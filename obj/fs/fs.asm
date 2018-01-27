
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
  8000b7:	e8 c3 1a 00 00       	call   801b7f <cprintf>
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
  8000e0:	e8 c1 19 00 00       	call   801aa6 <_panic>
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
  800117:	e8 8a 19 00 00       	call   801aa6 <_panic>

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
  8001db:	e8 c6 18 00 00       	call   801aa6 <_panic>

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
  8002a6:	e8 fb 17 00 00       	call   801aa6 <_panic>
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
  8002c6:	e8 db 17 00 00       	call   801aa6 <_panic>
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
  8002d9:	e8 29 22 00 00       	call   802507 <sys_page_alloc>

	if (r < 0) {
  8002de:	83 c4 10             	add    $0x10,%esp
  8002e1:	85 c0                	test   %eax,%eax
  8002e3:	79 12                	jns    8002f7 <bc_pgfault+0x83>
		panic("page alloc fault - %e", r);
  8002e5:	50                   	push   %eax
  8002e6:	68 b8 3c 80 00       	push   $0x803cb8
  8002eb:	6a 37                	push   $0x37
  8002ed:	68 b0 3c 80 00       	push   $0x803cb0
  8002f2:	e8 af 17 00 00       	call   801aa6 <_panic>
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
  80031e:	e8 83 17 00 00       	call   801aa6 <_panic>
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
  80033e:	e8 07 22 00 00       	call   80254a <sys_page_map>
  800343:	83 c4 20             	add    $0x20,%esp
  800346:	85 c0                	test   %eax,%eax
  800348:	79 12                	jns    80035c <bc_pgfault+0xe8>
		panic("in bc_pgfault, sys_page_map: %e", r);
  80034a:	50                   	push   %eax
  80034b:	68 48 3c 80 00       	push   $0x803c48
  800350:	6a 43                	push   $0x43
  800352:	68 b0 3c 80 00       	push   $0x803cb0
  800357:	e8 4a 17 00 00       	call   801aa6 <_panic>

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
  800382:	e8 1f 17 00 00       	call   801aa6 <_panic>
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
  8003b7:	e8 ea 16 00 00       	call   801aa6 <_panic>
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
  80042e:	e8 73 16 00 00       	call   801aa6 <_panic>

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
  80048d:	e8 b8 20 00 00       	call   80254a <sys_page_map>
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
  8004ab:	e8 88 22 00 00       	call   802738 <set_pgfault_handler>
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
  8004cc:	e8 c5 1d 00 00       	call   802296 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  8004d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004d8:	e8 b1 fe ff ff       	call   80038e <diskaddr>
  8004dd:	83 c4 08             	add    $0x8,%esp
  8004e0:	68 16 3d 80 00       	push   $0x803d16
  8004e5:	50                   	push   %eax
  8004e6:	e8 19 1c 00 00       	call   802104 <strcpy>
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
  80052b:	e8 76 15 00 00       	call   801aa6 <_panic>
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
  80055a:	e8 47 15 00 00       	call   801aa6 <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  80055f:	83 ec 0c             	sub    $0xc,%esp
  800562:	6a 01                	push   $0x1
  800564:	e8 25 fe ff ff       	call   80038e <diskaddr>
  800569:	83 c4 08             	add    $0x8,%esp
  80056c:	50                   	push   %eax
  80056d:	6a 00                	push   $0x0
  80056f:	e8 18 20 00 00       	call   80258c <sys_page_unmap>
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
  8005a0:	e8 01 15 00 00       	call   801aa6 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8005a5:	83 ec 0c             	sub    $0xc,%esp
  8005a8:	6a 01                	push   $0x1
  8005aa:	e8 df fd ff ff       	call   80038e <diskaddr>
  8005af:	83 c4 08             	add    $0x8,%esp
  8005b2:	68 16 3d 80 00       	push   $0x803d16
  8005b7:	50                   	push   %eax
  8005b8:	e8 f1 1b 00 00       	call   8021ae <strcmp>
  8005bd:	83 c4 10             	add    $0x10,%esp
  8005c0:	85 c0                	test   %eax,%eax
  8005c2:	74 16                	je     8005da <bc_init+0x13e>
  8005c4:	68 8c 3c 80 00       	push   $0x803c8c
  8005c9:	68 dd 3b 80 00       	push   $0x803bdd
  8005ce:	6a 7a                	push   $0x7a
  8005d0:	68 b0 3c 80 00       	push   $0x803cb0
  8005d5:	e8 cc 14 00 00       	call   801aa6 <_panic>

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
  8005f4:	e8 9d 1c 00 00       	call   802296 <memmove>
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
  800623:	e8 6e 1c 00 00       	call   802296 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  800628:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80062f:	e8 5a fd ff ff       	call   80038e <diskaddr>
  800634:	83 c4 08             	add    $0x8,%esp
  800637:	68 16 3d 80 00       	push   $0x803d16
  80063c:	50                   	push   %eax
  80063d:	e8 c2 1a 00 00       	call   802104 <strcpy>

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
  800688:	e8 19 14 00 00       	call   801aa6 <_panic>
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
  80069d:	e8 ea 1e 00 00       	call   80258c <sys_page_unmap>
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
  8006d1:	e8 d0 13 00 00       	call   801aa6 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8006d6:	83 ec 0c             	sub    $0xc,%esp
  8006d9:	6a 01                	push   $0x1
  8006db:	e8 ae fc ff ff       	call   80038e <diskaddr>
  8006e0:	83 c4 08             	add    $0x8,%esp
  8006e3:	68 16 3d 80 00       	push   $0x803d16
  8006e8:	50                   	push   %eax
  8006e9:	e8 c0 1a 00 00       	call   8021ae <strcmp>
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	85 c0                	test   %eax,%eax
  8006f3:	74 19                	je     80070e <bc_init+0x272>
  8006f5:	68 8c 3c 80 00       	push   $0x803c8c
  8006fa:	68 dd 3b 80 00       	push   $0x803bdd
  8006ff:	68 96 00 00 00       	push   $0x96
  800704:	68 b0 3c 80 00       	push   $0x803cb0
  800709:	e8 98 13 00 00       	call   801aa6 <_panic>

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
  800728:	e8 69 1b 00 00       	call   802296 <memmove>
	flush_block(diskaddr(1));
  80072d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800734:	e8 55 fc ff ff       	call   80038e <diskaddr>
  800739:	89 04 24             	mov    %eax,(%esp)
  80073c:	e8 cb fc ff ff       	call   80040c <flush_block>

	cprintf("block cache is good\n");
  800741:	c7 04 24 52 3d 80 00 	movl   $0x803d52,(%esp)
  800748:	e8 32 14 00 00       	call   801b7f <cprintf>
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
  800769:	e8 28 1b 00 00       	call   802296 <memmove>
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
  800798:	e8 09 13 00 00       	call   801aa6 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  80079d:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8007a4:	76 14                	jbe    8007ba <check_super+0x44>
		panic("file system is too large");
  8007a6:	83 ec 04             	sub    $0x4,%esp
  8007a9:	68 8d 3d 80 00       	push   $0x803d8d
  8007ae:	6a 12                	push   $0x12
  8007b0:	68 85 3d 80 00       	push   $0x803d85
  8007b5:	e8 ec 12 00 00       	call   801aa6 <_panic>

	cprintf("superblock is good\n");
  8007ba:	83 ec 0c             	sub    $0xc,%esp
  8007bd:	68 a6 3d 80 00       	push   $0x803da6
  8007c2:	e8 b8 13 00 00       	call   801b7f <cprintf>
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
  800826:	e8 7b 12 00 00       	call   801aa6 <_panic>
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
  800982:	e8 1f 11 00 00       	call   801aa6 <_panic>
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
  8009b5:	e8 ec 10 00 00       	call   801aa6 <_panic>
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
  8009dc:	e8 c5 10 00 00       	call   801aa6 <_panic>

	cprintf("bitmap is good\n");
  8009e1:	83 ec 0c             	sub    $0xc,%esp
  8009e4:	68 0d 3e 80 00       	push   $0x803e0d
  8009e9:	e8 91 11 00 00       	call   801b7f <cprintf>
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
  800a9c:	e8 05 10 00 00       	call   801aa6 <_panic>
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
  800b4c:	e8 45 17 00 00       	call   802296 <memmove>
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
  800b9a:	e8 07 0f 00 00       	call   801aa6 <_panic>
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
  800c02:	e8 a7 15 00 00       	call   8021ae <strcmp>
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
  800c6a:	e8 95 14 00 00       	call   802104 <strcpy>
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
  800d91:	e8 00 15 00 00       	call   802296 <memmove>
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
  800e67:	e8 13 0d 00 00       	call   801b7f <cprintf>
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
  800f18:	e8 79 13 00 00       	call   802296 <memmove>
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
  80103d:	e8 64 0a 00 00       	call   801aa6 <_panic>
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
  8010f4:	e8 0b 10 00 00       	call   802104 <strcpy>
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
  8011af:	e8 31 22 00 00       	call   8033e5 <pageref>
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
  8011d4:	e8 2e 13 00 00       	call   802507 <sys_page_alloc>
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
  801205:	e8 3f 10 00 00       	call   802249 <memset>
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
  80124f:	e8 91 21 00 00       	call   8033e5 <pageref>
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
  80139f:	e8 60 0d 00 00       	call   802104 <strcpy>
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
  801429:	e8 68 0e 00 00       	call   802296 <memmove>
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
  801560:	e8 56 15 00 00       	call   802abb <ipc_recv>
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
  801579:	e8 01 06 00 00       	call   801b7f <cprintf>
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
  8015d6:	e8 a4 05 00 00       	call   801b7f <cprintf>
  8015db:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  8015de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  8015e3:	ff 75 f0             	pushl  -0x10(%ebp)
  8015e6:	ff 75 ec             	pushl  -0x14(%ebp)
  8015e9:	50                   	push   %eax
  8015ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8015ed:	e8 44 15 00 00       	call   802b36 <ipc_send>
		sys_page_unmap(0, fsreq);
  8015f2:	83 c4 08             	add    $0x8,%esp
  8015f5:	ff 35 44 50 80 00    	pushl  0x805044
  8015fb:	6a 00                	push   $0x0
  8015fd:	e8 8a 0f 00 00       	call   80258c <sys_page_unmap>
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
  80161f:	e8 5b 05 00 00       	call   801b7f <cprintf>
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
  801637:	e8 43 05 00 00       	call   801b7f <cprintf>

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
  801660:	e8 a2 0e 00 00       	call   802507 <sys_page_alloc>
  801665:	83 c4 10             	add    $0x10,%esp
  801668:	85 c0                	test   %eax,%eax
  80166a:	79 12                	jns    80167e <fs_test+0x2e>
		panic("sys_page_alloc: %e", r);
  80166c:	50                   	push   %eax
  80166d:	68 e4 3e 80 00       	push   $0x803ee4
  801672:	6a 12                	push   $0x12
  801674:	68 f7 3e 80 00       	push   $0x803ef7
  801679:	e8 28 04 00 00       	call   801aa6 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  80167e:	83 ec 04             	sub    $0x4,%esp
  801681:	68 00 10 00 00       	push   $0x1000
  801686:	ff 35 04 a0 80 00    	pushl  0x80a004
  80168c:	68 00 10 00 00       	push   $0x1000
  801691:	e8 00 0c 00 00       	call   802296 <memmove>
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
  8016af:	e8 f2 03 00 00       	call   801aa6 <_panic>
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
  8016f0:	e8 b1 03 00 00       	call   801aa6 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  8016f5:	8b 0d 04 a0 80 00    	mov    0x80a004,%ecx
  8016fb:	85 04 91             	test   %eax,(%ecx,%edx,4)
  8016fe:	74 16                	je     801716 <fs_test+0xc6>
  801700:	68 8c 40 80 00       	push   $0x80408c
  801705:	68 dd 3b 80 00       	push   $0x803bdd
  80170a:	6a 1b                	push   $0x1b
  80170c:	68 f7 3e 80 00       	push   $0x803ef7
  801711:	e8 90 03 00 00       	call   801aa6 <_panic>
	cprintf("alloc_block is good\n");
  801716:	83 ec 0c             	sub    $0xc,%esp
  801719:	68 2c 3f 80 00       	push   $0x803f2c
  80171e:	e8 5c 04 00 00       	call   801b7f <cprintf>

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
  801752:	e8 4f 03 00 00       	call   801aa6 <_panic>
	else if (r == 0)
  801757:	85 c0                	test   %eax,%eax
  801759:	75 14                	jne    80176f <fs_test+0x11f>
		panic("file_open /not-found succeeded!");
  80175b:	83 ec 04             	sub    $0x4,%esp
  80175e:	68 ac 40 80 00       	push   $0x8040ac
  801763:	6a 21                	push   $0x21
  801765:	68 f7 3e 80 00       	push   $0x803ef7
  80176a:	e8 37 03 00 00       	call   801aa6 <_panic>
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
  801794:	e8 0d 03 00 00       	call   801aa6 <_panic>
	cprintf("file_open is good\n");
  801799:	83 ec 0c             	sub    $0xc,%esp
  80179c:	68 85 3f 80 00       	push   $0x803f85
  8017a1:	e8 d9 03 00 00       	call   801b7f <cprintf>

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
  8017cb:	e8 d6 02 00 00       	call   801aa6 <_panic>
	if (strcmp(blk, msg) != 0)
  8017d0:	83 ec 08             	sub    $0x8,%esp
  8017d3:	68 cc 40 80 00       	push   $0x8040cc
  8017d8:	ff 75 f0             	pushl  -0x10(%ebp)
  8017db:	e8 ce 09 00 00       	call   8021ae <strcmp>
  8017e0:	83 c4 10             	add    $0x10,%esp
  8017e3:	85 c0                	test   %eax,%eax
  8017e5:	74 14                	je     8017fb <fs_test+0x1ab>
		panic("file_get_block returned wrong data");
  8017e7:	83 ec 04             	sub    $0x4,%esp
  8017ea:	68 f4 40 80 00       	push   $0x8040f4
  8017ef:	6a 29                	push   $0x29
  8017f1:	68 f7 3e 80 00       	push   $0x803ef7
  8017f6:	e8 ab 02 00 00       	call   801aa6 <_panic>
	cprintf("file_get_block is good\n");
  8017fb:	83 ec 0c             	sub    $0xc,%esp
  8017fe:	68 ab 3f 80 00       	push   $0x803fab
  801803:	e8 77 03 00 00       	call   801b7f <cprintf>

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
  801835:	e8 6c 02 00 00       	call   801aa6 <_panic>
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
  80186a:	e8 37 02 00 00       	call   801aa6 <_panic>
	cprintf("file_flush is good\n");
  80186f:	83 ec 0c             	sub    $0xc,%esp
  801872:	68 df 3f 80 00       	push   $0x803fdf
  801877:	e8 03 03 00 00       	call   801b7f <cprintf>

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
  80189d:	e8 04 02 00 00       	call   801aa6 <_panic>
	assert(f->f_direct[0] == 0);
  8018a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a5:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  8018ac:	74 16                	je     8018c4 <fs_test+0x274>
  8018ae:	68 05 40 80 00       	push   $0x804005
  8018b3:	68 dd 3b 80 00       	push   $0x803bdd
  8018b8:	6a 34                	push   $0x34
  8018ba:	68 f7 3e 80 00       	push   $0x803ef7
  8018bf:	e8 e2 01 00 00       	call   801aa6 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8018c4:	c1 e8 0c             	shr    $0xc,%eax
  8018c7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018ce:	a8 40                	test   $0x40,%al
  8018d0:	74 16                	je     8018e8 <fs_test+0x298>
  8018d2:	68 19 40 80 00       	push   $0x804019
  8018d7:	68 dd 3b 80 00       	push   $0x803bdd
  8018dc:	6a 35                	push   $0x35
  8018de:	68 f7 3e 80 00       	push   $0x803ef7
  8018e3:	e8 be 01 00 00       	call   801aa6 <_panic>
	cprintf("file_truncate is good\n");
  8018e8:	83 ec 0c             	sub    $0xc,%esp
  8018eb:	68 33 40 80 00       	push   $0x804033
  8018f0:	e8 8a 02 00 00       	call   801b7f <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  8018f5:	c7 04 24 cc 40 80 00 	movl   $0x8040cc,(%esp)
  8018fc:	e8 ca 07 00 00       	call   8020cb <strlen>
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
  801921:	e8 80 01 00 00       	call   801aa6 <_panic>
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
  80194b:	e8 56 01 00 00       	call   801aa6 <_panic>
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
  801973:	e8 2e 01 00 00       	call   801aa6 <_panic>
	strcpy(blk, msg);
  801978:	83 ec 08             	sub    $0x8,%esp
  80197b:	68 cc 40 80 00       	push   $0x8040cc
  801980:	ff 75 f0             	pushl  -0x10(%ebp)
  801983:	e8 7c 07 00 00       	call   802104 <strcpy>
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
  8019ad:	e8 f4 00 00 00       	call   801aa6 <_panic>
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
  8019e2:	e8 bf 00 00 00       	call   801aa6 <_panic>
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
  801a09:	e8 98 00 00 00       	call   801aa6 <_panic>
	cprintf("file rewrite is good\n");
  801a0e:	83 ec 0c             	sub    $0xc,%esp
  801a11:	68 73 40 80 00       	push   $0x804073
  801a16:	e8 64 01 00 00       	call   801b7f <cprintf>
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
  801a2e:	e8 96 0a 00 00       	call   8024c9 <sys_getenvid>
  801a33:	25 ff 03 00 00       	and    $0x3ff,%eax
  801a38:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  801a3e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801a43:	a3 0c a0 80 00       	mov    %eax,0x80a00c
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801a48:	85 db                	test   %ebx,%ebx
  801a4a:	7e 07                	jle    801a53 <libmain+0x30>
		binaryname = argv[0];
  801a4c:	8b 06                	mov    (%esi),%eax
  801a4e:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801a53:	83 ec 08             	sub    $0x8,%esp
  801a56:	56                   	push   %esi
  801a57:	53                   	push   %ebx
  801a58:	e8 ad fb ff ff       	call   80160a <umain>

	// exit gracefully
	exit();
  801a5d:	e8 2a 00 00 00       	call   801a8c <exit>
}
  801a62:	83 c4 10             	add    $0x10,%esp
  801a65:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a68:	5b                   	pop    %ebx
  801a69:	5e                   	pop    %esi
  801a6a:	5d                   	pop    %ebp
  801a6b:	c3                   	ret    

00801a6c <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  801a72:	a1 14 a0 80 00       	mov    0x80a014,%eax
	func();
  801a77:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  801a79:	e8 4b 0a 00 00       	call   8024c9 <sys_getenvid>
  801a7e:	83 ec 0c             	sub    $0xc,%esp
  801a81:	50                   	push   %eax
  801a82:	e8 91 0c 00 00       	call   802718 <sys_thread_free>
}
  801a87:	83 c4 10             	add    $0x10,%esp
  801a8a:	c9                   	leave  
  801a8b:	c3                   	ret    

00801a8c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801a8c:	55                   	push   %ebp
  801a8d:	89 e5                	mov    %esp,%ebp
  801a8f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801a92:	e8 0e 13 00 00       	call   802da5 <close_all>
	sys_env_destroy(0);
  801a97:	83 ec 0c             	sub    $0xc,%esp
  801a9a:	6a 00                	push   $0x0
  801a9c:	e8 e7 09 00 00       	call   802488 <sys_env_destroy>
}
  801aa1:	83 c4 10             	add    $0x10,%esp
  801aa4:	c9                   	leave  
  801aa5:	c3                   	ret    

00801aa6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801aa6:	55                   	push   %ebp
  801aa7:	89 e5                	mov    %esp,%ebp
  801aa9:	56                   	push   %esi
  801aaa:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801aab:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801aae:	8b 35 60 90 80 00    	mov    0x809060,%esi
  801ab4:	e8 10 0a 00 00       	call   8024c9 <sys_getenvid>
  801ab9:	83 ec 0c             	sub    $0xc,%esp
  801abc:	ff 75 0c             	pushl  0xc(%ebp)
  801abf:	ff 75 08             	pushl  0x8(%ebp)
  801ac2:	56                   	push   %esi
  801ac3:	50                   	push   %eax
  801ac4:	68 24 41 80 00       	push   $0x804124
  801ac9:	e8 b1 00 00 00       	call   801b7f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ace:	83 c4 18             	add    $0x18,%esp
  801ad1:	53                   	push   %ebx
  801ad2:	ff 75 10             	pushl  0x10(%ebp)
  801ad5:	e8 54 00 00 00       	call   801b2e <vcprintf>
	cprintf("\n");
  801ada:	c7 04 24 1b 3d 80 00 	movl   $0x803d1b,(%esp)
  801ae1:	e8 99 00 00 00       	call   801b7f <cprintf>
  801ae6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ae9:	cc                   	int3   
  801aea:	eb fd                	jmp    801ae9 <_panic+0x43>

00801aec <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801aec:	55                   	push   %ebp
  801aed:	89 e5                	mov    %esp,%ebp
  801aef:	53                   	push   %ebx
  801af0:	83 ec 04             	sub    $0x4,%esp
  801af3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801af6:	8b 13                	mov    (%ebx),%edx
  801af8:	8d 42 01             	lea    0x1(%edx),%eax
  801afb:	89 03                	mov    %eax,(%ebx)
  801afd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b00:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801b04:	3d ff 00 00 00       	cmp    $0xff,%eax
  801b09:	75 1a                	jne    801b25 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801b0b:	83 ec 08             	sub    $0x8,%esp
  801b0e:	68 ff 00 00 00       	push   $0xff
  801b13:	8d 43 08             	lea    0x8(%ebx),%eax
  801b16:	50                   	push   %eax
  801b17:	e8 2f 09 00 00       	call   80244b <sys_cputs>
		b->idx = 0;
  801b1c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b22:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801b25:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801b29:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b2c:	c9                   	leave  
  801b2d:	c3                   	ret    

00801b2e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801b2e:	55                   	push   %ebp
  801b2f:	89 e5                	mov    %esp,%ebp
  801b31:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801b37:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801b3e:	00 00 00 
	b.cnt = 0;
  801b41:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801b48:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801b4b:	ff 75 0c             	pushl  0xc(%ebp)
  801b4e:	ff 75 08             	pushl  0x8(%ebp)
  801b51:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801b57:	50                   	push   %eax
  801b58:	68 ec 1a 80 00       	push   $0x801aec
  801b5d:	e8 54 01 00 00       	call   801cb6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801b62:	83 c4 08             	add    $0x8,%esp
  801b65:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801b6b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801b71:	50                   	push   %eax
  801b72:	e8 d4 08 00 00       	call   80244b <sys_cputs>

	return b.cnt;
}
  801b77:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801b7d:	c9                   	leave  
  801b7e:	c3                   	ret    

00801b7f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801b7f:	55                   	push   %ebp
  801b80:	89 e5                	mov    %esp,%ebp
  801b82:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801b85:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801b88:	50                   	push   %eax
  801b89:	ff 75 08             	pushl  0x8(%ebp)
  801b8c:	e8 9d ff ff ff       	call   801b2e <vcprintf>
	va_end(ap);

	return cnt;
}
  801b91:	c9                   	leave  
  801b92:	c3                   	ret    

00801b93 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801b93:	55                   	push   %ebp
  801b94:	89 e5                	mov    %esp,%ebp
  801b96:	57                   	push   %edi
  801b97:	56                   	push   %esi
  801b98:	53                   	push   %ebx
  801b99:	83 ec 1c             	sub    $0x1c,%esp
  801b9c:	89 c7                	mov    %eax,%edi
  801b9e:	89 d6                	mov    %edx,%esi
  801ba0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ba6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801ba9:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801bac:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801baf:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bb4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801bb7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801bba:	39 d3                	cmp    %edx,%ebx
  801bbc:	72 05                	jb     801bc3 <printnum+0x30>
  801bbe:	39 45 10             	cmp    %eax,0x10(%ebp)
  801bc1:	77 45                	ja     801c08 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801bc3:	83 ec 0c             	sub    $0xc,%esp
  801bc6:	ff 75 18             	pushl  0x18(%ebp)
  801bc9:	8b 45 14             	mov    0x14(%ebp),%eax
  801bcc:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801bcf:	53                   	push   %ebx
  801bd0:	ff 75 10             	pushl  0x10(%ebp)
  801bd3:	83 ec 08             	sub    $0x8,%esp
  801bd6:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bd9:	ff 75 e0             	pushl  -0x20(%ebp)
  801bdc:	ff 75 dc             	pushl  -0x24(%ebp)
  801bdf:	ff 75 d8             	pushl  -0x28(%ebp)
  801be2:	e8 29 1d 00 00       	call   803910 <__udivdi3>
  801be7:	83 c4 18             	add    $0x18,%esp
  801bea:	52                   	push   %edx
  801beb:	50                   	push   %eax
  801bec:	89 f2                	mov    %esi,%edx
  801bee:	89 f8                	mov    %edi,%eax
  801bf0:	e8 9e ff ff ff       	call   801b93 <printnum>
  801bf5:	83 c4 20             	add    $0x20,%esp
  801bf8:	eb 18                	jmp    801c12 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801bfa:	83 ec 08             	sub    $0x8,%esp
  801bfd:	56                   	push   %esi
  801bfe:	ff 75 18             	pushl  0x18(%ebp)
  801c01:	ff d7                	call   *%edi
  801c03:	83 c4 10             	add    $0x10,%esp
  801c06:	eb 03                	jmp    801c0b <printnum+0x78>
  801c08:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801c0b:	83 eb 01             	sub    $0x1,%ebx
  801c0e:	85 db                	test   %ebx,%ebx
  801c10:	7f e8                	jg     801bfa <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801c12:	83 ec 08             	sub    $0x8,%esp
  801c15:	56                   	push   %esi
  801c16:	83 ec 04             	sub    $0x4,%esp
  801c19:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c1c:	ff 75 e0             	pushl  -0x20(%ebp)
  801c1f:	ff 75 dc             	pushl  -0x24(%ebp)
  801c22:	ff 75 d8             	pushl  -0x28(%ebp)
  801c25:	e8 16 1e 00 00       	call   803a40 <__umoddi3>
  801c2a:	83 c4 14             	add    $0x14,%esp
  801c2d:	0f be 80 47 41 80 00 	movsbl 0x804147(%eax),%eax
  801c34:	50                   	push   %eax
  801c35:	ff d7                	call   *%edi
}
  801c37:	83 c4 10             	add    $0x10,%esp
  801c3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c3d:	5b                   	pop    %ebx
  801c3e:	5e                   	pop    %esi
  801c3f:	5f                   	pop    %edi
  801c40:	5d                   	pop    %ebp
  801c41:	c3                   	ret    

00801c42 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801c42:	55                   	push   %ebp
  801c43:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801c45:	83 fa 01             	cmp    $0x1,%edx
  801c48:	7e 0e                	jle    801c58 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801c4a:	8b 10                	mov    (%eax),%edx
  801c4c:	8d 4a 08             	lea    0x8(%edx),%ecx
  801c4f:	89 08                	mov    %ecx,(%eax)
  801c51:	8b 02                	mov    (%edx),%eax
  801c53:	8b 52 04             	mov    0x4(%edx),%edx
  801c56:	eb 22                	jmp    801c7a <getuint+0x38>
	else if (lflag)
  801c58:	85 d2                	test   %edx,%edx
  801c5a:	74 10                	je     801c6c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801c5c:	8b 10                	mov    (%eax),%edx
  801c5e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801c61:	89 08                	mov    %ecx,(%eax)
  801c63:	8b 02                	mov    (%edx),%eax
  801c65:	ba 00 00 00 00       	mov    $0x0,%edx
  801c6a:	eb 0e                	jmp    801c7a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801c6c:	8b 10                	mov    (%eax),%edx
  801c6e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801c71:	89 08                	mov    %ecx,(%eax)
  801c73:	8b 02                	mov    (%edx),%eax
  801c75:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801c7a:	5d                   	pop    %ebp
  801c7b:	c3                   	ret    

00801c7c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801c7c:	55                   	push   %ebp
  801c7d:	89 e5                	mov    %esp,%ebp
  801c7f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801c82:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801c86:	8b 10                	mov    (%eax),%edx
  801c88:	3b 50 04             	cmp    0x4(%eax),%edx
  801c8b:	73 0a                	jae    801c97 <sprintputch+0x1b>
		*b->buf++ = ch;
  801c8d:	8d 4a 01             	lea    0x1(%edx),%ecx
  801c90:	89 08                	mov    %ecx,(%eax)
  801c92:	8b 45 08             	mov    0x8(%ebp),%eax
  801c95:	88 02                	mov    %al,(%edx)
}
  801c97:	5d                   	pop    %ebp
  801c98:	c3                   	ret    

00801c99 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801c99:	55                   	push   %ebp
  801c9a:	89 e5                	mov    %esp,%ebp
  801c9c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801c9f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801ca2:	50                   	push   %eax
  801ca3:	ff 75 10             	pushl  0x10(%ebp)
  801ca6:	ff 75 0c             	pushl  0xc(%ebp)
  801ca9:	ff 75 08             	pushl  0x8(%ebp)
  801cac:	e8 05 00 00 00       	call   801cb6 <vprintfmt>
	va_end(ap);
}
  801cb1:	83 c4 10             	add    $0x10,%esp
  801cb4:	c9                   	leave  
  801cb5:	c3                   	ret    

00801cb6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801cb6:	55                   	push   %ebp
  801cb7:	89 e5                	mov    %esp,%ebp
  801cb9:	57                   	push   %edi
  801cba:	56                   	push   %esi
  801cbb:	53                   	push   %ebx
  801cbc:	83 ec 2c             	sub    $0x2c,%esp
  801cbf:	8b 75 08             	mov    0x8(%ebp),%esi
  801cc2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801cc5:	8b 7d 10             	mov    0x10(%ebp),%edi
  801cc8:	eb 12                	jmp    801cdc <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801cca:	85 c0                	test   %eax,%eax
  801ccc:	0f 84 89 03 00 00    	je     80205b <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801cd2:	83 ec 08             	sub    $0x8,%esp
  801cd5:	53                   	push   %ebx
  801cd6:	50                   	push   %eax
  801cd7:	ff d6                	call   *%esi
  801cd9:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801cdc:	83 c7 01             	add    $0x1,%edi
  801cdf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801ce3:	83 f8 25             	cmp    $0x25,%eax
  801ce6:	75 e2                	jne    801cca <vprintfmt+0x14>
  801ce8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801cec:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801cf3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801cfa:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801d01:	ba 00 00 00 00       	mov    $0x0,%edx
  801d06:	eb 07                	jmp    801d0f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d08:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801d0b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d0f:	8d 47 01             	lea    0x1(%edi),%eax
  801d12:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d15:	0f b6 07             	movzbl (%edi),%eax
  801d18:	0f b6 c8             	movzbl %al,%ecx
  801d1b:	83 e8 23             	sub    $0x23,%eax
  801d1e:	3c 55                	cmp    $0x55,%al
  801d20:	0f 87 1a 03 00 00    	ja     802040 <vprintfmt+0x38a>
  801d26:	0f b6 c0             	movzbl %al,%eax
  801d29:	ff 24 85 80 42 80 00 	jmp    *0x804280(,%eax,4)
  801d30:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801d33:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801d37:	eb d6                	jmp    801d0f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d39:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d3c:	b8 00 00 00 00       	mov    $0x0,%eax
  801d41:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801d44:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801d47:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801d4b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801d4e:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801d51:	83 fa 09             	cmp    $0x9,%edx
  801d54:	77 39                	ja     801d8f <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801d56:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801d59:	eb e9                	jmp    801d44 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801d5b:	8b 45 14             	mov    0x14(%ebp),%eax
  801d5e:	8d 48 04             	lea    0x4(%eax),%ecx
  801d61:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801d64:	8b 00                	mov    (%eax),%eax
  801d66:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d69:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801d6c:	eb 27                	jmp    801d95 <vprintfmt+0xdf>
  801d6e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d71:	85 c0                	test   %eax,%eax
  801d73:	b9 00 00 00 00       	mov    $0x0,%ecx
  801d78:	0f 49 c8             	cmovns %eax,%ecx
  801d7b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d7e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d81:	eb 8c                	jmp    801d0f <vprintfmt+0x59>
  801d83:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801d86:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801d8d:	eb 80                	jmp    801d0f <vprintfmt+0x59>
  801d8f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801d92:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801d95:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801d99:	0f 89 70 ff ff ff    	jns    801d0f <vprintfmt+0x59>
				width = precision, precision = -1;
  801d9f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801da2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801da5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801dac:	e9 5e ff ff ff       	jmp    801d0f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801db1:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801db4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801db7:	e9 53 ff ff ff       	jmp    801d0f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801dbc:	8b 45 14             	mov    0x14(%ebp),%eax
  801dbf:	8d 50 04             	lea    0x4(%eax),%edx
  801dc2:	89 55 14             	mov    %edx,0x14(%ebp)
  801dc5:	83 ec 08             	sub    $0x8,%esp
  801dc8:	53                   	push   %ebx
  801dc9:	ff 30                	pushl  (%eax)
  801dcb:	ff d6                	call   *%esi
			break;
  801dcd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801dd0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801dd3:	e9 04 ff ff ff       	jmp    801cdc <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801dd8:	8b 45 14             	mov    0x14(%ebp),%eax
  801ddb:	8d 50 04             	lea    0x4(%eax),%edx
  801dde:	89 55 14             	mov    %edx,0x14(%ebp)
  801de1:	8b 00                	mov    (%eax),%eax
  801de3:	99                   	cltd   
  801de4:	31 d0                	xor    %edx,%eax
  801de6:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801de8:	83 f8 0f             	cmp    $0xf,%eax
  801deb:	7f 0b                	jg     801df8 <vprintfmt+0x142>
  801ded:	8b 14 85 e0 43 80 00 	mov    0x8043e0(,%eax,4),%edx
  801df4:	85 d2                	test   %edx,%edx
  801df6:	75 18                	jne    801e10 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801df8:	50                   	push   %eax
  801df9:	68 5f 41 80 00       	push   $0x80415f
  801dfe:	53                   	push   %ebx
  801dff:	56                   	push   %esi
  801e00:	e8 94 fe ff ff       	call   801c99 <printfmt>
  801e05:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e08:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801e0b:	e9 cc fe ff ff       	jmp    801cdc <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801e10:	52                   	push   %edx
  801e11:	68 ef 3b 80 00       	push   $0x803bef
  801e16:	53                   	push   %ebx
  801e17:	56                   	push   %esi
  801e18:	e8 7c fe ff ff       	call   801c99 <printfmt>
  801e1d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e20:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e23:	e9 b4 fe ff ff       	jmp    801cdc <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801e28:	8b 45 14             	mov    0x14(%ebp),%eax
  801e2b:	8d 50 04             	lea    0x4(%eax),%edx
  801e2e:	89 55 14             	mov    %edx,0x14(%ebp)
  801e31:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801e33:	85 ff                	test   %edi,%edi
  801e35:	b8 58 41 80 00       	mov    $0x804158,%eax
  801e3a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801e3d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801e41:	0f 8e 94 00 00 00    	jle    801edb <vprintfmt+0x225>
  801e47:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801e4b:	0f 84 98 00 00 00    	je     801ee9 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801e51:	83 ec 08             	sub    $0x8,%esp
  801e54:	ff 75 d0             	pushl  -0x30(%ebp)
  801e57:	57                   	push   %edi
  801e58:	e8 86 02 00 00       	call   8020e3 <strnlen>
  801e5d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801e60:	29 c1                	sub    %eax,%ecx
  801e62:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801e65:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801e68:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801e6c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e6f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801e72:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801e74:	eb 0f                	jmp    801e85 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801e76:	83 ec 08             	sub    $0x8,%esp
  801e79:	53                   	push   %ebx
  801e7a:	ff 75 e0             	pushl  -0x20(%ebp)
  801e7d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801e7f:	83 ef 01             	sub    $0x1,%edi
  801e82:	83 c4 10             	add    $0x10,%esp
  801e85:	85 ff                	test   %edi,%edi
  801e87:	7f ed                	jg     801e76 <vprintfmt+0x1c0>
  801e89:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801e8c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801e8f:	85 c9                	test   %ecx,%ecx
  801e91:	b8 00 00 00 00       	mov    $0x0,%eax
  801e96:	0f 49 c1             	cmovns %ecx,%eax
  801e99:	29 c1                	sub    %eax,%ecx
  801e9b:	89 75 08             	mov    %esi,0x8(%ebp)
  801e9e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801ea1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801ea4:	89 cb                	mov    %ecx,%ebx
  801ea6:	eb 4d                	jmp    801ef5 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801ea8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801eac:	74 1b                	je     801ec9 <vprintfmt+0x213>
  801eae:	0f be c0             	movsbl %al,%eax
  801eb1:	83 e8 20             	sub    $0x20,%eax
  801eb4:	83 f8 5e             	cmp    $0x5e,%eax
  801eb7:	76 10                	jbe    801ec9 <vprintfmt+0x213>
					putch('?', putdat);
  801eb9:	83 ec 08             	sub    $0x8,%esp
  801ebc:	ff 75 0c             	pushl  0xc(%ebp)
  801ebf:	6a 3f                	push   $0x3f
  801ec1:	ff 55 08             	call   *0x8(%ebp)
  801ec4:	83 c4 10             	add    $0x10,%esp
  801ec7:	eb 0d                	jmp    801ed6 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801ec9:	83 ec 08             	sub    $0x8,%esp
  801ecc:	ff 75 0c             	pushl  0xc(%ebp)
  801ecf:	52                   	push   %edx
  801ed0:	ff 55 08             	call   *0x8(%ebp)
  801ed3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801ed6:	83 eb 01             	sub    $0x1,%ebx
  801ed9:	eb 1a                	jmp    801ef5 <vprintfmt+0x23f>
  801edb:	89 75 08             	mov    %esi,0x8(%ebp)
  801ede:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801ee1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801ee4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801ee7:	eb 0c                	jmp    801ef5 <vprintfmt+0x23f>
  801ee9:	89 75 08             	mov    %esi,0x8(%ebp)
  801eec:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801eef:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801ef2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801ef5:	83 c7 01             	add    $0x1,%edi
  801ef8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801efc:	0f be d0             	movsbl %al,%edx
  801eff:	85 d2                	test   %edx,%edx
  801f01:	74 23                	je     801f26 <vprintfmt+0x270>
  801f03:	85 f6                	test   %esi,%esi
  801f05:	78 a1                	js     801ea8 <vprintfmt+0x1f2>
  801f07:	83 ee 01             	sub    $0x1,%esi
  801f0a:	79 9c                	jns    801ea8 <vprintfmt+0x1f2>
  801f0c:	89 df                	mov    %ebx,%edi
  801f0e:	8b 75 08             	mov    0x8(%ebp),%esi
  801f11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801f14:	eb 18                	jmp    801f2e <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801f16:	83 ec 08             	sub    $0x8,%esp
  801f19:	53                   	push   %ebx
  801f1a:	6a 20                	push   $0x20
  801f1c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801f1e:	83 ef 01             	sub    $0x1,%edi
  801f21:	83 c4 10             	add    $0x10,%esp
  801f24:	eb 08                	jmp    801f2e <vprintfmt+0x278>
  801f26:	89 df                	mov    %ebx,%edi
  801f28:	8b 75 08             	mov    0x8(%ebp),%esi
  801f2b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801f2e:	85 ff                	test   %edi,%edi
  801f30:	7f e4                	jg     801f16 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f32:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801f35:	e9 a2 fd ff ff       	jmp    801cdc <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801f3a:	83 fa 01             	cmp    $0x1,%edx
  801f3d:	7e 16                	jle    801f55 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801f3f:	8b 45 14             	mov    0x14(%ebp),%eax
  801f42:	8d 50 08             	lea    0x8(%eax),%edx
  801f45:	89 55 14             	mov    %edx,0x14(%ebp)
  801f48:	8b 50 04             	mov    0x4(%eax),%edx
  801f4b:	8b 00                	mov    (%eax),%eax
  801f4d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f50:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801f53:	eb 32                	jmp    801f87 <vprintfmt+0x2d1>
	else if (lflag)
  801f55:	85 d2                	test   %edx,%edx
  801f57:	74 18                	je     801f71 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801f59:	8b 45 14             	mov    0x14(%ebp),%eax
  801f5c:	8d 50 04             	lea    0x4(%eax),%edx
  801f5f:	89 55 14             	mov    %edx,0x14(%ebp)
  801f62:	8b 00                	mov    (%eax),%eax
  801f64:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f67:	89 c1                	mov    %eax,%ecx
  801f69:	c1 f9 1f             	sar    $0x1f,%ecx
  801f6c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801f6f:	eb 16                	jmp    801f87 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801f71:	8b 45 14             	mov    0x14(%ebp),%eax
  801f74:	8d 50 04             	lea    0x4(%eax),%edx
  801f77:	89 55 14             	mov    %edx,0x14(%ebp)
  801f7a:	8b 00                	mov    (%eax),%eax
  801f7c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801f7f:	89 c1                	mov    %eax,%ecx
  801f81:	c1 f9 1f             	sar    $0x1f,%ecx
  801f84:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801f87:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801f8a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801f8d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801f92:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801f96:	79 74                	jns    80200c <vprintfmt+0x356>
				putch('-', putdat);
  801f98:	83 ec 08             	sub    $0x8,%esp
  801f9b:	53                   	push   %ebx
  801f9c:	6a 2d                	push   $0x2d
  801f9e:	ff d6                	call   *%esi
				num = -(long long) num;
  801fa0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801fa3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801fa6:	f7 d8                	neg    %eax
  801fa8:	83 d2 00             	adc    $0x0,%edx
  801fab:	f7 da                	neg    %edx
  801fad:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801fb0:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801fb5:	eb 55                	jmp    80200c <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801fb7:	8d 45 14             	lea    0x14(%ebp),%eax
  801fba:	e8 83 fc ff ff       	call   801c42 <getuint>
			base = 10;
  801fbf:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801fc4:	eb 46                	jmp    80200c <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801fc6:	8d 45 14             	lea    0x14(%ebp),%eax
  801fc9:	e8 74 fc ff ff       	call   801c42 <getuint>
			base = 8;
  801fce:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801fd3:	eb 37                	jmp    80200c <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801fd5:	83 ec 08             	sub    $0x8,%esp
  801fd8:	53                   	push   %ebx
  801fd9:	6a 30                	push   $0x30
  801fdb:	ff d6                	call   *%esi
			putch('x', putdat);
  801fdd:	83 c4 08             	add    $0x8,%esp
  801fe0:	53                   	push   %ebx
  801fe1:	6a 78                	push   $0x78
  801fe3:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801fe5:	8b 45 14             	mov    0x14(%ebp),%eax
  801fe8:	8d 50 04             	lea    0x4(%eax),%edx
  801feb:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801fee:	8b 00                	mov    (%eax),%eax
  801ff0:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801ff5:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801ff8:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801ffd:	eb 0d                	jmp    80200c <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801fff:	8d 45 14             	lea    0x14(%ebp),%eax
  802002:	e8 3b fc ff ff       	call   801c42 <getuint>
			base = 16;
  802007:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80200c:	83 ec 0c             	sub    $0xc,%esp
  80200f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  802013:	57                   	push   %edi
  802014:	ff 75 e0             	pushl  -0x20(%ebp)
  802017:	51                   	push   %ecx
  802018:	52                   	push   %edx
  802019:	50                   	push   %eax
  80201a:	89 da                	mov    %ebx,%edx
  80201c:	89 f0                	mov    %esi,%eax
  80201e:	e8 70 fb ff ff       	call   801b93 <printnum>
			break;
  802023:	83 c4 20             	add    $0x20,%esp
  802026:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  802029:	e9 ae fc ff ff       	jmp    801cdc <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80202e:	83 ec 08             	sub    $0x8,%esp
  802031:	53                   	push   %ebx
  802032:	51                   	push   %ecx
  802033:	ff d6                	call   *%esi
			break;
  802035:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  802038:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80203b:	e9 9c fc ff ff       	jmp    801cdc <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  802040:	83 ec 08             	sub    $0x8,%esp
  802043:	53                   	push   %ebx
  802044:	6a 25                	push   $0x25
  802046:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  802048:	83 c4 10             	add    $0x10,%esp
  80204b:	eb 03                	jmp    802050 <vprintfmt+0x39a>
  80204d:	83 ef 01             	sub    $0x1,%edi
  802050:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  802054:	75 f7                	jne    80204d <vprintfmt+0x397>
  802056:	e9 81 fc ff ff       	jmp    801cdc <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80205b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80205e:	5b                   	pop    %ebx
  80205f:	5e                   	pop    %esi
  802060:	5f                   	pop    %edi
  802061:	5d                   	pop    %ebp
  802062:	c3                   	ret    

00802063 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  802063:	55                   	push   %ebp
  802064:	89 e5                	mov    %esp,%ebp
  802066:	83 ec 18             	sub    $0x18,%esp
  802069:	8b 45 08             	mov    0x8(%ebp),%eax
  80206c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80206f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802072:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  802076:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  802079:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  802080:	85 c0                	test   %eax,%eax
  802082:	74 26                	je     8020aa <vsnprintf+0x47>
  802084:	85 d2                	test   %edx,%edx
  802086:	7e 22                	jle    8020aa <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  802088:	ff 75 14             	pushl  0x14(%ebp)
  80208b:	ff 75 10             	pushl  0x10(%ebp)
  80208e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  802091:	50                   	push   %eax
  802092:	68 7c 1c 80 00       	push   $0x801c7c
  802097:	e8 1a fc ff ff       	call   801cb6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80209c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80209f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8020a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a5:	83 c4 10             	add    $0x10,%esp
  8020a8:	eb 05                	jmp    8020af <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8020aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8020af:	c9                   	leave  
  8020b0:	c3                   	ret    

008020b1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8020b1:	55                   	push   %ebp
  8020b2:	89 e5                	mov    %esp,%ebp
  8020b4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8020b7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8020ba:	50                   	push   %eax
  8020bb:	ff 75 10             	pushl  0x10(%ebp)
  8020be:	ff 75 0c             	pushl  0xc(%ebp)
  8020c1:	ff 75 08             	pushl  0x8(%ebp)
  8020c4:	e8 9a ff ff ff       	call   802063 <vsnprintf>
	va_end(ap);

	return rc;
}
  8020c9:	c9                   	leave  
  8020ca:	c3                   	ret    

008020cb <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8020cb:	55                   	push   %ebp
  8020cc:	89 e5                	mov    %esp,%ebp
  8020ce:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8020d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8020d6:	eb 03                	jmp    8020db <strlen+0x10>
		n++;
  8020d8:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8020db:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8020df:	75 f7                	jne    8020d8 <strlen+0xd>
		n++;
	return n;
}
  8020e1:	5d                   	pop    %ebp
  8020e2:	c3                   	ret    

008020e3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8020e3:	55                   	push   %ebp
  8020e4:	89 e5                	mov    %esp,%ebp
  8020e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020e9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8020ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8020f1:	eb 03                	jmp    8020f6 <strnlen+0x13>
		n++;
  8020f3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8020f6:	39 c2                	cmp    %eax,%edx
  8020f8:	74 08                	je     802102 <strnlen+0x1f>
  8020fa:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8020fe:	75 f3                	jne    8020f3 <strnlen+0x10>
  802100:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  802102:	5d                   	pop    %ebp
  802103:	c3                   	ret    

00802104 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  802104:	55                   	push   %ebp
  802105:	89 e5                	mov    %esp,%ebp
  802107:	53                   	push   %ebx
  802108:	8b 45 08             	mov    0x8(%ebp),%eax
  80210b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80210e:	89 c2                	mov    %eax,%edx
  802110:	83 c2 01             	add    $0x1,%edx
  802113:	83 c1 01             	add    $0x1,%ecx
  802116:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80211a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80211d:	84 db                	test   %bl,%bl
  80211f:	75 ef                	jne    802110 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  802121:	5b                   	pop    %ebx
  802122:	5d                   	pop    %ebp
  802123:	c3                   	ret    

00802124 <strcat>:

char *
strcat(char *dst, const char *src)
{
  802124:	55                   	push   %ebp
  802125:	89 e5                	mov    %esp,%ebp
  802127:	53                   	push   %ebx
  802128:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80212b:	53                   	push   %ebx
  80212c:	e8 9a ff ff ff       	call   8020cb <strlen>
  802131:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  802134:	ff 75 0c             	pushl  0xc(%ebp)
  802137:	01 d8                	add    %ebx,%eax
  802139:	50                   	push   %eax
  80213a:	e8 c5 ff ff ff       	call   802104 <strcpy>
	return dst;
}
  80213f:	89 d8                	mov    %ebx,%eax
  802141:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802144:	c9                   	leave  
  802145:	c3                   	ret    

00802146 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  802146:	55                   	push   %ebp
  802147:	89 e5                	mov    %esp,%ebp
  802149:	56                   	push   %esi
  80214a:	53                   	push   %ebx
  80214b:	8b 75 08             	mov    0x8(%ebp),%esi
  80214e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802151:	89 f3                	mov    %esi,%ebx
  802153:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802156:	89 f2                	mov    %esi,%edx
  802158:	eb 0f                	jmp    802169 <strncpy+0x23>
		*dst++ = *src;
  80215a:	83 c2 01             	add    $0x1,%edx
  80215d:	0f b6 01             	movzbl (%ecx),%eax
  802160:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  802163:	80 39 01             	cmpb   $0x1,(%ecx)
  802166:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802169:	39 da                	cmp    %ebx,%edx
  80216b:	75 ed                	jne    80215a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80216d:	89 f0                	mov    %esi,%eax
  80216f:	5b                   	pop    %ebx
  802170:	5e                   	pop    %esi
  802171:	5d                   	pop    %ebp
  802172:	c3                   	ret    

00802173 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  802173:	55                   	push   %ebp
  802174:	89 e5                	mov    %esp,%ebp
  802176:	56                   	push   %esi
  802177:	53                   	push   %ebx
  802178:	8b 75 08             	mov    0x8(%ebp),%esi
  80217b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80217e:	8b 55 10             	mov    0x10(%ebp),%edx
  802181:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  802183:	85 d2                	test   %edx,%edx
  802185:	74 21                	je     8021a8 <strlcpy+0x35>
  802187:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80218b:	89 f2                	mov    %esi,%edx
  80218d:	eb 09                	jmp    802198 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80218f:	83 c2 01             	add    $0x1,%edx
  802192:	83 c1 01             	add    $0x1,%ecx
  802195:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  802198:	39 c2                	cmp    %eax,%edx
  80219a:	74 09                	je     8021a5 <strlcpy+0x32>
  80219c:	0f b6 19             	movzbl (%ecx),%ebx
  80219f:	84 db                	test   %bl,%bl
  8021a1:	75 ec                	jne    80218f <strlcpy+0x1c>
  8021a3:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8021a5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8021a8:	29 f0                	sub    %esi,%eax
}
  8021aa:	5b                   	pop    %ebx
  8021ab:	5e                   	pop    %esi
  8021ac:	5d                   	pop    %ebp
  8021ad:	c3                   	ret    

008021ae <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8021ae:	55                   	push   %ebp
  8021af:	89 e5                	mov    %esp,%ebp
  8021b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021b4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8021b7:	eb 06                	jmp    8021bf <strcmp+0x11>
		p++, q++;
  8021b9:	83 c1 01             	add    $0x1,%ecx
  8021bc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8021bf:	0f b6 01             	movzbl (%ecx),%eax
  8021c2:	84 c0                	test   %al,%al
  8021c4:	74 04                	je     8021ca <strcmp+0x1c>
  8021c6:	3a 02                	cmp    (%edx),%al
  8021c8:	74 ef                	je     8021b9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8021ca:	0f b6 c0             	movzbl %al,%eax
  8021cd:	0f b6 12             	movzbl (%edx),%edx
  8021d0:	29 d0                	sub    %edx,%eax
}
  8021d2:	5d                   	pop    %ebp
  8021d3:	c3                   	ret    

008021d4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8021d4:	55                   	push   %ebp
  8021d5:	89 e5                	mov    %esp,%ebp
  8021d7:	53                   	push   %ebx
  8021d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8021db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021de:	89 c3                	mov    %eax,%ebx
  8021e0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8021e3:	eb 06                	jmp    8021eb <strncmp+0x17>
		n--, p++, q++;
  8021e5:	83 c0 01             	add    $0x1,%eax
  8021e8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8021eb:	39 d8                	cmp    %ebx,%eax
  8021ed:	74 15                	je     802204 <strncmp+0x30>
  8021ef:	0f b6 08             	movzbl (%eax),%ecx
  8021f2:	84 c9                	test   %cl,%cl
  8021f4:	74 04                	je     8021fa <strncmp+0x26>
  8021f6:	3a 0a                	cmp    (%edx),%cl
  8021f8:	74 eb                	je     8021e5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8021fa:	0f b6 00             	movzbl (%eax),%eax
  8021fd:	0f b6 12             	movzbl (%edx),%edx
  802200:	29 d0                	sub    %edx,%eax
  802202:	eb 05                	jmp    802209 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  802204:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  802209:	5b                   	pop    %ebx
  80220a:	5d                   	pop    %ebp
  80220b:	c3                   	ret    

0080220c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80220c:	55                   	push   %ebp
  80220d:	89 e5                	mov    %esp,%ebp
  80220f:	8b 45 08             	mov    0x8(%ebp),%eax
  802212:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802216:	eb 07                	jmp    80221f <strchr+0x13>
		if (*s == c)
  802218:	38 ca                	cmp    %cl,%dl
  80221a:	74 0f                	je     80222b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80221c:	83 c0 01             	add    $0x1,%eax
  80221f:	0f b6 10             	movzbl (%eax),%edx
  802222:	84 d2                	test   %dl,%dl
  802224:	75 f2                	jne    802218 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  802226:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80222b:	5d                   	pop    %ebp
  80222c:	c3                   	ret    

0080222d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80222d:	55                   	push   %ebp
  80222e:	89 e5                	mov    %esp,%ebp
  802230:	8b 45 08             	mov    0x8(%ebp),%eax
  802233:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802237:	eb 03                	jmp    80223c <strfind+0xf>
  802239:	83 c0 01             	add    $0x1,%eax
  80223c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80223f:	38 ca                	cmp    %cl,%dl
  802241:	74 04                	je     802247 <strfind+0x1a>
  802243:	84 d2                	test   %dl,%dl
  802245:	75 f2                	jne    802239 <strfind+0xc>
			break;
	return (char *) s;
}
  802247:	5d                   	pop    %ebp
  802248:	c3                   	ret    

00802249 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  802249:	55                   	push   %ebp
  80224a:	89 e5                	mov    %esp,%ebp
  80224c:	57                   	push   %edi
  80224d:	56                   	push   %esi
  80224e:	53                   	push   %ebx
  80224f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802252:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  802255:	85 c9                	test   %ecx,%ecx
  802257:	74 36                	je     80228f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  802259:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80225f:	75 28                	jne    802289 <memset+0x40>
  802261:	f6 c1 03             	test   $0x3,%cl
  802264:	75 23                	jne    802289 <memset+0x40>
		c &= 0xFF;
  802266:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80226a:	89 d3                	mov    %edx,%ebx
  80226c:	c1 e3 08             	shl    $0x8,%ebx
  80226f:	89 d6                	mov    %edx,%esi
  802271:	c1 e6 18             	shl    $0x18,%esi
  802274:	89 d0                	mov    %edx,%eax
  802276:	c1 e0 10             	shl    $0x10,%eax
  802279:	09 f0                	or     %esi,%eax
  80227b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80227d:	89 d8                	mov    %ebx,%eax
  80227f:	09 d0                	or     %edx,%eax
  802281:	c1 e9 02             	shr    $0x2,%ecx
  802284:	fc                   	cld    
  802285:	f3 ab                	rep stos %eax,%es:(%edi)
  802287:	eb 06                	jmp    80228f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802289:	8b 45 0c             	mov    0xc(%ebp),%eax
  80228c:	fc                   	cld    
  80228d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80228f:	89 f8                	mov    %edi,%eax
  802291:	5b                   	pop    %ebx
  802292:	5e                   	pop    %esi
  802293:	5f                   	pop    %edi
  802294:	5d                   	pop    %ebp
  802295:	c3                   	ret    

00802296 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802296:	55                   	push   %ebp
  802297:	89 e5                	mov    %esp,%ebp
  802299:	57                   	push   %edi
  80229a:	56                   	push   %esi
  80229b:	8b 45 08             	mov    0x8(%ebp),%eax
  80229e:	8b 75 0c             	mov    0xc(%ebp),%esi
  8022a1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8022a4:	39 c6                	cmp    %eax,%esi
  8022a6:	73 35                	jae    8022dd <memmove+0x47>
  8022a8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8022ab:	39 d0                	cmp    %edx,%eax
  8022ad:	73 2e                	jae    8022dd <memmove+0x47>
		s += n;
		d += n;
  8022af:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8022b2:	89 d6                	mov    %edx,%esi
  8022b4:	09 fe                	or     %edi,%esi
  8022b6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8022bc:	75 13                	jne    8022d1 <memmove+0x3b>
  8022be:	f6 c1 03             	test   $0x3,%cl
  8022c1:	75 0e                	jne    8022d1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8022c3:	83 ef 04             	sub    $0x4,%edi
  8022c6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8022c9:	c1 e9 02             	shr    $0x2,%ecx
  8022cc:	fd                   	std    
  8022cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8022cf:	eb 09                	jmp    8022da <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8022d1:	83 ef 01             	sub    $0x1,%edi
  8022d4:	8d 72 ff             	lea    -0x1(%edx),%esi
  8022d7:	fd                   	std    
  8022d8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8022da:	fc                   	cld    
  8022db:	eb 1d                	jmp    8022fa <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8022dd:	89 f2                	mov    %esi,%edx
  8022df:	09 c2                	or     %eax,%edx
  8022e1:	f6 c2 03             	test   $0x3,%dl
  8022e4:	75 0f                	jne    8022f5 <memmove+0x5f>
  8022e6:	f6 c1 03             	test   $0x3,%cl
  8022e9:	75 0a                	jne    8022f5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8022eb:	c1 e9 02             	shr    $0x2,%ecx
  8022ee:	89 c7                	mov    %eax,%edi
  8022f0:	fc                   	cld    
  8022f1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8022f3:	eb 05                	jmp    8022fa <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8022f5:	89 c7                	mov    %eax,%edi
  8022f7:	fc                   	cld    
  8022f8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8022fa:	5e                   	pop    %esi
  8022fb:	5f                   	pop    %edi
  8022fc:	5d                   	pop    %ebp
  8022fd:	c3                   	ret    

008022fe <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8022fe:	55                   	push   %ebp
  8022ff:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  802301:	ff 75 10             	pushl  0x10(%ebp)
  802304:	ff 75 0c             	pushl  0xc(%ebp)
  802307:	ff 75 08             	pushl  0x8(%ebp)
  80230a:	e8 87 ff ff ff       	call   802296 <memmove>
}
  80230f:	c9                   	leave  
  802310:	c3                   	ret    

00802311 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  802311:	55                   	push   %ebp
  802312:	89 e5                	mov    %esp,%ebp
  802314:	56                   	push   %esi
  802315:	53                   	push   %ebx
  802316:	8b 45 08             	mov    0x8(%ebp),%eax
  802319:	8b 55 0c             	mov    0xc(%ebp),%edx
  80231c:	89 c6                	mov    %eax,%esi
  80231e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802321:	eb 1a                	jmp    80233d <memcmp+0x2c>
		if (*s1 != *s2)
  802323:	0f b6 08             	movzbl (%eax),%ecx
  802326:	0f b6 1a             	movzbl (%edx),%ebx
  802329:	38 d9                	cmp    %bl,%cl
  80232b:	74 0a                	je     802337 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80232d:	0f b6 c1             	movzbl %cl,%eax
  802330:	0f b6 db             	movzbl %bl,%ebx
  802333:	29 d8                	sub    %ebx,%eax
  802335:	eb 0f                	jmp    802346 <memcmp+0x35>
		s1++, s2++;
  802337:	83 c0 01             	add    $0x1,%eax
  80233a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80233d:	39 f0                	cmp    %esi,%eax
  80233f:	75 e2                	jne    802323 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  802341:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802346:	5b                   	pop    %ebx
  802347:	5e                   	pop    %esi
  802348:	5d                   	pop    %ebp
  802349:	c3                   	ret    

0080234a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80234a:	55                   	push   %ebp
  80234b:	89 e5                	mov    %esp,%ebp
  80234d:	53                   	push   %ebx
  80234e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  802351:	89 c1                	mov    %eax,%ecx
  802353:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  802356:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80235a:	eb 0a                	jmp    802366 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80235c:	0f b6 10             	movzbl (%eax),%edx
  80235f:	39 da                	cmp    %ebx,%edx
  802361:	74 07                	je     80236a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802363:	83 c0 01             	add    $0x1,%eax
  802366:	39 c8                	cmp    %ecx,%eax
  802368:	72 f2                	jb     80235c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80236a:	5b                   	pop    %ebx
  80236b:	5d                   	pop    %ebp
  80236c:	c3                   	ret    

0080236d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80236d:	55                   	push   %ebp
  80236e:	89 e5                	mov    %esp,%ebp
  802370:	57                   	push   %edi
  802371:	56                   	push   %esi
  802372:	53                   	push   %ebx
  802373:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802376:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802379:	eb 03                	jmp    80237e <strtol+0x11>
		s++;
  80237b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80237e:	0f b6 01             	movzbl (%ecx),%eax
  802381:	3c 20                	cmp    $0x20,%al
  802383:	74 f6                	je     80237b <strtol+0xe>
  802385:	3c 09                	cmp    $0x9,%al
  802387:	74 f2                	je     80237b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  802389:	3c 2b                	cmp    $0x2b,%al
  80238b:	75 0a                	jne    802397 <strtol+0x2a>
		s++;
  80238d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  802390:	bf 00 00 00 00       	mov    $0x0,%edi
  802395:	eb 11                	jmp    8023a8 <strtol+0x3b>
  802397:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80239c:	3c 2d                	cmp    $0x2d,%al
  80239e:	75 08                	jne    8023a8 <strtol+0x3b>
		s++, neg = 1;
  8023a0:	83 c1 01             	add    $0x1,%ecx
  8023a3:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8023a8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8023ae:	75 15                	jne    8023c5 <strtol+0x58>
  8023b0:	80 39 30             	cmpb   $0x30,(%ecx)
  8023b3:	75 10                	jne    8023c5 <strtol+0x58>
  8023b5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8023b9:	75 7c                	jne    802437 <strtol+0xca>
		s += 2, base = 16;
  8023bb:	83 c1 02             	add    $0x2,%ecx
  8023be:	bb 10 00 00 00       	mov    $0x10,%ebx
  8023c3:	eb 16                	jmp    8023db <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8023c5:	85 db                	test   %ebx,%ebx
  8023c7:	75 12                	jne    8023db <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8023c9:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8023ce:	80 39 30             	cmpb   $0x30,(%ecx)
  8023d1:	75 08                	jne    8023db <strtol+0x6e>
		s++, base = 8;
  8023d3:	83 c1 01             	add    $0x1,%ecx
  8023d6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8023db:	b8 00 00 00 00       	mov    $0x0,%eax
  8023e0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8023e3:	0f b6 11             	movzbl (%ecx),%edx
  8023e6:	8d 72 d0             	lea    -0x30(%edx),%esi
  8023e9:	89 f3                	mov    %esi,%ebx
  8023eb:	80 fb 09             	cmp    $0x9,%bl
  8023ee:	77 08                	ja     8023f8 <strtol+0x8b>
			dig = *s - '0';
  8023f0:	0f be d2             	movsbl %dl,%edx
  8023f3:	83 ea 30             	sub    $0x30,%edx
  8023f6:	eb 22                	jmp    80241a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8023f8:	8d 72 9f             	lea    -0x61(%edx),%esi
  8023fb:	89 f3                	mov    %esi,%ebx
  8023fd:	80 fb 19             	cmp    $0x19,%bl
  802400:	77 08                	ja     80240a <strtol+0x9d>
			dig = *s - 'a' + 10;
  802402:	0f be d2             	movsbl %dl,%edx
  802405:	83 ea 57             	sub    $0x57,%edx
  802408:	eb 10                	jmp    80241a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80240a:	8d 72 bf             	lea    -0x41(%edx),%esi
  80240d:	89 f3                	mov    %esi,%ebx
  80240f:	80 fb 19             	cmp    $0x19,%bl
  802412:	77 16                	ja     80242a <strtol+0xbd>
			dig = *s - 'A' + 10;
  802414:	0f be d2             	movsbl %dl,%edx
  802417:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80241a:	3b 55 10             	cmp    0x10(%ebp),%edx
  80241d:	7d 0b                	jge    80242a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  80241f:	83 c1 01             	add    $0x1,%ecx
  802422:	0f af 45 10          	imul   0x10(%ebp),%eax
  802426:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  802428:	eb b9                	jmp    8023e3 <strtol+0x76>

	if (endptr)
  80242a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80242e:	74 0d                	je     80243d <strtol+0xd0>
		*endptr = (char *) s;
  802430:	8b 75 0c             	mov    0xc(%ebp),%esi
  802433:	89 0e                	mov    %ecx,(%esi)
  802435:	eb 06                	jmp    80243d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802437:	85 db                	test   %ebx,%ebx
  802439:	74 98                	je     8023d3 <strtol+0x66>
  80243b:	eb 9e                	jmp    8023db <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80243d:	89 c2                	mov    %eax,%edx
  80243f:	f7 da                	neg    %edx
  802441:	85 ff                	test   %edi,%edi
  802443:	0f 45 c2             	cmovne %edx,%eax
}
  802446:	5b                   	pop    %ebx
  802447:	5e                   	pop    %esi
  802448:	5f                   	pop    %edi
  802449:	5d                   	pop    %ebp
  80244a:	c3                   	ret    

0080244b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80244b:	55                   	push   %ebp
  80244c:	89 e5                	mov    %esp,%ebp
  80244e:	57                   	push   %edi
  80244f:	56                   	push   %esi
  802450:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802451:	b8 00 00 00 00       	mov    $0x0,%eax
  802456:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802459:	8b 55 08             	mov    0x8(%ebp),%edx
  80245c:	89 c3                	mov    %eax,%ebx
  80245e:	89 c7                	mov    %eax,%edi
  802460:	89 c6                	mov    %eax,%esi
  802462:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  802464:	5b                   	pop    %ebx
  802465:	5e                   	pop    %esi
  802466:	5f                   	pop    %edi
  802467:	5d                   	pop    %ebp
  802468:	c3                   	ret    

00802469 <sys_cgetc>:

int
sys_cgetc(void)
{
  802469:	55                   	push   %ebp
  80246a:	89 e5                	mov    %esp,%ebp
  80246c:	57                   	push   %edi
  80246d:	56                   	push   %esi
  80246e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80246f:	ba 00 00 00 00       	mov    $0x0,%edx
  802474:	b8 01 00 00 00       	mov    $0x1,%eax
  802479:	89 d1                	mov    %edx,%ecx
  80247b:	89 d3                	mov    %edx,%ebx
  80247d:	89 d7                	mov    %edx,%edi
  80247f:	89 d6                	mov    %edx,%esi
  802481:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  802483:	5b                   	pop    %ebx
  802484:	5e                   	pop    %esi
  802485:	5f                   	pop    %edi
  802486:	5d                   	pop    %ebp
  802487:	c3                   	ret    

00802488 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  802488:	55                   	push   %ebp
  802489:	89 e5                	mov    %esp,%ebp
  80248b:	57                   	push   %edi
  80248c:	56                   	push   %esi
  80248d:	53                   	push   %ebx
  80248e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802491:	b9 00 00 00 00       	mov    $0x0,%ecx
  802496:	b8 03 00 00 00       	mov    $0x3,%eax
  80249b:	8b 55 08             	mov    0x8(%ebp),%edx
  80249e:	89 cb                	mov    %ecx,%ebx
  8024a0:	89 cf                	mov    %ecx,%edi
  8024a2:	89 ce                	mov    %ecx,%esi
  8024a4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8024a6:	85 c0                	test   %eax,%eax
  8024a8:	7e 17                	jle    8024c1 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8024aa:	83 ec 0c             	sub    $0xc,%esp
  8024ad:	50                   	push   %eax
  8024ae:	6a 03                	push   $0x3
  8024b0:	68 3f 44 80 00       	push   $0x80443f
  8024b5:	6a 23                	push   $0x23
  8024b7:	68 5c 44 80 00       	push   $0x80445c
  8024bc:	e8 e5 f5 ff ff       	call   801aa6 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8024c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024c4:	5b                   	pop    %ebx
  8024c5:	5e                   	pop    %esi
  8024c6:	5f                   	pop    %edi
  8024c7:	5d                   	pop    %ebp
  8024c8:	c3                   	ret    

008024c9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8024c9:	55                   	push   %ebp
  8024ca:	89 e5                	mov    %esp,%ebp
  8024cc:	57                   	push   %edi
  8024cd:	56                   	push   %esi
  8024ce:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8024d4:	b8 02 00 00 00       	mov    $0x2,%eax
  8024d9:	89 d1                	mov    %edx,%ecx
  8024db:	89 d3                	mov    %edx,%ebx
  8024dd:	89 d7                	mov    %edx,%edi
  8024df:	89 d6                	mov    %edx,%esi
  8024e1:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8024e3:	5b                   	pop    %ebx
  8024e4:	5e                   	pop    %esi
  8024e5:	5f                   	pop    %edi
  8024e6:	5d                   	pop    %ebp
  8024e7:	c3                   	ret    

008024e8 <sys_yield>:

void
sys_yield(void)
{
  8024e8:	55                   	push   %ebp
  8024e9:	89 e5                	mov    %esp,%ebp
  8024eb:	57                   	push   %edi
  8024ec:	56                   	push   %esi
  8024ed:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8024f3:	b8 0b 00 00 00       	mov    $0xb,%eax
  8024f8:	89 d1                	mov    %edx,%ecx
  8024fa:	89 d3                	mov    %edx,%ebx
  8024fc:	89 d7                	mov    %edx,%edi
  8024fe:	89 d6                	mov    %edx,%esi
  802500:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  802502:	5b                   	pop    %ebx
  802503:	5e                   	pop    %esi
  802504:	5f                   	pop    %edi
  802505:	5d                   	pop    %ebp
  802506:	c3                   	ret    

00802507 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  802507:	55                   	push   %ebp
  802508:	89 e5                	mov    %esp,%ebp
  80250a:	57                   	push   %edi
  80250b:	56                   	push   %esi
  80250c:	53                   	push   %ebx
  80250d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802510:	be 00 00 00 00       	mov    $0x0,%esi
  802515:	b8 04 00 00 00       	mov    $0x4,%eax
  80251a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80251d:	8b 55 08             	mov    0x8(%ebp),%edx
  802520:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802523:	89 f7                	mov    %esi,%edi
  802525:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802527:	85 c0                	test   %eax,%eax
  802529:	7e 17                	jle    802542 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80252b:	83 ec 0c             	sub    $0xc,%esp
  80252e:	50                   	push   %eax
  80252f:	6a 04                	push   $0x4
  802531:	68 3f 44 80 00       	push   $0x80443f
  802536:	6a 23                	push   $0x23
  802538:	68 5c 44 80 00       	push   $0x80445c
  80253d:	e8 64 f5 ff ff       	call   801aa6 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  802542:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802545:	5b                   	pop    %ebx
  802546:	5e                   	pop    %esi
  802547:	5f                   	pop    %edi
  802548:	5d                   	pop    %ebp
  802549:	c3                   	ret    

0080254a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80254a:	55                   	push   %ebp
  80254b:	89 e5                	mov    %esp,%ebp
  80254d:	57                   	push   %edi
  80254e:	56                   	push   %esi
  80254f:	53                   	push   %ebx
  802550:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802553:	b8 05 00 00 00       	mov    $0x5,%eax
  802558:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80255b:	8b 55 08             	mov    0x8(%ebp),%edx
  80255e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802561:	8b 7d 14             	mov    0x14(%ebp),%edi
  802564:	8b 75 18             	mov    0x18(%ebp),%esi
  802567:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802569:	85 c0                	test   %eax,%eax
  80256b:	7e 17                	jle    802584 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80256d:	83 ec 0c             	sub    $0xc,%esp
  802570:	50                   	push   %eax
  802571:	6a 05                	push   $0x5
  802573:	68 3f 44 80 00       	push   $0x80443f
  802578:	6a 23                	push   $0x23
  80257a:	68 5c 44 80 00       	push   $0x80445c
  80257f:	e8 22 f5 ff ff       	call   801aa6 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  802584:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802587:	5b                   	pop    %ebx
  802588:	5e                   	pop    %esi
  802589:	5f                   	pop    %edi
  80258a:	5d                   	pop    %ebp
  80258b:	c3                   	ret    

0080258c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80258c:	55                   	push   %ebp
  80258d:	89 e5                	mov    %esp,%ebp
  80258f:	57                   	push   %edi
  802590:	56                   	push   %esi
  802591:	53                   	push   %ebx
  802592:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802595:	bb 00 00 00 00       	mov    $0x0,%ebx
  80259a:	b8 06 00 00 00       	mov    $0x6,%eax
  80259f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8025a5:	89 df                	mov    %ebx,%edi
  8025a7:	89 de                	mov    %ebx,%esi
  8025a9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8025ab:	85 c0                	test   %eax,%eax
  8025ad:	7e 17                	jle    8025c6 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025af:	83 ec 0c             	sub    $0xc,%esp
  8025b2:	50                   	push   %eax
  8025b3:	6a 06                	push   $0x6
  8025b5:	68 3f 44 80 00       	push   $0x80443f
  8025ba:	6a 23                	push   $0x23
  8025bc:	68 5c 44 80 00       	push   $0x80445c
  8025c1:	e8 e0 f4 ff ff       	call   801aa6 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8025c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025c9:	5b                   	pop    %ebx
  8025ca:	5e                   	pop    %esi
  8025cb:	5f                   	pop    %edi
  8025cc:	5d                   	pop    %ebp
  8025cd:	c3                   	ret    

008025ce <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8025ce:	55                   	push   %ebp
  8025cf:	89 e5                	mov    %esp,%ebp
  8025d1:	57                   	push   %edi
  8025d2:	56                   	push   %esi
  8025d3:	53                   	push   %ebx
  8025d4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8025dc:	b8 08 00 00 00       	mov    $0x8,%eax
  8025e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8025e7:	89 df                	mov    %ebx,%edi
  8025e9:	89 de                	mov    %ebx,%esi
  8025eb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8025ed:	85 c0                	test   %eax,%eax
  8025ef:	7e 17                	jle    802608 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025f1:	83 ec 0c             	sub    $0xc,%esp
  8025f4:	50                   	push   %eax
  8025f5:	6a 08                	push   $0x8
  8025f7:	68 3f 44 80 00       	push   $0x80443f
  8025fc:	6a 23                	push   $0x23
  8025fe:	68 5c 44 80 00       	push   $0x80445c
  802603:	e8 9e f4 ff ff       	call   801aa6 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  802608:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80260b:	5b                   	pop    %ebx
  80260c:	5e                   	pop    %esi
  80260d:	5f                   	pop    %edi
  80260e:	5d                   	pop    %ebp
  80260f:	c3                   	ret    

00802610 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  802610:	55                   	push   %ebp
  802611:	89 e5                	mov    %esp,%ebp
  802613:	57                   	push   %edi
  802614:	56                   	push   %esi
  802615:	53                   	push   %ebx
  802616:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802619:	bb 00 00 00 00       	mov    $0x0,%ebx
  80261e:	b8 09 00 00 00       	mov    $0x9,%eax
  802623:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802626:	8b 55 08             	mov    0x8(%ebp),%edx
  802629:	89 df                	mov    %ebx,%edi
  80262b:	89 de                	mov    %ebx,%esi
  80262d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80262f:	85 c0                	test   %eax,%eax
  802631:	7e 17                	jle    80264a <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802633:	83 ec 0c             	sub    $0xc,%esp
  802636:	50                   	push   %eax
  802637:	6a 09                	push   $0x9
  802639:	68 3f 44 80 00       	push   $0x80443f
  80263e:	6a 23                	push   $0x23
  802640:	68 5c 44 80 00       	push   $0x80445c
  802645:	e8 5c f4 ff ff       	call   801aa6 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80264a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80264d:	5b                   	pop    %ebx
  80264e:	5e                   	pop    %esi
  80264f:	5f                   	pop    %edi
  802650:	5d                   	pop    %ebp
  802651:	c3                   	ret    

00802652 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  802652:	55                   	push   %ebp
  802653:	89 e5                	mov    %esp,%ebp
  802655:	57                   	push   %edi
  802656:	56                   	push   %esi
  802657:	53                   	push   %ebx
  802658:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80265b:	bb 00 00 00 00       	mov    $0x0,%ebx
  802660:	b8 0a 00 00 00       	mov    $0xa,%eax
  802665:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802668:	8b 55 08             	mov    0x8(%ebp),%edx
  80266b:	89 df                	mov    %ebx,%edi
  80266d:	89 de                	mov    %ebx,%esi
  80266f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802671:	85 c0                	test   %eax,%eax
  802673:	7e 17                	jle    80268c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802675:	83 ec 0c             	sub    $0xc,%esp
  802678:	50                   	push   %eax
  802679:	6a 0a                	push   $0xa
  80267b:	68 3f 44 80 00       	push   $0x80443f
  802680:	6a 23                	push   $0x23
  802682:	68 5c 44 80 00       	push   $0x80445c
  802687:	e8 1a f4 ff ff       	call   801aa6 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80268c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80268f:	5b                   	pop    %ebx
  802690:	5e                   	pop    %esi
  802691:	5f                   	pop    %edi
  802692:	5d                   	pop    %ebp
  802693:	c3                   	ret    

00802694 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  802694:	55                   	push   %ebp
  802695:	89 e5                	mov    %esp,%ebp
  802697:	57                   	push   %edi
  802698:	56                   	push   %esi
  802699:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80269a:	be 00 00 00 00       	mov    $0x0,%esi
  80269f:	b8 0c 00 00 00       	mov    $0xc,%eax
  8026a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8026aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8026ad:	8b 7d 14             	mov    0x14(%ebp),%edi
  8026b0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8026b2:	5b                   	pop    %ebx
  8026b3:	5e                   	pop    %esi
  8026b4:	5f                   	pop    %edi
  8026b5:	5d                   	pop    %ebp
  8026b6:	c3                   	ret    

008026b7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8026b7:	55                   	push   %ebp
  8026b8:	89 e5                	mov    %esp,%ebp
  8026ba:	57                   	push   %edi
  8026bb:	56                   	push   %esi
  8026bc:	53                   	push   %ebx
  8026bd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8026c5:	b8 0d 00 00 00       	mov    $0xd,%eax
  8026ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8026cd:	89 cb                	mov    %ecx,%ebx
  8026cf:	89 cf                	mov    %ecx,%edi
  8026d1:	89 ce                	mov    %ecx,%esi
  8026d3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8026d5:	85 c0                	test   %eax,%eax
  8026d7:	7e 17                	jle    8026f0 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8026d9:	83 ec 0c             	sub    $0xc,%esp
  8026dc:	50                   	push   %eax
  8026dd:	6a 0d                	push   $0xd
  8026df:	68 3f 44 80 00       	push   $0x80443f
  8026e4:	6a 23                	push   $0x23
  8026e6:	68 5c 44 80 00       	push   $0x80445c
  8026eb:	e8 b6 f3 ff ff       	call   801aa6 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8026f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026f3:	5b                   	pop    %ebx
  8026f4:	5e                   	pop    %esi
  8026f5:	5f                   	pop    %edi
  8026f6:	5d                   	pop    %ebp
  8026f7:	c3                   	ret    

008026f8 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  8026f8:	55                   	push   %ebp
  8026f9:	89 e5                	mov    %esp,%ebp
  8026fb:	57                   	push   %edi
  8026fc:	56                   	push   %esi
  8026fd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  802703:	b8 0e 00 00 00       	mov    $0xe,%eax
  802708:	8b 55 08             	mov    0x8(%ebp),%edx
  80270b:	89 cb                	mov    %ecx,%ebx
  80270d:	89 cf                	mov    %ecx,%edi
  80270f:	89 ce                	mov    %ecx,%esi
  802711:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  802713:	5b                   	pop    %ebx
  802714:	5e                   	pop    %esi
  802715:	5f                   	pop    %edi
  802716:	5d                   	pop    %ebp
  802717:	c3                   	ret    

00802718 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  802718:	55                   	push   %ebp
  802719:	89 e5                	mov    %esp,%ebp
  80271b:	57                   	push   %edi
  80271c:	56                   	push   %esi
  80271d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80271e:	b9 00 00 00 00       	mov    $0x0,%ecx
  802723:	b8 0f 00 00 00       	mov    $0xf,%eax
  802728:	8b 55 08             	mov    0x8(%ebp),%edx
  80272b:	89 cb                	mov    %ecx,%ebx
  80272d:	89 cf                	mov    %ecx,%edi
  80272f:	89 ce                	mov    %ecx,%esi
  802731:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  802733:	5b                   	pop    %ebx
  802734:	5e                   	pop    %esi
  802735:	5f                   	pop    %edi
  802736:	5d                   	pop    %ebp
  802737:	c3                   	ret    

00802738 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802738:	55                   	push   %ebp
  802739:	89 e5                	mov    %esp,%ebp
  80273b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80273e:	83 3d 10 a0 80 00 00 	cmpl   $0x0,0x80a010
  802745:	75 2a                	jne    802771 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802747:	83 ec 04             	sub    $0x4,%esp
  80274a:	6a 07                	push   $0x7
  80274c:	68 00 f0 bf ee       	push   $0xeebff000
  802751:	6a 00                	push   $0x0
  802753:	e8 af fd ff ff       	call   802507 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802758:	83 c4 10             	add    $0x10,%esp
  80275b:	85 c0                	test   %eax,%eax
  80275d:	79 12                	jns    802771 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  80275f:	50                   	push   %eax
  802760:	68 6a 44 80 00       	push   $0x80446a
  802765:	6a 23                	push   $0x23
  802767:	68 6e 44 80 00       	push   $0x80446e
  80276c:	e8 35 f3 ff ff       	call   801aa6 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802771:	8b 45 08             	mov    0x8(%ebp),%eax
  802774:	a3 10 a0 80 00       	mov    %eax,0x80a010
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802779:	83 ec 08             	sub    $0x8,%esp
  80277c:	68 a3 27 80 00       	push   $0x8027a3
  802781:	6a 00                	push   $0x0
  802783:	e8 ca fe ff ff       	call   802652 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802788:	83 c4 10             	add    $0x10,%esp
  80278b:	85 c0                	test   %eax,%eax
  80278d:	79 12                	jns    8027a1 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  80278f:	50                   	push   %eax
  802790:	68 6a 44 80 00       	push   $0x80446a
  802795:	6a 2c                	push   $0x2c
  802797:	68 6e 44 80 00       	push   $0x80446e
  80279c:	e8 05 f3 ff ff       	call   801aa6 <_panic>
	}
}
  8027a1:	c9                   	leave  
  8027a2:	c3                   	ret    

008027a3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8027a3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8027a4:	a1 10 a0 80 00       	mov    0x80a010,%eax
	call *%eax
  8027a9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8027ab:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8027ae:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8027b2:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8027b7:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8027bb:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8027bd:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8027c0:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8027c1:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8027c4:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8027c5:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8027c6:	c3                   	ret    

008027c7 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8027c7:	55                   	push   %ebp
  8027c8:	89 e5                	mov    %esp,%ebp
  8027ca:	53                   	push   %ebx
  8027cb:	83 ec 04             	sub    $0x4,%esp
  8027ce:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8027d1:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8027d3:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8027d7:	74 11                	je     8027ea <pgfault+0x23>
  8027d9:	89 d8                	mov    %ebx,%eax
  8027db:	c1 e8 0c             	shr    $0xc,%eax
  8027de:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8027e5:	f6 c4 08             	test   $0x8,%ah
  8027e8:	75 14                	jne    8027fe <pgfault+0x37>
		panic("faulting access");
  8027ea:	83 ec 04             	sub    $0x4,%esp
  8027ed:	68 7c 44 80 00       	push   $0x80447c
  8027f2:	6a 1e                	push   $0x1e
  8027f4:	68 8c 44 80 00       	push   $0x80448c
  8027f9:	e8 a8 f2 ff ff       	call   801aa6 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  8027fe:	83 ec 04             	sub    $0x4,%esp
  802801:	6a 07                	push   $0x7
  802803:	68 00 f0 7f 00       	push   $0x7ff000
  802808:	6a 00                	push   $0x0
  80280a:	e8 f8 fc ff ff       	call   802507 <sys_page_alloc>
	if (r < 0) {
  80280f:	83 c4 10             	add    $0x10,%esp
  802812:	85 c0                	test   %eax,%eax
  802814:	79 12                	jns    802828 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  802816:	50                   	push   %eax
  802817:	68 97 44 80 00       	push   $0x804497
  80281c:	6a 2c                	push   $0x2c
  80281e:	68 8c 44 80 00       	push   $0x80448c
  802823:	e8 7e f2 ff ff       	call   801aa6 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  802828:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  80282e:	83 ec 04             	sub    $0x4,%esp
  802831:	68 00 10 00 00       	push   $0x1000
  802836:	53                   	push   %ebx
  802837:	68 00 f0 7f 00       	push   $0x7ff000
  80283c:	e8 bd fa ff ff       	call   8022fe <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  802841:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  802848:	53                   	push   %ebx
  802849:	6a 00                	push   $0x0
  80284b:	68 00 f0 7f 00       	push   $0x7ff000
  802850:	6a 00                	push   $0x0
  802852:	e8 f3 fc ff ff       	call   80254a <sys_page_map>
	if (r < 0) {
  802857:	83 c4 20             	add    $0x20,%esp
  80285a:	85 c0                	test   %eax,%eax
  80285c:	79 12                	jns    802870 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  80285e:	50                   	push   %eax
  80285f:	68 97 44 80 00       	push   $0x804497
  802864:	6a 33                	push   $0x33
  802866:	68 8c 44 80 00       	push   $0x80448c
  80286b:	e8 36 f2 ff ff       	call   801aa6 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  802870:	83 ec 08             	sub    $0x8,%esp
  802873:	68 00 f0 7f 00       	push   $0x7ff000
  802878:	6a 00                	push   $0x0
  80287a:	e8 0d fd ff ff       	call   80258c <sys_page_unmap>
	if (r < 0) {
  80287f:	83 c4 10             	add    $0x10,%esp
  802882:	85 c0                	test   %eax,%eax
  802884:	79 12                	jns    802898 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  802886:	50                   	push   %eax
  802887:	68 97 44 80 00       	push   $0x804497
  80288c:	6a 37                	push   $0x37
  80288e:	68 8c 44 80 00       	push   $0x80448c
  802893:	e8 0e f2 ff ff       	call   801aa6 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  802898:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80289b:	c9                   	leave  
  80289c:	c3                   	ret    

0080289d <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80289d:	55                   	push   %ebp
  80289e:	89 e5                	mov    %esp,%ebp
  8028a0:	57                   	push   %edi
  8028a1:	56                   	push   %esi
  8028a2:	53                   	push   %ebx
  8028a3:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  8028a6:	68 c7 27 80 00       	push   $0x8027c7
  8028ab:	e8 88 fe ff ff       	call   802738 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8028b0:	b8 07 00 00 00       	mov    $0x7,%eax
  8028b5:	cd 30                	int    $0x30
  8028b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8028ba:	83 c4 10             	add    $0x10,%esp
  8028bd:	85 c0                	test   %eax,%eax
  8028bf:	79 17                	jns    8028d8 <fork+0x3b>
		panic("fork fault %e");
  8028c1:	83 ec 04             	sub    $0x4,%esp
  8028c4:	68 b0 44 80 00       	push   $0x8044b0
  8028c9:	68 84 00 00 00       	push   $0x84
  8028ce:	68 8c 44 80 00       	push   $0x80448c
  8028d3:	e8 ce f1 ff ff       	call   801aa6 <_panic>
  8028d8:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8028da:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8028de:	75 24                	jne    802904 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  8028e0:	e8 e4 fb ff ff       	call   8024c9 <sys_getenvid>
  8028e5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8028ea:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  8028f0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8028f5:	a3 0c a0 80 00       	mov    %eax,0x80a00c
		return 0;
  8028fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8028ff:	e9 64 01 00 00       	jmp    802a68 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  802904:	83 ec 04             	sub    $0x4,%esp
  802907:	6a 07                	push   $0x7
  802909:	68 00 f0 bf ee       	push   $0xeebff000
  80290e:	ff 75 e4             	pushl  -0x1c(%ebp)
  802911:	e8 f1 fb ff ff       	call   802507 <sys_page_alloc>
  802916:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  802919:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80291e:	89 d8                	mov    %ebx,%eax
  802920:	c1 e8 16             	shr    $0x16,%eax
  802923:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80292a:	a8 01                	test   $0x1,%al
  80292c:	0f 84 fc 00 00 00    	je     802a2e <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  802932:	89 d8                	mov    %ebx,%eax
  802934:	c1 e8 0c             	shr    $0xc,%eax
  802937:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80293e:	f6 c2 01             	test   $0x1,%dl
  802941:	0f 84 e7 00 00 00    	je     802a2e <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  802947:	89 c6                	mov    %eax,%esi
  802949:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  80294c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802953:	f6 c6 04             	test   $0x4,%dh
  802956:	74 39                	je     802991 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  802958:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80295f:	83 ec 0c             	sub    $0xc,%esp
  802962:	25 07 0e 00 00       	and    $0xe07,%eax
  802967:	50                   	push   %eax
  802968:	56                   	push   %esi
  802969:	57                   	push   %edi
  80296a:	56                   	push   %esi
  80296b:	6a 00                	push   $0x0
  80296d:	e8 d8 fb ff ff       	call   80254a <sys_page_map>
		if (r < 0) {
  802972:	83 c4 20             	add    $0x20,%esp
  802975:	85 c0                	test   %eax,%eax
  802977:	0f 89 b1 00 00 00    	jns    802a2e <fork+0x191>
		    	panic("sys page map fault %e");
  80297d:	83 ec 04             	sub    $0x4,%esp
  802980:	68 be 44 80 00       	push   $0x8044be
  802985:	6a 54                	push   $0x54
  802987:	68 8c 44 80 00       	push   $0x80448c
  80298c:	e8 15 f1 ff ff       	call   801aa6 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  802991:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802998:	f6 c2 02             	test   $0x2,%dl
  80299b:	75 0c                	jne    8029a9 <fork+0x10c>
  80299d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8029a4:	f6 c4 08             	test   $0x8,%ah
  8029a7:	74 5b                	je     802a04 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8029a9:	83 ec 0c             	sub    $0xc,%esp
  8029ac:	68 05 08 00 00       	push   $0x805
  8029b1:	56                   	push   %esi
  8029b2:	57                   	push   %edi
  8029b3:	56                   	push   %esi
  8029b4:	6a 00                	push   $0x0
  8029b6:	e8 8f fb ff ff       	call   80254a <sys_page_map>
		if (r < 0) {
  8029bb:	83 c4 20             	add    $0x20,%esp
  8029be:	85 c0                	test   %eax,%eax
  8029c0:	79 14                	jns    8029d6 <fork+0x139>
		    	panic("sys page map fault %e");
  8029c2:	83 ec 04             	sub    $0x4,%esp
  8029c5:	68 be 44 80 00       	push   $0x8044be
  8029ca:	6a 5b                	push   $0x5b
  8029cc:	68 8c 44 80 00       	push   $0x80448c
  8029d1:	e8 d0 f0 ff ff       	call   801aa6 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8029d6:	83 ec 0c             	sub    $0xc,%esp
  8029d9:	68 05 08 00 00       	push   $0x805
  8029de:	56                   	push   %esi
  8029df:	6a 00                	push   $0x0
  8029e1:	56                   	push   %esi
  8029e2:	6a 00                	push   $0x0
  8029e4:	e8 61 fb ff ff       	call   80254a <sys_page_map>
		if (r < 0) {
  8029e9:	83 c4 20             	add    $0x20,%esp
  8029ec:	85 c0                	test   %eax,%eax
  8029ee:	79 3e                	jns    802a2e <fork+0x191>
		    	panic("sys page map fault %e");
  8029f0:	83 ec 04             	sub    $0x4,%esp
  8029f3:	68 be 44 80 00       	push   $0x8044be
  8029f8:	6a 5f                	push   $0x5f
  8029fa:	68 8c 44 80 00       	push   $0x80448c
  8029ff:	e8 a2 f0 ff ff       	call   801aa6 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  802a04:	83 ec 0c             	sub    $0xc,%esp
  802a07:	6a 05                	push   $0x5
  802a09:	56                   	push   %esi
  802a0a:	57                   	push   %edi
  802a0b:	56                   	push   %esi
  802a0c:	6a 00                	push   $0x0
  802a0e:	e8 37 fb ff ff       	call   80254a <sys_page_map>
		if (r < 0) {
  802a13:	83 c4 20             	add    $0x20,%esp
  802a16:	85 c0                	test   %eax,%eax
  802a18:	79 14                	jns    802a2e <fork+0x191>
		    	panic("sys page map fault %e");
  802a1a:	83 ec 04             	sub    $0x4,%esp
  802a1d:	68 be 44 80 00       	push   $0x8044be
  802a22:	6a 64                	push   $0x64
  802a24:	68 8c 44 80 00       	push   $0x80448c
  802a29:	e8 78 f0 ff ff       	call   801aa6 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  802a2e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802a34:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  802a3a:	0f 85 de fe ff ff    	jne    80291e <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  802a40:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802a45:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  802a4b:	83 ec 08             	sub    $0x8,%esp
  802a4e:	50                   	push   %eax
  802a4f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  802a52:	57                   	push   %edi
  802a53:	e8 fa fb ff ff       	call   802652 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  802a58:	83 c4 08             	add    $0x8,%esp
  802a5b:	6a 02                	push   $0x2
  802a5d:	57                   	push   %edi
  802a5e:	e8 6b fb ff ff       	call   8025ce <sys_env_set_status>
	
	return envid;
  802a63:	83 c4 10             	add    $0x10,%esp
  802a66:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  802a68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a6b:	5b                   	pop    %ebx
  802a6c:	5e                   	pop    %esi
  802a6d:	5f                   	pop    %edi
  802a6e:	5d                   	pop    %ebp
  802a6f:	c3                   	ret    

00802a70 <sfork>:

envid_t
sfork(void)
{
  802a70:	55                   	push   %ebp
  802a71:	89 e5                	mov    %esp,%ebp
	return 0;
}
  802a73:	b8 00 00 00 00       	mov    $0x0,%eax
  802a78:	5d                   	pop    %ebp
  802a79:	c3                   	ret    

00802a7a <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  802a7a:	55                   	push   %ebp
  802a7b:	89 e5                	mov    %esp,%ebp
  802a7d:	56                   	push   %esi
  802a7e:	53                   	push   %ebx
  802a7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  802a82:	89 1d 14 a0 80 00    	mov    %ebx,0x80a014
	cprintf("in fork.c thread create. func: %x\n", func);
  802a88:	83 ec 08             	sub    $0x8,%esp
  802a8b:	53                   	push   %ebx
  802a8c:	68 d4 44 80 00       	push   $0x8044d4
  802a91:	e8 e9 f0 ff ff       	call   801b7f <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  802a96:	c7 04 24 6c 1a 80 00 	movl   $0x801a6c,(%esp)
  802a9d:	e8 56 fc ff ff       	call   8026f8 <sys_thread_create>
  802aa2:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  802aa4:	83 c4 08             	add    $0x8,%esp
  802aa7:	53                   	push   %ebx
  802aa8:	68 d4 44 80 00       	push   $0x8044d4
  802aad:	e8 cd f0 ff ff       	call   801b7f <cprintf>
	return id;
}
  802ab2:	89 f0                	mov    %esi,%eax
  802ab4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ab7:	5b                   	pop    %ebx
  802ab8:	5e                   	pop    %esi
  802ab9:	5d                   	pop    %ebp
  802aba:	c3                   	ret    

00802abb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802abb:	55                   	push   %ebp
  802abc:	89 e5                	mov    %esp,%ebp
  802abe:	56                   	push   %esi
  802abf:	53                   	push   %ebx
  802ac0:	8b 75 08             	mov    0x8(%ebp),%esi
  802ac3:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ac6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802ac9:	85 c0                	test   %eax,%eax
  802acb:	75 12                	jne    802adf <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802acd:	83 ec 0c             	sub    $0xc,%esp
  802ad0:	68 00 00 c0 ee       	push   $0xeec00000
  802ad5:	e8 dd fb ff ff       	call   8026b7 <sys_ipc_recv>
  802ada:	83 c4 10             	add    $0x10,%esp
  802add:	eb 0c                	jmp    802aeb <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802adf:	83 ec 0c             	sub    $0xc,%esp
  802ae2:	50                   	push   %eax
  802ae3:	e8 cf fb ff ff       	call   8026b7 <sys_ipc_recv>
  802ae8:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802aeb:	85 f6                	test   %esi,%esi
  802aed:	0f 95 c1             	setne  %cl
  802af0:	85 db                	test   %ebx,%ebx
  802af2:	0f 95 c2             	setne  %dl
  802af5:	84 d1                	test   %dl,%cl
  802af7:	74 09                	je     802b02 <ipc_recv+0x47>
  802af9:	89 c2                	mov    %eax,%edx
  802afb:	c1 ea 1f             	shr    $0x1f,%edx
  802afe:	84 d2                	test   %dl,%dl
  802b00:	75 2d                	jne    802b2f <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802b02:	85 f6                	test   %esi,%esi
  802b04:	74 0d                	je     802b13 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802b06:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802b0b:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  802b11:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802b13:	85 db                	test   %ebx,%ebx
  802b15:	74 0d                	je     802b24 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802b17:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802b1c:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  802b22:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802b24:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802b29:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  802b2f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b32:	5b                   	pop    %ebx
  802b33:	5e                   	pop    %esi
  802b34:	5d                   	pop    %ebp
  802b35:	c3                   	ret    

00802b36 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802b36:	55                   	push   %ebp
  802b37:	89 e5                	mov    %esp,%ebp
  802b39:	57                   	push   %edi
  802b3a:	56                   	push   %esi
  802b3b:	53                   	push   %ebx
  802b3c:	83 ec 0c             	sub    $0xc,%esp
  802b3f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802b42:	8b 75 0c             	mov    0xc(%ebp),%esi
  802b45:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802b48:	85 db                	test   %ebx,%ebx
  802b4a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802b4f:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802b52:	ff 75 14             	pushl  0x14(%ebp)
  802b55:	53                   	push   %ebx
  802b56:	56                   	push   %esi
  802b57:	57                   	push   %edi
  802b58:	e8 37 fb ff ff       	call   802694 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802b5d:	89 c2                	mov    %eax,%edx
  802b5f:	c1 ea 1f             	shr    $0x1f,%edx
  802b62:	83 c4 10             	add    $0x10,%esp
  802b65:	84 d2                	test   %dl,%dl
  802b67:	74 17                	je     802b80 <ipc_send+0x4a>
  802b69:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802b6c:	74 12                	je     802b80 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802b6e:	50                   	push   %eax
  802b6f:	68 f7 44 80 00       	push   $0x8044f7
  802b74:	6a 47                	push   $0x47
  802b76:	68 05 45 80 00       	push   $0x804505
  802b7b:	e8 26 ef ff ff       	call   801aa6 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802b80:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802b83:	75 07                	jne    802b8c <ipc_send+0x56>
			sys_yield();
  802b85:	e8 5e f9 ff ff       	call   8024e8 <sys_yield>
  802b8a:	eb c6                	jmp    802b52 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802b8c:	85 c0                	test   %eax,%eax
  802b8e:	75 c2                	jne    802b52 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802b90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b93:	5b                   	pop    %ebx
  802b94:	5e                   	pop    %esi
  802b95:	5f                   	pop    %edi
  802b96:	5d                   	pop    %ebp
  802b97:	c3                   	ret    

00802b98 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802b98:	55                   	push   %ebp
  802b99:	89 e5                	mov    %esp,%ebp
  802b9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802b9e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802ba3:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  802ba9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802baf:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  802bb5:	39 ca                	cmp    %ecx,%edx
  802bb7:	75 10                	jne    802bc9 <ipc_find_env+0x31>
			return envs[i].env_id;
  802bb9:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  802bbf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802bc4:	8b 40 7c             	mov    0x7c(%eax),%eax
  802bc7:	eb 0f                	jmp    802bd8 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802bc9:	83 c0 01             	add    $0x1,%eax
  802bcc:	3d 00 04 00 00       	cmp    $0x400,%eax
  802bd1:	75 d0                	jne    802ba3 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802bd3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802bd8:	5d                   	pop    %ebp
  802bd9:	c3                   	ret    

00802bda <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802bda:	55                   	push   %ebp
  802bdb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802bdd:	8b 45 08             	mov    0x8(%ebp),%eax
  802be0:	05 00 00 00 30       	add    $0x30000000,%eax
  802be5:	c1 e8 0c             	shr    $0xc,%eax
}
  802be8:	5d                   	pop    %ebp
  802be9:	c3                   	ret    

00802bea <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802bea:	55                   	push   %ebp
  802beb:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  802bed:	8b 45 08             	mov    0x8(%ebp),%eax
  802bf0:	05 00 00 00 30       	add    $0x30000000,%eax
  802bf5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  802bfa:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  802bff:	5d                   	pop    %ebp
  802c00:	c3                   	ret    

00802c01 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  802c01:	55                   	push   %ebp
  802c02:	89 e5                	mov    %esp,%ebp
  802c04:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802c07:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  802c0c:	89 c2                	mov    %eax,%edx
  802c0e:	c1 ea 16             	shr    $0x16,%edx
  802c11:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802c18:	f6 c2 01             	test   $0x1,%dl
  802c1b:	74 11                	je     802c2e <fd_alloc+0x2d>
  802c1d:	89 c2                	mov    %eax,%edx
  802c1f:	c1 ea 0c             	shr    $0xc,%edx
  802c22:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802c29:	f6 c2 01             	test   $0x1,%dl
  802c2c:	75 09                	jne    802c37 <fd_alloc+0x36>
			*fd_store = fd;
  802c2e:	89 01                	mov    %eax,(%ecx)
			return 0;
  802c30:	b8 00 00 00 00       	mov    $0x0,%eax
  802c35:	eb 17                	jmp    802c4e <fd_alloc+0x4d>
  802c37:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  802c3c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  802c41:	75 c9                	jne    802c0c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  802c43:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  802c49:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  802c4e:	5d                   	pop    %ebp
  802c4f:	c3                   	ret    

00802c50 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802c50:	55                   	push   %ebp
  802c51:	89 e5                	mov    %esp,%ebp
  802c53:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802c56:	83 f8 1f             	cmp    $0x1f,%eax
  802c59:	77 36                	ja     802c91 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802c5b:	c1 e0 0c             	shl    $0xc,%eax
  802c5e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  802c63:	89 c2                	mov    %eax,%edx
  802c65:	c1 ea 16             	shr    $0x16,%edx
  802c68:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802c6f:	f6 c2 01             	test   $0x1,%dl
  802c72:	74 24                	je     802c98 <fd_lookup+0x48>
  802c74:	89 c2                	mov    %eax,%edx
  802c76:	c1 ea 0c             	shr    $0xc,%edx
  802c79:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802c80:	f6 c2 01             	test   $0x1,%dl
  802c83:	74 1a                	je     802c9f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  802c85:	8b 55 0c             	mov    0xc(%ebp),%edx
  802c88:	89 02                	mov    %eax,(%edx)
	return 0;
  802c8a:	b8 00 00 00 00       	mov    $0x0,%eax
  802c8f:	eb 13                	jmp    802ca4 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802c91:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802c96:	eb 0c                	jmp    802ca4 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802c98:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802c9d:	eb 05                	jmp    802ca4 <fd_lookup+0x54>
  802c9f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  802ca4:	5d                   	pop    %ebp
  802ca5:	c3                   	ret    

00802ca6 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802ca6:	55                   	push   %ebp
  802ca7:	89 e5                	mov    %esp,%ebp
  802ca9:	83 ec 08             	sub    $0x8,%esp
  802cac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802caf:	ba 90 45 80 00       	mov    $0x804590,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  802cb4:	eb 13                	jmp    802cc9 <dev_lookup+0x23>
  802cb6:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  802cb9:	39 08                	cmp    %ecx,(%eax)
  802cbb:	75 0c                	jne    802cc9 <dev_lookup+0x23>
			*dev = devtab[i];
  802cbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802cc0:	89 01                	mov    %eax,(%ecx)
			return 0;
  802cc2:	b8 00 00 00 00       	mov    $0x0,%eax
  802cc7:	eb 2e                	jmp    802cf7 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  802cc9:	8b 02                	mov    (%edx),%eax
  802ccb:	85 c0                	test   %eax,%eax
  802ccd:	75 e7                	jne    802cb6 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802ccf:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802cd4:	8b 40 7c             	mov    0x7c(%eax),%eax
  802cd7:	83 ec 04             	sub    $0x4,%esp
  802cda:	51                   	push   %ecx
  802cdb:	50                   	push   %eax
  802cdc:	68 10 45 80 00       	push   $0x804510
  802ce1:	e8 99 ee ff ff       	call   801b7f <cprintf>
	*dev = 0;
  802ce6:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ce9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  802cef:	83 c4 10             	add    $0x10,%esp
  802cf2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802cf7:	c9                   	leave  
  802cf8:	c3                   	ret    

00802cf9 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  802cf9:	55                   	push   %ebp
  802cfa:	89 e5                	mov    %esp,%ebp
  802cfc:	56                   	push   %esi
  802cfd:	53                   	push   %ebx
  802cfe:	83 ec 10             	sub    $0x10,%esp
  802d01:	8b 75 08             	mov    0x8(%ebp),%esi
  802d04:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802d07:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d0a:	50                   	push   %eax
  802d0b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  802d11:	c1 e8 0c             	shr    $0xc,%eax
  802d14:	50                   	push   %eax
  802d15:	e8 36 ff ff ff       	call   802c50 <fd_lookup>
  802d1a:	83 c4 08             	add    $0x8,%esp
  802d1d:	85 c0                	test   %eax,%eax
  802d1f:	78 05                	js     802d26 <fd_close+0x2d>
	    || fd != fd2)
  802d21:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  802d24:	74 0c                	je     802d32 <fd_close+0x39>
		return (must_exist ? r : 0);
  802d26:	84 db                	test   %bl,%bl
  802d28:	ba 00 00 00 00       	mov    $0x0,%edx
  802d2d:	0f 44 c2             	cmove  %edx,%eax
  802d30:	eb 41                	jmp    802d73 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802d32:	83 ec 08             	sub    $0x8,%esp
  802d35:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d38:	50                   	push   %eax
  802d39:	ff 36                	pushl  (%esi)
  802d3b:	e8 66 ff ff ff       	call   802ca6 <dev_lookup>
  802d40:	89 c3                	mov    %eax,%ebx
  802d42:	83 c4 10             	add    $0x10,%esp
  802d45:	85 c0                	test   %eax,%eax
  802d47:	78 1a                	js     802d63 <fd_close+0x6a>
		if (dev->dev_close)
  802d49:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d4c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  802d4f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  802d54:	85 c0                	test   %eax,%eax
  802d56:	74 0b                	je     802d63 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  802d58:	83 ec 0c             	sub    $0xc,%esp
  802d5b:	56                   	push   %esi
  802d5c:	ff d0                	call   *%eax
  802d5e:	89 c3                	mov    %eax,%ebx
  802d60:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802d63:	83 ec 08             	sub    $0x8,%esp
  802d66:	56                   	push   %esi
  802d67:	6a 00                	push   $0x0
  802d69:	e8 1e f8 ff ff       	call   80258c <sys_page_unmap>
	return r;
  802d6e:	83 c4 10             	add    $0x10,%esp
  802d71:	89 d8                	mov    %ebx,%eax
}
  802d73:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802d76:	5b                   	pop    %ebx
  802d77:	5e                   	pop    %esi
  802d78:	5d                   	pop    %ebp
  802d79:	c3                   	ret    

00802d7a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  802d7a:	55                   	push   %ebp
  802d7b:	89 e5                	mov    %esp,%ebp
  802d7d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802d80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d83:	50                   	push   %eax
  802d84:	ff 75 08             	pushl  0x8(%ebp)
  802d87:	e8 c4 fe ff ff       	call   802c50 <fd_lookup>
  802d8c:	83 c4 08             	add    $0x8,%esp
  802d8f:	85 c0                	test   %eax,%eax
  802d91:	78 10                	js     802da3 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  802d93:	83 ec 08             	sub    $0x8,%esp
  802d96:	6a 01                	push   $0x1
  802d98:	ff 75 f4             	pushl  -0xc(%ebp)
  802d9b:	e8 59 ff ff ff       	call   802cf9 <fd_close>
  802da0:	83 c4 10             	add    $0x10,%esp
}
  802da3:	c9                   	leave  
  802da4:	c3                   	ret    

00802da5 <close_all>:

void
close_all(void)
{
  802da5:	55                   	push   %ebp
  802da6:	89 e5                	mov    %esp,%ebp
  802da8:	53                   	push   %ebx
  802da9:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802dac:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802db1:	83 ec 0c             	sub    $0xc,%esp
  802db4:	53                   	push   %ebx
  802db5:	e8 c0 ff ff ff       	call   802d7a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  802dba:	83 c3 01             	add    $0x1,%ebx
  802dbd:	83 c4 10             	add    $0x10,%esp
  802dc0:	83 fb 20             	cmp    $0x20,%ebx
  802dc3:	75 ec                	jne    802db1 <close_all+0xc>
		close(i);
}
  802dc5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802dc8:	c9                   	leave  
  802dc9:	c3                   	ret    

00802dca <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802dca:	55                   	push   %ebp
  802dcb:	89 e5                	mov    %esp,%ebp
  802dcd:	57                   	push   %edi
  802dce:	56                   	push   %esi
  802dcf:	53                   	push   %ebx
  802dd0:	83 ec 2c             	sub    $0x2c,%esp
  802dd3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802dd6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802dd9:	50                   	push   %eax
  802dda:	ff 75 08             	pushl  0x8(%ebp)
  802ddd:	e8 6e fe ff ff       	call   802c50 <fd_lookup>
  802de2:	83 c4 08             	add    $0x8,%esp
  802de5:	85 c0                	test   %eax,%eax
  802de7:	0f 88 c1 00 00 00    	js     802eae <dup+0xe4>
		return r;
	close(newfdnum);
  802ded:	83 ec 0c             	sub    $0xc,%esp
  802df0:	56                   	push   %esi
  802df1:	e8 84 ff ff ff       	call   802d7a <close>

	newfd = INDEX2FD(newfdnum);
  802df6:	89 f3                	mov    %esi,%ebx
  802df8:	c1 e3 0c             	shl    $0xc,%ebx
  802dfb:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  802e01:	83 c4 04             	add    $0x4,%esp
  802e04:	ff 75 e4             	pushl  -0x1c(%ebp)
  802e07:	e8 de fd ff ff       	call   802bea <fd2data>
  802e0c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  802e0e:	89 1c 24             	mov    %ebx,(%esp)
  802e11:	e8 d4 fd ff ff       	call   802bea <fd2data>
  802e16:	83 c4 10             	add    $0x10,%esp
  802e19:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802e1c:	89 f8                	mov    %edi,%eax
  802e1e:	c1 e8 16             	shr    $0x16,%eax
  802e21:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802e28:	a8 01                	test   $0x1,%al
  802e2a:	74 37                	je     802e63 <dup+0x99>
  802e2c:	89 f8                	mov    %edi,%eax
  802e2e:	c1 e8 0c             	shr    $0xc,%eax
  802e31:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802e38:	f6 c2 01             	test   $0x1,%dl
  802e3b:	74 26                	je     802e63 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802e3d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802e44:	83 ec 0c             	sub    $0xc,%esp
  802e47:	25 07 0e 00 00       	and    $0xe07,%eax
  802e4c:	50                   	push   %eax
  802e4d:	ff 75 d4             	pushl  -0x2c(%ebp)
  802e50:	6a 00                	push   $0x0
  802e52:	57                   	push   %edi
  802e53:	6a 00                	push   $0x0
  802e55:	e8 f0 f6 ff ff       	call   80254a <sys_page_map>
  802e5a:	89 c7                	mov    %eax,%edi
  802e5c:	83 c4 20             	add    $0x20,%esp
  802e5f:	85 c0                	test   %eax,%eax
  802e61:	78 2e                	js     802e91 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802e63:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802e66:	89 d0                	mov    %edx,%eax
  802e68:	c1 e8 0c             	shr    $0xc,%eax
  802e6b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802e72:	83 ec 0c             	sub    $0xc,%esp
  802e75:	25 07 0e 00 00       	and    $0xe07,%eax
  802e7a:	50                   	push   %eax
  802e7b:	53                   	push   %ebx
  802e7c:	6a 00                	push   $0x0
  802e7e:	52                   	push   %edx
  802e7f:	6a 00                	push   $0x0
  802e81:	e8 c4 f6 ff ff       	call   80254a <sys_page_map>
  802e86:	89 c7                	mov    %eax,%edi
  802e88:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  802e8b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802e8d:	85 ff                	test   %edi,%edi
  802e8f:	79 1d                	jns    802eae <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802e91:	83 ec 08             	sub    $0x8,%esp
  802e94:	53                   	push   %ebx
  802e95:	6a 00                	push   $0x0
  802e97:	e8 f0 f6 ff ff       	call   80258c <sys_page_unmap>
	sys_page_unmap(0, nva);
  802e9c:	83 c4 08             	add    $0x8,%esp
  802e9f:	ff 75 d4             	pushl  -0x2c(%ebp)
  802ea2:	6a 00                	push   $0x0
  802ea4:	e8 e3 f6 ff ff       	call   80258c <sys_page_unmap>
	return r;
  802ea9:	83 c4 10             	add    $0x10,%esp
  802eac:	89 f8                	mov    %edi,%eax
}
  802eae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802eb1:	5b                   	pop    %ebx
  802eb2:	5e                   	pop    %esi
  802eb3:	5f                   	pop    %edi
  802eb4:	5d                   	pop    %ebp
  802eb5:	c3                   	ret    

00802eb6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802eb6:	55                   	push   %ebp
  802eb7:	89 e5                	mov    %esp,%ebp
  802eb9:	53                   	push   %ebx
  802eba:	83 ec 14             	sub    $0x14,%esp
  802ebd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802ec0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802ec3:	50                   	push   %eax
  802ec4:	53                   	push   %ebx
  802ec5:	e8 86 fd ff ff       	call   802c50 <fd_lookup>
  802eca:	83 c4 08             	add    $0x8,%esp
  802ecd:	89 c2                	mov    %eax,%edx
  802ecf:	85 c0                	test   %eax,%eax
  802ed1:	78 6d                	js     802f40 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802ed3:	83 ec 08             	sub    $0x8,%esp
  802ed6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802ed9:	50                   	push   %eax
  802eda:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802edd:	ff 30                	pushl  (%eax)
  802edf:	e8 c2 fd ff ff       	call   802ca6 <dev_lookup>
  802ee4:	83 c4 10             	add    $0x10,%esp
  802ee7:	85 c0                	test   %eax,%eax
  802ee9:	78 4c                	js     802f37 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802eeb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802eee:	8b 42 08             	mov    0x8(%edx),%eax
  802ef1:	83 e0 03             	and    $0x3,%eax
  802ef4:	83 f8 01             	cmp    $0x1,%eax
  802ef7:	75 21                	jne    802f1a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802ef9:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802efe:	8b 40 7c             	mov    0x7c(%eax),%eax
  802f01:	83 ec 04             	sub    $0x4,%esp
  802f04:	53                   	push   %ebx
  802f05:	50                   	push   %eax
  802f06:	68 54 45 80 00       	push   $0x804554
  802f0b:	e8 6f ec ff ff       	call   801b7f <cprintf>
		return -E_INVAL;
  802f10:	83 c4 10             	add    $0x10,%esp
  802f13:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802f18:	eb 26                	jmp    802f40 <read+0x8a>
	}
	if (!dev->dev_read)
  802f1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802f1d:	8b 40 08             	mov    0x8(%eax),%eax
  802f20:	85 c0                	test   %eax,%eax
  802f22:	74 17                	je     802f3b <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  802f24:	83 ec 04             	sub    $0x4,%esp
  802f27:	ff 75 10             	pushl  0x10(%ebp)
  802f2a:	ff 75 0c             	pushl  0xc(%ebp)
  802f2d:	52                   	push   %edx
  802f2e:	ff d0                	call   *%eax
  802f30:	89 c2                	mov    %eax,%edx
  802f32:	83 c4 10             	add    $0x10,%esp
  802f35:	eb 09                	jmp    802f40 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802f37:	89 c2                	mov    %eax,%edx
  802f39:	eb 05                	jmp    802f40 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802f3b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  802f40:	89 d0                	mov    %edx,%eax
  802f42:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f45:	c9                   	leave  
  802f46:	c3                   	ret    

00802f47 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802f47:	55                   	push   %ebp
  802f48:	89 e5                	mov    %esp,%ebp
  802f4a:	57                   	push   %edi
  802f4b:	56                   	push   %esi
  802f4c:	53                   	push   %ebx
  802f4d:	83 ec 0c             	sub    $0xc,%esp
  802f50:	8b 7d 08             	mov    0x8(%ebp),%edi
  802f53:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802f56:	bb 00 00 00 00       	mov    $0x0,%ebx
  802f5b:	eb 21                	jmp    802f7e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802f5d:	83 ec 04             	sub    $0x4,%esp
  802f60:	89 f0                	mov    %esi,%eax
  802f62:	29 d8                	sub    %ebx,%eax
  802f64:	50                   	push   %eax
  802f65:	89 d8                	mov    %ebx,%eax
  802f67:	03 45 0c             	add    0xc(%ebp),%eax
  802f6a:	50                   	push   %eax
  802f6b:	57                   	push   %edi
  802f6c:	e8 45 ff ff ff       	call   802eb6 <read>
		if (m < 0)
  802f71:	83 c4 10             	add    $0x10,%esp
  802f74:	85 c0                	test   %eax,%eax
  802f76:	78 10                	js     802f88 <readn+0x41>
			return m;
		if (m == 0)
  802f78:	85 c0                	test   %eax,%eax
  802f7a:	74 0a                	je     802f86 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802f7c:	01 c3                	add    %eax,%ebx
  802f7e:	39 f3                	cmp    %esi,%ebx
  802f80:	72 db                	jb     802f5d <readn+0x16>
  802f82:	89 d8                	mov    %ebx,%eax
  802f84:	eb 02                	jmp    802f88 <readn+0x41>
  802f86:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  802f88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802f8b:	5b                   	pop    %ebx
  802f8c:	5e                   	pop    %esi
  802f8d:	5f                   	pop    %edi
  802f8e:	5d                   	pop    %ebp
  802f8f:	c3                   	ret    

00802f90 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802f90:	55                   	push   %ebp
  802f91:	89 e5                	mov    %esp,%ebp
  802f93:	53                   	push   %ebx
  802f94:	83 ec 14             	sub    $0x14,%esp
  802f97:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802f9a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802f9d:	50                   	push   %eax
  802f9e:	53                   	push   %ebx
  802f9f:	e8 ac fc ff ff       	call   802c50 <fd_lookup>
  802fa4:	83 c4 08             	add    $0x8,%esp
  802fa7:	89 c2                	mov    %eax,%edx
  802fa9:	85 c0                	test   %eax,%eax
  802fab:	78 68                	js     803015 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802fad:	83 ec 08             	sub    $0x8,%esp
  802fb0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802fb3:	50                   	push   %eax
  802fb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802fb7:	ff 30                	pushl  (%eax)
  802fb9:	e8 e8 fc ff ff       	call   802ca6 <dev_lookup>
  802fbe:	83 c4 10             	add    $0x10,%esp
  802fc1:	85 c0                	test   %eax,%eax
  802fc3:	78 47                	js     80300c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802fc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802fc8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802fcc:	75 21                	jne    802fef <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802fce:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802fd3:	8b 40 7c             	mov    0x7c(%eax),%eax
  802fd6:	83 ec 04             	sub    $0x4,%esp
  802fd9:	53                   	push   %ebx
  802fda:	50                   	push   %eax
  802fdb:	68 70 45 80 00       	push   $0x804570
  802fe0:	e8 9a eb ff ff       	call   801b7f <cprintf>
		return -E_INVAL;
  802fe5:	83 c4 10             	add    $0x10,%esp
  802fe8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802fed:	eb 26                	jmp    803015 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802fef:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802ff2:	8b 52 0c             	mov    0xc(%edx),%edx
  802ff5:	85 d2                	test   %edx,%edx
  802ff7:	74 17                	je     803010 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802ff9:	83 ec 04             	sub    $0x4,%esp
  802ffc:	ff 75 10             	pushl  0x10(%ebp)
  802fff:	ff 75 0c             	pushl  0xc(%ebp)
  803002:	50                   	push   %eax
  803003:	ff d2                	call   *%edx
  803005:	89 c2                	mov    %eax,%edx
  803007:	83 c4 10             	add    $0x10,%esp
  80300a:	eb 09                	jmp    803015 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80300c:	89 c2                	mov    %eax,%edx
  80300e:	eb 05                	jmp    803015 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  803010:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  803015:	89 d0                	mov    %edx,%eax
  803017:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80301a:	c9                   	leave  
  80301b:	c3                   	ret    

0080301c <seek>:

int
seek(int fdnum, off_t offset)
{
  80301c:	55                   	push   %ebp
  80301d:	89 e5                	mov    %esp,%ebp
  80301f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803022:	8d 45 fc             	lea    -0x4(%ebp),%eax
  803025:	50                   	push   %eax
  803026:	ff 75 08             	pushl  0x8(%ebp)
  803029:	e8 22 fc ff ff       	call   802c50 <fd_lookup>
  80302e:	83 c4 08             	add    $0x8,%esp
  803031:	85 c0                	test   %eax,%eax
  803033:	78 0e                	js     803043 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  803035:	8b 45 fc             	mov    -0x4(%ebp),%eax
  803038:	8b 55 0c             	mov    0xc(%ebp),%edx
  80303b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80303e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803043:	c9                   	leave  
  803044:	c3                   	ret    

00803045 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  803045:	55                   	push   %ebp
  803046:	89 e5                	mov    %esp,%ebp
  803048:	53                   	push   %ebx
  803049:	83 ec 14             	sub    $0x14,%esp
  80304c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80304f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803052:	50                   	push   %eax
  803053:	53                   	push   %ebx
  803054:	e8 f7 fb ff ff       	call   802c50 <fd_lookup>
  803059:	83 c4 08             	add    $0x8,%esp
  80305c:	89 c2                	mov    %eax,%edx
  80305e:	85 c0                	test   %eax,%eax
  803060:	78 65                	js     8030c7 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  803062:	83 ec 08             	sub    $0x8,%esp
  803065:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803068:	50                   	push   %eax
  803069:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80306c:	ff 30                	pushl  (%eax)
  80306e:	e8 33 fc ff ff       	call   802ca6 <dev_lookup>
  803073:	83 c4 10             	add    $0x10,%esp
  803076:	85 c0                	test   %eax,%eax
  803078:	78 44                	js     8030be <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80307a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80307d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  803081:	75 21                	jne    8030a4 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  803083:	a1 0c a0 80 00       	mov    0x80a00c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  803088:	8b 40 7c             	mov    0x7c(%eax),%eax
  80308b:	83 ec 04             	sub    $0x4,%esp
  80308e:	53                   	push   %ebx
  80308f:	50                   	push   %eax
  803090:	68 30 45 80 00       	push   $0x804530
  803095:	e8 e5 ea ff ff       	call   801b7f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80309a:	83 c4 10             	add    $0x10,%esp
  80309d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8030a2:	eb 23                	jmp    8030c7 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8030a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8030a7:	8b 52 18             	mov    0x18(%edx),%edx
  8030aa:	85 d2                	test   %edx,%edx
  8030ac:	74 14                	je     8030c2 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8030ae:	83 ec 08             	sub    $0x8,%esp
  8030b1:	ff 75 0c             	pushl  0xc(%ebp)
  8030b4:	50                   	push   %eax
  8030b5:	ff d2                	call   *%edx
  8030b7:	89 c2                	mov    %eax,%edx
  8030b9:	83 c4 10             	add    $0x10,%esp
  8030bc:	eb 09                	jmp    8030c7 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8030be:	89 c2                	mov    %eax,%edx
  8030c0:	eb 05                	jmp    8030c7 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8030c2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8030c7:	89 d0                	mov    %edx,%eax
  8030c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8030cc:	c9                   	leave  
  8030cd:	c3                   	ret    

008030ce <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8030ce:	55                   	push   %ebp
  8030cf:	89 e5                	mov    %esp,%ebp
  8030d1:	53                   	push   %ebx
  8030d2:	83 ec 14             	sub    $0x14,%esp
  8030d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8030d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8030db:	50                   	push   %eax
  8030dc:	ff 75 08             	pushl  0x8(%ebp)
  8030df:	e8 6c fb ff ff       	call   802c50 <fd_lookup>
  8030e4:	83 c4 08             	add    $0x8,%esp
  8030e7:	89 c2                	mov    %eax,%edx
  8030e9:	85 c0                	test   %eax,%eax
  8030eb:	78 58                	js     803145 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8030ed:	83 ec 08             	sub    $0x8,%esp
  8030f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8030f3:	50                   	push   %eax
  8030f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8030f7:	ff 30                	pushl  (%eax)
  8030f9:	e8 a8 fb ff ff       	call   802ca6 <dev_lookup>
  8030fe:	83 c4 10             	add    $0x10,%esp
  803101:	85 c0                	test   %eax,%eax
  803103:	78 37                	js     80313c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  803105:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803108:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80310c:	74 32                	je     803140 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80310e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  803111:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  803118:	00 00 00 
	stat->st_isdir = 0;
  80311b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  803122:	00 00 00 
	stat->st_dev = dev;
  803125:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80312b:	83 ec 08             	sub    $0x8,%esp
  80312e:	53                   	push   %ebx
  80312f:	ff 75 f0             	pushl  -0x10(%ebp)
  803132:	ff 50 14             	call   *0x14(%eax)
  803135:	89 c2                	mov    %eax,%edx
  803137:	83 c4 10             	add    $0x10,%esp
  80313a:	eb 09                	jmp    803145 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80313c:	89 c2                	mov    %eax,%edx
  80313e:	eb 05                	jmp    803145 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  803140:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  803145:	89 d0                	mov    %edx,%eax
  803147:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80314a:	c9                   	leave  
  80314b:	c3                   	ret    

0080314c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80314c:	55                   	push   %ebp
  80314d:	89 e5                	mov    %esp,%ebp
  80314f:	56                   	push   %esi
  803150:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  803151:	83 ec 08             	sub    $0x8,%esp
  803154:	6a 00                	push   $0x0
  803156:	ff 75 08             	pushl  0x8(%ebp)
  803159:	e8 e3 01 00 00       	call   803341 <open>
  80315e:	89 c3                	mov    %eax,%ebx
  803160:	83 c4 10             	add    $0x10,%esp
  803163:	85 c0                	test   %eax,%eax
  803165:	78 1b                	js     803182 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  803167:	83 ec 08             	sub    $0x8,%esp
  80316a:	ff 75 0c             	pushl  0xc(%ebp)
  80316d:	50                   	push   %eax
  80316e:	e8 5b ff ff ff       	call   8030ce <fstat>
  803173:	89 c6                	mov    %eax,%esi
	close(fd);
  803175:	89 1c 24             	mov    %ebx,(%esp)
  803178:	e8 fd fb ff ff       	call   802d7a <close>
	return r;
  80317d:	83 c4 10             	add    $0x10,%esp
  803180:	89 f0                	mov    %esi,%eax
}
  803182:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803185:	5b                   	pop    %ebx
  803186:	5e                   	pop    %esi
  803187:	5d                   	pop    %ebp
  803188:	c3                   	ret    

00803189 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  803189:	55                   	push   %ebp
  80318a:	89 e5                	mov    %esp,%ebp
  80318c:	56                   	push   %esi
  80318d:	53                   	push   %ebx
  80318e:	89 c6                	mov    %eax,%esi
  803190:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  803192:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  803199:	75 12                	jne    8031ad <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80319b:	83 ec 0c             	sub    $0xc,%esp
  80319e:	6a 01                	push   $0x1
  8031a0:	e8 f3 f9 ff ff       	call   802b98 <ipc_find_env>
  8031a5:	a3 00 a0 80 00       	mov    %eax,0x80a000
  8031aa:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8031ad:	6a 07                	push   $0x7
  8031af:	68 00 b0 80 00       	push   $0x80b000
  8031b4:	56                   	push   %esi
  8031b5:	ff 35 00 a0 80 00    	pushl  0x80a000
  8031bb:	e8 76 f9 ff ff       	call   802b36 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8031c0:	83 c4 0c             	add    $0xc,%esp
  8031c3:	6a 00                	push   $0x0
  8031c5:	53                   	push   %ebx
  8031c6:	6a 00                	push   $0x0
  8031c8:	e8 ee f8 ff ff       	call   802abb <ipc_recv>
}
  8031cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8031d0:	5b                   	pop    %ebx
  8031d1:	5e                   	pop    %esi
  8031d2:	5d                   	pop    %ebp
  8031d3:	c3                   	ret    

008031d4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8031d4:	55                   	push   %ebp
  8031d5:	89 e5                	mov    %esp,%ebp
  8031d7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8031da:	8b 45 08             	mov    0x8(%ebp),%eax
  8031dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8031e0:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  8031e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8031e8:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8031ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8031f2:	b8 02 00 00 00       	mov    $0x2,%eax
  8031f7:	e8 8d ff ff ff       	call   803189 <fsipc>
}
  8031fc:	c9                   	leave  
  8031fd:	c3                   	ret    

008031fe <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8031fe:	55                   	push   %ebp
  8031ff:	89 e5                	mov    %esp,%ebp
  803201:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  803204:	8b 45 08             	mov    0x8(%ebp),%eax
  803207:	8b 40 0c             	mov    0xc(%eax),%eax
  80320a:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  80320f:	ba 00 00 00 00       	mov    $0x0,%edx
  803214:	b8 06 00 00 00       	mov    $0x6,%eax
  803219:	e8 6b ff ff ff       	call   803189 <fsipc>
}
  80321e:	c9                   	leave  
  80321f:	c3                   	ret    

00803220 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  803220:	55                   	push   %ebp
  803221:	89 e5                	mov    %esp,%ebp
  803223:	53                   	push   %ebx
  803224:	83 ec 04             	sub    $0x4,%esp
  803227:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80322a:	8b 45 08             	mov    0x8(%ebp),%eax
  80322d:	8b 40 0c             	mov    0xc(%eax),%eax
  803230:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  803235:	ba 00 00 00 00       	mov    $0x0,%edx
  80323a:	b8 05 00 00 00       	mov    $0x5,%eax
  80323f:	e8 45 ff ff ff       	call   803189 <fsipc>
  803244:	85 c0                	test   %eax,%eax
  803246:	78 2c                	js     803274 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  803248:	83 ec 08             	sub    $0x8,%esp
  80324b:	68 00 b0 80 00       	push   $0x80b000
  803250:	53                   	push   %ebx
  803251:	e8 ae ee ff ff       	call   802104 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  803256:	a1 80 b0 80 00       	mov    0x80b080,%eax
  80325b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  803261:	a1 84 b0 80 00       	mov    0x80b084,%eax
  803266:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80326c:	83 c4 10             	add    $0x10,%esp
  80326f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803274:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803277:	c9                   	leave  
  803278:	c3                   	ret    

00803279 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  803279:	55                   	push   %ebp
  80327a:	89 e5                	mov    %esp,%ebp
  80327c:	83 ec 0c             	sub    $0xc,%esp
  80327f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  803282:	8b 55 08             	mov    0x8(%ebp),%edx
  803285:	8b 52 0c             	mov    0xc(%edx),%edx
  803288:	89 15 00 b0 80 00    	mov    %edx,0x80b000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80328e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  803293:	ba f8 0f 00 00       	mov    $0xff8,%edx
  803298:	0f 47 c2             	cmova  %edx,%eax
  80329b:	a3 04 b0 80 00       	mov    %eax,0x80b004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8032a0:	50                   	push   %eax
  8032a1:	ff 75 0c             	pushl  0xc(%ebp)
  8032a4:	68 08 b0 80 00       	push   $0x80b008
  8032a9:	e8 e8 ef ff ff       	call   802296 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8032ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8032b3:	b8 04 00 00 00       	mov    $0x4,%eax
  8032b8:	e8 cc fe ff ff       	call   803189 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8032bd:	c9                   	leave  
  8032be:	c3                   	ret    

008032bf <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8032bf:	55                   	push   %ebp
  8032c0:	89 e5                	mov    %esp,%ebp
  8032c2:	56                   	push   %esi
  8032c3:	53                   	push   %ebx
  8032c4:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8032c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8032ca:	8b 40 0c             	mov    0xc(%eax),%eax
  8032cd:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  8032d2:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8032d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8032dd:	b8 03 00 00 00       	mov    $0x3,%eax
  8032e2:	e8 a2 fe ff ff       	call   803189 <fsipc>
  8032e7:	89 c3                	mov    %eax,%ebx
  8032e9:	85 c0                	test   %eax,%eax
  8032eb:	78 4b                	js     803338 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8032ed:	39 c6                	cmp    %eax,%esi
  8032ef:	73 16                	jae    803307 <devfile_read+0x48>
  8032f1:	68 a0 45 80 00       	push   $0x8045a0
  8032f6:	68 dd 3b 80 00       	push   $0x803bdd
  8032fb:	6a 7c                	push   $0x7c
  8032fd:	68 a7 45 80 00       	push   $0x8045a7
  803302:	e8 9f e7 ff ff       	call   801aa6 <_panic>
	assert(r <= PGSIZE);
  803307:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80330c:	7e 16                	jle    803324 <devfile_read+0x65>
  80330e:	68 b2 45 80 00       	push   $0x8045b2
  803313:	68 dd 3b 80 00       	push   $0x803bdd
  803318:	6a 7d                	push   $0x7d
  80331a:	68 a7 45 80 00       	push   $0x8045a7
  80331f:	e8 82 e7 ff ff       	call   801aa6 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  803324:	83 ec 04             	sub    $0x4,%esp
  803327:	50                   	push   %eax
  803328:	68 00 b0 80 00       	push   $0x80b000
  80332d:	ff 75 0c             	pushl  0xc(%ebp)
  803330:	e8 61 ef ff ff       	call   802296 <memmove>
	return r;
  803335:	83 c4 10             	add    $0x10,%esp
}
  803338:	89 d8                	mov    %ebx,%eax
  80333a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80333d:	5b                   	pop    %ebx
  80333e:	5e                   	pop    %esi
  80333f:	5d                   	pop    %ebp
  803340:	c3                   	ret    

00803341 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  803341:	55                   	push   %ebp
  803342:	89 e5                	mov    %esp,%ebp
  803344:	53                   	push   %ebx
  803345:	83 ec 20             	sub    $0x20,%esp
  803348:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80334b:	53                   	push   %ebx
  80334c:	e8 7a ed ff ff       	call   8020cb <strlen>
  803351:	83 c4 10             	add    $0x10,%esp
  803354:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  803359:	7f 67                	jg     8033c2 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80335b:	83 ec 0c             	sub    $0xc,%esp
  80335e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803361:	50                   	push   %eax
  803362:	e8 9a f8 ff ff       	call   802c01 <fd_alloc>
  803367:	83 c4 10             	add    $0x10,%esp
		return r;
  80336a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80336c:	85 c0                	test   %eax,%eax
  80336e:	78 57                	js     8033c7 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  803370:	83 ec 08             	sub    $0x8,%esp
  803373:	53                   	push   %ebx
  803374:	68 00 b0 80 00       	push   $0x80b000
  803379:	e8 86 ed ff ff       	call   802104 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80337e:	8b 45 0c             	mov    0xc(%ebp),%eax
  803381:	a3 00 b4 80 00       	mov    %eax,0x80b400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  803386:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803389:	b8 01 00 00 00       	mov    $0x1,%eax
  80338e:	e8 f6 fd ff ff       	call   803189 <fsipc>
  803393:	89 c3                	mov    %eax,%ebx
  803395:	83 c4 10             	add    $0x10,%esp
  803398:	85 c0                	test   %eax,%eax
  80339a:	79 14                	jns    8033b0 <open+0x6f>
		fd_close(fd, 0);
  80339c:	83 ec 08             	sub    $0x8,%esp
  80339f:	6a 00                	push   $0x0
  8033a1:	ff 75 f4             	pushl  -0xc(%ebp)
  8033a4:	e8 50 f9 ff ff       	call   802cf9 <fd_close>
		return r;
  8033a9:	83 c4 10             	add    $0x10,%esp
  8033ac:	89 da                	mov    %ebx,%edx
  8033ae:	eb 17                	jmp    8033c7 <open+0x86>
	}

	return fd2num(fd);
  8033b0:	83 ec 0c             	sub    $0xc,%esp
  8033b3:	ff 75 f4             	pushl  -0xc(%ebp)
  8033b6:	e8 1f f8 ff ff       	call   802bda <fd2num>
  8033bb:	89 c2                	mov    %eax,%edx
  8033bd:	83 c4 10             	add    $0x10,%esp
  8033c0:	eb 05                	jmp    8033c7 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8033c2:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8033c7:	89 d0                	mov    %edx,%eax
  8033c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8033cc:	c9                   	leave  
  8033cd:	c3                   	ret    

008033ce <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8033ce:	55                   	push   %ebp
  8033cf:	89 e5                	mov    %esp,%ebp
  8033d1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8033d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8033d9:	b8 08 00 00 00       	mov    $0x8,%eax
  8033de:	e8 a6 fd ff ff       	call   803189 <fsipc>
}
  8033e3:	c9                   	leave  
  8033e4:	c3                   	ret    

008033e5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8033e5:	55                   	push   %ebp
  8033e6:	89 e5                	mov    %esp,%ebp
  8033e8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8033eb:	89 d0                	mov    %edx,%eax
  8033ed:	c1 e8 16             	shr    $0x16,%eax
  8033f0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8033f7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8033fc:	f6 c1 01             	test   $0x1,%cl
  8033ff:	74 1d                	je     80341e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  803401:	c1 ea 0c             	shr    $0xc,%edx
  803404:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80340b:	f6 c2 01             	test   $0x1,%dl
  80340e:	74 0e                	je     80341e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803410:	c1 ea 0c             	shr    $0xc,%edx
  803413:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80341a:	ef 
  80341b:	0f b7 c0             	movzwl %ax,%eax
}
  80341e:	5d                   	pop    %ebp
  80341f:	c3                   	ret    

00803420 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  803420:	55                   	push   %ebp
  803421:	89 e5                	mov    %esp,%ebp
  803423:	56                   	push   %esi
  803424:	53                   	push   %ebx
  803425:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  803428:	83 ec 0c             	sub    $0xc,%esp
  80342b:	ff 75 08             	pushl  0x8(%ebp)
  80342e:	e8 b7 f7 ff ff       	call   802bea <fd2data>
  803433:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  803435:	83 c4 08             	add    $0x8,%esp
  803438:	68 be 45 80 00       	push   $0x8045be
  80343d:	53                   	push   %ebx
  80343e:	e8 c1 ec ff ff       	call   802104 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  803443:	8b 46 04             	mov    0x4(%esi),%eax
  803446:	2b 06                	sub    (%esi),%eax
  803448:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80344e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  803455:	00 00 00 
	stat->st_dev = &devpipe;
  803458:	c7 83 88 00 00 00 80 	movl   $0x809080,0x88(%ebx)
  80345f:	90 80 00 
	return 0;
}
  803462:	b8 00 00 00 00       	mov    $0x0,%eax
  803467:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80346a:	5b                   	pop    %ebx
  80346b:	5e                   	pop    %esi
  80346c:	5d                   	pop    %ebp
  80346d:	c3                   	ret    

0080346e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80346e:	55                   	push   %ebp
  80346f:	89 e5                	mov    %esp,%ebp
  803471:	53                   	push   %ebx
  803472:	83 ec 0c             	sub    $0xc,%esp
  803475:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  803478:	53                   	push   %ebx
  803479:	6a 00                	push   $0x0
  80347b:	e8 0c f1 ff ff       	call   80258c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  803480:	89 1c 24             	mov    %ebx,(%esp)
  803483:	e8 62 f7 ff ff       	call   802bea <fd2data>
  803488:	83 c4 08             	add    $0x8,%esp
  80348b:	50                   	push   %eax
  80348c:	6a 00                	push   $0x0
  80348e:	e8 f9 f0 ff ff       	call   80258c <sys_page_unmap>
}
  803493:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803496:	c9                   	leave  
  803497:	c3                   	ret    

00803498 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  803498:	55                   	push   %ebp
  803499:	89 e5                	mov    %esp,%ebp
  80349b:	57                   	push   %edi
  80349c:	56                   	push   %esi
  80349d:	53                   	push   %ebx
  80349e:	83 ec 1c             	sub    $0x1c,%esp
  8034a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8034a4:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8034a6:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8034ab:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8034b1:	83 ec 0c             	sub    $0xc,%esp
  8034b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8034b7:	e8 29 ff ff ff       	call   8033e5 <pageref>
  8034bc:	89 c3                	mov    %eax,%ebx
  8034be:	89 3c 24             	mov    %edi,(%esp)
  8034c1:	e8 1f ff ff ff       	call   8033e5 <pageref>
  8034c6:	83 c4 10             	add    $0x10,%esp
  8034c9:	39 c3                	cmp    %eax,%ebx
  8034cb:	0f 94 c1             	sete   %cl
  8034ce:	0f b6 c9             	movzbl %cl,%ecx
  8034d1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8034d4:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  8034da:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  8034e0:	39 ce                	cmp    %ecx,%esi
  8034e2:	74 1e                	je     803502 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  8034e4:	39 c3                	cmp    %eax,%ebx
  8034e6:	75 be                	jne    8034a6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8034e8:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  8034ee:	ff 75 e4             	pushl  -0x1c(%ebp)
  8034f1:	50                   	push   %eax
  8034f2:	56                   	push   %esi
  8034f3:	68 c5 45 80 00       	push   $0x8045c5
  8034f8:	e8 82 e6 ff ff       	call   801b7f <cprintf>
  8034fd:	83 c4 10             	add    $0x10,%esp
  803500:	eb a4                	jmp    8034a6 <_pipeisclosed+0xe>
	}
}
  803502:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803505:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803508:	5b                   	pop    %ebx
  803509:	5e                   	pop    %esi
  80350a:	5f                   	pop    %edi
  80350b:	5d                   	pop    %ebp
  80350c:	c3                   	ret    

0080350d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80350d:	55                   	push   %ebp
  80350e:	89 e5                	mov    %esp,%ebp
  803510:	57                   	push   %edi
  803511:	56                   	push   %esi
  803512:	53                   	push   %ebx
  803513:	83 ec 28             	sub    $0x28,%esp
  803516:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  803519:	56                   	push   %esi
  80351a:	e8 cb f6 ff ff       	call   802bea <fd2data>
  80351f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803521:	83 c4 10             	add    $0x10,%esp
  803524:	bf 00 00 00 00       	mov    $0x0,%edi
  803529:	eb 4b                	jmp    803576 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80352b:	89 da                	mov    %ebx,%edx
  80352d:	89 f0                	mov    %esi,%eax
  80352f:	e8 64 ff ff ff       	call   803498 <_pipeisclosed>
  803534:	85 c0                	test   %eax,%eax
  803536:	75 48                	jne    803580 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  803538:	e8 ab ef ff ff       	call   8024e8 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80353d:	8b 43 04             	mov    0x4(%ebx),%eax
  803540:	8b 0b                	mov    (%ebx),%ecx
  803542:	8d 51 20             	lea    0x20(%ecx),%edx
  803545:	39 d0                	cmp    %edx,%eax
  803547:	73 e2                	jae    80352b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  803549:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80354c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  803550:	88 4d e7             	mov    %cl,-0x19(%ebp)
  803553:	89 c2                	mov    %eax,%edx
  803555:	c1 fa 1f             	sar    $0x1f,%edx
  803558:	89 d1                	mov    %edx,%ecx
  80355a:	c1 e9 1b             	shr    $0x1b,%ecx
  80355d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  803560:	83 e2 1f             	and    $0x1f,%edx
  803563:	29 ca                	sub    %ecx,%edx
  803565:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  803569:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80356d:	83 c0 01             	add    $0x1,%eax
  803570:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803573:	83 c7 01             	add    $0x1,%edi
  803576:	3b 7d 10             	cmp    0x10(%ebp),%edi
  803579:	75 c2                	jne    80353d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80357b:	8b 45 10             	mov    0x10(%ebp),%eax
  80357e:	eb 05                	jmp    803585 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803580:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  803585:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803588:	5b                   	pop    %ebx
  803589:	5e                   	pop    %esi
  80358a:	5f                   	pop    %edi
  80358b:	5d                   	pop    %ebp
  80358c:	c3                   	ret    

0080358d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80358d:	55                   	push   %ebp
  80358e:	89 e5                	mov    %esp,%ebp
  803590:	57                   	push   %edi
  803591:	56                   	push   %esi
  803592:	53                   	push   %ebx
  803593:	83 ec 18             	sub    $0x18,%esp
  803596:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  803599:	57                   	push   %edi
  80359a:	e8 4b f6 ff ff       	call   802bea <fd2data>
  80359f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8035a1:	83 c4 10             	add    $0x10,%esp
  8035a4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8035a9:	eb 3d                	jmp    8035e8 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8035ab:	85 db                	test   %ebx,%ebx
  8035ad:	74 04                	je     8035b3 <devpipe_read+0x26>
				return i;
  8035af:	89 d8                	mov    %ebx,%eax
  8035b1:	eb 44                	jmp    8035f7 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8035b3:	89 f2                	mov    %esi,%edx
  8035b5:	89 f8                	mov    %edi,%eax
  8035b7:	e8 dc fe ff ff       	call   803498 <_pipeisclosed>
  8035bc:	85 c0                	test   %eax,%eax
  8035be:	75 32                	jne    8035f2 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8035c0:	e8 23 ef ff ff       	call   8024e8 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8035c5:	8b 06                	mov    (%esi),%eax
  8035c7:	3b 46 04             	cmp    0x4(%esi),%eax
  8035ca:	74 df                	je     8035ab <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8035cc:	99                   	cltd   
  8035cd:	c1 ea 1b             	shr    $0x1b,%edx
  8035d0:	01 d0                	add    %edx,%eax
  8035d2:	83 e0 1f             	and    $0x1f,%eax
  8035d5:	29 d0                	sub    %edx,%eax
  8035d7:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8035dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8035df:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8035e2:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8035e5:	83 c3 01             	add    $0x1,%ebx
  8035e8:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8035eb:	75 d8                	jne    8035c5 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8035ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8035f0:	eb 05                	jmp    8035f7 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8035f2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8035f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8035fa:	5b                   	pop    %ebx
  8035fb:	5e                   	pop    %esi
  8035fc:	5f                   	pop    %edi
  8035fd:	5d                   	pop    %ebp
  8035fe:	c3                   	ret    

008035ff <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8035ff:	55                   	push   %ebp
  803600:	89 e5                	mov    %esp,%ebp
  803602:	56                   	push   %esi
  803603:	53                   	push   %ebx
  803604:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  803607:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80360a:	50                   	push   %eax
  80360b:	e8 f1 f5 ff ff       	call   802c01 <fd_alloc>
  803610:	83 c4 10             	add    $0x10,%esp
  803613:	89 c2                	mov    %eax,%edx
  803615:	85 c0                	test   %eax,%eax
  803617:	0f 88 2c 01 00 00    	js     803749 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80361d:	83 ec 04             	sub    $0x4,%esp
  803620:	68 07 04 00 00       	push   $0x407
  803625:	ff 75 f4             	pushl  -0xc(%ebp)
  803628:	6a 00                	push   $0x0
  80362a:	e8 d8 ee ff ff       	call   802507 <sys_page_alloc>
  80362f:	83 c4 10             	add    $0x10,%esp
  803632:	89 c2                	mov    %eax,%edx
  803634:	85 c0                	test   %eax,%eax
  803636:	0f 88 0d 01 00 00    	js     803749 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80363c:	83 ec 0c             	sub    $0xc,%esp
  80363f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803642:	50                   	push   %eax
  803643:	e8 b9 f5 ff ff       	call   802c01 <fd_alloc>
  803648:	89 c3                	mov    %eax,%ebx
  80364a:	83 c4 10             	add    $0x10,%esp
  80364d:	85 c0                	test   %eax,%eax
  80364f:	0f 88 e2 00 00 00    	js     803737 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803655:	83 ec 04             	sub    $0x4,%esp
  803658:	68 07 04 00 00       	push   $0x407
  80365d:	ff 75 f0             	pushl  -0x10(%ebp)
  803660:	6a 00                	push   $0x0
  803662:	e8 a0 ee ff ff       	call   802507 <sys_page_alloc>
  803667:	89 c3                	mov    %eax,%ebx
  803669:	83 c4 10             	add    $0x10,%esp
  80366c:	85 c0                	test   %eax,%eax
  80366e:	0f 88 c3 00 00 00    	js     803737 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  803674:	83 ec 0c             	sub    $0xc,%esp
  803677:	ff 75 f4             	pushl  -0xc(%ebp)
  80367a:	e8 6b f5 ff ff       	call   802bea <fd2data>
  80367f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803681:	83 c4 0c             	add    $0xc,%esp
  803684:	68 07 04 00 00       	push   $0x407
  803689:	50                   	push   %eax
  80368a:	6a 00                	push   $0x0
  80368c:	e8 76 ee ff ff       	call   802507 <sys_page_alloc>
  803691:	89 c3                	mov    %eax,%ebx
  803693:	83 c4 10             	add    $0x10,%esp
  803696:	85 c0                	test   %eax,%eax
  803698:	0f 88 89 00 00 00    	js     803727 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80369e:	83 ec 0c             	sub    $0xc,%esp
  8036a1:	ff 75 f0             	pushl  -0x10(%ebp)
  8036a4:	e8 41 f5 ff ff       	call   802bea <fd2data>
  8036a9:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8036b0:	50                   	push   %eax
  8036b1:	6a 00                	push   $0x0
  8036b3:	56                   	push   %esi
  8036b4:	6a 00                	push   $0x0
  8036b6:	e8 8f ee ff ff       	call   80254a <sys_page_map>
  8036bb:	89 c3                	mov    %eax,%ebx
  8036bd:	83 c4 20             	add    $0x20,%esp
  8036c0:	85 c0                	test   %eax,%eax
  8036c2:	78 55                	js     803719 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8036c4:	8b 15 80 90 80 00    	mov    0x809080,%edx
  8036ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8036cd:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8036cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8036d2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8036d9:	8b 15 80 90 80 00    	mov    0x809080,%edx
  8036df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8036e2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8036e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8036e7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8036ee:	83 ec 0c             	sub    $0xc,%esp
  8036f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8036f4:	e8 e1 f4 ff ff       	call   802bda <fd2num>
  8036f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8036fc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8036fe:	83 c4 04             	add    $0x4,%esp
  803701:	ff 75 f0             	pushl  -0x10(%ebp)
  803704:	e8 d1 f4 ff ff       	call   802bda <fd2num>
  803709:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80370c:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80370f:	83 c4 10             	add    $0x10,%esp
  803712:	ba 00 00 00 00       	mov    $0x0,%edx
  803717:	eb 30                	jmp    803749 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  803719:	83 ec 08             	sub    $0x8,%esp
  80371c:	56                   	push   %esi
  80371d:	6a 00                	push   $0x0
  80371f:	e8 68 ee ff ff       	call   80258c <sys_page_unmap>
  803724:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  803727:	83 ec 08             	sub    $0x8,%esp
  80372a:	ff 75 f0             	pushl  -0x10(%ebp)
  80372d:	6a 00                	push   $0x0
  80372f:	e8 58 ee ff ff       	call   80258c <sys_page_unmap>
  803734:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  803737:	83 ec 08             	sub    $0x8,%esp
  80373a:	ff 75 f4             	pushl  -0xc(%ebp)
  80373d:	6a 00                	push   $0x0
  80373f:	e8 48 ee ff ff       	call   80258c <sys_page_unmap>
  803744:	83 c4 10             	add    $0x10,%esp
  803747:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  803749:	89 d0                	mov    %edx,%eax
  80374b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80374e:	5b                   	pop    %ebx
  80374f:	5e                   	pop    %esi
  803750:	5d                   	pop    %ebp
  803751:	c3                   	ret    

00803752 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  803752:	55                   	push   %ebp
  803753:	89 e5                	mov    %esp,%ebp
  803755:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803758:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80375b:	50                   	push   %eax
  80375c:	ff 75 08             	pushl  0x8(%ebp)
  80375f:	e8 ec f4 ff ff       	call   802c50 <fd_lookup>
  803764:	83 c4 10             	add    $0x10,%esp
  803767:	85 c0                	test   %eax,%eax
  803769:	78 18                	js     803783 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80376b:	83 ec 0c             	sub    $0xc,%esp
  80376e:	ff 75 f4             	pushl  -0xc(%ebp)
  803771:	e8 74 f4 ff ff       	call   802bea <fd2data>
	return _pipeisclosed(fd, p);
  803776:	89 c2                	mov    %eax,%edx
  803778:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80377b:	e8 18 fd ff ff       	call   803498 <_pipeisclosed>
  803780:	83 c4 10             	add    $0x10,%esp
}
  803783:	c9                   	leave  
  803784:	c3                   	ret    

00803785 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  803785:	55                   	push   %ebp
  803786:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  803788:	b8 00 00 00 00       	mov    $0x0,%eax
  80378d:	5d                   	pop    %ebp
  80378e:	c3                   	ret    

0080378f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80378f:	55                   	push   %ebp
  803790:	89 e5                	mov    %esp,%ebp
  803792:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  803795:	68 dd 45 80 00       	push   $0x8045dd
  80379a:	ff 75 0c             	pushl  0xc(%ebp)
  80379d:	e8 62 e9 ff ff       	call   802104 <strcpy>
	return 0;
}
  8037a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8037a7:	c9                   	leave  
  8037a8:	c3                   	ret    

008037a9 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8037a9:	55                   	push   %ebp
  8037aa:	89 e5                	mov    %esp,%ebp
  8037ac:	57                   	push   %edi
  8037ad:	56                   	push   %esi
  8037ae:	53                   	push   %ebx
  8037af:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8037b5:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8037ba:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8037c0:	eb 2d                	jmp    8037ef <devcons_write+0x46>
		m = n - tot;
  8037c2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8037c5:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8037c7:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8037ca:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8037cf:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8037d2:	83 ec 04             	sub    $0x4,%esp
  8037d5:	53                   	push   %ebx
  8037d6:	03 45 0c             	add    0xc(%ebp),%eax
  8037d9:	50                   	push   %eax
  8037da:	57                   	push   %edi
  8037db:	e8 b6 ea ff ff       	call   802296 <memmove>
		sys_cputs(buf, m);
  8037e0:	83 c4 08             	add    $0x8,%esp
  8037e3:	53                   	push   %ebx
  8037e4:	57                   	push   %edi
  8037e5:	e8 61 ec ff ff       	call   80244b <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8037ea:	01 de                	add    %ebx,%esi
  8037ec:	83 c4 10             	add    $0x10,%esp
  8037ef:	89 f0                	mov    %esi,%eax
  8037f1:	3b 75 10             	cmp    0x10(%ebp),%esi
  8037f4:	72 cc                	jb     8037c2 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8037f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8037f9:	5b                   	pop    %ebx
  8037fa:	5e                   	pop    %esi
  8037fb:	5f                   	pop    %edi
  8037fc:	5d                   	pop    %ebp
  8037fd:	c3                   	ret    

008037fe <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8037fe:	55                   	push   %ebp
  8037ff:	89 e5                	mov    %esp,%ebp
  803801:	83 ec 08             	sub    $0x8,%esp
  803804:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  803809:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80380d:	74 2a                	je     803839 <devcons_read+0x3b>
  80380f:	eb 05                	jmp    803816 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  803811:	e8 d2 ec ff ff       	call   8024e8 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  803816:	e8 4e ec ff ff       	call   802469 <sys_cgetc>
  80381b:	85 c0                	test   %eax,%eax
  80381d:	74 f2                	je     803811 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80381f:	85 c0                	test   %eax,%eax
  803821:	78 16                	js     803839 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  803823:	83 f8 04             	cmp    $0x4,%eax
  803826:	74 0c                	je     803834 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  803828:	8b 55 0c             	mov    0xc(%ebp),%edx
  80382b:	88 02                	mov    %al,(%edx)
	return 1;
  80382d:	b8 01 00 00 00       	mov    $0x1,%eax
  803832:	eb 05                	jmp    803839 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  803834:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  803839:	c9                   	leave  
  80383a:	c3                   	ret    

0080383b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80383b:	55                   	push   %ebp
  80383c:	89 e5                	mov    %esp,%ebp
  80383e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  803841:	8b 45 08             	mov    0x8(%ebp),%eax
  803844:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  803847:	6a 01                	push   $0x1
  803849:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80384c:	50                   	push   %eax
  80384d:	e8 f9 eb ff ff       	call   80244b <sys_cputs>
}
  803852:	83 c4 10             	add    $0x10,%esp
  803855:	c9                   	leave  
  803856:	c3                   	ret    

00803857 <getchar>:

int
getchar(void)
{
  803857:	55                   	push   %ebp
  803858:	89 e5                	mov    %esp,%ebp
  80385a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80385d:	6a 01                	push   $0x1
  80385f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803862:	50                   	push   %eax
  803863:	6a 00                	push   $0x0
  803865:	e8 4c f6 ff ff       	call   802eb6 <read>
	if (r < 0)
  80386a:	83 c4 10             	add    $0x10,%esp
  80386d:	85 c0                	test   %eax,%eax
  80386f:	78 0f                	js     803880 <getchar+0x29>
		return r;
	if (r < 1)
  803871:	85 c0                	test   %eax,%eax
  803873:	7e 06                	jle    80387b <getchar+0x24>
		return -E_EOF;
	return c;
  803875:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  803879:	eb 05                	jmp    803880 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80387b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  803880:	c9                   	leave  
  803881:	c3                   	ret    

00803882 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  803882:	55                   	push   %ebp
  803883:	89 e5                	mov    %esp,%ebp
  803885:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803888:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80388b:	50                   	push   %eax
  80388c:	ff 75 08             	pushl  0x8(%ebp)
  80388f:	e8 bc f3 ff ff       	call   802c50 <fd_lookup>
  803894:	83 c4 10             	add    $0x10,%esp
  803897:	85 c0                	test   %eax,%eax
  803899:	78 11                	js     8038ac <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80389b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80389e:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  8038a4:	39 10                	cmp    %edx,(%eax)
  8038a6:	0f 94 c0             	sete   %al
  8038a9:	0f b6 c0             	movzbl %al,%eax
}
  8038ac:	c9                   	leave  
  8038ad:	c3                   	ret    

008038ae <opencons>:

int
opencons(void)
{
  8038ae:	55                   	push   %ebp
  8038af:	89 e5                	mov    %esp,%ebp
  8038b1:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8038b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8038b7:	50                   	push   %eax
  8038b8:	e8 44 f3 ff ff       	call   802c01 <fd_alloc>
  8038bd:	83 c4 10             	add    $0x10,%esp
		return r;
  8038c0:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8038c2:	85 c0                	test   %eax,%eax
  8038c4:	78 3e                	js     803904 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8038c6:	83 ec 04             	sub    $0x4,%esp
  8038c9:	68 07 04 00 00       	push   $0x407
  8038ce:	ff 75 f4             	pushl  -0xc(%ebp)
  8038d1:	6a 00                	push   $0x0
  8038d3:	e8 2f ec ff ff       	call   802507 <sys_page_alloc>
  8038d8:	83 c4 10             	add    $0x10,%esp
		return r;
  8038db:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8038dd:	85 c0                	test   %eax,%eax
  8038df:	78 23                	js     803904 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8038e1:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  8038e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8038ea:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8038ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8038ef:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8038f6:	83 ec 0c             	sub    $0xc,%esp
  8038f9:	50                   	push   %eax
  8038fa:	e8 db f2 ff ff       	call   802bda <fd2num>
  8038ff:	89 c2                	mov    %eax,%edx
  803901:	83 c4 10             	add    $0x10,%esp
}
  803904:	89 d0                	mov    %edx,%eax
  803906:	c9                   	leave  
  803907:	c3                   	ret    
  803908:	66 90                	xchg   %ax,%ax
  80390a:	66 90                	xchg   %ax,%ax
  80390c:	66 90                	xchg   %ax,%ax
  80390e:	66 90                	xchg   %ax,%ax

00803910 <__udivdi3>:
  803910:	55                   	push   %ebp
  803911:	57                   	push   %edi
  803912:	56                   	push   %esi
  803913:	53                   	push   %ebx
  803914:	83 ec 1c             	sub    $0x1c,%esp
  803917:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80391b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80391f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803923:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803927:	85 f6                	test   %esi,%esi
  803929:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80392d:	89 ca                	mov    %ecx,%edx
  80392f:	89 f8                	mov    %edi,%eax
  803931:	75 3d                	jne    803970 <__udivdi3+0x60>
  803933:	39 cf                	cmp    %ecx,%edi
  803935:	0f 87 c5 00 00 00    	ja     803a00 <__udivdi3+0xf0>
  80393b:	85 ff                	test   %edi,%edi
  80393d:	89 fd                	mov    %edi,%ebp
  80393f:	75 0b                	jne    80394c <__udivdi3+0x3c>
  803941:	b8 01 00 00 00       	mov    $0x1,%eax
  803946:	31 d2                	xor    %edx,%edx
  803948:	f7 f7                	div    %edi
  80394a:	89 c5                	mov    %eax,%ebp
  80394c:	89 c8                	mov    %ecx,%eax
  80394e:	31 d2                	xor    %edx,%edx
  803950:	f7 f5                	div    %ebp
  803952:	89 c1                	mov    %eax,%ecx
  803954:	89 d8                	mov    %ebx,%eax
  803956:	89 cf                	mov    %ecx,%edi
  803958:	f7 f5                	div    %ebp
  80395a:	89 c3                	mov    %eax,%ebx
  80395c:	89 d8                	mov    %ebx,%eax
  80395e:	89 fa                	mov    %edi,%edx
  803960:	83 c4 1c             	add    $0x1c,%esp
  803963:	5b                   	pop    %ebx
  803964:	5e                   	pop    %esi
  803965:	5f                   	pop    %edi
  803966:	5d                   	pop    %ebp
  803967:	c3                   	ret    
  803968:	90                   	nop
  803969:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803970:	39 ce                	cmp    %ecx,%esi
  803972:	77 74                	ja     8039e8 <__udivdi3+0xd8>
  803974:	0f bd fe             	bsr    %esi,%edi
  803977:	83 f7 1f             	xor    $0x1f,%edi
  80397a:	0f 84 98 00 00 00    	je     803a18 <__udivdi3+0x108>
  803980:	bb 20 00 00 00       	mov    $0x20,%ebx
  803985:	89 f9                	mov    %edi,%ecx
  803987:	89 c5                	mov    %eax,%ebp
  803989:	29 fb                	sub    %edi,%ebx
  80398b:	d3 e6                	shl    %cl,%esi
  80398d:	89 d9                	mov    %ebx,%ecx
  80398f:	d3 ed                	shr    %cl,%ebp
  803991:	89 f9                	mov    %edi,%ecx
  803993:	d3 e0                	shl    %cl,%eax
  803995:	09 ee                	or     %ebp,%esi
  803997:	89 d9                	mov    %ebx,%ecx
  803999:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80399d:	89 d5                	mov    %edx,%ebp
  80399f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8039a3:	d3 ed                	shr    %cl,%ebp
  8039a5:	89 f9                	mov    %edi,%ecx
  8039a7:	d3 e2                	shl    %cl,%edx
  8039a9:	89 d9                	mov    %ebx,%ecx
  8039ab:	d3 e8                	shr    %cl,%eax
  8039ad:	09 c2                	or     %eax,%edx
  8039af:	89 d0                	mov    %edx,%eax
  8039b1:	89 ea                	mov    %ebp,%edx
  8039b3:	f7 f6                	div    %esi
  8039b5:	89 d5                	mov    %edx,%ebp
  8039b7:	89 c3                	mov    %eax,%ebx
  8039b9:	f7 64 24 0c          	mull   0xc(%esp)
  8039bd:	39 d5                	cmp    %edx,%ebp
  8039bf:	72 10                	jb     8039d1 <__udivdi3+0xc1>
  8039c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8039c5:	89 f9                	mov    %edi,%ecx
  8039c7:	d3 e6                	shl    %cl,%esi
  8039c9:	39 c6                	cmp    %eax,%esi
  8039cb:	73 07                	jae    8039d4 <__udivdi3+0xc4>
  8039cd:	39 d5                	cmp    %edx,%ebp
  8039cf:	75 03                	jne    8039d4 <__udivdi3+0xc4>
  8039d1:	83 eb 01             	sub    $0x1,%ebx
  8039d4:	31 ff                	xor    %edi,%edi
  8039d6:	89 d8                	mov    %ebx,%eax
  8039d8:	89 fa                	mov    %edi,%edx
  8039da:	83 c4 1c             	add    $0x1c,%esp
  8039dd:	5b                   	pop    %ebx
  8039de:	5e                   	pop    %esi
  8039df:	5f                   	pop    %edi
  8039e0:	5d                   	pop    %ebp
  8039e1:	c3                   	ret    
  8039e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8039e8:	31 ff                	xor    %edi,%edi
  8039ea:	31 db                	xor    %ebx,%ebx
  8039ec:	89 d8                	mov    %ebx,%eax
  8039ee:	89 fa                	mov    %edi,%edx
  8039f0:	83 c4 1c             	add    $0x1c,%esp
  8039f3:	5b                   	pop    %ebx
  8039f4:	5e                   	pop    %esi
  8039f5:	5f                   	pop    %edi
  8039f6:	5d                   	pop    %ebp
  8039f7:	c3                   	ret    
  8039f8:	90                   	nop
  8039f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803a00:	89 d8                	mov    %ebx,%eax
  803a02:	f7 f7                	div    %edi
  803a04:	31 ff                	xor    %edi,%edi
  803a06:	89 c3                	mov    %eax,%ebx
  803a08:	89 d8                	mov    %ebx,%eax
  803a0a:	89 fa                	mov    %edi,%edx
  803a0c:	83 c4 1c             	add    $0x1c,%esp
  803a0f:	5b                   	pop    %ebx
  803a10:	5e                   	pop    %esi
  803a11:	5f                   	pop    %edi
  803a12:	5d                   	pop    %ebp
  803a13:	c3                   	ret    
  803a14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803a18:	39 ce                	cmp    %ecx,%esi
  803a1a:	72 0c                	jb     803a28 <__udivdi3+0x118>
  803a1c:	31 db                	xor    %ebx,%ebx
  803a1e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803a22:	0f 87 34 ff ff ff    	ja     80395c <__udivdi3+0x4c>
  803a28:	bb 01 00 00 00       	mov    $0x1,%ebx
  803a2d:	e9 2a ff ff ff       	jmp    80395c <__udivdi3+0x4c>
  803a32:	66 90                	xchg   %ax,%ax
  803a34:	66 90                	xchg   %ax,%ax
  803a36:	66 90                	xchg   %ax,%ax
  803a38:	66 90                	xchg   %ax,%ax
  803a3a:	66 90                	xchg   %ax,%ax
  803a3c:	66 90                	xchg   %ax,%ax
  803a3e:	66 90                	xchg   %ax,%ax

00803a40 <__umoddi3>:
  803a40:	55                   	push   %ebp
  803a41:	57                   	push   %edi
  803a42:	56                   	push   %esi
  803a43:	53                   	push   %ebx
  803a44:	83 ec 1c             	sub    $0x1c,%esp
  803a47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  803a4b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  803a4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  803a53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803a57:	85 d2                	test   %edx,%edx
  803a59:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  803a5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803a61:	89 f3                	mov    %esi,%ebx
  803a63:	89 3c 24             	mov    %edi,(%esp)
  803a66:	89 74 24 04          	mov    %esi,0x4(%esp)
  803a6a:	75 1c                	jne    803a88 <__umoddi3+0x48>
  803a6c:	39 f7                	cmp    %esi,%edi
  803a6e:	76 50                	jbe    803ac0 <__umoddi3+0x80>
  803a70:	89 c8                	mov    %ecx,%eax
  803a72:	89 f2                	mov    %esi,%edx
  803a74:	f7 f7                	div    %edi
  803a76:	89 d0                	mov    %edx,%eax
  803a78:	31 d2                	xor    %edx,%edx
  803a7a:	83 c4 1c             	add    $0x1c,%esp
  803a7d:	5b                   	pop    %ebx
  803a7e:	5e                   	pop    %esi
  803a7f:	5f                   	pop    %edi
  803a80:	5d                   	pop    %ebp
  803a81:	c3                   	ret    
  803a82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803a88:	39 f2                	cmp    %esi,%edx
  803a8a:	89 d0                	mov    %edx,%eax
  803a8c:	77 52                	ja     803ae0 <__umoddi3+0xa0>
  803a8e:	0f bd ea             	bsr    %edx,%ebp
  803a91:	83 f5 1f             	xor    $0x1f,%ebp
  803a94:	75 5a                	jne    803af0 <__umoddi3+0xb0>
  803a96:	3b 54 24 04          	cmp    0x4(%esp),%edx
  803a9a:	0f 82 e0 00 00 00    	jb     803b80 <__umoddi3+0x140>
  803aa0:	39 0c 24             	cmp    %ecx,(%esp)
  803aa3:	0f 86 d7 00 00 00    	jbe    803b80 <__umoddi3+0x140>
  803aa9:	8b 44 24 08          	mov    0x8(%esp),%eax
  803aad:	8b 54 24 04          	mov    0x4(%esp),%edx
  803ab1:	83 c4 1c             	add    $0x1c,%esp
  803ab4:	5b                   	pop    %ebx
  803ab5:	5e                   	pop    %esi
  803ab6:	5f                   	pop    %edi
  803ab7:	5d                   	pop    %ebp
  803ab8:	c3                   	ret    
  803ab9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803ac0:	85 ff                	test   %edi,%edi
  803ac2:	89 fd                	mov    %edi,%ebp
  803ac4:	75 0b                	jne    803ad1 <__umoddi3+0x91>
  803ac6:	b8 01 00 00 00       	mov    $0x1,%eax
  803acb:	31 d2                	xor    %edx,%edx
  803acd:	f7 f7                	div    %edi
  803acf:	89 c5                	mov    %eax,%ebp
  803ad1:	89 f0                	mov    %esi,%eax
  803ad3:	31 d2                	xor    %edx,%edx
  803ad5:	f7 f5                	div    %ebp
  803ad7:	89 c8                	mov    %ecx,%eax
  803ad9:	f7 f5                	div    %ebp
  803adb:	89 d0                	mov    %edx,%eax
  803add:	eb 99                	jmp    803a78 <__umoddi3+0x38>
  803adf:	90                   	nop
  803ae0:	89 c8                	mov    %ecx,%eax
  803ae2:	89 f2                	mov    %esi,%edx
  803ae4:	83 c4 1c             	add    $0x1c,%esp
  803ae7:	5b                   	pop    %ebx
  803ae8:	5e                   	pop    %esi
  803ae9:	5f                   	pop    %edi
  803aea:	5d                   	pop    %ebp
  803aeb:	c3                   	ret    
  803aec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803af0:	8b 34 24             	mov    (%esp),%esi
  803af3:	bf 20 00 00 00       	mov    $0x20,%edi
  803af8:	89 e9                	mov    %ebp,%ecx
  803afa:	29 ef                	sub    %ebp,%edi
  803afc:	d3 e0                	shl    %cl,%eax
  803afe:	89 f9                	mov    %edi,%ecx
  803b00:	89 f2                	mov    %esi,%edx
  803b02:	d3 ea                	shr    %cl,%edx
  803b04:	89 e9                	mov    %ebp,%ecx
  803b06:	09 c2                	or     %eax,%edx
  803b08:	89 d8                	mov    %ebx,%eax
  803b0a:	89 14 24             	mov    %edx,(%esp)
  803b0d:	89 f2                	mov    %esi,%edx
  803b0f:	d3 e2                	shl    %cl,%edx
  803b11:	89 f9                	mov    %edi,%ecx
  803b13:	89 54 24 04          	mov    %edx,0x4(%esp)
  803b17:	8b 54 24 0c          	mov    0xc(%esp),%edx
  803b1b:	d3 e8                	shr    %cl,%eax
  803b1d:	89 e9                	mov    %ebp,%ecx
  803b1f:	89 c6                	mov    %eax,%esi
  803b21:	d3 e3                	shl    %cl,%ebx
  803b23:	89 f9                	mov    %edi,%ecx
  803b25:	89 d0                	mov    %edx,%eax
  803b27:	d3 e8                	shr    %cl,%eax
  803b29:	89 e9                	mov    %ebp,%ecx
  803b2b:	09 d8                	or     %ebx,%eax
  803b2d:	89 d3                	mov    %edx,%ebx
  803b2f:	89 f2                	mov    %esi,%edx
  803b31:	f7 34 24             	divl   (%esp)
  803b34:	89 d6                	mov    %edx,%esi
  803b36:	d3 e3                	shl    %cl,%ebx
  803b38:	f7 64 24 04          	mull   0x4(%esp)
  803b3c:	39 d6                	cmp    %edx,%esi
  803b3e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803b42:	89 d1                	mov    %edx,%ecx
  803b44:	89 c3                	mov    %eax,%ebx
  803b46:	72 08                	jb     803b50 <__umoddi3+0x110>
  803b48:	75 11                	jne    803b5b <__umoddi3+0x11b>
  803b4a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  803b4e:	73 0b                	jae    803b5b <__umoddi3+0x11b>
  803b50:	2b 44 24 04          	sub    0x4(%esp),%eax
  803b54:	1b 14 24             	sbb    (%esp),%edx
  803b57:	89 d1                	mov    %edx,%ecx
  803b59:	89 c3                	mov    %eax,%ebx
  803b5b:	8b 54 24 08          	mov    0x8(%esp),%edx
  803b5f:	29 da                	sub    %ebx,%edx
  803b61:	19 ce                	sbb    %ecx,%esi
  803b63:	89 f9                	mov    %edi,%ecx
  803b65:	89 f0                	mov    %esi,%eax
  803b67:	d3 e0                	shl    %cl,%eax
  803b69:	89 e9                	mov    %ebp,%ecx
  803b6b:	d3 ea                	shr    %cl,%edx
  803b6d:	89 e9                	mov    %ebp,%ecx
  803b6f:	d3 ee                	shr    %cl,%esi
  803b71:	09 d0                	or     %edx,%eax
  803b73:	89 f2                	mov    %esi,%edx
  803b75:	83 c4 1c             	add    $0x1c,%esp
  803b78:	5b                   	pop    %ebx
  803b79:	5e                   	pop    %esi
  803b7a:	5f                   	pop    %edi
  803b7b:	5d                   	pop    %ebp
  803b7c:	c3                   	ret    
  803b7d:	8d 76 00             	lea    0x0(%esi),%esi
  803b80:	29 f9                	sub    %edi,%ecx
  803b82:	19 d6                	sbb    %edx,%esi
  803b84:	89 74 24 04          	mov    %esi,0x4(%esp)
  803b88:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803b8c:	e9 18 ff ff ff       	jmp    803aa9 <__umoddi3+0x69>
