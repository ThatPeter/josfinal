
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
f0100048:	83 3d 80 6e 21 f0 00 	cmpl   $0x0,0xf0216e80
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 80 6e 21 f0    	mov    %esi,0xf0216e80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 a1 61 00 00       	call   f0106202 <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 a0 68 10 f0       	push   $0xf01068a0
f010006d:	e8 ae 3a 00 00       	call   f0103b20 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 7e 3a 00 00       	call   f0103afa <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 da 80 10 f0 	movl   $0xf01080da,(%esp)
f0100083:	e8 98 3a 00 00       	call   f0103b20 <cprintf>
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
f01000a1:	b8 08 80 25 f0       	mov    $0xf0258008,%eax
f01000a6:	2d 64 53 21 f0       	sub    $0xf0215364,%eax
f01000ab:	50                   	push   %eax
f01000ac:	6a 00                	push   $0x0
f01000ae:	68 64 53 21 f0       	push   $0xf0215364
f01000b3:	e8 27 5b 00 00       	call   f0105bdf <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b8:	e8 96 05 00 00       	call   f0100653 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000bd:	83 c4 08             	add    $0x8,%esp
f01000c0:	68 ac 1a 00 00       	push   $0x1aac
f01000c5:	68 0c 69 10 f0       	push   $0xf010690c
f01000ca:	e8 51 3a 00 00       	call   f0103b20 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000cf:	e8 bd 13 00 00       	call   f0101491 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000d4:	e8 ac 30 00 00       	call   f0103185 <env_init>
	trap_init();
f01000d9:	e8 3d 3b 00 00       	call   f0103c1b <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000de:	e8 15 5e 00 00       	call   f0105ef8 <mp_init>
	lapic_init();
f01000e3:	e8 35 61 00 00       	call   f010621d <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000e8:	e8 5a 39 00 00       	call   f0103a47 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000ed:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f01000f4:	e8 77 63 00 00       	call   f0106470 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000f9:	83 c4 10             	add    $0x10,%esp
f01000fc:	83 3d 88 6e 21 f0 07 	cmpl   $0x7,0xf0216e88
f0100103:	77 16                	ja     f010011b <i386_init+0x81>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100105:	68 00 70 00 00       	push   $0x7000
f010010a:	68 c4 68 10 f0       	push   $0xf01068c4
f010010f:	6a 58                	push   $0x58
f0100111:	68 27 69 10 f0       	push   $0xf0106927
f0100116:	e8 25 ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010011b:	83 ec 04             	sub    $0x4,%esp
f010011e:	b8 5e 5e 10 f0       	mov    $0xf0105e5e,%eax
f0100123:	2d e4 5d 10 f0       	sub    $0xf0105de4,%eax
f0100128:	50                   	push   %eax
f0100129:	68 e4 5d 10 f0       	push   $0xf0105de4
f010012e:	68 00 70 00 f0       	push   $0xf0007000
f0100133:	e8 f4 5a 00 00       	call   f0105c2c <memmove>
f0100138:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010013b:	bb 20 70 21 f0       	mov    $0xf0217020,%ebx
f0100140:	eb 4d                	jmp    f010018f <i386_init+0xf5>
		if (c == cpus + cpunum())  // We've started already.
f0100142:	e8 bb 60 00 00       	call   f0106202 <cpunum>
f0100147:	6b c0 74             	imul   $0x74,%eax,%eax
f010014a:	05 20 70 21 f0       	add    $0xf0217020,%eax
f010014f:	39 c3                	cmp    %eax,%ebx
f0100151:	74 39                	je     f010018c <i386_init+0xf2>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100153:	89 d8                	mov    %ebx,%eax
f0100155:	2d 20 70 21 f0       	sub    $0xf0217020,%eax
f010015a:	c1 f8 02             	sar    $0x2,%eax
f010015d:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100163:	c1 e0 0f             	shl    $0xf,%eax
f0100166:	05 00 00 22 f0       	add    $0xf0220000,%eax
f010016b:	a3 84 6e 21 f0       	mov    %eax,0xf0216e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100170:	83 ec 08             	sub    $0x8,%esp
f0100173:	68 00 70 00 00       	push   $0x7000
f0100178:	0f b6 03             	movzbl (%ebx),%eax
f010017b:	50                   	push   %eax
f010017c:	e8 ea 61 00 00       	call   f010636b <lapic_startap>
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
f010018f:	6b 05 c4 73 21 f0 74 	imul   $0x74,0xf02173c4,%eax
f0100196:	05 20 70 21 f0       	add    $0xf0217020,%eax
f010019b:	39 c3                	cmp    %eax,%ebx
f010019d:	72 a3                	jb     f0100142 <i386_init+0xa8>
	lock_kernel();

	// Starting non-boot CPUs
	boot_aps();

	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f010019f:	83 ec 08             	sub    $0x8,%esp
f01001a2:	6a 01                	push   $0x1
f01001a4:	68 b8 50 1d f0       	push   $0xf01d50b8
f01001a9:	e8 29 32 00 00       	call   f01033d7 <env_create>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001ae:	83 c4 08             	add    $0x8,%esp
f01001b1:	6a 00                	push   $0x0
f01001b3:	68 d8 03 21 f0       	push   $0xf02103d8
f01001b8:	e8 1a 32 00 00       	call   f01033d7 <env_create>
	// Touch all you want. Calls fork.
	ENV_CREATE(user_primes, ENV_TYPE_USER);
#endif // TEST* 
	
	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f01001bd:	e8 35 04 00 00       	call   f01005f7 <kbd_intr>
	// Schedule and run the first user environment!
	sched_yield();
f01001c2:	e8 c4 47 00 00       	call   f010498b <sched_yield>

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
f01001cd:	a1 8c 6e 21 f0       	mov    0xf0216e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001d2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001d7:	77 12                	ja     f01001eb <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001d9:	50                   	push   %eax
f01001da:	68 e8 68 10 f0       	push   $0xf01068e8
f01001df:	6a 6f                	push   $0x6f
f01001e1:	68 27 69 10 f0       	push   $0xf0106927
f01001e6:	e8 55 fe ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001eb:	05 00 00 00 10       	add    $0x10000000,%eax
f01001f0:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001f3:	e8 0a 60 00 00       	call   f0106202 <cpunum>
f01001f8:	83 ec 08             	sub    $0x8,%esp
f01001fb:	50                   	push   %eax
f01001fc:	68 33 69 10 f0       	push   $0xf0106933
f0100201:	e8 1a 39 00 00       	call   f0103b20 <cprintf>

	lapic_init();
f0100206:	e8 12 60 00 00       	call   f010621d <lapic_init>
	env_init_percpu();
f010020b:	e8 45 2f 00 00       	call   f0103155 <env_init_percpu>
	trap_init_percpu();
f0100210:	e8 1f 39 00 00       	call   f0103b34 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100215:	e8 e8 5f 00 00       	call   f0106202 <cpunum>
f010021a:	6b d0 74             	imul   $0x74,%eax,%edx
f010021d:	81 c2 20 70 21 f0    	add    $0xf0217020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100223:	b8 01 00 00 00       	mov    $0x1,%eax
f0100228:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010022c:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0100233:	e8 38 62 00 00       	call   f0106470 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100238:	e8 4e 47 00 00       	call   f010498b <sched_yield>

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
f010024d:	68 49 69 10 f0       	push   $0xf0106949
f0100252:	e8 c9 38 00 00       	call   f0103b20 <cprintf>
	vcprintf(fmt, ap);
f0100257:	83 c4 08             	add    $0x8,%esp
f010025a:	53                   	push   %ebx
f010025b:	ff 75 10             	pushl  0x10(%ebp)
f010025e:	e8 97 38 00 00       	call   f0103afa <vcprintf>
	cprintf("\n");
f0100263:	c7 04 24 da 80 10 f0 	movl   $0xf01080da,(%esp)
f010026a:	e8 b1 38 00 00       	call   f0103b20 <cprintf>
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
f01002a5:	8b 0d 24 62 21 f0    	mov    0xf0216224,%ecx
f01002ab:	8d 51 01             	lea    0x1(%ecx),%edx
f01002ae:	89 15 24 62 21 f0    	mov    %edx,0xf0216224
f01002b4:	88 81 20 60 21 f0    	mov    %al,-0xfde9fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002ba:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002c0:	75 0a                	jne    f01002cc <cons_intr+0x36>
			cons.wpos = 0;
f01002c2:	c7 05 24 62 21 f0 00 	movl   $0x0,0xf0216224
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
f01002fb:	83 0d 00 60 21 f0 40 	orl    $0x40,0xf0216000
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
f0100313:	8b 0d 00 60 21 f0    	mov    0xf0216000,%ecx
f0100319:	89 cb                	mov    %ecx,%ebx
f010031b:	83 e3 40             	and    $0x40,%ebx
f010031e:	83 e0 7f             	and    $0x7f,%eax
f0100321:	85 db                	test   %ebx,%ebx
f0100323:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100326:	0f b6 d2             	movzbl %dl,%edx
f0100329:	0f b6 82 c0 6a 10 f0 	movzbl -0xfef9540(%edx),%eax
f0100330:	83 c8 40             	or     $0x40,%eax
f0100333:	0f b6 c0             	movzbl %al,%eax
f0100336:	f7 d0                	not    %eax
f0100338:	21 c8                	and    %ecx,%eax
f010033a:	a3 00 60 21 f0       	mov    %eax,0xf0216000
		return 0;
f010033f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100344:	e9 a4 00 00 00       	jmp    f01003ed <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100349:	8b 0d 00 60 21 f0    	mov    0xf0216000,%ecx
f010034f:	f6 c1 40             	test   $0x40,%cl
f0100352:	74 0e                	je     f0100362 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100354:	83 c8 80             	or     $0xffffff80,%eax
f0100357:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100359:	83 e1 bf             	and    $0xffffffbf,%ecx
f010035c:	89 0d 00 60 21 f0    	mov    %ecx,0xf0216000
	}

	shift |= shiftcode[data];
f0100362:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100365:	0f b6 82 c0 6a 10 f0 	movzbl -0xfef9540(%edx),%eax
f010036c:	0b 05 00 60 21 f0    	or     0xf0216000,%eax
f0100372:	0f b6 8a c0 69 10 f0 	movzbl -0xfef9640(%edx),%ecx
f0100379:	31 c8                	xor    %ecx,%eax
f010037b:	a3 00 60 21 f0       	mov    %eax,0xf0216000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100380:	89 c1                	mov    %eax,%ecx
f0100382:	83 e1 03             	and    $0x3,%ecx
f0100385:	8b 0c 8d a0 69 10 f0 	mov    -0xfef9660(,%ecx,4),%ecx
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
f01003c3:	68 63 69 10 f0       	push   $0xf0106963
f01003c8:	e8 53 37 00 00       	call   f0103b20 <cprintf>
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
f01004af:	0f b7 05 28 62 21 f0 	movzwl 0xf0216228,%eax
f01004b6:	66 85 c0             	test   %ax,%ax
f01004b9:	0f 84 e6 00 00 00    	je     f01005a5 <cons_putc+0x1b3>
			crt_pos--;
f01004bf:	83 e8 01             	sub    $0x1,%eax
f01004c2:	66 a3 28 62 21 f0    	mov    %ax,0xf0216228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004c8:	0f b7 c0             	movzwl %ax,%eax
f01004cb:	66 81 e7 00 ff       	and    $0xff00,%di
f01004d0:	83 cf 20             	or     $0x20,%edi
f01004d3:	8b 15 2c 62 21 f0    	mov    0xf021622c,%edx
f01004d9:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004dd:	eb 78                	jmp    f0100557 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004df:	66 83 05 28 62 21 f0 	addw   $0x50,0xf0216228
f01004e6:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004e7:	0f b7 05 28 62 21 f0 	movzwl 0xf0216228,%eax
f01004ee:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004f4:	c1 e8 16             	shr    $0x16,%eax
f01004f7:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004fa:	c1 e0 04             	shl    $0x4,%eax
f01004fd:	66 a3 28 62 21 f0    	mov    %ax,0xf0216228
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
f0100539:	0f b7 05 28 62 21 f0 	movzwl 0xf0216228,%eax
f0100540:	8d 50 01             	lea    0x1(%eax),%edx
f0100543:	66 89 15 28 62 21 f0 	mov    %dx,0xf0216228
f010054a:	0f b7 c0             	movzwl %ax,%eax
f010054d:	8b 15 2c 62 21 f0    	mov    0xf021622c,%edx
f0100553:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100557:	66 81 3d 28 62 21 f0 	cmpw   $0x7cf,0xf0216228
f010055e:	cf 07 
f0100560:	76 43                	jbe    f01005a5 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100562:	a1 2c 62 21 f0       	mov    0xf021622c,%eax
f0100567:	83 ec 04             	sub    $0x4,%esp
f010056a:	68 00 0f 00 00       	push   $0xf00
f010056f:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100575:	52                   	push   %edx
f0100576:	50                   	push   %eax
f0100577:	e8 b0 56 00 00       	call   f0105c2c <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010057c:	8b 15 2c 62 21 f0    	mov    0xf021622c,%edx
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
f010059d:	66 83 2d 28 62 21 f0 	subw   $0x50,0xf0216228
f01005a4:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01005a5:	8b 0d 30 62 21 f0    	mov    0xf0216230,%ecx
f01005ab:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005b0:	89 ca                	mov    %ecx,%edx
f01005b2:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005b3:	0f b7 1d 28 62 21 f0 	movzwl 0xf0216228,%ebx
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
f01005db:	80 3d 34 62 21 f0 00 	cmpb   $0x0,0xf0216234
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
f0100619:	a1 20 62 21 f0       	mov    0xf0216220,%eax
f010061e:	3b 05 24 62 21 f0    	cmp    0xf0216224,%eax
f0100624:	74 26                	je     f010064c <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100626:	8d 50 01             	lea    0x1(%eax),%edx
f0100629:	89 15 20 62 21 f0    	mov    %edx,0xf0216220
f010062f:	0f b6 88 20 60 21 f0 	movzbl -0xfde9fe0(%eax),%ecx
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
f0100640:	c7 05 20 62 21 f0 00 	movl   $0x0,0xf0216220
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
f0100679:	c7 05 30 62 21 f0 b4 	movl   $0x3b4,0xf0216230
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
f0100691:	c7 05 30 62 21 f0 d4 	movl   $0x3d4,0xf0216230
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
f01006a0:	8b 3d 30 62 21 f0    	mov    0xf0216230,%edi
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
f01006c5:	89 35 2c 62 21 f0    	mov    %esi,0xf021622c
	crt_pos = pos;
f01006cb:	0f b6 c0             	movzbl %al,%eax
f01006ce:	09 c8                	or     %ecx,%eax
f01006d0:	66 a3 28 62 21 f0    	mov    %ax,0xf0216228

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
f01006eb:	e8 df 32 00 00       	call   f01039cf <irq_setmask_8259A>
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
f010074e:	0f 95 05 34 62 21 f0 	setne  0xf0216234
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
f0100770:	e8 5a 32 00 00       	call   f01039cf <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100775:	83 c4 10             	add    $0x10,%esp
f0100778:	80 3d 34 62 21 f0 00 	cmpb   $0x0,0xf0216234
f010077f:	75 10                	jne    f0100791 <cons_init+0x13e>
		cprintf("Serial port does not exist!\n");
f0100781:	83 ec 0c             	sub    $0xc,%esp
f0100784:	68 6f 69 10 f0       	push   $0xf010696f
f0100789:	e8 92 33 00 00       	call   f0103b20 <cprintf>
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
f01007ca:	68 c0 6b 10 f0       	push   $0xf0106bc0
f01007cf:	68 de 6b 10 f0       	push   $0xf0106bde
f01007d4:	68 e3 6b 10 f0       	push   $0xf0106be3
f01007d9:	e8 42 33 00 00       	call   f0103b20 <cprintf>
f01007de:	83 c4 0c             	add    $0xc,%esp
f01007e1:	68 9c 6c 10 f0       	push   $0xf0106c9c
f01007e6:	68 ec 6b 10 f0       	push   $0xf0106bec
f01007eb:	68 e3 6b 10 f0       	push   $0xf0106be3
f01007f0:	e8 2b 33 00 00       	call   f0103b20 <cprintf>
f01007f5:	83 c4 0c             	add    $0xc,%esp
f01007f8:	68 f5 6b 10 f0       	push   $0xf0106bf5
f01007fd:	68 fd 6b 10 f0       	push   $0xf0106bfd
f0100802:	68 e3 6b 10 f0       	push   $0xf0106be3
f0100807:	e8 14 33 00 00       	call   f0103b20 <cprintf>
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
f0100819:	68 07 6c 10 f0       	push   $0xf0106c07
f010081e:	e8 fd 32 00 00       	call   f0103b20 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100823:	83 c4 08             	add    $0x8,%esp
f0100826:	68 0c 00 10 00       	push   $0x10000c
f010082b:	68 c4 6c 10 f0       	push   $0xf0106cc4
f0100830:	e8 eb 32 00 00       	call   f0103b20 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100835:	83 c4 0c             	add    $0xc,%esp
f0100838:	68 0c 00 10 00       	push   $0x10000c
f010083d:	68 0c 00 10 f0       	push   $0xf010000c
f0100842:	68 ec 6c 10 f0       	push   $0xf0106cec
f0100847:	e8 d4 32 00 00       	call   f0103b20 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010084c:	83 c4 0c             	add    $0xc,%esp
f010084f:	68 81 68 10 00       	push   $0x106881
f0100854:	68 81 68 10 f0       	push   $0xf0106881
f0100859:	68 10 6d 10 f0       	push   $0xf0106d10
f010085e:	e8 bd 32 00 00       	call   f0103b20 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100863:	83 c4 0c             	add    $0xc,%esp
f0100866:	68 64 53 21 00       	push   $0x215364
f010086b:	68 64 53 21 f0       	push   $0xf0215364
f0100870:	68 34 6d 10 f0       	push   $0xf0106d34
f0100875:	e8 a6 32 00 00       	call   f0103b20 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010087a:	83 c4 0c             	add    $0xc,%esp
f010087d:	68 08 80 25 00       	push   $0x258008
f0100882:	68 08 80 25 f0       	push   $0xf0258008
f0100887:	68 58 6d 10 f0       	push   $0xf0106d58
f010088c:	e8 8f 32 00 00       	call   f0103b20 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100891:	b8 07 84 25 f0       	mov    $0xf0258407,%eax
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
f01008b2:	68 7c 6d 10 f0       	push   $0xf0106d7c
f01008b7:	e8 64 32 00 00       	call   f0103b20 <cprintf>
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
f01008ce:	68 20 6c 10 f0       	push   $0xf0106c20
f01008d3:	e8 48 32 00 00       	call   f0103b20 <cprintf>
	
	while (ebp != 0) {
f01008d8:	83 c4 10             	add    $0x10,%esp
f01008db:	eb 67                	jmp    f0100944 <mon_backtrace+0x81>
		eip = ebp + 1;	   //eip is stored after ebp
		cprintf("ebp %x eip %x args ", ebp, *eip);
f01008dd:	83 ec 04             	sub    $0x4,%esp
f01008e0:	ff 76 04             	pushl  0x4(%esi)
f01008e3:	56                   	push   %esi
f01008e4:	68 32 6c 10 f0       	push   $0xf0106c32
f01008e9:	e8 32 32 00 00       	call   f0103b20 <cprintf>
f01008ee:	8d 5e 08             	lea    0x8(%esi),%ebx
f01008f1:	8d 7e 1c             	lea    0x1c(%esi),%edi
f01008f4:	83 c4 10             	add    $0x10,%esp

		size_t arg_num;
		//print arguments stored after instruction pointer
		for (arg_num = 1; arg_num <= 5; arg_num++) {
			cprintf("%08x ", *(eip + arg_num));
f01008f7:	83 ec 08             	sub    $0x8,%esp
f01008fa:	ff 33                	pushl  (%ebx)
f01008fc:	68 46 6c 10 f0       	push   $0xf0106c46
f0100901:	e8 1a 32 00 00       	call   f0103b20 <cprintf>
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
f010091a:	e8 d8 48 00 00       	call   f01051f7 <debuginfo_eip>

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
f0100935:	68 4c 6c 10 f0       	push   $0xf0106c4c
f010093a:	e8 e1 31 00 00       	call   f0103b20 <cprintf>
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
f010095e:	68 a8 6d 10 f0       	push   $0xf0106da8
f0100963:	e8 b8 31 00 00       	call   f0103b20 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100968:	c7 04 24 cc 6d 10 f0 	movl   $0xf0106dcc,(%esp)
f010096f:	e8 ac 31 00 00       	call   f0103b20 <cprintf>

	if (tf != NULL)
f0100974:	83 c4 10             	add    $0x10,%esp
f0100977:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010097b:	74 0e                	je     f010098b <monitor+0x36>
		print_trapframe(tf);
f010097d:	83 ec 0c             	sub    $0xc,%esp
f0100980:	ff 75 08             	pushl  0x8(%ebp)
f0100983:	e8 0f 39 00 00       	call   f0104297 <print_trapframe>
f0100988:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f010098b:	83 ec 0c             	sub    $0xc,%esp
f010098e:	68 5e 6c 10 f0       	push   $0xf0106c5e
f0100993:	e8 d8 4f 00 00       	call   f0105970 <readline>
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
f01009c7:	68 62 6c 10 f0       	push   $0xf0106c62
f01009cc:	e8 d1 51 00 00       	call   f0105ba2 <strchr>
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
f01009e7:	68 67 6c 10 f0       	push   $0xf0106c67
f01009ec:	e8 2f 31 00 00       	call   f0103b20 <cprintf>
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
f0100a10:	68 62 6c 10 f0       	push   $0xf0106c62
f0100a15:	e8 88 51 00 00       	call   f0105ba2 <strchr>
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
f0100a3e:	ff 34 85 00 6e 10 f0 	pushl  -0xfef9200(,%eax,4)
f0100a45:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a48:	e8 f7 50 00 00       	call   f0105b44 <strcmp>
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
f0100a62:	ff 14 85 08 6e 10 f0 	call   *-0xfef91f8(,%eax,4)
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
f0100a83:	68 84 6c 10 f0       	push   $0xf0106c84
f0100a88:	e8 93 30 00 00       	call   f0103b20 <cprintf>
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
f0100aa8:	e8 f4 2e 00 00       	call   f01039a1 <mc146818_read>
f0100aad:	89 c6                	mov    %eax,%esi
f0100aaf:	83 c3 01             	add    $0x1,%ebx
f0100ab2:	89 1c 24             	mov    %ebx,(%esp)
f0100ab5:	e8 e7 2e 00 00       	call   f01039a1 <mc146818_read>
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
f0100adc:	3b 0d 88 6e 21 f0    	cmp    0xf0216e88,%ecx
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
f0100aeb:	68 c4 68 10 f0       	push   $0xf01068c4
f0100af0:	68 cd 03 00 00       	push   $0x3cd
f0100af5:	68 91 77 10 f0       	push   $0xf0107791
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
f0100b2a:	83 3d 38 62 21 f0 00 	cmpl   $0x0,0xf0216238
f0100b31:	75 11                	jne    f0100b44 <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100b33:	ba 07 90 25 f0       	mov    $0xf0259007,%edx
f0100b38:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b3e:	89 15 38 62 21 f0    	mov    %edx,0xf0216238
        // Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
        if (n == 0)
f0100b44:	85 c0                	test   %eax,%eax
f0100b46:	75 06                	jne    f0100b4e <boot_alloc+0x24>
                return nextfree;
f0100b48:	a1 38 62 21 f0       	mov    0xf0216238,%eax

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
f0100b57:	8b 15 38 62 21 f0    	mov    0xf0216238,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100b5d:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100b63:	77 12                	ja     f0100b77 <boot_alloc+0x4d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100b65:	52                   	push   %edx
f0100b66:	68 e8 68 10 f0       	push   $0xf01068e8
f0100b6b:	6a 70                	push   $0x70
f0100b6d:	68 91 77 10 f0       	push   $0xf0107791
f0100b72:	e8 c9 f4 ff ff       	call   f0100040 <_panic>
f0100b77:	b8 00 00 40 f0       	mov    $0xf0400000,%eax
f0100b7c:	29 d0                	sub    %edx,%eax
f0100b7e:	39 c3                	cmp    %eax,%ebx
f0100b80:	76 14                	jbe    f0100b96 <boot_alloc+0x6c>
               panic("boot_alloc: ran out of free memory"); 
f0100b82:	83 ec 04             	sub    $0x4,%esp
f0100b85:	68 24 6e 10 f0       	push   $0xf0106e24
f0100b8a:	6a 71                	push   $0x71
f0100b8c:	68 91 77 10 f0       	push   $0xf0107791
f0100b91:	e8 aa f4 ff ff       	call   f0100040 <_panic>
	cprintf("in boot alloc: free mem: %d\n",(4 * 1024 * 1024 - PADDR(nextfree)));
f0100b96:	83 ec 08             	sub    $0x8,%esp
f0100b99:	50                   	push   %eax
f0100b9a:	68 9d 77 10 f0       	push   $0xf010779d
f0100b9f:	e8 7c 2f 00 00       	call   f0103b20 <cprintf>

        result = nextfree;        
f0100ba4:	a1 38 62 21 f0       	mov    0xf0216238,%eax
        nextfree = ROUNDUP((char *) (nextfree + n), PGSIZE);
f0100ba9:	8d 94 18 ff 0f 00 00 	lea    0xfff(%eax,%ebx,1),%edx
f0100bb0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100bb6:	89 15 38 62 21 f0    	mov    %edx,0xf0216238

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
f0100bdd:	68 48 6e 10 f0       	push   $0xf0106e48
f0100be2:	68 00 03 00 00       	push   $0x300
f0100be7:	68 91 77 10 f0       	push   $0xf0107791
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
f0100bff:	2b 15 90 6e 21 f0    	sub    0xf0216e90,%edx
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
f0100c35:	a3 40 62 21 f0       	mov    %eax,0xf0216240
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
f0100c3f:	8b 1d 40 62 21 f0    	mov    0xf0216240,%ebx
f0100c45:	eb 53                	jmp    f0100c9a <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c47:	89 d8                	mov    %ebx,%eax
f0100c49:	2b 05 90 6e 21 f0    	sub    0xf0216e90,%eax
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
f0100c63:	3b 15 88 6e 21 f0    	cmp    0xf0216e88,%edx
f0100c69:	72 12                	jb     f0100c7d <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c6b:	50                   	push   %eax
f0100c6c:	68 c4 68 10 f0       	push   $0xf01068c4
f0100c71:	6a 58                	push   $0x58
f0100c73:	68 ba 77 10 f0       	push   $0xf01077ba
f0100c78:	e8 c3 f3 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c7d:	83 ec 04             	sub    $0x4,%esp
f0100c80:	68 80 00 00 00       	push   $0x80
f0100c85:	68 97 00 00 00       	push   $0x97
f0100c8a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c8f:	50                   	push   %eax
f0100c90:	e8 4a 4f 00 00       	call   f0105bdf <memset>
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
f0100cab:	8b 15 40 62 21 f0    	mov    0xf0216240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100cb1:	8b 0d 90 6e 21 f0    	mov    0xf0216e90,%ecx
		assert(pp < pages + npages);
f0100cb7:	a1 88 6e 21 f0       	mov    0xf0216e88,%eax
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
f0100cd6:	68 c8 77 10 f0       	push   $0xf01077c8
f0100cdb:	68 d4 77 10 f0       	push   $0xf01077d4
f0100ce0:	68 1a 03 00 00       	push   $0x31a
f0100ce5:	68 91 77 10 f0       	push   $0xf0107791
f0100cea:	e8 51 f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100cef:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100cf2:	72 19                	jb     f0100d0d <check_page_free_list+0x149>
f0100cf4:	68 e9 77 10 f0       	push   $0xf01077e9
f0100cf9:	68 d4 77 10 f0       	push   $0xf01077d4
f0100cfe:	68 1b 03 00 00       	push   $0x31b
f0100d03:	68 91 77 10 f0       	push   $0xf0107791
f0100d08:	e8 33 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d0d:	89 d0                	mov    %edx,%eax
f0100d0f:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100d12:	a8 07                	test   $0x7,%al
f0100d14:	74 19                	je     f0100d2f <check_page_free_list+0x16b>
f0100d16:	68 6c 6e 10 f0       	push   $0xf0106e6c
f0100d1b:	68 d4 77 10 f0       	push   $0xf01077d4
f0100d20:	68 1c 03 00 00       	push   $0x31c
f0100d25:	68 91 77 10 f0       	push   $0xf0107791
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
f0100d39:	68 fd 77 10 f0       	push   $0xf01077fd
f0100d3e:	68 d4 77 10 f0       	push   $0xf01077d4
f0100d43:	68 1f 03 00 00       	push   $0x31f
f0100d48:	68 91 77 10 f0       	push   $0xf0107791
f0100d4d:	e8 ee f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d52:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d57:	75 19                	jne    f0100d72 <check_page_free_list+0x1ae>
f0100d59:	68 0e 78 10 f0       	push   $0xf010780e
f0100d5e:	68 d4 77 10 f0       	push   $0xf01077d4
f0100d63:	68 20 03 00 00       	push   $0x320
f0100d68:	68 91 77 10 f0       	push   $0xf0107791
f0100d6d:	e8 ce f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d72:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d77:	75 19                	jne    f0100d92 <check_page_free_list+0x1ce>
f0100d79:	68 a0 6e 10 f0       	push   $0xf0106ea0
f0100d7e:	68 d4 77 10 f0       	push   $0xf01077d4
f0100d83:	68 21 03 00 00       	push   $0x321
f0100d88:	68 91 77 10 f0       	push   $0xf0107791
f0100d8d:	e8 ae f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d92:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d97:	75 19                	jne    f0100db2 <check_page_free_list+0x1ee>
f0100d99:	68 27 78 10 f0       	push   $0xf0107827
f0100d9e:	68 d4 77 10 f0       	push   $0xf01077d4
f0100da3:	68 22 03 00 00       	push   $0x322
f0100da8:	68 91 77 10 f0       	push   $0xf0107791
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
f0100dc8:	68 c4 68 10 f0       	push   $0xf01068c4
f0100dcd:	6a 58                	push   $0x58
f0100dcf:	68 ba 77 10 f0       	push   $0xf01077ba
f0100dd4:	e8 67 f2 ff ff       	call   f0100040 <_panic>
f0100dd9:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100ddf:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100de2:	0f 86 b6 00 00 00    	jbe    f0100e9e <check_page_free_list+0x2da>
f0100de8:	68 c4 6e 10 f0       	push   $0xf0106ec4
f0100ded:	68 d4 77 10 f0       	push   $0xf01077d4
f0100df2:	68 23 03 00 00       	push   $0x323
f0100df7:	68 91 77 10 f0       	push   $0xf0107791
f0100dfc:	e8 3f f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e01:	68 41 78 10 f0       	push   $0xf0107841
f0100e06:	68 d4 77 10 f0       	push   $0xf01077d4
f0100e0b:	68 25 03 00 00       	push   $0x325
f0100e10:	68 91 77 10 f0       	push   $0xf0107791
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
f0100e30:	68 5e 78 10 f0       	push   $0xf010785e
f0100e35:	68 d4 77 10 f0       	push   $0xf01077d4
f0100e3a:	68 2d 03 00 00       	push   $0x32d
f0100e3f:	68 91 77 10 f0       	push   $0xf0107791
f0100e44:	e8 f7 f1 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e49:	85 db                	test   %ebx,%ebx
f0100e4b:	7f 19                	jg     f0100e66 <check_page_free_list+0x2a2>
f0100e4d:	68 70 78 10 f0       	push   $0xf0107870
f0100e52:	68 d4 77 10 f0       	push   $0xf01077d4
f0100e57:	68 2e 03 00 00       	push   $0x32e
f0100e5c:	68 91 77 10 f0       	push   $0xf0107791
f0100e61:	e8 da f1 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100e66:	83 ec 0c             	sub    $0xc,%esp
f0100e69:	68 0c 6f 10 f0       	push   $0xf0106f0c
f0100e6e:	e8 ad 2c 00 00       	call   f0103b20 <cprintf>
}
f0100e73:	eb 49                	jmp    f0100ebe <check_page_free_list+0x2fa>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e75:	a1 40 62 21 f0       	mov    0xf0216240,%eax
f0100e7a:	85 c0                	test   %eax,%eax
f0100e7c:	0f 85 6f fd ff ff    	jne    f0100bf1 <check_page_free_list+0x2d>
f0100e82:	e9 53 fd ff ff       	jmp    f0100bda <check_page_free_list+0x16>
f0100e87:	83 3d 40 62 21 f0 00 	cmpl   $0x0,0xf0216240
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
f0100ec6:	a1 90 6e 21 f0       	mov    0xf0216e90,%eax
f0100ecb:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0100ed0:	8b 15 40 62 21 f0    	mov    0xf0216240,%edx
f0100ed6:	b8 08 00 00 00       	mov    $0x8,%eax
        // 2) All base pages except 0 are free
        size_t i;
        size_t mpentry_page = MPENTRY_PADDR / PGSIZE; 

        for (i = 1; i < mpentry_page; i++) {
                pages[i].pp_link = page_free_list;
f0100edb:	8b 0d 90 6e 21 f0    	mov    0xf0216e90,%ecx
f0100ee1:	89 14 01             	mov    %edx,(%ecx,%eax,1)
                page_free_list = &pages[i];
f0100ee4:	8b 0d 90 6e 21 f0    	mov    0xf0216e90,%ecx
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
f0100efa:	89 15 40 62 21 f0    	mov    %edx,0xf0216240
        for (i = 1; i < mpentry_page; i++) {
                pages[i].pp_link = page_free_list;
                page_free_list = &pages[i];
        }

        pages[mpentry_page].pp_ref++;
f0100f00:	66 83 41 3c 01       	addw   $0x1,0x3c(%ecx)

        for (i = mpentry_page + 1; i < npages_basemem; i++) {
f0100f05:	8b 1d 44 62 21 f0    	mov    0xf0216244,%ebx
f0100f0b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100f10:	b8 08 00 00 00       	mov    $0x8,%eax
f0100f15:	eb 20                	jmp    f0100f37 <page_init+0x71>
f0100f17:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
                pages[i].pp_link = page_free_list;
f0100f1e:	8b 35 90 6e 21 f0    	mov    0xf0216e90,%esi
f0100f24:	89 14 c6             	mov    %edx,(%esi,%eax,8)
                page_free_list = &pages[i];
        }

        pages[mpentry_page].pp_ref++;

        for (i = mpentry_page + 1; i < npages_basemem; i++) {
f0100f27:	83 c0 01             	add    $0x1,%eax
                pages[i].pp_link = page_free_list;
                page_free_list = &pages[i];
f0100f2a:	89 ca                	mov    %ecx,%edx
f0100f2c:	03 15 90 6e 21 f0    	add    0xf0216e90,%edx
f0100f32:	b9 01 00 00 00       	mov    $0x1,%ecx
                page_free_list = &pages[i];
        }

        pages[mpentry_page].pp_ref++;

        for (i = mpentry_page + 1; i < npages_basemem; i++) {
f0100f37:	39 d8                	cmp    %ebx,%eax
f0100f39:	72 dc                	jb     f0100f17 <page_init+0x51>
f0100f3b:	84 c9                	test   %cl,%cl
f0100f3d:	74 06                	je     f0100f45 <page_init+0x7f>
f0100f3f:	89 15 40 62 21 f0    	mov    %edx,0xf0216240
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
f0100f57:	68 e8 68 10 f0       	push   $0xf01068e8
f0100f5c:	68 60 01 00 00       	push   $0x160
f0100f61:	68 91 77 10 f0       	push   $0xf0107791
f0100f66:	e8 d5 f0 ff ff       	call   f0100040 <_panic>
f0100f6b:	05 00 00 00 10       	add    $0x10000000,%eax
f0100f70:	c1 e8 0c             	shr    $0xc,%eax
f0100f73:	8b 0d 40 62 21 f0    	mov    0xf0216240,%ecx
f0100f79:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100f80:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100f85:	eb 1c                	jmp    f0100fa3 <page_init+0xdd>
                pages[i].pp_link = page_free_list;
f0100f87:	8b 35 90 6e 21 f0    	mov    0xf0216e90,%esi
f0100f8d:	89 0c 16             	mov    %ecx,(%esi,%edx,1)
                page_free_list = &pages[i];
f0100f90:	89 d1                	mov    %edx,%ecx
f0100f92:	03 0d 90 6e 21 f0    	add    0xf0216e90,%ecx
                page_free_list = &pages[i];
        }

        // 4) We find the next free memory (boot_alloc() outputs a rounded-up virtual address),
        // convert it to a physical address and get the index of free pages by dividing by PGSIZE  
        for (i = PADDR(boot_alloc(0)) / PGSIZE; i < npages; i++) {
f0100f98:	83 c0 01             	add    $0x1,%eax
f0100f9b:	83 c2 08             	add    $0x8,%edx
f0100f9e:	bb 01 00 00 00       	mov    $0x1,%ebx
f0100fa3:	3b 05 88 6e 21 f0    	cmp    0xf0216e88,%eax
f0100fa9:	72 dc                	jb     f0100f87 <page_init+0xc1>
f0100fab:	84 db                	test   %bl,%bl
f0100fad:	74 06                	je     f0100fb5 <page_init+0xef>
f0100faf:	89 0d 40 62 21 f0    	mov    %ecx,0xf0216240
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
f0100fc3:	8b 1d 40 62 21 f0    	mov    0xf0216240,%ebx
f0100fc9:	85 db                	test   %ebx,%ebx
f0100fcb:	74 58                	je     f0101025 <page_alloc+0x69>
                return NULL;

        struct PageInfo *page = page_free_list;
        page_free_list = page->pp_link;
f0100fcd:	8b 03                	mov    (%ebx),%eax
f0100fcf:	a3 40 62 21 f0       	mov    %eax,0xf0216240

	if (alloc_flags & ALLOC_ZERO) {
f0100fd4:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100fd8:	74 45                	je     f010101f <page_alloc+0x63>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100fda:	89 d8                	mov    %ebx,%eax
f0100fdc:	2b 05 90 6e 21 f0    	sub    0xf0216e90,%eax
f0100fe2:	c1 f8 03             	sar    $0x3,%eax
f0100fe5:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fe8:	89 c2                	mov    %eax,%edx
f0100fea:	c1 ea 0c             	shr    $0xc,%edx
f0100fed:	3b 15 88 6e 21 f0    	cmp    0xf0216e88,%edx
f0100ff3:	72 12                	jb     f0101007 <page_alloc+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ff5:	50                   	push   %eax
f0100ff6:	68 c4 68 10 f0       	push   $0xf01068c4
f0100ffb:	6a 58                	push   $0x58
f0100ffd:	68 ba 77 10 f0       	push   $0xf01077ba
f0101002:	e8 39 f0 ff ff       	call   f0100040 <_panic>
                char *p = page2kva(page);
                memset(p, 0, PGSIZE);
f0101007:	83 ec 04             	sub    $0x4,%esp
f010100a:	68 00 10 00 00       	push   $0x1000
f010100f:	6a 00                	push   $0x0
f0101011:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101016:	50                   	push   %eax
f0101017:	e8 c3 4b 00 00       	call   f0105bdf <memset>
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
f0101039:	68 bb 79 10 f0       	push   $0xf01079bb
f010103e:	68 d4 77 10 f0       	push   $0xf01077d4
f0101043:	68 8b 01 00 00       	push   $0x18b
f0101048:	68 91 77 10 f0       	push   $0xf0107791
f010104d:	e8 ee ef ff ff       	call   f0100040 <_panic>

        // Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
        if (pp->pp_ref != 0) 
f0101052:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101057:	74 17                	je     f0101070 <page_free+0x44>
                panic("pp->pp_ref is nonzero\n");
f0101059:	83 ec 04             	sub    $0x4,%esp
f010105c:	68 81 78 10 f0       	push   $0xf0107881
f0101061:	68 91 01 00 00       	push   $0x191
f0101066:	68 91 77 10 f0       	push   $0xf0107791
f010106b:	e8 d0 ef ff ff       	call   f0100040 <_panic>

        if (pp->pp_link != NULL)
f0101070:	83 38 00             	cmpl   $0x0,(%eax)
f0101073:	74 17                	je     f010108c <page_free+0x60>
                panic("pp->pp_link is not NULL\n");
f0101075:	83 ec 04             	sub    $0x4,%esp
f0101078:	68 98 78 10 f0       	push   $0xf0107898
f010107d:	68 94 01 00 00       	push   $0x194
f0101082:	68 91 77 10 f0       	push   $0xf0107791
f0101087:	e8 b4 ef ff ff       	call   f0100040 <_panic>

        pp->pp_link = page_free_list;
f010108c:	8b 15 40 62 21 f0    	mov    0xf0216240,%edx
f0101092:	89 10                	mov    %edx,(%eax)
        page_free_list = pp;
f0101094:	a3 40 62 21 f0       	mov    %eax,0xf0216240
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
f01010d1:	68 b1 78 10 f0       	push   $0xf01078b1
f01010d6:	68 d4 77 10 f0       	push   $0xf01077d4
f01010db:	68 be 01 00 00       	push   $0x1be
f01010e0:	68 91 77 10 f0       	push   $0xf0107791
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
f0101104:	39 05 88 6e 21 f0    	cmp    %eax,0xf0216e88
f010110a:	77 15                	ja     f0101121 <pgdir_walk+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010110c:	52                   	push   %edx
f010110d:	68 c4 68 10 f0       	push   $0xf01068c4
f0101112:	68 c5 01 00 00       	push   $0x1c5
f0101117:	68 91 77 10 f0       	push   $0xf0107791
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
f0101142:	2b 15 90 6e 21 f0    	sub    0xf0216e90,%edx
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
f0101158:	2b 05 90 6e 21 f0    	sub    0xf0216e90,%eax
f010115e:	c1 f8 03             	sar    $0x3,%eax
f0101161:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101164:	89 c2                	mov    %eax,%edx
f0101166:	c1 ea 0c             	shr    $0xc,%edx
f0101169:	3b 15 88 6e 21 f0    	cmp    0xf0216e88,%edx
f010116f:	72 12                	jb     f0101183 <pgdir_walk+0xc1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101171:	50                   	push   %eax
f0101172:	68 c4 68 10 f0       	push   $0xf01068c4
f0101177:	6a 58                	push   $0x58
f0101179:	68 ba 77 10 f0       	push   $0xf01077ba
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
f01011d9:	68 b1 78 10 f0       	push   $0xf01078b1
f01011de:	68 d4 77 10 f0       	push   $0xf01077d4
f01011e3:	68 e5 01 00 00       	push   $0x1e5
f01011e8:	68 91 77 10 f0       	push   $0xf0107791
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
f010120a:	68 b7 78 10 f0       	push   $0xf01078b7
f010120f:	68 d4 77 10 f0       	push   $0xf01077d4
f0101214:	68 ed 01 00 00       	push   $0x1ed
f0101219:	68 91 77 10 f0       	push   $0xf0107791
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
f0101251:	68 b1 78 10 f0       	push   $0xf01078b1
f0101256:	68 d4 77 10 f0       	push   $0xf01077d4
f010125b:	68 3a 02 00 00       	push   $0x23a
f0101260:	68 91 77 10 f0       	push   $0xf0107791
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
f010128f:	3b 05 88 6e 21 f0    	cmp    0xf0216e88,%eax
f0101295:	72 14                	jb     f01012ab <page_lookup+0x6b>
		panic("pa2page called with invalid pa");
f0101297:	83 ec 04             	sub    $0x4,%esp
f010129a:	68 30 6f 10 f0       	push   $0xf0106f30
f010129f:	6a 51                	push   $0x51
f01012a1:	68 ba 77 10 f0       	push   $0xf01077ba
f01012a6:	e8 95 ed ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01012ab:	8b 15 90 6e 21 f0    	mov    0xf0216e90,%edx
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
f01012cd:	e8 30 4f 00 00       	call   f0106202 <cpunum>
f01012d2:	6b c0 74             	imul   $0x74,%eax,%eax
f01012d5:	83 b8 28 70 21 f0 00 	cmpl   $0x0,-0xfde8fd8(%eax)
f01012dc:	74 16                	je     f01012f4 <tlb_invalidate+0x2d>
f01012de:	e8 1f 4f 00 00       	call   f0106202 <cpunum>
f01012e3:	6b c0 74             	imul   $0x74,%eax,%eax
f01012e6:	8b 80 28 70 21 f0    	mov    -0xfde8fd8(%eax),%eax
f01012ec:	8b 55 08             	mov    0x8(%ebp),%edx
f01012ef:	39 50 6c             	cmp    %edx,0x6c(%eax)
f01012f2:	75 06                	jne    f01012fa <tlb_invalidate+0x33>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01012f4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01012f7:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f01012fa:	c9                   	leave  
f01012fb:	c3                   	ret    

f01012fc <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01012fc:	55                   	push   %ebp
f01012fd:	89 e5                	mov    %esp,%ebp
f01012ff:	56                   	push   %esi
f0101300:	53                   	push   %ebx
f0101301:	83 ec 10             	sub    $0x10,%esp
f0101304:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101307:	8b 75 0c             	mov    0xc(%ebp),%esi
        assert(pgdir);
f010130a:	85 db                	test   %ebx,%ebx
f010130c:	75 19                	jne    f0101327 <page_remove+0x2b>
f010130e:	68 b1 78 10 f0       	push   $0xf01078b1
f0101313:	68 d4 77 10 f0       	push   $0xf01077d4
f0101318:	68 59 02 00 00       	push   $0x259
f010131d:	68 91 77 10 f0       	push   $0xf0107791
f0101322:	e8 19 ed ff ff       	call   f0100040 <_panic>

        pte_t *pte;
        struct PageInfo *page = page_lookup(pgdir, va, &pte);
f0101327:	83 ec 04             	sub    $0x4,%esp
f010132a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010132d:	50                   	push   %eax
f010132e:	56                   	push   %esi
f010132f:	53                   	push   %ebx
f0101330:	e8 0b ff ff ff       	call   f0101240 <page_lookup>
        // Silently do nothing
        if (page == NULL || (*pte & PTE_P) != PTE_P)
f0101335:	83 c4 10             	add    $0x10,%esp
f0101338:	85 c0                	test   %eax,%eax
f010133a:	74 27                	je     f0101363 <page_remove+0x67>
f010133c:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010133f:	f6 02 01             	testb  $0x1,(%edx)
f0101342:	74 1f                	je     f0101363 <page_remove+0x67>
                return;

        page_decref(page);
f0101344:	83 ec 0c             	sub    $0xc,%esp
f0101347:	50                   	push   %eax
f0101348:	e8 4e fd ff ff       	call   f010109b <page_decref>

        // Zero the table entry
        *pte = 0;
f010134d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101350:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

        tlb_invalidate(pgdir, va);
f0101356:	83 c4 08             	add    $0x8,%esp
f0101359:	56                   	push   %esi
f010135a:	53                   	push   %ebx
f010135b:	e8 67 ff ff ff       	call   f01012c7 <tlb_invalidate>
f0101360:	83 c4 10             	add    $0x10,%esp
}
f0101363:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101366:	5b                   	pop    %ebx
f0101367:	5e                   	pop    %esi
f0101368:	5d                   	pop    %ebp
f0101369:	c3                   	ret    

f010136a <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010136a:	55                   	push   %ebp
f010136b:	89 e5                	mov    %esp,%ebp
f010136d:	57                   	push   %edi
f010136e:	56                   	push   %esi
f010136f:	53                   	push   %ebx
f0101370:	83 ec 0c             	sub    $0xc,%esp
f0101373:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101376:	8b 5d 0c             	mov    0xc(%ebp),%ebx
        assert(pgdir);
f0101379:	85 ff                	test   %edi,%edi
f010137b:	75 19                	jne    f0101396 <page_insert+0x2c>
f010137d:	68 b1 78 10 f0       	push   $0xf01078b1
f0101382:	68 d4 77 10 f0       	push   $0xf01077d4
f0101387:	68 12 02 00 00       	push   $0x212
f010138c:	68 91 77 10 f0       	push   $0xf0107791
f0101391:	e8 aa ec ff ff       	call   f0100040 <_panic>
        assert(pp);
f0101396:	85 db                	test   %ebx,%ebx
f0101398:	75 19                	jne    f01013b3 <page_insert+0x49>
f010139a:	68 bb 79 10 f0       	push   $0xf01079bb
f010139f:	68 d4 77 10 f0       	push   $0xf01077d4
f01013a4:	68 13 02 00 00       	push   $0x213
f01013a9:	68 91 77 10 f0       	push   $0xf0107791
f01013ae:	e8 8d ec ff ff       	call   f0100040 <_panic>

        // Return -E_NO_MEM when it fails
        pte_t *pte = pgdir_walk(pgdir, va, 1);
f01013b3:	83 ec 04             	sub    $0x4,%esp
f01013b6:	6a 01                	push   $0x1
f01013b8:	ff 75 10             	pushl  0x10(%ebp)
f01013bb:	57                   	push   %edi
f01013bc:	e8 01 fd ff ff       	call   f01010c2 <pgdir_walk>
f01013c1:	89 c6                	mov    %eax,%esi
        if (pte == NULL)
f01013c3:	83 c4 10             	add    $0x10,%esp
f01013c6:	85 c0                	test   %eax,%eax
f01013c8:	74 5a                	je     f0101424 <page_insert+0xba>
                return -E_NO_MEM;

        if ((*pte & PTE_P) == PTE_P) {
f01013ca:	8b 00                	mov    (%eax),%eax
f01013cc:	a8 01                	test   $0x1,%al
f01013ce:	74 32                	je     f0101402 <page_insert+0x98>
                // We don't increment ref because it's the same page
                // but we just change its permissions (this is in tests)
                if (PTE_ADDR(*pte) == page2pa(pp))
f01013d0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01013d5:	89 da                	mov    %ebx,%edx
f01013d7:	2b 15 90 6e 21 f0    	sub    0xf0216e90,%edx
f01013dd:	c1 fa 03             	sar    $0x3,%edx
f01013e0:	c1 e2 0c             	shl    $0xc,%edx
f01013e3:	39 d0                	cmp    %edx,%eax
f01013e5:	74 20                	je     f0101407 <page_insert+0x9d>
                        goto page_insert_success;

                page_remove(pgdir, va);
f01013e7:	83 ec 08             	sub    $0x8,%esp
f01013ea:	ff 75 10             	pushl  0x10(%ebp)
f01013ed:	57                   	push   %edi
f01013ee:	e8 09 ff ff ff       	call   f01012fc <page_remove>
                // If the page was formerly at va, we invalidate the TLB
                tlb_invalidate(pgdir, va);
f01013f3:	83 c4 08             	add    $0x8,%esp
f01013f6:	ff 75 10             	pushl  0x10(%ebp)
f01013f9:	57                   	push   %edi
f01013fa:	e8 c8 fe ff ff       	call   f01012c7 <tlb_invalidate>
f01013ff:	83 c4 10             	add    $0x10,%esp
        }

        pp->pp_ref++;
f0101402:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)

page_insert_success:
        *pte = page2pa(pp) | perm | PTE_P;
f0101407:	2b 1d 90 6e 21 f0    	sub    0xf0216e90,%ebx
f010140d:	c1 fb 03             	sar    $0x3,%ebx
f0101410:	c1 e3 0c             	shl    $0xc,%ebx
f0101413:	8b 45 14             	mov    0x14(%ebp),%eax
f0101416:	83 c8 01             	or     $0x1,%eax
f0101419:	09 c3                	or     %eax,%ebx
f010141b:	89 1e                	mov    %ebx,(%esi)
        return 0; 
f010141d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101422:	eb 05                	jmp    f0101429 <page_insert+0xbf>
        assert(pp);

        // Return -E_NO_MEM when it fails
        pte_t *pte = pgdir_walk(pgdir, va, 1);
        if (pte == NULL)
                return -E_NO_MEM;
f0101424:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
        pp->pp_ref++;

page_insert_success:
        *pte = page2pa(pp) | perm | PTE_P;
        return 0; 
}
f0101429:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010142c:	5b                   	pop    %ebx
f010142d:	5e                   	pop    %esi
f010142e:	5f                   	pop    %edi
f010142f:	5d                   	pop    %ebp
f0101430:	c3                   	ret    

f0101431 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101431:	55                   	push   %ebp
f0101432:	89 e5                	mov    %esp,%ebp
f0101434:	56                   	push   %esi
f0101435:	53                   	push   %ebx
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
        size_t sz = ROUNDUP(size, PGSIZE); 
f0101436:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101439:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f010143f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        uintptr_t result = base;
f0101445:	8b 35 00 13 12 f0    	mov    0xf0121300,%esi

        if (base + sz > MMIOLIM)
f010144b:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f010144e:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f0101453:	76 17                	jbe    f010146c <mmio_map_region+0x3b>
                panic("mmio_map_region: base + sz > MMIOLIM");
f0101455:	83 ec 04             	sub    $0x4,%esp
f0101458:	68 50 6f 10 f0       	push   $0xf0106f50
f010145d:	68 99 02 00 00       	push   $0x299
f0101462:	68 91 77 10 f0       	push   $0xf0107791
f0101467:	e8 d4 eb ff ff       	call   f0100040 <_panic>

        boot_map_region(kern_pgdir, base, sz, pa, PTE_W | PTE_PCD | PTE_PWT);      
f010146c:	83 ec 08             	sub    $0x8,%esp
f010146f:	6a 1a                	push   $0x1a
f0101471:	ff 75 08             	pushl  0x8(%ebp)
f0101474:	89 d9                	mov    %ebx,%ecx
f0101476:	89 f2                	mov    %esi,%edx
f0101478:	a1 8c 6e 21 f0       	mov    0xf0216e8c,%eax
f010147d:	e8 28 fd ff ff       	call   f01011aa <boot_map_region>
        base += sz;
f0101482:	01 1d 00 13 12 f0    	add    %ebx,0xf0121300
        
        return (void *) result;
}
f0101488:	89 f0                	mov    %esi,%eax
f010148a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010148d:	5b                   	pop    %ebx
f010148e:	5e                   	pop    %esi
f010148f:	5d                   	pop    %ebp
f0101490:	c3                   	ret    

f0101491 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101491:	55                   	push   %ebp
f0101492:	89 e5                	mov    %esp,%ebp
f0101494:	57                   	push   %edi
f0101495:	56                   	push   %esi
f0101496:	53                   	push   %ebx
f0101497:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f010149a:	b8 15 00 00 00       	mov    $0x15,%eax
f010149f:	e8 f9 f5 ff ff       	call   f0100a9d <nvram_read>
f01014a4:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f01014a6:	b8 17 00 00 00       	mov    $0x17,%eax
f01014ab:	e8 ed f5 ff ff       	call   f0100a9d <nvram_read>
f01014b0:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01014b2:	b8 34 00 00 00       	mov    $0x34,%eax
f01014b7:	e8 e1 f5 ff ff       	call   f0100a9d <nvram_read>
f01014bc:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f01014bf:	85 c0                	test   %eax,%eax
f01014c1:	74 07                	je     f01014ca <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f01014c3:	05 00 40 00 00       	add    $0x4000,%eax
f01014c8:	eb 0b                	jmp    f01014d5 <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f01014ca:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01014d0:	85 f6                	test   %esi,%esi
f01014d2:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f01014d5:	89 c2                	mov    %eax,%edx
f01014d7:	c1 ea 02             	shr    $0x2,%edx
f01014da:	89 15 88 6e 21 f0    	mov    %edx,0xf0216e88
	npages_basemem = basemem / (PGSIZE / 1024);
f01014e0:	89 da                	mov    %ebx,%edx
f01014e2:	c1 ea 02             	shr    $0x2,%edx
f01014e5:	89 15 44 62 21 f0    	mov    %edx,0xf0216244

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01014eb:	89 c2                	mov    %eax,%edx
f01014ed:	29 da                	sub    %ebx,%edx
f01014ef:	52                   	push   %edx
f01014f0:	53                   	push   %ebx
f01014f1:	50                   	push   %eax
f01014f2:	68 78 6f 10 f0       	push   $0xf0106f78
f01014f7:	e8 24 26 00 00       	call   f0103b20 <cprintf>
	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01014fc:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101501:	e8 24 f6 ff ff       	call   f0100b2a <boot_alloc>
f0101506:	a3 8c 6e 21 f0       	mov    %eax,0xf0216e8c
	memset(kern_pgdir, 0, PGSIZE);
f010150b:	83 c4 0c             	add    $0xc,%esp
f010150e:	68 00 10 00 00       	push   $0x1000
f0101513:	6a 00                	push   $0x0
f0101515:	50                   	push   %eax
f0101516:	e8 c4 46 00 00       	call   f0105bdf <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010151b:	a1 8c 6e 21 f0       	mov    0xf0216e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101520:	83 c4 10             	add    $0x10,%esp
f0101523:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101528:	77 15                	ja     f010153f <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010152a:	50                   	push   %eax
f010152b:	68 e8 68 10 f0       	push   $0xf01068e8
f0101530:	68 98 00 00 00       	push   $0x98
f0101535:	68 91 77 10 f0       	push   $0xf0107791
f010153a:	e8 01 eb ff ff       	call   f0100040 <_panic>
f010153f:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101545:	83 ca 05             	or     $0x5,%edx
f0101548:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
        const size_t pages_size = sizeof(struct PageInfo) * npages;
f010154e:	a1 88 6e 21 f0       	mov    0xf0216e88,%eax
f0101553:	c1 e0 03             	shl    $0x3,%eax
f0101556:	89 c7                	mov    %eax,%edi
f0101558:	89 45 cc             	mov    %eax,-0x34(%ebp)
        pages = (struct PageInfo *) boot_alloc(pages_size);
f010155b:	e8 ca f5 ff ff       	call   f0100b2a <boot_alloc>
f0101560:	a3 90 6e 21 f0       	mov    %eax,0xf0216e90
        memset(pages, 0, pages_size);
f0101565:	83 ec 04             	sub    $0x4,%esp
f0101568:	57                   	push   %edi
f0101569:	6a 00                	push   $0x0
f010156b:	50                   	push   %eax
f010156c:	e8 6e 46 00 00       	call   f0105bdf <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
        const size_t envs_size = sizeof(struct Env) * NENV;
        envs = (struct Env *) boot_alloc(envs_size);
f0101571:	b8 00 20 02 00       	mov    $0x22000,%eax
f0101576:	e8 af f5 ff ff       	call   f0100b2a <boot_alloc>
f010157b:	a3 4c 62 21 f0       	mov    %eax,0xf021624c
        memset(envs, 0, envs_size);
f0101580:	83 c4 0c             	add    $0xc,%esp
f0101583:	68 00 20 02 00       	push   $0x22000
f0101588:	6a 00                	push   $0x0
f010158a:	50                   	push   %eax
f010158b:	e8 4f 46 00 00       	call   f0105bdf <memset>
	
	//Lab 7: Multithreading
	/*Alloc place for the free stack stacks stacking*/

	const size_t stack_size = sizeof(struct FreeStacks) * MAX_THREADS;
	thread_free_stacks = (struct FreeStacks*) boot_alloc(stack_size);
f0101590:	b8 f4 2f 00 00       	mov    $0x2ff4,%eax
f0101595:	e8 90 f5 ff ff       	call   f0100b2a <boot_alloc>
f010159a:	a3 48 62 21 f0       	mov    %eax,0xf0216248
	memset(thread_free_stacks, 0, stack_size);
f010159f:	83 c4 0c             	add    $0xc,%esp
f01015a2:	68 f4 2f 00 00       	push   $0x2ff4
f01015a7:	6a 00                	push   $0x0
f01015a9:	50                   	push   %eax
f01015aa:	e8 30 46 00 00       	call   f0105bdf <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01015af:	e8 12 f9 ff ff       	call   f0100ec6 <page_init>

	check_page_free_list(1);
f01015b4:	b8 01 00 00 00       	mov    $0x1,%eax
f01015b9:	e8 06 f6 ff ff       	call   f0100bc4 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01015be:	83 c4 10             	add    $0x10,%esp
f01015c1:	83 3d 90 6e 21 f0 00 	cmpl   $0x0,0xf0216e90
f01015c8:	75 17                	jne    f01015e1 <mem_init+0x150>
		panic("'pages' is a null pointer!");
f01015ca:	83 ec 04             	sub    $0x4,%esp
f01015cd:	68 bb 78 10 f0       	push   $0xf01078bb
f01015d2:	68 41 03 00 00       	push   $0x341
f01015d7:	68 91 77 10 f0       	push   $0xf0107791
f01015dc:	e8 5f ea ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01015e1:	a1 40 62 21 f0       	mov    0xf0216240,%eax
f01015e6:	bb 00 00 00 00       	mov    $0x0,%ebx
f01015eb:	eb 05                	jmp    f01015f2 <mem_init+0x161>
		++nfree;
f01015ed:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01015f0:	8b 00                	mov    (%eax),%eax
f01015f2:	85 c0                	test   %eax,%eax
f01015f4:	75 f7                	jne    f01015ed <mem_init+0x15c>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01015f6:	83 ec 0c             	sub    $0xc,%esp
f01015f9:	6a 00                	push   $0x0
f01015fb:	e8 bc f9 ff ff       	call   f0100fbc <page_alloc>
f0101600:	89 c7                	mov    %eax,%edi
f0101602:	83 c4 10             	add    $0x10,%esp
f0101605:	85 c0                	test   %eax,%eax
f0101607:	75 19                	jne    f0101622 <mem_init+0x191>
f0101609:	68 d6 78 10 f0       	push   $0xf01078d6
f010160e:	68 d4 77 10 f0       	push   $0xf01077d4
f0101613:	68 49 03 00 00       	push   $0x349
f0101618:	68 91 77 10 f0       	push   $0xf0107791
f010161d:	e8 1e ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101622:	83 ec 0c             	sub    $0xc,%esp
f0101625:	6a 00                	push   $0x0
f0101627:	e8 90 f9 ff ff       	call   f0100fbc <page_alloc>
f010162c:	89 c6                	mov    %eax,%esi
f010162e:	83 c4 10             	add    $0x10,%esp
f0101631:	85 c0                	test   %eax,%eax
f0101633:	75 19                	jne    f010164e <mem_init+0x1bd>
f0101635:	68 ec 78 10 f0       	push   $0xf01078ec
f010163a:	68 d4 77 10 f0       	push   $0xf01077d4
f010163f:	68 4a 03 00 00       	push   $0x34a
f0101644:	68 91 77 10 f0       	push   $0xf0107791
f0101649:	e8 f2 e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010164e:	83 ec 0c             	sub    $0xc,%esp
f0101651:	6a 00                	push   $0x0
f0101653:	e8 64 f9 ff ff       	call   f0100fbc <page_alloc>
f0101658:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010165b:	83 c4 10             	add    $0x10,%esp
f010165e:	85 c0                	test   %eax,%eax
f0101660:	75 19                	jne    f010167b <mem_init+0x1ea>
f0101662:	68 02 79 10 f0       	push   $0xf0107902
f0101667:	68 d4 77 10 f0       	push   $0xf01077d4
f010166c:	68 4b 03 00 00       	push   $0x34b
f0101671:	68 91 77 10 f0       	push   $0xf0107791
f0101676:	e8 c5 e9 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010167b:	39 f7                	cmp    %esi,%edi
f010167d:	75 19                	jne    f0101698 <mem_init+0x207>
f010167f:	68 18 79 10 f0       	push   $0xf0107918
f0101684:	68 d4 77 10 f0       	push   $0xf01077d4
f0101689:	68 4e 03 00 00       	push   $0x34e
f010168e:	68 91 77 10 f0       	push   $0xf0107791
f0101693:	e8 a8 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101698:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010169b:	39 c6                	cmp    %eax,%esi
f010169d:	74 04                	je     f01016a3 <mem_init+0x212>
f010169f:	39 c7                	cmp    %eax,%edi
f01016a1:	75 19                	jne    f01016bc <mem_init+0x22b>
f01016a3:	68 b4 6f 10 f0       	push   $0xf0106fb4
f01016a8:	68 d4 77 10 f0       	push   $0xf01077d4
f01016ad:	68 4f 03 00 00       	push   $0x34f
f01016b2:	68 91 77 10 f0       	push   $0xf0107791
f01016b7:	e8 84 e9 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01016bc:	8b 0d 90 6e 21 f0    	mov    0xf0216e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01016c2:	8b 15 88 6e 21 f0    	mov    0xf0216e88,%edx
f01016c8:	c1 e2 0c             	shl    $0xc,%edx
f01016cb:	89 f8                	mov    %edi,%eax
f01016cd:	29 c8                	sub    %ecx,%eax
f01016cf:	c1 f8 03             	sar    $0x3,%eax
f01016d2:	c1 e0 0c             	shl    $0xc,%eax
f01016d5:	39 d0                	cmp    %edx,%eax
f01016d7:	72 19                	jb     f01016f2 <mem_init+0x261>
f01016d9:	68 2a 79 10 f0       	push   $0xf010792a
f01016de:	68 d4 77 10 f0       	push   $0xf01077d4
f01016e3:	68 50 03 00 00       	push   $0x350
f01016e8:	68 91 77 10 f0       	push   $0xf0107791
f01016ed:	e8 4e e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01016f2:	89 f0                	mov    %esi,%eax
f01016f4:	29 c8                	sub    %ecx,%eax
f01016f6:	c1 f8 03             	sar    $0x3,%eax
f01016f9:	c1 e0 0c             	shl    $0xc,%eax
f01016fc:	39 c2                	cmp    %eax,%edx
f01016fe:	77 19                	ja     f0101719 <mem_init+0x288>
f0101700:	68 47 79 10 f0       	push   $0xf0107947
f0101705:	68 d4 77 10 f0       	push   $0xf01077d4
f010170a:	68 51 03 00 00       	push   $0x351
f010170f:	68 91 77 10 f0       	push   $0xf0107791
f0101714:	e8 27 e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101719:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010171c:	29 c8                	sub    %ecx,%eax
f010171e:	c1 f8 03             	sar    $0x3,%eax
f0101721:	c1 e0 0c             	shl    $0xc,%eax
f0101724:	39 c2                	cmp    %eax,%edx
f0101726:	77 19                	ja     f0101741 <mem_init+0x2b0>
f0101728:	68 64 79 10 f0       	push   $0xf0107964
f010172d:	68 d4 77 10 f0       	push   $0xf01077d4
f0101732:	68 52 03 00 00       	push   $0x352
f0101737:	68 91 77 10 f0       	push   $0xf0107791
f010173c:	e8 ff e8 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101741:	a1 40 62 21 f0       	mov    0xf0216240,%eax
f0101746:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101749:	c7 05 40 62 21 f0 00 	movl   $0x0,0xf0216240
f0101750:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101753:	83 ec 0c             	sub    $0xc,%esp
f0101756:	6a 00                	push   $0x0
f0101758:	e8 5f f8 ff ff       	call   f0100fbc <page_alloc>
f010175d:	83 c4 10             	add    $0x10,%esp
f0101760:	85 c0                	test   %eax,%eax
f0101762:	74 19                	je     f010177d <mem_init+0x2ec>
f0101764:	68 81 79 10 f0       	push   $0xf0107981
f0101769:	68 d4 77 10 f0       	push   $0xf01077d4
f010176e:	68 59 03 00 00       	push   $0x359
f0101773:	68 91 77 10 f0       	push   $0xf0107791
f0101778:	e8 c3 e8 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f010177d:	83 ec 0c             	sub    $0xc,%esp
f0101780:	57                   	push   %edi
f0101781:	e8 a6 f8 ff ff       	call   f010102c <page_free>
	page_free(pp1);
f0101786:	89 34 24             	mov    %esi,(%esp)
f0101789:	e8 9e f8 ff ff       	call   f010102c <page_free>
	page_free(pp2);
f010178e:	83 c4 04             	add    $0x4,%esp
f0101791:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101794:	e8 93 f8 ff ff       	call   f010102c <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101799:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017a0:	e8 17 f8 ff ff       	call   f0100fbc <page_alloc>
f01017a5:	89 c6                	mov    %eax,%esi
f01017a7:	83 c4 10             	add    $0x10,%esp
f01017aa:	85 c0                	test   %eax,%eax
f01017ac:	75 19                	jne    f01017c7 <mem_init+0x336>
f01017ae:	68 d6 78 10 f0       	push   $0xf01078d6
f01017b3:	68 d4 77 10 f0       	push   $0xf01077d4
f01017b8:	68 60 03 00 00       	push   $0x360
f01017bd:	68 91 77 10 f0       	push   $0xf0107791
f01017c2:	e8 79 e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01017c7:	83 ec 0c             	sub    $0xc,%esp
f01017ca:	6a 00                	push   $0x0
f01017cc:	e8 eb f7 ff ff       	call   f0100fbc <page_alloc>
f01017d1:	89 c7                	mov    %eax,%edi
f01017d3:	83 c4 10             	add    $0x10,%esp
f01017d6:	85 c0                	test   %eax,%eax
f01017d8:	75 19                	jne    f01017f3 <mem_init+0x362>
f01017da:	68 ec 78 10 f0       	push   $0xf01078ec
f01017df:	68 d4 77 10 f0       	push   $0xf01077d4
f01017e4:	68 61 03 00 00       	push   $0x361
f01017e9:	68 91 77 10 f0       	push   $0xf0107791
f01017ee:	e8 4d e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01017f3:	83 ec 0c             	sub    $0xc,%esp
f01017f6:	6a 00                	push   $0x0
f01017f8:	e8 bf f7 ff ff       	call   f0100fbc <page_alloc>
f01017fd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101800:	83 c4 10             	add    $0x10,%esp
f0101803:	85 c0                	test   %eax,%eax
f0101805:	75 19                	jne    f0101820 <mem_init+0x38f>
f0101807:	68 02 79 10 f0       	push   $0xf0107902
f010180c:	68 d4 77 10 f0       	push   $0xf01077d4
f0101811:	68 62 03 00 00       	push   $0x362
f0101816:	68 91 77 10 f0       	push   $0xf0107791
f010181b:	e8 20 e8 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101820:	39 fe                	cmp    %edi,%esi
f0101822:	75 19                	jne    f010183d <mem_init+0x3ac>
f0101824:	68 18 79 10 f0       	push   $0xf0107918
f0101829:	68 d4 77 10 f0       	push   $0xf01077d4
f010182e:	68 64 03 00 00       	push   $0x364
f0101833:	68 91 77 10 f0       	push   $0xf0107791
f0101838:	e8 03 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010183d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101840:	39 c7                	cmp    %eax,%edi
f0101842:	74 04                	je     f0101848 <mem_init+0x3b7>
f0101844:	39 c6                	cmp    %eax,%esi
f0101846:	75 19                	jne    f0101861 <mem_init+0x3d0>
f0101848:	68 b4 6f 10 f0       	push   $0xf0106fb4
f010184d:	68 d4 77 10 f0       	push   $0xf01077d4
f0101852:	68 65 03 00 00       	push   $0x365
f0101857:	68 91 77 10 f0       	push   $0xf0107791
f010185c:	e8 df e7 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101861:	83 ec 0c             	sub    $0xc,%esp
f0101864:	6a 00                	push   $0x0
f0101866:	e8 51 f7 ff ff       	call   f0100fbc <page_alloc>
f010186b:	83 c4 10             	add    $0x10,%esp
f010186e:	85 c0                	test   %eax,%eax
f0101870:	74 19                	je     f010188b <mem_init+0x3fa>
f0101872:	68 81 79 10 f0       	push   $0xf0107981
f0101877:	68 d4 77 10 f0       	push   $0xf01077d4
f010187c:	68 66 03 00 00       	push   $0x366
f0101881:	68 91 77 10 f0       	push   $0xf0107791
f0101886:	e8 b5 e7 ff ff       	call   f0100040 <_panic>
f010188b:	89 f0                	mov    %esi,%eax
f010188d:	2b 05 90 6e 21 f0    	sub    0xf0216e90,%eax
f0101893:	c1 f8 03             	sar    $0x3,%eax
f0101896:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101899:	89 c2                	mov    %eax,%edx
f010189b:	c1 ea 0c             	shr    $0xc,%edx
f010189e:	3b 15 88 6e 21 f0    	cmp    0xf0216e88,%edx
f01018a4:	72 12                	jb     f01018b8 <mem_init+0x427>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018a6:	50                   	push   %eax
f01018a7:	68 c4 68 10 f0       	push   $0xf01068c4
f01018ac:	6a 58                	push   $0x58
f01018ae:	68 ba 77 10 f0       	push   $0xf01077ba
f01018b3:	e8 88 e7 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01018b8:	83 ec 04             	sub    $0x4,%esp
f01018bb:	68 00 10 00 00       	push   $0x1000
f01018c0:	6a 01                	push   $0x1
f01018c2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01018c7:	50                   	push   %eax
f01018c8:	e8 12 43 00 00       	call   f0105bdf <memset>
	page_free(pp0);
f01018cd:	89 34 24             	mov    %esi,(%esp)
f01018d0:	e8 57 f7 ff ff       	call   f010102c <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01018d5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01018dc:	e8 db f6 ff ff       	call   f0100fbc <page_alloc>
f01018e1:	83 c4 10             	add    $0x10,%esp
f01018e4:	85 c0                	test   %eax,%eax
f01018e6:	75 19                	jne    f0101901 <mem_init+0x470>
f01018e8:	68 90 79 10 f0       	push   $0xf0107990
f01018ed:	68 d4 77 10 f0       	push   $0xf01077d4
f01018f2:	68 6b 03 00 00       	push   $0x36b
f01018f7:	68 91 77 10 f0       	push   $0xf0107791
f01018fc:	e8 3f e7 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101901:	39 c6                	cmp    %eax,%esi
f0101903:	74 19                	je     f010191e <mem_init+0x48d>
f0101905:	68 ae 79 10 f0       	push   $0xf01079ae
f010190a:	68 d4 77 10 f0       	push   $0xf01077d4
f010190f:	68 6c 03 00 00       	push   $0x36c
f0101914:	68 91 77 10 f0       	push   $0xf0107791
f0101919:	e8 22 e7 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010191e:	89 f0                	mov    %esi,%eax
f0101920:	2b 05 90 6e 21 f0    	sub    0xf0216e90,%eax
f0101926:	c1 f8 03             	sar    $0x3,%eax
f0101929:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010192c:	89 c2                	mov    %eax,%edx
f010192e:	c1 ea 0c             	shr    $0xc,%edx
f0101931:	3b 15 88 6e 21 f0    	cmp    0xf0216e88,%edx
f0101937:	72 12                	jb     f010194b <mem_init+0x4ba>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101939:	50                   	push   %eax
f010193a:	68 c4 68 10 f0       	push   $0xf01068c4
f010193f:	6a 58                	push   $0x58
f0101941:	68 ba 77 10 f0       	push   $0xf01077ba
f0101946:	e8 f5 e6 ff ff       	call   f0100040 <_panic>
f010194b:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101951:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101957:	80 38 00             	cmpb   $0x0,(%eax)
f010195a:	74 19                	je     f0101975 <mem_init+0x4e4>
f010195c:	68 be 79 10 f0       	push   $0xf01079be
f0101961:	68 d4 77 10 f0       	push   $0xf01077d4
f0101966:	68 6f 03 00 00       	push   $0x36f
f010196b:	68 91 77 10 f0       	push   $0xf0107791
f0101970:	e8 cb e6 ff ff       	call   f0100040 <_panic>
f0101975:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101978:	39 d0                	cmp    %edx,%eax
f010197a:	75 db                	jne    f0101957 <mem_init+0x4c6>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f010197c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010197f:	a3 40 62 21 f0       	mov    %eax,0xf0216240

	// free the pages we took
	page_free(pp0);
f0101984:	83 ec 0c             	sub    $0xc,%esp
f0101987:	56                   	push   %esi
f0101988:	e8 9f f6 ff ff       	call   f010102c <page_free>
	page_free(pp1);
f010198d:	89 3c 24             	mov    %edi,(%esp)
f0101990:	e8 97 f6 ff ff       	call   f010102c <page_free>
	page_free(pp2);
f0101995:	83 c4 04             	add    $0x4,%esp
f0101998:	ff 75 d4             	pushl  -0x2c(%ebp)
f010199b:	e8 8c f6 ff ff       	call   f010102c <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01019a0:	a1 40 62 21 f0       	mov    0xf0216240,%eax
f01019a5:	83 c4 10             	add    $0x10,%esp
f01019a8:	eb 05                	jmp    f01019af <mem_init+0x51e>
		--nfree;
f01019aa:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01019ad:	8b 00                	mov    (%eax),%eax
f01019af:	85 c0                	test   %eax,%eax
f01019b1:	75 f7                	jne    f01019aa <mem_init+0x519>
		--nfree;
	assert(nfree == 0);
f01019b3:	85 db                	test   %ebx,%ebx
f01019b5:	74 19                	je     f01019d0 <mem_init+0x53f>
f01019b7:	68 c8 79 10 f0       	push   $0xf01079c8
f01019bc:	68 d4 77 10 f0       	push   $0xf01077d4
f01019c1:	68 7c 03 00 00       	push   $0x37c
f01019c6:	68 91 77 10 f0       	push   $0xf0107791
f01019cb:	e8 70 e6 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01019d0:	83 ec 0c             	sub    $0xc,%esp
f01019d3:	68 d4 6f 10 f0       	push   $0xf0106fd4
f01019d8:	e8 43 21 00 00       	call   f0103b20 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01019dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019e4:	e8 d3 f5 ff ff       	call   f0100fbc <page_alloc>
f01019e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01019ec:	83 c4 10             	add    $0x10,%esp
f01019ef:	85 c0                	test   %eax,%eax
f01019f1:	75 19                	jne    f0101a0c <mem_init+0x57b>
f01019f3:	68 d6 78 10 f0       	push   $0xf01078d6
f01019f8:	68 d4 77 10 f0       	push   $0xf01077d4
f01019fd:	68 e2 03 00 00       	push   $0x3e2
f0101a02:	68 91 77 10 f0       	push   $0xf0107791
f0101a07:	e8 34 e6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101a0c:	83 ec 0c             	sub    $0xc,%esp
f0101a0f:	6a 00                	push   $0x0
f0101a11:	e8 a6 f5 ff ff       	call   f0100fbc <page_alloc>
f0101a16:	89 c3                	mov    %eax,%ebx
f0101a18:	83 c4 10             	add    $0x10,%esp
f0101a1b:	85 c0                	test   %eax,%eax
f0101a1d:	75 19                	jne    f0101a38 <mem_init+0x5a7>
f0101a1f:	68 ec 78 10 f0       	push   $0xf01078ec
f0101a24:	68 d4 77 10 f0       	push   $0xf01077d4
f0101a29:	68 e3 03 00 00       	push   $0x3e3
f0101a2e:	68 91 77 10 f0       	push   $0xf0107791
f0101a33:	e8 08 e6 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a38:	83 ec 0c             	sub    $0xc,%esp
f0101a3b:	6a 00                	push   $0x0
f0101a3d:	e8 7a f5 ff ff       	call   f0100fbc <page_alloc>
f0101a42:	89 c6                	mov    %eax,%esi
f0101a44:	83 c4 10             	add    $0x10,%esp
f0101a47:	85 c0                	test   %eax,%eax
f0101a49:	75 19                	jne    f0101a64 <mem_init+0x5d3>
f0101a4b:	68 02 79 10 f0       	push   $0xf0107902
f0101a50:	68 d4 77 10 f0       	push   $0xf01077d4
f0101a55:	68 e4 03 00 00       	push   $0x3e4
f0101a5a:	68 91 77 10 f0       	push   $0xf0107791
f0101a5f:	e8 dc e5 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a64:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101a67:	75 19                	jne    f0101a82 <mem_init+0x5f1>
f0101a69:	68 18 79 10 f0       	push   $0xf0107918
f0101a6e:	68 d4 77 10 f0       	push   $0xf01077d4
f0101a73:	68 e7 03 00 00       	push   $0x3e7
f0101a78:	68 91 77 10 f0       	push   $0xf0107791
f0101a7d:	e8 be e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a82:	39 c3                	cmp    %eax,%ebx
f0101a84:	74 05                	je     f0101a8b <mem_init+0x5fa>
f0101a86:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101a89:	75 19                	jne    f0101aa4 <mem_init+0x613>
f0101a8b:	68 b4 6f 10 f0       	push   $0xf0106fb4
f0101a90:	68 d4 77 10 f0       	push   $0xf01077d4
f0101a95:	68 e8 03 00 00       	push   $0x3e8
f0101a9a:	68 91 77 10 f0       	push   $0xf0107791
f0101a9f:	e8 9c e5 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101aa4:	a1 40 62 21 f0       	mov    0xf0216240,%eax
f0101aa9:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101aac:	c7 05 40 62 21 f0 00 	movl   $0x0,0xf0216240
f0101ab3:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101ab6:	83 ec 0c             	sub    $0xc,%esp
f0101ab9:	6a 00                	push   $0x0
f0101abb:	e8 fc f4 ff ff       	call   f0100fbc <page_alloc>
f0101ac0:	83 c4 10             	add    $0x10,%esp
f0101ac3:	85 c0                	test   %eax,%eax
f0101ac5:	74 19                	je     f0101ae0 <mem_init+0x64f>
f0101ac7:	68 81 79 10 f0       	push   $0xf0107981
f0101acc:	68 d4 77 10 f0       	push   $0xf01077d4
f0101ad1:	68 ef 03 00 00       	push   $0x3ef
f0101ad6:	68 91 77 10 f0       	push   $0xf0107791
f0101adb:	e8 60 e5 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101ae0:	83 ec 04             	sub    $0x4,%esp
f0101ae3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101ae6:	50                   	push   %eax
f0101ae7:	6a 00                	push   $0x0
f0101ae9:	ff 35 8c 6e 21 f0    	pushl  0xf0216e8c
f0101aef:	e8 4c f7 ff ff       	call   f0101240 <page_lookup>
f0101af4:	83 c4 10             	add    $0x10,%esp
f0101af7:	85 c0                	test   %eax,%eax
f0101af9:	74 19                	je     f0101b14 <mem_init+0x683>
f0101afb:	68 f4 6f 10 f0       	push   $0xf0106ff4
f0101b00:	68 d4 77 10 f0       	push   $0xf01077d4
f0101b05:	68 f2 03 00 00       	push   $0x3f2
f0101b0a:	68 91 77 10 f0       	push   $0xf0107791
f0101b0f:	e8 2c e5 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101b14:	6a 02                	push   $0x2
f0101b16:	6a 00                	push   $0x0
f0101b18:	53                   	push   %ebx
f0101b19:	ff 35 8c 6e 21 f0    	pushl  0xf0216e8c
f0101b1f:	e8 46 f8 ff ff       	call   f010136a <page_insert>
f0101b24:	83 c4 10             	add    $0x10,%esp
f0101b27:	85 c0                	test   %eax,%eax
f0101b29:	78 19                	js     f0101b44 <mem_init+0x6b3>
f0101b2b:	68 2c 70 10 f0       	push   $0xf010702c
f0101b30:	68 d4 77 10 f0       	push   $0xf01077d4
f0101b35:	68 f5 03 00 00       	push   $0x3f5
f0101b3a:	68 91 77 10 f0       	push   $0xf0107791
f0101b3f:	e8 fc e4 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101b44:	83 ec 0c             	sub    $0xc,%esp
f0101b47:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b4a:	e8 dd f4 ff ff       	call   f010102c <page_free>

	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101b4f:	6a 02                	push   $0x2
f0101b51:	6a 00                	push   $0x0
f0101b53:	53                   	push   %ebx
f0101b54:	ff 35 8c 6e 21 f0    	pushl  0xf0216e8c
f0101b5a:	e8 0b f8 ff ff       	call   f010136a <page_insert>
f0101b5f:	83 c4 20             	add    $0x20,%esp
f0101b62:	85 c0                	test   %eax,%eax
f0101b64:	74 19                	je     f0101b7f <mem_init+0x6ee>
f0101b66:	68 5c 70 10 f0       	push   $0xf010705c
f0101b6b:	68 d4 77 10 f0       	push   $0xf01077d4
f0101b70:	68 fa 03 00 00       	push   $0x3fa
f0101b75:	68 91 77 10 f0       	push   $0xf0107791
f0101b7a:	e8 c1 e4 ff ff       	call   f0100040 <_panic>
        assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b7f:	8b 3d 8c 6e 21 f0    	mov    0xf0216e8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b85:	a1 90 6e 21 f0       	mov    0xf0216e90,%eax
f0101b8a:	89 c1                	mov    %eax,%ecx
f0101b8c:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0101b8f:	8b 17                	mov    (%edi),%edx
f0101b91:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101b97:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b9a:	29 c8                	sub    %ecx,%eax
f0101b9c:	c1 f8 03             	sar    $0x3,%eax
f0101b9f:	c1 e0 0c             	shl    $0xc,%eax
f0101ba2:	39 c2                	cmp    %eax,%edx
f0101ba4:	74 19                	je     f0101bbf <mem_init+0x72e>
f0101ba6:	68 8c 70 10 f0       	push   $0xf010708c
f0101bab:	68 d4 77 10 f0       	push   $0xf01077d4
f0101bb0:	68 fb 03 00 00       	push   $0x3fb
f0101bb5:	68 91 77 10 f0       	push   $0xf0107791
f0101bba:	e8 81 e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101bbf:	ba 00 00 00 00       	mov    $0x0,%edx
f0101bc4:	89 f8                	mov    %edi,%eax
f0101bc6:	e8 fb ee ff ff       	call   f0100ac6 <check_va2pa>
f0101bcb:	89 da                	mov    %ebx,%edx
f0101bcd:	2b 55 c8             	sub    -0x38(%ebp),%edx
f0101bd0:	c1 fa 03             	sar    $0x3,%edx
f0101bd3:	c1 e2 0c             	shl    $0xc,%edx
f0101bd6:	39 d0                	cmp    %edx,%eax
f0101bd8:	74 19                	je     f0101bf3 <mem_init+0x762>
f0101bda:	68 b4 70 10 f0       	push   $0xf01070b4
f0101bdf:	68 d4 77 10 f0       	push   $0xf01077d4
f0101be4:	68 fc 03 00 00       	push   $0x3fc
f0101be9:	68 91 77 10 f0       	push   $0xf0107791
f0101bee:	e8 4d e4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101bf3:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101bf8:	74 19                	je     f0101c13 <mem_init+0x782>
f0101bfa:	68 d3 79 10 f0       	push   $0xf01079d3
f0101bff:	68 d4 77 10 f0       	push   $0xf01077d4
f0101c04:	68 fd 03 00 00       	push   $0x3fd
f0101c09:	68 91 77 10 f0       	push   $0xf0107791
f0101c0e:	e8 2d e4 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101c13:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c16:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101c1b:	74 19                	je     f0101c36 <mem_init+0x7a5>
f0101c1d:	68 e4 79 10 f0       	push   $0xf01079e4
f0101c22:	68 d4 77 10 f0       	push   $0xf01077d4
f0101c27:	68 fe 03 00 00       	push   $0x3fe
f0101c2c:	68 91 77 10 f0       	push   $0xf0107791
f0101c31:	e8 0a e4 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c36:	6a 02                	push   $0x2
f0101c38:	68 00 10 00 00       	push   $0x1000
f0101c3d:	56                   	push   %esi
f0101c3e:	57                   	push   %edi
f0101c3f:	e8 26 f7 ff ff       	call   f010136a <page_insert>
f0101c44:	83 c4 10             	add    $0x10,%esp
f0101c47:	85 c0                	test   %eax,%eax
f0101c49:	74 19                	je     f0101c64 <mem_init+0x7d3>
f0101c4b:	68 e4 70 10 f0       	push   $0xf01070e4
f0101c50:	68 d4 77 10 f0       	push   $0xf01077d4
f0101c55:	68 01 04 00 00       	push   $0x401
f0101c5a:	68 91 77 10 f0       	push   $0xf0107791
f0101c5f:	e8 dc e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c64:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c69:	a1 8c 6e 21 f0       	mov    0xf0216e8c,%eax
f0101c6e:	e8 53 ee ff ff       	call   f0100ac6 <check_va2pa>
f0101c73:	89 f2                	mov    %esi,%edx
f0101c75:	2b 15 90 6e 21 f0    	sub    0xf0216e90,%edx
f0101c7b:	c1 fa 03             	sar    $0x3,%edx
f0101c7e:	c1 e2 0c             	shl    $0xc,%edx
f0101c81:	39 d0                	cmp    %edx,%eax
f0101c83:	74 19                	je     f0101c9e <mem_init+0x80d>
f0101c85:	68 20 71 10 f0       	push   $0xf0107120
f0101c8a:	68 d4 77 10 f0       	push   $0xf01077d4
f0101c8f:	68 02 04 00 00       	push   $0x402
f0101c94:	68 91 77 10 f0       	push   $0xf0107791
f0101c99:	e8 a2 e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101c9e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ca3:	74 19                	je     f0101cbe <mem_init+0x82d>
f0101ca5:	68 f5 79 10 f0       	push   $0xf01079f5
f0101caa:	68 d4 77 10 f0       	push   $0xf01077d4
f0101caf:	68 03 04 00 00       	push   $0x403
f0101cb4:	68 91 77 10 f0       	push   $0xf0107791
f0101cb9:	e8 82 e3 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101cbe:	83 ec 0c             	sub    $0xc,%esp
f0101cc1:	6a 00                	push   $0x0
f0101cc3:	e8 f4 f2 ff ff       	call   f0100fbc <page_alloc>
f0101cc8:	83 c4 10             	add    $0x10,%esp
f0101ccb:	85 c0                	test   %eax,%eax
f0101ccd:	74 19                	je     f0101ce8 <mem_init+0x857>
f0101ccf:	68 81 79 10 f0       	push   $0xf0107981
f0101cd4:	68 d4 77 10 f0       	push   $0xf01077d4
f0101cd9:	68 06 04 00 00       	push   $0x406
f0101cde:	68 91 77 10 f0       	push   $0xf0107791
f0101ce3:	e8 58 e3 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ce8:	6a 02                	push   $0x2
f0101cea:	68 00 10 00 00       	push   $0x1000
f0101cef:	56                   	push   %esi
f0101cf0:	ff 35 8c 6e 21 f0    	pushl  0xf0216e8c
f0101cf6:	e8 6f f6 ff ff       	call   f010136a <page_insert>
f0101cfb:	83 c4 10             	add    $0x10,%esp
f0101cfe:	85 c0                	test   %eax,%eax
f0101d00:	74 19                	je     f0101d1b <mem_init+0x88a>
f0101d02:	68 e4 70 10 f0       	push   $0xf01070e4
f0101d07:	68 d4 77 10 f0       	push   $0xf01077d4
f0101d0c:	68 09 04 00 00       	push   $0x409
f0101d11:	68 91 77 10 f0       	push   $0xf0107791
f0101d16:	e8 25 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d1b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d20:	a1 8c 6e 21 f0       	mov    0xf0216e8c,%eax
f0101d25:	e8 9c ed ff ff       	call   f0100ac6 <check_va2pa>
f0101d2a:	89 f2                	mov    %esi,%edx
f0101d2c:	2b 15 90 6e 21 f0    	sub    0xf0216e90,%edx
f0101d32:	c1 fa 03             	sar    $0x3,%edx
f0101d35:	c1 e2 0c             	shl    $0xc,%edx
f0101d38:	39 d0                	cmp    %edx,%eax
f0101d3a:	74 19                	je     f0101d55 <mem_init+0x8c4>
f0101d3c:	68 20 71 10 f0       	push   $0xf0107120
f0101d41:	68 d4 77 10 f0       	push   $0xf01077d4
f0101d46:	68 0a 04 00 00       	push   $0x40a
f0101d4b:	68 91 77 10 f0       	push   $0xf0107791
f0101d50:	e8 eb e2 ff ff       	call   f0100040 <_panic>
        assert(pp2->pp_ref == 1);
f0101d55:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d5a:	74 19                	je     f0101d75 <mem_init+0x8e4>
f0101d5c:	68 f5 79 10 f0       	push   $0xf01079f5
f0101d61:	68 d4 77 10 f0       	push   $0xf01077d4
f0101d66:	68 0b 04 00 00       	push   $0x40b
f0101d6b:	68 91 77 10 f0       	push   $0xf0107791
f0101d70:	e8 cb e2 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101d75:	83 ec 0c             	sub    $0xc,%esp
f0101d78:	6a 00                	push   $0x0
f0101d7a:	e8 3d f2 ff ff       	call   f0100fbc <page_alloc>
f0101d7f:	83 c4 10             	add    $0x10,%esp
f0101d82:	85 c0                	test   %eax,%eax
f0101d84:	74 19                	je     f0101d9f <mem_init+0x90e>
f0101d86:	68 81 79 10 f0       	push   $0xf0107981
f0101d8b:	68 d4 77 10 f0       	push   $0xf01077d4
f0101d90:	68 0f 04 00 00       	push   $0x40f
f0101d95:	68 91 77 10 f0       	push   $0xf0107791
f0101d9a:	e8 a1 e2 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101d9f:	8b 15 8c 6e 21 f0    	mov    0xf0216e8c,%edx
f0101da5:	8b 02                	mov    (%edx),%eax
f0101da7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101dac:	89 c1                	mov    %eax,%ecx
f0101dae:	c1 e9 0c             	shr    $0xc,%ecx
f0101db1:	3b 0d 88 6e 21 f0    	cmp    0xf0216e88,%ecx
f0101db7:	72 15                	jb     f0101dce <mem_init+0x93d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101db9:	50                   	push   %eax
f0101dba:	68 c4 68 10 f0       	push   $0xf01068c4
f0101dbf:	68 12 04 00 00       	push   $0x412
f0101dc4:	68 91 77 10 f0       	push   $0xf0107791
f0101dc9:	e8 72 e2 ff ff       	call   f0100040 <_panic>
f0101dce:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101dd3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101dd6:	83 ec 04             	sub    $0x4,%esp
f0101dd9:	6a 00                	push   $0x0
f0101ddb:	68 00 10 00 00       	push   $0x1000
f0101de0:	52                   	push   %edx
f0101de1:	e8 dc f2 ff ff       	call   f01010c2 <pgdir_walk>
f0101de6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101de9:	8d 51 04             	lea    0x4(%ecx),%edx
f0101dec:	83 c4 10             	add    $0x10,%esp
f0101def:	39 d0                	cmp    %edx,%eax
f0101df1:	74 19                	je     f0101e0c <mem_init+0x97b>
f0101df3:	68 50 71 10 f0       	push   $0xf0107150
f0101df8:	68 d4 77 10 f0       	push   $0xf01077d4
f0101dfd:	68 13 04 00 00       	push   $0x413
f0101e02:	68 91 77 10 f0       	push   $0xf0107791
f0101e07:	e8 34 e2 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101e0c:	6a 06                	push   $0x6
f0101e0e:	68 00 10 00 00       	push   $0x1000
f0101e13:	56                   	push   %esi
f0101e14:	ff 35 8c 6e 21 f0    	pushl  0xf0216e8c
f0101e1a:	e8 4b f5 ff ff       	call   f010136a <page_insert>
f0101e1f:	83 c4 10             	add    $0x10,%esp
f0101e22:	85 c0                	test   %eax,%eax
f0101e24:	74 19                	je     f0101e3f <mem_init+0x9ae>
f0101e26:	68 90 71 10 f0       	push   $0xf0107190
f0101e2b:	68 d4 77 10 f0       	push   $0xf01077d4
f0101e30:	68 16 04 00 00       	push   $0x416
f0101e35:	68 91 77 10 f0       	push   $0xf0107791
f0101e3a:	e8 01 e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e3f:	8b 3d 8c 6e 21 f0    	mov    0xf0216e8c,%edi
f0101e45:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e4a:	89 f8                	mov    %edi,%eax
f0101e4c:	e8 75 ec ff ff       	call   f0100ac6 <check_va2pa>
f0101e51:	89 f2                	mov    %esi,%edx
f0101e53:	2b 15 90 6e 21 f0    	sub    0xf0216e90,%edx
f0101e59:	c1 fa 03             	sar    $0x3,%edx
f0101e5c:	c1 e2 0c             	shl    $0xc,%edx
f0101e5f:	39 d0                	cmp    %edx,%eax
f0101e61:	74 19                	je     f0101e7c <mem_init+0x9eb>
f0101e63:	68 20 71 10 f0       	push   $0xf0107120
f0101e68:	68 d4 77 10 f0       	push   $0xf01077d4
f0101e6d:	68 17 04 00 00       	push   $0x417
f0101e72:	68 91 77 10 f0       	push   $0xf0107791
f0101e77:	e8 c4 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101e7c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101e81:	74 19                	je     f0101e9c <mem_init+0xa0b>
f0101e83:	68 f5 79 10 f0       	push   $0xf01079f5
f0101e88:	68 d4 77 10 f0       	push   $0xf01077d4
f0101e8d:	68 18 04 00 00       	push   $0x418
f0101e92:	68 91 77 10 f0       	push   $0xf0107791
f0101e97:	e8 a4 e1 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101e9c:	83 ec 04             	sub    $0x4,%esp
f0101e9f:	6a 00                	push   $0x0
f0101ea1:	68 00 10 00 00       	push   $0x1000
f0101ea6:	57                   	push   %edi
f0101ea7:	e8 16 f2 ff ff       	call   f01010c2 <pgdir_walk>
f0101eac:	83 c4 10             	add    $0x10,%esp
f0101eaf:	f6 00 04             	testb  $0x4,(%eax)
f0101eb2:	75 19                	jne    f0101ecd <mem_init+0xa3c>
f0101eb4:	68 d0 71 10 f0       	push   $0xf01071d0
f0101eb9:	68 d4 77 10 f0       	push   $0xf01077d4
f0101ebe:	68 19 04 00 00       	push   $0x419
f0101ec3:	68 91 77 10 f0       	push   $0xf0107791
f0101ec8:	e8 73 e1 ff ff       	call   f0100040 <_panic>
        assert(kern_pgdir[0] & PTE_U);
f0101ecd:	a1 8c 6e 21 f0       	mov    0xf0216e8c,%eax
f0101ed2:	f6 00 04             	testb  $0x4,(%eax)
f0101ed5:	75 19                	jne    f0101ef0 <mem_init+0xa5f>
f0101ed7:	68 06 7a 10 f0       	push   $0xf0107a06
f0101edc:	68 d4 77 10 f0       	push   $0xf01077d4
f0101ee1:	68 1a 04 00 00       	push   $0x41a
f0101ee6:	68 91 77 10 f0       	push   $0xf0107791
f0101eeb:	e8 50 e1 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ef0:	6a 02                	push   $0x2
f0101ef2:	68 00 10 00 00       	push   $0x1000
f0101ef7:	56                   	push   %esi
f0101ef8:	50                   	push   %eax
f0101ef9:	e8 6c f4 ff ff       	call   f010136a <page_insert>
f0101efe:	83 c4 10             	add    $0x10,%esp
f0101f01:	85 c0                	test   %eax,%eax
f0101f03:	74 19                	je     f0101f1e <mem_init+0xa8d>
f0101f05:	68 e4 70 10 f0       	push   $0xf01070e4
f0101f0a:	68 d4 77 10 f0       	push   $0xf01077d4
f0101f0f:	68 1d 04 00 00       	push   $0x41d
f0101f14:	68 91 77 10 f0       	push   $0xf0107791
f0101f19:	e8 22 e1 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101f1e:	83 ec 04             	sub    $0x4,%esp
f0101f21:	6a 00                	push   $0x0
f0101f23:	68 00 10 00 00       	push   $0x1000
f0101f28:	ff 35 8c 6e 21 f0    	pushl  0xf0216e8c
f0101f2e:	e8 8f f1 ff ff       	call   f01010c2 <pgdir_walk>
f0101f33:	83 c4 10             	add    $0x10,%esp
f0101f36:	f6 00 02             	testb  $0x2,(%eax)
f0101f39:	75 19                	jne    f0101f54 <mem_init+0xac3>
f0101f3b:	68 04 72 10 f0       	push   $0xf0107204
f0101f40:	68 d4 77 10 f0       	push   $0xf01077d4
f0101f45:	68 1e 04 00 00       	push   $0x41e
f0101f4a:	68 91 77 10 f0       	push   $0xf0107791
f0101f4f:	e8 ec e0 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f54:	83 ec 04             	sub    $0x4,%esp
f0101f57:	6a 00                	push   $0x0
f0101f59:	68 00 10 00 00       	push   $0x1000
f0101f5e:	ff 35 8c 6e 21 f0    	pushl  0xf0216e8c
f0101f64:	e8 59 f1 ff ff       	call   f01010c2 <pgdir_walk>
f0101f69:	83 c4 10             	add    $0x10,%esp
f0101f6c:	f6 00 04             	testb  $0x4,(%eax)
f0101f6f:	74 19                	je     f0101f8a <mem_init+0xaf9>
f0101f71:	68 38 72 10 f0       	push   $0xf0107238
f0101f76:	68 d4 77 10 f0       	push   $0xf01077d4
f0101f7b:	68 1f 04 00 00       	push   $0x41f
f0101f80:	68 91 77 10 f0       	push   $0xf0107791
f0101f85:	e8 b6 e0 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101f8a:	6a 02                	push   $0x2
f0101f8c:	68 00 00 40 00       	push   $0x400000
f0101f91:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101f94:	ff 35 8c 6e 21 f0    	pushl  0xf0216e8c
f0101f9a:	e8 cb f3 ff ff       	call   f010136a <page_insert>
f0101f9f:	83 c4 10             	add    $0x10,%esp
f0101fa2:	85 c0                	test   %eax,%eax
f0101fa4:	78 19                	js     f0101fbf <mem_init+0xb2e>
f0101fa6:	68 70 72 10 f0       	push   $0xf0107270
f0101fab:	68 d4 77 10 f0       	push   $0xf01077d4
f0101fb0:	68 22 04 00 00       	push   $0x422
f0101fb5:	68 91 77 10 f0       	push   $0xf0107791
f0101fba:	e8 81 e0 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101fbf:	6a 02                	push   $0x2
f0101fc1:	68 00 10 00 00       	push   $0x1000
f0101fc6:	53                   	push   %ebx
f0101fc7:	ff 35 8c 6e 21 f0    	pushl  0xf0216e8c
f0101fcd:	e8 98 f3 ff ff       	call   f010136a <page_insert>
f0101fd2:	83 c4 10             	add    $0x10,%esp
f0101fd5:	85 c0                	test   %eax,%eax
f0101fd7:	74 19                	je     f0101ff2 <mem_init+0xb61>
f0101fd9:	68 a8 72 10 f0       	push   $0xf01072a8
f0101fde:	68 d4 77 10 f0       	push   $0xf01077d4
f0101fe3:	68 25 04 00 00       	push   $0x425
f0101fe8:	68 91 77 10 f0       	push   $0xf0107791
f0101fed:	e8 4e e0 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101ff2:	83 ec 04             	sub    $0x4,%esp
f0101ff5:	6a 00                	push   $0x0
f0101ff7:	68 00 10 00 00       	push   $0x1000
f0101ffc:	ff 35 8c 6e 21 f0    	pushl  0xf0216e8c
f0102002:	e8 bb f0 ff ff       	call   f01010c2 <pgdir_walk>
f0102007:	83 c4 10             	add    $0x10,%esp
f010200a:	f6 00 04             	testb  $0x4,(%eax)
f010200d:	74 19                	je     f0102028 <mem_init+0xb97>
f010200f:	68 38 72 10 f0       	push   $0xf0107238
f0102014:	68 d4 77 10 f0       	push   $0xf01077d4
f0102019:	68 26 04 00 00       	push   $0x426
f010201e:	68 91 77 10 f0       	push   $0xf0107791
f0102023:	e8 18 e0 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102028:	8b 3d 8c 6e 21 f0    	mov    0xf0216e8c,%edi
f010202e:	ba 00 00 00 00       	mov    $0x0,%edx
f0102033:	89 f8                	mov    %edi,%eax
f0102035:	e8 8c ea ff ff       	call   f0100ac6 <check_va2pa>
f010203a:	89 c1                	mov    %eax,%ecx
f010203c:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010203f:	89 d8                	mov    %ebx,%eax
f0102041:	2b 05 90 6e 21 f0    	sub    0xf0216e90,%eax
f0102047:	c1 f8 03             	sar    $0x3,%eax
f010204a:	c1 e0 0c             	shl    $0xc,%eax
f010204d:	39 c1                	cmp    %eax,%ecx
f010204f:	74 19                	je     f010206a <mem_init+0xbd9>
f0102051:	68 e4 72 10 f0       	push   $0xf01072e4
f0102056:	68 d4 77 10 f0       	push   $0xf01077d4
f010205b:	68 29 04 00 00       	push   $0x429
f0102060:	68 91 77 10 f0       	push   $0xf0107791
f0102065:	e8 d6 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010206a:	ba 00 10 00 00       	mov    $0x1000,%edx
f010206f:	89 f8                	mov    %edi,%eax
f0102071:	e8 50 ea ff ff       	call   f0100ac6 <check_va2pa>
f0102076:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0102079:	74 19                	je     f0102094 <mem_init+0xc03>
f010207b:	68 10 73 10 f0       	push   $0xf0107310
f0102080:	68 d4 77 10 f0       	push   $0xf01077d4
f0102085:	68 2a 04 00 00       	push   $0x42a
f010208a:	68 91 77 10 f0       	push   $0xf0107791
f010208f:	e8 ac df ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102094:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0102099:	74 19                	je     f01020b4 <mem_init+0xc23>
f010209b:	68 1c 7a 10 f0       	push   $0xf0107a1c
f01020a0:	68 d4 77 10 f0       	push   $0xf01077d4
f01020a5:	68 2c 04 00 00       	push   $0x42c
f01020aa:	68 91 77 10 f0       	push   $0xf0107791
f01020af:	e8 8c df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01020b4:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01020b9:	74 19                	je     f01020d4 <mem_init+0xc43>
f01020bb:	68 2d 7a 10 f0       	push   $0xf0107a2d
f01020c0:	68 d4 77 10 f0       	push   $0xf01077d4
f01020c5:	68 2d 04 00 00       	push   $0x42d
f01020ca:	68 91 77 10 f0       	push   $0xf0107791
f01020cf:	e8 6c df ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01020d4:	83 ec 0c             	sub    $0xc,%esp
f01020d7:	6a 00                	push   $0x0
f01020d9:	e8 de ee ff ff       	call   f0100fbc <page_alloc>
f01020de:	83 c4 10             	add    $0x10,%esp
f01020e1:	85 c0                	test   %eax,%eax
f01020e3:	74 04                	je     f01020e9 <mem_init+0xc58>
f01020e5:	39 c6                	cmp    %eax,%esi
f01020e7:	74 19                	je     f0102102 <mem_init+0xc71>
f01020e9:	68 40 73 10 f0       	push   $0xf0107340
f01020ee:	68 d4 77 10 f0       	push   $0xf01077d4
f01020f3:	68 30 04 00 00       	push   $0x430
f01020f8:	68 91 77 10 f0       	push   $0xf0107791
f01020fd:	e8 3e df ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102102:	83 ec 08             	sub    $0x8,%esp
f0102105:	6a 00                	push   $0x0
f0102107:	ff 35 8c 6e 21 f0    	pushl  0xf0216e8c
f010210d:	e8 ea f1 ff ff       	call   f01012fc <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102112:	8b 3d 8c 6e 21 f0    	mov    0xf0216e8c,%edi
f0102118:	ba 00 00 00 00       	mov    $0x0,%edx
f010211d:	89 f8                	mov    %edi,%eax
f010211f:	e8 a2 e9 ff ff       	call   f0100ac6 <check_va2pa>
f0102124:	83 c4 10             	add    $0x10,%esp
f0102127:	83 f8 ff             	cmp    $0xffffffff,%eax
f010212a:	74 19                	je     f0102145 <mem_init+0xcb4>
f010212c:	68 64 73 10 f0       	push   $0xf0107364
f0102131:	68 d4 77 10 f0       	push   $0xf01077d4
f0102136:	68 34 04 00 00       	push   $0x434
f010213b:	68 91 77 10 f0       	push   $0xf0107791
f0102140:	e8 fb de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102145:	ba 00 10 00 00       	mov    $0x1000,%edx
f010214a:	89 f8                	mov    %edi,%eax
f010214c:	e8 75 e9 ff ff       	call   f0100ac6 <check_va2pa>
f0102151:	89 da                	mov    %ebx,%edx
f0102153:	2b 15 90 6e 21 f0    	sub    0xf0216e90,%edx
f0102159:	c1 fa 03             	sar    $0x3,%edx
f010215c:	c1 e2 0c             	shl    $0xc,%edx
f010215f:	39 d0                	cmp    %edx,%eax
f0102161:	74 19                	je     f010217c <mem_init+0xceb>
f0102163:	68 10 73 10 f0       	push   $0xf0107310
f0102168:	68 d4 77 10 f0       	push   $0xf01077d4
f010216d:	68 35 04 00 00       	push   $0x435
f0102172:	68 91 77 10 f0       	push   $0xf0107791
f0102177:	e8 c4 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010217c:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102181:	74 19                	je     f010219c <mem_init+0xd0b>
f0102183:	68 d3 79 10 f0       	push   $0xf01079d3
f0102188:	68 d4 77 10 f0       	push   $0xf01077d4
f010218d:	68 36 04 00 00       	push   $0x436
f0102192:	68 91 77 10 f0       	push   $0xf0107791
f0102197:	e8 a4 de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010219c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01021a1:	74 19                	je     f01021bc <mem_init+0xd2b>
f01021a3:	68 2d 7a 10 f0       	push   $0xf0107a2d
f01021a8:	68 d4 77 10 f0       	push   $0xf01077d4
f01021ad:	68 37 04 00 00       	push   $0x437
f01021b2:	68 91 77 10 f0       	push   $0xf0107791
f01021b7:	e8 84 de ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01021bc:	6a 00                	push   $0x0
f01021be:	68 00 10 00 00       	push   $0x1000
f01021c3:	53                   	push   %ebx
f01021c4:	57                   	push   %edi
f01021c5:	e8 a0 f1 ff ff       	call   f010136a <page_insert>
f01021ca:	83 c4 10             	add    $0x10,%esp
f01021cd:	85 c0                	test   %eax,%eax
f01021cf:	74 19                	je     f01021ea <mem_init+0xd59>
f01021d1:	68 88 73 10 f0       	push   $0xf0107388
f01021d6:	68 d4 77 10 f0       	push   $0xf01077d4
f01021db:	68 3a 04 00 00       	push   $0x43a
f01021e0:	68 91 77 10 f0       	push   $0xf0107791
f01021e5:	e8 56 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01021ea:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01021ef:	75 19                	jne    f010220a <mem_init+0xd79>
f01021f1:	68 3e 7a 10 f0       	push   $0xf0107a3e
f01021f6:	68 d4 77 10 f0       	push   $0xf01077d4
f01021fb:	68 3b 04 00 00       	push   $0x43b
f0102200:	68 91 77 10 f0       	push   $0xf0107791
f0102205:	e8 36 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f010220a:	83 3b 00             	cmpl   $0x0,(%ebx)
f010220d:	74 19                	je     f0102228 <mem_init+0xd97>
f010220f:	68 4a 7a 10 f0       	push   $0xf0107a4a
f0102214:	68 d4 77 10 f0       	push   $0xf01077d4
f0102219:	68 3c 04 00 00       	push   $0x43c
f010221e:	68 91 77 10 f0       	push   $0xf0107791
f0102223:	e8 18 de ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102228:	83 ec 08             	sub    $0x8,%esp
f010222b:	68 00 10 00 00       	push   $0x1000
f0102230:	ff 35 8c 6e 21 f0    	pushl  0xf0216e8c
f0102236:	e8 c1 f0 ff ff       	call   f01012fc <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010223b:	8b 3d 8c 6e 21 f0    	mov    0xf0216e8c,%edi
f0102241:	ba 00 00 00 00       	mov    $0x0,%edx
f0102246:	89 f8                	mov    %edi,%eax
f0102248:	e8 79 e8 ff ff       	call   f0100ac6 <check_va2pa>
f010224d:	83 c4 10             	add    $0x10,%esp
f0102250:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102253:	74 19                	je     f010226e <mem_init+0xddd>
f0102255:	68 64 73 10 f0       	push   $0xf0107364
f010225a:	68 d4 77 10 f0       	push   $0xf01077d4
f010225f:	68 40 04 00 00       	push   $0x440
f0102264:	68 91 77 10 f0       	push   $0xf0107791
f0102269:	e8 d2 dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010226e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102273:	89 f8                	mov    %edi,%eax
f0102275:	e8 4c e8 ff ff       	call   f0100ac6 <check_va2pa>
f010227a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010227d:	74 19                	je     f0102298 <mem_init+0xe07>
f010227f:	68 c0 73 10 f0       	push   $0xf01073c0
f0102284:	68 d4 77 10 f0       	push   $0xf01077d4
f0102289:	68 41 04 00 00       	push   $0x441
f010228e:	68 91 77 10 f0       	push   $0xf0107791
f0102293:	e8 a8 dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102298:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010229d:	74 19                	je     f01022b8 <mem_init+0xe27>
f010229f:	68 5f 7a 10 f0       	push   $0xf0107a5f
f01022a4:	68 d4 77 10 f0       	push   $0xf01077d4
f01022a9:	68 42 04 00 00       	push   $0x442
f01022ae:	68 91 77 10 f0       	push   $0xf0107791
f01022b3:	e8 88 dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01022b8:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01022bd:	74 19                	je     f01022d8 <mem_init+0xe47>
f01022bf:	68 2d 7a 10 f0       	push   $0xf0107a2d
f01022c4:	68 d4 77 10 f0       	push   $0xf01077d4
f01022c9:	68 43 04 00 00       	push   $0x443
f01022ce:	68 91 77 10 f0       	push   $0xf0107791
f01022d3:	e8 68 dd ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01022d8:	83 ec 0c             	sub    $0xc,%esp
f01022db:	6a 00                	push   $0x0
f01022dd:	e8 da ec ff ff       	call   f0100fbc <page_alloc>
f01022e2:	83 c4 10             	add    $0x10,%esp
f01022e5:	39 c3                	cmp    %eax,%ebx
f01022e7:	75 04                	jne    f01022ed <mem_init+0xe5c>
f01022e9:	85 c0                	test   %eax,%eax
f01022eb:	75 19                	jne    f0102306 <mem_init+0xe75>
f01022ed:	68 e8 73 10 f0       	push   $0xf01073e8
f01022f2:	68 d4 77 10 f0       	push   $0xf01077d4
f01022f7:	68 46 04 00 00       	push   $0x446
f01022fc:	68 91 77 10 f0       	push   $0xf0107791
f0102301:	e8 3a dd ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102306:	83 ec 0c             	sub    $0xc,%esp
f0102309:	6a 00                	push   $0x0
f010230b:	e8 ac ec ff ff       	call   f0100fbc <page_alloc>
f0102310:	83 c4 10             	add    $0x10,%esp
f0102313:	85 c0                	test   %eax,%eax
f0102315:	74 19                	je     f0102330 <mem_init+0xe9f>
f0102317:	68 81 79 10 f0       	push   $0xf0107981
f010231c:	68 d4 77 10 f0       	push   $0xf01077d4
f0102321:	68 49 04 00 00       	push   $0x449
f0102326:	68 91 77 10 f0       	push   $0xf0107791
f010232b:	e8 10 dd ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102330:	8b 0d 8c 6e 21 f0    	mov    0xf0216e8c,%ecx
f0102336:	8b 11                	mov    (%ecx),%edx
f0102338:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010233e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102341:	2b 05 90 6e 21 f0    	sub    0xf0216e90,%eax
f0102347:	c1 f8 03             	sar    $0x3,%eax
f010234a:	c1 e0 0c             	shl    $0xc,%eax
f010234d:	39 c2                	cmp    %eax,%edx
f010234f:	74 19                	je     f010236a <mem_init+0xed9>
f0102351:	68 8c 70 10 f0       	push   $0xf010708c
f0102356:	68 d4 77 10 f0       	push   $0xf01077d4
f010235b:	68 4c 04 00 00       	push   $0x44c
f0102360:	68 91 77 10 f0       	push   $0xf0107791
f0102365:	e8 d6 dc ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f010236a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102370:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102373:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102378:	74 19                	je     f0102393 <mem_init+0xf02>
f010237a:	68 e4 79 10 f0       	push   $0xf01079e4
f010237f:	68 d4 77 10 f0       	push   $0xf01077d4
f0102384:	68 4e 04 00 00       	push   $0x44e
f0102389:	68 91 77 10 f0       	push   $0xf0107791
f010238e:	e8 ad dc ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102393:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102396:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010239c:	83 ec 0c             	sub    $0xc,%esp
f010239f:	50                   	push   %eax
f01023a0:	e8 87 ec ff ff       	call   f010102c <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01023a5:	83 c4 0c             	add    $0xc,%esp
f01023a8:	6a 01                	push   $0x1
f01023aa:	68 00 10 40 00       	push   $0x401000
f01023af:	ff 35 8c 6e 21 f0    	pushl  0xf0216e8c
f01023b5:	e8 08 ed ff ff       	call   f01010c2 <pgdir_walk>
f01023ba:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01023bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01023c0:	8b 0d 8c 6e 21 f0    	mov    0xf0216e8c,%ecx
f01023c6:	8b 51 04             	mov    0x4(%ecx),%edx
f01023c9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01023cf:	8b 3d 88 6e 21 f0    	mov    0xf0216e88,%edi
f01023d5:	89 d0                	mov    %edx,%eax
f01023d7:	c1 e8 0c             	shr    $0xc,%eax
f01023da:	83 c4 10             	add    $0x10,%esp
f01023dd:	39 f8                	cmp    %edi,%eax
f01023df:	72 15                	jb     f01023f6 <mem_init+0xf65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023e1:	52                   	push   %edx
f01023e2:	68 c4 68 10 f0       	push   $0xf01068c4
f01023e7:	68 55 04 00 00       	push   $0x455
f01023ec:	68 91 77 10 f0       	push   $0xf0107791
f01023f1:	e8 4a dc ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01023f6:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01023fc:	39 55 c8             	cmp    %edx,-0x38(%ebp)
f01023ff:	74 19                	je     f010241a <mem_init+0xf89>
f0102401:	68 70 7a 10 f0       	push   $0xf0107a70
f0102406:	68 d4 77 10 f0       	push   $0xf01077d4
f010240b:	68 56 04 00 00       	push   $0x456
f0102410:	68 91 77 10 f0       	push   $0xf0107791
f0102415:	e8 26 dc ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f010241a:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0102421:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102424:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010242a:	2b 05 90 6e 21 f0    	sub    0xf0216e90,%eax
f0102430:	c1 f8 03             	sar    $0x3,%eax
f0102433:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102436:	89 c2                	mov    %eax,%edx
f0102438:	c1 ea 0c             	shr    $0xc,%edx
f010243b:	39 d7                	cmp    %edx,%edi
f010243d:	77 12                	ja     f0102451 <mem_init+0xfc0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010243f:	50                   	push   %eax
f0102440:	68 c4 68 10 f0       	push   $0xf01068c4
f0102445:	6a 58                	push   $0x58
f0102447:	68 ba 77 10 f0       	push   $0xf01077ba
f010244c:	e8 ef db ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102451:	83 ec 04             	sub    $0x4,%esp
f0102454:	68 00 10 00 00       	push   $0x1000
f0102459:	68 ff 00 00 00       	push   $0xff
f010245e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102463:	50                   	push   %eax
f0102464:	e8 76 37 00 00       	call   f0105bdf <memset>
	page_free(pp0);
f0102469:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010246c:	89 3c 24             	mov    %edi,(%esp)
f010246f:	e8 b8 eb ff ff       	call   f010102c <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102474:	83 c4 0c             	add    $0xc,%esp
f0102477:	6a 01                	push   $0x1
f0102479:	6a 00                	push   $0x0
f010247b:	ff 35 8c 6e 21 f0    	pushl  0xf0216e8c
f0102481:	e8 3c ec ff ff       	call   f01010c2 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102486:	89 fa                	mov    %edi,%edx
f0102488:	2b 15 90 6e 21 f0    	sub    0xf0216e90,%edx
f010248e:	c1 fa 03             	sar    $0x3,%edx
f0102491:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102494:	89 d0                	mov    %edx,%eax
f0102496:	c1 e8 0c             	shr    $0xc,%eax
f0102499:	83 c4 10             	add    $0x10,%esp
f010249c:	3b 05 88 6e 21 f0    	cmp    0xf0216e88,%eax
f01024a2:	72 12                	jb     f01024b6 <mem_init+0x1025>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024a4:	52                   	push   %edx
f01024a5:	68 c4 68 10 f0       	push   $0xf01068c4
f01024aa:	6a 58                	push   $0x58
f01024ac:	68 ba 77 10 f0       	push   $0xf01077ba
f01024b1:	e8 8a db ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01024b6:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01024bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01024bf:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01024c5:	f6 00 01             	testb  $0x1,(%eax)
f01024c8:	74 19                	je     f01024e3 <mem_init+0x1052>
f01024ca:	68 88 7a 10 f0       	push   $0xf0107a88
f01024cf:	68 d4 77 10 f0       	push   $0xf01077d4
f01024d4:	68 60 04 00 00       	push   $0x460
f01024d9:	68 91 77 10 f0       	push   $0xf0107791
f01024de:	e8 5d db ff ff       	call   f0100040 <_panic>
f01024e3:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01024e6:	39 d0                	cmp    %edx,%eax
f01024e8:	75 db                	jne    f01024c5 <mem_init+0x1034>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01024ea:	a1 8c 6e 21 f0       	mov    0xf0216e8c,%eax
f01024ef:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01024f5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024f8:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01024fe:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102501:	89 0d 40 62 21 f0    	mov    %ecx,0xf0216240

	// free the pages we took
	page_free(pp0);
f0102507:	83 ec 0c             	sub    $0xc,%esp
f010250a:	50                   	push   %eax
f010250b:	e8 1c eb ff ff       	call   f010102c <page_free>
	page_free(pp1);
f0102510:	89 1c 24             	mov    %ebx,(%esp)
f0102513:	e8 14 eb ff ff       	call   f010102c <page_free>
	page_free(pp2);
f0102518:	89 34 24             	mov    %esi,(%esp)
f010251b:	e8 0c eb ff ff       	call   f010102c <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102520:	83 c4 08             	add    $0x8,%esp
f0102523:	68 01 10 00 00       	push   $0x1001
f0102528:	6a 00                	push   $0x0
f010252a:	e8 02 ef ff ff       	call   f0101431 <mmio_map_region>
f010252f:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102531:	83 c4 08             	add    $0x8,%esp
f0102534:	68 00 10 00 00       	push   $0x1000
f0102539:	6a 00                	push   $0x0
f010253b:	e8 f1 ee ff ff       	call   f0101431 <mmio_map_region>
f0102540:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102542:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102548:	83 c4 10             	add    $0x10,%esp
f010254b:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102551:	76 07                	jbe    f010255a <mem_init+0x10c9>
f0102553:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102558:	76 19                	jbe    f0102573 <mem_init+0x10e2>
f010255a:	68 0c 74 10 f0       	push   $0xf010740c
f010255f:	68 d4 77 10 f0       	push   $0xf01077d4
f0102564:	68 70 04 00 00       	push   $0x470
f0102569:	68 91 77 10 f0       	push   $0xf0107791
f010256e:	e8 cd da ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102573:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102579:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f010257f:	77 08                	ja     f0102589 <mem_init+0x10f8>
f0102581:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102587:	77 19                	ja     f01025a2 <mem_init+0x1111>
f0102589:	68 34 74 10 f0       	push   $0xf0107434
f010258e:	68 d4 77 10 f0       	push   $0xf01077d4
f0102593:	68 71 04 00 00       	push   $0x471
f0102598:	68 91 77 10 f0       	push   $0xf0107791
f010259d:	e8 9e da ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01025a2:	89 da                	mov    %ebx,%edx
f01025a4:	09 f2                	or     %esi,%edx
f01025a6:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01025ac:	74 19                	je     f01025c7 <mem_init+0x1136>
f01025ae:	68 5c 74 10 f0       	push   $0xf010745c
f01025b3:	68 d4 77 10 f0       	push   $0xf01077d4
f01025b8:	68 73 04 00 00       	push   $0x473
f01025bd:	68 91 77 10 f0       	push   $0xf0107791
f01025c2:	e8 79 da ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f01025c7:	39 c6                	cmp    %eax,%esi
f01025c9:	73 19                	jae    f01025e4 <mem_init+0x1153>
f01025cb:	68 9f 7a 10 f0       	push   $0xf0107a9f
f01025d0:	68 d4 77 10 f0       	push   $0xf01077d4
f01025d5:	68 75 04 00 00       	push   $0x475
f01025da:	68 91 77 10 f0       	push   $0xf0107791
f01025df:	e8 5c da ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01025e4:	8b 3d 8c 6e 21 f0    	mov    0xf0216e8c,%edi
f01025ea:	89 da                	mov    %ebx,%edx
f01025ec:	89 f8                	mov    %edi,%eax
f01025ee:	e8 d3 e4 ff ff       	call   f0100ac6 <check_va2pa>
f01025f3:	85 c0                	test   %eax,%eax
f01025f5:	74 19                	je     f0102610 <mem_init+0x117f>
f01025f7:	68 84 74 10 f0       	push   $0xf0107484
f01025fc:	68 d4 77 10 f0       	push   $0xf01077d4
f0102601:	68 77 04 00 00       	push   $0x477
f0102606:	68 91 77 10 f0       	push   $0xf0107791
f010260b:	e8 30 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102610:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102616:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102619:	89 c2                	mov    %eax,%edx
f010261b:	89 f8                	mov    %edi,%eax
f010261d:	e8 a4 e4 ff ff       	call   f0100ac6 <check_va2pa>
f0102622:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102627:	74 19                	je     f0102642 <mem_init+0x11b1>
f0102629:	68 a8 74 10 f0       	push   $0xf01074a8
f010262e:	68 d4 77 10 f0       	push   $0xf01077d4
f0102633:	68 78 04 00 00       	push   $0x478
f0102638:	68 91 77 10 f0       	push   $0xf0107791
f010263d:	e8 fe d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102642:	89 f2                	mov    %esi,%edx
f0102644:	89 f8                	mov    %edi,%eax
f0102646:	e8 7b e4 ff ff       	call   f0100ac6 <check_va2pa>
f010264b:	85 c0                	test   %eax,%eax
f010264d:	74 19                	je     f0102668 <mem_init+0x11d7>
f010264f:	68 d8 74 10 f0       	push   $0xf01074d8
f0102654:	68 d4 77 10 f0       	push   $0xf01077d4
f0102659:	68 79 04 00 00       	push   $0x479
f010265e:	68 91 77 10 f0       	push   $0xf0107791
f0102663:	e8 d8 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102668:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f010266e:	89 f8                	mov    %edi,%eax
f0102670:	e8 51 e4 ff ff       	call   f0100ac6 <check_va2pa>
f0102675:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102678:	74 19                	je     f0102693 <mem_init+0x1202>
f010267a:	68 fc 74 10 f0       	push   $0xf01074fc
f010267f:	68 d4 77 10 f0       	push   $0xf01077d4
f0102684:	68 7a 04 00 00       	push   $0x47a
f0102689:	68 91 77 10 f0       	push   $0xf0107791
f010268e:	e8 ad d9 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102693:	83 ec 04             	sub    $0x4,%esp
f0102696:	6a 00                	push   $0x0
f0102698:	53                   	push   %ebx
f0102699:	57                   	push   %edi
f010269a:	e8 23 ea ff ff       	call   f01010c2 <pgdir_walk>
f010269f:	83 c4 10             	add    $0x10,%esp
f01026a2:	f6 00 1a             	testb  $0x1a,(%eax)
f01026a5:	75 19                	jne    f01026c0 <mem_init+0x122f>
f01026a7:	68 28 75 10 f0       	push   $0xf0107528
f01026ac:	68 d4 77 10 f0       	push   $0xf01077d4
f01026b1:	68 7c 04 00 00       	push   $0x47c
f01026b6:	68 91 77 10 f0       	push   $0xf0107791
f01026bb:	e8 80 d9 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01026c0:	83 ec 04             	sub    $0x4,%esp
f01026c3:	6a 00                	push   $0x0
f01026c5:	53                   	push   %ebx
f01026c6:	ff 35 8c 6e 21 f0    	pushl  0xf0216e8c
f01026cc:	e8 f1 e9 ff ff       	call   f01010c2 <pgdir_walk>
f01026d1:	8b 00                	mov    (%eax),%eax
f01026d3:	83 c4 10             	add    $0x10,%esp
f01026d6:	83 e0 04             	and    $0x4,%eax
f01026d9:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01026dc:	74 19                	je     f01026f7 <mem_init+0x1266>
f01026de:	68 6c 75 10 f0       	push   $0xf010756c
f01026e3:	68 d4 77 10 f0       	push   $0xf01077d4
f01026e8:	68 7d 04 00 00       	push   $0x47d
f01026ed:	68 91 77 10 f0       	push   $0xf0107791
f01026f2:	e8 49 d9 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f01026f7:	83 ec 04             	sub    $0x4,%esp
f01026fa:	6a 00                	push   $0x0
f01026fc:	53                   	push   %ebx
f01026fd:	ff 35 8c 6e 21 f0    	pushl  0xf0216e8c
f0102703:	e8 ba e9 ff ff       	call   f01010c2 <pgdir_walk>
f0102708:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f010270e:	83 c4 0c             	add    $0xc,%esp
f0102711:	6a 00                	push   $0x0
f0102713:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102716:	ff 35 8c 6e 21 f0    	pushl  0xf0216e8c
f010271c:	e8 a1 e9 ff ff       	call   f01010c2 <pgdir_walk>
f0102721:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102727:	83 c4 0c             	add    $0xc,%esp
f010272a:	6a 00                	push   $0x0
f010272c:	56                   	push   %esi
f010272d:	ff 35 8c 6e 21 f0    	pushl  0xf0216e8c
f0102733:	e8 8a e9 ff ff       	call   f01010c2 <pgdir_walk>
f0102738:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f010273e:	c7 04 24 b1 7a 10 f0 	movl   $0xf0107ab1,(%esp)
f0102745:	e8 d6 13 00 00       	call   f0103b20 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
        boot_map_region(kern_pgdir, UPAGES, ROUNDUP(pages_size, PGSIZE), PADDR(pages), PTE_U); 
f010274a:	a1 90 6e 21 f0       	mov    0xf0216e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010274f:	83 c4 10             	add    $0x10,%esp
f0102752:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102757:	77 15                	ja     f010276e <mem_init+0x12dd>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102759:	50                   	push   %eax
f010275a:	68 e8 68 10 f0       	push   $0xf01068e8
f010275f:	68 c9 00 00 00       	push   $0xc9
f0102764:	68 91 77 10 f0       	push   $0xf0107791
f0102769:	e8 d2 d8 ff ff       	call   f0100040 <_panic>
f010276e:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0102771:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f0102777:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f010277d:	83 ec 08             	sub    $0x8,%esp
f0102780:	6a 04                	push   $0x4
f0102782:	05 00 00 00 10       	add    $0x10000000,%eax
f0102787:	50                   	push   %eax
f0102788:	89 d9                	mov    %ebx,%ecx
f010278a:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010278f:	a1 8c 6e 21 f0       	mov    0xf0216e8c,%eax
f0102794:	e8 11 ea ff ff       	call   f01011aa <boot_map_region>
        boot_map_region(kern_pgdir, (uintptr_t) pages, ROUNDUP(pages_size, PGSIZE), PADDR(pages), PTE_W);
f0102799:	8b 15 90 6e 21 f0    	mov    0xf0216e90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010279f:	83 c4 10             	add    $0x10,%esp
f01027a2:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01027a8:	77 15                	ja     f01027bf <mem_init+0x132e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027aa:	52                   	push   %edx
f01027ab:	68 e8 68 10 f0       	push   $0xf01068e8
f01027b0:	68 ca 00 00 00       	push   $0xca
f01027b5:	68 91 77 10 f0       	push   $0xf0107791
f01027ba:	e8 81 d8 ff ff       	call   f0100040 <_panic>
f01027bf:	83 ec 08             	sub    $0x8,%esp
f01027c2:	6a 02                	push   $0x2
f01027c4:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
f01027ca:	50                   	push   %eax
f01027cb:	89 d9                	mov    %ebx,%ecx
f01027cd:	a1 8c 6e 21 f0       	mov    0xf0216e8c,%eax
f01027d2:	e8 d3 e9 ff ff       	call   f01011aa <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
        boot_map_region(kern_pgdir, UENVS, ROUNDUP(envs_size, PGSIZE), PADDR(envs), PTE_U);
f01027d7:	a1 4c 62 21 f0       	mov    0xf021624c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027dc:	83 c4 10             	add    $0x10,%esp
f01027df:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01027e4:	77 15                	ja     f01027fb <mem_init+0x136a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027e6:	50                   	push   %eax
f01027e7:	68 e8 68 10 f0       	push   $0xf01068e8
f01027ec:	68 d3 00 00 00       	push   $0xd3
f01027f1:	68 91 77 10 f0       	push   $0xf0107791
f01027f6:	e8 45 d8 ff ff       	call   f0100040 <_panic>
f01027fb:	83 ec 08             	sub    $0x8,%esp
f01027fe:	6a 04                	push   $0x4
f0102800:	05 00 00 00 10       	add    $0x10000000,%eax
f0102805:	50                   	push   %eax
f0102806:	b9 00 20 02 00       	mov    $0x22000,%ecx
f010280b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102810:	a1 8c 6e 21 f0       	mov    0xf0216e8c,%eax
f0102815:	e8 90 e9 ff ff       	call   f01011aa <boot_map_region>
        boot_map_region(kern_pgdir, (uintptr_t) envs, ROUNDUP(envs_size, PGSIZE), PADDR(pages), PTE_W);
f010281a:	a1 90 6e 21 f0       	mov    0xf0216e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010281f:	83 c4 10             	add    $0x10,%esp
f0102822:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102827:	77 15                	ja     f010283e <mem_init+0x13ad>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102829:	50                   	push   %eax
f010282a:	68 e8 68 10 f0       	push   $0xf01068e8
f010282f:	68 d4 00 00 00       	push   $0xd4
f0102834:	68 91 77 10 f0       	push   $0xf0107791
f0102839:	e8 02 d8 ff ff       	call   f0100040 <_panic>
f010283e:	83 ec 08             	sub    $0x8,%esp
f0102841:	6a 02                	push   $0x2
f0102843:	05 00 00 00 10       	add    $0x10000000,%eax
f0102848:	50                   	push   %eax
f0102849:	b9 00 20 02 00       	mov    $0x22000,%ecx
f010284e:	8b 15 4c 62 21 f0    	mov    0xf021624c,%edx
f0102854:	a1 8c 6e 21 f0       	mov    0xf0216e8c,%eax
f0102859:	e8 4c e9 ff ff       	call   f01011aa <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010285e:	83 c4 10             	add    $0x10,%esp
f0102861:	b8 00 70 11 f0       	mov    $0xf0117000,%eax
f0102866:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010286b:	77 15                	ja     f0102882 <mem_init+0x13f1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010286d:	50                   	push   %eax
f010286e:	68 e8 68 10 f0       	push   $0xf01068e8
f0102873:	68 e1 00 00 00       	push   $0xe1
f0102878:	68 91 77 10 f0       	push   $0xf0107791
f010287d:	e8 be d7 ff ff       	call   f0100040 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
        boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102882:	83 ec 08             	sub    $0x8,%esp
f0102885:	6a 02                	push   $0x2
f0102887:	68 00 70 11 00       	push   $0x117000
f010288c:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102891:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102896:	a1 8c 6e 21 f0       	mov    0xf0216e8c,%eax
f010289b:	e8 0a e9 ff ff       	call   f01011aa <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
        boot_map_region(kern_pgdir, KERNBASE, -KERNBASE, 0, PTE_W);
f01028a0:	83 c4 08             	add    $0x8,%esp
f01028a3:	6a 02                	push   $0x2
f01028a5:	6a 00                	push   $0x0
f01028a7:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01028ac:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01028b1:	a1 8c 6e 21 f0       	mov    0xf0216e8c,%eax
f01028b6:	e8 ef e8 ff ff       	call   f01011aa <boot_map_region>
f01028bb:	c7 45 c4 00 80 21 f0 	movl   $0xf0218000,-0x3c(%ebp)
f01028c2:	83 c4 10             	add    $0x10,%esp
f01028c5:	bb 00 80 21 f0       	mov    $0xf0218000,%ebx
f01028ca:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01028cf:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01028d5:	77 15                	ja     f01028ec <mem_init+0x145b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028d7:	53                   	push   %ebx
f01028d8:	68 e8 68 10 f0       	push   $0xf01068e8
f01028dd:	68 22 01 00 00       	push   $0x122
f01028e2:	68 91 77 10 f0       	push   $0xf0107791
f01028e7:	e8 54 d7 ff ff       	call   f0100040 <_panic>
	//
	// LAB 4: Your code here:
        size_t i;
        for (i = 0; i < NCPU; i++) {
                uintptr_t kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
                boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W);
f01028ec:	83 ec 08             	sub    $0x8,%esp
f01028ef:	6a 02                	push   $0x2
f01028f1:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f01028f7:	50                   	push   %eax
f01028f8:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01028fd:	89 f2                	mov    %esi,%edx
f01028ff:	a1 8c 6e 21 f0       	mov    0xf0216e8c,%eax
f0102904:	e8 a1 e8 ff ff       	call   f01011aa <boot_map_region>
f0102909:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f010290f:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
        size_t i;
        for (i = 0; i < NCPU; i++) {
f0102915:	83 c4 10             	add    $0x10,%esp
f0102918:	b8 00 80 25 f0       	mov    $0xf0258000,%eax
f010291d:	39 d8                	cmp    %ebx,%eax
f010291f:	75 ae                	jne    f01028cf <mem_init+0x143e>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102921:	8b 3d 8c 6e 21 f0    	mov    0xf0216e8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102927:	a1 88 6e 21 f0       	mov    0xf0216e88,%eax
f010292c:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010292f:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102936:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010293b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010293e:	8b 35 90 6e 21 f0    	mov    0xf0216e90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102944:	89 75 d0             	mov    %esi,-0x30(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102947:	bb 00 00 00 00       	mov    $0x0,%ebx
f010294c:	eb 55                	jmp    f01029a3 <mem_init+0x1512>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010294e:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102954:	89 f8                	mov    %edi,%eax
f0102956:	e8 6b e1 ff ff       	call   f0100ac6 <check_va2pa>
f010295b:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102962:	77 15                	ja     f0102979 <mem_init+0x14e8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102964:	56                   	push   %esi
f0102965:	68 e8 68 10 f0       	push   $0xf01068e8
f010296a:	68 94 03 00 00       	push   $0x394
f010296f:	68 91 77 10 f0       	push   $0xf0107791
f0102974:	e8 c7 d6 ff ff       	call   f0100040 <_panic>
f0102979:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f0102980:	39 c2                	cmp    %eax,%edx
f0102982:	74 19                	je     f010299d <mem_init+0x150c>
f0102984:	68 a0 75 10 f0       	push   $0xf01075a0
f0102989:	68 d4 77 10 f0       	push   $0xf01077d4
f010298e:	68 94 03 00 00       	push   $0x394
f0102993:	68 91 77 10 f0       	push   $0xf0107791
f0102998:	e8 a3 d6 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010299d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01029a3:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01029a6:	77 a6                	ja     f010294e <mem_init+0x14bd>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01029a8:	8b 35 4c 62 21 f0    	mov    0xf021624c,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01029ae:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01029b1:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f01029b6:	89 da                	mov    %ebx,%edx
f01029b8:	89 f8                	mov    %edi,%eax
f01029ba:	e8 07 e1 ff ff       	call   f0100ac6 <check_va2pa>
f01029bf:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f01029c6:	77 15                	ja     f01029dd <mem_init+0x154c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029c8:	56                   	push   %esi
f01029c9:	68 e8 68 10 f0       	push   $0xf01068e8
f01029ce:	68 99 03 00 00       	push   $0x399
f01029d3:	68 91 77 10 f0       	push   $0xf0107791
f01029d8:	e8 63 d6 ff ff       	call   f0100040 <_panic>
f01029dd:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f01029e4:	39 d0                	cmp    %edx,%eax
f01029e6:	74 19                	je     f0102a01 <mem_init+0x1570>
f01029e8:	68 d4 75 10 f0       	push   $0xf01075d4
f01029ed:	68 d4 77 10 f0       	push   $0xf01077d4
f01029f2:	68 99 03 00 00       	push   $0x399
f01029f7:	68 91 77 10 f0       	push   $0xf0107791
f01029fc:	e8 3f d6 ff ff       	call   f0100040 <_panic>
f0102a01:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102a07:	81 fb 00 20 c2 ee    	cmp    $0xeec22000,%ebx
f0102a0d:	75 a7                	jne    f01029b6 <mem_init+0x1525>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102a0f:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102a12:	c1 e6 0c             	shl    $0xc,%esi
f0102a15:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102a1a:	eb 30                	jmp    f0102a4c <mem_init+0x15bb>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102a1c:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102a22:	89 f8                	mov    %edi,%eax
f0102a24:	e8 9d e0 ff ff       	call   f0100ac6 <check_va2pa>
f0102a29:	39 c3                	cmp    %eax,%ebx
f0102a2b:	74 19                	je     f0102a46 <mem_init+0x15b5>
f0102a2d:	68 08 76 10 f0       	push   $0xf0107608
f0102a32:	68 d4 77 10 f0       	push   $0xf01077d4
f0102a37:	68 9d 03 00 00       	push   $0x39d
f0102a3c:	68 91 77 10 f0       	push   $0xf0107791
f0102a41:	e8 fa d5 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102a46:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102a4c:	39 f3                	cmp    %esi,%ebx
f0102a4e:	72 cc                	jb     f0102a1c <mem_init+0x158b>
f0102a50:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102a55:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0102a58:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102a5b:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102a5e:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f0102a64:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102a67:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102a69:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102a6c:	05 00 80 00 20       	add    $0x20008000,%eax
f0102a71:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102a74:	89 da                	mov    %ebx,%edx
f0102a76:	89 f8                	mov    %edi,%eax
f0102a78:	e8 49 e0 ff ff       	call   f0100ac6 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a7d:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102a83:	77 15                	ja     f0102a9a <mem_init+0x1609>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a85:	56                   	push   %esi
f0102a86:	68 e8 68 10 f0       	push   $0xf01068e8
f0102a8b:	68 a5 03 00 00       	push   $0x3a5
f0102a90:	68 91 77 10 f0       	push   $0xf0107791
f0102a95:	e8 a6 d5 ff ff       	call   f0100040 <_panic>
f0102a9a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102a9d:	8d 94 0b 00 80 21 f0 	lea    -0xfde8000(%ebx,%ecx,1),%edx
f0102aa4:	39 d0                	cmp    %edx,%eax
f0102aa6:	74 19                	je     f0102ac1 <mem_init+0x1630>
f0102aa8:	68 30 76 10 f0       	push   $0xf0107630
f0102aad:	68 d4 77 10 f0       	push   $0xf01077d4
f0102ab2:	68 a5 03 00 00       	push   $0x3a5
f0102ab7:	68 91 77 10 f0       	push   $0xf0107791
f0102abc:	e8 7f d5 ff ff       	call   f0100040 <_panic>
f0102ac1:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102ac7:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f0102aca:	75 a8                	jne    f0102a74 <mem_init+0x15e3>
f0102acc:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102acf:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f0102ad5:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102ad8:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102ada:	89 da                	mov    %ebx,%edx
f0102adc:	89 f8                	mov    %edi,%eax
f0102ade:	e8 e3 df ff ff       	call   f0100ac6 <check_va2pa>
f0102ae3:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102ae6:	74 19                	je     f0102b01 <mem_init+0x1670>
f0102ae8:	68 78 76 10 f0       	push   $0xf0107678
f0102aed:	68 d4 77 10 f0       	push   $0xf01077d4
f0102af2:	68 a7 03 00 00       	push   $0x3a7
f0102af7:	68 91 77 10 f0       	push   $0xf0107791
f0102afc:	e8 3f d5 ff ff       	call   f0100040 <_panic>
f0102b01:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102b07:	39 f3                	cmp    %esi,%ebx
f0102b09:	75 cf                	jne    f0102ada <mem_init+0x1649>
f0102b0b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102b0e:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f0102b15:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f0102b1c:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102b22:	b8 00 80 25 f0       	mov    $0xf0258000,%eax
f0102b27:	39 f0                	cmp    %esi,%eax
f0102b29:	0f 85 2c ff ff ff    	jne    f0102a5b <mem_init+0x15ca>
f0102b2f:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b34:	eb 2a                	jmp    f0102b60 <mem_init+0x16cf>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102b36:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102b3c:	83 fa 04             	cmp    $0x4,%edx
f0102b3f:	77 1f                	ja     f0102b60 <mem_init+0x16cf>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102b41:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102b45:	75 7e                	jne    f0102bc5 <mem_init+0x1734>
f0102b47:	68 ca 7a 10 f0       	push   $0xf0107aca
f0102b4c:	68 d4 77 10 f0       	push   $0xf01077d4
f0102b51:	68 b2 03 00 00       	push   $0x3b2
f0102b56:	68 91 77 10 f0       	push   $0xf0107791
f0102b5b:	e8 e0 d4 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102b60:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102b65:	76 3f                	jbe    f0102ba6 <mem_init+0x1715>
				assert(pgdir[i] & PTE_P);
f0102b67:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102b6a:	f6 c2 01             	test   $0x1,%dl
f0102b6d:	75 19                	jne    f0102b88 <mem_init+0x16f7>
f0102b6f:	68 ca 7a 10 f0       	push   $0xf0107aca
f0102b74:	68 d4 77 10 f0       	push   $0xf01077d4
f0102b79:	68 b6 03 00 00       	push   $0x3b6
f0102b7e:	68 91 77 10 f0       	push   $0xf0107791
f0102b83:	e8 b8 d4 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102b88:	f6 c2 02             	test   $0x2,%dl
f0102b8b:	75 38                	jne    f0102bc5 <mem_init+0x1734>
f0102b8d:	68 db 7a 10 f0       	push   $0xf0107adb
f0102b92:	68 d4 77 10 f0       	push   $0xf01077d4
f0102b97:	68 b7 03 00 00       	push   $0x3b7
f0102b9c:	68 91 77 10 f0       	push   $0xf0107791
f0102ba1:	e8 9a d4 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102ba6:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102baa:	74 19                	je     f0102bc5 <mem_init+0x1734>
f0102bac:	68 ec 7a 10 f0       	push   $0xf0107aec
f0102bb1:	68 d4 77 10 f0       	push   $0xf01077d4
f0102bb6:	68 b9 03 00 00       	push   $0x3b9
f0102bbb:	68 91 77 10 f0       	push   $0xf0107791
f0102bc0:	e8 7b d4 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102bc5:	83 c0 01             	add    $0x1,%eax
f0102bc8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102bcd:	0f 86 63 ff ff ff    	jbe    f0102b36 <mem_init+0x16a5>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102bd3:	83 ec 0c             	sub    $0xc,%esp
f0102bd6:	68 9c 76 10 f0       	push   $0xf010769c
f0102bdb:	e8 40 0f 00 00       	call   f0103b20 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102be0:	a1 8c 6e 21 f0       	mov    0xf0216e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102be5:	83 c4 10             	add    $0x10,%esp
f0102be8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102bed:	77 15                	ja     f0102c04 <mem_init+0x1773>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102bef:	50                   	push   %eax
f0102bf0:	68 e8 68 10 f0       	push   $0xf01068e8
f0102bf5:	68 fa 00 00 00       	push   $0xfa
f0102bfa:	68 91 77 10 f0       	push   $0xf0107791
f0102bff:	e8 3c d4 ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102c04:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c09:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102c0c:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c11:	e8 ae df ff ff       	call   f0100bc4 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102c16:	0f 20 c0             	mov    %cr0,%eax
f0102c19:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102c1c:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102c21:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102c24:	83 ec 0c             	sub    $0xc,%esp
f0102c27:	6a 00                	push   $0x0
f0102c29:	e8 8e e3 ff ff       	call   f0100fbc <page_alloc>
f0102c2e:	89 c3                	mov    %eax,%ebx
f0102c30:	83 c4 10             	add    $0x10,%esp
f0102c33:	85 c0                	test   %eax,%eax
f0102c35:	75 19                	jne    f0102c50 <mem_init+0x17bf>
f0102c37:	68 d6 78 10 f0       	push   $0xf01078d6
f0102c3c:	68 d4 77 10 f0       	push   $0xf01077d4
f0102c41:	68 92 04 00 00       	push   $0x492
f0102c46:	68 91 77 10 f0       	push   $0xf0107791
f0102c4b:	e8 f0 d3 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102c50:	83 ec 0c             	sub    $0xc,%esp
f0102c53:	6a 00                	push   $0x0
f0102c55:	e8 62 e3 ff ff       	call   f0100fbc <page_alloc>
f0102c5a:	89 c7                	mov    %eax,%edi
f0102c5c:	83 c4 10             	add    $0x10,%esp
f0102c5f:	85 c0                	test   %eax,%eax
f0102c61:	75 19                	jne    f0102c7c <mem_init+0x17eb>
f0102c63:	68 ec 78 10 f0       	push   $0xf01078ec
f0102c68:	68 d4 77 10 f0       	push   $0xf01077d4
f0102c6d:	68 93 04 00 00       	push   $0x493
f0102c72:	68 91 77 10 f0       	push   $0xf0107791
f0102c77:	e8 c4 d3 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102c7c:	83 ec 0c             	sub    $0xc,%esp
f0102c7f:	6a 00                	push   $0x0
f0102c81:	e8 36 e3 ff ff       	call   f0100fbc <page_alloc>
f0102c86:	89 c6                	mov    %eax,%esi
f0102c88:	83 c4 10             	add    $0x10,%esp
f0102c8b:	85 c0                	test   %eax,%eax
f0102c8d:	75 19                	jne    f0102ca8 <mem_init+0x1817>
f0102c8f:	68 02 79 10 f0       	push   $0xf0107902
f0102c94:	68 d4 77 10 f0       	push   $0xf01077d4
f0102c99:	68 94 04 00 00       	push   $0x494
f0102c9e:	68 91 77 10 f0       	push   $0xf0107791
f0102ca3:	e8 98 d3 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102ca8:	83 ec 0c             	sub    $0xc,%esp
f0102cab:	53                   	push   %ebx
f0102cac:	e8 7b e3 ff ff       	call   f010102c <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102cb1:	89 f8                	mov    %edi,%eax
f0102cb3:	2b 05 90 6e 21 f0    	sub    0xf0216e90,%eax
f0102cb9:	c1 f8 03             	sar    $0x3,%eax
f0102cbc:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102cbf:	89 c2                	mov    %eax,%edx
f0102cc1:	c1 ea 0c             	shr    $0xc,%edx
f0102cc4:	83 c4 10             	add    $0x10,%esp
f0102cc7:	3b 15 88 6e 21 f0    	cmp    0xf0216e88,%edx
f0102ccd:	72 12                	jb     f0102ce1 <mem_init+0x1850>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ccf:	50                   	push   %eax
f0102cd0:	68 c4 68 10 f0       	push   $0xf01068c4
f0102cd5:	6a 58                	push   $0x58
f0102cd7:	68 ba 77 10 f0       	push   $0xf01077ba
f0102cdc:	e8 5f d3 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102ce1:	83 ec 04             	sub    $0x4,%esp
f0102ce4:	68 00 10 00 00       	push   $0x1000
f0102ce9:	6a 01                	push   $0x1
f0102ceb:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102cf0:	50                   	push   %eax
f0102cf1:	e8 e9 2e 00 00       	call   f0105bdf <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102cf6:	89 f0                	mov    %esi,%eax
f0102cf8:	2b 05 90 6e 21 f0    	sub    0xf0216e90,%eax
f0102cfe:	c1 f8 03             	sar    $0x3,%eax
f0102d01:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d04:	89 c2                	mov    %eax,%edx
f0102d06:	c1 ea 0c             	shr    $0xc,%edx
f0102d09:	83 c4 10             	add    $0x10,%esp
f0102d0c:	3b 15 88 6e 21 f0    	cmp    0xf0216e88,%edx
f0102d12:	72 12                	jb     f0102d26 <mem_init+0x1895>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d14:	50                   	push   %eax
f0102d15:	68 c4 68 10 f0       	push   $0xf01068c4
f0102d1a:	6a 58                	push   $0x58
f0102d1c:	68 ba 77 10 f0       	push   $0xf01077ba
f0102d21:	e8 1a d3 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102d26:	83 ec 04             	sub    $0x4,%esp
f0102d29:	68 00 10 00 00       	push   $0x1000
f0102d2e:	6a 02                	push   $0x2
f0102d30:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102d35:	50                   	push   %eax
f0102d36:	e8 a4 2e 00 00       	call   f0105bdf <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102d3b:	6a 02                	push   $0x2
f0102d3d:	68 00 10 00 00       	push   $0x1000
f0102d42:	57                   	push   %edi
f0102d43:	ff 35 8c 6e 21 f0    	pushl  0xf0216e8c
f0102d49:	e8 1c e6 ff ff       	call   f010136a <page_insert>
	assert(pp1->pp_ref == 1);
f0102d4e:	83 c4 20             	add    $0x20,%esp
f0102d51:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102d56:	74 19                	je     f0102d71 <mem_init+0x18e0>
f0102d58:	68 d3 79 10 f0       	push   $0xf01079d3
f0102d5d:	68 d4 77 10 f0       	push   $0xf01077d4
f0102d62:	68 99 04 00 00       	push   $0x499
f0102d67:	68 91 77 10 f0       	push   $0xf0107791
f0102d6c:	e8 cf d2 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102d71:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102d78:	01 01 01 
f0102d7b:	74 19                	je     f0102d96 <mem_init+0x1905>
f0102d7d:	68 bc 76 10 f0       	push   $0xf01076bc
f0102d82:	68 d4 77 10 f0       	push   $0xf01077d4
f0102d87:	68 9a 04 00 00       	push   $0x49a
f0102d8c:	68 91 77 10 f0       	push   $0xf0107791
f0102d91:	e8 aa d2 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102d96:	6a 02                	push   $0x2
f0102d98:	68 00 10 00 00       	push   $0x1000
f0102d9d:	56                   	push   %esi
f0102d9e:	ff 35 8c 6e 21 f0    	pushl  0xf0216e8c
f0102da4:	e8 c1 e5 ff ff       	call   f010136a <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102da9:	83 c4 10             	add    $0x10,%esp
f0102dac:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102db3:	02 02 02 
f0102db6:	74 19                	je     f0102dd1 <mem_init+0x1940>
f0102db8:	68 e0 76 10 f0       	push   $0xf01076e0
f0102dbd:	68 d4 77 10 f0       	push   $0xf01077d4
f0102dc2:	68 9c 04 00 00       	push   $0x49c
f0102dc7:	68 91 77 10 f0       	push   $0xf0107791
f0102dcc:	e8 6f d2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102dd1:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102dd6:	74 19                	je     f0102df1 <mem_init+0x1960>
f0102dd8:	68 f5 79 10 f0       	push   $0xf01079f5
f0102ddd:	68 d4 77 10 f0       	push   $0xf01077d4
f0102de2:	68 9d 04 00 00       	push   $0x49d
f0102de7:	68 91 77 10 f0       	push   $0xf0107791
f0102dec:	e8 4f d2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102df1:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102df6:	74 19                	je     f0102e11 <mem_init+0x1980>
f0102df8:	68 5f 7a 10 f0       	push   $0xf0107a5f
f0102dfd:	68 d4 77 10 f0       	push   $0xf01077d4
f0102e02:	68 9e 04 00 00       	push   $0x49e
f0102e07:	68 91 77 10 f0       	push   $0xf0107791
f0102e0c:	e8 2f d2 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102e11:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102e18:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102e1b:	89 f0                	mov    %esi,%eax
f0102e1d:	2b 05 90 6e 21 f0    	sub    0xf0216e90,%eax
f0102e23:	c1 f8 03             	sar    $0x3,%eax
f0102e26:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e29:	89 c2                	mov    %eax,%edx
f0102e2b:	c1 ea 0c             	shr    $0xc,%edx
f0102e2e:	3b 15 88 6e 21 f0    	cmp    0xf0216e88,%edx
f0102e34:	72 12                	jb     f0102e48 <mem_init+0x19b7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e36:	50                   	push   %eax
f0102e37:	68 c4 68 10 f0       	push   $0xf01068c4
f0102e3c:	6a 58                	push   $0x58
f0102e3e:	68 ba 77 10 f0       	push   $0xf01077ba
f0102e43:	e8 f8 d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e48:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102e4f:	03 03 03 
f0102e52:	74 19                	je     f0102e6d <mem_init+0x19dc>
f0102e54:	68 04 77 10 f0       	push   $0xf0107704
f0102e59:	68 d4 77 10 f0       	push   $0xf01077d4
f0102e5e:	68 a0 04 00 00       	push   $0x4a0
f0102e63:	68 91 77 10 f0       	push   $0xf0107791
f0102e68:	e8 d3 d1 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102e6d:	83 ec 08             	sub    $0x8,%esp
f0102e70:	68 00 10 00 00       	push   $0x1000
f0102e75:	ff 35 8c 6e 21 f0    	pushl  0xf0216e8c
f0102e7b:	e8 7c e4 ff ff       	call   f01012fc <page_remove>
	assert(pp2->pp_ref == 0);
f0102e80:	83 c4 10             	add    $0x10,%esp
f0102e83:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102e88:	74 19                	je     f0102ea3 <mem_init+0x1a12>
f0102e8a:	68 2d 7a 10 f0       	push   $0xf0107a2d
f0102e8f:	68 d4 77 10 f0       	push   $0xf01077d4
f0102e94:	68 a2 04 00 00       	push   $0x4a2
f0102e99:	68 91 77 10 f0       	push   $0xf0107791
f0102e9e:	e8 9d d1 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102ea3:	8b 0d 8c 6e 21 f0    	mov    0xf0216e8c,%ecx
f0102ea9:	8b 11                	mov    (%ecx),%edx
f0102eab:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102eb1:	89 d8                	mov    %ebx,%eax
f0102eb3:	2b 05 90 6e 21 f0    	sub    0xf0216e90,%eax
f0102eb9:	c1 f8 03             	sar    $0x3,%eax
f0102ebc:	c1 e0 0c             	shl    $0xc,%eax
f0102ebf:	39 c2                	cmp    %eax,%edx
f0102ec1:	74 19                	je     f0102edc <mem_init+0x1a4b>
f0102ec3:	68 8c 70 10 f0       	push   $0xf010708c
f0102ec8:	68 d4 77 10 f0       	push   $0xf01077d4
f0102ecd:	68 a5 04 00 00       	push   $0x4a5
f0102ed2:	68 91 77 10 f0       	push   $0xf0107791
f0102ed7:	e8 64 d1 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102edc:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102ee2:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102ee7:	74 19                	je     f0102f02 <mem_init+0x1a71>
f0102ee9:	68 e4 79 10 f0       	push   $0xf01079e4
f0102eee:	68 d4 77 10 f0       	push   $0xf01077d4
f0102ef3:	68 a7 04 00 00       	push   $0x4a7
f0102ef8:	68 91 77 10 f0       	push   $0xf0107791
f0102efd:	e8 3e d1 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102f02:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102f08:	83 ec 0c             	sub    $0xc,%esp
f0102f0b:	53                   	push   %ebx
f0102f0c:	e8 1b e1 ff ff       	call   f010102c <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102f11:	c7 04 24 30 77 10 f0 	movl   $0xf0107730,(%esp)
f0102f18:	e8 03 0c 00 00       	call   f0103b20 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102f1d:	83 c4 10             	add    $0x10,%esp
f0102f20:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f23:	5b                   	pop    %ebx
f0102f24:	5e                   	pop    %esi
f0102f25:	5f                   	pop    %edi
f0102f26:	5d                   	pop    %ebp
f0102f27:	c3                   	ret    

f0102f28 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102f28:	55                   	push   %ebp
f0102f29:	89 e5                	mov    %esp,%ebp
f0102f2b:	57                   	push   %edi
f0102f2c:	56                   	push   %esi
f0102f2d:	53                   	push   %ebx
f0102f2e:	83 ec 1c             	sub    $0x1c,%esp
f0102f31:	8b 7d 08             	mov    0x8(%ebp),%edi
        uintptr_t start_va = ROUNDDOWN((uintptr_t) va, PGSIZE);
f0102f34:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f37:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102f3c:	89 c1                	mov    %eax,%ecx
f0102f3e:	89 45 e0             	mov    %eax,-0x20(%ebp)
        uintptr_t end_va = start_va + ROUNDUP(len, PGSIZE);        
f0102f41:	8b 45 10             	mov    0x10(%ebp),%eax
f0102f44:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102f49:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102f4e:	8d 04 08             	lea    (%eax,%ecx,1),%eax
f0102f51:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
        uintptr_t start_va = ROUNDDOWN((uintptr_t) va, PGSIZE);
f0102f54:	89 cb                	mov    %ecx,%ebx
                        goto user_mem_check_fault;

                if (start_va >= ULIM)
                        goto user_mem_check_fault;

                if ((*pte & (perm | PTE_P)) != (perm | PTE_P))
f0102f56:	8b 75 14             	mov    0x14(%ebp),%esi
f0102f59:	83 ce 01             	or     $0x1,%esi
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
        uintptr_t start_va = ROUNDDOWN((uintptr_t) va, PGSIZE);
        uintptr_t end_va = start_va + ROUNDUP(len, PGSIZE);        

        while (start_va < end_va) {
f0102f5c:	eb 2b                	jmp    f0102f89 <user_mem_check+0x61>
                pte_t *pte = pgdir_walk(env->env_pgdir, (void *) start_va, 0);
f0102f5e:	83 ec 04             	sub    $0x4,%esp
f0102f61:	6a 00                	push   $0x0
f0102f63:	53                   	push   %ebx
f0102f64:	ff 77 6c             	pushl  0x6c(%edi)
f0102f67:	e8 56 e1 ff ff       	call   f01010c2 <pgdir_walk>
                // No entry for this va in the page table, so no, the env
                // can't access it
                if (pte == NULL)
                        goto user_mem_check_fault;

                if (start_va >= ULIM)
f0102f6c:	83 c4 10             	add    $0x10,%esp
f0102f6f:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102f75:	77 1e                	ja     f0102f95 <user_mem_check+0x6d>
f0102f77:	85 c0                	test   %eax,%eax
f0102f79:	74 1a                	je     f0102f95 <user_mem_check+0x6d>
                        goto user_mem_check_fault;

                if ((*pte & (perm | PTE_P)) != (perm | PTE_P))
f0102f7b:	89 f2                	mov    %esi,%edx
f0102f7d:	23 10                	and    (%eax),%edx
f0102f7f:	39 d6                	cmp    %edx,%esi
f0102f81:	75 12                	jne    f0102f95 <user_mem_check+0x6d>
                        goto user_mem_check_fault;

                start_va += PGSIZE;
f0102f83:	81 c3 00 10 00 00    	add    $0x1000,%ebx
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
        uintptr_t start_va = ROUNDDOWN((uintptr_t) va, PGSIZE);
        uintptr_t end_va = start_va + ROUNDUP(len, PGSIZE);        

        while (start_va < end_va) {
f0102f89:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102f8c:	72 d0                	jb     f0102f5e <user_mem_check+0x36>
                        goto user_mem_check_fault;

                start_va += PGSIZE;
        }

	return 0;
f0102f8e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f93:	eb 12                	jmp    f0102fa7 <user_mem_check+0x7f>
        //              [00001000] user_mem_check assertion failure for va 00000001
        //      2) make run-buggyhello2:
        //              [00001000] user_mem_check assertion failure for va 00803000
        //
        //              Note: the actual check here is for 00.0.000
        user_mem_check_addr = start_va == ROUNDDOWN((uintptr_t) va, PGSIZE) ? (uintptr_t) va : start_va;        
f0102f95:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f0102f98:	0f 44 5d 0c          	cmove  0xc(%ebp),%ebx
f0102f9c:	89 1d 3c 62 21 f0    	mov    %ebx,0xf021623c
        return -E_FAULT;
f0102fa2:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f0102fa7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102faa:	5b                   	pop    %ebx
f0102fab:	5e                   	pop    %esi
f0102fac:	5f                   	pop    %edi
f0102fad:	5d                   	pop    %ebp
f0102fae:	c3                   	ret    

f0102faf <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102faf:	55                   	push   %ebp
f0102fb0:	89 e5                	mov    %esp,%ebp
f0102fb2:	53                   	push   %ebx
f0102fb3:	83 ec 04             	sub    $0x4,%esp
f0102fb6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102fb9:	8b 45 14             	mov    0x14(%ebp),%eax
f0102fbc:	83 c8 04             	or     $0x4,%eax
f0102fbf:	50                   	push   %eax
f0102fc0:	ff 75 10             	pushl  0x10(%ebp)
f0102fc3:	ff 75 0c             	pushl  0xc(%ebp)
f0102fc6:	53                   	push   %ebx
f0102fc7:	e8 5c ff ff ff       	call   f0102f28 <user_mem_check>
f0102fcc:	83 c4 10             	add    $0x10,%esp
f0102fcf:	85 c0                	test   %eax,%eax
f0102fd1:	79 21                	jns    f0102ff4 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102fd3:	83 ec 04             	sub    $0x4,%esp
f0102fd6:	ff 35 3c 62 21 f0    	pushl  0xf021623c
f0102fdc:	ff 73 54             	pushl  0x54(%ebx)
f0102fdf:	68 5c 77 10 f0       	push   $0xf010775c
f0102fe4:	e8 37 0b 00 00       	call   f0103b20 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102fe9:	89 1c 24             	mov    %ebx,(%esp)
f0102fec:	e8 51 08 00 00       	call   f0103842 <env_destroy>
f0102ff1:	83 c4 10             	add    $0x10,%esp
	}
}
f0102ff4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102ff7:	c9                   	leave  
f0102ff8:	c3                   	ret    

f0102ff9 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102ff9:	55                   	push   %ebp
f0102ffa:	89 e5                	mov    %esp,%ebp
f0102ffc:	57                   	push   %edi
f0102ffd:	56                   	push   %esi
f0102ffe:	53                   	push   %ebx
f0102fff:	83 ec 0c             	sub    $0xc,%esp
f0103002:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
        uintptr_t rva = (uintptr_t) ROUNDDOWN(va, PGSIZE);
f0103004:	89 d3                	mov    %edx,%ebx
f0103006:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        uintptr_t rva_end = (uintptr_t) ROUNDUP(va + len, PGSIZE);
f010300c:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0103013:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi

        while (rva < rva_end) {
f0103019:	eb 58                	jmp    f0103073 <region_alloc+0x7a>
                struct PageInfo *page = page_alloc(0);
f010301b:	83 ec 0c             	sub    $0xc,%esp
f010301e:	6a 00                	push   $0x0
f0103020:	e8 97 df ff ff       	call   f0100fbc <page_alloc>
                if (page == NULL)
f0103025:	83 c4 10             	add    $0x10,%esp
f0103028:	85 c0                	test   %eax,%eax
f010302a:	75 17                	jne    f0103043 <region_alloc+0x4a>
                        panic("region_alloc: couldn't allocate page");
f010302c:	83 ec 04             	sub    $0x4,%esp
f010302f:	68 fc 7a 10 f0       	push   $0xf0107afc
f0103034:	68 5b 01 00 00       	push   $0x15b
f0103039:	68 35 7c 10 f0       	push   $0xf0107c35
f010303e:	e8 fd cf ff ff       	call   f0100040 <_panic>

                if (page_insert(e->env_pgdir, page, (void *) rva, PTE_P | PTE_U | PTE_W) < 0)
f0103043:	6a 07                	push   $0x7
f0103045:	53                   	push   %ebx
f0103046:	50                   	push   %eax
f0103047:	ff 77 6c             	pushl  0x6c(%edi)
f010304a:	e8 1b e3 ff ff       	call   f010136a <page_insert>
f010304f:	83 c4 10             	add    $0x10,%esp
f0103052:	85 c0                	test   %eax,%eax
f0103054:	79 17                	jns    f010306d <region_alloc+0x74>
                        panic("region_alloc: page couldn't be inserted");
f0103056:	83 ec 04             	sub    $0x4,%esp
f0103059:	68 24 7b 10 f0       	push   $0xf0107b24
f010305e:	68 5e 01 00 00       	push   $0x15e
f0103063:	68 35 7c 10 f0       	push   $0xf0107c35
f0103068:	e8 d3 cf ff ff       	call   f0100040 <_panic>

                rva += PGSIZE;
f010306d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
        uintptr_t rva = (uintptr_t) ROUNDDOWN(va, PGSIZE);
        uintptr_t rva_end = (uintptr_t) ROUNDUP(va + len, PGSIZE);

        while (rva < rva_end) {
f0103073:	39 f3                	cmp    %esi,%ebx
f0103075:	72 a4                	jb     f010301b <region_alloc+0x22>
                if (page_insert(e->env_pgdir, page, (void *) rva, PTE_P | PTE_U | PTE_W) < 0)
                        panic("region_alloc: page couldn't be inserted");

                rva += PGSIZE;
        }
}
f0103077:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010307a:	5b                   	pop    %ebx
f010307b:	5e                   	pop    %esi
f010307c:	5f                   	pop    %edi
f010307d:	5d                   	pop    %ebp
f010307e:	c3                   	ret    

f010307f <stack_push>:
struct FreeStacks* thread_free_stacks = NULL; //free stacks for threads
static struct FreeStacks* free_stacks_stack;


void stack_push(uint32_t id)
{	
f010307f:	55                   	push   %ebp
f0103080:	89 e5                	mov    %esp,%ebp
f0103082:	8b 45 08             	mov    0x8(%ebp),%eax
	thread_free_stacks[id].next_stack = free_stacks_stack;
f0103085:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103088:	a1 48 62 21 f0       	mov    0xf0216248,%eax
f010308d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103090:	8b 15 50 62 21 f0    	mov    0xf0216250,%edx
f0103096:	89 50 08             	mov    %edx,0x8(%eax)
        free_stacks_stack = &thread_free_stacks[id];
f0103099:	a3 50 62 21 f0       	mov    %eax,0xf0216250
}
f010309e:	5d                   	pop    %ebp
f010309f:	c3                   	ret    

f01030a0 <stack_pop>:

struct FreeStacks* stack_pop()
{
f01030a0:	55                   	push   %ebp
f01030a1:	89 e5                	mov    %esp,%ebp
	struct FreeStacks* ret = free_stacks_stack;
f01030a3:	a1 50 62 21 f0       	mov    0xf0216250,%eax
	free_stacks_stack = free_stacks_stack->next_stack;
f01030a8:	8b 50 08             	mov    0x8(%eax),%edx
f01030ab:	89 15 50 62 21 f0    	mov    %edx,0xf0216250
	
	return ret;
}
f01030b1:	5d                   	pop    %ebp
f01030b2:	c3                   	ret    

f01030b3 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01030b3:	55                   	push   %ebp
f01030b4:	89 e5                	mov    %esp,%ebp
f01030b6:	56                   	push   %esi
f01030b7:	53                   	push   %ebx
f01030b8:	8b 45 08             	mov    0x8(%ebp),%eax
f01030bb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f01030be:	85 c0                	test   %eax,%eax
f01030c0:	75 1a                	jne    f01030dc <envid2env+0x29>
		*env_store = curenv;
f01030c2:	e8 3b 31 00 00       	call   f0106202 <cpunum>
f01030c7:	6b c0 74             	imul   $0x74,%eax,%eax
f01030ca:	8b 80 28 70 21 f0    	mov    -0xfde8fd8(%eax),%eax
f01030d0:	8b 75 0c             	mov    0xc(%ebp),%esi
f01030d3:	89 06                	mov    %eax,(%esi)
		return 0;
f01030d5:	b8 00 00 00 00       	mov    $0x0,%eax
f01030da:	eb 75                	jmp    f0103151 <envid2env+0x9e>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f01030dc:	89 c2                	mov    %eax,%edx
f01030de:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01030e4:	89 d3                	mov    %edx,%ebx
f01030e6:	c1 e3 07             	shl    $0x7,%ebx
f01030e9:	8d 1c d3             	lea    (%ebx,%edx,8),%ebx
f01030ec:	03 1d 4c 62 21 f0    	add    0xf021624c,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01030f2:	83 7b 60 00          	cmpl   $0x0,0x60(%ebx)
f01030f6:	74 05                	je     f01030fd <envid2env+0x4a>
f01030f8:	3b 43 54             	cmp    0x54(%ebx),%eax
f01030fb:	74 10                	je     f010310d <envid2env+0x5a>
		*env_store = 0;
f01030fd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103100:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103106:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010310b:	eb 44                	jmp    f0103151 <envid2env+0x9e>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010310d:	84 c9                	test   %cl,%cl
f010310f:	74 36                	je     f0103147 <envid2env+0x94>
f0103111:	e8 ec 30 00 00       	call   f0106202 <cpunum>
f0103116:	6b c0 74             	imul   $0x74,%eax,%eax
f0103119:	3b 98 28 70 21 f0    	cmp    -0xfde8fd8(%eax),%ebx
f010311f:	74 26                	je     f0103147 <envid2env+0x94>
f0103121:	8b 73 58             	mov    0x58(%ebx),%esi
f0103124:	e8 d9 30 00 00       	call   f0106202 <cpunum>
f0103129:	6b c0 74             	imul   $0x74,%eax,%eax
f010312c:	8b 80 28 70 21 f0    	mov    -0xfde8fd8(%eax),%eax
f0103132:	3b 70 54             	cmp    0x54(%eax),%esi
f0103135:	74 10                	je     f0103147 <envid2env+0x94>
		*env_store = 0;
f0103137:	8b 45 0c             	mov    0xc(%ebp),%eax
f010313a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103140:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103145:	eb 0a                	jmp    f0103151 <envid2env+0x9e>
	}

	*env_store = e;
f0103147:	8b 45 0c             	mov    0xc(%ebp),%eax
f010314a:	89 18                	mov    %ebx,(%eax)
	return 0;
f010314c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103151:	5b                   	pop    %ebx
f0103152:	5e                   	pop    %esi
f0103153:	5d                   	pop    %ebp
f0103154:	c3                   	ret    

f0103155 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103155:	55                   	push   %ebp
f0103156:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f0103158:	b8 20 13 12 f0       	mov    $0xf0121320,%eax
f010315d:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103160:	b8 23 00 00 00       	mov    $0x23,%eax
f0103165:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103167:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103169:	b8 10 00 00 00       	mov    $0x10,%eax
f010316e:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103170:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103172:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103174:	ea 7b 31 10 f0 08 00 	ljmp   $0x8,$0xf010317b
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f010317b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103180:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103183:	5d                   	pop    %ebp
f0103184:	c3                   	ret    

f0103185 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103185:	55                   	push   %ebp
f0103186:	89 e5                	mov    %esp,%ebp
f0103188:	56                   	push   %esi
f0103189:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
        int i;
        for (i = NENV - 1; i >= 0; i--) {
                envs[i].env_status = ENV_FREE;
f010318a:	8b 35 4c 62 21 f0    	mov    0xf021624c,%esi
f0103190:	8b 15 54 62 21 f0    	mov    0xf0216254,%edx
f0103196:	8d 86 78 1f 02 00    	lea    0x21f78(%esi),%eax
f010319c:	8d 9e 78 ff ff ff    	lea    -0x88(%esi),%ebx
f01031a2:	89 c1                	mov    %eax,%ecx
f01031a4:	c7 40 60 00 00 00 00 	movl   $0x0,0x60(%eax)
                envs[i].env_id = 0;
f01031ab:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
                envs[i].env_link = env_free_list;
f01031b2:	89 50 50             	mov    %edx,0x50(%eax)
f01031b5:	2d 88 00 00 00       	sub    $0x88,%eax
                env_free_list = &envs[i];
f01031ba:	89 ca                	mov    %ecx,%edx
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
        int i;
        for (i = NENV - 1; i >= 0; i--) {
f01031bc:	39 d8                	cmp    %ebx,%eax
f01031be:	75 e2                	jne    f01031a2 <env_init+0x1d>
f01031c0:	89 35 54 62 21 f0    	mov    %esi,0xf0216254
f01031c6:	8b 1d 50 62 21 f0    	mov    0xf0216250,%ebx
f01031cc:	b9 00 d0 bf ee       	mov    $0xeebfd000,%ecx
f01031d1:	b8 fe 03 00 00       	mov    $0x3fe,%eax
f01031d6:	8d 14 40             	lea    (%eax,%eax,2),%edx
	uintptr_t THRDSTACKTOP = ustacktop - THRDSTKGAP;
	uintptr_t STACKADDR = THRDSTACKTOP;

	for (i = MAX_THREADS - 1; i >= 0 ; i--, STACKADDR -= (THRDSTKSIZE + THRDSTKGAP))
	{	
		thread_free_stacks[i].id = i;
f01031d9:	8b 35 48 62 21 f0    	mov    0xf0216248,%esi
f01031df:	89 04 96             	mov    %eax,(%esi,%edx,4)
		thread_free_stacks[i].addr = STACKADDR;
f01031e2:	8b 35 48 62 21 f0    	mov    0xf0216248,%esi
f01031e8:	8d 14 96             	lea    (%esi,%edx,4),%edx
f01031eb:	89 4a 04             	mov    %ecx,0x4(%edx)
		thread_free_stacks[i].next_stack = free_stacks_stack;
f01031ee:	89 5a 08             	mov    %ebx,0x8(%edx)
	/*Lab 7: multithreading*/
	uintptr_t ustacktop = 0xeebfe000;
	uintptr_t THRDSTACKTOP = ustacktop - THRDSTKGAP;
	uintptr_t STACKADDR = THRDSTACKTOP;

	for (i = MAX_THREADS - 1; i >= 0 ; i--, STACKADDR -= (THRDSTKSIZE + THRDSTKGAP))
f01031f1:	83 e8 01             	sub    $0x1,%eax
f01031f4:	81 e9 00 20 00 00    	sub    $0x2000,%ecx
	{	
		thread_free_stacks[i].id = i;
		thread_free_stacks[i].addr = STACKADDR;
		thread_free_stacks[i].next_stack = free_stacks_stack;
                free_stacks_stack = &thread_free_stacks[i];
f01031fa:	89 d3                	mov    %edx,%ebx
	/*Lab 7: multithreading*/
	uintptr_t ustacktop = 0xeebfe000;
	uintptr_t THRDSTACKTOP = ustacktop - THRDSTKGAP;
	uintptr_t STACKADDR = THRDSTACKTOP;

	for (i = MAX_THREADS - 1; i >= 0 ; i--, STACKADDR -= (THRDSTKSIZE + THRDSTKGAP))
f01031fc:	83 f8 ff             	cmp    $0xffffffff,%eax
f01031ff:	75 d5                	jne    f01031d6 <env_init+0x51>
f0103201:	89 15 50 62 21 f0    	mov    %edx,0xf0216250
		thread_free_stacks[i].addr = STACKADDR;
		thread_free_stacks[i].next_stack = free_stacks_stack;
                free_stacks_stack = &thread_free_stacks[i];
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f0103207:	e8 49 ff ff ff       	call   f0103155 <env_init_percpu>
}
f010320c:	5b                   	pop    %ebx
f010320d:	5e                   	pop    %esi
f010320e:	5d                   	pop    %ebp
f010320f:	c3                   	ret    

f0103210 <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103210:	55                   	push   %ebp
f0103211:	89 e5                	mov    %esp,%ebp
f0103213:	56                   	push   %esi
f0103214:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103215:	8b 1d 54 62 21 f0    	mov    0xf0216254,%ebx
f010321b:	85 db                	test   %ebx,%ebx
f010321d:	0f 84 a1 01 00 00    	je     f01033c4 <env_alloc+0x1b4>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103223:	83 ec 0c             	sub    $0xc,%esp
f0103226:	6a 01                	push   $0x1
f0103228:	e8 8f dd ff ff       	call   f0100fbc <page_alloc>
f010322d:	83 c4 10             	add    $0x10,%esp
f0103230:	85 c0                	test   %eax,%eax
f0103232:	0f 84 93 01 00 00    	je     f01033cb <env_alloc+0x1bb>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103238:	89 c2                	mov    %eax,%edx
f010323a:	2b 15 90 6e 21 f0    	sub    0xf0216e90,%edx
f0103240:	c1 fa 03             	sar    $0x3,%edx
f0103243:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103246:	89 d1                	mov    %edx,%ecx
f0103248:	c1 e9 0c             	shr    $0xc,%ecx
f010324b:	3b 0d 88 6e 21 f0    	cmp    0xf0216e88,%ecx
f0103251:	72 12                	jb     f0103265 <env_alloc+0x55>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103253:	52                   	push   %edx
f0103254:	68 c4 68 10 f0       	push   $0xf01068c4
f0103259:	6a 58                	push   $0x58
f010325b:	68 ba 77 10 f0       	push   $0xf01077ba
f0103260:	e8 db cd ff ff       	call   f0100040 <_panic>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
        e->env_pgdir = (pde_t *) page2kva(p);
f0103265:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010326b:	89 53 6c             	mov    %edx,0x6c(%ebx)
        p->pp_ref++;
f010326e:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0103273:	b8 00 00 00 00       	mov    $0x0,%eax

        for (i = 0; i < PDX(UTOP); i++)
                e->env_pgdir[i] = 0;
f0103278:	8b 53 6c             	mov    0x6c(%ebx),%edx
f010327b:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
f0103282:	83 c0 04             	add    $0x4,%eax

	// LAB 3: Your code here.
        e->env_pgdir = (pde_t *) page2kva(p);
        p->pp_ref++;

        for (i = 0; i < PDX(UTOP); i++)
f0103285:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f010328a:	75 ec                	jne    f0103278 <env_alloc+0x68>
                e->env_pgdir[i] = 0;

        for (i = PDX(UTOP); i < NPDENTRIES; i++)
                e->env_pgdir[i] = kern_pgdir[i];
f010328c:	8b 15 8c 6e 21 f0    	mov    0xf0216e8c,%edx
f0103292:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0103295:	8b 53 6c             	mov    0x6c(%ebx),%edx
f0103298:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f010329b:	83 c0 04             	add    $0x4,%eax
        p->pp_ref++;

        for (i = 0; i < PDX(UTOP); i++)
                e->env_pgdir[i] = 0;

        for (i = PDX(UTOP); i < NPDENTRIES; i++)
f010329e:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01032a3:	75 e7                	jne    f010328c <env_alloc+0x7c>
                e->env_pgdir[i] = kern_pgdir[i];

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01032a5:	8b 43 6c             	mov    0x6c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032a8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032ad:	77 15                	ja     f01032c4 <env_alloc+0xb4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032af:	50                   	push   %eax
f01032b0:	68 e8 68 10 f0       	push   $0xf01068e8
f01032b5:	68 ef 00 00 00       	push   $0xef
f01032ba:	68 35 7c 10 f0       	push   $0xf0107c35
f01032bf:	e8 7c cd ff ff       	call   f0100040 <_panic>
f01032c4:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01032ca:	83 ca 05             	or     $0x5,%edx
f01032cd:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01032d3:	8b 43 54             	mov    0x54(%ebx),%eax
f01032d6:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01032db:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f01032e0:	ba 00 10 00 00       	mov    $0x1000,%edx
f01032e5:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01032e8:	89 da                	mov    %ebx,%edx
f01032ea:	2b 15 4c 62 21 f0    	sub    0xf021624c,%edx
f01032f0:	c1 fa 03             	sar    $0x3,%edx
f01032f3:	69 d2 f1 f0 f0 f0    	imul   $0xf0f0f0f1,%edx,%edx
f01032f9:	09 d0                	or     %edx,%eax
f01032fb:	89 43 54             	mov    %eax,0x54(%ebx)
	cprintf("in env_alloc, allocated envid: %d\n\n", e->env_id);
f01032fe:	83 ec 08             	sub    $0x8,%esp
f0103301:	50                   	push   %eax
f0103302:	68 4c 7b 10 f0       	push   $0xf0107b4c
f0103307:	e8 14 08 00 00       	call   f0103b20 <cprintf>
	// Set the basic status variables.
	e->env_parent_id = parent_id;
f010330c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010330f:	89 43 58             	mov    %eax,0x58(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103312:	c7 43 5c 00 00 00 00 	movl   $0x0,0x5c(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103319:	c7 43 60 02 00 00 00 	movl   $0x2,0x60(%ebx)
	e->env_runs = 0;
f0103320:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103327:	83 c4 0c             	add    $0xc,%esp
f010332a:	6a 44                	push   $0x44
f010332c:	6a 00                	push   $0x0
f010332e:	8d 43 0c             	lea    0xc(%ebx),%eax
f0103331:	50                   	push   %eax
f0103332:	e8 a8 28 00 00       	call   f0105bdf <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103337:	66 c7 43 30 23 00    	movw   $0x23,0x30(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010333d:	66 c7 43 2c 23 00    	movw   $0x23,0x2c(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103343:	66 c7 43 4c 23 00    	movw   $0x23,0x4c(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103349:	c7 43 48 00 e0 bf ee 	movl   $0xeebfe000,0x48(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103350:	66 c7 43 40 1b 00    	movw   $0x1b,0x40(%ebx)
	// You will set e->env_tf.tf_eip later.
	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
        e->env_tf.tf_eflags |= FL_IF;
f0103356:	81 4b 44 00 02 00 00 	orl    $0x200,0x44(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f010335d:	c7 43 70 00 00 00 00 	movl   $0x0,0x70(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103364:	c6 43 74 00          	movb   $0x0,0x74(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103368:	8b 43 50             	mov    0x50(%ebx),%eax
f010336b:	a3 54 62 21 f0       	mov    %eax,0xf0216254
	*newenv_store = e;
f0103370:	8b 45 08             	mov    0x8(%ebp),%eax
f0103373:	89 18                	mov    %ebx,(%eax)

	// Lab 7 multithreading
	// nastavme proces id ako env id, ak sa alokuje thread, prestavi si process id sam
	// zoznam workerov nastavime ako prazdny
	e->env_process_id = e->env_id;
f0103375:	8b 73 54             	mov    0x54(%ebx),%esi
f0103378:	89 33                	mov    %esi,(%ebx)
	e->env_workers_link = NULL;
f010337a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	//e->env_threads_list->id = 0;
	//e->env_threads_list->next = NULL;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103381:	e8 7c 2e 00 00       	call   f0106202 <cpunum>
f0103386:	6b c0 74             	imul   $0x74,%eax,%eax
f0103389:	83 c4 10             	add    $0x10,%esp
f010338c:	ba 00 00 00 00       	mov    $0x0,%edx
f0103391:	83 b8 28 70 21 f0 00 	cmpl   $0x0,-0xfde8fd8(%eax)
f0103398:	74 11                	je     f01033ab <env_alloc+0x19b>
f010339a:	e8 63 2e 00 00       	call   f0106202 <cpunum>
f010339f:	6b c0 74             	imul   $0x74,%eax,%eax
f01033a2:	8b 80 28 70 21 f0    	mov    -0xfde8fd8(%eax),%eax
f01033a8:	8b 50 54             	mov    0x54(%eax),%edx
f01033ab:	83 ec 04             	sub    $0x4,%esp
f01033ae:	56                   	push   %esi
f01033af:	52                   	push   %edx
f01033b0:	68 40 7c 10 f0       	push   $0xf0107c40
f01033b5:	e8 66 07 00 00       	call   f0103b20 <cprintf>
	return 0;
f01033ba:	83 c4 10             	add    $0x10,%esp
f01033bd:	b8 00 00 00 00       	mov    $0x0,%eax
f01033c2:	eb 0c                	jmp    f01033d0 <env_alloc+0x1c0>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f01033c4:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01033c9:	eb 05                	jmp    f01033d0 <env_alloc+0x1c0>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f01033cb:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	//e->env_threads_list->id = 0;
	//e->env_threads_list->next = NULL;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01033d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01033d3:	5b                   	pop    %ebx
f01033d4:	5e                   	pop    %esi
f01033d5:	5d                   	pop    %ebp
f01033d6:	c3                   	ret    

f01033d7 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01033d7:	55                   	push   %ebp
f01033d8:	89 e5                	mov    %esp,%ebp
f01033da:	57                   	push   %edi
f01033db:	56                   	push   %esi
f01033dc:	53                   	push   %ebx
f01033dd:	83 ec 34             	sub    $0x34,%esp
f01033e0:	8b 75 08             	mov    0x8(%ebp),%esi
f01033e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// LAB 3: Your code here.
        struct Env *env;
        int status = env_alloc(&env, 0);
f01033e6:	6a 00                	push   $0x0
f01033e8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01033eb:	50                   	push   %eax
f01033ec:	e8 1f fe ff ff       	call   f0103210 <env_alloc>
        if (status < 0)
f01033f1:	83 c4 10             	add    $0x10,%esp
f01033f4:	85 c0                	test   %eax,%eax
f01033f6:	79 15                	jns    f010340d <env_create+0x36>
                panic("env_alloc: %e", status);
f01033f8:	50                   	push   %eax
f01033f9:	68 55 7c 10 f0       	push   $0xf0107c55
f01033fe:	68 c8 01 00 00       	push   $0x1c8
f0103403:	68 35 7c 10 f0       	push   $0xf0107c35
f0103408:	e8 33 cc ff ff       	call   f0100040 <_panic>

        // If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.        
        if (type == ENV_TYPE_FS) {
f010340d:	83 fb 01             	cmp    $0x1,%ebx
f0103410:	75 0a                	jne    f010341c <env_create+0x45>
                env->env_tf.tf_eflags |= FL_IOPL_3;
f0103412:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103415:	81 48 44 00 30 00 00 	orl    $0x3000,0x44(%eax)
        }

        env->env_type = type;
f010341c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010341f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103422:	89 58 5c             	mov    %ebx,0x5c(%eax)
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
        struct Elf *elf = (struct Elf *) binary;
        
        if (elf->e_magic != ELF_MAGIC)
f0103425:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f010342b:	74 17                	je     f0103444 <env_create+0x6d>
                panic("load_icode: binary isn't elf (invalid magic)");
f010342d:	83 ec 04             	sub    $0x4,%esp
f0103430:	68 70 7b 10 f0       	push   $0xf0107b70
f0103435:	68 9d 01 00 00       	push   $0x19d
f010343a:	68 35 7c 10 f0       	push   $0xf0107c35
f010343f:	e8 fc cb ff ff       	call   f0100040 <_panic>
       
        // We could do a bunch more checks here (for e_phnum and such) but let's not.

        struct Proghdr *pht = (struct Proghdr *) (binary + elf->e_phoff); 
f0103444:	89 f7                	mov    %esi,%edi
f0103446:	03 7e 1c             	add    0x1c(%esi),%edi
     
        lcr3(PADDR(e->env_pgdir));
f0103449:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010344c:	8b 40 6c             	mov    0x6c(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010344f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103454:	77 15                	ja     f010346b <env_create+0x94>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103456:	50                   	push   %eax
f0103457:	68 e8 68 10 f0       	push   $0xf01068e8
f010345c:	68 a3 01 00 00       	push   $0x1a3
f0103461:	68 35 7c 10 f0       	push   $0xf0107c35
f0103466:	e8 d5 cb ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010346b:	05 00 00 00 10       	add    $0x10000000,%eax
f0103470:	0f 22 d8             	mov    %eax,%cr3

        struct Proghdr *phdr;
        for (phdr = pht; phdr < pht + elf->e_phnum; phdr++) {
f0103473:	89 fb                	mov    %edi,%ebx
f0103475:	eb 60                	jmp    f01034d7 <env_create+0x100>
                if (phdr->p_type != ELF_PROG_LOAD)
f0103477:	83 3b 01             	cmpl   $0x1,(%ebx)
f010347a:	75 58                	jne    f01034d4 <env_create+0xfd>
                        continue;

                if (phdr->p_filesz > phdr->p_memsz)
f010347c:	8b 4b 14             	mov    0x14(%ebx),%ecx
f010347f:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0103482:	76 17                	jbe    f010349b <env_create+0xc4>
                        panic("load_icode: segment filesz > memsz");
f0103484:	83 ec 04             	sub    $0x4,%esp
f0103487:	68 a0 7b 10 f0       	push   $0xf0107ba0
f010348c:	68 ab 01 00 00       	push   $0x1ab
f0103491:	68 35 7c 10 f0       	push   $0xf0107c35
f0103496:	e8 a5 cb ff ff       	call   f0100040 <_panic>

                region_alloc(e, (void *) phdr->p_va, phdr->p_memsz);
f010349b:	8b 53 08             	mov    0x8(%ebx),%edx
f010349e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01034a1:	e8 53 fb ff ff       	call   f0102ff9 <region_alloc>
                memcpy((void *) phdr->p_va, binary + phdr->p_offset, phdr->p_filesz); 
f01034a6:	83 ec 04             	sub    $0x4,%esp
f01034a9:	ff 73 10             	pushl  0x10(%ebx)
f01034ac:	89 f0                	mov    %esi,%eax
f01034ae:	03 43 04             	add    0x4(%ebx),%eax
f01034b1:	50                   	push   %eax
f01034b2:	ff 73 08             	pushl  0x8(%ebx)
f01034b5:	e8 da 27 00 00       	call   f0105c94 <memcpy>
                memset((void *) (phdr->p_va + phdr->p_filesz), 0, phdr->p_memsz - phdr->p_filesz);
f01034ba:	8b 43 10             	mov    0x10(%ebx),%eax
f01034bd:	83 c4 0c             	add    $0xc,%esp
f01034c0:	8b 53 14             	mov    0x14(%ebx),%edx
f01034c3:	29 c2                	sub    %eax,%edx
f01034c5:	52                   	push   %edx
f01034c6:	6a 00                	push   $0x0
f01034c8:	03 43 08             	add    0x8(%ebx),%eax
f01034cb:	50                   	push   %eax
f01034cc:	e8 0e 27 00 00       	call   f0105bdf <memset>
f01034d1:	83 c4 10             	add    $0x10,%esp
        struct Proghdr *pht = (struct Proghdr *) (binary + elf->e_phoff); 
     
        lcr3(PADDR(e->env_pgdir));

        struct Proghdr *phdr;
        for (phdr = pht; phdr < pht + elf->e_phnum; phdr++) {
f01034d4:	83 c3 20             	add    $0x20,%ebx
f01034d7:	0f b7 46 2c          	movzwl 0x2c(%esi),%eax
f01034db:	c1 e0 05             	shl    $0x5,%eax
f01034de:	01 f8                	add    %edi,%eax
f01034e0:	39 c3                	cmp    %eax,%ebx
f01034e2:	72 93                	jb     f0103477 <env_create+0xa0>
                memset((void *) (phdr->p_va + phdr->p_filesz), 0, phdr->p_memsz - phdr->p_filesz);
        }

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
        region_alloc(e, (void *) (USTACKTOP - PGSIZE), PGSIZE);
f01034e4:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01034e9:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01034ee:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01034f1:	89 f8                	mov    %edi,%eax
f01034f3:	e8 01 fb ff ff       	call   f0102ff9 <region_alloc>

	// LAB 3: Your code here.
        e->env_tf.tf_eip = elf->e_entry;
f01034f8:	8b 46 18             	mov    0x18(%esi),%eax
f01034fb:	89 47 3c             	mov    %eax,0x3c(%edi)
                env->env_tf.tf_eflags |= FL_IOPL_3;
        }

        env->env_type = type;
        load_icode(env, binary);
}
f01034fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103501:	5b                   	pop    %ebx
f0103502:	5e                   	pop    %esi
f0103503:	5f                   	pop    %edi
f0103504:	5d                   	pop    %ebp
f0103505:	c3                   	ret    

f0103506 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103506:	55                   	push   %ebp
f0103507:	89 e5                	mov    %esp,%ebp
f0103509:	57                   	push   %edi
f010350a:	56                   	push   %esi
f010350b:	53                   	push   %ebx
f010350c:	83 ec 1c             	sub    $0x1c,%esp
f010350f:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103512:	e8 eb 2c 00 00       	call   f0106202 <cpunum>
f0103517:	6b c0 74             	imul   $0x74,%eax,%eax
f010351a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103521:	39 b8 28 70 21 f0    	cmp    %edi,-0xfde8fd8(%eax)
f0103527:	75 30                	jne    f0103559 <env_free+0x53>
		lcr3(PADDR(kern_pgdir));
f0103529:	a1 8c 6e 21 f0       	mov    0xf0216e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010352e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103533:	77 15                	ja     f010354a <env_free+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103535:	50                   	push   %eax
f0103536:	68 e8 68 10 f0       	push   $0xf01068e8
f010353b:	68 e2 01 00 00       	push   $0x1e2
f0103540:	68 35 7c 10 f0       	push   $0xf0107c35
f0103545:	e8 f6 ca ff ff       	call   f0100040 <_panic>
f010354a:	05 00 00 00 10       	add    $0x10000000,%eax
f010354f:	0f 22 d8             	mov    %eax,%cr3
f0103552:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103559:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010355c:	89 d0                	mov    %edx,%eax
f010355e:	c1 e0 02             	shl    $0x2,%eax
f0103561:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103564:	8b 47 6c             	mov    0x6c(%edi),%eax
f0103567:	8b 34 90             	mov    (%eax,%edx,4),%esi
f010356a:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103570:	0f 84 a8 00 00 00    	je     f010361e <env_free+0x118>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103576:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010357c:	89 f0                	mov    %esi,%eax
f010357e:	c1 e8 0c             	shr    $0xc,%eax
f0103581:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103584:	39 05 88 6e 21 f0    	cmp    %eax,0xf0216e88
f010358a:	77 15                	ja     f01035a1 <env_free+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010358c:	56                   	push   %esi
f010358d:	68 c4 68 10 f0       	push   $0xf01068c4
f0103592:	68 f1 01 00 00       	push   $0x1f1
f0103597:	68 35 7c 10 f0       	push   $0xf0107c35
f010359c:	e8 9f ca ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01035a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01035a4:	c1 e0 16             	shl    $0x16,%eax
f01035a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01035aa:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01035af:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01035b6:	01 
f01035b7:	74 17                	je     f01035d0 <env_free+0xca>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01035b9:	83 ec 08             	sub    $0x8,%esp
f01035bc:	89 d8                	mov    %ebx,%eax
f01035be:	c1 e0 0c             	shl    $0xc,%eax
f01035c1:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01035c4:	50                   	push   %eax
f01035c5:	ff 77 6c             	pushl  0x6c(%edi)
f01035c8:	e8 2f dd ff ff       	call   f01012fc <page_remove>
f01035cd:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01035d0:	83 c3 01             	add    $0x1,%ebx
f01035d3:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01035d9:	75 d4                	jne    f01035af <env_free+0xa9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01035db:	8b 47 6c             	mov    0x6c(%edi),%eax
f01035de:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01035e1:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01035e8:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01035eb:	3b 05 88 6e 21 f0    	cmp    0xf0216e88,%eax
f01035f1:	72 14                	jb     f0103607 <env_free+0x101>
		panic("pa2page called with invalid pa");
f01035f3:	83 ec 04             	sub    $0x4,%esp
f01035f6:	68 30 6f 10 f0       	push   $0xf0106f30
f01035fb:	6a 51                	push   $0x51
f01035fd:	68 ba 77 10 f0       	push   $0xf01077ba
f0103602:	e8 39 ca ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f0103607:	83 ec 0c             	sub    $0xc,%esp
f010360a:	a1 90 6e 21 f0       	mov    0xf0216e90,%eax
f010360f:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103612:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103615:	50                   	push   %eax
f0103616:	e8 80 da ff ff       	call   f010109b <page_decref>
f010361b:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010361e:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103622:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103625:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f010362a:	0f 85 29 ff ff ff    	jne    f0103559 <env_free+0x53>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103630:	8b 47 6c             	mov    0x6c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103633:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103638:	77 15                	ja     f010364f <env_free+0x149>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010363a:	50                   	push   %eax
f010363b:	68 e8 68 10 f0       	push   $0xf01068e8
f0103640:	68 ff 01 00 00       	push   $0x1ff
f0103645:	68 35 7c 10 f0       	push   $0xf0107c35
f010364a:	e8 f1 c9 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f010364f:	c7 47 6c 00 00 00 00 	movl   $0x0,0x6c(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103656:	05 00 00 00 10       	add    $0x10000000,%eax
f010365b:	c1 e8 0c             	shr    $0xc,%eax
f010365e:	3b 05 88 6e 21 f0    	cmp    0xf0216e88,%eax
f0103664:	72 14                	jb     f010367a <env_free+0x174>
		panic("pa2page called with invalid pa");
f0103666:	83 ec 04             	sub    $0x4,%esp
f0103669:	68 30 6f 10 f0       	push   $0xf0106f30
f010366e:	6a 51                	push   $0x51
f0103670:	68 ba 77 10 f0       	push   $0xf01077ba
f0103675:	e8 c6 c9 ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f010367a:	83 ec 0c             	sub    $0xc,%esp
f010367d:	8b 15 90 6e 21 f0    	mov    0xf0216e90,%edx
f0103683:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103686:	50                   	push   %eax
f0103687:	e8 0f da ff ff       	call   f010109b <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010368c:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	e->env_link = env_free_list;
f0103693:	a1 54 62 21 f0       	mov    0xf0216254,%eax
f0103698:	89 47 50             	mov    %eax,0x50(%edi)
	env_free_list = e;
f010369b:	89 3d 54 62 21 f0    	mov    %edi,0xf0216254
}
f01036a1:	83 c4 10             	add    $0x10,%esp
f01036a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01036a7:	5b                   	pop    %ebx
f01036a8:	5e                   	pop    %esi
f01036a9:	5f                   	pop    %edi
f01036aa:	5d                   	pop    %ebp
f01036ab:	c3                   	ret    

f01036ac <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01036ac:	55                   	push   %ebp
f01036ad:	89 e5                	mov    %esp,%ebp
f01036af:	53                   	push   %ebx
f01036b0:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01036b3:	e8 4a 2b 00 00       	call   f0106202 <cpunum>
f01036b8:	6b c0 74             	imul   $0x74,%eax,%eax
f01036bb:	8b 98 28 70 21 f0    	mov    -0xfde8fd8(%eax),%ebx
f01036c1:	e8 3c 2b 00 00       	call   f0106202 <cpunum>
f01036c6:	89 43 68             	mov    %eax,0x68(%ebx)

	asm volatile(
f01036c9:	8b 65 08             	mov    0x8(%ebp),%esp
f01036cc:	61                   	popa   
f01036cd:	07                   	pop    %es
f01036ce:	1f                   	pop    %ds
f01036cf:	83 c4 08             	add    $0x8,%esp
f01036d2:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01036d3:	83 ec 04             	sub    $0x4,%esp
f01036d6:	68 63 7c 10 f0       	push   $0xf0107c63
f01036db:	68 3f 02 00 00       	push   $0x23f
f01036e0:	68 35 7c 10 f0       	push   $0xf0107c35
f01036e5:	e8 56 c9 ff ff       	call   f0100040 <_panic>

f01036ea <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01036ea:	55                   	push   %ebp
f01036eb:	89 e5                	mov    %esp,%ebp
f01036ed:	53                   	push   %ebx
f01036ee:	83 ec 0c             	sub    $0xc,%esp
f01036f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
        //
        // First call to env_run
	cprintf("In env run, running env: %d\n", e->env_id);// can be commented - for testing purposes only
f01036f4:	ff 73 54             	pushl  0x54(%ebx)
f01036f7:	68 6f 7c 10 f0       	push   $0xf0107c6f
f01036fc:	e8 1f 04 00 00       	call   f0103b20 <cprintf>

        if ((curenv != NULL) && (curenv->env_status == ENV_RUNNING))
f0103701:	e8 fc 2a 00 00       	call   f0106202 <cpunum>
f0103706:	6b c0 74             	imul   $0x74,%eax,%eax
f0103709:	83 c4 10             	add    $0x10,%esp
f010370c:	83 b8 28 70 21 f0 00 	cmpl   $0x0,-0xfde8fd8(%eax)
f0103713:	74 29                	je     f010373e <env_run+0x54>
f0103715:	e8 e8 2a 00 00       	call   f0106202 <cpunum>
f010371a:	6b c0 74             	imul   $0x74,%eax,%eax
f010371d:	8b 80 28 70 21 f0    	mov    -0xfde8fd8(%eax),%eax
f0103723:	83 78 60 03          	cmpl   $0x3,0x60(%eax)
f0103727:	75 15                	jne    f010373e <env_run+0x54>
                curenv->env_status = ENV_RUNNABLE;
f0103729:	e8 d4 2a 00 00       	call   f0106202 <cpunum>
f010372e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103731:	8b 80 28 70 21 f0    	mov    -0xfde8fd8(%eax),%eax
f0103737:	c7 40 60 02 00 00 00 	movl   $0x2,0x60(%eax)

        curenv = e;
f010373e:	e8 bf 2a 00 00       	call   f0106202 <cpunum>
f0103743:	6b c0 74             	imul   $0x74,%eax,%eax
f0103746:	89 98 28 70 21 f0    	mov    %ebx,-0xfde8fd8(%eax)
        curenv->env_status = ENV_RUNNING;
f010374c:	e8 b1 2a 00 00       	call   f0106202 <cpunum>
f0103751:	6b c0 74             	imul   $0x74,%eax,%eax
f0103754:	8b 80 28 70 21 f0    	mov    -0xfde8fd8(%eax),%eax
f010375a:	c7 40 60 03 00 00 00 	movl   $0x3,0x60(%eax)
        curenv->env_runs++;
f0103761:	e8 9c 2a 00 00       	call   f0106202 <cpunum>
f0103766:	6b c0 74             	imul   $0x74,%eax,%eax
f0103769:	8b 80 28 70 21 f0    	mov    -0xfde8fd8(%eax),%eax
f010376f:	83 40 64 01          	addl   $0x1,0x64(%eax)

        lcr3(PADDR(curenv->env_pgdir));
f0103773:	e8 8a 2a 00 00       	call   f0106202 <cpunum>
f0103778:	6b c0 74             	imul   $0x74,%eax,%eax
f010377b:	8b 80 28 70 21 f0    	mov    -0xfde8fd8(%eax),%eax
f0103781:	8b 40 6c             	mov    0x6c(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103784:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103789:	77 15                	ja     f01037a0 <env_run+0xb6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010378b:	50                   	push   %eax
f010378c:	68 e8 68 10 f0       	push   $0xf01068e8
f0103791:	68 68 02 00 00       	push   $0x268
f0103796:	68 35 7c 10 f0       	push   $0xf0107c35
f010379b:	e8 a0 c8 ff ff       	call   f0100040 <_panic>
f01037a0:	05 00 00 00 10       	add    $0x10000000,%eax
f01037a5:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01037a8:	83 ec 0c             	sub    $0xc,%esp
f01037ab:	68 c0 13 12 f0       	push   $0xf01213c0
f01037b0:	e8 58 2d 00 00       	call   f010650d <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01037b5:	f3 90                	pause  
        unlock_kernel();
        env_pop_tf(&curenv->env_tf);
f01037b7:	e8 46 2a 00 00       	call   f0106202 <cpunum>
f01037bc:	6b c0 74             	imul   $0x74,%eax,%eax
f01037bf:	8b 80 28 70 21 f0    	mov    -0xfde8fd8(%eax),%eax
f01037c5:	83 c0 0c             	add    $0xc,%eax
f01037c8:	89 04 24             	mov    %eax,(%esp)
f01037cb:	e8 dc fe ff ff       	call   f01036ac <env_pop_tf>

f01037d0 <thread_destroy>:

/*Lab 7 : mulithreading*/

void
thread_destroy(struct Env *e)
{
f01037d0:	55                   	push   %ebp
f01037d1:	89 e5                	mov    %esp,%ebp
	//asi ani nebude potrebne, vsetko co treba sa spravi v thread free 
}
f01037d3:	5d                   	pop    %ebp
f01037d4:	c3                   	ret    

f01037d5 <thread_free>:
// pri multithreadingu zdielany, takze by sme efektivne znicili env pgdir aj pre ostatne worker 
// thready a aj pre main thread, cize po prepnuti do jedneho z tychto threadov
// sa potom sposobuje velmi nepekny triple fault
void 
thread_free(struct Env* e)
{
f01037d5:	55                   	push   %ebp
f01037d6:	89 e5                	mov    %esp,%ebp
f01037d8:	53                   	push   %ebx
f01037d9:	83 ec 0c             	sub    $0xc,%esp
f01037dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("In thread free, freeing thread: %d\n", e->env_id); 
f01037df:	ff 73 54             	pushl  0x54(%ebx)
f01037e2:	68 c4 7b 10 f0       	push   $0xf0107bc4
f01037e7:	e8 34 03 00 00       	call   f0103b20 <cprintf>
	// hod jej esp adresu na zoznam volnych stackov pre thready
	stack_push(e->env_stack_id);
f01037ec:	83 c4 04             	add    $0x4,%esp
f01037ef:	ff 73 08             	pushl  0x8(%ebx)
f01037f2:	e8 88 f8 ff ff       	call   f010307f <stack_push>

	e->env_pgdir = 0;
f01037f7:	c7 43 6c 00 00 00 00 	movl   $0x0,0x6c(%ebx)
	e->env_status = ENV_FREE;
f01037fe:	c7 43 60 00 00 00 00 	movl   $0x0,0x60(%ebx)
	e->env_link = env_free_list;
f0103805:	a1 54 62 21 f0       	mov    0xf0216254,%eax
f010380a:	89 43 50             	mov    %eax,0x50(%ebx)
	env_free_list = e;
f010380d:	89 1d 54 62 21 f0    	mov    %ebx,0xf0216254
	if (curenv == e) {
f0103813:	e8 ea 29 00 00       	call   f0106202 <cpunum>
f0103818:	6b c0 74             	imul   $0x74,%eax,%eax
f010381b:	83 c4 10             	add    $0x10,%esp
f010381e:	3b 98 28 70 21 f0    	cmp    -0xfde8fd8(%eax),%ebx
f0103824:	75 17                	jne    f010383d <thread_free+0x68>
		curenv = NULL;
f0103826:	e8 d7 29 00 00       	call   f0106202 <cpunum>
f010382b:	6b c0 74             	imul   $0x74,%eax,%eax
f010382e:	c7 80 28 70 21 f0 00 	movl   $0x0,-0xfde8fd8(%eax)
f0103835:	00 00 00 
		sched_yield();
f0103838:	e8 4e 11 00 00       	call   f010498b <sched_yield>
	}
}
f010383d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103840:	c9                   	leave  
f0103841:	c3                   	ret    

f0103842 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103842:	55                   	push   %ebp
f0103843:	89 e5                	mov    %esp,%ebp
f0103845:	53                   	push   %ebx
f0103846:	83 ec 04             	sub    $0x4,%esp
f0103849:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f010384c:	83 7b 60 03          	cmpl   $0x3,0x60(%ebx)
f0103850:	75 19                	jne    f010386b <env_destroy+0x29>
f0103852:	e8 ab 29 00 00       	call   f0106202 <cpunum>
f0103857:	6b c0 74             	imul   $0x74,%eax,%eax
f010385a:	3b 98 28 70 21 f0    	cmp    -0xfde8fd8(%eax),%ebx
f0103860:	74 09                	je     f010386b <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103862:	c7 43 60 01 00 00 00 	movl   $0x1,0x60(%ebx)
		return;
f0103869:	eb 59                	jmp    f01038c4 <env_destroy+0x82>
	}
	cprintf("In env destroy, destroying env: %d\n", e->env_id); // for testing purposes
f010386b:	83 ec 08             	sub    $0x8,%esp
f010386e:	ff 73 54             	pushl  0x54(%ebx)
f0103871:	68 e8 7b 10 f0       	push   $0xf0107be8
f0103876:	e8 a5 02 00 00       	call   f0103b20 <cprintf>
	// prejdi cez zoznam workerov main threadu a znic ich 
	struct Env *worker = e->env_workers_link;
f010387b:	8b 43 04             	mov    0x4(%ebx),%eax
	if(e->env_workers_link) {
f010387e:	83 c4 10             	add    $0x10,%esp
f0103881:	85 c0                	test   %eax,%eax
f0103883:	74 0c                	je     f0103891 <env_destroy+0x4f>
		struct Env *to_free = worker;
		worker = worker->env_workers_link;
		//env_free(to_free);
		thread_free(to_free);
f0103885:	83 ec 0c             	sub    $0xc,%esp
f0103888:	50                   	push   %eax
f0103889:	e8 47 ff ff ff       	call   f01037d5 <thread_free>
f010388e:	83 c4 10             	add    $0x10,%esp
	}
	// znic main thread
	env_free(e);
f0103891:	83 ec 0c             	sub    $0xc,%esp
f0103894:	53                   	push   %ebx
f0103895:	e8 6c fc ff ff       	call   f0103506 <env_free>

	if (curenv == e) {
f010389a:	e8 63 29 00 00       	call   f0106202 <cpunum>
f010389f:	6b c0 74             	imul   $0x74,%eax,%eax
f01038a2:	83 c4 10             	add    $0x10,%esp
f01038a5:	3b 98 28 70 21 f0    	cmp    -0xfde8fd8(%eax),%ebx
f01038ab:	75 17                	jne    f01038c4 <env_destroy+0x82>
		curenv = NULL;
f01038ad:	e8 50 29 00 00       	call   f0106202 <cpunum>
f01038b2:	6b c0 74             	imul   $0x74,%eax,%eax
f01038b5:	c7 80 28 70 21 f0 00 	movl   $0x0,-0xfde8fd8(%eax)
f01038bc:	00 00 00 
		sched_yield();
f01038bf:	e8 c7 10 00 00       	call   f010498b <sched_yield>
	}
}
f01038c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01038c7:	c9                   	leave  
f01038c8:	c3                   	ret    

f01038c9 <thread_create>:
	main threadu), vratine env id

napad:  alokovanie zasobnikov - zasobnik s adresami vrcholov neobsadenych zasobnikov. Pri vytvoreni 		threadu sa popne, pri zniceni threadu pushne.
	*/
envid_t thread_create(uintptr_t func)
{
f01038c9:	55                   	push   %ebp
f01038ca:	89 e5                	mov    %esp,%ebp
f01038cc:	56                   	push   %esi
f01038cd:	53                   	push   %ebx
f01038ce:	83 ec 10             	sub    $0x10,%esp
	print_trapframe(&curenv->env_tf); // can be commented - for testing purposes only
f01038d1:	e8 2c 29 00 00       	call   f0106202 <cpunum>
f01038d6:	83 ec 0c             	sub    $0xc,%esp
f01038d9:	6b c0 74             	imul   $0x74,%eax,%eax
f01038dc:	8b 80 28 70 21 f0    	mov    -0xfde8fd8(%eax),%eax
f01038e2:	83 c0 0c             	add    $0xc,%eax
f01038e5:	50                   	push   %eax
f01038e6:	e8 ac 09 00 00       	call   f0104297 <print_trapframe>
	
	struct Env *e;
	env_alloc(&e, 0);
f01038eb:	83 c4 08             	add    $0x8,%esp
f01038ee:	6a 00                	push   $0x0
f01038f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01038f3:	50                   	push   %eax
f01038f4:	e8 17 f9 ff ff       	call   f0103210 <env_alloc>
	e->env_pgdir = curenv->env_pgdir;
f01038f9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01038fc:	e8 01 29 00 00       	call   f0106202 <cpunum>
f0103901:	6b c0 74             	imul   $0x74,%eax,%eax
f0103904:	8b 80 28 70 21 f0    	mov    -0xfde8fd8(%eax),%eax
f010390a:	8b 40 6c             	mov    0x6c(%eax),%eax
f010390d:	89 43 6c             	mov    %eax,0x6c(%ebx)
	
	//region_alloc(e, (void *) (USTACKTOP - (4*PGSIZE)), PGSIZE);
	//e->env_tf.tf_esp = USTACKTOP - (3*PGSIZE);
	/*get a free thread stack address from the free stacks stack*/
	struct FreeStacks* stack = stack_pop();
f0103910:	e8 8b f7 ff ff       	call   f01030a0 <stack_pop>
f0103915:	89 c6                	mov    %eax,%esi
	e->env_stack_id = stack->id; 
f0103917:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010391a:	8b 16                	mov    (%esi),%edx
f010391c:	89 50 08             	mov    %edx,0x8(%eax)
	region_alloc(e, (void*)(stack->addr - PGSIZE), PGSIZE);
f010391f:	8b 4e 04             	mov    0x4(%esi),%ecx
f0103922:	8d 91 00 f0 ff ff    	lea    -0x1000(%ecx),%edx
f0103928:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010392d:	e8 c7 f6 ff ff       	call   f0102ff9 <region_alloc>
	e->env_tf.tf_esp = stack->addr;
f0103932:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0103935:	8b 46 04             	mov    0x4(%esi),%eax
f0103938:	89 43 48             	mov    %eax,0x48(%ebx)

	e->env_tf.tf_eip = func;
f010393b:	8b 45 08             	mov    0x8(%ebp),%eax
f010393e:	89 43 3c             	mov    %eax,0x3c(%ebx)
	


	//e->env_threads_list->id = e->env_id;
	//e->env_threads_list->next
	e->env_workers_link = curenv->env_workers_link;
f0103941:	e8 bc 28 00 00       	call   f0106202 <cpunum>
f0103946:	6b c0 74             	imul   $0x74,%eax,%eax
f0103949:	8b 80 28 70 21 f0    	mov    -0xfde8fd8(%eax),%eax
f010394f:	8b 40 04             	mov    0x4(%eax),%eax
f0103952:	89 43 04             	mov    %eax,0x4(%ebx)
	curenv->env_workers_link = e;
f0103955:	e8 a8 28 00 00       	call   f0106202 <cpunum>
f010395a:	6b c0 74             	imul   $0x74,%eax,%eax
f010395d:	8b 80 28 70 21 f0    	mov    -0xfde8fd8(%eax),%eax
f0103963:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0103966:	89 58 04             	mov    %ebx,0x4(%eax)
	e->env_status = ENV_RUNNABLE;
f0103969:	c7 43 60 02 00 00 00 	movl   $0x2,0x60(%ebx)
	e->env_process_id = curenv->env_process_id; // resp. env_id ?
f0103970:	e8 8d 28 00 00       	call   f0106202 <cpunum>
f0103975:	6b c0 74             	imul   $0x74,%eax,%eax
f0103978:	8b 80 28 70 21 f0    	mov    -0xfde8fd8(%eax),%eax
f010397e:	8b 00                	mov    (%eax),%eax
f0103980:	89 03                	mov    %eax,(%ebx)
	cprintf("in thread create: thread process id: %d\n", e->env_process_id);
f0103982:	83 c4 08             	add    $0x8,%esp
f0103985:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103988:	ff 30                	pushl  (%eax)
f010398a:	68 0c 7c 10 f0       	push   $0xf0107c0c
f010398f:	e8 8c 01 00 00       	call   f0103b20 <cprintf>
	return e->env_id;
f0103994:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103997:	8b 40 54             	mov    0x54(%eax),%eax
}
f010399a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010399d:	5b                   	pop    %ebx
f010399e:	5e                   	pop    %esi
f010399f:	5d                   	pop    %ebp
f01039a0:	c3                   	ret    

f01039a1 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01039a1:	55                   	push   %ebp
f01039a2:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01039a4:	ba 70 00 00 00       	mov    $0x70,%edx
f01039a9:	8b 45 08             	mov    0x8(%ebp),%eax
f01039ac:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01039ad:	ba 71 00 00 00       	mov    $0x71,%edx
f01039b2:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01039b3:	0f b6 c0             	movzbl %al,%eax
}
f01039b6:	5d                   	pop    %ebp
f01039b7:	c3                   	ret    

f01039b8 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01039b8:	55                   	push   %ebp
f01039b9:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01039bb:	ba 70 00 00 00       	mov    $0x70,%edx
f01039c0:	8b 45 08             	mov    0x8(%ebp),%eax
f01039c3:	ee                   	out    %al,(%dx)
f01039c4:	ba 71 00 00 00       	mov    $0x71,%edx
f01039c9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01039cc:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01039cd:	5d                   	pop    %ebp
f01039ce:	c3                   	ret    

f01039cf <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01039cf:	55                   	push   %ebp
f01039d0:	89 e5                	mov    %esp,%ebp
f01039d2:	56                   	push   %esi
f01039d3:	53                   	push   %ebx
f01039d4:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f01039d7:	66 a3 a8 13 12 f0    	mov    %ax,0xf01213a8
	if (!didinit)
f01039dd:	80 3d 58 62 21 f0 00 	cmpb   $0x0,0xf0216258
f01039e4:	74 5a                	je     f0103a40 <irq_setmask_8259A+0x71>
f01039e6:	89 c6                	mov    %eax,%esi
f01039e8:	ba 21 00 00 00       	mov    $0x21,%edx
f01039ed:	ee                   	out    %al,(%dx)
f01039ee:	66 c1 e8 08          	shr    $0x8,%ax
f01039f2:	ba a1 00 00 00       	mov    $0xa1,%edx
f01039f7:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f01039f8:	83 ec 0c             	sub    $0xc,%esp
f01039fb:	68 8c 7c 10 f0       	push   $0xf0107c8c
f0103a00:	e8 1b 01 00 00       	call   f0103b20 <cprintf>
f0103a05:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103a08:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103a0d:	0f b7 f6             	movzwl %si,%esi
f0103a10:	f7 d6                	not    %esi
f0103a12:	0f a3 de             	bt     %ebx,%esi
f0103a15:	73 11                	jae    f0103a28 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f0103a17:	83 ec 08             	sub    $0x8,%esp
f0103a1a:	53                   	push   %ebx
f0103a1b:	68 9b 81 10 f0       	push   $0xf010819b
f0103a20:	e8 fb 00 00 00       	call   f0103b20 <cprintf>
f0103a25:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103a28:	83 c3 01             	add    $0x1,%ebx
f0103a2b:	83 fb 10             	cmp    $0x10,%ebx
f0103a2e:	75 e2                	jne    f0103a12 <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103a30:	83 ec 0c             	sub    $0xc,%esp
f0103a33:	68 da 80 10 f0       	push   $0xf01080da
f0103a38:	e8 e3 00 00 00       	call   f0103b20 <cprintf>
f0103a3d:	83 c4 10             	add    $0x10,%esp
}
f0103a40:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103a43:	5b                   	pop    %ebx
f0103a44:	5e                   	pop    %esi
f0103a45:	5d                   	pop    %ebp
f0103a46:	c3                   	ret    

f0103a47 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0103a47:	c6 05 58 62 21 f0 01 	movb   $0x1,0xf0216258
f0103a4e:	ba 21 00 00 00       	mov    $0x21,%edx
f0103a53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103a58:	ee                   	out    %al,(%dx)
f0103a59:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103a5e:	ee                   	out    %al,(%dx)
f0103a5f:	ba 20 00 00 00       	mov    $0x20,%edx
f0103a64:	b8 11 00 00 00       	mov    $0x11,%eax
f0103a69:	ee                   	out    %al,(%dx)
f0103a6a:	ba 21 00 00 00       	mov    $0x21,%edx
f0103a6f:	b8 20 00 00 00       	mov    $0x20,%eax
f0103a74:	ee                   	out    %al,(%dx)
f0103a75:	b8 04 00 00 00       	mov    $0x4,%eax
f0103a7a:	ee                   	out    %al,(%dx)
f0103a7b:	b8 03 00 00 00       	mov    $0x3,%eax
f0103a80:	ee                   	out    %al,(%dx)
f0103a81:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103a86:	b8 11 00 00 00       	mov    $0x11,%eax
f0103a8b:	ee                   	out    %al,(%dx)
f0103a8c:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103a91:	b8 28 00 00 00       	mov    $0x28,%eax
f0103a96:	ee                   	out    %al,(%dx)
f0103a97:	b8 02 00 00 00       	mov    $0x2,%eax
f0103a9c:	ee                   	out    %al,(%dx)
f0103a9d:	b8 01 00 00 00       	mov    $0x1,%eax
f0103aa2:	ee                   	out    %al,(%dx)
f0103aa3:	ba 20 00 00 00       	mov    $0x20,%edx
f0103aa8:	b8 68 00 00 00       	mov    $0x68,%eax
f0103aad:	ee                   	out    %al,(%dx)
f0103aae:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103ab3:	ee                   	out    %al,(%dx)
f0103ab4:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103ab9:	b8 68 00 00 00       	mov    $0x68,%eax
f0103abe:	ee                   	out    %al,(%dx)
f0103abf:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103ac4:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103ac5:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f0103acc:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103ad0:	74 13                	je     f0103ae5 <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103ad2:	55                   	push   %ebp
f0103ad3:	89 e5                	mov    %esp,%ebp
f0103ad5:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103ad8:	0f b7 c0             	movzwl %ax,%eax
f0103adb:	50                   	push   %eax
f0103adc:	e8 ee fe ff ff       	call   f01039cf <irq_setmask_8259A>
f0103ae1:	83 c4 10             	add    $0x10,%esp
}
f0103ae4:	c9                   	leave  
f0103ae5:	f3 c3                	repz ret 

f0103ae7 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103ae7:	55                   	push   %ebp
f0103ae8:	89 e5                	mov    %esp,%ebp
f0103aea:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103aed:	ff 75 08             	pushl  0x8(%ebp)
f0103af0:	e8 a4 cc ff ff       	call   f0100799 <cputchar>
	*cnt++;
}
f0103af5:	83 c4 10             	add    $0x10,%esp
f0103af8:	c9                   	leave  
f0103af9:	c3                   	ret    

f0103afa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103afa:	55                   	push   %ebp
f0103afb:	89 e5                	mov    %esp,%ebp
f0103afd:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103b00:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103b07:	ff 75 0c             	pushl  0xc(%ebp)
f0103b0a:	ff 75 08             	pushl  0x8(%ebp)
f0103b0d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103b10:	50                   	push   %eax
f0103b11:	68 e7 3a 10 f0       	push   $0xf0103ae7
f0103b16:	e8 40 1a 00 00       	call   f010555b <vprintfmt>
	return cnt;
}
f0103b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103b1e:	c9                   	leave  
f0103b1f:	c3                   	ret    

f0103b20 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103b20:	55                   	push   %ebp
f0103b21:	89 e5                	mov    %esp,%ebp
f0103b23:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103b26:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103b29:	50                   	push   %eax
f0103b2a:	ff 75 08             	pushl  0x8(%ebp)
f0103b2d:	e8 c8 ff ff ff       	call   f0103afa <vcprintf>
	va_end(ap);

	return cnt;
}
f0103b32:	c9                   	leave  
f0103b33:	c3                   	ret    

f0103b34 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103b34:	55                   	push   %ebp
f0103b35:	89 e5                	mov    %esp,%ebp
f0103b37:	57                   	push   %edi
f0103b38:	56                   	push   %esi
f0103b39:	53                   	push   %ebx
f0103b3a:	83 ec 1c             	sub    $0x1c,%esp
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:

	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - (thiscpu->cpu_id * (KSTKSIZE + KSTKGAP));
f0103b3d:	e8 c0 26 00 00       	call   f0106202 <cpunum>
f0103b42:	89 c3                	mov    %eax,%ebx
f0103b44:	e8 b9 26 00 00       	call   f0106202 <cpunum>
f0103b49:	6b d3 74             	imul   $0x74,%ebx,%edx
f0103b4c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b4f:	0f b6 88 20 70 21 f0 	movzbl -0xfde8fe0(%eax),%ecx
f0103b56:	c1 e1 10             	shl    $0x10,%ecx
f0103b59:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
f0103b5e:	29 c8                	sub    %ecx,%eax
f0103b60:	89 82 30 70 21 f0    	mov    %eax,-0xfde8fd0(%edx)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103b66:	e8 97 26 00 00       	call   f0106202 <cpunum>
f0103b6b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b6e:	66 c7 80 34 70 21 f0 	movw   $0x10,-0xfde8fcc(%eax)
f0103b75:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f0103b77:	e8 86 26 00 00       	call   f0106202 <cpunum>
f0103b7c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b7f:	66 c7 80 92 70 21 f0 	movw   $0x68,-0xfde8f6e(%eax)
f0103b86:	68 00 

	uint32_t curr_cpu_gdt_index = GD_TSS0 + ((thiscpu->cpu_id + 1) * 8);
f0103b88:	e8 75 26 00 00       	call   f0106202 <cpunum>
f0103b8d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b90:	0f b6 80 20 70 21 f0 	movzbl -0xfde8fe0(%eax),%eax
f0103b97:	8d 3c c5 30 00 00 00 	lea    0x30(,%eax,8),%edi

	gdt[curr_cpu_gdt_index >> 3] = SEG16
f0103b9e:	89 fb                	mov    %edi,%ebx
f0103ba0:	c1 eb 03             	shr    $0x3,%ebx
f0103ba3:	e8 5a 26 00 00       	call   f0106202 <cpunum>
f0103ba8:	89 c6                	mov    %eax,%esi
f0103baa:	e8 53 26 00 00       	call   f0106202 <cpunum>
f0103baf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103bb2:	e8 4b 26 00 00       	call   f0106202 <cpunum>
f0103bb7:	66 c7 04 dd 40 13 12 	movw   $0x67,-0xfedecc0(,%ebx,8)
f0103bbe:	f0 67 00 
f0103bc1:	6b f6 74             	imul   $0x74,%esi,%esi
f0103bc4:	81 c6 2c 70 21 f0    	add    $0xf021702c,%esi
f0103bca:	66 89 34 dd 42 13 12 	mov    %si,-0xfedecbe(,%ebx,8)
f0103bd1:	f0 
f0103bd2:	6b 55 e4 74          	imul   $0x74,-0x1c(%ebp),%edx
f0103bd6:	81 c2 2c 70 21 f0    	add    $0xf021702c,%edx
f0103bdc:	c1 ea 10             	shr    $0x10,%edx
f0103bdf:	88 14 dd 44 13 12 f0 	mov    %dl,-0xfedecbc(,%ebx,8)
f0103be6:	c6 04 dd 46 13 12 f0 	movb   $0x40,-0xfedecba(,%ebx,8)
f0103bed:	40 
f0103bee:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bf1:	05 2c 70 21 f0       	add    $0xf021702c,%eax
f0103bf6:	c1 e8 18             	shr    $0x18,%eax
f0103bf9:	88 04 dd 47 13 12 f0 	mov    %al,-0xfedecb9(,%ebx,8)
	(STS_T32A, (uint32_t) (&thiscpu->cpu_ts), sizeof(struct Taskstate) - 1, 0);
	gdt[curr_cpu_gdt_index >> 3].sd_s = 0;
f0103c00:	c6 04 dd 45 13 12 f0 	movb   $0x89,-0xfedecbb(,%ebx,8)
f0103c07:	89 
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0103c08:	0f 00 df             	ltr    %di
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f0103c0b:	b8 ac 13 12 f0       	mov    $0xf01213ac,%eax
f0103c10:	0f 01 18             	lidtl  (%eax)
	
	ltr(curr_cpu_gdt_index);

	// Load the IDT
	lidt(&idt_pd);
}
f0103c13:	83 c4 1c             	add    $0x1c,%esp
f0103c16:	5b                   	pop    %ebx
f0103c17:	5e                   	pop    %esi
f0103c18:	5f                   	pop    %edi
f0103c19:	5d                   	pop    %ebp
f0103c1a:	c3                   	ret    

f0103c1b <trap_init>:
}


void
trap_init(void)
{
f0103c1b:	55                   	push   %ebp
f0103c1c:	89 e5                	mov    %esp,%ebp
f0103c1e:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.

	extern void TH_DIVIDE(); 	SETGATE(idt[T_DIVIDE], 0, GD_KT, TH_DIVIDE, 							0); 
f0103c21:	b8 a0 47 10 f0       	mov    $0xf01047a0,%eax
f0103c26:	66 a3 60 62 21 f0    	mov    %ax,0xf0216260
f0103c2c:	66 c7 05 62 62 21 f0 	movw   $0x8,0xf0216262
f0103c33:	08 00 
f0103c35:	c6 05 64 62 21 f0 00 	movb   $0x0,0xf0216264
f0103c3c:	c6 05 65 62 21 f0 8e 	movb   $0x8e,0xf0216265
f0103c43:	c1 e8 10             	shr    $0x10,%eax
f0103c46:	66 a3 66 62 21 f0    	mov    %ax,0xf0216266
	extern void TH_DEBUG(); 	SETGATE(idt[T_DEBUG], 0, GD_KT, TH_DEBUG, 0); 
f0103c4c:	b8 aa 47 10 f0       	mov    $0xf01047aa,%eax
f0103c51:	66 a3 68 62 21 f0    	mov    %ax,0xf0216268
f0103c57:	66 c7 05 6a 62 21 f0 	movw   $0x8,0xf021626a
f0103c5e:	08 00 
f0103c60:	c6 05 6c 62 21 f0 00 	movb   $0x0,0xf021626c
f0103c67:	c6 05 6d 62 21 f0 8e 	movb   $0x8e,0xf021626d
f0103c6e:	c1 e8 10             	shr    $0x10,%eax
f0103c71:	66 a3 6e 62 21 f0    	mov    %ax,0xf021626e
	extern void TH_NMI(); 		SETGATE(idt[T_NMI], 0, GD_KT, TH_NMI, 0); 
f0103c77:	b8 b4 47 10 f0       	mov    $0xf01047b4,%eax
f0103c7c:	66 a3 70 62 21 f0    	mov    %ax,0xf0216270
f0103c82:	66 c7 05 72 62 21 f0 	movw   $0x8,0xf0216272
f0103c89:	08 00 
f0103c8b:	c6 05 74 62 21 f0 00 	movb   $0x0,0xf0216274
f0103c92:	c6 05 75 62 21 f0 8e 	movb   $0x8e,0xf0216275
f0103c99:	c1 e8 10             	shr    $0x10,%eax
f0103c9c:	66 a3 76 62 21 f0    	mov    %ax,0xf0216276
	extern void TH_BRKPT(); 	SETGATE(idt[T_BRKPT], 0, GD_KT, TH_BRKPT, 3); 
f0103ca2:	b8 be 47 10 f0       	mov    $0xf01047be,%eax
f0103ca7:	66 a3 78 62 21 f0    	mov    %ax,0xf0216278
f0103cad:	66 c7 05 7a 62 21 f0 	movw   $0x8,0xf021627a
f0103cb4:	08 00 
f0103cb6:	c6 05 7c 62 21 f0 00 	movb   $0x0,0xf021627c
f0103cbd:	c6 05 7d 62 21 f0 ee 	movb   $0xee,0xf021627d
f0103cc4:	c1 e8 10             	shr    $0x10,%eax
f0103cc7:	66 a3 7e 62 21 f0    	mov    %ax,0xf021627e
	extern void TH_OFLOW(); 	SETGATE(idt[T_OFLOW], 0, GD_KT, TH_OFLOW, 0); 
f0103ccd:	b8 c8 47 10 f0       	mov    $0xf01047c8,%eax
f0103cd2:	66 a3 80 62 21 f0    	mov    %ax,0xf0216280
f0103cd8:	66 c7 05 82 62 21 f0 	movw   $0x8,0xf0216282
f0103cdf:	08 00 
f0103ce1:	c6 05 84 62 21 f0 00 	movb   $0x0,0xf0216284
f0103ce8:	c6 05 85 62 21 f0 8e 	movb   $0x8e,0xf0216285
f0103cef:	c1 e8 10             	shr    $0x10,%eax
f0103cf2:	66 a3 86 62 21 f0    	mov    %ax,0xf0216286
	extern void TH_BOUND(); 	SETGATE(idt[T_BOUND], 0, GD_KT, TH_BOUND, 0); 
f0103cf8:	b8 d2 47 10 f0       	mov    $0xf01047d2,%eax
f0103cfd:	66 a3 88 62 21 f0    	mov    %ax,0xf0216288
f0103d03:	66 c7 05 8a 62 21 f0 	movw   $0x8,0xf021628a
f0103d0a:	08 00 
f0103d0c:	c6 05 8c 62 21 f0 00 	movb   $0x0,0xf021628c
f0103d13:	c6 05 8d 62 21 f0 8e 	movb   $0x8e,0xf021628d
f0103d1a:	c1 e8 10             	shr    $0x10,%eax
f0103d1d:	66 a3 8e 62 21 f0    	mov    %ax,0xf021628e
	extern void TH_ILLOP(); 	SETGATE(idt[T_ILLOP], 0, GD_KT, TH_ILLOP, 0); 
f0103d23:	b8 dc 47 10 f0       	mov    $0xf01047dc,%eax
f0103d28:	66 a3 90 62 21 f0    	mov    %ax,0xf0216290
f0103d2e:	66 c7 05 92 62 21 f0 	movw   $0x8,0xf0216292
f0103d35:	08 00 
f0103d37:	c6 05 94 62 21 f0 00 	movb   $0x0,0xf0216294
f0103d3e:	c6 05 95 62 21 f0 8e 	movb   $0x8e,0xf0216295
f0103d45:	c1 e8 10             	shr    $0x10,%eax
f0103d48:	66 a3 96 62 21 f0    	mov    %ax,0xf0216296
	extern void TH_DEVICE(); 	SETGATE(idt[T_DEVICE], 0, GD_KT, TH_DEVICE, 							0); 
f0103d4e:	b8 e6 47 10 f0       	mov    $0xf01047e6,%eax
f0103d53:	66 a3 98 62 21 f0    	mov    %ax,0xf0216298
f0103d59:	66 c7 05 9a 62 21 f0 	movw   $0x8,0xf021629a
f0103d60:	08 00 
f0103d62:	c6 05 9c 62 21 f0 00 	movb   $0x0,0xf021629c
f0103d69:	c6 05 9d 62 21 f0 8e 	movb   $0x8e,0xf021629d
f0103d70:	c1 e8 10             	shr    $0x10,%eax
f0103d73:	66 a3 9e 62 21 f0    	mov    %ax,0xf021629e
	extern void TH_DBLFLT(); 	SETGATE(idt[T_DBLFLT], 0, GD_KT, TH_DBLFLT, 							0); 
f0103d79:	b8 f0 47 10 f0       	mov    $0xf01047f0,%eax
f0103d7e:	66 a3 a0 62 21 f0    	mov    %ax,0xf02162a0
f0103d84:	66 c7 05 a2 62 21 f0 	movw   $0x8,0xf02162a2
f0103d8b:	08 00 
f0103d8d:	c6 05 a4 62 21 f0 00 	movb   $0x0,0xf02162a4
f0103d94:	c6 05 a5 62 21 f0 8e 	movb   $0x8e,0xf02162a5
f0103d9b:	c1 e8 10             	shr    $0x10,%eax
f0103d9e:	66 a3 a6 62 21 f0    	mov    %ax,0xf02162a6
	extern void TH_TSS(); 		SETGATE(idt[T_TSS], 0, GD_KT, TH_TSS, 0); 
f0103da4:	b8 f8 47 10 f0       	mov    $0xf01047f8,%eax
f0103da9:	66 a3 b0 62 21 f0    	mov    %ax,0xf02162b0
f0103daf:	66 c7 05 b2 62 21 f0 	movw   $0x8,0xf02162b2
f0103db6:	08 00 
f0103db8:	c6 05 b4 62 21 f0 00 	movb   $0x0,0xf02162b4
f0103dbf:	c6 05 b5 62 21 f0 8e 	movb   $0x8e,0xf02162b5
f0103dc6:	c1 e8 10             	shr    $0x10,%eax
f0103dc9:	66 a3 b6 62 21 f0    	mov    %ax,0xf02162b6
	extern void TH_SEGNP(); 	SETGATE(idt[T_SEGNP], 0, GD_KT, TH_SEGNP, 0); 
f0103dcf:	b8 00 48 10 f0       	mov    $0xf0104800,%eax
f0103dd4:	66 a3 b8 62 21 f0    	mov    %ax,0xf02162b8
f0103dda:	66 c7 05 ba 62 21 f0 	movw   $0x8,0xf02162ba
f0103de1:	08 00 
f0103de3:	c6 05 bc 62 21 f0 00 	movb   $0x0,0xf02162bc
f0103dea:	c6 05 bd 62 21 f0 8e 	movb   $0x8e,0xf02162bd
f0103df1:	c1 e8 10             	shr    $0x10,%eax
f0103df4:	66 a3 be 62 21 f0    	mov    %ax,0xf02162be
	extern void TH_STACK(); 	SETGATE(idt[T_STACK], 0, GD_KT, TH_STACK, 0); 
f0103dfa:	b8 08 48 10 f0       	mov    $0xf0104808,%eax
f0103dff:	66 a3 c0 62 21 f0    	mov    %ax,0xf02162c0
f0103e05:	66 c7 05 c2 62 21 f0 	movw   $0x8,0xf02162c2
f0103e0c:	08 00 
f0103e0e:	c6 05 c4 62 21 f0 00 	movb   $0x0,0xf02162c4
f0103e15:	c6 05 c5 62 21 f0 8e 	movb   $0x8e,0xf02162c5
f0103e1c:	c1 e8 10             	shr    $0x10,%eax
f0103e1f:	66 a3 c6 62 21 f0    	mov    %ax,0xf02162c6
	extern void TH_GPFLT(); 	SETGATE(idt[T_GPFLT], 0, GD_KT, TH_GPFLT, 0); 
f0103e25:	b8 10 48 10 f0       	mov    $0xf0104810,%eax
f0103e2a:	66 a3 c8 62 21 f0    	mov    %ax,0xf02162c8
f0103e30:	66 c7 05 ca 62 21 f0 	movw   $0x8,0xf02162ca
f0103e37:	08 00 
f0103e39:	c6 05 cc 62 21 f0 00 	movb   $0x0,0xf02162cc
f0103e40:	c6 05 cd 62 21 f0 8e 	movb   $0x8e,0xf02162cd
f0103e47:	c1 e8 10             	shr    $0x10,%eax
f0103e4a:	66 a3 ce 62 21 f0    	mov    %ax,0xf02162ce
	extern void TH_PGFLT(); 	SETGATE(idt[T_PGFLT], 0, GD_KT, TH_PGFLT, 0); 
f0103e50:	b8 18 48 10 f0       	mov    $0xf0104818,%eax
f0103e55:	66 a3 d0 62 21 f0    	mov    %ax,0xf02162d0
f0103e5b:	66 c7 05 d2 62 21 f0 	movw   $0x8,0xf02162d2
f0103e62:	08 00 
f0103e64:	c6 05 d4 62 21 f0 00 	movb   $0x0,0xf02162d4
f0103e6b:	c6 05 d5 62 21 f0 8e 	movb   $0x8e,0xf02162d5
f0103e72:	c1 e8 10             	shr    $0x10,%eax
f0103e75:	66 a3 d6 62 21 f0    	mov    %ax,0xf02162d6
	extern void TH_FPERR(); 	SETGATE(idt[T_FPERR], 0, GD_KT, TH_FPERR, 0); 
f0103e7b:	b8 20 48 10 f0       	mov    $0xf0104820,%eax
f0103e80:	66 a3 e0 62 21 f0    	mov    %ax,0xf02162e0
f0103e86:	66 c7 05 e2 62 21 f0 	movw   $0x8,0xf02162e2
f0103e8d:	08 00 
f0103e8f:	c6 05 e4 62 21 f0 00 	movb   $0x0,0xf02162e4
f0103e96:	c6 05 e5 62 21 f0 8e 	movb   $0x8e,0xf02162e5
f0103e9d:	c1 e8 10             	shr    $0x10,%eax
f0103ea0:	66 a3 e6 62 21 f0    	mov    %ax,0xf02162e6
	extern void TH_ALIGN(); 	SETGATE(idt[T_ALIGN], 0, GD_KT, TH_ALIGN, 0); 
f0103ea6:	b8 26 48 10 f0       	mov    $0xf0104826,%eax
f0103eab:	66 a3 e8 62 21 f0    	mov    %ax,0xf02162e8
f0103eb1:	66 c7 05 ea 62 21 f0 	movw   $0x8,0xf02162ea
f0103eb8:	08 00 
f0103eba:	c6 05 ec 62 21 f0 00 	movb   $0x0,0xf02162ec
f0103ec1:	c6 05 ed 62 21 f0 8e 	movb   $0x8e,0xf02162ed
f0103ec8:	c1 e8 10             	shr    $0x10,%eax
f0103ecb:	66 a3 ee 62 21 f0    	mov    %ax,0xf02162ee
	extern void TH_MCHK(); 		SETGATE(idt[T_MCHK], 0, GD_KT, TH_MCHK, 0); 
f0103ed1:	b8 2a 48 10 f0       	mov    $0xf010482a,%eax
f0103ed6:	66 a3 f0 62 21 f0    	mov    %ax,0xf02162f0
f0103edc:	66 c7 05 f2 62 21 f0 	movw   $0x8,0xf02162f2
f0103ee3:	08 00 
f0103ee5:	c6 05 f4 62 21 f0 00 	movb   $0x0,0xf02162f4
f0103eec:	c6 05 f5 62 21 f0 8e 	movb   $0x8e,0xf02162f5
f0103ef3:	c1 e8 10             	shr    $0x10,%eax
f0103ef6:	66 a3 f6 62 21 f0    	mov    %ax,0xf02162f6
	extern void TH_SIMDERR(); 	SETGATE(idt[T_SIMDERR], 0, GD_KT, TH_SIMDERR, 							0); 	// prepisat neskor ako interrupt 
f0103efc:	b8 30 48 10 f0       	mov    $0xf0104830,%eax
f0103f01:	66 a3 f8 62 21 f0    	mov    %ax,0xf02162f8
f0103f07:	66 c7 05 fa 62 21 f0 	movw   $0x8,0xf02162fa
f0103f0e:	08 00 
f0103f10:	c6 05 fc 62 21 f0 00 	movb   $0x0,0xf02162fc
f0103f17:	c6 05 fd 62 21 f0 8e 	movb   $0x8e,0xf02162fd
f0103f1e:	c1 e8 10             	shr    $0x10,%eax
f0103f21:	66 a3 fe 62 21 f0    	mov    %ax,0xf02162fe
							// namiesto trapu (neskor)
	extern void TH_SYSCALL(); 	SETGATE(idt[T_SYSCALL], 0, GD_KT, TH_SYSCALL, 							3); 
f0103f27:	b8 36 48 10 f0       	mov    $0xf0104836,%eax
f0103f2c:	66 a3 e0 63 21 f0    	mov    %ax,0xf02163e0
f0103f32:	66 c7 05 e2 63 21 f0 	movw   $0x8,0xf02163e2
f0103f39:	08 00 
f0103f3b:	c6 05 e4 63 21 f0 00 	movb   $0x0,0xf02163e4
f0103f42:	c6 05 e5 63 21 f0 ee 	movb   $0xee,0xf02163e5
f0103f49:	c1 e8 10             	shr    $0x10,%eax
f0103f4c:	66 a3 e6 63 21 f0    	mov    %ax,0xf02163e6

	extern void TH_IRQ_TIMER();	SETGATE(idt[IRQ_OFFSET + 0], 0, GD_KT, TH_IRQ_TIMER, 0);
f0103f52:	b8 3c 48 10 f0       	mov    $0xf010483c,%eax
f0103f57:	66 a3 60 63 21 f0    	mov    %ax,0xf0216360
f0103f5d:	66 c7 05 62 63 21 f0 	movw   $0x8,0xf0216362
f0103f64:	08 00 
f0103f66:	c6 05 64 63 21 f0 00 	movb   $0x0,0xf0216364
f0103f6d:	c6 05 65 63 21 f0 8e 	movb   $0x8e,0xf0216365
f0103f74:	c1 e8 10             	shr    $0x10,%eax
f0103f77:	66 a3 66 63 21 f0    	mov    %ax,0xf0216366
	extern void TH_IRQ_KBD();	SETGATE(idt[IRQ_OFFSET + 1], 0, GD_KT, TH_IRQ_KBD, 0);
f0103f7d:	b8 42 48 10 f0       	mov    $0xf0104842,%eax
f0103f82:	66 a3 68 63 21 f0    	mov    %ax,0xf0216368
f0103f88:	66 c7 05 6a 63 21 f0 	movw   $0x8,0xf021636a
f0103f8f:	08 00 
f0103f91:	c6 05 6c 63 21 f0 00 	movb   $0x0,0xf021636c
f0103f98:	c6 05 6d 63 21 f0 8e 	movb   $0x8e,0xf021636d
f0103f9f:	c1 e8 10             	shr    $0x10,%eax
f0103fa2:	66 a3 6e 63 21 f0    	mov    %ax,0xf021636e
	extern void TH_IRQ_2();		SETGATE(idt[IRQ_OFFSET + 2], 0, GD_KT, TH_IRQ_2, 0);
f0103fa8:	b8 48 48 10 f0       	mov    $0xf0104848,%eax
f0103fad:	66 a3 70 63 21 f0    	mov    %ax,0xf0216370
f0103fb3:	66 c7 05 72 63 21 f0 	movw   $0x8,0xf0216372
f0103fba:	08 00 
f0103fbc:	c6 05 74 63 21 f0 00 	movb   $0x0,0xf0216374
f0103fc3:	c6 05 75 63 21 f0 8e 	movb   $0x8e,0xf0216375
f0103fca:	c1 e8 10             	shr    $0x10,%eax
f0103fcd:	66 a3 76 63 21 f0    	mov    %ax,0xf0216376
	extern void TH_IRQ_3();		SETGATE(idt[IRQ_OFFSET + 3], 0, GD_KT, TH_IRQ_3, 0);
f0103fd3:	b8 4e 48 10 f0       	mov    $0xf010484e,%eax
f0103fd8:	66 a3 78 63 21 f0    	mov    %ax,0xf0216378
f0103fde:	66 c7 05 7a 63 21 f0 	movw   $0x8,0xf021637a
f0103fe5:	08 00 
f0103fe7:	c6 05 7c 63 21 f0 00 	movb   $0x0,0xf021637c
f0103fee:	c6 05 7d 63 21 f0 8e 	movb   $0x8e,0xf021637d
f0103ff5:	c1 e8 10             	shr    $0x10,%eax
f0103ff8:	66 a3 7e 63 21 f0    	mov    %ax,0xf021637e
	extern void TH_IRQ_SERIAL();	SETGATE(idt[IRQ_OFFSET + 4], 0, GD_KT, TH_IRQ_SERIAL, 0);
f0103ffe:	b8 54 48 10 f0       	mov    $0xf0104854,%eax
f0104003:	66 a3 80 63 21 f0    	mov    %ax,0xf0216380
f0104009:	66 c7 05 82 63 21 f0 	movw   $0x8,0xf0216382
f0104010:	08 00 
f0104012:	c6 05 84 63 21 f0 00 	movb   $0x0,0xf0216384
f0104019:	c6 05 85 63 21 f0 8e 	movb   $0x8e,0xf0216385
f0104020:	c1 e8 10             	shr    $0x10,%eax
f0104023:	66 a3 86 63 21 f0    	mov    %ax,0xf0216386
	extern void TH_IRQ_5();		SETGATE(idt[IRQ_OFFSET + 5], 0, GD_KT, TH_IRQ_5, 0);
f0104029:	b8 5a 48 10 f0       	mov    $0xf010485a,%eax
f010402e:	66 a3 88 63 21 f0    	mov    %ax,0xf0216388
f0104034:	66 c7 05 8a 63 21 f0 	movw   $0x8,0xf021638a
f010403b:	08 00 
f010403d:	c6 05 8c 63 21 f0 00 	movb   $0x0,0xf021638c
f0104044:	c6 05 8d 63 21 f0 8e 	movb   $0x8e,0xf021638d
f010404b:	c1 e8 10             	shr    $0x10,%eax
f010404e:	66 a3 8e 63 21 f0    	mov    %ax,0xf021638e
	extern void TH_IRQ_6();		SETGATE(idt[IRQ_OFFSET + 6], 0, GD_KT, TH_IRQ_6, 0);
f0104054:	b8 60 48 10 f0       	mov    $0xf0104860,%eax
f0104059:	66 a3 90 63 21 f0    	mov    %ax,0xf0216390
f010405f:	66 c7 05 92 63 21 f0 	movw   $0x8,0xf0216392
f0104066:	08 00 
f0104068:	c6 05 94 63 21 f0 00 	movb   $0x0,0xf0216394
f010406f:	c6 05 95 63 21 f0 8e 	movb   $0x8e,0xf0216395
f0104076:	c1 e8 10             	shr    $0x10,%eax
f0104079:	66 a3 96 63 21 f0    	mov    %ax,0xf0216396
	extern void TH_IRQ_SPURIOUS();	SETGATE(idt[IRQ_OFFSET + 7], 0, GD_KT, TH_IRQ_SPURIOUS, 0);
f010407f:	b8 66 48 10 f0       	mov    $0xf0104866,%eax
f0104084:	66 a3 98 63 21 f0    	mov    %ax,0xf0216398
f010408a:	66 c7 05 9a 63 21 f0 	movw   $0x8,0xf021639a
f0104091:	08 00 
f0104093:	c6 05 9c 63 21 f0 00 	movb   $0x0,0xf021639c
f010409a:	c6 05 9d 63 21 f0 8e 	movb   $0x8e,0xf021639d
f01040a1:	c1 e8 10             	shr    $0x10,%eax
f01040a4:	66 a3 9e 63 21 f0    	mov    %ax,0xf021639e
	extern void TH_IRQ_8();		SETGATE(idt[IRQ_OFFSET + 8], 0, GD_KT, TH_IRQ_8, 0);
f01040aa:	b8 6c 48 10 f0       	mov    $0xf010486c,%eax
f01040af:	66 a3 a0 63 21 f0    	mov    %ax,0xf02163a0
f01040b5:	66 c7 05 a2 63 21 f0 	movw   $0x8,0xf02163a2
f01040bc:	08 00 
f01040be:	c6 05 a4 63 21 f0 00 	movb   $0x0,0xf02163a4
f01040c5:	c6 05 a5 63 21 f0 8e 	movb   $0x8e,0xf02163a5
f01040cc:	c1 e8 10             	shr    $0x10,%eax
f01040cf:	66 a3 a6 63 21 f0    	mov    %ax,0xf02163a6
	extern void TH_IRQ_9();		SETGATE(idt[IRQ_OFFSET + 9], 0, GD_KT, TH_IRQ_9, 0);
f01040d5:	b8 72 48 10 f0       	mov    $0xf0104872,%eax
f01040da:	66 a3 a8 63 21 f0    	mov    %ax,0xf02163a8
f01040e0:	66 c7 05 aa 63 21 f0 	movw   $0x8,0xf02163aa
f01040e7:	08 00 
f01040e9:	c6 05 ac 63 21 f0 00 	movb   $0x0,0xf02163ac
f01040f0:	c6 05 ad 63 21 f0 8e 	movb   $0x8e,0xf02163ad
f01040f7:	c1 e8 10             	shr    $0x10,%eax
f01040fa:	66 a3 ae 63 21 f0    	mov    %ax,0xf02163ae
	extern void TH_IRQ_10();	SETGATE(idt[IRQ_OFFSET + 10], 0, GD_KT, TH_IRQ_10, 0);
f0104100:	b8 78 48 10 f0       	mov    $0xf0104878,%eax
f0104105:	66 a3 b0 63 21 f0    	mov    %ax,0xf02163b0
f010410b:	66 c7 05 b2 63 21 f0 	movw   $0x8,0xf02163b2
f0104112:	08 00 
f0104114:	c6 05 b4 63 21 f0 00 	movb   $0x0,0xf02163b4
f010411b:	c6 05 b5 63 21 f0 8e 	movb   $0x8e,0xf02163b5
f0104122:	c1 e8 10             	shr    $0x10,%eax
f0104125:	66 a3 b6 63 21 f0    	mov    %ax,0xf02163b6
	extern void TH_IRQ_11();	SETGATE(idt[IRQ_OFFSET + 11], 0, GD_KT, TH_IRQ_11, 0);
f010412b:	b8 7e 48 10 f0       	mov    $0xf010487e,%eax
f0104130:	66 a3 b8 63 21 f0    	mov    %ax,0xf02163b8
f0104136:	66 c7 05 ba 63 21 f0 	movw   $0x8,0xf02163ba
f010413d:	08 00 
f010413f:	c6 05 bc 63 21 f0 00 	movb   $0x0,0xf02163bc
f0104146:	c6 05 bd 63 21 f0 8e 	movb   $0x8e,0xf02163bd
f010414d:	c1 e8 10             	shr    $0x10,%eax
f0104150:	66 a3 be 63 21 f0    	mov    %ax,0xf02163be
	extern void TH_IRQ_12();	SETGATE(idt[IRQ_OFFSET + 12], 0, GD_KT, TH_IRQ_12, 0);
f0104156:	b8 84 48 10 f0       	mov    $0xf0104884,%eax
f010415b:	66 a3 c0 63 21 f0    	mov    %ax,0xf02163c0
f0104161:	66 c7 05 c2 63 21 f0 	movw   $0x8,0xf02163c2
f0104168:	08 00 
f010416a:	c6 05 c4 63 21 f0 00 	movb   $0x0,0xf02163c4
f0104171:	c6 05 c5 63 21 f0 8e 	movb   $0x8e,0xf02163c5
f0104178:	c1 e8 10             	shr    $0x10,%eax
f010417b:	66 a3 c6 63 21 f0    	mov    %ax,0xf02163c6
	extern void TH_IRQ_13();	SETGATE(idt[IRQ_OFFSET + 13], 0, GD_KT, TH_IRQ_13, 0);
f0104181:	b8 8a 48 10 f0       	mov    $0xf010488a,%eax
f0104186:	66 a3 c8 63 21 f0    	mov    %ax,0xf02163c8
f010418c:	66 c7 05 ca 63 21 f0 	movw   $0x8,0xf02163ca
f0104193:	08 00 
f0104195:	c6 05 cc 63 21 f0 00 	movb   $0x0,0xf02163cc
f010419c:	c6 05 cd 63 21 f0 8e 	movb   $0x8e,0xf02163cd
f01041a3:	c1 e8 10             	shr    $0x10,%eax
f01041a6:	66 a3 ce 63 21 f0    	mov    %ax,0xf02163ce
	extern void TH_IRQ_IDE();	SETGATE(idt[IRQ_OFFSET + 14], 0, GD_KT, TH_IRQ_IDE, 0);
f01041ac:	b8 90 48 10 f0       	mov    $0xf0104890,%eax
f01041b1:	66 a3 d0 63 21 f0    	mov    %ax,0xf02163d0
f01041b7:	66 c7 05 d2 63 21 f0 	movw   $0x8,0xf02163d2
f01041be:	08 00 
f01041c0:	c6 05 d4 63 21 f0 00 	movb   $0x0,0xf02163d4
f01041c7:	c6 05 d5 63 21 f0 8e 	movb   $0x8e,0xf02163d5
f01041ce:	c1 e8 10             	shr    $0x10,%eax
f01041d1:	66 a3 d6 63 21 f0    	mov    %ax,0xf02163d6
	extern void TH_IRQ_15();	SETGATE(idt[IRQ_OFFSET + 15], 0, GD_KT, TH_IRQ_15, 0);
f01041d7:	b8 96 48 10 f0       	mov    $0xf0104896,%eax
f01041dc:	66 a3 d8 63 21 f0    	mov    %ax,0xf02163d8
f01041e2:	66 c7 05 da 63 21 f0 	movw   $0x8,0xf02163da
f01041e9:	08 00 
f01041eb:	c6 05 dc 63 21 f0 00 	movb   $0x0,0xf02163dc
f01041f2:	c6 05 dd 63 21 f0 8e 	movb   $0x8e,0xf02163dd
f01041f9:	c1 e8 10             	shr    $0x10,%eax
f01041fc:	66 a3 de 63 21 f0    	mov    %ax,0xf02163de

	// Per-CPU setup 
	trap_init_percpu();
f0104202:	e8 2d f9 ff ff       	call   f0103b34 <trap_init_percpu>
}
f0104207:	c9                   	leave  
f0104208:	c3                   	ret    

f0104209 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0104209:	55                   	push   %ebp
f010420a:	89 e5                	mov    %esp,%ebp
f010420c:	53                   	push   %ebx
f010420d:	83 ec 0c             	sub    $0xc,%esp
f0104210:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0104213:	ff 33                	pushl  (%ebx)
f0104215:	68 a0 7c 10 f0       	push   $0xf0107ca0
f010421a:	e8 01 f9 ff ff       	call   f0103b20 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f010421f:	83 c4 08             	add    $0x8,%esp
f0104222:	ff 73 04             	pushl  0x4(%ebx)
f0104225:	68 af 7c 10 f0       	push   $0xf0107caf
f010422a:	e8 f1 f8 ff ff       	call   f0103b20 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010422f:	83 c4 08             	add    $0x8,%esp
f0104232:	ff 73 08             	pushl  0x8(%ebx)
f0104235:	68 be 7c 10 f0       	push   $0xf0107cbe
f010423a:	e8 e1 f8 ff ff       	call   f0103b20 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f010423f:	83 c4 08             	add    $0x8,%esp
f0104242:	ff 73 0c             	pushl  0xc(%ebx)
f0104245:	68 cd 7c 10 f0       	push   $0xf0107ccd
f010424a:	e8 d1 f8 ff ff       	call   f0103b20 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f010424f:	83 c4 08             	add    $0x8,%esp
f0104252:	ff 73 10             	pushl  0x10(%ebx)
f0104255:	68 dc 7c 10 f0       	push   $0xf0107cdc
f010425a:	e8 c1 f8 ff ff       	call   f0103b20 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f010425f:	83 c4 08             	add    $0x8,%esp
f0104262:	ff 73 14             	pushl  0x14(%ebx)
f0104265:	68 eb 7c 10 f0       	push   $0xf0107ceb
f010426a:	e8 b1 f8 ff ff       	call   f0103b20 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010426f:	83 c4 08             	add    $0x8,%esp
f0104272:	ff 73 18             	pushl  0x18(%ebx)
f0104275:	68 fa 7c 10 f0       	push   $0xf0107cfa
f010427a:	e8 a1 f8 ff ff       	call   f0103b20 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010427f:	83 c4 08             	add    $0x8,%esp
f0104282:	ff 73 1c             	pushl  0x1c(%ebx)
f0104285:	68 09 7d 10 f0       	push   $0xf0107d09
f010428a:	e8 91 f8 ff ff       	call   f0103b20 <cprintf>
}
f010428f:	83 c4 10             	add    $0x10,%esp
f0104292:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104295:	c9                   	leave  
f0104296:	c3                   	ret    

f0104297 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0104297:	55                   	push   %ebp
f0104298:	89 e5                	mov    %esp,%ebp
f010429a:	56                   	push   %esi
f010429b:	53                   	push   %ebx
f010429c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f010429f:	e8 5e 1f 00 00       	call   f0106202 <cpunum>
f01042a4:	83 ec 04             	sub    $0x4,%esp
f01042a7:	50                   	push   %eax
f01042a8:	53                   	push   %ebx
f01042a9:	68 6d 7d 10 f0       	push   $0xf0107d6d
f01042ae:	e8 6d f8 ff ff       	call   f0103b20 <cprintf>
	print_regs(&tf->tf_regs);
f01042b3:	89 1c 24             	mov    %ebx,(%esp)
f01042b6:	e8 4e ff ff ff       	call   f0104209 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01042bb:	83 c4 08             	add    $0x8,%esp
f01042be:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01042c2:	50                   	push   %eax
f01042c3:	68 8b 7d 10 f0       	push   $0xf0107d8b
f01042c8:	e8 53 f8 ff ff       	call   f0103b20 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01042cd:	83 c4 08             	add    $0x8,%esp
f01042d0:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01042d4:	50                   	push   %eax
f01042d5:	68 9e 7d 10 f0       	push   $0xf0107d9e
f01042da:	e8 41 f8 ff ff       	call   f0103b20 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01042df:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f01042e2:	83 c4 10             	add    $0x10,%esp
f01042e5:	83 f8 13             	cmp    $0x13,%eax
f01042e8:	77 09                	ja     f01042f3 <print_trapframe+0x5c>
		return excnames[trapno];
f01042ea:	8b 14 85 40 80 10 f0 	mov    -0xfef7fc0(,%eax,4),%edx
f01042f1:	eb 1f                	jmp    f0104312 <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f01042f3:	83 f8 30             	cmp    $0x30,%eax
f01042f6:	74 15                	je     f010430d <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01042f8:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f01042fb:	83 fa 10             	cmp    $0x10,%edx
f01042fe:	b9 37 7d 10 f0       	mov    $0xf0107d37,%ecx
f0104303:	ba 24 7d 10 f0       	mov    $0xf0107d24,%edx
f0104308:	0f 43 d1             	cmovae %ecx,%edx
f010430b:	eb 05                	jmp    f0104312 <print_trapframe+0x7b>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f010430d:	ba 18 7d 10 f0       	mov    $0xf0107d18,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104312:	83 ec 04             	sub    $0x4,%esp
f0104315:	52                   	push   %edx
f0104316:	50                   	push   %eax
f0104317:	68 b1 7d 10 f0       	push   $0xf0107db1
f010431c:	e8 ff f7 ff ff       	call   f0103b20 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104321:	83 c4 10             	add    $0x10,%esp
f0104324:	3b 1d 60 6a 21 f0    	cmp    0xf0216a60,%ebx
f010432a:	75 1a                	jne    f0104346 <print_trapframe+0xaf>
f010432c:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104330:	75 14                	jne    f0104346 <print_trapframe+0xaf>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0104332:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104335:	83 ec 08             	sub    $0x8,%esp
f0104338:	50                   	push   %eax
f0104339:	68 c3 7d 10 f0       	push   $0xf0107dc3
f010433e:	e8 dd f7 ff ff       	call   f0103b20 <cprintf>
f0104343:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0104346:	83 ec 08             	sub    $0x8,%esp
f0104349:	ff 73 2c             	pushl  0x2c(%ebx)
f010434c:	68 d2 7d 10 f0       	push   $0xf0107dd2
f0104351:	e8 ca f7 ff ff       	call   f0103b20 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104356:	83 c4 10             	add    $0x10,%esp
f0104359:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010435d:	75 49                	jne    f01043a8 <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f010435f:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0104362:	89 c2                	mov    %eax,%edx
f0104364:	83 e2 01             	and    $0x1,%edx
f0104367:	ba 51 7d 10 f0       	mov    $0xf0107d51,%edx
f010436c:	b9 46 7d 10 f0       	mov    $0xf0107d46,%ecx
f0104371:	0f 44 ca             	cmove  %edx,%ecx
f0104374:	89 c2                	mov    %eax,%edx
f0104376:	83 e2 02             	and    $0x2,%edx
f0104379:	ba 63 7d 10 f0       	mov    $0xf0107d63,%edx
f010437e:	be 5d 7d 10 f0       	mov    $0xf0107d5d,%esi
f0104383:	0f 45 d6             	cmovne %esi,%edx
f0104386:	83 e0 04             	and    $0x4,%eax
f0104389:	be ca 7e 10 f0       	mov    $0xf0107eca,%esi
f010438e:	b8 68 7d 10 f0       	mov    $0xf0107d68,%eax
f0104393:	0f 44 c6             	cmove  %esi,%eax
f0104396:	51                   	push   %ecx
f0104397:	52                   	push   %edx
f0104398:	50                   	push   %eax
f0104399:	68 e0 7d 10 f0       	push   $0xf0107de0
f010439e:	e8 7d f7 ff ff       	call   f0103b20 <cprintf>
f01043a3:	83 c4 10             	add    $0x10,%esp
f01043a6:	eb 10                	jmp    f01043b8 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01043a8:	83 ec 0c             	sub    $0xc,%esp
f01043ab:	68 da 80 10 f0       	push   $0xf01080da
f01043b0:	e8 6b f7 ff ff       	call   f0103b20 <cprintf>
f01043b5:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01043b8:	83 ec 08             	sub    $0x8,%esp
f01043bb:	ff 73 30             	pushl  0x30(%ebx)
f01043be:	68 ef 7d 10 f0       	push   $0xf0107def
f01043c3:	e8 58 f7 ff ff       	call   f0103b20 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01043c8:	83 c4 08             	add    $0x8,%esp
f01043cb:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01043cf:	50                   	push   %eax
f01043d0:	68 fe 7d 10 f0       	push   $0xf0107dfe
f01043d5:	e8 46 f7 ff ff       	call   f0103b20 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01043da:	83 c4 08             	add    $0x8,%esp
f01043dd:	ff 73 38             	pushl  0x38(%ebx)
f01043e0:	68 11 7e 10 f0       	push   $0xf0107e11
f01043e5:	e8 36 f7 ff ff       	call   f0103b20 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01043ea:	83 c4 10             	add    $0x10,%esp
f01043ed:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01043f1:	74 25                	je     f0104418 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01043f3:	83 ec 08             	sub    $0x8,%esp
f01043f6:	ff 73 3c             	pushl  0x3c(%ebx)
f01043f9:	68 20 7e 10 f0       	push   $0xf0107e20
f01043fe:	e8 1d f7 ff ff       	call   f0103b20 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104403:	83 c4 08             	add    $0x8,%esp
f0104406:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010440a:	50                   	push   %eax
f010440b:	68 2f 7e 10 f0       	push   $0xf0107e2f
f0104410:	e8 0b f7 ff ff       	call   f0103b20 <cprintf>
f0104415:	83 c4 10             	add    $0x10,%esp
	}
}
f0104418:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010441b:	5b                   	pop    %ebx
f010441c:	5e                   	pop    %esi
f010441d:	5d                   	pop    %ebp
f010441e:	c3                   	ret    

f010441f <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010441f:	55                   	push   %ebp
f0104420:	89 e5                	mov    %esp,%ebp
f0104422:	57                   	push   %edi
f0104423:	56                   	push   %esi
f0104424:	53                   	push   %ebx
f0104425:	83 ec 0c             	sub    $0xc,%esp
f0104428:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010442b:	0f 20 d6             	mov    %cr2,%esi

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.

	if ((tf->tf_cs & 3) == 0) {
f010442e:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104432:	75 17                	jne    f010444b <page_fault_handler+0x2c>
		panic("kernel page fault\n");
f0104434:	83 ec 04             	sub    $0x4,%esp
f0104437:	68 42 7e 10 f0       	push   $0xf0107e42
f010443c:	68 5f 01 00 00       	push   $0x15f
f0104441:	68 55 7e 10 f0       	push   $0xf0107e55
f0104446:	e8 f5 bb ff ff       	call   f0100040 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	if (curenv->env_pgfault_upcall) {
f010444b:	e8 b2 1d 00 00       	call   f0106202 <cpunum>
f0104450:	6b c0 74             	imul   $0x74,%eax,%eax
f0104453:	8b 80 28 70 21 f0    	mov    -0xfde8fd8(%eax),%eax
f0104459:	83 78 70 00          	cmpl   $0x0,0x70(%eax)
f010445d:	0f 84 a7 00 00 00    	je     f010450a <page_fault_handler+0xeb>
		struct UTrapframe *utf;
		uintptr_t utf_va;
		if ((tf->tf_esp >= UXSTACKTOP - PGSIZE) && 
f0104463:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104466:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
		    (tf->tf_esp < UXSTACKTOP)) {
			utf_va = tf->tf_esp - sizeof(struct UTrapframe) - 4;
f010446c:	83 e8 38             	sub    $0x38,%eax
f010446f:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104475:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f010447a:	0f 46 d0             	cmovbe %eax,%edx
f010447d:	89 d7                	mov    %edx,%edi
		} else {
			utf_va = UXSTACKTOP - sizeof(struct UTrapframe);
		}
	
		user_mem_assert(curenv, (void*)utf_va, sizeof(struct UTrapframe), 					PTE_W);
f010447f:	e8 7e 1d 00 00       	call   f0106202 <cpunum>
f0104484:	6a 02                	push   $0x2
f0104486:	6a 34                	push   $0x34
f0104488:	57                   	push   %edi
f0104489:	6b c0 74             	imul   $0x74,%eax,%eax
f010448c:	ff b0 28 70 21 f0    	pushl  -0xfde8fd8(%eax)
f0104492:	e8 18 eb ff ff       	call   f0102faf <user_mem_assert>
		utf = (struct UTrapframe*) utf_va;

		utf->utf_fault_va = fault_va;
f0104497:	89 fa                	mov    %edi,%edx
f0104499:	89 37                	mov    %esi,(%edi)
		utf->utf_err = tf->tf_err;
f010449b:	8b 43 2c             	mov    0x2c(%ebx),%eax
f010449e:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_regs = tf->tf_regs;
f01044a1:	8d 7f 08             	lea    0x8(%edi),%edi
f01044a4:	b9 08 00 00 00       	mov    $0x8,%ecx
f01044a9:	89 de                	mov    %ebx,%esi
f01044ab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eip = tf->tf_eip;
f01044ad:	8b 43 30             	mov    0x30(%ebx),%eax
f01044b0:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags = tf->tf_eflags;
f01044b3:	8b 43 38             	mov    0x38(%ebx),%eax
f01044b6:	89 d7                	mov    %edx,%edi
f01044b8:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;
f01044bb:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01044be:	89 42 30             	mov    %eax,0x30(%edx)

		curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f01044c1:	e8 3c 1d 00 00       	call   f0106202 <cpunum>
f01044c6:	6b c0 74             	imul   $0x74,%eax,%eax
f01044c9:	8b 98 28 70 21 f0    	mov    -0xfde8fd8(%eax),%ebx
f01044cf:	e8 2e 1d 00 00       	call   f0106202 <cpunum>
f01044d4:	6b c0 74             	imul   $0x74,%eax,%eax
f01044d7:	8b 80 28 70 21 f0    	mov    -0xfde8fd8(%eax),%eax
f01044dd:	8b 40 70             	mov    0x70(%eax),%eax
f01044e0:	89 43 3c             	mov    %eax,0x3c(%ebx)
		curenv->env_tf.tf_esp = utf_va;
f01044e3:	e8 1a 1d 00 00       	call   f0106202 <cpunum>
f01044e8:	6b c0 74             	imul   $0x74,%eax,%eax
f01044eb:	8b 80 28 70 21 f0    	mov    -0xfde8fd8(%eax),%eax
f01044f1:	89 78 48             	mov    %edi,0x48(%eax)
		env_run(curenv);
f01044f4:	e8 09 1d 00 00       	call   f0106202 <cpunum>
f01044f9:	83 c4 04             	add    $0x4,%esp
f01044fc:	6b c0 74             	imul   $0x74,%eax,%eax
f01044ff:	ff b0 28 70 21 f0    	pushl  -0xfde8fd8(%eax)
f0104505:	e8 e0 f1 ff ff       	call   f01036ea <env_run>
	}


	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010450a:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f010450d:	e8 f0 1c 00 00       	call   f0106202 <cpunum>
		env_run(curenv);
	}


	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104512:	57                   	push   %edi
f0104513:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0104514:	6b c0 74             	imul   $0x74,%eax,%eax
		env_run(curenv);
	}


	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104517:	8b 80 28 70 21 f0    	mov    -0xfde8fd8(%eax),%eax
f010451d:	ff 70 54             	pushl  0x54(%eax)
f0104520:	68 14 80 10 f0       	push   $0xf0108014
f0104525:	e8 f6 f5 ff ff       	call   f0103b20 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f010452a:	89 1c 24             	mov    %ebx,(%esp)
f010452d:	e8 65 fd ff ff       	call   f0104297 <print_trapframe>
	env_destroy(curenv);
f0104532:	e8 cb 1c 00 00       	call   f0106202 <cpunum>
f0104537:	83 c4 04             	add    $0x4,%esp
f010453a:	6b c0 74             	imul   $0x74,%eax,%eax
f010453d:	ff b0 28 70 21 f0    	pushl  -0xfde8fd8(%eax)
f0104543:	e8 fa f2 ff ff       	call   f0103842 <env_destroy>
}
f0104548:	83 c4 10             	add    $0x10,%esp
f010454b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010454e:	5b                   	pop    %ebx
f010454f:	5e                   	pop    %esi
f0104550:	5f                   	pop    %edi
f0104551:	5d                   	pop    %ebp
f0104552:	c3                   	ret    

f0104553 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104553:	55                   	push   %ebp
f0104554:	89 e5                	mov    %esp,%ebp
f0104556:	57                   	push   %edi
f0104557:	56                   	push   %esi
f0104558:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f010455b:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f010455c:	83 3d 80 6e 21 f0 00 	cmpl   $0x0,0xf0216e80
f0104563:	74 01                	je     f0104566 <trap+0x13>
		asm volatile("hlt");
f0104565:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104566:	e8 97 1c 00 00       	call   f0106202 <cpunum>
f010456b:	6b d0 74             	imul   $0x74,%eax,%edx
f010456e:	81 c2 20 70 21 f0    	add    $0xf0217020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104574:	b8 01 00 00 00       	mov    $0x1,%eax
f0104579:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010457d:	83 f8 02             	cmp    $0x2,%eax
f0104580:	75 10                	jne    f0104592 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104582:	83 ec 0c             	sub    $0xc,%esp
f0104585:	68 c0 13 12 f0       	push   $0xf01213c0
f010458a:	e8 e1 1e 00 00       	call   f0106470 <spin_lock>
f010458f:	83 c4 10             	add    $0x10,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104592:	9c                   	pushf  
f0104593:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104594:	f6 c4 02             	test   $0x2,%ah
f0104597:	74 19                	je     f01045b2 <trap+0x5f>
f0104599:	68 61 7e 10 f0       	push   $0xf0107e61
f010459e:	68 d4 77 10 f0       	push   $0xf01077d4
f01045a3:	68 26 01 00 00       	push   $0x126
f01045a8:	68 55 7e 10 f0       	push   $0xf0107e55
f01045ad:	e8 8e ba ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f01045b2:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01045b6:	83 e0 03             	and    $0x3,%eax
f01045b9:	66 83 f8 03          	cmp    $0x3,%ax
f01045bd:	0f 85 a4 00 00 00    	jne    f0104667 <trap+0x114>
f01045c3:	83 ec 0c             	sub    $0xc,%esp
f01045c6:	68 c0 13 12 f0       	push   $0xf01213c0
f01045cb:	e8 a0 1e 00 00       	call   f0106470 <spin_lock>
		// serious kernel work.
		// LAB 4: Your code here.

		lock_kernel();

		assert(curenv);
f01045d0:	e8 2d 1c 00 00       	call   f0106202 <cpunum>
f01045d5:	6b c0 74             	imul   $0x74,%eax,%eax
f01045d8:	83 c4 10             	add    $0x10,%esp
f01045db:	83 b8 28 70 21 f0 00 	cmpl   $0x0,-0xfde8fd8(%eax)
f01045e2:	75 19                	jne    f01045fd <trap+0xaa>
f01045e4:	68 7a 7e 10 f0       	push   $0xf0107e7a
f01045e9:	68 d4 77 10 f0       	push   $0xf01077d4
f01045ee:	68 30 01 00 00       	push   $0x130
f01045f3:	68 55 7e 10 f0       	push   $0xf0107e55
f01045f8:	e8 43 ba ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01045fd:	e8 00 1c 00 00       	call   f0106202 <cpunum>
f0104602:	6b c0 74             	imul   $0x74,%eax,%eax
f0104605:	8b 80 28 70 21 f0    	mov    -0xfde8fd8(%eax),%eax
f010460b:	83 78 60 01          	cmpl   $0x1,0x60(%eax)
f010460f:	75 2d                	jne    f010463e <trap+0xeb>
			env_free(curenv);
f0104611:	e8 ec 1b 00 00       	call   f0106202 <cpunum>
f0104616:	83 ec 0c             	sub    $0xc,%esp
f0104619:	6b c0 74             	imul   $0x74,%eax,%eax
f010461c:	ff b0 28 70 21 f0    	pushl  -0xfde8fd8(%eax)
f0104622:	e8 df ee ff ff       	call   f0103506 <env_free>
			curenv = NULL;
f0104627:	e8 d6 1b 00 00       	call   f0106202 <cpunum>
f010462c:	6b c0 74             	imul   $0x74,%eax,%eax
f010462f:	c7 80 28 70 21 f0 00 	movl   $0x0,-0xfde8fd8(%eax)
f0104636:	00 00 00 
			sched_yield();
f0104639:	e8 4d 03 00 00       	call   f010498b <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f010463e:	e8 bf 1b 00 00       	call   f0106202 <cpunum>
f0104643:	6b c0 74             	imul   $0x74,%eax,%eax
f0104646:	8b b8 28 70 21 f0    	mov    -0xfde8fd8(%eax),%edi
f010464c:	83 c7 0c             	add    $0xc,%edi
f010464f:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104654:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104656:	e8 a7 1b 00 00       	call   f0106202 <cpunum>
f010465b:	6b c0 74             	imul   $0x74,%eax,%eax
f010465e:	8b b0 28 70 21 f0    	mov    -0xfde8fd8(%eax),%esi
f0104664:	83 c6 0c             	add    $0xc,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104667:	89 35 60 6a 21 f0    	mov    %esi,0xf0216a60
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.

	switch (tf->tf_trapno) {	
f010466d:	8b 46 28             	mov    0x28(%esi),%eax
f0104670:	83 f8 0e             	cmp    $0xe,%eax
f0104673:	74 0c                	je     f0104681 <trap+0x12e>
f0104675:	83 f8 30             	cmp    $0x30,%eax
f0104678:	74 38                	je     f01046b2 <trap+0x15f>
f010467a:	83 f8 03             	cmp    $0x3,%eax
f010467d:	75 57                	jne    f01046d6 <trap+0x183>
f010467f:	eb 11                	jmp    f0104692 <trap+0x13f>
	case T_PGFLT:
		page_fault_handler(tf);
f0104681:	83 ec 0c             	sub    $0xc,%esp
f0104684:	56                   	push   %esi
f0104685:	e8 95 fd ff ff       	call   f010441f <page_fault_handler>
f010468a:	83 c4 10             	add    $0x10,%esp
f010468d:	e9 cd 00 00 00       	jmp    f010475f <trap+0x20c>
		return;
	case T_BRKPT:
		print_trapframe(tf);
f0104692:	83 ec 0c             	sub    $0xc,%esp
f0104695:	56                   	push   %esi
f0104696:	e8 fc fb ff ff       	call   f0104297 <print_trapframe>
		panic("tf->tf_trapno == T_BRKPT\n");
f010469b:	83 c4 0c             	add    $0xc,%esp
f010469e:	68 81 7e 10 f0       	push   $0xf0107e81
f01046a3:	68 e0 00 00 00       	push   $0xe0
f01046a8:	68 55 7e 10 f0       	push   $0xf0107e55
f01046ad:	e8 8e b9 ff ff       	call   f0100040 <_panic>
		return;
	case T_SYSCALL:
		tf->tf_regs.reg_eax = syscall(
f01046b2:	83 ec 08             	sub    $0x8,%esp
f01046b5:	ff 76 04             	pushl  0x4(%esi)
f01046b8:	ff 36                	pushl  (%esi)
f01046ba:	ff 76 10             	pushl  0x10(%esi)
f01046bd:	ff 76 18             	pushl  0x18(%esi)
f01046c0:	ff 76 14             	pushl  0x14(%esi)
f01046c3:	ff 76 1c             	pushl  0x1c(%esi)
f01046c6:	e8 e6 03 00 00       	call   f0104ab1 <syscall>
f01046cb:	89 46 1c             	mov    %eax,0x1c(%esi)
f01046ce:	83 c4 20             	add    $0x20,%esp
f01046d1:	e9 89 00 00 00       	jmp    f010475f <trap+0x20c>
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01046d6:	83 f8 27             	cmp    $0x27,%eax
f01046d9:	75 1a                	jne    f01046f5 <trap+0x1a2>
		cprintf("Spurious interrupt on irq 7\n");
f01046db:	83 ec 0c             	sub    $0xc,%esp
f01046de:	68 9b 7e 10 f0       	push   $0xf0107e9b
f01046e3:	e8 38 f4 ff ff       	call   f0103b20 <cprintf>
		print_trapframe(tf);
f01046e8:	89 34 24             	mov    %esi,(%esp)
f01046eb:	e8 a7 fb ff ff       	call   f0104297 <print_trapframe>
f01046f0:	83 c4 10             	add    $0x10,%esp
f01046f3:	eb 6a                	jmp    f010475f <trap+0x20c>

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f01046f5:	83 f8 20             	cmp    $0x20,%eax
f01046f8:	75 0a                	jne    f0104704 <trap+0x1b1>
		lapic_eoi();
f01046fa:	e8 4e 1c 00 00       	call   f010634d <lapic_eoi>
		sched_yield();
f01046ff:	e8 87 02 00 00       	call   f010498b <sched_yield>
	}

	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.

	if (tf->tf_trapno == (IRQ_OFFSET + IRQ_KBD)) {
f0104704:	83 f8 21             	cmp    $0x21,%eax
f0104707:	75 07                	jne    f0104710 <trap+0x1bd>
		kbd_intr();
f0104709:	e8 e9 be ff ff       	call   f01005f7 <kbd_intr>
f010470e:	eb 4f                	jmp    f010475f <trap+0x20c>
		return;
	}

	if (tf->tf_trapno == (IRQ_OFFSET + IRQ_SERIAL)) {
f0104710:	83 f8 24             	cmp    $0x24,%eax
f0104713:	75 07                	jne    f010471c <trap+0x1c9>
		serial_intr();
f0104715:	e8 c1 be ff ff       	call   f01005db <serial_intr>
f010471a:	eb 43                	jmp    f010475f <trap+0x20c>
		return;
	}

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f010471c:	83 ec 0c             	sub    $0xc,%esp
f010471f:	56                   	push   %esi
f0104720:	e8 72 fb ff ff       	call   f0104297 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104725:	83 c4 10             	add    $0x10,%esp
f0104728:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010472d:	75 17                	jne    f0104746 <trap+0x1f3>
		panic("unhandled trap in kernel");
f010472f:	83 ec 04             	sub    $0x4,%esp
f0104732:	68 b8 7e 10 f0       	push   $0xf0107eb8
f0104737:	68 0c 01 00 00       	push   $0x10c
f010473c:	68 55 7e 10 f0       	push   $0xf0107e55
f0104741:	e8 fa b8 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104746:	e8 b7 1a 00 00       	call   f0106202 <cpunum>
f010474b:	83 ec 0c             	sub    $0xc,%esp
f010474e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104751:	ff b0 28 70 21 f0    	pushl  -0xfde8fd8(%eax)
f0104757:	e8 e6 f0 ff ff       	call   f0103842 <env_destroy>
f010475c:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f010475f:	e8 9e 1a 00 00       	call   f0106202 <cpunum>
f0104764:	6b c0 74             	imul   $0x74,%eax,%eax
f0104767:	83 b8 28 70 21 f0 00 	cmpl   $0x0,-0xfde8fd8(%eax)
f010476e:	74 2a                	je     f010479a <trap+0x247>
f0104770:	e8 8d 1a 00 00       	call   f0106202 <cpunum>
f0104775:	6b c0 74             	imul   $0x74,%eax,%eax
f0104778:	8b 80 28 70 21 f0    	mov    -0xfde8fd8(%eax),%eax
f010477e:	83 78 60 03          	cmpl   $0x3,0x60(%eax)
f0104782:	75 16                	jne    f010479a <trap+0x247>
		env_run(curenv);
f0104784:	e8 79 1a 00 00       	call   f0106202 <cpunum>
f0104789:	83 ec 0c             	sub    $0xc,%esp
f010478c:	6b c0 74             	imul   $0x74,%eax,%eax
f010478f:	ff b0 28 70 21 f0    	pushl  -0xfde8fd8(%eax)
f0104795:	e8 50 ef ff ff       	call   f01036ea <env_run>
	else
		sched_yield();
f010479a:	e8 ec 01 00 00       	call   f010498b <sched_yield>
f010479f:	90                   	nop

f01047a0 <TH_DIVIDE>:
	.p2align 2
	.globl TRAPHANDLERS
TRAPHANDLERS:
.text

TRAPHANDLER_NOEC(TH_DIVIDE, T_DIVIDE)	// fault
f01047a0:	6a 00                	push   $0x0
f01047a2:	6a 00                	push   $0x0
f01047a4:	e9 f9 00 00 00       	jmp    f01048a2 <_alltraps>
f01047a9:	90                   	nop

f01047aa <TH_DEBUG>:
TRAPHANDLER_NOEC(TH_DEBUG, T_DEBUG)	// fault/trap
f01047aa:	6a 00                	push   $0x0
f01047ac:	6a 01                	push   $0x1
f01047ae:	e9 ef 00 00 00       	jmp    f01048a2 <_alltraps>
f01047b3:	90                   	nop

f01047b4 <TH_NMI>:
TRAPHANDLER_NOEC(TH_NMI, T_NMI)		//
f01047b4:	6a 00                	push   $0x0
f01047b6:	6a 02                	push   $0x2
f01047b8:	e9 e5 00 00 00       	jmp    f01048a2 <_alltraps>
f01047bd:	90                   	nop

f01047be <TH_BRKPT>:
TRAPHANDLER_NOEC(TH_BRKPT, T_BRKPT)	// trap
f01047be:	6a 00                	push   $0x0
f01047c0:	6a 03                	push   $0x3
f01047c2:	e9 db 00 00 00       	jmp    f01048a2 <_alltraps>
f01047c7:	90                   	nop

f01047c8 <TH_OFLOW>:
TRAPHANDLER_NOEC(TH_OFLOW, T_OFLOW)	// trap
f01047c8:	6a 00                	push   $0x0
f01047ca:	6a 04                	push   $0x4
f01047cc:	e9 d1 00 00 00       	jmp    f01048a2 <_alltraps>
f01047d1:	90                   	nop

f01047d2 <TH_BOUND>:
TRAPHANDLER_NOEC(TH_BOUND, T_BOUND)	// fault
f01047d2:	6a 00                	push   $0x0
f01047d4:	6a 05                	push   $0x5
f01047d6:	e9 c7 00 00 00       	jmp    f01048a2 <_alltraps>
f01047db:	90                   	nop

f01047dc <TH_ILLOP>:
TRAPHANDLER_NOEC(TH_ILLOP, T_ILLOP)	// fault
f01047dc:	6a 00                	push   $0x0
f01047de:	6a 06                	push   $0x6
f01047e0:	e9 bd 00 00 00       	jmp    f01048a2 <_alltraps>
f01047e5:	90                   	nop

f01047e6 <TH_DEVICE>:
TRAPHANDLER_NOEC(TH_DEVICE, T_DEVICE)	// fault
f01047e6:	6a 00                	push   $0x0
f01047e8:	6a 07                	push   $0x7
f01047ea:	e9 b3 00 00 00       	jmp    f01048a2 <_alltraps>
f01047ef:	90                   	nop

f01047f0 <TH_DBLFLT>:
TRAPHANDLER     (TH_DBLFLT, T_DBLFLT)	// abort
f01047f0:	6a 08                	push   $0x8
f01047f2:	e9 ab 00 00 00       	jmp    f01048a2 <_alltraps>
f01047f7:	90                   	nop

f01047f8 <TH_TSS>:
//TRAPHANDLER_NOEC(TH_COPROC, T_COPROC) // abort	
TRAPHANDLER     (TH_TSS, T_TSS)		// fault
f01047f8:	6a 0a                	push   $0xa
f01047fa:	e9 a3 00 00 00       	jmp    f01048a2 <_alltraps>
f01047ff:	90                   	nop

f0104800 <TH_SEGNP>:
TRAPHANDLER     (TH_SEGNP, T_SEGNP)	// fault
f0104800:	6a 0b                	push   $0xb
f0104802:	e9 9b 00 00 00       	jmp    f01048a2 <_alltraps>
f0104807:	90                   	nop

f0104808 <TH_STACK>:
TRAPHANDLER     (TH_STACK, T_STACK)	// fault
f0104808:	6a 0c                	push   $0xc
f010480a:	e9 93 00 00 00       	jmp    f01048a2 <_alltraps>
f010480f:	90                   	nop

f0104810 <TH_GPFLT>:
TRAPHANDLER     (TH_GPFLT, T_GPFLT)	// fault/abort
f0104810:	6a 0d                	push   $0xd
f0104812:	e9 8b 00 00 00       	jmp    f01048a2 <_alltraps>
f0104817:	90                   	nop

f0104818 <TH_PGFLT>:
TRAPHANDLER     (TH_PGFLT, T_PGFLT)	// fault
f0104818:	6a 0e                	push   $0xe
f010481a:	e9 83 00 00 00       	jmp    f01048a2 <_alltraps>
f010481f:	90                   	nop

f0104820 <TH_FPERR>:
//TRAPHANDLER_NOEC(TH_RES, T_RES)	
TRAPHANDLER_NOEC(TH_FPERR, T_FPERR)	// fault
f0104820:	6a 00                	push   $0x0
f0104822:	6a 10                	push   $0x10
f0104824:	eb 7c                	jmp    f01048a2 <_alltraps>

f0104826 <TH_ALIGN>:
TRAPHANDLER     (TH_ALIGN, T_ALIGN)	//
f0104826:	6a 11                	push   $0x11
f0104828:	eb 78                	jmp    f01048a2 <_alltraps>

f010482a <TH_MCHK>:
TRAPHANDLER_NOEC(TH_MCHK, T_MCHK)	//
f010482a:	6a 00                	push   $0x0
f010482c:	6a 12                	push   $0x12
f010482e:	eb 72                	jmp    f01048a2 <_alltraps>

f0104830 <TH_SIMDERR>:
TRAPHANDLER_NOEC(TH_SIMDERR, T_SIMDERR) //
f0104830:	6a 00                	push   $0x0
f0104832:	6a 13                	push   $0x13
f0104834:	eb 6c                	jmp    f01048a2 <_alltraps>

f0104836 <TH_SYSCALL>:

TRAPHANDLER_NOEC(TH_SYSCALL, T_SYSCALL) // trap
f0104836:	6a 00                	push   $0x0
f0104838:	6a 30                	push   $0x30
f010483a:	eb 66                	jmp    f01048a2 <_alltraps>

f010483c <TH_IRQ_TIMER>:

TRAPHANDLER_NOEC(TH_IRQ_TIMER, IRQ_OFFSET+IRQ_TIMER)	// 0
f010483c:	6a 00                	push   $0x0
f010483e:	6a 20                	push   $0x20
f0104840:	eb 60                	jmp    f01048a2 <_alltraps>

f0104842 <TH_IRQ_KBD>:
TRAPHANDLER_NOEC(TH_IRQ_KBD, IRQ_OFFSET+IRQ_KBD)	// 1
f0104842:	6a 00                	push   $0x0
f0104844:	6a 21                	push   $0x21
f0104846:	eb 5a                	jmp    f01048a2 <_alltraps>

f0104848 <TH_IRQ_2>:
TRAPHANDLER_NOEC(TH_IRQ_2, IRQ_OFFSET+2)
f0104848:	6a 00                	push   $0x0
f010484a:	6a 22                	push   $0x22
f010484c:	eb 54                	jmp    f01048a2 <_alltraps>

f010484e <TH_IRQ_3>:
TRAPHANDLER_NOEC(TH_IRQ_3, IRQ_OFFSET+3)
f010484e:	6a 00                	push   $0x0
f0104850:	6a 23                	push   $0x23
f0104852:	eb 4e                	jmp    f01048a2 <_alltraps>

f0104854 <TH_IRQ_SERIAL>:
TRAPHANDLER_NOEC(TH_IRQ_SERIAL, IRQ_OFFSET+IRQ_SERIAL)	// 4
f0104854:	6a 00                	push   $0x0
f0104856:	6a 24                	push   $0x24
f0104858:	eb 48                	jmp    f01048a2 <_alltraps>

f010485a <TH_IRQ_5>:
TRAPHANDLER_NOEC(TH_IRQ_5, IRQ_OFFSET+5)
f010485a:	6a 00                	push   $0x0
f010485c:	6a 25                	push   $0x25
f010485e:	eb 42                	jmp    f01048a2 <_alltraps>

f0104860 <TH_IRQ_6>:
TRAPHANDLER_NOEC(TH_IRQ_6, IRQ_OFFSET+6)
f0104860:	6a 00                	push   $0x0
f0104862:	6a 26                	push   $0x26
f0104864:	eb 3c                	jmp    f01048a2 <_alltraps>

f0104866 <TH_IRQ_SPURIOUS>:
TRAPHANDLER_NOEC(TH_IRQ_SPURIOUS, IRQ_OFFSET+IRQ_SPURIOUS) // 7
f0104866:	6a 00                	push   $0x0
f0104868:	6a 27                	push   $0x27
f010486a:	eb 36                	jmp    f01048a2 <_alltraps>

f010486c <TH_IRQ_8>:
TRAPHANDLER_NOEC(TH_IRQ_8, IRQ_OFFSET+8)
f010486c:	6a 00                	push   $0x0
f010486e:	6a 28                	push   $0x28
f0104870:	eb 30                	jmp    f01048a2 <_alltraps>

f0104872 <TH_IRQ_9>:
TRAPHANDLER_NOEC(TH_IRQ_9, IRQ_OFFSET+9)
f0104872:	6a 00                	push   $0x0
f0104874:	6a 29                	push   $0x29
f0104876:	eb 2a                	jmp    f01048a2 <_alltraps>

f0104878 <TH_IRQ_10>:
TRAPHANDLER_NOEC(TH_IRQ_10, IRQ_OFFSET+10)
f0104878:	6a 00                	push   $0x0
f010487a:	6a 2a                	push   $0x2a
f010487c:	eb 24                	jmp    f01048a2 <_alltraps>

f010487e <TH_IRQ_11>:
TRAPHANDLER_NOEC(TH_IRQ_11, IRQ_OFFSET+11)
f010487e:	6a 00                	push   $0x0
f0104880:	6a 2b                	push   $0x2b
f0104882:	eb 1e                	jmp    f01048a2 <_alltraps>

f0104884 <TH_IRQ_12>:
TRAPHANDLER_NOEC(TH_IRQ_12, IRQ_OFFSET+12)
f0104884:	6a 00                	push   $0x0
f0104886:	6a 2c                	push   $0x2c
f0104888:	eb 18                	jmp    f01048a2 <_alltraps>

f010488a <TH_IRQ_13>:
TRAPHANDLER_NOEC(TH_IRQ_13, IRQ_OFFSET+13)
f010488a:	6a 00                	push   $0x0
f010488c:	6a 2d                	push   $0x2d
f010488e:	eb 12                	jmp    f01048a2 <_alltraps>

f0104890 <TH_IRQ_IDE>:
TRAPHANDLER_NOEC(TH_IRQ_IDE, IRQ_OFFSET+IRQ_IDE)	// 14
f0104890:	6a 00                	push   $0x0
f0104892:	6a 2e                	push   $0x2e
f0104894:	eb 0c                	jmp    f01048a2 <_alltraps>

f0104896 <TH_IRQ_15>:
TRAPHANDLER_NOEC(TH_IRQ_15, IRQ_OFFSET+15)
f0104896:	6a 00                	push   $0x0
f0104898:	6a 2f                	push   $0x2f
f010489a:	eb 06                	jmp    f01048a2 <_alltraps>

f010489c <TH_IRQ_ERROR>:
TRAPHANDLER_NOEC(TH_IRQ_ERROR, IRQ_OFFSET+IRQ_ERROR)	// 19
f010489c:	6a 00                	push   $0x0
f010489e:	6a 33                	push   $0x33
f01048a0:	eb 00                	jmp    f01048a2 <_alltraps>

f01048a2 <_alltraps>:
 * Lab 3: Your code here for _alltraps
 */

.text
_alltraps:
	pushl	%ds
f01048a2:	1e                   	push   %ds
	pushl	%es
f01048a3:	06                   	push   %es
	pushal
f01048a4:	60                   	pusha  
	mov	$GD_KD, %eax
f01048a5:	b8 10 00 00 00       	mov    $0x10,%eax
	mov	%ax, %es
f01048aa:	8e c0                	mov    %eax,%es
	mov	%ax, %ds
f01048ac:	8e d8                	mov    %eax,%ds
	pushl	%esp
f01048ae:	54                   	push   %esp
	call	trap
f01048af:	e8 9f fc ff ff       	call   f0104553 <trap>

f01048b4 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01048b4:	55                   	push   %ebp
f01048b5:	89 e5                	mov    %esp,%ebp
f01048b7:	83 ec 08             	sub    $0x8,%esp
f01048ba:	a1 4c 62 21 f0       	mov    0xf021624c,%eax
f01048bf:	8d 50 60             	lea    0x60(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01048c2:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01048c7:	8b 02                	mov    (%edx),%eax
f01048c9:	83 e8 01             	sub    $0x1,%eax
f01048cc:	83 f8 02             	cmp    $0x2,%eax
f01048cf:	76 13                	jbe    f01048e4 <sched_halt+0x30>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01048d1:	83 c1 01             	add    $0x1,%ecx
f01048d4:	81 c2 88 00 00 00    	add    $0x88,%edx
f01048da:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01048e0:	75 e5                	jne    f01048c7 <sched_halt+0x13>
f01048e2:	eb 08                	jmp    f01048ec <sched_halt+0x38>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f01048e4:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01048ea:	75 1f                	jne    f010490b <sched_halt+0x57>
		cprintf("No runnable environments in the system!\n");
f01048ec:	83 ec 0c             	sub    $0xc,%esp
f01048ef:	68 90 80 10 f0       	push   $0xf0108090
f01048f4:	e8 27 f2 ff ff       	call   f0103b20 <cprintf>
f01048f9:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f01048fc:	83 ec 0c             	sub    $0xc,%esp
f01048ff:	6a 00                	push   $0x0
f0104901:	e8 4f c0 ff ff       	call   f0100955 <monitor>
f0104906:	83 c4 10             	add    $0x10,%esp
f0104909:	eb f1                	jmp    f01048fc <sched_halt+0x48>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f010490b:	e8 f2 18 00 00       	call   f0106202 <cpunum>
f0104910:	6b c0 74             	imul   $0x74,%eax,%eax
f0104913:	c7 80 28 70 21 f0 00 	movl   $0x0,-0xfde8fd8(%eax)
f010491a:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f010491d:	a1 8c 6e 21 f0       	mov    0xf0216e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104922:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104927:	77 12                	ja     f010493b <sched_halt+0x87>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104929:	50                   	push   %eax
f010492a:	68 e8 68 10 f0       	push   $0xf01068e8
f010492f:	6a 7b                	push   $0x7b
f0104931:	68 b9 80 10 f0       	push   $0xf01080b9
f0104936:	e8 05 b7 ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010493b:	05 00 00 00 10       	add    $0x10000000,%eax
f0104940:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104943:	e8 ba 18 00 00       	call   f0106202 <cpunum>
f0104948:	6b d0 74             	imul   $0x74,%eax,%edx
f010494b:	81 c2 20 70 21 f0    	add    $0xf0217020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104951:	b8 02 00 00 00       	mov    $0x2,%eax
f0104956:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010495a:	83 ec 0c             	sub    $0xc,%esp
f010495d:	68 c0 13 12 f0       	push   $0xf01213c0
f0104962:	e8 a6 1b 00 00       	call   f010650d <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104967:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104969:	e8 94 18 00 00       	call   f0106202 <cpunum>
f010496e:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104971:	8b 80 30 70 21 f0    	mov    -0xfde8fd0(%eax),%eax
f0104977:	bd 00 00 00 00       	mov    $0x0,%ebp
f010497c:	89 c4                	mov    %eax,%esp
f010497e:	6a 00                	push   $0x0
f0104980:	6a 00                	push   $0x0
f0104982:	fb                   	sti    
f0104983:	f4                   	hlt    
f0104984:	eb fd                	jmp    f0104983 <sched_halt+0xcf>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104986:	83 c4 10             	add    $0x10,%esp
f0104989:	c9                   	leave  
f010498a:	c3                   	ret    

f010498b <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f010498b:	55                   	push   %ebp
f010498c:	89 e5                	mov    %esp,%ebp
f010498e:	53                   	push   %ebx
f010498f:	83 ec 10             	sub    $0x10,%esp
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	cprintf ("IN SCHED.C YIELDING\n\n");
f0104992:	68 c6 80 10 f0       	push   $0xf01080c6
f0104997:	e8 84 f1 ff ff       	call   f0103b20 <cprintf>
	size_t i;
	if (!curenv) {
f010499c:	e8 61 18 00 00       	call   f0106202 <cpunum>
f01049a1:	6b c0 74             	imul   $0x74,%eax,%eax
f01049a4:	83 c4 10             	add    $0x10,%esp
		i = 0;
f01049a7:	ba 00 00 00 00       	mov    $0x0,%edx
	// below to halt the cpu.

	// LAB 4: Your code here.
	cprintf ("IN SCHED.C YIELDING\n\n");
	size_t i;
	if (!curenv) {
f01049ac:	83 b8 28 70 21 f0 00 	cmpl   $0x0,-0xfde8fd8(%eax)
f01049b3:	74 1a                	je     f01049cf <sched_yield+0x44>
		i = 0;
	} else {
		i = ENVX(curenv->env_id) + 1;
f01049b5:	e8 48 18 00 00       	call   f0106202 <cpunum>
f01049ba:	6b c0 74             	imul   $0x74,%eax,%eax
f01049bd:	8b 80 28 70 21 f0    	mov    -0xfde8fd8(%eax),%eax
f01049c3:	8b 50 54             	mov    0x54(%eax),%edx
f01049c6:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01049cc:	83 c2 01             	add    $0x1,%edx
	}
	// Lab 7 Multithreading: scheduler verzia 1.0 
	for (; i < NENV; i++) {
		if (envs[i].env_status == ENV_RUNNABLE) {
f01049cf:	a1 4c 62 21 f0       	mov    0xf021624c,%eax
f01049d4:	89 d1                	mov    %edx,%ecx
f01049d6:	c1 e1 07             	shl    $0x7,%ecx
f01049d9:	8d 0c d1             	lea    (%ecx,%edx,8),%ecx
f01049dc:	01 c1                	add    %eax,%ecx
f01049de:	eb 1a                	jmp    f01049fa <sched_yield+0x6f>
f01049e0:	89 cb                	mov    %ecx,%ebx
f01049e2:	81 c1 88 00 00 00    	add    $0x88,%ecx
f01049e8:	83 79 d8 02          	cmpl   $0x2,-0x28(%ecx)
f01049ec:	75 09                	jne    f01049f7 <sched_yield+0x6c>
			env_run(&envs[i]);
f01049ee:	83 ec 0c             	sub    $0xc,%esp
f01049f1:	53                   	push   %ebx
f01049f2:	e8 f3 ec ff ff       	call   f01036ea <env_run>
		i = 0;
	} else {
		i = ENVX(curenv->env_id) + 1;
	}
	// Lab 7 Multithreading: scheduler verzia 1.0 
	for (; i < NENV; i++) {
f01049f7:	83 c2 01             	add    $0x1,%edx
f01049fa:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
f0104a00:	76 de                	jbe    f01049e0 <sched_yield+0x55>
f0104a02:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104a07:	eb 19                	jmp    f0104a22 <sched_yield+0x97>
	}

	size_t j;

	for (j = 0; j < i; j++) {
		if (envs[j].env_status == ENV_RUNNABLE) {
f0104a09:	89 c3                	mov    %eax,%ebx
f0104a0b:	05 88 00 00 00       	add    $0x88,%eax
f0104a10:	83 78 d8 02          	cmpl   $0x2,-0x28(%eax)
f0104a14:	75 09                	jne    f0104a1f <sched_yield+0x94>
			env_run(&envs[j]);
f0104a16:	83 ec 0c             	sub    $0xc,%esp
f0104a19:	53                   	push   %ebx
f0104a1a:	e8 cb ec ff ff       	call   f01036ea <env_run>
		} 
	}

	size_t j;

	for (j = 0; j < i; j++) {
f0104a1f:	83 c1 01             	add    $0x1,%ecx
f0104a22:	39 ca                	cmp    %ecx,%edx
f0104a24:	75 e3                	jne    f0104a09 <sched_yield+0x7e>
				else
					env_destroy(&envs[j]);
			}
		} 
	}*/
	if (curenv && (curenv->env_status == ENV_RUNNING)) {
f0104a26:	e8 d7 17 00 00       	call   f0106202 <cpunum>
f0104a2b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a2e:	83 b8 28 70 21 f0 00 	cmpl   $0x0,-0xfde8fd8(%eax)
f0104a35:	74 2a                	je     f0104a61 <sched_yield+0xd6>
f0104a37:	e8 c6 17 00 00       	call   f0106202 <cpunum>
f0104a3c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a3f:	8b 80 28 70 21 f0    	mov    -0xfde8fd8(%eax),%eax
f0104a45:	83 78 60 03          	cmpl   $0x3,0x60(%eax)
f0104a49:	75 16                	jne    f0104a61 <sched_yield+0xd6>
		env_run(curenv);
f0104a4b:	e8 b2 17 00 00       	call   f0106202 <cpunum>
f0104a50:	83 ec 0c             	sub    $0xc,%esp
f0104a53:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a56:	ff b0 28 70 21 f0    	pushl  -0xfde8fd8(%eax)
f0104a5c:	e8 89 ec ff ff       	call   f01036ea <env_run>
	}

	// sched_halt never returns
	sched_halt();
f0104a61:	e8 4e fe ff ff       	call   f01048b4 <sched_halt>
}
f0104a66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104a69:	c9                   	leave  
f0104a6a:	c3                   	ret    

f0104a6b <sys_thread_create>:

// Lab 7 Multithreading 
// zavola tvorbu noveho threadu (z env.c)
envid_t	
sys_thread_create(uintptr_t func)
{
f0104a6b:	55                   	push   %ebp
f0104a6c:	89 e5                	mov    %esp,%ebp
f0104a6e:	53                   	push   %ebx
f0104a6f:	83 ec 0c             	sub    $0xc,%esp
f0104a72:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("in sys thread create, eip: %x\n", func);
f0104a75:	53                   	push   %ebx
f0104a76:	68 dc 80 10 f0       	push   $0xf01080dc
f0104a7b:	e8 a0 f0 ff ff       	call   f0103b20 <cprintf>

	envid_t id = thread_create(func);
f0104a80:	89 1c 24             	mov    %ebx,(%esp)
f0104a83:	e8 41 ee ff ff       	call   f01038c9 <thread_create>
	return id;
}	
f0104a88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104a8b:	c9                   	leave  
f0104a8c:	c3                   	ret    

f0104a8d <sys_thread_free>:


void 	
sys_thread_free(envid_t envid)
{
f0104a8d:	55                   	push   %ebp
f0104a8e:	89 e5                	mov    %esp,%ebp
f0104a90:	83 ec 1c             	sub    $0x1c,%esp
	struct Env* e;
	envid2env(envid, &e, 0);
f0104a93:	6a 00                	push   $0x0
f0104a95:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104a98:	50                   	push   %eax
f0104a99:	ff 75 08             	pushl  0x8(%ebp)
f0104a9c:	e8 12 e6 ff ff       	call   f01030b3 <envid2env>
	thread_free(e);
f0104aa1:	83 c4 04             	add    $0x4,%esp
f0104aa4:	ff 75 f4             	pushl  -0xc(%ebp)
f0104aa7:	e8 29 ed ff ff       	call   f01037d5 <thread_free>
}
f0104aac:	83 c4 10             	add    $0x10,%esp
f0104aaf:	c9                   	leave  
f0104ab0:	c3                   	ret    

f0104ab1 <syscall>:

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104ab1:	55                   	push   %ebp
f0104ab2:	89 e5                	mov    %esp,%ebp
f0104ab4:	57                   	push   %edi
f0104ab5:	56                   	push   %esi
f0104ab6:	83 ec 10             	sub    $0x10,%esp
f0104ab9:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno) {
f0104abc:	83 f8 0f             	cmp    $0xf,%eax
f0104abf:	0f 87 29 06 00 00    	ja     f01050ee <syscall+0x63d>
f0104ac5:	ff 24 85 34 81 10 f0 	jmp    *-0xfef7ecc(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, PTE_U);
f0104acc:	e8 31 17 00 00       	call   f0106202 <cpunum>
f0104ad1:	6a 04                	push   $0x4
f0104ad3:	ff 75 10             	pushl  0x10(%ebp)
f0104ad6:	ff 75 0c             	pushl  0xc(%ebp)
f0104ad9:	6b c0 74             	imul   $0x74,%eax,%eax
f0104adc:	ff b0 28 70 21 f0    	pushl  -0xfde8fd8(%eax)
f0104ae2:	e8 c8 e4 ff ff       	call   f0102faf <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104ae7:	83 c4 0c             	add    $0xc,%esp
f0104aea:	ff 75 0c             	pushl  0xc(%ebp)
f0104aed:	ff 75 10             	pushl  0x10(%ebp)
f0104af0:	68 fb 80 10 f0       	push   $0xf01080fb
f0104af5:	e8 26 f0 ff ff       	call   f0103b20 <cprintf>
f0104afa:	83 c4 10             	add    $0x10,%esp
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((char*)a1, a2);
			return 0;
f0104afd:	b8 00 00 00 00       	mov    $0x0,%eax
f0104b02:	e9 f3 05 00 00       	jmp    f01050fa <syscall+0x649>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104b07:	e8 fd ba ff ff       	call   f0100609 <cons_getc>
		case SYS_cputs:
			sys_cputs((char*)a1, a2);
			return 0;

		case SYS_cgetc:
			return sys_cgetc();
f0104b0c:	e9 e9 05 00 00       	jmp    f01050fa <syscall+0x649>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104b11:	e8 ec 16 00 00       	call   f0106202 <cpunum>
f0104b16:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b19:	8b 80 28 70 21 f0    	mov    -0xfde8fd8(%eax),%eax
f0104b1f:	8b 40 54             	mov    0x54(%eax),%eax

		case SYS_cgetc:
			return sys_cgetc();

		case SYS_getenvid:
			return sys_getenvid();
f0104b22:	e9 d3 05 00 00       	jmp    f01050fa <syscall+0x649>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104b27:	83 ec 04             	sub    $0x4,%esp
f0104b2a:	6a 01                	push   $0x1
f0104b2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104b2f:	50                   	push   %eax
f0104b30:	ff 75 0c             	pushl  0xc(%ebp)
f0104b33:	e8 7b e5 ff ff       	call   f01030b3 <envid2env>
f0104b38:	83 c4 10             	add    $0x10,%esp
f0104b3b:	85 c0                	test   %eax,%eax
f0104b3d:	0f 88 b7 05 00 00    	js     f01050fa <syscall+0x649>
		return r;
	if (e == curenv)
f0104b43:	e8 ba 16 00 00       	call   f0106202 <cpunum>
f0104b48:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104b4b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b4e:	39 90 28 70 21 f0    	cmp    %edx,-0xfde8fd8(%eax)
f0104b54:	75 23                	jne    f0104b79 <syscall+0xc8>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104b56:	e8 a7 16 00 00       	call   f0106202 <cpunum>
f0104b5b:	83 ec 08             	sub    $0x8,%esp
f0104b5e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b61:	8b 80 28 70 21 f0    	mov    -0xfde8fd8(%eax),%eax
f0104b67:	ff 70 54             	pushl  0x54(%eax)
f0104b6a:	68 00 81 10 f0       	push   $0xf0108100
f0104b6f:	e8 ac ef ff ff       	call   f0103b20 <cprintf>
f0104b74:	83 c4 10             	add    $0x10,%esp
f0104b77:	eb 25                	jmp    f0104b9e <syscall+0xed>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104b79:	8b 72 54             	mov    0x54(%edx),%esi
f0104b7c:	e8 81 16 00 00       	call   f0106202 <cpunum>
f0104b81:	83 ec 04             	sub    $0x4,%esp
f0104b84:	56                   	push   %esi
f0104b85:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b88:	8b 80 28 70 21 f0    	mov    -0xfde8fd8(%eax),%eax
f0104b8e:	ff 70 54             	pushl  0x54(%eax)
f0104b91:	68 1b 81 10 f0       	push   $0xf010811b
f0104b96:	e8 85 ef ff ff       	call   f0103b20 <cprintf>
f0104b9b:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104b9e:	83 ec 0c             	sub    $0xc,%esp
f0104ba1:	ff 75 f4             	pushl  -0xc(%ebp)
f0104ba4:	e8 99 ec ff ff       	call   f0103842 <env_destroy>
f0104ba9:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104bac:	b8 00 00 00 00       	mov    $0x0,%eax
f0104bb1:	e9 44 05 00 00       	jmp    f01050fa <syscall+0x649>
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	// check if va is page aligned and isnt above UTOP
	if ((((int)va % PGSIZE) != 0) || ((uintptr_t)va >= UTOP)) {
f0104bb6:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104bbd:	0f 85 84 00 00 00    	jne    f0104c47 <syscall+0x196>
f0104bc3:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104bca:	77 7b                	ja     f0104c47 <syscall+0x196>
		return -E_INVAL;
	}
	// check if PTE_P and PTE_U are set (must be set)
	if (((PTE_P | PTE_U) & perm) != (PTE_U | PTE_P)) { 
f0104bcc:	8b 45 14             	mov    0x14(%ebp),%eax
f0104bcf:	83 e0 05             	and    $0x5,%eax
f0104bd2:	83 f8 05             	cmp    $0x5,%eax
f0104bd5:	75 7a                	jne    f0104c51 <syscall+0x1a0>
	}
	
	int to_check = perm | PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	int available_perm = PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	// check if no other bits hev bin(where the trash goes) set 
	if ((available_perm ^ to_check) != 0) {
f0104bd7:	8b 45 14             	mov    0x14(%ebp),%eax
f0104bda:	0d 07 0e 00 00       	or     $0xe07,%eax
f0104bdf:	3d 07 0e 00 00       	cmp    $0xe07,%eax
f0104be4:	75 75                	jne    f0104c5b <syscall+0x1aa>
		return -E_INVAL;
	}

	struct PageInfo *new_page = page_alloc(ALLOC_ZERO);
f0104be6:	83 ec 0c             	sub    $0xc,%esp
f0104be9:	6a 01                	push   $0x1
f0104beb:	e8 cc c3 ff ff       	call   f0100fbc <page_alloc>
f0104bf0:	89 c6                	mov    %eax,%esi
	// page alloc return null if there are no free pages on page_free_list
	if (!new_page) {
f0104bf2:	83 c4 10             	add    $0x10,%esp
f0104bf5:	85 c0                	test   %eax,%eax
f0104bf7:	74 6c                	je     f0104c65 <syscall+0x1b4>
		return -E_NO_MEM;
	}

	struct Env *e;
	int retperm = envid2env(envid, &e, true);
f0104bf9:	83 ec 04             	sub    $0x4,%esp
f0104bfc:	6a 01                	push   $0x1
f0104bfe:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104c01:	50                   	push   %eax
f0104c02:	ff 75 0c             	pushl  0xc(%ebp)
f0104c05:	e8 a9 e4 ff ff       	call   f01030b3 <envid2env>

	//nechce sa mi uz
	if (retperm) {
f0104c0a:	83 c4 10             	add    $0x10,%esp
f0104c0d:	85 c0                	test   %eax,%eax
f0104c0f:	0f 85 e5 04 00 00    	jne    f01050fa <syscall+0x649>
		return retperm;
	}	

	int pg_insert_check = page_insert(e->env_pgdir, new_page, va, perm);
f0104c15:	ff 75 14             	pushl  0x14(%ebp)
f0104c18:	ff 75 10             	pushl  0x10(%ebp)
f0104c1b:	56                   	push   %esi
f0104c1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104c1f:	ff 70 6c             	pushl  0x6c(%eax)
f0104c22:	e8 43 c7 ff ff       	call   f010136a <page_insert>
f0104c27:	89 c7                	mov    %eax,%edi
	
	if (pg_insert_check) {
f0104c29:	83 c4 10             	add    $0x10,%esp
f0104c2c:	85 c0                	test   %eax,%eax
f0104c2e:	0f 84 c6 04 00 00    	je     f01050fa <syscall+0x649>
		page_free(new_page);
f0104c34:	83 ec 0c             	sub    $0xc,%esp
f0104c37:	56                   	push   %esi
f0104c38:	e8 ef c3 ff ff       	call   f010102c <page_free>
f0104c3d:	83 c4 10             	add    $0x10,%esp
		return pg_insert_check;
f0104c40:	89 f8                	mov    %edi,%eax
f0104c42:	e9 b3 04 00 00       	jmp    f01050fa <syscall+0x649>
	//   allocated!

	// LAB 4: Your code here.
	// check if va is page aligned and isnt above UTOP
	if ((((int)va % PGSIZE) != 0) || ((uintptr_t)va >= UTOP)) {
		return -E_INVAL;
f0104c47:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104c4c:	e9 a9 04 00 00       	jmp    f01050fa <syscall+0x649>
	}
	// check if PTE_P and PTE_U are set (must be set)
	if (((PTE_P | PTE_U) & perm) != (PTE_U | PTE_P)) { 
		return -E_INVAL;
f0104c51:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104c56:	e9 9f 04 00 00       	jmp    f01050fa <syscall+0x649>
	
	int to_check = perm | PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	int available_perm = PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	// check if no other bits hev bin(where the trash goes) set 
	if ((available_perm ^ to_check) != 0) {
		return -E_INVAL;
f0104c5b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104c60:	e9 95 04 00 00       	jmp    f01050fa <syscall+0x649>
	}

	struct PageInfo *new_page = page_alloc(ALLOC_ZERO);
	// page alloc return null if there are no free pages on page_free_list
	if (!new_page) {
		return -E_NO_MEM;
f0104c65:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104c6a:	e9 8b 04 00 00       	jmp    f01050fa <syscall+0x649>
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.

	if ((((int)srcva % PGSIZE) != 0) || ((uintptr_t)srcva >= UTOP)) {
f0104c6f:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104c76:	0f 85 d7 00 00 00    	jne    f0104d53 <syscall+0x2a2>
f0104c7c:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104c83:	0f 87 ca 00 00 00    	ja     f0104d53 <syscall+0x2a2>
		return -E_INVAL;
	}

	if ((((int)dstva % PGSIZE) != 0) || ((uintptr_t)dstva >= UTOP)) {
f0104c89:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0104c90:	0f 85 c7 00 00 00    	jne    f0104d5d <syscall+0x2ac>
f0104c96:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104c9d:	0f 87 ba 00 00 00    	ja     f0104d5d <syscall+0x2ac>
		return -E_INVAL;
	}

	if (((PTE_P | PTE_U) & perm) != (PTE_U | PTE_P)) { 
f0104ca3:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0104ca6:	83 e0 05             	and    $0x5,%eax
f0104ca9:	83 f8 05             	cmp    $0x5,%eax
f0104cac:	0f 85 b5 00 00 00    	jne    f0104d67 <syscall+0x2b6>
	}
	
	int to_check = perm | PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	int available_perm = PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	// check if no other bits have been set 
	if ((available_perm ^ to_check) != 0) {
f0104cb2:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0104cb5:	0d 07 0e 00 00       	or     $0xe07,%eax
f0104cba:	3d 07 0e 00 00       	cmp    $0xe07,%eax
f0104cbf:	0f 85 ac 00 00 00    	jne    f0104d71 <syscall+0x2c0>
		return -E_INVAL;
	}

	struct Env *srce;

	int retperm = envid2env(srcenvid, &srce, true);
f0104cc5:	83 ec 04             	sub    $0x4,%esp
f0104cc8:	6a 01                	push   $0x1
f0104cca:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104ccd:	50                   	push   %eax
f0104cce:	ff 75 0c             	pushl  0xc(%ebp)
f0104cd1:	e8 dd e3 ff ff       	call   f01030b3 <envid2env>
	
	if (retperm == -E_BAD_ENV) {
f0104cd6:	83 c4 10             	add    $0x10,%esp
f0104cd9:	83 f8 fe             	cmp    $0xfffffffe,%eax
f0104cdc:	0f 84 99 00 00 00    	je     f0104d7b <syscall+0x2ca>
		return -E_BAD_ENV;
	}

	struct Env *dste;

	int retperm2 = envid2env(dstenvid, &dste, true);
f0104ce2:	83 ec 04             	sub    $0x4,%esp
f0104ce5:	6a 01                	push   $0x1
f0104ce7:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0104cea:	50                   	push   %eax
f0104ceb:	ff 75 14             	pushl  0x14(%ebp)
f0104cee:	e8 c0 e3 ff ff       	call   f01030b3 <envid2env>
	
	if (retperm2 == -E_BAD_ENV) {
f0104cf3:	83 c4 10             	add    $0x10,%esp
f0104cf6:	83 f8 fe             	cmp    $0xfffffffe,%eax
f0104cf9:	0f 84 86 00 00 00    	je     f0104d85 <syscall+0x2d4>
		return -E_BAD_ENV;
	}

	pte_t *pte_store;
	struct PageInfo *p = page_lookup(srce->env_pgdir, srcva, &pte_store);
f0104cff:	83 ec 04             	sub    $0x4,%esp
f0104d02:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104d05:	50                   	push   %eax
f0104d06:	ff 75 10             	pushl  0x10(%ebp)
f0104d09:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104d0c:	ff 70 6c             	pushl  0x6c(%eax)
f0104d0f:	e8 2c c5 ff ff       	call   f0101240 <page_lookup>
	
	if (((perm & PTE_W) == PTE_W) && ((*pte_store & PTE_W) != PTE_W)) {
f0104d14:	83 c4 10             	add    $0x10,%esp
f0104d17:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104d1b:	74 08                	je     f0104d25 <syscall+0x274>
f0104d1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104d20:	f6 02 02             	testb  $0x2,(%edx)
f0104d23:	74 6a                	je     f0104d8f <syscall+0x2de>
		return -E_INVAL;
	}

	if (!p) {
f0104d25:	85 c0                	test   %eax,%eax
f0104d27:	74 70                	je     f0104d99 <syscall+0x2e8>
		return -E_INVAL;	
	}
	
	int pg_insert_check = page_insert(dste->env_pgdir, p, dstva, perm);
f0104d29:	ff 75 1c             	pushl  0x1c(%ebp)
f0104d2c:	ff 75 18             	pushl  0x18(%ebp)
f0104d2f:	50                   	push   %eax
f0104d30:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104d33:	ff 70 6c             	pushl  0x6c(%eax)
f0104d36:	e8 2f c6 ff ff       	call   f010136a <page_insert>
	
	if (pg_insert_check == -E_NO_MEM) {
f0104d3b:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
	}
	
	return 0;
f0104d3e:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0104d41:	0f 95 c0             	setne  %al
f0104d44:	0f b6 c0             	movzbl %al,%eax
f0104d47:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
f0104d4e:	e9 a7 03 00 00       	jmp    f01050fa <syscall+0x649>
	//   check the current permissions on the page.

	// LAB 4: Your code here.

	if ((((int)srcva % PGSIZE) != 0) || ((uintptr_t)srcva >= UTOP)) {
		return -E_INVAL;
f0104d53:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104d58:	e9 9d 03 00 00       	jmp    f01050fa <syscall+0x649>
	}

	if ((((int)dstva % PGSIZE) != 0) || ((uintptr_t)dstva >= UTOP)) {
		return -E_INVAL;
f0104d5d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104d62:	e9 93 03 00 00       	jmp    f01050fa <syscall+0x649>
	}

	if (((PTE_P | PTE_U) & perm) != (PTE_U | PTE_P)) { 
		return -E_INVAL;
f0104d67:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104d6c:	e9 89 03 00 00       	jmp    f01050fa <syscall+0x649>
	
	int to_check = perm | PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	int available_perm = PTE_P | PTE_W | PTE_U | PTE_AVAIL;
	// check if no other bits have been set 
	if ((available_perm ^ to_check) != 0) {
		return -E_INVAL;
f0104d71:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104d76:	e9 7f 03 00 00       	jmp    f01050fa <syscall+0x649>
	struct Env *srce;

	int retperm = envid2env(srcenvid, &srce, true);
	
	if (retperm == -E_BAD_ENV) {
		return -E_BAD_ENV;
f0104d7b:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104d80:	e9 75 03 00 00       	jmp    f01050fa <syscall+0x649>
	struct Env *dste;

	int retperm2 = envid2env(dstenvid, &dste, true);
	
	if (retperm2 == -E_BAD_ENV) {
		return -E_BAD_ENV;
f0104d85:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104d8a:	e9 6b 03 00 00       	jmp    f01050fa <syscall+0x649>

	pte_t *pte_store;
	struct PageInfo *p = page_lookup(srce->env_pgdir, srcva, &pte_store);
	
	if (((perm & PTE_W) == PTE_W) && ((*pte_store & PTE_W) != PTE_W)) {
		return -E_INVAL;
f0104d8f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104d94:	e9 61 03 00 00       	jmp    f01050fa <syscall+0x649>
	}

	if (!p) {
		return -E_INVAL;	
f0104d99:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104d9e:	e9 57 03 00 00       	jmp    f01050fa <syscall+0x649>
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if ((((int)va % PGSIZE) != 0) || ((uintptr_t)va >= UTOP)) {
f0104da3:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104daa:	75 42                	jne    f0104dee <syscall+0x33d>
f0104dac:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104db3:	77 39                	ja     f0104dee <syscall+0x33d>
		return -E_INVAL;
	}
	
	struct Env *e;
	int perm = envid2env(envid, &e, true);
f0104db5:	83 ec 04             	sub    $0x4,%esp
f0104db8:	6a 01                	push   $0x1
f0104dba:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104dbd:	50                   	push   %eax
f0104dbe:	ff 75 0c             	pushl  0xc(%ebp)
f0104dc1:	e8 ed e2 ff ff       	call   f01030b3 <envid2env>
f0104dc6:	89 c6                	mov    %eax,%esi
	
	if (perm) {
f0104dc8:	83 c4 10             	add    $0x10,%esp
f0104dcb:	85 c0                	test   %eax,%eax
f0104dcd:	0f 85 27 03 00 00    	jne    f01050fa <syscall+0x649>
		return perm;
	}	
	
	page_remove(e->env_pgdir, va);
f0104dd3:	83 ec 08             	sub    $0x8,%esp
f0104dd6:	ff 75 10             	pushl  0x10(%ebp)
f0104dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104ddc:	ff 70 6c             	pushl  0x6c(%eax)
f0104ddf:	e8 18 c5 ff ff       	call   f01012fc <page_remove>
f0104de4:	83 c4 10             	add    $0x10,%esp

	return 0;
f0104de7:	89 f0                	mov    %esi,%eax
f0104de9:	e9 0c 03 00 00       	jmp    f01050fa <syscall+0x649>
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if ((((int)va % PGSIZE) != 0) || ((uintptr_t)va >= UTOP)) {
		return -E_INVAL;
f0104dee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104df3:	e9 02 03 00 00       	jmp    f01050fa <syscall+0x649>
	// It should be left as env_alloc created it, except that
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.
	struct Env *new_env;
	int env_state =	env_alloc(&new_env, curenv->env_id);
f0104df8:	e8 05 14 00 00       	call   f0106202 <cpunum>
f0104dfd:	83 ec 08             	sub    $0x8,%esp
f0104e00:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e03:	8b 80 28 70 21 f0    	mov    -0xfde8fd8(%eax),%eax
f0104e09:	ff 70 54             	pushl  0x54(%eax)
f0104e0c:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104e0f:	50                   	push   %eax
f0104e10:	e8 fb e3 ff ff       	call   f0103210 <env_alloc>

	if (env_state < 0) {
f0104e15:	83 c4 10             	add    $0x10,%esp
f0104e18:	85 c0                	test   %eax,%eax
f0104e1a:	0f 88 da 02 00 00    	js     f01050fa <syscall+0x649>
		return env_state;
	}

	new_env->env_tf = curenv->env_tf;
f0104e20:	8b 7d f4             	mov    -0xc(%ebp),%edi
f0104e23:	e8 da 13 00 00       	call   f0106202 <cpunum>
f0104e28:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e2b:	8b b0 28 70 21 f0    	mov    -0xfde8fd8(%eax),%esi
f0104e31:	83 c7 0c             	add    $0xc,%edi
f0104e34:	83 c6 0c             	add    $0xc,%esi
f0104e37:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104e3c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	new_env->env_status = ENV_NOT_RUNNABLE;
f0104e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104e41:	c7 40 60 04 00 00 00 	movl   $0x4,0x60(%eax)
	new_env->env_tf.tf_regs.reg_eax = 0;
f0104e48:	c7 40 28 00 00 00 00 	movl   $0x0,0x28(%eax)

	return new_env->env_id;
f0104e4f:	8b 40 54             	mov    0x54(%eax),%eax
f0104e52:	e9 a3 02 00 00       	jmp    f01050fa <syscall+0x649>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if ((status != ENV_RUNNABLE) && (status != ENV_NOT_RUNNABLE)) {
f0104e57:	8b 45 10             	mov    0x10(%ebp),%eax
f0104e5a:	83 e8 02             	sub    $0x2,%eax
f0104e5d:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0104e62:	75 2e                	jne    f0104e92 <syscall+0x3e1>
		return -E_INVAL;
	}

	struct Env *e;

	int perm = envid2env(envid, &e, true); 
f0104e64:	83 ec 04             	sub    $0x4,%esp
f0104e67:	6a 01                	push   $0x1
f0104e69:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104e6c:	50                   	push   %eax
f0104e6d:	ff 75 0c             	pushl  0xc(%ebp)
f0104e70:	e8 3e e2 ff ff       	call   f01030b3 <envid2env>
f0104e75:	89 c2                	mov    %eax,%edx

	if (perm) {
f0104e77:	83 c4 10             	add    $0x10,%esp
f0104e7a:	85 c0                	test   %eax,%eax
f0104e7c:	0f 85 78 02 00 00    	jne    f01050fa <syscall+0x649>
		return perm;
	}	

	e->env_status = status;
f0104e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104e85:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104e88:	89 48 60             	mov    %ecx,0x60(%eax)

	return 0;
f0104e8b:	89 d0                	mov    %edx,%eax
f0104e8d:	e9 68 02 00 00       	jmp    f01050fa <syscall+0x649>
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if ((status != ENV_RUNNABLE) && (status != ENV_NOT_RUNNABLE)) {
		return -E_INVAL;
f0104e92:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104e97:	e9 5e 02 00 00       	jmp    f01050fa <syscall+0x649>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *e;

	int perm = envid2env(envid, &e, true); 
f0104e9c:	83 ec 04             	sub    $0x4,%esp
f0104e9f:	6a 01                	push   $0x1
f0104ea1:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104ea4:	50                   	push   %eax
f0104ea5:	ff 75 0c             	pushl  0xc(%ebp)
f0104ea8:	e8 06 e2 ff ff       	call   f01030b3 <envid2env>

	if (perm) {
f0104ead:	83 c4 10             	add    $0x10,%esp
f0104eb0:	85 c0                	test   %eax,%eax
f0104eb2:	0f 85 42 02 00 00    	jne    f01050fa <syscall+0x649>
		return perm;
	}
	
	e->env_pgfault_upcall = func;
f0104eb8:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104ebb:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104ebe:	89 4a 70             	mov    %ecx,0x70(%edx)

		case SYS_env_set_status:
			return sys_env_set_status(a1, a2);

		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1, (void*)a2);
f0104ec1:	e9 34 02 00 00       	jmp    f01050fa <syscall+0x649>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104ec6:	e8 c0 fa ff ff       	call   f010498b <sched_yield>
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.

	struct Env *e;
	int env = envid2env(envid, &e, false);
f0104ecb:	83 ec 04             	sub    $0x4,%esp
f0104ece:	6a 00                	push   $0x0
f0104ed0:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0104ed3:	50                   	push   %eax
f0104ed4:	ff 75 0c             	pushl  0xc(%ebp)
f0104ed7:	e8 d7 e1 ff ff       	call   f01030b3 <envid2env>
	
	if (env < 0) {
f0104edc:	83 c4 10             	add    $0x10,%esp
f0104edf:	85 c0                	test   %eax,%eax
f0104ee1:	79 08                	jns    f0104eeb <syscall+0x43a>
		return perm;
f0104ee3:	8b 45 18             	mov    0x18(%ebp),%eax
f0104ee6:	e9 0f 02 00 00       	jmp    f01050fa <syscall+0x649>
	}
	
	if (!e->env_ipc_recving) {
f0104eeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104eee:	80 78 74 00          	cmpb   $0x0,0x74(%eax)
f0104ef2:	0f 84 09 01 00 00    	je     f0105001 <syscall+0x550>
		return -E_IPC_NOT_RECV;
	}

	e->env_ipc_perm = 0;
f0104ef8:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
f0104eff:	00 00 00 

	if ((uint32_t)srcva < UTOP) {
f0104f02:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104f09:	0f 87 b3 00 00 00    	ja     f0104fc2 <syscall+0x511>
		if (ROUNDDOWN((uint32_t)srcva,PGSIZE) != (uint32_t)srcva) {
			return -E_INVAL;
f0104f0f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}

	e->env_ipc_perm = 0;

	if ((uint32_t)srcva < UTOP) {
		if (ROUNDDOWN((uint32_t)srcva,PGSIZE) != (uint32_t)srcva) {
f0104f14:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104f1b:	0f 85 d9 01 00 00    	jne    f01050fa <syscall+0x649>
			return -E_INVAL;
		}

		if (((PTE_P | PTE_U) & perm) != (PTE_U | PTE_P)) { 
f0104f21:	8b 55 18             	mov    0x18(%ebp),%edx
f0104f24:	83 e2 05             	and    $0x5,%edx
f0104f27:	83 fa 05             	cmp    $0x5,%edx
f0104f2a:	0f 85 ca 01 00 00    	jne    f01050fa <syscall+0x649>
		}
	
		int to_check = perm | PTE_P | PTE_W | PTE_U | PTE_AVAIL;
		int available_perm = PTE_P | PTE_W | PTE_U | PTE_AVAIL;
		// check if no other bits have been set 
		if ((available_perm ^ to_check) != 0) {
f0104f30:	8b 55 18             	mov    0x18(%ebp),%edx
f0104f33:	81 ca 07 0e 00 00    	or     $0xe07,%edx
f0104f39:	81 fa 07 0e 00 00    	cmp    $0xe07,%edx
f0104f3f:	0f 85 b5 01 00 00    	jne    f01050fa <syscall+0x649>
			return -E_INVAL;
		}

		pte_t *pte_store;
		struct PageInfo *p = page_lookup(curenv->env_pgdir, srcva, 							 &pte_store);
f0104f45:	e8 b8 12 00 00       	call   f0106202 <cpunum>
f0104f4a:	83 ec 04             	sub    $0x4,%esp
f0104f4d:	8d 55 f4             	lea    -0xc(%ebp),%edx
f0104f50:	52                   	push   %edx
f0104f51:	ff 75 14             	pushl  0x14(%ebp)
f0104f54:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f57:	8b 80 28 70 21 f0    	mov    -0xfde8fd8(%eax),%eax
f0104f5d:	ff 70 6c             	pushl  0x6c(%eax)
f0104f60:	e8 db c2 ff ff       	call   f0101240 <page_lookup>
f0104f65:	89 c1                	mov    %eax,%ecx
	
		if (((perm & PTE_W) == PTE_W) && ((*pte_store & PTE_W) != PTE_W)) {
f0104f67:	83 c4 10             	add    $0x10,%esp
f0104f6a:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104f6e:	74 11                	je     f0104f81 <syscall+0x4d0>
			return -E_INVAL;
f0104f70:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}

		pte_t *pte_store;
		struct PageInfo *p = page_lookup(curenv->env_pgdir, srcva, 							 &pte_store);
	
		if (((perm & PTE_W) == PTE_W) && ((*pte_store & PTE_W) != PTE_W)) {
f0104f75:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104f78:	f6 02 02             	testb  $0x2,(%edx)
f0104f7b:	0f 84 79 01 00 00    	je     f01050fa <syscall+0x649>
			return -E_INVAL;
		}

		if (!p) {
f0104f81:	85 c9                	test   %ecx,%ecx
f0104f83:	74 33                	je     f0104fb8 <syscall+0x507>
			return -E_INVAL;	
		}

		if ((uint32_t)e->env_ipc_dstva < UTOP){
f0104f85:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0104f88:	8b 42 78             	mov    0x78(%edx),%eax
f0104f8b:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f0104f90:	77 30                	ja     f0104fc2 <syscall+0x511>
			int pg_insert_check = page_insert(e->env_pgdir, p,
f0104f92:	ff 75 18             	pushl  0x18(%ebp)
f0104f95:	50                   	push   %eax
f0104f96:	51                   	push   %ecx
f0104f97:	ff 72 6c             	pushl  0x6c(%edx)
f0104f9a:	e8 cb c3 ff ff       	call   f010136a <page_insert>
	 				          e->env_ipc_dstva, perm);
	
			if (pg_insert_check < 0) {
f0104f9f:	83 c4 10             	add    $0x10,%esp
f0104fa2:	85 c0                	test   %eax,%eax
f0104fa4:	0f 88 50 01 00 00    	js     f01050fa <syscall+0x649>
				return pg_insert_check;
			}

			e->env_ipc_perm = perm;
f0104faa:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104fad:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0104fb0:	89 88 84 00 00 00    	mov    %ecx,0x84(%eax)
f0104fb6:	eb 0a                	jmp    f0104fc2 <syscall+0x511>
		if (((perm & PTE_W) == PTE_W) && ((*pte_store & PTE_W) != PTE_W)) {
			return -E_INVAL;
		}

		if (!p) {
			return -E_INVAL;	
f0104fb8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104fbd:	e9 38 01 00 00       	jmp    f01050fa <syscall+0x649>

			e->env_ipc_perm = perm;
		}
	}

	e->env_ipc_recving = false;
f0104fc2:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0104fc5:	c6 46 74 00          	movb   $0x0,0x74(%esi)
	e->env_ipc_from = curenv->env_id;
f0104fc9:	e8 34 12 00 00       	call   f0106202 <cpunum>
f0104fce:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fd1:	8b 80 28 70 21 f0    	mov    -0xfde8fd8(%eax),%eax
f0104fd7:	8b 40 54             	mov    0x54(%eax),%eax
f0104fda:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	e->env_ipc_value = value;
f0104fe0:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104fe3:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104fe6:	89 78 7c             	mov    %edi,0x7c(%eax)
	e->env_status = ENV_RUNNABLE;
f0104fe9:	c7 40 60 02 00 00 00 	movl   $0x2,0x60(%eax)
	e->env_tf.tf_regs.reg_eax = 0;
f0104ff0:	c7 40 28 00 00 00 00 	movl   $0x0,0x28(%eax)

	return 0;
f0104ff7:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ffc:	e9 f9 00 00 00       	jmp    f01050fa <syscall+0x649>
	if (env < 0) {
		return perm;
	}
	
	if (!e->env_ipc_recving) {
		return -E_IPC_NOT_RECV;
f0105001:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
		case SYS_yield:
			sys_yield();
			return 0;

		case SYS_ipc_try_send:
			return sys_ipc_try_send(a1, a2, (void*)a3, a4);
f0105006:	e9 ef 00 00 00       	jmp    f01050fa <syscall+0x649>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if ((uint32_t)dstva < UTOP) {
f010500b:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0105012:	77 0d                	ja     f0105021 <syscall+0x570>
		if (ROUNDDOWN((uint32_t)dstva, PGSIZE) != (uint32_t)dstva) {
f0105014:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f010501b:	0f 85 d4 00 00 00    	jne    f01050f5 <syscall+0x644>
			return -E_INVAL;
		}
	}
	curenv->env_ipc_recving = true;	
f0105021:	e8 dc 11 00 00       	call   f0106202 <cpunum>
f0105026:	6b c0 74             	imul   $0x74,%eax,%eax
f0105029:	8b 80 28 70 21 f0    	mov    -0xfde8fd8(%eax),%eax
f010502f:	c6 40 74 01          	movb   $0x1,0x74(%eax)
	curenv->env_ipc_dstva = dstva;
f0105033:	e8 ca 11 00 00       	call   f0106202 <cpunum>
f0105038:	6b c0 74             	imul   $0x74,%eax,%eax
f010503b:	8b 80 28 70 21 f0    	mov    -0xfde8fd8(%eax),%eax
f0105041:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105044:	89 48 78             	mov    %ecx,0x78(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0105047:	e8 b6 11 00 00       	call   f0106202 <cpunum>
f010504c:	6b c0 74             	imul   $0x74,%eax,%eax
f010504f:	8b 80 28 70 21 f0    	mov    -0xfde8fd8(%eax),%eax
f0105055:	c7 40 60 04 00 00 00 	movl   $0x4,0x60(%eax)
	curenv->env_tf.tf_regs.reg_eax = 0;
f010505c:	e8 a1 11 00 00       	call   f0106202 <cpunum>
f0105061:	6b c0 74             	imul   $0x74,%eax,%eax
f0105064:	8b 80 28 70 21 f0    	mov    -0xfde8fd8(%eax),%eax
f010506a:	c7 40 28 00 00 00 00 	movl   $0x0,0x28(%eax)

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0105071:	e8 15 f9 ff ff       	call   f010498b <sched_yield>
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!

	struct Env *e; 
	int env = envid2env(envid, &e, 1);
f0105076:	83 ec 04             	sub    $0x4,%esp
f0105079:	6a 01                	push   $0x1
f010507b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010507e:	50                   	push   %eax
f010507f:	ff 75 0c             	pushl  0xc(%ebp)
f0105082:	e8 2c e0 ff ff       	call   f01030b3 <envid2env>

	if (env < 0) { 
f0105087:	83 c4 10             	add    $0x10,%esp
f010508a:	85 c0                	test   %eax,%eax
f010508c:	78 6c                	js     f01050fa <syscall+0x649>
		return env;
	}

	user_mem_assert(e, tf, sizeof(struct Trapframe), PTE_U);
f010508e:	6a 04                	push   $0x4
f0105090:	6a 44                	push   $0x44
f0105092:	ff 75 10             	pushl  0x10(%ebp)
f0105095:	ff 75 f4             	pushl  -0xc(%ebp)
f0105098:	e8 12 df ff ff       	call   f0102faf <user_mem_assert>

	e->env_tf = *tf;
f010509d:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01050a0:	8d 7a 0c             	lea    0xc(%edx),%edi
f01050a3:	b9 11 00 00 00       	mov    $0x11,%ecx
f01050a8:	8b 75 10             	mov    0x10(%ebp),%esi
f01050ab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_tf.tf_eflags |= FL_IF;
	e->env_tf.tf_cs = GD_UT | 3;
f01050ad:	66 c7 42 40 1b 00    	movw   $0x1b,0x40(%edx)
	//shoutout to fgt(x)
	e->env_tf.tf_eflags &= ~FL_IOPL_3;
f01050b3:	8b 42 44             	mov    0x44(%edx),%eax
f01050b6:	80 e4 cf             	and    $0xcf,%ah
f01050b9:	80 cc 02             	or     $0x2,%ah
f01050bc:	89 42 44             	mov    %eax,0x44(%edx)
f01050bf:	83 c4 10             	add    $0x10,%esp

	return 0;
f01050c2:	b8 00 00 00 00       	mov    $0x0,%eax
f01050c7:	eb 31                	jmp    f01050fa <syscall+0x649>

// LAB 7 Multithreading
		case SYS_thread_create:
			//void (*func)() = (void(*)())a1;
			//return sys_thread_create((void(*)())a1/*func*/);
			return sys_thread_create((uintptr_t) a1);
f01050c9:	83 ec 0c             	sub    $0xc,%esp
f01050cc:	ff 75 0c             	pushl  0xc(%ebp)
f01050cf:	e8 97 f9 ff ff       	call   f0104a6b <sys_thread_create>
f01050d4:	83 c4 10             	add    $0x10,%esp
f01050d7:	eb 21                	jmp    f01050fa <syscall+0x649>

		case SYS_thread_free:
			sys_thread_free((envid_t)a1);
f01050d9:	83 ec 0c             	sub    $0xc,%esp
f01050dc:	ff 75 0c             	pushl  0xc(%ebp)
f01050df:	e8 a9 f9 ff ff       	call   f0104a8d <sys_thread_free>
			return 0;
f01050e4:	83 c4 10             	add    $0x10,%esp
f01050e7:	b8 00 00 00 00       	mov    $0x0,%eax
f01050ec:	eb 0c                	jmp    f01050fa <syscall+0x649>

		default:
			return -E_INVAL;
f01050ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01050f3:	eb 05                	jmp    f01050fa <syscall+0x649>

		case SYS_ipc_try_send:
			return sys_ipc_try_send(a1, a2, (void*)a3, a4);

		case SYS_ipc_recv:
			return sys_ipc_recv((void*)a1);
f01050f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			return 0;

		default:
			return -E_INVAL;
	}
}
f01050fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01050fd:	5e                   	pop    %esi
f01050fe:	5f                   	pop    %edi
f01050ff:	5d                   	pop    %ebp
f0105100:	c3                   	ret    

f0105101 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0105101:	55                   	push   %ebp
f0105102:	89 e5                	mov    %esp,%ebp
f0105104:	57                   	push   %edi
f0105105:	56                   	push   %esi
f0105106:	53                   	push   %ebx
f0105107:	83 ec 14             	sub    $0x14,%esp
f010510a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010510d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0105110:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105113:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0105116:	8b 1a                	mov    (%edx),%ebx
f0105118:	8b 01                	mov    (%ecx),%eax
f010511a:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010511d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0105124:	eb 7f                	jmp    f01051a5 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0105126:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105129:	01 d8                	add    %ebx,%eax
f010512b:	89 c6                	mov    %eax,%esi
f010512d:	c1 ee 1f             	shr    $0x1f,%esi
f0105130:	01 c6                	add    %eax,%esi
f0105132:	d1 fe                	sar    %esi
f0105134:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0105137:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010513a:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f010513d:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010513f:	eb 03                	jmp    f0105144 <stab_binsearch+0x43>
			m--;
f0105141:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105144:	39 c3                	cmp    %eax,%ebx
f0105146:	7f 0d                	jg     f0105155 <stab_binsearch+0x54>
f0105148:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010514c:	83 ea 0c             	sub    $0xc,%edx
f010514f:	39 f9                	cmp    %edi,%ecx
f0105151:	75 ee                	jne    f0105141 <stab_binsearch+0x40>
f0105153:	eb 05                	jmp    f010515a <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0105155:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0105158:	eb 4b                	jmp    f01051a5 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010515a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010515d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105160:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0105164:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0105167:	76 11                	jbe    f010517a <stab_binsearch+0x79>
			*region_left = m;
f0105169:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010516c:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010516e:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105171:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105178:	eb 2b                	jmp    f01051a5 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010517a:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010517d:	73 14                	jae    f0105193 <stab_binsearch+0x92>
			*region_right = m - 1;
f010517f:	83 e8 01             	sub    $0x1,%eax
f0105182:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105185:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105188:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010518a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105191:	eb 12                	jmp    f01051a5 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0105193:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105196:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0105198:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010519c:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010519e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01051a5:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01051a8:	0f 8e 78 ff ff ff    	jle    f0105126 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01051ae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01051b2:	75 0f                	jne    f01051c3 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f01051b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01051b7:	8b 00                	mov    (%eax),%eax
f01051b9:	83 e8 01             	sub    $0x1,%eax
f01051bc:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01051bf:	89 06                	mov    %eax,(%esi)
f01051c1:	eb 2c                	jmp    f01051ef <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01051c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01051c6:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01051c8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01051cb:	8b 0e                	mov    (%esi),%ecx
f01051cd:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01051d0:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01051d3:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01051d6:	eb 03                	jmp    f01051db <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01051d8:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01051db:	39 c8                	cmp    %ecx,%eax
f01051dd:	7e 0b                	jle    f01051ea <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f01051df:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01051e3:	83 ea 0c             	sub    $0xc,%edx
f01051e6:	39 df                	cmp    %ebx,%edi
f01051e8:	75 ee                	jne    f01051d8 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f01051ea:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01051ed:	89 06                	mov    %eax,(%esi)
	}
}
f01051ef:	83 c4 14             	add    $0x14,%esp
f01051f2:	5b                   	pop    %ebx
f01051f3:	5e                   	pop    %esi
f01051f4:	5f                   	pop    %edi
f01051f5:	5d                   	pop    %ebp
f01051f6:	c3                   	ret    

f01051f7 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01051f7:	55                   	push   %ebp
f01051f8:	89 e5                	mov    %esp,%ebp
f01051fa:	57                   	push   %edi
f01051fb:	56                   	push   %esi
f01051fc:	53                   	push   %ebx
f01051fd:	83 ec 3c             	sub    $0x3c,%esp
f0105200:	8b 75 08             	mov    0x8(%ebp),%esi
f0105203:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0105206:	c7 03 74 81 10 f0    	movl   $0xf0108174,(%ebx)
	info->eip_line = 0;
f010520c:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0105213:	c7 43 08 74 81 10 f0 	movl   $0xf0108174,0x8(%ebx)
	info->eip_fn_namelen = 9;
f010521a:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0105221:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0105224:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010522b:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0105231:	77 21                	ja     f0105254 <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0105233:	a1 00 00 20 00       	mov    0x200000,%eax
f0105238:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stab_end = usd->stab_end;
f010523b:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0105240:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f0105246:	89 7d b8             	mov    %edi,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0105249:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f010524f:	89 7d c0             	mov    %edi,-0x40(%ebp)
f0105252:	eb 1a                	jmp    f010526e <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0105254:	c7 45 c0 84 6a 11 f0 	movl   $0xf0116a84,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f010525b:	c7 45 b8 a9 30 11 f0 	movl   $0xf01130a9,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0105262:	b8 a8 30 11 f0       	mov    $0xf01130a8,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0105267:	c7 45 bc 10 87 10 f0 	movl   $0xf0108710,-0x44(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010526e:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0105271:	39 7d b8             	cmp    %edi,-0x48(%ebp)
f0105274:	0f 83 95 01 00 00    	jae    f010540f <debuginfo_eip+0x218>
f010527a:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f010527e:	0f 85 92 01 00 00    	jne    f0105416 <debuginfo_eip+0x21f>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105284:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010528b:	8b 7d bc             	mov    -0x44(%ebp),%edi
f010528e:	29 f8                	sub    %edi,%eax
f0105290:	c1 f8 02             	sar    $0x2,%eax
f0105293:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0105299:	83 e8 01             	sub    $0x1,%eax
f010529c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010529f:	56                   	push   %esi
f01052a0:	6a 64                	push   $0x64
f01052a2:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01052a5:	89 c1                	mov    %eax,%ecx
f01052a7:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01052aa:	89 f8                	mov    %edi,%eax
f01052ac:	e8 50 fe ff ff       	call   f0105101 <stab_binsearch>
	if (lfile == 0)
f01052b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01052b4:	83 c4 08             	add    $0x8,%esp
f01052b7:	85 c0                	test   %eax,%eax
f01052b9:	0f 84 5e 01 00 00    	je     f010541d <debuginfo_eip+0x226>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01052bf:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01052c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01052c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01052c8:	56                   	push   %esi
f01052c9:	6a 24                	push   $0x24
f01052cb:	8d 45 d8             	lea    -0x28(%ebp),%eax
f01052ce:	89 c1                	mov    %eax,%ecx
f01052d0:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01052d3:	89 f8                	mov    %edi,%eax
f01052d5:	e8 27 fe ff ff       	call   f0105101 <stab_binsearch>

	if (lfun <= rfun) {
f01052da:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01052dd:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01052e0:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f01052e3:	83 c4 08             	add    $0x8,%esp
f01052e6:	39 d0                	cmp    %edx,%eax
f01052e8:	7f 2b                	jg     f0105315 <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01052ea:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01052ed:	8d 0c 97             	lea    (%edi,%edx,4),%ecx
f01052f0:	8b 11                	mov    (%ecx),%edx
f01052f2:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01052f5:	2b 7d b8             	sub    -0x48(%ebp),%edi
f01052f8:	39 fa                	cmp    %edi,%edx
f01052fa:	73 06                	jae    f0105302 <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01052fc:	03 55 b8             	add    -0x48(%ebp),%edx
f01052ff:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0105302:	8b 51 08             	mov    0x8(%ecx),%edx
f0105305:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0105308:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f010530a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f010530d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105310:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105313:	eb 0f                	jmp    f0105324 <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0105315:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0105318:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010531b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f010531e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105321:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0105324:	83 ec 08             	sub    $0x8,%esp
f0105327:	6a 3a                	push   $0x3a
f0105329:	ff 73 08             	pushl  0x8(%ebx)
f010532c:	e8 92 08 00 00       	call   f0105bc3 <strfind>
f0105331:	2b 43 08             	sub    0x8(%ebx),%eax
f0105334:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0105337:	83 c4 08             	add    $0x8,%esp
f010533a:	56                   	push   %esi
f010533b:	6a 44                	push   $0x44
f010533d:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0105340:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0105343:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0105346:	89 f0                	mov    %esi,%eax
f0105348:	e8 b4 fd ff ff       	call   f0105101 <stab_binsearch>
	if (lline == rline) {
f010534d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105350:	83 c4 10             	add    $0x10,%esp
f0105353:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0105356:	0f 85 c8 00 00 00    	jne    f0105424 <debuginfo_eip+0x22d>
		info->eip_line = stabs[lline].n_desc;
f010535c:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010535f:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0105362:	0f b7 4a 06          	movzwl 0x6(%edx),%ecx
f0105366:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105369:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010536c:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0105370:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105373:	eb 0a                	jmp    f010537f <debuginfo_eip+0x188>
f0105375:	83 e8 01             	sub    $0x1,%eax
f0105378:	83 ea 0c             	sub    $0xc,%edx
f010537b:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f010537f:	39 c7                	cmp    %eax,%edi
f0105381:	7e 05                	jle    f0105388 <debuginfo_eip+0x191>
f0105383:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105386:	eb 47                	jmp    f01053cf <debuginfo_eip+0x1d8>
	       && stabs[lline].n_type != N_SOL
f0105388:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010538c:	80 f9 84             	cmp    $0x84,%cl
f010538f:	75 0e                	jne    f010539f <debuginfo_eip+0x1a8>
f0105391:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105394:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0105398:	74 1c                	je     f01053b6 <debuginfo_eip+0x1bf>
f010539a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010539d:	eb 17                	jmp    f01053b6 <debuginfo_eip+0x1bf>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010539f:	80 f9 64             	cmp    $0x64,%cl
f01053a2:	75 d1                	jne    f0105375 <debuginfo_eip+0x17e>
f01053a4:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f01053a8:	74 cb                	je     f0105375 <debuginfo_eip+0x17e>
f01053aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01053ad:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f01053b1:	74 03                	je     f01053b6 <debuginfo_eip+0x1bf>
f01053b3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01053b6:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01053b9:	8b 75 bc             	mov    -0x44(%ebp),%esi
f01053bc:	8b 14 86             	mov    (%esi,%eax,4),%edx
f01053bf:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01053c2:	8b 75 b8             	mov    -0x48(%ebp),%esi
f01053c5:	29 f0                	sub    %esi,%eax
f01053c7:	39 c2                	cmp    %eax,%edx
f01053c9:	73 04                	jae    f01053cf <debuginfo_eip+0x1d8>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01053cb:	01 f2                	add    %esi,%edx
f01053cd:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01053cf:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01053d2:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01053d5:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01053da:	39 f2                	cmp    %esi,%edx
f01053dc:	7d 52                	jge    f0105430 <debuginfo_eip+0x239>
		for (lline = lfun + 1;
f01053de:	83 c2 01             	add    $0x1,%edx
f01053e1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01053e4:	89 d0                	mov    %edx,%eax
f01053e6:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01053e9:	8b 7d bc             	mov    -0x44(%ebp),%edi
f01053ec:	8d 14 97             	lea    (%edi,%edx,4),%edx
f01053ef:	eb 04                	jmp    f01053f5 <debuginfo_eip+0x1fe>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01053f1:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01053f5:	39 c6                	cmp    %eax,%esi
f01053f7:	7e 32                	jle    f010542b <debuginfo_eip+0x234>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01053f9:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01053fd:	83 c0 01             	add    $0x1,%eax
f0105400:	83 c2 0c             	add    $0xc,%edx
f0105403:	80 f9 a0             	cmp    $0xa0,%cl
f0105406:	74 e9                	je     f01053f1 <debuginfo_eip+0x1fa>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105408:	b8 00 00 00 00       	mov    $0x0,%eax
f010540d:	eb 21                	jmp    f0105430 <debuginfo_eip+0x239>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f010540f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105414:	eb 1a                	jmp    f0105430 <debuginfo_eip+0x239>
f0105416:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010541b:	eb 13                	jmp    f0105430 <debuginfo_eip+0x239>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f010541d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105422:	eb 0c                	jmp    f0105430 <debuginfo_eip+0x239>
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline == rline) {
		info->eip_line = stabs[lline].n_desc;
	} else {
		return -1;	
f0105424:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105429:	eb 05                	jmp    f0105430 <debuginfo_eip+0x239>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010542b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105430:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105433:	5b                   	pop    %ebx
f0105434:	5e                   	pop    %esi
f0105435:	5f                   	pop    %edi
f0105436:	5d                   	pop    %ebp
f0105437:	c3                   	ret    

f0105438 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105438:	55                   	push   %ebp
f0105439:	89 e5                	mov    %esp,%ebp
f010543b:	57                   	push   %edi
f010543c:	56                   	push   %esi
f010543d:	53                   	push   %ebx
f010543e:	83 ec 1c             	sub    $0x1c,%esp
f0105441:	89 c7                	mov    %eax,%edi
f0105443:	89 d6                	mov    %edx,%esi
f0105445:	8b 45 08             	mov    0x8(%ebp),%eax
f0105448:	8b 55 0c             	mov    0xc(%ebp),%edx
f010544b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010544e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105451:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0105454:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105459:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010545c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f010545f:	39 d3                	cmp    %edx,%ebx
f0105461:	72 05                	jb     f0105468 <printnum+0x30>
f0105463:	39 45 10             	cmp    %eax,0x10(%ebp)
f0105466:	77 45                	ja     f01054ad <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105468:	83 ec 0c             	sub    $0xc,%esp
f010546b:	ff 75 18             	pushl  0x18(%ebp)
f010546e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105471:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0105474:	53                   	push   %ebx
f0105475:	ff 75 10             	pushl  0x10(%ebp)
f0105478:	83 ec 08             	sub    $0x8,%esp
f010547b:	ff 75 e4             	pushl  -0x1c(%ebp)
f010547e:	ff 75 e0             	pushl  -0x20(%ebp)
f0105481:	ff 75 dc             	pushl  -0x24(%ebp)
f0105484:	ff 75 d8             	pushl  -0x28(%ebp)
f0105487:	e8 74 11 00 00       	call   f0106600 <__udivdi3>
f010548c:	83 c4 18             	add    $0x18,%esp
f010548f:	52                   	push   %edx
f0105490:	50                   	push   %eax
f0105491:	89 f2                	mov    %esi,%edx
f0105493:	89 f8                	mov    %edi,%eax
f0105495:	e8 9e ff ff ff       	call   f0105438 <printnum>
f010549a:	83 c4 20             	add    $0x20,%esp
f010549d:	eb 18                	jmp    f01054b7 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010549f:	83 ec 08             	sub    $0x8,%esp
f01054a2:	56                   	push   %esi
f01054a3:	ff 75 18             	pushl  0x18(%ebp)
f01054a6:	ff d7                	call   *%edi
f01054a8:	83 c4 10             	add    $0x10,%esp
f01054ab:	eb 03                	jmp    f01054b0 <printnum+0x78>
f01054ad:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01054b0:	83 eb 01             	sub    $0x1,%ebx
f01054b3:	85 db                	test   %ebx,%ebx
f01054b5:	7f e8                	jg     f010549f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01054b7:	83 ec 08             	sub    $0x8,%esp
f01054ba:	56                   	push   %esi
f01054bb:	83 ec 04             	sub    $0x4,%esp
f01054be:	ff 75 e4             	pushl  -0x1c(%ebp)
f01054c1:	ff 75 e0             	pushl  -0x20(%ebp)
f01054c4:	ff 75 dc             	pushl  -0x24(%ebp)
f01054c7:	ff 75 d8             	pushl  -0x28(%ebp)
f01054ca:	e8 61 12 00 00       	call   f0106730 <__umoddi3>
f01054cf:	83 c4 14             	add    $0x14,%esp
f01054d2:	0f be 80 7e 81 10 f0 	movsbl -0xfef7e82(%eax),%eax
f01054d9:	50                   	push   %eax
f01054da:	ff d7                	call   *%edi
}
f01054dc:	83 c4 10             	add    $0x10,%esp
f01054df:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01054e2:	5b                   	pop    %ebx
f01054e3:	5e                   	pop    %esi
f01054e4:	5f                   	pop    %edi
f01054e5:	5d                   	pop    %ebp
f01054e6:	c3                   	ret    

f01054e7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01054e7:	55                   	push   %ebp
f01054e8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01054ea:	83 fa 01             	cmp    $0x1,%edx
f01054ed:	7e 0e                	jle    f01054fd <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01054ef:	8b 10                	mov    (%eax),%edx
f01054f1:	8d 4a 08             	lea    0x8(%edx),%ecx
f01054f4:	89 08                	mov    %ecx,(%eax)
f01054f6:	8b 02                	mov    (%edx),%eax
f01054f8:	8b 52 04             	mov    0x4(%edx),%edx
f01054fb:	eb 22                	jmp    f010551f <getuint+0x38>
	else if (lflag)
f01054fd:	85 d2                	test   %edx,%edx
f01054ff:	74 10                	je     f0105511 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105501:	8b 10                	mov    (%eax),%edx
f0105503:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105506:	89 08                	mov    %ecx,(%eax)
f0105508:	8b 02                	mov    (%edx),%eax
f010550a:	ba 00 00 00 00       	mov    $0x0,%edx
f010550f:	eb 0e                	jmp    f010551f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105511:	8b 10                	mov    (%eax),%edx
f0105513:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105516:	89 08                	mov    %ecx,(%eax)
f0105518:	8b 02                	mov    (%edx),%eax
f010551a:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010551f:	5d                   	pop    %ebp
f0105520:	c3                   	ret    

f0105521 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105521:	55                   	push   %ebp
f0105522:	89 e5                	mov    %esp,%ebp
f0105524:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105527:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010552b:	8b 10                	mov    (%eax),%edx
f010552d:	3b 50 04             	cmp    0x4(%eax),%edx
f0105530:	73 0a                	jae    f010553c <sprintputch+0x1b>
		*b->buf++ = ch;
f0105532:	8d 4a 01             	lea    0x1(%edx),%ecx
f0105535:	89 08                	mov    %ecx,(%eax)
f0105537:	8b 45 08             	mov    0x8(%ebp),%eax
f010553a:	88 02                	mov    %al,(%edx)
}
f010553c:	5d                   	pop    %ebp
f010553d:	c3                   	ret    

f010553e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f010553e:	55                   	push   %ebp
f010553f:	89 e5                	mov    %esp,%ebp
f0105541:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0105544:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105547:	50                   	push   %eax
f0105548:	ff 75 10             	pushl  0x10(%ebp)
f010554b:	ff 75 0c             	pushl  0xc(%ebp)
f010554e:	ff 75 08             	pushl  0x8(%ebp)
f0105551:	e8 05 00 00 00       	call   f010555b <vprintfmt>
	va_end(ap);
}
f0105556:	83 c4 10             	add    $0x10,%esp
f0105559:	c9                   	leave  
f010555a:	c3                   	ret    

f010555b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010555b:	55                   	push   %ebp
f010555c:	89 e5                	mov    %esp,%ebp
f010555e:	57                   	push   %edi
f010555f:	56                   	push   %esi
f0105560:	53                   	push   %ebx
f0105561:	83 ec 2c             	sub    $0x2c,%esp
f0105564:	8b 75 08             	mov    0x8(%ebp),%esi
f0105567:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010556a:	8b 7d 10             	mov    0x10(%ebp),%edi
f010556d:	eb 12                	jmp    f0105581 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f010556f:	85 c0                	test   %eax,%eax
f0105571:	0f 84 89 03 00 00    	je     f0105900 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0105577:	83 ec 08             	sub    $0x8,%esp
f010557a:	53                   	push   %ebx
f010557b:	50                   	push   %eax
f010557c:	ff d6                	call   *%esi
f010557e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105581:	83 c7 01             	add    $0x1,%edi
f0105584:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105588:	83 f8 25             	cmp    $0x25,%eax
f010558b:	75 e2                	jne    f010556f <vprintfmt+0x14>
f010558d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0105591:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0105598:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f010559f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f01055a6:	ba 00 00 00 00       	mov    $0x0,%edx
f01055ab:	eb 07                	jmp    f01055b4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01055ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f01055b0:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01055b4:	8d 47 01             	lea    0x1(%edi),%eax
f01055b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01055ba:	0f b6 07             	movzbl (%edi),%eax
f01055bd:	0f b6 c8             	movzbl %al,%ecx
f01055c0:	83 e8 23             	sub    $0x23,%eax
f01055c3:	3c 55                	cmp    $0x55,%al
f01055c5:	0f 87 1a 03 00 00    	ja     f01058e5 <vprintfmt+0x38a>
f01055cb:	0f b6 c0             	movzbl %al,%eax
f01055ce:	ff 24 85 c0 82 10 f0 	jmp    *-0xfef7d40(,%eax,4)
f01055d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01055d8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f01055dc:	eb d6                	jmp    f01055b4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01055de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01055e1:	b8 00 00 00 00       	mov    $0x0,%eax
f01055e6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01055e9:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01055ec:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f01055f0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f01055f3:	8d 51 d0             	lea    -0x30(%ecx),%edx
f01055f6:	83 fa 09             	cmp    $0x9,%edx
f01055f9:	77 39                	ja     f0105634 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01055fb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f01055fe:	eb e9                	jmp    f01055e9 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105600:	8b 45 14             	mov    0x14(%ebp),%eax
f0105603:	8d 48 04             	lea    0x4(%eax),%ecx
f0105606:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105609:	8b 00                	mov    (%eax),%eax
f010560b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010560e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105611:	eb 27                	jmp    f010563a <vprintfmt+0xdf>
f0105613:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105616:	85 c0                	test   %eax,%eax
f0105618:	b9 00 00 00 00       	mov    $0x0,%ecx
f010561d:	0f 49 c8             	cmovns %eax,%ecx
f0105620:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105623:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105626:	eb 8c                	jmp    f01055b4 <vprintfmt+0x59>
f0105628:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f010562b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0105632:	eb 80                	jmp    f01055b4 <vprintfmt+0x59>
f0105634:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105637:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f010563a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010563e:	0f 89 70 ff ff ff    	jns    f01055b4 <vprintfmt+0x59>
				width = precision, precision = -1;
f0105644:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105647:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010564a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105651:	e9 5e ff ff ff       	jmp    f01055b4 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105656:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105659:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f010565c:	e9 53 ff ff ff       	jmp    f01055b4 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105661:	8b 45 14             	mov    0x14(%ebp),%eax
f0105664:	8d 50 04             	lea    0x4(%eax),%edx
f0105667:	89 55 14             	mov    %edx,0x14(%ebp)
f010566a:	83 ec 08             	sub    $0x8,%esp
f010566d:	53                   	push   %ebx
f010566e:	ff 30                	pushl  (%eax)
f0105670:	ff d6                	call   *%esi
			break;
f0105672:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105675:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105678:	e9 04 ff ff ff       	jmp    f0105581 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f010567d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105680:	8d 50 04             	lea    0x4(%eax),%edx
f0105683:	89 55 14             	mov    %edx,0x14(%ebp)
f0105686:	8b 00                	mov    (%eax),%eax
f0105688:	99                   	cltd   
f0105689:	31 d0                	xor    %edx,%eax
f010568b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010568d:	83 f8 0f             	cmp    $0xf,%eax
f0105690:	7f 0b                	jg     f010569d <vprintfmt+0x142>
f0105692:	8b 14 85 20 84 10 f0 	mov    -0xfef7be0(,%eax,4),%edx
f0105699:	85 d2                	test   %edx,%edx
f010569b:	75 18                	jne    f01056b5 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f010569d:	50                   	push   %eax
f010569e:	68 96 81 10 f0       	push   $0xf0108196
f01056a3:	53                   	push   %ebx
f01056a4:	56                   	push   %esi
f01056a5:	e8 94 fe ff ff       	call   f010553e <printfmt>
f01056aa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01056ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01056b0:	e9 cc fe ff ff       	jmp    f0105581 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f01056b5:	52                   	push   %edx
f01056b6:	68 e6 77 10 f0       	push   $0xf01077e6
f01056bb:	53                   	push   %ebx
f01056bc:	56                   	push   %esi
f01056bd:	e8 7c fe ff ff       	call   f010553e <printfmt>
f01056c2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01056c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01056c8:	e9 b4 fe ff ff       	jmp    f0105581 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01056cd:	8b 45 14             	mov    0x14(%ebp),%eax
f01056d0:	8d 50 04             	lea    0x4(%eax),%edx
f01056d3:	89 55 14             	mov    %edx,0x14(%ebp)
f01056d6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f01056d8:	85 ff                	test   %edi,%edi
f01056da:	b8 8f 81 10 f0       	mov    $0xf010818f,%eax
f01056df:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f01056e2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01056e6:	0f 8e 94 00 00 00    	jle    f0105780 <vprintfmt+0x225>
f01056ec:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f01056f0:	0f 84 98 00 00 00    	je     f010578e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f01056f6:	83 ec 08             	sub    $0x8,%esp
f01056f9:	ff 75 d0             	pushl  -0x30(%ebp)
f01056fc:	57                   	push   %edi
f01056fd:	e8 77 03 00 00       	call   f0105a79 <strnlen>
f0105702:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105705:	29 c1                	sub    %eax,%ecx
f0105707:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f010570a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f010570d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0105711:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105714:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105717:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105719:	eb 0f                	jmp    f010572a <vprintfmt+0x1cf>
					putch(padc, putdat);
f010571b:	83 ec 08             	sub    $0x8,%esp
f010571e:	53                   	push   %ebx
f010571f:	ff 75 e0             	pushl  -0x20(%ebp)
f0105722:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105724:	83 ef 01             	sub    $0x1,%edi
f0105727:	83 c4 10             	add    $0x10,%esp
f010572a:	85 ff                	test   %edi,%edi
f010572c:	7f ed                	jg     f010571b <vprintfmt+0x1c0>
f010572e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105731:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0105734:	85 c9                	test   %ecx,%ecx
f0105736:	b8 00 00 00 00       	mov    $0x0,%eax
f010573b:	0f 49 c1             	cmovns %ecx,%eax
f010573e:	29 c1                	sub    %eax,%ecx
f0105740:	89 75 08             	mov    %esi,0x8(%ebp)
f0105743:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105746:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105749:	89 cb                	mov    %ecx,%ebx
f010574b:	eb 4d                	jmp    f010579a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f010574d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105751:	74 1b                	je     f010576e <vprintfmt+0x213>
f0105753:	0f be c0             	movsbl %al,%eax
f0105756:	83 e8 20             	sub    $0x20,%eax
f0105759:	83 f8 5e             	cmp    $0x5e,%eax
f010575c:	76 10                	jbe    f010576e <vprintfmt+0x213>
					putch('?', putdat);
f010575e:	83 ec 08             	sub    $0x8,%esp
f0105761:	ff 75 0c             	pushl  0xc(%ebp)
f0105764:	6a 3f                	push   $0x3f
f0105766:	ff 55 08             	call   *0x8(%ebp)
f0105769:	83 c4 10             	add    $0x10,%esp
f010576c:	eb 0d                	jmp    f010577b <vprintfmt+0x220>
				else
					putch(ch, putdat);
f010576e:	83 ec 08             	sub    $0x8,%esp
f0105771:	ff 75 0c             	pushl  0xc(%ebp)
f0105774:	52                   	push   %edx
f0105775:	ff 55 08             	call   *0x8(%ebp)
f0105778:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010577b:	83 eb 01             	sub    $0x1,%ebx
f010577e:	eb 1a                	jmp    f010579a <vprintfmt+0x23f>
f0105780:	89 75 08             	mov    %esi,0x8(%ebp)
f0105783:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105786:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105789:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010578c:	eb 0c                	jmp    f010579a <vprintfmt+0x23f>
f010578e:	89 75 08             	mov    %esi,0x8(%ebp)
f0105791:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105794:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105797:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010579a:	83 c7 01             	add    $0x1,%edi
f010579d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01057a1:	0f be d0             	movsbl %al,%edx
f01057a4:	85 d2                	test   %edx,%edx
f01057a6:	74 23                	je     f01057cb <vprintfmt+0x270>
f01057a8:	85 f6                	test   %esi,%esi
f01057aa:	78 a1                	js     f010574d <vprintfmt+0x1f2>
f01057ac:	83 ee 01             	sub    $0x1,%esi
f01057af:	79 9c                	jns    f010574d <vprintfmt+0x1f2>
f01057b1:	89 df                	mov    %ebx,%edi
f01057b3:	8b 75 08             	mov    0x8(%ebp),%esi
f01057b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01057b9:	eb 18                	jmp    f01057d3 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01057bb:	83 ec 08             	sub    $0x8,%esp
f01057be:	53                   	push   %ebx
f01057bf:	6a 20                	push   $0x20
f01057c1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01057c3:	83 ef 01             	sub    $0x1,%edi
f01057c6:	83 c4 10             	add    $0x10,%esp
f01057c9:	eb 08                	jmp    f01057d3 <vprintfmt+0x278>
f01057cb:	89 df                	mov    %ebx,%edi
f01057cd:	8b 75 08             	mov    0x8(%ebp),%esi
f01057d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01057d3:	85 ff                	test   %edi,%edi
f01057d5:	7f e4                	jg     f01057bb <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01057d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01057da:	e9 a2 fd ff ff       	jmp    f0105581 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01057df:	83 fa 01             	cmp    $0x1,%edx
f01057e2:	7e 16                	jle    f01057fa <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f01057e4:	8b 45 14             	mov    0x14(%ebp),%eax
f01057e7:	8d 50 08             	lea    0x8(%eax),%edx
f01057ea:	89 55 14             	mov    %edx,0x14(%ebp)
f01057ed:	8b 50 04             	mov    0x4(%eax),%edx
f01057f0:	8b 00                	mov    (%eax),%eax
f01057f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01057f5:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01057f8:	eb 32                	jmp    f010582c <vprintfmt+0x2d1>
	else if (lflag)
f01057fa:	85 d2                	test   %edx,%edx
f01057fc:	74 18                	je     f0105816 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f01057fe:	8b 45 14             	mov    0x14(%ebp),%eax
f0105801:	8d 50 04             	lea    0x4(%eax),%edx
f0105804:	89 55 14             	mov    %edx,0x14(%ebp)
f0105807:	8b 00                	mov    (%eax),%eax
f0105809:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010580c:	89 c1                	mov    %eax,%ecx
f010580e:	c1 f9 1f             	sar    $0x1f,%ecx
f0105811:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105814:	eb 16                	jmp    f010582c <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0105816:	8b 45 14             	mov    0x14(%ebp),%eax
f0105819:	8d 50 04             	lea    0x4(%eax),%edx
f010581c:	89 55 14             	mov    %edx,0x14(%ebp)
f010581f:	8b 00                	mov    (%eax),%eax
f0105821:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105824:	89 c1                	mov    %eax,%ecx
f0105826:	c1 f9 1f             	sar    $0x1f,%ecx
f0105829:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010582c:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010582f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105832:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0105837:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010583b:	79 74                	jns    f01058b1 <vprintfmt+0x356>
				putch('-', putdat);
f010583d:	83 ec 08             	sub    $0x8,%esp
f0105840:	53                   	push   %ebx
f0105841:	6a 2d                	push   $0x2d
f0105843:	ff d6                	call   *%esi
				num = -(long long) num;
f0105845:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105848:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010584b:	f7 d8                	neg    %eax
f010584d:	83 d2 00             	adc    $0x0,%edx
f0105850:	f7 da                	neg    %edx
f0105852:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0105855:	b9 0a 00 00 00       	mov    $0xa,%ecx
f010585a:	eb 55                	jmp    f01058b1 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f010585c:	8d 45 14             	lea    0x14(%ebp),%eax
f010585f:	e8 83 fc ff ff       	call   f01054e7 <getuint>
			base = 10;
f0105864:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0105869:	eb 46                	jmp    f01058b1 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f010586b:	8d 45 14             	lea    0x14(%ebp),%eax
f010586e:	e8 74 fc ff ff       	call   f01054e7 <getuint>
			base = 8;
f0105873:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0105878:	eb 37                	jmp    f01058b1 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f010587a:	83 ec 08             	sub    $0x8,%esp
f010587d:	53                   	push   %ebx
f010587e:	6a 30                	push   $0x30
f0105880:	ff d6                	call   *%esi
			putch('x', putdat);
f0105882:	83 c4 08             	add    $0x8,%esp
f0105885:	53                   	push   %ebx
f0105886:	6a 78                	push   $0x78
f0105888:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010588a:	8b 45 14             	mov    0x14(%ebp),%eax
f010588d:	8d 50 04             	lea    0x4(%eax),%edx
f0105890:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105893:	8b 00                	mov    (%eax),%eax
f0105895:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f010589a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f010589d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f01058a2:	eb 0d                	jmp    f01058b1 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01058a4:	8d 45 14             	lea    0x14(%ebp),%eax
f01058a7:	e8 3b fc ff ff       	call   f01054e7 <getuint>
			base = 16;
f01058ac:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f01058b1:	83 ec 0c             	sub    $0xc,%esp
f01058b4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01058b8:	57                   	push   %edi
f01058b9:	ff 75 e0             	pushl  -0x20(%ebp)
f01058bc:	51                   	push   %ecx
f01058bd:	52                   	push   %edx
f01058be:	50                   	push   %eax
f01058bf:	89 da                	mov    %ebx,%edx
f01058c1:	89 f0                	mov    %esi,%eax
f01058c3:	e8 70 fb ff ff       	call   f0105438 <printnum>
			break;
f01058c8:	83 c4 20             	add    $0x20,%esp
f01058cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01058ce:	e9 ae fc ff ff       	jmp    f0105581 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01058d3:	83 ec 08             	sub    $0x8,%esp
f01058d6:	53                   	push   %ebx
f01058d7:	51                   	push   %ecx
f01058d8:	ff d6                	call   *%esi
			break;
f01058da:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01058dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01058e0:	e9 9c fc ff ff       	jmp    f0105581 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01058e5:	83 ec 08             	sub    $0x8,%esp
f01058e8:	53                   	push   %ebx
f01058e9:	6a 25                	push   $0x25
f01058eb:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01058ed:	83 c4 10             	add    $0x10,%esp
f01058f0:	eb 03                	jmp    f01058f5 <vprintfmt+0x39a>
f01058f2:	83 ef 01             	sub    $0x1,%edi
f01058f5:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f01058f9:	75 f7                	jne    f01058f2 <vprintfmt+0x397>
f01058fb:	e9 81 fc ff ff       	jmp    f0105581 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0105900:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105903:	5b                   	pop    %ebx
f0105904:	5e                   	pop    %esi
f0105905:	5f                   	pop    %edi
f0105906:	5d                   	pop    %ebp
f0105907:	c3                   	ret    

f0105908 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105908:	55                   	push   %ebp
f0105909:	89 e5                	mov    %esp,%ebp
f010590b:	83 ec 18             	sub    $0x18,%esp
f010590e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105911:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105914:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105917:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010591b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010591e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105925:	85 c0                	test   %eax,%eax
f0105927:	74 26                	je     f010594f <vsnprintf+0x47>
f0105929:	85 d2                	test   %edx,%edx
f010592b:	7e 22                	jle    f010594f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010592d:	ff 75 14             	pushl  0x14(%ebp)
f0105930:	ff 75 10             	pushl  0x10(%ebp)
f0105933:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105936:	50                   	push   %eax
f0105937:	68 21 55 10 f0       	push   $0xf0105521
f010593c:	e8 1a fc ff ff       	call   f010555b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105941:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105944:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105947:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010594a:	83 c4 10             	add    $0x10,%esp
f010594d:	eb 05                	jmp    f0105954 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010594f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105954:	c9                   	leave  
f0105955:	c3                   	ret    

f0105956 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105956:	55                   	push   %ebp
f0105957:	89 e5                	mov    %esp,%ebp
f0105959:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010595c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010595f:	50                   	push   %eax
f0105960:	ff 75 10             	pushl  0x10(%ebp)
f0105963:	ff 75 0c             	pushl  0xc(%ebp)
f0105966:	ff 75 08             	pushl  0x8(%ebp)
f0105969:	e8 9a ff ff ff       	call   f0105908 <vsnprintf>
	va_end(ap);

	return rc;
}
f010596e:	c9                   	leave  
f010596f:	c3                   	ret    

f0105970 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105970:	55                   	push   %ebp
f0105971:	89 e5                	mov    %esp,%ebp
f0105973:	57                   	push   %edi
f0105974:	56                   	push   %esi
f0105975:	53                   	push   %ebx
f0105976:	83 ec 0c             	sub    $0xc,%esp
f0105979:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f010597c:	85 c0                	test   %eax,%eax
f010597e:	74 11                	je     f0105991 <readline+0x21>
		cprintf("%s", prompt);
f0105980:	83 ec 08             	sub    $0x8,%esp
f0105983:	50                   	push   %eax
f0105984:	68 e6 77 10 f0       	push   $0xf01077e6
f0105989:	e8 92 e1 ff ff       	call   f0103b20 <cprintf>
f010598e:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105991:	83 ec 0c             	sub    $0xc,%esp
f0105994:	6a 00                	push   $0x0
f0105996:	e8 1f ae ff ff       	call   f01007ba <iscons>
f010599b:	89 c7                	mov    %eax,%edi
f010599d:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f01059a0:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01059a5:	e8 ff ad ff ff       	call   f01007a9 <getchar>
f01059aa:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01059ac:	85 c0                	test   %eax,%eax
f01059ae:	79 29                	jns    f01059d9 <readline+0x69>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f01059b0:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f01059b5:	83 fb f8             	cmp    $0xfffffff8,%ebx
f01059b8:	0f 84 9b 00 00 00    	je     f0105a59 <readline+0xe9>
				cprintf("read error: %e\n", c);
f01059be:	83 ec 08             	sub    $0x8,%esp
f01059c1:	53                   	push   %ebx
f01059c2:	68 7f 84 10 f0       	push   $0xf010847f
f01059c7:	e8 54 e1 ff ff       	call   f0103b20 <cprintf>
f01059cc:	83 c4 10             	add    $0x10,%esp
			return NULL;
f01059cf:	b8 00 00 00 00       	mov    $0x0,%eax
f01059d4:	e9 80 00 00 00       	jmp    f0105a59 <readline+0xe9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01059d9:	83 f8 08             	cmp    $0x8,%eax
f01059dc:	0f 94 c2             	sete   %dl
f01059df:	83 f8 7f             	cmp    $0x7f,%eax
f01059e2:	0f 94 c0             	sete   %al
f01059e5:	08 c2                	or     %al,%dl
f01059e7:	74 1a                	je     f0105a03 <readline+0x93>
f01059e9:	85 f6                	test   %esi,%esi
f01059eb:	7e 16                	jle    f0105a03 <readline+0x93>
			if (echoing)
f01059ed:	85 ff                	test   %edi,%edi
f01059ef:	74 0d                	je     f01059fe <readline+0x8e>
				cputchar('\b');
f01059f1:	83 ec 0c             	sub    $0xc,%esp
f01059f4:	6a 08                	push   $0x8
f01059f6:	e8 9e ad ff ff       	call   f0100799 <cputchar>
f01059fb:	83 c4 10             	add    $0x10,%esp
			i--;
f01059fe:	83 ee 01             	sub    $0x1,%esi
f0105a01:	eb a2                	jmp    f01059a5 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105a03:	83 fb 1f             	cmp    $0x1f,%ebx
f0105a06:	7e 26                	jle    f0105a2e <readline+0xbe>
f0105a08:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105a0e:	7f 1e                	jg     f0105a2e <readline+0xbe>
			if (echoing)
f0105a10:	85 ff                	test   %edi,%edi
f0105a12:	74 0c                	je     f0105a20 <readline+0xb0>
				cputchar(c);
f0105a14:	83 ec 0c             	sub    $0xc,%esp
f0105a17:	53                   	push   %ebx
f0105a18:	e8 7c ad ff ff       	call   f0100799 <cputchar>
f0105a1d:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105a20:	88 9e 80 6a 21 f0    	mov    %bl,-0xfde9580(%esi)
f0105a26:	8d 76 01             	lea    0x1(%esi),%esi
f0105a29:	e9 77 ff ff ff       	jmp    f01059a5 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105a2e:	83 fb 0a             	cmp    $0xa,%ebx
f0105a31:	74 09                	je     f0105a3c <readline+0xcc>
f0105a33:	83 fb 0d             	cmp    $0xd,%ebx
f0105a36:	0f 85 69 ff ff ff    	jne    f01059a5 <readline+0x35>
			if (echoing)
f0105a3c:	85 ff                	test   %edi,%edi
f0105a3e:	74 0d                	je     f0105a4d <readline+0xdd>
				cputchar('\n');
f0105a40:	83 ec 0c             	sub    $0xc,%esp
f0105a43:	6a 0a                	push   $0xa
f0105a45:	e8 4f ad ff ff       	call   f0100799 <cputchar>
f0105a4a:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0105a4d:	c6 86 80 6a 21 f0 00 	movb   $0x0,-0xfde9580(%esi)
			return buf;
f0105a54:	b8 80 6a 21 f0       	mov    $0xf0216a80,%eax
		}
	}
}
f0105a59:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105a5c:	5b                   	pop    %ebx
f0105a5d:	5e                   	pop    %esi
f0105a5e:	5f                   	pop    %edi
f0105a5f:	5d                   	pop    %ebp
f0105a60:	c3                   	ret    

f0105a61 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105a61:	55                   	push   %ebp
f0105a62:	89 e5                	mov    %esp,%ebp
f0105a64:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105a67:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a6c:	eb 03                	jmp    f0105a71 <strlen+0x10>
		n++;
f0105a6e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105a71:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105a75:	75 f7                	jne    f0105a6e <strlen+0xd>
		n++;
	return n;
}
f0105a77:	5d                   	pop    %ebp
f0105a78:	c3                   	ret    

f0105a79 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105a79:	55                   	push   %ebp
f0105a7a:	89 e5                	mov    %esp,%ebp
f0105a7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105a7f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105a82:	ba 00 00 00 00       	mov    $0x0,%edx
f0105a87:	eb 03                	jmp    f0105a8c <strnlen+0x13>
		n++;
f0105a89:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105a8c:	39 c2                	cmp    %eax,%edx
f0105a8e:	74 08                	je     f0105a98 <strnlen+0x1f>
f0105a90:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0105a94:	75 f3                	jne    f0105a89 <strnlen+0x10>
f0105a96:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0105a98:	5d                   	pop    %ebp
f0105a99:	c3                   	ret    

f0105a9a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105a9a:	55                   	push   %ebp
f0105a9b:	89 e5                	mov    %esp,%ebp
f0105a9d:	53                   	push   %ebx
f0105a9e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105aa1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105aa4:	89 c2                	mov    %eax,%edx
f0105aa6:	83 c2 01             	add    $0x1,%edx
f0105aa9:	83 c1 01             	add    $0x1,%ecx
f0105aac:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105ab0:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105ab3:	84 db                	test   %bl,%bl
f0105ab5:	75 ef                	jne    f0105aa6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105ab7:	5b                   	pop    %ebx
f0105ab8:	5d                   	pop    %ebp
f0105ab9:	c3                   	ret    

f0105aba <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105aba:	55                   	push   %ebp
f0105abb:	89 e5                	mov    %esp,%ebp
f0105abd:	53                   	push   %ebx
f0105abe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105ac1:	53                   	push   %ebx
f0105ac2:	e8 9a ff ff ff       	call   f0105a61 <strlen>
f0105ac7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105aca:	ff 75 0c             	pushl  0xc(%ebp)
f0105acd:	01 d8                	add    %ebx,%eax
f0105acf:	50                   	push   %eax
f0105ad0:	e8 c5 ff ff ff       	call   f0105a9a <strcpy>
	return dst;
}
f0105ad5:	89 d8                	mov    %ebx,%eax
f0105ad7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105ada:	c9                   	leave  
f0105adb:	c3                   	ret    

f0105adc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105adc:	55                   	push   %ebp
f0105add:	89 e5                	mov    %esp,%ebp
f0105adf:	56                   	push   %esi
f0105ae0:	53                   	push   %ebx
f0105ae1:	8b 75 08             	mov    0x8(%ebp),%esi
f0105ae4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105ae7:	89 f3                	mov    %esi,%ebx
f0105ae9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105aec:	89 f2                	mov    %esi,%edx
f0105aee:	eb 0f                	jmp    f0105aff <strncpy+0x23>
		*dst++ = *src;
f0105af0:	83 c2 01             	add    $0x1,%edx
f0105af3:	0f b6 01             	movzbl (%ecx),%eax
f0105af6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105af9:	80 39 01             	cmpb   $0x1,(%ecx)
f0105afc:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105aff:	39 da                	cmp    %ebx,%edx
f0105b01:	75 ed                	jne    f0105af0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105b03:	89 f0                	mov    %esi,%eax
f0105b05:	5b                   	pop    %ebx
f0105b06:	5e                   	pop    %esi
f0105b07:	5d                   	pop    %ebp
f0105b08:	c3                   	ret    

f0105b09 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105b09:	55                   	push   %ebp
f0105b0a:	89 e5                	mov    %esp,%ebp
f0105b0c:	56                   	push   %esi
f0105b0d:	53                   	push   %ebx
f0105b0e:	8b 75 08             	mov    0x8(%ebp),%esi
f0105b11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105b14:	8b 55 10             	mov    0x10(%ebp),%edx
f0105b17:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105b19:	85 d2                	test   %edx,%edx
f0105b1b:	74 21                	je     f0105b3e <strlcpy+0x35>
f0105b1d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105b21:	89 f2                	mov    %esi,%edx
f0105b23:	eb 09                	jmp    f0105b2e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105b25:	83 c2 01             	add    $0x1,%edx
f0105b28:	83 c1 01             	add    $0x1,%ecx
f0105b2b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105b2e:	39 c2                	cmp    %eax,%edx
f0105b30:	74 09                	je     f0105b3b <strlcpy+0x32>
f0105b32:	0f b6 19             	movzbl (%ecx),%ebx
f0105b35:	84 db                	test   %bl,%bl
f0105b37:	75 ec                	jne    f0105b25 <strlcpy+0x1c>
f0105b39:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105b3b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105b3e:	29 f0                	sub    %esi,%eax
}
f0105b40:	5b                   	pop    %ebx
f0105b41:	5e                   	pop    %esi
f0105b42:	5d                   	pop    %ebp
f0105b43:	c3                   	ret    

f0105b44 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105b44:	55                   	push   %ebp
f0105b45:	89 e5                	mov    %esp,%ebp
f0105b47:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105b4a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105b4d:	eb 06                	jmp    f0105b55 <strcmp+0x11>
		p++, q++;
f0105b4f:	83 c1 01             	add    $0x1,%ecx
f0105b52:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105b55:	0f b6 01             	movzbl (%ecx),%eax
f0105b58:	84 c0                	test   %al,%al
f0105b5a:	74 04                	je     f0105b60 <strcmp+0x1c>
f0105b5c:	3a 02                	cmp    (%edx),%al
f0105b5e:	74 ef                	je     f0105b4f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105b60:	0f b6 c0             	movzbl %al,%eax
f0105b63:	0f b6 12             	movzbl (%edx),%edx
f0105b66:	29 d0                	sub    %edx,%eax
}
f0105b68:	5d                   	pop    %ebp
f0105b69:	c3                   	ret    

f0105b6a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105b6a:	55                   	push   %ebp
f0105b6b:	89 e5                	mov    %esp,%ebp
f0105b6d:	53                   	push   %ebx
f0105b6e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b71:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105b74:	89 c3                	mov    %eax,%ebx
f0105b76:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105b79:	eb 06                	jmp    f0105b81 <strncmp+0x17>
		n--, p++, q++;
f0105b7b:	83 c0 01             	add    $0x1,%eax
f0105b7e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105b81:	39 d8                	cmp    %ebx,%eax
f0105b83:	74 15                	je     f0105b9a <strncmp+0x30>
f0105b85:	0f b6 08             	movzbl (%eax),%ecx
f0105b88:	84 c9                	test   %cl,%cl
f0105b8a:	74 04                	je     f0105b90 <strncmp+0x26>
f0105b8c:	3a 0a                	cmp    (%edx),%cl
f0105b8e:	74 eb                	je     f0105b7b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105b90:	0f b6 00             	movzbl (%eax),%eax
f0105b93:	0f b6 12             	movzbl (%edx),%edx
f0105b96:	29 d0                	sub    %edx,%eax
f0105b98:	eb 05                	jmp    f0105b9f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105b9a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105b9f:	5b                   	pop    %ebx
f0105ba0:	5d                   	pop    %ebp
f0105ba1:	c3                   	ret    

f0105ba2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105ba2:	55                   	push   %ebp
f0105ba3:	89 e5                	mov    %esp,%ebp
f0105ba5:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ba8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105bac:	eb 07                	jmp    f0105bb5 <strchr+0x13>
		if (*s == c)
f0105bae:	38 ca                	cmp    %cl,%dl
f0105bb0:	74 0f                	je     f0105bc1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105bb2:	83 c0 01             	add    $0x1,%eax
f0105bb5:	0f b6 10             	movzbl (%eax),%edx
f0105bb8:	84 d2                	test   %dl,%dl
f0105bba:	75 f2                	jne    f0105bae <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0105bbc:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105bc1:	5d                   	pop    %ebp
f0105bc2:	c3                   	ret    

f0105bc3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105bc3:	55                   	push   %ebp
f0105bc4:	89 e5                	mov    %esp,%ebp
f0105bc6:	8b 45 08             	mov    0x8(%ebp),%eax
f0105bc9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105bcd:	eb 03                	jmp    f0105bd2 <strfind+0xf>
f0105bcf:	83 c0 01             	add    $0x1,%eax
f0105bd2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105bd5:	38 ca                	cmp    %cl,%dl
f0105bd7:	74 04                	je     f0105bdd <strfind+0x1a>
f0105bd9:	84 d2                	test   %dl,%dl
f0105bdb:	75 f2                	jne    f0105bcf <strfind+0xc>
			break;
	return (char *) s;
}
f0105bdd:	5d                   	pop    %ebp
f0105bde:	c3                   	ret    

f0105bdf <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105bdf:	55                   	push   %ebp
f0105be0:	89 e5                	mov    %esp,%ebp
f0105be2:	57                   	push   %edi
f0105be3:	56                   	push   %esi
f0105be4:	53                   	push   %ebx
f0105be5:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105be8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105beb:	85 c9                	test   %ecx,%ecx
f0105bed:	74 36                	je     f0105c25 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105bef:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105bf5:	75 28                	jne    f0105c1f <memset+0x40>
f0105bf7:	f6 c1 03             	test   $0x3,%cl
f0105bfa:	75 23                	jne    f0105c1f <memset+0x40>
		c &= 0xFF;
f0105bfc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105c00:	89 d3                	mov    %edx,%ebx
f0105c02:	c1 e3 08             	shl    $0x8,%ebx
f0105c05:	89 d6                	mov    %edx,%esi
f0105c07:	c1 e6 18             	shl    $0x18,%esi
f0105c0a:	89 d0                	mov    %edx,%eax
f0105c0c:	c1 e0 10             	shl    $0x10,%eax
f0105c0f:	09 f0                	or     %esi,%eax
f0105c11:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0105c13:	89 d8                	mov    %ebx,%eax
f0105c15:	09 d0                	or     %edx,%eax
f0105c17:	c1 e9 02             	shr    $0x2,%ecx
f0105c1a:	fc                   	cld    
f0105c1b:	f3 ab                	rep stos %eax,%es:(%edi)
f0105c1d:	eb 06                	jmp    f0105c25 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105c1f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105c22:	fc                   	cld    
f0105c23:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105c25:	89 f8                	mov    %edi,%eax
f0105c27:	5b                   	pop    %ebx
f0105c28:	5e                   	pop    %esi
f0105c29:	5f                   	pop    %edi
f0105c2a:	5d                   	pop    %ebp
f0105c2b:	c3                   	ret    

f0105c2c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105c2c:	55                   	push   %ebp
f0105c2d:	89 e5                	mov    %esp,%ebp
f0105c2f:	57                   	push   %edi
f0105c30:	56                   	push   %esi
f0105c31:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c34:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105c37:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105c3a:	39 c6                	cmp    %eax,%esi
f0105c3c:	73 35                	jae    f0105c73 <memmove+0x47>
f0105c3e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105c41:	39 d0                	cmp    %edx,%eax
f0105c43:	73 2e                	jae    f0105c73 <memmove+0x47>
		s += n;
		d += n;
f0105c45:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105c48:	89 d6                	mov    %edx,%esi
f0105c4a:	09 fe                	or     %edi,%esi
f0105c4c:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105c52:	75 13                	jne    f0105c67 <memmove+0x3b>
f0105c54:	f6 c1 03             	test   $0x3,%cl
f0105c57:	75 0e                	jne    f0105c67 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0105c59:	83 ef 04             	sub    $0x4,%edi
f0105c5c:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105c5f:	c1 e9 02             	shr    $0x2,%ecx
f0105c62:	fd                   	std    
f0105c63:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105c65:	eb 09                	jmp    f0105c70 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105c67:	83 ef 01             	sub    $0x1,%edi
f0105c6a:	8d 72 ff             	lea    -0x1(%edx),%esi
f0105c6d:	fd                   	std    
f0105c6e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105c70:	fc                   	cld    
f0105c71:	eb 1d                	jmp    f0105c90 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105c73:	89 f2                	mov    %esi,%edx
f0105c75:	09 c2                	or     %eax,%edx
f0105c77:	f6 c2 03             	test   $0x3,%dl
f0105c7a:	75 0f                	jne    f0105c8b <memmove+0x5f>
f0105c7c:	f6 c1 03             	test   $0x3,%cl
f0105c7f:	75 0a                	jne    f0105c8b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0105c81:	c1 e9 02             	shr    $0x2,%ecx
f0105c84:	89 c7                	mov    %eax,%edi
f0105c86:	fc                   	cld    
f0105c87:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105c89:	eb 05                	jmp    f0105c90 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105c8b:	89 c7                	mov    %eax,%edi
f0105c8d:	fc                   	cld    
f0105c8e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105c90:	5e                   	pop    %esi
f0105c91:	5f                   	pop    %edi
f0105c92:	5d                   	pop    %ebp
f0105c93:	c3                   	ret    

f0105c94 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105c94:	55                   	push   %ebp
f0105c95:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105c97:	ff 75 10             	pushl  0x10(%ebp)
f0105c9a:	ff 75 0c             	pushl  0xc(%ebp)
f0105c9d:	ff 75 08             	pushl  0x8(%ebp)
f0105ca0:	e8 87 ff ff ff       	call   f0105c2c <memmove>
}
f0105ca5:	c9                   	leave  
f0105ca6:	c3                   	ret    

f0105ca7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105ca7:	55                   	push   %ebp
f0105ca8:	89 e5                	mov    %esp,%ebp
f0105caa:	56                   	push   %esi
f0105cab:	53                   	push   %ebx
f0105cac:	8b 45 08             	mov    0x8(%ebp),%eax
f0105caf:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105cb2:	89 c6                	mov    %eax,%esi
f0105cb4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105cb7:	eb 1a                	jmp    f0105cd3 <memcmp+0x2c>
		if (*s1 != *s2)
f0105cb9:	0f b6 08             	movzbl (%eax),%ecx
f0105cbc:	0f b6 1a             	movzbl (%edx),%ebx
f0105cbf:	38 d9                	cmp    %bl,%cl
f0105cc1:	74 0a                	je     f0105ccd <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0105cc3:	0f b6 c1             	movzbl %cl,%eax
f0105cc6:	0f b6 db             	movzbl %bl,%ebx
f0105cc9:	29 d8                	sub    %ebx,%eax
f0105ccb:	eb 0f                	jmp    f0105cdc <memcmp+0x35>
		s1++, s2++;
f0105ccd:	83 c0 01             	add    $0x1,%eax
f0105cd0:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105cd3:	39 f0                	cmp    %esi,%eax
f0105cd5:	75 e2                	jne    f0105cb9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105cd7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105cdc:	5b                   	pop    %ebx
f0105cdd:	5e                   	pop    %esi
f0105cde:	5d                   	pop    %ebp
f0105cdf:	c3                   	ret    

f0105ce0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105ce0:	55                   	push   %ebp
f0105ce1:	89 e5                	mov    %esp,%ebp
f0105ce3:	53                   	push   %ebx
f0105ce4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0105ce7:	89 c1                	mov    %eax,%ecx
f0105ce9:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0105cec:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105cf0:	eb 0a                	jmp    f0105cfc <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105cf2:	0f b6 10             	movzbl (%eax),%edx
f0105cf5:	39 da                	cmp    %ebx,%edx
f0105cf7:	74 07                	je     f0105d00 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105cf9:	83 c0 01             	add    $0x1,%eax
f0105cfc:	39 c8                	cmp    %ecx,%eax
f0105cfe:	72 f2                	jb     f0105cf2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105d00:	5b                   	pop    %ebx
f0105d01:	5d                   	pop    %ebp
f0105d02:	c3                   	ret    

f0105d03 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105d03:	55                   	push   %ebp
f0105d04:	89 e5                	mov    %esp,%ebp
f0105d06:	57                   	push   %edi
f0105d07:	56                   	push   %esi
f0105d08:	53                   	push   %ebx
f0105d09:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105d0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105d0f:	eb 03                	jmp    f0105d14 <strtol+0x11>
		s++;
f0105d11:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105d14:	0f b6 01             	movzbl (%ecx),%eax
f0105d17:	3c 20                	cmp    $0x20,%al
f0105d19:	74 f6                	je     f0105d11 <strtol+0xe>
f0105d1b:	3c 09                	cmp    $0x9,%al
f0105d1d:	74 f2                	je     f0105d11 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105d1f:	3c 2b                	cmp    $0x2b,%al
f0105d21:	75 0a                	jne    f0105d2d <strtol+0x2a>
		s++;
f0105d23:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105d26:	bf 00 00 00 00       	mov    $0x0,%edi
f0105d2b:	eb 11                	jmp    f0105d3e <strtol+0x3b>
f0105d2d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105d32:	3c 2d                	cmp    $0x2d,%al
f0105d34:	75 08                	jne    f0105d3e <strtol+0x3b>
		s++, neg = 1;
f0105d36:	83 c1 01             	add    $0x1,%ecx
f0105d39:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105d3e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105d44:	75 15                	jne    f0105d5b <strtol+0x58>
f0105d46:	80 39 30             	cmpb   $0x30,(%ecx)
f0105d49:	75 10                	jne    f0105d5b <strtol+0x58>
f0105d4b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105d4f:	75 7c                	jne    f0105dcd <strtol+0xca>
		s += 2, base = 16;
f0105d51:	83 c1 02             	add    $0x2,%ecx
f0105d54:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105d59:	eb 16                	jmp    f0105d71 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0105d5b:	85 db                	test   %ebx,%ebx
f0105d5d:	75 12                	jne    f0105d71 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105d5f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105d64:	80 39 30             	cmpb   $0x30,(%ecx)
f0105d67:	75 08                	jne    f0105d71 <strtol+0x6e>
		s++, base = 8;
f0105d69:	83 c1 01             	add    $0x1,%ecx
f0105d6c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0105d71:	b8 00 00 00 00       	mov    $0x0,%eax
f0105d76:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105d79:	0f b6 11             	movzbl (%ecx),%edx
f0105d7c:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105d7f:	89 f3                	mov    %esi,%ebx
f0105d81:	80 fb 09             	cmp    $0x9,%bl
f0105d84:	77 08                	ja     f0105d8e <strtol+0x8b>
			dig = *s - '0';
f0105d86:	0f be d2             	movsbl %dl,%edx
f0105d89:	83 ea 30             	sub    $0x30,%edx
f0105d8c:	eb 22                	jmp    f0105db0 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0105d8e:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105d91:	89 f3                	mov    %esi,%ebx
f0105d93:	80 fb 19             	cmp    $0x19,%bl
f0105d96:	77 08                	ja     f0105da0 <strtol+0x9d>
			dig = *s - 'a' + 10;
f0105d98:	0f be d2             	movsbl %dl,%edx
f0105d9b:	83 ea 57             	sub    $0x57,%edx
f0105d9e:	eb 10                	jmp    f0105db0 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0105da0:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105da3:	89 f3                	mov    %esi,%ebx
f0105da5:	80 fb 19             	cmp    $0x19,%bl
f0105da8:	77 16                	ja     f0105dc0 <strtol+0xbd>
			dig = *s - 'A' + 10;
f0105daa:	0f be d2             	movsbl %dl,%edx
f0105dad:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0105db0:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105db3:	7d 0b                	jge    f0105dc0 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0105db5:	83 c1 01             	add    $0x1,%ecx
f0105db8:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105dbc:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0105dbe:	eb b9                	jmp    f0105d79 <strtol+0x76>

	if (endptr)
f0105dc0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105dc4:	74 0d                	je     f0105dd3 <strtol+0xd0>
		*endptr = (char *) s;
f0105dc6:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105dc9:	89 0e                	mov    %ecx,(%esi)
f0105dcb:	eb 06                	jmp    f0105dd3 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105dcd:	85 db                	test   %ebx,%ebx
f0105dcf:	74 98                	je     f0105d69 <strtol+0x66>
f0105dd1:	eb 9e                	jmp    f0105d71 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0105dd3:	89 c2                	mov    %eax,%edx
f0105dd5:	f7 da                	neg    %edx
f0105dd7:	85 ff                	test   %edi,%edi
f0105dd9:	0f 45 c2             	cmovne %edx,%eax
}
f0105ddc:	5b                   	pop    %ebx
f0105ddd:	5e                   	pop    %esi
f0105dde:	5f                   	pop    %edi
f0105ddf:	5d                   	pop    %ebp
f0105de0:	c3                   	ret    
f0105de1:	66 90                	xchg   %ax,%ax
f0105de3:	90                   	nop

f0105de4 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105de4:	fa                   	cli    

	xorw    %ax, %ax
f0105de5:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105de7:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105de9:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105deb:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105ded:	0f 01 16             	lgdtl  (%esi)
f0105df0:	74 70                	je     f0105e62 <mpsearch1+0x3>
	movl    %cr0, %eax
f0105df2:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105df5:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105df9:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105dfc:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105e02:	08 00                	or     %al,(%eax)

f0105e04 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105e04:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105e08:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105e0a:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105e0c:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105e0e:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105e12:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105e14:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105e16:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl    %eax, %cr3
f0105e1b:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105e1e:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105e21:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105e26:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105e29:	8b 25 84 6e 21 f0    	mov    0xf0216e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105e2f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105e34:	b8 c7 01 10 f0       	mov    $0xf01001c7,%eax
	call    *%eax
f0105e39:	ff d0                	call   *%eax

f0105e3b <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105e3b:	eb fe                	jmp    f0105e3b <spin>
f0105e3d:	8d 76 00             	lea    0x0(%esi),%esi

f0105e40 <gdt>:
	...
f0105e48:	ff                   	(bad)  
f0105e49:	ff 00                	incl   (%eax)
f0105e4b:	00 00                	add    %al,(%eax)
f0105e4d:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105e54:	00                   	.byte 0x0
f0105e55:	92                   	xchg   %eax,%edx
f0105e56:	cf                   	iret   
	...

f0105e58 <gdtdesc>:
f0105e58:	17                   	pop    %ss
f0105e59:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105e5e <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105e5e:	90                   	nop

f0105e5f <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105e5f:	55                   	push   %ebp
f0105e60:	89 e5                	mov    %esp,%ebp
f0105e62:	57                   	push   %edi
f0105e63:	56                   	push   %esi
f0105e64:	53                   	push   %ebx
f0105e65:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105e68:	8b 0d 88 6e 21 f0    	mov    0xf0216e88,%ecx
f0105e6e:	89 c3                	mov    %eax,%ebx
f0105e70:	c1 eb 0c             	shr    $0xc,%ebx
f0105e73:	39 cb                	cmp    %ecx,%ebx
f0105e75:	72 12                	jb     f0105e89 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105e77:	50                   	push   %eax
f0105e78:	68 c4 68 10 f0       	push   $0xf01068c4
f0105e7d:	6a 57                	push   $0x57
f0105e7f:	68 1d 86 10 f0       	push   $0xf010861d
f0105e84:	e8 b7 a1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105e89:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105e8f:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105e91:	89 c2                	mov    %eax,%edx
f0105e93:	c1 ea 0c             	shr    $0xc,%edx
f0105e96:	39 ca                	cmp    %ecx,%edx
f0105e98:	72 12                	jb     f0105eac <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105e9a:	50                   	push   %eax
f0105e9b:	68 c4 68 10 f0       	push   $0xf01068c4
f0105ea0:	6a 57                	push   $0x57
f0105ea2:	68 1d 86 10 f0       	push   $0xf010861d
f0105ea7:	e8 94 a1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105eac:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0105eb2:	eb 2f                	jmp    f0105ee3 <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105eb4:	83 ec 04             	sub    $0x4,%esp
f0105eb7:	6a 04                	push   $0x4
f0105eb9:	68 2d 86 10 f0       	push   $0xf010862d
f0105ebe:	53                   	push   %ebx
f0105ebf:	e8 e3 fd ff ff       	call   f0105ca7 <memcmp>
f0105ec4:	83 c4 10             	add    $0x10,%esp
f0105ec7:	85 c0                	test   %eax,%eax
f0105ec9:	75 15                	jne    f0105ee0 <mpsearch1+0x81>
f0105ecb:	89 da                	mov    %ebx,%edx
f0105ecd:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0105ed0:	0f b6 0a             	movzbl (%edx),%ecx
f0105ed3:	01 c8                	add    %ecx,%eax
f0105ed5:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105ed8:	39 d7                	cmp    %edx,%edi
f0105eda:	75 f4                	jne    f0105ed0 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105edc:	84 c0                	test   %al,%al
f0105ede:	74 0e                	je     f0105eee <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105ee0:	83 c3 10             	add    $0x10,%ebx
f0105ee3:	39 f3                	cmp    %esi,%ebx
f0105ee5:	72 cd                	jb     f0105eb4 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105ee7:	b8 00 00 00 00       	mov    $0x0,%eax
f0105eec:	eb 02                	jmp    f0105ef0 <mpsearch1+0x91>
f0105eee:	89 d8                	mov    %ebx,%eax
}
f0105ef0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105ef3:	5b                   	pop    %ebx
f0105ef4:	5e                   	pop    %esi
f0105ef5:	5f                   	pop    %edi
f0105ef6:	5d                   	pop    %ebp
f0105ef7:	c3                   	ret    

f0105ef8 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105ef8:	55                   	push   %ebp
f0105ef9:	89 e5                	mov    %esp,%ebp
f0105efb:	57                   	push   %edi
f0105efc:	56                   	push   %esi
f0105efd:	53                   	push   %ebx
f0105efe:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105f01:	c7 05 c0 73 21 f0 20 	movl   $0xf0217020,0xf02173c0
f0105f08:	70 21 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105f0b:	83 3d 88 6e 21 f0 00 	cmpl   $0x0,0xf0216e88
f0105f12:	75 16                	jne    f0105f2a <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105f14:	68 00 04 00 00       	push   $0x400
f0105f19:	68 c4 68 10 f0       	push   $0xf01068c4
f0105f1e:	6a 6f                	push   $0x6f
f0105f20:	68 1d 86 10 f0       	push   $0xf010861d
f0105f25:	e8 16 a1 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105f2a:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105f31:	85 c0                	test   %eax,%eax
f0105f33:	74 16                	je     f0105f4b <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0105f35:	c1 e0 04             	shl    $0x4,%eax
f0105f38:	ba 00 04 00 00       	mov    $0x400,%edx
f0105f3d:	e8 1d ff ff ff       	call   f0105e5f <mpsearch1>
f0105f42:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105f45:	85 c0                	test   %eax,%eax
f0105f47:	75 3c                	jne    f0105f85 <mp_init+0x8d>
f0105f49:	eb 20                	jmp    f0105f6b <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105f4b:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105f52:	c1 e0 0a             	shl    $0xa,%eax
f0105f55:	2d 00 04 00 00       	sub    $0x400,%eax
f0105f5a:	ba 00 04 00 00       	mov    $0x400,%edx
f0105f5f:	e8 fb fe ff ff       	call   f0105e5f <mpsearch1>
f0105f64:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105f67:	85 c0                	test   %eax,%eax
f0105f69:	75 1a                	jne    f0105f85 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105f6b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105f70:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105f75:	e8 e5 fe ff ff       	call   f0105e5f <mpsearch1>
f0105f7a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105f7d:	85 c0                	test   %eax,%eax
f0105f7f:	0f 84 5d 02 00 00    	je     f01061e2 <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105f85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105f88:	8b 70 04             	mov    0x4(%eax),%esi
f0105f8b:	85 f6                	test   %esi,%esi
f0105f8d:	74 06                	je     f0105f95 <mp_init+0x9d>
f0105f8f:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105f93:	74 15                	je     f0105faa <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105f95:	83 ec 0c             	sub    $0xc,%esp
f0105f98:	68 90 84 10 f0       	push   $0xf0108490
f0105f9d:	e8 7e db ff ff       	call   f0103b20 <cprintf>
f0105fa2:	83 c4 10             	add    $0x10,%esp
f0105fa5:	e9 38 02 00 00       	jmp    f01061e2 <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105faa:	89 f0                	mov    %esi,%eax
f0105fac:	c1 e8 0c             	shr    $0xc,%eax
f0105faf:	3b 05 88 6e 21 f0    	cmp    0xf0216e88,%eax
f0105fb5:	72 15                	jb     f0105fcc <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105fb7:	56                   	push   %esi
f0105fb8:	68 c4 68 10 f0       	push   $0xf01068c4
f0105fbd:	68 90 00 00 00       	push   $0x90
f0105fc2:	68 1d 86 10 f0       	push   $0xf010861d
f0105fc7:	e8 74 a0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105fcc:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105fd2:	83 ec 04             	sub    $0x4,%esp
f0105fd5:	6a 04                	push   $0x4
f0105fd7:	68 32 86 10 f0       	push   $0xf0108632
f0105fdc:	53                   	push   %ebx
f0105fdd:	e8 c5 fc ff ff       	call   f0105ca7 <memcmp>
f0105fe2:	83 c4 10             	add    $0x10,%esp
f0105fe5:	85 c0                	test   %eax,%eax
f0105fe7:	74 15                	je     f0105ffe <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105fe9:	83 ec 0c             	sub    $0xc,%esp
f0105fec:	68 c0 84 10 f0       	push   $0xf01084c0
f0105ff1:	e8 2a db ff ff       	call   f0103b20 <cprintf>
f0105ff6:	83 c4 10             	add    $0x10,%esp
f0105ff9:	e9 e4 01 00 00       	jmp    f01061e2 <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105ffe:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0106002:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0106006:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0106009:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f010600e:	b8 00 00 00 00       	mov    $0x0,%eax
f0106013:	eb 0d                	jmp    f0106022 <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0106015:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f010601c:	f0 
f010601d:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f010601f:	83 c0 01             	add    $0x1,%eax
f0106022:	39 c7                	cmp    %eax,%edi
f0106024:	75 ef                	jne    f0106015 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0106026:	84 d2                	test   %dl,%dl
f0106028:	74 15                	je     f010603f <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f010602a:	83 ec 0c             	sub    $0xc,%esp
f010602d:	68 f4 84 10 f0       	push   $0xf01084f4
f0106032:	e8 e9 da ff ff       	call   f0103b20 <cprintf>
f0106037:	83 c4 10             	add    $0x10,%esp
f010603a:	e9 a3 01 00 00       	jmp    f01061e2 <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f010603f:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0106043:	3c 01                	cmp    $0x1,%al
f0106045:	74 1d                	je     f0106064 <mp_init+0x16c>
f0106047:	3c 04                	cmp    $0x4,%al
f0106049:	74 19                	je     f0106064 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f010604b:	83 ec 08             	sub    $0x8,%esp
f010604e:	0f b6 c0             	movzbl %al,%eax
f0106051:	50                   	push   %eax
f0106052:	68 18 85 10 f0       	push   $0xf0108518
f0106057:	e8 c4 da ff ff       	call   f0103b20 <cprintf>
f010605c:	83 c4 10             	add    $0x10,%esp
f010605f:	e9 7e 01 00 00       	jmp    f01061e2 <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0106064:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0106068:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f010606c:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0106071:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0106076:	01 ce                	add    %ecx,%esi
f0106078:	eb 0d                	jmp    f0106087 <mp_init+0x18f>
f010607a:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0106081:	f0 
f0106082:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106084:	83 c0 01             	add    $0x1,%eax
f0106087:	39 c7                	cmp    %eax,%edi
f0106089:	75 ef                	jne    f010607a <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010608b:	89 d0                	mov    %edx,%eax
f010608d:	02 43 2a             	add    0x2a(%ebx),%al
f0106090:	74 15                	je     f01060a7 <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0106092:	83 ec 0c             	sub    $0xc,%esp
f0106095:	68 38 85 10 f0       	push   $0xf0108538
f010609a:	e8 81 da ff ff       	call   f0103b20 <cprintf>
f010609f:	83 c4 10             	add    $0x10,%esp
f01060a2:	e9 3b 01 00 00       	jmp    f01061e2 <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f01060a7:	85 db                	test   %ebx,%ebx
f01060a9:	0f 84 33 01 00 00    	je     f01061e2 <mp_init+0x2ea>
		return;
	ismp = 1;
f01060af:	c7 05 00 70 21 f0 01 	movl   $0x1,0xf0217000
f01060b6:	00 00 00 
	lapicaddr = conf->lapicaddr;
f01060b9:	8b 43 24             	mov    0x24(%ebx),%eax
f01060bc:	a3 00 80 25 f0       	mov    %eax,0xf0258000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01060c1:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f01060c4:	be 00 00 00 00       	mov    $0x0,%esi
f01060c9:	e9 85 00 00 00       	jmp    f0106153 <mp_init+0x25b>
		switch (*p) {
f01060ce:	0f b6 07             	movzbl (%edi),%eax
f01060d1:	84 c0                	test   %al,%al
f01060d3:	74 06                	je     f01060db <mp_init+0x1e3>
f01060d5:	3c 04                	cmp    $0x4,%al
f01060d7:	77 55                	ja     f010612e <mp_init+0x236>
f01060d9:	eb 4e                	jmp    f0106129 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f01060db:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f01060df:	74 11                	je     f01060f2 <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f01060e1:	6b 05 c4 73 21 f0 74 	imul   $0x74,0xf02173c4,%eax
f01060e8:	05 20 70 21 f0       	add    $0xf0217020,%eax
f01060ed:	a3 c0 73 21 f0       	mov    %eax,0xf02173c0
			if (ncpu < NCPU) {
f01060f2:	a1 c4 73 21 f0       	mov    0xf02173c4,%eax
f01060f7:	83 f8 07             	cmp    $0x7,%eax
f01060fa:	7f 13                	jg     f010610f <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f01060fc:	6b d0 74             	imul   $0x74,%eax,%edx
f01060ff:	88 82 20 70 21 f0    	mov    %al,-0xfde8fe0(%edx)
				ncpu++;
f0106105:	83 c0 01             	add    $0x1,%eax
f0106108:	a3 c4 73 21 f0       	mov    %eax,0xf02173c4
f010610d:	eb 15                	jmp    f0106124 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f010610f:	83 ec 08             	sub    $0x8,%esp
f0106112:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0106116:	50                   	push   %eax
f0106117:	68 68 85 10 f0       	push   $0xf0108568
f010611c:	e8 ff d9 ff ff       	call   f0103b20 <cprintf>
f0106121:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0106124:	83 c7 14             	add    $0x14,%edi
			continue;
f0106127:	eb 27                	jmp    f0106150 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106129:	83 c7 08             	add    $0x8,%edi
			continue;
f010612c:	eb 22                	jmp    f0106150 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f010612e:	83 ec 08             	sub    $0x8,%esp
f0106131:	0f b6 c0             	movzbl %al,%eax
f0106134:	50                   	push   %eax
f0106135:	68 90 85 10 f0       	push   $0xf0108590
f010613a:	e8 e1 d9 ff ff       	call   f0103b20 <cprintf>
			ismp = 0;
f010613f:	c7 05 00 70 21 f0 00 	movl   $0x0,0xf0217000
f0106146:	00 00 00 
			i = conf->entry;
f0106149:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f010614d:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106150:	83 c6 01             	add    $0x1,%esi
f0106153:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0106157:	39 c6                	cmp    %eax,%esi
f0106159:	0f 82 6f ff ff ff    	jb     f01060ce <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f010615f:	a1 c0 73 21 f0       	mov    0xf02173c0,%eax
f0106164:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f010616b:	83 3d 00 70 21 f0 00 	cmpl   $0x0,0xf0217000
f0106172:	75 26                	jne    f010619a <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0106174:	c7 05 c4 73 21 f0 01 	movl   $0x1,0xf02173c4
f010617b:	00 00 00 
		lapicaddr = 0;
f010617e:	c7 05 00 80 25 f0 00 	movl   $0x0,0xf0258000
f0106185:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106188:	83 ec 0c             	sub    $0xc,%esp
f010618b:	68 b0 85 10 f0       	push   $0xf01085b0
f0106190:	e8 8b d9 ff ff       	call   f0103b20 <cprintf>
		return;
f0106195:	83 c4 10             	add    $0x10,%esp
f0106198:	eb 48                	jmp    f01061e2 <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f010619a:	83 ec 04             	sub    $0x4,%esp
f010619d:	ff 35 c4 73 21 f0    	pushl  0xf02173c4
f01061a3:	0f b6 00             	movzbl (%eax),%eax
f01061a6:	50                   	push   %eax
f01061a7:	68 37 86 10 f0       	push   $0xf0108637
f01061ac:	e8 6f d9 ff ff       	call   f0103b20 <cprintf>

	if (mp->imcrp) {
f01061b1:	83 c4 10             	add    $0x10,%esp
f01061b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01061b7:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01061bb:	74 25                	je     f01061e2 <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01061bd:	83 ec 0c             	sub    $0xc,%esp
f01061c0:	68 dc 85 10 f0       	push   $0xf01085dc
f01061c5:	e8 56 d9 ff ff       	call   f0103b20 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01061ca:	ba 22 00 00 00       	mov    $0x22,%edx
f01061cf:	b8 70 00 00 00       	mov    $0x70,%eax
f01061d4:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01061d5:	ba 23 00 00 00       	mov    $0x23,%edx
f01061da:	ec                   	in     (%dx),%al
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01061db:	83 c8 01             	or     $0x1,%eax
f01061de:	ee                   	out    %al,(%dx)
f01061df:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f01061e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01061e5:	5b                   	pop    %ebx
f01061e6:	5e                   	pop    %esi
f01061e7:	5f                   	pop    %edi
f01061e8:	5d                   	pop    %ebp
f01061e9:	c3                   	ret    

f01061ea <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f01061ea:	55                   	push   %ebp
f01061eb:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f01061ed:	8b 0d 04 80 25 f0    	mov    0xf0258004,%ecx
f01061f3:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f01061f6:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f01061f8:	a1 04 80 25 f0       	mov    0xf0258004,%eax
f01061fd:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106200:	5d                   	pop    %ebp
f0106201:	c3                   	ret    

f0106202 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106202:	55                   	push   %ebp
f0106203:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106205:	a1 04 80 25 f0       	mov    0xf0258004,%eax
f010620a:	85 c0                	test   %eax,%eax
f010620c:	74 08                	je     f0106216 <cpunum+0x14>
		return lapic[ID] >> 24;
f010620e:	8b 40 20             	mov    0x20(%eax),%eax
f0106211:	c1 e8 18             	shr    $0x18,%eax
f0106214:	eb 05                	jmp    f010621b <cpunum+0x19>
	return 0;
f0106216:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010621b:	5d                   	pop    %ebp
f010621c:	c3                   	ret    

f010621d <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f010621d:	a1 00 80 25 f0       	mov    0xf0258000,%eax
f0106222:	85 c0                	test   %eax,%eax
f0106224:	0f 84 21 01 00 00    	je     f010634b <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f010622a:	55                   	push   %ebp
f010622b:	89 e5                	mov    %esp,%ebp
f010622d:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0106230:	68 00 10 00 00       	push   $0x1000
f0106235:	50                   	push   %eax
f0106236:	e8 f6 b1 ff ff       	call   f0101431 <mmio_map_region>
f010623b:	a3 04 80 25 f0       	mov    %eax,0xf0258004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0106240:	ba 27 01 00 00       	mov    $0x127,%edx
f0106245:	b8 3c 00 00 00       	mov    $0x3c,%eax
f010624a:	e8 9b ff ff ff       	call   f01061ea <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f010624f:	ba 0b 00 00 00       	mov    $0xb,%edx
f0106254:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0106259:	e8 8c ff ff ff       	call   f01061ea <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f010625e:	ba 20 00 02 00       	mov    $0x20020,%edx
f0106263:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0106268:	e8 7d ff ff ff       	call   f01061ea <lapicw>
	lapicw(TICR, 10000000); 
f010626d:	ba 80 96 98 00       	mov    $0x989680,%edx
f0106272:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106277:	e8 6e ff ff ff       	call   f01061ea <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f010627c:	e8 81 ff ff ff       	call   f0106202 <cpunum>
f0106281:	6b c0 74             	imul   $0x74,%eax,%eax
f0106284:	05 20 70 21 f0       	add    $0xf0217020,%eax
f0106289:	83 c4 10             	add    $0x10,%esp
f010628c:	39 05 c0 73 21 f0    	cmp    %eax,0xf02173c0
f0106292:	74 0f                	je     f01062a3 <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0106294:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106299:	b8 d4 00 00 00       	mov    $0xd4,%eax
f010629e:	e8 47 ff ff ff       	call   f01061ea <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f01062a3:	ba 00 00 01 00       	mov    $0x10000,%edx
f01062a8:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01062ad:	e8 38 ff ff ff       	call   f01061ea <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01062b2:	a1 04 80 25 f0       	mov    0xf0258004,%eax
f01062b7:	8b 40 30             	mov    0x30(%eax),%eax
f01062ba:	c1 e8 10             	shr    $0x10,%eax
f01062bd:	3c 03                	cmp    $0x3,%al
f01062bf:	76 0f                	jbe    f01062d0 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f01062c1:	ba 00 00 01 00       	mov    $0x10000,%edx
f01062c6:	b8 d0 00 00 00       	mov    $0xd0,%eax
f01062cb:	e8 1a ff ff ff       	call   f01061ea <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01062d0:	ba 33 00 00 00       	mov    $0x33,%edx
f01062d5:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01062da:	e8 0b ff ff ff       	call   f01061ea <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f01062df:	ba 00 00 00 00       	mov    $0x0,%edx
f01062e4:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01062e9:	e8 fc fe ff ff       	call   f01061ea <lapicw>
	lapicw(ESR, 0);
f01062ee:	ba 00 00 00 00       	mov    $0x0,%edx
f01062f3:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01062f8:	e8 ed fe ff ff       	call   f01061ea <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f01062fd:	ba 00 00 00 00       	mov    $0x0,%edx
f0106302:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106307:	e8 de fe ff ff       	call   f01061ea <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f010630c:	ba 00 00 00 00       	mov    $0x0,%edx
f0106311:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106316:	e8 cf fe ff ff       	call   f01061ea <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f010631b:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106320:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106325:	e8 c0 fe ff ff       	call   f01061ea <lapicw>
	while(lapic[ICRLO] & DELIVS)
f010632a:	8b 15 04 80 25 f0    	mov    0xf0258004,%edx
f0106330:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106336:	f6 c4 10             	test   $0x10,%ah
f0106339:	75 f5                	jne    f0106330 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f010633b:	ba 00 00 00 00       	mov    $0x0,%edx
f0106340:	b8 20 00 00 00       	mov    $0x20,%eax
f0106345:	e8 a0 fe ff ff       	call   f01061ea <lapicw>
}
f010634a:	c9                   	leave  
f010634b:	f3 c3                	repz ret 

f010634d <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f010634d:	83 3d 04 80 25 f0 00 	cmpl   $0x0,0xf0258004
f0106354:	74 13                	je     f0106369 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0106356:	55                   	push   %ebp
f0106357:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0106359:	ba 00 00 00 00       	mov    $0x0,%edx
f010635e:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106363:	e8 82 fe ff ff       	call   f01061ea <lapicw>
}
f0106368:	5d                   	pop    %ebp
f0106369:	f3 c3                	repz ret 

f010636b <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f010636b:	55                   	push   %ebp
f010636c:	89 e5                	mov    %esp,%ebp
f010636e:	56                   	push   %esi
f010636f:	53                   	push   %ebx
f0106370:	8b 75 08             	mov    0x8(%ebp),%esi
f0106373:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106376:	ba 70 00 00 00       	mov    $0x70,%edx
f010637b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0106380:	ee                   	out    %al,(%dx)
f0106381:	ba 71 00 00 00       	mov    $0x71,%edx
f0106386:	b8 0a 00 00 00       	mov    $0xa,%eax
f010638b:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010638c:	83 3d 88 6e 21 f0 00 	cmpl   $0x0,0xf0216e88
f0106393:	75 19                	jne    f01063ae <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106395:	68 67 04 00 00       	push   $0x467
f010639a:	68 c4 68 10 f0       	push   $0xf01068c4
f010639f:	68 98 00 00 00       	push   $0x98
f01063a4:	68 54 86 10 f0       	push   $0xf0108654
f01063a9:	e8 92 9c ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01063ae:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01063b5:	00 00 
	wrv[1] = addr >> 4;
f01063b7:	89 d8                	mov    %ebx,%eax
f01063b9:	c1 e8 04             	shr    $0x4,%eax
f01063bc:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01063c2:	c1 e6 18             	shl    $0x18,%esi
f01063c5:	89 f2                	mov    %esi,%edx
f01063c7:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01063cc:	e8 19 fe ff ff       	call   f01061ea <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01063d1:	ba 00 c5 00 00       	mov    $0xc500,%edx
f01063d6:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01063db:	e8 0a fe ff ff       	call   f01061ea <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01063e0:	ba 00 85 00 00       	mov    $0x8500,%edx
f01063e5:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01063ea:	e8 fb fd ff ff       	call   f01061ea <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01063ef:	c1 eb 0c             	shr    $0xc,%ebx
f01063f2:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01063f5:	89 f2                	mov    %esi,%edx
f01063f7:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01063fc:	e8 e9 fd ff ff       	call   f01061ea <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106401:	89 da                	mov    %ebx,%edx
f0106403:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106408:	e8 dd fd ff ff       	call   f01061ea <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010640d:	89 f2                	mov    %esi,%edx
f010640f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106414:	e8 d1 fd ff ff       	call   f01061ea <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106419:	89 da                	mov    %ebx,%edx
f010641b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106420:	e8 c5 fd ff ff       	call   f01061ea <lapicw>
		microdelay(200);
	}
}
f0106425:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106428:	5b                   	pop    %ebx
f0106429:	5e                   	pop    %esi
f010642a:	5d                   	pop    %ebp
f010642b:	c3                   	ret    

f010642c <lapic_ipi>:

void
lapic_ipi(int vector)
{
f010642c:	55                   	push   %ebp
f010642d:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f010642f:	8b 55 08             	mov    0x8(%ebp),%edx
f0106432:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106438:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010643d:	e8 a8 fd ff ff       	call   f01061ea <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106442:	8b 15 04 80 25 f0    	mov    0xf0258004,%edx
f0106448:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010644e:	f6 c4 10             	test   $0x10,%ah
f0106451:	75 f5                	jne    f0106448 <lapic_ipi+0x1c>
		;
}
f0106453:	5d                   	pop    %ebp
f0106454:	c3                   	ret    

f0106455 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106455:	55                   	push   %ebp
f0106456:	89 e5                	mov    %esp,%ebp
f0106458:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f010645b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106461:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106464:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106467:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f010646e:	5d                   	pop    %ebp
f010646f:	c3                   	ret    

f0106470 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106470:	55                   	push   %ebp
f0106471:	89 e5                	mov    %esp,%ebp
f0106473:	56                   	push   %esi
f0106474:	53                   	push   %ebx
f0106475:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0106478:	83 3b 00             	cmpl   $0x0,(%ebx)
f010647b:	74 14                	je     f0106491 <spin_lock+0x21>
f010647d:	8b 73 08             	mov    0x8(%ebx),%esi
f0106480:	e8 7d fd ff ff       	call   f0106202 <cpunum>
f0106485:	6b c0 74             	imul   $0x74,%eax,%eax
f0106488:	05 20 70 21 f0       	add    $0xf0217020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f010648d:	39 c6                	cmp    %eax,%esi
f010648f:	74 07                	je     f0106498 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0106491:	ba 01 00 00 00       	mov    $0x1,%edx
f0106496:	eb 20                	jmp    f01064b8 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106498:	8b 5b 04             	mov    0x4(%ebx),%ebx
f010649b:	e8 62 fd ff ff       	call   f0106202 <cpunum>
f01064a0:	83 ec 0c             	sub    $0xc,%esp
f01064a3:	53                   	push   %ebx
f01064a4:	50                   	push   %eax
f01064a5:	68 64 86 10 f0       	push   $0xf0108664
f01064aa:	6a 41                	push   $0x41
f01064ac:	68 c8 86 10 f0       	push   $0xf01086c8
f01064b1:	e8 8a 9b ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f01064b6:	f3 90                	pause  
f01064b8:	89 d0                	mov    %edx,%eax
f01064ba:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f01064bd:	85 c0                	test   %eax,%eax
f01064bf:	75 f5                	jne    f01064b6 <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f01064c1:	e8 3c fd ff ff       	call   f0106202 <cpunum>
f01064c6:	6b c0 74             	imul   $0x74,%eax,%eax
f01064c9:	05 20 70 21 f0       	add    $0xf0217020,%eax
f01064ce:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f01064d1:	83 c3 0c             	add    $0xc,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01064d4:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01064d6:	b8 00 00 00 00       	mov    $0x0,%eax
f01064db:	eb 0b                	jmp    f01064e8 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f01064dd:	8b 4a 04             	mov    0x4(%edx),%ecx
f01064e0:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01064e3:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01064e5:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01064e8:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01064ee:	76 11                	jbe    f0106501 <spin_lock+0x91>
f01064f0:	83 f8 09             	cmp    $0x9,%eax
f01064f3:	7e e8                	jle    f01064dd <spin_lock+0x6d>
f01064f5:	eb 0a                	jmp    f0106501 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f01064f7:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f01064fe:	83 c0 01             	add    $0x1,%eax
f0106501:	83 f8 09             	cmp    $0x9,%eax
f0106504:	7e f1                	jle    f01064f7 <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0106506:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106509:	5b                   	pop    %ebx
f010650a:	5e                   	pop    %esi
f010650b:	5d                   	pop    %ebp
f010650c:	c3                   	ret    

f010650d <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f010650d:	55                   	push   %ebp
f010650e:	89 e5                	mov    %esp,%ebp
f0106510:	57                   	push   %edi
f0106511:	56                   	push   %esi
f0106512:	53                   	push   %ebx
f0106513:	83 ec 4c             	sub    $0x4c,%esp
f0106516:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0106519:	83 3e 00             	cmpl   $0x0,(%esi)
f010651c:	74 18                	je     f0106536 <spin_unlock+0x29>
f010651e:	8b 5e 08             	mov    0x8(%esi),%ebx
f0106521:	e8 dc fc ff ff       	call   f0106202 <cpunum>
f0106526:	6b c0 74             	imul   $0x74,%eax,%eax
f0106529:	05 20 70 21 f0       	add    $0xf0217020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f010652e:	39 c3                	cmp    %eax,%ebx
f0106530:	0f 84 a5 00 00 00    	je     f01065db <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106536:	83 ec 04             	sub    $0x4,%esp
f0106539:	6a 28                	push   $0x28
f010653b:	8d 46 0c             	lea    0xc(%esi),%eax
f010653e:	50                   	push   %eax
f010653f:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106542:	53                   	push   %ebx
f0106543:	e8 e4 f6 ff ff       	call   f0105c2c <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106548:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f010654b:	0f b6 38             	movzbl (%eax),%edi
f010654e:	8b 76 04             	mov    0x4(%esi),%esi
f0106551:	e8 ac fc ff ff       	call   f0106202 <cpunum>
f0106556:	57                   	push   %edi
f0106557:	56                   	push   %esi
f0106558:	50                   	push   %eax
f0106559:	68 90 86 10 f0       	push   $0xf0108690
f010655e:	e8 bd d5 ff ff       	call   f0103b20 <cprintf>
f0106563:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106566:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0106569:	eb 54                	jmp    f01065bf <spin_unlock+0xb2>
f010656b:	83 ec 08             	sub    $0x8,%esp
f010656e:	57                   	push   %edi
f010656f:	50                   	push   %eax
f0106570:	e8 82 ec ff ff       	call   f01051f7 <debuginfo_eip>
f0106575:	83 c4 10             	add    $0x10,%esp
f0106578:	85 c0                	test   %eax,%eax
f010657a:	78 27                	js     f01065a3 <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f010657c:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f010657e:	83 ec 04             	sub    $0x4,%esp
f0106581:	89 c2                	mov    %eax,%edx
f0106583:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0106586:	52                   	push   %edx
f0106587:	ff 75 b0             	pushl  -0x50(%ebp)
f010658a:	ff 75 b4             	pushl  -0x4c(%ebp)
f010658d:	ff 75 ac             	pushl  -0x54(%ebp)
f0106590:	ff 75 a8             	pushl  -0x58(%ebp)
f0106593:	50                   	push   %eax
f0106594:	68 d8 86 10 f0       	push   $0xf01086d8
f0106599:	e8 82 d5 ff ff       	call   f0103b20 <cprintf>
f010659e:	83 c4 20             	add    $0x20,%esp
f01065a1:	eb 12                	jmp    f01065b5 <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f01065a3:	83 ec 08             	sub    $0x8,%esp
f01065a6:	ff 36                	pushl  (%esi)
f01065a8:	68 ef 86 10 f0       	push   $0xf01086ef
f01065ad:	e8 6e d5 ff ff       	call   f0103b20 <cprintf>
f01065b2:	83 c4 10             	add    $0x10,%esp
f01065b5:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f01065b8:	8d 45 e8             	lea    -0x18(%ebp),%eax
f01065bb:	39 c3                	cmp    %eax,%ebx
f01065bd:	74 08                	je     f01065c7 <spin_unlock+0xba>
f01065bf:	89 de                	mov    %ebx,%esi
f01065c1:	8b 03                	mov    (%ebx),%eax
f01065c3:	85 c0                	test   %eax,%eax
f01065c5:	75 a4                	jne    f010656b <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f01065c7:	83 ec 04             	sub    $0x4,%esp
f01065ca:	68 f7 86 10 f0       	push   $0xf01086f7
f01065cf:	6a 67                	push   $0x67
f01065d1:	68 c8 86 10 f0       	push   $0xf01086c8
f01065d6:	e8 65 9a ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f01065db:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f01065e2:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01065e9:	b8 00 00 00 00       	mov    $0x0,%eax
f01065ee:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f01065f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01065f4:	5b                   	pop    %ebx
f01065f5:	5e                   	pop    %esi
f01065f6:	5f                   	pop    %edi
f01065f7:	5d                   	pop    %ebp
f01065f8:	c3                   	ret    
f01065f9:	66 90                	xchg   %ax,%ax
f01065fb:	66 90                	xchg   %ax,%ax
f01065fd:	66 90                	xchg   %ax,%ax
f01065ff:	90                   	nop

f0106600 <__udivdi3>:
f0106600:	55                   	push   %ebp
f0106601:	57                   	push   %edi
f0106602:	56                   	push   %esi
f0106603:	53                   	push   %ebx
f0106604:	83 ec 1c             	sub    $0x1c,%esp
f0106607:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010660b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010660f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0106613:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106617:	85 f6                	test   %esi,%esi
f0106619:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010661d:	89 ca                	mov    %ecx,%edx
f010661f:	89 f8                	mov    %edi,%eax
f0106621:	75 3d                	jne    f0106660 <__udivdi3+0x60>
f0106623:	39 cf                	cmp    %ecx,%edi
f0106625:	0f 87 c5 00 00 00    	ja     f01066f0 <__udivdi3+0xf0>
f010662b:	85 ff                	test   %edi,%edi
f010662d:	89 fd                	mov    %edi,%ebp
f010662f:	75 0b                	jne    f010663c <__udivdi3+0x3c>
f0106631:	b8 01 00 00 00       	mov    $0x1,%eax
f0106636:	31 d2                	xor    %edx,%edx
f0106638:	f7 f7                	div    %edi
f010663a:	89 c5                	mov    %eax,%ebp
f010663c:	89 c8                	mov    %ecx,%eax
f010663e:	31 d2                	xor    %edx,%edx
f0106640:	f7 f5                	div    %ebp
f0106642:	89 c1                	mov    %eax,%ecx
f0106644:	89 d8                	mov    %ebx,%eax
f0106646:	89 cf                	mov    %ecx,%edi
f0106648:	f7 f5                	div    %ebp
f010664a:	89 c3                	mov    %eax,%ebx
f010664c:	89 d8                	mov    %ebx,%eax
f010664e:	89 fa                	mov    %edi,%edx
f0106650:	83 c4 1c             	add    $0x1c,%esp
f0106653:	5b                   	pop    %ebx
f0106654:	5e                   	pop    %esi
f0106655:	5f                   	pop    %edi
f0106656:	5d                   	pop    %ebp
f0106657:	c3                   	ret    
f0106658:	90                   	nop
f0106659:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106660:	39 ce                	cmp    %ecx,%esi
f0106662:	77 74                	ja     f01066d8 <__udivdi3+0xd8>
f0106664:	0f bd fe             	bsr    %esi,%edi
f0106667:	83 f7 1f             	xor    $0x1f,%edi
f010666a:	0f 84 98 00 00 00    	je     f0106708 <__udivdi3+0x108>
f0106670:	bb 20 00 00 00       	mov    $0x20,%ebx
f0106675:	89 f9                	mov    %edi,%ecx
f0106677:	89 c5                	mov    %eax,%ebp
f0106679:	29 fb                	sub    %edi,%ebx
f010667b:	d3 e6                	shl    %cl,%esi
f010667d:	89 d9                	mov    %ebx,%ecx
f010667f:	d3 ed                	shr    %cl,%ebp
f0106681:	89 f9                	mov    %edi,%ecx
f0106683:	d3 e0                	shl    %cl,%eax
f0106685:	09 ee                	or     %ebp,%esi
f0106687:	89 d9                	mov    %ebx,%ecx
f0106689:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010668d:	89 d5                	mov    %edx,%ebp
f010668f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106693:	d3 ed                	shr    %cl,%ebp
f0106695:	89 f9                	mov    %edi,%ecx
f0106697:	d3 e2                	shl    %cl,%edx
f0106699:	89 d9                	mov    %ebx,%ecx
f010669b:	d3 e8                	shr    %cl,%eax
f010669d:	09 c2                	or     %eax,%edx
f010669f:	89 d0                	mov    %edx,%eax
f01066a1:	89 ea                	mov    %ebp,%edx
f01066a3:	f7 f6                	div    %esi
f01066a5:	89 d5                	mov    %edx,%ebp
f01066a7:	89 c3                	mov    %eax,%ebx
f01066a9:	f7 64 24 0c          	mull   0xc(%esp)
f01066ad:	39 d5                	cmp    %edx,%ebp
f01066af:	72 10                	jb     f01066c1 <__udivdi3+0xc1>
f01066b1:	8b 74 24 08          	mov    0x8(%esp),%esi
f01066b5:	89 f9                	mov    %edi,%ecx
f01066b7:	d3 e6                	shl    %cl,%esi
f01066b9:	39 c6                	cmp    %eax,%esi
f01066bb:	73 07                	jae    f01066c4 <__udivdi3+0xc4>
f01066bd:	39 d5                	cmp    %edx,%ebp
f01066bf:	75 03                	jne    f01066c4 <__udivdi3+0xc4>
f01066c1:	83 eb 01             	sub    $0x1,%ebx
f01066c4:	31 ff                	xor    %edi,%edi
f01066c6:	89 d8                	mov    %ebx,%eax
f01066c8:	89 fa                	mov    %edi,%edx
f01066ca:	83 c4 1c             	add    $0x1c,%esp
f01066cd:	5b                   	pop    %ebx
f01066ce:	5e                   	pop    %esi
f01066cf:	5f                   	pop    %edi
f01066d0:	5d                   	pop    %ebp
f01066d1:	c3                   	ret    
f01066d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01066d8:	31 ff                	xor    %edi,%edi
f01066da:	31 db                	xor    %ebx,%ebx
f01066dc:	89 d8                	mov    %ebx,%eax
f01066de:	89 fa                	mov    %edi,%edx
f01066e0:	83 c4 1c             	add    $0x1c,%esp
f01066e3:	5b                   	pop    %ebx
f01066e4:	5e                   	pop    %esi
f01066e5:	5f                   	pop    %edi
f01066e6:	5d                   	pop    %ebp
f01066e7:	c3                   	ret    
f01066e8:	90                   	nop
f01066e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01066f0:	89 d8                	mov    %ebx,%eax
f01066f2:	f7 f7                	div    %edi
f01066f4:	31 ff                	xor    %edi,%edi
f01066f6:	89 c3                	mov    %eax,%ebx
f01066f8:	89 d8                	mov    %ebx,%eax
f01066fa:	89 fa                	mov    %edi,%edx
f01066fc:	83 c4 1c             	add    $0x1c,%esp
f01066ff:	5b                   	pop    %ebx
f0106700:	5e                   	pop    %esi
f0106701:	5f                   	pop    %edi
f0106702:	5d                   	pop    %ebp
f0106703:	c3                   	ret    
f0106704:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106708:	39 ce                	cmp    %ecx,%esi
f010670a:	72 0c                	jb     f0106718 <__udivdi3+0x118>
f010670c:	31 db                	xor    %ebx,%ebx
f010670e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0106712:	0f 87 34 ff ff ff    	ja     f010664c <__udivdi3+0x4c>
f0106718:	bb 01 00 00 00       	mov    $0x1,%ebx
f010671d:	e9 2a ff ff ff       	jmp    f010664c <__udivdi3+0x4c>
f0106722:	66 90                	xchg   %ax,%ax
f0106724:	66 90                	xchg   %ax,%ax
f0106726:	66 90                	xchg   %ax,%ax
f0106728:	66 90                	xchg   %ax,%ax
f010672a:	66 90                	xchg   %ax,%ax
f010672c:	66 90                	xchg   %ax,%ax
f010672e:	66 90                	xchg   %ax,%ax

f0106730 <__umoddi3>:
f0106730:	55                   	push   %ebp
f0106731:	57                   	push   %edi
f0106732:	56                   	push   %esi
f0106733:	53                   	push   %ebx
f0106734:	83 ec 1c             	sub    $0x1c,%esp
f0106737:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010673b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010673f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106743:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106747:	85 d2                	test   %edx,%edx
f0106749:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010674d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106751:	89 f3                	mov    %esi,%ebx
f0106753:	89 3c 24             	mov    %edi,(%esp)
f0106756:	89 74 24 04          	mov    %esi,0x4(%esp)
f010675a:	75 1c                	jne    f0106778 <__umoddi3+0x48>
f010675c:	39 f7                	cmp    %esi,%edi
f010675e:	76 50                	jbe    f01067b0 <__umoddi3+0x80>
f0106760:	89 c8                	mov    %ecx,%eax
f0106762:	89 f2                	mov    %esi,%edx
f0106764:	f7 f7                	div    %edi
f0106766:	89 d0                	mov    %edx,%eax
f0106768:	31 d2                	xor    %edx,%edx
f010676a:	83 c4 1c             	add    $0x1c,%esp
f010676d:	5b                   	pop    %ebx
f010676e:	5e                   	pop    %esi
f010676f:	5f                   	pop    %edi
f0106770:	5d                   	pop    %ebp
f0106771:	c3                   	ret    
f0106772:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106778:	39 f2                	cmp    %esi,%edx
f010677a:	89 d0                	mov    %edx,%eax
f010677c:	77 52                	ja     f01067d0 <__umoddi3+0xa0>
f010677e:	0f bd ea             	bsr    %edx,%ebp
f0106781:	83 f5 1f             	xor    $0x1f,%ebp
f0106784:	75 5a                	jne    f01067e0 <__umoddi3+0xb0>
f0106786:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010678a:	0f 82 e0 00 00 00    	jb     f0106870 <__umoddi3+0x140>
f0106790:	39 0c 24             	cmp    %ecx,(%esp)
f0106793:	0f 86 d7 00 00 00    	jbe    f0106870 <__umoddi3+0x140>
f0106799:	8b 44 24 08          	mov    0x8(%esp),%eax
f010679d:	8b 54 24 04          	mov    0x4(%esp),%edx
f01067a1:	83 c4 1c             	add    $0x1c,%esp
f01067a4:	5b                   	pop    %ebx
f01067a5:	5e                   	pop    %esi
f01067a6:	5f                   	pop    %edi
f01067a7:	5d                   	pop    %ebp
f01067a8:	c3                   	ret    
f01067a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01067b0:	85 ff                	test   %edi,%edi
f01067b2:	89 fd                	mov    %edi,%ebp
f01067b4:	75 0b                	jne    f01067c1 <__umoddi3+0x91>
f01067b6:	b8 01 00 00 00       	mov    $0x1,%eax
f01067bb:	31 d2                	xor    %edx,%edx
f01067bd:	f7 f7                	div    %edi
f01067bf:	89 c5                	mov    %eax,%ebp
f01067c1:	89 f0                	mov    %esi,%eax
f01067c3:	31 d2                	xor    %edx,%edx
f01067c5:	f7 f5                	div    %ebp
f01067c7:	89 c8                	mov    %ecx,%eax
f01067c9:	f7 f5                	div    %ebp
f01067cb:	89 d0                	mov    %edx,%eax
f01067cd:	eb 99                	jmp    f0106768 <__umoddi3+0x38>
f01067cf:	90                   	nop
f01067d0:	89 c8                	mov    %ecx,%eax
f01067d2:	89 f2                	mov    %esi,%edx
f01067d4:	83 c4 1c             	add    $0x1c,%esp
f01067d7:	5b                   	pop    %ebx
f01067d8:	5e                   	pop    %esi
f01067d9:	5f                   	pop    %edi
f01067da:	5d                   	pop    %ebp
f01067db:	c3                   	ret    
f01067dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01067e0:	8b 34 24             	mov    (%esp),%esi
f01067e3:	bf 20 00 00 00       	mov    $0x20,%edi
f01067e8:	89 e9                	mov    %ebp,%ecx
f01067ea:	29 ef                	sub    %ebp,%edi
f01067ec:	d3 e0                	shl    %cl,%eax
f01067ee:	89 f9                	mov    %edi,%ecx
f01067f0:	89 f2                	mov    %esi,%edx
f01067f2:	d3 ea                	shr    %cl,%edx
f01067f4:	89 e9                	mov    %ebp,%ecx
f01067f6:	09 c2                	or     %eax,%edx
f01067f8:	89 d8                	mov    %ebx,%eax
f01067fa:	89 14 24             	mov    %edx,(%esp)
f01067fd:	89 f2                	mov    %esi,%edx
f01067ff:	d3 e2                	shl    %cl,%edx
f0106801:	89 f9                	mov    %edi,%ecx
f0106803:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106807:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010680b:	d3 e8                	shr    %cl,%eax
f010680d:	89 e9                	mov    %ebp,%ecx
f010680f:	89 c6                	mov    %eax,%esi
f0106811:	d3 e3                	shl    %cl,%ebx
f0106813:	89 f9                	mov    %edi,%ecx
f0106815:	89 d0                	mov    %edx,%eax
f0106817:	d3 e8                	shr    %cl,%eax
f0106819:	89 e9                	mov    %ebp,%ecx
f010681b:	09 d8                	or     %ebx,%eax
f010681d:	89 d3                	mov    %edx,%ebx
f010681f:	89 f2                	mov    %esi,%edx
f0106821:	f7 34 24             	divl   (%esp)
f0106824:	89 d6                	mov    %edx,%esi
f0106826:	d3 e3                	shl    %cl,%ebx
f0106828:	f7 64 24 04          	mull   0x4(%esp)
f010682c:	39 d6                	cmp    %edx,%esi
f010682e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106832:	89 d1                	mov    %edx,%ecx
f0106834:	89 c3                	mov    %eax,%ebx
f0106836:	72 08                	jb     f0106840 <__umoddi3+0x110>
f0106838:	75 11                	jne    f010684b <__umoddi3+0x11b>
f010683a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010683e:	73 0b                	jae    f010684b <__umoddi3+0x11b>
f0106840:	2b 44 24 04          	sub    0x4(%esp),%eax
f0106844:	1b 14 24             	sbb    (%esp),%edx
f0106847:	89 d1                	mov    %edx,%ecx
f0106849:	89 c3                	mov    %eax,%ebx
f010684b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010684f:	29 da                	sub    %ebx,%edx
f0106851:	19 ce                	sbb    %ecx,%esi
f0106853:	89 f9                	mov    %edi,%ecx
f0106855:	89 f0                	mov    %esi,%eax
f0106857:	d3 e0                	shl    %cl,%eax
f0106859:	89 e9                	mov    %ebp,%ecx
f010685b:	d3 ea                	shr    %cl,%edx
f010685d:	89 e9                	mov    %ebp,%ecx
f010685f:	d3 ee                	shr    %cl,%esi
f0106861:	09 d0                	or     %edx,%eax
f0106863:	89 f2                	mov    %esi,%edx
f0106865:	83 c4 1c             	add    $0x1c,%esp
f0106868:	5b                   	pop    %ebx
f0106869:	5e                   	pop    %esi
f010686a:	5f                   	pop    %edi
f010686b:	5d                   	pop    %ebp
f010686c:	c3                   	ret    
f010686d:	8d 76 00             	lea    0x0(%esi),%esi
f0106870:	29 f9                	sub    %edi,%ecx
f0106872:	19 d6                	sbb    %edx,%esi
f0106874:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106878:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010687c:	e9 18 ff ff ff       	jmp    f0106799 <__umoddi3+0x69>
