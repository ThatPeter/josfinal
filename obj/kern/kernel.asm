
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
f0100048:	83 3d 80 8e 21 f0 00 	cmpl   $0x0,0xf0218e80
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 80 8e 21 f0    	mov    %esi,0xf0218e80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 29 63 00 00       	call   f010638a <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 20 6a 10 f0       	push   $0xf0106a20
f010006d:	e8 f6 3b 00 00       	call   f0103c68 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 c6 3b 00 00       	call   f0103c42 <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 5a 82 10 f0 	movl   $0xf010825a,(%esp)
f0100083:	e8 e0 3b 00 00       	call   f0103c68 <cprintf>
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
f01000a1:	b8 08 a0 25 f0       	mov    $0xf025a008,%eax
f01000a6:	2d 64 73 21 f0       	sub    $0xf0217364,%eax
f01000ab:	50                   	push   %eax
f01000ac:	6a 00                	push   $0x0
f01000ae:	68 64 73 21 f0       	push   $0xf0217364
f01000b3:	e8 b2 5c 00 00       	call   f0105d6a <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b8:	e8 96 05 00 00       	call   f0100653 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000bd:	83 c4 08             	add    $0x8,%esp
f01000c0:	68 ac 1a 00 00       	push   $0x1aac
f01000c5:	68 8c 6a 10 f0       	push   $0xf0106a8c
f01000ca:	e8 99 3b 00 00       	call   f0103c68 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000cf:	e8 c0 13 00 00       	call   f0101494 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000d4:	e8 b9 30 00 00       	call   f0103192 <env_init>
	trap_init();
f01000d9:	e8 85 3c 00 00       	call   f0103d63 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000de:	e8 9d 5f 00 00       	call   f0106080 <mp_init>
	lapic_init();
f01000e3:	e8 bd 62 00 00       	call   f01063a5 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000e8:	e8 a2 3a 00 00       	call   f0103b8f <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000ed:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f01000f4:	e8 ff 64 00 00       	call   f01065f8 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000f9:	83 c4 10             	add    $0x10,%esp
f01000fc:	83 3d 88 8e 21 f0 07 	cmpl   $0x7,0xf0218e88
f0100103:	77 16                	ja     f010011b <i386_init+0x81>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100105:	68 00 70 00 00       	push   $0x7000
f010010a:	68 44 6a 10 f0       	push   $0xf0106a44
f010010f:	6a 58                	push   $0x58
f0100111:	68 a7 6a 10 f0       	push   $0xf0106aa7
f0100116:	e8 25 ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010011b:	83 ec 04             	sub    $0x4,%esp
f010011e:	b8 e6 5f 10 f0       	mov    $0xf0105fe6,%eax
f0100123:	2d 6c 5f 10 f0       	sub    $0xf0105f6c,%eax
f0100128:	50                   	push   %eax
f0100129:	68 6c 5f 10 f0       	push   $0xf0105f6c
f010012e:	68 00 70 00 f0       	push   $0xf0007000
f0100133:	e8 7f 5c 00 00       	call   f0105db7 <memmove>
f0100138:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010013b:	bb 20 90 21 f0       	mov    $0xf0219020,%ebx
f0100140:	eb 4d                	jmp    f010018f <i386_init+0xf5>
		if (c == cpus + cpunum())  // We've started already.
f0100142:	e8 43 62 00 00       	call   f010638a <cpunum>
f0100147:	6b c0 74             	imul   $0x74,%eax,%eax
f010014a:	05 20 90 21 f0       	add    $0xf0219020,%eax
f010014f:	39 c3                	cmp    %eax,%ebx
f0100151:	74 39                	je     f010018c <i386_init+0xf2>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100153:	89 d8                	mov    %ebx,%eax
f0100155:	2d 20 90 21 f0       	sub    $0xf0219020,%eax
f010015a:	c1 f8 02             	sar    $0x2,%eax
f010015d:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100163:	c1 e0 0f             	shl    $0xf,%eax
f0100166:	05 00 20 22 f0       	add    $0xf0222000,%eax
f010016b:	a3 84 8e 21 f0       	mov    %eax,0xf0218e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100170:	83 ec 08             	sub    $0x8,%esp
f0100173:	68 00 70 00 00       	push   $0x7000
f0100178:	0f b6 03             	movzbl (%ebx),%eax
f010017b:	50                   	push   %eax
f010017c:	e8 72 63 00 00       	call   f01064f3 <lapic_startap>
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
f010018f:	6b 05 c4 93 21 f0 74 	imul   $0x74,0xf02193c4,%eax
f0100196:	05 20 90 21 f0       	add    $0xf0219020,%eax
f010019b:	39 c3                	cmp    %eax,%ebx
f010019d:	72 a3                	jb     f0100142 <i386_init+0xa8>
	lock_kernel();

	// Starting non-boot CPUs
	boot_aps();

	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f010019f:	83 ec 08             	sub    $0x8,%esp
f01001a2:	6a 01                	push   $0x1
f01001a4:	68 b8 60 1d f0       	push   $0xf01d60b8
f01001a9:	e8 57 32 00 00       	call   f0103405 <env_create>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001ae:	83 c4 08             	add    $0x8,%esp
f01001b1:	6a 00                	push   $0x0
f01001b3:	68 d8 23 21 f0       	push   $0xf02123d8
f01001b8:	e8 48 32 00 00       	call   f0103405 <env_create>
	// Touch all you want. Calls fork.
	ENV_CREATE(user_primes, ENV_TYPE_USER);
#endif // TEST* 
	
	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f01001bd:	e8 35 04 00 00       	call   f01005f7 <kbd_intr>
	// Schedule and run the first user environment!
	sched_yield();
f01001c2:	e8 1b 49 00 00       	call   f0104ae2 <sched_yield>

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
f01001cd:	a1 8c 8e 21 f0       	mov    0xf0218e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001d2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001d7:	77 12                	ja     f01001eb <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001d9:	50                   	push   %eax
f01001da:	68 68 6a 10 f0       	push   $0xf0106a68
f01001df:	6a 6f                	push   $0x6f
f01001e1:	68 a7 6a 10 f0       	push   $0xf0106aa7
f01001e6:	e8 55 fe ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001eb:	05 00 00 00 10       	add    $0x10000000,%eax
f01001f0:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001f3:	e8 92 61 00 00       	call   f010638a <cpunum>
f01001f8:	83 ec 08             	sub    $0x8,%esp
f01001fb:	50                   	push   %eax
f01001fc:	68 b3 6a 10 f0       	push   $0xf0106ab3
f0100201:	e8 62 3a 00 00       	call   f0103c68 <cprintf>

	lapic_init();
f0100206:	e8 9a 61 00 00       	call   f01063a5 <lapic_init>
	env_init_percpu();
f010020b:	e8 52 2f 00 00       	call   f0103162 <env_init_percpu>
	trap_init_percpu();
f0100210:	e8 67 3a 00 00       	call   f0103c7c <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100215:	e8 70 61 00 00       	call   f010638a <cpunum>
f010021a:	6b d0 74             	imul   $0x74,%eax,%edx
f010021d:	81 c2 20 90 21 f0    	add    $0xf0219020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100223:	b8 01 00 00 00       	mov    $0x1,%eax
f0100228:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010022c:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f0100233:	e8 c0 63 00 00       	call   f01065f8 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100238:	e8 a5 48 00 00       	call   f0104ae2 <sched_yield>

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
f010024d:	68 c9 6a 10 f0       	push   $0xf0106ac9
f0100252:	e8 11 3a 00 00       	call   f0103c68 <cprintf>
	vcprintf(fmt, ap);
f0100257:	83 c4 08             	add    $0x8,%esp
f010025a:	53                   	push   %ebx
f010025b:	ff 75 10             	pushl  0x10(%ebp)
f010025e:	e8 df 39 00 00       	call   f0103c42 <vcprintf>
	cprintf("\n");
f0100263:	c7 04 24 5a 82 10 f0 	movl   $0xf010825a,(%esp)
f010026a:	e8 f9 39 00 00       	call   f0103c68 <cprintf>
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
f01002a5:	8b 0d 24 82 21 f0    	mov    0xf0218224,%ecx
f01002ab:	8d 51 01             	lea    0x1(%ecx),%edx
f01002ae:	89 15 24 82 21 f0    	mov    %edx,0xf0218224
f01002b4:	88 81 20 80 21 f0    	mov    %al,-0xfde7fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002ba:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002c0:	75 0a                	jne    f01002cc <cons_intr+0x36>
			cons.wpos = 0;
f01002c2:	c7 05 24 82 21 f0 00 	movl   $0x0,0xf0218224
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
f01002fb:	83 0d 00 80 21 f0 40 	orl    $0x40,0xf0218000
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
f0100313:	8b 0d 00 80 21 f0    	mov    0xf0218000,%ecx
f0100319:	89 cb                	mov    %ecx,%ebx
f010031b:	83 e3 40             	and    $0x40,%ebx
f010031e:	83 e0 7f             	and    $0x7f,%eax
f0100321:	85 db                	test   %ebx,%ebx
f0100323:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100326:	0f b6 d2             	movzbl %dl,%edx
f0100329:	0f b6 82 40 6c 10 f0 	movzbl -0xfef93c0(%edx),%eax
f0100330:	83 c8 40             	or     $0x40,%eax
f0100333:	0f b6 c0             	movzbl %al,%eax
f0100336:	f7 d0                	not    %eax
f0100338:	21 c8                	and    %ecx,%eax
f010033a:	a3 00 80 21 f0       	mov    %eax,0xf0218000
		return 0;
f010033f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100344:	e9 a4 00 00 00       	jmp    f01003ed <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100349:	8b 0d 00 80 21 f0    	mov    0xf0218000,%ecx
f010034f:	f6 c1 40             	test   $0x40,%cl
f0100352:	74 0e                	je     f0100362 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100354:	83 c8 80             	or     $0xffffff80,%eax
f0100357:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100359:	83 e1 bf             	and    $0xffffffbf,%ecx
f010035c:	89 0d 00 80 21 f0    	mov    %ecx,0xf0218000
	}

	shift |= shiftcode[data];
f0100362:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100365:	0f b6 82 40 6c 10 f0 	movzbl -0xfef93c0(%edx),%eax
f010036c:	0b 05 00 80 21 f0    	or     0xf0218000,%eax
f0100372:	0f b6 8a 40 6b 10 f0 	movzbl -0xfef94c0(%edx),%ecx
f0100379:	31 c8                	xor    %ecx,%eax
f010037b:	a3 00 80 21 f0       	mov    %eax,0xf0218000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100380:	89 c1                	mov    %eax,%ecx
f0100382:	83 e1 03             	and    $0x3,%ecx
f0100385:	8b 0c 8d 20 6b 10 f0 	mov    -0xfef94e0(,%ecx,4),%ecx
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
f01003c3:	68 e3 6a 10 f0       	push   $0xf0106ae3
f01003c8:	e8 9b 38 00 00       	call   f0103c68 <cprintf>
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
f01004af:	0f b7 05 28 82 21 f0 	movzwl 0xf0218228,%eax
f01004b6:	66 85 c0             	test   %ax,%ax
f01004b9:	0f 84 e6 00 00 00    	je     f01005a5 <cons_putc+0x1b3>
			crt_pos--;
f01004bf:	83 e8 01             	sub    $0x1,%eax
f01004c2:	66 a3 28 82 21 f0    	mov    %ax,0xf0218228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004c8:	0f b7 c0             	movzwl %ax,%eax
f01004cb:	66 81 e7 00 ff       	and    $0xff00,%di
f01004d0:	83 cf 20             	or     $0x20,%edi
f01004d3:	8b 15 2c 82 21 f0    	mov    0xf021822c,%edx
f01004d9:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004dd:	eb 78                	jmp    f0100557 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004df:	66 83 05 28 82 21 f0 	addw   $0x50,0xf0218228
f01004e6:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004e7:	0f b7 05 28 82 21 f0 	movzwl 0xf0218228,%eax
f01004ee:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004f4:	c1 e8 16             	shr    $0x16,%eax
f01004f7:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004fa:	c1 e0 04             	shl    $0x4,%eax
f01004fd:	66 a3 28 82 21 f0    	mov    %ax,0xf0218228
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
f0100539:	0f b7 05 28 82 21 f0 	movzwl 0xf0218228,%eax
f0100540:	8d 50 01             	lea    0x1(%eax),%edx
f0100543:	66 89 15 28 82 21 f0 	mov    %dx,0xf0218228
f010054a:	0f b7 c0             	movzwl %ax,%eax
f010054d:	8b 15 2c 82 21 f0    	mov    0xf021822c,%edx
f0100553:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100557:	66 81 3d 28 82 21 f0 	cmpw   $0x7cf,0xf0218228
f010055e:	cf 07 
f0100560:	76 43                	jbe    f01005a5 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100562:	a1 2c 82 21 f0       	mov    0xf021822c,%eax
f0100567:	83 ec 04             	sub    $0x4,%esp
f010056a:	68 00 0f 00 00       	push   $0xf00
f010056f:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100575:	52                   	push   %edx
f0100576:	50                   	push   %eax
f0100577:	e8 3b 58 00 00       	call   f0105db7 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010057c:	8b 15 2c 82 21 f0    	mov    0xf021822c,%edx
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
f010059d:	66 83 2d 28 82 21 f0 	subw   $0x50,0xf0218228
f01005a4:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01005a5:	8b 0d 30 82 21 f0    	mov    0xf0218230,%ecx
f01005ab:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005b0:	89 ca                	mov    %ecx,%edx
f01005b2:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005b3:	0f b7 1d 28 82 21 f0 	movzwl 0xf0218228,%ebx
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
f01005db:	80 3d 34 82 21 f0 00 	cmpb   $0x0,0xf0218234
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
f0100619:	a1 20 82 21 f0       	mov    0xf0218220,%eax
f010061e:	3b 05 24 82 21 f0    	cmp    0xf0218224,%eax
f0100624:	74 26                	je     f010064c <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100626:	8d 50 01             	lea    0x1(%eax),%edx
f0100629:	89 15 20 82 21 f0    	mov    %edx,0xf0218220
f010062f:	0f b6 88 20 80 21 f0 	movzbl -0xfde7fe0(%eax),%ecx
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
f0100640:	c7 05 20 82 21 f0 00 	movl   $0x0,0xf0218220
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
f0100679:	c7 05 30 82 21 f0 b4 	movl   $0x3b4,0xf0218230
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
f0100691:	c7 05 30 82 21 f0 d4 	movl   $0x3d4,0xf0218230
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
f01006a0:	8b 3d 30 82 21 f0    	mov    0xf0218230,%edi
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
f01006c5:	89 35 2c 82 21 f0    	mov    %esi,0xf021822c
	crt_pos = pos;
f01006cb:	0f b6 c0             	movzbl %al,%eax
f01006ce:	09 c8                	or     %ecx,%eax
f01006d0:	66 a3 28 82 21 f0    	mov    %ax,0xf0218228

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
f01006eb:	e8 27 34 00 00       	call   f0103b17 <irq_setmask_8259A>
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
f010074e:	0f 95 05 34 82 21 f0 	setne  0xf0218234
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
f0100770:	e8 a2 33 00 00       	call   f0103b17 <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100775:	83 c4 10             	add    $0x10,%esp
f0100778:	80 3d 34 82 21 f0 00 	cmpb   $0x0,0xf0218234
f010077f:	75 10                	jne    f0100791 <cons_init+0x13e>
		cprintf("Serial port does not exist!\n");
f0100781:	83 ec 0c             	sub    $0xc,%esp
f0100784:	68 ef 6a 10 f0       	push   $0xf0106aef
f0100789:	e8 da 34 00 00       	call   f0103c68 <cprintf>
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
f01007ca:	68 40 6d 10 f0       	push   $0xf0106d40
f01007cf:	68 5e 6d 10 f0       	push   $0xf0106d5e
f01007d4:	68 63 6d 10 f0       	push   $0xf0106d63
f01007d9:	e8 8a 34 00 00       	call   f0103c68 <cprintf>
f01007de:	83 c4 0c             	add    $0xc,%esp
f01007e1:	68 1c 6e 10 f0       	push   $0xf0106e1c
f01007e6:	68 6c 6d 10 f0       	push   $0xf0106d6c
f01007eb:	68 63 6d 10 f0       	push   $0xf0106d63
f01007f0:	e8 73 34 00 00       	call   f0103c68 <cprintf>
f01007f5:	83 c4 0c             	add    $0xc,%esp
f01007f8:	68 75 6d 10 f0       	push   $0xf0106d75
f01007fd:	68 7d 6d 10 f0       	push   $0xf0106d7d
f0100802:	68 63 6d 10 f0       	push   $0xf0106d63
f0100807:	e8 5c 34 00 00       	call   f0103c68 <cprintf>
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
f0100819:	68 87 6d 10 f0       	push   $0xf0106d87
f010081e:	e8 45 34 00 00       	call   f0103c68 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100823:	83 c4 08             	add    $0x8,%esp
f0100826:	68 0c 00 10 00       	push   $0x10000c
f010082b:	68 44 6e 10 f0       	push   $0xf0106e44
f0100830:	e8 33 34 00 00       	call   f0103c68 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100835:	83 c4 0c             	add    $0xc,%esp
f0100838:	68 0c 00 10 00       	push   $0x10000c
f010083d:	68 0c 00 10 f0       	push   $0xf010000c
f0100842:	68 6c 6e 10 f0       	push   $0xf0106e6c
f0100847:	e8 1c 34 00 00       	call   f0103c68 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010084c:	83 c4 0c             	add    $0xc,%esp
f010084f:	68 11 6a 10 00       	push   $0x106a11
f0100854:	68 11 6a 10 f0       	push   $0xf0106a11
f0100859:	68 90 6e 10 f0       	push   $0xf0106e90
f010085e:	e8 05 34 00 00       	call   f0103c68 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100863:	83 c4 0c             	add    $0xc,%esp
f0100866:	68 64 73 21 00       	push   $0x217364
f010086b:	68 64 73 21 f0       	push   $0xf0217364
f0100870:	68 b4 6e 10 f0       	push   $0xf0106eb4
f0100875:	e8 ee 33 00 00       	call   f0103c68 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010087a:	83 c4 0c             	add    $0xc,%esp
f010087d:	68 08 a0 25 00       	push   $0x25a008
f0100882:	68 08 a0 25 f0       	push   $0xf025a008
f0100887:	68 d8 6e 10 f0       	push   $0xf0106ed8
f010088c:	e8 d7 33 00 00       	call   f0103c68 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100891:	b8 07 a4 25 f0       	mov    $0xf025a407,%eax
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
f01008b2:	68 fc 6e 10 f0       	push   $0xf0106efc
f01008b7:	e8 ac 33 00 00       	call   f0103c68 <cprintf>
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
f01008ce:	68 a0 6d 10 f0       	push   $0xf0106da0
f01008d3:	e8 90 33 00 00       	call   f0103c68 <cprintf>
	
	while (ebp != 0) {
f01008d8:	83 c4 10             	add    $0x10,%esp
f01008db:	eb 67                	jmp    f0100944 <mon_backtrace+0x81>
		eip = ebp + 1;	   //eip is stored after ebp
		cprintf("ebp %x eip %x args ", ebp, *eip);
f01008dd:	83 ec 04             	sub    $0x4,%esp
f01008e0:	ff 76 04             	pushl  0x4(%esi)
f01008e3:	56                   	push   %esi
f01008e4:	68 b2 6d 10 f0       	push   $0xf0106db2
f01008e9:	e8 7a 33 00 00       	call   f0103c68 <cprintf>
f01008ee:	8d 5e 08             	lea    0x8(%esi),%ebx
f01008f1:	8d 7e 1c             	lea    0x1c(%esi),%edi
f01008f4:	83 c4 10             	add    $0x10,%esp

		size_t arg_num;
		//print arguments stored after instruction pointer
		for (arg_num = 1; arg_num <= 5; arg_num++) {
			cprintf("%08x ", *(eip + arg_num));
f01008f7:	83 ec 08             	sub    $0x8,%esp
f01008fa:	ff 33                	pushl  (%ebx)
f01008fc:	68 c6 6d 10 f0       	push   $0xf0106dc6
f0100901:	e8 62 33 00 00       	call   f0103c68 <cprintf>
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
f010091a:	e8 63 4a 00 00       	call   f0105382 <debuginfo_eip>

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
f0100935:	68 cc 6d 10 f0       	push   $0xf0106dcc
f010093a:	e8 29 33 00 00       	call   f0103c68 <cprintf>
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
f010095e:	68 28 6f 10 f0       	push   $0xf0106f28
f0100963:	e8 00 33 00 00       	call   f0103c68 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100968:	c7 04 24 4c 6f 10 f0 	movl   $0xf0106f4c,(%esp)
f010096f:	e8 f4 32 00 00       	call   f0103c68 <cprintf>

	if (tf != NULL)
f0100974:	83 c4 10             	add    $0x10,%esp
f0100977:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010097b:	74 0e                	je     f010098b <monitor+0x36>
		print_trapframe(tf);
f010097d:	83 ec 0c             	sub    $0xc,%esp
f0100980:	ff 75 08             	pushl  0x8(%ebp)
f0100983:	e8 57 3a 00 00       	call   f01043df <print_trapframe>
f0100988:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f010098b:	83 ec 0c             	sub    $0xc,%esp
f010098e:	68 de 6d 10 f0       	push   $0xf0106dde
f0100993:	e8 63 51 00 00       	call   f0105afb <readline>
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
f01009c7:	68 e2 6d 10 f0       	push   $0xf0106de2
f01009cc:	e8 5c 53 00 00       	call   f0105d2d <strchr>
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
f01009e7:	68 e7 6d 10 f0       	push   $0xf0106de7
f01009ec:	e8 77 32 00 00       	call   f0103c68 <cprintf>
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
f0100a10:	68 e2 6d 10 f0       	push   $0xf0106de2
f0100a15:	e8 13 53 00 00       	call   f0105d2d <strchr>
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
f0100a3e:	ff 34 85 80 6f 10 f0 	pushl  -0xfef9080(,%eax,4)
f0100a45:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a48:	e8 82 52 00 00       	call   f0105ccf <strcmp>
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
f0100a62:	ff 14 85 88 6f 10 f0 	call   *-0xfef9078(,%eax,4)
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
f0100a83:	68 04 6e 10 f0       	push   $0xf0106e04
f0100a88:	e8 db 31 00 00       	call   f0103c68 <cprintf>
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
f0100aa8:	e8 3c 30 00 00       	call   f0103ae9 <mc146818_read>
f0100aad:	89 c6                	mov    %eax,%esi
f0100aaf:	83 c3 01             	add    $0x1,%ebx
f0100ab2:	89 1c 24             	mov    %ebx,(%esp)
f0100ab5:	e8 2f 30 00 00       	call   f0103ae9 <mc146818_read>
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
f0100adc:	3b 0d 88 8e 21 f0    	cmp    0xf0218e88,%ecx
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
f0100aeb:	68 44 6a 10 f0       	push   $0xf0106a44
f0100af0:	68 cd 03 00 00       	push   $0x3cd
f0100af5:	68 11 79 10 f0       	push   $0xf0107911
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
f0100b2a:	83 3d 38 82 21 f0 00 	cmpl   $0x0,0xf0218238
f0100b31:	75 11                	jne    f0100b44 <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100b33:	ba 07 b0 25 f0       	mov    $0xf025b007,%edx
f0100b38:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b3e:	89 15 38 82 21 f0    	mov    %edx,0xf0218238
        // Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
        if (n == 0)
f0100b44:	85 c0                	test   %eax,%eax
f0100b46:	75 06                	jne    f0100b4e <boot_alloc+0x24>
                return nextfree;
f0100b48:	a1 38 82 21 f0       	mov    0xf0218238,%eax

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
f0100b57:	8b 15 38 82 21 f0    	mov    0xf0218238,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100b5d:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100b63:	77 12                	ja     f0100b77 <boot_alloc+0x4d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100b65:	52                   	push   %edx
f0100b66:	68 68 6a 10 f0       	push   $0xf0106a68
f0100b6b:	6a 70                	push   $0x70
f0100b6d:	68 11 79 10 f0       	push   $0xf0107911
f0100b72:	e8 c9 f4 ff ff       	call   f0100040 <_panic>
f0100b77:	b8 00 00 40 f0       	mov    $0xf0400000,%eax
f0100b7c:	29 d0                	sub    %edx,%eax
f0100b7e:	39 c3                	cmp    %eax,%ebx
f0100b80:	76 14                	jbe    f0100b96 <boot_alloc+0x6c>
               panic("boot_alloc: ran out of free memory"); 
f0100b82:	83 ec 04             	sub    $0x4,%esp
f0100b85:	68 a4 6f 10 f0       	push   $0xf0106fa4
f0100b8a:	6a 71                	push   $0x71
f0100b8c:	68 11 79 10 f0       	push   $0xf0107911
f0100b91:	e8 aa f4 ff ff       	call   f0100040 <_panic>
	cprintf("in boot alloc: free mem: %d\n",(4 * 1024 * 1024 - PADDR(nextfree)));
f0100b96:	83 ec 08             	sub    $0x8,%esp
f0100b99:	50                   	push   %eax
f0100b9a:	68 1d 79 10 f0       	push   $0xf010791d
f0100b9f:	e8 c4 30 00 00       	call   f0103c68 <cprintf>

        result = nextfree;        
f0100ba4:	a1 38 82 21 f0       	mov    0xf0218238,%eax
        nextfree = ROUNDUP((char *) (nextfree + n), PGSIZE);
f0100ba9:	8d 94 18 ff 0f 00 00 	lea    0xfff(%eax,%ebx,1),%edx
f0100bb0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100bb6:	89 15 38 82 21 f0    	mov    %edx,0xf0218238

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
f0100bdd:	68 c8 6f 10 f0       	push   $0xf0106fc8
f0100be2:	68 00 03 00 00       	push   $0x300
f0100be7:	68 11 79 10 f0       	push   $0xf0107911
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
f0100bff:	2b 15 90 8e 21 f0    	sub    0xf0218e90,%edx
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
f0100c35:	a3 40 82 21 f0       	mov    %eax,0xf0218240
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
f0100c3f:	8b 1d 40 82 21 f0    	mov    0xf0218240,%ebx
f0100c45:	eb 53                	jmp    f0100c9a <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c47:	89 d8                	mov    %ebx,%eax
f0100c49:	2b 05 90 8e 21 f0    	sub    0xf0218e90,%eax
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
f0100c63:	3b 15 88 8e 21 f0    	cmp    0xf0218e88,%edx
f0100c69:	72 12                	jb     f0100c7d <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c6b:	50                   	push   %eax
f0100c6c:	68 44 6a 10 f0       	push   $0xf0106a44
f0100c71:	6a 58                	push   $0x58
f0100c73:	68 3a 79 10 f0       	push   $0xf010793a
f0100c78:	e8 c3 f3 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c7d:	83 ec 04             	sub    $0x4,%esp
f0100c80:	68 80 00 00 00       	push   $0x80
f0100c85:	68 97 00 00 00       	push   $0x97
f0100c8a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c8f:	50                   	push   %eax
f0100c90:	e8 d5 50 00 00       	call   f0105d6a <memset>
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
f0100cab:	8b 15 40 82 21 f0    	mov    0xf0218240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100cb1:	8b 0d 90 8e 21 f0    	mov    0xf0218e90,%ecx
		assert(pp < pages + npages);
f0100cb7:	a1 88 8e 21 f0       	mov    0xf0218e88,%eax
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
f0100cd6:	68 48 79 10 f0       	push   $0xf0107948
f0100cdb:	68 54 79 10 f0       	push   $0xf0107954
f0100ce0:	68 1a 03 00 00       	push   $0x31a
f0100ce5:	68 11 79 10 f0       	push   $0xf0107911
f0100cea:	e8 51 f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100cef:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100cf2:	72 19                	jb     f0100d0d <check_page_free_list+0x149>
f0100cf4:	68 69 79 10 f0       	push   $0xf0107969
f0100cf9:	68 54 79 10 f0       	push   $0xf0107954
f0100cfe:	68 1b 03 00 00       	push   $0x31b
f0100d03:	68 11 79 10 f0       	push   $0xf0107911
f0100d08:	e8 33 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d0d:	89 d0                	mov    %edx,%eax
f0100d0f:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100d12:	a8 07                	test   $0x7,%al
f0100d14:	74 19                	je     f0100d2f <check_page_free_list+0x16b>
f0100d16:	68 ec 6f 10 f0       	push   $0xf0106fec
f0100d1b:	68 54 79 10 f0       	push   $0xf0107954
f0100d20:	68 1c 03 00 00       	push   $0x31c
f0100d25:	68 11 79 10 f0       	push   $0xf0107911
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
f0100d39:	68 7d 79 10 f0       	push   $0xf010797d
f0100d3e:	68 54 79 10 f0       	push   $0xf0107954
f0100d43:	68 1f 03 00 00       	push   $0x31f
f0100d48:	68 11 79 10 f0       	push   $0xf0107911
f0100d4d:	e8 ee f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d52:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d57:	75 19                	jne    f0100d72 <check_page_free_list+0x1ae>
f0100d59:	68 8e 79 10 f0       	push   $0xf010798e
f0100d5e:	68 54 79 10 f0       	push   $0xf0107954
f0100d63:	68 20 03 00 00       	push   $0x320
f0100d68:	68 11 79 10 f0       	push   $0xf0107911
f0100d6d:	e8 ce f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d72:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d77:	75 19                	jne    f0100d92 <check_page_free_list+0x1ce>
f0100d79:	68 20 70 10 f0       	push   $0xf0107020
f0100d7e:	68 54 79 10 f0       	push   $0xf0107954
f0100d83:	68 21 03 00 00       	push   $0x321
f0100d88:	68 11 79 10 f0       	push   $0xf0107911
f0100d8d:	e8 ae f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d92:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d97:	75 19                	jne    f0100db2 <check_page_free_list+0x1ee>
f0100d99:	68 a7 79 10 f0       	push   $0xf01079a7
f0100d9e:	68 54 79 10 f0       	push   $0xf0107954
f0100da3:	68 22 03 00 00       	push   $0x322
f0100da8:	68 11 79 10 f0       	push   $0xf0107911
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
f0100dc8:	68 44 6a 10 f0       	push   $0xf0106a44
f0100dcd:	6a 58                	push   $0x58
f0100dcf:	68 3a 79 10 f0       	push   $0xf010793a
f0100dd4:	e8 67 f2 ff ff       	call   f0100040 <_panic>
f0100dd9:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100ddf:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100de2:	0f 86 b6 00 00 00    	jbe    f0100e9e <check_page_free_list+0x2da>
f0100de8:	68 44 70 10 f0       	push   $0xf0107044
f0100ded:	68 54 79 10 f0       	push   $0xf0107954
f0100df2:	68 23 03 00 00       	push   $0x323
f0100df7:	68 11 79 10 f0       	push   $0xf0107911
f0100dfc:	e8 3f f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e01:	68 c1 79 10 f0       	push   $0xf01079c1
f0100e06:	68 54 79 10 f0       	push   $0xf0107954
f0100e0b:	68 25 03 00 00       	push   $0x325
f0100e10:	68 11 79 10 f0       	push   $0xf0107911
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
f0100e30:	68 de 79 10 f0       	push   $0xf01079de
f0100e35:	68 54 79 10 f0       	push   $0xf0107954
f0100e3a:	68 2d 03 00 00       	push   $0x32d
f0100e3f:	68 11 79 10 f0       	push   $0xf0107911
f0100e44:	e8 f7 f1 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e49:	85 db                	test   %ebx,%ebx
f0100e4b:	7f 19                	jg     f0100e66 <check_page_free_list+0x2a2>
f0100e4d:	68 f0 79 10 f0       	push   $0xf01079f0
f0100e52:	68 54 79 10 f0       	push   $0xf0107954
f0100e57:	68 2e 03 00 00       	push   $0x32e
f0100e5c:	68 11 79 10 f0       	push   $0xf0107911
f0100e61:	e8 da f1 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100e66:	83 ec 0c             	sub    $0xc,%esp
f0100e69:	68 8c 70 10 f0       	push   $0xf010708c
f0100e6e:	e8 f5 2d 00 00       	call   f0103c68 <cprintf>
}
f0100e73:	eb 49                	jmp    f0100ebe <check_page_free_list+0x2fa>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e75:	a1 40 82 21 f0       	mov    0xf0218240,%eax
f0100e7a:	85 c0                	test   %eax,%eax
f0100e7c:	0f 85 6f fd ff ff    	jne    f0100bf1 <check_page_free_list+0x2d>
f0100e82:	e9 53 fd ff ff       	jmp    f0100bda <check_page_free_list+0x16>
f0100e87:	83 3d 40 82 21 f0 00 	cmpl   $0x0,0xf0218240
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
f0100ec6:	a1 90 8e 21 f0       	mov    0xf0218e90,%eax
f0100ecb:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0100ed0:	8b 15 40 82 21 f0    	mov    0xf0218240,%edx
f0100ed6:	b8 08 00 00 00       	mov    $0x8,%eax
        // 2) All base pages except 0 are free
        size_t i;
        size_t mpentry_page = MPENTRY_PADDR / PGSIZE; 

        for (i = 1; i < mpentry_page; i++) {
                pages[i].pp_link = page_free_list;
f0100edb:	8b 0d 90 8e 21 f0    	mov    0xf0218e90,%ecx
f0100ee1:	89 14 01             	mov    %edx,(%ecx,%eax,1)
                page_free_list = &pages[i];
f0100ee4:	8b 0d 90 8e 21 f0    	mov    0xf0218e90,%ecx
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
f0100efa:	89 15 40 82 21 f0    	mov    %edx,0xf0218240
        for (i = 1; i < mpentry_page; i++) {
                pages[i].pp_link = page_free_list;
                page_free_list = &pages[i];
        }

        pages[mpentry_page].pp_ref++;
f0100f00:	66 83 41 3c 01       	addw   $0x1,0x3c(%ecx)

        for (i = mpentry_page + 1; i < npages_basemem; i++) {
f0100f05:	8b 1d 44 82 21 f0    	mov    0xf0218244,%ebx
f0100f0b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100f10:	b8 08 00 00 00       	mov    $0x8,%eax
f0100f15:	eb 20                	jmp    f0100f37 <page_init+0x71>
f0100f17:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
                pages[i].pp_link = page_free_list;
f0100f1e:	8b 35 90 8e 21 f0    	mov    0xf0218e90,%esi
f0100f24:	89 14 c6             	mov    %edx,(%esi,%eax,8)
                page_free_list = &pages[i];
        }

        pages[mpentry_page].pp_ref++;

        for (i = mpentry_page + 1; i < npages_basemem; i++) {
f0100f27:	83 c0 01             	add    $0x1,%eax
                pages[i].pp_link = page_free_list;
                page_free_list = &pages[i];
f0100f2a:	89 ca                	mov    %ecx,%edx
f0100f2c:	03 15 90 8e 21 f0    	add    0xf0218e90,%edx
f0100f32:	b9 01 00 00 00       	mov    $0x1,%ecx
                page_free_list = &pages[i];
        }

        pages[mpentry_page].pp_ref++;

        for (i = mpentry_page + 1; i < npages_basemem; i++) {
f0100f37:	39 d8                	cmp    %ebx,%eax
f0100f39:	72 dc                	jb     f0100f17 <page_init+0x51>
f0100f3b:	84 c9                	test   %cl,%cl
f0100f3d:	74 06                	je     f0100f45 <page_init+0x7f>
f0100f3f:	89 15 40 82 21 f0    	mov    %edx,0xf0218240
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
f0100f57:	68 68 6a 10 f0       	push   $0xf0106a68
f0100f5c:	68 60 01 00 00       	push   $0x160
f0100f61:	68 11 79 10 f0       	push   $0xf0107911
f0100f66:	e8 d5 f0 ff ff       	call   f0100040 <_panic>
f0100f6b:	05 00 00 00 10       	add    $0x10000000,%eax
f0100f70:	c1 e8 0c             	shr    $0xc,%eax
f0100f73:	8b 0d 40 82 21 f0    	mov    0xf0218240,%ecx
f0100f79:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100f80:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100f85:	eb 1c                	jmp    f0100fa3 <page_init+0xdd>
                pages[i].pp_link = page_free_list;
f0100f87:	8b 35 90 8e 21 f0    	mov    0xf0218e90,%esi
f0100f8d:	89 0c 16             	mov    %ecx,(%esi,%edx,1)
                page_free_list = &pages[i];
f0100f90:	89 d1                	mov    %edx,%ecx
f0100f92:	03 0d 90 8e 21 f0    	add    0xf0218e90,%ecx
                page_free_list = &pages[i];
        }

        // 4) We find the next free memory (boot_alloc() outputs a rounded-up virtual address),
        // convert it to a physical address and get the index of free pages by dividing by PGSIZE  
        for (i = PADDR(boot_alloc(0)) / PGSIZE; i < npages; i++) {
f0100f98:	83 c0 01             	add    $0x1,%eax
f0100f9b:	83 c2 08             	add    $0x8,%edx
f0100f9e:	bb 01 00 00 00       	mov    $0x1,%ebx
f0100fa3:	3b 05 88 8e 21 f0    	cmp    0xf0218e88,%eax
f0100fa9:	72 dc                	jb     f0100f87 <page_init+0xc1>
f0100fab:	84 db                	test   %bl,%bl
f0100fad:	74 06                	je     f0100fb5 <page_init+0xef>
f0100faf:	89 0d 40 82 21 f0    	mov    %ecx,0xf0218240
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
f0100fc3:	8b 1d 40 82 21 f0    	mov    0xf0218240,%ebx
f0100fc9:	85 db                	test   %ebx,%ebx
f0100fcb:	74 58                	je     f0101025 <page_alloc+0x69>
                return NULL;

        struct PageInfo *page = page_free_list;
        page_free_list = page->pp_link;
f0100fcd:	8b 03                	mov    (%ebx),%eax
f0100fcf:	a3 40 82 21 f0       	mov    %eax,0xf0218240

	if (alloc_flags & ALLOC_ZERO) {
f0100fd4:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100fd8:	74 45                	je     f010101f <page_alloc+0x63>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100fda:	89 d8                	mov    %ebx,%eax
f0100fdc:	2b 05 90 8e 21 f0    	sub    0xf0218e90,%eax
f0100fe2:	c1 f8 03             	sar    $0x3,%eax
f0100fe5:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fe8:	89 c2                	mov    %eax,%edx
f0100fea:	c1 ea 0c             	shr    $0xc,%edx
f0100fed:	3b 15 88 8e 21 f0    	cmp    0xf0218e88,%edx
f0100ff3:	72 12                	jb     f0101007 <page_alloc+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ff5:	50                   	push   %eax
f0100ff6:	68 44 6a 10 f0       	push   $0xf0106a44
f0100ffb:	6a 58                	push   $0x58
f0100ffd:	68 3a 79 10 f0       	push   $0xf010793a
f0101002:	e8 39 f0 ff ff       	call   f0100040 <_panic>
                char *p = page2kva(page);
                memset(p, 0, PGSIZE);
f0101007:	83 ec 04             	sub    $0x4,%esp
f010100a:	68 00 10 00 00       	push   $0x1000
f010100f:	6a 00                	push   $0x0
f0101011:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101016:	50                   	push   %eax
f0101017:	e8 4e 4d 00 00       	call   f0105d6a <memset>
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
f0101039:	68 3b 7b 10 f0       	push   $0xf0107b3b
f010103e:	68 54 79 10 f0       	push   $0xf0107954
f0101043:	68 8b 01 00 00       	push   $0x18b
f0101048:	68 11 79 10 f0       	push   $0xf0107911
f010104d:	e8 ee ef ff ff       	call   f0100040 <_panic>

        // Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
        if (pp->pp_ref != 0) 
f0101052:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101057:	74 17                	je     f0101070 <page_free+0x44>
                panic("pp->pp_ref is nonzero\n");
f0101059:	83 ec 04             	sub    $0x4,%esp
f010105c:	68 01 7a 10 f0       	push   $0xf0107a01
f0101061:	68 91 01 00 00       	push   $0x191
f0101066:	68 11 79 10 f0       	push   $0xf0107911
f010106b:	e8 d0 ef ff ff       	call   f0100040 <_panic>

        if (pp->pp_link != NULL)
f0101070:	83 38 00             	cmpl   $0x0,(%eax)
f0101073:	74 17                	je     f010108c <page_free+0x60>
                panic("pp->pp_link is not NULL\n");
f0101075:	83 ec 04             	sub    $0x4,%esp
f0101078:	68 18 7a 10 f0       	push   $0xf0107a18
f010107d:	68 94 01 00 00       	push   $0x194
f0101082:	68 11 79 10 f0       	push   $0xf0107911
f0101087:	e8 b4 ef ff ff       	call   f0100040 <_panic>

        pp->pp_link = page_free_list;
f010108c:	8b 15 40 82 21 f0    	mov    0xf0218240,%edx
f0101092:	89 10                	mov    %edx,(%eax)
        page_free_list = pp;
f0101094:	a3 40 82 21 f0       	mov    %eax,0xf0218240
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
f01010d1:	68 31 7a 10 f0       	push   $0xf0107a31
f01010d6:	68 54 79 10 f0       	push   $0xf0107954
f01010db:	68 be 01 00 00       	push   $0x1be
f01010e0:	68 11 79 10 f0       	push   $0xf0107911
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
f0101104:	39 05 88 8e 21 f0    	cmp    %eax,0xf0218e88
f010110a:	77 15                	ja     f0101121 <pgdir_walk+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010110c:	52                   	push   %edx
f010110d:	68 44 6a 10 f0       	push   $0xf0106a44
f0101112:	68 c5 01 00 00       	push   $0x1c5
f0101117:	68 11 79 10 f0       	push   $0xf0107911
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
f0101142:	2b 15 90 8e 21 f0    	sub    0xf0218e90,%edx
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
f0101158:	2b 05 90 8e 21 f0    	sub    0xf0218e90,%eax
f010115e:	c1 f8 03             	sar    $0x3,%eax
f0101161:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101164:	89 c2                	mov    %eax,%edx
f0101166:	c1 ea 0c             	shr    $0xc,%edx
f0101169:	3b 15 88 8e 21 f0    	cmp    0xf0218e88,%edx
f010116f:	72 12                	jb     f0101183 <pgdir_walk+0xc1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101171:	50                   	push   %eax
f0101172:	68 44 6a 10 f0       	push   $0xf0106a44
f0101177:	6a 58                	push   $0x58
f0101179:	68 3a 79 10 f0       	push   $0xf010793a
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
f01011d9:	68 31 7a 10 f0       	push   $0xf0107a31
f01011de:	68 54 79 10 f0       	push   $0xf0107954
f01011e3:	68 e5 01 00 00       	push   $0x1e5
f01011e8:	68 11 79 10 f0       	push   $0xf0107911
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
f010120a:	68 37 7a 10 f0       	push   $0xf0107a37
f010120f:	68 54 79 10 f0       	push   $0xf0107954
f0101214:	68 ed 01 00 00       	push   $0x1ed
f0101219:	68 11 79 10 f0       	push   $0xf0107911
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
f0101251:	68 31 7a 10 f0       	push   $0xf0107a31
f0101256:	68 54 79 10 f0       	push   $0xf0107954
f010125b:	68 3a 02 00 00       	push   $0x23a
f0101260:	68 11 79 10 f0       	push   $0xf0107911
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
f010128f:	3b 05 88 8e 21 f0    	cmp    0xf0218e88,%eax
f0101295:	72 14                	jb     f01012ab <page_lookup+0x6b>
		panic("pa2page called with invalid pa");
f0101297:	83 ec 04             	sub    $0x4,%esp
f010129a:	68 b0 70 10 f0       	push   $0xf01070b0
f010129f:	6a 51                	push   $0x51
f01012a1:	68 3a 79 10 f0       	push   $0xf010793a
f01012a6:	e8 95 ed ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01012ab:	8b 15 90 8e 21 f0    	mov    0xf0218e90,%edx
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
f01012cd:	e8 b8 50 00 00       	call   f010638a <cpunum>
f01012d2:	6b c0 74             	imul   $0x74,%eax,%eax
f01012d5:	83 b8 28 90 21 f0 00 	cmpl   $0x0,-0xfde6fd8(%eax)
f01012dc:	74 19                	je     f01012f7 <tlb_invalidate+0x30>
f01012de:	e8 a7 50 00 00       	call   f010638a <cpunum>
f01012e3:	6b c0 74             	imul   $0x74,%eax,%eax
f01012e6:	8b 80 28 90 21 f0    	mov    -0xfde6fd8(%eax),%eax
f01012ec:	8b 55 08             	mov    0x8(%ebp),%edx
f01012ef:	39 90 94 00 00 00    	cmp    %edx,0x94(%eax)
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
f0101311:	68 31 7a 10 f0       	push   $0xf0107a31
f0101316:	68 54 79 10 f0       	push   $0xf0107954
f010131b:	68 59 02 00 00       	push   $0x259
f0101320:	68 11 79 10 f0       	push   $0xf0107911
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
f0101380:	68 31 7a 10 f0       	push   $0xf0107a31
f0101385:	68 54 79 10 f0       	push   $0xf0107954
f010138a:	68 12 02 00 00       	push   $0x212
f010138f:	68 11 79 10 f0       	push   $0xf0107911
f0101394:	e8 a7 ec ff ff       	call   f0100040 <_panic>
        assert(pp);
f0101399:	85 db                	test   %ebx,%ebx
f010139b:	75 19                	jne    f01013b6 <page_insert+0x49>
f010139d:	68 3b 7b 10 f0       	push   $0xf0107b3b
f01013a2:	68 54 79 10 f0       	push   $0xf0107954
f01013a7:	68 13 02 00 00       	push   $0x213
f01013ac:	68 11 79 10 f0       	push   $0xf0107911
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
f01013da:	2b 15 90 8e 21 f0    	sub    0xf0218e90,%edx
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
f010140a:	2b 1d 90 8e 21 f0    	sub    0xf0218e90,%ebx
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
f010145b:	68 d0 70 10 f0       	push   $0xf01070d0
f0101460:	68 99 02 00 00       	push   $0x299
f0101465:	68 11 79 10 f0       	push   $0xf0107911
f010146a:	e8 d1 eb ff ff       	call   f0100040 <_panic>

        boot_map_region(kern_pgdir, base, sz, pa, PTE_W | PTE_PCD | PTE_PWT);      
f010146f:	83 ec 08             	sub    $0x8,%esp
f0101472:	6a 1a                	push   $0x1a
f0101474:	ff 75 08             	pushl  0x8(%ebp)
f0101477:	89 d9                	mov    %ebx,%ecx
f0101479:	89 f2                	mov    %esi,%edx
f010147b:	a1 8c 8e 21 f0       	mov    0xf0218e8c,%eax
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
f01014dd:	89 15 88 8e 21 f0    	mov    %edx,0xf0218e88
	npages_basemem = basemem / (PGSIZE / 1024);
f01014e3:	89 da                	mov    %ebx,%edx
f01014e5:	c1 ea 02             	shr    $0x2,%edx
f01014e8:	89 15 44 82 21 f0    	mov    %edx,0xf0218244

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01014ee:	89 c2                	mov    %eax,%edx
f01014f0:	29 da                	sub    %ebx,%edx
f01014f2:	52                   	push   %edx
f01014f3:	53                   	push   %ebx
f01014f4:	50                   	push   %eax
f01014f5:	68 f8 70 10 f0       	push   $0xf01070f8
f01014fa:	e8 69 27 00 00       	call   f0103c68 <cprintf>
	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01014ff:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101504:	e8 21 f6 ff ff       	call   f0100b2a <boot_alloc>
f0101509:	a3 8c 8e 21 f0       	mov    %eax,0xf0218e8c
	memset(kern_pgdir, 0, PGSIZE);
f010150e:	83 c4 0c             	add    $0xc,%esp
f0101511:	68 00 10 00 00       	push   $0x1000
f0101516:	6a 00                	push   $0x0
f0101518:	50                   	push   %eax
f0101519:	e8 4c 48 00 00       	call   f0105d6a <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010151e:	a1 8c 8e 21 f0       	mov    0xf0218e8c,%eax
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
f010152e:	68 68 6a 10 f0       	push   $0xf0106a68
f0101533:	68 98 00 00 00       	push   $0x98
f0101538:	68 11 79 10 f0       	push   $0xf0107911
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
f0101551:	a1 88 8e 21 f0       	mov    0xf0218e88,%eax
f0101556:	c1 e0 03             	shl    $0x3,%eax
f0101559:	89 c7                	mov    %eax,%edi
f010155b:	89 45 cc             	mov    %eax,-0x34(%ebp)
        pages = (struct PageInfo *) boot_alloc(pages_size);
f010155e:	e8 c7 f5 ff ff       	call   f0100b2a <boot_alloc>
f0101563:	a3 90 8e 21 f0       	mov    %eax,0xf0218e90
        memset(pages, 0, pages_size);
f0101568:	83 ec 04             	sub    $0x4,%esp
f010156b:	57                   	push   %edi
f010156c:	6a 00                	push   $0x0
f010156e:	50                   	push   %eax
f010156f:	e8 f6 47 00 00       	call   f0105d6a <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
        const size_t envs_size = sizeof(struct Env) * NENV;
        envs = (struct Env *) boot_alloc(envs_size);
f0101574:	b8 00 c0 02 00       	mov    $0x2c000,%eax
f0101579:	e8 ac f5 ff ff       	call   f0100b2a <boot_alloc>
f010157e:	a3 4c 82 21 f0       	mov    %eax,0xf021824c
        memset(envs, 0, envs_size);
f0101583:	83 c4 0c             	add    $0xc,%esp
f0101586:	68 00 c0 02 00       	push   $0x2c000
f010158b:	6a 00                	push   $0x0
f010158d:	50                   	push   %eax
f010158e:	e8 d7 47 00 00       	call   f0105d6a <memset>
	
	//Lab 7: Multithreading
	/*Alloc place for the free stack stacks stacking*/

	const size_t stack_size = sizeof(struct FreeStacks) * MAX_THREADS;
	thread_free_stacks = (struct FreeStacks*) boot_alloc(stack_size);
f0101593:	b8 f4 2f 00 00       	mov    $0x2ff4,%eax
f0101598:	e8 8d f5 ff ff       	call   f0100b2a <boot_alloc>
f010159d:	a3 48 82 21 f0       	mov    %eax,0xf0218248
	memset(thread_free_stacks, 0, stack_size);
f01015a2:	83 c4 0c             	add    $0xc,%esp
f01015a5:	68 f4 2f 00 00       	push   $0x2ff4
f01015aa:	6a 00                	push   $0x0
f01015ac:	50                   	push   %eax
f01015ad:	e8 b8 47 00 00       	call   f0105d6a <memset>
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
f01015c4:	83 3d 90 8e 21 f0 00 	cmpl   $0x0,0xf0218e90
f01015cb:	75 17                	jne    f01015e4 <mem_init+0x150>
		panic("'pages' is a null pointer!");
f01015cd:	83 ec 04             	sub    $0x4,%esp
f01015d0:	68 3b 7a 10 f0       	push   $0xf0107a3b
f01015d5:	68 41 03 00 00       	push   $0x341
f01015da:	68 11 79 10 f0       	push   $0xf0107911
f01015df:	e8 5c ea ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01015e4:	a1 40 82 21 f0       	mov    0xf0218240,%eax
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
f010160c:	68 56 7a 10 f0       	push   $0xf0107a56
f0101611:	68 54 79 10 f0       	push   $0xf0107954
f0101616:	68 49 03 00 00       	push   $0x349
f010161b:	68 11 79 10 f0       	push   $0xf0107911
f0101620:	e8 1b ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101625:	83 ec 0c             	sub    $0xc,%esp
f0101628:	6a 00                	push   $0x0
f010162a:	e8 8d f9 ff ff       	call   f0100fbc <page_alloc>
f010162f:	89 c6                	mov    %eax,%esi
f0101631:	83 c4 10             	add    $0x10,%esp
f0101634:	85 c0                	test   %eax,%eax
f0101636:	75 19                	jne    f0101651 <mem_init+0x1bd>
f0101638:	68 6c 7a 10 f0       	push   $0xf0107a6c
f010163d:	68 54 79 10 f0       	push   $0xf0107954
f0101642:	68 4a 03 00 00       	push   $0x34a
f0101647:	68 11 79 10 f0       	push   $0xf0107911
f010164c:	e8 ef e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101651:	83 ec 0c             	sub    $0xc,%esp
f0101654:	6a 00                	push   $0x0
f0101656:	e8 61 f9 ff ff       	call   f0100fbc <page_alloc>
f010165b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010165e:	83 c4 10             	add    $0x10,%esp
f0101661:	85 c0                	test   %eax,%eax
f0101663:	75 19                	jne    f010167e <mem_init+0x1ea>
f0101665:	68 82 7a 10 f0       	push   $0xf0107a82
f010166a:	68 54 79 10 f0       	push   $0xf0107954
f010166f:	68 4b 03 00 00       	push   $0x34b
f0101674:	68 11 79 10 f0       	push   $0xf0107911
f0101679:	e8 c2 e9 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010167e:	39 f7                	cmp    %esi,%edi
f0101680:	75 19                	jne    f010169b <mem_init+0x207>
f0101682:	68 98 7a 10 f0       	push   $0xf0107a98
f0101687:	68 54 79 10 f0       	push   $0xf0107954
f010168c:	68 4e 03 00 00       	push   $0x34e
f0101691:	68 11 79 10 f0       	push   $0xf0107911
f0101696:	e8 a5 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010169b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010169e:	39 c6                	cmp    %eax,%esi
f01016a0:	74 04                	je     f01016a6 <mem_init+0x212>
f01016a2:	39 c7                	cmp    %eax,%edi
f01016a4:	75 19                	jne    f01016bf <mem_init+0x22b>
f01016a6:	68 34 71 10 f0       	push   $0xf0107134
f01016ab:	68 54 79 10 f0       	push   $0xf0107954
f01016b0:	68 4f 03 00 00       	push   $0x34f
f01016b5:	68 11 79 10 f0       	push   $0xf0107911
f01016ba:	e8 81 e9 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01016bf:	8b 0d 90 8e 21 f0    	mov    0xf0218e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01016c5:	8b 15 88 8e 21 f0    	mov    0xf0218e88,%edx
f01016cb:	c1 e2 0c             	shl    $0xc,%edx
f01016ce:	89 f8                	mov    %edi,%eax
f01016d0:	29 c8                	sub    %ecx,%eax
f01016d2:	c1 f8 03             	sar    $0x3,%eax
f01016d5:	c1 e0 0c             	shl    $0xc,%eax
f01016d8:	39 d0                	cmp    %edx,%eax
f01016da:	72 19                	jb     f01016f5 <mem_init+0x261>
f01016dc:	68 aa 7a 10 f0       	push   $0xf0107aaa
f01016e1:	68 54 79 10 f0       	push   $0xf0107954
f01016e6:	68 50 03 00 00       	push   $0x350
f01016eb:	68 11 79 10 f0       	push   $0xf0107911
f01016f0:	e8 4b e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01016f5:	89 f0                	mov    %esi,%eax
f01016f7:	29 c8                	sub    %ecx,%eax
f01016f9:	c1 f8 03             	sar    $0x3,%eax
f01016fc:	c1 e0 0c             	shl    $0xc,%eax
f01016ff:	39 c2                	cmp    %eax,%edx
f0101701:	77 19                	ja     f010171c <mem_init+0x288>
f0101703:	68 c7 7a 10 f0       	push   $0xf0107ac7
f0101708:	68 54 79 10 f0       	push   $0xf0107954
f010170d:	68 51 03 00 00       	push   $0x351
f0101712:	68 11 79 10 f0       	push   $0xf0107911
f0101717:	e8 24 e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010171c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010171f:	29 c8                	sub    %ecx,%eax
f0101721:	c1 f8 03             	sar    $0x3,%eax
f0101724:	c1 e0 0c             	shl    $0xc,%eax
f0101727:	39 c2                	cmp    %eax,%edx
f0101729:	77 19                	ja     f0101744 <mem_init+0x2b0>
f010172b:	68 e4 7a 10 f0       	push   $0xf0107ae4
f0101730:	68 54 79 10 f0       	push   $0xf0107954
f0101735:	68 52 03 00 00       	push   $0x352
f010173a:	68 11 79 10 f0       	push   $0xf0107911
f010173f:	e8 fc e8 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101744:	a1 40 82 21 f0       	mov    0xf0218240,%eax
f0101749:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010174c:	c7 05 40 82 21 f0 00 	movl   $0x0,0xf0218240
f0101753:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101756:	83 ec 0c             	sub    $0xc,%esp
f0101759:	6a 00                	push   $0x0
f010175b:	e8 5c f8 ff ff       	call   f0100fbc <page_alloc>
f0101760:	83 c4 10             	add    $0x10,%esp
f0101763:	85 c0                	test   %eax,%eax
f0101765:	74 19                	je     f0101780 <mem_init+0x2ec>
f0101767:	68 01 7b 10 f0       	push   $0xf0107b01
f010176c:	68 54 79 10 f0       	push   $0xf0107954
f0101771:	68 59 03 00 00       	push   $0x359
f0101776:	68 11 79 10 f0       	push   $0xf0107911
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
f01017b1:	68 56 7a 10 f0       	push   $0xf0107a56
f01017b6:	68 54 79 10 f0       	push   $0xf0107954
f01017bb:	68 60 03 00 00       	push   $0x360
f01017c0:	68 11 79 10 f0       	push   $0xf0107911
f01017c5:	e8 76 e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01017ca:	83 ec 0c             	sub    $0xc,%esp
f01017cd:	6a 00                	push   $0x0
f01017cf:	e8 e8 f7 ff ff       	call   f0100fbc <page_alloc>
f01017d4:	89 c7                	mov    %eax,%edi
f01017d6:	83 c4 10             	add    $0x10,%esp
f01017d9:	85 c0                	test   %eax,%eax
f01017db:	75 19                	jne    f01017f6 <mem_init+0x362>
f01017dd:	68 6c 7a 10 f0       	push   $0xf0107a6c
f01017e2:	68 54 79 10 f0       	push   $0xf0107954
f01017e7:	68 61 03 00 00       	push   $0x361
f01017ec:	68 11 79 10 f0       	push   $0xf0107911
f01017f1:	e8 4a e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01017f6:	83 ec 0c             	sub    $0xc,%esp
f01017f9:	6a 00                	push   $0x0
f01017fb:	e8 bc f7 ff ff       	call   f0100fbc <page_alloc>
f0101800:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101803:	83 c4 10             	add    $0x10,%esp
f0101806:	85 c0                	test   %eax,%eax
f0101808:	75 19                	jne    f0101823 <mem_init+0x38f>
f010180a:	68 82 7a 10 f0       	push   $0xf0107a82
f010180f:	68 54 79 10 f0       	push   $0xf0107954
f0101814:	68 62 03 00 00       	push   $0x362
f0101819:	68 11 79 10 f0       	push   $0xf0107911
f010181e:	e8 1d e8 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101823:	39 fe                	cmp    %edi,%esi
f0101825:	75 19                	jne    f0101840 <mem_init+0x3ac>
f0101827:	68 98 7a 10 f0       	push   $0xf0107a98
f010182c:	68 54 79 10 f0       	push   $0xf0107954
f0101831:	68 64 03 00 00       	push   $0x364
f0101836:	68 11 79 10 f0       	push   $0xf0107911
f010183b:	e8 00 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101840:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101843:	39 c7                	cmp    %eax,%edi
f0101845:	74 04                	je     f010184b <mem_init+0x3b7>
f0101847:	39 c6                	cmp    %eax,%esi
f0101849:	75 19                	jne    f0101864 <mem_init+0x3d0>
f010184b:	68 34 71 10 f0       	push   $0xf0107134
f0101850:	68 54 79 10 f0       	push   $0xf0107954
f0101855:	68 65 03 00 00       	push   $0x365
f010185a:	68 11 79 10 f0       	push   $0xf0107911
f010185f:	e8 dc e7 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101864:	83 ec 0c             	sub    $0xc,%esp
f0101867:	6a 00                	push   $0x0
f0101869:	e8 4e f7 ff ff       	call   f0100fbc <page_alloc>
f010186e:	83 c4 10             	add    $0x10,%esp
f0101871:	85 c0                	test   %eax,%eax
f0101873:	74 19                	je     f010188e <mem_init+0x3fa>
f0101875:	68 01 7b 10 f0       	push   $0xf0107b01
f010187a:	68 54 79 10 f0       	push   $0xf0107954
f010187f:	68 66 03 00 00       	push   $0x366
f0101884:	68 11 79 10 f0       	push   $0xf0107911
f0101889:	e8 b2 e7 ff ff       	call   f0100040 <_panic>
f010188e:	89 f0                	mov    %esi,%eax
f0101890:	2b 05 90 8e 21 f0    	sub    0xf0218e90,%eax
f0101896:	c1 f8 03             	sar    $0x3,%eax
f0101899:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010189c:	89 c2                	mov    %eax,%edx
f010189e:	c1 ea 0c             	shr    $0xc,%edx
f01018a1:	3b 15 88 8e 21 f0    	cmp    0xf0218e88,%edx
f01018a7:	72 12                	jb     f01018bb <mem_init+0x427>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018a9:	50                   	push   %eax
f01018aa:	68 44 6a 10 f0       	push   $0xf0106a44
f01018af:	6a 58                	push   $0x58
f01018b1:	68 3a 79 10 f0       	push   $0xf010793a
f01018b6:	e8 85 e7 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01018bb:	83 ec 04             	sub    $0x4,%esp
f01018be:	68 00 10 00 00       	push   $0x1000
f01018c3:	6a 01                	push   $0x1
f01018c5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01018ca:	50                   	push   %eax
f01018cb:	e8 9a 44 00 00       	call   f0105d6a <memset>
	page_free(pp0);
f01018d0:	89 34 24             	mov    %esi,(%esp)
f01018d3:	e8 54 f7 ff ff       	call   f010102c <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01018d8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01018df:	e8 d8 f6 ff ff       	call   f0100fbc <page_alloc>
f01018e4:	83 c4 10             	add    $0x10,%esp
f01018e7:	85 c0                	test   %eax,%eax
f01018e9:	75 19                	jne    f0101904 <mem_init+0x470>
f01018eb:	68 10 7b 10 f0       	push   $0xf0107b10
f01018f0:	68 54 79 10 f0       	push   $0xf0107954
f01018f5:	68 6b 03 00 00       	push   $0x36b
f01018fa:	68 11 79 10 f0       	push   $0xf0107911
f01018ff:	e8 3c e7 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101904:	39 c6                	cmp    %eax,%esi
f0101906:	74 19                	je     f0101921 <mem_init+0x48d>
f0101908:	68 2e 7b 10 f0       	push   $0xf0107b2e
f010190d:	68 54 79 10 f0       	push   $0xf0107954
f0101912:	68 6c 03 00 00       	push   $0x36c
f0101917:	68 11 79 10 f0       	push   $0xf0107911
f010191c:	e8 1f e7 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101921:	89 f0                	mov    %esi,%eax
f0101923:	2b 05 90 8e 21 f0    	sub    0xf0218e90,%eax
f0101929:	c1 f8 03             	sar    $0x3,%eax
f010192c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010192f:	89 c2                	mov    %eax,%edx
f0101931:	c1 ea 0c             	shr    $0xc,%edx
f0101934:	3b 15 88 8e 21 f0    	cmp    0xf0218e88,%edx
f010193a:	72 12                	jb     f010194e <mem_init+0x4ba>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010193c:	50                   	push   %eax
f010193d:	68 44 6a 10 f0       	push   $0xf0106a44
f0101942:	6a 58                	push   $0x58
f0101944:	68 3a 79 10 f0       	push   $0xf010793a
f0101949:	e8 f2 e6 ff ff       	call   f0100040 <_panic>
f010194e:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101954:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f010195a:	80 38 00             	cmpb   $0x0,(%eax)
f010195d:	74 19                	je     f0101978 <mem_init+0x4e4>
f010195f:	68 3e 7b 10 f0       	push   $0xf0107b3e
f0101964:	68 54 79 10 f0       	push   $0xf0107954
f0101969:	68 6f 03 00 00       	push   $0x36f
f010196e:	68 11 79 10 f0       	push   $0xf0107911
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
f0101982:	a3 40 82 21 f0       	mov    %eax,0xf0218240

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
f01019a3:	a1 40 82 21 f0       	mov    0xf0218240,%eax
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
f01019ba:	68 48 7b 10 f0       	push   $0xf0107b48
f01019bf:	68 54 79 10 f0       	push   $0xf0107954
f01019c4:	68 7c 03 00 00       	push   $0x37c
f01019c9:	68 11 79 10 f0       	push   $0xf0107911
f01019ce:	e8 6d e6 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01019d3:	83 ec 0c             	sub    $0xc,%esp
f01019d6:	68 54 71 10 f0       	push   $0xf0107154
f01019db:	e8 88 22 00 00       	call   f0103c68 <cprintf>
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
f01019f6:	68 56 7a 10 f0       	push   $0xf0107a56
f01019fb:	68 54 79 10 f0       	push   $0xf0107954
f0101a00:	68 e2 03 00 00       	push   $0x3e2
f0101a05:	68 11 79 10 f0       	push   $0xf0107911
f0101a0a:	e8 31 e6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101a0f:	83 ec 0c             	sub    $0xc,%esp
f0101a12:	6a 00                	push   $0x0
f0101a14:	e8 a3 f5 ff ff       	call   f0100fbc <page_alloc>
f0101a19:	89 c3                	mov    %eax,%ebx
f0101a1b:	83 c4 10             	add    $0x10,%esp
f0101a1e:	85 c0                	test   %eax,%eax
f0101a20:	75 19                	jne    f0101a3b <mem_init+0x5a7>
f0101a22:	68 6c 7a 10 f0       	push   $0xf0107a6c
f0101a27:	68 54 79 10 f0       	push   $0xf0107954
f0101a2c:	68 e3 03 00 00       	push   $0x3e3
f0101a31:	68 11 79 10 f0       	push   $0xf0107911
f0101a36:	e8 05 e6 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a3b:	83 ec 0c             	sub    $0xc,%esp
f0101a3e:	6a 00                	push   $0x0
f0101a40:	e8 77 f5 ff ff       	call   f0100fbc <page_alloc>
f0101a45:	89 c6                	mov    %eax,%esi
f0101a47:	83 c4 10             	add    $0x10,%esp
f0101a4a:	85 c0                	test   %eax,%eax
f0101a4c:	75 19                	jne    f0101a67 <mem_init+0x5d3>
f0101a4e:	68 82 7a 10 f0       	push   $0xf0107a82
f0101a53:	68 54 79 10 f0       	push   $0xf0107954
f0101a58:	68 e4 03 00 00       	push   $0x3e4
f0101a5d:	68 11 79 10 f0       	push   $0xf0107911
f0101a62:	e8 d9 e5 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a67:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101a6a:	75 19                	jne    f0101a85 <mem_init+0x5f1>
f0101a6c:	68 98 7a 10 f0       	push   $0xf0107a98
f0101a71:	68 54 79 10 f0       	push   $0xf0107954
f0101a76:	68 e7 03 00 00       	push   $0x3e7
f0101a7b:	68 11 79 10 f0       	push   $0xf0107911
f0101a80:	e8 bb e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a85:	39 c3                	cmp    %eax,%ebx
f0101a87:	74 05                	je     f0101a8e <mem_init+0x5fa>
f0101a89:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101a8c:	75 19                	jne    f0101aa7 <mem_init+0x613>
f0101a8e:	68 34 71 10 f0       	push   $0xf0107134
f0101a93:	68 54 79 10 f0       	push   $0xf0107954
f0101a98:	68 e8 03 00 00       	push   $0x3e8
f0101a9d:	68 11 79 10 f0       	push   $0xf0107911
f0101aa2:	e8 99 e5 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101aa7:	a1 40 82 21 f0       	mov    0xf0218240,%eax
f0101aac:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101aaf:	c7 05 40 82 21 f0 00 	movl   $0x0,0xf0218240
f0101ab6:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101ab9:	83 ec 0c             	sub    $0xc,%esp
f0101abc:	6a 00                	push   $0x0
f0101abe:	e8 f9 f4 ff ff       	call   f0100fbc <page_alloc>
f0101ac3:	83 c4 10             	add    $0x10,%esp
f0101ac6:	85 c0                	test   %eax,%eax
f0101ac8:	74 19                	je     f0101ae3 <mem_init+0x64f>
f0101aca:	68 01 7b 10 f0       	push   $0xf0107b01
f0101acf:	68 54 79 10 f0       	push   $0xf0107954
f0101ad4:	68 ef 03 00 00       	push   $0x3ef
f0101ad9:	68 11 79 10 f0       	push   $0xf0107911
f0101ade:	e8 5d e5 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101ae3:	83 ec 04             	sub    $0x4,%esp
f0101ae6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101ae9:	50                   	push   %eax
f0101aea:	6a 00                	push   $0x0
f0101aec:	ff 35 8c 8e 21 f0    	pushl  0xf0218e8c
f0101af2:	e8 49 f7 ff ff       	call   f0101240 <page_lookup>
f0101af7:	83 c4 10             	add    $0x10,%esp
f0101afa:	85 c0                	test   %eax,%eax
f0101afc:	74 19                	je     f0101b17 <mem_init+0x683>
f0101afe:	68 74 71 10 f0       	push   $0xf0107174
f0101b03:	68 54 79 10 f0       	push   $0xf0107954
f0101b08:	68 f2 03 00 00       	push   $0x3f2
f0101b0d:	68 11 79 10 f0       	push   $0xf0107911
f0101b12:	e8 29 e5 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101b17:	6a 02                	push   $0x2
f0101b19:	6a 00                	push   $0x0
f0101b1b:	53                   	push   %ebx
f0101b1c:	ff 35 8c 8e 21 f0    	pushl  0xf0218e8c
f0101b22:	e8 46 f8 ff ff       	call   f010136d <page_insert>
f0101b27:	83 c4 10             	add    $0x10,%esp
f0101b2a:	85 c0                	test   %eax,%eax
f0101b2c:	78 19                	js     f0101b47 <mem_init+0x6b3>
f0101b2e:	68 ac 71 10 f0       	push   $0xf01071ac
f0101b33:	68 54 79 10 f0       	push   $0xf0107954
f0101b38:	68 f5 03 00 00       	push   $0x3f5
f0101b3d:	68 11 79 10 f0       	push   $0xf0107911
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
f0101b57:	ff 35 8c 8e 21 f0    	pushl  0xf0218e8c
f0101b5d:	e8 0b f8 ff ff       	call   f010136d <page_insert>
f0101b62:	83 c4 20             	add    $0x20,%esp
f0101b65:	85 c0                	test   %eax,%eax
f0101b67:	74 19                	je     f0101b82 <mem_init+0x6ee>
f0101b69:	68 dc 71 10 f0       	push   $0xf01071dc
f0101b6e:	68 54 79 10 f0       	push   $0xf0107954
f0101b73:	68 fa 03 00 00       	push   $0x3fa
f0101b78:	68 11 79 10 f0       	push   $0xf0107911
f0101b7d:	e8 be e4 ff ff       	call   f0100040 <_panic>
        assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b82:	8b 3d 8c 8e 21 f0    	mov    0xf0218e8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b88:	a1 90 8e 21 f0       	mov    0xf0218e90,%eax
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
f0101ba9:	68 0c 72 10 f0       	push   $0xf010720c
f0101bae:	68 54 79 10 f0       	push   $0xf0107954
f0101bb3:	68 fb 03 00 00       	push   $0x3fb
f0101bb8:	68 11 79 10 f0       	push   $0xf0107911
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
f0101bdd:	68 34 72 10 f0       	push   $0xf0107234
f0101be2:	68 54 79 10 f0       	push   $0xf0107954
f0101be7:	68 fc 03 00 00       	push   $0x3fc
f0101bec:	68 11 79 10 f0       	push   $0xf0107911
f0101bf1:	e8 4a e4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101bf6:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101bfb:	74 19                	je     f0101c16 <mem_init+0x782>
f0101bfd:	68 53 7b 10 f0       	push   $0xf0107b53
f0101c02:	68 54 79 10 f0       	push   $0xf0107954
f0101c07:	68 fd 03 00 00       	push   $0x3fd
f0101c0c:	68 11 79 10 f0       	push   $0xf0107911
f0101c11:	e8 2a e4 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101c16:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c19:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101c1e:	74 19                	je     f0101c39 <mem_init+0x7a5>
f0101c20:	68 64 7b 10 f0       	push   $0xf0107b64
f0101c25:	68 54 79 10 f0       	push   $0xf0107954
f0101c2a:	68 fe 03 00 00       	push   $0x3fe
f0101c2f:	68 11 79 10 f0       	push   $0xf0107911
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
f0101c4e:	68 64 72 10 f0       	push   $0xf0107264
f0101c53:	68 54 79 10 f0       	push   $0xf0107954
f0101c58:	68 01 04 00 00       	push   $0x401
f0101c5d:	68 11 79 10 f0       	push   $0xf0107911
f0101c62:	e8 d9 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c67:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c6c:	a1 8c 8e 21 f0       	mov    0xf0218e8c,%eax
f0101c71:	e8 50 ee ff ff       	call   f0100ac6 <check_va2pa>
f0101c76:	89 f2                	mov    %esi,%edx
f0101c78:	2b 15 90 8e 21 f0    	sub    0xf0218e90,%edx
f0101c7e:	c1 fa 03             	sar    $0x3,%edx
f0101c81:	c1 e2 0c             	shl    $0xc,%edx
f0101c84:	39 d0                	cmp    %edx,%eax
f0101c86:	74 19                	je     f0101ca1 <mem_init+0x80d>
f0101c88:	68 a0 72 10 f0       	push   $0xf01072a0
f0101c8d:	68 54 79 10 f0       	push   $0xf0107954
f0101c92:	68 02 04 00 00       	push   $0x402
f0101c97:	68 11 79 10 f0       	push   $0xf0107911
f0101c9c:	e8 9f e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101ca1:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ca6:	74 19                	je     f0101cc1 <mem_init+0x82d>
f0101ca8:	68 75 7b 10 f0       	push   $0xf0107b75
f0101cad:	68 54 79 10 f0       	push   $0xf0107954
f0101cb2:	68 03 04 00 00       	push   $0x403
f0101cb7:	68 11 79 10 f0       	push   $0xf0107911
f0101cbc:	e8 7f e3 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101cc1:	83 ec 0c             	sub    $0xc,%esp
f0101cc4:	6a 00                	push   $0x0
f0101cc6:	e8 f1 f2 ff ff       	call   f0100fbc <page_alloc>
f0101ccb:	83 c4 10             	add    $0x10,%esp
f0101cce:	85 c0                	test   %eax,%eax
f0101cd0:	74 19                	je     f0101ceb <mem_init+0x857>
f0101cd2:	68 01 7b 10 f0       	push   $0xf0107b01
f0101cd7:	68 54 79 10 f0       	push   $0xf0107954
f0101cdc:	68 06 04 00 00       	push   $0x406
f0101ce1:	68 11 79 10 f0       	push   $0xf0107911
f0101ce6:	e8 55 e3 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ceb:	6a 02                	push   $0x2
f0101ced:	68 00 10 00 00       	push   $0x1000
f0101cf2:	56                   	push   %esi
f0101cf3:	ff 35 8c 8e 21 f0    	pushl  0xf0218e8c
f0101cf9:	e8 6f f6 ff ff       	call   f010136d <page_insert>
f0101cfe:	83 c4 10             	add    $0x10,%esp
f0101d01:	85 c0                	test   %eax,%eax
f0101d03:	74 19                	je     f0101d1e <mem_init+0x88a>
f0101d05:	68 64 72 10 f0       	push   $0xf0107264
f0101d0a:	68 54 79 10 f0       	push   $0xf0107954
f0101d0f:	68 09 04 00 00       	push   $0x409
f0101d14:	68 11 79 10 f0       	push   $0xf0107911
f0101d19:	e8 22 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d1e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d23:	a1 8c 8e 21 f0       	mov    0xf0218e8c,%eax
f0101d28:	e8 99 ed ff ff       	call   f0100ac6 <check_va2pa>
f0101d2d:	89 f2                	mov    %esi,%edx
f0101d2f:	2b 15 90 8e 21 f0    	sub    0xf0218e90,%edx
f0101d35:	c1 fa 03             	sar    $0x3,%edx
f0101d38:	c1 e2 0c             	shl    $0xc,%edx
f0101d3b:	39 d0                	cmp    %edx,%eax
f0101d3d:	74 19                	je     f0101d58 <mem_init+0x8c4>
f0101d3f:	68 a0 72 10 f0       	push   $0xf01072a0
f0101d44:	68 54 79 10 f0       	push   $0xf0107954
f0101d49:	68 0a 04 00 00       	push   $0x40a
f0101d4e:	68 11 79 10 f0       	push   $0xf0107911
f0101d53:	e8 e8 e2 ff ff       	call   f0100040 <_panic>
        assert(pp2->pp_ref == 1);
f0101d58:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d5d:	74 19                	je     f0101d78 <mem_init+0x8e4>
f0101d5f:	68 75 7b 10 f0       	push   $0xf0107b75
f0101d64:	68 54 79 10 f0       	push   $0xf0107954
f0101d69:	68 0b 04 00 00       	push   $0x40b
f0101d6e:	68 11 79 10 f0       	push   $0xf0107911
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
f0101d89:	68 01 7b 10 f0       	push   $0xf0107b01
f0101d8e:	68 54 79 10 f0       	push   $0xf0107954
f0101d93:	68 0f 04 00 00       	push   $0x40f
f0101d98:	68 11 79 10 f0       	push   $0xf0107911
f0101d9d:	e8 9e e2 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101da2:	8b 15 8c 8e 21 f0    	mov    0xf0218e8c,%edx
f0101da8:	8b 02                	mov    (%edx),%eax
f0101daa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101daf:	89 c1                	mov    %eax,%ecx
f0101db1:	c1 e9 0c             	shr    $0xc,%ecx
f0101db4:	3b 0d 88 8e 21 f0    	cmp    0xf0218e88,%ecx
f0101dba:	72 15                	jb     f0101dd1 <mem_init+0x93d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101dbc:	50                   	push   %eax
f0101dbd:	68 44 6a 10 f0       	push   $0xf0106a44
f0101dc2:	68 12 04 00 00       	push   $0x412
f0101dc7:	68 11 79 10 f0       	push   $0xf0107911
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
f0101df6:	68 d0 72 10 f0       	push   $0xf01072d0
f0101dfb:	68 54 79 10 f0       	push   $0xf0107954
f0101e00:	68 13 04 00 00       	push   $0x413
f0101e05:	68 11 79 10 f0       	push   $0xf0107911
f0101e0a:	e8 31 e2 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101e0f:	6a 06                	push   $0x6
f0101e11:	68 00 10 00 00       	push   $0x1000
f0101e16:	56                   	push   %esi
f0101e17:	ff 35 8c 8e 21 f0    	pushl  0xf0218e8c
f0101e1d:	e8 4b f5 ff ff       	call   f010136d <page_insert>
f0101e22:	83 c4 10             	add    $0x10,%esp
f0101e25:	85 c0                	test   %eax,%eax
f0101e27:	74 19                	je     f0101e42 <mem_init+0x9ae>
f0101e29:	68 10 73 10 f0       	push   $0xf0107310
f0101e2e:	68 54 79 10 f0       	push   $0xf0107954
f0101e33:	68 16 04 00 00       	push   $0x416
f0101e38:	68 11 79 10 f0       	push   $0xf0107911
f0101e3d:	e8 fe e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e42:	8b 3d 8c 8e 21 f0    	mov    0xf0218e8c,%edi
f0101e48:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e4d:	89 f8                	mov    %edi,%eax
f0101e4f:	e8 72 ec ff ff       	call   f0100ac6 <check_va2pa>
f0101e54:	89 f2                	mov    %esi,%edx
f0101e56:	2b 15 90 8e 21 f0    	sub    0xf0218e90,%edx
f0101e5c:	c1 fa 03             	sar    $0x3,%edx
f0101e5f:	c1 e2 0c             	shl    $0xc,%edx
f0101e62:	39 d0                	cmp    %edx,%eax
f0101e64:	74 19                	je     f0101e7f <mem_init+0x9eb>
f0101e66:	68 a0 72 10 f0       	push   $0xf01072a0
f0101e6b:	68 54 79 10 f0       	push   $0xf0107954
f0101e70:	68 17 04 00 00       	push   $0x417
f0101e75:	68 11 79 10 f0       	push   $0xf0107911
f0101e7a:	e8 c1 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101e7f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101e84:	74 19                	je     f0101e9f <mem_init+0xa0b>
f0101e86:	68 75 7b 10 f0       	push   $0xf0107b75
f0101e8b:	68 54 79 10 f0       	push   $0xf0107954
f0101e90:	68 18 04 00 00       	push   $0x418
f0101e95:	68 11 79 10 f0       	push   $0xf0107911
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
f0101eb7:	68 50 73 10 f0       	push   $0xf0107350
f0101ebc:	68 54 79 10 f0       	push   $0xf0107954
f0101ec1:	68 19 04 00 00       	push   $0x419
f0101ec6:	68 11 79 10 f0       	push   $0xf0107911
f0101ecb:	e8 70 e1 ff ff       	call   f0100040 <_panic>
        assert(kern_pgdir[0] & PTE_U);
f0101ed0:	a1 8c 8e 21 f0       	mov    0xf0218e8c,%eax
f0101ed5:	f6 00 04             	testb  $0x4,(%eax)
f0101ed8:	75 19                	jne    f0101ef3 <mem_init+0xa5f>
f0101eda:	68 86 7b 10 f0       	push   $0xf0107b86
f0101edf:	68 54 79 10 f0       	push   $0xf0107954
f0101ee4:	68 1a 04 00 00       	push   $0x41a
f0101ee9:	68 11 79 10 f0       	push   $0xf0107911
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
f0101f08:	68 64 72 10 f0       	push   $0xf0107264
f0101f0d:	68 54 79 10 f0       	push   $0xf0107954
f0101f12:	68 1d 04 00 00       	push   $0x41d
f0101f17:	68 11 79 10 f0       	push   $0xf0107911
f0101f1c:	e8 1f e1 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101f21:	83 ec 04             	sub    $0x4,%esp
f0101f24:	6a 00                	push   $0x0
f0101f26:	68 00 10 00 00       	push   $0x1000
f0101f2b:	ff 35 8c 8e 21 f0    	pushl  0xf0218e8c
f0101f31:	e8 8c f1 ff ff       	call   f01010c2 <pgdir_walk>
f0101f36:	83 c4 10             	add    $0x10,%esp
f0101f39:	f6 00 02             	testb  $0x2,(%eax)
f0101f3c:	75 19                	jne    f0101f57 <mem_init+0xac3>
f0101f3e:	68 84 73 10 f0       	push   $0xf0107384
f0101f43:	68 54 79 10 f0       	push   $0xf0107954
f0101f48:	68 1e 04 00 00       	push   $0x41e
f0101f4d:	68 11 79 10 f0       	push   $0xf0107911
f0101f52:	e8 e9 e0 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f57:	83 ec 04             	sub    $0x4,%esp
f0101f5a:	6a 00                	push   $0x0
f0101f5c:	68 00 10 00 00       	push   $0x1000
f0101f61:	ff 35 8c 8e 21 f0    	pushl  0xf0218e8c
f0101f67:	e8 56 f1 ff ff       	call   f01010c2 <pgdir_walk>
f0101f6c:	83 c4 10             	add    $0x10,%esp
f0101f6f:	f6 00 04             	testb  $0x4,(%eax)
f0101f72:	74 19                	je     f0101f8d <mem_init+0xaf9>
f0101f74:	68 b8 73 10 f0       	push   $0xf01073b8
f0101f79:	68 54 79 10 f0       	push   $0xf0107954
f0101f7e:	68 1f 04 00 00       	push   $0x41f
f0101f83:	68 11 79 10 f0       	push   $0xf0107911
f0101f88:	e8 b3 e0 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101f8d:	6a 02                	push   $0x2
f0101f8f:	68 00 00 40 00       	push   $0x400000
f0101f94:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101f97:	ff 35 8c 8e 21 f0    	pushl  0xf0218e8c
f0101f9d:	e8 cb f3 ff ff       	call   f010136d <page_insert>
f0101fa2:	83 c4 10             	add    $0x10,%esp
f0101fa5:	85 c0                	test   %eax,%eax
f0101fa7:	78 19                	js     f0101fc2 <mem_init+0xb2e>
f0101fa9:	68 f0 73 10 f0       	push   $0xf01073f0
f0101fae:	68 54 79 10 f0       	push   $0xf0107954
f0101fb3:	68 22 04 00 00       	push   $0x422
f0101fb8:	68 11 79 10 f0       	push   $0xf0107911
f0101fbd:	e8 7e e0 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101fc2:	6a 02                	push   $0x2
f0101fc4:	68 00 10 00 00       	push   $0x1000
f0101fc9:	53                   	push   %ebx
f0101fca:	ff 35 8c 8e 21 f0    	pushl  0xf0218e8c
f0101fd0:	e8 98 f3 ff ff       	call   f010136d <page_insert>
f0101fd5:	83 c4 10             	add    $0x10,%esp
f0101fd8:	85 c0                	test   %eax,%eax
f0101fda:	74 19                	je     f0101ff5 <mem_init+0xb61>
f0101fdc:	68 28 74 10 f0       	push   $0xf0107428
f0101fe1:	68 54 79 10 f0       	push   $0xf0107954
f0101fe6:	68 25 04 00 00       	push   $0x425
f0101feb:	68 11 79 10 f0       	push   $0xf0107911
f0101ff0:	e8 4b e0 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101ff5:	83 ec 04             	sub    $0x4,%esp
f0101ff8:	6a 00                	push   $0x0
f0101ffa:	68 00 10 00 00       	push   $0x1000
f0101fff:	ff 35 8c 8e 21 f0    	pushl  0xf0218e8c
f0102005:	e8 b8 f0 ff ff       	call   f01010c2 <pgdir_walk>
f010200a:	83 c4 10             	add    $0x10,%esp
f010200d:	f6 00 04             	testb  $0x4,(%eax)
f0102010:	74 19                	je     f010202b <mem_init+0xb97>
f0102012:	68 b8 73 10 f0       	push   $0xf01073b8
f0102017:	68 54 79 10 f0       	push   $0xf0107954
f010201c:	68 26 04 00 00       	push   $0x426
f0102021:	68 11 79 10 f0       	push   $0xf0107911
f0102026:	e8 15 e0 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010202b:	8b 3d 8c 8e 21 f0    	mov    0xf0218e8c,%edi
f0102031:	ba 00 00 00 00       	mov    $0x0,%edx
f0102036:	89 f8                	mov    %edi,%eax
f0102038:	e8 89 ea ff ff       	call   f0100ac6 <check_va2pa>
f010203d:	89 c1                	mov    %eax,%ecx
f010203f:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102042:	89 d8                	mov    %ebx,%eax
f0102044:	2b 05 90 8e 21 f0    	sub    0xf0218e90,%eax
f010204a:	c1 f8 03             	sar    $0x3,%eax
f010204d:	c1 e0 0c             	shl    $0xc,%eax
f0102050:	39 c1                	cmp    %eax,%ecx
f0102052:	74 19                	je     f010206d <mem_init+0xbd9>
f0102054:	68 64 74 10 f0       	push   $0xf0107464
f0102059:	68 54 79 10 f0       	push   $0xf0107954
f010205e:	68 29 04 00 00       	push   $0x429
f0102063:	68 11 79 10 f0       	push   $0xf0107911
f0102068:	e8 d3 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010206d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102072:	89 f8                	mov    %edi,%eax
f0102074:	e8 4d ea ff ff       	call   f0100ac6 <check_va2pa>
f0102079:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f010207c:	74 19                	je     f0102097 <mem_init+0xc03>
f010207e:	68 90 74 10 f0       	push   $0xf0107490
f0102083:	68 54 79 10 f0       	push   $0xf0107954
f0102088:	68 2a 04 00 00       	push   $0x42a
f010208d:	68 11 79 10 f0       	push   $0xf0107911
f0102092:	e8 a9 df ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102097:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f010209c:	74 19                	je     f01020b7 <mem_init+0xc23>
f010209e:	68 9c 7b 10 f0       	push   $0xf0107b9c
f01020a3:	68 54 79 10 f0       	push   $0xf0107954
f01020a8:	68 2c 04 00 00       	push   $0x42c
f01020ad:	68 11 79 10 f0       	push   $0xf0107911
f01020b2:	e8 89 df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01020b7:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01020bc:	74 19                	je     f01020d7 <mem_init+0xc43>
f01020be:	68 ad 7b 10 f0       	push   $0xf0107bad
f01020c3:	68 54 79 10 f0       	push   $0xf0107954
f01020c8:	68 2d 04 00 00       	push   $0x42d
f01020cd:	68 11 79 10 f0       	push   $0xf0107911
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
f01020ec:	68 c0 74 10 f0       	push   $0xf01074c0
f01020f1:	68 54 79 10 f0       	push   $0xf0107954
f01020f6:	68 30 04 00 00       	push   $0x430
f01020fb:	68 11 79 10 f0       	push   $0xf0107911
f0102100:	e8 3b df ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102105:	83 ec 08             	sub    $0x8,%esp
f0102108:	6a 00                	push   $0x0
f010210a:	ff 35 8c 8e 21 f0    	pushl  0xf0218e8c
f0102110:	e8 ea f1 ff ff       	call   f01012ff <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102115:	8b 3d 8c 8e 21 f0    	mov    0xf0218e8c,%edi
f010211b:	ba 00 00 00 00       	mov    $0x0,%edx
f0102120:	89 f8                	mov    %edi,%eax
f0102122:	e8 9f e9 ff ff       	call   f0100ac6 <check_va2pa>
f0102127:	83 c4 10             	add    $0x10,%esp
f010212a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010212d:	74 19                	je     f0102148 <mem_init+0xcb4>
f010212f:	68 e4 74 10 f0       	push   $0xf01074e4
f0102134:	68 54 79 10 f0       	push   $0xf0107954
f0102139:	68 34 04 00 00       	push   $0x434
f010213e:	68 11 79 10 f0       	push   $0xf0107911
f0102143:	e8 f8 de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102148:	ba 00 10 00 00       	mov    $0x1000,%edx
f010214d:	89 f8                	mov    %edi,%eax
f010214f:	e8 72 e9 ff ff       	call   f0100ac6 <check_va2pa>
f0102154:	89 da                	mov    %ebx,%edx
f0102156:	2b 15 90 8e 21 f0    	sub    0xf0218e90,%edx
f010215c:	c1 fa 03             	sar    $0x3,%edx
f010215f:	c1 e2 0c             	shl    $0xc,%edx
f0102162:	39 d0                	cmp    %edx,%eax
f0102164:	74 19                	je     f010217f <mem_init+0xceb>
f0102166:	68 90 74 10 f0       	push   $0xf0107490
f010216b:	68 54 79 10 f0       	push   $0xf0107954
f0102170:	68 35 04 00 00       	push   $0x435
f0102175:	68 11 79 10 f0       	push   $0xf0107911
f010217a:	e8 c1 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010217f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102184:	74 19                	je     f010219f <mem_init+0xd0b>
f0102186:	68 53 7b 10 f0       	push   $0xf0107b53
f010218b:	68 54 79 10 f0       	push   $0xf0107954
f0102190:	68 36 04 00 00       	push   $0x436
f0102195:	68 11 79 10 f0       	push   $0xf0107911
f010219a:	e8 a1 de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010219f:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01021a4:	74 19                	je     f01021bf <mem_init+0xd2b>
f01021a6:	68 ad 7b 10 f0       	push   $0xf0107bad
f01021ab:	68 54 79 10 f0       	push   $0xf0107954
f01021b0:	68 37 04 00 00       	push   $0x437
f01021b5:	68 11 79 10 f0       	push   $0xf0107911
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
f01021d4:	68 08 75 10 f0       	push   $0xf0107508
f01021d9:	68 54 79 10 f0       	push   $0xf0107954
f01021de:	68 3a 04 00 00       	push   $0x43a
f01021e3:	68 11 79 10 f0       	push   $0xf0107911
f01021e8:	e8 53 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01021ed:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01021f2:	75 19                	jne    f010220d <mem_init+0xd79>
f01021f4:	68 be 7b 10 f0       	push   $0xf0107bbe
f01021f9:	68 54 79 10 f0       	push   $0xf0107954
f01021fe:	68 3b 04 00 00       	push   $0x43b
f0102203:	68 11 79 10 f0       	push   $0xf0107911
f0102208:	e8 33 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f010220d:	83 3b 00             	cmpl   $0x0,(%ebx)
f0102210:	74 19                	je     f010222b <mem_init+0xd97>
f0102212:	68 ca 7b 10 f0       	push   $0xf0107bca
f0102217:	68 54 79 10 f0       	push   $0xf0107954
f010221c:	68 3c 04 00 00       	push   $0x43c
f0102221:	68 11 79 10 f0       	push   $0xf0107911
f0102226:	e8 15 de ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010222b:	83 ec 08             	sub    $0x8,%esp
f010222e:	68 00 10 00 00       	push   $0x1000
f0102233:	ff 35 8c 8e 21 f0    	pushl  0xf0218e8c
f0102239:	e8 c1 f0 ff ff       	call   f01012ff <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010223e:	8b 3d 8c 8e 21 f0    	mov    0xf0218e8c,%edi
f0102244:	ba 00 00 00 00       	mov    $0x0,%edx
f0102249:	89 f8                	mov    %edi,%eax
f010224b:	e8 76 e8 ff ff       	call   f0100ac6 <check_va2pa>
f0102250:	83 c4 10             	add    $0x10,%esp
f0102253:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102256:	74 19                	je     f0102271 <mem_init+0xddd>
f0102258:	68 e4 74 10 f0       	push   $0xf01074e4
f010225d:	68 54 79 10 f0       	push   $0xf0107954
f0102262:	68 40 04 00 00       	push   $0x440
f0102267:	68 11 79 10 f0       	push   $0xf0107911
f010226c:	e8 cf dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102271:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102276:	89 f8                	mov    %edi,%eax
f0102278:	e8 49 e8 ff ff       	call   f0100ac6 <check_va2pa>
f010227d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102280:	74 19                	je     f010229b <mem_init+0xe07>
f0102282:	68 40 75 10 f0       	push   $0xf0107540
f0102287:	68 54 79 10 f0       	push   $0xf0107954
f010228c:	68 41 04 00 00       	push   $0x441
f0102291:	68 11 79 10 f0       	push   $0xf0107911
f0102296:	e8 a5 dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010229b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022a0:	74 19                	je     f01022bb <mem_init+0xe27>
f01022a2:	68 df 7b 10 f0       	push   $0xf0107bdf
f01022a7:	68 54 79 10 f0       	push   $0xf0107954
f01022ac:	68 42 04 00 00       	push   $0x442
f01022b1:	68 11 79 10 f0       	push   $0xf0107911
f01022b6:	e8 85 dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01022bb:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01022c0:	74 19                	je     f01022db <mem_init+0xe47>
f01022c2:	68 ad 7b 10 f0       	push   $0xf0107bad
f01022c7:	68 54 79 10 f0       	push   $0xf0107954
f01022cc:	68 43 04 00 00       	push   $0x443
f01022d1:	68 11 79 10 f0       	push   $0xf0107911
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
f01022f0:	68 68 75 10 f0       	push   $0xf0107568
f01022f5:	68 54 79 10 f0       	push   $0xf0107954
f01022fa:	68 46 04 00 00       	push   $0x446
f01022ff:	68 11 79 10 f0       	push   $0xf0107911
f0102304:	e8 37 dd ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102309:	83 ec 0c             	sub    $0xc,%esp
f010230c:	6a 00                	push   $0x0
f010230e:	e8 a9 ec ff ff       	call   f0100fbc <page_alloc>
f0102313:	83 c4 10             	add    $0x10,%esp
f0102316:	85 c0                	test   %eax,%eax
f0102318:	74 19                	je     f0102333 <mem_init+0xe9f>
f010231a:	68 01 7b 10 f0       	push   $0xf0107b01
f010231f:	68 54 79 10 f0       	push   $0xf0107954
f0102324:	68 49 04 00 00       	push   $0x449
f0102329:	68 11 79 10 f0       	push   $0xf0107911
f010232e:	e8 0d dd ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102333:	8b 0d 8c 8e 21 f0    	mov    0xf0218e8c,%ecx
f0102339:	8b 11                	mov    (%ecx),%edx
f010233b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102341:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102344:	2b 05 90 8e 21 f0    	sub    0xf0218e90,%eax
f010234a:	c1 f8 03             	sar    $0x3,%eax
f010234d:	c1 e0 0c             	shl    $0xc,%eax
f0102350:	39 c2                	cmp    %eax,%edx
f0102352:	74 19                	je     f010236d <mem_init+0xed9>
f0102354:	68 0c 72 10 f0       	push   $0xf010720c
f0102359:	68 54 79 10 f0       	push   $0xf0107954
f010235e:	68 4c 04 00 00       	push   $0x44c
f0102363:	68 11 79 10 f0       	push   $0xf0107911
f0102368:	e8 d3 dc ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f010236d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102373:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102376:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010237b:	74 19                	je     f0102396 <mem_init+0xf02>
f010237d:	68 64 7b 10 f0       	push   $0xf0107b64
f0102382:	68 54 79 10 f0       	push   $0xf0107954
f0102387:	68 4e 04 00 00       	push   $0x44e
f010238c:	68 11 79 10 f0       	push   $0xf0107911
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
f01023b2:	ff 35 8c 8e 21 f0    	pushl  0xf0218e8c
f01023b8:	e8 05 ed ff ff       	call   f01010c2 <pgdir_walk>
f01023bd:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01023c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01023c3:	8b 0d 8c 8e 21 f0    	mov    0xf0218e8c,%ecx
f01023c9:	8b 51 04             	mov    0x4(%ecx),%edx
f01023cc:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01023d2:	8b 3d 88 8e 21 f0    	mov    0xf0218e88,%edi
f01023d8:	89 d0                	mov    %edx,%eax
f01023da:	c1 e8 0c             	shr    $0xc,%eax
f01023dd:	83 c4 10             	add    $0x10,%esp
f01023e0:	39 f8                	cmp    %edi,%eax
f01023e2:	72 15                	jb     f01023f9 <mem_init+0xf65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023e4:	52                   	push   %edx
f01023e5:	68 44 6a 10 f0       	push   $0xf0106a44
f01023ea:	68 55 04 00 00       	push   $0x455
f01023ef:	68 11 79 10 f0       	push   $0xf0107911
f01023f4:	e8 47 dc ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01023f9:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01023ff:	39 55 c8             	cmp    %edx,-0x38(%ebp)
f0102402:	74 19                	je     f010241d <mem_init+0xf89>
f0102404:	68 f0 7b 10 f0       	push   $0xf0107bf0
f0102409:	68 54 79 10 f0       	push   $0xf0107954
f010240e:	68 56 04 00 00       	push   $0x456
f0102413:	68 11 79 10 f0       	push   $0xf0107911
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
f010242d:	2b 05 90 8e 21 f0    	sub    0xf0218e90,%eax
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
f0102443:	68 44 6a 10 f0       	push   $0xf0106a44
f0102448:	6a 58                	push   $0x58
f010244a:	68 3a 79 10 f0       	push   $0xf010793a
f010244f:	e8 ec db ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102454:	83 ec 04             	sub    $0x4,%esp
f0102457:	68 00 10 00 00       	push   $0x1000
f010245c:	68 ff 00 00 00       	push   $0xff
f0102461:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102466:	50                   	push   %eax
f0102467:	e8 fe 38 00 00       	call   f0105d6a <memset>
	page_free(pp0);
f010246c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010246f:	89 3c 24             	mov    %edi,(%esp)
f0102472:	e8 b5 eb ff ff       	call   f010102c <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102477:	83 c4 0c             	add    $0xc,%esp
f010247a:	6a 01                	push   $0x1
f010247c:	6a 00                	push   $0x0
f010247e:	ff 35 8c 8e 21 f0    	pushl  0xf0218e8c
f0102484:	e8 39 ec ff ff       	call   f01010c2 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102489:	89 fa                	mov    %edi,%edx
f010248b:	2b 15 90 8e 21 f0    	sub    0xf0218e90,%edx
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
f010249f:	3b 05 88 8e 21 f0    	cmp    0xf0218e88,%eax
f01024a5:	72 12                	jb     f01024b9 <mem_init+0x1025>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024a7:	52                   	push   %edx
f01024a8:	68 44 6a 10 f0       	push   $0xf0106a44
f01024ad:	6a 58                	push   $0x58
f01024af:	68 3a 79 10 f0       	push   $0xf010793a
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
f01024cd:	68 08 7c 10 f0       	push   $0xf0107c08
f01024d2:	68 54 79 10 f0       	push   $0xf0107954
f01024d7:	68 60 04 00 00       	push   $0x460
f01024dc:	68 11 79 10 f0       	push   $0xf0107911
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
f01024ed:	a1 8c 8e 21 f0       	mov    0xf0218e8c,%eax
f01024f2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01024f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024fb:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102501:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102504:	89 0d 40 82 21 f0    	mov    %ecx,0xf0218240

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
f010255d:	68 8c 75 10 f0       	push   $0xf010758c
f0102562:	68 54 79 10 f0       	push   $0xf0107954
f0102567:	68 70 04 00 00       	push   $0x470
f010256c:	68 11 79 10 f0       	push   $0xf0107911
f0102571:	e8 ca da ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102576:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f010257c:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102582:	77 08                	ja     f010258c <mem_init+0x10f8>
f0102584:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010258a:	77 19                	ja     f01025a5 <mem_init+0x1111>
f010258c:	68 b4 75 10 f0       	push   $0xf01075b4
f0102591:	68 54 79 10 f0       	push   $0xf0107954
f0102596:	68 71 04 00 00       	push   $0x471
f010259b:	68 11 79 10 f0       	push   $0xf0107911
f01025a0:	e8 9b da ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01025a5:	89 da                	mov    %ebx,%edx
f01025a7:	09 f2                	or     %esi,%edx
f01025a9:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01025af:	74 19                	je     f01025ca <mem_init+0x1136>
f01025b1:	68 dc 75 10 f0       	push   $0xf01075dc
f01025b6:	68 54 79 10 f0       	push   $0xf0107954
f01025bb:	68 73 04 00 00       	push   $0x473
f01025c0:	68 11 79 10 f0       	push   $0xf0107911
f01025c5:	e8 76 da ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f01025ca:	39 c6                	cmp    %eax,%esi
f01025cc:	73 19                	jae    f01025e7 <mem_init+0x1153>
f01025ce:	68 1f 7c 10 f0       	push   $0xf0107c1f
f01025d3:	68 54 79 10 f0       	push   $0xf0107954
f01025d8:	68 75 04 00 00       	push   $0x475
f01025dd:	68 11 79 10 f0       	push   $0xf0107911
f01025e2:	e8 59 da ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01025e7:	8b 3d 8c 8e 21 f0    	mov    0xf0218e8c,%edi
f01025ed:	89 da                	mov    %ebx,%edx
f01025ef:	89 f8                	mov    %edi,%eax
f01025f1:	e8 d0 e4 ff ff       	call   f0100ac6 <check_va2pa>
f01025f6:	85 c0                	test   %eax,%eax
f01025f8:	74 19                	je     f0102613 <mem_init+0x117f>
f01025fa:	68 04 76 10 f0       	push   $0xf0107604
f01025ff:	68 54 79 10 f0       	push   $0xf0107954
f0102604:	68 77 04 00 00       	push   $0x477
f0102609:	68 11 79 10 f0       	push   $0xf0107911
f010260e:	e8 2d da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102613:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102619:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010261c:	89 c2                	mov    %eax,%edx
f010261e:	89 f8                	mov    %edi,%eax
f0102620:	e8 a1 e4 ff ff       	call   f0100ac6 <check_va2pa>
f0102625:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010262a:	74 19                	je     f0102645 <mem_init+0x11b1>
f010262c:	68 28 76 10 f0       	push   $0xf0107628
f0102631:	68 54 79 10 f0       	push   $0xf0107954
f0102636:	68 78 04 00 00       	push   $0x478
f010263b:	68 11 79 10 f0       	push   $0xf0107911
f0102640:	e8 fb d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102645:	89 f2                	mov    %esi,%edx
f0102647:	89 f8                	mov    %edi,%eax
f0102649:	e8 78 e4 ff ff       	call   f0100ac6 <check_va2pa>
f010264e:	85 c0                	test   %eax,%eax
f0102650:	74 19                	je     f010266b <mem_init+0x11d7>
f0102652:	68 58 76 10 f0       	push   $0xf0107658
f0102657:	68 54 79 10 f0       	push   $0xf0107954
f010265c:	68 79 04 00 00       	push   $0x479
f0102661:	68 11 79 10 f0       	push   $0xf0107911
f0102666:	e8 d5 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f010266b:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102671:	89 f8                	mov    %edi,%eax
f0102673:	e8 4e e4 ff ff       	call   f0100ac6 <check_va2pa>
f0102678:	83 f8 ff             	cmp    $0xffffffff,%eax
f010267b:	74 19                	je     f0102696 <mem_init+0x1202>
f010267d:	68 7c 76 10 f0       	push   $0xf010767c
f0102682:	68 54 79 10 f0       	push   $0xf0107954
f0102687:	68 7a 04 00 00       	push   $0x47a
f010268c:	68 11 79 10 f0       	push   $0xf0107911
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
f01026aa:	68 a8 76 10 f0       	push   $0xf01076a8
f01026af:	68 54 79 10 f0       	push   $0xf0107954
f01026b4:	68 7c 04 00 00       	push   $0x47c
f01026b9:	68 11 79 10 f0       	push   $0xf0107911
f01026be:	e8 7d d9 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01026c3:	83 ec 04             	sub    $0x4,%esp
f01026c6:	6a 00                	push   $0x0
f01026c8:	53                   	push   %ebx
f01026c9:	ff 35 8c 8e 21 f0    	pushl  0xf0218e8c
f01026cf:	e8 ee e9 ff ff       	call   f01010c2 <pgdir_walk>
f01026d4:	8b 00                	mov    (%eax),%eax
f01026d6:	83 c4 10             	add    $0x10,%esp
f01026d9:	83 e0 04             	and    $0x4,%eax
f01026dc:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01026df:	74 19                	je     f01026fa <mem_init+0x1266>
f01026e1:	68 ec 76 10 f0       	push   $0xf01076ec
f01026e6:	68 54 79 10 f0       	push   $0xf0107954
f01026eb:	68 7d 04 00 00       	push   $0x47d
f01026f0:	68 11 79 10 f0       	push   $0xf0107911
f01026f5:	e8 46 d9 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f01026fa:	83 ec 04             	sub    $0x4,%esp
f01026fd:	6a 00                	push   $0x0
f01026ff:	53                   	push   %ebx
f0102700:	ff 35 8c 8e 21 f0    	pushl  0xf0218e8c
f0102706:	e8 b7 e9 ff ff       	call   f01010c2 <pgdir_walk>
f010270b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102711:	83 c4 0c             	add    $0xc,%esp
f0102714:	6a 00                	push   $0x0
f0102716:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102719:	ff 35 8c 8e 21 f0    	pushl  0xf0218e8c
f010271f:	e8 9e e9 ff ff       	call   f01010c2 <pgdir_walk>
f0102724:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f010272a:	83 c4 0c             	add    $0xc,%esp
f010272d:	6a 00                	push   $0x0
f010272f:	56                   	push   %esi
f0102730:	ff 35 8c 8e 21 f0    	pushl  0xf0218e8c
f0102736:	e8 87 e9 ff ff       	call   f01010c2 <pgdir_walk>
f010273b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102741:	c7 04 24 31 7c 10 f0 	movl   $0xf0107c31,(%esp)
f0102748:	e8 1b 15 00 00       	call   f0103c68 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
        boot_map_region(kern_pgdir, UPAGES, ROUNDUP(pages_size, PGSIZE), PADDR(pages), PTE_U); 
f010274d:	a1 90 8e 21 f0       	mov    0xf0218e90,%eax
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
f010275d:	68 68 6a 10 f0       	push   $0xf0106a68
f0102762:	68 c9 00 00 00       	push   $0xc9
f0102767:	68 11 79 10 f0       	push   $0xf0107911
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
f0102792:	a1 8c 8e 21 f0       	mov    0xf0218e8c,%eax
f0102797:	e8 0e ea ff ff       	call   f01011aa <boot_map_region>
        boot_map_region(kern_pgdir, (uintptr_t) pages, ROUNDUP(pages_size, PGSIZE), PADDR(pages), PTE_W);
f010279c:	8b 15 90 8e 21 f0    	mov    0xf0218e90,%edx
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
f01027ae:	68 68 6a 10 f0       	push   $0xf0106a68
f01027b3:	68 ca 00 00 00       	push   $0xca
f01027b8:	68 11 79 10 f0       	push   $0xf0107911
f01027bd:	e8 7e d8 ff ff       	call   f0100040 <_panic>
f01027c2:	83 ec 08             	sub    $0x8,%esp
f01027c5:	6a 02                	push   $0x2
f01027c7:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
f01027cd:	50                   	push   %eax
f01027ce:	89 d9                	mov    %ebx,%ecx
f01027d0:	a1 8c 8e 21 f0       	mov    0xf0218e8c,%eax
f01027d5:	e8 d0 e9 ff ff       	call   f01011aa <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
        boot_map_region(kern_pgdir, UENVS, ROUNDUP(envs_size, PGSIZE), PADDR(envs), PTE_U);
f01027da:	a1 4c 82 21 f0       	mov    0xf021824c,%eax
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
f01027ea:	68 68 6a 10 f0       	push   $0xf0106a68
f01027ef:	68 d3 00 00 00       	push   $0xd3
f01027f4:	68 11 79 10 f0       	push   $0xf0107911
f01027f9:	e8 42 d8 ff ff       	call   f0100040 <_panic>
f01027fe:	83 ec 08             	sub    $0x8,%esp
f0102801:	6a 04                	push   $0x4
f0102803:	05 00 00 00 10       	add    $0x10000000,%eax
f0102808:	50                   	push   %eax
f0102809:	b9 00 c0 02 00       	mov    $0x2c000,%ecx
f010280e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102813:	a1 8c 8e 21 f0       	mov    0xf0218e8c,%eax
f0102818:	e8 8d e9 ff ff       	call   f01011aa <boot_map_region>
        boot_map_region(kern_pgdir, (uintptr_t) envs, ROUNDUP(envs_size, PGSIZE), PADDR(pages), PTE_W);
f010281d:	a1 90 8e 21 f0       	mov    0xf0218e90,%eax
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
f010282d:	68 68 6a 10 f0       	push   $0xf0106a68
f0102832:	68 d4 00 00 00       	push   $0xd4
f0102837:	68 11 79 10 f0       	push   $0xf0107911
f010283c:	e8 ff d7 ff ff       	call   f0100040 <_panic>
f0102841:	83 ec 08             	sub    $0x8,%esp
f0102844:	6a 02                	push   $0x2
f0102846:	05 00 00 00 10       	add    $0x10000000,%eax
f010284b:	50                   	push   %eax
f010284c:	b9 00 c0 02 00       	mov    $0x2c000,%ecx
f0102851:	8b 15 4c 82 21 f0    	mov    0xf021824c,%edx
f0102857:	a1 8c 8e 21 f0       	mov    0xf0218e8c,%eax
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
f0102871:	68 68 6a 10 f0       	push   $0xf0106a68
f0102876:	68 e1 00 00 00       	push   $0xe1
f010287b:	68 11 79 10 f0       	push   $0xf0107911
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
f0102899:	a1 8c 8e 21 f0       	mov    0xf0218e8c,%eax
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
f01028b4:	a1 8c 8e 21 f0       	mov    0xf0218e8c,%eax
f01028b9:	e8 ec e8 ff ff       	call   f01011aa <boot_map_region>
f01028be:	c7 45 c4 00 a0 21 f0 	movl   $0xf021a000,-0x3c(%ebp)
f01028c5:	83 c4 10             	add    $0x10,%esp
f01028c8:	bb 00 a0 21 f0       	mov    $0xf021a000,%ebx
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
f01028db:	68 68 6a 10 f0       	push   $0xf0106a68
f01028e0:	68 22 01 00 00       	push   $0x122
f01028e5:	68 11 79 10 f0       	push   $0xf0107911
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
f0102902:	a1 8c 8e 21 f0       	mov    0xf0218e8c,%eax
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
f010291b:	b8 00 a0 25 f0       	mov    $0xf025a000,%eax
f0102920:	39 d8                	cmp    %ebx,%eax
f0102922:	75 ae                	jne    f01028d2 <mem_init+0x143e>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102924:	8b 3d 8c 8e 21 f0    	mov    0xf0218e8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010292a:	a1 88 8e 21 f0       	mov    0xf0218e88,%eax
f010292f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102932:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102939:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010293e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102941:	8b 35 90 8e 21 f0    	mov    0xf0218e90,%esi
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
f0102968:	68 68 6a 10 f0       	push   $0xf0106a68
f010296d:	68 94 03 00 00       	push   $0x394
f0102972:	68 11 79 10 f0       	push   $0xf0107911
f0102977:	e8 c4 d6 ff ff       	call   f0100040 <_panic>
f010297c:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f0102983:	39 c2                	cmp    %eax,%edx
f0102985:	74 19                	je     f01029a0 <mem_init+0x150c>
f0102987:	68 20 77 10 f0       	push   $0xf0107720
f010298c:	68 54 79 10 f0       	push   $0xf0107954
f0102991:	68 94 03 00 00       	push   $0x394
f0102996:	68 11 79 10 f0       	push   $0xf0107911
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
f01029ab:	8b 35 4c 82 21 f0    	mov    0xf021824c,%esi
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
f01029cc:	68 68 6a 10 f0       	push   $0xf0106a68
f01029d1:	68 99 03 00 00       	push   $0x399
f01029d6:	68 11 79 10 f0       	push   $0xf0107911
f01029db:	e8 60 d6 ff ff       	call   f0100040 <_panic>
f01029e0:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f01029e7:	39 d0                	cmp    %edx,%eax
f01029e9:	74 19                	je     f0102a04 <mem_init+0x1570>
f01029eb:	68 54 77 10 f0       	push   $0xf0107754
f01029f0:	68 54 79 10 f0       	push   $0xf0107954
f01029f5:	68 99 03 00 00       	push   $0x399
f01029fa:	68 11 79 10 f0       	push   $0xf0107911
f01029ff:	e8 3c d6 ff ff       	call   f0100040 <_panic>
f0102a04:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102a0a:	81 fb 00 c0 c2 ee    	cmp    $0xeec2c000,%ebx
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
f0102a30:	68 88 77 10 f0       	push   $0xf0107788
f0102a35:	68 54 79 10 f0       	push   $0xf0107954
f0102a3a:	68 9d 03 00 00       	push   $0x39d
f0102a3f:	68 11 79 10 f0       	push   $0xf0107911
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
f0102a89:	68 68 6a 10 f0       	push   $0xf0106a68
f0102a8e:	68 a5 03 00 00       	push   $0x3a5
f0102a93:	68 11 79 10 f0       	push   $0xf0107911
f0102a98:	e8 a3 d5 ff ff       	call   f0100040 <_panic>
f0102a9d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102aa0:	8d 94 0b 00 a0 21 f0 	lea    -0xfde6000(%ebx,%ecx,1),%edx
f0102aa7:	39 d0                	cmp    %edx,%eax
f0102aa9:	74 19                	je     f0102ac4 <mem_init+0x1630>
f0102aab:	68 b0 77 10 f0       	push   $0xf01077b0
f0102ab0:	68 54 79 10 f0       	push   $0xf0107954
f0102ab5:	68 a5 03 00 00       	push   $0x3a5
f0102aba:	68 11 79 10 f0       	push   $0xf0107911
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
f0102aeb:	68 f8 77 10 f0       	push   $0xf01077f8
f0102af0:	68 54 79 10 f0       	push   $0xf0107954
f0102af5:	68 a7 03 00 00       	push   $0x3a7
f0102afa:	68 11 79 10 f0       	push   $0xf0107911
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
f0102b25:	b8 00 a0 25 f0       	mov    $0xf025a000,%eax
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
f0102b4a:	68 4a 7c 10 f0       	push   $0xf0107c4a
f0102b4f:	68 54 79 10 f0       	push   $0xf0107954
f0102b54:	68 b2 03 00 00       	push   $0x3b2
f0102b59:	68 11 79 10 f0       	push   $0xf0107911
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
f0102b72:	68 4a 7c 10 f0       	push   $0xf0107c4a
f0102b77:	68 54 79 10 f0       	push   $0xf0107954
f0102b7c:	68 b6 03 00 00       	push   $0x3b6
f0102b81:	68 11 79 10 f0       	push   $0xf0107911
f0102b86:	e8 b5 d4 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102b8b:	f6 c2 02             	test   $0x2,%dl
f0102b8e:	75 38                	jne    f0102bc8 <mem_init+0x1734>
f0102b90:	68 5b 7c 10 f0       	push   $0xf0107c5b
f0102b95:	68 54 79 10 f0       	push   $0xf0107954
f0102b9a:	68 b7 03 00 00       	push   $0x3b7
f0102b9f:	68 11 79 10 f0       	push   $0xf0107911
f0102ba4:	e8 97 d4 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102ba9:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102bad:	74 19                	je     f0102bc8 <mem_init+0x1734>
f0102baf:	68 6c 7c 10 f0       	push   $0xf0107c6c
f0102bb4:	68 54 79 10 f0       	push   $0xf0107954
f0102bb9:	68 b9 03 00 00       	push   $0x3b9
f0102bbe:	68 11 79 10 f0       	push   $0xf0107911
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
f0102bd9:	68 1c 78 10 f0       	push   $0xf010781c
f0102bde:	e8 85 10 00 00       	call   f0103c68 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102be3:	a1 8c 8e 21 f0       	mov    0xf0218e8c,%eax
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
f0102bf3:	68 68 6a 10 f0       	push   $0xf0106a68
f0102bf8:	68 fa 00 00 00       	push   $0xfa
f0102bfd:	68 11 79 10 f0       	push   $0xf0107911
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
f0102c3a:	68 56 7a 10 f0       	push   $0xf0107a56
f0102c3f:	68 54 79 10 f0       	push   $0xf0107954
f0102c44:	68 92 04 00 00       	push   $0x492
f0102c49:	68 11 79 10 f0       	push   $0xf0107911
f0102c4e:	e8 ed d3 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102c53:	83 ec 0c             	sub    $0xc,%esp
f0102c56:	6a 00                	push   $0x0
f0102c58:	e8 5f e3 ff ff       	call   f0100fbc <page_alloc>
f0102c5d:	89 c7                	mov    %eax,%edi
f0102c5f:	83 c4 10             	add    $0x10,%esp
f0102c62:	85 c0                	test   %eax,%eax
f0102c64:	75 19                	jne    f0102c7f <mem_init+0x17eb>
f0102c66:	68 6c 7a 10 f0       	push   $0xf0107a6c
f0102c6b:	68 54 79 10 f0       	push   $0xf0107954
f0102c70:	68 93 04 00 00       	push   $0x493
f0102c75:	68 11 79 10 f0       	push   $0xf0107911
f0102c7a:	e8 c1 d3 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102c7f:	83 ec 0c             	sub    $0xc,%esp
f0102c82:	6a 00                	push   $0x0
f0102c84:	e8 33 e3 ff ff       	call   f0100fbc <page_alloc>
f0102c89:	89 c6                	mov    %eax,%esi
f0102c8b:	83 c4 10             	add    $0x10,%esp
f0102c8e:	85 c0                	test   %eax,%eax
f0102c90:	75 19                	jne    f0102cab <mem_init+0x1817>
f0102c92:	68 82 7a 10 f0       	push   $0xf0107a82
f0102c97:	68 54 79 10 f0       	push   $0xf0107954
f0102c9c:	68 94 04 00 00       	push   $0x494
f0102ca1:	68 11 79 10 f0       	push   $0xf0107911
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
f0102cb6:	2b 05 90 8e 21 f0    	sub    0xf0218e90,%eax
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
f0102cca:	3b 15 88 8e 21 f0    	cmp    0xf0218e88,%edx
f0102cd0:	72 12                	jb     f0102ce4 <mem_init+0x1850>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102cd2:	50                   	push   %eax
f0102cd3:	68 44 6a 10 f0       	push   $0xf0106a44
f0102cd8:	6a 58                	push   $0x58
f0102cda:	68 3a 79 10 f0       	push   $0xf010793a
f0102cdf:	e8 5c d3 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102ce4:	83 ec 04             	sub    $0x4,%esp
f0102ce7:	68 00 10 00 00       	push   $0x1000
f0102cec:	6a 01                	push   $0x1
f0102cee:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102cf3:	50                   	push   %eax
f0102cf4:	e8 71 30 00 00       	call   f0105d6a <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102cf9:	89 f0                	mov    %esi,%eax
f0102cfb:	2b 05 90 8e 21 f0    	sub    0xf0218e90,%eax
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
f0102d0f:	3b 15 88 8e 21 f0    	cmp    0xf0218e88,%edx
f0102d15:	72 12                	jb     f0102d29 <mem_init+0x1895>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d17:	50                   	push   %eax
f0102d18:	68 44 6a 10 f0       	push   $0xf0106a44
f0102d1d:	6a 58                	push   $0x58
f0102d1f:	68 3a 79 10 f0       	push   $0xf010793a
f0102d24:	e8 17 d3 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102d29:	83 ec 04             	sub    $0x4,%esp
f0102d2c:	68 00 10 00 00       	push   $0x1000
f0102d31:	6a 02                	push   $0x2
f0102d33:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102d38:	50                   	push   %eax
f0102d39:	e8 2c 30 00 00       	call   f0105d6a <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102d3e:	6a 02                	push   $0x2
f0102d40:	68 00 10 00 00       	push   $0x1000
f0102d45:	57                   	push   %edi
f0102d46:	ff 35 8c 8e 21 f0    	pushl  0xf0218e8c
f0102d4c:	e8 1c e6 ff ff       	call   f010136d <page_insert>
	assert(pp1->pp_ref == 1);
f0102d51:	83 c4 20             	add    $0x20,%esp
f0102d54:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102d59:	74 19                	je     f0102d74 <mem_init+0x18e0>
f0102d5b:	68 53 7b 10 f0       	push   $0xf0107b53
f0102d60:	68 54 79 10 f0       	push   $0xf0107954
f0102d65:	68 99 04 00 00       	push   $0x499
f0102d6a:	68 11 79 10 f0       	push   $0xf0107911
f0102d6f:	e8 cc d2 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102d74:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102d7b:	01 01 01 
f0102d7e:	74 19                	je     f0102d99 <mem_init+0x1905>
f0102d80:	68 3c 78 10 f0       	push   $0xf010783c
f0102d85:	68 54 79 10 f0       	push   $0xf0107954
f0102d8a:	68 9a 04 00 00       	push   $0x49a
f0102d8f:	68 11 79 10 f0       	push   $0xf0107911
f0102d94:	e8 a7 d2 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102d99:	6a 02                	push   $0x2
f0102d9b:	68 00 10 00 00       	push   $0x1000
f0102da0:	56                   	push   %esi
f0102da1:	ff 35 8c 8e 21 f0    	pushl  0xf0218e8c
f0102da7:	e8 c1 e5 ff ff       	call   f010136d <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102dac:	83 c4 10             	add    $0x10,%esp
f0102daf:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102db6:	02 02 02 
f0102db9:	74 19                	je     f0102dd4 <mem_init+0x1940>
f0102dbb:	68 60 78 10 f0       	push   $0xf0107860
f0102dc0:	68 54 79 10 f0       	push   $0xf0107954
f0102dc5:	68 9c 04 00 00       	push   $0x49c
f0102dca:	68 11 79 10 f0       	push   $0xf0107911
f0102dcf:	e8 6c d2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102dd4:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102dd9:	74 19                	je     f0102df4 <mem_init+0x1960>
f0102ddb:	68 75 7b 10 f0       	push   $0xf0107b75
f0102de0:	68 54 79 10 f0       	push   $0xf0107954
f0102de5:	68 9d 04 00 00       	push   $0x49d
f0102dea:	68 11 79 10 f0       	push   $0xf0107911
f0102def:	e8 4c d2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102df4:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102df9:	74 19                	je     f0102e14 <mem_init+0x1980>
f0102dfb:	68 df 7b 10 f0       	push   $0xf0107bdf
f0102e00:	68 54 79 10 f0       	push   $0xf0107954
f0102e05:	68 9e 04 00 00       	push   $0x49e
f0102e0a:	68 11 79 10 f0       	push   $0xf0107911
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
f0102e20:	2b 05 90 8e 21 f0    	sub    0xf0218e90,%eax
f0102e26:	c1 f8 03             	sar    $0x3,%eax
f0102e29:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e2c:	89 c2                	mov    %eax,%edx
f0102e2e:	c1 ea 0c             	shr    $0xc,%edx
f0102e31:	3b 15 88 8e 21 f0    	cmp    0xf0218e88,%edx
f0102e37:	72 12                	jb     f0102e4b <mem_init+0x19b7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e39:	50                   	push   %eax
f0102e3a:	68 44 6a 10 f0       	push   $0xf0106a44
f0102e3f:	6a 58                	push   $0x58
f0102e41:	68 3a 79 10 f0       	push   $0xf010793a
f0102e46:	e8 f5 d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e4b:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102e52:	03 03 03 
f0102e55:	74 19                	je     f0102e70 <mem_init+0x19dc>
f0102e57:	68 84 78 10 f0       	push   $0xf0107884
f0102e5c:	68 54 79 10 f0       	push   $0xf0107954
f0102e61:	68 a0 04 00 00       	push   $0x4a0
f0102e66:	68 11 79 10 f0       	push   $0xf0107911
f0102e6b:	e8 d0 d1 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102e70:	83 ec 08             	sub    $0x8,%esp
f0102e73:	68 00 10 00 00       	push   $0x1000
f0102e78:	ff 35 8c 8e 21 f0    	pushl  0xf0218e8c
f0102e7e:	e8 7c e4 ff ff       	call   f01012ff <page_remove>
	assert(pp2->pp_ref == 0);
f0102e83:	83 c4 10             	add    $0x10,%esp
f0102e86:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102e8b:	74 19                	je     f0102ea6 <mem_init+0x1a12>
f0102e8d:	68 ad 7b 10 f0       	push   $0xf0107bad
f0102e92:	68 54 79 10 f0       	push   $0xf0107954
f0102e97:	68 a2 04 00 00       	push   $0x4a2
f0102e9c:	68 11 79 10 f0       	push   $0xf0107911
f0102ea1:	e8 9a d1 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102ea6:	8b 0d 8c 8e 21 f0    	mov    0xf0218e8c,%ecx
f0102eac:	8b 11                	mov    (%ecx),%edx
f0102eae:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102eb4:	89 d8                	mov    %ebx,%eax
f0102eb6:	2b 05 90 8e 21 f0    	sub    0xf0218e90,%eax
f0102ebc:	c1 f8 03             	sar    $0x3,%eax
f0102ebf:	c1 e0 0c             	shl    $0xc,%eax
f0102ec2:	39 c2                	cmp    %eax,%edx
f0102ec4:	74 19                	je     f0102edf <mem_init+0x1a4b>
f0102ec6:	68 0c 72 10 f0       	push   $0xf010720c
f0102ecb:	68 54 79 10 f0       	push   $0xf0107954
f0102ed0:	68 a5 04 00 00       	push   $0x4a5
f0102ed5:	68 11 79 10 f0       	push   $0xf0107911
f0102eda:	e8 61 d1 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102edf:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102ee5:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102eea:	74 19                	je     f0102f05 <mem_init+0x1a71>
f0102eec:	68 64 7b 10 f0       	push   $0xf0107b64
f0102ef1:	68 54 79 10 f0       	push   $0xf0107954
f0102ef6:	68 a7 04 00 00       	push   $0x4a7
f0102efb:	68 11 79 10 f0       	push   $0xf0107911
f0102f00:	e8 3b d1 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102f05:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102f0b:	83 ec 0c             	sub    $0xc,%esp
f0102f0e:	53                   	push   %ebx
f0102f0f:	e8 18 e1 ff ff       	call   f010102c <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102f14:	c7 04 24 b0 78 10 f0 	movl   $0xf01078b0,(%esp)
f0102f1b:	e8 48 0d 00 00       	call   f0103c68 <cprintf>
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
f0102f67:	ff b7 94 00 00 00    	pushl  0x94(%edi)
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
f0102fa2:	89 1d 3c 82 21 f0    	mov    %ebx,0xf021823c
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
f0102fd7:	79 21                	jns    f0102ffa <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102fd9:	83 ec 04             	sub    $0x4,%esp
f0102fdc:	ff 35 3c 82 21 f0    	pushl  0xf021823c
f0102fe2:	ff 73 7c             	pushl  0x7c(%ebx)
f0102fe5:	68 dc 78 10 f0       	push   $0xf01078dc
f0102fea:	e8 79 0c 00 00       	call   f0103c68 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102fef:	89 1c 24             	mov    %ebx,(%esp)
f0102ff2:	e8 6e 07 00 00       	call   f0103765 <env_destroy>
f0102ff7:	83 c4 10             	add    $0x10,%esp
	}
}
f0102ffa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102ffd:	c9                   	leave  
f0102ffe:	c3                   	ret    

f0102fff <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102fff:	55                   	push   %ebp
f0103000:	89 e5                	mov    %esp,%ebp
f0103002:	57                   	push   %edi
f0103003:	56                   	push   %esi
f0103004:	53                   	push   %ebx
f0103005:	83 ec 0c             	sub    $0xc,%esp
f0103008:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
        uintptr_t rva = (uintptr_t) ROUNDDOWN(va, PGSIZE);
f010300a:	89 d3                	mov    %edx,%ebx
f010300c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        uintptr_t rva_end = (uintptr_t) ROUNDUP(va + len, PGSIZE);
f0103012:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0103019:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi

        while (rva < rva_end) {
f010301f:	eb 5b                	jmp    f010307c <region_alloc+0x7d>
                struct PageInfo *page = page_alloc(0);
f0103021:	83 ec 0c             	sub    $0xc,%esp
f0103024:	6a 00                	push   $0x0
f0103026:	e8 91 df ff ff       	call   f0100fbc <page_alloc>
                if (page == NULL)
f010302b:	83 c4 10             	add    $0x10,%esp
f010302e:	85 c0                	test   %eax,%eax
f0103030:	75 17                	jne    f0103049 <region_alloc+0x4a>
                        panic("region_alloc: couldn't allocate page");
f0103032:	83 ec 04             	sub    $0x4,%esp
f0103035:	68 7c 7c 10 f0       	push   $0xf0107c7c
f010303a:	68 5f 01 00 00       	push   $0x15f
f010303f:	68 b1 7d 10 f0       	push   $0xf0107db1
f0103044:	e8 f7 cf ff ff       	call   f0100040 <_panic>

                if (page_insert(e->env_pgdir, page, (void *) rva, PTE_P | PTE_U | PTE_W) < 0)
f0103049:	6a 07                	push   $0x7
f010304b:	53                   	push   %ebx
f010304c:	50                   	push   %eax
f010304d:	ff b7 94 00 00 00    	pushl  0x94(%edi)
f0103053:	e8 15 e3 ff ff       	call   f010136d <page_insert>
f0103058:	83 c4 10             	add    $0x10,%esp
f010305b:	85 c0                	test   %eax,%eax
f010305d:	79 17                	jns    f0103076 <region_alloc+0x77>
                        panic("region_alloc: page couldn't be inserted");
f010305f:	83 ec 04             	sub    $0x4,%esp
f0103062:	68 a4 7c 10 f0       	push   $0xf0107ca4
f0103067:	68 62 01 00 00       	push   $0x162
f010306c:	68 b1 7d 10 f0       	push   $0xf0107db1
f0103071:	e8 ca cf ff ff       	call   f0100040 <_panic>

                rva += PGSIZE;
f0103076:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
        uintptr_t rva = (uintptr_t) ROUNDDOWN(va, PGSIZE);
        uintptr_t rva_end = (uintptr_t) ROUNDUP(va + len, PGSIZE);

        while (rva < rva_end) {
f010307c:	39 f3                	cmp    %esi,%ebx
f010307e:	72 a1                	jb     f0103021 <region_alloc+0x22>
                if (page_insert(e->env_pgdir, page, (void *) rva, PTE_P | PTE_U | PTE_W) < 0)
                        panic("region_alloc: page couldn't be inserted");

                rva += PGSIZE;
        }
}
f0103080:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103083:	5b                   	pop    %ebx
f0103084:	5e                   	pop    %esi
f0103085:	5f                   	pop    %edi
f0103086:	5d                   	pop    %ebp
f0103087:	c3                   	ret    

f0103088 <stack_push>:
struct FreeStacks* thread_free_stacks = NULL; //free stacks for threads
static struct FreeStacks* free_stacks_stack;


void stack_push(uint32_t id)
{	
f0103088:	55                   	push   %ebp
f0103089:	89 e5                	mov    %esp,%ebp
f010308b:	8b 45 08             	mov    0x8(%ebp),%eax
	thread_free_stacks[id].next_stack = free_stacks_stack;
f010308e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103091:	a1 48 82 21 f0       	mov    0xf0218248,%eax
f0103096:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103099:	8b 15 50 82 21 f0    	mov    0xf0218250,%edx
f010309f:	89 50 08             	mov    %edx,0x8(%eax)
        free_stacks_stack = &thread_free_stacks[id];
f01030a2:	a3 50 82 21 f0       	mov    %eax,0xf0218250
}
f01030a7:	5d                   	pop    %ebp
f01030a8:	c3                   	ret    

f01030a9 <stack_pop>:

struct FreeStacks* stack_pop()
{
f01030a9:	55                   	push   %ebp
f01030aa:	89 e5                	mov    %esp,%ebp
	struct FreeStacks* ret = free_stacks_stack;
f01030ac:	a1 50 82 21 f0       	mov    0xf0218250,%eax
	free_stacks_stack = free_stacks_stack->next_stack;
f01030b1:	8b 50 08             	mov    0x8(%eax),%edx
f01030b4:	89 15 50 82 21 f0    	mov    %edx,0xf0218250
	
	return ret;
}
f01030ba:	5d                   	pop    %ebp
f01030bb:	c3                   	ret    

f01030bc <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01030bc:	55                   	push   %ebp
f01030bd:	89 e5                	mov    %esp,%ebp
f01030bf:	56                   	push   %esi
f01030c0:	53                   	push   %ebx
f01030c1:	8b 45 08             	mov    0x8(%ebp),%eax
f01030c4:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f01030c7:	85 c0                	test   %eax,%eax
f01030c9:	75 1a                	jne    f01030e5 <envid2env+0x29>
		*env_store = curenv;
f01030cb:	e8 ba 32 00 00       	call   f010638a <cpunum>
f01030d0:	6b c0 74             	imul   $0x74,%eax,%eax
f01030d3:	8b 80 28 90 21 f0    	mov    -0xfde6fd8(%eax),%eax
f01030d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01030dc:	89 01                	mov    %eax,(%ecx)
		return 0;
f01030de:	b8 00 00 00 00       	mov    $0x0,%eax
f01030e3:	eb 79                	jmp    f010315e <envid2env+0xa2>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f01030e5:	89 c3                	mov    %eax,%ebx
f01030e7:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f01030ed:	69 db b0 00 00 00    	imul   $0xb0,%ebx,%ebx
f01030f3:	03 1d 4c 82 21 f0    	add    0xf021824c,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01030f9:	83 bb 88 00 00 00 00 	cmpl   $0x0,0x88(%ebx)
f0103100:	74 05                	je     f0103107 <envid2env+0x4b>
f0103102:	3b 43 7c             	cmp    0x7c(%ebx),%eax
f0103105:	74 10                	je     f0103117 <envid2env+0x5b>
		*env_store = 0;
f0103107:	8b 45 0c             	mov    0xc(%ebp),%eax
f010310a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103110:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103115:	eb 47                	jmp    f010315e <envid2env+0xa2>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103117:	84 d2                	test   %dl,%dl
f0103119:	74 39                	je     f0103154 <envid2env+0x98>
f010311b:	e8 6a 32 00 00       	call   f010638a <cpunum>
f0103120:	6b c0 74             	imul   $0x74,%eax,%eax
f0103123:	3b 98 28 90 21 f0    	cmp    -0xfde6fd8(%eax),%ebx
f0103129:	74 29                	je     f0103154 <envid2env+0x98>
f010312b:	8b b3 80 00 00 00    	mov    0x80(%ebx),%esi
f0103131:	e8 54 32 00 00       	call   f010638a <cpunum>
f0103136:	6b c0 74             	imul   $0x74,%eax,%eax
f0103139:	8b 80 28 90 21 f0    	mov    -0xfde6fd8(%eax),%eax
f010313f:	3b 70 7c             	cmp    0x7c(%eax),%esi
f0103142:	74 10                	je     f0103154 <envid2env+0x98>
		*env_store = 0;
f0103144:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103147:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010314d:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103152:	eb 0a                	jmp    f010315e <envid2env+0xa2>
	}

	*env_store = e;
f0103154:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103157:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103159:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010315e:	5b                   	pop    %ebx
f010315f:	5e                   	pop    %esi
f0103160:	5d                   	pop    %ebp
f0103161:	c3                   	ret    

f0103162 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103162:	55                   	push   %ebp
f0103163:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f0103165:	b8 20 23 12 f0       	mov    $0xf0122320,%eax
f010316a:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f010316d:	b8 23 00 00 00       	mov    $0x23,%eax
f0103172:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103174:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103176:	b8 10 00 00 00       	mov    $0x10,%eax
f010317b:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f010317d:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f010317f:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103181:	ea 88 31 10 f0 08 00 	ljmp   $0x8,$0xf0103188
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f0103188:	b8 00 00 00 00       	mov    $0x0,%eax
f010318d:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103190:	5d                   	pop    %ebp
f0103191:	c3                   	ret    

f0103192 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103192:	55                   	push   %ebp
f0103193:	89 e5                	mov    %esp,%ebp
f0103195:	56                   	push   %esi
f0103196:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
        int i;
        for (i = NENV - 1; i >= 0; i--) {
                envs[i].env_status = ENV_FREE;
f0103197:	8b 35 4c 82 21 f0    	mov    0xf021824c,%esi
f010319d:	8b 15 54 82 21 f0    	mov    0xf0218254,%edx
f01031a3:	8d 86 50 bf 02 00    	lea    0x2bf50(%esi),%eax
f01031a9:	8d 9e 50 ff ff ff    	lea    -0xb0(%esi),%ebx
f01031af:	89 c1                	mov    %eax,%ecx
f01031b1:	c7 80 88 00 00 00 00 	movl   $0x0,0x88(%eax)
f01031b8:	00 00 00 
                envs[i].env_id = 0;
f01031bb:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
                envs[i].env_link = env_free_list;
f01031c2:	89 50 78             	mov    %edx,0x78(%eax)
f01031c5:	2d b0 00 00 00       	sub    $0xb0,%eax
                env_free_list = &envs[i];
f01031ca:	89 ca                	mov    %ecx,%edx
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
        int i;
        for (i = NENV - 1; i >= 0; i--) {
f01031cc:	39 d8                	cmp    %ebx,%eax
f01031ce:	75 df                	jne    f01031af <env_init+0x1d>
f01031d0:	89 35 54 82 21 f0    	mov    %esi,0xf0218254
f01031d6:	8b 1d 50 82 21 f0    	mov    0xf0218250,%ebx
f01031dc:	b9 00 d0 bf ee       	mov    $0xeebfd000,%ecx
f01031e1:	b8 fe 03 00 00       	mov    $0x3fe,%eax
f01031e6:	8d 14 40             	lea    (%eax,%eax,2),%edx
	uintptr_t THRDSTACKTOP = ustacktop - THRDSTKGAP;
	uintptr_t STACKADDR = THRDSTACKTOP;

	for (i = MAX_THREADS - 1; i >= 0 ; i--, STACKADDR -= (THRDSTKSIZE + THRDSTKGAP))
	{	
		thread_free_stacks[i].id = i;
f01031e9:	8b 35 48 82 21 f0    	mov    0xf0218248,%esi
f01031ef:	89 04 96             	mov    %eax,(%esi,%edx,4)
		thread_free_stacks[i].addr = STACKADDR;
f01031f2:	8b 35 48 82 21 f0    	mov    0xf0218248,%esi
f01031f8:	8d 14 96             	lea    (%esi,%edx,4),%edx
f01031fb:	89 4a 04             	mov    %ecx,0x4(%edx)
		thread_free_stacks[i].next_stack = free_stacks_stack;
f01031fe:	89 5a 08             	mov    %ebx,0x8(%edx)
	/*Lab 7: multithreading*/
	uintptr_t ustacktop = 0xeebfe000;
	uintptr_t THRDSTACKTOP = ustacktop - THRDSTKGAP;
	uintptr_t STACKADDR = THRDSTACKTOP;

	for (i = MAX_THREADS - 1; i >= 0 ; i--, STACKADDR -= (THRDSTKSIZE + THRDSTKGAP))
f0103201:	83 e8 01             	sub    $0x1,%eax
f0103204:	81 e9 00 20 00 00    	sub    $0x2000,%ecx
	{	
		thread_free_stacks[i].id = i;
		thread_free_stacks[i].addr = STACKADDR;
		thread_free_stacks[i].next_stack = free_stacks_stack;
                free_stacks_stack = &thread_free_stacks[i];
f010320a:	89 d3                	mov    %edx,%ebx
	/*Lab 7: multithreading*/
	uintptr_t ustacktop = 0xeebfe000;
	uintptr_t THRDSTACKTOP = ustacktop - THRDSTKGAP;
	uintptr_t STACKADDR = THRDSTACKTOP;

	for (i = MAX_THREADS - 1; i >= 0 ; i--, STACKADDR -= (THRDSTKSIZE + THRDSTKGAP))
f010320c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010320f:	75 d5                	jne    f01031e6 <env_init+0x54>
f0103211:	89 15 50 82 21 f0    	mov    %edx,0xf0218250
		thread_free_stacks[i].addr = STACKADDR;
		thread_free_stacks[i].next_stack = free_stacks_stack;
                free_stacks_stack = &thread_free_stacks[i];
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f0103217:	e8 46 ff ff ff       	call   f0103162 <env_init_percpu>
}
f010321c:	5b                   	pop    %ebx
f010321d:	5e                   	pop    %esi
f010321e:	5d                   	pop    %ebp
f010321f:	c3                   	ret    

f0103220 <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103220:	55                   	push   %ebp
f0103221:	89 e5                	mov    %esp,%ebp
f0103223:	57                   	push   %edi
f0103224:	56                   	push   %esi
f0103225:	53                   	push   %ebx
f0103226:	83 ec 0c             	sub    $0xc,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103229:	8b 1d 54 82 21 f0    	mov    0xf0218254,%ebx
f010322f:	85 db                	test   %ebx,%ebx
f0103231:	0f 84 ba 01 00 00    	je     f01033f1 <env_alloc+0x1d1>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103237:	83 ec 0c             	sub    $0xc,%esp
f010323a:	6a 01                	push   $0x1
f010323c:	e8 7b dd ff ff       	call   f0100fbc <page_alloc>
f0103241:	83 c4 10             	add    $0x10,%esp
f0103244:	85 c0                	test   %eax,%eax
f0103246:	0f 84 ac 01 00 00    	je     f01033f8 <env_alloc+0x1d8>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010324c:	89 c2                	mov    %eax,%edx
f010324e:	2b 15 90 8e 21 f0    	sub    0xf0218e90,%edx
f0103254:	c1 fa 03             	sar    $0x3,%edx
f0103257:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010325a:	89 d1                	mov    %edx,%ecx
f010325c:	c1 e9 0c             	shr    $0xc,%ecx
f010325f:	3b 0d 88 8e 21 f0    	cmp    0xf0218e88,%ecx
f0103265:	72 12                	jb     f0103279 <env_alloc+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103267:	52                   	push   %edx
f0103268:	68 44 6a 10 f0       	push   $0xf0106a44
f010326d:	6a 58                	push   $0x58
f010326f:	68 3a 79 10 f0       	push   $0xf010793a
f0103274:	e8 c7 cd ff ff       	call   f0100040 <_panic>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
        e->env_pgdir = (pde_t *) page2kva(p);
f0103279:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010327f:	89 93 94 00 00 00    	mov    %edx,0x94(%ebx)
        p->pp_ref++;
f0103285:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f010328a:	b8 00 00 00 00       	mov    $0x0,%eax

        for (i = 0; i < PDX(UTOP); i++)
                e->env_pgdir[i] = 0;
f010328f:	8b 93 94 00 00 00    	mov    0x94(%ebx),%edx
f0103295:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
f010329c:	83 c0 04             	add    $0x4,%eax

	// LAB 3: Your code here.
        e->env_pgdir = (pde_t *) page2kva(p);
        p->pp_ref++;

        for (i = 0; i < PDX(UTOP); i++)
f010329f:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01032a4:	75 e9                	jne    f010328f <env_alloc+0x6f>
                e->env_pgdir[i] = 0;

        for (i = PDX(UTOP); i < NPDENTRIES; i++)
                e->env_pgdir[i] = kern_pgdir[i];
f01032a6:	8b 15 8c 8e 21 f0    	mov    0xf0218e8c,%edx
f01032ac:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f01032af:	8b 93 94 00 00 00    	mov    0x94(%ebx),%edx
f01032b5:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f01032b8:	83 c0 04             	add    $0x4,%eax
        p->pp_ref++;

        for (i = 0; i < PDX(UTOP); i++)
                e->env_pgdir[i] = 0;

        for (i = PDX(UTOP); i < NPDENTRIES; i++)
f01032bb:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01032c0:	75 e4                	jne    f01032a6 <env_alloc+0x86>
                e->env_pgdir[i] = kern_pgdir[i];

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01032c2:	8b 83 94 00 00 00    	mov    0x94(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032c8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032cd:	77 15                	ja     f01032e4 <env_alloc+0xc4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032cf:	50                   	push   %eax
f01032d0:	68 68 6a 10 f0       	push   $0xf0106a68
f01032d5:	68 ef 00 00 00       	push   $0xef
f01032da:	68 b1 7d 10 f0       	push   $0xf0107db1
f01032df:	e8 5c cd ff ff       	call   f0100040 <_panic>
f01032e4:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01032ea:	83 ca 05             	or     $0x5,%edx
f01032ed:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01032f3:	8b 43 7c             	mov    0x7c(%ebx),%eax
f01032f6:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01032fb:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103300:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103305:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103308:	89 da                	mov    %ebx,%edx
f010330a:	2b 15 4c 82 21 f0    	sub    0xf021824c,%edx
f0103310:	c1 fa 04             	sar    $0x4,%edx
f0103313:	69 d2 a3 8b 2e ba    	imul   $0xba2e8ba3,%edx,%edx
f0103319:	09 d0                	or     %edx,%eax
f010331b:	89 43 7c             	mov    %eax,0x7c(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f010331e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103321:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103327:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
f010332e:	00 00 00 
	e->env_status = ENV_RUNNABLE;
f0103331:	c7 83 88 00 00 00 02 	movl   $0x2,0x88(%ebx)
f0103338:	00 00 00 
	e->env_runs = 0;
f010333b:	c7 83 8c 00 00 00 00 	movl   $0x0,0x8c(%ebx)
f0103342:	00 00 00 

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103345:	83 ec 04             	sub    $0x4,%esp
f0103348:	6a 44                	push   $0x44
f010334a:	6a 00                	push   $0x0
f010334c:	8d 73 34             	lea    0x34(%ebx),%esi
f010334f:	56                   	push   %esi
f0103350:	e8 15 2a 00 00       	call   f0105d6a <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103355:	66 c7 43 58 23 00    	movw   $0x23,0x58(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010335b:	66 c7 43 54 23 00    	movw   $0x23,0x54(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103361:	66 c7 43 74 23 00    	movw   $0x23,0x74(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103367:	c7 43 70 00 e0 bf ee 	movl   $0xeebfe000,0x70(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010336e:	66 c7 43 68 1b 00    	movw   $0x1b,0x68(%ebx)
	// You will set e->env_tf.tf_eip later.
	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
        e->env_tf.tf_eflags |= FL_IF;
f0103374:	81 4b 6c 00 02 00 00 	orl    $0x200,0x6c(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f010337b:	c7 83 98 00 00 00 00 	movl   $0x0,0x98(%ebx)
f0103382:	00 00 00 

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103385:	c6 83 9c 00 00 00 00 	movb   $0x0,0x9c(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f010338c:	8b 43 78             	mov    0x78(%ebx),%eax
f010338f:	a3 54 82 21 f0       	mov    %eax,0xf0218254
	*newenv_store = e;
f0103394:	8b 45 08             	mov    0x8(%ebp),%eax
f0103397:	89 18                	mov    %ebx,(%eax)

	// Lab 7 multithreading
	// nastavme proces id ako env id, ak sa alokuje thread, prestavi si process id sam
	// zoznam workerov nastavime ako prazdny
	e->env_process_id = e->env_id;
f0103399:	8b 7b 7c             	mov    0x7c(%ebx),%edi
f010339c:	89 3b                	mov    %edi,(%ebx)
f010339e:	83 c3 0c             	add    $0xc,%ebx
f01033a1:	83 c4 10             	add    $0x10,%esp
	int i;
	for(i = 0; i < MAX_PROCESS_THREADS; i++)
	{
		e->worker_threads[i] = 0;		
f01033a4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
f01033aa:	83 c3 04             	add    $0x4,%ebx
	// Lab 7 multithreading
	// nastavme proces id ako env id, ak sa alokuje thread, prestavi si process id sam
	// zoznam workerov nastavime ako prazdny
	e->env_process_id = e->env_id;
	int i;
	for(i = 0; i < MAX_PROCESS_THREADS; i++)
f01033ad:	39 de                	cmp    %ebx,%esi
f01033af:	75 f3                	jne    f01033a4 <env_alloc+0x184>
		e->worker_threads[i] = 0;		
	}
	


	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01033b1:	e8 d4 2f 00 00       	call   f010638a <cpunum>
f01033b6:	6b c0 74             	imul   $0x74,%eax,%eax
f01033b9:	ba 00 00 00 00       	mov    $0x0,%edx
f01033be:	83 b8 28 90 21 f0 00 	cmpl   $0x0,-0xfde6fd8(%eax)
f01033c5:	74 11                	je     f01033d8 <env_alloc+0x1b8>
f01033c7:	e8 be 2f 00 00       	call   f010638a <cpunum>
f01033cc:	6b c0 74             	imul   $0x74,%eax,%eax
f01033cf:	8b 80 28 90 21 f0    	mov    -0xfde6fd8(%eax),%eax
f01033d5:	8b 50 7c             	mov    0x7c(%eax),%edx
f01033d8:	83 ec 04             	sub    $0x4,%esp
f01033db:	57                   	push   %edi
f01033dc:	52                   	push   %edx
f01033dd:	68 bc 7d 10 f0       	push   $0xf0107dbc
f01033e2:	e8 81 08 00 00       	call   f0103c68 <cprintf>
	return 0;
f01033e7:	83 c4 10             	add    $0x10,%esp
f01033ea:	b8 00 00 00 00       	mov    $0x0,%eax
f01033ef:	eb 0c                	jmp    f01033fd <env_alloc+0x1dd>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f01033f1:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01033f6:	eb 05                	jmp    f01033fd <env_alloc+0x1dd>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f01033f8:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	


	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01033fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103400:	5b                   	pop    %ebx
f0103401:	5e                   	pop    %esi
f0103402:	5f                   	pop    %edi
f0103403:	5d                   	pop    %ebp
f0103404:	c3                   	ret    

f0103405 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103405:	55                   	push   %ebp
f0103406:	89 e5                	mov    %esp,%ebp
f0103408:	57                   	push   %edi
f0103409:	56                   	push   %esi
f010340a:	53                   	push   %ebx
f010340b:	83 ec 34             	sub    $0x34,%esp
f010340e:	8b 75 08             	mov    0x8(%ebp),%esi
f0103411:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// LAB 3: Your code here.
        struct Env *env;
        int status = env_alloc(&env, 0);
f0103414:	6a 00                	push   $0x0
f0103416:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103419:	50                   	push   %eax
f010341a:	e8 01 fe ff ff       	call   f0103220 <env_alloc>
        if (status < 0)
f010341f:	83 c4 10             	add    $0x10,%esp
f0103422:	85 c0                	test   %eax,%eax
f0103424:	79 15                	jns    f010343b <env_create+0x36>
                panic("env_alloc: %e", status);
f0103426:	50                   	push   %eax
f0103427:	68 d1 7d 10 f0       	push   $0xf0107dd1
f010342c:	68 cc 01 00 00       	push   $0x1cc
f0103431:	68 b1 7d 10 f0       	push   $0xf0107db1
f0103436:	e8 05 cc ff ff       	call   f0100040 <_panic>

        // If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.        
        if (type == ENV_TYPE_FS) {
f010343b:	83 fb 01             	cmp    $0x1,%ebx
f010343e:	75 0a                	jne    f010344a <env_create+0x45>
                env->env_tf.tf_eflags |= FL_IOPL_3;
f0103440:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103443:	81 48 6c 00 30 00 00 	orl    $0x3000,0x6c(%eax)
        }

        env->env_type = type;
f010344a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010344d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103450:	89 98 84 00 00 00    	mov    %ebx,0x84(%eax)
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
        struct Elf *elf = (struct Elf *) binary;
        
        if (elf->e_magic != ELF_MAGIC)
f0103456:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f010345c:	74 17                	je     f0103475 <env_create+0x70>
                panic("load_icode: binary isn't elf (invalid magic)");
f010345e:	83 ec 04             	sub    $0x4,%esp
f0103461:	68 cc 7c 10 f0       	push   $0xf0107ccc
f0103466:	68 a1 01 00 00       	push   $0x1a1
f010346b:	68 b1 7d 10 f0       	push   $0xf0107db1
f0103470:	e8 cb cb ff ff       	call   f0100040 <_panic>
       
        // We could do a bunch more checks here (for e_phnum and such) but let's not.

        struct Proghdr *pht = (struct Proghdr *) (binary + elf->e_phoff); 
f0103475:	89 f7                	mov    %esi,%edi
f0103477:	03 7e 1c             	add    0x1c(%esi),%edi
     
        lcr3(PADDR(e->env_pgdir));
f010347a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010347d:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103483:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103488:	77 15                	ja     f010349f <env_create+0x9a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010348a:	50                   	push   %eax
f010348b:	68 68 6a 10 f0       	push   $0xf0106a68
f0103490:	68 a7 01 00 00       	push   $0x1a7
f0103495:	68 b1 7d 10 f0       	push   $0xf0107db1
f010349a:	e8 a1 cb ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010349f:	05 00 00 00 10       	add    $0x10000000,%eax
f01034a4:	0f 22 d8             	mov    %eax,%cr3

        struct Proghdr *phdr;
        for (phdr = pht; phdr < pht + elf->e_phnum; phdr++) {
f01034a7:	89 fb                	mov    %edi,%ebx
f01034a9:	eb 60                	jmp    f010350b <env_create+0x106>
                if (phdr->p_type != ELF_PROG_LOAD)
f01034ab:	83 3b 01             	cmpl   $0x1,(%ebx)
f01034ae:	75 58                	jne    f0103508 <env_create+0x103>
                        continue;

                if (phdr->p_filesz > phdr->p_memsz)
f01034b0:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01034b3:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f01034b6:	76 17                	jbe    f01034cf <env_create+0xca>
                        panic("load_icode: segment filesz > memsz");
f01034b8:	83 ec 04             	sub    $0x4,%esp
f01034bb:	68 fc 7c 10 f0       	push   $0xf0107cfc
f01034c0:	68 af 01 00 00       	push   $0x1af
f01034c5:	68 b1 7d 10 f0       	push   $0xf0107db1
f01034ca:	e8 71 cb ff ff       	call   f0100040 <_panic>

                region_alloc(e, (void *) phdr->p_va, phdr->p_memsz);
f01034cf:	8b 53 08             	mov    0x8(%ebx),%edx
f01034d2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01034d5:	e8 25 fb ff ff       	call   f0102fff <region_alloc>
                memcpy((void *) phdr->p_va, binary + phdr->p_offset, phdr->p_filesz); 
f01034da:	83 ec 04             	sub    $0x4,%esp
f01034dd:	ff 73 10             	pushl  0x10(%ebx)
f01034e0:	89 f0                	mov    %esi,%eax
f01034e2:	03 43 04             	add    0x4(%ebx),%eax
f01034e5:	50                   	push   %eax
f01034e6:	ff 73 08             	pushl  0x8(%ebx)
f01034e9:	e8 31 29 00 00       	call   f0105e1f <memcpy>
                memset((void *) (phdr->p_va + phdr->p_filesz), 0, phdr->p_memsz - phdr->p_filesz);
f01034ee:	8b 43 10             	mov    0x10(%ebx),%eax
f01034f1:	83 c4 0c             	add    $0xc,%esp
f01034f4:	8b 53 14             	mov    0x14(%ebx),%edx
f01034f7:	29 c2                	sub    %eax,%edx
f01034f9:	52                   	push   %edx
f01034fa:	6a 00                	push   $0x0
f01034fc:	03 43 08             	add    0x8(%ebx),%eax
f01034ff:	50                   	push   %eax
f0103500:	e8 65 28 00 00       	call   f0105d6a <memset>
f0103505:	83 c4 10             	add    $0x10,%esp
        struct Proghdr *pht = (struct Proghdr *) (binary + elf->e_phoff); 
     
        lcr3(PADDR(e->env_pgdir));

        struct Proghdr *phdr;
        for (phdr = pht; phdr < pht + elf->e_phnum; phdr++) {
f0103508:	83 c3 20             	add    $0x20,%ebx
f010350b:	0f b7 46 2c          	movzwl 0x2c(%esi),%eax
f010350f:	c1 e0 05             	shl    $0x5,%eax
f0103512:	01 f8                	add    %edi,%eax
f0103514:	39 c3                	cmp    %eax,%ebx
f0103516:	72 93                	jb     f01034ab <env_create+0xa6>
                memset((void *) (phdr->p_va + phdr->p_filesz), 0, phdr->p_memsz - phdr->p_filesz);
        }

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
        region_alloc(e, (void *) (USTACKTOP - PGSIZE), PGSIZE);
f0103518:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010351d:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103522:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103525:	89 f8                	mov    %edi,%eax
f0103527:	e8 d3 fa ff ff       	call   f0102fff <region_alloc>

	// LAB 3: Your code here.
        e->env_tf.tf_eip = elf->e_entry;
f010352c:	8b 46 18             	mov    0x18(%esi),%eax
f010352f:	89 47 64             	mov    %eax,0x64(%edi)
                env->env_tf.tf_eflags |= FL_IOPL_3;
        }

        env->env_type = type;
        load_icode(env, binary);
}
f0103532:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103535:	5b                   	pop    %ebx
f0103536:	5e                   	pop    %esi
f0103537:	5f                   	pop    %edi
f0103538:	5d                   	pop    %ebp
f0103539:	c3                   	ret    

f010353a <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010353a:	55                   	push   %ebp
f010353b:	89 e5                	mov    %esp,%ebp
f010353d:	57                   	push   %edi
f010353e:	56                   	push   %esi
f010353f:	53                   	push   %ebx
f0103540:	83 ec 1c             	sub    $0x1c,%esp
f0103543:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103546:	e8 3f 2e 00 00       	call   f010638a <cpunum>
f010354b:	6b c0 74             	imul   $0x74,%eax,%eax
f010354e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103555:	39 b8 28 90 21 f0    	cmp    %edi,-0xfde6fd8(%eax)
f010355b:	75 30                	jne    f010358d <env_free+0x53>
		lcr3(PADDR(kern_pgdir));
f010355d:	a1 8c 8e 21 f0       	mov    0xf0218e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103562:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103567:	77 15                	ja     f010357e <env_free+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103569:	50                   	push   %eax
f010356a:	68 68 6a 10 f0       	push   $0xf0106a68
f010356f:	68 e6 01 00 00       	push   $0x1e6
f0103574:	68 b1 7d 10 f0       	push   $0xf0107db1
f0103579:	e8 c2 ca ff ff       	call   f0100040 <_panic>
f010357e:	05 00 00 00 10       	add    $0x10000000,%eax
f0103583:	0f 22 d8             	mov    %eax,%cr3
f0103586:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010358d:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103590:	89 d0                	mov    %edx,%eax
f0103592:	c1 e0 02             	shl    $0x2,%eax
f0103595:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103598:	8b 87 94 00 00 00    	mov    0x94(%edi),%eax
f010359e:	8b 34 90             	mov    (%eax,%edx,4),%esi
f01035a1:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01035a7:	0f 84 ae 00 00 00    	je     f010365b <env_free+0x121>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01035ad:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01035b3:	89 f0                	mov    %esi,%eax
f01035b5:	c1 e8 0c             	shr    $0xc,%eax
f01035b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01035bb:	39 05 88 8e 21 f0    	cmp    %eax,0xf0218e88
f01035c1:	77 15                	ja     f01035d8 <env_free+0x9e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01035c3:	56                   	push   %esi
f01035c4:	68 44 6a 10 f0       	push   $0xf0106a44
f01035c9:	68 f5 01 00 00       	push   $0x1f5
f01035ce:	68 b1 7d 10 f0       	push   $0xf0107db1
f01035d3:	e8 68 ca ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01035d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01035db:	c1 e0 16             	shl    $0x16,%eax
f01035de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01035e1:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01035e6:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01035ed:	01 
f01035ee:	74 1a                	je     f010360a <env_free+0xd0>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01035f0:	83 ec 08             	sub    $0x8,%esp
f01035f3:	89 d8                	mov    %ebx,%eax
f01035f5:	c1 e0 0c             	shl    $0xc,%eax
f01035f8:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01035fb:	50                   	push   %eax
f01035fc:	ff b7 94 00 00 00    	pushl  0x94(%edi)
f0103602:	e8 f8 dc ff ff       	call   f01012ff <page_remove>
f0103607:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010360a:	83 c3 01             	add    $0x1,%ebx
f010360d:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103613:	75 d1                	jne    f01035e6 <env_free+0xac>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103615:	8b 87 94 00 00 00    	mov    0x94(%edi),%eax
f010361b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010361e:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103625:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103628:	3b 05 88 8e 21 f0    	cmp    0xf0218e88,%eax
f010362e:	72 14                	jb     f0103644 <env_free+0x10a>
		panic("pa2page called with invalid pa");
f0103630:	83 ec 04             	sub    $0x4,%esp
f0103633:	68 b0 70 10 f0       	push   $0xf01070b0
f0103638:	6a 51                	push   $0x51
f010363a:	68 3a 79 10 f0       	push   $0xf010793a
f010363f:	e8 fc c9 ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f0103644:	83 ec 0c             	sub    $0xc,%esp
f0103647:	a1 90 8e 21 f0       	mov    0xf0218e90,%eax
f010364c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010364f:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103652:	50                   	push   %eax
f0103653:	e8 43 da ff ff       	call   f010109b <page_decref>
f0103658:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010365b:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f010365f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103662:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0103667:	0f 85 20 ff ff ff    	jne    f010358d <env_free+0x53>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010366d:	8b 87 94 00 00 00    	mov    0x94(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103673:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103678:	77 15                	ja     f010368f <env_free+0x155>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010367a:	50                   	push   %eax
f010367b:	68 68 6a 10 f0       	push   $0xf0106a68
f0103680:	68 03 02 00 00       	push   $0x203
f0103685:	68 b1 7d 10 f0       	push   $0xf0107db1
f010368a:	e8 b1 c9 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f010368f:	c7 87 94 00 00 00 00 	movl   $0x0,0x94(%edi)
f0103696:	00 00 00 
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103699:	05 00 00 00 10       	add    $0x10000000,%eax
f010369e:	c1 e8 0c             	shr    $0xc,%eax
f01036a1:	3b 05 88 8e 21 f0    	cmp    0xf0218e88,%eax
f01036a7:	72 14                	jb     f01036bd <env_free+0x183>
		panic("pa2page called with invalid pa");
f01036a9:	83 ec 04             	sub    $0x4,%esp
f01036ac:	68 b0 70 10 f0       	push   $0xf01070b0
f01036b1:	6a 51                	push   $0x51
f01036b3:	68 3a 79 10 f0       	push   $0xf010793a
f01036b8:	e8 83 c9 ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f01036bd:	83 ec 0c             	sub    $0xc,%esp
f01036c0:	8b 15 90 8e 21 f0    	mov    0xf0218e90,%edx
f01036c6:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01036c9:	50                   	push   %eax
f01036ca:	e8 cc d9 ff ff       	call   f010109b <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01036cf:	c7 87 88 00 00 00 00 	movl   $0x0,0x88(%edi)
f01036d6:	00 00 00 
	e->env_link = env_free_list;
f01036d9:	a1 54 82 21 f0       	mov    0xf0218254,%eax
f01036de:	89 47 78             	mov    %eax,0x78(%edi)
	env_free_list = e;
f01036e1:	89 3d 54 82 21 f0    	mov    %edi,0xf0218254
}
f01036e7:	83 c4 10             	add    $0x10,%esp
f01036ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01036ed:	5b                   	pop    %ebx
f01036ee:	5e                   	pop    %esi
f01036ef:	5f                   	pop    %edi
f01036f0:	5d                   	pop    %ebp
f01036f1:	c3                   	ret    

f01036f2 <thread_destroy>:
// pouzivane env_destroyom pre nicenie vsetkych worker threadov
// narozdiel od thread free neprechadza po poli v main threade a nenuluje pole wokrer
// threadov (je to zbytocne, kedze main thread sa ide znicit)
void
thread_destroy(struct Env *e)
{
f01036f2:	55                   	push   %ebp
f01036f3:	89 e5                	mov    %esp,%ebp
f01036f5:	53                   	push   %ebx
f01036f6:	83 ec 0c             	sub    $0xc,%esp
f01036f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("In thread destroy, thread: %d\n", e->env_id); 
f01036fc:	ff 73 7c             	pushl  0x7c(%ebx)
f01036ff:	68 20 7d 10 f0       	push   $0xf0107d20
f0103704:	e8 5f 05 00 00       	call   f0103c68 <cprintf>
	// hod jej esp adresu na zoznam volnych stackov pre thready
	stack_push(e->env_stack_id);
f0103709:	83 c4 04             	add    $0x4,%esp
f010370c:	ff 73 04             	pushl  0x4(%ebx)
f010370f:	e8 74 f9 ff ff       	call   f0103088 <stack_push>
	
	e->env_pgdir = 0;
f0103714:	c7 83 94 00 00 00 00 	movl   $0x0,0x94(%ebx)
f010371b:	00 00 00 
	e->env_status = ENV_FREE;
f010371e:	c7 83 88 00 00 00 00 	movl   $0x0,0x88(%ebx)
f0103725:	00 00 00 
	e->env_link = env_free_list;
f0103728:	a1 54 82 21 f0       	mov    0xf0218254,%eax
f010372d:	89 43 78             	mov    %eax,0x78(%ebx)
	env_free_list = e;
f0103730:	89 1d 54 82 21 f0    	mov    %ebx,0xf0218254

	if (curenv == e) {
f0103736:	e8 4f 2c 00 00       	call   f010638a <cpunum>
f010373b:	6b c0 74             	imul   $0x74,%eax,%eax
f010373e:	83 c4 10             	add    $0x10,%esp
f0103741:	3b 98 28 90 21 f0    	cmp    -0xfde6fd8(%eax),%ebx
f0103747:	75 17                	jne    f0103760 <thread_destroy+0x6e>
		curenv = NULL;
f0103749:	e8 3c 2c 00 00       	call   f010638a <cpunum>
f010374e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103751:	c7 80 28 90 21 f0 00 	movl   $0x0,-0xfde6fd8(%eax)
f0103758:	00 00 00 
		sched_yield();
f010375b:	e8 82 13 00 00       	call   f0104ae2 <sched_yield>
	}
}
f0103760:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103763:	c9                   	leave  
f0103764:	c3                   	ret    

f0103765 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103765:	55                   	push   %ebp
f0103766:	89 e5                	mov    %esp,%ebp
f0103768:	57                   	push   %edi
f0103769:	56                   	push   %esi
f010376a:	53                   	push   %ebx
f010376b:	83 ec 0c             	sub    $0xc,%esp
f010376e:	8b 7d 08             	mov    0x8(%ebp),%edi
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103771:	83 bf 88 00 00 00 03 	cmpl   $0x3,0x88(%edi)
f0103778:	75 1c                	jne    f0103796 <env_destroy+0x31>
f010377a:	e8 0b 2c 00 00       	call   f010638a <cpunum>
f010377f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103782:	3b b8 28 90 21 f0    	cmp    -0xfde6fd8(%eax),%edi
f0103788:	74 0c                	je     f0103796 <env_destroy+0x31>
		e->env_status = ENV_DYING;
f010378a:	c7 87 88 00 00 00 01 	movl   $0x1,0x88(%edi)
f0103791:	00 00 00 
		return;
f0103794:	eb 76                	jmp    f010380c <env_destroy+0xa7>
	}
	cprintf("In env destroy, destroying env: %d\n", e->env_id); // for testing purposes
f0103796:	83 ec 08             	sub    $0x8,%esp
f0103799:	ff 77 7c             	pushl  0x7c(%edi)
f010379c:	68 40 7d 10 f0       	push   $0xf0107d40
f01037a1:	e8 c2 04 00 00       	call   f0103c68 <cprintf>
f01037a6:	8d 5f 0c             	lea    0xc(%edi),%ebx
f01037a9:	8d 77 34             	lea    0x34(%edi),%esi
f01037ac:	83 c4 10             	add    $0x10,%esp
	/*prejdi cez pole worker threadov a znic ich*/
	int i;
	for(i = 0; i < MAX_PROCESS_THREADS; i++)
	{
		if(e->worker_threads[i] != 0) {
f01037af:	8b 03                	mov    (%ebx),%eax
f01037b1:	85 c0                	test   %eax,%eax
f01037b3:	74 1d                	je     f01037d2 <env_destroy+0x6d>
			thread_destroy(&envs[ENVX(e->worker_threads[i])]);	
f01037b5:	83 ec 0c             	sub    $0xc,%esp
f01037b8:	25 ff 03 00 00       	and    $0x3ff,%eax
f01037bd:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
f01037c3:	03 05 4c 82 21 f0    	add    0xf021824c,%eax
f01037c9:	50                   	push   %eax
f01037ca:	e8 23 ff ff ff       	call   f01036f2 <thread_destroy>
f01037cf:	83 c4 10             	add    $0x10,%esp
f01037d2:	83 c3 04             	add    $0x4,%ebx
		return;
	}
	cprintf("In env destroy, destroying env: %d\n", e->env_id); // for testing purposes
	/*prejdi cez pole worker threadov a znic ich*/
	int i;
	for(i = 0; i < MAX_PROCESS_THREADS; i++)
f01037d5:	39 f3                	cmp    %esi,%ebx
f01037d7:	75 d6                	jne    f01037af <env_destroy+0x4a>
		if(e->worker_threads[i] != 0) {
			thread_destroy(&envs[ENVX(e->worker_threads[i])]);	
		}
	}
	// znic main thread
	env_free(e);
f01037d9:	83 ec 0c             	sub    $0xc,%esp
f01037dc:	57                   	push   %edi
f01037dd:	e8 58 fd ff ff       	call   f010353a <env_free>

	if (curenv == e) {
f01037e2:	e8 a3 2b 00 00       	call   f010638a <cpunum>
f01037e7:	6b c0 74             	imul   $0x74,%eax,%eax
f01037ea:	83 c4 10             	add    $0x10,%esp
f01037ed:	3b b8 28 90 21 f0    	cmp    -0xfde6fd8(%eax),%edi
f01037f3:	75 17                	jne    f010380c <env_destroy+0xa7>
		curenv = NULL;
f01037f5:	e8 90 2b 00 00       	call   f010638a <cpunum>
f01037fa:	6b c0 74             	imul   $0x74,%eax,%eax
f01037fd:	c7 80 28 90 21 f0 00 	movl   $0x0,-0xfde6fd8(%eax)
f0103804:	00 00 00 
		sched_yield();
f0103807:	e8 d6 12 00 00       	call   f0104ae2 <sched_yield>
	}
}
f010380c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010380f:	5b                   	pop    %ebx
f0103810:	5e                   	pop    %esi
f0103811:	5f                   	pop    %edi
f0103812:	5d                   	pop    %ebp
f0103813:	c3                   	ret    

f0103814 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103814:	55                   	push   %ebp
f0103815:	89 e5                	mov    %esp,%ebp
f0103817:	53                   	push   %ebx
f0103818:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f010381b:	e8 6a 2b 00 00       	call   f010638a <cpunum>
f0103820:	6b c0 74             	imul   $0x74,%eax,%eax
f0103823:	8b 98 28 90 21 f0    	mov    -0xfde6fd8(%eax),%ebx
f0103829:	e8 5c 2b 00 00       	call   f010638a <cpunum>
f010382e:	89 83 90 00 00 00    	mov    %eax,0x90(%ebx)

	asm volatile(
f0103834:	8b 65 08             	mov    0x8(%ebp),%esp
f0103837:	61                   	popa   
f0103838:	07                   	pop    %es
f0103839:	1f                   	pop    %ds
f010383a:	83 c4 08             	add    $0x8,%esp
f010383d:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f010383e:	83 ec 04             	sub    $0x4,%esp
f0103841:	68 df 7d 10 f0       	push   $0xf0107ddf
f0103846:	68 59 02 00 00       	push   $0x259
f010384b:	68 b1 7d 10 f0       	push   $0xf0107db1
f0103850:	e8 eb c7 ff ff       	call   f0100040 <_panic>

f0103855 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103855:	55                   	push   %ebp
f0103856:	89 e5                	mov    %esp,%ebp
f0103858:	53                   	push   %ebx
f0103859:	83 ec 0c             	sub    $0xc,%esp
f010385c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
        //
        // First call to env_run
	cprintf("In env run, running env: %d\n", e->env_id);// can be commented - for testing purposes only
f010385f:	ff 73 7c             	pushl  0x7c(%ebx)
f0103862:	68 eb 7d 10 f0       	push   $0xf0107deb
f0103867:	e8 fc 03 00 00       	call   f0103c68 <cprintf>

        if ((curenv != NULL) && (curenv->env_status == ENV_RUNNING))
f010386c:	e8 19 2b 00 00       	call   f010638a <cpunum>
f0103871:	6b c0 74             	imul   $0x74,%eax,%eax
f0103874:	83 c4 10             	add    $0x10,%esp
f0103877:	83 b8 28 90 21 f0 00 	cmpl   $0x0,-0xfde6fd8(%eax)
f010387e:	74 2f                	je     f01038af <env_run+0x5a>
f0103880:	e8 05 2b 00 00       	call   f010638a <cpunum>
f0103885:	6b c0 74             	imul   $0x74,%eax,%eax
f0103888:	8b 80 28 90 21 f0    	mov    -0xfde6fd8(%eax),%eax
f010388e:	83 b8 88 00 00 00 03 	cmpl   $0x3,0x88(%eax)
f0103895:	75 18                	jne    f01038af <env_run+0x5a>
                curenv->env_status = ENV_RUNNABLE;
f0103897:	e8 ee 2a 00 00       	call   f010638a <cpunum>
f010389c:	6b c0 74             	imul   $0x74,%eax,%eax
f010389f:	8b 80 28 90 21 f0    	mov    -0xfde6fd8(%eax),%eax
f01038a5:	c7 80 88 00 00 00 02 	movl   $0x2,0x88(%eax)
f01038ac:	00 00 00 

        curenv = e;
f01038af:	e8 d6 2a 00 00       	call   f010638a <cpunum>
f01038b4:	6b c0 74             	imul   $0x74,%eax,%eax
f01038b7:	89 98 28 90 21 f0    	mov    %ebx,-0xfde6fd8(%eax)
        curenv->env_status = ENV_RUNNING;
f01038bd:	e8 c8 2a 00 00       	call   f010638a <cpunum>
f01038c2:	6b c0 74             	imul   $0x74,%eax,%eax
f01038c5:	8b 80 28 90 21 f0    	mov    -0xfde6fd8(%eax),%eax
f01038cb:	c7 80 88 00 00 00 03 	movl   $0x3,0x88(%eax)
f01038d2:	00 00 00 
        curenv->env_runs++;
f01038d5:	e8 b0 2a 00 00       	call   f010638a <cpunum>
f01038da:	6b c0 74             	imul   $0x74,%eax,%eax
f01038dd:	8b 80 28 90 21 f0    	mov    -0xfde6fd8(%eax),%eax
f01038e3:	83 80 8c 00 00 00 01 	addl   $0x1,0x8c(%eax)

        lcr3(PADDR(curenv->env_pgdir));
f01038ea:	e8 9b 2a 00 00       	call   f010638a <cpunum>
f01038ef:	6b c0 74             	imul   $0x74,%eax,%eax
f01038f2:	8b 80 28 90 21 f0    	mov    -0xfde6fd8(%eax),%eax
f01038f8:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01038fe:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103903:	77 15                	ja     f010391a <env_run+0xc5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103905:	50                   	push   %eax
f0103906:	68 68 6a 10 f0       	push   $0xf0106a68
f010390b:	68 82 02 00 00       	push   $0x282
f0103910:	68 b1 7d 10 f0       	push   $0xf0107db1
f0103915:	e8 26 c7 ff ff       	call   f0100040 <_panic>
f010391a:	05 00 00 00 10       	add    $0x10000000,%eax
f010391f:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103922:	83 ec 0c             	sub    $0xc,%esp
f0103925:	68 c0 23 12 f0       	push   $0xf01223c0
f010392a:	e8 66 2d 00 00       	call   f0106695 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010392f:	f3 90                	pause  
        unlock_kernel();
        env_pop_tf(&curenv->env_tf);
f0103931:	e8 54 2a 00 00       	call   f010638a <cpunum>
f0103936:	6b c0 74             	imul   $0x74,%eax,%eax
f0103939:	8b 80 28 90 21 f0    	mov    -0xfde6fd8(%eax),%eax
f010393f:	83 c0 34             	add    $0x34,%eax
f0103942:	89 04 24             	mov    %eax,(%esp)
f0103945:	e8 ca fe ff ff       	call   f0103814 <env_pop_tf>

f010394a <thread_free>:
// pri multithreadingu zdielany, takze by sme efektivne znicili env pgdir aj pre ostatne worker 
// thready a aj pre main thread, cize po prepnuti do jedneho z tychto threadov
// sa potom sposobuje velmi nepekny triple fault
void 
thread_free(struct Env* e)
{
f010394a:	55                   	push   %ebp
f010394b:	89 e5                	mov    %esp,%ebp
f010394d:	53                   	push   %ebx
f010394e:	83 ec 0c             	sub    $0xc,%esp
f0103951:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("In thread free, freeing thread: %d\n", e->env_id); 
f0103954:	ff 73 7c             	pushl  0x7c(%ebx)
f0103957:	68 64 7d 10 f0       	push   $0xf0107d64
f010395c:	e8 07 03 00 00       	call   f0103c68 <cprintf>
	// hod jej esp adresu na zoznam volnych stackov pre thready
	stack_push(e->env_stack_id);
f0103961:	83 c4 04             	add    $0x4,%esp
f0103964:	ff 73 04             	pushl  0x4(%ebx)
f0103967:	e8 1c f7 ff ff       	call   f0103088 <stack_push>
	struct Env* main_thrd = &envs[ENVX(e->env_process_id)];
f010396c:	8b 13                	mov    (%ebx),%edx
f010396e:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0103974:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
f010397a:	03 15 4c 82 21 f0    	add    0xf021824c,%edx

	int i;
	for(i = 0; i < MAX_PROCESS_THREADS; i++) {
		if(main_thrd->worker_threads[i] == e->env_id) {
f0103980:	8b 4b 7c             	mov    0x7c(%ebx),%ecx
f0103983:	83 c4 10             	add    $0x10,%esp
	// hod jej esp adresu na zoznam volnych stackov pre thready
	stack_push(e->env_stack_id);
	struct Env* main_thrd = &envs[ENVX(e->env_process_id)];

	int i;
	for(i = 0; i < MAX_PROCESS_THREADS; i++) {
f0103986:	b8 00 00 00 00       	mov    $0x0,%eax
		if(main_thrd->worker_threads[i] == e->env_id) {
f010398b:	39 4c 82 0c          	cmp    %ecx,0xc(%edx,%eax,4)
f010398f:	75 0a                	jne    f010399b <thread_free+0x51>
			main_thrd->worker_threads[i] = 0;	
f0103991:	c7 44 82 0c 00 00 00 	movl   $0x0,0xc(%edx,%eax,4)
f0103998:	00 
			break;
f0103999:	eb 08                	jmp    f01039a3 <thread_free+0x59>
	// hod jej esp adresu na zoznam volnych stackov pre thready
	stack_push(e->env_stack_id);
	struct Env* main_thrd = &envs[ENVX(e->env_process_id)];

	int i;
	for(i = 0; i < MAX_PROCESS_THREADS; i++) {
f010399b:	83 c0 01             	add    $0x1,%eax
f010399e:	83 f8 0a             	cmp    $0xa,%eax
f01039a1:	75 e8                	jne    f010398b <thread_free+0x41>
		}
		if(i == MAX_PROCESS_THREADS - 1) {
			// no such worker thread registered- should NOT happen
		}
	}
	e->env_pgdir = 0;
f01039a3:	c7 83 94 00 00 00 00 	movl   $0x0,0x94(%ebx)
f01039aa:	00 00 00 
	e->env_status = ENV_FREE;
f01039ad:	c7 83 88 00 00 00 00 	movl   $0x0,0x88(%ebx)
f01039b4:	00 00 00 
	e->env_link = env_free_list;
f01039b7:	a1 54 82 21 f0       	mov    0xf0218254,%eax
f01039bc:	89 43 78             	mov    %eax,0x78(%ebx)
	env_free_list = e;
f01039bf:	89 1d 54 82 21 f0    	mov    %ebx,0xf0218254
	if (curenv == e) {
f01039c5:	e8 c0 29 00 00       	call   f010638a <cpunum>
f01039ca:	6b c0 74             	imul   $0x74,%eax,%eax
f01039cd:	3b 98 28 90 21 f0    	cmp    -0xfde6fd8(%eax),%ebx
f01039d3:	75 17                	jne    f01039ec <thread_free+0xa2>
		curenv = NULL;
f01039d5:	e8 b0 29 00 00       	call   f010638a <cpunum>
f01039da:	6b c0 74             	imul   $0x74,%eax,%eax
f01039dd:	c7 80 28 90 21 f0 00 	movl   $0x0,-0xfde6fd8(%eax)
f01039e4:	00 00 00 
		sched_yield();
f01039e7:	e8 f6 10 00 00       	call   f0104ae2 <sched_yield>
	}
}
f01039ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01039ef:	c9                   	leave  
f01039f0:	c3                   	ret    

f01039f1 <thread_create>:
	main threadu), vratine env id

napad:  alokovanie zasobnikov - zasobnik s adresami vrcholov neobsadenych zasobnikov. Pri vytvoreni 		threadu sa popne, pri zniceni threadu pushne. //hotovo
	*/
envid_t thread_create(uintptr_t func)
{
f01039f1:	55                   	push   %ebp
f01039f2:	89 e5                	mov    %esp,%ebp
f01039f4:	53                   	push   %ebx
f01039f5:	83 ec 14             	sub    $0x14,%esp
	print_trapframe(&curenv->env_tf); // can be commented - for testing purposes only
f01039f8:	e8 8d 29 00 00       	call   f010638a <cpunum>
f01039fd:	83 ec 0c             	sub    $0xc,%esp
f0103a00:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a03:	8b 80 28 90 21 f0    	mov    -0xfde6fd8(%eax),%eax
f0103a09:	83 c0 34             	add    $0x34,%eax
f0103a0c:	50                   	push   %eax
f0103a0d:	e8 cd 09 00 00       	call   f01043df <print_trapframe>
	
	struct Env *e;
	env_alloc(&e, 0);
f0103a12:	83 c4 08             	add    $0x8,%esp
f0103a15:	6a 00                	push   $0x0
f0103a17:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103a1a:	50                   	push   %eax
f0103a1b:	e8 00 f8 ff ff       	call   f0103220 <env_alloc>
	e->env_pgdir = curenv->env_pgdir;
f0103a20:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0103a23:	e8 62 29 00 00       	call   f010638a <cpunum>
f0103a28:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a2b:	8b 80 28 90 21 f0    	mov    -0xfde6fd8(%eax),%eax
f0103a31:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
f0103a37:	89 83 94 00 00 00    	mov    %eax,0x94(%ebx)
	
	struct FreeStacks* stack = stack_pop();
f0103a3d:	e8 67 f6 ff ff       	call   f01030a9 <stack_pop>
f0103a42:	89 c3                	mov    %eax,%ebx
	e->env_stack_id = stack->id; 
f0103a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103a47:	8b 13                	mov    (%ebx),%edx
f0103a49:	89 50 04             	mov    %edx,0x4(%eax)
	region_alloc(e, (void*)(stack->addr - PGSIZE), PGSIZE);
f0103a4c:	8b 4b 04             	mov    0x4(%ebx),%ecx
f0103a4f:	8d 91 00 f0 ff ff    	lea    -0x1000(%ecx),%edx
f0103a55:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103a5a:	e8 a0 f5 ff ff       	call   f0102fff <region_alloc>
	e->env_tf.tf_esp = stack->addr;
f0103a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103a62:	8b 53 04             	mov    0x4(%ebx),%edx
f0103a65:	89 50 70             	mov    %edx,0x70(%eax)
	e->env_tf.tf_eip = func;
f0103a68:	8b 55 08             	mov    0x8(%ebp),%edx
f0103a6b:	89 50 64             	mov    %edx,0x64(%eax)
f0103a6e:	83 c4 10             	add    $0x10,%esp

	int i;
	for(i = 0; i < MAX_PROCESS_THREADS; i++)
f0103a71:	bb 00 00 00 00       	mov    $0x0,%ebx
	{
		if(curenv->worker_threads[i] == 0) {
f0103a76:	e8 0f 29 00 00       	call   f010638a <cpunum>
f0103a7b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a7e:	8b 80 28 90 21 f0    	mov    -0xfde6fd8(%eax),%eax
f0103a84:	83 7c 98 0c 00       	cmpl   $0x0,0xc(%eax,%ebx,4)
f0103a89:	75 1a                	jne    f0103aa5 <thread_create+0xb4>
			curenv->worker_threads[i] = e->env_id;	
f0103a8b:	e8 fa 28 00 00       	call   f010638a <cpunum>
f0103a90:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a93:	8b 80 28 90 21 f0    	mov    -0xfde6fd8(%eax),%eax
f0103a99:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103a9c:	8b 52 7c             	mov    0x7c(%edx),%edx
f0103a9f:	89 54 98 0c          	mov    %edx,0xc(%eax,%ebx,4)
			break;
f0103aa3:	eb 08                	jmp    f0103aad <thread_create+0xbc>
	region_alloc(e, (void*)(stack->addr - PGSIZE), PGSIZE);
	e->env_tf.tf_esp = stack->addr;
	e->env_tf.tf_eip = func;

	int i;
	for(i = 0; i < MAX_PROCESS_THREADS; i++)
f0103aa5:	83 c3 01             	add    $0x1,%ebx
f0103aa8:	83 fb 0a             	cmp    $0xa,%ebx
f0103aab:	75 c9                	jne    f0103a76 <thread_create+0x85>
		if(i == MAX_PROCESS_THREADS - 1) {
			// cant create any more threads - rollback
		}
	}

	e->env_status = ENV_RUNNABLE;
f0103aad:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0103ab0:	c7 83 88 00 00 00 02 	movl   $0x2,0x88(%ebx)
f0103ab7:	00 00 00 
	e->env_process_id = curenv->env_process_id; // resp. env_id ?
f0103aba:	e8 cb 28 00 00       	call   f010638a <cpunum>
f0103abf:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ac2:	8b 80 28 90 21 f0    	mov    -0xfde6fd8(%eax),%eax
f0103ac8:	8b 00                	mov    (%eax),%eax
f0103aca:	89 03                	mov    %eax,(%ebx)
	cprintf("in thread create: thread process id: %d\n", e->env_process_id);
f0103acc:	83 ec 08             	sub    $0x8,%esp
f0103acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103ad2:	ff 30                	pushl  (%eax)
f0103ad4:	68 88 7d 10 f0       	push   $0xf0107d88
f0103ad9:	e8 8a 01 00 00       	call   f0103c68 <cprintf>
	return e->env_id;
f0103ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103ae1:	8b 40 7c             	mov    0x7c(%eax),%eax
}
f0103ae4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103ae7:	c9                   	leave  
f0103ae8:	c3                   	ret    

f0103ae9 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103ae9:	55                   	push   %ebp
f0103aea:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103aec:	ba 70 00 00 00       	mov    $0x70,%edx
f0103af1:	8b 45 08             	mov    0x8(%ebp),%eax
f0103af4:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103af5:	ba 71 00 00 00       	mov    $0x71,%edx
f0103afa:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103afb:	0f b6 c0             	movzbl %al,%eax
}
f0103afe:	5d                   	pop    %ebp
f0103aff:	c3                   	ret    

f0103b00 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103b00:	55                   	push   %ebp
f0103b01:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103b03:	ba 70 00 00 00       	mov    $0x70,%edx
f0103b08:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b0b:	ee                   	out    %al,(%dx)
f0103b0c:	ba 71 00 00 00       	mov    $0x71,%edx
f0103b11:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103b14:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103b15:	5d                   	pop    %ebp
f0103b16:	c3                   	ret    

f0103b17 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103b17:	55                   	push   %ebp
f0103b18:	89 e5                	mov    %esp,%ebp
f0103b1a:	56                   	push   %esi
f0103b1b:	53                   	push   %ebx
f0103b1c:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103b1f:	66 a3 a8 23 12 f0    	mov    %ax,0xf01223a8
	if (!didinit)
f0103b25:	80 3d 58 82 21 f0 00 	cmpb   $0x0,0xf0218258
f0103b2c:	74 5a                	je     f0103b88 <irq_setmask_8259A+0x71>
f0103b2e:	89 c6                	mov    %eax,%esi
f0103b30:	ba 21 00 00 00       	mov    $0x21,%edx
f0103b35:	ee                   	out    %al,(%dx)
f0103b36:	66 c1 e8 08          	shr    $0x8,%ax
f0103b3a:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103b3f:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0103b40:	83 ec 0c             	sub    $0xc,%esp
f0103b43:	68 08 7e 10 f0       	push   $0xf0107e08
f0103b48:	e8 1b 01 00 00       	call   f0103c68 <cprintf>
f0103b4d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103b50:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103b55:	0f b7 f6             	movzwl %si,%esi
f0103b58:	f7 d6                	not    %esi
f0103b5a:	0f a3 de             	bt     %ebx,%esi
f0103b5d:	73 11                	jae    f0103b70 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f0103b5f:	83 ec 08             	sub    $0x8,%esp
f0103b62:	53                   	push   %ebx
f0103b63:	68 1b 83 10 f0       	push   $0xf010831b
f0103b68:	e8 fb 00 00 00       	call   f0103c68 <cprintf>
f0103b6d:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103b70:	83 c3 01             	add    $0x1,%ebx
f0103b73:	83 fb 10             	cmp    $0x10,%ebx
f0103b76:	75 e2                	jne    f0103b5a <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103b78:	83 ec 0c             	sub    $0xc,%esp
f0103b7b:	68 5a 82 10 f0       	push   $0xf010825a
f0103b80:	e8 e3 00 00 00       	call   f0103c68 <cprintf>
f0103b85:	83 c4 10             	add    $0x10,%esp
}
f0103b88:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103b8b:	5b                   	pop    %ebx
f0103b8c:	5e                   	pop    %esi
f0103b8d:	5d                   	pop    %ebp
f0103b8e:	c3                   	ret    

f0103b8f <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0103b8f:	c6 05 58 82 21 f0 01 	movb   $0x1,0xf0218258
f0103b96:	ba 21 00 00 00       	mov    $0x21,%edx
f0103b9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103ba0:	ee                   	out    %al,(%dx)
f0103ba1:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103ba6:	ee                   	out    %al,(%dx)
f0103ba7:	ba 20 00 00 00       	mov    $0x20,%edx
f0103bac:	b8 11 00 00 00       	mov    $0x11,%eax
f0103bb1:	ee                   	out    %al,(%dx)
f0103bb2:	ba 21 00 00 00       	mov    $0x21,%edx
f0103bb7:	b8 20 00 00 00       	mov    $0x20,%eax
f0103bbc:	ee                   	out    %al,(%dx)
f0103bbd:	b8 04 00 00 00       	mov    $0x4,%eax
f0103bc2:	ee                   	out    %al,(%dx)
f0103bc3:	b8 03 00 00 00       	mov    $0x3,%eax
f0103bc8:	ee                   	out    %al,(%dx)
f0103bc9:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103bce:	b8 11 00 00 00       	mov    $0x11,%eax
f0103bd3:	ee                   	out    %al,(%dx)
f0103bd4:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103bd9:	b8 28 00 00 00       	mov    $0x28,%eax
f0103bde:	ee                   	out    %al,(%dx)
f0103bdf:	b8 02 00 00 00       	mov    $0x2,%eax
f0103be4:	ee                   	out    %al,(%dx)
f0103be5:	b8 01 00 00 00       	mov    $0x1,%eax
f0103bea:	ee                   	out    %al,(%dx)
f0103beb:	ba 20 00 00 00       	mov    $0x20,%edx
f0103bf0:	b8 68 00 00 00       	mov    $0x68,%eax
f0103bf5:	ee                   	out    %al,(%dx)
f0103bf6:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103bfb:	ee                   	out    %al,(%dx)
f0103bfc:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103c01:	b8 68 00 00 00       	mov    $0x68,%eax
f0103c06:	ee                   	out    %al,(%dx)
f0103c07:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103c0c:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103c0d:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f0103c14:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103c18:	74 13                	je     f0103c2d <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103c1a:	55                   	push   %ebp
f0103c1b:	89 e5                	mov    %esp,%ebp
f0103c1d:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103c20:	0f b7 c0             	movzwl %ax,%eax
f0103c23:	50                   	push   %eax
f0103c24:	e8 ee fe ff ff       	call   f0103b17 <irq_setmask_8259A>
f0103c29:	83 c4 10             	add    $0x10,%esp
}
f0103c2c:	c9                   	leave  
f0103c2d:	f3 c3                	repz ret 

f0103c2f <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103c2f:	55                   	push   %ebp
f0103c30:	89 e5                	mov    %esp,%ebp
f0103c32:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103c35:	ff 75 08             	pushl  0x8(%ebp)
f0103c38:	e8 5c cb ff ff       	call   f0100799 <cputchar>
	*cnt++;
}
f0103c3d:	83 c4 10             	add    $0x10,%esp
f0103c40:	c9                   	leave  
f0103c41:	c3                   	ret    

f0103c42 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103c42:	55                   	push   %ebp
f0103c43:	89 e5                	mov    %esp,%ebp
f0103c45:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103c48:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103c4f:	ff 75 0c             	pushl  0xc(%ebp)
f0103c52:	ff 75 08             	pushl  0x8(%ebp)
f0103c55:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103c58:	50                   	push   %eax
f0103c59:	68 2f 3c 10 f0       	push   $0xf0103c2f
f0103c5e:	e8 83 1a 00 00       	call   f01056e6 <vprintfmt>
	return cnt;
}
f0103c63:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103c66:	c9                   	leave  
f0103c67:	c3                   	ret    

f0103c68 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103c68:	55                   	push   %ebp
f0103c69:	89 e5                	mov    %esp,%ebp
f0103c6b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103c6e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103c71:	50                   	push   %eax
f0103c72:	ff 75 08             	pushl  0x8(%ebp)
f0103c75:	e8 c8 ff ff ff       	call   f0103c42 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103c7a:	c9                   	leave  
f0103c7b:	c3                   	ret    

f0103c7c <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103c7c:	55                   	push   %ebp
f0103c7d:	89 e5                	mov    %esp,%ebp
f0103c7f:	57                   	push   %edi
f0103c80:	56                   	push   %esi
f0103c81:	53                   	push   %ebx
f0103c82:	83 ec 1c             	sub    $0x1c,%esp
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:

	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - (thiscpu->cpu_id * (KSTKSIZE + KSTKGAP));
f0103c85:	e8 00 27 00 00       	call   f010638a <cpunum>
f0103c8a:	89 c3                	mov    %eax,%ebx
f0103c8c:	e8 f9 26 00 00       	call   f010638a <cpunum>
f0103c91:	6b d3 74             	imul   $0x74,%ebx,%edx
f0103c94:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c97:	0f b6 88 20 90 21 f0 	movzbl -0xfde6fe0(%eax),%ecx
f0103c9e:	c1 e1 10             	shl    $0x10,%ecx
f0103ca1:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
f0103ca6:	29 c8                	sub    %ecx,%eax
f0103ca8:	89 82 30 90 21 f0    	mov    %eax,-0xfde6fd0(%edx)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103cae:	e8 d7 26 00 00       	call   f010638a <cpunum>
f0103cb3:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cb6:	66 c7 80 34 90 21 f0 	movw   $0x10,-0xfde6fcc(%eax)
f0103cbd:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f0103cbf:	e8 c6 26 00 00       	call   f010638a <cpunum>
f0103cc4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cc7:	66 c7 80 92 90 21 f0 	movw   $0x68,-0xfde6f6e(%eax)
f0103cce:	68 00 

	uint32_t curr_cpu_gdt_index = GD_TSS0 + ((thiscpu->cpu_id + 1) * 8);
f0103cd0:	e8 b5 26 00 00       	call   f010638a <cpunum>
f0103cd5:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cd8:	0f b6 80 20 90 21 f0 	movzbl -0xfde6fe0(%eax),%eax
f0103cdf:	8d 3c c5 30 00 00 00 	lea    0x30(,%eax,8),%edi

	gdt[curr_cpu_gdt_index >> 3] = SEG16
f0103ce6:	89 fb                	mov    %edi,%ebx
f0103ce8:	c1 eb 03             	shr    $0x3,%ebx
f0103ceb:	e8 9a 26 00 00       	call   f010638a <cpunum>
f0103cf0:	89 c6                	mov    %eax,%esi
f0103cf2:	e8 93 26 00 00       	call   f010638a <cpunum>
f0103cf7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103cfa:	e8 8b 26 00 00       	call   f010638a <cpunum>
f0103cff:	66 c7 04 dd 40 23 12 	movw   $0x67,-0xfeddcc0(,%ebx,8)
f0103d06:	f0 67 00 
f0103d09:	6b f6 74             	imul   $0x74,%esi,%esi
f0103d0c:	81 c6 2c 90 21 f0    	add    $0xf021902c,%esi
f0103d12:	66 89 34 dd 42 23 12 	mov    %si,-0xfeddcbe(,%ebx,8)
f0103d19:	f0 
f0103d1a:	6b 55 e4 74          	imul   $0x74,-0x1c(%ebp),%edx
f0103d1e:	81 c2 2c 90 21 f0    	add    $0xf021902c,%edx
f0103d24:	c1 ea 10             	shr    $0x10,%edx
f0103d27:	88 14 dd 44 23 12 f0 	mov    %dl,-0xfeddcbc(,%ebx,8)
f0103d2e:	c6 04 dd 46 23 12 f0 	movb   $0x40,-0xfeddcba(,%ebx,8)
f0103d35:	40 
f0103d36:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d39:	05 2c 90 21 f0       	add    $0xf021902c,%eax
f0103d3e:	c1 e8 18             	shr    $0x18,%eax
f0103d41:	88 04 dd 47 23 12 f0 	mov    %al,-0xfeddcb9(,%ebx,8)
	(STS_T32A, (uint32_t) (&thiscpu->cpu_ts), sizeof(struct Taskstate) - 1, 0);
	gdt[curr_cpu_gdt_index >> 3].sd_s = 0;
f0103d48:	c6 04 dd 45 23 12 f0 	movb   $0x89,-0xfeddcbb(,%ebx,8)
f0103d4f:	89 
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0103d50:	0f 00 df             	ltr    %di
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f0103d53:	b8 ac 23 12 f0       	mov    $0xf01223ac,%eax
f0103d58:	0f 01 18             	lidtl  (%eax)
	
	ltr(curr_cpu_gdt_index);

	// Load the IDT
	lidt(&idt_pd);
}
f0103d5b:	83 c4 1c             	add    $0x1c,%esp
f0103d5e:	5b                   	pop    %ebx
f0103d5f:	5e                   	pop    %esi
f0103d60:	5f                   	pop    %edi
f0103d61:	5d                   	pop    %ebp
f0103d62:	c3                   	ret    

f0103d63 <trap_init>:
}


void
trap_init(void)
{
f0103d63:	55                   	push   %ebp
f0103d64:	89 e5                	mov    %esp,%ebp
f0103d66:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.

	extern void TH_DIVIDE(); 	SETGATE(idt[T_DIVIDE], 0, GD_KT, TH_DIVIDE, 							0); 
f0103d69:	b8 f4 48 10 f0       	mov    $0xf01048f4,%eax
f0103d6e:	66 a3 60 82 21 f0    	mov    %ax,0xf0218260
f0103d74:	66 c7 05 62 82 21 f0 	movw   $0x8,0xf0218262
f0103d7b:	08 00 
f0103d7d:	c6 05 64 82 21 f0 00 	movb   $0x0,0xf0218264
f0103d84:	c6 05 65 82 21 f0 8e 	movb   $0x8e,0xf0218265
f0103d8b:	c1 e8 10             	shr    $0x10,%eax
f0103d8e:	66 a3 66 82 21 f0    	mov    %ax,0xf0218266
	extern void TH_DEBUG(); 	SETGATE(idt[T_DEBUG], 0, GD_KT, TH_DEBUG, 0); 
f0103d94:	b8 fe 48 10 f0       	mov    $0xf01048fe,%eax
f0103d99:	66 a3 68 82 21 f0    	mov    %ax,0xf0218268
f0103d9f:	66 c7 05 6a 82 21 f0 	movw   $0x8,0xf021826a
f0103da6:	08 00 
f0103da8:	c6 05 6c 82 21 f0 00 	movb   $0x0,0xf021826c
f0103daf:	c6 05 6d 82 21 f0 8e 	movb   $0x8e,0xf021826d
f0103db6:	c1 e8 10             	shr    $0x10,%eax
f0103db9:	66 a3 6e 82 21 f0    	mov    %ax,0xf021826e
	extern void TH_NMI(); 		SETGATE(idt[T_NMI], 0, GD_KT, TH_NMI, 0); 
f0103dbf:	b8 08 49 10 f0       	mov    $0xf0104908,%eax
f0103dc4:	66 a3 70 82 21 f0    	mov    %ax,0xf0218270
f0103dca:	66 c7 05 72 82 21 f0 	movw   $0x8,0xf0218272
f0103dd1:	08 00 
f0103dd3:	c6 05 74 82 21 f0 00 	movb   $0x0,0xf0218274
f0103dda:	c6 05 75 82 21 f0 8e 	movb   $0x8e,0xf0218275
f0103de1:	c1 e8 10             	shr    $0x10,%eax
f0103de4:	66 a3 76 82 21 f0    	mov    %ax,0xf0218276
	extern void TH_BRKPT(); 	SETGATE(idt[T_BRKPT], 0, GD_KT, TH_BRKPT, 3); 
f0103dea:	b8 12 49 10 f0       	mov    $0xf0104912,%eax
f0103def:	66 a3 78 82 21 f0    	mov    %ax,0xf0218278
f0103df5:	66 c7 05 7a 82 21 f0 	movw   $0x8,0xf021827a
f0103dfc:	08 00 
f0103dfe:	c6 05 7c 82 21 f0 00 	movb   $0x0,0xf021827c
f0103e05:	c6 05 7d 82 21 f0 ee 	movb   $0xee,0xf021827d
f0103e0c:	c1 e8 10             	shr    $0x10,%eax
f0103e0f:	66 a3 7e 82 21 f0    	mov    %ax,0xf021827e
	extern void TH_OFLOW(); 	SETGATE(idt[T_OFLOW], 0, GD_KT, TH_OFLOW, 0); 
f0103e15:	b8 1c 49 10 f0       	mov    $0xf010491c,%eax
f0103e1a:	66 a3 80 82 21 f0    	mov    %ax,0xf0218280
f0103e20:	66 c7 05 82 82 21 f0 	movw   $0x8,0xf0218282
f0103e27:	08 00 
f0103e29:	c6 05 84 82 21 f0 00 	movb   $0x0,0xf0218284
f0103e30:	c6 05 85 82 21 f0 8e 	movb   $0x8e,0xf0218285
f0103e37:	c1 e8 10             	shr    $0x10,%eax
f0103e3a:	66 a3 86 82 21 f0    	mov    %ax,0xf0218286
	extern void TH_BOUND(); 	SETGATE(idt[T_BOUND], 0, GD_KT, TH_BOUND, 0); 
f0103e40:	b8 26 49 10 f0       	mov    $0xf0104926,%eax
f0103e45:	66 a3 88 82 21 f0    	mov    %ax,0xf0218288
f0103e4b:	66 c7 05 8a 82 21 f0 	movw   $0x8,0xf021828a
f0103e52:	08 00 
f0103e54:	c6 05 8c 82 21 f0 00 	movb   $0x0,0xf021828c
f0103e5b:	c6 05 8d 82 21 f0 8e 	movb   $0x8e,0xf021828d
f0103e62:	c1 e8 10             	shr    $0x10,%eax
f0103e65:	66 a3 8e 82 21 f0    	mov    %ax,0xf021828e
	extern void TH_ILLOP(); 	SETGATE(idt[T_ILLOP], 0, GD_KT, TH_ILLOP, 0); 
f0103e6b:	b8 30 49 10 f0       	mov    $0xf0104930,%eax
f0103e70:	66 a3 90 82 21 f0    	mov    %ax,0xf0218290
f0103e76:	66 c7 05 92 82 21 f0 	movw   $0x8,0xf0218292
f0103e7d:	08 00 
f0103e7f:	c6 05 94 82 21 f0 00 	movb   $0x0,0xf0218294
f0103e86:	c6 05 95 82 21 f0 8e 	movb   $0x8e,0xf0218295
f0103e8d:	c1 e8 10             	shr    $0x10,%eax
f0103e90:	66 a3 96 82 21 f0    	mov    %ax,0xf0218296
	extern void TH_DEVICE(); 	SETGATE(idt[T_DEVICE], 0, GD_KT, TH_DEVICE, 							0); 
f0103e96:	b8 3a 49 10 f0       	mov    $0xf010493a,%eax
f0103e9b:	66 a3 98 82 21 f0    	mov    %ax,0xf0218298
f0103ea1:	66 c7 05 9a 82 21 f0 	movw   $0x8,0xf021829a
f0103ea8:	08 00 
f0103eaa:	c6 05 9c 82 21 f0 00 	movb   $0x0,0xf021829c
f0103eb1:	c6 05 9d 82 21 f0 8e 	movb   $0x8e,0xf021829d
f0103eb8:	c1 e8 10             	shr    $0x10,%eax
f0103ebb:	66 a3 9e 82 21 f0    	mov    %ax,0xf021829e
	extern void TH_DBLFLT(); 	SETGATE(idt[T_DBLFLT], 0, GD_KT, TH_DBLFLT, 							0); 
f0103ec1:	b8 44 49 10 f0       	mov    $0xf0104944,%eax
f0103ec6:	66 a3 a0 82 21 f0    	mov    %ax,0xf02182a0
f0103ecc:	66 c7 05 a2 82 21 f0 	movw   $0x8,0xf02182a2
f0103ed3:	08 00 
f0103ed5:	c6 05 a4 82 21 f0 00 	movb   $0x0,0xf02182a4
f0103edc:	c6 05 a5 82 21 f0 8e 	movb   $0x8e,0xf02182a5
f0103ee3:	c1 e8 10             	shr    $0x10,%eax
f0103ee6:	66 a3 a6 82 21 f0    	mov    %ax,0xf02182a6
	extern void TH_TSS(); 		SETGATE(idt[T_TSS], 0, GD_KT, TH_TSS, 0); 
f0103eec:	b8 4c 49 10 f0       	mov    $0xf010494c,%eax
f0103ef1:	66 a3 b0 82 21 f0    	mov    %ax,0xf02182b0
f0103ef7:	66 c7 05 b2 82 21 f0 	movw   $0x8,0xf02182b2
f0103efe:	08 00 
f0103f00:	c6 05 b4 82 21 f0 00 	movb   $0x0,0xf02182b4
f0103f07:	c6 05 b5 82 21 f0 8e 	movb   $0x8e,0xf02182b5
f0103f0e:	c1 e8 10             	shr    $0x10,%eax
f0103f11:	66 a3 b6 82 21 f0    	mov    %ax,0xf02182b6
	extern void TH_SEGNP(); 	SETGATE(idt[T_SEGNP], 0, GD_KT, TH_SEGNP, 0); 
f0103f17:	b8 54 49 10 f0       	mov    $0xf0104954,%eax
f0103f1c:	66 a3 b8 82 21 f0    	mov    %ax,0xf02182b8
f0103f22:	66 c7 05 ba 82 21 f0 	movw   $0x8,0xf02182ba
f0103f29:	08 00 
f0103f2b:	c6 05 bc 82 21 f0 00 	movb   $0x0,0xf02182bc
f0103f32:	c6 05 bd 82 21 f0 8e 	movb   $0x8e,0xf02182bd
f0103f39:	c1 e8 10             	shr    $0x10,%eax
f0103f3c:	66 a3 be 82 21 f0    	mov    %ax,0xf02182be
	extern void TH_STACK(); 	SETGATE(idt[T_STACK], 0, GD_KT, TH_STACK, 0); 
f0103f42:	b8 5c 49 10 f0       	mov    $0xf010495c,%eax
f0103f47:	66 a3 c0 82 21 f0    	mov    %ax,0xf02182c0
f0103f4d:	66 c7 05 c2 82 21 f0 	movw   $0x8,0xf02182c2
f0103f54:	08 00 
f0103f56:	c6 05 c4 82 21 f0 00 	movb   $0x0,0xf02182c4
f0103f5d:	c6 05 c5 82 21 f0 8e 	movb   $0x8e,0xf02182c5
f0103f64:	c1 e8 10             	shr    $0x10,%eax
f0103f67:	66 a3 c6 82 21 f0    	mov    %ax,0xf02182c6
	extern void TH_GPFLT(); 	SETGATE(idt[T_GPFLT], 0, GD_KT, TH_GPFLT, 0); 
f0103f6d:	b8 64 49 10 f0       	mov    $0xf0104964,%eax
f0103f72:	66 a3 c8 82 21 f0    	mov    %ax,0xf02182c8
f0103f78:	66 c7 05 ca 82 21 f0 	movw   $0x8,0xf02182ca
f0103f7f:	08 00 
f0103f81:	c6 05 cc 82 21 f0 00 	movb   $0x0,0xf02182cc
f0103f88:	c6 05 cd 82 21 f0 8e 	movb   $0x8e,0xf02182cd
f0103f8f:	c1 e8 10             	shr    $0x10,%eax
f0103f92:	66 a3 ce 82 21 f0    	mov    %ax,0xf02182ce
	extern void TH_PGFLT(); 	SETGATE(idt[T_PGFLT], 0, GD_KT, TH_PGFLT, 0); 
f0103f98:	b8 6c 49 10 f0       	mov    $0xf010496c,%eax
f0103f9d:	66 a3 d0 82 21 f0    	mov    %ax,0xf02182d0
f0103fa3:	66 c7 05 d2 82 21 f0 	movw   $0x8,0xf02182d2
f0103faa:	08 00 
f0103fac:	c6 05 d4 82 21 f0 00 	movb   $0x0,0xf02182d4
f0103fb3:	c6 05 d5 82 21 f0 8e 	movb   $0x8e,0xf02182d5
f0103fba:	c1 e8 10             	shr    $0x10,%eax
f0103fbd:	66 a3 d6 82 21 f0    	mov    %ax,0xf02182d6
	extern void TH_FPERR(); 	SETGATE(idt[T_FPERR], 0, GD_KT, TH_FPERR, 0); 
f0103fc3:	b8 74 49 10 f0       	mov    $0xf0104974,%eax
f0103fc8:	66 a3 e0 82 21 f0    	mov    %ax,0xf02182e0
f0103fce:	66 c7 05 e2 82 21 f0 	movw   $0x8,0xf02182e2
f0103fd5:	08 00 
f0103fd7:	c6 05 e4 82 21 f0 00 	movb   $0x0,0xf02182e4
f0103fde:	c6 05 e5 82 21 f0 8e 	movb   $0x8e,0xf02182e5
f0103fe5:	c1 e8 10             	shr    $0x10,%eax
f0103fe8:	66 a3 e6 82 21 f0    	mov    %ax,0xf02182e6
	extern void TH_ALIGN(); 	SETGATE(idt[T_ALIGN], 0, GD_KT, TH_ALIGN, 0); 
f0103fee:	b8 7a 49 10 f0       	mov    $0xf010497a,%eax
f0103ff3:	66 a3 e8 82 21 f0    	mov    %ax,0xf02182e8
f0103ff9:	66 c7 05 ea 82 21 f0 	movw   $0x8,0xf02182ea
f0104000:	08 00 
f0104002:	c6 05 ec 82 21 f0 00 	movb   $0x0,0xf02182ec
f0104009:	c6 05 ed 82 21 f0 8e 	movb   $0x8e,0xf02182ed
f0104010:	c1 e8 10             	shr    $0x10,%eax
f0104013:	66 a3 ee 82 21 f0    	mov    %ax,0xf02182ee
	extern void TH_MCHK(); 		SETGATE(idt[T_MCHK], 0, GD_KT, TH_MCHK, 0); 
f0104019:	b8 7e 49 10 f0       	mov    $0xf010497e,%eax
f010401e:	66 a3 f0 82 21 f0    	mov    %ax,0xf02182f0
f0104024:	66 c7 05 f2 82 21 f0 	movw   $0x8,0xf02182f2
f010402b:	08 00 
f010402d:	c6 05 f4 82 21 f0 00 	movb   $0x0,0xf02182f4
f0104034:	c6 05 f5 82 21 f0 8e 	movb   $0x8e,0xf02182f5
f010403b:	c1 e8 10             	shr    $0x10,%eax
f010403e:	66 a3 f6 82 21 f0    	mov    %ax,0xf02182f6
	extern void TH_SIMDERR(); 	SETGATE(idt[T_SIMDERR], 0, GD_KT, TH_SIMDERR, 							0); 	// prepisat neskor ako interrupt 
f0104044:	b8 84 49 10 f0       	mov    $0xf0104984,%eax
f0104049:	66 a3 f8 82 21 f0    	mov    %ax,0xf02182f8
f010404f:	66 c7 05 fa 82 21 f0 	movw   $0x8,0xf02182fa
f0104056:	08 00 
f0104058:	c6 05 fc 82 21 f0 00 	movb   $0x0,0xf02182fc
f010405f:	c6 05 fd 82 21 f0 8e 	movb   $0x8e,0xf02182fd
f0104066:	c1 e8 10             	shr    $0x10,%eax
f0104069:	66 a3 fe 82 21 f0    	mov    %ax,0xf02182fe
							// namiesto trapu (neskor)
	extern void TH_SYSCALL(); 	SETGATE(idt[T_SYSCALL], 0, GD_KT, TH_SYSCALL, 							3); 
f010406f:	b8 8a 49 10 f0       	mov    $0xf010498a,%eax
f0104074:	66 a3 e0 83 21 f0    	mov    %ax,0xf02183e0
f010407a:	66 c7 05 e2 83 21 f0 	movw   $0x8,0xf02183e2
f0104081:	08 00 
f0104083:	c6 05 e4 83 21 f0 00 	movb   $0x0,0xf02183e4
f010408a:	c6 05 e5 83 21 f0 ee 	movb   $0xee,0xf02183e5
f0104091:	c1 e8 10             	shr    $0x10,%eax
f0104094:	66 a3 e6 83 21 f0    	mov    %ax,0xf02183e6

	extern void TH_IRQ_TIMER();	SETGATE(idt[IRQ_OFFSET + 0], 0, GD_KT, TH_IRQ_TIMER, 0);
f010409a:	b8 90 49 10 f0       	mov    $0xf0104990,%eax
f010409f:	66 a3 60 83 21 f0    	mov    %ax,0xf0218360
f01040a5:	66 c7 05 62 83 21 f0 	movw   $0x8,0xf0218362
f01040ac:	08 00 
f01040ae:	c6 05 64 83 21 f0 00 	movb   $0x0,0xf0218364
f01040b5:	c6 05 65 83 21 f0 8e 	movb   $0x8e,0xf0218365
f01040bc:	c1 e8 10             	shr    $0x10,%eax
f01040bf:	66 a3 66 83 21 f0    	mov    %ax,0xf0218366
	extern void TH_IRQ_KBD();	SETGATE(idt[IRQ_OFFSET + 1], 0, GD_KT, TH_IRQ_KBD, 0);
f01040c5:	b8 96 49 10 f0       	mov    $0xf0104996,%eax
f01040ca:	66 a3 68 83 21 f0    	mov    %ax,0xf0218368
f01040d0:	66 c7 05 6a 83 21 f0 	movw   $0x8,0xf021836a
f01040d7:	08 00 
f01040d9:	c6 05 6c 83 21 f0 00 	movb   $0x0,0xf021836c
f01040e0:	c6 05 6d 83 21 f0 8e 	movb   $0x8e,0xf021836d
f01040e7:	c1 e8 10             	shr    $0x10,%eax
f01040ea:	66 a3 6e 83 21 f0    	mov    %ax,0xf021836e
	extern void TH_IRQ_2();		SETGATE(idt[IRQ_OFFSET + 2], 0, GD_KT, TH_IRQ_2, 0);
f01040f0:	b8 9c 49 10 f0       	mov    $0xf010499c,%eax
f01040f5:	66 a3 70 83 21 f0    	mov    %ax,0xf0218370
f01040fb:	66 c7 05 72 83 21 f0 	movw   $0x8,0xf0218372
f0104102:	08 00 
f0104104:	c6 05 74 83 21 f0 00 	movb   $0x0,0xf0218374
f010410b:	c6 05 75 83 21 f0 8e 	movb   $0x8e,0xf0218375
f0104112:	c1 e8 10             	shr    $0x10,%eax
f0104115:	66 a3 76 83 21 f0    	mov    %ax,0xf0218376
	extern void TH_IRQ_3();		SETGATE(idt[IRQ_OFFSET + 3], 0, GD_KT, TH_IRQ_3, 0);
f010411b:	b8 a2 49 10 f0       	mov    $0xf01049a2,%eax
f0104120:	66 a3 78 83 21 f0    	mov    %ax,0xf0218378
f0104126:	66 c7 05 7a 83 21 f0 	movw   $0x8,0xf021837a
f010412d:	08 00 
f010412f:	c6 05 7c 83 21 f0 00 	movb   $0x0,0xf021837c
f0104136:	c6 05 7d 83 21 f0 8e 	movb   $0x8e,0xf021837d
f010413d:	c1 e8 10             	shr    $0x10,%eax
f0104140:	66 a3 7e 83 21 f0    	mov    %ax,0xf021837e
	extern void TH_IRQ_SERIAL();	SETGATE(idt[IRQ_OFFSET + 4], 0, GD_KT, TH_IRQ_SERIAL, 0);
f0104146:	b8 a8 49 10 f0       	mov    $0xf01049a8,%eax
f010414b:	66 a3 80 83 21 f0    	mov    %ax,0xf0218380
f0104151:	66 c7 05 82 83 21 f0 	movw   $0x8,0xf0218382
f0104158:	08 00 
f010415a:	c6 05 84 83 21 f0 00 	movb   $0x0,0xf0218384
f0104161:	c6 05 85 83 21 f0 8e 	movb   $0x8e,0xf0218385
f0104168:	c1 e8 10             	shr    $0x10,%eax
f010416b:	66 a3 86 83 21 f0    	mov    %ax,0xf0218386
	extern void TH_IRQ_5();		SETGATE(idt[IRQ_OFFSET + 5], 0, GD_KT, TH_IRQ_5, 0);
f0104171:	b8 ae 49 10 f0       	mov    $0xf01049ae,%eax
f0104176:	66 a3 88 83 21 f0    	mov    %ax,0xf0218388
f010417c:	66 c7 05 8a 83 21 f0 	movw   $0x8,0xf021838a
f0104183:	08 00 
f0104185:	c6 05 8c 83 21 f0 00 	movb   $0x0,0xf021838c
f010418c:	c6 05 8d 83 21 f0 8e 	movb   $0x8e,0xf021838d
f0104193:	c1 e8 10             	shr    $0x10,%eax
f0104196:	66 a3 8e 83 21 f0    	mov    %ax,0xf021838e
	extern void TH_IRQ_6();		SETGATE(idt[IRQ_OFFSET + 6], 0, GD_KT, TH_IRQ_6, 0);
f010419c:	b8 b4 49 10 f0       	mov    $0xf01049b4,%eax
f01041a1:	66 a3 90 83 21 f0    	mov    %ax,0xf0218390
f01041a7:	66 c7 05 92 83 21 f0 	movw   $0x8,0xf0218392
f01041ae:	08 00 
f01041b0:	c6 05 94 83 21 f0 00 	movb   $0x0,0xf0218394
f01041b7:	c6 05 95 83 21 f0 8e 	movb   $0x8e,0xf0218395
f01041be:	c1 e8 10             	shr    $0x10,%eax
f01041c1:	66 a3 96 83 21 f0    	mov    %ax,0xf0218396
	extern void TH_IRQ_SPURIOUS();	SETGATE(idt[IRQ_OFFSET + 7], 0, GD_KT, TH_IRQ_SPURIOUS, 0);
f01041c7:	b8 ba 49 10 f0       	mov    $0xf01049ba,%eax
f01041cc:	66 a3 98 83 21 f0    	mov    %ax,0xf0218398
f01041d2:	66 c7 05 9a 83 21 f0 	movw   $0x8,0xf021839a
f01041d9:	08 00 
f01041db:	c6 05 9c 83 21 f0 00 	movb   $0x0,0xf021839c
f01041e2:	c6 05 9d 83 21 f0 8e 	movb   $0x8e,0xf021839d
f01041e9:	c1 e8 10             	shr    $0x10,%eax
f01041ec:	66 a3 9e 83 21 f0    	mov    %ax,0xf021839e
	extern void TH_IRQ_8();		SETGATE(idt[IRQ_OFFSET + 8], 0, GD_KT, TH_IRQ_8, 0);
f01041f2:	b8 c0 49 10 f0       	mov    $0xf01049c0,%eax
f01041f7:	66 a3 a0 83 21 f0    	mov    %ax,0xf02183a0
f01041fd:	66 c7 05 a2 83 21 f0 	movw   $0x8,0xf02183a2
f0104204:	08 00 
f0104206:	c6 05 a4 83 21 f0 00 	movb   $0x0,0xf02183a4
f010420d:	c6 05 a5 83 21 f0 8e 	movb   $0x8e,0xf02183a5
f0104214:	c1 e8 10             	shr    $0x10,%eax
f0104217:	66 a3 a6 83 21 f0    	mov    %ax,0xf02183a6
	extern void TH_IRQ_9();		SETGATE(idt[IRQ_OFFSET + 9], 0, GD_KT, TH_IRQ_9, 0);
f010421d:	b8 c6 49 10 f0       	mov    $0xf01049c6,%eax
f0104222:	66 a3 a8 83 21 f0    	mov    %ax,0xf02183a8
f0104228:	66 c7 05 aa 83 21 f0 	movw   $0x8,0xf02183aa
f010422f:	08 00 
f0104231:	c6 05 ac 83 21 f0 00 	movb   $0x0,0xf02183ac
f0104238:	c6 05 ad 83 21 f0 8e 	movb   $0x8e,0xf02183ad
f010423f:	c1 e8 10             	shr    $0x10,%eax
f0104242:	66 a3 ae 83 21 f0    	mov    %ax,0xf02183ae
	extern void TH_IRQ_10();	SETGATE(idt[IRQ_OFFSET + 10], 0, GD_KT, TH_IRQ_10, 0);
f0104248:	b8 cc 49 10 f0       	mov    $0xf01049cc,%eax
f010424d:	66 a3 b0 83 21 f0    	mov    %ax,0xf02183b0
f0104253:	66 c7 05 b2 83 21 f0 	movw   $0x8,0xf02183b2
f010425a:	08 00 
f010425c:	c6 05 b4 83 21 f0 00 	movb   $0x0,0xf02183b4
f0104263:	c6 05 b5 83 21 f0 8e 	movb   $0x8e,0xf02183b5
f010426a:	c1 e8 10             	shr    $0x10,%eax
f010426d:	66 a3 b6 83 21 f0    	mov    %ax,0xf02183b6
	extern void TH_IRQ_11();	SETGATE(idt[IRQ_OFFSET + 11], 0, GD_KT, TH_IRQ_11, 0);
f0104273:	b8 d2 49 10 f0       	mov    $0xf01049d2,%eax
f0104278:	66 a3 b8 83 21 f0    	mov    %ax,0xf02183b8
f010427e:	66 c7 05 ba 83 21 f0 	movw   $0x8,0xf02183ba
f0104285:	08 00 
f0104287:	c6 05 bc 83 21 f0 00 	movb   $0x0,0xf02183bc
f010428e:	c6 05 bd 83 21 f0 8e 	movb   $0x8e,0xf02183bd
f0104295:	c1 e8 10             	shr    $0x10,%eax
f0104298:	66 a3 be 83 21 f0    	mov    %ax,0xf02183be
	extern void TH_IRQ_12();	SETGATE(idt[IRQ_OFFSET + 12], 0, GD_KT, TH_IRQ_12, 0);
f010429e:	b8 d8 49 10 f0       	mov    $0xf01049d8,%eax
f01042a3:	66 a3 c0 83 21 f0    	mov    %ax,0xf02183c0
f01042a9:	66 c7 05 c2 83 21 f0 	movw   $0x8,0xf02183c2
f01042b0:	08 00 
f01042b2:	c6 05 c4 83 21 f0 00 	movb   $0x0,0xf02183c4
f01042b9:	c6 05 c5 83 21 f0 8e 	movb   $0x8e,0xf02183c5
f01042c0:	c1 e8 10             	shr    $0x10,%eax
f01042c3:	66 a3 c6 83 21 f0    	mov    %ax,0xf02183c6
	extern void TH_IRQ_13();	SETGATE(idt[IRQ_OFFSET + 13], 0, GD_KT, TH_IRQ_13, 0);
f01042c9:	b8 de 49 10 f0       	mov    $0xf01049de,%eax
f01042ce:	66 a3 c8 83 21 f0    	mov    %ax,0xf02183c8
f01042d4:	66 c7 05 ca 83 21 f0 	movw   $0x8,0xf02183ca
f01042db:	08 00 
f01042dd:	c6 05 cc 83 21 f0 00 	movb   $0x0,0xf02183cc
f01042e4:	c6 05 cd 83 21 f0 8e 	movb   $0x8e,0xf02183cd
f01042eb:	c1 e8 10             	shr    $0x10,%eax
f01042ee:	66 a3 ce 83 21 f0    	mov    %ax,0xf02183ce
	extern void TH_IRQ_IDE();	SETGATE(idt[IRQ_OFFSET + 14], 0, GD_KT, TH_IRQ_IDE, 0);
f01042f4:	b8 e4 49 10 f0       	mov    $0xf01049e4,%eax
f01042f9:	66 a3 d0 83 21 f0    	mov    %ax,0xf02183d0
f01042ff:	66 c7 05 d2 83 21 f0 	movw   $0x8,0xf02183d2
f0104306:	08 00 
f0104308:	c6 05 d4 83 21 f0 00 	movb   $0x0,0xf02183d4
f010430f:	c6 05 d5 83 21 f0 8e 	movb   $0x8e,0xf02183d5
f0104316:	c1 e8 10             	shr    $0x10,%eax
f0104319:	66 a3 d6 83 21 f0    	mov    %ax,0xf02183d6
	extern void TH_IRQ_15();	SETGATE(idt[IRQ_OFFSET + 15], 0, GD_KT, TH_IRQ_15, 0);
f010431f:	b8 ea 49 10 f0       	mov    $0xf01049ea,%eax
f0104324:	66 a3 d8 83 21 f0    	mov    %ax,0xf02183d8
f010432a:	66 c7 05 da 83 21 f0 	movw   $0x8,0xf02183da
f0104331:	08 00 
f0104333:	c6 05 dc 83 21 f0 00 	movb   $0x0,0xf02183dc
f010433a:	c6 05 dd 83 21 f0 8e 	movb   $0x8e,0xf02183dd
f0104341:	c1 e8 10             	shr    $0x10,%eax
f0104344:	66 a3 de 83 21 f0    	mov    %ax,0xf02183de

	// Per-CPU setup 
	trap_init_percpu();
f010434a:	e8 2d f9 ff ff       	call   f0103c7c <trap_init_percpu>
}
f010434f:	c9                   	leave  
f0104350:	c3                   	ret    

f0104351 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0104351:	55                   	push   %ebp
f0104352:	89 e5                	mov    %esp,%ebp
f0104354:	53                   	push   %ebx
f0104355:	83 ec 0c             	sub    $0xc,%esp
f0104358:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010435b:	ff 33                	pushl  (%ebx)
f010435d:	68 1c 7e 10 f0       	push   $0xf0107e1c
f0104362:	e8 01 f9 ff ff       	call   f0103c68 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0104367:	83 c4 08             	add    $0x8,%esp
f010436a:	ff 73 04             	pushl  0x4(%ebx)
f010436d:	68 2b 7e 10 f0       	push   $0xf0107e2b
f0104372:	e8 f1 f8 ff ff       	call   f0103c68 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0104377:	83 c4 08             	add    $0x8,%esp
f010437a:	ff 73 08             	pushl  0x8(%ebx)
f010437d:	68 3a 7e 10 f0       	push   $0xf0107e3a
f0104382:	e8 e1 f8 ff ff       	call   f0103c68 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104387:	83 c4 08             	add    $0x8,%esp
f010438a:	ff 73 0c             	pushl  0xc(%ebx)
f010438d:	68 49 7e 10 f0       	push   $0xf0107e49
f0104392:	e8 d1 f8 ff ff       	call   f0103c68 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104397:	83 c4 08             	add    $0x8,%esp
f010439a:	ff 73 10             	pushl  0x10(%ebx)
f010439d:	68 58 7e 10 f0       	push   $0xf0107e58
f01043a2:	e8 c1 f8 ff ff       	call   f0103c68 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01043a7:	83 c4 08             	add    $0x8,%esp
f01043aa:	ff 73 14             	pushl  0x14(%ebx)
f01043ad:	68 67 7e 10 f0       	push   $0xf0107e67
f01043b2:	e8 b1 f8 ff ff       	call   f0103c68 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01043b7:	83 c4 08             	add    $0x8,%esp
f01043ba:	ff 73 18             	pushl  0x18(%ebx)
f01043bd:	68 76 7e 10 f0       	push   $0xf0107e76
f01043c2:	e8 a1 f8 ff ff       	call   f0103c68 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01043c7:	83 c4 08             	add    $0x8,%esp
f01043ca:	ff 73 1c             	pushl  0x1c(%ebx)
f01043cd:	68 85 7e 10 f0       	push   $0xf0107e85
f01043d2:	e8 91 f8 ff ff       	call   f0103c68 <cprintf>
}
f01043d7:	83 c4 10             	add    $0x10,%esp
f01043da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01043dd:	c9                   	leave  
f01043de:	c3                   	ret    

f01043df <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f01043df:	55                   	push   %ebp
f01043e0:	89 e5                	mov    %esp,%ebp
f01043e2:	56                   	push   %esi
f01043e3:	53                   	push   %ebx
f01043e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01043e7:	e8 9e 1f 00 00       	call   f010638a <cpunum>
f01043ec:	83 ec 04             	sub    $0x4,%esp
f01043ef:	50                   	push   %eax
f01043f0:	53                   	push   %ebx
f01043f1:	68 e9 7e 10 f0       	push   $0xf0107ee9
f01043f6:	e8 6d f8 ff ff       	call   f0103c68 <cprintf>
	print_regs(&tf->tf_regs);
f01043fb:	89 1c 24             	mov    %ebx,(%esp)
f01043fe:	e8 4e ff ff ff       	call   f0104351 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0104403:	83 c4 08             	add    $0x8,%esp
f0104406:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f010440a:	50                   	push   %eax
f010440b:	68 07 7f 10 f0       	push   $0xf0107f07
f0104410:	e8 53 f8 ff ff       	call   f0103c68 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0104415:	83 c4 08             	add    $0x8,%esp
f0104418:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f010441c:	50                   	push   %eax
f010441d:	68 1a 7f 10 f0       	push   $0xf0107f1a
f0104422:	e8 41 f8 ff ff       	call   f0103c68 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104427:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f010442a:	83 c4 10             	add    $0x10,%esp
f010442d:	83 f8 13             	cmp    $0x13,%eax
f0104430:	77 09                	ja     f010443b <print_trapframe+0x5c>
		return excnames[trapno];
f0104432:	8b 14 85 c0 81 10 f0 	mov    -0xfef7e40(,%eax,4),%edx
f0104439:	eb 1f                	jmp    f010445a <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f010443b:	83 f8 30             	cmp    $0x30,%eax
f010443e:	74 15                	je     f0104455 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104440:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0104443:	83 fa 10             	cmp    $0x10,%edx
f0104446:	b9 b3 7e 10 f0       	mov    $0xf0107eb3,%ecx
f010444b:	ba a0 7e 10 f0       	mov    $0xf0107ea0,%edx
f0104450:	0f 43 d1             	cmovae %ecx,%edx
f0104453:	eb 05                	jmp    f010445a <print_trapframe+0x7b>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0104455:	ba 94 7e 10 f0       	mov    $0xf0107e94,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010445a:	83 ec 04             	sub    $0x4,%esp
f010445d:	52                   	push   %edx
f010445e:	50                   	push   %eax
f010445f:	68 2d 7f 10 f0       	push   $0xf0107f2d
f0104464:	e8 ff f7 ff ff       	call   f0103c68 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104469:	83 c4 10             	add    $0x10,%esp
f010446c:	3b 1d 60 8a 21 f0    	cmp    0xf0218a60,%ebx
f0104472:	75 1a                	jne    f010448e <print_trapframe+0xaf>
f0104474:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104478:	75 14                	jne    f010448e <print_trapframe+0xaf>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f010447a:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010447d:	83 ec 08             	sub    $0x8,%esp
f0104480:	50                   	push   %eax
f0104481:	68 3f 7f 10 f0       	push   $0xf0107f3f
f0104486:	e8 dd f7 ff ff       	call   f0103c68 <cprintf>
f010448b:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f010448e:	83 ec 08             	sub    $0x8,%esp
f0104491:	ff 73 2c             	pushl  0x2c(%ebx)
f0104494:	68 4e 7f 10 f0       	push   $0xf0107f4e
f0104499:	e8 ca f7 ff ff       	call   f0103c68 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f010449e:	83 c4 10             	add    $0x10,%esp
f01044a1:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01044a5:	75 49                	jne    f01044f0 <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f01044a7:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f01044aa:	89 c2                	mov    %eax,%edx
f01044ac:	83 e2 01             	and    $0x1,%edx
f01044af:	ba cd 7e 10 f0       	mov    $0xf0107ecd,%edx
f01044b4:	b9 c2 7e 10 f0       	mov    $0xf0107ec2,%ecx
f01044b9:	0f 44 ca             	cmove  %edx,%ecx
f01044bc:	89 c2                	mov    %eax,%edx
f01044be:	83 e2 02             	and    $0x2,%edx
f01044c1:	ba df 7e 10 f0       	mov    $0xf0107edf,%edx
f01044c6:	be d9 7e 10 f0       	mov    $0xf0107ed9,%esi
f01044cb:	0f 45 d6             	cmovne %esi,%edx
f01044ce:	83 e0 04             	and    $0x4,%eax
f01044d1:	be 46 80 10 f0       	mov    $0xf0108046,%esi
f01044d6:	b8 e4 7e 10 f0       	mov    $0xf0107ee4,%eax
f01044db:	0f 44 c6             	cmove  %esi,%eax
f01044de:	51                   	push   %ecx
f01044df:	52                   	push   %edx
f01044e0:	50                   	push   %eax
f01044e1:	68 5c 7f 10 f0       	push   $0xf0107f5c
f01044e6:	e8 7d f7 ff ff       	call   f0103c68 <cprintf>
f01044eb:	83 c4 10             	add    $0x10,%esp
f01044ee:	eb 10                	jmp    f0104500 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01044f0:	83 ec 0c             	sub    $0xc,%esp
f01044f3:	68 5a 82 10 f0       	push   $0xf010825a
f01044f8:	e8 6b f7 ff ff       	call   f0103c68 <cprintf>
f01044fd:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104500:	83 ec 08             	sub    $0x8,%esp
f0104503:	ff 73 30             	pushl  0x30(%ebx)
f0104506:	68 6b 7f 10 f0       	push   $0xf0107f6b
f010450b:	e8 58 f7 ff ff       	call   f0103c68 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104510:	83 c4 08             	add    $0x8,%esp
f0104513:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104517:	50                   	push   %eax
f0104518:	68 7a 7f 10 f0       	push   $0xf0107f7a
f010451d:	e8 46 f7 ff ff       	call   f0103c68 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104522:	83 c4 08             	add    $0x8,%esp
f0104525:	ff 73 38             	pushl  0x38(%ebx)
f0104528:	68 8d 7f 10 f0       	push   $0xf0107f8d
f010452d:	e8 36 f7 ff ff       	call   f0103c68 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104532:	83 c4 10             	add    $0x10,%esp
f0104535:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104539:	74 25                	je     f0104560 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010453b:	83 ec 08             	sub    $0x8,%esp
f010453e:	ff 73 3c             	pushl  0x3c(%ebx)
f0104541:	68 9c 7f 10 f0       	push   $0xf0107f9c
f0104546:	e8 1d f7 ff ff       	call   f0103c68 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010454b:	83 c4 08             	add    $0x8,%esp
f010454e:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104552:	50                   	push   %eax
f0104553:	68 ab 7f 10 f0       	push   $0xf0107fab
f0104558:	e8 0b f7 ff ff       	call   f0103c68 <cprintf>
f010455d:	83 c4 10             	add    $0x10,%esp
	}
}
f0104560:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104563:	5b                   	pop    %ebx
f0104564:	5e                   	pop    %esi
f0104565:	5d                   	pop    %ebp
f0104566:	c3                   	ret    

f0104567 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104567:	55                   	push   %ebp
f0104568:	89 e5                	mov    %esp,%ebp
f010456a:	57                   	push   %edi
f010456b:	56                   	push   %esi
f010456c:	53                   	push   %ebx
f010456d:	83 ec 0c             	sub    $0xc,%esp
f0104570:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104573:	0f 20 d6             	mov    %cr2,%esi

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.

	if ((tf->tf_cs & 3) == 0) {
f0104576:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010457a:	75 17                	jne    f0104593 <page_fault_handler+0x2c>
		panic("kernel page fault\n");
f010457c:	83 ec 04             	sub    $0x4,%esp
f010457f:	68 be 7f 10 f0       	push   $0xf0107fbe
f0104584:	68 5f 01 00 00       	push   $0x15f
f0104589:	68 d1 7f 10 f0       	push   $0xf0107fd1
f010458e:	e8 ad ba ff ff       	call   f0100040 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	if (curenv->env_pgfault_upcall) {
f0104593:	e8 f2 1d 00 00       	call   f010638a <cpunum>
f0104598:	6b c0 74             	imul   $0x74,%eax,%eax
f010459b:	8b 80 28 90 21 f0    	mov    -0xfde6fd8(%eax),%eax
f01045a1:	83 b8 98 00 00 00 00 	cmpl   $0x0,0x98(%eax)
f01045a8:	0f 84 aa 00 00 00    	je     f0104658 <page_fault_handler+0xf1>
		struct UTrapframe *utf;
		uintptr_t utf_va;
		if ((tf->tf_esp >= UXSTACKTOP - PGSIZE) && 
f01045ae:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01045b1:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
		    (tf->tf_esp < UXSTACKTOP)) {
			utf_va = tf->tf_esp - sizeof(struct UTrapframe) - 4;
f01045b7:	83 e8 38             	sub    $0x38,%eax
f01045ba:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f01045c0:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f01045c5:	0f 46 d0             	cmovbe %eax,%edx
f01045c8:	89 d7                	mov    %edx,%edi
		} else {
			utf_va = UXSTACKTOP - sizeof(struct UTrapframe);
		}
	
		user_mem_assert(curenv, (void*)utf_va, sizeof(struct UTrapframe), 					PTE_W);
f01045ca:	e8 bb 1d 00 00       	call   f010638a <cpunum>
f01045cf:	6a 02                	push   $0x2
f01045d1:	6a 34                	push   $0x34
f01045d3:	57                   	push   %edi
f01045d4:	6b c0 74             	imul   $0x74,%eax,%eax
f01045d7:	ff b0 28 90 21 f0    	pushl  -0xfde6fd8(%eax)
f01045dd:	e8 d3 e9 ff ff       	call   f0102fb5 <user_mem_assert>
		utf = (struct UTrapframe*) utf_va;

		utf->utf_fault_va = fault_va;
f01045e2:	89 fa                	mov    %edi,%edx
f01045e4:	89 37                	mov    %esi,(%edi)
		utf->utf_err = tf->tf_err;
f01045e6:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01045e9:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_regs = tf->tf_regs;
f01045ec:	8d 7f 08             	lea    0x8(%edi),%edi
f01045ef:	b9 08 00 00 00       	mov    $0x8,%ecx
f01045f4:	89 de                	mov    %ebx,%esi
f01045f6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eip = tf->tf_eip;
f01045f8:	8b 43 30             	mov    0x30(%ebx),%eax
f01045fb:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags = tf->tf_eflags;
f01045fe:	8b 43 38             	mov    0x38(%ebx),%eax
f0104601:	89 d7                	mov    %edx,%edi
f0104603:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;
f0104606:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104609:	89 42 30             	mov    %eax,0x30(%edx)

		curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f010460c:	e8 79 1d 00 00       	call   f010638a <cpunum>
f0104611:	6b c0 74             	imul   $0x74,%eax,%eax
f0104614:	8b 98 28 90 21 f0    	mov    -0xfde6fd8(%eax),%ebx
f010461a:	e8 6b 1d 00 00       	call   f010638a <cpunum>
f010461f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104622:	8b 80 28 90 21 f0    	mov    -0xfde6fd8(%eax),%eax
f0104628:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
f010462e:	89 43 64             	mov    %eax,0x64(%ebx)
		curenv->env_tf.tf_esp = utf_va;
f0104631:	e8 54 1d 00 00       	call   f010638a <cpunum>
f0104636:	6b c0 74             	imul   $0x74,%eax,%eax
f0104639:	8b 80 28 90 21 f0    	mov    -0xfde6fd8(%eax),%eax
f010463f:	89 78 70             	mov    %edi,0x70(%eax)
		env_run(curenv);
f0104642:	e8 43 1d 00 00       	call   f010638a <cpunum>
f0104647:	83 c4 04             	add    $0x4,%esp
f010464a:	6b c0 74             	imul   $0x74,%eax,%eax
f010464d:	ff b0 28 90 21 f0    	pushl  -0xfde6fd8(%eax)
f0104653:	e8 fd f1 ff ff       	call   f0103855 <env_run>
	}


	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104658:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f010465b:	e8 2a 1d 00 00       	call   f010638a <cpunum>
		env_run(curenv);
	}


	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104660:	57                   	push   %edi
f0104661:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0104662:	6b c0 74             	imul   $0x74,%eax,%eax
		env_run(curenv);
	}


	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104665:	8b 80 28 90 21 f0    	mov    -0xfde6fd8(%eax),%eax
f010466b:	ff 70 7c             	pushl  0x7c(%eax)
f010466e:	68 90 81 10 f0       	push   $0xf0108190
f0104673:	e8 f0 f5 ff ff       	call   f0103c68 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104678:	89 1c 24             	mov    %ebx,(%esp)
f010467b:	e8 5f fd ff ff       	call   f01043df <print_trapframe>
	env_destroy(curenv);
f0104680:	e8 05 1d 00 00       	call   f010638a <cpunum>
f0104685:	83 c4 04             	add    $0x4,%esp
f0104688:	6b c0 74             	imul   $0x74,%eax,%eax
f010468b:	ff b0 28 90 21 f0    	pushl  -0xfde6fd8(%eax)
f0104691:	e8 cf f0 ff ff       	call   f0103765 <env_destroy>
}
f0104696:	83 c4 10             	add    $0x10,%esp
f0104699:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010469c:	5b                   	pop    %ebx
f010469d:	5e                   	pop    %esi
f010469e:	5f                   	pop    %edi
f010469f:	5d                   	pop    %ebp
f01046a0:	c3                   	ret    

f01046a1 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01046a1:	55                   	push   %ebp
f01046a2:	89 e5                	mov    %esp,%ebp
f01046a4:	57                   	push   %edi
f01046a5:	56                   	push   %esi
f01046a6:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01046a9:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f01046aa:	83 3d 80 8e 21 f0 00 	cmpl   $0x0,0xf0218e80
f01046b1:	74 01                	je     f01046b4 <trap+0x13>
		asm volatile("hlt");
f01046b3:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01046b4:	e8 d1 1c 00 00       	call   f010638a <cpunum>
f01046b9:	6b d0 74             	imul   $0x74,%eax,%edx
f01046bc:	81 c2 20 90 21 f0    	add    $0xf0219020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01046c2:	b8 01 00 00 00       	mov    $0x1,%eax
f01046c7:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f01046cb:	83 f8 02             	cmp    $0x2,%eax
f01046ce:	75 10                	jne    f01046e0 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01046d0:	83 ec 0c             	sub    $0xc,%esp
f01046d3:	68 c0 23 12 f0       	push   $0xf01223c0
f01046d8:	e8 1b 1f 00 00       	call   f01065f8 <spin_lock>
f01046dd:	83 c4 10             	add    $0x10,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f01046e0:	9c                   	pushf  
f01046e1:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01046e2:	f6 c4 02             	test   $0x2,%ah
f01046e5:	74 19                	je     f0104700 <trap+0x5f>
f01046e7:	68 dd 7f 10 f0       	push   $0xf0107fdd
f01046ec:	68 54 79 10 f0       	push   $0xf0107954
f01046f1:	68 26 01 00 00       	push   $0x126
f01046f6:	68 d1 7f 10 f0       	push   $0xf0107fd1
f01046fb:	e8 40 b9 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104700:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104704:	83 e0 03             	and    $0x3,%eax
f0104707:	66 83 f8 03          	cmp    $0x3,%ax
f010470b:	0f 85 a7 00 00 00    	jne    f01047b8 <trap+0x117>
f0104711:	83 ec 0c             	sub    $0xc,%esp
f0104714:	68 c0 23 12 f0       	push   $0xf01223c0
f0104719:	e8 da 1e 00 00       	call   f01065f8 <spin_lock>
		// serious kernel work.
		// LAB 4: Your code here.

		lock_kernel();

		assert(curenv);
f010471e:	e8 67 1c 00 00       	call   f010638a <cpunum>
f0104723:	6b c0 74             	imul   $0x74,%eax,%eax
f0104726:	83 c4 10             	add    $0x10,%esp
f0104729:	83 b8 28 90 21 f0 00 	cmpl   $0x0,-0xfde6fd8(%eax)
f0104730:	75 19                	jne    f010474b <trap+0xaa>
f0104732:	68 f6 7f 10 f0       	push   $0xf0107ff6
f0104737:	68 54 79 10 f0       	push   $0xf0107954
f010473c:	68 30 01 00 00       	push   $0x130
f0104741:	68 d1 7f 10 f0       	push   $0xf0107fd1
f0104746:	e8 f5 b8 ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f010474b:	e8 3a 1c 00 00       	call   f010638a <cpunum>
f0104750:	6b c0 74             	imul   $0x74,%eax,%eax
f0104753:	8b 80 28 90 21 f0    	mov    -0xfde6fd8(%eax),%eax
f0104759:	83 b8 88 00 00 00 01 	cmpl   $0x1,0x88(%eax)
f0104760:	75 2d                	jne    f010478f <trap+0xee>
			env_free(curenv);
f0104762:	e8 23 1c 00 00       	call   f010638a <cpunum>
f0104767:	83 ec 0c             	sub    $0xc,%esp
f010476a:	6b c0 74             	imul   $0x74,%eax,%eax
f010476d:	ff b0 28 90 21 f0    	pushl  -0xfde6fd8(%eax)
f0104773:	e8 c2 ed ff ff       	call   f010353a <env_free>
			curenv = NULL;
f0104778:	e8 0d 1c 00 00       	call   f010638a <cpunum>
f010477d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104780:	c7 80 28 90 21 f0 00 	movl   $0x0,-0xfde6fd8(%eax)
f0104787:	00 00 00 
			sched_yield();
f010478a:	e8 53 03 00 00       	call   f0104ae2 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f010478f:	e8 f6 1b 00 00       	call   f010638a <cpunum>
f0104794:	6b c0 74             	imul   $0x74,%eax,%eax
f0104797:	8b b8 28 90 21 f0    	mov    -0xfde6fd8(%eax),%edi
f010479d:	83 c7 34             	add    $0x34,%edi
f01047a0:	b9 11 00 00 00       	mov    $0x11,%ecx
f01047a5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01047a7:	e8 de 1b 00 00       	call   f010638a <cpunum>
f01047ac:	6b c0 74             	imul   $0x74,%eax,%eax
f01047af:	8b b0 28 90 21 f0    	mov    -0xfde6fd8(%eax),%esi
f01047b5:	83 c6 34             	add    $0x34,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01047b8:	89 35 60 8a 21 f0    	mov    %esi,0xf0218a60
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.

	switch (tf->tf_trapno) {	
f01047be:	8b 46 28             	mov    0x28(%esi),%eax
f01047c1:	83 f8 0e             	cmp    $0xe,%eax
f01047c4:	74 0c                	je     f01047d2 <trap+0x131>
f01047c6:	83 f8 30             	cmp    $0x30,%eax
f01047c9:	74 38                	je     f0104803 <trap+0x162>
f01047cb:	83 f8 03             	cmp    $0x3,%eax
f01047ce:	75 57                	jne    f0104827 <trap+0x186>
f01047d0:	eb 11                	jmp    f01047e3 <trap+0x142>
	case T_PGFLT:
		page_fault_handler(tf);
f01047d2:	83 ec 0c             	sub    $0xc,%esp
f01047d5:	56                   	push   %esi
f01047d6:	e8 8c fd ff ff       	call   f0104567 <page_fault_handler>
f01047db:	83 c4 10             	add    $0x10,%esp
f01047de:	e9 cd 00 00 00       	jmp    f01048b0 <trap+0x20f>
		return;
	case T_BRKPT:
		print_trapframe(tf);
f01047e3:	83 ec 0c             	sub    $0xc,%esp
f01047e6:	56                   	push   %esi
f01047e7:	e8 f3 fb ff ff       	call   f01043df <print_trapframe>
		panic("tf->tf_trapno == T_BRKPT\n");
f01047ec:	83 c4 0c             	add    $0xc,%esp
f01047ef:	68 fd 7f 10 f0       	push   $0xf0107ffd
f01047f4:	68 e0 00 00 00       	push   $0xe0
f01047f9:	68 d1 7f 10 f0       	push   $0xf0107fd1
f01047fe:	e8 3d b8 ff ff       	call   f0100040 <_panic>
		return;
	case T_SYSCALL:
		tf->tf_regs.reg_eax = syscall(
f0104803:	83 ec 08             	sub    $0x8,%esp
f0104806:	ff 76 04             	pushl  0x4(%esi)
f0104809:	ff 36                	pushl  (%esi)
f010480b:	ff 76 10             	pushl  0x10(%esi)
f010480e:	ff 76 18             	pushl  0x18(%esi)
f0104811:	ff 76 14             	pushl  0x14(%esi)
f0104814:	ff 76 1c             	pushl  0x1c(%esi)
f0104817:	e8 ed 03 00 00       	call   f0104c09 <syscall>
f010481c:	89 46 1c             	mov    %eax,0x1c(%esi)
f010481f:	83 c4 20             	add    $0x20,%esp
f0104822:	e9 89 00 00 00       	jmp    f01048b0 <trap+0x20f>
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104827:	83 f8 27             	cmp    $0x27,%eax
f010482a:	75 1a                	jne    f0104846 <trap+0x1a5>
		cprintf("Spurious interrupt on irq 7\n");
f010482c:	83 ec 0c             	sub    $0xc,%esp
f010482f:	68 17 80 10 f0       	push   $0xf0108017
f0104834:	e8 2f f4 ff ff       	call   f0103c68 <cprintf>
		print_trapframe(tf);
f0104839:	89 34 24             	mov    %esi,(%esp)
f010483c:	e8 9e fb ff ff       	call   f01043df <print_trapframe>
f0104841:	83 c4 10             	add    $0x10,%esp
f0104844:	eb 6a                	jmp    f01048b0 <trap+0x20f>

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f0104846:	83 f8 20             	cmp    $0x20,%eax
f0104849:	75 0a                	jne    f0104855 <trap+0x1b4>
		lapic_eoi();
f010484b:	e8 85 1c 00 00       	call   f01064d5 <lapic_eoi>
		sched_yield();
f0104850:	e8 8d 02 00 00       	call   f0104ae2 <sched_yield>
	}

	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.

	if (tf->tf_trapno == (IRQ_OFFSET + IRQ_KBD)) {
f0104855:	83 f8 21             	cmp    $0x21,%eax
f0104858:	75 07                	jne    f0104861 <trap+0x1c0>
		kbd_intr();
f010485a:	e8 98 bd ff ff       	call   f01005f7 <kbd_intr>
f010485f:	eb 4f                	jmp    f01048b0 <trap+0x20f>
		return;
	}

	if (tf->tf_trapno == (IRQ_OFFSET + IRQ_SERIAL)) {
f0104861:	83 f8 24             	cmp    $0x24,%eax
f0104864:	75 07                	jne    f010486d <trap+0x1cc>
		serial_intr();
f0104866:	e8 70 bd ff ff       	call   f01005db <serial_intr>
f010486b:	eb 43                	jmp    f01048b0 <trap+0x20f>
		return;
	}

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f010486d:	83 ec 0c             	sub    $0xc,%esp
f0104870:	56                   	push   %esi
f0104871:	e8 69 fb ff ff       	call   f01043df <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104876:	83 c4 10             	add    $0x10,%esp
f0104879:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010487e:	75 17                	jne    f0104897 <trap+0x1f6>
		panic("unhandled trap in kernel");
f0104880:	83 ec 04             	sub    $0x4,%esp
f0104883:	68 34 80 10 f0       	push   $0xf0108034
f0104888:	68 0c 01 00 00       	push   $0x10c
f010488d:	68 d1 7f 10 f0       	push   $0xf0107fd1
f0104892:	e8 a9 b7 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104897:	e8 ee 1a 00 00       	call   f010638a <cpunum>
f010489c:	83 ec 0c             	sub    $0xc,%esp
f010489f:	6b c0 74             	imul   $0x74,%eax,%eax
f01048a2:	ff b0 28 90 21 f0    	pushl  -0xfde6fd8(%eax)
f01048a8:	e8 b8 ee ff ff       	call   f0103765 <env_destroy>
f01048ad:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f01048b0:	e8 d5 1a 00 00       	call   f010638a <cpunum>
f01048b5:	6b c0 74             	imul   $0x74,%eax,%eax
f01048b8:	83 b8 28 90 21 f0 00 	cmpl   $0x0,-0xfde6fd8(%eax)
f01048bf:	74 2d                	je     f01048ee <trap+0x24d>
f01048c1:	e8 c4 1a 00 00       	call   f010638a <cpunum>
f01048c6:	6b c0 74             	imul   $0x74,%eax,%eax
f01048c9:	8b 80 28 90 21 f0    	mov    -0xfde6fd8(%eax),%eax
f01048cf:	83 b8 88 00 00 00 03 	cmpl   $0x3,0x88(%eax)
f01048d6:	75 16                	jne    f01048ee <trap+0x24d>
		env_run(curenv);
f01048d8:	e8 ad 1a 00 00       	call   f010638a <cpunum>
f01048dd:	83 ec 0c             	sub    $0xc,%esp
f01048e0:	6b c0 74             	imul   $0x74,%eax,%eax
f01048e3:	ff b0 28 90 21 f0    	pushl  -0xfde6fd8(%eax)
f01048e9:	e8 67 ef ff ff       	call   f0103855 <env_run>
	else
		sched_yield();
f01048ee:	e8 ef 01 00 00       	call   f0104ae2 <sched_yield>
f01048f3:	90                   	nop

f01048f4 <TH_DIVIDE>:
	.p2align 2
	.globl TRAPHANDLERS
TRAPHANDLERS:
.text

TRAPHANDLER_NOEC(TH_DIVIDE, T_DIVIDE)	// fault
f01048f4:	6a 00                	push   $0x0
f01048f6:	6a 00                	push   $0x0
f01048f8:	e9 f9 00 00 00       	jmp    f01049f6 <_alltraps>
f01048fd:	90                   	nop

f01048fe <TH_DEBUG>:
TRAPHANDLER_NOEC(TH_DEBUG, T_DEBUG)	// fault/trap
f01048fe:	6a 00                	push   $0x0
f0104900:	6a 01                	push   $0x1
f0104902:	e9 ef 00 00 00       	jmp    f01049f6 <_alltraps>
f0104907:	90                   	nop

f0104908 <TH_NMI>:
TRAPHANDLER_NOEC(TH_NMI, T_NMI)		//
f0104908:	6a 00                	push   $0x0
f010490a:	6a 02                	push   $0x2
f010490c:	e9 e5 00 00 00       	jmp    f01049f6 <_alltraps>
f0104911:	90                   	nop

f0104912 <TH_BRKPT>:
TRAPHANDLER_NOEC(TH_BRKPT, T_BRKPT)	// trap
f0104912:	6a 00                	push   $0x0
f0104914:	6a 03                	push   $0x3
f0104916:	e9 db 00 00 00       	jmp    f01049f6 <_alltraps>
f010491b:	90                   	nop

f010491c <TH_OFLOW>:
TRAPHANDLER_NOEC(TH_OFLOW, T_OFLOW)	// trap
f010491c:	6a 00                	push   $0x0
f010491e:	6a 04                	push   $0x4
f0104920:	e9 d1 00 00 00       	jmp    f01049f6 <_alltraps>
f0104925:	90                   	nop

f0104926 <TH_BOUND>:
TRAPHANDLER_NOEC(TH_BOUND, T_BOUND)	// fault
f0104926:	6a 00                	push   $0x0
f0104928:	6a 05                	push   $0x5
f010492a:	e9 c7 00 00 00       	jmp    f01049f6 <_alltraps>
f010492f:	90                   	nop

f0104930 <TH_ILLOP>:
TRAPHANDLER_NOEC(TH_ILLOP, T_ILLOP)	// fault
f0104930:	6a 00                	push   $0x0
f0104932:	6a 06                	push   $0x6
f0104934:	e9 bd 00 00 00       	jmp    f01049f6 <_alltraps>
f0104939:	90                   	nop

f010493a <TH_DEVICE>:
TRAPHANDLER_NOEC(TH_DEVICE, T_DEVICE)	// fault
f010493a:	6a 00                	push   $0x0
f010493c:	6a 07                	push   $0x7
f010493e:	e9 b3 00 00 00       	jmp    f01049f6 <_alltraps>
f0104943:	90                   	nop

f0104944 <TH_DBLFLT>:
TRAPHANDLER     (TH_DBLFLT, T_DBLFLT)	// abort
f0104944:	6a 08                	push   $0x8
f0104946:	e9 ab 00 00 00       	jmp    f01049f6 <_alltraps>
f010494b:	90                   	nop

f010494c <TH_TSS>:
//TRAPHANDLER_NOEC(TH_COPROC, T_COPROC) // abort	
TRAPHANDLER     (TH_TSS, T_TSS)		// fault
f010494c:	6a 0a                	push   $0xa
f010494e:	e9 a3 00 00 00       	jmp    f01049f6 <_alltraps>
f0104953:	90                   	nop

f0104954 <TH_SEGNP>:
TRAPHANDLER     (TH_SEGNP, T_SEGNP)	// fault
f0104954:	6a 0b                	push   $0xb
f0104956:	e9 9b 00 00 00       	jmp    f01049f6 <_alltraps>
f010495b:	90                   	nop

f010495c <TH_STACK>:
TRAPHANDLER     (TH_STACK, T_STACK)	// fault
f010495c:	6a 0c                	push   $0xc
f010495e:	e9 93 00 00 00       	jmp    f01049f6 <_alltraps>
f0104963:	90                   	nop

f0104964 <TH_GPFLT>:
TRAPHANDLER     (TH_GPFLT, T_GPFLT)	// fault/abort
f0104964:	6a 0d                	push   $0xd
f0104966:	e9 8b 00 00 00       	jmp    f01049f6 <_alltraps>
f010496b:	90                   	nop

f010496c <TH_PGFLT>:
TRAPHANDLER     (TH_PGFLT, T_PGFLT)	// fault
f010496c:	6a 0e                	push   $0xe
f010496e:	e9 83 00 00 00       	jmp    f01049f6 <_alltraps>
f0104973:	90                   	nop

f0104974 <TH_FPERR>:
//TRAPHANDLER_NOEC(TH_RES, T_RES)	
TRAPHANDLER_NOEC(TH_FPERR, T_FPERR)	// fault
f0104974:	6a 00                	push   $0x0
f0104976:	6a 10                	push   $0x10
f0104978:	eb 7c                	jmp    f01049f6 <_alltraps>

f010497a <TH_ALIGN>:
TRAPHANDLER     (TH_ALIGN, T_ALIGN)	//
f010497a:	6a 11                	push   $0x11
f010497c:	eb 78                	jmp    f01049f6 <_alltraps>

f010497e <TH_MCHK>:
TRAPHANDLER_NOEC(TH_MCHK, T_MCHK)	//
f010497e:	6a 00                	push   $0x0
f0104980:	6a 12                	push   $0x12
f0104982:	eb 72                	jmp    f01049f6 <_alltraps>

f0104984 <TH_SIMDERR>:
TRAPHANDLER_NOEC(TH_SIMDERR, T_SIMDERR) //
f0104984:	6a 00                	push   $0x0
f0104986:	6a 13                	push   $0x13
f0104988:	eb 6c                	jmp    f01049f6 <_alltraps>

f010498a <TH_SYSCALL>:

TRAPHANDLER_NOEC(TH_SYSCALL, T_SYSCALL) // trap
f010498a:	6a 00                	push   $0x0
f010498c:	6a 30                	push   $0x30
f010498e:	eb 66                	jmp    f01049f6 <_alltraps>

f0104990 <TH_IRQ_TIMER>:

TRAPHANDLER_NOEC(TH_IRQ_TIMER, IRQ_OFFSET+IRQ_TIMER)	// 0
f0104990:	6a 00                	push   $0x0
f0104992:	6a 20                	push   $0x20
f0104994:	eb 60                	jmp    f01049f6 <_alltraps>

f0104996 <TH_IRQ_KBD>:
TRAPHANDLER_NOEC(TH_IRQ_KBD, IRQ_OFFSET+IRQ_KBD)	// 1
f0104996:	6a 00                	push   $0x0
f0104998:	6a 21                	push   $0x21
f010499a:	eb 5a                	jmp    f01049f6 <_alltraps>

f010499c <TH_IRQ_2>:
TRAPHANDLER_NOEC(TH_IRQ_2, IRQ_OFFSET+2)
f010499c:	6a 00                	push   $0x0
f010499e:	6a 22                	push   $0x22
f01049a0:	eb 54                	jmp    f01049f6 <_alltraps>

f01049a2 <TH_IRQ_3>:
TRAPHANDLER_NOEC(TH_IRQ_3, IRQ_OFFSET+3)
f01049a2:	6a 00                	push   $0x0
f01049a4:	6a 23                	push   $0x23
f01049a6:	eb 4e                	jmp    f01049f6 <_alltraps>

f01049a8 <TH_IRQ_SERIAL>:
TRAPHANDLER_NOEC(TH_IRQ_SERIAL, IRQ_OFFSET+IRQ_SERIAL)	// 4
f01049a8:	6a 00                	push   $0x0
f01049aa:	6a 24                	push   $0x24
f01049ac:	eb 48                	jmp    f01049f6 <_alltraps>

f01049ae <TH_IRQ_5>:
TRAPHANDLER_NOEC(TH_IRQ_5, IRQ_OFFSET+5)
f01049ae:	6a 00                	push   $0x0
f01049b0:	6a 25                	push   $0x25
f01049b2:	eb 42                	jmp    f01049f6 <_alltraps>

f01049b4 <TH_IRQ_6>:
TRAPHANDLER_NOEC(TH_IRQ_6, IRQ_OFFSET+6)
f01049b4:	6a 00                	push   $0x0
f01049b6:	6a 26                	push   $0x26
f01049b8:	eb 3c                	jmp    f01049f6 <_alltraps>

f01049ba <TH_IRQ_SPURIOUS>:
TRAPHANDLER_NOEC(TH_IRQ_SPURIOUS, IRQ_OFFSET+IRQ_SPURIOUS) // 7
f01049ba:	6a 00                	push   $0x0
f01049bc:	6a 27                	push   $0x27
f01049be:	eb 36                	jmp    f01049f6 <_alltraps>

f01049c0 <TH_IRQ_8>:
TRAPHANDLER_NOEC(TH_IRQ_8, IRQ_OFFSET+8)
f01049c0:	6a 00                	push   $0x0
f01049c2:	6a 28                	push   $0x28
f01049c4:	eb 30                	jmp    f01049f6 <_alltraps>

f01049c6 <TH_IRQ_9>:
TRAPHANDLER_NOEC(TH_IRQ_9, IRQ_OFFSET+9)
f01049c6:	6a 00                	push   $0x0
f01049c8:	6a 29                	push   $0x29
f01049ca:	eb 2a                	jmp    f01049f6 <_alltraps>

f01049cc <TH_IRQ_10>:
TRAPHANDLER_NOEC(TH_IRQ_10, IRQ_OFFSET+10)
f01049cc:	6a 00                	push   $0x0
f01049ce:	6a 2a                	push   $0x2a
f01049d0:	eb 24                	jmp    f01049f6 <_alltraps>

f01049d2 <TH_IRQ_11>:
TRAPHANDLER_NOEC(TH_IRQ_11, IRQ_OFFSET+11)
f01049d2:	6a 00                	push   $0x0
f01049d4:	6a 2b                	push   $0x2b
f01049d6:	eb 1e                	jmp    f01049f6 <_alltraps>

f01049d8 <TH_IRQ_12>:
TRAPHANDLER_NOEC(TH_IRQ_12, IRQ_OFFSET+12)
f01049d8:	6a 00                	push   $0x0
f01049da:	6a 2c                	push   $0x2c
f01049dc:	eb 18                	jmp    f01049f6 <_alltraps>

f01049de <TH_IRQ_13>:
TRAPHANDLER_NOEC(TH_IRQ_13, IRQ_OFFSET+13)
f01049de:	6a 00                	push   $0x0
f01049e0:	6a 2d                	push   $0x2d
f01049e2:	eb 12                	jmp    f01049f6 <_alltraps>

f01049e4 <TH_IRQ_IDE>:
TRAPHANDLER_NOEC(TH_IRQ_IDE, IRQ_OFFSET+IRQ_IDE)	// 14
f01049e4:	6a 00                	push   $0x0
f01049e6:	6a 2e                	push   $0x2e
f01049e8:	eb 0c                	jmp    f01049f6 <_alltraps>

f01049ea <TH_IRQ_15>:
TRAPHANDLER_NOEC(TH_IRQ_15, IRQ_OFFSET+15)
f01049ea:	6a 00                	push   $0x0
f01049ec:	6a 2f                	push   $0x2f
f01049ee:	eb 06                	jmp    f01049f6 <_alltraps>

f01049f0 <TH_IRQ_ERROR>:
TRAPHANDLER_NOEC(TH_IRQ_ERROR, IRQ_OFFSET+IRQ_ERROR)	// 19
f01049f0:	6a 00                	push   $0x0
f01049f2:	6a 33                	push   $0x33
f01049f4:	eb 00                	jmp    f01049f6 <_alltraps>

f01049f6 <_alltraps>:
 * Lab 3: Your code here for _alltraps
 */

.text
_alltraps:
	pushl	%ds
f01049f6:	1e                   	push   %ds
	pushl	%es
f01049f7:	06                   	push   %es
	pushal
f01049f8:	60                   	pusha  
	mov	$GD_KD, %eax
f01049f9:	b8 10 00 00 00       	mov    $0x10,%eax
	mov	%ax, %es
f01049fe:	8e c0                	mov    %eax,%es
	mov	%ax, %ds
f0104a00:	8e d8                	mov    %eax,%ds
	pushl	%esp
f0104a02:	54                   	push   %esp
	call	trap
f0104a03:	e8 99 fc ff ff       	call   f01046a1 <trap>

f0104a08 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104a08:	55                   	push   %ebp
f0104a09:	89 e5                	mov    %esp,%ebp
f0104a0b:	83 ec 08             	sub    $0x8,%esp
f0104a0e:	a1 4c 82 21 f0       	mov    0xf021824c,%eax
f0104a13:	8d 90 88 00 00 00    	lea    0x88(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104a19:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104a1e:	8b 02                	mov    (%edx),%eax
f0104a20:	83 e8 01             	sub    $0x1,%eax
f0104a23:	83 f8 02             	cmp    $0x2,%eax
f0104a26:	76 13                	jbe    f0104a3b <sched_halt+0x33>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104a28:	83 c1 01             	add    $0x1,%ecx
f0104a2b:	81 c2 b0 00 00 00    	add    $0xb0,%edx
f0104a31:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104a37:	75 e5                	jne    f0104a1e <sched_halt+0x16>
f0104a39:	eb 08                	jmp    f0104a43 <sched_halt+0x3b>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104a3b:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104a41:	75 1f                	jne    f0104a62 <sched_halt+0x5a>
		cprintf("No runnable environments in the system!\n");
f0104a43:	83 ec 0c             	sub    $0xc,%esp
f0104a46:	68 10 82 10 f0       	push   $0xf0108210
f0104a4b:	e8 18 f2 ff ff       	call   f0103c68 <cprintf>
f0104a50:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104a53:	83 ec 0c             	sub    $0xc,%esp
f0104a56:	6a 00                	push   $0x0
f0104a58:	e8 f8 be ff ff       	call   f0100955 <monitor>
f0104a5d:	83 c4 10             	add    $0x10,%esp
f0104a60:	eb f1                	jmp    f0104a53 <sched_halt+0x4b>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104a62:	e8 23 19 00 00       	call   f010638a <cpunum>
f0104a67:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a6a:	c7 80 28 90 21 f0 00 	movl   $0x0,-0xfde6fd8(%eax)
f0104a71:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104a74:	a1 8c 8e 21 f0       	mov    0xf0218e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104a79:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104a7e:	77 12                	ja     f0104a92 <sched_halt+0x8a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104a80:	50                   	push   %eax
f0104a81:	68 68 6a 10 f0       	push   $0xf0106a68
f0104a86:	6a 7b                	push   $0x7b
f0104a88:	68 39 82 10 f0       	push   $0xf0108239
f0104a8d:	e8 ae b5 ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104a92:	05 00 00 00 10       	add    $0x10000000,%eax
f0104a97:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104a9a:	e8 eb 18 00 00       	call   f010638a <cpunum>
f0104a9f:	6b d0 74             	imul   $0x74,%eax,%edx
f0104aa2:	81 c2 20 90 21 f0    	add    $0xf0219020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104aa8:	b8 02 00 00 00       	mov    $0x2,%eax
f0104aad:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104ab1:	83 ec 0c             	sub    $0xc,%esp
f0104ab4:	68 c0 23 12 f0       	push   $0xf01223c0
f0104ab9:	e8 d7 1b 00 00       	call   f0106695 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104abe:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104ac0:	e8 c5 18 00 00       	call   f010638a <cpunum>
f0104ac5:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104ac8:	8b 80 30 90 21 f0    	mov    -0xfde6fd0(%eax),%eax
f0104ace:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104ad3:	89 c4                	mov    %eax,%esp
f0104ad5:	6a 00                	push   $0x0
f0104ad7:	6a 00                	push   $0x0
f0104ad9:	fb                   	sti    
f0104ada:	f4                   	hlt    
f0104adb:	eb fd                	jmp    f0104ada <sched_halt+0xd2>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104add:	83 c4 10             	add    $0x10,%esp
f0104ae0:	c9                   	leave  
f0104ae1:	c3                   	ret    

f0104ae2 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104ae2:	55                   	push   %ebp
f0104ae3:	89 e5                	mov    %esp,%ebp
f0104ae5:	53                   	push   %ebx
f0104ae6:	83 ec 10             	sub    $0x10,%esp
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	cprintf ("IN SCHED.C YIELDING\n\n");
f0104ae9:	68 46 82 10 f0       	push   $0xf0108246
f0104aee:	e8 75 f1 ff ff       	call   f0103c68 <cprintf>
	size_t i;
	if (!curenv) {
f0104af3:	e8 92 18 00 00       	call   f010638a <cpunum>
f0104af8:	6b c0 74             	imul   $0x74,%eax,%eax
f0104afb:	83 c4 10             	add    $0x10,%esp
		i = 0;
f0104afe:	ba 00 00 00 00       	mov    $0x0,%edx
	// below to halt the cpu.

	// LAB 4: Your code here.
	cprintf ("IN SCHED.C YIELDING\n\n");
	size_t i;
	if (!curenv) {
f0104b03:	83 b8 28 90 21 f0 00 	cmpl   $0x0,-0xfde6fd8(%eax)
f0104b0a:	74 1a                	je     f0104b26 <sched_yield+0x44>
		i = 0;
	} else {
		i = ENVX(curenv->env_id) + 1;
f0104b0c:	e8 79 18 00 00       	call   f010638a <cpunum>
f0104b11:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b14:	8b 80 28 90 21 f0    	mov    -0xfde6fd8(%eax),%eax
f0104b1a:	8b 50 7c             	mov    0x7c(%eax),%edx
f0104b1d:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0104b23:	83 c2 01             	add    $0x1,%edx
	}
	// Lab 7 Multithreading: scheduler verzia 1.0 
	for (; i < NENV; i++) {
		if (envs[i].env_status == ENV_RUNNABLE) {
f0104b26:	a1 4c 82 21 f0       	mov    0xf021824c,%eax
f0104b2b:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
f0104b31:	01 c1                	add    %eax,%ecx
f0104b33:	eb 1a                	jmp    f0104b4f <sched_yield+0x6d>
f0104b35:	89 cb                	mov    %ecx,%ebx
f0104b37:	81 c1 b0 00 00 00    	add    $0xb0,%ecx
f0104b3d:	83 79 d8 02          	cmpl   $0x2,-0x28(%ecx)
f0104b41:	75 09                	jne    f0104b4c <sched_yield+0x6a>
			env_run(&envs[i]);
f0104b43:	83 ec 0c             	sub    $0xc,%esp
f0104b46:	53                   	push   %ebx
f0104b47:	e8 09 ed ff ff       	call   f0103855 <env_run>
		i = 0;
	} else {
		i = ENVX(curenv->env_id) + 1;
	}
	// Lab 7 Multithreading: scheduler verzia 1.0 
	for (; i < NENV; i++) {
f0104b4c:	83 c2 01             	add    $0x1,%edx
f0104b4f:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
f0104b55:	76 de                	jbe    f0104b35 <sched_yield+0x53>
f0104b57:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104b5c:	eb 19                	jmp    f0104b77 <sched_yield+0x95>
	}

	size_t j;

	for (j = 0; j < i; j++) {
		if (envs[j].env_status == ENV_RUNNABLE) {
f0104b5e:	89 c3                	mov    %eax,%ebx
f0104b60:	05 b0 00 00 00       	add    $0xb0,%eax
f0104b65:	83 78 d8 02          	cmpl   $0x2,-0x28(%eax)
f0104b69:	75 09                	jne    f0104b74 <sched_yield+0x92>
			env_run(&envs[j]);
f0104b6b:	83 ec 0c             	sub    $0xc,%esp
f0104b6e:	53                   	push   %ebx
f0104b6f:	e8 e1 ec ff ff       	call   f0103855 <env_run>
		} 
	}

	size_t j;

	for (j = 0; j < i; j++) {
f0104b74:	83 c1 01             	add    $0x1,%ecx
f0104b77:	39 ca                	cmp    %ecx,%edx
f0104b79:	75 e3                	jne    f0104b5e <sched_yield+0x7c>
				else
					env_destroy(&envs[j]);
			}
		} 
	}*/
	if (curenv && (curenv->env_status == ENV_RUNNING)) {
f0104b7b:	e8 0a 18 00 00       	call   f010638a <cpunum>
f0104b80:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b83:	83 b8 28 90 21 f0 00 	cmpl   $0x0,-0xfde6fd8(%eax)
f0104b8a:	74 2d                	je     f0104bb9 <sched_yield+0xd7>
f0104b8c:	e8 f9 17 00 00       	call   f010638a <cpunum>
f0104b91:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b94:	8b 80 28 90 21 f0    	mov    -0xfde6fd8(%eax),%eax
f0104b9a:	83 b8 88 00 00 00 03 	cmpl   $0x3,0x88(%eax)
f0104ba1:	75 16                	jne    f0104bb9 <sched_yield+0xd7>
		env_run(curenv);
f0104ba3:	e8 e2 17 00 00       	call   f010638a <cpunum>
f0104ba8:	83 ec 0c             	sub    $0xc,%esp
f0104bab:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bae:	ff b0 28 90 21 f0    	pushl  -0xfde6fd8(%eax)
f0104bb4:	e8 9c ec ff ff       	call   f0103855 <env_run>
	}

	// sched_halt never returns
	sched_halt();
f0104bb9:	e8 4a fe ff ff       	call   f0104a08 <sched_halt>
}
f0104bbe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104bc1:	c9                   	leave  
f0104bc2:	c3                   	ret    

f0104bc3 <sys_thread_create>:

// Lab 7 Multithreading 
// zavola tvorbu noveho threadu (z env.c)
envid_t	
sys_thread_create(uintptr_t func)
{
f0104bc3:	55                   	push   %ebp
f0104bc4:	89 e5                	mov    %esp,%ebp
f0104bc6:	53                   	push   %ebx
f0104bc7:	83 ec 0c             	sub    $0xc,%esp
f0104bca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("in sys thread create, eip: %x\n", func);
f0104bcd:	53                   	push   %ebx
f0104bce:	68 5c 82 10 f0       	push   $0xf010825c
f0104bd3:	e8 90 f0 ff ff       	call   f0103c68 <cprintf>

	envid_t id = thread_create(func);
f0104bd8:	89 1c 24             	mov    %ebx,(%esp)
f0104bdb:	e8 11 ee ff ff       	call   f01039f1 <thread_create>
	return id;
}	
f0104be0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104be3:	c9                   	leave  
f0104be4:	c3                   	ret    

f0104be5 <sys_thread_free>:


void 	
sys_thread_free(envid_t envid)
{
f0104be5:	55                   	push   %ebp
f0104be6:	89 e5                	mov    %esp,%ebp
f0104be8:	83 ec 1c             	sub    $0x1c,%esp
	struct Env* e;
	envid2env(envid, &e, 0);
f0104beb:	6a 00                	push   $0x0
f0104bed:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104bf0:	50                   	push   %eax
f0104bf1:	ff 75 08             	pushl  0x8(%ebp)
f0104bf4:	e8 c3 e4 ff ff       	call   f01030bc <envid2env>
	thread_free(e);
f0104bf9:	83 c4 04             	add    $0x4,%esp
f0104bfc:	ff 75 f4             	pushl  -0xc(%ebp)
f0104bff:	e8 46 ed ff ff       	call   f010394a <thread_free>
}
f0104c04:	83 c4 10             	add    $0x10,%esp
f0104c07:	c9                   	leave  
f0104c08:	c3                   	ret    

f0104c09 <syscall>:

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104c09:	55                   	push   %ebp
f0104c0a:	89 e5                	mov    %esp,%ebp
f0104c0c:	57                   	push   %edi
f0104c0d:	56                   	push   %esi
f0104c0e:	83 ec 10             	sub    $0x10,%esp
f0104c11:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno) {
f0104c14:	83 f8 0f             	cmp    $0xf,%eax
f0104c17:	0f 87 5c 06 00 00    	ja     f0105279 <syscall+0x670>
f0104c1d:	ff 24 85 b4 82 10 f0 	jmp    *-0xfef7d4c(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, PTE_U);
f0104c24:	e8 61 17 00 00       	call   f010638a <cpunum>
f0104c29:	6a 04                	push   $0x4
f0104c2b:	ff 75 10             	pushl  0x10(%ebp)
f0104c2e:	ff 75 0c             	pushl  0xc(%ebp)
f0104c31:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c34:	ff b0 28 90 21 f0    	pushl  -0xfde6fd8(%eax)
f0104c3a:	e8 76 e3 ff ff       	call   f0102fb5 <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104c3f:	83 c4 0c             	add    $0xc,%esp
f0104c42:	ff 75 0c             	pushl  0xc(%ebp)
f0104c45:	ff 75 10             	pushl  0x10(%ebp)
f0104c48:	68 7b 82 10 f0       	push   $0xf010827b
f0104c4d:	e8 16 f0 ff ff       	call   f0103c68 <cprintf>
f0104c52:	83 c4 10             	add    $0x10,%esp
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((char*)a1, a2);
			return 0;
f0104c55:	b8 00 00 00 00       	mov    $0x0,%eax
f0104c5a:	e9 26 06 00 00       	jmp    f0105285 <syscall+0x67c>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104c5f:	e8 a5 b9 ff ff       	call   f0100609 <cons_getc>
		case SYS_cputs:
			sys_cputs((char*)a1, a2);
			return 0;

		case SYS_cgetc:
			return sys_cgetc();
f0104c64:	e9 1c 06 00 00       	jmp    f0105285 <syscall+0x67c>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104c69:	e8 1c 17 00 00       	call   f010638a <cpunum>
f0104c6e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c71:	8b 80 28 90 21 f0    	mov    -0xfde6fd8(%eax),%eax
f0104c77:	8b 40 7c             	mov    0x7c(%eax),%eax

		case SYS_cgetc:
			return sys_cgetc();

		case SYS_getenvid:
			return sys_getenvid();
f0104c7a:	e9 06 06 00 00       	jmp    f0105285 <syscall+0x67c>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104c7f:	83 ec 04             	sub    $0x4,%esp
f0104c82:	6a 01                	push   $0x1
f0104c84:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104c87:	50                   	push   %eax
f0104c88:	ff 75 0c             	pushl  0xc(%ebp)
f0104c8b:	e8 2c e4 ff ff       	call   f01030bc <envid2env>
f0104c90:	83 c4 10             	add    $0x10,%esp
f0104c93:	85 c0                	test   %eax,%eax
f0104c95:	0f 88 ea 05 00 00    	js     f0105285 <syscall+0x67c>
		return r;
	if (e == curenv)
f0104c9b:	e8 ea 16 00 00       	call   f010638a <cpunum>
f0104ca0:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104ca3:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ca6:	39 90 28 90 21 f0    	cmp    %edx,-0xfde6fd8(%eax)
f0104cac:	75 23                	jne    f0104cd1 <syscall+0xc8>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104cae:	e8 d7 16 00 00       	call   f010638a <cpunum>
f0104cb3:	83 ec 08             	sub    $0x8,%esp
f0104cb6:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cb9:	8b 80 28 90 21 f0    	mov    -0xfde6fd8(%eax),%eax
f0104cbf:	ff 70 7c             	pushl  0x7c(%eax)
f0104cc2:	68 80 82 10 f0       	push   $0xf0108280
f0104cc7:	e8 9c ef ff ff       	call   f0103c68 <cprintf>
f0104ccc:	83 c4 10             	add    $0x10,%esp
f0104ccf:	eb 25                	jmp    f0104cf6 <syscall+0xed>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104cd1:	8b 72 7c             	mov    0x7c(%edx),%esi
f0104cd4:	e8 b1 16 00 00       	call   f010638a <cpunum>
f0104cd9:	83 ec 04             	sub    $0x4,%esp
f0104cdc:	56                   	push   %esi
f0104cdd:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ce0:	8b 80 28 90 21 f0    	mov    -0xfde6fd8(%eax),%eax
f0104ce6:	ff 70 7c             	pushl  0x7c(%eax)
f0104ce9:	68 9b 82 10 f0       	push   $0xf010829b
f0104cee:	e8 75 ef ff ff       	call   f0103c68 <cprintf>
f0104cf3:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104cf6:	83 ec 0c             	sub    $0xc,%esp
f0104cf9:	ff 75 f4             	pushl  -0xc(%ebp)
f0104cfc:	e8 64 ea ff ff       	call   f0103765 <env_destroy>
f0104d01:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104d04:	b8 00 00 00 00       	mov    $0x0,%eax
f0104d09:	e9 77 05 00 00       	jmp    f0105285 <syscall+0x67c>
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	// check if va is page aligned and isnt above UTOP
	if ((((int)va % PGSIZE) != 0) || ((uintptr_t)va >= UTOP)) {
f0104d0e:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104d15:	0f 85 87 00 00 00    	jne    f0104da2 <syscall+0x199>
f0104d1b:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104d22:	77 7e                	ja     f0104da2 <syscall+0x199>
		return -E_INVAL;
	}
	// check if PTE_P and PTE_U are set (must be set)
	if (((PTE_P | PTE_U) & perm) != (PTE_U | PTE_P)) { 
f0104d24:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d27:	83 e0 05             	and    $0x5,%eax
f0104d2a:	83 f8 05             	cmp    $0x5,%eax
f0104d2d:	75 7d                	jne    f0104dac <syscall+0x1a3>
	}
	
	int to_check = perm | PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	int available_perm = PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	// check if no other bits hev bin(where the trash goes) set 
	if ((available_perm ^ to_check) != 0) {
f0104d2f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d32:	0d 07 0e 00 00       	or     $0xe07,%eax
f0104d37:	3d 07 0e 00 00       	cmp    $0xe07,%eax
f0104d3c:	75 78                	jne    f0104db6 <syscall+0x1ad>
		return -E_INVAL;
	}

	struct PageInfo *new_page = page_alloc(ALLOC_ZERO);
f0104d3e:	83 ec 0c             	sub    $0xc,%esp
f0104d41:	6a 01                	push   $0x1
f0104d43:	e8 74 c2 ff ff       	call   f0100fbc <page_alloc>
f0104d48:	89 c6                	mov    %eax,%esi
	// page alloc return null if there are no free pages on page_free_list
	if (!new_page) {
f0104d4a:	83 c4 10             	add    $0x10,%esp
f0104d4d:	85 c0                	test   %eax,%eax
f0104d4f:	74 6f                	je     f0104dc0 <syscall+0x1b7>
		return -E_NO_MEM;
	}

	struct Env *e;
	int retperm = envid2env(envid, &e, true);
f0104d51:	83 ec 04             	sub    $0x4,%esp
f0104d54:	6a 01                	push   $0x1
f0104d56:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104d59:	50                   	push   %eax
f0104d5a:	ff 75 0c             	pushl  0xc(%ebp)
f0104d5d:	e8 5a e3 ff ff       	call   f01030bc <envid2env>

	//nechce sa mi uz
	if (retperm) {
f0104d62:	83 c4 10             	add    $0x10,%esp
f0104d65:	85 c0                	test   %eax,%eax
f0104d67:	0f 85 18 05 00 00    	jne    f0105285 <syscall+0x67c>
		return retperm;
	}	

	int pg_insert_check = page_insert(e->env_pgdir, new_page, va, perm);
f0104d6d:	ff 75 14             	pushl  0x14(%ebp)
f0104d70:	ff 75 10             	pushl  0x10(%ebp)
f0104d73:	56                   	push   %esi
f0104d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104d77:	ff b0 94 00 00 00    	pushl  0x94(%eax)
f0104d7d:	e8 eb c5 ff ff       	call   f010136d <page_insert>
f0104d82:	89 c7                	mov    %eax,%edi
	
	if (pg_insert_check) {
f0104d84:	83 c4 10             	add    $0x10,%esp
f0104d87:	85 c0                	test   %eax,%eax
f0104d89:	0f 84 f6 04 00 00    	je     f0105285 <syscall+0x67c>
		page_free(new_page);
f0104d8f:	83 ec 0c             	sub    $0xc,%esp
f0104d92:	56                   	push   %esi
f0104d93:	e8 94 c2 ff ff       	call   f010102c <page_free>
f0104d98:	83 c4 10             	add    $0x10,%esp
		return pg_insert_check;
f0104d9b:	89 f8                	mov    %edi,%eax
f0104d9d:	e9 e3 04 00 00       	jmp    f0105285 <syscall+0x67c>
	//   allocated!

	// LAB 4: Your code here.
	// check if va is page aligned and isnt above UTOP
	if ((((int)va % PGSIZE) != 0) || ((uintptr_t)va >= UTOP)) {
		return -E_INVAL;
f0104da2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104da7:	e9 d9 04 00 00       	jmp    f0105285 <syscall+0x67c>
	}
	// check if PTE_P and PTE_U are set (must be set)
	if (((PTE_P | PTE_U) & perm) != (PTE_U | PTE_P)) { 
		return -E_INVAL;
f0104dac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104db1:	e9 cf 04 00 00       	jmp    f0105285 <syscall+0x67c>
	
	int to_check = perm | PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	int available_perm = PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	// check if no other bits hev bin(where the trash goes) set 
	if ((available_perm ^ to_check) != 0) {
		return -E_INVAL;
f0104db6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104dbb:	e9 c5 04 00 00       	jmp    f0105285 <syscall+0x67c>
	}

	struct PageInfo *new_page = page_alloc(ALLOC_ZERO);
	// page alloc return null if there are no free pages on page_free_list
	if (!new_page) {
		return -E_NO_MEM;
f0104dc0:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104dc5:	e9 bb 04 00 00       	jmp    f0105285 <syscall+0x67c>
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.

	if ((((int)srcva % PGSIZE) != 0) || ((uintptr_t)srcva >= UTOP)) {
f0104dca:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104dd1:	0f 85 dd 00 00 00    	jne    f0104eb4 <syscall+0x2ab>
f0104dd7:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104dde:	0f 87 d0 00 00 00    	ja     f0104eb4 <syscall+0x2ab>
		return -E_INVAL;
	}

	if ((((int)dstva % PGSIZE) != 0) || ((uintptr_t)dstva >= UTOP)) {
f0104de4:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0104deb:	0f 85 cd 00 00 00    	jne    f0104ebe <syscall+0x2b5>
f0104df1:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104df8:	0f 87 c0 00 00 00    	ja     f0104ebe <syscall+0x2b5>
		return -E_INVAL;
	}

	if (((PTE_P | PTE_U) & perm) != (PTE_U | PTE_P)) { 
f0104dfe:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0104e01:	83 e0 05             	and    $0x5,%eax
f0104e04:	83 f8 05             	cmp    $0x5,%eax
f0104e07:	0f 85 bb 00 00 00    	jne    f0104ec8 <syscall+0x2bf>
	}
	
	int to_check = perm | PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	int available_perm = PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	// check if no other bits have been set 
	if ((available_perm ^ to_check) != 0) {
f0104e0d:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0104e10:	0d 07 0e 00 00       	or     $0xe07,%eax
f0104e15:	3d 07 0e 00 00       	cmp    $0xe07,%eax
f0104e1a:	0f 85 b2 00 00 00    	jne    f0104ed2 <syscall+0x2c9>
		return -E_INVAL;
	}

	struct Env *srce;

	int retperm = envid2env(srcenvid, &srce, true);
f0104e20:	83 ec 04             	sub    $0x4,%esp
f0104e23:	6a 01                	push   $0x1
f0104e25:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104e28:	50                   	push   %eax
f0104e29:	ff 75 0c             	pushl  0xc(%ebp)
f0104e2c:	e8 8b e2 ff ff       	call   f01030bc <envid2env>
	
	if (retperm == -E_BAD_ENV) {
f0104e31:	83 c4 10             	add    $0x10,%esp
f0104e34:	83 f8 fe             	cmp    $0xfffffffe,%eax
f0104e37:	0f 84 9f 00 00 00    	je     f0104edc <syscall+0x2d3>
		return -E_BAD_ENV;
	}

	struct Env *dste;

	int retperm2 = envid2env(dstenvid, &dste, true);
f0104e3d:	83 ec 04             	sub    $0x4,%esp
f0104e40:	6a 01                	push   $0x1
f0104e42:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0104e45:	50                   	push   %eax
f0104e46:	ff 75 14             	pushl  0x14(%ebp)
f0104e49:	e8 6e e2 ff ff       	call   f01030bc <envid2env>
	
	if (retperm2 == -E_BAD_ENV) {
f0104e4e:	83 c4 10             	add    $0x10,%esp
f0104e51:	83 f8 fe             	cmp    $0xfffffffe,%eax
f0104e54:	0f 84 8c 00 00 00    	je     f0104ee6 <syscall+0x2dd>
		return -E_BAD_ENV;
	}

	pte_t *pte_store;
	struct PageInfo *p = page_lookup(srce->env_pgdir, srcva, &pte_store);
f0104e5a:	83 ec 04             	sub    $0x4,%esp
f0104e5d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104e60:	50                   	push   %eax
f0104e61:	ff 75 10             	pushl  0x10(%ebp)
f0104e64:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104e67:	ff b0 94 00 00 00    	pushl  0x94(%eax)
f0104e6d:	e8 ce c3 ff ff       	call   f0101240 <page_lookup>
	
	if (((perm & PTE_W) == PTE_W) && ((*pte_store & PTE_W) != PTE_W)) {
f0104e72:	83 c4 10             	add    $0x10,%esp
f0104e75:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104e79:	74 08                	je     f0104e83 <syscall+0x27a>
f0104e7b:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104e7e:	f6 02 02             	testb  $0x2,(%edx)
f0104e81:	74 6d                	je     f0104ef0 <syscall+0x2e7>
		return -E_INVAL;
	}

	if (!p) {
f0104e83:	85 c0                	test   %eax,%eax
f0104e85:	74 73                	je     f0104efa <syscall+0x2f1>
		return -E_INVAL;	
	}
	
	int pg_insert_check = page_insert(dste->env_pgdir, p, dstva, perm);
f0104e87:	ff 75 1c             	pushl  0x1c(%ebp)
f0104e8a:	ff 75 18             	pushl  0x18(%ebp)
f0104e8d:	50                   	push   %eax
f0104e8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104e91:	ff b0 94 00 00 00    	pushl  0x94(%eax)
f0104e97:	e8 d1 c4 ff ff       	call   f010136d <page_insert>
	
	if (pg_insert_check == -E_NO_MEM) {
f0104e9c:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
	}
	
	return 0;
f0104e9f:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0104ea2:	0f 95 c0             	setne  %al
f0104ea5:	0f b6 c0             	movzbl %al,%eax
f0104ea8:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
f0104eaf:	e9 d1 03 00 00       	jmp    f0105285 <syscall+0x67c>
	//   check the current permissions on the page.

	// LAB 4: Your code here.

	if ((((int)srcva % PGSIZE) != 0) || ((uintptr_t)srcva >= UTOP)) {
		return -E_INVAL;
f0104eb4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104eb9:	e9 c7 03 00 00       	jmp    f0105285 <syscall+0x67c>
	}

	if ((((int)dstva % PGSIZE) != 0) || ((uintptr_t)dstva >= UTOP)) {
		return -E_INVAL;
f0104ebe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104ec3:	e9 bd 03 00 00       	jmp    f0105285 <syscall+0x67c>
	}

	if (((PTE_P | PTE_U) & perm) != (PTE_U | PTE_P)) { 
		return -E_INVAL;
f0104ec8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104ecd:	e9 b3 03 00 00       	jmp    f0105285 <syscall+0x67c>
	
	int to_check = perm | PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	int available_perm = PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	// check if no other bits have been set 
	if ((available_perm ^ to_check) != 0) {
		return -E_INVAL;
f0104ed2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104ed7:	e9 a9 03 00 00       	jmp    f0105285 <syscall+0x67c>
	struct Env *srce;

	int retperm = envid2env(srcenvid, &srce, true);
	
	if (retperm == -E_BAD_ENV) {
		return -E_BAD_ENV;
f0104edc:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104ee1:	e9 9f 03 00 00       	jmp    f0105285 <syscall+0x67c>
	struct Env *dste;

	int retperm2 = envid2env(dstenvid, &dste, true);
	
	if (retperm2 == -E_BAD_ENV) {
		return -E_BAD_ENV;
f0104ee6:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104eeb:	e9 95 03 00 00       	jmp    f0105285 <syscall+0x67c>

	pte_t *pte_store;
	struct PageInfo *p = page_lookup(srce->env_pgdir, srcva, &pte_store);
	
	if (((perm & PTE_W) == PTE_W) && ((*pte_store & PTE_W) != PTE_W)) {
		return -E_INVAL;
f0104ef0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104ef5:	e9 8b 03 00 00       	jmp    f0105285 <syscall+0x67c>
	}

	if (!p) {
		return -E_INVAL;	
f0104efa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104eff:	e9 81 03 00 00       	jmp    f0105285 <syscall+0x67c>
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if ((((int)va % PGSIZE) != 0) || ((uintptr_t)va >= UTOP)) {
f0104f04:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104f0b:	75 45                	jne    f0104f52 <syscall+0x349>
f0104f0d:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104f14:	77 3c                	ja     f0104f52 <syscall+0x349>
		return -E_INVAL;
	}
	
	struct Env *e;
	int perm = envid2env(envid, &e, true);
f0104f16:	83 ec 04             	sub    $0x4,%esp
f0104f19:	6a 01                	push   $0x1
f0104f1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104f1e:	50                   	push   %eax
f0104f1f:	ff 75 0c             	pushl  0xc(%ebp)
f0104f22:	e8 95 e1 ff ff       	call   f01030bc <envid2env>
f0104f27:	89 c6                	mov    %eax,%esi
	
	if (perm) {
f0104f29:	83 c4 10             	add    $0x10,%esp
f0104f2c:	85 c0                	test   %eax,%eax
f0104f2e:	0f 85 51 03 00 00    	jne    f0105285 <syscall+0x67c>
		return perm;
	}	
	
	page_remove(e->env_pgdir, va);
f0104f34:	83 ec 08             	sub    $0x8,%esp
f0104f37:	ff 75 10             	pushl  0x10(%ebp)
f0104f3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104f3d:	ff b0 94 00 00 00    	pushl  0x94(%eax)
f0104f43:	e8 b7 c3 ff ff       	call   f01012ff <page_remove>
f0104f48:	83 c4 10             	add    $0x10,%esp

	return 0;
f0104f4b:	89 f0                	mov    %esi,%eax
f0104f4d:	e9 33 03 00 00       	jmp    f0105285 <syscall+0x67c>
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if ((((int)va % PGSIZE) != 0) || ((uintptr_t)va >= UTOP)) {
		return -E_INVAL;
f0104f52:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104f57:	e9 29 03 00 00       	jmp    f0105285 <syscall+0x67c>
	// It should be left as env_alloc created it, except that
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.
	struct Env *new_env;
	int env_state =	env_alloc(&new_env, curenv->env_id);
f0104f5c:	e8 29 14 00 00       	call   f010638a <cpunum>
f0104f61:	83 ec 08             	sub    $0x8,%esp
f0104f64:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f67:	8b 80 28 90 21 f0    	mov    -0xfde6fd8(%eax),%eax
f0104f6d:	ff 70 7c             	pushl  0x7c(%eax)
f0104f70:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104f73:	50                   	push   %eax
f0104f74:	e8 a7 e2 ff ff       	call   f0103220 <env_alloc>

	if (env_state < 0) {
f0104f79:	83 c4 10             	add    $0x10,%esp
f0104f7c:	85 c0                	test   %eax,%eax
f0104f7e:	0f 88 01 03 00 00    	js     f0105285 <syscall+0x67c>
		return env_state;
	}

	new_env->env_tf = curenv->env_tf;
f0104f84:	8b 7d f4             	mov    -0xc(%ebp),%edi
f0104f87:	e8 fe 13 00 00       	call   f010638a <cpunum>
f0104f8c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f8f:	8b b0 28 90 21 f0    	mov    -0xfde6fd8(%eax),%esi
f0104f95:	83 c7 34             	add    $0x34,%edi
f0104f98:	83 c6 34             	add    $0x34,%esi
f0104f9b:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104fa0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	new_env->env_status = ENV_NOT_RUNNABLE;
f0104fa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104fa5:	c7 80 88 00 00 00 04 	movl   $0x4,0x88(%eax)
f0104fac:	00 00 00 
	new_env->env_tf.tf_regs.reg_eax = 0;
f0104faf:	c7 40 50 00 00 00 00 	movl   $0x0,0x50(%eax)

	return new_env->env_id;
f0104fb6:	8b 40 7c             	mov    0x7c(%eax),%eax
f0104fb9:	e9 c7 02 00 00       	jmp    f0105285 <syscall+0x67c>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if ((status != ENV_RUNNABLE) && (status != ENV_NOT_RUNNABLE)) {
f0104fbe:	8b 45 10             	mov    0x10(%ebp),%eax
f0104fc1:	83 e8 02             	sub    $0x2,%eax
f0104fc4:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0104fc9:	75 31                	jne    f0104ffc <syscall+0x3f3>
		return -E_INVAL;
	}

	struct Env *e;

	int perm = envid2env(envid, &e, true); 
f0104fcb:	83 ec 04             	sub    $0x4,%esp
f0104fce:	6a 01                	push   $0x1
f0104fd0:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104fd3:	50                   	push   %eax
f0104fd4:	ff 75 0c             	pushl  0xc(%ebp)
f0104fd7:	e8 e0 e0 ff ff       	call   f01030bc <envid2env>
f0104fdc:	89 c2                	mov    %eax,%edx

	if (perm) {
f0104fde:	83 c4 10             	add    $0x10,%esp
f0104fe1:	85 c0                	test   %eax,%eax
f0104fe3:	0f 85 9c 02 00 00    	jne    f0105285 <syscall+0x67c>
		return perm;
	}	

	e->env_status = status;
f0104fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104fec:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104fef:	89 88 88 00 00 00    	mov    %ecx,0x88(%eax)

	return 0;
f0104ff5:	89 d0                	mov    %edx,%eax
f0104ff7:	e9 89 02 00 00       	jmp    f0105285 <syscall+0x67c>
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if ((status != ENV_RUNNABLE) && (status != ENV_NOT_RUNNABLE)) {
		return -E_INVAL;
f0104ffc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105001:	e9 7f 02 00 00       	jmp    f0105285 <syscall+0x67c>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *e;

	int perm = envid2env(envid, &e, true); 
f0105006:	83 ec 04             	sub    $0x4,%esp
f0105009:	6a 01                	push   $0x1
f010500b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010500e:	50                   	push   %eax
f010500f:	ff 75 0c             	pushl  0xc(%ebp)
f0105012:	e8 a5 e0 ff ff       	call   f01030bc <envid2env>

	if (perm) {
f0105017:	83 c4 10             	add    $0x10,%esp
f010501a:	85 c0                	test   %eax,%eax
f010501c:	0f 85 63 02 00 00    	jne    f0105285 <syscall+0x67c>
		return perm;
	}
	
	e->env_pgfault_upcall = func;
f0105022:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0105025:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0105028:	89 8a 98 00 00 00    	mov    %ecx,0x98(%edx)

		case SYS_env_set_status:
			return sys_env_set_status(a1, a2);

		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1, (void*)a2);
f010502e:	e9 52 02 00 00       	jmp    f0105285 <syscall+0x67c>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0105033:	e8 aa fa ff ff       	call   f0104ae2 <sched_yield>
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.

	struct Env *e;
	int env = envid2env(envid, &e, false);
f0105038:	83 ec 04             	sub    $0x4,%esp
f010503b:	6a 00                	push   $0x0
f010503d:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0105040:	50                   	push   %eax
f0105041:	ff 75 0c             	pushl  0xc(%ebp)
f0105044:	e8 73 e0 ff ff       	call   f01030bc <envid2env>
	
	if (env < 0) {
f0105049:	83 c4 10             	add    $0x10,%esp
f010504c:	85 c0                	test   %eax,%eax
f010504e:	79 08                	jns    f0105058 <syscall+0x44f>
		return perm;
f0105050:	8b 45 18             	mov    0x18(%ebp),%eax
f0105053:	e9 2d 02 00 00       	jmp    f0105285 <syscall+0x67c>
	}
	
	if (!e->env_ipc_recving) {
f0105058:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010505b:	80 b8 9c 00 00 00 00 	cmpb   $0x0,0x9c(%eax)
f0105062:	0f 84 1b 01 00 00    	je     f0105183 <syscall+0x57a>
		return -E_IPC_NOT_RECV;
	}

	e->env_ipc_perm = 0;
f0105068:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
f010506f:	00 00 00 

	if ((uint32_t)srcva < UTOP) {
f0105072:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0105079:	0f 87 bc 00 00 00    	ja     f010513b <syscall+0x532>
		if (ROUNDDOWN((uint32_t)srcva,PGSIZE) != (uint32_t)srcva) {
			return -E_INVAL;
f010507f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}

	e->env_ipc_perm = 0;

	if ((uint32_t)srcva < UTOP) {
		if (ROUNDDOWN((uint32_t)srcva,PGSIZE) != (uint32_t)srcva) {
f0105084:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f010508b:	0f 85 f4 01 00 00    	jne    f0105285 <syscall+0x67c>
			return -E_INVAL;
		}

		if (((PTE_P | PTE_U) & perm) != (PTE_U | PTE_P)) { 
f0105091:	8b 55 18             	mov    0x18(%ebp),%edx
f0105094:	83 e2 05             	and    $0x5,%edx
f0105097:	83 fa 05             	cmp    $0x5,%edx
f010509a:	0f 85 e5 01 00 00    	jne    f0105285 <syscall+0x67c>
		}
	
		int to_check = perm | PTE_P | PTE_W | PTE_U | PTE_AVAIL;
		int available_perm = PTE_P | PTE_W | PTE_U | PTE_AVAIL;
		// check if no other bits have been set 
		if ((available_perm ^ to_check) != 0) {
f01050a0:	8b 55 18             	mov    0x18(%ebp),%edx
f01050a3:	81 ca 07 0e 00 00    	or     $0xe07,%edx
f01050a9:	81 fa 07 0e 00 00    	cmp    $0xe07,%edx
f01050af:	0f 85 d0 01 00 00    	jne    f0105285 <syscall+0x67c>
			return -E_INVAL;
		}

		pte_t *pte_store;
		struct PageInfo *p = page_lookup(curenv->env_pgdir, srcva, 							 &pte_store);
f01050b5:	e8 d0 12 00 00       	call   f010638a <cpunum>
f01050ba:	83 ec 04             	sub    $0x4,%esp
f01050bd:	8d 55 f4             	lea    -0xc(%ebp),%edx
f01050c0:	52                   	push   %edx
f01050c1:	ff 75 14             	pushl  0x14(%ebp)
f01050c4:	6b c0 74             	imul   $0x74,%eax,%eax
f01050c7:	8b 80 28 90 21 f0    	mov    -0xfde6fd8(%eax),%eax
f01050cd:	ff b0 94 00 00 00    	pushl  0x94(%eax)
f01050d3:	e8 68 c1 ff ff       	call   f0101240 <page_lookup>
f01050d8:	89 c1                	mov    %eax,%ecx
	
		if (((perm & PTE_W) == PTE_W) && ((*pte_store & PTE_W) != PTE_W)) {
f01050da:	83 c4 10             	add    $0x10,%esp
f01050dd:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f01050e1:	74 11                	je     f01050f4 <syscall+0x4eb>
			return -E_INVAL;
f01050e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}

		pte_t *pte_store;
		struct PageInfo *p = page_lookup(curenv->env_pgdir, srcva, 							 &pte_store);
	
		if (((perm & PTE_W) == PTE_W) && ((*pte_store & PTE_W) != PTE_W)) {
f01050e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01050eb:	f6 02 02             	testb  $0x2,(%edx)
f01050ee:	0f 84 91 01 00 00    	je     f0105285 <syscall+0x67c>
			return -E_INVAL;
		}

		if (!p) {
f01050f4:	85 c9                	test   %ecx,%ecx
f01050f6:	74 39                	je     f0105131 <syscall+0x528>
			return -E_INVAL;	
		}

		if ((uint32_t)e->env_ipc_dstva < UTOP){
f01050f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01050fb:	8b 82 a0 00 00 00    	mov    0xa0(%edx),%eax
f0105101:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f0105106:	77 33                	ja     f010513b <syscall+0x532>
			int pg_insert_check = page_insert(e->env_pgdir, p,
f0105108:	ff 75 18             	pushl  0x18(%ebp)
f010510b:	50                   	push   %eax
f010510c:	51                   	push   %ecx
f010510d:	ff b2 94 00 00 00    	pushl  0x94(%edx)
f0105113:	e8 55 c2 ff ff       	call   f010136d <page_insert>
	 				          e->env_ipc_dstva, perm);
	
			if (pg_insert_check < 0) {
f0105118:	83 c4 10             	add    $0x10,%esp
f010511b:	85 c0                	test   %eax,%eax
f010511d:	0f 88 62 01 00 00    	js     f0105285 <syscall+0x67c>
				return pg_insert_check;
			}

			e->env_ipc_perm = perm;
f0105123:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105126:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0105129:	89 88 ac 00 00 00    	mov    %ecx,0xac(%eax)
f010512f:	eb 0a                	jmp    f010513b <syscall+0x532>
		if (((perm & PTE_W) == PTE_W) && ((*pte_store & PTE_W) != PTE_W)) {
			return -E_INVAL;
		}

		if (!p) {
			return -E_INVAL;	
f0105131:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105136:	e9 4a 01 00 00       	jmp    f0105285 <syscall+0x67c>

			e->env_ipc_perm = perm;
		}
	}

	e->env_ipc_recving = false;
f010513b:	8b 75 f0             	mov    -0x10(%ebp),%esi
f010513e:	c6 86 9c 00 00 00 00 	movb   $0x0,0x9c(%esi)
	e->env_ipc_from = curenv->env_id;
f0105145:	e8 40 12 00 00       	call   f010638a <cpunum>
f010514a:	6b c0 74             	imul   $0x74,%eax,%eax
f010514d:	8b 80 28 90 21 f0    	mov    -0xfde6fd8(%eax),%eax
f0105153:	8b 40 7c             	mov    0x7c(%eax),%eax
f0105156:	89 86 a8 00 00 00    	mov    %eax,0xa8(%esi)
	e->env_ipc_value = value;
f010515c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010515f:	8b 7d 10             	mov    0x10(%ebp),%edi
f0105162:	89 b8 a4 00 00 00    	mov    %edi,0xa4(%eax)
	e->env_status = ENV_RUNNABLE;
f0105168:	c7 80 88 00 00 00 02 	movl   $0x2,0x88(%eax)
f010516f:	00 00 00 
	e->env_tf.tf_regs.reg_eax = 0;
f0105172:	c7 40 50 00 00 00 00 	movl   $0x0,0x50(%eax)

	return 0;
f0105179:	b8 00 00 00 00       	mov    $0x0,%eax
f010517e:	e9 02 01 00 00       	jmp    f0105285 <syscall+0x67c>
	if (env < 0) {
		return perm;
	}
	
	if (!e->env_ipc_recving) {
		return -E_IPC_NOT_RECV;
f0105183:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
		case SYS_yield:
			sys_yield();
			return 0;

		case SYS_ipc_try_send:
			return sys_ipc_try_send(a1, a2, (void*)a3, a4);
f0105188:	e9 f8 00 00 00       	jmp    f0105285 <syscall+0x67c>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if ((uint32_t)dstva < UTOP) {
f010518d:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0105194:	77 0d                	ja     f01051a3 <syscall+0x59a>
		if (ROUNDDOWN((uint32_t)dstva, PGSIZE) != (uint32_t)dstva) {
f0105196:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f010519d:	0f 85 dd 00 00 00    	jne    f0105280 <syscall+0x677>
			return -E_INVAL;
		}
	}
	curenv->env_ipc_recving = true;	
f01051a3:	e8 e2 11 00 00       	call   f010638a <cpunum>
f01051a8:	6b c0 74             	imul   $0x74,%eax,%eax
f01051ab:	8b 80 28 90 21 f0    	mov    -0xfde6fd8(%eax),%eax
f01051b1:	c6 80 9c 00 00 00 01 	movb   $0x1,0x9c(%eax)
	curenv->env_ipc_dstva = dstva;
f01051b8:	e8 cd 11 00 00       	call   f010638a <cpunum>
f01051bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01051c0:	8b 80 28 90 21 f0    	mov    -0xfde6fd8(%eax),%eax
f01051c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01051c9:	89 88 a0 00 00 00    	mov    %ecx,0xa0(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f01051cf:	e8 b6 11 00 00       	call   f010638a <cpunum>
f01051d4:	6b c0 74             	imul   $0x74,%eax,%eax
f01051d7:	8b 80 28 90 21 f0    	mov    -0xfde6fd8(%eax),%eax
f01051dd:	c7 80 88 00 00 00 04 	movl   $0x4,0x88(%eax)
f01051e4:	00 00 00 
	curenv->env_tf.tf_regs.reg_eax = 0;
f01051e7:	e8 9e 11 00 00       	call   f010638a <cpunum>
f01051ec:	6b c0 74             	imul   $0x74,%eax,%eax
f01051ef:	8b 80 28 90 21 f0    	mov    -0xfde6fd8(%eax),%eax
f01051f5:	c7 40 50 00 00 00 00 	movl   $0x0,0x50(%eax)

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f01051fc:	e8 e1 f8 ff ff       	call   f0104ae2 <sched_yield>
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!

	struct Env *e; 
	int env = envid2env(envid, &e, 1);
f0105201:	83 ec 04             	sub    $0x4,%esp
f0105204:	6a 01                	push   $0x1
f0105206:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0105209:	50                   	push   %eax
f010520a:	ff 75 0c             	pushl  0xc(%ebp)
f010520d:	e8 aa de ff ff       	call   f01030bc <envid2env>

	if (env < 0) { 
f0105212:	83 c4 10             	add    $0x10,%esp
f0105215:	85 c0                	test   %eax,%eax
f0105217:	78 6c                	js     f0105285 <syscall+0x67c>
		return env;
	}

	user_mem_assert(e, tf, sizeof(struct Trapframe), PTE_U);
f0105219:	6a 04                	push   $0x4
f010521b:	6a 44                	push   $0x44
f010521d:	ff 75 10             	pushl  0x10(%ebp)
f0105220:	ff 75 f4             	pushl  -0xc(%ebp)
f0105223:	e8 8d dd ff ff       	call   f0102fb5 <user_mem_assert>

	e->env_tf = *tf;
f0105228:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010522b:	8d 7a 34             	lea    0x34(%edx),%edi
f010522e:	b9 11 00 00 00       	mov    $0x11,%ecx
f0105233:	8b 75 10             	mov    0x10(%ebp),%esi
f0105236:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_tf.tf_eflags |= FL_IF;
	e->env_tf.tf_cs = GD_UT | 3;
f0105238:	66 c7 42 68 1b 00    	movw   $0x1b,0x68(%edx)
	//shoutout to fgt(x)
	e->env_tf.tf_eflags &= ~FL_IOPL_3;
f010523e:	8b 42 6c             	mov    0x6c(%edx),%eax
f0105241:	80 e4 cf             	and    $0xcf,%ah
f0105244:	80 cc 02             	or     $0x2,%ah
f0105247:	89 42 6c             	mov    %eax,0x6c(%edx)
f010524a:	83 c4 10             	add    $0x10,%esp

	return 0;
f010524d:	b8 00 00 00 00       	mov    $0x0,%eax
f0105252:	eb 31                	jmp    f0105285 <syscall+0x67c>

// LAB 7 Multithreading
		case SYS_thread_create:
			//void (*func)() = (void(*)())a1;
			//return sys_thread_create((void(*)())a1/*func*/);
			return sys_thread_create((uintptr_t) a1);
f0105254:	83 ec 0c             	sub    $0xc,%esp
f0105257:	ff 75 0c             	pushl  0xc(%ebp)
f010525a:	e8 64 f9 ff ff       	call   f0104bc3 <sys_thread_create>
f010525f:	83 c4 10             	add    $0x10,%esp
f0105262:	eb 21                	jmp    f0105285 <syscall+0x67c>

		case SYS_thread_free:
			sys_thread_free((envid_t)a1);
f0105264:	83 ec 0c             	sub    $0xc,%esp
f0105267:	ff 75 0c             	pushl  0xc(%ebp)
f010526a:	e8 76 f9 ff ff       	call   f0104be5 <sys_thread_free>
			return 0;
f010526f:	83 c4 10             	add    $0x10,%esp
f0105272:	b8 00 00 00 00       	mov    $0x0,%eax
f0105277:	eb 0c                	jmp    f0105285 <syscall+0x67c>

		default:
			return -E_INVAL;
f0105279:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010527e:	eb 05                	jmp    f0105285 <syscall+0x67c>

		case SYS_ipc_try_send:
			return sys_ipc_try_send(a1, a2, (void*)a3, a4);

		case SYS_ipc_recv:
			return sys_ipc_recv((void*)a1);
f0105280:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			return 0;

		default:
			return -E_INVAL;
	}
}
f0105285:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105288:	5e                   	pop    %esi
f0105289:	5f                   	pop    %edi
f010528a:	5d                   	pop    %ebp
f010528b:	c3                   	ret    

f010528c <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010528c:	55                   	push   %ebp
f010528d:	89 e5                	mov    %esp,%ebp
f010528f:	57                   	push   %edi
f0105290:	56                   	push   %esi
f0105291:	53                   	push   %ebx
f0105292:	83 ec 14             	sub    $0x14,%esp
f0105295:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105298:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010529b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010529e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01052a1:	8b 1a                	mov    (%edx),%ebx
f01052a3:	8b 01                	mov    (%ecx),%eax
f01052a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01052a8:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01052af:	eb 7f                	jmp    f0105330 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f01052b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01052b4:	01 d8                	add    %ebx,%eax
f01052b6:	89 c6                	mov    %eax,%esi
f01052b8:	c1 ee 1f             	shr    $0x1f,%esi
f01052bb:	01 c6                	add    %eax,%esi
f01052bd:	d1 fe                	sar    %esi
f01052bf:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01052c2:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01052c5:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01052c8:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01052ca:	eb 03                	jmp    f01052cf <stab_binsearch+0x43>
			m--;
f01052cc:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01052cf:	39 c3                	cmp    %eax,%ebx
f01052d1:	7f 0d                	jg     f01052e0 <stab_binsearch+0x54>
f01052d3:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01052d7:	83 ea 0c             	sub    $0xc,%edx
f01052da:	39 f9                	cmp    %edi,%ecx
f01052dc:	75 ee                	jne    f01052cc <stab_binsearch+0x40>
f01052de:	eb 05                	jmp    f01052e5 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01052e0:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f01052e3:	eb 4b                	jmp    f0105330 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01052e5:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01052e8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01052eb:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01052ef:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01052f2:	76 11                	jbe    f0105305 <stab_binsearch+0x79>
			*region_left = m;
f01052f4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01052f7:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01052f9:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01052fc:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105303:	eb 2b                	jmp    f0105330 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0105305:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0105308:	73 14                	jae    f010531e <stab_binsearch+0x92>
			*region_right = m - 1;
f010530a:	83 e8 01             	sub    $0x1,%eax
f010530d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105310:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105313:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105315:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010531c:	eb 12                	jmp    f0105330 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010531e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105321:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0105323:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0105327:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105329:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0105330:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0105333:	0f 8e 78 ff ff ff    	jle    f01052b1 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0105339:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010533d:	75 0f                	jne    f010534e <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f010533f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105342:	8b 00                	mov    (%eax),%eax
f0105344:	83 e8 01             	sub    $0x1,%eax
f0105347:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010534a:	89 06                	mov    %eax,(%esi)
f010534c:	eb 2c                	jmp    f010537a <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010534e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105351:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0105353:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105356:	8b 0e                	mov    (%esi),%ecx
f0105358:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010535b:	8b 75 ec             	mov    -0x14(%ebp),%esi
f010535e:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105361:	eb 03                	jmp    f0105366 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0105363:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105366:	39 c8                	cmp    %ecx,%eax
f0105368:	7e 0b                	jle    f0105375 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f010536a:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f010536e:	83 ea 0c             	sub    $0xc,%edx
f0105371:	39 df                	cmp    %ebx,%edi
f0105373:	75 ee                	jne    f0105363 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0105375:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105378:	89 06                	mov    %eax,(%esi)
	}
}
f010537a:	83 c4 14             	add    $0x14,%esp
f010537d:	5b                   	pop    %ebx
f010537e:	5e                   	pop    %esi
f010537f:	5f                   	pop    %edi
f0105380:	5d                   	pop    %ebp
f0105381:	c3                   	ret    

f0105382 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0105382:	55                   	push   %ebp
f0105383:	89 e5                	mov    %esp,%ebp
f0105385:	57                   	push   %edi
f0105386:	56                   	push   %esi
f0105387:	53                   	push   %ebx
f0105388:	83 ec 3c             	sub    $0x3c,%esp
f010538b:	8b 75 08             	mov    0x8(%ebp),%esi
f010538e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0105391:	c7 03 f4 82 10 f0    	movl   $0xf01082f4,(%ebx)
	info->eip_line = 0;
f0105397:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f010539e:	c7 43 08 f4 82 10 f0 	movl   $0xf01082f4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01053a5:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01053ac:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01053af:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01053b6:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01053bc:	77 21                	ja     f01053df <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f01053be:	a1 00 00 20 00       	mov    0x200000,%eax
f01053c3:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stab_end = usd->stab_end;
f01053c6:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f01053cb:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f01053d1:	89 7d b8             	mov    %edi,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f01053d4:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f01053da:	89 7d c0             	mov    %edi,-0x40(%ebp)
f01053dd:	eb 1a                	jmp    f01053f9 <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01053df:	c7 45 c0 33 76 11 f0 	movl   $0xf0117633,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01053e6:	c7 45 b8 39 34 11 f0 	movl   $0xf0113439,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01053ed:	b8 38 34 11 f0       	mov    $0xf0113438,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01053f2:	c7 45 bc 90 88 10 f0 	movl   $0xf0108890,-0x44(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01053f9:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01053fc:	39 7d b8             	cmp    %edi,-0x48(%ebp)
f01053ff:	0f 83 95 01 00 00    	jae    f010559a <debuginfo_eip+0x218>
f0105405:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f0105409:	0f 85 92 01 00 00    	jne    f01055a1 <debuginfo_eip+0x21f>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010540f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0105416:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0105419:	29 f8                	sub    %edi,%eax
f010541b:	c1 f8 02             	sar    $0x2,%eax
f010541e:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0105424:	83 e8 01             	sub    $0x1,%eax
f0105427:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010542a:	56                   	push   %esi
f010542b:	6a 64                	push   $0x64
f010542d:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0105430:	89 c1                	mov    %eax,%ecx
f0105432:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105435:	89 f8                	mov    %edi,%eax
f0105437:	e8 50 fe ff ff       	call   f010528c <stab_binsearch>
	if (lfile == 0)
f010543c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010543f:	83 c4 08             	add    $0x8,%esp
f0105442:	85 c0                	test   %eax,%eax
f0105444:	0f 84 5e 01 00 00    	je     f01055a8 <debuginfo_eip+0x226>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010544a:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010544d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105450:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105453:	56                   	push   %esi
f0105454:	6a 24                	push   $0x24
f0105456:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0105459:	89 c1                	mov    %eax,%ecx
f010545b:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010545e:	89 f8                	mov    %edi,%eax
f0105460:	e8 27 fe ff ff       	call   f010528c <stab_binsearch>

	if (lfun <= rfun) {
f0105465:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105468:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010546b:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f010546e:	83 c4 08             	add    $0x8,%esp
f0105471:	39 d0                	cmp    %edx,%eax
f0105473:	7f 2b                	jg     f01054a0 <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105475:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105478:	8d 0c 97             	lea    (%edi,%edx,4),%ecx
f010547b:	8b 11                	mov    (%ecx),%edx
f010547d:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0105480:	2b 7d b8             	sub    -0x48(%ebp),%edi
f0105483:	39 fa                	cmp    %edi,%edx
f0105485:	73 06                	jae    f010548d <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105487:	03 55 b8             	add    -0x48(%ebp),%edx
f010548a:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010548d:	8b 51 08             	mov    0x8(%ecx),%edx
f0105490:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0105493:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0105495:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0105498:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010549b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010549e:	eb 0f                	jmp    f01054af <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01054a0:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f01054a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01054a6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01054a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01054ac:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01054af:	83 ec 08             	sub    $0x8,%esp
f01054b2:	6a 3a                	push   $0x3a
f01054b4:	ff 73 08             	pushl  0x8(%ebx)
f01054b7:	e8 92 08 00 00       	call   f0105d4e <strfind>
f01054bc:	2b 43 08             	sub    0x8(%ebx),%eax
f01054bf:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01054c2:	83 c4 08             	add    $0x8,%esp
f01054c5:	56                   	push   %esi
f01054c6:	6a 44                	push   $0x44
f01054c8:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01054cb:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01054ce:	8b 75 bc             	mov    -0x44(%ebp),%esi
f01054d1:	89 f0                	mov    %esi,%eax
f01054d3:	e8 b4 fd ff ff       	call   f010528c <stab_binsearch>
	if (lline == rline) {
f01054d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01054db:	83 c4 10             	add    $0x10,%esp
f01054de:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f01054e1:	0f 85 c8 00 00 00    	jne    f01055af <debuginfo_eip+0x22d>
		info->eip_line = stabs[lline].n_desc;
f01054e7:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01054ea:	8d 14 96             	lea    (%esi,%edx,4),%edx
f01054ed:	0f b7 4a 06          	movzwl 0x6(%edx),%ecx
f01054f1:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01054f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01054f7:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f01054fb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01054fe:	eb 0a                	jmp    f010550a <debuginfo_eip+0x188>
f0105500:	83 e8 01             	sub    $0x1,%eax
f0105503:	83 ea 0c             	sub    $0xc,%edx
f0105506:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f010550a:	39 c7                	cmp    %eax,%edi
f010550c:	7e 05                	jle    f0105513 <debuginfo_eip+0x191>
f010550e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105511:	eb 47                	jmp    f010555a <debuginfo_eip+0x1d8>
	       && stabs[lline].n_type != N_SOL
f0105513:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0105517:	80 f9 84             	cmp    $0x84,%cl
f010551a:	75 0e                	jne    f010552a <debuginfo_eip+0x1a8>
f010551c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010551f:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0105523:	74 1c                	je     f0105541 <debuginfo_eip+0x1bf>
f0105525:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105528:	eb 17                	jmp    f0105541 <debuginfo_eip+0x1bf>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010552a:	80 f9 64             	cmp    $0x64,%cl
f010552d:	75 d1                	jne    f0105500 <debuginfo_eip+0x17e>
f010552f:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0105533:	74 cb                	je     f0105500 <debuginfo_eip+0x17e>
f0105535:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105538:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f010553c:	74 03                	je     f0105541 <debuginfo_eip+0x1bf>
f010553e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105541:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105544:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0105547:	8b 14 86             	mov    (%esi,%eax,4),%edx
f010554a:	8b 45 c0             	mov    -0x40(%ebp),%eax
f010554d:	8b 75 b8             	mov    -0x48(%ebp),%esi
f0105550:	29 f0                	sub    %esi,%eax
f0105552:	39 c2                	cmp    %eax,%edx
f0105554:	73 04                	jae    f010555a <debuginfo_eip+0x1d8>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105556:	01 f2                	add    %esi,%edx
f0105558:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010555a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010555d:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105560:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105565:	39 f2                	cmp    %esi,%edx
f0105567:	7d 52                	jge    f01055bb <debuginfo_eip+0x239>
		for (lline = lfun + 1;
f0105569:	83 c2 01             	add    $0x1,%edx
f010556c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010556f:	89 d0                	mov    %edx,%eax
f0105571:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0105574:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0105577:	8d 14 97             	lea    (%edi,%edx,4),%edx
f010557a:	eb 04                	jmp    f0105580 <debuginfo_eip+0x1fe>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f010557c:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105580:	39 c6                	cmp    %eax,%esi
f0105582:	7e 32                	jle    f01055b6 <debuginfo_eip+0x234>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105584:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0105588:	83 c0 01             	add    $0x1,%eax
f010558b:	83 c2 0c             	add    $0xc,%edx
f010558e:	80 f9 a0             	cmp    $0xa0,%cl
f0105591:	74 e9                	je     f010557c <debuginfo_eip+0x1fa>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105593:	b8 00 00 00 00       	mov    $0x0,%eax
f0105598:	eb 21                	jmp    f01055bb <debuginfo_eip+0x239>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f010559a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010559f:	eb 1a                	jmp    f01055bb <debuginfo_eip+0x239>
f01055a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01055a6:	eb 13                	jmp    f01055bb <debuginfo_eip+0x239>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f01055a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01055ad:	eb 0c                	jmp    f01055bb <debuginfo_eip+0x239>
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline == rline) {
		info->eip_line = stabs[lline].n_desc;
	} else {
		return -1;	
f01055af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01055b4:	eb 05                	jmp    f01055bb <debuginfo_eip+0x239>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01055b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01055bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01055be:	5b                   	pop    %ebx
f01055bf:	5e                   	pop    %esi
f01055c0:	5f                   	pop    %edi
f01055c1:	5d                   	pop    %ebp
f01055c2:	c3                   	ret    

f01055c3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01055c3:	55                   	push   %ebp
f01055c4:	89 e5                	mov    %esp,%ebp
f01055c6:	57                   	push   %edi
f01055c7:	56                   	push   %esi
f01055c8:	53                   	push   %ebx
f01055c9:	83 ec 1c             	sub    $0x1c,%esp
f01055cc:	89 c7                	mov    %eax,%edi
f01055ce:	89 d6                	mov    %edx,%esi
f01055d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01055d3:	8b 55 0c             	mov    0xc(%ebp),%edx
f01055d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01055d9:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01055dc:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01055df:	bb 00 00 00 00       	mov    $0x0,%ebx
f01055e4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01055e7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f01055ea:	39 d3                	cmp    %edx,%ebx
f01055ec:	72 05                	jb     f01055f3 <printnum+0x30>
f01055ee:	39 45 10             	cmp    %eax,0x10(%ebp)
f01055f1:	77 45                	ja     f0105638 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01055f3:	83 ec 0c             	sub    $0xc,%esp
f01055f6:	ff 75 18             	pushl  0x18(%ebp)
f01055f9:	8b 45 14             	mov    0x14(%ebp),%eax
f01055fc:	8d 58 ff             	lea    -0x1(%eax),%ebx
f01055ff:	53                   	push   %ebx
f0105600:	ff 75 10             	pushl  0x10(%ebp)
f0105603:	83 ec 08             	sub    $0x8,%esp
f0105606:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105609:	ff 75 e0             	pushl  -0x20(%ebp)
f010560c:	ff 75 dc             	pushl  -0x24(%ebp)
f010560f:	ff 75 d8             	pushl  -0x28(%ebp)
f0105612:	e8 79 11 00 00       	call   f0106790 <__udivdi3>
f0105617:	83 c4 18             	add    $0x18,%esp
f010561a:	52                   	push   %edx
f010561b:	50                   	push   %eax
f010561c:	89 f2                	mov    %esi,%edx
f010561e:	89 f8                	mov    %edi,%eax
f0105620:	e8 9e ff ff ff       	call   f01055c3 <printnum>
f0105625:	83 c4 20             	add    $0x20,%esp
f0105628:	eb 18                	jmp    f0105642 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010562a:	83 ec 08             	sub    $0x8,%esp
f010562d:	56                   	push   %esi
f010562e:	ff 75 18             	pushl  0x18(%ebp)
f0105631:	ff d7                	call   *%edi
f0105633:	83 c4 10             	add    $0x10,%esp
f0105636:	eb 03                	jmp    f010563b <printnum+0x78>
f0105638:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010563b:	83 eb 01             	sub    $0x1,%ebx
f010563e:	85 db                	test   %ebx,%ebx
f0105640:	7f e8                	jg     f010562a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105642:	83 ec 08             	sub    $0x8,%esp
f0105645:	56                   	push   %esi
f0105646:	83 ec 04             	sub    $0x4,%esp
f0105649:	ff 75 e4             	pushl  -0x1c(%ebp)
f010564c:	ff 75 e0             	pushl  -0x20(%ebp)
f010564f:	ff 75 dc             	pushl  -0x24(%ebp)
f0105652:	ff 75 d8             	pushl  -0x28(%ebp)
f0105655:	e8 66 12 00 00       	call   f01068c0 <__umoddi3>
f010565a:	83 c4 14             	add    $0x14,%esp
f010565d:	0f be 80 fe 82 10 f0 	movsbl -0xfef7d02(%eax),%eax
f0105664:	50                   	push   %eax
f0105665:	ff d7                	call   *%edi
}
f0105667:	83 c4 10             	add    $0x10,%esp
f010566a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010566d:	5b                   	pop    %ebx
f010566e:	5e                   	pop    %esi
f010566f:	5f                   	pop    %edi
f0105670:	5d                   	pop    %ebp
f0105671:	c3                   	ret    

f0105672 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105672:	55                   	push   %ebp
f0105673:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105675:	83 fa 01             	cmp    $0x1,%edx
f0105678:	7e 0e                	jle    f0105688 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f010567a:	8b 10                	mov    (%eax),%edx
f010567c:	8d 4a 08             	lea    0x8(%edx),%ecx
f010567f:	89 08                	mov    %ecx,(%eax)
f0105681:	8b 02                	mov    (%edx),%eax
f0105683:	8b 52 04             	mov    0x4(%edx),%edx
f0105686:	eb 22                	jmp    f01056aa <getuint+0x38>
	else if (lflag)
f0105688:	85 d2                	test   %edx,%edx
f010568a:	74 10                	je     f010569c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f010568c:	8b 10                	mov    (%eax),%edx
f010568e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105691:	89 08                	mov    %ecx,(%eax)
f0105693:	8b 02                	mov    (%edx),%eax
f0105695:	ba 00 00 00 00       	mov    $0x0,%edx
f010569a:	eb 0e                	jmp    f01056aa <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f010569c:	8b 10                	mov    (%eax),%edx
f010569e:	8d 4a 04             	lea    0x4(%edx),%ecx
f01056a1:	89 08                	mov    %ecx,(%eax)
f01056a3:	8b 02                	mov    (%edx),%eax
f01056a5:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01056aa:	5d                   	pop    %ebp
f01056ab:	c3                   	ret    

f01056ac <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01056ac:	55                   	push   %ebp
f01056ad:	89 e5                	mov    %esp,%ebp
f01056af:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01056b2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01056b6:	8b 10                	mov    (%eax),%edx
f01056b8:	3b 50 04             	cmp    0x4(%eax),%edx
f01056bb:	73 0a                	jae    f01056c7 <sprintputch+0x1b>
		*b->buf++ = ch;
f01056bd:	8d 4a 01             	lea    0x1(%edx),%ecx
f01056c0:	89 08                	mov    %ecx,(%eax)
f01056c2:	8b 45 08             	mov    0x8(%ebp),%eax
f01056c5:	88 02                	mov    %al,(%edx)
}
f01056c7:	5d                   	pop    %ebp
f01056c8:	c3                   	ret    

f01056c9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01056c9:	55                   	push   %ebp
f01056ca:	89 e5                	mov    %esp,%ebp
f01056cc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01056cf:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01056d2:	50                   	push   %eax
f01056d3:	ff 75 10             	pushl  0x10(%ebp)
f01056d6:	ff 75 0c             	pushl  0xc(%ebp)
f01056d9:	ff 75 08             	pushl  0x8(%ebp)
f01056dc:	e8 05 00 00 00       	call   f01056e6 <vprintfmt>
	va_end(ap);
}
f01056e1:	83 c4 10             	add    $0x10,%esp
f01056e4:	c9                   	leave  
f01056e5:	c3                   	ret    

f01056e6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01056e6:	55                   	push   %ebp
f01056e7:	89 e5                	mov    %esp,%ebp
f01056e9:	57                   	push   %edi
f01056ea:	56                   	push   %esi
f01056eb:	53                   	push   %ebx
f01056ec:	83 ec 2c             	sub    $0x2c,%esp
f01056ef:	8b 75 08             	mov    0x8(%ebp),%esi
f01056f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01056f5:	8b 7d 10             	mov    0x10(%ebp),%edi
f01056f8:	eb 12                	jmp    f010570c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01056fa:	85 c0                	test   %eax,%eax
f01056fc:	0f 84 89 03 00 00    	je     f0105a8b <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0105702:	83 ec 08             	sub    $0x8,%esp
f0105705:	53                   	push   %ebx
f0105706:	50                   	push   %eax
f0105707:	ff d6                	call   *%esi
f0105709:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010570c:	83 c7 01             	add    $0x1,%edi
f010570f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105713:	83 f8 25             	cmp    $0x25,%eax
f0105716:	75 e2                	jne    f01056fa <vprintfmt+0x14>
f0105718:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f010571c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0105723:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f010572a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0105731:	ba 00 00 00 00       	mov    $0x0,%edx
f0105736:	eb 07                	jmp    f010573f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105738:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f010573b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010573f:	8d 47 01             	lea    0x1(%edi),%eax
f0105742:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105745:	0f b6 07             	movzbl (%edi),%eax
f0105748:	0f b6 c8             	movzbl %al,%ecx
f010574b:	83 e8 23             	sub    $0x23,%eax
f010574e:	3c 55                	cmp    $0x55,%al
f0105750:	0f 87 1a 03 00 00    	ja     f0105a70 <vprintfmt+0x38a>
f0105756:	0f b6 c0             	movzbl %al,%eax
f0105759:	ff 24 85 40 84 10 f0 	jmp    *-0xfef7bc0(,%eax,4)
f0105760:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105763:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0105767:	eb d6                	jmp    f010573f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105769:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010576c:	b8 00 00 00 00       	mov    $0x0,%eax
f0105771:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105774:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0105777:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f010577b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f010577e:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0105781:	83 fa 09             	cmp    $0x9,%edx
f0105784:	77 39                	ja     f01057bf <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105786:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0105789:	eb e9                	jmp    f0105774 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f010578b:	8b 45 14             	mov    0x14(%ebp),%eax
f010578e:	8d 48 04             	lea    0x4(%eax),%ecx
f0105791:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105794:	8b 00                	mov    (%eax),%eax
f0105796:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105799:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010579c:	eb 27                	jmp    f01057c5 <vprintfmt+0xdf>
f010579e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01057a1:	85 c0                	test   %eax,%eax
f01057a3:	b9 00 00 00 00       	mov    $0x0,%ecx
f01057a8:	0f 49 c8             	cmovns %eax,%ecx
f01057ab:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01057ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01057b1:	eb 8c                	jmp    f010573f <vprintfmt+0x59>
f01057b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01057b6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f01057bd:	eb 80                	jmp    f010573f <vprintfmt+0x59>
f01057bf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01057c2:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f01057c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01057c9:	0f 89 70 ff ff ff    	jns    f010573f <vprintfmt+0x59>
				width = precision, precision = -1;
f01057cf:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01057d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01057d5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01057dc:	e9 5e ff ff ff       	jmp    f010573f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01057e1:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01057e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01057e7:	e9 53 ff ff ff       	jmp    f010573f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01057ec:	8b 45 14             	mov    0x14(%ebp),%eax
f01057ef:	8d 50 04             	lea    0x4(%eax),%edx
f01057f2:	89 55 14             	mov    %edx,0x14(%ebp)
f01057f5:	83 ec 08             	sub    $0x8,%esp
f01057f8:	53                   	push   %ebx
f01057f9:	ff 30                	pushl  (%eax)
f01057fb:	ff d6                	call   *%esi
			break;
f01057fd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105800:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105803:	e9 04 ff ff ff       	jmp    f010570c <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105808:	8b 45 14             	mov    0x14(%ebp),%eax
f010580b:	8d 50 04             	lea    0x4(%eax),%edx
f010580e:	89 55 14             	mov    %edx,0x14(%ebp)
f0105811:	8b 00                	mov    (%eax),%eax
f0105813:	99                   	cltd   
f0105814:	31 d0                	xor    %edx,%eax
f0105816:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105818:	83 f8 0f             	cmp    $0xf,%eax
f010581b:	7f 0b                	jg     f0105828 <vprintfmt+0x142>
f010581d:	8b 14 85 a0 85 10 f0 	mov    -0xfef7a60(,%eax,4),%edx
f0105824:	85 d2                	test   %edx,%edx
f0105826:	75 18                	jne    f0105840 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0105828:	50                   	push   %eax
f0105829:	68 16 83 10 f0       	push   $0xf0108316
f010582e:	53                   	push   %ebx
f010582f:	56                   	push   %esi
f0105830:	e8 94 fe ff ff       	call   f01056c9 <printfmt>
f0105835:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105838:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f010583b:	e9 cc fe ff ff       	jmp    f010570c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0105840:	52                   	push   %edx
f0105841:	68 66 79 10 f0       	push   $0xf0107966
f0105846:	53                   	push   %ebx
f0105847:	56                   	push   %esi
f0105848:	e8 7c fe ff ff       	call   f01056c9 <printfmt>
f010584d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105850:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105853:	e9 b4 fe ff ff       	jmp    f010570c <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105858:	8b 45 14             	mov    0x14(%ebp),%eax
f010585b:	8d 50 04             	lea    0x4(%eax),%edx
f010585e:	89 55 14             	mov    %edx,0x14(%ebp)
f0105861:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0105863:	85 ff                	test   %edi,%edi
f0105865:	b8 0f 83 10 f0       	mov    $0xf010830f,%eax
f010586a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f010586d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105871:	0f 8e 94 00 00 00    	jle    f010590b <vprintfmt+0x225>
f0105877:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f010587b:	0f 84 98 00 00 00    	je     f0105919 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105881:	83 ec 08             	sub    $0x8,%esp
f0105884:	ff 75 d0             	pushl  -0x30(%ebp)
f0105887:	57                   	push   %edi
f0105888:	e8 77 03 00 00       	call   f0105c04 <strnlen>
f010588d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105890:	29 c1                	sub    %eax,%ecx
f0105892:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0105895:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0105898:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f010589c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010589f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01058a2:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01058a4:	eb 0f                	jmp    f01058b5 <vprintfmt+0x1cf>
					putch(padc, putdat);
f01058a6:	83 ec 08             	sub    $0x8,%esp
f01058a9:	53                   	push   %ebx
f01058aa:	ff 75 e0             	pushl  -0x20(%ebp)
f01058ad:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01058af:	83 ef 01             	sub    $0x1,%edi
f01058b2:	83 c4 10             	add    $0x10,%esp
f01058b5:	85 ff                	test   %edi,%edi
f01058b7:	7f ed                	jg     f01058a6 <vprintfmt+0x1c0>
f01058b9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01058bc:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01058bf:	85 c9                	test   %ecx,%ecx
f01058c1:	b8 00 00 00 00       	mov    $0x0,%eax
f01058c6:	0f 49 c1             	cmovns %ecx,%eax
f01058c9:	29 c1                	sub    %eax,%ecx
f01058cb:	89 75 08             	mov    %esi,0x8(%ebp)
f01058ce:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01058d1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01058d4:	89 cb                	mov    %ecx,%ebx
f01058d6:	eb 4d                	jmp    f0105925 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01058d8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01058dc:	74 1b                	je     f01058f9 <vprintfmt+0x213>
f01058de:	0f be c0             	movsbl %al,%eax
f01058e1:	83 e8 20             	sub    $0x20,%eax
f01058e4:	83 f8 5e             	cmp    $0x5e,%eax
f01058e7:	76 10                	jbe    f01058f9 <vprintfmt+0x213>
					putch('?', putdat);
f01058e9:	83 ec 08             	sub    $0x8,%esp
f01058ec:	ff 75 0c             	pushl  0xc(%ebp)
f01058ef:	6a 3f                	push   $0x3f
f01058f1:	ff 55 08             	call   *0x8(%ebp)
f01058f4:	83 c4 10             	add    $0x10,%esp
f01058f7:	eb 0d                	jmp    f0105906 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f01058f9:	83 ec 08             	sub    $0x8,%esp
f01058fc:	ff 75 0c             	pushl  0xc(%ebp)
f01058ff:	52                   	push   %edx
f0105900:	ff 55 08             	call   *0x8(%ebp)
f0105903:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105906:	83 eb 01             	sub    $0x1,%ebx
f0105909:	eb 1a                	jmp    f0105925 <vprintfmt+0x23f>
f010590b:	89 75 08             	mov    %esi,0x8(%ebp)
f010590e:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105911:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105914:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105917:	eb 0c                	jmp    f0105925 <vprintfmt+0x23f>
f0105919:	89 75 08             	mov    %esi,0x8(%ebp)
f010591c:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010591f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105922:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105925:	83 c7 01             	add    $0x1,%edi
f0105928:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010592c:	0f be d0             	movsbl %al,%edx
f010592f:	85 d2                	test   %edx,%edx
f0105931:	74 23                	je     f0105956 <vprintfmt+0x270>
f0105933:	85 f6                	test   %esi,%esi
f0105935:	78 a1                	js     f01058d8 <vprintfmt+0x1f2>
f0105937:	83 ee 01             	sub    $0x1,%esi
f010593a:	79 9c                	jns    f01058d8 <vprintfmt+0x1f2>
f010593c:	89 df                	mov    %ebx,%edi
f010593e:	8b 75 08             	mov    0x8(%ebp),%esi
f0105941:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105944:	eb 18                	jmp    f010595e <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105946:	83 ec 08             	sub    $0x8,%esp
f0105949:	53                   	push   %ebx
f010594a:	6a 20                	push   $0x20
f010594c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010594e:	83 ef 01             	sub    $0x1,%edi
f0105951:	83 c4 10             	add    $0x10,%esp
f0105954:	eb 08                	jmp    f010595e <vprintfmt+0x278>
f0105956:	89 df                	mov    %ebx,%edi
f0105958:	8b 75 08             	mov    0x8(%ebp),%esi
f010595b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010595e:	85 ff                	test   %edi,%edi
f0105960:	7f e4                	jg     f0105946 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105962:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105965:	e9 a2 fd ff ff       	jmp    f010570c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010596a:	83 fa 01             	cmp    $0x1,%edx
f010596d:	7e 16                	jle    f0105985 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f010596f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105972:	8d 50 08             	lea    0x8(%eax),%edx
f0105975:	89 55 14             	mov    %edx,0x14(%ebp)
f0105978:	8b 50 04             	mov    0x4(%eax),%edx
f010597b:	8b 00                	mov    (%eax),%eax
f010597d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105980:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105983:	eb 32                	jmp    f01059b7 <vprintfmt+0x2d1>
	else if (lflag)
f0105985:	85 d2                	test   %edx,%edx
f0105987:	74 18                	je     f01059a1 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0105989:	8b 45 14             	mov    0x14(%ebp),%eax
f010598c:	8d 50 04             	lea    0x4(%eax),%edx
f010598f:	89 55 14             	mov    %edx,0x14(%ebp)
f0105992:	8b 00                	mov    (%eax),%eax
f0105994:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105997:	89 c1                	mov    %eax,%ecx
f0105999:	c1 f9 1f             	sar    $0x1f,%ecx
f010599c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010599f:	eb 16                	jmp    f01059b7 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f01059a1:	8b 45 14             	mov    0x14(%ebp),%eax
f01059a4:	8d 50 04             	lea    0x4(%eax),%edx
f01059a7:	89 55 14             	mov    %edx,0x14(%ebp)
f01059aa:	8b 00                	mov    (%eax),%eax
f01059ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01059af:	89 c1                	mov    %eax,%ecx
f01059b1:	c1 f9 1f             	sar    $0x1f,%ecx
f01059b4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01059b7:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01059ba:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01059bd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01059c2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01059c6:	79 74                	jns    f0105a3c <vprintfmt+0x356>
				putch('-', putdat);
f01059c8:	83 ec 08             	sub    $0x8,%esp
f01059cb:	53                   	push   %ebx
f01059cc:	6a 2d                	push   $0x2d
f01059ce:	ff d6                	call   *%esi
				num = -(long long) num;
f01059d0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01059d3:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01059d6:	f7 d8                	neg    %eax
f01059d8:	83 d2 00             	adc    $0x0,%edx
f01059db:	f7 da                	neg    %edx
f01059dd:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01059e0:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01059e5:	eb 55                	jmp    f0105a3c <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01059e7:	8d 45 14             	lea    0x14(%ebp),%eax
f01059ea:	e8 83 fc ff ff       	call   f0105672 <getuint>
			base = 10;
f01059ef:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01059f4:	eb 46                	jmp    f0105a3c <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f01059f6:	8d 45 14             	lea    0x14(%ebp),%eax
f01059f9:	e8 74 fc ff ff       	call   f0105672 <getuint>
			base = 8;
f01059fe:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0105a03:	eb 37                	jmp    f0105a3c <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f0105a05:	83 ec 08             	sub    $0x8,%esp
f0105a08:	53                   	push   %ebx
f0105a09:	6a 30                	push   $0x30
f0105a0b:	ff d6                	call   *%esi
			putch('x', putdat);
f0105a0d:	83 c4 08             	add    $0x8,%esp
f0105a10:	53                   	push   %ebx
f0105a11:	6a 78                	push   $0x78
f0105a13:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105a15:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a18:	8d 50 04             	lea    0x4(%eax),%edx
f0105a1b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105a1e:	8b 00                	mov    (%eax),%eax
f0105a20:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0105a25:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105a28:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0105a2d:	eb 0d                	jmp    f0105a3c <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105a2f:	8d 45 14             	lea    0x14(%ebp),%eax
f0105a32:	e8 3b fc ff ff       	call   f0105672 <getuint>
			base = 16;
f0105a37:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105a3c:	83 ec 0c             	sub    $0xc,%esp
f0105a3f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0105a43:	57                   	push   %edi
f0105a44:	ff 75 e0             	pushl  -0x20(%ebp)
f0105a47:	51                   	push   %ecx
f0105a48:	52                   	push   %edx
f0105a49:	50                   	push   %eax
f0105a4a:	89 da                	mov    %ebx,%edx
f0105a4c:	89 f0                	mov    %esi,%eax
f0105a4e:	e8 70 fb ff ff       	call   f01055c3 <printnum>
			break;
f0105a53:	83 c4 20             	add    $0x20,%esp
f0105a56:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105a59:	e9 ae fc ff ff       	jmp    f010570c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105a5e:	83 ec 08             	sub    $0x8,%esp
f0105a61:	53                   	push   %ebx
f0105a62:	51                   	push   %ecx
f0105a63:	ff d6                	call   *%esi
			break;
f0105a65:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a68:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105a6b:	e9 9c fc ff ff       	jmp    f010570c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105a70:	83 ec 08             	sub    $0x8,%esp
f0105a73:	53                   	push   %ebx
f0105a74:	6a 25                	push   $0x25
f0105a76:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105a78:	83 c4 10             	add    $0x10,%esp
f0105a7b:	eb 03                	jmp    f0105a80 <vprintfmt+0x39a>
f0105a7d:	83 ef 01             	sub    $0x1,%edi
f0105a80:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0105a84:	75 f7                	jne    f0105a7d <vprintfmt+0x397>
f0105a86:	e9 81 fc ff ff       	jmp    f010570c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0105a8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105a8e:	5b                   	pop    %ebx
f0105a8f:	5e                   	pop    %esi
f0105a90:	5f                   	pop    %edi
f0105a91:	5d                   	pop    %ebp
f0105a92:	c3                   	ret    

f0105a93 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105a93:	55                   	push   %ebp
f0105a94:	89 e5                	mov    %esp,%ebp
f0105a96:	83 ec 18             	sub    $0x18,%esp
f0105a99:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a9c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105a9f:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105aa2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105aa6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105aa9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105ab0:	85 c0                	test   %eax,%eax
f0105ab2:	74 26                	je     f0105ada <vsnprintf+0x47>
f0105ab4:	85 d2                	test   %edx,%edx
f0105ab6:	7e 22                	jle    f0105ada <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105ab8:	ff 75 14             	pushl  0x14(%ebp)
f0105abb:	ff 75 10             	pushl  0x10(%ebp)
f0105abe:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105ac1:	50                   	push   %eax
f0105ac2:	68 ac 56 10 f0       	push   $0xf01056ac
f0105ac7:	e8 1a fc ff ff       	call   f01056e6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105acc:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105acf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105ad5:	83 c4 10             	add    $0x10,%esp
f0105ad8:	eb 05                	jmp    f0105adf <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105ada:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105adf:	c9                   	leave  
f0105ae0:	c3                   	ret    

f0105ae1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105ae1:	55                   	push   %ebp
f0105ae2:	89 e5                	mov    %esp,%ebp
f0105ae4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105ae7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105aea:	50                   	push   %eax
f0105aeb:	ff 75 10             	pushl  0x10(%ebp)
f0105aee:	ff 75 0c             	pushl  0xc(%ebp)
f0105af1:	ff 75 08             	pushl  0x8(%ebp)
f0105af4:	e8 9a ff ff ff       	call   f0105a93 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105af9:	c9                   	leave  
f0105afa:	c3                   	ret    

f0105afb <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105afb:	55                   	push   %ebp
f0105afc:	89 e5                	mov    %esp,%ebp
f0105afe:	57                   	push   %edi
f0105aff:	56                   	push   %esi
f0105b00:	53                   	push   %ebx
f0105b01:	83 ec 0c             	sub    $0xc,%esp
f0105b04:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105b07:	85 c0                	test   %eax,%eax
f0105b09:	74 11                	je     f0105b1c <readline+0x21>
		cprintf("%s", prompt);
f0105b0b:	83 ec 08             	sub    $0x8,%esp
f0105b0e:	50                   	push   %eax
f0105b0f:	68 66 79 10 f0       	push   $0xf0107966
f0105b14:	e8 4f e1 ff ff       	call   f0103c68 <cprintf>
f0105b19:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105b1c:	83 ec 0c             	sub    $0xc,%esp
f0105b1f:	6a 00                	push   $0x0
f0105b21:	e8 94 ac ff ff       	call   f01007ba <iscons>
f0105b26:	89 c7                	mov    %eax,%edi
f0105b28:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f0105b2b:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105b30:	e8 74 ac ff ff       	call   f01007a9 <getchar>
f0105b35:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105b37:	85 c0                	test   %eax,%eax
f0105b39:	79 29                	jns    f0105b64 <readline+0x69>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f0105b3b:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f0105b40:	83 fb f8             	cmp    $0xfffffff8,%ebx
f0105b43:	0f 84 9b 00 00 00    	je     f0105be4 <readline+0xe9>
				cprintf("read error: %e\n", c);
f0105b49:	83 ec 08             	sub    $0x8,%esp
f0105b4c:	53                   	push   %ebx
f0105b4d:	68 ff 85 10 f0       	push   $0xf01085ff
f0105b52:	e8 11 e1 ff ff       	call   f0103c68 <cprintf>
f0105b57:	83 c4 10             	add    $0x10,%esp
			return NULL;
f0105b5a:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b5f:	e9 80 00 00 00       	jmp    f0105be4 <readline+0xe9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105b64:	83 f8 08             	cmp    $0x8,%eax
f0105b67:	0f 94 c2             	sete   %dl
f0105b6a:	83 f8 7f             	cmp    $0x7f,%eax
f0105b6d:	0f 94 c0             	sete   %al
f0105b70:	08 c2                	or     %al,%dl
f0105b72:	74 1a                	je     f0105b8e <readline+0x93>
f0105b74:	85 f6                	test   %esi,%esi
f0105b76:	7e 16                	jle    f0105b8e <readline+0x93>
			if (echoing)
f0105b78:	85 ff                	test   %edi,%edi
f0105b7a:	74 0d                	je     f0105b89 <readline+0x8e>
				cputchar('\b');
f0105b7c:	83 ec 0c             	sub    $0xc,%esp
f0105b7f:	6a 08                	push   $0x8
f0105b81:	e8 13 ac ff ff       	call   f0100799 <cputchar>
f0105b86:	83 c4 10             	add    $0x10,%esp
			i--;
f0105b89:	83 ee 01             	sub    $0x1,%esi
f0105b8c:	eb a2                	jmp    f0105b30 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105b8e:	83 fb 1f             	cmp    $0x1f,%ebx
f0105b91:	7e 26                	jle    f0105bb9 <readline+0xbe>
f0105b93:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105b99:	7f 1e                	jg     f0105bb9 <readline+0xbe>
			if (echoing)
f0105b9b:	85 ff                	test   %edi,%edi
f0105b9d:	74 0c                	je     f0105bab <readline+0xb0>
				cputchar(c);
f0105b9f:	83 ec 0c             	sub    $0xc,%esp
f0105ba2:	53                   	push   %ebx
f0105ba3:	e8 f1 ab ff ff       	call   f0100799 <cputchar>
f0105ba8:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105bab:	88 9e 80 8a 21 f0    	mov    %bl,-0xfde7580(%esi)
f0105bb1:	8d 76 01             	lea    0x1(%esi),%esi
f0105bb4:	e9 77 ff ff ff       	jmp    f0105b30 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105bb9:	83 fb 0a             	cmp    $0xa,%ebx
f0105bbc:	74 09                	je     f0105bc7 <readline+0xcc>
f0105bbe:	83 fb 0d             	cmp    $0xd,%ebx
f0105bc1:	0f 85 69 ff ff ff    	jne    f0105b30 <readline+0x35>
			if (echoing)
f0105bc7:	85 ff                	test   %edi,%edi
f0105bc9:	74 0d                	je     f0105bd8 <readline+0xdd>
				cputchar('\n');
f0105bcb:	83 ec 0c             	sub    $0xc,%esp
f0105bce:	6a 0a                	push   $0xa
f0105bd0:	e8 c4 ab ff ff       	call   f0100799 <cputchar>
f0105bd5:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0105bd8:	c6 86 80 8a 21 f0 00 	movb   $0x0,-0xfde7580(%esi)
			return buf;
f0105bdf:	b8 80 8a 21 f0       	mov    $0xf0218a80,%eax
		}
	}
}
f0105be4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105be7:	5b                   	pop    %ebx
f0105be8:	5e                   	pop    %esi
f0105be9:	5f                   	pop    %edi
f0105bea:	5d                   	pop    %ebp
f0105beb:	c3                   	ret    

f0105bec <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105bec:	55                   	push   %ebp
f0105bed:	89 e5                	mov    %esp,%ebp
f0105bef:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105bf2:	b8 00 00 00 00       	mov    $0x0,%eax
f0105bf7:	eb 03                	jmp    f0105bfc <strlen+0x10>
		n++;
f0105bf9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105bfc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105c00:	75 f7                	jne    f0105bf9 <strlen+0xd>
		n++;
	return n;
}
f0105c02:	5d                   	pop    %ebp
f0105c03:	c3                   	ret    

f0105c04 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105c04:	55                   	push   %ebp
f0105c05:	89 e5                	mov    %esp,%ebp
f0105c07:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105c0a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105c0d:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c12:	eb 03                	jmp    f0105c17 <strnlen+0x13>
		n++;
f0105c14:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105c17:	39 c2                	cmp    %eax,%edx
f0105c19:	74 08                	je     f0105c23 <strnlen+0x1f>
f0105c1b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0105c1f:	75 f3                	jne    f0105c14 <strnlen+0x10>
f0105c21:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0105c23:	5d                   	pop    %ebp
f0105c24:	c3                   	ret    

f0105c25 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105c25:	55                   	push   %ebp
f0105c26:	89 e5                	mov    %esp,%ebp
f0105c28:	53                   	push   %ebx
f0105c29:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105c2f:	89 c2                	mov    %eax,%edx
f0105c31:	83 c2 01             	add    $0x1,%edx
f0105c34:	83 c1 01             	add    $0x1,%ecx
f0105c37:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105c3b:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105c3e:	84 db                	test   %bl,%bl
f0105c40:	75 ef                	jne    f0105c31 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105c42:	5b                   	pop    %ebx
f0105c43:	5d                   	pop    %ebp
f0105c44:	c3                   	ret    

f0105c45 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105c45:	55                   	push   %ebp
f0105c46:	89 e5                	mov    %esp,%ebp
f0105c48:	53                   	push   %ebx
f0105c49:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105c4c:	53                   	push   %ebx
f0105c4d:	e8 9a ff ff ff       	call   f0105bec <strlen>
f0105c52:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105c55:	ff 75 0c             	pushl  0xc(%ebp)
f0105c58:	01 d8                	add    %ebx,%eax
f0105c5a:	50                   	push   %eax
f0105c5b:	e8 c5 ff ff ff       	call   f0105c25 <strcpy>
	return dst;
}
f0105c60:	89 d8                	mov    %ebx,%eax
f0105c62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105c65:	c9                   	leave  
f0105c66:	c3                   	ret    

f0105c67 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105c67:	55                   	push   %ebp
f0105c68:	89 e5                	mov    %esp,%ebp
f0105c6a:	56                   	push   %esi
f0105c6b:	53                   	push   %ebx
f0105c6c:	8b 75 08             	mov    0x8(%ebp),%esi
f0105c6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105c72:	89 f3                	mov    %esi,%ebx
f0105c74:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105c77:	89 f2                	mov    %esi,%edx
f0105c79:	eb 0f                	jmp    f0105c8a <strncpy+0x23>
		*dst++ = *src;
f0105c7b:	83 c2 01             	add    $0x1,%edx
f0105c7e:	0f b6 01             	movzbl (%ecx),%eax
f0105c81:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105c84:	80 39 01             	cmpb   $0x1,(%ecx)
f0105c87:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105c8a:	39 da                	cmp    %ebx,%edx
f0105c8c:	75 ed                	jne    f0105c7b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105c8e:	89 f0                	mov    %esi,%eax
f0105c90:	5b                   	pop    %ebx
f0105c91:	5e                   	pop    %esi
f0105c92:	5d                   	pop    %ebp
f0105c93:	c3                   	ret    

f0105c94 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105c94:	55                   	push   %ebp
f0105c95:	89 e5                	mov    %esp,%ebp
f0105c97:	56                   	push   %esi
f0105c98:	53                   	push   %ebx
f0105c99:	8b 75 08             	mov    0x8(%ebp),%esi
f0105c9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105c9f:	8b 55 10             	mov    0x10(%ebp),%edx
f0105ca2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105ca4:	85 d2                	test   %edx,%edx
f0105ca6:	74 21                	je     f0105cc9 <strlcpy+0x35>
f0105ca8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105cac:	89 f2                	mov    %esi,%edx
f0105cae:	eb 09                	jmp    f0105cb9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105cb0:	83 c2 01             	add    $0x1,%edx
f0105cb3:	83 c1 01             	add    $0x1,%ecx
f0105cb6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105cb9:	39 c2                	cmp    %eax,%edx
f0105cbb:	74 09                	je     f0105cc6 <strlcpy+0x32>
f0105cbd:	0f b6 19             	movzbl (%ecx),%ebx
f0105cc0:	84 db                	test   %bl,%bl
f0105cc2:	75 ec                	jne    f0105cb0 <strlcpy+0x1c>
f0105cc4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105cc6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105cc9:	29 f0                	sub    %esi,%eax
}
f0105ccb:	5b                   	pop    %ebx
f0105ccc:	5e                   	pop    %esi
f0105ccd:	5d                   	pop    %ebp
f0105cce:	c3                   	ret    

f0105ccf <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105ccf:	55                   	push   %ebp
f0105cd0:	89 e5                	mov    %esp,%ebp
f0105cd2:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105cd5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105cd8:	eb 06                	jmp    f0105ce0 <strcmp+0x11>
		p++, q++;
f0105cda:	83 c1 01             	add    $0x1,%ecx
f0105cdd:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105ce0:	0f b6 01             	movzbl (%ecx),%eax
f0105ce3:	84 c0                	test   %al,%al
f0105ce5:	74 04                	je     f0105ceb <strcmp+0x1c>
f0105ce7:	3a 02                	cmp    (%edx),%al
f0105ce9:	74 ef                	je     f0105cda <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105ceb:	0f b6 c0             	movzbl %al,%eax
f0105cee:	0f b6 12             	movzbl (%edx),%edx
f0105cf1:	29 d0                	sub    %edx,%eax
}
f0105cf3:	5d                   	pop    %ebp
f0105cf4:	c3                   	ret    

f0105cf5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105cf5:	55                   	push   %ebp
f0105cf6:	89 e5                	mov    %esp,%ebp
f0105cf8:	53                   	push   %ebx
f0105cf9:	8b 45 08             	mov    0x8(%ebp),%eax
f0105cfc:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105cff:	89 c3                	mov    %eax,%ebx
f0105d01:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105d04:	eb 06                	jmp    f0105d0c <strncmp+0x17>
		n--, p++, q++;
f0105d06:	83 c0 01             	add    $0x1,%eax
f0105d09:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105d0c:	39 d8                	cmp    %ebx,%eax
f0105d0e:	74 15                	je     f0105d25 <strncmp+0x30>
f0105d10:	0f b6 08             	movzbl (%eax),%ecx
f0105d13:	84 c9                	test   %cl,%cl
f0105d15:	74 04                	je     f0105d1b <strncmp+0x26>
f0105d17:	3a 0a                	cmp    (%edx),%cl
f0105d19:	74 eb                	je     f0105d06 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105d1b:	0f b6 00             	movzbl (%eax),%eax
f0105d1e:	0f b6 12             	movzbl (%edx),%edx
f0105d21:	29 d0                	sub    %edx,%eax
f0105d23:	eb 05                	jmp    f0105d2a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105d25:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105d2a:	5b                   	pop    %ebx
f0105d2b:	5d                   	pop    %ebp
f0105d2c:	c3                   	ret    

f0105d2d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105d2d:	55                   	push   %ebp
f0105d2e:	89 e5                	mov    %esp,%ebp
f0105d30:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d33:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105d37:	eb 07                	jmp    f0105d40 <strchr+0x13>
		if (*s == c)
f0105d39:	38 ca                	cmp    %cl,%dl
f0105d3b:	74 0f                	je     f0105d4c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105d3d:	83 c0 01             	add    $0x1,%eax
f0105d40:	0f b6 10             	movzbl (%eax),%edx
f0105d43:	84 d2                	test   %dl,%dl
f0105d45:	75 f2                	jne    f0105d39 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0105d47:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105d4c:	5d                   	pop    %ebp
f0105d4d:	c3                   	ret    

f0105d4e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105d4e:	55                   	push   %ebp
f0105d4f:	89 e5                	mov    %esp,%ebp
f0105d51:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d54:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105d58:	eb 03                	jmp    f0105d5d <strfind+0xf>
f0105d5a:	83 c0 01             	add    $0x1,%eax
f0105d5d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105d60:	38 ca                	cmp    %cl,%dl
f0105d62:	74 04                	je     f0105d68 <strfind+0x1a>
f0105d64:	84 d2                	test   %dl,%dl
f0105d66:	75 f2                	jne    f0105d5a <strfind+0xc>
			break;
	return (char *) s;
}
f0105d68:	5d                   	pop    %ebp
f0105d69:	c3                   	ret    

f0105d6a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105d6a:	55                   	push   %ebp
f0105d6b:	89 e5                	mov    %esp,%ebp
f0105d6d:	57                   	push   %edi
f0105d6e:	56                   	push   %esi
f0105d6f:	53                   	push   %ebx
f0105d70:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105d73:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105d76:	85 c9                	test   %ecx,%ecx
f0105d78:	74 36                	je     f0105db0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105d7a:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105d80:	75 28                	jne    f0105daa <memset+0x40>
f0105d82:	f6 c1 03             	test   $0x3,%cl
f0105d85:	75 23                	jne    f0105daa <memset+0x40>
		c &= 0xFF;
f0105d87:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105d8b:	89 d3                	mov    %edx,%ebx
f0105d8d:	c1 e3 08             	shl    $0x8,%ebx
f0105d90:	89 d6                	mov    %edx,%esi
f0105d92:	c1 e6 18             	shl    $0x18,%esi
f0105d95:	89 d0                	mov    %edx,%eax
f0105d97:	c1 e0 10             	shl    $0x10,%eax
f0105d9a:	09 f0                	or     %esi,%eax
f0105d9c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0105d9e:	89 d8                	mov    %ebx,%eax
f0105da0:	09 d0                	or     %edx,%eax
f0105da2:	c1 e9 02             	shr    $0x2,%ecx
f0105da5:	fc                   	cld    
f0105da6:	f3 ab                	rep stos %eax,%es:(%edi)
f0105da8:	eb 06                	jmp    f0105db0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105daa:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105dad:	fc                   	cld    
f0105dae:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105db0:	89 f8                	mov    %edi,%eax
f0105db2:	5b                   	pop    %ebx
f0105db3:	5e                   	pop    %esi
f0105db4:	5f                   	pop    %edi
f0105db5:	5d                   	pop    %ebp
f0105db6:	c3                   	ret    

f0105db7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105db7:	55                   	push   %ebp
f0105db8:	89 e5                	mov    %esp,%ebp
f0105dba:	57                   	push   %edi
f0105dbb:	56                   	push   %esi
f0105dbc:	8b 45 08             	mov    0x8(%ebp),%eax
f0105dbf:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105dc2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105dc5:	39 c6                	cmp    %eax,%esi
f0105dc7:	73 35                	jae    f0105dfe <memmove+0x47>
f0105dc9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105dcc:	39 d0                	cmp    %edx,%eax
f0105dce:	73 2e                	jae    f0105dfe <memmove+0x47>
		s += n;
		d += n;
f0105dd0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105dd3:	89 d6                	mov    %edx,%esi
f0105dd5:	09 fe                	or     %edi,%esi
f0105dd7:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105ddd:	75 13                	jne    f0105df2 <memmove+0x3b>
f0105ddf:	f6 c1 03             	test   $0x3,%cl
f0105de2:	75 0e                	jne    f0105df2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0105de4:	83 ef 04             	sub    $0x4,%edi
f0105de7:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105dea:	c1 e9 02             	shr    $0x2,%ecx
f0105ded:	fd                   	std    
f0105dee:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105df0:	eb 09                	jmp    f0105dfb <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105df2:	83 ef 01             	sub    $0x1,%edi
f0105df5:	8d 72 ff             	lea    -0x1(%edx),%esi
f0105df8:	fd                   	std    
f0105df9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105dfb:	fc                   	cld    
f0105dfc:	eb 1d                	jmp    f0105e1b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105dfe:	89 f2                	mov    %esi,%edx
f0105e00:	09 c2                	or     %eax,%edx
f0105e02:	f6 c2 03             	test   $0x3,%dl
f0105e05:	75 0f                	jne    f0105e16 <memmove+0x5f>
f0105e07:	f6 c1 03             	test   $0x3,%cl
f0105e0a:	75 0a                	jne    f0105e16 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0105e0c:	c1 e9 02             	shr    $0x2,%ecx
f0105e0f:	89 c7                	mov    %eax,%edi
f0105e11:	fc                   	cld    
f0105e12:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105e14:	eb 05                	jmp    f0105e1b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105e16:	89 c7                	mov    %eax,%edi
f0105e18:	fc                   	cld    
f0105e19:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105e1b:	5e                   	pop    %esi
f0105e1c:	5f                   	pop    %edi
f0105e1d:	5d                   	pop    %ebp
f0105e1e:	c3                   	ret    

f0105e1f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105e1f:	55                   	push   %ebp
f0105e20:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105e22:	ff 75 10             	pushl  0x10(%ebp)
f0105e25:	ff 75 0c             	pushl  0xc(%ebp)
f0105e28:	ff 75 08             	pushl  0x8(%ebp)
f0105e2b:	e8 87 ff ff ff       	call   f0105db7 <memmove>
}
f0105e30:	c9                   	leave  
f0105e31:	c3                   	ret    

f0105e32 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105e32:	55                   	push   %ebp
f0105e33:	89 e5                	mov    %esp,%ebp
f0105e35:	56                   	push   %esi
f0105e36:	53                   	push   %ebx
f0105e37:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e3a:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105e3d:	89 c6                	mov    %eax,%esi
f0105e3f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105e42:	eb 1a                	jmp    f0105e5e <memcmp+0x2c>
		if (*s1 != *s2)
f0105e44:	0f b6 08             	movzbl (%eax),%ecx
f0105e47:	0f b6 1a             	movzbl (%edx),%ebx
f0105e4a:	38 d9                	cmp    %bl,%cl
f0105e4c:	74 0a                	je     f0105e58 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0105e4e:	0f b6 c1             	movzbl %cl,%eax
f0105e51:	0f b6 db             	movzbl %bl,%ebx
f0105e54:	29 d8                	sub    %ebx,%eax
f0105e56:	eb 0f                	jmp    f0105e67 <memcmp+0x35>
		s1++, s2++;
f0105e58:	83 c0 01             	add    $0x1,%eax
f0105e5b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105e5e:	39 f0                	cmp    %esi,%eax
f0105e60:	75 e2                	jne    f0105e44 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105e62:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105e67:	5b                   	pop    %ebx
f0105e68:	5e                   	pop    %esi
f0105e69:	5d                   	pop    %ebp
f0105e6a:	c3                   	ret    

f0105e6b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105e6b:	55                   	push   %ebp
f0105e6c:	89 e5                	mov    %esp,%ebp
f0105e6e:	53                   	push   %ebx
f0105e6f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0105e72:	89 c1                	mov    %eax,%ecx
f0105e74:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0105e77:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105e7b:	eb 0a                	jmp    f0105e87 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105e7d:	0f b6 10             	movzbl (%eax),%edx
f0105e80:	39 da                	cmp    %ebx,%edx
f0105e82:	74 07                	je     f0105e8b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105e84:	83 c0 01             	add    $0x1,%eax
f0105e87:	39 c8                	cmp    %ecx,%eax
f0105e89:	72 f2                	jb     f0105e7d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105e8b:	5b                   	pop    %ebx
f0105e8c:	5d                   	pop    %ebp
f0105e8d:	c3                   	ret    

f0105e8e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105e8e:	55                   	push   %ebp
f0105e8f:	89 e5                	mov    %esp,%ebp
f0105e91:	57                   	push   %edi
f0105e92:	56                   	push   %esi
f0105e93:	53                   	push   %ebx
f0105e94:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105e97:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105e9a:	eb 03                	jmp    f0105e9f <strtol+0x11>
		s++;
f0105e9c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105e9f:	0f b6 01             	movzbl (%ecx),%eax
f0105ea2:	3c 20                	cmp    $0x20,%al
f0105ea4:	74 f6                	je     f0105e9c <strtol+0xe>
f0105ea6:	3c 09                	cmp    $0x9,%al
f0105ea8:	74 f2                	je     f0105e9c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105eaa:	3c 2b                	cmp    $0x2b,%al
f0105eac:	75 0a                	jne    f0105eb8 <strtol+0x2a>
		s++;
f0105eae:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105eb1:	bf 00 00 00 00       	mov    $0x0,%edi
f0105eb6:	eb 11                	jmp    f0105ec9 <strtol+0x3b>
f0105eb8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105ebd:	3c 2d                	cmp    $0x2d,%al
f0105ebf:	75 08                	jne    f0105ec9 <strtol+0x3b>
		s++, neg = 1;
f0105ec1:	83 c1 01             	add    $0x1,%ecx
f0105ec4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105ec9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105ecf:	75 15                	jne    f0105ee6 <strtol+0x58>
f0105ed1:	80 39 30             	cmpb   $0x30,(%ecx)
f0105ed4:	75 10                	jne    f0105ee6 <strtol+0x58>
f0105ed6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105eda:	75 7c                	jne    f0105f58 <strtol+0xca>
		s += 2, base = 16;
f0105edc:	83 c1 02             	add    $0x2,%ecx
f0105edf:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105ee4:	eb 16                	jmp    f0105efc <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0105ee6:	85 db                	test   %ebx,%ebx
f0105ee8:	75 12                	jne    f0105efc <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105eea:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105eef:	80 39 30             	cmpb   $0x30,(%ecx)
f0105ef2:	75 08                	jne    f0105efc <strtol+0x6e>
		s++, base = 8;
f0105ef4:	83 c1 01             	add    $0x1,%ecx
f0105ef7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0105efc:	b8 00 00 00 00       	mov    $0x0,%eax
f0105f01:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105f04:	0f b6 11             	movzbl (%ecx),%edx
f0105f07:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105f0a:	89 f3                	mov    %esi,%ebx
f0105f0c:	80 fb 09             	cmp    $0x9,%bl
f0105f0f:	77 08                	ja     f0105f19 <strtol+0x8b>
			dig = *s - '0';
f0105f11:	0f be d2             	movsbl %dl,%edx
f0105f14:	83 ea 30             	sub    $0x30,%edx
f0105f17:	eb 22                	jmp    f0105f3b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0105f19:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105f1c:	89 f3                	mov    %esi,%ebx
f0105f1e:	80 fb 19             	cmp    $0x19,%bl
f0105f21:	77 08                	ja     f0105f2b <strtol+0x9d>
			dig = *s - 'a' + 10;
f0105f23:	0f be d2             	movsbl %dl,%edx
f0105f26:	83 ea 57             	sub    $0x57,%edx
f0105f29:	eb 10                	jmp    f0105f3b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0105f2b:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105f2e:	89 f3                	mov    %esi,%ebx
f0105f30:	80 fb 19             	cmp    $0x19,%bl
f0105f33:	77 16                	ja     f0105f4b <strtol+0xbd>
			dig = *s - 'A' + 10;
f0105f35:	0f be d2             	movsbl %dl,%edx
f0105f38:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0105f3b:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105f3e:	7d 0b                	jge    f0105f4b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0105f40:	83 c1 01             	add    $0x1,%ecx
f0105f43:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105f47:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0105f49:	eb b9                	jmp    f0105f04 <strtol+0x76>

	if (endptr)
f0105f4b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105f4f:	74 0d                	je     f0105f5e <strtol+0xd0>
		*endptr = (char *) s;
f0105f51:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105f54:	89 0e                	mov    %ecx,(%esi)
f0105f56:	eb 06                	jmp    f0105f5e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105f58:	85 db                	test   %ebx,%ebx
f0105f5a:	74 98                	je     f0105ef4 <strtol+0x66>
f0105f5c:	eb 9e                	jmp    f0105efc <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0105f5e:	89 c2                	mov    %eax,%edx
f0105f60:	f7 da                	neg    %edx
f0105f62:	85 ff                	test   %edi,%edi
f0105f64:	0f 45 c2             	cmovne %edx,%eax
}
f0105f67:	5b                   	pop    %ebx
f0105f68:	5e                   	pop    %esi
f0105f69:	5f                   	pop    %edi
f0105f6a:	5d                   	pop    %ebp
f0105f6b:	c3                   	ret    

f0105f6c <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105f6c:	fa                   	cli    

	xorw    %ax, %ax
f0105f6d:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105f6f:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105f71:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105f73:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105f75:	0f 01 16             	lgdtl  (%esi)
f0105f78:	74 70                	je     f0105fea <mpsearch1+0x3>
	movl    %cr0, %eax
f0105f7a:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105f7d:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105f81:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105f84:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105f8a:	08 00                	or     %al,(%eax)

f0105f8c <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105f8c:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105f90:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105f92:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105f94:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105f96:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105f9a:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105f9c:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105f9e:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl    %eax, %cr3
f0105fa3:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105fa6:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105fa9:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105fae:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105fb1:	8b 25 84 8e 21 f0    	mov    0xf0218e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105fb7:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105fbc:	b8 c7 01 10 f0       	mov    $0xf01001c7,%eax
	call    *%eax
f0105fc1:	ff d0                	call   *%eax

f0105fc3 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105fc3:	eb fe                	jmp    f0105fc3 <spin>
f0105fc5:	8d 76 00             	lea    0x0(%esi),%esi

f0105fc8 <gdt>:
	...
f0105fd0:	ff                   	(bad)  
f0105fd1:	ff 00                	incl   (%eax)
f0105fd3:	00 00                	add    %al,(%eax)
f0105fd5:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105fdc:	00                   	.byte 0x0
f0105fdd:	92                   	xchg   %eax,%edx
f0105fde:	cf                   	iret   
	...

f0105fe0 <gdtdesc>:
f0105fe0:	17                   	pop    %ss
f0105fe1:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105fe6 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105fe6:	90                   	nop

f0105fe7 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105fe7:	55                   	push   %ebp
f0105fe8:	89 e5                	mov    %esp,%ebp
f0105fea:	57                   	push   %edi
f0105feb:	56                   	push   %esi
f0105fec:	53                   	push   %ebx
f0105fed:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105ff0:	8b 0d 88 8e 21 f0    	mov    0xf0218e88,%ecx
f0105ff6:	89 c3                	mov    %eax,%ebx
f0105ff8:	c1 eb 0c             	shr    $0xc,%ebx
f0105ffb:	39 cb                	cmp    %ecx,%ebx
f0105ffd:	72 12                	jb     f0106011 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105fff:	50                   	push   %eax
f0106000:	68 44 6a 10 f0       	push   $0xf0106a44
f0106005:	6a 57                	push   $0x57
f0106007:	68 9d 87 10 f0       	push   $0xf010879d
f010600c:	e8 2f a0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106011:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0106017:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106019:	89 c2                	mov    %eax,%edx
f010601b:	c1 ea 0c             	shr    $0xc,%edx
f010601e:	39 ca                	cmp    %ecx,%edx
f0106020:	72 12                	jb     f0106034 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106022:	50                   	push   %eax
f0106023:	68 44 6a 10 f0       	push   $0xf0106a44
f0106028:	6a 57                	push   $0x57
f010602a:	68 9d 87 10 f0       	push   $0xf010879d
f010602f:	e8 0c a0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106034:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f010603a:	eb 2f                	jmp    f010606b <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010603c:	83 ec 04             	sub    $0x4,%esp
f010603f:	6a 04                	push   $0x4
f0106041:	68 ad 87 10 f0       	push   $0xf01087ad
f0106046:	53                   	push   %ebx
f0106047:	e8 e6 fd ff ff       	call   f0105e32 <memcmp>
f010604c:	83 c4 10             	add    $0x10,%esp
f010604f:	85 c0                	test   %eax,%eax
f0106051:	75 15                	jne    f0106068 <mpsearch1+0x81>
f0106053:	89 da                	mov    %ebx,%edx
f0106055:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0106058:	0f b6 0a             	movzbl (%edx),%ecx
f010605b:	01 c8                	add    %ecx,%eax
f010605d:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106060:	39 d7                	cmp    %edx,%edi
f0106062:	75 f4                	jne    f0106058 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106064:	84 c0                	test   %al,%al
f0106066:	74 0e                	je     f0106076 <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0106068:	83 c3 10             	add    $0x10,%ebx
f010606b:	39 f3                	cmp    %esi,%ebx
f010606d:	72 cd                	jb     f010603c <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f010606f:	b8 00 00 00 00       	mov    $0x0,%eax
f0106074:	eb 02                	jmp    f0106078 <mpsearch1+0x91>
f0106076:	89 d8                	mov    %ebx,%eax
}
f0106078:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010607b:	5b                   	pop    %ebx
f010607c:	5e                   	pop    %esi
f010607d:	5f                   	pop    %edi
f010607e:	5d                   	pop    %ebp
f010607f:	c3                   	ret    

f0106080 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0106080:	55                   	push   %ebp
f0106081:	89 e5                	mov    %esp,%ebp
f0106083:	57                   	push   %edi
f0106084:	56                   	push   %esi
f0106085:	53                   	push   %ebx
f0106086:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0106089:	c7 05 c0 93 21 f0 20 	movl   $0xf0219020,0xf02193c0
f0106090:	90 21 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106093:	83 3d 88 8e 21 f0 00 	cmpl   $0x0,0xf0218e88
f010609a:	75 16                	jne    f01060b2 <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010609c:	68 00 04 00 00       	push   $0x400
f01060a1:	68 44 6a 10 f0       	push   $0xf0106a44
f01060a6:	6a 6f                	push   $0x6f
f01060a8:	68 9d 87 10 f0       	push   $0xf010879d
f01060ad:	e8 8e 9f ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f01060b2:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f01060b9:	85 c0                	test   %eax,%eax
f01060bb:	74 16                	je     f01060d3 <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f01060bd:	c1 e0 04             	shl    $0x4,%eax
f01060c0:	ba 00 04 00 00       	mov    $0x400,%edx
f01060c5:	e8 1d ff ff ff       	call   f0105fe7 <mpsearch1>
f01060ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01060cd:	85 c0                	test   %eax,%eax
f01060cf:	75 3c                	jne    f010610d <mp_init+0x8d>
f01060d1:	eb 20                	jmp    f01060f3 <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f01060d3:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01060da:	c1 e0 0a             	shl    $0xa,%eax
f01060dd:	2d 00 04 00 00       	sub    $0x400,%eax
f01060e2:	ba 00 04 00 00       	mov    $0x400,%edx
f01060e7:	e8 fb fe ff ff       	call   f0105fe7 <mpsearch1>
f01060ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01060ef:	85 c0                	test   %eax,%eax
f01060f1:	75 1a                	jne    f010610d <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f01060f3:	ba 00 00 01 00       	mov    $0x10000,%edx
f01060f8:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f01060fd:	e8 e5 fe ff ff       	call   f0105fe7 <mpsearch1>
f0106102:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0106105:	85 c0                	test   %eax,%eax
f0106107:	0f 84 5d 02 00 00    	je     f010636a <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f010610d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106110:	8b 70 04             	mov    0x4(%eax),%esi
f0106113:	85 f6                	test   %esi,%esi
f0106115:	74 06                	je     f010611d <mp_init+0x9d>
f0106117:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f010611b:	74 15                	je     f0106132 <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f010611d:	83 ec 0c             	sub    $0xc,%esp
f0106120:	68 10 86 10 f0       	push   $0xf0108610
f0106125:	e8 3e db ff ff       	call   f0103c68 <cprintf>
f010612a:	83 c4 10             	add    $0x10,%esp
f010612d:	e9 38 02 00 00       	jmp    f010636a <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106132:	89 f0                	mov    %esi,%eax
f0106134:	c1 e8 0c             	shr    $0xc,%eax
f0106137:	3b 05 88 8e 21 f0    	cmp    0xf0218e88,%eax
f010613d:	72 15                	jb     f0106154 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010613f:	56                   	push   %esi
f0106140:	68 44 6a 10 f0       	push   $0xf0106a44
f0106145:	68 90 00 00 00       	push   $0x90
f010614a:	68 9d 87 10 f0       	push   $0xf010879d
f010614f:	e8 ec 9e ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106154:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f010615a:	83 ec 04             	sub    $0x4,%esp
f010615d:	6a 04                	push   $0x4
f010615f:	68 b2 87 10 f0       	push   $0xf01087b2
f0106164:	53                   	push   %ebx
f0106165:	e8 c8 fc ff ff       	call   f0105e32 <memcmp>
f010616a:	83 c4 10             	add    $0x10,%esp
f010616d:	85 c0                	test   %eax,%eax
f010616f:	74 15                	je     f0106186 <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0106171:	83 ec 0c             	sub    $0xc,%esp
f0106174:	68 40 86 10 f0       	push   $0xf0108640
f0106179:	e8 ea da ff ff       	call   f0103c68 <cprintf>
f010617e:	83 c4 10             	add    $0x10,%esp
f0106181:	e9 e4 01 00 00       	jmp    f010636a <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0106186:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f010618a:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f010618e:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0106191:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0106196:	b8 00 00 00 00       	mov    $0x0,%eax
f010619b:	eb 0d                	jmp    f01061aa <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f010619d:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f01061a4:	f0 
f01061a5:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01061a7:	83 c0 01             	add    $0x1,%eax
f01061aa:	39 c7                	cmp    %eax,%edi
f01061ac:	75 ef                	jne    f010619d <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01061ae:	84 d2                	test   %dl,%dl
f01061b0:	74 15                	je     f01061c7 <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f01061b2:	83 ec 0c             	sub    $0xc,%esp
f01061b5:	68 74 86 10 f0       	push   $0xf0108674
f01061ba:	e8 a9 da ff ff       	call   f0103c68 <cprintf>
f01061bf:	83 c4 10             	add    $0x10,%esp
f01061c2:	e9 a3 01 00 00       	jmp    f010636a <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f01061c7:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f01061cb:	3c 01                	cmp    $0x1,%al
f01061cd:	74 1d                	je     f01061ec <mp_init+0x16c>
f01061cf:	3c 04                	cmp    $0x4,%al
f01061d1:	74 19                	je     f01061ec <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01061d3:	83 ec 08             	sub    $0x8,%esp
f01061d6:	0f b6 c0             	movzbl %al,%eax
f01061d9:	50                   	push   %eax
f01061da:	68 98 86 10 f0       	push   $0xf0108698
f01061df:	e8 84 da ff ff       	call   f0103c68 <cprintf>
f01061e4:	83 c4 10             	add    $0x10,%esp
f01061e7:	e9 7e 01 00 00       	jmp    f010636a <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01061ec:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f01061f0:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f01061f4:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01061f9:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f01061fe:	01 ce                	add    %ecx,%esi
f0106200:	eb 0d                	jmp    f010620f <mp_init+0x18f>
f0106202:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0106209:	f0 
f010620a:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f010620c:	83 c0 01             	add    $0x1,%eax
f010620f:	39 c7                	cmp    %eax,%edi
f0106211:	75 ef                	jne    f0106202 <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0106213:	89 d0                	mov    %edx,%eax
f0106215:	02 43 2a             	add    0x2a(%ebx),%al
f0106218:	74 15                	je     f010622f <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f010621a:	83 ec 0c             	sub    $0xc,%esp
f010621d:	68 b8 86 10 f0       	push   $0xf01086b8
f0106222:	e8 41 da ff ff       	call   f0103c68 <cprintf>
f0106227:	83 c4 10             	add    $0x10,%esp
f010622a:	e9 3b 01 00 00       	jmp    f010636a <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f010622f:	85 db                	test   %ebx,%ebx
f0106231:	0f 84 33 01 00 00    	je     f010636a <mp_init+0x2ea>
		return;
	ismp = 1;
f0106237:	c7 05 00 90 21 f0 01 	movl   $0x1,0xf0219000
f010623e:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0106241:	8b 43 24             	mov    0x24(%ebx),%eax
f0106244:	a3 00 a0 25 f0       	mov    %eax,0xf025a000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106249:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f010624c:	be 00 00 00 00       	mov    $0x0,%esi
f0106251:	e9 85 00 00 00       	jmp    f01062db <mp_init+0x25b>
		switch (*p) {
f0106256:	0f b6 07             	movzbl (%edi),%eax
f0106259:	84 c0                	test   %al,%al
f010625b:	74 06                	je     f0106263 <mp_init+0x1e3>
f010625d:	3c 04                	cmp    $0x4,%al
f010625f:	77 55                	ja     f01062b6 <mp_init+0x236>
f0106261:	eb 4e                	jmp    f01062b1 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0106263:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0106267:	74 11                	je     f010627a <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0106269:	6b 05 c4 93 21 f0 74 	imul   $0x74,0xf02193c4,%eax
f0106270:	05 20 90 21 f0       	add    $0xf0219020,%eax
f0106275:	a3 c0 93 21 f0       	mov    %eax,0xf02193c0
			if (ncpu < NCPU) {
f010627a:	a1 c4 93 21 f0       	mov    0xf02193c4,%eax
f010627f:	83 f8 07             	cmp    $0x7,%eax
f0106282:	7f 13                	jg     f0106297 <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f0106284:	6b d0 74             	imul   $0x74,%eax,%edx
f0106287:	88 82 20 90 21 f0    	mov    %al,-0xfde6fe0(%edx)
				ncpu++;
f010628d:	83 c0 01             	add    $0x1,%eax
f0106290:	a3 c4 93 21 f0       	mov    %eax,0xf02193c4
f0106295:	eb 15                	jmp    f01062ac <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106297:	83 ec 08             	sub    $0x8,%esp
f010629a:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f010629e:	50                   	push   %eax
f010629f:	68 e8 86 10 f0       	push   $0xf01086e8
f01062a4:	e8 bf d9 ff ff       	call   f0103c68 <cprintf>
f01062a9:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f01062ac:	83 c7 14             	add    $0x14,%edi
			continue;
f01062af:	eb 27                	jmp    f01062d8 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f01062b1:	83 c7 08             	add    $0x8,%edi
			continue;
f01062b4:	eb 22                	jmp    f01062d8 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f01062b6:	83 ec 08             	sub    $0x8,%esp
f01062b9:	0f b6 c0             	movzbl %al,%eax
f01062bc:	50                   	push   %eax
f01062bd:	68 10 87 10 f0       	push   $0xf0108710
f01062c2:	e8 a1 d9 ff ff       	call   f0103c68 <cprintf>
			ismp = 0;
f01062c7:	c7 05 00 90 21 f0 00 	movl   $0x0,0xf0219000
f01062ce:	00 00 00 
			i = conf->entry;
f01062d1:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f01062d5:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01062d8:	83 c6 01             	add    $0x1,%esi
f01062db:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f01062df:	39 c6                	cmp    %eax,%esi
f01062e1:	0f 82 6f ff ff ff    	jb     f0106256 <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f01062e7:	a1 c0 93 21 f0       	mov    0xf02193c0,%eax
f01062ec:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f01062f3:	83 3d 00 90 21 f0 00 	cmpl   $0x0,0xf0219000
f01062fa:	75 26                	jne    f0106322 <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f01062fc:	c7 05 c4 93 21 f0 01 	movl   $0x1,0xf02193c4
f0106303:	00 00 00 
		lapicaddr = 0;
f0106306:	c7 05 00 a0 25 f0 00 	movl   $0x0,0xf025a000
f010630d:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106310:	83 ec 0c             	sub    $0xc,%esp
f0106313:	68 30 87 10 f0       	push   $0xf0108730
f0106318:	e8 4b d9 ff ff       	call   f0103c68 <cprintf>
		return;
f010631d:	83 c4 10             	add    $0x10,%esp
f0106320:	eb 48                	jmp    f010636a <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0106322:	83 ec 04             	sub    $0x4,%esp
f0106325:	ff 35 c4 93 21 f0    	pushl  0xf02193c4
f010632b:	0f b6 00             	movzbl (%eax),%eax
f010632e:	50                   	push   %eax
f010632f:	68 b7 87 10 f0       	push   $0xf01087b7
f0106334:	e8 2f d9 ff ff       	call   f0103c68 <cprintf>

	if (mp->imcrp) {
f0106339:	83 c4 10             	add    $0x10,%esp
f010633c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010633f:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106343:	74 25                	je     f010636a <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0106345:	83 ec 0c             	sub    $0xc,%esp
f0106348:	68 5c 87 10 f0       	push   $0xf010875c
f010634d:	e8 16 d9 ff ff       	call   f0103c68 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106352:	ba 22 00 00 00       	mov    $0x22,%edx
f0106357:	b8 70 00 00 00       	mov    $0x70,%eax
f010635c:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010635d:	ba 23 00 00 00       	mov    $0x23,%edx
f0106362:	ec                   	in     (%dx),%al
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106363:	83 c8 01             	or     $0x1,%eax
f0106366:	ee                   	out    %al,(%dx)
f0106367:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f010636a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010636d:	5b                   	pop    %ebx
f010636e:	5e                   	pop    %esi
f010636f:	5f                   	pop    %edi
f0106370:	5d                   	pop    %ebp
f0106371:	c3                   	ret    

f0106372 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0106372:	55                   	push   %ebp
f0106373:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0106375:	8b 0d 04 a0 25 f0    	mov    0xf025a004,%ecx
f010637b:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f010637e:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106380:	a1 04 a0 25 f0       	mov    0xf025a004,%eax
f0106385:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106388:	5d                   	pop    %ebp
f0106389:	c3                   	ret    

f010638a <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f010638a:	55                   	push   %ebp
f010638b:	89 e5                	mov    %esp,%ebp
	if (lapic)
f010638d:	a1 04 a0 25 f0       	mov    0xf025a004,%eax
f0106392:	85 c0                	test   %eax,%eax
f0106394:	74 08                	je     f010639e <cpunum+0x14>
		return lapic[ID] >> 24;
f0106396:	8b 40 20             	mov    0x20(%eax),%eax
f0106399:	c1 e8 18             	shr    $0x18,%eax
f010639c:	eb 05                	jmp    f01063a3 <cpunum+0x19>
	return 0;
f010639e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01063a3:	5d                   	pop    %ebp
f01063a4:	c3                   	ret    

f01063a5 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f01063a5:	a1 00 a0 25 f0       	mov    0xf025a000,%eax
f01063aa:	85 c0                	test   %eax,%eax
f01063ac:	0f 84 21 01 00 00    	je     f01064d3 <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f01063b2:	55                   	push   %ebp
f01063b3:	89 e5                	mov    %esp,%ebp
f01063b5:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f01063b8:	68 00 10 00 00       	push   $0x1000
f01063bd:	50                   	push   %eax
f01063be:	e8 71 b0 ff ff       	call   f0101434 <mmio_map_region>
f01063c3:	a3 04 a0 25 f0       	mov    %eax,0xf025a004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f01063c8:	ba 27 01 00 00       	mov    $0x127,%edx
f01063cd:	b8 3c 00 00 00       	mov    $0x3c,%eax
f01063d2:	e8 9b ff ff ff       	call   f0106372 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f01063d7:	ba 0b 00 00 00       	mov    $0xb,%edx
f01063dc:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01063e1:	e8 8c ff ff ff       	call   f0106372 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01063e6:	ba 20 00 02 00       	mov    $0x20020,%edx
f01063eb:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01063f0:	e8 7d ff ff ff       	call   f0106372 <lapicw>
	lapicw(TICR, 10000000); 
f01063f5:	ba 80 96 98 00       	mov    $0x989680,%edx
f01063fa:	b8 e0 00 00 00       	mov    $0xe0,%eax
f01063ff:	e8 6e ff ff ff       	call   f0106372 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0106404:	e8 81 ff ff ff       	call   f010638a <cpunum>
f0106409:	6b c0 74             	imul   $0x74,%eax,%eax
f010640c:	05 20 90 21 f0       	add    $0xf0219020,%eax
f0106411:	83 c4 10             	add    $0x10,%esp
f0106414:	39 05 c0 93 21 f0    	cmp    %eax,0xf02193c0
f010641a:	74 0f                	je     f010642b <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f010641c:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106421:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0106426:	e8 47 ff ff ff       	call   f0106372 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f010642b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106430:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0106435:	e8 38 ff ff ff       	call   f0106372 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f010643a:	a1 04 a0 25 f0       	mov    0xf025a004,%eax
f010643f:	8b 40 30             	mov    0x30(%eax),%eax
f0106442:	c1 e8 10             	shr    $0x10,%eax
f0106445:	3c 03                	cmp    $0x3,%al
f0106447:	76 0f                	jbe    f0106458 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0106449:	ba 00 00 01 00       	mov    $0x10000,%edx
f010644e:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0106453:	e8 1a ff ff ff       	call   f0106372 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106458:	ba 33 00 00 00       	mov    $0x33,%edx
f010645d:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106462:	e8 0b ff ff ff       	call   f0106372 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0106467:	ba 00 00 00 00       	mov    $0x0,%edx
f010646c:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106471:	e8 fc fe ff ff       	call   f0106372 <lapicw>
	lapicw(ESR, 0);
f0106476:	ba 00 00 00 00       	mov    $0x0,%edx
f010647b:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106480:	e8 ed fe ff ff       	call   f0106372 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0106485:	ba 00 00 00 00       	mov    $0x0,%edx
f010648a:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010648f:	e8 de fe ff ff       	call   f0106372 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0106494:	ba 00 00 00 00       	mov    $0x0,%edx
f0106499:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010649e:	e8 cf fe ff ff       	call   f0106372 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01064a3:	ba 00 85 08 00       	mov    $0x88500,%edx
f01064a8:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01064ad:	e8 c0 fe ff ff       	call   f0106372 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01064b2:	8b 15 04 a0 25 f0    	mov    0xf025a004,%edx
f01064b8:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01064be:	f6 c4 10             	test   $0x10,%ah
f01064c1:	75 f5                	jne    f01064b8 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f01064c3:	ba 00 00 00 00       	mov    $0x0,%edx
f01064c8:	b8 20 00 00 00       	mov    $0x20,%eax
f01064cd:	e8 a0 fe ff ff       	call   f0106372 <lapicw>
}
f01064d2:	c9                   	leave  
f01064d3:	f3 c3                	repz ret 

f01064d5 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f01064d5:	83 3d 04 a0 25 f0 00 	cmpl   $0x0,0xf025a004
f01064dc:	74 13                	je     f01064f1 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f01064de:	55                   	push   %ebp
f01064df:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f01064e1:	ba 00 00 00 00       	mov    $0x0,%edx
f01064e6:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01064eb:	e8 82 fe ff ff       	call   f0106372 <lapicw>
}
f01064f0:	5d                   	pop    %ebp
f01064f1:	f3 c3                	repz ret 

f01064f3 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01064f3:	55                   	push   %ebp
f01064f4:	89 e5                	mov    %esp,%ebp
f01064f6:	56                   	push   %esi
f01064f7:	53                   	push   %ebx
f01064f8:	8b 75 08             	mov    0x8(%ebp),%esi
f01064fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01064fe:	ba 70 00 00 00       	mov    $0x70,%edx
f0106503:	b8 0f 00 00 00       	mov    $0xf,%eax
f0106508:	ee                   	out    %al,(%dx)
f0106509:	ba 71 00 00 00       	mov    $0x71,%edx
f010650e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0106513:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106514:	83 3d 88 8e 21 f0 00 	cmpl   $0x0,0xf0218e88
f010651b:	75 19                	jne    f0106536 <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010651d:	68 67 04 00 00       	push   $0x467
f0106522:	68 44 6a 10 f0       	push   $0xf0106a44
f0106527:	68 98 00 00 00       	push   $0x98
f010652c:	68 d4 87 10 f0       	push   $0xf01087d4
f0106531:	e8 0a 9b ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106536:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f010653d:	00 00 
	wrv[1] = addr >> 4;
f010653f:	89 d8                	mov    %ebx,%eax
f0106541:	c1 e8 04             	shr    $0x4,%eax
f0106544:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f010654a:	c1 e6 18             	shl    $0x18,%esi
f010654d:	89 f2                	mov    %esi,%edx
f010654f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106554:	e8 19 fe ff ff       	call   f0106372 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106559:	ba 00 c5 00 00       	mov    $0xc500,%edx
f010655e:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106563:	e8 0a fe ff ff       	call   f0106372 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106568:	ba 00 85 00 00       	mov    $0x8500,%edx
f010656d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106572:	e8 fb fd ff ff       	call   f0106372 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106577:	c1 eb 0c             	shr    $0xc,%ebx
f010657a:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010657d:	89 f2                	mov    %esi,%edx
f010657f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106584:	e8 e9 fd ff ff       	call   f0106372 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106589:	89 da                	mov    %ebx,%edx
f010658b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106590:	e8 dd fd ff ff       	call   f0106372 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106595:	89 f2                	mov    %esi,%edx
f0106597:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010659c:	e8 d1 fd ff ff       	call   f0106372 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01065a1:	89 da                	mov    %ebx,%edx
f01065a3:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01065a8:	e8 c5 fd ff ff       	call   f0106372 <lapicw>
		microdelay(200);
	}
}
f01065ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01065b0:	5b                   	pop    %ebx
f01065b1:	5e                   	pop    %esi
f01065b2:	5d                   	pop    %ebp
f01065b3:	c3                   	ret    

f01065b4 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01065b4:	55                   	push   %ebp
f01065b5:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01065b7:	8b 55 08             	mov    0x8(%ebp),%edx
f01065ba:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f01065c0:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01065c5:	e8 a8 fd ff ff       	call   f0106372 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01065ca:	8b 15 04 a0 25 f0    	mov    0xf025a004,%edx
f01065d0:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01065d6:	f6 c4 10             	test   $0x10,%ah
f01065d9:	75 f5                	jne    f01065d0 <lapic_ipi+0x1c>
		;
}
f01065db:	5d                   	pop    %ebp
f01065dc:	c3                   	ret    

f01065dd <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01065dd:	55                   	push   %ebp
f01065de:	89 e5                	mov    %esp,%ebp
f01065e0:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01065e3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01065e9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01065ec:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01065ef:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01065f6:	5d                   	pop    %ebp
f01065f7:	c3                   	ret    

f01065f8 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01065f8:	55                   	push   %ebp
f01065f9:	89 e5                	mov    %esp,%ebp
f01065fb:	56                   	push   %esi
f01065fc:	53                   	push   %ebx
f01065fd:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0106600:	83 3b 00             	cmpl   $0x0,(%ebx)
f0106603:	74 14                	je     f0106619 <spin_lock+0x21>
f0106605:	8b 73 08             	mov    0x8(%ebx),%esi
f0106608:	e8 7d fd ff ff       	call   f010638a <cpunum>
f010660d:	6b c0 74             	imul   $0x74,%eax,%eax
f0106610:	05 20 90 21 f0       	add    $0xf0219020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106615:	39 c6                	cmp    %eax,%esi
f0106617:	74 07                	je     f0106620 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0106619:	ba 01 00 00 00       	mov    $0x1,%edx
f010661e:	eb 20                	jmp    f0106640 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106620:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106623:	e8 62 fd ff ff       	call   f010638a <cpunum>
f0106628:	83 ec 0c             	sub    $0xc,%esp
f010662b:	53                   	push   %ebx
f010662c:	50                   	push   %eax
f010662d:	68 e4 87 10 f0       	push   $0xf01087e4
f0106632:	6a 41                	push   $0x41
f0106634:	68 48 88 10 f0       	push   $0xf0108848
f0106639:	e8 02 9a ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f010663e:	f3 90                	pause  
f0106640:	89 d0                	mov    %edx,%eax
f0106642:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106645:	85 c0                	test   %eax,%eax
f0106647:	75 f5                	jne    f010663e <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106649:	e8 3c fd ff ff       	call   f010638a <cpunum>
f010664e:	6b c0 74             	imul   $0x74,%eax,%eax
f0106651:	05 20 90 21 f0       	add    $0xf0219020,%eax
f0106656:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106659:	83 c3 0c             	add    $0xc,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f010665c:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f010665e:	b8 00 00 00 00       	mov    $0x0,%eax
f0106663:	eb 0b                	jmp    f0106670 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106665:	8b 4a 04             	mov    0x4(%edx),%ecx
f0106668:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f010666b:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f010666d:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106670:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106676:	76 11                	jbe    f0106689 <spin_lock+0x91>
f0106678:	83 f8 09             	cmp    $0x9,%eax
f010667b:	7e e8                	jle    f0106665 <spin_lock+0x6d>
f010667d:	eb 0a                	jmp    f0106689 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f010667f:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106686:	83 c0 01             	add    $0x1,%eax
f0106689:	83 f8 09             	cmp    $0x9,%eax
f010668c:	7e f1                	jle    f010667f <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f010668e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106691:	5b                   	pop    %ebx
f0106692:	5e                   	pop    %esi
f0106693:	5d                   	pop    %ebp
f0106694:	c3                   	ret    

f0106695 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106695:	55                   	push   %ebp
f0106696:	89 e5                	mov    %esp,%ebp
f0106698:	57                   	push   %edi
f0106699:	56                   	push   %esi
f010669a:	53                   	push   %ebx
f010669b:	83 ec 4c             	sub    $0x4c,%esp
f010669e:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f01066a1:	83 3e 00             	cmpl   $0x0,(%esi)
f01066a4:	74 18                	je     f01066be <spin_unlock+0x29>
f01066a6:	8b 5e 08             	mov    0x8(%esi),%ebx
f01066a9:	e8 dc fc ff ff       	call   f010638a <cpunum>
f01066ae:	6b c0 74             	imul   $0x74,%eax,%eax
f01066b1:	05 20 90 21 f0       	add    $0xf0219020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f01066b6:	39 c3                	cmp    %eax,%ebx
f01066b8:	0f 84 a5 00 00 00    	je     f0106763 <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01066be:	83 ec 04             	sub    $0x4,%esp
f01066c1:	6a 28                	push   $0x28
f01066c3:	8d 46 0c             	lea    0xc(%esi),%eax
f01066c6:	50                   	push   %eax
f01066c7:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f01066ca:	53                   	push   %ebx
f01066cb:	e8 e7 f6 ff ff       	call   f0105db7 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01066d0:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01066d3:	0f b6 38             	movzbl (%eax),%edi
f01066d6:	8b 76 04             	mov    0x4(%esi),%esi
f01066d9:	e8 ac fc ff ff       	call   f010638a <cpunum>
f01066de:	57                   	push   %edi
f01066df:	56                   	push   %esi
f01066e0:	50                   	push   %eax
f01066e1:	68 10 88 10 f0       	push   $0xf0108810
f01066e6:	e8 7d d5 ff ff       	call   f0103c68 <cprintf>
f01066eb:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01066ee:	8d 7d a8             	lea    -0x58(%ebp),%edi
f01066f1:	eb 54                	jmp    f0106747 <spin_unlock+0xb2>
f01066f3:	83 ec 08             	sub    $0x8,%esp
f01066f6:	57                   	push   %edi
f01066f7:	50                   	push   %eax
f01066f8:	e8 85 ec ff ff       	call   f0105382 <debuginfo_eip>
f01066fd:	83 c4 10             	add    $0x10,%esp
f0106700:	85 c0                	test   %eax,%eax
f0106702:	78 27                	js     f010672b <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106704:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106706:	83 ec 04             	sub    $0x4,%esp
f0106709:	89 c2                	mov    %eax,%edx
f010670b:	2b 55 b8             	sub    -0x48(%ebp),%edx
f010670e:	52                   	push   %edx
f010670f:	ff 75 b0             	pushl  -0x50(%ebp)
f0106712:	ff 75 b4             	pushl  -0x4c(%ebp)
f0106715:	ff 75 ac             	pushl  -0x54(%ebp)
f0106718:	ff 75 a8             	pushl  -0x58(%ebp)
f010671b:	50                   	push   %eax
f010671c:	68 58 88 10 f0       	push   $0xf0108858
f0106721:	e8 42 d5 ff ff       	call   f0103c68 <cprintf>
f0106726:	83 c4 20             	add    $0x20,%esp
f0106729:	eb 12                	jmp    f010673d <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f010672b:	83 ec 08             	sub    $0x8,%esp
f010672e:	ff 36                	pushl  (%esi)
f0106730:	68 6f 88 10 f0       	push   $0xf010886f
f0106735:	e8 2e d5 ff ff       	call   f0103c68 <cprintf>
f010673a:	83 c4 10             	add    $0x10,%esp
f010673d:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106740:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106743:	39 c3                	cmp    %eax,%ebx
f0106745:	74 08                	je     f010674f <spin_unlock+0xba>
f0106747:	89 de                	mov    %ebx,%esi
f0106749:	8b 03                	mov    (%ebx),%eax
f010674b:	85 c0                	test   %eax,%eax
f010674d:	75 a4                	jne    f01066f3 <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f010674f:	83 ec 04             	sub    $0x4,%esp
f0106752:	68 77 88 10 f0       	push   $0xf0108877
f0106757:	6a 67                	push   $0x67
f0106759:	68 48 88 10 f0       	push   $0xf0108848
f010675e:	e8 dd 98 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0106763:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f010676a:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0106771:	b8 00 00 00 00       	mov    $0x0,%eax
f0106776:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0106779:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010677c:	5b                   	pop    %ebx
f010677d:	5e                   	pop    %esi
f010677e:	5f                   	pop    %edi
f010677f:	5d                   	pop    %ebp
f0106780:	c3                   	ret    
f0106781:	66 90                	xchg   %ax,%ax
f0106783:	66 90                	xchg   %ax,%ax
f0106785:	66 90                	xchg   %ax,%ax
f0106787:	66 90                	xchg   %ax,%ax
f0106789:	66 90                	xchg   %ax,%ax
f010678b:	66 90                	xchg   %ax,%ax
f010678d:	66 90                	xchg   %ax,%ax
f010678f:	90                   	nop

f0106790 <__udivdi3>:
f0106790:	55                   	push   %ebp
f0106791:	57                   	push   %edi
f0106792:	56                   	push   %esi
f0106793:	53                   	push   %ebx
f0106794:	83 ec 1c             	sub    $0x1c,%esp
f0106797:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010679b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010679f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f01067a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01067a7:	85 f6                	test   %esi,%esi
f01067a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01067ad:	89 ca                	mov    %ecx,%edx
f01067af:	89 f8                	mov    %edi,%eax
f01067b1:	75 3d                	jne    f01067f0 <__udivdi3+0x60>
f01067b3:	39 cf                	cmp    %ecx,%edi
f01067b5:	0f 87 c5 00 00 00    	ja     f0106880 <__udivdi3+0xf0>
f01067bb:	85 ff                	test   %edi,%edi
f01067bd:	89 fd                	mov    %edi,%ebp
f01067bf:	75 0b                	jne    f01067cc <__udivdi3+0x3c>
f01067c1:	b8 01 00 00 00       	mov    $0x1,%eax
f01067c6:	31 d2                	xor    %edx,%edx
f01067c8:	f7 f7                	div    %edi
f01067ca:	89 c5                	mov    %eax,%ebp
f01067cc:	89 c8                	mov    %ecx,%eax
f01067ce:	31 d2                	xor    %edx,%edx
f01067d0:	f7 f5                	div    %ebp
f01067d2:	89 c1                	mov    %eax,%ecx
f01067d4:	89 d8                	mov    %ebx,%eax
f01067d6:	89 cf                	mov    %ecx,%edi
f01067d8:	f7 f5                	div    %ebp
f01067da:	89 c3                	mov    %eax,%ebx
f01067dc:	89 d8                	mov    %ebx,%eax
f01067de:	89 fa                	mov    %edi,%edx
f01067e0:	83 c4 1c             	add    $0x1c,%esp
f01067e3:	5b                   	pop    %ebx
f01067e4:	5e                   	pop    %esi
f01067e5:	5f                   	pop    %edi
f01067e6:	5d                   	pop    %ebp
f01067e7:	c3                   	ret    
f01067e8:	90                   	nop
f01067e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01067f0:	39 ce                	cmp    %ecx,%esi
f01067f2:	77 74                	ja     f0106868 <__udivdi3+0xd8>
f01067f4:	0f bd fe             	bsr    %esi,%edi
f01067f7:	83 f7 1f             	xor    $0x1f,%edi
f01067fa:	0f 84 98 00 00 00    	je     f0106898 <__udivdi3+0x108>
f0106800:	bb 20 00 00 00       	mov    $0x20,%ebx
f0106805:	89 f9                	mov    %edi,%ecx
f0106807:	89 c5                	mov    %eax,%ebp
f0106809:	29 fb                	sub    %edi,%ebx
f010680b:	d3 e6                	shl    %cl,%esi
f010680d:	89 d9                	mov    %ebx,%ecx
f010680f:	d3 ed                	shr    %cl,%ebp
f0106811:	89 f9                	mov    %edi,%ecx
f0106813:	d3 e0                	shl    %cl,%eax
f0106815:	09 ee                	or     %ebp,%esi
f0106817:	89 d9                	mov    %ebx,%ecx
f0106819:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010681d:	89 d5                	mov    %edx,%ebp
f010681f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106823:	d3 ed                	shr    %cl,%ebp
f0106825:	89 f9                	mov    %edi,%ecx
f0106827:	d3 e2                	shl    %cl,%edx
f0106829:	89 d9                	mov    %ebx,%ecx
f010682b:	d3 e8                	shr    %cl,%eax
f010682d:	09 c2                	or     %eax,%edx
f010682f:	89 d0                	mov    %edx,%eax
f0106831:	89 ea                	mov    %ebp,%edx
f0106833:	f7 f6                	div    %esi
f0106835:	89 d5                	mov    %edx,%ebp
f0106837:	89 c3                	mov    %eax,%ebx
f0106839:	f7 64 24 0c          	mull   0xc(%esp)
f010683d:	39 d5                	cmp    %edx,%ebp
f010683f:	72 10                	jb     f0106851 <__udivdi3+0xc1>
f0106841:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106845:	89 f9                	mov    %edi,%ecx
f0106847:	d3 e6                	shl    %cl,%esi
f0106849:	39 c6                	cmp    %eax,%esi
f010684b:	73 07                	jae    f0106854 <__udivdi3+0xc4>
f010684d:	39 d5                	cmp    %edx,%ebp
f010684f:	75 03                	jne    f0106854 <__udivdi3+0xc4>
f0106851:	83 eb 01             	sub    $0x1,%ebx
f0106854:	31 ff                	xor    %edi,%edi
f0106856:	89 d8                	mov    %ebx,%eax
f0106858:	89 fa                	mov    %edi,%edx
f010685a:	83 c4 1c             	add    $0x1c,%esp
f010685d:	5b                   	pop    %ebx
f010685e:	5e                   	pop    %esi
f010685f:	5f                   	pop    %edi
f0106860:	5d                   	pop    %ebp
f0106861:	c3                   	ret    
f0106862:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106868:	31 ff                	xor    %edi,%edi
f010686a:	31 db                	xor    %ebx,%ebx
f010686c:	89 d8                	mov    %ebx,%eax
f010686e:	89 fa                	mov    %edi,%edx
f0106870:	83 c4 1c             	add    $0x1c,%esp
f0106873:	5b                   	pop    %ebx
f0106874:	5e                   	pop    %esi
f0106875:	5f                   	pop    %edi
f0106876:	5d                   	pop    %ebp
f0106877:	c3                   	ret    
f0106878:	90                   	nop
f0106879:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106880:	89 d8                	mov    %ebx,%eax
f0106882:	f7 f7                	div    %edi
f0106884:	31 ff                	xor    %edi,%edi
f0106886:	89 c3                	mov    %eax,%ebx
f0106888:	89 d8                	mov    %ebx,%eax
f010688a:	89 fa                	mov    %edi,%edx
f010688c:	83 c4 1c             	add    $0x1c,%esp
f010688f:	5b                   	pop    %ebx
f0106890:	5e                   	pop    %esi
f0106891:	5f                   	pop    %edi
f0106892:	5d                   	pop    %ebp
f0106893:	c3                   	ret    
f0106894:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106898:	39 ce                	cmp    %ecx,%esi
f010689a:	72 0c                	jb     f01068a8 <__udivdi3+0x118>
f010689c:	31 db                	xor    %ebx,%ebx
f010689e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f01068a2:	0f 87 34 ff ff ff    	ja     f01067dc <__udivdi3+0x4c>
f01068a8:	bb 01 00 00 00       	mov    $0x1,%ebx
f01068ad:	e9 2a ff ff ff       	jmp    f01067dc <__udivdi3+0x4c>
f01068b2:	66 90                	xchg   %ax,%ax
f01068b4:	66 90                	xchg   %ax,%ax
f01068b6:	66 90                	xchg   %ax,%ax
f01068b8:	66 90                	xchg   %ax,%ax
f01068ba:	66 90                	xchg   %ax,%ax
f01068bc:	66 90                	xchg   %ax,%ax
f01068be:	66 90                	xchg   %ax,%ax

f01068c0 <__umoddi3>:
f01068c0:	55                   	push   %ebp
f01068c1:	57                   	push   %edi
f01068c2:	56                   	push   %esi
f01068c3:	53                   	push   %ebx
f01068c4:	83 ec 1c             	sub    $0x1c,%esp
f01068c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01068cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f01068cf:	8b 74 24 34          	mov    0x34(%esp),%esi
f01068d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01068d7:	85 d2                	test   %edx,%edx
f01068d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01068dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01068e1:	89 f3                	mov    %esi,%ebx
f01068e3:	89 3c 24             	mov    %edi,(%esp)
f01068e6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01068ea:	75 1c                	jne    f0106908 <__umoddi3+0x48>
f01068ec:	39 f7                	cmp    %esi,%edi
f01068ee:	76 50                	jbe    f0106940 <__umoddi3+0x80>
f01068f0:	89 c8                	mov    %ecx,%eax
f01068f2:	89 f2                	mov    %esi,%edx
f01068f4:	f7 f7                	div    %edi
f01068f6:	89 d0                	mov    %edx,%eax
f01068f8:	31 d2                	xor    %edx,%edx
f01068fa:	83 c4 1c             	add    $0x1c,%esp
f01068fd:	5b                   	pop    %ebx
f01068fe:	5e                   	pop    %esi
f01068ff:	5f                   	pop    %edi
f0106900:	5d                   	pop    %ebp
f0106901:	c3                   	ret    
f0106902:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106908:	39 f2                	cmp    %esi,%edx
f010690a:	89 d0                	mov    %edx,%eax
f010690c:	77 52                	ja     f0106960 <__umoddi3+0xa0>
f010690e:	0f bd ea             	bsr    %edx,%ebp
f0106911:	83 f5 1f             	xor    $0x1f,%ebp
f0106914:	75 5a                	jne    f0106970 <__umoddi3+0xb0>
f0106916:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010691a:	0f 82 e0 00 00 00    	jb     f0106a00 <__umoddi3+0x140>
f0106920:	39 0c 24             	cmp    %ecx,(%esp)
f0106923:	0f 86 d7 00 00 00    	jbe    f0106a00 <__umoddi3+0x140>
f0106929:	8b 44 24 08          	mov    0x8(%esp),%eax
f010692d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106931:	83 c4 1c             	add    $0x1c,%esp
f0106934:	5b                   	pop    %ebx
f0106935:	5e                   	pop    %esi
f0106936:	5f                   	pop    %edi
f0106937:	5d                   	pop    %ebp
f0106938:	c3                   	ret    
f0106939:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106940:	85 ff                	test   %edi,%edi
f0106942:	89 fd                	mov    %edi,%ebp
f0106944:	75 0b                	jne    f0106951 <__umoddi3+0x91>
f0106946:	b8 01 00 00 00       	mov    $0x1,%eax
f010694b:	31 d2                	xor    %edx,%edx
f010694d:	f7 f7                	div    %edi
f010694f:	89 c5                	mov    %eax,%ebp
f0106951:	89 f0                	mov    %esi,%eax
f0106953:	31 d2                	xor    %edx,%edx
f0106955:	f7 f5                	div    %ebp
f0106957:	89 c8                	mov    %ecx,%eax
f0106959:	f7 f5                	div    %ebp
f010695b:	89 d0                	mov    %edx,%eax
f010695d:	eb 99                	jmp    f01068f8 <__umoddi3+0x38>
f010695f:	90                   	nop
f0106960:	89 c8                	mov    %ecx,%eax
f0106962:	89 f2                	mov    %esi,%edx
f0106964:	83 c4 1c             	add    $0x1c,%esp
f0106967:	5b                   	pop    %ebx
f0106968:	5e                   	pop    %esi
f0106969:	5f                   	pop    %edi
f010696a:	5d                   	pop    %ebp
f010696b:	c3                   	ret    
f010696c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106970:	8b 34 24             	mov    (%esp),%esi
f0106973:	bf 20 00 00 00       	mov    $0x20,%edi
f0106978:	89 e9                	mov    %ebp,%ecx
f010697a:	29 ef                	sub    %ebp,%edi
f010697c:	d3 e0                	shl    %cl,%eax
f010697e:	89 f9                	mov    %edi,%ecx
f0106980:	89 f2                	mov    %esi,%edx
f0106982:	d3 ea                	shr    %cl,%edx
f0106984:	89 e9                	mov    %ebp,%ecx
f0106986:	09 c2                	or     %eax,%edx
f0106988:	89 d8                	mov    %ebx,%eax
f010698a:	89 14 24             	mov    %edx,(%esp)
f010698d:	89 f2                	mov    %esi,%edx
f010698f:	d3 e2                	shl    %cl,%edx
f0106991:	89 f9                	mov    %edi,%ecx
f0106993:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106997:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010699b:	d3 e8                	shr    %cl,%eax
f010699d:	89 e9                	mov    %ebp,%ecx
f010699f:	89 c6                	mov    %eax,%esi
f01069a1:	d3 e3                	shl    %cl,%ebx
f01069a3:	89 f9                	mov    %edi,%ecx
f01069a5:	89 d0                	mov    %edx,%eax
f01069a7:	d3 e8                	shr    %cl,%eax
f01069a9:	89 e9                	mov    %ebp,%ecx
f01069ab:	09 d8                	or     %ebx,%eax
f01069ad:	89 d3                	mov    %edx,%ebx
f01069af:	89 f2                	mov    %esi,%edx
f01069b1:	f7 34 24             	divl   (%esp)
f01069b4:	89 d6                	mov    %edx,%esi
f01069b6:	d3 e3                	shl    %cl,%ebx
f01069b8:	f7 64 24 04          	mull   0x4(%esp)
f01069bc:	39 d6                	cmp    %edx,%esi
f01069be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01069c2:	89 d1                	mov    %edx,%ecx
f01069c4:	89 c3                	mov    %eax,%ebx
f01069c6:	72 08                	jb     f01069d0 <__umoddi3+0x110>
f01069c8:	75 11                	jne    f01069db <__umoddi3+0x11b>
f01069ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01069ce:	73 0b                	jae    f01069db <__umoddi3+0x11b>
f01069d0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01069d4:	1b 14 24             	sbb    (%esp),%edx
f01069d7:	89 d1                	mov    %edx,%ecx
f01069d9:	89 c3                	mov    %eax,%ebx
f01069db:	8b 54 24 08          	mov    0x8(%esp),%edx
f01069df:	29 da                	sub    %ebx,%edx
f01069e1:	19 ce                	sbb    %ecx,%esi
f01069e3:	89 f9                	mov    %edi,%ecx
f01069e5:	89 f0                	mov    %esi,%eax
f01069e7:	d3 e0                	shl    %cl,%eax
f01069e9:	89 e9                	mov    %ebp,%ecx
f01069eb:	d3 ea                	shr    %cl,%edx
f01069ed:	89 e9                	mov    %ebp,%ecx
f01069ef:	d3 ee                	shr    %cl,%esi
f01069f1:	09 d0                	or     %edx,%eax
f01069f3:	89 f2                	mov    %esi,%edx
f01069f5:	83 c4 1c             	add    $0x1c,%esp
f01069f8:	5b                   	pop    %ebx
f01069f9:	5e                   	pop    %esi
f01069fa:	5f                   	pop    %edi
f01069fb:	5d                   	pop    %ebp
f01069fc:	c3                   	ret    
f01069fd:	8d 76 00             	lea    0x0(%esi),%esi
f0106a00:	29 f9                	sub    %edi,%ecx
f0106a02:	19 d6                	sbb    %edx,%esi
f0106a04:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106a08:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106a0c:	e9 18 ff ff ff       	jmp    f0106929 <__umoddi3+0x69>
