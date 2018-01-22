
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
f0100015:	b8 00 f0 11 00       	mov    $0x11f000,%eax
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
f0100034:	bc 00 f0 11 f0       	mov    $0xf011f000,%esp

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
f0100048:	83 3d 80 2e 21 f0 00 	cmpl   $0x0,0xf0212e80
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 80 2e 21 f0    	mov    %esi,0xf0212e80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 21 60 00 00       	call   f0106082 <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 20 67 10 f0       	push   $0xf0106720
f010006d:	e8 6d 39 00 00       	call   f01039df <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 3d 39 00 00       	call   f01039b9 <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 fa 7e 10 f0 	movl   $0xf0107efa,(%esp)
f0100083:	e8 57 39 00 00       	call   f01039df <cprintf>
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
f01000a1:	b8 08 40 25 f0       	mov    $0xf0254008,%eax
f01000a6:	2d e4 1f 21 f0       	sub    $0xf0211fe4,%eax
f01000ab:	50                   	push   %eax
f01000ac:	6a 00                	push   $0x0
f01000ae:	68 e4 1f 21 f0       	push   $0xf0211fe4
f01000b3:	e8 a9 59 00 00       	call   f0105a61 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b8:	e8 96 05 00 00       	call   f0100653 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000bd:	83 c4 08             	add    $0x8,%esp
f01000c0:	68 ac 1a 00 00       	push   $0x1aac
f01000c5:	68 8c 67 10 f0       	push   $0xf010678c
f01000ca:	e8 10 39 00 00       	call   f01039df <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000cf:	e8 a2 13 00 00       	call   f0101476 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000d4:	e8 3e 30 00 00       	call   f0103117 <env_init>
	trap_init();
f01000d9:	e8 fc 39 00 00       	call   f0103ada <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000de:	e8 95 5c 00 00       	call   f0105d78 <mp_init>
	lapic_init();
f01000e3:	e8 b5 5f 00 00       	call   f010609d <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000e8:	e8 19 38 00 00       	call   f0103906 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000ed:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f01000f4:	e8 f7 61 00 00       	call   f01062f0 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000f9:	83 c4 10             	add    $0x10,%esp
f01000fc:	83 3d 88 2e 21 f0 07 	cmpl   $0x7,0xf0212e88
f0100103:	77 16                	ja     f010011b <i386_init+0x81>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100105:	68 00 70 00 00       	push   $0x7000
f010010a:	68 44 67 10 f0       	push   $0xf0106744
f010010f:	6a 58                	push   $0x58
f0100111:	68 a7 67 10 f0       	push   $0xf01067a7
f0100116:	e8 25 ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010011b:	83 ec 04             	sub    $0x4,%esp
f010011e:	b8 de 5c 10 f0       	mov    $0xf0105cde,%eax
f0100123:	2d 64 5c 10 f0       	sub    $0xf0105c64,%eax
f0100128:	50                   	push   %eax
f0100129:	68 64 5c 10 f0       	push   $0xf0105c64
f010012e:	68 00 70 00 f0       	push   $0xf0007000
f0100133:	e8 76 59 00 00       	call   f0105aae <memmove>
f0100138:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010013b:	bb 20 30 21 f0       	mov    $0xf0213020,%ebx
f0100140:	eb 4d                	jmp    f010018f <i386_init+0xf5>
		if (c == cpus + cpunum())  // We've started already.
f0100142:	e8 3b 5f 00 00       	call   f0106082 <cpunum>
f0100147:	6b c0 74             	imul   $0x74,%eax,%eax
f010014a:	05 20 30 21 f0       	add    $0xf0213020,%eax
f010014f:	39 c3                	cmp    %eax,%ebx
f0100151:	74 39                	je     f010018c <i386_init+0xf2>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100153:	89 d8                	mov    %ebx,%eax
f0100155:	2d 20 30 21 f0       	sub    $0xf0213020,%eax
f010015a:	c1 f8 02             	sar    $0x2,%eax
f010015d:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100163:	c1 e0 0f             	shl    $0xf,%eax
f0100166:	05 00 c0 21 f0       	add    $0xf021c000,%eax
f010016b:	a3 84 2e 21 f0       	mov    %eax,0xf0212e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100170:	83 ec 08             	sub    $0x8,%esp
f0100173:	68 00 70 00 00       	push   $0x7000
f0100178:	0f b6 03             	movzbl (%ebx),%eax
f010017b:	50                   	push   %eax
f010017c:	e8 6a 60 00 00       	call   f01061eb <lapic_startap>
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
f010018f:	6b 05 c4 33 21 f0 74 	imul   $0x74,0xf02133c4,%eax
f0100196:	05 20 30 21 f0       	add    $0xf0213020,%eax
f010019b:	39 c3                	cmp    %eax,%ebx
f010019d:	72 a3                	jb     f0100142 <i386_init+0xa8>
	lock_kernel();

	// Starting non-boot CPUs
	boot_aps();

	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f010019f:	83 ec 08             	sub    $0x8,%esp
f01001a2:	6a 01                	push   $0x1
f01001a4:	68 3c 21 1d f0       	push   $0xf01d213c
f01001a9:	e8 6c 31 00 00       	call   f010331a <env_create>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001ae:	83 c4 08             	add    $0x8,%esp
f01001b1:	6a 00                	push   $0x0
f01001b3:	68 bc d0 20 f0       	push   $0xf020d0bc
f01001b8:	e8 5d 31 00 00       	call   f010331a <env_create>
	// Touch all you want. Calls fork.
	ENV_CREATE(user_primes, ENV_TYPE_USER);
#endif // TEST* 
	
	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f01001bd:	e8 35 04 00 00       	call   f01005f7 <kbd_intr>
	// Schedule and run the first user environment!
	sched_yield();
f01001c2:	e8 82 46 00 00       	call   f0104849 <sched_yield>

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
f01001cd:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001d2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001d7:	77 12                	ja     f01001eb <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001d9:	50                   	push   %eax
f01001da:	68 68 67 10 f0       	push   $0xf0106768
f01001df:	6a 6f                	push   $0x6f
f01001e1:	68 a7 67 10 f0       	push   $0xf01067a7
f01001e6:	e8 55 fe ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001eb:	05 00 00 00 10       	add    $0x10000000,%eax
f01001f0:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001f3:	e8 8a 5e 00 00       	call   f0106082 <cpunum>
f01001f8:	83 ec 08             	sub    $0x8,%esp
f01001fb:	50                   	push   %eax
f01001fc:	68 b3 67 10 f0       	push   $0xf01067b3
f0100201:	e8 d9 37 00 00       	call   f01039df <cprintf>

	lapic_init();
f0100206:	e8 92 5e 00 00       	call   f010609d <lapic_init>
	env_init_percpu();
f010020b:	e8 d7 2e 00 00       	call   f01030e7 <env_init_percpu>
	trap_init_percpu();
f0100210:	e8 de 37 00 00       	call   f01039f3 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100215:	e8 68 5e 00 00       	call   f0106082 <cpunum>
f010021a:	6b d0 74             	imul   $0x74,%eax,%edx
f010021d:	81 c2 20 30 21 f0    	add    $0xf0213020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100223:	b8 01 00 00 00       	mov    $0x1,%eax
f0100228:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010022c:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0100233:	e8 b8 60 00 00       	call   f01062f0 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100238:	e8 0c 46 00 00       	call   f0104849 <sched_yield>

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
f010024d:	68 c9 67 10 f0       	push   $0xf01067c9
f0100252:	e8 88 37 00 00       	call   f01039df <cprintf>
	vcprintf(fmt, ap);
f0100257:	83 c4 08             	add    $0x8,%esp
f010025a:	53                   	push   %ebx
f010025b:	ff 75 10             	pushl  0x10(%ebp)
f010025e:	e8 56 37 00 00       	call   f01039b9 <vcprintf>
	cprintf("\n");
f0100263:	c7 04 24 fa 7e 10 f0 	movl   $0xf0107efa,(%esp)
f010026a:	e8 70 37 00 00       	call   f01039df <cprintf>
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
f01002a5:	8b 0d 24 22 21 f0    	mov    0xf0212224,%ecx
f01002ab:	8d 51 01             	lea    0x1(%ecx),%edx
f01002ae:	89 15 24 22 21 f0    	mov    %edx,0xf0212224
f01002b4:	88 81 20 20 21 f0    	mov    %al,-0xfdedfe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002ba:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002c0:	75 0a                	jne    f01002cc <cons_intr+0x36>
			cons.wpos = 0;
f01002c2:	c7 05 24 22 21 f0 00 	movl   $0x0,0xf0212224
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
f01002fb:	83 0d 00 20 21 f0 40 	orl    $0x40,0xf0212000
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
f0100313:	8b 0d 00 20 21 f0    	mov    0xf0212000,%ecx
f0100319:	89 cb                	mov    %ecx,%ebx
f010031b:	83 e3 40             	and    $0x40,%ebx
f010031e:	83 e0 7f             	and    $0x7f,%eax
f0100321:	85 db                	test   %ebx,%ebx
f0100323:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100326:	0f b6 d2             	movzbl %dl,%edx
f0100329:	0f b6 82 40 69 10 f0 	movzbl -0xfef96c0(%edx),%eax
f0100330:	83 c8 40             	or     $0x40,%eax
f0100333:	0f b6 c0             	movzbl %al,%eax
f0100336:	f7 d0                	not    %eax
f0100338:	21 c8                	and    %ecx,%eax
f010033a:	a3 00 20 21 f0       	mov    %eax,0xf0212000
		return 0;
f010033f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100344:	e9 a4 00 00 00       	jmp    f01003ed <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100349:	8b 0d 00 20 21 f0    	mov    0xf0212000,%ecx
f010034f:	f6 c1 40             	test   $0x40,%cl
f0100352:	74 0e                	je     f0100362 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100354:	83 c8 80             	or     $0xffffff80,%eax
f0100357:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100359:	83 e1 bf             	and    $0xffffffbf,%ecx
f010035c:	89 0d 00 20 21 f0    	mov    %ecx,0xf0212000
	}

	shift |= shiftcode[data];
f0100362:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100365:	0f b6 82 40 69 10 f0 	movzbl -0xfef96c0(%edx),%eax
f010036c:	0b 05 00 20 21 f0    	or     0xf0212000,%eax
f0100372:	0f b6 8a 40 68 10 f0 	movzbl -0xfef97c0(%edx),%ecx
f0100379:	31 c8                	xor    %ecx,%eax
f010037b:	a3 00 20 21 f0       	mov    %eax,0xf0212000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100380:	89 c1                	mov    %eax,%ecx
f0100382:	83 e1 03             	and    $0x3,%ecx
f0100385:	8b 0c 8d 20 68 10 f0 	mov    -0xfef97e0(,%ecx,4),%ecx
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
f01003c3:	68 e3 67 10 f0       	push   $0xf01067e3
f01003c8:	e8 12 36 00 00       	call   f01039df <cprintf>
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
f01004af:	0f b7 05 28 22 21 f0 	movzwl 0xf0212228,%eax
f01004b6:	66 85 c0             	test   %ax,%ax
f01004b9:	0f 84 e6 00 00 00    	je     f01005a5 <cons_putc+0x1b3>
			crt_pos--;
f01004bf:	83 e8 01             	sub    $0x1,%eax
f01004c2:	66 a3 28 22 21 f0    	mov    %ax,0xf0212228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004c8:	0f b7 c0             	movzwl %ax,%eax
f01004cb:	66 81 e7 00 ff       	and    $0xff00,%di
f01004d0:	83 cf 20             	or     $0x20,%edi
f01004d3:	8b 15 2c 22 21 f0    	mov    0xf021222c,%edx
f01004d9:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004dd:	eb 78                	jmp    f0100557 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004df:	66 83 05 28 22 21 f0 	addw   $0x50,0xf0212228
f01004e6:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004e7:	0f b7 05 28 22 21 f0 	movzwl 0xf0212228,%eax
f01004ee:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004f4:	c1 e8 16             	shr    $0x16,%eax
f01004f7:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004fa:	c1 e0 04             	shl    $0x4,%eax
f01004fd:	66 a3 28 22 21 f0    	mov    %ax,0xf0212228
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
f0100539:	0f b7 05 28 22 21 f0 	movzwl 0xf0212228,%eax
f0100540:	8d 50 01             	lea    0x1(%eax),%edx
f0100543:	66 89 15 28 22 21 f0 	mov    %dx,0xf0212228
f010054a:	0f b7 c0             	movzwl %ax,%eax
f010054d:	8b 15 2c 22 21 f0    	mov    0xf021222c,%edx
f0100553:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100557:	66 81 3d 28 22 21 f0 	cmpw   $0x7cf,0xf0212228
f010055e:	cf 07 
f0100560:	76 43                	jbe    f01005a5 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100562:	a1 2c 22 21 f0       	mov    0xf021222c,%eax
f0100567:	83 ec 04             	sub    $0x4,%esp
f010056a:	68 00 0f 00 00       	push   $0xf00
f010056f:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100575:	52                   	push   %edx
f0100576:	50                   	push   %eax
f0100577:	e8 32 55 00 00       	call   f0105aae <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010057c:	8b 15 2c 22 21 f0    	mov    0xf021222c,%edx
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
f010059d:	66 83 2d 28 22 21 f0 	subw   $0x50,0xf0212228
f01005a4:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01005a5:	8b 0d 30 22 21 f0    	mov    0xf0212230,%ecx
f01005ab:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005b0:	89 ca                	mov    %ecx,%edx
f01005b2:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005b3:	0f b7 1d 28 22 21 f0 	movzwl 0xf0212228,%ebx
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
f01005db:	80 3d 34 22 21 f0 00 	cmpb   $0x0,0xf0212234
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
f0100619:	a1 20 22 21 f0       	mov    0xf0212220,%eax
f010061e:	3b 05 24 22 21 f0    	cmp    0xf0212224,%eax
f0100624:	74 26                	je     f010064c <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100626:	8d 50 01             	lea    0x1(%eax),%edx
f0100629:	89 15 20 22 21 f0    	mov    %edx,0xf0212220
f010062f:	0f b6 88 20 20 21 f0 	movzbl -0xfdedfe0(%eax),%ecx
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
f0100640:	c7 05 20 22 21 f0 00 	movl   $0x0,0xf0212220
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
f0100679:	c7 05 30 22 21 f0 b4 	movl   $0x3b4,0xf0212230
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
f0100691:	c7 05 30 22 21 f0 d4 	movl   $0x3d4,0xf0212230
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
f01006a0:	8b 3d 30 22 21 f0    	mov    0xf0212230,%edi
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
f01006c5:	89 35 2c 22 21 f0    	mov    %esi,0xf021222c
	crt_pos = pos;
f01006cb:	0f b6 c0             	movzbl %al,%eax
f01006ce:	09 c8                	or     %ecx,%eax
f01006d0:	66 a3 28 22 21 f0    	mov    %ax,0xf0212228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006d6:	e8 1c ff ff ff       	call   f01005f7 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006db:	83 ec 0c             	sub    $0xc,%esp
f01006de:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f01006e5:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006ea:	50                   	push   %eax
f01006eb:	e8 9e 31 00 00       	call   f010388e <irq_setmask_8259A>
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
f010074e:	0f 95 05 34 22 21 f0 	setne  0xf0212234
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
f0100763:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f010076a:	25 ef ff 00 00       	and    $0xffef,%eax
f010076f:	50                   	push   %eax
f0100770:	e8 19 31 00 00       	call   f010388e <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100775:	83 c4 10             	add    $0x10,%esp
f0100778:	80 3d 34 22 21 f0 00 	cmpb   $0x0,0xf0212234
f010077f:	75 10                	jne    f0100791 <cons_init+0x13e>
		cprintf("Serial port does not exist!\n");
f0100781:	83 ec 0c             	sub    $0xc,%esp
f0100784:	68 ef 67 10 f0       	push   $0xf01067ef
f0100789:	e8 51 32 00 00       	call   f01039df <cprintf>
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
f01007ca:	68 40 6a 10 f0       	push   $0xf0106a40
f01007cf:	68 5e 6a 10 f0       	push   $0xf0106a5e
f01007d4:	68 63 6a 10 f0       	push   $0xf0106a63
f01007d9:	e8 01 32 00 00       	call   f01039df <cprintf>
f01007de:	83 c4 0c             	add    $0xc,%esp
f01007e1:	68 1c 6b 10 f0       	push   $0xf0106b1c
f01007e6:	68 6c 6a 10 f0       	push   $0xf0106a6c
f01007eb:	68 63 6a 10 f0       	push   $0xf0106a63
f01007f0:	e8 ea 31 00 00       	call   f01039df <cprintf>
f01007f5:	83 c4 0c             	add    $0xc,%esp
f01007f8:	68 75 6a 10 f0       	push   $0xf0106a75
f01007fd:	68 7d 6a 10 f0       	push   $0xf0106a7d
f0100802:	68 63 6a 10 f0       	push   $0xf0106a63
f0100807:	e8 d3 31 00 00       	call   f01039df <cprintf>
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
f0100819:	68 87 6a 10 f0       	push   $0xf0106a87
f010081e:	e8 bc 31 00 00       	call   f01039df <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100823:	83 c4 08             	add    $0x8,%esp
f0100826:	68 0c 00 10 00       	push   $0x10000c
f010082b:	68 44 6b 10 f0       	push   $0xf0106b44
f0100830:	e8 aa 31 00 00       	call   f01039df <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100835:	83 c4 0c             	add    $0xc,%esp
f0100838:	68 0c 00 10 00       	push   $0x10000c
f010083d:	68 0c 00 10 f0       	push   $0xf010000c
f0100842:	68 6c 6b 10 f0       	push   $0xf0106b6c
f0100847:	e8 93 31 00 00       	call   f01039df <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010084c:	83 c4 0c             	add    $0xc,%esp
f010084f:	68 01 67 10 00       	push   $0x106701
f0100854:	68 01 67 10 f0       	push   $0xf0106701
f0100859:	68 90 6b 10 f0       	push   $0xf0106b90
f010085e:	e8 7c 31 00 00       	call   f01039df <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100863:	83 c4 0c             	add    $0xc,%esp
f0100866:	68 e4 1f 21 00       	push   $0x211fe4
f010086b:	68 e4 1f 21 f0       	push   $0xf0211fe4
f0100870:	68 b4 6b 10 f0       	push   $0xf0106bb4
f0100875:	e8 65 31 00 00       	call   f01039df <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010087a:	83 c4 0c             	add    $0xc,%esp
f010087d:	68 08 40 25 00       	push   $0x254008
f0100882:	68 08 40 25 f0       	push   $0xf0254008
f0100887:	68 d8 6b 10 f0       	push   $0xf0106bd8
f010088c:	e8 4e 31 00 00       	call   f01039df <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100891:	b8 07 44 25 f0       	mov    $0xf0254407,%eax
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
f01008b2:	68 fc 6b 10 f0       	push   $0xf0106bfc
f01008b7:	e8 23 31 00 00       	call   f01039df <cprintf>
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
f01008ce:	68 a0 6a 10 f0       	push   $0xf0106aa0
f01008d3:	e8 07 31 00 00       	call   f01039df <cprintf>
	
	while (ebp != 0) {
f01008d8:	83 c4 10             	add    $0x10,%esp
f01008db:	eb 67                	jmp    f0100944 <mon_backtrace+0x81>
		eip = ebp + 1;	   //eip is stored after ebp
		cprintf("ebp %x eip %x args ", ebp, *eip);
f01008dd:	83 ec 04             	sub    $0x4,%esp
f01008e0:	ff 76 04             	pushl  0x4(%esi)
f01008e3:	56                   	push   %esi
f01008e4:	68 b2 6a 10 f0       	push   $0xf0106ab2
f01008e9:	e8 f1 30 00 00       	call   f01039df <cprintf>
f01008ee:	8d 5e 08             	lea    0x8(%esi),%ebx
f01008f1:	8d 7e 1c             	lea    0x1c(%esi),%edi
f01008f4:	83 c4 10             	add    $0x10,%esp

		size_t arg_num;
		//print arguments stored after instruction pointer
		for (arg_num = 1; arg_num <= 5; arg_num++) {
			cprintf("%08x ", *(eip + arg_num));
f01008f7:	83 ec 08             	sub    $0x8,%esp
f01008fa:	ff 33                	pushl  (%ebx)
f01008fc:	68 c6 6a 10 f0       	push   $0xf0106ac6
f0100901:	e8 d9 30 00 00       	call   f01039df <cprintf>
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
f010091a:	e8 5a 47 00 00       	call   f0105079 <debuginfo_eip>

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
f0100935:	68 cc 6a 10 f0       	push   $0xf0106acc
f010093a:	e8 a0 30 00 00       	call   f01039df <cprintf>
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
f010095e:	68 28 6c 10 f0       	push   $0xf0106c28
f0100963:	e8 77 30 00 00       	call   f01039df <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100968:	c7 04 24 4c 6c 10 f0 	movl   $0xf0106c4c,(%esp)
f010096f:	e8 6b 30 00 00       	call   f01039df <cprintf>

	if (tf != NULL)
f0100974:	83 c4 10             	add    $0x10,%esp
f0100977:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010097b:	74 0e                	je     f010098b <monitor+0x36>
		print_trapframe(tf);
f010097d:	83 ec 0c             	sub    $0xc,%esp
f0100980:	ff 75 08             	pushl  0x8(%ebp)
f0100983:	e8 ce 37 00 00       	call   f0104156 <print_trapframe>
f0100988:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f010098b:	83 ec 0c             	sub    $0xc,%esp
f010098e:	68 de 6a 10 f0       	push   $0xf0106ade
f0100993:	e8 5a 4e 00 00       	call   f01057f2 <readline>
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
f01009c7:	68 e2 6a 10 f0       	push   $0xf0106ae2
f01009cc:	e8 53 50 00 00       	call   f0105a24 <strchr>
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
f01009e7:	68 e7 6a 10 f0       	push   $0xf0106ae7
f01009ec:	e8 ee 2f 00 00       	call   f01039df <cprintf>
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
f0100a10:	68 e2 6a 10 f0       	push   $0xf0106ae2
f0100a15:	e8 0a 50 00 00       	call   f0105a24 <strchr>
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
f0100a3e:	ff 34 85 80 6c 10 f0 	pushl  -0xfef9380(,%eax,4)
f0100a45:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a48:	e8 79 4f 00 00       	call   f01059c6 <strcmp>
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
f0100a62:	ff 14 85 88 6c 10 f0 	call   *-0xfef9378(,%eax,4)
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
f0100a83:	68 04 6b 10 f0       	push   $0xf0106b04
f0100a88:	e8 52 2f 00 00       	call   f01039df <cprintf>
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
f0100aa8:	e8 b3 2d 00 00       	call   f0103860 <mc146818_read>
f0100aad:	89 c6                	mov    %eax,%esi
f0100aaf:	83 c3 01             	add    $0x1,%ebx
f0100ab2:	89 1c 24             	mov    %ebx,(%esp)
f0100ab5:	e8 a6 2d 00 00       	call   f0103860 <mc146818_read>
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
f0100adc:	3b 0d 88 2e 21 f0    	cmp    0xf0212e88,%ecx
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
f0100aeb:	68 44 67 10 f0       	push   $0xf0106744
f0100af0:	68 c5 03 00 00       	push   $0x3c5
f0100af5:	68 11 76 10 f0       	push   $0xf0107611
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
f0100b30:	83 3d 38 22 21 f0 00 	cmpl   $0x0,0xf0212238
f0100b37:	75 11                	jne    f0100b4a <boot_alloc+0x20>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100b39:	ba 07 50 25 f0       	mov    $0xf0255007,%edx
f0100b3e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b44:	89 15 38 22 21 f0    	mov    %edx,0xf0212238
        // Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
        if (n == 0)
f0100b4a:	85 c0                	test   %eax,%eax
f0100b4c:	75 07                	jne    f0100b55 <boot_alloc+0x2b>
                return nextfree;
f0100b4e:	a1 38 22 21 f0       	mov    0xf0212238,%eax
f0100b53:	eb 52                	jmp    f0100ba7 <boot_alloc+0x7d>
f0100b55:	89 c2                	mov    %eax,%edx

        // We only have 4MB of memory available
        if (4 * 1024 * 1024 - PADDR(nextfree) < n)
f0100b57:	a1 38 22 21 f0       	mov    0xf0212238,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100b5c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100b61:	77 12                	ja     f0100b75 <boot_alloc+0x4b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100b63:	50                   	push   %eax
f0100b64:	68 68 67 10 f0       	push   $0xf0106768
f0100b69:	6a 70                	push   $0x70
f0100b6b:	68 11 76 10 f0       	push   $0xf0107611
f0100b70:	e8 cb f4 ff ff       	call   f0100040 <_panic>
f0100b75:	b9 00 00 40 f0       	mov    $0xf0400000,%ecx
f0100b7a:	29 c1                	sub    %eax,%ecx
f0100b7c:	39 ca                	cmp    %ecx,%edx
f0100b7e:	76 14                	jbe    f0100b94 <boot_alloc+0x6a>
               panic("boot_alloc: ran out of free memory"); 
f0100b80:	83 ec 04             	sub    $0x4,%esp
f0100b83:	68 a4 6c 10 f0       	push   $0xf0106ca4
f0100b88:	6a 71                	push   $0x71
f0100b8a:	68 11 76 10 f0       	push   $0xf0107611
f0100b8f:	e8 ac f4 ff ff       	call   f0100040 <_panic>

        result = nextfree;        
        nextfree = ROUNDUP((char *) (nextfree + n), PGSIZE);
f0100b94:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0100b9b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100ba1:	89 15 38 22 21 f0    	mov    %edx,0xf0212238

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
f0100bc2:	68 c8 6c 10 f0       	push   $0xf0106cc8
f0100bc7:	68 f8 02 00 00       	push   $0x2f8
f0100bcc:	68 11 76 10 f0       	push   $0xf0107611
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
f0100be4:	2b 15 90 2e 21 f0    	sub    0xf0212e90,%edx
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
f0100c1a:	a3 40 22 21 f0       	mov    %eax,0xf0212240
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
f0100c24:	8b 1d 40 22 21 f0    	mov    0xf0212240,%ebx
f0100c2a:	eb 53                	jmp    f0100c7f <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c2c:	89 d8                	mov    %ebx,%eax
f0100c2e:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
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
f0100c48:	3b 15 88 2e 21 f0    	cmp    0xf0212e88,%edx
f0100c4e:	72 12                	jb     f0100c62 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c50:	50                   	push   %eax
f0100c51:	68 44 67 10 f0       	push   $0xf0106744
f0100c56:	6a 58                	push   $0x58
f0100c58:	68 1d 76 10 f0       	push   $0xf010761d
f0100c5d:	e8 de f3 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c62:	83 ec 04             	sub    $0x4,%esp
f0100c65:	68 80 00 00 00       	push   $0x80
f0100c6a:	68 97 00 00 00       	push   $0x97
f0100c6f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c74:	50                   	push   %eax
f0100c75:	e8 e7 4d 00 00       	call   f0105a61 <memset>
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
f0100c90:	8b 15 40 22 21 f0    	mov    0xf0212240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c96:	8b 0d 90 2e 21 f0    	mov    0xf0212e90,%ecx
		assert(pp < pages + npages);
f0100c9c:	a1 88 2e 21 f0       	mov    0xf0212e88,%eax
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
f0100cbb:	68 2b 76 10 f0       	push   $0xf010762b
f0100cc0:	68 37 76 10 f0       	push   $0xf0107637
f0100cc5:	68 12 03 00 00       	push   $0x312
f0100cca:	68 11 76 10 f0       	push   $0xf0107611
f0100ccf:	e8 6c f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100cd4:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100cd7:	72 19                	jb     f0100cf2 <check_page_free_list+0x149>
f0100cd9:	68 4c 76 10 f0       	push   $0xf010764c
f0100cde:	68 37 76 10 f0       	push   $0xf0107637
f0100ce3:	68 13 03 00 00       	push   $0x313
f0100ce8:	68 11 76 10 f0       	push   $0xf0107611
f0100ced:	e8 4e f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cf2:	89 d0                	mov    %edx,%eax
f0100cf4:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100cf7:	a8 07                	test   $0x7,%al
f0100cf9:	74 19                	je     f0100d14 <check_page_free_list+0x16b>
f0100cfb:	68 ec 6c 10 f0       	push   $0xf0106cec
f0100d00:	68 37 76 10 f0       	push   $0xf0107637
f0100d05:	68 14 03 00 00       	push   $0x314
f0100d0a:	68 11 76 10 f0       	push   $0xf0107611
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
f0100d1e:	68 60 76 10 f0       	push   $0xf0107660
f0100d23:	68 37 76 10 f0       	push   $0xf0107637
f0100d28:	68 17 03 00 00       	push   $0x317
f0100d2d:	68 11 76 10 f0       	push   $0xf0107611
f0100d32:	e8 09 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d37:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d3c:	75 19                	jne    f0100d57 <check_page_free_list+0x1ae>
f0100d3e:	68 71 76 10 f0       	push   $0xf0107671
f0100d43:	68 37 76 10 f0       	push   $0xf0107637
f0100d48:	68 18 03 00 00       	push   $0x318
f0100d4d:	68 11 76 10 f0       	push   $0xf0107611
f0100d52:	e8 e9 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d57:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d5c:	75 19                	jne    f0100d77 <check_page_free_list+0x1ce>
f0100d5e:	68 20 6d 10 f0       	push   $0xf0106d20
f0100d63:	68 37 76 10 f0       	push   $0xf0107637
f0100d68:	68 19 03 00 00       	push   $0x319
f0100d6d:	68 11 76 10 f0       	push   $0xf0107611
f0100d72:	e8 c9 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d77:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d7c:	75 19                	jne    f0100d97 <check_page_free_list+0x1ee>
f0100d7e:	68 8a 76 10 f0       	push   $0xf010768a
f0100d83:	68 37 76 10 f0       	push   $0xf0107637
f0100d88:	68 1a 03 00 00       	push   $0x31a
f0100d8d:	68 11 76 10 f0       	push   $0xf0107611
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
f0100dad:	68 44 67 10 f0       	push   $0xf0106744
f0100db2:	6a 58                	push   $0x58
f0100db4:	68 1d 76 10 f0       	push   $0xf010761d
f0100db9:	e8 82 f2 ff ff       	call   f0100040 <_panic>
f0100dbe:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100dc4:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100dc7:	0f 86 b6 00 00 00    	jbe    f0100e83 <check_page_free_list+0x2da>
f0100dcd:	68 44 6d 10 f0       	push   $0xf0106d44
f0100dd2:	68 37 76 10 f0       	push   $0xf0107637
f0100dd7:	68 1b 03 00 00       	push   $0x31b
f0100ddc:	68 11 76 10 f0       	push   $0xf0107611
f0100de1:	e8 5a f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100de6:	68 a4 76 10 f0       	push   $0xf01076a4
f0100deb:	68 37 76 10 f0       	push   $0xf0107637
f0100df0:	68 1d 03 00 00       	push   $0x31d
f0100df5:	68 11 76 10 f0       	push   $0xf0107611
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
f0100e15:	68 c1 76 10 f0       	push   $0xf01076c1
f0100e1a:	68 37 76 10 f0       	push   $0xf0107637
f0100e1f:	68 25 03 00 00       	push   $0x325
f0100e24:	68 11 76 10 f0       	push   $0xf0107611
f0100e29:	e8 12 f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e2e:	85 db                	test   %ebx,%ebx
f0100e30:	7f 19                	jg     f0100e4b <check_page_free_list+0x2a2>
f0100e32:	68 d3 76 10 f0       	push   $0xf01076d3
f0100e37:	68 37 76 10 f0       	push   $0xf0107637
f0100e3c:	68 26 03 00 00       	push   $0x326
f0100e41:	68 11 76 10 f0       	push   $0xf0107611
f0100e46:	e8 f5 f1 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100e4b:	83 ec 0c             	sub    $0xc,%esp
f0100e4e:	68 8c 6d 10 f0       	push   $0xf0106d8c
f0100e53:	e8 87 2b 00 00       	call   f01039df <cprintf>
}
f0100e58:	eb 49                	jmp    f0100ea3 <check_page_free_list+0x2fa>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e5a:	a1 40 22 21 f0       	mov    0xf0212240,%eax
f0100e5f:	85 c0                	test   %eax,%eax
f0100e61:	0f 85 6f fd ff ff    	jne    f0100bd6 <check_page_free_list+0x2d>
f0100e67:	e9 53 fd ff ff       	jmp    f0100bbf <check_page_free_list+0x16>
f0100e6c:	83 3d 40 22 21 f0 00 	cmpl   $0x0,0xf0212240
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
f0100eab:	a1 90 2e 21 f0       	mov    0xf0212e90,%eax
f0100eb0:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0100eb5:	8b 15 40 22 21 f0    	mov    0xf0212240,%edx
f0100ebb:	b8 08 00 00 00       	mov    $0x8,%eax
        // 2) All base pages except 0 are free
        size_t i;
        size_t mpentry_page = MPENTRY_PADDR / PGSIZE; 

        for (i = 1; i < mpentry_page; i++) {
                pages[i].pp_link = page_free_list;
f0100ec0:	8b 0d 90 2e 21 f0    	mov    0xf0212e90,%ecx
f0100ec6:	89 14 01             	mov    %edx,(%ecx,%eax,1)
                page_free_list = &pages[i];
f0100ec9:	8b 0d 90 2e 21 f0    	mov    0xf0212e90,%ecx
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
f0100edf:	89 15 40 22 21 f0    	mov    %edx,0xf0212240
        for (i = 1; i < mpentry_page; i++) {
                pages[i].pp_link = page_free_list;
                page_free_list = &pages[i];
        }

        pages[mpentry_page].pp_ref++;
f0100ee5:	66 83 41 3c 01       	addw   $0x1,0x3c(%ecx)

        for (i = mpentry_page + 1; i < npages_basemem; i++) {
f0100eea:	8b 1d 44 22 21 f0    	mov    0xf0212244,%ebx
f0100ef0:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100ef5:	b8 08 00 00 00       	mov    $0x8,%eax
f0100efa:	eb 20                	jmp    f0100f1c <page_init+0x71>
f0100efc:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
                pages[i].pp_link = page_free_list;
f0100f03:	8b 35 90 2e 21 f0    	mov    0xf0212e90,%esi
f0100f09:	89 14 c6             	mov    %edx,(%esi,%eax,8)
                page_free_list = &pages[i];
        }

        pages[mpentry_page].pp_ref++;

        for (i = mpentry_page + 1; i < npages_basemem; i++) {
f0100f0c:	83 c0 01             	add    $0x1,%eax
                pages[i].pp_link = page_free_list;
                page_free_list = &pages[i];
f0100f0f:	89 ca                	mov    %ecx,%edx
f0100f11:	03 15 90 2e 21 f0    	add    0xf0212e90,%edx
f0100f17:	b9 01 00 00 00       	mov    $0x1,%ecx
                page_free_list = &pages[i];
        }

        pages[mpentry_page].pp_ref++;

        for (i = mpentry_page + 1; i < npages_basemem; i++) {
f0100f1c:	39 d8                	cmp    %ebx,%eax
f0100f1e:	72 dc                	jb     f0100efc <page_init+0x51>
f0100f20:	84 c9                	test   %cl,%cl
f0100f22:	74 06                	je     f0100f2a <page_init+0x7f>
f0100f24:	89 15 40 22 21 f0    	mov    %edx,0xf0212240
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
f0100f3c:	68 68 67 10 f0       	push   $0xf0106768
f0100f41:	68 58 01 00 00       	push   $0x158
f0100f46:	68 11 76 10 f0       	push   $0xf0107611
f0100f4b:	e8 f0 f0 ff ff       	call   f0100040 <_panic>
f0100f50:	05 00 00 00 10       	add    $0x10000000,%eax
f0100f55:	c1 e8 0c             	shr    $0xc,%eax
f0100f58:	8b 0d 40 22 21 f0    	mov    0xf0212240,%ecx
f0100f5e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100f65:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100f6a:	eb 1c                	jmp    f0100f88 <page_init+0xdd>
                pages[i].pp_link = page_free_list;
f0100f6c:	8b 35 90 2e 21 f0    	mov    0xf0212e90,%esi
f0100f72:	89 0c 16             	mov    %ecx,(%esi,%edx,1)
                page_free_list = &pages[i];
f0100f75:	89 d1                	mov    %edx,%ecx
f0100f77:	03 0d 90 2e 21 f0    	add    0xf0212e90,%ecx
                page_free_list = &pages[i];
        }

        // 4) We find the next free memory (boot_alloc() outputs a rounded-up virtual address),
        // convert it to a physical address and get the index of free pages by dividing by PGSIZE  
        for (i = PADDR(boot_alloc(0)) / PGSIZE; i < npages; i++) {
f0100f7d:	83 c0 01             	add    $0x1,%eax
f0100f80:	83 c2 08             	add    $0x8,%edx
f0100f83:	bb 01 00 00 00       	mov    $0x1,%ebx
f0100f88:	3b 05 88 2e 21 f0    	cmp    0xf0212e88,%eax
f0100f8e:	72 dc                	jb     f0100f6c <page_init+0xc1>
f0100f90:	84 db                	test   %bl,%bl
f0100f92:	74 06                	je     f0100f9a <page_init+0xef>
f0100f94:	89 0d 40 22 21 f0    	mov    %ecx,0xf0212240
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
f0100fa8:	8b 1d 40 22 21 f0    	mov    0xf0212240,%ebx
f0100fae:	85 db                	test   %ebx,%ebx
f0100fb0:	74 58                	je     f010100a <page_alloc+0x69>
                return NULL;

        struct PageInfo *page = page_free_list;
        page_free_list = page->pp_link;
f0100fb2:	8b 03                	mov    (%ebx),%eax
f0100fb4:	a3 40 22 21 f0       	mov    %eax,0xf0212240

	if (alloc_flags & ALLOC_ZERO) {
f0100fb9:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100fbd:	74 45                	je     f0101004 <page_alloc+0x63>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100fbf:	89 d8                	mov    %ebx,%eax
f0100fc1:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f0100fc7:	c1 f8 03             	sar    $0x3,%eax
f0100fca:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fcd:	89 c2                	mov    %eax,%edx
f0100fcf:	c1 ea 0c             	shr    $0xc,%edx
f0100fd2:	3b 15 88 2e 21 f0    	cmp    0xf0212e88,%edx
f0100fd8:	72 12                	jb     f0100fec <page_alloc+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fda:	50                   	push   %eax
f0100fdb:	68 44 67 10 f0       	push   $0xf0106744
f0100fe0:	6a 58                	push   $0x58
f0100fe2:	68 1d 76 10 f0       	push   $0xf010761d
f0100fe7:	e8 54 f0 ff ff       	call   f0100040 <_panic>
                char *p = page2kva(page);
                memset(p, 0, PGSIZE);
f0100fec:	83 ec 04             	sub    $0x4,%esp
f0100fef:	68 00 10 00 00       	push   $0x1000
f0100ff4:	6a 00                	push   $0x0
f0100ff6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ffb:	50                   	push   %eax
f0100ffc:	e8 60 4a 00 00       	call   f0105a61 <memset>
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
f010101e:	68 1e 78 10 f0       	push   $0xf010781e
f0101023:	68 37 76 10 f0       	push   $0xf0107637
f0101028:	68 83 01 00 00       	push   $0x183
f010102d:	68 11 76 10 f0       	push   $0xf0107611
f0101032:	e8 09 f0 ff ff       	call   f0100040 <_panic>

        // Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
        if (pp->pp_ref != 0) 
f0101037:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010103c:	74 17                	je     f0101055 <page_free+0x44>
                panic("pp->pp_ref is nonzero\n");
f010103e:	83 ec 04             	sub    $0x4,%esp
f0101041:	68 e4 76 10 f0       	push   $0xf01076e4
f0101046:	68 89 01 00 00       	push   $0x189
f010104b:	68 11 76 10 f0       	push   $0xf0107611
f0101050:	e8 eb ef ff ff       	call   f0100040 <_panic>

        if (pp->pp_link != NULL)
f0101055:	83 38 00             	cmpl   $0x0,(%eax)
f0101058:	74 17                	je     f0101071 <page_free+0x60>
                panic("pp->pp_link is not NULL\n");
f010105a:	83 ec 04             	sub    $0x4,%esp
f010105d:	68 fb 76 10 f0       	push   $0xf01076fb
f0101062:	68 8c 01 00 00       	push   $0x18c
f0101067:	68 11 76 10 f0       	push   $0xf0107611
f010106c:	e8 cf ef ff ff       	call   f0100040 <_panic>

        pp->pp_link = page_free_list;
f0101071:	8b 15 40 22 21 f0    	mov    0xf0212240,%edx
f0101077:	89 10                	mov    %edx,(%eax)
        page_free_list = pp;
f0101079:	a3 40 22 21 f0       	mov    %eax,0xf0212240
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
f01010b6:	68 14 77 10 f0       	push   $0xf0107714
f01010bb:	68 37 76 10 f0       	push   $0xf0107637
f01010c0:	68 b6 01 00 00       	push   $0x1b6
f01010c5:	68 11 76 10 f0       	push   $0xf0107611
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
f01010e9:	39 05 88 2e 21 f0    	cmp    %eax,0xf0212e88
f01010ef:	77 15                	ja     f0101106 <pgdir_walk+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010f1:	52                   	push   %edx
f01010f2:	68 44 67 10 f0       	push   $0xf0106744
f01010f7:	68 bd 01 00 00       	push   $0x1bd
f01010fc:	68 11 76 10 f0       	push   $0xf0107611
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
f0101127:	2b 15 90 2e 21 f0    	sub    0xf0212e90,%edx
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
f010113d:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f0101143:	c1 f8 03             	sar    $0x3,%eax
f0101146:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101149:	89 c2                	mov    %eax,%edx
f010114b:	c1 ea 0c             	shr    $0xc,%edx
f010114e:	3b 15 88 2e 21 f0    	cmp    0xf0212e88,%edx
f0101154:	72 12                	jb     f0101168 <pgdir_walk+0xc1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101156:	50                   	push   %eax
f0101157:	68 44 67 10 f0       	push   $0xf0106744
f010115c:	6a 58                	push   $0x58
f010115e:	68 1d 76 10 f0       	push   $0xf010761d
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
f01011be:	68 14 77 10 f0       	push   $0xf0107714
f01011c3:	68 37 76 10 f0       	push   $0xf0107637
f01011c8:	68 dd 01 00 00       	push   $0x1dd
f01011cd:	68 11 76 10 f0       	push   $0xf0107611
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
f01011ef:	68 1a 77 10 f0       	push   $0xf010771a
f01011f4:	68 37 76 10 f0       	push   $0xf0107637
f01011f9:	68 e5 01 00 00       	push   $0x1e5
f01011fe:	68 11 76 10 f0       	push   $0xf0107611
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
f0101236:	68 14 77 10 f0       	push   $0xf0107714
f010123b:	68 37 76 10 f0       	push   $0xf0107637
f0101240:	68 32 02 00 00       	push   $0x232
f0101245:	68 11 76 10 f0       	push   $0xf0107611
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
f0101274:	3b 05 88 2e 21 f0    	cmp    0xf0212e88,%eax
f010127a:	72 14                	jb     f0101290 <page_lookup+0x6b>
		panic("pa2page called with invalid pa");
f010127c:	83 ec 04             	sub    $0x4,%esp
f010127f:	68 b0 6d 10 f0       	push   $0xf0106db0
f0101284:	6a 51                	push   $0x51
f0101286:	68 1d 76 10 f0       	push   $0xf010761d
f010128b:	e8 b0 ed ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0101290:	8b 15 90 2e 21 f0    	mov    0xf0212e90,%edx
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
f01012b2:	e8 cb 4d 00 00       	call   f0106082 <cpunum>
f01012b7:	6b c0 74             	imul   $0x74,%eax,%eax
f01012ba:	83 b8 28 30 21 f0 00 	cmpl   $0x0,-0xfdecfd8(%eax)
f01012c1:	74 16                	je     f01012d9 <tlb_invalidate+0x2d>
f01012c3:	e8 ba 4d 00 00       	call   f0106082 <cpunum>
f01012c8:	6b c0 74             	imul   $0x74,%eax,%eax
f01012cb:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f01012d1:	8b 55 08             	mov    0x8(%ebp),%edx
f01012d4:	39 50 68             	cmp    %edx,0x68(%eax)
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
f01012f3:	68 14 77 10 f0       	push   $0xf0107714
f01012f8:	68 37 76 10 f0       	push   $0xf0107637
f01012fd:	68 51 02 00 00       	push   $0x251
f0101302:	68 11 76 10 f0       	push   $0xf0107611
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
f0101362:	68 14 77 10 f0       	push   $0xf0107714
f0101367:	68 37 76 10 f0       	push   $0xf0107637
f010136c:	68 0a 02 00 00       	push   $0x20a
f0101371:	68 11 76 10 f0       	push   $0xf0107611
f0101376:	e8 c5 ec ff ff       	call   f0100040 <_panic>
        assert(pp);
f010137b:	85 db                	test   %ebx,%ebx
f010137d:	75 19                	jne    f0101398 <page_insert+0x49>
f010137f:	68 1e 78 10 f0       	push   $0xf010781e
f0101384:	68 37 76 10 f0       	push   $0xf0107637
f0101389:	68 0b 02 00 00       	push   $0x20b
f010138e:	68 11 76 10 f0       	push   $0xf0107611
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
f01013bc:	2b 15 90 2e 21 f0    	sub    0xf0212e90,%edx
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
f01013ec:	2b 1d 90 2e 21 f0    	sub    0xf0212e90,%ebx
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
f010142a:	8b 35 00 13 12 f0    	mov    0xf0121300,%esi

        if (base + sz > MMIOLIM)
f0101430:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f0101433:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f0101438:	76 17                	jbe    f0101451 <mmio_map_region+0x3b>
                panic("mmio_map_region: base + sz > MMIOLIM");
f010143a:	83 ec 04             	sub    $0x4,%esp
f010143d:	68 d0 6d 10 f0       	push   $0xf0106dd0
f0101442:	68 91 02 00 00       	push   $0x291
f0101447:	68 11 76 10 f0       	push   $0xf0107611
f010144c:	e8 ef eb ff ff       	call   f0100040 <_panic>

        boot_map_region(kern_pgdir, base, sz, pa, PTE_W | PTE_PCD | PTE_PWT);      
f0101451:	83 ec 08             	sub    $0x8,%esp
f0101454:	6a 1a                	push   $0x1a
f0101456:	ff 75 08             	pushl  0x8(%ebp)
f0101459:	89 d9                	mov    %ebx,%ecx
f010145b:	89 f2                	mov    %esi,%edx
f010145d:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
f0101462:	e8 28 fd ff ff       	call   f010118f <boot_map_region>
        base += sz;
f0101467:	01 1d 00 13 12 f0    	add    %ebx,0xf0121300
        
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
f01014bf:	89 15 88 2e 21 f0    	mov    %edx,0xf0212e88
	npages_basemem = basemem / (PGSIZE / 1024);
f01014c5:	89 da                	mov    %ebx,%edx
f01014c7:	c1 ea 02             	shr    $0x2,%edx
f01014ca:	89 15 44 22 21 f0    	mov    %edx,0xf0212244

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01014d0:	89 c2                	mov    %eax,%edx
f01014d2:	29 da                	sub    %ebx,%edx
f01014d4:	52                   	push   %edx
f01014d5:	53                   	push   %ebx
f01014d6:	50                   	push   %eax
f01014d7:	68 f8 6d 10 f0       	push   $0xf0106df8
f01014dc:	e8 fe 24 00 00       	call   f01039df <cprintf>
	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01014e1:	b8 00 10 00 00       	mov    $0x1000,%eax
f01014e6:	e8 3f f6 ff ff       	call   f0100b2a <boot_alloc>
f01014eb:	a3 8c 2e 21 f0       	mov    %eax,0xf0212e8c
	memset(kern_pgdir, 0, PGSIZE);
f01014f0:	83 c4 0c             	add    $0xc,%esp
f01014f3:	68 00 10 00 00       	push   $0x1000
f01014f8:	6a 00                	push   $0x0
f01014fa:	50                   	push   %eax
f01014fb:	e8 61 45 00 00       	call   f0105a61 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101500:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
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
f0101510:	68 68 67 10 f0       	push   $0xf0106768
f0101515:	68 97 00 00 00       	push   $0x97
f010151a:	68 11 76 10 f0       	push   $0xf0107611
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
f0101533:	a1 88 2e 21 f0       	mov    0xf0212e88,%eax
f0101538:	c1 e0 03             	shl    $0x3,%eax
f010153b:	89 c7                	mov    %eax,%edi
f010153d:	89 45 cc             	mov    %eax,-0x34(%ebp)
        pages = (struct PageInfo *) boot_alloc(pages_size);
f0101540:	e8 e5 f5 ff ff       	call   f0100b2a <boot_alloc>
f0101545:	a3 90 2e 21 f0       	mov    %eax,0xf0212e90
        memset(pages, 0, pages_size);
f010154a:	83 ec 04             	sub    $0x4,%esp
f010154d:	57                   	push   %edi
f010154e:	6a 00                	push   $0x0
f0101550:	50                   	push   %eax
f0101551:	e8 0b 45 00 00       	call   f0105a61 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
        const size_t envs_size = sizeof(struct Env) * NENV;
        envs = (struct Env *) boot_alloc(envs_size);
f0101556:	b8 00 10 02 00       	mov    $0x21000,%eax
f010155b:	e8 ca f5 ff ff       	call   f0100b2a <boot_alloc>
f0101560:	a3 48 22 21 f0       	mov    %eax,0xf0212248
        memset(envs, 0, envs_size);
f0101565:	83 c4 0c             	add    $0xc,%esp
f0101568:	68 00 10 02 00       	push   $0x21000
f010156d:	6a 00                	push   $0x0
f010156f:	50                   	push   %eax
f0101570:	e8 ec 44 00 00       	call   f0105a61 <memset>
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
f0101587:	83 3d 90 2e 21 f0 00 	cmpl   $0x0,0xf0212e90
f010158e:	75 17                	jne    f01015a7 <mem_init+0x131>
		panic("'pages' is a null pointer!");
f0101590:	83 ec 04             	sub    $0x4,%esp
f0101593:	68 1e 77 10 f0       	push   $0xf010771e
f0101598:	68 39 03 00 00       	push   $0x339
f010159d:	68 11 76 10 f0       	push   $0xf0107611
f01015a2:	e8 99 ea ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01015a7:	a1 40 22 21 f0       	mov    0xf0212240,%eax
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
f01015cf:	68 39 77 10 f0       	push   $0xf0107739
f01015d4:	68 37 76 10 f0       	push   $0xf0107637
f01015d9:	68 41 03 00 00       	push   $0x341
f01015de:	68 11 76 10 f0       	push   $0xf0107611
f01015e3:	e8 58 ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01015e8:	83 ec 0c             	sub    $0xc,%esp
f01015eb:	6a 00                	push   $0x0
f01015ed:	e8 af f9 ff ff       	call   f0100fa1 <page_alloc>
f01015f2:	89 c6                	mov    %eax,%esi
f01015f4:	83 c4 10             	add    $0x10,%esp
f01015f7:	85 c0                	test   %eax,%eax
f01015f9:	75 19                	jne    f0101614 <mem_init+0x19e>
f01015fb:	68 4f 77 10 f0       	push   $0xf010774f
f0101600:	68 37 76 10 f0       	push   $0xf0107637
f0101605:	68 42 03 00 00       	push   $0x342
f010160a:	68 11 76 10 f0       	push   $0xf0107611
f010160f:	e8 2c ea ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101614:	83 ec 0c             	sub    $0xc,%esp
f0101617:	6a 00                	push   $0x0
f0101619:	e8 83 f9 ff ff       	call   f0100fa1 <page_alloc>
f010161e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101621:	83 c4 10             	add    $0x10,%esp
f0101624:	85 c0                	test   %eax,%eax
f0101626:	75 19                	jne    f0101641 <mem_init+0x1cb>
f0101628:	68 65 77 10 f0       	push   $0xf0107765
f010162d:	68 37 76 10 f0       	push   $0xf0107637
f0101632:	68 43 03 00 00       	push   $0x343
f0101637:	68 11 76 10 f0       	push   $0xf0107611
f010163c:	e8 ff e9 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101641:	39 f7                	cmp    %esi,%edi
f0101643:	75 19                	jne    f010165e <mem_init+0x1e8>
f0101645:	68 7b 77 10 f0       	push   $0xf010777b
f010164a:	68 37 76 10 f0       	push   $0xf0107637
f010164f:	68 46 03 00 00       	push   $0x346
f0101654:	68 11 76 10 f0       	push   $0xf0107611
f0101659:	e8 e2 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010165e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101661:	39 c6                	cmp    %eax,%esi
f0101663:	74 04                	je     f0101669 <mem_init+0x1f3>
f0101665:	39 c7                	cmp    %eax,%edi
f0101667:	75 19                	jne    f0101682 <mem_init+0x20c>
f0101669:	68 34 6e 10 f0       	push   $0xf0106e34
f010166e:	68 37 76 10 f0       	push   $0xf0107637
f0101673:	68 47 03 00 00       	push   $0x347
f0101678:	68 11 76 10 f0       	push   $0xf0107611
f010167d:	e8 be e9 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101682:	8b 0d 90 2e 21 f0    	mov    0xf0212e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101688:	8b 15 88 2e 21 f0    	mov    0xf0212e88,%edx
f010168e:	c1 e2 0c             	shl    $0xc,%edx
f0101691:	89 f8                	mov    %edi,%eax
f0101693:	29 c8                	sub    %ecx,%eax
f0101695:	c1 f8 03             	sar    $0x3,%eax
f0101698:	c1 e0 0c             	shl    $0xc,%eax
f010169b:	39 d0                	cmp    %edx,%eax
f010169d:	72 19                	jb     f01016b8 <mem_init+0x242>
f010169f:	68 8d 77 10 f0       	push   $0xf010778d
f01016a4:	68 37 76 10 f0       	push   $0xf0107637
f01016a9:	68 48 03 00 00       	push   $0x348
f01016ae:	68 11 76 10 f0       	push   $0xf0107611
f01016b3:	e8 88 e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01016b8:	89 f0                	mov    %esi,%eax
f01016ba:	29 c8                	sub    %ecx,%eax
f01016bc:	c1 f8 03             	sar    $0x3,%eax
f01016bf:	c1 e0 0c             	shl    $0xc,%eax
f01016c2:	39 c2                	cmp    %eax,%edx
f01016c4:	77 19                	ja     f01016df <mem_init+0x269>
f01016c6:	68 aa 77 10 f0       	push   $0xf01077aa
f01016cb:	68 37 76 10 f0       	push   $0xf0107637
f01016d0:	68 49 03 00 00       	push   $0x349
f01016d5:	68 11 76 10 f0       	push   $0xf0107611
f01016da:	e8 61 e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01016df:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01016e2:	29 c8                	sub    %ecx,%eax
f01016e4:	c1 f8 03             	sar    $0x3,%eax
f01016e7:	c1 e0 0c             	shl    $0xc,%eax
f01016ea:	39 c2                	cmp    %eax,%edx
f01016ec:	77 19                	ja     f0101707 <mem_init+0x291>
f01016ee:	68 c7 77 10 f0       	push   $0xf01077c7
f01016f3:	68 37 76 10 f0       	push   $0xf0107637
f01016f8:	68 4a 03 00 00       	push   $0x34a
f01016fd:	68 11 76 10 f0       	push   $0xf0107611
f0101702:	e8 39 e9 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101707:	a1 40 22 21 f0       	mov    0xf0212240,%eax
f010170c:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010170f:	c7 05 40 22 21 f0 00 	movl   $0x0,0xf0212240
f0101716:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101719:	83 ec 0c             	sub    $0xc,%esp
f010171c:	6a 00                	push   $0x0
f010171e:	e8 7e f8 ff ff       	call   f0100fa1 <page_alloc>
f0101723:	83 c4 10             	add    $0x10,%esp
f0101726:	85 c0                	test   %eax,%eax
f0101728:	74 19                	je     f0101743 <mem_init+0x2cd>
f010172a:	68 e4 77 10 f0       	push   $0xf01077e4
f010172f:	68 37 76 10 f0       	push   $0xf0107637
f0101734:	68 51 03 00 00       	push   $0x351
f0101739:	68 11 76 10 f0       	push   $0xf0107611
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
f0101774:	68 39 77 10 f0       	push   $0xf0107739
f0101779:	68 37 76 10 f0       	push   $0xf0107637
f010177e:	68 58 03 00 00       	push   $0x358
f0101783:	68 11 76 10 f0       	push   $0xf0107611
f0101788:	e8 b3 e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010178d:	83 ec 0c             	sub    $0xc,%esp
f0101790:	6a 00                	push   $0x0
f0101792:	e8 0a f8 ff ff       	call   f0100fa1 <page_alloc>
f0101797:	89 c7                	mov    %eax,%edi
f0101799:	83 c4 10             	add    $0x10,%esp
f010179c:	85 c0                	test   %eax,%eax
f010179e:	75 19                	jne    f01017b9 <mem_init+0x343>
f01017a0:	68 4f 77 10 f0       	push   $0xf010774f
f01017a5:	68 37 76 10 f0       	push   $0xf0107637
f01017aa:	68 59 03 00 00       	push   $0x359
f01017af:	68 11 76 10 f0       	push   $0xf0107611
f01017b4:	e8 87 e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01017b9:	83 ec 0c             	sub    $0xc,%esp
f01017bc:	6a 00                	push   $0x0
f01017be:	e8 de f7 ff ff       	call   f0100fa1 <page_alloc>
f01017c3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01017c6:	83 c4 10             	add    $0x10,%esp
f01017c9:	85 c0                	test   %eax,%eax
f01017cb:	75 19                	jne    f01017e6 <mem_init+0x370>
f01017cd:	68 65 77 10 f0       	push   $0xf0107765
f01017d2:	68 37 76 10 f0       	push   $0xf0107637
f01017d7:	68 5a 03 00 00       	push   $0x35a
f01017dc:	68 11 76 10 f0       	push   $0xf0107611
f01017e1:	e8 5a e8 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01017e6:	39 fe                	cmp    %edi,%esi
f01017e8:	75 19                	jne    f0101803 <mem_init+0x38d>
f01017ea:	68 7b 77 10 f0       	push   $0xf010777b
f01017ef:	68 37 76 10 f0       	push   $0xf0107637
f01017f4:	68 5c 03 00 00       	push   $0x35c
f01017f9:	68 11 76 10 f0       	push   $0xf0107611
f01017fe:	e8 3d e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101803:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101806:	39 c7                	cmp    %eax,%edi
f0101808:	74 04                	je     f010180e <mem_init+0x398>
f010180a:	39 c6                	cmp    %eax,%esi
f010180c:	75 19                	jne    f0101827 <mem_init+0x3b1>
f010180e:	68 34 6e 10 f0       	push   $0xf0106e34
f0101813:	68 37 76 10 f0       	push   $0xf0107637
f0101818:	68 5d 03 00 00       	push   $0x35d
f010181d:	68 11 76 10 f0       	push   $0xf0107611
f0101822:	e8 19 e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101827:	83 ec 0c             	sub    $0xc,%esp
f010182a:	6a 00                	push   $0x0
f010182c:	e8 70 f7 ff ff       	call   f0100fa1 <page_alloc>
f0101831:	83 c4 10             	add    $0x10,%esp
f0101834:	85 c0                	test   %eax,%eax
f0101836:	74 19                	je     f0101851 <mem_init+0x3db>
f0101838:	68 e4 77 10 f0       	push   $0xf01077e4
f010183d:	68 37 76 10 f0       	push   $0xf0107637
f0101842:	68 5e 03 00 00       	push   $0x35e
f0101847:	68 11 76 10 f0       	push   $0xf0107611
f010184c:	e8 ef e7 ff ff       	call   f0100040 <_panic>
f0101851:	89 f0                	mov    %esi,%eax
f0101853:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f0101859:	c1 f8 03             	sar    $0x3,%eax
f010185c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010185f:	89 c2                	mov    %eax,%edx
f0101861:	c1 ea 0c             	shr    $0xc,%edx
f0101864:	3b 15 88 2e 21 f0    	cmp    0xf0212e88,%edx
f010186a:	72 12                	jb     f010187e <mem_init+0x408>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010186c:	50                   	push   %eax
f010186d:	68 44 67 10 f0       	push   $0xf0106744
f0101872:	6a 58                	push   $0x58
f0101874:	68 1d 76 10 f0       	push   $0xf010761d
f0101879:	e8 c2 e7 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f010187e:	83 ec 04             	sub    $0x4,%esp
f0101881:	68 00 10 00 00       	push   $0x1000
f0101886:	6a 01                	push   $0x1
f0101888:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010188d:	50                   	push   %eax
f010188e:	e8 ce 41 00 00       	call   f0105a61 <memset>
	page_free(pp0);
f0101893:	89 34 24             	mov    %esi,(%esp)
f0101896:	e8 76 f7 ff ff       	call   f0101011 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010189b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01018a2:	e8 fa f6 ff ff       	call   f0100fa1 <page_alloc>
f01018a7:	83 c4 10             	add    $0x10,%esp
f01018aa:	85 c0                	test   %eax,%eax
f01018ac:	75 19                	jne    f01018c7 <mem_init+0x451>
f01018ae:	68 f3 77 10 f0       	push   $0xf01077f3
f01018b3:	68 37 76 10 f0       	push   $0xf0107637
f01018b8:	68 63 03 00 00       	push   $0x363
f01018bd:	68 11 76 10 f0       	push   $0xf0107611
f01018c2:	e8 79 e7 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01018c7:	39 c6                	cmp    %eax,%esi
f01018c9:	74 19                	je     f01018e4 <mem_init+0x46e>
f01018cb:	68 11 78 10 f0       	push   $0xf0107811
f01018d0:	68 37 76 10 f0       	push   $0xf0107637
f01018d5:	68 64 03 00 00       	push   $0x364
f01018da:	68 11 76 10 f0       	push   $0xf0107611
f01018df:	e8 5c e7 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018e4:	89 f0                	mov    %esi,%eax
f01018e6:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f01018ec:	c1 f8 03             	sar    $0x3,%eax
f01018ef:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01018f2:	89 c2                	mov    %eax,%edx
f01018f4:	c1 ea 0c             	shr    $0xc,%edx
f01018f7:	3b 15 88 2e 21 f0    	cmp    0xf0212e88,%edx
f01018fd:	72 12                	jb     f0101911 <mem_init+0x49b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018ff:	50                   	push   %eax
f0101900:	68 44 67 10 f0       	push   $0xf0106744
f0101905:	6a 58                	push   $0x58
f0101907:	68 1d 76 10 f0       	push   $0xf010761d
f010190c:	e8 2f e7 ff ff       	call   f0100040 <_panic>
f0101911:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101917:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f010191d:	80 38 00             	cmpb   $0x0,(%eax)
f0101920:	74 19                	je     f010193b <mem_init+0x4c5>
f0101922:	68 21 78 10 f0       	push   $0xf0107821
f0101927:	68 37 76 10 f0       	push   $0xf0107637
f010192c:	68 67 03 00 00       	push   $0x367
f0101931:	68 11 76 10 f0       	push   $0xf0107611
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
f0101945:	a3 40 22 21 f0       	mov    %eax,0xf0212240

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
f0101966:	a1 40 22 21 f0       	mov    0xf0212240,%eax
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
f010197d:	68 2b 78 10 f0       	push   $0xf010782b
f0101982:	68 37 76 10 f0       	push   $0xf0107637
f0101987:	68 74 03 00 00       	push   $0x374
f010198c:	68 11 76 10 f0       	push   $0xf0107611
f0101991:	e8 aa e6 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101996:	83 ec 0c             	sub    $0xc,%esp
f0101999:	68 54 6e 10 f0       	push   $0xf0106e54
f010199e:	e8 3c 20 00 00       	call   f01039df <cprintf>
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
f01019b9:	68 39 77 10 f0       	push   $0xf0107739
f01019be:	68 37 76 10 f0       	push   $0xf0107637
f01019c3:	68 da 03 00 00       	push   $0x3da
f01019c8:	68 11 76 10 f0       	push   $0xf0107611
f01019cd:	e8 6e e6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01019d2:	83 ec 0c             	sub    $0xc,%esp
f01019d5:	6a 00                	push   $0x0
f01019d7:	e8 c5 f5 ff ff       	call   f0100fa1 <page_alloc>
f01019dc:	89 c3                	mov    %eax,%ebx
f01019de:	83 c4 10             	add    $0x10,%esp
f01019e1:	85 c0                	test   %eax,%eax
f01019e3:	75 19                	jne    f01019fe <mem_init+0x588>
f01019e5:	68 4f 77 10 f0       	push   $0xf010774f
f01019ea:	68 37 76 10 f0       	push   $0xf0107637
f01019ef:	68 db 03 00 00       	push   $0x3db
f01019f4:	68 11 76 10 f0       	push   $0xf0107611
f01019f9:	e8 42 e6 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01019fe:	83 ec 0c             	sub    $0xc,%esp
f0101a01:	6a 00                	push   $0x0
f0101a03:	e8 99 f5 ff ff       	call   f0100fa1 <page_alloc>
f0101a08:	89 c6                	mov    %eax,%esi
f0101a0a:	83 c4 10             	add    $0x10,%esp
f0101a0d:	85 c0                	test   %eax,%eax
f0101a0f:	75 19                	jne    f0101a2a <mem_init+0x5b4>
f0101a11:	68 65 77 10 f0       	push   $0xf0107765
f0101a16:	68 37 76 10 f0       	push   $0xf0107637
f0101a1b:	68 dc 03 00 00       	push   $0x3dc
f0101a20:	68 11 76 10 f0       	push   $0xf0107611
f0101a25:	e8 16 e6 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a2a:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101a2d:	75 19                	jne    f0101a48 <mem_init+0x5d2>
f0101a2f:	68 7b 77 10 f0       	push   $0xf010777b
f0101a34:	68 37 76 10 f0       	push   $0xf0107637
f0101a39:	68 df 03 00 00       	push   $0x3df
f0101a3e:	68 11 76 10 f0       	push   $0xf0107611
f0101a43:	e8 f8 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a48:	39 c3                	cmp    %eax,%ebx
f0101a4a:	74 05                	je     f0101a51 <mem_init+0x5db>
f0101a4c:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101a4f:	75 19                	jne    f0101a6a <mem_init+0x5f4>
f0101a51:	68 34 6e 10 f0       	push   $0xf0106e34
f0101a56:	68 37 76 10 f0       	push   $0xf0107637
f0101a5b:	68 e0 03 00 00       	push   $0x3e0
f0101a60:	68 11 76 10 f0       	push   $0xf0107611
f0101a65:	e8 d6 e5 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101a6a:	a1 40 22 21 f0       	mov    0xf0212240,%eax
f0101a6f:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101a72:	c7 05 40 22 21 f0 00 	movl   $0x0,0xf0212240
f0101a79:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101a7c:	83 ec 0c             	sub    $0xc,%esp
f0101a7f:	6a 00                	push   $0x0
f0101a81:	e8 1b f5 ff ff       	call   f0100fa1 <page_alloc>
f0101a86:	83 c4 10             	add    $0x10,%esp
f0101a89:	85 c0                	test   %eax,%eax
f0101a8b:	74 19                	je     f0101aa6 <mem_init+0x630>
f0101a8d:	68 e4 77 10 f0       	push   $0xf01077e4
f0101a92:	68 37 76 10 f0       	push   $0xf0107637
f0101a97:	68 e7 03 00 00       	push   $0x3e7
f0101a9c:	68 11 76 10 f0       	push   $0xf0107611
f0101aa1:	e8 9a e5 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101aa6:	83 ec 04             	sub    $0x4,%esp
f0101aa9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101aac:	50                   	push   %eax
f0101aad:	6a 00                	push   $0x0
f0101aaf:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0101ab5:	e8 6b f7 ff ff       	call   f0101225 <page_lookup>
f0101aba:	83 c4 10             	add    $0x10,%esp
f0101abd:	85 c0                	test   %eax,%eax
f0101abf:	74 19                	je     f0101ada <mem_init+0x664>
f0101ac1:	68 74 6e 10 f0       	push   $0xf0106e74
f0101ac6:	68 37 76 10 f0       	push   $0xf0107637
f0101acb:	68 ea 03 00 00       	push   $0x3ea
f0101ad0:	68 11 76 10 f0       	push   $0xf0107611
f0101ad5:	e8 66 e5 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101ada:	6a 02                	push   $0x2
f0101adc:	6a 00                	push   $0x0
f0101ade:	53                   	push   %ebx
f0101adf:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0101ae5:	e8 65 f8 ff ff       	call   f010134f <page_insert>
f0101aea:	83 c4 10             	add    $0x10,%esp
f0101aed:	85 c0                	test   %eax,%eax
f0101aef:	78 19                	js     f0101b0a <mem_init+0x694>
f0101af1:	68 ac 6e 10 f0       	push   $0xf0106eac
f0101af6:	68 37 76 10 f0       	push   $0xf0107637
f0101afb:	68 ed 03 00 00       	push   $0x3ed
f0101b00:	68 11 76 10 f0       	push   $0xf0107611
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
f0101b1a:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0101b20:	e8 2a f8 ff ff       	call   f010134f <page_insert>
f0101b25:	83 c4 20             	add    $0x20,%esp
f0101b28:	85 c0                	test   %eax,%eax
f0101b2a:	74 19                	je     f0101b45 <mem_init+0x6cf>
f0101b2c:	68 dc 6e 10 f0       	push   $0xf0106edc
f0101b31:	68 37 76 10 f0       	push   $0xf0107637
f0101b36:	68 f2 03 00 00       	push   $0x3f2
f0101b3b:	68 11 76 10 f0       	push   $0xf0107611
f0101b40:	e8 fb e4 ff ff       	call   f0100040 <_panic>
        assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b45:	8b 3d 8c 2e 21 f0    	mov    0xf0212e8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b4b:	a1 90 2e 21 f0       	mov    0xf0212e90,%eax
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
f0101b6c:	68 0c 6f 10 f0       	push   $0xf0106f0c
f0101b71:	68 37 76 10 f0       	push   $0xf0107637
f0101b76:	68 f3 03 00 00       	push   $0x3f3
f0101b7b:	68 11 76 10 f0       	push   $0xf0107611
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
f0101ba0:	68 34 6f 10 f0       	push   $0xf0106f34
f0101ba5:	68 37 76 10 f0       	push   $0xf0107637
f0101baa:	68 f4 03 00 00       	push   $0x3f4
f0101baf:	68 11 76 10 f0       	push   $0xf0107611
f0101bb4:	e8 87 e4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101bb9:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101bbe:	74 19                	je     f0101bd9 <mem_init+0x763>
f0101bc0:	68 36 78 10 f0       	push   $0xf0107836
f0101bc5:	68 37 76 10 f0       	push   $0xf0107637
f0101bca:	68 f5 03 00 00       	push   $0x3f5
f0101bcf:	68 11 76 10 f0       	push   $0xf0107611
f0101bd4:	e8 67 e4 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101bd9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101bdc:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101be1:	74 19                	je     f0101bfc <mem_init+0x786>
f0101be3:	68 47 78 10 f0       	push   $0xf0107847
f0101be8:	68 37 76 10 f0       	push   $0xf0107637
f0101bed:	68 f6 03 00 00       	push   $0x3f6
f0101bf2:	68 11 76 10 f0       	push   $0xf0107611
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
f0101c11:	68 64 6f 10 f0       	push   $0xf0106f64
f0101c16:	68 37 76 10 f0       	push   $0xf0107637
f0101c1b:	68 f9 03 00 00       	push   $0x3f9
f0101c20:	68 11 76 10 f0       	push   $0xf0107611
f0101c25:	e8 16 e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c2a:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c2f:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
f0101c34:	e8 8d ee ff ff       	call   f0100ac6 <check_va2pa>
f0101c39:	89 f2                	mov    %esi,%edx
f0101c3b:	2b 15 90 2e 21 f0    	sub    0xf0212e90,%edx
f0101c41:	c1 fa 03             	sar    $0x3,%edx
f0101c44:	c1 e2 0c             	shl    $0xc,%edx
f0101c47:	39 d0                	cmp    %edx,%eax
f0101c49:	74 19                	je     f0101c64 <mem_init+0x7ee>
f0101c4b:	68 a0 6f 10 f0       	push   $0xf0106fa0
f0101c50:	68 37 76 10 f0       	push   $0xf0107637
f0101c55:	68 fa 03 00 00       	push   $0x3fa
f0101c5a:	68 11 76 10 f0       	push   $0xf0107611
f0101c5f:	e8 dc e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101c64:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c69:	74 19                	je     f0101c84 <mem_init+0x80e>
f0101c6b:	68 58 78 10 f0       	push   $0xf0107858
f0101c70:	68 37 76 10 f0       	push   $0xf0107637
f0101c75:	68 fb 03 00 00       	push   $0x3fb
f0101c7a:	68 11 76 10 f0       	push   $0xf0107611
f0101c7f:	e8 bc e3 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101c84:	83 ec 0c             	sub    $0xc,%esp
f0101c87:	6a 00                	push   $0x0
f0101c89:	e8 13 f3 ff ff       	call   f0100fa1 <page_alloc>
f0101c8e:	83 c4 10             	add    $0x10,%esp
f0101c91:	85 c0                	test   %eax,%eax
f0101c93:	74 19                	je     f0101cae <mem_init+0x838>
f0101c95:	68 e4 77 10 f0       	push   $0xf01077e4
f0101c9a:	68 37 76 10 f0       	push   $0xf0107637
f0101c9f:	68 fe 03 00 00       	push   $0x3fe
f0101ca4:	68 11 76 10 f0       	push   $0xf0107611
f0101ca9:	e8 92 e3 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101cae:	6a 02                	push   $0x2
f0101cb0:	68 00 10 00 00       	push   $0x1000
f0101cb5:	56                   	push   %esi
f0101cb6:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0101cbc:	e8 8e f6 ff ff       	call   f010134f <page_insert>
f0101cc1:	83 c4 10             	add    $0x10,%esp
f0101cc4:	85 c0                	test   %eax,%eax
f0101cc6:	74 19                	je     f0101ce1 <mem_init+0x86b>
f0101cc8:	68 64 6f 10 f0       	push   $0xf0106f64
f0101ccd:	68 37 76 10 f0       	push   $0xf0107637
f0101cd2:	68 01 04 00 00       	push   $0x401
f0101cd7:	68 11 76 10 f0       	push   $0xf0107611
f0101cdc:	e8 5f e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ce1:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ce6:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
f0101ceb:	e8 d6 ed ff ff       	call   f0100ac6 <check_va2pa>
f0101cf0:	89 f2                	mov    %esi,%edx
f0101cf2:	2b 15 90 2e 21 f0    	sub    0xf0212e90,%edx
f0101cf8:	c1 fa 03             	sar    $0x3,%edx
f0101cfb:	c1 e2 0c             	shl    $0xc,%edx
f0101cfe:	39 d0                	cmp    %edx,%eax
f0101d00:	74 19                	je     f0101d1b <mem_init+0x8a5>
f0101d02:	68 a0 6f 10 f0       	push   $0xf0106fa0
f0101d07:	68 37 76 10 f0       	push   $0xf0107637
f0101d0c:	68 02 04 00 00       	push   $0x402
f0101d11:	68 11 76 10 f0       	push   $0xf0107611
f0101d16:	e8 25 e3 ff ff       	call   f0100040 <_panic>
        assert(pp2->pp_ref == 1);
f0101d1b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d20:	74 19                	je     f0101d3b <mem_init+0x8c5>
f0101d22:	68 58 78 10 f0       	push   $0xf0107858
f0101d27:	68 37 76 10 f0       	push   $0xf0107637
f0101d2c:	68 03 04 00 00       	push   $0x403
f0101d31:	68 11 76 10 f0       	push   $0xf0107611
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
f0101d4c:	68 e4 77 10 f0       	push   $0xf01077e4
f0101d51:	68 37 76 10 f0       	push   $0xf0107637
f0101d56:	68 07 04 00 00       	push   $0x407
f0101d5b:	68 11 76 10 f0       	push   $0xf0107611
f0101d60:	e8 db e2 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101d65:	8b 15 8c 2e 21 f0    	mov    0xf0212e8c,%edx
f0101d6b:	8b 02                	mov    (%edx),%eax
f0101d6d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101d72:	89 c1                	mov    %eax,%ecx
f0101d74:	c1 e9 0c             	shr    $0xc,%ecx
f0101d77:	3b 0d 88 2e 21 f0    	cmp    0xf0212e88,%ecx
f0101d7d:	72 15                	jb     f0101d94 <mem_init+0x91e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101d7f:	50                   	push   %eax
f0101d80:	68 44 67 10 f0       	push   $0xf0106744
f0101d85:	68 0a 04 00 00       	push   $0x40a
f0101d8a:	68 11 76 10 f0       	push   $0xf0107611
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
f0101db9:	68 d0 6f 10 f0       	push   $0xf0106fd0
f0101dbe:	68 37 76 10 f0       	push   $0xf0107637
f0101dc3:	68 0b 04 00 00       	push   $0x40b
f0101dc8:	68 11 76 10 f0       	push   $0xf0107611
f0101dcd:	e8 6e e2 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101dd2:	6a 06                	push   $0x6
f0101dd4:	68 00 10 00 00       	push   $0x1000
f0101dd9:	56                   	push   %esi
f0101dda:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0101de0:	e8 6a f5 ff ff       	call   f010134f <page_insert>
f0101de5:	83 c4 10             	add    $0x10,%esp
f0101de8:	85 c0                	test   %eax,%eax
f0101dea:	74 19                	je     f0101e05 <mem_init+0x98f>
f0101dec:	68 10 70 10 f0       	push   $0xf0107010
f0101df1:	68 37 76 10 f0       	push   $0xf0107637
f0101df6:	68 0e 04 00 00       	push   $0x40e
f0101dfb:	68 11 76 10 f0       	push   $0xf0107611
f0101e00:	e8 3b e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e05:	8b 3d 8c 2e 21 f0    	mov    0xf0212e8c,%edi
f0101e0b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e10:	89 f8                	mov    %edi,%eax
f0101e12:	e8 af ec ff ff       	call   f0100ac6 <check_va2pa>
f0101e17:	89 f2                	mov    %esi,%edx
f0101e19:	2b 15 90 2e 21 f0    	sub    0xf0212e90,%edx
f0101e1f:	c1 fa 03             	sar    $0x3,%edx
f0101e22:	c1 e2 0c             	shl    $0xc,%edx
f0101e25:	39 d0                	cmp    %edx,%eax
f0101e27:	74 19                	je     f0101e42 <mem_init+0x9cc>
f0101e29:	68 a0 6f 10 f0       	push   $0xf0106fa0
f0101e2e:	68 37 76 10 f0       	push   $0xf0107637
f0101e33:	68 0f 04 00 00       	push   $0x40f
f0101e38:	68 11 76 10 f0       	push   $0xf0107611
f0101e3d:	e8 fe e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101e42:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101e47:	74 19                	je     f0101e62 <mem_init+0x9ec>
f0101e49:	68 58 78 10 f0       	push   $0xf0107858
f0101e4e:	68 37 76 10 f0       	push   $0xf0107637
f0101e53:	68 10 04 00 00       	push   $0x410
f0101e58:	68 11 76 10 f0       	push   $0xf0107611
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
f0101e7a:	68 50 70 10 f0       	push   $0xf0107050
f0101e7f:	68 37 76 10 f0       	push   $0xf0107637
f0101e84:	68 11 04 00 00       	push   $0x411
f0101e89:	68 11 76 10 f0       	push   $0xf0107611
f0101e8e:	e8 ad e1 ff ff       	call   f0100040 <_panic>
        assert(kern_pgdir[0] & PTE_U);
f0101e93:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
f0101e98:	f6 00 04             	testb  $0x4,(%eax)
f0101e9b:	75 19                	jne    f0101eb6 <mem_init+0xa40>
f0101e9d:	68 69 78 10 f0       	push   $0xf0107869
f0101ea2:	68 37 76 10 f0       	push   $0xf0107637
f0101ea7:	68 12 04 00 00       	push   $0x412
f0101eac:	68 11 76 10 f0       	push   $0xf0107611
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
f0101ecb:	68 64 6f 10 f0       	push   $0xf0106f64
f0101ed0:	68 37 76 10 f0       	push   $0xf0107637
f0101ed5:	68 15 04 00 00       	push   $0x415
f0101eda:	68 11 76 10 f0       	push   $0xf0107611
f0101edf:	e8 5c e1 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101ee4:	83 ec 04             	sub    $0x4,%esp
f0101ee7:	6a 00                	push   $0x0
f0101ee9:	68 00 10 00 00       	push   $0x1000
f0101eee:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0101ef4:	e8 ae f1 ff ff       	call   f01010a7 <pgdir_walk>
f0101ef9:	83 c4 10             	add    $0x10,%esp
f0101efc:	f6 00 02             	testb  $0x2,(%eax)
f0101eff:	75 19                	jne    f0101f1a <mem_init+0xaa4>
f0101f01:	68 84 70 10 f0       	push   $0xf0107084
f0101f06:	68 37 76 10 f0       	push   $0xf0107637
f0101f0b:	68 16 04 00 00       	push   $0x416
f0101f10:	68 11 76 10 f0       	push   $0xf0107611
f0101f15:	e8 26 e1 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f1a:	83 ec 04             	sub    $0x4,%esp
f0101f1d:	6a 00                	push   $0x0
f0101f1f:	68 00 10 00 00       	push   $0x1000
f0101f24:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0101f2a:	e8 78 f1 ff ff       	call   f01010a7 <pgdir_walk>
f0101f2f:	83 c4 10             	add    $0x10,%esp
f0101f32:	f6 00 04             	testb  $0x4,(%eax)
f0101f35:	74 19                	je     f0101f50 <mem_init+0xada>
f0101f37:	68 b8 70 10 f0       	push   $0xf01070b8
f0101f3c:	68 37 76 10 f0       	push   $0xf0107637
f0101f41:	68 17 04 00 00       	push   $0x417
f0101f46:	68 11 76 10 f0       	push   $0xf0107611
f0101f4b:	e8 f0 e0 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101f50:	6a 02                	push   $0x2
f0101f52:	68 00 00 40 00       	push   $0x400000
f0101f57:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101f5a:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0101f60:	e8 ea f3 ff ff       	call   f010134f <page_insert>
f0101f65:	83 c4 10             	add    $0x10,%esp
f0101f68:	85 c0                	test   %eax,%eax
f0101f6a:	78 19                	js     f0101f85 <mem_init+0xb0f>
f0101f6c:	68 f0 70 10 f0       	push   $0xf01070f0
f0101f71:	68 37 76 10 f0       	push   $0xf0107637
f0101f76:	68 1a 04 00 00       	push   $0x41a
f0101f7b:	68 11 76 10 f0       	push   $0xf0107611
f0101f80:	e8 bb e0 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101f85:	6a 02                	push   $0x2
f0101f87:	68 00 10 00 00       	push   $0x1000
f0101f8c:	53                   	push   %ebx
f0101f8d:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0101f93:	e8 b7 f3 ff ff       	call   f010134f <page_insert>
f0101f98:	83 c4 10             	add    $0x10,%esp
f0101f9b:	85 c0                	test   %eax,%eax
f0101f9d:	74 19                	je     f0101fb8 <mem_init+0xb42>
f0101f9f:	68 28 71 10 f0       	push   $0xf0107128
f0101fa4:	68 37 76 10 f0       	push   $0xf0107637
f0101fa9:	68 1d 04 00 00       	push   $0x41d
f0101fae:	68 11 76 10 f0       	push   $0xf0107611
f0101fb3:	e8 88 e0 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101fb8:	83 ec 04             	sub    $0x4,%esp
f0101fbb:	6a 00                	push   $0x0
f0101fbd:	68 00 10 00 00       	push   $0x1000
f0101fc2:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0101fc8:	e8 da f0 ff ff       	call   f01010a7 <pgdir_walk>
f0101fcd:	83 c4 10             	add    $0x10,%esp
f0101fd0:	f6 00 04             	testb  $0x4,(%eax)
f0101fd3:	74 19                	je     f0101fee <mem_init+0xb78>
f0101fd5:	68 b8 70 10 f0       	push   $0xf01070b8
f0101fda:	68 37 76 10 f0       	push   $0xf0107637
f0101fdf:	68 1e 04 00 00       	push   $0x41e
f0101fe4:	68 11 76 10 f0       	push   $0xf0107611
f0101fe9:	e8 52 e0 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101fee:	8b 3d 8c 2e 21 f0    	mov    0xf0212e8c,%edi
f0101ff4:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ff9:	89 f8                	mov    %edi,%eax
f0101ffb:	e8 c6 ea ff ff       	call   f0100ac6 <check_va2pa>
f0102000:	89 c1                	mov    %eax,%ecx
f0102002:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102005:	89 d8                	mov    %ebx,%eax
f0102007:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f010200d:	c1 f8 03             	sar    $0x3,%eax
f0102010:	c1 e0 0c             	shl    $0xc,%eax
f0102013:	39 c1                	cmp    %eax,%ecx
f0102015:	74 19                	je     f0102030 <mem_init+0xbba>
f0102017:	68 64 71 10 f0       	push   $0xf0107164
f010201c:	68 37 76 10 f0       	push   $0xf0107637
f0102021:	68 21 04 00 00       	push   $0x421
f0102026:	68 11 76 10 f0       	push   $0xf0107611
f010202b:	e8 10 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102030:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102035:	89 f8                	mov    %edi,%eax
f0102037:	e8 8a ea ff ff       	call   f0100ac6 <check_va2pa>
f010203c:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f010203f:	74 19                	je     f010205a <mem_init+0xbe4>
f0102041:	68 90 71 10 f0       	push   $0xf0107190
f0102046:	68 37 76 10 f0       	push   $0xf0107637
f010204b:	68 22 04 00 00       	push   $0x422
f0102050:	68 11 76 10 f0       	push   $0xf0107611
f0102055:	e8 e6 df ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010205a:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f010205f:	74 19                	je     f010207a <mem_init+0xc04>
f0102061:	68 7f 78 10 f0       	push   $0xf010787f
f0102066:	68 37 76 10 f0       	push   $0xf0107637
f010206b:	68 24 04 00 00       	push   $0x424
f0102070:	68 11 76 10 f0       	push   $0xf0107611
f0102075:	e8 c6 df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010207a:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010207f:	74 19                	je     f010209a <mem_init+0xc24>
f0102081:	68 90 78 10 f0       	push   $0xf0107890
f0102086:	68 37 76 10 f0       	push   $0xf0107637
f010208b:	68 25 04 00 00       	push   $0x425
f0102090:	68 11 76 10 f0       	push   $0xf0107611
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
f01020af:	68 c0 71 10 f0       	push   $0xf01071c0
f01020b4:	68 37 76 10 f0       	push   $0xf0107637
f01020b9:	68 28 04 00 00       	push   $0x428
f01020be:	68 11 76 10 f0       	push   $0xf0107611
f01020c3:	e8 78 df ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01020c8:	83 ec 08             	sub    $0x8,%esp
f01020cb:	6a 00                	push   $0x0
f01020cd:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f01020d3:	e8 09 f2 ff ff       	call   f01012e1 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01020d8:	8b 3d 8c 2e 21 f0    	mov    0xf0212e8c,%edi
f01020de:	ba 00 00 00 00       	mov    $0x0,%edx
f01020e3:	89 f8                	mov    %edi,%eax
f01020e5:	e8 dc e9 ff ff       	call   f0100ac6 <check_va2pa>
f01020ea:	83 c4 10             	add    $0x10,%esp
f01020ed:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020f0:	74 19                	je     f010210b <mem_init+0xc95>
f01020f2:	68 e4 71 10 f0       	push   $0xf01071e4
f01020f7:	68 37 76 10 f0       	push   $0xf0107637
f01020fc:	68 2c 04 00 00       	push   $0x42c
f0102101:	68 11 76 10 f0       	push   $0xf0107611
f0102106:	e8 35 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010210b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102110:	89 f8                	mov    %edi,%eax
f0102112:	e8 af e9 ff ff       	call   f0100ac6 <check_va2pa>
f0102117:	89 da                	mov    %ebx,%edx
f0102119:	2b 15 90 2e 21 f0    	sub    0xf0212e90,%edx
f010211f:	c1 fa 03             	sar    $0x3,%edx
f0102122:	c1 e2 0c             	shl    $0xc,%edx
f0102125:	39 d0                	cmp    %edx,%eax
f0102127:	74 19                	je     f0102142 <mem_init+0xccc>
f0102129:	68 90 71 10 f0       	push   $0xf0107190
f010212e:	68 37 76 10 f0       	push   $0xf0107637
f0102133:	68 2d 04 00 00       	push   $0x42d
f0102138:	68 11 76 10 f0       	push   $0xf0107611
f010213d:	e8 fe de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102142:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102147:	74 19                	je     f0102162 <mem_init+0xcec>
f0102149:	68 36 78 10 f0       	push   $0xf0107836
f010214e:	68 37 76 10 f0       	push   $0xf0107637
f0102153:	68 2e 04 00 00       	push   $0x42e
f0102158:	68 11 76 10 f0       	push   $0xf0107611
f010215d:	e8 de de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102162:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102167:	74 19                	je     f0102182 <mem_init+0xd0c>
f0102169:	68 90 78 10 f0       	push   $0xf0107890
f010216e:	68 37 76 10 f0       	push   $0xf0107637
f0102173:	68 2f 04 00 00       	push   $0x42f
f0102178:	68 11 76 10 f0       	push   $0xf0107611
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
f0102197:	68 08 72 10 f0       	push   $0xf0107208
f010219c:	68 37 76 10 f0       	push   $0xf0107637
f01021a1:	68 32 04 00 00       	push   $0x432
f01021a6:	68 11 76 10 f0       	push   $0xf0107611
f01021ab:	e8 90 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01021b0:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01021b5:	75 19                	jne    f01021d0 <mem_init+0xd5a>
f01021b7:	68 a1 78 10 f0       	push   $0xf01078a1
f01021bc:	68 37 76 10 f0       	push   $0xf0107637
f01021c1:	68 33 04 00 00       	push   $0x433
f01021c6:	68 11 76 10 f0       	push   $0xf0107611
f01021cb:	e8 70 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f01021d0:	83 3b 00             	cmpl   $0x0,(%ebx)
f01021d3:	74 19                	je     f01021ee <mem_init+0xd78>
f01021d5:	68 ad 78 10 f0       	push   $0xf01078ad
f01021da:	68 37 76 10 f0       	push   $0xf0107637
f01021df:	68 34 04 00 00       	push   $0x434
f01021e4:	68 11 76 10 f0       	push   $0xf0107611
f01021e9:	e8 52 de ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01021ee:	83 ec 08             	sub    $0x8,%esp
f01021f1:	68 00 10 00 00       	push   $0x1000
f01021f6:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f01021fc:	e8 e0 f0 ff ff       	call   f01012e1 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102201:	8b 3d 8c 2e 21 f0    	mov    0xf0212e8c,%edi
f0102207:	ba 00 00 00 00       	mov    $0x0,%edx
f010220c:	89 f8                	mov    %edi,%eax
f010220e:	e8 b3 e8 ff ff       	call   f0100ac6 <check_va2pa>
f0102213:	83 c4 10             	add    $0x10,%esp
f0102216:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102219:	74 19                	je     f0102234 <mem_init+0xdbe>
f010221b:	68 e4 71 10 f0       	push   $0xf01071e4
f0102220:	68 37 76 10 f0       	push   $0xf0107637
f0102225:	68 38 04 00 00       	push   $0x438
f010222a:	68 11 76 10 f0       	push   $0xf0107611
f010222f:	e8 0c de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102234:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102239:	89 f8                	mov    %edi,%eax
f010223b:	e8 86 e8 ff ff       	call   f0100ac6 <check_va2pa>
f0102240:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102243:	74 19                	je     f010225e <mem_init+0xde8>
f0102245:	68 40 72 10 f0       	push   $0xf0107240
f010224a:	68 37 76 10 f0       	push   $0xf0107637
f010224f:	68 39 04 00 00       	push   $0x439
f0102254:	68 11 76 10 f0       	push   $0xf0107611
f0102259:	e8 e2 dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010225e:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102263:	74 19                	je     f010227e <mem_init+0xe08>
f0102265:	68 c2 78 10 f0       	push   $0xf01078c2
f010226a:	68 37 76 10 f0       	push   $0xf0107637
f010226f:	68 3a 04 00 00       	push   $0x43a
f0102274:	68 11 76 10 f0       	push   $0xf0107611
f0102279:	e8 c2 dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010227e:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102283:	74 19                	je     f010229e <mem_init+0xe28>
f0102285:	68 90 78 10 f0       	push   $0xf0107890
f010228a:	68 37 76 10 f0       	push   $0xf0107637
f010228f:	68 3b 04 00 00       	push   $0x43b
f0102294:	68 11 76 10 f0       	push   $0xf0107611
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
f01022b3:	68 68 72 10 f0       	push   $0xf0107268
f01022b8:	68 37 76 10 f0       	push   $0xf0107637
f01022bd:	68 3e 04 00 00       	push   $0x43e
f01022c2:	68 11 76 10 f0       	push   $0xf0107611
f01022c7:	e8 74 dd ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01022cc:	83 ec 0c             	sub    $0xc,%esp
f01022cf:	6a 00                	push   $0x0
f01022d1:	e8 cb ec ff ff       	call   f0100fa1 <page_alloc>
f01022d6:	83 c4 10             	add    $0x10,%esp
f01022d9:	85 c0                	test   %eax,%eax
f01022db:	74 19                	je     f01022f6 <mem_init+0xe80>
f01022dd:	68 e4 77 10 f0       	push   $0xf01077e4
f01022e2:	68 37 76 10 f0       	push   $0xf0107637
f01022e7:	68 41 04 00 00       	push   $0x441
f01022ec:	68 11 76 10 f0       	push   $0xf0107611
f01022f1:	e8 4a dd ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01022f6:	8b 0d 8c 2e 21 f0    	mov    0xf0212e8c,%ecx
f01022fc:	8b 11                	mov    (%ecx),%edx
f01022fe:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102304:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102307:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f010230d:	c1 f8 03             	sar    $0x3,%eax
f0102310:	c1 e0 0c             	shl    $0xc,%eax
f0102313:	39 c2                	cmp    %eax,%edx
f0102315:	74 19                	je     f0102330 <mem_init+0xeba>
f0102317:	68 0c 6f 10 f0       	push   $0xf0106f0c
f010231c:	68 37 76 10 f0       	push   $0xf0107637
f0102321:	68 44 04 00 00       	push   $0x444
f0102326:	68 11 76 10 f0       	push   $0xf0107611
f010232b:	e8 10 dd ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102330:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102336:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102339:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010233e:	74 19                	je     f0102359 <mem_init+0xee3>
f0102340:	68 47 78 10 f0       	push   $0xf0107847
f0102345:	68 37 76 10 f0       	push   $0xf0107637
f010234a:	68 46 04 00 00       	push   $0x446
f010234f:	68 11 76 10 f0       	push   $0xf0107611
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
f0102375:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f010237b:	e8 27 ed ff ff       	call   f01010a7 <pgdir_walk>
f0102380:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102383:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102386:	8b 0d 8c 2e 21 f0    	mov    0xf0212e8c,%ecx
f010238c:	8b 51 04             	mov    0x4(%ecx),%edx
f010238f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102395:	8b 3d 88 2e 21 f0    	mov    0xf0212e88,%edi
f010239b:	89 d0                	mov    %edx,%eax
f010239d:	c1 e8 0c             	shr    $0xc,%eax
f01023a0:	83 c4 10             	add    $0x10,%esp
f01023a3:	39 f8                	cmp    %edi,%eax
f01023a5:	72 15                	jb     f01023bc <mem_init+0xf46>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023a7:	52                   	push   %edx
f01023a8:	68 44 67 10 f0       	push   $0xf0106744
f01023ad:	68 4d 04 00 00       	push   $0x44d
f01023b2:	68 11 76 10 f0       	push   $0xf0107611
f01023b7:	e8 84 dc ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01023bc:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01023c2:	39 55 c8             	cmp    %edx,-0x38(%ebp)
f01023c5:	74 19                	je     f01023e0 <mem_init+0xf6a>
f01023c7:	68 d3 78 10 f0       	push   $0xf01078d3
f01023cc:	68 37 76 10 f0       	push   $0xf0107637
f01023d1:	68 4e 04 00 00       	push   $0x44e
f01023d6:	68 11 76 10 f0       	push   $0xf0107611
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
f01023f0:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
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
f0102406:	68 44 67 10 f0       	push   $0xf0106744
f010240b:	6a 58                	push   $0x58
f010240d:	68 1d 76 10 f0       	push   $0xf010761d
f0102412:	e8 29 dc ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102417:	83 ec 04             	sub    $0x4,%esp
f010241a:	68 00 10 00 00       	push   $0x1000
f010241f:	68 ff 00 00 00       	push   $0xff
f0102424:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102429:	50                   	push   %eax
f010242a:	e8 32 36 00 00       	call   f0105a61 <memset>
	page_free(pp0);
f010242f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102432:	89 3c 24             	mov    %edi,(%esp)
f0102435:	e8 d7 eb ff ff       	call   f0101011 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010243a:	83 c4 0c             	add    $0xc,%esp
f010243d:	6a 01                	push   $0x1
f010243f:	6a 00                	push   $0x0
f0102441:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0102447:	e8 5b ec ff ff       	call   f01010a7 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010244c:	89 fa                	mov    %edi,%edx
f010244e:	2b 15 90 2e 21 f0    	sub    0xf0212e90,%edx
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
f0102462:	3b 05 88 2e 21 f0    	cmp    0xf0212e88,%eax
f0102468:	72 12                	jb     f010247c <mem_init+0x1006>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010246a:	52                   	push   %edx
f010246b:	68 44 67 10 f0       	push   $0xf0106744
f0102470:	6a 58                	push   $0x58
f0102472:	68 1d 76 10 f0       	push   $0xf010761d
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
f0102490:	68 eb 78 10 f0       	push   $0xf01078eb
f0102495:	68 37 76 10 f0       	push   $0xf0107637
f010249a:	68 58 04 00 00       	push   $0x458
f010249f:	68 11 76 10 f0       	push   $0xf0107611
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
f01024b0:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
f01024b5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01024bb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024be:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01024c4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01024c7:	89 0d 40 22 21 f0    	mov    %ecx,0xf0212240

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
f0102520:	68 8c 72 10 f0       	push   $0xf010728c
f0102525:	68 37 76 10 f0       	push   $0xf0107637
f010252a:	68 68 04 00 00       	push   $0x468
f010252f:	68 11 76 10 f0       	push   $0xf0107611
f0102534:	e8 07 db ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102539:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f010253f:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102545:	77 08                	ja     f010254f <mem_init+0x10d9>
f0102547:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010254d:	77 19                	ja     f0102568 <mem_init+0x10f2>
f010254f:	68 b4 72 10 f0       	push   $0xf01072b4
f0102554:	68 37 76 10 f0       	push   $0xf0107637
f0102559:	68 69 04 00 00       	push   $0x469
f010255e:	68 11 76 10 f0       	push   $0xf0107611
f0102563:	e8 d8 da ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102568:	89 da                	mov    %ebx,%edx
f010256a:	09 f2                	or     %esi,%edx
f010256c:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102572:	74 19                	je     f010258d <mem_init+0x1117>
f0102574:	68 dc 72 10 f0       	push   $0xf01072dc
f0102579:	68 37 76 10 f0       	push   $0xf0107637
f010257e:	68 6b 04 00 00       	push   $0x46b
f0102583:	68 11 76 10 f0       	push   $0xf0107611
f0102588:	e8 b3 da ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f010258d:	39 c6                	cmp    %eax,%esi
f010258f:	73 19                	jae    f01025aa <mem_init+0x1134>
f0102591:	68 02 79 10 f0       	push   $0xf0107902
f0102596:	68 37 76 10 f0       	push   $0xf0107637
f010259b:	68 6d 04 00 00       	push   $0x46d
f01025a0:	68 11 76 10 f0       	push   $0xf0107611
f01025a5:	e8 96 da ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01025aa:	8b 3d 8c 2e 21 f0    	mov    0xf0212e8c,%edi
f01025b0:	89 da                	mov    %ebx,%edx
f01025b2:	89 f8                	mov    %edi,%eax
f01025b4:	e8 0d e5 ff ff       	call   f0100ac6 <check_va2pa>
f01025b9:	85 c0                	test   %eax,%eax
f01025bb:	74 19                	je     f01025d6 <mem_init+0x1160>
f01025bd:	68 04 73 10 f0       	push   $0xf0107304
f01025c2:	68 37 76 10 f0       	push   $0xf0107637
f01025c7:	68 6f 04 00 00       	push   $0x46f
f01025cc:	68 11 76 10 f0       	push   $0xf0107611
f01025d1:	e8 6a da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01025d6:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f01025dc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01025df:	89 c2                	mov    %eax,%edx
f01025e1:	89 f8                	mov    %edi,%eax
f01025e3:	e8 de e4 ff ff       	call   f0100ac6 <check_va2pa>
f01025e8:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01025ed:	74 19                	je     f0102608 <mem_init+0x1192>
f01025ef:	68 28 73 10 f0       	push   $0xf0107328
f01025f4:	68 37 76 10 f0       	push   $0xf0107637
f01025f9:	68 70 04 00 00       	push   $0x470
f01025fe:	68 11 76 10 f0       	push   $0xf0107611
f0102603:	e8 38 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102608:	89 f2                	mov    %esi,%edx
f010260a:	89 f8                	mov    %edi,%eax
f010260c:	e8 b5 e4 ff ff       	call   f0100ac6 <check_va2pa>
f0102611:	85 c0                	test   %eax,%eax
f0102613:	74 19                	je     f010262e <mem_init+0x11b8>
f0102615:	68 58 73 10 f0       	push   $0xf0107358
f010261a:	68 37 76 10 f0       	push   $0xf0107637
f010261f:	68 71 04 00 00       	push   $0x471
f0102624:	68 11 76 10 f0       	push   $0xf0107611
f0102629:	e8 12 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f010262e:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102634:	89 f8                	mov    %edi,%eax
f0102636:	e8 8b e4 ff ff       	call   f0100ac6 <check_va2pa>
f010263b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010263e:	74 19                	je     f0102659 <mem_init+0x11e3>
f0102640:	68 7c 73 10 f0       	push   $0xf010737c
f0102645:	68 37 76 10 f0       	push   $0xf0107637
f010264a:	68 72 04 00 00       	push   $0x472
f010264f:	68 11 76 10 f0       	push   $0xf0107611
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
f010266d:	68 a8 73 10 f0       	push   $0xf01073a8
f0102672:	68 37 76 10 f0       	push   $0xf0107637
f0102677:	68 74 04 00 00       	push   $0x474
f010267c:	68 11 76 10 f0       	push   $0xf0107611
f0102681:	e8 ba d9 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102686:	83 ec 04             	sub    $0x4,%esp
f0102689:	6a 00                	push   $0x0
f010268b:	53                   	push   %ebx
f010268c:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0102692:	e8 10 ea ff ff       	call   f01010a7 <pgdir_walk>
f0102697:	8b 00                	mov    (%eax),%eax
f0102699:	83 c4 10             	add    $0x10,%esp
f010269c:	83 e0 04             	and    $0x4,%eax
f010269f:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01026a2:	74 19                	je     f01026bd <mem_init+0x1247>
f01026a4:	68 ec 73 10 f0       	push   $0xf01073ec
f01026a9:	68 37 76 10 f0       	push   $0xf0107637
f01026ae:	68 75 04 00 00       	push   $0x475
f01026b3:	68 11 76 10 f0       	push   $0xf0107611
f01026b8:	e8 83 d9 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f01026bd:	83 ec 04             	sub    $0x4,%esp
f01026c0:	6a 00                	push   $0x0
f01026c2:	53                   	push   %ebx
f01026c3:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f01026c9:	e8 d9 e9 ff ff       	call   f01010a7 <pgdir_walk>
f01026ce:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f01026d4:	83 c4 0c             	add    $0xc,%esp
f01026d7:	6a 00                	push   $0x0
f01026d9:	ff 75 d4             	pushl  -0x2c(%ebp)
f01026dc:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f01026e2:	e8 c0 e9 ff ff       	call   f01010a7 <pgdir_walk>
f01026e7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f01026ed:	83 c4 0c             	add    $0xc,%esp
f01026f0:	6a 00                	push   $0x0
f01026f2:	56                   	push   %esi
f01026f3:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f01026f9:	e8 a9 e9 ff ff       	call   f01010a7 <pgdir_walk>
f01026fe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102704:	c7 04 24 14 79 10 f0 	movl   $0xf0107914,(%esp)
f010270b:	e8 cf 12 00 00       	call   f01039df <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
        boot_map_region(kern_pgdir, UPAGES, ROUNDUP(pages_size, PGSIZE), PADDR(pages), PTE_U); 
f0102710:	a1 90 2e 21 f0       	mov    0xf0212e90,%eax
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
f0102720:	68 68 67 10 f0       	push   $0xf0106768
f0102725:	68 c1 00 00 00       	push   $0xc1
f010272a:	68 11 76 10 f0       	push   $0xf0107611
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
f0102755:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
f010275a:	e8 30 ea ff ff       	call   f010118f <boot_map_region>
        boot_map_region(kern_pgdir, (uintptr_t) pages, ROUNDUP(pages_size, PGSIZE), PADDR(pages), PTE_W);
f010275f:	8b 15 90 2e 21 f0    	mov    0xf0212e90,%edx
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
f0102771:	68 68 67 10 f0       	push   $0xf0106768
f0102776:	68 c2 00 00 00       	push   $0xc2
f010277b:	68 11 76 10 f0       	push   $0xf0107611
f0102780:	e8 bb d8 ff ff       	call   f0100040 <_panic>
f0102785:	83 ec 08             	sub    $0x8,%esp
f0102788:	6a 02                	push   $0x2
f010278a:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
f0102790:	50                   	push   %eax
f0102791:	89 d9                	mov    %ebx,%ecx
f0102793:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
f0102798:	e8 f2 e9 ff ff       	call   f010118f <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
        boot_map_region(kern_pgdir, UENVS, ROUNDUP(envs_size, PGSIZE), PADDR(envs), PTE_U);
f010279d:	a1 48 22 21 f0       	mov    0xf0212248,%eax
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
f01027ad:	68 68 67 10 f0       	push   $0xf0106768
f01027b2:	68 cb 00 00 00       	push   $0xcb
f01027b7:	68 11 76 10 f0       	push   $0xf0107611
f01027bc:	e8 7f d8 ff ff       	call   f0100040 <_panic>
f01027c1:	83 ec 08             	sub    $0x8,%esp
f01027c4:	6a 04                	push   $0x4
f01027c6:	05 00 00 00 10       	add    $0x10000000,%eax
f01027cb:	50                   	push   %eax
f01027cc:	b9 00 10 02 00       	mov    $0x21000,%ecx
f01027d1:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01027d6:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
f01027db:	e8 af e9 ff ff       	call   f010118f <boot_map_region>
        boot_map_region(kern_pgdir, (uintptr_t) envs, ROUNDUP(envs_size, PGSIZE), PADDR(pages), PTE_W);
f01027e0:	a1 90 2e 21 f0       	mov    0xf0212e90,%eax
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
f01027f0:	68 68 67 10 f0       	push   $0xf0106768
f01027f5:	68 cc 00 00 00       	push   $0xcc
f01027fa:	68 11 76 10 f0       	push   $0xf0107611
f01027ff:	e8 3c d8 ff ff       	call   f0100040 <_panic>
f0102804:	83 ec 08             	sub    $0x8,%esp
f0102807:	6a 02                	push   $0x2
f0102809:	05 00 00 00 10       	add    $0x10000000,%eax
f010280e:	50                   	push   %eax
f010280f:	b9 00 10 02 00       	mov    $0x21000,%ecx
f0102814:	8b 15 48 22 21 f0    	mov    0xf0212248,%edx
f010281a:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
f010281f:	e8 6b e9 ff ff       	call   f010118f <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102824:	83 c4 10             	add    $0x10,%esp
f0102827:	b8 00 70 11 f0       	mov    $0xf0117000,%eax
f010282c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102831:	77 15                	ja     f0102848 <mem_init+0x13d2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102833:	50                   	push   %eax
f0102834:	68 68 67 10 f0       	push   $0xf0106768
f0102839:	68 d9 00 00 00       	push   $0xd9
f010283e:	68 11 76 10 f0       	push   $0xf0107611
f0102843:	e8 f8 d7 ff ff       	call   f0100040 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
        boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102848:	83 ec 08             	sub    $0x8,%esp
f010284b:	6a 02                	push   $0x2
f010284d:	68 00 70 11 00       	push   $0x117000
f0102852:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102857:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010285c:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
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
f0102877:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
f010287c:	e8 0e e9 ff ff       	call   f010118f <boot_map_region>
f0102881:	c7 45 c4 00 40 21 f0 	movl   $0xf0214000,-0x3c(%ebp)
f0102888:	83 c4 10             	add    $0x10,%esp
f010288b:	bb 00 40 21 f0       	mov    $0xf0214000,%ebx
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
f010289e:	68 68 67 10 f0       	push   $0xf0106768
f01028a3:	68 1a 01 00 00       	push   $0x11a
f01028a8:	68 11 76 10 f0       	push   $0xf0107611
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
f01028c5:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
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
f01028de:	b8 00 40 25 f0       	mov    $0xf0254000,%eax
f01028e3:	39 d8                	cmp    %ebx,%eax
f01028e5:	75 ae                	jne    f0102895 <mem_init+0x141f>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01028e7:	8b 3d 8c 2e 21 f0    	mov    0xf0212e8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01028ed:	a1 88 2e 21 f0       	mov    0xf0212e88,%eax
f01028f2:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01028f5:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01028fc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102901:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102904:	8b 35 90 2e 21 f0    	mov    0xf0212e90,%esi
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
f010292b:	68 68 67 10 f0       	push   $0xf0106768
f0102930:	68 8c 03 00 00       	push   $0x38c
f0102935:	68 11 76 10 f0       	push   $0xf0107611
f010293a:	e8 01 d7 ff ff       	call   f0100040 <_panic>
f010293f:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f0102946:	39 c2                	cmp    %eax,%edx
f0102948:	74 19                	je     f0102963 <mem_init+0x14ed>
f010294a:	68 20 74 10 f0       	push   $0xf0107420
f010294f:	68 37 76 10 f0       	push   $0xf0107637
f0102954:	68 8c 03 00 00       	push   $0x38c
f0102959:	68 11 76 10 f0       	push   $0xf0107611
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
f010296e:	8b 35 48 22 21 f0    	mov    0xf0212248,%esi
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
f010298f:	68 68 67 10 f0       	push   $0xf0106768
f0102994:	68 91 03 00 00       	push   $0x391
f0102999:	68 11 76 10 f0       	push   $0xf0107611
f010299e:	e8 9d d6 ff ff       	call   f0100040 <_panic>
f01029a3:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f01029aa:	39 d0                	cmp    %edx,%eax
f01029ac:	74 19                	je     f01029c7 <mem_init+0x1551>
f01029ae:	68 54 74 10 f0       	push   $0xf0107454
f01029b3:	68 37 76 10 f0       	push   $0xf0107637
f01029b8:	68 91 03 00 00       	push   $0x391
f01029bd:	68 11 76 10 f0       	push   $0xf0107611
f01029c2:	e8 79 d6 ff ff       	call   f0100040 <_panic>
f01029c7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01029cd:	81 fb 00 10 c2 ee    	cmp    $0xeec21000,%ebx
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
f01029f3:	68 88 74 10 f0       	push   $0xf0107488
f01029f8:	68 37 76 10 f0       	push   $0xf0107637
f01029fd:	68 95 03 00 00       	push   $0x395
f0102a02:	68 11 76 10 f0       	push   $0xf0107611
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
f0102a4c:	68 68 67 10 f0       	push   $0xf0106768
f0102a51:	68 9d 03 00 00       	push   $0x39d
f0102a56:	68 11 76 10 f0       	push   $0xf0107611
f0102a5b:	e8 e0 d5 ff ff       	call   f0100040 <_panic>
f0102a60:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102a63:	8d 94 0b 00 40 21 f0 	lea    -0xfdec000(%ebx,%ecx,1),%edx
f0102a6a:	39 d0                	cmp    %edx,%eax
f0102a6c:	74 19                	je     f0102a87 <mem_init+0x1611>
f0102a6e:	68 b0 74 10 f0       	push   $0xf01074b0
f0102a73:	68 37 76 10 f0       	push   $0xf0107637
f0102a78:	68 9d 03 00 00       	push   $0x39d
f0102a7d:	68 11 76 10 f0       	push   $0xf0107611
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
f0102aae:	68 f8 74 10 f0       	push   $0xf01074f8
f0102ab3:	68 37 76 10 f0       	push   $0xf0107637
f0102ab8:	68 9f 03 00 00       	push   $0x39f
f0102abd:	68 11 76 10 f0       	push   $0xf0107611
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
f0102ae8:	b8 00 40 25 f0       	mov    $0xf0254000,%eax
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
f0102b0d:	68 2d 79 10 f0       	push   $0xf010792d
f0102b12:	68 37 76 10 f0       	push   $0xf0107637
f0102b17:	68 aa 03 00 00       	push   $0x3aa
f0102b1c:	68 11 76 10 f0       	push   $0xf0107611
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
f0102b35:	68 2d 79 10 f0       	push   $0xf010792d
f0102b3a:	68 37 76 10 f0       	push   $0xf0107637
f0102b3f:	68 ae 03 00 00       	push   $0x3ae
f0102b44:	68 11 76 10 f0       	push   $0xf0107611
f0102b49:	e8 f2 d4 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102b4e:	f6 c2 02             	test   $0x2,%dl
f0102b51:	75 38                	jne    f0102b8b <mem_init+0x1715>
f0102b53:	68 3e 79 10 f0       	push   $0xf010793e
f0102b58:	68 37 76 10 f0       	push   $0xf0107637
f0102b5d:	68 af 03 00 00       	push   $0x3af
f0102b62:	68 11 76 10 f0       	push   $0xf0107611
f0102b67:	e8 d4 d4 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102b6c:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102b70:	74 19                	je     f0102b8b <mem_init+0x1715>
f0102b72:	68 4f 79 10 f0       	push   $0xf010794f
f0102b77:	68 37 76 10 f0       	push   $0xf0107637
f0102b7c:	68 b1 03 00 00       	push   $0x3b1
f0102b81:	68 11 76 10 f0       	push   $0xf0107611
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
f0102b9c:	68 1c 75 10 f0       	push   $0xf010751c
f0102ba1:	e8 39 0e 00 00       	call   f01039df <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102ba6:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
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
f0102bb6:	68 68 67 10 f0       	push   $0xf0106768
f0102bbb:	68 f2 00 00 00       	push   $0xf2
f0102bc0:	68 11 76 10 f0       	push   $0xf0107611
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
f0102bfd:	68 39 77 10 f0       	push   $0xf0107739
f0102c02:	68 37 76 10 f0       	push   $0xf0107637
f0102c07:	68 8a 04 00 00       	push   $0x48a
f0102c0c:	68 11 76 10 f0       	push   $0xf0107611
f0102c11:	e8 2a d4 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102c16:	83 ec 0c             	sub    $0xc,%esp
f0102c19:	6a 00                	push   $0x0
f0102c1b:	e8 81 e3 ff ff       	call   f0100fa1 <page_alloc>
f0102c20:	89 c7                	mov    %eax,%edi
f0102c22:	83 c4 10             	add    $0x10,%esp
f0102c25:	85 c0                	test   %eax,%eax
f0102c27:	75 19                	jne    f0102c42 <mem_init+0x17cc>
f0102c29:	68 4f 77 10 f0       	push   $0xf010774f
f0102c2e:	68 37 76 10 f0       	push   $0xf0107637
f0102c33:	68 8b 04 00 00       	push   $0x48b
f0102c38:	68 11 76 10 f0       	push   $0xf0107611
f0102c3d:	e8 fe d3 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102c42:	83 ec 0c             	sub    $0xc,%esp
f0102c45:	6a 00                	push   $0x0
f0102c47:	e8 55 e3 ff ff       	call   f0100fa1 <page_alloc>
f0102c4c:	89 c6                	mov    %eax,%esi
f0102c4e:	83 c4 10             	add    $0x10,%esp
f0102c51:	85 c0                	test   %eax,%eax
f0102c53:	75 19                	jne    f0102c6e <mem_init+0x17f8>
f0102c55:	68 65 77 10 f0       	push   $0xf0107765
f0102c5a:	68 37 76 10 f0       	push   $0xf0107637
f0102c5f:	68 8c 04 00 00       	push   $0x48c
f0102c64:	68 11 76 10 f0       	push   $0xf0107611
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
f0102c79:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
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
f0102c8d:	3b 15 88 2e 21 f0    	cmp    0xf0212e88,%edx
f0102c93:	72 12                	jb     f0102ca7 <mem_init+0x1831>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c95:	50                   	push   %eax
f0102c96:	68 44 67 10 f0       	push   $0xf0106744
f0102c9b:	6a 58                	push   $0x58
f0102c9d:	68 1d 76 10 f0       	push   $0xf010761d
f0102ca2:	e8 99 d3 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102ca7:	83 ec 04             	sub    $0x4,%esp
f0102caa:	68 00 10 00 00       	push   $0x1000
f0102caf:	6a 01                	push   $0x1
f0102cb1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102cb6:	50                   	push   %eax
f0102cb7:	e8 a5 2d 00 00       	call   f0105a61 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102cbc:	89 f0                	mov    %esi,%eax
f0102cbe:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
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
f0102cd2:	3b 15 88 2e 21 f0    	cmp    0xf0212e88,%edx
f0102cd8:	72 12                	jb     f0102cec <mem_init+0x1876>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102cda:	50                   	push   %eax
f0102cdb:	68 44 67 10 f0       	push   $0xf0106744
f0102ce0:	6a 58                	push   $0x58
f0102ce2:	68 1d 76 10 f0       	push   $0xf010761d
f0102ce7:	e8 54 d3 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102cec:	83 ec 04             	sub    $0x4,%esp
f0102cef:	68 00 10 00 00       	push   $0x1000
f0102cf4:	6a 02                	push   $0x2
f0102cf6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102cfb:	50                   	push   %eax
f0102cfc:	e8 60 2d 00 00       	call   f0105a61 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102d01:	6a 02                	push   $0x2
f0102d03:	68 00 10 00 00       	push   $0x1000
f0102d08:	57                   	push   %edi
f0102d09:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0102d0f:	e8 3b e6 ff ff       	call   f010134f <page_insert>
	assert(pp1->pp_ref == 1);
f0102d14:	83 c4 20             	add    $0x20,%esp
f0102d17:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102d1c:	74 19                	je     f0102d37 <mem_init+0x18c1>
f0102d1e:	68 36 78 10 f0       	push   $0xf0107836
f0102d23:	68 37 76 10 f0       	push   $0xf0107637
f0102d28:	68 91 04 00 00       	push   $0x491
f0102d2d:	68 11 76 10 f0       	push   $0xf0107611
f0102d32:	e8 09 d3 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102d37:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102d3e:	01 01 01 
f0102d41:	74 19                	je     f0102d5c <mem_init+0x18e6>
f0102d43:	68 3c 75 10 f0       	push   $0xf010753c
f0102d48:	68 37 76 10 f0       	push   $0xf0107637
f0102d4d:	68 92 04 00 00       	push   $0x492
f0102d52:	68 11 76 10 f0       	push   $0xf0107611
f0102d57:	e8 e4 d2 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102d5c:	6a 02                	push   $0x2
f0102d5e:	68 00 10 00 00       	push   $0x1000
f0102d63:	56                   	push   %esi
f0102d64:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0102d6a:	e8 e0 e5 ff ff       	call   f010134f <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102d6f:	83 c4 10             	add    $0x10,%esp
f0102d72:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102d79:	02 02 02 
f0102d7c:	74 19                	je     f0102d97 <mem_init+0x1921>
f0102d7e:	68 60 75 10 f0       	push   $0xf0107560
f0102d83:	68 37 76 10 f0       	push   $0xf0107637
f0102d88:	68 94 04 00 00       	push   $0x494
f0102d8d:	68 11 76 10 f0       	push   $0xf0107611
f0102d92:	e8 a9 d2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102d97:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102d9c:	74 19                	je     f0102db7 <mem_init+0x1941>
f0102d9e:	68 58 78 10 f0       	push   $0xf0107858
f0102da3:	68 37 76 10 f0       	push   $0xf0107637
f0102da8:	68 95 04 00 00       	push   $0x495
f0102dad:	68 11 76 10 f0       	push   $0xf0107611
f0102db2:	e8 89 d2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102db7:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102dbc:	74 19                	je     f0102dd7 <mem_init+0x1961>
f0102dbe:	68 c2 78 10 f0       	push   $0xf01078c2
f0102dc3:	68 37 76 10 f0       	push   $0xf0107637
f0102dc8:	68 96 04 00 00       	push   $0x496
f0102dcd:	68 11 76 10 f0       	push   $0xf0107611
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
f0102de3:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f0102de9:	c1 f8 03             	sar    $0x3,%eax
f0102dec:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102def:	89 c2                	mov    %eax,%edx
f0102df1:	c1 ea 0c             	shr    $0xc,%edx
f0102df4:	3b 15 88 2e 21 f0    	cmp    0xf0212e88,%edx
f0102dfa:	72 12                	jb     f0102e0e <mem_init+0x1998>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102dfc:	50                   	push   %eax
f0102dfd:	68 44 67 10 f0       	push   $0xf0106744
f0102e02:	6a 58                	push   $0x58
f0102e04:	68 1d 76 10 f0       	push   $0xf010761d
f0102e09:	e8 32 d2 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e0e:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102e15:	03 03 03 
f0102e18:	74 19                	je     f0102e33 <mem_init+0x19bd>
f0102e1a:	68 84 75 10 f0       	push   $0xf0107584
f0102e1f:	68 37 76 10 f0       	push   $0xf0107637
f0102e24:	68 98 04 00 00       	push   $0x498
f0102e29:	68 11 76 10 f0       	push   $0xf0107611
f0102e2e:	e8 0d d2 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102e33:	83 ec 08             	sub    $0x8,%esp
f0102e36:	68 00 10 00 00       	push   $0x1000
f0102e3b:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0102e41:	e8 9b e4 ff ff       	call   f01012e1 <page_remove>
	assert(pp2->pp_ref == 0);
f0102e46:	83 c4 10             	add    $0x10,%esp
f0102e49:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102e4e:	74 19                	je     f0102e69 <mem_init+0x19f3>
f0102e50:	68 90 78 10 f0       	push   $0xf0107890
f0102e55:	68 37 76 10 f0       	push   $0xf0107637
f0102e5a:	68 9a 04 00 00       	push   $0x49a
f0102e5f:	68 11 76 10 f0       	push   $0xf0107611
f0102e64:	e8 d7 d1 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102e69:	8b 0d 8c 2e 21 f0    	mov    0xf0212e8c,%ecx
f0102e6f:	8b 11                	mov    (%ecx),%edx
f0102e71:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102e77:	89 d8                	mov    %ebx,%eax
f0102e79:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f0102e7f:	c1 f8 03             	sar    $0x3,%eax
f0102e82:	c1 e0 0c             	shl    $0xc,%eax
f0102e85:	39 c2                	cmp    %eax,%edx
f0102e87:	74 19                	je     f0102ea2 <mem_init+0x1a2c>
f0102e89:	68 0c 6f 10 f0       	push   $0xf0106f0c
f0102e8e:	68 37 76 10 f0       	push   $0xf0107637
f0102e93:	68 9d 04 00 00       	push   $0x49d
f0102e98:	68 11 76 10 f0       	push   $0xf0107611
f0102e9d:	e8 9e d1 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102ea2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102ea8:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102ead:	74 19                	je     f0102ec8 <mem_init+0x1a52>
f0102eaf:	68 47 78 10 f0       	push   $0xf0107847
f0102eb4:	68 37 76 10 f0       	push   $0xf0107637
f0102eb9:	68 9f 04 00 00       	push   $0x49f
f0102ebe:	68 11 76 10 f0       	push   $0xf0107611
f0102ec3:	e8 78 d1 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102ec8:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102ece:	83 ec 0c             	sub    $0xc,%esp
f0102ed1:	53                   	push   %ebx
f0102ed2:	e8 3a e1 ff ff       	call   f0101011 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102ed7:	c7 04 24 b0 75 10 f0 	movl   $0xf01075b0,(%esp)
f0102ede:	e8 fc 0a 00 00       	call   f01039df <cprintf>
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
f0102f2a:	ff 77 68             	pushl  0x68(%edi)
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
f0102f62:	89 1d 3c 22 21 f0    	mov    %ebx,0xf021223c
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
f0102f9c:	ff 35 3c 22 21 f0    	pushl  0xf021223c
f0102fa2:	ff 73 50             	pushl  0x50(%ebx)
f0102fa5:	68 dc 75 10 f0       	push   $0xf01075dc
f0102faa:	e8 30 0a 00 00       	call   f01039df <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102faf:	89 1c 24             	mov    %ebx,(%esp)
f0102fb2:	e8 38 06 00 00       	call   f01035ef <env_destroy>
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
f0102ff5:	68 60 79 10 f0       	push   $0xf0107960
f0102ffa:	68 34 01 00 00       	push   $0x134
f0102fff:	68 51 7a 10 f0       	push   $0xf0107a51
f0103004:	e8 37 d0 ff ff       	call   f0100040 <_panic>

                if (page_insert(e->env_pgdir, page, (void *) rva, PTE_P | PTE_U | PTE_W) < 0)
f0103009:	6a 07                	push   $0x7
f010300b:	53                   	push   %ebx
f010300c:	50                   	push   %eax
f010300d:	ff 77 68             	pushl  0x68(%edi)
f0103010:	e8 3a e3 ff ff       	call   f010134f <page_insert>
f0103015:	83 c4 10             	add    $0x10,%esp
f0103018:	85 c0                	test   %eax,%eax
f010301a:	79 17                	jns    f0103033 <region_alloc+0x74>
                        panic("region_alloc: page couldn't be inserted");
f010301c:	83 ec 04             	sub    $0x4,%esp
f010301f:	68 88 79 10 f0       	push   $0xf0107988
f0103024:	68 37 01 00 00       	push   $0x137
f0103029:	68 51 7a 10 f0       	push   $0xf0107a51
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
f010304d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103050:	85 c0                	test   %eax,%eax
f0103052:	75 1a                	jne    f010306e <envid2env+0x29>
		*env_store = curenv;
f0103054:	e8 29 30 00 00       	call   f0106082 <cpunum>
f0103059:	6b c0 74             	imul   $0x74,%eax,%eax
f010305c:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0103062:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103065:	89 06                	mov    %eax,(%esi)
		return 0;
f0103067:	b8 00 00 00 00       	mov    $0x0,%eax
f010306c:	eb 75                	jmp    f01030e3 <envid2env+0x9e>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010306e:	89 c2                	mov    %eax,%edx
f0103070:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0103076:	89 d3                	mov    %edx,%ebx
f0103078:	c1 e3 07             	shl    $0x7,%ebx
f010307b:	8d 1c 93             	lea    (%ebx,%edx,4),%ebx
f010307e:	03 1d 48 22 21 f0    	add    0xf0212248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103084:	83 7b 5c 00          	cmpl   $0x0,0x5c(%ebx)
f0103088:	74 05                	je     f010308f <envid2env+0x4a>
f010308a:	3b 43 50             	cmp    0x50(%ebx),%eax
f010308d:	74 10                	je     f010309f <envid2env+0x5a>
		*env_store = 0;
f010308f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103092:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103098:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010309d:	eb 44                	jmp    f01030e3 <envid2env+0x9e>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010309f:	84 c9                	test   %cl,%cl
f01030a1:	74 36                	je     f01030d9 <envid2env+0x94>
f01030a3:	e8 da 2f 00 00       	call   f0106082 <cpunum>
f01030a8:	6b c0 74             	imul   $0x74,%eax,%eax
f01030ab:	3b 98 28 30 21 f0    	cmp    -0xfdecfd8(%eax),%ebx
f01030b1:	74 26                	je     f01030d9 <envid2env+0x94>
f01030b3:	8b 73 54             	mov    0x54(%ebx),%esi
f01030b6:	e8 c7 2f 00 00       	call   f0106082 <cpunum>
f01030bb:	6b c0 74             	imul   $0x74,%eax,%eax
f01030be:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f01030c4:	3b 70 50             	cmp    0x50(%eax),%esi
f01030c7:	74 10                	je     f01030d9 <envid2env+0x94>
		*env_store = 0;
f01030c9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030cc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01030d2:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01030d7:	eb 0a                	jmp    f01030e3 <envid2env+0x9e>
	}

	*env_store = e;
f01030d9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030dc:	89 18                	mov    %ebx,(%eax)
	return 0;
f01030de:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01030e3:	5b                   	pop    %ebx
f01030e4:	5e                   	pop    %esi
f01030e5:	5d                   	pop    %ebp
f01030e6:	c3                   	ret    

f01030e7 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01030e7:	55                   	push   %ebp
f01030e8:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f01030ea:	b8 20 13 12 f0       	mov    $0xf0121320,%eax
f01030ef:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f01030f2:	b8 23 00 00 00       	mov    $0x23,%eax
f01030f7:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f01030f9:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f01030fb:	b8 10 00 00 00       	mov    $0x10,%eax
f0103100:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103102:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103104:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103106:	ea 0d 31 10 f0 08 00 	ljmp   $0x8,$0xf010310d
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f010310d:	b8 00 00 00 00       	mov    $0x0,%eax
f0103112:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103115:	5d                   	pop    %ebp
f0103116:	c3                   	ret    

f0103117 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103117:	55                   	push   %ebp
f0103118:	89 e5                	mov    %esp,%ebp
f010311a:	56                   	push   %esi
f010311b:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
        int i;
        for (i = NENV - 1; i >= 0; i--) {
                envs[i].env_status = ENV_FREE;
f010311c:	8b 35 48 22 21 f0    	mov    0xf0212248,%esi
f0103122:	8b 15 4c 22 21 f0    	mov    0xf021224c,%edx
f0103128:	8d 86 7c 0f 02 00    	lea    0x20f7c(%esi),%eax
f010312e:	8d 9e 7c ff ff ff    	lea    -0x84(%esi),%ebx
f0103134:	89 c1                	mov    %eax,%ecx
f0103136:	c7 40 5c 00 00 00 00 	movl   $0x0,0x5c(%eax)
                envs[i].env_id = 0;
f010313d:	c7 40 50 00 00 00 00 	movl   $0x0,0x50(%eax)
                envs[i].env_link = env_free_list;
f0103144:	89 50 4c             	mov    %edx,0x4c(%eax)
f0103147:	2d 84 00 00 00       	sub    $0x84,%eax
                env_free_list = &envs[i];
f010314c:	89 ca                	mov    %ecx,%edx
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
        int i;
        for (i = NENV - 1; i >= 0; i--) {
f010314e:	39 d8                	cmp    %ebx,%eax
f0103150:	75 e2                	jne    f0103134 <env_init+0x1d>
f0103152:	89 35 4c 22 21 f0    	mov    %esi,0xf021224c
                envs[i].env_link = env_free_list;
                env_free_list = &envs[i];
        }

	// Per-CPU part of the initialization
	env_init_percpu();
f0103158:	e8 8a ff ff ff       	call   f01030e7 <env_init_percpu>
}
f010315d:	5b                   	pop    %ebx
f010315e:	5e                   	pop    %esi
f010315f:	5d                   	pop    %ebp
f0103160:	c3                   	ret    

f0103161 <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103161:	55                   	push   %ebp
f0103162:	89 e5                	mov    %esp,%ebp
f0103164:	56                   	push   %esi
f0103165:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103166:	8b 1d 4c 22 21 f0    	mov    0xf021224c,%ebx
f010316c:	85 db                	test   %ebx,%ebx
f010316e:	0f 84 93 01 00 00    	je     f0103307 <env_alloc+0x1a6>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103174:	83 ec 0c             	sub    $0xc,%esp
f0103177:	6a 01                	push   $0x1
f0103179:	e8 23 de ff ff       	call   f0100fa1 <page_alloc>
f010317e:	83 c4 10             	add    $0x10,%esp
f0103181:	85 c0                	test   %eax,%eax
f0103183:	0f 84 85 01 00 00    	je     f010330e <env_alloc+0x1ad>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103189:	89 c2                	mov    %eax,%edx
f010318b:	2b 15 90 2e 21 f0    	sub    0xf0212e90,%edx
f0103191:	c1 fa 03             	sar    $0x3,%edx
f0103194:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103197:	89 d1                	mov    %edx,%ecx
f0103199:	c1 e9 0c             	shr    $0xc,%ecx
f010319c:	3b 0d 88 2e 21 f0    	cmp    0xf0212e88,%ecx
f01031a2:	72 12                	jb     f01031b6 <env_alloc+0x55>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01031a4:	52                   	push   %edx
f01031a5:	68 44 67 10 f0       	push   $0xf0106744
f01031aa:	6a 58                	push   $0x58
f01031ac:	68 1d 76 10 f0       	push   $0xf010761d
f01031b1:	e8 8a ce ff ff       	call   f0100040 <_panic>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
        e->env_pgdir = (pde_t *) page2kva(p);
f01031b6:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01031bc:	89 53 68             	mov    %edx,0x68(%ebx)
        p->pp_ref++;
f01031bf:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f01031c4:	b8 00 00 00 00       	mov    $0x0,%eax

        for (i = 0; i < PDX(UTOP); i++)
                e->env_pgdir[i] = 0;
f01031c9:	8b 53 68             	mov    0x68(%ebx),%edx
f01031cc:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
f01031d3:	83 c0 04             	add    $0x4,%eax

	// LAB 3: Your code here.
        e->env_pgdir = (pde_t *) page2kva(p);
        p->pp_ref++;

        for (i = 0; i < PDX(UTOP); i++)
f01031d6:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01031db:	75 ec                	jne    f01031c9 <env_alloc+0x68>
                e->env_pgdir[i] = 0;

        for (i = PDX(UTOP); i < NPDENTRIES; i++)
                e->env_pgdir[i] = kern_pgdir[i];
f01031dd:	8b 15 8c 2e 21 f0    	mov    0xf0212e8c,%edx
f01031e3:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f01031e6:	8b 53 68             	mov    0x68(%ebx),%edx
f01031e9:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f01031ec:	83 c0 04             	add    $0x4,%eax
        p->pp_ref++;

        for (i = 0; i < PDX(UTOP); i++)
                e->env_pgdir[i] = 0;

        for (i = PDX(UTOP); i < NPDENTRIES; i++)
f01031ef:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01031f4:	75 e7                	jne    f01031dd <env_alloc+0x7c>
                e->env_pgdir[i] = kern_pgdir[i];

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01031f6:	8b 43 68             	mov    0x68(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031f9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031fe:	77 15                	ja     f0103215 <env_alloc+0xb4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103200:	50                   	push   %eax
f0103201:	68 68 67 10 f0       	push   $0xf0106768
f0103206:	68 cb 00 00 00       	push   $0xcb
f010320b:	68 51 7a 10 f0       	push   $0xf0107a51
f0103210:	e8 2b ce ff ff       	call   f0100040 <_panic>
f0103215:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010321b:	83 ca 05             	or     $0x5,%edx
f010321e:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103224:	8b 43 50             	mov    0x50(%ebx),%eax
f0103227:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010322c:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103231:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103236:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103239:	89 da                	mov    %ebx,%edx
f010323b:	2b 15 48 22 21 f0    	sub    0xf0212248,%edx
f0103241:	c1 fa 02             	sar    $0x2,%edx
f0103244:	69 d2 e1 83 0f 3e    	imul   $0x3e0f83e1,%edx,%edx
f010324a:	09 d0                	or     %edx,%eax
f010324c:	89 43 50             	mov    %eax,0x50(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f010324f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103252:	89 43 54             	mov    %eax,0x54(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103255:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	e->env_status = ENV_RUNNABLE;
f010325c:	c7 43 5c 02 00 00 00 	movl   $0x2,0x5c(%ebx)
	e->env_runs = 0;
f0103263:	c7 43 60 00 00 00 00 	movl   $0x0,0x60(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010326a:	83 ec 04             	sub    $0x4,%esp
f010326d:	6a 44                	push   $0x44
f010326f:	6a 00                	push   $0x0
f0103271:	8d 43 08             	lea    0x8(%ebx),%eax
f0103274:	50                   	push   %eax
f0103275:	e8 e7 27 00 00       	call   f0105a61 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f010327a:	66 c7 43 2c 23 00    	movw   $0x23,0x2c(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103280:	66 c7 43 28 23 00    	movw   $0x23,0x28(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103286:	66 c7 43 48 23 00    	movw   $0x23,0x48(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010328c:	c7 43 44 00 e0 bf ee 	movl   $0xeebfe000,0x44(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103293:	66 c7 43 3c 1b 00    	movw   $0x1b,0x3c(%ebx)
	// You will set e->env_tf.tf_eip later.
	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
        e->env_tf.tf_eflags |= FL_IF;
f0103299:	81 4b 40 00 02 00 00 	orl    $0x200,0x40(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01032a0:	c7 43 6c 00 00 00 00 	movl   $0x0,0x6c(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01032a7:	c6 43 70 00          	movb   $0x0,0x70(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f01032ab:	8b 43 4c             	mov    0x4c(%ebx),%eax
f01032ae:	a3 4c 22 21 f0       	mov    %eax,0xf021224c
	*newenv_store = e;
f01032b3:	8b 45 08             	mov    0x8(%ebp),%eax
f01032b6:	89 18                	mov    %ebx,(%eax)

	// Lab 7 multithreading
	// nastavme proces id ako env id, ak sa alokuje thread, prestavi si process id sam
	// zoznam workerov nastavime ako prazdny
	e->env_process_id = e->env_id;
f01032b8:	8b 73 50             	mov    0x50(%ebx),%esi
f01032bb:	89 33                	mov    %esi,(%ebx)
	e->env_workers_link = NULL;
f01032bd:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01032c4:	e8 b9 2d 00 00       	call   f0106082 <cpunum>
f01032c9:	6b c0 74             	imul   $0x74,%eax,%eax
f01032cc:	83 c4 10             	add    $0x10,%esp
f01032cf:	ba 00 00 00 00       	mov    $0x0,%edx
f01032d4:	83 b8 28 30 21 f0 00 	cmpl   $0x0,-0xfdecfd8(%eax)
f01032db:	74 11                	je     f01032ee <env_alloc+0x18d>
f01032dd:	e8 a0 2d 00 00       	call   f0106082 <cpunum>
f01032e2:	6b c0 74             	imul   $0x74,%eax,%eax
f01032e5:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f01032eb:	8b 50 50             	mov    0x50(%eax),%edx
f01032ee:	83 ec 04             	sub    $0x4,%esp
f01032f1:	56                   	push   %esi
f01032f2:	52                   	push   %edx
f01032f3:	68 5c 7a 10 f0       	push   $0xf0107a5c
f01032f8:	e8 e2 06 00 00       	call   f01039df <cprintf>
	return 0;
f01032fd:	83 c4 10             	add    $0x10,%esp
f0103300:	b8 00 00 00 00       	mov    $0x0,%eax
f0103305:	eb 0c                	jmp    f0103313 <env_alloc+0x1b2>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103307:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010330c:	eb 05                	jmp    f0103313 <env_alloc+0x1b2>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f010330e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	// zoznam workerov nastavime ako prazdny
	e->env_process_id = e->env_id;
	e->env_workers_link = NULL;
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103313:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103316:	5b                   	pop    %ebx
f0103317:	5e                   	pop    %esi
f0103318:	5d                   	pop    %ebp
f0103319:	c3                   	ret    

f010331a <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f010331a:	55                   	push   %ebp
f010331b:	89 e5                	mov    %esp,%ebp
f010331d:	57                   	push   %edi
f010331e:	56                   	push   %esi
f010331f:	53                   	push   %ebx
f0103320:	83 ec 34             	sub    $0x34,%esp
f0103323:	8b 75 08             	mov    0x8(%ebp),%esi
f0103326:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// LAB 3: Your code here.
        struct Env *env;
        int status = env_alloc(&env, 0);
f0103329:	6a 00                	push   $0x0
f010332b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010332e:	50                   	push   %eax
f010332f:	e8 2d fe ff ff       	call   f0103161 <env_alloc>
        if (status < 0)
f0103334:	83 c4 10             	add    $0x10,%esp
f0103337:	85 c0                	test   %eax,%eax
f0103339:	79 15                	jns    f0103350 <env_create+0x36>
                panic("env_alloc: %e", status);
f010333b:	50                   	push   %eax
f010333c:	68 71 7a 10 f0       	push   $0xf0107a71
f0103341:	68 a1 01 00 00       	push   $0x1a1
f0103346:	68 51 7a 10 f0       	push   $0xf0107a51
f010334b:	e8 f0 cc ff ff       	call   f0100040 <_panic>

        // If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.        
        if (type == ENV_TYPE_FS) {
f0103350:	83 fb 01             	cmp    $0x1,%ebx
f0103353:	75 0a                	jne    f010335f <env_create+0x45>
                env->env_tf.tf_eflags |= FL_IOPL_3;
f0103355:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103358:	81 48 40 00 30 00 00 	orl    $0x3000,0x40(%eax)
        }

        env->env_type = type;
f010335f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103362:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103365:	89 58 58             	mov    %ebx,0x58(%eax)
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
        struct Elf *elf = (struct Elf *) binary;
        
        if (elf->e_magic != ELF_MAGIC)
f0103368:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f010336e:	74 17                	je     f0103387 <env_create+0x6d>
                panic("load_icode: binary isn't elf (invalid magic)");
f0103370:	83 ec 04             	sub    $0x4,%esp
f0103373:	68 b0 79 10 f0       	push   $0xf01079b0
f0103378:	68 76 01 00 00       	push   $0x176
f010337d:	68 51 7a 10 f0       	push   $0xf0107a51
f0103382:	e8 b9 cc ff ff       	call   f0100040 <_panic>
       
        // We could do a bunch more checks here (for e_phnum and such) but let's not.

        struct Proghdr *pht = (struct Proghdr *) (binary + elf->e_phoff); 
f0103387:	89 f7                	mov    %esi,%edi
f0103389:	03 7e 1c             	add    0x1c(%esi),%edi
     
        lcr3(PADDR(e->env_pgdir));
f010338c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010338f:	8b 40 68             	mov    0x68(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103392:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103397:	77 15                	ja     f01033ae <env_create+0x94>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103399:	50                   	push   %eax
f010339a:	68 68 67 10 f0       	push   $0xf0106768
f010339f:	68 7c 01 00 00       	push   $0x17c
f01033a4:	68 51 7a 10 f0       	push   $0xf0107a51
f01033a9:	e8 92 cc ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01033ae:	05 00 00 00 10       	add    $0x10000000,%eax
f01033b3:	0f 22 d8             	mov    %eax,%cr3

        struct Proghdr *phdr;
        for (phdr = pht; phdr < pht + elf->e_phnum; phdr++) {
f01033b6:	89 fb                	mov    %edi,%ebx
f01033b8:	eb 60                	jmp    f010341a <env_create+0x100>
                if (phdr->p_type != ELF_PROG_LOAD)
f01033ba:	83 3b 01             	cmpl   $0x1,(%ebx)
f01033bd:	75 58                	jne    f0103417 <env_create+0xfd>
                        continue;

                if (phdr->p_filesz > phdr->p_memsz)
f01033bf:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01033c2:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f01033c5:	76 17                	jbe    f01033de <env_create+0xc4>
                        panic("load_icode: segment filesz > memsz");
f01033c7:	83 ec 04             	sub    $0x4,%esp
f01033ca:	68 e0 79 10 f0       	push   $0xf01079e0
f01033cf:	68 84 01 00 00       	push   $0x184
f01033d4:	68 51 7a 10 f0       	push   $0xf0107a51
f01033d9:	e8 62 cc ff ff       	call   f0100040 <_panic>

                region_alloc(e, (void *) phdr->p_va, phdr->p_memsz);
f01033de:	8b 53 08             	mov    0x8(%ebx),%edx
f01033e1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01033e4:	e8 d6 fb ff ff       	call   f0102fbf <region_alloc>
                memcpy((void *) phdr->p_va, binary + phdr->p_offset, phdr->p_filesz); 
f01033e9:	83 ec 04             	sub    $0x4,%esp
f01033ec:	ff 73 10             	pushl  0x10(%ebx)
f01033ef:	89 f0                	mov    %esi,%eax
f01033f1:	03 43 04             	add    0x4(%ebx),%eax
f01033f4:	50                   	push   %eax
f01033f5:	ff 73 08             	pushl  0x8(%ebx)
f01033f8:	e8 19 27 00 00       	call   f0105b16 <memcpy>
                memset((void *) (phdr->p_va + phdr->p_filesz), 0, phdr->p_memsz - phdr->p_filesz);
f01033fd:	8b 43 10             	mov    0x10(%ebx),%eax
f0103400:	83 c4 0c             	add    $0xc,%esp
f0103403:	8b 53 14             	mov    0x14(%ebx),%edx
f0103406:	29 c2                	sub    %eax,%edx
f0103408:	52                   	push   %edx
f0103409:	6a 00                	push   $0x0
f010340b:	03 43 08             	add    0x8(%ebx),%eax
f010340e:	50                   	push   %eax
f010340f:	e8 4d 26 00 00       	call   f0105a61 <memset>
f0103414:	83 c4 10             	add    $0x10,%esp
        struct Proghdr *pht = (struct Proghdr *) (binary + elf->e_phoff); 
     
        lcr3(PADDR(e->env_pgdir));

        struct Proghdr *phdr;
        for (phdr = pht; phdr < pht + elf->e_phnum; phdr++) {
f0103417:	83 c3 20             	add    $0x20,%ebx
f010341a:	0f b7 46 2c          	movzwl 0x2c(%esi),%eax
f010341e:	c1 e0 05             	shl    $0x5,%eax
f0103421:	01 f8                	add    %edi,%eax
f0103423:	39 c3                	cmp    %eax,%ebx
f0103425:	72 93                	jb     f01033ba <env_create+0xa0>
                memset((void *) (phdr->p_va + phdr->p_filesz), 0, phdr->p_memsz - phdr->p_filesz);
        }

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
        region_alloc(e, (void *) (USTACKTOP - PGSIZE), PGSIZE);
f0103427:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010342c:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103431:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103434:	89 f8                	mov    %edi,%eax
f0103436:	e8 84 fb ff ff       	call   f0102fbf <region_alloc>

	// LAB 3: Your code here.
        e->env_tf.tf_eip = elf->e_entry;
f010343b:	8b 46 18             	mov    0x18(%esi),%eax
f010343e:	89 47 38             	mov    %eax,0x38(%edi)
                env->env_tf.tf_eflags |= FL_IOPL_3;
        }

        env->env_type = type;
        load_icode(env, binary);
}
f0103441:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103444:	5b                   	pop    %ebx
f0103445:	5e                   	pop    %esi
f0103446:	5f                   	pop    %edi
f0103447:	5d                   	pop    %ebp
f0103448:	c3                   	ret    

f0103449 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103449:	55                   	push   %ebp
f010344a:	89 e5                	mov    %esp,%ebp
f010344c:	57                   	push   %edi
f010344d:	56                   	push   %esi
f010344e:	53                   	push   %ebx
f010344f:	83 ec 1c             	sub    $0x1c,%esp
f0103452:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103455:	e8 28 2c 00 00       	call   f0106082 <cpunum>
f010345a:	6b c0 74             	imul   $0x74,%eax,%eax
f010345d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103464:	39 b8 28 30 21 f0    	cmp    %edi,-0xfdecfd8(%eax)
f010346a:	75 30                	jne    f010349c <env_free+0x53>
		lcr3(PADDR(kern_pgdir));
f010346c:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103471:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103476:	77 15                	ja     f010348d <env_free+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103478:	50                   	push   %eax
f0103479:	68 68 67 10 f0       	push   $0xf0106768
f010347e:	68 bb 01 00 00       	push   $0x1bb
f0103483:	68 51 7a 10 f0       	push   $0xf0107a51
f0103488:	e8 b3 cb ff ff       	call   f0100040 <_panic>
f010348d:	05 00 00 00 10       	add    $0x10000000,%eax
f0103492:	0f 22 d8             	mov    %eax,%cr3
f0103495:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010349c:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010349f:	89 d0                	mov    %edx,%eax
f01034a1:	c1 e0 02             	shl    $0x2,%eax
f01034a4:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01034a7:	8b 47 68             	mov    0x68(%edi),%eax
f01034aa:	8b 34 90             	mov    (%eax,%edx,4),%esi
f01034ad:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01034b3:	0f 84 a8 00 00 00    	je     f0103561 <env_free+0x118>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01034b9:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01034bf:	89 f0                	mov    %esi,%eax
f01034c1:	c1 e8 0c             	shr    $0xc,%eax
f01034c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01034c7:	39 05 88 2e 21 f0    	cmp    %eax,0xf0212e88
f01034cd:	77 15                	ja     f01034e4 <env_free+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01034cf:	56                   	push   %esi
f01034d0:	68 44 67 10 f0       	push   $0xf0106744
f01034d5:	68 ca 01 00 00       	push   $0x1ca
f01034da:	68 51 7a 10 f0       	push   $0xf0107a51
f01034df:	e8 5c cb ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01034e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034e7:	c1 e0 16             	shl    $0x16,%eax
f01034ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01034ed:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01034f2:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01034f9:	01 
f01034fa:	74 17                	je     f0103513 <env_free+0xca>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01034fc:	83 ec 08             	sub    $0x8,%esp
f01034ff:	89 d8                	mov    %ebx,%eax
f0103501:	c1 e0 0c             	shl    $0xc,%eax
f0103504:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103507:	50                   	push   %eax
f0103508:	ff 77 68             	pushl  0x68(%edi)
f010350b:	e8 d1 dd ff ff       	call   f01012e1 <page_remove>
f0103510:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103513:	83 c3 01             	add    $0x1,%ebx
f0103516:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f010351c:	75 d4                	jne    f01034f2 <env_free+0xa9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f010351e:	8b 47 68             	mov    0x68(%edi),%eax
f0103521:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103524:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010352b:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010352e:	3b 05 88 2e 21 f0    	cmp    0xf0212e88,%eax
f0103534:	72 14                	jb     f010354a <env_free+0x101>
		panic("pa2page called with invalid pa");
f0103536:	83 ec 04             	sub    $0x4,%esp
f0103539:	68 b0 6d 10 f0       	push   $0xf0106db0
f010353e:	6a 51                	push   $0x51
f0103540:	68 1d 76 10 f0       	push   $0xf010761d
f0103545:	e8 f6 ca ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f010354a:	83 ec 0c             	sub    $0xc,%esp
f010354d:	a1 90 2e 21 f0       	mov    0xf0212e90,%eax
f0103552:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103555:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103558:	50                   	push   %eax
f0103559:	e8 22 db ff ff       	call   f0101080 <page_decref>
f010355e:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103561:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103565:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103568:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f010356d:	0f 85 29 ff ff ff    	jne    f010349c <env_free+0x53>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103573:	8b 47 68             	mov    0x68(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103576:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010357b:	77 15                	ja     f0103592 <env_free+0x149>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010357d:	50                   	push   %eax
f010357e:	68 68 67 10 f0       	push   $0xf0106768
f0103583:	68 d8 01 00 00       	push   $0x1d8
f0103588:	68 51 7a 10 f0       	push   $0xf0107a51
f010358d:	e8 ae ca ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103592:	c7 47 68 00 00 00 00 	movl   $0x0,0x68(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103599:	05 00 00 00 10       	add    $0x10000000,%eax
f010359e:	c1 e8 0c             	shr    $0xc,%eax
f01035a1:	3b 05 88 2e 21 f0    	cmp    0xf0212e88,%eax
f01035a7:	72 14                	jb     f01035bd <env_free+0x174>
		panic("pa2page called with invalid pa");
f01035a9:	83 ec 04             	sub    $0x4,%esp
f01035ac:	68 b0 6d 10 f0       	push   $0xf0106db0
f01035b1:	6a 51                	push   $0x51
f01035b3:	68 1d 76 10 f0       	push   $0xf010761d
f01035b8:	e8 83 ca ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f01035bd:	83 ec 0c             	sub    $0xc,%esp
f01035c0:	8b 15 90 2e 21 f0    	mov    0xf0212e90,%edx
f01035c6:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01035c9:	50                   	push   %eax
f01035ca:	e8 b1 da ff ff       	call   f0101080 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01035cf:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	e->env_link = env_free_list;
f01035d6:	a1 4c 22 21 f0       	mov    0xf021224c,%eax
f01035db:	89 47 4c             	mov    %eax,0x4c(%edi)
	env_free_list = e;
f01035de:	89 3d 4c 22 21 f0    	mov    %edi,0xf021224c
}
f01035e4:	83 c4 10             	add    $0x10,%esp
f01035e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01035ea:	5b                   	pop    %ebx
f01035eb:	5e                   	pop    %esi
f01035ec:	5f                   	pop    %edi
f01035ed:	5d                   	pop    %ebp
f01035ee:	c3                   	ret    

f01035ef <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01035ef:	55                   	push   %ebp
f01035f0:	89 e5                	mov    %esp,%ebp
f01035f2:	53                   	push   %ebx
f01035f3:	83 ec 04             	sub    $0x4,%esp
f01035f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01035f9:	83 7b 5c 03          	cmpl   $0x3,0x5c(%ebx)
f01035fd:	75 19                	jne    f0103618 <env_destroy+0x29>
f01035ff:	e8 7e 2a 00 00       	call   f0106082 <cpunum>
f0103604:	6b c0 74             	imul   $0x74,%eax,%eax
f0103607:	3b 98 28 30 21 f0    	cmp    -0xfdecfd8(%eax),%ebx
f010360d:	74 09                	je     f0103618 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f010360f:	c7 43 5c 01 00 00 00 	movl   $0x1,0x5c(%ebx)
		return;
f0103616:	eb 59                	jmp    f0103671 <env_destroy+0x82>
	}
	cprintf("In env destroy, destroying env: %d\n", e->env_id); // for testing purposes
f0103618:	83 ec 08             	sub    $0x8,%esp
f010361b:	ff 73 50             	pushl  0x50(%ebx)
f010361e:	68 04 7a 10 f0       	push   $0xf0107a04
f0103623:	e8 b7 03 00 00       	call   f01039df <cprintf>
	// prejdi cez zoznam workerov main threadu a znic ich 
	struct Env *worker = e->env_workers_link;
f0103628:	8b 43 04             	mov    0x4(%ebx),%eax
	if(e->env_workers_link) {
f010362b:	83 c4 10             	add    $0x10,%esp
f010362e:	85 c0                	test   %eax,%eax
f0103630:	74 0c                	je     f010363e <env_destroy+0x4f>
		struct Env *to_free = worker;
		worker = worker->env_workers_link;
		env_free(to_free);
f0103632:	83 ec 0c             	sub    $0xc,%esp
f0103635:	50                   	push   %eax
f0103636:	e8 0e fe ff ff       	call   f0103449 <env_free>
f010363b:	83 c4 10             	add    $0x10,%esp
	}
	// znic main thread
	env_free(e);
f010363e:	83 ec 0c             	sub    $0xc,%esp
f0103641:	53                   	push   %ebx
f0103642:	e8 02 fe ff ff       	call   f0103449 <env_free>

	if (curenv == e) {
f0103647:	e8 36 2a 00 00       	call   f0106082 <cpunum>
f010364c:	6b c0 74             	imul   $0x74,%eax,%eax
f010364f:	83 c4 10             	add    $0x10,%esp
f0103652:	3b 98 28 30 21 f0    	cmp    -0xfdecfd8(%eax),%ebx
f0103658:	75 17                	jne    f0103671 <env_destroy+0x82>
		curenv = NULL;
f010365a:	e8 23 2a 00 00       	call   f0106082 <cpunum>
f010365f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103662:	c7 80 28 30 21 f0 00 	movl   $0x0,-0xfdecfd8(%eax)
f0103669:	00 00 00 
		sched_yield();
f010366c:	e8 d8 11 00 00       	call   f0104849 <sched_yield>
	}
}
f0103671:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103674:	c9                   	leave  
f0103675:	c3                   	ret    

f0103676 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103676:	55                   	push   %ebp
f0103677:	89 e5                	mov    %esp,%ebp
f0103679:	53                   	push   %ebx
f010367a:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f010367d:	e8 00 2a 00 00       	call   f0106082 <cpunum>
f0103682:	6b c0 74             	imul   $0x74,%eax,%eax
f0103685:	8b 98 28 30 21 f0    	mov    -0xfdecfd8(%eax),%ebx
f010368b:	e8 f2 29 00 00       	call   f0106082 <cpunum>
f0103690:	89 43 64             	mov    %eax,0x64(%ebx)

	asm volatile(
f0103693:	8b 65 08             	mov    0x8(%ebp),%esp
f0103696:	61                   	popa   
f0103697:	07                   	pop    %es
f0103698:	1f                   	pop    %ds
f0103699:	83 c4 08             	add    $0x8,%esp
f010369c:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f010369d:	83 ec 04             	sub    $0x4,%esp
f01036a0:	68 7f 7a 10 f0       	push   $0xf0107a7f
f01036a5:	68 17 02 00 00       	push   $0x217
f01036aa:	68 51 7a 10 f0       	push   $0xf0107a51
f01036af:	e8 8c c9 ff ff       	call   f0100040 <_panic>

f01036b4 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01036b4:	55                   	push   %ebp
f01036b5:	89 e5                	mov    %esp,%ebp
f01036b7:	53                   	push   %ebx
f01036b8:	83 ec 0c             	sub    $0xc,%esp
f01036bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
        //
        // First call to env_run
	cprintf("In env run, running env: %d\n", e->env_id);// can be commented - for testing purposes only
f01036be:	ff 73 50             	pushl  0x50(%ebx)
f01036c1:	68 8b 7a 10 f0       	push   $0xf0107a8b
f01036c6:	e8 14 03 00 00       	call   f01039df <cprintf>

        if ((curenv != NULL) && (curenv->env_status == ENV_RUNNING))
f01036cb:	e8 b2 29 00 00       	call   f0106082 <cpunum>
f01036d0:	6b c0 74             	imul   $0x74,%eax,%eax
f01036d3:	83 c4 10             	add    $0x10,%esp
f01036d6:	83 b8 28 30 21 f0 00 	cmpl   $0x0,-0xfdecfd8(%eax)
f01036dd:	74 29                	je     f0103708 <env_run+0x54>
f01036df:	e8 9e 29 00 00       	call   f0106082 <cpunum>
f01036e4:	6b c0 74             	imul   $0x74,%eax,%eax
f01036e7:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f01036ed:	83 78 5c 03          	cmpl   $0x3,0x5c(%eax)
f01036f1:	75 15                	jne    f0103708 <env_run+0x54>
                curenv->env_status = ENV_RUNNABLE;
f01036f3:	e8 8a 29 00 00       	call   f0106082 <cpunum>
f01036f8:	6b c0 74             	imul   $0x74,%eax,%eax
f01036fb:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0103701:	c7 40 5c 02 00 00 00 	movl   $0x2,0x5c(%eax)

        curenv = e;
f0103708:	e8 75 29 00 00       	call   f0106082 <cpunum>
f010370d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103710:	89 98 28 30 21 f0    	mov    %ebx,-0xfdecfd8(%eax)
        curenv->env_status = ENV_RUNNING;
f0103716:	e8 67 29 00 00       	call   f0106082 <cpunum>
f010371b:	6b c0 74             	imul   $0x74,%eax,%eax
f010371e:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0103724:	c7 40 5c 03 00 00 00 	movl   $0x3,0x5c(%eax)
        curenv->env_runs++;
f010372b:	e8 52 29 00 00       	call   f0106082 <cpunum>
f0103730:	6b c0 74             	imul   $0x74,%eax,%eax
f0103733:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0103739:	83 40 60 01          	addl   $0x1,0x60(%eax)

        lcr3(PADDR(curenv->env_pgdir));
f010373d:	e8 40 29 00 00       	call   f0106082 <cpunum>
f0103742:	6b c0 74             	imul   $0x74,%eax,%eax
f0103745:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f010374b:	8b 40 68             	mov    0x68(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010374e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103753:	77 15                	ja     f010376a <env_run+0xb6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103755:	50                   	push   %eax
f0103756:	68 68 67 10 f0       	push   $0xf0106768
f010375b:	68 40 02 00 00       	push   $0x240
f0103760:	68 51 7a 10 f0       	push   $0xf0107a51
f0103765:	e8 d6 c8 ff ff       	call   f0100040 <_panic>
f010376a:	05 00 00 00 10       	add    $0x10000000,%eax
f010376f:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103772:	83 ec 0c             	sub    $0xc,%esp
f0103775:	68 c0 13 12 f0       	push   $0xf01213c0
f010377a:	e8 0e 2c 00 00       	call   f010638d <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010377f:	f3 90                	pause  

        unlock_kernel();
        env_pop_tf(&curenv->env_tf);
f0103781:	e8 fc 28 00 00       	call   f0106082 <cpunum>
f0103786:	6b c0 74             	imul   $0x74,%eax,%eax
f0103789:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f010378f:	83 c0 08             	add    $0x8,%eax
f0103792:	89 04 24             	mov    %eax,(%esp)
f0103795:	e8 dc fe ff ff       	call   f0103676 <env_pop_tf>

f010379a <thread_create>:
}


envid_t thread_create(uintptr_t func)
{
f010379a:	55                   	push   %ebp
f010379b:	89 e5                	mov    %esp,%ebp
f010379d:	53                   	push   %ebx
f010379e:	83 ec 14             	sub    $0x14,%esp
	print_trapframe(&curenv->env_tf); // can be commented - for testing purposes only
f01037a1:	e8 dc 28 00 00       	call   f0106082 <cpunum>
f01037a6:	83 ec 0c             	sub    $0xc,%esp
f01037a9:	6b c0 74             	imul   $0x74,%eax,%eax
f01037ac:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f01037b2:	83 c0 08             	add    $0x8,%eax
f01037b5:	50                   	push   %eax
f01037b6:	e8 9b 09 00 00       	call   f0104156 <print_trapframe>
	alokujeme miesto pre zasobnik a nastavime esp aby ukazoval na vrchol,
	nastavime alokovany env (thread) ako runnable a nastavime jeho process id (env_id 
	main threadu), vratine env id
	*/
	struct Env *e;
	env_alloc(&e, 0);
f01037bb:	83 c4 08             	add    $0x8,%esp
f01037be:	6a 00                	push   $0x0
f01037c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01037c3:	50                   	push   %eax
f01037c4:	e8 98 f9 ff ff       	call   f0103161 <env_alloc>
	e->env_pgdir = curenv->env_pgdir;
f01037c9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01037cc:	e8 b1 28 00 00       	call   f0106082 <cpunum>
f01037d1:	6b c0 74             	imul   $0x74,%eax,%eax
f01037d4:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f01037da:	8b 40 68             	mov    0x68(%eax),%eax
f01037dd:	89 43 68             	mov    %eax,0x68(%ebx)
	e->env_tf.tf_eip = func;
f01037e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01037e3:	8b 55 08             	mov    0x8(%ebp),%edx
f01037e6:	89 50 38             	mov    %edx,0x38(%eax)
	
	region_alloc(e, (void *) (USTACKTOP - (4*PGSIZE)), PGSIZE);
f01037e9:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01037ee:	ba 00 a0 bf ee       	mov    $0xeebfa000,%edx
f01037f3:	e8 c7 f7 ff ff       	call   f0102fbf <region_alloc>
	e->env_tf.tf_esp = USTACKTOP - (3*PGSIZE);
f01037f8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01037fb:	c7 43 44 00 b0 bf ee 	movl   $0xeebfb000,0x44(%ebx)
	e->env_workers_link = curenv->env_workers_link;
f0103802:	e8 7b 28 00 00       	call   f0106082 <cpunum>
f0103807:	6b c0 74             	imul   $0x74,%eax,%eax
f010380a:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0103810:	8b 40 04             	mov    0x4(%eax),%eax
f0103813:	89 43 04             	mov    %eax,0x4(%ebx)
	curenv->env_workers_link = e;
f0103816:	e8 67 28 00 00       	call   f0106082 <cpunum>
f010381b:	6b c0 74             	imul   $0x74,%eax,%eax
f010381e:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0103824:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0103827:	89 58 04             	mov    %ebx,0x4(%eax)
	e->env_status = ENV_RUNNABLE;
f010382a:	c7 43 5c 02 00 00 00 	movl   $0x2,0x5c(%ebx)
	e->env_process_id = curenv->env_process_id; // resp. env_id ?
f0103831:	e8 4c 28 00 00       	call   f0106082 <cpunum>
f0103836:	6b c0 74             	imul   $0x74,%eax,%eax
f0103839:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f010383f:	8b 00                	mov    (%eax),%eax
f0103841:	89 03                	mov    %eax,(%ebx)
	cprintf("in thread create: thread process id: %d\n", e->env_process_id);
f0103843:	83 c4 08             	add    $0x8,%esp
f0103846:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103849:	ff 30                	pushl  (%eax)
f010384b:	68 28 7a 10 f0       	push   $0xf0107a28
f0103850:	e8 8a 01 00 00       	call   f01039df <cprintf>
	return e->env_id;
f0103855:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103858:	8b 40 50             	mov    0x50(%eax),%eax
}
f010385b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010385e:	c9                   	leave  
f010385f:	c3                   	ret    

f0103860 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103860:	55                   	push   %ebp
f0103861:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103863:	ba 70 00 00 00       	mov    $0x70,%edx
f0103868:	8b 45 08             	mov    0x8(%ebp),%eax
f010386b:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010386c:	ba 71 00 00 00       	mov    $0x71,%edx
f0103871:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103872:	0f b6 c0             	movzbl %al,%eax
}
f0103875:	5d                   	pop    %ebp
f0103876:	c3                   	ret    

f0103877 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103877:	55                   	push   %ebp
f0103878:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010387a:	ba 70 00 00 00       	mov    $0x70,%edx
f010387f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103882:	ee                   	out    %al,(%dx)
f0103883:	ba 71 00 00 00       	mov    $0x71,%edx
f0103888:	8b 45 0c             	mov    0xc(%ebp),%eax
f010388b:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010388c:	5d                   	pop    %ebp
f010388d:	c3                   	ret    

f010388e <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f010388e:	55                   	push   %ebp
f010388f:	89 e5                	mov    %esp,%ebp
f0103891:	56                   	push   %esi
f0103892:	53                   	push   %ebx
f0103893:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103896:	66 a3 a8 13 12 f0    	mov    %ax,0xf01213a8
	if (!didinit)
f010389c:	80 3d 50 22 21 f0 00 	cmpb   $0x0,0xf0212250
f01038a3:	74 5a                	je     f01038ff <irq_setmask_8259A+0x71>
f01038a5:	89 c6                	mov    %eax,%esi
f01038a7:	ba 21 00 00 00       	mov    $0x21,%edx
f01038ac:	ee                   	out    %al,(%dx)
f01038ad:	66 c1 e8 08          	shr    $0x8,%ax
f01038b1:	ba a1 00 00 00       	mov    $0xa1,%edx
f01038b6:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f01038b7:	83 ec 0c             	sub    $0xc,%esp
f01038ba:	68 a8 7a 10 f0       	push   $0xf0107aa8
f01038bf:	e8 1b 01 00 00       	call   f01039df <cprintf>
f01038c4:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f01038c7:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f01038cc:	0f b7 f6             	movzwl %si,%esi
f01038cf:	f7 d6                	not    %esi
f01038d1:	0f a3 de             	bt     %ebx,%esi
f01038d4:	73 11                	jae    f01038e7 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f01038d6:	83 ec 08             	sub    $0x8,%esp
f01038d9:	53                   	push   %ebx
f01038da:	68 b7 7f 10 f0       	push   $0xf0107fb7
f01038df:	e8 fb 00 00 00       	call   f01039df <cprintf>
f01038e4:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f01038e7:	83 c3 01             	add    $0x1,%ebx
f01038ea:	83 fb 10             	cmp    $0x10,%ebx
f01038ed:	75 e2                	jne    f01038d1 <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f01038ef:	83 ec 0c             	sub    $0xc,%esp
f01038f2:	68 fa 7e 10 f0       	push   $0xf0107efa
f01038f7:	e8 e3 00 00 00       	call   f01039df <cprintf>
f01038fc:	83 c4 10             	add    $0x10,%esp
}
f01038ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103902:	5b                   	pop    %ebx
f0103903:	5e                   	pop    %esi
f0103904:	5d                   	pop    %ebp
f0103905:	c3                   	ret    

f0103906 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0103906:	c6 05 50 22 21 f0 01 	movb   $0x1,0xf0212250
f010390d:	ba 21 00 00 00       	mov    $0x21,%edx
f0103912:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103917:	ee                   	out    %al,(%dx)
f0103918:	ba a1 00 00 00       	mov    $0xa1,%edx
f010391d:	ee                   	out    %al,(%dx)
f010391e:	ba 20 00 00 00       	mov    $0x20,%edx
f0103923:	b8 11 00 00 00       	mov    $0x11,%eax
f0103928:	ee                   	out    %al,(%dx)
f0103929:	ba 21 00 00 00       	mov    $0x21,%edx
f010392e:	b8 20 00 00 00       	mov    $0x20,%eax
f0103933:	ee                   	out    %al,(%dx)
f0103934:	b8 04 00 00 00       	mov    $0x4,%eax
f0103939:	ee                   	out    %al,(%dx)
f010393a:	b8 03 00 00 00       	mov    $0x3,%eax
f010393f:	ee                   	out    %al,(%dx)
f0103940:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103945:	b8 11 00 00 00       	mov    $0x11,%eax
f010394a:	ee                   	out    %al,(%dx)
f010394b:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103950:	b8 28 00 00 00       	mov    $0x28,%eax
f0103955:	ee                   	out    %al,(%dx)
f0103956:	b8 02 00 00 00       	mov    $0x2,%eax
f010395b:	ee                   	out    %al,(%dx)
f010395c:	b8 01 00 00 00       	mov    $0x1,%eax
f0103961:	ee                   	out    %al,(%dx)
f0103962:	ba 20 00 00 00       	mov    $0x20,%edx
f0103967:	b8 68 00 00 00       	mov    $0x68,%eax
f010396c:	ee                   	out    %al,(%dx)
f010396d:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103972:	ee                   	out    %al,(%dx)
f0103973:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103978:	b8 68 00 00 00       	mov    $0x68,%eax
f010397d:	ee                   	out    %al,(%dx)
f010397e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103983:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103984:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f010398b:	66 83 f8 ff          	cmp    $0xffff,%ax
f010398f:	74 13                	je     f01039a4 <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103991:	55                   	push   %ebp
f0103992:	89 e5                	mov    %esp,%ebp
f0103994:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103997:	0f b7 c0             	movzwl %ax,%eax
f010399a:	50                   	push   %eax
f010399b:	e8 ee fe ff ff       	call   f010388e <irq_setmask_8259A>
f01039a0:	83 c4 10             	add    $0x10,%esp
}
f01039a3:	c9                   	leave  
f01039a4:	f3 c3                	repz ret 

f01039a6 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01039a6:	55                   	push   %ebp
f01039a7:	89 e5                	mov    %esp,%ebp
f01039a9:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01039ac:	ff 75 08             	pushl  0x8(%ebp)
f01039af:	e8 e5 cd ff ff       	call   f0100799 <cputchar>
	*cnt++;
}
f01039b4:	83 c4 10             	add    $0x10,%esp
f01039b7:	c9                   	leave  
f01039b8:	c3                   	ret    

f01039b9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01039b9:	55                   	push   %ebp
f01039ba:	89 e5                	mov    %esp,%ebp
f01039bc:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01039bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01039c6:	ff 75 0c             	pushl  0xc(%ebp)
f01039c9:	ff 75 08             	pushl  0x8(%ebp)
f01039cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01039cf:	50                   	push   %eax
f01039d0:	68 a6 39 10 f0       	push   $0xf01039a6
f01039d5:	e8 03 1a 00 00       	call   f01053dd <vprintfmt>
	return cnt;
}
f01039da:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01039dd:	c9                   	leave  
f01039de:	c3                   	ret    

f01039df <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01039df:	55                   	push   %ebp
f01039e0:	89 e5                	mov    %esp,%ebp
f01039e2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01039e5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01039e8:	50                   	push   %eax
f01039e9:	ff 75 08             	pushl  0x8(%ebp)
f01039ec:	e8 c8 ff ff ff       	call   f01039b9 <vcprintf>
	va_end(ap);

	return cnt;
}
f01039f1:	c9                   	leave  
f01039f2:	c3                   	ret    

f01039f3 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01039f3:	55                   	push   %ebp
f01039f4:	89 e5                	mov    %esp,%ebp
f01039f6:	57                   	push   %edi
f01039f7:	56                   	push   %esi
f01039f8:	53                   	push   %ebx
f01039f9:	83 ec 1c             	sub    $0x1c,%esp
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:

	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - (thiscpu->cpu_id * (KSTKSIZE + KSTKGAP));
f01039fc:	e8 81 26 00 00       	call   f0106082 <cpunum>
f0103a01:	89 c3                	mov    %eax,%ebx
f0103a03:	e8 7a 26 00 00       	call   f0106082 <cpunum>
f0103a08:	6b d3 74             	imul   $0x74,%ebx,%edx
f0103a0b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a0e:	0f b6 88 20 30 21 f0 	movzbl -0xfdecfe0(%eax),%ecx
f0103a15:	c1 e1 10             	shl    $0x10,%ecx
f0103a18:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
f0103a1d:	29 c8                	sub    %ecx,%eax
f0103a1f:	89 82 30 30 21 f0    	mov    %eax,-0xfdecfd0(%edx)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103a25:	e8 58 26 00 00       	call   f0106082 <cpunum>
f0103a2a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a2d:	66 c7 80 34 30 21 f0 	movw   $0x10,-0xfdecfcc(%eax)
f0103a34:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f0103a36:	e8 47 26 00 00       	call   f0106082 <cpunum>
f0103a3b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a3e:	66 c7 80 92 30 21 f0 	movw   $0x68,-0xfdecf6e(%eax)
f0103a45:	68 00 

	uint32_t curr_cpu_gdt_index = GD_TSS0 + ((thiscpu->cpu_id + 1) * 8);
f0103a47:	e8 36 26 00 00       	call   f0106082 <cpunum>
f0103a4c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a4f:	0f b6 80 20 30 21 f0 	movzbl -0xfdecfe0(%eax),%eax
f0103a56:	8d 3c c5 30 00 00 00 	lea    0x30(,%eax,8),%edi

	gdt[curr_cpu_gdt_index >> 3] = SEG16
f0103a5d:	89 fb                	mov    %edi,%ebx
f0103a5f:	c1 eb 03             	shr    $0x3,%ebx
f0103a62:	e8 1b 26 00 00       	call   f0106082 <cpunum>
f0103a67:	89 c6                	mov    %eax,%esi
f0103a69:	e8 14 26 00 00       	call   f0106082 <cpunum>
f0103a6e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103a71:	e8 0c 26 00 00       	call   f0106082 <cpunum>
f0103a76:	66 c7 04 dd 40 13 12 	movw   $0x67,-0xfedecc0(,%ebx,8)
f0103a7d:	f0 67 00 
f0103a80:	6b f6 74             	imul   $0x74,%esi,%esi
f0103a83:	81 c6 2c 30 21 f0    	add    $0xf021302c,%esi
f0103a89:	66 89 34 dd 42 13 12 	mov    %si,-0xfedecbe(,%ebx,8)
f0103a90:	f0 
f0103a91:	6b 55 e4 74          	imul   $0x74,-0x1c(%ebp),%edx
f0103a95:	81 c2 2c 30 21 f0    	add    $0xf021302c,%edx
f0103a9b:	c1 ea 10             	shr    $0x10,%edx
f0103a9e:	88 14 dd 44 13 12 f0 	mov    %dl,-0xfedecbc(,%ebx,8)
f0103aa5:	c6 04 dd 46 13 12 f0 	movb   $0x40,-0xfedecba(,%ebx,8)
f0103aac:	40 
f0103aad:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ab0:	05 2c 30 21 f0       	add    $0xf021302c,%eax
f0103ab5:	c1 e8 18             	shr    $0x18,%eax
f0103ab8:	88 04 dd 47 13 12 f0 	mov    %al,-0xfedecb9(,%ebx,8)
	(STS_T32A, (uint32_t) (&thiscpu->cpu_ts), sizeof(struct Taskstate) - 1, 0);
	gdt[curr_cpu_gdt_index >> 3].sd_s = 0;
f0103abf:	c6 04 dd 45 13 12 f0 	movb   $0x89,-0xfedecbb(,%ebx,8)
f0103ac6:	89 
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0103ac7:	0f 00 df             	ltr    %di
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f0103aca:	b8 ac 13 12 f0       	mov    $0xf01213ac,%eax
f0103acf:	0f 01 18             	lidtl  (%eax)
	
	ltr(curr_cpu_gdt_index);

	// Load the IDT
	lidt(&idt_pd);
}
f0103ad2:	83 c4 1c             	add    $0x1c,%esp
f0103ad5:	5b                   	pop    %ebx
f0103ad6:	5e                   	pop    %esi
f0103ad7:	5f                   	pop    %edi
f0103ad8:	5d                   	pop    %ebp
f0103ad9:	c3                   	ret    

f0103ada <trap_init>:
}


void
trap_init(void)
{
f0103ada:	55                   	push   %ebp
f0103adb:	89 e5                	mov    %esp,%ebp
f0103add:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.

	extern void TH_DIVIDE(); 	SETGATE(idt[T_DIVIDE], 0, GD_KT, TH_DIVIDE, 							0); 
f0103ae0:	b8 5e 46 10 f0       	mov    $0xf010465e,%eax
f0103ae5:	66 a3 60 22 21 f0    	mov    %ax,0xf0212260
f0103aeb:	66 c7 05 62 22 21 f0 	movw   $0x8,0xf0212262
f0103af2:	08 00 
f0103af4:	c6 05 64 22 21 f0 00 	movb   $0x0,0xf0212264
f0103afb:	c6 05 65 22 21 f0 8e 	movb   $0x8e,0xf0212265
f0103b02:	c1 e8 10             	shr    $0x10,%eax
f0103b05:	66 a3 66 22 21 f0    	mov    %ax,0xf0212266
	extern void TH_DEBUG(); 	SETGATE(idt[T_DEBUG], 0, GD_KT, TH_DEBUG, 0); 
f0103b0b:	b8 68 46 10 f0       	mov    $0xf0104668,%eax
f0103b10:	66 a3 68 22 21 f0    	mov    %ax,0xf0212268
f0103b16:	66 c7 05 6a 22 21 f0 	movw   $0x8,0xf021226a
f0103b1d:	08 00 
f0103b1f:	c6 05 6c 22 21 f0 00 	movb   $0x0,0xf021226c
f0103b26:	c6 05 6d 22 21 f0 8e 	movb   $0x8e,0xf021226d
f0103b2d:	c1 e8 10             	shr    $0x10,%eax
f0103b30:	66 a3 6e 22 21 f0    	mov    %ax,0xf021226e
	extern void TH_NMI(); 		SETGATE(idt[T_NMI], 0, GD_KT, TH_NMI, 0); 
f0103b36:	b8 72 46 10 f0       	mov    $0xf0104672,%eax
f0103b3b:	66 a3 70 22 21 f0    	mov    %ax,0xf0212270
f0103b41:	66 c7 05 72 22 21 f0 	movw   $0x8,0xf0212272
f0103b48:	08 00 
f0103b4a:	c6 05 74 22 21 f0 00 	movb   $0x0,0xf0212274
f0103b51:	c6 05 75 22 21 f0 8e 	movb   $0x8e,0xf0212275
f0103b58:	c1 e8 10             	shr    $0x10,%eax
f0103b5b:	66 a3 76 22 21 f0    	mov    %ax,0xf0212276
	extern void TH_BRKPT(); 	SETGATE(idt[T_BRKPT], 0, GD_KT, TH_BRKPT, 3); 
f0103b61:	b8 7c 46 10 f0       	mov    $0xf010467c,%eax
f0103b66:	66 a3 78 22 21 f0    	mov    %ax,0xf0212278
f0103b6c:	66 c7 05 7a 22 21 f0 	movw   $0x8,0xf021227a
f0103b73:	08 00 
f0103b75:	c6 05 7c 22 21 f0 00 	movb   $0x0,0xf021227c
f0103b7c:	c6 05 7d 22 21 f0 ee 	movb   $0xee,0xf021227d
f0103b83:	c1 e8 10             	shr    $0x10,%eax
f0103b86:	66 a3 7e 22 21 f0    	mov    %ax,0xf021227e
	extern void TH_OFLOW(); 	SETGATE(idt[T_OFLOW], 0, GD_KT, TH_OFLOW, 0); 
f0103b8c:	b8 86 46 10 f0       	mov    $0xf0104686,%eax
f0103b91:	66 a3 80 22 21 f0    	mov    %ax,0xf0212280
f0103b97:	66 c7 05 82 22 21 f0 	movw   $0x8,0xf0212282
f0103b9e:	08 00 
f0103ba0:	c6 05 84 22 21 f0 00 	movb   $0x0,0xf0212284
f0103ba7:	c6 05 85 22 21 f0 8e 	movb   $0x8e,0xf0212285
f0103bae:	c1 e8 10             	shr    $0x10,%eax
f0103bb1:	66 a3 86 22 21 f0    	mov    %ax,0xf0212286
	extern void TH_BOUND(); 	SETGATE(idt[T_BOUND], 0, GD_KT, TH_BOUND, 0); 
f0103bb7:	b8 90 46 10 f0       	mov    $0xf0104690,%eax
f0103bbc:	66 a3 88 22 21 f0    	mov    %ax,0xf0212288
f0103bc2:	66 c7 05 8a 22 21 f0 	movw   $0x8,0xf021228a
f0103bc9:	08 00 
f0103bcb:	c6 05 8c 22 21 f0 00 	movb   $0x0,0xf021228c
f0103bd2:	c6 05 8d 22 21 f0 8e 	movb   $0x8e,0xf021228d
f0103bd9:	c1 e8 10             	shr    $0x10,%eax
f0103bdc:	66 a3 8e 22 21 f0    	mov    %ax,0xf021228e
	extern void TH_ILLOP(); 	SETGATE(idt[T_ILLOP], 0, GD_KT, TH_ILLOP, 0); 
f0103be2:	b8 9a 46 10 f0       	mov    $0xf010469a,%eax
f0103be7:	66 a3 90 22 21 f0    	mov    %ax,0xf0212290
f0103bed:	66 c7 05 92 22 21 f0 	movw   $0x8,0xf0212292
f0103bf4:	08 00 
f0103bf6:	c6 05 94 22 21 f0 00 	movb   $0x0,0xf0212294
f0103bfd:	c6 05 95 22 21 f0 8e 	movb   $0x8e,0xf0212295
f0103c04:	c1 e8 10             	shr    $0x10,%eax
f0103c07:	66 a3 96 22 21 f0    	mov    %ax,0xf0212296
	extern void TH_DEVICE(); 	SETGATE(idt[T_DEVICE], 0, GD_KT, TH_DEVICE, 							0); 
f0103c0d:	b8 a4 46 10 f0       	mov    $0xf01046a4,%eax
f0103c12:	66 a3 98 22 21 f0    	mov    %ax,0xf0212298
f0103c18:	66 c7 05 9a 22 21 f0 	movw   $0x8,0xf021229a
f0103c1f:	08 00 
f0103c21:	c6 05 9c 22 21 f0 00 	movb   $0x0,0xf021229c
f0103c28:	c6 05 9d 22 21 f0 8e 	movb   $0x8e,0xf021229d
f0103c2f:	c1 e8 10             	shr    $0x10,%eax
f0103c32:	66 a3 9e 22 21 f0    	mov    %ax,0xf021229e
	extern void TH_DBLFLT(); 	SETGATE(idt[T_DBLFLT], 0, GD_KT, TH_DBLFLT, 							0); 
f0103c38:	b8 ae 46 10 f0       	mov    $0xf01046ae,%eax
f0103c3d:	66 a3 a0 22 21 f0    	mov    %ax,0xf02122a0
f0103c43:	66 c7 05 a2 22 21 f0 	movw   $0x8,0xf02122a2
f0103c4a:	08 00 
f0103c4c:	c6 05 a4 22 21 f0 00 	movb   $0x0,0xf02122a4
f0103c53:	c6 05 a5 22 21 f0 8e 	movb   $0x8e,0xf02122a5
f0103c5a:	c1 e8 10             	shr    $0x10,%eax
f0103c5d:	66 a3 a6 22 21 f0    	mov    %ax,0xf02122a6
	extern void TH_TSS(); 		SETGATE(idt[T_TSS], 0, GD_KT, TH_TSS, 0); 
f0103c63:	b8 b6 46 10 f0       	mov    $0xf01046b6,%eax
f0103c68:	66 a3 b0 22 21 f0    	mov    %ax,0xf02122b0
f0103c6e:	66 c7 05 b2 22 21 f0 	movw   $0x8,0xf02122b2
f0103c75:	08 00 
f0103c77:	c6 05 b4 22 21 f0 00 	movb   $0x0,0xf02122b4
f0103c7e:	c6 05 b5 22 21 f0 8e 	movb   $0x8e,0xf02122b5
f0103c85:	c1 e8 10             	shr    $0x10,%eax
f0103c88:	66 a3 b6 22 21 f0    	mov    %ax,0xf02122b6
	extern void TH_SEGNP(); 	SETGATE(idt[T_SEGNP], 0, GD_KT, TH_SEGNP, 0); 
f0103c8e:	b8 be 46 10 f0       	mov    $0xf01046be,%eax
f0103c93:	66 a3 b8 22 21 f0    	mov    %ax,0xf02122b8
f0103c99:	66 c7 05 ba 22 21 f0 	movw   $0x8,0xf02122ba
f0103ca0:	08 00 
f0103ca2:	c6 05 bc 22 21 f0 00 	movb   $0x0,0xf02122bc
f0103ca9:	c6 05 bd 22 21 f0 8e 	movb   $0x8e,0xf02122bd
f0103cb0:	c1 e8 10             	shr    $0x10,%eax
f0103cb3:	66 a3 be 22 21 f0    	mov    %ax,0xf02122be
	extern void TH_STACK(); 	SETGATE(idt[T_STACK], 0, GD_KT, TH_STACK, 0); 
f0103cb9:	b8 c6 46 10 f0       	mov    $0xf01046c6,%eax
f0103cbe:	66 a3 c0 22 21 f0    	mov    %ax,0xf02122c0
f0103cc4:	66 c7 05 c2 22 21 f0 	movw   $0x8,0xf02122c2
f0103ccb:	08 00 
f0103ccd:	c6 05 c4 22 21 f0 00 	movb   $0x0,0xf02122c4
f0103cd4:	c6 05 c5 22 21 f0 8e 	movb   $0x8e,0xf02122c5
f0103cdb:	c1 e8 10             	shr    $0x10,%eax
f0103cde:	66 a3 c6 22 21 f0    	mov    %ax,0xf02122c6
	extern void TH_GPFLT(); 	SETGATE(idt[T_GPFLT], 0, GD_KT, TH_GPFLT, 0); 
f0103ce4:	b8 ce 46 10 f0       	mov    $0xf01046ce,%eax
f0103ce9:	66 a3 c8 22 21 f0    	mov    %ax,0xf02122c8
f0103cef:	66 c7 05 ca 22 21 f0 	movw   $0x8,0xf02122ca
f0103cf6:	08 00 
f0103cf8:	c6 05 cc 22 21 f0 00 	movb   $0x0,0xf02122cc
f0103cff:	c6 05 cd 22 21 f0 8e 	movb   $0x8e,0xf02122cd
f0103d06:	c1 e8 10             	shr    $0x10,%eax
f0103d09:	66 a3 ce 22 21 f0    	mov    %ax,0xf02122ce
	extern void TH_PGFLT(); 	SETGATE(idt[T_PGFLT], 0, GD_KT, TH_PGFLT, 0); 
f0103d0f:	b8 d6 46 10 f0       	mov    $0xf01046d6,%eax
f0103d14:	66 a3 d0 22 21 f0    	mov    %ax,0xf02122d0
f0103d1a:	66 c7 05 d2 22 21 f0 	movw   $0x8,0xf02122d2
f0103d21:	08 00 
f0103d23:	c6 05 d4 22 21 f0 00 	movb   $0x0,0xf02122d4
f0103d2a:	c6 05 d5 22 21 f0 8e 	movb   $0x8e,0xf02122d5
f0103d31:	c1 e8 10             	shr    $0x10,%eax
f0103d34:	66 a3 d6 22 21 f0    	mov    %ax,0xf02122d6
	extern void TH_FPERR(); 	SETGATE(idt[T_FPERR], 0, GD_KT, TH_FPERR, 0); 
f0103d3a:	b8 de 46 10 f0       	mov    $0xf01046de,%eax
f0103d3f:	66 a3 e0 22 21 f0    	mov    %ax,0xf02122e0
f0103d45:	66 c7 05 e2 22 21 f0 	movw   $0x8,0xf02122e2
f0103d4c:	08 00 
f0103d4e:	c6 05 e4 22 21 f0 00 	movb   $0x0,0xf02122e4
f0103d55:	c6 05 e5 22 21 f0 8e 	movb   $0x8e,0xf02122e5
f0103d5c:	c1 e8 10             	shr    $0x10,%eax
f0103d5f:	66 a3 e6 22 21 f0    	mov    %ax,0xf02122e6
	extern void TH_ALIGN(); 	SETGATE(idt[T_ALIGN], 0, GD_KT, TH_ALIGN, 0); 
f0103d65:	b8 e4 46 10 f0       	mov    $0xf01046e4,%eax
f0103d6a:	66 a3 e8 22 21 f0    	mov    %ax,0xf02122e8
f0103d70:	66 c7 05 ea 22 21 f0 	movw   $0x8,0xf02122ea
f0103d77:	08 00 
f0103d79:	c6 05 ec 22 21 f0 00 	movb   $0x0,0xf02122ec
f0103d80:	c6 05 ed 22 21 f0 8e 	movb   $0x8e,0xf02122ed
f0103d87:	c1 e8 10             	shr    $0x10,%eax
f0103d8a:	66 a3 ee 22 21 f0    	mov    %ax,0xf02122ee
	extern void TH_MCHK(); 		SETGATE(idt[T_MCHK], 0, GD_KT, TH_MCHK, 0); 
f0103d90:	b8 e8 46 10 f0       	mov    $0xf01046e8,%eax
f0103d95:	66 a3 f0 22 21 f0    	mov    %ax,0xf02122f0
f0103d9b:	66 c7 05 f2 22 21 f0 	movw   $0x8,0xf02122f2
f0103da2:	08 00 
f0103da4:	c6 05 f4 22 21 f0 00 	movb   $0x0,0xf02122f4
f0103dab:	c6 05 f5 22 21 f0 8e 	movb   $0x8e,0xf02122f5
f0103db2:	c1 e8 10             	shr    $0x10,%eax
f0103db5:	66 a3 f6 22 21 f0    	mov    %ax,0xf02122f6
	extern void TH_SIMDERR(); 	SETGATE(idt[T_SIMDERR], 0, GD_KT, TH_SIMDERR, 							0); 	// prepisat neskor ako interrupt 
f0103dbb:	b8 ee 46 10 f0       	mov    $0xf01046ee,%eax
f0103dc0:	66 a3 f8 22 21 f0    	mov    %ax,0xf02122f8
f0103dc6:	66 c7 05 fa 22 21 f0 	movw   $0x8,0xf02122fa
f0103dcd:	08 00 
f0103dcf:	c6 05 fc 22 21 f0 00 	movb   $0x0,0xf02122fc
f0103dd6:	c6 05 fd 22 21 f0 8e 	movb   $0x8e,0xf02122fd
f0103ddd:	c1 e8 10             	shr    $0x10,%eax
f0103de0:	66 a3 fe 22 21 f0    	mov    %ax,0xf02122fe
							// namiesto trapu (neskor)
	extern void TH_SYSCALL(); 	SETGATE(idt[T_SYSCALL], 0, GD_KT, TH_SYSCALL, 							3); 
f0103de6:	b8 f4 46 10 f0       	mov    $0xf01046f4,%eax
f0103deb:	66 a3 e0 23 21 f0    	mov    %ax,0xf02123e0
f0103df1:	66 c7 05 e2 23 21 f0 	movw   $0x8,0xf02123e2
f0103df8:	08 00 
f0103dfa:	c6 05 e4 23 21 f0 00 	movb   $0x0,0xf02123e4
f0103e01:	c6 05 e5 23 21 f0 ee 	movb   $0xee,0xf02123e5
f0103e08:	c1 e8 10             	shr    $0x10,%eax
f0103e0b:	66 a3 e6 23 21 f0    	mov    %ax,0xf02123e6

	extern void TH_IRQ_TIMER();	SETGATE(idt[IRQ_OFFSET + 0], 0, GD_KT, TH_IRQ_TIMER, 0);
f0103e11:	b8 fa 46 10 f0       	mov    $0xf01046fa,%eax
f0103e16:	66 a3 60 23 21 f0    	mov    %ax,0xf0212360
f0103e1c:	66 c7 05 62 23 21 f0 	movw   $0x8,0xf0212362
f0103e23:	08 00 
f0103e25:	c6 05 64 23 21 f0 00 	movb   $0x0,0xf0212364
f0103e2c:	c6 05 65 23 21 f0 8e 	movb   $0x8e,0xf0212365
f0103e33:	c1 e8 10             	shr    $0x10,%eax
f0103e36:	66 a3 66 23 21 f0    	mov    %ax,0xf0212366
	extern void TH_IRQ_KBD();	SETGATE(idt[IRQ_OFFSET + 1], 0, GD_KT, TH_IRQ_KBD, 0);
f0103e3c:	b8 00 47 10 f0       	mov    $0xf0104700,%eax
f0103e41:	66 a3 68 23 21 f0    	mov    %ax,0xf0212368
f0103e47:	66 c7 05 6a 23 21 f0 	movw   $0x8,0xf021236a
f0103e4e:	08 00 
f0103e50:	c6 05 6c 23 21 f0 00 	movb   $0x0,0xf021236c
f0103e57:	c6 05 6d 23 21 f0 8e 	movb   $0x8e,0xf021236d
f0103e5e:	c1 e8 10             	shr    $0x10,%eax
f0103e61:	66 a3 6e 23 21 f0    	mov    %ax,0xf021236e
	extern void TH_IRQ_2();		SETGATE(idt[IRQ_OFFSET + 2], 0, GD_KT, TH_IRQ_2, 0);
f0103e67:	b8 06 47 10 f0       	mov    $0xf0104706,%eax
f0103e6c:	66 a3 70 23 21 f0    	mov    %ax,0xf0212370
f0103e72:	66 c7 05 72 23 21 f0 	movw   $0x8,0xf0212372
f0103e79:	08 00 
f0103e7b:	c6 05 74 23 21 f0 00 	movb   $0x0,0xf0212374
f0103e82:	c6 05 75 23 21 f0 8e 	movb   $0x8e,0xf0212375
f0103e89:	c1 e8 10             	shr    $0x10,%eax
f0103e8c:	66 a3 76 23 21 f0    	mov    %ax,0xf0212376
	extern void TH_IRQ_3();		SETGATE(idt[IRQ_OFFSET + 3], 0, GD_KT, TH_IRQ_3, 0);
f0103e92:	b8 0c 47 10 f0       	mov    $0xf010470c,%eax
f0103e97:	66 a3 78 23 21 f0    	mov    %ax,0xf0212378
f0103e9d:	66 c7 05 7a 23 21 f0 	movw   $0x8,0xf021237a
f0103ea4:	08 00 
f0103ea6:	c6 05 7c 23 21 f0 00 	movb   $0x0,0xf021237c
f0103ead:	c6 05 7d 23 21 f0 8e 	movb   $0x8e,0xf021237d
f0103eb4:	c1 e8 10             	shr    $0x10,%eax
f0103eb7:	66 a3 7e 23 21 f0    	mov    %ax,0xf021237e
	extern void TH_IRQ_SERIAL();	SETGATE(idt[IRQ_OFFSET + 4], 0, GD_KT, TH_IRQ_SERIAL, 0);
f0103ebd:	b8 12 47 10 f0       	mov    $0xf0104712,%eax
f0103ec2:	66 a3 80 23 21 f0    	mov    %ax,0xf0212380
f0103ec8:	66 c7 05 82 23 21 f0 	movw   $0x8,0xf0212382
f0103ecf:	08 00 
f0103ed1:	c6 05 84 23 21 f0 00 	movb   $0x0,0xf0212384
f0103ed8:	c6 05 85 23 21 f0 8e 	movb   $0x8e,0xf0212385
f0103edf:	c1 e8 10             	shr    $0x10,%eax
f0103ee2:	66 a3 86 23 21 f0    	mov    %ax,0xf0212386
	extern void TH_IRQ_5();		SETGATE(idt[IRQ_OFFSET + 5], 0, GD_KT, TH_IRQ_5, 0);
f0103ee8:	b8 18 47 10 f0       	mov    $0xf0104718,%eax
f0103eed:	66 a3 88 23 21 f0    	mov    %ax,0xf0212388
f0103ef3:	66 c7 05 8a 23 21 f0 	movw   $0x8,0xf021238a
f0103efa:	08 00 
f0103efc:	c6 05 8c 23 21 f0 00 	movb   $0x0,0xf021238c
f0103f03:	c6 05 8d 23 21 f0 8e 	movb   $0x8e,0xf021238d
f0103f0a:	c1 e8 10             	shr    $0x10,%eax
f0103f0d:	66 a3 8e 23 21 f0    	mov    %ax,0xf021238e
	extern void TH_IRQ_6();		SETGATE(idt[IRQ_OFFSET + 6], 0, GD_KT, TH_IRQ_6, 0);
f0103f13:	b8 1e 47 10 f0       	mov    $0xf010471e,%eax
f0103f18:	66 a3 90 23 21 f0    	mov    %ax,0xf0212390
f0103f1e:	66 c7 05 92 23 21 f0 	movw   $0x8,0xf0212392
f0103f25:	08 00 
f0103f27:	c6 05 94 23 21 f0 00 	movb   $0x0,0xf0212394
f0103f2e:	c6 05 95 23 21 f0 8e 	movb   $0x8e,0xf0212395
f0103f35:	c1 e8 10             	shr    $0x10,%eax
f0103f38:	66 a3 96 23 21 f0    	mov    %ax,0xf0212396
	extern void TH_IRQ_SPURIOUS();	SETGATE(idt[IRQ_OFFSET + 7], 0, GD_KT, TH_IRQ_SPURIOUS, 0);
f0103f3e:	b8 24 47 10 f0       	mov    $0xf0104724,%eax
f0103f43:	66 a3 98 23 21 f0    	mov    %ax,0xf0212398
f0103f49:	66 c7 05 9a 23 21 f0 	movw   $0x8,0xf021239a
f0103f50:	08 00 
f0103f52:	c6 05 9c 23 21 f0 00 	movb   $0x0,0xf021239c
f0103f59:	c6 05 9d 23 21 f0 8e 	movb   $0x8e,0xf021239d
f0103f60:	c1 e8 10             	shr    $0x10,%eax
f0103f63:	66 a3 9e 23 21 f0    	mov    %ax,0xf021239e
	extern void TH_IRQ_8();		SETGATE(idt[IRQ_OFFSET + 8], 0, GD_KT, TH_IRQ_8, 0);
f0103f69:	b8 2a 47 10 f0       	mov    $0xf010472a,%eax
f0103f6e:	66 a3 a0 23 21 f0    	mov    %ax,0xf02123a0
f0103f74:	66 c7 05 a2 23 21 f0 	movw   $0x8,0xf02123a2
f0103f7b:	08 00 
f0103f7d:	c6 05 a4 23 21 f0 00 	movb   $0x0,0xf02123a4
f0103f84:	c6 05 a5 23 21 f0 8e 	movb   $0x8e,0xf02123a5
f0103f8b:	c1 e8 10             	shr    $0x10,%eax
f0103f8e:	66 a3 a6 23 21 f0    	mov    %ax,0xf02123a6
	extern void TH_IRQ_9();		SETGATE(idt[IRQ_OFFSET + 9], 0, GD_KT, TH_IRQ_9, 0);
f0103f94:	b8 30 47 10 f0       	mov    $0xf0104730,%eax
f0103f99:	66 a3 a8 23 21 f0    	mov    %ax,0xf02123a8
f0103f9f:	66 c7 05 aa 23 21 f0 	movw   $0x8,0xf02123aa
f0103fa6:	08 00 
f0103fa8:	c6 05 ac 23 21 f0 00 	movb   $0x0,0xf02123ac
f0103faf:	c6 05 ad 23 21 f0 8e 	movb   $0x8e,0xf02123ad
f0103fb6:	c1 e8 10             	shr    $0x10,%eax
f0103fb9:	66 a3 ae 23 21 f0    	mov    %ax,0xf02123ae
	extern void TH_IRQ_10();	SETGATE(idt[IRQ_OFFSET + 10], 0, GD_KT, TH_IRQ_10, 0);
f0103fbf:	b8 36 47 10 f0       	mov    $0xf0104736,%eax
f0103fc4:	66 a3 b0 23 21 f0    	mov    %ax,0xf02123b0
f0103fca:	66 c7 05 b2 23 21 f0 	movw   $0x8,0xf02123b2
f0103fd1:	08 00 
f0103fd3:	c6 05 b4 23 21 f0 00 	movb   $0x0,0xf02123b4
f0103fda:	c6 05 b5 23 21 f0 8e 	movb   $0x8e,0xf02123b5
f0103fe1:	c1 e8 10             	shr    $0x10,%eax
f0103fe4:	66 a3 b6 23 21 f0    	mov    %ax,0xf02123b6
	extern void TH_IRQ_11();	SETGATE(idt[IRQ_OFFSET + 11], 0, GD_KT, TH_IRQ_11, 0);
f0103fea:	b8 3c 47 10 f0       	mov    $0xf010473c,%eax
f0103fef:	66 a3 b8 23 21 f0    	mov    %ax,0xf02123b8
f0103ff5:	66 c7 05 ba 23 21 f0 	movw   $0x8,0xf02123ba
f0103ffc:	08 00 
f0103ffe:	c6 05 bc 23 21 f0 00 	movb   $0x0,0xf02123bc
f0104005:	c6 05 bd 23 21 f0 8e 	movb   $0x8e,0xf02123bd
f010400c:	c1 e8 10             	shr    $0x10,%eax
f010400f:	66 a3 be 23 21 f0    	mov    %ax,0xf02123be
	extern void TH_IRQ_12();	SETGATE(idt[IRQ_OFFSET + 12], 0, GD_KT, TH_IRQ_12, 0);
f0104015:	b8 42 47 10 f0       	mov    $0xf0104742,%eax
f010401a:	66 a3 c0 23 21 f0    	mov    %ax,0xf02123c0
f0104020:	66 c7 05 c2 23 21 f0 	movw   $0x8,0xf02123c2
f0104027:	08 00 
f0104029:	c6 05 c4 23 21 f0 00 	movb   $0x0,0xf02123c4
f0104030:	c6 05 c5 23 21 f0 8e 	movb   $0x8e,0xf02123c5
f0104037:	c1 e8 10             	shr    $0x10,%eax
f010403a:	66 a3 c6 23 21 f0    	mov    %ax,0xf02123c6
	extern void TH_IRQ_13();	SETGATE(idt[IRQ_OFFSET + 13], 0, GD_KT, TH_IRQ_13, 0);
f0104040:	b8 48 47 10 f0       	mov    $0xf0104748,%eax
f0104045:	66 a3 c8 23 21 f0    	mov    %ax,0xf02123c8
f010404b:	66 c7 05 ca 23 21 f0 	movw   $0x8,0xf02123ca
f0104052:	08 00 
f0104054:	c6 05 cc 23 21 f0 00 	movb   $0x0,0xf02123cc
f010405b:	c6 05 cd 23 21 f0 8e 	movb   $0x8e,0xf02123cd
f0104062:	c1 e8 10             	shr    $0x10,%eax
f0104065:	66 a3 ce 23 21 f0    	mov    %ax,0xf02123ce
	extern void TH_IRQ_IDE();	SETGATE(idt[IRQ_OFFSET + 14], 0, GD_KT, TH_IRQ_IDE, 0);
f010406b:	b8 4e 47 10 f0       	mov    $0xf010474e,%eax
f0104070:	66 a3 d0 23 21 f0    	mov    %ax,0xf02123d0
f0104076:	66 c7 05 d2 23 21 f0 	movw   $0x8,0xf02123d2
f010407d:	08 00 
f010407f:	c6 05 d4 23 21 f0 00 	movb   $0x0,0xf02123d4
f0104086:	c6 05 d5 23 21 f0 8e 	movb   $0x8e,0xf02123d5
f010408d:	c1 e8 10             	shr    $0x10,%eax
f0104090:	66 a3 d6 23 21 f0    	mov    %ax,0xf02123d6
	extern void TH_IRQ_15();	SETGATE(idt[IRQ_OFFSET + 15], 0, GD_KT, TH_IRQ_15, 0);
f0104096:	b8 54 47 10 f0       	mov    $0xf0104754,%eax
f010409b:	66 a3 d8 23 21 f0    	mov    %ax,0xf02123d8
f01040a1:	66 c7 05 da 23 21 f0 	movw   $0x8,0xf02123da
f01040a8:	08 00 
f01040aa:	c6 05 dc 23 21 f0 00 	movb   $0x0,0xf02123dc
f01040b1:	c6 05 dd 23 21 f0 8e 	movb   $0x8e,0xf02123dd
f01040b8:	c1 e8 10             	shr    $0x10,%eax
f01040bb:	66 a3 de 23 21 f0    	mov    %ax,0xf02123de

	// Per-CPU setup 
	trap_init_percpu();
f01040c1:	e8 2d f9 ff ff       	call   f01039f3 <trap_init_percpu>
}
f01040c6:	c9                   	leave  
f01040c7:	c3                   	ret    

f01040c8 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01040c8:	55                   	push   %ebp
f01040c9:	89 e5                	mov    %esp,%ebp
f01040cb:	53                   	push   %ebx
f01040cc:	83 ec 0c             	sub    $0xc,%esp
f01040cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01040d2:	ff 33                	pushl  (%ebx)
f01040d4:	68 bc 7a 10 f0       	push   $0xf0107abc
f01040d9:	e8 01 f9 ff ff       	call   f01039df <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01040de:	83 c4 08             	add    $0x8,%esp
f01040e1:	ff 73 04             	pushl  0x4(%ebx)
f01040e4:	68 cb 7a 10 f0       	push   $0xf0107acb
f01040e9:	e8 f1 f8 ff ff       	call   f01039df <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01040ee:	83 c4 08             	add    $0x8,%esp
f01040f1:	ff 73 08             	pushl  0x8(%ebx)
f01040f4:	68 da 7a 10 f0       	push   $0xf0107ada
f01040f9:	e8 e1 f8 ff ff       	call   f01039df <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01040fe:	83 c4 08             	add    $0x8,%esp
f0104101:	ff 73 0c             	pushl  0xc(%ebx)
f0104104:	68 e9 7a 10 f0       	push   $0xf0107ae9
f0104109:	e8 d1 f8 ff ff       	call   f01039df <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f010410e:	83 c4 08             	add    $0x8,%esp
f0104111:	ff 73 10             	pushl  0x10(%ebx)
f0104114:	68 f8 7a 10 f0       	push   $0xf0107af8
f0104119:	e8 c1 f8 ff ff       	call   f01039df <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f010411e:	83 c4 08             	add    $0x8,%esp
f0104121:	ff 73 14             	pushl  0x14(%ebx)
f0104124:	68 07 7b 10 f0       	push   $0xf0107b07
f0104129:	e8 b1 f8 ff ff       	call   f01039df <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010412e:	83 c4 08             	add    $0x8,%esp
f0104131:	ff 73 18             	pushl  0x18(%ebx)
f0104134:	68 16 7b 10 f0       	push   $0xf0107b16
f0104139:	e8 a1 f8 ff ff       	call   f01039df <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010413e:	83 c4 08             	add    $0x8,%esp
f0104141:	ff 73 1c             	pushl  0x1c(%ebx)
f0104144:	68 25 7b 10 f0       	push   $0xf0107b25
f0104149:	e8 91 f8 ff ff       	call   f01039df <cprintf>
}
f010414e:	83 c4 10             	add    $0x10,%esp
f0104151:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104154:	c9                   	leave  
f0104155:	c3                   	ret    

f0104156 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0104156:	55                   	push   %ebp
f0104157:	89 e5                	mov    %esp,%ebp
f0104159:	56                   	push   %esi
f010415a:	53                   	push   %ebx
f010415b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f010415e:	e8 1f 1f 00 00       	call   f0106082 <cpunum>
f0104163:	83 ec 04             	sub    $0x4,%esp
f0104166:	50                   	push   %eax
f0104167:	53                   	push   %ebx
f0104168:	68 89 7b 10 f0       	push   $0xf0107b89
f010416d:	e8 6d f8 ff ff       	call   f01039df <cprintf>
	print_regs(&tf->tf_regs);
f0104172:	89 1c 24             	mov    %ebx,(%esp)
f0104175:	e8 4e ff ff ff       	call   f01040c8 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f010417a:	83 c4 08             	add    $0x8,%esp
f010417d:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0104181:	50                   	push   %eax
f0104182:	68 a7 7b 10 f0       	push   $0xf0107ba7
f0104187:	e8 53 f8 ff ff       	call   f01039df <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010418c:	83 c4 08             	add    $0x8,%esp
f010418f:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0104193:	50                   	push   %eax
f0104194:	68 ba 7b 10 f0       	push   $0xf0107bba
f0104199:	e8 41 f8 ff ff       	call   f01039df <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010419e:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f01041a1:	83 c4 10             	add    $0x10,%esp
f01041a4:	83 f8 13             	cmp    $0x13,%eax
f01041a7:	77 09                	ja     f01041b2 <print_trapframe+0x5c>
		return excnames[trapno];
f01041a9:	8b 14 85 60 7e 10 f0 	mov    -0xfef81a0(,%eax,4),%edx
f01041b0:	eb 1f                	jmp    f01041d1 <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f01041b2:	83 f8 30             	cmp    $0x30,%eax
f01041b5:	74 15                	je     f01041cc <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01041b7:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f01041ba:	83 fa 10             	cmp    $0x10,%edx
f01041bd:	b9 53 7b 10 f0       	mov    $0xf0107b53,%ecx
f01041c2:	ba 40 7b 10 f0       	mov    $0xf0107b40,%edx
f01041c7:	0f 43 d1             	cmovae %ecx,%edx
f01041ca:	eb 05                	jmp    f01041d1 <print_trapframe+0x7b>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f01041cc:	ba 34 7b 10 f0       	mov    $0xf0107b34,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01041d1:	83 ec 04             	sub    $0x4,%esp
f01041d4:	52                   	push   %edx
f01041d5:	50                   	push   %eax
f01041d6:	68 cd 7b 10 f0       	push   $0xf0107bcd
f01041db:	e8 ff f7 ff ff       	call   f01039df <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01041e0:	83 c4 10             	add    $0x10,%esp
f01041e3:	3b 1d 60 2a 21 f0    	cmp    0xf0212a60,%ebx
f01041e9:	75 1a                	jne    f0104205 <print_trapframe+0xaf>
f01041eb:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01041ef:	75 14                	jne    f0104205 <print_trapframe+0xaf>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f01041f1:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01041f4:	83 ec 08             	sub    $0x8,%esp
f01041f7:	50                   	push   %eax
f01041f8:	68 df 7b 10 f0       	push   $0xf0107bdf
f01041fd:	e8 dd f7 ff ff       	call   f01039df <cprintf>
f0104202:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0104205:	83 ec 08             	sub    $0x8,%esp
f0104208:	ff 73 2c             	pushl  0x2c(%ebx)
f010420b:	68 ee 7b 10 f0       	push   $0xf0107bee
f0104210:	e8 ca f7 ff ff       	call   f01039df <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104215:	83 c4 10             	add    $0x10,%esp
f0104218:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010421c:	75 49                	jne    f0104267 <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f010421e:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0104221:	89 c2                	mov    %eax,%edx
f0104223:	83 e2 01             	and    $0x1,%edx
f0104226:	ba 6d 7b 10 f0       	mov    $0xf0107b6d,%edx
f010422b:	b9 62 7b 10 f0       	mov    $0xf0107b62,%ecx
f0104230:	0f 44 ca             	cmove  %edx,%ecx
f0104233:	89 c2                	mov    %eax,%edx
f0104235:	83 e2 02             	and    $0x2,%edx
f0104238:	ba 7f 7b 10 f0       	mov    $0xf0107b7f,%edx
f010423d:	be 79 7b 10 f0       	mov    $0xf0107b79,%esi
f0104242:	0f 45 d6             	cmovne %esi,%edx
f0104245:	83 e0 04             	and    $0x4,%eax
f0104248:	be e6 7c 10 f0       	mov    $0xf0107ce6,%esi
f010424d:	b8 84 7b 10 f0       	mov    $0xf0107b84,%eax
f0104252:	0f 44 c6             	cmove  %esi,%eax
f0104255:	51                   	push   %ecx
f0104256:	52                   	push   %edx
f0104257:	50                   	push   %eax
f0104258:	68 fc 7b 10 f0       	push   $0xf0107bfc
f010425d:	e8 7d f7 ff ff       	call   f01039df <cprintf>
f0104262:	83 c4 10             	add    $0x10,%esp
f0104265:	eb 10                	jmp    f0104277 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0104267:	83 ec 0c             	sub    $0xc,%esp
f010426a:	68 fa 7e 10 f0       	push   $0xf0107efa
f010426f:	e8 6b f7 ff ff       	call   f01039df <cprintf>
f0104274:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104277:	83 ec 08             	sub    $0x8,%esp
f010427a:	ff 73 30             	pushl  0x30(%ebx)
f010427d:	68 0b 7c 10 f0       	push   $0xf0107c0b
f0104282:	e8 58 f7 ff ff       	call   f01039df <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104287:	83 c4 08             	add    $0x8,%esp
f010428a:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f010428e:	50                   	push   %eax
f010428f:	68 1a 7c 10 f0       	push   $0xf0107c1a
f0104294:	e8 46 f7 ff ff       	call   f01039df <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104299:	83 c4 08             	add    $0x8,%esp
f010429c:	ff 73 38             	pushl  0x38(%ebx)
f010429f:	68 2d 7c 10 f0       	push   $0xf0107c2d
f01042a4:	e8 36 f7 ff ff       	call   f01039df <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01042a9:	83 c4 10             	add    $0x10,%esp
f01042ac:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01042b0:	74 25                	je     f01042d7 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01042b2:	83 ec 08             	sub    $0x8,%esp
f01042b5:	ff 73 3c             	pushl  0x3c(%ebx)
f01042b8:	68 3c 7c 10 f0       	push   $0xf0107c3c
f01042bd:	e8 1d f7 ff ff       	call   f01039df <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01042c2:	83 c4 08             	add    $0x8,%esp
f01042c5:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01042c9:	50                   	push   %eax
f01042ca:	68 4b 7c 10 f0       	push   $0xf0107c4b
f01042cf:	e8 0b f7 ff ff       	call   f01039df <cprintf>
f01042d4:	83 c4 10             	add    $0x10,%esp
	}
}
f01042d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01042da:	5b                   	pop    %ebx
f01042db:	5e                   	pop    %esi
f01042dc:	5d                   	pop    %ebp
f01042dd:	c3                   	ret    

f01042de <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01042de:	55                   	push   %ebp
f01042df:	89 e5                	mov    %esp,%ebp
f01042e1:	57                   	push   %edi
f01042e2:	56                   	push   %esi
f01042e3:	53                   	push   %ebx
f01042e4:	83 ec 0c             	sub    $0xc,%esp
f01042e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01042ea:	0f 20 d6             	mov    %cr2,%esi

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.

	if ((tf->tf_cs & 3) == 0) {
f01042ed:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01042f1:	75 17                	jne    f010430a <page_fault_handler+0x2c>
		panic("kernel page fault\n");
f01042f3:	83 ec 04             	sub    $0x4,%esp
f01042f6:	68 5e 7c 10 f0       	push   $0xf0107c5e
f01042fb:	68 5f 01 00 00       	push   $0x15f
f0104300:	68 71 7c 10 f0       	push   $0xf0107c71
f0104305:	e8 36 bd ff ff       	call   f0100040 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	if (curenv->env_pgfault_upcall) {
f010430a:	e8 73 1d 00 00       	call   f0106082 <cpunum>
f010430f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104312:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0104318:	83 78 6c 00          	cmpl   $0x0,0x6c(%eax)
f010431c:	0f 84 a7 00 00 00    	je     f01043c9 <page_fault_handler+0xeb>
		struct UTrapframe *utf;
		uintptr_t utf_va;
		if ((tf->tf_esp >= UXSTACKTOP - PGSIZE) && 
f0104322:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104325:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
		    (tf->tf_esp < UXSTACKTOP)) {
			utf_va = tf->tf_esp - sizeof(struct UTrapframe) - 4;
f010432b:	83 e8 38             	sub    $0x38,%eax
f010432e:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104334:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f0104339:	0f 46 d0             	cmovbe %eax,%edx
f010433c:	89 d7                	mov    %edx,%edi
		} else {
			utf_va = UXSTACKTOP - sizeof(struct UTrapframe);
		}
	
		user_mem_assert(curenv, (void*)utf_va, sizeof(struct UTrapframe), 					PTE_W);
f010433e:	e8 3f 1d 00 00       	call   f0106082 <cpunum>
f0104343:	6a 02                	push   $0x2
f0104345:	6a 34                	push   $0x34
f0104347:	57                   	push   %edi
f0104348:	6b c0 74             	imul   $0x74,%eax,%eax
f010434b:	ff b0 28 30 21 f0    	pushl  -0xfdecfd8(%eax)
f0104351:	e8 1f ec ff ff       	call   f0102f75 <user_mem_assert>
		utf = (struct UTrapframe*) utf_va;

		utf->utf_fault_va = fault_va;
f0104356:	89 fa                	mov    %edi,%edx
f0104358:	89 37                	mov    %esi,(%edi)
		utf->utf_err = tf->tf_err;
f010435a:	8b 43 2c             	mov    0x2c(%ebx),%eax
f010435d:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_regs = tf->tf_regs;
f0104360:	8d 7f 08             	lea    0x8(%edi),%edi
f0104363:	b9 08 00 00 00       	mov    $0x8,%ecx
f0104368:	89 de                	mov    %ebx,%esi
f010436a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eip = tf->tf_eip;
f010436c:	8b 43 30             	mov    0x30(%ebx),%eax
f010436f:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags = tf->tf_eflags;
f0104372:	8b 43 38             	mov    0x38(%ebx),%eax
f0104375:	89 d7                	mov    %edx,%edi
f0104377:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;
f010437a:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010437d:	89 42 30             	mov    %eax,0x30(%edx)

		curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f0104380:	e8 fd 1c 00 00       	call   f0106082 <cpunum>
f0104385:	6b c0 74             	imul   $0x74,%eax,%eax
f0104388:	8b 98 28 30 21 f0    	mov    -0xfdecfd8(%eax),%ebx
f010438e:	e8 ef 1c 00 00       	call   f0106082 <cpunum>
f0104393:	6b c0 74             	imul   $0x74,%eax,%eax
f0104396:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f010439c:	8b 40 6c             	mov    0x6c(%eax),%eax
f010439f:	89 43 38             	mov    %eax,0x38(%ebx)
		curenv->env_tf.tf_esp = utf_va;
f01043a2:	e8 db 1c 00 00       	call   f0106082 <cpunum>
f01043a7:	6b c0 74             	imul   $0x74,%eax,%eax
f01043aa:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f01043b0:	89 78 44             	mov    %edi,0x44(%eax)
		env_run(curenv);
f01043b3:	e8 ca 1c 00 00       	call   f0106082 <cpunum>
f01043b8:	83 c4 04             	add    $0x4,%esp
f01043bb:	6b c0 74             	imul   $0x74,%eax,%eax
f01043be:	ff b0 28 30 21 f0    	pushl  -0xfdecfd8(%eax)
f01043c4:	e8 eb f2 ff ff       	call   f01036b4 <env_run>
	}


	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01043c9:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f01043cc:	e8 b1 1c 00 00       	call   f0106082 <cpunum>
		env_run(curenv);
	}


	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01043d1:	57                   	push   %edi
f01043d2:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f01043d3:	6b c0 74             	imul   $0x74,%eax,%eax
		env_run(curenv);
	}


	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01043d6:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f01043dc:	ff 70 50             	pushl  0x50(%eax)
f01043df:	68 30 7e 10 f0       	push   $0xf0107e30
f01043e4:	e8 f6 f5 ff ff       	call   f01039df <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01043e9:	89 1c 24             	mov    %ebx,(%esp)
f01043ec:	e8 65 fd ff ff       	call   f0104156 <print_trapframe>
	env_destroy(curenv);
f01043f1:	e8 8c 1c 00 00       	call   f0106082 <cpunum>
f01043f6:	83 c4 04             	add    $0x4,%esp
f01043f9:	6b c0 74             	imul   $0x74,%eax,%eax
f01043fc:	ff b0 28 30 21 f0    	pushl  -0xfdecfd8(%eax)
f0104402:	e8 e8 f1 ff ff       	call   f01035ef <env_destroy>
}
f0104407:	83 c4 10             	add    $0x10,%esp
f010440a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010440d:	5b                   	pop    %ebx
f010440e:	5e                   	pop    %esi
f010440f:	5f                   	pop    %edi
f0104410:	5d                   	pop    %ebp
f0104411:	c3                   	ret    

f0104412 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104412:	55                   	push   %ebp
f0104413:	89 e5                	mov    %esp,%ebp
f0104415:	57                   	push   %edi
f0104416:	56                   	push   %esi
f0104417:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f010441a:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f010441b:	83 3d 80 2e 21 f0 00 	cmpl   $0x0,0xf0212e80
f0104422:	74 01                	je     f0104425 <trap+0x13>
		asm volatile("hlt");
f0104424:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104425:	e8 58 1c 00 00       	call   f0106082 <cpunum>
f010442a:	6b d0 74             	imul   $0x74,%eax,%edx
f010442d:	81 c2 20 30 21 f0    	add    $0xf0213020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104433:	b8 01 00 00 00       	mov    $0x1,%eax
f0104438:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010443c:	83 f8 02             	cmp    $0x2,%eax
f010443f:	75 10                	jne    f0104451 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104441:	83 ec 0c             	sub    $0xc,%esp
f0104444:	68 c0 13 12 f0       	push   $0xf01213c0
f0104449:	e8 a2 1e 00 00       	call   f01062f0 <spin_lock>
f010444e:	83 c4 10             	add    $0x10,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104451:	9c                   	pushf  
f0104452:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104453:	f6 c4 02             	test   $0x2,%ah
f0104456:	74 19                	je     f0104471 <trap+0x5f>
f0104458:	68 7d 7c 10 f0       	push   $0xf0107c7d
f010445d:	68 37 76 10 f0       	push   $0xf0107637
f0104462:	68 26 01 00 00       	push   $0x126
f0104467:	68 71 7c 10 f0       	push   $0xf0107c71
f010446c:	e8 cf bb ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104471:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104475:	83 e0 03             	and    $0x3,%eax
f0104478:	66 83 f8 03          	cmp    $0x3,%ax
f010447c:	0f 85 a4 00 00 00    	jne    f0104526 <trap+0x114>
f0104482:	83 ec 0c             	sub    $0xc,%esp
f0104485:	68 c0 13 12 f0       	push   $0xf01213c0
f010448a:	e8 61 1e 00 00       	call   f01062f0 <spin_lock>
		// serious kernel work.
		// LAB 4: Your code here.

		lock_kernel();

		assert(curenv);
f010448f:	e8 ee 1b 00 00       	call   f0106082 <cpunum>
f0104494:	6b c0 74             	imul   $0x74,%eax,%eax
f0104497:	83 c4 10             	add    $0x10,%esp
f010449a:	83 b8 28 30 21 f0 00 	cmpl   $0x0,-0xfdecfd8(%eax)
f01044a1:	75 19                	jne    f01044bc <trap+0xaa>
f01044a3:	68 96 7c 10 f0       	push   $0xf0107c96
f01044a8:	68 37 76 10 f0       	push   $0xf0107637
f01044ad:	68 30 01 00 00       	push   $0x130
f01044b2:	68 71 7c 10 f0       	push   $0xf0107c71
f01044b7:	e8 84 bb ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01044bc:	e8 c1 1b 00 00       	call   f0106082 <cpunum>
f01044c1:	6b c0 74             	imul   $0x74,%eax,%eax
f01044c4:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f01044ca:	83 78 5c 01          	cmpl   $0x1,0x5c(%eax)
f01044ce:	75 2d                	jne    f01044fd <trap+0xeb>
			env_free(curenv);
f01044d0:	e8 ad 1b 00 00       	call   f0106082 <cpunum>
f01044d5:	83 ec 0c             	sub    $0xc,%esp
f01044d8:	6b c0 74             	imul   $0x74,%eax,%eax
f01044db:	ff b0 28 30 21 f0    	pushl  -0xfdecfd8(%eax)
f01044e1:	e8 63 ef ff ff       	call   f0103449 <env_free>
			curenv = NULL;
f01044e6:	e8 97 1b 00 00       	call   f0106082 <cpunum>
f01044eb:	6b c0 74             	imul   $0x74,%eax,%eax
f01044ee:	c7 80 28 30 21 f0 00 	movl   $0x0,-0xfdecfd8(%eax)
f01044f5:	00 00 00 
			sched_yield();
f01044f8:	e8 4c 03 00 00       	call   f0104849 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01044fd:	e8 80 1b 00 00       	call   f0106082 <cpunum>
f0104502:	6b c0 74             	imul   $0x74,%eax,%eax
f0104505:	8b b8 28 30 21 f0    	mov    -0xfdecfd8(%eax),%edi
f010450b:	83 c7 08             	add    $0x8,%edi
f010450e:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104513:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104515:	e8 68 1b 00 00       	call   f0106082 <cpunum>
f010451a:	6b c0 74             	imul   $0x74,%eax,%eax
f010451d:	8b b0 28 30 21 f0    	mov    -0xfdecfd8(%eax),%esi
f0104523:	83 c6 08             	add    $0x8,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104526:	89 35 60 2a 21 f0    	mov    %esi,0xf0212a60
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.

	switch (tf->tf_trapno) {	
f010452c:	8b 46 28             	mov    0x28(%esi),%eax
f010452f:	83 f8 0e             	cmp    $0xe,%eax
f0104532:	74 0c                	je     f0104540 <trap+0x12e>
f0104534:	83 f8 30             	cmp    $0x30,%eax
f0104537:	74 38                	je     f0104571 <trap+0x15f>
f0104539:	83 f8 03             	cmp    $0x3,%eax
f010453c:	75 57                	jne    f0104595 <trap+0x183>
f010453e:	eb 11                	jmp    f0104551 <trap+0x13f>
	case T_PGFLT:
		page_fault_handler(tf);
f0104540:	83 ec 0c             	sub    $0xc,%esp
f0104543:	56                   	push   %esi
f0104544:	e8 95 fd ff ff       	call   f01042de <page_fault_handler>
f0104549:	83 c4 10             	add    $0x10,%esp
f010454c:	e9 cd 00 00 00       	jmp    f010461e <trap+0x20c>
		return;
	case T_BRKPT:
		print_trapframe(tf);
f0104551:	83 ec 0c             	sub    $0xc,%esp
f0104554:	56                   	push   %esi
f0104555:	e8 fc fb ff ff       	call   f0104156 <print_trapframe>
		panic("tf->tf_trapno == T_BRKPT\n");
f010455a:	83 c4 0c             	add    $0xc,%esp
f010455d:	68 9d 7c 10 f0       	push   $0xf0107c9d
f0104562:	68 e0 00 00 00       	push   $0xe0
f0104567:	68 71 7c 10 f0       	push   $0xf0107c71
f010456c:	e8 cf ba ff ff       	call   f0100040 <_panic>
		return;
	case T_SYSCALL:
		tf->tf_regs.reg_eax = syscall(
f0104571:	83 ec 08             	sub    $0x8,%esp
f0104574:	ff 76 04             	pushl  0x4(%esi)
f0104577:	ff 36                	pushl  (%esi)
f0104579:	ff 76 10             	pushl  0x10(%esi)
f010457c:	ff 76 18             	pushl  0x18(%esi)
f010457f:	ff 76 14             	pushl  0x14(%esi)
f0104582:	ff 76 1c             	pushl  0x1c(%esi)
f0104585:	e8 c1 03 00 00       	call   f010494b <syscall>
f010458a:	89 46 1c             	mov    %eax,0x1c(%esi)
f010458d:	83 c4 20             	add    $0x20,%esp
f0104590:	e9 89 00 00 00       	jmp    f010461e <trap+0x20c>
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104595:	83 f8 27             	cmp    $0x27,%eax
f0104598:	75 1a                	jne    f01045b4 <trap+0x1a2>
		cprintf("Spurious interrupt on irq 7\n");
f010459a:	83 ec 0c             	sub    $0xc,%esp
f010459d:	68 b7 7c 10 f0       	push   $0xf0107cb7
f01045a2:	e8 38 f4 ff ff       	call   f01039df <cprintf>
		print_trapframe(tf);
f01045a7:	89 34 24             	mov    %esi,(%esp)
f01045aa:	e8 a7 fb ff ff       	call   f0104156 <print_trapframe>
f01045af:	83 c4 10             	add    $0x10,%esp
f01045b2:	eb 6a                	jmp    f010461e <trap+0x20c>

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f01045b4:	83 f8 20             	cmp    $0x20,%eax
f01045b7:	75 0a                	jne    f01045c3 <trap+0x1b1>
		lapic_eoi();
f01045b9:	e8 0f 1c 00 00       	call   f01061cd <lapic_eoi>
		sched_yield();
f01045be:	e8 86 02 00 00       	call   f0104849 <sched_yield>
	}

	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.

	if (tf->tf_trapno == (IRQ_OFFSET + IRQ_KBD)) {
f01045c3:	83 f8 21             	cmp    $0x21,%eax
f01045c6:	75 07                	jne    f01045cf <trap+0x1bd>
		kbd_intr();
f01045c8:	e8 2a c0 ff ff       	call   f01005f7 <kbd_intr>
f01045cd:	eb 4f                	jmp    f010461e <trap+0x20c>
		return;
	}

	if (tf->tf_trapno == (IRQ_OFFSET + IRQ_SERIAL)) {
f01045cf:	83 f8 24             	cmp    $0x24,%eax
f01045d2:	75 07                	jne    f01045db <trap+0x1c9>
		serial_intr();
f01045d4:	e8 02 c0 ff ff       	call   f01005db <serial_intr>
f01045d9:	eb 43                	jmp    f010461e <trap+0x20c>
		return;
	}

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f01045db:	83 ec 0c             	sub    $0xc,%esp
f01045de:	56                   	push   %esi
f01045df:	e8 72 fb ff ff       	call   f0104156 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01045e4:	83 c4 10             	add    $0x10,%esp
f01045e7:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01045ec:	75 17                	jne    f0104605 <trap+0x1f3>
		panic("unhandled trap in kernel");
f01045ee:	83 ec 04             	sub    $0x4,%esp
f01045f1:	68 d4 7c 10 f0       	push   $0xf0107cd4
f01045f6:	68 0c 01 00 00       	push   $0x10c
f01045fb:	68 71 7c 10 f0       	push   $0xf0107c71
f0104600:	e8 3b ba ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104605:	e8 78 1a 00 00       	call   f0106082 <cpunum>
f010460a:	83 ec 0c             	sub    $0xc,%esp
f010460d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104610:	ff b0 28 30 21 f0    	pushl  -0xfdecfd8(%eax)
f0104616:	e8 d4 ef ff ff       	call   f01035ef <env_destroy>
f010461b:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f010461e:	e8 5f 1a 00 00       	call   f0106082 <cpunum>
f0104623:	6b c0 74             	imul   $0x74,%eax,%eax
f0104626:	83 b8 28 30 21 f0 00 	cmpl   $0x0,-0xfdecfd8(%eax)
f010462d:	74 2a                	je     f0104659 <trap+0x247>
f010462f:	e8 4e 1a 00 00       	call   f0106082 <cpunum>
f0104634:	6b c0 74             	imul   $0x74,%eax,%eax
f0104637:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f010463d:	83 78 5c 03          	cmpl   $0x3,0x5c(%eax)
f0104641:	75 16                	jne    f0104659 <trap+0x247>
		env_run(curenv);
f0104643:	e8 3a 1a 00 00       	call   f0106082 <cpunum>
f0104648:	83 ec 0c             	sub    $0xc,%esp
f010464b:	6b c0 74             	imul   $0x74,%eax,%eax
f010464e:	ff b0 28 30 21 f0    	pushl  -0xfdecfd8(%eax)
f0104654:	e8 5b f0 ff ff       	call   f01036b4 <env_run>
	else
		sched_yield();
f0104659:	e8 eb 01 00 00       	call   f0104849 <sched_yield>

f010465e <TH_DIVIDE>:
	.p2align 2
	.globl TRAPHANDLERS
TRAPHANDLERS:
.text

TRAPHANDLER_NOEC(TH_DIVIDE, T_DIVIDE)	// fault
f010465e:	6a 00                	push   $0x0
f0104660:	6a 00                	push   $0x0
f0104662:	e9 f9 00 00 00       	jmp    f0104760 <_alltraps>
f0104667:	90                   	nop

f0104668 <TH_DEBUG>:
TRAPHANDLER_NOEC(TH_DEBUG, T_DEBUG)	// fault/trap
f0104668:	6a 00                	push   $0x0
f010466a:	6a 01                	push   $0x1
f010466c:	e9 ef 00 00 00       	jmp    f0104760 <_alltraps>
f0104671:	90                   	nop

f0104672 <TH_NMI>:
TRAPHANDLER_NOEC(TH_NMI, T_NMI)		//
f0104672:	6a 00                	push   $0x0
f0104674:	6a 02                	push   $0x2
f0104676:	e9 e5 00 00 00       	jmp    f0104760 <_alltraps>
f010467b:	90                   	nop

f010467c <TH_BRKPT>:
TRAPHANDLER_NOEC(TH_BRKPT, T_BRKPT)	// trap
f010467c:	6a 00                	push   $0x0
f010467e:	6a 03                	push   $0x3
f0104680:	e9 db 00 00 00       	jmp    f0104760 <_alltraps>
f0104685:	90                   	nop

f0104686 <TH_OFLOW>:
TRAPHANDLER_NOEC(TH_OFLOW, T_OFLOW)	// trap
f0104686:	6a 00                	push   $0x0
f0104688:	6a 04                	push   $0x4
f010468a:	e9 d1 00 00 00       	jmp    f0104760 <_alltraps>
f010468f:	90                   	nop

f0104690 <TH_BOUND>:
TRAPHANDLER_NOEC(TH_BOUND, T_BOUND)	// fault
f0104690:	6a 00                	push   $0x0
f0104692:	6a 05                	push   $0x5
f0104694:	e9 c7 00 00 00       	jmp    f0104760 <_alltraps>
f0104699:	90                   	nop

f010469a <TH_ILLOP>:
TRAPHANDLER_NOEC(TH_ILLOP, T_ILLOP)	// fault
f010469a:	6a 00                	push   $0x0
f010469c:	6a 06                	push   $0x6
f010469e:	e9 bd 00 00 00       	jmp    f0104760 <_alltraps>
f01046a3:	90                   	nop

f01046a4 <TH_DEVICE>:
TRAPHANDLER_NOEC(TH_DEVICE, T_DEVICE)	// fault
f01046a4:	6a 00                	push   $0x0
f01046a6:	6a 07                	push   $0x7
f01046a8:	e9 b3 00 00 00       	jmp    f0104760 <_alltraps>
f01046ad:	90                   	nop

f01046ae <TH_DBLFLT>:
TRAPHANDLER     (TH_DBLFLT, T_DBLFLT)	// abort
f01046ae:	6a 08                	push   $0x8
f01046b0:	e9 ab 00 00 00       	jmp    f0104760 <_alltraps>
f01046b5:	90                   	nop

f01046b6 <TH_TSS>:
//TRAPHANDLER_NOEC(TH_COPROC, T_COPROC) // abort	
TRAPHANDLER     (TH_TSS, T_TSS)		// fault
f01046b6:	6a 0a                	push   $0xa
f01046b8:	e9 a3 00 00 00       	jmp    f0104760 <_alltraps>
f01046bd:	90                   	nop

f01046be <TH_SEGNP>:
TRAPHANDLER     (TH_SEGNP, T_SEGNP)	// fault
f01046be:	6a 0b                	push   $0xb
f01046c0:	e9 9b 00 00 00       	jmp    f0104760 <_alltraps>
f01046c5:	90                   	nop

f01046c6 <TH_STACK>:
TRAPHANDLER     (TH_STACK, T_STACK)	// fault
f01046c6:	6a 0c                	push   $0xc
f01046c8:	e9 93 00 00 00       	jmp    f0104760 <_alltraps>
f01046cd:	90                   	nop

f01046ce <TH_GPFLT>:
TRAPHANDLER     (TH_GPFLT, T_GPFLT)	// fault/abort
f01046ce:	6a 0d                	push   $0xd
f01046d0:	e9 8b 00 00 00       	jmp    f0104760 <_alltraps>
f01046d5:	90                   	nop

f01046d6 <TH_PGFLT>:
TRAPHANDLER     (TH_PGFLT, T_PGFLT)	// fault
f01046d6:	6a 0e                	push   $0xe
f01046d8:	e9 83 00 00 00       	jmp    f0104760 <_alltraps>
f01046dd:	90                   	nop

f01046de <TH_FPERR>:
//TRAPHANDLER_NOEC(TH_RES, T_RES)	
TRAPHANDLER_NOEC(TH_FPERR, T_FPERR)	// fault
f01046de:	6a 00                	push   $0x0
f01046e0:	6a 10                	push   $0x10
f01046e2:	eb 7c                	jmp    f0104760 <_alltraps>

f01046e4 <TH_ALIGN>:
TRAPHANDLER     (TH_ALIGN, T_ALIGN)	//
f01046e4:	6a 11                	push   $0x11
f01046e6:	eb 78                	jmp    f0104760 <_alltraps>

f01046e8 <TH_MCHK>:
TRAPHANDLER_NOEC(TH_MCHK, T_MCHK)	//
f01046e8:	6a 00                	push   $0x0
f01046ea:	6a 12                	push   $0x12
f01046ec:	eb 72                	jmp    f0104760 <_alltraps>

f01046ee <TH_SIMDERR>:
TRAPHANDLER_NOEC(TH_SIMDERR, T_SIMDERR) //
f01046ee:	6a 00                	push   $0x0
f01046f0:	6a 13                	push   $0x13
f01046f2:	eb 6c                	jmp    f0104760 <_alltraps>

f01046f4 <TH_SYSCALL>:

TRAPHANDLER_NOEC(TH_SYSCALL, T_SYSCALL) // trap
f01046f4:	6a 00                	push   $0x0
f01046f6:	6a 30                	push   $0x30
f01046f8:	eb 66                	jmp    f0104760 <_alltraps>

f01046fa <TH_IRQ_TIMER>:

TRAPHANDLER_NOEC(TH_IRQ_TIMER, IRQ_OFFSET+IRQ_TIMER)	// 0
f01046fa:	6a 00                	push   $0x0
f01046fc:	6a 20                	push   $0x20
f01046fe:	eb 60                	jmp    f0104760 <_alltraps>

f0104700 <TH_IRQ_KBD>:
TRAPHANDLER_NOEC(TH_IRQ_KBD, IRQ_OFFSET+IRQ_KBD)	// 1
f0104700:	6a 00                	push   $0x0
f0104702:	6a 21                	push   $0x21
f0104704:	eb 5a                	jmp    f0104760 <_alltraps>

f0104706 <TH_IRQ_2>:
TRAPHANDLER_NOEC(TH_IRQ_2, IRQ_OFFSET+2)
f0104706:	6a 00                	push   $0x0
f0104708:	6a 22                	push   $0x22
f010470a:	eb 54                	jmp    f0104760 <_alltraps>

f010470c <TH_IRQ_3>:
TRAPHANDLER_NOEC(TH_IRQ_3, IRQ_OFFSET+3)
f010470c:	6a 00                	push   $0x0
f010470e:	6a 23                	push   $0x23
f0104710:	eb 4e                	jmp    f0104760 <_alltraps>

f0104712 <TH_IRQ_SERIAL>:
TRAPHANDLER_NOEC(TH_IRQ_SERIAL, IRQ_OFFSET+IRQ_SERIAL)	// 4
f0104712:	6a 00                	push   $0x0
f0104714:	6a 24                	push   $0x24
f0104716:	eb 48                	jmp    f0104760 <_alltraps>

f0104718 <TH_IRQ_5>:
TRAPHANDLER_NOEC(TH_IRQ_5, IRQ_OFFSET+5)
f0104718:	6a 00                	push   $0x0
f010471a:	6a 25                	push   $0x25
f010471c:	eb 42                	jmp    f0104760 <_alltraps>

f010471e <TH_IRQ_6>:
TRAPHANDLER_NOEC(TH_IRQ_6, IRQ_OFFSET+6)
f010471e:	6a 00                	push   $0x0
f0104720:	6a 26                	push   $0x26
f0104722:	eb 3c                	jmp    f0104760 <_alltraps>

f0104724 <TH_IRQ_SPURIOUS>:
TRAPHANDLER_NOEC(TH_IRQ_SPURIOUS, IRQ_OFFSET+IRQ_SPURIOUS) // 7
f0104724:	6a 00                	push   $0x0
f0104726:	6a 27                	push   $0x27
f0104728:	eb 36                	jmp    f0104760 <_alltraps>

f010472a <TH_IRQ_8>:
TRAPHANDLER_NOEC(TH_IRQ_8, IRQ_OFFSET+8)
f010472a:	6a 00                	push   $0x0
f010472c:	6a 28                	push   $0x28
f010472e:	eb 30                	jmp    f0104760 <_alltraps>

f0104730 <TH_IRQ_9>:
TRAPHANDLER_NOEC(TH_IRQ_9, IRQ_OFFSET+9)
f0104730:	6a 00                	push   $0x0
f0104732:	6a 29                	push   $0x29
f0104734:	eb 2a                	jmp    f0104760 <_alltraps>

f0104736 <TH_IRQ_10>:
TRAPHANDLER_NOEC(TH_IRQ_10, IRQ_OFFSET+10)
f0104736:	6a 00                	push   $0x0
f0104738:	6a 2a                	push   $0x2a
f010473a:	eb 24                	jmp    f0104760 <_alltraps>

f010473c <TH_IRQ_11>:
TRAPHANDLER_NOEC(TH_IRQ_11, IRQ_OFFSET+11)
f010473c:	6a 00                	push   $0x0
f010473e:	6a 2b                	push   $0x2b
f0104740:	eb 1e                	jmp    f0104760 <_alltraps>

f0104742 <TH_IRQ_12>:
TRAPHANDLER_NOEC(TH_IRQ_12, IRQ_OFFSET+12)
f0104742:	6a 00                	push   $0x0
f0104744:	6a 2c                	push   $0x2c
f0104746:	eb 18                	jmp    f0104760 <_alltraps>

f0104748 <TH_IRQ_13>:
TRAPHANDLER_NOEC(TH_IRQ_13, IRQ_OFFSET+13)
f0104748:	6a 00                	push   $0x0
f010474a:	6a 2d                	push   $0x2d
f010474c:	eb 12                	jmp    f0104760 <_alltraps>

f010474e <TH_IRQ_IDE>:
TRAPHANDLER_NOEC(TH_IRQ_IDE, IRQ_OFFSET+IRQ_IDE)	// 14
f010474e:	6a 00                	push   $0x0
f0104750:	6a 2e                	push   $0x2e
f0104752:	eb 0c                	jmp    f0104760 <_alltraps>

f0104754 <TH_IRQ_15>:
TRAPHANDLER_NOEC(TH_IRQ_15, IRQ_OFFSET+15)
f0104754:	6a 00                	push   $0x0
f0104756:	6a 2f                	push   $0x2f
f0104758:	eb 06                	jmp    f0104760 <_alltraps>

f010475a <TH_IRQ_ERROR>:
TRAPHANDLER_NOEC(TH_IRQ_ERROR, IRQ_OFFSET+IRQ_ERROR)	// 19
f010475a:	6a 00                	push   $0x0
f010475c:	6a 33                	push   $0x33
f010475e:	eb 00                	jmp    f0104760 <_alltraps>

f0104760 <_alltraps>:
 * Lab 3: Your code here for _alltraps
 */

.text
_alltraps:
	pushl	%ds
f0104760:	1e                   	push   %ds
	pushl	%es
f0104761:	06                   	push   %es
	pushal
f0104762:	60                   	pusha  
	mov	$GD_KD, %eax
f0104763:	b8 10 00 00 00       	mov    $0x10,%eax
	mov	%ax, %es
f0104768:	8e c0                	mov    %eax,%es
	mov	%ax, %ds
f010476a:	8e d8                	mov    %eax,%ds
	pushl	%esp
f010476c:	54                   	push   %esp
	call	trap
f010476d:	e8 a0 fc ff ff       	call   f0104412 <trap>

f0104772 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104772:	55                   	push   %ebp
f0104773:	89 e5                	mov    %esp,%ebp
f0104775:	83 ec 08             	sub    $0x8,%esp
f0104778:	a1 48 22 21 f0       	mov    0xf0212248,%eax
f010477d:	8d 50 5c             	lea    0x5c(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104780:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104785:	8b 02                	mov    (%edx),%eax
f0104787:	83 e8 01             	sub    $0x1,%eax
f010478a:	83 f8 02             	cmp    $0x2,%eax
f010478d:	76 13                	jbe    f01047a2 <sched_halt+0x30>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010478f:	83 c1 01             	add    $0x1,%ecx
f0104792:	81 c2 84 00 00 00    	add    $0x84,%edx
f0104798:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f010479e:	75 e5                	jne    f0104785 <sched_halt+0x13>
f01047a0:	eb 08                	jmp    f01047aa <sched_halt+0x38>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f01047a2:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01047a8:	75 1f                	jne    f01047c9 <sched_halt+0x57>
		cprintf("No runnable environments in the system!\n");
f01047aa:	83 ec 0c             	sub    $0xc,%esp
f01047ad:	68 b0 7e 10 f0       	push   $0xf0107eb0
f01047b2:	e8 28 f2 ff ff       	call   f01039df <cprintf>
f01047b7:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f01047ba:	83 ec 0c             	sub    $0xc,%esp
f01047bd:	6a 00                	push   $0x0
f01047bf:	e8 91 c1 ff ff       	call   f0100955 <monitor>
f01047c4:	83 c4 10             	add    $0x10,%esp
f01047c7:	eb f1                	jmp    f01047ba <sched_halt+0x48>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01047c9:	e8 b4 18 00 00       	call   f0106082 <cpunum>
f01047ce:	6b c0 74             	imul   $0x74,%eax,%eax
f01047d1:	c7 80 28 30 21 f0 00 	movl   $0x0,-0xfdecfd8(%eax)
f01047d8:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f01047db:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01047e0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01047e5:	77 12                	ja     f01047f9 <sched_halt+0x87>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01047e7:	50                   	push   %eax
f01047e8:	68 68 67 10 f0       	push   $0xf0106768
f01047ed:	6a 7b                	push   $0x7b
f01047ef:	68 d9 7e 10 f0       	push   $0xf0107ed9
f01047f4:	e8 47 b8 ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01047f9:	05 00 00 00 10       	add    $0x10000000,%eax
f01047fe:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104801:	e8 7c 18 00 00       	call   f0106082 <cpunum>
f0104806:	6b d0 74             	imul   $0x74,%eax,%edx
f0104809:	81 c2 20 30 21 f0    	add    $0xf0213020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f010480f:	b8 02 00 00 00       	mov    $0x2,%eax
f0104814:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104818:	83 ec 0c             	sub    $0xc,%esp
f010481b:	68 c0 13 12 f0       	push   $0xf01213c0
f0104820:	e8 68 1b 00 00       	call   f010638d <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104825:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104827:	e8 56 18 00 00       	call   f0106082 <cpunum>
f010482c:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f010482f:	8b 80 30 30 21 f0    	mov    -0xfdecfd0(%eax),%eax
f0104835:	bd 00 00 00 00       	mov    $0x0,%ebp
f010483a:	89 c4                	mov    %eax,%esp
f010483c:	6a 00                	push   $0x0
f010483e:	6a 00                	push   $0x0
f0104840:	fb                   	sti    
f0104841:	f4                   	hlt    
f0104842:	eb fd                	jmp    f0104841 <sched_halt+0xcf>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104844:	83 c4 10             	add    $0x10,%esp
f0104847:	c9                   	leave  
f0104848:	c3                   	ret    

f0104849 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104849:	55                   	push   %ebp
f010484a:	89 e5                	mov    %esp,%ebp
f010484c:	53                   	push   %ebx
f010484d:	83 ec 10             	sub    $0x10,%esp
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	cprintf ("IN SCHED.C YIELDING\n\n");
f0104850:	68 e6 7e 10 f0       	push   $0xf0107ee6
f0104855:	e8 85 f1 ff ff       	call   f01039df <cprintf>
	size_t i;
	if (!curenv) {
f010485a:	e8 23 18 00 00       	call   f0106082 <cpunum>
f010485f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104862:	83 c4 10             	add    $0x10,%esp
		i = 0;
f0104865:	ba 00 00 00 00       	mov    $0x0,%edx
	// below to halt the cpu.

	// LAB 4: Your code here.
	cprintf ("IN SCHED.C YIELDING\n\n");
	size_t i;
	if (!curenv) {
f010486a:	83 b8 28 30 21 f0 00 	cmpl   $0x0,-0xfdecfd8(%eax)
f0104871:	74 1a                	je     f010488d <sched_yield+0x44>
		i = 0;
	} else {
		i = ENVX(curenv->env_id) + 1;
f0104873:	e8 0a 18 00 00       	call   f0106082 <cpunum>
f0104878:	6b c0 74             	imul   $0x74,%eax,%eax
f010487b:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0104881:	8b 50 50             	mov    0x50(%eax),%edx
f0104884:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f010488a:	83 c2 01             	add    $0x1,%edx
	}
	// Lab 7 Multithreading: scheduler verzia 1.0 
	for (; i < NENV; i++) {
		if (envs[i].env_status == ENV_RUNNABLE) {
f010488d:	a1 48 22 21 f0       	mov    0xf0212248,%eax
f0104892:	89 d1                	mov    %edx,%ecx
f0104894:	c1 e1 07             	shl    $0x7,%ecx
f0104897:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f010489a:	01 c1                	add    %eax,%ecx
f010489c:	eb 1a                	jmp    f01048b8 <sched_yield+0x6f>
f010489e:	89 cb                	mov    %ecx,%ebx
f01048a0:	81 c1 84 00 00 00    	add    $0x84,%ecx
f01048a6:	83 79 d8 02          	cmpl   $0x2,-0x28(%ecx)
f01048aa:	75 09                	jne    f01048b5 <sched_yield+0x6c>
			env_run(&envs[i]);
f01048ac:	83 ec 0c             	sub    $0xc,%esp
f01048af:	53                   	push   %ebx
f01048b0:	e8 ff ed ff ff       	call   f01036b4 <env_run>
		i = 0;
	} else {
		i = ENVX(curenv->env_id) + 1;
	}
	// Lab 7 Multithreading: scheduler verzia 1.0 
	for (; i < NENV; i++) {
f01048b5:	83 c2 01             	add    $0x1,%edx
f01048b8:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
f01048be:	76 de                	jbe    f010489e <sched_yield+0x55>
f01048c0:	b9 00 00 00 00       	mov    $0x0,%ecx
f01048c5:	eb 19                	jmp    f01048e0 <sched_yield+0x97>
	}

	size_t j;

	for (j = 0; j < i; j++) {
		if (envs[j].env_status == ENV_RUNNABLE) {
f01048c7:	89 c3                	mov    %eax,%ebx
f01048c9:	05 84 00 00 00       	add    $0x84,%eax
f01048ce:	83 78 d8 02          	cmpl   $0x2,-0x28(%eax)
f01048d2:	75 09                	jne    f01048dd <sched_yield+0x94>
			env_run(&envs[j]);
f01048d4:	83 ec 0c             	sub    $0xc,%esp
f01048d7:	53                   	push   %ebx
f01048d8:	e8 d7 ed ff ff       	call   f01036b4 <env_run>
		} 
	}

	size_t j;

	for (j = 0; j < i; j++) {
f01048dd:	83 c1 01             	add    $0x1,%ecx
f01048e0:	39 ca                	cmp    %ecx,%edx
f01048e2:	75 e3                	jne    f01048c7 <sched_yield+0x7e>
				else
					env_destroy(&envs[j]);
			}
		} 
	}*/
	if (curenv && (curenv->env_status == ENV_RUNNING)) {
f01048e4:	e8 99 17 00 00       	call   f0106082 <cpunum>
f01048e9:	6b c0 74             	imul   $0x74,%eax,%eax
f01048ec:	83 b8 28 30 21 f0 00 	cmpl   $0x0,-0xfdecfd8(%eax)
f01048f3:	74 2a                	je     f010491f <sched_yield+0xd6>
f01048f5:	e8 88 17 00 00       	call   f0106082 <cpunum>
f01048fa:	6b c0 74             	imul   $0x74,%eax,%eax
f01048fd:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0104903:	83 78 5c 03          	cmpl   $0x3,0x5c(%eax)
f0104907:	75 16                	jne    f010491f <sched_yield+0xd6>
		env_run(curenv);
f0104909:	e8 74 17 00 00       	call   f0106082 <cpunum>
f010490e:	83 ec 0c             	sub    $0xc,%esp
f0104911:	6b c0 74             	imul   $0x74,%eax,%eax
f0104914:	ff b0 28 30 21 f0    	pushl  -0xfdecfd8(%eax)
f010491a:	e8 95 ed ff ff       	call   f01036b4 <env_run>
	}

	// sched_halt never returns
	sched_halt();
f010491f:	e8 4e fe ff ff       	call   f0104772 <sched_halt>
}
f0104924:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104927:	c9                   	leave  
f0104928:	c3                   	ret    

f0104929 <sys_thread_create>:

// Lab 7 Multithreading 
// zavola tvorbu noveho threadu (z env.c)
envid_t	
sys_thread_create(uintptr_t func)
{
f0104929:	55                   	push   %ebp
f010492a:	89 e5                	mov    %esp,%ebp
f010492c:	53                   	push   %ebx
f010492d:	83 ec 0c             	sub    $0xc,%esp
f0104930:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("in sys thread create, eip: %x\n", func);
f0104933:	53                   	push   %ebx
f0104934:	68 fc 7e 10 f0       	push   $0xf0107efc
f0104939:	e8 a1 f0 ff ff       	call   f01039df <cprintf>

	envid_t id = thread_create(func);
f010493e:	89 1c 24             	mov    %ebx,(%esp)
f0104941:	e8 54 ee ff ff       	call   f010379a <thread_create>
	return id;
}	
f0104946:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104949:	c9                   	leave  
f010494a:	c3                   	ret    

f010494b <syscall>:

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f010494b:	55                   	push   %ebp
f010494c:	89 e5                	mov    %esp,%ebp
f010494e:	57                   	push   %edi
f010494f:	56                   	push   %esi
f0104950:	83 ec 10             	sub    $0x10,%esp
f0104953:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno) {
f0104956:	83 f8 0e             	cmp    $0xe,%eax
f0104959:	0f 87 11 06 00 00    	ja     f0104f70 <syscall+0x625>
f010495f:	ff 24 85 54 7f 10 f0 	jmp    *-0xfef80ac(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, PTE_U);
f0104966:	e8 17 17 00 00       	call   f0106082 <cpunum>
f010496b:	6a 04                	push   $0x4
f010496d:	ff 75 10             	pushl  0x10(%ebp)
f0104970:	ff 75 0c             	pushl  0xc(%ebp)
f0104973:	6b c0 74             	imul   $0x74,%eax,%eax
f0104976:	ff b0 28 30 21 f0    	pushl  -0xfdecfd8(%eax)
f010497c:	e8 f4 e5 ff ff       	call   f0102f75 <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104981:	83 c4 0c             	add    $0xc,%esp
f0104984:	ff 75 0c             	pushl  0xc(%ebp)
f0104987:	ff 75 10             	pushl  0x10(%ebp)
f010498a:	68 1b 7f 10 f0       	push   $0xf0107f1b
f010498f:	e8 4b f0 ff ff       	call   f01039df <cprintf>
f0104994:	83 c4 10             	add    $0x10,%esp
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((char*)a1, a2);
			return 0;
f0104997:	b8 00 00 00 00       	mov    $0x0,%eax
f010499c:	e9 db 05 00 00       	jmp    f0104f7c <syscall+0x631>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f01049a1:	e8 63 bc ff ff       	call   f0100609 <cons_getc>
		case SYS_cputs:
			sys_cputs((char*)a1, a2);
			return 0;

		case SYS_cgetc:
			return sys_cgetc();
f01049a6:	e9 d1 05 00 00       	jmp    f0104f7c <syscall+0x631>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01049ab:	e8 d2 16 00 00       	call   f0106082 <cpunum>
f01049b0:	6b c0 74             	imul   $0x74,%eax,%eax
f01049b3:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f01049b9:	8b 40 50             	mov    0x50(%eax),%eax

		case SYS_cgetc:
			return sys_cgetc();

		case SYS_getenvid:
			return sys_getenvid();
f01049bc:	e9 bb 05 00 00       	jmp    f0104f7c <syscall+0x631>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01049c1:	83 ec 04             	sub    $0x4,%esp
f01049c4:	6a 01                	push   $0x1
f01049c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01049c9:	50                   	push   %eax
f01049ca:	ff 75 0c             	pushl  0xc(%ebp)
f01049cd:	e8 73 e6 ff ff       	call   f0103045 <envid2env>
f01049d2:	83 c4 10             	add    $0x10,%esp
f01049d5:	85 c0                	test   %eax,%eax
f01049d7:	0f 88 9f 05 00 00    	js     f0104f7c <syscall+0x631>
		return r;
	if (e == curenv)
f01049dd:	e8 a0 16 00 00       	call   f0106082 <cpunum>
f01049e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01049e5:	6b c0 74             	imul   $0x74,%eax,%eax
f01049e8:	39 90 28 30 21 f0    	cmp    %edx,-0xfdecfd8(%eax)
f01049ee:	75 23                	jne    f0104a13 <syscall+0xc8>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f01049f0:	e8 8d 16 00 00       	call   f0106082 <cpunum>
f01049f5:	83 ec 08             	sub    $0x8,%esp
f01049f8:	6b c0 74             	imul   $0x74,%eax,%eax
f01049fb:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0104a01:	ff 70 50             	pushl  0x50(%eax)
f0104a04:	68 20 7f 10 f0       	push   $0xf0107f20
f0104a09:	e8 d1 ef ff ff       	call   f01039df <cprintf>
f0104a0e:	83 c4 10             	add    $0x10,%esp
f0104a11:	eb 25                	jmp    f0104a38 <syscall+0xed>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104a13:	8b 72 50             	mov    0x50(%edx),%esi
f0104a16:	e8 67 16 00 00       	call   f0106082 <cpunum>
f0104a1b:	83 ec 04             	sub    $0x4,%esp
f0104a1e:	56                   	push   %esi
f0104a1f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a22:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0104a28:	ff 70 50             	pushl  0x50(%eax)
f0104a2b:	68 3b 7f 10 f0       	push   $0xf0107f3b
f0104a30:	e8 aa ef ff ff       	call   f01039df <cprintf>
f0104a35:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104a38:	83 ec 0c             	sub    $0xc,%esp
f0104a3b:	ff 75 f4             	pushl  -0xc(%ebp)
f0104a3e:	e8 ac eb ff ff       	call   f01035ef <env_destroy>
f0104a43:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104a46:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a4b:	e9 2c 05 00 00       	jmp    f0104f7c <syscall+0x631>
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	// check if va is page aligned and isnt above UTOP
	if ((((int)va % PGSIZE) != 0) || ((uintptr_t)va >= UTOP)) {
f0104a50:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104a57:	0f 85 84 00 00 00    	jne    f0104ae1 <syscall+0x196>
f0104a5d:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104a64:	77 7b                	ja     f0104ae1 <syscall+0x196>
		return -E_INVAL;
	}
	// check if PTE_P and PTE_U are set (must be set)
	if (((PTE_P | PTE_U) & perm) != (PTE_U | PTE_P)) { 
f0104a66:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a69:	83 e0 05             	and    $0x5,%eax
f0104a6c:	83 f8 05             	cmp    $0x5,%eax
f0104a6f:	75 7a                	jne    f0104aeb <syscall+0x1a0>
	}
	
	int to_check = perm | PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	int available_perm = PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	// check if no other bits hev bin(where the trash goes) set 
	if ((available_perm ^ to_check) != 0) {
f0104a71:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a74:	0d 07 0e 00 00       	or     $0xe07,%eax
f0104a79:	3d 07 0e 00 00       	cmp    $0xe07,%eax
f0104a7e:	75 75                	jne    f0104af5 <syscall+0x1aa>
		return -E_INVAL;
	}

	struct PageInfo *new_page = page_alloc(ALLOC_ZERO);
f0104a80:	83 ec 0c             	sub    $0xc,%esp
f0104a83:	6a 01                	push   $0x1
f0104a85:	e8 17 c5 ff ff       	call   f0100fa1 <page_alloc>
f0104a8a:	89 c6                	mov    %eax,%esi
	// page alloc return null if there are no free pages on page_free_list
	if (!new_page) {
f0104a8c:	83 c4 10             	add    $0x10,%esp
f0104a8f:	85 c0                	test   %eax,%eax
f0104a91:	74 6c                	je     f0104aff <syscall+0x1b4>
		return -E_NO_MEM;
	}

	struct Env *e;
	int retperm = envid2env(envid, &e, true);
f0104a93:	83 ec 04             	sub    $0x4,%esp
f0104a96:	6a 01                	push   $0x1
f0104a98:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104a9b:	50                   	push   %eax
f0104a9c:	ff 75 0c             	pushl  0xc(%ebp)
f0104a9f:	e8 a1 e5 ff ff       	call   f0103045 <envid2env>

	//nechce sa mi uz
	if (retperm) {
f0104aa4:	83 c4 10             	add    $0x10,%esp
f0104aa7:	85 c0                	test   %eax,%eax
f0104aa9:	0f 85 cd 04 00 00    	jne    f0104f7c <syscall+0x631>
		return retperm;
	}	

	int pg_insert_check = page_insert(e->env_pgdir, new_page, va, perm);
f0104aaf:	ff 75 14             	pushl  0x14(%ebp)
f0104ab2:	ff 75 10             	pushl  0x10(%ebp)
f0104ab5:	56                   	push   %esi
f0104ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104ab9:	ff 70 68             	pushl  0x68(%eax)
f0104abc:	e8 8e c8 ff ff       	call   f010134f <page_insert>
f0104ac1:	89 c7                	mov    %eax,%edi
	
	if (pg_insert_check) {
f0104ac3:	83 c4 10             	add    $0x10,%esp
f0104ac6:	85 c0                	test   %eax,%eax
f0104ac8:	0f 84 ae 04 00 00    	je     f0104f7c <syscall+0x631>
		page_free(new_page);
f0104ace:	83 ec 0c             	sub    $0xc,%esp
f0104ad1:	56                   	push   %esi
f0104ad2:	e8 3a c5 ff ff       	call   f0101011 <page_free>
f0104ad7:	83 c4 10             	add    $0x10,%esp
		return pg_insert_check;
f0104ada:	89 f8                	mov    %edi,%eax
f0104adc:	e9 9b 04 00 00       	jmp    f0104f7c <syscall+0x631>
	//   allocated!

	// LAB 4: Your code here.
	// check if va is page aligned and isnt above UTOP
	if ((((int)va % PGSIZE) != 0) || ((uintptr_t)va >= UTOP)) {
		return -E_INVAL;
f0104ae1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104ae6:	e9 91 04 00 00       	jmp    f0104f7c <syscall+0x631>
	}
	// check if PTE_P and PTE_U are set (must be set)
	if (((PTE_P | PTE_U) & perm) != (PTE_U | PTE_P)) { 
		return -E_INVAL;
f0104aeb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104af0:	e9 87 04 00 00       	jmp    f0104f7c <syscall+0x631>
	
	int to_check = perm | PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	int available_perm = PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	// check if no other bits hev bin(where the trash goes) set 
	if ((available_perm ^ to_check) != 0) {
		return -E_INVAL;
f0104af5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104afa:	e9 7d 04 00 00       	jmp    f0104f7c <syscall+0x631>
	}

	struct PageInfo *new_page = page_alloc(ALLOC_ZERO);
	// page alloc return null if there are no free pages on page_free_list
	if (!new_page) {
		return -E_NO_MEM;
f0104aff:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104b04:	e9 73 04 00 00       	jmp    f0104f7c <syscall+0x631>
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.

	if ((((int)srcva % PGSIZE) != 0) || ((uintptr_t)srcva >= UTOP)) {
f0104b09:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104b10:	0f 85 d7 00 00 00    	jne    f0104bed <syscall+0x2a2>
f0104b16:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104b1d:	0f 87 ca 00 00 00    	ja     f0104bed <syscall+0x2a2>
		return -E_INVAL;
	}

	if ((((int)dstva % PGSIZE) != 0) || ((uintptr_t)dstva >= UTOP)) {
f0104b23:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0104b2a:	0f 85 c7 00 00 00    	jne    f0104bf7 <syscall+0x2ac>
f0104b30:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104b37:	0f 87 ba 00 00 00    	ja     f0104bf7 <syscall+0x2ac>
		return -E_INVAL;
	}

	if (((PTE_P | PTE_U) & perm) != (PTE_U | PTE_P)) { 
f0104b3d:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0104b40:	83 e0 05             	and    $0x5,%eax
f0104b43:	83 f8 05             	cmp    $0x5,%eax
f0104b46:	0f 85 b5 00 00 00    	jne    f0104c01 <syscall+0x2b6>
	}
	
	int to_check = perm | PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	int available_perm = PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	// check if no other bits have been set 
	if ((available_perm ^ to_check) != 0) {
f0104b4c:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0104b4f:	0d 07 0e 00 00       	or     $0xe07,%eax
f0104b54:	3d 07 0e 00 00       	cmp    $0xe07,%eax
f0104b59:	0f 85 ac 00 00 00    	jne    f0104c0b <syscall+0x2c0>
		return -E_INVAL;
	}

	struct Env *srce;

	int retperm = envid2env(srcenvid, &srce, true);
f0104b5f:	83 ec 04             	sub    $0x4,%esp
f0104b62:	6a 01                	push   $0x1
f0104b64:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104b67:	50                   	push   %eax
f0104b68:	ff 75 0c             	pushl  0xc(%ebp)
f0104b6b:	e8 d5 e4 ff ff       	call   f0103045 <envid2env>
	
	if (retperm == -E_BAD_ENV) {
f0104b70:	83 c4 10             	add    $0x10,%esp
f0104b73:	83 f8 fe             	cmp    $0xfffffffe,%eax
f0104b76:	0f 84 99 00 00 00    	je     f0104c15 <syscall+0x2ca>
		return -E_BAD_ENV;
	}

	struct Env *dste;

	int retperm2 = envid2env(dstenvid, &dste, true);
f0104b7c:	83 ec 04             	sub    $0x4,%esp
f0104b7f:	6a 01                	push   $0x1
f0104b81:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0104b84:	50                   	push   %eax
f0104b85:	ff 75 14             	pushl  0x14(%ebp)
f0104b88:	e8 b8 e4 ff ff       	call   f0103045 <envid2env>
	
	if (retperm2 == -E_BAD_ENV) {
f0104b8d:	83 c4 10             	add    $0x10,%esp
f0104b90:	83 f8 fe             	cmp    $0xfffffffe,%eax
f0104b93:	0f 84 86 00 00 00    	je     f0104c1f <syscall+0x2d4>
		return -E_BAD_ENV;
	}

	pte_t *pte_store;
	struct PageInfo *p = page_lookup(srce->env_pgdir, srcva, &pte_store);
f0104b99:	83 ec 04             	sub    $0x4,%esp
f0104b9c:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104b9f:	50                   	push   %eax
f0104ba0:	ff 75 10             	pushl  0x10(%ebp)
f0104ba3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104ba6:	ff 70 68             	pushl  0x68(%eax)
f0104ba9:	e8 77 c6 ff ff       	call   f0101225 <page_lookup>
	
	if (((perm & PTE_W) == PTE_W) && ((*pte_store & PTE_W) != PTE_W)) {
f0104bae:	83 c4 10             	add    $0x10,%esp
f0104bb1:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104bb5:	74 08                	je     f0104bbf <syscall+0x274>
f0104bb7:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104bba:	f6 02 02             	testb  $0x2,(%edx)
f0104bbd:	74 6a                	je     f0104c29 <syscall+0x2de>
		return -E_INVAL;
	}

	if (!p) {
f0104bbf:	85 c0                	test   %eax,%eax
f0104bc1:	74 70                	je     f0104c33 <syscall+0x2e8>
		return -E_INVAL;	
	}
	
	int pg_insert_check = page_insert(dste->env_pgdir, p, dstva, perm);
f0104bc3:	ff 75 1c             	pushl  0x1c(%ebp)
f0104bc6:	ff 75 18             	pushl  0x18(%ebp)
f0104bc9:	50                   	push   %eax
f0104bca:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104bcd:	ff 70 68             	pushl  0x68(%eax)
f0104bd0:	e8 7a c7 ff ff       	call   f010134f <page_insert>
	
	if (pg_insert_check == -E_NO_MEM) {
f0104bd5:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
	}
	
	return 0;
f0104bd8:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0104bdb:	0f 95 c0             	setne  %al
f0104bde:	0f b6 c0             	movzbl %al,%eax
f0104be1:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
f0104be8:	e9 8f 03 00 00       	jmp    f0104f7c <syscall+0x631>
	//   check the current permissions on the page.

	// LAB 4: Your code here.

	if ((((int)srcva % PGSIZE) != 0) || ((uintptr_t)srcva >= UTOP)) {
		return -E_INVAL;
f0104bed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104bf2:	e9 85 03 00 00       	jmp    f0104f7c <syscall+0x631>
	}

	if ((((int)dstva % PGSIZE) != 0) || ((uintptr_t)dstva >= UTOP)) {
		return -E_INVAL;
f0104bf7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104bfc:	e9 7b 03 00 00       	jmp    f0104f7c <syscall+0x631>
	}

	if (((PTE_P | PTE_U) & perm) != (PTE_U | PTE_P)) { 
		return -E_INVAL;
f0104c01:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104c06:	e9 71 03 00 00       	jmp    f0104f7c <syscall+0x631>
	
	int to_check = perm | PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	int available_perm = PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	// check if no other bits have been set 
	if ((available_perm ^ to_check) != 0) {
		return -E_INVAL;
f0104c0b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104c10:	e9 67 03 00 00       	jmp    f0104f7c <syscall+0x631>
	struct Env *srce;

	int retperm = envid2env(srcenvid, &srce, true);
	
	if (retperm == -E_BAD_ENV) {
		return -E_BAD_ENV;
f0104c15:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104c1a:	e9 5d 03 00 00       	jmp    f0104f7c <syscall+0x631>
	struct Env *dste;

	int retperm2 = envid2env(dstenvid, &dste, true);
	
	if (retperm2 == -E_BAD_ENV) {
		return -E_BAD_ENV;
f0104c1f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104c24:	e9 53 03 00 00       	jmp    f0104f7c <syscall+0x631>

	pte_t *pte_store;
	struct PageInfo *p = page_lookup(srce->env_pgdir, srcva, &pte_store);
	
	if (((perm & PTE_W) == PTE_W) && ((*pte_store & PTE_W) != PTE_W)) {
		return -E_INVAL;
f0104c29:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104c2e:	e9 49 03 00 00       	jmp    f0104f7c <syscall+0x631>
	}

	if (!p) {
		return -E_INVAL;	
f0104c33:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104c38:	e9 3f 03 00 00       	jmp    f0104f7c <syscall+0x631>
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if ((((int)va % PGSIZE) != 0) || ((uintptr_t)va >= UTOP)) {
f0104c3d:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104c44:	75 42                	jne    f0104c88 <syscall+0x33d>
f0104c46:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104c4d:	77 39                	ja     f0104c88 <syscall+0x33d>
		return -E_INVAL;
	}
	
	struct Env *e;
	int perm = envid2env(envid, &e, true);
f0104c4f:	83 ec 04             	sub    $0x4,%esp
f0104c52:	6a 01                	push   $0x1
f0104c54:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104c57:	50                   	push   %eax
f0104c58:	ff 75 0c             	pushl  0xc(%ebp)
f0104c5b:	e8 e5 e3 ff ff       	call   f0103045 <envid2env>
f0104c60:	89 c6                	mov    %eax,%esi
	
	if (perm) {
f0104c62:	83 c4 10             	add    $0x10,%esp
f0104c65:	85 c0                	test   %eax,%eax
f0104c67:	0f 85 0f 03 00 00    	jne    f0104f7c <syscall+0x631>
		return perm;
	}	
	
	page_remove(e->env_pgdir, va);
f0104c6d:	83 ec 08             	sub    $0x8,%esp
f0104c70:	ff 75 10             	pushl  0x10(%ebp)
f0104c73:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104c76:	ff 70 68             	pushl  0x68(%eax)
f0104c79:	e8 63 c6 ff ff       	call   f01012e1 <page_remove>
f0104c7e:	83 c4 10             	add    $0x10,%esp

	return 0;
f0104c81:	89 f0                	mov    %esi,%eax
f0104c83:	e9 f4 02 00 00       	jmp    f0104f7c <syscall+0x631>
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if ((((int)va % PGSIZE) != 0) || ((uintptr_t)va >= UTOP)) {
		return -E_INVAL;
f0104c88:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104c8d:	e9 ea 02 00 00       	jmp    f0104f7c <syscall+0x631>
	// It should be left as env_alloc created it, except that
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.
	struct Env *new_env;
	int env_state =	env_alloc(&new_env, curenv->env_id);
f0104c92:	e8 eb 13 00 00       	call   f0106082 <cpunum>
f0104c97:	83 ec 08             	sub    $0x8,%esp
f0104c9a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c9d:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0104ca3:	ff 70 50             	pushl  0x50(%eax)
f0104ca6:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104ca9:	50                   	push   %eax
f0104caa:	e8 b2 e4 ff ff       	call   f0103161 <env_alloc>

	if (env_state < 0) {
f0104caf:	83 c4 10             	add    $0x10,%esp
f0104cb2:	85 c0                	test   %eax,%eax
f0104cb4:	0f 88 c2 02 00 00    	js     f0104f7c <syscall+0x631>
		return env_state;
	}

	new_env->env_tf = curenv->env_tf;
f0104cba:	8b 7d f4             	mov    -0xc(%ebp),%edi
f0104cbd:	e8 c0 13 00 00       	call   f0106082 <cpunum>
f0104cc2:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cc5:	8b b0 28 30 21 f0    	mov    -0xfdecfd8(%eax),%esi
f0104ccb:	83 c7 08             	add    $0x8,%edi
f0104cce:	83 c6 08             	add    $0x8,%esi
f0104cd1:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104cd6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	new_env->env_status = ENV_NOT_RUNNABLE;
f0104cd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104cdb:	c7 40 5c 04 00 00 00 	movl   $0x4,0x5c(%eax)
	new_env->env_tf.tf_regs.reg_eax = 0;
f0104ce2:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)

	return new_env->env_id;
f0104ce9:	8b 40 50             	mov    0x50(%eax),%eax
f0104cec:	e9 8b 02 00 00       	jmp    f0104f7c <syscall+0x631>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if ((status != ENV_RUNNABLE) && (status != ENV_NOT_RUNNABLE)) {
f0104cf1:	8b 45 10             	mov    0x10(%ebp),%eax
f0104cf4:	83 e8 02             	sub    $0x2,%eax
f0104cf7:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0104cfc:	75 2e                	jne    f0104d2c <syscall+0x3e1>
		return -E_INVAL;
	}

	struct Env *e;

	int perm = envid2env(envid, &e, true); 
f0104cfe:	83 ec 04             	sub    $0x4,%esp
f0104d01:	6a 01                	push   $0x1
f0104d03:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104d06:	50                   	push   %eax
f0104d07:	ff 75 0c             	pushl  0xc(%ebp)
f0104d0a:	e8 36 e3 ff ff       	call   f0103045 <envid2env>
f0104d0f:	89 c2                	mov    %eax,%edx

	if (perm) {
f0104d11:	83 c4 10             	add    $0x10,%esp
f0104d14:	85 c0                	test   %eax,%eax
f0104d16:	0f 85 60 02 00 00    	jne    f0104f7c <syscall+0x631>
		return perm;
	}	

	e->env_status = status;
f0104d1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104d1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104d22:	89 48 5c             	mov    %ecx,0x5c(%eax)

	return 0;
f0104d25:	89 d0                	mov    %edx,%eax
f0104d27:	e9 50 02 00 00       	jmp    f0104f7c <syscall+0x631>
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if ((status != ENV_RUNNABLE) && (status != ENV_NOT_RUNNABLE)) {
		return -E_INVAL;
f0104d2c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104d31:	e9 46 02 00 00       	jmp    f0104f7c <syscall+0x631>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *e;

	int perm = envid2env(envid, &e, true); 
f0104d36:	83 ec 04             	sub    $0x4,%esp
f0104d39:	6a 01                	push   $0x1
f0104d3b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104d3e:	50                   	push   %eax
f0104d3f:	ff 75 0c             	pushl  0xc(%ebp)
f0104d42:	e8 fe e2 ff ff       	call   f0103045 <envid2env>

	if (perm) {
f0104d47:	83 c4 10             	add    $0x10,%esp
f0104d4a:	85 c0                	test   %eax,%eax
f0104d4c:	0f 85 2a 02 00 00    	jne    f0104f7c <syscall+0x631>
		return perm;
	}
	
	e->env_pgfault_upcall = func;
f0104d52:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104d55:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104d58:	89 4a 6c             	mov    %ecx,0x6c(%edx)

		case SYS_env_set_status:
			return sys_env_set_status(a1, a2);

		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1, (void*)a2);
f0104d5b:	e9 1c 02 00 00       	jmp    f0104f7c <syscall+0x631>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104d60:	e8 e4 fa ff ff       	call   f0104849 <sched_yield>
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.

	struct Env *e;
	int env = envid2env(envid, &e, false);
f0104d65:	83 ec 04             	sub    $0x4,%esp
f0104d68:	6a 00                	push   $0x0
f0104d6a:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0104d6d:	50                   	push   %eax
f0104d6e:	ff 75 0c             	pushl  0xc(%ebp)
f0104d71:	e8 cf e2 ff ff       	call   f0103045 <envid2env>
	
	if (env < 0) {
f0104d76:	83 c4 10             	add    $0x10,%esp
f0104d79:	85 c0                	test   %eax,%eax
f0104d7b:	79 08                	jns    f0104d85 <syscall+0x43a>
		return perm;
f0104d7d:	8b 45 18             	mov    0x18(%ebp),%eax
f0104d80:	e9 f7 01 00 00       	jmp    f0104f7c <syscall+0x631>
	}
	
	if (!e->env_ipc_recving) {
f0104d85:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104d88:	80 78 70 00          	cmpb   $0x0,0x70(%eax)
f0104d8c:	0f 84 06 01 00 00    	je     f0104e98 <syscall+0x54d>
		return -E_IPC_NOT_RECV;
	}

	e->env_ipc_perm = 0;
f0104d92:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
f0104d99:	00 00 00 

	if ((uint32_t)srcva < UTOP) {
f0104d9c:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104da3:	0f 87 b3 00 00 00    	ja     f0104e5c <syscall+0x511>
		if (ROUNDDOWN((uint32_t)srcva,PGSIZE) != (uint32_t)srcva) {
			return -E_INVAL;
f0104da9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}

	e->env_ipc_perm = 0;

	if ((uint32_t)srcva < UTOP) {
		if (ROUNDDOWN((uint32_t)srcva,PGSIZE) != (uint32_t)srcva) {
f0104dae:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104db5:	0f 85 c1 01 00 00    	jne    f0104f7c <syscall+0x631>
			return -E_INVAL;
		}

		if (((PTE_P | PTE_U) & perm) != (PTE_U | PTE_P)) { 
f0104dbb:	8b 55 18             	mov    0x18(%ebp),%edx
f0104dbe:	83 e2 05             	and    $0x5,%edx
f0104dc1:	83 fa 05             	cmp    $0x5,%edx
f0104dc4:	0f 85 b2 01 00 00    	jne    f0104f7c <syscall+0x631>
		}
	
		int to_check = perm | PTE_P | PTE_W | PTE_U | PTE_AVAIL;
		int available_perm = PTE_P | PTE_W | PTE_U | PTE_AVAIL;
		// check if no other bits have been set 
		if ((available_perm ^ to_check) != 0) {
f0104dca:	8b 55 18             	mov    0x18(%ebp),%edx
f0104dcd:	81 ca 07 0e 00 00    	or     $0xe07,%edx
f0104dd3:	81 fa 07 0e 00 00    	cmp    $0xe07,%edx
f0104dd9:	0f 85 9d 01 00 00    	jne    f0104f7c <syscall+0x631>
			return -E_INVAL;
		}

		pte_t *pte_store;
		struct PageInfo *p = page_lookup(curenv->env_pgdir, srcva, 							 &pte_store);
f0104ddf:	e8 9e 12 00 00       	call   f0106082 <cpunum>
f0104de4:	83 ec 04             	sub    $0x4,%esp
f0104de7:	8d 55 f4             	lea    -0xc(%ebp),%edx
f0104dea:	52                   	push   %edx
f0104deb:	ff 75 14             	pushl  0x14(%ebp)
f0104dee:	6b c0 74             	imul   $0x74,%eax,%eax
f0104df1:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0104df7:	ff 70 68             	pushl  0x68(%eax)
f0104dfa:	e8 26 c4 ff ff       	call   f0101225 <page_lookup>
f0104dff:	89 c1                	mov    %eax,%ecx
	
		if (((perm & PTE_W) == PTE_W) && ((*pte_store & PTE_W) != PTE_W)) {
f0104e01:	83 c4 10             	add    $0x10,%esp
f0104e04:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104e08:	74 11                	je     f0104e1b <syscall+0x4d0>
			return -E_INVAL;
f0104e0a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}

		pte_t *pte_store;
		struct PageInfo *p = page_lookup(curenv->env_pgdir, srcva, 							 &pte_store);
	
		if (((perm & PTE_W) == PTE_W) && ((*pte_store & PTE_W) != PTE_W)) {
f0104e0f:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104e12:	f6 02 02             	testb  $0x2,(%edx)
f0104e15:	0f 84 61 01 00 00    	je     f0104f7c <syscall+0x631>
			return -E_INVAL;
		}

		if (!p) {
f0104e1b:	85 c9                	test   %ecx,%ecx
f0104e1d:	74 33                	je     f0104e52 <syscall+0x507>
			return -E_INVAL;	
		}

		if ((uint32_t)e->env_ipc_dstva < UTOP){
f0104e1f:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0104e22:	8b 42 74             	mov    0x74(%edx),%eax
f0104e25:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f0104e2a:	77 30                	ja     f0104e5c <syscall+0x511>
			int pg_insert_check = page_insert(e->env_pgdir, p,
f0104e2c:	ff 75 18             	pushl  0x18(%ebp)
f0104e2f:	50                   	push   %eax
f0104e30:	51                   	push   %ecx
f0104e31:	ff 72 68             	pushl  0x68(%edx)
f0104e34:	e8 16 c5 ff ff       	call   f010134f <page_insert>
	 				          e->env_ipc_dstva, perm);
	
			if (pg_insert_check < 0) {
f0104e39:	83 c4 10             	add    $0x10,%esp
f0104e3c:	85 c0                	test   %eax,%eax
f0104e3e:	0f 88 38 01 00 00    	js     f0104f7c <syscall+0x631>
				return pg_insert_check;
			}

			e->env_ipc_perm = perm;
f0104e44:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104e47:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0104e4a:	89 88 80 00 00 00    	mov    %ecx,0x80(%eax)
f0104e50:	eb 0a                	jmp    f0104e5c <syscall+0x511>
		if (((perm & PTE_W) == PTE_W) && ((*pte_store & PTE_W) != PTE_W)) {
			return -E_INVAL;
		}

		if (!p) {
			return -E_INVAL;	
f0104e52:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104e57:	e9 20 01 00 00       	jmp    f0104f7c <syscall+0x631>

			e->env_ipc_perm = perm;
		}
	}

	e->env_ipc_recving = false;
f0104e5c:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0104e5f:	c6 46 70 00          	movb   $0x0,0x70(%esi)
	e->env_ipc_from = curenv->env_id;
f0104e63:	e8 1a 12 00 00       	call   f0106082 <cpunum>
f0104e68:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e6b:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0104e71:	8b 40 50             	mov    0x50(%eax),%eax
f0104e74:	89 46 7c             	mov    %eax,0x7c(%esi)
	e->env_ipc_value = value;
f0104e77:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104e7a:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104e7d:	89 78 78             	mov    %edi,0x78(%eax)
	e->env_status = ENV_RUNNABLE;
f0104e80:	c7 40 5c 02 00 00 00 	movl   $0x2,0x5c(%eax)
	e->env_tf.tf_regs.reg_eax = 0;
f0104e87:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)

	return 0;
f0104e8e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e93:	e9 e4 00 00 00       	jmp    f0104f7c <syscall+0x631>
	if (env < 0) {
		return perm;
	}
	
	if (!e->env_ipc_recving) {
		return -E_IPC_NOT_RECV;
f0104e98:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
		case SYS_yield:
			sys_yield();
			return 0;

		case SYS_ipc_try_send:
			return sys_ipc_try_send(a1, a2, (void*)a3, a4);
f0104e9d:	e9 da 00 00 00       	jmp    f0104f7c <syscall+0x631>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if ((uint32_t)dstva < UTOP) {
f0104ea2:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104ea9:	77 0d                	ja     f0104eb8 <syscall+0x56d>
		if (ROUNDDOWN((uint32_t)dstva, PGSIZE) != (uint32_t)dstva) {
f0104eab:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104eb2:	0f 85 bf 00 00 00    	jne    f0104f77 <syscall+0x62c>
			return -E_INVAL;
		}
	}
	curenv->env_ipc_recving = true;	
f0104eb8:	e8 c5 11 00 00       	call   f0106082 <cpunum>
f0104ebd:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ec0:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0104ec6:	c6 40 70 01          	movb   $0x1,0x70(%eax)
	curenv->env_ipc_dstva = dstva;
f0104eca:	e8 b3 11 00 00       	call   f0106082 <cpunum>
f0104ecf:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ed2:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0104ed8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104edb:	89 48 74             	mov    %ecx,0x74(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104ede:	e8 9f 11 00 00       	call   f0106082 <cpunum>
f0104ee3:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ee6:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0104eec:	c7 40 5c 04 00 00 00 	movl   $0x4,0x5c(%eax)
	curenv->env_tf.tf_regs.reg_eax = 0;
f0104ef3:	e8 8a 11 00 00       	call   f0106082 <cpunum>
f0104ef8:	6b c0 74             	imul   $0x74,%eax,%eax
f0104efb:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0104f01:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104f08:	e8 3c f9 ff ff       	call   f0104849 <sched_yield>
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!

	struct Env *e; 
	int env = envid2env(envid, &e, 1);
f0104f0d:	83 ec 04             	sub    $0x4,%esp
f0104f10:	6a 01                	push   $0x1
f0104f12:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104f15:	50                   	push   %eax
f0104f16:	ff 75 0c             	pushl  0xc(%ebp)
f0104f19:	e8 27 e1 ff ff       	call   f0103045 <envid2env>

	if (env < 0) { 
f0104f1e:	83 c4 10             	add    $0x10,%esp
f0104f21:	85 c0                	test   %eax,%eax
f0104f23:	78 57                	js     f0104f7c <syscall+0x631>
		return env;
	}

	user_mem_assert(e, tf, sizeof(struct Trapframe), PTE_U);
f0104f25:	6a 04                	push   $0x4
f0104f27:	6a 44                	push   $0x44
f0104f29:	ff 75 10             	pushl  0x10(%ebp)
f0104f2c:	ff 75 f4             	pushl  -0xc(%ebp)
f0104f2f:	e8 41 e0 ff ff       	call   f0102f75 <user_mem_assert>

	e->env_tf = *tf;
f0104f34:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104f37:	8d 7a 08             	lea    0x8(%edx),%edi
f0104f3a:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104f3f:	8b 75 10             	mov    0x10(%ebp),%esi
f0104f42:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_tf.tf_eflags |= FL_IF;
	e->env_tf.tf_cs = GD_UT | 3;
f0104f44:	66 c7 42 3c 1b 00    	movw   $0x1b,0x3c(%edx)
	//shoutout to fgt(x)
	e->env_tf.tf_eflags &= ~FL_IOPL_3;
f0104f4a:	8b 42 40             	mov    0x40(%edx),%eax
f0104f4d:	80 e4 cf             	and    $0xcf,%ah
f0104f50:	80 cc 02             	or     $0x2,%ah
f0104f53:	89 42 40             	mov    %eax,0x40(%edx)
f0104f56:	83 c4 10             	add    $0x10,%esp

	return 0;
f0104f59:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f5e:	eb 1c                	jmp    f0104f7c <syscall+0x631>

// LAB 7 Multithreading
		case SYS_thread_create:
			//void (*func)() = (void(*)())a1;
			//return sys_thread_create((void(*)())a1/*func*/);
			return sys_thread_create((uintptr_t) a1);
f0104f60:	83 ec 0c             	sub    $0xc,%esp
f0104f63:	ff 75 0c             	pushl  0xc(%ebp)
f0104f66:	e8 be f9 ff ff       	call   f0104929 <sys_thread_create>
f0104f6b:	83 c4 10             	add    $0x10,%esp
f0104f6e:	eb 0c                	jmp    f0104f7c <syscall+0x631>

		default:
			return -E_INVAL;
f0104f70:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104f75:	eb 05                	jmp    f0104f7c <syscall+0x631>

		case SYS_ipc_try_send:
			return sys_ipc_try_send(a1, a2, (void*)a3, a4);

		case SYS_ipc_recv:
			return sys_ipc_recv((void*)a1);
f0104f77:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			return sys_thread_create((uintptr_t) a1);

		default:
			return -E_INVAL;
	}
}
f0104f7c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104f7f:	5e                   	pop    %esi
f0104f80:	5f                   	pop    %edi
f0104f81:	5d                   	pop    %ebp
f0104f82:	c3                   	ret    

f0104f83 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104f83:	55                   	push   %ebp
f0104f84:	89 e5                	mov    %esp,%ebp
f0104f86:	57                   	push   %edi
f0104f87:	56                   	push   %esi
f0104f88:	53                   	push   %ebx
f0104f89:	83 ec 14             	sub    $0x14,%esp
f0104f8c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104f8f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104f92:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104f95:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104f98:	8b 1a                	mov    (%edx),%ebx
f0104f9a:	8b 01                	mov    (%ecx),%eax
f0104f9c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104f9f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104fa6:	eb 7f                	jmp    f0105027 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0104fa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104fab:	01 d8                	add    %ebx,%eax
f0104fad:	89 c6                	mov    %eax,%esi
f0104faf:	c1 ee 1f             	shr    $0x1f,%esi
f0104fb2:	01 c6                	add    %eax,%esi
f0104fb4:	d1 fe                	sar    %esi
f0104fb6:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104fb9:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104fbc:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104fbf:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104fc1:	eb 03                	jmp    f0104fc6 <stab_binsearch+0x43>
			m--;
f0104fc3:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104fc6:	39 c3                	cmp    %eax,%ebx
f0104fc8:	7f 0d                	jg     f0104fd7 <stab_binsearch+0x54>
f0104fca:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104fce:	83 ea 0c             	sub    $0xc,%edx
f0104fd1:	39 f9                	cmp    %edi,%ecx
f0104fd3:	75 ee                	jne    f0104fc3 <stab_binsearch+0x40>
f0104fd5:	eb 05                	jmp    f0104fdc <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104fd7:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104fda:	eb 4b                	jmp    f0105027 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104fdc:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104fdf:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104fe2:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104fe6:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104fe9:	76 11                	jbe    f0104ffc <stab_binsearch+0x79>
			*region_left = m;
f0104feb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104fee:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104ff0:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104ff3:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104ffa:	eb 2b                	jmp    f0105027 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104ffc:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104fff:	73 14                	jae    f0105015 <stab_binsearch+0x92>
			*region_right = m - 1;
f0105001:	83 e8 01             	sub    $0x1,%eax
f0105004:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105007:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010500a:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010500c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105013:	eb 12                	jmp    f0105027 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0105015:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105018:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f010501a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010501e:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105020:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0105027:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f010502a:	0f 8e 78 ff ff ff    	jle    f0104fa8 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0105030:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0105034:	75 0f                	jne    f0105045 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0105036:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105039:	8b 00                	mov    (%eax),%eax
f010503b:	83 e8 01             	sub    $0x1,%eax
f010503e:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105041:	89 06                	mov    %eax,(%esi)
f0105043:	eb 2c                	jmp    f0105071 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105045:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105048:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f010504a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010504d:	8b 0e                	mov    (%esi),%ecx
f010504f:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105052:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0105055:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105058:	eb 03                	jmp    f010505d <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f010505a:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010505d:	39 c8                	cmp    %ecx,%eax
f010505f:	7e 0b                	jle    f010506c <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0105061:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0105065:	83 ea 0c             	sub    $0xc,%edx
f0105068:	39 df                	cmp    %ebx,%edi
f010506a:	75 ee                	jne    f010505a <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f010506c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010506f:	89 06                	mov    %eax,(%esi)
	}
}
f0105071:	83 c4 14             	add    $0x14,%esp
f0105074:	5b                   	pop    %ebx
f0105075:	5e                   	pop    %esi
f0105076:	5f                   	pop    %edi
f0105077:	5d                   	pop    %ebp
f0105078:	c3                   	ret    

f0105079 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0105079:	55                   	push   %ebp
f010507a:	89 e5                	mov    %esp,%ebp
f010507c:	57                   	push   %edi
f010507d:	56                   	push   %esi
f010507e:	53                   	push   %ebx
f010507f:	83 ec 3c             	sub    $0x3c,%esp
f0105082:	8b 75 08             	mov    0x8(%ebp),%esi
f0105085:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0105088:	c7 03 90 7f 10 f0    	movl   $0xf0107f90,(%ebx)
	info->eip_line = 0;
f010508e:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0105095:	c7 43 08 90 7f 10 f0 	movl   $0xf0107f90,0x8(%ebx)
	info->eip_fn_namelen = 9;
f010509c:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01050a3:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01050a6:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01050ad:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01050b3:	77 21                	ja     f01050d6 <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f01050b5:	a1 00 00 20 00       	mov    0x200000,%eax
f01050ba:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stab_end = usd->stab_end;
f01050bd:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f01050c2:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f01050c8:	89 7d b8             	mov    %edi,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f01050cb:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f01050d1:	89 7d c0             	mov    %edi,-0x40(%ebp)
f01050d4:	eb 1a                	jmp    f01050f0 <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01050d6:	c7 45 c0 44 64 11 f0 	movl   $0xf0116444,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01050dd:	c7 45 b8 8d 2b 11 f0 	movl   $0xf0112b8d,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01050e4:	b8 8c 2b 11 f0       	mov    $0xf0112b8c,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01050e9:	c7 45 bc 30 85 10 f0 	movl   $0xf0108530,-0x44(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01050f0:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01050f3:	39 7d b8             	cmp    %edi,-0x48(%ebp)
f01050f6:	0f 83 95 01 00 00    	jae    f0105291 <debuginfo_eip+0x218>
f01050fc:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f0105100:	0f 85 92 01 00 00    	jne    f0105298 <debuginfo_eip+0x21f>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105106:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010510d:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0105110:	29 f8                	sub    %edi,%eax
f0105112:	c1 f8 02             	sar    $0x2,%eax
f0105115:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010511b:	83 e8 01             	sub    $0x1,%eax
f010511e:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105121:	56                   	push   %esi
f0105122:	6a 64                	push   $0x64
f0105124:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0105127:	89 c1                	mov    %eax,%ecx
f0105129:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010512c:	89 f8                	mov    %edi,%eax
f010512e:	e8 50 fe ff ff       	call   f0104f83 <stab_binsearch>
	if (lfile == 0)
f0105133:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105136:	83 c4 08             	add    $0x8,%esp
f0105139:	85 c0                	test   %eax,%eax
f010513b:	0f 84 5e 01 00 00    	je     f010529f <debuginfo_eip+0x226>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105141:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0105144:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105147:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010514a:	56                   	push   %esi
f010514b:	6a 24                	push   $0x24
f010514d:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0105150:	89 c1                	mov    %eax,%ecx
f0105152:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105155:	89 f8                	mov    %edi,%eax
f0105157:	e8 27 fe ff ff       	call   f0104f83 <stab_binsearch>

	if (lfun <= rfun) {
f010515c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010515f:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105162:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0105165:	83 c4 08             	add    $0x8,%esp
f0105168:	39 d0                	cmp    %edx,%eax
f010516a:	7f 2b                	jg     f0105197 <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010516c:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010516f:	8d 0c 97             	lea    (%edi,%edx,4),%ecx
f0105172:	8b 11                	mov    (%ecx),%edx
f0105174:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0105177:	2b 7d b8             	sub    -0x48(%ebp),%edi
f010517a:	39 fa                	cmp    %edi,%edx
f010517c:	73 06                	jae    f0105184 <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010517e:	03 55 b8             	add    -0x48(%ebp),%edx
f0105181:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0105184:	8b 51 08             	mov    0x8(%ecx),%edx
f0105187:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f010518a:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f010518c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f010518f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105192:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105195:	eb 0f                	jmp    f01051a6 <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0105197:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010519a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010519d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01051a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01051a3:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01051a6:	83 ec 08             	sub    $0x8,%esp
f01051a9:	6a 3a                	push   $0x3a
f01051ab:	ff 73 08             	pushl  0x8(%ebx)
f01051ae:	e8 92 08 00 00       	call   f0105a45 <strfind>
f01051b3:	2b 43 08             	sub    0x8(%ebx),%eax
f01051b6:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01051b9:	83 c4 08             	add    $0x8,%esp
f01051bc:	56                   	push   %esi
f01051bd:	6a 44                	push   $0x44
f01051bf:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01051c2:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01051c5:	8b 75 bc             	mov    -0x44(%ebp),%esi
f01051c8:	89 f0                	mov    %esi,%eax
f01051ca:	e8 b4 fd ff ff       	call   f0104f83 <stab_binsearch>
	if (lline == rline) {
f01051cf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01051d2:	83 c4 10             	add    $0x10,%esp
f01051d5:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f01051d8:	0f 85 c8 00 00 00    	jne    f01052a6 <debuginfo_eip+0x22d>
		info->eip_line = stabs[lline].n_desc;
f01051de:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01051e1:	8d 14 96             	lea    (%esi,%edx,4),%edx
f01051e4:	0f b7 4a 06          	movzwl 0x6(%edx),%ecx
f01051e8:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01051eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01051ee:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f01051f2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01051f5:	eb 0a                	jmp    f0105201 <debuginfo_eip+0x188>
f01051f7:	83 e8 01             	sub    $0x1,%eax
f01051fa:	83 ea 0c             	sub    $0xc,%edx
f01051fd:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0105201:	39 c7                	cmp    %eax,%edi
f0105203:	7e 05                	jle    f010520a <debuginfo_eip+0x191>
f0105205:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105208:	eb 47                	jmp    f0105251 <debuginfo_eip+0x1d8>
	       && stabs[lline].n_type != N_SOL
f010520a:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010520e:	80 f9 84             	cmp    $0x84,%cl
f0105211:	75 0e                	jne    f0105221 <debuginfo_eip+0x1a8>
f0105213:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105216:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f010521a:	74 1c                	je     f0105238 <debuginfo_eip+0x1bf>
f010521c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010521f:	eb 17                	jmp    f0105238 <debuginfo_eip+0x1bf>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105221:	80 f9 64             	cmp    $0x64,%cl
f0105224:	75 d1                	jne    f01051f7 <debuginfo_eip+0x17e>
f0105226:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f010522a:	74 cb                	je     f01051f7 <debuginfo_eip+0x17e>
f010522c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010522f:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0105233:	74 03                	je     f0105238 <debuginfo_eip+0x1bf>
f0105235:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105238:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010523b:	8b 75 bc             	mov    -0x44(%ebp),%esi
f010523e:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0105241:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0105244:	8b 75 b8             	mov    -0x48(%ebp),%esi
f0105247:	29 f0                	sub    %esi,%eax
f0105249:	39 c2                	cmp    %eax,%edx
f010524b:	73 04                	jae    f0105251 <debuginfo_eip+0x1d8>
		info->eip_file = stabstr + stabs[lline].n_strx;
f010524d:	01 f2                	add    %esi,%edx
f010524f:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105251:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105254:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105257:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010525c:	39 f2                	cmp    %esi,%edx
f010525e:	7d 52                	jge    f01052b2 <debuginfo_eip+0x239>
		for (lline = lfun + 1;
f0105260:	83 c2 01             	add    $0x1,%edx
f0105263:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105266:	89 d0                	mov    %edx,%eax
f0105268:	8d 14 52             	lea    (%edx,%edx,2),%edx
f010526b:	8b 7d bc             	mov    -0x44(%ebp),%edi
f010526e:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0105271:	eb 04                	jmp    f0105277 <debuginfo_eip+0x1fe>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0105273:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105277:	39 c6                	cmp    %eax,%esi
f0105279:	7e 32                	jle    f01052ad <debuginfo_eip+0x234>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010527b:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010527f:	83 c0 01             	add    $0x1,%eax
f0105282:	83 c2 0c             	add    $0xc,%edx
f0105285:	80 f9 a0             	cmp    $0xa0,%cl
f0105288:	74 e9                	je     f0105273 <debuginfo_eip+0x1fa>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010528a:	b8 00 00 00 00       	mov    $0x0,%eax
f010528f:	eb 21                	jmp    f01052b2 <debuginfo_eip+0x239>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0105291:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105296:	eb 1a                	jmp    f01052b2 <debuginfo_eip+0x239>
f0105298:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010529d:	eb 13                	jmp    f01052b2 <debuginfo_eip+0x239>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f010529f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01052a4:	eb 0c                	jmp    f01052b2 <debuginfo_eip+0x239>
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline == rline) {
		info->eip_line = stabs[lline].n_desc;
	} else {
		return -1;	
f01052a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01052ab:	eb 05                	jmp    f01052b2 <debuginfo_eip+0x239>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01052ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01052b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01052b5:	5b                   	pop    %ebx
f01052b6:	5e                   	pop    %esi
f01052b7:	5f                   	pop    %edi
f01052b8:	5d                   	pop    %ebp
f01052b9:	c3                   	ret    

f01052ba <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01052ba:	55                   	push   %ebp
f01052bb:	89 e5                	mov    %esp,%ebp
f01052bd:	57                   	push   %edi
f01052be:	56                   	push   %esi
f01052bf:	53                   	push   %ebx
f01052c0:	83 ec 1c             	sub    $0x1c,%esp
f01052c3:	89 c7                	mov    %eax,%edi
f01052c5:	89 d6                	mov    %edx,%esi
f01052c7:	8b 45 08             	mov    0x8(%ebp),%eax
f01052ca:	8b 55 0c             	mov    0xc(%ebp),%edx
f01052cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01052d0:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01052d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01052d6:	bb 00 00 00 00       	mov    $0x0,%ebx
f01052db:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01052de:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f01052e1:	39 d3                	cmp    %edx,%ebx
f01052e3:	72 05                	jb     f01052ea <printnum+0x30>
f01052e5:	39 45 10             	cmp    %eax,0x10(%ebp)
f01052e8:	77 45                	ja     f010532f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01052ea:	83 ec 0c             	sub    $0xc,%esp
f01052ed:	ff 75 18             	pushl  0x18(%ebp)
f01052f0:	8b 45 14             	mov    0x14(%ebp),%eax
f01052f3:	8d 58 ff             	lea    -0x1(%eax),%ebx
f01052f6:	53                   	push   %ebx
f01052f7:	ff 75 10             	pushl  0x10(%ebp)
f01052fa:	83 ec 08             	sub    $0x8,%esp
f01052fd:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105300:	ff 75 e0             	pushl  -0x20(%ebp)
f0105303:	ff 75 dc             	pushl  -0x24(%ebp)
f0105306:	ff 75 d8             	pushl  -0x28(%ebp)
f0105309:	e8 72 11 00 00       	call   f0106480 <__udivdi3>
f010530e:	83 c4 18             	add    $0x18,%esp
f0105311:	52                   	push   %edx
f0105312:	50                   	push   %eax
f0105313:	89 f2                	mov    %esi,%edx
f0105315:	89 f8                	mov    %edi,%eax
f0105317:	e8 9e ff ff ff       	call   f01052ba <printnum>
f010531c:	83 c4 20             	add    $0x20,%esp
f010531f:	eb 18                	jmp    f0105339 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105321:	83 ec 08             	sub    $0x8,%esp
f0105324:	56                   	push   %esi
f0105325:	ff 75 18             	pushl  0x18(%ebp)
f0105328:	ff d7                	call   *%edi
f010532a:	83 c4 10             	add    $0x10,%esp
f010532d:	eb 03                	jmp    f0105332 <printnum+0x78>
f010532f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105332:	83 eb 01             	sub    $0x1,%ebx
f0105335:	85 db                	test   %ebx,%ebx
f0105337:	7f e8                	jg     f0105321 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105339:	83 ec 08             	sub    $0x8,%esp
f010533c:	56                   	push   %esi
f010533d:	83 ec 04             	sub    $0x4,%esp
f0105340:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105343:	ff 75 e0             	pushl  -0x20(%ebp)
f0105346:	ff 75 dc             	pushl  -0x24(%ebp)
f0105349:	ff 75 d8             	pushl  -0x28(%ebp)
f010534c:	e8 5f 12 00 00       	call   f01065b0 <__umoddi3>
f0105351:	83 c4 14             	add    $0x14,%esp
f0105354:	0f be 80 9a 7f 10 f0 	movsbl -0xfef8066(%eax),%eax
f010535b:	50                   	push   %eax
f010535c:	ff d7                	call   *%edi
}
f010535e:	83 c4 10             	add    $0x10,%esp
f0105361:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105364:	5b                   	pop    %ebx
f0105365:	5e                   	pop    %esi
f0105366:	5f                   	pop    %edi
f0105367:	5d                   	pop    %ebp
f0105368:	c3                   	ret    

f0105369 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105369:	55                   	push   %ebp
f010536a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f010536c:	83 fa 01             	cmp    $0x1,%edx
f010536f:	7e 0e                	jle    f010537f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0105371:	8b 10                	mov    (%eax),%edx
f0105373:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105376:	89 08                	mov    %ecx,(%eax)
f0105378:	8b 02                	mov    (%edx),%eax
f010537a:	8b 52 04             	mov    0x4(%edx),%edx
f010537d:	eb 22                	jmp    f01053a1 <getuint+0x38>
	else if (lflag)
f010537f:	85 d2                	test   %edx,%edx
f0105381:	74 10                	je     f0105393 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105383:	8b 10                	mov    (%eax),%edx
f0105385:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105388:	89 08                	mov    %ecx,(%eax)
f010538a:	8b 02                	mov    (%edx),%eax
f010538c:	ba 00 00 00 00       	mov    $0x0,%edx
f0105391:	eb 0e                	jmp    f01053a1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105393:	8b 10                	mov    (%eax),%edx
f0105395:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105398:	89 08                	mov    %ecx,(%eax)
f010539a:	8b 02                	mov    (%edx),%eax
f010539c:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01053a1:	5d                   	pop    %ebp
f01053a2:	c3                   	ret    

f01053a3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01053a3:	55                   	push   %ebp
f01053a4:	89 e5                	mov    %esp,%ebp
f01053a6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01053a9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01053ad:	8b 10                	mov    (%eax),%edx
f01053af:	3b 50 04             	cmp    0x4(%eax),%edx
f01053b2:	73 0a                	jae    f01053be <sprintputch+0x1b>
		*b->buf++ = ch;
f01053b4:	8d 4a 01             	lea    0x1(%edx),%ecx
f01053b7:	89 08                	mov    %ecx,(%eax)
f01053b9:	8b 45 08             	mov    0x8(%ebp),%eax
f01053bc:	88 02                	mov    %al,(%edx)
}
f01053be:	5d                   	pop    %ebp
f01053bf:	c3                   	ret    

f01053c0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01053c0:	55                   	push   %ebp
f01053c1:	89 e5                	mov    %esp,%ebp
f01053c3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01053c6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01053c9:	50                   	push   %eax
f01053ca:	ff 75 10             	pushl  0x10(%ebp)
f01053cd:	ff 75 0c             	pushl  0xc(%ebp)
f01053d0:	ff 75 08             	pushl  0x8(%ebp)
f01053d3:	e8 05 00 00 00       	call   f01053dd <vprintfmt>
	va_end(ap);
}
f01053d8:	83 c4 10             	add    $0x10,%esp
f01053db:	c9                   	leave  
f01053dc:	c3                   	ret    

f01053dd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01053dd:	55                   	push   %ebp
f01053de:	89 e5                	mov    %esp,%ebp
f01053e0:	57                   	push   %edi
f01053e1:	56                   	push   %esi
f01053e2:	53                   	push   %ebx
f01053e3:	83 ec 2c             	sub    $0x2c,%esp
f01053e6:	8b 75 08             	mov    0x8(%ebp),%esi
f01053e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01053ec:	8b 7d 10             	mov    0x10(%ebp),%edi
f01053ef:	eb 12                	jmp    f0105403 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01053f1:	85 c0                	test   %eax,%eax
f01053f3:	0f 84 89 03 00 00    	je     f0105782 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f01053f9:	83 ec 08             	sub    $0x8,%esp
f01053fc:	53                   	push   %ebx
f01053fd:	50                   	push   %eax
f01053fe:	ff d6                	call   *%esi
f0105400:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105403:	83 c7 01             	add    $0x1,%edi
f0105406:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010540a:	83 f8 25             	cmp    $0x25,%eax
f010540d:	75 e2                	jne    f01053f1 <vprintfmt+0x14>
f010540f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0105413:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f010541a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105421:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0105428:	ba 00 00 00 00       	mov    $0x0,%edx
f010542d:	eb 07                	jmp    f0105436 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010542f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0105432:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105436:	8d 47 01             	lea    0x1(%edi),%eax
f0105439:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010543c:	0f b6 07             	movzbl (%edi),%eax
f010543f:	0f b6 c8             	movzbl %al,%ecx
f0105442:	83 e8 23             	sub    $0x23,%eax
f0105445:	3c 55                	cmp    $0x55,%al
f0105447:	0f 87 1a 03 00 00    	ja     f0105767 <vprintfmt+0x38a>
f010544d:	0f b6 c0             	movzbl %al,%eax
f0105450:	ff 24 85 e0 80 10 f0 	jmp    *-0xfef7f20(,%eax,4)
f0105457:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f010545a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f010545e:	eb d6                	jmp    f0105436 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105460:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105463:	b8 00 00 00 00       	mov    $0x0,%eax
f0105468:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f010546b:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010546e:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0105472:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0105475:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0105478:	83 fa 09             	cmp    $0x9,%edx
f010547b:	77 39                	ja     f01054b6 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010547d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0105480:	eb e9                	jmp    f010546b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105482:	8b 45 14             	mov    0x14(%ebp),%eax
f0105485:	8d 48 04             	lea    0x4(%eax),%ecx
f0105488:	89 4d 14             	mov    %ecx,0x14(%ebp)
f010548b:	8b 00                	mov    (%eax),%eax
f010548d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105490:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105493:	eb 27                	jmp    f01054bc <vprintfmt+0xdf>
f0105495:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105498:	85 c0                	test   %eax,%eax
f010549a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010549f:	0f 49 c8             	cmovns %eax,%ecx
f01054a2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01054a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01054a8:	eb 8c                	jmp    f0105436 <vprintfmt+0x59>
f01054aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01054ad:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f01054b4:	eb 80                	jmp    f0105436 <vprintfmt+0x59>
f01054b6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01054b9:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f01054bc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01054c0:	0f 89 70 ff ff ff    	jns    f0105436 <vprintfmt+0x59>
				width = precision, precision = -1;
f01054c6:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01054c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01054cc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01054d3:	e9 5e ff ff ff       	jmp    f0105436 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01054d8:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01054db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01054de:	e9 53 ff ff ff       	jmp    f0105436 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01054e3:	8b 45 14             	mov    0x14(%ebp),%eax
f01054e6:	8d 50 04             	lea    0x4(%eax),%edx
f01054e9:	89 55 14             	mov    %edx,0x14(%ebp)
f01054ec:	83 ec 08             	sub    $0x8,%esp
f01054ef:	53                   	push   %ebx
f01054f0:	ff 30                	pushl  (%eax)
f01054f2:	ff d6                	call   *%esi
			break;
f01054f4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01054f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01054fa:	e9 04 ff ff ff       	jmp    f0105403 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01054ff:	8b 45 14             	mov    0x14(%ebp),%eax
f0105502:	8d 50 04             	lea    0x4(%eax),%edx
f0105505:	89 55 14             	mov    %edx,0x14(%ebp)
f0105508:	8b 00                	mov    (%eax),%eax
f010550a:	99                   	cltd   
f010550b:	31 d0                	xor    %edx,%eax
f010550d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010550f:	83 f8 0f             	cmp    $0xf,%eax
f0105512:	7f 0b                	jg     f010551f <vprintfmt+0x142>
f0105514:	8b 14 85 40 82 10 f0 	mov    -0xfef7dc0(,%eax,4),%edx
f010551b:	85 d2                	test   %edx,%edx
f010551d:	75 18                	jne    f0105537 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f010551f:	50                   	push   %eax
f0105520:	68 b2 7f 10 f0       	push   $0xf0107fb2
f0105525:	53                   	push   %ebx
f0105526:	56                   	push   %esi
f0105527:	e8 94 fe ff ff       	call   f01053c0 <printfmt>
f010552c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010552f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0105532:	e9 cc fe ff ff       	jmp    f0105403 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0105537:	52                   	push   %edx
f0105538:	68 49 76 10 f0       	push   $0xf0107649
f010553d:	53                   	push   %ebx
f010553e:	56                   	push   %esi
f010553f:	e8 7c fe ff ff       	call   f01053c0 <printfmt>
f0105544:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105547:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010554a:	e9 b4 fe ff ff       	jmp    f0105403 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f010554f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105552:	8d 50 04             	lea    0x4(%eax),%edx
f0105555:	89 55 14             	mov    %edx,0x14(%ebp)
f0105558:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f010555a:	85 ff                	test   %edi,%edi
f010555c:	b8 ab 7f 10 f0       	mov    $0xf0107fab,%eax
f0105561:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0105564:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105568:	0f 8e 94 00 00 00    	jle    f0105602 <vprintfmt+0x225>
f010556e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0105572:	0f 84 98 00 00 00    	je     f0105610 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105578:	83 ec 08             	sub    $0x8,%esp
f010557b:	ff 75 d0             	pushl  -0x30(%ebp)
f010557e:	57                   	push   %edi
f010557f:	e8 77 03 00 00       	call   f01058fb <strnlen>
f0105584:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105587:	29 c1                	sub    %eax,%ecx
f0105589:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f010558c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f010558f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0105593:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105596:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105599:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010559b:	eb 0f                	jmp    f01055ac <vprintfmt+0x1cf>
					putch(padc, putdat);
f010559d:	83 ec 08             	sub    $0x8,%esp
f01055a0:	53                   	push   %ebx
f01055a1:	ff 75 e0             	pushl  -0x20(%ebp)
f01055a4:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01055a6:	83 ef 01             	sub    $0x1,%edi
f01055a9:	83 c4 10             	add    $0x10,%esp
f01055ac:	85 ff                	test   %edi,%edi
f01055ae:	7f ed                	jg     f010559d <vprintfmt+0x1c0>
f01055b0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01055b3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01055b6:	85 c9                	test   %ecx,%ecx
f01055b8:	b8 00 00 00 00       	mov    $0x0,%eax
f01055bd:	0f 49 c1             	cmovns %ecx,%eax
f01055c0:	29 c1                	sub    %eax,%ecx
f01055c2:	89 75 08             	mov    %esi,0x8(%ebp)
f01055c5:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01055c8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01055cb:	89 cb                	mov    %ecx,%ebx
f01055cd:	eb 4d                	jmp    f010561c <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01055cf:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01055d3:	74 1b                	je     f01055f0 <vprintfmt+0x213>
f01055d5:	0f be c0             	movsbl %al,%eax
f01055d8:	83 e8 20             	sub    $0x20,%eax
f01055db:	83 f8 5e             	cmp    $0x5e,%eax
f01055de:	76 10                	jbe    f01055f0 <vprintfmt+0x213>
					putch('?', putdat);
f01055e0:	83 ec 08             	sub    $0x8,%esp
f01055e3:	ff 75 0c             	pushl  0xc(%ebp)
f01055e6:	6a 3f                	push   $0x3f
f01055e8:	ff 55 08             	call   *0x8(%ebp)
f01055eb:	83 c4 10             	add    $0x10,%esp
f01055ee:	eb 0d                	jmp    f01055fd <vprintfmt+0x220>
				else
					putch(ch, putdat);
f01055f0:	83 ec 08             	sub    $0x8,%esp
f01055f3:	ff 75 0c             	pushl  0xc(%ebp)
f01055f6:	52                   	push   %edx
f01055f7:	ff 55 08             	call   *0x8(%ebp)
f01055fa:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01055fd:	83 eb 01             	sub    $0x1,%ebx
f0105600:	eb 1a                	jmp    f010561c <vprintfmt+0x23f>
f0105602:	89 75 08             	mov    %esi,0x8(%ebp)
f0105605:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105608:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010560b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010560e:	eb 0c                	jmp    f010561c <vprintfmt+0x23f>
f0105610:	89 75 08             	mov    %esi,0x8(%ebp)
f0105613:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105616:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105619:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010561c:	83 c7 01             	add    $0x1,%edi
f010561f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105623:	0f be d0             	movsbl %al,%edx
f0105626:	85 d2                	test   %edx,%edx
f0105628:	74 23                	je     f010564d <vprintfmt+0x270>
f010562a:	85 f6                	test   %esi,%esi
f010562c:	78 a1                	js     f01055cf <vprintfmt+0x1f2>
f010562e:	83 ee 01             	sub    $0x1,%esi
f0105631:	79 9c                	jns    f01055cf <vprintfmt+0x1f2>
f0105633:	89 df                	mov    %ebx,%edi
f0105635:	8b 75 08             	mov    0x8(%ebp),%esi
f0105638:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010563b:	eb 18                	jmp    f0105655 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010563d:	83 ec 08             	sub    $0x8,%esp
f0105640:	53                   	push   %ebx
f0105641:	6a 20                	push   $0x20
f0105643:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105645:	83 ef 01             	sub    $0x1,%edi
f0105648:	83 c4 10             	add    $0x10,%esp
f010564b:	eb 08                	jmp    f0105655 <vprintfmt+0x278>
f010564d:	89 df                	mov    %ebx,%edi
f010564f:	8b 75 08             	mov    0x8(%ebp),%esi
f0105652:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105655:	85 ff                	test   %edi,%edi
f0105657:	7f e4                	jg     f010563d <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105659:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010565c:	e9 a2 fd ff ff       	jmp    f0105403 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105661:	83 fa 01             	cmp    $0x1,%edx
f0105664:	7e 16                	jle    f010567c <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0105666:	8b 45 14             	mov    0x14(%ebp),%eax
f0105669:	8d 50 08             	lea    0x8(%eax),%edx
f010566c:	89 55 14             	mov    %edx,0x14(%ebp)
f010566f:	8b 50 04             	mov    0x4(%eax),%edx
f0105672:	8b 00                	mov    (%eax),%eax
f0105674:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105677:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010567a:	eb 32                	jmp    f01056ae <vprintfmt+0x2d1>
	else if (lflag)
f010567c:	85 d2                	test   %edx,%edx
f010567e:	74 18                	je     f0105698 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0105680:	8b 45 14             	mov    0x14(%ebp),%eax
f0105683:	8d 50 04             	lea    0x4(%eax),%edx
f0105686:	89 55 14             	mov    %edx,0x14(%ebp)
f0105689:	8b 00                	mov    (%eax),%eax
f010568b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010568e:	89 c1                	mov    %eax,%ecx
f0105690:	c1 f9 1f             	sar    $0x1f,%ecx
f0105693:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105696:	eb 16                	jmp    f01056ae <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0105698:	8b 45 14             	mov    0x14(%ebp),%eax
f010569b:	8d 50 04             	lea    0x4(%eax),%edx
f010569e:	89 55 14             	mov    %edx,0x14(%ebp)
f01056a1:	8b 00                	mov    (%eax),%eax
f01056a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01056a6:	89 c1                	mov    %eax,%ecx
f01056a8:	c1 f9 1f             	sar    $0x1f,%ecx
f01056ab:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01056ae:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01056b1:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01056b4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01056b9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01056bd:	79 74                	jns    f0105733 <vprintfmt+0x356>
				putch('-', putdat);
f01056bf:	83 ec 08             	sub    $0x8,%esp
f01056c2:	53                   	push   %ebx
f01056c3:	6a 2d                	push   $0x2d
f01056c5:	ff d6                	call   *%esi
				num = -(long long) num;
f01056c7:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01056ca:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01056cd:	f7 d8                	neg    %eax
f01056cf:	83 d2 00             	adc    $0x0,%edx
f01056d2:	f7 da                	neg    %edx
f01056d4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01056d7:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01056dc:	eb 55                	jmp    f0105733 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01056de:	8d 45 14             	lea    0x14(%ebp),%eax
f01056e1:	e8 83 fc ff ff       	call   f0105369 <getuint>
			base = 10;
f01056e6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01056eb:	eb 46                	jmp    f0105733 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f01056ed:	8d 45 14             	lea    0x14(%ebp),%eax
f01056f0:	e8 74 fc ff ff       	call   f0105369 <getuint>
			base = 8;
f01056f5:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f01056fa:	eb 37                	jmp    f0105733 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f01056fc:	83 ec 08             	sub    $0x8,%esp
f01056ff:	53                   	push   %ebx
f0105700:	6a 30                	push   $0x30
f0105702:	ff d6                	call   *%esi
			putch('x', putdat);
f0105704:	83 c4 08             	add    $0x8,%esp
f0105707:	53                   	push   %ebx
f0105708:	6a 78                	push   $0x78
f010570a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010570c:	8b 45 14             	mov    0x14(%ebp),%eax
f010570f:	8d 50 04             	lea    0x4(%eax),%edx
f0105712:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105715:	8b 00                	mov    (%eax),%eax
f0105717:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f010571c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f010571f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0105724:	eb 0d                	jmp    f0105733 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105726:	8d 45 14             	lea    0x14(%ebp),%eax
f0105729:	e8 3b fc ff ff       	call   f0105369 <getuint>
			base = 16;
f010572e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105733:	83 ec 0c             	sub    $0xc,%esp
f0105736:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f010573a:	57                   	push   %edi
f010573b:	ff 75 e0             	pushl  -0x20(%ebp)
f010573e:	51                   	push   %ecx
f010573f:	52                   	push   %edx
f0105740:	50                   	push   %eax
f0105741:	89 da                	mov    %ebx,%edx
f0105743:	89 f0                	mov    %esi,%eax
f0105745:	e8 70 fb ff ff       	call   f01052ba <printnum>
			break;
f010574a:	83 c4 20             	add    $0x20,%esp
f010574d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105750:	e9 ae fc ff ff       	jmp    f0105403 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105755:	83 ec 08             	sub    $0x8,%esp
f0105758:	53                   	push   %ebx
f0105759:	51                   	push   %ecx
f010575a:	ff d6                	call   *%esi
			break;
f010575c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010575f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105762:	e9 9c fc ff ff       	jmp    f0105403 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105767:	83 ec 08             	sub    $0x8,%esp
f010576a:	53                   	push   %ebx
f010576b:	6a 25                	push   $0x25
f010576d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010576f:	83 c4 10             	add    $0x10,%esp
f0105772:	eb 03                	jmp    f0105777 <vprintfmt+0x39a>
f0105774:	83 ef 01             	sub    $0x1,%edi
f0105777:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f010577b:	75 f7                	jne    f0105774 <vprintfmt+0x397>
f010577d:	e9 81 fc ff ff       	jmp    f0105403 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0105782:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105785:	5b                   	pop    %ebx
f0105786:	5e                   	pop    %esi
f0105787:	5f                   	pop    %edi
f0105788:	5d                   	pop    %ebp
f0105789:	c3                   	ret    

f010578a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010578a:	55                   	push   %ebp
f010578b:	89 e5                	mov    %esp,%ebp
f010578d:	83 ec 18             	sub    $0x18,%esp
f0105790:	8b 45 08             	mov    0x8(%ebp),%eax
f0105793:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105796:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105799:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010579d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01057a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01057a7:	85 c0                	test   %eax,%eax
f01057a9:	74 26                	je     f01057d1 <vsnprintf+0x47>
f01057ab:	85 d2                	test   %edx,%edx
f01057ad:	7e 22                	jle    f01057d1 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01057af:	ff 75 14             	pushl  0x14(%ebp)
f01057b2:	ff 75 10             	pushl  0x10(%ebp)
f01057b5:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01057b8:	50                   	push   %eax
f01057b9:	68 a3 53 10 f0       	push   $0xf01053a3
f01057be:	e8 1a fc ff ff       	call   f01053dd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01057c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01057c6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01057c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01057cc:	83 c4 10             	add    $0x10,%esp
f01057cf:	eb 05                	jmp    f01057d6 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01057d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01057d6:	c9                   	leave  
f01057d7:	c3                   	ret    

f01057d8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01057d8:	55                   	push   %ebp
f01057d9:	89 e5                	mov    %esp,%ebp
f01057db:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01057de:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01057e1:	50                   	push   %eax
f01057e2:	ff 75 10             	pushl  0x10(%ebp)
f01057e5:	ff 75 0c             	pushl  0xc(%ebp)
f01057e8:	ff 75 08             	pushl  0x8(%ebp)
f01057eb:	e8 9a ff ff ff       	call   f010578a <vsnprintf>
	va_end(ap);

	return rc;
}
f01057f0:	c9                   	leave  
f01057f1:	c3                   	ret    

f01057f2 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01057f2:	55                   	push   %ebp
f01057f3:	89 e5                	mov    %esp,%ebp
f01057f5:	57                   	push   %edi
f01057f6:	56                   	push   %esi
f01057f7:	53                   	push   %ebx
f01057f8:	83 ec 0c             	sub    $0xc,%esp
f01057fb:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f01057fe:	85 c0                	test   %eax,%eax
f0105800:	74 11                	je     f0105813 <readline+0x21>
		cprintf("%s", prompt);
f0105802:	83 ec 08             	sub    $0x8,%esp
f0105805:	50                   	push   %eax
f0105806:	68 49 76 10 f0       	push   $0xf0107649
f010580b:	e8 cf e1 ff ff       	call   f01039df <cprintf>
f0105810:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105813:	83 ec 0c             	sub    $0xc,%esp
f0105816:	6a 00                	push   $0x0
f0105818:	e8 9d af ff ff       	call   f01007ba <iscons>
f010581d:	89 c7                	mov    %eax,%edi
f010581f:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f0105822:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105827:	e8 7d af ff ff       	call   f01007a9 <getchar>
f010582c:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010582e:	85 c0                	test   %eax,%eax
f0105830:	79 29                	jns    f010585b <readline+0x69>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f0105832:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f0105837:	83 fb f8             	cmp    $0xfffffff8,%ebx
f010583a:	0f 84 9b 00 00 00    	je     f01058db <readline+0xe9>
				cprintf("read error: %e\n", c);
f0105840:	83 ec 08             	sub    $0x8,%esp
f0105843:	53                   	push   %ebx
f0105844:	68 9f 82 10 f0       	push   $0xf010829f
f0105849:	e8 91 e1 ff ff       	call   f01039df <cprintf>
f010584e:	83 c4 10             	add    $0x10,%esp
			return NULL;
f0105851:	b8 00 00 00 00       	mov    $0x0,%eax
f0105856:	e9 80 00 00 00       	jmp    f01058db <readline+0xe9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010585b:	83 f8 08             	cmp    $0x8,%eax
f010585e:	0f 94 c2             	sete   %dl
f0105861:	83 f8 7f             	cmp    $0x7f,%eax
f0105864:	0f 94 c0             	sete   %al
f0105867:	08 c2                	or     %al,%dl
f0105869:	74 1a                	je     f0105885 <readline+0x93>
f010586b:	85 f6                	test   %esi,%esi
f010586d:	7e 16                	jle    f0105885 <readline+0x93>
			if (echoing)
f010586f:	85 ff                	test   %edi,%edi
f0105871:	74 0d                	je     f0105880 <readline+0x8e>
				cputchar('\b');
f0105873:	83 ec 0c             	sub    $0xc,%esp
f0105876:	6a 08                	push   $0x8
f0105878:	e8 1c af ff ff       	call   f0100799 <cputchar>
f010587d:	83 c4 10             	add    $0x10,%esp
			i--;
f0105880:	83 ee 01             	sub    $0x1,%esi
f0105883:	eb a2                	jmp    f0105827 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105885:	83 fb 1f             	cmp    $0x1f,%ebx
f0105888:	7e 26                	jle    f01058b0 <readline+0xbe>
f010588a:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105890:	7f 1e                	jg     f01058b0 <readline+0xbe>
			if (echoing)
f0105892:	85 ff                	test   %edi,%edi
f0105894:	74 0c                	je     f01058a2 <readline+0xb0>
				cputchar(c);
f0105896:	83 ec 0c             	sub    $0xc,%esp
f0105899:	53                   	push   %ebx
f010589a:	e8 fa ae ff ff       	call   f0100799 <cputchar>
f010589f:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01058a2:	88 9e 80 2a 21 f0    	mov    %bl,-0xfded580(%esi)
f01058a8:	8d 76 01             	lea    0x1(%esi),%esi
f01058ab:	e9 77 ff ff ff       	jmp    f0105827 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01058b0:	83 fb 0a             	cmp    $0xa,%ebx
f01058b3:	74 09                	je     f01058be <readline+0xcc>
f01058b5:	83 fb 0d             	cmp    $0xd,%ebx
f01058b8:	0f 85 69 ff ff ff    	jne    f0105827 <readline+0x35>
			if (echoing)
f01058be:	85 ff                	test   %edi,%edi
f01058c0:	74 0d                	je     f01058cf <readline+0xdd>
				cputchar('\n');
f01058c2:	83 ec 0c             	sub    $0xc,%esp
f01058c5:	6a 0a                	push   $0xa
f01058c7:	e8 cd ae ff ff       	call   f0100799 <cputchar>
f01058cc:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01058cf:	c6 86 80 2a 21 f0 00 	movb   $0x0,-0xfded580(%esi)
			return buf;
f01058d6:	b8 80 2a 21 f0       	mov    $0xf0212a80,%eax
		}
	}
}
f01058db:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01058de:	5b                   	pop    %ebx
f01058df:	5e                   	pop    %esi
f01058e0:	5f                   	pop    %edi
f01058e1:	5d                   	pop    %ebp
f01058e2:	c3                   	ret    

f01058e3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01058e3:	55                   	push   %ebp
f01058e4:	89 e5                	mov    %esp,%ebp
f01058e6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01058e9:	b8 00 00 00 00       	mov    $0x0,%eax
f01058ee:	eb 03                	jmp    f01058f3 <strlen+0x10>
		n++;
f01058f0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01058f3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01058f7:	75 f7                	jne    f01058f0 <strlen+0xd>
		n++;
	return n;
}
f01058f9:	5d                   	pop    %ebp
f01058fa:	c3                   	ret    

f01058fb <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01058fb:	55                   	push   %ebp
f01058fc:	89 e5                	mov    %esp,%ebp
f01058fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105901:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105904:	ba 00 00 00 00       	mov    $0x0,%edx
f0105909:	eb 03                	jmp    f010590e <strnlen+0x13>
		n++;
f010590b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010590e:	39 c2                	cmp    %eax,%edx
f0105910:	74 08                	je     f010591a <strnlen+0x1f>
f0105912:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0105916:	75 f3                	jne    f010590b <strnlen+0x10>
f0105918:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f010591a:	5d                   	pop    %ebp
f010591b:	c3                   	ret    

f010591c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010591c:	55                   	push   %ebp
f010591d:	89 e5                	mov    %esp,%ebp
f010591f:	53                   	push   %ebx
f0105920:	8b 45 08             	mov    0x8(%ebp),%eax
f0105923:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105926:	89 c2                	mov    %eax,%edx
f0105928:	83 c2 01             	add    $0x1,%edx
f010592b:	83 c1 01             	add    $0x1,%ecx
f010592e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105932:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105935:	84 db                	test   %bl,%bl
f0105937:	75 ef                	jne    f0105928 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105939:	5b                   	pop    %ebx
f010593a:	5d                   	pop    %ebp
f010593b:	c3                   	ret    

f010593c <strcat>:

char *
strcat(char *dst, const char *src)
{
f010593c:	55                   	push   %ebp
f010593d:	89 e5                	mov    %esp,%ebp
f010593f:	53                   	push   %ebx
f0105940:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105943:	53                   	push   %ebx
f0105944:	e8 9a ff ff ff       	call   f01058e3 <strlen>
f0105949:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010594c:	ff 75 0c             	pushl  0xc(%ebp)
f010594f:	01 d8                	add    %ebx,%eax
f0105951:	50                   	push   %eax
f0105952:	e8 c5 ff ff ff       	call   f010591c <strcpy>
	return dst;
}
f0105957:	89 d8                	mov    %ebx,%eax
f0105959:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010595c:	c9                   	leave  
f010595d:	c3                   	ret    

f010595e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010595e:	55                   	push   %ebp
f010595f:	89 e5                	mov    %esp,%ebp
f0105961:	56                   	push   %esi
f0105962:	53                   	push   %ebx
f0105963:	8b 75 08             	mov    0x8(%ebp),%esi
f0105966:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105969:	89 f3                	mov    %esi,%ebx
f010596b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010596e:	89 f2                	mov    %esi,%edx
f0105970:	eb 0f                	jmp    f0105981 <strncpy+0x23>
		*dst++ = *src;
f0105972:	83 c2 01             	add    $0x1,%edx
f0105975:	0f b6 01             	movzbl (%ecx),%eax
f0105978:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010597b:	80 39 01             	cmpb   $0x1,(%ecx)
f010597e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105981:	39 da                	cmp    %ebx,%edx
f0105983:	75 ed                	jne    f0105972 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105985:	89 f0                	mov    %esi,%eax
f0105987:	5b                   	pop    %ebx
f0105988:	5e                   	pop    %esi
f0105989:	5d                   	pop    %ebp
f010598a:	c3                   	ret    

f010598b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010598b:	55                   	push   %ebp
f010598c:	89 e5                	mov    %esp,%ebp
f010598e:	56                   	push   %esi
f010598f:	53                   	push   %ebx
f0105990:	8b 75 08             	mov    0x8(%ebp),%esi
f0105993:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105996:	8b 55 10             	mov    0x10(%ebp),%edx
f0105999:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010599b:	85 d2                	test   %edx,%edx
f010599d:	74 21                	je     f01059c0 <strlcpy+0x35>
f010599f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01059a3:	89 f2                	mov    %esi,%edx
f01059a5:	eb 09                	jmp    f01059b0 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01059a7:	83 c2 01             	add    $0x1,%edx
f01059aa:	83 c1 01             	add    $0x1,%ecx
f01059ad:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01059b0:	39 c2                	cmp    %eax,%edx
f01059b2:	74 09                	je     f01059bd <strlcpy+0x32>
f01059b4:	0f b6 19             	movzbl (%ecx),%ebx
f01059b7:	84 db                	test   %bl,%bl
f01059b9:	75 ec                	jne    f01059a7 <strlcpy+0x1c>
f01059bb:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01059bd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01059c0:	29 f0                	sub    %esi,%eax
}
f01059c2:	5b                   	pop    %ebx
f01059c3:	5e                   	pop    %esi
f01059c4:	5d                   	pop    %ebp
f01059c5:	c3                   	ret    

f01059c6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01059c6:	55                   	push   %ebp
f01059c7:	89 e5                	mov    %esp,%ebp
f01059c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01059cc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01059cf:	eb 06                	jmp    f01059d7 <strcmp+0x11>
		p++, q++;
f01059d1:	83 c1 01             	add    $0x1,%ecx
f01059d4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01059d7:	0f b6 01             	movzbl (%ecx),%eax
f01059da:	84 c0                	test   %al,%al
f01059dc:	74 04                	je     f01059e2 <strcmp+0x1c>
f01059de:	3a 02                	cmp    (%edx),%al
f01059e0:	74 ef                	je     f01059d1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01059e2:	0f b6 c0             	movzbl %al,%eax
f01059e5:	0f b6 12             	movzbl (%edx),%edx
f01059e8:	29 d0                	sub    %edx,%eax
}
f01059ea:	5d                   	pop    %ebp
f01059eb:	c3                   	ret    

f01059ec <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01059ec:	55                   	push   %ebp
f01059ed:	89 e5                	mov    %esp,%ebp
f01059ef:	53                   	push   %ebx
f01059f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01059f3:	8b 55 0c             	mov    0xc(%ebp),%edx
f01059f6:	89 c3                	mov    %eax,%ebx
f01059f8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01059fb:	eb 06                	jmp    f0105a03 <strncmp+0x17>
		n--, p++, q++;
f01059fd:	83 c0 01             	add    $0x1,%eax
f0105a00:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105a03:	39 d8                	cmp    %ebx,%eax
f0105a05:	74 15                	je     f0105a1c <strncmp+0x30>
f0105a07:	0f b6 08             	movzbl (%eax),%ecx
f0105a0a:	84 c9                	test   %cl,%cl
f0105a0c:	74 04                	je     f0105a12 <strncmp+0x26>
f0105a0e:	3a 0a                	cmp    (%edx),%cl
f0105a10:	74 eb                	je     f01059fd <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105a12:	0f b6 00             	movzbl (%eax),%eax
f0105a15:	0f b6 12             	movzbl (%edx),%edx
f0105a18:	29 d0                	sub    %edx,%eax
f0105a1a:	eb 05                	jmp    f0105a21 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105a1c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105a21:	5b                   	pop    %ebx
f0105a22:	5d                   	pop    %ebp
f0105a23:	c3                   	ret    

f0105a24 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105a24:	55                   	push   %ebp
f0105a25:	89 e5                	mov    %esp,%ebp
f0105a27:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a2a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105a2e:	eb 07                	jmp    f0105a37 <strchr+0x13>
		if (*s == c)
f0105a30:	38 ca                	cmp    %cl,%dl
f0105a32:	74 0f                	je     f0105a43 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105a34:	83 c0 01             	add    $0x1,%eax
f0105a37:	0f b6 10             	movzbl (%eax),%edx
f0105a3a:	84 d2                	test   %dl,%dl
f0105a3c:	75 f2                	jne    f0105a30 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0105a3e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105a43:	5d                   	pop    %ebp
f0105a44:	c3                   	ret    

f0105a45 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105a45:	55                   	push   %ebp
f0105a46:	89 e5                	mov    %esp,%ebp
f0105a48:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a4b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105a4f:	eb 03                	jmp    f0105a54 <strfind+0xf>
f0105a51:	83 c0 01             	add    $0x1,%eax
f0105a54:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105a57:	38 ca                	cmp    %cl,%dl
f0105a59:	74 04                	je     f0105a5f <strfind+0x1a>
f0105a5b:	84 d2                	test   %dl,%dl
f0105a5d:	75 f2                	jne    f0105a51 <strfind+0xc>
			break;
	return (char *) s;
}
f0105a5f:	5d                   	pop    %ebp
f0105a60:	c3                   	ret    

f0105a61 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105a61:	55                   	push   %ebp
f0105a62:	89 e5                	mov    %esp,%ebp
f0105a64:	57                   	push   %edi
f0105a65:	56                   	push   %esi
f0105a66:	53                   	push   %ebx
f0105a67:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105a6a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105a6d:	85 c9                	test   %ecx,%ecx
f0105a6f:	74 36                	je     f0105aa7 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105a71:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105a77:	75 28                	jne    f0105aa1 <memset+0x40>
f0105a79:	f6 c1 03             	test   $0x3,%cl
f0105a7c:	75 23                	jne    f0105aa1 <memset+0x40>
		c &= 0xFF;
f0105a7e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105a82:	89 d3                	mov    %edx,%ebx
f0105a84:	c1 e3 08             	shl    $0x8,%ebx
f0105a87:	89 d6                	mov    %edx,%esi
f0105a89:	c1 e6 18             	shl    $0x18,%esi
f0105a8c:	89 d0                	mov    %edx,%eax
f0105a8e:	c1 e0 10             	shl    $0x10,%eax
f0105a91:	09 f0                	or     %esi,%eax
f0105a93:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0105a95:	89 d8                	mov    %ebx,%eax
f0105a97:	09 d0                	or     %edx,%eax
f0105a99:	c1 e9 02             	shr    $0x2,%ecx
f0105a9c:	fc                   	cld    
f0105a9d:	f3 ab                	rep stos %eax,%es:(%edi)
f0105a9f:	eb 06                	jmp    f0105aa7 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105aa1:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105aa4:	fc                   	cld    
f0105aa5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105aa7:	89 f8                	mov    %edi,%eax
f0105aa9:	5b                   	pop    %ebx
f0105aaa:	5e                   	pop    %esi
f0105aab:	5f                   	pop    %edi
f0105aac:	5d                   	pop    %ebp
f0105aad:	c3                   	ret    

f0105aae <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105aae:	55                   	push   %ebp
f0105aaf:	89 e5                	mov    %esp,%ebp
f0105ab1:	57                   	push   %edi
f0105ab2:	56                   	push   %esi
f0105ab3:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ab6:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105ab9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105abc:	39 c6                	cmp    %eax,%esi
f0105abe:	73 35                	jae    f0105af5 <memmove+0x47>
f0105ac0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105ac3:	39 d0                	cmp    %edx,%eax
f0105ac5:	73 2e                	jae    f0105af5 <memmove+0x47>
		s += n;
		d += n;
f0105ac7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105aca:	89 d6                	mov    %edx,%esi
f0105acc:	09 fe                	or     %edi,%esi
f0105ace:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105ad4:	75 13                	jne    f0105ae9 <memmove+0x3b>
f0105ad6:	f6 c1 03             	test   $0x3,%cl
f0105ad9:	75 0e                	jne    f0105ae9 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0105adb:	83 ef 04             	sub    $0x4,%edi
f0105ade:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105ae1:	c1 e9 02             	shr    $0x2,%ecx
f0105ae4:	fd                   	std    
f0105ae5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105ae7:	eb 09                	jmp    f0105af2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105ae9:	83 ef 01             	sub    $0x1,%edi
f0105aec:	8d 72 ff             	lea    -0x1(%edx),%esi
f0105aef:	fd                   	std    
f0105af0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105af2:	fc                   	cld    
f0105af3:	eb 1d                	jmp    f0105b12 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105af5:	89 f2                	mov    %esi,%edx
f0105af7:	09 c2                	or     %eax,%edx
f0105af9:	f6 c2 03             	test   $0x3,%dl
f0105afc:	75 0f                	jne    f0105b0d <memmove+0x5f>
f0105afe:	f6 c1 03             	test   $0x3,%cl
f0105b01:	75 0a                	jne    f0105b0d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0105b03:	c1 e9 02             	shr    $0x2,%ecx
f0105b06:	89 c7                	mov    %eax,%edi
f0105b08:	fc                   	cld    
f0105b09:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105b0b:	eb 05                	jmp    f0105b12 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105b0d:	89 c7                	mov    %eax,%edi
f0105b0f:	fc                   	cld    
f0105b10:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105b12:	5e                   	pop    %esi
f0105b13:	5f                   	pop    %edi
f0105b14:	5d                   	pop    %ebp
f0105b15:	c3                   	ret    

f0105b16 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105b16:	55                   	push   %ebp
f0105b17:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105b19:	ff 75 10             	pushl  0x10(%ebp)
f0105b1c:	ff 75 0c             	pushl  0xc(%ebp)
f0105b1f:	ff 75 08             	pushl  0x8(%ebp)
f0105b22:	e8 87 ff ff ff       	call   f0105aae <memmove>
}
f0105b27:	c9                   	leave  
f0105b28:	c3                   	ret    

f0105b29 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105b29:	55                   	push   %ebp
f0105b2a:	89 e5                	mov    %esp,%ebp
f0105b2c:	56                   	push   %esi
f0105b2d:	53                   	push   %ebx
f0105b2e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b31:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105b34:	89 c6                	mov    %eax,%esi
f0105b36:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105b39:	eb 1a                	jmp    f0105b55 <memcmp+0x2c>
		if (*s1 != *s2)
f0105b3b:	0f b6 08             	movzbl (%eax),%ecx
f0105b3e:	0f b6 1a             	movzbl (%edx),%ebx
f0105b41:	38 d9                	cmp    %bl,%cl
f0105b43:	74 0a                	je     f0105b4f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0105b45:	0f b6 c1             	movzbl %cl,%eax
f0105b48:	0f b6 db             	movzbl %bl,%ebx
f0105b4b:	29 d8                	sub    %ebx,%eax
f0105b4d:	eb 0f                	jmp    f0105b5e <memcmp+0x35>
		s1++, s2++;
f0105b4f:	83 c0 01             	add    $0x1,%eax
f0105b52:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105b55:	39 f0                	cmp    %esi,%eax
f0105b57:	75 e2                	jne    f0105b3b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105b59:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105b5e:	5b                   	pop    %ebx
f0105b5f:	5e                   	pop    %esi
f0105b60:	5d                   	pop    %ebp
f0105b61:	c3                   	ret    

f0105b62 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105b62:	55                   	push   %ebp
f0105b63:	89 e5                	mov    %esp,%ebp
f0105b65:	53                   	push   %ebx
f0105b66:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0105b69:	89 c1                	mov    %eax,%ecx
f0105b6b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0105b6e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105b72:	eb 0a                	jmp    f0105b7e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105b74:	0f b6 10             	movzbl (%eax),%edx
f0105b77:	39 da                	cmp    %ebx,%edx
f0105b79:	74 07                	je     f0105b82 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105b7b:	83 c0 01             	add    $0x1,%eax
f0105b7e:	39 c8                	cmp    %ecx,%eax
f0105b80:	72 f2                	jb     f0105b74 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105b82:	5b                   	pop    %ebx
f0105b83:	5d                   	pop    %ebp
f0105b84:	c3                   	ret    

f0105b85 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105b85:	55                   	push   %ebp
f0105b86:	89 e5                	mov    %esp,%ebp
f0105b88:	57                   	push   %edi
f0105b89:	56                   	push   %esi
f0105b8a:	53                   	push   %ebx
f0105b8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105b8e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105b91:	eb 03                	jmp    f0105b96 <strtol+0x11>
		s++;
f0105b93:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105b96:	0f b6 01             	movzbl (%ecx),%eax
f0105b99:	3c 20                	cmp    $0x20,%al
f0105b9b:	74 f6                	je     f0105b93 <strtol+0xe>
f0105b9d:	3c 09                	cmp    $0x9,%al
f0105b9f:	74 f2                	je     f0105b93 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105ba1:	3c 2b                	cmp    $0x2b,%al
f0105ba3:	75 0a                	jne    f0105baf <strtol+0x2a>
		s++;
f0105ba5:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105ba8:	bf 00 00 00 00       	mov    $0x0,%edi
f0105bad:	eb 11                	jmp    f0105bc0 <strtol+0x3b>
f0105baf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105bb4:	3c 2d                	cmp    $0x2d,%al
f0105bb6:	75 08                	jne    f0105bc0 <strtol+0x3b>
		s++, neg = 1;
f0105bb8:	83 c1 01             	add    $0x1,%ecx
f0105bbb:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105bc0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105bc6:	75 15                	jne    f0105bdd <strtol+0x58>
f0105bc8:	80 39 30             	cmpb   $0x30,(%ecx)
f0105bcb:	75 10                	jne    f0105bdd <strtol+0x58>
f0105bcd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105bd1:	75 7c                	jne    f0105c4f <strtol+0xca>
		s += 2, base = 16;
f0105bd3:	83 c1 02             	add    $0x2,%ecx
f0105bd6:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105bdb:	eb 16                	jmp    f0105bf3 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0105bdd:	85 db                	test   %ebx,%ebx
f0105bdf:	75 12                	jne    f0105bf3 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105be1:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105be6:	80 39 30             	cmpb   $0x30,(%ecx)
f0105be9:	75 08                	jne    f0105bf3 <strtol+0x6e>
		s++, base = 8;
f0105beb:	83 c1 01             	add    $0x1,%ecx
f0105bee:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0105bf3:	b8 00 00 00 00       	mov    $0x0,%eax
f0105bf8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105bfb:	0f b6 11             	movzbl (%ecx),%edx
f0105bfe:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105c01:	89 f3                	mov    %esi,%ebx
f0105c03:	80 fb 09             	cmp    $0x9,%bl
f0105c06:	77 08                	ja     f0105c10 <strtol+0x8b>
			dig = *s - '0';
f0105c08:	0f be d2             	movsbl %dl,%edx
f0105c0b:	83 ea 30             	sub    $0x30,%edx
f0105c0e:	eb 22                	jmp    f0105c32 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0105c10:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105c13:	89 f3                	mov    %esi,%ebx
f0105c15:	80 fb 19             	cmp    $0x19,%bl
f0105c18:	77 08                	ja     f0105c22 <strtol+0x9d>
			dig = *s - 'a' + 10;
f0105c1a:	0f be d2             	movsbl %dl,%edx
f0105c1d:	83 ea 57             	sub    $0x57,%edx
f0105c20:	eb 10                	jmp    f0105c32 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0105c22:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105c25:	89 f3                	mov    %esi,%ebx
f0105c27:	80 fb 19             	cmp    $0x19,%bl
f0105c2a:	77 16                	ja     f0105c42 <strtol+0xbd>
			dig = *s - 'A' + 10;
f0105c2c:	0f be d2             	movsbl %dl,%edx
f0105c2f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0105c32:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105c35:	7d 0b                	jge    f0105c42 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0105c37:	83 c1 01             	add    $0x1,%ecx
f0105c3a:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105c3e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0105c40:	eb b9                	jmp    f0105bfb <strtol+0x76>

	if (endptr)
f0105c42:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105c46:	74 0d                	je     f0105c55 <strtol+0xd0>
		*endptr = (char *) s;
f0105c48:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105c4b:	89 0e                	mov    %ecx,(%esi)
f0105c4d:	eb 06                	jmp    f0105c55 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105c4f:	85 db                	test   %ebx,%ebx
f0105c51:	74 98                	je     f0105beb <strtol+0x66>
f0105c53:	eb 9e                	jmp    f0105bf3 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0105c55:	89 c2                	mov    %eax,%edx
f0105c57:	f7 da                	neg    %edx
f0105c59:	85 ff                	test   %edi,%edi
f0105c5b:	0f 45 c2             	cmovne %edx,%eax
}
f0105c5e:	5b                   	pop    %ebx
f0105c5f:	5e                   	pop    %esi
f0105c60:	5f                   	pop    %edi
f0105c61:	5d                   	pop    %ebp
f0105c62:	c3                   	ret    
f0105c63:	90                   	nop

f0105c64 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105c64:	fa                   	cli    

	xorw    %ax, %ax
f0105c65:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105c67:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105c69:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105c6b:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105c6d:	0f 01 16             	lgdtl  (%esi)
f0105c70:	74 70                	je     f0105ce2 <mpsearch1+0x3>
	movl    %cr0, %eax
f0105c72:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105c75:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105c79:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105c7c:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105c82:	08 00                	or     %al,(%eax)

f0105c84 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105c84:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105c88:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105c8a:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105c8c:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105c8e:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105c92:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105c94:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105c96:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl    %eax, %cr3
f0105c9b:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105c9e:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105ca1:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105ca6:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105ca9:	8b 25 84 2e 21 f0    	mov    0xf0212e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105caf:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105cb4:	b8 c7 01 10 f0       	mov    $0xf01001c7,%eax
	call    *%eax
f0105cb9:	ff d0                	call   *%eax

f0105cbb <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105cbb:	eb fe                	jmp    f0105cbb <spin>
f0105cbd:	8d 76 00             	lea    0x0(%esi),%esi

f0105cc0 <gdt>:
	...
f0105cc8:	ff                   	(bad)  
f0105cc9:	ff 00                	incl   (%eax)
f0105ccb:	00 00                	add    %al,(%eax)
f0105ccd:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105cd4:	00                   	.byte 0x0
f0105cd5:	92                   	xchg   %eax,%edx
f0105cd6:	cf                   	iret   
	...

f0105cd8 <gdtdesc>:
f0105cd8:	17                   	pop    %ss
f0105cd9:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105cde <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105cde:	90                   	nop

f0105cdf <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105cdf:	55                   	push   %ebp
f0105ce0:	89 e5                	mov    %esp,%ebp
f0105ce2:	57                   	push   %edi
f0105ce3:	56                   	push   %esi
f0105ce4:	53                   	push   %ebx
f0105ce5:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105ce8:	8b 0d 88 2e 21 f0    	mov    0xf0212e88,%ecx
f0105cee:	89 c3                	mov    %eax,%ebx
f0105cf0:	c1 eb 0c             	shr    $0xc,%ebx
f0105cf3:	39 cb                	cmp    %ecx,%ebx
f0105cf5:	72 12                	jb     f0105d09 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105cf7:	50                   	push   %eax
f0105cf8:	68 44 67 10 f0       	push   $0xf0106744
f0105cfd:	6a 57                	push   $0x57
f0105cff:	68 3d 84 10 f0       	push   $0xf010843d
f0105d04:	e8 37 a3 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105d09:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105d0f:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105d11:	89 c2                	mov    %eax,%edx
f0105d13:	c1 ea 0c             	shr    $0xc,%edx
f0105d16:	39 ca                	cmp    %ecx,%edx
f0105d18:	72 12                	jb     f0105d2c <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105d1a:	50                   	push   %eax
f0105d1b:	68 44 67 10 f0       	push   $0xf0106744
f0105d20:	6a 57                	push   $0x57
f0105d22:	68 3d 84 10 f0       	push   $0xf010843d
f0105d27:	e8 14 a3 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105d2c:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0105d32:	eb 2f                	jmp    f0105d63 <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105d34:	83 ec 04             	sub    $0x4,%esp
f0105d37:	6a 04                	push   $0x4
f0105d39:	68 4d 84 10 f0       	push   $0xf010844d
f0105d3e:	53                   	push   %ebx
f0105d3f:	e8 e5 fd ff ff       	call   f0105b29 <memcmp>
f0105d44:	83 c4 10             	add    $0x10,%esp
f0105d47:	85 c0                	test   %eax,%eax
f0105d49:	75 15                	jne    f0105d60 <mpsearch1+0x81>
f0105d4b:	89 da                	mov    %ebx,%edx
f0105d4d:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0105d50:	0f b6 0a             	movzbl (%edx),%ecx
f0105d53:	01 c8                	add    %ecx,%eax
f0105d55:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105d58:	39 d7                	cmp    %edx,%edi
f0105d5a:	75 f4                	jne    f0105d50 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105d5c:	84 c0                	test   %al,%al
f0105d5e:	74 0e                	je     f0105d6e <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105d60:	83 c3 10             	add    $0x10,%ebx
f0105d63:	39 f3                	cmp    %esi,%ebx
f0105d65:	72 cd                	jb     f0105d34 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105d67:	b8 00 00 00 00       	mov    $0x0,%eax
f0105d6c:	eb 02                	jmp    f0105d70 <mpsearch1+0x91>
f0105d6e:	89 d8                	mov    %ebx,%eax
}
f0105d70:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105d73:	5b                   	pop    %ebx
f0105d74:	5e                   	pop    %esi
f0105d75:	5f                   	pop    %edi
f0105d76:	5d                   	pop    %ebp
f0105d77:	c3                   	ret    

f0105d78 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105d78:	55                   	push   %ebp
f0105d79:	89 e5                	mov    %esp,%ebp
f0105d7b:	57                   	push   %edi
f0105d7c:	56                   	push   %esi
f0105d7d:	53                   	push   %ebx
f0105d7e:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105d81:	c7 05 c0 33 21 f0 20 	movl   $0xf0213020,0xf02133c0
f0105d88:	30 21 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105d8b:	83 3d 88 2e 21 f0 00 	cmpl   $0x0,0xf0212e88
f0105d92:	75 16                	jne    f0105daa <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105d94:	68 00 04 00 00       	push   $0x400
f0105d99:	68 44 67 10 f0       	push   $0xf0106744
f0105d9e:	6a 6f                	push   $0x6f
f0105da0:	68 3d 84 10 f0       	push   $0xf010843d
f0105da5:	e8 96 a2 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105daa:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105db1:	85 c0                	test   %eax,%eax
f0105db3:	74 16                	je     f0105dcb <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0105db5:	c1 e0 04             	shl    $0x4,%eax
f0105db8:	ba 00 04 00 00       	mov    $0x400,%edx
f0105dbd:	e8 1d ff ff ff       	call   f0105cdf <mpsearch1>
f0105dc2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105dc5:	85 c0                	test   %eax,%eax
f0105dc7:	75 3c                	jne    f0105e05 <mp_init+0x8d>
f0105dc9:	eb 20                	jmp    f0105deb <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105dcb:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105dd2:	c1 e0 0a             	shl    $0xa,%eax
f0105dd5:	2d 00 04 00 00       	sub    $0x400,%eax
f0105dda:	ba 00 04 00 00       	mov    $0x400,%edx
f0105ddf:	e8 fb fe ff ff       	call   f0105cdf <mpsearch1>
f0105de4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105de7:	85 c0                	test   %eax,%eax
f0105de9:	75 1a                	jne    f0105e05 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105deb:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105df0:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105df5:	e8 e5 fe ff ff       	call   f0105cdf <mpsearch1>
f0105dfa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105dfd:	85 c0                	test   %eax,%eax
f0105dff:	0f 84 5d 02 00 00    	je     f0106062 <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105e05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105e08:	8b 70 04             	mov    0x4(%eax),%esi
f0105e0b:	85 f6                	test   %esi,%esi
f0105e0d:	74 06                	je     f0105e15 <mp_init+0x9d>
f0105e0f:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105e13:	74 15                	je     f0105e2a <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105e15:	83 ec 0c             	sub    $0xc,%esp
f0105e18:	68 b0 82 10 f0       	push   $0xf01082b0
f0105e1d:	e8 bd db ff ff       	call   f01039df <cprintf>
f0105e22:	83 c4 10             	add    $0x10,%esp
f0105e25:	e9 38 02 00 00       	jmp    f0106062 <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105e2a:	89 f0                	mov    %esi,%eax
f0105e2c:	c1 e8 0c             	shr    $0xc,%eax
f0105e2f:	3b 05 88 2e 21 f0    	cmp    0xf0212e88,%eax
f0105e35:	72 15                	jb     f0105e4c <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105e37:	56                   	push   %esi
f0105e38:	68 44 67 10 f0       	push   $0xf0106744
f0105e3d:	68 90 00 00 00       	push   $0x90
f0105e42:	68 3d 84 10 f0       	push   $0xf010843d
f0105e47:	e8 f4 a1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105e4c:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105e52:	83 ec 04             	sub    $0x4,%esp
f0105e55:	6a 04                	push   $0x4
f0105e57:	68 52 84 10 f0       	push   $0xf0108452
f0105e5c:	53                   	push   %ebx
f0105e5d:	e8 c7 fc ff ff       	call   f0105b29 <memcmp>
f0105e62:	83 c4 10             	add    $0x10,%esp
f0105e65:	85 c0                	test   %eax,%eax
f0105e67:	74 15                	je     f0105e7e <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105e69:	83 ec 0c             	sub    $0xc,%esp
f0105e6c:	68 e0 82 10 f0       	push   $0xf01082e0
f0105e71:	e8 69 db ff ff       	call   f01039df <cprintf>
f0105e76:	83 c4 10             	add    $0x10,%esp
f0105e79:	e9 e4 01 00 00       	jmp    f0106062 <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105e7e:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0105e82:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0105e86:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105e89:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105e8e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e93:	eb 0d                	jmp    f0105ea2 <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0105e95:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105e9c:	f0 
f0105e9d:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105e9f:	83 c0 01             	add    $0x1,%eax
f0105ea2:	39 c7                	cmp    %eax,%edi
f0105ea4:	75 ef                	jne    f0105e95 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105ea6:	84 d2                	test   %dl,%dl
f0105ea8:	74 15                	je     f0105ebf <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105eaa:	83 ec 0c             	sub    $0xc,%esp
f0105ead:	68 14 83 10 f0       	push   $0xf0108314
f0105eb2:	e8 28 db ff ff       	call   f01039df <cprintf>
f0105eb7:	83 c4 10             	add    $0x10,%esp
f0105eba:	e9 a3 01 00 00       	jmp    f0106062 <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105ebf:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105ec3:	3c 01                	cmp    $0x1,%al
f0105ec5:	74 1d                	je     f0105ee4 <mp_init+0x16c>
f0105ec7:	3c 04                	cmp    $0x4,%al
f0105ec9:	74 19                	je     f0105ee4 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105ecb:	83 ec 08             	sub    $0x8,%esp
f0105ece:	0f b6 c0             	movzbl %al,%eax
f0105ed1:	50                   	push   %eax
f0105ed2:	68 38 83 10 f0       	push   $0xf0108338
f0105ed7:	e8 03 db ff ff       	call   f01039df <cprintf>
f0105edc:	83 c4 10             	add    $0x10,%esp
f0105edf:	e9 7e 01 00 00       	jmp    f0106062 <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105ee4:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0105ee8:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105eec:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105ef1:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0105ef6:	01 ce                	add    %ecx,%esi
f0105ef8:	eb 0d                	jmp    f0105f07 <mp_init+0x18f>
f0105efa:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105f01:	f0 
f0105f02:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105f04:	83 c0 01             	add    $0x1,%eax
f0105f07:	39 c7                	cmp    %eax,%edi
f0105f09:	75 ef                	jne    f0105efa <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105f0b:	89 d0                	mov    %edx,%eax
f0105f0d:	02 43 2a             	add    0x2a(%ebx),%al
f0105f10:	74 15                	je     f0105f27 <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105f12:	83 ec 0c             	sub    $0xc,%esp
f0105f15:	68 58 83 10 f0       	push   $0xf0108358
f0105f1a:	e8 c0 da ff ff       	call   f01039df <cprintf>
f0105f1f:	83 c4 10             	add    $0x10,%esp
f0105f22:	e9 3b 01 00 00       	jmp    f0106062 <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105f27:	85 db                	test   %ebx,%ebx
f0105f29:	0f 84 33 01 00 00    	je     f0106062 <mp_init+0x2ea>
		return;
	ismp = 1;
f0105f2f:	c7 05 00 30 21 f0 01 	movl   $0x1,0xf0213000
f0105f36:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105f39:	8b 43 24             	mov    0x24(%ebx),%eax
f0105f3c:	a3 00 40 25 f0       	mov    %eax,0xf0254000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105f41:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105f44:	be 00 00 00 00       	mov    $0x0,%esi
f0105f49:	e9 85 00 00 00       	jmp    f0105fd3 <mp_init+0x25b>
		switch (*p) {
f0105f4e:	0f b6 07             	movzbl (%edi),%eax
f0105f51:	84 c0                	test   %al,%al
f0105f53:	74 06                	je     f0105f5b <mp_init+0x1e3>
f0105f55:	3c 04                	cmp    $0x4,%al
f0105f57:	77 55                	ja     f0105fae <mp_init+0x236>
f0105f59:	eb 4e                	jmp    f0105fa9 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105f5b:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105f5f:	74 11                	je     f0105f72 <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105f61:	6b 05 c4 33 21 f0 74 	imul   $0x74,0xf02133c4,%eax
f0105f68:	05 20 30 21 f0       	add    $0xf0213020,%eax
f0105f6d:	a3 c0 33 21 f0       	mov    %eax,0xf02133c0
			if (ncpu < NCPU) {
f0105f72:	a1 c4 33 21 f0       	mov    0xf02133c4,%eax
f0105f77:	83 f8 07             	cmp    $0x7,%eax
f0105f7a:	7f 13                	jg     f0105f8f <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f0105f7c:	6b d0 74             	imul   $0x74,%eax,%edx
f0105f7f:	88 82 20 30 21 f0    	mov    %al,-0xfdecfe0(%edx)
				ncpu++;
f0105f85:	83 c0 01             	add    $0x1,%eax
f0105f88:	a3 c4 33 21 f0       	mov    %eax,0xf02133c4
f0105f8d:	eb 15                	jmp    f0105fa4 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105f8f:	83 ec 08             	sub    $0x8,%esp
f0105f92:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105f96:	50                   	push   %eax
f0105f97:	68 88 83 10 f0       	push   $0xf0108388
f0105f9c:	e8 3e da ff ff       	call   f01039df <cprintf>
f0105fa1:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105fa4:	83 c7 14             	add    $0x14,%edi
			continue;
f0105fa7:	eb 27                	jmp    f0105fd0 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105fa9:	83 c7 08             	add    $0x8,%edi
			continue;
f0105fac:	eb 22                	jmp    f0105fd0 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105fae:	83 ec 08             	sub    $0x8,%esp
f0105fb1:	0f b6 c0             	movzbl %al,%eax
f0105fb4:	50                   	push   %eax
f0105fb5:	68 b0 83 10 f0       	push   $0xf01083b0
f0105fba:	e8 20 da ff ff       	call   f01039df <cprintf>
			ismp = 0;
f0105fbf:	c7 05 00 30 21 f0 00 	movl   $0x0,0xf0213000
f0105fc6:	00 00 00 
			i = conf->entry;
f0105fc9:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105fcd:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105fd0:	83 c6 01             	add    $0x1,%esi
f0105fd3:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105fd7:	39 c6                	cmp    %eax,%esi
f0105fd9:	0f 82 6f ff ff ff    	jb     f0105f4e <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105fdf:	a1 c0 33 21 f0       	mov    0xf02133c0,%eax
f0105fe4:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105feb:	83 3d 00 30 21 f0 00 	cmpl   $0x0,0xf0213000
f0105ff2:	75 26                	jne    f010601a <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105ff4:	c7 05 c4 33 21 f0 01 	movl   $0x1,0xf02133c4
f0105ffb:	00 00 00 
		lapicaddr = 0;
f0105ffe:	c7 05 00 40 25 f0 00 	movl   $0x0,0xf0254000
f0106005:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106008:	83 ec 0c             	sub    $0xc,%esp
f010600b:	68 d0 83 10 f0       	push   $0xf01083d0
f0106010:	e8 ca d9 ff ff       	call   f01039df <cprintf>
		return;
f0106015:	83 c4 10             	add    $0x10,%esp
f0106018:	eb 48                	jmp    f0106062 <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f010601a:	83 ec 04             	sub    $0x4,%esp
f010601d:	ff 35 c4 33 21 f0    	pushl  0xf02133c4
f0106023:	0f b6 00             	movzbl (%eax),%eax
f0106026:	50                   	push   %eax
f0106027:	68 57 84 10 f0       	push   $0xf0108457
f010602c:	e8 ae d9 ff ff       	call   f01039df <cprintf>

	if (mp->imcrp) {
f0106031:	83 c4 10             	add    $0x10,%esp
f0106034:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106037:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f010603b:	74 25                	je     f0106062 <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f010603d:	83 ec 0c             	sub    $0xc,%esp
f0106040:	68 fc 83 10 f0       	push   $0xf01083fc
f0106045:	e8 95 d9 ff ff       	call   f01039df <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010604a:	ba 22 00 00 00       	mov    $0x22,%edx
f010604f:	b8 70 00 00 00       	mov    $0x70,%eax
f0106054:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106055:	ba 23 00 00 00       	mov    $0x23,%edx
f010605a:	ec                   	in     (%dx),%al
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010605b:	83 c8 01             	or     $0x1,%eax
f010605e:	ee                   	out    %al,(%dx)
f010605f:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0106062:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106065:	5b                   	pop    %ebx
f0106066:	5e                   	pop    %esi
f0106067:	5f                   	pop    %edi
f0106068:	5d                   	pop    %ebp
f0106069:	c3                   	ret    

f010606a <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f010606a:	55                   	push   %ebp
f010606b:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f010606d:	8b 0d 04 40 25 f0    	mov    0xf0254004,%ecx
f0106073:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0106076:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106078:	a1 04 40 25 f0       	mov    0xf0254004,%eax
f010607d:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106080:	5d                   	pop    %ebp
f0106081:	c3                   	ret    

f0106082 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106082:	55                   	push   %ebp
f0106083:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106085:	a1 04 40 25 f0       	mov    0xf0254004,%eax
f010608a:	85 c0                	test   %eax,%eax
f010608c:	74 08                	je     f0106096 <cpunum+0x14>
		return lapic[ID] >> 24;
f010608e:	8b 40 20             	mov    0x20(%eax),%eax
f0106091:	c1 e8 18             	shr    $0x18,%eax
f0106094:	eb 05                	jmp    f010609b <cpunum+0x19>
	return 0;
f0106096:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010609b:	5d                   	pop    %ebp
f010609c:	c3                   	ret    

f010609d <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f010609d:	a1 00 40 25 f0       	mov    0xf0254000,%eax
f01060a2:	85 c0                	test   %eax,%eax
f01060a4:	0f 84 21 01 00 00    	je     f01061cb <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f01060aa:	55                   	push   %ebp
f01060ab:	89 e5                	mov    %esp,%ebp
f01060ad:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f01060b0:	68 00 10 00 00       	push   $0x1000
f01060b5:	50                   	push   %eax
f01060b6:	e8 5b b3 ff ff       	call   f0101416 <mmio_map_region>
f01060bb:	a3 04 40 25 f0       	mov    %eax,0xf0254004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f01060c0:	ba 27 01 00 00       	mov    $0x127,%edx
f01060c5:	b8 3c 00 00 00       	mov    $0x3c,%eax
f01060ca:	e8 9b ff ff ff       	call   f010606a <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f01060cf:	ba 0b 00 00 00       	mov    $0xb,%edx
f01060d4:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01060d9:	e8 8c ff ff ff       	call   f010606a <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01060de:	ba 20 00 02 00       	mov    $0x20020,%edx
f01060e3:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01060e8:	e8 7d ff ff ff       	call   f010606a <lapicw>
	lapicw(TICR, 10000000); 
f01060ed:	ba 80 96 98 00       	mov    $0x989680,%edx
f01060f2:	b8 e0 00 00 00       	mov    $0xe0,%eax
f01060f7:	e8 6e ff ff ff       	call   f010606a <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f01060fc:	e8 81 ff ff ff       	call   f0106082 <cpunum>
f0106101:	6b c0 74             	imul   $0x74,%eax,%eax
f0106104:	05 20 30 21 f0       	add    $0xf0213020,%eax
f0106109:	83 c4 10             	add    $0x10,%esp
f010610c:	39 05 c0 33 21 f0    	cmp    %eax,0xf02133c0
f0106112:	74 0f                	je     f0106123 <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0106114:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106119:	b8 d4 00 00 00       	mov    $0xd4,%eax
f010611e:	e8 47 ff ff ff       	call   f010606a <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0106123:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106128:	b8 d8 00 00 00       	mov    $0xd8,%eax
f010612d:	e8 38 ff ff ff       	call   f010606a <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0106132:	a1 04 40 25 f0       	mov    0xf0254004,%eax
f0106137:	8b 40 30             	mov    0x30(%eax),%eax
f010613a:	c1 e8 10             	shr    $0x10,%eax
f010613d:	3c 03                	cmp    $0x3,%al
f010613f:	76 0f                	jbe    f0106150 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0106141:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106146:	b8 d0 00 00 00       	mov    $0xd0,%eax
f010614b:	e8 1a ff ff ff       	call   f010606a <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106150:	ba 33 00 00 00       	mov    $0x33,%edx
f0106155:	b8 dc 00 00 00       	mov    $0xdc,%eax
f010615a:	e8 0b ff ff ff       	call   f010606a <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f010615f:	ba 00 00 00 00       	mov    $0x0,%edx
f0106164:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106169:	e8 fc fe ff ff       	call   f010606a <lapicw>
	lapicw(ESR, 0);
f010616e:	ba 00 00 00 00       	mov    $0x0,%edx
f0106173:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106178:	e8 ed fe ff ff       	call   f010606a <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f010617d:	ba 00 00 00 00       	mov    $0x0,%edx
f0106182:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106187:	e8 de fe ff ff       	call   f010606a <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f010618c:	ba 00 00 00 00       	mov    $0x0,%edx
f0106191:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106196:	e8 cf fe ff ff       	call   f010606a <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f010619b:	ba 00 85 08 00       	mov    $0x88500,%edx
f01061a0:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01061a5:	e8 c0 fe ff ff       	call   f010606a <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01061aa:	8b 15 04 40 25 f0    	mov    0xf0254004,%edx
f01061b0:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01061b6:	f6 c4 10             	test   $0x10,%ah
f01061b9:	75 f5                	jne    f01061b0 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f01061bb:	ba 00 00 00 00       	mov    $0x0,%edx
f01061c0:	b8 20 00 00 00       	mov    $0x20,%eax
f01061c5:	e8 a0 fe ff ff       	call   f010606a <lapicw>
}
f01061ca:	c9                   	leave  
f01061cb:	f3 c3                	repz ret 

f01061cd <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f01061cd:	83 3d 04 40 25 f0 00 	cmpl   $0x0,0xf0254004
f01061d4:	74 13                	je     f01061e9 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f01061d6:	55                   	push   %ebp
f01061d7:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f01061d9:	ba 00 00 00 00       	mov    $0x0,%edx
f01061de:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01061e3:	e8 82 fe ff ff       	call   f010606a <lapicw>
}
f01061e8:	5d                   	pop    %ebp
f01061e9:	f3 c3                	repz ret 

f01061eb <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01061eb:	55                   	push   %ebp
f01061ec:	89 e5                	mov    %esp,%ebp
f01061ee:	56                   	push   %esi
f01061ef:	53                   	push   %ebx
f01061f0:	8b 75 08             	mov    0x8(%ebp),%esi
f01061f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01061f6:	ba 70 00 00 00       	mov    $0x70,%edx
f01061fb:	b8 0f 00 00 00       	mov    $0xf,%eax
f0106200:	ee                   	out    %al,(%dx)
f0106201:	ba 71 00 00 00       	mov    $0x71,%edx
f0106206:	b8 0a 00 00 00       	mov    $0xa,%eax
f010620b:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010620c:	83 3d 88 2e 21 f0 00 	cmpl   $0x0,0xf0212e88
f0106213:	75 19                	jne    f010622e <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106215:	68 67 04 00 00       	push   $0x467
f010621a:	68 44 67 10 f0       	push   $0xf0106744
f010621f:	68 98 00 00 00       	push   $0x98
f0106224:	68 74 84 10 f0       	push   $0xf0108474
f0106229:	e8 12 9e ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f010622e:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106235:	00 00 
	wrv[1] = addr >> 4;
f0106237:	89 d8                	mov    %ebx,%eax
f0106239:	c1 e8 04             	shr    $0x4,%eax
f010623c:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106242:	c1 e6 18             	shl    $0x18,%esi
f0106245:	89 f2                	mov    %esi,%edx
f0106247:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010624c:	e8 19 fe ff ff       	call   f010606a <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106251:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106256:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010625b:	e8 0a fe ff ff       	call   f010606a <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106260:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106265:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010626a:	e8 fb fd ff ff       	call   f010606a <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010626f:	c1 eb 0c             	shr    $0xc,%ebx
f0106272:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106275:	89 f2                	mov    %esi,%edx
f0106277:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010627c:	e8 e9 fd ff ff       	call   f010606a <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106281:	89 da                	mov    %ebx,%edx
f0106283:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106288:	e8 dd fd ff ff       	call   f010606a <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010628d:	89 f2                	mov    %esi,%edx
f010628f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106294:	e8 d1 fd ff ff       	call   f010606a <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106299:	89 da                	mov    %ebx,%edx
f010629b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01062a0:	e8 c5 fd ff ff       	call   f010606a <lapicw>
		microdelay(200);
	}
}
f01062a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01062a8:	5b                   	pop    %ebx
f01062a9:	5e                   	pop    %esi
f01062aa:	5d                   	pop    %ebp
f01062ab:	c3                   	ret    

f01062ac <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01062ac:	55                   	push   %ebp
f01062ad:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01062af:	8b 55 08             	mov    0x8(%ebp),%edx
f01062b2:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f01062b8:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01062bd:	e8 a8 fd ff ff       	call   f010606a <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01062c2:	8b 15 04 40 25 f0    	mov    0xf0254004,%edx
f01062c8:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01062ce:	f6 c4 10             	test   $0x10,%ah
f01062d1:	75 f5                	jne    f01062c8 <lapic_ipi+0x1c>
		;
}
f01062d3:	5d                   	pop    %ebp
f01062d4:	c3                   	ret    

f01062d5 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01062d5:	55                   	push   %ebp
f01062d6:	89 e5                	mov    %esp,%ebp
f01062d8:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01062db:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01062e1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01062e4:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01062e7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01062ee:	5d                   	pop    %ebp
f01062ef:	c3                   	ret    

f01062f0 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01062f0:	55                   	push   %ebp
f01062f1:	89 e5                	mov    %esp,%ebp
f01062f3:	56                   	push   %esi
f01062f4:	53                   	push   %ebx
f01062f5:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f01062f8:	83 3b 00             	cmpl   $0x0,(%ebx)
f01062fb:	74 14                	je     f0106311 <spin_lock+0x21>
f01062fd:	8b 73 08             	mov    0x8(%ebx),%esi
f0106300:	e8 7d fd ff ff       	call   f0106082 <cpunum>
f0106305:	6b c0 74             	imul   $0x74,%eax,%eax
f0106308:	05 20 30 21 f0       	add    $0xf0213020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f010630d:	39 c6                	cmp    %eax,%esi
f010630f:	74 07                	je     f0106318 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0106311:	ba 01 00 00 00       	mov    $0x1,%edx
f0106316:	eb 20                	jmp    f0106338 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106318:	8b 5b 04             	mov    0x4(%ebx),%ebx
f010631b:	e8 62 fd ff ff       	call   f0106082 <cpunum>
f0106320:	83 ec 0c             	sub    $0xc,%esp
f0106323:	53                   	push   %ebx
f0106324:	50                   	push   %eax
f0106325:	68 84 84 10 f0       	push   $0xf0108484
f010632a:	6a 41                	push   $0x41
f010632c:	68 e8 84 10 f0       	push   $0xf01084e8
f0106331:	e8 0a 9d ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106336:	f3 90                	pause  
f0106338:	89 d0                	mov    %edx,%eax
f010633a:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f010633d:	85 c0                	test   %eax,%eax
f010633f:	75 f5                	jne    f0106336 <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106341:	e8 3c fd ff ff       	call   f0106082 <cpunum>
f0106346:	6b c0 74             	imul   $0x74,%eax,%eax
f0106349:	05 20 30 21 f0       	add    $0xf0213020,%eax
f010634e:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106351:	83 c3 0c             	add    $0xc,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0106354:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106356:	b8 00 00 00 00       	mov    $0x0,%eax
f010635b:	eb 0b                	jmp    f0106368 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f010635d:	8b 4a 04             	mov    0x4(%edx),%ecx
f0106360:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106363:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106365:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106368:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f010636e:	76 11                	jbe    f0106381 <spin_lock+0x91>
f0106370:	83 f8 09             	cmp    $0x9,%eax
f0106373:	7e e8                	jle    f010635d <spin_lock+0x6d>
f0106375:	eb 0a                	jmp    f0106381 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0106377:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f010637e:	83 c0 01             	add    $0x1,%eax
f0106381:	83 f8 09             	cmp    $0x9,%eax
f0106384:	7e f1                	jle    f0106377 <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0106386:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106389:	5b                   	pop    %ebx
f010638a:	5e                   	pop    %esi
f010638b:	5d                   	pop    %ebp
f010638c:	c3                   	ret    

f010638d <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f010638d:	55                   	push   %ebp
f010638e:	89 e5                	mov    %esp,%ebp
f0106390:	57                   	push   %edi
f0106391:	56                   	push   %esi
f0106392:	53                   	push   %ebx
f0106393:	83 ec 4c             	sub    $0x4c,%esp
f0106396:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0106399:	83 3e 00             	cmpl   $0x0,(%esi)
f010639c:	74 18                	je     f01063b6 <spin_unlock+0x29>
f010639e:	8b 5e 08             	mov    0x8(%esi),%ebx
f01063a1:	e8 dc fc ff ff       	call   f0106082 <cpunum>
f01063a6:	6b c0 74             	imul   $0x74,%eax,%eax
f01063a9:	05 20 30 21 f0       	add    $0xf0213020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f01063ae:	39 c3                	cmp    %eax,%ebx
f01063b0:	0f 84 a5 00 00 00    	je     f010645b <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01063b6:	83 ec 04             	sub    $0x4,%esp
f01063b9:	6a 28                	push   $0x28
f01063bb:	8d 46 0c             	lea    0xc(%esi),%eax
f01063be:	50                   	push   %eax
f01063bf:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f01063c2:	53                   	push   %ebx
f01063c3:	e8 e6 f6 ff ff       	call   f0105aae <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01063c8:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01063cb:	0f b6 38             	movzbl (%eax),%edi
f01063ce:	8b 76 04             	mov    0x4(%esi),%esi
f01063d1:	e8 ac fc ff ff       	call   f0106082 <cpunum>
f01063d6:	57                   	push   %edi
f01063d7:	56                   	push   %esi
f01063d8:	50                   	push   %eax
f01063d9:	68 b0 84 10 f0       	push   $0xf01084b0
f01063de:	e8 fc d5 ff ff       	call   f01039df <cprintf>
f01063e3:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01063e6:	8d 7d a8             	lea    -0x58(%ebp),%edi
f01063e9:	eb 54                	jmp    f010643f <spin_unlock+0xb2>
f01063eb:	83 ec 08             	sub    $0x8,%esp
f01063ee:	57                   	push   %edi
f01063ef:	50                   	push   %eax
f01063f0:	e8 84 ec ff ff       	call   f0105079 <debuginfo_eip>
f01063f5:	83 c4 10             	add    $0x10,%esp
f01063f8:	85 c0                	test   %eax,%eax
f01063fa:	78 27                	js     f0106423 <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f01063fc:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01063fe:	83 ec 04             	sub    $0x4,%esp
f0106401:	89 c2                	mov    %eax,%edx
f0106403:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0106406:	52                   	push   %edx
f0106407:	ff 75 b0             	pushl  -0x50(%ebp)
f010640a:	ff 75 b4             	pushl  -0x4c(%ebp)
f010640d:	ff 75 ac             	pushl  -0x54(%ebp)
f0106410:	ff 75 a8             	pushl  -0x58(%ebp)
f0106413:	50                   	push   %eax
f0106414:	68 f8 84 10 f0       	push   $0xf01084f8
f0106419:	e8 c1 d5 ff ff       	call   f01039df <cprintf>
f010641e:	83 c4 20             	add    $0x20,%esp
f0106421:	eb 12                	jmp    f0106435 <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106423:	83 ec 08             	sub    $0x8,%esp
f0106426:	ff 36                	pushl  (%esi)
f0106428:	68 0f 85 10 f0       	push   $0xf010850f
f010642d:	e8 ad d5 ff ff       	call   f01039df <cprintf>
f0106432:	83 c4 10             	add    $0x10,%esp
f0106435:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106438:	8d 45 e8             	lea    -0x18(%ebp),%eax
f010643b:	39 c3                	cmp    %eax,%ebx
f010643d:	74 08                	je     f0106447 <spin_unlock+0xba>
f010643f:	89 de                	mov    %ebx,%esi
f0106441:	8b 03                	mov    (%ebx),%eax
f0106443:	85 c0                	test   %eax,%eax
f0106445:	75 a4                	jne    f01063eb <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0106447:	83 ec 04             	sub    $0x4,%esp
f010644a:	68 17 85 10 f0       	push   $0xf0108517
f010644f:	6a 67                	push   $0x67
f0106451:	68 e8 84 10 f0       	push   $0xf01084e8
f0106456:	e8 e5 9b ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f010645b:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0106462:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0106469:	b8 00 00 00 00       	mov    $0x0,%eax
f010646e:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0106471:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106474:	5b                   	pop    %ebx
f0106475:	5e                   	pop    %esi
f0106476:	5f                   	pop    %edi
f0106477:	5d                   	pop    %ebp
f0106478:	c3                   	ret    
f0106479:	66 90                	xchg   %ax,%ax
f010647b:	66 90                	xchg   %ax,%ax
f010647d:	66 90                	xchg   %ax,%ax
f010647f:	90                   	nop

f0106480 <__udivdi3>:
f0106480:	55                   	push   %ebp
f0106481:	57                   	push   %edi
f0106482:	56                   	push   %esi
f0106483:	53                   	push   %ebx
f0106484:	83 ec 1c             	sub    $0x1c,%esp
f0106487:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010648b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010648f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0106493:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106497:	85 f6                	test   %esi,%esi
f0106499:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010649d:	89 ca                	mov    %ecx,%edx
f010649f:	89 f8                	mov    %edi,%eax
f01064a1:	75 3d                	jne    f01064e0 <__udivdi3+0x60>
f01064a3:	39 cf                	cmp    %ecx,%edi
f01064a5:	0f 87 c5 00 00 00    	ja     f0106570 <__udivdi3+0xf0>
f01064ab:	85 ff                	test   %edi,%edi
f01064ad:	89 fd                	mov    %edi,%ebp
f01064af:	75 0b                	jne    f01064bc <__udivdi3+0x3c>
f01064b1:	b8 01 00 00 00       	mov    $0x1,%eax
f01064b6:	31 d2                	xor    %edx,%edx
f01064b8:	f7 f7                	div    %edi
f01064ba:	89 c5                	mov    %eax,%ebp
f01064bc:	89 c8                	mov    %ecx,%eax
f01064be:	31 d2                	xor    %edx,%edx
f01064c0:	f7 f5                	div    %ebp
f01064c2:	89 c1                	mov    %eax,%ecx
f01064c4:	89 d8                	mov    %ebx,%eax
f01064c6:	89 cf                	mov    %ecx,%edi
f01064c8:	f7 f5                	div    %ebp
f01064ca:	89 c3                	mov    %eax,%ebx
f01064cc:	89 d8                	mov    %ebx,%eax
f01064ce:	89 fa                	mov    %edi,%edx
f01064d0:	83 c4 1c             	add    $0x1c,%esp
f01064d3:	5b                   	pop    %ebx
f01064d4:	5e                   	pop    %esi
f01064d5:	5f                   	pop    %edi
f01064d6:	5d                   	pop    %ebp
f01064d7:	c3                   	ret    
f01064d8:	90                   	nop
f01064d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01064e0:	39 ce                	cmp    %ecx,%esi
f01064e2:	77 74                	ja     f0106558 <__udivdi3+0xd8>
f01064e4:	0f bd fe             	bsr    %esi,%edi
f01064e7:	83 f7 1f             	xor    $0x1f,%edi
f01064ea:	0f 84 98 00 00 00    	je     f0106588 <__udivdi3+0x108>
f01064f0:	bb 20 00 00 00       	mov    $0x20,%ebx
f01064f5:	89 f9                	mov    %edi,%ecx
f01064f7:	89 c5                	mov    %eax,%ebp
f01064f9:	29 fb                	sub    %edi,%ebx
f01064fb:	d3 e6                	shl    %cl,%esi
f01064fd:	89 d9                	mov    %ebx,%ecx
f01064ff:	d3 ed                	shr    %cl,%ebp
f0106501:	89 f9                	mov    %edi,%ecx
f0106503:	d3 e0                	shl    %cl,%eax
f0106505:	09 ee                	or     %ebp,%esi
f0106507:	89 d9                	mov    %ebx,%ecx
f0106509:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010650d:	89 d5                	mov    %edx,%ebp
f010650f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106513:	d3 ed                	shr    %cl,%ebp
f0106515:	89 f9                	mov    %edi,%ecx
f0106517:	d3 e2                	shl    %cl,%edx
f0106519:	89 d9                	mov    %ebx,%ecx
f010651b:	d3 e8                	shr    %cl,%eax
f010651d:	09 c2                	or     %eax,%edx
f010651f:	89 d0                	mov    %edx,%eax
f0106521:	89 ea                	mov    %ebp,%edx
f0106523:	f7 f6                	div    %esi
f0106525:	89 d5                	mov    %edx,%ebp
f0106527:	89 c3                	mov    %eax,%ebx
f0106529:	f7 64 24 0c          	mull   0xc(%esp)
f010652d:	39 d5                	cmp    %edx,%ebp
f010652f:	72 10                	jb     f0106541 <__udivdi3+0xc1>
f0106531:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106535:	89 f9                	mov    %edi,%ecx
f0106537:	d3 e6                	shl    %cl,%esi
f0106539:	39 c6                	cmp    %eax,%esi
f010653b:	73 07                	jae    f0106544 <__udivdi3+0xc4>
f010653d:	39 d5                	cmp    %edx,%ebp
f010653f:	75 03                	jne    f0106544 <__udivdi3+0xc4>
f0106541:	83 eb 01             	sub    $0x1,%ebx
f0106544:	31 ff                	xor    %edi,%edi
f0106546:	89 d8                	mov    %ebx,%eax
f0106548:	89 fa                	mov    %edi,%edx
f010654a:	83 c4 1c             	add    $0x1c,%esp
f010654d:	5b                   	pop    %ebx
f010654e:	5e                   	pop    %esi
f010654f:	5f                   	pop    %edi
f0106550:	5d                   	pop    %ebp
f0106551:	c3                   	ret    
f0106552:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106558:	31 ff                	xor    %edi,%edi
f010655a:	31 db                	xor    %ebx,%ebx
f010655c:	89 d8                	mov    %ebx,%eax
f010655e:	89 fa                	mov    %edi,%edx
f0106560:	83 c4 1c             	add    $0x1c,%esp
f0106563:	5b                   	pop    %ebx
f0106564:	5e                   	pop    %esi
f0106565:	5f                   	pop    %edi
f0106566:	5d                   	pop    %ebp
f0106567:	c3                   	ret    
f0106568:	90                   	nop
f0106569:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106570:	89 d8                	mov    %ebx,%eax
f0106572:	f7 f7                	div    %edi
f0106574:	31 ff                	xor    %edi,%edi
f0106576:	89 c3                	mov    %eax,%ebx
f0106578:	89 d8                	mov    %ebx,%eax
f010657a:	89 fa                	mov    %edi,%edx
f010657c:	83 c4 1c             	add    $0x1c,%esp
f010657f:	5b                   	pop    %ebx
f0106580:	5e                   	pop    %esi
f0106581:	5f                   	pop    %edi
f0106582:	5d                   	pop    %ebp
f0106583:	c3                   	ret    
f0106584:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106588:	39 ce                	cmp    %ecx,%esi
f010658a:	72 0c                	jb     f0106598 <__udivdi3+0x118>
f010658c:	31 db                	xor    %ebx,%ebx
f010658e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0106592:	0f 87 34 ff ff ff    	ja     f01064cc <__udivdi3+0x4c>
f0106598:	bb 01 00 00 00       	mov    $0x1,%ebx
f010659d:	e9 2a ff ff ff       	jmp    f01064cc <__udivdi3+0x4c>
f01065a2:	66 90                	xchg   %ax,%ax
f01065a4:	66 90                	xchg   %ax,%ax
f01065a6:	66 90                	xchg   %ax,%ax
f01065a8:	66 90                	xchg   %ax,%ax
f01065aa:	66 90                	xchg   %ax,%ax
f01065ac:	66 90                	xchg   %ax,%ax
f01065ae:	66 90                	xchg   %ax,%ax

f01065b0 <__umoddi3>:
f01065b0:	55                   	push   %ebp
f01065b1:	57                   	push   %edi
f01065b2:	56                   	push   %esi
f01065b3:	53                   	push   %ebx
f01065b4:	83 ec 1c             	sub    $0x1c,%esp
f01065b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01065bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f01065bf:	8b 74 24 34          	mov    0x34(%esp),%esi
f01065c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01065c7:	85 d2                	test   %edx,%edx
f01065c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01065cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01065d1:	89 f3                	mov    %esi,%ebx
f01065d3:	89 3c 24             	mov    %edi,(%esp)
f01065d6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01065da:	75 1c                	jne    f01065f8 <__umoddi3+0x48>
f01065dc:	39 f7                	cmp    %esi,%edi
f01065de:	76 50                	jbe    f0106630 <__umoddi3+0x80>
f01065e0:	89 c8                	mov    %ecx,%eax
f01065e2:	89 f2                	mov    %esi,%edx
f01065e4:	f7 f7                	div    %edi
f01065e6:	89 d0                	mov    %edx,%eax
f01065e8:	31 d2                	xor    %edx,%edx
f01065ea:	83 c4 1c             	add    $0x1c,%esp
f01065ed:	5b                   	pop    %ebx
f01065ee:	5e                   	pop    %esi
f01065ef:	5f                   	pop    %edi
f01065f0:	5d                   	pop    %ebp
f01065f1:	c3                   	ret    
f01065f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01065f8:	39 f2                	cmp    %esi,%edx
f01065fa:	89 d0                	mov    %edx,%eax
f01065fc:	77 52                	ja     f0106650 <__umoddi3+0xa0>
f01065fe:	0f bd ea             	bsr    %edx,%ebp
f0106601:	83 f5 1f             	xor    $0x1f,%ebp
f0106604:	75 5a                	jne    f0106660 <__umoddi3+0xb0>
f0106606:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010660a:	0f 82 e0 00 00 00    	jb     f01066f0 <__umoddi3+0x140>
f0106610:	39 0c 24             	cmp    %ecx,(%esp)
f0106613:	0f 86 d7 00 00 00    	jbe    f01066f0 <__umoddi3+0x140>
f0106619:	8b 44 24 08          	mov    0x8(%esp),%eax
f010661d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106621:	83 c4 1c             	add    $0x1c,%esp
f0106624:	5b                   	pop    %ebx
f0106625:	5e                   	pop    %esi
f0106626:	5f                   	pop    %edi
f0106627:	5d                   	pop    %ebp
f0106628:	c3                   	ret    
f0106629:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106630:	85 ff                	test   %edi,%edi
f0106632:	89 fd                	mov    %edi,%ebp
f0106634:	75 0b                	jne    f0106641 <__umoddi3+0x91>
f0106636:	b8 01 00 00 00       	mov    $0x1,%eax
f010663b:	31 d2                	xor    %edx,%edx
f010663d:	f7 f7                	div    %edi
f010663f:	89 c5                	mov    %eax,%ebp
f0106641:	89 f0                	mov    %esi,%eax
f0106643:	31 d2                	xor    %edx,%edx
f0106645:	f7 f5                	div    %ebp
f0106647:	89 c8                	mov    %ecx,%eax
f0106649:	f7 f5                	div    %ebp
f010664b:	89 d0                	mov    %edx,%eax
f010664d:	eb 99                	jmp    f01065e8 <__umoddi3+0x38>
f010664f:	90                   	nop
f0106650:	89 c8                	mov    %ecx,%eax
f0106652:	89 f2                	mov    %esi,%edx
f0106654:	83 c4 1c             	add    $0x1c,%esp
f0106657:	5b                   	pop    %ebx
f0106658:	5e                   	pop    %esi
f0106659:	5f                   	pop    %edi
f010665a:	5d                   	pop    %ebp
f010665b:	c3                   	ret    
f010665c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106660:	8b 34 24             	mov    (%esp),%esi
f0106663:	bf 20 00 00 00       	mov    $0x20,%edi
f0106668:	89 e9                	mov    %ebp,%ecx
f010666a:	29 ef                	sub    %ebp,%edi
f010666c:	d3 e0                	shl    %cl,%eax
f010666e:	89 f9                	mov    %edi,%ecx
f0106670:	89 f2                	mov    %esi,%edx
f0106672:	d3 ea                	shr    %cl,%edx
f0106674:	89 e9                	mov    %ebp,%ecx
f0106676:	09 c2                	or     %eax,%edx
f0106678:	89 d8                	mov    %ebx,%eax
f010667a:	89 14 24             	mov    %edx,(%esp)
f010667d:	89 f2                	mov    %esi,%edx
f010667f:	d3 e2                	shl    %cl,%edx
f0106681:	89 f9                	mov    %edi,%ecx
f0106683:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106687:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010668b:	d3 e8                	shr    %cl,%eax
f010668d:	89 e9                	mov    %ebp,%ecx
f010668f:	89 c6                	mov    %eax,%esi
f0106691:	d3 e3                	shl    %cl,%ebx
f0106693:	89 f9                	mov    %edi,%ecx
f0106695:	89 d0                	mov    %edx,%eax
f0106697:	d3 e8                	shr    %cl,%eax
f0106699:	89 e9                	mov    %ebp,%ecx
f010669b:	09 d8                	or     %ebx,%eax
f010669d:	89 d3                	mov    %edx,%ebx
f010669f:	89 f2                	mov    %esi,%edx
f01066a1:	f7 34 24             	divl   (%esp)
f01066a4:	89 d6                	mov    %edx,%esi
f01066a6:	d3 e3                	shl    %cl,%ebx
f01066a8:	f7 64 24 04          	mull   0x4(%esp)
f01066ac:	39 d6                	cmp    %edx,%esi
f01066ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01066b2:	89 d1                	mov    %edx,%ecx
f01066b4:	89 c3                	mov    %eax,%ebx
f01066b6:	72 08                	jb     f01066c0 <__umoddi3+0x110>
f01066b8:	75 11                	jne    f01066cb <__umoddi3+0x11b>
f01066ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01066be:	73 0b                	jae    f01066cb <__umoddi3+0x11b>
f01066c0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01066c4:	1b 14 24             	sbb    (%esp),%edx
f01066c7:	89 d1                	mov    %edx,%ecx
f01066c9:	89 c3                	mov    %eax,%ebx
f01066cb:	8b 54 24 08          	mov    0x8(%esp),%edx
f01066cf:	29 da                	sub    %ebx,%edx
f01066d1:	19 ce                	sbb    %ecx,%esi
f01066d3:	89 f9                	mov    %edi,%ecx
f01066d5:	89 f0                	mov    %esi,%eax
f01066d7:	d3 e0                	shl    %cl,%eax
f01066d9:	89 e9                	mov    %ebp,%ecx
f01066db:	d3 ea                	shr    %cl,%edx
f01066dd:	89 e9                	mov    %ebp,%ecx
f01066df:	d3 ee                	shr    %cl,%esi
f01066e1:	09 d0                	or     %edx,%eax
f01066e3:	89 f2                	mov    %esi,%edx
f01066e5:	83 c4 1c             	add    $0x1c,%esp
f01066e8:	5b                   	pop    %ebx
f01066e9:	5e                   	pop    %esi
f01066ea:	5f                   	pop    %edi
f01066eb:	5d                   	pop    %ebp
f01066ec:	c3                   	ret    
f01066ed:	8d 76 00             	lea    0x0(%esi),%esi
f01066f0:	29 f9                	sub    %edi,%ecx
f01066f2:	19 d6                	sbb    %edx,%esi
f01066f4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01066f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01066fc:	e9 18 ff ff ff       	jmp    f0106619 <__umoddi3+0x69>
