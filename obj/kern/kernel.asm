
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
f0100015:	b8 00 e0 11 00       	mov    $0x11e000,%eax
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
f0100034:	bc 00 e0 11 f0       	mov    $0xf011e000,%esp

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
f0100048:	83 3d 80 1e 21 f0 00 	cmpl   $0x0,0xf0211e80
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 80 1e 21 f0    	mov    %esi,0xf0211e80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 79 5e 00 00       	call   f0105eda <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 80 65 10 f0       	push   $0xf0106580
f010006d:	e8 1b 38 00 00       	call   f010388d <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 eb 37 00 00       	call   f0103867 <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 8b 77 10 f0 	movl   $0xf010778b,(%esp)
f0100083:	e8 05 38 00 00       	call   f010388d <cprintf>
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
f01000a1:	b8 08 30 25 f0       	mov    $0xf0253008,%eax
f01000a6:	2d 7c 09 21 f0       	sub    $0xf021097c,%eax
f01000ab:	50                   	push   %eax
f01000ac:	6a 00                	push   $0x0
f01000ae:	68 7c 09 21 f0       	push   $0xf021097c
f01000b3:	e8 ff 57 00 00       	call   f01058b7 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b8:	e8 96 05 00 00       	call   f0100653 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000bd:	83 c4 08             	add    $0x8,%esp
f01000c0:	68 ac 1a 00 00       	push   $0x1aac
f01000c5:	68 ec 65 10 f0       	push   $0xf01065ec
f01000ca:	e8 be 37 00 00       	call   f010388d <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000cf:	e8 a2 13 00 00       	call   f0101476 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000d4:	e8 39 30 00 00       	call   f0103112 <env_init>
	trap_init();
f01000d9:	e8 aa 38 00 00       	call   f0103988 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000de:	e8 ed 5a 00 00       	call   f0105bd0 <mp_init>
	lapic_init();
f01000e3:	e8 0d 5e 00 00       	call   f0105ef5 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000e8:	e8 c7 36 00 00       	call   f01037b4 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000ed:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f01000f4:	e8 4f 60 00 00       	call   f0106148 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000f9:	83 c4 10             	add    $0x10,%esp
f01000fc:	83 3d 88 1e 21 f0 07 	cmpl   $0x7,0xf0211e88
f0100103:	77 16                	ja     f010011b <i386_init+0x81>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100105:	68 00 70 00 00       	push   $0x7000
f010010a:	68 a4 65 10 f0       	push   $0xf01065a4
f010010f:	6a 58                	push   $0x58
f0100111:	68 07 66 10 f0       	push   $0xf0106607
f0100116:	e8 25 ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010011b:	83 ec 04             	sub    $0x4,%esp
f010011e:	b8 36 5b 10 f0       	mov    $0xf0105b36,%eax
f0100123:	2d bc 5a 10 f0       	sub    $0xf0105abc,%eax
f0100128:	50                   	push   %eax
f0100129:	68 bc 5a 10 f0       	push   $0xf0105abc
f010012e:	68 00 70 00 f0       	push   $0xf0007000
f0100133:	e8 cc 57 00 00       	call   f0105904 <memmove>
f0100138:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010013b:	bb 20 20 21 f0       	mov    $0xf0212020,%ebx
f0100140:	eb 4d                	jmp    f010018f <i386_init+0xf5>
		if (c == cpus + cpunum())  // We've started already.
f0100142:	e8 93 5d 00 00       	call   f0105eda <cpunum>
f0100147:	6b c0 74             	imul   $0x74,%eax,%eax
f010014a:	05 20 20 21 f0       	add    $0xf0212020,%eax
f010014f:	39 c3                	cmp    %eax,%ebx
f0100151:	74 39                	je     f010018c <i386_init+0xf2>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100153:	89 d8                	mov    %ebx,%eax
f0100155:	2d 20 20 21 f0       	sub    $0xf0212020,%eax
f010015a:	c1 f8 02             	sar    $0x2,%eax
f010015d:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100163:	c1 e0 0f             	shl    $0xf,%eax
f0100166:	05 00 b0 21 f0       	add    $0xf021b000,%eax
f010016b:	a3 84 1e 21 f0       	mov    %eax,0xf0211e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100170:	83 ec 08             	sub    $0x8,%esp
f0100173:	68 00 70 00 00       	push   $0x7000
f0100178:	0f b6 03             	movzbl (%ebx),%eax
f010017b:	50                   	push   %eax
f010017c:	e8 c2 5e 00 00       	call   f0106043 <lapic_startap>
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
f010018f:	6b 05 c4 23 21 f0 74 	imul   $0x74,0xf02123c4,%eax
f0100196:	05 20 20 21 f0       	add    $0xf0212020,%eax
f010019b:	39 c3                	cmp    %eax,%ebx
f010019d:	72 a3                	jb     f0100142 <i386_init+0xa8>
	lock_kernel();

	// Starting non-boot CPUs
	boot_aps();

	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f010019f:	83 ec 08             	sub    $0x8,%esp
f01001a2:	6a 01                	push   $0x1
f01001a4:	68 08 0c 1d f0       	push   $0xf01d0c08
f01001a9:	e8 1a 31 00 00       	call   f01032c8 <env_create>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001ae:	83 c4 08             	add    $0x8,%esp
f01001b1:	6a 00                	push   $0x0
f01001b3:	68 40 0c 20 f0       	push   $0xf0200c40
f01001b8:	e8 0b 31 00 00       	call   f01032c8 <env_create>
	// Touch all you want. Calls fork.
	ENV_CREATE(user_primes, ENV_TYPE_USER);
#endif // TEST* 
	
	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f01001bd:	e8 35 04 00 00       	call   f01005f7 <kbd_intr>
	// Schedule and run the first user environment!
	sched_yield();
f01001c2:	e8 29 45 00 00       	call   f01046f0 <sched_yield>

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
f01001cd:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001d2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001d7:	77 12                	ja     f01001eb <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001d9:	50                   	push   %eax
f01001da:	68 c8 65 10 f0       	push   $0xf01065c8
f01001df:	6a 6f                	push   $0x6f
f01001e1:	68 07 66 10 f0       	push   $0xf0106607
f01001e6:	e8 55 fe ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001eb:	05 00 00 00 10       	add    $0x10000000,%eax
f01001f0:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001f3:	e8 e2 5c 00 00       	call   f0105eda <cpunum>
f01001f8:	83 ec 08             	sub    $0x8,%esp
f01001fb:	50                   	push   %eax
f01001fc:	68 13 66 10 f0       	push   $0xf0106613
f0100201:	e8 87 36 00 00       	call   f010388d <cprintf>

	lapic_init();
f0100206:	e8 ea 5c 00 00       	call   f0105ef5 <lapic_init>
	env_init_percpu();
f010020b:	e8 d2 2e 00 00       	call   f01030e2 <env_init_percpu>
	trap_init_percpu();
f0100210:	e8 8c 36 00 00       	call   f01038a1 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100215:	e8 c0 5c 00 00       	call   f0105eda <cpunum>
f010021a:	6b d0 74             	imul   $0x74,%eax,%edx
f010021d:	81 c2 20 20 21 f0    	add    $0xf0212020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100223:	b8 01 00 00 00       	mov    $0x1,%eax
f0100228:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010022c:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f0100233:	e8 10 5f 00 00       	call   f0106148 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100238:	e8 b3 44 00 00       	call   f01046f0 <sched_yield>

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
f010024d:	68 29 66 10 f0       	push   $0xf0106629
f0100252:	e8 36 36 00 00       	call   f010388d <cprintf>
	vcprintf(fmt, ap);
f0100257:	83 c4 08             	add    $0x8,%esp
f010025a:	53                   	push   %ebx
f010025b:	ff 75 10             	pushl  0x10(%ebp)
f010025e:	e8 04 36 00 00       	call   f0103867 <vcprintf>
	cprintf("\n");
f0100263:	c7 04 24 8b 77 10 f0 	movl   $0xf010778b,(%esp)
f010026a:	e8 1e 36 00 00       	call   f010388d <cprintf>
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
f01002a5:	8b 0d 24 12 21 f0    	mov    0xf0211224,%ecx
f01002ab:	8d 51 01             	lea    0x1(%ecx),%edx
f01002ae:	89 15 24 12 21 f0    	mov    %edx,0xf0211224
f01002b4:	88 81 20 10 21 f0    	mov    %al,-0xfdeefe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002ba:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002c0:	75 0a                	jne    f01002cc <cons_intr+0x36>
			cons.wpos = 0;
f01002c2:	c7 05 24 12 21 f0 00 	movl   $0x0,0xf0211224
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
f01002fb:	83 0d 00 10 21 f0 40 	orl    $0x40,0xf0211000
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
f0100313:	8b 0d 00 10 21 f0    	mov    0xf0211000,%ecx
f0100319:	89 cb                	mov    %ecx,%ebx
f010031b:	83 e3 40             	and    $0x40,%ebx
f010031e:	83 e0 7f             	and    $0x7f,%eax
f0100321:	85 db                	test   %ebx,%ebx
f0100323:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100326:	0f b6 d2             	movzbl %dl,%edx
f0100329:	0f b6 82 a0 67 10 f0 	movzbl -0xfef9860(%edx),%eax
f0100330:	83 c8 40             	or     $0x40,%eax
f0100333:	0f b6 c0             	movzbl %al,%eax
f0100336:	f7 d0                	not    %eax
f0100338:	21 c8                	and    %ecx,%eax
f010033a:	a3 00 10 21 f0       	mov    %eax,0xf0211000
		return 0;
f010033f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100344:	e9 a4 00 00 00       	jmp    f01003ed <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100349:	8b 0d 00 10 21 f0    	mov    0xf0211000,%ecx
f010034f:	f6 c1 40             	test   $0x40,%cl
f0100352:	74 0e                	je     f0100362 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100354:	83 c8 80             	or     $0xffffff80,%eax
f0100357:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100359:	83 e1 bf             	and    $0xffffffbf,%ecx
f010035c:	89 0d 00 10 21 f0    	mov    %ecx,0xf0211000
	}

	shift |= shiftcode[data];
f0100362:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100365:	0f b6 82 a0 67 10 f0 	movzbl -0xfef9860(%edx),%eax
f010036c:	0b 05 00 10 21 f0    	or     0xf0211000,%eax
f0100372:	0f b6 8a a0 66 10 f0 	movzbl -0xfef9960(%edx),%ecx
f0100379:	31 c8                	xor    %ecx,%eax
f010037b:	a3 00 10 21 f0       	mov    %eax,0xf0211000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100380:	89 c1                	mov    %eax,%ecx
f0100382:	83 e1 03             	and    $0x3,%ecx
f0100385:	8b 0c 8d 80 66 10 f0 	mov    -0xfef9980(,%ecx,4),%ecx
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
f01003c3:	68 43 66 10 f0       	push   $0xf0106643
f01003c8:	e8 c0 34 00 00       	call   f010388d <cprintf>
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
f01004af:	0f b7 05 28 12 21 f0 	movzwl 0xf0211228,%eax
f01004b6:	66 85 c0             	test   %ax,%ax
f01004b9:	0f 84 e6 00 00 00    	je     f01005a5 <cons_putc+0x1b3>
			crt_pos--;
f01004bf:	83 e8 01             	sub    $0x1,%eax
f01004c2:	66 a3 28 12 21 f0    	mov    %ax,0xf0211228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004c8:	0f b7 c0             	movzwl %ax,%eax
f01004cb:	66 81 e7 00 ff       	and    $0xff00,%di
f01004d0:	83 cf 20             	or     $0x20,%edi
f01004d3:	8b 15 2c 12 21 f0    	mov    0xf021122c,%edx
f01004d9:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004dd:	eb 78                	jmp    f0100557 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004df:	66 83 05 28 12 21 f0 	addw   $0x50,0xf0211228
f01004e6:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004e7:	0f b7 05 28 12 21 f0 	movzwl 0xf0211228,%eax
f01004ee:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004f4:	c1 e8 16             	shr    $0x16,%eax
f01004f7:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004fa:	c1 e0 04             	shl    $0x4,%eax
f01004fd:	66 a3 28 12 21 f0    	mov    %ax,0xf0211228
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
f0100539:	0f b7 05 28 12 21 f0 	movzwl 0xf0211228,%eax
f0100540:	8d 50 01             	lea    0x1(%eax),%edx
f0100543:	66 89 15 28 12 21 f0 	mov    %dx,0xf0211228
f010054a:	0f b7 c0             	movzwl %ax,%eax
f010054d:	8b 15 2c 12 21 f0    	mov    0xf021122c,%edx
f0100553:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100557:	66 81 3d 28 12 21 f0 	cmpw   $0x7cf,0xf0211228
f010055e:	cf 07 
f0100560:	76 43                	jbe    f01005a5 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100562:	a1 2c 12 21 f0       	mov    0xf021122c,%eax
f0100567:	83 ec 04             	sub    $0x4,%esp
f010056a:	68 00 0f 00 00       	push   $0xf00
f010056f:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100575:	52                   	push   %edx
f0100576:	50                   	push   %eax
f0100577:	e8 88 53 00 00       	call   f0105904 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010057c:	8b 15 2c 12 21 f0    	mov    0xf021122c,%edx
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
f010059d:	66 83 2d 28 12 21 f0 	subw   $0x50,0xf0211228
f01005a4:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01005a5:	8b 0d 30 12 21 f0    	mov    0xf0211230,%ecx
f01005ab:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005b0:	89 ca                	mov    %ecx,%edx
f01005b2:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005b3:	0f b7 1d 28 12 21 f0 	movzwl 0xf0211228,%ebx
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
f01005db:	80 3d 34 12 21 f0 00 	cmpb   $0x0,0xf0211234
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
f0100619:	a1 20 12 21 f0       	mov    0xf0211220,%eax
f010061e:	3b 05 24 12 21 f0    	cmp    0xf0211224,%eax
f0100624:	74 26                	je     f010064c <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100626:	8d 50 01             	lea    0x1(%eax),%edx
f0100629:	89 15 20 12 21 f0    	mov    %edx,0xf0211220
f010062f:	0f b6 88 20 10 21 f0 	movzbl -0xfdeefe0(%eax),%ecx
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
f0100640:	c7 05 20 12 21 f0 00 	movl   $0x0,0xf0211220
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
f0100679:	c7 05 30 12 21 f0 b4 	movl   $0x3b4,0xf0211230
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
f0100691:	c7 05 30 12 21 f0 d4 	movl   $0x3d4,0xf0211230
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
f01006a0:	8b 3d 30 12 21 f0    	mov    0xf0211230,%edi
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
f01006c5:	89 35 2c 12 21 f0    	mov    %esi,0xf021122c
	crt_pos = pos;
f01006cb:	0f b6 c0             	movzbl %al,%eax
f01006ce:	09 c8                	or     %ecx,%eax
f01006d0:	66 a3 28 12 21 f0    	mov    %ax,0xf0211228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006d6:	e8 1c ff ff ff       	call   f01005f7 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006db:	83 ec 0c             	sub    $0xc,%esp
f01006de:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f01006e5:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006ea:	50                   	push   %eax
f01006eb:	e8 4c 30 00 00       	call   f010373c <irq_setmask_8259A>
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
f010074e:	0f 95 05 34 12 21 f0 	setne  0xf0211234
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
f0100763:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f010076a:	25 ef ff 00 00       	and    $0xffef,%eax
f010076f:	50                   	push   %eax
f0100770:	e8 c7 2f 00 00       	call   f010373c <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100775:	83 c4 10             	add    $0x10,%esp
f0100778:	80 3d 34 12 21 f0 00 	cmpb   $0x0,0xf0211234
f010077f:	75 10                	jne    f0100791 <cons_init+0x13e>
		cprintf("Serial port does not exist!\n");
f0100781:	83 ec 0c             	sub    $0xc,%esp
f0100784:	68 4f 66 10 f0       	push   $0xf010664f
f0100789:	e8 ff 30 00 00       	call   f010388d <cprintf>
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
f01007ca:	68 a0 68 10 f0       	push   $0xf01068a0
f01007cf:	68 be 68 10 f0       	push   $0xf01068be
f01007d4:	68 c3 68 10 f0       	push   $0xf01068c3
f01007d9:	e8 af 30 00 00       	call   f010388d <cprintf>
f01007de:	83 c4 0c             	add    $0xc,%esp
f01007e1:	68 7c 69 10 f0       	push   $0xf010697c
f01007e6:	68 cc 68 10 f0       	push   $0xf01068cc
f01007eb:	68 c3 68 10 f0       	push   $0xf01068c3
f01007f0:	e8 98 30 00 00       	call   f010388d <cprintf>
f01007f5:	83 c4 0c             	add    $0xc,%esp
f01007f8:	68 d5 68 10 f0       	push   $0xf01068d5
f01007fd:	68 dd 68 10 f0       	push   $0xf01068dd
f0100802:	68 c3 68 10 f0       	push   $0xf01068c3
f0100807:	e8 81 30 00 00       	call   f010388d <cprintf>
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
f0100819:	68 e7 68 10 f0       	push   $0xf01068e7
f010081e:	e8 6a 30 00 00       	call   f010388d <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100823:	83 c4 08             	add    $0x8,%esp
f0100826:	68 0c 00 10 00       	push   $0x10000c
f010082b:	68 a4 69 10 f0       	push   $0xf01069a4
f0100830:	e8 58 30 00 00       	call   f010388d <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100835:	83 c4 0c             	add    $0xc,%esp
f0100838:	68 0c 00 10 00       	push   $0x10000c
f010083d:	68 0c 00 10 f0       	push   $0xf010000c
f0100842:	68 cc 69 10 f0       	push   $0xf01069cc
f0100847:	e8 41 30 00 00       	call   f010388d <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010084c:	83 c4 0c             	add    $0xc,%esp
f010084f:	68 61 65 10 00       	push   $0x106561
f0100854:	68 61 65 10 f0       	push   $0xf0106561
f0100859:	68 f0 69 10 f0       	push   $0xf01069f0
f010085e:	e8 2a 30 00 00       	call   f010388d <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100863:	83 c4 0c             	add    $0xc,%esp
f0100866:	68 7c 09 21 00       	push   $0x21097c
f010086b:	68 7c 09 21 f0       	push   $0xf021097c
f0100870:	68 14 6a 10 f0       	push   $0xf0106a14
f0100875:	e8 13 30 00 00       	call   f010388d <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010087a:	83 c4 0c             	add    $0xc,%esp
f010087d:	68 08 30 25 00       	push   $0x253008
f0100882:	68 08 30 25 f0       	push   $0xf0253008
f0100887:	68 38 6a 10 f0       	push   $0xf0106a38
f010088c:	e8 fc 2f 00 00       	call   f010388d <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100891:	b8 07 34 25 f0       	mov    $0xf0253407,%eax
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
f01008b2:	68 5c 6a 10 f0       	push   $0xf0106a5c
f01008b7:	e8 d1 2f 00 00       	call   f010388d <cprintf>
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
f01008ce:	68 00 69 10 f0       	push   $0xf0106900
f01008d3:	e8 b5 2f 00 00       	call   f010388d <cprintf>
	
	while (ebp != 0) {
f01008d8:	83 c4 10             	add    $0x10,%esp
f01008db:	eb 67                	jmp    f0100944 <mon_backtrace+0x81>
		eip = ebp + 1;	   //eip is stored after ebp
		cprintf("ebp %x eip %x args ", ebp, *eip);
f01008dd:	83 ec 04             	sub    $0x4,%esp
f01008e0:	ff 76 04             	pushl  0x4(%esi)
f01008e3:	56                   	push   %esi
f01008e4:	68 12 69 10 f0       	push   $0xf0106912
f01008e9:	e8 9f 2f 00 00       	call   f010388d <cprintf>
f01008ee:	8d 5e 08             	lea    0x8(%esi),%ebx
f01008f1:	8d 7e 1c             	lea    0x1c(%esi),%edi
f01008f4:	83 c4 10             	add    $0x10,%esp

		size_t arg_num;
		//print arguments stored after instruction pointer
		for (arg_num = 1; arg_num <= 5; arg_num++) {
			cprintf("%08x ", *(eip + arg_num));
f01008f7:	83 ec 08             	sub    $0x8,%esp
f01008fa:	ff 33                	pushl  (%ebx)
f01008fc:	68 26 69 10 f0       	push   $0xf0106926
f0100901:	e8 87 2f 00 00       	call   f010388d <cprintf>
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
f010091a:	e8 b0 45 00 00       	call   f0104ecf <debuginfo_eip>

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
f0100935:	68 2c 69 10 f0       	push   $0xf010692c
f010093a:	e8 4e 2f 00 00       	call   f010388d <cprintf>
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
f010095e:	68 88 6a 10 f0       	push   $0xf0106a88
f0100963:	e8 25 2f 00 00       	call   f010388d <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100968:	c7 04 24 ac 6a 10 f0 	movl   $0xf0106aac,(%esp)
f010096f:	e8 19 2f 00 00       	call   f010388d <cprintf>

	if (tf != NULL)
f0100974:	83 c4 10             	add    $0x10,%esp
f0100977:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010097b:	74 0e                	je     f010098b <monitor+0x36>
		print_trapframe(tf);
f010097d:	83 ec 0c             	sub    $0xc,%esp
f0100980:	ff 75 08             	pushl  0x8(%ebp)
f0100983:	e8 7c 36 00 00       	call   f0104004 <print_trapframe>
f0100988:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f010098b:	83 ec 0c             	sub    $0xc,%esp
f010098e:	68 3e 69 10 f0       	push   $0xf010693e
f0100993:	e8 b0 4c 00 00       	call   f0105648 <readline>
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
f01009c7:	68 42 69 10 f0       	push   $0xf0106942
f01009cc:	e8 a9 4e 00 00       	call   f010587a <strchr>
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
f01009e7:	68 47 69 10 f0       	push   $0xf0106947
f01009ec:	e8 9c 2e 00 00       	call   f010388d <cprintf>
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
f0100a10:	68 42 69 10 f0       	push   $0xf0106942
f0100a15:	e8 60 4e 00 00       	call   f010587a <strchr>
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
f0100a3e:	ff 34 85 e0 6a 10 f0 	pushl  -0xfef9520(,%eax,4)
f0100a45:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a48:	e8 cf 4d 00 00       	call   f010581c <strcmp>
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
f0100a62:	ff 14 85 e8 6a 10 f0 	call   *-0xfef9518(,%eax,4)
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
f0100a83:	68 64 69 10 f0       	push   $0xf0106964
f0100a88:	e8 00 2e 00 00       	call   f010388d <cprintf>
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
f0100aa8:	e8 61 2c 00 00       	call   f010370e <mc146818_read>
f0100aad:	89 c6                	mov    %eax,%esi
f0100aaf:	83 c3 01             	add    $0x1,%ebx
f0100ab2:	89 1c 24             	mov    %ebx,(%esp)
f0100ab5:	e8 54 2c 00 00       	call   f010370e <mc146818_read>
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
f0100adc:	3b 0d 88 1e 21 f0    	cmp    0xf0211e88,%ecx
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
f0100aeb:	68 a4 65 10 f0       	push   $0xf01065a4
f0100af0:	68 c5 03 00 00       	push   $0x3c5
f0100af5:	68 71 74 10 f0       	push   $0xf0107471
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
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100b2a:	55                   	push   %ebp
f0100b2b:	89 e5                	mov    %esp,%ebp
f0100b2d:	83 ec 08             	sub    $0x8,%esp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100b30:	83 3d 38 12 21 f0 00 	cmpl   $0x0,0xf0211238
f0100b37:	75 11                	jne    f0100b4a <boot_alloc+0x20>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100b39:	ba 07 40 25 f0       	mov    $0xf0254007,%edx
f0100b3e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b44:	89 15 38 12 21 f0    	mov    %edx,0xf0211238
        // Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
        if (n == 0)
f0100b4a:	85 c0                	test   %eax,%eax
f0100b4c:	75 07                	jne    f0100b55 <boot_alloc+0x2b>
                return nextfree;
f0100b4e:	a1 38 12 21 f0       	mov    0xf0211238,%eax
f0100b53:	eb 52                	jmp    f0100ba7 <boot_alloc+0x7d>
f0100b55:	89 c2                	mov    %eax,%edx

        // We only have 4MB of memory available
        if (4 * 1024 * 1024 - PADDR(nextfree) < n)
f0100b57:	a1 38 12 21 f0       	mov    0xf0211238,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100b5c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100b61:	77 12                	ja     f0100b75 <boot_alloc+0x4b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100b63:	50                   	push   %eax
f0100b64:	68 c8 65 10 f0       	push   $0xf01065c8
f0100b69:	6a 70                	push   $0x70
f0100b6b:	68 71 74 10 f0       	push   $0xf0107471
f0100b70:	e8 cb f4 ff ff       	call   f0100040 <_panic>
f0100b75:	b9 00 00 40 f0       	mov    $0xf0400000,%ecx
f0100b7a:	29 c1                	sub    %eax,%ecx
f0100b7c:	39 ca                	cmp    %ecx,%edx
f0100b7e:	76 14                	jbe    f0100b94 <boot_alloc+0x6a>
               panic("boot_alloc: ran out of free memory"); 
f0100b80:	83 ec 04             	sub    $0x4,%esp
f0100b83:	68 04 6b 10 f0       	push   $0xf0106b04
f0100b88:	6a 71                	push   $0x71
f0100b8a:	68 71 74 10 f0       	push   $0xf0107471
f0100b8f:	e8 ac f4 ff ff       	call   f0100040 <_panic>

        result = nextfree;        
        nextfree = ROUNDUP((char *) (nextfree + n), PGSIZE);
f0100b94:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0100b9b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100ba1:	89 15 38 12 21 f0    	mov    %edx,0xf0211238

        return result;
}
f0100ba7:	c9                   	leave  
f0100ba8:	c3                   	ret    

f0100ba9 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100ba9:	55                   	push   %ebp
f0100baa:	89 e5                	mov    %esp,%ebp
f0100bac:	57                   	push   %edi
f0100bad:	56                   	push   %esi
f0100bae:	53                   	push   %ebx
f0100baf:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bb2:	84 c0                	test   %al,%al
f0100bb4:	0f 85 a0 02 00 00    	jne    f0100e5a <check_page_free_list+0x2b1>
f0100bba:	e9 ad 02 00 00       	jmp    f0100e6c <check_page_free_list+0x2c3>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100bbf:	83 ec 04             	sub    $0x4,%esp
f0100bc2:	68 28 6b 10 f0       	push   $0xf0106b28
f0100bc7:	68 f8 02 00 00       	push   $0x2f8
f0100bcc:	68 71 74 10 f0       	push   $0xf0107471
f0100bd1:	e8 6a f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100bd6:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100bd9:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100bdc:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100bdf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100be2:	89 c2                	mov    %eax,%edx
f0100be4:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0100bea:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100bf0:	0f 95 c2             	setne  %dl
f0100bf3:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100bf6:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100bfa:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100bfc:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c00:	8b 00                	mov    (%eax),%eax
f0100c02:	85 c0                	test   %eax,%eax
f0100c04:	75 dc                	jne    f0100be2 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100c06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c09:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100c0f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c12:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c15:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100c17:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100c1a:	a3 40 12 21 f0       	mov    %eax,0xf0211240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c1f:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c24:	8b 1d 40 12 21 f0    	mov    0xf0211240,%ebx
f0100c2a:	eb 53                	jmp    f0100c7f <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c2c:	89 d8                	mov    %ebx,%eax
f0100c2e:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0100c34:	c1 f8 03             	sar    $0x3,%eax
f0100c37:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c3a:	89 c2                	mov    %eax,%edx
f0100c3c:	c1 ea 16             	shr    $0x16,%edx
f0100c3f:	39 f2                	cmp    %esi,%edx
f0100c41:	73 3a                	jae    f0100c7d <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c43:	89 c2                	mov    %eax,%edx
f0100c45:	c1 ea 0c             	shr    $0xc,%edx
f0100c48:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0100c4e:	72 12                	jb     f0100c62 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c50:	50                   	push   %eax
f0100c51:	68 a4 65 10 f0       	push   $0xf01065a4
f0100c56:	6a 58                	push   $0x58
f0100c58:	68 7d 74 10 f0       	push   $0xf010747d
f0100c5d:	e8 de f3 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c62:	83 ec 04             	sub    $0x4,%esp
f0100c65:	68 80 00 00 00       	push   $0x80
f0100c6a:	68 97 00 00 00       	push   $0x97
f0100c6f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c74:	50                   	push   %eax
f0100c75:	e8 3d 4c 00 00       	call   f01058b7 <memset>
f0100c7a:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c7d:	8b 1b                	mov    (%ebx),%ebx
f0100c7f:	85 db                	test   %ebx,%ebx
f0100c81:	75 a9                	jne    f0100c2c <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100c83:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c88:	e8 9d fe ff ff       	call   f0100b2a <boot_alloc>
f0100c8d:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c90:	8b 15 40 12 21 f0    	mov    0xf0211240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c96:	8b 0d 90 1e 21 f0    	mov    0xf0211e90,%ecx
		assert(pp < pages + npages);
f0100c9c:	a1 88 1e 21 f0       	mov    0xf0211e88,%eax
f0100ca1:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100ca4:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100ca7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100caa:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100cad:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cb2:	e9 52 01 00 00       	jmp    f0100e09 <check_page_free_list+0x260>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100cb7:	39 ca                	cmp    %ecx,%edx
f0100cb9:	73 19                	jae    f0100cd4 <check_page_free_list+0x12b>
f0100cbb:	68 8b 74 10 f0       	push   $0xf010748b
f0100cc0:	68 97 74 10 f0       	push   $0xf0107497
f0100cc5:	68 12 03 00 00       	push   $0x312
f0100cca:	68 71 74 10 f0       	push   $0xf0107471
f0100ccf:	e8 6c f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100cd4:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100cd7:	72 19                	jb     f0100cf2 <check_page_free_list+0x149>
f0100cd9:	68 ac 74 10 f0       	push   $0xf01074ac
f0100cde:	68 97 74 10 f0       	push   $0xf0107497
f0100ce3:	68 13 03 00 00       	push   $0x313
f0100ce8:	68 71 74 10 f0       	push   $0xf0107471
f0100ced:	e8 4e f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cf2:	89 d0                	mov    %edx,%eax
f0100cf4:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100cf7:	a8 07                	test   $0x7,%al
f0100cf9:	74 19                	je     f0100d14 <check_page_free_list+0x16b>
f0100cfb:	68 4c 6b 10 f0       	push   $0xf0106b4c
f0100d00:	68 97 74 10 f0       	push   $0xf0107497
f0100d05:	68 14 03 00 00       	push   $0x314
f0100d0a:	68 71 74 10 f0       	push   $0xf0107471
f0100d0f:	e8 2c f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d14:	c1 f8 03             	sar    $0x3,%eax
f0100d17:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100d1a:	85 c0                	test   %eax,%eax
f0100d1c:	75 19                	jne    f0100d37 <check_page_free_list+0x18e>
f0100d1e:	68 c0 74 10 f0       	push   $0xf01074c0
f0100d23:	68 97 74 10 f0       	push   $0xf0107497
f0100d28:	68 17 03 00 00       	push   $0x317
f0100d2d:	68 71 74 10 f0       	push   $0xf0107471
f0100d32:	e8 09 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d37:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d3c:	75 19                	jne    f0100d57 <check_page_free_list+0x1ae>
f0100d3e:	68 d1 74 10 f0       	push   $0xf01074d1
f0100d43:	68 97 74 10 f0       	push   $0xf0107497
f0100d48:	68 18 03 00 00       	push   $0x318
f0100d4d:	68 71 74 10 f0       	push   $0xf0107471
f0100d52:	e8 e9 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d57:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d5c:	75 19                	jne    f0100d77 <check_page_free_list+0x1ce>
f0100d5e:	68 80 6b 10 f0       	push   $0xf0106b80
f0100d63:	68 97 74 10 f0       	push   $0xf0107497
f0100d68:	68 19 03 00 00       	push   $0x319
f0100d6d:	68 71 74 10 f0       	push   $0xf0107471
f0100d72:	e8 c9 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d77:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d7c:	75 19                	jne    f0100d97 <check_page_free_list+0x1ee>
f0100d7e:	68 ea 74 10 f0       	push   $0xf01074ea
f0100d83:	68 97 74 10 f0       	push   $0xf0107497
f0100d88:	68 1a 03 00 00       	push   $0x31a
f0100d8d:	68 71 74 10 f0       	push   $0xf0107471
f0100d92:	e8 a9 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d97:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d9c:	0f 86 f1 00 00 00    	jbe    f0100e93 <check_page_free_list+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100da2:	89 c7                	mov    %eax,%edi
f0100da4:	c1 ef 0c             	shr    $0xc,%edi
f0100da7:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100daa:	77 12                	ja     f0100dbe <check_page_free_list+0x215>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100dac:	50                   	push   %eax
f0100dad:	68 a4 65 10 f0       	push   $0xf01065a4
f0100db2:	6a 58                	push   $0x58
f0100db4:	68 7d 74 10 f0       	push   $0xf010747d
f0100db9:	e8 82 f2 ff ff       	call   f0100040 <_panic>
f0100dbe:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100dc4:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100dc7:	0f 86 b6 00 00 00    	jbe    f0100e83 <check_page_free_list+0x2da>
f0100dcd:	68 a4 6b 10 f0       	push   $0xf0106ba4
f0100dd2:	68 97 74 10 f0       	push   $0xf0107497
f0100dd7:	68 1b 03 00 00       	push   $0x31b
f0100ddc:	68 71 74 10 f0       	push   $0xf0107471
f0100de1:	e8 5a f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100de6:	68 04 75 10 f0       	push   $0xf0107504
f0100deb:	68 97 74 10 f0       	push   $0xf0107497
f0100df0:	68 1d 03 00 00       	push   $0x31d
f0100df5:	68 71 74 10 f0       	push   $0xf0107471
f0100dfa:	e8 41 f2 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM) 
			++nfree_basemem;
f0100dff:	83 c6 01             	add    $0x1,%esi
f0100e02:	eb 03                	jmp    f0100e07 <check_page_free_list+0x25e>
                else
			++nfree_extmem;
f0100e04:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e07:	8b 12                	mov    (%edx),%edx
f0100e09:	85 d2                	test   %edx,%edx
f0100e0b:	0f 85 a6 fe ff ff    	jne    f0100cb7 <check_page_free_list+0x10e>
			++nfree_basemem;
                else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100e11:	85 f6                	test   %esi,%esi
f0100e13:	7f 19                	jg     f0100e2e <check_page_free_list+0x285>
f0100e15:	68 21 75 10 f0       	push   $0xf0107521
f0100e1a:	68 97 74 10 f0       	push   $0xf0107497
f0100e1f:	68 25 03 00 00       	push   $0x325
f0100e24:	68 71 74 10 f0       	push   $0xf0107471
f0100e29:	e8 12 f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e2e:	85 db                	test   %ebx,%ebx
f0100e30:	7f 19                	jg     f0100e4b <check_page_free_list+0x2a2>
f0100e32:	68 33 75 10 f0       	push   $0xf0107533
f0100e37:	68 97 74 10 f0       	push   $0xf0107497
f0100e3c:	68 26 03 00 00       	push   $0x326
f0100e41:	68 71 74 10 f0       	push   $0xf0107471
f0100e46:	e8 f5 f1 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100e4b:	83 ec 0c             	sub    $0xc,%esp
f0100e4e:	68 ec 6b 10 f0       	push   $0xf0106bec
f0100e53:	e8 35 2a 00 00       	call   f010388d <cprintf>
}
f0100e58:	eb 49                	jmp    f0100ea3 <check_page_free_list+0x2fa>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e5a:	a1 40 12 21 f0       	mov    0xf0211240,%eax
f0100e5f:	85 c0                	test   %eax,%eax
f0100e61:	0f 85 6f fd ff ff    	jne    f0100bd6 <check_page_free_list+0x2d>
f0100e67:	e9 53 fd ff ff       	jmp    f0100bbf <check_page_free_list+0x16>
f0100e6c:	83 3d 40 12 21 f0 00 	cmpl   $0x0,0xf0211240
f0100e73:	0f 84 46 fd ff ff    	je     f0100bbf <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e79:	be 00 04 00 00       	mov    $0x400,%esi
f0100e7e:	e9 a1 fd ff ff       	jmp    f0100c24 <check_page_free_list+0x7b>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e83:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e88:	0f 85 76 ff ff ff    	jne    f0100e04 <check_page_free_list+0x25b>
f0100e8e:	e9 53 ff ff ff       	jmp    f0100de6 <check_page_free_list+0x23d>
f0100e93:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e98:	0f 85 61 ff ff ff    	jne    f0100dff <check_page_free_list+0x256>
f0100e9e:	e9 43 ff ff ff       	jmp    f0100de6 <check_page_free_list+0x23d>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f0100ea3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ea6:	5b                   	pop    %ebx
f0100ea7:	5e                   	pop    %esi
f0100ea8:	5f                   	pop    %edi
f0100ea9:	5d                   	pop    %ebp
f0100eaa:	c3                   	ret    

f0100eab <page_init>:
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

        // 1) Mark page 0 as used        
        pages[0].pp_ref++;
f0100eab:	a1 90 1e 21 f0       	mov    0xf0211e90,%eax
f0100eb0:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0100eb5:	8b 15 40 12 21 f0    	mov    0xf0211240,%edx
f0100ebb:	b8 08 00 00 00       	mov    $0x8,%eax
        // 2) All base pages except 0 are free
        size_t i;
        size_t mpentry_page = MPENTRY_PADDR / PGSIZE; 

        for (i = 1; i < mpentry_page; i++) {
                pages[i].pp_link = page_free_list;
f0100ec0:	8b 0d 90 1e 21 f0    	mov    0xf0211e90,%ecx
f0100ec6:	89 14 01             	mov    %edx,(%ecx,%eax,1)
                page_free_list = &pages[i];
f0100ec9:	8b 0d 90 1e 21 f0    	mov    0xf0211e90,%ecx
f0100ecf:	8d 14 01             	lea    (%ecx,%eax,1),%edx
f0100ed2:	83 c0 08             	add    $0x8,%eax
       
        // 2) All base pages except 0 are free
        size_t i;
        size_t mpentry_page = MPENTRY_PADDR / PGSIZE; 

        for (i = 1; i < mpentry_page; i++) {
f0100ed5:	83 f8 38             	cmp    $0x38,%eax
f0100ed8:	75 e6                	jne    f0100ec0 <page_init+0x15>
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100eda:	55                   	push   %ebp
f0100edb:	89 e5                	mov    %esp,%ebp
f0100edd:	56                   	push   %esi
f0100ede:	53                   	push   %ebx
f0100edf:	89 15 40 12 21 f0    	mov    %edx,0xf0211240
        for (i = 1; i < mpentry_page; i++) {
                pages[i].pp_link = page_free_list;
                page_free_list = &pages[i];
        }

        pages[mpentry_page].pp_ref++;
f0100ee5:	66 83 41 3c 01       	addw   $0x1,0x3c(%ecx)

        for (i = mpentry_page + 1; i < npages_basemem; i++) {
f0100eea:	8b 1d 44 12 21 f0    	mov    0xf0211244,%ebx
f0100ef0:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100ef5:	b8 08 00 00 00       	mov    $0x8,%eax
f0100efa:	eb 20                	jmp    f0100f1c <page_init+0x71>
f0100efc:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
                pages[i].pp_link = page_free_list;
f0100f03:	8b 35 90 1e 21 f0    	mov    0xf0211e90,%esi
f0100f09:	89 14 c6             	mov    %edx,(%esi,%eax,8)
                page_free_list = &pages[i];
        }

        pages[mpentry_page].pp_ref++;

        for (i = mpentry_page + 1; i < npages_basemem; i++) {
f0100f0c:	83 c0 01             	add    $0x1,%eax
                pages[i].pp_link = page_free_list;
                page_free_list = &pages[i];
f0100f0f:	89 ca                	mov    %ecx,%edx
f0100f11:	03 15 90 1e 21 f0    	add    0xf0211e90,%edx
f0100f17:	b9 01 00 00 00       	mov    $0x1,%ecx
                page_free_list = &pages[i];
        }

        pages[mpentry_page].pp_ref++;

        for (i = mpentry_page + 1; i < npages_basemem; i++) {
f0100f1c:	39 d8                	cmp    %ebx,%eax
f0100f1e:	72 dc                	jb     f0100efc <page_init+0x51>
f0100f20:	84 c9                	test   %cl,%cl
f0100f22:	74 06                	je     f0100f2a <page_init+0x7f>
f0100f24:	89 15 40 12 21 f0    	mov    %edx,0xf0211240
                page_free_list = &pages[i];
        }

        // 4) We find the next free memory (boot_alloc() outputs a rounded-up virtual address),
        // convert it to a physical address and get the index of free pages by dividing by PGSIZE  
        for (i = PADDR(boot_alloc(0)) / PGSIZE; i < npages; i++) {
f0100f2a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f2f:	e8 f6 fb ff ff       	call   f0100b2a <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100f34:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100f39:	77 15                	ja     f0100f50 <page_init+0xa5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f3b:	50                   	push   %eax
f0100f3c:	68 c8 65 10 f0       	push   $0xf01065c8
f0100f41:	68 58 01 00 00       	push   $0x158
f0100f46:	68 71 74 10 f0       	push   $0xf0107471
f0100f4b:	e8 f0 f0 ff ff       	call   f0100040 <_panic>
f0100f50:	05 00 00 00 10       	add    $0x10000000,%eax
f0100f55:	c1 e8 0c             	shr    $0xc,%eax
f0100f58:	8b 0d 40 12 21 f0    	mov    0xf0211240,%ecx
f0100f5e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100f65:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100f6a:	eb 1c                	jmp    f0100f88 <page_init+0xdd>
                pages[i].pp_link = page_free_list;
f0100f6c:	8b 35 90 1e 21 f0    	mov    0xf0211e90,%esi
f0100f72:	89 0c 16             	mov    %ecx,(%esi,%edx,1)
                page_free_list = &pages[i];
f0100f75:	89 d1                	mov    %edx,%ecx
f0100f77:	03 0d 90 1e 21 f0    	add    0xf0211e90,%ecx
                page_free_list = &pages[i];
        }

        // 4) We find the next free memory (boot_alloc() outputs a rounded-up virtual address),
        // convert it to a physical address and get the index of free pages by dividing by PGSIZE  
        for (i = PADDR(boot_alloc(0)) / PGSIZE; i < npages; i++) {
f0100f7d:	83 c0 01             	add    $0x1,%eax
f0100f80:	83 c2 08             	add    $0x8,%edx
f0100f83:	bb 01 00 00 00       	mov    $0x1,%ebx
f0100f88:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f0100f8e:	72 dc                	jb     f0100f6c <page_init+0xc1>
f0100f90:	84 db                	test   %bl,%bl
f0100f92:	74 06                	je     f0100f9a <page_init+0xef>
f0100f94:	89 0d 40 12 21 f0    	mov    %ecx,0xf0211240
                pages[i].pp_link = page_free_list;
                page_free_list = &pages[i];
        }
}
f0100f9a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100f9d:	5b                   	pop    %ebx
f0100f9e:	5e                   	pop    %esi
f0100f9f:	5d                   	pop    %ebp
f0100fa0:	c3                   	ret    

f0100fa1 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100fa1:	55                   	push   %ebp
f0100fa2:	89 e5                	mov    %esp,%ebp
f0100fa4:	53                   	push   %ebx
f0100fa5:	83 ec 04             	sub    $0x4,%esp
        if (page_free_list == NULL)
f0100fa8:	8b 1d 40 12 21 f0    	mov    0xf0211240,%ebx
f0100fae:	85 db                	test   %ebx,%ebx
f0100fb0:	74 58                	je     f010100a <page_alloc+0x69>
                return NULL;

        struct PageInfo *page = page_free_list;
        page_free_list = page->pp_link;
f0100fb2:	8b 03                	mov    (%ebx),%eax
f0100fb4:	a3 40 12 21 f0       	mov    %eax,0xf0211240

	if (alloc_flags & ALLOC_ZERO) {
f0100fb9:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100fbd:	74 45                	je     f0101004 <page_alloc+0x63>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100fbf:	89 d8                	mov    %ebx,%eax
f0100fc1:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0100fc7:	c1 f8 03             	sar    $0x3,%eax
f0100fca:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fcd:	89 c2                	mov    %eax,%edx
f0100fcf:	c1 ea 0c             	shr    $0xc,%edx
f0100fd2:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0100fd8:	72 12                	jb     f0100fec <page_alloc+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fda:	50                   	push   %eax
f0100fdb:	68 a4 65 10 f0       	push   $0xf01065a4
f0100fe0:	6a 58                	push   $0x58
f0100fe2:	68 7d 74 10 f0       	push   $0xf010747d
f0100fe7:	e8 54 f0 ff ff       	call   f0100040 <_panic>
                char *p = page2kva(page);
                memset(p, 0, PGSIZE);
f0100fec:	83 ec 04             	sub    $0x4,%esp
f0100fef:	68 00 10 00 00       	push   $0x1000
f0100ff4:	6a 00                	push   $0x0
f0100ff6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ffb:	50                   	push   %eax
f0100ffc:	e8 b6 48 00 00       	call   f01058b7 <memset>
f0101001:	83 c4 10             	add    $0x10,%esp
        }

        page->pp_link = NULL;
f0101004:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        return page;
}
f010100a:	89 d8                	mov    %ebx,%eax
f010100c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010100f:	c9                   	leave  
f0101010:	c3                   	ret    

f0101011 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101011:	55                   	push   %ebp
f0101012:	89 e5                	mov    %esp,%ebp
f0101014:	83 ec 08             	sub    $0x8,%esp
f0101017:	8b 45 08             	mov    0x8(%ebp),%eax
        assert(pp);
f010101a:	85 c0                	test   %eax,%eax
f010101c:	75 19                	jne    f0101037 <page_free+0x26>
f010101e:	68 7e 76 10 f0       	push   $0xf010767e
f0101023:	68 97 74 10 f0       	push   $0xf0107497
f0101028:	68 83 01 00 00       	push   $0x183
f010102d:	68 71 74 10 f0       	push   $0xf0107471
f0101032:	e8 09 f0 ff ff       	call   f0100040 <_panic>

        // Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
        if (pp->pp_ref != 0) 
f0101037:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010103c:	74 17                	je     f0101055 <page_free+0x44>
                panic("pp->pp_ref is nonzero\n");
f010103e:	83 ec 04             	sub    $0x4,%esp
f0101041:	68 44 75 10 f0       	push   $0xf0107544
f0101046:	68 89 01 00 00       	push   $0x189
f010104b:	68 71 74 10 f0       	push   $0xf0107471
f0101050:	e8 eb ef ff ff       	call   f0100040 <_panic>

        if (pp->pp_link != NULL)
f0101055:	83 38 00             	cmpl   $0x0,(%eax)
f0101058:	74 17                	je     f0101071 <page_free+0x60>
                panic("pp->pp_link is not NULL\n");
f010105a:	83 ec 04             	sub    $0x4,%esp
f010105d:	68 5b 75 10 f0       	push   $0xf010755b
f0101062:	68 8c 01 00 00       	push   $0x18c
f0101067:	68 71 74 10 f0       	push   $0xf0107471
f010106c:	e8 cf ef ff ff       	call   f0100040 <_panic>

        pp->pp_link = page_free_list;
f0101071:	8b 15 40 12 21 f0    	mov    0xf0211240,%edx
f0101077:	89 10                	mov    %edx,(%eax)
        page_free_list = pp;
f0101079:	a3 40 12 21 f0       	mov    %eax,0xf0211240
}
f010107e:	c9                   	leave  
f010107f:	c3                   	ret    

f0101080 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101080:	55                   	push   %ebp
f0101081:	89 e5                	mov    %esp,%ebp
f0101083:	83 ec 08             	sub    $0x8,%esp
f0101086:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101089:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f010108d:	83 e8 01             	sub    $0x1,%eax
f0101090:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101094:	66 85 c0             	test   %ax,%ax
f0101097:	75 0c                	jne    f01010a5 <page_decref+0x25>
		page_free(pp);
f0101099:	83 ec 0c             	sub    $0xc,%esp
f010109c:	52                   	push   %edx
f010109d:	e8 6f ff ff ff       	call   f0101011 <page_free>
f01010a2:	83 c4 10             	add    $0x10,%esp
}
f01010a5:	c9                   	leave  
f01010a6:	c3                   	ret    

f01010a7 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01010a7:	55                   	push   %ebp
f01010a8:	89 e5                	mov    %esp,%ebp
f01010aa:	56                   	push   %esi
f01010ab:	53                   	push   %ebx
f01010ac:	8b 45 08             	mov    0x8(%ebp),%eax
f01010af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        assert(pgdir);
f01010b2:	85 c0                	test   %eax,%eax
f01010b4:	75 19                	jne    f01010cf <pgdir_walk+0x28>
f01010b6:	68 74 75 10 f0       	push   $0xf0107574
f01010bb:	68 97 74 10 f0       	push   $0xf0107497
f01010c0:	68 b6 01 00 00       	push   $0x1b6
f01010c5:	68 71 74 10 f0       	push   $0xf0107471
f01010ca:	e8 71 ef ff ff       	call   f0100040 <_panic>

        size_t pdx = PDX(va);
        pde_t pd_entry = pgdir[pdx]; 
f01010cf:	89 da                	mov    %ebx,%edx
f01010d1:	c1 ea 16             	shr    $0x16,%edx
f01010d4:	8d 34 90             	lea    (%eax,%edx,4),%esi
f01010d7:	8b 16                	mov    (%esi),%edx
       
        pte_t *pt = NULL; 
        if ((pd_entry & PTE_P) == PTE_P) {
f01010d9:	f6 c2 01             	test   $0x1,%dl
f01010dc:	74 30                	je     f010110e <pgdir_walk+0x67>
                pt = (pte_t *) KADDR(PTE_ADDR(pd_entry));
f01010de:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010e4:	89 d0                	mov    %edx,%eax
f01010e6:	c1 e8 0c             	shr    $0xc,%eax
f01010e9:	39 05 88 1e 21 f0    	cmp    %eax,0xf0211e88
f01010ef:	77 15                	ja     f0101106 <pgdir_walk+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010f1:	52                   	push   %edx
f01010f2:	68 a4 65 10 f0       	push   $0xf01065a4
f01010f7:	68 bd 01 00 00       	push   $0x1bd
f01010fc:	68 71 74 10 f0       	push   $0xf0107471
f0101101:	e8 3a ef ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101106:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010110c:	eb 60                	jmp    f010116e <pgdir_walk+0xc7>
        } else {
                if (create == 0)
f010110e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101112:	74 68                	je     f010117c <pgdir_walk+0xd5>
                        return NULL;

                struct PageInfo *pt_page = page_alloc(ALLOC_ZERO);
f0101114:	83 ec 0c             	sub    $0xc,%esp
f0101117:	6a 01                	push   $0x1
f0101119:	e8 83 fe ff ff       	call   f0100fa1 <page_alloc>
                if (pt_page == NULL)
f010111e:	83 c4 10             	add    $0x10,%esp
f0101121:	85 c0                	test   %eax,%eax
f0101123:	74 5e                	je     f0101183 <pgdir_walk+0xdc>
                        return NULL;

                pgdir[pdx] = page2pa(pt_page) | PTE_U | PTE_W | PTE_P;
f0101125:	89 c2                	mov    %eax,%edx
f0101127:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f010112d:	c1 fa 03             	sar    $0x3,%edx
f0101130:	c1 e2 0c             	shl    $0xc,%edx
f0101133:	83 ca 07             	or     $0x7,%edx
f0101136:	89 16                	mov    %edx,(%esi)

                pt_page->pp_ref++;
f0101138:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010113d:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0101143:	c1 f8 03             	sar    $0x3,%eax
f0101146:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101149:	89 c2                	mov    %eax,%edx
f010114b:	c1 ea 0c             	shr    $0xc,%edx
f010114e:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0101154:	72 12                	jb     f0101168 <pgdir_walk+0xc1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101156:	50                   	push   %eax
f0101157:	68 a4 65 10 f0       	push   $0xf01065a4
f010115c:	6a 58                	push   $0x58
f010115e:	68 7d 74 10 f0       	push   $0xf010747d
f0101163:	e8 d8 ee ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101168:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
                pt = (pte_t *) page2kva(pt_page);
        }

        return &pt[PTX(va)];
f010116e:	c1 eb 0a             	shr    $0xa,%ebx
f0101171:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0101177:	8d 04 1a             	lea    (%edx,%ebx,1),%eax
f010117a:	eb 0c                	jmp    f0101188 <pgdir_walk+0xe1>
        pte_t *pt = NULL; 
        if ((pd_entry & PTE_P) == PTE_P) {
                pt = (pte_t *) KADDR(PTE_ADDR(pd_entry));
        } else {
                if (create == 0)
                        return NULL;
f010117c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101181:	eb 05                	jmp    f0101188 <pgdir_walk+0xe1>

                struct PageInfo *pt_page = page_alloc(ALLOC_ZERO);
                if (pt_page == NULL)
                        return NULL;
f0101183:	b8 00 00 00 00       	mov    $0x0,%eax
                pt_page->pp_ref++;
                pt = (pte_t *) page2kva(pt_page);
        }

        return &pt[PTX(va)];
}
f0101188:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010118b:	5b                   	pop    %ebx
f010118c:	5e                   	pop    %esi
f010118d:	5d                   	pop    %ebp
f010118e:	c3                   	ret    

f010118f <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f010118f:	55                   	push   %ebp
f0101190:	89 e5                	mov    %esp,%ebp
f0101192:	57                   	push   %edi
f0101193:	56                   	push   %esi
f0101194:	53                   	push   %ebx
f0101195:	83 ec 1c             	sub    $0x1c,%esp
f0101198:	89 c7                	mov    %eax,%edi
f010119a:	8b 45 08             	mov    0x8(%ebp),%eax
        assert(pgdir);
f010119d:	85 ff                	test   %edi,%edi
f010119f:	74 1d                	je     f01011be <boot_map_region+0x2f>

        uintptr_t map_va = va;
        physaddr_t map_pa = pa;

        size_t i;
        for (i = 0; i < size / PGSIZE; i++) {
f01011a1:	c1 e9 0c             	shr    $0xc,%ecx
f01011a4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f01011a7:	89 c3                	mov    %eax,%ebx
f01011a9:	be 00 00 00 00       	mov    $0x0,%esi
                pte_t *pte = pgdir_walk(pgdir, (void *) map_va, 1);
f01011ae:	29 c2                	sub    %eax,%edx
f01011b0:	89 55 e0             	mov    %edx,-0x20(%ebp)
                assert(pte);

                *pte = map_pa | perm | PTE_P;
f01011b3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011b6:	83 c8 01             	or     $0x1,%eax
f01011b9:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01011bc:	eb 5a                	jmp    f0101218 <boot_map_region+0x89>
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
        assert(pgdir);
f01011be:	68 74 75 10 f0       	push   $0xf0107574
f01011c3:	68 97 74 10 f0       	push   $0xf0107497
f01011c8:	68 dd 01 00 00       	push   $0x1dd
f01011cd:	68 71 74 10 f0       	push   $0xf0107471
f01011d2:	e8 69 ee ff ff       	call   f0100040 <_panic>
        uintptr_t map_va = va;
        physaddr_t map_pa = pa;

        size_t i;
        for (i = 0; i < size / PGSIZE; i++) {
                pte_t *pte = pgdir_walk(pgdir, (void *) map_va, 1);
f01011d7:	83 ec 04             	sub    $0x4,%esp
f01011da:	6a 01                	push   $0x1
f01011dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01011df:	01 d8                	add    %ebx,%eax
f01011e1:	50                   	push   %eax
f01011e2:	57                   	push   %edi
f01011e3:	e8 bf fe ff ff       	call   f01010a7 <pgdir_walk>
                assert(pte);
f01011e8:	83 c4 10             	add    $0x10,%esp
f01011eb:	85 c0                	test   %eax,%eax
f01011ed:	75 19                	jne    f0101208 <boot_map_region+0x79>
f01011ef:	68 7a 75 10 f0       	push   $0xf010757a
f01011f4:	68 97 74 10 f0       	push   $0xf0107497
f01011f9:	68 e5 01 00 00       	push   $0x1e5
f01011fe:	68 71 74 10 f0       	push   $0xf0107471
f0101203:	e8 38 ee ff ff       	call   f0100040 <_panic>

                *pte = map_pa | perm | PTE_P;
f0101208:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010120b:	09 da                	or     %ebx,%edx
f010120d:	89 10                	mov    %edx,(%eax)

                map_va += PGSIZE;
                map_pa += PGSIZE;
f010120f:	81 c3 00 10 00 00    	add    $0x1000,%ebx

        uintptr_t map_va = va;
        physaddr_t map_pa = pa;

        size_t i;
        for (i = 0; i < size / PGSIZE; i++) {
f0101215:	83 c6 01             	add    $0x1,%esi
f0101218:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f010121b:	75 ba                	jne    f01011d7 <boot_map_region+0x48>
                *pte = map_pa | perm | PTE_P;

                map_va += PGSIZE;
                map_pa += PGSIZE;
        }
}
f010121d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101220:	5b                   	pop    %ebx
f0101221:	5e                   	pop    %esi
f0101222:	5f                   	pop    %edi
f0101223:	5d                   	pop    %ebp
f0101224:	c3                   	ret    

f0101225 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101225:	55                   	push   %ebp
f0101226:	89 e5                	mov    %esp,%ebp
f0101228:	53                   	push   %ebx
f0101229:	83 ec 04             	sub    $0x4,%esp
f010122c:	8b 45 08             	mov    0x8(%ebp),%eax
f010122f:	8b 5d 10             	mov    0x10(%ebp),%ebx
        assert(pgdir);
f0101232:	85 c0                	test   %eax,%eax
f0101234:	75 19                	jne    f010124f <page_lookup+0x2a>
f0101236:	68 74 75 10 f0       	push   $0xf0107574
f010123b:	68 97 74 10 f0       	push   $0xf0107497
f0101240:	68 32 02 00 00       	push   $0x232
f0101245:	68 71 74 10 f0       	push   $0xf0107471
f010124a:	e8 f1 ed ff ff       	call   f0100040 <_panic>

        pte_t *pte = pgdir_walk(pgdir, va, 0);
f010124f:	83 ec 04             	sub    $0x4,%esp
f0101252:	6a 00                	push   $0x0
f0101254:	ff 75 0c             	pushl  0xc(%ebp)
f0101257:	50                   	push   %eax
f0101258:	e8 4a fe ff ff       	call   f01010a7 <pgdir_walk>
        // No page mapped at va
        if (pte == NULL || (*pte & PTE_P) != PTE_P)
f010125d:	83 c4 10             	add    $0x10,%esp
f0101260:	85 c0                	test   %eax,%eax
f0101262:	74 37                	je     f010129b <page_lookup+0x76>
f0101264:	f6 00 01             	testb  $0x1,(%eax)
f0101267:	74 39                	je     f01012a2 <page_lookup+0x7d>
                return NULL;

        if (pte_store)
f0101269:	85 db                	test   %ebx,%ebx
f010126b:	74 02                	je     f010126f <page_lookup+0x4a>
                *pte_store = pte;
f010126d:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010126f:	8b 00                	mov    (%eax),%eax
f0101271:	c1 e8 0c             	shr    $0xc,%eax
f0101274:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f010127a:	72 14                	jb     f0101290 <page_lookup+0x6b>
		panic("pa2page called with invalid pa");
f010127c:	83 ec 04             	sub    $0x4,%esp
f010127f:	68 10 6c 10 f0       	push   $0xf0106c10
f0101284:	6a 51                	push   $0x51
f0101286:	68 7d 74 10 f0       	push   $0xf010747d
f010128b:	e8 b0 ed ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0101290:	8b 15 90 1e 21 f0    	mov    0xf0211e90,%edx
f0101296:	8d 04 c2             	lea    (%edx,%eax,8),%eax

        return pa2page(PTE_ADDR(*pte));
f0101299:	eb 0c                	jmp    f01012a7 <page_lookup+0x82>
        assert(pgdir);

        pte_t *pte = pgdir_walk(pgdir, va, 0);
        // No page mapped at va
        if (pte == NULL || (*pte & PTE_P) != PTE_P)
                return NULL;
f010129b:	b8 00 00 00 00       	mov    $0x0,%eax
f01012a0:	eb 05                	jmp    f01012a7 <page_lookup+0x82>
f01012a2:	b8 00 00 00 00       	mov    $0x0,%eax

        if (pte_store)
                *pte_store = pte;

        return pa2page(PTE_ADDR(*pte));
}
f01012a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01012aa:	c9                   	leave  
f01012ab:	c3                   	ret    

f01012ac <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01012ac:	55                   	push   %ebp
f01012ad:	89 e5                	mov    %esp,%ebp
f01012af:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01012b2:	e8 23 4c 00 00       	call   f0105eda <cpunum>
f01012b7:	6b c0 74             	imul   $0x74,%eax,%eax
f01012ba:	83 b8 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%eax)
f01012c1:	74 16                	je     f01012d9 <tlb_invalidate+0x2d>
f01012c3:	e8 12 4c 00 00       	call   f0105eda <cpunum>
f01012c8:	6b c0 74             	imul   $0x74,%eax,%eax
f01012cb:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01012d1:	8b 55 08             	mov    0x8(%ebp),%edx
f01012d4:	39 50 60             	cmp    %edx,0x60(%eax)
f01012d7:	75 06                	jne    f01012df <tlb_invalidate+0x33>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01012d9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01012dc:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f01012df:	c9                   	leave  
f01012e0:	c3                   	ret    

f01012e1 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01012e1:	55                   	push   %ebp
f01012e2:	89 e5                	mov    %esp,%ebp
f01012e4:	56                   	push   %esi
f01012e5:	53                   	push   %ebx
f01012e6:	83 ec 10             	sub    $0x10,%esp
f01012e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01012ec:	8b 75 0c             	mov    0xc(%ebp),%esi
        assert(pgdir);
f01012ef:	85 db                	test   %ebx,%ebx
f01012f1:	75 19                	jne    f010130c <page_remove+0x2b>
f01012f3:	68 74 75 10 f0       	push   $0xf0107574
f01012f8:	68 97 74 10 f0       	push   $0xf0107497
f01012fd:	68 51 02 00 00       	push   $0x251
f0101302:	68 71 74 10 f0       	push   $0xf0107471
f0101307:	e8 34 ed ff ff       	call   f0100040 <_panic>

        pte_t *pte;
        struct PageInfo *page = page_lookup(pgdir, va, &pte);
f010130c:	83 ec 04             	sub    $0x4,%esp
f010130f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101312:	50                   	push   %eax
f0101313:	56                   	push   %esi
f0101314:	53                   	push   %ebx
f0101315:	e8 0b ff ff ff       	call   f0101225 <page_lookup>
        // Silently do nothing
        if (page == NULL || (*pte & PTE_P) != PTE_P)
f010131a:	83 c4 10             	add    $0x10,%esp
f010131d:	85 c0                	test   %eax,%eax
f010131f:	74 27                	je     f0101348 <page_remove+0x67>
f0101321:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101324:	f6 02 01             	testb  $0x1,(%edx)
f0101327:	74 1f                	je     f0101348 <page_remove+0x67>
                return;

        page_decref(page);
f0101329:	83 ec 0c             	sub    $0xc,%esp
f010132c:	50                   	push   %eax
f010132d:	e8 4e fd ff ff       	call   f0101080 <page_decref>

        // Zero the table entry
        *pte = 0;
f0101332:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101335:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

        tlb_invalidate(pgdir, va);
f010133b:	83 c4 08             	add    $0x8,%esp
f010133e:	56                   	push   %esi
f010133f:	53                   	push   %ebx
f0101340:	e8 67 ff ff ff       	call   f01012ac <tlb_invalidate>
f0101345:	83 c4 10             	add    $0x10,%esp
}
f0101348:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010134b:	5b                   	pop    %ebx
f010134c:	5e                   	pop    %esi
f010134d:	5d                   	pop    %ebp
f010134e:	c3                   	ret    

f010134f <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010134f:	55                   	push   %ebp
f0101350:	89 e5                	mov    %esp,%ebp
f0101352:	57                   	push   %edi
f0101353:	56                   	push   %esi
f0101354:	53                   	push   %ebx
f0101355:	83 ec 0c             	sub    $0xc,%esp
f0101358:	8b 7d 08             	mov    0x8(%ebp),%edi
f010135b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        assert(pgdir);
f010135e:	85 ff                	test   %edi,%edi
f0101360:	75 19                	jne    f010137b <page_insert+0x2c>
f0101362:	68 74 75 10 f0       	push   $0xf0107574
f0101367:	68 97 74 10 f0       	push   $0xf0107497
f010136c:	68 0a 02 00 00       	push   $0x20a
f0101371:	68 71 74 10 f0       	push   $0xf0107471
f0101376:	e8 c5 ec ff ff       	call   f0100040 <_panic>
        assert(pp);
f010137b:	85 db                	test   %ebx,%ebx
f010137d:	75 19                	jne    f0101398 <page_insert+0x49>
f010137f:	68 7e 76 10 f0       	push   $0xf010767e
f0101384:	68 97 74 10 f0       	push   $0xf0107497
f0101389:	68 0b 02 00 00       	push   $0x20b
f010138e:	68 71 74 10 f0       	push   $0xf0107471
f0101393:	e8 a8 ec ff ff       	call   f0100040 <_panic>

        // Return -E_NO_MEM when it fails
        pte_t *pte = pgdir_walk(pgdir, va, 1);
f0101398:	83 ec 04             	sub    $0x4,%esp
f010139b:	6a 01                	push   $0x1
f010139d:	ff 75 10             	pushl  0x10(%ebp)
f01013a0:	57                   	push   %edi
f01013a1:	e8 01 fd ff ff       	call   f01010a7 <pgdir_walk>
f01013a6:	89 c6                	mov    %eax,%esi
        if (pte == NULL)
f01013a8:	83 c4 10             	add    $0x10,%esp
f01013ab:	85 c0                	test   %eax,%eax
f01013ad:	74 5a                	je     f0101409 <page_insert+0xba>
                return -E_NO_MEM;

        if ((*pte & PTE_P) == PTE_P) {
f01013af:	8b 00                	mov    (%eax),%eax
f01013b1:	a8 01                	test   $0x1,%al
f01013b3:	74 32                	je     f01013e7 <page_insert+0x98>
                // We don't increment ref because it's the same page
                // but we just change its permissions (this is in tests)
                if (PTE_ADDR(*pte) == page2pa(pp))
f01013b5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01013ba:	89 da                	mov    %ebx,%edx
f01013bc:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f01013c2:	c1 fa 03             	sar    $0x3,%edx
f01013c5:	c1 e2 0c             	shl    $0xc,%edx
f01013c8:	39 d0                	cmp    %edx,%eax
f01013ca:	74 20                	je     f01013ec <page_insert+0x9d>
                        goto page_insert_success;

                page_remove(pgdir, va);
f01013cc:	83 ec 08             	sub    $0x8,%esp
f01013cf:	ff 75 10             	pushl  0x10(%ebp)
f01013d2:	57                   	push   %edi
f01013d3:	e8 09 ff ff ff       	call   f01012e1 <page_remove>
                // If the page was formerly at va, we invalidate the TLB
                tlb_invalidate(pgdir, va);
f01013d8:	83 c4 08             	add    $0x8,%esp
f01013db:	ff 75 10             	pushl  0x10(%ebp)
f01013de:	57                   	push   %edi
f01013df:	e8 c8 fe ff ff       	call   f01012ac <tlb_invalidate>
f01013e4:	83 c4 10             	add    $0x10,%esp
        }

        pp->pp_ref++;
f01013e7:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)

page_insert_success:
        *pte = page2pa(pp) | perm | PTE_P;
f01013ec:	2b 1d 90 1e 21 f0    	sub    0xf0211e90,%ebx
f01013f2:	c1 fb 03             	sar    $0x3,%ebx
f01013f5:	c1 e3 0c             	shl    $0xc,%ebx
f01013f8:	8b 45 14             	mov    0x14(%ebp),%eax
f01013fb:	83 c8 01             	or     $0x1,%eax
f01013fe:	09 c3                	or     %eax,%ebx
f0101400:	89 1e                	mov    %ebx,(%esi)
        return 0; 
f0101402:	b8 00 00 00 00       	mov    $0x0,%eax
f0101407:	eb 05                	jmp    f010140e <page_insert+0xbf>
        assert(pp);

        // Return -E_NO_MEM when it fails
        pte_t *pte = pgdir_walk(pgdir, va, 1);
        if (pte == NULL)
                return -E_NO_MEM;
f0101409:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
        pp->pp_ref++;

page_insert_success:
        *pte = page2pa(pp) | perm | PTE_P;
        return 0; 
}
f010140e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101411:	5b                   	pop    %ebx
f0101412:	5e                   	pop    %esi
f0101413:	5f                   	pop    %edi
f0101414:	5d                   	pop    %ebp
f0101415:	c3                   	ret    

f0101416 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101416:	55                   	push   %ebp
f0101417:	89 e5                	mov    %esp,%ebp
f0101419:	56                   	push   %esi
f010141a:	53                   	push   %ebx
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
        size_t sz = ROUNDUP(size, PGSIZE); 
f010141b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010141e:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0101424:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        uintptr_t result = base;
f010142a:	8b 35 00 03 12 f0    	mov    0xf0120300,%esi

        if (base + sz > MMIOLIM)
f0101430:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f0101433:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f0101438:	76 17                	jbe    f0101451 <mmio_map_region+0x3b>
                panic("mmio_map_region: base + sz > MMIOLIM");
f010143a:	83 ec 04             	sub    $0x4,%esp
f010143d:	68 30 6c 10 f0       	push   $0xf0106c30
f0101442:	68 91 02 00 00       	push   $0x291
f0101447:	68 71 74 10 f0       	push   $0xf0107471
f010144c:	e8 ef eb ff ff       	call   f0100040 <_panic>

        boot_map_region(kern_pgdir, base, sz, pa, PTE_W | PTE_PCD | PTE_PWT);      
f0101451:	83 ec 08             	sub    $0x8,%esp
f0101454:	6a 1a                	push   $0x1a
f0101456:	ff 75 08             	pushl  0x8(%ebp)
f0101459:	89 d9                	mov    %ebx,%ecx
f010145b:	89 f2                	mov    %esi,%edx
f010145d:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0101462:	e8 28 fd ff ff       	call   f010118f <boot_map_region>
        base += sz;
f0101467:	01 1d 00 03 12 f0    	add    %ebx,0xf0120300
        
        return (void *) result;
}
f010146d:	89 f0                	mov    %esi,%eax
f010146f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101472:	5b                   	pop    %ebx
f0101473:	5e                   	pop    %esi
f0101474:	5d                   	pop    %ebp
f0101475:	c3                   	ret    

f0101476 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101476:	55                   	push   %ebp
f0101477:	89 e5                	mov    %esp,%ebp
f0101479:	57                   	push   %edi
f010147a:	56                   	push   %esi
f010147b:	53                   	push   %ebx
f010147c:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f010147f:	b8 15 00 00 00       	mov    $0x15,%eax
f0101484:	e8 14 f6 ff ff       	call   f0100a9d <nvram_read>
f0101489:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f010148b:	b8 17 00 00 00       	mov    $0x17,%eax
f0101490:	e8 08 f6 ff ff       	call   f0100a9d <nvram_read>
f0101495:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101497:	b8 34 00 00 00       	mov    $0x34,%eax
f010149c:	e8 fc f5 ff ff       	call   f0100a9d <nvram_read>
f01014a1:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f01014a4:	85 c0                	test   %eax,%eax
f01014a6:	74 07                	je     f01014af <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f01014a8:	05 00 40 00 00       	add    $0x4000,%eax
f01014ad:	eb 0b                	jmp    f01014ba <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f01014af:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01014b5:	85 f6                	test   %esi,%esi
f01014b7:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f01014ba:	89 c2                	mov    %eax,%edx
f01014bc:	c1 ea 02             	shr    $0x2,%edx
f01014bf:	89 15 88 1e 21 f0    	mov    %edx,0xf0211e88
	npages_basemem = basemem / (PGSIZE / 1024);
f01014c5:	89 da                	mov    %ebx,%edx
f01014c7:	c1 ea 02             	shr    $0x2,%edx
f01014ca:	89 15 44 12 21 f0    	mov    %edx,0xf0211244

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01014d0:	89 c2                	mov    %eax,%edx
f01014d2:	29 da                	sub    %ebx,%edx
f01014d4:	52                   	push   %edx
f01014d5:	53                   	push   %ebx
f01014d6:	50                   	push   %eax
f01014d7:	68 58 6c 10 f0       	push   $0xf0106c58
f01014dc:	e8 ac 23 00 00       	call   f010388d <cprintf>
	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01014e1:	b8 00 10 00 00       	mov    $0x1000,%eax
f01014e6:	e8 3f f6 ff ff       	call   f0100b2a <boot_alloc>
f01014eb:	a3 8c 1e 21 f0       	mov    %eax,0xf0211e8c
	memset(kern_pgdir, 0, PGSIZE);
f01014f0:	83 c4 0c             	add    $0xc,%esp
f01014f3:	68 00 10 00 00       	push   $0x1000
f01014f8:	6a 00                	push   $0x0
f01014fa:	50                   	push   %eax
f01014fb:	e8 b7 43 00 00       	call   f01058b7 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101500:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101505:	83 c4 10             	add    $0x10,%esp
f0101508:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010150d:	77 15                	ja     f0101524 <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010150f:	50                   	push   %eax
f0101510:	68 c8 65 10 f0       	push   $0xf01065c8
f0101515:	68 97 00 00 00       	push   $0x97
f010151a:	68 71 74 10 f0       	push   $0xf0107471
f010151f:	e8 1c eb ff ff       	call   f0100040 <_panic>
f0101524:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010152a:	83 ca 05             	or     $0x5,%edx
f010152d:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
        const size_t pages_size = sizeof(struct PageInfo) * npages;
f0101533:	a1 88 1e 21 f0       	mov    0xf0211e88,%eax
f0101538:	c1 e0 03             	shl    $0x3,%eax
f010153b:	89 c7                	mov    %eax,%edi
f010153d:	89 45 cc             	mov    %eax,-0x34(%ebp)
        pages = (struct PageInfo *) boot_alloc(pages_size);
f0101540:	e8 e5 f5 ff ff       	call   f0100b2a <boot_alloc>
f0101545:	a3 90 1e 21 f0       	mov    %eax,0xf0211e90
        memset(pages, 0, pages_size);
f010154a:	83 ec 04             	sub    $0x4,%esp
f010154d:	57                   	push   %edi
f010154e:	6a 00                	push   $0x0
f0101550:	50                   	push   %eax
f0101551:	e8 61 43 00 00       	call   f01058b7 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
        const size_t envs_size = sizeof(struct Env) * NENV;
        envs = (struct Env *) boot_alloc(envs_size);
f0101556:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010155b:	e8 ca f5 ff ff       	call   f0100b2a <boot_alloc>
f0101560:	a3 48 12 21 f0       	mov    %eax,0xf0211248
        memset(envs, 0, envs_size);
f0101565:	83 c4 0c             	add    $0xc,%esp
f0101568:	68 00 f0 01 00       	push   $0x1f000
f010156d:	6a 00                	push   $0x0
f010156f:	50                   	push   %eax
f0101570:	e8 42 43 00 00       	call   f01058b7 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101575:	e8 31 f9 ff ff       	call   f0100eab <page_init>

	check_page_free_list(1);
f010157a:	b8 01 00 00 00       	mov    $0x1,%eax
f010157f:	e8 25 f6 ff ff       	call   f0100ba9 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101584:	83 c4 10             	add    $0x10,%esp
f0101587:	83 3d 90 1e 21 f0 00 	cmpl   $0x0,0xf0211e90
f010158e:	75 17                	jne    f01015a7 <mem_init+0x131>
		panic("'pages' is a null pointer!");
f0101590:	83 ec 04             	sub    $0x4,%esp
f0101593:	68 7e 75 10 f0       	push   $0xf010757e
f0101598:	68 39 03 00 00       	push   $0x339
f010159d:	68 71 74 10 f0       	push   $0xf0107471
f01015a2:	e8 99 ea ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01015a7:	a1 40 12 21 f0       	mov    0xf0211240,%eax
f01015ac:	bb 00 00 00 00       	mov    $0x0,%ebx
f01015b1:	eb 05                	jmp    f01015b8 <mem_init+0x142>
		++nfree;
f01015b3:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01015b6:	8b 00                	mov    (%eax),%eax
f01015b8:	85 c0                	test   %eax,%eax
f01015ba:	75 f7                	jne    f01015b3 <mem_init+0x13d>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01015bc:	83 ec 0c             	sub    $0xc,%esp
f01015bf:	6a 00                	push   $0x0
f01015c1:	e8 db f9 ff ff       	call   f0100fa1 <page_alloc>
f01015c6:	89 c7                	mov    %eax,%edi
f01015c8:	83 c4 10             	add    $0x10,%esp
f01015cb:	85 c0                	test   %eax,%eax
f01015cd:	75 19                	jne    f01015e8 <mem_init+0x172>
f01015cf:	68 99 75 10 f0       	push   $0xf0107599
f01015d4:	68 97 74 10 f0       	push   $0xf0107497
f01015d9:	68 41 03 00 00       	push   $0x341
f01015de:	68 71 74 10 f0       	push   $0xf0107471
f01015e3:	e8 58 ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01015e8:	83 ec 0c             	sub    $0xc,%esp
f01015eb:	6a 00                	push   $0x0
f01015ed:	e8 af f9 ff ff       	call   f0100fa1 <page_alloc>
f01015f2:	89 c6                	mov    %eax,%esi
f01015f4:	83 c4 10             	add    $0x10,%esp
f01015f7:	85 c0                	test   %eax,%eax
f01015f9:	75 19                	jne    f0101614 <mem_init+0x19e>
f01015fb:	68 af 75 10 f0       	push   $0xf01075af
f0101600:	68 97 74 10 f0       	push   $0xf0107497
f0101605:	68 42 03 00 00       	push   $0x342
f010160a:	68 71 74 10 f0       	push   $0xf0107471
f010160f:	e8 2c ea ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101614:	83 ec 0c             	sub    $0xc,%esp
f0101617:	6a 00                	push   $0x0
f0101619:	e8 83 f9 ff ff       	call   f0100fa1 <page_alloc>
f010161e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101621:	83 c4 10             	add    $0x10,%esp
f0101624:	85 c0                	test   %eax,%eax
f0101626:	75 19                	jne    f0101641 <mem_init+0x1cb>
f0101628:	68 c5 75 10 f0       	push   $0xf01075c5
f010162d:	68 97 74 10 f0       	push   $0xf0107497
f0101632:	68 43 03 00 00       	push   $0x343
f0101637:	68 71 74 10 f0       	push   $0xf0107471
f010163c:	e8 ff e9 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101641:	39 f7                	cmp    %esi,%edi
f0101643:	75 19                	jne    f010165e <mem_init+0x1e8>
f0101645:	68 db 75 10 f0       	push   $0xf01075db
f010164a:	68 97 74 10 f0       	push   $0xf0107497
f010164f:	68 46 03 00 00       	push   $0x346
f0101654:	68 71 74 10 f0       	push   $0xf0107471
f0101659:	e8 e2 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010165e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101661:	39 c6                	cmp    %eax,%esi
f0101663:	74 04                	je     f0101669 <mem_init+0x1f3>
f0101665:	39 c7                	cmp    %eax,%edi
f0101667:	75 19                	jne    f0101682 <mem_init+0x20c>
f0101669:	68 94 6c 10 f0       	push   $0xf0106c94
f010166e:	68 97 74 10 f0       	push   $0xf0107497
f0101673:	68 47 03 00 00       	push   $0x347
f0101678:	68 71 74 10 f0       	push   $0xf0107471
f010167d:	e8 be e9 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101682:	8b 0d 90 1e 21 f0    	mov    0xf0211e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101688:	8b 15 88 1e 21 f0    	mov    0xf0211e88,%edx
f010168e:	c1 e2 0c             	shl    $0xc,%edx
f0101691:	89 f8                	mov    %edi,%eax
f0101693:	29 c8                	sub    %ecx,%eax
f0101695:	c1 f8 03             	sar    $0x3,%eax
f0101698:	c1 e0 0c             	shl    $0xc,%eax
f010169b:	39 d0                	cmp    %edx,%eax
f010169d:	72 19                	jb     f01016b8 <mem_init+0x242>
f010169f:	68 ed 75 10 f0       	push   $0xf01075ed
f01016a4:	68 97 74 10 f0       	push   $0xf0107497
f01016a9:	68 48 03 00 00       	push   $0x348
f01016ae:	68 71 74 10 f0       	push   $0xf0107471
f01016b3:	e8 88 e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01016b8:	89 f0                	mov    %esi,%eax
f01016ba:	29 c8                	sub    %ecx,%eax
f01016bc:	c1 f8 03             	sar    $0x3,%eax
f01016bf:	c1 e0 0c             	shl    $0xc,%eax
f01016c2:	39 c2                	cmp    %eax,%edx
f01016c4:	77 19                	ja     f01016df <mem_init+0x269>
f01016c6:	68 0a 76 10 f0       	push   $0xf010760a
f01016cb:	68 97 74 10 f0       	push   $0xf0107497
f01016d0:	68 49 03 00 00       	push   $0x349
f01016d5:	68 71 74 10 f0       	push   $0xf0107471
f01016da:	e8 61 e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01016df:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01016e2:	29 c8                	sub    %ecx,%eax
f01016e4:	c1 f8 03             	sar    $0x3,%eax
f01016e7:	c1 e0 0c             	shl    $0xc,%eax
f01016ea:	39 c2                	cmp    %eax,%edx
f01016ec:	77 19                	ja     f0101707 <mem_init+0x291>
f01016ee:	68 27 76 10 f0       	push   $0xf0107627
f01016f3:	68 97 74 10 f0       	push   $0xf0107497
f01016f8:	68 4a 03 00 00       	push   $0x34a
f01016fd:	68 71 74 10 f0       	push   $0xf0107471
f0101702:	e8 39 e9 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101707:	a1 40 12 21 f0       	mov    0xf0211240,%eax
f010170c:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010170f:	c7 05 40 12 21 f0 00 	movl   $0x0,0xf0211240
f0101716:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101719:	83 ec 0c             	sub    $0xc,%esp
f010171c:	6a 00                	push   $0x0
f010171e:	e8 7e f8 ff ff       	call   f0100fa1 <page_alloc>
f0101723:	83 c4 10             	add    $0x10,%esp
f0101726:	85 c0                	test   %eax,%eax
f0101728:	74 19                	je     f0101743 <mem_init+0x2cd>
f010172a:	68 44 76 10 f0       	push   $0xf0107644
f010172f:	68 97 74 10 f0       	push   $0xf0107497
f0101734:	68 51 03 00 00       	push   $0x351
f0101739:	68 71 74 10 f0       	push   $0xf0107471
f010173e:	e8 fd e8 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101743:	83 ec 0c             	sub    $0xc,%esp
f0101746:	57                   	push   %edi
f0101747:	e8 c5 f8 ff ff       	call   f0101011 <page_free>
	page_free(pp1);
f010174c:	89 34 24             	mov    %esi,(%esp)
f010174f:	e8 bd f8 ff ff       	call   f0101011 <page_free>
	page_free(pp2);
f0101754:	83 c4 04             	add    $0x4,%esp
f0101757:	ff 75 d4             	pushl  -0x2c(%ebp)
f010175a:	e8 b2 f8 ff ff       	call   f0101011 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010175f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101766:	e8 36 f8 ff ff       	call   f0100fa1 <page_alloc>
f010176b:	89 c6                	mov    %eax,%esi
f010176d:	83 c4 10             	add    $0x10,%esp
f0101770:	85 c0                	test   %eax,%eax
f0101772:	75 19                	jne    f010178d <mem_init+0x317>
f0101774:	68 99 75 10 f0       	push   $0xf0107599
f0101779:	68 97 74 10 f0       	push   $0xf0107497
f010177e:	68 58 03 00 00       	push   $0x358
f0101783:	68 71 74 10 f0       	push   $0xf0107471
f0101788:	e8 b3 e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010178d:	83 ec 0c             	sub    $0xc,%esp
f0101790:	6a 00                	push   $0x0
f0101792:	e8 0a f8 ff ff       	call   f0100fa1 <page_alloc>
f0101797:	89 c7                	mov    %eax,%edi
f0101799:	83 c4 10             	add    $0x10,%esp
f010179c:	85 c0                	test   %eax,%eax
f010179e:	75 19                	jne    f01017b9 <mem_init+0x343>
f01017a0:	68 af 75 10 f0       	push   $0xf01075af
f01017a5:	68 97 74 10 f0       	push   $0xf0107497
f01017aa:	68 59 03 00 00       	push   $0x359
f01017af:	68 71 74 10 f0       	push   $0xf0107471
f01017b4:	e8 87 e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01017b9:	83 ec 0c             	sub    $0xc,%esp
f01017bc:	6a 00                	push   $0x0
f01017be:	e8 de f7 ff ff       	call   f0100fa1 <page_alloc>
f01017c3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01017c6:	83 c4 10             	add    $0x10,%esp
f01017c9:	85 c0                	test   %eax,%eax
f01017cb:	75 19                	jne    f01017e6 <mem_init+0x370>
f01017cd:	68 c5 75 10 f0       	push   $0xf01075c5
f01017d2:	68 97 74 10 f0       	push   $0xf0107497
f01017d7:	68 5a 03 00 00       	push   $0x35a
f01017dc:	68 71 74 10 f0       	push   $0xf0107471
f01017e1:	e8 5a e8 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01017e6:	39 fe                	cmp    %edi,%esi
f01017e8:	75 19                	jne    f0101803 <mem_init+0x38d>
f01017ea:	68 db 75 10 f0       	push   $0xf01075db
f01017ef:	68 97 74 10 f0       	push   $0xf0107497
f01017f4:	68 5c 03 00 00       	push   $0x35c
f01017f9:	68 71 74 10 f0       	push   $0xf0107471
f01017fe:	e8 3d e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101803:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101806:	39 c7                	cmp    %eax,%edi
f0101808:	74 04                	je     f010180e <mem_init+0x398>
f010180a:	39 c6                	cmp    %eax,%esi
f010180c:	75 19                	jne    f0101827 <mem_init+0x3b1>
f010180e:	68 94 6c 10 f0       	push   $0xf0106c94
f0101813:	68 97 74 10 f0       	push   $0xf0107497
f0101818:	68 5d 03 00 00       	push   $0x35d
f010181d:	68 71 74 10 f0       	push   $0xf0107471
f0101822:	e8 19 e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101827:	83 ec 0c             	sub    $0xc,%esp
f010182a:	6a 00                	push   $0x0
f010182c:	e8 70 f7 ff ff       	call   f0100fa1 <page_alloc>
f0101831:	83 c4 10             	add    $0x10,%esp
f0101834:	85 c0                	test   %eax,%eax
f0101836:	74 19                	je     f0101851 <mem_init+0x3db>
f0101838:	68 44 76 10 f0       	push   $0xf0107644
f010183d:	68 97 74 10 f0       	push   $0xf0107497
f0101842:	68 5e 03 00 00       	push   $0x35e
f0101847:	68 71 74 10 f0       	push   $0xf0107471
f010184c:	e8 ef e7 ff ff       	call   f0100040 <_panic>
f0101851:	89 f0                	mov    %esi,%eax
f0101853:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0101859:	c1 f8 03             	sar    $0x3,%eax
f010185c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010185f:	89 c2                	mov    %eax,%edx
f0101861:	c1 ea 0c             	shr    $0xc,%edx
f0101864:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f010186a:	72 12                	jb     f010187e <mem_init+0x408>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010186c:	50                   	push   %eax
f010186d:	68 a4 65 10 f0       	push   $0xf01065a4
f0101872:	6a 58                	push   $0x58
f0101874:	68 7d 74 10 f0       	push   $0xf010747d
f0101879:	e8 c2 e7 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f010187e:	83 ec 04             	sub    $0x4,%esp
f0101881:	68 00 10 00 00       	push   $0x1000
f0101886:	6a 01                	push   $0x1
f0101888:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010188d:	50                   	push   %eax
f010188e:	e8 24 40 00 00       	call   f01058b7 <memset>
	page_free(pp0);
f0101893:	89 34 24             	mov    %esi,(%esp)
f0101896:	e8 76 f7 ff ff       	call   f0101011 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010189b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01018a2:	e8 fa f6 ff ff       	call   f0100fa1 <page_alloc>
f01018a7:	83 c4 10             	add    $0x10,%esp
f01018aa:	85 c0                	test   %eax,%eax
f01018ac:	75 19                	jne    f01018c7 <mem_init+0x451>
f01018ae:	68 53 76 10 f0       	push   $0xf0107653
f01018b3:	68 97 74 10 f0       	push   $0xf0107497
f01018b8:	68 63 03 00 00       	push   $0x363
f01018bd:	68 71 74 10 f0       	push   $0xf0107471
f01018c2:	e8 79 e7 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01018c7:	39 c6                	cmp    %eax,%esi
f01018c9:	74 19                	je     f01018e4 <mem_init+0x46e>
f01018cb:	68 71 76 10 f0       	push   $0xf0107671
f01018d0:	68 97 74 10 f0       	push   $0xf0107497
f01018d5:	68 64 03 00 00       	push   $0x364
f01018da:	68 71 74 10 f0       	push   $0xf0107471
f01018df:	e8 5c e7 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018e4:	89 f0                	mov    %esi,%eax
f01018e6:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f01018ec:	c1 f8 03             	sar    $0x3,%eax
f01018ef:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01018f2:	89 c2                	mov    %eax,%edx
f01018f4:	c1 ea 0c             	shr    $0xc,%edx
f01018f7:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f01018fd:	72 12                	jb     f0101911 <mem_init+0x49b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018ff:	50                   	push   %eax
f0101900:	68 a4 65 10 f0       	push   $0xf01065a4
f0101905:	6a 58                	push   $0x58
f0101907:	68 7d 74 10 f0       	push   $0xf010747d
f010190c:	e8 2f e7 ff ff       	call   f0100040 <_panic>
f0101911:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101917:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f010191d:	80 38 00             	cmpb   $0x0,(%eax)
f0101920:	74 19                	je     f010193b <mem_init+0x4c5>
f0101922:	68 81 76 10 f0       	push   $0xf0107681
f0101927:	68 97 74 10 f0       	push   $0xf0107497
f010192c:	68 67 03 00 00       	push   $0x367
f0101931:	68 71 74 10 f0       	push   $0xf0107471
f0101936:	e8 05 e7 ff ff       	call   f0100040 <_panic>
f010193b:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f010193e:	39 d0                	cmp    %edx,%eax
f0101940:	75 db                	jne    f010191d <mem_init+0x4a7>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101942:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101945:	a3 40 12 21 f0       	mov    %eax,0xf0211240

	// free the pages we took
	page_free(pp0);
f010194a:	83 ec 0c             	sub    $0xc,%esp
f010194d:	56                   	push   %esi
f010194e:	e8 be f6 ff ff       	call   f0101011 <page_free>
	page_free(pp1);
f0101953:	89 3c 24             	mov    %edi,(%esp)
f0101956:	e8 b6 f6 ff ff       	call   f0101011 <page_free>
	page_free(pp2);
f010195b:	83 c4 04             	add    $0x4,%esp
f010195e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101961:	e8 ab f6 ff ff       	call   f0101011 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101966:	a1 40 12 21 f0       	mov    0xf0211240,%eax
f010196b:	83 c4 10             	add    $0x10,%esp
f010196e:	eb 05                	jmp    f0101975 <mem_init+0x4ff>
		--nfree;
f0101970:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101973:	8b 00                	mov    (%eax),%eax
f0101975:	85 c0                	test   %eax,%eax
f0101977:	75 f7                	jne    f0101970 <mem_init+0x4fa>
		--nfree;
	assert(nfree == 0);
f0101979:	85 db                	test   %ebx,%ebx
f010197b:	74 19                	je     f0101996 <mem_init+0x520>
f010197d:	68 8b 76 10 f0       	push   $0xf010768b
f0101982:	68 97 74 10 f0       	push   $0xf0107497
f0101987:	68 74 03 00 00       	push   $0x374
f010198c:	68 71 74 10 f0       	push   $0xf0107471
f0101991:	e8 aa e6 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101996:	83 ec 0c             	sub    $0xc,%esp
f0101999:	68 b4 6c 10 f0       	push   $0xf0106cb4
f010199e:	e8 ea 1e 00 00       	call   f010388d <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01019a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019aa:	e8 f2 f5 ff ff       	call   f0100fa1 <page_alloc>
f01019af:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01019b2:	83 c4 10             	add    $0x10,%esp
f01019b5:	85 c0                	test   %eax,%eax
f01019b7:	75 19                	jne    f01019d2 <mem_init+0x55c>
f01019b9:	68 99 75 10 f0       	push   $0xf0107599
f01019be:	68 97 74 10 f0       	push   $0xf0107497
f01019c3:	68 da 03 00 00       	push   $0x3da
f01019c8:	68 71 74 10 f0       	push   $0xf0107471
f01019cd:	e8 6e e6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01019d2:	83 ec 0c             	sub    $0xc,%esp
f01019d5:	6a 00                	push   $0x0
f01019d7:	e8 c5 f5 ff ff       	call   f0100fa1 <page_alloc>
f01019dc:	89 c3                	mov    %eax,%ebx
f01019de:	83 c4 10             	add    $0x10,%esp
f01019e1:	85 c0                	test   %eax,%eax
f01019e3:	75 19                	jne    f01019fe <mem_init+0x588>
f01019e5:	68 af 75 10 f0       	push   $0xf01075af
f01019ea:	68 97 74 10 f0       	push   $0xf0107497
f01019ef:	68 db 03 00 00       	push   $0x3db
f01019f4:	68 71 74 10 f0       	push   $0xf0107471
f01019f9:	e8 42 e6 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01019fe:	83 ec 0c             	sub    $0xc,%esp
f0101a01:	6a 00                	push   $0x0
f0101a03:	e8 99 f5 ff ff       	call   f0100fa1 <page_alloc>
f0101a08:	89 c6                	mov    %eax,%esi
f0101a0a:	83 c4 10             	add    $0x10,%esp
f0101a0d:	85 c0                	test   %eax,%eax
f0101a0f:	75 19                	jne    f0101a2a <mem_init+0x5b4>
f0101a11:	68 c5 75 10 f0       	push   $0xf01075c5
f0101a16:	68 97 74 10 f0       	push   $0xf0107497
f0101a1b:	68 dc 03 00 00       	push   $0x3dc
f0101a20:	68 71 74 10 f0       	push   $0xf0107471
f0101a25:	e8 16 e6 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a2a:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101a2d:	75 19                	jne    f0101a48 <mem_init+0x5d2>
f0101a2f:	68 db 75 10 f0       	push   $0xf01075db
f0101a34:	68 97 74 10 f0       	push   $0xf0107497
f0101a39:	68 df 03 00 00       	push   $0x3df
f0101a3e:	68 71 74 10 f0       	push   $0xf0107471
f0101a43:	e8 f8 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a48:	39 c3                	cmp    %eax,%ebx
f0101a4a:	74 05                	je     f0101a51 <mem_init+0x5db>
f0101a4c:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101a4f:	75 19                	jne    f0101a6a <mem_init+0x5f4>
f0101a51:	68 94 6c 10 f0       	push   $0xf0106c94
f0101a56:	68 97 74 10 f0       	push   $0xf0107497
f0101a5b:	68 e0 03 00 00       	push   $0x3e0
f0101a60:	68 71 74 10 f0       	push   $0xf0107471
f0101a65:	e8 d6 e5 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101a6a:	a1 40 12 21 f0       	mov    0xf0211240,%eax
f0101a6f:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101a72:	c7 05 40 12 21 f0 00 	movl   $0x0,0xf0211240
f0101a79:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101a7c:	83 ec 0c             	sub    $0xc,%esp
f0101a7f:	6a 00                	push   $0x0
f0101a81:	e8 1b f5 ff ff       	call   f0100fa1 <page_alloc>
f0101a86:	83 c4 10             	add    $0x10,%esp
f0101a89:	85 c0                	test   %eax,%eax
f0101a8b:	74 19                	je     f0101aa6 <mem_init+0x630>
f0101a8d:	68 44 76 10 f0       	push   $0xf0107644
f0101a92:	68 97 74 10 f0       	push   $0xf0107497
f0101a97:	68 e7 03 00 00       	push   $0x3e7
f0101a9c:	68 71 74 10 f0       	push   $0xf0107471
f0101aa1:	e8 9a e5 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101aa6:	83 ec 04             	sub    $0x4,%esp
f0101aa9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101aac:	50                   	push   %eax
f0101aad:	6a 00                	push   $0x0
f0101aaf:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101ab5:	e8 6b f7 ff ff       	call   f0101225 <page_lookup>
f0101aba:	83 c4 10             	add    $0x10,%esp
f0101abd:	85 c0                	test   %eax,%eax
f0101abf:	74 19                	je     f0101ada <mem_init+0x664>
f0101ac1:	68 d4 6c 10 f0       	push   $0xf0106cd4
f0101ac6:	68 97 74 10 f0       	push   $0xf0107497
f0101acb:	68 ea 03 00 00       	push   $0x3ea
f0101ad0:	68 71 74 10 f0       	push   $0xf0107471
f0101ad5:	e8 66 e5 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101ada:	6a 02                	push   $0x2
f0101adc:	6a 00                	push   $0x0
f0101ade:	53                   	push   %ebx
f0101adf:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101ae5:	e8 65 f8 ff ff       	call   f010134f <page_insert>
f0101aea:	83 c4 10             	add    $0x10,%esp
f0101aed:	85 c0                	test   %eax,%eax
f0101aef:	78 19                	js     f0101b0a <mem_init+0x694>
f0101af1:	68 0c 6d 10 f0       	push   $0xf0106d0c
f0101af6:	68 97 74 10 f0       	push   $0xf0107497
f0101afb:	68 ed 03 00 00       	push   $0x3ed
f0101b00:	68 71 74 10 f0       	push   $0xf0107471
f0101b05:	e8 36 e5 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101b0a:	83 ec 0c             	sub    $0xc,%esp
f0101b0d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b10:	e8 fc f4 ff ff       	call   f0101011 <page_free>

	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101b15:	6a 02                	push   $0x2
f0101b17:	6a 00                	push   $0x0
f0101b19:	53                   	push   %ebx
f0101b1a:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101b20:	e8 2a f8 ff ff       	call   f010134f <page_insert>
f0101b25:	83 c4 20             	add    $0x20,%esp
f0101b28:	85 c0                	test   %eax,%eax
f0101b2a:	74 19                	je     f0101b45 <mem_init+0x6cf>
f0101b2c:	68 3c 6d 10 f0       	push   $0xf0106d3c
f0101b31:	68 97 74 10 f0       	push   $0xf0107497
f0101b36:	68 f2 03 00 00       	push   $0x3f2
f0101b3b:	68 71 74 10 f0       	push   $0xf0107471
f0101b40:	e8 fb e4 ff ff       	call   f0100040 <_panic>
        assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b45:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b4b:	a1 90 1e 21 f0       	mov    0xf0211e90,%eax
f0101b50:	89 c1                	mov    %eax,%ecx
f0101b52:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0101b55:	8b 17                	mov    (%edi),%edx
f0101b57:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101b5d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b60:	29 c8                	sub    %ecx,%eax
f0101b62:	c1 f8 03             	sar    $0x3,%eax
f0101b65:	c1 e0 0c             	shl    $0xc,%eax
f0101b68:	39 c2                	cmp    %eax,%edx
f0101b6a:	74 19                	je     f0101b85 <mem_init+0x70f>
f0101b6c:	68 6c 6d 10 f0       	push   $0xf0106d6c
f0101b71:	68 97 74 10 f0       	push   $0xf0107497
f0101b76:	68 f3 03 00 00       	push   $0x3f3
f0101b7b:	68 71 74 10 f0       	push   $0xf0107471
f0101b80:	e8 bb e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101b85:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b8a:	89 f8                	mov    %edi,%eax
f0101b8c:	e8 35 ef ff ff       	call   f0100ac6 <check_va2pa>
f0101b91:	89 da                	mov    %ebx,%edx
f0101b93:	2b 55 c8             	sub    -0x38(%ebp),%edx
f0101b96:	c1 fa 03             	sar    $0x3,%edx
f0101b99:	c1 e2 0c             	shl    $0xc,%edx
f0101b9c:	39 d0                	cmp    %edx,%eax
f0101b9e:	74 19                	je     f0101bb9 <mem_init+0x743>
f0101ba0:	68 94 6d 10 f0       	push   $0xf0106d94
f0101ba5:	68 97 74 10 f0       	push   $0xf0107497
f0101baa:	68 f4 03 00 00       	push   $0x3f4
f0101baf:	68 71 74 10 f0       	push   $0xf0107471
f0101bb4:	e8 87 e4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101bb9:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101bbe:	74 19                	je     f0101bd9 <mem_init+0x763>
f0101bc0:	68 96 76 10 f0       	push   $0xf0107696
f0101bc5:	68 97 74 10 f0       	push   $0xf0107497
f0101bca:	68 f5 03 00 00       	push   $0x3f5
f0101bcf:	68 71 74 10 f0       	push   $0xf0107471
f0101bd4:	e8 67 e4 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101bd9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101bdc:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101be1:	74 19                	je     f0101bfc <mem_init+0x786>
f0101be3:	68 a7 76 10 f0       	push   $0xf01076a7
f0101be8:	68 97 74 10 f0       	push   $0xf0107497
f0101bed:	68 f6 03 00 00       	push   $0x3f6
f0101bf2:	68 71 74 10 f0       	push   $0xf0107471
f0101bf7:	e8 44 e4 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101bfc:	6a 02                	push   $0x2
f0101bfe:	68 00 10 00 00       	push   $0x1000
f0101c03:	56                   	push   %esi
f0101c04:	57                   	push   %edi
f0101c05:	e8 45 f7 ff ff       	call   f010134f <page_insert>
f0101c0a:	83 c4 10             	add    $0x10,%esp
f0101c0d:	85 c0                	test   %eax,%eax
f0101c0f:	74 19                	je     f0101c2a <mem_init+0x7b4>
f0101c11:	68 c4 6d 10 f0       	push   $0xf0106dc4
f0101c16:	68 97 74 10 f0       	push   $0xf0107497
f0101c1b:	68 f9 03 00 00       	push   $0x3f9
f0101c20:	68 71 74 10 f0       	push   $0xf0107471
f0101c25:	e8 16 e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c2a:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c2f:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0101c34:	e8 8d ee ff ff       	call   f0100ac6 <check_va2pa>
f0101c39:	89 f2                	mov    %esi,%edx
f0101c3b:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0101c41:	c1 fa 03             	sar    $0x3,%edx
f0101c44:	c1 e2 0c             	shl    $0xc,%edx
f0101c47:	39 d0                	cmp    %edx,%eax
f0101c49:	74 19                	je     f0101c64 <mem_init+0x7ee>
f0101c4b:	68 00 6e 10 f0       	push   $0xf0106e00
f0101c50:	68 97 74 10 f0       	push   $0xf0107497
f0101c55:	68 fa 03 00 00       	push   $0x3fa
f0101c5a:	68 71 74 10 f0       	push   $0xf0107471
f0101c5f:	e8 dc e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101c64:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c69:	74 19                	je     f0101c84 <mem_init+0x80e>
f0101c6b:	68 b8 76 10 f0       	push   $0xf01076b8
f0101c70:	68 97 74 10 f0       	push   $0xf0107497
f0101c75:	68 fb 03 00 00       	push   $0x3fb
f0101c7a:	68 71 74 10 f0       	push   $0xf0107471
f0101c7f:	e8 bc e3 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101c84:	83 ec 0c             	sub    $0xc,%esp
f0101c87:	6a 00                	push   $0x0
f0101c89:	e8 13 f3 ff ff       	call   f0100fa1 <page_alloc>
f0101c8e:	83 c4 10             	add    $0x10,%esp
f0101c91:	85 c0                	test   %eax,%eax
f0101c93:	74 19                	je     f0101cae <mem_init+0x838>
f0101c95:	68 44 76 10 f0       	push   $0xf0107644
f0101c9a:	68 97 74 10 f0       	push   $0xf0107497
f0101c9f:	68 fe 03 00 00       	push   $0x3fe
f0101ca4:	68 71 74 10 f0       	push   $0xf0107471
f0101ca9:	e8 92 e3 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101cae:	6a 02                	push   $0x2
f0101cb0:	68 00 10 00 00       	push   $0x1000
f0101cb5:	56                   	push   %esi
f0101cb6:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101cbc:	e8 8e f6 ff ff       	call   f010134f <page_insert>
f0101cc1:	83 c4 10             	add    $0x10,%esp
f0101cc4:	85 c0                	test   %eax,%eax
f0101cc6:	74 19                	je     f0101ce1 <mem_init+0x86b>
f0101cc8:	68 c4 6d 10 f0       	push   $0xf0106dc4
f0101ccd:	68 97 74 10 f0       	push   $0xf0107497
f0101cd2:	68 01 04 00 00       	push   $0x401
f0101cd7:	68 71 74 10 f0       	push   $0xf0107471
f0101cdc:	e8 5f e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ce1:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ce6:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0101ceb:	e8 d6 ed ff ff       	call   f0100ac6 <check_va2pa>
f0101cf0:	89 f2                	mov    %esi,%edx
f0101cf2:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0101cf8:	c1 fa 03             	sar    $0x3,%edx
f0101cfb:	c1 e2 0c             	shl    $0xc,%edx
f0101cfe:	39 d0                	cmp    %edx,%eax
f0101d00:	74 19                	je     f0101d1b <mem_init+0x8a5>
f0101d02:	68 00 6e 10 f0       	push   $0xf0106e00
f0101d07:	68 97 74 10 f0       	push   $0xf0107497
f0101d0c:	68 02 04 00 00       	push   $0x402
f0101d11:	68 71 74 10 f0       	push   $0xf0107471
f0101d16:	e8 25 e3 ff ff       	call   f0100040 <_panic>
        assert(pp2->pp_ref == 1);
f0101d1b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d20:	74 19                	je     f0101d3b <mem_init+0x8c5>
f0101d22:	68 b8 76 10 f0       	push   $0xf01076b8
f0101d27:	68 97 74 10 f0       	push   $0xf0107497
f0101d2c:	68 03 04 00 00       	push   $0x403
f0101d31:	68 71 74 10 f0       	push   $0xf0107471
f0101d36:	e8 05 e3 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101d3b:	83 ec 0c             	sub    $0xc,%esp
f0101d3e:	6a 00                	push   $0x0
f0101d40:	e8 5c f2 ff ff       	call   f0100fa1 <page_alloc>
f0101d45:	83 c4 10             	add    $0x10,%esp
f0101d48:	85 c0                	test   %eax,%eax
f0101d4a:	74 19                	je     f0101d65 <mem_init+0x8ef>
f0101d4c:	68 44 76 10 f0       	push   $0xf0107644
f0101d51:	68 97 74 10 f0       	push   $0xf0107497
f0101d56:	68 07 04 00 00       	push   $0x407
f0101d5b:	68 71 74 10 f0       	push   $0xf0107471
f0101d60:	e8 db e2 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101d65:	8b 15 8c 1e 21 f0    	mov    0xf0211e8c,%edx
f0101d6b:	8b 02                	mov    (%edx),%eax
f0101d6d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101d72:	89 c1                	mov    %eax,%ecx
f0101d74:	c1 e9 0c             	shr    $0xc,%ecx
f0101d77:	3b 0d 88 1e 21 f0    	cmp    0xf0211e88,%ecx
f0101d7d:	72 15                	jb     f0101d94 <mem_init+0x91e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101d7f:	50                   	push   %eax
f0101d80:	68 a4 65 10 f0       	push   $0xf01065a4
f0101d85:	68 0a 04 00 00       	push   $0x40a
f0101d8a:	68 71 74 10 f0       	push   $0xf0107471
f0101d8f:	e8 ac e2 ff ff       	call   f0100040 <_panic>
f0101d94:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101d99:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101d9c:	83 ec 04             	sub    $0x4,%esp
f0101d9f:	6a 00                	push   $0x0
f0101da1:	68 00 10 00 00       	push   $0x1000
f0101da6:	52                   	push   %edx
f0101da7:	e8 fb f2 ff ff       	call   f01010a7 <pgdir_walk>
f0101dac:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101daf:	8d 51 04             	lea    0x4(%ecx),%edx
f0101db2:	83 c4 10             	add    $0x10,%esp
f0101db5:	39 d0                	cmp    %edx,%eax
f0101db7:	74 19                	je     f0101dd2 <mem_init+0x95c>
f0101db9:	68 30 6e 10 f0       	push   $0xf0106e30
f0101dbe:	68 97 74 10 f0       	push   $0xf0107497
f0101dc3:	68 0b 04 00 00       	push   $0x40b
f0101dc8:	68 71 74 10 f0       	push   $0xf0107471
f0101dcd:	e8 6e e2 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101dd2:	6a 06                	push   $0x6
f0101dd4:	68 00 10 00 00       	push   $0x1000
f0101dd9:	56                   	push   %esi
f0101dda:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101de0:	e8 6a f5 ff ff       	call   f010134f <page_insert>
f0101de5:	83 c4 10             	add    $0x10,%esp
f0101de8:	85 c0                	test   %eax,%eax
f0101dea:	74 19                	je     f0101e05 <mem_init+0x98f>
f0101dec:	68 70 6e 10 f0       	push   $0xf0106e70
f0101df1:	68 97 74 10 f0       	push   $0xf0107497
f0101df6:	68 0e 04 00 00       	push   $0x40e
f0101dfb:	68 71 74 10 f0       	push   $0xf0107471
f0101e00:	e8 3b e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e05:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
f0101e0b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e10:	89 f8                	mov    %edi,%eax
f0101e12:	e8 af ec ff ff       	call   f0100ac6 <check_va2pa>
f0101e17:	89 f2                	mov    %esi,%edx
f0101e19:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0101e1f:	c1 fa 03             	sar    $0x3,%edx
f0101e22:	c1 e2 0c             	shl    $0xc,%edx
f0101e25:	39 d0                	cmp    %edx,%eax
f0101e27:	74 19                	je     f0101e42 <mem_init+0x9cc>
f0101e29:	68 00 6e 10 f0       	push   $0xf0106e00
f0101e2e:	68 97 74 10 f0       	push   $0xf0107497
f0101e33:	68 0f 04 00 00       	push   $0x40f
f0101e38:	68 71 74 10 f0       	push   $0xf0107471
f0101e3d:	e8 fe e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101e42:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101e47:	74 19                	je     f0101e62 <mem_init+0x9ec>
f0101e49:	68 b8 76 10 f0       	push   $0xf01076b8
f0101e4e:	68 97 74 10 f0       	push   $0xf0107497
f0101e53:	68 10 04 00 00       	push   $0x410
f0101e58:	68 71 74 10 f0       	push   $0xf0107471
f0101e5d:	e8 de e1 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101e62:	83 ec 04             	sub    $0x4,%esp
f0101e65:	6a 00                	push   $0x0
f0101e67:	68 00 10 00 00       	push   $0x1000
f0101e6c:	57                   	push   %edi
f0101e6d:	e8 35 f2 ff ff       	call   f01010a7 <pgdir_walk>
f0101e72:	83 c4 10             	add    $0x10,%esp
f0101e75:	f6 00 04             	testb  $0x4,(%eax)
f0101e78:	75 19                	jne    f0101e93 <mem_init+0xa1d>
f0101e7a:	68 b0 6e 10 f0       	push   $0xf0106eb0
f0101e7f:	68 97 74 10 f0       	push   $0xf0107497
f0101e84:	68 11 04 00 00       	push   $0x411
f0101e89:	68 71 74 10 f0       	push   $0xf0107471
f0101e8e:	e8 ad e1 ff ff       	call   f0100040 <_panic>
        assert(kern_pgdir[0] & PTE_U);
f0101e93:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0101e98:	f6 00 04             	testb  $0x4,(%eax)
f0101e9b:	75 19                	jne    f0101eb6 <mem_init+0xa40>
f0101e9d:	68 c9 76 10 f0       	push   $0xf01076c9
f0101ea2:	68 97 74 10 f0       	push   $0xf0107497
f0101ea7:	68 12 04 00 00       	push   $0x412
f0101eac:	68 71 74 10 f0       	push   $0xf0107471
f0101eb1:	e8 8a e1 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101eb6:	6a 02                	push   $0x2
f0101eb8:	68 00 10 00 00       	push   $0x1000
f0101ebd:	56                   	push   %esi
f0101ebe:	50                   	push   %eax
f0101ebf:	e8 8b f4 ff ff       	call   f010134f <page_insert>
f0101ec4:	83 c4 10             	add    $0x10,%esp
f0101ec7:	85 c0                	test   %eax,%eax
f0101ec9:	74 19                	je     f0101ee4 <mem_init+0xa6e>
f0101ecb:	68 c4 6d 10 f0       	push   $0xf0106dc4
f0101ed0:	68 97 74 10 f0       	push   $0xf0107497
f0101ed5:	68 15 04 00 00       	push   $0x415
f0101eda:	68 71 74 10 f0       	push   $0xf0107471
f0101edf:	e8 5c e1 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101ee4:	83 ec 04             	sub    $0x4,%esp
f0101ee7:	6a 00                	push   $0x0
f0101ee9:	68 00 10 00 00       	push   $0x1000
f0101eee:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101ef4:	e8 ae f1 ff ff       	call   f01010a7 <pgdir_walk>
f0101ef9:	83 c4 10             	add    $0x10,%esp
f0101efc:	f6 00 02             	testb  $0x2,(%eax)
f0101eff:	75 19                	jne    f0101f1a <mem_init+0xaa4>
f0101f01:	68 e4 6e 10 f0       	push   $0xf0106ee4
f0101f06:	68 97 74 10 f0       	push   $0xf0107497
f0101f0b:	68 16 04 00 00       	push   $0x416
f0101f10:	68 71 74 10 f0       	push   $0xf0107471
f0101f15:	e8 26 e1 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f1a:	83 ec 04             	sub    $0x4,%esp
f0101f1d:	6a 00                	push   $0x0
f0101f1f:	68 00 10 00 00       	push   $0x1000
f0101f24:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101f2a:	e8 78 f1 ff ff       	call   f01010a7 <pgdir_walk>
f0101f2f:	83 c4 10             	add    $0x10,%esp
f0101f32:	f6 00 04             	testb  $0x4,(%eax)
f0101f35:	74 19                	je     f0101f50 <mem_init+0xada>
f0101f37:	68 18 6f 10 f0       	push   $0xf0106f18
f0101f3c:	68 97 74 10 f0       	push   $0xf0107497
f0101f41:	68 17 04 00 00       	push   $0x417
f0101f46:	68 71 74 10 f0       	push   $0xf0107471
f0101f4b:	e8 f0 e0 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101f50:	6a 02                	push   $0x2
f0101f52:	68 00 00 40 00       	push   $0x400000
f0101f57:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101f5a:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101f60:	e8 ea f3 ff ff       	call   f010134f <page_insert>
f0101f65:	83 c4 10             	add    $0x10,%esp
f0101f68:	85 c0                	test   %eax,%eax
f0101f6a:	78 19                	js     f0101f85 <mem_init+0xb0f>
f0101f6c:	68 50 6f 10 f0       	push   $0xf0106f50
f0101f71:	68 97 74 10 f0       	push   $0xf0107497
f0101f76:	68 1a 04 00 00       	push   $0x41a
f0101f7b:	68 71 74 10 f0       	push   $0xf0107471
f0101f80:	e8 bb e0 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101f85:	6a 02                	push   $0x2
f0101f87:	68 00 10 00 00       	push   $0x1000
f0101f8c:	53                   	push   %ebx
f0101f8d:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101f93:	e8 b7 f3 ff ff       	call   f010134f <page_insert>
f0101f98:	83 c4 10             	add    $0x10,%esp
f0101f9b:	85 c0                	test   %eax,%eax
f0101f9d:	74 19                	je     f0101fb8 <mem_init+0xb42>
f0101f9f:	68 88 6f 10 f0       	push   $0xf0106f88
f0101fa4:	68 97 74 10 f0       	push   $0xf0107497
f0101fa9:	68 1d 04 00 00       	push   $0x41d
f0101fae:	68 71 74 10 f0       	push   $0xf0107471
f0101fb3:	e8 88 e0 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101fb8:	83 ec 04             	sub    $0x4,%esp
f0101fbb:	6a 00                	push   $0x0
f0101fbd:	68 00 10 00 00       	push   $0x1000
f0101fc2:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101fc8:	e8 da f0 ff ff       	call   f01010a7 <pgdir_walk>
f0101fcd:	83 c4 10             	add    $0x10,%esp
f0101fd0:	f6 00 04             	testb  $0x4,(%eax)
f0101fd3:	74 19                	je     f0101fee <mem_init+0xb78>
f0101fd5:	68 18 6f 10 f0       	push   $0xf0106f18
f0101fda:	68 97 74 10 f0       	push   $0xf0107497
f0101fdf:	68 1e 04 00 00       	push   $0x41e
f0101fe4:	68 71 74 10 f0       	push   $0xf0107471
f0101fe9:	e8 52 e0 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101fee:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
f0101ff4:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ff9:	89 f8                	mov    %edi,%eax
f0101ffb:	e8 c6 ea ff ff       	call   f0100ac6 <check_va2pa>
f0102000:	89 c1                	mov    %eax,%ecx
f0102002:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102005:	89 d8                	mov    %ebx,%eax
f0102007:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f010200d:	c1 f8 03             	sar    $0x3,%eax
f0102010:	c1 e0 0c             	shl    $0xc,%eax
f0102013:	39 c1                	cmp    %eax,%ecx
f0102015:	74 19                	je     f0102030 <mem_init+0xbba>
f0102017:	68 c4 6f 10 f0       	push   $0xf0106fc4
f010201c:	68 97 74 10 f0       	push   $0xf0107497
f0102021:	68 21 04 00 00       	push   $0x421
f0102026:	68 71 74 10 f0       	push   $0xf0107471
f010202b:	e8 10 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102030:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102035:	89 f8                	mov    %edi,%eax
f0102037:	e8 8a ea ff ff       	call   f0100ac6 <check_va2pa>
f010203c:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f010203f:	74 19                	je     f010205a <mem_init+0xbe4>
f0102041:	68 f0 6f 10 f0       	push   $0xf0106ff0
f0102046:	68 97 74 10 f0       	push   $0xf0107497
f010204b:	68 22 04 00 00       	push   $0x422
f0102050:	68 71 74 10 f0       	push   $0xf0107471
f0102055:	e8 e6 df ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010205a:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f010205f:	74 19                	je     f010207a <mem_init+0xc04>
f0102061:	68 df 76 10 f0       	push   $0xf01076df
f0102066:	68 97 74 10 f0       	push   $0xf0107497
f010206b:	68 24 04 00 00       	push   $0x424
f0102070:	68 71 74 10 f0       	push   $0xf0107471
f0102075:	e8 c6 df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010207a:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010207f:	74 19                	je     f010209a <mem_init+0xc24>
f0102081:	68 f0 76 10 f0       	push   $0xf01076f0
f0102086:	68 97 74 10 f0       	push   $0xf0107497
f010208b:	68 25 04 00 00       	push   $0x425
f0102090:	68 71 74 10 f0       	push   $0xf0107471
f0102095:	e8 a6 df ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f010209a:	83 ec 0c             	sub    $0xc,%esp
f010209d:	6a 00                	push   $0x0
f010209f:	e8 fd ee ff ff       	call   f0100fa1 <page_alloc>
f01020a4:	83 c4 10             	add    $0x10,%esp
f01020a7:	85 c0                	test   %eax,%eax
f01020a9:	74 04                	je     f01020af <mem_init+0xc39>
f01020ab:	39 c6                	cmp    %eax,%esi
f01020ad:	74 19                	je     f01020c8 <mem_init+0xc52>
f01020af:	68 20 70 10 f0       	push   $0xf0107020
f01020b4:	68 97 74 10 f0       	push   $0xf0107497
f01020b9:	68 28 04 00 00       	push   $0x428
f01020be:	68 71 74 10 f0       	push   $0xf0107471
f01020c3:	e8 78 df ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01020c8:	83 ec 08             	sub    $0x8,%esp
f01020cb:	6a 00                	push   $0x0
f01020cd:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f01020d3:	e8 09 f2 ff ff       	call   f01012e1 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01020d8:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
f01020de:	ba 00 00 00 00       	mov    $0x0,%edx
f01020e3:	89 f8                	mov    %edi,%eax
f01020e5:	e8 dc e9 ff ff       	call   f0100ac6 <check_va2pa>
f01020ea:	83 c4 10             	add    $0x10,%esp
f01020ed:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020f0:	74 19                	je     f010210b <mem_init+0xc95>
f01020f2:	68 44 70 10 f0       	push   $0xf0107044
f01020f7:	68 97 74 10 f0       	push   $0xf0107497
f01020fc:	68 2c 04 00 00       	push   $0x42c
f0102101:	68 71 74 10 f0       	push   $0xf0107471
f0102106:	e8 35 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010210b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102110:	89 f8                	mov    %edi,%eax
f0102112:	e8 af e9 ff ff       	call   f0100ac6 <check_va2pa>
f0102117:	89 da                	mov    %ebx,%edx
f0102119:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f010211f:	c1 fa 03             	sar    $0x3,%edx
f0102122:	c1 e2 0c             	shl    $0xc,%edx
f0102125:	39 d0                	cmp    %edx,%eax
f0102127:	74 19                	je     f0102142 <mem_init+0xccc>
f0102129:	68 f0 6f 10 f0       	push   $0xf0106ff0
f010212e:	68 97 74 10 f0       	push   $0xf0107497
f0102133:	68 2d 04 00 00       	push   $0x42d
f0102138:	68 71 74 10 f0       	push   $0xf0107471
f010213d:	e8 fe de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102142:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102147:	74 19                	je     f0102162 <mem_init+0xcec>
f0102149:	68 96 76 10 f0       	push   $0xf0107696
f010214e:	68 97 74 10 f0       	push   $0xf0107497
f0102153:	68 2e 04 00 00       	push   $0x42e
f0102158:	68 71 74 10 f0       	push   $0xf0107471
f010215d:	e8 de de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102162:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102167:	74 19                	je     f0102182 <mem_init+0xd0c>
f0102169:	68 f0 76 10 f0       	push   $0xf01076f0
f010216e:	68 97 74 10 f0       	push   $0xf0107497
f0102173:	68 2f 04 00 00       	push   $0x42f
f0102178:	68 71 74 10 f0       	push   $0xf0107471
f010217d:	e8 be de ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102182:	6a 00                	push   $0x0
f0102184:	68 00 10 00 00       	push   $0x1000
f0102189:	53                   	push   %ebx
f010218a:	57                   	push   %edi
f010218b:	e8 bf f1 ff ff       	call   f010134f <page_insert>
f0102190:	83 c4 10             	add    $0x10,%esp
f0102193:	85 c0                	test   %eax,%eax
f0102195:	74 19                	je     f01021b0 <mem_init+0xd3a>
f0102197:	68 68 70 10 f0       	push   $0xf0107068
f010219c:	68 97 74 10 f0       	push   $0xf0107497
f01021a1:	68 32 04 00 00       	push   $0x432
f01021a6:	68 71 74 10 f0       	push   $0xf0107471
f01021ab:	e8 90 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01021b0:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01021b5:	75 19                	jne    f01021d0 <mem_init+0xd5a>
f01021b7:	68 01 77 10 f0       	push   $0xf0107701
f01021bc:	68 97 74 10 f0       	push   $0xf0107497
f01021c1:	68 33 04 00 00       	push   $0x433
f01021c6:	68 71 74 10 f0       	push   $0xf0107471
f01021cb:	e8 70 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f01021d0:	83 3b 00             	cmpl   $0x0,(%ebx)
f01021d3:	74 19                	je     f01021ee <mem_init+0xd78>
f01021d5:	68 0d 77 10 f0       	push   $0xf010770d
f01021da:	68 97 74 10 f0       	push   $0xf0107497
f01021df:	68 34 04 00 00       	push   $0x434
f01021e4:	68 71 74 10 f0       	push   $0xf0107471
f01021e9:	e8 52 de ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01021ee:	83 ec 08             	sub    $0x8,%esp
f01021f1:	68 00 10 00 00       	push   $0x1000
f01021f6:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f01021fc:	e8 e0 f0 ff ff       	call   f01012e1 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102201:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
f0102207:	ba 00 00 00 00       	mov    $0x0,%edx
f010220c:	89 f8                	mov    %edi,%eax
f010220e:	e8 b3 e8 ff ff       	call   f0100ac6 <check_va2pa>
f0102213:	83 c4 10             	add    $0x10,%esp
f0102216:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102219:	74 19                	je     f0102234 <mem_init+0xdbe>
f010221b:	68 44 70 10 f0       	push   $0xf0107044
f0102220:	68 97 74 10 f0       	push   $0xf0107497
f0102225:	68 38 04 00 00       	push   $0x438
f010222a:	68 71 74 10 f0       	push   $0xf0107471
f010222f:	e8 0c de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102234:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102239:	89 f8                	mov    %edi,%eax
f010223b:	e8 86 e8 ff ff       	call   f0100ac6 <check_va2pa>
f0102240:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102243:	74 19                	je     f010225e <mem_init+0xde8>
f0102245:	68 a0 70 10 f0       	push   $0xf01070a0
f010224a:	68 97 74 10 f0       	push   $0xf0107497
f010224f:	68 39 04 00 00       	push   $0x439
f0102254:	68 71 74 10 f0       	push   $0xf0107471
f0102259:	e8 e2 dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010225e:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102263:	74 19                	je     f010227e <mem_init+0xe08>
f0102265:	68 22 77 10 f0       	push   $0xf0107722
f010226a:	68 97 74 10 f0       	push   $0xf0107497
f010226f:	68 3a 04 00 00       	push   $0x43a
f0102274:	68 71 74 10 f0       	push   $0xf0107471
f0102279:	e8 c2 dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010227e:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102283:	74 19                	je     f010229e <mem_init+0xe28>
f0102285:	68 f0 76 10 f0       	push   $0xf01076f0
f010228a:	68 97 74 10 f0       	push   $0xf0107497
f010228f:	68 3b 04 00 00       	push   $0x43b
f0102294:	68 71 74 10 f0       	push   $0xf0107471
f0102299:	e8 a2 dd ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010229e:	83 ec 0c             	sub    $0xc,%esp
f01022a1:	6a 00                	push   $0x0
f01022a3:	e8 f9 ec ff ff       	call   f0100fa1 <page_alloc>
f01022a8:	83 c4 10             	add    $0x10,%esp
f01022ab:	39 c3                	cmp    %eax,%ebx
f01022ad:	75 04                	jne    f01022b3 <mem_init+0xe3d>
f01022af:	85 c0                	test   %eax,%eax
f01022b1:	75 19                	jne    f01022cc <mem_init+0xe56>
f01022b3:	68 c8 70 10 f0       	push   $0xf01070c8
f01022b8:	68 97 74 10 f0       	push   $0xf0107497
f01022bd:	68 3e 04 00 00       	push   $0x43e
f01022c2:	68 71 74 10 f0       	push   $0xf0107471
f01022c7:	e8 74 dd ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01022cc:	83 ec 0c             	sub    $0xc,%esp
f01022cf:	6a 00                	push   $0x0
f01022d1:	e8 cb ec ff ff       	call   f0100fa1 <page_alloc>
f01022d6:	83 c4 10             	add    $0x10,%esp
f01022d9:	85 c0                	test   %eax,%eax
f01022db:	74 19                	je     f01022f6 <mem_init+0xe80>
f01022dd:	68 44 76 10 f0       	push   $0xf0107644
f01022e2:	68 97 74 10 f0       	push   $0xf0107497
f01022e7:	68 41 04 00 00       	push   $0x441
f01022ec:	68 71 74 10 f0       	push   $0xf0107471
f01022f1:	e8 4a dd ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01022f6:	8b 0d 8c 1e 21 f0    	mov    0xf0211e8c,%ecx
f01022fc:	8b 11                	mov    (%ecx),%edx
f01022fe:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102304:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102307:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f010230d:	c1 f8 03             	sar    $0x3,%eax
f0102310:	c1 e0 0c             	shl    $0xc,%eax
f0102313:	39 c2                	cmp    %eax,%edx
f0102315:	74 19                	je     f0102330 <mem_init+0xeba>
f0102317:	68 6c 6d 10 f0       	push   $0xf0106d6c
f010231c:	68 97 74 10 f0       	push   $0xf0107497
f0102321:	68 44 04 00 00       	push   $0x444
f0102326:	68 71 74 10 f0       	push   $0xf0107471
f010232b:	e8 10 dd ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102330:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102336:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102339:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010233e:	74 19                	je     f0102359 <mem_init+0xee3>
f0102340:	68 a7 76 10 f0       	push   $0xf01076a7
f0102345:	68 97 74 10 f0       	push   $0xf0107497
f010234a:	68 46 04 00 00       	push   $0x446
f010234f:	68 71 74 10 f0       	push   $0xf0107471
f0102354:	e8 e7 dc ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102359:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010235c:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102362:	83 ec 0c             	sub    $0xc,%esp
f0102365:	50                   	push   %eax
f0102366:	e8 a6 ec ff ff       	call   f0101011 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010236b:	83 c4 0c             	add    $0xc,%esp
f010236e:	6a 01                	push   $0x1
f0102370:	68 00 10 40 00       	push   $0x401000
f0102375:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f010237b:	e8 27 ed ff ff       	call   f01010a7 <pgdir_walk>
f0102380:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102383:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102386:	8b 0d 8c 1e 21 f0    	mov    0xf0211e8c,%ecx
f010238c:	8b 51 04             	mov    0x4(%ecx),%edx
f010238f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102395:	8b 3d 88 1e 21 f0    	mov    0xf0211e88,%edi
f010239b:	89 d0                	mov    %edx,%eax
f010239d:	c1 e8 0c             	shr    $0xc,%eax
f01023a0:	83 c4 10             	add    $0x10,%esp
f01023a3:	39 f8                	cmp    %edi,%eax
f01023a5:	72 15                	jb     f01023bc <mem_init+0xf46>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023a7:	52                   	push   %edx
f01023a8:	68 a4 65 10 f0       	push   $0xf01065a4
f01023ad:	68 4d 04 00 00       	push   $0x44d
f01023b2:	68 71 74 10 f0       	push   $0xf0107471
f01023b7:	e8 84 dc ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01023bc:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01023c2:	39 55 c8             	cmp    %edx,-0x38(%ebp)
f01023c5:	74 19                	je     f01023e0 <mem_init+0xf6a>
f01023c7:	68 33 77 10 f0       	push   $0xf0107733
f01023cc:	68 97 74 10 f0       	push   $0xf0107497
f01023d1:	68 4e 04 00 00       	push   $0x44e
f01023d6:	68 71 74 10 f0       	push   $0xf0107471
f01023db:	e8 60 dc ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01023e0:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f01023e7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023ea:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01023f0:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f01023f6:	c1 f8 03             	sar    $0x3,%eax
f01023f9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01023fc:	89 c2                	mov    %eax,%edx
f01023fe:	c1 ea 0c             	shr    $0xc,%edx
f0102401:	39 d7                	cmp    %edx,%edi
f0102403:	77 12                	ja     f0102417 <mem_init+0xfa1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102405:	50                   	push   %eax
f0102406:	68 a4 65 10 f0       	push   $0xf01065a4
f010240b:	6a 58                	push   $0x58
f010240d:	68 7d 74 10 f0       	push   $0xf010747d
f0102412:	e8 29 dc ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102417:	83 ec 04             	sub    $0x4,%esp
f010241a:	68 00 10 00 00       	push   $0x1000
f010241f:	68 ff 00 00 00       	push   $0xff
f0102424:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102429:	50                   	push   %eax
f010242a:	e8 88 34 00 00       	call   f01058b7 <memset>
	page_free(pp0);
f010242f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102432:	89 3c 24             	mov    %edi,(%esp)
f0102435:	e8 d7 eb ff ff       	call   f0101011 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010243a:	83 c4 0c             	add    $0xc,%esp
f010243d:	6a 01                	push   $0x1
f010243f:	6a 00                	push   $0x0
f0102441:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102447:	e8 5b ec ff ff       	call   f01010a7 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010244c:	89 fa                	mov    %edi,%edx
f010244e:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0102454:	c1 fa 03             	sar    $0x3,%edx
f0102457:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010245a:	89 d0                	mov    %edx,%eax
f010245c:	c1 e8 0c             	shr    $0xc,%eax
f010245f:	83 c4 10             	add    $0x10,%esp
f0102462:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f0102468:	72 12                	jb     f010247c <mem_init+0x1006>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010246a:	52                   	push   %edx
f010246b:	68 a4 65 10 f0       	push   $0xf01065a4
f0102470:	6a 58                	push   $0x58
f0102472:	68 7d 74 10 f0       	push   $0xf010747d
f0102477:	e8 c4 db ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010247c:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102482:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102485:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010248b:	f6 00 01             	testb  $0x1,(%eax)
f010248e:	74 19                	je     f01024a9 <mem_init+0x1033>
f0102490:	68 4b 77 10 f0       	push   $0xf010774b
f0102495:	68 97 74 10 f0       	push   $0xf0107497
f010249a:	68 58 04 00 00       	push   $0x458
f010249f:	68 71 74 10 f0       	push   $0xf0107471
f01024a4:	e8 97 db ff ff       	call   f0100040 <_panic>
f01024a9:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01024ac:	39 d0                	cmp    %edx,%eax
f01024ae:	75 db                	jne    f010248b <mem_init+0x1015>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01024b0:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f01024b5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01024bb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024be:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01024c4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01024c7:	89 0d 40 12 21 f0    	mov    %ecx,0xf0211240

	// free the pages we took
	page_free(pp0);
f01024cd:	83 ec 0c             	sub    $0xc,%esp
f01024d0:	50                   	push   %eax
f01024d1:	e8 3b eb ff ff       	call   f0101011 <page_free>
	page_free(pp1);
f01024d6:	89 1c 24             	mov    %ebx,(%esp)
f01024d9:	e8 33 eb ff ff       	call   f0101011 <page_free>
	page_free(pp2);
f01024de:	89 34 24             	mov    %esi,(%esp)
f01024e1:	e8 2b eb ff ff       	call   f0101011 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f01024e6:	83 c4 08             	add    $0x8,%esp
f01024e9:	68 01 10 00 00       	push   $0x1001
f01024ee:	6a 00                	push   $0x0
f01024f0:	e8 21 ef ff ff       	call   f0101416 <mmio_map_region>
f01024f5:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f01024f7:	83 c4 08             	add    $0x8,%esp
f01024fa:	68 00 10 00 00       	push   $0x1000
f01024ff:	6a 00                	push   $0x0
f0102501:	e8 10 ef ff ff       	call   f0101416 <mmio_map_region>
f0102506:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102508:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f010250e:	83 c4 10             	add    $0x10,%esp
f0102511:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102517:	76 07                	jbe    f0102520 <mem_init+0x10aa>
f0102519:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f010251e:	76 19                	jbe    f0102539 <mem_init+0x10c3>
f0102520:	68 ec 70 10 f0       	push   $0xf01070ec
f0102525:	68 97 74 10 f0       	push   $0xf0107497
f010252a:	68 68 04 00 00       	push   $0x468
f010252f:	68 71 74 10 f0       	push   $0xf0107471
f0102534:	e8 07 db ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102539:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f010253f:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102545:	77 08                	ja     f010254f <mem_init+0x10d9>
f0102547:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010254d:	77 19                	ja     f0102568 <mem_init+0x10f2>
f010254f:	68 14 71 10 f0       	push   $0xf0107114
f0102554:	68 97 74 10 f0       	push   $0xf0107497
f0102559:	68 69 04 00 00       	push   $0x469
f010255e:	68 71 74 10 f0       	push   $0xf0107471
f0102563:	e8 d8 da ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102568:	89 da                	mov    %ebx,%edx
f010256a:	09 f2                	or     %esi,%edx
f010256c:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102572:	74 19                	je     f010258d <mem_init+0x1117>
f0102574:	68 3c 71 10 f0       	push   $0xf010713c
f0102579:	68 97 74 10 f0       	push   $0xf0107497
f010257e:	68 6b 04 00 00       	push   $0x46b
f0102583:	68 71 74 10 f0       	push   $0xf0107471
f0102588:	e8 b3 da ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f010258d:	39 c6                	cmp    %eax,%esi
f010258f:	73 19                	jae    f01025aa <mem_init+0x1134>
f0102591:	68 62 77 10 f0       	push   $0xf0107762
f0102596:	68 97 74 10 f0       	push   $0xf0107497
f010259b:	68 6d 04 00 00       	push   $0x46d
f01025a0:	68 71 74 10 f0       	push   $0xf0107471
f01025a5:	e8 96 da ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01025aa:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
f01025b0:	89 da                	mov    %ebx,%edx
f01025b2:	89 f8                	mov    %edi,%eax
f01025b4:	e8 0d e5 ff ff       	call   f0100ac6 <check_va2pa>
f01025b9:	85 c0                	test   %eax,%eax
f01025bb:	74 19                	je     f01025d6 <mem_init+0x1160>
f01025bd:	68 64 71 10 f0       	push   $0xf0107164
f01025c2:	68 97 74 10 f0       	push   $0xf0107497
f01025c7:	68 6f 04 00 00       	push   $0x46f
f01025cc:	68 71 74 10 f0       	push   $0xf0107471
f01025d1:	e8 6a da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01025d6:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f01025dc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01025df:	89 c2                	mov    %eax,%edx
f01025e1:	89 f8                	mov    %edi,%eax
f01025e3:	e8 de e4 ff ff       	call   f0100ac6 <check_va2pa>
f01025e8:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01025ed:	74 19                	je     f0102608 <mem_init+0x1192>
f01025ef:	68 88 71 10 f0       	push   $0xf0107188
f01025f4:	68 97 74 10 f0       	push   $0xf0107497
f01025f9:	68 70 04 00 00       	push   $0x470
f01025fe:	68 71 74 10 f0       	push   $0xf0107471
f0102603:	e8 38 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102608:	89 f2                	mov    %esi,%edx
f010260a:	89 f8                	mov    %edi,%eax
f010260c:	e8 b5 e4 ff ff       	call   f0100ac6 <check_va2pa>
f0102611:	85 c0                	test   %eax,%eax
f0102613:	74 19                	je     f010262e <mem_init+0x11b8>
f0102615:	68 b8 71 10 f0       	push   $0xf01071b8
f010261a:	68 97 74 10 f0       	push   $0xf0107497
f010261f:	68 71 04 00 00       	push   $0x471
f0102624:	68 71 74 10 f0       	push   $0xf0107471
f0102629:	e8 12 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f010262e:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102634:	89 f8                	mov    %edi,%eax
f0102636:	e8 8b e4 ff ff       	call   f0100ac6 <check_va2pa>
f010263b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010263e:	74 19                	je     f0102659 <mem_init+0x11e3>
f0102640:	68 dc 71 10 f0       	push   $0xf01071dc
f0102645:	68 97 74 10 f0       	push   $0xf0107497
f010264a:	68 72 04 00 00       	push   $0x472
f010264f:	68 71 74 10 f0       	push   $0xf0107471
f0102654:	e8 e7 d9 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102659:	83 ec 04             	sub    $0x4,%esp
f010265c:	6a 00                	push   $0x0
f010265e:	53                   	push   %ebx
f010265f:	57                   	push   %edi
f0102660:	e8 42 ea ff ff       	call   f01010a7 <pgdir_walk>
f0102665:	83 c4 10             	add    $0x10,%esp
f0102668:	f6 00 1a             	testb  $0x1a,(%eax)
f010266b:	75 19                	jne    f0102686 <mem_init+0x1210>
f010266d:	68 08 72 10 f0       	push   $0xf0107208
f0102672:	68 97 74 10 f0       	push   $0xf0107497
f0102677:	68 74 04 00 00       	push   $0x474
f010267c:	68 71 74 10 f0       	push   $0xf0107471
f0102681:	e8 ba d9 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102686:	83 ec 04             	sub    $0x4,%esp
f0102689:	6a 00                	push   $0x0
f010268b:	53                   	push   %ebx
f010268c:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102692:	e8 10 ea ff ff       	call   f01010a7 <pgdir_walk>
f0102697:	8b 00                	mov    (%eax),%eax
f0102699:	83 c4 10             	add    $0x10,%esp
f010269c:	83 e0 04             	and    $0x4,%eax
f010269f:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01026a2:	74 19                	je     f01026bd <mem_init+0x1247>
f01026a4:	68 4c 72 10 f0       	push   $0xf010724c
f01026a9:	68 97 74 10 f0       	push   $0xf0107497
f01026ae:	68 75 04 00 00       	push   $0x475
f01026b3:	68 71 74 10 f0       	push   $0xf0107471
f01026b8:	e8 83 d9 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f01026bd:	83 ec 04             	sub    $0x4,%esp
f01026c0:	6a 00                	push   $0x0
f01026c2:	53                   	push   %ebx
f01026c3:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f01026c9:	e8 d9 e9 ff ff       	call   f01010a7 <pgdir_walk>
f01026ce:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f01026d4:	83 c4 0c             	add    $0xc,%esp
f01026d7:	6a 00                	push   $0x0
f01026d9:	ff 75 d4             	pushl  -0x2c(%ebp)
f01026dc:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f01026e2:	e8 c0 e9 ff ff       	call   f01010a7 <pgdir_walk>
f01026e7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f01026ed:	83 c4 0c             	add    $0xc,%esp
f01026f0:	6a 00                	push   $0x0
f01026f2:	56                   	push   %esi
f01026f3:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f01026f9:	e8 a9 e9 ff ff       	call   f01010a7 <pgdir_walk>
f01026fe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102704:	c7 04 24 74 77 10 f0 	movl   $0xf0107774,(%esp)
f010270b:	e8 7d 11 00 00       	call   f010388d <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
        boot_map_region(kern_pgdir, UPAGES, ROUNDUP(pages_size, PGSIZE), PADDR(pages), PTE_U); 
f0102710:	a1 90 1e 21 f0       	mov    0xf0211e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102715:	83 c4 10             	add    $0x10,%esp
f0102718:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010271d:	77 15                	ja     f0102734 <mem_init+0x12be>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010271f:	50                   	push   %eax
f0102720:	68 c8 65 10 f0       	push   $0xf01065c8
f0102725:	68 c1 00 00 00       	push   $0xc1
f010272a:	68 71 74 10 f0       	push   $0xf0107471
f010272f:	e8 0c d9 ff ff       	call   f0100040 <_panic>
f0102734:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0102737:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f010273d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102743:	83 ec 08             	sub    $0x8,%esp
f0102746:	6a 04                	push   $0x4
f0102748:	05 00 00 00 10       	add    $0x10000000,%eax
f010274d:	50                   	push   %eax
f010274e:	89 d9                	mov    %ebx,%ecx
f0102750:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102755:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f010275a:	e8 30 ea ff ff       	call   f010118f <boot_map_region>
        boot_map_region(kern_pgdir, (uintptr_t) pages, ROUNDUP(pages_size, PGSIZE), PADDR(pages), PTE_W);
f010275f:	8b 15 90 1e 21 f0    	mov    0xf0211e90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102765:	83 c4 10             	add    $0x10,%esp
f0102768:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010276e:	77 15                	ja     f0102785 <mem_init+0x130f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102770:	52                   	push   %edx
f0102771:	68 c8 65 10 f0       	push   $0xf01065c8
f0102776:	68 c2 00 00 00       	push   $0xc2
f010277b:	68 71 74 10 f0       	push   $0xf0107471
f0102780:	e8 bb d8 ff ff       	call   f0100040 <_panic>
f0102785:	83 ec 08             	sub    $0x8,%esp
f0102788:	6a 02                	push   $0x2
f010278a:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
f0102790:	50                   	push   %eax
f0102791:	89 d9                	mov    %ebx,%ecx
f0102793:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0102798:	e8 f2 e9 ff ff       	call   f010118f <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
        boot_map_region(kern_pgdir, UENVS, ROUNDUP(envs_size, PGSIZE), PADDR(envs), PTE_U);
f010279d:	a1 48 12 21 f0       	mov    0xf0211248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027a2:	83 c4 10             	add    $0x10,%esp
f01027a5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01027aa:	77 15                	ja     f01027c1 <mem_init+0x134b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027ac:	50                   	push   %eax
f01027ad:	68 c8 65 10 f0       	push   $0xf01065c8
f01027b2:	68 cb 00 00 00       	push   $0xcb
f01027b7:	68 71 74 10 f0       	push   $0xf0107471
f01027bc:	e8 7f d8 ff ff       	call   f0100040 <_panic>
f01027c1:	83 ec 08             	sub    $0x8,%esp
f01027c4:	6a 04                	push   $0x4
f01027c6:	05 00 00 00 10       	add    $0x10000000,%eax
f01027cb:	50                   	push   %eax
f01027cc:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f01027d1:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01027d6:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f01027db:	e8 af e9 ff ff       	call   f010118f <boot_map_region>
        boot_map_region(kern_pgdir, (uintptr_t) envs, ROUNDUP(envs_size, PGSIZE), PADDR(pages), PTE_W);
f01027e0:	a1 90 1e 21 f0       	mov    0xf0211e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027e5:	83 c4 10             	add    $0x10,%esp
f01027e8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01027ed:	77 15                	ja     f0102804 <mem_init+0x138e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027ef:	50                   	push   %eax
f01027f0:	68 c8 65 10 f0       	push   $0xf01065c8
f01027f5:	68 cc 00 00 00       	push   $0xcc
f01027fa:	68 71 74 10 f0       	push   $0xf0107471
f01027ff:	e8 3c d8 ff ff       	call   f0100040 <_panic>
f0102804:	83 ec 08             	sub    $0x8,%esp
f0102807:	6a 02                	push   $0x2
f0102809:	05 00 00 00 10       	add    $0x10000000,%eax
f010280e:	50                   	push   %eax
f010280f:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102814:	8b 15 48 12 21 f0    	mov    0xf0211248,%edx
f010281a:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f010281f:	e8 6b e9 ff ff       	call   f010118f <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102824:	83 c4 10             	add    $0x10,%esp
f0102827:	b8 00 60 11 f0       	mov    $0xf0116000,%eax
f010282c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102831:	77 15                	ja     f0102848 <mem_init+0x13d2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102833:	50                   	push   %eax
f0102834:	68 c8 65 10 f0       	push   $0xf01065c8
f0102839:	68 d9 00 00 00       	push   $0xd9
f010283e:	68 71 74 10 f0       	push   $0xf0107471
f0102843:	e8 f8 d7 ff ff       	call   f0100040 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
        boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102848:	83 ec 08             	sub    $0x8,%esp
f010284b:	6a 02                	push   $0x2
f010284d:	68 00 60 11 00       	push   $0x116000
f0102852:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102857:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010285c:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0102861:	e8 29 e9 ff ff       	call   f010118f <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
        boot_map_region(kern_pgdir, KERNBASE, -KERNBASE, 0, PTE_W);
f0102866:	83 c4 08             	add    $0x8,%esp
f0102869:	6a 02                	push   $0x2
f010286b:	6a 00                	push   $0x0
f010286d:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102872:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102877:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f010287c:	e8 0e e9 ff ff       	call   f010118f <boot_map_region>
f0102881:	c7 45 c4 00 30 21 f0 	movl   $0xf0213000,-0x3c(%ebp)
f0102888:	83 c4 10             	add    $0x10,%esp
f010288b:	bb 00 30 21 f0       	mov    $0xf0213000,%ebx
f0102890:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102895:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f010289b:	77 15                	ja     f01028b2 <mem_init+0x143c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010289d:	53                   	push   %ebx
f010289e:	68 c8 65 10 f0       	push   $0xf01065c8
f01028a3:	68 1a 01 00 00       	push   $0x11a
f01028a8:	68 71 74 10 f0       	push   $0xf0107471
f01028ad:	e8 8e d7 ff ff       	call   f0100040 <_panic>
	//
	// LAB 4: Your code here:
        size_t i;
        for (i = 0; i < NCPU; i++) {
                uintptr_t kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
                boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W);
f01028b2:	83 ec 08             	sub    $0x8,%esp
f01028b5:	6a 02                	push   $0x2
f01028b7:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f01028bd:	50                   	push   %eax
f01028be:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01028c3:	89 f2                	mov    %esi,%edx
f01028c5:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f01028ca:	e8 c0 e8 ff ff       	call   f010118f <boot_map_region>
f01028cf:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f01028d5:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
        size_t i;
        for (i = 0; i < NCPU; i++) {
f01028db:	83 c4 10             	add    $0x10,%esp
f01028de:	b8 00 30 25 f0       	mov    $0xf0253000,%eax
f01028e3:	39 d8                	cmp    %ebx,%eax
f01028e5:	75 ae                	jne    f0102895 <mem_init+0x141f>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01028e7:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01028ed:	a1 88 1e 21 f0       	mov    0xf0211e88,%eax
f01028f2:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01028f5:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01028fc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102901:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102904:	8b 35 90 1e 21 f0    	mov    0xf0211e90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010290a:	89 75 d0             	mov    %esi,-0x30(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010290d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102912:	eb 55                	jmp    f0102969 <mem_init+0x14f3>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102914:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f010291a:	89 f8                	mov    %edi,%eax
f010291c:	e8 a5 e1 ff ff       	call   f0100ac6 <check_va2pa>
f0102921:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102928:	77 15                	ja     f010293f <mem_init+0x14c9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010292a:	56                   	push   %esi
f010292b:	68 c8 65 10 f0       	push   $0xf01065c8
f0102930:	68 8c 03 00 00       	push   $0x38c
f0102935:	68 71 74 10 f0       	push   $0xf0107471
f010293a:	e8 01 d7 ff ff       	call   f0100040 <_panic>
f010293f:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f0102946:	39 c2                	cmp    %eax,%edx
f0102948:	74 19                	je     f0102963 <mem_init+0x14ed>
f010294a:	68 80 72 10 f0       	push   $0xf0107280
f010294f:	68 97 74 10 f0       	push   $0xf0107497
f0102954:	68 8c 03 00 00       	push   $0x38c
f0102959:	68 71 74 10 f0       	push   $0xf0107471
f010295e:	e8 dd d6 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102963:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102969:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f010296c:	77 a6                	ja     f0102914 <mem_init+0x149e>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010296e:	8b 35 48 12 21 f0    	mov    0xf0211248,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102974:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102977:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f010297c:	89 da                	mov    %ebx,%edx
f010297e:	89 f8                	mov    %edi,%eax
f0102980:	e8 41 e1 ff ff       	call   f0100ac6 <check_va2pa>
f0102985:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f010298c:	77 15                	ja     f01029a3 <mem_init+0x152d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010298e:	56                   	push   %esi
f010298f:	68 c8 65 10 f0       	push   $0xf01065c8
f0102994:	68 91 03 00 00       	push   $0x391
f0102999:	68 71 74 10 f0       	push   $0xf0107471
f010299e:	e8 9d d6 ff ff       	call   f0100040 <_panic>
f01029a3:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f01029aa:	39 d0                	cmp    %edx,%eax
f01029ac:	74 19                	je     f01029c7 <mem_init+0x1551>
f01029ae:	68 b4 72 10 f0       	push   $0xf01072b4
f01029b3:	68 97 74 10 f0       	push   $0xf0107497
f01029b8:	68 91 03 00 00       	push   $0x391
f01029bd:	68 71 74 10 f0       	push   $0xf0107471
f01029c2:	e8 79 d6 ff ff       	call   f0100040 <_panic>
f01029c7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01029cd:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f01029d3:	75 a7                	jne    f010297c <mem_init+0x1506>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029d5:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01029d8:	c1 e6 0c             	shl    $0xc,%esi
f01029db:	bb 00 00 00 00       	mov    $0x0,%ebx
f01029e0:	eb 30                	jmp    f0102a12 <mem_init+0x159c>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01029e2:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01029e8:	89 f8                	mov    %edi,%eax
f01029ea:	e8 d7 e0 ff ff       	call   f0100ac6 <check_va2pa>
f01029ef:	39 c3                	cmp    %eax,%ebx
f01029f1:	74 19                	je     f0102a0c <mem_init+0x1596>
f01029f3:	68 e8 72 10 f0       	push   $0xf01072e8
f01029f8:	68 97 74 10 f0       	push   $0xf0107497
f01029fd:	68 95 03 00 00       	push   $0x395
f0102a02:	68 71 74 10 f0       	push   $0xf0107471
f0102a07:	e8 34 d6 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102a0c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102a12:	39 f3                	cmp    %esi,%ebx
f0102a14:	72 cc                	jb     f01029e2 <mem_init+0x156c>
f0102a16:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102a1b:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0102a1e:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102a21:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102a24:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f0102a2a:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102a2d:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102a2f:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102a32:	05 00 80 00 20       	add    $0x20008000,%eax
f0102a37:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102a3a:	89 da                	mov    %ebx,%edx
f0102a3c:	89 f8                	mov    %edi,%eax
f0102a3e:	e8 83 e0 ff ff       	call   f0100ac6 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a43:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102a49:	77 15                	ja     f0102a60 <mem_init+0x15ea>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a4b:	56                   	push   %esi
f0102a4c:	68 c8 65 10 f0       	push   $0xf01065c8
f0102a51:	68 9d 03 00 00       	push   $0x39d
f0102a56:	68 71 74 10 f0       	push   $0xf0107471
f0102a5b:	e8 e0 d5 ff ff       	call   f0100040 <_panic>
f0102a60:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102a63:	8d 94 0b 00 30 21 f0 	lea    -0xfded000(%ebx,%ecx,1),%edx
f0102a6a:	39 d0                	cmp    %edx,%eax
f0102a6c:	74 19                	je     f0102a87 <mem_init+0x1611>
f0102a6e:	68 10 73 10 f0       	push   $0xf0107310
f0102a73:	68 97 74 10 f0       	push   $0xf0107497
f0102a78:	68 9d 03 00 00       	push   $0x39d
f0102a7d:	68 71 74 10 f0       	push   $0xf0107471
f0102a82:	e8 b9 d5 ff ff       	call   f0100040 <_panic>
f0102a87:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102a8d:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f0102a90:	75 a8                	jne    f0102a3a <mem_init+0x15c4>
f0102a92:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102a95:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f0102a9b:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102a9e:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102aa0:	89 da                	mov    %ebx,%edx
f0102aa2:	89 f8                	mov    %edi,%eax
f0102aa4:	e8 1d e0 ff ff       	call   f0100ac6 <check_va2pa>
f0102aa9:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102aac:	74 19                	je     f0102ac7 <mem_init+0x1651>
f0102aae:	68 58 73 10 f0       	push   $0xf0107358
f0102ab3:	68 97 74 10 f0       	push   $0xf0107497
f0102ab8:	68 9f 03 00 00       	push   $0x39f
f0102abd:	68 71 74 10 f0       	push   $0xf0107471
f0102ac2:	e8 79 d5 ff ff       	call   f0100040 <_panic>
f0102ac7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102acd:	39 f3                	cmp    %esi,%ebx
f0102acf:	75 cf                	jne    f0102aa0 <mem_init+0x162a>
f0102ad1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102ad4:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f0102adb:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f0102ae2:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102ae8:	b8 00 30 25 f0       	mov    $0xf0253000,%eax
f0102aed:	39 f0                	cmp    %esi,%eax
f0102aef:	0f 85 2c ff ff ff    	jne    f0102a21 <mem_init+0x15ab>
f0102af5:	b8 00 00 00 00       	mov    $0x0,%eax
f0102afa:	eb 2a                	jmp    f0102b26 <mem_init+0x16b0>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102afc:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102b02:	83 fa 04             	cmp    $0x4,%edx
f0102b05:	77 1f                	ja     f0102b26 <mem_init+0x16b0>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102b07:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102b0b:	75 7e                	jne    f0102b8b <mem_init+0x1715>
f0102b0d:	68 8d 77 10 f0       	push   $0xf010778d
f0102b12:	68 97 74 10 f0       	push   $0xf0107497
f0102b17:	68 aa 03 00 00       	push   $0x3aa
f0102b1c:	68 71 74 10 f0       	push   $0xf0107471
f0102b21:	e8 1a d5 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102b26:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102b2b:	76 3f                	jbe    f0102b6c <mem_init+0x16f6>
				assert(pgdir[i] & PTE_P);
f0102b2d:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102b30:	f6 c2 01             	test   $0x1,%dl
f0102b33:	75 19                	jne    f0102b4e <mem_init+0x16d8>
f0102b35:	68 8d 77 10 f0       	push   $0xf010778d
f0102b3a:	68 97 74 10 f0       	push   $0xf0107497
f0102b3f:	68 ae 03 00 00       	push   $0x3ae
f0102b44:	68 71 74 10 f0       	push   $0xf0107471
f0102b49:	e8 f2 d4 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102b4e:	f6 c2 02             	test   $0x2,%dl
f0102b51:	75 38                	jne    f0102b8b <mem_init+0x1715>
f0102b53:	68 9e 77 10 f0       	push   $0xf010779e
f0102b58:	68 97 74 10 f0       	push   $0xf0107497
f0102b5d:	68 af 03 00 00       	push   $0x3af
f0102b62:	68 71 74 10 f0       	push   $0xf0107471
f0102b67:	e8 d4 d4 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102b6c:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102b70:	74 19                	je     f0102b8b <mem_init+0x1715>
f0102b72:	68 af 77 10 f0       	push   $0xf01077af
f0102b77:	68 97 74 10 f0       	push   $0xf0107497
f0102b7c:	68 b1 03 00 00       	push   $0x3b1
f0102b81:	68 71 74 10 f0       	push   $0xf0107471
f0102b86:	e8 b5 d4 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102b8b:	83 c0 01             	add    $0x1,%eax
f0102b8e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102b93:	0f 86 63 ff ff ff    	jbe    f0102afc <mem_init+0x1686>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102b99:	83 ec 0c             	sub    $0xc,%esp
f0102b9c:	68 7c 73 10 f0       	push   $0xf010737c
f0102ba1:	e8 e7 0c 00 00       	call   f010388d <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102ba6:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102bab:	83 c4 10             	add    $0x10,%esp
f0102bae:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102bb3:	77 15                	ja     f0102bca <mem_init+0x1754>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102bb5:	50                   	push   %eax
f0102bb6:	68 c8 65 10 f0       	push   $0xf01065c8
f0102bbb:	68 f2 00 00 00       	push   $0xf2
f0102bc0:	68 71 74 10 f0       	push   $0xf0107471
f0102bc5:	e8 76 d4 ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102bca:	05 00 00 00 10       	add    $0x10000000,%eax
f0102bcf:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102bd2:	b8 00 00 00 00       	mov    $0x0,%eax
f0102bd7:	e8 cd df ff ff       	call   f0100ba9 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102bdc:	0f 20 c0             	mov    %cr0,%eax
f0102bdf:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102be2:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102be7:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102bea:	83 ec 0c             	sub    $0xc,%esp
f0102bed:	6a 00                	push   $0x0
f0102bef:	e8 ad e3 ff ff       	call   f0100fa1 <page_alloc>
f0102bf4:	89 c3                	mov    %eax,%ebx
f0102bf6:	83 c4 10             	add    $0x10,%esp
f0102bf9:	85 c0                	test   %eax,%eax
f0102bfb:	75 19                	jne    f0102c16 <mem_init+0x17a0>
f0102bfd:	68 99 75 10 f0       	push   $0xf0107599
f0102c02:	68 97 74 10 f0       	push   $0xf0107497
f0102c07:	68 8a 04 00 00       	push   $0x48a
f0102c0c:	68 71 74 10 f0       	push   $0xf0107471
f0102c11:	e8 2a d4 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102c16:	83 ec 0c             	sub    $0xc,%esp
f0102c19:	6a 00                	push   $0x0
f0102c1b:	e8 81 e3 ff ff       	call   f0100fa1 <page_alloc>
f0102c20:	89 c7                	mov    %eax,%edi
f0102c22:	83 c4 10             	add    $0x10,%esp
f0102c25:	85 c0                	test   %eax,%eax
f0102c27:	75 19                	jne    f0102c42 <mem_init+0x17cc>
f0102c29:	68 af 75 10 f0       	push   $0xf01075af
f0102c2e:	68 97 74 10 f0       	push   $0xf0107497
f0102c33:	68 8b 04 00 00       	push   $0x48b
f0102c38:	68 71 74 10 f0       	push   $0xf0107471
f0102c3d:	e8 fe d3 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102c42:	83 ec 0c             	sub    $0xc,%esp
f0102c45:	6a 00                	push   $0x0
f0102c47:	e8 55 e3 ff ff       	call   f0100fa1 <page_alloc>
f0102c4c:	89 c6                	mov    %eax,%esi
f0102c4e:	83 c4 10             	add    $0x10,%esp
f0102c51:	85 c0                	test   %eax,%eax
f0102c53:	75 19                	jne    f0102c6e <mem_init+0x17f8>
f0102c55:	68 c5 75 10 f0       	push   $0xf01075c5
f0102c5a:	68 97 74 10 f0       	push   $0xf0107497
f0102c5f:	68 8c 04 00 00       	push   $0x48c
f0102c64:	68 71 74 10 f0       	push   $0xf0107471
f0102c69:	e8 d2 d3 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102c6e:	83 ec 0c             	sub    $0xc,%esp
f0102c71:	53                   	push   %ebx
f0102c72:	e8 9a e3 ff ff       	call   f0101011 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c77:	89 f8                	mov    %edi,%eax
f0102c79:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0102c7f:	c1 f8 03             	sar    $0x3,%eax
f0102c82:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c85:	89 c2                	mov    %eax,%edx
f0102c87:	c1 ea 0c             	shr    $0xc,%edx
f0102c8a:	83 c4 10             	add    $0x10,%esp
f0102c8d:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0102c93:	72 12                	jb     f0102ca7 <mem_init+0x1831>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c95:	50                   	push   %eax
f0102c96:	68 a4 65 10 f0       	push   $0xf01065a4
f0102c9b:	6a 58                	push   $0x58
f0102c9d:	68 7d 74 10 f0       	push   $0xf010747d
f0102ca2:	e8 99 d3 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102ca7:	83 ec 04             	sub    $0x4,%esp
f0102caa:	68 00 10 00 00       	push   $0x1000
f0102caf:	6a 01                	push   $0x1
f0102cb1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102cb6:	50                   	push   %eax
f0102cb7:	e8 fb 2b 00 00       	call   f01058b7 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102cbc:	89 f0                	mov    %esi,%eax
f0102cbe:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0102cc4:	c1 f8 03             	sar    $0x3,%eax
f0102cc7:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102cca:	89 c2                	mov    %eax,%edx
f0102ccc:	c1 ea 0c             	shr    $0xc,%edx
f0102ccf:	83 c4 10             	add    $0x10,%esp
f0102cd2:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0102cd8:	72 12                	jb     f0102cec <mem_init+0x1876>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102cda:	50                   	push   %eax
f0102cdb:	68 a4 65 10 f0       	push   $0xf01065a4
f0102ce0:	6a 58                	push   $0x58
f0102ce2:	68 7d 74 10 f0       	push   $0xf010747d
f0102ce7:	e8 54 d3 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102cec:	83 ec 04             	sub    $0x4,%esp
f0102cef:	68 00 10 00 00       	push   $0x1000
f0102cf4:	6a 02                	push   $0x2
f0102cf6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102cfb:	50                   	push   %eax
f0102cfc:	e8 b6 2b 00 00       	call   f01058b7 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102d01:	6a 02                	push   $0x2
f0102d03:	68 00 10 00 00       	push   $0x1000
f0102d08:	57                   	push   %edi
f0102d09:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102d0f:	e8 3b e6 ff ff       	call   f010134f <page_insert>
	assert(pp1->pp_ref == 1);
f0102d14:	83 c4 20             	add    $0x20,%esp
f0102d17:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102d1c:	74 19                	je     f0102d37 <mem_init+0x18c1>
f0102d1e:	68 96 76 10 f0       	push   $0xf0107696
f0102d23:	68 97 74 10 f0       	push   $0xf0107497
f0102d28:	68 91 04 00 00       	push   $0x491
f0102d2d:	68 71 74 10 f0       	push   $0xf0107471
f0102d32:	e8 09 d3 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102d37:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102d3e:	01 01 01 
f0102d41:	74 19                	je     f0102d5c <mem_init+0x18e6>
f0102d43:	68 9c 73 10 f0       	push   $0xf010739c
f0102d48:	68 97 74 10 f0       	push   $0xf0107497
f0102d4d:	68 92 04 00 00       	push   $0x492
f0102d52:	68 71 74 10 f0       	push   $0xf0107471
f0102d57:	e8 e4 d2 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102d5c:	6a 02                	push   $0x2
f0102d5e:	68 00 10 00 00       	push   $0x1000
f0102d63:	56                   	push   %esi
f0102d64:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102d6a:	e8 e0 e5 ff ff       	call   f010134f <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102d6f:	83 c4 10             	add    $0x10,%esp
f0102d72:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102d79:	02 02 02 
f0102d7c:	74 19                	je     f0102d97 <mem_init+0x1921>
f0102d7e:	68 c0 73 10 f0       	push   $0xf01073c0
f0102d83:	68 97 74 10 f0       	push   $0xf0107497
f0102d88:	68 94 04 00 00       	push   $0x494
f0102d8d:	68 71 74 10 f0       	push   $0xf0107471
f0102d92:	e8 a9 d2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102d97:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102d9c:	74 19                	je     f0102db7 <mem_init+0x1941>
f0102d9e:	68 b8 76 10 f0       	push   $0xf01076b8
f0102da3:	68 97 74 10 f0       	push   $0xf0107497
f0102da8:	68 95 04 00 00       	push   $0x495
f0102dad:	68 71 74 10 f0       	push   $0xf0107471
f0102db2:	e8 89 d2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102db7:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102dbc:	74 19                	je     f0102dd7 <mem_init+0x1961>
f0102dbe:	68 22 77 10 f0       	push   $0xf0107722
f0102dc3:	68 97 74 10 f0       	push   $0xf0107497
f0102dc8:	68 96 04 00 00       	push   $0x496
f0102dcd:	68 71 74 10 f0       	push   $0xf0107471
f0102dd2:	e8 69 d2 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102dd7:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102dde:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102de1:	89 f0                	mov    %esi,%eax
f0102de3:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0102de9:	c1 f8 03             	sar    $0x3,%eax
f0102dec:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102def:	89 c2                	mov    %eax,%edx
f0102df1:	c1 ea 0c             	shr    $0xc,%edx
f0102df4:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0102dfa:	72 12                	jb     f0102e0e <mem_init+0x1998>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102dfc:	50                   	push   %eax
f0102dfd:	68 a4 65 10 f0       	push   $0xf01065a4
f0102e02:	6a 58                	push   $0x58
f0102e04:	68 7d 74 10 f0       	push   $0xf010747d
f0102e09:	e8 32 d2 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e0e:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102e15:	03 03 03 
f0102e18:	74 19                	je     f0102e33 <mem_init+0x19bd>
f0102e1a:	68 e4 73 10 f0       	push   $0xf01073e4
f0102e1f:	68 97 74 10 f0       	push   $0xf0107497
f0102e24:	68 98 04 00 00       	push   $0x498
f0102e29:	68 71 74 10 f0       	push   $0xf0107471
f0102e2e:	e8 0d d2 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102e33:	83 ec 08             	sub    $0x8,%esp
f0102e36:	68 00 10 00 00       	push   $0x1000
f0102e3b:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102e41:	e8 9b e4 ff ff       	call   f01012e1 <page_remove>
	assert(pp2->pp_ref == 0);
f0102e46:	83 c4 10             	add    $0x10,%esp
f0102e49:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102e4e:	74 19                	je     f0102e69 <mem_init+0x19f3>
f0102e50:	68 f0 76 10 f0       	push   $0xf01076f0
f0102e55:	68 97 74 10 f0       	push   $0xf0107497
f0102e5a:	68 9a 04 00 00       	push   $0x49a
f0102e5f:	68 71 74 10 f0       	push   $0xf0107471
f0102e64:	e8 d7 d1 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102e69:	8b 0d 8c 1e 21 f0    	mov    0xf0211e8c,%ecx
f0102e6f:	8b 11                	mov    (%ecx),%edx
f0102e71:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102e77:	89 d8                	mov    %ebx,%eax
f0102e79:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0102e7f:	c1 f8 03             	sar    $0x3,%eax
f0102e82:	c1 e0 0c             	shl    $0xc,%eax
f0102e85:	39 c2                	cmp    %eax,%edx
f0102e87:	74 19                	je     f0102ea2 <mem_init+0x1a2c>
f0102e89:	68 6c 6d 10 f0       	push   $0xf0106d6c
f0102e8e:	68 97 74 10 f0       	push   $0xf0107497
f0102e93:	68 9d 04 00 00       	push   $0x49d
f0102e98:	68 71 74 10 f0       	push   $0xf0107471
f0102e9d:	e8 9e d1 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102ea2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102ea8:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102ead:	74 19                	je     f0102ec8 <mem_init+0x1a52>
f0102eaf:	68 a7 76 10 f0       	push   $0xf01076a7
f0102eb4:	68 97 74 10 f0       	push   $0xf0107497
f0102eb9:	68 9f 04 00 00       	push   $0x49f
f0102ebe:	68 71 74 10 f0       	push   $0xf0107471
f0102ec3:	e8 78 d1 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102ec8:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102ece:	83 ec 0c             	sub    $0xc,%esp
f0102ed1:	53                   	push   %ebx
f0102ed2:	e8 3a e1 ff ff       	call   f0101011 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102ed7:	c7 04 24 10 74 10 f0 	movl   $0xf0107410,(%esp)
f0102ede:	e8 aa 09 00 00       	call   f010388d <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102ee3:	83 c4 10             	add    $0x10,%esp
f0102ee6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102ee9:	5b                   	pop    %ebx
f0102eea:	5e                   	pop    %esi
f0102eeb:	5f                   	pop    %edi
f0102eec:	5d                   	pop    %ebp
f0102eed:	c3                   	ret    

f0102eee <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102eee:	55                   	push   %ebp
f0102eef:	89 e5                	mov    %esp,%ebp
f0102ef1:	57                   	push   %edi
f0102ef2:	56                   	push   %esi
f0102ef3:	53                   	push   %ebx
f0102ef4:	83 ec 1c             	sub    $0x1c,%esp
f0102ef7:	8b 7d 08             	mov    0x8(%ebp),%edi
        uintptr_t start_va = ROUNDDOWN((uintptr_t) va, PGSIZE);
f0102efa:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102efd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102f02:	89 c1                	mov    %eax,%ecx
f0102f04:	89 45 e0             	mov    %eax,-0x20(%ebp)
        uintptr_t end_va = start_va + ROUNDUP(len, PGSIZE);        
f0102f07:	8b 45 10             	mov    0x10(%ebp),%eax
f0102f0a:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102f0f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102f14:	8d 04 08             	lea    (%eax,%ecx,1),%eax
f0102f17:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
        uintptr_t start_va = ROUNDDOWN((uintptr_t) va, PGSIZE);
f0102f1a:	89 cb                	mov    %ecx,%ebx
                        goto user_mem_check_fault;

                if (start_va >= ULIM)
                        goto user_mem_check_fault;

                if ((*pte & (perm | PTE_P)) != (perm | PTE_P))
f0102f1c:	8b 75 14             	mov    0x14(%ebp),%esi
f0102f1f:	83 ce 01             	or     $0x1,%esi
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
        uintptr_t start_va = ROUNDDOWN((uintptr_t) va, PGSIZE);
        uintptr_t end_va = start_va + ROUNDUP(len, PGSIZE);        

        while (start_va < end_va) {
f0102f22:	eb 2b                	jmp    f0102f4f <user_mem_check+0x61>
                pte_t *pte = pgdir_walk(env->env_pgdir, (void *) start_va, 0);
f0102f24:	83 ec 04             	sub    $0x4,%esp
f0102f27:	6a 00                	push   $0x0
f0102f29:	53                   	push   %ebx
f0102f2a:	ff 77 60             	pushl  0x60(%edi)
f0102f2d:	e8 75 e1 ff ff       	call   f01010a7 <pgdir_walk>
                // No entry for this va in the page table, so no, the env
                // can't access it
                if (pte == NULL)
                        goto user_mem_check_fault;

                if (start_va >= ULIM)
f0102f32:	83 c4 10             	add    $0x10,%esp
f0102f35:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102f3b:	77 1e                	ja     f0102f5b <user_mem_check+0x6d>
f0102f3d:	85 c0                	test   %eax,%eax
f0102f3f:	74 1a                	je     f0102f5b <user_mem_check+0x6d>
                        goto user_mem_check_fault;

                if ((*pte & (perm | PTE_P)) != (perm | PTE_P))
f0102f41:	89 f2                	mov    %esi,%edx
f0102f43:	23 10                	and    (%eax),%edx
f0102f45:	39 d6                	cmp    %edx,%esi
f0102f47:	75 12                	jne    f0102f5b <user_mem_check+0x6d>
                        goto user_mem_check_fault;

                start_va += PGSIZE;
f0102f49:	81 c3 00 10 00 00    	add    $0x1000,%ebx
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
        uintptr_t start_va = ROUNDDOWN((uintptr_t) va, PGSIZE);
        uintptr_t end_va = start_va + ROUNDUP(len, PGSIZE);        

        while (start_va < end_va) {
f0102f4f:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102f52:	72 d0                	jb     f0102f24 <user_mem_check+0x36>
                        goto user_mem_check_fault;

                start_va += PGSIZE;
        }

	return 0;
f0102f54:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f59:	eb 12                	jmp    f0102f6d <user_mem_check+0x7f>
        //              [00001000] user_mem_check assertion failure for va 00000001
        //      2) make run-buggyhello2:
        //              [00001000] user_mem_check assertion failure for va 00803000
        //
        //              Note: the actual check here is for 00.0.000
        user_mem_check_addr = start_va == ROUNDDOWN((uintptr_t) va, PGSIZE) ? (uintptr_t) va : start_va;        
f0102f5b:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f0102f5e:	0f 44 5d 0c          	cmove  0xc(%ebp),%ebx
f0102f62:	89 1d 3c 12 21 f0    	mov    %ebx,0xf021123c
        return -E_FAULT;
f0102f68:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f0102f6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f70:	5b                   	pop    %ebx
f0102f71:	5e                   	pop    %esi
f0102f72:	5f                   	pop    %edi
f0102f73:	5d                   	pop    %ebp
f0102f74:	c3                   	ret    

f0102f75 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102f75:	55                   	push   %ebp
f0102f76:	89 e5                	mov    %esp,%ebp
f0102f78:	53                   	push   %ebx
f0102f79:	83 ec 04             	sub    $0x4,%esp
f0102f7c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102f7f:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f82:	83 c8 04             	or     $0x4,%eax
f0102f85:	50                   	push   %eax
f0102f86:	ff 75 10             	pushl  0x10(%ebp)
f0102f89:	ff 75 0c             	pushl  0xc(%ebp)
f0102f8c:	53                   	push   %ebx
f0102f8d:	e8 5c ff ff ff       	call   f0102eee <user_mem_check>
f0102f92:	83 c4 10             	add    $0x10,%esp
f0102f95:	85 c0                	test   %eax,%eax
f0102f97:	79 21                	jns    f0102fba <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102f99:	83 ec 04             	sub    $0x4,%esp
f0102f9c:	ff 35 3c 12 21 f0    	pushl  0xf021123c
f0102fa2:	ff 73 48             	pushl  0x48(%ebx)
f0102fa5:	68 3c 74 10 f0       	push   $0xf010743c
f0102faa:	e8 de 08 00 00       	call   f010388d <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102faf:	89 1c 24             	mov    %ebx,(%esp)
f0102fb2:	e8 e6 05 00 00       	call   f010359d <env_destroy>
f0102fb7:	83 c4 10             	add    $0x10,%esp
	}
}
f0102fba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102fbd:	c9                   	leave  
f0102fbe:	c3                   	ret    

f0102fbf <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102fbf:	55                   	push   %ebp
f0102fc0:	89 e5                	mov    %esp,%ebp
f0102fc2:	57                   	push   %edi
f0102fc3:	56                   	push   %esi
f0102fc4:	53                   	push   %ebx
f0102fc5:	83 ec 0c             	sub    $0xc,%esp
f0102fc8:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
        uintptr_t rva = (uintptr_t) ROUNDDOWN(va, PGSIZE);
f0102fca:	89 d3                	mov    %edx,%ebx
f0102fcc:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        uintptr_t rva_end = (uintptr_t) ROUNDUP(va + len, PGSIZE);
f0102fd2:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102fd9:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi

        while (rva < rva_end) {
f0102fdf:	eb 58                	jmp    f0103039 <region_alloc+0x7a>
                struct PageInfo *page = page_alloc(0);
f0102fe1:	83 ec 0c             	sub    $0xc,%esp
f0102fe4:	6a 00                	push   $0x0
f0102fe6:	e8 b6 df ff ff       	call   f0100fa1 <page_alloc>
                if (page == NULL)
f0102feb:	83 c4 10             	add    $0x10,%esp
f0102fee:	85 c0                	test   %eax,%eax
f0102ff0:	75 17                	jne    f0103009 <region_alloc+0x4a>
                        panic("region_alloc: couldn't allocate page");
f0102ff2:	83 ec 04             	sub    $0x4,%esp
f0102ff5:	68 c0 77 10 f0       	push   $0xf01077c0
f0102ffa:	68 2f 01 00 00       	push   $0x12f
f0102fff:	68 63 78 10 f0       	push   $0xf0107863
f0103004:	e8 37 d0 ff ff       	call   f0100040 <_panic>

                if (page_insert(e->env_pgdir, page, (void *) rva, PTE_P | PTE_U | PTE_W) < 0)
f0103009:	6a 07                	push   $0x7
f010300b:	53                   	push   %ebx
f010300c:	50                   	push   %eax
f010300d:	ff 77 60             	pushl  0x60(%edi)
f0103010:	e8 3a e3 ff ff       	call   f010134f <page_insert>
f0103015:	83 c4 10             	add    $0x10,%esp
f0103018:	85 c0                	test   %eax,%eax
f010301a:	79 17                	jns    f0103033 <region_alloc+0x74>
                        panic("region_alloc: page couldn't be inserted");
f010301c:	83 ec 04             	sub    $0x4,%esp
f010301f:	68 e8 77 10 f0       	push   $0xf01077e8
f0103024:	68 32 01 00 00       	push   $0x132
f0103029:	68 63 78 10 f0       	push   $0xf0107863
f010302e:	e8 0d d0 ff ff       	call   f0100040 <_panic>

                rva += PGSIZE;
f0103033:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
        uintptr_t rva = (uintptr_t) ROUNDDOWN(va, PGSIZE);
        uintptr_t rva_end = (uintptr_t) ROUNDUP(va + len, PGSIZE);

        while (rva < rva_end) {
f0103039:	39 f3                	cmp    %esi,%ebx
f010303b:	72 a4                	jb     f0102fe1 <region_alloc+0x22>
                if (page_insert(e->env_pgdir, page, (void *) rva, PTE_P | PTE_U | PTE_W) < 0)
                        panic("region_alloc: page couldn't be inserted");

                rva += PGSIZE;
        }
}
f010303d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103040:	5b                   	pop    %ebx
f0103041:	5e                   	pop    %esi
f0103042:	5f                   	pop    %edi
f0103043:	5d                   	pop    %ebp
f0103044:	c3                   	ret    

f0103045 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103045:	55                   	push   %ebp
f0103046:	89 e5                	mov    %esp,%ebp
f0103048:	56                   	push   %esi
f0103049:	53                   	push   %ebx
f010304a:	8b 45 08             	mov    0x8(%ebp),%eax
f010304d:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103050:	85 c0                	test   %eax,%eax
f0103052:	75 1a                	jne    f010306e <envid2env+0x29>
		*env_store = curenv;
f0103054:	e8 81 2e 00 00       	call   f0105eda <cpunum>
f0103059:	6b c0 74             	imul   $0x74,%eax,%eax
f010305c:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103062:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103065:	89 01                	mov    %eax,(%ecx)
		return 0;
f0103067:	b8 00 00 00 00       	mov    $0x0,%eax
f010306c:	eb 70                	jmp    f01030de <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010306e:	89 c3                	mov    %eax,%ebx
f0103070:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103076:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0103079:	03 1d 48 12 21 f0    	add    0xf0211248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010307f:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103083:	74 05                	je     f010308a <envid2env+0x45>
f0103085:	3b 43 48             	cmp    0x48(%ebx),%eax
f0103088:	74 10                	je     f010309a <envid2env+0x55>
		*env_store = 0;
f010308a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010308d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103093:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103098:	eb 44                	jmp    f01030de <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010309a:	84 d2                	test   %dl,%dl
f010309c:	74 36                	je     f01030d4 <envid2env+0x8f>
f010309e:	e8 37 2e 00 00       	call   f0105eda <cpunum>
f01030a3:	6b c0 74             	imul   $0x74,%eax,%eax
f01030a6:	3b 98 28 20 21 f0    	cmp    -0xfdedfd8(%eax),%ebx
f01030ac:	74 26                	je     f01030d4 <envid2env+0x8f>
f01030ae:	8b 73 4c             	mov    0x4c(%ebx),%esi
f01030b1:	e8 24 2e 00 00       	call   f0105eda <cpunum>
f01030b6:	6b c0 74             	imul   $0x74,%eax,%eax
f01030b9:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01030bf:	3b 70 48             	cmp    0x48(%eax),%esi
f01030c2:	74 10                	je     f01030d4 <envid2env+0x8f>
		*env_store = 0;
f01030c4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030c7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01030cd:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01030d2:	eb 0a                	jmp    f01030de <envid2env+0x99>
	}

	*env_store = e;
f01030d4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030d7:	89 18                	mov    %ebx,(%eax)
	return 0;
f01030d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01030de:	5b                   	pop    %ebx
f01030df:	5e                   	pop    %esi
f01030e0:	5d                   	pop    %ebp
f01030e1:	c3                   	ret    

f01030e2 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01030e2:	55                   	push   %ebp
f01030e3:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f01030e5:	b8 20 03 12 f0       	mov    $0xf0120320,%eax
f01030ea:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f01030ed:	b8 23 00 00 00       	mov    $0x23,%eax
f01030f2:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f01030f4:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f01030f6:	b8 10 00 00 00       	mov    $0x10,%eax
f01030fb:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f01030fd:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f01030ff:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103101:	ea 08 31 10 f0 08 00 	ljmp   $0x8,$0xf0103108
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f0103108:	b8 00 00 00 00       	mov    $0x0,%eax
f010310d:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103110:	5d                   	pop    %ebp
f0103111:	c3                   	ret    

f0103112 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103112:	55                   	push   %ebp
f0103113:	89 e5                	mov    %esp,%ebp
f0103115:	56                   	push   %esi
f0103116:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
        int i;
        for (i = NENV - 1; i >= 0; i--) {
                envs[i].env_status = ENV_FREE;
f0103117:	8b 35 48 12 21 f0    	mov    0xf0211248,%esi
f010311d:	8b 15 4c 12 21 f0    	mov    0xf021124c,%edx
f0103123:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0103129:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f010312c:	89 c1                	mov    %eax,%ecx
f010312e:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
                envs[i].env_id = 0;
f0103135:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
                envs[i].env_link = env_free_list;
f010313c:	89 50 44             	mov    %edx,0x44(%eax)
f010313f:	83 e8 7c             	sub    $0x7c,%eax
                env_free_list = &envs[i];
f0103142:	89 ca                	mov    %ecx,%edx
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
        int i;
        for (i = NENV - 1; i >= 0; i--) {
f0103144:	39 d8                	cmp    %ebx,%eax
f0103146:	75 e4                	jne    f010312c <env_init+0x1a>
f0103148:	89 35 4c 12 21 f0    	mov    %esi,0xf021124c
                envs[i].env_link = env_free_list;
                env_free_list = &envs[i];
        }

	// Per-CPU part of the initialization
	env_init_percpu();
f010314e:	e8 8f ff ff ff       	call   f01030e2 <env_init_percpu>
}
f0103153:	5b                   	pop    %ebx
f0103154:	5e                   	pop    %esi
f0103155:	5d                   	pop    %ebp
f0103156:	c3                   	ret    

f0103157 <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103157:	55                   	push   %ebp
f0103158:	89 e5                	mov    %esp,%ebp
f010315a:	53                   	push   %ebx
f010315b:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f010315e:	8b 1d 4c 12 21 f0    	mov    0xf021124c,%ebx
f0103164:	85 db                	test   %ebx,%ebx
f0103166:	0f 84 4b 01 00 00    	je     f01032b7 <env_alloc+0x160>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f010316c:	83 ec 0c             	sub    $0xc,%esp
f010316f:	6a 01                	push   $0x1
f0103171:	e8 2b de ff ff       	call   f0100fa1 <page_alloc>
f0103176:	83 c4 10             	add    $0x10,%esp
f0103179:	85 c0                	test   %eax,%eax
f010317b:	0f 84 3d 01 00 00    	je     f01032be <env_alloc+0x167>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103181:	89 c2                	mov    %eax,%edx
f0103183:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0103189:	c1 fa 03             	sar    $0x3,%edx
f010318c:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010318f:	89 d1                	mov    %edx,%ecx
f0103191:	c1 e9 0c             	shr    $0xc,%ecx
f0103194:	3b 0d 88 1e 21 f0    	cmp    0xf0211e88,%ecx
f010319a:	72 12                	jb     f01031ae <env_alloc+0x57>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010319c:	52                   	push   %edx
f010319d:	68 a4 65 10 f0       	push   $0xf01065a4
f01031a2:	6a 58                	push   $0x58
f01031a4:	68 7d 74 10 f0       	push   $0xf010747d
f01031a9:	e8 92 ce ff ff       	call   f0100040 <_panic>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
        e->env_pgdir = (pde_t *) page2kva(p);
f01031ae:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01031b4:	89 53 60             	mov    %edx,0x60(%ebx)
        p->pp_ref++;
f01031b7:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f01031bc:	b8 00 00 00 00       	mov    $0x0,%eax

        for (i = 0; i < PDX(UTOP); i++)
                e->env_pgdir[i] = 0;
f01031c1:	8b 53 60             	mov    0x60(%ebx),%edx
f01031c4:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
f01031cb:	83 c0 04             	add    $0x4,%eax

	// LAB 3: Your code here.
        e->env_pgdir = (pde_t *) page2kva(p);
        p->pp_ref++;

        for (i = 0; i < PDX(UTOP); i++)
f01031ce:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01031d3:	75 ec                	jne    f01031c1 <env_alloc+0x6a>
                e->env_pgdir[i] = 0;

        for (i = PDX(UTOP); i < NPDENTRIES; i++)
                e->env_pgdir[i] = kern_pgdir[i];
f01031d5:	8b 15 8c 1e 21 f0    	mov    0xf0211e8c,%edx
f01031db:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f01031de:	8b 53 60             	mov    0x60(%ebx),%edx
f01031e1:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f01031e4:	83 c0 04             	add    $0x4,%eax
        p->pp_ref++;

        for (i = 0; i < PDX(UTOP); i++)
                e->env_pgdir[i] = 0;

        for (i = PDX(UTOP); i < NPDENTRIES; i++)
f01031e7:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01031ec:	75 e7                	jne    f01031d5 <env_alloc+0x7e>
                e->env_pgdir[i] = kern_pgdir[i];

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01031ee:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031f1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031f6:	77 15                	ja     f010320d <env_alloc+0xb6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031f8:	50                   	push   %eax
f01031f9:	68 c8 65 10 f0       	push   $0xf01065c8
f01031fe:	68 cb 00 00 00       	push   $0xcb
f0103203:	68 63 78 10 f0       	push   $0xf0107863
f0103208:	e8 33 ce ff ff       	call   f0100040 <_panic>
f010320d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103213:	83 ca 05             	or     $0x5,%edx
f0103216:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010321c:	8b 43 48             	mov    0x48(%ebx),%eax
f010321f:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103224:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103229:	ba 00 10 00 00       	mov    $0x1000,%edx
f010322e:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103231:	89 da                	mov    %ebx,%edx
f0103233:	2b 15 48 12 21 f0    	sub    0xf0211248,%edx
f0103239:	c1 fa 02             	sar    $0x2,%edx
f010323c:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103242:	09 d0                	or     %edx,%eax
f0103244:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103247:	8b 45 0c             	mov    0xc(%ebp),%eax
f010324a:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010324d:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103254:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f010325b:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103262:	83 ec 04             	sub    $0x4,%esp
f0103265:	6a 44                	push   $0x44
f0103267:	6a 00                	push   $0x0
f0103269:	53                   	push   %ebx
f010326a:	e8 48 26 00 00       	call   f01058b7 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f010326f:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103275:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010327b:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103281:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103288:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.
	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
        e->env_tf.tf_eflags |= FL_IF;
f010328e:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103295:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f010329c:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f01032a0:	8b 43 44             	mov    0x44(%ebx),%eax
f01032a3:	a3 4c 12 21 f0       	mov    %eax,0xf021124c
	*newenv_store = e;
f01032a8:	8b 45 08             	mov    0x8(%ebp),%eax
f01032ab:	89 18                	mov    %ebx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f01032ad:	83 c4 10             	add    $0x10,%esp
f01032b0:	b8 00 00 00 00       	mov    $0x0,%eax
f01032b5:	eb 0c                	jmp    f01032c3 <env_alloc+0x16c>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f01032b7:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01032bc:	eb 05                	jmp    f01032c3 <env_alloc+0x16c>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f01032be:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01032c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01032c6:	c9                   	leave  
f01032c7:	c3                   	ret    

f01032c8 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01032c8:	55                   	push   %ebp
f01032c9:	89 e5                	mov    %esp,%ebp
f01032cb:	57                   	push   %edi
f01032cc:	56                   	push   %esi
f01032cd:	53                   	push   %ebx
f01032ce:	83 ec 34             	sub    $0x34,%esp
f01032d1:	8b 75 08             	mov    0x8(%ebp),%esi
f01032d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// LAB 3: Your code here.
        struct Env *env;
        int status = env_alloc(&env, 0);
f01032d7:	6a 00                	push   $0x0
f01032d9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01032dc:	50                   	push   %eax
f01032dd:	e8 75 fe ff ff       	call   f0103157 <env_alloc>
        if (status < 0)
f01032e2:	83 c4 10             	add    $0x10,%esp
f01032e5:	85 c0                	test   %eax,%eax
f01032e7:	79 15                	jns    f01032fe <env_create+0x36>
                panic("env_alloc: %e", status);
f01032e9:	50                   	push   %eax
f01032ea:	68 6e 78 10 f0       	push   $0xf010786e
f01032ef:	68 9c 01 00 00       	push   $0x19c
f01032f4:	68 63 78 10 f0       	push   $0xf0107863
f01032f9:	e8 42 cd ff ff       	call   f0100040 <_panic>

        // If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.        
        if (type == ENV_TYPE_FS) {
f01032fe:	83 fb 01             	cmp    $0x1,%ebx
f0103301:	75 0a                	jne    f010330d <env_create+0x45>
                env->env_tf.tf_eflags |= FL_IOPL_3;
f0103303:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103306:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
        }

        env->env_type = type;
f010330d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103310:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103313:	89 58 50             	mov    %ebx,0x50(%eax)
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
        struct Elf *elf = (struct Elf *) binary;
        
        if (elf->e_magic != ELF_MAGIC)
f0103316:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f010331c:	74 17                	je     f0103335 <env_create+0x6d>
                panic("load_icode: binary isn't elf (invalid magic)");
f010331e:	83 ec 04             	sub    $0x4,%esp
f0103321:	68 10 78 10 f0       	push   $0xf0107810
f0103326:	68 71 01 00 00       	push   $0x171
f010332b:	68 63 78 10 f0       	push   $0xf0107863
f0103330:	e8 0b cd ff ff       	call   f0100040 <_panic>
       
        // We could do a bunch more checks here (for e_phnum and such) but let's not.

        struct Proghdr *pht = (struct Proghdr *) (binary + elf->e_phoff); 
f0103335:	89 f7                	mov    %esi,%edi
f0103337:	03 7e 1c             	add    0x1c(%esi),%edi
     
        lcr3(PADDR(e->env_pgdir));
f010333a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010333d:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103340:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103345:	77 15                	ja     f010335c <env_create+0x94>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103347:	50                   	push   %eax
f0103348:	68 c8 65 10 f0       	push   $0xf01065c8
f010334d:	68 77 01 00 00       	push   $0x177
f0103352:	68 63 78 10 f0       	push   $0xf0107863
f0103357:	e8 e4 cc ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010335c:	05 00 00 00 10       	add    $0x10000000,%eax
f0103361:	0f 22 d8             	mov    %eax,%cr3

        struct Proghdr *phdr;
        for (phdr = pht; phdr < pht + elf->e_phnum; phdr++) {
f0103364:	89 fb                	mov    %edi,%ebx
f0103366:	eb 60                	jmp    f01033c8 <env_create+0x100>
                if (phdr->p_type != ELF_PROG_LOAD)
f0103368:	83 3b 01             	cmpl   $0x1,(%ebx)
f010336b:	75 58                	jne    f01033c5 <env_create+0xfd>
                        continue;

                if (phdr->p_filesz > phdr->p_memsz)
f010336d:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103370:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0103373:	76 17                	jbe    f010338c <env_create+0xc4>
                        panic("load_icode: segment filesz > memsz");
f0103375:	83 ec 04             	sub    $0x4,%esp
f0103378:	68 40 78 10 f0       	push   $0xf0107840
f010337d:	68 7f 01 00 00       	push   $0x17f
f0103382:	68 63 78 10 f0       	push   $0xf0107863
f0103387:	e8 b4 cc ff ff       	call   f0100040 <_panic>

                region_alloc(e, (void *) phdr->p_va, phdr->p_memsz);
f010338c:	8b 53 08             	mov    0x8(%ebx),%edx
f010338f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103392:	e8 28 fc ff ff       	call   f0102fbf <region_alloc>
                memcpy((void *) phdr->p_va, binary + phdr->p_offset, phdr->p_filesz); 
f0103397:	83 ec 04             	sub    $0x4,%esp
f010339a:	ff 73 10             	pushl  0x10(%ebx)
f010339d:	89 f0                	mov    %esi,%eax
f010339f:	03 43 04             	add    0x4(%ebx),%eax
f01033a2:	50                   	push   %eax
f01033a3:	ff 73 08             	pushl  0x8(%ebx)
f01033a6:	e8 c1 25 00 00       	call   f010596c <memcpy>
                memset((void *) (phdr->p_va + phdr->p_filesz), 0, phdr->p_memsz - phdr->p_filesz);
f01033ab:	8b 43 10             	mov    0x10(%ebx),%eax
f01033ae:	83 c4 0c             	add    $0xc,%esp
f01033b1:	8b 53 14             	mov    0x14(%ebx),%edx
f01033b4:	29 c2                	sub    %eax,%edx
f01033b6:	52                   	push   %edx
f01033b7:	6a 00                	push   $0x0
f01033b9:	03 43 08             	add    0x8(%ebx),%eax
f01033bc:	50                   	push   %eax
f01033bd:	e8 f5 24 00 00       	call   f01058b7 <memset>
f01033c2:	83 c4 10             	add    $0x10,%esp
        struct Proghdr *pht = (struct Proghdr *) (binary + elf->e_phoff); 
     
        lcr3(PADDR(e->env_pgdir));

        struct Proghdr *phdr;
        for (phdr = pht; phdr < pht + elf->e_phnum; phdr++) {
f01033c5:	83 c3 20             	add    $0x20,%ebx
f01033c8:	0f b7 46 2c          	movzwl 0x2c(%esi),%eax
f01033cc:	c1 e0 05             	shl    $0x5,%eax
f01033cf:	01 f8                	add    %edi,%eax
f01033d1:	39 c3                	cmp    %eax,%ebx
f01033d3:	72 93                	jb     f0103368 <env_create+0xa0>
                memset((void *) (phdr->p_va + phdr->p_filesz), 0, phdr->p_memsz - phdr->p_filesz);
        }

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
        region_alloc(e, (void *) (USTACKTOP - PGSIZE), PGSIZE);
f01033d5:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01033da:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01033df:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01033e2:	89 f8                	mov    %edi,%eax
f01033e4:	e8 d6 fb ff ff       	call   f0102fbf <region_alloc>

	// LAB 3: Your code here.
        e->env_tf.tf_eip = elf->e_entry;
f01033e9:	8b 46 18             	mov    0x18(%esi),%eax
f01033ec:	89 47 30             	mov    %eax,0x30(%edi)
                env->env_tf.tf_eflags |= FL_IOPL_3;
        }

        env->env_type = type;
        load_icode(env, binary);
}
f01033ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033f2:	5b                   	pop    %ebx
f01033f3:	5e                   	pop    %esi
f01033f4:	5f                   	pop    %edi
f01033f5:	5d                   	pop    %ebp
f01033f6:	c3                   	ret    

f01033f7 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01033f7:	55                   	push   %ebp
f01033f8:	89 e5                	mov    %esp,%ebp
f01033fa:	57                   	push   %edi
f01033fb:	56                   	push   %esi
f01033fc:	53                   	push   %ebx
f01033fd:	83 ec 1c             	sub    $0x1c,%esp
f0103400:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103403:	e8 d2 2a 00 00       	call   f0105eda <cpunum>
f0103408:	6b c0 74             	imul   $0x74,%eax,%eax
f010340b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103412:	39 b8 28 20 21 f0    	cmp    %edi,-0xfdedfd8(%eax)
f0103418:	75 30                	jne    f010344a <env_free+0x53>
		lcr3(PADDR(kern_pgdir));
f010341a:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010341f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103424:	77 15                	ja     f010343b <env_free+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103426:	50                   	push   %eax
f0103427:	68 c8 65 10 f0       	push   $0xf01065c8
f010342c:	68 b6 01 00 00       	push   $0x1b6
f0103431:	68 63 78 10 f0       	push   $0xf0107863
f0103436:	e8 05 cc ff ff       	call   f0100040 <_panic>
f010343b:	05 00 00 00 10       	add    $0x10000000,%eax
f0103440:	0f 22 d8             	mov    %eax,%cr3
f0103443:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010344a:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010344d:	89 d0                	mov    %edx,%eax
f010344f:	c1 e0 02             	shl    $0x2,%eax
f0103452:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103455:	8b 47 60             	mov    0x60(%edi),%eax
f0103458:	8b 34 90             	mov    (%eax,%edx,4),%esi
f010345b:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103461:	0f 84 a8 00 00 00    	je     f010350f <env_free+0x118>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103467:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010346d:	89 f0                	mov    %esi,%eax
f010346f:	c1 e8 0c             	shr    $0xc,%eax
f0103472:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103475:	39 05 88 1e 21 f0    	cmp    %eax,0xf0211e88
f010347b:	77 15                	ja     f0103492 <env_free+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010347d:	56                   	push   %esi
f010347e:	68 a4 65 10 f0       	push   $0xf01065a4
f0103483:	68 c5 01 00 00       	push   $0x1c5
f0103488:	68 63 78 10 f0       	push   $0xf0107863
f010348d:	e8 ae cb ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103492:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103495:	c1 e0 16             	shl    $0x16,%eax
f0103498:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010349b:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01034a0:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01034a7:	01 
f01034a8:	74 17                	je     f01034c1 <env_free+0xca>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01034aa:	83 ec 08             	sub    $0x8,%esp
f01034ad:	89 d8                	mov    %ebx,%eax
f01034af:	c1 e0 0c             	shl    $0xc,%eax
f01034b2:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01034b5:	50                   	push   %eax
f01034b6:	ff 77 60             	pushl  0x60(%edi)
f01034b9:	e8 23 de ff ff       	call   f01012e1 <page_remove>
f01034be:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01034c1:	83 c3 01             	add    $0x1,%ebx
f01034c4:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01034ca:	75 d4                	jne    f01034a0 <env_free+0xa9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01034cc:	8b 47 60             	mov    0x60(%edi),%eax
f01034cf:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01034d2:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01034d9:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01034dc:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f01034e2:	72 14                	jb     f01034f8 <env_free+0x101>
		panic("pa2page called with invalid pa");
f01034e4:	83 ec 04             	sub    $0x4,%esp
f01034e7:	68 10 6c 10 f0       	push   $0xf0106c10
f01034ec:	6a 51                	push   $0x51
f01034ee:	68 7d 74 10 f0       	push   $0xf010747d
f01034f3:	e8 48 cb ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f01034f8:	83 ec 0c             	sub    $0xc,%esp
f01034fb:	a1 90 1e 21 f0       	mov    0xf0211e90,%eax
f0103500:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103503:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103506:	50                   	push   %eax
f0103507:	e8 74 db ff ff       	call   f0101080 <page_decref>
f010350c:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010350f:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103513:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103516:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f010351b:	0f 85 29 ff ff ff    	jne    f010344a <env_free+0x53>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103521:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103524:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103529:	77 15                	ja     f0103540 <env_free+0x149>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010352b:	50                   	push   %eax
f010352c:	68 c8 65 10 f0       	push   $0xf01065c8
f0103531:	68 d3 01 00 00       	push   $0x1d3
f0103536:	68 63 78 10 f0       	push   $0xf0107863
f010353b:	e8 00 cb ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103540:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103547:	05 00 00 00 10       	add    $0x10000000,%eax
f010354c:	c1 e8 0c             	shr    $0xc,%eax
f010354f:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f0103555:	72 14                	jb     f010356b <env_free+0x174>
		panic("pa2page called with invalid pa");
f0103557:	83 ec 04             	sub    $0x4,%esp
f010355a:	68 10 6c 10 f0       	push   $0xf0106c10
f010355f:	6a 51                	push   $0x51
f0103561:	68 7d 74 10 f0       	push   $0xf010747d
f0103566:	e8 d5 ca ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f010356b:	83 ec 0c             	sub    $0xc,%esp
f010356e:	8b 15 90 1e 21 f0    	mov    0xf0211e90,%edx
f0103574:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103577:	50                   	push   %eax
f0103578:	e8 03 db ff ff       	call   f0101080 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010357d:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103584:	a1 4c 12 21 f0       	mov    0xf021124c,%eax
f0103589:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f010358c:	89 3d 4c 12 21 f0    	mov    %edi,0xf021124c
}
f0103592:	83 c4 10             	add    $0x10,%esp
f0103595:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103598:	5b                   	pop    %ebx
f0103599:	5e                   	pop    %esi
f010359a:	5f                   	pop    %edi
f010359b:	5d                   	pop    %ebp
f010359c:	c3                   	ret    

f010359d <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f010359d:	55                   	push   %ebp
f010359e:	89 e5                	mov    %esp,%ebp
f01035a0:	53                   	push   %ebx
f01035a1:	83 ec 04             	sub    $0x4,%esp
f01035a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01035a7:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01035ab:	75 19                	jne    f01035c6 <env_destroy+0x29>
f01035ad:	e8 28 29 00 00       	call   f0105eda <cpunum>
f01035b2:	6b c0 74             	imul   $0x74,%eax,%eax
f01035b5:	3b 98 28 20 21 f0    	cmp    -0xfdedfd8(%eax),%ebx
f01035bb:	74 09                	je     f01035c6 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f01035bd:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01035c4:	eb 33                	jmp    f01035f9 <env_destroy+0x5c>
	}

	env_free(e);
f01035c6:	83 ec 0c             	sub    $0xc,%esp
f01035c9:	53                   	push   %ebx
f01035ca:	e8 28 fe ff ff       	call   f01033f7 <env_free>

	if (curenv == e) {
f01035cf:	e8 06 29 00 00       	call   f0105eda <cpunum>
f01035d4:	6b c0 74             	imul   $0x74,%eax,%eax
f01035d7:	83 c4 10             	add    $0x10,%esp
f01035da:	3b 98 28 20 21 f0    	cmp    -0xfdedfd8(%eax),%ebx
f01035e0:	75 17                	jne    f01035f9 <env_destroy+0x5c>
		curenv = NULL;
f01035e2:	e8 f3 28 00 00       	call   f0105eda <cpunum>
f01035e7:	6b c0 74             	imul   $0x74,%eax,%eax
f01035ea:	c7 80 28 20 21 f0 00 	movl   $0x0,-0xfdedfd8(%eax)
f01035f1:	00 00 00 
		sched_yield();
f01035f4:	e8 f7 10 00 00       	call   f01046f0 <sched_yield>
	}
}
f01035f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01035fc:	c9                   	leave  
f01035fd:	c3                   	ret    

f01035fe <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01035fe:	55                   	push   %ebp
f01035ff:	89 e5                	mov    %esp,%ebp
f0103601:	53                   	push   %ebx
f0103602:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103605:	e8 d0 28 00 00       	call   f0105eda <cpunum>
f010360a:	6b c0 74             	imul   $0x74,%eax,%eax
f010360d:	8b 98 28 20 21 f0    	mov    -0xfdedfd8(%eax),%ebx
f0103613:	e8 c2 28 00 00       	call   f0105eda <cpunum>
f0103618:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f010361b:	8b 65 08             	mov    0x8(%ebp),%esp
f010361e:	61                   	popa   
f010361f:	07                   	pop    %es
f0103620:	1f                   	pop    %ds
f0103621:	83 c4 08             	add    $0x8,%esp
f0103624:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103625:	83 ec 04             	sub    $0x4,%esp
f0103628:	68 7c 78 10 f0       	push   $0xf010787c
f010362d:	68 0a 02 00 00       	push   $0x20a
f0103632:	68 63 78 10 f0       	push   $0xf0107863
f0103637:	e8 04 ca ff ff       	call   f0100040 <_panic>

f010363c <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f010363c:	55                   	push   %ebp
f010363d:	89 e5                	mov    %esp,%ebp
f010363f:	83 ec 08             	sub    $0x8,%esp
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
        //
        // First call to env_run
        if ((curenv != NULL) && (curenv->env_status == ENV_RUNNING))
f0103642:	e8 93 28 00 00       	call   f0105eda <cpunum>
f0103647:	6b c0 74             	imul   $0x74,%eax,%eax
f010364a:	83 b8 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%eax)
f0103651:	74 29                	je     f010367c <env_run+0x40>
f0103653:	e8 82 28 00 00       	call   f0105eda <cpunum>
f0103658:	6b c0 74             	imul   $0x74,%eax,%eax
f010365b:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103661:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103665:	75 15                	jne    f010367c <env_run+0x40>
                curenv->env_status = ENV_RUNNABLE;
f0103667:	e8 6e 28 00 00       	call   f0105eda <cpunum>
f010366c:	6b c0 74             	imul   $0x74,%eax,%eax
f010366f:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103675:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)

        curenv = e;
f010367c:	e8 59 28 00 00       	call   f0105eda <cpunum>
f0103681:	6b c0 74             	imul   $0x74,%eax,%eax
f0103684:	8b 55 08             	mov    0x8(%ebp),%edx
f0103687:	89 90 28 20 21 f0    	mov    %edx,-0xfdedfd8(%eax)
        curenv->env_status = ENV_RUNNING;
f010368d:	e8 48 28 00 00       	call   f0105eda <cpunum>
f0103692:	6b c0 74             	imul   $0x74,%eax,%eax
f0103695:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f010369b:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
        curenv->env_runs++;
f01036a2:	e8 33 28 00 00       	call   f0105eda <cpunum>
f01036a7:	6b c0 74             	imul   $0x74,%eax,%eax
f01036aa:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01036b0:	83 40 58 01          	addl   $0x1,0x58(%eax)

        lcr3(PADDR(curenv->env_pgdir));
f01036b4:	e8 21 28 00 00       	call   f0105eda <cpunum>
f01036b9:	6b c0 74             	imul   $0x74,%eax,%eax
f01036bc:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01036c2:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01036c5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036ca:	77 15                	ja     f01036e1 <env_run+0xa5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036cc:	50                   	push   %eax
f01036cd:	68 c8 65 10 f0       	push   $0xf01065c8
f01036d2:	68 31 02 00 00       	push   $0x231
f01036d7:	68 63 78 10 f0       	push   $0xf0107863
f01036dc:	e8 5f c9 ff ff       	call   f0100040 <_panic>
f01036e1:	05 00 00 00 10       	add    $0x10000000,%eax
f01036e6:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01036e9:	83 ec 0c             	sub    $0xc,%esp
f01036ec:	68 c0 03 12 f0       	push   $0xf01203c0
f01036f1:	e8 ef 2a 00 00       	call   f01061e5 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01036f6:	f3 90                	pause  

        unlock_kernel();
        env_pop_tf(&curenv->env_tf);
f01036f8:	e8 dd 27 00 00       	call   f0105eda <cpunum>
f01036fd:	83 c4 04             	add    $0x4,%esp
f0103700:	6b c0 74             	imul   $0x74,%eax,%eax
f0103703:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0103709:	e8 f0 fe ff ff       	call   f01035fe <env_pop_tf>

f010370e <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f010370e:	55                   	push   %ebp
f010370f:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103711:	ba 70 00 00 00       	mov    $0x70,%edx
f0103716:	8b 45 08             	mov    0x8(%ebp),%eax
f0103719:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010371a:	ba 71 00 00 00       	mov    $0x71,%edx
f010371f:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103720:	0f b6 c0             	movzbl %al,%eax
}
f0103723:	5d                   	pop    %ebp
f0103724:	c3                   	ret    

f0103725 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103725:	55                   	push   %ebp
f0103726:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103728:	ba 70 00 00 00       	mov    $0x70,%edx
f010372d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103730:	ee                   	out    %al,(%dx)
f0103731:	ba 71 00 00 00       	mov    $0x71,%edx
f0103736:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103739:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010373a:	5d                   	pop    %ebp
f010373b:	c3                   	ret    

f010373c <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f010373c:	55                   	push   %ebp
f010373d:	89 e5                	mov    %esp,%ebp
f010373f:	56                   	push   %esi
f0103740:	53                   	push   %ebx
f0103741:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103744:	66 a3 a8 03 12 f0    	mov    %ax,0xf01203a8
	if (!didinit)
f010374a:	80 3d 50 12 21 f0 00 	cmpb   $0x0,0xf0211250
f0103751:	74 5a                	je     f01037ad <irq_setmask_8259A+0x71>
f0103753:	89 c6                	mov    %eax,%esi
f0103755:	ba 21 00 00 00       	mov    $0x21,%edx
f010375a:	ee                   	out    %al,(%dx)
f010375b:	66 c1 e8 08          	shr    $0x8,%ax
f010375f:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103764:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0103765:	83 ec 0c             	sub    $0xc,%esp
f0103768:	68 88 78 10 f0       	push   $0xf0107888
f010376d:	e8 1b 01 00 00       	call   f010388d <cprintf>
f0103772:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103775:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f010377a:	0f b7 f6             	movzwl %si,%esi
f010377d:	f7 d6                	not    %esi
f010377f:	0f a3 de             	bt     %ebx,%esi
f0103782:	73 11                	jae    f0103795 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f0103784:	83 ec 08             	sub    $0x8,%esp
f0103787:	53                   	push   %ebx
f0103788:	68 5f 7d 10 f0       	push   $0xf0107d5f
f010378d:	e8 fb 00 00 00       	call   f010388d <cprintf>
f0103792:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103795:	83 c3 01             	add    $0x1,%ebx
f0103798:	83 fb 10             	cmp    $0x10,%ebx
f010379b:	75 e2                	jne    f010377f <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f010379d:	83 ec 0c             	sub    $0xc,%esp
f01037a0:	68 8b 77 10 f0       	push   $0xf010778b
f01037a5:	e8 e3 00 00 00       	call   f010388d <cprintf>
f01037aa:	83 c4 10             	add    $0x10,%esp
}
f01037ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01037b0:	5b                   	pop    %ebx
f01037b1:	5e                   	pop    %esi
f01037b2:	5d                   	pop    %ebp
f01037b3:	c3                   	ret    

f01037b4 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f01037b4:	c6 05 50 12 21 f0 01 	movb   $0x1,0xf0211250
f01037bb:	ba 21 00 00 00       	mov    $0x21,%edx
f01037c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01037c5:	ee                   	out    %al,(%dx)
f01037c6:	ba a1 00 00 00       	mov    $0xa1,%edx
f01037cb:	ee                   	out    %al,(%dx)
f01037cc:	ba 20 00 00 00       	mov    $0x20,%edx
f01037d1:	b8 11 00 00 00       	mov    $0x11,%eax
f01037d6:	ee                   	out    %al,(%dx)
f01037d7:	ba 21 00 00 00       	mov    $0x21,%edx
f01037dc:	b8 20 00 00 00       	mov    $0x20,%eax
f01037e1:	ee                   	out    %al,(%dx)
f01037e2:	b8 04 00 00 00       	mov    $0x4,%eax
f01037e7:	ee                   	out    %al,(%dx)
f01037e8:	b8 03 00 00 00       	mov    $0x3,%eax
f01037ed:	ee                   	out    %al,(%dx)
f01037ee:	ba a0 00 00 00       	mov    $0xa0,%edx
f01037f3:	b8 11 00 00 00       	mov    $0x11,%eax
f01037f8:	ee                   	out    %al,(%dx)
f01037f9:	ba a1 00 00 00       	mov    $0xa1,%edx
f01037fe:	b8 28 00 00 00       	mov    $0x28,%eax
f0103803:	ee                   	out    %al,(%dx)
f0103804:	b8 02 00 00 00       	mov    $0x2,%eax
f0103809:	ee                   	out    %al,(%dx)
f010380a:	b8 01 00 00 00       	mov    $0x1,%eax
f010380f:	ee                   	out    %al,(%dx)
f0103810:	ba 20 00 00 00       	mov    $0x20,%edx
f0103815:	b8 68 00 00 00       	mov    $0x68,%eax
f010381a:	ee                   	out    %al,(%dx)
f010381b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103820:	ee                   	out    %al,(%dx)
f0103821:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103826:	b8 68 00 00 00       	mov    $0x68,%eax
f010382b:	ee                   	out    %al,(%dx)
f010382c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103831:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103832:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f0103839:	66 83 f8 ff          	cmp    $0xffff,%ax
f010383d:	74 13                	je     f0103852 <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f010383f:	55                   	push   %ebp
f0103840:	89 e5                	mov    %esp,%ebp
f0103842:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103845:	0f b7 c0             	movzwl %ax,%eax
f0103848:	50                   	push   %eax
f0103849:	e8 ee fe ff ff       	call   f010373c <irq_setmask_8259A>
f010384e:	83 c4 10             	add    $0x10,%esp
}
f0103851:	c9                   	leave  
f0103852:	f3 c3                	repz ret 

f0103854 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103854:	55                   	push   %ebp
f0103855:	89 e5                	mov    %esp,%ebp
f0103857:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010385a:	ff 75 08             	pushl  0x8(%ebp)
f010385d:	e8 37 cf ff ff       	call   f0100799 <cputchar>
	*cnt++;
}
f0103862:	83 c4 10             	add    $0x10,%esp
f0103865:	c9                   	leave  
f0103866:	c3                   	ret    

f0103867 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103867:	55                   	push   %ebp
f0103868:	89 e5                	mov    %esp,%ebp
f010386a:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010386d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103874:	ff 75 0c             	pushl  0xc(%ebp)
f0103877:	ff 75 08             	pushl  0x8(%ebp)
f010387a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010387d:	50                   	push   %eax
f010387e:	68 54 38 10 f0       	push   $0xf0103854
f0103883:	e8 ab 19 00 00       	call   f0105233 <vprintfmt>
	return cnt;
}
f0103888:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010388b:	c9                   	leave  
f010388c:	c3                   	ret    

f010388d <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010388d:	55                   	push   %ebp
f010388e:	89 e5                	mov    %esp,%ebp
f0103890:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103893:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103896:	50                   	push   %eax
f0103897:	ff 75 08             	pushl  0x8(%ebp)
f010389a:	e8 c8 ff ff ff       	call   f0103867 <vcprintf>
	va_end(ap);

	return cnt;
}
f010389f:	c9                   	leave  
f01038a0:	c3                   	ret    

f01038a1 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01038a1:	55                   	push   %ebp
f01038a2:	89 e5                	mov    %esp,%ebp
f01038a4:	57                   	push   %edi
f01038a5:	56                   	push   %esi
f01038a6:	53                   	push   %ebx
f01038a7:	83 ec 1c             	sub    $0x1c,%esp
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:

	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - (thiscpu->cpu_id * (KSTKSIZE + KSTKGAP));
f01038aa:	e8 2b 26 00 00       	call   f0105eda <cpunum>
f01038af:	89 c3                	mov    %eax,%ebx
f01038b1:	e8 24 26 00 00       	call   f0105eda <cpunum>
f01038b6:	6b d3 74             	imul   $0x74,%ebx,%edx
f01038b9:	6b c0 74             	imul   $0x74,%eax,%eax
f01038bc:	0f b6 88 20 20 21 f0 	movzbl -0xfdedfe0(%eax),%ecx
f01038c3:	c1 e1 10             	shl    $0x10,%ecx
f01038c6:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
f01038cb:	29 c8                	sub    %ecx,%eax
f01038cd:	89 82 30 20 21 f0    	mov    %eax,-0xfdedfd0(%edx)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f01038d3:	e8 02 26 00 00       	call   f0105eda <cpunum>
f01038d8:	6b c0 74             	imul   $0x74,%eax,%eax
f01038db:	66 c7 80 34 20 21 f0 	movw   $0x10,-0xfdedfcc(%eax)
f01038e2:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f01038e4:	e8 f1 25 00 00       	call   f0105eda <cpunum>
f01038e9:	6b c0 74             	imul   $0x74,%eax,%eax
f01038ec:	66 c7 80 92 20 21 f0 	movw   $0x68,-0xfdedf6e(%eax)
f01038f3:	68 00 

	uint32_t curr_cpu_gdt_index = GD_TSS0 + ((thiscpu->cpu_id + 1) * 8);
f01038f5:	e8 e0 25 00 00       	call   f0105eda <cpunum>
f01038fa:	6b c0 74             	imul   $0x74,%eax,%eax
f01038fd:	0f b6 80 20 20 21 f0 	movzbl -0xfdedfe0(%eax),%eax
f0103904:	8d 3c c5 30 00 00 00 	lea    0x30(,%eax,8),%edi

	gdt[curr_cpu_gdt_index >> 3] = SEG16
f010390b:	89 fb                	mov    %edi,%ebx
f010390d:	c1 eb 03             	shr    $0x3,%ebx
f0103910:	e8 c5 25 00 00       	call   f0105eda <cpunum>
f0103915:	89 c6                	mov    %eax,%esi
f0103917:	e8 be 25 00 00       	call   f0105eda <cpunum>
f010391c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010391f:	e8 b6 25 00 00       	call   f0105eda <cpunum>
f0103924:	66 c7 04 dd 40 03 12 	movw   $0x67,-0xfedfcc0(,%ebx,8)
f010392b:	f0 67 00 
f010392e:	6b f6 74             	imul   $0x74,%esi,%esi
f0103931:	81 c6 2c 20 21 f0    	add    $0xf021202c,%esi
f0103937:	66 89 34 dd 42 03 12 	mov    %si,-0xfedfcbe(,%ebx,8)
f010393e:	f0 
f010393f:	6b 55 e4 74          	imul   $0x74,-0x1c(%ebp),%edx
f0103943:	81 c2 2c 20 21 f0    	add    $0xf021202c,%edx
f0103949:	c1 ea 10             	shr    $0x10,%edx
f010394c:	88 14 dd 44 03 12 f0 	mov    %dl,-0xfedfcbc(,%ebx,8)
f0103953:	c6 04 dd 46 03 12 f0 	movb   $0x40,-0xfedfcba(,%ebx,8)
f010395a:	40 
f010395b:	6b c0 74             	imul   $0x74,%eax,%eax
f010395e:	05 2c 20 21 f0       	add    $0xf021202c,%eax
f0103963:	c1 e8 18             	shr    $0x18,%eax
f0103966:	88 04 dd 47 03 12 f0 	mov    %al,-0xfedfcb9(,%ebx,8)
	(STS_T32A, (uint32_t) (&thiscpu->cpu_ts), sizeof(struct Taskstate) - 1, 0);
	gdt[curr_cpu_gdt_index >> 3].sd_s = 0;
f010396d:	c6 04 dd 45 03 12 f0 	movb   $0x89,-0xfedfcbb(,%ebx,8)
f0103974:	89 
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0103975:	0f 00 df             	ltr    %di
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f0103978:	b8 ac 03 12 f0       	mov    $0xf01203ac,%eax
f010397d:	0f 01 18             	lidtl  (%eax)
	
	ltr(curr_cpu_gdt_index);

	// Load the IDT
	lidt(&idt_pd);
}
f0103980:	83 c4 1c             	add    $0x1c,%esp
f0103983:	5b                   	pop    %ebx
f0103984:	5e                   	pop    %esi
f0103985:	5f                   	pop    %edi
f0103986:	5d                   	pop    %ebp
f0103987:	c3                   	ret    

f0103988 <trap_init>:
}


void
trap_init(void)
{
f0103988:	55                   	push   %ebp
f0103989:	89 e5                	mov    %esp,%ebp
f010398b:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.

	extern void TH_DIVIDE(); 	SETGATE(idt[T_DIVIDE], 0, GD_KT, TH_DIVIDE, 							0); 
f010398e:	b8 08 45 10 f0       	mov    $0xf0104508,%eax
f0103993:	66 a3 60 12 21 f0    	mov    %ax,0xf0211260
f0103999:	66 c7 05 62 12 21 f0 	movw   $0x8,0xf0211262
f01039a0:	08 00 
f01039a2:	c6 05 64 12 21 f0 00 	movb   $0x0,0xf0211264
f01039a9:	c6 05 65 12 21 f0 8e 	movb   $0x8e,0xf0211265
f01039b0:	c1 e8 10             	shr    $0x10,%eax
f01039b3:	66 a3 66 12 21 f0    	mov    %ax,0xf0211266
	extern void TH_DEBUG(); 	SETGATE(idt[T_DEBUG], 0, GD_KT, TH_DEBUG, 0); 
f01039b9:	b8 12 45 10 f0       	mov    $0xf0104512,%eax
f01039be:	66 a3 68 12 21 f0    	mov    %ax,0xf0211268
f01039c4:	66 c7 05 6a 12 21 f0 	movw   $0x8,0xf021126a
f01039cb:	08 00 
f01039cd:	c6 05 6c 12 21 f0 00 	movb   $0x0,0xf021126c
f01039d4:	c6 05 6d 12 21 f0 8e 	movb   $0x8e,0xf021126d
f01039db:	c1 e8 10             	shr    $0x10,%eax
f01039de:	66 a3 6e 12 21 f0    	mov    %ax,0xf021126e
	extern void TH_NMI(); 		SETGATE(idt[T_NMI], 0, GD_KT, TH_NMI, 0); 
f01039e4:	b8 1c 45 10 f0       	mov    $0xf010451c,%eax
f01039e9:	66 a3 70 12 21 f0    	mov    %ax,0xf0211270
f01039ef:	66 c7 05 72 12 21 f0 	movw   $0x8,0xf0211272
f01039f6:	08 00 
f01039f8:	c6 05 74 12 21 f0 00 	movb   $0x0,0xf0211274
f01039ff:	c6 05 75 12 21 f0 8e 	movb   $0x8e,0xf0211275
f0103a06:	c1 e8 10             	shr    $0x10,%eax
f0103a09:	66 a3 76 12 21 f0    	mov    %ax,0xf0211276
	extern void TH_BRKPT(); 	SETGATE(idt[T_BRKPT], 0, GD_KT, TH_BRKPT, 3); 
f0103a0f:	b8 26 45 10 f0       	mov    $0xf0104526,%eax
f0103a14:	66 a3 78 12 21 f0    	mov    %ax,0xf0211278
f0103a1a:	66 c7 05 7a 12 21 f0 	movw   $0x8,0xf021127a
f0103a21:	08 00 
f0103a23:	c6 05 7c 12 21 f0 00 	movb   $0x0,0xf021127c
f0103a2a:	c6 05 7d 12 21 f0 ee 	movb   $0xee,0xf021127d
f0103a31:	c1 e8 10             	shr    $0x10,%eax
f0103a34:	66 a3 7e 12 21 f0    	mov    %ax,0xf021127e
	extern void TH_OFLOW(); 	SETGATE(idt[T_OFLOW], 0, GD_KT, TH_OFLOW, 0); 
f0103a3a:	b8 30 45 10 f0       	mov    $0xf0104530,%eax
f0103a3f:	66 a3 80 12 21 f0    	mov    %ax,0xf0211280
f0103a45:	66 c7 05 82 12 21 f0 	movw   $0x8,0xf0211282
f0103a4c:	08 00 
f0103a4e:	c6 05 84 12 21 f0 00 	movb   $0x0,0xf0211284
f0103a55:	c6 05 85 12 21 f0 8e 	movb   $0x8e,0xf0211285
f0103a5c:	c1 e8 10             	shr    $0x10,%eax
f0103a5f:	66 a3 86 12 21 f0    	mov    %ax,0xf0211286
	extern void TH_BOUND(); 	SETGATE(idt[T_BOUND], 0, GD_KT, TH_BOUND, 0); 
f0103a65:	b8 3a 45 10 f0       	mov    $0xf010453a,%eax
f0103a6a:	66 a3 88 12 21 f0    	mov    %ax,0xf0211288
f0103a70:	66 c7 05 8a 12 21 f0 	movw   $0x8,0xf021128a
f0103a77:	08 00 
f0103a79:	c6 05 8c 12 21 f0 00 	movb   $0x0,0xf021128c
f0103a80:	c6 05 8d 12 21 f0 8e 	movb   $0x8e,0xf021128d
f0103a87:	c1 e8 10             	shr    $0x10,%eax
f0103a8a:	66 a3 8e 12 21 f0    	mov    %ax,0xf021128e
	extern void TH_ILLOP(); 	SETGATE(idt[T_ILLOP], 0, GD_KT, TH_ILLOP, 0); 
f0103a90:	b8 44 45 10 f0       	mov    $0xf0104544,%eax
f0103a95:	66 a3 90 12 21 f0    	mov    %ax,0xf0211290
f0103a9b:	66 c7 05 92 12 21 f0 	movw   $0x8,0xf0211292
f0103aa2:	08 00 
f0103aa4:	c6 05 94 12 21 f0 00 	movb   $0x0,0xf0211294
f0103aab:	c6 05 95 12 21 f0 8e 	movb   $0x8e,0xf0211295
f0103ab2:	c1 e8 10             	shr    $0x10,%eax
f0103ab5:	66 a3 96 12 21 f0    	mov    %ax,0xf0211296
	extern void TH_DEVICE(); 	SETGATE(idt[T_DEVICE], 0, GD_KT, TH_DEVICE, 							0); 
f0103abb:	b8 4e 45 10 f0       	mov    $0xf010454e,%eax
f0103ac0:	66 a3 98 12 21 f0    	mov    %ax,0xf0211298
f0103ac6:	66 c7 05 9a 12 21 f0 	movw   $0x8,0xf021129a
f0103acd:	08 00 
f0103acf:	c6 05 9c 12 21 f0 00 	movb   $0x0,0xf021129c
f0103ad6:	c6 05 9d 12 21 f0 8e 	movb   $0x8e,0xf021129d
f0103add:	c1 e8 10             	shr    $0x10,%eax
f0103ae0:	66 a3 9e 12 21 f0    	mov    %ax,0xf021129e
	extern void TH_DBLFLT(); 	SETGATE(idt[T_DBLFLT], 0, GD_KT, TH_DBLFLT, 							0); 
f0103ae6:	b8 58 45 10 f0       	mov    $0xf0104558,%eax
f0103aeb:	66 a3 a0 12 21 f0    	mov    %ax,0xf02112a0
f0103af1:	66 c7 05 a2 12 21 f0 	movw   $0x8,0xf02112a2
f0103af8:	08 00 
f0103afa:	c6 05 a4 12 21 f0 00 	movb   $0x0,0xf02112a4
f0103b01:	c6 05 a5 12 21 f0 8e 	movb   $0x8e,0xf02112a5
f0103b08:	c1 e8 10             	shr    $0x10,%eax
f0103b0b:	66 a3 a6 12 21 f0    	mov    %ax,0xf02112a6
	extern void TH_TSS(); 		SETGATE(idt[T_TSS], 0, GD_KT, TH_TSS, 0); 
f0103b11:	b8 60 45 10 f0       	mov    $0xf0104560,%eax
f0103b16:	66 a3 b0 12 21 f0    	mov    %ax,0xf02112b0
f0103b1c:	66 c7 05 b2 12 21 f0 	movw   $0x8,0xf02112b2
f0103b23:	08 00 
f0103b25:	c6 05 b4 12 21 f0 00 	movb   $0x0,0xf02112b4
f0103b2c:	c6 05 b5 12 21 f0 8e 	movb   $0x8e,0xf02112b5
f0103b33:	c1 e8 10             	shr    $0x10,%eax
f0103b36:	66 a3 b6 12 21 f0    	mov    %ax,0xf02112b6
	extern void TH_SEGNP(); 	SETGATE(idt[T_SEGNP], 0, GD_KT, TH_SEGNP, 0); 
f0103b3c:	b8 68 45 10 f0       	mov    $0xf0104568,%eax
f0103b41:	66 a3 b8 12 21 f0    	mov    %ax,0xf02112b8
f0103b47:	66 c7 05 ba 12 21 f0 	movw   $0x8,0xf02112ba
f0103b4e:	08 00 
f0103b50:	c6 05 bc 12 21 f0 00 	movb   $0x0,0xf02112bc
f0103b57:	c6 05 bd 12 21 f0 8e 	movb   $0x8e,0xf02112bd
f0103b5e:	c1 e8 10             	shr    $0x10,%eax
f0103b61:	66 a3 be 12 21 f0    	mov    %ax,0xf02112be
	extern void TH_STACK(); 	SETGATE(idt[T_STACK], 0, GD_KT, TH_STACK, 0); 
f0103b67:	b8 70 45 10 f0       	mov    $0xf0104570,%eax
f0103b6c:	66 a3 c0 12 21 f0    	mov    %ax,0xf02112c0
f0103b72:	66 c7 05 c2 12 21 f0 	movw   $0x8,0xf02112c2
f0103b79:	08 00 
f0103b7b:	c6 05 c4 12 21 f0 00 	movb   $0x0,0xf02112c4
f0103b82:	c6 05 c5 12 21 f0 8e 	movb   $0x8e,0xf02112c5
f0103b89:	c1 e8 10             	shr    $0x10,%eax
f0103b8c:	66 a3 c6 12 21 f0    	mov    %ax,0xf02112c6
	extern void TH_GPFLT(); 	SETGATE(idt[T_GPFLT], 0, GD_KT, TH_GPFLT, 0); 
f0103b92:	b8 78 45 10 f0       	mov    $0xf0104578,%eax
f0103b97:	66 a3 c8 12 21 f0    	mov    %ax,0xf02112c8
f0103b9d:	66 c7 05 ca 12 21 f0 	movw   $0x8,0xf02112ca
f0103ba4:	08 00 
f0103ba6:	c6 05 cc 12 21 f0 00 	movb   $0x0,0xf02112cc
f0103bad:	c6 05 cd 12 21 f0 8e 	movb   $0x8e,0xf02112cd
f0103bb4:	c1 e8 10             	shr    $0x10,%eax
f0103bb7:	66 a3 ce 12 21 f0    	mov    %ax,0xf02112ce
	extern void TH_PGFLT(); 	SETGATE(idt[T_PGFLT], 0, GD_KT, TH_PGFLT, 0); 
f0103bbd:	b8 80 45 10 f0       	mov    $0xf0104580,%eax
f0103bc2:	66 a3 d0 12 21 f0    	mov    %ax,0xf02112d0
f0103bc8:	66 c7 05 d2 12 21 f0 	movw   $0x8,0xf02112d2
f0103bcf:	08 00 
f0103bd1:	c6 05 d4 12 21 f0 00 	movb   $0x0,0xf02112d4
f0103bd8:	c6 05 d5 12 21 f0 8e 	movb   $0x8e,0xf02112d5
f0103bdf:	c1 e8 10             	shr    $0x10,%eax
f0103be2:	66 a3 d6 12 21 f0    	mov    %ax,0xf02112d6
	extern void TH_FPERR(); 	SETGATE(idt[T_FPERR], 0, GD_KT, TH_FPERR, 0); 
f0103be8:	b8 88 45 10 f0       	mov    $0xf0104588,%eax
f0103bed:	66 a3 e0 12 21 f0    	mov    %ax,0xf02112e0
f0103bf3:	66 c7 05 e2 12 21 f0 	movw   $0x8,0xf02112e2
f0103bfa:	08 00 
f0103bfc:	c6 05 e4 12 21 f0 00 	movb   $0x0,0xf02112e4
f0103c03:	c6 05 e5 12 21 f0 8e 	movb   $0x8e,0xf02112e5
f0103c0a:	c1 e8 10             	shr    $0x10,%eax
f0103c0d:	66 a3 e6 12 21 f0    	mov    %ax,0xf02112e6
	extern void TH_ALIGN(); 	SETGATE(idt[T_ALIGN], 0, GD_KT, TH_ALIGN, 0); 
f0103c13:	b8 8e 45 10 f0       	mov    $0xf010458e,%eax
f0103c18:	66 a3 e8 12 21 f0    	mov    %ax,0xf02112e8
f0103c1e:	66 c7 05 ea 12 21 f0 	movw   $0x8,0xf02112ea
f0103c25:	08 00 
f0103c27:	c6 05 ec 12 21 f0 00 	movb   $0x0,0xf02112ec
f0103c2e:	c6 05 ed 12 21 f0 8e 	movb   $0x8e,0xf02112ed
f0103c35:	c1 e8 10             	shr    $0x10,%eax
f0103c38:	66 a3 ee 12 21 f0    	mov    %ax,0xf02112ee
	extern void TH_MCHK(); 		SETGATE(idt[T_MCHK], 0, GD_KT, TH_MCHK, 0); 
f0103c3e:	b8 92 45 10 f0       	mov    $0xf0104592,%eax
f0103c43:	66 a3 f0 12 21 f0    	mov    %ax,0xf02112f0
f0103c49:	66 c7 05 f2 12 21 f0 	movw   $0x8,0xf02112f2
f0103c50:	08 00 
f0103c52:	c6 05 f4 12 21 f0 00 	movb   $0x0,0xf02112f4
f0103c59:	c6 05 f5 12 21 f0 8e 	movb   $0x8e,0xf02112f5
f0103c60:	c1 e8 10             	shr    $0x10,%eax
f0103c63:	66 a3 f6 12 21 f0    	mov    %ax,0xf02112f6
	extern void TH_SIMDERR(); 	SETGATE(idt[T_SIMDERR], 0, GD_KT, TH_SIMDERR, 							0); 	// prepisat neskor ako interrupt 
f0103c69:	b8 98 45 10 f0       	mov    $0xf0104598,%eax
f0103c6e:	66 a3 f8 12 21 f0    	mov    %ax,0xf02112f8
f0103c74:	66 c7 05 fa 12 21 f0 	movw   $0x8,0xf02112fa
f0103c7b:	08 00 
f0103c7d:	c6 05 fc 12 21 f0 00 	movb   $0x0,0xf02112fc
f0103c84:	c6 05 fd 12 21 f0 8e 	movb   $0x8e,0xf02112fd
f0103c8b:	c1 e8 10             	shr    $0x10,%eax
f0103c8e:	66 a3 fe 12 21 f0    	mov    %ax,0xf02112fe
							// namiesto trapu (neskor)
	extern void TH_SYSCALL(); 	SETGATE(idt[T_SYSCALL], 0, GD_KT, TH_SYSCALL, 							3); 
f0103c94:	b8 9e 45 10 f0       	mov    $0xf010459e,%eax
f0103c99:	66 a3 e0 13 21 f0    	mov    %ax,0xf02113e0
f0103c9f:	66 c7 05 e2 13 21 f0 	movw   $0x8,0xf02113e2
f0103ca6:	08 00 
f0103ca8:	c6 05 e4 13 21 f0 00 	movb   $0x0,0xf02113e4
f0103caf:	c6 05 e5 13 21 f0 ee 	movb   $0xee,0xf02113e5
f0103cb6:	c1 e8 10             	shr    $0x10,%eax
f0103cb9:	66 a3 e6 13 21 f0    	mov    %ax,0xf02113e6

	extern void TH_IRQ_TIMER();	SETGATE(idt[IRQ_OFFSET + 0], 0, GD_KT, TH_IRQ_TIMER, 0);
f0103cbf:	b8 a4 45 10 f0       	mov    $0xf01045a4,%eax
f0103cc4:	66 a3 60 13 21 f0    	mov    %ax,0xf0211360
f0103cca:	66 c7 05 62 13 21 f0 	movw   $0x8,0xf0211362
f0103cd1:	08 00 
f0103cd3:	c6 05 64 13 21 f0 00 	movb   $0x0,0xf0211364
f0103cda:	c6 05 65 13 21 f0 8e 	movb   $0x8e,0xf0211365
f0103ce1:	c1 e8 10             	shr    $0x10,%eax
f0103ce4:	66 a3 66 13 21 f0    	mov    %ax,0xf0211366
	extern void TH_IRQ_KBD();	SETGATE(idt[IRQ_OFFSET + 1], 0, GD_KT, TH_IRQ_KBD, 0);
f0103cea:	b8 aa 45 10 f0       	mov    $0xf01045aa,%eax
f0103cef:	66 a3 68 13 21 f0    	mov    %ax,0xf0211368
f0103cf5:	66 c7 05 6a 13 21 f0 	movw   $0x8,0xf021136a
f0103cfc:	08 00 
f0103cfe:	c6 05 6c 13 21 f0 00 	movb   $0x0,0xf021136c
f0103d05:	c6 05 6d 13 21 f0 8e 	movb   $0x8e,0xf021136d
f0103d0c:	c1 e8 10             	shr    $0x10,%eax
f0103d0f:	66 a3 6e 13 21 f0    	mov    %ax,0xf021136e
	extern void TH_IRQ_2();		SETGATE(idt[IRQ_OFFSET + 2], 0, GD_KT, TH_IRQ_2, 0);
f0103d15:	b8 b0 45 10 f0       	mov    $0xf01045b0,%eax
f0103d1a:	66 a3 70 13 21 f0    	mov    %ax,0xf0211370
f0103d20:	66 c7 05 72 13 21 f0 	movw   $0x8,0xf0211372
f0103d27:	08 00 
f0103d29:	c6 05 74 13 21 f0 00 	movb   $0x0,0xf0211374
f0103d30:	c6 05 75 13 21 f0 8e 	movb   $0x8e,0xf0211375
f0103d37:	c1 e8 10             	shr    $0x10,%eax
f0103d3a:	66 a3 76 13 21 f0    	mov    %ax,0xf0211376
	extern void TH_IRQ_3();		SETGATE(idt[IRQ_OFFSET + 3], 0, GD_KT, TH_IRQ_3, 0);
f0103d40:	b8 b6 45 10 f0       	mov    $0xf01045b6,%eax
f0103d45:	66 a3 78 13 21 f0    	mov    %ax,0xf0211378
f0103d4b:	66 c7 05 7a 13 21 f0 	movw   $0x8,0xf021137a
f0103d52:	08 00 
f0103d54:	c6 05 7c 13 21 f0 00 	movb   $0x0,0xf021137c
f0103d5b:	c6 05 7d 13 21 f0 8e 	movb   $0x8e,0xf021137d
f0103d62:	c1 e8 10             	shr    $0x10,%eax
f0103d65:	66 a3 7e 13 21 f0    	mov    %ax,0xf021137e
	extern void TH_IRQ_SERIAL();	SETGATE(idt[IRQ_OFFSET + 4], 0, GD_KT, TH_IRQ_SERIAL, 0);
f0103d6b:	b8 bc 45 10 f0       	mov    $0xf01045bc,%eax
f0103d70:	66 a3 80 13 21 f0    	mov    %ax,0xf0211380
f0103d76:	66 c7 05 82 13 21 f0 	movw   $0x8,0xf0211382
f0103d7d:	08 00 
f0103d7f:	c6 05 84 13 21 f0 00 	movb   $0x0,0xf0211384
f0103d86:	c6 05 85 13 21 f0 8e 	movb   $0x8e,0xf0211385
f0103d8d:	c1 e8 10             	shr    $0x10,%eax
f0103d90:	66 a3 86 13 21 f0    	mov    %ax,0xf0211386
	extern void TH_IRQ_5();		SETGATE(idt[IRQ_OFFSET + 5], 0, GD_KT, TH_IRQ_5, 0);
f0103d96:	b8 c2 45 10 f0       	mov    $0xf01045c2,%eax
f0103d9b:	66 a3 88 13 21 f0    	mov    %ax,0xf0211388
f0103da1:	66 c7 05 8a 13 21 f0 	movw   $0x8,0xf021138a
f0103da8:	08 00 
f0103daa:	c6 05 8c 13 21 f0 00 	movb   $0x0,0xf021138c
f0103db1:	c6 05 8d 13 21 f0 8e 	movb   $0x8e,0xf021138d
f0103db8:	c1 e8 10             	shr    $0x10,%eax
f0103dbb:	66 a3 8e 13 21 f0    	mov    %ax,0xf021138e
	extern void TH_IRQ_6();		SETGATE(idt[IRQ_OFFSET + 6], 0, GD_KT, TH_IRQ_6, 0);
f0103dc1:	b8 c8 45 10 f0       	mov    $0xf01045c8,%eax
f0103dc6:	66 a3 90 13 21 f0    	mov    %ax,0xf0211390
f0103dcc:	66 c7 05 92 13 21 f0 	movw   $0x8,0xf0211392
f0103dd3:	08 00 
f0103dd5:	c6 05 94 13 21 f0 00 	movb   $0x0,0xf0211394
f0103ddc:	c6 05 95 13 21 f0 8e 	movb   $0x8e,0xf0211395
f0103de3:	c1 e8 10             	shr    $0x10,%eax
f0103de6:	66 a3 96 13 21 f0    	mov    %ax,0xf0211396
	extern void TH_IRQ_SPURIOUS();	SETGATE(idt[IRQ_OFFSET + 7], 0, GD_KT, TH_IRQ_SPURIOUS, 0);
f0103dec:	b8 ce 45 10 f0       	mov    $0xf01045ce,%eax
f0103df1:	66 a3 98 13 21 f0    	mov    %ax,0xf0211398
f0103df7:	66 c7 05 9a 13 21 f0 	movw   $0x8,0xf021139a
f0103dfe:	08 00 
f0103e00:	c6 05 9c 13 21 f0 00 	movb   $0x0,0xf021139c
f0103e07:	c6 05 9d 13 21 f0 8e 	movb   $0x8e,0xf021139d
f0103e0e:	c1 e8 10             	shr    $0x10,%eax
f0103e11:	66 a3 9e 13 21 f0    	mov    %ax,0xf021139e
	extern void TH_IRQ_8();		SETGATE(idt[IRQ_OFFSET + 8], 0, GD_KT, TH_IRQ_8, 0);
f0103e17:	b8 d4 45 10 f0       	mov    $0xf01045d4,%eax
f0103e1c:	66 a3 a0 13 21 f0    	mov    %ax,0xf02113a0
f0103e22:	66 c7 05 a2 13 21 f0 	movw   $0x8,0xf02113a2
f0103e29:	08 00 
f0103e2b:	c6 05 a4 13 21 f0 00 	movb   $0x0,0xf02113a4
f0103e32:	c6 05 a5 13 21 f0 8e 	movb   $0x8e,0xf02113a5
f0103e39:	c1 e8 10             	shr    $0x10,%eax
f0103e3c:	66 a3 a6 13 21 f0    	mov    %ax,0xf02113a6
	extern void TH_IRQ_9();		SETGATE(idt[IRQ_OFFSET + 9], 0, GD_KT, TH_IRQ_9, 0);
f0103e42:	b8 da 45 10 f0       	mov    $0xf01045da,%eax
f0103e47:	66 a3 a8 13 21 f0    	mov    %ax,0xf02113a8
f0103e4d:	66 c7 05 aa 13 21 f0 	movw   $0x8,0xf02113aa
f0103e54:	08 00 
f0103e56:	c6 05 ac 13 21 f0 00 	movb   $0x0,0xf02113ac
f0103e5d:	c6 05 ad 13 21 f0 8e 	movb   $0x8e,0xf02113ad
f0103e64:	c1 e8 10             	shr    $0x10,%eax
f0103e67:	66 a3 ae 13 21 f0    	mov    %ax,0xf02113ae
	extern void TH_IRQ_10();	SETGATE(idt[IRQ_OFFSET + 10], 0, GD_KT, TH_IRQ_10, 0);
f0103e6d:	b8 e0 45 10 f0       	mov    $0xf01045e0,%eax
f0103e72:	66 a3 b0 13 21 f0    	mov    %ax,0xf02113b0
f0103e78:	66 c7 05 b2 13 21 f0 	movw   $0x8,0xf02113b2
f0103e7f:	08 00 
f0103e81:	c6 05 b4 13 21 f0 00 	movb   $0x0,0xf02113b4
f0103e88:	c6 05 b5 13 21 f0 8e 	movb   $0x8e,0xf02113b5
f0103e8f:	c1 e8 10             	shr    $0x10,%eax
f0103e92:	66 a3 b6 13 21 f0    	mov    %ax,0xf02113b6
	extern void TH_IRQ_11();	SETGATE(idt[IRQ_OFFSET + 11], 0, GD_KT, TH_IRQ_11, 0);
f0103e98:	b8 e6 45 10 f0       	mov    $0xf01045e6,%eax
f0103e9d:	66 a3 b8 13 21 f0    	mov    %ax,0xf02113b8
f0103ea3:	66 c7 05 ba 13 21 f0 	movw   $0x8,0xf02113ba
f0103eaa:	08 00 
f0103eac:	c6 05 bc 13 21 f0 00 	movb   $0x0,0xf02113bc
f0103eb3:	c6 05 bd 13 21 f0 8e 	movb   $0x8e,0xf02113bd
f0103eba:	c1 e8 10             	shr    $0x10,%eax
f0103ebd:	66 a3 be 13 21 f0    	mov    %ax,0xf02113be
	extern void TH_IRQ_12();	SETGATE(idt[IRQ_OFFSET + 12], 0, GD_KT, TH_IRQ_12, 0);
f0103ec3:	b8 ec 45 10 f0       	mov    $0xf01045ec,%eax
f0103ec8:	66 a3 c0 13 21 f0    	mov    %ax,0xf02113c0
f0103ece:	66 c7 05 c2 13 21 f0 	movw   $0x8,0xf02113c2
f0103ed5:	08 00 
f0103ed7:	c6 05 c4 13 21 f0 00 	movb   $0x0,0xf02113c4
f0103ede:	c6 05 c5 13 21 f0 8e 	movb   $0x8e,0xf02113c5
f0103ee5:	c1 e8 10             	shr    $0x10,%eax
f0103ee8:	66 a3 c6 13 21 f0    	mov    %ax,0xf02113c6
	extern void TH_IRQ_13();	SETGATE(idt[IRQ_OFFSET + 13], 0, GD_KT, TH_IRQ_13, 0);
f0103eee:	b8 f2 45 10 f0       	mov    $0xf01045f2,%eax
f0103ef3:	66 a3 c8 13 21 f0    	mov    %ax,0xf02113c8
f0103ef9:	66 c7 05 ca 13 21 f0 	movw   $0x8,0xf02113ca
f0103f00:	08 00 
f0103f02:	c6 05 cc 13 21 f0 00 	movb   $0x0,0xf02113cc
f0103f09:	c6 05 cd 13 21 f0 8e 	movb   $0x8e,0xf02113cd
f0103f10:	c1 e8 10             	shr    $0x10,%eax
f0103f13:	66 a3 ce 13 21 f0    	mov    %ax,0xf02113ce
	extern void TH_IRQ_IDE();	SETGATE(idt[IRQ_OFFSET + 14], 0, GD_KT, TH_IRQ_IDE, 0);
f0103f19:	b8 f8 45 10 f0       	mov    $0xf01045f8,%eax
f0103f1e:	66 a3 d0 13 21 f0    	mov    %ax,0xf02113d0
f0103f24:	66 c7 05 d2 13 21 f0 	movw   $0x8,0xf02113d2
f0103f2b:	08 00 
f0103f2d:	c6 05 d4 13 21 f0 00 	movb   $0x0,0xf02113d4
f0103f34:	c6 05 d5 13 21 f0 8e 	movb   $0x8e,0xf02113d5
f0103f3b:	c1 e8 10             	shr    $0x10,%eax
f0103f3e:	66 a3 d6 13 21 f0    	mov    %ax,0xf02113d6
	extern void TH_IRQ_15();	SETGATE(idt[IRQ_OFFSET + 15], 0, GD_KT, TH_IRQ_15, 0);
f0103f44:	b8 fe 45 10 f0       	mov    $0xf01045fe,%eax
f0103f49:	66 a3 d8 13 21 f0    	mov    %ax,0xf02113d8
f0103f4f:	66 c7 05 da 13 21 f0 	movw   $0x8,0xf02113da
f0103f56:	08 00 
f0103f58:	c6 05 dc 13 21 f0 00 	movb   $0x0,0xf02113dc
f0103f5f:	c6 05 dd 13 21 f0 8e 	movb   $0x8e,0xf02113dd
f0103f66:	c1 e8 10             	shr    $0x10,%eax
f0103f69:	66 a3 de 13 21 f0    	mov    %ax,0xf02113de

	// Per-CPU setup 
	trap_init_percpu();
f0103f6f:	e8 2d f9 ff ff       	call   f01038a1 <trap_init_percpu>
}
f0103f74:	c9                   	leave  
f0103f75:	c3                   	ret    

f0103f76 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103f76:	55                   	push   %ebp
f0103f77:	89 e5                	mov    %esp,%ebp
f0103f79:	53                   	push   %ebx
f0103f7a:	83 ec 0c             	sub    $0xc,%esp
f0103f7d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103f80:	ff 33                	pushl  (%ebx)
f0103f82:	68 9c 78 10 f0       	push   $0xf010789c
f0103f87:	e8 01 f9 ff ff       	call   f010388d <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103f8c:	83 c4 08             	add    $0x8,%esp
f0103f8f:	ff 73 04             	pushl  0x4(%ebx)
f0103f92:	68 ab 78 10 f0       	push   $0xf01078ab
f0103f97:	e8 f1 f8 ff ff       	call   f010388d <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103f9c:	83 c4 08             	add    $0x8,%esp
f0103f9f:	ff 73 08             	pushl  0x8(%ebx)
f0103fa2:	68 ba 78 10 f0       	push   $0xf01078ba
f0103fa7:	e8 e1 f8 ff ff       	call   f010388d <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103fac:	83 c4 08             	add    $0x8,%esp
f0103faf:	ff 73 0c             	pushl  0xc(%ebx)
f0103fb2:	68 c9 78 10 f0       	push   $0xf01078c9
f0103fb7:	e8 d1 f8 ff ff       	call   f010388d <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103fbc:	83 c4 08             	add    $0x8,%esp
f0103fbf:	ff 73 10             	pushl  0x10(%ebx)
f0103fc2:	68 d8 78 10 f0       	push   $0xf01078d8
f0103fc7:	e8 c1 f8 ff ff       	call   f010388d <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103fcc:	83 c4 08             	add    $0x8,%esp
f0103fcf:	ff 73 14             	pushl  0x14(%ebx)
f0103fd2:	68 e7 78 10 f0       	push   $0xf01078e7
f0103fd7:	e8 b1 f8 ff ff       	call   f010388d <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103fdc:	83 c4 08             	add    $0x8,%esp
f0103fdf:	ff 73 18             	pushl  0x18(%ebx)
f0103fe2:	68 f6 78 10 f0       	push   $0xf01078f6
f0103fe7:	e8 a1 f8 ff ff       	call   f010388d <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103fec:	83 c4 08             	add    $0x8,%esp
f0103fef:	ff 73 1c             	pushl  0x1c(%ebx)
f0103ff2:	68 05 79 10 f0       	push   $0xf0107905
f0103ff7:	e8 91 f8 ff ff       	call   f010388d <cprintf>
}
f0103ffc:	83 c4 10             	add    $0x10,%esp
f0103fff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104002:	c9                   	leave  
f0104003:	c3                   	ret    

f0104004 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0104004:	55                   	push   %ebp
f0104005:	89 e5                	mov    %esp,%ebp
f0104007:	56                   	push   %esi
f0104008:	53                   	push   %ebx
f0104009:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f010400c:	e8 c9 1e 00 00       	call   f0105eda <cpunum>
f0104011:	83 ec 04             	sub    $0x4,%esp
f0104014:	50                   	push   %eax
f0104015:	53                   	push   %ebx
f0104016:	68 69 79 10 f0       	push   $0xf0107969
f010401b:	e8 6d f8 ff ff       	call   f010388d <cprintf>
	print_regs(&tf->tf_regs);
f0104020:	89 1c 24             	mov    %ebx,(%esp)
f0104023:	e8 4e ff ff ff       	call   f0103f76 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0104028:	83 c4 08             	add    $0x8,%esp
f010402b:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f010402f:	50                   	push   %eax
f0104030:	68 87 79 10 f0       	push   $0xf0107987
f0104035:	e8 53 f8 ff ff       	call   f010388d <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010403a:	83 c4 08             	add    $0x8,%esp
f010403d:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0104041:	50                   	push   %eax
f0104042:	68 9a 79 10 f0       	push   $0xf010799a
f0104047:	e8 41 f8 ff ff       	call   f010388d <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010404c:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f010404f:	83 c4 10             	add    $0x10,%esp
f0104052:	83 f8 13             	cmp    $0x13,%eax
f0104055:	77 09                	ja     f0104060 <print_trapframe+0x5c>
		return excnames[trapno];
f0104057:	8b 14 85 40 7c 10 f0 	mov    -0xfef83c0(,%eax,4),%edx
f010405e:	eb 1f                	jmp    f010407f <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0104060:	83 f8 30             	cmp    $0x30,%eax
f0104063:	74 15                	je     f010407a <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104065:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0104068:	83 fa 10             	cmp    $0x10,%edx
f010406b:	b9 33 79 10 f0       	mov    $0xf0107933,%ecx
f0104070:	ba 20 79 10 f0       	mov    $0xf0107920,%edx
f0104075:	0f 43 d1             	cmovae %ecx,%edx
f0104078:	eb 05                	jmp    f010407f <print_trapframe+0x7b>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f010407a:	ba 14 79 10 f0       	mov    $0xf0107914,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010407f:	83 ec 04             	sub    $0x4,%esp
f0104082:	52                   	push   %edx
f0104083:	50                   	push   %eax
f0104084:	68 ad 79 10 f0       	push   $0xf01079ad
f0104089:	e8 ff f7 ff ff       	call   f010388d <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010408e:	83 c4 10             	add    $0x10,%esp
f0104091:	3b 1d 60 1a 21 f0    	cmp    0xf0211a60,%ebx
f0104097:	75 1a                	jne    f01040b3 <print_trapframe+0xaf>
f0104099:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010409d:	75 14                	jne    f01040b3 <print_trapframe+0xaf>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f010409f:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01040a2:	83 ec 08             	sub    $0x8,%esp
f01040a5:	50                   	push   %eax
f01040a6:	68 bf 79 10 f0       	push   $0xf01079bf
f01040ab:	e8 dd f7 ff ff       	call   f010388d <cprintf>
f01040b0:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f01040b3:	83 ec 08             	sub    $0x8,%esp
f01040b6:	ff 73 2c             	pushl  0x2c(%ebx)
f01040b9:	68 ce 79 10 f0       	push   $0xf01079ce
f01040be:	e8 ca f7 ff ff       	call   f010388d <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f01040c3:	83 c4 10             	add    $0x10,%esp
f01040c6:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01040ca:	75 49                	jne    f0104115 <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f01040cc:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f01040cf:	89 c2                	mov    %eax,%edx
f01040d1:	83 e2 01             	and    $0x1,%edx
f01040d4:	ba 4d 79 10 f0       	mov    $0xf010794d,%edx
f01040d9:	b9 42 79 10 f0       	mov    $0xf0107942,%ecx
f01040de:	0f 44 ca             	cmove  %edx,%ecx
f01040e1:	89 c2                	mov    %eax,%edx
f01040e3:	83 e2 02             	and    $0x2,%edx
f01040e6:	ba 5f 79 10 f0       	mov    $0xf010795f,%edx
f01040eb:	be 59 79 10 f0       	mov    $0xf0107959,%esi
f01040f0:	0f 45 d6             	cmovne %esi,%edx
f01040f3:	83 e0 04             	and    $0x4,%eax
f01040f6:	be c6 7a 10 f0       	mov    $0xf0107ac6,%esi
f01040fb:	b8 64 79 10 f0       	mov    $0xf0107964,%eax
f0104100:	0f 44 c6             	cmove  %esi,%eax
f0104103:	51                   	push   %ecx
f0104104:	52                   	push   %edx
f0104105:	50                   	push   %eax
f0104106:	68 dc 79 10 f0       	push   $0xf01079dc
f010410b:	e8 7d f7 ff ff       	call   f010388d <cprintf>
f0104110:	83 c4 10             	add    $0x10,%esp
f0104113:	eb 10                	jmp    f0104125 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0104115:	83 ec 0c             	sub    $0xc,%esp
f0104118:	68 8b 77 10 f0       	push   $0xf010778b
f010411d:	e8 6b f7 ff ff       	call   f010388d <cprintf>
f0104122:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104125:	83 ec 08             	sub    $0x8,%esp
f0104128:	ff 73 30             	pushl  0x30(%ebx)
f010412b:	68 eb 79 10 f0       	push   $0xf01079eb
f0104130:	e8 58 f7 ff ff       	call   f010388d <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104135:	83 c4 08             	add    $0x8,%esp
f0104138:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f010413c:	50                   	push   %eax
f010413d:	68 fa 79 10 f0       	push   $0xf01079fa
f0104142:	e8 46 f7 ff ff       	call   f010388d <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104147:	83 c4 08             	add    $0x8,%esp
f010414a:	ff 73 38             	pushl  0x38(%ebx)
f010414d:	68 0d 7a 10 f0       	push   $0xf0107a0d
f0104152:	e8 36 f7 ff ff       	call   f010388d <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104157:	83 c4 10             	add    $0x10,%esp
f010415a:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010415e:	74 25                	je     f0104185 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104160:	83 ec 08             	sub    $0x8,%esp
f0104163:	ff 73 3c             	pushl  0x3c(%ebx)
f0104166:	68 1c 7a 10 f0       	push   $0xf0107a1c
f010416b:	e8 1d f7 ff ff       	call   f010388d <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104170:	83 c4 08             	add    $0x8,%esp
f0104173:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104177:	50                   	push   %eax
f0104178:	68 2b 7a 10 f0       	push   $0xf0107a2b
f010417d:	e8 0b f7 ff ff       	call   f010388d <cprintf>
f0104182:	83 c4 10             	add    $0x10,%esp
	}
}
f0104185:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104188:	5b                   	pop    %ebx
f0104189:	5e                   	pop    %esi
f010418a:	5d                   	pop    %ebp
f010418b:	c3                   	ret    

f010418c <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010418c:	55                   	push   %ebp
f010418d:	89 e5                	mov    %esp,%ebp
f010418f:	57                   	push   %edi
f0104190:	56                   	push   %esi
f0104191:	53                   	push   %ebx
f0104192:	83 ec 0c             	sub    $0xc,%esp
f0104195:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104198:	0f 20 d6             	mov    %cr2,%esi

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.

	if ((tf->tf_cs & 3) == 0) {
f010419b:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010419f:	75 17                	jne    f01041b8 <page_fault_handler+0x2c>
		panic("kernel page fault\n");
f01041a1:	83 ec 04             	sub    $0x4,%esp
f01041a4:	68 3e 7a 10 f0       	push   $0xf0107a3e
f01041a9:	68 5f 01 00 00       	push   $0x15f
f01041ae:	68 51 7a 10 f0       	push   $0xf0107a51
f01041b3:	e8 88 be ff ff       	call   f0100040 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	if (curenv->env_pgfault_upcall) {
f01041b8:	e8 1d 1d 00 00       	call   f0105eda <cpunum>
f01041bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01041c0:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01041c6:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f01041ca:	0f 84 a7 00 00 00    	je     f0104277 <page_fault_handler+0xeb>
		struct UTrapframe *utf;
		uintptr_t utf_va;
		if ((tf->tf_esp >= UXSTACKTOP - PGSIZE) && 
f01041d0:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01041d3:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
		    (tf->tf_esp < UXSTACKTOP)) {
			utf_va = tf->tf_esp - sizeof(struct UTrapframe) - 4;
f01041d9:	83 e8 38             	sub    $0x38,%eax
f01041dc:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f01041e2:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f01041e7:	0f 46 d0             	cmovbe %eax,%edx
f01041ea:	89 d7                	mov    %edx,%edi
		} else {
			utf_va = UXSTACKTOP - sizeof(struct UTrapframe);
		}
	
		user_mem_assert(curenv, (void*)utf_va, sizeof(struct UTrapframe), 					PTE_W);
f01041ec:	e8 e9 1c 00 00       	call   f0105eda <cpunum>
f01041f1:	6a 02                	push   $0x2
f01041f3:	6a 34                	push   $0x34
f01041f5:	57                   	push   %edi
f01041f6:	6b c0 74             	imul   $0x74,%eax,%eax
f01041f9:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f01041ff:	e8 71 ed ff ff       	call   f0102f75 <user_mem_assert>
		utf = (struct UTrapframe*) utf_va;

		utf->utf_fault_va = fault_va;
f0104204:	89 fa                	mov    %edi,%edx
f0104206:	89 37                	mov    %esi,(%edi)
		utf->utf_err = tf->tf_err;
f0104208:	8b 43 2c             	mov    0x2c(%ebx),%eax
f010420b:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_regs = tf->tf_regs;
f010420e:	8d 7f 08             	lea    0x8(%edi),%edi
f0104211:	b9 08 00 00 00       	mov    $0x8,%ecx
f0104216:	89 de                	mov    %ebx,%esi
f0104218:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eip = tf->tf_eip;
f010421a:	8b 43 30             	mov    0x30(%ebx),%eax
f010421d:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags = tf->tf_eflags;
f0104220:	8b 43 38             	mov    0x38(%ebx),%eax
f0104223:	89 d7                	mov    %edx,%edi
f0104225:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;
f0104228:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010422b:	89 42 30             	mov    %eax,0x30(%edx)

		curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f010422e:	e8 a7 1c 00 00       	call   f0105eda <cpunum>
f0104233:	6b c0 74             	imul   $0x74,%eax,%eax
f0104236:	8b 98 28 20 21 f0    	mov    -0xfdedfd8(%eax),%ebx
f010423c:	e8 99 1c 00 00       	call   f0105eda <cpunum>
f0104241:	6b c0 74             	imul   $0x74,%eax,%eax
f0104244:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f010424a:	8b 40 64             	mov    0x64(%eax),%eax
f010424d:	89 43 30             	mov    %eax,0x30(%ebx)
		curenv->env_tf.tf_esp = utf_va;
f0104250:	e8 85 1c 00 00       	call   f0105eda <cpunum>
f0104255:	6b c0 74             	imul   $0x74,%eax,%eax
f0104258:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f010425e:	89 78 3c             	mov    %edi,0x3c(%eax)
		env_run(curenv);
f0104261:	e8 74 1c 00 00       	call   f0105eda <cpunum>
f0104266:	83 c4 04             	add    $0x4,%esp
f0104269:	6b c0 74             	imul   $0x74,%eax,%eax
f010426c:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0104272:	e8 c5 f3 ff ff       	call   f010363c <env_run>
	}


	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104277:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f010427a:	e8 5b 1c 00 00       	call   f0105eda <cpunum>
		env_run(curenv);
	}


	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010427f:	57                   	push   %edi
f0104280:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0104281:	6b c0 74             	imul   $0x74,%eax,%eax
		env_run(curenv);
	}


	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104284:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f010428a:	ff 70 48             	pushl  0x48(%eax)
f010428d:	68 10 7c 10 f0       	push   $0xf0107c10
f0104292:	e8 f6 f5 ff ff       	call   f010388d <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104297:	89 1c 24             	mov    %ebx,(%esp)
f010429a:	e8 65 fd ff ff       	call   f0104004 <print_trapframe>
	env_destroy(curenv);
f010429f:	e8 36 1c 00 00       	call   f0105eda <cpunum>
f01042a4:	83 c4 04             	add    $0x4,%esp
f01042a7:	6b c0 74             	imul   $0x74,%eax,%eax
f01042aa:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f01042b0:	e8 e8 f2 ff ff       	call   f010359d <env_destroy>
}
f01042b5:	83 c4 10             	add    $0x10,%esp
f01042b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01042bb:	5b                   	pop    %ebx
f01042bc:	5e                   	pop    %esi
f01042bd:	5f                   	pop    %edi
f01042be:	5d                   	pop    %ebp
f01042bf:	c3                   	ret    

f01042c0 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01042c0:	55                   	push   %ebp
f01042c1:	89 e5                	mov    %esp,%ebp
f01042c3:	57                   	push   %edi
f01042c4:	56                   	push   %esi
f01042c5:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01042c8:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f01042c9:	83 3d 80 1e 21 f0 00 	cmpl   $0x0,0xf0211e80
f01042d0:	74 01                	je     f01042d3 <trap+0x13>
		asm volatile("hlt");
f01042d2:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01042d3:	e8 02 1c 00 00       	call   f0105eda <cpunum>
f01042d8:	6b d0 74             	imul   $0x74,%eax,%edx
f01042db:	81 c2 20 20 21 f0    	add    $0xf0212020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01042e1:	b8 01 00 00 00       	mov    $0x1,%eax
f01042e6:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f01042ea:	83 f8 02             	cmp    $0x2,%eax
f01042ed:	75 10                	jne    f01042ff <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01042ef:	83 ec 0c             	sub    $0xc,%esp
f01042f2:	68 c0 03 12 f0       	push   $0xf01203c0
f01042f7:	e8 4c 1e 00 00       	call   f0106148 <spin_lock>
f01042fc:	83 c4 10             	add    $0x10,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f01042ff:	9c                   	pushf  
f0104300:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104301:	f6 c4 02             	test   $0x2,%ah
f0104304:	74 19                	je     f010431f <trap+0x5f>
f0104306:	68 5d 7a 10 f0       	push   $0xf0107a5d
f010430b:	68 97 74 10 f0       	push   $0xf0107497
f0104310:	68 26 01 00 00       	push   $0x126
f0104315:	68 51 7a 10 f0       	push   $0xf0107a51
f010431a:	e8 21 bd ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f010431f:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104323:	83 e0 03             	and    $0x3,%eax
f0104326:	66 83 f8 03          	cmp    $0x3,%ax
f010432a:	0f 85 a0 00 00 00    	jne    f01043d0 <trap+0x110>
f0104330:	83 ec 0c             	sub    $0xc,%esp
f0104333:	68 c0 03 12 f0       	push   $0xf01203c0
f0104338:	e8 0b 1e 00 00       	call   f0106148 <spin_lock>
		// serious kernel work.
		// LAB 4: Your code here.

		lock_kernel();

		assert(curenv);
f010433d:	e8 98 1b 00 00       	call   f0105eda <cpunum>
f0104342:	6b c0 74             	imul   $0x74,%eax,%eax
f0104345:	83 c4 10             	add    $0x10,%esp
f0104348:	83 b8 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%eax)
f010434f:	75 19                	jne    f010436a <trap+0xaa>
f0104351:	68 76 7a 10 f0       	push   $0xf0107a76
f0104356:	68 97 74 10 f0       	push   $0xf0107497
f010435b:	68 30 01 00 00       	push   $0x130
f0104360:	68 51 7a 10 f0       	push   $0xf0107a51
f0104365:	e8 d6 bc ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f010436a:	e8 6b 1b 00 00       	call   f0105eda <cpunum>
f010436f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104372:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104378:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f010437c:	75 2d                	jne    f01043ab <trap+0xeb>
			env_free(curenv);
f010437e:	e8 57 1b 00 00       	call   f0105eda <cpunum>
f0104383:	83 ec 0c             	sub    $0xc,%esp
f0104386:	6b c0 74             	imul   $0x74,%eax,%eax
f0104389:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f010438f:	e8 63 f0 ff ff       	call   f01033f7 <env_free>
			curenv = NULL;
f0104394:	e8 41 1b 00 00       	call   f0105eda <cpunum>
f0104399:	6b c0 74             	imul   $0x74,%eax,%eax
f010439c:	c7 80 28 20 21 f0 00 	movl   $0x0,-0xfdedfd8(%eax)
f01043a3:	00 00 00 
			sched_yield();
f01043a6:	e8 45 03 00 00       	call   f01046f0 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01043ab:	e8 2a 1b 00 00       	call   f0105eda <cpunum>
f01043b0:	6b c0 74             	imul   $0x74,%eax,%eax
f01043b3:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01043b9:	b9 11 00 00 00       	mov    $0x11,%ecx
f01043be:	89 c7                	mov    %eax,%edi
f01043c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01043c2:	e8 13 1b 00 00       	call   f0105eda <cpunum>
f01043c7:	6b c0 74             	imul   $0x74,%eax,%eax
f01043ca:	8b b0 28 20 21 f0    	mov    -0xfdedfd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01043d0:	89 35 60 1a 21 f0    	mov    %esi,0xf0211a60
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.

	switch (tf->tf_trapno) {	
f01043d6:	8b 46 28             	mov    0x28(%esi),%eax
f01043d9:	83 f8 0e             	cmp    $0xe,%eax
f01043dc:	74 0c                	je     f01043ea <trap+0x12a>
f01043de:	83 f8 30             	cmp    $0x30,%eax
f01043e1:	74 38                	je     f010441b <trap+0x15b>
f01043e3:	83 f8 03             	cmp    $0x3,%eax
f01043e6:	75 57                	jne    f010443f <trap+0x17f>
f01043e8:	eb 11                	jmp    f01043fb <trap+0x13b>
	case T_PGFLT:
		page_fault_handler(tf);
f01043ea:	83 ec 0c             	sub    $0xc,%esp
f01043ed:	56                   	push   %esi
f01043ee:	e8 99 fd ff ff       	call   f010418c <page_fault_handler>
f01043f3:	83 c4 10             	add    $0x10,%esp
f01043f6:	e9 cd 00 00 00       	jmp    f01044c8 <trap+0x208>
		return;
	case T_BRKPT:
		print_trapframe(tf);
f01043fb:	83 ec 0c             	sub    $0xc,%esp
f01043fe:	56                   	push   %esi
f01043ff:	e8 00 fc ff ff       	call   f0104004 <print_trapframe>
		panic("tf->tf_trapno == T_BRKPT\n");
f0104404:	83 c4 0c             	add    $0xc,%esp
f0104407:	68 7d 7a 10 f0       	push   $0xf0107a7d
f010440c:	68 e0 00 00 00       	push   $0xe0
f0104411:	68 51 7a 10 f0       	push   $0xf0107a51
f0104416:	e8 25 bc ff ff       	call   f0100040 <_panic>
		return;
	case T_SYSCALL:
		tf->tf_regs.reg_eax = syscall(
f010441b:	83 ec 08             	sub    $0x8,%esp
f010441e:	ff 76 04             	pushl  0x4(%esi)
f0104421:	ff 36                	pushl  (%esi)
f0104423:	ff 76 10             	pushl  0x10(%esi)
f0104426:	ff 76 18             	pushl  0x18(%esi)
f0104429:	ff 76 14             	pushl  0x14(%esi)
f010442c:	ff 76 1c             	pushl  0x1c(%esi)
f010442f:	e8 85 03 00 00       	call   f01047b9 <syscall>
f0104434:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104437:	83 c4 20             	add    $0x20,%esp
f010443a:	e9 89 00 00 00       	jmp    f01044c8 <trap+0x208>
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f010443f:	83 f8 27             	cmp    $0x27,%eax
f0104442:	75 1a                	jne    f010445e <trap+0x19e>
		cprintf("Spurious interrupt on irq 7\n");
f0104444:	83 ec 0c             	sub    $0xc,%esp
f0104447:	68 97 7a 10 f0       	push   $0xf0107a97
f010444c:	e8 3c f4 ff ff       	call   f010388d <cprintf>
		print_trapframe(tf);
f0104451:	89 34 24             	mov    %esi,(%esp)
f0104454:	e8 ab fb ff ff       	call   f0104004 <print_trapframe>
f0104459:	83 c4 10             	add    $0x10,%esp
f010445c:	eb 6a                	jmp    f01044c8 <trap+0x208>

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f010445e:	83 f8 20             	cmp    $0x20,%eax
f0104461:	75 0a                	jne    f010446d <trap+0x1ad>
		lapic_eoi();
f0104463:	e8 bd 1b 00 00       	call   f0106025 <lapic_eoi>
		sched_yield();
f0104468:	e8 83 02 00 00       	call   f01046f0 <sched_yield>
	}

	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.

	if (tf->tf_trapno == (IRQ_OFFSET + IRQ_KBD)) {
f010446d:	83 f8 21             	cmp    $0x21,%eax
f0104470:	75 07                	jne    f0104479 <trap+0x1b9>
		kbd_intr();
f0104472:	e8 80 c1 ff ff       	call   f01005f7 <kbd_intr>
f0104477:	eb 4f                	jmp    f01044c8 <trap+0x208>
		return;
	}

	if (tf->tf_trapno == (IRQ_OFFSET + IRQ_SERIAL)) {
f0104479:	83 f8 24             	cmp    $0x24,%eax
f010447c:	75 07                	jne    f0104485 <trap+0x1c5>
		serial_intr();
f010447e:	e8 58 c1 ff ff       	call   f01005db <serial_intr>
f0104483:	eb 43                	jmp    f01044c8 <trap+0x208>
		return;
	}

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104485:	83 ec 0c             	sub    $0xc,%esp
f0104488:	56                   	push   %esi
f0104489:	e8 76 fb ff ff       	call   f0104004 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f010448e:	83 c4 10             	add    $0x10,%esp
f0104491:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104496:	75 17                	jne    f01044af <trap+0x1ef>
		panic("unhandled trap in kernel");
f0104498:	83 ec 04             	sub    $0x4,%esp
f010449b:	68 b4 7a 10 f0       	push   $0xf0107ab4
f01044a0:	68 0c 01 00 00       	push   $0x10c
f01044a5:	68 51 7a 10 f0       	push   $0xf0107a51
f01044aa:	e8 91 bb ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f01044af:	e8 26 1a 00 00       	call   f0105eda <cpunum>
f01044b4:	83 ec 0c             	sub    $0xc,%esp
f01044b7:	6b c0 74             	imul   $0x74,%eax,%eax
f01044ba:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f01044c0:	e8 d8 f0 ff ff       	call   f010359d <env_destroy>
f01044c5:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f01044c8:	e8 0d 1a 00 00       	call   f0105eda <cpunum>
f01044cd:	6b c0 74             	imul   $0x74,%eax,%eax
f01044d0:	83 b8 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%eax)
f01044d7:	74 2a                	je     f0104503 <trap+0x243>
f01044d9:	e8 fc 19 00 00       	call   f0105eda <cpunum>
f01044de:	6b c0 74             	imul   $0x74,%eax,%eax
f01044e1:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01044e7:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01044eb:	75 16                	jne    f0104503 <trap+0x243>
		env_run(curenv);
f01044ed:	e8 e8 19 00 00       	call   f0105eda <cpunum>
f01044f2:	83 ec 0c             	sub    $0xc,%esp
f01044f5:	6b c0 74             	imul   $0x74,%eax,%eax
f01044f8:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f01044fe:	e8 39 f1 ff ff       	call   f010363c <env_run>
	else
		sched_yield();
f0104503:	e8 e8 01 00 00       	call   f01046f0 <sched_yield>

f0104508 <TH_DIVIDE>:
	.p2align 2
	.globl TRAPHANDLERS
TRAPHANDLERS:
.text

TRAPHANDLER_NOEC(TH_DIVIDE, T_DIVIDE)	// fault
f0104508:	6a 00                	push   $0x0
f010450a:	6a 00                	push   $0x0
f010450c:	e9 f9 00 00 00       	jmp    f010460a <_alltraps>
f0104511:	90                   	nop

f0104512 <TH_DEBUG>:
TRAPHANDLER_NOEC(TH_DEBUG, T_DEBUG)	// fault/trap
f0104512:	6a 00                	push   $0x0
f0104514:	6a 01                	push   $0x1
f0104516:	e9 ef 00 00 00       	jmp    f010460a <_alltraps>
f010451b:	90                   	nop

f010451c <TH_NMI>:
TRAPHANDLER_NOEC(TH_NMI, T_NMI)		//
f010451c:	6a 00                	push   $0x0
f010451e:	6a 02                	push   $0x2
f0104520:	e9 e5 00 00 00       	jmp    f010460a <_alltraps>
f0104525:	90                   	nop

f0104526 <TH_BRKPT>:
TRAPHANDLER_NOEC(TH_BRKPT, T_BRKPT)	// trap
f0104526:	6a 00                	push   $0x0
f0104528:	6a 03                	push   $0x3
f010452a:	e9 db 00 00 00       	jmp    f010460a <_alltraps>
f010452f:	90                   	nop

f0104530 <TH_OFLOW>:
TRAPHANDLER_NOEC(TH_OFLOW, T_OFLOW)	// trap
f0104530:	6a 00                	push   $0x0
f0104532:	6a 04                	push   $0x4
f0104534:	e9 d1 00 00 00       	jmp    f010460a <_alltraps>
f0104539:	90                   	nop

f010453a <TH_BOUND>:
TRAPHANDLER_NOEC(TH_BOUND, T_BOUND)	// fault
f010453a:	6a 00                	push   $0x0
f010453c:	6a 05                	push   $0x5
f010453e:	e9 c7 00 00 00       	jmp    f010460a <_alltraps>
f0104543:	90                   	nop

f0104544 <TH_ILLOP>:
TRAPHANDLER_NOEC(TH_ILLOP, T_ILLOP)	// fault
f0104544:	6a 00                	push   $0x0
f0104546:	6a 06                	push   $0x6
f0104548:	e9 bd 00 00 00       	jmp    f010460a <_alltraps>
f010454d:	90                   	nop

f010454e <TH_DEVICE>:
TRAPHANDLER_NOEC(TH_DEVICE, T_DEVICE)	// fault
f010454e:	6a 00                	push   $0x0
f0104550:	6a 07                	push   $0x7
f0104552:	e9 b3 00 00 00       	jmp    f010460a <_alltraps>
f0104557:	90                   	nop

f0104558 <TH_DBLFLT>:
TRAPHANDLER     (TH_DBLFLT, T_DBLFLT)	// abort
f0104558:	6a 08                	push   $0x8
f010455a:	e9 ab 00 00 00       	jmp    f010460a <_alltraps>
f010455f:	90                   	nop

f0104560 <TH_TSS>:
//TRAPHANDLER_NOEC(TH_COPROC, T_COPROC) // abort	
TRAPHANDLER     (TH_TSS, T_TSS)		// fault
f0104560:	6a 0a                	push   $0xa
f0104562:	e9 a3 00 00 00       	jmp    f010460a <_alltraps>
f0104567:	90                   	nop

f0104568 <TH_SEGNP>:
TRAPHANDLER     (TH_SEGNP, T_SEGNP)	// fault
f0104568:	6a 0b                	push   $0xb
f010456a:	e9 9b 00 00 00       	jmp    f010460a <_alltraps>
f010456f:	90                   	nop

f0104570 <TH_STACK>:
TRAPHANDLER     (TH_STACK, T_STACK)	// fault
f0104570:	6a 0c                	push   $0xc
f0104572:	e9 93 00 00 00       	jmp    f010460a <_alltraps>
f0104577:	90                   	nop

f0104578 <TH_GPFLT>:
TRAPHANDLER     (TH_GPFLT, T_GPFLT)	// fault/abort
f0104578:	6a 0d                	push   $0xd
f010457a:	e9 8b 00 00 00       	jmp    f010460a <_alltraps>
f010457f:	90                   	nop

f0104580 <TH_PGFLT>:
TRAPHANDLER     (TH_PGFLT, T_PGFLT)	// fault
f0104580:	6a 0e                	push   $0xe
f0104582:	e9 83 00 00 00       	jmp    f010460a <_alltraps>
f0104587:	90                   	nop

f0104588 <TH_FPERR>:
//TRAPHANDLER_NOEC(TH_RES, T_RES)	
TRAPHANDLER_NOEC(TH_FPERR, T_FPERR)	// fault
f0104588:	6a 00                	push   $0x0
f010458a:	6a 10                	push   $0x10
f010458c:	eb 7c                	jmp    f010460a <_alltraps>

f010458e <TH_ALIGN>:
TRAPHANDLER     (TH_ALIGN, T_ALIGN)	//
f010458e:	6a 11                	push   $0x11
f0104590:	eb 78                	jmp    f010460a <_alltraps>

f0104592 <TH_MCHK>:
TRAPHANDLER_NOEC(TH_MCHK, T_MCHK)	//
f0104592:	6a 00                	push   $0x0
f0104594:	6a 12                	push   $0x12
f0104596:	eb 72                	jmp    f010460a <_alltraps>

f0104598 <TH_SIMDERR>:
TRAPHANDLER_NOEC(TH_SIMDERR, T_SIMDERR) //
f0104598:	6a 00                	push   $0x0
f010459a:	6a 13                	push   $0x13
f010459c:	eb 6c                	jmp    f010460a <_alltraps>

f010459e <TH_SYSCALL>:

TRAPHANDLER_NOEC(TH_SYSCALL, T_SYSCALL) // trap
f010459e:	6a 00                	push   $0x0
f01045a0:	6a 30                	push   $0x30
f01045a2:	eb 66                	jmp    f010460a <_alltraps>

f01045a4 <TH_IRQ_TIMER>:

TRAPHANDLER_NOEC(TH_IRQ_TIMER, IRQ_OFFSET+IRQ_TIMER)	// 0
f01045a4:	6a 00                	push   $0x0
f01045a6:	6a 20                	push   $0x20
f01045a8:	eb 60                	jmp    f010460a <_alltraps>

f01045aa <TH_IRQ_KBD>:
TRAPHANDLER_NOEC(TH_IRQ_KBD, IRQ_OFFSET+IRQ_KBD)	// 1
f01045aa:	6a 00                	push   $0x0
f01045ac:	6a 21                	push   $0x21
f01045ae:	eb 5a                	jmp    f010460a <_alltraps>

f01045b0 <TH_IRQ_2>:
TRAPHANDLER_NOEC(TH_IRQ_2, IRQ_OFFSET+2)
f01045b0:	6a 00                	push   $0x0
f01045b2:	6a 22                	push   $0x22
f01045b4:	eb 54                	jmp    f010460a <_alltraps>

f01045b6 <TH_IRQ_3>:
TRAPHANDLER_NOEC(TH_IRQ_3, IRQ_OFFSET+3)
f01045b6:	6a 00                	push   $0x0
f01045b8:	6a 23                	push   $0x23
f01045ba:	eb 4e                	jmp    f010460a <_alltraps>

f01045bc <TH_IRQ_SERIAL>:
TRAPHANDLER_NOEC(TH_IRQ_SERIAL, IRQ_OFFSET+IRQ_SERIAL)	// 4
f01045bc:	6a 00                	push   $0x0
f01045be:	6a 24                	push   $0x24
f01045c0:	eb 48                	jmp    f010460a <_alltraps>

f01045c2 <TH_IRQ_5>:
TRAPHANDLER_NOEC(TH_IRQ_5, IRQ_OFFSET+5)
f01045c2:	6a 00                	push   $0x0
f01045c4:	6a 25                	push   $0x25
f01045c6:	eb 42                	jmp    f010460a <_alltraps>

f01045c8 <TH_IRQ_6>:
TRAPHANDLER_NOEC(TH_IRQ_6, IRQ_OFFSET+6)
f01045c8:	6a 00                	push   $0x0
f01045ca:	6a 26                	push   $0x26
f01045cc:	eb 3c                	jmp    f010460a <_alltraps>

f01045ce <TH_IRQ_SPURIOUS>:
TRAPHANDLER_NOEC(TH_IRQ_SPURIOUS, IRQ_OFFSET+IRQ_SPURIOUS) // 7
f01045ce:	6a 00                	push   $0x0
f01045d0:	6a 27                	push   $0x27
f01045d2:	eb 36                	jmp    f010460a <_alltraps>

f01045d4 <TH_IRQ_8>:
TRAPHANDLER_NOEC(TH_IRQ_8, IRQ_OFFSET+8)
f01045d4:	6a 00                	push   $0x0
f01045d6:	6a 28                	push   $0x28
f01045d8:	eb 30                	jmp    f010460a <_alltraps>

f01045da <TH_IRQ_9>:
TRAPHANDLER_NOEC(TH_IRQ_9, IRQ_OFFSET+9)
f01045da:	6a 00                	push   $0x0
f01045dc:	6a 29                	push   $0x29
f01045de:	eb 2a                	jmp    f010460a <_alltraps>

f01045e0 <TH_IRQ_10>:
TRAPHANDLER_NOEC(TH_IRQ_10, IRQ_OFFSET+10)
f01045e0:	6a 00                	push   $0x0
f01045e2:	6a 2a                	push   $0x2a
f01045e4:	eb 24                	jmp    f010460a <_alltraps>

f01045e6 <TH_IRQ_11>:
TRAPHANDLER_NOEC(TH_IRQ_11, IRQ_OFFSET+11)
f01045e6:	6a 00                	push   $0x0
f01045e8:	6a 2b                	push   $0x2b
f01045ea:	eb 1e                	jmp    f010460a <_alltraps>

f01045ec <TH_IRQ_12>:
TRAPHANDLER_NOEC(TH_IRQ_12, IRQ_OFFSET+12)
f01045ec:	6a 00                	push   $0x0
f01045ee:	6a 2c                	push   $0x2c
f01045f0:	eb 18                	jmp    f010460a <_alltraps>

f01045f2 <TH_IRQ_13>:
TRAPHANDLER_NOEC(TH_IRQ_13, IRQ_OFFSET+13)
f01045f2:	6a 00                	push   $0x0
f01045f4:	6a 2d                	push   $0x2d
f01045f6:	eb 12                	jmp    f010460a <_alltraps>

f01045f8 <TH_IRQ_IDE>:
TRAPHANDLER_NOEC(TH_IRQ_IDE, IRQ_OFFSET+IRQ_IDE)	// 14
f01045f8:	6a 00                	push   $0x0
f01045fa:	6a 2e                	push   $0x2e
f01045fc:	eb 0c                	jmp    f010460a <_alltraps>

f01045fe <TH_IRQ_15>:
TRAPHANDLER_NOEC(TH_IRQ_15, IRQ_OFFSET+15)
f01045fe:	6a 00                	push   $0x0
f0104600:	6a 2f                	push   $0x2f
f0104602:	eb 06                	jmp    f010460a <_alltraps>

f0104604 <TH_IRQ_ERROR>:
TRAPHANDLER_NOEC(TH_IRQ_ERROR, IRQ_OFFSET+IRQ_ERROR)	// 19
f0104604:	6a 00                	push   $0x0
f0104606:	6a 33                	push   $0x33
f0104608:	eb 00                	jmp    f010460a <_alltraps>

f010460a <_alltraps>:
 * Lab 3: Your code here for _alltraps
 */

.text
_alltraps:
	pushl	%ds
f010460a:	1e                   	push   %ds
	pushl	%es
f010460b:	06                   	push   %es
	pushal
f010460c:	60                   	pusha  
	mov	$GD_KD, %eax
f010460d:	b8 10 00 00 00       	mov    $0x10,%eax
	mov	%ax, %es
f0104612:	8e c0                	mov    %eax,%es
	mov	%ax, %ds
f0104614:	8e d8                	mov    %eax,%ds
	pushl	%esp
f0104616:	54                   	push   %esp
	call	trap
f0104617:	e8 a4 fc ff ff       	call   f01042c0 <trap>

f010461c <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f010461c:	55                   	push   %ebp
f010461d:	89 e5                	mov    %esp,%ebp
f010461f:	83 ec 08             	sub    $0x8,%esp
f0104622:	a1 48 12 21 f0       	mov    0xf0211248,%eax
f0104627:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010462a:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f010462f:	8b 02                	mov    (%edx),%eax
f0104631:	83 e8 01             	sub    $0x1,%eax
f0104634:	83 f8 02             	cmp    $0x2,%eax
f0104637:	76 10                	jbe    f0104649 <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104639:	83 c1 01             	add    $0x1,%ecx
f010463c:	83 c2 7c             	add    $0x7c,%edx
f010463f:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104645:	75 e8                	jne    f010462f <sched_halt+0x13>
f0104647:	eb 08                	jmp    f0104651 <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104649:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f010464f:	75 1f                	jne    f0104670 <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f0104651:	83 ec 0c             	sub    $0xc,%esp
f0104654:	68 90 7c 10 f0       	push   $0xf0107c90
f0104659:	e8 2f f2 ff ff       	call   f010388d <cprintf>
f010465e:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104661:	83 ec 0c             	sub    $0xc,%esp
f0104664:	6a 00                	push   $0x0
f0104666:	e8 ea c2 ff ff       	call   f0100955 <monitor>
f010466b:	83 c4 10             	add    $0x10,%esp
f010466e:	eb f1                	jmp    f0104661 <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104670:	e8 65 18 00 00       	call   f0105eda <cpunum>
f0104675:	6b c0 74             	imul   $0x74,%eax,%eax
f0104678:	c7 80 28 20 21 f0 00 	movl   $0x0,-0xfdedfd8(%eax)
f010467f:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104682:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104687:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010468c:	77 12                	ja     f01046a0 <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010468e:	50                   	push   %eax
f010468f:	68 c8 65 10 f0       	push   $0xf01065c8
f0104694:	6a 55                	push   $0x55
f0104696:	68 b9 7c 10 f0       	push   $0xf0107cb9
f010469b:	e8 a0 b9 ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01046a0:	05 00 00 00 10       	add    $0x10000000,%eax
f01046a5:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f01046a8:	e8 2d 18 00 00       	call   f0105eda <cpunum>
f01046ad:	6b d0 74             	imul   $0x74,%eax,%edx
f01046b0:	81 c2 20 20 21 f0    	add    $0xf0212020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01046b6:	b8 02 00 00 00       	mov    $0x2,%eax
f01046bb:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01046bf:	83 ec 0c             	sub    $0xc,%esp
f01046c2:	68 c0 03 12 f0       	push   $0xf01203c0
f01046c7:	e8 19 1b 00 00       	call   f01061e5 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01046cc:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f01046ce:	e8 07 18 00 00       	call   f0105eda <cpunum>
f01046d3:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f01046d6:	8b 80 30 20 21 f0    	mov    -0xfdedfd0(%eax),%eax
f01046dc:	bd 00 00 00 00       	mov    $0x0,%ebp
f01046e1:	89 c4                	mov    %eax,%esp
f01046e3:	6a 00                	push   $0x0
f01046e5:	6a 00                	push   $0x0
f01046e7:	fb                   	sti    
f01046e8:	f4                   	hlt    
f01046e9:	eb fd                	jmp    f01046e8 <sched_halt+0xcc>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f01046eb:	83 c4 10             	add    $0x10,%esp
f01046ee:	c9                   	leave  
f01046ef:	c3                   	ret    

f01046f0 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f01046f0:	55                   	push   %ebp
f01046f1:	89 e5                	mov    %esp,%ebp
f01046f3:	53                   	push   %ebx
f01046f4:	83 ec 04             	sub    $0x4,%esp
	// below to halt the cpu.

	// LAB 4: Your code here.

	size_t i;
	if (!curenv) {
f01046f7:	e8 de 17 00 00       	call   f0105eda <cpunum>
f01046fc:	6b c0 74             	imul   $0x74,%eax,%eax
		i = 0;
f01046ff:	ba 00 00 00 00       	mov    $0x0,%edx
	// below to halt the cpu.

	// LAB 4: Your code here.

	size_t i;
	if (!curenv) {
f0104704:	83 b8 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%eax)
f010470b:	74 1a                	je     f0104727 <sched_yield+0x37>
		i = 0;
	} else {
		i = ENVX(curenv->env_id) + 1;
f010470d:	e8 c8 17 00 00       	call   f0105eda <cpunum>
f0104712:	6b c0 74             	imul   $0x74,%eax,%eax
f0104715:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f010471b:	8b 50 48             	mov    0x48(%eax),%edx
f010471e:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0104724:	83 c2 01             	add    $0x1,%edx
	}
		
	for (; i < NENV; i++) {
		if (envs[i].env_status == ENV_RUNNABLE) {
f0104727:	a1 48 12 21 f0       	mov    0xf0211248,%eax
f010472c:	6b ca 7c             	imul   $0x7c,%edx,%ecx
f010472f:	01 c1                	add    %eax,%ecx
f0104731:	eb 17                	jmp    f010474a <sched_yield+0x5a>
f0104733:	89 cb                	mov    %ecx,%ebx
f0104735:	83 c1 7c             	add    $0x7c,%ecx
f0104738:	83 79 d8 02          	cmpl   $0x2,-0x28(%ecx)
f010473c:	75 09                	jne    f0104747 <sched_yield+0x57>
			env_run(&envs[i]);
f010473e:	83 ec 0c             	sub    $0xc,%esp
f0104741:	53                   	push   %ebx
f0104742:	e8 f5 ee ff ff       	call   f010363c <env_run>
		i = 0;
	} else {
		i = ENVX(curenv->env_id) + 1;
	}
		
	for (; i < NENV; i++) {
f0104747:	83 c2 01             	add    $0x1,%edx
f010474a:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
f0104750:	76 e1                	jbe    f0104733 <sched_yield+0x43>
f0104752:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104757:	eb 17                	jmp    f0104770 <sched_yield+0x80>
	}

	size_t j;

	for (j = 0; j < i; j++) {
		if (envs[j].env_status == ENV_RUNNABLE) {
f0104759:	89 c3                	mov    %eax,%ebx
f010475b:	83 c0 7c             	add    $0x7c,%eax
f010475e:	83 78 d8 02          	cmpl   $0x2,-0x28(%eax)
f0104762:	75 09                	jne    f010476d <sched_yield+0x7d>
			env_run(&envs[j]);
f0104764:	83 ec 0c             	sub    $0xc,%esp
f0104767:	53                   	push   %ebx
f0104768:	e8 cf ee ff ff       	call   f010363c <env_run>
		} 
	}

	size_t j;

	for (j = 0; j < i; j++) {
f010476d:	83 c1 01             	add    $0x1,%ecx
f0104770:	39 ca                	cmp    %ecx,%edx
f0104772:	75 e5                	jne    f0104759 <sched_yield+0x69>
		if (envs[j].env_status == ENV_RUNNABLE) {
			env_run(&envs[j]);
		} 
	}
	if (curenv && (curenv->env_status == ENV_RUNNING)) {
f0104774:	e8 61 17 00 00       	call   f0105eda <cpunum>
f0104779:	6b c0 74             	imul   $0x74,%eax,%eax
f010477c:	83 b8 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%eax)
f0104783:	74 2a                	je     f01047af <sched_yield+0xbf>
f0104785:	e8 50 17 00 00       	call   f0105eda <cpunum>
f010478a:	6b c0 74             	imul   $0x74,%eax,%eax
f010478d:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104793:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104797:	75 16                	jne    f01047af <sched_yield+0xbf>
		env_run(curenv);
f0104799:	e8 3c 17 00 00       	call   f0105eda <cpunum>
f010479e:	83 ec 0c             	sub    $0xc,%esp
f01047a1:	6b c0 74             	imul   $0x74,%eax,%eax
f01047a4:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f01047aa:	e8 8d ee ff ff       	call   f010363c <env_run>
	}

	// sched_halt never returns
	sched_halt();
f01047af:	e8 68 fe ff ff       	call   f010461c <sched_halt>
}
f01047b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01047b7:	c9                   	leave  
f01047b8:	c3                   	ret    

f01047b9 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01047b9:	55                   	push   %ebp
f01047ba:	89 e5                	mov    %esp,%ebp
f01047bc:	57                   	push   %edi
f01047bd:	56                   	push   %esi
f01047be:	53                   	push   %ebx
f01047bf:	83 ec 1c             	sub    $0x1c,%esp
f01047c2:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno) {
f01047c5:	83 f8 0d             	cmp    $0xd,%eax
f01047c8:	0f 87 f7 05 00 00    	ja     f0104dc5 <syscall+0x60c>
f01047ce:	ff 24 85 00 7d 10 f0 	jmp    *-0xfef8300(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, PTE_U);
f01047d5:	e8 00 17 00 00       	call   f0105eda <cpunum>
f01047da:	6a 04                	push   $0x4
f01047dc:	ff 75 10             	pushl  0x10(%ebp)
f01047df:	ff 75 0c             	pushl  0xc(%ebp)
f01047e2:	6b c0 74             	imul   $0x74,%eax,%eax
f01047e5:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f01047eb:	e8 85 e7 ff ff       	call   f0102f75 <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f01047f0:	83 c4 0c             	add    $0xc,%esp
f01047f3:	ff 75 0c             	pushl  0xc(%ebp)
f01047f6:	ff 75 10             	pushl  0x10(%ebp)
f01047f9:	68 c6 7c 10 f0       	push   $0xf0107cc6
f01047fe:	e8 8a f0 ff ff       	call   f010388d <cprintf>
f0104803:	83 c4 10             	add    $0x10,%esp
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((char*)a1, a2);
			return 0;
f0104806:	b8 00 00 00 00       	mov    $0x0,%eax
f010480b:	e9 c1 05 00 00       	jmp    f0104dd1 <syscall+0x618>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104810:	e8 f4 bd ff ff       	call   f0100609 <cons_getc>
		case SYS_cputs:
			sys_cputs((char*)a1, a2);
			return 0;

		case SYS_cgetc:
			return sys_cgetc();
f0104815:	e9 b7 05 00 00       	jmp    f0104dd1 <syscall+0x618>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f010481a:	e8 bb 16 00 00       	call   f0105eda <cpunum>
f010481f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104822:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104828:	8b 40 48             	mov    0x48(%eax),%eax

		case SYS_cgetc:
			return sys_cgetc();

		case SYS_getenvid:
			return sys_getenvid();
f010482b:	e9 a1 05 00 00       	jmp    f0104dd1 <syscall+0x618>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104830:	83 ec 04             	sub    $0x4,%esp
f0104833:	6a 01                	push   $0x1
f0104835:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104838:	50                   	push   %eax
f0104839:	ff 75 0c             	pushl  0xc(%ebp)
f010483c:	e8 04 e8 ff ff       	call   f0103045 <envid2env>
f0104841:	83 c4 10             	add    $0x10,%esp
f0104844:	85 c0                	test   %eax,%eax
f0104846:	0f 88 85 05 00 00    	js     f0104dd1 <syscall+0x618>
		return r;
	if (e == curenv)
f010484c:	e8 89 16 00 00       	call   f0105eda <cpunum>
f0104851:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104854:	6b c0 74             	imul   $0x74,%eax,%eax
f0104857:	39 90 28 20 21 f0    	cmp    %edx,-0xfdedfd8(%eax)
f010485d:	75 23                	jne    f0104882 <syscall+0xc9>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f010485f:	e8 76 16 00 00       	call   f0105eda <cpunum>
f0104864:	83 ec 08             	sub    $0x8,%esp
f0104867:	6b c0 74             	imul   $0x74,%eax,%eax
f010486a:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104870:	ff 70 48             	pushl  0x48(%eax)
f0104873:	68 cb 7c 10 f0       	push   $0xf0107ccb
f0104878:	e8 10 f0 ff ff       	call   f010388d <cprintf>
f010487d:	83 c4 10             	add    $0x10,%esp
f0104880:	eb 25                	jmp    f01048a7 <syscall+0xee>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104882:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104885:	e8 50 16 00 00       	call   f0105eda <cpunum>
f010488a:	83 ec 04             	sub    $0x4,%esp
f010488d:	53                   	push   %ebx
f010488e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104891:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104897:	ff 70 48             	pushl  0x48(%eax)
f010489a:	68 e6 7c 10 f0       	push   $0xf0107ce6
f010489f:	e8 e9 ef ff ff       	call   f010388d <cprintf>
f01048a4:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f01048a7:	83 ec 0c             	sub    $0xc,%esp
f01048aa:	ff 75 e4             	pushl  -0x1c(%ebp)
f01048ad:	e8 eb ec ff ff       	call   f010359d <env_destroy>
f01048b2:	83 c4 10             	add    $0x10,%esp
	return 0;
f01048b5:	b8 00 00 00 00       	mov    $0x0,%eax
f01048ba:	e9 12 05 00 00       	jmp    f0104dd1 <syscall+0x618>
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	// check if va is page aligned and isnt above UTOP
	if ((((int)va % PGSIZE) != 0) || ((uintptr_t)va >= UTOP)) {
f01048bf:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01048c6:	0f 85 84 00 00 00    	jne    f0104950 <syscall+0x197>
f01048cc:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01048d3:	77 7b                	ja     f0104950 <syscall+0x197>
		return -E_INVAL;
	}
	// check if PTE_P and PTE_U are set (must be set)
	if (((PTE_P | PTE_U) & perm) != (PTE_U | PTE_P)) { 
f01048d5:	8b 45 14             	mov    0x14(%ebp),%eax
f01048d8:	83 e0 05             	and    $0x5,%eax
f01048db:	83 f8 05             	cmp    $0x5,%eax
f01048de:	75 7a                	jne    f010495a <syscall+0x1a1>
	}
	
	int to_check = perm | PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	int available_perm = PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	// check if no other bits hev bin(where the trash goes) set 
	if ((available_perm ^ to_check) != 0) {
f01048e0:	8b 45 14             	mov    0x14(%ebp),%eax
f01048e3:	0d 07 0e 00 00       	or     $0xe07,%eax
f01048e8:	3d 07 0e 00 00       	cmp    $0xe07,%eax
f01048ed:	75 75                	jne    f0104964 <syscall+0x1ab>
		return -E_INVAL;
	}

	struct PageInfo *new_page = page_alloc(ALLOC_ZERO);
f01048ef:	83 ec 0c             	sub    $0xc,%esp
f01048f2:	6a 01                	push   $0x1
f01048f4:	e8 a8 c6 ff ff       	call   f0100fa1 <page_alloc>
f01048f9:	89 c3                	mov    %eax,%ebx
	// page alloc return null if there are no free pages on page_free_list
	if (!new_page) {
f01048fb:	83 c4 10             	add    $0x10,%esp
f01048fe:	85 c0                	test   %eax,%eax
f0104900:	74 6c                	je     f010496e <syscall+0x1b5>
		return -E_NO_MEM;
	}

	struct Env *e;
	int retperm = envid2env(envid, &e, true);
f0104902:	83 ec 04             	sub    $0x4,%esp
f0104905:	6a 01                	push   $0x1
f0104907:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010490a:	50                   	push   %eax
f010490b:	ff 75 0c             	pushl  0xc(%ebp)
f010490e:	e8 32 e7 ff ff       	call   f0103045 <envid2env>

	//nechce sa mi uz
	if (retperm) {
f0104913:	83 c4 10             	add    $0x10,%esp
f0104916:	85 c0                	test   %eax,%eax
f0104918:	0f 85 b3 04 00 00    	jne    f0104dd1 <syscall+0x618>
		return retperm;
	}	

	int pg_insert_check = page_insert(e->env_pgdir, new_page, va, perm);
f010491e:	ff 75 14             	pushl  0x14(%ebp)
f0104921:	ff 75 10             	pushl  0x10(%ebp)
f0104924:	53                   	push   %ebx
f0104925:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104928:	ff 70 60             	pushl  0x60(%eax)
f010492b:	e8 1f ca ff ff       	call   f010134f <page_insert>
f0104930:	89 c6                	mov    %eax,%esi
	
	if (pg_insert_check) {
f0104932:	83 c4 10             	add    $0x10,%esp
f0104935:	85 c0                	test   %eax,%eax
f0104937:	0f 84 94 04 00 00    	je     f0104dd1 <syscall+0x618>
		page_free(new_page);
f010493d:	83 ec 0c             	sub    $0xc,%esp
f0104940:	53                   	push   %ebx
f0104941:	e8 cb c6 ff ff       	call   f0101011 <page_free>
f0104946:	83 c4 10             	add    $0x10,%esp
		return pg_insert_check;
f0104949:	89 f0                	mov    %esi,%eax
f010494b:	e9 81 04 00 00       	jmp    f0104dd1 <syscall+0x618>
	//   allocated!

	// LAB 4: Your code here.
	// check if va is page aligned and isnt above UTOP
	if ((((int)va % PGSIZE) != 0) || ((uintptr_t)va >= UTOP)) {
		return -E_INVAL;
f0104950:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104955:	e9 77 04 00 00       	jmp    f0104dd1 <syscall+0x618>
	}
	// check if PTE_P and PTE_U are set (must be set)
	if (((PTE_P | PTE_U) & perm) != (PTE_U | PTE_P)) { 
		return -E_INVAL;
f010495a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010495f:	e9 6d 04 00 00       	jmp    f0104dd1 <syscall+0x618>
	
	int to_check = perm | PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	int available_perm = PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	// check if no other bits hev bin(where the trash goes) set 
	if ((available_perm ^ to_check) != 0) {
		return -E_INVAL;
f0104964:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104969:	e9 63 04 00 00       	jmp    f0104dd1 <syscall+0x618>
	}

	struct PageInfo *new_page = page_alloc(ALLOC_ZERO);
	// page alloc return null if there are no free pages on page_free_list
	if (!new_page) {
		return -E_NO_MEM;
f010496e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104973:	e9 59 04 00 00       	jmp    f0104dd1 <syscall+0x618>
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.

	if ((((int)srcva % PGSIZE) != 0) || ((uintptr_t)srcva >= UTOP)) {
f0104978:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010497f:	0f 85 d7 00 00 00    	jne    f0104a5c <syscall+0x2a3>
f0104985:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010498c:	0f 87 ca 00 00 00    	ja     f0104a5c <syscall+0x2a3>
		return -E_INVAL;
	}

	if ((((int)dstva % PGSIZE) != 0) || ((uintptr_t)dstva >= UTOP)) {
f0104992:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0104999:	0f 85 c7 00 00 00    	jne    f0104a66 <syscall+0x2ad>
f010499f:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f01049a6:	0f 87 ba 00 00 00    	ja     f0104a66 <syscall+0x2ad>
		return -E_INVAL;
	}

	if (((PTE_P | PTE_U) & perm) != (PTE_U | PTE_P)) { 
f01049ac:	8b 45 1c             	mov    0x1c(%ebp),%eax
f01049af:	83 e0 05             	and    $0x5,%eax
f01049b2:	83 f8 05             	cmp    $0x5,%eax
f01049b5:	0f 85 b5 00 00 00    	jne    f0104a70 <syscall+0x2b7>
	}
	
	int to_check = perm | PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	int available_perm = PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	// check if no other bits have been set 
	if ((available_perm ^ to_check) != 0) {
f01049bb:	8b 45 1c             	mov    0x1c(%ebp),%eax
f01049be:	0d 07 0e 00 00       	or     $0xe07,%eax
f01049c3:	3d 07 0e 00 00       	cmp    $0xe07,%eax
f01049c8:	0f 85 ac 00 00 00    	jne    f0104a7a <syscall+0x2c1>
		return -E_INVAL;
	}

	struct Env *srce;

	int retperm = envid2env(srcenvid, &srce, true);
f01049ce:	83 ec 04             	sub    $0x4,%esp
f01049d1:	6a 01                	push   $0x1
f01049d3:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01049d6:	50                   	push   %eax
f01049d7:	ff 75 0c             	pushl  0xc(%ebp)
f01049da:	e8 66 e6 ff ff       	call   f0103045 <envid2env>
	
	if (retperm == -E_BAD_ENV) {
f01049df:	83 c4 10             	add    $0x10,%esp
f01049e2:	83 f8 fe             	cmp    $0xfffffffe,%eax
f01049e5:	0f 84 99 00 00 00    	je     f0104a84 <syscall+0x2cb>
		return -E_BAD_ENV;
	}

	struct Env *dste;

	int retperm2 = envid2env(dstenvid, &dste, true);
f01049eb:	83 ec 04             	sub    $0x4,%esp
f01049ee:	6a 01                	push   $0x1
f01049f0:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01049f3:	50                   	push   %eax
f01049f4:	ff 75 14             	pushl  0x14(%ebp)
f01049f7:	e8 49 e6 ff ff       	call   f0103045 <envid2env>
	
	if (retperm2 == -E_BAD_ENV) {
f01049fc:	83 c4 10             	add    $0x10,%esp
f01049ff:	83 f8 fe             	cmp    $0xfffffffe,%eax
f0104a02:	0f 84 86 00 00 00    	je     f0104a8e <syscall+0x2d5>
		return -E_BAD_ENV;
	}

	pte_t *pte_store;
	struct PageInfo *p = page_lookup(srce->env_pgdir, srcva, &pte_store);
f0104a08:	83 ec 04             	sub    $0x4,%esp
f0104a0b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104a0e:	50                   	push   %eax
f0104a0f:	ff 75 10             	pushl  0x10(%ebp)
f0104a12:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104a15:	ff 70 60             	pushl  0x60(%eax)
f0104a18:	e8 08 c8 ff ff       	call   f0101225 <page_lookup>
	
	if (((perm & PTE_W) == PTE_W) && ((*pte_store & PTE_W) != PTE_W)) {
f0104a1d:	83 c4 10             	add    $0x10,%esp
f0104a20:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104a24:	74 08                	je     f0104a2e <syscall+0x275>
f0104a26:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104a29:	f6 02 02             	testb  $0x2,(%edx)
f0104a2c:	74 6a                	je     f0104a98 <syscall+0x2df>
		return -E_INVAL;
	}

	if (!p) {
f0104a2e:	85 c0                	test   %eax,%eax
f0104a30:	74 70                	je     f0104aa2 <syscall+0x2e9>
		return -E_INVAL;	
	}
	
	int pg_insert_check = page_insert(dste->env_pgdir, p, dstva, perm);
f0104a32:	ff 75 1c             	pushl  0x1c(%ebp)
f0104a35:	ff 75 18             	pushl  0x18(%ebp)
f0104a38:	50                   	push   %eax
f0104a39:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a3c:	ff 70 60             	pushl  0x60(%eax)
f0104a3f:	e8 0b c9 ff ff       	call   f010134f <page_insert>
	
	if (pg_insert_check == -E_NO_MEM) {
f0104a44:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
	}
	
	return 0;
f0104a47:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0104a4a:	0f 95 c0             	setne  %al
f0104a4d:	0f b6 c0             	movzbl %al,%eax
f0104a50:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
f0104a57:	e9 75 03 00 00       	jmp    f0104dd1 <syscall+0x618>
	//   check the current permissions on the page.

	// LAB 4: Your code here.

	if ((((int)srcva % PGSIZE) != 0) || ((uintptr_t)srcva >= UTOP)) {
		return -E_INVAL;
f0104a5c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a61:	e9 6b 03 00 00       	jmp    f0104dd1 <syscall+0x618>
	}

	if ((((int)dstva % PGSIZE) != 0) || ((uintptr_t)dstva >= UTOP)) {
		return -E_INVAL;
f0104a66:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a6b:	e9 61 03 00 00       	jmp    f0104dd1 <syscall+0x618>
	}

	if (((PTE_P | PTE_U) & perm) != (PTE_U | PTE_P)) { 
		return -E_INVAL;
f0104a70:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a75:	e9 57 03 00 00       	jmp    f0104dd1 <syscall+0x618>
	
	int to_check = perm | PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	int available_perm = PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	// check if no other bits have been set 
	if ((available_perm ^ to_check) != 0) {
		return -E_INVAL;
f0104a7a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a7f:	e9 4d 03 00 00       	jmp    f0104dd1 <syscall+0x618>
	struct Env *srce;

	int retperm = envid2env(srcenvid, &srce, true);
	
	if (retperm == -E_BAD_ENV) {
		return -E_BAD_ENV;
f0104a84:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104a89:	e9 43 03 00 00       	jmp    f0104dd1 <syscall+0x618>
	struct Env *dste;

	int retperm2 = envid2env(dstenvid, &dste, true);
	
	if (retperm2 == -E_BAD_ENV) {
		return -E_BAD_ENV;
f0104a8e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104a93:	e9 39 03 00 00       	jmp    f0104dd1 <syscall+0x618>

	pte_t *pte_store;
	struct PageInfo *p = page_lookup(srce->env_pgdir, srcva, &pte_store);
	
	if (((perm & PTE_W) == PTE_W) && ((*pte_store & PTE_W) != PTE_W)) {
		return -E_INVAL;
f0104a98:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a9d:	e9 2f 03 00 00       	jmp    f0104dd1 <syscall+0x618>
	}

	if (!p) {
		return -E_INVAL;	
f0104aa2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104aa7:	e9 25 03 00 00       	jmp    f0104dd1 <syscall+0x618>
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if ((((int)va % PGSIZE) != 0) || ((uintptr_t)va >= UTOP)) {
f0104aac:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104ab3:	75 42                	jne    f0104af7 <syscall+0x33e>
f0104ab5:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104abc:	77 39                	ja     f0104af7 <syscall+0x33e>
		return -E_INVAL;
	}
	
	struct Env *e;
	int perm = envid2env(envid, &e, true);
f0104abe:	83 ec 04             	sub    $0x4,%esp
f0104ac1:	6a 01                	push   $0x1
f0104ac3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104ac6:	50                   	push   %eax
f0104ac7:	ff 75 0c             	pushl  0xc(%ebp)
f0104aca:	e8 76 e5 ff ff       	call   f0103045 <envid2env>
f0104acf:	89 c3                	mov    %eax,%ebx
	
	if (perm) {
f0104ad1:	83 c4 10             	add    $0x10,%esp
f0104ad4:	85 c0                	test   %eax,%eax
f0104ad6:	0f 85 f5 02 00 00    	jne    f0104dd1 <syscall+0x618>
		return perm;
	}	
	
	page_remove(e->env_pgdir, va);
f0104adc:	83 ec 08             	sub    $0x8,%esp
f0104adf:	ff 75 10             	pushl  0x10(%ebp)
f0104ae2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ae5:	ff 70 60             	pushl  0x60(%eax)
f0104ae8:	e8 f4 c7 ff ff       	call   f01012e1 <page_remove>
f0104aed:	83 c4 10             	add    $0x10,%esp

	return 0;
f0104af0:	89 d8                	mov    %ebx,%eax
f0104af2:	e9 da 02 00 00       	jmp    f0104dd1 <syscall+0x618>
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if ((((int)va % PGSIZE) != 0) || ((uintptr_t)va >= UTOP)) {
		return -E_INVAL;
f0104af7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104afc:	e9 d0 02 00 00       	jmp    f0104dd1 <syscall+0x618>
	// It should be left as env_alloc created it, except that
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.
	struct Env *new_env;
	int env_state =	env_alloc(&new_env, curenv->env_id);
f0104b01:	e8 d4 13 00 00       	call   f0105eda <cpunum>
f0104b06:	83 ec 08             	sub    $0x8,%esp
f0104b09:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b0c:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104b12:	ff 70 48             	pushl  0x48(%eax)
f0104b15:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104b18:	50                   	push   %eax
f0104b19:	e8 39 e6 ff ff       	call   f0103157 <env_alloc>

	if (env_state < 0) {
f0104b1e:	83 c4 10             	add    $0x10,%esp
f0104b21:	85 c0                	test   %eax,%eax
f0104b23:	0f 88 a8 02 00 00    	js     f0104dd1 <syscall+0x618>
		return env_state;
	}

	new_env->env_tf = curenv->env_tf;
f0104b29:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104b2c:	e8 a9 13 00 00       	call   f0105eda <cpunum>
f0104b31:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b34:	8b b0 28 20 21 f0    	mov    -0xfdedfd8(%eax),%esi
f0104b3a:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104b3f:	89 df                	mov    %ebx,%edi
f0104b41:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	new_env->env_status = ENV_NOT_RUNNABLE;
f0104b43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b46:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	new_env->env_tf.tf_regs.reg_eax = 0;
f0104b4d:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	return new_env->env_id;
f0104b54:	8b 40 48             	mov    0x48(%eax),%eax
f0104b57:	e9 75 02 00 00       	jmp    f0104dd1 <syscall+0x618>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if ((status != ENV_RUNNABLE) && (status != ENV_NOT_RUNNABLE)) {
f0104b5c:	8b 45 10             	mov    0x10(%ebp),%eax
f0104b5f:	83 e8 02             	sub    $0x2,%eax
f0104b62:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0104b67:	75 2e                	jne    f0104b97 <syscall+0x3de>
		return -E_INVAL;
	}

	struct Env *e;

	int perm = envid2env(envid, &e, true); 
f0104b69:	83 ec 04             	sub    $0x4,%esp
f0104b6c:	6a 01                	push   $0x1
f0104b6e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104b71:	50                   	push   %eax
f0104b72:	ff 75 0c             	pushl  0xc(%ebp)
f0104b75:	e8 cb e4 ff ff       	call   f0103045 <envid2env>
f0104b7a:	89 c2                	mov    %eax,%edx

	if (perm) {
f0104b7c:	83 c4 10             	add    $0x10,%esp
f0104b7f:	85 c0                	test   %eax,%eax
f0104b81:	0f 85 4a 02 00 00    	jne    f0104dd1 <syscall+0x618>
		return perm;
	}	

	e->env_status = status;
f0104b87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b8a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104b8d:	89 48 54             	mov    %ecx,0x54(%eax)

	return 0;
f0104b90:	89 d0                	mov    %edx,%eax
f0104b92:	e9 3a 02 00 00       	jmp    f0104dd1 <syscall+0x618>
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if ((status != ENV_RUNNABLE) && (status != ENV_NOT_RUNNABLE)) {
		return -E_INVAL;
f0104b97:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104b9c:	e9 30 02 00 00       	jmp    f0104dd1 <syscall+0x618>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *e;

	int perm = envid2env(envid, &e, true); 
f0104ba1:	83 ec 04             	sub    $0x4,%esp
f0104ba4:	6a 01                	push   $0x1
f0104ba6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104ba9:	50                   	push   %eax
f0104baa:	ff 75 0c             	pushl  0xc(%ebp)
f0104bad:	e8 93 e4 ff ff       	call   f0103045 <envid2env>

	if (perm) {
f0104bb2:	83 c4 10             	add    $0x10,%esp
f0104bb5:	85 c0                	test   %eax,%eax
f0104bb7:	0f 85 14 02 00 00    	jne    f0104dd1 <syscall+0x618>
		return perm;
	}
	
	e->env_pgfault_upcall = func;
f0104bbd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104bc0:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104bc3:	89 7a 64             	mov    %edi,0x64(%edx)

		case SYS_env_set_status:
			return sys_env_set_status(a1, a2);

		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1, (void*)a2);
f0104bc6:	e9 06 02 00 00       	jmp    f0104dd1 <syscall+0x618>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104bcb:	e8 20 fb ff ff       	call   f01046f0 <sched_yield>
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.

	struct Env *e;
	int env = envid2env(envid, &e, false);
f0104bd0:	83 ec 04             	sub    $0x4,%esp
f0104bd3:	6a 00                	push   $0x0
f0104bd5:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104bd8:	50                   	push   %eax
f0104bd9:	ff 75 0c             	pushl  0xc(%ebp)
f0104bdc:	e8 64 e4 ff ff       	call   f0103045 <envid2env>
	
	if (env < 0) {
f0104be1:	83 c4 10             	add    $0x10,%esp
f0104be4:	85 c0                	test   %eax,%eax
f0104be6:	79 08                	jns    f0104bf0 <syscall+0x437>
		return perm;
f0104be8:	8b 45 18             	mov    0x18(%ebp),%eax
f0104beb:	e9 e1 01 00 00       	jmp    f0104dd1 <syscall+0x618>
	}
	
	if (!e->env_ipc_recving) {
f0104bf0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104bf3:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104bf7:	0f 84 00 01 00 00    	je     f0104cfd <syscall+0x544>
		return -E_IPC_NOT_RECV;
	}

	e->env_ipc_perm = 0;
f0104bfd:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)

	if ((uint32_t)srcva < UTOP) {
f0104c04:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104c0b:	0f 87 b0 00 00 00    	ja     f0104cc1 <syscall+0x508>
		if (ROUNDDOWN((uint32_t)srcva,PGSIZE) != (uint32_t)srcva) {
			return -E_INVAL;
f0104c11:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}

	e->env_ipc_perm = 0;

	if ((uint32_t)srcva < UTOP) {
		if (ROUNDDOWN((uint32_t)srcva,PGSIZE) != (uint32_t)srcva) {
f0104c16:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104c1d:	0f 85 ae 01 00 00    	jne    f0104dd1 <syscall+0x618>
			return -E_INVAL;
		}

		if (((PTE_P | PTE_U) & perm) != (PTE_U | PTE_P)) { 
f0104c23:	8b 55 18             	mov    0x18(%ebp),%edx
f0104c26:	83 e2 05             	and    $0x5,%edx
f0104c29:	83 fa 05             	cmp    $0x5,%edx
f0104c2c:	0f 85 9f 01 00 00    	jne    f0104dd1 <syscall+0x618>
		}
	
		int to_check = perm | PTE_P | PTE_W | PTE_U | PTE_AVAIL;
		int available_perm = PTE_P | PTE_W | PTE_U | PTE_AVAIL;
		// check if no other bits have been set 
		if ((available_perm ^ to_check) != 0) {
f0104c32:	8b 55 18             	mov    0x18(%ebp),%edx
f0104c35:	81 ca 07 0e 00 00    	or     $0xe07,%edx
f0104c3b:	81 fa 07 0e 00 00    	cmp    $0xe07,%edx
f0104c41:	0f 85 8a 01 00 00    	jne    f0104dd1 <syscall+0x618>
			return -E_INVAL;
		}

		pte_t *pte_store;
		struct PageInfo *p = page_lookup(curenv->env_pgdir, srcva, 							 &pte_store);
f0104c47:	e8 8e 12 00 00       	call   f0105eda <cpunum>
f0104c4c:	83 ec 04             	sub    $0x4,%esp
f0104c4f:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104c52:	52                   	push   %edx
f0104c53:	ff 75 14             	pushl  0x14(%ebp)
f0104c56:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c59:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104c5f:	ff 70 60             	pushl  0x60(%eax)
f0104c62:	e8 be c5 ff ff       	call   f0101225 <page_lookup>
f0104c67:	89 c1                	mov    %eax,%ecx
	
		if (((perm & PTE_W) == PTE_W) && ((*pte_store & PTE_W) != PTE_W)) {
f0104c69:	83 c4 10             	add    $0x10,%esp
f0104c6c:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104c70:	74 11                	je     f0104c83 <syscall+0x4ca>
			return -E_INVAL;
f0104c72:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}

		pte_t *pte_store;
		struct PageInfo *p = page_lookup(curenv->env_pgdir, srcva, 							 &pte_store);
	
		if (((perm & PTE_W) == PTE_W) && ((*pte_store & PTE_W) != PTE_W)) {
f0104c77:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104c7a:	f6 02 02             	testb  $0x2,(%edx)
f0104c7d:	0f 84 4e 01 00 00    	je     f0104dd1 <syscall+0x618>
			return -E_INVAL;
		}

		if (!p) {
f0104c83:	85 c9                	test   %ecx,%ecx
f0104c85:	74 30                	je     f0104cb7 <syscall+0x4fe>
			return -E_INVAL;	
		}

		if ((uint32_t)e->env_ipc_dstva < UTOP){
f0104c87:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104c8a:	8b 42 6c             	mov    0x6c(%edx),%eax
f0104c8d:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f0104c92:	77 2d                	ja     f0104cc1 <syscall+0x508>
			int pg_insert_check = page_insert(e->env_pgdir, p,
f0104c94:	ff 75 18             	pushl  0x18(%ebp)
f0104c97:	50                   	push   %eax
f0104c98:	51                   	push   %ecx
f0104c99:	ff 72 60             	pushl  0x60(%edx)
f0104c9c:	e8 ae c6 ff ff       	call   f010134f <page_insert>
	 				          e->env_ipc_dstva, perm);
	
			if (pg_insert_check < 0) {
f0104ca1:	83 c4 10             	add    $0x10,%esp
f0104ca4:	85 c0                	test   %eax,%eax
f0104ca6:	0f 88 25 01 00 00    	js     f0104dd1 <syscall+0x618>
				return pg_insert_check;
			}

			e->env_ipc_perm = perm;
f0104cac:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104caf:	8b 7d 18             	mov    0x18(%ebp),%edi
f0104cb2:	89 78 78             	mov    %edi,0x78(%eax)
f0104cb5:	eb 0a                	jmp    f0104cc1 <syscall+0x508>
		if (((perm & PTE_W) == PTE_W) && ((*pte_store & PTE_W) != PTE_W)) {
			return -E_INVAL;
		}

		if (!p) {
			return -E_INVAL;	
f0104cb7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104cbc:	e9 10 01 00 00       	jmp    f0104dd1 <syscall+0x618>

			e->env_ipc_perm = perm;
		}
	}

	e->env_ipc_recving = false;
f0104cc1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104cc4:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	e->env_ipc_from = curenv->env_id;
f0104cc8:	e8 0d 12 00 00       	call   f0105eda <cpunum>
f0104ccd:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cd0:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104cd6:	8b 40 48             	mov    0x48(%eax),%eax
f0104cd9:	89 43 74             	mov    %eax,0x74(%ebx)
	e->env_ipc_value = value;
f0104cdc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104cdf:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104ce2:	89 48 70             	mov    %ecx,0x70(%eax)
	e->env_status = ENV_RUNNABLE;
f0104ce5:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	e->env_tf.tf_regs.reg_eax = 0;
f0104cec:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	return 0;
f0104cf3:	b8 00 00 00 00       	mov    $0x0,%eax
f0104cf8:	e9 d4 00 00 00       	jmp    f0104dd1 <syscall+0x618>
	if (env < 0) {
		return perm;
	}
	
	if (!e->env_ipc_recving) {
		return -E_IPC_NOT_RECV;
f0104cfd:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
		case SYS_yield:
			sys_yield();
			return 0;

		case SYS_ipc_try_send:
			return sys_ipc_try_send(a1, a2, (void*)a3, a4);
f0104d02:	e9 ca 00 00 00       	jmp    f0104dd1 <syscall+0x618>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if ((uint32_t)dstva < UTOP) {
f0104d07:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104d0e:	77 0d                	ja     f0104d1d <syscall+0x564>
		if (ROUNDDOWN((uint32_t)dstva, PGSIZE) != (uint32_t)dstva) {
f0104d10:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104d17:	0f 85 af 00 00 00    	jne    f0104dcc <syscall+0x613>
			return -E_INVAL;
		}
	}
	curenv->env_ipc_recving = true;	
f0104d1d:	e8 b8 11 00 00       	call   f0105eda <cpunum>
f0104d22:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d25:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104d2b:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f0104d2f:	e8 a6 11 00 00       	call   f0105eda <cpunum>
f0104d34:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d37:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104d3d:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104d40:	89 78 6c             	mov    %edi,0x6c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104d43:	e8 92 11 00 00       	call   f0105eda <cpunum>
f0104d48:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d4b:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104d51:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	curenv->env_tf.tf_regs.reg_eax = 0;
f0104d58:	e8 7d 11 00 00       	call   f0105eda <cpunum>
f0104d5d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d60:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104d66:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104d6d:	e8 7e f9 ff ff       	call   f01046f0 <sched_yield>
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!

	struct Env *e; 
	int env = envid2env(envid, &e, 1);
f0104d72:	83 ec 04             	sub    $0x4,%esp
f0104d75:	6a 01                	push   $0x1
f0104d77:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104d7a:	50                   	push   %eax
f0104d7b:	ff 75 0c             	pushl  0xc(%ebp)
f0104d7e:	e8 c2 e2 ff ff       	call   f0103045 <envid2env>

	if (env < 0) { 
f0104d83:	83 c4 10             	add    $0x10,%esp
f0104d86:	85 c0                	test   %eax,%eax
f0104d88:	78 47                	js     f0104dd1 <syscall+0x618>
		return env;
	}

	user_mem_assert(e, tf, sizeof(struct Trapframe), PTE_U);
f0104d8a:	6a 04                	push   $0x4
f0104d8c:	6a 44                	push   $0x44
f0104d8e:	ff 75 10             	pushl  0x10(%ebp)
f0104d91:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104d94:	e8 dc e1 ff ff       	call   f0102f75 <user_mem_assert>

	e->env_tf = *tf;
f0104d99:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104d9e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104da1:	8b 75 10             	mov    0x10(%ebp),%esi
f0104da4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_tf.tf_eflags |= FL_IF;
f0104da6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
	e->env_tf.tf_cs = GD_UT | 3;
f0104da9:	66 c7 42 34 1b 00    	movw   $0x1b,0x34(%edx)
	//shoutout to fgt(x)
	e->env_tf.tf_eflags &= ~FL_IOPL_3;
f0104daf:	8b 42 38             	mov    0x38(%edx),%eax
f0104db2:	80 e4 cf             	and    $0xcf,%ah
f0104db5:	80 cc 02             	or     $0x2,%ah
f0104db8:	89 42 38             	mov    %eax,0x38(%edx)
f0104dbb:	83 c4 10             	add    $0x10,%esp

	return 0;
f0104dbe:	b8 00 00 00 00       	mov    $0x0,%eax
f0104dc3:	eb 0c                	jmp    f0104dd1 <syscall+0x618>

		case SYS_env_set_trapframe:
			return sys_env_set_trapframe(a1, (struct Trapframe*)a2);

		default:
			return -E_INVAL;
f0104dc5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104dca:	eb 05                	jmp    f0104dd1 <syscall+0x618>

		case SYS_ipc_try_send:
			return sys_ipc_try_send(a1, a2, (void*)a3, a4);

		case SYS_ipc_recv:
			return sys_ipc_recv((void*)a1);
f0104dcc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			return sys_env_set_trapframe(a1, (struct Trapframe*)a2);

		default:
			return -E_INVAL;
	}
}
f0104dd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104dd4:	5b                   	pop    %ebx
f0104dd5:	5e                   	pop    %esi
f0104dd6:	5f                   	pop    %edi
f0104dd7:	5d                   	pop    %ebp
f0104dd8:	c3                   	ret    

f0104dd9 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104dd9:	55                   	push   %ebp
f0104dda:	89 e5                	mov    %esp,%ebp
f0104ddc:	57                   	push   %edi
f0104ddd:	56                   	push   %esi
f0104dde:	53                   	push   %ebx
f0104ddf:	83 ec 14             	sub    $0x14,%esp
f0104de2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104de5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104de8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104deb:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104dee:	8b 1a                	mov    (%edx),%ebx
f0104df0:	8b 01                	mov    (%ecx),%eax
f0104df2:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104df5:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104dfc:	eb 7f                	jmp    f0104e7d <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0104dfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104e01:	01 d8                	add    %ebx,%eax
f0104e03:	89 c6                	mov    %eax,%esi
f0104e05:	c1 ee 1f             	shr    $0x1f,%esi
f0104e08:	01 c6                	add    %eax,%esi
f0104e0a:	d1 fe                	sar    %esi
f0104e0c:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104e0f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104e12:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104e15:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104e17:	eb 03                	jmp    f0104e1c <stab_binsearch+0x43>
			m--;
f0104e19:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104e1c:	39 c3                	cmp    %eax,%ebx
f0104e1e:	7f 0d                	jg     f0104e2d <stab_binsearch+0x54>
f0104e20:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104e24:	83 ea 0c             	sub    $0xc,%edx
f0104e27:	39 f9                	cmp    %edi,%ecx
f0104e29:	75 ee                	jne    f0104e19 <stab_binsearch+0x40>
f0104e2b:	eb 05                	jmp    f0104e32 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104e2d:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104e30:	eb 4b                	jmp    f0104e7d <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104e32:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104e35:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104e38:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104e3c:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104e3f:	76 11                	jbe    f0104e52 <stab_binsearch+0x79>
			*region_left = m;
f0104e41:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104e44:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104e46:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104e49:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104e50:	eb 2b                	jmp    f0104e7d <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104e52:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104e55:	73 14                	jae    f0104e6b <stab_binsearch+0x92>
			*region_right = m - 1;
f0104e57:	83 e8 01             	sub    $0x1,%eax
f0104e5a:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104e5d:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104e60:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104e62:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104e69:	eb 12                	jmp    f0104e7d <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104e6b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104e6e:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104e70:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104e74:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104e76:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104e7d:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104e80:	0f 8e 78 ff ff ff    	jle    f0104dfe <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104e86:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104e8a:	75 0f                	jne    f0104e9b <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0104e8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e8f:	8b 00                	mov    (%eax),%eax
f0104e91:	83 e8 01             	sub    $0x1,%eax
f0104e94:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104e97:	89 06                	mov    %eax,(%esi)
f0104e99:	eb 2c                	jmp    f0104ec7 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104e9b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e9e:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104ea0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104ea3:	8b 0e                	mov    (%esi),%ecx
f0104ea5:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104ea8:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104eab:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104eae:	eb 03                	jmp    f0104eb3 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104eb0:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104eb3:	39 c8                	cmp    %ecx,%eax
f0104eb5:	7e 0b                	jle    f0104ec2 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0104eb7:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104ebb:	83 ea 0c             	sub    $0xc,%edx
f0104ebe:	39 df                	cmp    %ebx,%edi
f0104ec0:	75 ee                	jne    f0104eb0 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104ec2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104ec5:	89 06                	mov    %eax,(%esi)
	}
}
f0104ec7:	83 c4 14             	add    $0x14,%esp
f0104eca:	5b                   	pop    %ebx
f0104ecb:	5e                   	pop    %esi
f0104ecc:	5f                   	pop    %edi
f0104ecd:	5d                   	pop    %ebp
f0104ece:	c3                   	ret    

f0104ecf <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104ecf:	55                   	push   %ebp
f0104ed0:	89 e5                	mov    %esp,%ebp
f0104ed2:	57                   	push   %edi
f0104ed3:	56                   	push   %esi
f0104ed4:	53                   	push   %ebx
f0104ed5:	83 ec 3c             	sub    $0x3c,%esp
f0104ed8:	8b 75 08             	mov    0x8(%ebp),%esi
f0104edb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104ede:	c7 03 38 7d 10 f0    	movl   $0xf0107d38,(%ebx)
	info->eip_line = 0;
f0104ee4:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104eeb:	c7 43 08 38 7d 10 f0 	movl   $0xf0107d38,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104ef2:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104ef9:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104efc:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104f03:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0104f09:	77 21                	ja     f0104f2c <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104f0b:	a1 00 00 20 00       	mov    0x200000,%eax
f0104f10:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stab_end = usd->stab_end;
f0104f13:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0104f18:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f0104f1e:	89 7d b8             	mov    %edi,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0104f21:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f0104f27:	89 7d c0             	mov    %edi,-0x40(%ebp)
f0104f2a:	eb 1a                	jmp    f0104f46 <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104f2c:	c7 45 c0 64 5e 11 f0 	movl   $0xf0115e64,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104f33:	c7 45 b8 f9 26 11 f0 	movl   $0xf01126f9,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104f3a:	b8 f8 26 11 f0       	mov    $0xf01126f8,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104f3f:	c7 45 bc d0 82 10 f0 	movl   $0xf01082d0,-0x44(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104f46:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104f49:	39 7d b8             	cmp    %edi,-0x48(%ebp)
f0104f4c:	0f 83 95 01 00 00    	jae    f01050e7 <debuginfo_eip+0x218>
f0104f52:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f0104f56:	0f 85 92 01 00 00    	jne    f01050ee <debuginfo_eip+0x21f>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104f5c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104f63:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0104f66:	29 f8                	sub    %edi,%eax
f0104f68:	c1 f8 02             	sar    $0x2,%eax
f0104f6b:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104f71:	83 e8 01             	sub    $0x1,%eax
f0104f74:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104f77:	56                   	push   %esi
f0104f78:	6a 64                	push   $0x64
f0104f7a:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104f7d:	89 c1                	mov    %eax,%ecx
f0104f7f:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104f82:	89 f8                	mov    %edi,%eax
f0104f84:	e8 50 fe ff ff       	call   f0104dd9 <stab_binsearch>
	if (lfile == 0)
f0104f89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f8c:	83 c4 08             	add    $0x8,%esp
f0104f8f:	85 c0                	test   %eax,%eax
f0104f91:	0f 84 5e 01 00 00    	je     f01050f5 <debuginfo_eip+0x226>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104f97:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104f9a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104f9d:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104fa0:	56                   	push   %esi
f0104fa1:	6a 24                	push   $0x24
f0104fa3:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0104fa6:	89 c1                	mov    %eax,%ecx
f0104fa8:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104fab:	89 f8                	mov    %edi,%eax
f0104fad:	e8 27 fe ff ff       	call   f0104dd9 <stab_binsearch>

	if (lfun <= rfun) {
f0104fb2:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104fb5:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104fb8:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0104fbb:	83 c4 08             	add    $0x8,%esp
f0104fbe:	39 d0                	cmp    %edx,%eax
f0104fc0:	7f 2b                	jg     f0104fed <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104fc2:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104fc5:	8d 0c 97             	lea    (%edi,%edx,4),%ecx
f0104fc8:	8b 11                	mov    (%ecx),%edx
f0104fca:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104fcd:	2b 7d b8             	sub    -0x48(%ebp),%edi
f0104fd0:	39 fa                	cmp    %edi,%edx
f0104fd2:	73 06                	jae    f0104fda <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104fd4:	03 55 b8             	add    -0x48(%ebp),%edx
f0104fd7:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104fda:	8b 51 08             	mov    0x8(%ecx),%edx
f0104fdd:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104fe0:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0104fe2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104fe5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104fe8:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104feb:	eb 0f                	jmp    f0104ffc <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104fed:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0104ff0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ff3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104ff6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ff9:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104ffc:	83 ec 08             	sub    $0x8,%esp
f0104fff:	6a 3a                	push   $0x3a
f0105001:	ff 73 08             	pushl  0x8(%ebx)
f0105004:	e8 92 08 00 00       	call   f010589b <strfind>
f0105009:	2b 43 08             	sub    0x8(%ebx),%eax
f010500c:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f010500f:	83 c4 08             	add    $0x8,%esp
f0105012:	56                   	push   %esi
f0105013:	6a 44                	push   $0x44
f0105015:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0105018:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010501b:	8b 75 bc             	mov    -0x44(%ebp),%esi
f010501e:	89 f0                	mov    %esi,%eax
f0105020:	e8 b4 fd ff ff       	call   f0104dd9 <stab_binsearch>
	if (lline == rline) {
f0105025:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105028:	83 c4 10             	add    $0x10,%esp
f010502b:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f010502e:	0f 85 c8 00 00 00    	jne    f01050fc <debuginfo_eip+0x22d>
		info->eip_line = stabs[lline].n_desc;
f0105034:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105037:	8d 14 96             	lea    (%esi,%edx,4),%edx
f010503a:	0f b7 4a 06          	movzwl 0x6(%edx),%ecx
f010503e:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105041:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105044:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0105048:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010504b:	eb 0a                	jmp    f0105057 <debuginfo_eip+0x188>
f010504d:	83 e8 01             	sub    $0x1,%eax
f0105050:	83 ea 0c             	sub    $0xc,%edx
f0105053:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0105057:	39 c7                	cmp    %eax,%edi
f0105059:	7e 05                	jle    f0105060 <debuginfo_eip+0x191>
f010505b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010505e:	eb 47                	jmp    f01050a7 <debuginfo_eip+0x1d8>
	       && stabs[lline].n_type != N_SOL
f0105060:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0105064:	80 f9 84             	cmp    $0x84,%cl
f0105067:	75 0e                	jne    f0105077 <debuginfo_eip+0x1a8>
f0105069:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010506c:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0105070:	74 1c                	je     f010508e <debuginfo_eip+0x1bf>
f0105072:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105075:	eb 17                	jmp    f010508e <debuginfo_eip+0x1bf>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105077:	80 f9 64             	cmp    $0x64,%cl
f010507a:	75 d1                	jne    f010504d <debuginfo_eip+0x17e>
f010507c:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0105080:	74 cb                	je     f010504d <debuginfo_eip+0x17e>
f0105082:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105085:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0105089:	74 03                	je     f010508e <debuginfo_eip+0x1bf>
f010508b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010508e:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105091:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0105094:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0105097:	8b 45 c0             	mov    -0x40(%ebp),%eax
f010509a:	8b 75 b8             	mov    -0x48(%ebp),%esi
f010509d:	29 f0                	sub    %esi,%eax
f010509f:	39 c2                	cmp    %eax,%edx
f01050a1:	73 04                	jae    f01050a7 <debuginfo_eip+0x1d8>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01050a3:	01 f2                	add    %esi,%edx
f01050a5:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01050a7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01050aa:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01050ad:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01050b2:	39 f2                	cmp    %esi,%edx
f01050b4:	7d 52                	jge    f0105108 <debuginfo_eip+0x239>
		for (lline = lfun + 1;
f01050b6:	83 c2 01             	add    $0x1,%edx
f01050b9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01050bc:	89 d0                	mov    %edx,%eax
f01050be:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01050c1:	8b 7d bc             	mov    -0x44(%ebp),%edi
f01050c4:	8d 14 97             	lea    (%edi,%edx,4),%edx
f01050c7:	eb 04                	jmp    f01050cd <debuginfo_eip+0x1fe>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01050c9:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01050cd:	39 c6                	cmp    %eax,%esi
f01050cf:	7e 32                	jle    f0105103 <debuginfo_eip+0x234>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01050d1:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01050d5:	83 c0 01             	add    $0x1,%eax
f01050d8:	83 c2 0c             	add    $0xc,%edx
f01050db:	80 f9 a0             	cmp    $0xa0,%cl
f01050de:	74 e9                	je     f01050c9 <debuginfo_eip+0x1fa>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01050e0:	b8 00 00 00 00       	mov    $0x0,%eax
f01050e5:	eb 21                	jmp    f0105108 <debuginfo_eip+0x239>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01050e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01050ec:	eb 1a                	jmp    f0105108 <debuginfo_eip+0x239>
f01050ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01050f3:	eb 13                	jmp    f0105108 <debuginfo_eip+0x239>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f01050f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01050fa:	eb 0c                	jmp    f0105108 <debuginfo_eip+0x239>
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline == rline) {
		info->eip_line = stabs[lline].n_desc;
	} else {
		return -1;	
f01050fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105101:	eb 05                	jmp    f0105108 <debuginfo_eip+0x239>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105103:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105108:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010510b:	5b                   	pop    %ebx
f010510c:	5e                   	pop    %esi
f010510d:	5f                   	pop    %edi
f010510e:	5d                   	pop    %ebp
f010510f:	c3                   	ret    

f0105110 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105110:	55                   	push   %ebp
f0105111:	89 e5                	mov    %esp,%ebp
f0105113:	57                   	push   %edi
f0105114:	56                   	push   %esi
f0105115:	53                   	push   %ebx
f0105116:	83 ec 1c             	sub    $0x1c,%esp
f0105119:	89 c7                	mov    %eax,%edi
f010511b:	89 d6                	mov    %edx,%esi
f010511d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105120:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105123:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105126:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105129:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010512c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105131:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105134:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0105137:	39 d3                	cmp    %edx,%ebx
f0105139:	72 05                	jb     f0105140 <printnum+0x30>
f010513b:	39 45 10             	cmp    %eax,0x10(%ebp)
f010513e:	77 45                	ja     f0105185 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105140:	83 ec 0c             	sub    $0xc,%esp
f0105143:	ff 75 18             	pushl  0x18(%ebp)
f0105146:	8b 45 14             	mov    0x14(%ebp),%eax
f0105149:	8d 58 ff             	lea    -0x1(%eax),%ebx
f010514c:	53                   	push   %ebx
f010514d:	ff 75 10             	pushl  0x10(%ebp)
f0105150:	83 ec 08             	sub    $0x8,%esp
f0105153:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105156:	ff 75 e0             	pushl  -0x20(%ebp)
f0105159:	ff 75 dc             	pushl  -0x24(%ebp)
f010515c:	ff 75 d8             	pushl  -0x28(%ebp)
f010515f:	e8 7c 11 00 00       	call   f01062e0 <__udivdi3>
f0105164:	83 c4 18             	add    $0x18,%esp
f0105167:	52                   	push   %edx
f0105168:	50                   	push   %eax
f0105169:	89 f2                	mov    %esi,%edx
f010516b:	89 f8                	mov    %edi,%eax
f010516d:	e8 9e ff ff ff       	call   f0105110 <printnum>
f0105172:	83 c4 20             	add    $0x20,%esp
f0105175:	eb 18                	jmp    f010518f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105177:	83 ec 08             	sub    $0x8,%esp
f010517a:	56                   	push   %esi
f010517b:	ff 75 18             	pushl  0x18(%ebp)
f010517e:	ff d7                	call   *%edi
f0105180:	83 c4 10             	add    $0x10,%esp
f0105183:	eb 03                	jmp    f0105188 <printnum+0x78>
f0105185:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105188:	83 eb 01             	sub    $0x1,%ebx
f010518b:	85 db                	test   %ebx,%ebx
f010518d:	7f e8                	jg     f0105177 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010518f:	83 ec 08             	sub    $0x8,%esp
f0105192:	56                   	push   %esi
f0105193:	83 ec 04             	sub    $0x4,%esp
f0105196:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105199:	ff 75 e0             	pushl  -0x20(%ebp)
f010519c:	ff 75 dc             	pushl  -0x24(%ebp)
f010519f:	ff 75 d8             	pushl  -0x28(%ebp)
f01051a2:	e8 69 12 00 00       	call   f0106410 <__umoddi3>
f01051a7:	83 c4 14             	add    $0x14,%esp
f01051aa:	0f be 80 42 7d 10 f0 	movsbl -0xfef82be(%eax),%eax
f01051b1:	50                   	push   %eax
f01051b2:	ff d7                	call   *%edi
}
f01051b4:	83 c4 10             	add    $0x10,%esp
f01051b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01051ba:	5b                   	pop    %ebx
f01051bb:	5e                   	pop    %esi
f01051bc:	5f                   	pop    %edi
f01051bd:	5d                   	pop    %ebp
f01051be:	c3                   	ret    

f01051bf <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01051bf:	55                   	push   %ebp
f01051c0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01051c2:	83 fa 01             	cmp    $0x1,%edx
f01051c5:	7e 0e                	jle    f01051d5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01051c7:	8b 10                	mov    (%eax),%edx
f01051c9:	8d 4a 08             	lea    0x8(%edx),%ecx
f01051cc:	89 08                	mov    %ecx,(%eax)
f01051ce:	8b 02                	mov    (%edx),%eax
f01051d0:	8b 52 04             	mov    0x4(%edx),%edx
f01051d3:	eb 22                	jmp    f01051f7 <getuint+0x38>
	else if (lflag)
f01051d5:	85 d2                	test   %edx,%edx
f01051d7:	74 10                	je     f01051e9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01051d9:	8b 10                	mov    (%eax),%edx
f01051db:	8d 4a 04             	lea    0x4(%edx),%ecx
f01051de:	89 08                	mov    %ecx,(%eax)
f01051e0:	8b 02                	mov    (%edx),%eax
f01051e2:	ba 00 00 00 00       	mov    $0x0,%edx
f01051e7:	eb 0e                	jmp    f01051f7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01051e9:	8b 10                	mov    (%eax),%edx
f01051eb:	8d 4a 04             	lea    0x4(%edx),%ecx
f01051ee:	89 08                	mov    %ecx,(%eax)
f01051f0:	8b 02                	mov    (%edx),%eax
f01051f2:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01051f7:	5d                   	pop    %ebp
f01051f8:	c3                   	ret    

f01051f9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01051f9:	55                   	push   %ebp
f01051fa:	89 e5                	mov    %esp,%ebp
f01051fc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01051ff:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105203:	8b 10                	mov    (%eax),%edx
f0105205:	3b 50 04             	cmp    0x4(%eax),%edx
f0105208:	73 0a                	jae    f0105214 <sprintputch+0x1b>
		*b->buf++ = ch;
f010520a:	8d 4a 01             	lea    0x1(%edx),%ecx
f010520d:	89 08                	mov    %ecx,(%eax)
f010520f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105212:	88 02                	mov    %al,(%edx)
}
f0105214:	5d                   	pop    %ebp
f0105215:	c3                   	ret    

f0105216 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105216:	55                   	push   %ebp
f0105217:	89 e5                	mov    %esp,%ebp
f0105219:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010521c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010521f:	50                   	push   %eax
f0105220:	ff 75 10             	pushl  0x10(%ebp)
f0105223:	ff 75 0c             	pushl  0xc(%ebp)
f0105226:	ff 75 08             	pushl  0x8(%ebp)
f0105229:	e8 05 00 00 00       	call   f0105233 <vprintfmt>
	va_end(ap);
}
f010522e:	83 c4 10             	add    $0x10,%esp
f0105231:	c9                   	leave  
f0105232:	c3                   	ret    

f0105233 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105233:	55                   	push   %ebp
f0105234:	89 e5                	mov    %esp,%ebp
f0105236:	57                   	push   %edi
f0105237:	56                   	push   %esi
f0105238:	53                   	push   %ebx
f0105239:	83 ec 2c             	sub    $0x2c,%esp
f010523c:	8b 75 08             	mov    0x8(%ebp),%esi
f010523f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105242:	8b 7d 10             	mov    0x10(%ebp),%edi
f0105245:	eb 12                	jmp    f0105259 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0105247:	85 c0                	test   %eax,%eax
f0105249:	0f 84 89 03 00 00    	je     f01055d8 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f010524f:	83 ec 08             	sub    $0x8,%esp
f0105252:	53                   	push   %ebx
f0105253:	50                   	push   %eax
f0105254:	ff d6                	call   *%esi
f0105256:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105259:	83 c7 01             	add    $0x1,%edi
f010525c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105260:	83 f8 25             	cmp    $0x25,%eax
f0105263:	75 e2                	jne    f0105247 <vprintfmt+0x14>
f0105265:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0105269:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0105270:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105277:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f010527e:	ba 00 00 00 00       	mov    $0x0,%edx
f0105283:	eb 07                	jmp    f010528c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105285:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0105288:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010528c:	8d 47 01             	lea    0x1(%edi),%eax
f010528f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105292:	0f b6 07             	movzbl (%edi),%eax
f0105295:	0f b6 c8             	movzbl %al,%ecx
f0105298:	83 e8 23             	sub    $0x23,%eax
f010529b:	3c 55                	cmp    $0x55,%al
f010529d:	0f 87 1a 03 00 00    	ja     f01055bd <vprintfmt+0x38a>
f01052a3:	0f b6 c0             	movzbl %al,%eax
f01052a6:	ff 24 85 80 7e 10 f0 	jmp    *-0xfef8180(,%eax,4)
f01052ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01052b0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f01052b4:	eb d6                	jmp    f010528c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01052b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01052b9:	b8 00 00 00 00       	mov    $0x0,%eax
f01052be:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01052c1:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01052c4:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f01052c8:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f01052cb:	8d 51 d0             	lea    -0x30(%ecx),%edx
f01052ce:	83 fa 09             	cmp    $0x9,%edx
f01052d1:	77 39                	ja     f010530c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01052d3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f01052d6:	eb e9                	jmp    f01052c1 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01052d8:	8b 45 14             	mov    0x14(%ebp),%eax
f01052db:	8d 48 04             	lea    0x4(%eax),%ecx
f01052de:	89 4d 14             	mov    %ecx,0x14(%ebp)
f01052e1:	8b 00                	mov    (%eax),%eax
f01052e3:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01052e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01052e9:	eb 27                	jmp    f0105312 <vprintfmt+0xdf>
f01052eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01052ee:	85 c0                	test   %eax,%eax
f01052f0:	b9 00 00 00 00       	mov    $0x0,%ecx
f01052f5:	0f 49 c8             	cmovns %eax,%ecx
f01052f8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01052fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01052fe:	eb 8c                	jmp    f010528c <vprintfmt+0x59>
f0105300:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105303:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f010530a:	eb 80                	jmp    f010528c <vprintfmt+0x59>
f010530c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010530f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0105312:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105316:	0f 89 70 ff ff ff    	jns    f010528c <vprintfmt+0x59>
				width = precision, precision = -1;
f010531c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010531f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105322:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105329:	e9 5e ff ff ff       	jmp    f010528c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010532e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105331:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105334:	e9 53 ff ff ff       	jmp    f010528c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105339:	8b 45 14             	mov    0x14(%ebp),%eax
f010533c:	8d 50 04             	lea    0x4(%eax),%edx
f010533f:	89 55 14             	mov    %edx,0x14(%ebp)
f0105342:	83 ec 08             	sub    $0x8,%esp
f0105345:	53                   	push   %ebx
f0105346:	ff 30                	pushl  (%eax)
f0105348:	ff d6                	call   *%esi
			break;
f010534a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010534d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105350:	e9 04 ff ff ff       	jmp    f0105259 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105355:	8b 45 14             	mov    0x14(%ebp),%eax
f0105358:	8d 50 04             	lea    0x4(%eax),%edx
f010535b:	89 55 14             	mov    %edx,0x14(%ebp)
f010535e:	8b 00                	mov    (%eax),%eax
f0105360:	99                   	cltd   
f0105361:	31 d0                	xor    %edx,%eax
f0105363:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105365:	83 f8 0f             	cmp    $0xf,%eax
f0105368:	7f 0b                	jg     f0105375 <vprintfmt+0x142>
f010536a:	8b 14 85 e0 7f 10 f0 	mov    -0xfef8020(,%eax,4),%edx
f0105371:	85 d2                	test   %edx,%edx
f0105373:	75 18                	jne    f010538d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0105375:	50                   	push   %eax
f0105376:	68 5a 7d 10 f0       	push   $0xf0107d5a
f010537b:	53                   	push   %ebx
f010537c:	56                   	push   %esi
f010537d:	e8 94 fe ff ff       	call   f0105216 <printfmt>
f0105382:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105385:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0105388:	e9 cc fe ff ff       	jmp    f0105259 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f010538d:	52                   	push   %edx
f010538e:	68 a9 74 10 f0       	push   $0xf01074a9
f0105393:	53                   	push   %ebx
f0105394:	56                   	push   %esi
f0105395:	e8 7c fe ff ff       	call   f0105216 <printfmt>
f010539a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010539d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01053a0:	e9 b4 fe ff ff       	jmp    f0105259 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01053a5:	8b 45 14             	mov    0x14(%ebp),%eax
f01053a8:	8d 50 04             	lea    0x4(%eax),%edx
f01053ab:	89 55 14             	mov    %edx,0x14(%ebp)
f01053ae:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f01053b0:	85 ff                	test   %edi,%edi
f01053b2:	b8 53 7d 10 f0       	mov    $0xf0107d53,%eax
f01053b7:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f01053ba:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01053be:	0f 8e 94 00 00 00    	jle    f0105458 <vprintfmt+0x225>
f01053c4:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f01053c8:	0f 84 98 00 00 00    	je     f0105466 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f01053ce:	83 ec 08             	sub    $0x8,%esp
f01053d1:	ff 75 d0             	pushl  -0x30(%ebp)
f01053d4:	57                   	push   %edi
f01053d5:	e8 77 03 00 00       	call   f0105751 <strnlen>
f01053da:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01053dd:	29 c1                	sub    %eax,%ecx
f01053df:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f01053e2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f01053e5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f01053e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01053ec:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01053ef:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01053f1:	eb 0f                	jmp    f0105402 <vprintfmt+0x1cf>
					putch(padc, putdat);
f01053f3:	83 ec 08             	sub    $0x8,%esp
f01053f6:	53                   	push   %ebx
f01053f7:	ff 75 e0             	pushl  -0x20(%ebp)
f01053fa:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01053fc:	83 ef 01             	sub    $0x1,%edi
f01053ff:	83 c4 10             	add    $0x10,%esp
f0105402:	85 ff                	test   %edi,%edi
f0105404:	7f ed                	jg     f01053f3 <vprintfmt+0x1c0>
f0105406:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105409:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010540c:	85 c9                	test   %ecx,%ecx
f010540e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105413:	0f 49 c1             	cmovns %ecx,%eax
f0105416:	29 c1                	sub    %eax,%ecx
f0105418:	89 75 08             	mov    %esi,0x8(%ebp)
f010541b:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010541e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105421:	89 cb                	mov    %ecx,%ebx
f0105423:	eb 4d                	jmp    f0105472 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105425:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105429:	74 1b                	je     f0105446 <vprintfmt+0x213>
f010542b:	0f be c0             	movsbl %al,%eax
f010542e:	83 e8 20             	sub    $0x20,%eax
f0105431:	83 f8 5e             	cmp    $0x5e,%eax
f0105434:	76 10                	jbe    f0105446 <vprintfmt+0x213>
					putch('?', putdat);
f0105436:	83 ec 08             	sub    $0x8,%esp
f0105439:	ff 75 0c             	pushl  0xc(%ebp)
f010543c:	6a 3f                	push   $0x3f
f010543e:	ff 55 08             	call   *0x8(%ebp)
f0105441:	83 c4 10             	add    $0x10,%esp
f0105444:	eb 0d                	jmp    f0105453 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0105446:	83 ec 08             	sub    $0x8,%esp
f0105449:	ff 75 0c             	pushl  0xc(%ebp)
f010544c:	52                   	push   %edx
f010544d:	ff 55 08             	call   *0x8(%ebp)
f0105450:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105453:	83 eb 01             	sub    $0x1,%ebx
f0105456:	eb 1a                	jmp    f0105472 <vprintfmt+0x23f>
f0105458:	89 75 08             	mov    %esi,0x8(%ebp)
f010545b:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010545e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105461:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105464:	eb 0c                	jmp    f0105472 <vprintfmt+0x23f>
f0105466:	89 75 08             	mov    %esi,0x8(%ebp)
f0105469:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010546c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010546f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105472:	83 c7 01             	add    $0x1,%edi
f0105475:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105479:	0f be d0             	movsbl %al,%edx
f010547c:	85 d2                	test   %edx,%edx
f010547e:	74 23                	je     f01054a3 <vprintfmt+0x270>
f0105480:	85 f6                	test   %esi,%esi
f0105482:	78 a1                	js     f0105425 <vprintfmt+0x1f2>
f0105484:	83 ee 01             	sub    $0x1,%esi
f0105487:	79 9c                	jns    f0105425 <vprintfmt+0x1f2>
f0105489:	89 df                	mov    %ebx,%edi
f010548b:	8b 75 08             	mov    0x8(%ebp),%esi
f010548e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105491:	eb 18                	jmp    f01054ab <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105493:	83 ec 08             	sub    $0x8,%esp
f0105496:	53                   	push   %ebx
f0105497:	6a 20                	push   $0x20
f0105499:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010549b:	83 ef 01             	sub    $0x1,%edi
f010549e:	83 c4 10             	add    $0x10,%esp
f01054a1:	eb 08                	jmp    f01054ab <vprintfmt+0x278>
f01054a3:	89 df                	mov    %ebx,%edi
f01054a5:	8b 75 08             	mov    0x8(%ebp),%esi
f01054a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01054ab:	85 ff                	test   %edi,%edi
f01054ad:	7f e4                	jg     f0105493 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01054af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01054b2:	e9 a2 fd ff ff       	jmp    f0105259 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01054b7:	83 fa 01             	cmp    $0x1,%edx
f01054ba:	7e 16                	jle    f01054d2 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f01054bc:	8b 45 14             	mov    0x14(%ebp),%eax
f01054bf:	8d 50 08             	lea    0x8(%eax),%edx
f01054c2:	89 55 14             	mov    %edx,0x14(%ebp)
f01054c5:	8b 50 04             	mov    0x4(%eax),%edx
f01054c8:	8b 00                	mov    (%eax),%eax
f01054ca:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01054cd:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01054d0:	eb 32                	jmp    f0105504 <vprintfmt+0x2d1>
	else if (lflag)
f01054d2:	85 d2                	test   %edx,%edx
f01054d4:	74 18                	je     f01054ee <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f01054d6:	8b 45 14             	mov    0x14(%ebp),%eax
f01054d9:	8d 50 04             	lea    0x4(%eax),%edx
f01054dc:	89 55 14             	mov    %edx,0x14(%ebp)
f01054df:	8b 00                	mov    (%eax),%eax
f01054e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01054e4:	89 c1                	mov    %eax,%ecx
f01054e6:	c1 f9 1f             	sar    $0x1f,%ecx
f01054e9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01054ec:	eb 16                	jmp    f0105504 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f01054ee:	8b 45 14             	mov    0x14(%ebp),%eax
f01054f1:	8d 50 04             	lea    0x4(%eax),%edx
f01054f4:	89 55 14             	mov    %edx,0x14(%ebp)
f01054f7:	8b 00                	mov    (%eax),%eax
f01054f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01054fc:	89 c1                	mov    %eax,%ecx
f01054fe:	c1 f9 1f             	sar    $0x1f,%ecx
f0105501:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105504:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105507:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010550a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010550f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105513:	79 74                	jns    f0105589 <vprintfmt+0x356>
				putch('-', putdat);
f0105515:	83 ec 08             	sub    $0x8,%esp
f0105518:	53                   	push   %ebx
f0105519:	6a 2d                	push   $0x2d
f010551b:	ff d6                	call   *%esi
				num = -(long long) num;
f010551d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105520:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105523:	f7 d8                	neg    %eax
f0105525:	83 d2 00             	adc    $0x0,%edx
f0105528:	f7 da                	neg    %edx
f010552a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f010552d:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0105532:	eb 55                	jmp    f0105589 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105534:	8d 45 14             	lea    0x14(%ebp),%eax
f0105537:	e8 83 fc ff ff       	call   f01051bf <getuint>
			base = 10;
f010553c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0105541:	eb 46                	jmp    f0105589 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0105543:	8d 45 14             	lea    0x14(%ebp),%eax
f0105546:	e8 74 fc ff ff       	call   f01051bf <getuint>
			base = 8;
f010554b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0105550:	eb 37                	jmp    f0105589 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f0105552:	83 ec 08             	sub    $0x8,%esp
f0105555:	53                   	push   %ebx
f0105556:	6a 30                	push   $0x30
f0105558:	ff d6                	call   *%esi
			putch('x', putdat);
f010555a:	83 c4 08             	add    $0x8,%esp
f010555d:	53                   	push   %ebx
f010555e:	6a 78                	push   $0x78
f0105560:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105562:	8b 45 14             	mov    0x14(%ebp),%eax
f0105565:	8d 50 04             	lea    0x4(%eax),%edx
f0105568:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010556b:	8b 00                	mov    (%eax),%eax
f010556d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0105572:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105575:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f010557a:	eb 0d                	jmp    f0105589 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010557c:	8d 45 14             	lea    0x14(%ebp),%eax
f010557f:	e8 3b fc ff ff       	call   f01051bf <getuint>
			base = 16;
f0105584:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105589:	83 ec 0c             	sub    $0xc,%esp
f010558c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0105590:	57                   	push   %edi
f0105591:	ff 75 e0             	pushl  -0x20(%ebp)
f0105594:	51                   	push   %ecx
f0105595:	52                   	push   %edx
f0105596:	50                   	push   %eax
f0105597:	89 da                	mov    %ebx,%edx
f0105599:	89 f0                	mov    %esi,%eax
f010559b:	e8 70 fb ff ff       	call   f0105110 <printnum>
			break;
f01055a0:	83 c4 20             	add    $0x20,%esp
f01055a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01055a6:	e9 ae fc ff ff       	jmp    f0105259 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01055ab:	83 ec 08             	sub    $0x8,%esp
f01055ae:	53                   	push   %ebx
f01055af:	51                   	push   %ecx
f01055b0:	ff d6                	call   *%esi
			break;
f01055b2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01055b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01055b8:	e9 9c fc ff ff       	jmp    f0105259 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01055bd:	83 ec 08             	sub    $0x8,%esp
f01055c0:	53                   	push   %ebx
f01055c1:	6a 25                	push   $0x25
f01055c3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01055c5:	83 c4 10             	add    $0x10,%esp
f01055c8:	eb 03                	jmp    f01055cd <vprintfmt+0x39a>
f01055ca:	83 ef 01             	sub    $0x1,%edi
f01055cd:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f01055d1:	75 f7                	jne    f01055ca <vprintfmt+0x397>
f01055d3:	e9 81 fc ff ff       	jmp    f0105259 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f01055d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01055db:	5b                   	pop    %ebx
f01055dc:	5e                   	pop    %esi
f01055dd:	5f                   	pop    %edi
f01055de:	5d                   	pop    %ebp
f01055df:	c3                   	ret    

f01055e0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01055e0:	55                   	push   %ebp
f01055e1:	89 e5                	mov    %esp,%ebp
f01055e3:	83 ec 18             	sub    $0x18,%esp
f01055e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01055e9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01055ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01055ef:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01055f3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01055f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01055fd:	85 c0                	test   %eax,%eax
f01055ff:	74 26                	je     f0105627 <vsnprintf+0x47>
f0105601:	85 d2                	test   %edx,%edx
f0105603:	7e 22                	jle    f0105627 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105605:	ff 75 14             	pushl  0x14(%ebp)
f0105608:	ff 75 10             	pushl  0x10(%ebp)
f010560b:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010560e:	50                   	push   %eax
f010560f:	68 f9 51 10 f0       	push   $0xf01051f9
f0105614:	e8 1a fc ff ff       	call   f0105233 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105619:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010561c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010561f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105622:	83 c4 10             	add    $0x10,%esp
f0105625:	eb 05                	jmp    f010562c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105627:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010562c:	c9                   	leave  
f010562d:	c3                   	ret    

f010562e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010562e:	55                   	push   %ebp
f010562f:	89 e5                	mov    %esp,%ebp
f0105631:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105634:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105637:	50                   	push   %eax
f0105638:	ff 75 10             	pushl  0x10(%ebp)
f010563b:	ff 75 0c             	pushl  0xc(%ebp)
f010563e:	ff 75 08             	pushl  0x8(%ebp)
f0105641:	e8 9a ff ff ff       	call   f01055e0 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105646:	c9                   	leave  
f0105647:	c3                   	ret    

f0105648 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105648:	55                   	push   %ebp
f0105649:	89 e5                	mov    %esp,%ebp
f010564b:	57                   	push   %edi
f010564c:	56                   	push   %esi
f010564d:	53                   	push   %ebx
f010564e:	83 ec 0c             	sub    $0xc,%esp
f0105651:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105654:	85 c0                	test   %eax,%eax
f0105656:	74 11                	je     f0105669 <readline+0x21>
		cprintf("%s", prompt);
f0105658:	83 ec 08             	sub    $0x8,%esp
f010565b:	50                   	push   %eax
f010565c:	68 a9 74 10 f0       	push   $0xf01074a9
f0105661:	e8 27 e2 ff ff       	call   f010388d <cprintf>
f0105666:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105669:	83 ec 0c             	sub    $0xc,%esp
f010566c:	6a 00                	push   $0x0
f010566e:	e8 47 b1 ff ff       	call   f01007ba <iscons>
f0105673:	89 c7                	mov    %eax,%edi
f0105675:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f0105678:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f010567d:	e8 27 b1 ff ff       	call   f01007a9 <getchar>
f0105682:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105684:	85 c0                	test   %eax,%eax
f0105686:	79 29                	jns    f01056b1 <readline+0x69>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f0105688:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f010568d:	83 fb f8             	cmp    $0xfffffff8,%ebx
f0105690:	0f 84 9b 00 00 00    	je     f0105731 <readline+0xe9>
				cprintf("read error: %e\n", c);
f0105696:	83 ec 08             	sub    $0x8,%esp
f0105699:	53                   	push   %ebx
f010569a:	68 3f 80 10 f0       	push   $0xf010803f
f010569f:	e8 e9 e1 ff ff       	call   f010388d <cprintf>
f01056a4:	83 c4 10             	add    $0x10,%esp
			return NULL;
f01056a7:	b8 00 00 00 00       	mov    $0x0,%eax
f01056ac:	e9 80 00 00 00       	jmp    f0105731 <readline+0xe9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01056b1:	83 f8 08             	cmp    $0x8,%eax
f01056b4:	0f 94 c2             	sete   %dl
f01056b7:	83 f8 7f             	cmp    $0x7f,%eax
f01056ba:	0f 94 c0             	sete   %al
f01056bd:	08 c2                	or     %al,%dl
f01056bf:	74 1a                	je     f01056db <readline+0x93>
f01056c1:	85 f6                	test   %esi,%esi
f01056c3:	7e 16                	jle    f01056db <readline+0x93>
			if (echoing)
f01056c5:	85 ff                	test   %edi,%edi
f01056c7:	74 0d                	je     f01056d6 <readline+0x8e>
				cputchar('\b');
f01056c9:	83 ec 0c             	sub    $0xc,%esp
f01056cc:	6a 08                	push   $0x8
f01056ce:	e8 c6 b0 ff ff       	call   f0100799 <cputchar>
f01056d3:	83 c4 10             	add    $0x10,%esp
			i--;
f01056d6:	83 ee 01             	sub    $0x1,%esi
f01056d9:	eb a2                	jmp    f010567d <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01056db:	83 fb 1f             	cmp    $0x1f,%ebx
f01056de:	7e 26                	jle    f0105706 <readline+0xbe>
f01056e0:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01056e6:	7f 1e                	jg     f0105706 <readline+0xbe>
			if (echoing)
f01056e8:	85 ff                	test   %edi,%edi
f01056ea:	74 0c                	je     f01056f8 <readline+0xb0>
				cputchar(c);
f01056ec:	83 ec 0c             	sub    $0xc,%esp
f01056ef:	53                   	push   %ebx
f01056f0:	e8 a4 b0 ff ff       	call   f0100799 <cputchar>
f01056f5:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01056f8:	88 9e 80 1a 21 f0    	mov    %bl,-0xfdee580(%esi)
f01056fe:	8d 76 01             	lea    0x1(%esi),%esi
f0105701:	e9 77 ff ff ff       	jmp    f010567d <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105706:	83 fb 0a             	cmp    $0xa,%ebx
f0105709:	74 09                	je     f0105714 <readline+0xcc>
f010570b:	83 fb 0d             	cmp    $0xd,%ebx
f010570e:	0f 85 69 ff ff ff    	jne    f010567d <readline+0x35>
			if (echoing)
f0105714:	85 ff                	test   %edi,%edi
f0105716:	74 0d                	je     f0105725 <readline+0xdd>
				cputchar('\n');
f0105718:	83 ec 0c             	sub    $0xc,%esp
f010571b:	6a 0a                	push   $0xa
f010571d:	e8 77 b0 ff ff       	call   f0100799 <cputchar>
f0105722:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0105725:	c6 86 80 1a 21 f0 00 	movb   $0x0,-0xfdee580(%esi)
			return buf;
f010572c:	b8 80 1a 21 f0       	mov    $0xf0211a80,%eax
		}
	}
}
f0105731:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105734:	5b                   	pop    %ebx
f0105735:	5e                   	pop    %esi
f0105736:	5f                   	pop    %edi
f0105737:	5d                   	pop    %ebp
f0105738:	c3                   	ret    

f0105739 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105739:	55                   	push   %ebp
f010573a:	89 e5                	mov    %esp,%ebp
f010573c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010573f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105744:	eb 03                	jmp    f0105749 <strlen+0x10>
		n++;
f0105746:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105749:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010574d:	75 f7                	jne    f0105746 <strlen+0xd>
		n++;
	return n;
}
f010574f:	5d                   	pop    %ebp
f0105750:	c3                   	ret    

f0105751 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105751:	55                   	push   %ebp
f0105752:	89 e5                	mov    %esp,%ebp
f0105754:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105757:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010575a:	ba 00 00 00 00       	mov    $0x0,%edx
f010575f:	eb 03                	jmp    f0105764 <strnlen+0x13>
		n++;
f0105761:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105764:	39 c2                	cmp    %eax,%edx
f0105766:	74 08                	je     f0105770 <strnlen+0x1f>
f0105768:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f010576c:	75 f3                	jne    f0105761 <strnlen+0x10>
f010576e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0105770:	5d                   	pop    %ebp
f0105771:	c3                   	ret    

f0105772 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105772:	55                   	push   %ebp
f0105773:	89 e5                	mov    %esp,%ebp
f0105775:	53                   	push   %ebx
f0105776:	8b 45 08             	mov    0x8(%ebp),%eax
f0105779:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010577c:	89 c2                	mov    %eax,%edx
f010577e:	83 c2 01             	add    $0x1,%edx
f0105781:	83 c1 01             	add    $0x1,%ecx
f0105784:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105788:	88 5a ff             	mov    %bl,-0x1(%edx)
f010578b:	84 db                	test   %bl,%bl
f010578d:	75 ef                	jne    f010577e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010578f:	5b                   	pop    %ebx
f0105790:	5d                   	pop    %ebp
f0105791:	c3                   	ret    

f0105792 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105792:	55                   	push   %ebp
f0105793:	89 e5                	mov    %esp,%ebp
f0105795:	53                   	push   %ebx
f0105796:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105799:	53                   	push   %ebx
f010579a:	e8 9a ff ff ff       	call   f0105739 <strlen>
f010579f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01057a2:	ff 75 0c             	pushl  0xc(%ebp)
f01057a5:	01 d8                	add    %ebx,%eax
f01057a7:	50                   	push   %eax
f01057a8:	e8 c5 ff ff ff       	call   f0105772 <strcpy>
	return dst;
}
f01057ad:	89 d8                	mov    %ebx,%eax
f01057af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01057b2:	c9                   	leave  
f01057b3:	c3                   	ret    

f01057b4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01057b4:	55                   	push   %ebp
f01057b5:	89 e5                	mov    %esp,%ebp
f01057b7:	56                   	push   %esi
f01057b8:	53                   	push   %ebx
f01057b9:	8b 75 08             	mov    0x8(%ebp),%esi
f01057bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01057bf:	89 f3                	mov    %esi,%ebx
f01057c1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01057c4:	89 f2                	mov    %esi,%edx
f01057c6:	eb 0f                	jmp    f01057d7 <strncpy+0x23>
		*dst++ = *src;
f01057c8:	83 c2 01             	add    $0x1,%edx
f01057cb:	0f b6 01             	movzbl (%ecx),%eax
f01057ce:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01057d1:	80 39 01             	cmpb   $0x1,(%ecx)
f01057d4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01057d7:	39 da                	cmp    %ebx,%edx
f01057d9:	75 ed                	jne    f01057c8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01057db:	89 f0                	mov    %esi,%eax
f01057dd:	5b                   	pop    %ebx
f01057de:	5e                   	pop    %esi
f01057df:	5d                   	pop    %ebp
f01057e0:	c3                   	ret    

f01057e1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01057e1:	55                   	push   %ebp
f01057e2:	89 e5                	mov    %esp,%ebp
f01057e4:	56                   	push   %esi
f01057e5:	53                   	push   %ebx
f01057e6:	8b 75 08             	mov    0x8(%ebp),%esi
f01057e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01057ec:	8b 55 10             	mov    0x10(%ebp),%edx
f01057ef:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01057f1:	85 d2                	test   %edx,%edx
f01057f3:	74 21                	je     f0105816 <strlcpy+0x35>
f01057f5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01057f9:	89 f2                	mov    %esi,%edx
f01057fb:	eb 09                	jmp    f0105806 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01057fd:	83 c2 01             	add    $0x1,%edx
f0105800:	83 c1 01             	add    $0x1,%ecx
f0105803:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105806:	39 c2                	cmp    %eax,%edx
f0105808:	74 09                	je     f0105813 <strlcpy+0x32>
f010580a:	0f b6 19             	movzbl (%ecx),%ebx
f010580d:	84 db                	test   %bl,%bl
f010580f:	75 ec                	jne    f01057fd <strlcpy+0x1c>
f0105811:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105813:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105816:	29 f0                	sub    %esi,%eax
}
f0105818:	5b                   	pop    %ebx
f0105819:	5e                   	pop    %esi
f010581a:	5d                   	pop    %ebp
f010581b:	c3                   	ret    

f010581c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010581c:	55                   	push   %ebp
f010581d:	89 e5                	mov    %esp,%ebp
f010581f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105822:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105825:	eb 06                	jmp    f010582d <strcmp+0x11>
		p++, q++;
f0105827:	83 c1 01             	add    $0x1,%ecx
f010582a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010582d:	0f b6 01             	movzbl (%ecx),%eax
f0105830:	84 c0                	test   %al,%al
f0105832:	74 04                	je     f0105838 <strcmp+0x1c>
f0105834:	3a 02                	cmp    (%edx),%al
f0105836:	74 ef                	je     f0105827 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105838:	0f b6 c0             	movzbl %al,%eax
f010583b:	0f b6 12             	movzbl (%edx),%edx
f010583e:	29 d0                	sub    %edx,%eax
}
f0105840:	5d                   	pop    %ebp
f0105841:	c3                   	ret    

f0105842 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105842:	55                   	push   %ebp
f0105843:	89 e5                	mov    %esp,%ebp
f0105845:	53                   	push   %ebx
f0105846:	8b 45 08             	mov    0x8(%ebp),%eax
f0105849:	8b 55 0c             	mov    0xc(%ebp),%edx
f010584c:	89 c3                	mov    %eax,%ebx
f010584e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105851:	eb 06                	jmp    f0105859 <strncmp+0x17>
		n--, p++, q++;
f0105853:	83 c0 01             	add    $0x1,%eax
f0105856:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105859:	39 d8                	cmp    %ebx,%eax
f010585b:	74 15                	je     f0105872 <strncmp+0x30>
f010585d:	0f b6 08             	movzbl (%eax),%ecx
f0105860:	84 c9                	test   %cl,%cl
f0105862:	74 04                	je     f0105868 <strncmp+0x26>
f0105864:	3a 0a                	cmp    (%edx),%cl
f0105866:	74 eb                	je     f0105853 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105868:	0f b6 00             	movzbl (%eax),%eax
f010586b:	0f b6 12             	movzbl (%edx),%edx
f010586e:	29 d0                	sub    %edx,%eax
f0105870:	eb 05                	jmp    f0105877 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105872:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105877:	5b                   	pop    %ebx
f0105878:	5d                   	pop    %ebp
f0105879:	c3                   	ret    

f010587a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010587a:	55                   	push   %ebp
f010587b:	89 e5                	mov    %esp,%ebp
f010587d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105880:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105884:	eb 07                	jmp    f010588d <strchr+0x13>
		if (*s == c)
f0105886:	38 ca                	cmp    %cl,%dl
f0105888:	74 0f                	je     f0105899 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010588a:	83 c0 01             	add    $0x1,%eax
f010588d:	0f b6 10             	movzbl (%eax),%edx
f0105890:	84 d2                	test   %dl,%dl
f0105892:	75 f2                	jne    f0105886 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0105894:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105899:	5d                   	pop    %ebp
f010589a:	c3                   	ret    

f010589b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010589b:	55                   	push   %ebp
f010589c:	89 e5                	mov    %esp,%ebp
f010589e:	8b 45 08             	mov    0x8(%ebp),%eax
f01058a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01058a5:	eb 03                	jmp    f01058aa <strfind+0xf>
f01058a7:	83 c0 01             	add    $0x1,%eax
f01058aa:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01058ad:	38 ca                	cmp    %cl,%dl
f01058af:	74 04                	je     f01058b5 <strfind+0x1a>
f01058b1:	84 d2                	test   %dl,%dl
f01058b3:	75 f2                	jne    f01058a7 <strfind+0xc>
			break;
	return (char *) s;
}
f01058b5:	5d                   	pop    %ebp
f01058b6:	c3                   	ret    

f01058b7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01058b7:	55                   	push   %ebp
f01058b8:	89 e5                	mov    %esp,%ebp
f01058ba:	57                   	push   %edi
f01058bb:	56                   	push   %esi
f01058bc:	53                   	push   %ebx
f01058bd:	8b 7d 08             	mov    0x8(%ebp),%edi
f01058c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01058c3:	85 c9                	test   %ecx,%ecx
f01058c5:	74 36                	je     f01058fd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01058c7:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01058cd:	75 28                	jne    f01058f7 <memset+0x40>
f01058cf:	f6 c1 03             	test   $0x3,%cl
f01058d2:	75 23                	jne    f01058f7 <memset+0x40>
		c &= 0xFF;
f01058d4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01058d8:	89 d3                	mov    %edx,%ebx
f01058da:	c1 e3 08             	shl    $0x8,%ebx
f01058dd:	89 d6                	mov    %edx,%esi
f01058df:	c1 e6 18             	shl    $0x18,%esi
f01058e2:	89 d0                	mov    %edx,%eax
f01058e4:	c1 e0 10             	shl    $0x10,%eax
f01058e7:	09 f0                	or     %esi,%eax
f01058e9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f01058eb:	89 d8                	mov    %ebx,%eax
f01058ed:	09 d0                	or     %edx,%eax
f01058ef:	c1 e9 02             	shr    $0x2,%ecx
f01058f2:	fc                   	cld    
f01058f3:	f3 ab                	rep stos %eax,%es:(%edi)
f01058f5:	eb 06                	jmp    f01058fd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01058f7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01058fa:	fc                   	cld    
f01058fb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01058fd:	89 f8                	mov    %edi,%eax
f01058ff:	5b                   	pop    %ebx
f0105900:	5e                   	pop    %esi
f0105901:	5f                   	pop    %edi
f0105902:	5d                   	pop    %ebp
f0105903:	c3                   	ret    

f0105904 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105904:	55                   	push   %ebp
f0105905:	89 e5                	mov    %esp,%ebp
f0105907:	57                   	push   %edi
f0105908:	56                   	push   %esi
f0105909:	8b 45 08             	mov    0x8(%ebp),%eax
f010590c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010590f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105912:	39 c6                	cmp    %eax,%esi
f0105914:	73 35                	jae    f010594b <memmove+0x47>
f0105916:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105919:	39 d0                	cmp    %edx,%eax
f010591b:	73 2e                	jae    f010594b <memmove+0x47>
		s += n;
		d += n;
f010591d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105920:	89 d6                	mov    %edx,%esi
f0105922:	09 fe                	or     %edi,%esi
f0105924:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010592a:	75 13                	jne    f010593f <memmove+0x3b>
f010592c:	f6 c1 03             	test   $0x3,%cl
f010592f:	75 0e                	jne    f010593f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0105931:	83 ef 04             	sub    $0x4,%edi
f0105934:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105937:	c1 e9 02             	shr    $0x2,%ecx
f010593a:	fd                   	std    
f010593b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010593d:	eb 09                	jmp    f0105948 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010593f:	83 ef 01             	sub    $0x1,%edi
f0105942:	8d 72 ff             	lea    -0x1(%edx),%esi
f0105945:	fd                   	std    
f0105946:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105948:	fc                   	cld    
f0105949:	eb 1d                	jmp    f0105968 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010594b:	89 f2                	mov    %esi,%edx
f010594d:	09 c2                	or     %eax,%edx
f010594f:	f6 c2 03             	test   $0x3,%dl
f0105952:	75 0f                	jne    f0105963 <memmove+0x5f>
f0105954:	f6 c1 03             	test   $0x3,%cl
f0105957:	75 0a                	jne    f0105963 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0105959:	c1 e9 02             	shr    $0x2,%ecx
f010595c:	89 c7                	mov    %eax,%edi
f010595e:	fc                   	cld    
f010595f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105961:	eb 05                	jmp    f0105968 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105963:	89 c7                	mov    %eax,%edi
f0105965:	fc                   	cld    
f0105966:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105968:	5e                   	pop    %esi
f0105969:	5f                   	pop    %edi
f010596a:	5d                   	pop    %ebp
f010596b:	c3                   	ret    

f010596c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010596c:	55                   	push   %ebp
f010596d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010596f:	ff 75 10             	pushl  0x10(%ebp)
f0105972:	ff 75 0c             	pushl  0xc(%ebp)
f0105975:	ff 75 08             	pushl  0x8(%ebp)
f0105978:	e8 87 ff ff ff       	call   f0105904 <memmove>
}
f010597d:	c9                   	leave  
f010597e:	c3                   	ret    

f010597f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010597f:	55                   	push   %ebp
f0105980:	89 e5                	mov    %esp,%ebp
f0105982:	56                   	push   %esi
f0105983:	53                   	push   %ebx
f0105984:	8b 45 08             	mov    0x8(%ebp),%eax
f0105987:	8b 55 0c             	mov    0xc(%ebp),%edx
f010598a:	89 c6                	mov    %eax,%esi
f010598c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010598f:	eb 1a                	jmp    f01059ab <memcmp+0x2c>
		if (*s1 != *s2)
f0105991:	0f b6 08             	movzbl (%eax),%ecx
f0105994:	0f b6 1a             	movzbl (%edx),%ebx
f0105997:	38 d9                	cmp    %bl,%cl
f0105999:	74 0a                	je     f01059a5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010599b:	0f b6 c1             	movzbl %cl,%eax
f010599e:	0f b6 db             	movzbl %bl,%ebx
f01059a1:	29 d8                	sub    %ebx,%eax
f01059a3:	eb 0f                	jmp    f01059b4 <memcmp+0x35>
		s1++, s2++;
f01059a5:	83 c0 01             	add    $0x1,%eax
f01059a8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01059ab:	39 f0                	cmp    %esi,%eax
f01059ad:	75 e2                	jne    f0105991 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01059af:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01059b4:	5b                   	pop    %ebx
f01059b5:	5e                   	pop    %esi
f01059b6:	5d                   	pop    %ebp
f01059b7:	c3                   	ret    

f01059b8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01059b8:	55                   	push   %ebp
f01059b9:	89 e5                	mov    %esp,%ebp
f01059bb:	53                   	push   %ebx
f01059bc:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01059bf:	89 c1                	mov    %eax,%ecx
f01059c1:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01059c4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01059c8:	eb 0a                	jmp    f01059d4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f01059ca:	0f b6 10             	movzbl (%eax),%edx
f01059cd:	39 da                	cmp    %ebx,%edx
f01059cf:	74 07                	je     f01059d8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01059d1:	83 c0 01             	add    $0x1,%eax
f01059d4:	39 c8                	cmp    %ecx,%eax
f01059d6:	72 f2                	jb     f01059ca <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01059d8:	5b                   	pop    %ebx
f01059d9:	5d                   	pop    %ebp
f01059da:	c3                   	ret    

f01059db <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01059db:	55                   	push   %ebp
f01059dc:	89 e5                	mov    %esp,%ebp
f01059de:	57                   	push   %edi
f01059df:	56                   	push   %esi
f01059e0:	53                   	push   %ebx
f01059e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01059e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01059e7:	eb 03                	jmp    f01059ec <strtol+0x11>
		s++;
f01059e9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01059ec:	0f b6 01             	movzbl (%ecx),%eax
f01059ef:	3c 20                	cmp    $0x20,%al
f01059f1:	74 f6                	je     f01059e9 <strtol+0xe>
f01059f3:	3c 09                	cmp    $0x9,%al
f01059f5:	74 f2                	je     f01059e9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01059f7:	3c 2b                	cmp    $0x2b,%al
f01059f9:	75 0a                	jne    f0105a05 <strtol+0x2a>
		s++;
f01059fb:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01059fe:	bf 00 00 00 00       	mov    $0x0,%edi
f0105a03:	eb 11                	jmp    f0105a16 <strtol+0x3b>
f0105a05:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105a0a:	3c 2d                	cmp    $0x2d,%al
f0105a0c:	75 08                	jne    f0105a16 <strtol+0x3b>
		s++, neg = 1;
f0105a0e:	83 c1 01             	add    $0x1,%ecx
f0105a11:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105a16:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105a1c:	75 15                	jne    f0105a33 <strtol+0x58>
f0105a1e:	80 39 30             	cmpb   $0x30,(%ecx)
f0105a21:	75 10                	jne    f0105a33 <strtol+0x58>
f0105a23:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105a27:	75 7c                	jne    f0105aa5 <strtol+0xca>
		s += 2, base = 16;
f0105a29:	83 c1 02             	add    $0x2,%ecx
f0105a2c:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105a31:	eb 16                	jmp    f0105a49 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0105a33:	85 db                	test   %ebx,%ebx
f0105a35:	75 12                	jne    f0105a49 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105a37:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105a3c:	80 39 30             	cmpb   $0x30,(%ecx)
f0105a3f:	75 08                	jne    f0105a49 <strtol+0x6e>
		s++, base = 8;
f0105a41:	83 c1 01             	add    $0x1,%ecx
f0105a44:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0105a49:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a4e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105a51:	0f b6 11             	movzbl (%ecx),%edx
f0105a54:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105a57:	89 f3                	mov    %esi,%ebx
f0105a59:	80 fb 09             	cmp    $0x9,%bl
f0105a5c:	77 08                	ja     f0105a66 <strtol+0x8b>
			dig = *s - '0';
f0105a5e:	0f be d2             	movsbl %dl,%edx
f0105a61:	83 ea 30             	sub    $0x30,%edx
f0105a64:	eb 22                	jmp    f0105a88 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0105a66:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105a69:	89 f3                	mov    %esi,%ebx
f0105a6b:	80 fb 19             	cmp    $0x19,%bl
f0105a6e:	77 08                	ja     f0105a78 <strtol+0x9d>
			dig = *s - 'a' + 10;
f0105a70:	0f be d2             	movsbl %dl,%edx
f0105a73:	83 ea 57             	sub    $0x57,%edx
f0105a76:	eb 10                	jmp    f0105a88 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0105a78:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105a7b:	89 f3                	mov    %esi,%ebx
f0105a7d:	80 fb 19             	cmp    $0x19,%bl
f0105a80:	77 16                	ja     f0105a98 <strtol+0xbd>
			dig = *s - 'A' + 10;
f0105a82:	0f be d2             	movsbl %dl,%edx
f0105a85:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0105a88:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105a8b:	7d 0b                	jge    f0105a98 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0105a8d:	83 c1 01             	add    $0x1,%ecx
f0105a90:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105a94:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0105a96:	eb b9                	jmp    f0105a51 <strtol+0x76>

	if (endptr)
f0105a98:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105a9c:	74 0d                	je     f0105aab <strtol+0xd0>
		*endptr = (char *) s;
f0105a9e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105aa1:	89 0e                	mov    %ecx,(%esi)
f0105aa3:	eb 06                	jmp    f0105aab <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105aa5:	85 db                	test   %ebx,%ebx
f0105aa7:	74 98                	je     f0105a41 <strtol+0x66>
f0105aa9:	eb 9e                	jmp    f0105a49 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0105aab:	89 c2                	mov    %eax,%edx
f0105aad:	f7 da                	neg    %edx
f0105aaf:	85 ff                	test   %edi,%edi
f0105ab1:	0f 45 c2             	cmovne %edx,%eax
}
f0105ab4:	5b                   	pop    %ebx
f0105ab5:	5e                   	pop    %esi
f0105ab6:	5f                   	pop    %edi
f0105ab7:	5d                   	pop    %ebp
f0105ab8:	c3                   	ret    
f0105ab9:	66 90                	xchg   %ax,%ax
f0105abb:	90                   	nop

f0105abc <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105abc:	fa                   	cli    

	xorw    %ax, %ax
f0105abd:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105abf:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105ac1:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105ac3:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105ac5:	0f 01 16             	lgdtl  (%esi)
f0105ac8:	74 70                	je     f0105b3a <mpsearch1+0x3>
	movl    %cr0, %eax
f0105aca:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105acd:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105ad1:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105ad4:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105ada:	08 00                	or     %al,(%eax)

f0105adc <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105adc:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105ae0:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105ae2:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105ae4:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105ae6:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105aea:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105aec:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105aee:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl    %eax, %cr3
f0105af3:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105af6:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105af9:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105afe:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105b01:	8b 25 84 1e 21 f0    	mov    0xf0211e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105b07:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105b0c:	b8 c7 01 10 f0       	mov    $0xf01001c7,%eax
	call    *%eax
f0105b11:	ff d0                	call   *%eax

f0105b13 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105b13:	eb fe                	jmp    f0105b13 <spin>
f0105b15:	8d 76 00             	lea    0x0(%esi),%esi

f0105b18 <gdt>:
	...
f0105b20:	ff                   	(bad)  
f0105b21:	ff 00                	incl   (%eax)
f0105b23:	00 00                	add    %al,(%eax)
f0105b25:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105b2c:	00                   	.byte 0x0
f0105b2d:	92                   	xchg   %eax,%edx
f0105b2e:	cf                   	iret   
	...

f0105b30 <gdtdesc>:
f0105b30:	17                   	pop    %ss
f0105b31:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105b36 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105b36:	90                   	nop

f0105b37 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105b37:	55                   	push   %ebp
f0105b38:	89 e5                	mov    %esp,%ebp
f0105b3a:	57                   	push   %edi
f0105b3b:	56                   	push   %esi
f0105b3c:	53                   	push   %ebx
f0105b3d:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105b40:	8b 0d 88 1e 21 f0    	mov    0xf0211e88,%ecx
f0105b46:	89 c3                	mov    %eax,%ebx
f0105b48:	c1 eb 0c             	shr    $0xc,%ebx
f0105b4b:	39 cb                	cmp    %ecx,%ebx
f0105b4d:	72 12                	jb     f0105b61 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105b4f:	50                   	push   %eax
f0105b50:	68 a4 65 10 f0       	push   $0xf01065a4
f0105b55:	6a 57                	push   $0x57
f0105b57:	68 dd 81 10 f0       	push   $0xf01081dd
f0105b5c:	e8 df a4 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105b61:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105b67:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105b69:	89 c2                	mov    %eax,%edx
f0105b6b:	c1 ea 0c             	shr    $0xc,%edx
f0105b6e:	39 ca                	cmp    %ecx,%edx
f0105b70:	72 12                	jb     f0105b84 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105b72:	50                   	push   %eax
f0105b73:	68 a4 65 10 f0       	push   $0xf01065a4
f0105b78:	6a 57                	push   $0x57
f0105b7a:	68 dd 81 10 f0       	push   $0xf01081dd
f0105b7f:	e8 bc a4 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105b84:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0105b8a:	eb 2f                	jmp    f0105bbb <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105b8c:	83 ec 04             	sub    $0x4,%esp
f0105b8f:	6a 04                	push   $0x4
f0105b91:	68 ed 81 10 f0       	push   $0xf01081ed
f0105b96:	53                   	push   %ebx
f0105b97:	e8 e3 fd ff ff       	call   f010597f <memcmp>
f0105b9c:	83 c4 10             	add    $0x10,%esp
f0105b9f:	85 c0                	test   %eax,%eax
f0105ba1:	75 15                	jne    f0105bb8 <mpsearch1+0x81>
f0105ba3:	89 da                	mov    %ebx,%edx
f0105ba5:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0105ba8:	0f b6 0a             	movzbl (%edx),%ecx
f0105bab:	01 c8                	add    %ecx,%eax
f0105bad:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105bb0:	39 d7                	cmp    %edx,%edi
f0105bb2:	75 f4                	jne    f0105ba8 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105bb4:	84 c0                	test   %al,%al
f0105bb6:	74 0e                	je     f0105bc6 <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105bb8:	83 c3 10             	add    $0x10,%ebx
f0105bbb:	39 f3                	cmp    %esi,%ebx
f0105bbd:	72 cd                	jb     f0105b8c <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105bbf:	b8 00 00 00 00       	mov    $0x0,%eax
f0105bc4:	eb 02                	jmp    f0105bc8 <mpsearch1+0x91>
f0105bc6:	89 d8                	mov    %ebx,%eax
}
f0105bc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105bcb:	5b                   	pop    %ebx
f0105bcc:	5e                   	pop    %esi
f0105bcd:	5f                   	pop    %edi
f0105bce:	5d                   	pop    %ebp
f0105bcf:	c3                   	ret    

f0105bd0 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105bd0:	55                   	push   %ebp
f0105bd1:	89 e5                	mov    %esp,%ebp
f0105bd3:	57                   	push   %edi
f0105bd4:	56                   	push   %esi
f0105bd5:	53                   	push   %ebx
f0105bd6:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105bd9:	c7 05 c0 23 21 f0 20 	movl   $0xf0212020,0xf02123c0
f0105be0:	20 21 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105be3:	83 3d 88 1e 21 f0 00 	cmpl   $0x0,0xf0211e88
f0105bea:	75 16                	jne    f0105c02 <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105bec:	68 00 04 00 00       	push   $0x400
f0105bf1:	68 a4 65 10 f0       	push   $0xf01065a4
f0105bf6:	6a 6f                	push   $0x6f
f0105bf8:	68 dd 81 10 f0       	push   $0xf01081dd
f0105bfd:	e8 3e a4 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105c02:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105c09:	85 c0                	test   %eax,%eax
f0105c0b:	74 16                	je     f0105c23 <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0105c0d:	c1 e0 04             	shl    $0x4,%eax
f0105c10:	ba 00 04 00 00       	mov    $0x400,%edx
f0105c15:	e8 1d ff ff ff       	call   f0105b37 <mpsearch1>
f0105c1a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105c1d:	85 c0                	test   %eax,%eax
f0105c1f:	75 3c                	jne    f0105c5d <mp_init+0x8d>
f0105c21:	eb 20                	jmp    f0105c43 <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105c23:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105c2a:	c1 e0 0a             	shl    $0xa,%eax
f0105c2d:	2d 00 04 00 00       	sub    $0x400,%eax
f0105c32:	ba 00 04 00 00       	mov    $0x400,%edx
f0105c37:	e8 fb fe ff ff       	call   f0105b37 <mpsearch1>
f0105c3c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105c3f:	85 c0                	test   %eax,%eax
f0105c41:	75 1a                	jne    f0105c5d <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105c43:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105c48:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105c4d:	e8 e5 fe ff ff       	call   f0105b37 <mpsearch1>
f0105c52:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105c55:	85 c0                	test   %eax,%eax
f0105c57:	0f 84 5d 02 00 00    	je     f0105eba <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105c5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105c60:	8b 70 04             	mov    0x4(%eax),%esi
f0105c63:	85 f6                	test   %esi,%esi
f0105c65:	74 06                	je     f0105c6d <mp_init+0x9d>
f0105c67:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105c6b:	74 15                	je     f0105c82 <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105c6d:	83 ec 0c             	sub    $0xc,%esp
f0105c70:	68 50 80 10 f0       	push   $0xf0108050
f0105c75:	e8 13 dc ff ff       	call   f010388d <cprintf>
f0105c7a:	83 c4 10             	add    $0x10,%esp
f0105c7d:	e9 38 02 00 00       	jmp    f0105eba <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105c82:	89 f0                	mov    %esi,%eax
f0105c84:	c1 e8 0c             	shr    $0xc,%eax
f0105c87:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f0105c8d:	72 15                	jb     f0105ca4 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105c8f:	56                   	push   %esi
f0105c90:	68 a4 65 10 f0       	push   $0xf01065a4
f0105c95:	68 90 00 00 00       	push   $0x90
f0105c9a:	68 dd 81 10 f0       	push   $0xf01081dd
f0105c9f:	e8 9c a3 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105ca4:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105caa:	83 ec 04             	sub    $0x4,%esp
f0105cad:	6a 04                	push   $0x4
f0105caf:	68 f2 81 10 f0       	push   $0xf01081f2
f0105cb4:	53                   	push   %ebx
f0105cb5:	e8 c5 fc ff ff       	call   f010597f <memcmp>
f0105cba:	83 c4 10             	add    $0x10,%esp
f0105cbd:	85 c0                	test   %eax,%eax
f0105cbf:	74 15                	je     f0105cd6 <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105cc1:	83 ec 0c             	sub    $0xc,%esp
f0105cc4:	68 80 80 10 f0       	push   $0xf0108080
f0105cc9:	e8 bf db ff ff       	call   f010388d <cprintf>
f0105cce:	83 c4 10             	add    $0x10,%esp
f0105cd1:	e9 e4 01 00 00       	jmp    f0105eba <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105cd6:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0105cda:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0105cde:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105ce1:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105ce6:	b8 00 00 00 00       	mov    $0x0,%eax
f0105ceb:	eb 0d                	jmp    f0105cfa <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0105ced:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105cf4:	f0 
f0105cf5:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105cf7:	83 c0 01             	add    $0x1,%eax
f0105cfa:	39 c7                	cmp    %eax,%edi
f0105cfc:	75 ef                	jne    f0105ced <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105cfe:	84 d2                	test   %dl,%dl
f0105d00:	74 15                	je     f0105d17 <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105d02:	83 ec 0c             	sub    $0xc,%esp
f0105d05:	68 b4 80 10 f0       	push   $0xf01080b4
f0105d0a:	e8 7e db ff ff       	call   f010388d <cprintf>
f0105d0f:	83 c4 10             	add    $0x10,%esp
f0105d12:	e9 a3 01 00 00       	jmp    f0105eba <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105d17:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105d1b:	3c 01                	cmp    $0x1,%al
f0105d1d:	74 1d                	je     f0105d3c <mp_init+0x16c>
f0105d1f:	3c 04                	cmp    $0x4,%al
f0105d21:	74 19                	je     f0105d3c <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105d23:	83 ec 08             	sub    $0x8,%esp
f0105d26:	0f b6 c0             	movzbl %al,%eax
f0105d29:	50                   	push   %eax
f0105d2a:	68 d8 80 10 f0       	push   $0xf01080d8
f0105d2f:	e8 59 db ff ff       	call   f010388d <cprintf>
f0105d34:	83 c4 10             	add    $0x10,%esp
f0105d37:	e9 7e 01 00 00       	jmp    f0105eba <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105d3c:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0105d40:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105d44:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105d49:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0105d4e:	01 ce                	add    %ecx,%esi
f0105d50:	eb 0d                	jmp    f0105d5f <mp_init+0x18f>
f0105d52:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105d59:	f0 
f0105d5a:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105d5c:	83 c0 01             	add    $0x1,%eax
f0105d5f:	39 c7                	cmp    %eax,%edi
f0105d61:	75 ef                	jne    f0105d52 <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105d63:	89 d0                	mov    %edx,%eax
f0105d65:	02 43 2a             	add    0x2a(%ebx),%al
f0105d68:	74 15                	je     f0105d7f <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105d6a:	83 ec 0c             	sub    $0xc,%esp
f0105d6d:	68 f8 80 10 f0       	push   $0xf01080f8
f0105d72:	e8 16 db ff ff       	call   f010388d <cprintf>
f0105d77:	83 c4 10             	add    $0x10,%esp
f0105d7a:	e9 3b 01 00 00       	jmp    f0105eba <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105d7f:	85 db                	test   %ebx,%ebx
f0105d81:	0f 84 33 01 00 00    	je     f0105eba <mp_init+0x2ea>
		return;
	ismp = 1;
f0105d87:	c7 05 00 20 21 f0 01 	movl   $0x1,0xf0212000
f0105d8e:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105d91:	8b 43 24             	mov    0x24(%ebx),%eax
f0105d94:	a3 00 30 25 f0       	mov    %eax,0xf0253000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105d99:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105d9c:	be 00 00 00 00       	mov    $0x0,%esi
f0105da1:	e9 85 00 00 00       	jmp    f0105e2b <mp_init+0x25b>
		switch (*p) {
f0105da6:	0f b6 07             	movzbl (%edi),%eax
f0105da9:	84 c0                	test   %al,%al
f0105dab:	74 06                	je     f0105db3 <mp_init+0x1e3>
f0105dad:	3c 04                	cmp    $0x4,%al
f0105daf:	77 55                	ja     f0105e06 <mp_init+0x236>
f0105db1:	eb 4e                	jmp    f0105e01 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105db3:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105db7:	74 11                	je     f0105dca <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105db9:	6b 05 c4 23 21 f0 74 	imul   $0x74,0xf02123c4,%eax
f0105dc0:	05 20 20 21 f0       	add    $0xf0212020,%eax
f0105dc5:	a3 c0 23 21 f0       	mov    %eax,0xf02123c0
			if (ncpu < NCPU) {
f0105dca:	a1 c4 23 21 f0       	mov    0xf02123c4,%eax
f0105dcf:	83 f8 07             	cmp    $0x7,%eax
f0105dd2:	7f 13                	jg     f0105de7 <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f0105dd4:	6b d0 74             	imul   $0x74,%eax,%edx
f0105dd7:	88 82 20 20 21 f0    	mov    %al,-0xfdedfe0(%edx)
				ncpu++;
f0105ddd:	83 c0 01             	add    $0x1,%eax
f0105de0:	a3 c4 23 21 f0       	mov    %eax,0xf02123c4
f0105de5:	eb 15                	jmp    f0105dfc <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105de7:	83 ec 08             	sub    $0x8,%esp
f0105dea:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105dee:	50                   	push   %eax
f0105def:	68 28 81 10 f0       	push   $0xf0108128
f0105df4:	e8 94 da ff ff       	call   f010388d <cprintf>
f0105df9:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105dfc:	83 c7 14             	add    $0x14,%edi
			continue;
f0105dff:	eb 27                	jmp    f0105e28 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105e01:	83 c7 08             	add    $0x8,%edi
			continue;
f0105e04:	eb 22                	jmp    f0105e28 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105e06:	83 ec 08             	sub    $0x8,%esp
f0105e09:	0f b6 c0             	movzbl %al,%eax
f0105e0c:	50                   	push   %eax
f0105e0d:	68 50 81 10 f0       	push   $0xf0108150
f0105e12:	e8 76 da ff ff       	call   f010388d <cprintf>
			ismp = 0;
f0105e17:	c7 05 00 20 21 f0 00 	movl   $0x0,0xf0212000
f0105e1e:	00 00 00 
			i = conf->entry;
f0105e21:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105e25:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105e28:	83 c6 01             	add    $0x1,%esi
f0105e2b:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105e2f:	39 c6                	cmp    %eax,%esi
f0105e31:	0f 82 6f ff ff ff    	jb     f0105da6 <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105e37:	a1 c0 23 21 f0       	mov    0xf02123c0,%eax
f0105e3c:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105e43:	83 3d 00 20 21 f0 00 	cmpl   $0x0,0xf0212000
f0105e4a:	75 26                	jne    f0105e72 <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105e4c:	c7 05 c4 23 21 f0 01 	movl   $0x1,0xf02123c4
f0105e53:	00 00 00 
		lapicaddr = 0;
f0105e56:	c7 05 00 30 25 f0 00 	movl   $0x0,0xf0253000
f0105e5d:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105e60:	83 ec 0c             	sub    $0xc,%esp
f0105e63:	68 70 81 10 f0       	push   $0xf0108170
f0105e68:	e8 20 da ff ff       	call   f010388d <cprintf>
		return;
f0105e6d:	83 c4 10             	add    $0x10,%esp
f0105e70:	eb 48                	jmp    f0105eba <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105e72:	83 ec 04             	sub    $0x4,%esp
f0105e75:	ff 35 c4 23 21 f0    	pushl  0xf02123c4
f0105e7b:	0f b6 00             	movzbl (%eax),%eax
f0105e7e:	50                   	push   %eax
f0105e7f:	68 f7 81 10 f0       	push   $0xf01081f7
f0105e84:	e8 04 da ff ff       	call   f010388d <cprintf>

	if (mp->imcrp) {
f0105e89:	83 c4 10             	add    $0x10,%esp
f0105e8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105e8f:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105e93:	74 25                	je     f0105eba <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105e95:	83 ec 0c             	sub    $0xc,%esp
f0105e98:	68 9c 81 10 f0       	push   $0xf010819c
f0105e9d:	e8 eb d9 ff ff       	call   f010388d <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105ea2:	ba 22 00 00 00       	mov    $0x22,%edx
f0105ea7:	b8 70 00 00 00       	mov    $0x70,%eax
f0105eac:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105ead:	ba 23 00 00 00       	mov    $0x23,%edx
f0105eb2:	ec                   	in     (%dx),%al
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105eb3:	83 c8 01             	or     $0x1,%eax
f0105eb6:	ee                   	out    %al,(%dx)
f0105eb7:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105eba:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105ebd:	5b                   	pop    %ebx
f0105ebe:	5e                   	pop    %esi
f0105ebf:	5f                   	pop    %edi
f0105ec0:	5d                   	pop    %ebp
f0105ec1:	c3                   	ret    

f0105ec2 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105ec2:	55                   	push   %ebp
f0105ec3:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105ec5:	8b 0d 04 30 25 f0    	mov    0xf0253004,%ecx
f0105ecb:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105ece:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105ed0:	a1 04 30 25 f0       	mov    0xf0253004,%eax
f0105ed5:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105ed8:	5d                   	pop    %ebp
f0105ed9:	c3                   	ret    

f0105eda <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105eda:	55                   	push   %ebp
f0105edb:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105edd:	a1 04 30 25 f0       	mov    0xf0253004,%eax
f0105ee2:	85 c0                	test   %eax,%eax
f0105ee4:	74 08                	je     f0105eee <cpunum+0x14>
		return lapic[ID] >> 24;
f0105ee6:	8b 40 20             	mov    0x20(%eax),%eax
f0105ee9:	c1 e8 18             	shr    $0x18,%eax
f0105eec:	eb 05                	jmp    f0105ef3 <cpunum+0x19>
	return 0;
f0105eee:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105ef3:	5d                   	pop    %ebp
f0105ef4:	c3                   	ret    

f0105ef5 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105ef5:	a1 00 30 25 f0       	mov    0xf0253000,%eax
f0105efa:	85 c0                	test   %eax,%eax
f0105efc:	0f 84 21 01 00 00    	je     f0106023 <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105f02:	55                   	push   %ebp
f0105f03:	89 e5                	mov    %esp,%ebp
f0105f05:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105f08:	68 00 10 00 00       	push   $0x1000
f0105f0d:	50                   	push   %eax
f0105f0e:	e8 03 b5 ff ff       	call   f0101416 <mmio_map_region>
f0105f13:	a3 04 30 25 f0       	mov    %eax,0xf0253004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105f18:	ba 27 01 00 00       	mov    $0x127,%edx
f0105f1d:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105f22:	e8 9b ff ff ff       	call   f0105ec2 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105f27:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105f2c:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105f31:	e8 8c ff ff ff       	call   f0105ec2 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105f36:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105f3b:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105f40:	e8 7d ff ff ff       	call   f0105ec2 <lapicw>
	lapicw(TICR, 10000000); 
f0105f45:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105f4a:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105f4f:	e8 6e ff ff ff       	call   f0105ec2 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105f54:	e8 81 ff ff ff       	call   f0105eda <cpunum>
f0105f59:	6b c0 74             	imul   $0x74,%eax,%eax
f0105f5c:	05 20 20 21 f0       	add    $0xf0212020,%eax
f0105f61:	83 c4 10             	add    $0x10,%esp
f0105f64:	39 05 c0 23 21 f0    	cmp    %eax,0xf02123c0
f0105f6a:	74 0f                	je     f0105f7b <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105f6c:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105f71:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105f76:	e8 47 ff ff ff       	call   f0105ec2 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105f7b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105f80:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105f85:	e8 38 ff ff ff       	call   f0105ec2 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105f8a:	a1 04 30 25 f0       	mov    0xf0253004,%eax
f0105f8f:	8b 40 30             	mov    0x30(%eax),%eax
f0105f92:	c1 e8 10             	shr    $0x10,%eax
f0105f95:	3c 03                	cmp    $0x3,%al
f0105f97:	76 0f                	jbe    f0105fa8 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105f99:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105f9e:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105fa3:	e8 1a ff ff ff       	call   f0105ec2 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105fa8:	ba 33 00 00 00       	mov    $0x33,%edx
f0105fad:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105fb2:	e8 0b ff ff ff       	call   f0105ec2 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105fb7:	ba 00 00 00 00       	mov    $0x0,%edx
f0105fbc:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105fc1:	e8 fc fe ff ff       	call   f0105ec2 <lapicw>
	lapicw(ESR, 0);
f0105fc6:	ba 00 00 00 00       	mov    $0x0,%edx
f0105fcb:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105fd0:	e8 ed fe ff ff       	call   f0105ec2 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105fd5:	ba 00 00 00 00       	mov    $0x0,%edx
f0105fda:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105fdf:	e8 de fe ff ff       	call   f0105ec2 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105fe4:	ba 00 00 00 00       	mov    $0x0,%edx
f0105fe9:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105fee:	e8 cf fe ff ff       	call   f0105ec2 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105ff3:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105ff8:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ffd:	e8 c0 fe ff ff       	call   f0105ec2 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106002:	8b 15 04 30 25 f0    	mov    0xf0253004,%edx
f0106008:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010600e:	f6 c4 10             	test   $0x10,%ah
f0106011:	75 f5                	jne    f0106008 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0106013:	ba 00 00 00 00       	mov    $0x0,%edx
f0106018:	b8 20 00 00 00       	mov    $0x20,%eax
f010601d:	e8 a0 fe ff ff       	call   f0105ec2 <lapicw>
}
f0106022:	c9                   	leave  
f0106023:	f3 c3                	repz ret 

f0106025 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0106025:	83 3d 04 30 25 f0 00 	cmpl   $0x0,0xf0253004
f010602c:	74 13                	je     f0106041 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f010602e:	55                   	push   %ebp
f010602f:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0106031:	ba 00 00 00 00       	mov    $0x0,%edx
f0106036:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010603b:	e8 82 fe ff ff       	call   f0105ec2 <lapicw>
}
f0106040:	5d                   	pop    %ebp
f0106041:	f3 c3                	repz ret 

f0106043 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106043:	55                   	push   %ebp
f0106044:	89 e5                	mov    %esp,%ebp
f0106046:	56                   	push   %esi
f0106047:	53                   	push   %ebx
f0106048:	8b 75 08             	mov    0x8(%ebp),%esi
f010604b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010604e:	ba 70 00 00 00       	mov    $0x70,%edx
f0106053:	b8 0f 00 00 00       	mov    $0xf,%eax
f0106058:	ee                   	out    %al,(%dx)
f0106059:	ba 71 00 00 00       	mov    $0x71,%edx
f010605e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0106063:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106064:	83 3d 88 1e 21 f0 00 	cmpl   $0x0,0xf0211e88
f010606b:	75 19                	jne    f0106086 <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010606d:	68 67 04 00 00       	push   $0x467
f0106072:	68 a4 65 10 f0       	push   $0xf01065a4
f0106077:	68 98 00 00 00       	push   $0x98
f010607c:	68 14 82 10 f0       	push   $0xf0108214
f0106081:	e8 ba 9f ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106086:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f010608d:	00 00 
	wrv[1] = addr >> 4;
f010608f:	89 d8                	mov    %ebx,%eax
f0106091:	c1 e8 04             	shr    $0x4,%eax
f0106094:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f010609a:	c1 e6 18             	shl    $0x18,%esi
f010609d:	89 f2                	mov    %esi,%edx
f010609f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01060a4:	e8 19 fe ff ff       	call   f0105ec2 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01060a9:	ba 00 c5 00 00       	mov    $0xc500,%edx
f01060ae:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01060b3:	e8 0a fe ff ff       	call   f0105ec2 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01060b8:	ba 00 85 00 00       	mov    $0x8500,%edx
f01060bd:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01060c2:	e8 fb fd ff ff       	call   f0105ec2 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01060c7:	c1 eb 0c             	shr    $0xc,%ebx
f01060ca:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01060cd:	89 f2                	mov    %esi,%edx
f01060cf:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01060d4:	e8 e9 fd ff ff       	call   f0105ec2 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01060d9:	89 da                	mov    %ebx,%edx
f01060db:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01060e0:	e8 dd fd ff ff       	call   f0105ec2 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01060e5:	89 f2                	mov    %esi,%edx
f01060e7:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01060ec:	e8 d1 fd ff ff       	call   f0105ec2 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01060f1:	89 da                	mov    %ebx,%edx
f01060f3:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01060f8:	e8 c5 fd ff ff       	call   f0105ec2 <lapicw>
		microdelay(200);
	}
}
f01060fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106100:	5b                   	pop    %ebx
f0106101:	5e                   	pop    %esi
f0106102:	5d                   	pop    %ebp
f0106103:	c3                   	ret    

f0106104 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106104:	55                   	push   %ebp
f0106105:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106107:	8b 55 08             	mov    0x8(%ebp),%edx
f010610a:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106110:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106115:	e8 a8 fd ff ff       	call   f0105ec2 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f010611a:	8b 15 04 30 25 f0    	mov    0xf0253004,%edx
f0106120:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106126:	f6 c4 10             	test   $0x10,%ah
f0106129:	75 f5                	jne    f0106120 <lapic_ipi+0x1c>
		;
}
f010612b:	5d                   	pop    %ebp
f010612c:	c3                   	ret    

f010612d <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f010612d:	55                   	push   %ebp
f010612e:	89 e5                	mov    %esp,%ebp
f0106130:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106133:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106139:	8b 55 0c             	mov    0xc(%ebp),%edx
f010613c:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f010613f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106146:	5d                   	pop    %ebp
f0106147:	c3                   	ret    

f0106148 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106148:	55                   	push   %ebp
f0106149:	89 e5                	mov    %esp,%ebp
f010614b:	56                   	push   %esi
f010614c:	53                   	push   %ebx
f010614d:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0106150:	83 3b 00             	cmpl   $0x0,(%ebx)
f0106153:	74 14                	je     f0106169 <spin_lock+0x21>
f0106155:	8b 73 08             	mov    0x8(%ebx),%esi
f0106158:	e8 7d fd ff ff       	call   f0105eda <cpunum>
f010615d:	6b c0 74             	imul   $0x74,%eax,%eax
f0106160:	05 20 20 21 f0       	add    $0xf0212020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106165:	39 c6                	cmp    %eax,%esi
f0106167:	74 07                	je     f0106170 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0106169:	ba 01 00 00 00       	mov    $0x1,%edx
f010616e:	eb 20                	jmp    f0106190 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106170:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106173:	e8 62 fd ff ff       	call   f0105eda <cpunum>
f0106178:	83 ec 0c             	sub    $0xc,%esp
f010617b:	53                   	push   %ebx
f010617c:	50                   	push   %eax
f010617d:	68 24 82 10 f0       	push   $0xf0108224
f0106182:	6a 41                	push   $0x41
f0106184:	68 88 82 10 f0       	push   $0xf0108288
f0106189:	e8 b2 9e ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f010618e:	f3 90                	pause  
f0106190:	89 d0                	mov    %edx,%eax
f0106192:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106195:	85 c0                	test   %eax,%eax
f0106197:	75 f5                	jne    f010618e <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106199:	e8 3c fd ff ff       	call   f0105eda <cpunum>
f010619e:	6b c0 74             	imul   $0x74,%eax,%eax
f01061a1:	05 20 20 21 f0       	add    $0xf0212020,%eax
f01061a6:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f01061a9:	83 c3 0c             	add    $0xc,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01061ac:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01061ae:	b8 00 00 00 00       	mov    $0x0,%eax
f01061b3:	eb 0b                	jmp    f01061c0 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f01061b5:	8b 4a 04             	mov    0x4(%edx),%ecx
f01061b8:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01061bb:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01061bd:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01061c0:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01061c6:	76 11                	jbe    f01061d9 <spin_lock+0x91>
f01061c8:	83 f8 09             	cmp    $0x9,%eax
f01061cb:	7e e8                	jle    f01061b5 <spin_lock+0x6d>
f01061cd:	eb 0a                	jmp    f01061d9 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f01061cf:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f01061d6:	83 c0 01             	add    $0x1,%eax
f01061d9:	83 f8 09             	cmp    $0x9,%eax
f01061dc:	7e f1                	jle    f01061cf <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f01061de:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01061e1:	5b                   	pop    %ebx
f01061e2:	5e                   	pop    %esi
f01061e3:	5d                   	pop    %ebp
f01061e4:	c3                   	ret    

f01061e5 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01061e5:	55                   	push   %ebp
f01061e6:	89 e5                	mov    %esp,%ebp
f01061e8:	57                   	push   %edi
f01061e9:	56                   	push   %esi
f01061ea:	53                   	push   %ebx
f01061eb:	83 ec 4c             	sub    $0x4c,%esp
f01061ee:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f01061f1:	83 3e 00             	cmpl   $0x0,(%esi)
f01061f4:	74 18                	je     f010620e <spin_unlock+0x29>
f01061f6:	8b 5e 08             	mov    0x8(%esi),%ebx
f01061f9:	e8 dc fc ff ff       	call   f0105eda <cpunum>
f01061fe:	6b c0 74             	imul   $0x74,%eax,%eax
f0106201:	05 20 20 21 f0       	add    $0xf0212020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106206:	39 c3                	cmp    %eax,%ebx
f0106208:	0f 84 a5 00 00 00    	je     f01062b3 <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f010620e:	83 ec 04             	sub    $0x4,%esp
f0106211:	6a 28                	push   $0x28
f0106213:	8d 46 0c             	lea    0xc(%esi),%eax
f0106216:	50                   	push   %eax
f0106217:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f010621a:	53                   	push   %ebx
f010621b:	e8 e4 f6 ff ff       	call   f0105904 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106220:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106223:	0f b6 38             	movzbl (%eax),%edi
f0106226:	8b 76 04             	mov    0x4(%esi),%esi
f0106229:	e8 ac fc ff ff       	call   f0105eda <cpunum>
f010622e:	57                   	push   %edi
f010622f:	56                   	push   %esi
f0106230:	50                   	push   %eax
f0106231:	68 50 82 10 f0       	push   $0xf0108250
f0106236:	e8 52 d6 ff ff       	call   f010388d <cprintf>
f010623b:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010623e:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0106241:	eb 54                	jmp    f0106297 <spin_unlock+0xb2>
f0106243:	83 ec 08             	sub    $0x8,%esp
f0106246:	57                   	push   %edi
f0106247:	50                   	push   %eax
f0106248:	e8 82 ec ff ff       	call   f0104ecf <debuginfo_eip>
f010624d:	83 c4 10             	add    $0x10,%esp
f0106250:	85 c0                	test   %eax,%eax
f0106252:	78 27                	js     f010627b <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106254:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106256:	83 ec 04             	sub    $0x4,%esp
f0106259:	89 c2                	mov    %eax,%edx
f010625b:	2b 55 b8             	sub    -0x48(%ebp),%edx
f010625e:	52                   	push   %edx
f010625f:	ff 75 b0             	pushl  -0x50(%ebp)
f0106262:	ff 75 b4             	pushl  -0x4c(%ebp)
f0106265:	ff 75 ac             	pushl  -0x54(%ebp)
f0106268:	ff 75 a8             	pushl  -0x58(%ebp)
f010626b:	50                   	push   %eax
f010626c:	68 98 82 10 f0       	push   $0xf0108298
f0106271:	e8 17 d6 ff ff       	call   f010388d <cprintf>
f0106276:	83 c4 20             	add    $0x20,%esp
f0106279:	eb 12                	jmp    f010628d <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f010627b:	83 ec 08             	sub    $0x8,%esp
f010627e:	ff 36                	pushl  (%esi)
f0106280:	68 af 82 10 f0       	push   $0xf01082af
f0106285:	e8 03 d6 ff ff       	call   f010388d <cprintf>
f010628a:	83 c4 10             	add    $0x10,%esp
f010628d:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106290:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106293:	39 c3                	cmp    %eax,%ebx
f0106295:	74 08                	je     f010629f <spin_unlock+0xba>
f0106297:	89 de                	mov    %ebx,%esi
f0106299:	8b 03                	mov    (%ebx),%eax
f010629b:	85 c0                	test   %eax,%eax
f010629d:	75 a4                	jne    f0106243 <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f010629f:	83 ec 04             	sub    $0x4,%esp
f01062a2:	68 b7 82 10 f0       	push   $0xf01082b7
f01062a7:	6a 67                	push   $0x67
f01062a9:	68 88 82 10 f0       	push   $0xf0108288
f01062ae:	e8 8d 9d ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f01062b3:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f01062ba:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01062c1:	b8 00 00 00 00       	mov    $0x0,%eax
f01062c6:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f01062c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01062cc:	5b                   	pop    %ebx
f01062cd:	5e                   	pop    %esi
f01062ce:	5f                   	pop    %edi
f01062cf:	5d                   	pop    %ebp
f01062d0:	c3                   	ret    
f01062d1:	66 90                	xchg   %ax,%ax
f01062d3:	66 90                	xchg   %ax,%ax
f01062d5:	66 90                	xchg   %ax,%ax
f01062d7:	66 90                	xchg   %ax,%ax
f01062d9:	66 90                	xchg   %ax,%ax
f01062db:	66 90                	xchg   %ax,%ax
f01062dd:	66 90                	xchg   %ax,%ax
f01062df:	90                   	nop

f01062e0 <__udivdi3>:
f01062e0:	55                   	push   %ebp
f01062e1:	57                   	push   %edi
f01062e2:	56                   	push   %esi
f01062e3:	53                   	push   %ebx
f01062e4:	83 ec 1c             	sub    $0x1c,%esp
f01062e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f01062eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f01062ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f01062f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01062f7:	85 f6                	test   %esi,%esi
f01062f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01062fd:	89 ca                	mov    %ecx,%edx
f01062ff:	89 f8                	mov    %edi,%eax
f0106301:	75 3d                	jne    f0106340 <__udivdi3+0x60>
f0106303:	39 cf                	cmp    %ecx,%edi
f0106305:	0f 87 c5 00 00 00    	ja     f01063d0 <__udivdi3+0xf0>
f010630b:	85 ff                	test   %edi,%edi
f010630d:	89 fd                	mov    %edi,%ebp
f010630f:	75 0b                	jne    f010631c <__udivdi3+0x3c>
f0106311:	b8 01 00 00 00       	mov    $0x1,%eax
f0106316:	31 d2                	xor    %edx,%edx
f0106318:	f7 f7                	div    %edi
f010631a:	89 c5                	mov    %eax,%ebp
f010631c:	89 c8                	mov    %ecx,%eax
f010631e:	31 d2                	xor    %edx,%edx
f0106320:	f7 f5                	div    %ebp
f0106322:	89 c1                	mov    %eax,%ecx
f0106324:	89 d8                	mov    %ebx,%eax
f0106326:	89 cf                	mov    %ecx,%edi
f0106328:	f7 f5                	div    %ebp
f010632a:	89 c3                	mov    %eax,%ebx
f010632c:	89 d8                	mov    %ebx,%eax
f010632e:	89 fa                	mov    %edi,%edx
f0106330:	83 c4 1c             	add    $0x1c,%esp
f0106333:	5b                   	pop    %ebx
f0106334:	5e                   	pop    %esi
f0106335:	5f                   	pop    %edi
f0106336:	5d                   	pop    %ebp
f0106337:	c3                   	ret    
f0106338:	90                   	nop
f0106339:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106340:	39 ce                	cmp    %ecx,%esi
f0106342:	77 74                	ja     f01063b8 <__udivdi3+0xd8>
f0106344:	0f bd fe             	bsr    %esi,%edi
f0106347:	83 f7 1f             	xor    $0x1f,%edi
f010634a:	0f 84 98 00 00 00    	je     f01063e8 <__udivdi3+0x108>
f0106350:	bb 20 00 00 00       	mov    $0x20,%ebx
f0106355:	89 f9                	mov    %edi,%ecx
f0106357:	89 c5                	mov    %eax,%ebp
f0106359:	29 fb                	sub    %edi,%ebx
f010635b:	d3 e6                	shl    %cl,%esi
f010635d:	89 d9                	mov    %ebx,%ecx
f010635f:	d3 ed                	shr    %cl,%ebp
f0106361:	89 f9                	mov    %edi,%ecx
f0106363:	d3 e0                	shl    %cl,%eax
f0106365:	09 ee                	or     %ebp,%esi
f0106367:	89 d9                	mov    %ebx,%ecx
f0106369:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010636d:	89 d5                	mov    %edx,%ebp
f010636f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106373:	d3 ed                	shr    %cl,%ebp
f0106375:	89 f9                	mov    %edi,%ecx
f0106377:	d3 e2                	shl    %cl,%edx
f0106379:	89 d9                	mov    %ebx,%ecx
f010637b:	d3 e8                	shr    %cl,%eax
f010637d:	09 c2                	or     %eax,%edx
f010637f:	89 d0                	mov    %edx,%eax
f0106381:	89 ea                	mov    %ebp,%edx
f0106383:	f7 f6                	div    %esi
f0106385:	89 d5                	mov    %edx,%ebp
f0106387:	89 c3                	mov    %eax,%ebx
f0106389:	f7 64 24 0c          	mull   0xc(%esp)
f010638d:	39 d5                	cmp    %edx,%ebp
f010638f:	72 10                	jb     f01063a1 <__udivdi3+0xc1>
f0106391:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106395:	89 f9                	mov    %edi,%ecx
f0106397:	d3 e6                	shl    %cl,%esi
f0106399:	39 c6                	cmp    %eax,%esi
f010639b:	73 07                	jae    f01063a4 <__udivdi3+0xc4>
f010639d:	39 d5                	cmp    %edx,%ebp
f010639f:	75 03                	jne    f01063a4 <__udivdi3+0xc4>
f01063a1:	83 eb 01             	sub    $0x1,%ebx
f01063a4:	31 ff                	xor    %edi,%edi
f01063a6:	89 d8                	mov    %ebx,%eax
f01063a8:	89 fa                	mov    %edi,%edx
f01063aa:	83 c4 1c             	add    $0x1c,%esp
f01063ad:	5b                   	pop    %ebx
f01063ae:	5e                   	pop    %esi
f01063af:	5f                   	pop    %edi
f01063b0:	5d                   	pop    %ebp
f01063b1:	c3                   	ret    
f01063b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01063b8:	31 ff                	xor    %edi,%edi
f01063ba:	31 db                	xor    %ebx,%ebx
f01063bc:	89 d8                	mov    %ebx,%eax
f01063be:	89 fa                	mov    %edi,%edx
f01063c0:	83 c4 1c             	add    $0x1c,%esp
f01063c3:	5b                   	pop    %ebx
f01063c4:	5e                   	pop    %esi
f01063c5:	5f                   	pop    %edi
f01063c6:	5d                   	pop    %ebp
f01063c7:	c3                   	ret    
f01063c8:	90                   	nop
f01063c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01063d0:	89 d8                	mov    %ebx,%eax
f01063d2:	f7 f7                	div    %edi
f01063d4:	31 ff                	xor    %edi,%edi
f01063d6:	89 c3                	mov    %eax,%ebx
f01063d8:	89 d8                	mov    %ebx,%eax
f01063da:	89 fa                	mov    %edi,%edx
f01063dc:	83 c4 1c             	add    $0x1c,%esp
f01063df:	5b                   	pop    %ebx
f01063e0:	5e                   	pop    %esi
f01063e1:	5f                   	pop    %edi
f01063e2:	5d                   	pop    %ebp
f01063e3:	c3                   	ret    
f01063e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01063e8:	39 ce                	cmp    %ecx,%esi
f01063ea:	72 0c                	jb     f01063f8 <__udivdi3+0x118>
f01063ec:	31 db                	xor    %ebx,%ebx
f01063ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
f01063f2:	0f 87 34 ff ff ff    	ja     f010632c <__udivdi3+0x4c>
f01063f8:	bb 01 00 00 00       	mov    $0x1,%ebx
f01063fd:	e9 2a ff ff ff       	jmp    f010632c <__udivdi3+0x4c>
f0106402:	66 90                	xchg   %ax,%ax
f0106404:	66 90                	xchg   %ax,%ax
f0106406:	66 90                	xchg   %ax,%ax
f0106408:	66 90                	xchg   %ax,%ax
f010640a:	66 90                	xchg   %ax,%ax
f010640c:	66 90                	xchg   %ax,%ax
f010640e:	66 90                	xchg   %ax,%ax

f0106410 <__umoddi3>:
f0106410:	55                   	push   %ebp
f0106411:	57                   	push   %edi
f0106412:	56                   	push   %esi
f0106413:	53                   	push   %ebx
f0106414:	83 ec 1c             	sub    $0x1c,%esp
f0106417:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010641b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010641f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106423:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106427:	85 d2                	test   %edx,%edx
f0106429:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010642d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106431:	89 f3                	mov    %esi,%ebx
f0106433:	89 3c 24             	mov    %edi,(%esp)
f0106436:	89 74 24 04          	mov    %esi,0x4(%esp)
f010643a:	75 1c                	jne    f0106458 <__umoddi3+0x48>
f010643c:	39 f7                	cmp    %esi,%edi
f010643e:	76 50                	jbe    f0106490 <__umoddi3+0x80>
f0106440:	89 c8                	mov    %ecx,%eax
f0106442:	89 f2                	mov    %esi,%edx
f0106444:	f7 f7                	div    %edi
f0106446:	89 d0                	mov    %edx,%eax
f0106448:	31 d2                	xor    %edx,%edx
f010644a:	83 c4 1c             	add    $0x1c,%esp
f010644d:	5b                   	pop    %ebx
f010644e:	5e                   	pop    %esi
f010644f:	5f                   	pop    %edi
f0106450:	5d                   	pop    %ebp
f0106451:	c3                   	ret    
f0106452:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106458:	39 f2                	cmp    %esi,%edx
f010645a:	89 d0                	mov    %edx,%eax
f010645c:	77 52                	ja     f01064b0 <__umoddi3+0xa0>
f010645e:	0f bd ea             	bsr    %edx,%ebp
f0106461:	83 f5 1f             	xor    $0x1f,%ebp
f0106464:	75 5a                	jne    f01064c0 <__umoddi3+0xb0>
f0106466:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010646a:	0f 82 e0 00 00 00    	jb     f0106550 <__umoddi3+0x140>
f0106470:	39 0c 24             	cmp    %ecx,(%esp)
f0106473:	0f 86 d7 00 00 00    	jbe    f0106550 <__umoddi3+0x140>
f0106479:	8b 44 24 08          	mov    0x8(%esp),%eax
f010647d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106481:	83 c4 1c             	add    $0x1c,%esp
f0106484:	5b                   	pop    %ebx
f0106485:	5e                   	pop    %esi
f0106486:	5f                   	pop    %edi
f0106487:	5d                   	pop    %ebp
f0106488:	c3                   	ret    
f0106489:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106490:	85 ff                	test   %edi,%edi
f0106492:	89 fd                	mov    %edi,%ebp
f0106494:	75 0b                	jne    f01064a1 <__umoddi3+0x91>
f0106496:	b8 01 00 00 00       	mov    $0x1,%eax
f010649b:	31 d2                	xor    %edx,%edx
f010649d:	f7 f7                	div    %edi
f010649f:	89 c5                	mov    %eax,%ebp
f01064a1:	89 f0                	mov    %esi,%eax
f01064a3:	31 d2                	xor    %edx,%edx
f01064a5:	f7 f5                	div    %ebp
f01064a7:	89 c8                	mov    %ecx,%eax
f01064a9:	f7 f5                	div    %ebp
f01064ab:	89 d0                	mov    %edx,%eax
f01064ad:	eb 99                	jmp    f0106448 <__umoddi3+0x38>
f01064af:	90                   	nop
f01064b0:	89 c8                	mov    %ecx,%eax
f01064b2:	89 f2                	mov    %esi,%edx
f01064b4:	83 c4 1c             	add    $0x1c,%esp
f01064b7:	5b                   	pop    %ebx
f01064b8:	5e                   	pop    %esi
f01064b9:	5f                   	pop    %edi
f01064ba:	5d                   	pop    %ebp
f01064bb:	c3                   	ret    
f01064bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01064c0:	8b 34 24             	mov    (%esp),%esi
f01064c3:	bf 20 00 00 00       	mov    $0x20,%edi
f01064c8:	89 e9                	mov    %ebp,%ecx
f01064ca:	29 ef                	sub    %ebp,%edi
f01064cc:	d3 e0                	shl    %cl,%eax
f01064ce:	89 f9                	mov    %edi,%ecx
f01064d0:	89 f2                	mov    %esi,%edx
f01064d2:	d3 ea                	shr    %cl,%edx
f01064d4:	89 e9                	mov    %ebp,%ecx
f01064d6:	09 c2                	or     %eax,%edx
f01064d8:	89 d8                	mov    %ebx,%eax
f01064da:	89 14 24             	mov    %edx,(%esp)
f01064dd:	89 f2                	mov    %esi,%edx
f01064df:	d3 e2                	shl    %cl,%edx
f01064e1:	89 f9                	mov    %edi,%ecx
f01064e3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01064e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01064eb:	d3 e8                	shr    %cl,%eax
f01064ed:	89 e9                	mov    %ebp,%ecx
f01064ef:	89 c6                	mov    %eax,%esi
f01064f1:	d3 e3                	shl    %cl,%ebx
f01064f3:	89 f9                	mov    %edi,%ecx
f01064f5:	89 d0                	mov    %edx,%eax
f01064f7:	d3 e8                	shr    %cl,%eax
f01064f9:	89 e9                	mov    %ebp,%ecx
f01064fb:	09 d8                	or     %ebx,%eax
f01064fd:	89 d3                	mov    %edx,%ebx
f01064ff:	89 f2                	mov    %esi,%edx
f0106501:	f7 34 24             	divl   (%esp)
f0106504:	89 d6                	mov    %edx,%esi
f0106506:	d3 e3                	shl    %cl,%ebx
f0106508:	f7 64 24 04          	mull   0x4(%esp)
f010650c:	39 d6                	cmp    %edx,%esi
f010650e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106512:	89 d1                	mov    %edx,%ecx
f0106514:	89 c3                	mov    %eax,%ebx
f0106516:	72 08                	jb     f0106520 <__umoddi3+0x110>
f0106518:	75 11                	jne    f010652b <__umoddi3+0x11b>
f010651a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010651e:	73 0b                	jae    f010652b <__umoddi3+0x11b>
f0106520:	2b 44 24 04          	sub    0x4(%esp),%eax
f0106524:	1b 14 24             	sbb    (%esp),%edx
f0106527:	89 d1                	mov    %edx,%ecx
f0106529:	89 c3                	mov    %eax,%ebx
f010652b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010652f:	29 da                	sub    %ebx,%edx
f0106531:	19 ce                	sbb    %ecx,%esi
f0106533:	89 f9                	mov    %edi,%ecx
f0106535:	89 f0                	mov    %esi,%eax
f0106537:	d3 e0                	shl    %cl,%eax
f0106539:	89 e9                	mov    %ebp,%ecx
f010653b:	d3 ea                	shr    %cl,%edx
f010653d:	89 e9                	mov    %ebp,%ecx
f010653f:	d3 ee                	shr    %cl,%esi
f0106541:	09 d0                	or     %edx,%eax
f0106543:	89 f2                	mov    %esi,%edx
f0106545:	83 c4 1c             	add    $0x1c,%esp
f0106548:	5b                   	pop    %ebx
f0106549:	5e                   	pop    %esi
f010654a:	5f                   	pop    %edi
f010654b:	5d                   	pop    %ebp
f010654c:	c3                   	ret    
f010654d:	8d 76 00             	lea    0x0(%esi),%esi
f0106550:	29 f9                	sub    %edi,%ecx
f0106552:	19 d6                	sbb    %edx,%esi
f0106554:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106558:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010655c:	e9 18 ff ff ff       	jmp    f0106479 <__umoddi3+0x69>
