
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
  8000b2:	68 a0 3b 80 00       	push   $0x803ba0
  8000b7:	e8 c4 1a 00 00       	call   801b80 <cprintf>
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
  8000d4:	68 b7 3b 80 00       	push   $0x803bb7
  8000d9:	6a 3a                	push   $0x3a
  8000db:	68 c7 3b 80 00       	push   $0x803bc7
  8000e0:	e8 c2 19 00 00       	call   801aa7 <_panic>
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
  800106:	68 d0 3b 80 00       	push   $0x803bd0
  80010b:	68 dd 3b 80 00       	push   $0x803bdd
  800110:	6a 44                	push   $0x44
  800112:	68 c7 3b 80 00       	push   $0x803bc7
  800117:	e8 8b 19 00 00       	call   801aa7 <_panic>

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
  8001ca:	68 d0 3b 80 00       	push   $0x803bd0
  8001cf:	68 dd 3b 80 00       	push   $0x803bdd
  8001d4:	6a 5d                	push   $0x5d
  8001d6:	68 c7 3b 80 00       	push   $0x803bc7
  8001db:	e8 c7 18 00 00       	call   801aa7 <_panic>

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
  80029a:	68 f4 3b 80 00       	push   $0x803bf4
  80029f:	6a 27                	push   $0x27
  8002a1:	68 b0 3c 80 00       	push   $0x803cb0
  8002a6:	e8 fc 17 00 00       	call   801aa7 <_panic>
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
  8002ba:	68 24 3c 80 00       	push   $0x803c24
  8002bf:	6a 2b                	push   $0x2b
  8002c1:	68 b0 3c 80 00       	push   $0x803cb0
  8002c6:	e8 dc 17 00 00       	call   801aa7 <_panic>
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
  8002d9:	e8 2a 22 00 00       	call   802508 <sys_page_alloc>

	if (r < 0) {
  8002de:	83 c4 10             	add    $0x10,%esp
  8002e1:	85 c0                	test   %eax,%eax
  8002e3:	79 12                	jns    8002f7 <bc_pgfault+0x83>
		panic("page alloc fault - %e", r);
  8002e5:	50                   	push   %eax
  8002e6:	68 b8 3c 80 00       	push   $0x803cb8
  8002eb:	6a 37                	push   $0x37
  8002ed:	68 b0 3c 80 00       	push   $0x803cb0
  8002f2:	e8 b0 17 00 00       	call   801aa7 <_panic>
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
  800312:	68 ce 3c 80 00       	push   $0x803cce
  800317:	6a 3d                	push   $0x3d
  800319:	68 b0 3c 80 00       	push   $0x803cb0
  80031e:	e8 84 17 00 00       	call   801aa7 <_panic>
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
  80033e:	e8 08 22 00 00       	call   80254b <sys_page_map>
  800343:	83 c4 20             	add    $0x20,%esp
  800346:	85 c0                	test   %eax,%eax
  800348:	79 12                	jns    80035c <bc_pgfault+0xe8>
		panic("in bc_pgfault, sys_page_map: %e", r);
  80034a:	50                   	push   %eax
  80034b:	68 48 3c 80 00       	push   $0x803c48
  800350:	6a 43                	push   $0x43
  800352:	68 b0 3c 80 00       	push   $0x803cb0
  800357:	e8 4b 17 00 00       	call   801aa7 <_panic>

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
  800376:	68 e2 3c 80 00       	push   $0x803ce2
  80037b:	6a 49                	push   $0x49
  80037d:	68 b0 3c 80 00       	push   $0x803cb0
  800382:	e8 20 17 00 00       	call   801aa7 <_panic>
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
  8003ab:	68 68 3c 80 00       	push   $0x803c68
  8003b0:	6a 09                	push   $0x9
  8003b2:	68 b0 3c 80 00       	push   $0x803cb0
  8003b7:	e8 eb 16 00 00       	call   801aa7 <_panic>
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
  800422:	68 fb 3c 80 00       	push   $0x803cfb
  800427:	6a 59                	push   $0x59
  800429:	68 b0 3c 80 00       	push   $0x803cb0
  80042e:	e8 74 16 00 00       	call   801aa7 <_panic>

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
  80048d:	e8 b9 20 00 00       	call   80254b <sys_page_map>
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
  8004ab:	e8 89 22 00 00       	call   802739 <set_pgfault_handler>
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
  8004cc:	e8 c6 1d 00 00       	call   802297 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  8004d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004d8:	e8 b1 fe ff ff       	call   80038e <diskaddr>
  8004dd:	83 c4 08             	add    $0x8,%esp
  8004e0:	68 16 3d 80 00       	push   $0x803d16
  8004e5:	50                   	push   %eax
  8004e6:	e8 1a 1c 00 00       	call   802105 <strcpy>
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
  80051a:	68 38 3d 80 00       	push   $0x803d38
  80051f:	68 dd 3b 80 00       	push   $0x803bdd
  800524:	6a 72                	push   $0x72
  800526:	68 b0 3c 80 00       	push   $0x803cb0
  80052b:	e8 77 15 00 00       	call   801aa7 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  800530:	83 ec 0c             	sub    $0xc,%esp
  800533:	6a 01                	push   $0x1
  800535:	e8 54 fe ff ff       	call   80038e <diskaddr>
  80053a:	89 04 24             	mov    %eax,(%esp)
  80053d:	e8 b2 fe ff ff       	call   8003f4 <va_is_dirty>
  800542:	83 c4 10             	add    $0x10,%esp
  800545:	84 c0                	test   %al,%al
  800547:	74 16                	je     80055f <bc_init+0xc3>
  800549:	68 1d 3d 80 00       	push   $0x803d1d
  80054e:	68 dd 3b 80 00       	push   $0x803bdd
  800553:	6a 73                	push   $0x73
  800555:	68 b0 3c 80 00       	push   $0x803cb0
  80055a:	e8 48 15 00 00       	call   801aa7 <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  80055f:	83 ec 0c             	sub    $0xc,%esp
  800562:	6a 01                	push   $0x1
  800564:	e8 25 fe ff ff       	call   80038e <diskaddr>
  800569:	83 c4 08             	add    $0x8,%esp
  80056c:	50                   	push   %eax
  80056d:	6a 00                	push   $0x0
  80056f:	e8 19 20 00 00       	call   80258d <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  800574:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80057b:	e8 0e fe ff ff       	call   80038e <diskaddr>
  800580:	89 04 24             	mov    %eax,(%esp)
  800583:	e8 3e fe ff ff       	call   8003c6 <va_is_mapped>
  800588:	83 c4 10             	add    $0x10,%esp
  80058b:	84 c0                	test   %al,%al
  80058d:	74 16                	je     8005a5 <bc_init+0x109>
  80058f:	68 37 3d 80 00       	push   $0x803d37
  800594:	68 dd 3b 80 00       	push   $0x803bdd
  800599:	6a 77                	push   $0x77
  80059b:	68 b0 3c 80 00       	push   $0x803cb0
  8005a0:	e8 02 15 00 00       	call   801aa7 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8005a5:	83 ec 0c             	sub    $0xc,%esp
  8005a8:	6a 01                	push   $0x1
  8005aa:	e8 df fd ff ff       	call   80038e <diskaddr>
  8005af:	83 c4 08             	add    $0x8,%esp
  8005b2:	68 16 3d 80 00       	push   $0x803d16
  8005b7:	50                   	push   %eax
  8005b8:	e8 f2 1b 00 00       	call   8021af <strcmp>
  8005bd:	83 c4 10             	add    $0x10,%esp
  8005c0:	85 c0                	test   %eax,%eax
  8005c2:	74 16                	je     8005da <bc_init+0x13e>
  8005c4:	68 8c 3c 80 00       	push   $0x803c8c
  8005c9:	68 dd 3b 80 00       	push   $0x803bdd
  8005ce:	6a 7a                	push   $0x7a
  8005d0:	68 b0 3c 80 00       	push   $0x803cb0
  8005d5:	e8 cd 14 00 00       	call   801aa7 <_panic>

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
  8005f4:	e8 9e 1c 00 00       	call   802297 <memmove>
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
  800623:	e8 6f 1c 00 00       	call   802297 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  800628:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80062f:	e8 5a fd ff ff       	call   80038e <diskaddr>
  800634:	83 c4 08             	add    $0x8,%esp
  800637:	68 16 3d 80 00       	push   $0x803d16
  80063c:	50                   	push   %eax
  80063d:	e8 c3 1a 00 00       	call   802105 <strcpy>

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
  800674:	68 38 3d 80 00       	push   $0x803d38
  800679:	68 dd 3b 80 00       	push   $0x803bdd
  80067e:	68 8b 00 00 00       	push   $0x8b
  800683:	68 b0 3c 80 00       	push   $0x803cb0
  800688:	e8 1a 14 00 00       	call   801aa7 <_panic>
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
  80069d:	e8 eb 1e 00 00       	call   80258d <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  8006a2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006a9:	e8 e0 fc ff ff       	call   80038e <diskaddr>
  8006ae:	89 04 24             	mov    %eax,(%esp)
  8006b1:	e8 10 fd ff ff       	call   8003c6 <va_is_mapped>
  8006b6:	83 c4 10             	add    $0x10,%esp
  8006b9:	84 c0                	test   %al,%al
  8006bb:	74 19                	je     8006d6 <bc_init+0x23a>
  8006bd:	68 37 3d 80 00       	push   $0x803d37
  8006c2:	68 dd 3b 80 00       	push   $0x803bdd
  8006c7:	68 93 00 00 00       	push   $0x93
  8006cc:	68 b0 3c 80 00       	push   $0x803cb0
  8006d1:	e8 d1 13 00 00       	call   801aa7 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8006d6:	83 ec 0c             	sub    $0xc,%esp
  8006d9:	6a 01                	push   $0x1
  8006db:	e8 ae fc ff ff       	call   80038e <diskaddr>
  8006e0:	83 c4 08             	add    $0x8,%esp
  8006e3:	68 16 3d 80 00       	push   $0x803d16
  8006e8:	50                   	push   %eax
  8006e9:	e8 c1 1a 00 00       	call   8021af <strcmp>
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	85 c0                	test   %eax,%eax
  8006f3:	74 19                	je     80070e <bc_init+0x272>
  8006f5:	68 8c 3c 80 00       	push   $0x803c8c
  8006fa:	68 dd 3b 80 00       	push   $0x803bdd
  8006ff:	68 96 00 00 00       	push   $0x96
  800704:	68 b0 3c 80 00       	push   $0x803cb0
  800709:	e8 99 13 00 00       	call   801aa7 <_panic>

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
  800728:	e8 6a 1b 00 00       	call   802297 <memmove>
	flush_block(diskaddr(1));
  80072d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800734:	e8 55 fc ff ff       	call   80038e <diskaddr>
  800739:	89 04 24             	mov    %eax,(%esp)
  80073c:	e8 cb fc ff ff       	call   80040c <flush_block>

	cprintf("block cache is good\n");
  800741:	c7 04 24 52 3d 80 00 	movl   $0x803d52,(%esp)
  800748:	e8 33 14 00 00       	call   801b80 <cprintf>
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
  800769:	e8 29 1b 00 00       	call   802297 <memmove>
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
		panic("bad file system magic number\n");
  800789:	83 ec 04             	sub    $0x4,%esp
  80078c:	68 67 3d 80 00       	push   $0x803d67
  800791:	6a 0f                	push   $0xf
  800793:	68 85 3d 80 00       	push   $0x803d85
  800798:	e8 0a 13 00 00       	call   801aa7 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  80079d:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8007a4:	76 14                	jbe    8007ba <check_super+0x44>
		panic("file system is too large");
  8007a6:	83 ec 04             	sub    $0x4,%esp
  8007a9:	68 8d 3d 80 00       	push   $0x803d8d
  8007ae:	6a 12                	push   $0x12
  8007b0:	68 85 3d 80 00       	push   $0x803d85
  8007b5:	e8 ed 12 00 00       	call   801aa7 <_panic>

	cprintf("superblock is good\n");
  8007ba:	83 ec 0c             	sub    $0xc,%esp
  8007bd:	68 a6 3d 80 00       	push   $0x803da6
  8007c2:	e8 b9 13 00 00       	call   801b80 <cprintf>
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
  80081a:	68 ba 3d 80 00       	push   $0x803dba
  80081f:	6a 2d                	push   $0x2d
  800821:	68 85 3d 80 00       	push   $0x803d85
  800826:	e8 7c 12 00 00       	call   801aa7 <_panic>
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
  800971:	68 d5 3d 80 00       	push   $0x803dd5
  800976:	68 dd 3b 80 00       	push   $0x803bdd
  80097b:	6a 61                	push   $0x61
  80097d:	68 85 3d 80 00       	push   $0x803d85
  800982:	e8 20 11 00 00       	call   801aa7 <_panic>
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
  8009a4:	68 e9 3d 80 00       	push   $0x803de9
  8009a9:	68 dd 3b 80 00       	push   $0x803bdd
  8009ae:	6a 64                	push   $0x64
  8009b0:	68 85 3d 80 00       	push   $0x803d85
  8009b5:	e8 ed 10 00 00       	call   801aa7 <_panic>
	assert(!block_is_free(1));
  8009ba:	83 ec 0c             	sub    $0xc,%esp
  8009bd:	6a 01                	push   $0x1
  8009bf:	e8 08 fe ff ff       	call   8007cc <block_is_free>
  8009c4:	83 c4 10             	add    $0x10,%esp
  8009c7:	84 c0                	test   %al,%al
  8009c9:	74 16                	je     8009e1 <check_bitmap+0x94>
  8009cb:	68 fb 3d 80 00       	push   $0x803dfb
  8009d0:	68 dd 3b 80 00       	push   $0x803bdd
  8009d5:	6a 65                	push   $0x65
  8009d7:	68 85 3d 80 00       	push   $0x803d85
  8009dc:	e8 c6 10 00 00       	call   801aa7 <_panic>

	cprintf("bitmap is good\n");
  8009e1:	83 ec 0c             	sub    $0xc,%esp
  8009e4:	68 0d 3e 80 00       	push   $0x803e0d
  8009e9:	e8 92 11 00 00       	call   801b80 <cprintf>
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
  800a8d:	68 1d 3e 80 00       	push   $0x803e1d
  800a92:	68 d4 00 00 00       	push   $0xd4
  800a97:	68 85 3d 80 00       	push   $0x803d85
  800a9c:	e8 06 10 00 00       	call   801aa7 <_panic>
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
  800b4c:	e8 46 17 00 00       	call   802297 <memmove>
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
  800b86:	68 33 3e 80 00       	push   $0x803e33
  800b8b:	68 dd 3b 80 00       	push   $0x803bdd
  800b90:	68 ed 00 00 00       	push   $0xed
  800b95:	68 85 3d 80 00       	push   $0x803d85
  800b9a:	e8 08 0f 00 00       	call   801aa7 <_panic>
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
  800c02:	e8 a8 15 00 00       	call   8021af <strcmp>
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
  800c6a:	e8 96 14 00 00       	call   802105 <strcpy>
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
  800d91:	e8 01 15 00 00       	call   802297 <memmove>
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
  800e62:	68 50 3e 80 00       	push   $0x803e50
  800e67:	e8 14 0d 00 00       	call   801b80 <cprintf>
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
  800f18:	e8 7a 13 00 00       	call   802297 <memmove>
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
  801029:	68 33 3e 80 00       	push   $0x803e33
  80102e:	68 dd 3b 80 00       	push   $0x803bdd
  801033:	68 06 01 00 00       	push   $0x106
  801038:	68 85 3d 80 00       	push   $0x803d85
  80103d:	e8 65 0a 00 00       	call   801aa7 <_panic>
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
  8010f4:	e8 0c 10 00 00       	call   802105 <strcpy>
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
  8011af:	e8 2b 22 00 00       	call   8033df <pageref>
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
  8011d4:	e8 2f 13 00 00       	call   802508 <sys_page_alloc>
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
  801205:	e8 40 10 00 00       	call   80224a <memset>
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
  80124f:	e8 8b 21 00 00       	call   8033df <pageref>
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
  80139f:	e8 61 0d 00 00       	call   802105 <strcpy>
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
  801429:	e8 69 0e 00 00       	call   802297 <memmove>
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
  801560:	e8 55 15 00 00       	call   802aba <ipc_recv>
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
  801574:	68 70 3e 80 00       	push   $0x803e70
  801579:	e8 02 06 00 00       	call   801b80 <cprintf>
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
  8015d1:	68 a0 3e 80 00       	push   $0x803ea0
  8015d6:	e8 a5 05 00 00       	call   801b80 <cprintf>
  8015db:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  8015de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  8015e3:	ff 75 f0             	pushl  -0x10(%ebp)
  8015e6:	ff 75 ec             	pushl  -0x14(%ebp)
  8015e9:	50                   	push   %eax
  8015ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8015ed:	e8 40 15 00 00       	call   802b32 <ipc_send>
		sys_page_unmap(0, fsreq);
  8015f2:	83 c4 08             	add    $0x8,%esp
  8015f5:	ff 35 44 50 80 00    	pushl  0x805044
  8015fb:	6a 00                	push   $0x0
  8015fd:	e8 8b 0f 00 00       	call   80258d <sys_page_unmap>
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
  801610:	c7 05 60 90 80 00 c3 	movl   $0x803ec3,0x809060
  801617:	3e 80 00 
	cprintf("FS is running\n");
  80161a:	68 c6 3e 80 00       	push   $0x803ec6
  80161f:	e8 5c 05 00 00       	call   801b80 <cprintf>
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
  801630:	c7 04 24 d5 3e 80 00 	movl   $0x803ed5,(%esp)
  801637:	e8 44 05 00 00       	call   801b80 <cprintf>

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
  801660:	e8 a3 0e 00 00       	call   802508 <sys_page_alloc>
  801665:	83 c4 10             	add    $0x10,%esp
  801668:	85 c0                	test   %eax,%eax
  80166a:	79 12                	jns    80167e <fs_test+0x2e>
		panic("sys_page_alloc: %e", r);
  80166c:	50                   	push   %eax
  80166d:	68 e4 3e 80 00       	push   $0x803ee4
  801672:	6a 12                	push   $0x12
  801674:	68 f7 3e 80 00       	push   $0x803ef7
  801679:	e8 29 04 00 00       	call   801aa7 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  80167e:	83 ec 04             	sub    $0x4,%esp
  801681:	68 00 10 00 00       	push   $0x1000
  801686:	ff 35 04 a0 80 00    	pushl  0x80a004
  80168c:	68 00 10 00 00       	push   $0x1000
  801691:	e8 01 0c 00 00       	call   802297 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  801696:	e8 aa f1 ff ff       	call   800845 <alloc_block>
  80169b:	83 c4 10             	add    $0x10,%esp
  80169e:	85 c0                	test   %eax,%eax
  8016a0:	79 12                	jns    8016b4 <fs_test+0x64>
		panic("alloc_block: %e", r);
  8016a2:	50                   	push   %eax
  8016a3:	68 01 3f 80 00       	push   $0x803f01
  8016a8:	6a 17                	push   $0x17
  8016aa:	68 f7 3e 80 00       	push   $0x803ef7
  8016af:	e8 f3 03 00 00       	call   801aa7 <_panic>
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
  8016df:	68 11 3f 80 00       	push   $0x803f11
  8016e4:	68 dd 3b 80 00       	push   $0x803bdd
  8016e9:	6a 19                	push   $0x19
  8016eb:	68 f7 3e 80 00       	push   $0x803ef7
  8016f0:	e8 b2 03 00 00       	call   801aa7 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  8016f5:	8b 0d 04 a0 80 00    	mov    0x80a004,%ecx
  8016fb:	85 04 91             	test   %eax,(%ecx,%edx,4)
  8016fe:	74 16                	je     801716 <fs_test+0xc6>
  801700:	68 8c 40 80 00       	push   $0x80408c
  801705:	68 dd 3b 80 00       	push   $0x803bdd
  80170a:	6a 1b                	push   $0x1b
  80170c:	68 f7 3e 80 00       	push   $0x803ef7
  801711:	e8 91 03 00 00       	call   801aa7 <_panic>
	cprintf("alloc_block is good\n");
  801716:	83 ec 0c             	sub    $0xc,%esp
  801719:	68 2c 3f 80 00       	push   $0x803f2c
  80171e:	e8 5d 04 00 00       	call   801b80 <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  801723:	83 c4 08             	add    $0x8,%esp
  801726:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801729:	50                   	push   %eax
  80172a:	68 41 3f 80 00       	push   $0x803f41
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
  801746:	68 4c 3f 80 00       	push   $0x803f4c
  80174b:	6a 1f                	push   $0x1f
  80174d:	68 f7 3e 80 00       	push   $0x803ef7
  801752:	e8 50 03 00 00       	call   801aa7 <_panic>
	else if (r == 0)
  801757:	85 c0                	test   %eax,%eax
  801759:	75 14                	jne    80176f <fs_test+0x11f>
		panic("file_open /not-found succeeded!");
  80175b:	83 ec 04             	sub    $0x4,%esp
  80175e:	68 ac 40 80 00       	push   $0x8040ac
  801763:	6a 21                	push   $0x21
  801765:	68 f7 3e 80 00       	push   $0x803ef7
  80176a:	e8 38 03 00 00       	call   801aa7 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  80176f:	83 ec 08             	sub    $0x8,%esp
  801772:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801775:	50                   	push   %eax
  801776:	68 65 3f 80 00       	push   $0x803f65
  80177b:	e8 70 f5 ff ff       	call   800cf0 <file_open>
  801780:	83 c4 10             	add    $0x10,%esp
  801783:	85 c0                	test   %eax,%eax
  801785:	79 12                	jns    801799 <fs_test+0x149>
		panic("file_open /newmotd: %e", r);
  801787:	50                   	push   %eax
  801788:	68 6e 3f 80 00       	push   $0x803f6e
  80178d:	6a 23                	push   $0x23
  80178f:	68 f7 3e 80 00       	push   $0x803ef7
  801794:	e8 0e 03 00 00       	call   801aa7 <_panic>
	cprintf("file_open is good\n");
  801799:	83 ec 0c             	sub    $0xc,%esp
  80179c:	68 85 3f 80 00       	push   $0x803f85
  8017a1:	e8 da 03 00 00       	call   801b80 <cprintf>

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
  8017bf:	68 98 3f 80 00       	push   $0x803f98
  8017c4:	6a 27                	push   $0x27
  8017c6:	68 f7 3e 80 00       	push   $0x803ef7
  8017cb:	e8 d7 02 00 00       	call   801aa7 <_panic>
	if (strcmp(blk, msg) != 0)
  8017d0:	83 ec 08             	sub    $0x8,%esp
  8017d3:	68 cc 40 80 00       	push   $0x8040cc
  8017d8:	ff 75 f0             	pushl  -0x10(%ebp)
  8017db:	e8 cf 09 00 00       	call   8021af <strcmp>
  8017e0:	83 c4 10             	add    $0x10,%esp
  8017e3:	85 c0                	test   %eax,%eax
  8017e5:	74 14                	je     8017fb <fs_test+0x1ab>
		panic("file_get_block returned wrong data");
  8017e7:	83 ec 04             	sub    $0x4,%esp
  8017ea:	68 f4 40 80 00       	push   $0x8040f4
  8017ef:	6a 29                	push   $0x29
  8017f1:	68 f7 3e 80 00       	push   $0x803ef7
  8017f6:	e8 ac 02 00 00       	call   801aa7 <_panic>
	cprintf("file_get_block is good\n");
  8017fb:	83 ec 0c             	sub    $0xc,%esp
  8017fe:	68 ab 3f 80 00       	push   $0x803fab
  801803:	e8 78 03 00 00       	call   801b80 <cprintf>

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
  801824:	68 c4 3f 80 00       	push   $0x803fc4
  801829:	68 dd 3b 80 00       	push   $0x803bdd
  80182e:	6a 2d                	push   $0x2d
  801830:	68 f7 3e 80 00       	push   $0x803ef7
  801835:	e8 6d 02 00 00       	call   801aa7 <_panic>
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
  801859:	68 c3 3f 80 00       	push   $0x803fc3
  80185e:	68 dd 3b 80 00       	push   $0x803bdd
  801863:	6a 2f                	push   $0x2f
  801865:	68 f7 3e 80 00       	push   $0x803ef7
  80186a:	e8 38 02 00 00       	call   801aa7 <_panic>
	cprintf("file_flush is good\n");
  80186f:	83 ec 0c             	sub    $0xc,%esp
  801872:	68 df 3f 80 00       	push   $0x803fdf
  801877:	e8 04 03 00 00       	call   801b80 <cprintf>

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
  801891:	68 f3 3f 80 00       	push   $0x803ff3
  801896:	6a 33                	push   $0x33
  801898:	68 f7 3e 80 00       	push   $0x803ef7
  80189d:	e8 05 02 00 00       	call   801aa7 <_panic>
	assert(f->f_direct[0] == 0);
  8018a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a5:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  8018ac:	74 16                	je     8018c4 <fs_test+0x274>
  8018ae:	68 05 40 80 00       	push   $0x804005
  8018b3:	68 dd 3b 80 00       	push   $0x803bdd
  8018b8:	6a 34                	push   $0x34
  8018ba:	68 f7 3e 80 00       	push   $0x803ef7
  8018bf:	e8 e3 01 00 00       	call   801aa7 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8018c4:	c1 e8 0c             	shr    $0xc,%eax
  8018c7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018ce:	a8 40                	test   $0x40,%al
  8018d0:	74 16                	je     8018e8 <fs_test+0x298>
  8018d2:	68 19 40 80 00       	push   $0x804019
  8018d7:	68 dd 3b 80 00       	push   $0x803bdd
  8018dc:	6a 35                	push   $0x35
  8018de:	68 f7 3e 80 00       	push   $0x803ef7
  8018e3:	e8 bf 01 00 00       	call   801aa7 <_panic>
	cprintf("file_truncate is good\n");
  8018e8:	83 ec 0c             	sub    $0xc,%esp
  8018eb:	68 33 40 80 00       	push   $0x804033
  8018f0:	e8 8b 02 00 00       	call   801b80 <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  8018f5:	c7 04 24 cc 40 80 00 	movl   $0x8040cc,(%esp)
  8018fc:	e8 cb 07 00 00       	call   8020cc <strlen>
  801901:	83 c4 08             	add    $0x8,%esp
  801904:	50                   	push   %eax
  801905:	ff 75 f4             	pushl  -0xc(%ebp)
  801908:	e8 a2 f4 ff ff       	call   800daf <file_set_size>
  80190d:	83 c4 10             	add    $0x10,%esp
  801910:	85 c0                	test   %eax,%eax
  801912:	79 12                	jns    801926 <fs_test+0x2d6>
		panic("file_set_size 2: %e", r);
  801914:	50                   	push   %eax
  801915:	68 4a 40 80 00       	push   $0x80404a
  80191a:	6a 39                	push   $0x39
  80191c:	68 f7 3e 80 00       	push   $0x803ef7
  801921:	e8 81 01 00 00       	call   801aa7 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801926:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801929:	89 c2                	mov    %eax,%edx
  80192b:	c1 ea 0c             	shr    $0xc,%edx
  80192e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801935:	f6 c2 40             	test   $0x40,%dl
  801938:	74 16                	je     801950 <fs_test+0x300>
  80193a:	68 19 40 80 00       	push   $0x804019
  80193f:	68 dd 3b 80 00       	push   $0x803bdd
  801944:	6a 3a                	push   $0x3a
  801946:	68 f7 3e 80 00       	push   $0x803ef7
  80194b:	e8 57 01 00 00       	call   801aa7 <_panic>
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
  801967:	68 5e 40 80 00       	push   $0x80405e
  80196c:	6a 3c                	push   $0x3c
  80196e:	68 f7 3e 80 00       	push   $0x803ef7
  801973:	e8 2f 01 00 00       	call   801aa7 <_panic>
	strcpy(blk, msg);
  801978:	83 ec 08             	sub    $0x8,%esp
  80197b:	68 cc 40 80 00       	push   $0x8040cc
  801980:	ff 75 f0             	pushl  -0x10(%ebp)
  801983:	e8 7d 07 00 00       	call   802105 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801988:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80198b:	c1 e8 0c             	shr    $0xc,%eax
  80198e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801995:	83 c4 10             	add    $0x10,%esp
  801998:	a8 40                	test   $0x40,%al
  80199a:	75 16                	jne    8019b2 <fs_test+0x362>
  80199c:	68 c4 3f 80 00       	push   $0x803fc4
  8019a1:	68 dd 3b 80 00       	push   $0x803bdd
  8019a6:	6a 3e                	push   $0x3e
  8019a8:	68 f7 3e 80 00       	push   $0x803ef7
  8019ad:	e8 f5 00 00 00       	call   801aa7 <_panic>
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
  8019d1:	68 c3 3f 80 00       	push   $0x803fc3
  8019d6:	68 dd 3b 80 00       	push   $0x803bdd
  8019db:	6a 40                	push   $0x40
  8019dd:	68 f7 3e 80 00       	push   $0x803ef7
  8019e2:	e8 c0 00 00 00       	call   801aa7 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8019e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ea:	c1 e8 0c             	shr    $0xc,%eax
  8019ed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019f4:	a8 40                	test   $0x40,%al
  8019f6:	74 16                	je     801a0e <fs_test+0x3be>
  8019f8:	68 19 40 80 00       	push   $0x804019
  8019fd:	68 dd 3b 80 00       	push   $0x803bdd
  801a02:	6a 41                	push   $0x41
  801a04:	68 f7 3e 80 00       	push   $0x803ef7
  801a09:	e8 99 00 00 00       	call   801aa7 <_panic>
	cprintf("file rewrite is good\n");
  801a0e:	83 ec 0c             	sub    $0xc,%esp
  801a11:	68 73 40 80 00       	push   $0x804073
  801a16:	e8 65 01 00 00       	call   801b80 <cprintf>
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
  801a26:	56                   	push   %esi
  801a27:	53                   	push   %ebx
  801a28:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a2b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  801a2e:	e8 97 0a 00 00       	call   8024ca <sys_getenvid>
  801a33:	25 ff 03 00 00       	and    $0x3ff,%eax
  801a38:	89 c2                	mov    %eax,%edx
  801a3a:	c1 e2 07             	shl    $0x7,%edx
  801a3d:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801a44:	a3 0c a0 80 00       	mov    %eax,0x80a00c
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801a49:	85 db                	test   %ebx,%ebx
  801a4b:	7e 07                	jle    801a54 <libmain+0x31>
		binaryname = argv[0];
  801a4d:	8b 06                	mov    (%esi),%eax
  801a4f:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801a54:	83 ec 08             	sub    $0x8,%esp
  801a57:	56                   	push   %esi
  801a58:	53                   	push   %ebx
  801a59:	e8 ac fb ff ff       	call   80160a <umain>

	// exit gracefully
	exit();
  801a5e:	e8 2a 00 00 00       	call   801a8d <exit>
}
  801a63:	83 c4 10             	add    $0x10,%esp
  801a66:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a69:	5b                   	pop    %ebx
  801a6a:	5e                   	pop    %esi
  801a6b:	5d                   	pop    %ebp
  801a6c:	c3                   	ret    

00801a6d <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  801a73:	a1 14 a0 80 00       	mov    0x80a014,%eax
	func();
  801a78:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  801a7a:	e8 4b 0a 00 00       	call   8024ca <sys_getenvid>
  801a7f:	83 ec 0c             	sub    $0xc,%esp
  801a82:	50                   	push   %eax
  801a83:	e8 91 0c 00 00       	call   802719 <sys_thread_free>
}
  801a88:	83 c4 10             	add    $0x10,%esp
  801a8b:	c9                   	leave  
  801a8c:	c3                   	ret    

00801a8d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801a8d:	55                   	push   %ebp
  801a8e:	89 e5                	mov    %esp,%ebp
  801a90:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801a93:	e8 07 13 00 00       	call   802d9f <close_all>
	sys_env_destroy(0);
  801a98:	83 ec 0c             	sub    $0xc,%esp
  801a9b:	6a 00                	push   $0x0
  801a9d:	e8 e7 09 00 00       	call   802489 <sys_env_destroy>
}
  801aa2:	83 c4 10             	add    $0x10,%esp
  801aa5:	c9                   	leave  
  801aa6:	c3                   	ret    

00801aa7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801aa7:	55                   	push   %ebp
  801aa8:	89 e5                	mov    %esp,%ebp
  801aaa:	56                   	push   %esi
  801aab:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801aac:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801aaf:	8b 35 60 90 80 00    	mov    0x809060,%esi
  801ab5:	e8 10 0a 00 00       	call   8024ca <sys_getenvid>
  801aba:	83 ec 0c             	sub    $0xc,%esp
  801abd:	ff 75 0c             	pushl  0xc(%ebp)
  801ac0:	ff 75 08             	pushl  0x8(%ebp)
  801ac3:	56                   	push   %esi
  801ac4:	50                   	push   %eax
  801ac5:	68 24 41 80 00       	push   $0x804124
  801aca:	e8 b1 00 00 00       	call   801b80 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801acf:	83 c4 18             	add    $0x18,%esp
  801ad2:	53                   	push   %ebx
  801ad3:	ff 75 10             	pushl  0x10(%ebp)
  801ad6:	e8 54 00 00 00       	call   801b2f <vcprintf>
	cprintf("\n");
  801adb:	c7 04 24 1b 3d 80 00 	movl   $0x803d1b,(%esp)
  801ae2:	e8 99 00 00 00       	call   801b80 <cprintf>
  801ae7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801aea:	cc                   	int3   
  801aeb:	eb fd                	jmp    801aea <_panic+0x43>

00801aed <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801aed:	55                   	push   %ebp
  801aee:	89 e5                	mov    %esp,%ebp
  801af0:	53                   	push   %ebx
  801af1:	83 ec 04             	sub    $0x4,%esp
  801af4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801af7:	8b 13                	mov    (%ebx),%edx
  801af9:	8d 42 01             	lea    0x1(%edx),%eax
  801afc:	89 03                	mov    %eax,(%ebx)
  801afe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b01:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801b05:	3d ff 00 00 00       	cmp    $0xff,%eax
  801b0a:	75 1a                	jne    801b26 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801b0c:	83 ec 08             	sub    $0x8,%esp
  801b0f:	68 ff 00 00 00       	push   $0xff
  801b14:	8d 43 08             	lea    0x8(%ebx),%eax
  801b17:	50                   	push   %eax
  801b18:	e8 2f 09 00 00       	call   80244c <sys_cputs>
		b->idx = 0;
  801b1d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b23:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801b26:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801b2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b2d:	c9                   	leave  
  801b2e:	c3                   	ret    

00801b2f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801b38:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801b3f:	00 00 00 
	b.cnt = 0;
  801b42:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801b49:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801b4c:	ff 75 0c             	pushl  0xc(%ebp)
  801b4f:	ff 75 08             	pushl  0x8(%ebp)
  801b52:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801b58:	50                   	push   %eax
  801b59:	68 ed 1a 80 00       	push   $0x801aed
  801b5e:	e8 54 01 00 00       	call   801cb7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801b63:	83 c4 08             	add    $0x8,%esp
  801b66:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801b6c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801b72:	50                   	push   %eax
  801b73:	e8 d4 08 00 00       	call   80244c <sys_cputs>

	return b.cnt;
}
  801b78:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801b7e:	c9                   	leave  
  801b7f:	c3                   	ret    

00801b80 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801b86:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801b89:	50                   	push   %eax
  801b8a:	ff 75 08             	pushl  0x8(%ebp)
  801b8d:	e8 9d ff ff ff       	call   801b2f <vcprintf>
	va_end(ap);

	return cnt;
}
  801b92:	c9                   	leave  
  801b93:	c3                   	ret    

00801b94 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801b94:	55                   	push   %ebp
  801b95:	89 e5                	mov    %esp,%ebp
  801b97:	57                   	push   %edi
  801b98:	56                   	push   %esi
  801b99:	53                   	push   %ebx
  801b9a:	83 ec 1c             	sub    $0x1c,%esp
  801b9d:	89 c7                	mov    %eax,%edi
  801b9f:	89 d6                	mov    %edx,%esi
  801ba1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ba7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801baa:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801bad:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801bb0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bb5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801bb8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801bbb:	39 d3                	cmp    %edx,%ebx
  801bbd:	72 05                	jb     801bc4 <printnum+0x30>
  801bbf:	39 45 10             	cmp    %eax,0x10(%ebp)
  801bc2:	77 45                	ja     801c09 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801bc4:	83 ec 0c             	sub    $0xc,%esp
  801bc7:	ff 75 18             	pushl  0x18(%ebp)
  801bca:	8b 45 14             	mov    0x14(%ebp),%eax
  801bcd:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801bd0:	53                   	push   %ebx
  801bd1:	ff 75 10             	pushl  0x10(%ebp)
  801bd4:	83 ec 08             	sub    $0x8,%esp
  801bd7:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bda:	ff 75 e0             	pushl  -0x20(%ebp)
  801bdd:	ff 75 dc             	pushl  -0x24(%ebp)
  801be0:	ff 75 d8             	pushl  -0x28(%ebp)
  801be3:	e8 18 1d 00 00       	call   803900 <__udivdi3>
  801be8:	83 c4 18             	add    $0x18,%esp
  801beb:	52                   	push   %edx
  801bec:	50                   	push   %eax
  801bed:	89 f2                	mov    %esi,%edx
  801bef:	89 f8                	mov    %edi,%eax
  801bf1:	e8 9e ff ff ff       	call   801b94 <printnum>
  801bf6:	83 c4 20             	add    $0x20,%esp
  801bf9:	eb 18                	jmp    801c13 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801bfb:	83 ec 08             	sub    $0x8,%esp
  801bfe:	56                   	push   %esi
  801bff:	ff 75 18             	pushl  0x18(%ebp)
  801c02:	ff d7                	call   *%edi
  801c04:	83 c4 10             	add    $0x10,%esp
  801c07:	eb 03                	jmp    801c0c <printnum+0x78>
  801c09:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801c0c:	83 eb 01             	sub    $0x1,%ebx
  801c0f:	85 db                	test   %ebx,%ebx
  801c11:	7f e8                	jg     801bfb <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801c13:	83 ec 08             	sub    $0x8,%esp
  801c16:	56                   	push   %esi
  801c17:	83 ec 04             	sub    $0x4,%esp
  801c1a:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c1d:	ff 75 e0             	pushl  -0x20(%ebp)
  801c20:	ff 75 dc             	pushl  -0x24(%ebp)
  801c23:	ff 75 d8             	pushl  -0x28(%ebp)
  801c26:	e8 05 1e 00 00       	call   803a30 <__umoddi3>
  801c2b:	83 c4 14             	add    $0x14,%esp
  801c2e:	0f be 80 47 41 80 00 	movsbl 0x804147(%eax),%eax
  801c35:	50                   	push   %eax
  801c36:	ff d7                	call   *%edi
}
  801c38:	83 c4 10             	add    $0x10,%esp
  801c3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c3e:	5b                   	pop    %ebx
  801c3f:	5e                   	pop    %esi
  801c40:	5f                   	pop    %edi
  801c41:	5d                   	pop    %ebp
  801c42:	c3                   	ret    

00801c43 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801c43:	55                   	push   %ebp
  801c44:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801c46:	83 fa 01             	cmp    $0x1,%edx
  801c49:	7e 0e                	jle    801c59 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801c4b:	8b 10                	mov    (%eax),%edx
  801c4d:	8d 4a 08             	lea    0x8(%edx),%ecx
  801c50:	89 08                	mov    %ecx,(%eax)
  801c52:	8b 02                	mov    (%edx),%eax
  801c54:	8b 52 04             	mov    0x4(%edx),%edx
  801c57:	eb 22                	jmp    801c7b <getuint+0x38>
	else if (lflag)
  801c59:	85 d2                	test   %edx,%edx
  801c5b:	74 10                	je     801c6d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801c5d:	8b 10                	mov    (%eax),%edx
  801c5f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801c62:	89 08                	mov    %ecx,(%eax)
  801c64:	8b 02                	mov    (%edx),%eax
  801c66:	ba 00 00 00 00       	mov    $0x0,%edx
  801c6b:	eb 0e                	jmp    801c7b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801c6d:	8b 10                	mov    (%eax),%edx
  801c6f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801c72:	89 08                	mov    %ecx,(%eax)
  801c74:	8b 02                	mov    (%edx),%eax
  801c76:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801c7b:	5d                   	pop    %ebp
  801c7c:	c3                   	ret    

00801c7d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801c7d:	55                   	push   %ebp
  801c7e:	89 e5                	mov    %esp,%ebp
  801c80:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801c83:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801c87:	8b 10                	mov    (%eax),%edx
  801c89:	3b 50 04             	cmp    0x4(%eax),%edx
  801c8c:	73 0a                	jae    801c98 <sprintputch+0x1b>
		*b->buf++ = ch;
  801c8e:	8d 4a 01             	lea    0x1(%edx),%ecx
  801c91:	89 08                	mov    %ecx,(%eax)
  801c93:	8b 45 08             	mov    0x8(%ebp),%eax
  801c96:	88 02                	mov    %al,(%edx)
}
  801c98:	5d                   	pop    %ebp
  801c99:	c3                   	ret    

00801c9a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801c9a:	55                   	push   %ebp
  801c9b:	89 e5                	mov    %esp,%ebp
  801c9d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801ca0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801ca3:	50                   	push   %eax
  801ca4:	ff 75 10             	pushl  0x10(%ebp)
  801ca7:	ff 75 0c             	pushl  0xc(%ebp)
  801caa:	ff 75 08             	pushl  0x8(%ebp)
  801cad:	e8 05 00 00 00       	call   801cb7 <vprintfmt>
	va_end(ap);
}
  801cb2:	83 c4 10             	add    $0x10,%esp
  801cb5:	c9                   	leave  
  801cb6:	c3                   	ret    

00801cb7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801cb7:	55                   	push   %ebp
  801cb8:	89 e5                	mov    %esp,%ebp
  801cba:	57                   	push   %edi
  801cbb:	56                   	push   %esi
  801cbc:	53                   	push   %ebx
  801cbd:	83 ec 2c             	sub    $0x2c,%esp
  801cc0:	8b 75 08             	mov    0x8(%ebp),%esi
  801cc3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801cc6:	8b 7d 10             	mov    0x10(%ebp),%edi
  801cc9:	eb 12                	jmp    801cdd <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801ccb:	85 c0                	test   %eax,%eax
  801ccd:	0f 84 89 03 00 00    	je     80205c <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801cd3:	83 ec 08             	sub    $0x8,%esp
  801cd6:	53                   	push   %ebx
  801cd7:	50                   	push   %eax
  801cd8:	ff d6                	call   *%esi
  801cda:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801cdd:	83 c7 01             	add    $0x1,%edi
  801ce0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801ce4:	83 f8 25             	cmp    $0x25,%eax
  801ce7:	75 e2                	jne    801ccb <vprintfmt+0x14>
  801ce9:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801ced:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801cf4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801cfb:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801d02:	ba 00 00 00 00       	mov    $0x0,%edx
  801d07:	eb 07                	jmp    801d10 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d09:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801d0c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d10:	8d 47 01             	lea    0x1(%edi),%eax
  801d13:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d16:	0f b6 07             	movzbl (%edi),%eax
  801d19:	0f b6 c8             	movzbl %al,%ecx
  801d1c:	83 e8 23             	sub    $0x23,%eax
  801d1f:	3c 55                	cmp    $0x55,%al
  801d21:	0f 87 1a 03 00 00    	ja     802041 <vprintfmt+0x38a>
  801d27:	0f b6 c0             	movzbl %al,%eax
  801d2a:	ff 24 85 80 42 80 00 	jmp    *0x804280(,%eax,4)
  801d31:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801d34:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801d38:	eb d6                	jmp    801d10 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d3a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d3d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d42:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801d45:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801d48:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801d4c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801d4f:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801d52:	83 fa 09             	cmp    $0x9,%edx
  801d55:	77 39                	ja     801d90 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801d57:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801d5a:	eb e9                	jmp    801d45 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801d5c:	8b 45 14             	mov    0x14(%ebp),%eax
  801d5f:	8d 48 04             	lea    0x4(%eax),%ecx
  801d62:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801d65:	8b 00                	mov    (%eax),%eax
  801d67:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d6a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801d6d:	eb 27                	jmp    801d96 <vprintfmt+0xdf>
  801d6f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d72:	85 c0                	test   %eax,%eax
  801d74:	b9 00 00 00 00       	mov    $0x0,%ecx
  801d79:	0f 49 c8             	cmovns %eax,%ecx
  801d7c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d7f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d82:	eb 8c                	jmp    801d10 <vprintfmt+0x59>
  801d84:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801d87:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801d8e:	eb 80                	jmp    801d10 <vprintfmt+0x59>
  801d90:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801d93:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801d96:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801d9a:	0f 89 70 ff ff ff    	jns    801d10 <vprintfmt+0x59>
				width = precision, precision = -1;
  801da0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801da3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801da6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801dad:	e9 5e ff ff ff       	jmp    801d10 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801db2:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801db5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801db8:	e9 53 ff ff ff       	jmp    801d10 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801dbd:	8b 45 14             	mov    0x14(%ebp),%eax
  801dc0:	8d 50 04             	lea    0x4(%eax),%edx
  801dc3:	89 55 14             	mov    %edx,0x14(%ebp)
  801dc6:	83 ec 08             	sub    $0x8,%esp
  801dc9:	53                   	push   %ebx
  801dca:	ff 30                	pushl  (%eax)
  801dcc:	ff d6                	call   *%esi
			break;
  801dce:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801dd1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801dd4:	e9 04 ff ff ff       	jmp    801cdd <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801dd9:	8b 45 14             	mov    0x14(%ebp),%eax
  801ddc:	8d 50 04             	lea    0x4(%eax),%edx
  801ddf:	89 55 14             	mov    %edx,0x14(%ebp)
  801de2:	8b 00                	mov    (%eax),%eax
  801de4:	99                   	cltd   
  801de5:	31 d0                	xor    %edx,%eax
  801de7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801de9:	83 f8 0f             	cmp    $0xf,%eax
  801dec:	7f 0b                	jg     801df9 <vprintfmt+0x142>
  801dee:	8b 14 85 e0 43 80 00 	mov    0x8043e0(,%eax,4),%edx
  801df5:	85 d2                	test   %edx,%edx
  801df7:	75 18                	jne    801e11 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801df9:	50                   	push   %eax
  801dfa:	68 5f 41 80 00       	push   $0x80415f
  801dff:	53                   	push   %ebx
  801e00:	56                   	push   %esi
  801e01:	e8 94 fe ff ff       	call   801c9a <printfmt>
  801e06:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e09:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801e0c:	e9 cc fe ff ff       	jmp    801cdd <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801e11:	52                   	push   %edx
  801e12:	68 ef 3b 80 00       	push   $0x803bef
  801e17:	53                   	push   %ebx
  801e18:	56                   	push   %esi
  801e19:	e8 7c fe ff ff       	call   801c9a <printfmt>
  801e1e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e21:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e24:	e9 b4 fe ff ff       	jmp    801cdd <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801e29:	8b 45 14             	mov    0x14(%ebp),%eax
  801e2c:	8d 50 04             	lea    0x4(%eax),%edx
  801e2f:	89 55 14             	mov    %edx,0x14(%ebp)
  801e32:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801e34:	85 ff                	test   %edi,%edi
  801e36:	b8 58 41 80 00       	mov    $0x804158,%eax
  801e3b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801e3e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801e42:	0f 8e 94 00 00 00    	jle    801edc <vprintfmt+0x225>
  801e48:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801e4c:	0f 84 98 00 00 00    	je     801eea <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801e52:	83 ec 08             	sub    $0x8,%esp
  801e55:	ff 75 d0             	pushl  -0x30(%ebp)
  801e58:	57                   	push   %edi
  801e59:	e8 86 02 00 00       	call   8020e4 <strnlen>
  801e5e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801e61:	29 c1                	sub    %eax,%ecx
  801e63:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801e66:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801e69:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801e6d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e70:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801e73:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801e75:	eb 0f                	jmp    801e86 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801e77:	83 ec 08             	sub    $0x8,%esp
  801e7a:	53                   	push   %ebx
  801e7b:	ff 75 e0             	pushl  -0x20(%ebp)
  801e7e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801e80:	83 ef 01             	sub    $0x1,%edi
  801e83:	83 c4 10             	add    $0x10,%esp
  801e86:	85 ff                	test   %edi,%edi
  801e88:	7f ed                	jg     801e77 <vprintfmt+0x1c0>
  801e8a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801e8d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801e90:	85 c9                	test   %ecx,%ecx
  801e92:	b8 00 00 00 00       	mov    $0x0,%eax
  801e97:	0f 49 c1             	cmovns %ecx,%eax
  801e9a:	29 c1                	sub    %eax,%ecx
  801e9c:	89 75 08             	mov    %esi,0x8(%ebp)
  801e9f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801ea2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801ea5:	89 cb                	mov    %ecx,%ebx
  801ea7:	eb 4d                	jmp    801ef6 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801ea9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801ead:	74 1b                	je     801eca <vprintfmt+0x213>
  801eaf:	0f be c0             	movsbl %al,%eax
  801eb2:	83 e8 20             	sub    $0x20,%eax
  801eb5:	83 f8 5e             	cmp    $0x5e,%eax
  801eb8:	76 10                	jbe    801eca <vprintfmt+0x213>
					putch('?', putdat);
  801eba:	83 ec 08             	sub    $0x8,%esp
  801ebd:	ff 75 0c             	pushl  0xc(%ebp)
  801ec0:	6a 3f                	push   $0x3f
  801ec2:	ff 55 08             	call   *0x8(%ebp)
  801ec5:	83 c4 10             	add    $0x10,%esp
  801ec8:	eb 0d                	jmp    801ed7 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801eca:	83 ec 08             	sub    $0x8,%esp
  801ecd:	ff 75 0c             	pushl  0xc(%ebp)
  801ed0:	52                   	push   %edx
  801ed1:	ff 55 08             	call   *0x8(%ebp)
  801ed4:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801ed7:	83 eb 01             	sub    $0x1,%ebx
  801eda:	eb 1a                	jmp    801ef6 <vprintfmt+0x23f>
  801edc:	89 75 08             	mov    %esi,0x8(%ebp)
  801edf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801ee2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801ee5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801ee8:	eb 0c                	jmp    801ef6 <vprintfmt+0x23f>
  801eea:	89 75 08             	mov    %esi,0x8(%ebp)
  801eed:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801ef0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801ef3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801ef6:	83 c7 01             	add    $0x1,%edi
  801ef9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801efd:	0f be d0             	movsbl %al,%edx
  801f00:	85 d2                	test   %edx,%edx
  801f02:	74 23                	je     801f27 <vprintfmt+0x270>
  801f04:	85 f6                	test   %esi,%esi
  801f06:	78 a1                	js     801ea9 <vprintfmt+0x1f2>
  801f08:	83 ee 01             	sub    $0x1,%esi
  801f0b:	79 9c                	jns    801ea9 <vprintfmt+0x1f2>
  801f0d:	89 df                	mov    %ebx,%edi
  801f0f:	8b 75 08             	mov    0x8(%ebp),%esi
  801f12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801f15:	eb 18                	jmp    801f2f <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801f17:	83 ec 08             	sub    $0x8,%esp
  801f1a:	53                   	push   %ebx
  801f1b:	6a 20                	push   $0x20
  801f1d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801f1f:	83 ef 01             	sub    $0x1,%edi
  801f22:	83 c4 10             	add    $0x10,%esp
  801f25:	eb 08                	jmp    801f2f <vprintfmt+0x278>
  801f27:	89 df                	mov    %ebx,%edi
  801f29:	8b 75 08             	mov    0x8(%ebp),%esi
  801f2c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801f2f:	85 ff                	test   %edi,%edi
  801f31:	7f e4                	jg     801f17 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f33:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801f36:	e9 a2 fd ff ff       	jmp    801cdd <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801f3b:	83 fa 01             	cmp    $0x1,%edx
  801f3e:	7e 16                	jle    801f56 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801f40:	8b 45 14             	mov    0x14(%ebp),%eax
  801f43:	8d 50 08             	lea    0x8(%eax),%edx
  801f46:	89 55 14             	mov    %edx,0x14(%ebp)
  801f49:	8b 50 04             	mov    0x4(%eax),%edx
  801f4c:	8b 00                	mov    (%eax),%eax
  801f4e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f51:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801f54:	eb 32                	jmp    801f88 <vprintfmt+0x2d1>
	else if (lflag)
  801f56:	85 d2                	test   %edx,%edx
  801f58:	74 18                	je     801f72 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801f5a:	8b 45 14             	mov    0x14(%ebp),%eax
  801f5d:	8d 50 04             	lea    0x4(%eax),%edx
  801f60:	89 55 14             	mov    %edx,0x14(%ebp)
  801f63:	8b 00                	mov    (%eax),%eax
  801f65:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f68:	89 c1                	mov    %eax,%ecx
  801f6a:	c1 f9 1f             	sar    $0x1f,%ecx
  801f6d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801f70:	eb 16                	jmp    801f88 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801f72:	8b 45 14             	mov    0x14(%ebp),%eax
  801f75:	8d 50 04             	lea    0x4(%eax),%edx
  801f78:	89 55 14             	mov    %edx,0x14(%ebp)
  801f7b:	8b 00                	mov    (%eax),%eax
  801f7d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f80:	89 c1                	mov    %eax,%ecx
  801f82:	c1 f9 1f             	sar    $0x1f,%ecx
  801f85:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801f88:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801f8b:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801f8e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801f93:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801f97:	79 74                	jns    80200d <vprintfmt+0x356>
				putch('-', putdat);
  801f99:	83 ec 08             	sub    $0x8,%esp
  801f9c:	53                   	push   %ebx
  801f9d:	6a 2d                	push   $0x2d
  801f9f:	ff d6                	call   *%esi
				num = -(long long) num;
  801fa1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801fa4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801fa7:	f7 d8                	neg    %eax
  801fa9:	83 d2 00             	adc    $0x0,%edx
  801fac:	f7 da                	neg    %edx
  801fae:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801fb1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801fb6:	eb 55                	jmp    80200d <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801fb8:	8d 45 14             	lea    0x14(%ebp),%eax
  801fbb:	e8 83 fc ff ff       	call   801c43 <getuint>
			base = 10;
  801fc0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801fc5:	eb 46                	jmp    80200d <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801fc7:	8d 45 14             	lea    0x14(%ebp),%eax
  801fca:	e8 74 fc ff ff       	call   801c43 <getuint>
			base = 8;
  801fcf:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801fd4:	eb 37                	jmp    80200d <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801fd6:	83 ec 08             	sub    $0x8,%esp
  801fd9:	53                   	push   %ebx
  801fda:	6a 30                	push   $0x30
  801fdc:	ff d6                	call   *%esi
			putch('x', putdat);
  801fde:	83 c4 08             	add    $0x8,%esp
  801fe1:	53                   	push   %ebx
  801fe2:	6a 78                	push   $0x78
  801fe4:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801fe6:	8b 45 14             	mov    0x14(%ebp),%eax
  801fe9:	8d 50 04             	lea    0x4(%eax),%edx
  801fec:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801fef:	8b 00                	mov    (%eax),%eax
  801ff1:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801ff6:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801ff9:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801ffe:	eb 0d                	jmp    80200d <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  802000:	8d 45 14             	lea    0x14(%ebp),%eax
  802003:	e8 3b fc ff ff       	call   801c43 <getuint>
			base = 16;
  802008:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80200d:	83 ec 0c             	sub    $0xc,%esp
  802010:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  802014:	57                   	push   %edi
  802015:	ff 75 e0             	pushl  -0x20(%ebp)
  802018:	51                   	push   %ecx
  802019:	52                   	push   %edx
  80201a:	50                   	push   %eax
  80201b:	89 da                	mov    %ebx,%edx
  80201d:	89 f0                	mov    %esi,%eax
  80201f:	e8 70 fb ff ff       	call   801b94 <printnum>
			break;
  802024:	83 c4 20             	add    $0x20,%esp
  802027:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80202a:	e9 ae fc ff ff       	jmp    801cdd <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80202f:	83 ec 08             	sub    $0x8,%esp
  802032:	53                   	push   %ebx
  802033:	51                   	push   %ecx
  802034:	ff d6                	call   *%esi
			break;
  802036:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  802039:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80203c:	e9 9c fc ff ff       	jmp    801cdd <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  802041:	83 ec 08             	sub    $0x8,%esp
  802044:	53                   	push   %ebx
  802045:	6a 25                	push   $0x25
  802047:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  802049:	83 c4 10             	add    $0x10,%esp
  80204c:	eb 03                	jmp    802051 <vprintfmt+0x39a>
  80204e:	83 ef 01             	sub    $0x1,%edi
  802051:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  802055:	75 f7                	jne    80204e <vprintfmt+0x397>
  802057:	e9 81 fc ff ff       	jmp    801cdd <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80205c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80205f:	5b                   	pop    %ebx
  802060:	5e                   	pop    %esi
  802061:	5f                   	pop    %edi
  802062:	5d                   	pop    %ebp
  802063:	c3                   	ret    

00802064 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  802064:	55                   	push   %ebp
  802065:	89 e5                	mov    %esp,%ebp
  802067:	83 ec 18             	sub    $0x18,%esp
  80206a:	8b 45 08             	mov    0x8(%ebp),%eax
  80206d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  802070:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802073:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  802077:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80207a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  802081:	85 c0                	test   %eax,%eax
  802083:	74 26                	je     8020ab <vsnprintf+0x47>
  802085:	85 d2                	test   %edx,%edx
  802087:	7e 22                	jle    8020ab <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  802089:	ff 75 14             	pushl  0x14(%ebp)
  80208c:	ff 75 10             	pushl  0x10(%ebp)
  80208f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  802092:	50                   	push   %eax
  802093:	68 7d 1c 80 00       	push   $0x801c7d
  802098:	e8 1a fc ff ff       	call   801cb7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80209d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8020a0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8020a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a6:	83 c4 10             	add    $0x10,%esp
  8020a9:	eb 05                	jmp    8020b0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8020ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8020b0:	c9                   	leave  
  8020b1:	c3                   	ret    

008020b2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8020b2:	55                   	push   %ebp
  8020b3:	89 e5                	mov    %esp,%ebp
  8020b5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8020b8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8020bb:	50                   	push   %eax
  8020bc:	ff 75 10             	pushl  0x10(%ebp)
  8020bf:	ff 75 0c             	pushl  0xc(%ebp)
  8020c2:	ff 75 08             	pushl  0x8(%ebp)
  8020c5:	e8 9a ff ff ff       	call   802064 <vsnprintf>
	va_end(ap);

	return rc;
}
  8020ca:	c9                   	leave  
  8020cb:	c3                   	ret    

008020cc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8020cc:	55                   	push   %ebp
  8020cd:	89 e5                	mov    %esp,%ebp
  8020cf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8020d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8020d7:	eb 03                	jmp    8020dc <strlen+0x10>
		n++;
  8020d9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8020dc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8020e0:	75 f7                	jne    8020d9 <strlen+0xd>
		n++;
	return n;
}
  8020e2:	5d                   	pop    %ebp
  8020e3:	c3                   	ret    

008020e4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8020e4:	55                   	push   %ebp
  8020e5:	89 e5                	mov    %esp,%ebp
  8020e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020ea:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8020ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8020f2:	eb 03                	jmp    8020f7 <strnlen+0x13>
		n++;
  8020f4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8020f7:	39 c2                	cmp    %eax,%edx
  8020f9:	74 08                	je     802103 <strnlen+0x1f>
  8020fb:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8020ff:	75 f3                	jne    8020f4 <strnlen+0x10>
  802101:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  802103:	5d                   	pop    %ebp
  802104:	c3                   	ret    

00802105 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  802105:	55                   	push   %ebp
  802106:	89 e5                	mov    %esp,%ebp
  802108:	53                   	push   %ebx
  802109:	8b 45 08             	mov    0x8(%ebp),%eax
  80210c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80210f:	89 c2                	mov    %eax,%edx
  802111:	83 c2 01             	add    $0x1,%edx
  802114:	83 c1 01             	add    $0x1,%ecx
  802117:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80211b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80211e:	84 db                	test   %bl,%bl
  802120:	75 ef                	jne    802111 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  802122:	5b                   	pop    %ebx
  802123:	5d                   	pop    %ebp
  802124:	c3                   	ret    

00802125 <strcat>:

char *
strcat(char *dst, const char *src)
{
  802125:	55                   	push   %ebp
  802126:	89 e5                	mov    %esp,%ebp
  802128:	53                   	push   %ebx
  802129:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80212c:	53                   	push   %ebx
  80212d:	e8 9a ff ff ff       	call   8020cc <strlen>
  802132:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  802135:	ff 75 0c             	pushl  0xc(%ebp)
  802138:	01 d8                	add    %ebx,%eax
  80213a:	50                   	push   %eax
  80213b:	e8 c5 ff ff ff       	call   802105 <strcpy>
	return dst;
}
  802140:	89 d8                	mov    %ebx,%eax
  802142:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802145:	c9                   	leave  
  802146:	c3                   	ret    

00802147 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  802147:	55                   	push   %ebp
  802148:	89 e5                	mov    %esp,%ebp
  80214a:	56                   	push   %esi
  80214b:	53                   	push   %ebx
  80214c:	8b 75 08             	mov    0x8(%ebp),%esi
  80214f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802152:	89 f3                	mov    %esi,%ebx
  802154:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802157:	89 f2                	mov    %esi,%edx
  802159:	eb 0f                	jmp    80216a <strncpy+0x23>
		*dst++ = *src;
  80215b:	83 c2 01             	add    $0x1,%edx
  80215e:	0f b6 01             	movzbl (%ecx),%eax
  802161:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  802164:	80 39 01             	cmpb   $0x1,(%ecx)
  802167:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80216a:	39 da                	cmp    %ebx,%edx
  80216c:	75 ed                	jne    80215b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80216e:	89 f0                	mov    %esi,%eax
  802170:	5b                   	pop    %ebx
  802171:	5e                   	pop    %esi
  802172:	5d                   	pop    %ebp
  802173:	c3                   	ret    

00802174 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  802174:	55                   	push   %ebp
  802175:	89 e5                	mov    %esp,%ebp
  802177:	56                   	push   %esi
  802178:	53                   	push   %ebx
  802179:	8b 75 08             	mov    0x8(%ebp),%esi
  80217c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80217f:	8b 55 10             	mov    0x10(%ebp),%edx
  802182:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  802184:	85 d2                	test   %edx,%edx
  802186:	74 21                	je     8021a9 <strlcpy+0x35>
  802188:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80218c:	89 f2                	mov    %esi,%edx
  80218e:	eb 09                	jmp    802199 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  802190:	83 c2 01             	add    $0x1,%edx
  802193:	83 c1 01             	add    $0x1,%ecx
  802196:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  802199:	39 c2                	cmp    %eax,%edx
  80219b:	74 09                	je     8021a6 <strlcpy+0x32>
  80219d:	0f b6 19             	movzbl (%ecx),%ebx
  8021a0:	84 db                	test   %bl,%bl
  8021a2:	75 ec                	jne    802190 <strlcpy+0x1c>
  8021a4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8021a6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8021a9:	29 f0                	sub    %esi,%eax
}
  8021ab:	5b                   	pop    %ebx
  8021ac:	5e                   	pop    %esi
  8021ad:	5d                   	pop    %ebp
  8021ae:	c3                   	ret    

008021af <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8021af:	55                   	push   %ebp
  8021b0:	89 e5                	mov    %esp,%ebp
  8021b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021b5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8021b8:	eb 06                	jmp    8021c0 <strcmp+0x11>
		p++, q++;
  8021ba:	83 c1 01             	add    $0x1,%ecx
  8021bd:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8021c0:	0f b6 01             	movzbl (%ecx),%eax
  8021c3:	84 c0                	test   %al,%al
  8021c5:	74 04                	je     8021cb <strcmp+0x1c>
  8021c7:	3a 02                	cmp    (%edx),%al
  8021c9:	74 ef                	je     8021ba <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8021cb:	0f b6 c0             	movzbl %al,%eax
  8021ce:	0f b6 12             	movzbl (%edx),%edx
  8021d1:	29 d0                	sub    %edx,%eax
}
  8021d3:	5d                   	pop    %ebp
  8021d4:	c3                   	ret    

008021d5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8021d5:	55                   	push   %ebp
  8021d6:	89 e5                	mov    %esp,%ebp
  8021d8:	53                   	push   %ebx
  8021d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8021dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021df:	89 c3                	mov    %eax,%ebx
  8021e1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8021e4:	eb 06                	jmp    8021ec <strncmp+0x17>
		n--, p++, q++;
  8021e6:	83 c0 01             	add    $0x1,%eax
  8021e9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8021ec:	39 d8                	cmp    %ebx,%eax
  8021ee:	74 15                	je     802205 <strncmp+0x30>
  8021f0:	0f b6 08             	movzbl (%eax),%ecx
  8021f3:	84 c9                	test   %cl,%cl
  8021f5:	74 04                	je     8021fb <strncmp+0x26>
  8021f7:	3a 0a                	cmp    (%edx),%cl
  8021f9:	74 eb                	je     8021e6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8021fb:	0f b6 00             	movzbl (%eax),%eax
  8021fe:	0f b6 12             	movzbl (%edx),%edx
  802201:	29 d0                	sub    %edx,%eax
  802203:	eb 05                	jmp    80220a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  802205:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80220a:	5b                   	pop    %ebx
  80220b:	5d                   	pop    %ebp
  80220c:	c3                   	ret    

0080220d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80220d:	55                   	push   %ebp
  80220e:	89 e5                	mov    %esp,%ebp
  802210:	8b 45 08             	mov    0x8(%ebp),%eax
  802213:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802217:	eb 07                	jmp    802220 <strchr+0x13>
		if (*s == c)
  802219:	38 ca                	cmp    %cl,%dl
  80221b:	74 0f                	je     80222c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80221d:	83 c0 01             	add    $0x1,%eax
  802220:	0f b6 10             	movzbl (%eax),%edx
  802223:	84 d2                	test   %dl,%dl
  802225:	75 f2                	jne    802219 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  802227:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80222c:	5d                   	pop    %ebp
  80222d:	c3                   	ret    

0080222e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80222e:	55                   	push   %ebp
  80222f:	89 e5                	mov    %esp,%ebp
  802231:	8b 45 08             	mov    0x8(%ebp),%eax
  802234:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802238:	eb 03                	jmp    80223d <strfind+0xf>
  80223a:	83 c0 01             	add    $0x1,%eax
  80223d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  802240:	38 ca                	cmp    %cl,%dl
  802242:	74 04                	je     802248 <strfind+0x1a>
  802244:	84 d2                	test   %dl,%dl
  802246:	75 f2                	jne    80223a <strfind+0xc>
			break;
	return (char *) s;
}
  802248:	5d                   	pop    %ebp
  802249:	c3                   	ret    

0080224a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80224a:	55                   	push   %ebp
  80224b:	89 e5                	mov    %esp,%ebp
  80224d:	57                   	push   %edi
  80224e:	56                   	push   %esi
  80224f:	53                   	push   %ebx
  802250:	8b 7d 08             	mov    0x8(%ebp),%edi
  802253:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  802256:	85 c9                	test   %ecx,%ecx
  802258:	74 36                	je     802290 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80225a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802260:	75 28                	jne    80228a <memset+0x40>
  802262:	f6 c1 03             	test   $0x3,%cl
  802265:	75 23                	jne    80228a <memset+0x40>
		c &= 0xFF;
  802267:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80226b:	89 d3                	mov    %edx,%ebx
  80226d:	c1 e3 08             	shl    $0x8,%ebx
  802270:	89 d6                	mov    %edx,%esi
  802272:	c1 e6 18             	shl    $0x18,%esi
  802275:	89 d0                	mov    %edx,%eax
  802277:	c1 e0 10             	shl    $0x10,%eax
  80227a:	09 f0                	or     %esi,%eax
  80227c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80227e:	89 d8                	mov    %ebx,%eax
  802280:	09 d0                	or     %edx,%eax
  802282:	c1 e9 02             	shr    $0x2,%ecx
  802285:	fc                   	cld    
  802286:	f3 ab                	rep stos %eax,%es:(%edi)
  802288:	eb 06                	jmp    802290 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80228a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80228d:	fc                   	cld    
  80228e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  802290:	89 f8                	mov    %edi,%eax
  802292:	5b                   	pop    %ebx
  802293:	5e                   	pop    %esi
  802294:	5f                   	pop    %edi
  802295:	5d                   	pop    %ebp
  802296:	c3                   	ret    

00802297 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802297:	55                   	push   %ebp
  802298:	89 e5                	mov    %esp,%ebp
  80229a:	57                   	push   %edi
  80229b:	56                   	push   %esi
  80229c:	8b 45 08             	mov    0x8(%ebp),%eax
  80229f:	8b 75 0c             	mov    0xc(%ebp),%esi
  8022a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8022a5:	39 c6                	cmp    %eax,%esi
  8022a7:	73 35                	jae    8022de <memmove+0x47>
  8022a9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8022ac:	39 d0                	cmp    %edx,%eax
  8022ae:	73 2e                	jae    8022de <memmove+0x47>
		s += n;
		d += n;
  8022b0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8022b3:	89 d6                	mov    %edx,%esi
  8022b5:	09 fe                	or     %edi,%esi
  8022b7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8022bd:	75 13                	jne    8022d2 <memmove+0x3b>
  8022bf:	f6 c1 03             	test   $0x3,%cl
  8022c2:	75 0e                	jne    8022d2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8022c4:	83 ef 04             	sub    $0x4,%edi
  8022c7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8022ca:	c1 e9 02             	shr    $0x2,%ecx
  8022cd:	fd                   	std    
  8022ce:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8022d0:	eb 09                	jmp    8022db <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8022d2:	83 ef 01             	sub    $0x1,%edi
  8022d5:	8d 72 ff             	lea    -0x1(%edx),%esi
  8022d8:	fd                   	std    
  8022d9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8022db:	fc                   	cld    
  8022dc:	eb 1d                	jmp    8022fb <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8022de:	89 f2                	mov    %esi,%edx
  8022e0:	09 c2                	or     %eax,%edx
  8022e2:	f6 c2 03             	test   $0x3,%dl
  8022e5:	75 0f                	jne    8022f6 <memmove+0x5f>
  8022e7:	f6 c1 03             	test   $0x3,%cl
  8022ea:	75 0a                	jne    8022f6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8022ec:	c1 e9 02             	shr    $0x2,%ecx
  8022ef:	89 c7                	mov    %eax,%edi
  8022f1:	fc                   	cld    
  8022f2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8022f4:	eb 05                	jmp    8022fb <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8022f6:	89 c7                	mov    %eax,%edi
  8022f8:	fc                   	cld    
  8022f9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8022fb:	5e                   	pop    %esi
  8022fc:	5f                   	pop    %edi
  8022fd:	5d                   	pop    %ebp
  8022fe:	c3                   	ret    

008022ff <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8022ff:	55                   	push   %ebp
  802300:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  802302:	ff 75 10             	pushl  0x10(%ebp)
  802305:	ff 75 0c             	pushl  0xc(%ebp)
  802308:	ff 75 08             	pushl  0x8(%ebp)
  80230b:	e8 87 ff ff ff       	call   802297 <memmove>
}
  802310:	c9                   	leave  
  802311:	c3                   	ret    

00802312 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  802312:	55                   	push   %ebp
  802313:	89 e5                	mov    %esp,%ebp
  802315:	56                   	push   %esi
  802316:	53                   	push   %ebx
  802317:	8b 45 08             	mov    0x8(%ebp),%eax
  80231a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80231d:	89 c6                	mov    %eax,%esi
  80231f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802322:	eb 1a                	jmp    80233e <memcmp+0x2c>
		if (*s1 != *s2)
  802324:	0f b6 08             	movzbl (%eax),%ecx
  802327:	0f b6 1a             	movzbl (%edx),%ebx
  80232a:	38 d9                	cmp    %bl,%cl
  80232c:	74 0a                	je     802338 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80232e:	0f b6 c1             	movzbl %cl,%eax
  802331:	0f b6 db             	movzbl %bl,%ebx
  802334:	29 d8                	sub    %ebx,%eax
  802336:	eb 0f                	jmp    802347 <memcmp+0x35>
		s1++, s2++;
  802338:	83 c0 01             	add    $0x1,%eax
  80233b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80233e:	39 f0                	cmp    %esi,%eax
  802340:	75 e2                	jne    802324 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  802342:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802347:	5b                   	pop    %ebx
  802348:	5e                   	pop    %esi
  802349:	5d                   	pop    %ebp
  80234a:	c3                   	ret    

0080234b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80234b:	55                   	push   %ebp
  80234c:	89 e5                	mov    %esp,%ebp
  80234e:	53                   	push   %ebx
  80234f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  802352:	89 c1                	mov    %eax,%ecx
  802354:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  802357:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80235b:	eb 0a                	jmp    802367 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80235d:	0f b6 10             	movzbl (%eax),%edx
  802360:	39 da                	cmp    %ebx,%edx
  802362:	74 07                	je     80236b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802364:	83 c0 01             	add    $0x1,%eax
  802367:	39 c8                	cmp    %ecx,%eax
  802369:	72 f2                	jb     80235d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80236b:	5b                   	pop    %ebx
  80236c:	5d                   	pop    %ebp
  80236d:	c3                   	ret    

0080236e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80236e:	55                   	push   %ebp
  80236f:	89 e5                	mov    %esp,%ebp
  802371:	57                   	push   %edi
  802372:	56                   	push   %esi
  802373:	53                   	push   %ebx
  802374:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802377:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80237a:	eb 03                	jmp    80237f <strtol+0x11>
		s++;
  80237c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80237f:	0f b6 01             	movzbl (%ecx),%eax
  802382:	3c 20                	cmp    $0x20,%al
  802384:	74 f6                	je     80237c <strtol+0xe>
  802386:	3c 09                	cmp    $0x9,%al
  802388:	74 f2                	je     80237c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80238a:	3c 2b                	cmp    $0x2b,%al
  80238c:	75 0a                	jne    802398 <strtol+0x2a>
		s++;
  80238e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  802391:	bf 00 00 00 00       	mov    $0x0,%edi
  802396:	eb 11                	jmp    8023a9 <strtol+0x3b>
  802398:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80239d:	3c 2d                	cmp    $0x2d,%al
  80239f:	75 08                	jne    8023a9 <strtol+0x3b>
		s++, neg = 1;
  8023a1:	83 c1 01             	add    $0x1,%ecx
  8023a4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8023a9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8023af:	75 15                	jne    8023c6 <strtol+0x58>
  8023b1:	80 39 30             	cmpb   $0x30,(%ecx)
  8023b4:	75 10                	jne    8023c6 <strtol+0x58>
  8023b6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8023ba:	75 7c                	jne    802438 <strtol+0xca>
		s += 2, base = 16;
  8023bc:	83 c1 02             	add    $0x2,%ecx
  8023bf:	bb 10 00 00 00       	mov    $0x10,%ebx
  8023c4:	eb 16                	jmp    8023dc <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8023c6:	85 db                	test   %ebx,%ebx
  8023c8:	75 12                	jne    8023dc <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8023ca:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8023cf:	80 39 30             	cmpb   $0x30,(%ecx)
  8023d2:	75 08                	jne    8023dc <strtol+0x6e>
		s++, base = 8;
  8023d4:	83 c1 01             	add    $0x1,%ecx
  8023d7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8023dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8023e1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8023e4:	0f b6 11             	movzbl (%ecx),%edx
  8023e7:	8d 72 d0             	lea    -0x30(%edx),%esi
  8023ea:	89 f3                	mov    %esi,%ebx
  8023ec:	80 fb 09             	cmp    $0x9,%bl
  8023ef:	77 08                	ja     8023f9 <strtol+0x8b>
			dig = *s - '0';
  8023f1:	0f be d2             	movsbl %dl,%edx
  8023f4:	83 ea 30             	sub    $0x30,%edx
  8023f7:	eb 22                	jmp    80241b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8023f9:	8d 72 9f             	lea    -0x61(%edx),%esi
  8023fc:	89 f3                	mov    %esi,%ebx
  8023fe:	80 fb 19             	cmp    $0x19,%bl
  802401:	77 08                	ja     80240b <strtol+0x9d>
			dig = *s - 'a' + 10;
  802403:	0f be d2             	movsbl %dl,%edx
  802406:	83 ea 57             	sub    $0x57,%edx
  802409:	eb 10                	jmp    80241b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80240b:	8d 72 bf             	lea    -0x41(%edx),%esi
  80240e:	89 f3                	mov    %esi,%ebx
  802410:	80 fb 19             	cmp    $0x19,%bl
  802413:	77 16                	ja     80242b <strtol+0xbd>
			dig = *s - 'A' + 10;
  802415:	0f be d2             	movsbl %dl,%edx
  802418:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80241b:	3b 55 10             	cmp    0x10(%ebp),%edx
  80241e:	7d 0b                	jge    80242b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  802420:	83 c1 01             	add    $0x1,%ecx
  802423:	0f af 45 10          	imul   0x10(%ebp),%eax
  802427:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  802429:	eb b9                	jmp    8023e4 <strtol+0x76>

	if (endptr)
  80242b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80242f:	74 0d                	je     80243e <strtol+0xd0>
		*endptr = (char *) s;
  802431:	8b 75 0c             	mov    0xc(%ebp),%esi
  802434:	89 0e                	mov    %ecx,(%esi)
  802436:	eb 06                	jmp    80243e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802438:	85 db                	test   %ebx,%ebx
  80243a:	74 98                	je     8023d4 <strtol+0x66>
  80243c:	eb 9e                	jmp    8023dc <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80243e:	89 c2                	mov    %eax,%edx
  802440:	f7 da                	neg    %edx
  802442:	85 ff                	test   %edi,%edi
  802444:	0f 45 c2             	cmovne %edx,%eax
}
  802447:	5b                   	pop    %ebx
  802448:	5e                   	pop    %esi
  802449:	5f                   	pop    %edi
  80244a:	5d                   	pop    %ebp
  80244b:	c3                   	ret    

0080244c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80244c:	55                   	push   %ebp
  80244d:	89 e5                	mov    %esp,%ebp
  80244f:	57                   	push   %edi
  802450:	56                   	push   %esi
  802451:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802452:	b8 00 00 00 00       	mov    $0x0,%eax
  802457:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80245a:	8b 55 08             	mov    0x8(%ebp),%edx
  80245d:	89 c3                	mov    %eax,%ebx
  80245f:	89 c7                	mov    %eax,%edi
  802461:	89 c6                	mov    %eax,%esi
  802463:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  802465:	5b                   	pop    %ebx
  802466:	5e                   	pop    %esi
  802467:	5f                   	pop    %edi
  802468:	5d                   	pop    %ebp
  802469:	c3                   	ret    

0080246a <sys_cgetc>:

int
sys_cgetc(void)
{
  80246a:	55                   	push   %ebp
  80246b:	89 e5                	mov    %esp,%ebp
  80246d:	57                   	push   %edi
  80246e:	56                   	push   %esi
  80246f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802470:	ba 00 00 00 00       	mov    $0x0,%edx
  802475:	b8 01 00 00 00       	mov    $0x1,%eax
  80247a:	89 d1                	mov    %edx,%ecx
  80247c:	89 d3                	mov    %edx,%ebx
  80247e:	89 d7                	mov    %edx,%edi
  802480:	89 d6                	mov    %edx,%esi
  802482:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  802484:	5b                   	pop    %ebx
  802485:	5e                   	pop    %esi
  802486:	5f                   	pop    %edi
  802487:	5d                   	pop    %ebp
  802488:	c3                   	ret    

00802489 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  802489:	55                   	push   %ebp
  80248a:	89 e5                	mov    %esp,%ebp
  80248c:	57                   	push   %edi
  80248d:	56                   	push   %esi
  80248e:	53                   	push   %ebx
  80248f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802492:	b9 00 00 00 00       	mov    $0x0,%ecx
  802497:	b8 03 00 00 00       	mov    $0x3,%eax
  80249c:	8b 55 08             	mov    0x8(%ebp),%edx
  80249f:	89 cb                	mov    %ecx,%ebx
  8024a1:	89 cf                	mov    %ecx,%edi
  8024a3:	89 ce                	mov    %ecx,%esi
  8024a5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8024a7:	85 c0                	test   %eax,%eax
  8024a9:	7e 17                	jle    8024c2 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8024ab:	83 ec 0c             	sub    $0xc,%esp
  8024ae:	50                   	push   %eax
  8024af:	6a 03                	push   $0x3
  8024b1:	68 3f 44 80 00       	push   $0x80443f
  8024b6:	6a 23                	push   $0x23
  8024b8:	68 5c 44 80 00       	push   $0x80445c
  8024bd:	e8 e5 f5 ff ff       	call   801aa7 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8024c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024c5:	5b                   	pop    %ebx
  8024c6:	5e                   	pop    %esi
  8024c7:	5f                   	pop    %edi
  8024c8:	5d                   	pop    %ebp
  8024c9:	c3                   	ret    

008024ca <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8024ca:	55                   	push   %ebp
  8024cb:	89 e5                	mov    %esp,%ebp
  8024cd:	57                   	push   %edi
  8024ce:	56                   	push   %esi
  8024cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8024d5:	b8 02 00 00 00       	mov    $0x2,%eax
  8024da:	89 d1                	mov    %edx,%ecx
  8024dc:	89 d3                	mov    %edx,%ebx
  8024de:	89 d7                	mov    %edx,%edi
  8024e0:	89 d6                	mov    %edx,%esi
  8024e2:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8024e4:	5b                   	pop    %ebx
  8024e5:	5e                   	pop    %esi
  8024e6:	5f                   	pop    %edi
  8024e7:	5d                   	pop    %ebp
  8024e8:	c3                   	ret    

008024e9 <sys_yield>:

void
sys_yield(void)
{
  8024e9:	55                   	push   %ebp
  8024ea:	89 e5                	mov    %esp,%ebp
  8024ec:	57                   	push   %edi
  8024ed:	56                   	push   %esi
  8024ee:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8024f4:	b8 0b 00 00 00       	mov    $0xb,%eax
  8024f9:	89 d1                	mov    %edx,%ecx
  8024fb:	89 d3                	mov    %edx,%ebx
  8024fd:	89 d7                	mov    %edx,%edi
  8024ff:	89 d6                	mov    %edx,%esi
  802501:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  802503:	5b                   	pop    %ebx
  802504:	5e                   	pop    %esi
  802505:	5f                   	pop    %edi
  802506:	5d                   	pop    %ebp
  802507:	c3                   	ret    

00802508 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  802508:	55                   	push   %ebp
  802509:	89 e5                	mov    %esp,%ebp
  80250b:	57                   	push   %edi
  80250c:	56                   	push   %esi
  80250d:	53                   	push   %ebx
  80250e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802511:	be 00 00 00 00       	mov    $0x0,%esi
  802516:	b8 04 00 00 00       	mov    $0x4,%eax
  80251b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80251e:	8b 55 08             	mov    0x8(%ebp),%edx
  802521:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802524:	89 f7                	mov    %esi,%edi
  802526:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802528:	85 c0                	test   %eax,%eax
  80252a:	7e 17                	jle    802543 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80252c:	83 ec 0c             	sub    $0xc,%esp
  80252f:	50                   	push   %eax
  802530:	6a 04                	push   $0x4
  802532:	68 3f 44 80 00       	push   $0x80443f
  802537:	6a 23                	push   $0x23
  802539:	68 5c 44 80 00       	push   $0x80445c
  80253e:	e8 64 f5 ff ff       	call   801aa7 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  802543:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802546:	5b                   	pop    %ebx
  802547:	5e                   	pop    %esi
  802548:	5f                   	pop    %edi
  802549:	5d                   	pop    %ebp
  80254a:	c3                   	ret    

0080254b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80254b:	55                   	push   %ebp
  80254c:	89 e5                	mov    %esp,%ebp
  80254e:	57                   	push   %edi
  80254f:	56                   	push   %esi
  802550:	53                   	push   %ebx
  802551:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802554:	b8 05 00 00 00       	mov    $0x5,%eax
  802559:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80255c:	8b 55 08             	mov    0x8(%ebp),%edx
  80255f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802562:	8b 7d 14             	mov    0x14(%ebp),%edi
  802565:	8b 75 18             	mov    0x18(%ebp),%esi
  802568:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80256a:	85 c0                	test   %eax,%eax
  80256c:	7e 17                	jle    802585 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80256e:	83 ec 0c             	sub    $0xc,%esp
  802571:	50                   	push   %eax
  802572:	6a 05                	push   $0x5
  802574:	68 3f 44 80 00       	push   $0x80443f
  802579:	6a 23                	push   $0x23
  80257b:	68 5c 44 80 00       	push   $0x80445c
  802580:	e8 22 f5 ff ff       	call   801aa7 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  802585:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802588:	5b                   	pop    %ebx
  802589:	5e                   	pop    %esi
  80258a:	5f                   	pop    %edi
  80258b:	5d                   	pop    %ebp
  80258c:	c3                   	ret    

0080258d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80258d:	55                   	push   %ebp
  80258e:	89 e5                	mov    %esp,%ebp
  802590:	57                   	push   %edi
  802591:	56                   	push   %esi
  802592:	53                   	push   %ebx
  802593:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802596:	bb 00 00 00 00       	mov    $0x0,%ebx
  80259b:	b8 06 00 00 00       	mov    $0x6,%eax
  8025a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8025a6:	89 df                	mov    %ebx,%edi
  8025a8:	89 de                	mov    %ebx,%esi
  8025aa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8025ac:	85 c0                	test   %eax,%eax
  8025ae:	7e 17                	jle    8025c7 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025b0:	83 ec 0c             	sub    $0xc,%esp
  8025b3:	50                   	push   %eax
  8025b4:	6a 06                	push   $0x6
  8025b6:	68 3f 44 80 00       	push   $0x80443f
  8025bb:	6a 23                	push   $0x23
  8025bd:	68 5c 44 80 00       	push   $0x80445c
  8025c2:	e8 e0 f4 ff ff       	call   801aa7 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8025c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025ca:	5b                   	pop    %ebx
  8025cb:	5e                   	pop    %esi
  8025cc:	5f                   	pop    %edi
  8025cd:	5d                   	pop    %ebp
  8025ce:	c3                   	ret    

008025cf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8025cf:	55                   	push   %ebp
  8025d0:	89 e5                	mov    %esp,%ebp
  8025d2:	57                   	push   %edi
  8025d3:	56                   	push   %esi
  8025d4:	53                   	push   %ebx
  8025d5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8025dd:	b8 08 00 00 00       	mov    $0x8,%eax
  8025e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8025e8:	89 df                	mov    %ebx,%edi
  8025ea:	89 de                	mov    %ebx,%esi
  8025ec:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8025ee:	85 c0                	test   %eax,%eax
  8025f0:	7e 17                	jle    802609 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025f2:	83 ec 0c             	sub    $0xc,%esp
  8025f5:	50                   	push   %eax
  8025f6:	6a 08                	push   $0x8
  8025f8:	68 3f 44 80 00       	push   $0x80443f
  8025fd:	6a 23                	push   $0x23
  8025ff:	68 5c 44 80 00       	push   $0x80445c
  802604:	e8 9e f4 ff ff       	call   801aa7 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  802609:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80260c:	5b                   	pop    %ebx
  80260d:	5e                   	pop    %esi
  80260e:	5f                   	pop    %edi
  80260f:	5d                   	pop    %ebp
  802610:	c3                   	ret    

00802611 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  802611:	55                   	push   %ebp
  802612:	89 e5                	mov    %esp,%ebp
  802614:	57                   	push   %edi
  802615:	56                   	push   %esi
  802616:	53                   	push   %ebx
  802617:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80261a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80261f:	b8 09 00 00 00       	mov    $0x9,%eax
  802624:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802627:	8b 55 08             	mov    0x8(%ebp),%edx
  80262a:	89 df                	mov    %ebx,%edi
  80262c:	89 de                	mov    %ebx,%esi
  80262e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802630:	85 c0                	test   %eax,%eax
  802632:	7e 17                	jle    80264b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802634:	83 ec 0c             	sub    $0xc,%esp
  802637:	50                   	push   %eax
  802638:	6a 09                	push   $0x9
  80263a:	68 3f 44 80 00       	push   $0x80443f
  80263f:	6a 23                	push   $0x23
  802641:	68 5c 44 80 00       	push   $0x80445c
  802646:	e8 5c f4 ff ff       	call   801aa7 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80264b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80264e:	5b                   	pop    %ebx
  80264f:	5e                   	pop    %esi
  802650:	5f                   	pop    %edi
  802651:	5d                   	pop    %ebp
  802652:	c3                   	ret    

00802653 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  802653:	55                   	push   %ebp
  802654:	89 e5                	mov    %esp,%ebp
  802656:	57                   	push   %edi
  802657:	56                   	push   %esi
  802658:	53                   	push   %ebx
  802659:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80265c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802661:	b8 0a 00 00 00       	mov    $0xa,%eax
  802666:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802669:	8b 55 08             	mov    0x8(%ebp),%edx
  80266c:	89 df                	mov    %ebx,%edi
  80266e:	89 de                	mov    %ebx,%esi
  802670:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802672:	85 c0                	test   %eax,%eax
  802674:	7e 17                	jle    80268d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802676:	83 ec 0c             	sub    $0xc,%esp
  802679:	50                   	push   %eax
  80267a:	6a 0a                	push   $0xa
  80267c:	68 3f 44 80 00       	push   $0x80443f
  802681:	6a 23                	push   $0x23
  802683:	68 5c 44 80 00       	push   $0x80445c
  802688:	e8 1a f4 ff ff       	call   801aa7 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80268d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802690:	5b                   	pop    %ebx
  802691:	5e                   	pop    %esi
  802692:	5f                   	pop    %edi
  802693:	5d                   	pop    %ebp
  802694:	c3                   	ret    

00802695 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  802695:	55                   	push   %ebp
  802696:	89 e5                	mov    %esp,%ebp
  802698:	57                   	push   %edi
  802699:	56                   	push   %esi
  80269a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80269b:	be 00 00 00 00       	mov    $0x0,%esi
  8026a0:	b8 0c 00 00 00       	mov    $0xc,%eax
  8026a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8026ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8026ae:	8b 7d 14             	mov    0x14(%ebp),%edi
  8026b1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8026b3:	5b                   	pop    %ebx
  8026b4:	5e                   	pop    %esi
  8026b5:	5f                   	pop    %edi
  8026b6:	5d                   	pop    %ebp
  8026b7:	c3                   	ret    

008026b8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8026b8:	55                   	push   %ebp
  8026b9:	89 e5                	mov    %esp,%ebp
  8026bb:	57                   	push   %edi
  8026bc:	56                   	push   %esi
  8026bd:	53                   	push   %ebx
  8026be:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8026c6:	b8 0d 00 00 00       	mov    $0xd,%eax
  8026cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8026ce:	89 cb                	mov    %ecx,%ebx
  8026d0:	89 cf                	mov    %ecx,%edi
  8026d2:	89 ce                	mov    %ecx,%esi
  8026d4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8026d6:	85 c0                	test   %eax,%eax
  8026d8:	7e 17                	jle    8026f1 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8026da:	83 ec 0c             	sub    $0xc,%esp
  8026dd:	50                   	push   %eax
  8026de:	6a 0d                	push   $0xd
  8026e0:	68 3f 44 80 00       	push   $0x80443f
  8026e5:	6a 23                	push   $0x23
  8026e7:	68 5c 44 80 00       	push   $0x80445c
  8026ec:	e8 b6 f3 ff ff       	call   801aa7 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8026f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026f4:	5b                   	pop    %ebx
  8026f5:	5e                   	pop    %esi
  8026f6:	5f                   	pop    %edi
  8026f7:	5d                   	pop    %ebp
  8026f8:	c3                   	ret    

008026f9 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  8026f9:	55                   	push   %ebp
  8026fa:	89 e5                	mov    %esp,%ebp
  8026fc:	57                   	push   %edi
  8026fd:	56                   	push   %esi
  8026fe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  802704:	b8 0e 00 00 00       	mov    $0xe,%eax
  802709:	8b 55 08             	mov    0x8(%ebp),%edx
  80270c:	89 cb                	mov    %ecx,%ebx
  80270e:	89 cf                	mov    %ecx,%edi
  802710:	89 ce                	mov    %ecx,%esi
  802712:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  802714:	5b                   	pop    %ebx
  802715:	5e                   	pop    %esi
  802716:	5f                   	pop    %edi
  802717:	5d                   	pop    %ebp
  802718:	c3                   	ret    

00802719 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  802719:	55                   	push   %ebp
  80271a:	89 e5                	mov    %esp,%ebp
  80271c:	57                   	push   %edi
  80271d:	56                   	push   %esi
  80271e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80271f:	b9 00 00 00 00       	mov    $0x0,%ecx
  802724:	b8 0f 00 00 00       	mov    $0xf,%eax
  802729:	8b 55 08             	mov    0x8(%ebp),%edx
  80272c:	89 cb                	mov    %ecx,%ebx
  80272e:	89 cf                	mov    %ecx,%edi
  802730:	89 ce                	mov    %ecx,%esi
  802732:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  802734:	5b                   	pop    %ebx
  802735:	5e                   	pop    %esi
  802736:	5f                   	pop    %edi
  802737:	5d                   	pop    %ebp
  802738:	c3                   	ret    

00802739 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802739:	55                   	push   %ebp
  80273a:	89 e5                	mov    %esp,%ebp
  80273c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80273f:	83 3d 10 a0 80 00 00 	cmpl   $0x0,0x80a010
  802746:	75 2a                	jne    802772 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802748:	83 ec 04             	sub    $0x4,%esp
  80274b:	6a 07                	push   $0x7
  80274d:	68 00 f0 bf ee       	push   $0xeebff000
  802752:	6a 00                	push   $0x0
  802754:	e8 af fd ff ff       	call   802508 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802759:	83 c4 10             	add    $0x10,%esp
  80275c:	85 c0                	test   %eax,%eax
  80275e:	79 12                	jns    802772 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802760:	50                   	push   %eax
  802761:	68 6a 44 80 00       	push   $0x80446a
  802766:	6a 23                	push   $0x23
  802768:	68 6e 44 80 00       	push   $0x80446e
  80276d:	e8 35 f3 ff ff       	call   801aa7 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802772:	8b 45 08             	mov    0x8(%ebp),%eax
  802775:	a3 10 a0 80 00       	mov    %eax,0x80a010
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80277a:	83 ec 08             	sub    $0x8,%esp
  80277d:	68 a4 27 80 00       	push   $0x8027a4
  802782:	6a 00                	push   $0x0
  802784:	e8 ca fe ff ff       	call   802653 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802789:	83 c4 10             	add    $0x10,%esp
  80278c:	85 c0                	test   %eax,%eax
  80278e:	79 12                	jns    8027a2 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802790:	50                   	push   %eax
  802791:	68 6a 44 80 00       	push   $0x80446a
  802796:	6a 2c                	push   $0x2c
  802798:	68 6e 44 80 00       	push   $0x80446e
  80279d:	e8 05 f3 ff ff       	call   801aa7 <_panic>
	}
}
  8027a2:	c9                   	leave  
  8027a3:	c3                   	ret    

008027a4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8027a4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8027a5:	a1 10 a0 80 00       	mov    0x80a010,%eax
	call *%eax
  8027aa:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8027ac:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8027af:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8027b3:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8027b8:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8027bc:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8027be:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8027c1:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8027c2:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8027c5:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8027c6:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8027c7:	c3                   	ret    

008027c8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8027c8:	55                   	push   %ebp
  8027c9:	89 e5                	mov    %esp,%ebp
  8027cb:	53                   	push   %ebx
  8027cc:	83 ec 04             	sub    $0x4,%esp
  8027cf:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8027d2:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8027d4:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8027d8:	74 11                	je     8027eb <pgfault+0x23>
  8027da:	89 d8                	mov    %ebx,%eax
  8027dc:	c1 e8 0c             	shr    $0xc,%eax
  8027df:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8027e6:	f6 c4 08             	test   $0x8,%ah
  8027e9:	75 14                	jne    8027ff <pgfault+0x37>
		panic("faulting access");
  8027eb:	83 ec 04             	sub    $0x4,%esp
  8027ee:	68 7c 44 80 00       	push   $0x80447c
  8027f3:	6a 1e                	push   $0x1e
  8027f5:	68 8c 44 80 00       	push   $0x80448c
  8027fa:	e8 a8 f2 ff ff       	call   801aa7 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  8027ff:	83 ec 04             	sub    $0x4,%esp
  802802:	6a 07                	push   $0x7
  802804:	68 00 f0 7f 00       	push   $0x7ff000
  802809:	6a 00                	push   $0x0
  80280b:	e8 f8 fc ff ff       	call   802508 <sys_page_alloc>
	if (r < 0) {
  802810:	83 c4 10             	add    $0x10,%esp
  802813:	85 c0                	test   %eax,%eax
  802815:	79 12                	jns    802829 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  802817:	50                   	push   %eax
  802818:	68 97 44 80 00       	push   $0x804497
  80281d:	6a 2c                	push   $0x2c
  80281f:	68 8c 44 80 00       	push   $0x80448c
  802824:	e8 7e f2 ff ff       	call   801aa7 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  802829:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  80282f:	83 ec 04             	sub    $0x4,%esp
  802832:	68 00 10 00 00       	push   $0x1000
  802837:	53                   	push   %ebx
  802838:	68 00 f0 7f 00       	push   $0x7ff000
  80283d:	e8 bd fa ff ff       	call   8022ff <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  802842:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  802849:	53                   	push   %ebx
  80284a:	6a 00                	push   $0x0
  80284c:	68 00 f0 7f 00       	push   $0x7ff000
  802851:	6a 00                	push   $0x0
  802853:	e8 f3 fc ff ff       	call   80254b <sys_page_map>
	if (r < 0) {
  802858:	83 c4 20             	add    $0x20,%esp
  80285b:	85 c0                	test   %eax,%eax
  80285d:	79 12                	jns    802871 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  80285f:	50                   	push   %eax
  802860:	68 97 44 80 00       	push   $0x804497
  802865:	6a 33                	push   $0x33
  802867:	68 8c 44 80 00       	push   $0x80448c
  80286c:	e8 36 f2 ff ff       	call   801aa7 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  802871:	83 ec 08             	sub    $0x8,%esp
  802874:	68 00 f0 7f 00       	push   $0x7ff000
  802879:	6a 00                	push   $0x0
  80287b:	e8 0d fd ff ff       	call   80258d <sys_page_unmap>
	if (r < 0) {
  802880:	83 c4 10             	add    $0x10,%esp
  802883:	85 c0                	test   %eax,%eax
  802885:	79 12                	jns    802899 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  802887:	50                   	push   %eax
  802888:	68 97 44 80 00       	push   $0x804497
  80288d:	6a 37                	push   $0x37
  80288f:	68 8c 44 80 00       	push   $0x80448c
  802894:	e8 0e f2 ff ff       	call   801aa7 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  802899:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80289c:	c9                   	leave  
  80289d:	c3                   	ret    

0080289e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80289e:	55                   	push   %ebp
  80289f:	89 e5                	mov    %esp,%ebp
  8028a1:	57                   	push   %edi
  8028a2:	56                   	push   %esi
  8028a3:	53                   	push   %ebx
  8028a4:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  8028a7:	68 c8 27 80 00       	push   $0x8027c8
  8028ac:	e8 88 fe ff ff       	call   802739 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8028b1:	b8 07 00 00 00       	mov    $0x7,%eax
  8028b6:	cd 30                	int    $0x30
  8028b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8028bb:	83 c4 10             	add    $0x10,%esp
  8028be:	85 c0                	test   %eax,%eax
  8028c0:	79 17                	jns    8028d9 <fork+0x3b>
		panic("fork fault %e");
  8028c2:	83 ec 04             	sub    $0x4,%esp
  8028c5:	68 b0 44 80 00       	push   $0x8044b0
  8028ca:	68 84 00 00 00       	push   $0x84
  8028cf:	68 8c 44 80 00       	push   $0x80448c
  8028d4:	e8 ce f1 ff ff       	call   801aa7 <_panic>
  8028d9:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8028db:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8028df:	75 25                	jne    802906 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  8028e1:	e8 e4 fb ff ff       	call   8024ca <sys_getenvid>
  8028e6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8028eb:	89 c2                	mov    %eax,%edx
  8028ed:	c1 e2 07             	shl    $0x7,%edx
  8028f0:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8028f7:	a3 0c a0 80 00       	mov    %eax,0x80a00c
		return 0;
  8028fc:	b8 00 00 00 00       	mov    $0x0,%eax
  802901:	e9 61 01 00 00       	jmp    802a67 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  802906:	83 ec 04             	sub    $0x4,%esp
  802909:	6a 07                	push   $0x7
  80290b:	68 00 f0 bf ee       	push   $0xeebff000
  802910:	ff 75 e4             	pushl  -0x1c(%ebp)
  802913:	e8 f0 fb ff ff       	call   802508 <sys_page_alloc>
  802918:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80291b:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  802920:	89 d8                	mov    %ebx,%eax
  802922:	c1 e8 16             	shr    $0x16,%eax
  802925:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80292c:	a8 01                	test   $0x1,%al
  80292e:	0f 84 fc 00 00 00    	je     802a30 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  802934:	89 d8                	mov    %ebx,%eax
  802936:	c1 e8 0c             	shr    $0xc,%eax
  802939:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  802940:	f6 c2 01             	test   $0x1,%dl
  802943:	0f 84 e7 00 00 00    	je     802a30 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  802949:	89 c6                	mov    %eax,%esi
  80294b:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  80294e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802955:	f6 c6 04             	test   $0x4,%dh
  802958:	74 39                	je     802993 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80295a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802961:	83 ec 0c             	sub    $0xc,%esp
  802964:	25 07 0e 00 00       	and    $0xe07,%eax
  802969:	50                   	push   %eax
  80296a:	56                   	push   %esi
  80296b:	57                   	push   %edi
  80296c:	56                   	push   %esi
  80296d:	6a 00                	push   $0x0
  80296f:	e8 d7 fb ff ff       	call   80254b <sys_page_map>
		if (r < 0) {
  802974:	83 c4 20             	add    $0x20,%esp
  802977:	85 c0                	test   %eax,%eax
  802979:	0f 89 b1 00 00 00    	jns    802a30 <fork+0x192>
		    	panic("sys page map fault %e");
  80297f:	83 ec 04             	sub    $0x4,%esp
  802982:	68 be 44 80 00       	push   $0x8044be
  802987:	6a 54                	push   $0x54
  802989:	68 8c 44 80 00       	push   $0x80448c
  80298e:	e8 14 f1 ff ff       	call   801aa7 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  802993:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80299a:	f6 c2 02             	test   $0x2,%dl
  80299d:	75 0c                	jne    8029ab <fork+0x10d>
  80299f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8029a6:	f6 c4 08             	test   $0x8,%ah
  8029a9:	74 5b                	je     802a06 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8029ab:	83 ec 0c             	sub    $0xc,%esp
  8029ae:	68 05 08 00 00       	push   $0x805
  8029b3:	56                   	push   %esi
  8029b4:	57                   	push   %edi
  8029b5:	56                   	push   %esi
  8029b6:	6a 00                	push   $0x0
  8029b8:	e8 8e fb ff ff       	call   80254b <sys_page_map>
		if (r < 0) {
  8029bd:	83 c4 20             	add    $0x20,%esp
  8029c0:	85 c0                	test   %eax,%eax
  8029c2:	79 14                	jns    8029d8 <fork+0x13a>
		    	panic("sys page map fault %e");
  8029c4:	83 ec 04             	sub    $0x4,%esp
  8029c7:	68 be 44 80 00       	push   $0x8044be
  8029cc:	6a 5b                	push   $0x5b
  8029ce:	68 8c 44 80 00       	push   $0x80448c
  8029d3:	e8 cf f0 ff ff       	call   801aa7 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8029d8:	83 ec 0c             	sub    $0xc,%esp
  8029db:	68 05 08 00 00       	push   $0x805
  8029e0:	56                   	push   %esi
  8029e1:	6a 00                	push   $0x0
  8029e3:	56                   	push   %esi
  8029e4:	6a 00                	push   $0x0
  8029e6:	e8 60 fb ff ff       	call   80254b <sys_page_map>
		if (r < 0) {
  8029eb:	83 c4 20             	add    $0x20,%esp
  8029ee:	85 c0                	test   %eax,%eax
  8029f0:	79 3e                	jns    802a30 <fork+0x192>
		    	panic("sys page map fault %e");
  8029f2:	83 ec 04             	sub    $0x4,%esp
  8029f5:	68 be 44 80 00       	push   $0x8044be
  8029fa:	6a 5f                	push   $0x5f
  8029fc:	68 8c 44 80 00       	push   $0x80448c
  802a01:	e8 a1 f0 ff ff       	call   801aa7 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  802a06:	83 ec 0c             	sub    $0xc,%esp
  802a09:	6a 05                	push   $0x5
  802a0b:	56                   	push   %esi
  802a0c:	57                   	push   %edi
  802a0d:	56                   	push   %esi
  802a0e:	6a 00                	push   $0x0
  802a10:	e8 36 fb ff ff       	call   80254b <sys_page_map>
		if (r < 0) {
  802a15:	83 c4 20             	add    $0x20,%esp
  802a18:	85 c0                	test   %eax,%eax
  802a1a:	79 14                	jns    802a30 <fork+0x192>
		    	panic("sys page map fault %e");
  802a1c:	83 ec 04             	sub    $0x4,%esp
  802a1f:	68 be 44 80 00       	push   $0x8044be
  802a24:	6a 64                	push   $0x64
  802a26:	68 8c 44 80 00       	push   $0x80448c
  802a2b:	e8 77 f0 ff ff       	call   801aa7 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  802a30:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802a36:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  802a3c:	0f 85 de fe ff ff    	jne    802920 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  802a42:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802a47:	8b 40 70             	mov    0x70(%eax),%eax
  802a4a:	83 ec 08             	sub    $0x8,%esp
  802a4d:	50                   	push   %eax
  802a4e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  802a51:	57                   	push   %edi
  802a52:	e8 fc fb ff ff       	call   802653 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  802a57:	83 c4 08             	add    $0x8,%esp
  802a5a:	6a 02                	push   $0x2
  802a5c:	57                   	push   %edi
  802a5d:	e8 6d fb ff ff       	call   8025cf <sys_env_set_status>
	
	return envid;
  802a62:	83 c4 10             	add    $0x10,%esp
  802a65:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  802a67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a6a:	5b                   	pop    %ebx
  802a6b:	5e                   	pop    %esi
  802a6c:	5f                   	pop    %edi
  802a6d:	5d                   	pop    %ebp
  802a6e:	c3                   	ret    

00802a6f <sfork>:

envid_t
sfork(void)
{
  802a6f:	55                   	push   %ebp
  802a70:	89 e5                	mov    %esp,%ebp
	return 0;
}
  802a72:	b8 00 00 00 00       	mov    $0x0,%eax
  802a77:	5d                   	pop    %ebp
  802a78:	c3                   	ret    

00802a79 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  802a79:	55                   	push   %ebp
  802a7a:	89 e5                	mov    %esp,%ebp
  802a7c:	56                   	push   %esi
  802a7d:	53                   	push   %ebx
  802a7e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  802a81:	89 1d 14 a0 80 00    	mov    %ebx,0x80a014
	cprintf("in fork.c thread create. func: %x\n", func);
  802a87:	83 ec 08             	sub    $0x8,%esp
  802a8a:	53                   	push   %ebx
  802a8b:	68 d4 44 80 00       	push   $0x8044d4
  802a90:	e8 eb f0 ff ff       	call   801b80 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  802a95:	c7 04 24 6d 1a 80 00 	movl   $0x801a6d,(%esp)
  802a9c:	e8 58 fc ff ff       	call   8026f9 <sys_thread_create>
  802aa1:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  802aa3:	83 c4 08             	add    $0x8,%esp
  802aa6:	53                   	push   %ebx
  802aa7:	68 d4 44 80 00       	push   $0x8044d4
  802aac:	e8 cf f0 ff ff       	call   801b80 <cprintf>
	return id;
	//return 0;
}
  802ab1:	89 f0                	mov    %esi,%eax
  802ab3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ab6:	5b                   	pop    %ebx
  802ab7:	5e                   	pop    %esi
  802ab8:	5d                   	pop    %ebp
  802ab9:	c3                   	ret    

00802aba <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802aba:	55                   	push   %ebp
  802abb:	89 e5                	mov    %esp,%ebp
  802abd:	56                   	push   %esi
  802abe:	53                   	push   %ebx
  802abf:	8b 75 08             	mov    0x8(%ebp),%esi
  802ac2:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ac5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802ac8:	85 c0                	test   %eax,%eax
  802aca:	75 12                	jne    802ade <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802acc:	83 ec 0c             	sub    $0xc,%esp
  802acf:	68 00 00 c0 ee       	push   $0xeec00000
  802ad4:	e8 df fb ff ff       	call   8026b8 <sys_ipc_recv>
  802ad9:	83 c4 10             	add    $0x10,%esp
  802adc:	eb 0c                	jmp    802aea <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802ade:	83 ec 0c             	sub    $0xc,%esp
  802ae1:	50                   	push   %eax
  802ae2:	e8 d1 fb ff ff       	call   8026b8 <sys_ipc_recv>
  802ae7:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802aea:	85 f6                	test   %esi,%esi
  802aec:	0f 95 c1             	setne  %cl
  802aef:	85 db                	test   %ebx,%ebx
  802af1:	0f 95 c2             	setne  %dl
  802af4:	84 d1                	test   %dl,%cl
  802af6:	74 09                	je     802b01 <ipc_recv+0x47>
  802af8:	89 c2                	mov    %eax,%edx
  802afa:	c1 ea 1f             	shr    $0x1f,%edx
  802afd:	84 d2                	test   %dl,%dl
  802aff:	75 2a                	jne    802b2b <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802b01:	85 f6                	test   %esi,%esi
  802b03:	74 0d                	je     802b12 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802b05:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802b0a:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  802b10:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802b12:	85 db                	test   %ebx,%ebx
  802b14:	74 0d                	je     802b23 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802b16:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802b1b:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  802b21:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802b23:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802b28:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  802b2b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b2e:	5b                   	pop    %ebx
  802b2f:	5e                   	pop    %esi
  802b30:	5d                   	pop    %ebp
  802b31:	c3                   	ret    

00802b32 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802b32:	55                   	push   %ebp
  802b33:	89 e5                	mov    %esp,%ebp
  802b35:	57                   	push   %edi
  802b36:	56                   	push   %esi
  802b37:	53                   	push   %ebx
  802b38:	83 ec 0c             	sub    $0xc,%esp
  802b3b:	8b 7d 08             	mov    0x8(%ebp),%edi
  802b3e:	8b 75 0c             	mov    0xc(%ebp),%esi
  802b41:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802b44:	85 db                	test   %ebx,%ebx
  802b46:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802b4b:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802b4e:	ff 75 14             	pushl  0x14(%ebp)
  802b51:	53                   	push   %ebx
  802b52:	56                   	push   %esi
  802b53:	57                   	push   %edi
  802b54:	e8 3c fb ff ff       	call   802695 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802b59:	89 c2                	mov    %eax,%edx
  802b5b:	c1 ea 1f             	shr    $0x1f,%edx
  802b5e:	83 c4 10             	add    $0x10,%esp
  802b61:	84 d2                	test   %dl,%dl
  802b63:	74 17                	je     802b7c <ipc_send+0x4a>
  802b65:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802b68:	74 12                	je     802b7c <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802b6a:	50                   	push   %eax
  802b6b:	68 f7 44 80 00       	push   $0x8044f7
  802b70:	6a 47                	push   $0x47
  802b72:	68 05 45 80 00       	push   $0x804505
  802b77:	e8 2b ef ff ff       	call   801aa7 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802b7c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802b7f:	75 07                	jne    802b88 <ipc_send+0x56>
			sys_yield();
  802b81:	e8 63 f9 ff ff       	call   8024e9 <sys_yield>
  802b86:	eb c6                	jmp    802b4e <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802b88:	85 c0                	test   %eax,%eax
  802b8a:	75 c2                	jne    802b4e <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802b8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b8f:	5b                   	pop    %ebx
  802b90:	5e                   	pop    %esi
  802b91:	5f                   	pop    %edi
  802b92:	5d                   	pop    %ebp
  802b93:	c3                   	ret    

00802b94 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802b94:	55                   	push   %ebp
  802b95:	89 e5                	mov    %esp,%ebp
  802b97:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802b9a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802b9f:	89 c2                	mov    %eax,%edx
  802ba1:	c1 e2 07             	shl    $0x7,%edx
  802ba4:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  802bab:	8b 52 5c             	mov    0x5c(%edx),%edx
  802bae:	39 ca                	cmp    %ecx,%edx
  802bb0:	75 11                	jne    802bc3 <ipc_find_env+0x2f>
			return envs[i].env_id;
  802bb2:	89 c2                	mov    %eax,%edx
  802bb4:	c1 e2 07             	shl    $0x7,%edx
  802bb7:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  802bbe:	8b 40 54             	mov    0x54(%eax),%eax
  802bc1:	eb 0f                	jmp    802bd2 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802bc3:	83 c0 01             	add    $0x1,%eax
  802bc6:	3d 00 04 00 00       	cmp    $0x400,%eax
  802bcb:	75 d2                	jne    802b9f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802bcd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802bd2:	5d                   	pop    %ebp
  802bd3:	c3                   	ret    

00802bd4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802bd4:	55                   	push   %ebp
  802bd5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802bd7:	8b 45 08             	mov    0x8(%ebp),%eax
  802bda:	05 00 00 00 30       	add    $0x30000000,%eax
  802bdf:	c1 e8 0c             	shr    $0xc,%eax
}
  802be2:	5d                   	pop    %ebp
  802be3:	c3                   	ret    

00802be4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802be4:	55                   	push   %ebp
  802be5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  802be7:	8b 45 08             	mov    0x8(%ebp),%eax
  802bea:	05 00 00 00 30       	add    $0x30000000,%eax
  802bef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  802bf4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  802bf9:	5d                   	pop    %ebp
  802bfa:	c3                   	ret    

00802bfb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  802bfb:	55                   	push   %ebp
  802bfc:	89 e5                	mov    %esp,%ebp
  802bfe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802c01:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  802c06:	89 c2                	mov    %eax,%edx
  802c08:	c1 ea 16             	shr    $0x16,%edx
  802c0b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802c12:	f6 c2 01             	test   $0x1,%dl
  802c15:	74 11                	je     802c28 <fd_alloc+0x2d>
  802c17:	89 c2                	mov    %eax,%edx
  802c19:	c1 ea 0c             	shr    $0xc,%edx
  802c1c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802c23:	f6 c2 01             	test   $0x1,%dl
  802c26:	75 09                	jne    802c31 <fd_alloc+0x36>
			*fd_store = fd;
  802c28:	89 01                	mov    %eax,(%ecx)
			return 0;
  802c2a:	b8 00 00 00 00       	mov    $0x0,%eax
  802c2f:	eb 17                	jmp    802c48 <fd_alloc+0x4d>
  802c31:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  802c36:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  802c3b:	75 c9                	jne    802c06 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  802c3d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  802c43:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  802c48:	5d                   	pop    %ebp
  802c49:	c3                   	ret    

00802c4a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802c4a:	55                   	push   %ebp
  802c4b:	89 e5                	mov    %esp,%ebp
  802c4d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802c50:	83 f8 1f             	cmp    $0x1f,%eax
  802c53:	77 36                	ja     802c8b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802c55:	c1 e0 0c             	shl    $0xc,%eax
  802c58:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  802c5d:	89 c2                	mov    %eax,%edx
  802c5f:	c1 ea 16             	shr    $0x16,%edx
  802c62:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802c69:	f6 c2 01             	test   $0x1,%dl
  802c6c:	74 24                	je     802c92 <fd_lookup+0x48>
  802c6e:	89 c2                	mov    %eax,%edx
  802c70:	c1 ea 0c             	shr    $0xc,%edx
  802c73:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802c7a:	f6 c2 01             	test   $0x1,%dl
  802c7d:	74 1a                	je     802c99 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  802c7f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802c82:	89 02                	mov    %eax,(%edx)
	return 0;
  802c84:	b8 00 00 00 00       	mov    $0x0,%eax
  802c89:	eb 13                	jmp    802c9e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802c8b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802c90:	eb 0c                	jmp    802c9e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802c92:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802c97:	eb 05                	jmp    802c9e <fd_lookup+0x54>
  802c99:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  802c9e:	5d                   	pop    %ebp
  802c9f:	c3                   	ret    

00802ca0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802ca0:	55                   	push   %ebp
  802ca1:	89 e5                	mov    %esp,%ebp
  802ca3:	83 ec 08             	sub    $0x8,%esp
  802ca6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802ca9:	ba 90 45 80 00       	mov    $0x804590,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  802cae:	eb 13                	jmp    802cc3 <dev_lookup+0x23>
  802cb0:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  802cb3:	39 08                	cmp    %ecx,(%eax)
  802cb5:	75 0c                	jne    802cc3 <dev_lookup+0x23>
			*dev = devtab[i];
  802cb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802cba:	89 01                	mov    %eax,(%ecx)
			return 0;
  802cbc:	b8 00 00 00 00       	mov    $0x0,%eax
  802cc1:	eb 2e                	jmp    802cf1 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  802cc3:	8b 02                	mov    (%edx),%eax
  802cc5:	85 c0                	test   %eax,%eax
  802cc7:	75 e7                	jne    802cb0 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802cc9:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802cce:	8b 40 54             	mov    0x54(%eax),%eax
  802cd1:	83 ec 04             	sub    $0x4,%esp
  802cd4:	51                   	push   %ecx
  802cd5:	50                   	push   %eax
  802cd6:	68 10 45 80 00       	push   $0x804510
  802cdb:	e8 a0 ee ff ff       	call   801b80 <cprintf>
	*dev = 0;
  802ce0:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ce3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  802ce9:	83 c4 10             	add    $0x10,%esp
  802cec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802cf1:	c9                   	leave  
  802cf2:	c3                   	ret    

00802cf3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  802cf3:	55                   	push   %ebp
  802cf4:	89 e5                	mov    %esp,%ebp
  802cf6:	56                   	push   %esi
  802cf7:	53                   	push   %ebx
  802cf8:	83 ec 10             	sub    $0x10,%esp
  802cfb:	8b 75 08             	mov    0x8(%ebp),%esi
  802cfe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802d01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d04:	50                   	push   %eax
  802d05:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  802d0b:	c1 e8 0c             	shr    $0xc,%eax
  802d0e:	50                   	push   %eax
  802d0f:	e8 36 ff ff ff       	call   802c4a <fd_lookup>
  802d14:	83 c4 08             	add    $0x8,%esp
  802d17:	85 c0                	test   %eax,%eax
  802d19:	78 05                	js     802d20 <fd_close+0x2d>
	    || fd != fd2)
  802d1b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  802d1e:	74 0c                	je     802d2c <fd_close+0x39>
		return (must_exist ? r : 0);
  802d20:	84 db                	test   %bl,%bl
  802d22:	ba 00 00 00 00       	mov    $0x0,%edx
  802d27:	0f 44 c2             	cmove  %edx,%eax
  802d2a:	eb 41                	jmp    802d6d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802d2c:	83 ec 08             	sub    $0x8,%esp
  802d2f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d32:	50                   	push   %eax
  802d33:	ff 36                	pushl  (%esi)
  802d35:	e8 66 ff ff ff       	call   802ca0 <dev_lookup>
  802d3a:	89 c3                	mov    %eax,%ebx
  802d3c:	83 c4 10             	add    $0x10,%esp
  802d3f:	85 c0                	test   %eax,%eax
  802d41:	78 1a                	js     802d5d <fd_close+0x6a>
		if (dev->dev_close)
  802d43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d46:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  802d49:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  802d4e:	85 c0                	test   %eax,%eax
  802d50:	74 0b                	je     802d5d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  802d52:	83 ec 0c             	sub    $0xc,%esp
  802d55:	56                   	push   %esi
  802d56:	ff d0                	call   *%eax
  802d58:	89 c3                	mov    %eax,%ebx
  802d5a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802d5d:	83 ec 08             	sub    $0x8,%esp
  802d60:	56                   	push   %esi
  802d61:	6a 00                	push   $0x0
  802d63:	e8 25 f8 ff ff       	call   80258d <sys_page_unmap>
	return r;
  802d68:	83 c4 10             	add    $0x10,%esp
  802d6b:	89 d8                	mov    %ebx,%eax
}
  802d6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802d70:	5b                   	pop    %ebx
  802d71:	5e                   	pop    %esi
  802d72:	5d                   	pop    %ebp
  802d73:	c3                   	ret    

00802d74 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  802d74:	55                   	push   %ebp
  802d75:	89 e5                	mov    %esp,%ebp
  802d77:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802d7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d7d:	50                   	push   %eax
  802d7e:	ff 75 08             	pushl  0x8(%ebp)
  802d81:	e8 c4 fe ff ff       	call   802c4a <fd_lookup>
  802d86:	83 c4 08             	add    $0x8,%esp
  802d89:	85 c0                	test   %eax,%eax
  802d8b:	78 10                	js     802d9d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  802d8d:	83 ec 08             	sub    $0x8,%esp
  802d90:	6a 01                	push   $0x1
  802d92:	ff 75 f4             	pushl  -0xc(%ebp)
  802d95:	e8 59 ff ff ff       	call   802cf3 <fd_close>
  802d9a:	83 c4 10             	add    $0x10,%esp
}
  802d9d:	c9                   	leave  
  802d9e:	c3                   	ret    

00802d9f <close_all>:

void
close_all(void)
{
  802d9f:	55                   	push   %ebp
  802da0:	89 e5                	mov    %esp,%ebp
  802da2:	53                   	push   %ebx
  802da3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802da6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802dab:	83 ec 0c             	sub    $0xc,%esp
  802dae:	53                   	push   %ebx
  802daf:	e8 c0 ff ff ff       	call   802d74 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  802db4:	83 c3 01             	add    $0x1,%ebx
  802db7:	83 c4 10             	add    $0x10,%esp
  802dba:	83 fb 20             	cmp    $0x20,%ebx
  802dbd:	75 ec                	jne    802dab <close_all+0xc>
		close(i);
}
  802dbf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802dc2:	c9                   	leave  
  802dc3:	c3                   	ret    

00802dc4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802dc4:	55                   	push   %ebp
  802dc5:	89 e5                	mov    %esp,%ebp
  802dc7:	57                   	push   %edi
  802dc8:	56                   	push   %esi
  802dc9:	53                   	push   %ebx
  802dca:	83 ec 2c             	sub    $0x2c,%esp
  802dcd:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802dd0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802dd3:	50                   	push   %eax
  802dd4:	ff 75 08             	pushl  0x8(%ebp)
  802dd7:	e8 6e fe ff ff       	call   802c4a <fd_lookup>
  802ddc:	83 c4 08             	add    $0x8,%esp
  802ddf:	85 c0                	test   %eax,%eax
  802de1:	0f 88 c1 00 00 00    	js     802ea8 <dup+0xe4>
		return r;
	close(newfdnum);
  802de7:	83 ec 0c             	sub    $0xc,%esp
  802dea:	56                   	push   %esi
  802deb:	e8 84 ff ff ff       	call   802d74 <close>

	newfd = INDEX2FD(newfdnum);
  802df0:	89 f3                	mov    %esi,%ebx
  802df2:	c1 e3 0c             	shl    $0xc,%ebx
  802df5:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  802dfb:	83 c4 04             	add    $0x4,%esp
  802dfe:	ff 75 e4             	pushl  -0x1c(%ebp)
  802e01:	e8 de fd ff ff       	call   802be4 <fd2data>
  802e06:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  802e08:	89 1c 24             	mov    %ebx,(%esp)
  802e0b:	e8 d4 fd ff ff       	call   802be4 <fd2data>
  802e10:	83 c4 10             	add    $0x10,%esp
  802e13:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802e16:	89 f8                	mov    %edi,%eax
  802e18:	c1 e8 16             	shr    $0x16,%eax
  802e1b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802e22:	a8 01                	test   $0x1,%al
  802e24:	74 37                	je     802e5d <dup+0x99>
  802e26:	89 f8                	mov    %edi,%eax
  802e28:	c1 e8 0c             	shr    $0xc,%eax
  802e2b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802e32:	f6 c2 01             	test   $0x1,%dl
  802e35:	74 26                	je     802e5d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802e37:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802e3e:	83 ec 0c             	sub    $0xc,%esp
  802e41:	25 07 0e 00 00       	and    $0xe07,%eax
  802e46:	50                   	push   %eax
  802e47:	ff 75 d4             	pushl  -0x2c(%ebp)
  802e4a:	6a 00                	push   $0x0
  802e4c:	57                   	push   %edi
  802e4d:	6a 00                	push   $0x0
  802e4f:	e8 f7 f6 ff ff       	call   80254b <sys_page_map>
  802e54:	89 c7                	mov    %eax,%edi
  802e56:	83 c4 20             	add    $0x20,%esp
  802e59:	85 c0                	test   %eax,%eax
  802e5b:	78 2e                	js     802e8b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802e5d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802e60:	89 d0                	mov    %edx,%eax
  802e62:	c1 e8 0c             	shr    $0xc,%eax
  802e65:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802e6c:	83 ec 0c             	sub    $0xc,%esp
  802e6f:	25 07 0e 00 00       	and    $0xe07,%eax
  802e74:	50                   	push   %eax
  802e75:	53                   	push   %ebx
  802e76:	6a 00                	push   $0x0
  802e78:	52                   	push   %edx
  802e79:	6a 00                	push   $0x0
  802e7b:	e8 cb f6 ff ff       	call   80254b <sys_page_map>
  802e80:	89 c7                	mov    %eax,%edi
  802e82:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  802e85:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802e87:	85 ff                	test   %edi,%edi
  802e89:	79 1d                	jns    802ea8 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802e8b:	83 ec 08             	sub    $0x8,%esp
  802e8e:	53                   	push   %ebx
  802e8f:	6a 00                	push   $0x0
  802e91:	e8 f7 f6 ff ff       	call   80258d <sys_page_unmap>
	sys_page_unmap(0, nva);
  802e96:	83 c4 08             	add    $0x8,%esp
  802e99:	ff 75 d4             	pushl  -0x2c(%ebp)
  802e9c:	6a 00                	push   $0x0
  802e9e:	e8 ea f6 ff ff       	call   80258d <sys_page_unmap>
	return r;
  802ea3:	83 c4 10             	add    $0x10,%esp
  802ea6:	89 f8                	mov    %edi,%eax
}
  802ea8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802eab:	5b                   	pop    %ebx
  802eac:	5e                   	pop    %esi
  802ead:	5f                   	pop    %edi
  802eae:	5d                   	pop    %ebp
  802eaf:	c3                   	ret    

00802eb0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802eb0:	55                   	push   %ebp
  802eb1:	89 e5                	mov    %esp,%ebp
  802eb3:	53                   	push   %ebx
  802eb4:	83 ec 14             	sub    $0x14,%esp
  802eb7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802eba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802ebd:	50                   	push   %eax
  802ebe:	53                   	push   %ebx
  802ebf:	e8 86 fd ff ff       	call   802c4a <fd_lookup>
  802ec4:	83 c4 08             	add    $0x8,%esp
  802ec7:	89 c2                	mov    %eax,%edx
  802ec9:	85 c0                	test   %eax,%eax
  802ecb:	78 6d                	js     802f3a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802ecd:	83 ec 08             	sub    $0x8,%esp
  802ed0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802ed3:	50                   	push   %eax
  802ed4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802ed7:	ff 30                	pushl  (%eax)
  802ed9:	e8 c2 fd ff ff       	call   802ca0 <dev_lookup>
  802ede:	83 c4 10             	add    $0x10,%esp
  802ee1:	85 c0                	test   %eax,%eax
  802ee3:	78 4c                	js     802f31 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802ee5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802ee8:	8b 42 08             	mov    0x8(%edx),%eax
  802eeb:	83 e0 03             	and    $0x3,%eax
  802eee:	83 f8 01             	cmp    $0x1,%eax
  802ef1:	75 21                	jne    802f14 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802ef3:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802ef8:	8b 40 54             	mov    0x54(%eax),%eax
  802efb:	83 ec 04             	sub    $0x4,%esp
  802efe:	53                   	push   %ebx
  802eff:	50                   	push   %eax
  802f00:	68 54 45 80 00       	push   $0x804554
  802f05:	e8 76 ec ff ff       	call   801b80 <cprintf>
		return -E_INVAL;
  802f0a:	83 c4 10             	add    $0x10,%esp
  802f0d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802f12:	eb 26                	jmp    802f3a <read+0x8a>
	}
	if (!dev->dev_read)
  802f14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802f17:	8b 40 08             	mov    0x8(%eax),%eax
  802f1a:	85 c0                	test   %eax,%eax
  802f1c:	74 17                	je     802f35 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  802f1e:	83 ec 04             	sub    $0x4,%esp
  802f21:	ff 75 10             	pushl  0x10(%ebp)
  802f24:	ff 75 0c             	pushl  0xc(%ebp)
  802f27:	52                   	push   %edx
  802f28:	ff d0                	call   *%eax
  802f2a:	89 c2                	mov    %eax,%edx
  802f2c:	83 c4 10             	add    $0x10,%esp
  802f2f:	eb 09                	jmp    802f3a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802f31:	89 c2                	mov    %eax,%edx
  802f33:	eb 05                	jmp    802f3a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802f35:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  802f3a:	89 d0                	mov    %edx,%eax
  802f3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f3f:	c9                   	leave  
  802f40:	c3                   	ret    

00802f41 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802f41:	55                   	push   %ebp
  802f42:	89 e5                	mov    %esp,%ebp
  802f44:	57                   	push   %edi
  802f45:	56                   	push   %esi
  802f46:	53                   	push   %ebx
  802f47:	83 ec 0c             	sub    $0xc,%esp
  802f4a:	8b 7d 08             	mov    0x8(%ebp),%edi
  802f4d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802f50:	bb 00 00 00 00       	mov    $0x0,%ebx
  802f55:	eb 21                	jmp    802f78 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802f57:	83 ec 04             	sub    $0x4,%esp
  802f5a:	89 f0                	mov    %esi,%eax
  802f5c:	29 d8                	sub    %ebx,%eax
  802f5e:	50                   	push   %eax
  802f5f:	89 d8                	mov    %ebx,%eax
  802f61:	03 45 0c             	add    0xc(%ebp),%eax
  802f64:	50                   	push   %eax
  802f65:	57                   	push   %edi
  802f66:	e8 45 ff ff ff       	call   802eb0 <read>
		if (m < 0)
  802f6b:	83 c4 10             	add    $0x10,%esp
  802f6e:	85 c0                	test   %eax,%eax
  802f70:	78 10                	js     802f82 <readn+0x41>
			return m;
		if (m == 0)
  802f72:	85 c0                	test   %eax,%eax
  802f74:	74 0a                	je     802f80 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802f76:	01 c3                	add    %eax,%ebx
  802f78:	39 f3                	cmp    %esi,%ebx
  802f7a:	72 db                	jb     802f57 <readn+0x16>
  802f7c:	89 d8                	mov    %ebx,%eax
  802f7e:	eb 02                	jmp    802f82 <readn+0x41>
  802f80:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  802f82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802f85:	5b                   	pop    %ebx
  802f86:	5e                   	pop    %esi
  802f87:	5f                   	pop    %edi
  802f88:	5d                   	pop    %ebp
  802f89:	c3                   	ret    

00802f8a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802f8a:	55                   	push   %ebp
  802f8b:	89 e5                	mov    %esp,%ebp
  802f8d:	53                   	push   %ebx
  802f8e:	83 ec 14             	sub    $0x14,%esp
  802f91:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802f94:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802f97:	50                   	push   %eax
  802f98:	53                   	push   %ebx
  802f99:	e8 ac fc ff ff       	call   802c4a <fd_lookup>
  802f9e:	83 c4 08             	add    $0x8,%esp
  802fa1:	89 c2                	mov    %eax,%edx
  802fa3:	85 c0                	test   %eax,%eax
  802fa5:	78 68                	js     80300f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802fa7:	83 ec 08             	sub    $0x8,%esp
  802faa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802fad:	50                   	push   %eax
  802fae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802fb1:	ff 30                	pushl  (%eax)
  802fb3:	e8 e8 fc ff ff       	call   802ca0 <dev_lookup>
  802fb8:	83 c4 10             	add    $0x10,%esp
  802fbb:	85 c0                	test   %eax,%eax
  802fbd:	78 47                	js     803006 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802fbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802fc2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802fc6:	75 21                	jne    802fe9 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802fc8:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802fcd:	8b 40 54             	mov    0x54(%eax),%eax
  802fd0:	83 ec 04             	sub    $0x4,%esp
  802fd3:	53                   	push   %ebx
  802fd4:	50                   	push   %eax
  802fd5:	68 70 45 80 00       	push   $0x804570
  802fda:	e8 a1 eb ff ff       	call   801b80 <cprintf>
		return -E_INVAL;
  802fdf:	83 c4 10             	add    $0x10,%esp
  802fe2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802fe7:	eb 26                	jmp    80300f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802fe9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802fec:	8b 52 0c             	mov    0xc(%edx),%edx
  802fef:	85 d2                	test   %edx,%edx
  802ff1:	74 17                	je     80300a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802ff3:	83 ec 04             	sub    $0x4,%esp
  802ff6:	ff 75 10             	pushl  0x10(%ebp)
  802ff9:	ff 75 0c             	pushl  0xc(%ebp)
  802ffc:	50                   	push   %eax
  802ffd:	ff d2                	call   *%edx
  802fff:	89 c2                	mov    %eax,%edx
  803001:	83 c4 10             	add    $0x10,%esp
  803004:	eb 09                	jmp    80300f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  803006:	89 c2                	mov    %eax,%edx
  803008:	eb 05                	jmp    80300f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80300a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80300f:	89 d0                	mov    %edx,%eax
  803011:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803014:	c9                   	leave  
  803015:	c3                   	ret    

00803016 <seek>:

int
seek(int fdnum, off_t offset)
{
  803016:	55                   	push   %ebp
  803017:	89 e5                	mov    %esp,%ebp
  803019:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80301c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80301f:	50                   	push   %eax
  803020:	ff 75 08             	pushl  0x8(%ebp)
  803023:	e8 22 fc ff ff       	call   802c4a <fd_lookup>
  803028:	83 c4 08             	add    $0x8,%esp
  80302b:	85 c0                	test   %eax,%eax
  80302d:	78 0e                	js     80303d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80302f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  803032:	8b 55 0c             	mov    0xc(%ebp),%edx
  803035:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  803038:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80303d:	c9                   	leave  
  80303e:	c3                   	ret    

0080303f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80303f:	55                   	push   %ebp
  803040:	89 e5                	mov    %esp,%ebp
  803042:	53                   	push   %ebx
  803043:	83 ec 14             	sub    $0x14,%esp
  803046:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  803049:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80304c:	50                   	push   %eax
  80304d:	53                   	push   %ebx
  80304e:	e8 f7 fb ff ff       	call   802c4a <fd_lookup>
  803053:	83 c4 08             	add    $0x8,%esp
  803056:	89 c2                	mov    %eax,%edx
  803058:	85 c0                	test   %eax,%eax
  80305a:	78 65                	js     8030c1 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80305c:	83 ec 08             	sub    $0x8,%esp
  80305f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803062:	50                   	push   %eax
  803063:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803066:	ff 30                	pushl  (%eax)
  803068:	e8 33 fc ff ff       	call   802ca0 <dev_lookup>
  80306d:	83 c4 10             	add    $0x10,%esp
  803070:	85 c0                	test   %eax,%eax
  803072:	78 44                	js     8030b8 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  803074:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803077:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80307b:	75 21                	jne    80309e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80307d:	a1 0c a0 80 00       	mov    0x80a00c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  803082:	8b 40 54             	mov    0x54(%eax),%eax
  803085:	83 ec 04             	sub    $0x4,%esp
  803088:	53                   	push   %ebx
  803089:	50                   	push   %eax
  80308a:	68 30 45 80 00       	push   $0x804530
  80308f:	e8 ec ea ff ff       	call   801b80 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  803094:	83 c4 10             	add    $0x10,%esp
  803097:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80309c:	eb 23                	jmp    8030c1 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80309e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8030a1:	8b 52 18             	mov    0x18(%edx),%edx
  8030a4:	85 d2                	test   %edx,%edx
  8030a6:	74 14                	je     8030bc <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8030a8:	83 ec 08             	sub    $0x8,%esp
  8030ab:	ff 75 0c             	pushl  0xc(%ebp)
  8030ae:	50                   	push   %eax
  8030af:	ff d2                	call   *%edx
  8030b1:	89 c2                	mov    %eax,%edx
  8030b3:	83 c4 10             	add    $0x10,%esp
  8030b6:	eb 09                	jmp    8030c1 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8030b8:	89 c2                	mov    %eax,%edx
  8030ba:	eb 05                	jmp    8030c1 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8030bc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8030c1:	89 d0                	mov    %edx,%eax
  8030c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8030c6:	c9                   	leave  
  8030c7:	c3                   	ret    

008030c8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8030c8:	55                   	push   %ebp
  8030c9:	89 e5                	mov    %esp,%ebp
  8030cb:	53                   	push   %ebx
  8030cc:	83 ec 14             	sub    $0x14,%esp
  8030cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8030d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8030d5:	50                   	push   %eax
  8030d6:	ff 75 08             	pushl  0x8(%ebp)
  8030d9:	e8 6c fb ff ff       	call   802c4a <fd_lookup>
  8030de:	83 c4 08             	add    $0x8,%esp
  8030e1:	89 c2                	mov    %eax,%edx
  8030e3:	85 c0                	test   %eax,%eax
  8030e5:	78 58                	js     80313f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8030e7:	83 ec 08             	sub    $0x8,%esp
  8030ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8030ed:	50                   	push   %eax
  8030ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8030f1:	ff 30                	pushl  (%eax)
  8030f3:	e8 a8 fb ff ff       	call   802ca0 <dev_lookup>
  8030f8:	83 c4 10             	add    $0x10,%esp
  8030fb:	85 c0                	test   %eax,%eax
  8030fd:	78 37                	js     803136 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8030ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803102:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  803106:	74 32                	je     80313a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  803108:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80310b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  803112:	00 00 00 
	stat->st_isdir = 0;
  803115:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80311c:	00 00 00 
	stat->st_dev = dev;
  80311f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  803125:	83 ec 08             	sub    $0x8,%esp
  803128:	53                   	push   %ebx
  803129:	ff 75 f0             	pushl  -0x10(%ebp)
  80312c:	ff 50 14             	call   *0x14(%eax)
  80312f:	89 c2                	mov    %eax,%edx
  803131:	83 c4 10             	add    $0x10,%esp
  803134:	eb 09                	jmp    80313f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  803136:	89 c2                	mov    %eax,%edx
  803138:	eb 05                	jmp    80313f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80313a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80313f:	89 d0                	mov    %edx,%eax
  803141:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803144:	c9                   	leave  
  803145:	c3                   	ret    

00803146 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  803146:	55                   	push   %ebp
  803147:	89 e5                	mov    %esp,%ebp
  803149:	56                   	push   %esi
  80314a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80314b:	83 ec 08             	sub    $0x8,%esp
  80314e:	6a 00                	push   $0x0
  803150:	ff 75 08             	pushl  0x8(%ebp)
  803153:	e8 e3 01 00 00       	call   80333b <open>
  803158:	89 c3                	mov    %eax,%ebx
  80315a:	83 c4 10             	add    $0x10,%esp
  80315d:	85 c0                	test   %eax,%eax
  80315f:	78 1b                	js     80317c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  803161:	83 ec 08             	sub    $0x8,%esp
  803164:	ff 75 0c             	pushl  0xc(%ebp)
  803167:	50                   	push   %eax
  803168:	e8 5b ff ff ff       	call   8030c8 <fstat>
  80316d:	89 c6                	mov    %eax,%esi
	close(fd);
  80316f:	89 1c 24             	mov    %ebx,(%esp)
  803172:	e8 fd fb ff ff       	call   802d74 <close>
	return r;
  803177:	83 c4 10             	add    $0x10,%esp
  80317a:	89 f0                	mov    %esi,%eax
}
  80317c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80317f:	5b                   	pop    %ebx
  803180:	5e                   	pop    %esi
  803181:	5d                   	pop    %ebp
  803182:	c3                   	ret    

00803183 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  803183:	55                   	push   %ebp
  803184:	89 e5                	mov    %esp,%ebp
  803186:	56                   	push   %esi
  803187:	53                   	push   %ebx
  803188:	89 c6                	mov    %eax,%esi
  80318a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80318c:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  803193:	75 12                	jne    8031a7 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  803195:	83 ec 0c             	sub    $0xc,%esp
  803198:	6a 01                	push   $0x1
  80319a:	e8 f5 f9 ff ff       	call   802b94 <ipc_find_env>
  80319f:	a3 00 a0 80 00       	mov    %eax,0x80a000
  8031a4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8031a7:	6a 07                	push   $0x7
  8031a9:	68 00 b0 80 00       	push   $0x80b000
  8031ae:	56                   	push   %esi
  8031af:	ff 35 00 a0 80 00    	pushl  0x80a000
  8031b5:	e8 78 f9 ff ff       	call   802b32 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8031ba:	83 c4 0c             	add    $0xc,%esp
  8031bd:	6a 00                	push   $0x0
  8031bf:	53                   	push   %ebx
  8031c0:	6a 00                	push   $0x0
  8031c2:	e8 f3 f8 ff ff       	call   802aba <ipc_recv>
}
  8031c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8031ca:	5b                   	pop    %ebx
  8031cb:	5e                   	pop    %esi
  8031cc:	5d                   	pop    %ebp
  8031cd:	c3                   	ret    

008031ce <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8031ce:	55                   	push   %ebp
  8031cf:	89 e5                	mov    %esp,%ebp
  8031d1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8031d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8031d7:	8b 40 0c             	mov    0xc(%eax),%eax
  8031da:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  8031df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8031e2:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8031e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8031ec:	b8 02 00 00 00       	mov    $0x2,%eax
  8031f1:	e8 8d ff ff ff       	call   803183 <fsipc>
}
  8031f6:	c9                   	leave  
  8031f7:	c3                   	ret    

008031f8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8031f8:	55                   	push   %ebp
  8031f9:	89 e5                	mov    %esp,%ebp
  8031fb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8031fe:	8b 45 08             	mov    0x8(%ebp),%eax
  803201:	8b 40 0c             	mov    0xc(%eax),%eax
  803204:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  803209:	ba 00 00 00 00       	mov    $0x0,%edx
  80320e:	b8 06 00 00 00       	mov    $0x6,%eax
  803213:	e8 6b ff ff ff       	call   803183 <fsipc>
}
  803218:	c9                   	leave  
  803219:	c3                   	ret    

0080321a <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80321a:	55                   	push   %ebp
  80321b:	89 e5                	mov    %esp,%ebp
  80321d:	53                   	push   %ebx
  80321e:	83 ec 04             	sub    $0x4,%esp
  803221:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  803224:	8b 45 08             	mov    0x8(%ebp),%eax
  803227:	8b 40 0c             	mov    0xc(%eax),%eax
  80322a:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80322f:	ba 00 00 00 00       	mov    $0x0,%edx
  803234:	b8 05 00 00 00       	mov    $0x5,%eax
  803239:	e8 45 ff ff ff       	call   803183 <fsipc>
  80323e:	85 c0                	test   %eax,%eax
  803240:	78 2c                	js     80326e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  803242:	83 ec 08             	sub    $0x8,%esp
  803245:	68 00 b0 80 00       	push   $0x80b000
  80324a:	53                   	push   %ebx
  80324b:	e8 b5 ee ff ff       	call   802105 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  803250:	a1 80 b0 80 00       	mov    0x80b080,%eax
  803255:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80325b:	a1 84 b0 80 00       	mov    0x80b084,%eax
  803260:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  803266:	83 c4 10             	add    $0x10,%esp
  803269:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80326e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803271:	c9                   	leave  
  803272:	c3                   	ret    

00803273 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  803273:	55                   	push   %ebp
  803274:	89 e5                	mov    %esp,%ebp
  803276:	83 ec 0c             	sub    $0xc,%esp
  803279:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80327c:	8b 55 08             	mov    0x8(%ebp),%edx
  80327f:	8b 52 0c             	mov    0xc(%edx),%edx
  803282:	89 15 00 b0 80 00    	mov    %edx,0x80b000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  803288:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80328d:	ba f8 0f 00 00       	mov    $0xff8,%edx
  803292:	0f 47 c2             	cmova  %edx,%eax
  803295:	a3 04 b0 80 00       	mov    %eax,0x80b004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80329a:	50                   	push   %eax
  80329b:	ff 75 0c             	pushl  0xc(%ebp)
  80329e:	68 08 b0 80 00       	push   $0x80b008
  8032a3:	e8 ef ef ff ff       	call   802297 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8032a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8032ad:	b8 04 00 00 00       	mov    $0x4,%eax
  8032b2:	e8 cc fe ff ff       	call   803183 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8032b7:	c9                   	leave  
  8032b8:	c3                   	ret    

008032b9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8032b9:	55                   	push   %ebp
  8032ba:	89 e5                	mov    %esp,%ebp
  8032bc:	56                   	push   %esi
  8032bd:	53                   	push   %ebx
  8032be:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8032c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8032c4:	8b 40 0c             	mov    0xc(%eax),%eax
  8032c7:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  8032cc:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8032d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8032d7:	b8 03 00 00 00       	mov    $0x3,%eax
  8032dc:	e8 a2 fe ff ff       	call   803183 <fsipc>
  8032e1:	89 c3                	mov    %eax,%ebx
  8032e3:	85 c0                	test   %eax,%eax
  8032e5:	78 4b                	js     803332 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8032e7:	39 c6                	cmp    %eax,%esi
  8032e9:	73 16                	jae    803301 <devfile_read+0x48>
  8032eb:	68 a0 45 80 00       	push   $0x8045a0
  8032f0:	68 dd 3b 80 00       	push   $0x803bdd
  8032f5:	6a 7c                	push   $0x7c
  8032f7:	68 a7 45 80 00       	push   $0x8045a7
  8032fc:	e8 a6 e7 ff ff       	call   801aa7 <_panic>
	assert(r <= PGSIZE);
  803301:	3d 00 10 00 00       	cmp    $0x1000,%eax
  803306:	7e 16                	jle    80331e <devfile_read+0x65>
  803308:	68 b2 45 80 00       	push   $0x8045b2
  80330d:	68 dd 3b 80 00       	push   $0x803bdd
  803312:	6a 7d                	push   $0x7d
  803314:	68 a7 45 80 00       	push   $0x8045a7
  803319:	e8 89 e7 ff ff       	call   801aa7 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80331e:	83 ec 04             	sub    $0x4,%esp
  803321:	50                   	push   %eax
  803322:	68 00 b0 80 00       	push   $0x80b000
  803327:	ff 75 0c             	pushl  0xc(%ebp)
  80332a:	e8 68 ef ff ff       	call   802297 <memmove>
	return r;
  80332f:	83 c4 10             	add    $0x10,%esp
}
  803332:	89 d8                	mov    %ebx,%eax
  803334:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803337:	5b                   	pop    %ebx
  803338:	5e                   	pop    %esi
  803339:	5d                   	pop    %ebp
  80333a:	c3                   	ret    

0080333b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80333b:	55                   	push   %ebp
  80333c:	89 e5                	mov    %esp,%ebp
  80333e:	53                   	push   %ebx
  80333f:	83 ec 20             	sub    $0x20,%esp
  803342:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  803345:	53                   	push   %ebx
  803346:	e8 81 ed ff ff       	call   8020cc <strlen>
  80334b:	83 c4 10             	add    $0x10,%esp
  80334e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  803353:	7f 67                	jg     8033bc <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  803355:	83 ec 0c             	sub    $0xc,%esp
  803358:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80335b:	50                   	push   %eax
  80335c:	e8 9a f8 ff ff       	call   802bfb <fd_alloc>
  803361:	83 c4 10             	add    $0x10,%esp
		return r;
  803364:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  803366:	85 c0                	test   %eax,%eax
  803368:	78 57                	js     8033c1 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80336a:	83 ec 08             	sub    $0x8,%esp
  80336d:	53                   	push   %ebx
  80336e:	68 00 b0 80 00       	push   $0x80b000
  803373:	e8 8d ed ff ff       	call   802105 <strcpy>
	fsipcbuf.open.req_omode = mode;
  803378:	8b 45 0c             	mov    0xc(%ebp),%eax
  80337b:	a3 00 b4 80 00       	mov    %eax,0x80b400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  803380:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803383:	b8 01 00 00 00       	mov    $0x1,%eax
  803388:	e8 f6 fd ff ff       	call   803183 <fsipc>
  80338d:	89 c3                	mov    %eax,%ebx
  80338f:	83 c4 10             	add    $0x10,%esp
  803392:	85 c0                	test   %eax,%eax
  803394:	79 14                	jns    8033aa <open+0x6f>
		fd_close(fd, 0);
  803396:	83 ec 08             	sub    $0x8,%esp
  803399:	6a 00                	push   $0x0
  80339b:	ff 75 f4             	pushl  -0xc(%ebp)
  80339e:	e8 50 f9 ff ff       	call   802cf3 <fd_close>
		return r;
  8033a3:	83 c4 10             	add    $0x10,%esp
  8033a6:	89 da                	mov    %ebx,%edx
  8033a8:	eb 17                	jmp    8033c1 <open+0x86>
	}

	return fd2num(fd);
  8033aa:	83 ec 0c             	sub    $0xc,%esp
  8033ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8033b0:	e8 1f f8 ff ff       	call   802bd4 <fd2num>
  8033b5:	89 c2                	mov    %eax,%edx
  8033b7:	83 c4 10             	add    $0x10,%esp
  8033ba:	eb 05                	jmp    8033c1 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8033bc:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8033c1:	89 d0                	mov    %edx,%eax
  8033c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8033c6:	c9                   	leave  
  8033c7:	c3                   	ret    

008033c8 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8033c8:	55                   	push   %ebp
  8033c9:	89 e5                	mov    %esp,%ebp
  8033cb:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8033ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8033d3:	b8 08 00 00 00       	mov    $0x8,%eax
  8033d8:	e8 a6 fd ff ff       	call   803183 <fsipc>
}
  8033dd:	c9                   	leave  
  8033de:	c3                   	ret    

008033df <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8033df:	55                   	push   %ebp
  8033e0:	89 e5                	mov    %esp,%ebp
  8033e2:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8033e5:	89 d0                	mov    %edx,%eax
  8033e7:	c1 e8 16             	shr    $0x16,%eax
  8033ea:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8033f1:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8033f6:	f6 c1 01             	test   $0x1,%cl
  8033f9:	74 1d                	je     803418 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8033fb:	c1 ea 0c             	shr    $0xc,%edx
  8033fe:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  803405:	f6 c2 01             	test   $0x1,%dl
  803408:	74 0e                	je     803418 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80340a:	c1 ea 0c             	shr    $0xc,%edx
  80340d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  803414:	ef 
  803415:	0f b7 c0             	movzwl %ax,%eax
}
  803418:	5d                   	pop    %ebp
  803419:	c3                   	ret    

0080341a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80341a:	55                   	push   %ebp
  80341b:	89 e5                	mov    %esp,%ebp
  80341d:	56                   	push   %esi
  80341e:	53                   	push   %ebx
  80341f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  803422:	83 ec 0c             	sub    $0xc,%esp
  803425:	ff 75 08             	pushl  0x8(%ebp)
  803428:	e8 b7 f7 ff ff       	call   802be4 <fd2data>
  80342d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80342f:	83 c4 08             	add    $0x8,%esp
  803432:	68 be 45 80 00       	push   $0x8045be
  803437:	53                   	push   %ebx
  803438:	e8 c8 ec ff ff       	call   802105 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80343d:	8b 46 04             	mov    0x4(%esi),%eax
  803440:	2b 06                	sub    (%esi),%eax
  803442:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  803448:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80344f:	00 00 00 
	stat->st_dev = &devpipe;
  803452:	c7 83 88 00 00 00 80 	movl   $0x809080,0x88(%ebx)
  803459:	90 80 00 
	return 0;
}
  80345c:	b8 00 00 00 00       	mov    $0x0,%eax
  803461:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803464:	5b                   	pop    %ebx
  803465:	5e                   	pop    %esi
  803466:	5d                   	pop    %ebp
  803467:	c3                   	ret    

00803468 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  803468:	55                   	push   %ebp
  803469:	89 e5                	mov    %esp,%ebp
  80346b:	53                   	push   %ebx
  80346c:	83 ec 0c             	sub    $0xc,%esp
  80346f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  803472:	53                   	push   %ebx
  803473:	6a 00                	push   $0x0
  803475:	e8 13 f1 ff ff       	call   80258d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80347a:	89 1c 24             	mov    %ebx,(%esp)
  80347d:	e8 62 f7 ff ff       	call   802be4 <fd2data>
  803482:	83 c4 08             	add    $0x8,%esp
  803485:	50                   	push   %eax
  803486:	6a 00                	push   $0x0
  803488:	e8 00 f1 ff ff       	call   80258d <sys_page_unmap>
}
  80348d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803490:	c9                   	leave  
  803491:	c3                   	ret    

00803492 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  803492:	55                   	push   %ebp
  803493:	89 e5                	mov    %esp,%ebp
  803495:	57                   	push   %edi
  803496:	56                   	push   %esi
  803497:	53                   	push   %ebx
  803498:	83 ec 1c             	sub    $0x1c,%esp
  80349b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80349e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8034a0:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8034a5:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8034a8:	83 ec 0c             	sub    $0xc,%esp
  8034ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8034ae:	e8 2c ff ff ff       	call   8033df <pageref>
  8034b3:	89 c3                	mov    %eax,%ebx
  8034b5:	89 3c 24             	mov    %edi,(%esp)
  8034b8:	e8 22 ff ff ff       	call   8033df <pageref>
  8034bd:	83 c4 10             	add    $0x10,%esp
  8034c0:	39 c3                	cmp    %eax,%ebx
  8034c2:	0f 94 c1             	sete   %cl
  8034c5:	0f b6 c9             	movzbl %cl,%ecx
  8034c8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8034cb:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  8034d1:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  8034d4:	39 ce                	cmp    %ecx,%esi
  8034d6:	74 1b                	je     8034f3 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8034d8:	39 c3                	cmp    %eax,%ebx
  8034da:	75 c4                	jne    8034a0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8034dc:	8b 42 64             	mov    0x64(%edx),%eax
  8034df:	ff 75 e4             	pushl  -0x1c(%ebp)
  8034e2:	50                   	push   %eax
  8034e3:	56                   	push   %esi
  8034e4:	68 c5 45 80 00       	push   $0x8045c5
  8034e9:	e8 92 e6 ff ff       	call   801b80 <cprintf>
  8034ee:	83 c4 10             	add    $0x10,%esp
  8034f1:	eb ad                	jmp    8034a0 <_pipeisclosed+0xe>
	}
}
  8034f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8034f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8034f9:	5b                   	pop    %ebx
  8034fa:	5e                   	pop    %esi
  8034fb:	5f                   	pop    %edi
  8034fc:	5d                   	pop    %ebp
  8034fd:	c3                   	ret    

008034fe <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8034fe:	55                   	push   %ebp
  8034ff:	89 e5                	mov    %esp,%ebp
  803501:	57                   	push   %edi
  803502:	56                   	push   %esi
  803503:	53                   	push   %ebx
  803504:	83 ec 28             	sub    $0x28,%esp
  803507:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80350a:	56                   	push   %esi
  80350b:	e8 d4 f6 ff ff       	call   802be4 <fd2data>
  803510:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803512:	83 c4 10             	add    $0x10,%esp
  803515:	bf 00 00 00 00       	mov    $0x0,%edi
  80351a:	eb 4b                	jmp    803567 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80351c:	89 da                	mov    %ebx,%edx
  80351e:	89 f0                	mov    %esi,%eax
  803520:	e8 6d ff ff ff       	call   803492 <_pipeisclosed>
  803525:	85 c0                	test   %eax,%eax
  803527:	75 48                	jne    803571 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  803529:	e8 bb ef ff ff       	call   8024e9 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80352e:	8b 43 04             	mov    0x4(%ebx),%eax
  803531:	8b 0b                	mov    (%ebx),%ecx
  803533:	8d 51 20             	lea    0x20(%ecx),%edx
  803536:	39 d0                	cmp    %edx,%eax
  803538:	73 e2                	jae    80351c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80353a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80353d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  803541:	88 4d e7             	mov    %cl,-0x19(%ebp)
  803544:	89 c2                	mov    %eax,%edx
  803546:	c1 fa 1f             	sar    $0x1f,%edx
  803549:	89 d1                	mov    %edx,%ecx
  80354b:	c1 e9 1b             	shr    $0x1b,%ecx
  80354e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  803551:	83 e2 1f             	and    $0x1f,%edx
  803554:	29 ca                	sub    %ecx,%edx
  803556:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80355a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80355e:	83 c0 01             	add    $0x1,%eax
  803561:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803564:	83 c7 01             	add    $0x1,%edi
  803567:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80356a:	75 c2                	jne    80352e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80356c:	8b 45 10             	mov    0x10(%ebp),%eax
  80356f:	eb 05                	jmp    803576 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803571:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  803576:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803579:	5b                   	pop    %ebx
  80357a:	5e                   	pop    %esi
  80357b:	5f                   	pop    %edi
  80357c:	5d                   	pop    %ebp
  80357d:	c3                   	ret    

0080357e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80357e:	55                   	push   %ebp
  80357f:	89 e5                	mov    %esp,%ebp
  803581:	57                   	push   %edi
  803582:	56                   	push   %esi
  803583:	53                   	push   %ebx
  803584:	83 ec 18             	sub    $0x18,%esp
  803587:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80358a:	57                   	push   %edi
  80358b:	e8 54 f6 ff ff       	call   802be4 <fd2data>
  803590:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803592:	83 c4 10             	add    $0x10,%esp
  803595:	bb 00 00 00 00       	mov    $0x0,%ebx
  80359a:	eb 3d                	jmp    8035d9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80359c:	85 db                	test   %ebx,%ebx
  80359e:	74 04                	je     8035a4 <devpipe_read+0x26>
				return i;
  8035a0:	89 d8                	mov    %ebx,%eax
  8035a2:	eb 44                	jmp    8035e8 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8035a4:	89 f2                	mov    %esi,%edx
  8035a6:	89 f8                	mov    %edi,%eax
  8035a8:	e8 e5 fe ff ff       	call   803492 <_pipeisclosed>
  8035ad:	85 c0                	test   %eax,%eax
  8035af:	75 32                	jne    8035e3 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8035b1:	e8 33 ef ff ff       	call   8024e9 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8035b6:	8b 06                	mov    (%esi),%eax
  8035b8:	3b 46 04             	cmp    0x4(%esi),%eax
  8035bb:	74 df                	je     80359c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8035bd:	99                   	cltd   
  8035be:	c1 ea 1b             	shr    $0x1b,%edx
  8035c1:	01 d0                	add    %edx,%eax
  8035c3:	83 e0 1f             	and    $0x1f,%eax
  8035c6:	29 d0                	sub    %edx,%eax
  8035c8:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8035cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8035d0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8035d3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8035d6:	83 c3 01             	add    $0x1,%ebx
  8035d9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8035dc:	75 d8                	jne    8035b6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8035de:	8b 45 10             	mov    0x10(%ebp),%eax
  8035e1:	eb 05                	jmp    8035e8 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8035e3:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8035e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8035eb:	5b                   	pop    %ebx
  8035ec:	5e                   	pop    %esi
  8035ed:	5f                   	pop    %edi
  8035ee:	5d                   	pop    %ebp
  8035ef:	c3                   	ret    

008035f0 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8035f0:	55                   	push   %ebp
  8035f1:	89 e5                	mov    %esp,%ebp
  8035f3:	56                   	push   %esi
  8035f4:	53                   	push   %ebx
  8035f5:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8035f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8035fb:	50                   	push   %eax
  8035fc:	e8 fa f5 ff ff       	call   802bfb <fd_alloc>
  803601:	83 c4 10             	add    $0x10,%esp
  803604:	89 c2                	mov    %eax,%edx
  803606:	85 c0                	test   %eax,%eax
  803608:	0f 88 2c 01 00 00    	js     80373a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80360e:	83 ec 04             	sub    $0x4,%esp
  803611:	68 07 04 00 00       	push   $0x407
  803616:	ff 75 f4             	pushl  -0xc(%ebp)
  803619:	6a 00                	push   $0x0
  80361b:	e8 e8 ee ff ff       	call   802508 <sys_page_alloc>
  803620:	83 c4 10             	add    $0x10,%esp
  803623:	89 c2                	mov    %eax,%edx
  803625:	85 c0                	test   %eax,%eax
  803627:	0f 88 0d 01 00 00    	js     80373a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80362d:	83 ec 0c             	sub    $0xc,%esp
  803630:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803633:	50                   	push   %eax
  803634:	e8 c2 f5 ff ff       	call   802bfb <fd_alloc>
  803639:	89 c3                	mov    %eax,%ebx
  80363b:	83 c4 10             	add    $0x10,%esp
  80363e:	85 c0                	test   %eax,%eax
  803640:	0f 88 e2 00 00 00    	js     803728 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803646:	83 ec 04             	sub    $0x4,%esp
  803649:	68 07 04 00 00       	push   $0x407
  80364e:	ff 75 f0             	pushl  -0x10(%ebp)
  803651:	6a 00                	push   $0x0
  803653:	e8 b0 ee ff ff       	call   802508 <sys_page_alloc>
  803658:	89 c3                	mov    %eax,%ebx
  80365a:	83 c4 10             	add    $0x10,%esp
  80365d:	85 c0                	test   %eax,%eax
  80365f:	0f 88 c3 00 00 00    	js     803728 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  803665:	83 ec 0c             	sub    $0xc,%esp
  803668:	ff 75 f4             	pushl  -0xc(%ebp)
  80366b:	e8 74 f5 ff ff       	call   802be4 <fd2data>
  803670:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803672:	83 c4 0c             	add    $0xc,%esp
  803675:	68 07 04 00 00       	push   $0x407
  80367a:	50                   	push   %eax
  80367b:	6a 00                	push   $0x0
  80367d:	e8 86 ee ff ff       	call   802508 <sys_page_alloc>
  803682:	89 c3                	mov    %eax,%ebx
  803684:	83 c4 10             	add    $0x10,%esp
  803687:	85 c0                	test   %eax,%eax
  803689:	0f 88 89 00 00 00    	js     803718 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80368f:	83 ec 0c             	sub    $0xc,%esp
  803692:	ff 75 f0             	pushl  -0x10(%ebp)
  803695:	e8 4a f5 ff ff       	call   802be4 <fd2data>
  80369a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8036a1:	50                   	push   %eax
  8036a2:	6a 00                	push   $0x0
  8036a4:	56                   	push   %esi
  8036a5:	6a 00                	push   $0x0
  8036a7:	e8 9f ee ff ff       	call   80254b <sys_page_map>
  8036ac:	89 c3                	mov    %eax,%ebx
  8036ae:	83 c4 20             	add    $0x20,%esp
  8036b1:	85 c0                	test   %eax,%eax
  8036b3:	78 55                	js     80370a <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8036b5:	8b 15 80 90 80 00    	mov    0x809080,%edx
  8036bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8036be:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8036c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8036c3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8036ca:	8b 15 80 90 80 00    	mov    0x809080,%edx
  8036d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8036d3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8036d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8036d8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8036df:	83 ec 0c             	sub    $0xc,%esp
  8036e2:	ff 75 f4             	pushl  -0xc(%ebp)
  8036e5:	e8 ea f4 ff ff       	call   802bd4 <fd2num>
  8036ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8036ed:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8036ef:	83 c4 04             	add    $0x4,%esp
  8036f2:	ff 75 f0             	pushl  -0x10(%ebp)
  8036f5:	e8 da f4 ff ff       	call   802bd4 <fd2num>
  8036fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8036fd:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  803700:	83 c4 10             	add    $0x10,%esp
  803703:	ba 00 00 00 00       	mov    $0x0,%edx
  803708:	eb 30                	jmp    80373a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80370a:	83 ec 08             	sub    $0x8,%esp
  80370d:	56                   	push   %esi
  80370e:	6a 00                	push   $0x0
  803710:	e8 78 ee ff ff       	call   80258d <sys_page_unmap>
  803715:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  803718:	83 ec 08             	sub    $0x8,%esp
  80371b:	ff 75 f0             	pushl  -0x10(%ebp)
  80371e:	6a 00                	push   $0x0
  803720:	e8 68 ee ff ff       	call   80258d <sys_page_unmap>
  803725:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  803728:	83 ec 08             	sub    $0x8,%esp
  80372b:	ff 75 f4             	pushl  -0xc(%ebp)
  80372e:	6a 00                	push   $0x0
  803730:	e8 58 ee ff ff       	call   80258d <sys_page_unmap>
  803735:	83 c4 10             	add    $0x10,%esp
  803738:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80373a:	89 d0                	mov    %edx,%eax
  80373c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80373f:	5b                   	pop    %ebx
  803740:	5e                   	pop    %esi
  803741:	5d                   	pop    %ebp
  803742:	c3                   	ret    

00803743 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  803743:	55                   	push   %ebp
  803744:	89 e5                	mov    %esp,%ebp
  803746:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803749:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80374c:	50                   	push   %eax
  80374d:	ff 75 08             	pushl  0x8(%ebp)
  803750:	e8 f5 f4 ff ff       	call   802c4a <fd_lookup>
  803755:	83 c4 10             	add    $0x10,%esp
  803758:	85 c0                	test   %eax,%eax
  80375a:	78 18                	js     803774 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80375c:	83 ec 0c             	sub    $0xc,%esp
  80375f:	ff 75 f4             	pushl  -0xc(%ebp)
  803762:	e8 7d f4 ff ff       	call   802be4 <fd2data>
	return _pipeisclosed(fd, p);
  803767:	89 c2                	mov    %eax,%edx
  803769:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80376c:	e8 21 fd ff ff       	call   803492 <_pipeisclosed>
  803771:	83 c4 10             	add    $0x10,%esp
}
  803774:	c9                   	leave  
  803775:	c3                   	ret    

00803776 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  803776:	55                   	push   %ebp
  803777:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  803779:	b8 00 00 00 00       	mov    $0x0,%eax
  80377e:	5d                   	pop    %ebp
  80377f:	c3                   	ret    

00803780 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  803780:	55                   	push   %ebp
  803781:	89 e5                	mov    %esp,%ebp
  803783:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  803786:	68 dd 45 80 00       	push   $0x8045dd
  80378b:	ff 75 0c             	pushl  0xc(%ebp)
  80378e:	e8 72 e9 ff ff       	call   802105 <strcpy>
	return 0;
}
  803793:	b8 00 00 00 00       	mov    $0x0,%eax
  803798:	c9                   	leave  
  803799:	c3                   	ret    

0080379a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80379a:	55                   	push   %ebp
  80379b:	89 e5                	mov    %esp,%ebp
  80379d:	57                   	push   %edi
  80379e:	56                   	push   %esi
  80379f:	53                   	push   %ebx
  8037a0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8037a6:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8037ab:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8037b1:	eb 2d                	jmp    8037e0 <devcons_write+0x46>
		m = n - tot;
  8037b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8037b6:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8037b8:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8037bb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8037c0:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8037c3:	83 ec 04             	sub    $0x4,%esp
  8037c6:	53                   	push   %ebx
  8037c7:	03 45 0c             	add    0xc(%ebp),%eax
  8037ca:	50                   	push   %eax
  8037cb:	57                   	push   %edi
  8037cc:	e8 c6 ea ff ff       	call   802297 <memmove>
		sys_cputs(buf, m);
  8037d1:	83 c4 08             	add    $0x8,%esp
  8037d4:	53                   	push   %ebx
  8037d5:	57                   	push   %edi
  8037d6:	e8 71 ec ff ff       	call   80244c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8037db:	01 de                	add    %ebx,%esi
  8037dd:	83 c4 10             	add    $0x10,%esp
  8037e0:	89 f0                	mov    %esi,%eax
  8037e2:	3b 75 10             	cmp    0x10(%ebp),%esi
  8037e5:	72 cc                	jb     8037b3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8037e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8037ea:	5b                   	pop    %ebx
  8037eb:	5e                   	pop    %esi
  8037ec:	5f                   	pop    %edi
  8037ed:	5d                   	pop    %ebp
  8037ee:	c3                   	ret    

008037ef <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8037ef:	55                   	push   %ebp
  8037f0:	89 e5                	mov    %esp,%ebp
  8037f2:	83 ec 08             	sub    $0x8,%esp
  8037f5:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8037fa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8037fe:	74 2a                	je     80382a <devcons_read+0x3b>
  803800:	eb 05                	jmp    803807 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  803802:	e8 e2 ec ff ff       	call   8024e9 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  803807:	e8 5e ec ff ff       	call   80246a <sys_cgetc>
  80380c:	85 c0                	test   %eax,%eax
  80380e:	74 f2                	je     803802 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  803810:	85 c0                	test   %eax,%eax
  803812:	78 16                	js     80382a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  803814:	83 f8 04             	cmp    $0x4,%eax
  803817:	74 0c                	je     803825 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  803819:	8b 55 0c             	mov    0xc(%ebp),%edx
  80381c:	88 02                	mov    %al,(%edx)
	return 1;
  80381e:	b8 01 00 00 00       	mov    $0x1,%eax
  803823:	eb 05                	jmp    80382a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  803825:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80382a:	c9                   	leave  
  80382b:	c3                   	ret    

0080382c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80382c:	55                   	push   %ebp
  80382d:	89 e5                	mov    %esp,%ebp
  80382f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  803832:	8b 45 08             	mov    0x8(%ebp),%eax
  803835:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  803838:	6a 01                	push   $0x1
  80383a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80383d:	50                   	push   %eax
  80383e:	e8 09 ec ff ff       	call   80244c <sys_cputs>
}
  803843:	83 c4 10             	add    $0x10,%esp
  803846:	c9                   	leave  
  803847:	c3                   	ret    

00803848 <getchar>:

int
getchar(void)
{
  803848:	55                   	push   %ebp
  803849:	89 e5                	mov    %esp,%ebp
  80384b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80384e:	6a 01                	push   $0x1
  803850:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803853:	50                   	push   %eax
  803854:	6a 00                	push   $0x0
  803856:	e8 55 f6 ff ff       	call   802eb0 <read>
	if (r < 0)
  80385b:	83 c4 10             	add    $0x10,%esp
  80385e:	85 c0                	test   %eax,%eax
  803860:	78 0f                	js     803871 <getchar+0x29>
		return r;
	if (r < 1)
  803862:	85 c0                	test   %eax,%eax
  803864:	7e 06                	jle    80386c <getchar+0x24>
		return -E_EOF;
	return c;
  803866:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80386a:	eb 05                	jmp    803871 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80386c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  803871:	c9                   	leave  
  803872:	c3                   	ret    

00803873 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  803873:	55                   	push   %ebp
  803874:	89 e5                	mov    %esp,%ebp
  803876:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803879:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80387c:	50                   	push   %eax
  80387d:	ff 75 08             	pushl  0x8(%ebp)
  803880:	e8 c5 f3 ff ff       	call   802c4a <fd_lookup>
  803885:	83 c4 10             	add    $0x10,%esp
  803888:	85 c0                	test   %eax,%eax
  80388a:	78 11                	js     80389d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80388c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80388f:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803895:	39 10                	cmp    %edx,(%eax)
  803897:	0f 94 c0             	sete   %al
  80389a:	0f b6 c0             	movzbl %al,%eax
}
  80389d:	c9                   	leave  
  80389e:	c3                   	ret    

0080389f <opencons>:

int
opencons(void)
{
  80389f:	55                   	push   %ebp
  8038a0:	89 e5                	mov    %esp,%ebp
  8038a2:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8038a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8038a8:	50                   	push   %eax
  8038a9:	e8 4d f3 ff ff       	call   802bfb <fd_alloc>
  8038ae:	83 c4 10             	add    $0x10,%esp
		return r;
  8038b1:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8038b3:	85 c0                	test   %eax,%eax
  8038b5:	78 3e                	js     8038f5 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8038b7:	83 ec 04             	sub    $0x4,%esp
  8038ba:	68 07 04 00 00       	push   $0x407
  8038bf:	ff 75 f4             	pushl  -0xc(%ebp)
  8038c2:	6a 00                	push   $0x0
  8038c4:	e8 3f ec ff ff       	call   802508 <sys_page_alloc>
  8038c9:	83 c4 10             	add    $0x10,%esp
		return r;
  8038cc:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8038ce:	85 c0                	test   %eax,%eax
  8038d0:	78 23                	js     8038f5 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8038d2:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  8038d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8038db:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8038dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8038e0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8038e7:	83 ec 0c             	sub    $0xc,%esp
  8038ea:	50                   	push   %eax
  8038eb:	e8 e4 f2 ff ff       	call   802bd4 <fd2num>
  8038f0:	89 c2                	mov    %eax,%edx
  8038f2:	83 c4 10             	add    $0x10,%esp
}
  8038f5:	89 d0                	mov    %edx,%eax
  8038f7:	c9                   	leave  
  8038f8:	c3                   	ret    
  8038f9:	66 90                	xchg   %ax,%ax
  8038fb:	66 90                	xchg   %ax,%ax
  8038fd:	66 90                	xchg   %ax,%ax
  8038ff:	90                   	nop

00803900 <__udivdi3>:
  803900:	55                   	push   %ebp
  803901:	57                   	push   %edi
  803902:	56                   	push   %esi
  803903:	53                   	push   %ebx
  803904:	83 ec 1c             	sub    $0x1c,%esp
  803907:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80390b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80390f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803913:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803917:	85 f6                	test   %esi,%esi
  803919:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80391d:	89 ca                	mov    %ecx,%edx
  80391f:	89 f8                	mov    %edi,%eax
  803921:	75 3d                	jne    803960 <__udivdi3+0x60>
  803923:	39 cf                	cmp    %ecx,%edi
  803925:	0f 87 c5 00 00 00    	ja     8039f0 <__udivdi3+0xf0>
  80392b:	85 ff                	test   %edi,%edi
  80392d:	89 fd                	mov    %edi,%ebp
  80392f:	75 0b                	jne    80393c <__udivdi3+0x3c>
  803931:	b8 01 00 00 00       	mov    $0x1,%eax
  803936:	31 d2                	xor    %edx,%edx
  803938:	f7 f7                	div    %edi
  80393a:	89 c5                	mov    %eax,%ebp
  80393c:	89 c8                	mov    %ecx,%eax
  80393e:	31 d2                	xor    %edx,%edx
  803940:	f7 f5                	div    %ebp
  803942:	89 c1                	mov    %eax,%ecx
  803944:	89 d8                	mov    %ebx,%eax
  803946:	89 cf                	mov    %ecx,%edi
  803948:	f7 f5                	div    %ebp
  80394a:	89 c3                	mov    %eax,%ebx
  80394c:	89 d8                	mov    %ebx,%eax
  80394e:	89 fa                	mov    %edi,%edx
  803950:	83 c4 1c             	add    $0x1c,%esp
  803953:	5b                   	pop    %ebx
  803954:	5e                   	pop    %esi
  803955:	5f                   	pop    %edi
  803956:	5d                   	pop    %ebp
  803957:	c3                   	ret    
  803958:	90                   	nop
  803959:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803960:	39 ce                	cmp    %ecx,%esi
  803962:	77 74                	ja     8039d8 <__udivdi3+0xd8>
  803964:	0f bd fe             	bsr    %esi,%edi
  803967:	83 f7 1f             	xor    $0x1f,%edi
  80396a:	0f 84 98 00 00 00    	je     803a08 <__udivdi3+0x108>
  803970:	bb 20 00 00 00       	mov    $0x20,%ebx
  803975:	89 f9                	mov    %edi,%ecx
  803977:	89 c5                	mov    %eax,%ebp
  803979:	29 fb                	sub    %edi,%ebx
  80397b:	d3 e6                	shl    %cl,%esi
  80397d:	89 d9                	mov    %ebx,%ecx
  80397f:	d3 ed                	shr    %cl,%ebp
  803981:	89 f9                	mov    %edi,%ecx
  803983:	d3 e0                	shl    %cl,%eax
  803985:	09 ee                	or     %ebp,%esi
  803987:	89 d9                	mov    %ebx,%ecx
  803989:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80398d:	89 d5                	mov    %edx,%ebp
  80398f:	8b 44 24 08          	mov    0x8(%esp),%eax
  803993:	d3 ed                	shr    %cl,%ebp
  803995:	89 f9                	mov    %edi,%ecx
  803997:	d3 e2                	shl    %cl,%edx
  803999:	89 d9                	mov    %ebx,%ecx
  80399b:	d3 e8                	shr    %cl,%eax
  80399d:	09 c2                	or     %eax,%edx
  80399f:	89 d0                	mov    %edx,%eax
  8039a1:	89 ea                	mov    %ebp,%edx
  8039a3:	f7 f6                	div    %esi
  8039a5:	89 d5                	mov    %edx,%ebp
  8039a7:	89 c3                	mov    %eax,%ebx
  8039a9:	f7 64 24 0c          	mull   0xc(%esp)
  8039ad:	39 d5                	cmp    %edx,%ebp
  8039af:	72 10                	jb     8039c1 <__udivdi3+0xc1>
  8039b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8039b5:	89 f9                	mov    %edi,%ecx
  8039b7:	d3 e6                	shl    %cl,%esi
  8039b9:	39 c6                	cmp    %eax,%esi
  8039bb:	73 07                	jae    8039c4 <__udivdi3+0xc4>
  8039bd:	39 d5                	cmp    %edx,%ebp
  8039bf:	75 03                	jne    8039c4 <__udivdi3+0xc4>
  8039c1:	83 eb 01             	sub    $0x1,%ebx
  8039c4:	31 ff                	xor    %edi,%edi
  8039c6:	89 d8                	mov    %ebx,%eax
  8039c8:	89 fa                	mov    %edi,%edx
  8039ca:	83 c4 1c             	add    $0x1c,%esp
  8039cd:	5b                   	pop    %ebx
  8039ce:	5e                   	pop    %esi
  8039cf:	5f                   	pop    %edi
  8039d0:	5d                   	pop    %ebp
  8039d1:	c3                   	ret    
  8039d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8039d8:	31 ff                	xor    %edi,%edi
  8039da:	31 db                	xor    %ebx,%ebx
  8039dc:	89 d8                	mov    %ebx,%eax
  8039de:	89 fa                	mov    %edi,%edx
  8039e0:	83 c4 1c             	add    $0x1c,%esp
  8039e3:	5b                   	pop    %ebx
  8039e4:	5e                   	pop    %esi
  8039e5:	5f                   	pop    %edi
  8039e6:	5d                   	pop    %ebp
  8039e7:	c3                   	ret    
  8039e8:	90                   	nop
  8039e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8039f0:	89 d8                	mov    %ebx,%eax
  8039f2:	f7 f7                	div    %edi
  8039f4:	31 ff                	xor    %edi,%edi
  8039f6:	89 c3                	mov    %eax,%ebx
  8039f8:	89 d8                	mov    %ebx,%eax
  8039fa:	89 fa                	mov    %edi,%edx
  8039fc:	83 c4 1c             	add    $0x1c,%esp
  8039ff:	5b                   	pop    %ebx
  803a00:	5e                   	pop    %esi
  803a01:	5f                   	pop    %edi
  803a02:	5d                   	pop    %ebp
  803a03:	c3                   	ret    
  803a04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803a08:	39 ce                	cmp    %ecx,%esi
  803a0a:	72 0c                	jb     803a18 <__udivdi3+0x118>
  803a0c:	31 db                	xor    %ebx,%ebx
  803a0e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803a12:	0f 87 34 ff ff ff    	ja     80394c <__udivdi3+0x4c>
  803a18:	bb 01 00 00 00       	mov    $0x1,%ebx
  803a1d:	e9 2a ff ff ff       	jmp    80394c <__udivdi3+0x4c>
  803a22:	66 90                	xchg   %ax,%ax
  803a24:	66 90                	xchg   %ax,%ax
  803a26:	66 90                	xchg   %ax,%ax
  803a28:	66 90                	xchg   %ax,%ax
  803a2a:	66 90                	xchg   %ax,%ax
  803a2c:	66 90                	xchg   %ax,%ax
  803a2e:	66 90                	xchg   %ax,%ax

00803a30 <__umoddi3>:
  803a30:	55                   	push   %ebp
  803a31:	57                   	push   %edi
  803a32:	56                   	push   %esi
  803a33:	53                   	push   %ebx
  803a34:	83 ec 1c             	sub    $0x1c,%esp
  803a37:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  803a3b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  803a3f:	8b 74 24 34          	mov    0x34(%esp),%esi
  803a43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803a47:	85 d2                	test   %edx,%edx
  803a49:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  803a4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803a51:	89 f3                	mov    %esi,%ebx
  803a53:	89 3c 24             	mov    %edi,(%esp)
  803a56:	89 74 24 04          	mov    %esi,0x4(%esp)
  803a5a:	75 1c                	jne    803a78 <__umoddi3+0x48>
  803a5c:	39 f7                	cmp    %esi,%edi
  803a5e:	76 50                	jbe    803ab0 <__umoddi3+0x80>
  803a60:	89 c8                	mov    %ecx,%eax
  803a62:	89 f2                	mov    %esi,%edx
  803a64:	f7 f7                	div    %edi
  803a66:	89 d0                	mov    %edx,%eax
  803a68:	31 d2                	xor    %edx,%edx
  803a6a:	83 c4 1c             	add    $0x1c,%esp
  803a6d:	5b                   	pop    %ebx
  803a6e:	5e                   	pop    %esi
  803a6f:	5f                   	pop    %edi
  803a70:	5d                   	pop    %ebp
  803a71:	c3                   	ret    
  803a72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803a78:	39 f2                	cmp    %esi,%edx
  803a7a:	89 d0                	mov    %edx,%eax
  803a7c:	77 52                	ja     803ad0 <__umoddi3+0xa0>
  803a7e:	0f bd ea             	bsr    %edx,%ebp
  803a81:	83 f5 1f             	xor    $0x1f,%ebp
  803a84:	75 5a                	jne    803ae0 <__umoddi3+0xb0>
  803a86:	3b 54 24 04          	cmp    0x4(%esp),%edx
  803a8a:	0f 82 e0 00 00 00    	jb     803b70 <__umoddi3+0x140>
  803a90:	39 0c 24             	cmp    %ecx,(%esp)
  803a93:	0f 86 d7 00 00 00    	jbe    803b70 <__umoddi3+0x140>
  803a99:	8b 44 24 08          	mov    0x8(%esp),%eax
  803a9d:	8b 54 24 04          	mov    0x4(%esp),%edx
  803aa1:	83 c4 1c             	add    $0x1c,%esp
  803aa4:	5b                   	pop    %ebx
  803aa5:	5e                   	pop    %esi
  803aa6:	5f                   	pop    %edi
  803aa7:	5d                   	pop    %ebp
  803aa8:	c3                   	ret    
  803aa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803ab0:	85 ff                	test   %edi,%edi
  803ab2:	89 fd                	mov    %edi,%ebp
  803ab4:	75 0b                	jne    803ac1 <__umoddi3+0x91>
  803ab6:	b8 01 00 00 00       	mov    $0x1,%eax
  803abb:	31 d2                	xor    %edx,%edx
  803abd:	f7 f7                	div    %edi
  803abf:	89 c5                	mov    %eax,%ebp
  803ac1:	89 f0                	mov    %esi,%eax
  803ac3:	31 d2                	xor    %edx,%edx
  803ac5:	f7 f5                	div    %ebp
  803ac7:	89 c8                	mov    %ecx,%eax
  803ac9:	f7 f5                	div    %ebp
  803acb:	89 d0                	mov    %edx,%eax
  803acd:	eb 99                	jmp    803a68 <__umoddi3+0x38>
  803acf:	90                   	nop
  803ad0:	89 c8                	mov    %ecx,%eax
  803ad2:	89 f2                	mov    %esi,%edx
  803ad4:	83 c4 1c             	add    $0x1c,%esp
  803ad7:	5b                   	pop    %ebx
  803ad8:	5e                   	pop    %esi
  803ad9:	5f                   	pop    %edi
  803ada:	5d                   	pop    %ebp
  803adb:	c3                   	ret    
  803adc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803ae0:	8b 34 24             	mov    (%esp),%esi
  803ae3:	bf 20 00 00 00       	mov    $0x20,%edi
  803ae8:	89 e9                	mov    %ebp,%ecx
  803aea:	29 ef                	sub    %ebp,%edi
  803aec:	d3 e0                	shl    %cl,%eax
  803aee:	89 f9                	mov    %edi,%ecx
  803af0:	89 f2                	mov    %esi,%edx
  803af2:	d3 ea                	shr    %cl,%edx
  803af4:	89 e9                	mov    %ebp,%ecx
  803af6:	09 c2                	or     %eax,%edx
  803af8:	89 d8                	mov    %ebx,%eax
  803afa:	89 14 24             	mov    %edx,(%esp)
  803afd:	89 f2                	mov    %esi,%edx
  803aff:	d3 e2                	shl    %cl,%edx
  803b01:	89 f9                	mov    %edi,%ecx
  803b03:	89 54 24 04          	mov    %edx,0x4(%esp)
  803b07:	8b 54 24 0c          	mov    0xc(%esp),%edx
  803b0b:	d3 e8                	shr    %cl,%eax
  803b0d:	89 e9                	mov    %ebp,%ecx
  803b0f:	89 c6                	mov    %eax,%esi
  803b11:	d3 e3                	shl    %cl,%ebx
  803b13:	89 f9                	mov    %edi,%ecx
  803b15:	89 d0                	mov    %edx,%eax
  803b17:	d3 e8                	shr    %cl,%eax
  803b19:	89 e9                	mov    %ebp,%ecx
  803b1b:	09 d8                	or     %ebx,%eax
  803b1d:	89 d3                	mov    %edx,%ebx
  803b1f:	89 f2                	mov    %esi,%edx
  803b21:	f7 34 24             	divl   (%esp)
  803b24:	89 d6                	mov    %edx,%esi
  803b26:	d3 e3                	shl    %cl,%ebx
  803b28:	f7 64 24 04          	mull   0x4(%esp)
  803b2c:	39 d6                	cmp    %edx,%esi
  803b2e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803b32:	89 d1                	mov    %edx,%ecx
  803b34:	89 c3                	mov    %eax,%ebx
  803b36:	72 08                	jb     803b40 <__umoddi3+0x110>
  803b38:	75 11                	jne    803b4b <__umoddi3+0x11b>
  803b3a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  803b3e:	73 0b                	jae    803b4b <__umoddi3+0x11b>
  803b40:	2b 44 24 04          	sub    0x4(%esp),%eax
  803b44:	1b 14 24             	sbb    (%esp),%edx
  803b47:	89 d1                	mov    %edx,%ecx
  803b49:	89 c3                	mov    %eax,%ebx
  803b4b:	8b 54 24 08          	mov    0x8(%esp),%edx
  803b4f:	29 da                	sub    %ebx,%edx
  803b51:	19 ce                	sbb    %ecx,%esi
  803b53:	89 f9                	mov    %edi,%ecx
  803b55:	89 f0                	mov    %esi,%eax
  803b57:	d3 e0                	shl    %cl,%eax
  803b59:	89 e9                	mov    %ebp,%ecx
  803b5b:	d3 ea                	shr    %cl,%edx
  803b5d:	89 e9                	mov    %ebp,%ecx
  803b5f:	d3 ee                	shr    %cl,%esi
  803b61:	09 d0                	or     %edx,%eax
  803b63:	89 f2                	mov    %esi,%edx
  803b65:	83 c4 1c             	add    $0x1c,%esp
  803b68:	5b                   	pop    %ebx
  803b69:	5e                   	pop    %esi
  803b6a:	5f                   	pop    %edi
  803b6b:	5d                   	pop    %ebp
  803b6c:	c3                   	ret    
  803b6d:	8d 76 00             	lea    0x0(%esi),%esi
  803b70:	29 f9                	sub    %edi,%ecx
  803b72:	19 d6                	sbb    %edx,%esi
  803b74:	89 74 24 04          	mov    %esi,0x4(%esp)
  803b78:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803b7c:	e9 18 ff ff ff       	jmp    803a99 <__umoddi3+0x69>
