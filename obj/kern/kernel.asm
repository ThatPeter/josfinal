
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
f0100048:	83 3d 80 9e 21 f0 00 	cmpl   $0x0,0xf0219e80
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 80 9e 21 f0    	mov    %esi,0xf0219e80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 d9 64 00 00       	call   f010653a <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 e0 6b 10 f0       	push   $0xf0106be0
f010006d:	e8 16 3d 00 00       	call   f0103d88 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 e6 3c 00 00       	call   f0103d62 <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 9a 84 10 f0 	movl   $0xf010849a,(%esp)
f0100083:	e8 00 3d 00 00       	call   f0103d88 <cprintf>
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
f01000a1:	b8 08 b0 25 f0       	mov    $0xf025b008,%eax
f01000a6:	2d 98 81 21 f0       	sub    $0xf0218198,%eax
f01000ab:	50                   	push   %eax
f01000ac:	6a 00                	push   $0x0
f01000ae:	68 98 81 21 f0       	push   $0xf0218198
f01000b3:	e8 60 5e 00 00       	call   f0105f18 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b8:	e8 96 05 00 00       	call   f0100653 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000bd:	83 c4 08             	add    $0x8,%esp
f01000c0:	68 ac 1a 00 00       	push   $0x1aac
f01000c5:	68 4c 6c 10 f0       	push   $0xf0106c4c
f01000ca:	e8 b9 3c 00 00       	call   f0103d88 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000cf:	e8 c0 13 00 00       	call   f0101494 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000d4:	e8 c2 30 00 00       	call   f010319b <env_init>
	trap_init();
f01000d9:	e8 a5 3d 00 00       	call   f0103e83 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000de:	e8 4d 61 00 00       	call   f0106230 <mp_init>
	lapic_init();
f01000e3:	e8 6d 64 00 00       	call   f0106555 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000e8:	e8 c2 3b 00 00       	call   f0103caf <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000ed:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f01000f4:	e8 af 66 00 00       	call   f01067a8 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000f9:	83 c4 10             	add    $0x10,%esp
f01000fc:	83 3d 88 9e 21 f0 07 	cmpl   $0x7,0xf0219e88
f0100103:	77 16                	ja     f010011b <i386_init+0x81>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100105:	68 00 70 00 00       	push   $0x7000
f010010a:	68 04 6c 10 f0       	push   $0xf0106c04
f010010f:	6a 58                	push   $0x58
f0100111:	68 67 6c 10 f0       	push   $0xf0106c67
f0100116:	e8 25 ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010011b:	83 ec 04             	sub    $0x4,%esp
f010011e:	b8 96 61 10 f0       	mov    $0xf0106196,%eax
f0100123:	2d 1c 61 10 f0       	sub    $0xf010611c,%eax
f0100128:	50                   	push   %eax
f0100129:	68 1c 61 10 f0       	push   $0xf010611c
f010012e:	68 00 70 00 f0       	push   $0xf0007000
f0100133:	e8 2d 5e 00 00       	call   f0105f65 <memmove>
f0100138:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010013b:	bb 20 a0 21 f0       	mov    $0xf021a020,%ebx
f0100140:	eb 4d                	jmp    f010018f <i386_init+0xf5>
		if (c == cpus + cpunum())  // We've started already.
f0100142:	e8 f3 63 00 00       	call   f010653a <cpunum>
f0100147:	6b c0 74             	imul   $0x74,%eax,%eax
f010014a:	05 20 a0 21 f0       	add    $0xf021a020,%eax
f010014f:	39 c3                	cmp    %eax,%ebx
f0100151:	74 39                	je     f010018c <i386_init+0xf2>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100153:	89 d8                	mov    %ebx,%eax
f0100155:	2d 20 a0 21 f0       	sub    $0xf021a020,%eax
f010015a:	c1 f8 02             	sar    $0x2,%eax
f010015d:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100163:	c1 e0 0f             	shl    $0xf,%eax
f0100166:	05 00 30 22 f0       	add    $0xf0223000,%eax
f010016b:	a3 84 9e 21 f0       	mov    %eax,0xf0219e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100170:	83 ec 08             	sub    $0x8,%esp
f0100173:	68 00 70 00 00       	push   $0x7000
f0100178:	0f b6 03             	movzbl (%ebx),%eax
f010017b:	50                   	push   %eax
f010017c:	e8 22 65 00 00       	call   f01066a3 <lapic_startap>
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
f010018f:	6b 05 c4 a3 21 f0 74 	imul   $0x74,0xf021a3c4,%eax
f0100196:	05 20 a0 21 f0       	add    $0xf021a020,%eax
f010019b:	39 c3                	cmp    %eax,%ebx
f010019d:	72 a3                	jb     f0100142 <i386_init+0xa8>
	lock_kernel();

	// Starting non-boot CPUs
	boot_aps();

	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f010019f:	83 ec 08             	sub    $0x8,%esp
f01001a2:	6a 01                	push   $0x1
f01001a4:	68 14 6c 1d f0       	push   $0xf01d6c14
f01001a9:	e8 8a 32 00 00       	call   f0103438 <env_create>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001ae:	83 c4 08             	add    $0x8,%esp
f01001b1:	6a 00                	push   $0x0
f01001b3:	68 b8 31 21 f0       	push   $0xf02131b8
f01001b8:	e8 7b 32 00 00       	call   f0103438 <env_create>
	// Touch all you want. Calls fork.
	ENV_CREATE(user_primes, ENV_TYPE_USER);
#endif // TEST* 
	
	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f01001bd:	e8 35 04 00 00       	call   f01005f7 <kbd_intr>
	// Schedule and run the first user environment!
	sched_yield();
f01001c2:	e8 43 4a 00 00       	call   f0104c0a <sched_yield>

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
f01001cd:	a1 8c 9e 21 f0       	mov    0xf0219e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001d2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001d7:	77 12                	ja     f01001eb <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001d9:	50                   	push   %eax
f01001da:	68 28 6c 10 f0       	push   $0xf0106c28
f01001df:	6a 6f                	push   $0x6f
f01001e1:	68 67 6c 10 f0       	push   $0xf0106c67
f01001e6:	e8 55 fe ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001eb:	05 00 00 00 10       	add    $0x10000000,%eax
f01001f0:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001f3:	e8 42 63 00 00       	call   f010653a <cpunum>
f01001f8:	83 ec 08             	sub    $0x8,%esp
f01001fb:	50                   	push   %eax
f01001fc:	68 73 6c 10 f0       	push   $0xf0106c73
f0100201:	e8 82 3b 00 00       	call   f0103d88 <cprintf>

	lapic_init();
f0100206:	e8 4a 63 00 00       	call   f0106555 <lapic_init>
	env_init_percpu();
f010020b:	e8 5b 2f 00 00       	call   f010316b <env_init_percpu>
	trap_init_percpu();
f0100210:	e8 87 3b 00 00       	call   f0103d9c <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100215:	e8 20 63 00 00       	call   f010653a <cpunum>
f010021a:	6b d0 74             	imul   $0x74,%eax,%edx
f010021d:	81 c2 20 a0 21 f0    	add    $0xf021a020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100223:	b8 01 00 00 00       	mov    $0x1,%eax
f0100228:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010022c:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f0100233:	e8 70 65 00 00       	call   f01067a8 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100238:	e8 cd 49 00 00       	call   f0104c0a <sched_yield>

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
f010024d:	68 89 6c 10 f0       	push   $0xf0106c89
f0100252:	e8 31 3b 00 00       	call   f0103d88 <cprintf>
	vcprintf(fmt, ap);
f0100257:	83 c4 08             	add    $0x8,%esp
f010025a:	53                   	push   %ebx
f010025b:	ff 75 10             	pushl  0x10(%ebp)
f010025e:	e8 ff 3a 00 00       	call   f0103d62 <vcprintf>
	cprintf("\n");
f0100263:	c7 04 24 9a 84 10 f0 	movl   $0xf010849a,(%esp)
f010026a:	e8 19 3b 00 00       	call   f0103d88 <cprintf>
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
f01002a5:	8b 0d 24 92 21 f0    	mov    0xf0219224,%ecx
f01002ab:	8d 51 01             	lea    0x1(%ecx),%edx
f01002ae:	89 15 24 92 21 f0    	mov    %edx,0xf0219224
f01002b4:	88 81 20 90 21 f0    	mov    %al,-0xfde6fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002ba:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002c0:	75 0a                	jne    f01002cc <cons_intr+0x36>
			cons.wpos = 0;
f01002c2:	c7 05 24 92 21 f0 00 	movl   $0x0,0xf0219224
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
f01002fb:	83 0d 00 90 21 f0 40 	orl    $0x40,0xf0219000
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
f0100313:	8b 0d 00 90 21 f0    	mov    0xf0219000,%ecx
f0100319:	89 cb                	mov    %ecx,%ebx
f010031b:	83 e3 40             	and    $0x40,%ebx
f010031e:	83 e0 7f             	and    $0x7f,%eax
f0100321:	85 db                	test   %ebx,%ebx
f0100323:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100326:	0f b6 d2             	movzbl %dl,%edx
f0100329:	0f b6 82 00 6e 10 f0 	movzbl -0xfef9200(%edx),%eax
f0100330:	83 c8 40             	or     $0x40,%eax
f0100333:	0f b6 c0             	movzbl %al,%eax
f0100336:	f7 d0                	not    %eax
f0100338:	21 c8                	and    %ecx,%eax
f010033a:	a3 00 90 21 f0       	mov    %eax,0xf0219000
		return 0;
f010033f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100344:	e9 a4 00 00 00       	jmp    f01003ed <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100349:	8b 0d 00 90 21 f0    	mov    0xf0219000,%ecx
f010034f:	f6 c1 40             	test   $0x40,%cl
f0100352:	74 0e                	je     f0100362 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100354:	83 c8 80             	or     $0xffffff80,%eax
f0100357:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100359:	83 e1 bf             	and    $0xffffffbf,%ecx
f010035c:	89 0d 00 90 21 f0    	mov    %ecx,0xf0219000
	}

	shift |= shiftcode[data];
f0100362:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100365:	0f b6 82 00 6e 10 f0 	movzbl -0xfef9200(%edx),%eax
f010036c:	0b 05 00 90 21 f0    	or     0xf0219000,%eax
f0100372:	0f b6 8a 00 6d 10 f0 	movzbl -0xfef9300(%edx),%ecx
f0100379:	31 c8                	xor    %ecx,%eax
f010037b:	a3 00 90 21 f0       	mov    %eax,0xf0219000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100380:	89 c1                	mov    %eax,%ecx
f0100382:	83 e1 03             	and    $0x3,%ecx
f0100385:	8b 0c 8d e0 6c 10 f0 	mov    -0xfef9320(,%ecx,4),%ecx
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
f01003c3:	68 a3 6c 10 f0       	push   $0xf0106ca3
f01003c8:	e8 bb 39 00 00       	call   f0103d88 <cprintf>
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
f01004af:	0f b7 05 28 92 21 f0 	movzwl 0xf0219228,%eax
f01004b6:	66 85 c0             	test   %ax,%ax
f01004b9:	0f 84 e6 00 00 00    	je     f01005a5 <cons_putc+0x1b3>
			crt_pos--;
f01004bf:	83 e8 01             	sub    $0x1,%eax
f01004c2:	66 a3 28 92 21 f0    	mov    %ax,0xf0219228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004c8:	0f b7 c0             	movzwl %ax,%eax
f01004cb:	66 81 e7 00 ff       	and    $0xff00,%di
f01004d0:	83 cf 20             	or     $0x20,%edi
f01004d3:	8b 15 2c 92 21 f0    	mov    0xf021922c,%edx
f01004d9:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004dd:	eb 78                	jmp    f0100557 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004df:	66 83 05 28 92 21 f0 	addw   $0x50,0xf0219228
f01004e6:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004e7:	0f b7 05 28 92 21 f0 	movzwl 0xf0219228,%eax
f01004ee:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004f4:	c1 e8 16             	shr    $0x16,%eax
f01004f7:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004fa:	c1 e0 04             	shl    $0x4,%eax
f01004fd:	66 a3 28 92 21 f0    	mov    %ax,0xf0219228
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
f0100539:	0f b7 05 28 92 21 f0 	movzwl 0xf0219228,%eax
f0100540:	8d 50 01             	lea    0x1(%eax),%edx
f0100543:	66 89 15 28 92 21 f0 	mov    %dx,0xf0219228
f010054a:	0f b7 c0             	movzwl %ax,%eax
f010054d:	8b 15 2c 92 21 f0    	mov    0xf021922c,%edx
f0100553:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100557:	66 81 3d 28 92 21 f0 	cmpw   $0x7cf,0xf0219228
f010055e:	cf 07 
f0100560:	76 43                	jbe    f01005a5 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100562:	a1 2c 92 21 f0       	mov    0xf021922c,%eax
f0100567:	83 ec 04             	sub    $0x4,%esp
f010056a:	68 00 0f 00 00       	push   $0xf00
f010056f:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100575:	52                   	push   %edx
f0100576:	50                   	push   %eax
f0100577:	e8 e9 59 00 00       	call   f0105f65 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010057c:	8b 15 2c 92 21 f0    	mov    0xf021922c,%edx
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
f010059d:	66 83 2d 28 92 21 f0 	subw   $0x50,0xf0219228
f01005a4:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01005a5:	8b 0d 30 92 21 f0    	mov    0xf0219230,%ecx
f01005ab:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005b0:	89 ca                	mov    %ecx,%edx
f01005b2:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005b3:	0f b7 1d 28 92 21 f0 	movzwl 0xf0219228,%ebx
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
f01005db:	80 3d 34 92 21 f0 00 	cmpb   $0x0,0xf0219234
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
f0100619:	a1 20 92 21 f0       	mov    0xf0219220,%eax
f010061e:	3b 05 24 92 21 f0    	cmp    0xf0219224,%eax
f0100624:	74 26                	je     f010064c <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100626:	8d 50 01             	lea    0x1(%eax),%edx
f0100629:	89 15 20 92 21 f0    	mov    %edx,0xf0219220
f010062f:	0f b6 88 20 90 21 f0 	movzbl -0xfde6fe0(%eax),%ecx
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
f0100640:	c7 05 20 92 21 f0 00 	movl   $0x0,0xf0219220
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
f0100679:	c7 05 30 92 21 f0 b4 	movl   $0x3b4,0xf0219230
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
f0100691:	c7 05 30 92 21 f0 d4 	movl   $0x3d4,0xf0219230
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
f01006a0:	8b 3d 30 92 21 f0    	mov    0xf0219230,%edi
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
f01006c5:	89 35 2c 92 21 f0    	mov    %esi,0xf021922c
	crt_pos = pos;
f01006cb:	0f b6 c0             	movzbl %al,%eax
f01006ce:	09 c8                	or     %ecx,%eax
f01006d0:	66 a3 28 92 21 f0    	mov    %ax,0xf0219228

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
f01006eb:	e8 47 35 00 00       	call   f0103c37 <irq_setmask_8259A>
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
f010074e:	0f 95 05 34 92 21 f0 	setne  0xf0219234
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
f0100770:	e8 c2 34 00 00       	call   f0103c37 <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100775:	83 c4 10             	add    $0x10,%esp
f0100778:	80 3d 34 92 21 f0 00 	cmpb   $0x0,0xf0219234
f010077f:	75 10                	jne    f0100791 <cons_init+0x13e>
		cprintf("Serial port does not exist!\n");
f0100781:	83 ec 0c             	sub    $0xc,%esp
f0100784:	68 af 6c 10 f0       	push   $0xf0106caf
f0100789:	e8 fa 35 00 00       	call   f0103d88 <cprintf>
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
f01007ca:	68 00 6f 10 f0       	push   $0xf0106f00
f01007cf:	68 1e 6f 10 f0       	push   $0xf0106f1e
f01007d4:	68 23 6f 10 f0       	push   $0xf0106f23
f01007d9:	e8 aa 35 00 00       	call   f0103d88 <cprintf>
f01007de:	83 c4 0c             	add    $0xc,%esp
f01007e1:	68 dc 6f 10 f0       	push   $0xf0106fdc
f01007e6:	68 2c 6f 10 f0       	push   $0xf0106f2c
f01007eb:	68 23 6f 10 f0       	push   $0xf0106f23
f01007f0:	e8 93 35 00 00       	call   f0103d88 <cprintf>
f01007f5:	83 c4 0c             	add    $0xc,%esp
f01007f8:	68 35 6f 10 f0       	push   $0xf0106f35
f01007fd:	68 3d 6f 10 f0       	push   $0xf0106f3d
f0100802:	68 23 6f 10 f0       	push   $0xf0106f23
f0100807:	e8 7c 35 00 00       	call   f0103d88 <cprintf>
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
f0100819:	68 47 6f 10 f0       	push   $0xf0106f47
f010081e:	e8 65 35 00 00       	call   f0103d88 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100823:	83 c4 08             	add    $0x8,%esp
f0100826:	68 0c 00 10 00       	push   $0x10000c
f010082b:	68 04 70 10 f0       	push   $0xf0107004
f0100830:	e8 53 35 00 00       	call   f0103d88 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100835:	83 c4 0c             	add    $0xc,%esp
f0100838:	68 0c 00 10 00       	push   $0x10000c
f010083d:	68 0c 00 10 f0       	push   $0xf010000c
f0100842:	68 2c 70 10 f0       	push   $0xf010702c
f0100847:	e8 3c 35 00 00       	call   f0103d88 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010084c:	83 c4 0c             	add    $0xc,%esp
f010084f:	68 c1 6b 10 00       	push   $0x106bc1
f0100854:	68 c1 6b 10 f0       	push   $0xf0106bc1
f0100859:	68 50 70 10 f0       	push   $0xf0107050
f010085e:	e8 25 35 00 00       	call   f0103d88 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100863:	83 c4 0c             	add    $0xc,%esp
f0100866:	68 98 81 21 00       	push   $0x218198
f010086b:	68 98 81 21 f0       	push   $0xf0218198
f0100870:	68 74 70 10 f0       	push   $0xf0107074
f0100875:	e8 0e 35 00 00       	call   f0103d88 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010087a:	83 c4 0c             	add    $0xc,%esp
f010087d:	68 08 b0 25 00       	push   $0x25b008
f0100882:	68 08 b0 25 f0       	push   $0xf025b008
f0100887:	68 98 70 10 f0       	push   $0xf0107098
f010088c:	e8 f7 34 00 00       	call   f0103d88 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100891:	b8 07 b4 25 f0       	mov    $0xf025b407,%eax
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
f01008b2:	68 bc 70 10 f0       	push   $0xf01070bc
f01008b7:	e8 cc 34 00 00       	call   f0103d88 <cprintf>
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
f01008ce:	68 60 6f 10 f0       	push   $0xf0106f60
f01008d3:	e8 b0 34 00 00       	call   f0103d88 <cprintf>
	
	while (ebp != 0) {
f01008d8:	83 c4 10             	add    $0x10,%esp
f01008db:	eb 67                	jmp    f0100944 <mon_backtrace+0x81>
		eip = ebp + 1;	   //eip is stored after ebp
		cprintf("ebp %x eip %x args ", ebp, *eip);
f01008dd:	83 ec 04             	sub    $0x4,%esp
f01008e0:	ff 76 04             	pushl  0x4(%esi)
f01008e3:	56                   	push   %esi
f01008e4:	68 72 6f 10 f0       	push   $0xf0106f72
f01008e9:	e8 9a 34 00 00       	call   f0103d88 <cprintf>
f01008ee:	8d 5e 08             	lea    0x8(%esi),%ebx
f01008f1:	8d 7e 1c             	lea    0x1c(%esi),%edi
f01008f4:	83 c4 10             	add    $0x10,%esp

		size_t arg_num;
		//print arguments stored after instruction pointer
		for (arg_num = 1; arg_num <= 5; arg_num++) {
			cprintf("%08x ", *(eip + arg_num));
f01008f7:	83 ec 08             	sub    $0x8,%esp
f01008fa:	ff 33                	pushl  (%ebx)
f01008fc:	68 86 6f 10 f0       	push   $0xf0106f86
f0100901:	e8 82 34 00 00       	call   f0103d88 <cprintf>
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
f010091a:	e8 11 4c 00 00       	call   f0105530 <debuginfo_eip>

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
f0100935:	68 8c 6f 10 f0       	push   $0xf0106f8c
f010093a:	e8 49 34 00 00       	call   f0103d88 <cprintf>
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
f010095e:	68 e8 70 10 f0       	push   $0xf01070e8
f0100963:	e8 20 34 00 00       	call   f0103d88 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100968:	c7 04 24 0c 71 10 f0 	movl   $0xf010710c,(%esp)
f010096f:	e8 14 34 00 00       	call   f0103d88 <cprintf>

	if (tf != NULL)
f0100974:	83 c4 10             	add    $0x10,%esp
f0100977:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010097b:	74 0e                	je     f010098b <monitor+0x36>
		print_trapframe(tf);
f010097d:	83 ec 0c             	sub    $0xc,%esp
f0100980:	ff 75 08             	pushl  0x8(%ebp)
f0100983:	e8 77 3b 00 00       	call   f01044ff <print_trapframe>
f0100988:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f010098b:	83 ec 0c             	sub    $0xc,%esp
f010098e:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0100993:	e8 11 53 00 00       	call   f0105ca9 <readline>
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
f01009c7:	68 a2 6f 10 f0       	push   $0xf0106fa2
f01009cc:	e8 0a 55 00 00       	call   f0105edb <strchr>
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
f01009e7:	68 a7 6f 10 f0       	push   $0xf0106fa7
f01009ec:	e8 97 33 00 00       	call   f0103d88 <cprintf>
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
f0100a10:	68 a2 6f 10 f0       	push   $0xf0106fa2
f0100a15:	e8 c1 54 00 00       	call   f0105edb <strchr>
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
f0100a3e:	ff 34 85 40 71 10 f0 	pushl  -0xfef8ec0(,%eax,4)
f0100a45:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a48:	e8 30 54 00 00       	call   f0105e7d <strcmp>
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
f0100a62:	ff 14 85 48 71 10 f0 	call   *-0xfef8eb8(,%eax,4)
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
f0100a83:	68 c4 6f 10 f0       	push   $0xf0106fc4
f0100a88:	e8 fb 32 00 00       	call   f0103d88 <cprintf>
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
f0100aa8:	e8 5c 31 00 00       	call   f0103c09 <mc146818_read>
f0100aad:	89 c6                	mov    %eax,%esi
f0100aaf:	83 c3 01             	add    $0x1,%ebx
f0100ab2:	89 1c 24             	mov    %ebx,(%esp)
f0100ab5:	e8 4f 31 00 00       	call   f0103c09 <mc146818_read>
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
f0100adc:	3b 0d 88 9e 21 f0    	cmp    0xf0219e88,%ecx
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
f0100aeb:	68 04 6c 10 f0       	push   $0xf0106c04
f0100af0:	68 cd 03 00 00       	push   $0x3cd
f0100af5:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f0100b2a:	83 3d 38 92 21 f0 00 	cmpl   $0x0,0xf0219238
f0100b31:	75 11                	jne    f0100b44 <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100b33:	ba 07 c0 25 f0       	mov    $0xf025c007,%edx
f0100b38:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b3e:	89 15 38 92 21 f0    	mov    %edx,0xf0219238
        // Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
        if (n == 0)
f0100b44:	85 c0                	test   %eax,%eax
f0100b46:	75 06                	jne    f0100b4e <boot_alloc+0x24>
                return nextfree;
f0100b48:	a1 38 92 21 f0       	mov    0xf0219238,%eax

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
f0100b57:	8b 15 38 92 21 f0    	mov    0xf0219238,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100b5d:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100b63:	77 12                	ja     f0100b77 <boot_alloc+0x4d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100b65:	52                   	push   %edx
f0100b66:	68 28 6c 10 f0       	push   $0xf0106c28
f0100b6b:	6a 70                	push   $0x70
f0100b6d:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0100b72:	e8 c9 f4 ff ff       	call   f0100040 <_panic>
f0100b77:	b8 00 00 40 f0       	mov    $0xf0400000,%eax
f0100b7c:	29 d0                	sub    %edx,%eax
f0100b7e:	39 c3                	cmp    %eax,%ebx
f0100b80:	76 14                	jbe    f0100b96 <boot_alloc+0x6c>
               panic("boot_alloc: ran out of free memory"); 
f0100b82:	83 ec 04             	sub    $0x4,%esp
f0100b85:	68 64 71 10 f0       	push   $0xf0107164
f0100b8a:	6a 71                	push   $0x71
f0100b8c:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0100b91:	e8 aa f4 ff ff       	call   f0100040 <_panic>
	cprintf("in boot alloc: free mem: %d\n",(4 * 1024 * 1024 - PADDR(nextfree)));
f0100b96:	83 ec 08             	sub    $0x8,%esp
f0100b99:	50                   	push   %eax
f0100b9a:	68 dd 7a 10 f0       	push   $0xf0107add
f0100b9f:	e8 e4 31 00 00       	call   f0103d88 <cprintf>

        result = nextfree;        
f0100ba4:	a1 38 92 21 f0       	mov    0xf0219238,%eax
        nextfree = ROUNDUP((char *) (nextfree + n), PGSIZE);
f0100ba9:	8d 94 18 ff 0f 00 00 	lea    0xfff(%eax,%ebx,1),%edx
f0100bb0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100bb6:	89 15 38 92 21 f0    	mov    %edx,0xf0219238

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
f0100bdd:	68 88 71 10 f0       	push   $0xf0107188
f0100be2:	68 00 03 00 00       	push   $0x300
f0100be7:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f0100bff:	2b 15 90 9e 21 f0    	sub    0xf0219e90,%edx
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
f0100c35:	a3 40 92 21 f0       	mov    %eax,0xf0219240
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
f0100c3f:	8b 1d 40 92 21 f0    	mov    0xf0219240,%ebx
f0100c45:	eb 53                	jmp    f0100c9a <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c47:	89 d8                	mov    %ebx,%eax
f0100c49:	2b 05 90 9e 21 f0    	sub    0xf0219e90,%eax
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
f0100c63:	3b 15 88 9e 21 f0    	cmp    0xf0219e88,%edx
f0100c69:	72 12                	jb     f0100c7d <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c6b:	50                   	push   %eax
f0100c6c:	68 04 6c 10 f0       	push   $0xf0106c04
f0100c71:	6a 58                	push   $0x58
f0100c73:	68 fa 7a 10 f0       	push   $0xf0107afa
f0100c78:	e8 c3 f3 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c7d:	83 ec 04             	sub    $0x4,%esp
f0100c80:	68 80 00 00 00       	push   $0x80
f0100c85:	68 97 00 00 00       	push   $0x97
f0100c8a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c8f:	50                   	push   %eax
f0100c90:	e8 83 52 00 00       	call   f0105f18 <memset>
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
f0100cab:	8b 15 40 92 21 f0    	mov    0xf0219240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100cb1:	8b 0d 90 9e 21 f0    	mov    0xf0219e90,%ecx
		assert(pp < pages + npages);
f0100cb7:	a1 88 9e 21 f0       	mov    0xf0219e88,%eax
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
f0100cd6:	68 08 7b 10 f0       	push   $0xf0107b08
f0100cdb:	68 14 7b 10 f0       	push   $0xf0107b14
f0100ce0:	68 1a 03 00 00       	push   $0x31a
f0100ce5:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0100cea:	e8 51 f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100cef:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100cf2:	72 19                	jb     f0100d0d <check_page_free_list+0x149>
f0100cf4:	68 29 7b 10 f0       	push   $0xf0107b29
f0100cf9:	68 14 7b 10 f0       	push   $0xf0107b14
f0100cfe:	68 1b 03 00 00       	push   $0x31b
f0100d03:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0100d08:	e8 33 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d0d:	89 d0                	mov    %edx,%eax
f0100d0f:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100d12:	a8 07                	test   $0x7,%al
f0100d14:	74 19                	je     f0100d2f <check_page_free_list+0x16b>
f0100d16:	68 ac 71 10 f0       	push   $0xf01071ac
f0100d1b:	68 14 7b 10 f0       	push   $0xf0107b14
f0100d20:	68 1c 03 00 00       	push   $0x31c
f0100d25:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f0100d39:	68 3d 7b 10 f0       	push   $0xf0107b3d
f0100d3e:	68 14 7b 10 f0       	push   $0xf0107b14
f0100d43:	68 1f 03 00 00       	push   $0x31f
f0100d48:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0100d4d:	e8 ee f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d52:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d57:	75 19                	jne    f0100d72 <check_page_free_list+0x1ae>
f0100d59:	68 4e 7b 10 f0       	push   $0xf0107b4e
f0100d5e:	68 14 7b 10 f0       	push   $0xf0107b14
f0100d63:	68 20 03 00 00       	push   $0x320
f0100d68:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0100d6d:	e8 ce f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d72:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d77:	75 19                	jne    f0100d92 <check_page_free_list+0x1ce>
f0100d79:	68 e0 71 10 f0       	push   $0xf01071e0
f0100d7e:	68 14 7b 10 f0       	push   $0xf0107b14
f0100d83:	68 21 03 00 00       	push   $0x321
f0100d88:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0100d8d:	e8 ae f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d92:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d97:	75 19                	jne    f0100db2 <check_page_free_list+0x1ee>
f0100d99:	68 67 7b 10 f0       	push   $0xf0107b67
f0100d9e:	68 14 7b 10 f0       	push   $0xf0107b14
f0100da3:	68 22 03 00 00       	push   $0x322
f0100da8:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f0100dc8:	68 04 6c 10 f0       	push   $0xf0106c04
f0100dcd:	6a 58                	push   $0x58
f0100dcf:	68 fa 7a 10 f0       	push   $0xf0107afa
f0100dd4:	e8 67 f2 ff ff       	call   f0100040 <_panic>
f0100dd9:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100ddf:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100de2:	0f 86 b6 00 00 00    	jbe    f0100e9e <check_page_free_list+0x2da>
f0100de8:	68 04 72 10 f0       	push   $0xf0107204
f0100ded:	68 14 7b 10 f0       	push   $0xf0107b14
f0100df2:	68 23 03 00 00       	push   $0x323
f0100df7:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0100dfc:	e8 3f f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e01:	68 81 7b 10 f0       	push   $0xf0107b81
f0100e06:	68 14 7b 10 f0       	push   $0xf0107b14
f0100e0b:	68 25 03 00 00       	push   $0x325
f0100e10:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f0100e30:	68 9e 7b 10 f0       	push   $0xf0107b9e
f0100e35:	68 14 7b 10 f0       	push   $0xf0107b14
f0100e3a:	68 2d 03 00 00       	push   $0x32d
f0100e3f:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0100e44:	e8 f7 f1 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e49:	85 db                	test   %ebx,%ebx
f0100e4b:	7f 19                	jg     f0100e66 <check_page_free_list+0x2a2>
f0100e4d:	68 b0 7b 10 f0       	push   $0xf0107bb0
f0100e52:	68 14 7b 10 f0       	push   $0xf0107b14
f0100e57:	68 2e 03 00 00       	push   $0x32e
f0100e5c:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0100e61:	e8 da f1 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100e66:	83 ec 0c             	sub    $0xc,%esp
f0100e69:	68 4c 72 10 f0       	push   $0xf010724c
f0100e6e:	e8 15 2f 00 00       	call   f0103d88 <cprintf>
}
f0100e73:	eb 49                	jmp    f0100ebe <check_page_free_list+0x2fa>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e75:	a1 40 92 21 f0       	mov    0xf0219240,%eax
f0100e7a:	85 c0                	test   %eax,%eax
f0100e7c:	0f 85 6f fd ff ff    	jne    f0100bf1 <check_page_free_list+0x2d>
f0100e82:	e9 53 fd ff ff       	jmp    f0100bda <check_page_free_list+0x16>
f0100e87:	83 3d 40 92 21 f0 00 	cmpl   $0x0,0xf0219240
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
f0100ec6:	a1 90 9e 21 f0       	mov    0xf0219e90,%eax
f0100ecb:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0100ed0:	8b 15 40 92 21 f0    	mov    0xf0219240,%edx
f0100ed6:	b8 08 00 00 00       	mov    $0x8,%eax
        // 2) All base pages except 0 are free
        size_t i;
        size_t mpentry_page = MPENTRY_PADDR / PGSIZE; 

        for (i = 1; i < mpentry_page; i++) {
                pages[i].pp_link = page_free_list;
f0100edb:	8b 0d 90 9e 21 f0    	mov    0xf0219e90,%ecx
f0100ee1:	89 14 01             	mov    %edx,(%ecx,%eax,1)
                page_free_list = &pages[i];
f0100ee4:	8b 0d 90 9e 21 f0    	mov    0xf0219e90,%ecx
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
f0100efa:	89 15 40 92 21 f0    	mov    %edx,0xf0219240
        for (i = 1; i < mpentry_page; i++) {
                pages[i].pp_link = page_free_list;
                page_free_list = &pages[i];
        }

        pages[mpentry_page].pp_ref++;
f0100f00:	66 83 41 3c 01       	addw   $0x1,0x3c(%ecx)

        for (i = mpentry_page + 1; i < npages_basemem; i++) {
f0100f05:	8b 1d 44 92 21 f0    	mov    0xf0219244,%ebx
f0100f0b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100f10:	b8 08 00 00 00       	mov    $0x8,%eax
f0100f15:	eb 20                	jmp    f0100f37 <page_init+0x71>
f0100f17:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
                pages[i].pp_link = page_free_list;
f0100f1e:	8b 35 90 9e 21 f0    	mov    0xf0219e90,%esi
f0100f24:	89 14 c6             	mov    %edx,(%esi,%eax,8)
                page_free_list = &pages[i];
        }

        pages[mpentry_page].pp_ref++;

        for (i = mpentry_page + 1; i < npages_basemem; i++) {
f0100f27:	83 c0 01             	add    $0x1,%eax
                pages[i].pp_link = page_free_list;
                page_free_list = &pages[i];
f0100f2a:	89 ca                	mov    %ecx,%edx
f0100f2c:	03 15 90 9e 21 f0    	add    0xf0219e90,%edx
f0100f32:	b9 01 00 00 00       	mov    $0x1,%ecx
                page_free_list = &pages[i];
        }

        pages[mpentry_page].pp_ref++;

        for (i = mpentry_page + 1; i < npages_basemem; i++) {
f0100f37:	39 d8                	cmp    %ebx,%eax
f0100f39:	72 dc                	jb     f0100f17 <page_init+0x51>
f0100f3b:	84 c9                	test   %cl,%cl
f0100f3d:	74 06                	je     f0100f45 <page_init+0x7f>
f0100f3f:	89 15 40 92 21 f0    	mov    %edx,0xf0219240
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
f0100f57:	68 28 6c 10 f0       	push   $0xf0106c28
f0100f5c:	68 60 01 00 00       	push   $0x160
f0100f61:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0100f66:	e8 d5 f0 ff ff       	call   f0100040 <_panic>
f0100f6b:	05 00 00 00 10       	add    $0x10000000,%eax
f0100f70:	c1 e8 0c             	shr    $0xc,%eax
f0100f73:	8b 0d 40 92 21 f0    	mov    0xf0219240,%ecx
f0100f79:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100f80:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100f85:	eb 1c                	jmp    f0100fa3 <page_init+0xdd>
                pages[i].pp_link = page_free_list;
f0100f87:	8b 35 90 9e 21 f0    	mov    0xf0219e90,%esi
f0100f8d:	89 0c 16             	mov    %ecx,(%esi,%edx,1)
                page_free_list = &pages[i];
f0100f90:	89 d1                	mov    %edx,%ecx
f0100f92:	03 0d 90 9e 21 f0    	add    0xf0219e90,%ecx
                page_free_list = &pages[i];
        }

        // 4) We find the next free memory (boot_alloc() outputs a rounded-up virtual address),
        // convert it to a physical address and get the index of free pages by dividing by PGSIZE  
        for (i = PADDR(boot_alloc(0)) / PGSIZE; i < npages; i++) {
f0100f98:	83 c0 01             	add    $0x1,%eax
f0100f9b:	83 c2 08             	add    $0x8,%edx
f0100f9e:	bb 01 00 00 00       	mov    $0x1,%ebx
f0100fa3:	3b 05 88 9e 21 f0    	cmp    0xf0219e88,%eax
f0100fa9:	72 dc                	jb     f0100f87 <page_init+0xc1>
f0100fab:	84 db                	test   %bl,%bl
f0100fad:	74 06                	je     f0100fb5 <page_init+0xef>
f0100faf:	89 0d 40 92 21 f0    	mov    %ecx,0xf0219240
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
f0100fc3:	8b 1d 40 92 21 f0    	mov    0xf0219240,%ebx
f0100fc9:	85 db                	test   %ebx,%ebx
f0100fcb:	74 58                	je     f0101025 <page_alloc+0x69>
                return NULL;

        struct PageInfo *page = page_free_list;
        page_free_list = page->pp_link;
f0100fcd:	8b 03                	mov    (%ebx),%eax
f0100fcf:	a3 40 92 21 f0       	mov    %eax,0xf0219240

	if (alloc_flags & ALLOC_ZERO) {
f0100fd4:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100fd8:	74 45                	je     f010101f <page_alloc+0x63>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100fda:	89 d8                	mov    %ebx,%eax
f0100fdc:	2b 05 90 9e 21 f0    	sub    0xf0219e90,%eax
f0100fe2:	c1 f8 03             	sar    $0x3,%eax
f0100fe5:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fe8:	89 c2                	mov    %eax,%edx
f0100fea:	c1 ea 0c             	shr    $0xc,%edx
f0100fed:	3b 15 88 9e 21 f0    	cmp    0xf0219e88,%edx
f0100ff3:	72 12                	jb     f0101007 <page_alloc+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ff5:	50                   	push   %eax
f0100ff6:	68 04 6c 10 f0       	push   $0xf0106c04
f0100ffb:	6a 58                	push   $0x58
f0100ffd:	68 fa 7a 10 f0       	push   $0xf0107afa
f0101002:	e8 39 f0 ff ff       	call   f0100040 <_panic>
                char *p = page2kva(page);
                memset(p, 0, PGSIZE);
f0101007:	83 ec 04             	sub    $0x4,%esp
f010100a:	68 00 10 00 00       	push   $0x1000
f010100f:	6a 00                	push   $0x0
f0101011:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101016:	50                   	push   %eax
f0101017:	e8 fc 4e 00 00       	call   f0105f18 <memset>
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
f0101039:	68 fb 7c 10 f0       	push   $0xf0107cfb
f010103e:	68 14 7b 10 f0       	push   $0xf0107b14
f0101043:	68 8b 01 00 00       	push   $0x18b
f0101048:	68 d1 7a 10 f0       	push   $0xf0107ad1
f010104d:	e8 ee ef ff ff       	call   f0100040 <_panic>

        // Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
        if (pp->pp_ref != 0) 
f0101052:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101057:	74 17                	je     f0101070 <page_free+0x44>
                panic("pp->pp_ref is nonzero\n");
f0101059:	83 ec 04             	sub    $0x4,%esp
f010105c:	68 c1 7b 10 f0       	push   $0xf0107bc1
f0101061:	68 91 01 00 00       	push   $0x191
f0101066:	68 d1 7a 10 f0       	push   $0xf0107ad1
f010106b:	e8 d0 ef ff ff       	call   f0100040 <_panic>

        if (pp->pp_link != NULL)
f0101070:	83 38 00             	cmpl   $0x0,(%eax)
f0101073:	74 17                	je     f010108c <page_free+0x60>
                panic("pp->pp_link is not NULL\n");
f0101075:	83 ec 04             	sub    $0x4,%esp
f0101078:	68 d8 7b 10 f0       	push   $0xf0107bd8
f010107d:	68 94 01 00 00       	push   $0x194
f0101082:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0101087:	e8 b4 ef ff ff       	call   f0100040 <_panic>

        pp->pp_link = page_free_list;
f010108c:	8b 15 40 92 21 f0    	mov    0xf0219240,%edx
f0101092:	89 10                	mov    %edx,(%eax)
        page_free_list = pp;
f0101094:	a3 40 92 21 f0       	mov    %eax,0xf0219240
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
f01010d1:	68 f1 7b 10 f0       	push   $0xf0107bf1
f01010d6:	68 14 7b 10 f0       	push   $0xf0107b14
f01010db:	68 be 01 00 00       	push   $0x1be
f01010e0:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f0101104:	39 05 88 9e 21 f0    	cmp    %eax,0xf0219e88
f010110a:	77 15                	ja     f0101121 <pgdir_walk+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010110c:	52                   	push   %edx
f010110d:	68 04 6c 10 f0       	push   $0xf0106c04
f0101112:	68 c5 01 00 00       	push   $0x1c5
f0101117:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f0101142:	2b 15 90 9e 21 f0    	sub    0xf0219e90,%edx
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
f0101158:	2b 05 90 9e 21 f0    	sub    0xf0219e90,%eax
f010115e:	c1 f8 03             	sar    $0x3,%eax
f0101161:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101164:	89 c2                	mov    %eax,%edx
f0101166:	c1 ea 0c             	shr    $0xc,%edx
f0101169:	3b 15 88 9e 21 f0    	cmp    0xf0219e88,%edx
f010116f:	72 12                	jb     f0101183 <pgdir_walk+0xc1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101171:	50                   	push   %eax
f0101172:	68 04 6c 10 f0       	push   $0xf0106c04
f0101177:	6a 58                	push   $0x58
f0101179:	68 fa 7a 10 f0       	push   $0xf0107afa
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
f01011d9:	68 f1 7b 10 f0       	push   $0xf0107bf1
f01011de:	68 14 7b 10 f0       	push   $0xf0107b14
f01011e3:	68 e5 01 00 00       	push   $0x1e5
f01011e8:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f010120a:	68 f7 7b 10 f0       	push   $0xf0107bf7
f010120f:	68 14 7b 10 f0       	push   $0xf0107b14
f0101214:	68 ed 01 00 00       	push   $0x1ed
f0101219:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f0101251:	68 f1 7b 10 f0       	push   $0xf0107bf1
f0101256:	68 14 7b 10 f0       	push   $0xf0107b14
f010125b:	68 3a 02 00 00       	push   $0x23a
f0101260:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f010128f:	3b 05 88 9e 21 f0    	cmp    0xf0219e88,%eax
f0101295:	72 14                	jb     f01012ab <page_lookup+0x6b>
		panic("pa2page called with invalid pa");
f0101297:	83 ec 04             	sub    $0x4,%esp
f010129a:	68 70 72 10 f0       	push   $0xf0107270
f010129f:	6a 51                	push   $0x51
f01012a1:	68 fa 7a 10 f0       	push   $0xf0107afa
f01012a6:	e8 95 ed ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01012ab:	8b 15 90 9e 21 f0    	mov    0xf0219e90,%edx
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
f01012cd:	e8 68 52 00 00       	call   f010653a <cpunum>
f01012d2:	6b c0 74             	imul   $0x74,%eax,%eax
f01012d5:	83 b8 28 a0 21 f0 00 	cmpl   $0x0,-0xfde5fd8(%eax)
f01012dc:	74 19                	je     f01012f7 <tlb_invalidate+0x30>
f01012de:	e8 57 52 00 00       	call   f010653a <cpunum>
f01012e3:	6b c0 74             	imul   $0x74,%eax,%eax
f01012e6:	8b 80 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%eax
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
f0101311:	68 f1 7b 10 f0       	push   $0xf0107bf1
f0101316:	68 14 7b 10 f0       	push   $0xf0107b14
f010131b:	68 59 02 00 00       	push   $0x259
f0101320:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f0101380:	68 f1 7b 10 f0       	push   $0xf0107bf1
f0101385:	68 14 7b 10 f0       	push   $0xf0107b14
f010138a:	68 12 02 00 00       	push   $0x212
f010138f:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0101394:	e8 a7 ec ff ff       	call   f0100040 <_panic>
        assert(pp);
f0101399:	85 db                	test   %ebx,%ebx
f010139b:	75 19                	jne    f01013b6 <page_insert+0x49>
f010139d:	68 fb 7c 10 f0       	push   $0xf0107cfb
f01013a2:	68 14 7b 10 f0       	push   $0xf0107b14
f01013a7:	68 13 02 00 00       	push   $0x213
f01013ac:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f01013da:	2b 15 90 9e 21 f0    	sub    0xf0219e90,%edx
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
f010140a:	2b 1d 90 9e 21 f0    	sub    0xf0219e90,%ebx
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
f010145b:	68 90 72 10 f0       	push   $0xf0107290
f0101460:	68 99 02 00 00       	push   $0x299
f0101465:	68 d1 7a 10 f0       	push   $0xf0107ad1
f010146a:	e8 d1 eb ff ff       	call   f0100040 <_panic>

        boot_map_region(kern_pgdir, base, sz, pa, PTE_W | PTE_PCD | PTE_PWT);      
f010146f:	83 ec 08             	sub    $0x8,%esp
f0101472:	6a 1a                	push   $0x1a
f0101474:	ff 75 08             	pushl  0x8(%ebp)
f0101477:	89 d9                	mov    %ebx,%ecx
f0101479:	89 f2                	mov    %esi,%edx
f010147b:	a1 8c 9e 21 f0       	mov    0xf0219e8c,%eax
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
f01014dd:	89 15 88 9e 21 f0    	mov    %edx,0xf0219e88
	npages_basemem = basemem / (PGSIZE / 1024);
f01014e3:	89 da                	mov    %ebx,%edx
f01014e5:	c1 ea 02             	shr    $0x2,%edx
f01014e8:	89 15 44 92 21 f0    	mov    %edx,0xf0219244

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01014ee:	89 c2                	mov    %eax,%edx
f01014f0:	29 da                	sub    %ebx,%edx
f01014f2:	52                   	push   %edx
f01014f3:	53                   	push   %ebx
f01014f4:	50                   	push   %eax
f01014f5:	68 b8 72 10 f0       	push   $0xf01072b8
f01014fa:	e8 89 28 00 00       	call   f0103d88 <cprintf>
	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01014ff:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101504:	e8 21 f6 ff ff       	call   f0100b2a <boot_alloc>
f0101509:	a3 8c 9e 21 f0       	mov    %eax,0xf0219e8c
	memset(kern_pgdir, 0, PGSIZE);
f010150e:	83 c4 0c             	add    $0xc,%esp
f0101511:	68 00 10 00 00       	push   $0x1000
f0101516:	6a 00                	push   $0x0
f0101518:	50                   	push   %eax
f0101519:	e8 fa 49 00 00       	call   f0105f18 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010151e:	a1 8c 9e 21 f0       	mov    0xf0219e8c,%eax
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
f010152e:	68 28 6c 10 f0       	push   $0xf0106c28
f0101533:	68 98 00 00 00       	push   $0x98
f0101538:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f0101551:	a1 88 9e 21 f0       	mov    0xf0219e88,%eax
f0101556:	c1 e0 03             	shl    $0x3,%eax
f0101559:	89 c7                	mov    %eax,%edi
f010155b:	89 45 cc             	mov    %eax,-0x34(%ebp)
        pages = (struct PageInfo *) boot_alloc(pages_size);
f010155e:	e8 c7 f5 ff ff       	call   f0100b2a <boot_alloc>
f0101563:	a3 90 9e 21 f0       	mov    %eax,0xf0219e90
        memset(pages, 0, pages_size);
f0101568:	83 ec 04             	sub    $0x4,%esp
f010156b:	57                   	push   %edi
f010156c:	6a 00                	push   $0x0
f010156e:	50                   	push   %eax
f010156f:	e8 a4 49 00 00       	call   f0105f18 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
        const size_t envs_size = sizeof(struct Env) * NENV;
        envs = (struct Env *) boot_alloc(envs_size);
f0101574:	b8 00 60 03 00       	mov    $0x36000,%eax
f0101579:	e8 ac f5 ff ff       	call   f0100b2a <boot_alloc>
f010157e:	a3 4c 92 21 f0       	mov    %eax,0xf021924c
        memset(envs, 0, envs_size);
f0101583:	83 c4 0c             	add    $0xc,%esp
f0101586:	68 00 60 03 00       	push   $0x36000
f010158b:	6a 00                	push   $0x0
f010158d:	50                   	push   %eax
f010158e:	e8 85 49 00 00       	call   f0105f18 <memset>
	
	//Lab 7: Multithreading
	/*Alloc place for the free stack stacks stacking*/

	const size_t stack_size = sizeof(struct FreeStacks) * MAX_THREADS;
	thread_free_stacks = (struct FreeStacks*) boot_alloc(stack_size);
f0101593:	b8 f4 2f 00 00       	mov    $0x2ff4,%eax
f0101598:	e8 8d f5 ff ff       	call   f0100b2a <boot_alloc>
f010159d:	a3 48 92 21 f0       	mov    %eax,0xf0219248
	memset(thread_free_stacks, 0, stack_size);
f01015a2:	83 c4 0c             	add    $0xc,%esp
f01015a5:	68 f4 2f 00 00       	push   $0x2ff4
f01015aa:	6a 00                	push   $0x0
f01015ac:	50                   	push   %eax
f01015ad:	e8 66 49 00 00       	call   f0105f18 <memset>
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
f01015c4:	83 3d 90 9e 21 f0 00 	cmpl   $0x0,0xf0219e90
f01015cb:	75 17                	jne    f01015e4 <mem_init+0x150>
		panic("'pages' is a null pointer!");
f01015cd:	83 ec 04             	sub    $0x4,%esp
f01015d0:	68 fb 7b 10 f0       	push   $0xf0107bfb
f01015d5:	68 41 03 00 00       	push   $0x341
f01015da:	68 d1 7a 10 f0       	push   $0xf0107ad1
f01015df:	e8 5c ea ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01015e4:	a1 40 92 21 f0       	mov    0xf0219240,%eax
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
f010160c:	68 16 7c 10 f0       	push   $0xf0107c16
f0101611:	68 14 7b 10 f0       	push   $0xf0107b14
f0101616:	68 49 03 00 00       	push   $0x349
f010161b:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0101620:	e8 1b ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101625:	83 ec 0c             	sub    $0xc,%esp
f0101628:	6a 00                	push   $0x0
f010162a:	e8 8d f9 ff ff       	call   f0100fbc <page_alloc>
f010162f:	89 c6                	mov    %eax,%esi
f0101631:	83 c4 10             	add    $0x10,%esp
f0101634:	85 c0                	test   %eax,%eax
f0101636:	75 19                	jne    f0101651 <mem_init+0x1bd>
f0101638:	68 2c 7c 10 f0       	push   $0xf0107c2c
f010163d:	68 14 7b 10 f0       	push   $0xf0107b14
f0101642:	68 4a 03 00 00       	push   $0x34a
f0101647:	68 d1 7a 10 f0       	push   $0xf0107ad1
f010164c:	e8 ef e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101651:	83 ec 0c             	sub    $0xc,%esp
f0101654:	6a 00                	push   $0x0
f0101656:	e8 61 f9 ff ff       	call   f0100fbc <page_alloc>
f010165b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010165e:	83 c4 10             	add    $0x10,%esp
f0101661:	85 c0                	test   %eax,%eax
f0101663:	75 19                	jne    f010167e <mem_init+0x1ea>
f0101665:	68 42 7c 10 f0       	push   $0xf0107c42
f010166a:	68 14 7b 10 f0       	push   $0xf0107b14
f010166f:	68 4b 03 00 00       	push   $0x34b
f0101674:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0101679:	e8 c2 e9 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010167e:	39 f7                	cmp    %esi,%edi
f0101680:	75 19                	jne    f010169b <mem_init+0x207>
f0101682:	68 58 7c 10 f0       	push   $0xf0107c58
f0101687:	68 14 7b 10 f0       	push   $0xf0107b14
f010168c:	68 4e 03 00 00       	push   $0x34e
f0101691:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0101696:	e8 a5 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010169b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010169e:	39 c6                	cmp    %eax,%esi
f01016a0:	74 04                	je     f01016a6 <mem_init+0x212>
f01016a2:	39 c7                	cmp    %eax,%edi
f01016a4:	75 19                	jne    f01016bf <mem_init+0x22b>
f01016a6:	68 f4 72 10 f0       	push   $0xf01072f4
f01016ab:	68 14 7b 10 f0       	push   $0xf0107b14
f01016b0:	68 4f 03 00 00       	push   $0x34f
f01016b5:	68 d1 7a 10 f0       	push   $0xf0107ad1
f01016ba:	e8 81 e9 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01016bf:	8b 0d 90 9e 21 f0    	mov    0xf0219e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01016c5:	8b 15 88 9e 21 f0    	mov    0xf0219e88,%edx
f01016cb:	c1 e2 0c             	shl    $0xc,%edx
f01016ce:	89 f8                	mov    %edi,%eax
f01016d0:	29 c8                	sub    %ecx,%eax
f01016d2:	c1 f8 03             	sar    $0x3,%eax
f01016d5:	c1 e0 0c             	shl    $0xc,%eax
f01016d8:	39 d0                	cmp    %edx,%eax
f01016da:	72 19                	jb     f01016f5 <mem_init+0x261>
f01016dc:	68 6a 7c 10 f0       	push   $0xf0107c6a
f01016e1:	68 14 7b 10 f0       	push   $0xf0107b14
f01016e6:	68 50 03 00 00       	push   $0x350
f01016eb:	68 d1 7a 10 f0       	push   $0xf0107ad1
f01016f0:	e8 4b e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01016f5:	89 f0                	mov    %esi,%eax
f01016f7:	29 c8                	sub    %ecx,%eax
f01016f9:	c1 f8 03             	sar    $0x3,%eax
f01016fc:	c1 e0 0c             	shl    $0xc,%eax
f01016ff:	39 c2                	cmp    %eax,%edx
f0101701:	77 19                	ja     f010171c <mem_init+0x288>
f0101703:	68 87 7c 10 f0       	push   $0xf0107c87
f0101708:	68 14 7b 10 f0       	push   $0xf0107b14
f010170d:	68 51 03 00 00       	push   $0x351
f0101712:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0101717:	e8 24 e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010171c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010171f:	29 c8                	sub    %ecx,%eax
f0101721:	c1 f8 03             	sar    $0x3,%eax
f0101724:	c1 e0 0c             	shl    $0xc,%eax
f0101727:	39 c2                	cmp    %eax,%edx
f0101729:	77 19                	ja     f0101744 <mem_init+0x2b0>
f010172b:	68 a4 7c 10 f0       	push   $0xf0107ca4
f0101730:	68 14 7b 10 f0       	push   $0xf0107b14
f0101735:	68 52 03 00 00       	push   $0x352
f010173a:	68 d1 7a 10 f0       	push   $0xf0107ad1
f010173f:	e8 fc e8 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101744:	a1 40 92 21 f0       	mov    0xf0219240,%eax
f0101749:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010174c:	c7 05 40 92 21 f0 00 	movl   $0x0,0xf0219240
f0101753:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101756:	83 ec 0c             	sub    $0xc,%esp
f0101759:	6a 00                	push   $0x0
f010175b:	e8 5c f8 ff ff       	call   f0100fbc <page_alloc>
f0101760:	83 c4 10             	add    $0x10,%esp
f0101763:	85 c0                	test   %eax,%eax
f0101765:	74 19                	je     f0101780 <mem_init+0x2ec>
f0101767:	68 c1 7c 10 f0       	push   $0xf0107cc1
f010176c:	68 14 7b 10 f0       	push   $0xf0107b14
f0101771:	68 59 03 00 00       	push   $0x359
f0101776:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f01017b1:	68 16 7c 10 f0       	push   $0xf0107c16
f01017b6:	68 14 7b 10 f0       	push   $0xf0107b14
f01017bb:	68 60 03 00 00       	push   $0x360
f01017c0:	68 d1 7a 10 f0       	push   $0xf0107ad1
f01017c5:	e8 76 e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01017ca:	83 ec 0c             	sub    $0xc,%esp
f01017cd:	6a 00                	push   $0x0
f01017cf:	e8 e8 f7 ff ff       	call   f0100fbc <page_alloc>
f01017d4:	89 c7                	mov    %eax,%edi
f01017d6:	83 c4 10             	add    $0x10,%esp
f01017d9:	85 c0                	test   %eax,%eax
f01017db:	75 19                	jne    f01017f6 <mem_init+0x362>
f01017dd:	68 2c 7c 10 f0       	push   $0xf0107c2c
f01017e2:	68 14 7b 10 f0       	push   $0xf0107b14
f01017e7:	68 61 03 00 00       	push   $0x361
f01017ec:	68 d1 7a 10 f0       	push   $0xf0107ad1
f01017f1:	e8 4a e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01017f6:	83 ec 0c             	sub    $0xc,%esp
f01017f9:	6a 00                	push   $0x0
f01017fb:	e8 bc f7 ff ff       	call   f0100fbc <page_alloc>
f0101800:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101803:	83 c4 10             	add    $0x10,%esp
f0101806:	85 c0                	test   %eax,%eax
f0101808:	75 19                	jne    f0101823 <mem_init+0x38f>
f010180a:	68 42 7c 10 f0       	push   $0xf0107c42
f010180f:	68 14 7b 10 f0       	push   $0xf0107b14
f0101814:	68 62 03 00 00       	push   $0x362
f0101819:	68 d1 7a 10 f0       	push   $0xf0107ad1
f010181e:	e8 1d e8 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101823:	39 fe                	cmp    %edi,%esi
f0101825:	75 19                	jne    f0101840 <mem_init+0x3ac>
f0101827:	68 58 7c 10 f0       	push   $0xf0107c58
f010182c:	68 14 7b 10 f0       	push   $0xf0107b14
f0101831:	68 64 03 00 00       	push   $0x364
f0101836:	68 d1 7a 10 f0       	push   $0xf0107ad1
f010183b:	e8 00 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101840:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101843:	39 c7                	cmp    %eax,%edi
f0101845:	74 04                	je     f010184b <mem_init+0x3b7>
f0101847:	39 c6                	cmp    %eax,%esi
f0101849:	75 19                	jne    f0101864 <mem_init+0x3d0>
f010184b:	68 f4 72 10 f0       	push   $0xf01072f4
f0101850:	68 14 7b 10 f0       	push   $0xf0107b14
f0101855:	68 65 03 00 00       	push   $0x365
f010185a:	68 d1 7a 10 f0       	push   $0xf0107ad1
f010185f:	e8 dc e7 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101864:	83 ec 0c             	sub    $0xc,%esp
f0101867:	6a 00                	push   $0x0
f0101869:	e8 4e f7 ff ff       	call   f0100fbc <page_alloc>
f010186e:	83 c4 10             	add    $0x10,%esp
f0101871:	85 c0                	test   %eax,%eax
f0101873:	74 19                	je     f010188e <mem_init+0x3fa>
f0101875:	68 c1 7c 10 f0       	push   $0xf0107cc1
f010187a:	68 14 7b 10 f0       	push   $0xf0107b14
f010187f:	68 66 03 00 00       	push   $0x366
f0101884:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0101889:	e8 b2 e7 ff ff       	call   f0100040 <_panic>
f010188e:	89 f0                	mov    %esi,%eax
f0101890:	2b 05 90 9e 21 f0    	sub    0xf0219e90,%eax
f0101896:	c1 f8 03             	sar    $0x3,%eax
f0101899:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010189c:	89 c2                	mov    %eax,%edx
f010189e:	c1 ea 0c             	shr    $0xc,%edx
f01018a1:	3b 15 88 9e 21 f0    	cmp    0xf0219e88,%edx
f01018a7:	72 12                	jb     f01018bb <mem_init+0x427>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018a9:	50                   	push   %eax
f01018aa:	68 04 6c 10 f0       	push   $0xf0106c04
f01018af:	6a 58                	push   $0x58
f01018b1:	68 fa 7a 10 f0       	push   $0xf0107afa
f01018b6:	e8 85 e7 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01018bb:	83 ec 04             	sub    $0x4,%esp
f01018be:	68 00 10 00 00       	push   $0x1000
f01018c3:	6a 01                	push   $0x1
f01018c5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01018ca:	50                   	push   %eax
f01018cb:	e8 48 46 00 00       	call   f0105f18 <memset>
	page_free(pp0);
f01018d0:	89 34 24             	mov    %esi,(%esp)
f01018d3:	e8 54 f7 ff ff       	call   f010102c <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01018d8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01018df:	e8 d8 f6 ff ff       	call   f0100fbc <page_alloc>
f01018e4:	83 c4 10             	add    $0x10,%esp
f01018e7:	85 c0                	test   %eax,%eax
f01018e9:	75 19                	jne    f0101904 <mem_init+0x470>
f01018eb:	68 d0 7c 10 f0       	push   $0xf0107cd0
f01018f0:	68 14 7b 10 f0       	push   $0xf0107b14
f01018f5:	68 6b 03 00 00       	push   $0x36b
f01018fa:	68 d1 7a 10 f0       	push   $0xf0107ad1
f01018ff:	e8 3c e7 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101904:	39 c6                	cmp    %eax,%esi
f0101906:	74 19                	je     f0101921 <mem_init+0x48d>
f0101908:	68 ee 7c 10 f0       	push   $0xf0107cee
f010190d:	68 14 7b 10 f0       	push   $0xf0107b14
f0101912:	68 6c 03 00 00       	push   $0x36c
f0101917:	68 d1 7a 10 f0       	push   $0xf0107ad1
f010191c:	e8 1f e7 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101921:	89 f0                	mov    %esi,%eax
f0101923:	2b 05 90 9e 21 f0    	sub    0xf0219e90,%eax
f0101929:	c1 f8 03             	sar    $0x3,%eax
f010192c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010192f:	89 c2                	mov    %eax,%edx
f0101931:	c1 ea 0c             	shr    $0xc,%edx
f0101934:	3b 15 88 9e 21 f0    	cmp    0xf0219e88,%edx
f010193a:	72 12                	jb     f010194e <mem_init+0x4ba>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010193c:	50                   	push   %eax
f010193d:	68 04 6c 10 f0       	push   $0xf0106c04
f0101942:	6a 58                	push   $0x58
f0101944:	68 fa 7a 10 f0       	push   $0xf0107afa
f0101949:	e8 f2 e6 ff ff       	call   f0100040 <_panic>
f010194e:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101954:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f010195a:	80 38 00             	cmpb   $0x0,(%eax)
f010195d:	74 19                	je     f0101978 <mem_init+0x4e4>
f010195f:	68 fe 7c 10 f0       	push   $0xf0107cfe
f0101964:	68 14 7b 10 f0       	push   $0xf0107b14
f0101969:	68 6f 03 00 00       	push   $0x36f
f010196e:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f0101982:	a3 40 92 21 f0       	mov    %eax,0xf0219240

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
f01019a3:	a1 40 92 21 f0       	mov    0xf0219240,%eax
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
f01019ba:	68 08 7d 10 f0       	push   $0xf0107d08
f01019bf:	68 14 7b 10 f0       	push   $0xf0107b14
f01019c4:	68 7c 03 00 00       	push   $0x37c
f01019c9:	68 d1 7a 10 f0       	push   $0xf0107ad1
f01019ce:	e8 6d e6 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01019d3:	83 ec 0c             	sub    $0xc,%esp
f01019d6:	68 14 73 10 f0       	push   $0xf0107314
f01019db:	e8 a8 23 00 00       	call   f0103d88 <cprintf>
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
f01019f6:	68 16 7c 10 f0       	push   $0xf0107c16
f01019fb:	68 14 7b 10 f0       	push   $0xf0107b14
f0101a00:	68 e2 03 00 00       	push   $0x3e2
f0101a05:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0101a0a:	e8 31 e6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101a0f:	83 ec 0c             	sub    $0xc,%esp
f0101a12:	6a 00                	push   $0x0
f0101a14:	e8 a3 f5 ff ff       	call   f0100fbc <page_alloc>
f0101a19:	89 c3                	mov    %eax,%ebx
f0101a1b:	83 c4 10             	add    $0x10,%esp
f0101a1e:	85 c0                	test   %eax,%eax
f0101a20:	75 19                	jne    f0101a3b <mem_init+0x5a7>
f0101a22:	68 2c 7c 10 f0       	push   $0xf0107c2c
f0101a27:	68 14 7b 10 f0       	push   $0xf0107b14
f0101a2c:	68 e3 03 00 00       	push   $0x3e3
f0101a31:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0101a36:	e8 05 e6 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a3b:	83 ec 0c             	sub    $0xc,%esp
f0101a3e:	6a 00                	push   $0x0
f0101a40:	e8 77 f5 ff ff       	call   f0100fbc <page_alloc>
f0101a45:	89 c6                	mov    %eax,%esi
f0101a47:	83 c4 10             	add    $0x10,%esp
f0101a4a:	85 c0                	test   %eax,%eax
f0101a4c:	75 19                	jne    f0101a67 <mem_init+0x5d3>
f0101a4e:	68 42 7c 10 f0       	push   $0xf0107c42
f0101a53:	68 14 7b 10 f0       	push   $0xf0107b14
f0101a58:	68 e4 03 00 00       	push   $0x3e4
f0101a5d:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0101a62:	e8 d9 e5 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a67:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101a6a:	75 19                	jne    f0101a85 <mem_init+0x5f1>
f0101a6c:	68 58 7c 10 f0       	push   $0xf0107c58
f0101a71:	68 14 7b 10 f0       	push   $0xf0107b14
f0101a76:	68 e7 03 00 00       	push   $0x3e7
f0101a7b:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0101a80:	e8 bb e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a85:	39 c3                	cmp    %eax,%ebx
f0101a87:	74 05                	je     f0101a8e <mem_init+0x5fa>
f0101a89:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101a8c:	75 19                	jne    f0101aa7 <mem_init+0x613>
f0101a8e:	68 f4 72 10 f0       	push   $0xf01072f4
f0101a93:	68 14 7b 10 f0       	push   $0xf0107b14
f0101a98:	68 e8 03 00 00       	push   $0x3e8
f0101a9d:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0101aa2:	e8 99 e5 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101aa7:	a1 40 92 21 f0       	mov    0xf0219240,%eax
f0101aac:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101aaf:	c7 05 40 92 21 f0 00 	movl   $0x0,0xf0219240
f0101ab6:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101ab9:	83 ec 0c             	sub    $0xc,%esp
f0101abc:	6a 00                	push   $0x0
f0101abe:	e8 f9 f4 ff ff       	call   f0100fbc <page_alloc>
f0101ac3:	83 c4 10             	add    $0x10,%esp
f0101ac6:	85 c0                	test   %eax,%eax
f0101ac8:	74 19                	je     f0101ae3 <mem_init+0x64f>
f0101aca:	68 c1 7c 10 f0       	push   $0xf0107cc1
f0101acf:	68 14 7b 10 f0       	push   $0xf0107b14
f0101ad4:	68 ef 03 00 00       	push   $0x3ef
f0101ad9:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0101ade:	e8 5d e5 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101ae3:	83 ec 04             	sub    $0x4,%esp
f0101ae6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101ae9:	50                   	push   %eax
f0101aea:	6a 00                	push   $0x0
f0101aec:	ff 35 8c 9e 21 f0    	pushl  0xf0219e8c
f0101af2:	e8 49 f7 ff ff       	call   f0101240 <page_lookup>
f0101af7:	83 c4 10             	add    $0x10,%esp
f0101afa:	85 c0                	test   %eax,%eax
f0101afc:	74 19                	je     f0101b17 <mem_init+0x683>
f0101afe:	68 34 73 10 f0       	push   $0xf0107334
f0101b03:	68 14 7b 10 f0       	push   $0xf0107b14
f0101b08:	68 f2 03 00 00       	push   $0x3f2
f0101b0d:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0101b12:	e8 29 e5 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101b17:	6a 02                	push   $0x2
f0101b19:	6a 00                	push   $0x0
f0101b1b:	53                   	push   %ebx
f0101b1c:	ff 35 8c 9e 21 f0    	pushl  0xf0219e8c
f0101b22:	e8 46 f8 ff ff       	call   f010136d <page_insert>
f0101b27:	83 c4 10             	add    $0x10,%esp
f0101b2a:	85 c0                	test   %eax,%eax
f0101b2c:	78 19                	js     f0101b47 <mem_init+0x6b3>
f0101b2e:	68 6c 73 10 f0       	push   $0xf010736c
f0101b33:	68 14 7b 10 f0       	push   $0xf0107b14
f0101b38:	68 f5 03 00 00       	push   $0x3f5
f0101b3d:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f0101b57:	ff 35 8c 9e 21 f0    	pushl  0xf0219e8c
f0101b5d:	e8 0b f8 ff ff       	call   f010136d <page_insert>
f0101b62:	83 c4 20             	add    $0x20,%esp
f0101b65:	85 c0                	test   %eax,%eax
f0101b67:	74 19                	je     f0101b82 <mem_init+0x6ee>
f0101b69:	68 9c 73 10 f0       	push   $0xf010739c
f0101b6e:	68 14 7b 10 f0       	push   $0xf0107b14
f0101b73:	68 fa 03 00 00       	push   $0x3fa
f0101b78:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0101b7d:	e8 be e4 ff ff       	call   f0100040 <_panic>
        assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b82:	8b 3d 8c 9e 21 f0    	mov    0xf0219e8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b88:	a1 90 9e 21 f0       	mov    0xf0219e90,%eax
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
f0101ba9:	68 cc 73 10 f0       	push   $0xf01073cc
f0101bae:	68 14 7b 10 f0       	push   $0xf0107b14
f0101bb3:	68 fb 03 00 00       	push   $0x3fb
f0101bb8:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f0101bdd:	68 f4 73 10 f0       	push   $0xf01073f4
f0101be2:	68 14 7b 10 f0       	push   $0xf0107b14
f0101be7:	68 fc 03 00 00       	push   $0x3fc
f0101bec:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0101bf1:	e8 4a e4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101bf6:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101bfb:	74 19                	je     f0101c16 <mem_init+0x782>
f0101bfd:	68 13 7d 10 f0       	push   $0xf0107d13
f0101c02:	68 14 7b 10 f0       	push   $0xf0107b14
f0101c07:	68 fd 03 00 00       	push   $0x3fd
f0101c0c:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0101c11:	e8 2a e4 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101c16:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c19:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101c1e:	74 19                	je     f0101c39 <mem_init+0x7a5>
f0101c20:	68 24 7d 10 f0       	push   $0xf0107d24
f0101c25:	68 14 7b 10 f0       	push   $0xf0107b14
f0101c2a:	68 fe 03 00 00       	push   $0x3fe
f0101c2f:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f0101c4e:	68 24 74 10 f0       	push   $0xf0107424
f0101c53:	68 14 7b 10 f0       	push   $0xf0107b14
f0101c58:	68 01 04 00 00       	push   $0x401
f0101c5d:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0101c62:	e8 d9 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c67:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c6c:	a1 8c 9e 21 f0       	mov    0xf0219e8c,%eax
f0101c71:	e8 50 ee ff ff       	call   f0100ac6 <check_va2pa>
f0101c76:	89 f2                	mov    %esi,%edx
f0101c78:	2b 15 90 9e 21 f0    	sub    0xf0219e90,%edx
f0101c7e:	c1 fa 03             	sar    $0x3,%edx
f0101c81:	c1 e2 0c             	shl    $0xc,%edx
f0101c84:	39 d0                	cmp    %edx,%eax
f0101c86:	74 19                	je     f0101ca1 <mem_init+0x80d>
f0101c88:	68 60 74 10 f0       	push   $0xf0107460
f0101c8d:	68 14 7b 10 f0       	push   $0xf0107b14
f0101c92:	68 02 04 00 00       	push   $0x402
f0101c97:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0101c9c:	e8 9f e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101ca1:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ca6:	74 19                	je     f0101cc1 <mem_init+0x82d>
f0101ca8:	68 35 7d 10 f0       	push   $0xf0107d35
f0101cad:	68 14 7b 10 f0       	push   $0xf0107b14
f0101cb2:	68 03 04 00 00       	push   $0x403
f0101cb7:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0101cbc:	e8 7f e3 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101cc1:	83 ec 0c             	sub    $0xc,%esp
f0101cc4:	6a 00                	push   $0x0
f0101cc6:	e8 f1 f2 ff ff       	call   f0100fbc <page_alloc>
f0101ccb:	83 c4 10             	add    $0x10,%esp
f0101cce:	85 c0                	test   %eax,%eax
f0101cd0:	74 19                	je     f0101ceb <mem_init+0x857>
f0101cd2:	68 c1 7c 10 f0       	push   $0xf0107cc1
f0101cd7:	68 14 7b 10 f0       	push   $0xf0107b14
f0101cdc:	68 06 04 00 00       	push   $0x406
f0101ce1:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0101ce6:	e8 55 e3 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ceb:	6a 02                	push   $0x2
f0101ced:	68 00 10 00 00       	push   $0x1000
f0101cf2:	56                   	push   %esi
f0101cf3:	ff 35 8c 9e 21 f0    	pushl  0xf0219e8c
f0101cf9:	e8 6f f6 ff ff       	call   f010136d <page_insert>
f0101cfe:	83 c4 10             	add    $0x10,%esp
f0101d01:	85 c0                	test   %eax,%eax
f0101d03:	74 19                	je     f0101d1e <mem_init+0x88a>
f0101d05:	68 24 74 10 f0       	push   $0xf0107424
f0101d0a:	68 14 7b 10 f0       	push   $0xf0107b14
f0101d0f:	68 09 04 00 00       	push   $0x409
f0101d14:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0101d19:	e8 22 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d1e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d23:	a1 8c 9e 21 f0       	mov    0xf0219e8c,%eax
f0101d28:	e8 99 ed ff ff       	call   f0100ac6 <check_va2pa>
f0101d2d:	89 f2                	mov    %esi,%edx
f0101d2f:	2b 15 90 9e 21 f0    	sub    0xf0219e90,%edx
f0101d35:	c1 fa 03             	sar    $0x3,%edx
f0101d38:	c1 e2 0c             	shl    $0xc,%edx
f0101d3b:	39 d0                	cmp    %edx,%eax
f0101d3d:	74 19                	je     f0101d58 <mem_init+0x8c4>
f0101d3f:	68 60 74 10 f0       	push   $0xf0107460
f0101d44:	68 14 7b 10 f0       	push   $0xf0107b14
f0101d49:	68 0a 04 00 00       	push   $0x40a
f0101d4e:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0101d53:	e8 e8 e2 ff ff       	call   f0100040 <_panic>
        assert(pp2->pp_ref == 1);
f0101d58:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d5d:	74 19                	je     f0101d78 <mem_init+0x8e4>
f0101d5f:	68 35 7d 10 f0       	push   $0xf0107d35
f0101d64:	68 14 7b 10 f0       	push   $0xf0107b14
f0101d69:	68 0b 04 00 00       	push   $0x40b
f0101d6e:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f0101d89:	68 c1 7c 10 f0       	push   $0xf0107cc1
f0101d8e:	68 14 7b 10 f0       	push   $0xf0107b14
f0101d93:	68 0f 04 00 00       	push   $0x40f
f0101d98:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0101d9d:	e8 9e e2 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101da2:	8b 15 8c 9e 21 f0    	mov    0xf0219e8c,%edx
f0101da8:	8b 02                	mov    (%edx),%eax
f0101daa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101daf:	89 c1                	mov    %eax,%ecx
f0101db1:	c1 e9 0c             	shr    $0xc,%ecx
f0101db4:	3b 0d 88 9e 21 f0    	cmp    0xf0219e88,%ecx
f0101dba:	72 15                	jb     f0101dd1 <mem_init+0x93d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101dbc:	50                   	push   %eax
f0101dbd:	68 04 6c 10 f0       	push   $0xf0106c04
f0101dc2:	68 12 04 00 00       	push   $0x412
f0101dc7:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f0101df6:	68 90 74 10 f0       	push   $0xf0107490
f0101dfb:	68 14 7b 10 f0       	push   $0xf0107b14
f0101e00:	68 13 04 00 00       	push   $0x413
f0101e05:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0101e0a:	e8 31 e2 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101e0f:	6a 06                	push   $0x6
f0101e11:	68 00 10 00 00       	push   $0x1000
f0101e16:	56                   	push   %esi
f0101e17:	ff 35 8c 9e 21 f0    	pushl  0xf0219e8c
f0101e1d:	e8 4b f5 ff ff       	call   f010136d <page_insert>
f0101e22:	83 c4 10             	add    $0x10,%esp
f0101e25:	85 c0                	test   %eax,%eax
f0101e27:	74 19                	je     f0101e42 <mem_init+0x9ae>
f0101e29:	68 d0 74 10 f0       	push   $0xf01074d0
f0101e2e:	68 14 7b 10 f0       	push   $0xf0107b14
f0101e33:	68 16 04 00 00       	push   $0x416
f0101e38:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0101e3d:	e8 fe e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e42:	8b 3d 8c 9e 21 f0    	mov    0xf0219e8c,%edi
f0101e48:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e4d:	89 f8                	mov    %edi,%eax
f0101e4f:	e8 72 ec ff ff       	call   f0100ac6 <check_va2pa>
f0101e54:	89 f2                	mov    %esi,%edx
f0101e56:	2b 15 90 9e 21 f0    	sub    0xf0219e90,%edx
f0101e5c:	c1 fa 03             	sar    $0x3,%edx
f0101e5f:	c1 e2 0c             	shl    $0xc,%edx
f0101e62:	39 d0                	cmp    %edx,%eax
f0101e64:	74 19                	je     f0101e7f <mem_init+0x9eb>
f0101e66:	68 60 74 10 f0       	push   $0xf0107460
f0101e6b:	68 14 7b 10 f0       	push   $0xf0107b14
f0101e70:	68 17 04 00 00       	push   $0x417
f0101e75:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0101e7a:	e8 c1 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101e7f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101e84:	74 19                	je     f0101e9f <mem_init+0xa0b>
f0101e86:	68 35 7d 10 f0       	push   $0xf0107d35
f0101e8b:	68 14 7b 10 f0       	push   $0xf0107b14
f0101e90:	68 18 04 00 00       	push   $0x418
f0101e95:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f0101eb7:	68 10 75 10 f0       	push   $0xf0107510
f0101ebc:	68 14 7b 10 f0       	push   $0xf0107b14
f0101ec1:	68 19 04 00 00       	push   $0x419
f0101ec6:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0101ecb:	e8 70 e1 ff ff       	call   f0100040 <_panic>
        assert(kern_pgdir[0] & PTE_U);
f0101ed0:	a1 8c 9e 21 f0       	mov    0xf0219e8c,%eax
f0101ed5:	f6 00 04             	testb  $0x4,(%eax)
f0101ed8:	75 19                	jne    f0101ef3 <mem_init+0xa5f>
f0101eda:	68 46 7d 10 f0       	push   $0xf0107d46
f0101edf:	68 14 7b 10 f0       	push   $0xf0107b14
f0101ee4:	68 1a 04 00 00       	push   $0x41a
f0101ee9:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f0101f08:	68 24 74 10 f0       	push   $0xf0107424
f0101f0d:	68 14 7b 10 f0       	push   $0xf0107b14
f0101f12:	68 1d 04 00 00       	push   $0x41d
f0101f17:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0101f1c:	e8 1f e1 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101f21:	83 ec 04             	sub    $0x4,%esp
f0101f24:	6a 00                	push   $0x0
f0101f26:	68 00 10 00 00       	push   $0x1000
f0101f2b:	ff 35 8c 9e 21 f0    	pushl  0xf0219e8c
f0101f31:	e8 8c f1 ff ff       	call   f01010c2 <pgdir_walk>
f0101f36:	83 c4 10             	add    $0x10,%esp
f0101f39:	f6 00 02             	testb  $0x2,(%eax)
f0101f3c:	75 19                	jne    f0101f57 <mem_init+0xac3>
f0101f3e:	68 44 75 10 f0       	push   $0xf0107544
f0101f43:	68 14 7b 10 f0       	push   $0xf0107b14
f0101f48:	68 1e 04 00 00       	push   $0x41e
f0101f4d:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0101f52:	e8 e9 e0 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f57:	83 ec 04             	sub    $0x4,%esp
f0101f5a:	6a 00                	push   $0x0
f0101f5c:	68 00 10 00 00       	push   $0x1000
f0101f61:	ff 35 8c 9e 21 f0    	pushl  0xf0219e8c
f0101f67:	e8 56 f1 ff ff       	call   f01010c2 <pgdir_walk>
f0101f6c:	83 c4 10             	add    $0x10,%esp
f0101f6f:	f6 00 04             	testb  $0x4,(%eax)
f0101f72:	74 19                	je     f0101f8d <mem_init+0xaf9>
f0101f74:	68 78 75 10 f0       	push   $0xf0107578
f0101f79:	68 14 7b 10 f0       	push   $0xf0107b14
f0101f7e:	68 1f 04 00 00       	push   $0x41f
f0101f83:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0101f88:	e8 b3 e0 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101f8d:	6a 02                	push   $0x2
f0101f8f:	68 00 00 40 00       	push   $0x400000
f0101f94:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101f97:	ff 35 8c 9e 21 f0    	pushl  0xf0219e8c
f0101f9d:	e8 cb f3 ff ff       	call   f010136d <page_insert>
f0101fa2:	83 c4 10             	add    $0x10,%esp
f0101fa5:	85 c0                	test   %eax,%eax
f0101fa7:	78 19                	js     f0101fc2 <mem_init+0xb2e>
f0101fa9:	68 b0 75 10 f0       	push   $0xf01075b0
f0101fae:	68 14 7b 10 f0       	push   $0xf0107b14
f0101fb3:	68 22 04 00 00       	push   $0x422
f0101fb8:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0101fbd:	e8 7e e0 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101fc2:	6a 02                	push   $0x2
f0101fc4:	68 00 10 00 00       	push   $0x1000
f0101fc9:	53                   	push   %ebx
f0101fca:	ff 35 8c 9e 21 f0    	pushl  0xf0219e8c
f0101fd0:	e8 98 f3 ff ff       	call   f010136d <page_insert>
f0101fd5:	83 c4 10             	add    $0x10,%esp
f0101fd8:	85 c0                	test   %eax,%eax
f0101fda:	74 19                	je     f0101ff5 <mem_init+0xb61>
f0101fdc:	68 e8 75 10 f0       	push   $0xf01075e8
f0101fe1:	68 14 7b 10 f0       	push   $0xf0107b14
f0101fe6:	68 25 04 00 00       	push   $0x425
f0101feb:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0101ff0:	e8 4b e0 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101ff5:	83 ec 04             	sub    $0x4,%esp
f0101ff8:	6a 00                	push   $0x0
f0101ffa:	68 00 10 00 00       	push   $0x1000
f0101fff:	ff 35 8c 9e 21 f0    	pushl  0xf0219e8c
f0102005:	e8 b8 f0 ff ff       	call   f01010c2 <pgdir_walk>
f010200a:	83 c4 10             	add    $0x10,%esp
f010200d:	f6 00 04             	testb  $0x4,(%eax)
f0102010:	74 19                	je     f010202b <mem_init+0xb97>
f0102012:	68 78 75 10 f0       	push   $0xf0107578
f0102017:	68 14 7b 10 f0       	push   $0xf0107b14
f010201c:	68 26 04 00 00       	push   $0x426
f0102021:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0102026:	e8 15 e0 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010202b:	8b 3d 8c 9e 21 f0    	mov    0xf0219e8c,%edi
f0102031:	ba 00 00 00 00       	mov    $0x0,%edx
f0102036:	89 f8                	mov    %edi,%eax
f0102038:	e8 89 ea ff ff       	call   f0100ac6 <check_va2pa>
f010203d:	89 c1                	mov    %eax,%ecx
f010203f:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102042:	89 d8                	mov    %ebx,%eax
f0102044:	2b 05 90 9e 21 f0    	sub    0xf0219e90,%eax
f010204a:	c1 f8 03             	sar    $0x3,%eax
f010204d:	c1 e0 0c             	shl    $0xc,%eax
f0102050:	39 c1                	cmp    %eax,%ecx
f0102052:	74 19                	je     f010206d <mem_init+0xbd9>
f0102054:	68 24 76 10 f0       	push   $0xf0107624
f0102059:	68 14 7b 10 f0       	push   $0xf0107b14
f010205e:	68 29 04 00 00       	push   $0x429
f0102063:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0102068:	e8 d3 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010206d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102072:	89 f8                	mov    %edi,%eax
f0102074:	e8 4d ea ff ff       	call   f0100ac6 <check_va2pa>
f0102079:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f010207c:	74 19                	je     f0102097 <mem_init+0xc03>
f010207e:	68 50 76 10 f0       	push   $0xf0107650
f0102083:	68 14 7b 10 f0       	push   $0xf0107b14
f0102088:	68 2a 04 00 00       	push   $0x42a
f010208d:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0102092:	e8 a9 df ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102097:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f010209c:	74 19                	je     f01020b7 <mem_init+0xc23>
f010209e:	68 5c 7d 10 f0       	push   $0xf0107d5c
f01020a3:	68 14 7b 10 f0       	push   $0xf0107b14
f01020a8:	68 2c 04 00 00       	push   $0x42c
f01020ad:	68 d1 7a 10 f0       	push   $0xf0107ad1
f01020b2:	e8 89 df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01020b7:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01020bc:	74 19                	je     f01020d7 <mem_init+0xc43>
f01020be:	68 6d 7d 10 f0       	push   $0xf0107d6d
f01020c3:	68 14 7b 10 f0       	push   $0xf0107b14
f01020c8:	68 2d 04 00 00       	push   $0x42d
f01020cd:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f01020ec:	68 80 76 10 f0       	push   $0xf0107680
f01020f1:	68 14 7b 10 f0       	push   $0xf0107b14
f01020f6:	68 30 04 00 00       	push   $0x430
f01020fb:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0102100:	e8 3b df ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102105:	83 ec 08             	sub    $0x8,%esp
f0102108:	6a 00                	push   $0x0
f010210a:	ff 35 8c 9e 21 f0    	pushl  0xf0219e8c
f0102110:	e8 ea f1 ff ff       	call   f01012ff <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102115:	8b 3d 8c 9e 21 f0    	mov    0xf0219e8c,%edi
f010211b:	ba 00 00 00 00       	mov    $0x0,%edx
f0102120:	89 f8                	mov    %edi,%eax
f0102122:	e8 9f e9 ff ff       	call   f0100ac6 <check_va2pa>
f0102127:	83 c4 10             	add    $0x10,%esp
f010212a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010212d:	74 19                	je     f0102148 <mem_init+0xcb4>
f010212f:	68 a4 76 10 f0       	push   $0xf01076a4
f0102134:	68 14 7b 10 f0       	push   $0xf0107b14
f0102139:	68 34 04 00 00       	push   $0x434
f010213e:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0102143:	e8 f8 de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102148:	ba 00 10 00 00       	mov    $0x1000,%edx
f010214d:	89 f8                	mov    %edi,%eax
f010214f:	e8 72 e9 ff ff       	call   f0100ac6 <check_va2pa>
f0102154:	89 da                	mov    %ebx,%edx
f0102156:	2b 15 90 9e 21 f0    	sub    0xf0219e90,%edx
f010215c:	c1 fa 03             	sar    $0x3,%edx
f010215f:	c1 e2 0c             	shl    $0xc,%edx
f0102162:	39 d0                	cmp    %edx,%eax
f0102164:	74 19                	je     f010217f <mem_init+0xceb>
f0102166:	68 50 76 10 f0       	push   $0xf0107650
f010216b:	68 14 7b 10 f0       	push   $0xf0107b14
f0102170:	68 35 04 00 00       	push   $0x435
f0102175:	68 d1 7a 10 f0       	push   $0xf0107ad1
f010217a:	e8 c1 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010217f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102184:	74 19                	je     f010219f <mem_init+0xd0b>
f0102186:	68 13 7d 10 f0       	push   $0xf0107d13
f010218b:	68 14 7b 10 f0       	push   $0xf0107b14
f0102190:	68 36 04 00 00       	push   $0x436
f0102195:	68 d1 7a 10 f0       	push   $0xf0107ad1
f010219a:	e8 a1 de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010219f:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01021a4:	74 19                	je     f01021bf <mem_init+0xd2b>
f01021a6:	68 6d 7d 10 f0       	push   $0xf0107d6d
f01021ab:	68 14 7b 10 f0       	push   $0xf0107b14
f01021b0:	68 37 04 00 00       	push   $0x437
f01021b5:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f01021d4:	68 c8 76 10 f0       	push   $0xf01076c8
f01021d9:	68 14 7b 10 f0       	push   $0xf0107b14
f01021de:	68 3a 04 00 00       	push   $0x43a
f01021e3:	68 d1 7a 10 f0       	push   $0xf0107ad1
f01021e8:	e8 53 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01021ed:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01021f2:	75 19                	jne    f010220d <mem_init+0xd79>
f01021f4:	68 7e 7d 10 f0       	push   $0xf0107d7e
f01021f9:	68 14 7b 10 f0       	push   $0xf0107b14
f01021fe:	68 3b 04 00 00       	push   $0x43b
f0102203:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0102208:	e8 33 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f010220d:	83 3b 00             	cmpl   $0x0,(%ebx)
f0102210:	74 19                	je     f010222b <mem_init+0xd97>
f0102212:	68 8a 7d 10 f0       	push   $0xf0107d8a
f0102217:	68 14 7b 10 f0       	push   $0xf0107b14
f010221c:	68 3c 04 00 00       	push   $0x43c
f0102221:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0102226:	e8 15 de ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010222b:	83 ec 08             	sub    $0x8,%esp
f010222e:	68 00 10 00 00       	push   $0x1000
f0102233:	ff 35 8c 9e 21 f0    	pushl  0xf0219e8c
f0102239:	e8 c1 f0 ff ff       	call   f01012ff <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010223e:	8b 3d 8c 9e 21 f0    	mov    0xf0219e8c,%edi
f0102244:	ba 00 00 00 00       	mov    $0x0,%edx
f0102249:	89 f8                	mov    %edi,%eax
f010224b:	e8 76 e8 ff ff       	call   f0100ac6 <check_va2pa>
f0102250:	83 c4 10             	add    $0x10,%esp
f0102253:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102256:	74 19                	je     f0102271 <mem_init+0xddd>
f0102258:	68 a4 76 10 f0       	push   $0xf01076a4
f010225d:	68 14 7b 10 f0       	push   $0xf0107b14
f0102262:	68 40 04 00 00       	push   $0x440
f0102267:	68 d1 7a 10 f0       	push   $0xf0107ad1
f010226c:	e8 cf dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102271:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102276:	89 f8                	mov    %edi,%eax
f0102278:	e8 49 e8 ff ff       	call   f0100ac6 <check_va2pa>
f010227d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102280:	74 19                	je     f010229b <mem_init+0xe07>
f0102282:	68 00 77 10 f0       	push   $0xf0107700
f0102287:	68 14 7b 10 f0       	push   $0xf0107b14
f010228c:	68 41 04 00 00       	push   $0x441
f0102291:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0102296:	e8 a5 dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010229b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022a0:	74 19                	je     f01022bb <mem_init+0xe27>
f01022a2:	68 9f 7d 10 f0       	push   $0xf0107d9f
f01022a7:	68 14 7b 10 f0       	push   $0xf0107b14
f01022ac:	68 42 04 00 00       	push   $0x442
f01022b1:	68 d1 7a 10 f0       	push   $0xf0107ad1
f01022b6:	e8 85 dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01022bb:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01022c0:	74 19                	je     f01022db <mem_init+0xe47>
f01022c2:	68 6d 7d 10 f0       	push   $0xf0107d6d
f01022c7:	68 14 7b 10 f0       	push   $0xf0107b14
f01022cc:	68 43 04 00 00       	push   $0x443
f01022d1:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f01022f0:	68 28 77 10 f0       	push   $0xf0107728
f01022f5:	68 14 7b 10 f0       	push   $0xf0107b14
f01022fa:	68 46 04 00 00       	push   $0x446
f01022ff:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0102304:	e8 37 dd ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102309:	83 ec 0c             	sub    $0xc,%esp
f010230c:	6a 00                	push   $0x0
f010230e:	e8 a9 ec ff ff       	call   f0100fbc <page_alloc>
f0102313:	83 c4 10             	add    $0x10,%esp
f0102316:	85 c0                	test   %eax,%eax
f0102318:	74 19                	je     f0102333 <mem_init+0xe9f>
f010231a:	68 c1 7c 10 f0       	push   $0xf0107cc1
f010231f:	68 14 7b 10 f0       	push   $0xf0107b14
f0102324:	68 49 04 00 00       	push   $0x449
f0102329:	68 d1 7a 10 f0       	push   $0xf0107ad1
f010232e:	e8 0d dd ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102333:	8b 0d 8c 9e 21 f0    	mov    0xf0219e8c,%ecx
f0102339:	8b 11                	mov    (%ecx),%edx
f010233b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102341:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102344:	2b 05 90 9e 21 f0    	sub    0xf0219e90,%eax
f010234a:	c1 f8 03             	sar    $0x3,%eax
f010234d:	c1 e0 0c             	shl    $0xc,%eax
f0102350:	39 c2                	cmp    %eax,%edx
f0102352:	74 19                	je     f010236d <mem_init+0xed9>
f0102354:	68 cc 73 10 f0       	push   $0xf01073cc
f0102359:	68 14 7b 10 f0       	push   $0xf0107b14
f010235e:	68 4c 04 00 00       	push   $0x44c
f0102363:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0102368:	e8 d3 dc ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f010236d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102373:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102376:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010237b:	74 19                	je     f0102396 <mem_init+0xf02>
f010237d:	68 24 7d 10 f0       	push   $0xf0107d24
f0102382:	68 14 7b 10 f0       	push   $0xf0107b14
f0102387:	68 4e 04 00 00       	push   $0x44e
f010238c:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f01023b2:	ff 35 8c 9e 21 f0    	pushl  0xf0219e8c
f01023b8:	e8 05 ed ff ff       	call   f01010c2 <pgdir_walk>
f01023bd:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01023c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01023c3:	8b 0d 8c 9e 21 f0    	mov    0xf0219e8c,%ecx
f01023c9:	8b 51 04             	mov    0x4(%ecx),%edx
f01023cc:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01023d2:	8b 3d 88 9e 21 f0    	mov    0xf0219e88,%edi
f01023d8:	89 d0                	mov    %edx,%eax
f01023da:	c1 e8 0c             	shr    $0xc,%eax
f01023dd:	83 c4 10             	add    $0x10,%esp
f01023e0:	39 f8                	cmp    %edi,%eax
f01023e2:	72 15                	jb     f01023f9 <mem_init+0xf65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023e4:	52                   	push   %edx
f01023e5:	68 04 6c 10 f0       	push   $0xf0106c04
f01023ea:	68 55 04 00 00       	push   $0x455
f01023ef:	68 d1 7a 10 f0       	push   $0xf0107ad1
f01023f4:	e8 47 dc ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01023f9:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01023ff:	39 55 c8             	cmp    %edx,-0x38(%ebp)
f0102402:	74 19                	je     f010241d <mem_init+0xf89>
f0102404:	68 b0 7d 10 f0       	push   $0xf0107db0
f0102409:	68 14 7b 10 f0       	push   $0xf0107b14
f010240e:	68 56 04 00 00       	push   $0x456
f0102413:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f010242d:	2b 05 90 9e 21 f0    	sub    0xf0219e90,%eax
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
f0102443:	68 04 6c 10 f0       	push   $0xf0106c04
f0102448:	6a 58                	push   $0x58
f010244a:	68 fa 7a 10 f0       	push   $0xf0107afa
f010244f:	e8 ec db ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102454:	83 ec 04             	sub    $0x4,%esp
f0102457:	68 00 10 00 00       	push   $0x1000
f010245c:	68 ff 00 00 00       	push   $0xff
f0102461:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102466:	50                   	push   %eax
f0102467:	e8 ac 3a 00 00       	call   f0105f18 <memset>
	page_free(pp0);
f010246c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010246f:	89 3c 24             	mov    %edi,(%esp)
f0102472:	e8 b5 eb ff ff       	call   f010102c <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102477:	83 c4 0c             	add    $0xc,%esp
f010247a:	6a 01                	push   $0x1
f010247c:	6a 00                	push   $0x0
f010247e:	ff 35 8c 9e 21 f0    	pushl  0xf0219e8c
f0102484:	e8 39 ec ff ff       	call   f01010c2 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102489:	89 fa                	mov    %edi,%edx
f010248b:	2b 15 90 9e 21 f0    	sub    0xf0219e90,%edx
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
f010249f:	3b 05 88 9e 21 f0    	cmp    0xf0219e88,%eax
f01024a5:	72 12                	jb     f01024b9 <mem_init+0x1025>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024a7:	52                   	push   %edx
f01024a8:	68 04 6c 10 f0       	push   $0xf0106c04
f01024ad:	6a 58                	push   $0x58
f01024af:	68 fa 7a 10 f0       	push   $0xf0107afa
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
f01024cd:	68 c8 7d 10 f0       	push   $0xf0107dc8
f01024d2:	68 14 7b 10 f0       	push   $0xf0107b14
f01024d7:	68 60 04 00 00       	push   $0x460
f01024dc:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f01024ed:	a1 8c 9e 21 f0       	mov    0xf0219e8c,%eax
f01024f2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01024f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024fb:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102501:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102504:	89 0d 40 92 21 f0    	mov    %ecx,0xf0219240

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
f010255d:	68 4c 77 10 f0       	push   $0xf010774c
f0102562:	68 14 7b 10 f0       	push   $0xf0107b14
f0102567:	68 70 04 00 00       	push   $0x470
f010256c:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0102571:	e8 ca da ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102576:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f010257c:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102582:	77 08                	ja     f010258c <mem_init+0x10f8>
f0102584:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010258a:	77 19                	ja     f01025a5 <mem_init+0x1111>
f010258c:	68 74 77 10 f0       	push   $0xf0107774
f0102591:	68 14 7b 10 f0       	push   $0xf0107b14
f0102596:	68 71 04 00 00       	push   $0x471
f010259b:	68 d1 7a 10 f0       	push   $0xf0107ad1
f01025a0:	e8 9b da ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01025a5:	89 da                	mov    %ebx,%edx
f01025a7:	09 f2                	or     %esi,%edx
f01025a9:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01025af:	74 19                	je     f01025ca <mem_init+0x1136>
f01025b1:	68 9c 77 10 f0       	push   $0xf010779c
f01025b6:	68 14 7b 10 f0       	push   $0xf0107b14
f01025bb:	68 73 04 00 00       	push   $0x473
f01025c0:	68 d1 7a 10 f0       	push   $0xf0107ad1
f01025c5:	e8 76 da ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f01025ca:	39 c6                	cmp    %eax,%esi
f01025cc:	73 19                	jae    f01025e7 <mem_init+0x1153>
f01025ce:	68 df 7d 10 f0       	push   $0xf0107ddf
f01025d3:	68 14 7b 10 f0       	push   $0xf0107b14
f01025d8:	68 75 04 00 00       	push   $0x475
f01025dd:	68 d1 7a 10 f0       	push   $0xf0107ad1
f01025e2:	e8 59 da ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01025e7:	8b 3d 8c 9e 21 f0    	mov    0xf0219e8c,%edi
f01025ed:	89 da                	mov    %ebx,%edx
f01025ef:	89 f8                	mov    %edi,%eax
f01025f1:	e8 d0 e4 ff ff       	call   f0100ac6 <check_va2pa>
f01025f6:	85 c0                	test   %eax,%eax
f01025f8:	74 19                	je     f0102613 <mem_init+0x117f>
f01025fa:	68 c4 77 10 f0       	push   $0xf01077c4
f01025ff:	68 14 7b 10 f0       	push   $0xf0107b14
f0102604:	68 77 04 00 00       	push   $0x477
f0102609:	68 d1 7a 10 f0       	push   $0xf0107ad1
f010260e:	e8 2d da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102613:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102619:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010261c:	89 c2                	mov    %eax,%edx
f010261e:	89 f8                	mov    %edi,%eax
f0102620:	e8 a1 e4 ff ff       	call   f0100ac6 <check_va2pa>
f0102625:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010262a:	74 19                	je     f0102645 <mem_init+0x11b1>
f010262c:	68 e8 77 10 f0       	push   $0xf01077e8
f0102631:	68 14 7b 10 f0       	push   $0xf0107b14
f0102636:	68 78 04 00 00       	push   $0x478
f010263b:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0102640:	e8 fb d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102645:	89 f2                	mov    %esi,%edx
f0102647:	89 f8                	mov    %edi,%eax
f0102649:	e8 78 e4 ff ff       	call   f0100ac6 <check_va2pa>
f010264e:	85 c0                	test   %eax,%eax
f0102650:	74 19                	je     f010266b <mem_init+0x11d7>
f0102652:	68 18 78 10 f0       	push   $0xf0107818
f0102657:	68 14 7b 10 f0       	push   $0xf0107b14
f010265c:	68 79 04 00 00       	push   $0x479
f0102661:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0102666:	e8 d5 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f010266b:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102671:	89 f8                	mov    %edi,%eax
f0102673:	e8 4e e4 ff ff       	call   f0100ac6 <check_va2pa>
f0102678:	83 f8 ff             	cmp    $0xffffffff,%eax
f010267b:	74 19                	je     f0102696 <mem_init+0x1202>
f010267d:	68 3c 78 10 f0       	push   $0xf010783c
f0102682:	68 14 7b 10 f0       	push   $0xf0107b14
f0102687:	68 7a 04 00 00       	push   $0x47a
f010268c:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f01026aa:	68 68 78 10 f0       	push   $0xf0107868
f01026af:	68 14 7b 10 f0       	push   $0xf0107b14
f01026b4:	68 7c 04 00 00       	push   $0x47c
f01026b9:	68 d1 7a 10 f0       	push   $0xf0107ad1
f01026be:	e8 7d d9 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01026c3:	83 ec 04             	sub    $0x4,%esp
f01026c6:	6a 00                	push   $0x0
f01026c8:	53                   	push   %ebx
f01026c9:	ff 35 8c 9e 21 f0    	pushl  0xf0219e8c
f01026cf:	e8 ee e9 ff ff       	call   f01010c2 <pgdir_walk>
f01026d4:	8b 00                	mov    (%eax),%eax
f01026d6:	83 c4 10             	add    $0x10,%esp
f01026d9:	83 e0 04             	and    $0x4,%eax
f01026dc:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01026df:	74 19                	je     f01026fa <mem_init+0x1266>
f01026e1:	68 ac 78 10 f0       	push   $0xf01078ac
f01026e6:	68 14 7b 10 f0       	push   $0xf0107b14
f01026eb:	68 7d 04 00 00       	push   $0x47d
f01026f0:	68 d1 7a 10 f0       	push   $0xf0107ad1
f01026f5:	e8 46 d9 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f01026fa:	83 ec 04             	sub    $0x4,%esp
f01026fd:	6a 00                	push   $0x0
f01026ff:	53                   	push   %ebx
f0102700:	ff 35 8c 9e 21 f0    	pushl  0xf0219e8c
f0102706:	e8 b7 e9 ff ff       	call   f01010c2 <pgdir_walk>
f010270b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102711:	83 c4 0c             	add    $0xc,%esp
f0102714:	6a 00                	push   $0x0
f0102716:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102719:	ff 35 8c 9e 21 f0    	pushl  0xf0219e8c
f010271f:	e8 9e e9 ff ff       	call   f01010c2 <pgdir_walk>
f0102724:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f010272a:	83 c4 0c             	add    $0xc,%esp
f010272d:	6a 00                	push   $0x0
f010272f:	56                   	push   %esi
f0102730:	ff 35 8c 9e 21 f0    	pushl  0xf0219e8c
f0102736:	e8 87 e9 ff ff       	call   f01010c2 <pgdir_walk>
f010273b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102741:	c7 04 24 f1 7d 10 f0 	movl   $0xf0107df1,(%esp)
f0102748:	e8 3b 16 00 00       	call   f0103d88 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
        boot_map_region(kern_pgdir, UPAGES, ROUNDUP(pages_size, PGSIZE), PADDR(pages), PTE_U); 
f010274d:	a1 90 9e 21 f0       	mov    0xf0219e90,%eax
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
f010275d:	68 28 6c 10 f0       	push   $0xf0106c28
f0102762:	68 c9 00 00 00       	push   $0xc9
f0102767:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f0102792:	a1 8c 9e 21 f0       	mov    0xf0219e8c,%eax
f0102797:	e8 0e ea ff ff       	call   f01011aa <boot_map_region>
        boot_map_region(kern_pgdir, (uintptr_t) pages, ROUNDUP(pages_size, PGSIZE), PADDR(pages), PTE_W);
f010279c:	8b 15 90 9e 21 f0    	mov    0xf0219e90,%edx
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
f01027ae:	68 28 6c 10 f0       	push   $0xf0106c28
f01027b3:	68 ca 00 00 00       	push   $0xca
f01027b8:	68 d1 7a 10 f0       	push   $0xf0107ad1
f01027bd:	e8 7e d8 ff ff       	call   f0100040 <_panic>
f01027c2:	83 ec 08             	sub    $0x8,%esp
f01027c5:	6a 02                	push   $0x2
f01027c7:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
f01027cd:	50                   	push   %eax
f01027ce:	89 d9                	mov    %ebx,%ecx
f01027d0:	a1 8c 9e 21 f0       	mov    0xf0219e8c,%eax
f01027d5:	e8 d0 e9 ff ff       	call   f01011aa <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
        boot_map_region(kern_pgdir, UENVS, ROUNDUP(envs_size, PGSIZE), PADDR(envs), PTE_U);
f01027da:	a1 4c 92 21 f0       	mov    0xf021924c,%eax
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
f01027ea:	68 28 6c 10 f0       	push   $0xf0106c28
f01027ef:	68 d3 00 00 00       	push   $0xd3
f01027f4:	68 d1 7a 10 f0       	push   $0xf0107ad1
f01027f9:	e8 42 d8 ff ff       	call   f0100040 <_panic>
f01027fe:	83 ec 08             	sub    $0x8,%esp
f0102801:	6a 04                	push   $0x4
f0102803:	05 00 00 00 10       	add    $0x10000000,%eax
f0102808:	50                   	push   %eax
f0102809:	b9 00 60 03 00       	mov    $0x36000,%ecx
f010280e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102813:	a1 8c 9e 21 f0       	mov    0xf0219e8c,%eax
f0102818:	e8 8d e9 ff ff       	call   f01011aa <boot_map_region>
        boot_map_region(kern_pgdir, (uintptr_t) envs, ROUNDUP(envs_size, PGSIZE), PADDR(pages), PTE_W);
f010281d:	a1 90 9e 21 f0       	mov    0xf0219e90,%eax
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
f010282d:	68 28 6c 10 f0       	push   $0xf0106c28
f0102832:	68 d4 00 00 00       	push   $0xd4
f0102837:	68 d1 7a 10 f0       	push   $0xf0107ad1
f010283c:	e8 ff d7 ff ff       	call   f0100040 <_panic>
f0102841:	83 ec 08             	sub    $0x8,%esp
f0102844:	6a 02                	push   $0x2
f0102846:	05 00 00 00 10       	add    $0x10000000,%eax
f010284b:	50                   	push   %eax
f010284c:	b9 00 60 03 00       	mov    $0x36000,%ecx
f0102851:	8b 15 4c 92 21 f0    	mov    0xf021924c,%edx
f0102857:	a1 8c 9e 21 f0       	mov    0xf0219e8c,%eax
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
f0102871:	68 28 6c 10 f0       	push   $0xf0106c28
f0102876:	68 e1 00 00 00       	push   $0xe1
f010287b:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f0102899:	a1 8c 9e 21 f0       	mov    0xf0219e8c,%eax
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
f01028b4:	a1 8c 9e 21 f0       	mov    0xf0219e8c,%eax
f01028b9:	e8 ec e8 ff ff       	call   f01011aa <boot_map_region>
f01028be:	c7 45 c4 00 b0 21 f0 	movl   $0xf021b000,-0x3c(%ebp)
f01028c5:	83 c4 10             	add    $0x10,%esp
f01028c8:	bb 00 b0 21 f0       	mov    $0xf021b000,%ebx
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
f01028db:	68 28 6c 10 f0       	push   $0xf0106c28
f01028e0:	68 22 01 00 00       	push   $0x122
f01028e5:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f0102902:	a1 8c 9e 21 f0       	mov    0xf0219e8c,%eax
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
f010291b:	b8 00 b0 25 f0       	mov    $0xf025b000,%eax
f0102920:	39 d8                	cmp    %ebx,%eax
f0102922:	75 ae                	jne    f01028d2 <mem_init+0x143e>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102924:	8b 3d 8c 9e 21 f0    	mov    0xf0219e8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010292a:	a1 88 9e 21 f0       	mov    0xf0219e88,%eax
f010292f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102932:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102939:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010293e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102941:	8b 35 90 9e 21 f0    	mov    0xf0219e90,%esi
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
f0102968:	68 28 6c 10 f0       	push   $0xf0106c28
f010296d:	68 94 03 00 00       	push   $0x394
f0102972:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0102977:	e8 c4 d6 ff ff       	call   f0100040 <_panic>
f010297c:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f0102983:	39 c2                	cmp    %eax,%edx
f0102985:	74 19                	je     f01029a0 <mem_init+0x150c>
f0102987:	68 e0 78 10 f0       	push   $0xf01078e0
f010298c:	68 14 7b 10 f0       	push   $0xf0107b14
f0102991:	68 94 03 00 00       	push   $0x394
f0102996:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f01029ab:	8b 35 4c 92 21 f0    	mov    0xf021924c,%esi
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
f01029cc:	68 28 6c 10 f0       	push   $0xf0106c28
f01029d1:	68 99 03 00 00       	push   $0x399
f01029d6:	68 d1 7a 10 f0       	push   $0xf0107ad1
f01029db:	e8 60 d6 ff ff       	call   f0100040 <_panic>
f01029e0:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f01029e7:	39 d0                	cmp    %edx,%eax
f01029e9:	74 19                	je     f0102a04 <mem_init+0x1570>
f01029eb:	68 14 79 10 f0       	push   $0xf0107914
f01029f0:	68 14 7b 10 f0       	push   $0xf0107b14
f01029f5:	68 99 03 00 00       	push   $0x399
f01029fa:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f0102a30:	68 48 79 10 f0       	push   $0xf0107948
f0102a35:	68 14 7b 10 f0       	push   $0xf0107b14
f0102a3a:	68 9d 03 00 00       	push   $0x39d
f0102a3f:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f0102a89:	68 28 6c 10 f0       	push   $0xf0106c28
f0102a8e:	68 a5 03 00 00       	push   $0x3a5
f0102a93:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0102a98:	e8 a3 d5 ff ff       	call   f0100040 <_panic>
f0102a9d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102aa0:	8d 94 0b 00 b0 21 f0 	lea    -0xfde5000(%ebx,%ecx,1),%edx
f0102aa7:	39 d0                	cmp    %edx,%eax
f0102aa9:	74 19                	je     f0102ac4 <mem_init+0x1630>
f0102aab:	68 70 79 10 f0       	push   $0xf0107970
f0102ab0:	68 14 7b 10 f0       	push   $0xf0107b14
f0102ab5:	68 a5 03 00 00       	push   $0x3a5
f0102aba:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f0102aeb:	68 b8 79 10 f0       	push   $0xf01079b8
f0102af0:	68 14 7b 10 f0       	push   $0xf0107b14
f0102af5:	68 a7 03 00 00       	push   $0x3a7
f0102afa:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f0102b25:	b8 00 b0 25 f0       	mov    $0xf025b000,%eax
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
f0102b4a:	68 0a 7e 10 f0       	push   $0xf0107e0a
f0102b4f:	68 14 7b 10 f0       	push   $0xf0107b14
f0102b54:	68 b2 03 00 00       	push   $0x3b2
f0102b59:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f0102b72:	68 0a 7e 10 f0       	push   $0xf0107e0a
f0102b77:	68 14 7b 10 f0       	push   $0xf0107b14
f0102b7c:	68 b6 03 00 00       	push   $0x3b6
f0102b81:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0102b86:	e8 b5 d4 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102b8b:	f6 c2 02             	test   $0x2,%dl
f0102b8e:	75 38                	jne    f0102bc8 <mem_init+0x1734>
f0102b90:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0102b95:	68 14 7b 10 f0       	push   $0xf0107b14
f0102b9a:	68 b7 03 00 00       	push   $0x3b7
f0102b9f:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0102ba4:	e8 97 d4 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102ba9:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102bad:	74 19                	je     f0102bc8 <mem_init+0x1734>
f0102baf:	68 2c 7e 10 f0       	push   $0xf0107e2c
f0102bb4:	68 14 7b 10 f0       	push   $0xf0107b14
f0102bb9:	68 b9 03 00 00       	push   $0x3b9
f0102bbe:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f0102bd9:	68 dc 79 10 f0       	push   $0xf01079dc
f0102bde:	e8 a5 11 00 00       	call   f0103d88 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102be3:	a1 8c 9e 21 f0       	mov    0xf0219e8c,%eax
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
f0102bf3:	68 28 6c 10 f0       	push   $0xf0106c28
f0102bf8:	68 fa 00 00 00       	push   $0xfa
f0102bfd:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f0102c3a:	68 16 7c 10 f0       	push   $0xf0107c16
f0102c3f:	68 14 7b 10 f0       	push   $0xf0107b14
f0102c44:	68 92 04 00 00       	push   $0x492
f0102c49:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0102c4e:	e8 ed d3 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102c53:	83 ec 0c             	sub    $0xc,%esp
f0102c56:	6a 00                	push   $0x0
f0102c58:	e8 5f e3 ff ff       	call   f0100fbc <page_alloc>
f0102c5d:	89 c7                	mov    %eax,%edi
f0102c5f:	83 c4 10             	add    $0x10,%esp
f0102c62:	85 c0                	test   %eax,%eax
f0102c64:	75 19                	jne    f0102c7f <mem_init+0x17eb>
f0102c66:	68 2c 7c 10 f0       	push   $0xf0107c2c
f0102c6b:	68 14 7b 10 f0       	push   $0xf0107b14
f0102c70:	68 93 04 00 00       	push   $0x493
f0102c75:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0102c7a:	e8 c1 d3 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102c7f:	83 ec 0c             	sub    $0xc,%esp
f0102c82:	6a 00                	push   $0x0
f0102c84:	e8 33 e3 ff ff       	call   f0100fbc <page_alloc>
f0102c89:	89 c6                	mov    %eax,%esi
f0102c8b:	83 c4 10             	add    $0x10,%esp
f0102c8e:	85 c0                	test   %eax,%eax
f0102c90:	75 19                	jne    f0102cab <mem_init+0x1817>
f0102c92:	68 42 7c 10 f0       	push   $0xf0107c42
f0102c97:	68 14 7b 10 f0       	push   $0xf0107b14
f0102c9c:	68 94 04 00 00       	push   $0x494
f0102ca1:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f0102cb6:	2b 05 90 9e 21 f0    	sub    0xf0219e90,%eax
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
f0102cca:	3b 15 88 9e 21 f0    	cmp    0xf0219e88,%edx
f0102cd0:	72 12                	jb     f0102ce4 <mem_init+0x1850>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102cd2:	50                   	push   %eax
f0102cd3:	68 04 6c 10 f0       	push   $0xf0106c04
f0102cd8:	6a 58                	push   $0x58
f0102cda:	68 fa 7a 10 f0       	push   $0xf0107afa
f0102cdf:	e8 5c d3 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102ce4:	83 ec 04             	sub    $0x4,%esp
f0102ce7:	68 00 10 00 00       	push   $0x1000
f0102cec:	6a 01                	push   $0x1
f0102cee:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102cf3:	50                   	push   %eax
f0102cf4:	e8 1f 32 00 00       	call   f0105f18 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102cf9:	89 f0                	mov    %esi,%eax
f0102cfb:	2b 05 90 9e 21 f0    	sub    0xf0219e90,%eax
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
f0102d0f:	3b 15 88 9e 21 f0    	cmp    0xf0219e88,%edx
f0102d15:	72 12                	jb     f0102d29 <mem_init+0x1895>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d17:	50                   	push   %eax
f0102d18:	68 04 6c 10 f0       	push   $0xf0106c04
f0102d1d:	6a 58                	push   $0x58
f0102d1f:	68 fa 7a 10 f0       	push   $0xf0107afa
f0102d24:	e8 17 d3 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102d29:	83 ec 04             	sub    $0x4,%esp
f0102d2c:	68 00 10 00 00       	push   $0x1000
f0102d31:	6a 02                	push   $0x2
f0102d33:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102d38:	50                   	push   %eax
f0102d39:	e8 da 31 00 00       	call   f0105f18 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102d3e:	6a 02                	push   $0x2
f0102d40:	68 00 10 00 00       	push   $0x1000
f0102d45:	57                   	push   %edi
f0102d46:	ff 35 8c 9e 21 f0    	pushl  0xf0219e8c
f0102d4c:	e8 1c e6 ff ff       	call   f010136d <page_insert>
	assert(pp1->pp_ref == 1);
f0102d51:	83 c4 20             	add    $0x20,%esp
f0102d54:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102d59:	74 19                	je     f0102d74 <mem_init+0x18e0>
f0102d5b:	68 13 7d 10 f0       	push   $0xf0107d13
f0102d60:	68 14 7b 10 f0       	push   $0xf0107b14
f0102d65:	68 99 04 00 00       	push   $0x499
f0102d6a:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0102d6f:	e8 cc d2 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102d74:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102d7b:	01 01 01 
f0102d7e:	74 19                	je     f0102d99 <mem_init+0x1905>
f0102d80:	68 fc 79 10 f0       	push   $0xf01079fc
f0102d85:	68 14 7b 10 f0       	push   $0xf0107b14
f0102d8a:	68 9a 04 00 00       	push   $0x49a
f0102d8f:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0102d94:	e8 a7 d2 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102d99:	6a 02                	push   $0x2
f0102d9b:	68 00 10 00 00       	push   $0x1000
f0102da0:	56                   	push   %esi
f0102da1:	ff 35 8c 9e 21 f0    	pushl  0xf0219e8c
f0102da7:	e8 c1 e5 ff ff       	call   f010136d <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102dac:	83 c4 10             	add    $0x10,%esp
f0102daf:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102db6:	02 02 02 
f0102db9:	74 19                	je     f0102dd4 <mem_init+0x1940>
f0102dbb:	68 20 7a 10 f0       	push   $0xf0107a20
f0102dc0:	68 14 7b 10 f0       	push   $0xf0107b14
f0102dc5:	68 9c 04 00 00       	push   $0x49c
f0102dca:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0102dcf:	e8 6c d2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102dd4:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102dd9:	74 19                	je     f0102df4 <mem_init+0x1960>
f0102ddb:	68 35 7d 10 f0       	push   $0xf0107d35
f0102de0:	68 14 7b 10 f0       	push   $0xf0107b14
f0102de5:	68 9d 04 00 00       	push   $0x49d
f0102dea:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0102def:	e8 4c d2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102df4:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102df9:	74 19                	je     f0102e14 <mem_init+0x1980>
f0102dfb:	68 9f 7d 10 f0       	push   $0xf0107d9f
f0102e00:	68 14 7b 10 f0       	push   $0xf0107b14
f0102e05:	68 9e 04 00 00       	push   $0x49e
f0102e0a:	68 d1 7a 10 f0       	push   $0xf0107ad1
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
f0102e20:	2b 05 90 9e 21 f0    	sub    0xf0219e90,%eax
f0102e26:	c1 f8 03             	sar    $0x3,%eax
f0102e29:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e2c:	89 c2                	mov    %eax,%edx
f0102e2e:	c1 ea 0c             	shr    $0xc,%edx
f0102e31:	3b 15 88 9e 21 f0    	cmp    0xf0219e88,%edx
f0102e37:	72 12                	jb     f0102e4b <mem_init+0x19b7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e39:	50                   	push   %eax
f0102e3a:	68 04 6c 10 f0       	push   $0xf0106c04
f0102e3f:	6a 58                	push   $0x58
f0102e41:	68 fa 7a 10 f0       	push   $0xf0107afa
f0102e46:	e8 f5 d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e4b:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102e52:	03 03 03 
f0102e55:	74 19                	je     f0102e70 <mem_init+0x19dc>
f0102e57:	68 44 7a 10 f0       	push   $0xf0107a44
f0102e5c:	68 14 7b 10 f0       	push   $0xf0107b14
f0102e61:	68 a0 04 00 00       	push   $0x4a0
f0102e66:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0102e6b:	e8 d0 d1 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102e70:	83 ec 08             	sub    $0x8,%esp
f0102e73:	68 00 10 00 00       	push   $0x1000
f0102e78:	ff 35 8c 9e 21 f0    	pushl  0xf0219e8c
f0102e7e:	e8 7c e4 ff ff       	call   f01012ff <page_remove>
	assert(pp2->pp_ref == 0);
f0102e83:	83 c4 10             	add    $0x10,%esp
f0102e86:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102e8b:	74 19                	je     f0102ea6 <mem_init+0x1a12>
f0102e8d:	68 6d 7d 10 f0       	push   $0xf0107d6d
f0102e92:	68 14 7b 10 f0       	push   $0xf0107b14
f0102e97:	68 a2 04 00 00       	push   $0x4a2
f0102e9c:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0102ea1:	e8 9a d1 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102ea6:	8b 0d 8c 9e 21 f0    	mov    0xf0219e8c,%ecx
f0102eac:	8b 11                	mov    (%ecx),%edx
f0102eae:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102eb4:	89 d8                	mov    %ebx,%eax
f0102eb6:	2b 05 90 9e 21 f0    	sub    0xf0219e90,%eax
f0102ebc:	c1 f8 03             	sar    $0x3,%eax
f0102ebf:	c1 e0 0c             	shl    $0xc,%eax
f0102ec2:	39 c2                	cmp    %eax,%edx
f0102ec4:	74 19                	je     f0102edf <mem_init+0x1a4b>
f0102ec6:	68 cc 73 10 f0       	push   $0xf01073cc
f0102ecb:	68 14 7b 10 f0       	push   $0xf0107b14
f0102ed0:	68 a5 04 00 00       	push   $0x4a5
f0102ed5:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0102eda:	e8 61 d1 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102edf:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102ee5:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102eea:	74 19                	je     f0102f05 <mem_init+0x1a71>
f0102eec:	68 24 7d 10 f0       	push   $0xf0107d24
f0102ef1:	68 14 7b 10 f0       	push   $0xf0107b14
f0102ef6:	68 a7 04 00 00       	push   $0x4a7
f0102efb:	68 d1 7a 10 f0       	push   $0xf0107ad1
f0102f00:	e8 3b d1 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102f05:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102f0b:	83 ec 0c             	sub    $0xc,%esp
f0102f0e:	53                   	push   %ebx
f0102f0f:	e8 18 e1 ff ff       	call   f010102c <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102f14:	c7 04 24 70 7a 10 f0 	movl   $0xf0107a70,(%esp)
f0102f1b:	e8 68 0e 00 00       	call   f0103d88 <cprintf>
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
f0102fa2:	89 1d 3c 92 21 f0    	mov    %ebx,0xf021923c
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
f0102fdc:	ff 35 3c 92 21 f0    	pushl  0xf021923c
f0102fe2:	ff b3 a4 00 00 00    	pushl  0xa4(%ebx)
f0102fe8:	68 9c 7a 10 f0       	push   $0xf0107a9c
f0102fed:	e8 96 0d 00 00       	call   f0103d88 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102ff2:	89 1c 24             	mov    %ebx,(%esp)
f0102ff5:	e8 ad 07 00 00       	call   f01037a7 <env_destroy>
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
f0103038:	68 3c 7e 10 f0       	push   $0xf0107e3c
f010303d:	68 61 01 00 00       	push   $0x161
f0103042:	68 e9 7f 10 f0       	push   $0xf0107fe9
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
f0103065:	68 64 7e 10 f0       	push   $0xf0107e64
f010306a:	68 64 01 00 00       	push   $0x164
f010306f:	68 e9 7f 10 f0       	push   $0xf0107fe9
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
f0103094:	a1 48 92 21 f0       	mov    0xf0219248,%eax
f0103099:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010309c:	8b 15 50 92 21 f0    	mov    0xf0219250,%edx
f01030a2:	89 50 08             	mov    %edx,0x8(%eax)
        free_stacks_stack = &thread_free_stacks[id];
f01030a5:	a3 50 92 21 f0       	mov    %eax,0xf0219250
}
f01030aa:	5d                   	pop    %ebp
f01030ab:	c3                   	ret    

f01030ac <stack_pop>:

struct FreeStacks* stack_pop()
{
f01030ac:	55                   	push   %ebp
f01030ad:	89 e5                	mov    %esp,%ebp
	struct FreeStacks* ret = free_stacks_stack;
f01030af:	a1 50 92 21 f0       	mov    0xf0219250,%eax
	free_stacks_stack = free_stacks_stack->next_stack;
f01030b4:	8b 50 08             	mov    0x8(%eax),%edx
f01030b7:	89 15 50 92 21 f0    	mov    %edx,0xf0219250
	
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
f01030ce:	e8 67 34 00 00       	call   f010653a <cpunum>
f01030d3:	6b c0 74             	imul   $0x74,%eax,%eax
f01030d6:	8b 80 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%eax
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
f01030f6:	03 1d 4c 92 21 f0    	add    0xf021924c,%ebx
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
f0103121:	e8 14 34 00 00       	call   f010653a <cpunum>
f0103126:	6b c0 74             	imul   $0x74,%eax,%eax
f0103129:	3b 98 28 a0 21 f0    	cmp    -0xfde5fd8(%eax),%ebx
f010312f:	74 2c                	je     f010315d <envid2env+0x9e>
f0103131:	8b b3 a8 00 00 00    	mov    0xa8(%ebx),%esi
f0103137:	e8 fe 33 00 00       	call   f010653a <cpunum>
f010313c:	6b c0 74             	imul   $0x74,%eax,%eax
f010313f:	8b 80 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%eax
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
f01031a0:	8b 35 4c 92 21 f0    	mov    0xf021924c,%esi
f01031a6:	8b 15 54 92 21 f0    	mov    0xf0219254,%edx
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
f01031df:	89 35 54 92 21 f0    	mov    %esi,0xf0219254
f01031e5:	8b 1d 50 92 21 f0    	mov    0xf0219250,%ebx
f01031eb:	b9 00 d0 bf ee       	mov    $0xeebfd000,%ecx
f01031f0:	b8 fe 03 00 00       	mov    $0x3fe,%eax
f01031f5:	8d 14 40             	lea    (%eax,%eax,2),%edx
	uintptr_t THRDSTACKTOP = ustacktop - THRDSTKGAP;
	uintptr_t STACKADDR = THRDSTACKTOP;

	for (i = MAX_THREADS - 1; i >= 0 ; i--, STACKADDR -= (THRDSTKSIZE + THRDSTKGAP))
	{	
		thread_free_stacks[i].id = i;
f01031f8:	8b 35 48 92 21 f0    	mov    0xf0219248,%esi
f01031fe:	89 04 96             	mov    %eax,(%esi,%edx,4)
		thread_free_stacks[i].addr = STACKADDR;
f0103201:	8b 35 48 92 21 f0    	mov    0xf0219248,%esi
f0103207:	8d 14 96             	lea    (%esi,%edx,4),%edx
f010320a:	89 4a 04             	mov    %ecx,0x4(%edx)
		thread_free_stacks[i].next_stack = free_stacks_stack;
f010320d:	89 5a 08             	mov    %ebx,0x8(%edx)
	/*Lab 7: multithreading*/
	uintptr_t ustacktop = 0xeebfe000;
	uintptr_t THRDSTACKTOP = ustacktop - THRDSTKGAP;
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
	uintptr_t THRDSTACKTOP = ustacktop - THRDSTKGAP;
	uintptr_t STACKADDR = THRDSTACKTOP;

	for (i = MAX_THREADS - 1; i >= 0 ; i--, STACKADDR -= (THRDSTKSIZE + THRDSTKGAP))
f010321b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010321e:	75 d5                	jne    f01031f5 <env_init+0x5a>
f0103220:	89 15 50 92 21 f0    	mov    %edx,0xf0219250
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
f0103234:	8b 1d 54 92 21 f0    	mov    0xf0219254,%ebx
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
f0103259:	2b 15 90 9e 21 f0    	sub    0xf0219e90,%edx
f010325f:	c1 fa 03             	sar    $0x3,%edx
f0103262:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103265:	89 d1                	mov    %edx,%ecx
f0103267:	c1 e9 0c             	shr    $0xc,%ecx
f010326a:	3b 0d 88 9e 21 f0    	cmp    0xf0219e88,%ecx
f0103270:	72 12                	jb     f0103284 <env_alloc+0x55>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103272:	52                   	push   %edx
f0103273:	68 04 6c 10 f0       	push   $0xf0106c04
f0103278:	6a 58                	push   $0x58
f010327a:	68 fa 7a 10 f0       	push   $0xf0107afa
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
f01032b1:	8b 15 8c 9e 21 f0    	mov    0xf0219e8c,%edx
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
f01032db:	68 28 6c 10 f0       	push   $0xf0106c28
f01032e0:	68 ef 00 00 00       	push   $0xef
f01032e5:	68 e9 7f 10 f0       	push   $0xf0107fe9
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
f0103318:	2b 15 4c 92 21 f0    	sub    0xf021924c,%edx
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
f0103361:	e8 b2 2b 00 00       	call   f0105f18 <memset>
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
f01033af:	a3 54 92 21 f0       	mov    %eax,0xf0219254
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
	// nastavme proces id ako env id, ak sa alokuje thread, prestavi si process id sam
	// zoznam workerov nastavime ako prazdny
	e->env_process_id = e->env_id;
	e->env_waiting = false;
	int i;
	for(i = 0; i < MAX_PROCESS_THREADS; i++)
f01033de:	39 c3                	cmp    %eax,%ebx
f01033e0:	75 ec                	jne    f01033ce <env_alloc+0x19f>
		e->worker_threads[1][i] = 0;		
	}
	


	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01033e2:	e8 53 31 00 00       	call   f010653a <cpunum>
f01033e7:	6b c0 74             	imul   $0x74,%eax,%eax
f01033ea:	ba 00 00 00 00       	mov    $0x0,%edx
f01033ef:	83 b8 28 a0 21 f0 00 	cmpl   $0x0,-0xfde5fd8(%eax)
f01033f6:	74 14                	je     f010340c <env_alloc+0x1dd>
f01033f8:	e8 3d 31 00 00       	call   f010653a <cpunum>
f01033fd:	6b c0 74             	imul   $0x74,%eax,%eax
f0103400:	8b 80 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%eax
f0103406:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
f010340c:	83 ec 04             	sub    $0x4,%esp
f010340f:	56                   	push   %esi
f0103410:	52                   	push   %edx
f0103411:	68 f4 7f 10 f0       	push   $0xf0107ff4
f0103416:	e8 6d 09 00 00       	call   f0103d88 <cprintf>
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
f010345a:	68 09 80 10 f0       	push   $0xf0108009
f010345f:	68 ce 01 00 00       	push   $0x1ce
f0103464:	68 e9 7f 10 f0       	push   $0xf0107fe9
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
f0103497:	68 8c 7e 10 f0       	push   $0xf0107e8c
f010349c:	68 a3 01 00 00       	push   $0x1a3
f01034a1:	68 e9 7f 10 f0       	push   $0xf0107fe9
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
f01034c1:	68 28 6c 10 f0       	push   $0xf0106c28
f01034c6:	68 a9 01 00 00       	push   $0x1a9
f01034cb:	68 e9 7f 10 f0       	push   $0xf0107fe9
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
f01034f1:	68 bc 7e 10 f0       	push   $0xf0107ebc
f01034f6:	68 b1 01 00 00       	push   $0x1b1
f01034fb:	68 e9 7f 10 f0       	push   $0xf0107fe9
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
f010351f:	e8 a9 2a 00 00       	call   f0105fcd <memcpy>
                memset((void *) (phdr->p_va + phdr->p_filesz), 0, phdr->p_memsz - phdr->p_filesz);
f0103524:	8b 43 10             	mov    0x10(%ebx),%eax
f0103527:	83 c4 0c             	add    $0xc,%esp
f010352a:	8b 53 14             	mov    0x14(%ebx),%edx
f010352d:	29 c2                	sub    %eax,%edx
f010352f:	52                   	push   %edx
f0103530:	6a 00                	push   $0x0
f0103532:	03 43 08             	add    0x8(%ebx),%eax
f0103535:	50                   	push   %eax
f0103536:	e8 dd 29 00 00       	call   f0105f18 <memset>
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
f010357f:	e8 b6 2f 00 00       	call   f010653a <cpunum>
f0103584:	6b c0 74             	imul   $0x74,%eax,%eax
f0103587:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010358e:	39 b8 28 a0 21 f0    	cmp    %edi,-0xfde5fd8(%eax)
f0103594:	75 30                	jne    f01035c6 <env_free+0x53>
		lcr3(PADDR(kern_pgdir));
f0103596:	a1 8c 9e 21 f0       	mov    0xf0219e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010359b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01035a0:	77 15                	ja     f01035b7 <env_free+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01035a2:	50                   	push   %eax
f01035a3:	68 28 6c 10 f0       	push   $0xf0106c28
f01035a8:	68 e8 01 00 00       	push   $0x1e8
f01035ad:	68 e9 7f 10 f0       	push   $0xf0107fe9
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
f01035f4:	39 05 88 9e 21 f0    	cmp    %eax,0xf0219e88
f01035fa:	77 15                	ja     f0103611 <env_free+0x9e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01035fc:	56                   	push   %esi
f01035fd:	68 04 6c 10 f0       	push   $0xf0106c04
f0103602:	68 f7 01 00 00       	push   $0x1f7
f0103607:	68 e9 7f 10 f0       	push   $0xf0107fe9
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
f0103661:	3b 05 88 9e 21 f0    	cmp    0xf0219e88,%eax
f0103667:	72 14                	jb     f010367d <env_free+0x10a>
		panic("pa2page called with invalid pa");
f0103669:	83 ec 04             	sub    $0x4,%esp
f010366c:	68 70 72 10 f0       	push   $0xf0107270
f0103671:	6a 51                	push   $0x51
f0103673:	68 fa 7a 10 f0       	push   $0xf0107afa
f0103678:	e8 c3 c9 ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f010367d:	83 ec 0c             	sub    $0xc,%esp
f0103680:	a1 90 9e 21 f0       	mov    0xf0219e90,%eax
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
f01036b4:	68 28 6c 10 f0       	push   $0xf0106c28
f01036b9:	68 05 02 00 00       	push   $0x205
f01036be:	68 e9 7f 10 f0       	push   $0xf0107fe9
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
f01036da:	3b 05 88 9e 21 f0    	cmp    0xf0219e88,%eax
f01036e0:	72 14                	jb     f01036f6 <env_free+0x183>
		panic("pa2page called with invalid pa");
f01036e2:	83 ec 04             	sub    $0x4,%esp
f01036e5:	68 70 72 10 f0       	push   $0xf0107270
f01036ea:	6a 51                	push   $0x51
f01036ec:	68 fa 7a 10 f0       	push   $0xf0107afa
f01036f1:	e8 4a c9 ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f01036f6:	83 ec 0c             	sub    $0xc,%esp
f01036f9:	8b 15 90 9e 21 f0    	mov    0xf0219e90,%edx
f01036ff:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103702:	50                   	push   %eax
f0103703:	e8 93 d9 ff ff       	call   f010109b <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103708:	c7 87 b0 00 00 00 00 	movl   $0x0,0xb0(%edi)
f010370f:	00 00 00 
	e->env_link = env_free_list;
f0103712:	a1 54 92 21 f0       	mov    0xf0219254,%eax
f0103717:	89 87 a0 00 00 00    	mov    %eax,0xa0(%edi)
	env_free_list = e;
f010371d:	89 3d 54 92 21 f0    	mov    %edi,0xf0219254
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
f0103731:	53                   	push   %ebx
f0103732:	83 ec 0c             	sub    $0xc,%esp
f0103735:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("In thread destroy, thread: %d\n", e->env_id); 
f0103738:	ff b3 a4 00 00 00    	pushl  0xa4(%ebx)
f010373e:	68 e0 7e 10 f0       	push   $0xf0107ee0
f0103743:	e8 40 06 00 00       	call   f0103d88 <cprintf>
	// hod jej esp adresu na zoznam volnych stackov pre thready
	stack_push(e->env_stack_id);
f0103748:	83 c4 04             	add    $0x4,%esp
f010374b:	ff 73 04             	pushl  0x4(%ebx)
f010374e:	e8 38 f9 ff ff       	call   f010308b <stack_push>
	
	e->env_pgdir = 0;
f0103753:	c7 83 bc 00 00 00 00 	movl   $0x0,0xbc(%ebx)
f010375a:	00 00 00 
	e->env_status = ENV_FREE;
f010375d:	c7 83 b0 00 00 00 00 	movl   $0x0,0xb0(%ebx)
f0103764:	00 00 00 
	e->env_link = env_free_list;
f0103767:	a1 54 92 21 f0       	mov    0xf0219254,%eax
f010376c:	89 83 a0 00 00 00    	mov    %eax,0xa0(%ebx)
	env_free_list = e;
f0103772:	89 1d 54 92 21 f0    	mov    %ebx,0xf0219254

	if (curenv == e) {
f0103778:	e8 bd 2d 00 00       	call   f010653a <cpunum>
f010377d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103780:	83 c4 10             	add    $0x10,%esp
f0103783:	3b 98 28 a0 21 f0    	cmp    -0xfde5fd8(%eax),%ebx
f0103789:	75 17                	jne    f01037a2 <thread_destroy+0x74>
		curenv = NULL;
f010378b:	e8 aa 2d 00 00       	call   f010653a <cpunum>
f0103790:	6b c0 74             	imul   $0x74,%eax,%eax
f0103793:	c7 80 28 a0 21 f0 00 	movl   $0x0,-0xfde5fd8(%eax)
f010379a:	00 00 00 
		sched_yield();
f010379d:	e8 68 14 00 00       	call   f0104c0a <sched_yield>
	}
}
f01037a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01037a5:	c9                   	leave  
f01037a6:	c3                   	ret    

f01037a7 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01037a7:	55                   	push   %ebp
f01037a8:	89 e5                	mov    %esp,%ebp
f01037aa:	57                   	push   %edi
f01037ab:	56                   	push   %esi
f01037ac:	53                   	push   %ebx
f01037ad:	83 ec 0c             	sub    $0xc,%esp
f01037b0:	8b 7d 08             	mov    0x8(%ebp),%edi
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01037b3:	83 bf b0 00 00 00 03 	cmpl   $0x3,0xb0(%edi)
f01037ba:	75 1c                	jne    f01037d8 <env_destroy+0x31>
f01037bc:	e8 79 2d 00 00       	call   f010653a <cpunum>
f01037c1:	6b c0 74             	imul   $0x74,%eax,%eax
f01037c4:	3b b8 28 a0 21 f0    	cmp    -0xfde5fd8(%eax),%edi
f01037ca:	74 0c                	je     f01037d8 <env_destroy+0x31>
		e->env_status = ENV_DYING;
f01037cc:	c7 87 b0 00 00 00 01 	movl   $0x1,0xb0(%edi)
f01037d3:	00 00 00 
		return;
f01037d6:	eb 79                	jmp    f0103851 <env_destroy+0xaa>
	}
	cprintf("In env destroy, destroying env: %d\n", e->env_id); // for testing purposes
f01037d8:	83 ec 08             	sub    $0x8,%esp
f01037db:	ff b7 a4 00 00 00    	pushl  0xa4(%edi)
f01037e1:	68 00 7f 10 f0       	push   $0xf0107f00
f01037e6:	e8 9d 05 00 00       	call   f0103d88 <cprintf>
f01037eb:	8d 5f 08             	lea    0x8(%edi),%ebx
f01037ee:	8d 77 30             	lea    0x30(%edi),%esi
f01037f1:	83 c4 10             	add    $0x10,%esp
	/*prejdi cez pole worker threadov a znic ich*/
	int i;
	for(i = 0; i < MAX_PROCESS_THREADS; i++)
	{
		if(e->worker_threads[0][i] != 0) {
f01037f4:	8b 03                	mov    (%ebx),%eax
f01037f6:	85 c0                	test   %eax,%eax
f01037f8:	74 1d                	je     f0103817 <env_destroy+0x70>
			thread_destroy(&envs[ENVX(e->worker_threads[0][i])]);	
f01037fa:	83 ec 0c             	sub    $0xc,%esp
f01037fd:	25 ff 03 00 00       	and    $0x3ff,%eax
f0103802:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
f0103808:	03 05 4c 92 21 f0    	add    0xf021924c,%eax
f010380e:	50                   	push   %eax
f010380f:	e8 1a ff ff ff       	call   f010372e <thread_destroy>
f0103814:	83 c4 10             	add    $0x10,%esp
f0103817:	83 c3 04             	add    $0x4,%ebx
		return;
	}
	cprintf("In env destroy, destroying env: %d\n", e->env_id); // for testing purposes
	/*prejdi cez pole worker threadov a znic ich*/
	int i;
	for(i = 0; i < MAX_PROCESS_THREADS; i++)
f010381a:	39 f3                	cmp    %esi,%ebx
f010381c:	75 d6                	jne    f01037f4 <env_destroy+0x4d>
		if(e->worker_threads[0][i] != 0) {
			thread_destroy(&envs[ENVX(e->worker_threads[0][i])]);	
		}
	}
	// znic main thread
	env_free(e);
f010381e:	83 ec 0c             	sub    $0xc,%esp
f0103821:	57                   	push   %edi
f0103822:	e8 4c fd ff ff       	call   f0103573 <env_free>

	if (curenv == e) {
f0103827:	e8 0e 2d 00 00       	call   f010653a <cpunum>
f010382c:	6b c0 74             	imul   $0x74,%eax,%eax
f010382f:	83 c4 10             	add    $0x10,%esp
f0103832:	3b b8 28 a0 21 f0    	cmp    -0xfde5fd8(%eax),%edi
f0103838:	75 17                	jne    f0103851 <env_destroy+0xaa>
		curenv = NULL;
f010383a:	e8 fb 2c 00 00       	call   f010653a <cpunum>
f010383f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103842:	c7 80 28 a0 21 f0 00 	movl   $0x0,-0xfde5fd8(%eax)
f0103849:	00 00 00 
		sched_yield();
f010384c:	e8 b9 13 00 00       	call   f0104c0a <sched_yield>
	}
}
f0103851:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103854:	5b                   	pop    %ebx
f0103855:	5e                   	pop    %esi
f0103856:	5f                   	pop    %edi
f0103857:	5d                   	pop    %ebp
f0103858:	c3                   	ret    

f0103859 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103859:	55                   	push   %ebp
f010385a:	89 e5                	mov    %esp,%ebp
f010385c:	53                   	push   %ebx
f010385d:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103860:	e8 d5 2c 00 00       	call   f010653a <cpunum>
f0103865:	6b c0 74             	imul   $0x74,%eax,%eax
f0103868:	8b 98 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%ebx
f010386e:	e8 c7 2c 00 00       	call   f010653a <cpunum>
f0103873:	89 83 b8 00 00 00    	mov    %eax,0xb8(%ebx)

	asm volatile(
f0103879:	8b 65 08             	mov    0x8(%ebp),%esp
f010387c:	61                   	popa   
f010387d:	07                   	pop    %es
f010387e:	1f                   	pop    %ds
f010387f:	83 c4 08             	add    $0x8,%esp
f0103882:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103883:	83 ec 04             	sub    $0x4,%esp
f0103886:	68 17 80 10 f0       	push   $0xf0108017
f010388b:	68 5b 02 00 00       	push   $0x25b
f0103890:	68 e9 7f 10 f0       	push   $0xf0107fe9
f0103895:	e8 a6 c7 ff ff       	call   f0100040 <_panic>

f010389a <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f010389a:	55                   	push   %ebp
f010389b:	89 e5                	mov    %esp,%ebp
f010389d:	53                   	push   %ebx
f010389e:	83 ec 0c             	sub    $0xc,%esp
f01038a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
        //
        // First call to env_run
	cprintf("In env run, running env: %d\n", e->env_id);// can be commented - for testing purposes only
f01038a4:	ff b3 a4 00 00 00    	pushl  0xa4(%ebx)
f01038aa:	68 23 80 10 f0       	push   $0xf0108023
f01038af:	e8 d4 04 00 00       	call   f0103d88 <cprintf>

        if ((curenv != NULL) && (curenv->env_status == ENV_RUNNING))
f01038b4:	e8 81 2c 00 00       	call   f010653a <cpunum>
f01038b9:	6b c0 74             	imul   $0x74,%eax,%eax
f01038bc:	83 c4 10             	add    $0x10,%esp
f01038bf:	83 b8 28 a0 21 f0 00 	cmpl   $0x0,-0xfde5fd8(%eax)
f01038c6:	74 2f                	je     f01038f7 <env_run+0x5d>
f01038c8:	e8 6d 2c 00 00       	call   f010653a <cpunum>
f01038cd:	6b c0 74             	imul   $0x74,%eax,%eax
f01038d0:	8b 80 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%eax
f01038d6:	83 b8 b0 00 00 00 03 	cmpl   $0x3,0xb0(%eax)
f01038dd:	75 18                	jne    f01038f7 <env_run+0x5d>
                curenv->env_status = ENV_RUNNABLE;
f01038df:	e8 56 2c 00 00       	call   f010653a <cpunum>
f01038e4:	6b c0 74             	imul   $0x74,%eax,%eax
f01038e7:	8b 80 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%eax
f01038ed:	c7 80 b0 00 00 00 02 	movl   $0x2,0xb0(%eax)
f01038f4:	00 00 00 

        curenv = e;
f01038f7:	e8 3e 2c 00 00       	call   f010653a <cpunum>
f01038fc:	6b c0 74             	imul   $0x74,%eax,%eax
f01038ff:	89 98 28 a0 21 f0    	mov    %ebx,-0xfde5fd8(%eax)
        curenv->env_status = ENV_RUNNING;
f0103905:	e8 30 2c 00 00       	call   f010653a <cpunum>
f010390a:	6b c0 74             	imul   $0x74,%eax,%eax
f010390d:	8b 80 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%eax
f0103913:	c7 80 b0 00 00 00 03 	movl   $0x3,0xb0(%eax)
f010391a:	00 00 00 
        curenv->env_runs++;
f010391d:	e8 18 2c 00 00       	call   f010653a <cpunum>
f0103922:	6b c0 74             	imul   $0x74,%eax,%eax
f0103925:	8b 80 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%eax
f010392b:	83 80 b4 00 00 00 01 	addl   $0x1,0xb4(%eax)

        lcr3(PADDR(curenv->env_pgdir));
f0103932:	e8 03 2c 00 00       	call   f010653a <cpunum>
f0103937:	6b c0 74             	imul   $0x74,%eax,%eax
f010393a:	8b 80 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%eax
f0103940:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103946:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010394b:	77 15                	ja     f0103962 <env_run+0xc8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010394d:	50                   	push   %eax
f010394e:	68 28 6c 10 f0       	push   $0xf0106c28
f0103953:	68 84 02 00 00       	push   $0x284
f0103958:	68 e9 7f 10 f0       	push   $0xf0107fe9
f010395d:	e8 de c6 ff ff       	call   f0100040 <_panic>
f0103962:	05 00 00 00 10       	add    $0x10000000,%eax
f0103967:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010396a:	83 ec 0c             	sub    $0xc,%esp
f010396d:	68 c0 23 12 f0       	push   $0xf01223c0
f0103972:	e8 ce 2e 00 00       	call   f0106845 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103977:	f3 90                	pause  
        unlock_kernel();
        env_pop_tf(&curenv->env_tf);
f0103979:	e8 bc 2b 00 00       	call   f010653a <cpunum>
f010397e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103981:	8b 80 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%eax
f0103987:	83 c0 59             	add    $0x59,%eax
f010398a:	89 04 24             	mov    %eax,(%esp)
f010398d:	e8 c7 fe ff ff       	call   f0103859 <env_pop_tf>

f0103992 <thread_free>:
// pri multithreadingu zdielany, takze by sme efektivne znicili env pgdir aj pre ostatne worker 
// thready a aj pre main thread, cize po prepnuti do jedneho z tychto threadov
// sa potom sposobuje velmi nepekny triple fault
void 
thread_free(struct Env* e)
{
f0103992:	55                   	push   %ebp
f0103993:	89 e5                	mov    %esp,%ebp
f0103995:	56                   	push   %esi
f0103996:	53                   	push   %ebx
f0103997:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("In thread free, freeing thread: %d\n", e->env_id); 
f010399a:	83 ec 08             	sub    $0x8,%esp
f010399d:	ff b3 a4 00 00 00    	pushl  0xa4(%ebx)
f01039a3:	68 24 7f 10 f0       	push   $0xf0107f24
f01039a8:	e8 db 03 00 00       	call   f0103d88 <cprintf>
	// hod jej esp adresu na zoznam volnych stackov pre thready
	stack_push(e->env_stack_id);
f01039ad:	83 c4 04             	add    $0x4,%esp
f01039b0:	ff 73 04             	pushl  0x4(%ebx)
f01039b3:	e8 d3 f6 ff ff       	call   f010308b <stack_push>
	struct Env* main_thrd = &envs[ENVX(e->env_process_id)];
f01039b8:	8b 13                	mov    (%ebx),%edx
f01039ba:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01039c0:	69 d2 d8 00 00 00    	imul   $0xd8,%edx,%edx
f01039c6:	03 15 4c 92 21 f0    	add    0xf021924c,%edx

	int i;
	for(i = 0; i < MAX_PROCESS_THREADS; i++) {
		if(main_thrd->worker_threads[0][i] == e->env_id) {
f01039cc:	8b 8b a4 00 00 00    	mov    0xa4(%ebx),%ecx
f01039d2:	83 c4 10             	add    $0x10,%esp
	// hod jej esp adresu na zoznam volnych stackov pre thready
	stack_push(e->env_stack_id);
	struct Env* main_thrd = &envs[ENVX(e->env_process_id)];

	int i;
	for(i = 0; i < MAX_PROCESS_THREADS; i++) {
f01039d5:	b8 00 00 00 00       	mov    $0x0,%eax
		if(main_thrd->worker_threads[0][i] == e->env_id) {
f01039da:	39 4c 82 08          	cmp    %ecx,0x8(%edx,%eax,4)
f01039de:	75 18                	jne    f01039f8 <thread_free+0x66>
f01039e0:	8d 04 82             	lea    (%edx,%eax,4),%eax
			main_thrd->worker_threads[0][i] = 0;	
f01039e3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
			main_thrd->worker_threads[1][i] = 0;
f01039ea:	c7 40 30 00 00 00 00 	movl   $0x0,0x30(%eax)
	// hod jej esp adresu na zoznam volnych stackov pre thready
	stack_push(e->env_stack_id);
	struct Env* main_thrd = &envs[ENVX(e->env_process_id)];

	int i;
	for(i = 0; i < MAX_PROCESS_THREADS; i++) {
f01039f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01039f6:	eb 26                	jmp    f0103a1e <thread_free+0x8c>
		if(main_thrd->worker_threads[0][i] == e->env_id) {
			main_thrd->worker_threads[0][i] = 0;	
			main_thrd->worker_threads[1][i] = 0;
			break;
		}
		if(i == MAX_PROCESS_THREADS - 1) {
f01039f8:	83 f8 09             	cmp    $0x9,%eax
f01039fb:	75 17                	jne    f0103a14 <thread_free+0x82>
			panic("environment is not a worker thread of env E - THIS SHOULD NOT 				      HAPPEN\n");
f01039fd:	83 ec 04             	sub    $0x4,%esp
f0103a00:	68 48 7f 10 f0       	push   $0xf0107f48
f0103a05:	68 a4 02 00 00       	push   $0x2a4
f0103a0a:	68 e9 7f 10 f0       	push   $0xf0107fe9
f0103a0f:	e8 2c c6 ff ff       	call   f0100040 <_panic>
	// hod jej esp adresu na zoznam volnych stackov pre thready
	stack_push(e->env_stack_id);
	struct Env* main_thrd = &envs[ENVX(e->env_process_id)];

	int i;
	for(i = 0; i < MAX_PROCESS_THREADS; i++) {
f0103a14:	83 c0 01             	add    $0x1,%eax
f0103a17:	83 f8 0a             	cmp    $0xa,%eax
f0103a1a:	75 be                	jne    f01039da <thread_free+0x48>
f0103a1c:	eb d3                	jmp    f01039f1 <thread_free+0x5f>
			panic("environment is not a worker thread of env E - THIS SHOULD NOT 				      HAPPEN\n");
		}
	}

	for(i = 0; i < MAX_PROCESS_THREADS; i++) {
		if (main_thrd->worker_threads[1][i] == THREAD_WAIT) {
f0103a1e:	83 7c 82 30 01       	cmpl   $0x1,0x30(%edx,%eax,4)
f0103a23:	74 19                	je     f0103a3e <thread_free+0xac>
			break;
		} 
		if (i == MAX_PROCESS_THREADS-1) {
f0103a25:	83 f8 09             	cmp    $0x9,%eax
f0103a28:	75 0c                	jne    f0103a36 <thread_free+0xa4>
			main_thrd->env_status = ENV_RUNNABLE;
f0103a2a:	c7 82 b0 00 00 00 02 	movl   $0x2,0xb0(%edx)
f0103a31:	00 00 00 
f0103a34:	eb 08                	jmp    f0103a3e <thread_free+0xac>
		if(i == MAX_PROCESS_THREADS - 1) {
			panic("environment is not a worker thread of env E - THIS SHOULD NOT 				      HAPPEN\n");
		}
	}

	for(i = 0; i < MAX_PROCESS_THREADS; i++) {
f0103a36:	83 c0 01             	add    $0x1,%eax
f0103a39:	83 f8 0a             	cmp    $0xa,%eax
f0103a3c:	75 e0                	jne    f0103a1e <thread_free+0x8c>
		if (i == MAX_PROCESS_THREADS-1) {
			main_thrd->env_status = ENV_RUNNABLE;
		}
	}

	e->env_pgdir = 0;
f0103a3e:	c7 83 bc 00 00 00 00 	movl   $0x0,0xbc(%ebx)
f0103a45:	00 00 00 
	e->env_status = ENV_FREE;
f0103a48:	c7 83 b0 00 00 00 00 	movl   $0x0,0xb0(%ebx)
f0103a4f:	00 00 00 
	e->env_link = env_free_list;
f0103a52:	a1 54 92 21 f0       	mov    0xf0219254,%eax
f0103a57:	89 83 a0 00 00 00    	mov    %eax,0xa0(%ebx)
	env_free_list = e;
f0103a5d:	89 1d 54 92 21 f0    	mov    %ebx,0xf0219254
	if (curenv == e) {
f0103a63:	e8 d2 2a 00 00       	call   f010653a <cpunum>
f0103a68:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a6b:	3b 98 28 a0 21 f0    	cmp    -0xfde5fd8(%eax),%ebx
f0103a71:	75 17                	jne    f0103a8a <thread_free+0xf8>
		curenv = NULL;
f0103a73:	e8 c2 2a 00 00       	call   f010653a <cpunum>
f0103a78:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a7b:	c7 80 28 a0 21 f0 00 	movl   $0x0,-0xfde5fd8(%eax)
f0103a82:	00 00 00 
		sched_yield();
f0103a85:	e8 80 11 00 00       	call   f0104c0a <sched_yield>
	}
}
f0103a8a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103a8d:	5b                   	pop    %ebx
f0103a8e:	5e                   	pop    %esi
f0103a8f:	5d                   	pop    %ebp
f0103a90:	c3                   	ret    

f0103a91 <thread_create>:

napad:  alokovanie zasobnikov - zasobnik s adresami vrcholov neobsadenych zasobnikov. Pri vytvoreni 		threadu sa popne, pri zniceni threadu pushne. //hotovo
	*/
envid_t 
thread_create(uintptr_t func)
{
f0103a91:	55                   	push   %ebp
f0103a92:	89 e5                	mov    %esp,%ebp
f0103a94:	53                   	push   %ebx
f0103a95:	83 ec 14             	sub    $0x14,%esp
	print_trapframe(&curenv->env_tf); // can be commented - for testing purposes only
f0103a98:	e8 9d 2a 00 00       	call   f010653a <cpunum>
f0103a9d:	83 ec 0c             	sub    $0xc,%esp
f0103aa0:	6b c0 74             	imul   $0x74,%eax,%eax
f0103aa3:	8b 80 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%eax
f0103aa9:	83 c0 59             	add    $0x59,%eax
f0103aac:	50                   	push   %eax
f0103aad:	e8 4d 0a 00 00       	call   f01044ff <print_trapframe>
	
	struct Env *e;
	env_alloc(&e, 0);
f0103ab2:	83 c4 08             	add    $0x8,%esp
f0103ab5:	6a 00                	push   $0x0
f0103ab7:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103aba:	50                   	push   %eax
f0103abb:	e8 6f f7 ff ff       	call   f010322f <env_alloc>
	e->env_pgdir = curenv->env_pgdir;
f0103ac0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0103ac3:	e8 72 2a 00 00       	call   f010653a <cpunum>
f0103ac8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103acb:	8b 80 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%eax
f0103ad1:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
f0103ad7:	89 83 bc 00 00 00    	mov    %eax,0xbc(%ebx)
	
	struct FreeStacks* stack = stack_pop();
f0103add:	e8 ca f5 ff ff       	call   f01030ac <stack_pop>
f0103ae2:	89 c3                	mov    %eax,%ebx
	e->env_stack_id = stack->id; 
f0103ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103ae7:	8b 13                	mov    (%ebx),%edx
f0103ae9:	89 50 04             	mov    %edx,0x4(%eax)
	region_alloc(e, (void*)(stack->addr - PGSIZE), PGSIZE);
f0103aec:	8b 4b 04             	mov    0x4(%ebx),%ecx
f0103aef:	8d 91 00 f0 ff ff    	lea    -0x1000(%ecx),%edx
f0103af5:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103afa:	e8 03 f5 ff ff       	call   f0103002 <region_alloc>
	e->env_tf.tf_esp = stack->addr;
f0103aff:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103b02:	8b 53 04             	mov    0x4(%ebx),%edx
f0103b05:	89 90 95 00 00 00    	mov    %edx,0x95(%eax)
	e->env_tf.tf_eip = func;
f0103b0b:	8b 55 08             	mov    0x8(%ebp),%edx
f0103b0e:	89 90 89 00 00 00    	mov    %edx,0x89(%eax)
f0103b14:	83 c4 10             	add    $0x10,%esp

	int i;
	for(i = 0; i < MAX_PROCESS_THREADS; i++)
f0103b17:	bb 00 00 00 00       	mov    $0x0,%ebx
	{
		if(curenv->worker_threads[0][i] == 0) {
f0103b1c:	e8 19 2a 00 00       	call   f010653a <cpunum>
f0103b21:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b24:	8b 80 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%eax
f0103b2a:	83 7c 98 08 00       	cmpl   $0x0,0x8(%eax,%ebx,4)
f0103b2f:	75 1d                	jne    f0103b4e <thread_create+0xbd>
			curenv->worker_threads[0][i] = e->env_id;	
f0103b31:	e8 04 2a 00 00       	call   f010653a <cpunum>
f0103b36:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b39:	8b 80 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%eax
f0103b3f:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103b42:	8b 92 a4 00 00 00    	mov    0xa4(%edx),%edx
f0103b48:	89 54 98 08          	mov    %edx,0x8(%eax,%ebx,4)
			break;
f0103b4c:	eb 08                	jmp    f0103b56 <thread_create+0xc5>
	region_alloc(e, (void*)(stack->addr - PGSIZE), PGSIZE);
	e->env_tf.tf_esp = stack->addr;
	e->env_tf.tf_eip = func;

	int i;
	for(i = 0; i < MAX_PROCESS_THREADS; i++)
f0103b4e:	83 c3 01             	add    $0x1,%ebx
f0103b51:	83 fb 0a             	cmp    $0xa,%ebx
f0103b54:	75 c6                	jne    f0103b1c <thread_create+0x8b>
		if(i == MAX_PROCESS_THREADS - 1) {
			// cant create any more threads - rollback
		}
	}

	e->env_status = ENV_RUNNABLE;
f0103b56:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0103b59:	c7 83 b0 00 00 00 02 	movl   $0x2,0xb0(%ebx)
f0103b60:	00 00 00 
	e->env_process_id = curenv->env_process_id; 
f0103b63:	e8 d2 29 00 00       	call   f010653a <cpunum>
f0103b68:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b6b:	8b 80 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%eax
f0103b71:	8b 00                	mov    (%eax),%eax
f0103b73:	89 03                	mov    %eax,(%ebx)
	cprintf("in thread create: thread process id: %d\n", e->env_process_id);
f0103b75:	83 ec 08             	sub    $0x8,%esp
f0103b78:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103b7b:	ff 30                	pushl  (%eax)
f0103b7d:	68 98 7f 10 f0       	push   $0xf0107f98
f0103b82:	e8 01 02 00 00       	call   f0103d88 <cprintf>
	return e->env_id;
f0103b87:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103b8a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
f0103b90:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103b93:	c9                   	leave  
f0103b94:	c3                   	ret    

f0103b95 <thread_join>:

void 
thread_join(envid_t envid)
{
f0103b95:	55                   	push   %ebp
f0103b96:	89 e5                	mov    %esp,%ebp
f0103b98:	56                   	push   %esi
f0103b99:	53                   	push   %ebx
f0103b9a:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Env* worker = &envs[ENVX(envid)];
f0103b9d:	8b 1d 4c 92 21 f0    	mov    0xf021924c,%ebx
	struct Env* main_thrd = &envs[ENVX(worker->env_process_id)];
f0103ba3:	89 f0                	mov    %esi,%eax
f0103ba5:	25 ff 03 00 00       	and    $0x3ff,%eax
f0103baa:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
f0103bb0:	8b 04 03             	mov    (%ebx,%eax,1),%eax
f0103bb3:	25 ff 03 00 00       	and    $0x3ff,%eax
f0103bb8:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
f0103bbe:	01 c3                	add    %eax,%ebx

	cprintf("in system call THREAD JOIN id: %d \n\n", envid);
f0103bc0:	83 ec 08             	sub    $0x8,%esp
f0103bc3:	56                   	push   %esi
f0103bc4:	68 c4 7f 10 f0       	push   $0xf0107fc4
f0103bc9:	e8 ba 01 00 00       	call   f0103d88 <cprintf>
f0103bce:	83 c4 10             	add    $0x10,%esp
	/*najdi worker thread, nastav jeho stav na nenulovy (waiting)*/
	int i;
	for(i = 0; i < MAX_PROCESS_THREADS; i++) {
f0103bd1:	b8 00 00 00 00       	mov    $0x0,%eax
		if(main_thrd->worker_threads[0][i] == envid) {
f0103bd6:	3b 74 83 08          	cmp    0x8(%ebx,%eax,4),%esi
f0103bda:	75 0a                	jne    f0103be6 <thread_join+0x51>
			main_thrd->worker_threads[1][i] = THREAD_WAIT;	
f0103bdc:	c7 44 83 30 01 00 00 	movl   $0x1,0x30(%ebx,%eax,4)
f0103be3:	00 
			break;
f0103be4:	eb 0d                	jmp    f0103bf3 <thread_join+0x5e>
		}
		if(i == MAX_PROCESS_THREADS - 1) {
f0103be6:	83 f8 09             	cmp    $0x9,%eax
f0103be9:	74 17                	je     f0103c02 <thread_join+0x6d>
	struct Env* main_thrd = &envs[ENVX(worker->env_process_id)];

	cprintf("in system call THREAD JOIN id: %d \n\n", envid);
	/*najdi worker thread, nastav jeho stav na nenulovy (waiting)*/
	int i;
	for(i = 0; i < MAX_PROCESS_THREADS; i++) {
f0103beb:	83 c0 01             	add    $0x1,%eax
f0103bee:	83 f8 0a             	cmp    $0xa,%eax
f0103bf1:	75 e3                	jne    f0103bd6 <thread_join+0x41>
		if(i == MAX_PROCESS_THREADS - 1) {
			// no such thread
			return;
		}
	}
	main_thrd->env_status = ENV_NOT_RUNNABLE;
f0103bf3:	c7 83 b0 00 00 00 04 	movl   $0x4,0xb0(%ebx)
f0103bfa:	00 00 00 
	sched_yield();
f0103bfd:	e8 08 10 00 00       	call   f0104c0a <sched_yield>
}
f0103c02:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103c05:	5b                   	pop    %ebx
f0103c06:	5e                   	pop    %esi
f0103c07:	5d                   	pop    %ebp
f0103c08:	c3                   	ret    

f0103c09 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103c09:	55                   	push   %ebp
f0103c0a:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103c0c:	ba 70 00 00 00       	mov    $0x70,%edx
f0103c11:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c14:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103c15:	ba 71 00 00 00       	mov    $0x71,%edx
f0103c1a:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103c1b:	0f b6 c0             	movzbl %al,%eax
}
f0103c1e:	5d                   	pop    %ebp
f0103c1f:	c3                   	ret    

f0103c20 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103c20:	55                   	push   %ebp
f0103c21:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103c23:	ba 70 00 00 00       	mov    $0x70,%edx
f0103c28:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c2b:	ee                   	out    %al,(%dx)
f0103c2c:	ba 71 00 00 00       	mov    $0x71,%edx
f0103c31:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c34:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103c35:	5d                   	pop    %ebp
f0103c36:	c3                   	ret    

f0103c37 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103c37:	55                   	push   %ebp
f0103c38:	89 e5                	mov    %esp,%ebp
f0103c3a:	56                   	push   %esi
f0103c3b:	53                   	push   %ebx
f0103c3c:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103c3f:	66 a3 a8 23 12 f0    	mov    %ax,0xf01223a8
	if (!didinit)
f0103c45:	80 3d 58 92 21 f0 00 	cmpb   $0x0,0xf0219258
f0103c4c:	74 5a                	je     f0103ca8 <irq_setmask_8259A+0x71>
f0103c4e:	89 c6                	mov    %eax,%esi
f0103c50:	ba 21 00 00 00       	mov    $0x21,%edx
f0103c55:	ee                   	out    %al,(%dx)
f0103c56:	66 c1 e8 08          	shr    $0x8,%ax
f0103c5a:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103c5f:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0103c60:	83 ec 0c             	sub    $0xc,%esp
f0103c63:	68 40 80 10 f0       	push   $0xf0108040
f0103c68:	e8 1b 01 00 00       	call   f0103d88 <cprintf>
f0103c6d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103c70:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103c75:	0f b7 f6             	movzwl %si,%esi
f0103c78:	f7 d6                	not    %esi
f0103c7a:	0f a3 de             	bt     %ebx,%esi
f0103c7d:	73 11                	jae    f0103c90 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f0103c7f:	83 ec 08             	sub    $0x8,%esp
f0103c82:	53                   	push   %ebx
f0103c83:	68 5f 85 10 f0       	push   $0xf010855f
f0103c88:	e8 fb 00 00 00       	call   f0103d88 <cprintf>
f0103c8d:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103c90:	83 c3 01             	add    $0x1,%ebx
f0103c93:	83 fb 10             	cmp    $0x10,%ebx
f0103c96:	75 e2                	jne    f0103c7a <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103c98:	83 ec 0c             	sub    $0xc,%esp
f0103c9b:	68 9a 84 10 f0       	push   $0xf010849a
f0103ca0:	e8 e3 00 00 00       	call   f0103d88 <cprintf>
f0103ca5:	83 c4 10             	add    $0x10,%esp
}
f0103ca8:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103cab:	5b                   	pop    %ebx
f0103cac:	5e                   	pop    %esi
f0103cad:	5d                   	pop    %ebp
f0103cae:	c3                   	ret    

f0103caf <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0103caf:	c6 05 58 92 21 f0 01 	movb   $0x1,0xf0219258
f0103cb6:	ba 21 00 00 00       	mov    $0x21,%edx
f0103cbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103cc0:	ee                   	out    %al,(%dx)
f0103cc1:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103cc6:	ee                   	out    %al,(%dx)
f0103cc7:	ba 20 00 00 00       	mov    $0x20,%edx
f0103ccc:	b8 11 00 00 00       	mov    $0x11,%eax
f0103cd1:	ee                   	out    %al,(%dx)
f0103cd2:	ba 21 00 00 00       	mov    $0x21,%edx
f0103cd7:	b8 20 00 00 00       	mov    $0x20,%eax
f0103cdc:	ee                   	out    %al,(%dx)
f0103cdd:	b8 04 00 00 00       	mov    $0x4,%eax
f0103ce2:	ee                   	out    %al,(%dx)
f0103ce3:	b8 03 00 00 00       	mov    $0x3,%eax
f0103ce8:	ee                   	out    %al,(%dx)
f0103ce9:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103cee:	b8 11 00 00 00       	mov    $0x11,%eax
f0103cf3:	ee                   	out    %al,(%dx)
f0103cf4:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103cf9:	b8 28 00 00 00       	mov    $0x28,%eax
f0103cfe:	ee                   	out    %al,(%dx)
f0103cff:	b8 02 00 00 00       	mov    $0x2,%eax
f0103d04:	ee                   	out    %al,(%dx)
f0103d05:	b8 01 00 00 00       	mov    $0x1,%eax
f0103d0a:	ee                   	out    %al,(%dx)
f0103d0b:	ba 20 00 00 00       	mov    $0x20,%edx
f0103d10:	b8 68 00 00 00       	mov    $0x68,%eax
f0103d15:	ee                   	out    %al,(%dx)
f0103d16:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103d1b:	ee                   	out    %al,(%dx)
f0103d1c:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103d21:	b8 68 00 00 00       	mov    $0x68,%eax
f0103d26:	ee                   	out    %al,(%dx)
f0103d27:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103d2c:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103d2d:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f0103d34:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103d38:	74 13                	je     f0103d4d <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103d3a:	55                   	push   %ebp
f0103d3b:	89 e5                	mov    %esp,%ebp
f0103d3d:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103d40:	0f b7 c0             	movzwl %ax,%eax
f0103d43:	50                   	push   %eax
f0103d44:	e8 ee fe ff ff       	call   f0103c37 <irq_setmask_8259A>
f0103d49:	83 c4 10             	add    $0x10,%esp
}
f0103d4c:	c9                   	leave  
f0103d4d:	f3 c3                	repz ret 

f0103d4f <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103d4f:	55                   	push   %ebp
f0103d50:	89 e5                	mov    %esp,%ebp
f0103d52:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103d55:	ff 75 08             	pushl  0x8(%ebp)
f0103d58:	e8 3c ca ff ff       	call   f0100799 <cputchar>
	*cnt++;
}
f0103d5d:	83 c4 10             	add    $0x10,%esp
f0103d60:	c9                   	leave  
f0103d61:	c3                   	ret    

f0103d62 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103d62:	55                   	push   %ebp
f0103d63:	89 e5                	mov    %esp,%ebp
f0103d65:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103d68:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103d6f:	ff 75 0c             	pushl  0xc(%ebp)
f0103d72:	ff 75 08             	pushl  0x8(%ebp)
f0103d75:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103d78:	50                   	push   %eax
f0103d79:	68 4f 3d 10 f0       	push   $0xf0103d4f
f0103d7e:	e8 11 1b 00 00       	call   f0105894 <vprintfmt>
	return cnt;
}
f0103d83:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103d86:	c9                   	leave  
f0103d87:	c3                   	ret    

f0103d88 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103d88:	55                   	push   %ebp
f0103d89:	89 e5                	mov    %esp,%ebp
f0103d8b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103d8e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103d91:	50                   	push   %eax
f0103d92:	ff 75 08             	pushl  0x8(%ebp)
f0103d95:	e8 c8 ff ff ff       	call   f0103d62 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103d9a:	c9                   	leave  
f0103d9b:	c3                   	ret    

f0103d9c <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103d9c:	55                   	push   %ebp
f0103d9d:	89 e5                	mov    %esp,%ebp
f0103d9f:	57                   	push   %edi
f0103da0:	56                   	push   %esi
f0103da1:	53                   	push   %ebx
f0103da2:	83 ec 1c             	sub    $0x1c,%esp
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:

	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - (thiscpu->cpu_id * (KSTKSIZE + KSTKGAP));
f0103da5:	e8 90 27 00 00       	call   f010653a <cpunum>
f0103daa:	89 c3                	mov    %eax,%ebx
f0103dac:	e8 89 27 00 00       	call   f010653a <cpunum>
f0103db1:	6b d3 74             	imul   $0x74,%ebx,%edx
f0103db4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103db7:	0f b6 88 20 a0 21 f0 	movzbl -0xfde5fe0(%eax),%ecx
f0103dbe:	c1 e1 10             	shl    $0x10,%ecx
f0103dc1:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
f0103dc6:	29 c8                	sub    %ecx,%eax
f0103dc8:	89 82 30 a0 21 f0    	mov    %eax,-0xfde5fd0(%edx)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103dce:	e8 67 27 00 00       	call   f010653a <cpunum>
f0103dd3:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dd6:	66 c7 80 34 a0 21 f0 	movw   $0x10,-0xfde5fcc(%eax)
f0103ddd:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f0103ddf:	e8 56 27 00 00       	call   f010653a <cpunum>
f0103de4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103de7:	66 c7 80 92 a0 21 f0 	movw   $0x68,-0xfde5f6e(%eax)
f0103dee:	68 00 

	uint32_t curr_cpu_gdt_index = GD_TSS0 + ((thiscpu->cpu_id + 1) * 8);
f0103df0:	e8 45 27 00 00       	call   f010653a <cpunum>
f0103df5:	6b c0 74             	imul   $0x74,%eax,%eax
f0103df8:	0f b6 80 20 a0 21 f0 	movzbl -0xfde5fe0(%eax),%eax
f0103dff:	8d 3c c5 30 00 00 00 	lea    0x30(,%eax,8),%edi

	gdt[curr_cpu_gdt_index >> 3] = SEG16
f0103e06:	89 fb                	mov    %edi,%ebx
f0103e08:	c1 eb 03             	shr    $0x3,%ebx
f0103e0b:	e8 2a 27 00 00       	call   f010653a <cpunum>
f0103e10:	89 c6                	mov    %eax,%esi
f0103e12:	e8 23 27 00 00       	call   f010653a <cpunum>
f0103e17:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103e1a:	e8 1b 27 00 00       	call   f010653a <cpunum>
f0103e1f:	66 c7 04 dd 40 23 12 	movw   $0x67,-0xfeddcc0(,%ebx,8)
f0103e26:	f0 67 00 
f0103e29:	6b f6 74             	imul   $0x74,%esi,%esi
f0103e2c:	81 c6 2c a0 21 f0    	add    $0xf021a02c,%esi
f0103e32:	66 89 34 dd 42 23 12 	mov    %si,-0xfeddcbe(,%ebx,8)
f0103e39:	f0 
f0103e3a:	6b 55 e4 74          	imul   $0x74,-0x1c(%ebp),%edx
f0103e3e:	81 c2 2c a0 21 f0    	add    $0xf021a02c,%edx
f0103e44:	c1 ea 10             	shr    $0x10,%edx
f0103e47:	88 14 dd 44 23 12 f0 	mov    %dl,-0xfeddcbc(,%ebx,8)
f0103e4e:	c6 04 dd 46 23 12 f0 	movb   $0x40,-0xfeddcba(,%ebx,8)
f0103e55:	40 
f0103e56:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e59:	05 2c a0 21 f0       	add    $0xf021a02c,%eax
f0103e5e:	c1 e8 18             	shr    $0x18,%eax
f0103e61:	88 04 dd 47 23 12 f0 	mov    %al,-0xfeddcb9(,%ebx,8)
	(STS_T32A, (uint32_t) (&thiscpu->cpu_ts), sizeof(struct Taskstate) - 1, 0);
	gdt[curr_cpu_gdt_index >> 3].sd_s = 0;
f0103e68:	c6 04 dd 45 23 12 f0 	movb   $0x89,-0xfeddcbb(,%ebx,8)
f0103e6f:	89 
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0103e70:	0f 00 df             	ltr    %di
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f0103e73:	b8 ac 23 12 f0       	mov    $0xf01223ac,%eax
f0103e78:	0f 01 18             	lidtl  (%eax)
	
	ltr(curr_cpu_gdt_index);

	// Load the IDT
	lidt(&idt_pd);
}
f0103e7b:	83 c4 1c             	add    $0x1c,%esp
f0103e7e:	5b                   	pop    %ebx
f0103e7f:	5e                   	pop    %esi
f0103e80:	5f                   	pop    %edi
f0103e81:	5d                   	pop    %ebp
f0103e82:	c3                   	ret    

f0103e83 <trap_init>:
}


void
trap_init(void)
{
f0103e83:	55                   	push   %ebp
f0103e84:	89 e5                	mov    %esp,%ebp
f0103e86:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.

	extern void TH_DIVIDE(); 	SETGATE(idt[T_DIVIDE], 0, GD_KT, TH_DIVIDE, 							0); 
f0103e89:	b8 1c 4a 10 f0       	mov    $0xf0104a1c,%eax
f0103e8e:	66 a3 60 92 21 f0    	mov    %ax,0xf0219260
f0103e94:	66 c7 05 62 92 21 f0 	movw   $0x8,0xf0219262
f0103e9b:	08 00 
f0103e9d:	c6 05 64 92 21 f0 00 	movb   $0x0,0xf0219264
f0103ea4:	c6 05 65 92 21 f0 8e 	movb   $0x8e,0xf0219265
f0103eab:	c1 e8 10             	shr    $0x10,%eax
f0103eae:	66 a3 66 92 21 f0    	mov    %ax,0xf0219266
	extern void TH_DEBUG(); 	SETGATE(idt[T_DEBUG], 0, GD_KT, TH_DEBUG, 0); 
f0103eb4:	b8 26 4a 10 f0       	mov    $0xf0104a26,%eax
f0103eb9:	66 a3 68 92 21 f0    	mov    %ax,0xf0219268
f0103ebf:	66 c7 05 6a 92 21 f0 	movw   $0x8,0xf021926a
f0103ec6:	08 00 
f0103ec8:	c6 05 6c 92 21 f0 00 	movb   $0x0,0xf021926c
f0103ecf:	c6 05 6d 92 21 f0 8e 	movb   $0x8e,0xf021926d
f0103ed6:	c1 e8 10             	shr    $0x10,%eax
f0103ed9:	66 a3 6e 92 21 f0    	mov    %ax,0xf021926e
	extern void TH_NMI(); 		SETGATE(idt[T_NMI], 0, GD_KT, TH_NMI, 0); 
f0103edf:	b8 30 4a 10 f0       	mov    $0xf0104a30,%eax
f0103ee4:	66 a3 70 92 21 f0    	mov    %ax,0xf0219270
f0103eea:	66 c7 05 72 92 21 f0 	movw   $0x8,0xf0219272
f0103ef1:	08 00 
f0103ef3:	c6 05 74 92 21 f0 00 	movb   $0x0,0xf0219274
f0103efa:	c6 05 75 92 21 f0 8e 	movb   $0x8e,0xf0219275
f0103f01:	c1 e8 10             	shr    $0x10,%eax
f0103f04:	66 a3 76 92 21 f0    	mov    %ax,0xf0219276
	extern void TH_BRKPT(); 	SETGATE(idt[T_BRKPT], 0, GD_KT, TH_BRKPT, 3); 
f0103f0a:	b8 3a 4a 10 f0       	mov    $0xf0104a3a,%eax
f0103f0f:	66 a3 78 92 21 f0    	mov    %ax,0xf0219278
f0103f15:	66 c7 05 7a 92 21 f0 	movw   $0x8,0xf021927a
f0103f1c:	08 00 
f0103f1e:	c6 05 7c 92 21 f0 00 	movb   $0x0,0xf021927c
f0103f25:	c6 05 7d 92 21 f0 ee 	movb   $0xee,0xf021927d
f0103f2c:	c1 e8 10             	shr    $0x10,%eax
f0103f2f:	66 a3 7e 92 21 f0    	mov    %ax,0xf021927e
	extern void TH_OFLOW(); 	SETGATE(idt[T_OFLOW], 0, GD_KT, TH_OFLOW, 0); 
f0103f35:	b8 44 4a 10 f0       	mov    $0xf0104a44,%eax
f0103f3a:	66 a3 80 92 21 f0    	mov    %ax,0xf0219280
f0103f40:	66 c7 05 82 92 21 f0 	movw   $0x8,0xf0219282
f0103f47:	08 00 
f0103f49:	c6 05 84 92 21 f0 00 	movb   $0x0,0xf0219284
f0103f50:	c6 05 85 92 21 f0 8e 	movb   $0x8e,0xf0219285
f0103f57:	c1 e8 10             	shr    $0x10,%eax
f0103f5a:	66 a3 86 92 21 f0    	mov    %ax,0xf0219286
	extern void TH_BOUND(); 	SETGATE(idt[T_BOUND], 0, GD_KT, TH_BOUND, 0); 
f0103f60:	b8 4e 4a 10 f0       	mov    $0xf0104a4e,%eax
f0103f65:	66 a3 88 92 21 f0    	mov    %ax,0xf0219288
f0103f6b:	66 c7 05 8a 92 21 f0 	movw   $0x8,0xf021928a
f0103f72:	08 00 
f0103f74:	c6 05 8c 92 21 f0 00 	movb   $0x0,0xf021928c
f0103f7b:	c6 05 8d 92 21 f0 8e 	movb   $0x8e,0xf021928d
f0103f82:	c1 e8 10             	shr    $0x10,%eax
f0103f85:	66 a3 8e 92 21 f0    	mov    %ax,0xf021928e
	extern void TH_ILLOP(); 	SETGATE(idt[T_ILLOP], 0, GD_KT, TH_ILLOP, 0); 
f0103f8b:	b8 58 4a 10 f0       	mov    $0xf0104a58,%eax
f0103f90:	66 a3 90 92 21 f0    	mov    %ax,0xf0219290
f0103f96:	66 c7 05 92 92 21 f0 	movw   $0x8,0xf0219292
f0103f9d:	08 00 
f0103f9f:	c6 05 94 92 21 f0 00 	movb   $0x0,0xf0219294
f0103fa6:	c6 05 95 92 21 f0 8e 	movb   $0x8e,0xf0219295
f0103fad:	c1 e8 10             	shr    $0x10,%eax
f0103fb0:	66 a3 96 92 21 f0    	mov    %ax,0xf0219296
	extern void TH_DEVICE(); 	SETGATE(idt[T_DEVICE], 0, GD_KT, TH_DEVICE, 							0); 
f0103fb6:	b8 62 4a 10 f0       	mov    $0xf0104a62,%eax
f0103fbb:	66 a3 98 92 21 f0    	mov    %ax,0xf0219298
f0103fc1:	66 c7 05 9a 92 21 f0 	movw   $0x8,0xf021929a
f0103fc8:	08 00 
f0103fca:	c6 05 9c 92 21 f0 00 	movb   $0x0,0xf021929c
f0103fd1:	c6 05 9d 92 21 f0 8e 	movb   $0x8e,0xf021929d
f0103fd8:	c1 e8 10             	shr    $0x10,%eax
f0103fdb:	66 a3 9e 92 21 f0    	mov    %ax,0xf021929e
	extern void TH_DBLFLT(); 	SETGATE(idt[T_DBLFLT], 0, GD_KT, TH_DBLFLT, 							0); 
f0103fe1:	b8 6c 4a 10 f0       	mov    $0xf0104a6c,%eax
f0103fe6:	66 a3 a0 92 21 f0    	mov    %ax,0xf02192a0
f0103fec:	66 c7 05 a2 92 21 f0 	movw   $0x8,0xf02192a2
f0103ff3:	08 00 
f0103ff5:	c6 05 a4 92 21 f0 00 	movb   $0x0,0xf02192a4
f0103ffc:	c6 05 a5 92 21 f0 8e 	movb   $0x8e,0xf02192a5
f0104003:	c1 e8 10             	shr    $0x10,%eax
f0104006:	66 a3 a6 92 21 f0    	mov    %ax,0xf02192a6
	extern void TH_TSS(); 		SETGATE(idt[T_TSS], 0, GD_KT, TH_TSS, 0); 
f010400c:	b8 74 4a 10 f0       	mov    $0xf0104a74,%eax
f0104011:	66 a3 b0 92 21 f0    	mov    %ax,0xf02192b0
f0104017:	66 c7 05 b2 92 21 f0 	movw   $0x8,0xf02192b2
f010401e:	08 00 
f0104020:	c6 05 b4 92 21 f0 00 	movb   $0x0,0xf02192b4
f0104027:	c6 05 b5 92 21 f0 8e 	movb   $0x8e,0xf02192b5
f010402e:	c1 e8 10             	shr    $0x10,%eax
f0104031:	66 a3 b6 92 21 f0    	mov    %ax,0xf02192b6
	extern void TH_SEGNP(); 	SETGATE(idt[T_SEGNP], 0, GD_KT, TH_SEGNP, 0); 
f0104037:	b8 7c 4a 10 f0       	mov    $0xf0104a7c,%eax
f010403c:	66 a3 b8 92 21 f0    	mov    %ax,0xf02192b8
f0104042:	66 c7 05 ba 92 21 f0 	movw   $0x8,0xf02192ba
f0104049:	08 00 
f010404b:	c6 05 bc 92 21 f0 00 	movb   $0x0,0xf02192bc
f0104052:	c6 05 bd 92 21 f0 8e 	movb   $0x8e,0xf02192bd
f0104059:	c1 e8 10             	shr    $0x10,%eax
f010405c:	66 a3 be 92 21 f0    	mov    %ax,0xf02192be
	extern void TH_STACK(); 	SETGATE(idt[T_STACK], 0, GD_KT, TH_STACK, 0); 
f0104062:	b8 84 4a 10 f0       	mov    $0xf0104a84,%eax
f0104067:	66 a3 c0 92 21 f0    	mov    %ax,0xf02192c0
f010406d:	66 c7 05 c2 92 21 f0 	movw   $0x8,0xf02192c2
f0104074:	08 00 
f0104076:	c6 05 c4 92 21 f0 00 	movb   $0x0,0xf02192c4
f010407d:	c6 05 c5 92 21 f0 8e 	movb   $0x8e,0xf02192c5
f0104084:	c1 e8 10             	shr    $0x10,%eax
f0104087:	66 a3 c6 92 21 f0    	mov    %ax,0xf02192c6
	extern void TH_GPFLT(); 	SETGATE(idt[T_GPFLT], 0, GD_KT, TH_GPFLT, 0); 
f010408d:	b8 8c 4a 10 f0       	mov    $0xf0104a8c,%eax
f0104092:	66 a3 c8 92 21 f0    	mov    %ax,0xf02192c8
f0104098:	66 c7 05 ca 92 21 f0 	movw   $0x8,0xf02192ca
f010409f:	08 00 
f01040a1:	c6 05 cc 92 21 f0 00 	movb   $0x0,0xf02192cc
f01040a8:	c6 05 cd 92 21 f0 8e 	movb   $0x8e,0xf02192cd
f01040af:	c1 e8 10             	shr    $0x10,%eax
f01040b2:	66 a3 ce 92 21 f0    	mov    %ax,0xf02192ce
	extern void TH_PGFLT(); 	SETGATE(idt[T_PGFLT], 0, GD_KT, TH_PGFLT, 0); 
f01040b8:	b8 94 4a 10 f0       	mov    $0xf0104a94,%eax
f01040bd:	66 a3 d0 92 21 f0    	mov    %ax,0xf02192d0
f01040c3:	66 c7 05 d2 92 21 f0 	movw   $0x8,0xf02192d2
f01040ca:	08 00 
f01040cc:	c6 05 d4 92 21 f0 00 	movb   $0x0,0xf02192d4
f01040d3:	c6 05 d5 92 21 f0 8e 	movb   $0x8e,0xf02192d5
f01040da:	c1 e8 10             	shr    $0x10,%eax
f01040dd:	66 a3 d6 92 21 f0    	mov    %ax,0xf02192d6
	extern void TH_FPERR(); 	SETGATE(idt[T_FPERR], 0, GD_KT, TH_FPERR, 0); 
f01040e3:	b8 9c 4a 10 f0       	mov    $0xf0104a9c,%eax
f01040e8:	66 a3 e0 92 21 f0    	mov    %ax,0xf02192e0
f01040ee:	66 c7 05 e2 92 21 f0 	movw   $0x8,0xf02192e2
f01040f5:	08 00 
f01040f7:	c6 05 e4 92 21 f0 00 	movb   $0x0,0xf02192e4
f01040fe:	c6 05 e5 92 21 f0 8e 	movb   $0x8e,0xf02192e5
f0104105:	c1 e8 10             	shr    $0x10,%eax
f0104108:	66 a3 e6 92 21 f0    	mov    %ax,0xf02192e6
	extern void TH_ALIGN(); 	SETGATE(idt[T_ALIGN], 0, GD_KT, TH_ALIGN, 0); 
f010410e:	b8 a2 4a 10 f0       	mov    $0xf0104aa2,%eax
f0104113:	66 a3 e8 92 21 f0    	mov    %ax,0xf02192e8
f0104119:	66 c7 05 ea 92 21 f0 	movw   $0x8,0xf02192ea
f0104120:	08 00 
f0104122:	c6 05 ec 92 21 f0 00 	movb   $0x0,0xf02192ec
f0104129:	c6 05 ed 92 21 f0 8e 	movb   $0x8e,0xf02192ed
f0104130:	c1 e8 10             	shr    $0x10,%eax
f0104133:	66 a3 ee 92 21 f0    	mov    %ax,0xf02192ee
	extern void TH_MCHK(); 		SETGATE(idt[T_MCHK], 0, GD_KT, TH_MCHK, 0); 
f0104139:	b8 a6 4a 10 f0       	mov    $0xf0104aa6,%eax
f010413e:	66 a3 f0 92 21 f0    	mov    %ax,0xf02192f0
f0104144:	66 c7 05 f2 92 21 f0 	movw   $0x8,0xf02192f2
f010414b:	08 00 
f010414d:	c6 05 f4 92 21 f0 00 	movb   $0x0,0xf02192f4
f0104154:	c6 05 f5 92 21 f0 8e 	movb   $0x8e,0xf02192f5
f010415b:	c1 e8 10             	shr    $0x10,%eax
f010415e:	66 a3 f6 92 21 f0    	mov    %ax,0xf02192f6
	extern void TH_SIMDERR(); 	SETGATE(idt[T_SIMDERR], 0, GD_KT, TH_SIMDERR, 							0); 	// prepisat neskor ako interrupt 
f0104164:	b8 ac 4a 10 f0       	mov    $0xf0104aac,%eax
f0104169:	66 a3 f8 92 21 f0    	mov    %ax,0xf02192f8
f010416f:	66 c7 05 fa 92 21 f0 	movw   $0x8,0xf02192fa
f0104176:	08 00 
f0104178:	c6 05 fc 92 21 f0 00 	movb   $0x0,0xf02192fc
f010417f:	c6 05 fd 92 21 f0 8e 	movb   $0x8e,0xf02192fd
f0104186:	c1 e8 10             	shr    $0x10,%eax
f0104189:	66 a3 fe 92 21 f0    	mov    %ax,0xf02192fe
							// namiesto trapu (neskor)
	extern void TH_SYSCALL(); 	SETGATE(idt[T_SYSCALL], 0, GD_KT, TH_SYSCALL, 							3); 
f010418f:	b8 b2 4a 10 f0       	mov    $0xf0104ab2,%eax
f0104194:	66 a3 e0 93 21 f0    	mov    %ax,0xf02193e0
f010419a:	66 c7 05 e2 93 21 f0 	movw   $0x8,0xf02193e2
f01041a1:	08 00 
f01041a3:	c6 05 e4 93 21 f0 00 	movb   $0x0,0xf02193e4
f01041aa:	c6 05 e5 93 21 f0 ee 	movb   $0xee,0xf02193e5
f01041b1:	c1 e8 10             	shr    $0x10,%eax
f01041b4:	66 a3 e6 93 21 f0    	mov    %ax,0xf02193e6

	extern void TH_IRQ_TIMER();	SETGATE(idt[IRQ_OFFSET + 0], 0, GD_KT, TH_IRQ_TIMER, 0);
f01041ba:	b8 b8 4a 10 f0       	mov    $0xf0104ab8,%eax
f01041bf:	66 a3 60 93 21 f0    	mov    %ax,0xf0219360
f01041c5:	66 c7 05 62 93 21 f0 	movw   $0x8,0xf0219362
f01041cc:	08 00 
f01041ce:	c6 05 64 93 21 f0 00 	movb   $0x0,0xf0219364
f01041d5:	c6 05 65 93 21 f0 8e 	movb   $0x8e,0xf0219365
f01041dc:	c1 e8 10             	shr    $0x10,%eax
f01041df:	66 a3 66 93 21 f0    	mov    %ax,0xf0219366
	extern void TH_IRQ_KBD();	SETGATE(idt[IRQ_OFFSET + 1], 0, GD_KT, TH_IRQ_KBD, 0);
f01041e5:	b8 be 4a 10 f0       	mov    $0xf0104abe,%eax
f01041ea:	66 a3 68 93 21 f0    	mov    %ax,0xf0219368
f01041f0:	66 c7 05 6a 93 21 f0 	movw   $0x8,0xf021936a
f01041f7:	08 00 
f01041f9:	c6 05 6c 93 21 f0 00 	movb   $0x0,0xf021936c
f0104200:	c6 05 6d 93 21 f0 8e 	movb   $0x8e,0xf021936d
f0104207:	c1 e8 10             	shr    $0x10,%eax
f010420a:	66 a3 6e 93 21 f0    	mov    %ax,0xf021936e
	extern void TH_IRQ_2();		SETGATE(idt[IRQ_OFFSET + 2], 0, GD_KT, TH_IRQ_2, 0);
f0104210:	b8 c4 4a 10 f0       	mov    $0xf0104ac4,%eax
f0104215:	66 a3 70 93 21 f0    	mov    %ax,0xf0219370
f010421b:	66 c7 05 72 93 21 f0 	movw   $0x8,0xf0219372
f0104222:	08 00 
f0104224:	c6 05 74 93 21 f0 00 	movb   $0x0,0xf0219374
f010422b:	c6 05 75 93 21 f0 8e 	movb   $0x8e,0xf0219375
f0104232:	c1 e8 10             	shr    $0x10,%eax
f0104235:	66 a3 76 93 21 f0    	mov    %ax,0xf0219376
	extern void TH_IRQ_3();		SETGATE(idt[IRQ_OFFSET + 3], 0, GD_KT, TH_IRQ_3, 0);
f010423b:	b8 ca 4a 10 f0       	mov    $0xf0104aca,%eax
f0104240:	66 a3 78 93 21 f0    	mov    %ax,0xf0219378
f0104246:	66 c7 05 7a 93 21 f0 	movw   $0x8,0xf021937a
f010424d:	08 00 
f010424f:	c6 05 7c 93 21 f0 00 	movb   $0x0,0xf021937c
f0104256:	c6 05 7d 93 21 f0 8e 	movb   $0x8e,0xf021937d
f010425d:	c1 e8 10             	shr    $0x10,%eax
f0104260:	66 a3 7e 93 21 f0    	mov    %ax,0xf021937e
	extern void TH_IRQ_SERIAL();	SETGATE(idt[IRQ_OFFSET + 4], 0, GD_KT, TH_IRQ_SERIAL, 0);
f0104266:	b8 d0 4a 10 f0       	mov    $0xf0104ad0,%eax
f010426b:	66 a3 80 93 21 f0    	mov    %ax,0xf0219380
f0104271:	66 c7 05 82 93 21 f0 	movw   $0x8,0xf0219382
f0104278:	08 00 
f010427a:	c6 05 84 93 21 f0 00 	movb   $0x0,0xf0219384
f0104281:	c6 05 85 93 21 f0 8e 	movb   $0x8e,0xf0219385
f0104288:	c1 e8 10             	shr    $0x10,%eax
f010428b:	66 a3 86 93 21 f0    	mov    %ax,0xf0219386
	extern void TH_IRQ_5();		SETGATE(idt[IRQ_OFFSET + 5], 0, GD_KT, TH_IRQ_5, 0);
f0104291:	b8 d6 4a 10 f0       	mov    $0xf0104ad6,%eax
f0104296:	66 a3 88 93 21 f0    	mov    %ax,0xf0219388
f010429c:	66 c7 05 8a 93 21 f0 	movw   $0x8,0xf021938a
f01042a3:	08 00 
f01042a5:	c6 05 8c 93 21 f0 00 	movb   $0x0,0xf021938c
f01042ac:	c6 05 8d 93 21 f0 8e 	movb   $0x8e,0xf021938d
f01042b3:	c1 e8 10             	shr    $0x10,%eax
f01042b6:	66 a3 8e 93 21 f0    	mov    %ax,0xf021938e
	extern void TH_IRQ_6();		SETGATE(idt[IRQ_OFFSET + 6], 0, GD_KT, TH_IRQ_6, 0);
f01042bc:	b8 dc 4a 10 f0       	mov    $0xf0104adc,%eax
f01042c1:	66 a3 90 93 21 f0    	mov    %ax,0xf0219390
f01042c7:	66 c7 05 92 93 21 f0 	movw   $0x8,0xf0219392
f01042ce:	08 00 
f01042d0:	c6 05 94 93 21 f0 00 	movb   $0x0,0xf0219394
f01042d7:	c6 05 95 93 21 f0 8e 	movb   $0x8e,0xf0219395
f01042de:	c1 e8 10             	shr    $0x10,%eax
f01042e1:	66 a3 96 93 21 f0    	mov    %ax,0xf0219396
	extern void TH_IRQ_SPURIOUS();	SETGATE(idt[IRQ_OFFSET + 7], 0, GD_KT, TH_IRQ_SPURIOUS, 0);
f01042e7:	b8 e2 4a 10 f0       	mov    $0xf0104ae2,%eax
f01042ec:	66 a3 98 93 21 f0    	mov    %ax,0xf0219398
f01042f2:	66 c7 05 9a 93 21 f0 	movw   $0x8,0xf021939a
f01042f9:	08 00 
f01042fb:	c6 05 9c 93 21 f0 00 	movb   $0x0,0xf021939c
f0104302:	c6 05 9d 93 21 f0 8e 	movb   $0x8e,0xf021939d
f0104309:	c1 e8 10             	shr    $0x10,%eax
f010430c:	66 a3 9e 93 21 f0    	mov    %ax,0xf021939e
	extern void TH_IRQ_8();		SETGATE(idt[IRQ_OFFSET + 8], 0, GD_KT, TH_IRQ_8, 0);
f0104312:	b8 e8 4a 10 f0       	mov    $0xf0104ae8,%eax
f0104317:	66 a3 a0 93 21 f0    	mov    %ax,0xf02193a0
f010431d:	66 c7 05 a2 93 21 f0 	movw   $0x8,0xf02193a2
f0104324:	08 00 
f0104326:	c6 05 a4 93 21 f0 00 	movb   $0x0,0xf02193a4
f010432d:	c6 05 a5 93 21 f0 8e 	movb   $0x8e,0xf02193a5
f0104334:	c1 e8 10             	shr    $0x10,%eax
f0104337:	66 a3 a6 93 21 f0    	mov    %ax,0xf02193a6
	extern void TH_IRQ_9();		SETGATE(idt[IRQ_OFFSET + 9], 0, GD_KT, TH_IRQ_9, 0);
f010433d:	b8 ee 4a 10 f0       	mov    $0xf0104aee,%eax
f0104342:	66 a3 a8 93 21 f0    	mov    %ax,0xf02193a8
f0104348:	66 c7 05 aa 93 21 f0 	movw   $0x8,0xf02193aa
f010434f:	08 00 
f0104351:	c6 05 ac 93 21 f0 00 	movb   $0x0,0xf02193ac
f0104358:	c6 05 ad 93 21 f0 8e 	movb   $0x8e,0xf02193ad
f010435f:	c1 e8 10             	shr    $0x10,%eax
f0104362:	66 a3 ae 93 21 f0    	mov    %ax,0xf02193ae
	extern void TH_IRQ_10();	SETGATE(idt[IRQ_OFFSET + 10], 0, GD_KT, TH_IRQ_10, 0);
f0104368:	b8 f4 4a 10 f0       	mov    $0xf0104af4,%eax
f010436d:	66 a3 b0 93 21 f0    	mov    %ax,0xf02193b0
f0104373:	66 c7 05 b2 93 21 f0 	movw   $0x8,0xf02193b2
f010437a:	08 00 
f010437c:	c6 05 b4 93 21 f0 00 	movb   $0x0,0xf02193b4
f0104383:	c6 05 b5 93 21 f0 8e 	movb   $0x8e,0xf02193b5
f010438a:	c1 e8 10             	shr    $0x10,%eax
f010438d:	66 a3 b6 93 21 f0    	mov    %ax,0xf02193b6
	extern void TH_IRQ_11();	SETGATE(idt[IRQ_OFFSET + 11], 0, GD_KT, TH_IRQ_11, 0);
f0104393:	b8 fa 4a 10 f0       	mov    $0xf0104afa,%eax
f0104398:	66 a3 b8 93 21 f0    	mov    %ax,0xf02193b8
f010439e:	66 c7 05 ba 93 21 f0 	movw   $0x8,0xf02193ba
f01043a5:	08 00 
f01043a7:	c6 05 bc 93 21 f0 00 	movb   $0x0,0xf02193bc
f01043ae:	c6 05 bd 93 21 f0 8e 	movb   $0x8e,0xf02193bd
f01043b5:	c1 e8 10             	shr    $0x10,%eax
f01043b8:	66 a3 be 93 21 f0    	mov    %ax,0xf02193be
	extern void TH_IRQ_12();	SETGATE(idt[IRQ_OFFSET + 12], 0, GD_KT, TH_IRQ_12, 0);
f01043be:	b8 00 4b 10 f0       	mov    $0xf0104b00,%eax
f01043c3:	66 a3 c0 93 21 f0    	mov    %ax,0xf02193c0
f01043c9:	66 c7 05 c2 93 21 f0 	movw   $0x8,0xf02193c2
f01043d0:	08 00 
f01043d2:	c6 05 c4 93 21 f0 00 	movb   $0x0,0xf02193c4
f01043d9:	c6 05 c5 93 21 f0 8e 	movb   $0x8e,0xf02193c5
f01043e0:	c1 e8 10             	shr    $0x10,%eax
f01043e3:	66 a3 c6 93 21 f0    	mov    %ax,0xf02193c6
	extern void TH_IRQ_13();	SETGATE(idt[IRQ_OFFSET + 13], 0, GD_KT, TH_IRQ_13, 0);
f01043e9:	b8 06 4b 10 f0       	mov    $0xf0104b06,%eax
f01043ee:	66 a3 c8 93 21 f0    	mov    %ax,0xf02193c8
f01043f4:	66 c7 05 ca 93 21 f0 	movw   $0x8,0xf02193ca
f01043fb:	08 00 
f01043fd:	c6 05 cc 93 21 f0 00 	movb   $0x0,0xf02193cc
f0104404:	c6 05 cd 93 21 f0 8e 	movb   $0x8e,0xf02193cd
f010440b:	c1 e8 10             	shr    $0x10,%eax
f010440e:	66 a3 ce 93 21 f0    	mov    %ax,0xf02193ce
	extern void TH_IRQ_IDE();	SETGATE(idt[IRQ_OFFSET + 14], 0, GD_KT, TH_IRQ_IDE, 0);
f0104414:	b8 0c 4b 10 f0       	mov    $0xf0104b0c,%eax
f0104419:	66 a3 d0 93 21 f0    	mov    %ax,0xf02193d0
f010441f:	66 c7 05 d2 93 21 f0 	movw   $0x8,0xf02193d2
f0104426:	08 00 
f0104428:	c6 05 d4 93 21 f0 00 	movb   $0x0,0xf02193d4
f010442f:	c6 05 d5 93 21 f0 8e 	movb   $0x8e,0xf02193d5
f0104436:	c1 e8 10             	shr    $0x10,%eax
f0104439:	66 a3 d6 93 21 f0    	mov    %ax,0xf02193d6
	extern void TH_IRQ_15();	SETGATE(idt[IRQ_OFFSET + 15], 0, GD_KT, TH_IRQ_15, 0);
f010443f:	b8 12 4b 10 f0       	mov    $0xf0104b12,%eax
f0104444:	66 a3 d8 93 21 f0    	mov    %ax,0xf02193d8
f010444a:	66 c7 05 da 93 21 f0 	movw   $0x8,0xf02193da
f0104451:	08 00 
f0104453:	c6 05 dc 93 21 f0 00 	movb   $0x0,0xf02193dc
f010445a:	c6 05 dd 93 21 f0 8e 	movb   $0x8e,0xf02193dd
f0104461:	c1 e8 10             	shr    $0x10,%eax
f0104464:	66 a3 de 93 21 f0    	mov    %ax,0xf02193de

	// Per-CPU setup 
	trap_init_percpu();
f010446a:	e8 2d f9 ff ff       	call   f0103d9c <trap_init_percpu>
}
f010446f:	c9                   	leave  
f0104470:	c3                   	ret    

f0104471 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0104471:	55                   	push   %ebp
f0104472:	89 e5                	mov    %esp,%ebp
f0104474:	53                   	push   %ebx
f0104475:	83 ec 0c             	sub    $0xc,%esp
f0104478:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010447b:	ff 33                	pushl  (%ebx)
f010447d:	68 54 80 10 f0       	push   $0xf0108054
f0104482:	e8 01 f9 ff ff       	call   f0103d88 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0104487:	83 c4 08             	add    $0x8,%esp
f010448a:	ff 73 04             	pushl  0x4(%ebx)
f010448d:	68 63 80 10 f0       	push   $0xf0108063
f0104492:	e8 f1 f8 ff ff       	call   f0103d88 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0104497:	83 c4 08             	add    $0x8,%esp
f010449a:	ff 73 08             	pushl  0x8(%ebx)
f010449d:	68 72 80 10 f0       	push   $0xf0108072
f01044a2:	e8 e1 f8 ff ff       	call   f0103d88 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01044a7:	83 c4 08             	add    $0x8,%esp
f01044aa:	ff 73 0c             	pushl  0xc(%ebx)
f01044ad:	68 81 80 10 f0       	push   $0xf0108081
f01044b2:	e8 d1 f8 ff ff       	call   f0103d88 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01044b7:	83 c4 08             	add    $0x8,%esp
f01044ba:	ff 73 10             	pushl  0x10(%ebx)
f01044bd:	68 90 80 10 f0       	push   $0xf0108090
f01044c2:	e8 c1 f8 ff ff       	call   f0103d88 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01044c7:	83 c4 08             	add    $0x8,%esp
f01044ca:	ff 73 14             	pushl  0x14(%ebx)
f01044cd:	68 9f 80 10 f0       	push   $0xf010809f
f01044d2:	e8 b1 f8 ff ff       	call   f0103d88 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01044d7:	83 c4 08             	add    $0x8,%esp
f01044da:	ff 73 18             	pushl  0x18(%ebx)
f01044dd:	68 ae 80 10 f0       	push   $0xf01080ae
f01044e2:	e8 a1 f8 ff ff       	call   f0103d88 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01044e7:	83 c4 08             	add    $0x8,%esp
f01044ea:	ff 73 1c             	pushl  0x1c(%ebx)
f01044ed:	68 bd 80 10 f0       	push   $0xf01080bd
f01044f2:	e8 91 f8 ff ff       	call   f0103d88 <cprintf>
}
f01044f7:	83 c4 10             	add    $0x10,%esp
f01044fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01044fd:	c9                   	leave  
f01044fe:	c3                   	ret    

f01044ff <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f01044ff:	55                   	push   %ebp
f0104500:	89 e5                	mov    %esp,%ebp
f0104502:	56                   	push   %esi
f0104503:	53                   	push   %ebx
f0104504:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0104507:	e8 2e 20 00 00       	call   f010653a <cpunum>
f010450c:	83 ec 04             	sub    $0x4,%esp
f010450f:	50                   	push   %eax
f0104510:	53                   	push   %ebx
f0104511:	68 21 81 10 f0       	push   $0xf0108121
f0104516:	e8 6d f8 ff ff       	call   f0103d88 <cprintf>
	print_regs(&tf->tf_regs);
f010451b:	89 1c 24             	mov    %ebx,(%esp)
f010451e:	e8 4e ff ff ff       	call   f0104471 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0104523:	83 c4 08             	add    $0x8,%esp
f0104526:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f010452a:	50                   	push   %eax
f010452b:	68 3f 81 10 f0       	push   $0xf010813f
f0104530:	e8 53 f8 ff ff       	call   f0103d88 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0104535:	83 c4 08             	add    $0x8,%esp
f0104538:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f010453c:	50                   	push   %eax
f010453d:	68 52 81 10 f0       	push   $0xf0108152
f0104542:	e8 41 f8 ff ff       	call   f0103d88 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104547:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f010454a:	83 c4 10             	add    $0x10,%esp
f010454d:	83 f8 13             	cmp    $0x13,%eax
f0104550:	77 09                	ja     f010455b <print_trapframe+0x5c>
		return excnames[trapno];
f0104552:	8b 14 85 00 84 10 f0 	mov    -0xfef7c00(,%eax,4),%edx
f0104559:	eb 1f                	jmp    f010457a <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f010455b:	83 f8 30             	cmp    $0x30,%eax
f010455e:	74 15                	je     f0104575 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104560:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0104563:	83 fa 10             	cmp    $0x10,%edx
f0104566:	b9 eb 80 10 f0       	mov    $0xf01080eb,%ecx
f010456b:	ba d8 80 10 f0       	mov    $0xf01080d8,%edx
f0104570:	0f 43 d1             	cmovae %ecx,%edx
f0104573:	eb 05                	jmp    f010457a <print_trapframe+0x7b>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0104575:	ba cc 80 10 f0       	mov    $0xf01080cc,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010457a:	83 ec 04             	sub    $0x4,%esp
f010457d:	52                   	push   %edx
f010457e:	50                   	push   %eax
f010457f:	68 65 81 10 f0       	push   $0xf0108165
f0104584:	e8 ff f7 ff ff       	call   f0103d88 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104589:	83 c4 10             	add    $0x10,%esp
f010458c:	3b 1d 60 9a 21 f0    	cmp    0xf0219a60,%ebx
f0104592:	75 1a                	jne    f01045ae <print_trapframe+0xaf>
f0104594:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104598:	75 14                	jne    f01045ae <print_trapframe+0xaf>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f010459a:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010459d:	83 ec 08             	sub    $0x8,%esp
f01045a0:	50                   	push   %eax
f01045a1:	68 77 81 10 f0       	push   $0xf0108177
f01045a6:	e8 dd f7 ff ff       	call   f0103d88 <cprintf>
f01045ab:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f01045ae:	83 ec 08             	sub    $0x8,%esp
f01045b1:	ff 73 2c             	pushl  0x2c(%ebx)
f01045b4:	68 86 81 10 f0       	push   $0xf0108186
f01045b9:	e8 ca f7 ff ff       	call   f0103d88 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f01045be:	83 c4 10             	add    $0x10,%esp
f01045c1:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01045c5:	75 49                	jne    f0104610 <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f01045c7:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f01045ca:	89 c2                	mov    %eax,%edx
f01045cc:	83 e2 01             	and    $0x1,%edx
f01045cf:	ba 05 81 10 f0       	mov    $0xf0108105,%edx
f01045d4:	b9 fa 80 10 f0       	mov    $0xf01080fa,%ecx
f01045d9:	0f 44 ca             	cmove  %edx,%ecx
f01045dc:	89 c2                	mov    %eax,%edx
f01045de:	83 e2 02             	and    $0x2,%edx
f01045e1:	ba 17 81 10 f0       	mov    $0xf0108117,%edx
f01045e6:	be 11 81 10 f0       	mov    $0xf0108111,%esi
f01045eb:	0f 45 d6             	cmovne %esi,%edx
f01045ee:	83 e0 04             	and    $0x4,%eax
f01045f1:	be 7e 82 10 f0       	mov    $0xf010827e,%esi
f01045f6:	b8 1c 81 10 f0       	mov    $0xf010811c,%eax
f01045fb:	0f 44 c6             	cmove  %esi,%eax
f01045fe:	51                   	push   %ecx
f01045ff:	52                   	push   %edx
f0104600:	50                   	push   %eax
f0104601:	68 94 81 10 f0       	push   $0xf0108194
f0104606:	e8 7d f7 ff ff       	call   f0103d88 <cprintf>
f010460b:	83 c4 10             	add    $0x10,%esp
f010460e:	eb 10                	jmp    f0104620 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0104610:	83 ec 0c             	sub    $0xc,%esp
f0104613:	68 9a 84 10 f0       	push   $0xf010849a
f0104618:	e8 6b f7 ff ff       	call   f0103d88 <cprintf>
f010461d:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104620:	83 ec 08             	sub    $0x8,%esp
f0104623:	ff 73 30             	pushl  0x30(%ebx)
f0104626:	68 a3 81 10 f0       	push   $0xf01081a3
f010462b:	e8 58 f7 ff ff       	call   f0103d88 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104630:	83 c4 08             	add    $0x8,%esp
f0104633:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104637:	50                   	push   %eax
f0104638:	68 b2 81 10 f0       	push   $0xf01081b2
f010463d:	e8 46 f7 ff ff       	call   f0103d88 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104642:	83 c4 08             	add    $0x8,%esp
f0104645:	ff 73 38             	pushl  0x38(%ebx)
f0104648:	68 c5 81 10 f0       	push   $0xf01081c5
f010464d:	e8 36 f7 ff ff       	call   f0103d88 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104652:	83 c4 10             	add    $0x10,%esp
f0104655:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104659:	74 25                	je     f0104680 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010465b:	83 ec 08             	sub    $0x8,%esp
f010465e:	ff 73 3c             	pushl  0x3c(%ebx)
f0104661:	68 d4 81 10 f0       	push   $0xf01081d4
f0104666:	e8 1d f7 ff ff       	call   f0103d88 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010466b:	83 c4 08             	add    $0x8,%esp
f010466e:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104672:	50                   	push   %eax
f0104673:	68 e3 81 10 f0       	push   $0xf01081e3
f0104678:	e8 0b f7 ff ff       	call   f0103d88 <cprintf>
f010467d:	83 c4 10             	add    $0x10,%esp
	}
}
f0104680:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104683:	5b                   	pop    %ebx
f0104684:	5e                   	pop    %esi
f0104685:	5d                   	pop    %ebp
f0104686:	c3                   	ret    

f0104687 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104687:	55                   	push   %ebp
f0104688:	89 e5                	mov    %esp,%ebp
f010468a:	57                   	push   %edi
f010468b:	56                   	push   %esi
f010468c:	53                   	push   %ebx
f010468d:	83 ec 0c             	sub    $0xc,%esp
f0104690:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104693:	0f 20 d6             	mov    %cr2,%esi

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.

	if ((tf->tf_cs & 3) == 0) {
f0104696:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010469a:	75 17                	jne    f01046b3 <page_fault_handler+0x2c>
		panic("kernel page fault\n");
f010469c:	83 ec 04             	sub    $0x4,%esp
f010469f:	68 f6 81 10 f0       	push   $0xf01081f6
f01046a4:	68 5f 01 00 00       	push   $0x15f
f01046a9:	68 09 82 10 f0       	push   $0xf0108209
f01046ae:	e8 8d b9 ff ff       	call   f0100040 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	if (curenv->env_pgfault_upcall) {
f01046b3:	e8 82 1e 00 00       	call   f010653a <cpunum>
f01046b8:	6b c0 74             	imul   $0x74,%eax,%eax
f01046bb:	8b 80 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%eax
f01046c1:	83 b8 c0 00 00 00 00 	cmpl   $0x0,0xc0(%eax)
f01046c8:	0f 84 b0 00 00 00    	je     f010477e <page_fault_handler+0xf7>
		struct UTrapframe *utf;
		uintptr_t utf_va;
		if ((tf->tf_esp >= UXSTACKTOP - PGSIZE) && 
f01046ce:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01046d1:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
		    (tf->tf_esp < UXSTACKTOP)) {
			utf_va = tf->tf_esp - sizeof(struct UTrapframe) - 4;
f01046d7:	83 e8 38             	sub    $0x38,%eax
f01046da:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f01046e0:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f01046e5:	0f 46 d0             	cmovbe %eax,%edx
f01046e8:	89 d7                	mov    %edx,%edi
		} else {
			utf_va = UXSTACKTOP - sizeof(struct UTrapframe);
		}
	
		user_mem_assert(curenv, (void*)utf_va, sizeof(struct UTrapframe), 					PTE_W);
f01046ea:	e8 4b 1e 00 00       	call   f010653a <cpunum>
f01046ef:	6a 02                	push   $0x2
f01046f1:	6a 34                	push   $0x34
f01046f3:	57                   	push   %edi
f01046f4:	6b c0 74             	imul   $0x74,%eax,%eax
f01046f7:	ff b0 28 a0 21 f0    	pushl  -0xfde5fd8(%eax)
f01046fd:	e8 b3 e8 ff ff       	call   f0102fb5 <user_mem_assert>
		utf = (struct UTrapframe*) utf_va;

		utf->utf_fault_va = fault_va;
f0104702:	89 fa                	mov    %edi,%edx
f0104704:	89 37                	mov    %esi,(%edi)
		utf->utf_err = tf->tf_err;
f0104706:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104709:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_regs = tf->tf_regs;
f010470c:	8d 7f 08             	lea    0x8(%edi),%edi
f010470f:	b9 08 00 00 00       	mov    $0x8,%ecx
f0104714:	89 de                	mov    %ebx,%esi
f0104716:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eip = tf->tf_eip;
f0104718:	8b 43 30             	mov    0x30(%ebx),%eax
f010471b:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags = tf->tf_eflags;
f010471e:	8b 43 38             	mov    0x38(%ebx),%eax
f0104721:	89 d7                	mov    %edx,%edi
f0104723:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;
f0104726:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104729:	89 42 30             	mov    %eax,0x30(%edx)

		curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f010472c:	e8 09 1e 00 00       	call   f010653a <cpunum>
f0104731:	6b c0 74             	imul   $0x74,%eax,%eax
f0104734:	8b 98 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%ebx
f010473a:	e8 fb 1d 00 00       	call   f010653a <cpunum>
f010473f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104742:	8b 80 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%eax
f0104748:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
f010474e:	89 83 89 00 00 00    	mov    %eax,0x89(%ebx)
		curenv->env_tf.tf_esp = utf_va;
f0104754:	e8 e1 1d 00 00       	call   f010653a <cpunum>
f0104759:	6b c0 74             	imul   $0x74,%eax,%eax
f010475c:	8b 80 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%eax
f0104762:	89 b8 95 00 00 00    	mov    %edi,0x95(%eax)
		env_run(curenv);
f0104768:	e8 cd 1d 00 00       	call   f010653a <cpunum>
f010476d:	83 c4 04             	add    $0x4,%esp
f0104770:	6b c0 74             	imul   $0x74,%eax,%eax
f0104773:	ff b0 28 a0 21 f0    	pushl  -0xfde5fd8(%eax)
f0104779:	e8 1c f1 ff ff       	call   f010389a <env_run>
	}


	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010477e:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0104781:	e8 b4 1d 00 00       	call   f010653a <cpunum>
		env_run(curenv);
	}


	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104786:	57                   	push   %edi
f0104787:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0104788:	6b c0 74             	imul   $0x74,%eax,%eax
		env_run(curenv);
	}


	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010478b:	8b 80 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%eax
f0104791:	ff b0 a4 00 00 00    	pushl  0xa4(%eax)
f0104797:	68 c8 83 10 f0       	push   $0xf01083c8
f010479c:	e8 e7 f5 ff ff       	call   f0103d88 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01047a1:	89 1c 24             	mov    %ebx,(%esp)
f01047a4:	e8 56 fd ff ff       	call   f01044ff <print_trapframe>
	env_destroy(curenv);
f01047a9:	e8 8c 1d 00 00       	call   f010653a <cpunum>
f01047ae:	83 c4 04             	add    $0x4,%esp
f01047b1:	6b c0 74             	imul   $0x74,%eax,%eax
f01047b4:	ff b0 28 a0 21 f0    	pushl  -0xfde5fd8(%eax)
f01047ba:	e8 e8 ef ff ff       	call   f01037a7 <env_destroy>
}
f01047bf:	83 c4 10             	add    $0x10,%esp
f01047c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01047c5:	5b                   	pop    %ebx
f01047c6:	5e                   	pop    %esi
f01047c7:	5f                   	pop    %edi
f01047c8:	5d                   	pop    %ebp
f01047c9:	c3                   	ret    

f01047ca <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01047ca:	55                   	push   %ebp
f01047cb:	89 e5                	mov    %esp,%ebp
f01047cd:	57                   	push   %edi
f01047ce:	56                   	push   %esi
f01047cf:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01047d2:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f01047d3:	83 3d 80 9e 21 f0 00 	cmpl   $0x0,0xf0219e80
f01047da:	74 01                	je     f01047dd <trap+0x13>
		asm volatile("hlt");
f01047dc:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01047dd:	e8 58 1d 00 00       	call   f010653a <cpunum>
f01047e2:	6b d0 74             	imul   $0x74,%eax,%edx
f01047e5:	81 c2 20 a0 21 f0    	add    $0xf021a020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01047eb:	b8 01 00 00 00       	mov    $0x1,%eax
f01047f0:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f01047f4:	83 f8 02             	cmp    $0x2,%eax
f01047f7:	75 10                	jne    f0104809 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01047f9:	83 ec 0c             	sub    $0xc,%esp
f01047fc:	68 c0 23 12 f0       	push   $0xf01223c0
f0104801:	e8 a2 1f 00 00       	call   f01067a8 <spin_lock>
f0104806:	83 c4 10             	add    $0x10,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104809:	9c                   	pushf  
f010480a:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f010480b:	f6 c4 02             	test   $0x2,%ah
f010480e:	74 19                	je     f0104829 <trap+0x5f>
f0104810:	68 15 82 10 f0       	push   $0xf0108215
f0104815:	68 14 7b 10 f0       	push   $0xf0107b14
f010481a:	68 26 01 00 00       	push   $0x126
f010481f:	68 09 82 10 f0       	push   $0xf0108209
f0104824:	e8 17 b8 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104829:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010482d:	83 e0 03             	and    $0x3,%eax
f0104830:	66 83 f8 03          	cmp    $0x3,%ax
f0104834:	0f 85 a7 00 00 00    	jne    f01048e1 <trap+0x117>
f010483a:	83 ec 0c             	sub    $0xc,%esp
f010483d:	68 c0 23 12 f0       	push   $0xf01223c0
f0104842:	e8 61 1f 00 00       	call   f01067a8 <spin_lock>
		// serious kernel work.
		// LAB 4: Your code here.

		lock_kernel();

		assert(curenv);
f0104847:	e8 ee 1c 00 00       	call   f010653a <cpunum>
f010484c:	6b c0 74             	imul   $0x74,%eax,%eax
f010484f:	83 c4 10             	add    $0x10,%esp
f0104852:	83 b8 28 a0 21 f0 00 	cmpl   $0x0,-0xfde5fd8(%eax)
f0104859:	75 19                	jne    f0104874 <trap+0xaa>
f010485b:	68 2e 82 10 f0       	push   $0xf010822e
f0104860:	68 14 7b 10 f0       	push   $0xf0107b14
f0104865:	68 30 01 00 00       	push   $0x130
f010486a:	68 09 82 10 f0       	push   $0xf0108209
f010486f:	e8 cc b7 ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0104874:	e8 c1 1c 00 00       	call   f010653a <cpunum>
f0104879:	6b c0 74             	imul   $0x74,%eax,%eax
f010487c:	8b 80 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%eax
f0104882:	83 b8 b0 00 00 00 01 	cmpl   $0x1,0xb0(%eax)
f0104889:	75 2d                	jne    f01048b8 <trap+0xee>
			env_free(curenv);
f010488b:	e8 aa 1c 00 00       	call   f010653a <cpunum>
f0104890:	83 ec 0c             	sub    $0xc,%esp
f0104893:	6b c0 74             	imul   $0x74,%eax,%eax
f0104896:	ff b0 28 a0 21 f0    	pushl  -0xfde5fd8(%eax)
f010489c:	e8 d2 ec ff ff       	call   f0103573 <env_free>
			curenv = NULL;
f01048a1:	e8 94 1c 00 00       	call   f010653a <cpunum>
f01048a6:	6b c0 74             	imul   $0x74,%eax,%eax
f01048a9:	c7 80 28 a0 21 f0 00 	movl   $0x0,-0xfde5fd8(%eax)
f01048b0:	00 00 00 
			sched_yield();
f01048b3:	e8 52 03 00 00       	call   f0104c0a <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01048b8:	e8 7d 1c 00 00       	call   f010653a <cpunum>
f01048bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01048c0:	8b b8 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%edi
f01048c6:	83 c7 59             	add    $0x59,%edi
f01048c9:	b9 11 00 00 00       	mov    $0x11,%ecx
f01048ce:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01048d0:	e8 65 1c 00 00       	call   f010653a <cpunum>
f01048d5:	6b c0 74             	imul   $0x74,%eax,%eax
f01048d8:	8b b0 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%esi
f01048de:	83 c6 59             	add    $0x59,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01048e1:	89 35 60 9a 21 f0    	mov    %esi,0xf0219a60
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.

	switch (tf->tf_trapno) {	
f01048e7:	8b 46 28             	mov    0x28(%esi),%eax
f01048ea:	83 f8 0e             	cmp    $0xe,%eax
f01048ed:	74 0c                	je     f01048fb <trap+0x131>
f01048ef:	83 f8 30             	cmp    $0x30,%eax
f01048f2:	74 38                	je     f010492c <trap+0x162>
f01048f4:	83 f8 03             	cmp    $0x3,%eax
f01048f7:	75 57                	jne    f0104950 <trap+0x186>
f01048f9:	eb 11                	jmp    f010490c <trap+0x142>
	case T_PGFLT:
		page_fault_handler(tf);
f01048fb:	83 ec 0c             	sub    $0xc,%esp
f01048fe:	56                   	push   %esi
f01048ff:	e8 83 fd ff ff       	call   f0104687 <page_fault_handler>
f0104904:	83 c4 10             	add    $0x10,%esp
f0104907:	e9 cd 00 00 00       	jmp    f01049d9 <trap+0x20f>
		return;
	case T_BRKPT:
		print_trapframe(tf);
f010490c:	83 ec 0c             	sub    $0xc,%esp
f010490f:	56                   	push   %esi
f0104910:	e8 ea fb ff ff       	call   f01044ff <print_trapframe>
		panic("tf->tf_trapno == T_BRKPT\n");
f0104915:	83 c4 0c             	add    $0xc,%esp
f0104918:	68 35 82 10 f0       	push   $0xf0108235
f010491d:	68 e0 00 00 00       	push   $0xe0
f0104922:	68 09 82 10 f0       	push   $0xf0108209
f0104927:	e8 14 b7 ff ff       	call   f0100040 <_panic>
		return;
	case T_SYSCALL:
		tf->tf_regs.reg_eax = syscall(
f010492c:	83 ec 08             	sub    $0x8,%esp
f010492f:	ff 76 04             	pushl  0x4(%esi)
f0104932:	ff 36                	pushl  (%esi)
f0104934:	ff 76 10             	pushl  0x10(%esi)
f0104937:	ff 76 18             	pushl  0x18(%esi)
f010493a:	ff 76 14             	pushl  0x14(%esi)
f010493d:	ff 76 1c             	pushl  0x1c(%esi)
f0104940:	e8 02 04 00 00       	call   f0104d47 <syscall>
f0104945:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104948:	83 c4 20             	add    $0x20,%esp
f010494b:	e9 89 00 00 00       	jmp    f01049d9 <trap+0x20f>
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104950:	83 f8 27             	cmp    $0x27,%eax
f0104953:	75 1a                	jne    f010496f <trap+0x1a5>
		cprintf("Spurious interrupt on irq 7\n");
f0104955:	83 ec 0c             	sub    $0xc,%esp
f0104958:	68 4f 82 10 f0       	push   $0xf010824f
f010495d:	e8 26 f4 ff ff       	call   f0103d88 <cprintf>
		print_trapframe(tf);
f0104962:	89 34 24             	mov    %esi,(%esp)
f0104965:	e8 95 fb ff ff       	call   f01044ff <print_trapframe>
f010496a:	83 c4 10             	add    $0x10,%esp
f010496d:	eb 6a                	jmp    f01049d9 <trap+0x20f>

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f010496f:	83 f8 20             	cmp    $0x20,%eax
f0104972:	75 0a                	jne    f010497e <trap+0x1b4>
		lapic_eoi();
f0104974:	e8 0c 1d 00 00       	call   f0106685 <lapic_eoi>
		sched_yield();
f0104979:	e8 8c 02 00 00       	call   f0104c0a <sched_yield>
	}

	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.

	if (tf->tf_trapno == (IRQ_OFFSET + IRQ_KBD)) {
f010497e:	83 f8 21             	cmp    $0x21,%eax
f0104981:	75 07                	jne    f010498a <trap+0x1c0>
		kbd_intr();
f0104983:	e8 6f bc ff ff       	call   f01005f7 <kbd_intr>
f0104988:	eb 4f                	jmp    f01049d9 <trap+0x20f>
		return;
	}

	if (tf->tf_trapno == (IRQ_OFFSET + IRQ_SERIAL)) {
f010498a:	83 f8 24             	cmp    $0x24,%eax
f010498d:	75 07                	jne    f0104996 <trap+0x1cc>
		serial_intr();
f010498f:	e8 47 bc ff ff       	call   f01005db <serial_intr>
f0104994:	eb 43                	jmp    f01049d9 <trap+0x20f>
		return;
	}

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104996:	83 ec 0c             	sub    $0xc,%esp
f0104999:	56                   	push   %esi
f010499a:	e8 60 fb ff ff       	call   f01044ff <print_trapframe>
	if (tf->tf_cs == GD_KT)
f010499f:	83 c4 10             	add    $0x10,%esp
f01049a2:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01049a7:	75 17                	jne    f01049c0 <trap+0x1f6>
		panic("unhandled trap in kernel");
f01049a9:	83 ec 04             	sub    $0x4,%esp
f01049ac:	68 6c 82 10 f0       	push   $0xf010826c
f01049b1:	68 0c 01 00 00       	push   $0x10c
f01049b6:	68 09 82 10 f0       	push   $0xf0108209
f01049bb:	e8 80 b6 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f01049c0:	e8 75 1b 00 00       	call   f010653a <cpunum>
f01049c5:	83 ec 0c             	sub    $0xc,%esp
f01049c8:	6b c0 74             	imul   $0x74,%eax,%eax
f01049cb:	ff b0 28 a0 21 f0    	pushl  -0xfde5fd8(%eax)
f01049d1:	e8 d1 ed ff ff       	call   f01037a7 <env_destroy>
f01049d6:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f01049d9:	e8 5c 1b 00 00       	call   f010653a <cpunum>
f01049de:	6b c0 74             	imul   $0x74,%eax,%eax
f01049e1:	83 b8 28 a0 21 f0 00 	cmpl   $0x0,-0xfde5fd8(%eax)
f01049e8:	74 2d                	je     f0104a17 <trap+0x24d>
f01049ea:	e8 4b 1b 00 00       	call   f010653a <cpunum>
f01049ef:	6b c0 74             	imul   $0x74,%eax,%eax
f01049f2:	8b 80 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%eax
f01049f8:	83 b8 b0 00 00 00 03 	cmpl   $0x3,0xb0(%eax)
f01049ff:	75 16                	jne    f0104a17 <trap+0x24d>
		env_run(curenv);
f0104a01:	e8 34 1b 00 00       	call   f010653a <cpunum>
f0104a06:	83 ec 0c             	sub    $0xc,%esp
f0104a09:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a0c:	ff b0 28 a0 21 f0    	pushl  -0xfde5fd8(%eax)
f0104a12:	e8 83 ee ff ff       	call   f010389a <env_run>
	else
		sched_yield();
f0104a17:	e8 ee 01 00 00       	call   f0104c0a <sched_yield>

f0104a1c <TH_DIVIDE>:
	.p2align 2
	.globl TRAPHANDLERS
TRAPHANDLERS:
.text

TRAPHANDLER_NOEC(TH_DIVIDE, T_DIVIDE)	// fault
f0104a1c:	6a 00                	push   $0x0
f0104a1e:	6a 00                	push   $0x0
f0104a20:	e9 f9 00 00 00       	jmp    f0104b1e <_alltraps>
f0104a25:	90                   	nop

f0104a26 <TH_DEBUG>:
TRAPHANDLER_NOEC(TH_DEBUG, T_DEBUG)	// fault/trap
f0104a26:	6a 00                	push   $0x0
f0104a28:	6a 01                	push   $0x1
f0104a2a:	e9 ef 00 00 00       	jmp    f0104b1e <_alltraps>
f0104a2f:	90                   	nop

f0104a30 <TH_NMI>:
TRAPHANDLER_NOEC(TH_NMI, T_NMI)		//
f0104a30:	6a 00                	push   $0x0
f0104a32:	6a 02                	push   $0x2
f0104a34:	e9 e5 00 00 00       	jmp    f0104b1e <_alltraps>
f0104a39:	90                   	nop

f0104a3a <TH_BRKPT>:
TRAPHANDLER_NOEC(TH_BRKPT, T_BRKPT)	// trap
f0104a3a:	6a 00                	push   $0x0
f0104a3c:	6a 03                	push   $0x3
f0104a3e:	e9 db 00 00 00       	jmp    f0104b1e <_alltraps>
f0104a43:	90                   	nop

f0104a44 <TH_OFLOW>:
TRAPHANDLER_NOEC(TH_OFLOW, T_OFLOW)	// trap
f0104a44:	6a 00                	push   $0x0
f0104a46:	6a 04                	push   $0x4
f0104a48:	e9 d1 00 00 00       	jmp    f0104b1e <_alltraps>
f0104a4d:	90                   	nop

f0104a4e <TH_BOUND>:
TRAPHANDLER_NOEC(TH_BOUND, T_BOUND)	// fault
f0104a4e:	6a 00                	push   $0x0
f0104a50:	6a 05                	push   $0x5
f0104a52:	e9 c7 00 00 00       	jmp    f0104b1e <_alltraps>
f0104a57:	90                   	nop

f0104a58 <TH_ILLOP>:
TRAPHANDLER_NOEC(TH_ILLOP, T_ILLOP)	// fault
f0104a58:	6a 00                	push   $0x0
f0104a5a:	6a 06                	push   $0x6
f0104a5c:	e9 bd 00 00 00       	jmp    f0104b1e <_alltraps>
f0104a61:	90                   	nop

f0104a62 <TH_DEVICE>:
TRAPHANDLER_NOEC(TH_DEVICE, T_DEVICE)	// fault
f0104a62:	6a 00                	push   $0x0
f0104a64:	6a 07                	push   $0x7
f0104a66:	e9 b3 00 00 00       	jmp    f0104b1e <_alltraps>
f0104a6b:	90                   	nop

f0104a6c <TH_DBLFLT>:
TRAPHANDLER     (TH_DBLFLT, T_DBLFLT)	// abort
f0104a6c:	6a 08                	push   $0x8
f0104a6e:	e9 ab 00 00 00       	jmp    f0104b1e <_alltraps>
f0104a73:	90                   	nop

f0104a74 <TH_TSS>:
//TRAPHANDLER_NOEC(TH_COPROC, T_COPROC) // abort	
TRAPHANDLER     (TH_TSS, T_TSS)		// fault
f0104a74:	6a 0a                	push   $0xa
f0104a76:	e9 a3 00 00 00       	jmp    f0104b1e <_alltraps>
f0104a7b:	90                   	nop

f0104a7c <TH_SEGNP>:
TRAPHANDLER     (TH_SEGNP, T_SEGNP)	// fault
f0104a7c:	6a 0b                	push   $0xb
f0104a7e:	e9 9b 00 00 00       	jmp    f0104b1e <_alltraps>
f0104a83:	90                   	nop

f0104a84 <TH_STACK>:
TRAPHANDLER     (TH_STACK, T_STACK)	// fault
f0104a84:	6a 0c                	push   $0xc
f0104a86:	e9 93 00 00 00       	jmp    f0104b1e <_alltraps>
f0104a8b:	90                   	nop

f0104a8c <TH_GPFLT>:
TRAPHANDLER     (TH_GPFLT, T_GPFLT)	// fault/abort
f0104a8c:	6a 0d                	push   $0xd
f0104a8e:	e9 8b 00 00 00       	jmp    f0104b1e <_alltraps>
f0104a93:	90                   	nop

f0104a94 <TH_PGFLT>:
TRAPHANDLER     (TH_PGFLT, T_PGFLT)	// fault
f0104a94:	6a 0e                	push   $0xe
f0104a96:	e9 83 00 00 00       	jmp    f0104b1e <_alltraps>
f0104a9b:	90                   	nop

f0104a9c <TH_FPERR>:
//TRAPHANDLER_NOEC(TH_RES, T_RES)	
TRAPHANDLER_NOEC(TH_FPERR, T_FPERR)	// fault
f0104a9c:	6a 00                	push   $0x0
f0104a9e:	6a 10                	push   $0x10
f0104aa0:	eb 7c                	jmp    f0104b1e <_alltraps>

f0104aa2 <TH_ALIGN>:
TRAPHANDLER     (TH_ALIGN, T_ALIGN)	//
f0104aa2:	6a 11                	push   $0x11
f0104aa4:	eb 78                	jmp    f0104b1e <_alltraps>

f0104aa6 <TH_MCHK>:
TRAPHANDLER_NOEC(TH_MCHK, T_MCHK)	//
f0104aa6:	6a 00                	push   $0x0
f0104aa8:	6a 12                	push   $0x12
f0104aaa:	eb 72                	jmp    f0104b1e <_alltraps>

f0104aac <TH_SIMDERR>:
TRAPHANDLER_NOEC(TH_SIMDERR, T_SIMDERR) //
f0104aac:	6a 00                	push   $0x0
f0104aae:	6a 13                	push   $0x13
f0104ab0:	eb 6c                	jmp    f0104b1e <_alltraps>

f0104ab2 <TH_SYSCALL>:

TRAPHANDLER_NOEC(TH_SYSCALL, T_SYSCALL) // trap
f0104ab2:	6a 00                	push   $0x0
f0104ab4:	6a 30                	push   $0x30
f0104ab6:	eb 66                	jmp    f0104b1e <_alltraps>

f0104ab8 <TH_IRQ_TIMER>:

TRAPHANDLER_NOEC(TH_IRQ_TIMER, IRQ_OFFSET+IRQ_TIMER)	// 0
f0104ab8:	6a 00                	push   $0x0
f0104aba:	6a 20                	push   $0x20
f0104abc:	eb 60                	jmp    f0104b1e <_alltraps>

f0104abe <TH_IRQ_KBD>:
TRAPHANDLER_NOEC(TH_IRQ_KBD, IRQ_OFFSET+IRQ_KBD)	// 1
f0104abe:	6a 00                	push   $0x0
f0104ac0:	6a 21                	push   $0x21
f0104ac2:	eb 5a                	jmp    f0104b1e <_alltraps>

f0104ac4 <TH_IRQ_2>:
TRAPHANDLER_NOEC(TH_IRQ_2, IRQ_OFFSET+2)
f0104ac4:	6a 00                	push   $0x0
f0104ac6:	6a 22                	push   $0x22
f0104ac8:	eb 54                	jmp    f0104b1e <_alltraps>

f0104aca <TH_IRQ_3>:
TRAPHANDLER_NOEC(TH_IRQ_3, IRQ_OFFSET+3)
f0104aca:	6a 00                	push   $0x0
f0104acc:	6a 23                	push   $0x23
f0104ace:	eb 4e                	jmp    f0104b1e <_alltraps>

f0104ad0 <TH_IRQ_SERIAL>:
TRAPHANDLER_NOEC(TH_IRQ_SERIAL, IRQ_OFFSET+IRQ_SERIAL)	// 4
f0104ad0:	6a 00                	push   $0x0
f0104ad2:	6a 24                	push   $0x24
f0104ad4:	eb 48                	jmp    f0104b1e <_alltraps>

f0104ad6 <TH_IRQ_5>:
TRAPHANDLER_NOEC(TH_IRQ_5, IRQ_OFFSET+5)
f0104ad6:	6a 00                	push   $0x0
f0104ad8:	6a 25                	push   $0x25
f0104ada:	eb 42                	jmp    f0104b1e <_alltraps>

f0104adc <TH_IRQ_6>:
TRAPHANDLER_NOEC(TH_IRQ_6, IRQ_OFFSET+6)
f0104adc:	6a 00                	push   $0x0
f0104ade:	6a 26                	push   $0x26
f0104ae0:	eb 3c                	jmp    f0104b1e <_alltraps>

f0104ae2 <TH_IRQ_SPURIOUS>:
TRAPHANDLER_NOEC(TH_IRQ_SPURIOUS, IRQ_OFFSET+IRQ_SPURIOUS) // 7
f0104ae2:	6a 00                	push   $0x0
f0104ae4:	6a 27                	push   $0x27
f0104ae6:	eb 36                	jmp    f0104b1e <_alltraps>

f0104ae8 <TH_IRQ_8>:
TRAPHANDLER_NOEC(TH_IRQ_8, IRQ_OFFSET+8)
f0104ae8:	6a 00                	push   $0x0
f0104aea:	6a 28                	push   $0x28
f0104aec:	eb 30                	jmp    f0104b1e <_alltraps>

f0104aee <TH_IRQ_9>:
TRAPHANDLER_NOEC(TH_IRQ_9, IRQ_OFFSET+9)
f0104aee:	6a 00                	push   $0x0
f0104af0:	6a 29                	push   $0x29
f0104af2:	eb 2a                	jmp    f0104b1e <_alltraps>

f0104af4 <TH_IRQ_10>:
TRAPHANDLER_NOEC(TH_IRQ_10, IRQ_OFFSET+10)
f0104af4:	6a 00                	push   $0x0
f0104af6:	6a 2a                	push   $0x2a
f0104af8:	eb 24                	jmp    f0104b1e <_alltraps>

f0104afa <TH_IRQ_11>:
TRAPHANDLER_NOEC(TH_IRQ_11, IRQ_OFFSET+11)
f0104afa:	6a 00                	push   $0x0
f0104afc:	6a 2b                	push   $0x2b
f0104afe:	eb 1e                	jmp    f0104b1e <_alltraps>

f0104b00 <TH_IRQ_12>:
TRAPHANDLER_NOEC(TH_IRQ_12, IRQ_OFFSET+12)
f0104b00:	6a 00                	push   $0x0
f0104b02:	6a 2c                	push   $0x2c
f0104b04:	eb 18                	jmp    f0104b1e <_alltraps>

f0104b06 <TH_IRQ_13>:
TRAPHANDLER_NOEC(TH_IRQ_13, IRQ_OFFSET+13)
f0104b06:	6a 00                	push   $0x0
f0104b08:	6a 2d                	push   $0x2d
f0104b0a:	eb 12                	jmp    f0104b1e <_alltraps>

f0104b0c <TH_IRQ_IDE>:
TRAPHANDLER_NOEC(TH_IRQ_IDE, IRQ_OFFSET+IRQ_IDE)	// 14
f0104b0c:	6a 00                	push   $0x0
f0104b0e:	6a 2e                	push   $0x2e
f0104b10:	eb 0c                	jmp    f0104b1e <_alltraps>

f0104b12 <TH_IRQ_15>:
TRAPHANDLER_NOEC(TH_IRQ_15, IRQ_OFFSET+15)
f0104b12:	6a 00                	push   $0x0
f0104b14:	6a 2f                	push   $0x2f
f0104b16:	eb 06                	jmp    f0104b1e <_alltraps>

f0104b18 <TH_IRQ_ERROR>:
TRAPHANDLER_NOEC(TH_IRQ_ERROR, IRQ_OFFSET+IRQ_ERROR)	// 19
f0104b18:	6a 00                	push   $0x0
f0104b1a:	6a 33                	push   $0x33
f0104b1c:	eb 00                	jmp    f0104b1e <_alltraps>

f0104b1e <_alltraps>:
 * Lab 3: Your code here for _alltraps
 */

.text
_alltraps:
	pushl	%ds
f0104b1e:	1e                   	push   %ds
	pushl	%es
f0104b1f:	06                   	push   %es
	pushal
f0104b20:	60                   	pusha  
	mov	$GD_KD, %eax
f0104b21:	b8 10 00 00 00       	mov    $0x10,%eax
	mov	%ax, %es
f0104b26:	8e c0                	mov    %eax,%es
	mov	%ax, %ds
f0104b28:	8e d8                	mov    %eax,%ds
	pushl	%esp
f0104b2a:	54                   	push   %esp
	call	trap
f0104b2b:	e8 9a fc ff ff       	call   f01047ca <trap>

f0104b30 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104b30:	55                   	push   %ebp
f0104b31:	89 e5                	mov    %esp,%ebp
f0104b33:	83 ec 08             	sub    $0x8,%esp
f0104b36:	a1 4c 92 21 f0       	mov    0xf021924c,%eax
f0104b3b:	8d 90 b0 00 00 00    	lea    0xb0(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104b41:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104b46:	8b 02                	mov    (%edx),%eax
f0104b48:	83 e8 01             	sub    $0x1,%eax
f0104b4b:	83 f8 02             	cmp    $0x2,%eax
f0104b4e:	76 13                	jbe    f0104b63 <sched_halt+0x33>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104b50:	83 c1 01             	add    $0x1,%ecx
f0104b53:	81 c2 d8 00 00 00    	add    $0xd8,%edx
f0104b59:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104b5f:	75 e5                	jne    f0104b46 <sched_halt+0x16>
f0104b61:	eb 08                	jmp    f0104b6b <sched_halt+0x3b>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104b63:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104b69:	75 1f                	jne    f0104b8a <sched_halt+0x5a>
		cprintf("No runnable environments in the system!\n");
f0104b6b:	83 ec 0c             	sub    $0xc,%esp
f0104b6e:	68 50 84 10 f0       	push   $0xf0108450
f0104b73:	e8 10 f2 ff ff       	call   f0103d88 <cprintf>
f0104b78:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104b7b:	83 ec 0c             	sub    $0xc,%esp
f0104b7e:	6a 00                	push   $0x0
f0104b80:	e8 d0 bd ff ff       	call   f0100955 <monitor>
f0104b85:	83 c4 10             	add    $0x10,%esp
f0104b88:	eb f1                	jmp    f0104b7b <sched_halt+0x4b>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104b8a:	e8 ab 19 00 00       	call   f010653a <cpunum>
f0104b8f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b92:	c7 80 28 a0 21 f0 00 	movl   $0x0,-0xfde5fd8(%eax)
f0104b99:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104b9c:	a1 8c 9e 21 f0       	mov    0xf0219e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104ba1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104ba6:	77 12                	ja     f0104bba <sched_halt+0x8a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104ba8:	50                   	push   %eax
f0104ba9:	68 28 6c 10 f0       	push   $0xf0106c28
f0104bae:	6a 78                	push   $0x78
f0104bb0:	68 79 84 10 f0       	push   $0xf0108479
f0104bb5:	e8 86 b4 ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104bba:	05 00 00 00 10       	add    $0x10000000,%eax
f0104bbf:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104bc2:	e8 73 19 00 00       	call   f010653a <cpunum>
f0104bc7:	6b d0 74             	imul   $0x74,%eax,%edx
f0104bca:	81 c2 20 a0 21 f0    	add    $0xf021a020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104bd0:	b8 02 00 00 00       	mov    $0x2,%eax
f0104bd5:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104bd9:	83 ec 0c             	sub    $0xc,%esp
f0104bdc:	68 c0 23 12 f0       	push   $0xf01223c0
f0104be1:	e8 5f 1c 00 00       	call   f0106845 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104be6:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104be8:	e8 4d 19 00 00       	call   f010653a <cpunum>
f0104bed:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104bf0:	8b 80 30 a0 21 f0    	mov    -0xfde5fd0(%eax),%eax
f0104bf6:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104bfb:	89 c4                	mov    %eax,%esp
f0104bfd:	6a 00                	push   $0x0
f0104bff:	6a 00                	push   $0x0
f0104c01:	fb                   	sti    
f0104c02:	f4                   	hlt    
f0104c03:	eb fd                	jmp    f0104c02 <sched_halt+0xd2>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104c05:	83 c4 10             	add    $0x10,%esp
f0104c08:	c9                   	leave  
f0104c09:	c3                   	ret    

f0104c0a <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104c0a:	55                   	push   %ebp
f0104c0b:	89 e5                	mov    %esp,%ebp
f0104c0d:	53                   	push   %ebx
f0104c0e:	83 ec 10             	sub    $0x10,%esp
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	cprintf ("IN SCHED.C YIELDING\n\n");
f0104c11:	68 86 84 10 f0       	push   $0xf0108486
f0104c16:	e8 6d f1 ff ff       	call   f0103d88 <cprintf>
	size_t i;
	if (!curenv) {
f0104c1b:	e8 1a 19 00 00       	call   f010653a <cpunum>
f0104c20:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c23:	83 c4 10             	add    $0x10,%esp
		i = 0;
f0104c26:	ba 00 00 00 00       	mov    $0x0,%edx
	// below to halt the cpu.

	// LAB 4: Your code here.
	cprintf ("IN SCHED.C YIELDING\n\n");
	size_t i;
	if (!curenv) {
f0104c2b:	83 b8 28 a0 21 f0 00 	cmpl   $0x0,-0xfde5fd8(%eax)
f0104c32:	74 1d                	je     f0104c51 <sched_yield+0x47>
		i = 0;
	} else {
		i = ENVX(curenv->env_id) + 1;
f0104c34:	e8 01 19 00 00       	call   f010653a <cpunum>
f0104c39:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c3c:	8b 80 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%eax
f0104c42:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
f0104c48:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0104c4e:	83 c2 01             	add    $0x1,%edx
	}
	
	for (; i < NENV; i++) {
		if (envs[i].env_status == ENV_RUNNABLE) {
f0104c51:	a1 4c 92 21 f0       	mov    0xf021924c,%eax
f0104c56:	69 ca d8 00 00 00    	imul   $0xd8,%edx,%ecx
f0104c5c:	01 c1                	add    %eax,%ecx
f0104c5e:	eb 1a                	jmp    f0104c7a <sched_yield+0x70>
f0104c60:	89 cb                	mov    %ecx,%ebx
f0104c62:	81 c1 d8 00 00 00    	add    $0xd8,%ecx
f0104c68:	83 79 d8 02          	cmpl   $0x2,-0x28(%ecx)
f0104c6c:	75 09                	jne    f0104c77 <sched_yield+0x6d>
			env_run(&envs[i]);
f0104c6e:	83 ec 0c             	sub    $0xc,%esp
f0104c71:	53                   	push   %ebx
f0104c72:	e8 23 ec ff ff       	call   f010389a <env_run>
		i = 0;
	} else {
		i = ENVX(curenv->env_id) + 1;
	}
	
	for (; i < NENV; i++) {
f0104c77:	83 c2 01             	add    $0x1,%edx
f0104c7a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
f0104c80:	76 de                	jbe    f0104c60 <sched_yield+0x56>
f0104c82:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104c87:	eb 19                	jmp    f0104ca2 <sched_yield+0x98>
	}

	size_t j;

	for (j = 0; j < i; j++) {
		if (envs[j].env_status == ENV_RUNNABLE) {
f0104c89:	89 c3                	mov    %eax,%ebx
f0104c8b:	05 d8 00 00 00       	add    $0xd8,%eax
f0104c90:	83 78 d8 02          	cmpl   $0x2,-0x28(%eax)
f0104c94:	75 09                	jne    f0104c9f <sched_yield+0x95>
			env_run(&envs[j]);
f0104c96:	83 ec 0c             	sub    $0xc,%esp
f0104c99:	53                   	push   %ebx
f0104c9a:	e8 fb eb ff ff       	call   f010389a <env_run>
		} 
	}

	size_t j;

	for (j = 0; j < i; j++) {
f0104c9f:	83 c1 01             	add    $0x1,%ecx
f0104ca2:	39 ca                	cmp    %ecx,%edx
f0104ca4:	75 e3                	jne    f0104c89 <sched_yield+0x7f>
			} else {	// ak sa nejedna o main thread, kludne spusti
				env_run(&envs[j]);
			}
		} 
	}*/
	if (curenv && (curenv->env_status == ENV_RUNNING)) {
f0104ca6:	e8 8f 18 00 00       	call   f010653a <cpunum>
f0104cab:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cae:	83 b8 28 a0 21 f0 00 	cmpl   $0x0,-0xfde5fd8(%eax)
f0104cb5:	74 2d                	je     f0104ce4 <sched_yield+0xda>
f0104cb7:	e8 7e 18 00 00       	call   f010653a <cpunum>
f0104cbc:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cbf:	8b 80 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%eax
f0104cc5:	83 b8 b0 00 00 00 03 	cmpl   $0x3,0xb0(%eax)
f0104ccc:	75 16                	jne    f0104ce4 <sched_yield+0xda>
		env_run(curenv);
f0104cce:	e8 67 18 00 00       	call   f010653a <cpunum>
f0104cd3:	83 ec 0c             	sub    $0xc,%esp
f0104cd6:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cd9:	ff b0 28 a0 21 f0    	pushl  -0xfde5fd8(%eax)
f0104cdf:	e8 b6 eb ff ff       	call   f010389a <env_run>
	}
	// sched_halt never returns
	sched_halt();
f0104ce4:	e8 47 fe ff ff       	call   f0104b30 <sched_halt>
}
f0104ce9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104cec:	c9                   	leave  
f0104ced:	c3                   	ret    

f0104cee <sys_thread_create>:

// Lab 7 Multithreading 
// zavola tvorbu noveho threadu (z env.c)
envid_t	
sys_thread_create(uintptr_t func)
{
f0104cee:	55                   	push   %ebp
f0104cef:	89 e5                	mov    %esp,%ebp
f0104cf1:	53                   	push   %ebx
f0104cf2:	83 ec 0c             	sub    $0xc,%esp
f0104cf5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("in sys thread create, eip: %x\n", func);
f0104cf8:	53                   	push   %ebx
f0104cf9:	68 9c 84 10 f0       	push   $0xf010849c
f0104cfe:	e8 85 f0 ff ff       	call   f0103d88 <cprintf>

	envid_t id = thread_create(func);
f0104d03:	89 1c 24             	mov    %ebx,(%esp)
f0104d06:	e8 86 ed ff ff       	call   f0103a91 <thread_create>
	return id;
}	
f0104d0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104d0e:	c9                   	leave  
f0104d0f:	c3                   	ret    

f0104d10 <sys_thread_free>:


void 	
sys_thread_free(envid_t envid)
{
f0104d10:	55                   	push   %ebp
f0104d11:	89 e5                	mov    %esp,%ebp
f0104d13:	83 ec 1c             	sub    $0x1c,%esp
	struct Env* e;
	envid2env(envid, &e, 0);
f0104d16:	6a 00                	push   $0x0
f0104d18:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104d1b:	50                   	push   %eax
f0104d1c:	ff 75 08             	pushl  0x8(%ebp)
f0104d1f:	e8 9b e3 ff ff       	call   f01030bf <envid2env>
	thread_free(e);
f0104d24:	83 c4 04             	add    $0x4,%esp
f0104d27:	ff 75 f4             	pushl  -0xc(%ebp)
f0104d2a:	e8 63 ec ff ff       	call   f0103992 <thread_free>
}
f0104d2f:	83 c4 10             	add    $0x10,%esp
f0104d32:	c9                   	leave  
f0104d33:	c3                   	ret    

f0104d34 <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
f0104d34:	55                   	push   %ebp
f0104d35:	89 e5                	mov    %esp,%ebp
f0104d37:	83 ec 14             	sub    $0x14,%esp
	thread_join(envid);
f0104d3a:	ff 75 08             	pushl  0x8(%ebp)
f0104d3d:	e8 53 ee ff ff       	call   f0103b95 <thread_join>
}
f0104d42:	83 c4 10             	add    $0x10,%esp
f0104d45:	c9                   	leave  
f0104d46:	c3                   	ret    

f0104d47 <syscall>:

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104d47:	55                   	push   %ebp
f0104d48:	89 e5                	mov    %esp,%ebp
f0104d4a:	57                   	push   %edi
f0104d4b:	56                   	push   %esi
f0104d4c:	83 ec 10             	sub    $0x10,%esp
f0104d4f:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno) {
f0104d52:	83 f8 10             	cmp    $0x10,%eax
f0104d55:	0f 87 cc 06 00 00    	ja     f0105427 <syscall+0x6e0>
f0104d5b:	ff 24 85 f4 84 10 f0 	jmp    *-0xfef7b0c(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, PTE_U);
f0104d62:	e8 d3 17 00 00       	call   f010653a <cpunum>
f0104d67:	6a 04                	push   $0x4
f0104d69:	ff 75 10             	pushl  0x10(%ebp)
f0104d6c:	ff 75 0c             	pushl  0xc(%ebp)
f0104d6f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d72:	ff b0 28 a0 21 f0    	pushl  -0xfde5fd8(%eax)
f0104d78:	e8 38 e2 ff ff       	call   f0102fb5 <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104d7d:	83 c4 0c             	add    $0xc,%esp
f0104d80:	ff 75 0c             	pushl  0xc(%ebp)
f0104d83:	ff 75 10             	pushl  0x10(%ebp)
f0104d86:	68 bb 84 10 f0       	push   $0xf01084bb
f0104d8b:	e8 f8 ef ff ff       	call   f0103d88 <cprintf>
f0104d90:	83 c4 10             	add    $0x10,%esp
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((char*)a1, a2);
			return 0;
f0104d93:	b8 00 00 00 00       	mov    $0x0,%eax
f0104d98:	e9 96 06 00 00       	jmp    f0105433 <syscall+0x6ec>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104d9d:	e8 67 b8 ff ff       	call   f0100609 <cons_getc>
		case SYS_cputs:
			sys_cputs((char*)a1, a2);
			return 0;

		case SYS_cgetc:
			return sys_cgetc();
f0104da2:	e9 8c 06 00 00       	jmp    f0105433 <syscall+0x6ec>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104da7:	e8 8e 17 00 00       	call   f010653a <cpunum>
f0104dac:	6b c0 74             	imul   $0x74,%eax,%eax
f0104daf:	8b 80 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%eax
f0104db5:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax

		case SYS_cgetc:
			return sys_cgetc();

		case SYS_getenvid:
			return sys_getenvid();
f0104dbb:	e9 73 06 00 00       	jmp    f0105433 <syscall+0x6ec>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104dc0:	83 ec 04             	sub    $0x4,%esp
f0104dc3:	6a 01                	push   $0x1
f0104dc5:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104dc8:	50                   	push   %eax
f0104dc9:	ff 75 0c             	pushl  0xc(%ebp)
f0104dcc:	e8 ee e2 ff ff       	call   f01030bf <envid2env>
f0104dd1:	83 c4 10             	add    $0x10,%esp
f0104dd4:	85 c0                	test   %eax,%eax
f0104dd6:	0f 88 57 06 00 00    	js     f0105433 <syscall+0x6ec>
		return r;
	if (e == curenv)
f0104ddc:	e8 59 17 00 00       	call   f010653a <cpunum>
f0104de1:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104de4:	6b c0 74             	imul   $0x74,%eax,%eax
f0104de7:	39 90 28 a0 21 f0    	cmp    %edx,-0xfde5fd8(%eax)
f0104ded:	75 26                	jne    f0104e15 <syscall+0xce>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104def:	e8 46 17 00 00       	call   f010653a <cpunum>
f0104df4:	83 ec 08             	sub    $0x8,%esp
f0104df7:	6b c0 74             	imul   $0x74,%eax,%eax
f0104dfa:	8b 80 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%eax
f0104e00:	ff b0 a4 00 00 00    	pushl  0xa4(%eax)
f0104e06:	68 c0 84 10 f0       	push   $0xf01084c0
f0104e0b:	e8 78 ef ff ff       	call   f0103d88 <cprintf>
f0104e10:	83 c4 10             	add    $0x10,%esp
f0104e13:	eb 2b                	jmp    f0104e40 <syscall+0xf9>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104e15:	8b b2 a4 00 00 00    	mov    0xa4(%edx),%esi
f0104e1b:	e8 1a 17 00 00       	call   f010653a <cpunum>
f0104e20:	83 ec 04             	sub    $0x4,%esp
f0104e23:	56                   	push   %esi
f0104e24:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e27:	8b 80 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%eax
f0104e2d:	ff b0 a4 00 00 00    	pushl  0xa4(%eax)
f0104e33:	68 db 84 10 f0       	push   $0xf01084db
f0104e38:	e8 4b ef ff ff       	call   f0103d88 <cprintf>
f0104e3d:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104e40:	83 ec 0c             	sub    $0xc,%esp
f0104e43:	ff 75 f4             	pushl  -0xc(%ebp)
f0104e46:	e8 5c e9 ff ff       	call   f01037a7 <env_destroy>
f0104e4b:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104e4e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e53:	e9 db 05 00 00       	jmp    f0105433 <syscall+0x6ec>
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	// check if va is page aligned and isnt above UTOP
	if ((((int)va % PGSIZE) != 0) || ((uintptr_t)va >= UTOP)) {
f0104e58:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104e5f:	0f 85 87 00 00 00    	jne    f0104eec <syscall+0x1a5>
f0104e65:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104e6c:	77 7e                	ja     f0104eec <syscall+0x1a5>
		return -E_INVAL;
	}
	// check if PTE_P and PTE_U are set (must be set)
	if (((PTE_P | PTE_U) & perm) != (PTE_U | PTE_P)) { 
f0104e6e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e71:	83 e0 05             	and    $0x5,%eax
f0104e74:	83 f8 05             	cmp    $0x5,%eax
f0104e77:	75 7d                	jne    f0104ef6 <syscall+0x1af>
	}
	
	int to_check = perm | PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	int available_perm = PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	// check if no other bits hev bin(where the trash goes) set 
	if ((available_perm ^ to_check) != 0) {
f0104e79:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e7c:	0d 07 0e 00 00       	or     $0xe07,%eax
f0104e81:	3d 07 0e 00 00       	cmp    $0xe07,%eax
f0104e86:	75 78                	jne    f0104f00 <syscall+0x1b9>
		return -E_INVAL;
	}

	struct PageInfo *new_page = page_alloc(ALLOC_ZERO);
f0104e88:	83 ec 0c             	sub    $0xc,%esp
f0104e8b:	6a 01                	push   $0x1
f0104e8d:	e8 2a c1 ff ff       	call   f0100fbc <page_alloc>
f0104e92:	89 c6                	mov    %eax,%esi
	// page alloc return null if there are no free pages on page_free_list
	if (!new_page) {
f0104e94:	83 c4 10             	add    $0x10,%esp
f0104e97:	85 c0                	test   %eax,%eax
f0104e99:	74 6f                	je     f0104f0a <syscall+0x1c3>
		return -E_NO_MEM;
	}

	struct Env *e;
	int retperm = envid2env(envid, &e, true);
f0104e9b:	83 ec 04             	sub    $0x4,%esp
f0104e9e:	6a 01                	push   $0x1
f0104ea0:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104ea3:	50                   	push   %eax
f0104ea4:	ff 75 0c             	pushl  0xc(%ebp)
f0104ea7:	e8 13 e2 ff ff       	call   f01030bf <envid2env>

	//nechce sa mi uz
	if (retperm) {
f0104eac:	83 c4 10             	add    $0x10,%esp
f0104eaf:	85 c0                	test   %eax,%eax
f0104eb1:	0f 85 7c 05 00 00    	jne    f0105433 <syscall+0x6ec>
		return retperm;
	}	

	int pg_insert_check = page_insert(e->env_pgdir, new_page, va, perm);
f0104eb7:	ff 75 14             	pushl  0x14(%ebp)
f0104eba:	ff 75 10             	pushl  0x10(%ebp)
f0104ebd:	56                   	push   %esi
f0104ebe:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104ec1:	ff b0 bc 00 00 00    	pushl  0xbc(%eax)
f0104ec7:	e8 a1 c4 ff ff       	call   f010136d <page_insert>
f0104ecc:	89 c7                	mov    %eax,%edi
	
	if (pg_insert_check) {
f0104ece:	83 c4 10             	add    $0x10,%esp
f0104ed1:	85 c0                	test   %eax,%eax
f0104ed3:	0f 84 5a 05 00 00    	je     f0105433 <syscall+0x6ec>
		page_free(new_page);
f0104ed9:	83 ec 0c             	sub    $0xc,%esp
f0104edc:	56                   	push   %esi
f0104edd:	e8 4a c1 ff ff       	call   f010102c <page_free>
f0104ee2:	83 c4 10             	add    $0x10,%esp
		return pg_insert_check;
f0104ee5:	89 f8                	mov    %edi,%eax
f0104ee7:	e9 47 05 00 00       	jmp    f0105433 <syscall+0x6ec>
	//   allocated!

	// LAB 4: Your code here.
	// check if va is page aligned and isnt above UTOP
	if ((((int)va % PGSIZE) != 0) || ((uintptr_t)va >= UTOP)) {
		return -E_INVAL;
f0104eec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104ef1:	e9 3d 05 00 00       	jmp    f0105433 <syscall+0x6ec>
	}
	// check if PTE_P and PTE_U are set (must be set)
	if (((PTE_P | PTE_U) & perm) != (PTE_U | PTE_P)) { 
		return -E_INVAL;
f0104ef6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104efb:	e9 33 05 00 00       	jmp    f0105433 <syscall+0x6ec>
	
	int to_check = perm | PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	int available_perm = PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	// check if no other bits hev bin(where the trash goes) set 
	if ((available_perm ^ to_check) != 0) {
		return -E_INVAL;
f0104f00:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104f05:	e9 29 05 00 00       	jmp    f0105433 <syscall+0x6ec>
	}

	struct PageInfo *new_page = page_alloc(ALLOC_ZERO);
	// page alloc return null if there are no free pages on page_free_list
	if (!new_page) {
		return -E_NO_MEM;
f0104f0a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104f0f:	e9 1f 05 00 00       	jmp    f0105433 <syscall+0x6ec>
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.

	if ((((int)srcva % PGSIZE) != 0) || ((uintptr_t)srcva >= UTOP)) {
f0104f14:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104f1b:	0f 85 dd 00 00 00    	jne    f0104ffe <syscall+0x2b7>
f0104f21:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104f28:	0f 87 d0 00 00 00    	ja     f0104ffe <syscall+0x2b7>
		return -E_INVAL;
	}

	if ((((int)dstva % PGSIZE) != 0) || ((uintptr_t)dstva >= UTOP)) {
f0104f2e:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0104f35:	0f 85 cd 00 00 00    	jne    f0105008 <syscall+0x2c1>
f0104f3b:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104f42:	0f 87 c0 00 00 00    	ja     f0105008 <syscall+0x2c1>
		return -E_INVAL;
	}

	if (((PTE_P | PTE_U) & perm) != (PTE_U | PTE_P)) { 
f0104f48:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0104f4b:	83 e0 05             	and    $0x5,%eax
f0104f4e:	83 f8 05             	cmp    $0x5,%eax
f0104f51:	0f 85 bb 00 00 00    	jne    f0105012 <syscall+0x2cb>
	}
	
	int to_check = perm | PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	int available_perm = PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	// check if no other bits have been set 
	if ((available_perm ^ to_check) != 0) {
f0104f57:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0104f5a:	0d 07 0e 00 00       	or     $0xe07,%eax
f0104f5f:	3d 07 0e 00 00       	cmp    $0xe07,%eax
f0104f64:	0f 85 b2 00 00 00    	jne    f010501c <syscall+0x2d5>
		return -E_INVAL;
	}

	struct Env *srce;

	int retperm = envid2env(srcenvid, &srce, true);
f0104f6a:	83 ec 04             	sub    $0x4,%esp
f0104f6d:	6a 01                	push   $0x1
f0104f6f:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104f72:	50                   	push   %eax
f0104f73:	ff 75 0c             	pushl  0xc(%ebp)
f0104f76:	e8 44 e1 ff ff       	call   f01030bf <envid2env>
	
	if (retperm == -E_BAD_ENV) {
f0104f7b:	83 c4 10             	add    $0x10,%esp
f0104f7e:	83 f8 fe             	cmp    $0xfffffffe,%eax
f0104f81:	0f 84 9f 00 00 00    	je     f0105026 <syscall+0x2df>
		return -E_BAD_ENV;
	}

	struct Env *dste;

	int retperm2 = envid2env(dstenvid, &dste, true);
f0104f87:	83 ec 04             	sub    $0x4,%esp
f0104f8a:	6a 01                	push   $0x1
f0104f8c:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0104f8f:	50                   	push   %eax
f0104f90:	ff 75 14             	pushl  0x14(%ebp)
f0104f93:	e8 27 e1 ff ff       	call   f01030bf <envid2env>
	
	if (retperm2 == -E_BAD_ENV) {
f0104f98:	83 c4 10             	add    $0x10,%esp
f0104f9b:	83 f8 fe             	cmp    $0xfffffffe,%eax
f0104f9e:	0f 84 8c 00 00 00    	je     f0105030 <syscall+0x2e9>
		return -E_BAD_ENV;
	}

	pte_t *pte_store;
	struct PageInfo *p = page_lookup(srce->env_pgdir, srcva, &pte_store);
f0104fa4:	83 ec 04             	sub    $0x4,%esp
f0104fa7:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104faa:	50                   	push   %eax
f0104fab:	ff 75 10             	pushl  0x10(%ebp)
f0104fae:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104fb1:	ff b0 bc 00 00 00    	pushl  0xbc(%eax)
f0104fb7:	e8 84 c2 ff ff       	call   f0101240 <page_lookup>
	
	if (((perm & PTE_W) == PTE_W) && ((*pte_store & PTE_W) != PTE_W)) {
f0104fbc:	83 c4 10             	add    $0x10,%esp
f0104fbf:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104fc3:	74 08                	je     f0104fcd <syscall+0x286>
f0104fc5:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104fc8:	f6 02 02             	testb  $0x2,(%edx)
f0104fcb:	74 6d                	je     f010503a <syscall+0x2f3>
		return -E_INVAL;
	}

	if (!p) {
f0104fcd:	85 c0                	test   %eax,%eax
f0104fcf:	74 73                	je     f0105044 <syscall+0x2fd>
		return -E_INVAL;	
	}
	
	int pg_insert_check = page_insert(dste->env_pgdir, p, dstva, perm);
f0104fd1:	ff 75 1c             	pushl  0x1c(%ebp)
f0104fd4:	ff 75 18             	pushl  0x18(%ebp)
f0104fd7:	50                   	push   %eax
f0104fd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104fdb:	ff b0 bc 00 00 00    	pushl  0xbc(%eax)
f0104fe1:	e8 87 c3 ff ff       	call   f010136d <page_insert>
	
	if (pg_insert_check == -E_NO_MEM) {
f0104fe6:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
	}
	
	return 0;
f0104fe9:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0104fec:	0f 95 c0             	setne  %al
f0104fef:	0f b6 c0             	movzbl %al,%eax
f0104ff2:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
f0104ff9:	e9 35 04 00 00       	jmp    f0105433 <syscall+0x6ec>
	//   check the current permissions on the page.

	// LAB 4: Your code here.

	if ((((int)srcva % PGSIZE) != 0) || ((uintptr_t)srcva >= UTOP)) {
		return -E_INVAL;
f0104ffe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105003:	e9 2b 04 00 00       	jmp    f0105433 <syscall+0x6ec>
	}

	if ((((int)dstva % PGSIZE) != 0) || ((uintptr_t)dstva >= UTOP)) {
		return -E_INVAL;
f0105008:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010500d:	e9 21 04 00 00       	jmp    f0105433 <syscall+0x6ec>
	}

	if (((PTE_P | PTE_U) & perm) != (PTE_U | PTE_P)) { 
		return -E_INVAL;
f0105012:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105017:	e9 17 04 00 00       	jmp    f0105433 <syscall+0x6ec>
	
	int to_check = perm | PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	int available_perm = PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	// check if no other bits have been set 
	if ((available_perm ^ to_check) != 0) {
		return -E_INVAL;
f010501c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105021:	e9 0d 04 00 00       	jmp    f0105433 <syscall+0x6ec>
	struct Env *srce;

	int retperm = envid2env(srcenvid, &srce, true);
	
	if (retperm == -E_BAD_ENV) {
		return -E_BAD_ENV;
f0105026:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010502b:	e9 03 04 00 00       	jmp    f0105433 <syscall+0x6ec>
	struct Env *dste;

	int retperm2 = envid2env(dstenvid, &dste, true);
	
	if (retperm2 == -E_BAD_ENV) {
		return -E_BAD_ENV;
f0105030:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0105035:	e9 f9 03 00 00       	jmp    f0105433 <syscall+0x6ec>

	pte_t *pte_store;
	struct PageInfo *p = page_lookup(srce->env_pgdir, srcva, &pte_store);
	
	if (((perm & PTE_W) == PTE_W) && ((*pte_store & PTE_W) != PTE_W)) {
		return -E_INVAL;
f010503a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010503f:	e9 ef 03 00 00       	jmp    f0105433 <syscall+0x6ec>
	}

	if (!p) {
		return -E_INVAL;	
f0105044:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105049:	e9 e5 03 00 00       	jmp    f0105433 <syscall+0x6ec>
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if ((((int)va % PGSIZE) != 0) || ((uintptr_t)va >= UTOP)) {
f010504e:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0105055:	75 45                	jne    f010509c <syscall+0x355>
f0105057:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010505e:	77 3c                	ja     f010509c <syscall+0x355>
		return -E_INVAL;
	}
	
	struct Env *e;
	int perm = envid2env(envid, &e, true);
f0105060:	83 ec 04             	sub    $0x4,%esp
f0105063:	6a 01                	push   $0x1
f0105065:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0105068:	50                   	push   %eax
f0105069:	ff 75 0c             	pushl  0xc(%ebp)
f010506c:	e8 4e e0 ff ff       	call   f01030bf <envid2env>
f0105071:	89 c6                	mov    %eax,%esi
	
	if (perm) {
f0105073:	83 c4 10             	add    $0x10,%esp
f0105076:	85 c0                	test   %eax,%eax
f0105078:	0f 85 b5 03 00 00    	jne    f0105433 <syscall+0x6ec>
		return perm;
	}	
	
	page_remove(e->env_pgdir, va);
f010507e:	83 ec 08             	sub    $0x8,%esp
f0105081:	ff 75 10             	pushl  0x10(%ebp)
f0105084:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105087:	ff b0 bc 00 00 00    	pushl  0xbc(%eax)
f010508d:	e8 6d c2 ff ff       	call   f01012ff <page_remove>
f0105092:	83 c4 10             	add    $0x10,%esp

	return 0;
f0105095:	89 f0                	mov    %esi,%eax
f0105097:	e9 97 03 00 00       	jmp    f0105433 <syscall+0x6ec>
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if ((((int)va % PGSIZE) != 0) || ((uintptr_t)va >= UTOP)) {
		return -E_INVAL;
f010509c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01050a1:	e9 8d 03 00 00       	jmp    f0105433 <syscall+0x6ec>
	// It should be left as env_alloc created it, except that
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.
	struct Env *new_env;
	int env_state =	env_alloc(&new_env, curenv->env_id);
f01050a6:	e8 8f 14 00 00       	call   f010653a <cpunum>
f01050ab:	83 ec 08             	sub    $0x8,%esp
f01050ae:	6b c0 74             	imul   $0x74,%eax,%eax
f01050b1:	8b 80 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%eax
f01050b7:	ff b0 a4 00 00 00    	pushl  0xa4(%eax)
f01050bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01050c0:	50                   	push   %eax
f01050c1:	e8 69 e1 ff ff       	call   f010322f <env_alloc>

	if (env_state < 0) {
f01050c6:	83 c4 10             	add    $0x10,%esp
f01050c9:	85 c0                	test   %eax,%eax
f01050cb:	0f 88 62 03 00 00    	js     f0105433 <syscall+0x6ec>
		return env_state;
	}

	new_env->env_tf = curenv->env_tf;
f01050d1:	8b 7d f4             	mov    -0xc(%ebp),%edi
f01050d4:	e8 61 14 00 00       	call   f010653a <cpunum>
f01050d9:	6b c0 74             	imul   $0x74,%eax,%eax
f01050dc:	8b 90 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%edx
f01050e2:	8d 47 59             	lea    0x59(%edi),%eax
f01050e5:	8d 72 59             	lea    0x59(%edx),%esi
f01050e8:	8b 52 59             	mov    0x59(%edx),%edx
f01050eb:	89 57 59             	mov    %edx,0x59(%edi)
f01050ee:	8b 56 40             	mov    0x40(%esi),%edx
f01050f1:	89 97 99 00 00 00    	mov    %edx,0x99(%edi)
f01050f7:	83 c7 5d             	add    $0x5d,%edi
f01050fa:	83 e7 fc             	and    $0xfffffffc,%edi
f01050fd:	29 f8                	sub    %edi,%eax
f01050ff:	29 c6                	sub    %eax,%esi
f0105101:	8d 48 44             	lea    0x44(%eax),%ecx
f0105104:	c1 e9 02             	shr    $0x2,%ecx
f0105107:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	new_env->env_status = ENV_NOT_RUNNABLE;
f0105109:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010510c:	c7 80 b0 00 00 00 04 	movl   $0x4,0xb0(%eax)
f0105113:	00 00 00 
	new_env->env_tf.tf_regs.reg_eax = 0;
f0105116:	c7 40 75 00 00 00 00 	movl   $0x0,0x75(%eax)

	return new_env->env_id;
f010511d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
f0105123:	e9 0b 03 00 00       	jmp    f0105433 <syscall+0x6ec>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if ((status != ENV_RUNNABLE) && (status != ENV_NOT_RUNNABLE)) {
f0105128:	8b 45 10             	mov    0x10(%ebp),%eax
f010512b:	83 e8 02             	sub    $0x2,%eax
f010512e:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0105133:	75 31                	jne    f0105166 <syscall+0x41f>
		return -E_INVAL;
	}

	struct Env *e;

	int perm = envid2env(envid, &e, true); 
f0105135:	83 ec 04             	sub    $0x4,%esp
f0105138:	6a 01                	push   $0x1
f010513a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010513d:	50                   	push   %eax
f010513e:	ff 75 0c             	pushl  0xc(%ebp)
f0105141:	e8 79 df ff ff       	call   f01030bf <envid2env>
f0105146:	89 c2                	mov    %eax,%edx

	if (perm) {
f0105148:	83 c4 10             	add    $0x10,%esp
f010514b:	85 c0                	test   %eax,%eax
f010514d:	0f 85 e0 02 00 00    	jne    f0105433 <syscall+0x6ec>
		return perm;
	}	

	e->env_status = status;
f0105153:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105156:	8b 7d 10             	mov    0x10(%ebp),%edi
f0105159:	89 b8 b0 00 00 00    	mov    %edi,0xb0(%eax)

	return 0;
f010515f:	89 d0                	mov    %edx,%eax
f0105161:	e9 cd 02 00 00       	jmp    f0105433 <syscall+0x6ec>
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if ((status != ENV_RUNNABLE) && (status != ENV_NOT_RUNNABLE)) {
		return -E_INVAL;
f0105166:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010516b:	e9 c3 02 00 00       	jmp    f0105433 <syscall+0x6ec>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *e;

	int perm = envid2env(envid, &e, true); 
f0105170:	83 ec 04             	sub    $0x4,%esp
f0105173:	6a 01                	push   $0x1
f0105175:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0105178:	50                   	push   %eax
f0105179:	ff 75 0c             	pushl  0xc(%ebp)
f010517c:	e8 3e df ff ff       	call   f01030bf <envid2env>

	if (perm) {
f0105181:	83 c4 10             	add    $0x10,%esp
f0105184:	85 c0                	test   %eax,%eax
f0105186:	0f 85 a7 02 00 00    	jne    f0105433 <syscall+0x6ec>
		return perm;
	}
	
	e->env_pgfault_upcall = func;
f010518c:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010518f:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0105192:	89 8a c0 00 00 00    	mov    %ecx,0xc0(%edx)

		case SYS_env_set_status:
			return sys_env_set_status(a1, a2);

		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1, (void*)a2);
f0105198:	e9 96 02 00 00       	jmp    f0105433 <syscall+0x6ec>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f010519d:	e8 68 fa ff ff       	call   f0104c0a <sched_yield>
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.

	struct Env *e;
	int env = envid2env(envid, &e, false);
f01051a2:	83 ec 04             	sub    $0x4,%esp
f01051a5:	6a 00                	push   $0x0
f01051a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
f01051aa:	50                   	push   %eax
f01051ab:	ff 75 0c             	pushl  0xc(%ebp)
f01051ae:	e8 0c df ff ff       	call   f01030bf <envid2env>
	
	if (env < 0) {
f01051b3:	83 c4 10             	add    $0x10,%esp
f01051b6:	85 c0                	test   %eax,%eax
f01051b8:	79 08                	jns    f01051c2 <syscall+0x47b>
		return perm;
f01051ba:	8b 45 18             	mov    0x18(%ebp),%eax
f01051bd:	e9 71 02 00 00       	jmp    f0105433 <syscall+0x6ec>
	}
	
	if (!e->env_ipc_recving) {
f01051c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01051c5:	80 b8 c4 00 00 00 00 	cmpb   $0x0,0xc4(%eax)
f01051cc:	0f 84 1e 01 00 00    	je     f01052f0 <syscall+0x5a9>
		return -E_IPC_NOT_RECV;
	}

	e->env_ipc_perm = 0;
f01051d2:	c7 80 d4 00 00 00 00 	movl   $0x0,0xd4(%eax)
f01051d9:	00 00 00 

	if ((uint32_t)srcva < UTOP) {
f01051dc:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f01051e3:	0f 87 bc 00 00 00    	ja     f01052a5 <syscall+0x55e>
		if (ROUNDDOWN((uint32_t)srcva,PGSIZE) != (uint32_t)srcva) {
			return -E_INVAL;
f01051e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}

	e->env_ipc_perm = 0;

	if ((uint32_t)srcva < UTOP) {
		if (ROUNDDOWN((uint32_t)srcva,PGSIZE) != (uint32_t)srcva) {
f01051ee:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f01051f5:	0f 85 38 02 00 00    	jne    f0105433 <syscall+0x6ec>
			return -E_INVAL;
		}

		if (((PTE_P | PTE_U) & perm) != (PTE_U | PTE_P)) { 
f01051fb:	8b 55 18             	mov    0x18(%ebp),%edx
f01051fe:	83 e2 05             	and    $0x5,%edx
f0105201:	83 fa 05             	cmp    $0x5,%edx
f0105204:	0f 85 29 02 00 00    	jne    f0105433 <syscall+0x6ec>
		}
	
		int to_check = perm | PTE_P | PTE_W | PTE_U | PTE_AVAIL;
		int available_perm = PTE_P | PTE_W | PTE_U | PTE_AVAIL;
		// check if no other bits have been set 
		if ((available_perm ^ to_check) != 0) {
f010520a:	8b 55 18             	mov    0x18(%ebp),%edx
f010520d:	81 ca 07 0e 00 00    	or     $0xe07,%edx
f0105213:	81 fa 07 0e 00 00    	cmp    $0xe07,%edx
f0105219:	0f 85 14 02 00 00    	jne    f0105433 <syscall+0x6ec>
			return -E_INVAL;
		}

		pte_t *pte_store;
		struct PageInfo *p = page_lookup(curenv->env_pgdir, srcva, 							 &pte_store);
f010521f:	e8 16 13 00 00       	call   f010653a <cpunum>
f0105224:	83 ec 04             	sub    $0x4,%esp
f0105227:	8d 55 f4             	lea    -0xc(%ebp),%edx
f010522a:	52                   	push   %edx
f010522b:	ff 75 14             	pushl  0x14(%ebp)
f010522e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105231:	8b 80 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%eax
f0105237:	ff b0 bc 00 00 00    	pushl  0xbc(%eax)
f010523d:	e8 fe bf ff ff       	call   f0101240 <page_lookup>
f0105242:	89 c1                	mov    %eax,%ecx
	
		if (((perm & PTE_W) == PTE_W) && ((*pte_store & PTE_W) != PTE_W)) {
f0105244:	83 c4 10             	add    $0x10,%esp
f0105247:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f010524b:	74 11                	je     f010525e <syscall+0x517>
			return -E_INVAL;
f010524d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}

		pte_t *pte_store;
		struct PageInfo *p = page_lookup(curenv->env_pgdir, srcva, 							 &pte_store);
	
		if (((perm & PTE_W) == PTE_W) && ((*pte_store & PTE_W) != PTE_W)) {
f0105252:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0105255:	f6 02 02             	testb  $0x2,(%edx)
f0105258:	0f 84 d5 01 00 00    	je     f0105433 <syscall+0x6ec>
			return -E_INVAL;
		}

		if (!p) {
f010525e:	85 c9                	test   %ecx,%ecx
f0105260:	74 39                	je     f010529b <syscall+0x554>
			return -E_INVAL;	
		}

		if ((uint32_t)e->env_ipc_dstva < UTOP){
f0105262:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0105265:	8b 82 c8 00 00 00    	mov    0xc8(%edx),%eax
f010526b:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f0105270:	77 33                	ja     f01052a5 <syscall+0x55e>
			int pg_insert_check = page_insert(e->env_pgdir, p,
f0105272:	ff 75 18             	pushl  0x18(%ebp)
f0105275:	50                   	push   %eax
f0105276:	51                   	push   %ecx
f0105277:	ff b2 bc 00 00 00    	pushl  0xbc(%edx)
f010527d:	e8 eb c0 ff ff       	call   f010136d <page_insert>
	 				          e->env_ipc_dstva, perm);
	
			if (pg_insert_check < 0) {
f0105282:	83 c4 10             	add    $0x10,%esp
f0105285:	85 c0                	test   %eax,%eax
f0105287:	0f 88 a6 01 00 00    	js     f0105433 <syscall+0x6ec>
				return pg_insert_check;
			}

			e->env_ipc_perm = perm;
f010528d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105290:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0105293:	89 88 d4 00 00 00    	mov    %ecx,0xd4(%eax)
f0105299:	eb 0a                	jmp    f01052a5 <syscall+0x55e>
		if (((perm & PTE_W) == PTE_W) && ((*pte_store & PTE_W) != PTE_W)) {
			return -E_INVAL;
		}

		if (!p) {
			return -E_INVAL;	
f010529b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01052a0:	e9 8e 01 00 00       	jmp    f0105433 <syscall+0x6ec>

			e->env_ipc_perm = perm;
		}
	}

	e->env_ipc_recving = false;
f01052a5:	8b 75 f0             	mov    -0x10(%ebp),%esi
f01052a8:	c6 86 c4 00 00 00 00 	movb   $0x0,0xc4(%esi)
	e->env_ipc_from = curenv->env_id;
f01052af:	e8 86 12 00 00       	call   f010653a <cpunum>
f01052b4:	6b c0 74             	imul   $0x74,%eax,%eax
f01052b7:	8b 80 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%eax
f01052bd:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
f01052c3:	89 86 d0 00 00 00    	mov    %eax,0xd0(%esi)
	e->env_ipc_value = value;
f01052c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01052cc:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01052cf:	89 88 cc 00 00 00    	mov    %ecx,0xcc(%eax)
	e->env_status = ENV_RUNNABLE;
f01052d5:	c7 80 b0 00 00 00 02 	movl   $0x2,0xb0(%eax)
f01052dc:	00 00 00 
	e->env_tf.tf_regs.reg_eax = 0;
f01052df:	c7 40 75 00 00 00 00 	movl   $0x0,0x75(%eax)

	return 0;
f01052e6:	b8 00 00 00 00       	mov    $0x0,%eax
f01052eb:	e9 43 01 00 00       	jmp    f0105433 <syscall+0x6ec>
	if (env < 0) {
		return perm;
	}
	
	if (!e->env_ipc_recving) {
		return -E_IPC_NOT_RECV;
f01052f0:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
		case SYS_yield:
			sys_yield();
			return 0;

		case SYS_ipc_try_send:
			return sys_ipc_try_send(a1, a2, (void*)a3, a4);
f01052f5:	e9 39 01 00 00       	jmp    f0105433 <syscall+0x6ec>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if ((uint32_t)dstva < UTOP) {
f01052fa:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0105301:	77 0d                	ja     f0105310 <syscall+0x5c9>
		if (ROUNDDOWN((uint32_t)dstva, PGSIZE) != (uint32_t)dstva) {
f0105303:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f010530a:	0f 85 1e 01 00 00    	jne    f010542e <syscall+0x6e7>
			return -E_INVAL;
		}
	}
	curenv->env_ipc_recving = true;	
f0105310:	e8 25 12 00 00       	call   f010653a <cpunum>
f0105315:	6b c0 74             	imul   $0x74,%eax,%eax
f0105318:	8b 80 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%eax
f010531e:	c6 80 c4 00 00 00 01 	movb   $0x1,0xc4(%eax)
	curenv->env_ipc_dstva = dstva;
f0105325:	e8 10 12 00 00       	call   f010653a <cpunum>
f010532a:	6b c0 74             	imul   $0x74,%eax,%eax
f010532d:	8b 80 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%eax
f0105333:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105336:	89 88 c8 00 00 00    	mov    %ecx,0xc8(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f010533c:	e8 f9 11 00 00       	call   f010653a <cpunum>
f0105341:	6b c0 74             	imul   $0x74,%eax,%eax
f0105344:	8b 80 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%eax
f010534a:	c7 80 b0 00 00 00 04 	movl   $0x4,0xb0(%eax)
f0105351:	00 00 00 
	curenv->env_tf.tf_regs.reg_eax = 0;
f0105354:	e8 e1 11 00 00       	call   f010653a <cpunum>
f0105359:	6b c0 74             	imul   $0x74,%eax,%eax
f010535c:	8b 80 28 a0 21 f0    	mov    -0xfde5fd8(%eax),%eax
f0105362:	c7 40 75 00 00 00 00 	movl   $0x0,0x75(%eax)

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0105369:	e8 9c f8 ff ff       	call   f0104c0a <sched_yield>
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!

	struct Env *e; 
	int env = envid2env(envid, &e, 1);
f010536e:	83 ec 04             	sub    $0x4,%esp
f0105371:	6a 01                	push   $0x1
f0105373:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0105376:	50                   	push   %eax
f0105377:	ff 75 0c             	pushl  0xc(%ebp)
f010537a:	e8 40 dd ff ff       	call   f01030bf <envid2env>

	if (env < 0) { 
f010537f:	83 c4 10             	add    $0x10,%esp
f0105382:	85 c0                	test   %eax,%eax
f0105384:	0f 88 a9 00 00 00    	js     f0105433 <syscall+0x6ec>
		return env;
	}

	user_mem_assert(e, tf, sizeof(struct Trapframe), PTE_U);
f010538a:	6a 04                	push   $0x4
f010538c:	6a 44                	push   $0x44
f010538e:	ff 75 10             	pushl  0x10(%ebp)
f0105391:	ff 75 f4             	pushl  -0xc(%ebp)
f0105394:	e8 1c dc ff ff       	call   f0102fb5 <user_mem_assert>

	e->env_tf = *tf;
f0105399:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010539c:	8d 42 59             	lea    0x59(%edx),%eax
f010539f:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01053a2:	8b 09                	mov    (%ecx),%ecx
f01053a4:	89 4a 59             	mov    %ecx,0x59(%edx)
f01053a7:	8b 7d 10             	mov    0x10(%ebp),%edi
f01053aa:	8b 4f 40             	mov    0x40(%edi),%ecx
f01053ad:	89 8a 99 00 00 00    	mov    %ecx,0x99(%edx)
f01053b3:	8d 7a 5d             	lea    0x5d(%edx),%edi
f01053b6:	83 e7 fc             	and    $0xfffffffc,%edi
f01053b9:	29 f8                	sub    %edi,%eax
f01053bb:	8b 75 10             	mov    0x10(%ebp),%esi
f01053be:	29 c6                	sub    %eax,%esi
f01053c0:	8d 48 44             	lea    0x44(%eax),%ecx
f01053c3:	c1 e9 02             	shr    $0x2,%ecx
f01053c6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_tf.tf_eflags |= FL_IF;
	e->env_tf.tf_cs = GD_UT | 3;
f01053c8:	66 c7 82 8d 00 00 00 	movw   $0x1b,0x8d(%edx)
f01053cf:	1b 00 
	//shoutout to fgt(x)
	e->env_tf.tf_eflags &= ~FL_IOPL_3;
f01053d1:	8b 82 91 00 00 00    	mov    0x91(%edx),%eax
f01053d7:	80 e4 cf             	and    $0xcf,%ah
f01053da:	80 cc 02             	or     $0x2,%ah
f01053dd:	89 82 91 00 00 00    	mov    %eax,0x91(%edx)
f01053e3:	83 c4 10             	add    $0x10,%esp

	return 0;
f01053e6:	b8 00 00 00 00       	mov    $0x0,%eax
f01053eb:	eb 46                	jmp    f0105433 <syscall+0x6ec>
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe(a1, (struct Trapframe*)a2);

		// LAB 7 Multithreading
		case SYS_thread_create:
			return sys_thread_create((uintptr_t) a1);
f01053ed:	83 ec 0c             	sub    $0xc,%esp
f01053f0:	ff 75 0c             	pushl  0xc(%ebp)
f01053f3:	e8 f6 f8 ff ff       	call   f0104cee <sys_thread_create>
f01053f8:	83 c4 10             	add    $0x10,%esp
f01053fb:	eb 36                	jmp    f0105433 <syscall+0x6ec>

		case SYS_thread_free:
			sys_thread_free((envid_t)a1);
f01053fd:	83 ec 0c             	sub    $0xc,%esp
f0105400:	ff 75 0c             	pushl  0xc(%ebp)
f0105403:	e8 08 f9 ff ff       	call   f0104d10 <sys_thread_free>
			return 0;
f0105408:	83 c4 10             	add    $0x10,%esp
f010540b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105410:	eb 21                	jmp    f0105433 <syscall+0x6ec>
}

void 	
sys_thread_join(envid_t envid) 
{
	thread_join(envid);
f0105412:	83 ec 0c             	sub    $0xc,%esp
f0105415:	ff 75 0c             	pushl  0xc(%ebp)
f0105418:	e8 78 e7 ff ff       	call   f0103b95 <thread_join>
f010541d:	83 c4 10             	add    $0x10,%esp
			sys_thread_free((envid_t)a1);
			return 0;

		case SYS_thread_join:
			sys_thread_join((envid_t)a1);
			return 0;
f0105420:	b8 00 00 00 00       	mov    $0x0,%eax
f0105425:	eb 0c                	jmp    f0105433 <syscall+0x6ec>

		default:
			return -E_INVAL;
f0105427:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010542c:	eb 05                	jmp    f0105433 <syscall+0x6ec>

		case SYS_ipc_try_send:
			return sys_ipc_try_send(a1, a2, (void*)a3, a4);

		case SYS_ipc_recv:
			return sys_ipc_recv((void*)a1);
f010542e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			return 0;

		default:
			return -E_INVAL;
	}
}
f0105433:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105436:	5e                   	pop    %esi
f0105437:	5f                   	pop    %edi
f0105438:	5d                   	pop    %ebp
f0105439:	c3                   	ret    

f010543a <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010543a:	55                   	push   %ebp
f010543b:	89 e5                	mov    %esp,%ebp
f010543d:	57                   	push   %edi
f010543e:	56                   	push   %esi
f010543f:	53                   	push   %ebx
f0105440:	83 ec 14             	sub    $0x14,%esp
f0105443:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105446:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0105449:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010544c:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f010544f:	8b 1a                	mov    (%edx),%ebx
f0105451:	8b 01                	mov    (%ecx),%eax
f0105453:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105456:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f010545d:	eb 7f                	jmp    f01054de <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f010545f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105462:	01 d8                	add    %ebx,%eax
f0105464:	89 c6                	mov    %eax,%esi
f0105466:	c1 ee 1f             	shr    $0x1f,%esi
f0105469:	01 c6                	add    %eax,%esi
f010546b:	d1 fe                	sar    %esi
f010546d:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0105470:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105473:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0105476:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105478:	eb 03                	jmp    f010547d <stab_binsearch+0x43>
			m--;
f010547a:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010547d:	39 c3                	cmp    %eax,%ebx
f010547f:	7f 0d                	jg     f010548e <stab_binsearch+0x54>
f0105481:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0105485:	83 ea 0c             	sub    $0xc,%edx
f0105488:	39 f9                	cmp    %edi,%ecx
f010548a:	75 ee                	jne    f010547a <stab_binsearch+0x40>
f010548c:	eb 05                	jmp    f0105493 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010548e:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0105491:	eb 4b                	jmp    f01054de <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0105493:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105496:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105499:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010549d:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01054a0:	76 11                	jbe    f01054b3 <stab_binsearch+0x79>
			*region_left = m;
f01054a2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01054a5:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01054a7:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01054aa:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01054b1:	eb 2b                	jmp    f01054de <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01054b3:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01054b6:	73 14                	jae    f01054cc <stab_binsearch+0x92>
			*region_right = m - 1;
f01054b8:	83 e8 01             	sub    $0x1,%eax
f01054bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01054be:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01054c1:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01054c3:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01054ca:	eb 12                	jmp    f01054de <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01054cc:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01054cf:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f01054d1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01054d5:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01054d7:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01054de:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01054e1:	0f 8e 78 ff ff ff    	jle    f010545f <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01054e7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01054eb:	75 0f                	jne    f01054fc <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f01054ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01054f0:	8b 00                	mov    (%eax),%eax
f01054f2:	83 e8 01             	sub    $0x1,%eax
f01054f5:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01054f8:	89 06                	mov    %eax,(%esi)
f01054fa:	eb 2c                	jmp    f0105528 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01054fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01054ff:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0105501:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105504:	8b 0e                	mov    (%esi),%ecx
f0105506:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105509:	8b 75 ec             	mov    -0x14(%ebp),%esi
f010550c:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010550f:	eb 03                	jmp    f0105514 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0105511:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105514:	39 c8                	cmp    %ecx,%eax
f0105516:	7e 0b                	jle    f0105523 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0105518:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f010551c:	83 ea 0c             	sub    $0xc,%edx
f010551f:	39 df                	cmp    %ebx,%edi
f0105521:	75 ee                	jne    f0105511 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0105523:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105526:	89 06                	mov    %eax,(%esi)
	}
}
f0105528:	83 c4 14             	add    $0x14,%esp
f010552b:	5b                   	pop    %ebx
f010552c:	5e                   	pop    %esi
f010552d:	5f                   	pop    %edi
f010552e:	5d                   	pop    %ebp
f010552f:	c3                   	ret    

f0105530 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0105530:	55                   	push   %ebp
f0105531:	89 e5                	mov    %esp,%ebp
f0105533:	57                   	push   %edi
f0105534:	56                   	push   %esi
f0105535:	53                   	push   %ebx
f0105536:	83 ec 3c             	sub    $0x3c,%esp
f0105539:	8b 75 08             	mov    0x8(%ebp),%esi
f010553c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010553f:	c7 03 38 85 10 f0    	movl   $0xf0108538,(%ebx)
	info->eip_line = 0;
f0105545:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f010554c:	c7 43 08 38 85 10 f0 	movl   $0xf0108538,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0105553:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010555a:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010555d:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0105564:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010556a:	77 21                	ja     f010558d <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f010556c:	a1 00 00 20 00       	mov    0x200000,%eax
f0105571:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stab_end = usd->stab_end;
f0105574:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0105579:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f010557f:	89 7d b8             	mov    %edi,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0105582:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f0105588:	89 7d c0             	mov    %edi,-0x40(%ebp)
f010558b:	eb 1a                	jmp    f01055a7 <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f010558d:	c7 45 c0 2a 79 11 f0 	movl   $0xf011792a,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0105594:	c7 45 b8 d5 37 11 f0 	movl   $0xf01137d5,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f010559b:	b8 d4 37 11 f0       	mov    $0xf01137d4,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01055a0:	c7 45 bc d0 8a 10 f0 	movl   $0xf0108ad0,-0x44(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01055a7:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01055aa:	39 7d b8             	cmp    %edi,-0x48(%ebp)
f01055ad:	0f 83 95 01 00 00    	jae    f0105748 <debuginfo_eip+0x218>
f01055b3:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f01055b7:	0f 85 92 01 00 00    	jne    f010574f <debuginfo_eip+0x21f>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01055bd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01055c4:	8b 7d bc             	mov    -0x44(%ebp),%edi
f01055c7:	29 f8                	sub    %edi,%eax
f01055c9:	c1 f8 02             	sar    $0x2,%eax
f01055cc:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01055d2:	83 e8 01             	sub    $0x1,%eax
f01055d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01055d8:	56                   	push   %esi
f01055d9:	6a 64                	push   $0x64
f01055db:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01055de:	89 c1                	mov    %eax,%ecx
f01055e0:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01055e3:	89 f8                	mov    %edi,%eax
f01055e5:	e8 50 fe ff ff       	call   f010543a <stab_binsearch>
	if (lfile == 0)
f01055ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01055ed:	83 c4 08             	add    $0x8,%esp
f01055f0:	85 c0                	test   %eax,%eax
f01055f2:	0f 84 5e 01 00 00    	je     f0105756 <debuginfo_eip+0x226>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01055f8:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01055fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01055fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105601:	56                   	push   %esi
f0105602:	6a 24                	push   $0x24
f0105604:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0105607:	89 c1                	mov    %eax,%ecx
f0105609:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010560c:	89 f8                	mov    %edi,%eax
f010560e:	e8 27 fe ff ff       	call   f010543a <stab_binsearch>

	if (lfun <= rfun) {
f0105613:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105616:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105619:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f010561c:	83 c4 08             	add    $0x8,%esp
f010561f:	39 d0                	cmp    %edx,%eax
f0105621:	7f 2b                	jg     f010564e <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105623:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105626:	8d 0c 97             	lea    (%edi,%edx,4),%ecx
f0105629:	8b 11                	mov    (%ecx),%edx
f010562b:	8b 7d c0             	mov    -0x40(%ebp),%edi
f010562e:	2b 7d b8             	sub    -0x48(%ebp),%edi
f0105631:	39 fa                	cmp    %edi,%edx
f0105633:	73 06                	jae    f010563b <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105635:	03 55 b8             	add    -0x48(%ebp),%edx
f0105638:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010563b:	8b 51 08             	mov    0x8(%ecx),%edx
f010563e:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0105641:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0105643:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0105646:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105649:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010564c:	eb 0f                	jmp    f010565d <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f010564e:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0105651:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105654:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105657:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010565a:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010565d:	83 ec 08             	sub    $0x8,%esp
f0105660:	6a 3a                	push   $0x3a
f0105662:	ff 73 08             	pushl  0x8(%ebx)
f0105665:	e8 92 08 00 00       	call   f0105efc <strfind>
f010566a:	2b 43 08             	sub    0x8(%ebx),%eax
f010566d:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0105670:	83 c4 08             	add    $0x8,%esp
f0105673:	56                   	push   %esi
f0105674:	6a 44                	push   $0x44
f0105676:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0105679:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010567c:	8b 75 bc             	mov    -0x44(%ebp),%esi
f010567f:	89 f0                	mov    %esi,%eax
f0105681:	e8 b4 fd ff ff       	call   f010543a <stab_binsearch>
	if (lline == rline) {
f0105686:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105689:	83 c4 10             	add    $0x10,%esp
f010568c:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f010568f:	0f 85 c8 00 00 00    	jne    f010575d <debuginfo_eip+0x22d>
		info->eip_line = stabs[lline].n_desc;
f0105695:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105698:	8d 14 96             	lea    (%esi,%edx,4),%edx
f010569b:	0f b7 4a 06          	movzwl 0x6(%edx),%ecx
f010569f:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01056a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01056a5:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f01056a9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01056ac:	eb 0a                	jmp    f01056b8 <debuginfo_eip+0x188>
f01056ae:	83 e8 01             	sub    $0x1,%eax
f01056b1:	83 ea 0c             	sub    $0xc,%edx
f01056b4:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f01056b8:	39 c7                	cmp    %eax,%edi
f01056ba:	7e 05                	jle    f01056c1 <debuginfo_eip+0x191>
f01056bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01056bf:	eb 47                	jmp    f0105708 <debuginfo_eip+0x1d8>
	       && stabs[lline].n_type != N_SOL
f01056c1:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01056c5:	80 f9 84             	cmp    $0x84,%cl
f01056c8:	75 0e                	jne    f01056d8 <debuginfo_eip+0x1a8>
f01056ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01056cd:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f01056d1:	74 1c                	je     f01056ef <debuginfo_eip+0x1bf>
f01056d3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01056d6:	eb 17                	jmp    f01056ef <debuginfo_eip+0x1bf>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01056d8:	80 f9 64             	cmp    $0x64,%cl
f01056db:	75 d1                	jne    f01056ae <debuginfo_eip+0x17e>
f01056dd:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f01056e1:	74 cb                	je     f01056ae <debuginfo_eip+0x17e>
f01056e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01056e6:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f01056ea:	74 03                	je     f01056ef <debuginfo_eip+0x1bf>
f01056ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01056ef:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01056f2:	8b 75 bc             	mov    -0x44(%ebp),%esi
f01056f5:	8b 14 86             	mov    (%esi,%eax,4),%edx
f01056f8:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01056fb:	8b 75 b8             	mov    -0x48(%ebp),%esi
f01056fe:	29 f0                	sub    %esi,%eax
f0105700:	39 c2                	cmp    %eax,%edx
f0105702:	73 04                	jae    f0105708 <debuginfo_eip+0x1d8>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105704:	01 f2                	add    %esi,%edx
f0105706:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105708:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010570b:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010570e:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105713:	39 f2                	cmp    %esi,%edx
f0105715:	7d 52                	jge    f0105769 <debuginfo_eip+0x239>
		for (lline = lfun + 1;
f0105717:	83 c2 01             	add    $0x1,%edx
f010571a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010571d:	89 d0                	mov    %edx,%eax
f010571f:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0105722:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0105725:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0105728:	eb 04                	jmp    f010572e <debuginfo_eip+0x1fe>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f010572a:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f010572e:	39 c6                	cmp    %eax,%esi
f0105730:	7e 32                	jle    f0105764 <debuginfo_eip+0x234>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105732:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0105736:	83 c0 01             	add    $0x1,%eax
f0105739:	83 c2 0c             	add    $0xc,%edx
f010573c:	80 f9 a0             	cmp    $0xa0,%cl
f010573f:	74 e9                	je     f010572a <debuginfo_eip+0x1fa>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105741:	b8 00 00 00 00       	mov    $0x0,%eax
f0105746:	eb 21                	jmp    f0105769 <debuginfo_eip+0x239>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0105748:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010574d:	eb 1a                	jmp    f0105769 <debuginfo_eip+0x239>
f010574f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105754:	eb 13                	jmp    f0105769 <debuginfo_eip+0x239>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0105756:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010575b:	eb 0c                	jmp    f0105769 <debuginfo_eip+0x239>
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline == rline) {
		info->eip_line = stabs[lline].n_desc;
	} else {
		return -1;	
f010575d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105762:	eb 05                	jmp    f0105769 <debuginfo_eip+0x239>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105764:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105769:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010576c:	5b                   	pop    %ebx
f010576d:	5e                   	pop    %esi
f010576e:	5f                   	pop    %edi
f010576f:	5d                   	pop    %ebp
f0105770:	c3                   	ret    

f0105771 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105771:	55                   	push   %ebp
f0105772:	89 e5                	mov    %esp,%ebp
f0105774:	57                   	push   %edi
f0105775:	56                   	push   %esi
f0105776:	53                   	push   %ebx
f0105777:	83 ec 1c             	sub    $0x1c,%esp
f010577a:	89 c7                	mov    %eax,%edi
f010577c:	89 d6                	mov    %edx,%esi
f010577e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105781:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105784:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105787:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010578a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010578d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105792:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105795:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0105798:	39 d3                	cmp    %edx,%ebx
f010579a:	72 05                	jb     f01057a1 <printnum+0x30>
f010579c:	39 45 10             	cmp    %eax,0x10(%ebp)
f010579f:	77 45                	ja     f01057e6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01057a1:	83 ec 0c             	sub    $0xc,%esp
f01057a4:	ff 75 18             	pushl  0x18(%ebp)
f01057a7:	8b 45 14             	mov    0x14(%ebp),%eax
f01057aa:	8d 58 ff             	lea    -0x1(%eax),%ebx
f01057ad:	53                   	push   %ebx
f01057ae:	ff 75 10             	pushl  0x10(%ebp)
f01057b1:	83 ec 08             	sub    $0x8,%esp
f01057b4:	ff 75 e4             	pushl  -0x1c(%ebp)
f01057b7:	ff 75 e0             	pushl  -0x20(%ebp)
f01057ba:	ff 75 dc             	pushl  -0x24(%ebp)
f01057bd:	ff 75 d8             	pushl  -0x28(%ebp)
f01057c0:	e8 7b 11 00 00       	call   f0106940 <__udivdi3>
f01057c5:	83 c4 18             	add    $0x18,%esp
f01057c8:	52                   	push   %edx
f01057c9:	50                   	push   %eax
f01057ca:	89 f2                	mov    %esi,%edx
f01057cc:	89 f8                	mov    %edi,%eax
f01057ce:	e8 9e ff ff ff       	call   f0105771 <printnum>
f01057d3:	83 c4 20             	add    $0x20,%esp
f01057d6:	eb 18                	jmp    f01057f0 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01057d8:	83 ec 08             	sub    $0x8,%esp
f01057db:	56                   	push   %esi
f01057dc:	ff 75 18             	pushl  0x18(%ebp)
f01057df:	ff d7                	call   *%edi
f01057e1:	83 c4 10             	add    $0x10,%esp
f01057e4:	eb 03                	jmp    f01057e9 <printnum+0x78>
f01057e6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01057e9:	83 eb 01             	sub    $0x1,%ebx
f01057ec:	85 db                	test   %ebx,%ebx
f01057ee:	7f e8                	jg     f01057d8 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01057f0:	83 ec 08             	sub    $0x8,%esp
f01057f3:	56                   	push   %esi
f01057f4:	83 ec 04             	sub    $0x4,%esp
f01057f7:	ff 75 e4             	pushl  -0x1c(%ebp)
f01057fa:	ff 75 e0             	pushl  -0x20(%ebp)
f01057fd:	ff 75 dc             	pushl  -0x24(%ebp)
f0105800:	ff 75 d8             	pushl  -0x28(%ebp)
f0105803:	e8 68 12 00 00       	call   f0106a70 <__umoddi3>
f0105808:	83 c4 14             	add    $0x14,%esp
f010580b:	0f be 80 42 85 10 f0 	movsbl -0xfef7abe(%eax),%eax
f0105812:	50                   	push   %eax
f0105813:	ff d7                	call   *%edi
}
f0105815:	83 c4 10             	add    $0x10,%esp
f0105818:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010581b:	5b                   	pop    %ebx
f010581c:	5e                   	pop    %esi
f010581d:	5f                   	pop    %edi
f010581e:	5d                   	pop    %ebp
f010581f:	c3                   	ret    

f0105820 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105820:	55                   	push   %ebp
f0105821:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105823:	83 fa 01             	cmp    $0x1,%edx
f0105826:	7e 0e                	jle    f0105836 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0105828:	8b 10                	mov    (%eax),%edx
f010582a:	8d 4a 08             	lea    0x8(%edx),%ecx
f010582d:	89 08                	mov    %ecx,(%eax)
f010582f:	8b 02                	mov    (%edx),%eax
f0105831:	8b 52 04             	mov    0x4(%edx),%edx
f0105834:	eb 22                	jmp    f0105858 <getuint+0x38>
	else if (lflag)
f0105836:	85 d2                	test   %edx,%edx
f0105838:	74 10                	je     f010584a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f010583a:	8b 10                	mov    (%eax),%edx
f010583c:	8d 4a 04             	lea    0x4(%edx),%ecx
f010583f:	89 08                	mov    %ecx,(%eax)
f0105841:	8b 02                	mov    (%edx),%eax
f0105843:	ba 00 00 00 00       	mov    $0x0,%edx
f0105848:	eb 0e                	jmp    f0105858 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f010584a:	8b 10                	mov    (%eax),%edx
f010584c:	8d 4a 04             	lea    0x4(%edx),%ecx
f010584f:	89 08                	mov    %ecx,(%eax)
f0105851:	8b 02                	mov    (%edx),%eax
f0105853:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105858:	5d                   	pop    %ebp
f0105859:	c3                   	ret    

f010585a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010585a:	55                   	push   %ebp
f010585b:	89 e5                	mov    %esp,%ebp
f010585d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105860:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105864:	8b 10                	mov    (%eax),%edx
f0105866:	3b 50 04             	cmp    0x4(%eax),%edx
f0105869:	73 0a                	jae    f0105875 <sprintputch+0x1b>
		*b->buf++ = ch;
f010586b:	8d 4a 01             	lea    0x1(%edx),%ecx
f010586e:	89 08                	mov    %ecx,(%eax)
f0105870:	8b 45 08             	mov    0x8(%ebp),%eax
f0105873:	88 02                	mov    %al,(%edx)
}
f0105875:	5d                   	pop    %ebp
f0105876:	c3                   	ret    

f0105877 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105877:	55                   	push   %ebp
f0105878:	89 e5                	mov    %esp,%ebp
f010587a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010587d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105880:	50                   	push   %eax
f0105881:	ff 75 10             	pushl  0x10(%ebp)
f0105884:	ff 75 0c             	pushl  0xc(%ebp)
f0105887:	ff 75 08             	pushl  0x8(%ebp)
f010588a:	e8 05 00 00 00       	call   f0105894 <vprintfmt>
	va_end(ap);
}
f010588f:	83 c4 10             	add    $0x10,%esp
f0105892:	c9                   	leave  
f0105893:	c3                   	ret    

f0105894 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105894:	55                   	push   %ebp
f0105895:	89 e5                	mov    %esp,%ebp
f0105897:	57                   	push   %edi
f0105898:	56                   	push   %esi
f0105899:	53                   	push   %ebx
f010589a:	83 ec 2c             	sub    $0x2c,%esp
f010589d:	8b 75 08             	mov    0x8(%ebp),%esi
f01058a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01058a3:	8b 7d 10             	mov    0x10(%ebp),%edi
f01058a6:	eb 12                	jmp    f01058ba <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01058a8:	85 c0                	test   %eax,%eax
f01058aa:	0f 84 89 03 00 00    	je     f0105c39 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f01058b0:	83 ec 08             	sub    $0x8,%esp
f01058b3:	53                   	push   %ebx
f01058b4:	50                   	push   %eax
f01058b5:	ff d6                	call   *%esi
f01058b7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01058ba:	83 c7 01             	add    $0x1,%edi
f01058bd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01058c1:	83 f8 25             	cmp    $0x25,%eax
f01058c4:	75 e2                	jne    f01058a8 <vprintfmt+0x14>
f01058c6:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f01058ca:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01058d1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01058d8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f01058df:	ba 00 00 00 00       	mov    $0x0,%edx
f01058e4:	eb 07                	jmp    f01058ed <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01058e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f01058e9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01058ed:	8d 47 01             	lea    0x1(%edi),%eax
f01058f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01058f3:	0f b6 07             	movzbl (%edi),%eax
f01058f6:	0f b6 c8             	movzbl %al,%ecx
f01058f9:	83 e8 23             	sub    $0x23,%eax
f01058fc:	3c 55                	cmp    $0x55,%al
f01058fe:	0f 87 1a 03 00 00    	ja     f0105c1e <vprintfmt+0x38a>
f0105904:	0f b6 c0             	movzbl %al,%eax
f0105907:	ff 24 85 80 86 10 f0 	jmp    *-0xfef7980(,%eax,4)
f010590e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105911:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0105915:	eb d6                	jmp    f01058ed <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105917:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010591a:	b8 00 00 00 00       	mov    $0x0,%eax
f010591f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105922:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0105925:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0105929:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f010592c:	8d 51 d0             	lea    -0x30(%ecx),%edx
f010592f:	83 fa 09             	cmp    $0x9,%edx
f0105932:	77 39                	ja     f010596d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105934:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0105937:	eb e9                	jmp    f0105922 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105939:	8b 45 14             	mov    0x14(%ebp),%eax
f010593c:	8d 48 04             	lea    0x4(%eax),%ecx
f010593f:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105942:	8b 00                	mov    (%eax),%eax
f0105944:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105947:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010594a:	eb 27                	jmp    f0105973 <vprintfmt+0xdf>
f010594c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010594f:	85 c0                	test   %eax,%eax
f0105951:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105956:	0f 49 c8             	cmovns %eax,%ecx
f0105959:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010595c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010595f:	eb 8c                	jmp    f01058ed <vprintfmt+0x59>
f0105961:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105964:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f010596b:	eb 80                	jmp    f01058ed <vprintfmt+0x59>
f010596d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105970:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0105973:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105977:	0f 89 70 ff ff ff    	jns    f01058ed <vprintfmt+0x59>
				width = precision, precision = -1;
f010597d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105980:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105983:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f010598a:	e9 5e ff ff ff       	jmp    f01058ed <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010598f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105992:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105995:	e9 53 ff ff ff       	jmp    f01058ed <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f010599a:	8b 45 14             	mov    0x14(%ebp),%eax
f010599d:	8d 50 04             	lea    0x4(%eax),%edx
f01059a0:	89 55 14             	mov    %edx,0x14(%ebp)
f01059a3:	83 ec 08             	sub    $0x8,%esp
f01059a6:	53                   	push   %ebx
f01059a7:	ff 30                	pushl  (%eax)
f01059a9:	ff d6                	call   *%esi
			break;
f01059ab:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01059ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01059b1:	e9 04 ff ff ff       	jmp    f01058ba <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01059b6:	8b 45 14             	mov    0x14(%ebp),%eax
f01059b9:	8d 50 04             	lea    0x4(%eax),%edx
f01059bc:	89 55 14             	mov    %edx,0x14(%ebp)
f01059bf:	8b 00                	mov    (%eax),%eax
f01059c1:	99                   	cltd   
f01059c2:	31 d0                	xor    %edx,%eax
f01059c4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01059c6:	83 f8 0f             	cmp    $0xf,%eax
f01059c9:	7f 0b                	jg     f01059d6 <vprintfmt+0x142>
f01059cb:	8b 14 85 e0 87 10 f0 	mov    -0xfef7820(,%eax,4),%edx
f01059d2:	85 d2                	test   %edx,%edx
f01059d4:	75 18                	jne    f01059ee <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f01059d6:	50                   	push   %eax
f01059d7:	68 5a 85 10 f0       	push   $0xf010855a
f01059dc:	53                   	push   %ebx
f01059dd:	56                   	push   %esi
f01059de:	e8 94 fe ff ff       	call   f0105877 <printfmt>
f01059e3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01059e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01059e9:	e9 cc fe ff ff       	jmp    f01058ba <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f01059ee:	52                   	push   %edx
f01059ef:	68 26 7b 10 f0       	push   $0xf0107b26
f01059f4:	53                   	push   %ebx
f01059f5:	56                   	push   %esi
f01059f6:	e8 7c fe ff ff       	call   f0105877 <printfmt>
f01059fb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01059fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105a01:	e9 b4 fe ff ff       	jmp    f01058ba <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105a06:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a09:	8d 50 04             	lea    0x4(%eax),%edx
f0105a0c:	89 55 14             	mov    %edx,0x14(%ebp)
f0105a0f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0105a11:	85 ff                	test   %edi,%edi
f0105a13:	b8 53 85 10 f0       	mov    $0xf0108553,%eax
f0105a18:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0105a1b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105a1f:	0f 8e 94 00 00 00    	jle    f0105ab9 <vprintfmt+0x225>
f0105a25:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0105a29:	0f 84 98 00 00 00    	je     f0105ac7 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105a2f:	83 ec 08             	sub    $0x8,%esp
f0105a32:	ff 75 d0             	pushl  -0x30(%ebp)
f0105a35:	57                   	push   %edi
f0105a36:	e8 77 03 00 00       	call   f0105db2 <strnlen>
f0105a3b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105a3e:	29 c1                	sub    %eax,%ecx
f0105a40:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0105a43:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0105a46:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0105a4a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105a4d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105a50:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105a52:	eb 0f                	jmp    f0105a63 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0105a54:	83 ec 08             	sub    $0x8,%esp
f0105a57:	53                   	push   %ebx
f0105a58:	ff 75 e0             	pushl  -0x20(%ebp)
f0105a5b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105a5d:	83 ef 01             	sub    $0x1,%edi
f0105a60:	83 c4 10             	add    $0x10,%esp
f0105a63:	85 ff                	test   %edi,%edi
f0105a65:	7f ed                	jg     f0105a54 <vprintfmt+0x1c0>
f0105a67:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105a6a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0105a6d:	85 c9                	test   %ecx,%ecx
f0105a6f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a74:	0f 49 c1             	cmovns %ecx,%eax
f0105a77:	29 c1                	sub    %eax,%ecx
f0105a79:	89 75 08             	mov    %esi,0x8(%ebp)
f0105a7c:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105a7f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105a82:	89 cb                	mov    %ecx,%ebx
f0105a84:	eb 4d                	jmp    f0105ad3 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105a86:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105a8a:	74 1b                	je     f0105aa7 <vprintfmt+0x213>
f0105a8c:	0f be c0             	movsbl %al,%eax
f0105a8f:	83 e8 20             	sub    $0x20,%eax
f0105a92:	83 f8 5e             	cmp    $0x5e,%eax
f0105a95:	76 10                	jbe    f0105aa7 <vprintfmt+0x213>
					putch('?', putdat);
f0105a97:	83 ec 08             	sub    $0x8,%esp
f0105a9a:	ff 75 0c             	pushl  0xc(%ebp)
f0105a9d:	6a 3f                	push   $0x3f
f0105a9f:	ff 55 08             	call   *0x8(%ebp)
f0105aa2:	83 c4 10             	add    $0x10,%esp
f0105aa5:	eb 0d                	jmp    f0105ab4 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0105aa7:	83 ec 08             	sub    $0x8,%esp
f0105aaa:	ff 75 0c             	pushl  0xc(%ebp)
f0105aad:	52                   	push   %edx
f0105aae:	ff 55 08             	call   *0x8(%ebp)
f0105ab1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105ab4:	83 eb 01             	sub    $0x1,%ebx
f0105ab7:	eb 1a                	jmp    f0105ad3 <vprintfmt+0x23f>
f0105ab9:	89 75 08             	mov    %esi,0x8(%ebp)
f0105abc:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105abf:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105ac2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105ac5:	eb 0c                	jmp    f0105ad3 <vprintfmt+0x23f>
f0105ac7:	89 75 08             	mov    %esi,0x8(%ebp)
f0105aca:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105acd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105ad0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105ad3:	83 c7 01             	add    $0x1,%edi
f0105ad6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105ada:	0f be d0             	movsbl %al,%edx
f0105add:	85 d2                	test   %edx,%edx
f0105adf:	74 23                	je     f0105b04 <vprintfmt+0x270>
f0105ae1:	85 f6                	test   %esi,%esi
f0105ae3:	78 a1                	js     f0105a86 <vprintfmt+0x1f2>
f0105ae5:	83 ee 01             	sub    $0x1,%esi
f0105ae8:	79 9c                	jns    f0105a86 <vprintfmt+0x1f2>
f0105aea:	89 df                	mov    %ebx,%edi
f0105aec:	8b 75 08             	mov    0x8(%ebp),%esi
f0105aef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105af2:	eb 18                	jmp    f0105b0c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105af4:	83 ec 08             	sub    $0x8,%esp
f0105af7:	53                   	push   %ebx
f0105af8:	6a 20                	push   $0x20
f0105afa:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105afc:	83 ef 01             	sub    $0x1,%edi
f0105aff:	83 c4 10             	add    $0x10,%esp
f0105b02:	eb 08                	jmp    f0105b0c <vprintfmt+0x278>
f0105b04:	89 df                	mov    %ebx,%edi
f0105b06:	8b 75 08             	mov    0x8(%ebp),%esi
f0105b09:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105b0c:	85 ff                	test   %edi,%edi
f0105b0e:	7f e4                	jg     f0105af4 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b10:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105b13:	e9 a2 fd ff ff       	jmp    f01058ba <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105b18:	83 fa 01             	cmp    $0x1,%edx
f0105b1b:	7e 16                	jle    f0105b33 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0105b1d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b20:	8d 50 08             	lea    0x8(%eax),%edx
f0105b23:	89 55 14             	mov    %edx,0x14(%ebp)
f0105b26:	8b 50 04             	mov    0x4(%eax),%edx
f0105b29:	8b 00                	mov    (%eax),%eax
f0105b2b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105b2e:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105b31:	eb 32                	jmp    f0105b65 <vprintfmt+0x2d1>
	else if (lflag)
f0105b33:	85 d2                	test   %edx,%edx
f0105b35:	74 18                	je     f0105b4f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0105b37:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b3a:	8d 50 04             	lea    0x4(%eax),%edx
f0105b3d:	89 55 14             	mov    %edx,0x14(%ebp)
f0105b40:	8b 00                	mov    (%eax),%eax
f0105b42:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105b45:	89 c1                	mov    %eax,%ecx
f0105b47:	c1 f9 1f             	sar    $0x1f,%ecx
f0105b4a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105b4d:	eb 16                	jmp    f0105b65 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0105b4f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b52:	8d 50 04             	lea    0x4(%eax),%edx
f0105b55:	89 55 14             	mov    %edx,0x14(%ebp)
f0105b58:	8b 00                	mov    (%eax),%eax
f0105b5a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105b5d:	89 c1                	mov    %eax,%ecx
f0105b5f:	c1 f9 1f             	sar    $0x1f,%ecx
f0105b62:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105b65:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105b68:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105b6b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0105b70:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105b74:	79 74                	jns    f0105bea <vprintfmt+0x356>
				putch('-', putdat);
f0105b76:	83 ec 08             	sub    $0x8,%esp
f0105b79:	53                   	push   %ebx
f0105b7a:	6a 2d                	push   $0x2d
f0105b7c:	ff d6                	call   *%esi
				num = -(long long) num;
f0105b7e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105b81:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105b84:	f7 d8                	neg    %eax
f0105b86:	83 d2 00             	adc    $0x0,%edx
f0105b89:	f7 da                	neg    %edx
f0105b8b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0105b8e:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0105b93:	eb 55                	jmp    f0105bea <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105b95:	8d 45 14             	lea    0x14(%ebp),%eax
f0105b98:	e8 83 fc ff ff       	call   f0105820 <getuint>
			base = 10;
f0105b9d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0105ba2:	eb 46                	jmp    f0105bea <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0105ba4:	8d 45 14             	lea    0x14(%ebp),%eax
f0105ba7:	e8 74 fc ff ff       	call   f0105820 <getuint>
			base = 8;
f0105bac:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0105bb1:	eb 37                	jmp    f0105bea <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f0105bb3:	83 ec 08             	sub    $0x8,%esp
f0105bb6:	53                   	push   %ebx
f0105bb7:	6a 30                	push   $0x30
f0105bb9:	ff d6                	call   *%esi
			putch('x', putdat);
f0105bbb:	83 c4 08             	add    $0x8,%esp
f0105bbe:	53                   	push   %ebx
f0105bbf:	6a 78                	push   $0x78
f0105bc1:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105bc3:	8b 45 14             	mov    0x14(%ebp),%eax
f0105bc6:	8d 50 04             	lea    0x4(%eax),%edx
f0105bc9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105bcc:	8b 00                	mov    (%eax),%eax
f0105bce:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0105bd3:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105bd6:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0105bdb:	eb 0d                	jmp    f0105bea <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105bdd:	8d 45 14             	lea    0x14(%ebp),%eax
f0105be0:	e8 3b fc ff ff       	call   f0105820 <getuint>
			base = 16;
f0105be5:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105bea:	83 ec 0c             	sub    $0xc,%esp
f0105bed:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0105bf1:	57                   	push   %edi
f0105bf2:	ff 75 e0             	pushl  -0x20(%ebp)
f0105bf5:	51                   	push   %ecx
f0105bf6:	52                   	push   %edx
f0105bf7:	50                   	push   %eax
f0105bf8:	89 da                	mov    %ebx,%edx
f0105bfa:	89 f0                	mov    %esi,%eax
f0105bfc:	e8 70 fb ff ff       	call   f0105771 <printnum>
			break;
f0105c01:	83 c4 20             	add    $0x20,%esp
f0105c04:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105c07:	e9 ae fc ff ff       	jmp    f01058ba <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105c0c:	83 ec 08             	sub    $0x8,%esp
f0105c0f:	53                   	push   %ebx
f0105c10:	51                   	push   %ecx
f0105c11:	ff d6                	call   *%esi
			break;
f0105c13:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105c16:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105c19:	e9 9c fc ff ff       	jmp    f01058ba <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105c1e:	83 ec 08             	sub    $0x8,%esp
f0105c21:	53                   	push   %ebx
f0105c22:	6a 25                	push   $0x25
f0105c24:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105c26:	83 c4 10             	add    $0x10,%esp
f0105c29:	eb 03                	jmp    f0105c2e <vprintfmt+0x39a>
f0105c2b:	83 ef 01             	sub    $0x1,%edi
f0105c2e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0105c32:	75 f7                	jne    f0105c2b <vprintfmt+0x397>
f0105c34:	e9 81 fc ff ff       	jmp    f01058ba <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0105c39:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105c3c:	5b                   	pop    %ebx
f0105c3d:	5e                   	pop    %esi
f0105c3e:	5f                   	pop    %edi
f0105c3f:	5d                   	pop    %ebp
f0105c40:	c3                   	ret    

f0105c41 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105c41:	55                   	push   %ebp
f0105c42:	89 e5                	mov    %esp,%ebp
f0105c44:	83 ec 18             	sub    $0x18,%esp
f0105c47:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c4a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105c4d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105c50:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105c54:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105c57:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105c5e:	85 c0                	test   %eax,%eax
f0105c60:	74 26                	je     f0105c88 <vsnprintf+0x47>
f0105c62:	85 d2                	test   %edx,%edx
f0105c64:	7e 22                	jle    f0105c88 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105c66:	ff 75 14             	pushl  0x14(%ebp)
f0105c69:	ff 75 10             	pushl  0x10(%ebp)
f0105c6c:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105c6f:	50                   	push   %eax
f0105c70:	68 5a 58 10 f0       	push   $0xf010585a
f0105c75:	e8 1a fc ff ff       	call   f0105894 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105c7a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105c7d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105c83:	83 c4 10             	add    $0x10,%esp
f0105c86:	eb 05                	jmp    f0105c8d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105c88:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105c8d:	c9                   	leave  
f0105c8e:	c3                   	ret    

f0105c8f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105c8f:	55                   	push   %ebp
f0105c90:	89 e5                	mov    %esp,%ebp
f0105c92:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105c95:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105c98:	50                   	push   %eax
f0105c99:	ff 75 10             	pushl  0x10(%ebp)
f0105c9c:	ff 75 0c             	pushl  0xc(%ebp)
f0105c9f:	ff 75 08             	pushl  0x8(%ebp)
f0105ca2:	e8 9a ff ff ff       	call   f0105c41 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105ca7:	c9                   	leave  
f0105ca8:	c3                   	ret    

f0105ca9 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105ca9:	55                   	push   %ebp
f0105caa:	89 e5                	mov    %esp,%ebp
f0105cac:	57                   	push   %edi
f0105cad:	56                   	push   %esi
f0105cae:	53                   	push   %ebx
f0105caf:	83 ec 0c             	sub    $0xc,%esp
f0105cb2:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105cb5:	85 c0                	test   %eax,%eax
f0105cb7:	74 11                	je     f0105cca <readline+0x21>
		cprintf("%s", prompt);
f0105cb9:	83 ec 08             	sub    $0x8,%esp
f0105cbc:	50                   	push   %eax
f0105cbd:	68 26 7b 10 f0       	push   $0xf0107b26
f0105cc2:	e8 c1 e0 ff ff       	call   f0103d88 <cprintf>
f0105cc7:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105cca:	83 ec 0c             	sub    $0xc,%esp
f0105ccd:	6a 00                	push   $0x0
f0105ccf:	e8 e6 aa ff ff       	call   f01007ba <iscons>
f0105cd4:	89 c7                	mov    %eax,%edi
f0105cd6:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f0105cd9:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105cde:	e8 c6 aa ff ff       	call   f01007a9 <getchar>
f0105ce3:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105ce5:	85 c0                	test   %eax,%eax
f0105ce7:	79 29                	jns    f0105d12 <readline+0x69>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f0105ce9:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f0105cee:	83 fb f8             	cmp    $0xfffffff8,%ebx
f0105cf1:	0f 84 9b 00 00 00    	je     f0105d92 <readline+0xe9>
				cprintf("read error: %e\n", c);
f0105cf7:	83 ec 08             	sub    $0x8,%esp
f0105cfa:	53                   	push   %ebx
f0105cfb:	68 3f 88 10 f0       	push   $0xf010883f
f0105d00:	e8 83 e0 ff ff       	call   f0103d88 <cprintf>
f0105d05:	83 c4 10             	add    $0x10,%esp
			return NULL;
f0105d08:	b8 00 00 00 00       	mov    $0x0,%eax
f0105d0d:	e9 80 00 00 00       	jmp    f0105d92 <readline+0xe9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105d12:	83 f8 08             	cmp    $0x8,%eax
f0105d15:	0f 94 c2             	sete   %dl
f0105d18:	83 f8 7f             	cmp    $0x7f,%eax
f0105d1b:	0f 94 c0             	sete   %al
f0105d1e:	08 c2                	or     %al,%dl
f0105d20:	74 1a                	je     f0105d3c <readline+0x93>
f0105d22:	85 f6                	test   %esi,%esi
f0105d24:	7e 16                	jle    f0105d3c <readline+0x93>
			if (echoing)
f0105d26:	85 ff                	test   %edi,%edi
f0105d28:	74 0d                	je     f0105d37 <readline+0x8e>
				cputchar('\b');
f0105d2a:	83 ec 0c             	sub    $0xc,%esp
f0105d2d:	6a 08                	push   $0x8
f0105d2f:	e8 65 aa ff ff       	call   f0100799 <cputchar>
f0105d34:	83 c4 10             	add    $0x10,%esp
			i--;
f0105d37:	83 ee 01             	sub    $0x1,%esi
f0105d3a:	eb a2                	jmp    f0105cde <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105d3c:	83 fb 1f             	cmp    $0x1f,%ebx
f0105d3f:	7e 26                	jle    f0105d67 <readline+0xbe>
f0105d41:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105d47:	7f 1e                	jg     f0105d67 <readline+0xbe>
			if (echoing)
f0105d49:	85 ff                	test   %edi,%edi
f0105d4b:	74 0c                	je     f0105d59 <readline+0xb0>
				cputchar(c);
f0105d4d:	83 ec 0c             	sub    $0xc,%esp
f0105d50:	53                   	push   %ebx
f0105d51:	e8 43 aa ff ff       	call   f0100799 <cputchar>
f0105d56:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105d59:	88 9e 80 9a 21 f0    	mov    %bl,-0xfde6580(%esi)
f0105d5f:	8d 76 01             	lea    0x1(%esi),%esi
f0105d62:	e9 77 ff ff ff       	jmp    f0105cde <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105d67:	83 fb 0a             	cmp    $0xa,%ebx
f0105d6a:	74 09                	je     f0105d75 <readline+0xcc>
f0105d6c:	83 fb 0d             	cmp    $0xd,%ebx
f0105d6f:	0f 85 69 ff ff ff    	jne    f0105cde <readline+0x35>
			if (echoing)
f0105d75:	85 ff                	test   %edi,%edi
f0105d77:	74 0d                	je     f0105d86 <readline+0xdd>
				cputchar('\n');
f0105d79:	83 ec 0c             	sub    $0xc,%esp
f0105d7c:	6a 0a                	push   $0xa
f0105d7e:	e8 16 aa ff ff       	call   f0100799 <cputchar>
f0105d83:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0105d86:	c6 86 80 9a 21 f0 00 	movb   $0x0,-0xfde6580(%esi)
			return buf;
f0105d8d:	b8 80 9a 21 f0       	mov    $0xf0219a80,%eax
		}
	}
}
f0105d92:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105d95:	5b                   	pop    %ebx
f0105d96:	5e                   	pop    %esi
f0105d97:	5f                   	pop    %edi
f0105d98:	5d                   	pop    %ebp
f0105d99:	c3                   	ret    

f0105d9a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105d9a:	55                   	push   %ebp
f0105d9b:	89 e5                	mov    %esp,%ebp
f0105d9d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105da0:	b8 00 00 00 00       	mov    $0x0,%eax
f0105da5:	eb 03                	jmp    f0105daa <strlen+0x10>
		n++;
f0105da7:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105daa:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105dae:	75 f7                	jne    f0105da7 <strlen+0xd>
		n++;
	return n;
}
f0105db0:	5d                   	pop    %ebp
f0105db1:	c3                   	ret    

f0105db2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105db2:	55                   	push   %ebp
f0105db3:	89 e5                	mov    %esp,%ebp
f0105db5:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105db8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105dbb:	ba 00 00 00 00       	mov    $0x0,%edx
f0105dc0:	eb 03                	jmp    f0105dc5 <strnlen+0x13>
		n++;
f0105dc2:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105dc5:	39 c2                	cmp    %eax,%edx
f0105dc7:	74 08                	je     f0105dd1 <strnlen+0x1f>
f0105dc9:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0105dcd:	75 f3                	jne    f0105dc2 <strnlen+0x10>
f0105dcf:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0105dd1:	5d                   	pop    %ebp
f0105dd2:	c3                   	ret    

f0105dd3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105dd3:	55                   	push   %ebp
f0105dd4:	89 e5                	mov    %esp,%ebp
f0105dd6:	53                   	push   %ebx
f0105dd7:	8b 45 08             	mov    0x8(%ebp),%eax
f0105dda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105ddd:	89 c2                	mov    %eax,%edx
f0105ddf:	83 c2 01             	add    $0x1,%edx
f0105de2:	83 c1 01             	add    $0x1,%ecx
f0105de5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105de9:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105dec:	84 db                	test   %bl,%bl
f0105dee:	75 ef                	jne    f0105ddf <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105df0:	5b                   	pop    %ebx
f0105df1:	5d                   	pop    %ebp
f0105df2:	c3                   	ret    

f0105df3 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105df3:	55                   	push   %ebp
f0105df4:	89 e5                	mov    %esp,%ebp
f0105df6:	53                   	push   %ebx
f0105df7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105dfa:	53                   	push   %ebx
f0105dfb:	e8 9a ff ff ff       	call   f0105d9a <strlen>
f0105e00:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105e03:	ff 75 0c             	pushl  0xc(%ebp)
f0105e06:	01 d8                	add    %ebx,%eax
f0105e08:	50                   	push   %eax
f0105e09:	e8 c5 ff ff ff       	call   f0105dd3 <strcpy>
	return dst;
}
f0105e0e:	89 d8                	mov    %ebx,%eax
f0105e10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105e13:	c9                   	leave  
f0105e14:	c3                   	ret    

f0105e15 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105e15:	55                   	push   %ebp
f0105e16:	89 e5                	mov    %esp,%ebp
f0105e18:	56                   	push   %esi
f0105e19:	53                   	push   %ebx
f0105e1a:	8b 75 08             	mov    0x8(%ebp),%esi
f0105e1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105e20:	89 f3                	mov    %esi,%ebx
f0105e22:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105e25:	89 f2                	mov    %esi,%edx
f0105e27:	eb 0f                	jmp    f0105e38 <strncpy+0x23>
		*dst++ = *src;
f0105e29:	83 c2 01             	add    $0x1,%edx
f0105e2c:	0f b6 01             	movzbl (%ecx),%eax
f0105e2f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105e32:	80 39 01             	cmpb   $0x1,(%ecx)
f0105e35:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105e38:	39 da                	cmp    %ebx,%edx
f0105e3a:	75 ed                	jne    f0105e29 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105e3c:	89 f0                	mov    %esi,%eax
f0105e3e:	5b                   	pop    %ebx
f0105e3f:	5e                   	pop    %esi
f0105e40:	5d                   	pop    %ebp
f0105e41:	c3                   	ret    

f0105e42 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105e42:	55                   	push   %ebp
f0105e43:	89 e5                	mov    %esp,%ebp
f0105e45:	56                   	push   %esi
f0105e46:	53                   	push   %ebx
f0105e47:	8b 75 08             	mov    0x8(%ebp),%esi
f0105e4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105e4d:	8b 55 10             	mov    0x10(%ebp),%edx
f0105e50:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105e52:	85 d2                	test   %edx,%edx
f0105e54:	74 21                	je     f0105e77 <strlcpy+0x35>
f0105e56:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105e5a:	89 f2                	mov    %esi,%edx
f0105e5c:	eb 09                	jmp    f0105e67 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105e5e:	83 c2 01             	add    $0x1,%edx
f0105e61:	83 c1 01             	add    $0x1,%ecx
f0105e64:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105e67:	39 c2                	cmp    %eax,%edx
f0105e69:	74 09                	je     f0105e74 <strlcpy+0x32>
f0105e6b:	0f b6 19             	movzbl (%ecx),%ebx
f0105e6e:	84 db                	test   %bl,%bl
f0105e70:	75 ec                	jne    f0105e5e <strlcpy+0x1c>
f0105e72:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105e74:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105e77:	29 f0                	sub    %esi,%eax
}
f0105e79:	5b                   	pop    %ebx
f0105e7a:	5e                   	pop    %esi
f0105e7b:	5d                   	pop    %ebp
f0105e7c:	c3                   	ret    

f0105e7d <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105e7d:	55                   	push   %ebp
f0105e7e:	89 e5                	mov    %esp,%ebp
f0105e80:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105e83:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105e86:	eb 06                	jmp    f0105e8e <strcmp+0x11>
		p++, q++;
f0105e88:	83 c1 01             	add    $0x1,%ecx
f0105e8b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105e8e:	0f b6 01             	movzbl (%ecx),%eax
f0105e91:	84 c0                	test   %al,%al
f0105e93:	74 04                	je     f0105e99 <strcmp+0x1c>
f0105e95:	3a 02                	cmp    (%edx),%al
f0105e97:	74 ef                	je     f0105e88 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105e99:	0f b6 c0             	movzbl %al,%eax
f0105e9c:	0f b6 12             	movzbl (%edx),%edx
f0105e9f:	29 d0                	sub    %edx,%eax
}
f0105ea1:	5d                   	pop    %ebp
f0105ea2:	c3                   	ret    

f0105ea3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105ea3:	55                   	push   %ebp
f0105ea4:	89 e5                	mov    %esp,%ebp
f0105ea6:	53                   	push   %ebx
f0105ea7:	8b 45 08             	mov    0x8(%ebp),%eax
f0105eaa:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105ead:	89 c3                	mov    %eax,%ebx
f0105eaf:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105eb2:	eb 06                	jmp    f0105eba <strncmp+0x17>
		n--, p++, q++;
f0105eb4:	83 c0 01             	add    $0x1,%eax
f0105eb7:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105eba:	39 d8                	cmp    %ebx,%eax
f0105ebc:	74 15                	je     f0105ed3 <strncmp+0x30>
f0105ebe:	0f b6 08             	movzbl (%eax),%ecx
f0105ec1:	84 c9                	test   %cl,%cl
f0105ec3:	74 04                	je     f0105ec9 <strncmp+0x26>
f0105ec5:	3a 0a                	cmp    (%edx),%cl
f0105ec7:	74 eb                	je     f0105eb4 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105ec9:	0f b6 00             	movzbl (%eax),%eax
f0105ecc:	0f b6 12             	movzbl (%edx),%edx
f0105ecf:	29 d0                	sub    %edx,%eax
f0105ed1:	eb 05                	jmp    f0105ed8 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105ed3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105ed8:	5b                   	pop    %ebx
f0105ed9:	5d                   	pop    %ebp
f0105eda:	c3                   	ret    

f0105edb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105edb:	55                   	push   %ebp
f0105edc:	89 e5                	mov    %esp,%ebp
f0105ede:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ee1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105ee5:	eb 07                	jmp    f0105eee <strchr+0x13>
		if (*s == c)
f0105ee7:	38 ca                	cmp    %cl,%dl
f0105ee9:	74 0f                	je     f0105efa <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105eeb:	83 c0 01             	add    $0x1,%eax
f0105eee:	0f b6 10             	movzbl (%eax),%edx
f0105ef1:	84 d2                	test   %dl,%dl
f0105ef3:	75 f2                	jne    f0105ee7 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0105ef5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105efa:	5d                   	pop    %ebp
f0105efb:	c3                   	ret    

f0105efc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105efc:	55                   	push   %ebp
f0105efd:	89 e5                	mov    %esp,%ebp
f0105eff:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f02:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105f06:	eb 03                	jmp    f0105f0b <strfind+0xf>
f0105f08:	83 c0 01             	add    $0x1,%eax
f0105f0b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105f0e:	38 ca                	cmp    %cl,%dl
f0105f10:	74 04                	je     f0105f16 <strfind+0x1a>
f0105f12:	84 d2                	test   %dl,%dl
f0105f14:	75 f2                	jne    f0105f08 <strfind+0xc>
			break;
	return (char *) s;
}
f0105f16:	5d                   	pop    %ebp
f0105f17:	c3                   	ret    

f0105f18 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105f18:	55                   	push   %ebp
f0105f19:	89 e5                	mov    %esp,%ebp
f0105f1b:	57                   	push   %edi
f0105f1c:	56                   	push   %esi
f0105f1d:	53                   	push   %ebx
f0105f1e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105f21:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105f24:	85 c9                	test   %ecx,%ecx
f0105f26:	74 36                	je     f0105f5e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105f28:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105f2e:	75 28                	jne    f0105f58 <memset+0x40>
f0105f30:	f6 c1 03             	test   $0x3,%cl
f0105f33:	75 23                	jne    f0105f58 <memset+0x40>
		c &= 0xFF;
f0105f35:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105f39:	89 d3                	mov    %edx,%ebx
f0105f3b:	c1 e3 08             	shl    $0x8,%ebx
f0105f3e:	89 d6                	mov    %edx,%esi
f0105f40:	c1 e6 18             	shl    $0x18,%esi
f0105f43:	89 d0                	mov    %edx,%eax
f0105f45:	c1 e0 10             	shl    $0x10,%eax
f0105f48:	09 f0                	or     %esi,%eax
f0105f4a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0105f4c:	89 d8                	mov    %ebx,%eax
f0105f4e:	09 d0                	or     %edx,%eax
f0105f50:	c1 e9 02             	shr    $0x2,%ecx
f0105f53:	fc                   	cld    
f0105f54:	f3 ab                	rep stos %eax,%es:(%edi)
f0105f56:	eb 06                	jmp    f0105f5e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105f58:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105f5b:	fc                   	cld    
f0105f5c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105f5e:	89 f8                	mov    %edi,%eax
f0105f60:	5b                   	pop    %ebx
f0105f61:	5e                   	pop    %esi
f0105f62:	5f                   	pop    %edi
f0105f63:	5d                   	pop    %ebp
f0105f64:	c3                   	ret    

f0105f65 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105f65:	55                   	push   %ebp
f0105f66:	89 e5                	mov    %esp,%ebp
f0105f68:	57                   	push   %edi
f0105f69:	56                   	push   %esi
f0105f6a:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f6d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105f70:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105f73:	39 c6                	cmp    %eax,%esi
f0105f75:	73 35                	jae    f0105fac <memmove+0x47>
f0105f77:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105f7a:	39 d0                	cmp    %edx,%eax
f0105f7c:	73 2e                	jae    f0105fac <memmove+0x47>
		s += n;
		d += n;
f0105f7e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105f81:	89 d6                	mov    %edx,%esi
f0105f83:	09 fe                	or     %edi,%esi
f0105f85:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105f8b:	75 13                	jne    f0105fa0 <memmove+0x3b>
f0105f8d:	f6 c1 03             	test   $0x3,%cl
f0105f90:	75 0e                	jne    f0105fa0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0105f92:	83 ef 04             	sub    $0x4,%edi
f0105f95:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105f98:	c1 e9 02             	shr    $0x2,%ecx
f0105f9b:	fd                   	std    
f0105f9c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105f9e:	eb 09                	jmp    f0105fa9 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105fa0:	83 ef 01             	sub    $0x1,%edi
f0105fa3:	8d 72 ff             	lea    -0x1(%edx),%esi
f0105fa6:	fd                   	std    
f0105fa7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105fa9:	fc                   	cld    
f0105faa:	eb 1d                	jmp    f0105fc9 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105fac:	89 f2                	mov    %esi,%edx
f0105fae:	09 c2                	or     %eax,%edx
f0105fb0:	f6 c2 03             	test   $0x3,%dl
f0105fb3:	75 0f                	jne    f0105fc4 <memmove+0x5f>
f0105fb5:	f6 c1 03             	test   $0x3,%cl
f0105fb8:	75 0a                	jne    f0105fc4 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0105fba:	c1 e9 02             	shr    $0x2,%ecx
f0105fbd:	89 c7                	mov    %eax,%edi
f0105fbf:	fc                   	cld    
f0105fc0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105fc2:	eb 05                	jmp    f0105fc9 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105fc4:	89 c7                	mov    %eax,%edi
f0105fc6:	fc                   	cld    
f0105fc7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105fc9:	5e                   	pop    %esi
f0105fca:	5f                   	pop    %edi
f0105fcb:	5d                   	pop    %ebp
f0105fcc:	c3                   	ret    

f0105fcd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105fcd:	55                   	push   %ebp
f0105fce:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105fd0:	ff 75 10             	pushl  0x10(%ebp)
f0105fd3:	ff 75 0c             	pushl  0xc(%ebp)
f0105fd6:	ff 75 08             	pushl  0x8(%ebp)
f0105fd9:	e8 87 ff ff ff       	call   f0105f65 <memmove>
}
f0105fde:	c9                   	leave  
f0105fdf:	c3                   	ret    

f0105fe0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105fe0:	55                   	push   %ebp
f0105fe1:	89 e5                	mov    %esp,%ebp
f0105fe3:	56                   	push   %esi
f0105fe4:	53                   	push   %ebx
f0105fe5:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fe8:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105feb:	89 c6                	mov    %eax,%esi
f0105fed:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105ff0:	eb 1a                	jmp    f010600c <memcmp+0x2c>
		if (*s1 != *s2)
f0105ff2:	0f b6 08             	movzbl (%eax),%ecx
f0105ff5:	0f b6 1a             	movzbl (%edx),%ebx
f0105ff8:	38 d9                	cmp    %bl,%cl
f0105ffa:	74 0a                	je     f0106006 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0105ffc:	0f b6 c1             	movzbl %cl,%eax
f0105fff:	0f b6 db             	movzbl %bl,%ebx
f0106002:	29 d8                	sub    %ebx,%eax
f0106004:	eb 0f                	jmp    f0106015 <memcmp+0x35>
		s1++, s2++;
f0106006:	83 c0 01             	add    $0x1,%eax
f0106009:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010600c:	39 f0                	cmp    %esi,%eax
f010600e:	75 e2                	jne    f0105ff2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0106010:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106015:	5b                   	pop    %ebx
f0106016:	5e                   	pop    %esi
f0106017:	5d                   	pop    %ebp
f0106018:	c3                   	ret    

f0106019 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0106019:	55                   	push   %ebp
f010601a:	89 e5                	mov    %esp,%ebp
f010601c:	53                   	push   %ebx
f010601d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0106020:	89 c1                	mov    %eax,%ecx
f0106022:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0106025:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0106029:	eb 0a                	jmp    f0106035 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f010602b:	0f b6 10             	movzbl (%eax),%edx
f010602e:	39 da                	cmp    %ebx,%edx
f0106030:	74 07                	je     f0106039 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0106032:	83 c0 01             	add    $0x1,%eax
f0106035:	39 c8                	cmp    %ecx,%eax
f0106037:	72 f2                	jb     f010602b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0106039:	5b                   	pop    %ebx
f010603a:	5d                   	pop    %ebp
f010603b:	c3                   	ret    

f010603c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010603c:	55                   	push   %ebp
f010603d:	89 e5                	mov    %esp,%ebp
f010603f:	57                   	push   %edi
f0106040:	56                   	push   %esi
f0106041:	53                   	push   %ebx
f0106042:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0106045:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106048:	eb 03                	jmp    f010604d <strtol+0x11>
		s++;
f010604a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010604d:	0f b6 01             	movzbl (%ecx),%eax
f0106050:	3c 20                	cmp    $0x20,%al
f0106052:	74 f6                	je     f010604a <strtol+0xe>
f0106054:	3c 09                	cmp    $0x9,%al
f0106056:	74 f2                	je     f010604a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0106058:	3c 2b                	cmp    $0x2b,%al
f010605a:	75 0a                	jne    f0106066 <strtol+0x2a>
		s++;
f010605c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010605f:	bf 00 00 00 00       	mov    $0x0,%edi
f0106064:	eb 11                	jmp    f0106077 <strtol+0x3b>
f0106066:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010606b:	3c 2d                	cmp    $0x2d,%al
f010606d:	75 08                	jne    f0106077 <strtol+0x3b>
		s++, neg = 1;
f010606f:	83 c1 01             	add    $0x1,%ecx
f0106072:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0106077:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010607d:	75 15                	jne    f0106094 <strtol+0x58>
f010607f:	80 39 30             	cmpb   $0x30,(%ecx)
f0106082:	75 10                	jne    f0106094 <strtol+0x58>
f0106084:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0106088:	75 7c                	jne    f0106106 <strtol+0xca>
		s += 2, base = 16;
f010608a:	83 c1 02             	add    $0x2,%ecx
f010608d:	bb 10 00 00 00       	mov    $0x10,%ebx
f0106092:	eb 16                	jmp    f01060aa <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0106094:	85 db                	test   %ebx,%ebx
f0106096:	75 12                	jne    f01060aa <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0106098:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010609d:	80 39 30             	cmpb   $0x30,(%ecx)
f01060a0:	75 08                	jne    f01060aa <strtol+0x6e>
		s++, base = 8;
f01060a2:	83 c1 01             	add    $0x1,%ecx
f01060a5:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01060aa:	b8 00 00 00 00       	mov    $0x0,%eax
f01060af:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01060b2:	0f b6 11             	movzbl (%ecx),%edx
f01060b5:	8d 72 d0             	lea    -0x30(%edx),%esi
f01060b8:	89 f3                	mov    %esi,%ebx
f01060ba:	80 fb 09             	cmp    $0x9,%bl
f01060bd:	77 08                	ja     f01060c7 <strtol+0x8b>
			dig = *s - '0';
f01060bf:	0f be d2             	movsbl %dl,%edx
f01060c2:	83 ea 30             	sub    $0x30,%edx
f01060c5:	eb 22                	jmp    f01060e9 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f01060c7:	8d 72 9f             	lea    -0x61(%edx),%esi
f01060ca:	89 f3                	mov    %esi,%ebx
f01060cc:	80 fb 19             	cmp    $0x19,%bl
f01060cf:	77 08                	ja     f01060d9 <strtol+0x9d>
			dig = *s - 'a' + 10;
f01060d1:	0f be d2             	movsbl %dl,%edx
f01060d4:	83 ea 57             	sub    $0x57,%edx
f01060d7:	eb 10                	jmp    f01060e9 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01060d9:	8d 72 bf             	lea    -0x41(%edx),%esi
f01060dc:	89 f3                	mov    %esi,%ebx
f01060de:	80 fb 19             	cmp    $0x19,%bl
f01060e1:	77 16                	ja     f01060f9 <strtol+0xbd>
			dig = *s - 'A' + 10;
f01060e3:	0f be d2             	movsbl %dl,%edx
f01060e6:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01060e9:	3b 55 10             	cmp    0x10(%ebp),%edx
f01060ec:	7d 0b                	jge    f01060f9 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01060ee:	83 c1 01             	add    $0x1,%ecx
f01060f1:	0f af 45 10          	imul   0x10(%ebp),%eax
f01060f5:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01060f7:	eb b9                	jmp    f01060b2 <strtol+0x76>

	if (endptr)
f01060f9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01060fd:	74 0d                	je     f010610c <strtol+0xd0>
		*endptr = (char *) s;
f01060ff:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106102:	89 0e                	mov    %ecx,(%esi)
f0106104:	eb 06                	jmp    f010610c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0106106:	85 db                	test   %ebx,%ebx
f0106108:	74 98                	je     f01060a2 <strtol+0x66>
f010610a:	eb 9e                	jmp    f01060aa <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f010610c:	89 c2                	mov    %eax,%edx
f010610e:	f7 da                	neg    %edx
f0106110:	85 ff                	test   %edi,%edi
f0106112:	0f 45 c2             	cmovne %edx,%eax
}
f0106115:	5b                   	pop    %ebx
f0106116:	5e                   	pop    %esi
f0106117:	5f                   	pop    %edi
f0106118:	5d                   	pop    %ebp
f0106119:	c3                   	ret    
f010611a:	66 90                	xchg   %ax,%ax

f010611c <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f010611c:	fa                   	cli    

	xorw    %ax, %ax
f010611d:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010611f:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106121:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106123:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0106125:	0f 01 16             	lgdtl  (%esi)
f0106128:	74 70                	je     f010619a <mpsearch1+0x3>
	movl    %cr0, %eax
f010612a:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f010612d:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0106131:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0106134:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f010613a:	08 00                	or     %al,(%eax)

f010613c <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f010613c:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0106140:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106142:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106144:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0106146:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f010614a:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f010614c:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010614e:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl    %eax, %cr3
f0106153:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0106156:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0106159:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010615e:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0106161:	8b 25 84 9e 21 f0    	mov    0xf0219e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0106167:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f010616c:	b8 c7 01 10 f0       	mov    $0xf01001c7,%eax
	call    *%eax
f0106171:	ff d0                	call   *%eax

f0106173 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0106173:	eb fe                	jmp    f0106173 <spin>
f0106175:	8d 76 00             	lea    0x0(%esi),%esi

f0106178 <gdt>:
	...
f0106180:	ff                   	(bad)  
f0106181:	ff 00                	incl   (%eax)
f0106183:	00 00                	add    %al,(%eax)
f0106185:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f010618c:	00                   	.byte 0x0
f010618d:	92                   	xchg   %eax,%edx
f010618e:	cf                   	iret   
	...

f0106190 <gdtdesc>:
f0106190:	17                   	pop    %ss
f0106191:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0106196 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0106196:	90                   	nop

f0106197 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0106197:	55                   	push   %ebp
f0106198:	89 e5                	mov    %esp,%ebp
f010619a:	57                   	push   %edi
f010619b:	56                   	push   %esi
f010619c:	53                   	push   %ebx
f010619d:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01061a0:	8b 0d 88 9e 21 f0    	mov    0xf0219e88,%ecx
f01061a6:	89 c3                	mov    %eax,%ebx
f01061a8:	c1 eb 0c             	shr    $0xc,%ebx
f01061ab:	39 cb                	cmp    %ecx,%ebx
f01061ad:	72 12                	jb     f01061c1 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01061af:	50                   	push   %eax
f01061b0:	68 04 6c 10 f0       	push   $0xf0106c04
f01061b5:	6a 57                	push   $0x57
f01061b7:	68 dd 89 10 f0       	push   $0xf01089dd
f01061bc:	e8 7f 9e ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01061c1:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01061c7:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01061c9:	89 c2                	mov    %eax,%edx
f01061cb:	c1 ea 0c             	shr    $0xc,%edx
f01061ce:	39 ca                	cmp    %ecx,%edx
f01061d0:	72 12                	jb     f01061e4 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01061d2:	50                   	push   %eax
f01061d3:	68 04 6c 10 f0       	push   $0xf0106c04
f01061d8:	6a 57                	push   $0x57
f01061da:	68 dd 89 10 f0       	push   $0xf01089dd
f01061df:	e8 5c 9e ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01061e4:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f01061ea:	eb 2f                	jmp    f010621b <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01061ec:	83 ec 04             	sub    $0x4,%esp
f01061ef:	6a 04                	push   $0x4
f01061f1:	68 ed 89 10 f0       	push   $0xf01089ed
f01061f6:	53                   	push   %ebx
f01061f7:	e8 e4 fd ff ff       	call   f0105fe0 <memcmp>
f01061fc:	83 c4 10             	add    $0x10,%esp
f01061ff:	85 c0                	test   %eax,%eax
f0106201:	75 15                	jne    f0106218 <mpsearch1+0x81>
f0106203:	89 da                	mov    %ebx,%edx
f0106205:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0106208:	0f b6 0a             	movzbl (%edx),%ecx
f010620b:	01 c8                	add    %ecx,%eax
f010620d:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106210:	39 d7                	cmp    %edx,%edi
f0106212:	75 f4                	jne    f0106208 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106214:	84 c0                	test   %al,%al
f0106216:	74 0e                	je     f0106226 <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0106218:	83 c3 10             	add    $0x10,%ebx
f010621b:	39 f3                	cmp    %esi,%ebx
f010621d:	72 cd                	jb     f01061ec <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f010621f:	b8 00 00 00 00       	mov    $0x0,%eax
f0106224:	eb 02                	jmp    f0106228 <mpsearch1+0x91>
f0106226:	89 d8                	mov    %ebx,%eax
}
f0106228:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010622b:	5b                   	pop    %ebx
f010622c:	5e                   	pop    %esi
f010622d:	5f                   	pop    %edi
f010622e:	5d                   	pop    %ebp
f010622f:	c3                   	ret    

f0106230 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0106230:	55                   	push   %ebp
f0106231:	89 e5                	mov    %esp,%ebp
f0106233:	57                   	push   %edi
f0106234:	56                   	push   %esi
f0106235:	53                   	push   %ebx
f0106236:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0106239:	c7 05 c0 a3 21 f0 20 	movl   $0xf021a020,0xf021a3c0
f0106240:	a0 21 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106243:	83 3d 88 9e 21 f0 00 	cmpl   $0x0,0xf0219e88
f010624a:	75 16                	jne    f0106262 <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010624c:	68 00 04 00 00       	push   $0x400
f0106251:	68 04 6c 10 f0       	push   $0xf0106c04
f0106256:	6a 6f                	push   $0x6f
f0106258:	68 dd 89 10 f0       	push   $0xf01089dd
f010625d:	e8 de 9d ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0106262:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0106269:	85 c0                	test   %eax,%eax
f010626b:	74 16                	je     f0106283 <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f010626d:	c1 e0 04             	shl    $0x4,%eax
f0106270:	ba 00 04 00 00       	mov    $0x400,%edx
f0106275:	e8 1d ff ff ff       	call   f0106197 <mpsearch1>
f010627a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010627d:	85 c0                	test   %eax,%eax
f010627f:	75 3c                	jne    f01062bd <mp_init+0x8d>
f0106281:	eb 20                	jmp    f01062a3 <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0106283:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f010628a:	c1 e0 0a             	shl    $0xa,%eax
f010628d:	2d 00 04 00 00       	sub    $0x400,%eax
f0106292:	ba 00 04 00 00       	mov    $0x400,%edx
f0106297:	e8 fb fe ff ff       	call   f0106197 <mpsearch1>
f010629c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010629f:	85 c0                	test   %eax,%eax
f01062a1:	75 1a                	jne    f01062bd <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f01062a3:	ba 00 00 01 00       	mov    $0x10000,%edx
f01062a8:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f01062ad:	e8 e5 fe ff ff       	call   f0106197 <mpsearch1>
f01062b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f01062b5:	85 c0                	test   %eax,%eax
f01062b7:	0f 84 5d 02 00 00    	je     f010651a <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f01062bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01062c0:	8b 70 04             	mov    0x4(%eax),%esi
f01062c3:	85 f6                	test   %esi,%esi
f01062c5:	74 06                	je     f01062cd <mp_init+0x9d>
f01062c7:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f01062cb:	74 15                	je     f01062e2 <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f01062cd:	83 ec 0c             	sub    $0xc,%esp
f01062d0:	68 50 88 10 f0       	push   $0xf0108850
f01062d5:	e8 ae da ff ff       	call   f0103d88 <cprintf>
f01062da:	83 c4 10             	add    $0x10,%esp
f01062dd:	e9 38 02 00 00       	jmp    f010651a <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01062e2:	89 f0                	mov    %esi,%eax
f01062e4:	c1 e8 0c             	shr    $0xc,%eax
f01062e7:	3b 05 88 9e 21 f0    	cmp    0xf0219e88,%eax
f01062ed:	72 15                	jb     f0106304 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01062ef:	56                   	push   %esi
f01062f0:	68 04 6c 10 f0       	push   $0xf0106c04
f01062f5:	68 90 00 00 00       	push   $0x90
f01062fa:	68 dd 89 10 f0       	push   $0xf01089dd
f01062ff:	e8 3c 9d ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106304:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f010630a:	83 ec 04             	sub    $0x4,%esp
f010630d:	6a 04                	push   $0x4
f010630f:	68 f2 89 10 f0       	push   $0xf01089f2
f0106314:	53                   	push   %ebx
f0106315:	e8 c6 fc ff ff       	call   f0105fe0 <memcmp>
f010631a:	83 c4 10             	add    $0x10,%esp
f010631d:	85 c0                	test   %eax,%eax
f010631f:	74 15                	je     f0106336 <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0106321:	83 ec 0c             	sub    $0xc,%esp
f0106324:	68 80 88 10 f0       	push   $0xf0108880
f0106329:	e8 5a da ff ff       	call   f0103d88 <cprintf>
f010632e:	83 c4 10             	add    $0x10,%esp
f0106331:	e9 e4 01 00 00       	jmp    f010651a <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0106336:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f010633a:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f010633e:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0106341:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0106346:	b8 00 00 00 00       	mov    $0x0,%eax
f010634b:	eb 0d                	jmp    f010635a <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f010634d:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0106354:	f0 
f0106355:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106357:	83 c0 01             	add    $0x1,%eax
f010635a:	39 c7                	cmp    %eax,%edi
f010635c:	75 ef                	jne    f010634d <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f010635e:	84 d2                	test   %dl,%dl
f0106360:	74 15                	je     f0106377 <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f0106362:	83 ec 0c             	sub    $0xc,%esp
f0106365:	68 b4 88 10 f0       	push   $0xf01088b4
f010636a:	e8 19 da ff ff       	call   f0103d88 <cprintf>
f010636f:	83 c4 10             	add    $0x10,%esp
f0106372:	e9 a3 01 00 00       	jmp    f010651a <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0106377:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f010637b:	3c 01                	cmp    $0x1,%al
f010637d:	74 1d                	je     f010639c <mp_init+0x16c>
f010637f:	3c 04                	cmp    $0x4,%al
f0106381:	74 19                	je     f010639c <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0106383:	83 ec 08             	sub    $0x8,%esp
f0106386:	0f b6 c0             	movzbl %al,%eax
f0106389:	50                   	push   %eax
f010638a:	68 d8 88 10 f0       	push   $0xf01088d8
f010638f:	e8 f4 d9 ff ff       	call   f0103d88 <cprintf>
f0106394:	83 c4 10             	add    $0x10,%esp
f0106397:	e9 7e 01 00 00       	jmp    f010651a <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010639c:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f01063a0:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f01063a4:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01063a9:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f01063ae:	01 ce                	add    %ecx,%esi
f01063b0:	eb 0d                	jmp    f01063bf <mp_init+0x18f>
f01063b2:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f01063b9:	f0 
f01063ba:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01063bc:	83 c0 01             	add    $0x1,%eax
f01063bf:	39 c7                	cmp    %eax,%edi
f01063c1:	75 ef                	jne    f01063b2 <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01063c3:	89 d0                	mov    %edx,%eax
f01063c5:	02 43 2a             	add    0x2a(%ebx),%al
f01063c8:	74 15                	je     f01063df <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f01063ca:	83 ec 0c             	sub    $0xc,%esp
f01063cd:	68 f8 88 10 f0       	push   $0xf01088f8
f01063d2:	e8 b1 d9 ff ff       	call   f0103d88 <cprintf>
f01063d7:	83 c4 10             	add    $0x10,%esp
f01063da:	e9 3b 01 00 00       	jmp    f010651a <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f01063df:	85 db                	test   %ebx,%ebx
f01063e1:	0f 84 33 01 00 00    	je     f010651a <mp_init+0x2ea>
		return;
	ismp = 1;
f01063e7:	c7 05 00 a0 21 f0 01 	movl   $0x1,0xf021a000
f01063ee:	00 00 00 
	lapicaddr = conf->lapicaddr;
f01063f1:	8b 43 24             	mov    0x24(%ebx),%eax
f01063f4:	a3 00 b0 25 f0       	mov    %eax,0xf025b000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01063f9:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f01063fc:	be 00 00 00 00       	mov    $0x0,%esi
f0106401:	e9 85 00 00 00       	jmp    f010648b <mp_init+0x25b>
		switch (*p) {
f0106406:	0f b6 07             	movzbl (%edi),%eax
f0106409:	84 c0                	test   %al,%al
f010640b:	74 06                	je     f0106413 <mp_init+0x1e3>
f010640d:	3c 04                	cmp    $0x4,%al
f010640f:	77 55                	ja     f0106466 <mp_init+0x236>
f0106411:	eb 4e                	jmp    f0106461 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0106413:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0106417:	74 11                	je     f010642a <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0106419:	6b 05 c4 a3 21 f0 74 	imul   $0x74,0xf021a3c4,%eax
f0106420:	05 20 a0 21 f0       	add    $0xf021a020,%eax
f0106425:	a3 c0 a3 21 f0       	mov    %eax,0xf021a3c0
			if (ncpu < NCPU) {
f010642a:	a1 c4 a3 21 f0       	mov    0xf021a3c4,%eax
f010642f:	83 f8 07             	cmp    $0x7,%eax
f0106432:	7f 13                	jg     f0106447 <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f0106434:	6b d0 74             	imul   $0x74,%eax,%edx
f0106437:	88 82 20 a0 21 f0    	mov    %al,-0xfde5fe0(%edx)
				ncpu++;
f010643d:	83 c0 01             	add    $0x1,%eax
f0106440:	a3 c4 a3 21 f0       	mov    %eax,0xf021a3c4
f0106445:	eb 15                	jmp    f010645c <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106447:	83 ec 08             	sub    $0x8,%esp
f010644a:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f010644e:	50                   	push   %eax
f010644f:	68 28 89 10 f0       	push   $0xf0108928
f0106454:	e8 2f d9 ff ff       	call   f0103d88 <cprintf>
f0106459:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f010645c:	83 c7 14             	add    $0x14,%edi
			continue;
f010645f:	eb 27                	jmp    f0106488 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106461:	83 c7 08             	add    $0x8,%edi
			continue;
f0106464:	eb 22                	jmp    f0106488 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0106466:	83 ec 08             	sub    $0x8,%esp
f0106469:	0f b6 c0             	movzbl %al,%eax
f010646c:	50                   	push   %eax
f010646d:	68 50 89 10 f0       	push   $0xf0108950
f0106472:	e8 11 d9 ff ff       	call   f0103d88 <cprintf>
			ismp = 0;
f0106477:	c7 05 00 a0 21 f0 00 	movl   $0x0,0xf021a000
f010647e:	00 00 00 
			i = conf->entry;
f0106481:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0106485:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106488:	83 c6 01             	add    $0x1,%esi
f010648b:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f010648f:	39 c6                	cmp    %eax,%esi
f0106491:	0f 82 6f ff ff ff    	jb     f0106406 <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0106497:	a1 c0 a3 21 f0       	mov    0xf021a3c0,%eax
f010649c:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f01064a3:	83 3d 00 a0 21 f0 00 	cmpl   $0x0,0xf021a000
f01064aa:	75 26                	jne    f01064d2 <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f01064ac:	c7 05 c4 a3 21 f0 01 	movl   $0x1,0xf021a3c4
f01064b3:	00 00 00 
		lapicaddr = 0;
f01064b6:	c7 05 00 b0 25 f0 00 	movl   $0x0,0xf025b000
f01064bd:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f01064c0:	83 ec 0c             	sub    $0xc,%esp
f01064c3:	68 70 89 10 f0       	push   $0xf0108970
f01064c8:	e8 bb d8 ff ff       	call   f0103d88 <cprintf>
		return;
f01064cd:	83 c4 10             	add    $0x10,%esp
f01064d0:	eb 48                	jmp    f010651a <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01064d2:	83 ec 04             	sub    $0x4,%esp
f01064d5:	ff 35 c4 a3 21 f0    	pushl  0xf021a3c4
f01064db:	0f b6 00             	movzbl (%eax),%eax
f01064de:	50                   	push   %eax
f01064df:	68 f7 89 10 f0       	push   $0xf01089f7
f01064e4:	e8 9f d8 ff ff       	call   f0103d88 <cprintf>

	if (mp->imcrp) {
f01064e9:	83 c4 10             	add    $0x10,%esp
f01064ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01064ef:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01064f3:	74 25                	je     f010651a <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01064f5:	83 ec 0c             	sub    $0xc,%esp
f01064f8:	68 9c 89 10 f0       	push   $0xf010899c
f01064fd:	e8 86 d8 ff ff       	call   f0103d88 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106502:	ba 22 00 00 00       	mov    $0x22,%edx
f0106507:	b8 70 00 00 00       	mov    $0x70,%eax
f010650c:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010650d:	ba 23 00 00 00       	mov    $0x23,%edx
f0106512:	ec                   	in     (%dx),%al
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106513:	83 c8 01             	or     $0x1,%eax
f0106516:	ee                   	out    %al,(%dx)
f0106517:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f010651a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010651d:	5b                   	pop    %ebx
f010651e:	5e                   	pop    %esi
f010651f:	5f                   	pop    %edi
f0106520:	5d                   	pop    %ebp
f0106521:	c3                   	ret    

f0106522 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0106522:	55                   	push   %ebp
f0106523:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0106525:	8b 0d 04 b0 25 f0    	mov    0xf025b004,%ecx
f010652b:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f010652e:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106530:	a1 04 b0 25 f0       	mov    0xf025b004,%eax
f0106535:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106538:	5d                   	pop    %ebp
f0106539:	c3                   	ret    

f010653a <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f010653a:	55                   	push   %ebp
f010653b:	89 e5                	mov    %esp,%ebp
	if (lapic)
f010653d:	a1 04 b0 25 f0       	mov    0xf025b004,%eax
f0106542:	85 c0                	test   %eax,%eax
f0106544:	74 08                	je     f010654e <cpunum+0x14>
		return lapic[ID] >> 24;
f0106546:	8b 40 20             	mov    0x20(%eax),%eax
f0106549:	c1 e8 18             	shr    $0x18,%eax
f010654c:	eb 05                	jmp    f0106553 <cpunum+0x19>
	return 0;
f010654e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106553:	5d                   	pop    %ebp
f0106554:	c3                   	ret    

f0106555 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0106555:	a1 00 b0 25 f0       	mov    0xf025b000,%eax
f010655a:	85 c0                	test   %eax,%eax
f010655c:	0f 84 21 01 00 00    	je     f0106683 <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0106562:	55                   	push   %ebp
f0106563:	89 e5                	mov    %esp,%ebp
f0106565:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0106568:	68 00 10 00 00       	push   $0x1000
f010656d:	50                   	push   %eax
f010656e:	e8 c1 ae ff ff       	call   f0101434 <mmio_map_region>
f0106573:	a3 04 b0 25 f0       	mov    %eax,0xf025b004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0106578:	ba 27 01 00 00       	mov    $0x127,%edx
f010657d:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106582:	e8 9b ff ff ff       	call   f0106522 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0106587:	ba 0b 00 00 00       	mov    $0xb,%edx
f010658c:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0106591:	e8 8c ff ff ff       	call   f0106522 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0106596:	ba 20 00 02 00       	mov    $0x20020,%edx
f010659b:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01065a0:	e8 7d ff ff ff       	call   f0106522 <lapicw>
	lapicw(TICR, 10000000); 
f01065a5:	ba 80 96 98 00       	mov    $0x989680,%edx
f01065aa:	b8 e0 00 00 00       	mov    $0xe0,%eax
f01065af:	e8 6e ff ff ff       	call   f0106522 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f01065b4:	e8 81 ff ff ff       	call   f010653a <cpunum>
f01065b9:	6b c0 74             	imul   $0x74,%eax,%eax
f01065bc:	05 20 a0 21 f0       	add    $0xf021a020,%eax
f01065c1:	83 c4 10             	add    $0x10,%esp
f01065c4:	39 05 c0 a3 21 f0    	cmp    %eax,0xf021a3c0
f01065ca:	74 0f                	je     f01065db <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f01065cc:	ba 00 00 01 00       	mov    $0x10000,%edx
f01065d1:	b8 d4 00 00 00       	mov    $0xd4,%eax
f01065d6:	e8 47 ff ff ff       	call   f0106522 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f01065db:	ba 00 00 01 00       	mov    $0x10000,%edx
f01065e0:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01065e5:	e8 38 ff ff ff       	call   f0106522 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01065ea:	a1 04 b0 25 f0       	mov    0xf025b004,%eax
f01065ef:	8b 40 30             	mov    0x30(%eax),%eax
f01065f2:	c1 e8 10             	shr    $0x10,%eax
f01065f5:	3c 03                	cmp    $0x3,%al
f01065f7:	76 0f                	jbe    f0106608 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f01065f9:	ba 00 00 01 00       	mov    $0x10000,%edx
f01065fe:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0106603:	e8 1a ff ff ff       	call   f0106522 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106608:	ba 33 00 00 00       	mov    $0x33,%edx
f010660d:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106612:	e8 0b ff ff ff       	call   f0106522 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0106617:	ba 00 00 00 00       	mov    $0x0,%edx
f010661c:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106621:	e8 fc fe ff ff       	call   f0106522 <lapicw>
	lapicw(ESR, 0);
f0106626:	ba 00 00 00 00       	mov    $0x0,%edx
f010662b:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106630:	e8 ed fe ff ff       	call   f0106522 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0106635:	ba 00 00 00 00       	mov    $0x0,%edx
f010663a:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010663f:	e8 de fe ff ff       	call   f0106522 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0106644:	ba 00 00 00 00       	mov    $0x0,%edx
f0106649:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010664e:	e8 cf fe ff ff       	call   f0106522 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0106653:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106658:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010665d:	e8 c0 fe ff ff       	call   f0106522 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106662:	8b 15 04 b0 25 f0    	mov    0xf025b004,%edx
f0106668:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010666e:	f6 c4 10             	test   $0x10,%ah
f0106671:	75 f5                	jne    f0106668 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0106673:	ba 00 00 00 00       	mov    $0x0,%edx
f0106678:	b8 20 00 00 00       	mov    $0x20,%eax
f010667d:	e8 a0 fe ff ff       	call   f0106522 <lapicw>
}
f0106682:	c9                   	leave  
f0106683:	f3 c3                	repz ret 

f0106685 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0106685:	83 3d 04 b0 25 f0 00 	cmpl   $0x0,0xf025b004
f010668c:	74 13                	je     f01066a1 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f010668e:	55                   	push   %ebp
f010668f:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0106691:	ba 00 00 00 00       	mov    $0x0,%edx
f0106696:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010669b:	e8 82 fe ff ff       	call   f0106522 <lapicw>
}
f01066a0:	5d                   	pop    %ebp
f01066a1:	f3 c3                	repz ret 

f01066a3 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01066a3:	55                   	push   %ebp
f01066a4:	89 e5                	mov    %esp,%ebp
f01066a6:	56                   	push   %esi
f01066a7:	53                   	push   %ebx
f01066a8:	8b 75 08             	mov    0x8(%ebp),%esi
f01066ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01066ae:	ba 70 00 00 00       	mov    $0x70,%edx
f01066b3:	b8 0f 00 00 00       	mov    $0xf,%eax
f01066b8:	ee                   	out    %al,(%dx)
f01066b9:	ba 71 00 00 00       	mov    $0x71,%edx
f01066be:	b8 0a 00 00 00       	mov    $0xa,%eax
f01066c3:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01066c4:	83 3d 88 9e 21 f0 00 	cmpl   $0x0,0xf0219e88
f01066cb:	75 19                	jne    f01066e6 <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01066cd:	68 67 04 00 00       	push   $0x467
f01066d2:	68 04 6c 10 f0       	push   $0xf0106c04
f01066d7:	68 98 00 00 00       	push   $0x98
f01066dc:	68 14 8a 10 f0       	push   $0xf0108a14
f01066e1:	e8 5a 99 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01066e6:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01066ed:	00 00 
	wrv[1] = addr >> 4;
f01066ef:	89 d8                	mov    %ebx,%eax
f01066f1:	c1 e8 04             	shr    $0x4,%eax
f01066f4:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01066fa:	c1 e6 18             	shl    $0x18,%esi
f01066fd:	89 f2                	mov    %esi,%edx
f01066ff:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106704:	e8 19 fe ff ff       	call   f0106522 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106709:	ba 00 c5 00 00       	mov    $0xc500,%edx
f010670e:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106713:	e8 0a fe ff ff       	call   f0106522 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106718:	ba 00 85 00 00       	mov    $0x8500,%edx
f010671d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106722:	e8 fb fd ff ff       	call   f0106522 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106727:	c1 eb 0c             	shr    $0xc,%ebx
f010672a:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010672d:	89 f2                	mov    %esi,%edx
f010672f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106734:	e8 e9 fd ff ff       	call   f0106522 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106739:	89 da                	mov    %ebx,%edx
f010673b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106740:	e8 dd fd ff ff       	call   f0106522 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106745:	89 f2                	mov    %esi,%edx
f0106747:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010674c:	e8 d1 fd ff ff       	call   f0106522 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106751:	89 da                	mov    %ebx,%edx
f0106753:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106758:	e8 c5 fd ff ff       	call   f0106522 <lapicw>
		microdelay(200);
	}
}
f010675d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106760:	5b                   	pop    %ebx
f0106761:	5e                   	pop    %esi
f0106762:	5d                   	pop    %ebp
f0106763:	c3                   	ret    

f0106764 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106764:	55                   	push   %ebp
f0106765:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106767:	8b 55 08             	mov    0x8(%ebp),%edx
f010676a:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106770:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106775:	e8 a8 fd ff ff       	call   f0106522 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f010677a:	8b 15 04 b0 25 f0    	mov    0xf025b004,%edx
f0106780:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106786:	f6 c4 10             	test   $0x10,%ah
f0106789:	75 f5                	jne    f0106780 <lapic_ipi+0x1c>
		;
}
f010678b:	5d                   	pop    %ebp
f010678c:	c3                   	ret    

f010678d <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f010678d:	55                   	push   %ebp
f010678e:	89 e5                	mov    %esp,%ebp
f0106790:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106793:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106799:	8b 55 0c             	mov    0xc(%ebp),%edx
f010679c:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f010679f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01067a6:	5d                   	pop    %ebp
f01067a7:	c3                   	ret    

f01067a8 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01067a8:	55                   	push   %ebp
f01067a9:	89 e5                	mov    %esp,%ebp
f01067ab:	56                   	push   %esi
f01067ac:	53                   	push   %ebx
f01067ad:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f01067b0:	83 3b 00             	cmpl   $0x0,(%ebx)
f01067b3:	74 14                	je     f01067c9 <spin_lock+0x21>
f01067b5:	8b 73 08             	mov    0x8(%ebx),%esi
f01067b8:	e8 7d fd ff ff       	call   f010653a <cpunum>
f01067bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01067c0:	05 20 a0 21 f0       	add    $0xf021a020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01067c5:	39 c6                	cmp    %eax,%esi
f01067c7:	74 07                	je     f01067d0 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01067c9:	ba 01 00 00 00       	mov    $0x1,%edx
f01067ce:	eb 20                	jmp    f01067f0 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01067d0:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01067d3:	e8 62 fd ff ff       	call   f010653a <cpunum>
f01067d8:	83 ec 0c             	sub    $0xc,%esp
f01067db:	53                   	push   %ebx
f01067dc:	50                   	push   %eax
f01067dd:	68 24 8a 10 f0       	push   $0xf0108a24
f01067e2:	6a 41                	push   $0x41
f01067e4:	68 88 8a 10 f0       	push   $0xf0108a88
f01067e9:	e8 52 98 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f01067ee:	f3 90                	pause  
f01067f0:	89 d0                	mov    %edx,%eax
f01067f2:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f01067f5:	85 c0                	test   %eax,%eax
f01067f7:	75 f5                	jne    f01067ee <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f01067f9:	e8 3c fd ff ff       	call   f010653a <cpunum>
f01067fe:	6b c0 74             	imul   $0x74,%eax,%eax
f0106801:	05 20 a0 21 f0       	add    $0xf021a020,%eax
f0106806:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106809:	83 c3 0c             	add    $0xc,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f010680c:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f010680e:	b8 00 00 00 00       	mov    $0x0,%eax
f0106813:	eb 0b                	jmp    f0106820 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106815:	8b 4a 04             	mov    0x4(%edx),%ecx
f0106818:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f010681b:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f010681d:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106820:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106826:	76 11                	jbe    f0106839 <spin_lock+0x91>
f0106828:	83 f8 09             	cmp    $0x9,%eax
f010682b:	7e e8                	jle    f0106815 <spin_lock+0x6d>
f010682d:	eb 0a                	jmp    f0106839 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f010682f:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106836:	83 c0 01             	add    $0x1,%eax
f0106839:	83 f8 09             	cmp    $0x9,%eax
f010683c:	7e f1                	jle    f010682f <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f010683e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106841:	5b                   	pop    %ebx
f0106842:	5e                   	pop    %esi
f0106843:	5d                   	pop    %ebp
f0106844:	c3                   	ret    

f0106845 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106845:	55                   	push   %ebp
f0106846:	89 e5                	mov    %esp,%ebp
f0106848:	57                   	push   %edi
f0106849:	56                   	push   %esi
f010684a:	53                   	push   %ebx
f010684b:	83 ec 4c             	sub    $0x4c,%esp
f010684e:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0106851:	83 3e 00             	cmpl   $0x0,(%esi)
f0106854:	74 18                	je     f010686e <spin_unlock+0x29>
f0106856:	8b 5e 08             	mov    0x8(%esi),%ebx
f0106859:	e8 dc fc ff ff       	call   f010653a <cpunum>
f010685e:	6b c0 74             	imul   $0x74,%eax,%eax
f0106861:	05 20 a0 21 f0       	add    $0xf021a020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106866:	39 c3                	cmp    %eax,%ebx
f0106868:	0f 84 a5 00 00 00    	je     f0106913 <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f010686e:	83 ec 04             	sub    $0x4,%esp
f0106871:	6a 28                	push   $0x28
f0106873:	8d 46 0c             	lea    0xc(%esi),%eax
f0106876:	50                   	push   %eax
f0106877:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f010687a:	53                   	push   %ebx
f010687b:	e8 e5 f6 ff ff       	call   f0105f65 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106880:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106883:	0f b6 38             	movzbl (%eax),%edi
f0106886:	8b 76 04             	mov    0x4(%esi),%esi
f0106889:	e8 ac fc ff ff       	call   f010653a <cpunum>
f010688e:	57                   	push   %edi
f010688f:	56                   	push   %esi
f0106890:	50                   	push   %eax
f0106891:	68 50 8a 10 f0       	push   $0xf0108a50
f0106896:	e8 ed d4 ff ff       	call   f0103d88 <cprintf>
f010689b:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010689e:	8d 7d a8             	lea    -0x58(%ebp),%edi
f01068a1:	eb 54                	jmp    f01068f7 <spin_unlock+0xb2>
f01068a3:	83 ec 08             	sub    $0x8,%esp
f01068a6:	57                   	push   %edi
f01068a7:	50                   	push   %eax
f01068a8:	e8 83 ec ff ff       	call   f0105530 <debuginfo_eip>
f01068ad:	83 c4 10             	add    $0x10,%esp
f01068b0:	85 c0                	test   %eax,%eax
f01068b2:	78 27                	js     f01068db <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f01068b4:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01068b6:	83 ec 04             	sub    $0x4,%esp
f01068b9:	89 c2                	mov    %eax,%edx
f01068bb:	2b 55 b8             	sub    -0x48(%ebp),%edx
f01068be:	52                   	push   %edx
f01068bf:	ff 75 b0             	pushl  -0x50(%ebp)
f01068c2:	ff 75 b4             	pushl  -0x4c(%ebp)
f01068c5:	ff 75 ac             	pushl  -0x54(%ebp)
f01068c8:	ff 75 a8             	pushl  -0x58(%ebp)
f01068cb:	50                   	push   %eax
f01068cc:	68 98 8a 10 f0       	push   $0xf0108a98
f01068d1:	e8 b2 d4 ff ff       	call   f0103d88 <cprintf>
f01068d6:	83 c4 20             	add    $0x20,%esp
f01068d9:	eb 12                	jmp    f01068ed <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f01068db:	83 ec 08             	sub    $0x8,%esp
f01068de:	ff 36                	pushl  (%esi)
f01068e0:	68 af 8a 10 f0       	push   $0xf0108aaf
f01068e5:	e8 9e d4 ff ff       	call   f0103d88 <cprintf>
f01068ea:	83 c4 10             	add    $0x10,%esp
f01068ed:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f01068f0:	8d 45 e8             	lea    -0x18(%ebp),%eax
f01068f3:	39 c3                	cmp    %eax,%ebx
f01068f5:	74 08                	je     f01068ff <spin_unlock+0xba>
f01068f7:	89 de                	mov    %ebx,%esi
f01068f9:	8b 03                	mov    (%ebx),%eax
f01068fb:	85 c0                	test   %eax,%eax
f01068fd:	75 a4                	jne    f01068a3 <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f01068ff:	83 ec 04             	sub    $0x4,%esp
f0106902:	68 b7 8a 10 f0       	push   $0xf0108ab7
f0106907:	6a 67                	push   $0x67
f0106909:	68 88 8a 10 f0       	push   $0xf0108a88
f010690e:	e8 2d 97 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0106913:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f010691a:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0106921:	b8 00 00 00 00       	mov    $0x0,%eax
f0106926:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0106929:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010692c:	5b                   	pop    %ebx
f010692d:	5e                   	pop    %esi
f010692e:	5f                   	pop    %edi
f010692f:	5d                   	pop    %ebp
f0106930:	c3                   	ret    
f0106931:	66 90                	xchg   %ax,%ax
f0106933:	66 90                	xchg   %ax,%ax
f0106935:	66 90                	xchg   %ax,%ax
f0106937:	66 90                	xchg   %ax,%ax
f0106939:	66 90                	xchg   %ax,%ax
f010693b:	66 90                	xchg   %ax,%ax
f010693d:	66 90                	xchg   %ax,%ax
f010693f:	90                   	nop

f0106940 <__udivdi3>:
f0106940:	55                   	push   %ebp
f0106941:	57                   	push   %edi
f0106942:	56                   	push   %esi
f0106943:	53                   	push   %ebx
f0106944:	83 ec 1c             	sub    $0x1c,%esp
f0106947:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010694b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010694f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0106953:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106957:	85 f6                	test   %esi,%esi
f0106959:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010695d:	89 ca                	mov    %ecx,%edx
f010695f:	89 f8                	mov    %edi,%eax
f0106961:	75 3d                	jne    f01069a0 <__udivdi3+0x60>
f0106963:	39 cf                	cmp    %ecx,%edi
f0106965:	0f 87 c5 00 00 00    	ja     f0106a30 <__udivdi3+0xf0>
f010696b:	85 ff                	test   %edi,%edi
f010696d:	89 fd                	mov    %edi,%ebp
f010696f:	75 0b                	jne    f010697c <__udivdi3+0x3c>
f0106971:	b8 01 00 00 00       	mov    $0x1,%eax
f0106976:	31 d2                	xor    %edx,%edx
f0106978:	f7 f7                	div    %edi
f010697a:	89 c5                	mov    %eax,%ebp
f010697c:	89 c8                	mov    %ecx,%eax
f010697e:	31 d2                	xor    %edx,%edx
f0106980:	f7 f5                	div    %ebp
f0106982:	89 c1                	mov    %eax,%ecx
f0106984:	89 d8                	mov    %ebx,%eax
f0106986:	89 cf                	mov    %ecx,%edi
f0106988:	f7 f5                	div    %ebp
f010698a:	89 c3                	mov    %eax,%ebx
f010698c:	89 d8                	mov    %ebx,%eax
f010698e:	89 fa                	mov    %edi,%edx
f0106990:	83 c4 1c             	add    $0x1c,%esp
f0106993:	5b                   	pop    %ebx
f0106994:	5e                   	pop    %esi
f0106995:	5f                   	pop    %edi
f0106996:	5d                   	pop    %ebp
f0106997:	c3                   	ret    
f0106998:	90                   	nop
f0106999:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01069a0:	39 ce                	cmp    %ecx,%esi
f01069a2:	77 74                	ja     f0106a18 <__udivdi3+0xd8>
f01069a4:	0f bd fe             	bsr    %esi,%edi
f01069a7:	83 f7 1f             	xor    $0x1f,%edi
f01069aa:	0f 84 98 00 00 00    	je     f0106a48 <__udivdi3+0x108>
f01069b0:	bb 20 00 00 00       	mov    $0x20,%ebx
f01069b5:	89 f9                	mov    %edi,%ecx
f01069b7:	89 c5                	mov    %eax,%ebp
f01069b9:	29 fb                	sub    %edi,%ebx
f01069bb:	d3 e6                	shl    %cl,%esi
f01069bd:	89 d9                	mov    %ebx,%ecx
f01069bf:	d3 ed                	shr    %cl,%ebp
f01069c1:	89 f9                	mov    %edi,%ecx
f01069c3:	d3 e0                	shl    %cl,%eax
f01069c5:	09 ee                	or     %ebp,%esi
f01069c7:	89 d9                	mov    %ebx,%ecx
f01069c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01069cd:	89 d5                	mov    %edx,%ebp
f01069cf:	8b 44 24 08          	mov    0x8(%esp),%eax
f01069d3:	d3 ed                	shr    %cl,%ebp
f01069d5:	89 f9                	mov    %edi,%ecx
f01069d7:	d3 e2                	shl    %cl,%edx
f01069d9:	89 d9                	mov    %ebx,%ecx
f01069db:	d3 e8                	shr    %cl,%eax
f01069dd:	09 c2                	or     %eax,%edx
f01069df:	89 d0                	mov    %edx,%eax
f01069e1:	89 ea                	mov    %ebp,%edx
f01069e3:	f7 f6                	div    %esi
f01069e5:	89 d5                	mov    %edx,%ebp
f01069e7:	89 c3                	mov    %eax,%ebx
f01069e9:	f7 64 24 0c          	mull   0xc(%esp)
f01069ed:	39 d5                	cmp    %edx,%ebp
f01069ef:	72 10                	jb     f0106a01 <__udivdi3+0xc1>
f01069f1:	8b 74 24 08          	mov    0x8(%esp),%esi
f01069f5:	89 f9                	mov    %edi,%ecx
f01069f7:	d3 e6                	shl    %cl,%esi
f01069f9:	39 c6                	cmp    %eax,%esi
f01069fb:	73 07                	jae    f0106a04 <__udivdi3+0xc4>
f01069fd:	39 d5                	cmp    %edx,%ebp
f01069ff:	75 03                	jne    f0106a04 <__udivdi3+0xc4>
f0106a01:	83 eb 01             	sub    $0x1,%ebx
f0106a04:	31 ff                	xor    %edi,%edi
f0106a06:	89 d8                	mov    %ebx,%eax
f0106a08:	89 fa                	mov    %edi,%edx
f0106a0a:	83 c4 1c             	add    $0x1c,%esp
f0106a0d:	5b                   	pop    %ebx
f0106a0e:	5e                   	pop    %esi
f0106a0f:	5f                   	pop    %edi
f0106a10:	5d                   	pop    %ebp
f0106a11:	c3                   	ret    
f0106a12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106a18:	31 ff                	xor    %edi,%edi
f0106a1a:	31 db                	xor    %ebx,%ebx
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
f0106a30:	89 d8                	mov    %ebx,%eax
f0106a32:	f7 f7                	div    %edi
f0106a34:	31 ff                	xor    %edi,%edi
f0106a36:	89 c3                	mov    %eax,%ebx
f0106a38:	89 d8                	mov    %ebx,%eax
f0106a3a:	89 fa                	mov    %edi,%edx
f0106a3c:	83 c4 1c             	add    $0x1c,%esp
f0106a3f:	5b                   	pop    %ebx
f0106a40:	5e                   	pop    %esi
f0106a41:	5f                   	pop    %edi
f0106a42:	5d                   	pop    %ebp
f0106a43:	c3                   	ret    
f0106a44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106a48:	39 ce                	cmp    %ecx,%esi
f0106a4a:	72 0c                	jb     f0106a58 <__udivdi3+0x118>
f0106a4c:	31 db                	xor    %ebx,%ebx
f0106a4e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0106a52:	0f 87 34 ff ff ff    	ja     f010698c <__udivdi3+0x4c>
f0106a58:	bb 01 00 00 00       	mov    $0x1,%ebx
f0106a5d:	e9 2a ff ff ff       	jmp    f010698c <__udivdi3+0x4c>
f0106a62:	66 90                	xchg   %ax,%ax
f0106a64:	66 90                	xchg   %ax,%ax
f0106a66:	66 90                	xchg   %ax,%ax
f0106a68:	66 90                	xchg   %ax,%ax
f0106a6a:	66 90                	xchg   %ax,%ax
f0106a6c:	66 90                	xchg   %ax,%ax
f0106a6e:	66 90                	xchg   %ax,%ax

f0106a70 <__umoddi3>:
f0106a70:	55                   	push   %ebp
f0106a71:	57                   	push   %edi
f0106a72:	56                   	push   %esi
f0106a73:	53                   	push   %ebx
f0106a74:	83 ec 1c             	sub    $0x1c,%esp
f0106a77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0106a7b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f0106a7f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106a83:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106a87:	85 d2                	test   %edx,%edx
f0106a89:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0106a8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106a91:	89 f3                	mov    %esi,%ebx
f0106a93:	89 3c 24             	mov    %edi,(%esp)
f0106a96:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106a9a:	75 1c                	jne    f0106ab8 <__umoddi3+0x48>
f0106a9c:	39 f7                	cmp    %esi,%edi
f0106a9e:	76 50                	jbe    f0106af0 <__umoddi3+0x80>
f0106aa0:	89 c8                	mov    %ecx,%eax
f0106aa2:	89 f2                	mov    %esi,%edx
f0106aa4:	f7 f7                	div    %edi
f0106aa6:	89 d0                	mov    %edx,%eax
f0106aa8:	31 d2                	xor    %edx,%edx
f0106aaa:	83 c4 1c             	add    $0x1c,%esp
f0106aad:	5b                   	pop    %ebx
f0106aae:	5e                   	pop    %esi
f0106aaf:	5f                   	pop    %edi
f0106ab0:	5d                   	pop    %ebp
f0106ab1:	c3                   	ret    
f0106ab2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106ab8:	39 f2                	cmp    %esi,%edx
f0106aba:	89 d0                	mov    %edx,%eax
f0106abc:	77 52                	ja     f0106b10 <__umoddi3+0xa0>
f0106abe:	0f bd ea             	bsr    %edx,%ebp
f0106ac1:	83 f5 1f             	xor    $0x1f,%ebp
f0106ac4:	75 5a                	jne    f0106b20 <__umoddi3+0xb0>
f0106ac6:	3b 54 24 04          	cmp    0x4(%esp),%edx
f0106aca:	0f 82 e0 00 00 00    	jb     f0106bb0 <__umoddi3+0x140>
f0106ad0:	39 0c 24             	cmp    %ecx,(%esp)
f0106ad3:	0f 86 d7 00 00 00    	jbe    f0106bb0 <__umoddi3+0x140>
f0106ad9:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106add:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106ae1:	83 c4 1c             	add    $0x1c,%esp
f0106ae4:	5b                   	pop    %ebx
f0106ae5:	5e                   	pop    %esi
f0106ae6:	5f                   	pop    %edi
f0106ae7:	5d                   	pop    %ebp
f0106ae8:	c3                   	ret    
f0106ae9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106af0:	85 ff                	test   %edi,%edi
f0106af2:	89 fd                	mov    %edi,%ebp
f0106af4:	75 0b                	jne    f0106b01 <__umoddi3+0x91>
f0106af6:	b8 01 00 00 00       	mov    $0x1,%eax
f0106afb:	31 d2                	xor    %edx,%edx
f0106afd:	f7 f7                	div    %edi
f0106aff:	89 c5                	mov    %eax,%ebp
f0106b01:	89 f0                	mov    %esi,%eax
f0106b03:	31 d2                	xor    %edx,%edx
f0106b05:	f7 f5                	div    %ebp
f0106b07:	89 c8                	mov    %ecx,%eax
f0106b09:	f7 f5                	div    %ebp
f0106b0b:	89 d0                	mov    %edx,%eax
f0106b0d:	eb 99                	jmp    f0106aa8 <__umoddi3+0x38>
f0106b0f:	90                   	nop
f0106b10:	89 c8                	mov    %ecx,%eax
f0106b12:	89 f2                	mov    %esi,%edx
f0106b14:	83 c4 1c             	add    $0x1c,%esp
f0106b17:	5b                   	pop    %ebx
f0106b18:	5e                   	pop    %esi
f0106b19:	5f                   	pop    %edi
f0106b1a:	5d                   	pop    %ebp
f0106b1b:	c3                   	ret    
f0106b1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106b20:	8b 34 24             	mov    (%esp),%esi
f0106b23:	bf 20 00 00 00       	mov    $0x20,%edi
f0106b28:	89 e9                	mov    %ebp,%ecx
f0106b2a:	29 ef                	sub    %ebp,%edi
f0106b2c:	d3 e0                	shl    %cl,%eax
f0106b2e:	89 f9                	mov    %edi,%ecx
f0106b30:	89 f2                	mov    %esi,%edx
f0106b32:	d3 ea                	shr    %cl,%edx
f0106b34:	89 e9                	mov    %ebp,%ecx
f0106b36:	09 c2                	or     %eax,%edx
f0106b38:	89 d8                	mov    %ebx,%eax
f0106b3a:	89 14 24             	mov    %edx,(%esp)
f0106b3d:	89 f2                	mov    %esi,%edx
f0106b3f:	d3 e2                	shl    %cl,%edx
f0106b41:	89 f9                	mov    %edi,%ecx
f0106b43:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106b47:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0106b4b:	d3 e8                	shr    %cl,%eax
f0106b4d:	89 e9                	mov    %ebp,%ecx
f0106b4f:	89 c6                	mov    %eax,%esi
f0106b51:	d3 e3                	shl    %cl,%ebx
f0106b53:	89 f9                	mov    %edi,%ecx
f0106b55:	89 d0                	mov    %edx,%eax
f0106b57:	d3 e8                	shr    %cl,%eax
f0106b59:	89 e9                	mov    %ebp,%ecx
f0106b5b:	09 d8                	or     %ebx,%eax
f0106b5d:	89 d3                	mov    %edx,%ebx
f0106b5f:	89 f2                	mov    %esi,%edx
f0106b61:	f7 34 24             	divl   (%esp)
f0106b64:	89 d6                	mov    %edx,%esi
f0106b66:	d3 e3                	shl    %cl,%ebx
f0106b68:	f7 64 24 04          	mull   0x4(%esp)
f0106b6c:	39 d6                	cmp    %edx,%esi
f0106b6e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106b72:	89 d1                	mov    %edx,%ecx
f0106b74:	89 c3                	mov    %eax,%ebx
f0106b76:	72 08                	jb     f0106b80 <__umoddi3+0x110>
f0106b78:	75 11                	jne    f0106b8b <__umoddi3+0x11b>
f0106b7a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0106b7e:	73 0b                	jae    f0106b8b <__umoddi3+0x11b>
f0106b80:	2b 44 24 04          	sub    0x4(%esp),%eax
f0106b84:	1b 14 24             	sbb    (%esp),%edx
f0106b87:	89 d1                	mov    %edx,%ecx
f0106b89:	89 c3                	mov    %eax,%ebx
f0106b8b:	8b 54 24 08          	mov    0x8(%esp),%edx
f0106b8f:	29 da                	sub    %ebx,%edx
f0106b91:	19 ce                	sbb    %ecx,%esi
f0106b93:	89 f9                	mov    %edi,%ecx
f0106b95:	89 f0                	mov    %esi,%eax
f0106b97:	d3 e0                	shl    %cl,%eax
f0106b99:	89 e9                	mov    %ebp,%ecx
f0106b9b:	d3 ea                	shr    %cl,%edx
f0106b9d:	89 e9                	mov    %ebp,%ecx
f0106b9f:	d3 ee                	shr    %cl,%esi
f0106ba1:	09 d0                	or     %edx,%eax
f0106ba3:	89 f2                	mov    %esi,%edx
f0106ba5:	83 c4 1c             	add    $0x1c,%esp
f0106ba8:	5b                   	pop    %ebx
f0106ba9:	5e                   	pop    %esi
f0106baa:	5f                   	pop    %edi
f0106bab:	5d                   	pop    %ebp
f0106bac:	c3                   	ret    
f0106bad:	8d 76 00             	lea    0x0(%esi),%esi
f0106bb0:	29 f9                	sub    %edi,%ecx
f0106bb2:	19 d6                	sbb    %edx,%esi
f0106bb4:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106bb8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106bbc:	e9 18 ff ff ff       	jmp    f0106ad9 <__umoddi3+0x69>
