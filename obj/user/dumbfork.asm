
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
  80002c:	e8 aa 01 00 00       	call   8001db <libmain>
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
  800045:	e8 9a 0c 00 00       	call   800ce4 <sys_page_alloc>
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800051:	50                   	push   %eax
  800052:	68 a0 1f 80 00       	push   $0x801fa0
  800057:	6a 20                	push   $0x20
  800059:	68 b3 1f 80 00       	push   $0x801fb3
  80005e:	e8 20 02 00 00       	call   800283 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800063:	83 ec 0c             	sub    $0xc,%esp
  800066:	6a 07                	push   $0x7
  800068:	68 00 00 40 00       	push   $0x400000
  80006d:	6a 00                	push   $0x0
  80006f:	53                   	push   %ebx
  800070:	56                   	push   %esi
  800071:	e8 b1 0c 00 00       	call   800d27 <sys_page_map>
  800076:	83 c4 20             	add    $0x20,%esp
  800079:	85 c0                	test   %eax,%eax
  80007b:	79 12                	jns    80008f <duppage+0x5c>
		panic("sys_page_map: %e", r);
  80007d:	50                   	push   %eax
  80007e:	68 c3 1f 80 00       	push   $0x801fc3
  800083:	6a 22                	push   $0x22
  800085:	68 b3 1f 80 00       	push   $0x801fb3
  80008a:	e8 f4 01 00 00       	call   800283 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  80008f:	83 ec 04             	sub    $0x4,%esp
  800092:	68 00 10 00 00       	push   $0x1000
  800097:	53                   	push   %ebx
  800098:	68 00 00 40 00       	push   $0x400000
  80009d:	e8 d1 09 00 00       	call   800a73 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	68 00 00 40 00       	push   $0x400000
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 b8 0c 00 00       	call   800d69 <sys_page_unmap>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	79 12                	jns    8000ca <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  8000b8:	50                   	push   %eax
  8000b9:	68 d4 1f 80 00       	push   $0x801fd4
  8000be:	6a 25                	push   $0x25
  8000c0:	68 b3 1f 80 00       	push   $0x801fb3
  8000c5:	e8 b9 01 00 00       	call   800283 <_panic>
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
  8000e7:	68 e7 1f 80 00       	push   $0x801fe7
  8000ec:	6a 37                	push   $0x37
  8000ee:	68 b3 1f 80 00       	push   $0x801fb3
  8000f3:	e8 8b 01 00 00       	call   800283 <_panic>
  8000f8:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	75 1e                	jne    80011c <dumbfork+0x4b>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8000fe:	e8 a3 0b 00 00       	call   800ca6 <sys_getenvid>
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
  800108:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800110:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800115:	b8 00 00 00 00       	mov    $0x0,%eax
  80011a:	eb 60                	jmp    80017c <dumbfork+0xab>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80011c:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800123:	eb 14                	jmp    800139 <dumbfork+0x68>
		duppage(envid, addr);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	52                   	push   %edx
  800129:	56                   	push   %esi
  80012a:	e8 04 ff ff ff       	call   800033 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80012f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80013c:	81 fa 00 60 80 00    	cmp    $0x806000,%edx
  800142:	72 e1                	jb     800125 <dumbfork+0x54>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800144:	83 ec 08             	sub    $0x8,%esp
  800147:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80014a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80014f:	50                   	push   %eax
  800150:	53                   	push   %ebx
  800151:	e8 dd fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800156:	83 c4 08             	add    $0x8,%esp
  800159:	6a 02                	push   $0x2
  80015b:	53                   	push   %ebx
  80015c:	e8 4a 0c 00 00       	call   800dab <sys_env_set_status>
  800161:	83 c4 10             	add    $0x10,%esp
  800164:	85 c0                	test   %eax,%eax
  800166:	79 12                	jns    80017a <dumbfork+0xa9>
		panic("sys_env_set_status: %e", r);
  800168:	50                   	push   %eax
  800169:	68 f7 1f 80 00       	push   $0x801ff7
  80016e:	6a 4c                	push   $0x4c
  800170:	68 b3 1f 80 00       	push   $0x801fb3
  800175:	e8 09 01 00 00       	call   800283 <_panic>

	return envid;
  80017a:	89 d8                	mov    %ebx,%eax
}
  80017c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80017f:	5b                   	pop    %ebx
  800180:	5e                   	pop    %esi
  800181:	5d                   	pop    %ebp
  800182:	c3                   	ret    

00800183 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	57                   	push   %edi
  800187:	56                   	push   %esi
  800188:	53                   	push   %ebx
  800189:	83 ec 0c             	sub    $0xc,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  80018c:	e8 40 ff ff ff       	call   8000d1 <dumbfork>
  800191:	89 c7                	mov    %eax,%edi
  800193:	85 c0                	test   %eax,%eax
  800195:	be 15 20 80 00       	mov    $0x802015,%esi
  80019a:	b8 0e 20 80 00       	mov    $0x80200e,%eax
  80019f:	0f 45 f0             	cmovne %eax,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a7:	eb 1a                	jmp    8001c3 <umain+0x40>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001a9:	83 ec 04             	sub    $0x4,%esp
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	68 1b 20 80 00       	push   $0x80201b
  8001b3:	e8 a4 01 00 00       	call   80035c <cprintf>
		sys_yield();
  8001b8:	e8 08 0b 00 00       	call   800cc5 <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001bd:	83 c3 01             	add    $0x1,%ebx
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 ff                	test   %edi,%edi
  8001c5:	74 07                	je     8001ce <umain+0x4b>
  8001c7:	83 fb 09             	cmp    $0x9,%ebx
  8001ca:	7e dd                	jle    8001a9 <umain+0x26>
  8001cc:	eb 05                	jmp    8001d3 <umain+0x50>
  8001ce:	83 fb 13             	cmp    $0x13,%ebx
  8001d1:	7e d6                	jle    8001a9 <umain+0x26>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  8001d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	57                   	push   %edi
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8001e4:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  8001eb:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  8001ee:	e8 b3 0a 00 00       	call   800ca6 <sys_getenvid>
  8001f3:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  8001f9:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8001fe:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800203:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  800208:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  80020b:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  800211:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  800214:	39 c8                	cmp    %ecx,%eax
  800216:	0f 44 fb             	cmove  %ebx,%edi
  800219:	b9 01 00 00 00       	mov    $0x1,%ecx
  80021e:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  800221:	83 c2 01             	add    $0x1,%edx
  800224:	83 c3 7c             	add    $0x7c,%ebx
  800227:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  80022d:	75 d9                	jne    800208 <libmain+0x2d>
  80022f:	89 f0                	mov    %esi,%eax
  800231:	84 c0                	test   %al,%al
  800233:	74 06                	je     80023b <libmain+0x60>
  800235:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80023b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80023f:	7e 0a                	jle    80024b <libmain+0x70>
		binaryname = argv[0];
  800241:	8b 45 0c             	mov    0xc(%ebp),%eax
  800244:	8b 00                	mov    (%eax),%eax
  800246:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80024b:	83 ec 08             	sub    $0x8,%esp
  80024e:	ff 75 0c             	pushl  0xc(%ebp)
  800251:	ff 75 08             	pushl  0x8(%ebp)
  800254:	e8 2a ff ff ff       	call   800183 <umain>

	// exit gracefully
	exit();
  800259:	e8 0b 00 00 00       	call   800269 <exit>
}
  80025e:	83 c4 10             	add    $0x10,%esp
  800261:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800264:	5b                   	pop    %ebx
  800265:	5e                   	pop    %esi
  800266:	5f                   	pop    %edi
  800267:	5d                   	pop    %ebp
  800268:	c3                   	ret    

00800269 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800269:	55                   	push   %ebp
  80026a:	89 e5                	mov    %esp,%ebp
  80026c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80026f:	e8 2c 0e 00 00       	call   8010a0 <close_all>
	sys_env_destroy(0);
  800274:	83 ec 0c             	sub    $0xc,%esp
  800277:	6a 00                	push   $0x0
  800279:	e8 e7 09 00 00       	call   800c65 <sys_env_destroy>
}
  80027e:	83 c4 10             	add    $0x10,%esp
  800281:	c9                   	leave  
  800282:	c3                   	ret    

00800283 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800283:	55                   	push   %ebp
  800284:	89 e5                	mov    %esp,%ebp
  800286:	56                   	push   %esi
  800287:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800288:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80028b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800291:	e8 10 0a 00 00       	call   800ca6 <sys_getenvid>
  800296:	83 ec 0c             	sub    $0xc,%esp
  800299:	ff 75 0c             	pushl  0xc(%ebp)
  80029c:	ff 75 08             	pushl  0x8(%ebp)
  80029f:	56                   	push   %esi
  8002a0:	50                   	push   %eax
  8002a1:	68 38 20 80 00       	push   $0x802038
  8002a6:	e8 b1 00 00 00       	call   80035c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002ab:	83 c4 18             	add    $0x18,%esp
  8002ae:	53                   	push   %ebx
  8002af:	ff 75 10             	pushl  0x10(%ebp)
  8002b2:	e8 54 00 00 00       	call   80030b <vcprintf>
	cprintf("\n");
  8002b7:	c7 04 24 2b 20 80 00 	movl   $0x80202b,(%esp)
  8002be:	e8 99 00 00 00       	call   80035c <cprintf>
  8002c3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002c6:	cc                   	int3   
  8002c7:	eb fd                	jmp    8002c6 <_panic+0x43>

008002c9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	53                   	push   %ebx
  8002cd:	83 ec 04             	sub    $0x4,%esp
  8002d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002d3:	8b 13                	mov    (%ebx),%edx
  8002d5:	8d 42 01             	lea    0x1(%edx),%eax
  8002d8:	89 03                	mov    %eax,(%ebx)
  8002da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002dd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002e1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002e6:	75 1a                	jne    800302 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002e8:	83 ec 08             	sub    $0x8,%esp
  8002eb:	68 ff 00 00 00       	push   $0xff
  8002f0:	8d 43 08             	lea    0x8(%ebx),%eax
  8002f3:	50                   	push   %eax
  8002f4:	e8 2f 09 00 00       	call   800c28 <sys_cputs>
		b->idx = 0;
  8002f9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002ff:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800302:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800306:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800309:	c9                   	leave  
  80030a:	c3                   	ret    

0080030b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800314:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80031b:	00 00 00 
	b.cnt = 0;
  80031e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800325:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800328:	ff 75 0c             	pushl  0xc(%ebp)
  80032b:	ff 75 08             	pushl  0x8(%ebp)
  80032e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800334:	50                   	push   %eax
  800335:	68 c9 02 80 00       	push   $0x8002c9
  80033a:	e8 54 01 00 00       	call   800493 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80033f:	83 c4 08             	add    $0x8,%esp
  800342:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800348:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80034e:	50                   	push   %eax
  80034f:	e8 d4 08 00 00       	call   800c28 <sys_cputs>

	return b.cnt;
}
  800354:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80035a:	c9                   	leave  
  80035b:	c3                   	ret    

0080035c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80035c:	55                   	push   %ebp
  80035d:	89 e5                	mov    %esp,%ebp
  80035f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800362:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800365:	50                   	push   %eax
  800366:	ff 75 08             	pushl  0x8(%ebp)
  800369:	e8 9d ff ff ff       	call   80030b <vcprintf>
	va_end(ap);

	return cnt;
}
  80036e:	c9                   	leave  
  80036f:	c3                   	ret    

00800370 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	57                   	push   %edi
  800374:	56                   	push   %esi
  800375:	53                   	push   %ebx
  800376:	83 ec 1c             	sub    $0x1c,%esp
  800379:	89 c7                	mov    %eax,%edi
  80037b:	89 d6                	mov    %edx,%esi
  80037d:	8b 45 08             	mov    0x8(%ebp),%eax
  800380:	8b 55 0c             	mov    0xc(%ebp),%edx
  800383:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800386:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800389:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80038c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800391:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800394:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800397:	39 d3                	cmp    %edx,%ebx
  800399:	72 05                	jb     8003a0 <printnum+0x30>
  80039b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80039e:	77 45                	ja     8003e5 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003a0:	83 ec 0c             	sub    $0xc,%esp
  8003a3:	ff 75 18             	pushl  0x18(%ebp)
  8003a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003ac:	53                   	push   %ebx
  8003ad:	ff 75 10             	pushl  0x10(%ebp)
  8003b0:	83 ec 08             	sub    $0x8,%esp
  8003b3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003b6:	ff 75 e0             	pushl  -0x20(%ebp)
  8003b9:	ff 75 dc             	pushl  -0x24(%ebp)
  8003bc:	ff 75 d8             	pushl  -0x28(%ebp)
  8003bf:	e8 4c 19 00 00       	call   801d10 <__udivdi3>
  8003c4:	83 c4 18             	add    $0x18,%esp
  8003c7:	52                   	push   %edx
  8003c8:	50                   	push   %eax
  8003c9:	89 f2                	mov    %esi,%edx
  8003cb:	89 f8                	mov    %edi,%eax
  8003cd:	e8 9e ff ff ff       	call   800370 <printnum>
  8003d2:	83 c4 20             	add    $0x20,%esp
  8003d5:	eb 18                	jmp    8003ef <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003d7:	83 ec 08             	sub    $0x8,%esp
  8003da:	56                   	push   %esi
  8003db:	ff 75 18             	pushl  0x18(%ebp)
  8003de:	ff d7                	call   *%edi
  8003e0:	83 c4 10             	add    $0x10,%esp
  8003e3:	eb 03                	jmp    8003e8 <printnum+0x78>
  8003e5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003e8:	83 eb 01             	sub    $0x1,%ebx
  8003eb:	85 db                	test   %ebx,%ebx
  8003ed:	7f e8                	jg     8003d7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003ef:	83 ec 08             	sub    $0x8,%esp
  8003f2:	56                   	push   %esi
  8003f3:	83 ec 04             	sub    $0x4,%esp
  8003f6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003f9:	ff 75 e0             	pushl  -0x20(%ebp)
  8003fc:	ff 75 dc             	pushl  -0x24(%ebp)
  8003ff:	ff 75 d8             	pushl  -0x28(%ebp)
  800402:	e8 39 1a 00 00       	call   801e40 <__umoddi3>
  800407:	83 c4 14             	add    $0x14,%esp
  80040a:	0f be 80 5b 20 80 00 	movsbl 0x80205b(%eax),%eax
  800411:	50                   	push   %eax
  800412:	ff d7                	call   *%edi
}
  800414:	83 c4 10             	add    $0x10,%esp
  800417:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80041a:	5b                   	pop    %ebx
  80041b:	5e                   	pop    %esi
  80041c:	5f                   	pop    %edi
  80041d:	5d                   	pop    %ebp
  80041e:	c3                   	ret    

0080041f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80041f:	55                   	push   %ebp
  800420:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800422:	83 fa 01             	cmp    $0x1,%edx
  800425:	7e 0e                	jle    800435 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800427:	8b 10                	mov    (%eax),%edx
  800429:	8d 4a 08             	lea    0x8(%edx),%ecx
  80042c:	89 08                	mov    %ecx,(%eax)
  80042e:	8b 02                	mov    (%edx),%eax
  800430:	8b 52 04             	mov    0x4(%edx),%edx
  800433:	eb 22                	jmp    800457 <getuint+0x38>
	else if (lflag)
  800435:	85 d2                	test   %edx,%edx
  800437:	74 10                	je     800449 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800439:	8b 10                	mov    (%eax),%edx
  80043b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80043e:	89 08                	mov    %ecx,(%eax)
  800440:	8b 02                	mov    (%edx),%eax
  800442:	ba 00 00 00 00       	mov    $0x0,%edx
  800447:	eb 0e                	jmp    800457 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800449:	8b 10                	mov    (%eax),%edx
  80044b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80044e:	89 08                	mov    %ecx,(%eax)
  800450:	8b 02                	mov    (%edx),%eax
  800452:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800457:	5d                   	pop    %ebp
  800458:	c3                   	ret    

00800459 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800459:	55                   	push   %ebp
  80045a:	89 e5                	mov    %esp,%ebp
  80045c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80045f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800463:	8b 10                	mov    (%eax),%edx
  800465:	3b 50 04             	cmp    0x4(%eax),%edx
  800468:	73 0a                	jae    800474 <sprintputch+0x1b>
		*b->buf++ = ch;
  80046a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80046d:	89 08                	mov    %ecx,(%eax)
  80046f:	8b 45 08             	mov    0x8(%ebp),%eax
  800472:	88 02                	mov    %al,(%edx)
}
  800474:	5d                   	pop    %ebp
  800475:	c3                   	ret    

00800476 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800476:	55                   	push   %ebp
  800477:	89 e5                	mov    %esp,%ebp
  800479:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80047c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80047f:	50                   	push   %eax
  800480:	ff 75 10             	pushl  0x10(%ebp)
  800483:	ff 75 0c             	pushl  0xc(%ebp)
  800486:	ff 75 08             	pushl  0x8(%ebp)
  800489:	e8 05 00 00 00       	call   800493 <vprintfmt>
	va_end(ap);
}
  80048e:	83 c4 10             	add    $0x10,%esp
  800491:	c9                   	leave  
  800492:	c3                   	ret    

00800493 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800493:	55                   	push   %ebp
  800494:	89 e5                	mov    %esp,%ebp
  800496:	57                   	push   %edi
  800497:	56                   	push   %esi
  800498:	53                   	push   %ebx
  800499:	83 ec 2c             	sub    $0x2c,%esp
  80049c:	8b 75 08             	mov    0x8(%ebp),%esi
  80049f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004a2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004a5:	eb 12                	jmp    8004b9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004a7:	85 c0                	test   %eax,%eax
  8004a9:	0f 84 89 03 00 00    	je     800838 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	53                   	push   %ebx
  8004b3:	50                   	push   %eax
  8004b4:	ff d6                	call   *%esi
  8004b6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004b9:	83 c7 01             	add    $0x1,%edi
  8004bc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004c0:	83 f8 25             	cmp    $0x25,%eax
  8004c3:	75 e2                	jne    8004a7 <vprintfmt+0x14>
  8004c5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004c9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004d0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004d7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004de:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e3:	eb 07                	jmp    8004ec <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004e8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ec:	8d 47 01             	lea    0x1(%edi),%eax
  8004ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004f2:	0f b6 07             	movzbl (%edi),%eax
  8004f5:	0f b6 c8             	movzbl %al,%ecx
  8004f8:	83 e8 23             	sub    $0x23,%eax
  8004fb:	3c 55                	cmp    $0x55,%al
  8004fd:	0f 87 1a 03 00 00    	ja     80081d <vprintfmt+0x38a>
  800503:	0f b6 c0             	movzbl %al,%eax
  800506:	ff 24 85 a0 21 80 00 	jmp    *0x8021a0(,%eax,4)
  80050d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800510:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800514:	eb d6                	jmp    8004ec <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800516:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800519:	b8 00 00 00 00       	mov    $0x0,%eax
  80051e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800521:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800524:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800528:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80052b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80052e:	83 fa 09             	cmp    $0x9,%edx
  800531:	77 39                	ja     80056c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800533:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800536:	eb e9                	jmp    800521 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800538:	8b 45 14             	mov    0x14(%ebp),%eax
  80053b:	8d 48 04             	lea    0x4(%eax),%ecx
  80053e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800541:	8b 00                	mov    (%eax),%eax
  800543:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800546:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800549:	eb 27                	jmp    800572 <vprintfmt+0xdf>
  80054b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80054e:	85 c0                	test   %eax,%eax
  800550:	b9 00 00 00 00       	mov    $0x0,%ecx
  800555:	0f 49 c8             	cmovns %eax,%ecx
  800558:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80055e:	eb 8c                	jmp    8004ec <vprintfmt+0x59>
  800560:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800563:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80056a:	eb 80                	jmp    8004ec <vprintfmt+0x59>
  80056c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80056f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800572:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800576:	0f 89 70 ff ff ff    	jns    8004ec <vprintfmt+0x59>
				width = precision, precision = -1;
  80057c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80057f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800582:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800589:	e9 5e ff ff ff       	jmp    8004ec <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80058e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800591:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800594:	e9 53 ff ff ff       	jmp    8004ec <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800599:	8b 45 14             	mov    0x14(%ebp),%eax
  80059c:	8d 50 04             	lea    0x4(%eax),%edx
  80059f:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a2:	83 ec 08             	sub    $0x8,%esp
  8005a5:	53                   	push   %ebx
  8005a6:	ff 30                	pushl  (%eax)
  8005a8:	ff d6                	call   *%esi
			break;
  8005aa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005b0:	e9 04 ff ff ff       	jmp    8004b9 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8d 50 04             	lea    0x4(%eax),%edx
  8005bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005be:	8b 00                	mov    (%eax),%eax
  8005c0:	99                   	cltd   
  8005c1:	31 d0                	xor    %edx,%eax
  8005c3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005c5:	83 f8 0f             	cmp    $0xf,%eax
  8005c8:	7f 0b                	jg     8005d5 <vprintfmt+0x142>
  8005ca:	8b 14 85 00 23 80 00 	mov    0x802300(,%eax,4),%edx
  8005d1:	85 d2                	test   %edx,%edx
  8005d3:	75 18                	jne    8005ed <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005d5:	50                   	push   %eax
  8005d6:	68 73 20 80 00       	push   $0x802073
  8005db:	53                   	push   %ebx
  8005dc:	56                   	push   %esi
  8005dd:	e8 94 fe ff ff       	call   800476 <printfmt>
  8005e2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005e8:	e9 cc fe ff ff       	jmp    8004b9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005ed:	52                   	push   %edx
  8005ee:	68 35 24 80 00       	push   $0x802435
  8005f3:	53                   	push   %ebx
  8005f4:	56                   	push   %esi
  8005f5:	e8 7c fe ff ff       	call   800476 <printfmt>
  8005fa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800600:	e9 b4 fe ff ff       	jmp    8004b9 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800605:	8b 45 14             	mov    0x14(%ebp),%eax
  800608:	8d 50 04             	lea    0x4(%eax),%edx
  80060b:	89 55 14             	mov    %edx,0x14(%ebp)
  80060e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800610:	85 ff                	test   %edi,%edi
  800612:	b8 6c 20 80 00       	mov    $0x80206c,%eax
  800617:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80061a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80061e:	0f 8e 94 00 00 00    	jle    8006b8 <vprintfmt+0x225>
  800624:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800628:	0f 84 98 00 00 00    	je     8006c6 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80062e:	83 ec 08             	sub    $0x8,%esp
  800631:	ff 75 d0             	pushl  -0x30(%ebp)
  800634:	57                   	push   %edi
  800635:	e8 86 02 00 00       	call   8008c0 <strnlen>
  80063a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80063d:	29 c1                	sub    %eax,%ecx
  80063f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800642:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800645:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800649:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80064c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80064f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800651:	eb 0f                	jmp    800662 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800653:	83 ec 08             	sub    $0x8,%esp
  800656:	53                   	push   %ebx
  800657:	ff 75 e0             	pushl  -0x20(%ebp)
  80065a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80065c:	83 ef 01             	sub    $0x1,%edi
  80065f:	83 c4 10             	add    $0x10,%esp
  800662:	85 ff                	test   %edi,%edi
  800664:	7f ed                	jg     800653 <vprintfmt+0x1c0>
  800666:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800669:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80066c:	85 c9                	test   %ecx,%ecx
  80066e:	b8 00 00 00 00       	mov    $0x0,%eax
  800673:	0f 49 c1             	cmovns %ecx,%eax
  800676:	29 c1                	sub    %eax,%ecx
  800678:	89 75 08             	mov    %esi,0x8(%ebp)
  80067b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80067e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800681:	89 cb                	mov    %ecx,%ebx
  800683:	eb 4d                	jmp    8006d2 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800685:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800689:	74 1b                	je     8006a6 <vprintfmt+0x213>
  80068b:	0f be c0             	movsbl %al,%eax
  80068e:	83 e8 20             	sub    $0x20,%eax
  800691:	83 f8 5e             	cmp    $0x5e,%eax
  800694:	76 10                	jbe    8006a6 <vprintfmt+0x213>
					putch('?', putdat);
  800696:	83 ec 08             	sub    $0x8,%esp
  800699:	ff 75 0c             	pushl  0xc(%ebp)
  80069c:	6a 3f                	push   $0x3f
  80069e:	ff 55 08             	call   *0x8(%ebp)
  8006a1:	83 c4 10             	add    $0x10,%esp
  8006a4:	eb 0d                	jmp    8006b3 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8006a6:	83 ec 08             	sub    $0x8,%esp
  8006a9:	ff 75 0c             	pushl  0xc(%ebp)
  8006ac:	52                   	push   %edx
  8006ad:	ff 55 08             	call   *0x8(%ebp)
  8006b0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006b3:	83 eb 01             	sub    $0x1,%ebx
  8006b6:	eb 1a                	jmp    8006d2 <vprintfmt+0x23f>
  8006b8:	89 75 08             	mov    %esi,0x8(%ebp)
  8006bb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006be:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006c1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006c4:	eb 0c                	jmp    8006d2 <vprintfmt+0x23f>
  8006c6:	89 75 08             	mov    %esi,0x8(%ebp)
  8006c9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006cc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006cf:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006d2:	83 c7 01             	add    $0x1,%edi
  8006d5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006d9:	0f be d0             	movsbl %al,%edx
  8006dc:	85 d2                	test   %edx,%edx
  8006de:	74 23                	je     800703 <vprintfmt+0x270>
  8006e0:	85 f6                	test   %esi,%esi
  8006e2:	78 a1                	js     800685 <vprintfmt+0x1f2>
  8006e4:	83 ee 01             	sub    $0x1,%esi
  8006e7:	79 9c                	jns    800685 <vprintfmt+0x1f2>
  8006e9:	89 df                	mov    %ebx,%edi
  8006eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006f1:	eb 18                	jmp    80070b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006f3:	83 ec 08             	sub    $0x8,%esp
  8006f6:	53                   	push   %ebx
  8006f7:	6a 20                	push   $0x20
  8006f9:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006fb:	83 ef 01             	sub    $0x1,%edi
  8006fe:	83 c4 10             	add    $0x10,%esp
  800701:	eb 08                	jmp    80070b <vprintfmt+0x278>
  800703:	89 df                	mov    %ebx,%edi
  800705:	8b 75 08             	mov    0x8(%ebp),%esi
  800708:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80070b:	85 ff                	test   %edi,%edi
  80070d:	7f e4                	jg     8006f3 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800712:	e9 a2 fd ff ff       	jmp    8004b9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800717:	83 fa 01             	cmp    $0x1,%edx
  80071a:	7e 16                	jle    800732 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80071c:	8b 45 14             	mov    0x14(%ebp),%eax
  80071f:	8d 50 08             	lea    0x8(%eax),%edx
  800722:	89 55 14             	mov    %edx,0x14(%ebp)
  800725:	8b 50 04             	mov    0x4(%eax),%edx
  800728:	8b 00                	mov    (%eax),%eax
  80072a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80072d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800730:	eb 32                	jmp    800764 <vprintfmt+0x2d1>
	else if (lflag)
  800732:	85 d2                	test   %edx,%edx
  800734:	74 18                	je     80074e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800736:	8b 45 14             	mov    0x14(%ebp),%eax
  800739:	8d 50 04             	lea    0x4(%eax),%edx
  80073c:	89 55 14             	mov    %edx,0x14(%ebp)
  80073f:	8b 00                	mov    (%eax),%eax
  800741:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800744:	89 c1                	mov    %eax,%ecx
  800746:	c1 f9 1f             	sar    $0x1f,%ecx
  800749:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80074c:	eb 16                	jmp    800764 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80074e:	8b 45 14             	mov    0x14(%ebp),%eax
  800751:	8d 50 04             	lea    0x4(%eax),%edx
  800754:	89 55 14             	mov    %edx,0x14(%ebp)
  800757:	8b 00                	mov    (%eax),%eax
  800759:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80075c:	89 c1                	mov    %eax,%ecx
  80075e:	c1 f9 1f             	sar    $0x1f,%ecx
  800761:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800764:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800767:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80076a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80076f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800773:	79 74                	jns    8007e9 <vprintfmt+0x356>
				putch('-', putdat);
  800775:	83 ec 08             	sub    $0x8,%esp
  800778:	53                   	push   %ebx
  800779:	6a 2d                	push   $0x2d
  80077b:	ff d6                	call   *%esi
				num = -(long long) num;
  80077d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800780:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800783:	f7 d8                	neg    %eax
  800785:	83 d2 00             	adc    $0x0,%edx
  800788:	f7 da                	neg    %edx
  80078a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80078d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800792:	eb 55                	jmp    8007e9 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800794:	8d 45 14             	lea    0x14(%ebp),%eax
  800797:	e8 83 fc ff ff       	call   80041f <getuint>
			base = 10;
  80079c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007a1:	eb 46                	jmp    8007e9 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8007a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a6:	e8 74 fc ff ff       	call   80041f <getuint>
			base = 8;
  8007ab:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8007b0:	eb 37                	jmp    8007e9 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8007b2:	83 ec 08             	sub    $0x8,%esp
  8007b5:	53                   	push   %ebx
  8007b6:	6a 30                	push   $0x30
  8007b8:	ff d6                	call   *%esi
			putch('x', putdat);
  8007ba:	83 c4 08             	add    $0x8,%esp
  8007bd:	53                   	push   %ebx
  8007be:	6a 78                	push   $0x78
  8007c0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c5:	8d 50 04             	lea    0x4(%eax),%edx
  8007c8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007cb:	8b 00                	mov    (%eax),%eax
  8007cd:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007d2:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007d5:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007da:	eb 0d                	jmp    8007e9 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007dc:	8d 45 14             	lea    0x14(%ebp),%eax
  8007df:	e8 3b fc ff ff       	call   80041f <getuint>
			base = 16;
  8007e4:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007e9:	83 ec 0c             	sub    $0xc,%esp
  8007ec:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007f0:	57                   	push   %edi
  8007f1:	ff 75 e0             	pushl  -0x20(%ebp)
  8007f4:	51                   	push   %ecx
  8007f5:	52                   	push   %edx
  8007f6:	50                   	push   %eax
  8007f7:	89 da                	mov    %ebx,%edx
  8007f9:	89 f0                	mov    %esi,%eax
  8007fb:	e8 70 fb ff ff       	call   800370 <printnum>
			break;
  800800:	83 c4 20             	add    $0x20,%esp
  800803:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800806:	e9 ae fc ff ff       	jmp    8004b9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80080b:	83 ec 08             	sub    $0x8,%esp
  80080e:	53                   	push   %ebx
  80080f:	51                   	push   %ecx
  800810:	ff d6                	call   *%esi
			break;
  800812:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800815:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800818:	e9 9c fc ff ff       	jmp    8004b9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80081d:	83 ec 08             	sub    $0x8,%esp
  800820:	53                   	push   %ebx
  800821:	6a 25                	push   $0x25
  800823:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800825:	83 c4 10             	add    $0x10,%esp
  800828:	eb 03                	jmp    80082d <vprintfmt+0x39a>
  80082a:	83 ef 01             	sub    $0x1,%edi
  80082d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800831:	75 f7                	jne    80082a <vprintfmt+0x397>
  800833:	e9 81 fc ff ff       	jmp    8004b9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800838:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80083b:	5b                   	pop    %ebx
  80083c:	5e                   	pop    %esi
  80083d:	5f                   	pop    %edi
  80083e:	5d                   	pop    %ebp
  80083f:	c3                   	ret    

00800840 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	83 ec 18             	sub    $0x18,%esp
  800846:	8b 45 08             	mov    0x8(%ebp),%eax
  800849:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80084c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80084f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800853:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800856:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80085d:	85 c0                	test   %eax,%eax
  80085f:	74 26                	je     800887 <vsnprintf+0x47>
  800861:	85 d2                	test   %edx,%edx
  800863:	7e 22                	jle    800887 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800865:	ff 75 14             	pushl  0x14(%ebp)
  800868:	ff 75 10             	pushl  0x10(%ebp)
  80086b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80086e:	50                   	push   %eax
  80086f:	68 59 04 80 00       	push   $0x800459
  800874:	e8 1a fc ff ff       	call   800493 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800879:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80087c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80087f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800882:	83 c4 10             	add    $0x10,%esp
  800885:	eb 05                	jmp    80088c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800887:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80088c:	c9                   	leave  
  80088d:	c3                   	ret    

0080088e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800894:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800897:	50                   	push   %eax
  800898:	ff 75 10             	pushl  0x10(%ebp)
  80089b:	ff 75 0c             	pushl  0xc(%ebp)
  80089e:	ff 75 08             	pushl  0x8(%ebp)
  8008a1:	e8 9a ff ff ff       	call   800840 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008a6:	c9                   	leave  
  8008a7:	c3                   	ret    

008008a8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b3:	eb 03                	jmp    8008b8 <strlen+0x10>
		n++;
  8008b5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008bc:	75 f7                	jne    8008b5 <strlen+0xd>
		n++;
	return n;
}
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ce:	eb 03                	jmp    8008d3 <strnlen+0x13>
		n++;
  8008d0:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d3:	39 c2                	cmp    %eax,%edx
  8008d5:	74 08                	je     8008df <strnlen+0x1f>
  8008d7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008db:	75 f3                	jne    8008d0 <strnlen+0x10>
  8008dd:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	53                   	push   %ebx
  8008e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008eb:	89 c2                	mov    %eax,%edx
  8008ed:	83 c2 01             	add    $0x1,%edx
  8008f0:	83 c1 01             	add    $0x1,%ecx
  8008f3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008f7:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008fa:	84 db                	test   %bl,%bl
  8008fc:	75 ef                	jne    8008ed <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008fe:	5b                   	pop    %ebx
  8008ff:	5d                   	pop    %ebp
  800900:	c3                   	ret    

00800901 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	53                   	push   %ebx
  800905:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800908:	53                   	push   %ebx
  800909:	e8 9a ff ff ff       	call   8008a8 <strlen>
  80090e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800911:	ff 75 0c             	pushl  0xc(%ebp)
  800914:	01 d8                	add    %ebx,%eax
  800916:	50                   	push   %eax
  800917:	e8 c5 ff ff ff       	call   8008e1 <strcpy>
	return dst;
}
  80091c:	89 d8                	mov    %ebx,%eax
  80091e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800921:	c9                   	leave  
  800922:	c3                   	ret    

00800923 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	56                   	push   %esi
  800927:	53                   	push   %ebx
  800928:	8b 75 08             	mov    0x8(%ebp),%esi
  80092b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092e:	89 f3                	mov    %esi,%ebx
  800930:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800933:	89 f2                	mov    %esi,%edx
  800935:	eb 0f                	jmp    800946 <strncpy+0x23>
		*dst++ = *src;
  800937:	83 c2 01             	add    $0x1,%edx
  80093a:	0f b6 01             	movzbl (%ecx),%eax
  80093d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800940:	80 39 01             	cmpb   $0x1,(%ecx)
  800943:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800946:	39 da                	cmp    %ebx,%edx
  800948:	75 ed                	jne    800937 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80094a:	89 f0                	mov    %esi,%eax
  80094c:	5b                   	pop    %ebx
  80094d:	5e                   	pop    %esi
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    

00800950 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	56                   	push   %esi
  800954:	53                   	push   %ebx
  800955:	8b 75 08             	mov    0x8(%ebp),%esi
  800958:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80095b:	8b 55 10             	mov    0x10(%ebp),%edx
  80095e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800960:	85 d2                	test   %edx,%edx
  800962:	74 21                	je     800985 <strlcpy+0x35>
  800964:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800968:	89 f2                	mov    %esi,%edx
  80096a:	eb 09                	jmp    800975 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80096c:	83 c2 01             	add    $0x1,%edx
  80096f:	83 c1 01             	add    $0x1,%ecx
  800972:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800975:	39 c2                	cmp    %eax,%edx
  800977:	74 09                	je     800982 <strlcpy+0x32>
  800979:	0f b6 19             	movzbl (%ecx),%ebx
  80097c:	84 db                	test   %bl,%bl
  80097e:	75 ec                	jne    80096c <strlcpy+0x1c>
  800980:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800982:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800985:	29 f0                	sub    %esi,%eax
}
  800987:	5b                   	pop    %ebx
  800988:	5e                   	pop    %esi
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800991:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800994:	eb 06                	jmp    80099c <strcmp+0x11>
		p++, q++;
  800996:	83 c1 01             	add    $0x1,%ecx
  800999:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80099c:	0f b6 01             	movzbl (%ecx),%eax
  80099f:	84 c0                	test   %al,%al
  8009a1:	74 04                	je     8009a7 <strcmp+0x1c>
  8009a3:	3a 02                	cmp    (%edx),%al
  8009a5:	74 ef                	je     800996 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a7:	0f b6 c0             	movzbl %al,%eax
  8009aa:	0f b6 12             	movzbl (%edx),%edx
  8009ad:	29 d0                	sub    %edx,%eax
}
  8009af:	5d                   	pop    %ebp
  8009b0:	c3                   	ret    

008009b1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
  8009b4:	53                   	push   %ebx
  8009b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009bb:	89 c3                	mov    %eax,%ebx
  8009bd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009c0:	eb 06                	jmp    8009c8 <strncmp+0x17>
		n--, p++, q++;
  8009c2:	83 c0 01             	add    $0x1,%eax
  8009c5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009c8:	39 d8                	cmp    %ebx,%eax
  8009ca:	74 15                	je     8009e1 <strncmp+0x30>
  8009cc:	0f b6 08             	movzbl (%eax),%ecx
  8009cf:	84 c9                	test   %cl,%cl
  8009d1:	74 04                	je     8009d7 <strncmp+0x26>
  8009d3:	3a 0a                	cmp    (%edx),%cl
  8009d5:	74 eb                	je     8009c2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d7:	0f b6 00             	movzbl (%eax),%eax
  8009da:	0f b6 12             	movzbl (%edx),%edx
  8009dd:	29 d0                	sub    %edx,%eax
  8009df:	eb 05                	jmp    8009e6 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009e1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009e6:	5b                   	pop    %ebx
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ef:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f3:	eb 07                	jmp    8009fc <strchr+0x13>
		if (*s == c)
  8009f5:	38 ca                	cmp    %cl,%dl
  8009f7:	74 0f                	je     800a08 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009f9:	83 c0 01             	add    $0x1,%eax
  8009fc:	0f b6 10             	movzbl (%eax),%edx
  8009ff:	84 d2                	test   %dl,%dl
  800a01:	75 f2                	jne    8009f5 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a10:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a14:	eb 03                	jmp    800a19 <strfind+0xf>
  800a16:	83 c0 01             	add    $0x1,%eax
  800a19:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a1c:	38 ca                	cmp    %cl,%dl
  800a1e:	74 04                	je     800a24 <strfind+0x1a>
  800a20:	84 d2                	test   %dl,%dl
  800a22:	75 f2                	jne    800a16 <strfind+0xc>
			break;
	return (char *) s;
}
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	57                   	push   %edi
  800a2a:	56                   	push   %esi
  800a2b:	53                   	push   %ebx
  800a2c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a2f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a32:	85 c9                	test   %ecx,%ecx
  800a34:	74 36                	je     800a6c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a36:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a3c:	75 28                	jne    800a66 <memset+0x40>
  800a3e:	f6 c1 03             	test   $0x3,%cl
  800a41:	75 23                	jne    800a66 <memset+0x40>
		c &= 0xFF;
  800a43:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a47:	89 d3                	mov    %edx,%ebx
  800a49:	c1 e3 08             	shl    $0x8,%ebx
  800a4c:	89 d6                	mov    %edx,%esi
  800a4e:	c1 e6 18             	shl    $0x18,%esi
  800a51:	89 d0                	mov    %edx,%eax
  800a53:	c1 e0 10             	shl    $0x10,%eax
  800a56:	09 f0                	or     %esi,%eax
  800a58:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a5a:	89 d8                	mov    %ebx,%eax
  800a5c:	09 d0                	or     %edx,%eax
  800a5e:	c1 e9 02             	shr    $0x2,%ecx
  800a61:	fc                   	cld    
  800a62:	f3 ab                	rep stos %eax,%es:(%edi)
  800a64:	eb 06                	jmp    800a6c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a66:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a69:	fc                   	cld    
  800a6a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a6c:	89 f8                	mov    %edi,%eax
  800a6e:	5b                   	pop    %ebx
  800a6f:	5e                   	pop    %esi
  800a70:	5f                   	pop    %edi
  800a71:	5d                   	pop    %ebp
  800a72:	c3                   	ret    

00800a73 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	57                   	push   %edi
  800a77:	56                   	push   %esi
  800a78:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a81:	39 c6                	cmp    %eax,%esi
  800a83:	73 35                	jae    800aba <memmove+0x47>
  800a85:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a88:	39 d0                	cmp    %edx,%eax
  800a8a:	73 2e                	jae    800aba <memmove+0x47>
		s += n;
		d += n;
  800a8c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8f:	89 d6                	mov    %edx,%esi
  800a91:	09 fe                	or     %edi,%esi
  800a93:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a99:	75 13                	jne    800aae <memmove+0x3b>
  800a9b:	f6 c1 03             	test   $0x3,%cl
  800a9e:	75 0e                	jne    800aae <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800aa0:	83 ef 04             	sub    $0x4,%edi
  800aa3:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aa6:	c1 e9 02             	shr    $0x2,%ecx
  800aa9:	fd                   	std    
  800aaa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aac:	eb 09                	jmp    800ab7 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aae:	83 ef 01             	sub    $0x1,%edi
  800ab1:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ab4:	fd                   	std    
  800ab5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ab7:	fc                   	cld    
  800ab8:	eb 1d                	jmp    800ad7 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aba:	89 f2                	mov    %esi,%edx
  800abc:	09 c2                	or     %eax,%edx
  800abe:	f6 c2 03             	test   $0x3,%dl
  800ac1:	75 0f                	jne    800ad2 <memmove+0x5f>
  800ac3:	f6 c1 03             	test   $0x3,%cl
  800ac6:	75 0a                	jne    800ad2 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ac8:	c1 e9 02             	shr    $0x2,%ecx
  800acb:	89 c7                	mov    %eax,%edi
  800acd:	fc                   	cld    
  800ace:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad0:	eb 05                	jmp    800ad7 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ad2:	89 c7                	mov    %eax,%edi
  800ad4:	fc                   	cld    
  800ad5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ad7:	5e                   	pop    %esi
  800ad8:	5f                   	pop    %edi
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ade:	ff 75 10             	pushl  0x10(%ebp)
  800ae1:	ff 75 0c             	pushl  0xc(%ebp)
  800ae4:	ff 75 08             	pushl  0x8(%ebp)
  800ae7:	e8 87 ff ff ff       	call   800a73 <memmove>
}
  800aec:	c9                   	leave  
  800aed:	c3                   	ret    

00800aee <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	56                   	push   %esi
  800af2:	53                   	push   %ebx
  800af3:	8b 45 08             	mov    0x8(%ebp),%eax
  800af6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af9:	89 c6                	mov    %eax,%esi
  800afb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800afe:	eb 1a                	jmp    800b1a <memcmp+0x2c>
		if (*s1 != *s2)
  800b00:	0f b6 08             	movzbl (%eax),%ecx
  800b03:	0f b6 1a             	movzbl (%edx),%ebx
  800b06:	38 d9                	cmp    %bl,%cl
  800b08:	74 0a                	je     800b14 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b0a:	0f b6 c1             	movzbl %cl,%eax
  800b0d:	0f b6 db             	movzbl %bl,%ebx
  800b10:	29 d8                	sub    %ebx,%eax
  800b12:	eb 0f                	jmp    800b23 <memcmp+0x35>
		s1++, s2++;
  800b14:	83 c0 01             	add    $0x1,%eax
  800b17:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b1a:	39 f0                	cmp    %esi,%eax
  800b1c:	75 e2                	jne    800b00 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b1e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b23:	5b                   	pop    %ebx
  800b24:	5e                   	pop    %esi
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	53                   	push   %ebx
  800b2b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b2e:	89 c1                	mov    %eax,%ecx
  800b30:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b33:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b37:	eb 0a                	jmp    800b43 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b39:	0f b6 10             	movzbl (%eax),%edx
  800b3c:	39 da                	cmp    %ebx,%edx
  800b3e:	74 07                	je     800b47 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b40:	83 c0 01             	add    $0x1,%eax
  800b43:	39 c8                	cmp    %ecx,%eax
  800b45:	72 f2                	jb     800b39 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b47:	5b                   	pop    %ebx
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	57                   	push   %edi
  800b4e:	56                   	push   %esi
  800b4f:	53                   	push   %ebx
  800b50:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b53:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b56:	eb 03                	jmp    800b5b <strtol+0x11>
		s++;
  800b58:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b5b:	0f b6 01             	movzbl (%ecx),%eax
  800b5e:	3c 20                	cmp    $0x20,%al
  800b60:	74 f6                	je     800b58 <strtol+0xe>
  800b62:	3c 09                	cmp    $0x9,%al
  800b64:	74 f2                	je     800b58 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b66:	3c 2b                	cmp    $0x2b,%al
  800b68:	75 0a                	jne    800b74 <strtol+0x2a>
		s++;
  800b6a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b6d:	bf 00 00 00 00       	mov    $0x0,%edi
  800b72:	eb 11                	jmp    800b85 <strtol+0x3b>
  800b74:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b79:	3c 2d                	cmp    $0x2d,%al
  800b7b:	75 08                	jne    800b85 <strtol+0x3b>
		s++, neg = 1;
  800b7d:	83 c1 01             	add    $0x1,%ecx
  800b80:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b85:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b8b:	75 15                	jne    800ba2 <strtol+0x58>
  800b8d:	80 39 30             	cmpb   $0x30,(%ecx)
  800b90:	75 10                	jne    800ba2 <strtol+0x58>
  800b92:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b96:	75 7c                	jne    800c14 <strtol+0xca>
		s += 2, base = 16;
  800b98:	83 c1 02             	add    $0x2,%ecx
  800b9b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ba0:	eb 16                	jmp    800bb8 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ba2:	85 db                	test   %ebx,%ebx
  800ba4:	75 12                	jne    800bb8 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ba6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bab:	80 39 30             	cmpb   $0x30,(%ecx)
  800bae:	75 08                	jne    800bb8 <strtol+0x6e>
		s++, base = 8;
  800bb0:	83 c1 01             	add    $0x1,%ecx
  800bb3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bb8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbd:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bc0:	0f b6 11             	movzbl (%ecx),%edx
  800bc3:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bc6:	89 f3                	mov    %esi,%ebx
  800bc8:	80 fb 09             	cmp    $0x9,%bl
  800bcb:	77 08                	ja     800bd5 <strtol+0x8b>
			dig = *s - '0';
  800bcd:	0f be d2             	movsbl %dl,%edx
  800bd0:	83 ea 30             	sub    $0x30,%edx
  800bd3:	eb 22                	jmp    800bf7 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800bd5:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bd8:	89 f3                	mov    %esi,%ebx
  800bda:	80 fb 19             	cmp    $0x19,%bl
  800bdd:	77 08                	ja     800be7 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bdf:	0f be d2             	movsbl %dl,%edx
  800be2:	83 ea 57             	sub    $0x57,%edx
  800be5:	eb 10                	jmp    800bf7 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800be7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bea:	89 f3                	mov    %esi,%ebx
  800bec:	80 fb 19             	cmp    $0x19,%bl
  800bef:	77 16                	ja     800c07 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bf1:	0f be d2             	movsbl %dl,%edx
  800bf4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bf7:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bfa:	7d 0b                	jge    800c07 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bfc:	83 c1 01             	add    $0x1,%ecx
  800bff:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c03:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c05:	eb b9                	jmp    800bc0 <strtol+0x76>

	if (endptr)
  800c07:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c0b:	74 0d                	je     800c1a <strtol+0xd0>
		*endptr = (char *) s;
  800c0d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c10:	89 0e                	mov    %ecx,(%esi)
  800c12:	eb 06                	jmp    800c1a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c14:	85 db                	test   %ebx,%ebx
  800c16:	74 98                	je     800bb0 <strtol+0x66>
  800c18:	eb 9e                	jmp    800bb8 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c1a:	89 c2                	mov    %eax,%edx
  800c1c:	f7 da                	neg    %edx
  800c1e:	85 ff                	test   %edi,%edi
  800c20:	0f 45 c2             	cmovne %edx,%eax
}
  800c23:	5b                   	pop    %ebx
  800c24:	5e                   	pop    %esi
  800c25:	5f                   	pop    %edi
  800c26:	5d                   	pop    %ebp
  800c27:	c3                   	ret    

00800c28 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c28:	55                   	push   %ebp
  800c29:	89 e5                	mov    %esp,%ebp
  800c2b:	57                   	push   %edi
  800c2c:	56                   	push   %esi
  800c2d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c36:	8b 55 08             	mov    0x8(%ebp),%edx
  800c39:	89 c3                	mov    %eax,%ebx
  800c3b:	89 c7                	mov    %eax,%edi
  800c3d:	89 c6                	mov    %eax,%esi
  800c3f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c51:	b8 01 00 00 00       	mov    $0x1,%eax
  800c56:	89 d1                	mov    %edx,%ecx
  800c58:	89 d3                	mov    %edx,%ebx
  800c5a:	89 d7                	mov    %edx,%edi
  800c5c:	89 d6                	mov    %edx,%esi
  800c5e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5f                   	pop    %edi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    

00800c65 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	57                   	push   %edi
  800c69:	56                   	push   %esi
  800c6a:	53                   	push   %ebx
  800c6b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c73:	b8 03 00 00 00       	mov    $0x3,%eax
  800c78:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7b:	89 cb                	mov    %ecx,%ebx
  800c7d:	89 cf                	mov    %ecx,%edi
  800c7f:	89 ce                	mov    %ecx,%esi
  800c81:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c83:	85 c0                	test   %eax,%eax
  800c85:	7e 17                	jle    800c9e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c87:	83 ec 0c             	sub    $0xc,%esp
  800c8a:	50                   	push   %eax
  800c8b:	6a 03                	push   $0x3
  800c8d:	68 5f 23 80 00       	push   $0x80235f
  800c92:	6a 23                	push   $0x23
  800c94:	68 7c 23 80 00       	push   $0x80237c
  800c99:	e8 e5 f5 ff ff       	call   800283 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5f                   	pop    %edi
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    

00800ca6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cac:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb1:	b8 02 00 00 00       	mov    $0x2,%eax
  800cb6:	89 d1                	mov    %edx,%ecx
  800cb8:	89 d3                	mov    %edx,%ebx
  800cba:	89 d7                	mov    %edx,%edi
  800cbc:	89 d6                	mov    %edx,%esi
  800cbe:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <sys_yield>:

void
sys_yield(void)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccb:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cd5:	89 d1                	mov    %edx,%ecx
  800cd7:	89 d3                	mov    %edx,%ebx
  800cd9:	89 d7                	mov    %edx,%edi
  800cdb:	89 d6                	mov    %edx,%esi
  800cdd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
  800cea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ced:	be 00 00 00 00       	mov    $0x0,%esi
  800cf2:	b8 04 00 00 00       	mov    $0x4,%eax
  800cf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d00:	89 f7                	mov    %esi,%edi
  800d02:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d04:	85 c0                	test   %eax,%eax
  800d06:	7e 17                	jle    800d1f <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d08:	83 ec 0c             	sub    $0xc,%esp
  800d0b:	50                   	push   %eax
  800d0c:	6a 04                	push   $0x4
  800d0e:	68 5f 23 80 00       	push   $0x80235f
  800d13:	6a 23                	push   $0x23
  800d15:	68 7c 23 80 00       	push   $0x80237c
  800d1a:	e8 64 f5 ff ff       	call   800283 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d22:	5b                   	pop    %ebx
  800d23:	5e                   	pop    %esi
  800d24:	5f                   	pop    %edi
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    

00800d27 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	57                   	push   %edi
  800d2b:	56                   	push   %esi
  800d2c:	53                   	push   %ebx
  800d2d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d30:	b8 05 00 00 00       	mov    $0x5,%eax
  800d35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d38:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d41:	8b 75 18             	mov    0x18(%ebp),%esi
  800d44:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d46:	85 c0                	test   %eax,%eax
  800d48:	7e 17                	jle    800d61 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4a:	83 ec 0c             	sub    $0xc,%esp
  800d4d:	50                   	push   %eax
  800d4e:	6a 05                	push   $0x5
  800d50:	68 5f 23 80 00       	push   $0x80235f
  800d55:	6a 23                	push   $0x23
  800d57:	68 7c 23 80 00       	push   $0x80237c
  800d5c:	e8 22 f5 ff ff       	call   800283 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d64:	5b                   	pop    %ebx
  800d65:	5e                   	pop    %esi
  800d66:	5f                   	pop    %edi
  800d67:	5d                   	pop    %ebp
  800d68:	c3                   	ret    

00800d69 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	57                   	push   %edi
  800d6d:	56                   	push   %esi
  800d6e:	53                   	push   %ebx
  800d6f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d72:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d77:	b8 06 00 00 00       	mov    $0x6,%eax
  800d7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d82:	89 df                	mov    %ebx,%edi
  800d84:	89 de                	mov    %ebx,%esi
  800d86:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d88:	85 c0                	test   %eax,%eax
  800d8a:	7e 17                	jle    800da3 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8c:	83 ec 0c             	sub    $0xc,%esp
  800d8f:	50                   	push   %eax
  800d90:	6a 06                	push   $0x6
  800d92:	68 5f 23 80 00       	push   $0x80235f
  800d97:	6a 23                	push   $0x23
  800d99:	68 7c 23 80 00       	push   $0x80237c
  800d9e:	e8 e0 f4 ff ff       	call   800283 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800da3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da6:	5b                   	pop    %ebx
  800da7:	5e                   	pop    %esi
  800da8:	5f                   	pop    %edi
  800da9:	5d                   	pop    %ebp
  800daa:	c3                   	ret    

00800dab <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	57                   	push   %edi
  800daf:	56                   	push   %esi
  800db0:	53                   	push   %ebx
  800db1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db9:	b8 08 00 00 00       	mov    $0x8,%eax
  800dbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc4:	89 df                	mov    %ebx,%edi
  800dc6:	89 de                	mov    %ebx,%esi
  800dc8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dca:	85 c0                	test   %eax,%eax
  800dcc:	7e 17                	jle    800de5 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dce:	83 ec 0c             	sub    $0xc,%esp
  800dd1:	50                   	push   %eax
  800dd2:	6a 08                	push   $0x8
  800dd4:	68 5f 23 80 00       	push   $0x80235f
  800dd9:	6a 23                	push   $0x23
  800ddb:	68 7c 23 80 00       	push   $0x80237c
  800de0:	e8 9e f4 ff ff       	call   800283 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800de5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de8:	5b                   	pop    %ebx
  800de9:	5e                   	pop    %esi
  800dea:	5f                   	pop    %edi
  800deb:	5d                   	pop    %ebp
  800dec:	c3                   	ret    

00800ded <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ded:	55                   	push   %ebp
  800dee:	89 e5                	mov    %esp,%ebp
  800df0:	57                   	push   %edi
  800df1:	56                   	push   %esi
  800df2:	53                   	push   %ebx
  800df3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfb:	b8 09 00 00 00       	mov    $0x9,%eax
  800e00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e03:	8b 55 08             	mov    0x8(%ebp),%edx
  800e06:	89 df                	mov    %ebx,%edi
  800e08:	89 de                	mov    %ebx,%esi
  800e0a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e0c:	85 c0                	test   %eax,%eax
  800e0e:	7e 17                	jle    800e27 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e10:	83 ec 0c             	sub    $0xc,%esp
  800e13:	50                   	push   %eax
  800e14:	6a 09                	push   $0x9
  800e16:	68 5f 23 80 00       	push   $0x80235f
  800e1b:	6a 23                	push   $0x23
  800e1d:	68 7c 23 80 00       	push   $0x80237c
  800e22:	e8 5c f4 ff ff       	call   800283 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e2a:	5b                   	pop    %ebx
  800e2b:	5e                   	pop    %esi
  800e2c:	5f                   	pop    %edi
  800e2d:	5d                   	pop    %ebp
  800e2e:	c3                   	ret    

00800e2f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e2f:	55                   	push   %ebp
  800e30:	89 e5                	mov    %esp,%ebp
  800e32:	57                   	push   %edi
  800e33:	56                   	push   %esi
  800e34:	53                   	push   %ebx
  800e35:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e38:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e45:	8b 55 08             	mov    0x8(%ebp),%edx
  800e48:	89 df                	mov    %ebx,%edi
  800e4a:	89 de                	mov    %ebx,%esi
  800e4c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e4e:	85 c0                	test   %eax,%eax
  800e50:	7e 17                	jle    800e69 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e52:	83 ec 0c             	sub    $0xc,%esp
  800e55:	50                   	push   %eax
  800e56:	6a 0a                	push   $0xa
  800e58:	68 5f 23 80 00       	push   $0x80235f
  800e5d:	6a 23                	push   $0x23
  800e5f:	68 7c 23 80 00       	push   $0x80237c
  800e64:	e8 1a f4 ff ff       	call   800283 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e6c:	5b                   	pop    %ebx
  800e6d:	5e                   	pop    %esi
  800e6e:	5f                   	pop    %edi
  800e6f:	5d                   	pop    %ebp
  800e70:	c3                   	ret    

00800e71 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	57                   	push   %edi
  800e75:	56                   	push   %esi
  800e76:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e77:	be 00 00 00 00       	mov    $0x0,%esi
  800e7c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e84:	8b 55 08             	mov    0x8(%ebp),%edx
  800e87:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e8a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e8d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e8f:	5b                   	pop    %ebx
  800e90:	5e                   	pop    %esi
  800e91:	5f                   	pop    %edi
  800e92:	5d                   	pop    %ebp
  800e93:	c3                   	ret    

00800e94 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	57                   	push   %edi
  800e98:	56                   	push   %esi
  800e99:	53                   	push   %ebx
  800e9a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ea2:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ea7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eaa:	89 cb                	mov    %ecx,%ebx
  800eac:	89 cf                	mov    %ecx,%edi
  800eae:	89 ce                	mov    %ecx,%esi
  800eb0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eb2:	85 c0                	test   %eax,%eax
  800eb4:	7e 17                	jle    800ecd <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb6:	83 ec 0c             	sub    $0xc,%esp
  800eb9:	50                   	push   %eax
  800eba:	6a 0d                	push   $0xd
  800ebc:	68 5f 23 80 00       	push   $0x80235f
  800ec1:	6a 23                	push   $0x23
  800ec3:	68 7c 23 80 00       	push   $0x80237c
  800ec8:	e8 b6 f3 ff ff       	call   800283 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ecd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed0:	5b                   	pop    %ebx
  800ed1:	5e                   	pop    %esi
  800ed2:	5f                   	pop    %edi
  800ed3:	5d                   	pop    %ebp
  800ed4:	c3                   	ret    

00800ed5 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ed5:	55                   	push   %ebp
  800ed6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ed8:	8b 45 08             	mov    0x8(%ebp),%eax
  800edb:	05 00 00 00 30       	add    $0x30000000,%eax
  800ee0:	c1 e8 0c             	shr    $0xc,%eax
}
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    

00800ee5 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800ee8:	8b 45 08             	mov    0x8(%ebp),%eax
  800eeb:	05 00 00 00 30       	add    $0x30000000,%eax
  800ef0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ef5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    

00800efc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f02:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f07:	89 c2                	mov    %eax,%edx
  800f09:	c1 ea 16             	shr    $0x16,%edx
  800f0c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f13:	f6 c2 01             	test   $0x1,%dl
  800f16:	74 11                	je     800f29 <fd_alloc+0x2d>
  800f18:	89 c2                	mov    %eax,%edx
  800f1a:	c1 ea 0c             	shr    $0xc,%edx
  800f1d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f24:	f6 c2 01             	test   $0x1,%dl
  800f27:	75 09                	jne    800f32 <fd_alloc+0x36>
			*fd_store = fd;
  800f29:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f30:	eb 17                	jmp    800f49 <fd_alloc+0x4d>
  800f32:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f37:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f3c:	75 c9                	jne    800f07 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f3e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f44:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f49:	5d                   	pop    %ebp
  800f4a:	c3                   	ret    

00800f4b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f51:	83 f8 1f             	cmp    $0x1f,%eax
  800f54:	77 36                	ja     800f8c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f56:	c1 e0 0c             	shl    $0xc,%eax
  800f59:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f5e:	89 c2                	mov    %eax,%edx
  800f60:	c1 ea 16             	shr    $0x16,%edx
  800f63:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f6a:	f6 c2 01             	test   $0x1,%dl
  800f6d:	74 24                	je     800f93 <fd_lookup+0x48>
  800f6f:	89 c2                	mov    %eax,%edx
  800f71:	c1 ea 0c             	shr    $0xc,%edx
  800f74:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f7b:	f6 c2 01             	test   $0x1,%dl
  800f7e:	74 1a                	je     800f9a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f80:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f83:	89 02                	mov    %eax,(%edx)
	return 0;
  800f85:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8a:	eb 13                	jmp    800f9f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f8c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f91:	eb 0c                	jmp    800f9f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f93:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f98:	eb 05                	jmp    800f9f <fd_lookup+0x54>
  800f9a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f9f:	5d                   	pop    %ebp
  800fa0:	c3                   	ret    

00800fa1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fa1:	55                   	push   %ebp
  800fa2:	89 e5                	mov    %esp,%ebp
  800fa4:	83 ec 08             	sub    $0x8,%esp
  800fa7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800faa:	ba 0c 24 80 00       	mov    $0x80240c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800faf:	eb 13                	jmp    800fc4 <dev_lookup+0x23>
  800fb1:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800fb4:	39 08                	cmp    %ecx,(%eax)
  800fb6:	75 0c                	jne    800fc4 <dev_lookup+0x23>
			*dev = devtab[i];
  800fb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fbb:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fbd:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc2:	eb 2e                	jmp    800ff2 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fc4:	8b 02                	mov    (%edx),%eax
  800fc6:	85 c0                	test   %eax,%eax
  800fc8:	75 e7                	jne    800fb1 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fca:	a1 04 40 80 00       	mov    0x804004,%eax
  800fcf:	8b 40 48             	mov    0x48(%eax),%eax
  800fd2:	83 ec 04             	sub    $0x4,%esp
  800fd5:	51                   	push   %ecx
  800fd6:	50                   	push   %eax
  800fd7:	68 8c 23 80 00       	push   $0x80238c
  800fdc:	e8 7b f3 ff ff       	call   80035c <cprintf>
	*dev = 0;
  800fe1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fe4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fea:	83 c4 10             	add    $0x10,%esp
  800fed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ff2:	c9                   	leave  
  800ff3:	c3                   	ret    

00800ff4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ff4:	55                   	push   %ebp
  800ff5:	89 e5                	mov    %esp,%ebp
  800ff7:	56                   	push   %esi
  800ff8:	53                   	push   %ebx
  800ff9:	83 ec 10             	sub    $0x10,%esp
  800ffc:	8b 75 08             	mov    0x8(%ebp),%esi
  800fff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801002:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801005:	50                   	push   %eax
  801006:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80100c:	c1 e8 0c             	shr    $0xc,%eax
  80100f:	50                   	push   %eax
  801010:	e8 36 ff ff ff       	call   800f4b <fd_lookup>
  801015:	83 c4 08             	add    $0x8,%esp
  801018:	85 c0                	test   %eax,%eax
  80101a:	78 05                	js     801021 <fd_close+0x2d>
	    || fd != fd2)
  80101c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80101f:	74 0c                	je     80102d <fd_close+0x39>
		return (must_exist ? r : 0);
  801021:	84 db                	test   %bl,%bl
  801023:	ba 00 00 00 00       	mov    $0x0,%edx
  801028:	0f 44 c2             	cmove  %edx,%eax
  80102b:	eb 41                	jmp    80106e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80102d:	83 ec 08             	sub    $0x8,%esp
  801030:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801033:	50                   	push   %eax
  801034:	ff 36                	pushl  (%esi)
  801036:	e8 66 ff ff ff       	call   800fa1 <dev_lookup>
  80103b:	89 c3                	mov    %eax,%ebx
  80103d:	83 c4 10             	add    $0x10,%esp
  801040:	85 c0                	test   %eax,%eax
  801042:	78 1a                	js     80105e <fd_close+0x6a>
		if (dev->dev_close)
  801044:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801047:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80104a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80104f:	85 c0                	test   %eax,%eax
  801051:	74 0b                	je     80105e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801053:	83 ec 0c             	sub    $0xc,%esp
  801056:	56                   	push   %esi
  801057:	ff d0                	call   *%eax
  801059:	89 c3                	mov    %eax,%ebx
  80105b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80105e:	83 ec 08             	sub    $0x8,%esp
  801061:	56                   	push   %esi
  801062:	6a 00                	push   $0x0
  801064:	e8 00 fd ff ff       	call   800d69 <sys_page_unmap>
	return r;
  801069:	83 c4 10             	add    $0x10,%esp
  80106c:	89 d8                	mov    %ebx,%eax
}
  80106e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801071:	5b                   	pop    %ebx
  801072:	5e                   	pop    %esi
  801073:	5d                   	pop    %ebp
  801074:	c3                   	ret    

00801075 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801075:	55                   	push   %ebp
  801076:	89 e5                	mov    %esp,%ebp
  801078:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80107b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80107e:	50                   	push   %eax
  80107f:	ff 75 08             	pushl  0x8(%ebp)
  801082:	e8 c4 fe ff ff       	call   800f4b <fd_lookup>
  801087:	83 c4 08             	add    $0x8,%esp
  80108a:	85 c0                	test   %eax,%eax
  80108c:	78 10                	js     80109e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80108e:	83 ec 08             	sub    $0x8,%esp
  801091:	6a 01                	push   $0x1
  801093:	ff 75 f4             	pushl  -0xc(%ebp)
  801096:	e8 59 ff ff ff       	call   800ff4 <fd_close>
  80109b:	83 c4 10             	add    $0x10,%esp
}
  80109e:	c9                   	leave  
  80109f:	c3                   	ret    

008010a0 <close_all>:

void
close_all(void)
{
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
  8010a3:	53                   	push   %ebx
  8010a4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010a7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010ac:	83 ec 0c             	sub    $0xc,%esp
  8010af:	53                   	push   %ebx
  8010b0:	e8 c0 ff ff ff       	call   801075 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010b5:	83 c3 01             	add    $0x1,%ebx
  8010b8:	83 c4 10             	add    $0x10,%esp
  8010bb:	83 fb 20             	cmp    $0x20,%ebx
  8010be:	75 ec                	jne    8010ac <close_all+0xc>
		close(i);
}
  8010c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c3:	c9                   	leave  
  8010c4:	c3                   	ret    

008010c5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010c5:	55                   	push   %ebp
  8010c6:	89 e5                	mov    %esp,%ebp
  8010c8:	57                   	push   %edi
  8010c9:	56                   	push   %esi
  8010ca:	53                   	push   %ebx
  8010cb:	83 ec 2c             	sub    $0x2c,%esp
  8010ce:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010d1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010d4:	50                   	push   %eax
  8010d5:	ff 75 08             	pushl  0x8(%ebp)
  8010d8:	e8 6e fe ff ff       	call   800f4b <fd_lookup>
  8010dd:	83 c4 08             	add    $0x8,%esp
  8010e0:	85 c0                	test   %eax,%eax
  8010e2:	0f 88 c1 00 00 00    	js     8011a9 <dup+0xe4>
		return r;
	close(newfdnum);
  8010e8:	83 ec 0c             	sub    $0xc,%esp
  8010eb:	56                   	push   %esi
  8010ec:	e8 84 ff ff ff       	call   801075 <close>

	newfd = INDEX2FD(newfdnum);
  8010f1:	89 f3                	mov    %esi,%ebx
  8010f3:	c1 e3 0c             	shl    $0xc,%ebx
  8010f6:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010fc:	83 c4 04             	add    $0x4,%esp
  8010ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  801102:	e8 de fd ff ff       	call   800ee5 <fd2data>
  801107:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801109:	89 1c 24             	mov    %ebx,(%esp)
  80110c:	e8 d4 fd ff ff       	call   800ee5 <fd2data>
  801111:	83 c4 10             	add    $0x10,%esp
  801114:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801117:	89 f8                	mov    %edi,%eax
  801119:	c1 e8 16             	shr    $0x16,%eax
  80111c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801123:	a8 01                	test   $0x1,%al
  801125:	74 37                	je     80115e <dup+0x99>
  801127:	89 f8                	mov    %edi,%eax
  801129:	c1 e8 0c             	shr    $0xc,%eax
  80112c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801133:	f6 c2 01             	test   $0x1,%dl
  801136:	74 26                	je     80115e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801138:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80113f:	83 ec 0c             	sub    $0xc,%esp
  801142:	25 07 0e 00 00       	and    $0xe07,%eax
  801147:	50                   	push   %eax
  801148:	ff 75 d4             	pushl  -0x2c(%ebp)
  80114b:	6a 00                	push   $0x0
  80114d:	57                   	push   %edi
  80114e:	6a 00                	push   $0x0
  801150:	e8 d2 fb ff ff       	call   800d27 <sys_page_map>
  801155:	89 c7                	mov    %eax,%edi
  801157:	83 c4 20             	add    $0x20,%esp
  80115a:	85 c0                	test   %eax,%eax
  80115c:	78 2e                	js     80118c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80115e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801161:	89 d0                	mov    %edx,%eax
  801163:	c1 e8 0c             	shr    $0xc,%eax
  801166:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80116d:	83 ec 0c             	sub    $0xc,%esp
  801170:	25 07 0e 00 00       	and    $0xe07,%eax
  801175:	50                   	push   %eax
  801176:	53                   	push   %ebx
  801177:	6a 00                	push   $0x0
  801179:	52                   	push   %edx
  80117a:	6a 00                	push   $0x0
  80117c:	e8 a6 fb ff ff       	call   800d27 <sys_page_map>
  801181:	89 c7                	mov    %eax,%edi
  801183:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801186:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801188:	85 ff                	test   %edi,%edi
  80118a:	79 1d                	jns    8011a9 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80118c:	83 ec 08             	sub    $0x8,%esp
  80118f:	53                   	push   %ebx
  801190:	6a 00                	push   $0x0
  801192:	e8 d2 fb ff ff       	call   800d69 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801197:	83 c4 08             	add    $0x8,%esp
  80119a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80119d:	6a 00                	push   $0x0
  80119f:	e8 c5 fb ff ff       	call   800d69 <sys_page_unmap>
	return r;
  8011a4:	83 c4 10             	add    $0x10,%esp
  8011a7:	89 f8                	mov    %edi,%eax
}
  8011a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ac:	5b                   	pop    %ebx
  8011ad:	5e                   	pop    %esi
  8011ae:	5f                   	pop    %edi
  8011af:	5d                   	pop    %ebp
  8011b0:	c3                   	ret    

008011b1 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011b1:	55                   	push   %ebp
  8011b2:	89 e5                	mov    %esp,%ebp
  8011b4:	53                   	push   %ebx
  8011b5:	83 ec 14             	sub    $0x14,%esp
  8011b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011be:	50                   	push   %eax
  8011bf:	53                   	push   %ebx
  8011c0:	e8 86 fd ff ff       	call   800f4b <fd_lookup>
  8011c5:	83 c4 08             	add    $0x8,%esp
  8011c8:	89 c2                	mov    %eax,%edx
  8011ca:	85 c0                	test   %eax,%eax
  8011cc:	78 6d                	js     80123b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ce:	83 ec 08             	sub    $0x8,%esp
  8011d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d4:	50                   	push   %eax
  8011d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d8:	ff 30                	pushl  (%eax)
  8011da:	e8 c2 fd ff ff       	call   800fa1 <dev_lookup>
  8011df:	83 c4 10             	add    $0x10,%esp
  8011e2:	85 c0                	test   %eax,%eax
  8011e4:	78 4c                	js     801232 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011e6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011e9:	8b 42 08             	mov    0x8(%edx),%eax
  8011ec:	83 e0 03             	and    $0x3,%eax
  8011ef:	83 f8 01             	cmp    $0x1,%eax
  8011f2:	75 21                	jne    801215 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011f4:	a1 04 40 80 00       	mov    0x804004,%eax
  8011f9:	8b 40 48             	mov    0x48(%eax),%eax
  8011fc:	83 ec 04             	sub    $0x4,%esp
  8011ff:	53                   	push   %ebx
  801200:	50                   	push   %eax
  801201:	68 d0 23 80 00       	push   $0x8023d0
  801206:	e8 51 f1 ff ff       	call   80035c <cprintf>
		return -E_INVAL;
  80120b:	83 c4 10             	add    $0x10,%esp
  80120e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801213:	eb 26                	jmp    80123b <read+0x8a>
	}
	if (!dev->dev_read)
  801215:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801218:	8b 40 08             	mov    0x8(%eax),%eax
  80121b:	85 c0                	test   %eax,%eax
  80121d:	74 17                	je     801236 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80121f:	83 ec 04             	sub    $0x4,%esp
  801222:	ff 75 10             	pushl  0x10(%ebp)
  801225:	ff 75 0c             	pushl  0xc(%ebp)
  801228:	52                   	push   %edx
  801229:	ff d0                	call   *%eax
  80122b:	89 c2                	mov    %eax,%edx
  80122d:	83 c4 10             	add    $0x10,%esp
  801230:	eb 09                	jmp    80123b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801232:	89 c2                	mov    %eax,%edx
  801234:	eb 05                	jmp    80123b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801236:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80123b:	89 d0                	mov    %edx,%eax
  80123d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801240:	c9                   	leave  
  801241:	c3                   	ret    

00801242 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801242:	55                   	push   %ebp
  801243:	89 e5                	mov    %esp,%ebp
  801245:	57                   	push   %edi
  801246:	56                   	push   %esi
  801247:	53                   	push   %ebx
  801248:	83 ec 0c             	sub    $0xc,%esp
  80124b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80124e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801251:	bb 00 00 00 00       	mov    $0x0,%ebx
  801256:	eb 21                	jmp    801279 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801258:	83 ec 04             	sub    $0x4,%esp
  80125b:	89 f0                	mov    %esi,%eax
  80125d:	29 d8                	sub    %ebx,%eax
  80125f:	50                   	push   %eax
  801260:	89 d8                	mov    %ebx,%eax
  801262:	03 45 0c             	add    0xc(%ebp),%eax
  801265:	50                   	push   %eax
  801266:	57                   	push   %edi
  801267:	e8 45 ff ff ff       	call   8011b1 <read>
		if (m < 0)
  80126c:	83 c4 10             	add    $0x10,%esp
  80126f:	85 c0                	test   %eax,%eax
  801271:	78 10                	js     801283 <readn+0x41>
			return m;
		if (m == 0)
  801273:	85 c0                	test   %eax,%eax
  801275:	74 0a                	je     801281 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801277:	01 c3                	add    %eax,%ebx
  801279:	39 f3                	cmp    %esi,%ebx
  80127b:	72 db                	jb     801258 <readn+0x16>
  80127d:	89 d8                	mov    %ebx,%eax
  80127f:	eb 02                	jmp    801283 <readn+0x41>
  801281:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801283:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801286:	5b                   	pop    %ebx
  801287:	5e                   	pop    %esi
  801288:	5f                   	pop    %edi
  801289:	5d                   	pop    %ebp
  80128a:	c3                   	ret    

0080128b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80128b:	55                   	push   %ebp
  80128c:	89 e5                	mov    %esp,%ebp
  80128e:	53                   	push   %ebx
  80128f:	83 ec 14             	sub    $0x14,%esp
  801292:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801295:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801298:	50                   	push   %eax
  801299:	53                   	push   %ebx
  80129a:	e8 ac fc ff ff       	call   800f4b <fd_lookup>
  80129f:	83 c4 08             	add    $0x8,%esp
  8012a2:	89 c2                	mov    %eax,%edx
  8012a4:	85 c0                	test   %eax,%eax
  8012a6:	78 68                	js     801310 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012a8:	83 ec 08             	sub    $0x8,%esp
  8012ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ae:	50                   	push   %eax
  8012af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b2:	ff 30                	pushl  (%eax)
  8012b4:	e8 e8 fc ff ff       	call   800fa1 <dev_lookup>
  8012b9:	83 c4 10             	add    $0x10,%esp
  8012bc:	85 c0                	test   %eax,%eax
  8012be:	78 47                	js     801307 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012c7:	75 21                	jne    8012ea <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012c9:	a1 04 40 80 00       	mov    0x804004,%eax
  8012ce:	8b 40 48             	mov    0x48(%eax),%eax
  8012d1:	83 ec 04             	sub    $0x4,%esp
  8012d4:	53                   	push   %ebx
  8012d5:	50                   	push   %eax
  8012d6:	68 ec 23 80 00       	push   $0x8023ec
  8012db:	e8 7c f0 ff ff       	call   80035c <cprintf>
		return -E_INVAL;
  8012e0:	83 c4 10             	add    $0x10,%esp
  8012e3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012e8:	eb 26                	jmp    801310 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012ed:	8b 52 0c             	mov    0xc(%edx),%edx
  8012f0:	85 d2                	test   %edx,%edx
  8012f2:	74 17                	je     80130b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012f4:	83 ec 04             	sub    $0x4,%esp
  8012f7:	ff 75 10             	pushl  0x10(%ebp)
  8012fa:	ff 75 0c             	pushl  0xc(%ebp)
  8012fd:	50                   	push   %eax
  8012fe:	ff d2                	call   *%edx
  801300:	89 c2                	mov    %eax,%edx
  801302:	83 c4 10             	add    $0x10,%esp
  801305:	eb 09                	jmp    801310 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801307:	89 c2                	mov    %eax,%edx
  801309:	eb 05                	jmp    801310 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80130b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801310:	89 d0                	mov    %edx,%eax
  801312:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801315:	c9                   	leave  
  801316:	c3                   	ret    

00801317 <seek>:

int
seek(int fdnum, off_t offset)
{
  801317:	55                   	push   %ebp
  801318:	89 e5                	mov    %esp,%ebp
  80131a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80131d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801320:	50                   	push   %eax
  801321:	ff 75 08             	pushl  0x8(%ebp)
  801324:	e8 22 fc ff ff       	call   800f4b <fd_lookup>
  801329:	83 c4 08             	add    $0x8,%esp
  80132c:	85 c0                	test   %eax,%eax
  80132e:	78 0e                	js     80133e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801330:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801333:	8b 55 0c             	mov    0xc(%ebp),%edx
  801336:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801339:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80133e:	c9                   	leave  
  80133f:	c3                   	ret    

00801340 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801340:	55                   	push   %ebp
  801341:	89 e5                	mov    %esp,%ebp
  801343:	53                   	push   %ebx
  801344:	83 ec 14             	sub    $0x14,%esp
  801347:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80134a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80134d:	50                   	push   %eax
  80134e:	53                   	push   %ebx
  80134f:	e8 f7 fb ff ff       	call   800f4b <fd_lookup>
  801354:	83 c4 08             	add    $0x8,%esp
  801357:	89 c2                	mov    %eax,%edx
  801359:	85 c0                	test   %eax,%eax
  80135b:	78 65                	js     8013c2 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80135d:	83 ec 08             	sub    $0x8,%esp
  801360:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801363:	50                   	push   %eax
  801364:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801367:	ff 30                	pushl  (%eax)
  801369:	e8 33 fc ff ff       	call   800fa1 <dev_lookup>
  80136e:	83 c4 10             	add    $0x10,%esp
  801371:	85 c0                	test   %eax,%eax
  801373:	78 44                	js     8013b9 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801375:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801378:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80137c:	75 21                	jne    80139f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80137e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801383:	8b 40 48             	mov    0x48(%eax),%eax
  801386:	83 ec 04             	sub    $0x4,%esp
  801389:	53                   	push   %ebx
  80138a:	50                   	push   %eax
  80138b:	68 ac 23 80 00       	push   $0x8023ac
  801390:	e8 c7 ef ff ff       	call   80035c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801395:	83 c4 10             	add    $0x10,%esp
  801398:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80139d:	eb 23                	jmp    8013c2 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80139f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013a2:	8b 52 18             	mov    0x18(%edx),%edx
  8013a5:	85 d2                	test   %edx,%edx
  8013a7:	74 14                	je     8013bd <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013a9:	83 ec 08             	sub    $0x8,%esp
  8013ac:	ff 75 0c             	pushl  0xc(%ebp)
  8013af:	50                   	push   %eax
  8013b0:	ff d2                	call   *%edx
  8013b2:	89 c2                	mov    %eax,%edx
  8013b4:	83 c4 10             	add    $0x10,%esp
  8013b7:	eb 09                	jmp    8013c2 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b9:	89 c2                	mov    %eax,%edx
  8013bb:	eb 05                	jmp    8013c2 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013bd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8013c2:	89 d0                	mov    %edx,%eax
  8013c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c7:	c9                   	leave  
  8013c8:	c3                   	ret    

008013c9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013c9:	55                   	push   %ebp
  8013ca:	89 e5                	mov    %esp,%ebp
  8013cc:	53                   	push   %ebx
  8013cd:	83 ec 14             	sub    $0x14,%esp
  8013d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013d6:	50                   	push   %eax
  8013d7:	ff 75 08             	pushl  0x8(%ebp)
  8013da:	e8 6c fb ff ff       	call   800f4b <fd_lookup>
  8013df:	83 c4 08             	add    $0x8,%esp
  8013e2:	89 c2                	mov    %eax,%edx
  8013e4:	85 c0                	test   %eax,%eax
  8013e6:	78 58                	js     801440 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e8:	83 ec 08             	sub    $0x8,%esp
  8013eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ee:	50                   	push   %eax
  8013ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f2:	ff 30                	pushl  (%eax)
  8013f4:	e8 a8 fb ff ff       	call   800fa1 <dev_lookup>
  8013f9:	83 c4 10             	add    $0x10,%esp
  8013fc:	85 c0                	test   %eax,%eax
  8013fe:	78 37                	js     801437 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801400:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801403:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801407:	74 32                	je     80143b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801409:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80140c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801413:	00 00 00 
	stat->st_isdir = 0;
  801416:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80141d:	00 00 00 
	stat->st_dev = dev;
  801420:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801426:	83 ec 08             	sub    $0x8,%esp
  801429:	53                   	push   %ebx
  80142a:	ff 75 f0             	pushl  -0x10(%ebp)
  80142d:	ff 50 14             	call   *0x14(%eax)
  801430:	89 c2                	mov    %eax,%edx
  801432:	83 c4 10             	add    $0x10,%esp
  801435:	eb 09                	jmp    801440 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801437:	89 c2                	mov    %eax,%edx
  801439:	eb 05                	jmp    801440 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80143b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801440:	89 d0                	mov    %edx,%eax
  801442:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801445:	c9                   	leave  
  801446:	c3                   	ret    

00801447 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801447:	55                   	push   %ebp
  801448:	89 e5                	mov    %esp,%ebp
  80144a:	56                   	push   %esi
  80144b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80144c:	83 ec 08             	sub    $0x8,%esp
  80144f:	6a 00                	push   $0x0
  801451:	ff 75 08             	pushl  0x8(%ebp)
  801454:	e8 e3 01 00 00       	call   80163c <open>
  801459:	89 c3                	mov    %eax,%ebx
  80145b:	83 c4 10             	add    $0x10,%esp
  80145e:	85 c0                	test   %eax,%eax
  801460:	78 1b                	js     80147d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801462:	83 ec 08             	sub    $0x8,%esp
  801465:	ff 75 0c             	pushl  0xc(%ebp)
  801468:	50                   	push   %eax
  801469:	e8 5b ff ff ff       	call   8013c9 <fstat>
  80146e:	89 c6                	mov    %eax,%esi
	close(fd);
  801470:	89 1c 24             	mov    %ebx,(%esp)
  801473:	e8 fd fb ff ff       	call   801075 <close>
	return r;
  801478:	83 c4 10             	add    $0x10,%esp
  80147b:	89 f0                	mov    %esi,%eax
}
  80147d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801480:	5b                   	pop    %ebx
  801481:	5e                   	pop    %esi
  801482:	5d                   	pop    %ebp
  801483:	c3                   	ret    

00801484 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801484:	55                   	push   %ebp
  801485:	89 e5                	mov    %esp,%ebp
  801487:	56                   	push   %esi
  801488:	53                   	push   %ebx
  801489:	89 c6                	mov    %eax,%esi
  80148b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80148d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801494:	75 12                	jne    8014a8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801496:	83 ec 0c             	sub    $0xc,%esp
  801499:	6a 01                	push   $0x1
  80149b:	e8 f3 07 00 00       	call   801c93 <ipc_find_env>
  8014a0:	a3 00 40 80 00       	mov    %eax,0x804000
  8014a5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014a8:	6a 07                	push   $0x7
  8014aa:	68 00 50 80 00       	push   $0x805000
  8014af:	56                   	push   %esi
  8014b0:	ff 35 00 40 80 00    	pushl  0x804000
  8014b6:	e8 76 07 00 00       	call   801c31 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014bb:	83 c4 0c             	add    $0xc,%esp
  8014be:	6a 00                	push   $0x0
  8014c0:	53                   	push   %ebx
  8014c1:	6a 00                	push   $0x0
  8014c3:	e8 f7 06 00 00       	call   801bbf <ipc_recv>
}
  8014c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014cb:	5b                   	pop    %ebx
  8014cc:	5e                   	pop    %esi
  8014cd:	5d                   	pop    %ebp
  8014ce:	c3                   	ret    

008014cf <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014cf:	55                   	push   %ebp
  8014d0:	89 e5                	mov    %esp,%ebp
  8014d2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d8:	8b 40 0c             	mov    0xc(%eax),%eax
  8014db:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014e3:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ed:	b8 02 00 00 00       	mov    $0x2,%eax
  8014f2:	e8 8d ff ff ff       	call   801484 <fsipc>
}
  8014f7:	c9                   	leave  
  8014f8:	c3                   	ret    

008014f9 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014f9:	55                   	push   %ebp
  8014fa:	89 e5                	mov    %esp,%ebp
  8014fc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801502:	8b 40 0c             	mov    0xc(%eax),%eax
  801505:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80150a:	ba 00 00 00 00       	mov    $0x0,%edx
  80150f:	b8 06 00 00 00       	mov    $0x6,%eax
  801514:	e8 6b ff ff ff       	call   801484 <fsipc>
}
  801519:	c9                   	leave  
  80151a:	c3                   	ret    

0080151b <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80151b:	55                   	push   %ebp
  80151c:	89 e5                	mov    %esp,%ebp
  80151e:	53                   	push   %ebx
  80151f:	83 ec 04             	sub    $0x4,%esp
  801522:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801525:	8b 45 08             	mov    0x8(%ebp),%eax
  801528:	8b 40 0c             	mov    0xc(%eax),%eax
  80152b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801530:	ba 00 00 00 00       	mov    $0x0,%edx
  801535:	b8 05 00 00 00       	mov    $0x5,%eax
  80153a:	e8 45 ff ff ff       	call   801484 <fsipc>
  80153f:	85 c0                	test   %eax,%eax
  801541:	78 2c                	js     80156f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801543:	83 ec 08             	sub    $0x8,%esp
  801546:	68 00 50 80 00       	push   $0x805000
  80154b:	53                   	push   %ebx
  80154c:	e8 90 f3 ff ff       	call   8008e1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801551:	a1 80 50 80 00       	mov    0x805080,%eax
  801556:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80155c:	a1 84 50 80 00       	mov    0x805084,%eax
  801561:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801567:	83 c4 10             	add    $0x10,%esp
  80156a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80156f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801572:	c9                   	leave  
  801573:	c3                   	ret    

00801574 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801574:	55                   	push   %ebp
  801575:	89 e5                	mov    %esp,%ebp
  801577:	83 ec 0c             	sub    $0xc,%esp
  80157a:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80157d:	8b 55 08             	mov    0x8(%ebp),%edx
  801580:	8b 52 0c             	mov    0xc(%edx),%edx
  801583:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801589:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80158e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801593:	0f 47 c2             	cmova  %edx,%eax
  801596:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80159b:	50                   	push   %eax
  80159c:	ff 75 0c             	pushl  0xc(%ebp)
  80159f:	68 08 50 80 00       	push   $0x805008
  8015a4:	e8 ca f4 ff ff       	call   800a73 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8015a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ae:	b8 04 00 00 00       	mov    $0x4,%eax
  8015b3:	e8 cc fe ff ff       	call   801484 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8015b8:	c9                   	leave  
  8015b9:	c3                   	ret    

008015ba <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015ba:	55                   	push   %ebp
  8015bb:	89 e5                	mov    %esp,%ebp
  8015bd:	56                   	push   %esi
  8015be:	53                   	push   %ebx
  8015bf:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8015c8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015cd:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d8:	b8 03 00 00 00       	mov    $0x3,%eax
  8015dd:	e8 a2 fe ff ff       	call   801484 <fsipc>
  8015e2:	89 c3                	mov    %eax,%ebx
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	78 4b                	js     801633 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8015e8:	39 c6                	cmp    %eax,%esi
  8015ea:	73 16                	jae    801602 <devfile_read+0x48>
  8015ec:	68 1c 24 80 00       	push   $0x80241c
  8015f1:	68 23 24 80 00       	push   $0x802423
  8015f6:	6a 7c                	push   $0x7c
  8015f8:	68 38 24 80 00       	push   $0x802438
  8015fd:	e8 81 ec ff ff       	call   800283 <_panic>
	assert(r <= PGSIZE);
  801602:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801607:	7e 16                	jle    80161f <devfile_read+0x65>
  801609:	68 43 24 80 00       	push   $0x802443
  80160e:	68 23 24 80 00       	push   $0x802423
  801613:	6a 7d                	push   $0x7d
  801615:	68 38 24 80 00       	push   $0x802438
  80161a:	e8 64 ec ff ff       	call   800283 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80161f:	83 ec 04             	sub    $0x4,%esp
  801622:	50                   	push   %eax
  801623:	68 00 50 80 00       	push   $0x805000
  801628:	ff 75 0c             	pushl  0xc(%ebp)
  80162b:	e8 43 f4 ff ff       	call   800a73 <memmove>
	return r;
  801630:	83 c4 10             	add    $0x10,%esp
}
  801633:	89 d8                	mov    %ebx,%eax
  801635:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801638:	5b                   	pop    %ebx
  801639:	5e                   	pop    %esi
  80163a:	5d                   	pop    %ebp
  80163b:	c3                   	ret    

0080163c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80163c:	55                   	push   %ebp
  80163d:	89 e5                	mov    %esp,%ebp
  80163f:	53                   	push   %ebx
  801640:	83 ec 20             	sub    $0x20,%esp
  801643:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801646:	53                   	push   %ebx
  801647:	e8 5c f2 ff ff       	call   8008a8 <strlen>
  80164c:	83 c4 10             	add    $0x10,%esp
  80164f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801654:	7f 67                	jg     8016bd <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801656:	83 ec 0c             	sub    $0xc,%esp
  801659:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80165c:	50                   	push   %eax
  80165d:	e8 9a f8 ff ff       	call   800efc <fd_alloc>
  801662:	83 c4 10             	add    $0x10,%esp
		return r;
  801665:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801667:	85 c0                	test   %eax,%eax
  801669:	78 57                	js     8016c2 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80166b:	83 ec 08             	sub    $0x8,%esp
  80166e:	53                   	push   %ebx
  80166f:	68 00 50 80 00       	push   $0x805000
  801674:	e8 68 f2 ff ff       	call   8008e1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801679:	8b 45 0c             	mov    0xc(%ebp),%eax
  80167c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801681:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801684:	b8 01 00 00 00       	mov    $0x1,%eax
  801689:	e8 f6 fd ff ff       	call   801484 <fsipc>
  80168e:	89 c3                	mov    %eax,%ebx
  801690:	83 c4 10             	add    $0x10,%esp
  801693:	85 c0                	test   %eax,%eax
  801695:	79 14                	jns    8016ab <open+0x6f>
		fd_close(fd, 0);
  801697:	83 ec 08             	sub    $0x8,%esp
  80169a:	6a 00                	push   $0x0
  80169c:	ff 75 f4             	pushl  -0xc(%ebp)
  80169f:	e8 50 f9 ff ff       	call   800ff4 <fd_close>
		return r;
  8016a4:	83 c4 10             	add    $0x10,%esp
  8016a7:	89 da                	mov    %ebx,%edx
  8016a9:	eb 17                	jmp    8016c2 <open+0x86>
	}

	return fd2num(fd);
  8016ab:	83 ec 0c             	sub    $0xc,%esp
  8016ae:	ff 75 f4             	pushl  -0xc(%ebp)
  8016b1:	e8 1f f8 ff ff       	call   800ed5 <fd2num>
  8016b6:	89 c2                	mov    %eax,%edx
  8016b8:	83 c4 10             	add    $0x10,%esp
  8016bb:	eb 05                	jmp    8016c2 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016bd:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016c2:	89 d0                	mov    %edx,%eax
  8016c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c7:	c9                   	leave  
  8016c8:	c3                   	ret    

008016c9 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016c9:	55                   	push   %ebp
  8016ca:	89 e5                	mov    %esp,%ebp
  8016cc:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d4:	b8 08 00 00 00       	mov    $0x8,%eax
  8016d9:	e8 a6 fd ff ff       	call   801484 <fsipc>
}
  8016de:	c9                   	leave  
  8016df:	c3                   	ret    

008016e0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	56                   	push   %esi
  8016e4:	53                   	push   %ebx
  8016e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8016e8:	83 ec 0c             	sub    $0xc,%esp
  8016eb:	ff 75 08             	pushl  0x8(%ebp)
  8016ee:	e8 f2 f7 ff ff       	call   800ee5 <fd2data>
  8016f3:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8016f5:	83 c4 08             	add    $0x8,%esp
  8016f8:	68 4f 24 80 00       	push   $0x80244f
  8016fd:	53                   	push   %ebx
  8016fe:	e8 de f1 ff ff       	call   8008e1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801703:	8b 46 04             	mov    0x4(%esi),%eax
  801706:	2b 06                	sub    (%esi),%eax
  801708:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80170e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801715:	00 00 00 
	stat->st_dev = &devpipe;
  801718:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80171f:	30 80 00 
	return 0;
}
  801722:	b8 00 00 00 00       	mov    $0x0,%eax
  801727:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80172a:	5b                   	pop    %ebx
  80172b:	5e                   	pop    %esi
  80172c:	5d                   	pop    %ebp
  80172d:	c3                   	ret    

0080172e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80172e:	55                   	push   %ebp
  80172f:	89 e5                	mov    %esp,%ebp
  801731:	53                   	push   %ebx
  801732:	83 ec 0c             	sub    $0xc,%esp
  801735:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801738:	53                   	push   %ebx
  801739:	6a 00                	push   $0x0
  80173b:	e8 29 f6 ff ff       	call   800d69 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801740:	89 1c 24             	mov    %ebx,(%esp)
  801743:	e8 9d f7 ff ff       	call   800ee5 <fd2data>
  801748:	83 c4 08             	add    $0x8,%esp
  80174b:	50                   	push   %eax
  80174c:	6a 00                	push   $0x0
  80174e:	e8 16 f6 ff ff       	call   800d69 <sys_page_unmap>
}
  801753:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801756:	c9                   	leave  
  801757:	c3                   	ret    

00801758 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	57                   	push   %edi
  80175c:	56                   	push   %esi
  80175d:	53                   	push   %ebx
  80175e:	83 ec 1c             	sub    $0x1c,%esp
  801761:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801764:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801766:	a1 04 40 80 00       	mov    0x804004,%eax
  80176b:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80176e:	83 ec 0c             	sub    $0xc,%esp
  801771:	ff 75 e0             	pushl  -0x20(%ebp)
  801774:	e8 53 05 00 00       	call   801ccc <pageref>
  801779:	89 c3                	mov    %eax,%ebx
  80177b:	89 3c 24             	mov    %edi,(%esp)
  80177e:	e8 49 05 00 00       	call   801ccc <pageref>
  801783:	83 c4 10             	add    $0x10,%esp
  801786:	39 c3                	cmp    %eax,%ebx
  801788:	0f 94 c1             	sete   %cl
  80178b:	0f b6 c9             	movzbl %cl,%ecx
  80178e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801791:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801797:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80179a:	39 ce                	cmp    %ecx,%esi
  80179c:	74 1b                	je     8017b9 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80179e:	39 c3                	cmp    %eax,%ebx
  8017a0:	75 c4                	jne    801766 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8017a2:	8b 42 58             	mov    0x58(%edx),%eax
  8017a5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017a8:	50                   	push   %eax
  8017a9:	56                   	push   %esi
  8017aa:	68 56 24 80 00       	push   $0x802456
  8017af:	e8 a8 eb ff ff       	call   80035c <cprintf>
  8017b4:	83 c4 10             	add    $0x10,%esp
  8017b7:	eb ad                	jmp    801766 <_pipeisclosed+0xe>
	}
}
  8017b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017bf:	5b                   	pop    %ebx
  8017c0:	5e                   	pop    %esi
  8017c1:	5f                   	pop    %edi
  8017c2:	5d                   	pop    %ebp
  8017c3:	c3                   	ret    

008017c4 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8017c4:	55                   	push   %ebp
  8017c5:	89 e5                	mov    %esp,%ebp
  8017c7:	57                   	push   %edi
  8017c8:	56                   	push   %esi
  8017c9:	53                   	push   %ebx
  8017ca:	83 ec 28             	sub    $0x28,%esp
  8017cd:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8017d0:	56                   	push   %esi
  8017d1:	e8 0f f7 ff ff       	call   800ee5 <fd2data>
  8017d6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017d8:	83 c4 10             	add    $0x10,%esp
  8017db:	bf 00 00 00 00       	mov    $0x0,%edi
  8017e0:	eb 4b                	jmp    80182d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8017e2:	89 da                	mov    %ebx,%edx
  8017e4:	89 f0                	mov    %esi,%eax
  8017e6:	e8 6d ff ff ff       	call   801758 <_pipeisclosed>
  8017eb:	85 c0                	test   %eax,%eax
  8017ed:	75 48                	jne    801837 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8017ef:	e8 d1 f4 ff ff       	call   800cc5 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017f4:	8b 43 04             	mov    0x4(%ebx),%eax
  8017f7:	8b 0b                	mov    (%ebx),%ecx
  8017f9:	8d 51 20             	lea    0x20(%ecx),%edx
  8017fc:	39 d0                	cmp    %edx,%eax
  8017fe:	73 e2                	jae    8017e2 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801800:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801803:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801807:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80180a:	89 c2                	mov    %eax,%edx
  80180c:	c1 fa 1f             	sar    $0x1f,%edx
  80180f:	89 d1                	mov    %edx,%ecx
  801811:	c1 e9 1b             	shr    $0x1b,%ecx
  801814:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801817:	83 e2 1f             	and    $0x1f,%edx
  80181a:	29 ca                	sub    %ecx,%edx
  80181c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801820:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801824:	83 c0 01             	add    $0x1,%eax
  801827:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80182a:	83 c7 01             	add    $0x1,%edi
  80182d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801830:	75 c2                	jne    8017f4 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801832:	8b 45 10             	mov    0x10(%ebp),%eax
  801835:	eb 05                	jmp    80183c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801837:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80183c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80183f:	5b                   	pop    %ebx
  801840:	5e                   	pop    %esi
  801841:	5f                   	pop    %edi
  801842:	5d                   	pop    %ebp
  801843:	c3                   	ret    

00801844 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801844:	55                   	push   %ebp
  801845:	89 e5                	mov    %esp,%ebp
  801847:	57                   	push   %edi
  801848:	56                   	push   %esi
  801849:	53                   	push   %ebx
  80184a:	83 ec 18             	sub    $0x18,%esp
  80184d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801850:	57                   	push   %edi
  801851:	e8 8f f6 ff ff       	call   800ee5 <fd2data>
  801856:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801858:	83 c4 10             	add    $0x10,%esp
  80185b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801860:	eb 3d                	jmp    80189f <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801862:	85 db                	test   %ebx,%ebx
  801864:	74 04                	je     80186a <devpipe_read+0x26>
				return i;
  801866:	89 d8                	mov    %ebx,%eax
  801868:	eb 44                	jmp    8018ae <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80186a:	89 f2                	mov    %esi,%edx
  80186c:	89 f8                	mov    %edi,%eax
  80186e:	e8 e5 fe ff ff       	call   801758 <_pipeisclosed>
  801873:	85 c0                	test   %eax,%eax
  801875:	75 32                	jne    8018a9 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801877:	e8 49 f4 ff ff       	call   800cc5 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80187c:	8b 06                	mov    (%esi),%eax
  80187e:	3b 46 04             	cmp    0x4(%esi),%eax
  801881:	74 df                	je     801862 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801883:	99                   	cltd   
  801884:	c1 ea 1b             	shr    $0x1b,%edx
  801887:	01 d0                	add    %edx,%eax
  801889:	83 e0 1f             	and    $0x1f,%eax
  80188c:	29 d0                	sub    %edx,%eax
  80188e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801893:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801896:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801899:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80189c:	83 c3 01             	add    $0x1,%ebx
  80189f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8018a2:	75 d8                	jne    80187c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8018a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8018a7:	eb 05                	jmp    8018ae <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018a9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8018ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018b1:	5b                   	pop    %ebx
  8018b2:	5e                   	pop    %esi
  8018b3:	5f                   	pop    %edi
  8018b4:	5d                   	pop    %ebp
  8018b5:	c3                   	ret    

008018b6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8018b6:	55                   	push   %ebp
  8018b7:	89 e5                	mov    %esp,%ebp
  8018b9:	56                   	push   %esi
  8018ba:	53                   	push   %ebx
  8018bb:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8018be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c1:	50                   	push   %eax
  8018c2:	e8 35 f6 ff ff       	call   800efc <fd_alloc>
  8018c7:	83 c4 10             	add    $0x10,%esp
  8018ca:	89 c2                	mov    %eax,%edx
  8018cc:	85 c0                	test   %eax,%eax
  8018ce:	0f 88 2c 01 00 00    	js     801a00 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018d4:	83 ec 04             	sub    $0x4,%esp
  8018d7:	68 07 04 00 00       	push   $0x407
  8018dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8018df:	6a 00                	push   $0x0
  8018e1:	e8 fe f3 ff ff       	call   800ce4 <sys_page_alloc>
  8018e6:	83 c4 10             	add    $0x10,%esp
  8018e9:	89 c2                	mov    %eax,%edx
  8018eb:	85 c0                	test   %eax,%eax
  8018ed:	0f 88 0d 01 00 00    	js     801a00 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8018f3:	83 ec 0c             	sub    $0xc,%esp
  8018f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018f9:	50                   	push   %eax
  8018fa:	e8 fd f5 ff ff       	call   800efc <fd_alloc>
  8018ff:	89 c3                	mov    %eax,%ebx
  801901:	83 c4 10             	add    $0x10,%esp
  801904:	85 c0                	test   %eax,%eax
  801906:	0f 88 e2 00 00 00    	js     8019ee <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80190c:	83 ec 04             	sub    $0x4,%esp
  80190f:	68 07 04 00 00       	push   $0x407
  801914:	ff 75 f0             	pushl  -0x10(%ebp)
  801917:	6a 00                	push   $0x0
  801919:	e8 c6 f3 ff ff       	call   800ce4 <sys_page_alloc>
  80191e:	89 c3                	mov    %eax,%ebx
  801920:	83 c4 10             	add    $0x10,%esp
  801923:	85 c0                	test   %eax,%eax
  801925:	0f 88 c3 00 00 00    	js     8019ee <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80192b:	83 ec 0c             	sub    $0xc,%esp
  80192e:	ff 75 f4             	pushl  -0xc(%ebp)
  801931:	e8 af f5 ff ff       	call   800ee5 <fd2data>
  801936:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801938:	83 c4 0c             	add    $0xc,%esp
  80193b:	68 07 04 00 00       	push   $0x407
  801940:	50                   	push   %eax
  801941:	6a 00                	push   $0x0
  801943:	e8 9c f3 ff ff       	call   800ce4 <sys_page_alloc>
  801948:	89 c3                	mov    %eax,%ebx
  80194a:	83 c4 10             	add    $0x10,%esp
  80194d:	85 c0                	test   %eax,%eax
  80194f:	0f 88 89 00 00 00    	js     8019de <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801955:	83 ec 0c             	sub    $0xc,%esp
  801958:	ff 75 f0             	pushl  -0x10(%ebp)
  80195b:	e8 85 f5 ff ff       	call   800ee5 <fd2data>
  801960:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801967:	50                   	push   %eax
  801968:	6a 00                	push   $0x0
  80196a:	56                   	push   %esi
  80196b:	6a 00                	push   $0x0
  80196d:	e8 b5 f3 ff ff       	call   800d27 <sys_page_map>
  801972:	89 c3                	mov    %eax,%ebx
  801974:	83 c4 20             	add    $0x20,%esp
  801977:	85 c0                	test   %eax,%eax
  801979:	78 55                	js     8019d0 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80197b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801981:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801984:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801986:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801989:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801990:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801996:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801999:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80199b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80199e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8019a5:	83 ec 0c             	sub    $0xc,%esp
  8019a8:	ff 75 f4             	pushl  -0xc(%ebp)
  8019ab:	e8 25 f5 ff ff       	call   800ed5 <fd2num>
  8019b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019b3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8019b5:	83 c4 04             	add    $0x4,%esp
  8019b8:	ff 75 f0             	pushl  -0x10(%ebp)
  8019bb:	e8 15 f5 ff ff       	call   800ed5 <fd2num>
  8019c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019c3:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8019c6:	83 c4 10             	add    $0x10,%esp
  8019c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ce:	eb 30                	jmp    801a00 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8019d0:	83 ec 08             	sub    $0x8,%esp
  8019d3:	56                   	push   %esi
  8019d4:	6a 00                	push   $0x0
  8019d6:	e8 8e f3 ff ff       	call   800d69 <sys_page_unmap>
  8019db:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8019de:	83 ec 08             	sub    $0x8,%esp
  8019e1:	ff 75 f0             	pushl  -0x10(%ebp)
  8019e4:	6a 00                	push   $0x0
  8019e6:	e8 7e f3 ff ff       	call   800d69 <sys_page_unmap>
  8019eb:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8019ee:	83 ec 08             	sub    $0x8,%esp
  8019f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8019f4:	6a 00                	push   $0x0
  8019f6:	e8 6e f3 ff ff       	call   800d69 <sys_page_unmap>
  8019fb:	83 c4 10             	add    $0x10,%esp
  8019fe:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801a00:	89 d0                	mov    %edx,%eax
  801a02:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a05:	5b                   	pop    %ebx
  801a06:	5e                   	pop    %esi
  801a07:	5d                   	pop    %ebp
  801a08:	c3                   	ret    

00801a09 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801a09:	55                   	push   %ebp
  801a0a:	89 e5                	mov    %esp,%ebp
  801a0c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a0f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a12:	50                   	push   %eax
  801a13:	ff 75 08             	pushl  0x8(%ebp)
  801a16:	e8 30 f5 ff ff       	call   800f4b <fd_lookup>
  801a1b:	83 c4 10             	add    $0x10,%esp
  801a1e:	85 c0                	test   %eax,%eax
  801a20:	78 18                	js     801a3a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801a22:	83 ec 0c             	sub    $0xc,%esp
  801a25:	ff 75 f4             	pushl  -0xc(%ebp)
  801a28:	e8 b8 f4 ff ff       	call   800ee5 <fd2data>
	return _pipeisclosed(fd, p);
  801a2d:	89 c2                	mov    %eax,%edx
  801a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a32:	e8 21 fd ff ff       	call   801758 <_pipeisclosed>
  801a37:	83 c4 10             	add    $0x10,%esp
}
  801a3a:	c9                   	leave  
  801a3b:	c3                   	ret    

00801a3c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a3c:	55                   	push   %ebp
  801a3d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801a3f:	b8 00 00 00 00       	mov    $0x0,%eax
  801a44:	5d                   	pop    %ebp
  801a45:	c3                   	ret    

00801a46 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a46:	55                   	push   %ebp
  801a47:	89 e5                	mov    %esp,%ebp
  801a49:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a4c:	68 6e 24 80 00       	push   $0x80246e
  801a51:	ff 75 0c             	pushl  0xc(%ebp)
  801a54:	e8 88 ee ff ff       	call   8008e1 <strcpy>
	return 0;
}
  801a59:	b8 00 00 00 00       	mov    $0x0,%eax
  801a5e:	c9                   	leave  
  801a5f:	c3                   	ret    

00801a60 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	57                   	push   %edi
  801a64:	56                   	push   %esi
  801a65:	53                   	push   %ebx
  801a66:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a6c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a71:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a77:	eb 2d                	jmp    801aa6 <devcons_write+0x46>
		m = n - tot;
  801a79:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a7c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801a7e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801a81:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801a86:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a89:	83 ec 04             	sub    $0x4,%esp
  801a8c:	53                   	push   %ebx
  801a8d:	03 45 0c             	add    0xc(%ebp),%eax
  801a90:	50                   	push   %eax
  801a91:	57                   	push   %edi
  801a92:	e8 dc ef ff ff       	call   800a73 <memmove>
		sys_cputs(buf, m);
  801a97:	83 c4 08             	add    $0x8,%esp
  801a9a:	53                   	push   %ebx
  801a9b:	57                   	push   %edi
  801a9c:	e8 87 f1 ff ff       	call   800c28 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801aa1:	01 de                	add    %ebx,%esi
  801aa3:	83 c4 10             	add    $0x10,%esp
  801aa6:	89 f0                	mov    %esi,%eax
  801aa8:	3b 75 10             	cmp    0x10(%ebp),%esi
  801aab:	72 cc                	jb     801a79 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801aad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab0:	5b                   	pop    %ebx
  801ab1:	5e                   	pop    %esi
  801ab2:	5f                   	pop    %edi
  801ab3:	5d                   	pop    %ebp
  801ab4:	c3                   	ret    

00801ab5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ab5:	55                   	push   %ebp
  801ab6:	89 e5                	mov    %esp,%ebp
  801ab8:	83 ec 08             	sub    $0x8,%esp
  801abb:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ac0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ac4:	74 2a                	je     801af0 <devcons_read+0x3b>
  801ac6:	eb 05                	jmp    801acd <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ac8:	e8 f8 f1 ff ff       	call   800cc5 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801acd:	e8 74 f1 ff ff       	call   800c46 <sys_cgetc>
  801ad2:	85 c0                	test   %eax,%eax
  801ad4:	74 f2                	je     801ac8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ad6:	85 c0                	test   %eax,%eax
  801ad8:	78 16                	js     801af0 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ada:	83 f8 04             	cmp    $0x4,%eax
  801add:	74 0c                	je     801aeb <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801adf:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ae2:	88 02                	mov    %al,(%edx)
	return 1;
  801ae4:	b8 01 00 00 00       	mov    $0x1,%eax
  801ae9:	eb 05                	jmp    801af0 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801aeb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801af0:	c9                   	leave  
  801af1:	c3                   	ret    

00801af2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801af2:	55                   	push   %ebp
  801af3:	89 e5                	mov    %esp,%ebp
  801af5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801af8:	8b 45 08             	mov    0x8(%ebp),%eax
  801afb:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801afe:	6a 01                	push   $0x1
  801b00:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b03:	50                   	push   %eax
  801b04:	e8 1f f1 ff ff       	call   800c28 <sys_cputs>
}
  801b09:	83 c4 10             	add    $0x10,%esp
  801b0c:	c9                   	leave  
  801b0d:	c3                   	ret    

00801b0e <getchar>:

int
getchar(void)
{
  801b0e:	55                   	push   %ebp
  801b0f:	89 e5                	mov    %esp,%ebp
  801b11:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801b14:	6a 01                	push   $0x1
  801b16:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b19:	50                   	push   %eax
  801b1a:	6a 00                	push   $0x0
  801b1c:	e8 90 f6 ff ff       	call   8011b1 <read>
	if (r < 0)
  801b21:	83 c4 10             	add    $0x10,%esp
  801b24:	85 c0                	test   %eax,%eax
  801b26:	78 0f                	js     801b37 <getchar+0x29>
		return r;
	if (r < 1)
  801b28:	85 c0                	test   %eax,%eax
  801b2a:	7e 06                	jle    801b32 <getchar+0x24>
		return -E_EOF;
	return c;
  801b2c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b30:	eb 05                	jmp    801b37 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801b32:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b37:	c9                   	leave  
  801b38:	c3                   	ret    

00801b39 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b39:	55                   	push   %ebp
  801b3a:	89 e5                	mov    %esp,%ebp
  801b3c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b3f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b42:	50                   	push   %eax
  801b43:	ff 75 08             	pushl  0x8(%ebp)
  801b46:	e8 00 f4 ff ff       	call   800f4b <fd_lookup>
  801b4b:	83 c4 10             	add    $0x10,%esp
  801b4e:	85 c0                	test   %eax,%eax
  801b50:	78 11                	js     801b63 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b55:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b5b:	39 10                	cmp    %edx,(%eax)
  801b5d:	0f 94 c0             	sete   %al
  801b60:	0f b6 c0             	movzbl %al,%eax
}
  801b63:	c9                   	leave  
  801b64:	c3                   	ret    

00801b65 <opencons>:

int
opencons(void)
{
  801b65:	55                   	push   %ebp
  801b66:	89 e5                	mov    %esp,%ebp
  801b68:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b6b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b6e:	50                   	push   %eax
  801b6f:	e8 88 f3 ff ff       	call   800efc <fd_alloc>
  801b74:	83 c4 10             	add    $0x10,%esp
		return r;
  801b77:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b79:	85 c0                	test   %eax,%eax
  801b7b:	78 3e                	js     801bbb <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b7d:	83 ec 04             	sub    $0x4,%esp
  801b80:	68 07 04 00 00       	push   $0x407
  801b85:	ff 75 f4             	pushl  -0xc(%ebp)
  801b88:	6a 00                	push   $0x0
  801b8a:	e8 55 f1 ff ff       	call   800ce4 <sys_page_alloc>
  801b8f:	83 c4 10             	add    $0x10,%esp
		return r;
  801b92:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b94:	85 c0                	test   %eax,%eax
  801b96:	78 23                	js     801bbb <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b98:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801bad:	83 ec 0c             	sub    $0xc,%esp
  801bb0:	50                   	push   %eax
  801bb1:	e8 1f f3 ff ff       	call   800ed5 <fd2num>
  801bb6:	89 c2                	mov    %eax,%edx
  801bb8:	83 c4 10             	add    $0x10,%esp
}
  801bbb:	89 d0                	mov    %edx,%eax
  801bbd:	c9                   	leave  
  801bbe:	c3                   	ret    

00801bbf <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801bbf:	55                   	push   %ebp
  801bc0:	89 e5                	mov    %esp,%ebp
  801bc2:	56                   	push   %esi
  801bc3:	53                   	push   %ebx
  801bc4:	8b 75 08             	mov    0x8(%ebp),%esi
  801bc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801bcd:	85 c0                	test   %eax,%eax
  801bcf:	75 12                	jne    801be3 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801bd1:	83 ec 0c             	sub    $0xc,%esp
  801bd4:	68 00 00 c0 ee       	push   $0xeec00000
  801bd9:	e8 b6 f2 ff ff       	call   800e94 <sys_ipc_recv>
  801bde:	83 c4 10             	add    $0x10,%esp
  801be1:	eb 0c                	jmp    801bef <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801be3:	83 ec 0c             	sub    $0xc,%esp
  801be6:	50                   	push   %eax
  801be7:	e8 a8 f2 ff ff       	call   800e94 <sys_ipc_recv>
  801bec:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801bef:	85 f6                	test   %esi,%esi
  801bf1:	0f 95 c1             	setne  %cl
  801bf4:	85 db                	test   %ebx,%ebx
  801bf6:	0f 95 c2             	setne  %dl
  801bf9:	84 d1                	test   %dl,%cl
  801bfb:	74 09                	je     801c06 <ipc_recv+0x47>
  801bfd:	89 c2                	mov    %eax,%edx
  801bff:	c1 ea 1f             	shr    $0x1f,%edx
  801c02:	84 d2                	test   %dl,%dl
  801c04:	75 24                	jne    801c2a <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801c06:	85 f6                	test   %esi,%esi
  801c08:	74 0a                	je     801c14 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801c0a:	a1 04 40 80 00       	mov    0x804004,%eax
  801c0f:	8b 40 74             	mov    0x74(%eax),%eax
  801c12:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801c14:	85 db                	test   %ebx,%ebx
  801c16:	74 0a                	je     801c22 <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  801c18:	a1 04 40 80 00       	mov    0x804004,%eax
  801c1d:	8b 40 78             	mov    0x78(%eax),%eax
  801c20:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801c22:	a1 04 40 80 00       	mov    0x804004,%eax
  801c27:	8b 40 70             	mov    0x70(%eax),%eax
}
  801c2a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c2d:	5b                   	pop    %ebx
  801c2e:	5e                   	pop    %esi
  801c2f:	5d                   	pop    %ebp
  801c30:	c3                   	ret    

00801c31 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c31:	55                   	push   %ebp
  801c32:	89 e5                	mov    %esp,%ebp
  801c34:	57                   	push   %edi
  801c35:	56                   	push   %esi
  801c36:	53                   	push   %ebx
  801c37:	83 ec 0c             	sub    $0xc,%esp
  801c3a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c3d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c40:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801c43:	85 db                	test   %ebx,%ebx
  801c45:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801c4a:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801c4d:	ff 75 14             	pushl  0x14(%ebp)
  801c50:	53                   	push   %ebx
  801c51:	56                   	push   %esi
  801c52:	57                   	push   %edi
  801c53:	e8 19 f2 ff ff       	call   800e71 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801c58:	89 c2                	mov    %eax,%edx
  801c5a:	c1 ea 1f             	shr    $0x1f,%edx
  801c5d:	83 c4 10             	add    $0x10,%esp
  801c60:	84 d2                	test   %dl,%dl
  801c62:	74 17                	je     801c7b <ipc_send+0x4a>
  801c64:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c67:	74 12                	je     801c7b <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801c69:	50                   	push   %eax
  801c6a:	68 7a 24 80 00       	push   $0x80247a
  801c6f:	6a 47                	push   $0x47
  801c71:	68 88 24 80 00       	push   $0x802488
  801c76:	e8 08 e6 ff ff       	call   800283 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801c7b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c7e:	75 07                	jne    801c87 <ipc_send+0x56>
			sys_yield();
  801c80:	e8 40 f0 ff ff       	call   800cc5 <sys_yield>
  801c85:	eb c6                	jmp    801c4d <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801c87:	85 c0                	test   %eax,%eax
  801c89:	75 c2                	jne    801c4d <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801c8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c8e:	5b                   	pop    %ebx
  801c8f:	5e                   	pop    %esi
  801c90:	5f                   	pop    %edi
  801c91:	5d                   	pop    %ebp
  801c92:	c3                   	ret    

00801c93 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c93:	55                   	push   %ebp
  801c94:	89 e5                	mov    %esp,%ebp
  801c96:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c99:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c9e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ca1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ca7:	8b 52 50             	mov    0x50(%edx),%edx
  801caa:	39 ca                	cmp    %ecx,%edx
  801cac:	75 0d                	jne    801cbb <ipc_find_env+0x28>
			return envs[i].env_id;
  801cae:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801cb1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801cb6:	8b 40 48             	mov    0x48(%eax),%eax
  801cb9:	eb 0f                	jmp    801cca <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801cbb:	83 c0 01             	add    $0x1,%eax
  801cbe:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cc3:	75 d9                	jne    801c9e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801cc5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cca:	5d                   	pop    %ebp
  801ccb:	c3                   	ret    

00801ccc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ccc:	55                   	push   %ebp
  801ccd:	89 e5                	mov    %esp,%ebp
  801ccf:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cd2:	89 d0                	mov    %edx,%eax
  801cd4:	c1 e8 16             	shr    $0x16,%eax
  801cd7:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801cde:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ce3:	f6 c1 01             	test   $0x1,%cl
  801ce6:	74 1d                	je     801d05 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ce8:	c1 ea 0c             	shr    $0xc,%edx
  801ceb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801cf2:	f6 c2 01             	test   $0x1,%dl
  801cf5:	74 0e                	je     801d05 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801cf7:	c1 ea 0c             	shr    $0xc,%edx
  801cfa:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d01:	ef 
  801d02:	0f b7 c0             	movzwl %ax,%eax
}
  801d05:	5d                   	pop    %ebp
  801d06:	c3                   	ret    
  801d07:	66 90                	xchg   %ax,%ax
  801d09:	66 90                	xchg   %ax,%ax
  801d0b:	66 90                	xchg   %ax,%ax
  801d0d:	66 90                	xchg   %ax,%ax
  801d0f:	90                   	nop

00801d10 <__udivdi3>:
  801d10:	55                   	push   %ebp
  801d11:	57                   	push   %edi
  801d12:	56                   	push   %esi
  801d13:	53                   	push   %ebx
  801d14:	83 ec 1c             	sub    $0x1c,%esp
  801d17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801d1b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801d1f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801d23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d27:	85 f6                	test   %esi,%esi
  801d29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d2d:	89 ca                	mov    %ecx,%edx
  801d2f:	89 f8                	mov    %edi,%eax
  801d31:	75 3d                	jne    801d70 <__udivdi3+0x60>
  801d33:	39 cf                	cmp    %ecx,%edi
  801d35:	0f 87 c5 00 00 00    	ja     801e00 <__udivdi3+0xf0>
  801d3b:	85 ff                	test   %edi,%edi
  801d3d:	89 fd                	mov    %edi,%ebp
  801d3f:	75 0b                	jne    801d4c <__udivdi3+0x3c>
  801d41:	b8 01 00 00 00       	mov    $0x1,%eax
  801d46:	31 d2                	xor    %edx,%edx
  801d48:	f7 f7                	div    %edi
  801d4a:	89 c5                	mov    %eax,%ebp
  801d4c:	89 c8                	mov    %ecx,%eax
  801d4e:	31 d2                	xor    %edx,%edx
  801d50:	f7 f5                	div    %ebp
  801d52:	89 c1                	mov    %eax,%ecx
  801d54:	89 d8                	mov    %ebx,%eax
  801d56:	89 cf                	mov    %ecx,%edi
  801d58:	f7 f5                	div    %ebp
  801d5a:	89 c3                	mov    %eax,%ebx
  801d5c:	89 d8                	mov    %ebx,%eax
  801d5e:	89 fa                	mov    %edi,%edx
  801d60:	83 c4 1c             	add    $0x1c,%esp
  801d63:	5b                   	pop    %ebx
  801d64:	5e                   	pop    %esi
  801d65:	5f                   	pop    %edi
  801d66:	5d                   	pop    %ebp
  801d67:	c3                   	ret    
  801d68:	90                   	nop
  801d69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d70:	39 ce                	cmp    %ecx,%esi
  801d72:	77 74                	ja     801de8 <__udivdi3+0xd8>
  801d74:	0f bd fe             	bsr    %esi,%edi
  801d77:	83 f7 1f             	xor    $0x1f,%edi
  801d7a:	0f 84 98 00 00 00    	je     801e18 <__udivdi3+0x108>
  801d80:	bb 20 00 00 00       	mov    $0x20,%ebx
  801d85:	89 f9                	mov    %edi,%ecx
  801d87:	89 c5                	mov    %eax,%ebp
  801d89:	29 fb                	sub    %edi,%ebx
  801d8b:	d3 e6                	shl    %cl,%esi
  801d8d:	89 d9                	mov    %ebx,%ecx
  801d8f:	d3 ed                	shr    %cl,%ebp
  801d91:	89 f9                	mov    %edi,%ecx
  801d93:	d3 e0                	shl    %cl,%eax
  801d95:	09 ee                	or     %ebp,%esi
  801d97:	89 d9                	mov    %ebx,%ecx
  801d99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d9d:	89 d5                	mov    %edx,%ebp
  801d9f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801da3:	d3 ed                	shr    %cl,%ebp
  801da5:	89 f9                	mov    %edi,%ecx
  801da7:	d3 e2                	shl    %cl,%edx
  801da9:	89 d9                	mov    %ebx,%ecx
  801dab:	d3 e8                	shr    %cl,%eax
  801dad:	09 c2                	or     %eax,%edx
  801daf:	89 d0                	mov    %edx,%eax
  801db1:	89 ea                	mov    %ebp,%edx
  801db3:	f7 f6                	div    %esi
  801db5:	89 d5                	mov    %edx,%ebp
  801db7:	89 c3                	mov    %eax,%ebx
  801db9:	f7 64 24 0c          	mull   0xc(%esp)
  801dbd:	39 d5                	cmp    %edx,%ebp
  801dbf:	72 10                	jb     801dd1 <__udivdi3+0xc1>
  801dc1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801dc5:	89 f9                	mov    %edi,%ecx
  801dc7:	d3 e6                	shl    %cl,%esi
  801dc9:	39 c6                	cmp    %eax,%esi
  801dcb:	73 07                	jae    801dd4 <__udivdi3+0xc4>
  801dcd:	39 d5                	cmp    %edx,%ebp
  801dcf:	75 03                	jne    801dd4 <__udivdi3+0xc4>
  801dd1:	83 eb 01             	sub    $0x1,%ebx
  801dd4:	31 ff                	xor    %edi,%edi
  801dd6:	89 d8                	mov    %ebx,%eax
  801dd8:	89 fa                	mov    %edi,%edx
  801dda:	83 c4 1c             	add    $0x1c,%esp
  801ddd:	5b                   	pop    %ebx
  801dde:	5e                   	pop    %esi
  801ddf:	5f                   	pop    %edi
  801de0:	5d                   	pop    %ebp
  801de1:	c3                   	ret    
  801de2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801de8:	31 ff                	xor    %edi,%edi
  801dea:	31 db                	xor    %ebx,%ebx
  801dec:	89 d8                	mov    %ebx,%eax
  801dee:	89 fa                	mov    %edi,%edx
  801df0:	83 c4 1c             	add    $0x1c,%esp
  801df3:	5b                   	pop    %ebx
  801df4:	5e                   	pop    %esi
  801df5:	5f                   	pop    %edi
  801df6:	5d                   	pop    %ebp
  801df7:	c3                   	ret    
  801df8:	90                   	nop
  801df9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e00:	89 d8                	mov    %ebx,%eax
  801e02:	f7 f7                	div    %edi
  801e04:	31 ff                	xor    %edi,%edi
  801e06:	89 c3                	mov    %eax,%ebx
  801e08:	89 d8                	mov    %ebx,%eax
  801e0a:	89 fa                	mov    %edi,%edx
  801e0c:	83 c4 1c             	add    $0x1c,%esp
  801e0f:	5b                   	pop    %ebx
  801e10:	5e                   	pop    %esi
  801e11:	5f                   	pop    %edi
  801e12:	5d                   	pop    %ebp
  801e13:	c3                   	ret    
  801e14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e18:	39 ce                	cmp    %ecx,%esi
  801e1a:	72 0c                	jb     801e28 <__udivdi3+0x118>
  801e1c:	31 db                	xor    %ebx,%ebx
  801e1e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801e22:	0f 87 34 ff ff ff    	ja     801d5c <__udivdi3+0x4c>
  801e28:	bb 01 00 00 00       	mov    $0x1,%ebx
  801e2d:	e9 2a ff ff ff       	jmp    801d5c <__udivdi3+0x4c>
  801e32:	66 90                	xchg   %ax,%ax
  801e34:	66 90                	xchg   %ax,%ax
  801e36:	66 90                	xchg   %ax,%ax
  801e38:	66 90                	xchg   %ax,%ax
  801e3a:	66 90                	xchg   %ax,%ax
  801e3c:	66 90                	xchg   %ax,%ax
  801e3e:	66 90                	xchg   %ax,%ax

00801e40 <__umoddi3>:
  801e40:	55                   	push   %ebp
  801e41:	57                   	push   %edi
  801e42:	56                   	push   %esi
  801e43:	53                   	push   %ebx
  801e44:	83 ec 1c             	sub    $0x1c,%esp
  801e47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801e4b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801e4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801e53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e57:	85 d2                	test   %edx,%edx
  801e59:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e61:	89 f3                	mov    %esi,%ebx
  801e63:	89 3c 24             	mov    %edi,(%esp)
  801e66:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e6a:	75 1c                	jne    801e88 <__umoddi3+0x48>
  801e6c:	39 f7                	cmp    %esi,%edi
  801e6e:	76 50                	jbe    801ec0 <__umoddi3+0x80>
  801e70:	89 c8                	mov    %ecx,%eax
  801e72:	89 f2                	mov    %esi,%edx
  801e74:	f7 f7                	div    %edi
  801e76:	89 d0                	mov    %edx,%eax
  801e78:	31 d2                	xor    %edx,%edx
  801e7a:	83 c4 1c             	add    $0x1c,%esp
  801e7d:	5b                   	pop    %ebx
  801e7e:	5e                   	pop    %esi
  801e7f:	5f                   	pop    %edi
  801e80:	5d                   	pop    %ebp
  801e81:	c3                   	ret    
  801e82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e88:	39 f2                	cmp    %esi,%edx
  801e8a:	89 d0                	mov    %edx,%eax
  801e8c:	77 52                	ja     801ee0 <__umoddi3+0xa0>
  801e8e:	0f bd ea             	bsr    %edx,%ebp
  801e91:	83 f5 1f             	xor    $0x1f,%ebp
  801e94:	75 5a                	jne    801ef0 <__umoddi3+0xb0>
  801e96:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801e9a:	0f 82 e0 00 00 00    	jb     801f80 <__umoddi3+0x140>
  801ea0:	39 0c 24             	cmp    %ecx,(%esp)
  801ea3:	0f 86 d7 00 00 00    	jbe    801f80 <__umoddi3+0x140>
  801ea9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ead:	8b 54 24 04          	mov    0x4(%esp),%edx
  801eb1:	83 c4 1c             	add    $0x1c,%esp
  801eb4:	5b                   	pop    %ebx
  801eb5:	5e                   	pop    %esi
  801eb6:	5f                   	pop    %edi
  801eb7:	5d                   	pop    %ebp
  801eb8:	c3                   	ret    
  801eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ec0:	85 ff                	test   %edi,%edi
  801ec2:	89 fd                	mov    %edi,%ebp
  801ec4:	75 0b                	jne    801ed1 <__umoddi3+0x91>
  801ec6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ecb:	31 d2                	xor    %edx,%edx
  801ecd:	f7 f7                	div    %edi
  801ecf:	89 c5                	mov    %eax,%ebp
  801ed1:	89 f0                	mov    %esi,%eax
  801ed3:	31 d2                	xor    %edx,%edx
  801ed5:	f7 f5                	div    %ebp
  801ed7:	89 c8                	mov    %ecx,%eax
  801ed9:	f7 f5                	div    %ebp
  801edb:	89 d0                	mov    %edx,%eax
  801edd:	eb 99                	jmp    801e78 <__umoddi3+0x38>
  801edf:	90                   	nop
  801ee0:	89 c8                	mov    %ecx,%eax
  801ee2:	89 f2                	mov    %esi,%edx
  801ee4:	83 c4 1c             	add    $0x1c,%esp
  801ee7:	5b                   	pop    %ebx
  801ee8:	5e                   	pop    %esi
  801ee9:	5f                   	pop    %edi
  801eea:	5d                   	pop    %ebp
  801eeb:	c3                   	ret    
  801eec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ef0:	8b 34 24             	mov    (%esp),%esi
  801ef3:	bf 20 00 00 00       	mov    $0x20,%edi
  801ef8:	89 e9                	mov    %ebp,%ecx
  801efa:	29 ef                	sub    %ebp,%edi
  801efc:	d3 e0                	shl    %cl,%eax
  801efe:	89 f9                	mov    %edi,%ecx
  801f00:	89 f2                	mov    %esi,%edx
  801f02:	d3 ea                	shr    %cl,%edx
  801f04:	89 e9                	mov    %ebp,%ecx
  801f06:	09 c2                	or     %eax,%edx
  801f08:	89 d8                	mov    %ebx,%eax
  801f0a:	89 14 24             	mov    %edx,(%esp)
  801f0d:	89 f2                	mov    %esi,%edx
  801f0f:	d3 e2                	shl    %cl,%edx
  801f11:	89 f9                	mov    %edi,%ecx
  801f13:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f17:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801f1b:	d3 e8                	shr    %cl,%eax
  801f1d:	89 e9                	mov    %ebp,%ecx
  801f1f:	89 c6                	mov    %eax,%esi
  801f21:	d3 e3                	shl    %cl,%ebx
  801f23:	89 f9                	mov    %edi,%ecx
  801f25:	89 d0                	mov    %edx,%eax
  801f27:	d3 e8                	shr    %cl,%eax
  801f29:	89 e9                	mov    %ebp,%ecx
  801f2b:	09 d8                	or     %ebx,%eax
  801f2d:	89 d3                	mov    %edx,%ebx
  801f2f:	89 f2                	mov    %esi,%edx
  801f31:	f7 34 24             	divl   (%esp)
  801f34:	89 d6                	mov    %edx,%esi
  801f36:	d3 e3                	shl    %cl,%ebx
  801f38:	f7 64 24 04          	mull   0x4(%esp)
  801f3c:	39 d6                	cmp    %edx,%esi
  801f3e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f42:	89 d1                	mov    %edx,%ecx
  801f44:	89 c3                	mov    %eax,%ebx
  801f46:	72 08                	jb     801f50 <__umoddi3+0x110>
  801f48:	75 11                	jne    801f5b <__umoddi3+0x11b>
  801f4a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801f4e:	73 0b                	jae    801f5b <__umoddi3+0x11b>
  801f50:	2b 44 24 04          	sub    0x4(%esp),%eax
  801f54:	1b 14 24             	sbb    (%esp),%edx
  801f57:	89 d1                	mov    %edx,%ecx
  801f59:	89 c3                	mov    %eax,%ebx
  801f5b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801f5f:	29 da                	sub    %ebx,%edx
  801f61:	19 ce                	sbb    %ecx,%esi
  801f63:	89 f9                	mov    %edi,%ecx
  801f65:	89 f0                	mov    %esi,%eax
  801f67:	d3 e0                	shl    %cl,%eax
  801f69:	89 e9                	mov    %ebp,%ecx
  801f6b:	d3 ea                	shr    %cl,%edx
  801f6d:	89 e9                	mov    %ebp,%ecx
  801f6f:	d3 ee                	shr    %cl,%esi
  801f71:	09 d0                	or     %edx,%eax
  801f73:	89 f2                	mov    %esi,%edx
  801f75:	83 c4 1c             	add    $0x1c,%esp
  801f78:	5b                   	pop    %ebx
  801f79:	5e                   	pop    %esi
  801f7a:	5f                   	pop    %edi
  801f7b:	5d                   	pop    %ebp
  801f7c:	c3                   	ret    
  801f7d:	8d 76 00             	lea    0x0(%esi),%esi
  801f80:	29 f9                	sub    %edi,%ecx
  801f82:	19 d6                	sbb    %edx,%esi
  801f84:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f88:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f8c:	e9 18 ff ff ff       	jmp    801ea9 <__umoddi3+0x69>
