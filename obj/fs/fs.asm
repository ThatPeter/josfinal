
obj/fs/fs:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 f2 19 00 00       	call   801a23 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	89 c1                	mov    %eax,%ecx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800039:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003e:	ec                   	in     (%dx),%al
  80003f:	89 c3                	mov    %eax,%ebx
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800041:	83 e0 c0             	and    $0xffffffc0,%eax
  800044:	3c 40                	cmp    $0x40,%al
  800046:	75 f6                	jne    80003e <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
		return -1;
	return 0;
  800048:	b8 00 00 00 00       	mov    $0x0,%eax
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80004d:	84 c9                	test   %cl,%cl
  80004f:	74 0b                	je     80005c <ide_wait_ready+0x29>
  800051:	f6 c3 21             	test   $0x21,%bl
  800054:	0f 95 c0             	setne  %al
  800057:	0f b6 c0             	movzbl %al,%eax
  80005a:	f7 d8                	neg    %eax
		return -1;
	return 0;
}
  80005c:	5b                   	pop    %ebx
  80005d:	5d                   	pop    %ebp
  80005e:	c3                   	ret    

0080005f <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	53                   	push   %ebx
  800063:	83 ec 04             	sub    $0x4,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  800066:	b8 00 00 00 00       	mov    $0x0,%eax
  80006b:	e8 c3 ff ff ff       	call   800033 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800070:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800075:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80007a:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80007b:	b9 00 00 00 00       	mov    $0x0,%ecx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800080:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800085:	eb 0b                	jmp    800092 <ide_probe_disk1+0x33>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  800087:	83 c1 01             	add    $0x1,%ecx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80008a:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  800090:	74 05                	je     800097 <ide_probe_disk1+0x38>
  800092:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800093:	a8 a1                	test   $0xa1,%al
  800095:	75 f0                	jne    800087 <ide_probe_disk1+0x28>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800097:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80009c:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  8000a1:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000a2:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000a8:	0f 9e c3             	setle  %bl
  8000ab:	83 ec 08             	sub    $0x8,%esp
  8000ae:	0f b6 c3             	movzbl %bl,%eax
  8000b1:	50                   	push   %eax
  8000b2:	68 80 38 80 00       	push   $0x803880
  8000b7:	e8 e8 1a 00 00       	call   801ba4 <cprintf>
	return (x < 1000);
}
  8000bc:	89 d8                	mov    %ebx,%eax
  8000be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c1:	c9                   	leave  
  8000c2:	c3                   	ret    

008000c3 <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	83 ec 08             	sub    $0x8,%esp
  8000c9:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000cc:	83 f8 01             	cmp    $0x1,%eax
  8000cf:	76 14                	jbe    8000e5 <ide_set_disk+0x22>
		panic("bad disk number");
  8000d1:	83 ec 04             	sub    $0x4,%esp
  8000d4:	68 97 38 80 00       	push   $0x803897
  8000d9:	6a 3a                	push   $0x3a
  8000db:	68 a7 38 80 00       	push   $0x8038a7
  8000e0:	e8 e6 19 00 00       	call   801acb <_panic>
	diskno = d;
  8000e5:	a3 00 50 80 00       	mov    %eax,0x805000
}
  8000ea:	c9                   	leave  
  8000eb:	c3                   	ret    

008000ec <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	57                   	push   %edi
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8000f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000fb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  8000fe:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  800104:	76 16                	jbe    80011c <ide_read+0x30>
  800106:	68 b0 38 80 00       	push   $0x8038b0
  80010b:	68 bd 38 80 00       	push   $0x8038bd
  800110:	6a 44                	push   $0x44
  800112:	68 a7 38 80 00       	push   $0x8038a7
  800117:	e8 af 19 00 00       	call   801acb <_panic>

	ide_wait_ready(0);
  80011c:	b8 00 00 00 00       	mov    $0x0,%eax
  800121:	e8 0d ff ff ff       	call   800033 <ide_wait_ready>
  800126:	ba f2 01 00 00       	mov    $0x1f2,%edx
  80012b:	89 f0                	mov    %esi,%eax
  80012d:	ee                   	out    %al,(%dx)
  80012e:	ba f3 01 00 00       	mov    $0x1f3,%edx
  800133:	89 f8                	mov    %edi,%eax
  800135:	ee                   	out    %al,(%dx)
  800136:	89 f8                	mov    %edi,%eax
  800138:	c1 e8 08             	shr    $0x8,%eax
  80013b:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800140:	ee                   	out    %al,(%dx)
  800141:	89 f8                	mov    %edi,%eax
  800143:	c1 e8 10             	shr    $0x10,%eax
  800146:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80014b:	ee                   	out    %al,(%dx)
  80014c:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800153:	83 e0 01             	and    $0x1,%eax
  800156:	c1 e0 04             	shl    $0x4,%eax
  800159:	83 c8 e0             	or     $0xffffffe0,%eax
  80015c:	c1 ef 18             	shr    $0x18,%edi
  80015f:	83 e7 0f             	and    $0xf,%edi
  800162:	09 f8                	or     %edi,%eax
  800164:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800169:	ee                   	out    %al,(%dx)
  80016a:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80016f:	b8 20 00 00 00       	mov    $0x20,%eax
  800174:	ee                   	out    %al,(%dx)
  800175:	c1 e6 09             	shl    $0x9,%esi
  800178:	01 de                	add    %ebx,%esi
  80017a:	eb 23                	jmp    80019f <ide_read+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  80017c:	b8 01 00 00 00       	mov    $0x1,%eax
  800181:	e8 ad fe ff ff       	call   800033 <ide_wait_ready>
  800186:	85 c0                	test   %eax,%eax
  800188:	78 1e                	js     8001a8 <ide_read+0xbc>
}

static inline void
insl(int port, void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\tinsl"
  80018a:	89 df                	mov    %ebx,%edi
  80018c:	b9 80 00 00 00       	mov    $0x80,%ecx
  800191:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800196:	fc                   	cld    
  800197:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800199:	81 c3 00 02 00 00    	add    $0x200,%ebx
  80019f:	39 f3                	cmp    %esi,%ebx
  8001a1:	75 d9                	jne    80017c <ide_read+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  8001a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ab:	5b                   	pop    %ebx
  8001ac:	5e                   	pop    %esi
  8001ad:	5f                   	pop    %edi
  8001ae:	5d                   	pop    %ebp
  8001af:	c3                   	ret    

008001b0 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	57                   	push   %edi
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8001bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001bf:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r;

	assert(nsecs <= 256);
  8001c2:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  8001c8:	76 16                	jbe    8001e0 <ide_write+0x30>
  8001ca:	68 b0 38 80 00       	push   $0x8038b0
  8001cf:	68 bd 38 80 00       	push   $0x8038bd
  8001d4:	6a 5d                	push   $0x5d
  8001d6:	68 a7 38 80 00       	push   $0x8038a7
  8001db:	e8 eb 18 00 00       	call   801acb <_panic>

	ide_wait_ready(0);
  8001e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001e5:	e8 49 fe ff ff       	call   800033 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001ea:	ba f2 01 00 00       	mov    $0x1f2,%edx
  8001ef:	89 f8                	mov    %edi,%eax
  8001f1:	ee                   	out    %al,(%dx)
  8001f2:	ba f3 01 00 00       	mov    $0x1f3,%edx
  8001f7:	89 f0                	mov    %esi,%eax
  8001f9:	ee                   	out    %al,(%dx)
  8001fa:	89 f0                	mov    %esi,%eax
  8001fc:	c1 e8 08             	shr    $0x8,%eax
  8001ff:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800204:	ee                   	out    %al,(%dx)
  800205:	89 f0                	mov    %esi,%eax
  800207:	c1 e8 10             	shr    $0x10,%eax
  80020a:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80020f:	ee                   	out    %al,(%dx)
  800210:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800217:	83 e0 01             	and    $0x1,%eax
  80021a:	c1 e0 04             	shl    $0x4,%eax
  80021d:	83 c8 e0             	or     $0xffffffe0,%eax
  800220:	c1 ee 18             	shr    $0x18,%esi
  800223:	83 e6 0f             	and    $0xf,%esi
  800226:	09 f0                	or     %esi,%eax
  800228:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80022d:	ee                   	out    %al,(%dx)
  80022e:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800233:	b8 30 00 00 00       	mov    $0x30,%eax
  800238:	ee                   	out    %al,(%dx)
  800239:	c1 e7 09             	shl    $0x9,%edi
  80023c:	01 df                	add    %ebx,%edi
  80023e:	eb 23                	jmp    800263 <ide_write+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  800240:	b8 01 00 00 00       	mov    $0x1,%eax
  800245:	e8 e9 fd ff ff       	call   800033 <ide_wait_ready>
  80024a:	85 c0                	test   %eax,%eax
  80024c:	78 1e                	js     80026c <ide_write+0xbc>
}

static inline void
outsl(int port, const void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\toutsl"
  80024e:	89 de                	mov    %ebx,%esi
  800250:	b9 80 00 00 00       	mov    $0x80,%ecx
  800255:	ba f0 01 00 00       	mov    $0x1f0,%edx
  80025a:	fc                   	cld    
  80025b:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  80025d:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800263:	39 fb                	cmp    %edi,%ebx
  800265:	75 d9                	jne    800240 <ide_write+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  800267:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  80027c:	8b 1a                	mov    (%edx),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  80027e:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  800284:	89 c6                	mov    %eax,%esi
  800286:	c1 ee 0c             	shr    $0xc,%esi
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800289:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  80028e:	76 1b                	jbe    8002ab <bc_pgfault+0x37>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  800290:	83 ec 08             	sub    $0x8,%esp
  800293:	ff 72 04             	pushl  0x4(%edx)
  800296:	53                   	push   %ebx
  800297:	ff 72 28             	pushl  0x28(%edx)
  80029a:	68 d4 38 80 00       	push   $0x8038d4
  80029f:	6a 27                	push   $0x27
  8002a1:	68 90 39 80 00       	push   $0x803990
  8002a6:	e8 20 18 00 00       	call   801acb <_panic>
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002ab:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8002b0:	85 c0                	test   %eax,%eax
  8002b2:	74 17                	je     8002cb <bc_pgfault+0x57>
  8002b4:	3b 70 04             	cmp    0x4(%eax),%esi
  8002b7:	72 12                	jb     8002cb <bc_pgfault+0x57>
		panic("reading non-existent block %08x\n", blockno);
  8002b9:	56                   	push   %esi
  8002ba:	68 04 39 80 00       	push   $0x803904
  8002bf:	6a 2b                	push   $0x2b
  8002c1:	68 90 39 80 00       	push   $0x803990
  8002c6:	e8 00 18 00 00       	call   801acb <_panic>
	// of the block from the disk into that page.
	// Hint: first round addr to page boundary. fs/ide.c has code to read
	// the disk.
	//
	// LAB 5: you code here:
	addr = ROUNDDOWN(addr, PGSIZE);
  8002cb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	r = sys_page_alloc(0, addr, PTE_P | PTE_W | PTE_U);
  8002d1:	83 ec 04             	sub    $0x4,%esp
  8002d4:	6a 07                	push   $0x7
  8002d6:	53                   	push   %ebx
  8002d7:	6a 00                	push   $0x0
  8002d9:	e8 4e 22 00 00       	call   80252c <sys_page_alloc>

	if (r < 0) {
  8002de:	83 c4 10             	add    $0x10,%esp
  8002e1:	85 c0                	test   %eax,%eax
  8002e3:	79 12                	jns    8002f7 <bc_pgfault+0x83>
		panic("page alloc fault - %e", r);
  8002e5:	50                   	push   %eax
  8002e6:	68 98 39 80 00       	push   $0x803998
  8002eb:	6a 37                	push   $0x37
  8002ed:	68 90 39 80 00       	push   $0x803990
  8002f2:	e8 d4 17 00 00       	call   801acb <_panic>
	}

	r = ide_read(blockno * BLKSECTS, addr, BLKSECTS);
  8002f7:	83 ec 04             	sub    $0x4,%esp
  8002fa:	6a 08                	push   $0x8
  8002fc:	53                   	push   %ebx
  8002fd:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  800304:	50                   	push   %eax
  800305:	e8 e2 fd ff ff       	call   8000ec <ide_read>

	if (r < 0) {
  80030a:	83 c4 10             	add    $0x10,%esp
  80030d:	85 c0                	test   %eax,%eax
  80030f:	79 12                	jns    800323 <bc_pgfault+0xaf>
		panic("ide_read fault - %e", r);
  800311:	50                   	push   %eax
  800312:	68 ae 39 80 00       	push   $0x8039ae
  800317:	6a 3d                	push   $0x3d
  800319:	68 90 39 80 00       	push   $0x803990
  80031e:	e8 a8 17 00 00       	call   801acb <_panic>
	}
	
	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  800323:	89 d8                	mov    %ebx,%eax
  800325:	c1 e8 0c             	shr    $0xc,%eax
  800328:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80032f:	83 ec 0c             	sub    $0xc,%esp
  800332:	25 07 0e 00 00       	and    $0xe07,%eax
  800337:	50                   	push   %eax
  800338:	53                   	push   %ebx
  800339:	6a 00                	push   $0x0
  80033b:	53                   	push   %ebx
  80033c:	6a 00                	push   $0x0
  80033e:	e8 2c 22 00 00       	call   80256f <sys_page_map>
  800343:	83 c4 20             	add    $0x20,%esp
  800346:	85 c0                	test   %eax,%eax
  800348:	79 12                	jns    80035c <bc_pgfault+0xe8>
		panic("in bc_pgfault, sys_page_map: %e", r);
  80034a:	50                   	push   %eax
  80034b:	68 28 39 80 00       	push   $0x803928
  800350:	6a 43                	push   $0x43
  800352:	68 90 39 80 00       	push   $0x803990
  800357:	e8 6f 17 00 00       	call   801acb <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  80035c:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  800363:	74 22                	je     800387 <bc_pgfault+0x113>
  800365:	83 ec 0c             	sub    $0xc,%esp
  800368:	56                   	push   %esi
  800369:	e8 5e 04 00 00       	call   8007cc <block_is_free>
  80036e:	83 c4 10             	add    $0x10,%esp
  800371:	84 c0                	test   %al,%al
  800373:	74 12                	je     800387 <bc_pgfault+0x113>
		panic("reading free block %08x\n", blockno);
  800375:	56                   	push   %esi
  800376:	68 c2 39 80 00       	push   $0x8039c2
  80037b:	6a 49                	push   $0x49
  80037d:	68 90 39 80 00       	push   $0x803990
  800382:	e8 44 17 00 00       	call   801acb <_panic>
}
  800387:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80038a:	5b                   	pop    %ebx
  80038b:	5e                   	pop    %esi
  80038c:	5d                   	pop    %ebp
  80038d:	c3                   	ret    

0080038e <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	83 ec 08             	sub    $0x8,%esp
  800394:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  800397:	85 c0                	test   %eax,%eax
  800399:	74 0f                	je     8003aa <diskaddr+0x1c>
  80039b:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8003a1:	85 d2                	test   %edx,%edx
  8003a3:	74 17                	je     8003bc <diskaddr+0x2e>
  8003a5:	3b 42 04             	cmp    0x4(%edx),%eax
  8003a8:	72 12                	jb     8003bc <diskaddr+0x2e>
		panic("bad block number %08x in diskaddr", blockno);
  8003aa:	50                   	push   %eax
  8003ab:	68 48 39 80 00       	push   $0x803948
  8003b0:	6a 09                	push   $0x9
  8003b2:	68 90 39 80 00       	push   $0x803990
  8003b7:	e8 0f 17 00 00       	call   801acb <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  8003bc:	05 00 00 01 00       	add    $0x10000,%eax
  8003c1:	c1 e0 0c             	shl    $0xc,%eax
}
  8003c4:	c9                   	leave  
  8003c5:	c3                   	ret    

008003c6 <va_is_mapped>:

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  8003c6:	55                   	push   %ebp
  8003c7:	89 e5                	mov    %esp,%ebp
  8003c9:	8b 55 08             	mov    0x8(%ebp),%edx
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  8003cc:	89 d0                	mov    %edx,%eax
  8003ce:	c1 e8 16             	shr    $0x16,%eax
  8003d1:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  8003d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003dd:	f6 c1 01             	test   $0x1,%cl
  8003e0:	74 0d                	je     8003ef <va_is_mapped+0x29>
  8003e2:	c1 ea 0c             	shr    $0xc,%edx
  8003e5:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8003ec:	83 e0 01             	and    $0x1,%eax
  8003ef:	83 e0 01             	and    $0x1,%eax
}
  8003f2:	5d                   	pop    %ebp
  8003f3:	c3                   	ret    

008003f4 <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  8003f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fa:	c1 e8 0c             	shr    $0xc,%eax
  8003fd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800404:	c1 e8 06             	shr    $0x6,%eax
  800407:	83 e0 01             	and    $0x1,%eax
}
  80040a:	5d                   	pop    %ebp
  80040b:	c3                   	ret    

0080040c <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	56                   	push   %esi
  800410:	53                   	push   %ebx
  800411:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800414:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  80041a:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  80041f:	76 12                	jbe    800433 <flush_block+0x27>
		panic("flush_block of bad va %08x", addr);
  800421:	53                   	push   %ebx
  800422:	68 db 39 80 00       	push   $0x8039db
  800427:	6a 59                	push   $0x59
  800429:	68 90 39 80 00       	push   $0x803990
  80042e:	e8 98 16 00 00       	call   801acb <_panic>

	// LAB 5: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  800433:	89 de                	mov    %ebx,%esi
  800435:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi

	if(va_is_dirty(addr) && va_is_mapped(addr)) {
  80043b:	83 ec 0c             	sub    $0xc,%esp
  80043e:	56                   	push   %esi
  80043f:	e8 b0 ff ff ff       	call   8003f4 <va_is_dirty>
  800444:	83 c4 10             	add    $0x10,%esp
  800447:	84 c0                	test   %al,%al
  800449:	74 4a                	je     800495 <flush_block+0x89>
  80044b:	83 ec 0c             	sub    $0xc,%esp
  80044e:	56                   	push   %esi
  80044f:	e8 72 ff ff ff       	call   8003c6 <va_is_mapped>
  800454:	83 c4 10             	add    $0x10,%esp
  800457:	84 c0                	test   %al,%al
  800459:	74 3a                	je     800495 <flush_block+0x89>
		ide_write(blockno * BLKSECTS, addr, BLKSECTS);
  80045b:	83 ec 04             	sub    $0x4,%esp
  80045e:	6a 08                	push   $0x8
  800460:	56                   	push   %esi
  800461:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
  800467:	c1 eb 0c             	shr    $0xc,%ebx
  80046a:	c1 e3 03             	shl    $0x3,%ebx
  80046d:	53                   	push   %ebx
  80046e:	e8 3d fd ff ff       	call   8001b0 <ide_write>
		sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL);
  800473:	89 f0                	mov    %esi,%eax
  800475:	c1 e8 0c             	shr    $0xc,%eax
  800478:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80047f:	25 07 0e 00 00       	and    $0xe07,%eax
  800484:	89 04 24             	mov    %eax,(%esp)
  800487:	56                   	push   %esi
  800488:	6a 00                	push   $0x0
  80048a:	56                   	push   %esi
  80048b:	6a 00                	push   $0x0
  80048d:	e8 dd 20 00 00       	call   80256f <sys_page_map>
  800492:	83 c4 20             	add    $0x20,%esp
	}
	//panic("flush_block not implemented");
}
  800495:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800498:	5b                   	pop    %ebx
  800499:	5e                   	pop    %esi
  80049a:	5d                   	pop    %ebp
  80049b:	c3                   	ret    

0080049c <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  80049c:	55                   	push   %ebp
  80049d:	89 e5                	mov    %esp,%ebp
  80049f:	53                   	push   %ebx
  8004a0:	81 ec 20 02 00 00    	sub    $0x220,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  8004a6:	68 74 02 80 00       	push   $0x800274
  8004ab:	e8 6d 22 00 00       	call   80271d <set_pgfault_handler>
check_bc(void)
{
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  8004b0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004b7:	e8 d2 fe ff ff       	call   80038e <diskaddr>
  8004bc:	83 c4 0c             	add    $0xc,%esp
  8004bf:	68 08 01 00 00       	push   $0x108
  8004c4:	50                   	push   %eax
  8004c5:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8004cb:	50                   	push   %eax
  8004cc:	e8 ea 1d 00 00       	call   8022bb <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  8004d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004d8:	e8 b1 fe ff ff       	call   80038e <diskaddr>
  8004dd:	83 c4 08             	add    $0x8,%esp
  8004e0:	68 f6 39 80 00       	push   $0x8039f6
  8004e5:	50                   	push   %eax
  8004e6:	e8 3e 1c 00 00       	call   802129 <strcpy>
	flush_block(diskaddr(1));
  8004eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004f2:	e8 97 fe ff ff       	call   80038e <diskaddr>
  8004f7:	89 04 24             	mov    %eax,(%esp)
  8004fa:	e8 0d ff ff ff       	call   80040c <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  8004ff:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800506:	e8 83 fe ff ff       	call   80038e <diskaddr>
  80050b:	89 04 24             	mov    %eax,(%esp)
  80050e:	e8 b3 fe ff ff       	call   8003c6 <va_is_mapped>
  800513:	83 c4 10             	add    $0x10,%esp
  800516:	84 c0                	test   %al,%al
  800518:	75 16                	jne    800530 <bc_init+0x94>
  80051a:	68 18 3a 80 00       	push   $0x803a18
  80051f:	68 bd 38 80 00       	push   $0x8038bd
  800524:	6a 72                	push   $0x72
  800526:	68 90 39 80 00       	push   $0x803990
  80052b:	e8 9b 15 00 00       	call   801acb <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  800530:	83 ec 0c             	sub    $0xc,%esp
  800533:	6a 01                	push   $0x1
  800535:	e8 54 fe ff ff       	call   80038e <diskaddr>
  80053a:	89 04 24             	mov    %eax,(%esp)
  80053d:	e8 b2 fe ff ff       	call   8003f4 <va_is_dirty>
  800542:	83 c4 10             	add    $0x10,%esp
  800545:	84 c0                	test   %al,%al
  800547:	74 16                	je     80055f <bc_init+0xc3>
  800549:	68 fd 39 80 00       	push   $0x8039fd
  80054e:	68 bd 38 80 00       	push   $0x8038bd
  800553:	6a 73                	push   $0x73
  800555:	68 90 39 80 00       	push   $0x803990
  80055a:	e8 6c 15 00 00       	call   801acb <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  80055f:	83 ec 0c             	sub    $0xc,%esp
  800562:	6a 01                	push   $0x1
  800564:	e8 25 fe ff ff       	call   80038e <diskaddr>
  800569:	83 c4 08             	add    $0x8,%esp
  80056c:	50                   	push   %eax
  80056d:	6a 00                	push   $0x0
  80056f:	e8 3d 20 00 00       	call   8025b1 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  800574:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80057b:	e8 0e fe ff ff       	call   80038e <diskaddr>
  800580:	89 04 24             	mov    %eax,(%esp)
  800583:	e8 3e fe ff ff       	call   8003c6 <va_is_mapped>
  800588:	83 c4 10             	add    $0x10,%esp
  80058b:	84 c0                	test   %al,%al
  80058d:	74 16                	je     8005a5 <bc_init+0x109>
  80058f:	68 17 3a 80 00       	push   $0x803a17
  800594:	68 bd 38 80 00       	push   $0x8038bd
  800599:	6a 77                	push   $0x77
  80059b:	68 90 39 80 00       	push   $0x803990
  8005a0:	e8 26 15 00 00       	call   801acb <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8005a5:	83 ec 0c             	sub    $0xc,%esp
  8005a8:	6a 01                	push   $0x1
  8005aa:	e8 df fd ff ff       	call   80038e <diskaddr>
  8005af:	83 c4 08             	add    $0x8,%esp
  8005b2:	68 f6 39 80 00       	push   $0x8039f6
  8005b7:	50                   	push   %eax
  8005b8:	e8 16 1c 00 00       	call   8021d3 <strcmp>
  8005bd:	83 c4 10             	add    $0x10,%esp
  8005c0:	85 c0                	test   %eax,%eax
  8005c2:	74 16                	je     8005da <bc_init+0x13e>
  8005c4:	68 6c 39 80 00       	push   $0x80396c
  8005c9:	68 bd 38 80 00       	push   $0x8038bd
  8005ce:	6a 7a                	push   $0x7a
  8005d0:	68 90 39 80 00       	push   $0x803990
  8005d5:	e8 f1 14 00 00       	call   801acb <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  8005da:	83 ec 0c             	sub    $0xc,%esp
  8005dd:	6a 01                	push   $0x1
  8005df:	e8 aa fd ff ff       	call   80038e <diskaddr>
  8005e4:	83 c4 0c             	add    $0xc,%esp
  8005e7:	68 08 01 00 00       	push   $0x108
  8005ec:	8d 9d e8 fd ff ff    	lea    -0x218(%ebp),%ebx
  8005f2:	53                   	push   %ebx
  8005f3:	50                   	push   %eax
  8005f4:	e8 c2 1c 00 00       	call   8022bb <memmove>
	flush_block(diskaddr(1));
  8005f9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800600:	e8 89 fd ff ff       	call   80038e <diskaddr>
  800605:	89 04 24             	mov    %eax,(%esp)
  800608:	e8 ff fd ff ff       	call   80040c <flush_block>

	// Now repeat the same experiment, but pass an unaligned address to
	// flush_block.

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  80060d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800614:	e8 75 fd ff ff       	call   80038e <diskaddr>
  800619:	83 c4 0c             	add    $0xc,%esp
  80061c:	68 08 01 00 00       	push   $0x108
  800621:	50                   	push   %eax
  800622:	53                   	push   %ebx
  800623:	e8 93 1c 00 00       	call   8022bb <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  800628:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80062f:	e8 5a fd ff ff       	call   80038e <diskaddr>
  800634:	83 c4 08             	add    $0x8,%esp
  800637:	68 f6 39 80 00       	push   $0x8039f6
  80063c:	50                   	push   %eax
  80063d:	e8 e7 1a 00 00       	call   802129 <strcpy>

	// Pass an unaligned address to flush_block.
	flush_block(diskaddr(1) + 20);
  800642:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800649:	e8 40 fd ff ff       	call   80038e <diskaddr>
  80064e:	83 c0 14             	add    $0x14,%eax
  800651:	89 04 24             	mov    %eax,(%esp)
  800654:	e8 b3 fd ff ff       	call   80040c <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800659:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800660:	e8 29 fd ff ff       	call   80038e <diskaddr>
  800665:	89 04 24             	mov    %eax,(%esp)
  800668:	e8 59 fd ff ff       	call   8003c6 <va_is_mapped>
  80066d:	83 c4 10             	add    $0x10,%esp
  800670:	84 c0                	test   %al,%al
  800672:	75 19                	jne    80068d <bc_init+0x1f1>
  800674:	68 18 3a 80 00       	push   $0x803a18
  800679:	68 bd 38 80 00       	push   $0x8038bd
  80067e:	68 8b 00 00 00       	push   $0x8b
  800683:	68 90 39 80 00       	push   $0x803990
  800688:	e8 3e 14 00 00       	call   801acb <_panic>
	// Skip the !va_is_dirty() check because it makes the bug somewhat
	// obscure and hence harder to debug.
	//assert(!va_is_dirty(diskaddr(1)));

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  80068d:	83 ec 0c             	sub    $0xc,%esp
  800690:	6a 01                	push   $0x1
  800692:	e8 f7 fc ff ff       	call   80038e <diskaddr>
  800697:	83 c4 08             	add    $0x8,%esp
  80069a:	50                   	push   %eax
  80069b:	6a 00                	push   $0x0
  80069d:	e8 0f 1f 00 00       	call   8025b1 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  8006a2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006a9:	e8 e0 fc ff ff       	call   80038e <diskaddr>
  8006ae:	89 04 24             	mov    %eax,(%esp)
  8006b1:	e8 10 fd ff ff       	call   8003c6 <va_is_mapped>
  8006b6:	83 c4 10             	add    $0x10,%esp
  8006b9:	84 c0                	test   %al,%al
  8006bb:	74 19                	je     8006d6 <bc_init+0x23a>
  8006bd:	68 17 3a 80 00       	push   $0x803a17
  8006c2:	68 bd 38 80 00       	push   $0x8038bd
  8006c7:	68 93 00 00 00       	push   $0x93
  8006cc:	68 90 39 80 00       	push   $0x803990
  8006d1:	e8 f5 13 00 00       	call   801acb <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8006d6:	83 ec 0c             	sub    $0xc,%esp
  8006d9:	6a 01                	push   $0x1
  8006db:	e8 ae fc ff ff       	call   80038e <diskaddr>
  8006e0:	83 c4 08             	add    $0x8,%esp
  8006e3:	68 f6 39 80 00       	push   $0x8039f6
  8006e8:	50                   	push   %eax
  8006e9:	e8 e5 1a 00 00       	call   8021d3 <strcmp>
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	85 c0                	test   %eax,%eax
  8006f3:	74 19                	je     80070e <bc_init+0x272>
  8006f5:	68 6c 39 80 00       	push   $0x80396c
  8006fa:	68 bd 38 80 00       	push   $0x8038bd
  8006ff:	68 96 00 00 00       	push   $0x96
  800704:	68 90 39 80 00       	push   $0x803990
  800709:	e8 bd 13 00 00       	call   801acb <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  80070e:	83 ec 0c             	sub    $0xc,%esp
  800711:	6a 01                	push   $0x1
  800713:	e8 76 fc ff ff       	call   80038e <diskaddr>
  800718:	83 c4 0c             	add    $0xc,%esp
  80071b:	68 08 01 00 00       	push   $0x108
  800720:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  800726:	52                   	push   %edx
  800727:	50                   	push   %eax
  800728:	e8 8e 1b 00 00       	call   8022bb <memmove>
	flush_block(diskaddr(1));
  80072d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800734:	e8 55 fc ff ff       	call   80038e <diskaddr>
  800739:	89 04 24             	mov    %eax,(%esp)
  80073c:	e8 cb fc ff ff       	call   80040c <flush_block>

	cprintf("block cache is good\n");
  800741:	c7 04 24 32 3a 80 00 	movl   $0x803a32,(%esp)
  800748:	e8 57 14 00 00       	call   801ba4 <cprintf>
	struct Super super;
	set_pgfault_handler(bc_pgfault);
	check_bc();

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  80074d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800754:	e8 35 fc ff ff       	call   80038e <diskaddr>
  800759:	83 c4 0c             	add    $0xc,%esp
  80075c:	68 08 01 00 00       	push   $0x108
  800761:	50                   	push   %eax
  800762:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800768:	50                   	push   %eax
  800769:	e8 4d 1b 00 00       	call   8022bb <memmove>
}
  80076e:	83 c4 10             	add    $0x10,%esp
  800771:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800774:	c9                   	leave  
  800775:	c3                   	ret    

00800776 <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  80077c:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800781:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  800787:	74 14                	je     80079d <check_super+0x27>
		panic("bad file system magic number");
  800789:	83 ec 04             	sub    $0x4,%esp
  80078c:	68 47 3a 80 00       	push   $0x803a47
  800791:	6a 0f                	push   $0xf
  800793:	68 64 3a 80 00       	push   $0x803a64
  800798:	e8 2e 13 00 00       	call   801acb <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  80079d:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8007a4:	76 14                	jbe    8007ba <check_super+0x44>
		panic("file system is too large");
  8007a6:	83 ec 04             	sub    $0x4,%esp
  8007a9:	68 6c 3a 80 00       	push   $0x803a6c
  8007ae:	6a 12                	push   $0x12
  8007b0:	68 64 3a 80 00       	push   $0x803a64
  8007b5:	e8 11 13 00 00       	call   801acb <_panic>

	cprintf("superblock is good\n");
  8007ba:	83 ec 0c             	sub    $0xc,%esp
  8007bd:	68 85 3a 80 00       	push   $0x803a85
  8007c2:	e8 dd 13 00 00       	call   801ba4 <cprintf>
}
  8007c7:	83 c4 10             	add    $0x10,%esp
  8007ca:	c9                   	leave  
  8007cb:	c3                   	ret    

008007cc <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	53                   	push   %ebx
  8007d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  8007d3:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8007d9:	85 d2                	test   %edx,%edx
  8007db:	74 24                	je     800801 <block_is_free+0x35>
		return 0;
  8007dd:	b8 00 00 00 00       	mov    $0x0,%eax
// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
  8007e2:	39 4a 04             	cmp    %ecx,0x4(%edx)
  8007e5:	76 1f                	jbe    800806 <block_is_free+0x3a>
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  8007e7:	89 cb                	mov    %ecx,%ebx
  8007e9:	c1 eb 05             	shr    $0x5,%ebx
  8007ec:	b8 01 00 00 00       	mov    $0x1,%eax
  8007f1:	d3 e0                	shl    %cl,%eax
  8007f3:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  8007f9:	85 04 9a             	test   %eax,(%edx,%ebx,4)
  8007fc:	0f 95 c0             	setne  %al
  8007ff:	eb 05                	jmp    800806 <block_is_free+0x3a>
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
		return 0;
  800801:	b8 00 00 00 00       	mov    $0x0,%eax
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  800806:	5b                   	pop    %ebx
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	53                   	push   %ebx
  80080d:	83 ec 04             	sub    $0x4,%esp
  800810:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  800813:	85 c9                	test   %ecx,%ecx
  800815:	75 14                	jne    80082b <free_block+0x22>
		panic("attempt to free zero block");
  800817:	83 ec 04             	sub    $0x4,%esp
  80081a:	68 99 3a 80 00       	push   $0x803a99
  80081f:	6a 2d                	push   $0x2d
  800821:	68 64 3a 80 00       	push   $0x803a64
  800826:	e8 a0 12 00 00       	call   801acb <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  80082b:	89 cb                	mov    %ecx,%ebx
  80082d:	c1 eb 05             	shr    $0x5,%ebx
  800830:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  800836:	b8 01 00 00 00       	mov    $0x1,%eax
  80083b:	d3 e0                	shl    %cl,%eax
  80083d:	09 04 9a             	or     %eax,(%edx,%ebx,4)
}
  800840:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800843:	c9                   	leave  
  800844:	c3                   	ret    

00800845 <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	56                   	push   %esi
  800849:	53                   	push   %ebx
	// LAB 5: Your code here.
	size_t i;
	uint32_t blockno = -1;
	int r;

	for (i = 0; i < super->s_nblocks * 32; i++) {
  80084a:	a1 08 a0 80 00       	mov    0x80a008,%eax
  80084f:	8b 70 04             	mov    0x4(%eax),%esi
  800852:	c1 e6 05             	shl    $0x5,%esi
  800855:	bb 00 00 00 00       	mov    $0x0,%ebx
  80085a:	eb 10                	jmp    80086c <alloc_block+0x27>
		if (block_is_free(i)) {
  80085c:	53                   	push   %ebx
  80085d:	e8 6a ff ff ff       	call   8007cc <block_is_free>
  800862:	83 c4 04             	add    $0x4,%esp
  800865:	84 c0                	test   %al,%al
  800867:	75 0e                	jne    800877 <alloc_block+0x32>
	// LAB 5: Your code here.
	size_t i;
	uint32_t blockno = -1;
	int r;

	for (i = 0; i < super->s_nblocks * 32; i++) {
  800869:	83 c3 01             	add    $0x1,%ebx
  80086c:	39 f3                	cmp    %esi,%ebx
  80086e:	75 ec                	jne    80085c <alloc_block+0x17>
			break;
		}
	}

	if (blockno == -1) {
		return -E_NO_DISK;
  800870:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
  800875:	eb 39                	jmp    8008b0 <alloc_block+0x6b>
			blockno = i;
			break;
		}
	}

	if (blockno == -1) {
  800877:	83 fb ff             	cmp    $0xffffffff,%ebx
  80087a:	74 2f                	je     8008ab <alloc_block+0x66>
		return -E_NO_DISK;
	}

	bitmap[blockno/32] ^= 1 << (blockno % 32);
  80087c:	89 de                	mov    %ebx,%esi
  80087e:	c1 ee 05             	shr    $0x5,%esi
  800881:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  800887:	b8 01 00 00 00       	mov    $0x1,%eax
  80088c:	89 d9                	mov    %ebx,%ecx
  80088e:	d3 e0                	shl    %cl,%eax
  800890:	31 04 b2             	xor    %eax,(%edx,%esi,4)
	flush_block(diskaddr(blockno));
  800893:	83 ec 0c             	sub    $0xc,%esp
  800896:	53                   	push   %ebx
  800897:	e8 f2 fa ff ff       	call   80038e <diskaddr>
  80089c:	89 04 24             	mov    %eax,(%esp)
  80089f:	e8 68 fb ff ff       	call   80040c <flush_block>
	
	return blockno;
  8008a4:	89 d8                	mov    %ebx,%eax
  8008a6:	83 c4 10             	add    $0x10,%esp
  8008a9:	eb 05                	jmp    8008b0 <alloc_block+0x6b>
			break;
		}
	}

	if (blockno == -1) {
		return -E_NO_DISK;
  8008ab:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax

	bitmap[blockno/32] ^= 1 << (blockno % 32);
	flush_block(diskaddr(blockno));
	
	return blockno;
}
  8008b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008b3:	5b                   	pop    %ebx
  8008b4:	5e                   	pop    %esi
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	57                   	push   %edi
  8008bb:	56                   	push   %esi
  8008bc:	53                   	push   %ebx
  8008bd:	83 ec 0c             	sub    $0xc,%esp
  8008c0:	89 ce                	mov    %ecx,%esi
  8008c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
       	// LAB 5: Your code here.

	if (filebno >= (NDIRECT + NINDIRECT)) {
  8008c5:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  8008cb:	77 5a                	ja     800927 <file_block_walk+0x70>
		return -E_INVAL;
	}
	
	if (filebno < NDIRECT) {
  8008cd:	83 fa 09             	cmp    $0x9,%edx
  8008d0:	77 63                	ja     800935 <file_block_walk+0x7e>
		*ppdiskbno = &f->f_direct[filebno];
  8008d2:	8d 84 90 88 00 00 00 	lea    0x88(%eax,%edx,4),%eax
  8008d9:	89 06                	mov    %eax,(%esi)
		} else {
			return -E_NOT_FOUND;
		}
	}	
	
	return 0;
  8008db:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e0:	eb 63                	jmp    800945 <file_block_walk+0x8e>
	}	

	if (filebno >= NDIRECT) {
		if (f->f_indirect) {
			//*ppdiskbno = (uint32_t*)diskaddr(f->f_indirect) + filebno - NDIRECT;
			uint32_t *indirect = (uint32_t*)diskaddr(f->f_indirect);
  8008e2:	83 ec 0c             	sub    $0xc,%esp
  8008e5:	50                   	push   %eax
  8008e6:	e8 a3 fa ff ff       	call   80038e <diskaddr>
			*ppdiskbno =  &indirect[filebno - NDIRECT];
  8008eb:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  8008ef:	89 06                	mov    %eax,(%esi)
  8008f1:	83 c4 10             	add    $0x10,%esp
		} else {
			return -E_NOT_FOUND;
		}
	}	
	
	return 0;
  8008f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f9:	eb 4a                	jmp    800945 <file_block_walk+0x8e>
			//*ppdiskbno = (uint32_t*)diskaddr(f->f_indirect) + filebno - NDIRECT;
			uint32_t *indirect = (uint32_t*)diskaddr(f->f_indirect);
			*ppdiskbno =  &indirect[filebno - NDIRECT];
		}

		else if (!f->f_indirect && alloc) {
  8008fb:	84 c9                	test   %cl,%cl
  8008fd:	74 2f                	je     80092e <file_block_walk+0x77>
			int blockno;
			if ((blockno = alloc_block()) < 0) {
  8008ff:	e8 41 ff ff ff       	call   800845 <alloc_block>
  800904:	85 c0                	test   %eax,%eax
  800906:	78 3d                	js     800945 <file_block_walk+0x8e>
				return blockno;
			}
			//flush_block(diskaddr(blockno));
			f->f_indirect = blockno; 
  800908:	89 87 b0 00 00 00    	mov    %eax,0xb0(%edi)
			uint32_t *indirect = (uint32_t*)diskaddr(f->f_indirect);
  80090e:	83 ec 0c             	sub    $0xc,%esp
  800911:	50                   	push   %eax
  800912:	e8 77 fa ff ff       	call   80038e <diskaddr>
			*ppdiskbno =  &indirect[filebno - NDIRECT];
  800917:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  80091b:	89 06                	mov    %eax,(%esi)
			//*ppdiskbno = (uint32_t*)diskaddr(f->f_indirect) + filebno - NDIRECT;
			uint32_t *indirect = (uint32_t*)diskaddr(f->f_indirect);
			*ppdiskbno =  &indirect[filebno - NDIRECT];
		}

		else if (!f->f_indirect && alloc) {
  80091d:	83 c4 10             	add    $0x10,%esp
		} else {
			return -E_NOT_FOUND;
		}
	}	
	
	return 0;
  800920:	b8 00 00 00 00       	mov    $0x0,%eax
			//*ppdiskbno = (uint32_t*)diskaddr(f->f_indirect) + filebno - NDIRECT;
			uint32_t *indirect = (uint32_t*)diskaddr(f->f_indirect);
			*ppdiskbno =  &indirect[filebno - NDIRECT];
		}

		else if (!f->f_indirect && alloc) {
  800925:	eb 1e                	jmp    800945 <file_block_walk+0x8e>
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
       	// LAB 5: Your code here.

	if (filebno >= (NDIRECT + NINDIRECT)) {
		return -E_INVAL;
  800927:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80092c:	eb 17                	jmp    800945 <file_block_walk+0x8e>
			f->f_indirect = blockno; 
			uint32_t *indirect = (uint32_t*)diskaddr(f->f_indirect);
			*ppdiskbno =  &indirect[filebno - NDIRECT];

		} else {
			return -E_NOT_FOUND;
  80092e:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800933:	eb 10                	jmp    800945 <file_block_walk+0x8e>
  800935:	89 d3                	mov    %edx,%ebx
  800937:	89 c7                	mov    %eax,%edi
	if (filebno < NDIRECT) {
		*ppdiskbno = &f->f_direct[filebno];
	}	

	if (filebno >= NDIRECT) {
		if (f->f_indirect) {
  800939:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
  80093f:	85 c0                	test   %eax,%eax
  800941:	74 b8                	je     8008fb <file_block_walk+0x44>
  800943:	eb 9d                	jmp    8008e2 <file_block_walk+0x2b>
		}
	}	
	
	return 0;
       	//panic("file_block_walk not implemented");
}
  800945:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800948:	5b                   	pop    %ebx
  800949:	5e                   	pop    %esi
  80094a:	5f                   	pop    %edi
  80094b:	5d                   	pop    %ebp
  80094c:	c3                   	ret    

0080094d <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	56                   	push   %esi
  800951:	53                   	push   %ebx
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800952:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800957:	8b 70 04             	mov    0x4(%eax),%esi
  80095a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80095f:	eb 29                	jmp    80098a <check_bitmap+0x3d>
		assert(!block_is_free(2+i));
  800961:	8d 43 02             	lea    0x2(%ebx),%eax
  800964:	50                   	push   %eax
  800965:	e8 62 fe ff ff       	call   8007cc <block_is_free>
  80096a:	83 c4 04             	add    $0x4,%esp
  80096d:	84 c0                	test   %al,%al
  80096f:	74 16                	je     800987 <check_bitmap+0x3a>
  800971:	68 b4 3a 80 00       	push   $0x803ab4
  800976:	68 bd 38 80 00       	push   $0x8038bd
  80097b:	6a 61                	push   $0x61
  80097d:	68 64 3a 80 00       	push   $0x803a64
  800982:	e8 44 11 00 00       	call   801acb <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800987:	83 c3 01             	add    $0x1,%ebx
  80098a:	89 d8                	mov    %ebx,%eax
  80098c:	c1 e0 0f             	shl    $0xf,%eax
  80098f:	39 f0                	cmp    %esi,%eax
  800991:	72 ce                	jb     800961 <check_bitmap+0x14>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  800993:	83 ec 0c             	sub    $0xc,%esp
  800996:	6a 00                	push   $0x0
  800998:	e8 2f fe ff ff       	call   8007cc <block_is_free>
  80099d:	83 c4 10             	add    $0x10,%esp
  8009a0:	84 c0                	test   %al,%al
  8009a2:	74 16                	je     8009ba <check_bitmap+0x6d>
  8009a4:	68 c8 3a 80 00       	push   $0x803ac8
  8009a9:	68 bd 38 80 00       	push   $0x8038bd
  8009ae:	6a 64                	push   $0x64
  8009b0:	68 64 3a 80 00       	push   $0x803a64
  8009b5:	e8 11 11 00 00       	call   801acb <_panic>
	assert(!block_is_free(1));
  8009ba:	83 ec 0c             	sub    $0xc,%esp
  8009bd:	6a 01                	push   $0x1
  8009bf:	e8 08 fe ff ff       	call   8007cc <block_is_free>
  8009c4:	83 c4 10             	add    $0x10,%esp
  8009c7:	84 c0                	test   %al,%al
  8009c9:	74 16                	je     8009e1 <check_bitmap+0x94>
  8009cb:	68 da 3a 80 00       	push   $0x803ada
  8009d0:	68 bd 38 80 00       	push   $0x8038bd
  8009d5:	6a 65                	push   $0x65
  8009d7:	68 64 3a 80 00       	push   $0x803a64
  8009dc:	e8 ea 10 00 00       	call   801acb <_panic>

	cprintf("bitmap is good\n");
  8009e1:	83 ec 0c             	sub    $0xc,%esp
  8009e4:	68 ec 3a 80 00       	push   $0x803aec
  8009e9:	e8 b6 11 00 00       	call   801ba4 <cprintf>
}
  8009ee:	83 c4 10             	add    $0x10,%esp
  8009f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009f4:	5b                   	pop    %ebx
  8009f5:	5e                   	pop    %esi
  8009f6:	5d                   	pop    %ebp
  8009f7:	c3                   	ret    

008009f8 <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	83 ec 08             	sub    $0x8,%esp
	static_assert(sizeof(struct File) == 256);

	// Find a JOS disk.  Use the second IDE disk (number 1) if available
	if (ide_probe_disk1())
  8009fe:	e8 5c f6 ff ff       	call   80005f <ide_probe_disk1>
  800a03:	84 c0                	test   %al,%al
  800a05:	74 0f                	je     800a16 <fs_init+0x1e>
		ide_set_disk(1);
  800a07:	83 ec 0c             	sub    $0xc,%esp
  800a0a:	6a 01                	push   $0x1
  800a0c:	e8 b2 f6 ff ff       	call   8000c3 <ide_set_disk>
  800a11:	83 c4 10             	add    $0x10,%esp
  800a14:	eb 0d                	jmp    800a23 <fs_init+0x2b>
	else
		ide_set_disk(0);
  800a16:	83 ec 0c             	sub    $0xc,%esp
  800a19:	6a 00                	push   $0x0
  800a1b:	e8 a3 f6 ff ff       	call   8000c3 <ide_set_disk>
  800a20:	83 c4 10             	add    $0x10,%esp
	bc_init();
  800a23:	e8 74 fa ff ff       	call   80049c <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  800a28:	83 ec 0c             	sub    $0xc,%esp
  800a2b:	6a 01                	push   $0x1
  800a2d:	e8 5c f9 ff ff       	call   80038e <diskaddr>
  800a32:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_super();
  800a37:	e8 3a fd ff ff       	call   800776 <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  800a3c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800a43:	e8 46 f9 ff ff       	call   80038e <diskaddr>
  800a48:	a3 04 a0 80 00       	mov    %eax,0x80a004
	check_bitmap();
  800a4d:	e8 fb fe ff ff       	call   80094d <check_bitmap>
	
}
  800a52:	83 c4 10             	add    $0x10,%esp
  800a55:	c9                   	leave  
  800a56:	c3                   	ret    

00800a57 <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	83 ec 24             	sub    $0x24,%esp
       	// LAB 5: Your code here.
	int r;
	uint32_t *block = NULL;
  800a5d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	r = file_block_walk(f, filebno, &block, true);
  800a64:	6a 01                	push   $0x1
  800a66:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800a69:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6f:	e8 43 fe ff ff       	call   8008b7 <file_block_walk>
	if (r < 0) {
  800a74:	83 c4 10             	add    $0x10,%esp
  800a77:	85 c0                	test   %eax,%eax
  800a79:	78 45                	js     800ac0 <file_get_block+0x69>
		return r;
	} 
	if (*block == 0) {
  800a7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a7e:	83 38 00             	cmpl   $0x0,(%eax)
  800a81:	75 23                	jne    800aa6 <file_get_block+0x4f>
		r = alloc_block();
  800a83:	e8 bd fd ff ff       	call   800845 <alloc_block>
		if (r < 0) {
  800a88:	85 c0                	test   %eax,%eax
  800a8a:	79 15                	jns    800aa1 <file_get_block+0x4a>
			panic("alloc block failed %e", r);
  800a8c:	50                   	push   %eax
  800a8d:	68 fc 3a 80 00       	push   $0x803afc
  800a92:	68 d4 00 00 00       	push   $0xd4
  800a97:	68 64 3a 80 00       	push   $0x803a64
  800a9c:	e8 2a 10 00 00       	call   801acb <_panic>
		}
		*block = r;
  800aa1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800aa4:	89 02                	mov    %eax,(%edx)
	}
	*blk = diskaddr(*block);
  800aa6:	83 ec 0c             	sub    $0xc,%esp
  800aa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800aac:	ff 30                	pushl  (%eax)
  800aae:	e8 db f8 ff ff       	call   80038e <diskaddr>
  800ab3:	8b 55 10             	mov    0x10(%ebp),%edx
  800ab6:	89 02                	mov    %eax,(%edx)

	return 0;
  800ab8:	83 c4 10             	add    $0x10,%esp
  800abb:	b8 00 00 00 00       	mov    $0x0,%eax
       	//panic("file_get_block not implemented");
}
  800ac0:	c9                   	leave  
  800ac1:	c3                   	ret    

00800ac2 <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	57                   	push   %edi
  800ac6:	56                   	push   %esi
  800ac7:	53                   	push   %ebx
  800ac8:	81 ec bc 00 00 00    	sub    $0xbc,%esp
  800ace:	89 95 40 ff ff ff    	mov    %edx,-0xc0(%ebp)
  800ad4:	89 8d 3c ff ff ff    	mov    %ecx,-0xc4(%ebp)
  800ada:	eb 03                	jmp    800adf <walk_path+0x1d>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800adc:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800adf:	80 38 2f             	cmpb   $0x2f,(%eax)
  800ae2:	74 f8                	je     800adc <walk_path+0x1a>
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  800ae4:	8b 0d 08 a0 80 00    	mov    0x80a008,%ecx
  800aea:	83 c1 08             	add    $0x8,%ecx
  800aed:	89 8d 4c ff ff ff    	mov    %ecx,-0xb4(%ebp)
	dir = 0;
	name[0] = 0;
  800af3:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800afa:	8b 8d 40 ff ff ff    	mov    -0xc0(%ebp),%ecx
  800b00:	85 c9                	test   %ecx,%ecx
  800b02:	74 06                	je     800b0a <walk_path+0x48>
		*pdir = 0;
  800b04:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	*pf = 0;
  800b0a:	8b 8d 3c ff ff ff    	mov    -0xc4(%ebp),%ecx
  800b10:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
	dir = 0;
  800b16:	ba 00 00 00 00       	mov    $0x0,%edx
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800b1b:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800b21:	e9 5f 01 00 00       	jmp    800c85 <walk_path+0x1c3>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800b26:	83 c7 01             	add    $0x1,%edi
  800b29:	eb 02                	jmp    800b2d <walk_path+0x6b>
  800b2b:	89 c7                	mov    %eax,%edi
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800b2d:	0f b6 17             	movzbl (%edi),%edx
  800b30:	80 fa 2f             	cmp    $0x2f,%dl
  800b33:	74 04                	je     800b39 <walk_path+0x77>
  800b35:	84 d2                	test   %dl,%dl
  800b37:	75 ed                	jne    800b26 <walk_path+0x64>
			path++;
		if (path - p >= MAXNAMELEN)
  800b39:	89 fb                	mov    %edi,%ebx
  800b3b:	29 c3                	sub    %eax,%ebx
  800b3d:	83 fb 7f             	cmp    $0x7f,%ebx
  800b40:	0f 8f 69 01 00 00    	jg     800caf <walk_path+0x1ed>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800b46:	83 ec 04             	sub    $0x4,%esp
  800b49:	53                   	push   %ebx
  800b4a:	50                   	push   %eax
  800b4b:	56                   	push   %esi
  800b4c:	e8 6a 17 00 00       	call   8022bb <memmove>
		name[path - p] = '\0';
  800b51:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800b58:	00 
  800b59:	83 c4 10             	add    $0x10,%esp
  800b5c:	eb 03                	jmp    800b61 <walk_path+0x9f>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800b5e:	83 c7 01             	add    $0x1,%edi

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800b61:	80 3f 2f             	cmpb   $0x2f,(%edi)
  800b64:	74 f8                	je     800b5e <walk_path+0x9c>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
  800b66:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800b6c:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800b73:	0f 85 3d 01 00 00    	jne    800cb6 <walk_path+0x1f4>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800b79:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800b7f:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800b84:	74 19                	je     800b9f <walk_path+0xdd>
  800b86:	68 12 3b 80 00       	push   $0x803b12
  800b8b:	68 bd 38 80 00       	push   $0x8038bd
  800b90:	68 ed 00 00 00       	push   $0xed
  800b95:	68 64 3a 80 00       	push   $0x803a64
  800b9a:	e8 2c 0f 00 00       	call   801acb <_panic>
	nblock = dir->f_size / BLKSIZE;
  800b9f:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800ba5:	85 c0                	test   %eax,%eax
  800ba7:	0f 48 c2             	cmovs  %edx,%eax
  800baa:	c1 f8 0c             	sar    $0xc,%eax
  800bad:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
	for (i = 0; i < nblock; i++) {
  800bb3:	c7 85 50 ff ff ff 00 	movl   $0x0,-0xb0(%ebp)
  800bba:	00 00 00 
  800bbd:	89 bd 44 ff ff ff    	mov    %edi,-0xbc(%ebp)
  800bc3:	eb 5e                	jmp    800c23 <walk_path+0x161>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800bc5:	83 ec 04             	sub    $0x4,%esp
  800bc8:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800bce:	50                   	push   %eax
  800bcf:	ff b5 50 ff ff ff    	pushl  -0xb0(%ebp)
  800bd5:	ff b5 4c ff ff ff    	pushl  -0xb4(%ebp)
  800bdb:	e8 77 fe ff ff       	call   800a57 <file_get_block>
  800be0:	83 c4 10             	add    $0x10,%esp
  800be3:	85 c0                	test   %eax,%eax
  800be5:	0f 88 ee 00 00 00    	js     800cd9 <walk_path+0x217>
			return r;
		f = (struct File*) blk;
  800beb:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  800bf1:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800bf7:	89 9d 54 ff ff ff    	mov    %ebx,-0xac(%ebp)
  800bfd:	83 ec 08             	sub    $0x8,%esp
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
  800c02:	e8 cc 15 00 00       	call   8021d3 <strcmp>
  800c07:	83 c4 10             	add    $0x10,%esp
  800c0a:	85 c0                	test   %eax,%eax
  800c0c:	0f 84 ab 00 00 00    	je     800cbd <walk_path+0x1fb>
  800c12:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800c18:	39 fb                	cmp    %edi,%ebx
  800c1a:	75 db                	jne    800bf7 <walk_path+0x135>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800c1c:	83 85 50 ff ff ff 01 	addl   $0x1,-0xb0(%ebp)
  800c23:	8b 8d 50 ff ff ff    	mov    -0xb0(%ebp),%ecx
  800c29:	39 8d 48 ff ff ff    	cmp    %ecx,-0xb8(%ebp)
  800c2f:	75 94                	jne    800bc5 <walk_path+0x103>
  800c31:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800c37:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800c3c:	80 3f 00             	cmpb   $0x0,(%edi)
  800c3f:	0f 85 a3 00 00 00    	jne    800ce8 <walk_path+0x226>
				if (pdir)
  800c45:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800c4b:	85 c0                	test   %eax,%eax
  800c4d:	74 08                	je     800c57 <walk_path+0x195>
					*pdir = dir;
  800c4f:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800c55:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  800c57:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800c5b:	74 15                	je     800c72 <walk_path+0x1b0>
					strcpy(lastelem, name);
  800c5d:	83 ec 08             	sub    $0x8,%esp
  800c60:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800c66:	50                   	push   %eax
  800c67:	ff 75 08             	pushl  0x8(%ebp)
  800c6a:	e8 ba 14 00 00       	call   802129 <strcpy>
  800c6f:	83 c4 10             	add    $0x10,%esp
				*pf = 0;
  800c72:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800c78:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  800c7e:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800c83:	eb 63                	jmp    800ce8 <walk_path+0x226>
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800c85:	80 38 00             	cmpb   $0x0,(%eax)
  800c88:	0f 85 9d fe ff ff    	jne    800b2b <walk_path+0x69>
			}
			return r;
		}
	}

	if (pdir)
  800c8e:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800c94:	85 c0                	test   %eax,%eax
  800c96:	74 02                	je     800c9a <walk_path+0x1d8>
		*pdir = dir;
  800c98:	89 10                	mov    %edx,(%eax)
	*pf = f;
  800c9a:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800ca0:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800ca6:	89 08                	mov    %ecx,(%eax)
	return 0;
  800ca8:	b8 00 00 00 00       	mov    $0x0,%eax
  800cad:	eb 39                	jmp    800ce8 <walk_path+0x226>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  800caf:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800cb4:	eb 32                	jmp    800ce8 <walk_path+0x226>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  800cb6:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800cbb:	eb 2b                	jmp    800ce8 <walk_path+0x226>
  800cbd:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
  800cc3:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800cc9:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800ccf:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
  800cd5:	89 f8                	mov    %edi,%eax
  800cd7:	eb ac                	jmp    800c85 <walk_path+0x1c3>
  800cd9:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800cdf:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800ce2:	0f 84 4f ff ff ff    	je     800c37 <walk_path+0x175>

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}
  800ce8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ceb:	5b                   	pop    %ebx
  800cec:	5e                   	pop    %esi
  800ced:	5f                   	pop    %edi
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    

00800cf0 <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	83 ec 14             	sub    $0x14,%esp
	return walk_path(path, 0, pf, 0);
  800cf6:	6a 00                	push   $0x0
  800cf8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfb:	ba 00 00 00 00       	mov    $0x0,%edx
  800d00:	8b 45 08             	mov    0x8(%ebp),%eax
  800d03:	e8 ba fd ff ff       	call   800ac2 <walk_path>
}
  800d08:	c9                   	leave  
  800d09:	c3                   	ret    

00800d0a <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	57                   	push   %edi
  800d0e:	56                   	push   %esi
  800d0f:	53                   	push   %ebx
  800d10:	83 ec 2c             	sub    $0x2c,%esp
  800d13:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d16:	8b 4d 14             	mov    0x14(%ebp),%ecx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800d19:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1c:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
		return 0;
  800d22:	b8 00 00 00 00       	mov    $0x0,%eax
{
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800d27:	39 ca                	cmp    %ecx,%edx
  800d29:	7e 7c                	jle    800da7 <file_read+0x9d>
		return 0;

	count = MIN(count, f->f_size - offset);
  800d2b:	29 ca                	sub    %ecx,%edx
  800d2d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d30:	0f 47 55 10          	cmova  0x10(%ebp),%edx
  800d34:	89 55 d0             	mov    %edx,-0x30(%ebp)

	for (pos = offset; pos < offset + count; ) {
  800d37:	89 ce                	mov    %ecx,%esi
  800d39:	01 d1                	add    %edx,%ecx
  800d3b:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800d3e:	eb 5d                	jmp    800d9d <file_read+0x93>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800d40:	83 ec 04             	sub    $0x4,%esp
  800d43:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800d46:	50                   	push   %eax
  800d47:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800d4d:	85 f6                	test   %esi,%esi
  800d4f:	0f 49 c6             	cmovns %esi,%eax
  800d52:	c1 f8 0c             	sar    $0xc,%eax
  800d55:	50                   	push   %eax
  800d56:	ff 75 08             	pushl  0x8(%ebp)
  800d59:	e8 f9 fc ff ff       	call   800a57 <file_get_block>
  800d5e:	83 c4 10             	add    $0x10,%esp
  800d61:	85 c0                	test   %eax,%eax
  800d63:	78 42                	js     800da7 <file_read+0x9d>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800d65:	89 f2                	mov    %esi,%edx
  800d67:	c1 fa 1f             	sar    $0x1f,%edx
  800d6a:	c1 ea 14             	shr    $0x14,%edx
  800d6d:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800d70:	25 ff 0f 00 00       	and    $0xfff,%eax
  800d75:	29 d0                	sub    %edx,%eax
  800d77:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800d7a:	29 da                	sub    %ebx,%edx
  800d7c:	bb 00 10 00 00       	mov    $0x1000,%ebx
  800d81:	29 c3                	sub    %eax,%ebx
  800d83:	39 da                	cmp    %ebx,%edx
  800d85:	0f 46 da             	cmovbe %edx,%ebx
		memmove(buf, blk + pos % BLKSIZE, bn);
  800d88:	83 ec 04             	sub    $0x4,%esp
  800d8b:	53                   	push   %ebx
  800d8c:	03 45 e4             	add    -0x1c(%ebp),%eax
  800d8f:	50                   	push   %eax
  800d90:	57                   	push   %edi
  800d91:	e8 25 15 00 00       	call   8022bb <memmove>
		pos += bn;
  800d96:	01 de                	add    %ebx,%esi
		buf += bn;
  800d98:	01 df                	add    %ebx,%edi
  800d9a:	83 c4 10             	add    $0x10,%esp
	if (offset >= f->f_size)
		return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  800d9d:	89 f3                	mov    %esi,%ebx
  800d9f:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800da2:	77 9c                	ja     800d40 <file_read+0x36>
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800da4:	8b 45 d0             	mov    -0x30(%ebp),%eax
}
  800da7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800daa:	5b                   	pop    %ebx
  800dab:	5e                   	pop    %esi
  800dac:	5f                   	pop    %edi
  800dad:	5d                   	pop    %ebp
  800dae:	c3                   	ret    

00800daf <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	57                   	push   %edi
  800db3:	56                   	push   %esi
  800db4:	53                   	push   %ebx
  800db5:	83 ec 2c             	sub    $0x2c,%esp
  800db8:	8b 75 08             	mov    0x8(%ebp),%esi
	if (f->f_size > newsize)
  800dbb:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800dc1:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800dc4:	0f 8e a7 00 00 00    	jle    800e71 <file_set_size+0xc2>
file_truncate_blocks(struct File *f, off_t newsize)
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800dca:	8d b8 fe 1f 00 00    	lea    0x1ffe(%eax),%edi
  800dd0:	05 ff 0f 00 00       	add    $0xfff,%eax
  800dd5:	0f 49 f8             	cmovns %eax,%edi
  800dd8:	c1 ff 0c             	sar    $0xc,%edi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800ddb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dde:	05 fe 1f 00 00       	add    $0x1ffe,%eax
  800de3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800de6:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800dec:	0f 49 c2             	cmovns %edx,%eax
  800def:	c1 f8 0c             	sar    $0xc,%eax
  800df2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800df5:	89 c3                	mov    %eax,%ebx
  800df7:	eb 39                	jmp    800e32 <file_set_size+0x83>
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800df9:	83 ec 0c             	sub    $0xc,%esp
  800dfc:	6a 00                	push   $0x0
  800dfe:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800e01:	89 da                	mov    %ebx,%edx
  800e03:	89 f0                	mov    %esi,%eax
  800e05:	e8 ad fa ff ff       	call   8008b7 <file_block_walk>
  800e0a:	83 c4 10             	add    $0x10,%esp
  800e0d:	85 c0                	test   %eax,%eax
  800e0f:	78 4d                	js     800e5e <file_set_size+0xaf>
		return r;
	if (*ptr) {
  800e11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e14:	8b 00                	mov    (%eax),%eax
  800e16:	85 c0                	test   %eax,%eax
  800e18:	74 15                	je     800e2f <file_set_size+0x80>
		free_block(*ptr);
  800e1a:	83 ec 0c             	sub    $0xc,%esp
  800e1d:	50                   	push   %eax
  800e1e:	e8 e6 f9 ff ff       	call   800809 <free_block>
		*ptr = 0;
  800e23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e26:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800e2c:	83 c4 10             	add    $0x10,%esp
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800e2f:	83 c3 01             	add    $0x1,%ebx
  800e32:	39 df                	cmp    %ebx,%edi
  800e34:	77 c3                	ja     800df9 <file_set_size+0x4a>
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800e36:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  800e3a:	77 35                	ja     800e71 <file_set_size+0xc2>
  800e3c:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800e42:	85 c0                	test   %eax,%eax
  800e44:	74 2b                	je     800e71 <file_set_size+0xc2>
		free_block(f->f_indirect);
  800e46:	83 ec 0c             	sub    $0xc,%esp
  800e49:	50                   	push   %eax
  800e4a:	e8 ba f9 ff ff       	call   800809 <free_block>
		f->f_indirect = 0;
  800e4f:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  800e56:	00 00 00 
  800e59:	83 c4 10             	add    $0x10,%esp
  800e5c:	eb 13                	jmp    800e71 <file_set_size+0xc2>

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);
  800e5e:	83 ec 08             	sub    $0x8,%esp
  800e61:	50                   	push   %eax
  800e62:	68 2f 3b 80 00       	push   $0x803b2f
  800e67:	e8 38 0d 00 00       	call   801ba4 <cprintf>
  800e6c:	83 c4 10             	add    $0x10,%esp
  800e6f:	eb be                	jmp    800e2f <file_set_size+0x80>
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  800e71:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e74:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	flush_block(f);
  800e7a:	83 ec 0c             	sub    $0xc,%esp
  800e7d:	56                   	push   %esi
  800e7e:	e8 89 f5 ff ff       	call   80040c <flush_block>
	return 0;
}
  800e83:	b8 00 00 00 00       	mov    $0x0,%eax
  800e88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e8b:	5b                   	pop    %ebx
  800e8c:	5e                   	pop    %esi
  800e8d:	5f                   	pop    %edi
  800e8e:	5d                   	pop    %ebp
  800e8f:	c3                   	ret    

00800e90 <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	57                   	push   %edi
  800e94:	56                   	push   %esi
  800e95:	53                   	push   %ebx
  800e96:	83 ec 2c             	sub    $0x2c,%esp
  800e99:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e9c:	8b 75 14             	mov    0x14(%ebp),%esi
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  800e9f:	89 f0                	mov    %esi,%eax
  800ea1:	03 45 10             	add    0x10(%ebp),%eax
  800ea4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800ea7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eaa:	3b 81 80 00 00 00    	cmp    0x80(%ecx),%eax
  800eb0:	76 72                	jbe    800f24 <file_write+0x94>
		if ((r = file_set_size(f, offset + count)) < 0)
  800eb2:	83 ec 08             	sub    $0x8,%esp
  800eb5:	50                   	push   %eax
  800eb6:	51                   	push   %ecx
  800eb7:	e8 f3 fe ff ff       	call   800daf <file_set_size>
  800ebc:	83 c4 10             	add    $0x10,%esp
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	79 61                	jns    800f24 <file_write+0x94>
  800ec3:	eb 69                	jmp    800f2e <file_write+0x9e>
			return r;

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800ec5:	83 ec 04             	sub    $0x4,%esp
  800ec8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ecb:	50                   	push   %eax
  800ecc:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800ed2:	85 f6                	test   %esi,%esi
  800ed4:	0f 49 c6             	cmovns %esi,%eax
  800ed7:	c1 f8 0c             	sar    $0xc,%eax
  800eda:	50                   	push   %eax
  800edb:	ff 75 08             	pushl  0x8(%ebp)
  800ede:	e8 74 fb ff ff       	call   800a57 <file_get_block>
  800ee3:	83 c4 10             	add    $0x10,%esp
  800ee6:	85 c0                	test   %eax,%eax
  800ee8:	78 44                	js     800f2e <file_write+0x9e>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800eea:	89 f2                	mov    %esi,%edx
  800eec:	c1 fa 1f             	sar    $0x1f,%edx
  800eef:	c1 ea 14             	shr    $0x14,%edx
  800ef2:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800ef5:	25 ff 0f 00 00       	and    $0xfff,%eax
  800efa:	29 d0                	sub    %edx,%eax
  800efc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800eff:	29 d9                	sub    %ebx,%ecx
  800f01:	89 cb                	mov    %ecx,%ebx
  800f03:	ba 00 10 00 00       	mov    $0x1000,%edx
  800f08:	29 c2                	sub    %eax,%edx
  800f0a:	39 d1                	cmp    %edx,%ecx
  800f0c:	0f 47 da             	cmova  %edx,%ebx
		memmove(blk + pos % BLKSIZE, buf, bn);
  800f0f:	83 ec 04             	sub    $0x4,%esp
  800f12:	53                   	push   %ebx
  800f13:	57                   	push   %edi
  800f14:	03 45 e4             	add    -0x1c(%ebp),%eax
  800f17:	50                   	push   %eax
  800f18:	e8 9e 13 00 00       	call   8022bb <memmove>
		pos += bn;
  800f1d:	01 de                	add    %ebx,%esi
		buf += bn;
  800f1f:	01 df                	add    %ebx,%edi
  800f21:	83 c4 10             	add    $0x10,%esp
	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  800f24:	89 f3                	mov    %esi,%ebx
  800f26:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800f29:	77 9a                	ja     800ec5 <file_write+0x35>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800f2b:	8b 45 10             	mov    0x10(%ebp),%eax
}
  800f2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f31:	5b                   	pop    %ebx
  800f32:	5e                   	pop    %esi
  800f33:	5f                   	pop    %edi
  800f34:	5d                   	pop    %ebp
  800f35:	c3                   	ret    

00800f36 <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800f36:	55                   	push   %ebp
  800f37:	89 e5                	mov    %esp,%ebp
  800f39:	56                   	push   %esi
  800f3a:	53                   	push   %ebx
  800f3b:	83 ec 10             	sub    $0x10,%esp
  800f3e:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800f41:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f46:	eb 3c                	jmp    800f84 <file_flush+0x4e>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800f48:	83 ec 0c             	sub    $0xc,%esp
  800f4b:	6a 00                	push   $0x0
  800f4d:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800f50:	89 da                	mov    %ebx,%edx
  800f52:	89 f0                	mov    %esi,%eax
  800f54:	e8 5e f9 ff ff       	call   8008b7 <file_block_walk>
  800f59:	83 c4 10             	add    $0x10,%esp
  800f5c:	85 c0                	test   %eax,%eax
  800f5e:	78 21                	js     800f81 <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  800f60:	8b 45 f4             	mov    -0xc(%ebp),%eax
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800f63:	85 c0                	test   %eax,%eax
  800f65:	74 1a                	je     800f81 <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  800f67:	8b 00                	mov    (%eax),%eax
  800f69:	85 c0                	test   %eax,%eax
  800f6b:	74 14                	je     800f81 <file_flush+0x4b>
			continue;
		flush_block(diskaddr(*pdiskbno));
  800f6d:	83 ec 0c             	sub    $0xc,%esp
  800f70:	50                   	push   %eax
  800f71:	e8 18 f4 ff ff       	call   80038e <diskaddr>
  800f76:	89 04 24             	mov    %eax,(%esp)
  800f79:	e8 8e f4 ff ff       	call   80040c <flush_block>
  800f7e:	83 c4 10             	add    $0x10,%esp
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800f81:	83 c3 01             	add    $0x1,%ebx
  800f84:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  800f8a:	8d 8a ff 0f 00 00    	lea    0xfff(%edx),%ecx
  800f90:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  800f96:	85 c9                	test   %ecx,%ecx
  800f98:	0f 49 c1             	cmovns %ecx,%eax
  800f9b:	c1 f8 0c             	sar    $0xc,%eax
  800f9e:	39 c3                	cmp    %eax,%ebx
  800fa0:	7c a6                	jl     800f48 <file_flush+0x12>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  800fa2:	83 ec 0c             	sub    $0xc,%esp
  800fa5:	56                   	push   %esi
  800fa6:	e8 61 f4 ff ff       	call   80040c <flush_block>
	if (f->f_indirect)
  800fab:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800fb1:	83 c4 10             	add    $0x10,%esp
  800fb4:	85 c0                	test   %eax,%eax
  800fb6:	74 14                	je     800fcc <file_flush+0x96>
		flush_block(diskaddr(f->f_indirect));
  800fb8:	83 ec 0c             	sub    $0xc,%esp
  800fbb:	50                   	push   %eax
  800fbc:	e8 cd f3 ff ff       	call   80038e <diskaddr>
  800fc1:	89 04 24             	mov    %eax,(%esp)
  800fc4:	e8 43 f4 ff ff       	call   80040c <flush_block>
  800fc9:	83 c4 10             	add    $0x10,%esp
}
  800fcc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fcf:	5b                   	pop    %ebx
  800fd0:	5e                   	pop    %esi
  800fd1:	5d                   	pop    %ebp
  800fd2:	c3                   	ret    

00800fd3 <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	57                   	push   %edi
  800fd7:	56                   	push   %esi
  800fd8:	53                   	push   %ebx
  800fd9:	81 ec b8 00 00 00    	sub    $0xb8,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  800fdf:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800fe5:	50                   	push   %eax
  800fe6:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  800fec:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  800ff2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff5:	e8 c8 fa ff ff       	call   800ac2 <walk_path>
  800ffa:	83 c4 10             	add    $0x10,%esp
  800ffd:	85 c0                	test   %eax,%eax
  800fff:	0f 84 d1 00 00 00    	je     8010d6 <file_create+0x103>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  801005:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801008:	0f 85 0c 01 00 00    	jne    80111a <file_create+0x147>
  80100e:	8b b5 64 ff ff ff    	mov    -0x9c(%ebp),%esi
  801014:	85 f6                	test   %esi,%esi
  801016:	0f 84 c1 00 00 00    	je     8010dd <file_create+0x10a>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  80101c:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  801022:	a9 ff 0f 00 00       	test   $0xfff,%eax
  801027:	74 19                	je     801042 <file_create+0x6f>
  801029:	68 12 3b 80 00       	push   $0x803b12
  80102e:	68 bd 38 80 00       	push   $0x8038bd
  801033:	68 06 01 00 00       	push   $0x106
  801038:	68 64 3a 80 00       	push   $0x803a64
  80103d:	e8 89 0a 00 00       	call   801acb <_panic>
	nblock = dir->f_size / BLKSIZE;
  801042:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  801048:	85 c0                	test   %eax,%eax
  80104a:	0f 48 c2             	cmovs  %edx,%eax
  80104d:	c1 f8 0c             	sar    $0xc,%eax
  801050:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  801056:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((r = file_get_block(dir, i, &blk)) < 0)
  80105b:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  801061:	eb 3b                	jmp    80109e <file_create+0xcb>
  801063:	83 ec 04             	sub    $0x4,%esp
  801066:	57                   	push   %edi
  801067:	53                   	push   %ebx
  801068:	56                   	push   %esi
  801069:	e8 e9 f9 ff ff       	call   800a57 <file_get_block>
  80106e:	83 c4 10             	add    $0x10,%esp
  801071:	85 c0                	test   %eax,%eax
  801073:	0f 88 a1 00 00 00    	js     80111a <file_create+0x147>
			return r;
		f = (struct File*) blk;
  801079:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  80107f:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
		for (j = 0; j < BLKFILES; j++)
			if (f[j].f_name[0] == '\0') {
  801085:	80 38 00             	cmpb   $0x0,(%eax)
  801088:	75 08                	jne    801092 <file_create+0xbf>
				*file = &f[j];
  80108a:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  801090:	eb 52                	jmp    8010e4 <file_create+0x111>
  801092:	05 00 01 00 00       	add    $0x100,%eax
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  801097:	39 d0                	cmp    %edx,%eax
  801099:	75 ea                	jne    801085 <file_create+0xb2>
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  80109b:	83 c3 01             	add    $0x1,%ebx
  80109e:	39 9d 54 ff ff ff    	cmp    %ebx,-0xac(%ebp)
  8010a4:	75 bd                	jne    801063 <file_create+0x90>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  8010a6:	81 86 80 00 00 00 00 	addl   $0x1000,0x80(%esi)
  8010ad:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  8010b0:	83 ec 04             	sub    $0x4,%esp
  8010b3:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  8010b9:	50                   	push   %eax
  8010ba:	53                   	push   %ebx
  8010bb:	56                   	push   %esi
  8010bc:	e8 96 f9 ff ff       	call   800a57 <file_get_block>
  8010c1:	83 c4 10             	add    $0x10,%esp
  8010c4:	85 c0                	test   %eax,%eax
  8010c6:	78 52                	js     80111a <file_create+0x147>
		return r;
	f = (struct File*) blk;
	*file = &f[0];
  8010c8:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  8010ce:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  8010d4:	eb 0e                	jmp    8010e4 <file_create+0x111>
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
  8010d6:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  8010db:	eb 3d                	jmp    80111a <file_create+0x147>
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
  8010dd:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  8010e2:	eb 36                	jmp    80111a <file_create+0x147>
	if ((r = dir_alloc_file(dir, &f)) < 0)
		return r;

	strcpy(f->f_name, name);
  8010e4:	83 ec 08             	sub    $0x8,%esp
  8010e7:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  8010ed:	50                   	push   %eax
  8010ee:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
  8010f4:	e8 30 10 00 00       	call   802129 <strcpy>
	*pf = f;
  8010f9:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  8010ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801102:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  801104:	83 c4 04             	add    $0x4,%esp
  801107:	ff b5 64 ff ff ff    	pushl  -0x9c(%ebp)
  80110d:	e8 24 fe ff ff       	call   800f36 <file_flush>
	return 0;
  801112:	83 c4 10             	add    $0x10,%esp
  801115:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80111a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80111d:	5b                   	pop    %ebx
  80111e:	5e                   	pop    %esi
  80111f:	5f                   	pop    %edi
  801120:	5d                   	pop    %ebp
  801121:	c3                   	ret    

00801122 <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  801122:	55                   	push   %ebp
  801123:	89 e5                	mov    %esp,%ebp
  801125:	53                   	push   %ebx
  801126:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  801129:	bb 01 00 00 00       	mov    $0x1,%ebx
  80112e:	eb 17                	jmp    801147 <fs_sync+0x25>
		flush_block(diskaddr(i));
  801130:	83 ec 0c             	sub    $0xc,%esp
  801133:	53                   	push   %ebx
  801134:	e8 55 f2 ff ff       	call   80038e <diskaddr>
  801139:	89 04 24             	mov    %eax,(%esp)
  80113c:	e8 cb f2 ff ff       	call   80040c <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  801141:	83 c3 01             	add    $0x1,%ebx
  801144:	83 c4 10             	add    $0x10,%esp
  801147:	a1 08 a0 80 00       	mov    0x80a008,%eax
  80114c:	39 58 04             	cmp    %ebx,0x4(%eax)
  80114f:	77 df                	ja     801130 <fs_sync+0xe>
		flush_block(diskaddr(i));
}
  801151:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801154:	c9                   	leave  
  801155:	c3                   	ret    

00801156 <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  801156:	55                   	push   %ebp
  801157:	89 e5                	mov    %esp,%ebp
  801159:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  80115c:	e8 c1 ff ff ff       	call   801122 <fs_sync>
	return 0;
}
  801161:	b8 00 00 00 00       	mov    $0x0,%eax
  801166:	c9                   	leave  
  801167:	c3                   	ret    

00801168 <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
  80116b:	ba 60 50 80 00       	mov    $0x805060,%edx
	int i;
	uintptr_t va = FILEVA;
  801170:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  801175:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  80117a:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  80117c:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  80117f:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  801185:	83 c0 01             	add    $0x1,%eax
  801188:	83 c2 10             	add    $0x10,%edx
  80118b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801190:	75 e8                	jne    80117a <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  801192:	5d                   	pop    %ebp
  801193:	c3                   	ret    

00801194 <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
  801197:	56                   	push   %esi
  801198:	53                   	push   %ebx
  801199:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  80119c:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (pageref(opentab[i].o_fd)) {
  8011a1:	83 ec 0c             	sub    $0xc,%esp
  8011a4:	89 d8                	mov    %ebx,%eax
  8011a6:	c1 e0 04             	shl    $0x4,%eax
  8011a9:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  8011af:	e8 10 1f 00 00       	call   8030c4 <pageref>
  8011b4:	83 c4 10             	add    $0x10,%esp
  8011b7:	85 c0                	test   %eax,%eax
  8011b9:	74 07                	je     8011c2 <openfile_alloc+0x2e>
  8011bb:	83 f8 01             	cmp    $0x1,%eax
  8011be:	74 20                	je     8011e0 <openfile_alloc+0x4c>
  8011c0:	eb 51                	jmp    801213 <openfile_alloc+0x7f>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  8011c2:	83 ec 04             	sub    $0x4,%esp
  8011c5:	6a 07                	push   $0x7
  8011c7:	89 d8                	mov    %ebx,%eax
  8011c9:	c1 e0 04             	shl    $0x4,%eax
  8011cc:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  8011d2:	6a 00                	push   $0x0
  8011d4:	e8 53 13 00 00       	call   80252c <sys_page_alloc>
  8011d9:	83 c4 10             	add    $0x10,%esp
  8011dc:	85 c0                	test   %eax,%eax
  8011de:	78 43                	js     801223 <openfile_alloc+0x8f>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  8011e0:	c1 e3 04             	shl    $0x4,%ebx
  8011e3:	8d 83 60 50 80 00    	lea    0x805060(%ebx),%eax
  8011e9:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  8011f0:	04 00 00 
			*o = &opentab[i];
  8011f3:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  8011f5:	83 ec 04             	sub    $0x4,%esp
  8011f8:	68 00 10 00 00       	push   $0x1000
  8011fd:	6a 00                	push   $0x0
  8011ff:	ff b3 6c 50 80 00    	pushl  0x80506c(%ebx)
  801205:	e8 64 10 00 00       	call   80226e <memset>
			return (*o)->o_fileid;
  80120a:	8b 06                	mov    (%esi),%eax
  80120c:	8b 00                	mov    (%eax),%eax
  80120e:	83 c4 10             	add    $0x10,%esp
  801211:	eb 10                	jmp    801223 <openfile_alloc+0x8f>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  801213:	83 c3 01             	add    $0x1,%ebx
  801216:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  80121c:	75 83                	jne    8011a1 <openfile_alloc+0xd>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  80121e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801223:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801226:	5b                   	pop    %ebx
  801227:	5e                   	pop    %esi
  801228:	5d                   	pop    %ebp
  801229:	c3                   	ret    

0080122a <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  80122a:	55                   	push   %ebp
  80122b:	89 e5                	mov    %esp,%ebp
  80122d:	57                   	push   %edi
  80122e:	56                   	push   %esi
  80122f:	53                   	push   %ebx
  801230:	83 ec 18             	sub    $0x18,%esp
  801233:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  801236:	89 fb                	mov    %edi,%ebx
  801238:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  80123e:	89 de                	mov    %ebx,%esi
  801240:	c1 e6 04             	shl    $0x4,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  801243:	ff b6 6c 50 80 00    	pushl  0x80506c(%esi)
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  801249:	81 c6 60 50 80 00    	add    $0x805060,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  80124f:	e8 70 1e 00 00       	call   8030c4 <pageref>
  801254:	83 c4 10             	add    $0x10,%esp
  801257:	83 f8 01             	cmp    $0x1,%eax
  80125a:	7e 17                	jle    801273 <openfile_lookup+0x49>
  80125c:	c1 e3 04             	shl    $0x4,%ebx
  80125f:	3b bb 60 50 80 00    	cmp    0x805060(%ebx),%edi
  801265:	75 13                	jne    80127a <openfile_lookup+0x50>
		return -E_INVAL;
	*po = o;
  801267:	8b 45 10             	mov    0x10(%ebp),%eax
  80126a:	89 30                	mov    %esi,(%eax)
	return 0;
  80126c:	b8 00 00 00 00       	mov    $0x0,%eax
  801271:	eb 0c                	jmp    80127f <openfile_lookup+0x55>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
		return -E_INVAL;
  801273:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801278:	eb 05                	jmp    80127f <openfile_lookup+0x55>
  80127a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  80127f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801282:	5b                   	pop    %ebx
  801283:	5e                   	pop    %esi
  801284:	5f                   	pop    %edi
  801285:	5d                   	pop    %ebp
  801286:	c3                   	ret    

00801287 <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  801287:	55                   	push   %ebp
  801288:	89 e5                	mov    %esp,%ebp
  80128a:	53                   	push   %ebx
  80128b:	83 ec 18             	sub    $0x18,%esp
  80128e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801291:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801294:	50                   	push   %eax
  801295:	ff 33                	pushl  (%ebx)
  801297:	ff 75 08             	pushl  0x8(%ebp)
  80129a:	e8 8b ff ff ff       	call   80122a <openfile_lookup>
  80129f:	83 c4 10             	add    $0x10,%esp
  8012a2:	85 c0                	test   %eax,%eax
  8012a4:	78 14                	js     8012ba <serve_set_size+0x33>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  8012a6:	83 ec 08             	sub    $0x8,%esp
  8012a9:	ff 73 04             	pushl  0x4(%ebx)
  8012ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012af:	ff 70 04             	pushl  0x4(%eax)
  8012b2:	e8 f8 fa ff ff       	call   800daf <file_set_size>
  8012b7:	83 c4 10             	add    $0x10,%esp
}
  8012ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012bd:	c9                   	leave  
  8012be:	c3                   	ret    

008012bf <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  8012bf:	55                   	push   %ebp
  8012c0:	89 e5                	mov    %esp,%ebp
  8012c2:	53                   	push   %ebx
  8012c3:	83 ec 18             	sub    $0x18,%esp
  8012c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// Lab 5: Your code here:	
	struct OpenFile *openfile;
	int r;
	// find the opened file
	if ((r = openfile_lookup(envid, req->req_fileid, &openfile)) < 0) {
  8012c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012cc:	50                   	push   %eax
  8012cd:	ff 33                	pushl  (%ebx)
  8012cf:	ff 75 08             	pushl  0x8(%ebp)
  8012d2:	e8 53 ff ff ff       	call   80122a <openfile_lookup>
  8012d7:	83 c4 10             	add    $0x10,%esp
		return r;
  8012da:	89 c2                	mov    %eax,%edx

	// Lab 5: Your code here:	
	struct OpenFile *openfile;
	int r;
	// find the opened file
	if ((r = openfile_lookup(envid, req->req_fileid, &openfile)) < 0) {
  8012dc:	85 c0                	test   %eax,%eax
  8012de:	78 39                	js     801319 <serve_read+0x5a>
		return r;
	}
	//read the n bytes from the offset (seek) position to the buffer
	if ((r = file_read(openfile->o_file, ret->ret_buf, 
	  MIN(req->req_n, sizeof(ret->ret_buf)), openfile->o_fd->fd_offset)) < 0) {
  8012e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
	// find the opened file
	if ((r = openfile_lookup(envid, req->req_fileid, &openfile)) < 0) {
		return r;
	}
	//read the n bytes from the offset (seek) position to the buffer
	if ((r = file_read(openfile->o_file, ret->ret_buf, 
  8012e3:	8b 42 0c             	mov    0xc(%edx),%eax
  8012e6:	ff 70 04             	pushl  0x4(%eax)
  8012e9:	81 7b 04 00 10 00 00 	cmpl   $0x1000,0x4(%ebx)
  8012f0:	b8 00 10 00 00       	mov    $0x1000,%eax
  8012f5:	0f 46 43 04          	cmovbe 0x4(%ebx),%eax
  8012f9:	50                   	push   %eax
  8012fa:	53                   	push   %ebx
  8012fb:	ff 72 04             	pushl  0x4(%edx)
  8012fe:	e8 07 fa ff ff       	call   800d0a <file_read>
  801303:	83 c4 10             	add    $0x10,%esp
  801306:	85 c0                	test   %eax,%eax
  801308:	78 0d                	js     801317 <serve_read+0x58>
	  MIN(req->req_n, sizeof(ret->ret_buf)), openfile->o_fd->fd_offset)) < 0) {
		return r;
	}	
	//move the current seek position
  	openfile->o_fd->fd_offset += r;
  80130a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80130d:	8b 52 0c             	mov    0xc(%edx),%edx
  801310:	01 42 04             	add    %eax,0x4(%edx)

	return r;
  801313:	89 c2                	mov    %eax,%edx
  801315:	eb 02                	jmp    801319 <serve_read+0x5a>
		return r;
	}
	//read the n bytes from the offset (seek) position to the buffer
	if ((r = file_read(openfile->o_file, ret->ret_buf, 
	  MIN(req->req_n, sizeof(ret->ret_buf)), openfile->o_fd->fd_offset)) < 0) {
		return r;
  801317:	89 c2                	mov    %eax,%edx
	}	
	//move the current seek position
  	openfile->o_fd->fd_offset += r;

	return r;
}
  801319:	89 d0                	mov    %edx,%eax
  80131b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80131e:	c9                   	leave  
  80131f:	c3                   	ret    

00801320 <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
  801323:	53                   	push   %ebx
  801324:	83 ec 18             	sub    $0x18,%esp
  801327:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// LAB 5: Your code here.
	struct OpenFile *openfile;
	int r;

	if ((r = openfile_lookup(envid, req->req_fileid, &openfile)) < 0) {
  80132a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132d:	50                   	push   %eax
  80132e:	ff 33                	pushl  (%ebx)
  801330:	ff 75 08             	pushl  0x8(%ebp)
  801333:	e8 f2 fe ff ff       	call   80122a <openfile_lookup>
  801338:	83 c4 10             	add    $0x10,%esp
		return r;
  80133b:	89 c2                	mov    %eax,%edx

	// LAB 5: Your code here.
	struct OpenFile *openfile;
	int r;

	if ((r = openfile_lookup(envid, req->req_fileid, &openfile)) < 0) {
  80133d:	85 c0                	test   %eax,%eax
  80133f:	78 2e                	js     80136f <serve_write+0x4f>
		return r;
	}

	if ((r = file_write(openfile->o_file, req->req_buf, req->req_n, 
				openfile->o_fd->fd_offset)) < 0) {
  801341:	8b 45 f4             	mov    -0xc(%ebp),%eax

	if ((r = openfile_lookup(envid, req->req_fileid, &openfile)) < 0) {
		return r;
	}

	if ((r = file_write(openfile->o_file, req->req_buf, req->req_n, 
  801344:	8b 50 0c             	mov    0xc(%eax),%edx
  801347:	ff 72 04             	pushl  0x4(%edx)
  80134a:	ff 73 04             	pushl  0x4(%ebx)
  80134d:	83 c3 08             	add    $0x8,%ebx
  801350:	53                   	push   %ebx
  801351:	ff 70 04             	pushl  0x4(%eax)
  801354:	e8 37 fb ff ff       	call   800e90 <file_write>
  801359:	83 c4 10             	add    $0x10,%esp
  80135c:	85 c0                	test   %eax,%eax
  80135e:	78 0d                	js     80136d <serve_write+0x4d>
				openfile->o_fd->fd_offset)) < 0) {
		return r;
	}
	
	openfile->o_fd->fd_offset += r;
  801360:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801363:	8b 52 0c             	mov    0xc(%edx),%edx
  801366:	01 42 04             	add    %eax,0x4(%edx)
	
	return r;
  801369:	89 c2                	mov    %eax,%edx
  80136b:	eb 02                	jmp    80136f <serve_write+0x4f>
		return r;
	}

	if ((r = file_write(openfile->o_file, req->req_buf, req->req_n, 
				openfile->o_fd->fd_offset)) < 0) {
		return r;
  80136d:	89 c2                	mov    %eax,%edx
	
	openfile->o_fd->fd_offset += r;
	
	return r;
	//panic("serve_write not implemented");
}
  80136f:	89 d0                	mov    %edx,%eax
  801371:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801374:	c9                   	leave  
  801375:	c3                   	ret    

00801376 <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  801376:	55                   	push   %ebp
  801377:	89 e5                	mov    %esp,%ebp
  801379:	53                   	push   %ebx
  80137a:	83 ec 18             	sub    $0x18,%esp
  80137d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801380:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801383:	50                   	push   %eax
  801384:	ff 33                	pushl  (%ebx)
  801386:	ff 75 08             	pushl  0x8(%ebp)
  801389:	e8 9c fe ff ff       	call   80122a <openfile_lookup>
  80138e:	83 c4 10             	add    $0x10,%esp
  801391:	85 c0                	test   %eax,%eax
  801393:	78 3f                	js     8013d4 <serve_stat+0x5e>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  801395:	83 ec 08             	sub    $0x8,%esp
  801398:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80139b:	ff 70 04             	pushl  0x4(%eax)
  80139e:	53                   	push   %ebx
  80139f:	e8 85 0d 00 00       	call   802129 <strcpy>
	ret->ret_size = o->o_file->f_size;
  8013a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013a7:	8b 50 04             	mov    0x4(%eax),%edx
  8013aa:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  8013b0:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  8013b6:	8b 40 04             	mov    0x4(%eax),%eax
  8013b9:	83 c4 10             	add    $0x10,%esp
  8013bc:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  8013c3:	0f 94 c0             	sete   %al
  8013c6:	0f b6 c0             	movzbl %al,%eax
  8013c9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d7:	c9                   	leave  
  8013d8:	c3                   	ret    

008013d9 <serve_flush>:

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  8013d9:	55                   	push   %ebp
  8013da:	89 e5                	mov    %esp,%ebp
  8013dc:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8013df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e2:	50                   	push   %eax
  8013e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013e6:	ff 30                	pushl  (%eax)
  8013e8:	ff 75 08             	pushl  0x8(%ebp)
  8013eb:	e8 3a fe ff ff       	call   80122a <openfile_lookup>
  8013f0:	83 c4 10             	add    $0x10,%esp
  8013f3:	85 c0                	test   %eax,%eax
  8013f5:	78 16                	js     80140d <serve_flush+0x34>
		return r;
	file_flush(o->o_file);
  8013f7:	83 ec 0c             	sub    $0xc,%esp
  8013fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013fd:	ff 70 04             	pushl  0x4(%eax)
  801400:	e8 31 fb ff ff       	call   800f36 <file_flush>
	return 0;
  801405:	83 c4 10             	add    $0x10,%esp
  801408:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80140d:	c9                   	leave  
  80140e:	c3                   	ret    

0080140f <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  80140f:	55                   	push   %ebp
  801410:	89 e5                	mov    %esp,%ebp
  801412:	53                   	push   %ebx
  801413:	81 ec 18 04 00 00    	sub    $0x418,%esp
  801419:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  80141c:	68 00 04 00 00       	push   $0x400
  801421:	53                   	push   %ebx
  801422:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801428:	50                   	push   %eax
  801429:	e8 8d 0e 00 00       	call   8022bb <memmove>
	path[MAXPATHLEN-1] = 0;
  80142e:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  801432:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  801438:	89 04 24             	mov    %eax,(%esp)
  80143b:	e8 54 fd ff ff       	call   801194 <openfile_alloc>
  801440:	83 c4 10             	add    $0x10,%esp
  801443:	85 c0                	test   %eax,%eax
  801445:	0f 88 f0 00 00 00    	js     80153b <serve_open+0x12c>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  80144b:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  801452:	74 33                	je     801487 <serve_open+0x78>
		if ((r = file_create(path, &f)) < 0) {
  801454:	83 ec 08             	sub    $0x8,%esp
  801457:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  80145d:	50                   	push   %eax
  80145e:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801464:	50                   	push   %eax
  801465:	e8 69 fb ff ff       	call   800fd3 <file_create>
  80146a:	83 c4 10             	add    $0x10,%esp
  80146d:	85 c0                	test   %eax,%eax
  80146f:	79 37                	jns    8014a8 <serve_open+0x99>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  801471:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  801478:	0f 85 bd 00 00 00    	jne    80153b <serve_open+0x12c>
  80147e:	83 f8 f3             	cmp    $0xfffffff3,%eax
  801481:	0f 85 b4 00 00 00    	jne    80153b <serve_open+0x12c>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  801487:	83 ec 08             	sub    $0x8,%esp
  80148a:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801490:	50                   	push   %eax
  801491:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801497:	50                   	push   %eax
  801498:	e8 53 f8 ff ff       	call   800cf0 <file_open>
  80149d:	83 c4 10             	add    $0x10,%esp
  8014a0:	85 c0                	test   %eax,%eax
  8014a2:	0f 88 93 00 00 00    	js     80153b <serve_open+0x12c>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  8014a8:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  8014af:	74 17                	je     8014c8 <serve_open+0xb9>
		if ((r = file_set_size(f, 0)) < 0) {
  8014b1:	83 ec 08             	sub    $0x8,%esp
  8014b4:	6a 00                	push   $0x0
  8014b6:	ff b5 f4 fb ff ff    	pushl  -0x40c(%ebp)
  8014bc:	e8 ee f8 ff ff       	call   800daf <file_set_size>
  8014c1:	83 c4 10             	add    $0x10,%esp
  8014c4:	85 c0                	test   %eax,%eax
  8014c6:	78 73                	js     80153b <serve_open+0x12c>
			if (debug)
				cprintf("file_set_size failed: %e", r);
			return r;
		}
	}
	if ((r = file_open(path, &f)) < 0) {
  8014c8:	83 ec 08             	sub    $0x8,%esp
  8014cb:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8014d1:	50                   	push   %eax
  8014d2:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8014d8:	50                   	push   %eax
  8014d9:	e8 12 f8 ff ff       	call   800cf0 <file_open>
  8014de:	83 c4 10             	add    $0x10,%esp
  8014e1:	85 c0                	test   %eax,%eax
  8014e3:	78 56                	js     80153b <serve_open+0x12c>
			cprintf("file_open failed: %e", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;
  8014e5:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8014eb:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  8014f1:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  8014f4:	8b 50 0c             	mov    0xc(%eax),%edx
  8014f7:	8b 08                	mov    (%eax),%ecx
  8014f9:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  8014fc:	8b 48 0c             	mov    0xc(%eax),%ecx
  8014ff:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  801505:	83 e2 03             	and    $0x3,%edx
  801508:	89 51 08             	mov    %edx,0x8(%ecx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  80150b:	8b 40 0c             	mov    0xc(%eax),%eax
  80150e:	8b 15 64 90 80 00    	mov    0x809064,%edx
  801514:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  801516:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  80151c:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  801522:	89 50 08             	mov    %edx,0x8(%eax)
	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  801525:	8b 50 0c             	mov    0xc(%eax),%edx
  801528:	8b 45 10             	mov    0x10(%ebp),%eax
  80152b:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  80152d:	8b 45 14             	mov    0x14(%ebp),%eax
  801530:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  801536:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80153b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153e:	c9                   	leave  
  80153f:	c3                   	ret    

00801540 <serve>:
	[FSREQ_SYNC] =		serve_sync
};

void
serve(void)
{
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
  801543:	56                   	push   %esi
  801544:	53                   	push   %ebx
  801545:	83 ec 10             	sub    $0x10,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801548:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  80154b:	8d 75 f4             	lea    -0xc(%ebp),%esi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  80154e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801555:	83 ec 04             	sub    $0x4,%esp
  801558:	53                   	push   %ebx
  801559:	ff 35 44 50 80 00    	pushl  0x805044
  80155f:	56                   	push   %esi
  801560:	e8 47 12 00 00       	call   8027ac <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  801565:	83 c4 10             	add    $0x10,%esp
  801568:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  80156c:	75 15                	jne    801583 <serve+0x43>
			cprintf("Invalid request from %08x: no argument page\n",
  80156e:	83 ec 08             	sub    $0x8,%esp
  801571:	ff 75 f4             	pushl  -0xc(%ebp)
  801574:	68 4c 3b 80 00       	push   $0x803b4c
  801579:	e8 26 06 00 00       	call   801ba4 <cprintf>
				whom);
			continue; // just leave it hanging...
  80157e:	83 c4 10             	add    $0x10,%esp
  801581:	eb cb                	jmp    80154e <serve+0xe>
		}

		pg = NULL;
  801583:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  80158a:	83 f8 01             	cmp    $0x1,%eax
  80158d:	75 18                	jne    8015a7 <serve+0x67>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  80158f:	53                   	push   %ebx
  801590:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801593:	50                   	push   %eax
  801594:	ff 35 44 50 80 00    	pushl  0x805044
  80159a:	ff 75 f4             	pushl  -0xc(%ebp)
  80159d:	e8 6d fe ff ff       	call   80140f <serve_open>
  8015a2:	83 c4 10             	add    $0x10,%esp
  8015a5:	eb 3c                	jmp    8015e3 <serve+0xa3>
		} else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
  8015a7:	83 f8 08             	cmp    $0x8,%eax
  8015aa:	77 1e                	ja     8015ca <serve+0x8a>
  8015ac:	8b 14 85 20 50 80 00 	mov    0x805020(,%eax,4),%edx
  8015b3:	85 d2                	test   %edx,%edx
  8015b5:	74 13                	je     8015ca <serve+0x8a>
			r = handlers[req](whom, fsreq);
  8015b7:	83 ec 08             	sub    $0x8,%esp
  8015ba:	ff 35 44 50 80 00    	pushl  0x805044
  8015c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8015c3:	ff d2                	call   *%edx
  8015c5:	83 c4 10             	add    $0x10,%esp
  8015c8:	eb 19                	jmp    8015e3 <serve+0xa3>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  8015ca:	83 ec 04             	sub    $0x4,%esp
  8015cd:	ff 75 f4             	pushl  -0xc(%ebp)
  8015d0:	50                   	push   %eax
  8015d1:	68 7c 3b 80 00       	push   $0x803b7c
  8015d6:	e8 c9 05 00 00       	call   801ba4 <cprintf>
  8015db:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  8015de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  8015e3:	ff 75 f0             	pushl  -0x10(%ebp)
  8015e6:	ff 75 ec             	pushl  -0x14(%ebp)
  8015e9:	50                   	push   %eax
  8015ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8015ed:	e8 2c 12 00 00       	call   80281e <ipc_send>
		sys_page_unmap(0, fsreq);
  8015f2:	83 c4 08             	add    $0x8,%esp
  8015f5:	ff 35 44 50 80 00    	pushl  0x805044
  8015fb:	6a 00                	push   $0x0
  8015fd:	e8 af 0f 00 00       	call   8025b1 <sys_page_unmap>
  801602:	83 c4 10             	add    $0x10,%esp
  801605:	e9 44 ff ff ff       	jmp    80154e <serve+0xe>

0080160a <umain>:
	}
}

void
umain(int argc, char **argv)
{
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  801610:	c7 05 60 90 80 00 9f 	movl   $0x803b9f,0x809060
  801617:	3b 80 00 
	cprintf("FS is running\n");
  80161a:	68 a2 3b 80 00       	push   $0x803ba2
  80161f:	e8 80 05 00 00       	call   801ba4 <cprintf>
}

static inline void
outw(int port, uint16_t data)
{
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
  801624:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  801629:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  80162e:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  801630:	c7 04 24 b1 3b 80 00 	movl   $0x803bb1,(%esp)
  801637:	e8 68 05 00 00       	call   801ba4 <cprintf>

	serve_init();
  80163c:	e8 27 fb ff ff       	call   801168 <serve_init>
	fs_init();
  801641:	e8 b2 f3 ff ff       	call   8009f8 <fs_init>
        fs_test();
  801646:	e8 05 00 00 00       	call   801650 <fs_test>
	serve();
  80164b:	e8 f0 fe ff ff       	call   801540 <serve>

00801650 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  801650:	55                   	push   %ebp
  801651:	89 e5                	mov    %esp,%ebp
  801653:	53                   	push   %ebx
  801654:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  801657:	6a 07                	push   $0x7
  801659:	68 00 10 00 00       	push   $0x1000
  80165e:	6a 00                	push   $0x0
  801660:	e8 c7 0e 00 00       	call   80252c <sys_page_alloc>
  801665:	83 c4 10             	add    $0x10,%esp
  801668:	85 c0                	test   %eax,%eax
  80166a:	79 12                	jns    80167e <fs_test+0x2e>
		panic("sys_page_alloc: %e", r);
  80166c:	50                   	push   %eax
  80166d:	68 c0 3b 80 00       	push   $0x803bc0
  801672:	6a 12                	push   $0x12
  801674:	68 d3 3b 80 00       	push   $0x803bd3
  801679:	e8 4d 04 00 00       	call   801acb <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  80167e:	83 ec 04             	sub    $0x4,%esp
  801681:	68 00 10 00 00       	push   $0x1000
  801686:	ff 35 04 a0 80 00    	pushl  0x80a004
  80168c:	68 00 10 00 00       	push   $0x1000
  801691:	e8 25 0c 00 00       	call   8022bb <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  801696:	e8 aa f1 ff ff       	call   800845 <alloc_block>
  80169b:	83 c4 10             	add    $0x10,%esp
  80169e:	85 c0                	test   %eax,%eax
  8016a0:	79 12                	jns    8016b4 <fs_test+0x64>
		panic("alloc_block: %e", r);
  8016a2:	50                   	push   %eax
  8016a3:	68 dd 3b 80 00       	push   $0x803bdd
  8016a8:	6a 17                	push   $0x17
  8016aa:	68 d3 3b 80 00       	push   $0x803bd3
  8016af:	e8 17 04 00 00       	call   801acb <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  8016b4:	8d 50 1f             	lea    0x1f(%eax),%edx
  8016b7:	85 c0                	test   %eax,%eax
  8016b9:	0f 49 d0             	cmovns %eax,%edx
  8016bc:	c1 fa 05             	sar    $0x5,%edx
  8016bf:	89 c3                	mov    %eax,%ebx
  8016c1:	c1 fb 1f             	sar    $0x1f,%ebx
  8016c4:	c1 eb 1b             	shr    $0x1b,%ebx
  8016c7:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  8016ca:	83 e1 1f             	and    $0x1f,%ecx
  8016cd:	29 d9                	sub    %ebx,%ecx
  8016cf:	b8 01 00 00 00       	mov    $0x1,%eax
  8016d4:	d3 e0                	shl    %cl,%eax
  8016d6:	85 04 95 00 10 00 00 	test   %eax,0x1000(,%edx,4)
  8016dd:	75 16                	jne    8016f5 <fs_test+0xa5>
  8016df:	68 ed 3b 80 00       	push   $0x803bed
  8016e4:	68 bd 38 80 00       	push   $0x8038bd
  8016e9:	6a 19                	push   $0x19
  8016eb:	68 d3 3b 80 00       	push   $0x803bd3
  8016f0:	e8 d6 03 00 00       	call   801acb <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  8016f5:	8b 0d 04 a0 80 00    	mov    0x80a004,%ecx
  8016fb:	85 04 91             	test   %eax,(%ecx,%edx,4)
  8016fe:	74 16                	je     801716 <fs_test+0xc6>
  801700:	68 68 3d 80 00       	push   $0x803d68
  801705:	68 bd 38 80 00       	push   $0x8038bd
  80170a:	6a 1b                	push   $0x1b
  80170c:	68 d3 3b 80 00       	push   $0x803bd3
  801711:	e8 b5 03 00 00       	call   801acb <_panic>
	cprintf("alloc_block is good\n");
  801716:	83 ec 0c             	sub    $0xc,%esp
  801719:	68 08 3c 80 00       	push   $0x803c08
  80171e:	e8 81 04 00 00       	call   801ba4 <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  801723:	83 c4 08             	add    $0x8,%esp
  801726:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801729:	50                   	push   %eax
  80172a:	68 1d 3c 80 00       	push   $0x803c1d
  80172f:	e8 bc f5 ff ff       	call   800cf0 <file_open>
  801734:	83 c4 10             	add    $0x10,%esp
  801737:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80173a:	74 1b                	je     801757 <fs_test+0x107>
  80173c:	89 c2                	mov    %eax,%edx
  80173e:	c1 ea 1f             	shr    $0x1f,%edx
  801741:	84 d2                	test   %dl,%dl
  801743:	74 12                	je     801757 <fs_test+0x107>
		panic("file_open /not-found: %e", r);
  801745:	50                   	push   %eax
  801746:	68 28 3c 80 00       	push   $0x803c28
  80174b:	6a 1f                	push   $0x1f
  80174d:	68 d3 3b 80 00       	push   $0x803bd3
  801752:	e8 74 03 00 00       	call   801acb <_panic>
	else if (r == 0)
  801757:	85 c0                	test   %eax,%eax
  801759:	75 14                	jne    80176f <fs_test+0x11f>
		panic("file_open /not-found succeeded!");
  80175b:	83 ec 04             	sub    $0x4,%esp
  80175e:	68 88 3d 80 00       	push   $0x803d88
  801763:	6a 21                	push   $0x21
  801765:	68 d3 3b 80 00       	push   $0x803bd3
  80176a:	e8 5c 03 00 00       	call   801acb <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  80176f:	83 ec 08             	sub    $0x8,%esp
  801772:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801775:	50                   	push   %eax
  801776:	68 41 3c 80 00       	push   $0x803c41
  80177b:	e8 70 f5 ff ff       	call   800cf0 <file_open>
  801780:	83 c4 10             	add    $0x10,%esp
  801783:	85 c0                	test   %eax,%eax
  801785:	79 12                	jns    801799 <fs_test+0x149>
		panic("file_open /newmotd: %e", r);
  801787:	50                   	push   %eax
  801788:	68 4a 3c 80 00       	push   $0x803c4a
  80178d:	6a 23                	push   $0x23
  80178f:	68 d3 3b 80 00       	push   $0x803bd3
  801794:	e8 32 03 00 00       	call   801acb <_panic>
	cprintf("file_open is good\n");
  801799:	83 ec 0c             	sub    $0xc,%esp
  80179c:	68 61 3c 80 00       	push   $0x803c61
  8017a1:	e8 fe 03 00 00       	call   801ba4 <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  8017a6:	83 c4 0c             	add    $0xc,%esp
  8017a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017ac:	50                   	push   %eax
  8017ad:	6a 00                	push   $0x0
  8017af:	ff 75 f4             	pushl  -0xc(%ebp)
  8017b2:	e8 a0 f2 ff ff       	call   800a57 <file_get_block>
  8017b7:	83 c4 10             	add    $0x10,%esp
  8017ba:	85 c0                	test   %eax,%eax
  8017bc:	79 12                	jns    8017d0 <fs_test+0x180>
		panic("file_get_block: %e", r);
  8017be:	50                   	push   %eax
  8017bf:	68 74 3c 80 00       	push   $0x803c74
  8017c4:	6a 27                	push   $0x27
  8017c6:	68 d3 3b 80 00       	push   $0x803bd3
  8017cb:	e8 fb 02 00 00       	call   801acb <_panic>
	if (strcmp(blk, msg) != 0)
  8017d0:	83 ec 08             	sub    $0x8,%esp
  8017d3:	68 a8 3d 80 00       	push   $0x803da8
  8017d8:	ff 75 f0             	pushl  -0x10(%ebp)
  8017db:	e8 f3 09 00 00       	call   8021d3 <strcmp>
  8017e0:	83 c4 10             	add    $0x10,%esp
  8017e3:	85 c0                	test   %eax,%eax
  8017e5:	74 14                	je     8017fb <fs_test+0x1ab>
		panic("file_get_block returned wrong data");
  8017e7:	83 ec 04             	sub    $0x4,%esp
  8017ea:	68 d0 3d 80 00       	push   $0x803dd0
  8017ef:	6a 29                	push   $0x29
  8017f1:	68 d3 3b 80 00       	push   $0x803bd3
  8017f6:	e8 d0 02 00 00       	call   801acb <_panic>
	cprintf("file_get_block is good\n");
  8017fb:	83 ec 0c             	sub    $0xc,%esp
  8017fe:	68 87 3c 80 00       	push   $0x803c87
  801803:	e8 9c 03 00 00       	call   801ba4 <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  801808:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80180b:	0f b6 10             	movzbl (%eax),%edx
  80180e:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801810:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801813:	c1 e8 0c             	shr    $0xc,%eax
  801816:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80181d:	83 c4 10             	add    $0x10,%esp
  801820:	a8 40                	test   $0x40,%al
  801822:	75 16                	jne    80183a <fs_test+0x1ea>
  801824:	68 a0 3c 80 00       	push   $0x803ca0
  801829:	68 bd 38 80 00       	push   $0x8038bd
  80182e:	6a 2d                	push   $0x2d
  801830:	68 d3 3b 80 00       	push   $0x803bd3
  801835:	e8 91 02 00 00       	call   801acb <_panic>
	file_flush(f);
  80183a:	83 ec 0c             	sub    $0xc,%esp
  80183d:	ff 75 f4             	pushl  -0xc(%ebp)
  801840:	e8 f1 f6 ff ff       	call   800f36 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801845:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801848:	c1 e8 0c             	shr    $0xc,%eax
  80184b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801852:	83 c4 10             	add    $0x10,%esp
  801855:	a8 40                	test   $0x40,%al
  801857:	74 16                	je     80186f <fs_test+0x21f>
  801859:	68 9f 3c 80 00       	push   $0x803c9f
  80185e:	68 bd 38 80 00       	push   $0x8038bd
  801863:	6a 2f                	push   $0x2f
  801865:	68 d3 3b 80 00       	push   $0x803bd3
  80186a:	e8 5c 02 00 00       	call   801acb <_panic>
	cprintf("file_flush is good\n");
  80186f:	83 ec 0c             	sub    $0xc,%esp
  801872:	68 bb 3c 80 00       	push   $0x803cbb
  801877:	e8 28 03 00 00       	call   801ba4 <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  80187c:	83 c4 08             	add    $0x8,%esp
  80187f:	6a 00                	push   $0x0
  801881:	ff 75 f4             	pushl  -0xc(%ebp)
  801884:	e8 26 f5 ff ff       	call   800daf <file_set_size>
  801889:	83 c4 10             	add    $0x10,%esp
  80188c:	85 c0                	test   %eax,%eax
  80188e:	79 12                	jns    8018a2 <fs_test+0x252>
		panic("file_set_size: %e", r);
  801890:	50                   	push   %eax
  801891:	68 cf 3c 80 00       	push   $0x803ccf
  801896:	6a 33                	push   $0x33
  801898:	68 d3 3b 80 00       	push   $0x803bd3
  80189d:	e8 29 02 00 00       	call   801acb <_panic>
	assert(f->f_direct[0] == 0);
  8018a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a5:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  8018ac:	74 16                	je     8018c4 <fs_test+0x274>
  8018ae:	68 e1 3c 80 00       	push   $0x803ce1
  8018b3:	68 bd 38 80 00       	push   $0x8038bd
  8018b8:	6a 34                	push   $0x34
  8018ba:	68 d3 3b 80 00       	push   $0x803bd3
  8018bf:	e8 07 02 00 00       	call   801acb <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8018c4:	c1 e8 0c             	shr    $0xc,%eax
  8018c7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018ce:	a8 40                	test   $0x40,%al
  8018d0:	74 16                	je     8018e8 <fs_test+0x298>
  8018d2:	68 f5 3c 80 00       	push   $0x803cf5
  8018d7:	68 bd 38 80 00       	push   $0x8038bd
  8018dc:	6a 35                	push   $0x35
  8018de:	68 d3 3b 80 00       	push   $0x803bd3
  8018e3:	e8 e3 01 00 00       	call   801acb <_panic>
	cprintf("file_truncate is good\n");
  8018e8:	83 ec 0c             	sub    $0xc,%esp
  8018eb:	68 0f 3d 80 00       	push   $0x803d0f
  8018f0:	e8 af 02 00 00       	call   801ba4 <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  8018f5:	c7 04 24 a8 3d 80 00 	movl   $0x803da8,(%esp)
  8018fc:	e8 ef 07 00 00       	call   8020f0 <strlen>
  801901:	83 c4 08             	add    $0x8,%esp
  801904:	50                   	push   %eax
  801905:	ff 75 f4             	pushl  -0xc(%ebp)
  801908:	e8 a2 f4 ff ff       	call   800daf <file_set_size>
  80190d:	83 c4 10             	add    $0x10,%esp
  801910:	85 c0                	test   %eax,%eax
  801912:	79 12                	jns    801926 <fs_test+0x2d6>
		panic("file_set_size 2: %e", r);
  801914:	50                   	push   %eax
  801915:	68 26 3d 80 00       	push   $0x803d26
  80191a:	6a 39                	push   $0x39
  80191c:	68 d3 3b 80 00       	push   $0x803bd3
  801921:	e8 a5 01 00 00       	call   801acb <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801926:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801929:	89 c2                	mov    %eax,%edx
  80192b:	c1 ea 0c             	shr    $0xc,%edx
  80192e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801935:	f6 c2 40             	test   $0x40,%dl
  801938:	74 16                	je     801950 <fs_test+0x300>
  80193a:	68 f5 3c 80 00       	push   $0x803cf5
  80193f:	68 bd 38 80 00       	push   $0x8038bd
  801944:	6a 3a                	push   $0x3a
  801946:	68 d3 3b 80 00       	push   $0x803bd3
  80194b:	e8 7b 01 00 00       	call   801acb <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801950:	83 ec 04             	sub    $0x4,%esp
  801953:	8d 55 f0             	lea    -0x10(%ebp),%edx
  801956:	52                   	push   %edx
  801957:	6a 00                	push   $0x0
  801959:	50                   	push   %eax
  80195a:	e8 f8 f0 ff ff       	call   800a57 <file_get_block>
  80195f:	83 c4 10             	add    $0x10,%esp
  801962:	85 c0                	test   %eax,%eax
  801964:	79 12                	jns    801978 <fs_test+0x328>
		panic("file_get_block 2: %e", r);
  801966:	50                   	push   %eax
  801967:	68 3a 3d 80 00       	push   $0x803d3a
  80196c:	6a 3c                	push   $0x3c
  80196e:	68 d3 3b 80 00       	push   $0x803bd3
  801973:	e8 53 01 00 00       	call   801acb <_panic>
	strcpy(blk, msg);
  801978:	83 ec 08             	sub    $0x8,%esp
  80197b:	68 a8 3d 80 00       	push   $0x803da8
  801980:	ff 75 f0             	pushl  -0x10(%ebp)
  801983:	e8 a1 07 00 00       	call   802129 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801988:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80198b:	c1 e8 0c             	shr    $0xc,%eax
  80198e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801995:	83 c4 10             	add    $0x10,%esp
  801998:	a8 40                	test   $0x40,%al
  80199a:	75 16                	jne    8019b2 <fs_test+0x362>
  80199c:	68 a0 3c 80 00       	push   $0x803ca0
  8019a1:	68 bd 38 80 00       	push   $0x8038bd
  8019a6:	6a 3e                	push   $0x3e
  8019a8:	68 d3 3b 80 00       	push   $0x803bd3
  8019ad:	e8 19 01 00 00       	call   801acb <_panic>
	file_flush(f);
  8019b2:	83 ec 0c             	sub    $0xc,%esp
  8019b5:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b8:	e8 79 f5 ff ff       	call   800f36 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8019bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019c0:	c1 e8 0c             	shr    $0xc,%eax
  8019c3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019ca:	83 c4 10             	add    $0x10,%esp
  8019cd:	a8 40                	test   $0x40,%al
  8019cf:	74 16                	je     8019e7 <fs_test+0x397>
  8019d1:	68 9f 3c 80 00       	push   $0x803c9f
  8019d6:	68 bd 38 80 00       	push   $0x8038bd
  8019db:	6a 40                	push   $0x40
  8019dd:	68 d3 3b 80 00       	push   $0x803bd3
  8019e2:	e8 e4 00 00 00       	call   801acb <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8019e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ea:	c1 e8 0c             	shr    $0xc,%eax
  8019ed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019f4:	a8 40                	test   $0x40,%al
  8019f6:	74 16                	je     801a0e <fs_test+0x3be>
  8019f8:	68 f5 3c 80 00       	push   $0x803cf5
  8019fd:	68 bd 38 80 00       	push   $0x8038bd
  801a02:	6a 41                	push   $0x41
  801a04:	68 d3 3b 80 00       	push   $0x803bd3
  801a09:	e8 bd 00 00 00       	call   801acb <_panic>
	cprintf("file rewrite is good\n");
  801a0e:	83 ec 0c             	sub    $0xc,%esp
  801a11:	68 4f 3d 80 00       	push   $0x803d4f
  801a16:	e8 89 01 00 00       	call   801ba4 <cprintf>
}
  801a1b:	83 c4 10             	add    $0x10,%esp
  801a1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a21:	c9                   	leave  
  801a22:	c3                   	ret    

00801a23 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801a23:	55                   	push   %ebp
  801a24:	89 e5                	mov    %esp,%ebp
  801a26:	57                   	push   %edi
  801a27:	56                   	push   %esi
  801a28:	53                   	push   %ebx
  801a29:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  801a2c:	c7 05 0c a0 80 00 00 	movl   $0x0,0x80a00c
  801a33:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  801a36:	e8 b3 0a 00 00       	call   8024ee <sys_getenvid>
  801a3b:	8b 3d 0c a0 80 00    	mov    0x80a00c,%edi
  801a41:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801a46:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  801a4b:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  801a50:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  801a53:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  801a59:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  801a5c:	39 c8                	cmp    %ecx,%eax
  801a5e:	0f 44 fb             	cmove  %ebx,%edi
  801a61:	b9 01 00 00 00       	mov    $0x1,%ecx
  801a66:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  801a69:	83 c2 01             	add    $0x1,%edx
  801a6c:	83 c3 7c             	add    $0x7c,%ebx
  801a6f:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  801a75:	75 d9                	jne    801a50 <libmain+0x2d>
  801a77:	89 f0                	mov    %esi,%eax
  801a79:	84 c0                	test   %al,%al
  801a7b:	74 06                	je     801a83 <libmain+0x60>
  801a7d:	89 3d 0c a0 80 00    	mov    %edi,0x80a00c
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801a83:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  801a87:	7e 0a                	jle    801a93 <libmain+0x70>
		binaryname = argv[0];
  801a89:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a8c:	8b 00                	mov    (%eax),%eax
  801a8e:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801a93:	83 ec 08             	sub    $0x8,%esp
  801a96:	ff 75 0c             	pushl  0xc(%ebp)
  801a99:	ff 75 08             	pushl  0x8(%ebp)
  801a9c:	e8 69 fb ff ff       	call   80160a <umain>

	// exit gracefully
	exit();
  801aa1:	e8 0b 00 00 00       	call   801ab1 <exit>
}
  801aa6:	83 c4 10             	add    $0x10,%esp
  801aa9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aac:	5b                   	pop    %ebx
  801aad:	5e                   	pop    %esi
  801aae:	5f                   	pop    %edi
  801aaf:	5d                   	pop    %ebp
  801ab0:	c3                   	ret    

00801ab1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801ab1:	55                   	push   %ebp
  801ab2:	89 e5                	mov    %esp,%ebp
  801ab4:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801ab7:	e8 c8 0f 00 00       	call   802a84 <close_all>
	sys_env_destroy(0);
  801abc:	83 ec 0c             	sub    $0xc,%esp
  801abf:	6a 00                	push   $0x0
  801ac1:	e8 e7 09 00 00       	call   8024ad <sys_env_destroy>
}
  801ac6:	83 c4 10             	add    $0x10,%esp
  801ac9:	c9                   	leave  
  801aca:	c3                   	ret    

00801acb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801acb:	55                   	push   %ebp
  801acc:	89 e5                	mov    %esp,%ebp
  801ace:	56                   	push   %esi
  801acf:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ad0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ad3:	8b 35 60 90 80 00    	mov    0x809060,%esi
  801ad9:	e8 10 0a 00 00       	call   8024ee <sys_getenvid>
  801ade:	83 ec 0c             	sub    $0xc,%esp
  801ae1:	ff 75 0c             	pushl  0xc(%ebp)
  801ae4:	ff 75 08             	pushl  0x8(%ebp)
  801ae7:	56                   	push   %esi
  801ae8:	50                   	push   %eax
  801ae9:	68 00 3e 80 00       	push   $0x803e00
  801aee:	e8 b1 00 00 00       	call   801ba4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801af3:	83 c4 18             	add    $0x18,%esp
  801af6:	53                   	push   %ebx
  801af7:	ff 75 10             	pushl  0x10(%ebp)
  801afa:	e8 54 00 00 00       	call   801b53 <vcprintf>
	cprintf("\n");
  801aff:	c7 04 24 fb 39 80 00 	movl   $0x8039fb,(%esp)
  801b06:	e8 99 00 00 00       	call   801ba4 <cprintf>
  801b0b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b0e:	cc                   	int3   
  801b0f:	eb fd                	jmp    801b0e <_panic+0x43>

00801b11 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801b11:	55                   	push   %ebp
  801b12:	89 e5                	mov    %esp,%ebp
  801b14:	53                   	push   %ebx
  801b15:	83 ec 04             	sub    $0x4,%esp
  801b18:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801b1b:	8b 13                	mov    (%ebx),%edx
  801b1d:	8d 42 01             	lea    0x1(%edx),%eax
  801b20:	89 03                	mov    %eax,(%ebx)
  801b22:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b25:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801b29:	3d ff 00 00 00       	cmp    $0xff,%eax
  801b2e:	75 1a                	jne    801b4a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801b30:	83 ec 08             	sub    $0x8,%esp
  801b33:	68 ff 00 00 00       	push   $0xff
  801b38:	8d 43 08             	lea    0x8(%ebx),%eax
  801b3b:	50                   	push   %eax
  801b3c:	e8 2f 09 00 00       	call   802470 <sys_cputs>
		b->idx = 0;
  801b41:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b47:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801b4a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801b4e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b51:	c9                   	leave  
  801b52:	c3                   	ret    

00801b53 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801b53:	55                   	push   %ebp
  801b54:	89 e5                	mov    %esp,%ebp
  801b56:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801b5c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801b63:	00 00 00 
	b.cnt = 0;
  801b66:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801b6d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801b70:	ff 75 0c             	pushl  0xc(%ebp)
  801b73:	ff 75 08             	pushl  0x8(%ebp)
  801b76:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801b7c:	50                   	push   %eax
  801b7d:	68 11 1b 80 00       	push   $0x801b11
  801b82:	e8 54 01 00 00       	call   801cdb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801b87:	83 c4 08             	add    $0x8,%esp
  801b8a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801b90:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801b96:	50                   	push   %eax
  801b97:	e8 d4 08 00 00       	call   802470 <sys_cputs>

	return b.cnt;
}
  801b9c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801ba2:	c9                   	leave  
  801ba3:	c3                   	ret    

00801ba4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801ba4:	55                   	push   %ebp
  801ba5:	89 e5                	mov    %esp,%ebp
  801ba7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801baa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801bad:	50                   	push   %eax
  801bae:	ff 75 08             	pushl  0x8(%ebp)
  801bb1:	e8 9d ff ff ff       	call   801b53 <vcprintf>
	va_end(ap);

	return cnt;
}
  801bb6:	c9                   	leave  
  801bb7:	c3                   	ret    

00801bb8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801bb8:	55                   	push   %ebp
  801bb9:	89 e5                	mov    %esp,%ebp
  801bbb:	57                   	push   %edi
  801bbc:	56                   	push   %esi
  801bbd:	53                   	push   %ebx
  801bbe:	83 ec 1c             	sub    $0x1c,%esp
  801bc1:	89 c7                	mov    %eax,%edi
  801bc3:	89 d6                	mov    %edx,%esi
  801bc5:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bcb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801bce:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801bd1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801bd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bd9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801bdc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801bdf:	39 d3                	cmp    %edx,%ebx
  801be1:	72 05                	jb     801be8 <printnum+0x30>
  801be3:	39 45 10             	cmp    %eax,0x10(%ebp)
  801be6:	77 45                	ja     801c2d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801be8:	83 ec 0c             	sub    $0xc,%esp
  801beb:	ff 75 18             	pushl  0x18(%ebp)
  801bee:	8b 45 14             	mov    0x14(%ebp),%eax
  801bf1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801bf4:	53                   	push   %ebx
  801bf5:	ff 75 10             	pushl  0x10(%ebp)
  801bf8:	83 ec 08             	sub    $0x8,%esp
  801bfb:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bfe:	ff 75 e0             	pushl  -0x20(%ebp)
  801c01:	ff 75 dc             	pushl  -0x24(%ebp)
  801c04:	ff 75 d8             	pushl  -0x28(%ebp)
  801c07:	e8 d4 19 00 00       	call   8035e0 <__udivdi3>
  801c0c:	83 c4 18             	add    $0x18,%esp
  801c0f:	52                   	push   %edx
  801c10:	50                   	push   %eax
  801c11:	89 f2                	mov    %esi,%edx
  801c13:	89 f8                	mov    %edi,%eax
  801c15:	e8 9e ff ff ff       	call   801bb8 <printnum>
  801c1a:	83 c4 20             	add    $0x20,%esp
  801c1d:	eb 18                	jmp    801c37 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801c1f:	83 ec 08             	sub    $0x8,%esp
  801c22:	56                   	push   %esi
  801c23:	ff 75 18             	pushl  0x18(%ebp)
  801c26:	ff d7                	call   *%edi
  801c28:	83 c4 10             	add    $0x10,%esp
  801c2b:	eb 03                	jmp    801c30 <printnum+0x78>
  801c2d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801c30:	83 eb 01             	sub    $0x1,%ebx
  801c33:	85 db                	test   %ebx,%ebx
  801c35:	7f e8                	jg     801c1f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801c37:	83 ec 08             	sub    $0x8,%esp
  801c3a:	56                   	push   %esi
  801c3b:	83 ec 04             	sub    $0x4,%esp
  801c3e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c41:	ff 75 e0             	pushl  -0x20(%ebp)
  801c44:	ff 75 dc             	pushl  -0x24(%ebp)
  801c47:	ff 75 d8             	pushl  -0x28(%ebp)
  801c4a:	e8 c1 1a 00 00       	call   803710 <__umoddi3>
  801c4f:	83 c4 14             	add    $0x14,%esp
  801c52:	0f be 80 23 3e 80 00 	movsbl 0x803e23(%eax),%eax
  801c59:	50                   	push   %eax
  801c5a:	ff d7                	call   *%edi
}
  801c5c:	83 c4 10             	add    $0x10,%esp
  801c5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c62:	5b                   	pop    %ebx
  801c63:	5e                   	pop    %esi
  801c64:	5f                   	pop    %edi
  801c65:	5d                   	pop    %ebp
  801c66:	c3                   	ret    

00801c67 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801c67:	55                   	push   %ebp
  801c68:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801c6a:	83 fa 01             	cmp    $0x1,%edx
  801c6d:	7e 0e                	jle    801c7d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801c6f:	8b 10                	mov    (%eax),%edx
  801c71:	8d 4a 08             	lea    0x8(%edx),%ecx
  801c74:	89 08                	mov    %ecx,(%eax)
  801c76:	8b 02                	mov    (%edx),%eax
  801c78:	8b 52 04             	mov    0x4(%edx),%edx
  801c7b:	eb 22                	jmp    801c9f <getuint+0x38>
	else if (lflag)
  801c7d:	85 d2                	test   %edx,%edx
  801c7f:	74 10                	je     801c91 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801c81:	8b 10                	mov    (%eax),%edx
  801c83:	8d 4a 04             	lea    0x4(%edx),%ecx
  801c86:	89 08                	mov    %ecx,(%eax)
  801c88:	8b 02                	mov    (%edx),%eax
  801c8a:	ba 00 00 00 00       	mov    $0x0,%edx
  801c8f:	eb 0e                	jmp    801c9f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801c91:	8b 10                	mov    (%eax),%edx
  801c93:	8d 4a 04             	lea    0x4(%edx),%ecx
  801c96:	89 08                	mov    %ecx,(%eax)
  801c98:	8b 02                	mov    (%edx),%eax
  801c9a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801c9f:	5d                   	pop    %ebp
  801ca0:	c3                   	ret    

00801ca1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801ca1:	55                   	push   %ebp
  801ca2:	89 e5                	mov    %esp,%ebp
  801ca4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801ca7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801cab:	8b 10                	mov    (%eax),%edx
  801cad:	3b 50 04             	cmp    0x4(%eax),%edx
  801cb0:	73 0a                	jae    801cbc <sprintputch+0x1b>
		*b->buf++ = ch;
  801cb2:	8d 4a 01             	lea    0x1(%edx),%ecx
  801cb5:	89 08                	mov    %ecx,(%eax)
  801cb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801cba:	88 02                	mov    %al,(%edx)
}
  801cbc:	5d                   	pop    %ebp
  801cbd:	c3                   	ret    

00801cbe <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801cbe:	55                   	push   %ebp
  801cbf:	89 e5                	mov    %esp,%ebp
  801cc1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801cc4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801cc7:	50                   	push   %eax
  801cc8:	ff 75 10             	pushl  0x10(%ebp)
  801ccb:	ff 75 0c             	pushl  0xc(%ebp)
  801cce:	ff 75 08             	pushl  0x8(%ebp)
  801cd1:	e8 05 00 00 00       	call   801cdb <vprintfmt>
	va_end(ap);
}
  801cd6:	83 c4 10             	add    $0x10,%esp
  801cd9:	c9                   	leave  
  801cda:	c3                   	ret    

00801cdb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801cdb:	55                   	push   %ebp
  801cdc:	89 e5                	mov    %esp,%ebp
  801cde:	57                   	push   %edi
  801cdf:	56                   	push   %esi
  801ce0:	53                   	push   %ebx
  801ce1:	83 ec 2c             	sub    $0x2c,%esp
  801ce4:	8b 75 08             	mov    0x8(%ebp),%esi
  801ce7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801cea:	8b 7d 10             	mov    0x10(%ebp),%edi
  801ced:	eb 12                	jmp    801d01 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801cef:	85 c0                	test   %eax,%eax
  801cf1:	0f 84 89 03 00 00    	je     802080 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801cf7:	83 ec 08             	sub    $0x8,%esp
  801cfa:	53                   	push   %ebx
  801cfb:	50                   	push   %eax
  801cfc:	ff d6                	call   *%esi
  801cfe:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801d01:	83 c7 01             	add    $0x1,%edi
  801d04:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801d08:	83 f8 25             	cmp    $0x25,%eax
  801d0b:	75 e2                	jne    801cef <vprintfmt+0x14>
  801d0d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801d11:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801d18:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801d1f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801d26:	ba 00 00 00 00       	mov    $0x0,%edx
  801d2b:	eb 07                	jmp    801d34 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d2d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801d30:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d34:	8d 47 01             	lea    0x1(%edi),%eax
  801d37:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d3a:	0f b6 07             	movzbl (%edi),%eax
  801d3d:	0f b6 c8             	movzbl %al,%ecx
  801d40:	83 e8 23             	sub    $0x23,%eax
  801d43:	3c 55                	cmp    $0x55,%al
  801d45:	0f 87 1a 03 00 00    	ja     802065 <vprintfmt+0x38a>
  801d4b:	0f b6 c0             	movzbl %al,%eax
  801d4e:	ff 24 85 60 3f 80 00 	jmp    *0x803f60(,%eax,4)
  801d55:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801d58:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801d5c:	eb d6                	jmp    801d34 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d5e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d61:	b8 00 00 00 00       	mov    $0x0,%eax
  801d66:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801d69:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801d6c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801d70:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801d73:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801d76:	83 fa 09             	cmp    $0x9,%edx
  801d79:	77 39                	ja     801db4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801d7b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801d7e:	eb e9                	jmp    801d69 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801d80:	8b 45 14             	mov    0x14(%ebp),%eax
  801d83:	8d 48 04             	lea    0x4(%eax),%ecx
  801d86:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801d89:	8b 00                	mov    (%eax),%eax
  801d8b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d8e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801d91:	eb 27                	jmp    801dba <vprintfmt+0xdf>
  801d93:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d96:	85 c0                	test   %eax,%eax
  801d98:	b9 00 00 00 00       	mov    $0x0,%ecx
  801d9d:	0f 49 c8             	cmovns %eax,%ecx
  801da0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801da3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801da6:	eb 8c                	jmp    801d34 <vprintfmt+0x59>
  801da8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801dab:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801db2:	eb 80                	jmp    801d34 <vprintfmt+0x59>
  801db4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801db7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801dba:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801dbe:	0f 89 70 ff ff ff    	jns    801d34 <vprintfmt+0x59>
				width = precision, precision = -1;
  801dc4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801dc7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801dca:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801dd1:	e9 5e ff ff ff       	jmp    801d34 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801dd6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801dd9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801ddc:	e9 53 ff ff ff       	jmp    801d34 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801de1:	8b 45 14             	mov    0x14(%ebp),%eax
  801de4:	8d 50 04             	lea    0x4(%eax),%edx
  801de7:	89 55 14             	mov    %edx,0x14(%ebp)
  801dea:	83 ec 08             	sub    $0x8,%esp
  801ded:	53                   	push   %ebx
  801dee:	ff 30                	pushl  (%eax)
  801df0:	ff d6                	call   *%esi
			break;
  801df2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801df5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801df8:	e9 04 ff ff ff       	jmp    801d01 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801dfd:	8b 45 14             	mov    0x14(%ebp),%eax
  801e00:	8d 50 04             	lea    0x4(%eax),%edx
  801e03:	89 55 14             	mov    %edx,0x14(%ebp)
  801e06:	8b 00                	mov    (%eax),%eax
  801e08:	99                   	cltd   
  801e09:	31 d0                	xor    %edx,%eax
  801e0b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801e0d:	83 f8 0f             	cmp    $0xf,%eax
  801e10:	7f 0b                	jg     801e1d <vprintfmt+0x142>
  801e12:	8b 14 85 c0 40 80 00 	mov    0x8040c0(,%eax,4),%edx
  801e19:	85 d2                	test   %edx,%edx
  801e1b:	75 18                	jne    801e35 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801e1d:	50                   	push   %eax
  801e1e:	68 3b 3e 80 00       	push   $0x803e3b
  801e23:	53                   	push   %ebx
  801e24:	56                   	push   %esi
  801e25:	e8 94 fe ff ff       	call   801cbe <printfmt>
  801e2a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e2d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801e30:	e9 cc fe ff ff       	jmp    801d01 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801e35:	52                   	push   %edx
  801e36:	68 cf 38 80 00       	push   $0x8038cf
  801e3b:	53                   	push   %ebx
  801e3c:	56                   	push   %esi
  801e3d:	e8 7c fe ff ff       	call   801cbe <printfmt>
  801e42:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e45:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e48:	e9 b4 fe ff ff       	jmp    801d01 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801e4d:	8b 45 14             	mov    0x14(%ebp),%eax
  801e50:	8d 50 04             	lea    0x4(%eax),%edx
  801e53:	89 55 14             	mov    %edx,0x14(%ebp)
  801e56:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801e58:	85 ff                	test   %edi,%edi
  801e5a:	b8 34 3e 80 00       	mov    $0x803e34,%eax
  801e5f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801e62:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801e66:	0f 8e 94 00 00 00    	jle    801f00 <vprintfmt+0x225>
  801e6c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801e70:	0f 84 98 00 00 00    	je     801f0e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801e76:	83 ec 08             	sub    $0x8,%esp
  801e79:	ff 75 d0             	pushl  -0x30(%ebp)
  801e7c:	57                   	push   %edi
  801e7d:	e8 86 02 00 00       	call   802108 <strnlen>
  801e82:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801e85:	29 c1                	sub    %eax,%ecx
  801e87:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801e8a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801e8d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801e91:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e94:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801e97:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801e99:	eb 0f                	jmp    801eaa <vprintfmt+0x1cf>
					putch(padc, putdat);
  801e9b:	83 ec 08             	sub    $0x8,%esp
  801e9e:	53                   	push   %ebx
  801e9f:	ff 75 e0             	pushl  -0x20(%ebp)
  801ea2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801ea4:	83 ef 01             	sub    $0x1,%edi
  801ea7:	83 c4 10             	add    $0x10,%esp
  801eaa:	85 ff                	test   %edi,%edi
  801eac:	7f ed                	jg     801e9b <vprintfmt+0x1c0>
  801eae:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801eb1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801eb4:	85 c9                	test   %ecx,%ecx
  801eb6:	b8 00 00 00 00       	mov    $0x0,%eax
  801ebb:	0f 49 c1             	cmovns %ecx,%eax
  801ebe:	29 c1                	sub    %eax,%ecx
  801ec0:	89 75 08             	mov    %esi,0x8(%ebp)
  801ec3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801ec6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801ec9:	89 cb                	mov    %ecx,%ebx
  801ecb:	eb 4d                	jmp    801f1a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801ecd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801ed1:	74 1b                	je     801eee <vprintfmt+0x213>
  801ed3:	0f be c0             	movsbl %al,%eax
  801ed6:	83 e8 20             	sub    $0x20,%eax
  801ed9:	83 f8 5e             	cmp    $0x5e,%eax
  801edc:	76 10                	jbe    801eee <vprintfmt+0x213>
					putch('?', putdat);
  801ede:	83 ec 08             	sub    $0x8,%esp
  801ee1:	ff 75 0c             	pushl  0xc(%ebp)
  801ee4:	6a 3f                	push   $0x3f
  801ee6:	ff 55 08             	call   *0x8(%ebp)
  801ee9:	83 c4 10             	add    $0x10,%esp
  801eec:	eb 0d                	jmp    801efb <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801eee:	83 ec 08             	sub    $0x8,%esp
  801ef1:	ff 75 0c             	pushl  0xc(%ebp)
  801ef4:	52                   	push   %edx
  801ef5:	ff 55 08             	call   *0x8(%ebp)
  801ef8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801efb:	83 eb 01             	sub    $0x1,%ebx
  801efe:	eb 1a                	jmp    801f1a <vprintfmt+0x23f>
  801f00:	89 75 08             	mov    %esi,0x8(%ebp)
  801f03:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801f06:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801f09:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801f0c:	eb 0c                	jmp    801f1a <vprintfmt+0x23f>
  801f0e:	89 75 08             	mov    %esi,0x8(%ebp)
  801f11:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801f14:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801f17:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801f1a:	83 c7 01             	add    $0x1,%edi
  801f1d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801f21:	0f be d0             	movsbl %al,%edx
  801f24:	85 d2                	test   %edx,%edx
  801f26:	74 23                	je     801f4b <vprintfmt+0x270>
  801f28:	85 f6                	test   %esi,%esi
  801f2a:	78 a1                	js     801ecd <vprintfmt+0x1f2>
  801f2c:	83 ee 01             	sub    $0x1,%esi
  801f2f:	79 9c                	jns    801ecd <vprintfmt+0x1f2>
  801f31:	89 df                	mov    %ebx,%edi
  801f33:	8b 75 08             	mov    0x8(%ebp),%esi
  801f36:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801f39:	eb 18                	jmp    801f53 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801f3b:	83 ec 08             	sub    $0x8,%esp
  801f3e:	53                   	push   %ebx
  801f3f:	6a 20                	push   $0x20
  801f41:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801f43:	83 ef 01             	sub    $0x1,%edi
  801f46:	83 c4 10             	add    $0x10,%esp
  801f49:	eb 08                	jmp    801f53 <vprintfmt+0x278>
  801f4b:	89 df                	mov    %ebx,%edi
  801f4d:	8b 75 08             	mov    0x8(%ebp),%esi
  801f50:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801f53:	85 ff                	test   %edi,%edi
  801f55:	7f e4                	jg     801f3b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f57:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801f5a:	e9 a2 fd ff ff       	jmp    801d01 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801f5f:	83 fa 01             	cmp    $0x1,%edx
  801f62:	7e 16                	jle    801f7a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801f64:	8b 45 14             	mov    0x14(%ebp),%eax
  801f67:	8d 50 08             	lea    0x8(%eax),%edx
  801f6a:	89 55 14             	mov    %edx,0x14(%ebp)
  801f6d:	8b 50 04             	mov    0x4(%eax),%edx
  801f70:	8b 00                	mov    (%eax),%eax
  801f72:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f75:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801f78:	eb 32                	jmp    801fac <vprintfmt+0x2d1>
	else if (lflag)
  801f7a:	85 d2                	test   %edx,%edx
  801f7c:	74 18                	je     801f96 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801f7e:	8b 45 14             	mov    0x14(%ebp),%eax
  801f81:	8d 50 04             	lea    0x4(%eax),%edx
  801f84:	89 55 14             	mov    %edx,0x14(%ebp)
  801f87:	8b 00                	mov    (%eax),%eax
  801f89:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f8c:	89 c1                	mov    %eax,%ecx
  801f8e:	c1 f9 1f             	sar    $0x1f,%ecx
  801f91:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801f94:	eb 16                	jmp    801fac <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801f96:	8b 45 14             	mov    0x14(%ebp),%eax
  801f99:	8d 50 04             	lea    0x4(%eax),%edx
  801f9c:	89 55 14             	mov    %edx,0x14(%ebp)
  801f9f:	8b 00                	mov    (%eax),%eax
  801fa1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801fa4:	89 c1                	mov    %eax,%ecx
  801fa6:	c1 f9 1f             	sar    $0x1f,%ecx
  801fa9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801fac:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801faf:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801fb2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801fb7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801fbb:	79 74                	jns    802031 <vprintfmt+0x356>
				putch('-', putdat);
  801fbd:	83 ec 08             	sub    $0x8,%esp
  801fc0:	53                   	push   %ebx
  801fc1:	6a 2d                	push   $0x2d
  801fc3:	ff d6                	call   *%esi
				num = -(long long) num;
  801fc5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801fc8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801fcb:	f7 d8                	neg    %eax
  801fcd:	83 d2 00             	adc    $0x0,%edx
  801fd0:	f7 da                	neg    %edx
  801fd2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801fd5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801fda:	eb 55                	jmp    802031 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801fdc:	8d 45 14             	lea    0x14(%ebp),%eax
  801fdf:	e8 83 fc ff ff       	call   801c67 <getuint>
			base = 10;
  801fe4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801fe9:	eb 46                	jmp    802031 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801feb:	8d 45 14             	lea    0x14(%ebp),%eax
  801fee:	e8 74 fc ff ff       	call   801c67 <getuint>
			base = 8;
  801ff3:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801ff8:	eb 37                	jmp    802031 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801ffa:	83 ec 08             	sub    $0x8,%esp
  801ffd:	53                   	push   %ebx
  801ffe:	6a 30                	push   $0x30
  802000:	ff d6                	call   *%esi
			putch('x', putdat);
  802002:	83 c4 08             	add    $0x8,%esp
  802005:	53                   	push   %ebx
  802006:	6a 78                	push   $0x78
  802008:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80200a:	8b 45 14             	mov    0x14(%ebp),%eax
  80200d:	8d 50 04             	lea    0x4(%eax),%edx
  802010:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  802013:	8b 00                	mov    (%eax),%eax
  802015:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80201a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80201d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  802022:	eb 0d                	jmp    802031 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  802024:	8d 45 14             	lea    0x14(%ebp),%eax
  802027:	e8 3b fc ff ff       	call   801c67 <getuint>
			base = 16;
  80202c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  802031:	83 ec 0c             	sub    $0xc,%esp
  802034:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  802038:	57                   	push   %edi
  802039:	ff 75 e0             	pushl  -0x20(%ebp)
  80203c:	51                   	push   %ecx
  80203d:	52                   	push   %edx
  80203e:	50                   	push   %eax
  80203f:	89 da                	mov    %ebx,%edx
  802041:	89 f0                	mov    %esi,%eax
  802043:	e8 70 fb ff ff       	call   801bb8 <printnum>
			break;
  802048:	83 c4 20             	add    $0x20,%esp
  80204b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80204e:	e9 ae fc ff ff       	jmp    801d01 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  802053:	83 ec 08             	sub    $0x8,%esp
  802056:	53                   	push   %ebx
  802057:	51                   	push   %ecx
  802058:	ff d6                	call   *%esi
			break;
  80205a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80205d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  802060:	e9 9c fc ff ff       	jmp    801d01 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  802065:	83 ec 08             	sub    $0x8,%esp
  802068:	53                   	push   %ebx
  802069:	6a 25                	push   $0x25
  80206b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80206d:	83 c4 10             	add    $0x10,%esp
  802070:	eb 03                	jmp    802075 <vprintfmt+0x39a>
  802072:	83 ef 01             	sub    $0x1,%edi
  802075:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  802079:	75 f7                	jne    802072 <vprintfmt+0x397>
  80207b:	e9 81 fc ff ff       	jmp    801d01 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  802080:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802083:	5b                   	pop    %ebx
  802084:	5e                   	pop    %esi
  802085:	5f                   	pop    %edi
  802086:	5d                   	pop    %ebp
  802087:	c3                   	ret    

00802088 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  802088:	55                   	push   %ebp
  802089:	89 e5                	mov    %esp,%ebp
  80208b:	83 ec 18             	sub    $0x18,%esp
  80208e:	8b 45 08             	mov    0x8(%ebp),%eax
  802091:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  802094:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802097:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80209b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80209e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8020a5:	85 c0                	test   %eax,%eax
  8020a7:	74 26                	je     8020cf <vsnprintf+0x47>
  8020a9:	85 d2                	test   %edx,%edx
  8020ab:	7e 22                	jle    8020cf <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8020ad:	ff 75 14             	pushl  0x14(%ebp)
  8020b0:	ff 75 10             	pushl  0x10(%ebp)
  8020b3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8020b6:	50                   	push   %eax
  8020b7:	68 a1 1c 80 00       	push   $0x801ca1
  8020bc:	e8 1a fc ff ff       	call   801cdb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8020c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8020c4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8020c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ca:	83 c4 10             	add    $0x10,%esp
  8020cd:	eb 05                	jmp    8020d4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8020cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8020d4:	c9                   	leave  
  8020d5:	c3                   	ret    

008020d6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8020d6:	55                   	push   %ebp
  8020d7:	89 e5                	mov    %esp,%ebp
  8020d9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8020dc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8020df:	50                   	push   %eax
  8020e0:	ff 75 10             	pushl  0x10(%ebp)
  8020e3:	ff 75 0c             	pushl  0xc(%ebp)
  8020e6:	ff 75 08             	pushl  0x8(%ebp)
  8020e9:	e8 9a ff ff ff       	call   802088 <vsnprintf>
	va_end(ap);

	return rc;
}
  8020ee:	c9                   	leave  
  8020ef:	c3                   	ret    

008020f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8020f0:	55                   	push   %ebp
  8020f1:	89 e5                	mov    %esp,%ebp
  8020f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8020f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8020fb:	eb 03                	jmp    802100 <strlen+0x10>
		n++;
  8020fd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  802100:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  802104:	75 f7                	jne    8020fd <strlen+0xd>
		n++;
	return n;
}
  802106:	5d                   	pop    %ebp
  802107:	c3                   	ret    

00802108 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  802108:	55                   	push   %ebp
  802109:	89 e5                	mov    %esp,%ebp
  80210b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80210e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802111:	ba 00 00 00 00       	mov    $0x0,%edx
  802116:	eb 03                	jmp    80211b <strnlen+0x13>
		n++;
  802118:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80211b:	39 c2                	cmp    %eax,%edx
  80211d:	74 08                	je     802127 <strnlen+0x1f>
  80211f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  802123:	75 f3                	jne    802118 <strnlen+0x10>
  802125:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  802127:	5d                   	pop    %ebp
  802128:	c3                   	ret    

00802129 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  802129:	55                   	push   %ebp
  80212a:	89 e5                	mov    %esp,%ebp
  80212c:	53                   	push   %ebx
  80212d:	8b 45 08             	mov    0x8(%ebp),%eax
  802130:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  802133:	89 c2                	mov    %eax,%edx
  802135:	83 c2 01             	add    $0x1,%edx
  802138:	83 c1 01             	add    $0x1,%ecx
  80213b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80213f:	88 5a ff             	mov    %bl,-0x1(%edx)
  802142:	84 db                	test   %bl,%bl
  802144:	75 ef                	jne    802135 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  802146:	5b                   	pop    %ebx
  802147:	5d                   	pop    %ebp
  802148:	c3                   	ret    

00802149 <strcat>:

char *
strcat(char *dst, const char *src)
{
  802149:	55                   	push   %ebp
  80214a:	89 e5                	mov    %esp,%ebp
  80214c:	53                   	push   %ebx
  80214d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  802150:	53                   	push   %ebx
  802151:	e8 9a ff ff ff       	call   8020f0 <strlen>
  802156:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  802159:	ff 75 0c             	pushl  0xc(%ebp)
  80215c:	01 d8                	add    %ebx,%eax
  80215e:	50                   	push   %eax
  80215f:	e8 c5 ff ff ff       	call   802129 <strcpy>
	return dst;
}
  802164:	89 d8                	mov    %ebx,%eax
  802166:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802169:	c9                   	leave  
  80216a:	c3                   	ret    

0080216b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80216b:	55                   	push   %ebp
  80216c:	89 e5                	mov    %esp,%ebp
  80216e:	56                   	push   %esi
  80216f:	53                   	push   %ebx
  802170:	8b 75 08             	mov    0x8(%ebp),%esi
  802173:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802176:	89 f3                	mov    %esi,%ebx
  802178:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80217b:	89 f2                	mov    %esi,%edx
  80217d:	eb 0f                	jmp    80218e <strncpy+0x23>
		*dst++ = *src;
  80217f:	83 c2 01             	add    $0x1,%edx
  802182:	0f b6 01             	movzbl (%ecx),%eax
  802185:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  802188:	80 39 01             	cmpb   $0x1,(%ecx)
  80218b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80218e:	39 da                	cmp    %ebx,%edx
  802190:	75 ed                	jne    80217f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  802192:	89 f0                	mov    %esi,%eax
  802194:	5b                   	pop    %ebx
  802195:	5e                   	pop    %esi
  802196:	5d                   	pop    %ebp
  802197:	c3                   	ret    

00802198 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  802198:	55                   	push   %ebp
  802199:	89 e5                	mov    %esp,%ebp
  80219b:	56                   	push   %esi
  80219c:	53                   	push   %ebx
  80219d:	8b 75 08             	mov    0x8(%ebp),%esi
  8021a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021a3:	8b 55 10             	mov    0x10(%ebp),%edx
  8021a6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8021a8:	85 d2                	test   %edx,%edx
  8021aa:	74 21                	je     8021cd <strlcpy+0x35>
  8021ac:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8021b0:	89 f2                	mov    %esi,%edx
  8021b2:	eb 09                	jmp    8021bd <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8021b4:	83 c2 01             	add    $0x1,%edx
  8021b7:	83 c1 01             	add    $0x1,%ecx
  8021ba:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8021bd:	39 c2                	cmp    %eax,%edx
  8021bf:	74 09                	je     8021ca <strlcpy+0x32>
  8021c1:	0f b6 19             	movzbl (%ecx),%ebx
  8021c4:	84 db                	test   %bl,%bl
  8021c6:	75 ec                	jne    8021b4 <strlcpy+0x1c>
  8021c8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8021ca:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8021cd:	29 f0                	sub    %esi,%eax
}
  8021cf:	5b                   	pop    %ebx
  8021d0:	5e                   	pop    %esi
  8021d1:	5d                   	pop    %ebp
  8021d2:	c3                   	ret    

008021d3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8021d3:	55                   	push   %ebp
  8021d4:	89 e5                	mov    %esp,%ebp
  8021d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021d9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8021dc:	eb 06                	jmp    8021e4 <strcmp+0x11>
		p++, q++;
  8021de:	83 c1 01             	add    $0x1,%ecx
  8021e1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8021e4:	0f b6 01             	movzbl (%ecx),%eax
  8021e7:	84 c0                	test   %al,%al
  8021e9:	74 04                	je     8021ef <strcmp+0x1c>
  8021eb:	3a 02                	cmp    (%edx),%al
  8021ed:	74 ef                	je     8021de <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8021ef:	0f b6 c0             	movzbl %al,%eax
  8021f2:	0f b6 12             	movzbl (%edx),%edx
  8021f5:	29 d0                	sub    %edx,%eax
}
  8021f7:	5d                   	pop    %ebp
  8021f8:	c3                   	ret    

008021f9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8021f9:	55                   	push   %ebp
  8021fa:	89 e5                	mov    %esp,%ebp
  8021fc:	53                   	push   %ebx
  8021fd:	8b 45 08             	mov    0x8(%ebp),%eax
  802200:	8b 55 0c             	mov    0xc(%ebp),%edx
  802203:	89 c3                	mov    %eax,%ebx
  802205:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  802208:	eb 06                	jmp    802210 <strncmp+0x17>
		n--, p++, q++;
  80220a:	83 c0 01             	add    $0x1,%eax
  80220d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  802210:	39 d8                	cmp    %ebx,%eax
  802212:	74 15                	je     802229 <strncmp+0x30>
  802214:	0f b6 08             	movzbl (%eax),%ecx
  802217:	84 c9                	test   %cl,%cl
  802219:	74 04                	je     80221f <strncmp+0x26>
  80221b:	3a 0a                	cmp    (%edx),%cl
  80221d:	74 eb                	je     80220a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80221f:	0f b6 00             	movzbl (%eax),%eax
  802222:	0f b6 12             	movzbl (%edx),%edx
  802225:	29 d0                	sub    %edx,%eax
  802227:	eb 05                	jmp    80222e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  802229:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80222e:	5b                   	pop    %ebx
  80222f:	5d                   	pop    %ebp
  802230:	c3                   	ret    

00802231 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  802231:	55                   	push   %ebp
  802232:	89 e5                	mov    %esp,%ebp
  802234:	8b 45 08             	mov    0x8(%ebp),%eax
  802237:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80223b:	eb 07                	jmp    802244 <strchr+0x13>
		if (*s == c)
  80223d:	38 ca                	cmp    %cl,%dl
  80223f:	74 0f                	je     802250 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  802241:	83 c0 01             	add    $0x1,%eax
  802244:	0f b6 10             	movzbl (%eax),%edx
  802247:	84 d2                	test   %dl,%dl
  802249:	75 f2                	jne    80223d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80224b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802250:	5d                   	pop    %ebp
  802251:	c3                   	ret    

00802252 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  802252:	55                   	push   %ebp
  802253:	89 e5                	mov    %esp,%ebp
  802255:	8b 45 08             	mov    0x8(%ebp),%eax
  802258:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80225c:	eb 03                	jmp    802261 <strfind+0xf>
  80225e:	83 c0 01             	add    $0x1,%eax
  802261:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  802264:	38 ca                	cmp    %cl,%dl
  802266:	74 04                	je     80226c <strfind+0x1a>
  802268:	84 d2                	test   %dl,%dl
  80226a:	75 f2                	jne    80225e <strfind+0xc>
			break;
	return (char *) s;
}
  80226c:	5d                   	pop    %ebp
  80226d:	c3                   	ret    

0080226e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80226e:	55                   	push   %ebp
  80226f:	89 e5                	mov    %esp,%ebp
  802271:	57                   	push   %edi
  802272:	56                   	push   %esi
  802273:	53                   	push   %ebx
  802274:	8b 7d 08             	mov    0x8(%ebp),%edi
  802277:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80227a:	85 c9                	test   %ecx,%ecx
  80227c:	74 36                	je     8022b4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80227e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802284:	75 28                	jne    8022ae <memset+0x40>
  802286:	f6 c1 03             	test   $0x3,%cl
  802289:	75 23                	jne    8022ae <memset+0x40>
		c &= 0xFF;
  80228b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80228f:	89 d3                	mov    %edx,%ebx
  802291:	c1 e3 08             	shl    $0x8,%ebx
  802294:	89 d6                	mov    %edx,%esi
  802296:	c1 e6 18             	shl    $0x18,%esi
  802299:	89 d0                	mov    %edx,%eax
  80229b:	c1 e0 10             	shl    $0x10,%eax
  80229e:	09 f0                	or     %esi,%eax
  8022a0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8022a2:	89 d8                	mov    %ebx,%eax
  8022a4:	09 d0                	or     %edx,%eax
  8022a6:	c1 e9 02             	shr    $0x2,%ecx
  8022a9:	fc                   	cld    
  8022aa:	f3 ab                	rep stos %eax,%es:(%edi)
  8022ac:	eb 06                	jmp    8022b4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8022ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022b1:	fc                   	cld    
  8022b2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8022b4:	89 f8                	mov    %edi,%eax
  8022b6:	5b                   	pop    %ebx
  8022b7:	5e                   	pop    %esi
  8022b8:	5f                   	pop    %edi
  8022b9:	5d                   	pop    %ebp
  8022ba:	c3                   	ret    

008022bb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8022bb:	55                   	push   %ebp
  8022bc:	89 e5                	mov    %esp,%ebp
  8022be:	57                   	push   %edi
  8022bf:	56                   	push   %esi
  8022c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8022c3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8022c6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8022c9:	39 c6                	cmp    %eax,%esi
  8022cb:	73 35                	jae    802302 <memmove+0x47>
  8022cd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8022d0:	39 d0                	cmp    %edx,%eax
  8022d2:	73 2e                	jae    802302 <memmove+0x47>
		s += n;
		d += n;
  8022d4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8022d7:	89 d6                	mov    %edx,%esi
  8022d9:	09 fe                	or     %edi,%esi
  8022db:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8022e1:	75 13                	jne    8022f6 <memmove+0x3b>
  8022e3:	f6 c1 03             	test   $0x3,%cl
  8022e6:	75 0e                	jne    8022f6 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8022e8:	83 ef 04             	sub    $0x4,%edi
  8022eb:	8d 72 fc             	lea    -0x4(%edx),%esi
  8022ee:	c1 e9 02             	shr    $0x2,%ecx
  8022f1:	fd                   	std    
  8022f2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8022f4:	eb 09                	jmp    8022ff <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8022f6:	83 ef 01             	sub    $0x1,%edi
  8022f9:	8d 72 ff             	lea    -0x1(%edx),%esi
  8022fc:	fd                   	std    
  8022fd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8022ff:	fc                   	cld    
  802300:	eb 1d                	jmp    80231f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802302:	89 f2                	mov    %esi,%edx
  802304:	09 c2                	or     %eax,%edx
  802306:	f6 c2 03             	test   $0x3,%dl
  802309:	75 0f                	jne    80231a <memmove+0x5f>
  80230b:	f6 c1 03             	test   $0x3,%cl
  80230e:	75 0a                	jne    80231a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  802310:	c1 e9 02             	shr    $0x2,%ecx
  802313:	89 c7                	mov    %eax,%edi
  802315:	fc                   	cld    
  802316:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802318:	eb 05                	jmp    80231f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80231a:	89 c7                	mov    %eax,%edi
  80231c:	fc                   	cld    
  80231d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80231f:	5e                   	pop    %esi
  802320:	5f                   	pop    %edi
  802321:	5d                   	pop    %ebp
  802322:	c3                   	ret    

00802323 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  802323:	55                   	push   %ebp
  802324:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  802326:	ff 75 10             	pushl  0x10(%ebp)
  802329:	ff 75 0c             	pushl  0xc(%ebp)
  80232c:	ff 75 08             	pushl  0x8(%ebp)
  80232f:	e8 87 ff ff ff       	call   8022bb <memmove>
}
  802334:	c9                   	leave  
  802335:	c3                   	ret    

00802336 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  802336:	55                   	push   %ebp
  802337:	89 e5                	mov    %esp,%ebp
  802339:	56                   	push   %esi
  80233a:	53                   	push   %ebx
  80233b:	8b 45 08             	mov    0x8(%ebp),%eax
  80233e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802341:	89 c6                	mov    %eax,%esi
  802343:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802346:	eb 1a                	jmp    802362 <memcmp+0x2c>
		if (*s1 != *s2)
  802348:	0f b6 08             	movzbl (%eax),%ecx
  80234b:	0f b6 1a             	movzbl (%edx),%ebx
  80234e:	38 d9                	cmp    %bl,%cl
  802350:	74 0a                	je     80235c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  802352:	0f b6 c1             	movzbl %cl,%eax
  802355:	0f b6 db             	movzbl %bl,%ebx
  802358:	29 d8                	sub    %ebx,%eax
  80235a:	eb 0f                	jmp    80236b <memcmp+0x35>
		s1++, s2++;
  80235c:	83 c0 01             	add    $0x1,%eax
  80235f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802362:	39 f0                	cmp    %esi,%eax
  802364:	75 e2                	jne    802348 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  802366:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80236b:	5b                   	pop    %ebx
  80236c:	5e                   	pop    %esi
  80236d:	5d                   	pop    %ebp
  80236e:	c3                   	ret    

0080236f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80236f:	55                   	push   %ebp
  802370:	89 e5                	mov    %esp,%ebp
  802372:	53                   	push   %ebx
  802373:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  802376:	89 c1                	mov    %eax,%ecx
  802378:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80237b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80237f:	eb 0a                	jmp    80238b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  802381:	0f b6 10             	movzbl (%eax),%edx
  802384:	39 da                	cmp    %ebx,%edx
  802386:	74 07                	je     80238f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802388:	83 c0 01             	add    $0x1,%eax
  80238b:	39 c8                	cmp    %ecx,%eax
  80238d:	72 f2                	jb     802381 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80238f:	5b                   	pop    %ebx
  802390:	5d                   	pop    %ebp
  802391:	c3                   	ret    

00802392 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  802392:	55                   	push   %ebp
  802393:	89 e5                	mov    %esp,%ebp
  802395:	57                   	push   %edi
  802396:	56                   	push   %esi
  802397:	53                   	push   %ebx
  802398:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80239b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80239e:	eb 03                	jmp    8023a3 <strtol+0x11>
		s++;
  8023a0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8023a3:	0f b6 01             	movzbl (%ecx),%eax
  8023a6:	3c 20                	cmp    $0x20,%al
  8023a8:	74 f6                	je     8023a0 <strtol+0xe>
  8023aa:	3c 09                	cmp    $0x9,%al
  8023ac:	74 f2                	je     8023a0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8023ae:	3c 2b                	cmp    $0x2b,%al
  8023b0:	75 0a                	jne    8023bc <strtol+0x2a>
		s++;
  8023b2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8023b5:	bf 00 00 00 00       	mov    $0x0,%edi
  8023ba:	eb 11                	jmp    8023cd <strtol+0x3b>
  8023bc:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8023c1:	3c 2d                	cmp    $0x2d,%al
  8023c3:	75 08                	jne    8023cd <strtol+0x3b>
		s++, neg = 1;
  8023c5:	83 c1 01             	add    $0x1,%ecx
  8023c8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8023cd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8023d3:	75 15                	jne    8023ea <strtol+0x58>
  8023d5:	80 39 30             	cmpb   $0x30,(%ecx)
  8023d8:	75 10                	jne    8023ea <strtol+0x58>
  8023da:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8023de:	75 7c                	jne    80245c <strtol+0xca>
		s += 2, base = 16;
  8023e0:	83 c1 02             	add    $0x2,%ecx
  8023e3:	bb 10 00 00 00       	mov    $0x10,%ebx
  8023e8:	eb 16                	jmp    802400 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8023ea:	85 db                	test   %ebx,%ebx
  8023ec:	75 12                	jne    802400 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8023ee:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8023f3:	80 39 30             	cmpb   $0x30,(%ecx)
  8023f6:	75 08                	jne    802400 <strtol+0x6e>
		s++, base = 8;
  8023f8:	83 c1 01             	add    $0x1,%ecx
  8023fb:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  802400:	b8 00 00 00 00       	mov    $0x0,%eax
  802405:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  802408:	0f b6 11             	movzbl (%ecx),%edx
  80240b:	8d 72 d0             	lea    -0x30(%edx),%esi
  80240e:	89 f3                	mov    %esi,%ebx
  802410:	80 fb 09             	cmp    $0x9,%bl
  802413:	77 08                	ja     80241d <strtol+0x8b>
			dig = *s - '0';
  802415:	0f be d2             	movsbl %dl,%edx
  802418:	83 ea 30             	sub    $0x30,%edx
  80241b:	eb 22                	jmp    80243f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80241d:	8d 72 9f             	lea    -0x61(%edx),%esi
  802420:	89 f3                	mov    %esi,%ebx
  802422:	80 fb 19             	cmp    $0x19,%bl
  802425:	77 08                	ja     80242f <strtol+0x9d>
			dig = *s - 'a' + 10;
  802427:	0f be d2             	movsbl %dl,%edx
  80242a:	83 ea 57             	sub    $0x57,%edx
  80242d:	eb 10                	jmp    80243f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80242f:	8d 72 bf             	lea    -0x41(%edx),%esi
  802432:	89 f3                	mov    %esi,%ebx
  802434:	80 fb 19             	cmp    $0x19,%bl
  802437:	77 16                	ja     80244f <strtol+0xbd>
			dig = *s - 'A' + 10;
  802439:	0f be d2             	movsbl %dl,%edx
  80243c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80243f:	3b 55 10             	cmp    0x10(%ebp),%edx
  802442:	7d 0b                	jge    80244f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  802444:	83 c1 01             	add    $0x1,%ecx
  802447:	0f af 45 10          	imul   0x10(%ebp),%eax
  80244b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80244d:	eb b9                	jmp    802408 <strtol+0x76>

	if (endptr)
  80244f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802453:	74 0d                	je     802462 <strtol+0xd0>
		*endptr = (char *) s;
  802455:	8b 75 0c             	mov    0xc(%ebp),%esi
  802458:	89 0e                	mov    %ecx,(%esi)
  80245a:	eb 06                	jmp    802462 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80245c:	85 db                	test   %ebx,%ebx
  80245e:	74 98                	je     8023f8 <strtol+0x66>
  802460:	eb 9e                	jmp    802400 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  802462:	89 c2                	mov    %eax,%edx
  802464:	f7 da                	neg    %edx
  802466:	85 ff                	test   %edi,%edi
  802468:	0f 45 c2             	cmovne %edx,%eax
}
  80246b:	5b                   	pop    %ebx
  80246c:	5e                   	pop    %esi
  80246d:	5f                   	pop    %edi
  80246e:	5d                   	pop    %ebp
  80246f:	c3                   	ret    

00802470 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  802470:	55                   	push   %ebp
  802471:	89 e5                	mov    %esp,%ebp
  802473:	57                   	push   %edi
  802474:	56                   	push   %esi
  802475:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802476:	b8 00 00 00 00       	mov    $0x0,%eax
  80247b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80247e:	8b 55 08             	mov    0x8(%ebp),%edx
  802481:	89 c3                	mov    %eax,%ebx
  802483:	89 c7                	mov    %eax,%edi
  802485:	89 c6                	mov    %eax,%esi
  802487:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  802489:	5b                   	pop    %ebx
  80248a:	5e                   	pop    %esi
  80248b:	5f                   	pop    %edi
  80248c:	5d                   	pop    %ebp
  80248d:	c3                   	ret    

0080248e <sys_cgetc>:

int
sys_cgetc(void)
{
  80248e:	55                   	push   %ebp
  80248f:	89 e5                	mov    %esp,%ebp
  802491:	57                   	push   %edi
  802492:	56                   	push   %esi
  802493:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802494:	ba 00 00 00 00       	mov    $0x0,%edx
  802499:	b8 01 00 00 00       	mov    $0x1,%eax
  80249e:	89 d1                	mov    %edx,%ecx
  8024a0:	89 d3                	mov    %edx,%ebx
  8024a2:	89 d7                	mov    %edx,%edi
  8024a4:	89 d6                	mov    %edx,%esi
  8024a6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8024a8:	5b                   	pop    %ebx
  8024a9:	5e                   	pop    %esi
  8024aa:	5f                   	pop    %edi
  8024ab:	5d                   	pop    %ebp
  8024ac:	c3                   	ret    

008024ad <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8024ad:	55                   	push   %ebp
  8024ae:	89 e5                	mov    %esp,%ebp
  8024b0:	57                   	push   %edi
  8024b1:	56                   	push   %esi
  8024b2:	53                   	push   %ebx
  8024b3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8024bb:	b8 03 00 00 00       	mov    $0x3,%eax
  8024c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8024c3:	89 cb                	mov    %ecx,%ebx
  8024c5:	89 cf                	mov    %ecx,%edi
  8024c7:	89 ce                	mov    %ecx,%esi
  8024c9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8024cb:	85 c0                	test   %eax,%eax
  8024cd:	7e 17                	jle    8024e6 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8024cf:	83 ec 0c             	sub    $0xc,%esp
  8024d2:	50                   	push   %eax
  8024d3:	6a 03                	push   $0x3
  8024d5:	68 1f 41 80 00       	push   $0x80411f
  8024da:	6a 23                	push   $0x23
  8024dc:	68 3c 41 80 00       	push   $0x80413c
  8024e1:	e8 e5 f5 ff ff       	call   801acb <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8024e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024e9:	5b                   	pop    %ebx
  8024ea:	5e                   	pop    %esi
  8024eb:	5f                   	pop    %edi
  8024ec:	5d                   	pop    %ebp
  8024ed:	c3                   	ret    

008024ee <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8024ee:	55                   	push   %ebp
  8024ef:	89 e5                	mov    %esp,%ebp
  8024f1:	57                   	push   %edi
  8024f2:	56                   	push   %esi
  8024f3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8024f9:	b8 02 00 00 00       	mov    $0x2,%eax
  8024fe:	89 d1                	mov    %edx,%ecx
  802500:	89 d3                	mov    %edx,%ebx
  802502:	89 d7                	mov    %edx,%edi
  802504:	89 d6                	mov    %edx,%esi
  802506:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  802508:	5b                   	pop    %ebx
  802509:	5e                   	pop    %esi
  80250a:	5f                   	pop    %edi
  80250b:	5d                   	pop    %ebp
  80250c:	c3                   	ret    

0080250d <sys_yield>:

void
sys_yield(void)
{
  80250d:	55                   	push   %ebp
  80250e:	89 e5                	mov    %esp,%ebp
  802510:	57                   	push   %edi
  802511:	56                   	push   %esi
  802512:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802513:	ba 00 00 00 00       	mov    $0x0,%edx
  802518:	b8 0b 00 00 00       	mov    $0xb,%eax
  80251d:	89 d1                	mov    %edx,%ecx
  80251f:	89 d3                	mov    %edx,%ebx
  802521:	89 d7                	mov    %edx,%edi
  802523:	89 d6                	mov    %edx,%esi
  802525:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  802527:	5b                   	pop    %ebx
  802528:	5e                   	pop    %esi
  802529:	5f                   	pop    %edi
  80252a:	5d                   	pop    %ebp
  80252b:	c3                   	ret    

0080252c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80252c:	55                   	push   %ebp
  80252d:	89 e5                	mov    %esp,%ebp
  80252f:	57                   	push   %edi
  802530:	56                   	push   %esi
  802531:	53                   	push   %ebx
  802532:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802535:	be 00 00 00 00       	mov    $0x0,%esi
  80253a:	b8 04 00 00 00       	mov    $0x4,%eax
  80253f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802542:	8b 55 08             	mov    0x8(%ebp),%edx
  802545:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802548:	89 f7                	mov    %esi,%edi
  80254a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80254c:	85 c0                	test   %eax,%eax
  80254e:	7e 17                	jle    802567 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802550:	83 ec 0c             	sub    $0xc,%esp
  802553:	50                   	push   %eax
  802554:	6a 04                	push   $0x4
  802556:	68 1f 41 80 00       	push   $0x80411f
  80255b:	6a 23                	push   $0x23
  80255d:	68 3c 41 80 00       	push   $0x80413c
  802562:	e8 64 f5 ff ff       	call   801acb <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  802567:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80256a:	5b                   	pop    %ebx
  80256b:	5e                   	pop    %esi
  80256c:	5f                   	pop    %edi
  80256d:	5d                   	pop    %ebp
  80256e:	c3                   	ret    

0080256f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80256f:	55                   	push   %ebp
  802570:	89 e5                	mov    %esp,%ebp
  802572:	57                   	push   %edi
  802573:	56                   	push   %esi
  802574:	53                   	push   %ebx
  802575:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802578:	b8 05 00 00 00       	mov    $0x5,%eax
  80257d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802580:	8b 55 08             	mov    0x8(%ebp),%edx
  802583:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802586:	8b 7d 14             	mov    0x14(%ebp),%edi
  802589:	8b 75 18             	mov    0x18(%ebp),%esi
  80258c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80258e:	85 c0                	test   %eax,%eax
  802590:	7e 17                	jle    8025a9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802592:	83 ec 0c             	sub    $0xc,%esp
  802595:	50                   	push   %eax
  802596:	6a 05                	push   $0x5
  802598:	68 1f 41 80 00       	push   $0x80411f
  80259d:	6a 23                	push   $0x23
  80259f:	68 3c 41 80 00       	push   $0x80413c
  8025a4:	e8 22 f5 ff ff       	call   801acb <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8025a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025ac:	5b                   	pop    %ebx
  8025ad:	5e                   	pop    %esi
  8025ae:	5f                   	pop    %edi
  8025af:	5d                   	pop    %ebp
  8025b0:	c3                   	ret    

008025b1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8025b1:	55                   	push   %ebp
  8025b2:	89 e5                	mov    %esp,%ebp
  8025b4:	57                   	push   %edi
  8025b5:	56                   	push   %esi
  8025b6:	53                   	push   %ebx
  8025b7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8025bf:	b8 06 00 00 00       	mov    $0x6,%eax
  8025c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8025ca:	89 df                	mov    %ebx,%edi
  8025cc:	89 de                	mov    %ebx,%esi
  8025ce:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8025d0:	85 c0                	test   %eax,%eax
  8025d2:	7e 17                	jle    8025eb <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025d4:	83 ec 0c             	sub    $0xc,%esp
  8025d7:	50                   	push   %eax
  8025d8:	6a 06                	push   $0x6
  8025da:	68 1f 41 80 00       	push   $0x80411f
  8025df:	6a 23                	push   $0x23
  8025e1:	68 3c 41 80 00       	push   $0x80413c
  8025e6:	e8 e0 f4 ff ff       	call   801acb <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8025eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025ee:	5b                   	pop    %ebx
  8025ef:	5e                   	pop    %esi
  8025f0:	5f                   	pop    %edi
  8025f1:	5d                   	pop    %ebp
  8025f2:	c3                   	ret    

008025f3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8025f3:	55                   	push   %ebp
  8025f4:	89 e5                	mov    %esp,%ebp
  8025f6:	57                   	push   %edi
  8025f7:	56                   	push   %esi
  8025f8:	53                   	push   %ebx
  8025f9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  802601:	b8 08 00 00 00       	mov    $0x8,%eax
  802606:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802609:	8b 55 08             	mov    0x8(%ebp),%edx
  80260c:	89 df                	mov    %ebx,%edi
  80260e:	89 de                	mov    %ebx,%esi
  802610:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802612:	85 c0                	test   %eax,%eax
  802614:	7e 17                	jle    80262d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802616:	83 ec 0c             	sub    $0xc,%esp
  802619:	50                   	push   %eax
  80261a:	6a 08                	push   $0x8
  80261c:	68 1f 41 80 00       	push   $0x80411f
  802621:	6a 23                	push   $0x23
  802623:	68 3c 41 80 00       	push   $0x80413c
  802628:	e8 9e f4 ff ff       	call   801acb <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80262d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802630:	5b                   	pop    %ebx
  802631:	5e                   	pop    %esi
  802632:	5f                   	pop    %edi
  802633:	5d                   	pop    %ebp
  802634:	c3                   	ret    

00802635 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  802635:	55                   	push   %ebp
  802636:	89 e5                	mov    %esp,%ebp
  802638:	57                   	push   %edi
  802639:	56                   	push   %esi
  80263a:	53                   	push   %ebx
  80263b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80263e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802643:	b8 09 00 00 00       	mov    $0x9,%eax
  802648:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80264b:	8b 55 08             	mov    0x8(%ebp),%edx
  80264e:	89 df                	mov    %ebx,%edi
  802650:	89 de                	mov    %ebx,%esi
  802652:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802654:	85 c0                	test   %eax,%eax
  802656:	7e 17                	jle    80266f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802658:	83 ec 0c             	sub    $0xc,%esp
  80265b:	50                   	push   %eax
  80265c:	6a 09                	push   $0x9
  80265e:	68 1f 41 80 00       	push   $0x80411f
  802663:	6a 23                	push   $0x23
  802665:	68 3c 41 80 00       	push   $0x80413c
  80266a:	e8 5c f4 ff ff       	call   801acb <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80266f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802672:	5b                   	pop    %ebx
  802673:	5e                   	pop    %esi
  802674:	5f                   	pop    %edi
  802675:	5d                   	pop    %ebp
  802676:	c3                   	ret    

00802677 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  802677:	55                   	push   %ebp
  802678:	89 e5                	mov    %esp,%ebp
  80267a:	57                   	push   %edi
  80267b:	56                   	push   %esi
  80267c:	53                   	push   %ebx
  80267d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802680:	bb 00 00 00 00       	mov    $0x0,%ebx
  802685:	b8 0a 00 00 00       	mov    $0xa,%eax
  80268a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80268d:	8b 55 08             	mov    0x8(%ebp),%edx
  802690:	89 df                	mov    %ebx,%edi
  802692:	89 de                	mov    %ebx,%esi
  802694:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802696:	85 c0                	test   %eax,%eax
  802698:	7e 17                	jle    8026b1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80269a:	83 ec 0c             	sub    $0xc,%esp
  80269d:	50                   	push   %eax
  80269e:	6a 0a                	push   $0xa
  8026a0:	68 1f 41 80 00       	push   $0x80411f
  8026a5:	6a 23                	push   $0x23
  8026a7:	68 3c 41 80 00       	push   $0x80413c
  8026ac:	e8 1a f4 ff ff       	call   801acb <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8026b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026b4:	5b                   	pop    %ebx
  8026b5:	5e                   	pop    %esi
  8026b6:	5f                   	pop    %edi
  8026b7:	5d                   	pop    %ebp
  8026b8:	c3                   	ret    

008026b9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8026b9:	55                   	push   %ebp
  8026ba:	89 e5                	mov    %esp,%ebp
  8026bc:	57                   	push   %edi
  8026bd:	56                   	push   %esi
  8026be:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026bf:	be 00 00 00 00       	mov    $0x0,%esi
  8026c4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8026c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8026cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8026d2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8026d5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8026d7:	5b                   	pop    %ebx
  8026d8:	5e                   	pop    %esi
  8026d9:	5f                   	pop    %edi
  8026da:	5d                   	pop    %ebp
  8026db:	c3                   	ret    

008026dc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8026dc:	55                   	push   %ebp
  8026dd:	89 e5                	mov    %esp,%ebp
  8026df:	57                   	push   %edi
  8026e0:	56                   	push   %esi
  8026e1:	53                   	push   %ebx
  8026e2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8026ea:	b8 0d 00 00 00       	mov    $0xd,%eax
  8026ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8026f2:	89 cb                	mov    %ecx,%ebx
  8026f4:	89 cf                	mov    %ecx,%edi
  8026f6:	89 ce                	mov    %ecx,%esi
  8026f8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8026fa:	85 c0                	test   %eax,%eax
  8026fc:	7e 17                	jle    802715 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8026fe:	83 ec 0c             	sub    $0xc,%esp
  802701:	50                   	push   %eax
  802702:	6a 0d                	push   $0xd
  802704:	68 1f 41 80 00       	push   $0x80411f
  802709:	6a 23                	push   $0x23
  80270b:	68 3c 41 80 00       	push   $0x80413c
  802710:	e8 b6 f3 ff ff       	call   801acb <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  802715:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802718:	5b                   	pop    %ebx
  802719:	5e                   	pop    %esi
  80271a:	5f                   	pop    %edi
  80271b:	5d                   	pop    %ebp
  80271c:	c3                   	ret    

0080271d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80271d:	55                   	push   %ebp
  80271e:	89 e5                	mov    %esp,%ebp
  802720:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802723:	83 3d 10 a0 80 00 00 	cmpl   $0x0,0x80a010
  80272a:	75 2a                	jne    802756 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  80272c:	83 ec 04             	sub    $0x4,%esp
  80272f:	6a 07                	push   $0x7
  802731:	68 00 f0 bf ee       	push   $0xeebff000
  802736:	6a 00                	push   $0x0
  802738:	e8 ef fd ff ff       	call   80252c <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  80273d:	83 c4 10             	add    $0x10,%esp
  802740:	85 c0                	test   %eax,%eax
  802742:	79 12                	jns    802756 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802744:	50                   	push   %eax
  802745:	68 4a 41 80 00       	push   $0x80414a
  80274a:	6a 23                	push   $0x23
  80274c:	68 4e 41 80 00       	push   $0x80414e
  802751:	e8 75 f3 ff ff       	call   801acb <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802756:	8b 45 08             	mov    0x8(%ebp),%eax
  802759:	a3 10 a0 80 00       	mov    %eax,0x80a010
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80275e:	83 ec 08             	sub    $0x8,%esp
  802761:	68 88 27 80 00       	push   $0x802788
  802766:	6a 00                	push   $0x0
  802768:	e8 0a ff ff ff       	call   802677 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  80276d:	83 c4 10             	add    $0x10,%esp
  802770:	85 c0                	test   %eax,%eax
  802772:	79 12                	jns    802786 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802774:	50                   	push   %eax
  802775:	68 4a 41 80 00       	push   $0x80414a
  80277a:	6a 2c                	push   $0x2c
  80277c:	68 4e 41 80 00       	push   $0x80414e
  802781:	e8 45 f3 ff ff       	call   801acb <_panic>
	}
}
  802786:	c9                   	leave  
  802787:	c3                   	ret    

00802788 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802788:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802789:	a1 10 a0 80 00       	mov    0x80a010,%eax
	call *%eax
  80278e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802790:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802793:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802797:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  80279c:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8027a0:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8027a2:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8027a5:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8027a6:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8027a9:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8027aa:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8027ab:	c3                   	ret    

008027ac <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8027ac:	55                   	push   %ebp
  8027ad:	89 e5                	mov    %esp,%ebp
  8027af:	56                   	push   %esi
  8027b0:	53                   	push   %ebx
  8027b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8027b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8027ba:	85 c0                	test   %eax,%eax
  8027bc:	75 12                	jne    8027d0 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8027be:	83 ec 0c             	sub    $0xc,%esp
  8027c1:	68 00 00 c0 ee       	push   $0xeec00000
  8027c6:	e8 11 ff ff ff       	call   8026dc <sys_ipc_recv>
  8027cb:	83 c4 10             	add    $0x10,%esp
  8027ce:	eb 0c                	jmp    8027dc <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8027d0:	83 ec 0c             	sub    $0xc,%esp
  8027d3:	50                   	push   %eax
  8027d4:	e8 03 ff ff ff       	call   8026dc <sys_ipc_recv>
  8027d9:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8027dc:	85 f6                	test   %esi,%esi
  8027de:	0f 95 c1             	setne  %cl
  8027e1:	85 db                	test   %ebx,%ebx
  8027e3:	0f 95 c2             	setne  %dl
  8027e6:	84 d1                	test   %dl,%cl
  8027e8:	74 09                	je     8027f3 <ipc_recv+0x47>
  8027ea:	89 c2                	mov    %eax,%edx
  8027ec:	c1 ea 1f             	shr    $0x1f,%edx
  8027ef:	84 d2                	test   %dl,%dl
  8027f1:	75 24                	jne    802817 <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8027f3:	85 f6                	test   %esi,%esi
  8027f5:	74 0a                	je     802801 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  8027f7:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8027fc:	8b 40 74             	mov    0x74(%eax),%eax
  8027ff:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802801:	85 db                	test   %ebx,%ebx
  802803:	74 0a                	je     80280f <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  802805:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80280a:	8b 40 78             	mov    0x78(%eax),%eax
  80280d:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80280f:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802814:	8b 40 70             	mov    0x70(%eax),%eax
}
  802817:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80281a:	5b                   	pop    %ebx
  80281b:	5e                   	pop    %esi
  80281c:	5d                   	pop    %ebp
  80281d:	c3                   	ret    

0080281e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80281e:	55                   	push   %ebp
  80281f:	89 e5                	mov    %esp,%ebp
  802821:	57                   	push   %edi
  802822:	56                   	push   %esi
  802823:	53                   	push   %ebx
  802824:	83 ec 0c             	sub    $0xc,%esp
  802827:	8b 7d 08             	mov    0x8(%ebp),%edi
  80282a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80282d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802830:	85 db                	test   %ebx,%ebx
  802832:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802837:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80283a:	ff 75 14             	pushl  0x14(%ebp)
  80283d:	53                   	push   %ebx
  80283e:	56                   	push   %esi
  80283f:	57                   	push   %edi
  802840:	e8 74 fe ff ff       	call   8026b9 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802845:	89 c2                	mov    %eax,%edx
  802847:	c1 ea 1f             	shr    $0x1f,%edx
  80284a:	83 c4 10             	add    $0x10,%esp
  80284d:	84 d2                	test   %dl,%dl
  80284f:	74 17                	je     802868 <ipc_send+0x4a>
  802851:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802854:	74 12                	je     802868 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802856:	50                   	push   %eax
  802857:	68 5c 41 80 00       	push   $0x80415c
  80285c:	6a 47                	push   $0x47
  80285e:	68 6a 41 80 00       	push   $0x80416a
  802863:	e8 63 f2 ff ff       	call   801acb <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802868:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80286b:	75 07                	jne    802874 <ipc_send+0x56>
			sys_yield();
  80286d:	e8 9b fc ff ff       	call   80250d <sys_yield>
  802872:	eb c6                	jmp    80283a <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802874:	85 c0                	test   %eax,%eax
  802876:	75 c2                	jne    80283a <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802878:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80287b:	5b                   	pop    %ebx
  80287c:	5e                   	pop    %esi
  80287d:	5f                   	pop    %edi
  80287e:	5d                   	pop    %ebp
  80287f:	c3                   	ret    

00802880 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802880:	55                   	push   %ebp
  802881:	89 e5                	mov    %esp,%ebp
  802883:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802886:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80288b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80288e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802894:	8b 52 50             	mov    0x50(%edx),%edx
  802897:	39 ca                	cmp    %ecx,%edx
  802899:	75 0d                	jne    8028a8 <ipc_find_env+0x28>
			return envs[i].env_id;
  80289b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80289e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8028a3:	8b 40 48             	mov    0x48(%eax),%eax
  8028a6:	eb 0f                	jmp    8028b7 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8028a8:	83 c0 01             	add    $0x1,%eax
  8028ab:	3d 00 04 00 00       	cmp    $0x400,%eax
  8028b0:	75 d9                	jne    80288b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8028b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8028b7:	5d                   	pop    %ebp
  8028b8:	c3                   	ret    

008028b9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8028b9:	55                   	push   %ebp
  8028ba:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8028bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8028bf:	05 00 00 00 30       	add    $0x30000000,%eax
  8028c4:	c1 e8 0c             	shr    $0xc,%eax
}
  8028c7:	5d                   	pop    %ebp
  8028c8:	c3                   	ret    

008028c9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8028c9:	55                   	push   %ebp
  8028ca:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8028cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8028cf:	05 00 00 00 30       	add    $0x30000000,%eax
  8028d4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8028d9:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8028de:	5d                   	pop    %ebp
  8028df:	c3                   	ret    

008028e0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8028e0:	55                   	push   %ebp
  8028e1:	89 e5                	mov    %esp,%ebp
  8028e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8028e6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8028eb:	89 c2                	mov    %eax,%edx
  8028ed:	c1 ea 16             	shr    $0x16,%edx
  8028f0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8028f7:	f6 c2 01             	test   $0x1,%dl
  8028fa:	74 11                	je     80290d <fd_alloc+0x2d>
  8028fc:	89 c2                	mov    %eax,%edx
  8028fe:	c1 ea 0c             	shr    $0xc,%edx
  802901:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802908:	f6 c2 01             	test   $0x1,%dl
  80290b:	75 09                	jne    802916 <fd_alloc+0x36>
			*fd_store = fd;
  80290d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80290f:	b8 00 00 00 00       	mov    $0x0,%eax
  802914:	eb 17                	jmp    80292d <fd_alloc+0x4d>
  802916:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80291b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  802920:	75 c9                	jne    8028eb <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  802922:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  802928:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80292d:	5d                   	pop    %ebp
  80292e:	c3                   	ret    

0080292f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80292f:	55                   	push   %ebp
  802930:	89 e5                	mov    %esp,%ebp
  802932:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802935:	83 f8 1f             	cmp    $0x1f,%eax
  802938:	77 36                	ja     802970 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80293a:	c1 e0 0c             	shl    $0xc,%eax
  80293d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  802942:	89 c2                	mov    %eax,%edx
  802944:	c1 ea 16             	shr    $0x16,%edx
  802947:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80294e:	f6 c2 01             	test   $0x1,%dl
  802951:	74 24                	je     802977 <fd_lookup+0x48>
  802953:	89 c2                	mov    %eax,%edx
  802955:	c1 ea 0c             	shr    $0xc,%edx
  802958:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80295f:	f6 c2 01             	test   $0x1,%dl
  802962:	74 1a                	je     80297e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  802964:	8b 55 0c             	mov    0xc(%ebp),%edx
  802967:	89 02                	mov    %eax,(%edx)
	return 0;
  802969:	b8 00 00 00 00       	mov    $0x0,%eax
  80296e:	eb 13                	jmp    802983 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802970:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802975:	eb 0c                	jmp    802983 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802977:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80297c:	eb 05                	jmp    802983 <fd_lookup+0x54>
  80297e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  802983:	5d                   	pop    %ebp
  802984:	c3                   	ret    

00802985 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802985:	55                   	push   %ebp
  802986:	89 e5                	mov    %esp,%ebp
  802988:	83 ec 08             	sub    $0x8,%esp
  80298b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80298e:	ba f4 41 80 00       	mov    $0x8041f4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  802993:	eb 13                	jmp    8029a8 <dev_lookup+0x23>
  802995:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  802998:	39 08                	cmp    %ecx,(%eax)
  80299a:	75 0c                	jne    8029a8 <dev_lookup+0x23>
			*dev = devtab[i];
  80299c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80299f:	89 01                	mov    %eax,(%ecx)
			return 0;
  8029a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8029a6:	eb 2e                	jmp    8029d6 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8029a8:	8b 02                	mov    (%edx),%eax
  8029aa:	85 c0                	test   %eax,%eax
  8029ac:	75 e7                	jne    802995 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8029ae:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8029b3:	8b 40 48             	mov    0x48(%eax),%eax
  8029b6:	83 ec 04             	sub    $0x4,%esp
  8029b9:	51                   	push   %ecx
  8029ba:	50                   	push   %eax
  8029bb:	68 74 41 80 00       	push   $0x804174
  8029c0:	e8 df f1 ff ff       	call   801ba4 <cprintf>
	*dev = 0;
  8029c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8029c8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8029ce:	83 c4 10             	add    $0x10,%esp
  8029d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8029d6:	c9                   	leave  
  8029d7:	c3                   	ret    

008029d8 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8029d8:	55                   	push   %ebp
  8029d9:	89 e5                	mov    %esp,%ebp
  8029db:	56                   	push   %esi
  8029dc:	53                   	push   %ebx
  8029dd:	83 ec 10             	sub    $0x10,%esp
  8029e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8029e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8029e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8029e9:	50                   	push   %eax
  8029ea:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8029f0:	c1 e8 0c             	shr    $0xc,%eax
  8029f3:	50                   	push   %eax
  8029f4:	e8 36 ff ff ff       	call   80292f <fd_lookup>
  8029f9:	83 c4 08             	add    $0x8,%esp
  8029fc:	85 c0                	test   %eax,%eax
  8029fe:	78 05                	js     802a05 <fd_close+0x2d>
	    || fd != fd2)
  802a00:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  802a03:	74 0c                	je     802a11 <fd_close+0x39>
		return (must_exist ? r : 0);
  802a05:	84 db                	test   %bl,%bl
  802a07:	ba 00 00 00 00       	mov    $0x0,%edx
  802a0c:	0f 44 c2             	cmove  %edx,%eax
  802a0f:	eb 41                	jmp    802a52 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802a11:	83 ec 08             	sub    $0x8,%esp
  802a14:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802a17:	50                   	push   %eax
  802a18:	ff 36                	pushl  (%esi)
  802a1a:	e8 66 ff ff ff       	call   802985 <dev_lookup>
  802a1f:	89 c3                	mov    %eax,%ebx
  802a21:	83 c4 10             	add    $0x10,%esp
  802a24:	85 c0                	test   %eax,%eax
  802a26:	78 1a                	js     802a42 <fd_close+0x6a>
		if (dev->dev_close)
  802a28:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802a2b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  802a2e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  802a33:	85 c0                	test   %eax,%eax
  802a35:	74 0b                	je     802a42 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  802a37:	83 ec 0c             	sub    $0xc,%esp
  802a3a:	56                   	push   %esi
  802a3b:	ff d0                	call   *%eax
  802a3d:	89 c3                	mov    %eax,%ebx
  802a3f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802a42:	83 ec 08             	sub    $0x8,%esp
  802a45:	56                   	push   %esi
  802a46:	6a 00                	push   $0x0
  802a48:	e8 64 fb ff ff       	call   8025b1 <sys_page_unmap>
	return r;
  802a4d:	83 c4 10             	add    $0x10,%esp
  802a50:	89 d8                	mov    %ebx,%eax
}
  802a52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802a55:	5b                   	pop    %ebx
  802a56:	5e                   	pop    %esi
  802a57:	5d                   	pop    %ebp
  802a58:	c3                   	ret    

00802a59 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  802a59:	55                   	push   %ebp
  802a5a:	89 e5                	mov    %esp,%ebp
  802a5c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802a5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802a62:	50                   	push   %eax
  802a63:	ff 75 08             	pushl  0x8(%ebp)
  802a66:	e8 c4 fe ff ff       	call   80292f <fd_lookup>
  802a6b:	83 c4 08             	add    $0x8,%esp
  802a6e:	85 c0                	test   %eax,%eax
  802a70:	78 10                	js     802a82 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  802a72:	83 ec 08             	sub    $0x8,%esp
  802a75:	6a 01                	push   $0x1
  802a77:	ff 75 f4             	pushl  -0xc(%ebp)
  802a7a:	e8 59 ff ff ff       	call   8029d8 <fd_close>
  802a7f:	83 c4 10             	add    $0x10,%esp
}
  802a82:	c9                   	leave  
  802a83:	c3                   	ret    

00802a84 <close_all>:

void
close_all(void)
{
  802a84:	55                   	push   %ebp
  802a85:	89 e5                	mov    %esp,%ebp
  802a87:	53                   	push   %ebx
  802a88:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802a8b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802a90:	83 ec 0c             	sub    $0xc,%esp
  802a93:	53                   	push   %ebx
  802a94:	e8 c0 ff ff ff       	call   802a59 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  802a99:	83 c3 01             	add    $0x1,%ebx
  802a9c:	83 c4 10             	add    $0x10,%esp
  802a9f:	83 fb 20             	cmp    $0x20,%ebx
  802aa2:	75 ec                	jne    802a90 <close_all+0xc>
		close(i);
}
  802aa4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802aa7:	c9                   	leave  
  802aa8:	c3                   	ret    

00802aa9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802aa9:	55                   	push   %ebp
  802aaa:	89 e5                	mov    %esp,%ebp
  802aac:	57                   	push   %edi
  802aad:	56                   	push   %esi
  802aae:	53                   	push   %ebx
  802aaf:	83 ec 2c             	sub    $0x2c,%esp
  802ab2:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802ab5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802ab8:	50                   	push   %eax
  802ab9:	ff 75 08             	pushl  0x8(%ebp)
  802abc:	e8 6e fe ff ff       	call   80292f <fd_lookup>
  802ac1:	83 c4 08             	add    $0x8,%esp
  802ac4:	85 c0                	test   %eax,%eax
  802ac6:	0f 88 c1 00 00 00    	js     802b8d <dup+0xe4>
		return r;
	close(newfdnum);
  802acc:	83 ec 0c             	sub    $0xc,%esp
  802acf:	56                   	push   %esi
  802ad0:	e8 84 ff ff ff       	call   802a59 <close>

	newfd = INDEX2FD(newfdnum);
  802ad5:	89 f3                	mov    %esi,%ebx
  802ad7:	c1 e3 0c             	shl    $0xc,%ebx
  802ada:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  802ae0:	83 c4 04             	add    $0x4,%esp
  802ae3:	ff 75 e4             	pushl  -0x1c(%ebp)
  802ae6:	e8 de fd ff ff       	call   8028c9 <fd2data>
  802aeb:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  802aed:	89 1c 24             	mov    %ebx,(%esp)
  802af0:	e8 d4 fd ff ff       	call   8028c9 <fd2data>
  802af5:	83 c4 10             	add    $0x10,%esp
  802af8:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802afb:	89 f8                	mov    %edi,%eax
  802afd:	c1 e8 16             	shr    $0x16,%eax
  802b00:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802b07:	a8 01                	test   $0x1,%al
  802b09:	74 37                	je     802b42 <dup+0x99>
  802b0b:	89 f8                	mov    %edi,%eax
  802b0d:	c1 e8 0c             	shr    $0xc,%eax
  802b10:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802b17:	f6 c2 01             	test   $0x1,%dl
  802b1a:	74 26                	je     802b42 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802b1c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802b23:	83 ec 0c             	sub    $0xc,%esp
  802b26:	25 07 0e 00 00       	and    $0xe07,%eax
  802b2b:	50                   	push   %eax
  802b2c:	ff 75 d4             	pushl  -0x2c(%ebp)
  802b2f:	6a 00                	push   $0x0
  802b31:	57                   	push   %edi
  802b32:	6a 00                	push   $0x0
  802b34:	e8 36 fa ff ff       	call   80256f <sys_page_map>
  802b39:	89 c7                	mov    %eax,%edi
  802b3b:	83 c4 20             	add    $0x20,%esp
  802b3e:	85 c0                	test   %eax,%eax
  802b40:	78 2e                	js     802b70 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802b42:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802b45:	89 d0                	mov    %edx,%eax
  802b47:	c1 e8 0c             	shr    $0xc,%eax
  802b4a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802b51:	83 ec 0c             	sub    $0xc,%esp
  802b54:	25 07 0e 00 00       	and    $0xe07,%eax
  802b59:	50                   	push   %eax
  802b5a:	53                   	push   %ebx
  802b5b:	6a 00                	push   $0x0
  802b5d:	52                   	push   %edx
  802b5e:	6a 00                	push   $0x0
  802b60:	e8 0a fa ff ff       	call   80256f <sys_page_map>
  802b65:	89 c7                	mov    %eax,%edi
  802b67:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  802b6a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802b6c:	85 ff                	test   %edi,%edi
  802b6e:	79 1d                	jns    802b8d <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802b70:	83 ec 08             	sub    $0x8,%esp
  802b73:	53                   	push   %ebx
  802b74:	6a 00                	push   $0x0
  802b76:	e8 36 fa ff ff       	call   8025b1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802b7b:	83 c4 08             	add    $0x8,%esp
  802b7e:	ff 75 d4             	pushl  -0x2c(%ebp)
  802b81:	6a 00                	push   $0x0
  802b83:	e8 29 fa ff ff       	call   8025b1 <sys_page_unmap>
	return r;
  802b88:	83 c4 10             	add    $0x10,%esp
  802b8b:	89 f8                	mov    %edi,%eax
}
  802b8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b90:	5b                   	pop    %ebx
  802b91:	5e                   	pop    %esi
  802b92:	5f                   	pop    %edi
  802b93:	5d                   	pop    %ebp
  802b94:	c3                   	ret    

00802b95 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802b95:	55                   	push   %ebp
  802b96:	89 e5                	mov    %esp,%ebp
  802b98:	53                   	push   %ebx
  802b99:	83 ec 14             	sub    $0x14,%esp
  802b9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802b9f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802ba2:	50                   	push   %eax
  802ba3:	53                   	push   %ebx
  802ba4:	e8 86 fd ff ff       	call   80292f <fd_lookup>
  802ba9:	83 c4 08             	add    $0x8,%esp
  802bac:	89 c2                	mov    %eax,%edx
  802bae:	85 c0                	test   %eax,%eax
  802bb0:	78 6d                	js     802c1f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802bb2:	83 ec 08             	sub    $0x8,%esp
  802bb5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802bb8:	50                   	push   %eax
  802bb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802bbc:	ff 30                	pushl  (%eax)
  802bbe:	e8 c2 fd ff ff       	call   802985 <dev_lookup>
  802bc3:	83 c4 10             	add    $0x10,%esp
  802bc6:	85 c0                	test   %eax,%eax
  802bc8:	78 4c                	js     802c16 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802bca:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802bcd:	8b 42 08             	mov    0x8(%edx),%eax
  802bd0:	83 e0 03             	and    $0x3,%eax
  802bd3:	83 f8 01             	cmp    $0x1,%eax
  802bd6:	75 21                	jne    802bf9 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802bd8:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802bdd:	8b 40 48             	mov    0x48(%eax),%eax
  802be0:	83 ec 04             	sub    $0x4,%esp
  802be3:	53                   	push   %ebx
  802be4:	50                   	push   %eax
  802be5:	68 b8 41 80 00       	push   $0x8041b8
  802bea:	e8 b5 ef ff ff       	call   801ba4 <cprintf>
		return -E_INVAL;
  802bef:	83 c4 10             	add    $0x10,%esp
  802bf2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802bf7:	eb 26                	jmp    802c1f <read+0x8a>
	}
	if (!dev->dev_read)
  802bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802bfc:	8b 40 08             	mov    0x8(%eax),%eax
  802bff:	85 c0                	test   %eax,%eax
  802c01:	74 17                	je     802c1a <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  802c03:	83 ec 04             	sub    $0x4,%esp
  802c06:	ff 75 10             	pushl  0x10(%ebp)
  802c09:	ff 75 0c             	pushl  0xc(%ebp)
  802c0c:	52                   	push   %edx
  802c0d:	ff d0                	call   *%eax
  802c0f:	89 c2                	mov    %eax,%edx
  802c11:	83 c4 10             	add    $0x10,%esp
  802c14:	eb 09                	jmp    802c1f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c16:	89 c2                	mov    %eax,%edx
  802c18:	eb 05                	jmp    802c1f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802c1a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  802c1f:	89 d0                	mov    %edx,%eax
  802c21:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802c24:	c9                   	leave  
  802c25:	c3                   	ret    

00802c26 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802c26:	55                   	push   %ebp
  802c27:	89 e5                	mov    %esp,%ebp
  802c29:	57                   	push   %edi
  802c2a:	56                   	push   %esi
  802c2b:	53                   	push   %ebx
  802c2c:	83 ec 0c             	sub    $0xc,%esp
  802c2f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802c32:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802c35:	bb 00 00 00 00       	mov    $0x0,%ebx
  802c3a:	eb 21                	jmp    802c5d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802c3c:	83 ec 04             	sub    $0x4,%esp
  802c3f:	89 f0                	mov    %esi,%eax
  802c41:	29 d8                	sub    %ebx,%eax
  802c43:	50                   	push   %eax
  802c44:	89 d8                	mov    %ebx,%eax
  802c46:	03 45 0c             	add    0xc(%ebp),%eax
  802c49:	50                   	push   %eax
  802c4a:	57                   	push   %edi
  802c4b:	e8 45 ff ff ff       	call   802b95 <read>
		if (m < 0)
  802c50:	83 c4 10             	add    $0x10,%esp
  802c53:	85 c0                	test   %eax,%eax
  802c55:	78 10                	js     802c67 <readn+0x41>
			return m;
		if (m == 0)
  802c57:	85 c0                	test   %eax,%eax
  802c59:	74 0a                	je     802c65 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802c5b:	01 c3                	add    %eax,%ebx
  802c5d:	39 f3                	cmp    %esi,%ebx
  802c5f:	72 db                	jb     802c3c <readn+0x16>
  802c61:	89 d8                	mov    %ebx,%eax
  802c63:	eb 02                	jmp    802c67 <readn+0x41>
  802c65:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  802c67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c6a:	5b                   	pop    %ebx
  802c6b:	5e                   	pop    %esi
  802c6c:	5f                   	pop    %edi
  802c6d:	5d                   	pop    %ebp
  802c6e:	c3                   	ret    

00802c6f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802c6f:	55                   	push   %ebp
  802c70:	89 e5                	mov    %esp,%ebp
  802c72:	53                   	push   %ebx
  802c73:	83 ec 14             	sub    $0x14,%esp
  802c76:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802c79:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802c7c:	50                   	push   %eax
  802c7d:	53                   	push   %ebx
  802c7e:	e8 ac fc ff ff       	call   80292f <fd_lookup>
  802c83:	83 c4 08             	add    $0x8,%esp
  802c86:	89 c2                	mov    %eax,%edx
  802c88:	85 c0                	test   %eax,%eax
  802c8a:	78 68                	js     802cf4 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c8c:	83 ec 08             	sub    $0x8,%esp
  802c8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c92:	50                   	push   %eax
  802c93:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c96:	ff 30                	pushl  (%eax)
  802c98:	e8 e8 fc ff ff       	call   802985 <dev_lookup>
  802c9d:	83 c4 10             	add    $0x10,%esp
  802ca0:	85 c0                	test   %eax,%eax
  802ca2:	78 47                	js     802ceb <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802ca4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802ca7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802cab:	75 21                	jne    802cce <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802cad:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802cb2:	8b 40 48             	mov    0x48(%eax),%eax
  802cb5:	83 ec 04             	sub    $0x4,%esp
  802cb8:	53                   	push   %ebx
  802cb9:	50                   	push   %eax
  802cba:	68 d4 41 80 00       	push   $0x8041d4
  802cbf:	e8 e0 ee ff ff       	call   801ba4 <cprintf>
		return -E_INVAL;
  802cc4:	83 c4 10             	add    $0x10,%esp
  802cc7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802ccc:	eb 26                	jmp    802cf4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802cce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802cd1:	8b 52 0c             	mov    0xc(%edx),%edx
  802cd4:	85 d2                	test   %edx,%edx
  802cd6:	74 17                	je     802cef <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802cd8:	83 ec 04             	sub    $0x4,%esp
  802cdb:	ff 75 10             	pushl  0x10(%ebp)
  802cde:	ff 75 0c             	pushl  0xc(%ebp)
  802ce1:	50                   	push   %eax
  802ce2:	ff d2                	call   *%edx
  802ce4:	89 c2                	mov    %eax,%edx
  802ce6:	83 c4 10             	add    $0x10,%esp
  802ce9:	eb 09                	jmp    802cf4 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802ceb:	89 c2                	mov    %eax,%edx
  802ced:	eb 05                	jmp    802cf4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802cef:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802cf4:	89 d0                	mov    %edx,%eax
  802cf6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802cf9:	c9                   	leave  
  802cfa:	c3                   	ret    

00802cfb <seek>:

int
seek(int fdnum, off_t offset)
{
  802cfb:	55                   	push   %ebp
  802cfc:	89 e5                	mov    %esp,%ebp
  802cfe:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802d01:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802d04:	50                   	push   %eax
  802d05:	ff 75 08             	pushl  0x8(%ebp)
  802d08:	e8 22 fc ff ff       	call   80292f <fd_lookup>
  802d0d:	83 c4 08             	add    $0x8,%esp
  802d10:	85 c0                	test   %eax,%eax
  802d12:	78 0e                	js     802d22 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802d14:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802d17:	8b 55 0c             	mov    0xc(%ebp),%edx
  802d1a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802d1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802d22:	c9                   	leave  
  802d23:	c3                   	ret    

00802d24 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802d24:	55                   	push   %ebp
  802d25:	89 e5                	mov    %esp,%ebp
  802d27:	53                   	push   %ebx
  802d28:	83 ec 14             	sub    $0x14,%esp
  802d2b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802d2e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d31:	50                   	push   %eax
  802d32:	53                   	push   %ebx
  802d33:	e8 f7 fb ff ff       	call   80292f <fd_lookup>
  802d38:	83 c4 08             	add    $0x8,%esp
  802d3b:	89 c2                	mov    %eax,%edx
  802d3d:	85 c0                	test   %eax,%eax
  802d3f:	78 65                	js     802da6 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d41:	83 ec 08             	sub    $0x8,%esp
  802d44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d47:	50                   	push   %eax
  802d48:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d4b:	ff 30                	pushl  (%eax)
  802d4d:	e8 33 fc ff ff       	call   802985 <dev_lookup>
  802d52:	83 c4 10             	add    $0x10,%esp
  802d55:	85 c0                	test   %eax,%eax
  802d57:	78 44                	js     802d9d <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802d59:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d5c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802d60:	75 21                	jne    802d83 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802d62:	a1 0c a0 80 00       	mov    0x80a00c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802d67:	8b 40 48             	mov    0x48(%eax),%eax
  802d6a:	83 ec 04             	sub    $0x4,%esp
  802d6d:	53                   	push   %ebx
  802d6e:	50                   	push   %eax
  802d6f:	68 94 41 80 00       	push   $0x804194
  802d74:	e8 2b ee ff ff       	call   801ba4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802d79:	83 c4 10             	add    $0x10,%esp
  802d7c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802d81:	eb 23                	jmp    802da6 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802d83:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802d86:	8b 52 18             	mov    0x18(%edx),%edx
  802d89:	85 d2                	test   %edx,%edx
  802d8b:	74 14                	je     802da1 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802d8d:	83 ec 08             	sub    $0x8,%esp
  802d90:	ff 75 0c             	pushl  0xc(%ebp)
  802d93:	50                   	push   %eax
  802d94:	ff d2                	call   *%edx
  802d96:	89 c2                	mov    %eax,%edx
  802d98:	83 c4 10             	add    $0x10,%esp
  802d9b:	eb 09                	jmp    802da6 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d9d:	89 c2                	mov    %eax,%edx
  802d9f:	eb 05                	jmp    802da6 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802da1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802da6:	89 d0                	mov    %edx,%eax
  802da8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802dab:	c9                   	leave  
  802dac:	c3                   	ret    

00802dad <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802dad:	55                   	push   %ebp
  802dae:	89 e5                	mov    %esp,%ebp
  802db0:	53                   	push   %ebx
  802db1:	83 ec 14             	sub    $0x14,%esp
  802db4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802db7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802dba:	50                   	push   %eax
  802dbb:	ff 75 08             	pushl  0x8(%ebp)
  802dbe:	e8 6c fb ff ff       	call   80292f <fd_lookup>
  802dc3:	83 c4 08             	add    $0x8,%esp
  802dc6:	89 c2                	mov    %eax,%edx
  802dc8:	85 c0                	test   %eax,%eax
  802dca:	78 58                	js     802e24 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802dcc:	83 ec 08             	sub    $0x8,%esp
  802dcf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802dd2:	50                   	push   %eax
  802dd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802dd6:	ff 30                	pushl  (%eax)
  802dd8:	e8 a8 fb ff ff       	call   802985 <dev_lookup>
  802ddd:	83 c4 10             	add    $0x10,%esp
  802de0:	85 c0                	test   %eax,%eax
  802de2:	78 37                	js     802e1b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802de4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802de7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802deb:	74 32                	je     802e1f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802ded:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802df0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802df7:	00 00 00 
	stat->st_isdir = 0;
  802dfa:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802e01:	00 00 00 
	stat->st_dev = dev;
  802e04:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802e0a:	83 ec 08             	sub    $0x8,%esp
  802e0d:	53                   	push   %ebx
  802e0e:	ff 75 f0             	pushl  -0x10(%ebp)
  802e11:	ff 50 14             	call   *0x14(%eax)
  802e14:	89 c2                	mov    %eax,%edx
  802e16:	83 c4 10             	add    $0x10,%esp
  802e19:	eb 09                	jmp    802e24 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802e1b:	89 c2                	mov    %eax,%edx
  802e1d:	eb 05                	jmp    802e24 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802e1f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802e24:	89 d0                	mov    %edx,%eax
  802e26:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e29:	c9                   	leave  
  802e2a:	c3                   	ret    

00802e2b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802e2b:	55                   	push   %ebp
  802e2c:	89 e5                	mov    %esp,%ebp
  802e2e:	56                   	push   %esi
  802e2f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802e30:	83 ec 08             	sub    $0x8,%esp
  802e33:	6a 00                	push   $0x0
  802e35:	ff 75 08             	pushl  0x8(%ebp)
  802e38:	e8 e3 01 00 00       	call   803020 <open>
  802e3d:	89 c3                	mov    %eax,%ebx
  802e3f:	83 c4 10             	add    $0x10,%esp
  802e42:	85 c0                	test   %eax,%eax
  802e44:	78 1b                	js     802e61 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802e46:	83 ec 08             	sub    $0x8,%esp
  802e49:	ff 75 0c             	pushl  0xc(%ebp)
  802e4c:	50                   	push   %eax
  802e4d:	e8 5b ff ff ff       	call   802dad <fstat>
  802e52:	89 c6                	mov    %eax,%esi
	close(fd);
  802e54:	89 1c 24             	mov    %ebx,(%esp)
  802e57:	e8 fd fb ff ff       	call   802a59 <close>
	return r;
  802e5c:	83 c4 10             	add    $0x10,%esp
  802e5f:	89 f0                	mov    %esi,%eax
}
  802e61:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802e64:	5b                   	pop    %ebx
  802e65:	5e                   	pop    %esi
  802e66:	5d                   	pop    %ebp
  802e67:	c3                   	ret    

00802e68 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802e68:	55                   	push   %ebp
  802e69:	89 e5                	mov    %esp,%ebp
  802e6b:	56                   	push   %esi
  802e6c:	53                   	push   %ebx
  802e6d:	89 c6                	mov    %eax,%esi
  802e6f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802e71:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  802e78:	75 12                	jne    802e8c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802e7a:	83 ec 0c             	sub    $0xc,%esp
  802e7d:	6a 01                	push   $0x1
  802e7f:	e8 fc f9 ff ff       	call   802880 <ipc_find_env>
  802e84:	a3 00 a0 80 00       	mov    %eax,0x80a000
  802e89:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802e8c:	6a 07                	push   $0x7
  802e8e:	68 00 b0 80 00       	push   $0x80b000
  802e93:	56                   	push   %esi
  802e94:	ff 35 00 a0 80 00    	pushl  0x80a000
  802e9a:	e8 7f f9 ff ff       	call   80281e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802e9f:	83 c4 0c             	add    $0xc,%esp
  802ea2:	6a 00                	push   $0x0
  802ea4:	53                   	push   %ebx
  802ea5:	6a 00                	push   $0x0
  802ea7:	e8 00 f9 ff ff       	call   8027ac <ipc_recv>
}
  802eac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802eaf:	5b                   	pop    %ebx
  802eb0:	5e                   	pop    %esi
  802eb1:	5d                   	pop    %ebp
  802eb2:	c3                   	ret    

00802eb3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802eb3:	55                   	push   %ebp
  802eb4:	89 e5                	mov    %esp,%ebp
  802eb6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802eb9:	8b 45 08             	mov    0x8(%ebp),%eax
  802ebc:	8b 40 0c             	mov    0xc(%eax),%eax
  802ebf:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  802ec4:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ec7:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802ecc:	ba 00 00 00 00       	mov    $0x0,%edx
  802ed1:	b8 02 00 00 00       	mov    $0x2,%eax
  802ed6:	e8 8d ff ff ff       	call   802e68 <fsipc>
}
  802edb:	c9                   	leave  
  802edc:	c3                   	ret    

00802edd <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802edd:	55                   	push   %ebp
  802ede:	89 e5                	mov    %esp,%ebp
  802ee0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802ee3:	8b 45 08             	mov    0x8(%ebp),%eax
  802ee6:	8b 40 0c             	mov    0xc(%eax),%eax
  802ee9:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  802eee:	ba 00 00 00 00       	mov    $0x0,%edx
  802ef3:	b8 06 00 00 00       	mov    $0x6,%eax
  802ef8:	e8 6b ff ff ff       	call   802e68 <fsipc>
}
  802efd:	c9                   	leave  
  802efe:	c3                   	ret    

00802eff <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802eff:	55                   	push   %ebp
  802f00:	89 e5                	mov    %esp,%ebp
  802f02:	53                   	push   %ebx
  802f03:	83 ec 04             	sub    $0x4,%esp
  802f06:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802f09:	8b 45 08             	mov    0x8(%ebp),%eax
  802f0c:	8b 40 0c             	mov    0xc(%eax),%eax
  802f0f:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802f14:	ba 00 00 00 00       	mov    $0x0,%edx
  802f19:	b8 05 00 00 00       	mov    $0x5,%eax
  802f1e:	e8 45 ff ff ff       	call   802e68 <fsipc>
  802f23:	85 c0                	test   %eax,%eax
  802f25:	78 2c                	js     802f53 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802f27:	83 ec 08             	sub    $0x8,%esp
  802f2a:	68 00 b0 80 00       	push   $0x80b000
  802f2f:	53                   	push   %ebx
  802f30:	e8 f4 f1 ff ff       	call   802129 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802f35:	a1 80 b0 80 00       	mov    0x80b080,%eax
  802f3a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802f40:	a1 84 b0 80 00       	mov    0x80b084,%eax
  802f45:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802f4b:	83 c4 10             	add    $0x10,%esp
  802f4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802f53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f56:	c9                   	leave  
  802f57:	c3                   	ret    

00802f58 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802f58:	55                   	push   %ebp
  802f59:	89 e5                	mov    %esp,%ebp
  802f5b:	83 ec 0c             	sub    $0xc,%esp
  802f5e:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802f61:	8b 55 08             	mov    0x8(%ebp),%edx
  802f64:	8b 52 0c             	mov    0xc(%edx),%edx
  802f67:	89 15 00 b0 80 00    	mov    %edx,0x80b000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  802f6d:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  802f72:	ba f8 0f 00 00       	mov    $0xff8,%edx
  802f77:	0f 47 c2             	cmova  %edx,%eax
  802f7a:	a3 04 b0 80 00       	mov    %eax,0x80b004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  802f7f:	50                   	push   %eax
  802f80:	ff 75 0c             	pushl  0xc(%ebp)
  802f83:	68 08 b0 80 00       	push   $0x80b008
  802f88:	e8 2e f3 ff ff       	call   8022bb <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  802f8d:	ba 00 00 00 00       	mov    $0x0,%edx
  802f92:	b8 04 00 00 00       	mov    $0x4,%eax
  802f97:	e8 cc fe ff ff       	call   802e68 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  802f9c:	c9                   	leave  
  802f9d:	c3                   	ret    

00802f9e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802f9e:	55                   	push   %ebp
  802f9f:	89 e5                	mov    %esp,%ebp
  802fa1:	56                   	push   %esi
  802fa2:	53                   	push   %ebx
  802fa3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802fa6:	8b 45 08             	mov    0x8(%ebp),%eax
  802fa9:	8b 40 0c             	mov    0xc(%eax),%eax
  802fac:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  802fb1:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802fb7:	ba 00 00 00 00       	mov    $0x0,%edx
  802fbc:	b8 03 00 00 00       	mov    $0x3,%eax
  802fc1:	e8 a2 fe ff ff       	call   802e68 <fsipc>
  802fc6:	89 c3                	mov    %eax,%ebx
  802fc8:	85 c0                	test   %eax,%eax
  802fca:	78 4b                	js     803017 <devfile_read+0x79>
		return r;
	assert(r <= n);
  802fcc:	39 c6                	cmp    %eax,%esi
  802fce:	73 16                	jae    802fe6 <devfile_read+0x48>
  802fd0:	68 04 42 80 00       	push   $0x804204
  802fd5:	68 bd 38 80 00       	push   $0x8038bd
  802fda:	6a 7c                	push   $0x7c
  802fdc:	68 0b 42 80 00       	push   $0x80420b
  802fe1:	e8 e5 ea ff ff       	call   801acb <_panic>
	assert(r <= PGSIZE);
  802fe6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802feb:	7e 16                	jle    803003 <devfile_read+0x65>
  802fed:	68 16 42 80 00       	push   $0x804216
  802ff2:	68 bd 38 80 00       	push   $0x8038bd
  802ff7:	6a 7d                	push   $0x7d
  802ff9:	68 0b 42 80 00       	push   $0x80420b
  802ffe:	e8 c8 ea ff ff       	call   801acb <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  803003:	83 ec 04             	sub    $0x4,%esp
  803006:	50                   	push   %eax
  803007:	68 00 b0 80 00       	push   $0x80b000
  80300c:	ff 75 0c             	pushl  0xc(%ebp)
  80300f:	e8 a7 f2 ff ff       	call   8022bb <memmove>
	return r;
  803014:	83 c4 10             	add    $0x10,%esp
}
  803017:	89 d8                	mov    %ebx,%eax
  803019:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80301c:	5b                   	pop    %ebx
  80301d:	5e                   	pop    %esi
  80301e:	5d                   	pop    %ebp
  80301f:	c3                   	ret    

00803020 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  803020:	55                   	push   %ebp
  803021:	89 e5                	mov    %esp,%ebp
  803023:	53                   	push   %ebx
  803024:	83 ec 20             	sub    $0x20,%esp
  803027:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80302a:	53                   	push   %ebx
  80302b:	e8 c0 f0 ff ff       	call   8020f0 <strlen>
  803030:	83 c4 10             	add    $0x10,%esp
  803033:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  803038:	7f 67                	jg     8030a1 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80303a:	83 ec 0c             	sub    $0xc,%esp
  80303d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803040:	50                   	push   %eax
  803041:	e8 9a f8 ff ff       	call   8028e0 <fd_alloc>
  803046:	83 c4 10             	add    $0x10,%esp
		return r;
  803049:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80304b:	85 c0                	test   %eax,%eax
  80304d:	78 57                	js     8030a6 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80304f:	83 ec 08             	sub    $0x8,%esp
  803052:	53                   	push   %ebx
  803053:	68 00 b0 80 00       	push   $0x80b000
  803058:	e8 cc f0 ff ff       	call   802129 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80305d:	8b 45 0c             	mov    0xc(%ebp),%eax
  803060:	a3 00 b4 80 00       	mov    %eax,0x80b400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  803065:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803068:	b8 01 00 00 00       	mov    $0x1,%eax
  80306d:	e8 f6 fd ff ff       	call   802e68 <fsipc>
  803072:	89 c3                	mov    %eax,%ebx
  803074:	83 c4 10             	add    $0x10,%esp
  803077:	85 c0                	test   %eax,%eax
  803079:	79 14                	jns    80308f <open+0x6f>
		fd_close(fd, 0);
  80307b:	83 ec 08             	sub    $0x8,%esp
  80307e:	6a 00                	push   $0x0
  803080:	ff 75 f4             	pushl  -0xc(%ebp)
  803083:	e8 50 f9 ff ff       	call   8029d8 <fd_close>
		return r;
  803088:	83 c4 10             	add    $0x10,%esp
  80308b:	89 da                	mov    %ebx,%edx
  80308d:	eb 17                	jmp    8030a6 <open+0x86>
	}

	return fd2num(fd);
  80308f:	83 ec 0c             	sub    $0xc,%esp
  803092:	ff 75 f4             	pushl  -0xc(%ebp)
  803095:	e8 1f f8 ff ff       	call   8028b9 <fd2num>
  80309a:	89 c2                	mov    %eax,%edx
  80309c:	83 c4 10             	add    $0x10,%esp
  80309f:	eb 05                	jmp    8030a6 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8030a1:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8030a6:	89 d0                	mov    %edx,%eax
  8030a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8030ab:	c9                   	leave  
  8030ac:	c3                   	ret    

008030ad <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8030ad:	55                   	push   %ebp
  8030ae:	89 e5                	mov    %esp,%ebp
  8030b0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8030b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8030b8:	b8 08 00 00 00       	mov    $0x8,%eax
  8030bd:	e8 a6 fd ff ff       	call   802e68 <fsipc>
}
  8030c2:	c9                   	leave  
  8030c3:	c3                   	ret    

008030c4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8030c4:	55                   	push   %ebp
  8030c5:	89 e5                	mov    %esp,%ebp
  8030c7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8030ca:	89 d0                	mov    %edx,%eax
  8030cc:	c1 e8 16             	shr    $0x16,%eax
  8030cf:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8030d6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8030db:	f6 c1 01             	test   $0x1,%cl
  8030de:	74 1d                	je     8030fd <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8030e0:	c1 ea 0c             	shr    $0xc,%edx
  8030e3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8030ea:	f6 c2 01             	test   $0x1,%dl
  8030ed:	74 0e                	je     8030fd <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8030ef:	c1 ea 0c             	shr    $0xc,%edx
  8030f2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8030f9:	ef 
  8030fa:	0f b7 c0             	movzwl %ax,%eax
}
  8030fd:	5d                   	pop    %ebp
  8030fe:	c3                   	ret    

008030ff <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8030ff:	55                   	push   %ebp
  803100:	89 e5                	mov    %esp,%ebp
  803102:	56                   	push   %esi
  803103:	53                   	push   %ebx
  803104:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  803107:	83 ec 0c             	sub    $0xc,%esp
  80310a:	ff 75 08             	pushl  0x8(%ebp)
  80310d:	e8 b7 f7 ff ff       	call   8028c9 <fd2data>
  803112:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  803114:	83 c4 08             	add    $0x8,%esp
  803117:	68 22 42 80 00       	push   $0x804222
  80311c:	53                   	push   %ebx
  80311d:	e8 07 f0 ff ff       	call   802129 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  803122:	8b 46 04             	mov    0x4(%esi),%eax
  803125:	2b 06                	sub    (%esi),%eax
  803127:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80312d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  803134:	00 00 00 
	stat->st_dev = &devpipe;
  803137:	c7 83 88 00 00 00 80 	movl   $0x809080,0x88(%ebx)
  80313e:	90 80 00 
	return 0;
}
  803141:	b8 00 00 00 00       	mov    $0x0,%eax
  803146:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803149:	5b                   	pop    %ebx
  80314a:	5e                   	pop    %esi
  80314b:	5d                   	pop    %ebp
  80314c:	c3                   	ret    

0080314d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80314d:	55                   	push   %ebp
  80314e:	89 e5                	mov    %esp,%ebp
  803150:	53                   	push   %ebx
  803151:	83 ec 0c             	sub    $0xc,%esp
  803154:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  803157:	53                   	push   %ebx
  803158:	6a 00                	push   $0x0
  80315a:	e8 52 f4 ff ff       	call   8025b1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80315f:	89 1c 24             	mov    %ebx,(%esp)
  803162:	e8 62 f7 ff ff       	call   8028c9 <fd2data>
  803167:	83 c4 08             	add    $0x8,%esp
  80316a:	50                   	push   %eax
  80316b:	6a 00                	push   $0x0
  80316d:	e8 3f f4 ff ff       	call   8025b1 <sys_page_unmap>
}
  803172:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803175:	c9                   	leave  
  803176:	c3                   	ret    

00803177 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  803177:	55                   	push   %ebp
  803178:	89 e5                	mov    %esp,%ebp
  80317a:	57                   	push   %edi
  80317b:	56                   	push   %esi
  80317c:	53                   	push   %ebx
  80317d:	83 ec 1c             	sub    $0x1c,%esp
  803180:	89 45 e0             	mov    %eax,-0x20(%ebp)
  803183:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  803185:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80318a:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80318d:	83 ec 0c             	sub    $0xc,%esp
  803190:	ff 75 e0             	pushl  -0x20(%ebp)
  803193:	e8 2c ff ff ff       	call   8030c4 <pageref>
  803198:	89 c3                	mov    %eax,%ebx
  80319a:	89 3c 24             	mov    %edi,(%esp)
  80319d:	e8 22 ff ff ff       	call   8030c4 <pageref>
  8031a2:	83 c4 10             	add    $0x10,%esp
  8031a5:	39 c3                	cmp    %eax,%ebx
  8031a7:	0f 94 c1             	sete   %cl
  8031aa:	0f b6 c9             	movzbl %cl,%ecx
  8031ad:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8031b0:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  8031b6:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8031b9:	39 ce                	cmp    %ecx,%esi
  8031bb:	74 1b                	je     8031d8 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8031bd:	39 c3                	cmp    %eax,%ebx
  8031bf:	75 c4                	jne    803185 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8031c1:	8b 42 58             	mov    0x58(%edx),%eax
  8031c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8031c7:	50                   	push   %eax
  8031c8:	56                   	push   %esi
  8031c9:	68 29 42 80 00       	push   $0x804229
  8031ce:	e8 d1 e9 ff ff       	call   801ba4 <cprintf>
  8031d3:	83 c4 10             	add    $0x10,%esp
  8031d6:	eb ad                	jmp    803185 <_pipeisclosed+0xe>
	}
}
  8031d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8031db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8031de:	5b                   	pop    %ebx
  8031df:	5e                   	pop    %esi
  8031e0:	5f                   	pop    %edi
  8031e1:	5d                   	pop    %ebp
  8031e2:	c3                   	ret    

008031e3 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8031e3:	55                   	push   %ebp
  8031e4:	89 e5                	mov    %esp,%ebp
  8031e6:	57                   	push   %edi
  8031e7:	56                   	push   %esi
  8031e8:	53                   	push   %ebx
  8031e9:	83 ec 28             	sub    $0x28,%esp
  8031ec:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8031ef:	56                   	push   %esi
  8031f0:	e8 d4 f6 ff ff       	call   8028c9 <fd2data>
  8031f5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8031f7:	83 c4 10             	add    $0x10,%esp
  8031fa:	bf 00 00 00 00       	mov    $0x0,%edi
  8031ff:	eb 4b                	jmp    80324c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  803201:	89 da                	mov    %ebx,%edx
  803203:	89 f0                	mov    %esi,%eax
  803205:	e8 6d ff ff ff       	call   803177 <_pipeisclosed>
  80320a:	85 c0                	test   %eax,%eax
  80320c:	75 48                	jne    803256 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80320e:	e8 fa f2 ff ff       	call   80250d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  803213:	8b 43 04             	mov    0x4(%ebx),%eax
  803216:	8b 0b                	mov    (%ebx),%ecx
  803218:	8d 51 20             	lea    0x20(%ecx),%edx
  80321b:	39 d0                	cmp    %edx,%eax
  80321d:	73 e2                	jae    803201 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80321f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803222:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  803226:	88 4d e7             	mov    %cl,-0x19(%ebp)
  803229:	89 c2                	mov    %eax,%edx
  80322b:	c1 fa 1f             	sar    $0x1f,%edx
  80322e:	89 d1                	mov    %edx,%ecx
  803230:	c1 e9 1b             	shr    $0x1b,%ecx
  803233:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  803236:	83 e2 1f             	and    $0x1f,%edx
  803239:	29 ca                	sub    %ecx,%edx
  80323b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80323f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  803243:	83 c0 01             	add    $0x1,%eax
  803246:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803249:	83 c7 01             	add    $0x1,%edi
  80324c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80324f:	75 c2                	jne    803213 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  803251:	8b 45 10             	mov    0x10(%ebp),%eax
  803254:	eb 05                	jmp    80325b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803256:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80325b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80325e:	5b                   	pop    %ebx
  80325f:	5e                   	pop    %esi
  803260:	5f                   	pop    %edi
  803261:	5d                   	pop    %ebp
  803262:	c3                   	ret    

00803263 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  803263:	55                   	push   %ebp
  803264:	89 e5                	mov    %esp,%ebp
  803266:	57                   	push   %edi
  803267:	56                   	push   %esi
  803268:	53                   	push   %ebx
  803269:	83 ec 18             	sub    $0x18,%esp
  80326c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80326f:	57                   	push   %edi
  803270:	e8 54 f6 ff ff       	call   8028c9 <fd2data>
  803275:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803277:	83 c4 10             	add    $0x10,%esp
  80327a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80327f:	eb 3d                	jmp    8032be <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  803281:	85 db                	test   %ebx,%ebx
  803283:	74 04                	je     803289 <devpipe_read+0x26>
				return i;
  803285:	89 d8                	mov    %ebx,%eax
  803287:	eb 44                	jmp    8032cd <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  803289:	89 f2                	mov    %esi,%edx
  80328b:	89 f8                	mov    %edi,%eax
  80328d:	e8 e5 fe ff ff       	call   803177 <_pipeisclosed>
  803292:	85 c0                	test   %eax,%eax
  803294:	75 32                	jne    8032c8 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  803296:	e8 72 f2 ff ff       	call   80250d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80329b:	8b 06                	mov    (%esi),%eax
  80329d:	3b 46 04             	cmp    0x4(%esi),%eax
  8032a0:	74 df                	je     803281 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8032a2:	99                   	cltd   
  8032a3:	c1 ea 1b             	shr    $0x1b,%edx
  8032a6:	01 d0                	add    %edx,%eax
  8032a8:	83 e0 1f             	and    $0x1f,%eax
  8032ab:	29 d0                	sub    %edx,%eax
  8032ad:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8032b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8032b5:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8032b8:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8032bb:	83 c3 01             	add    $0x1,%ebx
  8032be:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8032c1:	75 d8                	jne    80329b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8032c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8032c6:	eb 05                	jmp    8032cd <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8032c8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8032cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8032d0:	5b                   	pop    %ebx
  8032d1:	5e                   	pop    %esi
  8032d2:	5f                   	pop    %edi
  8032d3:	5d                   	pop    %ebp
  8032d4:	c3                   	ret    

008032d5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8032d5:	55                   	push   %ebp
  8032d6:	89 e5                	mov    %esp,%ebp
  8032d8:	56                   	push   %esi
  8032d9:	53                   	push   %ebx
  8032da:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8032dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8032e0:	50                   	push   %eax
  8032e1:	e8 fa f5 ff ff       	call   8028e0 <fd_alloc>
  8032e6:	83 c4 10             	add    $0x10,%esp
  8032e9:	89 c2                	mov    %eax,%edx
  8032eb:	85 c0                	test   %eax,%eax
  8032ed:	0f 88 2c 01 00 00    	js     80341f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8032f3:	83 ec 04             	sub    $0x4,%esp
  8032f6:	68 07 04 00 00       	push   $0x407
  8032fb:	ff 75 f4             	pushl  -0xc(%ebp)
  8032fe:	6a 00                	push   $0x0
  803300:	e8 27 f2 ff ff       	call   80252c <sys_page_alloc>
  803305:	83 c4 10             	add    $0x10,%esp
  803308:	89 c2                	mov    %eax,%edx
  80330a:	85 c0                	test   %eax,%eax
  80330c:	0f 88 0d 01 00 00    	js     80341f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  803312:	83 ec 0c             	sub    $0xc,%esp
  803315:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803318:	50                   	push   %eax
  803319:	e8 c2 f5 ff ff       	call   8028e0 <fd_alloc>
  80331e:	89 c3                	mov    %eax,%ebx
  803320:	83 c4 10             	add    $0x10,%esp
  803323:	85 c0                	test   %eax,%eax
  803325:	0f 88 e2 00 00 00    	js     80340d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80332b:	83 ec 04             	sub    $0x4,%esp
  80332e:	68 07 04 00 00       	push   $0x407
  803333:	ff 75 f0             	pushl  -0x10(%ebp)
  803336:	6a 00                	push   $0x0
  803338:	e8 ef f1 ff ff       	call   80252c <sys_page_alloc>
  80333d:	89 c3                	mov    %eax,%ebx
  80333f:	83 c4 10             	add    $0x10,%esp
  803342:	85 c0                	test   %eax,%eax
  803344:	0f 88 c3 00 00 00    	js     80340d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80334a:	83 ec 0c             	sub    $0xc,%esp
  80334d:	ff 75 f4             	pushl  -0xc(%ebp)
  803350:	e8 74 f5 ff ff       	call   8028c9 <fd2data>
  803355:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803357:	83 c4 0c             	add    $0xc,%esp
  80335a:	68 07 04 00 00       	push   $0x407
  80335f:	50                   	push   %eax
  803360:	6a 00                	push   $0x0
  803362:	e8 c5 f1 ff ff       	call   80252c <sys_page_alloc>
  803367:	89 c3                	mov    %eax,%ebx
  803369:	83 c4 10             	add    $0x10,%esp
  80336c:	85 c0                	test   %eax,%eax
  80336e:	0f 88 89 00 00 00    	js     8033fd <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803374:	83 ec 0c             	sub    $0xc,%esp
  803377:	ff 75 f0             	pushl  -0x10(%ebp)
  80337a:	e8 4a f5 ff ff       	call   8028c9 <fd2data>
  80337f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  803386:	50                   	push   %eax
  803387:	6a 00                	push   $0x0
  803389:	56                   	push   %esi
  80338a:	6a 00                	push   $0x0
  80338c:	e8 de f1 ff ff       	call   80256f <sys_page_map>
  803391:	89 c3                	mov    %eax,%ebx
  803393:	83 c4 20             	add    $0x20,%esp
  803396:	85 c0                	test   %eax,%eax
  803398:	78 55                	js     8033ef <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80339a:	8b 15 80 90 80 00    	mov    0x809080,%edx
  8033a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8033a3:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8033a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8033a8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8033af:	8b 15 80 90 80 00    	mov    0x809080,%edx
  8033b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8033b8:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8033ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8033bd:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8033c4:	83 ec 0c             	sub    $0xc,%esp
  8033c7:	ff 75 f4             	pushl  -0xc(%ebp)
  8033ca:	e8 ea f4 ff ff       	call   8028b9 <fd2num>
  8033cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8033d2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8033d4:	83 c4 04             	add    $0x4,%esp
  8033d7:	ff 75 f0             	pushl  -0x10(%ebp)
  8033da:	e8 da f4 ff ff       	call   8028b9 <fd2num>
  8033df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8033e2:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8033e5:	83 c4 10             	add    $0x10,%esp
  8033e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8033ed:	eb 30                	jmp    80341f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8033ef:	83 ec 08             	sub    $0x8,%esp
  8033f2:	56                   	push   %esi
  8033f3:	6a 00                	push   $0x0
  8033f5:	e8 b7 f1 ff ff       	call   8025b1 <sys_page_unmap>
  8033fa:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8033fd:	83 ec 08             	sub    $0x8,%esp
  803400:	ff 75 f0             	pushl  -0x10(%ebp)
  803403:	6a 00                	push   $0x0
  803405:	e8 a7 f1 ff ff       	call   8025b1 <sys_page_unmap>
  80340a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80340d:	83 ec 08             	sub    $0x8,%esp
  803410:	ff 75 f4             	pushl  -0xc(%ebp)
  803413:	6a 00                	push   $0x0
  803415:	e8 97 f1 ff ff       	call   8025b1 <sys_page_unmap>
  80341a:	83 c4 10             	add    $0x10,%esp
  80341d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80341f:	89 d0                	mov    %edx,%eax
  803421:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803424:	5b                   	pop    %ebx
  803425:	5e                   	pop    %esi
  803426:	5d                   	pop    %ebp
  803427:	c3                   	ret    

00803428 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  803428:	55                   	push   %ebp
  803429:	89 e5                	mov    %esp,%ebp
  80342b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80342e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803431:	50                   	push   %eax
  803432:	ff 75 08             	pushl  0x8(%ebp)
  803435:	e8 f5 f4 ff ff       	call   80292f <fd_lookup>
  80343a:	83 c4 10             	add    $0x10,%esp
  80343d:	85 c0                	test   %eax,%eax
  80343f:	78 18                	js     803459 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  803441:	83 ec 0c             	sub    $0xc,%esp
  803444:	ff 75 f4             	pushl  -0xc(%ebp)
  803447:	e8 7d f4 ff ff       	call   8028c9 <fd2data>
	return _pipeisclosed(fd, p);
  80344c:	89 c2                	mov    %eax,%edx
  80344e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803451:	e8 21 fd ff ff       	call   803177 <_pipeisclosed>
  803456:	83 c4 10             	add    $0x10,%esp
}
  803459:	c9                   	leave  
  80345a:	c3                   	ret    

0080345b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80345b:	55                   	push   %ebp
  80345c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80345e:	b8 00 00 00 00       	mov    $0x0,%eax
  803463:	5d                   	pop    %ebp
  803464:	c3                   	ret    

00803465 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  803465:	55                   	push   %ebp
  803466:	89 e5                	mov    %esp,%ebp
  803468:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80346b:	68 41 42 80 00       	push   $0x804241
  803470:	ff 75 0c             	pushl  0xc(%ebp)
  803473:	e8 b1 ec ff ff       	call   802129 <strcpy>
	return 0;
}
  803478:	b8 00 00 00 00       	mov    $0x0,%eax
  80347d:	c9                   	leave  
  80347e:	c3                   	ret    

0080347f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80347f:	55                   	push   %ebp
  803480:	89 e5                	mov    %esp,%ebp
  803482:	57                   	push   %edi
  803483:	56                   	push   %esi
  803484:	53                   	push   %ebx
  803485:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80348b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  803490:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803496:	eb 2d                	jmp    8034c5 <devcons_write+0x46>
		m = n - tot;
  803498:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80349b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80349d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8034a0:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8034a5:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8034a8:	83 ec 04             	sub    $0x4,%esp
  8034ab:	53                   	push   %ebx
  8034ac:	03 45 0c             	add    0xc(%ebp),%eax
  8034af:	50                   	push   %eax
  8034b0:	57                   	push   %edi
  8034b1:	e8 05 ee ff ff       	call   8022bb <memmove>
		sys_cputs(buf, m);
  8034b6:	83 c4 08             	add    $0x8,%esp
  8034b9:	53                   	push   %ebx
  8034ba:	57                   	push   %edi
  8034bb:	e8 b0 ef ff ff       	call   802470 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8034c0:	01 de                	add    %ebx,%esi
  8034c2:	83 c4 10             	add    $0x10,%esp
  8034c5:	89 f0                	mov    %esi,%eax
  8034c7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8034ca:	72 cc                	jb     803498 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8034cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8034cf:	5b                   	pop    %ebx
  8034d0:	5e                   	pop    %esi
  8034d1:	5f                   	pop    %edi
  8034d2:	5d                   	pop    %ebp
  8034d3:	c3                   	ret    

008034d4 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8034d4:	55                   	push   %ebp
  8034d5:	89 e5                	mov    %esp,%ebp
  8034d7:	83 ec 08             	sub    $0x8,%esp
  8034da:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8034df:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8034e3:	74 2a                	je     80350f <devcons_read+0x3b>
  8034e5:	eb 05                	jmp    8034ec <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8034e7:	e8 21 f0 ff ff       	call   80250d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8034ec:	e8 9d ef ff ff       	call   80248e <sys_cgetc>
  8034f1:	85 c0                	test   %eax,%eax
  8034f3:	74 f2                	je     8034e7 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8034f5:	85 c0                	test   %eax,%eax
  8034f7:	78 16                	js     80350f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8034f9:	83 f8 04             	cmp    $0x4,%eax
  8034fc:	74 0c                	je     80350a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8034fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  803501:	88 02                	mov    %al,(%edx)
	return 1;
  803503:	b8 01 00 00 00       	mov    $0x1,%eax
  803508:	eb 05                	jmp    80350f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80350a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80350f:	c9                   	leave  
  803510:	c3                   	ret    

00803511 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  803511:	55                   	push   %ebp
  803512:	89 e5                	mov    %esp,%ebp
  803514:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  803517:	8b 45 08             	mov    0x8(%ebp),%eax
  80351a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80351d:	6a 01                	push   $0x1
  80351f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803522:	50                   	push   %eax
  803523:	e8 48 ef ff ff       	call   802470 <sys_cputs>
}
  803528:	83 c4 10             	add    $0x10,%esp
  80352b:	c9                   	leave  
  80352c:	c3                   	ret    

0080352d <getchar>:

int
getchar(void)
{
  80352d:	55                   	push   %ebp
  80352e:	89 e5                	mov    %esp,%ebp
  803530:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  803533:	6a 01                	push   $0x1
  803535:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803538:	50                   	push   %eax
  803539:	6a 00                	push   $0x0
  80353b:	e8 55 f6 ff ff       	call   802b95 <read>
	if (r < 0)
  803540:	83 c4 10             	add    $0x10,%esp
  803543:	85 c0                	test   %eax,%eax
  803545:	78 0f                	js     803556 <getchar+0x29>
		return r;
	if (r < 1)
  803547:	85 c0                	test   %eax,%eax
  803549:	7e 06                	jle    803551 <getchar+0x24>
		return -E_EOF;
	return c;
  80354b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80354f:	eb 05                	jmp    803556 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  803551:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  803556:	c9                   	leave  
  803557:	c3                   	ret    

00803558 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  803558:	55                   	push   %ebp
  803559:	89 e5                	mov    %esp,%ebp
  80355b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80355e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803561:	50                   	push   %eax
  803562:	ff 75 08             	pushl  0x8(%ebp)
  803565:	e8 c5 f3 ff ff       	call   80292f <fd_lookup>
  80356a:	83 c4 10             	add    $0x10,%esp
  80356d:	85 c0                	test   %eax,%eax
  80356f:	78 11                	js     803582 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  803571:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803574:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  80357a:	39 10                	cmp    %edx,(%eax)
  80357c:	0f 94 c0             	sete   %al
  80357f:	0f b6 c0             	movzbl %al,%eax
}
  803582:	c9                   	leave  
  803583:	c3                   	ret    

00803584 <opencons>:

int
opencons(void)
{
  803584:	55                   	push   %ebp
  803585:	89 e5                	mov    %esp,%ebp
  803587:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80358a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80358d:	50                   	push   %eax
  80358e:	e8 4d f3 ff ff       	call   8028e0 <fd_alloc>
  803593:	83 c4 10             	add    $0x10,%esp
		return r;
  803596:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  803598:	85 c0                	test   %eax,%eax
  80359a:	78 3e                	js     8035da <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80359c:	83 ec 04             	sub    $0x4,%esp
  80359f:	68 07 04 00 00       	push   $0x407
  8035a4:	ff 75 f4             	pushl  -0xc(%ebp)
  8035a7:	6a 00                	push   $0x0
  8035a9:	e8 7e ef ff ff       	call   80252c <sys_page_alloc>
  8035ae:	83 c4 10             	add    $0x10,%esp
		return r;
  8035b1:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8035b3:	85 c0                	test   %eax,%eax
  8035b5:	78 23                	js     8035da <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8035b7:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  8035bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8035c0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8035c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8035c5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8035cc:	83 ec 0c             	sub    $0xc,%esp
  8035cf:	50                   	push   %eax
  8035d0:	e8 e4 f2 ff ff       	call   8028b9 <fd2num>
  8035d5:	89 c2                	mov    %eax,%edx
  8035d7:	83 c4 10             	add    $0x10,%esp
}
  8035da:	89 d0                	mov    %edx,%eax
  8035dc:	c9                   	leave  
  8035dd:	c3                   	ret    
  8035de:	66 90                	xchg   %ax,%ax

008035e0 <__udivdi3>:
  8035e0:	55                   	push   %ebp
  8035e1:	57                   	push   %edi
  8035e2:	56                   	push   %esi
  8035e3:	53                   	push   %ebx
  8035e4:	83 ec 1c             	sub    $0x1c,%esp
  8035e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8035eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8035ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8035f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8035f7:	85 f6                	test   %esi,%esi
  8035f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8035fd:	89 ca                	mov    %ecx,%edx
  8035ff:	89 f8                	mov    %edi,%eax
  803601:	75 3d                	jne    803640 <__udivdi3+0x60>
  803603:	39 cf                	cmp    %ecx,%edi
  803605:	0f 87 c5 00 00 00    	ja     8036d0 <__udivdi3+0xf0>
  80360b:	85 ff                	test   %edi,%edi
  80360d:	89 fd                	mov    %edi,%ebp
  80360f:	75 0b                	jne    80361c <__udivdi3+0x3c>
  803611:	b8 01 00 00 00       	mov    $0x1,%eax
  803616:	31 d2                	xor    %edx,%edx
  803618:	f7 f7                	div    %edi
  80361a:	89 c5                	mov    %eax,%ebp
  80361c:	89 c8                	mov    %ecx,%eax
  80361e:	31 d2                	xor    %edx,%edx
  803620:	f7 f5                	div    %ebp
  803622:	89 c1                	mov    %eax,%ecx
  803624:	89 d8                	mov    %ebx,%eax
  803626:	89 cf                	mov    %ecx,%edi
  803628:	f7 f5                	div    %ebp
  80362a:	89 c3                	mov    %eax,%ebx
  80362c:	89 d8                	mov    %ebx,%eax
  80362e:	89 fa                	mov    %edi,%edx
  803630:	83 c4 1c             	add    $0x1c,%esp
  803633:	5b                   	pop    %ebx
  803634:	5e                   	pop    %esi
  803635:	5f                   	pop    %edi
  803636:	5d                   	pop    %ebp
  803637:	c3                   	ret    
  803638:	90                   	nop
  803639:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803640:	39 ce                	cmp    %ecx,%esi
  803642:	77 74                	ja     8036b8 <__udivdi3+0xd8>
  803644:	0f bd fe             	bsr    %esi,%edi
  803647:	83 f7 1f             	xor    $0x1f,%edi
  80364a:	0f 84 98 00 00 00    	je     8036e8 <__udivdi3+0x108>
  803650:	bb 20 00 00 00       	mov    $0x20,%ebx
  803655:	89 f9                	mov    %edi,%ecx
  803657:	89 c5                	mov    %eax,%ebp
  803659:	29 fb                	sub    %edi,%ebx
  80365b:	d3 e6                	shl    %cl,%esi
  80365d:	89 d9                	mov    %ebx,%ecx
  80365f:	d3 ed                	shr    %cl,%ebp
  803661:	89 f9                	mov    %edi,%ecx
  803663:	d3 e0                	shl    %cl,%eax
  803665:	09 ee                	or     %ebp,%esi
  803667:	89 d9                	mov    %ebx,%ecx
  803669:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80366d:	89 d5                	mov    %edx,%ebp
  80366f:	8b 44 24 08          	mov    0x8(%esp),%eax
  803673:	d3 ed                	shr    %cl,%ebp
  803675:	89 f9                	mov    %edi,%ecx
  803677:	d3 e2                	shl    %cl,%edx
  803679:	89 d9                	mov    %ebx,%ecx
  80367b:	d3 e8                	shr    %cl,%eax
  80367d:	09 c2                	or     %eax,%edx
  80367f:	89 d0                	mov    %edx,%eax
  803681:	89 ea                	mov    %ebp,%edx
  803683:	f7 f6                	div    %esi
  803685:	89 d5                	mov    %edx,%ebp
  803687:	89 c3                	mov    %eax,%ebx
  803689:	f7 64 24 0c          	mull   0xc(%esp)
  80368d:	39 d5                	cmp    %edx,%ebp
  80368f:	72 10                	jb     8036a1 <__udivdi3+0xc1>
  803691:	8b 74 24 08          	mov    0x8(%esp),%esi
  803695:	89 f9                	mov    %edi,%ecx
  803697:	d3 e6                	shl    %cl,%esi
  803699:	39 c6                	cmp    %eax,%esi
  80369b:	73 07                	jae    8036a4 <__udivdi3+0xc4>
  80369d:	39 d5                	cmp    %edx,%ebp
  80369f:	75 03                	jne    8036a4 <__udivdi3+0xc4>
  8036a1:	83 eb 01             	sub    $0x1,%ebx
  8036a4:	31 ff                	xor    %edi,%edi
  8036a6:	89 d8                	mov    %ebx,%eax
  8036a8:	89 fa                	mov    %edi,%edx
  8036aa:	83 c4 1c             	add    $0x1c,%esp
  8036ad:	5b                   	pop    %ebx
  8036ae:	5e                   	pop    %esi
  8036af:	5f                   	pop    %edi
  8036b0:	5d                   	pop    %ebp
  8036b1:	c3                   	ret    
  8036b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8036b8:	31 ff                	xor    %edi,%edi
  8036ba:	31 db                	xor    %ebx,%ebx
  8036bc:	89 d8                	mov    %ebx,%eax
  8036be:	89 fa                	mov    %edi,%edx
  8036c0:	83 c4 1c             	add    $0x1c,%esp
  8036c3:	5b                   	pop    %ebx
  8036c4:	5e                   	pop    %esi
  8036c5:	5f                   	pop    %edi
  8036c6:	5d                   	pop    %ebp
  8036c7:	c3                   	ret    
  8036c8:	90                   	nop
  8036c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8036d0:	89 d8                	mov    %ebx,%eax
  8036d2:	f7 f7                	div    %edi
  8036d4:	31 ff                	xor    %edi,%edi
  8036d6:	89 c3                	mov    %eax,%ebx
  8036d8:	89 d8                	mov    %ebx,%eax
  8036da:	89 fa                	mov    %edi,%edx
  8036dc:	83 c4 1c             	add    $0x1c,%esp
  8036df:	5b                   	pop    %ebx
  8036e0:	5e                   	pop    %esi
  8036e1:	5f                   	pop    %edi
  8036e2:	5d                   	pop    %ebp
  8036e3:	c3                   	ret    
  8036e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8036e8:	39 ce                	cmp    %ecx,%esi
  8036ea:	72 0c                	jb     8036f8 <__udivdi3+0x118>
  8036ec:	31 db                	xor    %ebx,%ebx
  8036ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8036f2:	0f 87 34 ff ff ff    	ja     80362c <__udivdi3+0x4c>
  8036f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8036fd:	e9 2a ff ff ff       	jmp    80362c <__udivdi3+0x4c>
  803702:	66 90                	xchg   %ax,%ax
  803704:	66 90                	xchg   %ax,%ax
  803706:	66 90                	xchg   %ax,%ax
  803708:	66 90                	xchg   %ax,%ax
  80370a:	66 90                	xchg   %ax,%ax
  80370c:	66 90                	xchg   %ax,%ax
  80370e:	66 90                	xchg   %ax,%ax

00803710 <__umoddi3>:
  803710:	55                   	push   %ebp
  803711:	57                   	push   %edi
  803712:	56                   	push   %esi
  803713:	53                   	push   %ebx
  803714:	83 ec 1c             	sub    $0x1c,%esp
  803717:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80371b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80371f:	8b 74 24 34          	mov    0x34(%esp),%esi
  803723:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803727:	85 d2                	test   %edx,%edx
  803729:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80372d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803731:	89 f3                	mov    %esi,%ebx
  803733:	89 3c 24             	mov    %edi,(%esp)
  803736:	89 74 24 04          	mov    %esi,0x4(%esp)
  80373a:	75 1c                	jne    803758 <__umoddi3+0x48>
  80373c:	39 f7                	cmp    %esi,%edi
  80373e:	76 50                	jbe    803790 <__umoddi3+0x80>
  803740:	89 c8                	mov    %ecx,%eax
  803742:	89 f2                	mov    %esi,%edx
  803744:	f7 f7                	div    %edi
  803746:	89 d0                	mov    %edx,%eax
  803748:	31 d2                	xor    %edx,%edx
  80374a:	83 c4 1c             	add    $0x1c,%esp
  80374d:	5b                   	pop    %ebx
  80374e:	5e                   	pop    %esi
  80374f:	5f                   	pop    %edi
  803750:	5d                   	pop    %ebp
  803751:	c3                   	ret    
  803752:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803758:	39 f2                	cmp    %esi,%edx
  80375a:	89 d0                	mov    %edx,%eax
  80375c:	77 52                	ja     8037b0 <__umoddi3+0xa0>
  80375e:	0f bd ea             	bsr    %edx,%ebp
  803761:	83 f5 1f             	xor    $0x1f,%ebp
  803764:	75 5a                	jne    8037c0 <__umoddi3+0xb0>
  803766:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80376a:	0f 82 e0 00 00 00    	jb     803850 <__umoddi3+0x140>
  803770:	39 0c 24             	cmp    %ecx,(%esp)
  803773:	0f 86 d7 00 00 00    	jbe    803850 <__umoddi3+0x140>
  803779:	8b 44 24 08          	mov    0x8(%esp),%eax
  80377d:	8b 54 24 04          	mov    0x4(%esp),%edx
  803781:	83 c4 1c             	add    $0x1c,%esp
  803784:	5b                   	pop    %ebx
  803785:	5e                   	pop    %esi
  803786:	5f                   	pop    %edi
  803787:	5d                   	pop    %ebp
  803788:	c3                   	ret    
  803789:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803790:	85 ff                	test   %edi,%edi
  803792:	89 fd                	mov    %edi,%ebp
  803794:	75 0b                	jne    8037a1 <__umoddi3+0x91>
  803796:	b8 01 00 00 00       	mov    $0x1,%eax
  80379b:	31 d2                	xor    %edx,%edx
  80379d:	f7 f7                	div    %edi
  80379f:	89 c5                	mov    %eax,%ebp
  8037a1:	89 f0                	mov    %esi,%eax
  8037a3:	31 d2                	xor    %edx,%edx
  8037a5:	f7 f5                	div    %ebp
  8037a7:	89 c8                	mov    %ecx,%eax
  8037a9:	f7 f5                	div    %ebp
  8037ab:	89 d0                	mov    %edx,%eax
  8037ad:	eb 99                	jmp    803748 <__umoddi3+0x38>
  8037af:	90                   	nop
  8037b0:	89 c8                	mov    %ecx,%eax
  8037b2:	89 f2                	mov    %esi,%edx
  8037b4:	83 c4 1c             	add    $0x1c,%esp
  8037b7:	5b                   	pop    %ebx
  8037b8:	5e                   	pop    %esi
  8037b9:	5f                   	pop    %edi
  8037ba:	5d                   	pop    %ebp
  8037bb:	c3                   	ret    
  8037bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8037c0:	8b 34 24             	mov    (%esp),%esi
  8037c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8037c8:	89 e9                	mov    %ebp,%ecx
  8037ca:	29 ef                	sub    %ebp,%edi
  8037cc:	d3 e0                	shl    %cl,%eax
  8037ce:	89 f9                	mov    %edi,%ecx
  8037d0:	89 f2                	mov    %esi,%edx
  8037d2:	d3 ea                	shr    %cl,%edx
  8037d4:	89 e9                	mov    %ebp,%ecx
  8037d6:	09 c2                	or     %eax,%edx
  8037d8:	89 d8                	mov    %ebx,%eax
  8037da:	89 14 24             	mov    %edx,(%esp)
  8037dd:	89 f2                	mov    %esi,%edx
  8037df:	d3 e2                	shl    %cl,%edx
  8037e1:	89 f9                	mov    %edi,%ecx
  8037e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8037e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8037eb:	d3 e8                	shr    %cl,%eax
  8037ed:	89 e9                	mov    %ebp,%ecx
  8037ef:	89 c6                	mov    %eax,%esi
  8037f1:	d3 e3                	shl    %cl,%ebx
  8037f3:	89 f9                	mov    %edi,%ecx
  8037f5:	89 d0                	mov    %edx,%eax
  8037f7:	d3 e8                	shr    %cl,%eax
  8037f9:	89 e9                	mov    %ebp,%ecx
  8037fb:	09 d8                	or     %ebx,%eax
  8037fd:	89 d3                	mov    %edx,%ebx
  8037ff:	89 f2                	mov    %esi,%edx
  803801:	f7 34 24             	divl   (%esp)
  803804:	89 d6                	mov    %edx,%esi
  803806:	d3 e3                	shl    %cl,%ebx
  803808:	f7 64 24 04          	mull   0x4(%esp)
  80380c:	39 d6                	cmp    %edx,%esi
  80380e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803812:	89 d1                	mov    %edx,%ecx
  803814:	89 c3                	mov    %eax,%ebx
  803816:	72 08                	jb     803820 <__umoddi3+0x110>
  803818:	75 11                	jne    80382b <__umoddi3+0x11b>
  80381a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80381e:	73 0b                	jae    80382b <__umoddi3+0x11b>
  803820:	2b 44 24 04          	sub    0x4(%esp),%eax
  803824:	1b 14 24             	sbb    (%esp),%edx
  803827:	89 d1                	mov    %edx,%ecx
  803829:	89 c3                	mov    %eax,%ebx
  80382b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80382f:	29 da                	sub    %ebx,%edx
  803831:	19 ce                	sbb    %ecx,%esi
  803833:	89 f9                	mov    %edi,%ecx
  803835:	89 f0                	mov    %esi,%eax
  803837:	d3 e0                	shl    %cl,%eax
  803839:	89 e9                	mov    %ebp,%ecx
  80383b:	d3 ea                	shr    %cl,%edx
  80383d:	89 e9                	mov    %ebp,%ecx
  80383f:	d3 ee                	shr    %cl,%esi
  803841:	09 d0                	or     %edx,%eax
  803843:	89 f2                	mov    %esi,%edx
  803845:	83 c4 1c             	add    $0x1c,%esp
  803848:	5b                   	pop    %ebx
  803849:	5e                   	pop    %esi
  80384a:	5f                   	pop    %edi
  80384b:	5d                   	pop    %ebp
  80384c:	c3                   	ret    
  80384d:	8d 76 00             	lea    0x0(%esi),%esi
  803850:	29 f9                	sub    %edi,%ecx
  803852:	19 d6                	sbb    %edx,%esi
  803854:	89 74 24 04          	mov    %esi,0x4(%esp)
  803858:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80385c:	e9 18 ff ff ff       	jmp    803779 <__umoddi3+0x69>
