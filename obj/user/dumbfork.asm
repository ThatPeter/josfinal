
obj/user/dumbfork.debug:     file format elf32-i386


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
  80002c:	e8 ae 01 00 00       	call   8001df <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80003e:	83 ec 04             	sub    $0x4,%esp
  800041:	6a 07                	push   $0x7
  800043:	53                   	push   %ebx
  800044:	56                   	push   %esi
  800045:	e8 b6 0c 00 00       	call   800d00 <sys_page_alloc>
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800051:	50                   	push   %eax
  800052:	68 e0 1f 80 00       	push   $0x801fe0
  800057:	6a 20                	push   $0x20
  800059:	68 f3 1f 80 00       	push   $0x801ff3
  80005e:	e8 3c 02 00 00       	call   80029f <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800063:	83 ec 0c             	sub    $0xc,%esp
  800066:	6a 07                	push   $0x7
  800068:	68 00 00 40 00       	push   $0x400000
  80006d:	6a 00                	push   $0x0
  80006f:	53                   	push   %ebx
  800070:	56                   	push   %esi
  800071:	e8 cd 0c 00 00       	call   800d43 <sys_page_map>
  800076:	83 c4 20             	add    $0x20,%esp
  800079:	85 c0                	test   %eax,%eax
  80007b:	79 12                	jns    80008f <duppage+0x5c>
		panic("sys_page_map: %e", r);
  80007d:	50                   	push   %eax
  80007e:	68 03 20 80 00       	push   $0x802003
  800083:	6a 22                	push   $0x22
  800085:	68 f3 1f 80 00       	push   $0x801ff3
  80008a:	e8 10 02 00 00       	call   80029f <_panic>
	memmove(UTEMP, addr, PGSIZE);
  80008f:	83 ec 04             	sub    $0x4,%esp
  800092:	68 00 10 00 00       	push   $0x1000
  800097:	53                   	push   %ebx
  800098:	68 00 00 40 00       	push   $0x400000
  80009d:	e8 ed 09 00 00       	call   800a8f <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	68 00 00 40 00       	push   $0x400000
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 d4 0c 00 00       	call   800d85 <sys_page_unmap>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	79 12                	jns    8000ca <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  8000b8:	50                   	push   %eax
  8000b9:	68 14 20 80 00       	push   $0x802014
  8000be:	6a 25                	push   $0x25
  8000c0:	68 f3 1f 80 00       	push   $0x801ff3
  8000c5:	e8 d5 01 00 00       	call   80029f <_panic>
}
  8000ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    

008000d1 <dumbfork>:

envid_t
dumbfork(void)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	56                   	push   %esi
  8000d5:	53                   	push   %ebx
  8000d6:	83 ec 10             	sub    $0x10,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8000d9:	b8 07 00 00 00       	mov    $0x7,%eax
  8000de:	cd 30                	int    $0x30
  8000e0:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8000e2:	85 c0                	test   %eax,%eax
  8000e4:	79 12                	jns    8000f8 <dumbfork+0x27>
		panic("sys_exofork: %e", envid);
  8000e6:	50                   	push   %eax
  8000e7:	68 27 20 80 00       	push   $0x802027
  8000ec:	6a 37                	push   $0x37
  8000ee:	68 f3 1f 80 00       	push   $0x801ff3
  8000f3:	e8 a7 01 00 00       	call   80029f <_panic>
  8000f8:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	75 22                	jne    800120 <dumbfork+0x4f>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8000fe:	e8 bf 0b 00 00       	call   800cc2 <sys_getenvid>
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
  800108:	89 c2                	mov    %eax,%edx
  80010a:	c1 e2 07             	shl    $0x7,%edx
  80010d:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800114:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800119:	b8 00 00 00 00       	mov    $0x0,%eax
  80011e:	eb 60                	jmp    800180 <dumbfork+0xaf>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800120:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800127:	eb 14                	jmp    80013d <dumbfork+0x6c>
		duppage(envid, addr);
  800129:	83 ec 08             	sub    $0x8,%esp
  80012c:	52                   	push   %edx
  80012d:	56                   	push   %esi
  80012e:	e8 00 ff ff ff       	call   800033 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800133:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  80013a:	83 c4 10             	add    $0x10,%esp
  80013d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800140:	81 fa 00 60 80 00    	cmp    $0x806000,%edx
  800146:	72 e1                	jb     800129 <dumbfork+0x58>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800148:	83 ec 08             	sub    $0x8,%esp
  80014b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80014e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800153:	50                   	push   %eax
  800154:	53                   	push   %ebx
  800155:	e8 d9 fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80015a:	83 c4 08             	add    $0x8,%esp
  80015d:	6a 02                	push   $0x2
  80015f:	53                   	push   %ebx
  800160:	e8 62 0c 00 00       	call   800dc7 <sys_env_set_status>
  800165:	83 c4 10             	add    $0x10,%esp
  800168:	85 c0                	test   %eax,%eax
  80016a:	79 12                	jns    80017e <dumbfork+0xad>
		panic("sys_env_set_status: %e", r);
  80016c:	50                   	push   %eax
  80016d:	68 37 20 80 00       	push   $0x802037
  800172:	6a 4c                	push   $0x4c
  800174:	68 f3 1f 80 00       	push   $0x801ff3
  800179:	e8 21 01 00 00       	call   80029f <_panic>

	return envid;
  80017e:	89 d8                	mov    %ebx,%eax
}
  800180:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800183:	5b                   	pop    %ebx
  800184:	5e                   	pop    %esi
  800185:	5d                   	pop    %ebp
  800186:	c3                   	ret    

00800187 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	57                   	push   %edi
  80018b:	56                   	push   %esi
  80018c:	53                   	push   %ebx
  80018d:	83 ec 0c             	sub    $0xc,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  800190:	e8 3c ff ff ff       	call   8000d1 <dumbfork>
  800195:	89 c7                	mov    %eax,%edi
  800197:	85 c0                	test   %eax,%eax
  800199:	be 55 20 80 00       	mov    $0x802055,%esi
  80019e:	b8 4e 20 80 00       	mov    $0x80204e,%eax
  8001a3:	0f 45 f0             	cmovne %eax,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ab:	eb 1a                	jmp    8001c7 <umain+0x40>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001ad:	83 ec 04             	sub    $0x4,%esp
  8001b0:	56                   	push   %esi
  8001b1:	53                   	push   %ebx
  8001b2:	68 5b 20 80 00       	push   $0x80205b
  8001b7:	e8 bc 01 00 00       	call   800378 <cprintf>
		sys_yield();
  8001bc:	e8 20 0b 00 00       	call   800ce1 <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001c1:	83 c3 01             	add    $0x1,%ebx
  8001c4:	83 c4 10             	add    $0x10,%esp
  8001c7:	85 ff                	test   %edi,%edi
  8001c9:	74 07                	je     8001d2 <umain+0x4b>
  8001cb:	83 fb 09             	cmp    $0x9,%ebx
  8001ce:	7e dd                	jle    8001ad <umain+0x26>
  8001d0:	eb 05                	jmp    8001d7 <umain+0x50>
  8001d2:	83 fb 13             	cmp    $0x13,%ebx
  8001d5:	7e d6                	jle    8001ad <umain+0x26>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  8001d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001da:	5b                   	pop    %ebx
  8001db:	5e                   	pop    %esi
  8001dc:	5f                   	pop    %edi
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	57                   	push   %edi
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8001e8:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  8001ef:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  8001f2:	e8 cb 0a 00 00       	call   800cc2 <sys_getenvid>
  8001f7:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  8001f9:	83 ec 08             	sub    $0x8,%esp
  8001fc:	50                   	push   %eax
  8001fd:	68 70 20 80 00       	push   $0x802070
  800202:	e8 71 01 00 00       	call   800378 <cprintf>
  800207:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  80020d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800212:	83 c4 10             	add    $0x10,%esp
  800215:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  80021a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  80021f:	89 c1                	mov    %eax,%ecx
  800221:	c1 e1 07             	shl    $0x7,%ecx
  800224:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  80022b:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  80022e:	39 cb                	cmp    %ecx,%ebx
  800230:	0f 44 fa             	cmove  %edx,%edi
  800233:	b9 01 00 00 00       	mov    $0x1,%ecx
  800238:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  80023b:	83 c0 01             	add    $0x1,%eax
  80023e:	81 c2 84 00 00 00    	add    $0x84,%edx
  800244:	3d 00 04 00 00       	cmp    $0x400,%eax
  800249:	75 d4                	jne    80021f <libmain+0x40>
  80024b:	89 f0                	mov    %esi,%eax
  80024d:	84 c0                	test   %al,%al
  80024f:	74 06                	je     800257 <libmain+0x78>
  800251:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800257:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80025b:	7e 0a                	jle    800267 <libmain+0x88>
		binaryname = argv[0];
  80025d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800260:	8b 00                	mov    (%eax),%eax
  800262:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800267:	83 ec 08             	sub    $0x8,%esp
  80026a:	ff 75 0c             	pushl  0xc(%ebp)
  80026d:	ff 75 08             	pushl  0x8(%ebp)
  800270:	e8 12 ff ff ff       	call   800187 <umain>

	// exit gracefully
	exit();
  800275:	e8 0b 00 00 00       	call   800285 <exit>
}
  80027a:	83 c4 10             	add    $0x10,%esp
  80027d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800280:	5b                   	pop    %ebx
  800281:	5e                   	pop    %esi
  800282:	5f                   	pop    %edi
  800283:	5d                   	pop    %ebp
  800284:	c3                   	ret    

00800285 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800285:	55                   	push   %ebp
  800286:	89 e5                	mov    %esp,%ebp
  800288:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80028b:	e8 4c 0e 00 00       	call   8010dc <close_all>
	sys_env_destroy(0);
  800290:	83 ec 0c             	sub    $0xc,%esp
  800293:	6a 00                	push   $0x0
  800295:	e8 e7 09 00 00       	call   800c81 <sys_env_destroy>
}
  80029a:	83 c4 10             	add    $0x10,%esp
  80029d:	c9                   	leave  
  80029e:	c3                   	ret    

0080029f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80029f:	55                   	push   %ebp
  8002a0:	89 e5                	mov    %esp,%ebp
  8002a2:	56                   	push   %esi
  8002a3:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002a4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002a7:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002ad:	e8 10 0a 00 00       	call   800cc2 <sys_getenvid>
  8002b2:	83 ec 0c             	sub    $0xc,%esp
  8002b5:	ff 75 0c             	pushl  0xc(%ebp)
  8002b8:	ff 75 08             	pushl  0x8(%ebp)
  8002bb:	56                   	push   %esi
  8002bc:	50                   	push   %eax
  8002bd:	68 9c 20 80 00       	push   $0x80209c
  8002c2:	e8 b1 00 00 00       	call   800378 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002c7:	83 c4 18             	add    $0x18,%esp
  8002ca:	53                   	push   %ebx
  8002cb:	ff 75 10             	pushl  0x10(%ebp)
  8002ce:	e8 54 00 00 00       	call   800327 <vcprintf>
	cprintf("\n");
  8002d3:	c7 04 24 6b 20 80 00 	movl   $0x80206b,(%esp)
  8002da:	e8 99 00 00 00       	call   800378 <cprintf>
  8002df:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002e2:	cc                   	int3   
  8002e3:	eb fd                	jmp    8002e2 <_panic+0x43>

008002e5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002e5:	55                   	push   %ebp
  8002e6:	89 e5                	mov    %esp,%ebp
  8002e8:	53                   	push   %ebx
  8002e9:	83 ec 04             	sub    $0x4,%esp
  8002ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002ef:	8b 13                	mov    (%ebx),%edx
  8002f1:	8d 42 01             	lea    0x1(%edx),%eax
  8002f4:	89 03                	mov    %eax,(%ebx)
  8002f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002fd:	3d ff 00 00 00       	cmp    $0xff,%eax
  800302:	75 1a                	jne    80031e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800304:	83 ec 08             	sub    $0x8,%esp
  800307:	68 ff 00 00 00       	push   $0xff
  80030c:	8d 43 08             	lea    0x8(%ebx),%eax
  80030f:	50                   	push   %eax
  800310:	e8 2f 09 00 00       	call   800c44 <sys_cputs>
		b->idx = 0;
  800315:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80031b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80031e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800322:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800325:	c9                   	leave  
  800326:	c3                   	ret    

00800327 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800327:	55                   	push   %ebp
  800328:	89 e5                	mov    %esp,%ebp
  80032a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800330:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800337:	00 00 00 
	b.cnt = 0;
  80033a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800341:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800344:	ff 75 0c             	pushl  0xc(%ebp)
  800347:	ff 75 08             	pushl  0x8(%ebp)
  80034a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800350:	50                   	push   %eax
  800351:	68 e5 02 80 00       	push   $0x8002e5
  800356:	e8 54 01 00 00       	call   8004af <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80035b:	83 c4 08             	add    $0x8,%esp
  80035e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800364:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80036a:	50                   	push   %eax
  80036b:	e8 d4 08 00 00       	call   800c44 <sys_cputs>

	return b.cnt;
}
  800370:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800376:	c9                   	leave  
  800377:	c3                   	ret    

00800378 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
  80037b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80037e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800381:	50                   	push   %eax
  800382:	ff 75 08             	pushl  0x8(%ebp)
  800385:	e8 9d ff ff ff       	call   800327 <vcprintf>
	va_end(ap);

	return cnt;
}
  80038a:	c9                   	leave  
  80038b:	c3                   	ret    

0080038c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	57                   	push   %edi
  800390:	56                   	push   %esi
  800391:	53                   	push   %ebx
  800392:	83 ec 1c             	sub    $0x1c,%esp
  800395:	89 c7                	mov    %eax,%edi
  800397:	89 d6                	mov    %edx,%esi
  800399:	8b 45 08             	mov    0x8(%ebp),%eax
  80039c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80039f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003a5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003ad:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003b0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003b3:	39 d3                	cmp    %edx,%ebx
  8003b5:	72 05                	jb     8003bc <printnum+0x30>
  8003b7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003ba:	77 45                	ja     800401 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003bc:	83 ec 0c             	sub    $0xc,%esp
  8003bf:	ff 75 18             	pushl  0x18(%ebp)
  8003c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c5:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003c8:	53                   	push   %ebx
  8003c9:	ff 75 10             	pushl  0x10(%ebp)
  8003cc:	83 ec 08             	sub    $0x8,%esp
  8003cf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003d2:	ff 75 e0             	pushl  -0x20(%ebp)
  8003d5:	ff 75 dc             	pushl  -0x24(%ebp)
  8003d8:	ff 75 d8             	pushl  -0x28(%ebp)
  8003db:	e8 70 19 00 00       	call   801d50 <__udivdi3>
  8003e0:	83 c4 18             	add    $0x18,%esp
  8003e3:	52                   	push   %edx
  8003e4:	50                   	push   %eax
  8003e5:	89 f2                	mov    %esi,%edx
  8003e7:	89 f8                	mov    %edi,%eax
  8003e9:	e8 9e ff ff ff       	call   80038c <printnum>
  8003ee:	83 c4 20             	add    $0x20,%esp
  8003f1:	eb 18                	jmp    80040b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003f3:	83 ec 08             	sub    $0x8,%esp
  8003f6:	56                   	push   %esi
  8003f7:	ff 75 18             	pushl  0x18(%ebp)
  8003fa:	ff d7                	call   *%edi
  8003fc:	83 c4 10             	add    $0x10,%esp
  8003ff:	eb 03                	jmp    800404 <printnum+0x78>
  800401:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800404:	83 eb 01             	sub    $0x1,%ebx
  800407:	85 db                	test   %ebx,%ebx
  800409:	7f e8                	jg     8003f3 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80040b:	83 ec 08             	sub    $0x8,%esp
  80040e:	56                   	push   %esi
  80040f:	83 ec 04             	sub    $0x4,%esp
  800412:	ff 75 e4             	pushl  -0x1c(%ebp)
  800415:	ff 75 e0             	pushl  -0x20(%ebp)
  800418:	ff 75 dc             	pushl  -0x24(%ebp)
  80041b:	ff 75 d8             	pushl  -0x28(%ebp)
  80041e:	e8 5d 1a 00 00       	call   801e80 <__umoddi3>
  800423:	83 c4 14             	add    $0x14,%esp
  800426:	0f be 80 bf 20 80 00 	movsbl 0x8020bf(%eax),%eax
  80042d:	50                   	push   %eax
  80042e:	ff d7                	call   *%edi
}
  800430:	83 c4 10             	add    $0x10,%esp
  800433:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800436:	5b                   	pop    %ebx
  800437:	5e                   	pop    %esi
  800438:	5f                   	pop    %edi
  800439:	5d                   	pop    %ebp
  80043a:	c3                   	ret    

0080043b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80043b:	55                   	push   %ebp
  80043c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80043e:	83 fa 01             	cmp    $0x1,%edx
  800441:	7e 0e                	jle    800451 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800443:	8b 10                	mov    (%eax),%edx
  800445:	8d 4a 08             	lea    0x8(%edx),%ecx
  800448:	89 08                	mov    %ecx,(%eax)
  80044a:	8b 02                	mov    (%edx),%eax
  80044c:	8b 52 04             	mov    0x4(%edx),%edx
  80044f:	eb 22                	jmp    800473 <getuint+0x38>
	else if (lflag)
  800451:	85 d2                	test   %edx,%edx
  800453:	74 10                	je     800465 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800455:	8b 10                	mov    (%eax),%edx
  800457:	8d 4a 04             	lea    0x4(%edx),%ecx
  80045a:	89 08                	mov    %ecx,(%eax)
  80045c:	8b 02                	mov    (%edx),%eax
  80045e:	ba 00 00 00 00       	mov    $0x0,%edx
  800463:	eb 0e                	jmp    800473 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800465:	8b 10                	mov    (%eax),%edx
  800467:	8d 4a 04             	lea    0x4(%edx),%ecx
  80046a:	89 08                	mov    %ecx,(%eax)
  80046c:	8b 02                	mov    (%edx),%eax
  80046e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800473:	5d                   	pop    %ebp
  800474:	c3                   	ret    

00800475 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800475:	55                   	push   %ebp
  800476:	89 e5                	mov    %esp,%ebp
  800478:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80047b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80047f:	8b 10                	mov    (%eax),%edx
  800481:	3b 50 04             	cmp    0x4(%eax),%edx
  800484:	73 0a                	jae    800490 <sprintputch+0x1b>
		*b->buf++ = ch;
  800486:	8d 4a 01             	lea    0x1(%edx),%ecx
  800489:	89 08                	mov    %ecx,(%eax)
  80048b:	8b 45 08             	mov    0x8(%ebp),%eax
  80048e:	88 02                	mov    %al,(%edx)
}
  800490:	5d                   	pop    %ebp
  800491:	c3                   	ret    

00800492 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800492:	55                   	push   %ebp
  800493:	89 e5                	mov    %esp,%ebp
  800495:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800498:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80049b:	50                   	push   %eax
  80049c:	ff 75 10             	pushl  0x10(%ebp)
  80049f:	ff 75 0c             	pushl  0xc(%ebp)
  8004a2:	ff 75 08             	pushl  0x8(%ebp)
  8004a5:	e8 05 00 00 00       	call   8004af <vprintfmt>
	va_end(ap);
}
  8004aa:	83 c4 10             	add    $0x10,%esp
  8004ad:	c9                   	leave  
  8004ae:	c3                   	ret    

008004af <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004af:	55                   	push   %ebp
  8004b0:	89 e5                	mov    %esp,%ebp
  8004b2:	57                   	push   %edi
  8004b3:	56                   	push   %esi
  8004b4:	53                   	push   %ebx
  8004b5:	83 ec 2c             	sub    $0x2c,%esp
  8004b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8004bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004be:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004c1:	eb 12                	jmp    8004d5 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004c3:	85 c0                	test   %eax,%eax
  8004c5:	0f 84 89 03 00 00    	je     800854 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8004cb:	83 ec 08             	sub    $0x8,%esp
  8004ce:	53                   	push   %ebx
  8004cf:	50                   	push   %eax
  8004d0:	ff d6                	call   *%esi
  8004d2:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004d5:	83 c7 01             	add    $0x1,%edi
  8004d8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004dc:	83 f8 25             	cmp    $0x25,%eax
  8004df:	75 e2                	jne    8004c3 <vprintfmt+0x14>
  8004e1:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004e5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004ec:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004f3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ff:	eb 07                	jmp    800508 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800501:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800504:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800508:	8d 47 01             	lea    0x1(%edi),%eax
  80050b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80050e:	0f b6 07             	movzbl (%edi),%eax
  800511:	0f b6 c8             	movzbl %al,%ecx
  800514:	83 e8 23             	sub    $0x23,%eax
  800517:	3c 55                	cmp    $0x55,%al
  800519:	0f 87 1a 03 00 00    	ja     800839 <vprintfmt+0x38a>
  80051f:	0f b6 c0             	movzbl %al,%eax
  800522:	ff 24 85 00 22 80 00 	jmp    *0x802200(,%eax,4)
  800529:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80052c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800530:	eb d6                	jmp    800508 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800532:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800535:	b8 00 00 00 00       	mov    $0x0,%eax
  80053a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80053d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800540:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800544:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800547:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80054a:	83 fa 09             	cmp    $0x9,%edx
  80054d:	77 39                	ja     800588 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80054f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800552:	eb e9                	jmp    80053d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	8d 48 04             	lea    0x4(%eax),%ecx
  80055a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80055d:	8b 00                	mov    (%eax),%eax
  80055f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800562:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800565:	eb 27                	jmp    80058e <vprintfmt+0xdf>
  800567:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80056a:	85 c0                	test   %eax,%eax
  80056c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800571:	0f 49 c8             	cmovns %eax,%ecx
  800574:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800577:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80057a:	eb 8c                	jmp    800508 <vprintfmt+0x59>
  80057c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80057f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800586:	eb 80                	jmp    800508 <vprintfmt+0x59>
  800588:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80058b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80058e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800592:	0f 89 70 ff ff ff    	jns    800508 <vprintfmt+0x59>
				width = precision, precision = -1;
  800598:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80059b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80059e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005a5:	e9 5e ff ff ff       	jmp    800508 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005aa:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005b0:	e9 53 ff ff ff       	jmp    800508 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8d 50 04             	lea    0x4(%eax),%edx
  8005bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005be:	83 ec 08             	sub    $0x8,%esp
  8005c1:	53                   	push   %ebx
  8005c2:	ff 30                	pushl  (%eax)
  8005c4:	ff d6                	call   *%esi
			break;
  8005c6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005cc:	e9 04 ff ff ff       	jmp    8004d5 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d4:	8d 50 04             	lea    0x4(%eax),%edx
  8005d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005da:	8b 00                	mov    (%eax),%eax
  8005dc:	99                   	cltd   
  8005dd:	31 d0                	xor    %edx,%eax
  8005df:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005e1:	83 f8 0f             	cmp    $0xf,%eax
  8005e4:	7f 0b                	jg     8005f1 <vprintfmt+0x142>
  8005e6:	8b 14 85 60 23 80 00 	mov    0x802360(,%eax,4),%edx
  8005ed:	85 d2                	test   %edx,%edx
  8005ef:	75 18                	jne    800609 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005f1:	50                   	push   %eax
  8005f2:	68 d7 20 80 00       	push   $0x8020d7
  8005f7:	53                   	push   %ebx
  8005f8:	56                   	push   %esi
  8005f9:	e8 94 fe ff ff       	call   800492 <printfmt>
  8005fe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800601:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800604:	e9 cc fe ff ff       	jmp    8004d5 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800609:	52                   	push   %edx
  80060a:	68 95 24 80 00       	push   $0x802495
  80060f:	53                   	push   %ebx
  800610:	56                   	push   %esi
  800611:	e8 7c fe ff ff       	call   800492 <printfmt>
  800616:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800619:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80061c:	e9 b4 fe ff ff       	jmp    8004d5 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800621:	8b 45 14             	mov    0x14(%ebp),%eax
  800624:	8d 50 04             	lea    0x4(%eax),%edx
  800627:	89 55 14             	mov    %edx,0x14(%ebp)
  80062a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80062c:	85 ff                	test   %edi,%edi
  80062e:	b8 d0 20 80 00       	mov    $0x8020d0,%eax
  800633:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800636:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80063a:	0f 8e 94 00 00 00    	jle    8006d4 <vprintfmt+0x225>
  800640:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800644:	0f 84 98 00 00 00    	je     8006e2 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80064a:	83 ec 08             	sub    $0x8,%esp
  80064d:	ff 75 d0             	pushl  -0x30(%ebp)
  800650:	57                   	push   %edi
  800651:	e8 86 02 00 00       	call   8008dc <strnlen>
  800656:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800659:	29 c1                	sub    %eax,%ecx
  80065b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80065e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800661:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800665:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800668:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80066b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80066d:	eb 0f                	jmp    80067e <vprintfmt+0x1cf>
					putch(padc, putdat);
  80066f:	83 ec 08             	sub    $0x8,%esp
  800672:	53                   	push   %ebx
  800673:	ff 75 e0             	pushl  -0x20(%ebp)
  800676:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800678:	83 ef 01             	sub    $0x1,%edi
  80067b:	83 c4 10             	add    $0x10,%esp
  80067e:	85 ff                	test   %edi,%edi
  800680:	7f ed                	jg     80066f <vprintfmt+0x1c0>
  800682:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800685:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800688:	85 c9                	test   %ecx,%ecx
  80068a:	b8 00 00 00 00       	mov    $0x0,%eax
  80068f:	0f 49 c1             	cmovns %ecx,%eax
  800692:	29 c1                	sub    %eax,%ecx
  800694:	89 75 08             	mov    %esi,0x8(%ebp)
  800697:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80069a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80069d:	89 cb                	mov    %ecx,%ebx
  80069f:	eb 4d                	jmp    8006ee <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006a1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006a5:	74 1b                	je     8006c2 <vprintfmt+0x213>
  8006a7:	0f be c0             	movsbl %al,%eax
  8006aa:	83 e8 20             	sub    $0x20,%eax
  8006ad:	83 f8 5e             	cmp    $0x5e,%eax
  8006b0:	76 10                	jbe    8006c2 <vprintfmt+0x213>
					putch('?', putdat);
  8006b2:	83 ec 08             	sub    $0x8,%esp
  8006b5:	ff 75 0c             	pushl  0xc(%ebp)
  8006b8:	6a 3f                	push   $0x3f
  8006ba:	ff 55 08             	call   *0x8(%ebp)
  8006bd:	83 c4 10             	add    $0x10,%esp
  8006c0:	eb 0d                	jmp    8006cf <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8006c2:	83 ec 08             	sub    $0x8,%esp
  8006c5:	ff 75 0c             	pushl  0xc(%ebp)
  8006c8:	52                   	push   %edx
  8006c9:	ff 55 08             	call   *0x8(%ebp)
  8006cc:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006cf:	83 eb 01             	sub    $0x1,%ebx
  8006d2:	eb 1a                	jmp    8006ee <vprintfmt+0x23f>
  8006d4:	89 75 08             	mov    %esi,0x8(%ebp)
  8006d7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006da:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006dd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006e0:	eb 0c                	jmp    8006ee <vprintfmt+0x23f>
  8006e2:	89 75 08             	mov    %esi,0x8(%ebp)
  8006e5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006e8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006eb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006ee:	83 c7 01             	add    $0x1,%edi
  8006f1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006f5:	0f be d0             	movsbl %al,%edx
  8006f8:	85 d2                	test   %edx,%edx
  8006fa:	74 23                	je     80071f <vprintfmt+0x270>
  8006fc:	85 f6                	test   %esi,%esi
  8006fe:	78 a1                	js     8006a1 <vprintfmt+0x1f2>
  800700:	83 ee 01             	sub    $0x1,%esi
  800703:	79 9c                	jns    8006a1 <vprintfmt+0x1f2>
  800705:	89 df                	mov    %ebx,%edi
  800707:	8b 75 08             	mov    0x8(%ebp),%esi
  80070a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80070d:	eb 18                	jmp    800727 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80070f:	83 ec 08             	sub    $0x8,%esp
  800712:	53                   	push   %ebx
  800713:	6a 20                	push   $0x20
  800715:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800717:	83 ef 01             	sub    $0x1,%edi
  80071a:	83 c4 10             	add    $0x10,%esp
  80071d:	eb 08                	jmp    800727 <vprintfmt+0x278>
  80071f:	89 df                	mov    %ebx,%edi
  800721:	8b 75 08             	mov    0x8(%ebp),%esi
  800724:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800727:	85 ff                	test   %edi,%edi
  800729:	7f e4                	jg     80070f <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80072e:	e9 a2 fd ff ff       	jmp    8004d5 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800733:	83 fa 01             	cmp    $0x1,%edx
  800736:	7e 16                	jle    80074e <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800738:	8b 45 14             	mov    0x14(%ebp),%eax
  80073b:	8d 50 08             	lea    0x8(%eax),%edx
  80073e:	89 55 14             	mov    %edx,0x14(%ebp)
  800741:	8b 50 04             	mov    0x4(%eax),%edx
  800744:	8b 00                	mov    (%eax),%eax
  800746:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800749:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80074c:	eb 32                	jmp    800780 <vprintfmt+0x2d1>
	else if (lflag)
  80074e:	85 d2                	test   %edx,%edx
  800750:	74 18                	je     80076a <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800752:	8b 45 14             	mov    0x14(%ebp),%eax
  800755:	8d 50 04             	lea    0x4(%eax),%edx
  800758:	89 55 14             	mov    %edx,0x14(%ebp)
  80075b:	8b 00                	mov    (%eax),%eax
  80075d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800760:	89 c1                	mov    %eax,%ecx
  800762:	c1 f9 1f             	sar    $0x1f,%ecx
  800765:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800768:	eb 16                	jmp    800780 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80076a:	8b 45 14             	mov    0x14(%ebp),%eax
  80076d:	8d 50 04             	lea    0x4(%eax),%edx
  800770:	89 55 14             	mov    %edx,0x14(%ebp)
  800773:	8b 00                	mov    (%eax),%eax
  800775:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800778:	89 c1                	mov    %eax,%ecx
  80077a:	c1 f9 1f             	sar    $0x1f,%ecx
  80077d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800780:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800783:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800786:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80078b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80078f:	79 74                	jns    800805 <vprintfmt+0x356>
				putch('-', putdat);
  800791:	83 ec 08             	sub    $0x8,%esp
  800794:	53                   	push   %ebx
  800795:	6a 2d                	push   $0x2d
  800797:	ff d6                	call   *%esi
				num = -(long long) num;
  800799:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80079c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80079f:	f7 d8                	neg    %eax
  8007a1:	83 d2 00             	adc    $0x0,%edx
  8007a4:	f7 da                	neg    %edx
  8007a6:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007a9:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007ae:	eb 55                	jmp    800805 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007b0:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b3:	e8 83 fc ff ff       	call   80043b <getuint>
			base = 10;
  8007b8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007bd:	eb 46                	jmp    800805 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8007bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c2:	e8 74 fc ff ff       	call   80043b <getuint>
			base = 8;
  8007c7:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8007cc:	eb 37                	jmp    800805 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8007ce:	83 ec 08             	sub    $0x8,%esp
  8007d1:	53                   	push   %ebx
  8007d2:	6a 30                	push   $0x30
  8007d4:	ff d6                	call   *%esi
			putch('x', putdat);
  8007d6:	83 c4 08             	add    $0x8,%esp
  8007d9:	53                   	push   %ebx
  8007da:	6a 78                	push   $0x78
  8007dc:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007de:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e1:	8d 50 04             	lea    0x4(%eax),%edx
  8007e4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007e7:	8b 00                	mov    (%eax),%eax
  8007e9:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007ee:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007f1:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007f6:	eb 0d                	jmp    800805 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007f8:	8d 45 14             	lea    0x14(%ebp),%eax
  8007fb:	e8 3b fc ff ff       	call   80043b <getuint>
			base = 16;
  800800:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800805:	83 ec 0c             	sub    $0xc,%esp
  800808:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80080c:	57                   	push   %edi
  80080d:	ff 75 e0             	pushl  -0x20(%ebp)
  800810:	51                   	push   %ecx
  800811:	52                   	push   %edx
  800812:	50                   	push   %eax
  800813:	89 da                	mov    %ebx,%edx
  800815:	89 f0                	mov    %esi,%eax
  800817:	e8 70 fb ff ff       	call   80038c <printnum>
			break;
  80081c:	83 c4 20             	add    $0x20,%esp
  80081f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800822:	e9 ae fc ff ff       	jmp    8004d5 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800827:	83 ec 08             	sub    $0x8,%esp
  80082a:	53                   	push   %ebx
  80082b:	51                   	push   %ecx
  80082c:	ff d6                	call   *%esi
			break;
  80082e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800831:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800834:	e9 9c fc ff ff       	jmp    8004d5 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800839:	83 ec 08             	sub    $0x8,%esp
  80083c:	53                   	push   %ebx
  80083d:	6a 25                	push   $0x25
  80083f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800841:	83 c4 10             	add    $0x10,%esp
  800844:	eb 03                	jmp    800849 <vprintfmt+0x39a>
  800846:	83 ef 01             	sub    $0x1,%edi
  800849:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80084d:	75 f7                	jne    800846 <vprintfmt+0x397>
  80084f:	e9 81 fc ff ff       	jmp    8004d5 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800854:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800857:	5b                   	pop    %ebx
  800858:	5e                   	pop    %esi
  800859:	5f                   	pop    %edi
  80085a:	5d                   	pop    %ebp
  80085b:	c3                   	ret    

0080085c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80085c:	55                   	push   %ebp
  80085d:	89 e5                	mov    %esp,%ebp
  80085f:	83 ec 18             	sub    $0x18,%esp
  800862:	8b 45 08             	mov    0x8(%ebp),%eax
  800865:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800868:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80086b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80086f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800872:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800879:	85 c0                	test   %eax,%eax
  80087b:	74 26                	je     8008a3 <vsnprintf+0x47>
  80087d:	85 d2                	test   %edx,%edx
  80087f:	7e 22                	jle    8008a3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800881:	ff 75 14             	pushl  0x14(%ebp)
  800884:	ff 75 10             	pushl  0x10(%ebp)
  800887:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80088a:	50                   	push   %eax
  80088b:	68 75 04 80 00       	push   $0x800475
  800890:	e8 1a fc ff ff       	call   8004af <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800895:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800898:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80089b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80089e:	83 c4 10             	add    $0x10,%esp
  8008a1:	eb 05                	jmp    8008a8 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008a8:	c9                   	leave  
  8008a9:	c3                   	ret    

008008aa <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008b0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008b3:	50                   	push   %eax
  8008b4:	ff 75 10             	pushl  0x10(%ebp)
  8008b7:	ff 75 0c             	pushl  0xc(%ebp)
  8008ba:	ff 75 08             	pushl  0x8(%ebp)
  8008bd:	e8 9a ff ff ff       	call   80085c <vsnprintf>
	va_end(ap);

	return rc;
}
  8008c2:	c9                   	leave  
  8008c3:	c3                   	ret    

008008c4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cf:	eb 03                	jmp    8008d4 <strlen+0x10>
		n++;
  8008d1:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008d4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008d8:	75 f7                	jne    8008d1 <strlen+0xd>
		n++;
	return n;
}
  8008da:	5d                   	pop    %ebp
  8008db:	c3                   	ret    

008008dc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e2:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ea:	eb 03                	jmp    8008ef <strnlen+0x13>
		n++;
  8008ec:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ef:	39 c2                	cmp    %eax,%edx
  8008f1:	74 08                	je     8008fb <strnlen+0x1f>
  8008f3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008f7:	75 f3                	jne    8008ec <strnlen+0x10>
  8008f9:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008fb:	5d                   	pop    %ebp
  8008fc:	c3                   	ret    

008008fd <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	53                   	push   %ebx
  800901:	8b 45 08             	mov    0x8(%ebp),%eax
  800904:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800907:	89 c2                	mov    %eax,%edx
  800909:	83 c2 01             	add    $0x1,%edx
  80090c:	83 c1 01             	add    $0x1,%ecx
  80090f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800913:	88 5a ff             	mov    %bl,-0x1(%edx)
  800916:	84 db                	test   %bl,%bl
  800918:	75 ef                	jne    800909 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80091a:	5b                   	pop    %ebx
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	53                   	push   %ebx
  800921:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800924:	53                   	push   %ebx
  800925:	e8 9a ff ff ff       	call   8008c4 <strlen>
  80092a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80092d:	ff 75 0c             	pushl  0xc(%ebp)
  800930:	01 d8                	add    %ebx,%eax
  800932:	50                   	push   %eax
  800933:	e8 c5 ff ff ff       	call   8008fd <strcpy>
	return dst;
}
  800938:	89 d8                	mov    %ebx,%eax
  80093a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80093d:	c9                   	leave  
  80093e:	c3                   	ret    

0080093f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	56                   	push   %esi
  800943:	53                   	push   %ebx
  800944:	8b 75 08             	mov    0x8(%ebp),%esi
  800947:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80094a:	89 f3                	mov    %esi,%ebx
  80094c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80094f:	89 f2                	mov    %esi,%edx
  800951:	eb 0f                	jmp    800962 <strncpy+0x23>
		*dst++ = *src;
  800953:	83 c2 01             	add    $0x1,%edx
  800956:	0f b6 01             	movzbl (%ecx),%eax
  800959:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80095c:	80 39 01             	cmpb   $0x1,(%ecx)
  80095f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800962:	39 da                	cmp    %ebx,%edx
  800964:	75 ed                	jne    800953 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800966:	89 f0                	mov    %esi,%eax
  800968:	5b                   	pop    %ebx
  800969:	5e                   	pop    %esi
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	56                   	push   %esi
  800970:	53                   	push   %ebx
  800971:	8b 75 08             	mov    0x8(%ebp),%esi
  800974:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800977:	8b 55 10             	mov    0x10(%ebp),%edx
  80097a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80097c:	85 d2                	test   %edx,%edx
  80097e:	74 21                	je     8009a1 <strlcpy+0x35>
  800980:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800984:	89 f2                	mov    %esi,%edx
  800986:	eb 09                	jmp    800991 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800988:	83 c2 01             	add    $0x1,%edx
  80098b:	83 c1 01             	add    $0x1,%ecx
  80098e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800991:	39 c2                	cmp    %eax,%edx
  800993:	74 09                	je     80099e <strlcpy+0x32>
  800995:	0f b6 19             	movzbl (%ecx),%ebx
  800998:	84 db                	test   %bl,%bl
  80099a:	75 ec                	jne    800988 <strlcpy+0x1c>
  80099c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80099e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009a1:	29 f0                	sub    %esi,%eax
}
  8009a3:	5b                   	pop    %ebx
  8009a4:	5e                   	pop    %esi
  8009a5:	5d                   	pop    %ebp
  8009a6:	c3                   	ret    

008009a7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ad:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009b0:	eb 06                	jmp    8009b8 <strcmp+0x11>
		p++, q++;
  8009b2:	83 c1 01             	add    $0x1,%ecx
  8009b5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009b8:	0f b6 01             	movzbl (%ecx),%eax
  8009bb:	84 c0                	test   %al,%al
  8009bd:	74 04                	je     8009c3 <strcmp+0x1c>
  8009bf:	3a 02                	cmp    (%edx),%al
  8009c1:	74 ef                	je     8009b2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c3:	0f b6 c0             	movzbl %al,%eax
  8009c6:	0f b6 12             	movzbl (%edx),%edx
  8009c9:	29 d0                	sub    %edx,%eax
}
  8009cb:	5d                   	pop    %ebp
  8009cc:	c3                   	ret    

008009cd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	53                   	push   %ebx
  8009d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d7:	89 c3                	mov    %eax,%ebx
  8009d9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009dc:	eb 06                	jmp    8009e4 <strncmp+0x17>
		n--, p++, q++;
  8009de:	83 c0 01             	add    $0x1,%eax
  8009e1:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009e4:	39 d8                	cmp    %ebx,%eax
  8009e6:	74 15                	je     8009fd <strncmp+0x30>
  8009e8:	0f b6 08             	movzbl (%eax),%ecx
  8009eb:	84 c9                	test   %cl,%cl
  8009ed:	74 04                	je     8009f3 <strncmp+0x26>
  8009ef:	3a 0a                	cmp    (%edx),%cl
  8009f1:	74 eb                	je     8009de <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f3:	0f b6 00             	movzbl (%eax),%eax
  8009f6:	0f b6 12             	movzbl (%edx),%edx
  8009f9:	29 d0                	sub    %edx,%eax
  8009fb:	eb 05                	jmp    800a02 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009fd:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a02:	5b                   	pop    %ebx
  800a03:	5d                   	pop    %ebp
  800a04:	c3                   	ret    

00800a05 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a0f:	eb 07                	jmp    800a18 <strchr+0x13>
		if (*s == c)
  800a11:	38 ca                	cmp    %cl,%dl
  800a13:	74 0f                	je     800a24 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a15:	83 c0 01             	add    $0x1,%eax
  800a18:	0f b6 10             	movzbl (%eax),%edx
  800a1b:	84 d2                	test   %dl,%dl
  800a1d:	75 f2                	jne    800a11 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a1f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a30:	eb 03                	jmp    800a35 <strfind+0xf>
  800a32:	83 c0 01             	add    $0x1,%eax
  800a35:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a38:	38 ca                	cmp    %cl,%dl
  800a3a:	74 04                	je     800a40 <strfind+0x1a>
  800a3c:	84 d2                	test   %dl,%dl
  800a3e:	75 f2                	jne    800a32 <strfind+0xc>
			break;
	return (char *) s;
}
  800a40:	5d                   	pop    %ebp
  800a41:	c3                   	ret    

00800a42 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	57                   	push   %edi
  800a46:	56                   	push   %esi
  800a47:	53                   	push   %ebx
  800a48:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a4b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a4e:	85 c9                	test   %ecx,%ecx
  800a50:	74 36                	je     800a88 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a52:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a58:	75 28                	jne    800a82 <memset+0x40>
  800a5a:	f6 c1 03             	test   $0x3,%cl
  800a5d:	75 23                	jne    800a82 <memset+0x40>
		c &= 0xFF;
  800a5f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a63:	89 d3                	mov    %edx,%ebx
  800a65:	c1 e3 08             	shl    $0x8,%ebx
  800a68:	89 d6                	mov    %edx,%esi
  800a6a:	c1 e6 18             	shl    $0x18,%esi
  800a6d:	89 d0                	mov    %edx,%eax
  800a6f:	c1 e0 10             	shl    $0x10,%eax
  800a72:	09 f0                	or     %esi,%eax
  800a74:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a76:	89 d8                	mov    %ebx,%eax
  800a78:	09 d0                	or     %edx,%eax
  800a7a:	c1 e9 02             	shr    $0x2,%ecx
  800a7d:	fc                   	cld    
  800a7e:	f3 ab                	rep stos %eax,%es:(%edi)
  800a80:	eb 06                	jmp    800a88 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a82:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a85:	fc                   	cld    
  800a86:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a88:	89 f8                	mov    %edi,%eax
  800a8a:	5b                   	pop    %ebx
  800a8b:	5e                   	pop    %esi
  800a8c:	5f                   	pop    %edi
  800a8d:	5d                   	pop    %ebp
  800a8e:	c3                   	ret    

00800a8f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a8f:	55                   	push   %ebp
  800a90:	89 e5                	mov    %esp,%ebp
  800a92:	57                   	push   %edi
  800a93:	56                   	push   %esi
  800a94:	8b 45 08             	mov    0x8(%ebp),%eax
  800a97:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a9a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a9d:	39 c6                	cmp    %eax,%esi
  800a9f:	73 35                	jae    800ad6 <memmove+0x47>
  800aa1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aa4:	39 d0                	cmp    %edx,%eax
  800aa6:	73 2e                	jae    800ad6 <memmove+0x47>
		s += n;
		d += n;
  800aa8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aab:	89 d6                	mov    %edx,%esi
  800aad:	09 fe                	or     %edi,%esi
  800aaf:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ab5:	75 13                	jne    800aca <memmove+0x3b>
  800ab7:	f6 c1 03             	test   $0x3,%cl
  800aba:	75 0e                	jne    800aca <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800abc:	83 ef 04             	sub    $0x4,%edi
  800abf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ac2:	c1 e9 02             	shr    $0x2,%ecx
  800ac5:	fd                   	std    
  800ac6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac8:	eb 09                	jmp    800ad3 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aca:	83 ef 01             	sub    $0x1,%edi
  800acd:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ad0:	fd                   	std    
  800ad1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ad3:	fc                   	cld    
  800ad4:	eb 1d                	jmp    800af3 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad6:	89 f2                	mov    %esi,%edx
  800ad8:	09 c2                	or     %eax,%edx
  800ada:	f6 c2 03             	test   $0x3,%dl
  800add:	75 0f                	jne    800aee <memmove+0x5f>
  800adf:	f6 c1 03             	test   $0x3,%cl
  800ae2:	75 0a                	jne    800aee <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ae4:	c1 e9 02             	shr    $0x2,%ecx
  800ae7:	89 c7                	mov    %eax,%edi
  800ae9:	fc                   	cld    
  800aea:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aec:	eb 05                	jmp    800af3 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aee:	89 c7                	mov    %eax,%edi
  800af0:	fc                   	cld    
  800af1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800af3:	5e                   	pop    %esi
  800af4:	5f                   	pop    %edi
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800afa:	ff 75 10             	pushl  0x10(%ebp)
  800afd:	ff 75 0c             	pushl  0xc(%ebp)
  800b00:	ff 75 08             	pushl  0x8(%ebp)
  800b03:	e8 87 ff ff ff       	call   800a8f <memmove>
}
  800b08:	c9                   	leave  
  800b09:	c3                   	ret    

00800b0a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	56                   	push   %esi
  800b0e:	53                   	push   %ebx
  800b0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b12:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b15:	89 c6                	mov    %eax,%esi
  800b17:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b1a:	eb 1a                	jmp    800b36 <memcmp+0x2c>
		if (*s1 != *s2)
  800b1c:	0f b6 08             	movzbl (%eax),%ecx
  800b1f:	0f b6 1a             	movzbl (%edx),%ebx
  800b22:	38 d9                	cmp    %bl,%cl
  800b24:	74 0a                	je     800b30 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b26:	0f b6 c1             	movzbl %cl,%eax
  800b29:	0f b6 db             	movzbl %bl,%ebx
  800b2c:	29 d8                	sub    %ebx,%eax
  800b2e:	eb 0f                	jmp    800b3f <memcmp+0x35>
		s1++, s2++;
  800b30:	83 c0 01             	add    $0x1,%eax
  800b33:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b36:	39 f0                	cmp    %esi,%eax
  800b38:	75 e2                	jne    800b1c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b3f:	5b                   	pop    %ebx
  800b40:	5e                   	pop    %esi
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	53                   	push   %ebx
  800b47:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b4a:	89 c1                	mov    %eax,%ecx
  800b4c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b4f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b53:	eb 0a                	jmp    800b5f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b55:	0f b6 10             	movzbl (%eax),%edx
  800b58:	39 da                	cmp    %ebx,%edx
  800b5a:	74 07                	je     800b63 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b5c:	83 c0 01             	add    $0x1,%eax
  800b5f:	39 c8                	cmp    %ecx,%eax
  800b61:	72 f2                	jb     800b55 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b63:	5b                   	pop    %ebx
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    

00800b66 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	57                   	push   %edi
  800b6a:	56                   	push   %esi
  800b6b:	53                   	push   %ebx
  800b6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b72:	eb 03                	jmp    800b77 <strtol+0x11>
		s++;
  800b74:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b77:	0f b6 01             	movzbl (%ecx),%eax
  800b7a:	3c 20                	cmp    $0x20,%al
  800b7c:	74 f6                	je     800b74 <strtol+0xe>
  800b7e:	3c 09                	cmp    $0x9,%al
  800b80:	74 f2                	je     800b74 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b82:	3c 2b                	cmp    $0x2b,%al
  800b84:	75 0a                	jne    800b90 <strtol+0x2a>
		s++;
  800b86:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b89:	bf 00 00 00 00       	mov    $0x0,%edi
  800b8e:	eb 11                	jmp    800ba1 <strtol+0x3b>
  800b90:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b95:	3c 2d                	cmp    $0x2d,%al
  800b97:	75 08                	jne    800ba1 <strtol+0x3b>
		s++, neg = 1;
  800b99:	83 c1 01             	add    $0x1,%ecx
  800b9c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ba1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ba7:	75 15                	jne    800bbe <strtol+0x58>
  800ba9:	80 39 30             	cmpb   $0x30,(%ecx)
  800bac:	75 10                	jne    800bbe <strtol+0x58>
  800bae:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bb2:	75 7c                	jne    800c30 <strtol+0xca>
		s += 2, base = 16;
  800bb4:	83 c1 02             	add    $0x2,%ecx
  800bb7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bbc:	eb 16                	jmp    800bd4 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bbe:	85 db                	test   %ebx,%ebx
  800bc0:	75 12                	jne    800bd4 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bc2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bc7:	80 39 30             	cmpb   $0x30,(%ecx)
  800bca:	75 08                	jne    800bd4 <strtol+0x6e>
		s++, base = 8;
  800bcc:	83 c1 01             	add    $0x1,%ecx
  800bcf:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bd4:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd9:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bdc:	0f b6 11             	movzbl (%ecx),%edx
  800bdf:	8d 72 d0             	lea    -0x30(%edx),%esi
  800be2:	89 f3                	mov    %esi,%ebx
  800be4:	80 fb 09             	cmp    $0x9,%bl
  800be7:	77 08                	ja     800bf1 <strtol+0x8b>
			dig = *s - '0';
  800be9:	0f be d2             	movsbl %dl,%edx
  800bec:	83 ea 30             	sub    $0x30,%edx
  800bef:	eb 22                	jmp    800c13 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800bf1:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bf4:	89 f3                	mov    %esi,%ebx
  800bf6:	80 fb 19             	cmp    $0x19,%bl
  800bf9:	77 08                	ja     800c03 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bfb:	0f be d2             	movsbl %dl,%edx
  800bfe:	83 ea 57             	sub    $0x57,%edx
  800c01:	eb 10                	jmp    800c13 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c03:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c06:	89 f3                	mov    %esi,%ebx
  800c08:	80 fb 19             	cmp    $0x19,%bl
  800c0b:	77 16                	ja     800c23 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c0d:	0f be d2             	movsbl %dl,%edx
  800c10:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c13:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c16:	7d 0b                	jge    800c23 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c18:	83 c1 01             	add    $0x1,%ecx
  800c1b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c1f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c21:	eb b9                	jmp    800bdc <strtol+0x76>

	if (endptr)
  800c23:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c27:	74 0d                	je     800c36 <strtol+0xd0>
		*endptr = (char *) s;
  800c29:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c2c:	89 0e                	mov    %ecx,(%esi)
  800c2e:	eb 06                	jmp    800c36 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c30:	85 db                	test   %ebx,%ebx
  800c32:	74 98                	je     800bcc <strtol+0x66>
  800c34:	eb 9e                	jmp    800bd4 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c36:	89 c2                	mov    %eax,%edx
  800c38:	f7 da                	neg    %edx
  800c3a:	85 ff                	test   %edi,%edi
  800c3c:	0f 45 c2             	cmovne %edx,%eax
}
  800c3f:	5b                   	pop    %ebx
  800c40:	5e                   	pop    %esi
  800c41:	5f                   	pop    %edi
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	57                   	push   %edi
  800c48:	56                   	push   %esi
  800c49:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c52:	8b 55 08             	mov    0x8(%ebp),%edx
  800c55:	89 c3                	mov    %eax,%ebx
  800c57:	89 c7                	mov    %eax,%edi
  800c59:	89 c6                	mov    %eax,%esi
  800c5b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c5d:	5b                   	pop    %ebx
  800c5e:	5e                   	pop    %esi
  800c5f:	5f                   	pop    %edi
  800c60:	5d                   	pop    %ebp
  800c61:	c3                   	ret    

00800c62 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	57                   	push   %edi
  800c66:	56                   	push   %esi
  800c67:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c68:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6d:	b8 01 00 00 00       	mov    $0x1,%eax
  800c72:	89 d1                	mov    %edx,%ecx
  800c74:	89 d3                	mov    %edx,%ebx
  800c76:	89 d7                	mov    %edx,%edi
  800c78:	89 d6                	mov    %edx,%esi
  800c7a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c7c:	5b                   	pop    %ebx
  800c7d:	5e                   	pop    %esi
  800c7e:	5f                   	pop    %edi
  800c7f:	5d                   	pop    %ebp
  800c80:	c3                   	ret    

00800c81 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	57                   	push   %edi
  800c85:	56                   	push   %esi
  800c86:	53                   	push   %ebx
  800c87:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c8f:	b8 03 00 00 00       	mov    $0x3,%eax
  800c94:	8b 55 08             	mov    0x8(%ebp),%edx
  800c97:	89 cb                	mov    %ecx,%ebx
  800c99:	89 cf                	mov    %ecx,%edi
  800c9b:	89 ce                	mov    %ecx,%esi
  800c9d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c9f:	85 c0                	test   %eax,%eax
  800ca1:	7e 17                	jle    800cba <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca3:	83 ec 0c             	sub    $0xc,%esp
  800ca6:	50                   	push   %eax
  800ca7:	6a 03                	push   $0x3
  800ca9:	68 bf 23 80 00       	push   $0x8023bf
  800cae:	6a 23                	push   $0x23
  800cb0:	68 dc 23 80 00       	push   $0x8023dc
  800cb5:	e8 e5 f5 ff ff       	call   80029f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ccd:	b8 02 00 00 00       	mov    $0x2,%eax
  800cd2:	89 d1                	mov    %edx,%ecx
  800cd4:	89 d3                	mov    %edx,%ebx
  800cd6:	89 d7                	mov    %edx,%edi
  800cd8:	89 d6                	mov    %edx,%esi
  800cda:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cdc:	5b                   	pop    %ebx
  800cdd:	5e                   	pop    %esi
  800cde:	5f                   	pop    %edi
  800cdf:	5d                   	pop    %ebp
  800ce0:	c3                   	ret    

00800ce1 <sys_yield>:

void
sys_yield(void)
{
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	57                   	push   %edi
  800ce5:	56                   	push   %esi
  800ce6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce7:	ba 00 00 00 00       	mov    $0x0,%edx
  800cec:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cf1:	89 d1                	mov    %edx,%ecx
  800cf3:	89 d3                	mov    %edx,%ebx
  800cf5:	89 d7                	mov    %edx,%edi
  800cf7:	89 d6                	mov    %edx,%esi
  800cf9:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5f                   	pop    %edi
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	57                   	push   %edi
  800d04:	56                   	push   %esi
  800d05:	53                   	push   %ebx
  800d06:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d09:	be 00 00 00 00       	mov    $0x0,%esi
  800d0e:	b8 04 00 00 00       	mov    $0x4,%eax
  800d13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d16:	8b 55 08             	mov    0x8(%ebp),%edx
  800d19:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1c:	89 f7                	mov    %esi,%edi
  800d1e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d20:	85 c0                	test   %eax,%eax
  800d22:	7e 17                	jle    800d3b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d24:	83 ec 0c             	sub    $0xc,%esp
  800d27:	50                   	push   %eax
  800d28:	6a 04                	push   $0x4
  800d2a:	68 bf 23 80 00       	push   $0x8023bf
  800d2f:	6a 23                	push   $0x23
  800d31:	68 dc 23 80 00       	push   $0x8023dc
  800d36:	e8 64 f5 ff ff       	call   80029f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3e:	5b                   	pop    %ebx
  800d3f:	5e                   	pop    %esi
  800d40:	5f                   	pop    %edi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	57                   	push   %edi
  800d47:	56                   	push   %esi
  800d48:	53                   	push   %ebx
  800d49:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4c:	b8 05 00 00 00       	mov    $0x5,%eax
  800d51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d54:	8b 55 08             	mov    0x8(%ebp),%edx
  800d57:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d5d:	8b 75 18             	mov    0x18(%ebp),%esi
  800d60:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d62:	85 c0                	test   %eax,%eax
  800d64:	7e 17                	jle    800d7d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d66:	83 ec 0c             	sub    $0xc,%esp
  800d69:	50                   	push   %eax
  800d6a:	6a 05                	push   $0x5
  800d6c:	68 bf 23 80 00       	push   $0x8023bf
  800d71:	6a 23                	push   $0x23
  800d73:	68 dc 23 80 00       	push   $0x8023dc
  800d78:	e8 22 f5 ff ff       	call   80029f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	57                   	push   %edi
  800d89:	56                   	push   %esi
  800d8a:	53                   	push   %ebx
  800d8b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d93:	b8 06 00 00 00       	mov    $0x6,%eax
  800d98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9e:	89 df                	mov    %ebx,%edi
  800da0:	89 de                	mov    %ebx,%esi
  800da2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da4:	85 c0                	test   %eax,%eax
  800da6:	7e 17                	jle    800dbf <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da8:	83 ec 0c             	sub    $0xc,%esp
  800dab:	50                   	push   %eax
  800dac:	6a 06                	push   $0x6
  800dae:	68 bf 23 80 00       	push   $0x8023bf
  800db3:	6a 23                	push   $0x23
  800db5:	68 dc 23 80 00       	push   $0x8023dc
  800dba:	e8 e0 f4 ff ff       	call   80029f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc2:	5b                   	pop    %ebx
  800dc3:	5e                   	pop    %esi
  800dc4:	5f                   	pop    %edi
  800dc5:	5d                   	pop    %ebp
  800dc6:	c3                   	ret    

00800dc7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dc7:	55                   	push   %ebp
  800dc8:	89 e5                	mov    %esp,%ebp
  800dca:	57                   	push   %edi
  800dcb:	56                   	push   %esi
  800dcc:	53                   	push   %ebx
  800dcd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd5:	b8 08 00 00 00       	mov    $0x8,%eax
  800dda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ddd:	8b 55 08             	mov    0x8(%ebp),%edx
  800de0:	89 df                	mov    %ebx,%edi
  800de2:	89 de                	mov    %ebx,%esi
  800de4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de6:	85 c0                	test   %eax,%eax
  800de8:	7e 17                	jle    800e01 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dea:	83 ec 0c             	sub    $0xc,%esp
  800ded:	50                   	push   %eax
  800dee:	6a 08                	push   $0x8
  800df0:	68 bf 23 80 00       	push   $0x8023bf
  800df5:	6a 23                	push   $0x23
  800df7:	68 dc 23 80 00       	push   $0x8023dc
  800dfc:	e8 9e f4 ff ff       	call   80029f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e04:	5b                   	pop    %ebx
  800e05:	5e                   	pop    %esi
  800e06:	5f                   	pop    %edi
  800e07:	5d                   	pop    %ebp
  800e08:	c3                   	ret    

00800e09 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	57                   	push   %edi
  800e0d:	56                   	push   %esi
  800e0e:	53                   	push   %ebx
  800e0f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e12:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e17:	b8 09 00 00 00       	mov    $0x9,%eax
  800e1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e22:	89 df                	mov    %ebx,%edi
  800e24:	89 de                	mov    %ebx,%esi
  800e26:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e28:	85 c0                	test   %eax,%eax
  800e2a:	7e 17                	jle    800e43 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2c:	83 ec 0c             	sub    $0xc,%esp
  800e2f:	50                   	push   %eax
  800e30:	6a 09                	push   $0x9
  800e32:	68 bf 23 80 00       	push   $0x8023bf
  800e37:	6a 23                	push   $0x23
  800e39:	68 dc 23 80 00       	push   $0x8023dc
  800e3e:	e8 5c f4 ff ff       	call   80029f <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e46:	5b                   	pop    %ebx
  800e47:	5e                   	pop    %esi
  800e48:	5f                   	pop    %edi
  800e49:	5d                   	pop    %ebp
  800e4a:	c3                   	ret    

00800e4b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	57                   	push   %edi
  800e4f:	56                   	push   %esi
  800e50:	53                   	push   %ebx
  800e51:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e54:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e59:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e61:	8b 55 08             	mov    0x8(%ebp),%edx
  800e64:	89 df                	mov    %ebx,%edi
  800e66:	89 de                	mov    %ebx,%esi
  800e68:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e6a:	85 c0                	test   %eax,%eax
  800e6c:	7e 17                	jle    800e85 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6e:	83 ec 0c             	sub    $0xc,%esp
  800e71:	50                   	push   %eax
  800e72:	6a 0a                	push   $0xa
  800e74:	68 bf 23 80 00       	push   $0x8023bf
  800e79:	6a 23                	push   $0x23
  800e7b:	68 dc 23 80 00       	push   $0x8023dc
  800e80:	e8 1a f4 ff ff       	call   80029f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e88:	5b                   	pop    %ebx
  800e89:	5e                   	pop    %esi
  800e8a:	5f                   	pop    %edi
  800e8b:	5d                   	pop    %ebp
  800e8c:	c3                   	ret    

00800e8d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e8d:	55                   	push   %ebp
  800e8e:	89 e5                	mov    %esp,%ebp
  800e90:	57                   	push   %edi
  800e91:	56                   	push   %esi
  800e92:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e93:	be 00 00 00 00       	mov    $0x0,%esi
  800e98:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ea6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ea9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eab:	5b                   	pop    %ebx
  800eac:	5e                   	pop    %esi
  800ead:	5f                   	pop    %edi
  800eae:	5d                   	pop    %ebp
  800eaf:	c3                   	ret    

00800eb0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800eb0:	55                   	push   %ebp
  800eb1:	89 e5                	mov    %esp,%ebp
  800eb3:	57                   	push   %edi
  800eb4:	56                   	push   %esi
  800eb5:	53                   	push   %ebx
  800eb6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ebe:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ec3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec6:	89 cb                	mov    %ecx,%ebx
  800ec8:	89 cf                	mov    %ecx,%edi
  800eca:	89 ce                	mov    %ecx,%esi
  800ecc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ece:	85 c0                	test   %eax,%eax
  800ed0:	7e 17                	jle    800ee9 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed2:	83 ec 0c             	sub    $0xc,%esp
  800ed5:	50                   	push   %eax
  800ed6:	6a 0d                	push   $0xd
  800ed8:	68 bf 23 80 00       	push   $0x8023bf
  800edd:	6a 23                	push   $0x23
  800edf:	68 dc 23 80 00       	push   $0x8023dc
  800ee4:	e8 b6 f3 ff ff       	call   80029f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ee9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eec:	5b                   	pop    %ebx
  800eed:	5e                   	pop    %esi
  800eee:	5f                   	pop    %edi
  800eef:	5d                   	pop    %ebp
  800ef0:	c3                   	ret    

00800ef1 <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	57                   	push   %edi
  800ef5:	56                   	push   %esi
  800ef6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800efc:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f01:	8b 55 08             	mov    0x8(%ebp),%edx
  800f04:	89 cb                	mov    %ecx,%ebx
  800f06:	89 cf                	mov    %ecx,%edi
  800f08:	89 ce                	mov    %ecx,%esi
  800f0a:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800f0c:	5b                   	pop    %ebx
  800f0d:	5e                   	pop    %esi
  800f0e:	5f                   	pop    %edi
  800f0f:	5d                   	pop    %ebp
  800f10:	c3                   	ret    

00800f11 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f14:	8b 45 08             	mov    0x8(%ebp),%eax
  800f17:	05 00 00 00 30       	add    $0x30000000,%eax
  800f1c:	c1 e8 0c             	shr    $0xc,%eax
}
  800f1f:	5d                   	pop    %ebp
  800f20:	c3                   	ret    

00800f21 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f21:	55                   	push   %ebp
  800f22:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800f24:	8b 45 08             	mov    0x8(%ebp),%eax
  800f27:	05 00 00 00 30       	add    $0x30000000,%eax
  800f2c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f31:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f36:	5d                   	pop    %ebp
  800f37:	c3                   	ret    

00800f38 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f38:	55                   	push   %ebp
  800f39:	89 e5                	mov    %esp,%ebp
  800f3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f3e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f43:	89 c2                	mov    %eax,%edx
  800f45:	c1 ea 16             	shr    $0x16,%edx
  800f48:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f4f:	f6 c2 01             	test   $0x1,%dl
  800f52:	74 11                	je     800f65 <fd_alloc+0x2d>
  800f54:	89 c2                	mov    %eax,%edx
  800f56:	c1 ea 0c             	shr    $0xc,%edx
  800f59:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f60:	f6 c2 01             	test   $0x1,%dl
  800f63:	75 09                	jne    800f6e <fd_alloc+0x36>
			*fd_store = fd;
  800f65:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f67:	b8 00 00 00 00       	mov    $0x0,%eax
  800f6c:	eb 17                	jmp    800f85 <fd_alloc+0x4d>
  800f6e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f73:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f78:	75 c9                	jne    800f43 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f7a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f80:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f85:	5d                   	pop    %ebp
  800f86:	c3                   	ret    

00800f87 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f8d:	83 f8 1f             	cmp    $0x1f,%eax
  800f90:	77 36                	ja     800fc8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f92:	c1 e0 0c             	shl    $0xc,%eax
  800f95:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f9a:	89 c2                	mov    %eax,%edx
  800f9c:	c1 ea 16             	shr    $0x16,%edx
  800f9f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fa6:	f6 c2 01             	test   $0x1,%dl
  800fa9:	74 24                	je     800fcf <fd_lookup+0x48>
  800fab:	89 c2                	mov    %eax,%edx
  800fad:	c1 ea 0c             	shr    $0xc,%edx
  800fb0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fb7:	f6 c2 01             	test   $0x1,%dl
  800fba:	74 1a                	je     800fd6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fbc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fbf:	89 02                	mov    %eax,(%edx)
	return 0;
  800fc1:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc6:	eb 13                	jmp    800fdb <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fc8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fcd:	eb 0c                	jmp    800fdb <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fcf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fd4:	eb 05                	jmp    800fdb <fd_lookup+0x54>
  800fd6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800fdb:	5d                   	pop    %ebp
  800fdc:	c3                   	ret    

00800fdd <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fdd:	55                   	push   %ebp
  800fde:	89 e5                	mov    %esp,%ebp
  800fe0:	83 ec 08             	sub    $0x8,%esp
  800fe3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fe6:	ba 6c 24 80 00       	mov    $0x80246c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800feb:	eb 13                	jmp    801000 <dev_lookup+0x23>
  800fed:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ff0:	39 08                	cmp    %ecx,(%eax)
  800ff2:	75 0c                	jne    801000 <dev_lookup+0x23>
			*dev = devtab[i];
  800ff4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff7:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ff9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ffe:	eb 2e                	jmp    80102e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801000:	8b 02                	mov    (%edx),%eax
  801002:	85 c0                	test   %eax,%eax
  801004:	75 e7                	jne    800fed <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801006:	a1 04 40 80 00       	mov    0x804004,%eax
  80100b:	8b 40 50             	mov    0x50(%eax),%eax
  80100e:	83 ec 04             	sub    $0x4,%esp
  801011:	51                   	push   %ecx
  801012:	50                   	push   %eax
  801013:	68 ec 23 80 00       	push   $0x8023ec
  801018:	e8 5b f3 ff ff       	call   800378 <cprintf>
	*dev = 0;
  80101d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801020:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801026:	83 c4 10             	add    $0x10,%esp
  801029:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80102e:	c9                   	leave  
  80102f:	c3                   	ret    

00801030 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	56                   	push   %esi
  801034:	53                   	push   %ebx
  801035:	83 ec 10             	sub    $0x10,%esp
  801038:	8b 75 08             	mov    0x8(%ebp),%esi
  80103b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80103e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801041:	50                   	push   %eax
  801042:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801048:	c1 e8 0c             	shr    $0xc,%eax
  80104b:	50                   	push   %eax
  80104c:	e8 36 ff ff ff       	call   800f87 <fd_lookup>
  801051:	83 c4 08             	add    $0x8,%esp
  801054:	85 c0                	test   %eax,%eax
  801056:	78 05                	js     80105d <fd_close+0x2d>
	    || fd != fd2)
  801058:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80105b:	74 0c                	je     801069 <fd_close+0x39>
		return (must_exist ? r : 0);
  80105d:	84 db                	test   %bl,%bl
  80105f:	ba 00 00 00 00       	mov    $0x0,%edx
  801064:	0f 44 c2             	cmove  %edx,%eax
  801067:	eb 41                	jmp    8010aa <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801069:	83 ec 08             	sub    $0x8,%esp
  80106c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80106f:	50                   	push   %eax
  801070:	ff 36                	pushl  (%esi)
  801072:	e8 66 ff ff ff       	call   800fdd <dev_lookup>
  801077:	89 c3                	mov    %eax,%ebx
  801079:	83 c4 10             	add    $0x10,%esp
  80107c:	85 c0                	test   %eax,%eax
  80107e:	78 1a                	js     80109a <fd_close+0x6a>
		if (dev->dev_close)
  801080:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801083:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801086:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80108b:	85 c0                	test   %eax,%eax
  80108d:	74 0b                	je     80109a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80108f:	83 ec 0c             	sub    $0xc,%esp
  801092:	56                   	push   %esi
  801093:	ff d0                	call   *%eax
  801095:	89 c3                	mov    %eax,%ebx
  801097:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80109a:	83 ec 08             	sub    $0x8,%esp
  80109d:	56                   	push   %esi
  80109e:	6a 00                	push   $0x0
  8010a0:	e8 e0 fc ff ff       	call   800d85 <sys_page_unmap>
	return r;
  8010a5:	83 c4 10             	add    $0x10,%esp
  8010a8:	89 d8                	mov    %ebx,%eax
}
  8010aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010ad:	5b                   	pop    %ebx
  8010ae:	5e                   	pop    %esi
  8010af:	5d                   	pop    %ebp
  8010b0:	c3                   	ret    

008010b1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010b1:	55                   	push   %ebp
  8010b2:	89 e5                	mov    %esp,%ebp
  8010b4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ba:	50                   	push   %eax
  8010bb:	ff 75 08             	pushl  0x8(%ebp)
  8010be:	e8 c4 fe ff ff       	call   800f87 <fd_lookup>
  8010c3:	83 c4 08             	add    $0x8,%esp
  8010c6:	85 c0                	test   %eax,%eax
  8010c8:	78 10                	js     8010da <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8010ca:	83 ec 08             	sub    $0x8,%esp
  8010cd:	6a 01                	push   $0x1
  8010cf:	ff 75 f4             	pushl  -0xc(%ebp)
  8010d2:	e8 59 ff ff ff       	call   801030 <fd_close>
  8010d7:	83 c4 10             	add    $0x10,%esp
}
  8010da:	c9                   	leave  
  8010db:	c3                   	ret    

008010dc <close_all>:

void
close_all(void)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	53                   	push   %ebx
  8010e0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010e3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010e8:	83 ec 0c             	sub    $0xc,%esp
  8010eb:	53                   	push   %ebx
  8010ec:	e8 c0 ff ff ff       	call   8010b1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010f1:	83 c3 01             	add    $0x1,%ebx
  8010f4:	83 c4 10             	add    $0x10,%esp
  8010f7:	83 fb 20             	cmp    $0x20,%ebx
  8010fa:	75 ec                	jne    8010e8 <close_all+0xc>
		close(i);
}
  8010fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ff:	c9                   	leave  
  801100:	c3                   	ret    

00801101 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
  801104:	57                   	push   %edi
  801105:	56                   	push   %esi
  801106:	53                   	push   %ebx
  801107:	83 ec 2c             	sub    $0x2c,%esp
  80110a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80110d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801110:	50                   	push   %eax
  801111:	ff 75 08             	pushl  0x8(%ebp)
  801114:	e8 6e fe ff ff       	call   800f87 <fd_lookup>
  801119:	83 c4 08             	add    $0x8,%esp
  80111c:	85 c0                	test   %eax,%eax
  80111e:	0f 88 c1 00 00 00    	js     8011e5 <dup+0xe4>
		return r;
	close(newfdnum);
  801124:	83 ec 0c             	sub    $0xc,%esp
  801127:	56                   	push   %esi
  801128:	e8 84 ff ff ff       	call   8010b1 <close>

	newfd = INDEX2FD(newfdnum);
  80112d:	89 f3                	mov    %esi,%ebx
  80112f:	c1 e3 0c             	shl    $0xc,%ebx
  801132:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801138:	83 c4 04             	add    $0x4,%esp
  80113b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80113e:	e8 de fd ff ff       	call   800f21 <fd2data>
  801143:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801145:	89 1c 24             	mov    %ebx,(%esp)
  801148:	e8 d4 fd ff ff       	call   800f21 <fd2data>
  80114d:	83 c4 10             	add    $0x10,%esp
  801150:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801153:	89 f8                	mov    %edi,%eax
  801155:	c1 e8 16             	shr    $0x16,%eax
  801158:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80115f:	a8 01                	test   $0x1,%al
  801161:	74 37                	je     80119a <dup+0x99>
  801163:	89 f8                	mov    %edi,%eax
  801165:	c1 e8 0c             	shr    $0xc,%eax
  801168:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80116f:	f6 c2 01             	test   $0x1,%dl
  801172:	74 26                	je     80119a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801174:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80117b:	83 ec 0c             	sub    $0xc,%esp
  80117e:	25 07 0e 00 00       	and    $0xe07,%eax
  801183:	50                   	push   %eax
  801184:	ff 75 d4             	pushl  -0x2c(%ebp)
  801187:	6a 00                	push   $0x0
  801189:	57                   	push   %edi
  80118a:	6a 00                	push   $0x0
  80118c:	e8 b2 fb ff ff       	call   800d43 <sys_page_map>
  801191:	89 c7                	mov    %eax,%edi
  801193:	83 c4 20             	add    $0x20,%esp
  801196:	85 c0                	test   %eax,%eax
  801198:	78 2e                	js     8011c8 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80119a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80119d:	89 d0                	mov    %edx,%eax
  80119f:	c1 e8 0c             	shr    $0xc,%eax
  8011a2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011a9:	83 ec 0c             	sub    $0xc,%esp
  8011ac:	25 07 0e 00 00       	and    $0xe07,%eax
  8011b1:	50                   	push   %eax
  8011b2:	53                   	push   %ebx
  8011b3:	6a 00                	push   $0x0
  8011b5:	52                   	push   %edx
  8011b6:	6a 00                	push   $0x0
  8011b8:	e8 86 fb ff ff       	call   800d43 <sys_page_map>
  8011bd:	89 c7                	mov    %eax,%edi
  8011bf:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8011c2:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011c4:	85 ff                	test   %edi,%edi
  8011c6:	79 1d                	jns    8011e5 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011c8:	83 ec 08             	sub    $0x8,%esp
  8011cb:	53                   	push   %ebx
  8011cc:	6a 00                	push   $0x0
  8011ce:	e8 b2 fb ff ff       	call   800d85 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011d3:	83 c4 08             	add    $0x8,%esp
  8011d6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011d9:	6a 00                	push   $0x0
  8011db:	e8 a5 fb ff ff       	call   800d85 <sys_page_unmap>
	return r;
  8011e0:	83 c4 10             	add    $0x10,%esp
  8011e3:	89 f8                	mov    %edi,%eax
}
  8011e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e8:	5b                   	pop    %ebx
  8011e9:	5e                   	pop    %esi
  8011ea:	5f                   	pop    %edi
  8011eb:	5d                   	pop    %ebp
  8011ec:	c3                   	ret    

008011ed <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011ed:	55                   	push   %ebp
  8011ee:	89 e5                	mov    %esp,%ebp
  8011f0:	53                   	push   %ebx
  8011f1:	83 ec 14             	sub    $0x14,%esp
  8011f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011fa:	50                   	push   %eax
  8011fb:	53                   	push   %ebx
  8011fc:	e8 86 fd ff ff       	call   800f87 <fd_lookup>
  801201:	83 c4 08             	add    $0x8,%esp
  801204:	89 c2                	mov    %eax,%edx
  801206:	85 c0                	test   %eax,%eax
  801208:	78 6d                	js     801277 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80120a:	83 ec 08             	sub    $0x8,%esp
  80120d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801210:	50                   	push   %eax
  801211:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801214:	ff 30                	pushl  (%eax)
  801216:	e8 c2 fd ff ff       	call   800fdd <dev_lookup>
  80121b:	83 c4 10             	add    $0x10,%esp
  80121e:	85 c0                	test   %eax,%eax
  801220:	78 4c                	js     80126e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801222:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801225:	8b 42 08             	mov    0x8(%edx),%eax
  801228:	83 e0 03             	and    $0x3,%eax
  80122b:	83 f8 01             	cmp    $0x1,%eax
  80122e:	75 21                	jne    801251 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801230:	a1 04 40 80 00       	mov    0x804004,%eax
  801235:	8b 40 50             	mov    0x50(%eax),%eax
  801238:	83 ec 04             	sub    $0x4,%esp
  80123b:	53                   	push   %ebx
  80123c:	50                   	push   %eax
  80123d:	68 30 24 80 00       	push   $0x802430
  801242:	e8 31 f1 ff ff       	call   800378 <cprintf>
		return -E_INVAL;
  801247:	83 c4 10             	add    $0x10,%esp
  80124a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80124f:	eb 26                	jmp    801277 <read+0x8a>
	}
	if (!dev->dev_read)
  801251:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801254:	8b 40 08             	mov    0x8(%eax),%eax
  801257:	85 c0                	test   %eax,%eax
  801259:	74 17                	je     801272 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80125b:	83 ec 04             	sub    $0x4,%esp
  80125e:	ff 75 10             	pushl  0x10(%ebp)
  801261:	ff 75 0c             	pushl  0xc(%ebp)
  801264:	52                   	push   %edx
  801265:	ff d0                	call   *%eax
  801267:	89 c2                	mov    %eax,%edx
  801269:	83 c4 10             	add    $0x10,%esp
  80126c:	eb 09                	jmp    801277 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80126e:	89 c2                	mov    %eax,%edx
  801270:	eb 05                	jmp    801277 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801272:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801277:	89 d0                	mov    %edx,%eax
  801279:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80127c:	c9                   	leave  
  80127d:	c3                   	ret    

0080127e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80127e:	55                   	push   %ebp
  80127f:	89 e5                	mov    %esp,%ebp
  801281:	57                   	push   %edi
  801282:	56                   	push   %esi
  801283:	53                   	push   %ebx
  801284:	83 ec 0c             	sub    $0xc,%esp
  801287:	8b 7d 08             	mov    0x8(%ebp),%edi
  80128a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80128d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801292:	eb 21                	jmp    8012b5 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801294:	83 ec 04             	sub    $0x4,%esp
  801297:	89 f0                	mov    %esi,%eax
  801299:	29 d8                	sub    %ebx,%eax
  80129b:	50                   	push   %eax
  80129c:	89 d8                	mov    %ebx,%eax
  80129e:	03 45 0c             	add    0xc(%ebp),%eax
  8012a1:	50                   	push   %eax
  8012a2:	57                   	push   %edi
  8012a3:	e8 45 ff ff ff       	call   8011ed <read>
		if (m < 0)
  8012a8:	83 c4 10             	add    $0x10,%esp
  8012ab:	85 c0                	test   %eax,%eax
  8012ad:	78 10                	js     8012bf <readn+0x41>
			return m;
		if (m == 0)
  8012af:	85 c0                	test   %eax,%eax
  8012b1:	74 0a                	je     8012bd <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012b3:	01 c3                	add    %eax,%ebx
  8012b5:	39 f3                	cmp    %esi,%ebx
  8012b7:	72 db                	jb     801294 <readn+0x16>
  8012b9:	89 d8                	mov    %ebx,%eax
  8012bb:	eb 02                	jmp    8012bf <readn+0x41>
  8012bd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8012bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c2:	5b                   	pop    %ebx
  8012c3:	5e                   	pop    %esi
  8012c4:	5f                   	pop    %edi
  8012c5:	5d                   	pop    %ebp
  8012c6:	c3                   	ret    

008012c7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012c7:	55                   	push   %ebp
  8012c8:	89 e5                	mov    %esp,%ebp
  8012ca:	53                   	push   %ebx
  8012cb:	83 ec 14             	sub    $0x14,%esp
  8012ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d4:	50                   	push   %eax
  8012d5:	53                   	push   %ebx
  8012d6:	e8 ac fc ff ff       	call   800f87 <fd_lookup>
  8012db:	83 c4 08             	add    $0x8,%esp
  8012de:	89 c2                	mov    %eax,%edx
  8012e0:	85 c0                	test   %eax,%eax
  8012e2:	78 68                	js     80134c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e4:	83 ec 08             	sub    $0x8,%esp
  8012e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ea:	50                   	push   %eax
  8012eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ee:	ff 30                	pushl  (%eax)
  8012f0:	e8 e8 fc ff ff       	call   800fdd <dev_lookup>
  8012f5:	83 c4 10             	add    $0x10,%esp
  8012f8:	85 c0                	test   %eax,%eax
  8012fa:	78 47                	js     801343 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ff:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801303:	75 21                	jne    801326 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801305:	a1 04 40 80 00       	mov    0x804004,%eax
  80130a:	8b 40 50             	mov    0x50(%eax),%eax
  80130d:	83 ec 04             	sub    $0x4,%esp
  801310:	53                   	push   %ebx
  801311:	50                   	push   %eax
  801312:	68 4c 24 80 00       	push   $0x80244c
  801317:	e8 5c f0 ff ff       	call   800378 <cprintf>
		return -E_INVAL;
  80131c:	83 c4 10             	add    $0x10,%esp
  80131f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801324:	eb 26                	jmp    80134c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801326:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801329:	8b 52 0c             	mov    0xc(%edx),%edx
  80132c:	85 d2                	test   %edx,%edx
  80132e:	74 17                	je     801347 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801330:	83 ec 04             	sub    $0x4,%esp
  801333:	ff 75 10             	pushl  0x10(%ebp)
  801336:	ff 75 0c             	pushl  0xc(%ebp)
  801339:	50                   	push   %eax
  80133a:	ff d2                	call   *%edx
  80133c:	89 c2                	mov    %eax,%edx
  80133e:	83 c4 10             	add    $0x10,%esp
  801341:	eb 09                	jmp    80134c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801343:	89 c2                	mov    %eax,%edx
  801345:	eb 05                	jmp    80134c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801347:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80134c:	89 d0                	mov    %edx,%eax
  80134e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801351:	c9                   	leave  
  801352:	c3                   	ret    

00801353 <seek>:

int
seek(int fdnum, off_t offset)
{
  801353:	55                   	push   %ebp
  801354:	89 e5                	mov    %esp,%ebp
  801356:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801359:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80135c:	50                   	push   %eax
  80135d:	ff 75 08             	pushl  0x8(%ebp)
  801360:	e8 22 fc ff ff       	call   800f87 <fd_lookup>
  801365:	83 c4 08             	add    $0x8,%esp
  801368:	85 c0                	test   %eax,%eax
  80136a:	78 0e                	js     80137a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80136c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80136f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801372:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801375:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80137a:	c9                   	leave  
  80137b:	c3                   	ret    

0080137c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	53                   	push   %ebx
  801380:	83 ec 14             	sub    $0x14,%esp
  801383:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801386:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801389:	50                   	push   %eax
  80138a:	53                   	push   %ebx
  80138b:	e8 f7 fb ff ff       	call   800f87 <fd_lookup>
  801390:	83 c4 08             	add    $0x8,%esp
  801393:	89 c2                	mov    %eax,%edx
  801395:	85 c0                	test   %eax,%eax
  801397:	78 65                	js     8013fe <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801399:	83 ec 08             	sub    $0x8,%esp
  80139c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80139f:	50                   	push   %eax
  8013a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a3:	ff 30                	pushl  (%eax)
  8013a5:	e8 33 fc ff ff       	call   800fdd <dev_lookup>
  8013aa:	83 c4 10             	add    $0x10,%esp
  8013ad:	85 c0                	test   %eax,%eax
  8013af:	78 44                	js     8013f5 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013b8:	75 21                	jne    8013db <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013ba:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013bf:	8b 40 50             	mov    0x50(%eax),%eax
  8013c2:	83 ec 04             	sub    $0x4,%esp
  8013c5:	53                   	push   %ebx
  8013c6:	50                   	push   %eax
  8013c7:	68 0c 24 80 00       	push   $0x80240c
  8013cc:	e8 a7 ef ff ff       	call   800378 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013d1:	83 c4 10             	add    $0x10,%esp
  8013d4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013d9:	eb 23                	jmp    8013fe <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8013db:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013de:	8b 52 18             	mov    0x18(%edx),%edx
  8013e1:	85 d2                	test   %edx,%edx
  8013e3:	74 14                	je     8013f9 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013e5:	83 ec 08             	sub    $0x8,%esp
  8013e8:	ff 75 0c             	pushl  0xc(%ebp)
  8013eb:	50                   	push   %eax
  8013ec:	ff d2                	call   *%edx
  8013ee:	89 c2                	mov    %eax,%edx
  8013f0:	83 c4 10             	add    $0x10,%esp
  8013f3:	eb 09                	jmp    8013fe <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f5:	89 c2                	mov    %eax,%edx
  8013f7:	eb 05                	jmp    8013fe <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013f9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8013fe:	89 d0                	mov    %edx,%eax
  801400:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801403:	c9                   	leave  
  801404:	c3                   	ret    

00801405 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801405:	55                   	push   %ebp
  801406:	89 e5                	mov    %esp,%ebp
  801408:	53                   	push   %ebx
  801409:	83 ec 14             	sub    $0x14,%esp
  80140c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80140f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801412:	50                   	push   %eax
  801413:	ff 75 08             	pushl  0x8(%ebp)
  801416:	e8 6c fb ff ff       	call   800f87 <fd_lookup>
  80141b:	83 c4 08             	add    $0x8,%esp
  80141e:	89 c2                	mov    %eax,%edx
  801420:	85 c0                	test   %eax,%eax
  801422:	78 58                	js     80147c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801424:	83 ec 08             	sub    $0x8,%esp
  801427:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142a:	50                   	push   %eax
  80142b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142e:	ff 30                	pushl  (%eax)
  801430:	e8 a8 fb ff ff       	call   800fdd <dev_lookup>
  801435:	83 c4 10             	add    $0x10,%esp
  801438:	85 c0                	test   %eax,%eax
  80143a:	78 37                	js     801473 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80143c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80143f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801443:	74 32                	je     801477 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801445:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801448:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80144f:	00 00 00 
	stat->st_isdir = 0;
  801452:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801459:	00 00 00 
	stat->st_dev = dev;
  80145c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801462:	83 ec 08             	sub    $0x8,%esp
  801465:	53                   	push   %ebx
  801466:	ff 75 f0             	pushl  -0x10(%ebp)
  801469:	ff 50 14             	call   *0x14(%eax)
  80146c:	89 c2                	mov    %eax,%edx
  80146e:	83 c4 10             	add    $0x10,%esp
  801471:	eb 09                	jmp    80147c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801473:	89 c2                	mov    %eax,%edx
  801475:	eb 05                	jmp    80147c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801477:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80147c:	89 d0                	mov    %edx,%eax
  80147e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801481:	c9                   	leave  
  801482:	c3                   	ret    

00801483 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801483:	55                   	push   %ebp
  801484:	89 e5                	mov    %esp,%ebp
  801486:	56                   	push   %esi
  801487:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801488:	83 ec 08             	sub    $0x8,%esp
  80148b:	6a 00                	push   $0x0
  80148d:	ff 75 08             	pushl  0x8(%ebp)
  801490:	e8 e3 01 00 00       	call   801678 <open>
  801495:	89 c3                	mov    %eax,%ebx
  801497:	83 c4 10             	add    $0x10,%esp
  80149a:	85 c0                	test   %eax,%eax
  80149c:	78 1b                	js     8014b9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80149e:	83 ec 08             	sub    $0x8,%esp
  8014a1:	ff 75 0c             	pushl  0xc(%ebp)
  8014a4:	50                   	push   %eax
  8014a5:	e8 5b ff ff ff       	call   801405 <fstat>
  8014aa:	89 c6                	mov    %eax,%esi
	close(fd);
  8014ac:	89 1c 24             	mov    %ebx,(%esp)
  8014af:	e8 fd fb ff ff       	call   8010b1 <close>
	return r;
  8014b4:	83 c4 10             	add    $0x10,%esp
  8014b7:	89 f0                	mov    %esi,%eax
}
  8014b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014bc:	5b                   	pop    %ebx
  8014bd:	5e                   	pop    %esi
  8014be:	5d                   	pop    %ebp
  8014bf:	c3                   	ret    

008014c0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014c0:	55                   	push   %ebp
  8014c1:	89 e5                	mov    %esp,%ebp
  8014c3:	56                   	push   %esi
  8014c4:	53                   	push   %ebx
  8014c5:	89 c6                	mov    %eax,%esi
  8014c7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014c9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014d0:	75 12                	jne    8014e4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014d2:	83 ec 0c             	sub    $0xc,%esp
  8014d5:	6a 01                	push   $0x1
  8014d7:	e8 f6 07 00 00       	call   801cd2 <ipc_find_env>
  8014dc:	a3 00 40 80 00       	mov    %eax,0x804000
  8014e1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014e4:	6a 07                	push   $0x7
  8014e6:	68 00 50 80 00       	push   $0x805000
  8014eb:	56                   	push   %esi
  8014ec:	ff 35 00 40 80 00    	pushl  0x804000
  8014f2:	e8 79 07 00 00       	call   801c70 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014f7:	83 c4 0c             	add    $0xc,%esp
  8014fa:	6a 00                	push   $0x0
  8014fc:	53                   	push   %ebx
  8014fd:	6a 00                	push   $0x0
  8014ff:	e8 f7 06 00 00       	call   801bfb <ipc_recv>
}
  801504:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801507:	5b                   	pop    %ebx
  801508:	5e                   	pop    %esi
  801509:	5d                   	pop    %ebp
  80150a:	c3                   	ret    

0080150b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80150b:	55                   	push   %ebp
  80150c:	89 e5                	mov    %esp,%ebp
  80150e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801511:	8b 45 08             	mov    0x8(%ebp),%eax
  801514:	8b 40 0c             	mov    0xc(%eax),%eax
  801517:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80151c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80151f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801524:	ba 00 00 00 00       	mov    $0x0,%edx
  801529:	b8 02 00 00 00       	mov    $0x2,%eax
  80152e:	e8 8d ff ff ff       	call   8014c0 <fsipc>
}
  801533:	c9                   	leave  
  801534:	c3                   	ret    

00801535 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801535:	55                   	push   %ebp
  801536:	89 e5                	mov    %esp,%ebp
  801538:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80153b:	8b 45 08             	mov    0x8(%ebp),%eax
  80153e:	8b 40 0c             	mov    0xc(%eax),%eax
  801541:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801546:	ba 00 00 00 00       	mov    $0x0,%edx
  80154b:	b8 06 00 00 00       	mov    $0x6,%eax
  801550:	e8 6b ff ff ff       	call   8014c0 <fsipc>
}
  801555:	c9                   	leave  
  801556:	c3                   	ret    

00801557 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801557:	55                   	push   %ebp
  801558:	89 e5                	mov    %esp,%ebp
  80155a:	53                   	push   %ebx
  80155b:	83 ec 04             	sub    $0x4,%esp
  80155e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801561:	8b 45 08             	mov    0x8(%ebp),%eax
  801564:	8b 40 0c             	mov    0xc(%eax),%eax
  801567:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80156c:	ba 00 00 00 00       	mov    $0x0,%edx
  801571:	b8 05 00 00 00       	mov    $0x5,%eax
  801576:	e8 45 ff ff ff       	call   8014c0 <fsipc>
  80157b:	85 c0                	test   %eax,%eax
  80157d:	78 2c                	js     8015ab <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80157f:	83 ec 08             	sub    $0x8,%esp
  801582:	68 00 50 80 00       	push   $0x805000
  801587:	53                   	push   %ebx
  801588:	e8 70 f3 ff ff       	call   8008fd <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80158d:	a1 80 50 80 00       	mov    0x805080,%eax
  801592:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801598:	a1 84 50 80 00       	mov    0x805084,%eax
  80159d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015a3:	83 c4 10             	add    $0x10,%esp
  8015a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ae:	c9                   	leave  
  8015af:	c3                   	ret    

008015b0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015b0:	55                   	push   %ebp
  8015b1:	89 e5                	mov    %esp,%ebp
  8015b3:	83 ec 0c             	sub    $0xc,%esp
  8015b6:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8015b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8015bc:	8b 52 0c             	mov    0xc(%edx),%edx
  8015bf:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8015c5:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8015ca:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8015cf:	0f 47 c2             	cmova  %edx,%eax
  8015d2:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8015d7:	50                   	push   %eax
  8015d8:	ff 75 0c             	pushl  0xc(%ebp)
  8015db:	68 08 50 80 00       	push   $0x805008
  8015e0:	e8 aa f4 ff ff       	call   800a8f <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8015e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ea:	b8 04 00 00 00       	mov    $0x4,%eax
  8015ef:	e8 cc fe ff ff       	call   8014c0 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8015f4:	c9                   	leave  
  8015f5:	c3                   	ret    

008015f6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015f6:	55                   	push   %ebp
  8015f7:	89 e5                	mov    %esp,%ebp
  8015f9:	56                   	push   %esi
  8015fa:	53                   	push   %ebx
  8015fb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801601:	8b 40 0c             	mov    0xc(%eax),%eax
  801604:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801609:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80160f:	ba 00 00 00 00       	mov    $0x0,%edx
  801614:	b8 03 00 00 00       	mov    $0x3,%eax
  801619:	e8 a2 fe ff ff       	call   8014c0 <fsipc>
  80161e:	89 c3                	mov    %eax,%ebx
  801620:	85 c0                	test   %eax,%eax
  801622:	78 4b                	js     80166f <devfile_read+0x79>
		return r;
	assert(r <= n);
  801624:	39 c6                	cmp    %eax,%esi
  801626:	73 16                	jae    80163e <devfile_read+0x48>
  801628:	68 7c 24 80 00       	push   $0x80247c
  80162d:	68 83 24 80 00       	push   $0x802483
  801632:	6a 7c                	push   $0x7c
  801634:	68 98 24 80 00       	push   $0x802498
  801639:	e8 61 ec ff ff       	call   80029f <_panic>
	assert(r <= PGSIZE);
  80163e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801643:	7e 16                	jle    80165b <devfile_read+0x65>
  801645:	68 a3 24 80 00       	push   $0x8024a3
  80164a:	68 83 24 80 00       	push   $0x802483
  80164f:	6a 7d                	push   $0x7d
  801651:	68 98 24 80 00       	push   $0x802498
  801656:	e8 44 ec ff ff       	call   80029f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80165b:	83 ec 04             	sub    $0x4,%esp
  80165e:	50                   	push   %eax
  80165f:	68 00 50 80 00       	push   $0x805000
  801664:	ff 75 0c             	pushl  0xc(%ebp)
  801667:	e8 23 f4 ff ff       	call   800a8f <memmove>
	return r;
  80166c:	83 c4 10             	add    $0x10,%esp
}
  80166f:	89 d8                	mov    %ebx,%eax
  801671:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801674:	5b                   	pop    %ebx
  801675:	5e                   	pop    %esi
  801676:	5d                   	pop    %ebp
  801677:	c3                   	ret    

00801678 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801678:	55                   	push   %ebp
  801679:	89 e5                	mov    %esp,%ebp
  80167b:	53                   	push   %ebx
  80167c:	83 ec 20             	sub    $0x20,%esp
  80167f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801682:	53                   	push   %ebx
  801683:	e8 3c f2 ff ff       	call   8008c4 <strlen>
  801688:	83 c4 10             	add    $0x10,%esp
  80168b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801690:	7f 67                	jg     8016f9 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801692:	83 ec 0c             	sub    $0xc,%esp
  801695:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801698:	50                   	push   %eax
  801699:	e8 9a f8 ff ff       	call   800f38 <fd_alloc>
  80169e:	83 c4 10             	add    $0x10,%esp
		return r;
  8016a1:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016a3:	85 c0                	test   %eax,%eax
  8016a5:	78 57                	js     8016fe <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016a7:	83 ec 08             	sub    $0x8,%esp
  8016aa:	53                   	push   %ebx
  8016ab:	68 00 50 80 00       	push   $0x805000
  8016b0:	e8 48 f2 ff ff       	call   8008fd <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016b8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016c0:	b8 01 00 00 00       	mov    $0x1,%eax
  8016c5:	e8 f6 fd ff ff       	call   8014c0 <fsipc>
  8016ca:	89 c3                	mov    %eax,%ebx
  8016cc:	83 c4 10             	add    $0x10,%esp
  8016cf:	85 c0                	test   %eax,%eax
  8016d1:	79 14                	jns    8016e7 <open+0x6f>
		fd_close(fd, 0);
  8016d3:	83 ec 08             	sub    $0x8,%esp
  8016d6:	6a 00                	push   $0x0
  8016d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8016db:	e8 50 f9 ff ff       	call   801030 <fd_close>
		return r;
  8016e0:	83 c4 10             	add    $0x10,%esp
  8016e3:	89 da                	mov    %ebx,%edx
  8016e5:	eb 17                	jmp    8016fe <open+0x86>
	}

	return fd2num(fd);
  8016e7:	83 ec 0c             	sub    $0xc,%esp
  8016ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8016ed:	e8 1f f8 ff ff       	call   800f11 <fd2num>
  8016f2:	89 c2                	mov    %eax,%edx
  8016f4:	83 c4 10             	add    $0x10,%esp
  8016f7:	eb 05                	jmp    8016fe <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016f9:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016fe:	89 d0                	mov    %edx,%eax
  801700:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801703:	c9                   	leave  
  801704:	c3                   	ret    

00801705 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801705:	55                   	push   %ebp
  801706:	89 e5                	mov    %esp,%ebp
  801708:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80170b:	ba 00 00 00 00       	mov    $0x0,%edx
  801710:	b8 08 00 00 00       	mov    $0x8,%eax
  801715:	e8 a6 fd ff ff       	call   8014c0 <fsipc>
}
  80171a:	c9                   	leave  
  80171b:	c3                   	ret    

0080171c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	56                   	push   %esi
  801720:	53                   	push   %ebx
  801721:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801724:	83 ec 0c             	sub    $0xc,%esp
  801727:	ff 75 08             	pushl  0x8(%ebp)
  80172a:	e8 f2 f7 ff ff       	call   800f21 <fd2data>
  80172f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801731:	83 c4 08             	add    $0x8,%esp
  801734:	68 af 24 80 00       	push   $0x8024af
  801739:	53                   	push   %ebx
  80173a:	e8 be f1 ff ff       	call   8008fd <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80173f:	8b 46 04             	mov    0x4(%esi),%eax
  801742:	2b 06                	sub    (%esi),%eax
  801744:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80174a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801751:	00 00 00 
	stat->st_dev = &devpipe;
  801754:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80175b:	30 80 00 
	return 0;
}
  80175e:	b8 00 00 00 00       	mov    $0x0,%eax
  801763:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801766:	5b                   	pop    %ebx
  801767:	5e                   	pop    %esi
  801768:	5d                   	pop    %ebp
  801769:	c3                   	ret    

0080176a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	53                   	push   %ebx
  80176e:	83 ec 0c             	sub    $0xc,%esp
  801771:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801774:	53                   	push   %ebx
  801775:	6a 00                	push   $0x0
  801777:	e8 09 f6 ff ff       	call   800d85 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80177c:	89 1c 24             	mov    %ebx,(%esp)
  80177f:	e8 9d f7 ff ff       	call   800f21 <fd2data>
  801784:	83 c4 08             	add    $0x8,%esp
  801787:	50                   	push   %eax
  801788:	6a 00                	push   $0x0
  80178a:	e8 f6 f5 ff ff       	call   800d85 <sys_page_unmap>
}
  80178f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801792:	c9                   	leave  
  801793:	c3                   	ret    

00801794 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801794:	55                   	push   %ebp
  801795:	89 e5                	mov    %esp,%ebp
  801797:	57                   	push   %edi
  801798:	56                   	push   %esi
  801799:	53                   	push   %ebx
  80179a:	83 ec 1c             	sub    $0x1c,%esp
  80179d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017a0:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8017a2:	a1 04 40 80 00       	mov    0x804004,%eax
  8017a7:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8017aa:	83 ec 0c             	sub    $0xc,%esp
  8017ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8017b0:	e8 5d 05 00 00       	call   801d12 <pageref>
  8017b5:	89 c3                	mov    %eax,%ebx
  8017b7:	89 3c 24             	mov    %edi,(%esp)
  8017ba:	e8 53 05 00 00       	call   801d12 <pageref>
  8017bf:	83 c4 10             	add    $0x10,%esp
  8017c2:	39 c3                	cmp    %eax,%ebx
  8017c4:	0f 94 c1             	sete   %cl
  8017c7:	0f b6 c9             	movzbl %cl,%ecx
  8017ca:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8017cd:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8017d3:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  8017d6:	39 ce                	cmp    %ecx,%esi
  8017d8:	74 1b                	je     8017f5 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8017da:	39 c3                	cmp    %eax,%ebx
  8017dc:	75 c4                	jne    8017a2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8017de:	8b 42 60             	mov    0x60(%edx),%eax
  8017e1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017e4:	50                   	push   %eax
  8017e5:	56                   	push   %esi
  8017e6:	68 b6 24 80 00       	push   $0x8024b6
  8017eb:	e8 88 eb ff ff       	call   800378 <cprintf>
  8017f0:	83 c4 10             	add    $0x10,%esp
  8017f3:	eb ad                	jmp    8017a2 <_pipeisclosed+0xe>
	}
}
  8017f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017fb:	5b                   	pop    %ebx
  8017fc:	5e                   	pop    %esi
  8017fd:	5f                   	pop    %edi
  8017fe:	5d                   	pop    %ebp
  8017ff:	c3                   	ret    

00801800 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	57                   	push   %edi
  801804:	56                   	push   %esi
  801805:	53                   	push   %ebx
  801806:	83 ec 28             	sub    $0x28,%esp
  801809:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80180c:	56                   	push   %esi
  80180d:	e8 0f f7 ff ff       	call   800f21 <fd2data>
  801812:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801814:	83 c4 10             	add    $0x10,%esp
  801817:	bf 00 00 00 00       	mov    $0x0,%edi
  80181c:	eb 4b                	jmp    801869 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80181e:	89 da                	mov    %ebx,%edx
  801820:	89 f0                	mov    %esi,%eax
  801822:	e8 6d ff ff ff       	call   801794 <_pipeisclosed>
  801827:	85 c0                	test   %eax,%eax
  801829:	75 48                	jne    801873 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80182b:	e8 b1 f4 ff ff       	call   800ce1 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801830:	8b 43 04             	mov    0x4(%ebx),%eax
  801833:	8b 0b                	mov    (%ebx),%ecx
  801835:	8d 51 20             	lea    0x20(%ecx),%edx
  801838:	39 d0                	cmp    %edx,%eax
  80183a:	73 e2                	jae    80181e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80183c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80183f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801843:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801846:	89 c2                	mov    %eax,%edx
  801848:	c1 fa 1f             	sar    $0x1f,%edx
  80184b:	89 d1                	mov    %edx,%ecx
  80184d:	c1 e9 1b             	shr    $0x1b,%ecx
  801850:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801853:	83 e2 1f             	and    $0x1f,%edx
  801856:	29 ca                	sub    %ecx,%edx
  801858:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80185c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801860:	83 c0 01             	add    $0x1,%eax
  801863:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801866:	83 c7 01             	add    $0x1,%edi
  801869:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80186c:	75 c2                	jne    801830 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80186e:	8b 45 10             	mov    0x10(%ebp),%eax
  801871:	eb 05                	jmp    801878 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801873:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801878:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80187b:	5b                   	pop    %ebx
  80187c:	5e                   	pop    %esi
  80187d:	5f                   	pop    %edi
  80187e:	5d                   	pop    %ebp
  80187f:	c3                   	ret    

00801880 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	57                   	push   %edi
  801884:	56                   	push   %esi
  801885:	53                   	push   %ebx
  801886:	83 ec 18             	sub    $0x18,%esp
  801889:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80188c:	57                   	push   %edi
  80188d:	e8 8f f6 ff ff       	call   800f21 <fd2data>
  801892:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801894:	83 c4 10             	add    $0x10,%esp
  801897:	bb 00 00 00 00       	mov    $0x0,%ebx
  80189c:	eb 3d                	jmp    8018db <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80189e:	85 db                	test   %ebx,%ebx
  8018a0:	74 04                	je     8018a6 <devpipe_read+0x26>
				return i;
  8018a2:	89 d8                	mov    %ebx,%eax
  8018a4:	eb 44                	jmp    8018ea <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8018a6:	89 f2                	mov    %esi,%edx
  8018a8:	89 f8                	mov    %edi,%eax
  8018aa:	e8 e5 fe ff ff       	call   801794 <_pipeisclosed>
  8018af:	85 c0                	test   %eax,%eax
  8018b1:	75 32                	jne    8018e5 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8018b3:	e8 29 f4 ff ff       	call   800ce1 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8018b8:	8b 06                	mov    (%esi),%eax
  8018ba:	3b 46 04             	cmp    0x4(%esi),%eax
  8018bd:	74 df                	je     80189e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8018bf:	99                   	cltd   
  8018c0:	c1 ea 1b             	shr    $0x1b,%edx
  8018c3:	01 d0                	add    %edx,%eax
  8018c5:	83 e0 1f             	and    $0x1f,%eax
  8018c8:	29 d0                	sub    %edx,%eax
  8018ca:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8018cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018d2:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8018d5:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018d8:	83 c3 01             	add    $0x1,%ebx
  8018db:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8018de:	75 d8                	jne    8018b8 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8018e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8018e3:	eb 05                	jmp    8018ea <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018e5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8018ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018ed:	5b                   	pop    %ebx
  8018ee:	5e                   	pop    %esi
  8018ef:	5f                   	pop    %edi
  8018f0:	5d                   	pop    %ebp
  8018f1:	c3                   	ret    

008018f2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8018f2:	55                   	push   %ebp
  8018f3:	89 e5                	mov    %esp,%ebp
  8018f5:	56                   	push   %esi
  8018f6:	53                   	push   %ebx
  8018f7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8018fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018fd:	50                   	push   %eax
  8018fe:	e8 35 f6 ff ff       	call   800f38 <fd_alloc>
  801903:	83 c4 10             	add    $0x10,%esp
  801906:	89 c2                	mov    %eax,%edx
  801908:	85 c0                	test   %eax,%eax
  80190a:	0f 88 2c 01 00 00    	js     801a3c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801910:	83 ec 04             	sub    $0x4,%esp
  801913:	68 07 04 00 00       	push   $0x407
  801918:	ff 75 f4             	pushl  -0xc(%ebp)
  80191b:	6a 00                	push   $0x0
  80191d:	e8 de f3 ff ff       	call   800d00 <sys_page_alloc>
  801922:	83 c4 10             	add    $0x10,%esp
  801925:	89 c2                	mov    %eax,%edx
  801927:	85 c0                	test   %eax,%eax
  801929:	0f 88 0d 01 00 00    	js     801a3c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80192f:	83 ec 0c             	sub    $0xc,%esp
  801932:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801935:	50                   	push   %eax
  801936:	e8 fd f5 ff ff       	call   800f38 <fd_alloc>
  80193b:	89 c3                	mov    %eax,%ebx
  80193d:	83 c4 10             	add    $0x10,%esp
  801940:	85 c0                	test   %eax,%eax
  801942:	0f 88 e2 00 00 00    	js     801a2a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801948:	83 ec 04             	sub    $0x4,%esp
  80194b:	68 07 04 00 00       	push   $0x407
  801950:	ff 75 f0             	pushl  -0x10(%ebp)
  801953:	6a 00                	push   $0x0
  801955:	e8 a6 f3 ff ff       	call   800d00 <sys_page_alloc>
  80195a:	89 c3                	mov    %eax,%ebx
  80195c:	83 c4 10             	add    $0x10,%esp
  80195f:	85 c0                	test   %eax,%eax
  801961:	0f 88 c3 00 00 00    	js     801a2a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801967:	83 ec 0c             	sub    $0xc,%esp
  80196a:	ff 75 f4             	pushl  -0xc(%ebp)
  80196d:	e8 af f5 ff ff       	call   800f21 <fd2data>
  801972:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801974:	83 c4 0c             	add    $0xc,%esp
  801977:	68 07 04 00 00       	push   $0x407
  80197c:	50                   	push   %eax
  80197d:	6a 00                	push   $0x0
  80197f:	e8 7c f3 ff ff       	call   800d00 <sys_page_alloc>
  801984:	89 c3                	mov    %eax,%ebx
  801986:	83 c4 10             	add    $0x10,%esp
  801989:	85 c0                	test   %eax,%eax
  80198b:	0f 88 89 00 00 00    	js     801a1a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801991:	83 ec 0c             	sub    $0xc,%esp
  801994:	ff 75 f0             	pushl  -0x10(%ebp)
  801997:	e8 85 f5 ff ff       	call   800f21 <fd2data>
  80199c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8019a3:	50                   	push   %eax
  8019a4:	6a 00                	push   $0x0
  8019a6:	56                   	push   %esi
  8019a7:	6a 00                	push   $0x0
  8019a9:	e8 95 f3 ff ff       	call   800d43 <sys_page_map>
  8019ae:	89 c3                	mov    %eax,%ebx
  8019b0:	83 c4 20             	add    $0x20,%esp
  8019b3:	85 c0                	test   %eax,%eax
  8019b5:	78 55                	js     801a0c <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8019b7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8019c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8019cc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019d5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8019d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019da:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8019e1:	83 ec 0c             	sub    $0xc,%esp
  8019e4:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e7:	e8 25 f5 ff ff       	call   800f11 <fd2num>
  8019ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019ef:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8019f1:	83 c4 04             	add    $0x4,%esp
  8019f4:	ff 75 f0             	pushl  -0x10(%ebp)
  8019f7:	e8 15 f5 ff ff       	call   800f11 <fd2num>
  8019fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019ff:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801a02:	83 c4 10             	add    $0x10,%esp
  801a05:	ba 00 00 00 00       	mov    $0x0,%edx
  801a0a:	eb 30                	jmp    801a3c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801a0c:	83 ec 08             	sub    $0x8,%esp
  801a0f:	56                   	push   %esi
  801a10:	6a 00                	push   $0x0
  801a12:	e8 6e f3 ff ff       	call   800d85 <sys_page_unmap>
  801a17:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801a1a:	83 ec 08             	sub    $0x8,%esp
  801a1d:	ff 75 f0             	pushl  -0x10(%ebp)
  801a20:	6a 00                	push   $0x0
  801a22:	e8 5e f3 ff ff       	call   800d85 <sys_page_unmap>
  801a27:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801a2a:	83 ec 08             	sub    $0x8,%esp
  801a2d:	ff 75 f4             	pushl  -0xc(%ebp)
  801a30:	6a 00                	push   $0x0
  801a32:	e8 4e f3 ff ff       	call   800d85 <sys_page_unmap>
  801a37:	83 c4 10             	add    $0x10,%esp
  801a3a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801a3c:	89 d0                	mov    %edx,%eax
  801a3e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a41:	5b                   	pop    %ebx
  801a42:	5e                   	pop    %esi
  801a43:	5d                   	pop    %ebp
  801a44:	c3                   	ret    

00801a45 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801a45:	55                   	push   %ebp
  801a46:	89 e5                	mov    %esp,%ebp
  801a48:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a4e:	50                   	push   %eax
  801a4f:	ff 75 08             	pushl  0x8(%ebp)
  801a52:	e8 30 f5 ff ff       	call   800f87 <fd_lookup>
  801a57:	83 c4 10             	add    $0x10,%esp
  801a5a:	85 c0                	test   %eax,%eax
  801a5c:	78 18                	js     801a76 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801a5e:	83 ec 0c             	sub    $0xc,%esp
  801a61:	ff 75 f4             	pushl  -0xc(%ebp)
  801a64:	e8 b8 f4 ff ff       	call   800f21 <fd2data>
	return _pipeisclosed(fd, p);
  801a69:	89 c2                	mov    %eax,%edx
  801a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a6e:	e8 21 fd ff ff       	call   801794 <_pipeisclosed>
  801a73:	83 c4 10             	add    $0x10,%esp
}
  801a76:	c9                   	leave  
  801a77:	c3                   	ret    

00801a78 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a78:	55                   	push   %ebp
  801a79:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801a7b:	b8 00 00 00 00       	mov    $0x0,%eax
  801a80:	5d                   	pop    %ebp
  801a81:	c3                   	ret    

00801a82 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a82:	55                   	push   %ebp
  801a83:	89 e5                	mov    %esp,%ebp
  801a85:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a88:	68 ce 24 80 00       	push   $0x8024ce
  801a8d:	ff 75 0c             	pushl  0xc(%ebp)
  801a90:	e8 68 ee ff ff       	call   8008fd <strcpy>
	return 0;
}
  801a95:	b8 00 00 00 00       	mov    $0x0,%eax
  801a9a:	c9                   	leave  
  801a9b:	c3                   	ret    

00801a9c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a9c:	55                   	push   %ebp
  801a9d:	89 e5                	mov    %esp,%ebp
  801a9f:	57                   	push   %edi
  801aa0:	56                   	push   %esi
  801aa1:	53                   	push   %ebx
  801aa2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801aa8:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801aad:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ab3:	eb 2d                	jmp    801ae2 <devcons_write+0x46>
		m = n - tot;
  801ab5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ab8:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801aba:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801abd:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ac2:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ac5:	83 ec 04             	sub    $0x4,%esp
  801ac8:	53                   	push   %ebx
  801ac9:	03 45 0c             	add    0xc(%ebp),%eax
  801acc:	50                   	push   %eax
  801acd:	57                   	push   %edi
  801ace:	e8 bc ef ff ff       	call   800a8f <memmove>
		sys_cputs(buf, m);
  801ad3:	83 c4 08             	add    $0x8,%esp
  801ad6:	53                   	push   %ebx
  801ad7:	57                   	push   %edi
  801ad8:	e8 67 f1 ff ff       	call   800c44 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801add:	01 de                	add    %ebx,%esi
  801adf:	83 c4 10             	add    $0x10,%esp
  801ae2:	89 f0                	mov    %esi,%eax
  801ae4:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ae7:	72 cc                	jb     801ab5 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ae9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aec:	5b                   	pop    %ebx
  801aed:	5e                   	pop    %esi
  801aee:	5f                   	pop    %edi
  801aef:	5d                   	pop    %ebp
  801af0:	c3                   	ret    

00801af1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801af1:	55                   	push   %ebp
  801af2:	89 e5                	mov    %esp,%ebp
  801af4:	83 ec 08             	sub    $0x8,%esp
  801af7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801afc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b00:	74 2a                	je     801b2c <devcons_read+0x3b>
  801b02:	eb 05                	jmp    801b09 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801b04:	e8 d8 f1 ff ff       	call   800ce1 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801b09:	e8 54 f1 ff ff       	call   800c62 <sys_cgetc>
  801b0e:	85 c0                	test   %eax,%eax
  801b10:	74 f2                	je     801b04 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801b12:	85 c0                	test   %eax,%eax
  801b14:	78 16                	js     801b2c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b16:	83 f8 04             	cmp    $0x4,%eax
  801b19:	74 0c                	je     801b27 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801b1b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b1e:	88 02                	mov    %al,(%edx)
	return 1;
  801b20:	b8 01 00 00 00       	mov    $0x1,%eax
  801b25:	eb 05                	jmp    801b2c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b27:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801b2c:	c9                   	leave  
  801b2d:	c3                   	ret    

00801b2e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b2e:	55                   	push   %ebp
  801b2f:	89 e5                	mov    %esp,%ebp
  801b31:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b34:	8b 45 08             	mov    0x8(%ebp),%eax
  801b37:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b3a:	6a 01                	push   $0x1
  801b3c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b3f:	50                   	push   %eax
  801b40:	e8 ff f0 ff ff       	call   800c44 <sys_cputs>
}
  801b45:	83 c4 10             	add    $0x10,%esp
  801b48:	c9                   	leave  
  801b49:	c3                   	ret    

00801b4a <getchar>:

int
getchar(void)
{
  801b4a:	55                   	push   %ebp
  801b4b:	89 e5                	mov    %esp,%ebp
  801b4d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801b50:	6a 01                	push   $0x1
  801b52:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b55:	50                   	push   %eax
  801b56:	6a 00                	push   $0x0
  801b58:	e8 90 f6 ff ff       	call   8011ed <read>
	if (r < 0)
  801b5d:	83 c4 10             	add    $0x10,%esp
  801b60:	85 c0                	test   %eax,%eax
  801b62:	78 0f                	js     801b73 <getchar+0x29>
		return r;
	if (r < 1)
  801b64:	85 c0                	test   %eax,%eax
  801b66:	7e 06                	jle    801b6e <getchar+0x24>
		return -E_EOF;
	return c;
  801b68:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b6c:	eb 05                	jmp    801b73 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801b6e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b73:	c9                   	leave  
  801b74:	c3                   	ret    

00801b75 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b75:	55                   	push   %ebp
  801b76:	89 e5                	mov    %esp,%ebp
  801b78:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b7e:	50                   	push   %eax
  801b7f:	ff 75 08             	pushl  0x8(%ebp)
  801b82:	e8 00 f4 ff ff       	call   800f87 <fd_lookup>
  801b87:	83 c4 10             	add    $0x10,%esp
  801b8a:	85 c0                	test   %eax,%eax
  801b8c:	78 11                	js     801b9f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b91:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b97:	39 10                	cmp    %edx,(%eax)
  801b99:	0f 94 c0             	sete   %al
  801b9c:	0f b6 c0             	movzbl %al,%eax
}
  801b9f:	c9                   	leave  
  801ba0:	c3                   	ret    

00801ba1 <opencons>:

int
opencons(void)
{
  801ba1:	55                   	push   %ebp
  801ba2:	89 e5                	mov    %esp,%ebp
  801ba4:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ba7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801baa:	50                   	push   %eax
  801bab:	e8 88 f3 ff ff       	call   800f38 <fd_alloc>
  801bb0:	83 c4 10             	add    $0x10,%esp
		return r;
  801bb3:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801bb5:	85 c0                	test   %eax,%eax
  801bb7:	78 3e                	js     801bf7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801bb9:	83 ec 04             	sub    $0x4,%esp
  801bbc:	68 07 04 00 00       	push   $0x407
  801bc1:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc4:	6a 00                	push   $0x0
  801bc6:	e8 35 f1 ff ff       	call   800d00 <sys_page_alloc>
  801bcb:	83 c4 10             	add    $0x10,%esp
		return r;
  801bce:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801bd0:	85 c0                	test   %eax,%eax
  801bd2:	78 23                	js     801bf7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801bd4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bdd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801be9:	83 ec 0c             	sub    $0xc,%esp
  801bec:	50                   	push   %eax
  801bed:	e8 1f f3 ff ff       	call   800f11 <fd2num>
  801bf2:	89 c2                	mov    %eax,%edx
  801bf4:	83 c4 10             	add    $0x10,%esp
}
  801bf7:	89 d0                	mov    %edx,%eax
  801bf9:	c9                   	leave  
  801bfa:	c3                   	ret    

00801bfb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801bfb:	55                   	push   %ebp
  801bfc:	89 e5                	mov    %esp,%ebp
  801bfe:	56                   	push   %esi
  801bff:	53                   	push   %ebx
  801c00:	8b 75 08             	mov    0x8(%ebp),%esi
  801c03:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c06:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801c09:	85 c0                	test   %eax,%eax
  801c0b:	75 12                	jne    801c1f <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801c0d:	83 ec 0c             	sub    $0xc,%esp
  801c10:	68 00 00 c0 ee       	push   $0xeec00000
  801c15:	e8 96 f2 ff ff       	call   800eb0 <sys_ipc_recv>
  801c1a:	83 c4 10             	add    $0x10,%esp
  801c1d:	eb 0c                	jmp    801c2b <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801c1f:	83 ec 0c             	sub    $0xc,%esp
  801c22:	50                   	push   %eax
  801c23:	e8 88 f2 ff ff       	call   800eb0 <sys_ipc_recv>
  801c28:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801c2b:	85 f6                	test   %esi,%esi
  801c2d:	0f 95 c1             	setne  %cl
  801c30:	85 db                	test   %ebx,%ebx
  801c32:	0f 95 c2             	setne  %dl
  801c35:	84 d1                	test   %dl,%cl
  801c37:	74 09                	je     801c42 <ipc_recv+0x47>
  801c39:	89 c2                	mov    %eax,%edx
  801c3b:	c1 ea 1f             	shr    $0x1f,%edx
  801c3e:	84 d2                	test   %dl,%dl
  801c40:	75 27                	jne    801c69 <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801c42:	85 f6                	test   %esi,%esi
  801c44:	74 0a                	je     801c50 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801c46:	a1 04 40 80 00       	mov    0x804004,%eax
  801c4b:	8b 40 7c             	mov    0x7c(%eax),%eax
  801c4e:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801c50:	85 db                	test   %ebx,%ebx
  801c52:	74 0d                	je     801c61 <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  801c54:	a1 04 40 80 00       	mov    0x804004,%eax
  801c59:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801c5f:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801c61:	a1 04 40 80 00       	mov    0x804004,%eax
  801c66:	8b 40 78             	mov    0x78(%eax),%eax
}
  801c69:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c6c:	5b                   	pop    %ebx
  801c6d:	5e                   	pop    %esi
  801c6e:	5d                   	pop    %ebp
  801c6f:	c3                   	ret    

00801c70 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c70:	55                   	push   %ebp
  801c71:	89 e5                	mov    %esp,%ebp
  801c73:	57                   	push   %edi
  801c74:	56                   	push   %esi
  801c75:	53                   	push   %ebx
  801c76:	83 ec 0c             	sub    $0xc,%esp
  801c79:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c7c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801c82:	85 db                	test   %ebx,%ebx
  801c84:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801c89:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801c8c:	ff 75 14             	pushl  0x14(%ebp)
  801c8f:	53                   	push   %ebx
  801c90:	56                   	push   %esi
  801c91:	57                   	push   %edi
  801c92:	e8 f6 f1 ff ff       	call   800e8d <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801c97:	89 c2                	mov    %eax,%edx
  801c99:	c1 ea 1f             	shr    $0x1f,%edx
  801c9c:	83 c4 10             	add    $0x10,%esp
  801c9f:	84 d2                	test   %dl,%dl
  801ca1:	74 17                	je     801cba <ipc_send+0x4a>
  801ca3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ca6:	74 12                	je     801cba <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801ca8:	50                   	push   %eax
  801ca9:	68 da 24 80 00       	push   $0x8024da
  801cae:	6a 47                	push   $0x47
  801cb0:	68 e8 24 80 00       	push   $0x8024e8
  801cb5:	e8 e5 e5 ff ff       	call   80029f <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801cba:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801cbd:	75 07                	jne    801cc6 <ipc_send+0x56>
			sys_yield();
  801cbf:	e8 1d f0 ff ff       	call   800ce1 <sys_yield>
  801cc4:	eb c6                	jmp    801c8c <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801cc6:	85 c0                	test   %eax,%eax
  801cc8:	75 c2                	jne    801c8c <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801cca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ccd:	5b                   	pop    %ebx
  801cce:	5e                   	pop    %esi
  801ccf:	5f                   	pop    %edi
  801cd0:	5d                   	pop    %ebp
  801cd1:	c3                   	ret    

00801cd2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801cd2:	55                   	push   %ebp
  801cd3:	89 e5                	mov    %esp,%ebp
  801cd5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801cd8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801cdd:	89 c2                	mov    %eax,%edx
  801cdf:	c1 e2 07             	shl    $0x7,%edx
  801ce2:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801ce9:	8b 52 58             	mov    0x58(%edx),%edx
  801cec:	39 ca                	cmp    %ecx,%edx
  801cee:	75 11                	jne    801d01 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801cf0:	89 c2                	mov    %eax,%edx
  801cf2:	c1 e2 07             	shl    $0x7,%edx
  801cf5:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801cfc:	8b 40 50             	mov    0x50(%eax),%eax
  801cff:	eb 0f                	jmp    801d10 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d01:	83 c0 01             	add    $0x1,%eax
  801d04:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d09:	75 d2                	jne    801cdd <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d10:	5d                   	pop    %ebp
  801d11:	c3                   	ret    

00801d12 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d12:	55                   	push   %ebp
  801d13:	89 e5                	mov    %esp,%ebp
  801d15:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d18:	89 d0                	mov    %edx,%eax
  801d1a:	c1 e8 16             	shr    $0x16,%eax
  801d1d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801d24:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d29:	f6 c1 01             	test   $0x1,%cl
  801d2c:	74 1d                	je     801d4b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d2e:	c1 ea 0c             	shr    $0xc,%edx
  801d31:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801d38:	f6 c2 01             	test   $0x1,%dl
  801d3b:	74 0e                	je     801d4b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d3d:	c1 ea 0c             	shr    $0xc,%edx
  801d40:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d47:	ef 
  801d48:	0f b7 c0             	movzwl %ax,%eax
}
  801d4b:	5d                   	pop    %ebp
  801d4c:	c3                   	ret    
  801d4d:	66 90                	xchg   %ax,%ax
  801d4f:	90                   	nop

00801d50 <__udivdi3>:
  801d50:	55                   	push   %ebp
  801d51:	57                   	push   %edi
  801d52:	56                   	push   %esi
  801d53:	53                   	push   %ebx
  801d54:	83 ec 1c             	sub    $0x1c,%esp
  801d57:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801d5b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801d5f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801d63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d67:	85 f6                	test   %esi,%esi
  801d69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d6d:	89 ca                	mov    %ecx,%edx
  801d6f:	89 f8                	mov    %edi,%eax
  801d71:	75 3d                	jne    801db0 <__udivdi3+0x60>
  801d73:	39 cf                	cmp    %ecx,%edi
  801d75:	0f 87 c5 00 00 00    	ja     801e40 <__udivdi3+0xf0>
  801d7b:	85 ff                	test   %edi,%edi
  801d7d:	89 fd                	mov    %edi,%ebp
  801d7f:	75 0b                	jne    801d8c <__udivdi3+0x3c>
  801d81:	b8 01 00 00 00       	mov    $0x1,%eax
  801d86:	31 d2                	xor    %edx,%edx
  801d88:	f7 f7                	div    %edi
  801d8a:	89 c5                	mov    %eax,%ebp
  801d8c:	89 c8                	mov    %ecx,%eax
  801d8e:	31 d2                	xor    %edx,%edx
  801d90:	f7 f5                	div    %ebp
  801d92:	89 c1                	mov    %eax,%ecx
  801d94:	89 d8                	mov    %ebx,%eax
  801d96:	89 cf                	mov    %ecx,%edi
  801d98:	f7 f5                	div    %ebp
  801d9a:	89 c3                	mov    %eax,%ebx
  801d9c:	89 d8                	mov    %ebx,%eax
  801d9e:	89 fa                	mov    %edi,%edx
  801da0:	83 c4 1c             	add    $0x1c,%esp
  801da3:	5b                   	pop    %ebx
  801da4:	5e                   	pop    %esi
  801da5:	5f                   	pop    %edi
  801da6:	5d                   	pop    %ebp
  801da7:	c3                   	ret    
  801da8:	90                   	nop
  801da9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801db0:	39 ce                	cmp    %ecx,%esi
  801db2:	77 74                	ja     801e28 <__udivdi3+0xd8>
  801db4:	0f bd fe             	bsr    %esi,%edi
  801db7:	83 f7 1f             	xor    $0x1f,%edi
  801dba:	0f 84 98 00 00 00    	je     801e58 <__udivdi3+0x108>
  801dc0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801dc5:	89 f9                	mov    %edi,%ecx
  801dc7:	89 c5                	mov    %eax,%ebp
  801dc9:	29 fb                	sub    %edi,%ebx
  801dcb:	d3 e6                	shl    %cl,%esi
  801dcd:	89 d9                	mov    %ebx,%ecx
  801dcf:	d3 ed                	shr    %cl,%ebp
  801dd1:	89 f9                	mov    %edi,%ecx
  801dd3:	d3 e0                	shl    %cl,%eax
  801dd5:	09 ee                	or     %ebp,%esi
  801dd7:	89 d9                	mov    %ebx,%ecx
  801dd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ddd:	89 d5                	mov    %edx,%ebp
  801ddf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801de3:	d3 ed                	shr    %cl,%ebp
  801de5:	89 f9                	mov    %edi,%ecx
  801de7:	d3 e2                	shl    %cl,%edx
  801de9:	89 d9                	mov    %ebx,%ecx
  801deb:	d3 e8                	shr    %cl,%eax
  801ded:	09 c2                	or     %eax,%edx
  801def:	89 d0                	mov    %edx,%eax
  801df1:	89 ea                	mov    %ebp,%edx
  801df3:	f7 f6                	div    %esi
  801df5:	89 d5                	mov    %edx,%ebp
  801df7:	89 c3                	mov    %eax,%ebx
  801df9:	f7 64 24 0c          	mull   0xc(%esp)
  801dfd:	39 d5                	cmp    %edx,%ebp
  801dff:	72 10                	jb     801e11 <__udivdi3+0xc1>
  801e01:	8b 74 24 08          	mov    0x8(%esp),%esi
  801e05:	89 f9                	mov    %edi,%ecx
  801e07:	d3 e6                	shl    %cl,%esi
  801e09:	39 c6                	cmp    %eax,%esi
  801e0b:	73 07                	jae    801e14 <__udivdi3+0xc4>
  801e0d:	39 d5                	cmp    %edx,%ebp
  801e0f:	75 03                	jne    801e14 <__udivdi3+0xc4>
  801e11:	83 eb 01             	sub    $0x1,%ebx
  801e14:	31 ff                	xor    %edi,%edi
  801e16:	89 d8                	mov    %ebx,%eax
  801e18:	89 fa                	mov    %edi,%edx
  801e1a:	83 c4 1c             	add    $0x1c,%esp
  801e1d:	5b                   	pop    %ebx
  801e1e:	5e                   	pop    %esi
  801e1f:	5f                   	pop    %edi
  801e20:	5d                   	pop    %ebp
  801e21:	c3                   	ret    
  801e22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e28:	31 ff                	xor    %edi,%edi
  801e2a:	31 db                	xor    %ebx,%ebx
  801e2c:	89 d8                	mov    %ebx,%eax
  801e2e:	89 fa                	mov    %edi,%edx
  801e30:	83 c4 1c             	add    $0x1c,%esp
  801e33:	5b                   	pop    %ebx
  801e34:	5e                   	pop    %esi
  801e35:	5f                   	pop    %edi
  801e36:	5d                   	pop    %ebp
  801e37:	c3                   	ret    
  801e38:	90                   	nop
  801e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e40:	89 d8                	mov    %ebx,%eax
  801e42:	f7 f7                	div    %edi
  801e44:	31 ff                	xor    %edi,%edi
  801e46:	89 c3                	mov    %eax,%ebx
  801e48:	89 d8                	mov    %ebx,%eax
  801e4a:	89 fa                	mov    %edi,%edx
  801e4c:	83 c4 1c             	add    $0x1c,%esp
  801e4f:	5b                   	pop    %ebx
  801e50:	5e                   	pop    %esi
  801e51:	5f                   	pop    %edi
  801e52:	5d                   	pop    %ebp
  801e53:	c3                   	ret    
  801e54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e58:	39 ce                	cmp    %ecx,%esi
  801e5a:	72 0c                	jb     801e68 <__udivdi3+0x118>
  801e5c:	31 db                	xor    %ebx,%ebx
  801e5e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801e62:	0f 87 34 ff ff ff    	ja     801d9c <__udivdi3+0x4c>
  801e68:	bb 01 00 00 00       	mov    $0x1,%ebx
  801e6d:	e9 2a ff ff ff       	jmp    801d9c <__udivdi3+0x4c>
  801e72:	66 90                	xchg   %ax,%ax
  801e74:	66 90                	xchg   %ax,%ax
  801e76:	66 90                	xchg   %ax,%ax
  801e78:	66 90                	xchg   %ax,%ax
  801e7a:	66 90                	xchg   %ax,%ax
  801e7c:	66 90                	xchg   %ax,%ax
  801e7e:	66 90                	xchg   %ax,%ax

00801e80 <__umoddi3>:
  801e80:	55                   	push   %ebp
  801e81:	57                   	push   %edi
  801e82:	56                   	push   %esi
  801e83:	53                   	push   %ebx
  801e84:	83 ec 1c             	sub    $0x1c,%esp
  801e87:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801e8b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801e8f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801e93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e97:	85 d2                	test   %edx,%edx
  801e99:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ea1:	89 f3                	mov    %esi,%ebx
  801ea3:	89 3c 24             	mov    %edi,(%esp)
  801ea6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801eaa:	75 1c                	jne    801ec8 <__umoddi3+0x48>
  801eac:	39 f7                	cmp    %esi,%edi
  801eae:	76 50                	jbe    801f00 <__umoddi3+0x80>
  801eb0:	89 c8                	mov    %ecx,%eax
  801eb2:	89 f2                	mov    %esi,%edx
  801eb4:	f7 f7                	div    %edi
  801eb6:	89 d0                	mov    %edx,%eax
  801eb8:	31 d2                	xor    %edx,%edx
  801eba:	83 c4 1c             	add    $0x1c,%esp
  801ebd:	5b                   	pop    %ebx
  801ebe:	5e                   	pop    %esi
  801ebf:	5f                   	pop    %edi
  801ec0:	5d                   	pop    %ebp
  801ec1:	c3                   	ret    
  801ec2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ec8:	39 f2                	cmp    %esi,%edx
  801eca:	89 d0                	mov    %edx,%eax
  801ecc:	77 52                	ja     801f20 <__umoddi3+0xa0>
  801ece:	0f bd ea             	bsr    %edx,%ebp
  801ed1:	83 f5 1f             	xor    $0x1f,%ebp
  801ed4:	75 5a                	jne    801f30 <__umoddi3+0xb0>
  801ed6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801eda:	0f 82 e0 00 00 00    	jb     801fc0 <__umoddi3+0x140>
  801ee0:	39 0c 24             	cmp    %ecx,(%esp)
  801ee3:	0f 86 d7 00 00 00    	jbe    801fc0 <__umoddi3+0x140>
  801ee9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801eed:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ef1:	83 c4 1c             	add    $0x1c,%esp
  801ef4:	5b                   	pop    %ebx
  801ef5:	5e                   	pop    %esi
  801ef6:	5f                   	pop    %edi
  801ef7:	5d                   	pop    %ebp
  801ef8:	c3                   	ret    
  801ef9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f00:	85 ff                	test   %edi,%edi
  801f02:	89 fd                	mov    %edi,%ebp
  801f04:	75 0b                	jne    801f11 <__umoddi3+0x91>
  801f06:	b8 01 00 00 00       	mov    $0x1,%eax
  801f0b:	31 d2                	xor    %edx,%edx
  801f0d:	f7 f7                	div    %edi
  801f0f:	89 c5                	mov    %eax,%ebp
  801f11:	89 f0                	mov    %esi,%eax
  801f13:	31 d2                	xor    %edx,%edx
  801f15:	f7 f5                	div    %ebp
  801f17:	89 c8                	mov    %ecx,%eax
  801f19:	f7 f5                	div    %ebp
  801f1b:	89 d0                	mov    %edx,%eax
  801f1d:	eb 99                	jmp    801eb8 <__umoddi3+0x38>
  801f1f:	90                   	nop
  801f20:	89 c8                	mov    %ecx,%eax
  801f22:	89 f2                	mov    %esi,%edx
  801f24:	83 c4 1c             	add    $0x1c,%esp
  801f27:	5b                   	pop    %ebx
  801f28:	5e                   	pop    %esi
  801f29:	5f                   	pop    %edi
  801f2a:	5d                   	pop    %ebp
  801f2b:	c3                   	ret    
  801f2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f30:	8b 34 24             	mov    (%esp),%esi
  801f33:	bf 20 00 00 00       	mov    $0x20,%edi
  801f38:	89 e9                	mov    %ebp,%ecx
  801f3a:	29 ef                	sub    %ebp,%edi
  801f3c:	d3 e0                	shl    %cl,%eax
  801f3e:	89 f9                	mov    %edi,%ecx
  801f40:	89 f2                	mov    %esi,%edx
  801f42:	d3 ea                	shr    %cl,%edx
  801f44:	89 e9                	mov    %ebp,%ecx
  801f46:	09 c2                	or     %eax,%edx
  801f48:	89 d8                	mov    %ebx,%eax
  801f4a:	89 14 24             	mov    %edx,(%esp)
  801f4d:	89 f2                	mov    %esi,%edx
  801f4f:	d3 e2                	shl    %cl,%edx
  801f51:	89 f9                	mov    %edi,%ecx
  801f53:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f57:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801f5b:	d3 e8                	shr    %cl,%eax
  801f5d:	89 e9                	mov    %ebp,%ecx
  801f5f:	89 c6                	mov    %eax,%esi
  801f61:	d3 e3                	shl    %cl,%ebx
  801f63:	89 f9                	mov    %edi,%ecx
  801f65:	89 d0                	mov    %edx,%eax
  801f67:	d3 e8                	shr    %cl,%eax
  801f69:	89 e9                	mov    %ebp,%ecx
  801f6b:	09 d8                	or     %ebx,%eax
  801f6d:	89 d3                	mov    %edx,%ebx
  801f6f:	89 f2                	mov    %esi,%edx
  801f71:	f7 34 24             	divl   (%esp)
  801f74:	89 d6                	mov    %edx,%esi
  801f76:	d3 e3                	shl    %cl,%ebx
  801f78:	f7 64 24 04          	mull   0x4(%esp)
  801f7c:	39 d6                	cmp    %edx,%esi
  801f7e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f82:	89 d1                	mov    %edx,%ecx
  801f84:	89 c3                	mov    %eax,%ebx
  801f86:	72 08                	jb     801f90 <__umoddi3+0x110>
  801f88:	75 11                	jne    801f9b <__umoddi3+0x11b>
  801f8a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801f8e:	73 0b                	jae    801f9b <__umoddi3+0x11b>
  801f90:	2b 44 24 04          	sub    0x4(%esp),%eax
  801f94:	1b 14 24             	sbb    (%esp),%edx
  801f97:	89 d1                	mov    %edx,%ecx
  801f99:	89 c3                	mov    %eax,%ebx
  801f9b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801f9f:	29 da                	sub    %ebx,%edx
  801fa1:	19 ce                	sbb    %ecx,%esi
  801fa3:	89 f9                	mov    %edi,%ecx
  801fa5:	89 f0                	mov    %esi,%eax
  801fa7:	d3 e0                	shl    %cl,%eax
  801fa9:	89 e9                	mov    %ebp,%ecx
  801fab:	d3 ea                	shr    %cl,%edx
  801fad:	89 e9                	mov    %ebp,%ecx
  801faf:	d3 ee                	shr    %cl,%esi
  801fb1:	09 d0                	or     %edx,%eax
  801fb3:	89 f2                	mov    %esi,%edx
  801fb5:	83 c4 1c             	add    $0x1c,%esp
  801fb8:	5b                   	pop    %ebx
  801fb9:	5e                   	pop    %esi
  801fba:	5f                   	pop    %edi
  801fbb:	5d                   	pop    %ebp
  801fbc:	c3                   	ret    
  801fbd:	8d 76 00             	lea    0x0(%esi),%esi
  801fc0:	29 f9                	sub    %edi,%ecx
  801fc2:	19 d6                	sbb    %edx,%esi
  801fc4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fc8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fcc:	e9 18 ff ff ff       	jmp    801ee9 <__umoddi3+0x69>
