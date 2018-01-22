
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
  8000b2:	68 c0 38 80 00       	push   $0x8038c0
  8000b7:	e8 00 1b 00 00       	call   801bbc <cprintf>
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
  8000d4:	68 d7 38 80 00       	push   $0x8038d7
  8000d9:	6a 3a                	push   $0x3a
  8000db:	68 e7 38 80 00       	push   $0x8038e7
  8000e0:	e8 fe 19 00 00       	call   801ae3 <_panic>
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
  800106:	68 f0 38 80 00       	push   $0x8038f0
  80010b:	68 fd 38 80 00       	push   $0x8038fd
  800110:	6a 44                	push   $0x44
  800112:	68 e7 38 80 00       	push   $0x8038e7
  800117:	e8 c7 19 00 00       	call   801ae3 <_panic>

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
  8001ca:	68 f0 38 80 00       	push   $0x8038f0
  8001cf:	68 fd 38 80 00       	push   $0x8038fd
  8001d4:	6a 5d                	push   $0x5d
  8001d6:	68 e7 38 80 00       	push   $0x8038e7
  8001db:	e8 03 19 00 00       	call   801ae3 <_panic>

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
  80029a:	68 14 39 80 00       	push   $0x803914
  80029f:	6a 27                	push   $0x27
  8002a1:	68 d0 39 80 00       	push   $0x8039d0
  8002a6:	e8 38 18 00 00       	call   801ae3 <_panic>
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
  8002ba:	68 44 39 80 00       	push   $0x803944
  8002bf:	6a 2b                	push   $0x2b
  8002c1:	68 d0 39 80 00       	push   $0x8039d0
  8002c6:	e8 18 18 00 00       	call   801ae3 <_panic>
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
  8002d9:	e8 66 22 00 00       	call   802544 <sys_page_alloc>

	if (r < 0) {
  8002de:	83 c4 10             	add    $0x10,%esp
  8002e1:	85 c0                	test   %eax,%eax
  8002e3:	79 12                	jns    8002f7 <bc_pgfault+0x83>
		panic("page alloc fault - %e", r);
  8002e5:	50                   	push   %eax
  8002e6:	68 d8 39 80 00       	push   $0x8039d8
  8002eb:	6a 37                	push   $0x37
  8002ed:	68 d0 39 80 00       	push   $0x8039d0
  8002f2:	e8 ec 17 00 00       	call   801ae3 <_panic>
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
  800312:	68 ee 39 80 00       	push   $0x8039ee
  800317:	6a 3d                	push   $0x3d
  800319:	68 d0 39 80 00       	push   $0x8039d0
  80031e:	e8 c0 17 00 00       	call   801ae3 <_panic>
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
  80033e:	e8 44 22 00 00       	call   802587 <sys_page_map>
  800343:	83 c4 20             	add    $0x20,%esp
  800346:	85 c0                	test   %eax,%eax
  800348:	79 12                	jns    80035c <bc_pgfault+0xe8>
		panic("in bc_pgfault, sys_page_map: %e", r);
  80034a:	50                   	push   %eax
  80034b:	68 68 39 80 00       	push   $0x803968
  800350:	6a 43                	push   $0x43
  800352:	68 d0 39 80 00       	push   $0x8039d0
  800357:	e8 87 17 00 00       	call   801ae3 <_panic>

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
  800376:	68 02 3a 80 00       	push   $0x803a02
  80037b:	6a 49                	push   $0x49
  80037d:	68 d0 39 80 00       	push   $0x8039d0
  800382:	e8 5c 17 00 00       	call   801ae3 <_panic>
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
  8003ab:	68 88 39 80 00       	push   $0x803988
  8003b0:	6a 09                	push   $0x9
  8003b2:	68 d0 39 80 00       	push   $0x8039d0
  8003b7:	e8 27 17 00 00       	call   801ae3 <_panic>
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
  800422:	68 1b 3a 80 00       	push   $0x803a1b
  800427:	6a 59                	push   $0x59
  800429:	68 d0 39 80 00       	push   $0x8039d0
  80042e:	e8 b0 16 00 00       	call   801ae3 <_panic>

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
  80048d:	e8 f5 20 00 00       	call   802587 <sys_page_map>
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
  8004ab:	e8 a5 22 00 00       	call   802755 <set_pgfault_handler>
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
  8004cc:	e8 02 1e 00 00       	call   8022d3 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  8004d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004d8:	e8 b1 fe ff ff       	call   80038e <diskaddr>
  8004dd:	83 c4 08             	add    $0x8,%esp
  8004e0:	68 36 3a 80 00       	push   $0x803a36
  8004e5:	50                   	push   %eax
  8004e6:	e8 56 1c 00 00       	call   802141 <strcpy>
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
  80051a:	68 58 3a 80 00       	push   $0x803a58
  80051f:	68 fd 38 80 00       	push   $0x8038fd
  800524:	6a 72                	push   $0x72
  800526:	68 d0 39 80 00       	push   $0x8039d0
  80052b:	e8 b3 15 00 00       	call   801ae3 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  800530:	83 ec 0c             	sub    $0xc,%esp
  800533:	6a 01                	push   $0x1
  800535:	e8 54 fe ff ff       	call   80038e <diskaddr>
  80053a:	89 04 24             	mov    %eax,(%esp)
  80053d:	e8 b2 fe ff ff       	call   8003f4 <va_is_dirty>
  800542:	83 c4 10             	add    $0x10,%esp
  800545:	84 c0                	test   %al,%al
  800547:	74 16                	je     80055f <bc_init+0xc3>
  800549:	68 3d 3a 80 00       	push   $0x803a3d
  80054e:	68 fd 38 80 00       	push   $0x8038fd
  800553:	6a 73                	push   $0x73
  800555:	68 d0 39 80 00       	push   $0x8039d0
  80055a:	e8 84 15 00 00       	call   801ae3 <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  80055f:	83 ec 0c             	sub    $0xc,%esp
  800562:	6a 01                	push   $0x1
  800564:	e8 25 fe ff ff       	call   80038e <diskaddr>
  800569:	83 c4 08             	add    $0x8,%esp
  80056c:	50                   	push   %eax
  80056d:	6a 00                	push   $0x0
  80056f:	e8 55 20 00 00       	call   8025c9 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  800574:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80057b:	e8 0e fe ff ff       	call   80038e <diskaddr>
  800580:	89 04 24             	mov    %eax,(%esp)
  800583:	e8 3e fe ff ff       	call   8003c6 <va_is_mapped>
  800588:	83 c4 10             	add    $0x10,%esp
  80058b:	84 c0                	test   %al,%al
  80058d:	74 16                	je     8005a5 <bc_init+0x109>
  80058f:	68 57 3a 80 00       	push   $0x803a57
  800594:	68 fd 38 80 00       	push   $0x8038fd
  800599:	6a 77                	push   $0x77
  80059b:	68 d0 39 80 00       	push   $0x8039d0
  8005a0:	e8 3e 15 00 00       	call   801ae3 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8005a5:	83 ec 0c             	sub    $0xc,%esp
  8005a8:	6a 01                	push   $0x1
  8005aa:	e8 df fd ff ff       	call   80038e <diskaddr>
  8005af:	83 c4 08             	add    $0x8,%esp
  8005b2:	68 36 3a 80 00       	push   $0x803a36
  8005b7:	50                   	push   %eax
  8005b8:	e8 2e 1c 00 00       	call   8021eb <strcmp>
  8005bd:	83 c4 10             	add    $0x10,%esp
  8005c0:	85 c0                	test   %eax,%eax
  8005c2:	74 16                	je     8005da <bc_init+0x13e>
  8005c4:	68 ac 39 80 00       	push   $0x8039ac
  8005c9:	68 fd 38 80 00       	push   $0x8038fd
  8005ce:	6a 7a                	push   $0x7a
  8005d0:	68 d0 39 80 00       	push   $0x8039d0
  8005d5:	e8 09 15 00 00       	call   801ae3 <_panic>

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
  8005f4:	e8 da 1c 00 00       	call   8022d3 <memmove>
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
  800623:	e8 ab 1c 00 00       	call   8022d3 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  800628:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80062f:	e8 5a fd ff ff       	call   80038e <diskaddr>
  800634:	83 c4 08             	add    $0x8,%esp
  800637:	68 36 3a 80 00       	push   $0x803a36
  80063c:	50                   	push   %eax
  80063d:	e8 ff 1a 00 00       	call   802141 <strcpy>

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
  800674:	68 58 3a 80 00       	push   $0x803a58
  800679:	68 fd 38 80 00       	push   $0x8038fd
  80067e:	68 8b 00 00 00       	push   $0x8b
  800683:	68 d0 39 80 00       	push   $0x8039d0
  800688:	e8 56 14 00 00       	call   801ae3 <_panic>
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
  80069d:	e8 27 1f 00 00       	call   8025c9 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  8006a2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006a9:	e8 e0 fc ff ff       	call   80038e <diskaddr>
  8006ae:	89 04 24             	mov    %eax,(%esp)
  8006b1:	e8 10 fd ff ff       	call   8003c6 <va_is_mapped>
  8006b6:	83 c4 10             	add    $0x10,%esp
  8006b9:	84 c0                	test   %al,%al
  8006bb:	74 19                	je     8006d6 <bc_init+0x23a>
  8006bd:	68 57 3a 80 00       	push   $0x803a57
  8006c2:	68 fd 38 80 00       	push   $0x8038fd
  8006c7:	68 93 00 00 00       	push   $0x93
  8006cc:	68 d0 39 80 00       	push   $0x8039d0
  8006d1:	e8 0d 14 00 00       	call   801ae3 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8006d6:	83 ec 0c             	sub    $0xc,%esp
  8006d9:	6a 01                	push   $0x1
  8006db:	e8 ae fc ff ff       	call   80038e <diskaddr>
  8006e0:	83 c4 08             	add    $0x8,%esp
  8006e3:	68 36 3a 80 00       	push   $0x803a36
  8006e8:	50                   	push   %eax
  8006e9:	e8 fd 1a 00 00       	call   8021eb <strcmp>
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	85 c0                	test   %eax,%eax
  8006f3:	74 19                	je     80070e <bc_init+0x272>
  8006f5:	68 ac 39 80 00       	push   $0x8039ac
  8006fa:	68 fd 38 80 00       	push   $0x8038fd
  8006ff:	68 96 00 00 00       	push   $0x96
  800704:	68 d0 39 80 00       	push   $0x8039d0
  800709:	e8 d5 13 00 00       	call   801ae3 <_panic>

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
  800728:	e8 a6 1b 00 00       	call   8022d3 <memmove>
	flush_block(diskaddr(1));
  80072d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800734:	e8 55 fc ff ff       	call   80038e <diskaddr>
  800739:	89 04 24             	mov    %eax,(%esp)
  80073c:	e8 cb fc ff ff       	call   80040c <flush_block>

	cprintf("block cache is good\n");
  800741:	c7 04 24 72 3a 80 00 	movl   $0x803a72,(%esp)
  800748:	e8 6f 14 00 00       	call   801bbc <cprintf>
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
  800769:	e8 65 1b 00 00       	call   8022d3 <memmove>
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
  80078c:	68 87 3a 80 00       	push   $0x803a87
  800791:	6a 0f                	push   $0xf
  800793:	68 a5 3a 80 00       	push   $0x803aa5
  800798:	e8 46 13 00 00       	call   801ae3 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  80079d:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8007a4:	76 14                	jbe    8007ba <check_super+0x44>
		panic("file system is too large");
  8007a6:	83 ec 04             	sub    $0x4,%esp
  8007a9:	68 ad 3a 80 00       	push   $0x803aad
  8007ae:	6a 12                	push   $0x12
  8007b0:	68 a5 3a 80 00       	push   $0x803aa5
  8007b5:	e8 29 13 00 00       	call   801ae3 <_panic>

	cprintf("superblock is good\n");
  8007ba:	83 ec 0c             	sub    $0xc,%esp
  8007bd:	68 c6 3a 80 00       	push   $0x803ac6
  8007c2:	e8 f5 13 00 00       	call   801bbc <cprintf>
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
  80081a:	68 da 3a 80 00       	push   $0x803ada
  80081f:	6a 2d                	push   $0x2d
  800821:	68 a5 3a 80 00       	push   $0x803aa5
  800826:	e8 b8 12 00 00       	call   801ae3 <_panic>
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
  800971:	68 f5 3a 80 00       	push   $0x803af5
  800976:	68 fd 38 80 00       	push   $0x8038fd
  80097b:	6a 61                	push   $0x61
  80097d:	68 a5 3a 80 00       	push   $0x803aa5
  800982:	e8 5c 11 00 00       	call   801ae3 <_panic>
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
  8009a4:	68 09 3b 80 00       	push   $0x803b09
  8009a9:	68 fd 38 80 00       	push   $0x8038fd
  8009ae:	6a 64                	push   $0x64
  8009b0:	68 a5 3a 80 00       	push   $0x803aa5
  8009b5:	e8 29 11 00 00       	call   801ae3 <_panic>
	assert(!block_is_free(1));
  8009ba:	83 ec 0c             	sub    $0xc,%esp
  8009bd:	6a 01                	push   $0x1
  8009bf:	e8 08 fe ff ff       	call   8007cc <block_is_free>
  8009c4:	83 c4 10             	add    $0x10,%esp
  8009c7:	84 c0                	test   %al,%al
  8009c9:	74 16                	je     8009e1 <check_bitmap+0x94>
  8009cb:	68 1b 3b 80 00       	push   $0x803b1b
  8009d0:	68 fd 38 80 00       	push   $0x8038fd
  8009d5:	6a 65                	push   $0x65
  8009d7:	68 a5 3a 80 00       	push   $0x803aa5
  8009dc:	e8 02 11 00 00       	call   801ae3 <_panic>

	cprintf("bitmap is good\n");
  8009e1:	83 ec 0c             	sub    $0xc,%esp
  8009e4:	68 2d 3b 80 00       	push   $0x803b2d
  8009e9:	e8 ce 11 00 00       	call   801bbc <cprintf>
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
  800a8d:	68 3d 3b 80 00       	push   $0x803b3d
  800a92:	68 d4 00 00 00       	push   $0xd4
  800a97:	68 a5 3a 80 00       	push   $0x803aa5
  800a9c:	e8 42 10 00 00       	call   801ae3 <_panic>
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
  800b4c:	e8 82 17 00 00       	call   8022d3 <memmove>
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
  800b86:	68 53 3b 80 00       	push   $0x803b53
  800b8b:	68 fd 38 80 00       	push   $0x8038fd
  800b90:	68 ed 00 00 00       	push   $0xed
  800b95:	68 a5 3a 80 00       	push   $0x803aa5
  800b9a:	e8 44 0f 00 00       	call   801ae3 <_panic>
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
  800c02:	e8 e4 15 00 00       	call   8021eb <strcmp>
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
  800c6a:	e8 d2 14 00 00       	call   802141 <strcpy>
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
  800d91:	e8 3d 15 00 00       	call   8022d3 <memmove>
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
  800e62:	68 70 3b 80 00       	push   $0x803b70
  800e67:	e8 50 0d 00 00       	call   801bbc <cprintf>
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
  800f18:	e8 b6 13 00 00       	call   8022d3 <memmove>
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
  801029:	68 53 3b 80 00       	push   $0x803b53
  80102e:	68 fd 38 80 00       	push   $0x8038fd
  801033:	68 06 01 00 00       	push   $0x106
  801038:	68 a5 3a 80 00       	push   $0x803aa5
  80103d:	e8 a1 0a 00 00       	call   801ae3 <_panic>
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
  8010f4:	e8 48 10 00 00       	call   802141 <strcpy>
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
  8011af:	e8 52 1f 00 00       	call   803106 <pageref>
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
  8011d4:	e8 6b 13 00 00       	call   802544 <sys_page_alloc>
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
  801205:	e8 7c 10 00 00       	call   802286 <memset>
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
  80124f:	e8 b2 1e 00 00       	call   803106 <pageref>
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
  80139f:	e8 9d 0d 00 00       	call   802141 <strcpy>
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
  801429:	e8 a5 0e 00 00       	call   8022d3 <memmove>
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
  801560:	e8 7f 12 00 00       	call   8027e4 <ipc_recv>
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
  801574:	68 90 3b 80 00       	push   $0x803b90
  801579:	e8 3e 06 00 00       	call   801bbc <cprintf>
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
  8015d1:	68 c0 3b 80 00       	push   $0x803bc0
  8015d6:	e8 e1 05 00 00       	call   801bbc <cprintf>
  8015db:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  8015de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  8015e3:	ff 75 f0             	pushl  -0x10(%ebp)
  8015e6:	ff 75 ec             	pushl  -0x14(%ebp)
  8015e9:	50                   	push   %eax
  8015ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8015ed:	e8 67 12 00 00       	call   802859 <ipc_send>
		sys_page_unmap(0, fsreq);
  8015f2:	83 c4 08             	add    $0x8,%esp
  8015f5:	ff 35 44 50 80 00    	pushl  0x805044
  8015fb:	6a 00                	push   $0x0
  8015fd:	e8 c7 0f 00 00       	call   8025c9 <sys_page_unmap>
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
  801610:	c7 05 60 90 80 00 e3 	movl   $0x803be3,0x809060
  801617:	3b 80 00 
	cprintf("FS is running\n");
  80161a:	68 e6 3b 80 00       	push   $0x803be6
  80161f:	e8 98 05 00 00       	call   801bbc <cprintf>
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
  801630:	c7 04 24 f5 3b 80 00 	movl   $0x803bf5,(%esp)
  801637:	e8 80 05 00 00       	call   801bbc <cprintf>

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
  801660:	e8 df 0e 00 00       	call   802544 <sys_page_alloc>
  801665:	83 c4 10             	add    $0x10,%esp
  801668:	85 c0                	test   %eax,%eax
  80166a:	79 12                	jns    80167e <fs_test+0x2e>
		panic("sys_page_alloc: %e", r);
  80166c:	50                   	push   %eax
  80166d:	68 04 3c 80 00       	push   $0x803c04
  801672:	6a 12                	push   $0x12
  801674:	68 17 3c 80 00       	push   $0x803c17
  801679:	e8 65 04 00 00       	call   801ae3 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  80167e:	83 ec 04             	sub    $0x4,%esp
  801681:	68 00 10 00 00       	push   $0x1000
  801686:	ff 35 04 a0 80 00    	pushl  0x80a004
  80168c:	68 00 10 00 00       	push   $0x1000
  801691:	e8 3d 0c 00 00       	call   8022d3 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  801696:	e8 aa f1 ff ff       	call   800845 <alloc_block>
  80169b:	83 c4 10             	add    $0x10,%esp
  80169e:	85 c0                	test   %eax,%eax
  8016a0:	79 12                	jns    8016b4 <fs_test+0x64>
		panic("alloc_block: %e", r);
  8016a2:	50                   	push   %eax
  8016a3:	68 21 3c 80 00       	push   $0x803c21
  8016a8:	6a 17                	push   $0x17
  8016aa:	68 17 3c 80 00       	push   $0x803c17
  8016af:	e8 2f 04 00 00       	call   801ae3 <_panic>
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
  8016df:	68 31 3c 80 00       	push   $0x803c31
  8016e4:	68 fd 38 80 00       	push   $0x8038fd
  8016e9:	6a 19                	push   $0x19
  8016eb:	68 17 3c 80 00       	push   $0x803c17
  8016f0:	e8 ee 03 00 00       	call   801ae3 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  8016f5:	8b 0d 04 a0 80 00    	mov    0x80a004,%ecx
  8016fb:	85 04 91             	test   %eax,(%ecx,%edx,4)
  8016fe:	74 16                	je     801716 <fs_test+0xc6>
  801700:	68 ac 3d 80 00       	push   $0x803dac
  801705:	68 fd 38 80 00       	push   $0x8038fd
  80170a:	6a 1b                	push   $0x1b
  80170c:	68 17 3c 80 00       	push   $0x803c17
  801711:	e8 cd 03 00 00       	call   801ae3 <_panic>
	cprintf("alloc_block is good\n");
  801716:	83 ec 0c             	sub    $0xc,%esp
  801719:	68 4c 3c 80 00       	push   $0x803c4c
  80171e:	e8 99 04 00 00       	call   801bbc <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  801723:	83 c4 08             	add    $0x8,%esp
  801726:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801729:	50                   	push   %eax
  80172a:	68 61 3c 80 00       	push   $0x803c61
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
  801746:	68 6c 3c 80 00       	push   $0x803c6c
  80174b:	6a 1f                	push   $0x1f
  80174d:	68 17 3c 80 00       	push   $0x803c17
  801752:	e8 8c 03 00 00       	call   801ae3 <_panic>
	else if (r == 0)
  801757:	85 c0                	test   %eax,%eax
  801759:	75 14                	jne    80176f <fs_test+0x11f>
		panic("file_open /not-found succeeded!");
  80175b:	83 ec 04             	sub    $0x4,%esp
  80175e:	68 cc 3d 80 00       	push   $0x803dcc
  801763:	6a 21                	push   $0x21
  801765:	68 17 3c 80 00       	push   $0x803c17
  80176a:	e8 74 03 00 00       	call   801ae3 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  80176f:	83 ec 08             	sub    $0x8,%esp
  801772:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801775:	50                   	push   %eax
  801776:	68 85 3c 80 00       	push   $0x803c85
  80177b:	e8 70 f5 ff ff       	call   800cf0 <file_open>
  801780:	83 c4 10             	add    $0x10,%esp
  801783:	85 c0                	test   %eax,%eax
  801785:	79 12                	jns    801799 <fs_test+0x149>
		panic("file_open /newmotd: %e", r);
  801787:	50                   	push   %eax
  801788:	68 8e 3c 80 00       	push   $0x803c8e
  80178d:	6a 23                	push   $0x23
  80178f:	68 17 3c 80 00       	push   $0x803c17
  801794:	e8 4a 03 00 00       	call   801ae3 <_panic>
	cprintf("file_open is good\n");
  801799:	83 ec 0c             	sub    $0xc,%esp
  80179c:	68 a5 3c 80 00       	push   $0x803ca5
  8017a1:	e8 16 04 00 00       	call   801bbc <cprintf>

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
  8017bf:	68 b8 3c 80 00       	push   $0x803cb8
  8017c4:	6a 27                	push   $0x27
  8017c6:	68 17 3c 80 00       	push   $0x803c17
  8017cb:	e8 13 03 00 00       	call   801ae3 <_panic>
	if (strcmp(blk, msg) != 0)
  8017d0:	83 ec 08             	sub    $0x8,%esp
  8017d3:	68 ec 3d 80 00       	push   $0x803dec
  8017d8:	ff 75 f0             	pushl  -0x10(%ebp)
  8017db:	e8 0b 0a 00 00       	call   8021eb <strcmp>
  8017e0:	83 c4 10             	add    $0x10,%esp
  8017e3:	85 c0                	test   %eax,%eax
  8017e5:	74 14                	je     8017fb <fs_test+0x1ab>
		panic("file_get_block returned wrong data");
  8017e7:	83 ec 04             	sub    $0x4,%esp
  8017ea:	68 14 3e 80 00       	push   $0x803e14
  8017ef:	6a 29                	push   $0x29
  8017f1:	68 17 3c 80 00       	push   $0x803c17
  8017f6:	e8 e8 02 00 00       	call   801ae3 <_panic>
	cprintf("file_get_block is good\n");
  8017fb:	83 ec 0c             	sub    $0xc,%esp
  8017fe:	68 cb 3c 80 00       	push   $0x803ccb
  801803:	e8 b4 03 00 00       	call   801bbc <cprintf>

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
  801824:	68 e4 3c 80 00       	push   $0x803ce4
  801829:	68 fd 38 80 00       	push   $0x8038fd
  80182e:	6a 2d                	push   $0x2d
  801830:	68 17 3c 80 00       	push   $0x803c17
  801835:	e8 a9 02 00 00       	call   801ae3 <_panic>
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
  801859:	68 e3 3c 80 00       	push   $0x803ce3
  80185e:	68 fd 38 80 00       	push   $0x8038fd
  801863:	6a 2f                	push   $0x2f
  801865:	68 17 3c 80 00       	push   $0x803c17
  80186a:	e8 74 02 00 00       	call   801ae3 <_panic>
	cprintf("file_flush is good\n");
  80186f:	83 ec 0c             	sub    $0xc,%esp
  801872:	68 ff 3c 80 00       	push   $0x803cff
  801877:	e8 40 03 00 00       	call   801bbc <cprintf>

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
  801891:	68 13 3d 80 00       	push   $0x803d13
  801896:	6a 33                	push   $0x33
  801898:	68 17 3c 80 00       	push   $0x803c17
  80189d:	e8 41 02 00 00       	call   801ae3 <_panic>
	assert(f->f_direct[0] == 0);
  8018a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a5:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  8018ac:	74 16                	je     8018c4 <fs_test+0x274>
  8018ae:	68 25 3d 80 00       	push   $0x803d25
  8018b3:	68 fd 38 80 00       	push   $0x8038fd
  8018b8:	6a 34                	push   $0x34
  8018ba:	68 17 3c 80 00       	push   $0x803c17
  8018bf:	e8 1f 02 00 00       	call   801ae3 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8018c4:	c1 e8 0c             	shr    $0xc,%eax
  8018c7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018ce:	a8 40                	test   $0x40,%al
  8018d0:	74 16                	je     8018e8 <fs_test+0x298>
  8018d2:	68 39 3d 80 00       	push   $0x803d39
  8018d7:	68 fd 38 80 00       	push   $0x8038fd
  8018dc:	6a 35                	push   $0x35
  8018de:	68 17 3c 80 00       	push   $0x803c17
  8018e3:	e8 fb 01 00 00       	call   801ae3 <_panic>
	cprintf("file_truncate is good\n");
  8018e8:	83 ec 0c             	sub    $0xc,%esp
  8018eb:	68 53 3d 80 00       	push   $0x803d53
  8018f0:	e8 c7 02 00 00       	call   801bbc <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  8018f5:	c7 04 24 ec 3d 80 00 	movl   $0x803dec,(%esp)
  8018fc:	e8 07 08 00 00       	call   802108 <strlen>
  801901:	83 c4 08             	add    $0x8,%esp
  801904:	50                   	push   %eax
  801905:	ff 75 f4             	pushl  -0xc(%ebp)
  801908:	e8 a2 f4 ff ff       	call   800daf <file_set_size>
  80190d:	83 c4 10             	add    $0x10,%esp
  801910:	85 c0                	test   %eax,%eax
  801912:	79 12                	jns    801926 <fs_test+0x2d6>
		panic("file_set_size 2: %e", r);
  801914:	50                   	push   %eax
  801915:	68 6a 3d 80 00       	push   $0x803d6a
  80191a:	6a 39                	push   $0x39
  80191c:	68 17 3c 80 00       	push   $0x803c17
  801921:	e8 bd 01 00 00       	call   801ae3 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801926:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801929:	89 c2                	mov    %eax,%edx
  80192b:	c1 ea 0c             	shr    $0xc,%edx
  80192e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801935:	f6 c2 40             	test   $0x40,%dl
  801938:	74 16                	je     801950 <fs_test+0x300>
  80193a:	68 39 3d 80 00       	push   $0x803d39
  80193f:	68 fd 38 80 00       	push   $0x8038fd
  801944:	6a 3a                	push   $0x3a
  801946:	68 17 3c 80 00       	push   $0x803c17
  80194b:	e8 93 01 00 00       	call   801ae3 <_panic>
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
  801967:	68 7e 3d 80 00       	push   $0x803d7e
  80196c:	6a 3c                	push   $0x3c
  80196e:	68 17 3c 80 00       	push   $0x803c17
  801973:	e8 6b 01 00 00       	call   801ae3 <_panic>
	strcpy(blk, msg);
  801978:	83 ec 08             	sub    $0x8,%esp
  80197b:	68 ec 3d 80 00       	push   $0x803dec
  801980:	ff 75 f0             	pushl  -0x10(%ebp)
  801983:	e8 b9 07 00 00       	call   802141 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801988:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80198b:	c1 e8 0c             	shr    $0xc,%eax
  80198e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801995:	83 c4 10             	add    $0x10,%esp
  801998:	a8 40                	test   $0x40,%al
  80199a:	75 16                	jne    8019b2 <fs_test+0x362>
  80199c:	68 e4 3c 80 00       	push   $0x803ce4
  8019a1:	68 fd 38 80 00       	push   $0x8038fd
  8019a6:	6a 3e                	push   $0x3e
  8019a8:	68 17 3c 80 00       	push   $0x803c17
  8019ad:	e8 31 01 00 00       	call   801ae3 <_panic>
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
  8019d1:	68 e3 3c 80 00       	push   $0x803ce3
  8019d6:	68 fd 38 80 00       	push   $0x8038fd
  8019db:	6a 40                	push   $0x40
  8019dd:	68 17 3c 80 00       	push   $0x803c17
  8019e2:	e8 fc 00 00 00       	call   801ae3 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8019e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ea:	c1 e8 0c             	shr    $0xc,%eax
  8019ed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019f4:	a8 40                	test   $0x40,%al
  8019f6:	74 16                	je     801a0e <fs_test+0x3be>
  8019f8:	68 39 3d 80 00       	push   $0x803d39
  8019fd:	68 fd 38 80 00       	push   $0x8038fd
  801a02:	6a 41                	push   $0x41
  801a04:	68 17 3c 80 00       	push   $0x803c17
  801a09:	e8 d5 00 00 00       	call   801ae3 <_panic>
	cprintf("file rewrite is good\n");
  801a0e:	83 ec 0c             	sub    $0xc,%esp
  801a11:	68 93 3d 80 00       	push   $0x803d93
  801a16:	e8 a1 01 00 00       	call   801bbc <cprintf>
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
  801a36:	e8 cb 0a 00 00       	call   802506 <sys_getenvid>
  801a3b:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  801a3d:	83 ec 08             	sub    $0x8,%esp
  801a40:	50                   	push   %eax
  801a41:	68 38 3e 80 00       	push   $0x803e38
  801a46:	e8 71 01 00 00       	call   801bbc <cprintf>
  801a4b:	8b 3d 0c a0 80 00    	mov    0x80a00c,%edi
  801a51:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a56:	83 c4 10             	add    $0x10,%esp
  801a59:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  801a5e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  801a63:	89 c1                	mov    %eax,%ecx
  801a65:	c1 e1 07             	shl    $0x7,%ecx
  801a68:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  801a6f:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  801a72:	39 cb                	cmp    %ecx,%ebx
  801a74:	0f 44 fa             	cmove  %edx,%edi
  801a77:	b9 01 00 00 00       	mov    $0x1,%ecx
  801a7c:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  801a7f:	83 c0 01             	add    $0x1,%eax
  801a82:	81 c2 84 00 00 00    	add    $0x84,%edx
  801a88:	3d 00 04 00 00       	cmp    $0x400,%eax
  801a8d:	75 d4                	jne    801a63 <libmain+0x40>
  801a8f:	89 f0                	mov    %esi,%eax
  801a91:	84 c0                	test   %al,%al
  801a93:	74 06                	je     801a9b <libmain+0x78>
  801a95:	89 3d 0c a0 80 00    	mov    %edi,0x80a00c
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801a9b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  801a9f:	7e 0a                	jle    801aab <libmain+0x88>
		binaryname = argv[0];
  801aa1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa4:	8b 00                	mov    (%eax),%eax
  801aa6:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801aab:	83 ec 08             	sub    $0x8,%esp
  801aae:	ff 75 0c             	pushl  0xc(%ebp)
  801ab1:	ff 75 08             	pushl  0x8(%ebp)
  801ab4:	e8 51 fb ff ff       	call   80160a <umain>

	// exit gracefully
	exit();
  801ab9:	e8 0b 00 00 00       	call   801ac9 <exit>
}
  801abe:	83 c4 10             	add    $0x10,%esp
  801ac1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac4:	5b                   	pop    %ebx
  801ac5:	5e                   	pop    %esi
  801ac6:	5f                   	pop    %edi
  801ac7:	5d                   	pop    %ebp
  801ac8:	c3                   	ret    

00801ac9 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801ac9:	55                   	push   %ebp
  801aca:	89 e5                	mov    %esp,%ebp
  801acc:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801acf:	e8 f2 0f 00 00       	call   802ac6 <close_all>
	sys_env_destroy(0);
  801ad4:	83 ec 0c             	sub    $0xc,%esp
  801ad7:	6a 00                	push   $0x0
  801ad9:	e8 e7 09 00 00       	call   8024c5 <sys_env_destroy>
}
  801ade:	83 c4 10             	add    $0x10,%esp
  801ae1:	c9                   	leave  
  801ae2:	c3                   	ret    

00801ae3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ae3:	55                   	push   %ebp
  801ae4:	89 e5                	mov    %esp,%ebp
  801ae6:	56                   	push   %esi
  801ae7:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ae8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801aeb:	8b 35 60 90 80 00    	mov    0x809060,%esi
  801af1:	e8 10 0a 00 00       	call   802506 <sys_getenvid>
  801af6:	83 ec 0c             	sub    $0xc,%esp
  801af9:	ff 75 0c             	pushl  0xc(%ebp)
  801afc:	ff 75 08             	pushl  0x8(%ebp)
  801aff:	56                   	push   %esi
  801b00:	50                   	push   %eax
  801b01:	68 64 3e 80 00       	push   $0x803e64
  801b06:	e8 b1 00 00 00       	call   801bbc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b0b:	83 c4 18             	add    $0x18,%esp
  801b0e:	53                   	push   %ebx
  801b0f:	ff 75 10             	pushl  0x10(%ebp)
  801b12:	e8 54 00 00 00       	call   801b6b <vcprintf>
	cprintf("\n");
  801b17:	c7 04 24 3b 3a 80 00 	movl   $0x803a3b,(%esp)
  801b1e:	e8 99 00 00 00       	call   801bbc <cprintf>
  801b23:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b26:	cc                   	int3   
  801b27:	eb fd                	jmp    801b26 <_panic+0x43>

00801b29 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801b29:	55                   	push   %ebp
  801b2a:	89 e5                	mov    %esp,%ebp
  801b2c:	53                   	push   %ebx
  801b2d:	83 ec 04             	sub    $0x4,%esp
  801b30:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801b33:	8b 13                	mov    (%ebx),%edx
  801b35:	8d 42 01             	lea    0x1(%edx),%eax
  801b38:	89 03                	mov    %eax,(%ebx)
  801b3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b3d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801b41:	3d ff 00 00 00       	cmp    $0xff,%eax
  801b46:	75 1a                	jne    801b62 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801b48:	83 ec 08             	sub    $0x8,%esp
  801b4b:	68 ff 00 00 00       	push   $0xff
  801b50:	8d 43 08             	lea    0x8(%ebx),%eax
  801b53:	50                   	push   %eax
  801b54:	e8 2f 09 00 00       	call   802488 <sys_cputs>
		b->idx = 0;
  801b59:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b5f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801b62:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801b66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b69:	c9                   	leave  
  801b6a:	c3                   	ret    

00801b6b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801b6b:	55                   	push   %ebp
  801b6c:	89 e5                	mov    %esp,%ebp
  801b6e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801b74:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801b7b:	00 00 00 
	b.cnt = 0;
  801b7e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801b85:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801b88:	ff 75 0c             	pushl  0xc(%ebp)
  801b8b:	ff 75 08             	pushl  0x8(%ebp)
  801b8e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801b94:	50                   	push   %eax
  801b95:	68 29 1b 80 00       	push   $0x801b29
  801b9a:	e8 54 01 00 00       	call   801cf3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801b9f:	83 c4 08             	add    $0x8,%esp
  801ba2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801ba8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801bae:	50                   	push   %eax
  801baf:	e8 d4 08 00 00       	call   802488 <sys_cputs>

	return b.cnt;
}
  801bb4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801bba:	c9                   	leave  
  801bbb:	c3                   	ret    

00801bbc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801bbc:	55                   	push   %ebp
  801bbd:	89 e5                	mov    %esp,%ebp
  801bbf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801bc2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801bc5:	50                   	push   %eax
  801bc6:	ff 75 08             	pushl  0x8(%ebp)
  801bc9:	e8 9d ff ff ff       	call   801b6b <vcprintf>
	va_end(ap);

	return cnt;
}
  801bce:	c9                   	leave  
  801bcf:	c3                   	ret    

00801bd0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801bd0:	55                   	push   %ebp
  801bd1:	89 e5                	mov    %esp,%ebp
  801bd3:	57                   	push   %edi
  801bd4:	56                   	push   %esi
  801bd5:	53                   	push   %ebx
  801bd6:	83 ec 1c             	sub    $0x1c,%esp
  801bd9:	89 c7                	mov    %eax,%edi
  801bdb:	89 d6                	mov    %edx,%esi
  801bdd:	8b 45 08             	mov    0x8(%ebp),%eax
  801be0:	8b 55 0c             	mov    0xc(%ebp),%edx
  801be3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801be6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801be9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801bec:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bf1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801bf4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801bf7:	39 d3                	cmp    %edx,%ebx
  801bf9:	72 05                	jb     801c00 <printnum+0x30>
  801bfb:	39 45 10             	cmp    %eax,0x10(%ebp)
  801bfe:	77 45                	ja     801c45 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801c00:	83 ec 0c             	sub    $0xc,%esp
  801c03:	ff 75 18             	pushl  0x18(%ebp)
  801c06:	8b 45 14             	mov    0x14(%ebp),%eax
  801c09:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801c0c:	53                   	push   %ebx
  801c0d:	ff 75 10             	pushl  0x10(%ebp)
  801c10:	83 ec 08             	sub    $0x8,%esp
  801c13:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c16:	ff 75 e0             	pushl  -0x20(%ebp)
  801c19:	ff 75 dc             	pushl  -0x24(%ebp)
  801c1c:	ff 75 d8             	pushl  -0x28(%ebp)
  801c1f:	e8 fc 19 00 00       	call   803620 <__udivdi3>
  801c24:	83 c4 18             	add    $0x18,%esp
  801c27:	52                   	push   %edx
  801c28:	50                   	push   %eax
  801c29:	89 f2                	mov    %esi,%edx
  801c2b:	89 f8                	mov    %edi,%eax
  801c2d:	e8 9e ff ff ff       	call   801bd0 <printnum>
  801c32:	83 c4 20             	add    $0x20,%esp
  801c35:	eb 18                	jmp    801c4f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801c37:	83 ec 08             	sub    $0x8,%esp
  801c3a:	56                   	push   %esi
  801c3b:	ff 75 18             	pushl  0x18(%ebp)
  801c3e:	ff d7                	call   *%edi
  801c40:	83 c4 10             	add    $0x10,%esp
  801c43:	eb 03                	jmp    801c48 <printnum+0x78>
  801c45:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801c48:	83 eb 01             	sub    $0x1,%ebx
  801c4b:	85 db                	test   %ebx,%ebx
  801c4d:	7f e8                	jg     801c37 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801c4f:	83 ec 08             	sub    $0x8,%esp
  801c52:	56                   	push   %esi
  801c53:	83 ec 04             	sub    $0x4,%esp
  801c56:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c59:	ff 75 e0             	pushl  -0x20(%ebp)
  801c5c:	ff 75 dc             	pushl  -0x24(%ebp)
  801c5f:	ff 75 d8             	pushl  -0x28(%ebp)
  801c62:	e8 e9 1a 00 00       	call   803750 <__umoddi3>
  801c67:	83 c4 14             	add    $0x14,%esp
  801c6a:	0f be 80 87 3e 80 00 	movsbl 0x803e87(%eax),%eax
  801c71:	50                   	push   %eax
  801c72:	ff d7                	call   *%edi
}
  801c74:	83 c4 10             	add    $0x10,%esp
  801c77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c7a:	5b                   	pop    %ebx
  801c7b:	5e                   	pop    %esi
  801c7c:	5f                   	pop    %edi
  801c7d:	5d                   	pop    %ebp
  801c7e:	c3                   	ret    

00801c7f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801c7f:	55                   	push   %ebp
  801c80:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801c82:	83 fa 01             	cmp    $0x1,%edx
  801c85:	7e 0e                	jle    801c95 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801c87:	8b 10                	mov    (%eax),%edx
  801c89:	8d 4a 08             	lea    0x8(%edx),%ecx
  801c8c:	89 08                	mov    %ecx,(%eax)
  801c8e:	8b 02                	mov    (%edx),%eax
  801c90:	8b 52 04             	mov    0x4(%edx),%edx
  801c93:	eb 22                	jmp    801cb7 <getuint+0x38>
	else if (lflag)
  801c95:	85 d2                	test   %edx,%edx
  801c97:	74 10                	je     801ca9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801c99:	8b 10                	mov    (%eax),%edx
  801c9b:	8d 4a 04             	lea    0x4(%edx),%ecx
  801c9e:	89 08                	mov    %ecx,(%eax)
  801ca0:	8b 02                	mov    (%edx),%eax
  801ca2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ca7:	eb 0e                	jmp    801cb7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801ca9:	8b 10                	mov    (%eax),%edx
  801cab:	8d 4a 04             	lea    0x4(%edx),%ecx
  801cae:	89 08                	mov    %ecx,(%eax)
  801cb0:	8b 02                	mov    (%edx),%eax
  801cb2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801cb7:	5d                   	pop    %ebp
  801cb8:	c3                   	ret    

00801cb9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801cb9:	55                   	push   %ebp
  801cba:	89 e5                	mov    %esp,%ebp
  801cbc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801cbf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801cc3:	8b 10                	mov    (%eax),%edx
  801cc5:	3b 50 04             	cmp    0x4(%eax),%edx
  801cc8:	73 0a                	jae    801cd4 <sprintputch+0x1b>
		*b->buf++ = ch;
  801cca:	8d 4a 01             	lea    0x1(%edx),%ecx
  801ccd:	89 08                	mov    %ecx,(%eax)
  801ccf:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd2:	88 02                	mov    %al,(%edx)
}
  801cd4:	5d                   	pop    %ebp
  801cd5:	c3                   	ret    

00801cd6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801cd6:	55                   	push   %ebp
  801cd7:	89 e5                	mov    %esp,%ebp
  801cd9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801cdc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801cdf:	50                   	push   %eax
  801ce0:	ff 75 10             	pushl  0x10(%ebp)
  801ce3:	ff 75 0c             	pushl  0xc(%ebp)
  801ce6:	ff 75 08             	pushl  0x8(%ebp)
  801ce9:	e8 05 00 00 00       	call   801cf3 <vprintfmt>
	va_end(ap);
}
  801cee:	83 c4 10             	add    $0x10,%esp
  801cf1:	c9                   	leave  
  801cf2:	c3                   	ret    

00801cf3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801cf3:	55                   	push   %ebp
  801cf4:	89 e5                	mov    %esp,%ebp
  801cf6:	57                   	push   %edi
  801cf7:	56                   	push   %esi
  801cf8:	53                   	push   %ebx
  801cf9:	83 ec 2c             	sub    $0x2c,%esp
  801cfc:	8b 75 08             	mov    0x8(%ebp),%esi
  801cff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d02:	8b 7d 10             	mov    0x10(%ebp),%edi
  801d05:	eb 12                	jmp    801d19 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801d07:	85 c0                	test   %eax,%eax
  801d09:	0f 84 89 03 00 00    	je     802098 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801d0f:	83 ec 08             	sub    $0x8,%esp
  801d12:	53                   	push   %ebx
  801d13:	50                   	push   %eax
  801d14:	ff d6                	call   *%esi
  801d16:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801d19:	83 c7 01             	add    $0x1,%edi
  801d1c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801d20:	83 f8 25             	cmp    $0x25,%eax
  801d23:	75 e2                	jne    801d07 <vprintfmt+0x14>
  801d25:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801d29:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801d30:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801d37:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801d3e:	ba 00 00 00 00       	mov    $0x0,%edx
  801d43:	eb 07                	jmp    801d4c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d45:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801d48:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d4c:	8d 47 01             	lea    0x1(%edi),%eax
  801d4f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d52:	0f b6 07             	movzbl (%edi),%eax
  801d55:	0f b6 c8             	movzbl %al,%ecx
  801d58:	83 e8 23             	sub    $0x23,%eax
  801d5b:	3c 55                	cmp    $0x55,%al
  801d5d:	0f 87 1a 03 00 00    	ja     80207d <vprintfmt+0x38a>
  801d63:	0f b6 c0             	movzbl %al,%eax
  801d66:	ff 24 85 c0 3f 80 00 	jmp    *0x803fc0(,%eax,4)
  801d6d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801d70:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801d74:	eb d6                	jmp    801d4c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d76:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d79:	b8 00 00 00 00       	mov    $0x0,%eax
  801d7e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801d81:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801d84:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801d88:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801d8b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801d8e:	83 fa 09             	cmp    $0x9,%edx
  801d91:	77 39                	ja     801dcc <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801d93:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801d96:	eb e9                	jmp    801d81 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801d98:	8b 45 14             	mov    0x14(%ebp),%eax
  801d9b:	8d 48 04             	lea    0x4(%eax),%ecx
  801d9e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801da1:	8b 00                	mov    (%eax),%eax
  801da3:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801da6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801da9:	eb 27                	jmp    801dd2 <vprintfmt+0xdf>
  801dab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801dae:	85 c0                	test   %eax,%eax
  801db0:	b9 00 00 00 00       	mov    $0x0,%ecx
  801db5:	0f 49 c8             	cmovns %eax,%ecx
  801db8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801dbb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801dbe:	eb 8c                	jmp    801d4c <vprintfmt+0x59>
  801dc0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801dc3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801dca:	eb 80                	jmp    801d4c <vprintfmt+0x59>
  801dcc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801dcf:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801dd2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801dd6:	0f 89 70 ff ff ff    	jns    801d4c <vprintfmt+0x59>
				width = precision, precision = -1;
  801ddc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801ddf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801de2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801de9:	e9 5e ff ff ff       	jmp    801d4c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801dee:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801df1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801df4:	e9 53 ff ff ff       	jmp    801d4c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801df9:	8b 45 14             	mov    0x14(%ebp),%eax
  801dfc:	8d 50 04             	lea    0x4(%eax),%edx
  801dff:	89 55 14             	mov    %edx,0x14(%ebp)
  801e02:	83 ec 08             	sub    $0x8,%esp
  801e05:	53                   	push   %ebx
  801e06:	ff 30                	pushl  (%eax)
  801e08:	ff d6                	call   *%esi
			break;
  801e0a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e0d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801e10:	e9 04 ff ff ff       	jmp    801d19 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801e15:	8b 45 14             	mov    0x14(%ebp),%eax
  801e18:	8d 50 04             	lea    0x4(%eax),%edx
  801e1b:	89 55 14             	mov    %edx,0x14(%ebp)
  801e1e:	8b 00                	mov    (%eax),%eax
  801e20:	99                   	cltd   
  801e21:	31 d0                	xor    %edx,%eax
  801e23:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801e25:	83 f8 0f             	cmp    $0xf,%eax
  801e28:	7f 0b                	jg     801e35 <vprintfmt+0x142>
  801e2a:	8b 14 85 20 41 80 00 	mov    0x804120(,%eax,4),%edx
  801e31:	85 d2                	test   %edx,%edx
  801e33:	75 18                	jne    801e4d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801e35:	50                   	push   %eax
  801e36:	68 9f 3e 80 00       	push   $0x803e9f
  801e3b:	53                   	push   %ebx
  801e3c:	56                   	push   %esi
  801e3d:	e8 94 fe ff ff       	call   801cd6 <printfmt>
  801e42:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e45:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801e48:	e9 cc fe ff ff       	jmp    801d19 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801e4d:	52                   	push   %edx
  801e4e:	68 0f 39 80 00       	push   $0x80390f
  801e53:	53                   	push   %ebx
  801e54:	56                   	push   %esi
  801e55:	e8 7c fe ff ff       	call   801cd6 <printfmt>
  801e5a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e5d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e60:	e9 b4 fe ff ff       	jmp    801d19 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801e65:	8b 45 14             	mov    0x14(%ebp),%eax
  801e68:	8d 50 04             	lea    0x4(%eax),%edx
  801e6b:	89 55 14             	mov    %edx,0x14(%ebp)
  801e6e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801e70:	85 ff                	test   %edi,%edi
  801e72:	b8 98 3e 80 00       	mov    $0x803e98,%eax
  801e77:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801e7a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801e7e:	0f 8e 94 00 00 00    	jle    801f18 <vprintfmt+0x225>
  801e84:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801e88:	0f 84 98 00 00 00    	je     801f26 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801e8e:	83 ec 08             	sub    $0x8,%esp
  801e91:	ff 75 d0             	pushl  -0x30(%ebp)
  801e94:	57                   	push   %edi
  801e95:	e8 86 02 00 00       	call   802120 <strnlen>
  801e9a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801e9d:	29 c1                	sub    %eax,%ecx
  801e9f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801ea2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801ea5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801ea9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801eac:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801eaf:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801eb1:	eb 0f                	jmp    801ec2 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801eb3:	83 ec 08             	sub    $0x8,%esp
  801eb6:	53                   	push   %ebx
  801eb7:	ff 75 e0             	pushl  -0x20(%ebp)
  801eba:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801ebc:	83 ef 01             	sub    $0x1,%edi
  801ebf:	83 c4 10             	add    $0x10,%esp
  801ec2:	85 ff                	test   %edi,%edi
  801ec4:	7f ed                	jg     801eb3 <vprintfmt+0x1c0>
  801ec6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801ec9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801ecc:	85 c9                	test   %ecx,%ecx
  801ece:	b8 00 00 00 00       	mov    $0x0,%eax
  801ed3:	0f 49 c1             	cmovns %ecx,%eax
  801ed6:	29 c1                	sub    %eax,%ecx
  801ed8:	89 75 08             	mov    %esi,0x8(%ebp)
  801edb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801ede:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801ee1:	89 cb                	mov    %ecx,%ebx
  801ee3:	eb 4d                	jmp    801f32 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801ee5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801ee9:	74 1b                	je     801f06 <vprintfmt+0x213>
  801eeb:	0f be c0             	movsbl %al,%eax
  801eee:	83 e8 20             	sub    $0x20,%eax
  801ef1:	83 f8 5e             	cmp    $0x5e,%eax
  801ef4:	76 10                	jbe    801f06 <vprintfmt+0x213>
					putch('?', putdat);
  801ef6:	83 ec 08             	sub    $0x8,%esp
  801ef9:	ff 75 0c             	pushl  0xc(%ebp)
  801efc:	6a 3f                	push   $0x3f
  801efe:	ff 55 08             	call   *0x8(%ebp)
  801f01:	83 c4 10             	add    $0x10,%esp
  801f04:	eb 0d                	jmp    801f13 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801f06:	83 ec 08             	sub    $0x8,%esp
  801f09:	ff 75 0c             	pushl  0xc(%ebp)
  801f0c:	52                   	push   %edx
  801f0d:	ff 55 08             	call   *0x8(%ebp)
  801f10:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801f13:	83 eb 01             	sub    $0x1,%ebx
  801f16:	eb 1a                	jmp    801f32 <vprintfmt+0x23f>
  801f18:	89 75 08             	mov    %esi,0x8(%ebp)
  801f1b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801f1e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801f21:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801f24:	eb 0c                	jmp    801f32 <vprintfmt+0x23f>
  801f26:	89 75 08             	mov    %esi,0x8(%ebp)
  801f29:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801f2c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801f2f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801f32:	83 c7 01             	add    $0x1,%edi
  801f35:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801f39:	0f be d0             	movsbl %al,%edx
  801f3c:	85 d2                	test   %edx,%edx
  801f3e:	74 23                	je     801f63 <vprintfmt+0x270>
  801f40:	85 f6                	test   %esi,%esi
  801f42:	78 a1                	js     801ee5 <vprintfmt+0x1f2>
  801f44:	83 ee 01             	sub    $0x1,%esi
  801f47:	79 9c                	jns    801ee5 <vprintfmt+0x1f2>
  801f49:	89 df                	mov    %ebx,%edi
  801f4b:	8b 75 08             	mov    0x8(%ebp),%esi
  801f4e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801f51:	eb 18                	jmp    801f6b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801f53:	83 ec 08             	sub    $0x8,%esp
  801f56:	53                   	push   %ebx
  801f57:	6a 20                	push   $0x20
  801f59:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801f5b:	83 ef 01             	sub    $0x1,%edi
  801f5e:	83 c4 10             	add    $0x10,%esp
  801f61:	eb 08                	jmp    801f6b <vprintfmt+0x278>
  801f63:	89 df                	mov    %ebx,%edi
  801f65:	8b 75 08             	mov    0x8(%ebp),%esi
  801f68:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801f6b:	85 ff                	test   %edi,%edi
  801f6d:	7f e4                	jg     801f53 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f6f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801f72:	e9 a2 fd ff ff       	jmp    801d19 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801f77:	83 fa 01             	cmp    $0x1,%edx
  801f7a:	7e 16                	jle    801f92 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801f7c:	8b 45 14             	mov    0x14(%ebp),%eax
  801f7f:	8d 50 08             	lea    0x8(%eax),%edx
  801f82:	89 55 14             	mov    %edx,0x14(%ebp)
  801f85:	8b 50 04             	mov    0x4(%eax),%edx
  801f88:	8b 00                	mov    (%eax),%eax
  801f8a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f8d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801f90:	eb 32                	jmp    801fc4 <vprintfmt+0x2d1>
	else if (lflag)
  801f92:	85 d2                	test   %edx,%edx
  801f94:	74 18                	je     801fae <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801f96:	8b 45 14             	mov    0x14(%ebp),%eax
  801f99:	8d 50 04             	lea    0x4(%eax),%edx
  801f9c:	89 55 14             	mov    %edx,0x14(%ebp)
  801f9f:	8b 00                	mov    (%eax),%eax
  801fa1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801fa4:	89 c1                	mov    %eax,%ecx
  801fa6:	c1 f9 1f             	sar    $0x1f,%ecx
  801fa9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801fac:	eb 16                	jmp    801fc4 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801fae:	8b 45 14             	mov    0x14(%ebp),%eax
  801fb1:	8d 50 04             	lea    0x4(%eax),%edx
  801fb4:	89 55 14             	mov    %edx,0x14(%ebp)
  801fb7:	8b 00                	mov    (%eax),%eax
  801fb9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801fbc:	89 c1                	mov    %eax,%ecx
  801fbe:	c1 f9 1f             	sar    $0x1f,%ecx
  801fc1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801fc4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801fc7:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801fca:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801fcf:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801fd3:	79 74                	jns    802049 <vprintfmt+0x356>
				putch('-', putdat);
  801fd5:	83 ec 08             	sub    $0x8,%esp
  801fd8:	53                   	push   %ebx
  801fd9:	6a 2d                	push   $0x2d
  801fdb:	ff d6                	call   *%esi
				num = -(long long) num;
  801fdd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801fe0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801fe3:	f7 d8                	neg    %eax
  801fe5:	83 d2 00             	adc    $0x0,%edx
  801fe8:	f7 da                	neg    %edx
  801fea:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801fed:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801ff2:	eb 55                	jmp    802049 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801ff4:	8d 45 14             	lea    0x14(%ebp),%eax
  801ff7:	e8 83 fc ff ff       	call   801c7f <getuint>
			base = 10;
  801ffc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  802001:	eb 46                	jmp    802049 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  802003:	8d 45 14             	lea    0x14(%ebp),%eax
  802006:	e8 74 fc ff ff       	call   801c7f <getuint>
			base = 8;
  80200b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  802010:	eb 37                	jmp    802049 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  802012:	83 ec 08             	sub    $0x8,%esp
  802015:	53                   	push   %ebx
  802016:	6a 30                	push   $0x30
  802018:	ff d6                	call   *%esi
			putch('x', putdat);
  80201a:	83 c4 08             	add    $0x8,%esp
  80201d:	53                   	push   %ebx
  80201e:	6a 78                	push   $0x78
  802020:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  802022:	8b 45 14             	mov    0x14(%ebp),%eax
  802025:	8d 50 04             	lea    0x4(%eax),%edx
  802028:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80202b:	8b 00                	mov    (%eax),%eax
  80202d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  802032:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  802035:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80203a:	eb 0d                	jmp    802049 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80203c:	8d 45 14             	lea    0x14(%ebp),%eax
  80203f:	e8 3b fc ff ff       	call   801c7f <getuint>
			base = 16;
  802044:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  802049:	83 ec 0c             	sub    $0xc,%esp
  80204c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  802050:	57                   	push   %edi
  802051:	ff 75 e0             	pushl  -0x20(%ebp)
  802054:	51                   	push   %ecx
  802055:	52                   	push   %edx
  802056:	50                   	push   %eax
  802057:	89 da                	mov    %ebx,%edx
  802059:	89 f0                	mov    %esi,%eax
  80205b:	e8 70 fb ff ff       	call   801bd0 <printnum>
			break;
  802060:	83 c4 20             	add    $0x20,%esp
  802063:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  802066:	e9 ae fc ff ff       	jmp    801d19 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80206b:	83 ec 08             	sub    $0x8,%esp
  80206e:	53                   	push   %ebx
  80206f:	51                   	push   %ecx
  802070:	ff d6                	call   *%esi
			break;
  802072:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  802075:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  802078:	e9 9c fc ff ff       	jmp    801d19 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80207d:	83 ec 08             	sub    $0x8,%esp
  802080:	53                   	push   %ebx
  802081:	6a 25                	push   $0x25
  802083:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  802085:	83 c4 10             	add    $0x10,%esp
  802088:	eb 03                	jmp    80208d <vprintfmt+0x39a>
  80208a:	83 ef 01             	sub    $0x1,%edi
  80208d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  802091:	75 f7                	jne    80208a <vprintfmt+0x397>
  802093:	e9 81 fc ff ff       	jmp    801d19 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  802098:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80209b:	5b                   	pop    %ebx
  80209c:	5e                   	pop    %esi
  80209d:	5f                   	pop    %edi
  80209e:	5d                   	pop    %ebp
  80209f:	c3                   	ret    

008020a0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8020a0:	55                   	push   %ebp
  8020a1:	89 e5                	mov    %esp,%ebp
  8020a3:	83 ec 18             	sub    $0x18,%esp
  8020a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8020ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8020af:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8020b3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8020b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8020bd:	85 c0                	test   %eax,%eax
  8020bf:	74 26                	je     8020e7 <vsnprintf+0x47>
  8020c1:	85 d2                	test   %edx,%edx
  8020c3:	7e 22                	jle    8020e7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8020c5:	ff 75 14             	pushl  0x14(%ebp)
  8020c8:	ff 75 10             	pushl  0x10(%ebp)
  8020cb:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8020ce:	50                   	push   %eax
  8020cf:	68 b9 1c 80 00       	push   $0x801cb9
  8020d4:	e8 1a fc ff ff       	call   801cf3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8020d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8020dc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8020df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e2:	83 c4 10             	add    $0x10,%esp
  8020e5:	eb 05                	jmp    8020ec <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8020e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8020ec:	c9                   	leave  
  8020ed:	c3                   	ret    

008020ee <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8020ee:	55                   	push   %ebp
  8020ef:	89 e5                	mov    %esp,%ebp
  8020f1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8020f4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8020f7:	50                   	push   %eax
  8020f8:	ff 75 10             	pushl  0x10(%ebp)
  8020fb:	ff 75 0c             	pushl  0xc(%ebp)
  8020fe:	ff 75 08             	pushl  0x8(%ebp)
  802101:	e8 9a ff ff ff       	call   8020a0 <vsnprintf>
	va_end(ap);

	return rc;
}
  802106:	c9                   	leave  
  802107:	c3                   	ret    

00802108 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  802108:	55                   	push   %ebp
  802109:	89 e5                	mov    %esp,%ebp
  80210b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80210e:	b8 00 00 00 00       	mov    $0x0,%eax
  802113:	eb 03                	jmp    802118 <strlen+0x10>
		n++;
  802115:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  802118:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80211c:	75 f7                	jne    802115 <strlen+0xd>
		n++;
	return n;
}
  80211e:	5d                   	pop    %ebp
  80211f:	c3                   	ret    

00802120 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  802120:	55                   	push   %ebp
  802121:	89 e5                	mov    %esp,%ebp
  802123:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802126:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802129:	ba 00 00 00 00       	mov    $0x0,%edx
  80212e:	eb 03                	jmp    802133 <strnlen+0x13>
		n++;
  802130:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802133:	39 c2                	cmp    %eax,%edx
  802135:	74 08                	je     80213f <strnlen+0x1f>
  802137:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80213b:	75 f3                	jne    802130 <strnlen+0x10>
  80213d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80213f:	5d                   	pop    %ebp
  802140:	c3                   	ret    

00802141 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  802141:	55                   	push   %ebp
  802142:	89 e5                	mov    %esp,%ebp
  802144:	53                   	push   %ebx
  802145:	8b 45 08             	mov    0x8(%ebp),%eax
  802148:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80214b:	89 c2                	mov    %eax,%edx
  80214d:	83 c2 01             	add    $0x1,%edx
  802150:	83 c1 01             	add    $0x1,%ecx
  802153:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  802157:	88 5a ff             	mov    %bl,-0x1(%edx)
  80215a:	84 db                	test   %bl,%bl
  80215c:	75 ef                	jne    80214d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80215e:	5b                   	pop    %ebx
  80215f:	5d                   	pop    %ebp
  802160:	c3                   	ret    

00802161 <strcat>:

char *
strcat(char *dst, const char *src)
{
  802161:	55                   	push   %ebp
  802162:	89 e5                	mov    %esp,%ebp
  802164:	53                   	push   %ebx
  802165:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  802168:	53                   	push   %ebx
  802169:	e8 9a ff ff ff       	call   802108 <strlen>
  80216e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  802171:	ff 75 0c             	pushl  0xc(%ebp)
  802174:	01 d8                	add    %ebx,%eax
  802176:	50                   	push   %eax
  802177:	e8 c5 ff ff ff       	call   802141 <strcpy>
	return dst;
}
  80217c:	89 d8                	mov    %ebx,%eax
  80217e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802181:	c9                   	leave  
  802182:	c3                   	ret    

00802183 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  802183:	55                   	push   %ebp
  802184:	89 e5                	mov    %esp,%ebp
  802186:	56                   	push   %esi
  802187:	53                   	push   %ebx
  802188:	8b 75 08             	mov    0x8(%ebp),%esi
  80218b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80218e:	89 f3                	mov    %esi,%ebx
  802190:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802193:	89 f2                	mov    %esi,%edx
  802195:	eb 0f                	jmp    8021a6 <strncpy+0x23>
		*dst++ = *src;
  802197:	83 c2 01             	add    $0x1,%edx
  80219a:	0f b6 01             	movzbl (%ecx),%eax
  80219d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8021a0:	80 39 01             	cmpb   $0x1,(%ecx)
  8021a3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8021a6:	39 da                	cmp    %ebx,%edx
  8021a8:	75 ed                	jne    802197 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8021aa:	89 f0                	mov    %esi,%eax
  8021ac:	5b                   	pop    %ebx
  8021ad:	5e                   	pop    %esi
  8021ae:	5d                   	pop    %ebp
  8021af:	c3                   	ret    

008021b0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8021b0:	55                   	push   %ebp
  8021b1:	89 e5                	mov    %esp,%ebp
  8021b3:	56                   	push   %esi
  8021b4:	53                   	push   %ebx
  8021b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8021b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021bb:	8b 55 10             	mov    0x10(%ebp),%edx
  8021be:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8021c0:	85 d2                	test   %edx,%edx
  8021c2:	74 21                	je     8021e5 <strlcpy+0x35>
  8021c4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8021c8:	89 f2                	mov    %esi,%edx
  8021ca:	eb 09                	jmp    8021d5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8021cc:	83 c2 01             	add    $0x1,%edx
  8021cf:	83 c1 01             	add    $0x1,%ecx
  8021d2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8021d5:	39 c2                	cmp    %eax,%edx
  8021d7:	74 09                	je     8021e2 <strlcpy+0x32>
  8021d9:	0f b6 19             	movzbl (%ecx),%ebx
  8021dc:	84 db                	test   %bl,%bl
  8021de:	75 ec                	jne    8021cc <strlcpy+0x1c>
  8021e0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8021e2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8021e5:	29 f0                	sub    %esi,%eax
}
  8021e7:	5b                   	pop    %ebx
  8021e8:	5e                   	pop    %esi
  8021e9:	5d                   	pop    %ebp
  8021ea:	c3                   	ret    

008021eb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8021eb:	55                   	push   %ebp
  8021ec:	89 e5                	mov    %esp,%ebp
  8021ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021f1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8021f4:	eb 06                	jmp    8021fc <strcmp+0x11>
		p++, q++;
  8021f6:	83 c1 01             	add    $0x1,%ecx
  8021f9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8021fc:	0f b6 01             	movzbl (%ecx),%eax
  8021ff:	84 c0                	test   %al,%al
  802201:	74 04                	je     802207 <strcmp+0x1c>
  802203:	3a 02                	cmp    (%edx),%al
  802205:	74 ef                	je     8021f6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  802207:	0f b6 c0             	movzbl %al,%eax
  80220a:	0f b6 12             	movzbl (%edx),%edx
  80220d:	29 d0                	sub    %edx,%eax
}
  80220f:	5d                   	pop    %ebp
  802210:	c3                   	ret    

00802211 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  802211:	55                   	push   %ebp
  802212:	89 e5                	mov    %esp,%ebp
  802214:	53                   	push   %ebx
  802215:	8b 45 08             	mov    0x8(%ebp),%eax
  802218:	8b 55 0c             	mov    0xc(%ebp),%edx
  80221b:	89 c3                	mov    %eax,%ebx
  80221d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  802220:	eb 06                	jmp    802228 <strncmp+0x17>
		n--, p++, q++;
  802222:	83 c0 01             	add    $0x1,%eax
  802225:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  802228:	39 d8                	cmp    %ebx,%eax
  80222a:	74 15                	je     802241 <strncmp+0x30>
  80222c:	0f b6 08             	movzbl (%eax),%ecx
  80222f:	84 c9                	test   %cl,%cl
  802231:	74 04                	je     802237 <strncmp+0x26>
  802233:	3a 0a                	cmp    (%edx),%cl
  802235:	74 eb                	je     802222 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  802237:	0f b6 00             	movzbl (%eax),%eax
  80223a:	0f b6 12             	movzbl (%edx),%edx
  80223d:	29 d0                	sub    %edx,%eax
  80223f:	eb 05                	jmp    802246 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  802241:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  802246:	5b                   	pop    %ebx
  802247:	5d                   	pop    %ebp
  802248:	c3                   	ret    

00802249 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  802249:	55                   	push   %ebp
  80224a:	89 e5                	mov    %esp,%ebp
  80224c:	8b 45 08             	mov    0x8(%ebp),%eax
  80224f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802253:	eb 07                	jmp    80225c <strchr+0x13>
		if (*s == c)
  802255:	38 ca                	cmp    %cl,%dl
  802257:	74 0f                	je     802268 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  802259:	83 c0 01             	add    $0x1,%eax
  80225c:	0f b6 10             	movzbl (%eax),%edx
  80225f:	84 d2                	test   %dl,%dl
  802261:	75 f2                	jne    802255 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  802263:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802268:	5d                   	pop    %ebp
  802269:	c3                   	ret    

0080226a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80226a:	55                   	push   %ebp
  80226b:	89 e5                	mov    %esp,%ebp
  80226d:	8b 45 08             	mov    0x8(%ebp),%eax
  802270:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802274:	eb 03                	jmp    802279 <strfind+0xf>
  802276:	83 c0 01             	add    $0x1,%eax
  802279:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80227c:	38 ca                	cmp    %cl,%dl
  80227e:	74 04                	je     802284 <strfind+0x1a>
  802280:	84 d2                	test   %dl,%dl
  802282:	75 f2                	jne    802276 <strfind+0xc>
			break;
	return (char *) s;
}
  802284:	5d                   	pop    %ebp
  802285:	c3                   	ret    

00802286 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  802286:	55                   	push   %ebp
  802287:	89 e5                	mov    %esp,%ebp
  802289:	57                   	push   %edi
  80228a:	56                   	push   %esi
  80228b:	53                   	push   %ebx
  80228c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80228f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  802292:	85 c9                	test   %ecx,%ecx
  802294:	74 36                	je     8022cc <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  802296:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80229c:	75 28                	jne    8022c6 <memset+0x40>
  80229e:	f6 c1 03             	test   $0x3,%cl
  8022a1:	75 23                	jne    8022c6 <memset+0x40>
		c &= 0xFF;
  8022a3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8022a7:	89 d3                	mov    %edx,%ebx
  8022a9:	c1 e3 08             	shl    $0x8,%ebx
  8022ac:	89 d6                	mov    %edx,%esi
  8022ae:	c1 e6 18             	shl    $0x18,%esi
  8022b1:	89 d0                	mov    %edx,%eax
  8022b3:	c1 e0 10             	shl    $0x10,%eax
  8022b6:	09 f0                	or     %esi,%eax
  8022b8:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8022ba:	89 d8                	mov    %ebx,%eax
  8022bc:	09 d0                	or     %edx,%eax
  8022be:	c1 e9 02             	shr    $0x2,%ecx
  8022c1:	fc                   	cld    
  8022c2:	f3 ab                	rep stos %eax,%es:(%edi)
  8022c4:	eb 06                	jmp    8022cc <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8022c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022c9:	fc                   	cld    
  8022ca:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8022cc:	89 f8                	mov    %edi,%eax
  8022ce:	5b                   	pop    %ebx
  8022cf:	5e                   	pop    %esi
  8022d0:	5f                   	pop    %edi
  8022d1:	5d                   	pop    %ebp
  8022d2:	c3                   	ret    

008022d3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8022d3:	55                   	push   %ebp
  8022d4:	89 e5                	mov    %esp,%ebp
  8022d6:	57                   	push   %edi
  8022d7:	56                   	push   %esi
  8022d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022db:	8b 75 0c             	mov    0xc(%ebp),%esi
  8022de:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8022e1:	39 c6                	cmp    %eax,%esi
  8022e3:	73 35                	jae    80231a <memmove+0x47>
  8022e5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8022e8:	39 d0                	cmp    %edx,%eax
  8022ea:	73 2e                	jae    80231a <memmove+0x47>
		s += n;
		d += n;
  8022ec:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8022ef:	89 d6                	mov    %edx,%esi
  8022f1:	09 fe                	or     %edi,%esi
  8022f3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8022f9:	75 13                	jne    80230e <memmove+0x3b>
  8022fb:	f6 c1 03             	test   $0x3,%cl
  8022fe:	75 0e                	jne    80230e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  802300:	83 ef 04             	sub    $0x4,%edi
  802303:	8d 72 fc             	lea    -0x4(%edx),%esi
  802306:	c1 e9 02             	shr    $0x2,%ecx
  802309:	fd                   	std    
  80230a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80230c:	eb 09                	jmp    802317 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80230e:	83 ef 01             	sub    $0x1,%edi
  802311:	8d 72 ff             	lea    -0x1(%edx),%esi
  802314:	fd                   	std    
  802315:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  802317:	fc                   	cld    
  802318:	eb 1d                	jmp    802337 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80231a:	89 f2                	mov    %esi,%edx
  80231c:	09 c2                	or     %eax,%edx
  80231e:	f6 c2 03             	test   $0x3,%dl
  802321:	75 0f                	jne    802332 <memmove+0x5f>
  802323:	f6 c1 03             	test   $0x3,%cl
  802326:	75 0a                	jne    802332 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  802328:	c1 e9 02             	shr    $0x2,%ecx
  80232b:	89 c7                	mov    %eax,%edi
  80232d:	fc                   	cld    
  80232e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802330:	eb 05                	jmp    802337 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  802332:	89 c7                	mov    %eax,%edi
  802334:	fc                   	cld    
  802335:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  802337:	5e                   	pop    %esi
  802338:	5f                   	pop    %edi
  802339:	5d                   	pop    %ebp
  80233a:	c3                   	ret    

0080233b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80233b:	55                   	push   %ebp
  80233c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80233e:	ff 75 10             	pushl  0x10(%ebp)
  802341:	ff 75 0c             	pushl  0xc(%ebp)
  802344:	ff 75 08             	pushl  0x8(%ebp)
  802347:	e8 87 ff ff ff       	call   8022d3 <memmove>
}
  80234c:	c9                   	leave  
  80234d:	c3                   	ret    

0080234e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80234e:	55                   	push   %ebp
  80234f:	89 e5                	mov    %esp,%ebp
  802351:	56                   	push   %esi
  802352:	53                   	push   %ebx
  802353:	8b 45 08             	mov    0x8(%ebp),%eax
  802356:	8b 55 0c             	mov    0xc(%ebp),%edx
  802359:	89 c6                	mov    %eax,%esi
  80235b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80235e:	eb 1a                	jmp    80237a <memcmp+0x2c>
		if (*s1 != *s2)
  802360:	0f b6 08             	movzbl (%eax),%ecx
  802363:	0f b6 1a             	movzbl (%edx),%ebx
  802366:	38 d9                	cmp    %bl,%cl
  802368:	74 0a                	je     802374 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80236a:	0f b6 c1             	movzbl %cl,%eax
  80236d:	0f b6 db             	movzbl %bl,%ebx
  802370:	29 d8                	sub    %ebx,%eax
  802372:	eb 0f                	jmp    802383 <memcmp+0x35>
		s1++, s2++;
  802374:	83 c0 01             	add    $0x1,%eax
  802377:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80237a:	39 f0                	cmp    %esi,%eax
  80237c:	75 e2                	jne    802360 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80237e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802383:	5b                   	pop    %ebx
  802384:	5e                   	pop    %esi
  802385:	5d                   	pop    %ebp
  802386:	c3                   	ret    

00802387 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  802387:	55                   	push   %ebp
  802388:	89 e5                	mov    %esp,%ebp
  80238a:	53                   	push   %ebx
  80238b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80238e:	89 c1                	mov    %eax,%ecx
  802390:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  802393:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802397:	eb 0a                	jmp    8023a3 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  802399:	0f b6 10             	movzbl (%eax),%edx
  80239c:	39 da                	cmp    %ebx,%edx
  80239e:	74 07                	je     8023a7 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8023a0:	83 c0 01             	add    $0x1,%eax
  8023a3:	39 c8                	cmp    %ecx,%eax
  8023a5:	72 f2                	jb     802399 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8023a7:	5b                   	pop    %ebx
  8023a8:	5d                   	pop    %ebp
  8023a9:	c3                   	ret    

008023aa <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8023aa:	55                   	push   %ebp
  8023ab:	89 e5                	mov    %esp,%ebp
  8023ad:	57                   	push   %edi
  8023ae:	56                   	push   %esi
  8023af:	53                   	push   %ebx
  8023b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8023b6:	eb 03                	jmp    8023bb <strtol+0x11>
		s++;
  8023b8:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8023bb:	0f b6 01             	movzbl (%ecx),%eax
  8023be:	3c 20                	cmp    $0x20,%al
  8023c0:	74 f6                	je     8023b8 <strtol+0xe>
  8023c2:	3c 09                	cmp    $0x9,%al
  8023c4:	74 f2                	je     8023b8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8023c6:	3c 2b                	cmp    $0x2b,%al
  8023c8:	75 0a                	jne    8023d4 <strtol+0x2a>
		s++;
  8023ca:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8023cd:	bf 00 00 00 00       	mov    $0x0,%edi
  8023d2:	eb 11                	jmp    8023e5 <strtol+0x3b>
  8023d4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8023d9:	3c 2d                	cmp    $0x2d,%al
  8023db:	75 08                	jne    8023e5 <strtol+0x3b>
		s++, neg = 1;
  8023dd:	83 c1 01             	add    $0x1,%ecx
  8023e0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8023e5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8023eb:	75 15                	jne    802402 <strtol+0x58>
  8023ed:	80 39 30             	cmpb   $0x30,(%ecx)
  8023f0:	75 10                	jne    802402 <strtol+0x58>
  8023f2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8023f6:	75 7c                	jne    802474 <strtol+0xca>
		s += 2, base = 16;
  8023f8:	83 c1 02             	add    $0x2,%ecx
  8023fb:	bb 10 00 00 00       	mov    $0x10,%ebx
  802400:	eb 16                	jmp    802418 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  802402:	85 db                	test   %ebx,%ebx
  802404:	75 12                	jne    802418 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  802406:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80240b:	80 39 30             	cmpb   $0x30,(%ecx)
  80240e:	75 08                	jne    802418 <strtol+0x6e>
		s++, base = 8;
  802410:	83 c1 01             	add    $0x1,%ecx
  802413:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  802418:	b8 00 00 00 00       	mov    $0x0,%eax
  80241d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  802420:	0f b6 11             	movzbl (%ecx),%edx
  802423:	8d 72 d0             	lea    -0x30(%edx),%esi
  802426:	89 f3                	mov    %esi,%ebx
  802428:	80 fb 09             	cmp    $0x9,%bl
  80242b:	77 08                	ja     802435 <strtol+0x8b>
			dig = *s - '0';
  80242d:	0f be d2             	movsbl %dl,%edx
  802430:	83 ea 30             	sub    $0x30,%edx
  802433:	eb 22                	jmp    802457 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  802435:	8d 72 9f             	lea    -0x61(%edx),%esi
  802438:	89 f3                	mov    %esi,%ebx
  80243a:	80 fb 19             	cmp    $0x19,%bl
  80243d:	77 08                	ja     802447 <strtol+0x9d>
			dig = *s - 'a' + 10;
  80243f:	0f be d2             	movsbl %dl,%edx
  802442:	83 ea 57             	sub    $0x57,%edx
  802445:	eb 10                	jmp    802457 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  802447:	8d 72 bf             	lea    -0x41(%edx),%esi
  80244a:	89 f3                	mov    %esi,%ebx
  80244c:	80 fb 19             	cmp    $0x19,%bl
  80244f:	77 16                	ja     802467 <strtol+0xbd>
			dig = *s - 'A' + 10;
  802451:	0f be d2             	movsbl %dl,%edx
  802454:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  802457:	3b 55 10             	cmp    0x10(%ebp),%edx
  80245a:	7d 0b                	jge    802467 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  80245c:	83 c1 01             	add    $0x1,%ecx
  80245f:	0f af 45 10          	imul   0x10(%ebp),%eax
  802463:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  802465:	eb b9                	jmp    802420 <strtol+0x76>

	if (endptr)
  802467:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80246b:	74 0d                	je     80247a <strtol+0xd0>
		*endptr = (char *) s;
  80246d:	8b 75 0c             	mov    0xc(%ebp),%esi
  802470:	89 0e                	mov    %ecx,(%esi)
  802472:	eb 06                	jmp    80247a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802474:	85 db                	test   %ebx,%ebx
  802476:	74 98                	je     802410 <strtol+0x66>
  802478:	eb 9e                	jmp    802418 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80247a:	89 c2                	mov    %eax,%edx
  80247c:	f7 da                	neg    %edx
  80247e:	85 ff                	test   %edi,%edi
  802480:	0f 45 c2             	cmovne %edx,%eax
}
  802483:	5b                   	pop    %ebx
  802484:	5e                   	pop    %esi
  802485:	5f                   	pop    %edi
  802486:	5d                   	pop    %ebp
  802487:	c3                   	ret    

00802488 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  802488:	55                   	push   %ebp
  802489:	89 e5                	mov    %esp,%ebp
  80248b:	57                   	push   %edi
  80248c:	56                   	push   %esi
  80248d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80248e:	b8 00 00 00 00       	mov    $0x0,%eax
  802493:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802496:	8b 55 08             	mov    0x8(%ebp),%edx
  802499:	89 c3                	mov    %eax,%ebx
  80249b:	89 c7                	mov    %eax,%edi
  80249d:	89 c6                	mov    %eax,%esi
  80249f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8024a1:	5b                   	pop    %ebx
  8024a2:	5e                   	pop    %esi
  8024a3:	5f                   	pop    %edi
  8024a4:	5d                   	pop    %ebp
  8024a5:	c3                   	ret    

008024a6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8024a6:	55                   	push   %ebp
  8024a7:	89 e5                	mov    %esp,%ebp
  8024a9:	57                   	push   %edi
  8024aa:	56                   	push   %esi
  8024ab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8024b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8024b6:	89 d1                	mov    %edx,%ecx
  8024b8:	89 d3                	mov    %edx,%ebx
  8024ba:	89 d7                	mov    %edx,%edi
  8024bc:	89 d6                	mov    %edx,%esi
  8024be:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8024c0:	5b                   	pop    %ebx
  8024c1:	5e                   	pop    %esi
  8024c2:	5f                   	pop    %edi
  8024c3:	5d                   	pop    %ebp
  8024c4:	c3                   	ret    

008024c5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8024c5:	55                   	push   %ebp
  8024c6:	89 e5                	mov    %esp,%ebp
  8024c8:	57                   	push   %edi
  8024c9:	56                   	push   %esi
  8024ca:	53                   	push   %ebx
  8024cb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024ce:	b9 00 00 00 00       	mov    $0x0,%ecx
  8024d3:	b8 03 00 00 00       	mov    $0x3,%eax
  8024d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8024db:	89 cb                	mov    %ecx,%ebx
  8024dd:	89 cf                	mov    %ecx,%edi
  8024df:	89 ce                	mov    %ecx,%esi
  8024e1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8024e3:	85 c0                	test   %eax,%eax
  8024e5:	7e 17                	jle    8024fe <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8024e7:	83 ec 0c             	sub    $0xc,%esp
  8024ea:	50                   	push   %eax
  8024eb:	6a 03                	push   $0x3
  8024ed:	68 7f 41 80 00       	push   $0x80417f
  8024f2:	6a 23                	push   $0x23
  8024f4:	68 9c 41 80 00       	push   $0x80419c
  8024f9:	e8 e5 f5 ff ff       	call   801ae3 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8024fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802501:	5b                   	pop    %ebx
  802502:	5e                   	pop    %esi
  802503:	5f                   	pop    %edi
  802504:	5d                   	pop    %ebp
  802505:	c3                   	ret    

00802506 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  802506:	55                   	push   %ebp
  802507:	89 e5                	mov    %esp,%ebp
  802509:	57                   	push   %edi
  80250a:	56                   	push   %esi
  80250b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80250c:	ba 00 00 00 00       	mov    $0x0,%edx
  802511:	b8 02 00 00 00       	mov    $0x2,%eax
  802516:	89 d1                	mov    %edx,%ecx
  802518:	89 d3                	mov    %edx,%ebx
  80251a:	89 d7                	mov    %edx,%edi
  80251c:	89 d6                	mov    %edx,%esi
  80251e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  802520:	5b                   	pop    %ebx
  802521:	5e                   	pop    %esi
  802522:	5f                   	pop    %edi
  802523:	5d                   	pop    %ebp
  802524:	c3                   	ret    

00802525 <sys_yield>:

void
sys_yield(void)
{
  802525:	55                   	push   %ebp
  802526:	89 e5                	mov    %esp,%ebp
  802528:	57                   	push   %edi
  802529:	56                   	push   %esi
  80252a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80252b:	ba 00 00 00 00       	mov    $0x0,%edx
  802530:	b8 0b 00 00 00       	mov    $0xb,%eax
  802535:	89 d1                	mov    %edx,%ecx
  802537:	89 d3                	mov    %edx,%ebx
  802539:	89 d7                	mov    %edx,%edi
  80253b:	89 d6                	mov    %edx,%esi
  80253d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80253f:	5b                   	pop    %ebx
  802540:	5e                   	pop    %esi
  802541:	5f                   	pop    %edi
  802542:	5d                   	pop    %ebp
  802543:	c3                   	ret    

00802544 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  802544:	55                   	push   %ebp
  802545:	89 e5                	mov    %esp,%ebp
  802547:	57                   	push   %edi
  802548:	56                   	push   %esi
  802549:	53                   	push   %ebx
  80254a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80254d:	be 00 00 00 00       	mov    $0x0,%esi
  802552:	b8 04 00 00 00       	mov    $0x4,%eax
  802557:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80255a:	8b 55 08             	mov    0x8(%ebp),%edx
  80255d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802560:	89 f7                	mov    %esi,%edi
  802562:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802564:	85 c0                	test   %eax,%eax
  802566:	7e 17                	jle    80257f <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802568:	83 ec 0c             	sub    $0xc,%esp
  80256b:	50                   	push   %eax
  80256c:	6a 04                	push   $0x4
  80256e:	68 7f 41 80 00       	push   $0x80417f
  802573:	6a 23                	push   $0x23
  802575:	68 9c 41 80 00       	push   $0x80419c
  80257a:	e8 64 f5 ff ff       	call   801ae3 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80257f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802582:	5b                   	pop    %ebx
  802583:	5e                   	pop    %esi
  802584:	5f                   	pop    %edi
  802585:	5d                   	pop    %ebp
  802586:	c3                   	ret    

00802587 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  802587:	55                   	push   %ebp
  802588:	89 e5                	mov    %esp,%ebp
  80258a:	57                   	push   %edi
  80258b:	56                   	push   %esi
  80258c:	53                   	push   %ebx
  80258d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802590:	b8 05 00 00 00       	mov    $0x5,%eax
  802595:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802598:	8b 55 08             	mov    0x8(%ebp),%edx
  80259b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80259e:	8b 7d 14             	mov    0x14(%ebp),%edi
  8025a1:	8b 75 18             	mov    0x18(%ebp),%esi
  8025a4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8025a6:	85 c0                	test   %eax,%eax
  8025a8:	7e 17                	jle    8025c1 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025aa:	83 ec 0c             	sub    $0xc,%esp
  8025ad:	50                   	push   %eax
  8025ae:	6a 05                	push   $0x5
  8025b0:	68 7f 41 80 00       	push   $0x80417f
  8025b5:	6a 23                	push   $0x23
  8025b7:	68 9c 41 80 00       	push   $0x80419c
  8025bc:	e8 22 f5 ff ff       	call   801ae3 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8025c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025c4:	5b                   	pop    %ebx
  8025c5:	5e                   	pop    %esi
  8025c6:	5f                   	pop    %edi
  8025c7:	5d                   	pop    %ebp
  8025c8:	c3                   	ret    

008025c9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8025c9:	55                   	push   %ebp
  8025ca:	89 e5                	mov    %esp,%ebp
  8025cc:	57                   	push   %edi
  8025cd:	56                   	push   %esi
  8025ce:	53                   	push   %ebx
  8025cf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025d2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8025d7:	b8 06 00 00 00       	mov    $0x6,%eax
  8025dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025df:	8b 55 08             	mov    0x8(%ebp),%edx
  8025e2:	89 df                	mov    %ebx,%edi
  8025e4:	89 de                	mov    %ebx,%esi
  8025e6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8025e8:	85 c0                	test   %eax,%eax
  8025ea:	7e 17                	jle    802603 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025ec:	83 ec 0c             	sub    $0xc,%esp
  8025ef:	50                   	push   %eax
  8025f0:	6a 06                	push   $0x6
  8025f2:	68 7f 41 80 00       	push   $0x80417f
  8025f7:	6a 23                	push   $0x23
  8025f9:	68 9c 41 80 00       	push   $0x80419c
  8025fe:	e8 e0 f4 ff ff       	call   801ae3 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  802603:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802606:	5b                   	pop    %ebx
  802607:	5e                   	pop    %esi
  802608:	5f                   	pop    %edi
  802609:	5d                   	pop    %ebp
  80260a:	c3                   	ret    

0080260b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80260b:	55                   	push   %ebp
  80260c:	89 e5                	mov    %esp,%ebp
  80260e:	57                   	push   %edi
  80260f:	56                   	push   %esi
  802610:	53                   	push   %ebx
  802611:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802614:	bb 00 00 00 00       	mov    $0x0,%ebx
  802619:	b8 08 00 00 00       	mov    $0x8,%eax
  80261e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802621:	8b 55 08             	mov    0x8(%ebp),%edx
  802624:	89 df                	mov    %ebx,%edi
  802626:	89 de                	mov    %ebx,%esi
  802628:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80262a:	85 c0                	test   %eax,%eax
  80262c:	7e 17                	jle    802645 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80262e:	83 ec 0c             	sub    $0xc,%esp
  802631:	50                   	push   %eax
  802632:	6a 08                	push   $0x8
  802634:	68 7f 41 80 00       	push   $0x80417f
  802639:	6a 23                	push   $0x23
  80263b:	68 9c 41 80 00       	push   $0x80419c
  802640:	e8 9e f4 ff ff       	call   801ae3 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  802645:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802648:	5b                   	pop    %ebx
  802649:	5e                   	pop    %esi
  80264a:	5f                   	pop    %edi
  80264b:	5d                   	pop    %ebp
  80264c:	c3                   	ret    

0080264d <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80264d:	55                   	push   %ebp
  80264e:	89 e5                	mov    %esp,%ebp
  802650:	57                   	push   %edi
  802651:	56                   	push   %esi
  802652:	53                   	push   %ebx
  802653:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802656:	bb 00 00 00 00       	mov    $0x0,%ebx
  80265b:	b8 09 00 00 00       	mov    $0x9,%eax
  802660:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802663:	8b 55 08             	mov    0x8(%ebp),%edx
  802666:	89 df                	mov    %ebx,%edi
  802668:	89 de                	mov    %ebx,%esi
  80266a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80266c:	85 c0                	test   %eax,%eax
  80266e:	7e 17                	jle    802687 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802670:	83 ec 0c             	sub    $0xc,%esp
  802673:	50                   	push   %eax
  802674:	6a 09                	push   $0x9
  802676:	68 7f 41 80 00       	push   $0x80417f
  80267b:	6a 23                	push   $0x23
  80267d:	68 9c 41 80 00       	push   $0x80419c
  802682:	e8 5c f4 ff ff       	call   801ae3 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  802687:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80268a:	5b                   	pop    %ebx
  80268b:	5e                   	pop    %esi
  80268c:	5f                   	pop    %edi
  80268d:	5d                   	pop    %ebp
  80268e:	c3                   	ret    

0080268f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80268f:	55                   	push   %ebp
  802690:	89 e5                	mov    %esp,%ebp
  802692:	57                   	push   %edi
  802693:	56                   	push   %esi
  802694:	53                   	push   %ebx
  802695:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802698:	bb 00 00 00 00       	mov    $0x0,%ebx
  80269d:	b8 0a 00 00 00       	mov    $0xa,%eax
  8026a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8026a8:	89 df                	mov    %ebx,%edi
  8026aa:	89 de                	mov    %ebx,%esi
  8026ac:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8026ae:	85 c0                	test   %eax,%eax
  8026b0:	7e 17                	jle    8026c9 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8026b2:	83 ec 0c             	sub    $0xc,%esp
  8026b5:	50                   	push   %eax
  8026b6:	6a 0a                	push   $0xa
  8026b8:	68 7f 41 80 00       	push   $0x80417f
  8026bd:	6a 23                	push   $0x23
  8026bf:	68 9c 41 80 00       	push   $0x80419c
  8026c4:	e8 1a f4 ff ff       	call   801ae3 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8026c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026cc:	5b                   	pop    %ebx
  8026cd:	5e                   	pop    %esi
  8026ce:	5f                   	pop    %edi
  8026cf:	5d                   	pop    %ebp
  8026d0:	c3                   	ret    

008026d1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8026d1:	55                   	push   %ebp
  8026d2:	89 e5                	mov    %esp,%ebp
  8026d4:	57                   	push   %edi
  8026d5:	56                   	push   %esi
  8026d6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026d7:	be 00 00 00 00       	mov    $0x0,%esi
  8026dc:	b8 0c 00 00 00       	mov    $0xc,%eax
  8026e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8026e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8026ea:	8b 7d 14             	mov    0x14(%ebp),%edi
  8026ed:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8026ef:	5b                   	pop    %ebx
  8026f0:	5e                   	pop    %esi
  8026f1:	5f                   	pop    %edi
  8026f2:	5d                   	pop    %ebp
  8026f3:	c3                   	ret    

008026f4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8026f4:	55                   	push   %ebp
  8026f5:	89 e5                	mov    %esp,%ebp
  8026f7:	57                   	push   %edi
  8026f8:	56                   	push   %esi
  8026f9:	53                   	push   %ebx
  8026fa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  802702:	b8 0d 00 00 00       	mov    $0xd,%eax
  802707:	8b 55 08             	mov    0x8(%ebp),%edx
  80270a:	89 cb                	mov    %ecx,%ebx
  80270c:	89 cf                	mov    %ecx,%edi
  80270e:	89 ce                	mov    %ecx,%esi
  802710:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802712:	85 c0                	test   %eax,%eax
  802714:	7e 17                	jle    80272d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  802716:	83 ec 0c             	sub    $0xc,%esp
  802719:	50                   	push   %eax
  80271a:	6a 0d                	push   $0xd
  80271c:	68 7f 41 80 00       	push   $0x80417f
  802721:	6a 23                	push   $0x23
  802723:	68 9c 41 80 00       	push   $0x80419c
  802728:	e8 b6 f3 ff ff       	call   801ae3 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80272d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802730:	5b                   	pop    %ebx
  802731:	5e                   	pop    %esi
  802732:	5f                   	pop    %edi
  802733:	5d                   	pop    %ebp
  802734:	c3                   	ret    

00802735 <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  802735:	55                   	push   %ebp
  802736:	89 e5                	mov    %esp,%ebp
  802738:	57                   	push   %edi
  802739:	56                   	push   %esi
  80273a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80273b:	b9 00 00 00 00       	mov    $0x0,%ecx
  802740:	b8 0e 00 00 00       	mov    $0xe,%eax
  802745:	8b 55 08             	mov    0x8(%ebp),%edx
  802748:	89 cb                	mov    %ecx,%ebx
  80274a:	89 cf                	mov    %ecx,%edi
  80274c:	89 ce                	mov    %ecx,%esi
  80274e:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  802750:	5b                   	pop    %ebx
  802751:	5e                   	pop    %esi
  802752:	5f                   	pop    %edi
  802753:	5d                   	pop    %ebp
  802754:	c3                   	ret    

00802755 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802755:	55                   	push   %ebp
  802756:	89 e5                	mov    %esp,%ebp
  802758:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80275b:	83 3d 10 a0 80 00 00 	cmpl   $0x0,0x80a010
  802762:	75 2a                	jne    80278e <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802764:	83 ec 04             	sub    $0x4,%esp
  802767:	6a 07                	push   $0x7
  802769:	68 00 f0 bf ee       	push   $0xeebff000
  80276e:	6a 00                	push   $0x0
  802770:	e8 cf fd ff ff       	call   802544 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802775:	83 c4 10             	add    $0x10,%esp
  802778:	85 c0                	test   %eax,%eax
  80277a:	79 12                	jns    80278e <set_pgfault_handler+0x39>
			panic("%e\n", r);
  80277c:	50                   	push   %eax
  80277d:	68 aa 41 80 00       	push   $0x8041aa
  802782:	6a 23                	push   $0x23
  802784:	68 ae 41 80 00       	push   $0x8041ae
  802789:	e8 55 f3 ff ff       	call   801ae3 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80278e:	8b 45 08             	mov    0x8(%ebp),%eax
  802791:	a3 10 a0 80 00       	mov    %eax,0x80a010
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802796:	83 ec 08             	sub    $0x8,%esp
  802799:	68 c0 27 80 00       	push   $0x8027c0
  80279e:	6a 00                	push   $0x0
  8027a0:	e8 ea fe ff ff       	call   80268f <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8027a5:	83 c4 10             	add    $0x10,%esp
  8027a8:	85 c0                	test   %eax,%eax
  8027aa:	79 12                	jns    8027be <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8027ac:	50                   	push   %eax
  8027ad:	68 aa 41 80 00       	push   $0x8041aa
  8027b2:	6a 2c                	push   $0x2c
  8027b4:	68 ae 41 80 00       	push   $0x8041ae
  8027b9:	e8 25 f3 ff ff       	call   801ae3 <_panic>
	}
}
  8027be:	c9                   	leave  
  8027bf:	c3                   	ret    

008027c0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8027c0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8027c1:	a1 10 a0 80 00       	mov    0x80a010,%eax
	call *%eax
  8027c6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8027c8:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8027cb:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8027cf:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8027d4:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8027d8:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8027da:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8027dd:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8027de:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8027e1:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8027e2:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8027e3:	c3                   	ret    

008027e4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8027e4:	55                   	push   %ebp
  8027e5:	89 e5                	mov    %esp,%ebp
  8027e7:	56                   	push   %esi
  8027e8:	53                   	push   %ebx
  8027e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8027ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8027f2:	85 c0                	test   %eax,%eax
  8027f4:	75 12                	jne    802808 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8027f6:	83 ec 0c             	sub    $0xc,%esp
  8027f9:	68 00 00 c0 ee       	push   $0xeec00000
  8027fe:	e8 f1 fe ff ff       	call   8026f4 <sys_ipc_recv>
  802803:	83 c4 10             	add    $0x10,%esp
  802806:	eb 0c                	jmp    802814 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802808:	83 ec 0c             	sub    $0xc,%esp
  80280b:	50                   	push   %eax
  80280c:	e8 e3 fe ff ff       	call   8026f4 <sys_ipc_recv>
  802811:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802814:	85 f6                	test   %esi,%esi
  802816:	0f 95 c1             	setne  %cl
  802819:	85 db                	test   %ebx,%ebx
  80281b:	0f 95 c2             	setne  %dl
  80281e:	84 d1                	test   %dl,%cl
  802820:	74 09                	je     80282b <ipc_recv+0x47>
  802822:	89 c2                	mov    %eax,%edx
  802824:	c1 ea 1f             	shr    $0x1f,%edx
  802827:	84 d2                	test   %dl,%dl
  802829:	75 27                	jne    802852 <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  80282b:	85 f6                	test   %esi,%esi
  80282d:	74 0a                	je     802839 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  80282f:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802834:	8b 40 7c             	mov    0x7c(%eax),%eax
  802837:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802839:	85 db                	test   %ebx,%ebx
  80283b:	74 0d                	je     80284a <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  80283d:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802842:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  802848:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80284a:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80284f:	8b 40 78             	mov    0x78(%eax),%eax
}
  802852:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802855:	5b                   	pop    %ebx
  802856:	5e                   	pop    %esi
  802857:	5d                   	pop    %ebp
  802858:	c3                   	ret    

00802859 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802859:	55                   	push   %ebp
  80285a:	89 e5                	mov    %esp,%ebp
  80285c:	57                   	push   %edi
  80285d:	56                   	push   %esi
  80285e:	53                   	push   %ebx
  80285f:	83 ec 0c             	sub    $0xc,%esp
  802862:	8b 7d 08             	mov    0x8(%ebp),%edi
  802865:	8b 75 0c             	mov    0xc(%ebp),%esi
  802868:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80286b:	85 db                	test   %ebx,%ebx
  80286d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802872:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802875:	ff 75 14             	pushl  0x14(%ebp)
  802878:	53                   	push   %ebx
  802879:	56                   	push   %esi
  80287a:	57                   	push   %edi
  80287b:	e8 51 fe ff ff       	call   8026d1 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802880:	89 c2                	mov    %eax,%edx
  802882:	c1 ea 1f             	shr    $0x1f,%edx
  802885:	83 c4 10             	add    $0x10,%esp
  802888:	84 d2                	test   %dl,%dl
  80288a:	74 17                	je     8028a3 <ipc_send+0x4a>
  80288c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80288f:	74 12                	je     8028a3 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802891:	50                   	push   %eax
  802892:	68 bc 41 80 00       	push   $0x8041bc
  802897:	6a 47                	push   $0x47
  802899:	68 ca 41 80 00       	push   $0x8041ca
  80289e:	e8 40 f2 ff ff       	call   801ae3 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8028a3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8028a6:	75 07                	jne    8028af <ipc_send+0x56>
			sys_yield();
  8028a8:	e8 78 fc ff ff       	call   802525 <sys_yield>
  8028ad:	eb c6                	jmp    802875 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8028af:	85 c0                	test   %eax,%eax
  8028b1:	75 c2                	jne    802875 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8028b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8028b6:	5b                   	pop    %ebx
  8028b7:	5e                   	pop    %esi
  8028b8:	5f                   	pop    %edi
  8028b9:	5d                   	pop    %ebp
  8028ba:	c3                   	ret    

008028bb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8028bb:	55                   	push   %ebp
  8028bc:	89 e5                	mov    %esp,%ebp
  8028be:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8028c1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8028c6:	89 c2                	mov    %eax,%edx
  8028c8:	c1 e2 07             	shl    $0x7,%edx
  8028cb:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  8028d2:	8b 52 58             	mov    0x58(%edx),%edx
  8028d5:	39 ca                	cmp    %ecx,%edx
  8028d7:	75 11                	jne    8028ea <ipc_find_env+0x2f>
			return envs[i].env_id;
  8028d9:	89 c2                	mov    %eax,%edx
  8028db:	c1 e2 07             	shl    $0x7,%edx
  8028de:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8028e5:	8b 40 50             	mov    0x50(%eax),%eax
  8028e8:	eb 0f                	jmp    8028f9 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8028ea:	83 c0 01             	add    $0x1,%eax
  8028ed:	3d 00 04 00 00       	cmp    $0x400,%eax
  8028f2:	75 d2                	jne    8028c6 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8028f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8028f9:	5d                   	pop    %ebp
  8028fa:	c3                   	ret    

008028fb <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8028fb:	55                   	push   %ebp
  8028fc:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8028fe:	8b 45 08             	mov    0x8(%ebp),%eax
  802901:	05 00 00 00 30       	add    $0x30000000,%eax
  802906:	c1 e8 0c             	shr    $0xc,%eax
}
  802909:	5d                   	pop    %ebp
  80290a:	c3                   	ret    

0080290b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80290b:	55                   	push   %ebp
  80290c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80290e:	8b 45 08             	mov    0x8(%ebp),%eax
  802911:	05 00 00 00 30       	add    $0x30000000,%eax
  802916:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80291b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  802920:	5d                   	pop    %ebp
  802921:	c3                   	ret    

00802922 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  802922:	55                   	push   %ebp
  802923:	89 e5                	mov    %esp,%ebp
  802925:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802928:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80292d:	89 c2                	mov    %eax,%edx
  80292f:	c1 ea 16             	shr    $0x16,%edx
  802932:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802939:	f6 c2 01             	test   $0x1,%dl
  80293c:	74 11                	je     80294f <fd_alloc+0x2d>
  80293e:	89 c2                	mov    %eax,%edx
  802940:	c1 ea 0c             	shr    $0xc,%edx
  802943:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80294a:	f6 c2 01             	test   $0x1,%dl
  80294d:	75 09                	jne    802958 <fd_alloc+0x36>
			*fd_store = fd;
  80294f:	89 01                	mov    %eax,(%ecx)
			return 0;
  802951:	b8 00 00 00 00       	mov    $0x0,%eax
  802956:	eb 17                	jmp    80296f <fd_alloc+0x4d>
  802958:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80295d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  802962:	75 c9                	jne    80292d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  802964:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80296a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80296f:	5d                   	pop    %ebp
  802970:	c3                   	ret    

00802971 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802971:	55                   	push   %ebp
  802972:	89 e5                	mov    %esp,%ebp
  802974:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802977:	83 f8 1f             	cmp    $0x1f,%eax
  80297a:	77 36                	ja     8029b2 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80297c:	c1 e0 0c             	shl    $0xc,%eax
  80297f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  802984:	89 c2                	mov    %eax,%edx
  802986:	c1 ea 16             	shr    $0x16,%edx
  802989:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802990:	f6 c2 01             	test   $0x1,%dl
  802993:	74 24                	je     8029b9 <fd_lookup+0x48>
  802995:	89 c2                	mov    %eax,%edx
  802997:	c1 ea 0c             	shr    $0xc,%edx
  80299a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8029a1:	f6 c2 01             	test   $0x1,%dl
  8029a4:	74 1a                	je     8029c0 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8029a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8029a9:	89 02                	mov    %eax,(%edx)
	return 0;
  8029ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8029b0:	eb 13                	jmp    8029c5 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8029b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8029b7:	eb 0c                	jmp    8029c5 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8029b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8029be:	eb 05                	jmp    8029c5 <fd_lookup+0x54>
  8029c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8029c5:	5d                   	pop    %ebp
  8029c6:	c3                   	ret    

008029c7 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8029c7:	55                   	push   %ebp
  8029c8:	89 e5                	mov    %esp,%ebp
  8029ca:	83 ec 08             	sub    $0x8,%esp
  8029cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8029d0:	ba 54 42 80 00       	mov    $0x804254,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8029d5:	eb 13                	jmp    8029ea <dev_lookup+0x23>
  8029d7:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8029da:	39 08                	cmp    %ecx,(%eax)
  8029dc:	75 0c                	jne    8029ea <dev_lookup+0x23>
			*dev = devtab[i];
  8029de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8029e1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8029e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8029e8:	eb 2e                	jmp    802a18 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8029ea:	8b 02                	mov    (%edx),%eax
  8029ec:	85 c0                	test   %eax,%eax
  8029ee:	75 e7                	jne    8029d7 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8029f0:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8029f5:	8b 40 50             	mov    0x50(%eax),%eax
  8029f8:	83 ec 04             	sub    $0x4,%esp
  8029fb:	51                   	push   %ecx
  8029fc:	50                   	push   %eax
  8029fd:	68 d4 41 80 00       	push   $0x8041d4
  802a02:	e8 b5 f1 ff ff       	call   801bbc <cprintf>
	*dev = 0;
  802a07:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a0a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  802a10:	83 c4 10             	add    $0x10,%esp
  802a13:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802a18:	c9                   	leave  
  802a19:	c3                   	ret    

00802a1a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  802a1a:	55                   	push   %ebp
  802a1b:	89 e5                	mov    %esp,%ebp
  802a1d:	56                   	push   %esi
  802a1e:	53                   	push   %ebx
  802a1f:	83 ec 10             	sub    $0x10,%esp
  802a22:	8b 75 08             	mov    0x8(%ebp),%esi
  802a25:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802a28:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802a2b:	50                   	push   %eax
  802a2c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  802a32:	c1 e8 0c             	shr    $0xc,%eax
  802a35:	50                   	push   %eax
  802a36:	e8 36 ff ff ff       	call   802971 <fd_lookup>
  802a3b:	83 c4 08             	add    $0x8,%esp
  802a3e:	85 c0                	test   %eax,%eax
  802a40:	78 05                	js     802a47 <fd_close+0x2d>
	    || fd != fd2)
  802a42:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  802a45:	74 0c                	je     802a53 <fd_close+0x39>
		return (must_exist ? r : 0);
  802a47:	84 db                	test   %bl,%bl
  802a49:	ba 00 00 00 00       	mov    $0x0,%edx
  802a4e:	0f 44 c2             	cmove  %edx,%eax
  802a51:	eb 41                	jmp    802a94 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802a53:	83 ec 08             	sub    $0x8,%esp
  802a56:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802a59:	50                   	push   %eax
  802a5a:	ff 36                	pushl  (%esi)
  802a5c:	e8 66 ff ff ff       	call   8029c7 <dev_lookup>
  802a61:	89 c3                	mov    %eax,%ebx
  802a63:	83 c4 10             	add    $0x10,%esp
  802a66:	85 c0                	test   %eax,%eax
  802a68:	78 1a                	js     802a84 <fd_close+0x6a>
		if (dev->dev_close)
  802a6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802a6d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  802a70:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  802a75:	85 c0                	test   %eax,%eax
  802a77:	74 0b                	je     802a84 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  802a79:	83 ec 0c             	sub    $0xc,%esp
  802a7c:	56                   	push   %esi
  802a7d:	ff d0                	call   *%eax
  802a7f:	89 c3                	mov    %eax,%ebx
  802a81:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802a84:	83 ec 08             	sub    $0x8,%esp
  802a87:	56                   	push   %esi
  802a88:	6a 00                	push   $0x0
  802a8a:	e8 3a fb ff ff       	call   8025c9 <sys_page_unmap>
	return r;
  802a8f:	83 c4 10             	add    $0x10,%esp
  802a92:	89 d8                	mov    %ebx,%eax
}
  802a94:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802a97:	5b                   	pop    %ebx
  802a98:	5e                   	pop    %esi
  802a99:	5d                   	pop    %ebp
  802a9a:	c3                   	ret    

00802a9b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  802a9b:	55                   	push   %ebp
  802a9c:	89 e5                	mov    %esp,%ebp
  802a9e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802aa1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802aa4:	50                   	push   %eax
  802aa5:	ff 75 08             	pushl  0x8(%ebp)
  802aa8:	e8 c4 fe ff ff       	call   802971 <fd_lookup>
  802aad:	83 c4 08             	add    $0x8,%esp
  802ab0:	85 c0                	test   %eax,%eax
  802ab2:	78 10                	js     802ac4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  802ab4:	83 ec 08             	sub    $0x8,%esp
  802ab7:	6a 01                	push   $0x1
  802ab9:	ff 75 f4             	pushl  -0xc(%ebp)
  802abc:	e8 59 ff ff ff       	call   802a1a <fd_close>
  802ac1:	83 c4 10             	add    $0x10,%esp
}
  802ac4:	c9                   	leave  
  802ac5:	c3                   	ret    

00802ac6 <close_all>:

void
close_all(void)
{
  802ac6:	55                   	push   %ebp
  802ac7:	89 e5                	mov    %esp,%ebp
  802ac9:	53                   	push   %ebx
  802aca:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802acd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802ad2:	83 ec 0c             	sub    $0xc,%esp
  802ad5:	53                   	push   %ebx
  802ad6:	e8 c0 ff ff ff       	call   802a9b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  802adb:	83 c3 01             	add    $0x1,%ebx
  802ade:	83 c4 10             	add    $0x10,%esp
  802ae1:	83 fb 20             	cmp    $0x20,%ebx
  802ae4:	75 ec                	jne    802ad2 <close_all+0xc>
		close(i);
}
  802ae6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802ae9:	c9                   	leave  
  802aea:	c3                   	ret    

00802aeb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802aeb:	55                   	push   %ebp
  802aec:	89 e5                	mov    %esp,%ebp
  802aee:	57                   	push   %edi
  802aef:	56                   	push   %esi
  802af0:	53                   	push   %ebx
  802af1:	83 ec 2c             	sub    $0x2c,%esp
  802af4:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802af7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802afa:	50                   	push   %eax
  802afb:	ff 75 08             	pushl  0x8(%ebp)
  802afe:	e8 6e fe ff ff       	call   802971 <fd_lookup>
  802b03:	83 c4 08             	add    $0x8,%esp
  802b06:	85 c0                	test   %eax,%eax
  802b08:	0f 88 c1 00 00 00    	js     802bcf <dup+0xe4>
		return r;
	close(newfdnum);
  802b0e:	83 ec 0c             	sub    $0xc,%esp
  802b11:	56                   	push   %esi
  802b12:	e8 84 ff ff ff       	call   802a9b <close>

	newfd = INDEX2FD(newfdnum);
  802b17:	89 f3                	mov    %esi,%ebx
  802b19:	c1 e3 0c             	shl    $0xc,%ebx
  802b1c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  802b22:	83 c4 04             	add    $0x4,%esp
  802b25:	ff 75 e4             	pushl  -0x1c(%ebp)
  802b28:	e8 de fd ff ff       	call   80290b <fd2data>
  802b2d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  802b2f:	89 1c 24             	mov    %ebx,(%esp)
  802b32:	e8 d4 fd ff ff       	call   80290b <fd2data>
  802b37:	83 c4 10             	add    $0x10,%esp
  802b3a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802b3d:	89 f8                	mov    %edi,%eax
  802b3f:	c1 e8 16             	shr    $0x16,%eax
  802b42:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802b49:	a8 01                	test   $0x1,%al
  802b4b:	74 37                	je     802b84 <dup+0x99>
  802b4d:	89 f8                	mov    %edi,%eax
  802b4f:	c1 e8 0c             	shr    $0xc,%eax
  802b52:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802b59:	f6 c2 01             	test   $0x1,%dl
  802b5c:	74 26                	je     802b84 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802b5e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802b65:	83 ec 0c             	sub    $0xc,%esp
  802b68:	25 07 0e 00 00       	and    $0xe07,%eax
  802b6d:	50                   	push   %eax
  802b6e:	ff 75 d4             	pushl  -0x2c(%ebp)
  802b71:	6a 00                	push   $0x0
  802b73:	57                   	push   %edi
  802b74:	6a 00                	push   $0x0
  802b76:	e8 0c fa ff ff       	call   802587 <sys_page_map>
  802b7b:	89 c7                	mov    %eax,%edi
  802b7d:	83 c4 20             	add    $0x20,%esp
  802b80:	85 c0                	test   %eax,%eax
  802b82:	78 2e                	js     802bb2 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802b84:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802b87:	89 d0                	mov    %edx,%eax
  802b89:	c1 e8 0c             	shr    $0xc,%eax
  802b8c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802b93:	83 ec 0c             	sub    $0xc,%esp
  802b96:	25 07 0e 00 00       	and    $0xe07,%eax
  802b9b:	50                   	push   %eax
  802b9c:	53                   	push   %ebx
  802b9d:	6a 00                	push   $0x0
  802b9f:	52                   	push   %edx
  802ba0:	6a 00                	push   $0x0
  802ba2:	e8 e0 f9 ff ff       	call   802587 <sys_page_map>
  802ba7:	89 c7                	mov    %eax,%edi
  802ba9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  802bac:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802bae:	85 ff                	test   %edi,%edi
  802bb0:	79 1d                	jns    802bcf <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802bb2:	83 ec 08             	sub    $0x8,%esp
  802bb5:	53                   	push   %ebx
  802bb6:	6a 00                	push   $0x0
  802bb8:	e8 0c fa ff ff       	call   8025c9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802bbd:	83 c4 08             	add    $0x8,%esp
  802bc0:	ff 75 d4             	pushl  -0x2c(%ebp)
  802bc3:	6a 00                	push   $0x0
  802bc5:	e8 ff f9 ff ff       	call   8025c9 <sys_page_unmap>
	return r;
  802bca:	83 c4 10             	add    $0x10,%esp
  802bcd:	89 f8                	mov    %edi,%eax
}
  802bcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802bd2:	5b                   	pop    %ebx
  802bd3:	5e                   	pop    %esi
  802bd4:	5f                   	pop    %edi
  802bd5:	5d                   	pop    %ebp
  802bd6:	c3                   	ret    

00802bd7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802bd7:	55                   	push   %ebp
  802bd8:	89 e5                	mov    %esp,%ebp
  802bda:	53                   	push   %ebx
  802bdb:	83 ec 14             	sub    $0x14,%esp
  802bde:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802be1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802be4:	50                   	push   %eax
  802be5:	53                   	push   %ebx
  802be6:	e8 86 fd ff ff       	call   802971 <fd_lookup>
  802beb:	83 c4 08             	add    $0x8,%esp
  802bee:	89 c2                	mov    %eax,%edx
  802bf0:	85 c0                	test   %eax,%eax
  802bf2:	78 6d                	js     802c61 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802bf4:	83 ec 08             	sub    $0x8,%esp
  802bf7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802bfa:	50                   	push   %eax
  802bfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802bfe:	ff 30                	pushl  (%eax)
  802c00:	e8 c2 fd ff ff       	call   8029c7 <dev_lookup>
  802c05:	83 c4 10             	add    $0x10,%esp
  802c08:	85 c0                	test   %eax,%eax
  802c0a:	78 4c                	js     802c58 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802c0c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802c0f:	8b 42 08             	mov    0x8(%edx),%eax
  802c12:	83 e0 03             	and    $0x3,%eax
  802c15:	83 f8 01             	cmp    $0x1,%eax
  802c18:	75 21                	jne    802c3b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802c1a:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802c1f:	8b 40 50             	mov    0x50(%eax),%eax
  802c22:	83 ec 04             	sub    $0x4,%esp
  802c25:	53                   	push   %ebx
  802c26:	50                   	push   %eax
  802c27:	68 18 42 80 00       	push   $0x804218
  802c2c:	e8 8b ef ff ff       	call   801bbc <cprintf>
		return -E_INVAL;
  802c31:	83 c4 10             	add    $0x10,%esp
  802c34:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802c39:	eb 26                	jmp    802c61 <read+0x8a>
	}
	if (!dev->dev_read)
  802c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c3e:	8b 40 08             	mov    0x8(%eax),%eax
  802c41:	85 c0                	test   %eax,%eax
  802c43:	74 17                	je     802c5c <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  802c45:	83 ec 04             	sub    $0x4,%esp
  802c48:	ff 75 10             	pushl  0x10(%ebp)
  802c4b:	ff 75 0c             	pushl  0xc(%ebp)
  802c4e:	52                   	push   %edx
  802c4f:	ff d0                	call   *%eax
  802c51:	89 c2                	mov    %eax,%edx
  802c53:	83 c4 10             	add    $0x10,%esp
  802c56:	eb 09                	jmp    802c61 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c58:	89 c2                	mov    %eax,%edx
  802c5a:	eb 05                	jmp    802c61 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802c5c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  802c61:	89 d0                	mov    %edx,%eax
  802c63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802c66:	c9                   	leave  
  802c67:	c3                   	ret    

00802c68 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802c68:	55                   	push   %ebp
  802c69:	89 e5                	mov    %esp,%ebp
  802c6b:	57                   	push   %edi
  802c6c:	56                   	push   %esi
  802c6d:	53                   	push   %ebx
  802c6e:	83 ec 0c             	sub    $0xc,%esp
  802c71:	8b 7d 08             	mov    0x8(%ebp),%edi
  802c74:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802c77:	bb 00 00 00 00       	mov    $0x0,%ebx
  802c7c:	eb 21                	jmp    802c9f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802c7e:	83 ec 04             	sub    $0x4,%esp
  802c81:	89 f0                	mov    %esi,%eax
  802c83:	29 d8                	sub    %ebx,%eax
  802c85:	50                   	push   %eax
  802c86:	89 d8                	mov    %ebx,%eax
  802c88:	03 45 0c             	add    0xc(%ebp),%eax
  802c8b:	50                   	push   %eax
  802c8c:	57                   	push   %edi
  802c8d:	e8 45 ff ff ff       	call   802bd7 <read>
		if (m < 0)
  802c92:	83 c4 10             	add    $0x10,%esp
  802c95:	85 c0                	test   %eax,%eax
  802c97:	78 10                	js     802ca9 <readn+0x41>
			return m;
		if (m == 0)
  802c99:	85 c0                	test   %eax,%eax
  802c9b:	74 0a                	je     802ca7 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802c9d:	01 c3                	add    %eax,%ebx
  802c9f:	39 f3                	cmp    %esi,%ebx
  802ca1:	72 db                	jb     802c7e <readn+0x16>
  802ca3:	89 d8                	mov    %ebx,%eax
  802ca5:	eb 02                	jmp    802ca9 <readn+0x41>
  802ca7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  802ca9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802cac:	5b                   	pop    %ebx
  802cad:	5e                   	pop    %esi
  802cae:	5f                   	pop    %edi
  802caf:	5d                   	pop    %ebp
  802cb0:	c3                   	ret    

00802cb1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802cb1:	55                   	push   %ebp
  802cb2:	89 e5                	mov    %esp,%ebp
  802cb4:	53                   	push   %ebx
  802cb5:	83 ec 14             	sub    $0x14,%esp
  802cb8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802cbb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802cbe:	50                   	push   %eax
  802cbf:	53                   	push   %ebx
  802cc0:	e8 ac fc ff ff       	call   802971 <fd_lookup>
  802cc5:	83 c4 08             	add    $0x8,%esp
  802cc8:	89 c2                	mov    %eax,%edx
  802cca:	85 c0                	test   %eax,%eax
  802ccc:	78 68                	js     802d36 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802cce:	83 ec 08             	sub    $0x8,%esp
  802cd1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802cd4:	50                   	push   %eax
  802cd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802cd8:	ff 30                	pushl  (%eax)
  802cda:	e8 e8 fc ff ff       	call   8029c7 <dev_lookup>
  802cdf:	83 c4 10             	add    $0x10,%esp
  802ce2:	85 c0                	test   %eax,%eax
  802ce4:	78 47                	js     802d2d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802ce6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802ce9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802ced:	75 21                	jne    802d10 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802cef:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802cf4:	8b 40 50             	mov    0x50(%eax),%eax
  802cf7:	83 ec 04             	sub    $0x4,%esp
  802cfa:	53                   	push   %ebx
  802cfb:	50                   	push   %eax
  802cfc:	68 34 42 80 00       	push   $0x804234
  802d01:	e8 b6 ee ff ff       	call   801bbc <cprintf>
		return -E_INVAL;
  802d06:	83 c4 10             	add    $0x10,%esp
  802d09:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802d0e:	eb 26                	jmp    802d36 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802d10:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802d13:	8b 52 0c             	mov    0xc(%edx),%edx
  802d16:	85 d2                	test   %edx,%edx
  802d18:	74 17                	je     802d31 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802d1a:	83 ec 04             	sub    $0x4,%esp
  802d1d:	ff 75 10             	pushl  0x10(%ebp)
  802d20:	ff 75 0c             	pushl  0xc(%ebp)
  802d23:	50                   	push   %eax
  802d24:	ff d2                	call   *%edx
  802d26:	89 c2                	mov    %eax,%edx
  802d28:	83 c4 10             	add    $0x10,%esp
  802d2b:	eb 09                	jmp    802d36 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d2d:	89 c2                	mov    %eax,%edx
  802d2f:	eb 05                	jmp    802d36 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802d31:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802d36:	89 d0                	mov    %edx,%eax
  802d38:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802d3b:	c9                   	leave  
  802d3c:	c3                   	ret    

00802d3d <seek>:

int
seek(int fdnum, off_t offset)
{
  802d3d:	55                   	push   %ebp
  802d3e:	89 e5                	mov    %esp,%ebp
  802d40:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802d43:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802d46:	50                   	push   %eax
  802d47:	ff 75 08             	pushl  0x8(%ebp)
  802d4a:	e8 22 fc ff ff       	call   802971 <fd_lookup>
  802d4f:	83 c4 08             	add    $0x8,%esp
  802d52:	85 c0                	test   %eax,%eax
  802d54:	78 0e                	js     802d64 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802d56:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802d59:	8b 55 0c             	mov    0xc(%ebp),%edx
  802d5c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802d5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802d64:	c9                   	leave  
  802d65:	c3                   	ret    

00802d66 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802d66:	55                   	push   %ebp
  802d67:	89 e5                	mov    %esp,%ebp
  802d69:	53                   	push   %ebx
  802d6a:	83 ec 14             	sub    $0x14,%esp
  802d6d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802d70:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d73:	50                   	push   %eax
  802d74:	53                   	push   %ebx
  802d75:	e8 f7 fb ff ff       	call   802971 <fd_lookup>
  802d7a:	83 c4 08             	add    $0x8,%esp
  802d7d:	89 c2                	mov    %eax,%edx
  802d7f:	85 c0                	test   %eax,%eax
  802d81:	78 65                	js     802de8 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d83:	83 ec 08             	sub    $0x8,%esp
  802d86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d89:	50                   	push   %eax
  802d8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d8d:	ff 30                	pushl  (%eax)
  802d8f:	e8 33 fc ff ff       	call   8029c7 <dev_lookup>
  802d94:	83 c4 10             	add    $0x10,%esp
  802d97:	85 c0                	test   %eax,%eax
  802d99:	78 44                	js     802ddf <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802d9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d9e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802da2:	75 21                	jne    802dc5 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802da4:	a1 0c a0 80 00       	mov    0x80a00c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802da9:	8b 40 50             	mov    0x50(%eax),%eax
  802dac:	83 ec 04             	sub    $0x4,%esp
  802daf:	53                   	push   %ebx
  802db0:	50                   	push   %eax
  802db1:	68 f4 41 80 00       	push   $0x8041f4
  802db6:	e8 01 ee ff ff       	call   801bbc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802dbb:	83 c4 10             	add    $0x10,%esp
  802dbe:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802dc3:	eb 23                	jmp    802de8 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802dc5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802dc8:	8b 52 18             	mov    0x18(%edx),%edx
  802dcb:	85 d2                	test   %edx,%edx
  802dcd:	74 14                	je     802de3 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802dcf:	83 ec 08             	sub    $0x8,%esp
  802dd2:	ff 75 0c             	pushl  0xc(%ebp)
  802dd5:	50                   	push   %eax
  802dd6:	ff d2                	call   *%edx
  802dd8:	89 c2                	mov    %eax,%edx
  802dda:	83 c4 10             	add    $0x10,%esp
  802ddd:	eb 09                	jmp    802de8 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802ddf:	89 c2                	mov    %eax,%edx
  802de1:	eb 05                	jmp    802de8 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802de3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802de8:	89 d0                	mov    %edx,%eax
  802dea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802ded:	c9                   	leave  
  802dee:	c3                   	ret    

00802def <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802def:	55                   	push   %ebp
  802df0:	89 e5                	mov    %esp,%ebp
  802df2:	53                   	push   %ebx
  802df3:	83 ec 14             	sub    $0x14,%esp
  802df6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802df9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802dfc:	50                   	push   %eax
  802dfd:	ff 75 08             	pushl  0x8(%ebp)
  802e00:	e8 6c fb ff ff       	call   802971 <fd_lookup>
  802e05:	83 c4 08             	add    $0x8,%esp
  802e08:	89 c2                	mov    %eax,%edx
  802e0a:	85 c0                	test   %eax,%eax
  802e0c:	78 58                	js     802e66 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802e0e:	83 ec 08             	sub    $0x8,%esp
  802e11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e14:	50                   	push   %eax
  802e15:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e18:	ff 30                	pushl  (%eax)
  802e1a:	e8 a8 fb ff ff       	call   8029c7 <dev_lookup>
  802e1f:	83 c4 10             	add    $0x10,%esp
  802e22:	85 c0                	test   %eax,%eax
  802e24:	78 37                	js     802e5d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e29:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802e2d:	74 32                	je     802e61 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802e2f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802e32:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802e39:	00 00 00 
	stat->st_isdir = 0;
  802e3c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802e43:	00 00 00 
	stat->st_dev = dev;
  802e46:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802e4c:	83 ec 08             	sub    $0x8,%esp
  802e4f:	53                   	push   %ebx
  802e50:	ff 75 f0             	pushl  -0x10(%ebp)
  802e53:	ff 50 14             	call   *0x14(%eax)
  802e56:	89 c2                	mov    %eax,%edx
  802e58:	83 c4 10             	add    $0x10,%esp
  802e5b:	eb 09                	jmp    802e66 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802e5d:	89 c2                	mov    %eax,%edx
  802e5f:	eb 05                	jmp    802e66 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802e61:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802e66:	89 d0                	mov    %edx,%eax
  802e68:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e6b:	c9                   	leave  
  802e6c:	c3                   	ret    

00802e6d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802e6d:	55                   	push   %ebp
  802e6e:	89 e5                	mov    %esp,%ebp
  802e70:	56                   	push   %esi
  802e71:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802e72:	83 ec 08             	sub    $0x8,%esp
  802e75:	6a 00                	push   $0x0
  802e77:	ff 75 08             	pushl  0x8(%ebp)
  802e7a:	e8 e3 01 00 00       	call   803062 <open>
  802e7f:	89 c3                	mov    %eax,%ebx
  802e81:	83 c4 10             	add    $0x10,%esp
  802e84:	85 c0                	test   %eax,%eax
  802e86:	78 1b                	js     802ea3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802e88:	83 ec 08             	sub    $0x8,%esp
  802e8b:	ff 75 0c             	pushl  0xc(%ebp)
  802e8e:	50                   	push   %eax
  802e8f:	e8 5b ff ff ff       	call   802def <fstat>
  802e94:	89 c6                	mov    %eax,%esi
	close(fd);
  802e96:	89 1c 24             	mov    %ebx,(%esp)
  802e99:	e8 fd fb ff ff       	call   802a9b <close>
	return r;
  802e9e:	83 c4 10             	add    $0x10,%esp
  802ea1:	89 f0                	mov    %esi,%eax
}
  802ea3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ea6:	5b                   	pop    %ebx
  802ea7:	5e                   	pop    %esi
  802ea8:	5d                   	pop    %ebp
  802ea9:	c3                   	ret    

00802eaa <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802eaa:	55                   	push   %ebp
  802eab:	89 e5                	mov    %esp,%ebp
  802ead:	56                   	push   %esi
  802eae:	53                   	push   %ebx
  802eaf:	89 c6                	mov    %eax,%esi
  802eb1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802eb3:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  802eba:	75 12                	jne    802ece <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802ebc:	83 ec 0c             	sub    $0xc,%esp
  802ebf:	6a 01                	push   $0x1
  802ec1:	e8 f5 f9 ff ff       	call   8028bb <ipc_find_env>
  802ec6:	a3 00 a0 80 00       	mov    %eax,0x80a000
  802ecb:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802ece:	6a 07                	push   $0x7
  802ed0:	68 00 b0 80 00       	push   $0x80b000
  802ed5:	56                   	push   %esi
  802ed6:	ff 35 00 a0 80 00    	pushl  0x80a000
  802edc:	e8 78 f9 ff ff       	call   802859 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802ee1:	83 c4 0c             	add    $0xc,%esp
  802ee4:	6a 00                	push   $0x0
  802ee6:	53                   	push   %ebx
  802ee7:	6a 00                	push   $0x0
  802ee9:	e8 f6 f8 ff ff       	call   8027e4 <ipc_recv>
}
  802eee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ef1:	5b                   	pop    %ebx
  802ef2:	5e                   	pop    %esi
  802ef3:	5d                   	pop    %ebp
  802ef4:	c3                   	ret    

00802ef5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802ef5:	55                   	push   %ebp
  802ef6:	89 e5                	mov    %esp,%ebp
  802ef8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802efb:	8b 45 08             	mov    0x8(%ebp),%eax
  802efe:	8b 40 0c             	mov    0xc(%eax),%eax
  802f01:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  802f06:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f09:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802f0e:	ba 00 00 00 00       	mov    $0x0,%edx
  802f13:	b8 02 00 00 00       	mov    $0x2,%eax
  802f18:	e8 8d ff ff ff       	call   802eaa <fsipc>
}
  802f1d:	c9                   	leave  
  802f1e:	c3                   	ret    

00802f1f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802f1f:	55                   	push   %ebp
  802f20:	89 e5                	mov    %esp,%ebp
  802f22:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802f25:	8b 45 08             	mov    0x8(%ebp),%eax
  802f28:	8b 40 0c             	mov    0xc(%eax),%eax
  802f2b:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  802f30:	ba 00 00 00 00       	mov    $0x0,%edx
  802f35:	b8 06 00 00 00       	mov    $0x6,%eax
  802f3a:	e8 6b ff ff ff       	call   802eaa <fsipc>
}
  802f3f:	c9                   	leave  
  802f40:	c3                   	ret    

00802f41 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802f41:	55                   	push   %ebp
  802f42:	89 e5                	mov    %esp,%ebp
  802f44:	53                   	push   %ebx
  802f45:	83 ec 04             	sub    $0x4,%esp
  802f48:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802f4b:	8b 45 08             	mov    0x8(%ebp),%eax
  802f4e:	8b 40 0c             	mov    0xc(%eax),%eax
  802f51:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802f56:	ba 00 00 00 00       	mov    $0x0,%edx
  802f5b:	b8 05 00 00 00       	mov    $0x5,%eax
  802f60:	e8 45 ff ff ff       	call   802eaa <fsipc>
  802f65:	85 c0                	test   %eax,%eax
  802f67:	78 2c                	js     802f95 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802f69:	83 ec 08             	sub    $0x8,%esp
  802f6c:	68 00 b0 80 00       	push   $0x80b000
  802f71:	53                   	push   %ebx
  802f72:	e8 ca f1 ff ff       	call   802141 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802f77:	a1 80 b0 80 00       	mov    0x80b080,%eax
  802f7c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802f82:	a1 84 b0 80 00       	mov    0x80b084,%eax
  802f87:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802f8d:	83 c4 10             	add    $0x10,%esp
  802f90:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802f95:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f98:	c9                   	leave  
  802f99:	c3                   	ret    

00802f9a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802f9a:	55                   	push   %ebp
  802f9b:	89 e5                	mov    %esp,%ebp
  802f9d:	83 ec 0c             	sub    $0xc,%esp
  802fa0:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802fa3:	8b 55 08             	mov    0x8(%ebp),%edx
  802fa6:	8b 52 0c             	mov    0xc(%edx),%edx
  802fa9:	89 15 00 b0 80 00    	mov    %edx,0x80b000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  802faf:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  802fb4:	ba f8 0f 00 00       	mov    $0xff8,%edx
  802fb9:	0f 47 c2             	cmova  %edx,%eax
  802fbc:	a3 04 b0 80 00       	mov    %eax,0x80b004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  802fc1:	50                   	push   %eax
  802fc2:	ff 75 0c             	pushl  0xc(%ebp)
  802fc5:	68 08 b0 80 00       	push   $0x80b008
  802fca:	e8 04 f3 ff ff       	call   8022d3 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  802fcf:	ba 00 00 00 00       	mov    $0x0,%edx
  802fd4:	b8 04 00 00 00       	mov    $0x4,%eax
  802fd9:	e8 cc fe ff ff       	call   802eaa <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  802fde:	c9                   	leave  
  802fdf:	c3                   	ret    

00802fe0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802fe0:	55                   	push   %ebp
  802fe1:	89 e5                	mov    %esp,%ebp
  802fe3:	56                   	push   %esi
  802fe4:	53                   	push   %ebx
  802fe5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802fe8:	8b 45 08             	mov    0x8(%ebp),%eax
  802feb:	8b 40 0c             	mov    0xc(%eax),%eax
  802fee:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  802ff3:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802ff9:	ba 00 00 00 00       	mov    $0x0,%edx
  802ffe:	b8 03 00 00 00       	mov    $0x3,%eax
  803003:	e8 a2 fe ff ff       	call   802eaa <fsipc>
  803008:	89 c3                	mov    %eax,%ebx
  80300a:	85 c0                	test   %eax,%eax
  80300c:	78 4b                	js     803059 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80300e:	39 c6                	cmp    %eax,%esi
  803010:	73 16                	jae    803028 <devfile_read+0x48>
  803012:	68 64 42 80 00       	push   $0x804264
  803017:	68 fd 38 80 00       	push   $0x8038fd
  80301c:	6a 7c                	push   $0x7c
  80301e:	68 6b 42 80 00       	push   $0x80426b
  803023:	e8 bb ea ff ff       	call   801ae3 <_panic>
	assert(r <= PGSIZE);
  803028:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80302d:	7e 16                	jle    803045 <devfile_read+0x65>
  80302f:	68 76 42 80 00       	push   $0x804276
  803034:	68 fd 38 80 00       	push   $0x8038fd
  803039:	6a 7d                	push   $0x7d
  80303b:	68 6b 42 80 00       	push   $0x80426b
  803040:	e8 9e ea ff ff       	call   801ae3 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  803045:	83 ec 04             	sub    $0x4,%esp
  803048:	50                   	push   %eax
  803049:	68 00 b0 80 00       	push   $0x80b000
  80304e:	ff 75 0c             	pushl  0xc(%ebp)
  803051:	e8 7d f2 ff ff       	call   8022d3 <memmove>
	return r;
  803056:	83 c4 10             	add    $0x10,%esp
}
  803059:	89 d8                	mov    %ebx,%eax
  80305b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80305e:	5b                   	pop    %ebx
  80305f:	5e                   	pop    %esi
  803060:	5d                   	pop    %ebp
  803061:	c3                   	ret    

00803062 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  803062:	55                   	push   %ebp
  803063:	89 e5                	mov    %esp,%ebp
  803065:	53                   	push   %ebx
  803066:	83 ec 20             	sub    $0x20,%esp
  803069:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80306c:	53                   	push   %ebx
  80306d:	e8 96 f0 ff ff       	call   802108 <strlen>
  803072:	83 c4 10             	add    $0x10,%esp
  803075:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80307a:	7f 67                	jg     8030e3 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80307c:	83 ec 0c             	sub    $0xc,%esp
  80307f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803082:	50                   	push   %eax
  803083:	e8 9a f8 ff ff       	call   802922 <fd_alloc>
  803088:	83 c4 10             	add    $0x10,%esp
		return r;
  80308b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80308d:	85 c0                	test   %eax,%eax
  80308f:	78 57                	js     8030e8 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  803091:	83 ec 08             	sub    $0x8,%esp
  803094:	53                   	push   %ebx
  803095:	68 00 b0 80 00       	push   $0x80b000
  80309a:	e8 a2 f0 ff ff       	call   802141 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80309f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8030a2:	a3 00 b4 80 00       	mov    %eax,0x80b400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8030a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8030aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8030af:	e8 f6 fd ff ff       	call   802eaa <fsipc>
  8030b4:	89 c3                	mov    %eax,%ebx
  8030b6:	83 c4 10             	add    $0x10,%esp
  8030b9:	85 c0                	test   %eax,%eax
  8030bb:	79 14                	jns    8030d1 <open+0x6f>
		fd_close(fd, 0);
  8030bd:	83 ec 08             	sub    $0x8,%esp
  8030c0:	6a 00                	push   $0x0
  8030c2:	ff 75 f4             	pushl  -0xc(%ebp)
  8030c5:	e8 50 f9 ff ff       	call   802a1a <fd_close>
		return r;
  8030ca:	83 c4 10             	add    $0x10,%esp
  8030cd:	89 da                	mov    %ebx,%edx
  8030cf:	eb 17                	jmp    8030e8 <open+0x86>
	}

	return fd2num(fd);
  8030d1:	83 ec 0c             	sub    $0xc,%esp
  8030d4:	ff 75 f4             	pushl  -0xc(%ebp)
  8030d7:	e8 1f f8 ff ff       	call   8028fb <fd2num>
  8030dc:	89 c2                	mov    %eax,%edx
  8030de:	83 c4 10             	add    $0x10,%esp
  8030e1:	eb 05                	jmp    8030e8 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8030e3:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8030e8:	89 d0                	mov    %edx,%eax
  8030ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8030ed:	c9                   	leave  
  8030ee:	c3                   	ret    

008030ef <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8030ef:	55                   	push   %ebp
  8030f0:	89 e5                	mov    %esp,%ebp
  8030f2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8030f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8030fa:	b8 08 00 00 00       	mov    $0x8,%eax
  8030ff:	e8 a6 fd ff ff       	call   802eaa <fsipc>
}
  803104:	c9                   	leave  
  803105:	c3                   	ret    

00803106 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803106:	55                   	push   %ebp
  803107:	89 e5                	mov    %esp,%ebp
  803109:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80310c:	89 d0                	mov    %edx,%eax
  80310e:	c1 e8 16             	shr    $0x16,%eax
  803111:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  803118:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80311d:	f6 c1 01             	test   $0x1,%cl
  803120:	74 1d                	je     80313f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  803122:	c1 ea 0c             	shr    $0xc,%edx
  803125:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80312c:	f6 c2 01             	test   $0x1,%dl
  80312f:	74 0e                	je     80313f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803131:	c1 ea 0c             	shr    $0xc,%edx
  803134:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80313b:	ef 
  80313c:	0f b7 c0             	movzwl %ax,%eax
}
  80313f:	5d                   	pop    %ebp
  803140:	c3                   	ret    

00803141 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  803141:	55                   	push   %ebp
  803142:	89 e5                	mov    %esp,%ebp
  803144:	56                   	push   %esi
  803145:	53                   	push   %ebx
  803146:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  803149:	83 ec 0c             	sub    $0xc,%esp
  80314c:	ff 75 08             	pushl  0x8(%ebp)
  80314f:	e8 b7 f7 ff ff       	call   80290b <fd2data>
  803154:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  803156:	83 c4 08             	add    $0x8,%esp
  803159:	68 82 42 80 00       	push   $0x804282
  80315e:	53                   	push   %ebx
  80315f:	e8 dd ef ff ff       	call   802141 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  803164:	8b 46 04             	mov    0x4(%esi),%eax
  803167:	2b 06                	sub    (%esi),%eax
  803169:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80316f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  803176:	00 00 00 
	stat->st_dev = &devpipe;
  803179:	c7 83 88 00 00 00 80 	movl   $0x809080,0x88(%ebx)
  803180:	90 80 00 
	return 0;
}
  803183:	b8 00 00 00 00       	mov    $0x0,%eax
  803188:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80318b:	5b                   	pop    %ebx
  80318c:	5e                   	pop    %esi
  80318d:	5d                   	pop    %ebp
  80318e:	c3                   	ret    

0080318f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80318f:	55                   	push   %ebp
  803190:	89 e5                	mov    %esp,%ebp
  803192:	53                   	push   %ebx
  803193:	83 ec 0c             	sub    $0xc,%esp
  803196:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  803199:	53                   	push   %ebx
  80319a:	6a 00                	push   $0x0
  80319c:	e8 28 f4 ff ff       	call   8025c9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8031a1:	89 1c 24             	mov    %ebx,(%esp)
  8031a4:	e8 62 f7 ff ff       	call   80290b <fd2data>
  8031a9:	83 c4 08             	add    $0x8,%esp
  8031ac:	50                   	push   %eax
  8031ad:	6a 00                	push   $0x0
  8031af:	e8 15 f4 ff ff       	call   8025c9 <sys_page_unmap>
}
  8031b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8031b7:	c9                   	leave  
  8031b8:	c3                   	ret    

008031b9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8031b9:	55                   	push   %ebp
  8031ba:	89 e5                	mov    %esp,%ebp
  8031bc:	57                   	push   %edi
  8031bd:	56                   	push   %esi
  8031be:	53                   	push   %ebx
  8031bf:	83 ec 1c             	sub    $0x1c,%esp
  8031c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8031c5:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8031c7:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8031cc:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8031cf:	83 ec 0c             	sub    $0xc,%esp
  8031d2:	ff 75 e0             	pushl  -0x20(%ebp)
  8031d5:	e8 2c ff ff ff       	call   803106 <pageref>
  8031da:	89 c3                	mov    %eax,%ebx
  8031dc:	89 3c 24             	mov    %edi,(%esp)
  8031df:	e8 22 ff ff ff       	call   803106 <pageref>
  8031e4:	83 c4 10             	add    $0x10,%esp
  8031e7:	39 c3                	cmp    %eax,%ebx
  8031e9:	0f 94 c1             	sete   %cl
  8031ec:	0f b6 c9             	movzbl %cl,%ecx
  8031ef:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8031f2:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  8031f8:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  8031fb:	39 ce                	cmp    %ecx,%esi
  8031fd:	74 1b                	je     80321a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8031ff:	39 c3                	cmp    %eax,%ebx
  803201:	75 c4                	jne    8031c7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  803203:	8b 42 60             	mov    0x60(%edx),%eax
  803206:	ff 75 e4             	pushl  -0x1c(%ebp)
  803209:	50                   	push   %eax
  80320a:	56                   	push   %esi
  80320b:	68 89 42 80 00       	push   $0x804289
  803210:	e8 a7 e9 ff ff       	call   801bbc <cprintf>
  803215:	83 c4 10             	add    $0x10,%esp
  803218:	eb ad                	jmp    8031c7 <_pipeisclosed+0xe>
	}
}
  80321a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80321d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803220:	5b                   	pop    %ebx
  803221:	5e                   	pop    %esi
  803222:	5f                   	pop    %edi
  803223:	5d                   	pop    %ebp
  803224:	c3                   	ret    

00803225 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803225:	55                   	push   %ebp
  803226:	89 e5                	mov    %esp,%ebp
  803228:	57                   	push   %edi
  803229:	56                   	push   %esi
  80322a:	53                   	push   %ebx
  80322b:	83 ec 28             	sub    $0x28,%esp
  80322e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  803231:	56                   	push   %esi
  803232:	e8 d4 f6 ff ff       	call   80290b <fd2data>
  803237:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803239:	83 c4 10             	add    $0x10,%esp
  80323c:	bf 00 00 00 00       	mov    $0x0,%edi
  803241:	eb 4b                	jmp    80328e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  803243:	89 da                	mov    %ebx,%edx
  803245:	89 f0                	mov    %esi,%eax
  803247:	e8 6d ff ff ff       	call   8031b9 <_pipeisclosed>
  80324c:	85 c0                	test   %eax,%eax
  80324e:	75 48                	jne    803298 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  803250:	e8 d0 f2 ff ff       	call   802525 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  803255:	8b 43 04             	mov    0x4(%ebx),%eax
  803258:	8b 0b                	mov    (%ebx),%ecx
  80325a:	8d 51 20             	lea    0x20(%ecx),%edx
  80325d:	39 d0                	cmp    %edx,%eax
  80325f:	73 e2                	jae    803243 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  803261:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803264:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  803268:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80326b:	89 c2                	mov    %eax,%edx
  80326d:	c1 fa 1f             	sar    $0x1f,%edx
  803270:	89 d1                	mov    %edx,%ecx
  803272:	c1 e9 1b             	shr    $0x1b,%ecx
  803275:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  803278:	83 e2 1f             	and    $0x1f,%edx
  80327b:	29 ca                	sub    %ecx,%edx
  80327d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  803281:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  803285:	83 c0 01             	add    $0x1,%eax
  803288:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80328b:	83 c7 01             	add    $0x1,%edi
  80328e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  803291:	75 c2                	jne    803255 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  803293:	8b 45 10             	mov    0x10(%ebp),%eax
  803296:	eb 05                	jmp    80329d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803298:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80329d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8032a0:	5b                   	pop    %ebx
  8032a1:	5e                   	pop    %esi
  8032a2:	5f                   	pop    %edi
  8032a3:	5d                   	pop    %ebp
  8032a4:	c3                   	ret    

008032a5 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8032a5:	55                   	push   %ebp
  8032a6:	89 e5                	mov    %esp,%ebp
  8032a8:	57                   	push   %edi
  8032a9:	56                   	push   %esi
  8032aa:	53                   	push   %ebx
  8032ab:	83 ec 18             	sub    $0x18,%esp
  8032ae:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8032b1:	57                   	push   %edi
  8032b2:	e8 54 f6 ff ff       	call   80290b <fd2data>
  8032b7:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8032b9:	83 c4 10             	add    $0x10,%esp
  8032bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8032c1:	eb 3d                	jmp    803300 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8032c3:	85 db                	test   %ebx,%ebx
  8032c5:	74 04                	je     8032cb <devpipe_read+0x26>
				return i;
  8032c7:	89 d8                	mov    %ebx,%eax
  8032c9:	eb 44                	jmp    80330f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8032cb:	89 f2                	mov    %esi,%edx
  8032cd:	89 f8                	mov    %edi,%eax
  8032cf:	e8 e5 fe ff ff       	call   8031b9 <_pipeisclosed>
  8032d4:	85 c0                	test   %eax,%eax
  8032d6:	75 32                	jne    80330a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8032d8:	e8 48 f2 ff ff       	call   802525 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8032dd:	8b 06                	mov    (%esi),%eax
  8032df:	3b 46 04             	cmp    0x4(%esi),%eax
  8032e2:	74 df                	je     8032c3 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8032e4:	99                   	cltd   
  8032e5:	c1 ea 1b             	shr    $0x1b,%edx
  8032e8:	01 d0                	add    %edx,%eax
  8032ea:	83 e0 1f             	and    $0x1f,%eax
  8032ed:	29 d0                	sub    %edx,%eax
  8032ef:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8032f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8032f7:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8032fa:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8032fd:	83 c3 01             	add    $0x1,%ebx
  803300:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  803303:	75 d8                	jne    8032dd <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  803305:	8b 45 10             	mov    0x10(%ebp),%eax
  803308:	eb 05                	jmp    80330f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80330a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80330f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803312:	5b                   	pop    %ebx
  803313:	5e                   	pop    %esi
  803314:	5f                   	pop    %edi
  803315:	5d                   	pop    %ebp
  803316:	c3                   	ret    

00803317 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  803317:	55                   	push   %ebp
  803318:	89 e5                	mov    %esp,%ebp
  80331a:	56                   	push   %esi
  80331b:	53                   	push   %ebx
  80331c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80331f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803322:	50                   	push   %eax
  803323:	e8 fa f5 ff ff       	call   802922 <fd_alloc>
  803328:	83 c4 10             	add    $0x10,%esp
  80332b:	89 c2                	mov    %eax,%edx
  80332d:	85 c0                	test   %eax,%eax
  80332f:	0f 88 2c 01 00 00    	js     803461 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803335:	83 ec 04             	sub    $0x4,%esp
  803338:	68 07 04 00 00       	push   $0x407
  80333d:	ff 75 f4             	pushl  -0xc(%ebp)
  803340:	6a 00                	push   $0x0
  803342:	e8 fd f1 ff ff       	call   802544 <sys_page_alloc>
  803347:	83 c4 10             	add    $0x10,%esp
  80334a:	89 c2                	mov    %eax,%edx
  80334c:	85 c0                	test   %eax,%eax
  80334e:	0f 88 0d 01 00 00    	js     803461 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  803354:	83 ec 0c             	sub    $0xc,%esp
  803357:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80335a:	50                   	push   %eax
  80335b:	e8 c2 f5 ff ff       	call   802922 <fd_alloc>
  803360:	89 c3                	mov    %eax,%ebx
  803362:	83 c4 10             	add    $0x10,%esp
  803365:	85 c0                	test   %eax,%eax
  803367:	0f 88 e2 00 00 00    	js     80344f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80336d:	83 ec 04             	sub    $0x4,%esp
  803370:	68 07 04 00 00       	push   $0x407
  803375:	ff 75 f0             	pushl  -0x10(%ebp)
  803378:	6a 00                	push   $0x0
  80337a:	e8 c5 f1 ff ff       	call   802544 <sys_page_alloc>
  80337f:	89 c3                	mov    %eax,%ebx
  803381:	83 c4 10             	add    $0x10,%esp
  803384:	85 c0                	test   %eax,%eax
  803386:	0f 88 c3 00 00 00    	js     80344f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80338c:	83 ec 0c             	sub    $0xc,%esp
  80338f:	ff 75 f4             	pushl  -0xc(%ebp)
  803392:	e8 74 f5 ff ff       	call   80290b <fd2data>
  803397:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803399:	83 c4 0c             	add    $0xc,%esp
  80339c:	68 07 04 00 00       	push   $0x407
  8033a1:	50                   	push   %eax
  8033a2:	6a 00                	push   $0x0
  8033a4:	e8 9b f1 ff ff       	call   802544 <sys_page_alloc>
  8033a9:	89 c3                	mov    %eax,%ebx
  8033ab:	83 c4 10             	add    $0x10,%esp
  8033ae:	85 c0                	test   %eax,%eax
  8033b0:	0f 88 89 00 00 00    	js     80343f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8033b6:	83 ec 0c             	sub    $0xc,%esp
  8033b9:	ff 75 f0             	pushl  -0x10(%ebp)
  8033bc:	e8 4a f5 ff ff       	call   80290b <fd2data>
  8033c1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8033c8:	50                   	push   %eax
  8033c9:	6a 00                	push   $0x0
  8033cb:	56                   	push   %esi
  8033cc:	6a 00                	push   $0x0
  8033ce:	e8 b4 f1 ff ff       	call   802587 <sys_page_map>
  8033d3:	89 c3                	mov    %eax,%ebx
  8033d5:	83 c4 20             	add    $0x20,%esp
  8033d8:	85 c0                	test   %eax,%eax
  8033da:	78 55                	js     803431 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8033dc:	8b 15 80 90 80 00    	mov    0x809080,%edx
  8033e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8033e5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8033e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8033ea:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8033f1:	8b 15 80 90 80 00    	mov    0x809080,%edx
  8033f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8033fa:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8033fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8033ff:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  803406:	83 ec 0c             	sub    $0xc,%esp
  803409:	ff 75 f4             	pushl  -0xc(%ebp)
  80340c:	e8 ea f4 ff ff       	call   8028fb <fd2num>
  803411:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803414:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  803416:	83 c4 04             	add    $0x4,%esp
  803419:	ff 75 f0             	pushl  -0x10(%ebp)
  80341c:	e8 da f4 ff ff       	call   8028fb <fd2num>
  803421:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803424:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  803427:	83 c4 10             	add    $0x10,%esp
  80342a:	ba 00 00 00 00       	mov    $0x0,%edx
  80342f:	eb 30                	jmp    803461 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  803431:	83 ec 08             	sub    $0x8,%esp
  803434:	56                   	push   %esi
  803435:	6a 00                	push   $0x0
  803437:	e8 8d f1 ff ff       	call   8025c9 <sys_page_unmap>
  80343c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80343f:	83 ec 08             	sub    $0x8,%esp
  803442:	ff 75 f0             	pushl  -0x10(%ebp)
  803445:	6a 00                	push   $0x0
  803447:	e8 7d f1 ff ff       	call   8025c9 <sys_page_unmap>
  80344c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80344f:	83 ec 08             	sub    $0x8,%esp
  803452:	ff 75 f4             	pushl  -0xc(%ebp)
  803455:	6a 00                	push   $0x0
  803457:	e8 6d f1 ff ff       	call   8025c9 <sys_page_unmap>
  80345c:	83 c4 10             	add    $0x10,%esp
  80345f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  803461:	89 d0                	mov    %edx,%eax
  803463:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803466:	5b                   	pop    %ebx
  803467:	5e                   	pop    %esi
  803468:	5d                   	pop    %ebp
  803469:	c3                   	ret    

0080346a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80346a:	55                   	push   %ebp
  80346b:	89 e5                	mov    %esp,%ebp
  80346d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803470:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803473:	50                   	push   %eax
  803474:	ff 75 08             	pushl  0x8(%ebp)
  803477:	e8 f5 f4 ff ff       	call   802971 <fd_lookup>
  80347c:	83 c4 10             	add    $0x10,%esp
  80347f:	85 c0                	test   %eax,%eax
  803481:	78 18                	js     80349b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  803483:	83 ec 0c             	sub    $0xc,%esp
  803486:	ff 75 f4             	pushl  -0xc(%ebp)
  803489:	e8 7d f4 ff ff       	call   80290b <fd2data>
	return _pipeisclosed(fd, p);
  80348e:	89 c2                	mov    %eax,%edx
  803490:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803493:	e8 21 fd ff ff       	call   8031b9 <_pipeisclosed>
  803498:	83 c4 10             	add    $0x10,%esp
}
  80349b:	c9                   	leave  
  80349c:	c3                   	ret    

0080349d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80349d:	55                   	push   %ebp
  80349e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8034a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8034a5:	5d                   	pop    %ebp
  8034a6:	c3                   	ret    

008034a7 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8034a7:	55                   	push   %ebp
  8034a8:	89 e5                	mov    %esp,%ebp
  8034aa:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8034ad:	68 a1 42 80 00       	push   $0x8042a1
  8034b2:	ff 75 0c             	pushl  0xc(%ebp)
  8034b5:	e8 87 ec ff ff       	call   802141 <strcpy>
	return 0;
}
  8034ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8034bf:	c9                   	leave  
  8034c0:	c3                   	ret    

008034c1 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8034c1:	55                   	push   %ebp
  8034c2:	89 e5                	mov    %esp,%ebp
  8034c4:	57                   	push   %edi
  8034c5:	56                   	push   %esi
  8034c6:	53                   	push   %ebx
  8034c7:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8034cd:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8034d2:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8034d8:	eb 2d                	jmp    803507 <devcons_write+0x46>
		m = n - tot;
  8034da:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8034dd:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8034df:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8034e2:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8034e7:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8034ea:	83 ec 04             	sub    $0x4,%esp
  8034ed:	53                   	push   %ebx
  8034ee:	03 45 0c             	add    0xc(%ebp),%eax
  8034f1:	50                   	push   %eax
  8034f2:	57                   	push   %edi
  8034f3:	e8 db ed ff ff       	call   8022d3 <memmove>
		sys_cputs(buf, m);
  8034f8:	83 c4 08             	add    $0x8,%esp
  8034fb:	53                   	push   %ebx
  8034fc:	57                   	push   %edi
  8034fd:	e8 86 ef ff ff       	call   802488 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803502:	01 de                	add    %ebx,%esi
  803504:	83 c4 10             	add    $0x10,%esp
  803507:	89 f0                	mov    %esi,%eax
  803509:	3b 75 10             	cmp    0x10(%ebp),%esi
  80350c:	72 cc                	jb     8034da <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80350e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803511:	5b                   	pop    %ebx
  803512:	5e                   	pop    %esi
  803513:	5f                   	pop    %edi
  803514:	5d                   	pop    %ebp
  803515:	c3                   	ret    

00803516 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  803516:	55                   	push   %ebp
  803517:	89 e5                	mov    %esp,%ebp
  803519:	83 ec 08             	sub    $0x8,%esp
  80351c:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  803521:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  803525:	74 2a                	je     803551 <devcons_read+0x3b>
  803527:	eb 05                	jmp    80352e <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  803529:	e8 f7 ef ff ff       	call   802525 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80352e:	e8 73 ef ff ff       	call   8024a6 <sys_cgetc>
  803533:	85 c0                	test   %eax,%eax
  803535:	74 f2                	je     803529 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  803537:	85 c0                	test   %eax,%eax
  803539:	78 16                	js     803551 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80353b:	83 f8 04             	cmp    $0x4,%eax
  80353e:	74 0c                	je     80354c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  803540:	8b 55 0c             	mov    0xc(%ebp),%edx
  803543:	88 02                	mov    %al,(%edx)
	return 1;
  803545:	b8 01 00 00 00       	mov    $0x1,%eax
  80354a:	eb 05                	jmp    803551 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80354c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  803551:	c9                   	leave  
  803552:	c3                   	ret    

00803553 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  803553:	55                   	push   %ebp
  803554:	89 e5                	mov    %esp,%ebp
  803556:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  803559:	8b 45 08             	mov    0x8(%ebp),%eax
  80355c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80355f:	6a 01                	push   $0x1
  803561:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803564:	50                   	push   %eax
  803565:	e8 1e ef ff ff       	call   802488 <sys_cputs>
}
  80356a:	83 c4 10             	add    $0x10,%esp
  80356d:	c9                   	leave  
  80356e:	c3                   	ret    

0080356f <getchar>:

int
getchar(void)
{
  80356f:	55                   	push   %ebp
  803570:	89 e5                	mov    %esp,%ebp
  803572:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  803575:	6a 01                	push   $0x1
  803577:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80357a:	50                   	push   %eax
  80357b:	6a 00                	push   $0x0
  80357d:	e8 55 f6 ff ff       	call   802bd7 <read>
	if (r < 0)
  803582:	83 c4 10             	add    $0x10,%esp
  803585:	85 c0                	test   %eax,%eax
  803587:	78 0f                	js     803598 <getchar+0x29>
		return r;
	if (r < 1)
  803589:	85 c0                	test   %eax,%eax
  80358b:	7e 06                	jle    803593 <getchar+0x24>
		return -E_EOF;
	return c;
  80358d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  803591:	eb 05                	jmp    803598 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  803593:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  803598:	c9                   	leave  
  803599:	c3                   	ret    

0080359a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80359a:	55                   	push   %ebp
  80359b:	89 e5                	mov    %esp,%ebp
  80359d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8035a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8035a3:	50                   	push   %eax
  8035a4:	ff 75 08             	pushl  0x8(%ebp)
  8035a7:	e8 c5 f3 ff ff       	call   802971 <fd_lookup>
  8035ac:	83 c4 10             	add    $0x10,%esp
  8035af:	85 c0                	test   %eax,%eax
  8035b1:	78 11                	js     8035c4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8035b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8035b6:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  8035bc:	39 10                	cmp    %edx,(%eax)
  8035be:	0f 94 c0             	sete   %al
  8035c1:	0f b6 c0             	movzbl %al,%eax
}
  8035c4:	c9                   	leave  
  8035c5:	c3                   	ret    

008035c6 <opencons>:

int
opencons(void)
{
  8035c6:	55                   	push   %ebp
  8035c7:	89 e5                	mov    %esp,%ebp
  8035c9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8035cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8035cf:	50                   	push   %eax
  8035d0:	e8 4d f3 ff ff       	call   802922 <fd_alloc>
  8035d5:	83 c4 10             	add    $0x10,%esp
		return r;
  8035d8:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8035da:	85 c0                	test   %eax,%eax
  8035dc:	78 3e                	js     80361c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8035de:	83 ec 04             	sub    $0x4,%esp
  8035e1:	68 07 04 00 00       	push   $0x407
  8035e6:	ff 75 f4             	pushl  -0xc(%ebp)
  8035e9:	6a 00                	push   $0x0
  8035eb:	e8 54 ef ff ff       	call   802544 <sys_page_alloc>
  8035f0:	83 c4 10             	add    $0x10,%esp
		return r;
  8035f3:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8035f5:	85 c0                	test   %eax,%eax
  8035f7:	78 23                	js     80361c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8035f9:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  8035ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803602:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  803604:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803607:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80360e:	83 ec 0c             	sub    $0xc,%esp
  803611:	50                   	push   %eax
  803612:	e8 e4 f2 ff ff       	call   8028fb <fd2num>
  803617:	89 c2                	mov    %eax,%edx
  803619:	83 c4 10             	add    $0x10,%esp
}
  80361c:	89 d0                	mov    %edx,%eax
  80361e:	c9                   	leave  
  80361f:	c3                   	ret    

00803620 <__udivdi3>:
  803620:	55                   	push   %ebp
  803621:	57                   	push   %edi
  803622:	56                   	push   %esi
  803623:	53                   	push   %ebx
  803624:	83 ec 1c             	sub    $0x1c,%esp
  803627:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80362b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80362f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803633:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803637:	85 f6                	test   %esi,%esi
  803639:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80363d:	89 ca                	mov    %ecx,%edx
  80363f:	89 f8                	mov    %edi,%eax
  803641:	75 3d                	jne    803680 <__udivdi3+0x60>
  803643:	39 cf                	cmp    %ecx,%edi
  803645:	0f 87 c5 00 00 00    	ja     803710 <__udivdi3+0xf0>
  80364b:	85 ff                	test   %edi,%edi
  80364d:	89 fd                	mov    %edi,%ebp
  80364f:	75 0b                	jne    80365c <__udivdi3+0x3c>
  803651:	b8 01 00 00 00       	mov    $0x1,%eax
  803656:	31 d2                	xor    %edx,%edx
  803658:	f7 f7                	div    %edi
  80365a:	89 c5                	mov    %eax,%ebp
  80365c:	89 c8                	mov    %ecx,%eax
  80365e:	31 d2                	xor    %edx,%edx
  803660:	f7 f5                	div    %ebp
  803662:	89 c1                	mov    %eax,%ecx
  803664:	89 d8                	mov    %ebx,%eax
  803666:	89 cf                	mov    %ecx,%edi
  803668:	f7 f5                	div    %ebp
  80366a:	89 c3                	mov    %eax,%ebx
  80366c:	89 d8                	mov    %ebx,%eax
  80366e:	89 fa                	mov    %edi,%edx
  803670:	83 c4 1c             	add    $0x1c,%esp
  803673:	5b                   	pop    %ebx
  803674:	5e                   	pop    %esi
  803675:	5f                   	pop    %edi
  803676:	5d                   	pop    %ebp
  803677:	c3                   	ret    
  803678:	90                   	nop
  803679:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803680:	39 ce                	cmp    %ecx,%esi
  803682:	77 74                	ja     8036f8 <__udivdi3+0xd8>
  803684:	0f bd fe             	bsr    %esi,%edi
  803687:	83 f7 1f             	xor    $0x1f,%edi
  80368a:	0f 84 98 00 00 00    	je     803728 <__udivdi3+0x108>
  803690:	bb 20 00 00 00       	mov    $0x20,%ebx
  803695:	89 f9                	mov    %edi,%ecx
  803697:	89 c5                	mov    %eax,%ebp
  803699:	29 fb                	sub    %edi,%ebx
  80369b:	d3 e6                	shl    %cl,%esi
  80369d:	89 d9                	mov    %ebx,%ecx
  80369f:	d3 ed                	shr    %cl,%ebp
  8036a1:	89 f9                	mov    %edi,%ecx
  8036a3:	d3 e0                	shl    %cl,%eax
  8036a5:	09 ee                	or     %ebp,%esi
  8036a7:	89 d9                	mov    %ebx,%ecx
  8036a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8036ad:	89 d5                	mov    %edx,%ebp
  8036af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8036b3:	d3 ed                	shr    %cl,%ebp
  8036b5:	89 f9                	mov    %edi,%ecx
  8036b7:	d3 e2                	shl    %cl,%edx
  8036b9:	89 d9                	mov    %ebx,%ecx
  8036bb:	d3 e8                	shr    %cl,%eax
  8036bd:	09 c2                	or     %eax,%edx
  8036bf:	89 d0                	mov    %edx,%eax
  8036c1:	89 ea                	mov    %ebp,%edx
  8036c3:	f7 f6                	div    %esi
  8036c5:	89 d5                	mov    %edx,%ebp
  8036c7:	89 c3                	mov    %eax,%ebx
  8036c9:	f7 64 24 0c          	mull   0xc(%esp)
  8036cd:	39 d5                	cmp    %edx,%ebp
  8036cf:	72 10                	jb     8036e1 <__udivdi3+0xc1>
  8036d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8036d5:	89 f9                	mov    %edi,%ecx
  8036d7:	d3 e6                	shl    %cl,%esi
  8036d9:	39 c6                	cmp    %eax,%esi
  8036db:	73 07                	jae    8036e4 <__udivdi3+0xc4>
  8036dd:	39 d5                	cmp    %edx,%ebp
  8036df:	75 03                	jne    8036e4 <__udivdi3+0xc4>
  8036e1:	83 eb 01             	sub    $0x1,%ebx
  8036e4:	31 ff                	xor    %edi,%edi
  8036e6:	89 d8                	mov    %ebx,%eax
  8036e8:	89 fa                	mov    %edi,%edx
  8036ea:	83 c4 1c             	add    $0x1c,%esp
  8036ed:	5b                   	pop    %ebx
  8036ee:	5e                   	pop    %esi
  8036ef:	5f                   	pop    %edi
  8036f0:	5d                   	pop    %ebp
  8036f1:	c3                   	ret    
  8036f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8036f8:	31 ff                	xor    %edi,%edi
  8036fa:	31 db                	xor    %ebx,%ebx
  8036fc:	89 d8                	mov    %ebx,%eax
  8036fe:	89 fa                	mov    %edi,%edx
  803700:	83 c4 1c             	add    $0x1c,%esp
  803703:	5b                   	pop    %ebx
  803704:	5e                   	pop    %esi
  803705:	5f                   	pop    %edi
  803706:	5d                   	pop    %ebp
  803707:	c3                   	ret    
  803708:	90                   	nop
  803709:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803710:	89 d8                	mov    %ebx,%eax
  803712:	f7 f7                	div    %edi
  803714:	31 ff                	xor    %edi,%edi
  803716:	89 c3                	mov    %eax,%ebx
  803718:	89 d8                	mov    %ebx,%eax
  80371a:	89 fa                	mov    %edi,%edx
  80371c:	83 c4 1c             	add    $0x1c,%esp
  80371f:	5b                   	pop    %ebx
  803720:	5e                   	pop    %esi
  803721:	5f                   	pop    %edi
  803722:	5d                   	pop    %ebp
  803723:	c3                   	ret    
  803724:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803728:	39 ce                	cmp    %ecx,%esi
  80372a:	72 0c                	jb     803738 <__udivdi3+0x118>
  80372c:	31 db                	xor    %ebx,%ebx
  80372e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803732:	0f 87 34 ff ff ff    	ja     80366c <__udivdi3+0x4c>
  803738:	bb 01 00 00 00       	mov    $0x1,%ebx
  80373d:	e9 2a ff ff ff       	jmp    80366c <__udivdi3+0x4c>
  803742:	66 90                	xchg   %ax,%ax
  803744:	66 90                	xchg   %ax,%ax
  803746:	66 90                	xchg   %ax,%ax
  803748:	66 90                	xchg   %ax,%ax
  80374a:	66 90                	xchg   %ax,%ax
  80374c:	66 90                	xchg   %ax,%ax
  80374e:	66 90                	xchg   %ax,%ax

00803750 <__umoddi3>:
  803750:	55                   	push   %ebp
  803751:	57                   	push   %edi
  803752:	56                   	push   %esi
  803753:	53                   	push   %ebx
  803754:	83 ec 1c             	sub    $0x1c,%esp
  803757:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80375b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80375f:	8b 74 24 34          	mov    0x34(%esp),%esi
  803763:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803767:	85 d2                	test   %edx,%edx
  803769:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80376d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803771:	89 f3                	mov    %esi,%ebx
  803773:	89 3c 24             	mov    %edi,(%esp)
  803776:	89 74 24 04          	mov    %esi,0x4(%esp)
  80377a:	75 1c                	jne    803798 <__umoddi3+0x48>
  80377c:	39 f7                	cmp    %esi,%edi
  80377e:	76 50                	jbe    8037d0 <__umoddi3+0x80>
  803780:	89 c8                	mov    %ecx,%eax
  803782:	89 f2                	mov    %esi,%edx
  803784:	f7 f7                	div    %edi
  803786:	89 d0                	mov    %edx,%eax
  803788:	31 d2                	xor    %edx,%edx
  80378a:	83 c4 1c             	add    $0x1c,%esp
  80378d:	5b                   	pop    %ebx
  80378e:	5e                   	pop    %esi
  80378f:	5f                   	pop    %edi
  803790:	5d                   	pop    %ebp
  803791:	c3                   	ret    
  803792:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803798:	39 f2                	cmp    %esi,%edx
  80379a:	89 d0                	mov    %edx,%eax
  80379c:	77 52                	ja     8037f0 <__umoddi3+0xa0>
  80379e:	0f bd ea             	bsr    %edx,%ebp
  8037a1:	83 f5 1f             	xor    $0x1f,%ebp
  8037a4:	75 5a                	jne    803800 <__umoddi3+0xb0>
  8037a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8037aa:	0f 82 e0 00 00 00    	jb     803890 <__umoddi3+0x140>
  8037b0:	39 0c 24             	cmp    %ecx,(%esp)
  8037b3:	0f 86 d7 00 00 00    	jbe    803890 <__umoddi3+0x140>
  8037b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8037bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8037c1:	83 c4 1c             	add    $0x1c,%esp
  8037c4:	5b                   	pop    %ebx
  8037c5:	5e                   	pop    %esi
  8037c6:	5f                   	pop    %edi
  8037c7:	5d                   	pop    %ebp
  8037c8:	c3                   	ret    
  8037c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8037d0:	85 ff                	test   %edi,%edi
  8037d2:	89 fd                	mov    %edi,%ebp
  8037d4:	75 0b                	jne    8037e1 <__umoddi3+0x91>
  8037d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8037db:	31 d2                	xor    %edx,%edx
  8037dd:	f7 f7                	div    %edi
  8037df:	89 c5                	mov    %eax,%ebp
  8037e1:	89 f0                	mov    %esi,%eax
  8037e3:	31 d2                	xor    %edx,%edx
  8037e5:	f7 f5                	div    %ebp
  8037e7:	89 c8                	mov    %ecx,%eax
  8037e9:	f7 f5                	div    %ebp
  8037eb:	89 d0                	mov    %edx,%eax
  8037ed:	eb 99                	jmp    803788 <__umoddi3+0x38>
  8037ef:	90                   	nop
  8037f0:	89 c8                	mov    %ecx,%eax
  8037f2:	89 f2                	mov    %esi,%edx
  8037f4:	83 c4 1c             	add    $0x1c,%esp
  8037f7:	5b                   	pop    %ebx
  8037f8:	5e                   	pop    %esi
  8037f9:	5f                   	pop    %edi
  8037fa:	5d                   	pop    %ebp
  8037fb:	c3                   	ret    
  8037fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803800:	8b 34 24             	mov    (%esp),%esi
  803803:	bf 20 00 00 00       	mov    $0x20,%edi
  803808:	89 e9                	mov    %ebp,%ecx
  80380a:	29 ef                	sub    %ebp,%edi
  80380c:	d3 e0                	shl    %cl,%eax
  80380e:	89 f9                	mov    %edi,%ecx
  803810:	89 f2                	mov    %esi,%edx
  803812:	d3 ea                	shr    %cl,%edx
  803814:	89 e9                	mov    %ebp,%ecx
  803816:	09 c2                	or     %eax,%edx
  803818:	89 d8                	mov    %ebx,%eax
  80381a:	89 14 24             	mov    %edx,(%esp)
  80381d:	89 f2                	mov    %esi,%edx
  80381f:	d3 e2                	shl    %cl,%edx
  803821:	89 f9                	mov    %edi,%ecx
  803823:	89 54 24 04          	mov    %edx,0x4(%esp)
  803827:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80382b:	d3 e8                	shr    %cl,%eax
  80382d:	89 e9                	mov    %ebp,%ecx
  80382f:	89 c6                	mov    %eax,%esi
  803831:	d3 e3                	shl    %cl,%ebx
  803833:	89 f9                	mov    %edi,%ecx
  803835:	89 d0                	mov    %edx,%eax
  803837:	d3 e8                	shr    %cl,%eax
  803839:	89 e9                	mov    %ebp,%ecx
  80383b:	09 d8                	or     %ebx,%eax
  80383d:	89 d3                	mov    %edx,%ebx
  80383f:	89 f2                	mov    %esi,%edx
  803841:	f7 34 24             	divl   (%esp)
  803844:	89 d6                	mov    %edx,%esi
  803846:	d3 e3                	shl    %cl,%ebx
  803848:	f7 64 24 04          	mull   0x4(%esp)
  80384c:	39 d6                	cmp    %edx,%esi
  80384e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803852:	89 d1                	mov    %edx,%ecx
  803854:	89 c3                	mov    %eax,%ebx
  803856:	72 08                	jb     803860 <__umoddi3+0x110>
  803858:	75 11                	jne    80386b <__umoddi3+0x11b>
  80385a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80385e:	73 0b                	jae    80386b <__umoddi3+0x11b>
  803860:	2b 44 24 04          	sub    0x4(%esp),%eax
  803864:	1b 14 24             	sbb    (%esp),%edx
  803867:	89 d1                	mov    %edx,%ecx
  803869:	89 c3                	mov    %eax,%ebx
  80386b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80386f:	29 da                	sub    %ebx,%edx
  803871:	19 ce                	sbb    %ecx,%esi
  803873:	89 f9                	mov    %edi,%ecx
  803875:	89 f0                	mov    %esi,%eax
  803877:	d3 e0                	shl    %cl,%eax
  803879:	89 e9                	mov    %ebp,%ecx
  80387b:	d3 ea                	shr    %cl,%edx
  80387d:	89 e9                	mov    %ebp,%ecx
  80387f:	d3 ee                	shr    %cl,%esi
  803881:	09 d0                	or     %edx,%eax
  803883:	89 f2                	mov    %esi,%edx
  803885:	83 c4 1c             	add    $0x1c,%esp
  803888:	5b                   	pop    %ebx
  803889:	5e                   	pop    %esi
  80388a:	5f                   	pop    %edi
  80388b:	5d                   	pop    %ebp
  80388c:	c3                   	ret    
  80388d:	8d 76 00             	lea    0x0(%esi),%esi
  803890:	29 f9                	sub    %edi,%ecx
  803892:	19 d6                	sbb    %edx,%esi
  803894:	89 74 24 04          	mov    %esi,0x4(%esp)
  803898:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80389c:	e9 18 ff ff ff       	jmp    8037b9 <__umoddi3+0x69>
