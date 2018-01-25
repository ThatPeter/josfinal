
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
  800045:	e8 7a 0c 00 00       	call   800cc4 <sys_page_alloc>
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800051:	50                   	push   %eax
  800052:	68 60 23 80 00       	push   $0x802360
  800057:	6a 20                	push   $0x20
  800059:	68 73 23 80 00       	push   $0x802373
  80005e:	e8 00 02 00 00       	call   800263 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800063:	83 ec 0c             	sub    $0xc,%esp
  800066:	6a 07                	push   $0x7
  800068:	68 00 00 40 00       	push   $0x400000
  80006d:	6a 00                	push   $0x0
  80006f:	53                   	push   %ebx
  800070:	56                   	push   %esi
  800071:	e8 91 0c 00 00       	call   800d07 <sys_page_map>
  800076:	83 c4 20             	add    $0x20,%esp
  800079:	85 c0                	test   %eax,%eax
  80007b:	79 12                	jns    80008f <duppage+0x5c>
		panic("sys_page_map: %e", r);
  80007d:	50                   	push   %eax
  80007e:	68 83 23 80 00       	push   $0x802383
  800083:	6a 22                	push   $0x22
  800085:	68 73 23 80 00       	push   $0x802373
  80008a:	e8 d4 01 00 00       	call   800263 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  80008f:	83 ec 04             	sub    $0x4,%esp
  800092:	68 00 10 00 00       	push   $0x1000
  800097:	53                   	push   %ebx
  800098:	68 00 00 40 00       	push   $0x400000
  80009d:	e8 b1 09 00 00       	call   800a53 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	68 00 00 40 00       	push   $0x400000
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 98 0c 00 00       	call   800d49 <sys_page_unmap>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	79 12                	jns    8000ca <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  8000b8:	50                   	push   %eax
  8000b9:	68 94 23 80 00       	push   $0x802394
  8000be:	6a 25                	push   $0x25
  8000c0:	68 73 23 80 00       	push   $0x802373
  8000c5:	e8 99 01 00 00       	call   800263 <_panic>
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
  8000e7:	68 a7 23 80 00       	push   $0x8023a7
  8000ec:	6a 37                	push   $0x37
  8000ee:	68 73 23 80 00       	push   $0x802373
  8000f3:	e8 6b 01 00 00       	call   800263 <_panic>
  8000f8:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	75 22                	jne    800120 <dumbfork+0x4f>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8000fe:	e8 83 0b 00 00       	call   800c86 <sys_getenvid>
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
  800108:	89 c2                	mov    %eax,%edx
  80010a:	c1 e2 07             	shl    $0x7,%edx
  80010d:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
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
  800140:	81 fa 04 60 80 00    	cmp    $0x806004,%edx
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
  800160:	e8 26 0c 00 00       	call   800d8b <sys_env_set_status>
  800165:	83 c4 10             	add    $0x10,%esp
  800168:	85 c0                	test   %eax,%eax
  80016a:	79 12                	jns    80017e <dumbfork+0xad>
		panic("sys_env_set_status: %e", r);
  80016c:	50                   	push   %eax
  80016d:	68 b7 23 80 00       	push   $0x8023b7
  800172:	6a 4c                	push   $0x4c
  800174:	68 73 23 80 00       	push   $0x802373
  800179:	e8 e5 00 00 00       	call   800263 <_panic>

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
  800199:	be d5 23 80 00       	mov    $0x8023d5,%esi
  80019e:	b8 ce 23 80 00       	mov    $0x8023ce,%eax
  8001a3:	0f 45 f0             	cmovne %eax,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ab:	eb 1a                	jmp    8001c7 <umain+0x40>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001ad:	83 ec 04             	sub    $0x4,%esp
  8001b0:	56                   	push   %esi
  8001b1:	53                   	push   %ebx
  8001b2:	68 db 23 80 00       	push   $0x8023db
  8001b7:	e8 80 01 00 00       	call   80033c <cprintf>
		sys_yield();
  8001bc:	e8 e4 0a 00 00       	call   800ca5 <sys_yield>

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
  8001e2:	56                   	push   %esi
  8001e3:	53                   	push   %ebx
  8001e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001e7:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001ea:	e8 97 0a 00 00       	call   800c86 <sys_getenvid>
  8001ef:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f4:	89 c2                	mov    %eax,%edx
  8001f6:	c1 e2 07             	shl    $0x7,%edx
  8001f9:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800200:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800205:	85 db                	test   %ebx,%ebx
  800207:	7e 07                	jle    800210 <libmain+0x31>
		binaryname = argv[0];
  800209:	8b 06                	mov    (%esi),%eax
  80020b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800210:	83 ec 08             	sub    $0x8,%esp
  800213:	56                   	push   %esi
  800214:	53                   	push   %ebx
  800215:	e8 6d ff ff ff       	call   800187 <umain>

	// exit gracefully
	exit();
  80021a:	e8 2a 00 00 00       	call   800249 <exit>
}
  80021f:	83 c4 10             	add    $0x10,%esp
  800222:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800225:	5b                   	pop    %ebx
  800226:	5e                   	pop    %esi
  800227:	5d                   	pop    %ebp
  800228:	c3                   	ret    

00800229 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  80022f:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  800234:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800236:	e8 4b 0a 00 00       	call   800c86 <sys_getenvid>
  80023b:	83 ec 0c             	sub    $0xc,%esp
  80023e:	50                   	push   %eax
  80023f:	e8 91 0c 00 00       	call   800ed5 <sys_thread_free>
}
  800244:	83 c4 10             	add    $0x10,%esp
  800247:	c9                   	leave  
  800248:	c3                   	ret    

00800249 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800249:	55                   	push   %ebp
  80024a:	89 e5                	mov    %esp,%ebp
  80024c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80024f:	e8 5e 11 00 00       	call   8013b2 <close_all>
	sys_env_destroy(0);
  800254:	83 ec 0c             	sub    $0xc,%esp
  800257:	6a 00                	push   $0x0
  800259:	e8 e7 09 00 00       	call   800c45 <sys_env_destroy>
}
  80025e:	83 c4 10             	add    $0x10,%esp
  800261:	c9                   	leave  
  800262:	c3                   	ret    

00800263 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	56                   	push   %esi
  800267:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800268:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80026b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800271:	e8 10 0a 00 00       	call   800c86 <sys_getenvid>
  800276:	83 ec 0c             	sub    $0xc,%esp
  800279:	ff 75 0c             	pushl  0xc(%ebp)
  80027c:	ff 75 08             	pushl  0x8(%ebp)
  80027f:	56                   	push   %esi
  800280:	50                   	push   %eax
  800281:	68 f8 23 80 00       	push   $0x8023f8
  800286:	e8 b1 00 00 00       	call   80033c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80028b:	83 c4 18             	add    $0x18,%esp
  80028e:	53                   	push   %ebx
  80028f:	ff 75 10             	pushl  0x10(%ebp)
  800292:	e8 54 00 00 00       	call   8002eb <vcprintf>
	cprintf("\n");
  800297:	c7 04 24 eb 23 80 00 	movl   $0x8023eb,(%esp)
  80029e:	e8 99 00 00 00       	call   80033c <cprintf>
  8002a3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002a6:	cc                   	int3   
  8002a7:	eb fd                	jmp    8002a6 <_panic+0x43>

008002a9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	53                   	push   %ebx
  8002ad:	83 ec 04             	sub    $0x4,%esp
  8002b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002b3:	8b 13                	mov    (%ebx),%edx
  8002b5:	8d 42 01             	lea    0x1(%edx),%eax
  8002b8:	89 03                	mov    %eax,(%ebx)
  8002ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002bd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002c1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002c6:	75 1a                	jne    8002e2 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002c8:	83 ec 08             	sub    $0x8,%esp
  8002cb:	68 ff 00 00 00       	push   $0xff
  8002d0:	8d 43 08             	lea    0x8(%ebx),%eax
  8002d3:	50                   	push   %eax
  8002d4:	e8 2f 09 00 00       	call   800c08 <sys_cputs>
		b->idx = 0;
  8002d9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002df:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002e2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002e9:	c9                   	leave  
  8002ea:	c3                   	ret    

008002eb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002f4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002fb:	00 00 00 
	b.cnt = 0;
  8002fe:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800305:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800308:	ff 75 0c             	pushl  0xc(%ebp)
  80030b:	ff 75 08             	pushl  0x8(%ebp)
  80030e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800314:	50                   	push   %eax
  800315:	68 a9 02 80 00       	push   $0x8002a9
  80031a:	e8 54 01 00 00       	call   800473 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80031f:	83 c4 08             	add    $0x8,%esp
  800322:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800328:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80032e:	50                   	push   %eax
  80032f:	e8 d4 08 00 00       	call   800c08 <sys_cputs>

	return b.cnt;
}
  800334:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80033a:	c9                   	leave  
  80033b:	c3                   	ret    

0080033c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80033c:	55                   	push   %ebp
  80033d:	89 e5                	mov    %esp,%ebp
  80033f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800342:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800345:	50                   	push   %eax
  800346:	ff 75 08             	pushl  0x8(%ebp)
  800349:	e8 9d ff ff ff       	call   8002eb <vcprintf>
	va_end(ap);

	return cnt;
}
  80034e:	c9                   	leave  
  80034f:	c3                   	ret    

00800350 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	57                   	push   %edi
  800354:	56                   	push   %esi
  800355:	53                   	push   %ebx
  800356:	83 ec 1c             	sub    $0x1c,%esp
  800359:	89 c7                	mov    %eax,%edi
  80035b:	89 d6                	mov    %edx,%esi
  80035d:	8b 45 08             	mov    0x8(%ebp),%eax
  800360:	8b 55 0c             	mov    0xc(%ebp),%edx
  800363:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800366:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800369:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80036c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800371:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800374:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800377:	39 d3                	cmp    %edx,%ebx
  800379:	72 05                	jb     800380 <printnum+0x30>
  80037b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80037e:	77 45                	ja     8003c5 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800380:	83 ec 0c             	sub    $0xc,%esp
  800383:	ff 75 18             	pushl  0x18(%ebp)
  800386:	8b 45 14             	mov    0x14(%ebp),%eax
  800389:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80038c:	53                   	push   %ebx
  80038d:	ff 75 10             	pushl  0x10(%ebp)
  800390:	83 ec 08             	sub    $0x8,%esp
  800393:	ff 75 e4             	pushl  -0x1c(%ebp)
  800396:	ff 75 e0             	pushl  -0x20(%ebp)
  800399:	ff 75 dc             	pushl  -0x24(%ebp)
  80039c:	ff 75 d8             	pushl  -0x28(%ebp)
  80039f:	e8 1c 1d 00 00       	call   8020c0 <__udivdi3>
  8003a4:	83 c4 18             	add    $0x18,%esp
  8003a7:	52                   	push   %edx
  8003a8:	50                   	push   %eax
  8003a9:	89 f2                	mov    %esi,%edx
  8003ab:	89 f8                	mov    %edi,%eax
  8003ad:	e8 9e ff ff ff       	call   800350 <printnum>
  8003b2:	83 c4 20             	add    $0x20,%esp
  8003b5:	eb 18                	jmp    8003cf <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003b7:	83 ec 08             	sub    $0x8,%esp
  8003ba:	56                   	push   %esi
  8003bb:	ff 75 18             	pushl  0x18(%ebp)
  8003be:	ff d7                	call   *%edi
  8003c0:	83 c4 10             	add    $0x10,%esp
  8003c3:	eb 03                	jmp    8003c8 <printnum+0x78>
  8003c5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003c8:	83 eb 01             	sub    $0x1,%ebx
  8003cb:	85 db                	test   %ebx,%ebx
  8003cd:	7f e8                	jg     8003b7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003cf:	83 ec 08             	sub    $0x8,%esp
  8003d2:	56                   	push   %esi
  8003d3:	83 ec 04             	sub    $0x4,%esp
  8003d6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003d9:	ff 75 e0             	pushl  -0x20(%ebp)
  8003dc:	ff 75 dc             	pushl  -0x24(%ebp)
  8003df:	ff 75 d8             	pushl  -0x28(%ebp)
  8003e2:	e8 09 1e 00 00       	call   8021f0 <__umoddi3>
  8003e7:	83 c4 14             	add    $0x14,%esp
  8003ea:	0f be 80 1b 24 80 00 	movsbl 0x80241b(%eax),%eax
  8003f1:	50                   	push   %eax
  8003f2:	ff d7                	call   *%edi
}
  8003f4:	83 c4 10             	add    $0x10,%esp
  8003f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003fa:	5b                   	pop    %ebx
  8003fb:	5e                   	pop    %esi
  8003fc:	5f                   	pop    %edi
  8003fd:	5d                   	pop    %ebp
  8003fe:	c3                   	ret    

008003ff <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800402:	83 fa 01             	cmp    $0x1,%edx
  800405:	7e 0e                	jle    800415 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800407:	8b 10                	mov    (%eax),%edx
  800409:	8d 4a 08             	lea    0x8(%edx),%ecx
  80040c:	89 08                	mov    %ecx,(%eax)
  80040e:	8b 02                	mov    (%edx),%eax
  800410:	8b 52 04             	mov    0x4(%edx),%edx
  800413:	eb 22                	jmp    800437 <getuint+0x38>
	else if (lflag)
  800415:	85 d2                	test   %edx,%edx
  800417:	74 10                	je     800429 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800419:	8b 10                	mov    (%eax),%edx
  80041b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80041e:	89 08                	mov    %ecx,(%eax)
  800420:	8b 02                	mov    (%edx),%eax
  800422:	ba 00 00 00 00       	mov    $0x0,%edx
  800427:	eb 0e                	jmp    800437 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800429:	8b 10                	mov    (%eax),%edx
  80042b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80042e:	89 08                	mov    %ecx,(%eax)
  800430:	8b 02                	mov    (%edx),%eax
  800432:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800437:	5d                   	pop    %ebp
  800438:	c3                   	ret    

00800439 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800439:	55                   	push   %ebp
  80043a:	89 e5                	mov    %esp,%ebp
  80043c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80043f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800443:	8b 10                	mov    (%eax),%edx
  800445:	3b 50 04             	cmp    0x4(%eax),%edx
  800448:	73 0a                	jae    800454 <sprintputch+0x1b>
		*b->buf++ = ch;
  80044a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80044d:	89 08                	mov    %ecx,(%eax)
  80044f:	8b 45 08             	mov    0x8(%ebp),%eax
  800452:	88 02                	mov    %al,(%edx)
}
  800454:	5d                   	pop    %ebp
  800455:	c3                   	ret    

00800456 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800456:	55                   	push   %ebp
  800457:	89 e5                	mov    %esp,%ebp
  800459:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80045c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80045f:	50                   	push   %eax
  800460:	ff 75 10             	pushl  0x10(%ebp)
  800463:	ff 75 0c             	pushl  0xc(%ebp)
  800466:	ff 75 08             	pushl  0x8(%ebp)
  800469:	e8 05 00 00 00       	call   800473 <vprintfmt>
	va_end(ap);
}
  80046e:	83 c4 10             	add    $0x10,%esp
  800471:	c9                   	leave  
  800472:	c3                   	ret    

00800473 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800473:	55                   	push   %ebp
  800474:	89 e5                	mov    %esp,%ebp
  800476:	57                   	push   %edi
  800477:	56                   	push   %esi
  800478:	53                   	push   %ebx
  800479:	83 ec 2c             	sub    $0x2c,%esp
  80047c:	8b 75 08             	mov    0x8(%ebp),%esi
  80047f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800482:	8b 7d 10             	mov    0x10(%ebp),%edi
  800485:	eb 12                	jmp    800499 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800487:	85 c0                	test   %eax,%eax
  800489:	0f 84 89 03 00 00    	je     800818 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80048f:	83 ec 08             	sub    $0x8,%esp
  800492:	53                   	push   %ebx
  800493:	50                   	push   %eax
  800494:	ff d6                	call   *%esi
  800496:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800499:	83 c7 01             	add    $0x1,%edi
  80049c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004a0:	83 f8 25             	cmp    $0x25,%eax
  8004a3:	75 e2                	jne    800487 <vprintfmt+0x14>
  8004a5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004a9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004b0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004b7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004be:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c3:	eb 07                	jmp    8004cc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004c8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cc:	8d 47 01             	lea    0x1(%edi),%eax
  8004cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004d2:	0f b6 07             	movzbl (%edi),%eax
  8004d5:	0f b6 c8             	movzbl %al,%ecx
  8004d8:	83 e8 23             	sub    $0x23,%eax
  8004db:	3c 55                	cmp    $0x55,%al
  8004dd:	0f 87 1a 03 00 00    	ja     8007fd <vprintfmt+0x38a>
  8004e3:	0f b6 c0             	movzbl %al,%eax
  8004e6:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
  8004ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004f0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004f4:	eb d6                	jmp    8004cc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fe:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800501:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800504:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800508:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80050b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80050e:	83 fa 09             	cmp    $0x9,%edx
  800511:	77 39                	ja     80054c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800513:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800516:	eb e9                	jmp    800501 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800518:	8b 45 14             	mov    0x14(%ebp),%eax
  80051b:	8d 48 04             	lea    0x4(%eax),%ecx
  80051e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800521:	8b 00                	mov    (%eax),%eax
  800523:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800526:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800529:	eb 27                	jmp    800552 <vprintfmt+0xdf>
  80052b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80052e:	85 c0                	test   %eax,%eax
  800530:	b9 00 00 00 00       	mov    $0x0,%ecx
  800535:	0f 49 c8             	cmovns %eax,%ecx
  800538:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80053e:	eb 8c                	jmp    8004cc <vprintfmt+0x59>
  800540:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800543:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80054a:	eb 80                	jmp    8004cc <vprintfmt+0x59>
  80054c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80054f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800552:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800556:	0f 89 70 ff ff ff    	jns    8004cc <vprintfmt+0x59>
				width = precision, precision = -1;
  80055c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80055f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800562:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800569:	e9 5e ff ff ff       	jmp    8004cc <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80056e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800571:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800574:	e9 53 ff ff ff       	jmp    8004cc <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800579:	8b 45 14             	mov    0x14(%ebp),%eax
  80057c:	8d 50 04             	lea    0x4(%eax),%edx
  80057f:	89 55 14             	mov    %edx,0x14(%ebp)
  800582:	83 ec 08             	sub    $0x8,%esp
  800585:	53                   	push   %ebx
  800586:	ff 30                	pushl  (%eax)
  800588:	ff d6                	call   *%esi
			break;
  80058a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800590:	e9 04 ff ff ff       	jmp    800499 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	8d 50 04             	lea    0x4(%eax),%edx
  80059b:	89 55 14             	mov    %edx,0x14(%ebp)
  80059e:	8b 00                	mov    (%eax),%eax
  8005a0:	99                   	cltd   
  8005a1:	31 d0                	xor    %edx,%eax
  8005a3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005a5:	83 f8 0f             	cmp    $0xf,%eax
  8005a8:	7f 0b                	jg     8005b5 <vprintfmt+0x142>
  8005aa:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  8005b1:	85 d2                	test   %edx,%edx
  8005b3:	75 18                	jne    8005cd <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005b5:	50                   	push   %eax
  8005b6:	68 33 24 80 00       	push   $0x802433
  8005bb:	53                   	push   %ebx
  8005bc:	56                   	push   %esi
  8005bd:	e8 94 fe ff ff       	call   800456 <printfmt>
  8005c2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005c8:	e9 cc fe ff ff       	jmp    800499 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005cd:	52                   	push   %edx
  8005ce:	68 71 28 80 00       	push   $0x802871
  8005d3:	53                   	push   %ebx
  8005d4:	56                   	push   %esi
  8005d5:	e8 7c fe ff ff       	call   800456 <printfmt>
  8005da:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e0:	e9 b4 fe ff ff       	jmp    800499 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e8:	8d 50 04             	lea    0x4(%eax),%edx
  8005eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ee:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005f0:	85 ff                	test   %edi,%edi
  8005f2:	b8 2c 24 80 00       	mov    $0x80242c,%eax
  8005f7:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005fa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005fe:	0f 8e 94 00 00 00    	jle    800698 <vprintfmt+0x225>
  800604:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800608:	0f 84 98 00 00 00    	je     8006a6 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	ff 75 d0             	pushl  -0x30(%ebp)
  800614:	57                   	push   %edi
  800615:	e8 86 02 00 00       	call   8008a0 <strnlen>
  80061a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80061d:	29 c1                	sub    %eax,%ecx
  80061f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800622:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800625:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800629:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80062c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80062f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800631:	eb 0f                	jmp    800642 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800633:	83 ec 08             	sub    $0x8,%esp
  800636:	53                   	push   %ebx
  800637:	ff 75 e0             	pushl  -0x20(%ebp)
  80063a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80063c:	83 ef 01             	sub    $0x1,%edi
  80063f:	83 c4 10             	add    $0x10,%esp
  800642:	85 ff                	test   %edi,%edi
  800644:	7f ed                	jg     800633 <vprintfmt+0x1c0>
  800646:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800649:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80064c:	85 c9                	test   %ecx,%ecx
  80064e:	b8 00 00 00 00       	mov    $0x0,%eax
  800653:	0f 49 c1             	cmovns %ecx,%eax
  800656:	29 c1                	sub    %eax,%ecx
  800658:	89 75 08             	mov    %esi,0x8(%ebp)
  80065b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80065e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800661:	89 cb                	mov    %ecx,%ebx
  800663:	eb 4d                	jmp    8006b2 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800665:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800669:	74 1b                	je     800686 <vprintfmt+0x213>
  80066b:	0f be c0             	movsbl %al,%eax
  80066e:	83 e8 20             	sub    $0x20,%eax
  800671:	83 f8 5e             	cmp    $0x5e,%eax
  800674:	76 10                	jbe    800686 <vprintfmt+0x213>
					putch('?', putdat);
  800676:	83 ec 08             	sub    $0x8,%esp
  800679:	ff 75 0c             	pushl  0xc(%ebp)
  80067c:	6a 3f                	push   $0x3f
  80067e:	ff 55 08             	call   *0x8(%ebp)
  800681:	83 c4 10             	add    $0x10,%esp
  800684:	eb 0d                	jmp    800693 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800686:	83 ec 08             	sub    $0x8,%esp
  800689:	ff 75 0c             	pushl  0xc(%ebp)
  80068c:	52                   	push   %edx
  80068d:	ff 55 08             	call   *0x8(%ebp)
  800690:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800693:	83 eb 01             	sub    $0x1,%ebx
  800696:	eb 1a                	jmp    8006b2 <vprintfmt+0x23f>
  800698:	89 75 08             	mov    %esi,0x8(%ebp)
  80069b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80069e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006a1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006a4:	eb 0c                	jmp    8006b2 <vprintfmt+0x23f>
  8006a6:	89 75 08             	mov    %esi,0x8(%ebp)
  8006a9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006ac:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006af:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006b2:	83 c7 01             	add    $0x1,%edi
  8006b5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006b9:	0f be d0             	movsbl %al,%edx
  8006bc:	85 d2                	test   %edx,%edx
  8006be:	74 23                	je     8006e3 <vprintfmt+0x270>
  8006c0:	85 f6                	test   %esi,%esi
  8006c2:	78 a1                	js     800665 <vprintfmt+0x1f2>
  8006c4:	83 ee 01             	sub    $0x1,%esi
  8006c7:	79 9c                	jns    800665 <vprintfmt+0x1f2>
  8006c9:	89 df                	mov    %ebx,%edi
  8006cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006d1:	eb 18                	jmp    8006eb <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006d3:	83 ec 08             	sub    $0x8,%esp
  8006d6:	53                   	push   %ebx
  8006d7:	6a 20                	push   $0x20
  8006d9:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006db:	83 ef 01             	sub    $0x1,%edi
  8006de:	83 c4 10             	add    $0x10,%esp
  8006e1:	eb 08                	jmp    8006eb <vprintfmt+0x278>
  8006e3:	89 df                	mov    %ebx,%edi
  8006e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8006e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006eb:	85 ff                	test   %edi,%edi
  8006ed:	7f e4                	jg     8006d3 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006f2:	e9 a2 fd ff ff       	jmp    800499 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006f7:	83 fa 01             	cmp    $0x1,%edx
  8006fa:	7e 16                	jle    800712 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ff:	8d 50 08             	lea    0x8(%eax),%edx
  800702:	89 55 14             	mov    %edx,0x14(%ebp)
  800705:	8b 50 04             	mov    0x4(%eax),%edx
  800708:	8b 00                	mov    (%eax),%eax
  80070a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80070d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800710:	eb 32                	jmp    800744 <vprintfmt+0x2d1>
	else if (lflag)
  800712:	85 d2                	test   %edx,%edx
  800714:	74 18                	je     80072e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800716:	8b 45 14             	mov    0x14(%ebp),%eax
  800719:	8d 50 04             	lea    0x4(%eax),%edx
  80071c:	89 55 14             	mov    %edx,0x14(%ebp)
  80071f:	8b 00                	mov    (%eax),%eax
  800721:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800724:	89 c1                	mov    %eax,%ecx
  800726:	c1 f9 1f             	sar    $0x1f,%ecx
  800729:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80072c:	eb 16                	jmp    800744 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80072e:	8b 45 14             	mov    0x14(%ebp),%eax
  800731:	8d 50 04             	lea    0x4(%eax),%edx
  800734:	89 55 14             	mov    %edx,0x14(%ebp)
  800737:	8b 00                	mov    (%eax),%eax
  800739:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80073c:	89 c1                	mov    %eax,%ecx
  80073e:	c1 f9 1f             	sar    $0x1f,%ecx
  800741:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800744:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800747:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80074a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80074f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800753:	79 74                	jns    8007c9 <vprintfmt+0x356>
				putch('-', putdat);
  800755:	83 ec 08             	sub    $0x8,%esp
  800758:	53                   	push   %ebx
  800759:	6a 2d                	push   $0x2d
  80075b:	ff d6                	call   *%esi
				num = -(long long) num;
  80075d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800760:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800763:	f7 d8                	neg    %eax
  800765:	83 d2 00             	adc    $0x0,%edx
  800768:	f7 da                	neg    %edx
  80076a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80076d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800772:	eb 55                	jmp    8007c9 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800774:	8d 45 14             	lea    0x14(%ebp),%eax
  800777:	e8 83 fc ff ff       	call   8003ff <getuint>
			base = 10;
  80077c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800781:	eb 46                	jmp    8007c9 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800783:	8d 45 14             	lea    0x14(%ebp),%eax
  800786:	e8 74 fc ff ff       	call   8003ff <getuint>
			base = 8;
  80078b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800790:	eb 37                	jmp    8007c9 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800792:	83 ec 08             	sub    $0x8,%esp
  800795:	53                   	push   %ebx
  800796:	6a 30                	push   $0x30
  800798:	ff d6                	call   *%esi
			putch('x', putdat);
  80079a:	83 c4 08             	add    $0x8,%esp
  80079d:	53                   	push   %ebx
  80079e:	6a 78                	push   $0x78
  8007a0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a5:	8d 50 04             	lea    0x4(%eax),%edx
  8007a8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007ab:	8b 00                	mov    (%eax),%eax
  8007ad:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007b2:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007b5:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007ba:	eb 0d                	jmp    8007c9 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007bc:	8d 45 14             	lea    0x14(%ebp),%eax
  8007bf:	e8 3b fc ff ff       	call   8003ff <getuint>
			base = 16;
  8007c4:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007c9:	83 ec 0c             	sub    $0xc,%esp
  8007cc:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007d0:	57                   	push   %edi
  8007d1:	ff 75 e0             	pushl  -0x20(%ebp)
  8007d4:	51                   	push   %ecx
  8007d5:	52                   	push   %edx
  8007d6:	50                   	push   %eax
  8007d7:	89 da                	mov    %ebx,%edx
  8007d9:	89 f0                	mov    %esi,%eax
  8007db:	e8 70 fb ff ff       	call   800350 <printnum>
			break;
  8007e0:	83 c4 20             	add    $0x20,%esp
  8007e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007e6:	e9 ae fc ff ff       	jmp    800499 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007eb:	83 ec 08             	sub    $0x8,%esp
  8007ee:	53                   	push   %ebx
  8007ef:	51                   	push   %ecx
  8007f0:	ff d6                	call   *%esi
			break;
  8007f2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007f8:	e9 9c fc ff ff       	jmp    800499 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007fd:	83 ec 08             	sub    $0x8,%esp
  800800:	53                   	push   %ebx
  800801:	6a 25                	push   $0x25
  800803:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800805:	83 c4 10             	add    $0x10,%esp
  800808:	eb 03                	jmp    80080d <vprintfmt+0x39a>
  80080a:	83 ef 01             	sub    $0x1,%edi
  80080d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800811:	75 f7                	jne    80080a <vprintfmt+0x397>
  800813:	e9 81 fc ff ff       	jmp    800499 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800818:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80081b:	5b                   	pop    %ebx
  80081c:	5e                   	pop    %esi
  80081d:	5f                   	pop    %edi
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    

00800820 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	83 ec 18             	sub    $0x18,%esp
  800826:	8b 45 08             	mov    0x8(%ebp),%eax
  800829:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80082c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80082f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800833:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800836:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80083d:	85 c0                	test   %eax,%eax
  80083f:	74 26                	je     800867 <vsnprintf+0x47>
  800841:	85 d2                	test   %edx,%edx
  800843:	7e 22                	jle    800867 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800845:	ff 75 14             	pushl  0x14(%ebp)
  800848:	ff 75 10             	pushl  0x10(%ebp)
  80084b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80084e:	50                   	push   %eax
  80084f:	68 39 04 80 00       	push   $0x800439
  800854:	e8 1a fc ff ff       	call   800473 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800859:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80085c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80085f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800862:	83 c4 10             	add    $0x10,%esp
  800865:	eb 05                	jmp    80086c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800867:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80086c:	c9                   	leave  
  80086d:	c3                   	ret    

0080086e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800874:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800877:	50                   	push   %eax
  800878:	ff 75 10             	pushl  0x10(%ebp)
  80087b:	ff 75 0c             	pushl  0xc(%ebp)
  80087e:	ff 75 08             	pushl  0x8(%ebp)
  800881:	e8 9a ff ff ff       	call   800820 <vsnprintf>
	va_end(ap);

	return rc;
}
  800886:	c9                   	leave  
  800887:	c3                   	ret    

00800888 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80088e:	b8 00 00 00 00       	mov    $0x0,%eax
  800893:	eb 03                	jmp    800898 <strlen+0x10>
		n++;
  800895:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800898:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80089c:	75 f7                	jne    800895 <strlen+0xd>
		n++;
	return n;
}
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ae:	eb 03                	jmp    8008b3 <strnlen+0x13>
		n++;
  8008b0:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b3:	39 c2                	cmp    %eax,%edx
  8008b5:	74 08                	je     8008bf <strnlen+0x1f>
  8008b7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008bb:	75 f3                	jne    8008b0 <strnlen+0x10>
  8008bd:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	53                   	push   %ebx
  8008c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008cb:	89 c2                	mov    %eax,%edx
  8008cd:	83 c2 01             	add    $0x1,%edx
  8008d0:	83 c1 01             	add    $0x1,%ecx
  8008d3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008d7:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008da:	84 db                	test   %bl,%bl
  8008dc:	75 ef                	jne    8008cd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008de:	5b                   	pop    %ebx
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	53                   	push   %ebx
  8008e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008e8:	53                   	push   %ebx
  8008e9:	e8 9a ff ff ff       	call   800888 <strlen>
  8008ee:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008f1:	ff 75 0c             	pushl  0xc(%ebp)
  8008f4:	01 d8                	add    %ebx,%eax
  8008f6:	50                   	push   %eax
  8008f7:	e8 c5 ff ff ff       	call   8008c1 <strcpy>
	return dst;
}
  8008fc:	89 d8                	mov    %ebx,%eax
  8008fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800901:	c9                   	leave  
  800902:	c3                   	ret    

00800903 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
  800908:	8b 75 08             	mov    0x8(%ebp),%esi
  80090b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090e:	89 f3                	mov    %esi,%ebx
  800910:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800913:	89 f2                	mov    %esi,%edx
  800915:	eb 0f                	jmp    800926 <strncpy+0x23>
		*dst++ = *src;
  800917:	83 c2 01             	add    $0x1,%edx
  80091a:	0f b6 01             	movzbl (%ecx),%eax
  80091d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800920:	80 39 01             	cmpb   $0x1,(%ecx)
  800923:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800926:	39 da                	cmp    %ebx,%edx
  800928:	75 ed                	jne    800917 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80092a:	89 f0                	mov    %esi,%eax
  80092c:	5b                   	pop    %ebx
  80092d:	5e                   	pop    %esi
  80092e:	5d                   	pop    %ebp
  80092f:	c3                   	ret    

00800930 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	56                   	push   %esi
  800934:	53                   	push   %ebx
  800935:	8b 75 08             	mov    0x8(%ebp),%esi
  800938:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80093b:	8b 55 10             	mov    0x10(%ebp),%edx
  80093e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800940:	85 d2                	test   %edx,%edx
  800942:	74 21                	je     800965 <strlcpy+0x35>
  800944:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800948:	89 f2                	mov    %esi,%edx
  80094a:	eb 09                	jmp    800955 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80094c:	83 c2 01             	add    $0x1,%edx
  80094f:	83 c1 01             	add    $0x1,%ecx
  800952:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800955:	39 c2                	cmp    %eax,%edx
  800957:	74 09                	je     800962 <strlcpy+0x32>
  800959:	0f b6 19             	movzbl (%ecx),%ebx
  80095c:	84 db                	test   %bl,%bl
  80095e:	75 ec                	jne    80094c <strlcpy+0x1c>
  800960:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800962:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800965:	29 f0                	sub    %esi,%eax
}
  800967:	5b                   	pop    %ebx
  800968:	5e                   	pop    %esi
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800971:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800974:	eb 06                	jmp    80097c <strcmp+0x11>
		p++, q++;
  800976:	83 c1 01             	add    $0x1,%ecx
  800979:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80097c:	0f b6 01             	movzbl (%ecx),%eax
  80097f:	84 c0                	test   %al,%al
  800981:	74 04                	je     800987 <strcmp+0x1c>
  800983:	3a 02                	cmp    (%edx),%al
  800985:	74 ef                	je     800976 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800987:	0f b6 c0             	movzbl %al,%eax
  80098a:	0f b6 12             	movzbl (%edx),%edx
  80098d:	29 d0                	sub    %edx,%eax
}
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	53                   	push   %ebx
  800995:	8b 45 08             	mov    0x8(%ebp),%eax
  800998:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099b:	89 c3                	mov    %eax,%ebx
  80099d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009a0:	eb 06                	jmp    8009a8 <strncmp+0x17>
		n--, p++, q++;
  8009a2:	83 c0 01             	add    $0x1,%eax
  8009a5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009a8:	39 d8                	cmp    %ebx,%eax
  8009aa:	74 15                	je     8009c1 <strncmp+0x30>
  8009ac:	0f b6 08             	movzbl (%eax),%ecx
  8009af:	84 c9                	test   %cl,%cl
  8009b1:	74 04                	je     8009b7 <strncmp+0x26>
  8009b3:	3a 0a                	cmp    (%edx),%cl
  8009b5:	74 eb                	je     8009a2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b7:	0f b6 00             	movzbl (%eax),%eax
  8009ba:	0f b6 12             	movzbl (%edx),%edx
  8009bd:	29 d0                	sub    %edx,%eax
  8009bf:	eb 05                	jmp    8009c6 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009c1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009c6:	5b                   	pop    %ebx
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d3:	eb 07                	jmp    8009dc <strchr+0x13>
		if (*s == c)
  8009d5:	38 ca                	cmp    %cl,%dl
  8009d7:	74 0f                	je     8009e8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009d9:	83 c0 01             	add    $0x1,%eax
  8009dc:	0f b6 10             	movzbl (%eax),%edx
  8009df:	84 d2                	test   %dl,%dl
  8009e1:	75 f2                	jne    8009d5 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f4:	eb 03                	jmp    8009f9 <strfind+0xf>
  8009f6:	83 c0 01             	add    $0x1,%eax
  8009f9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009fc:	38 ca                	cmp    %cl,%dl
  8009fe:	74 04                	je     800a04 <strfind+0x1a>
  800a00:	84 d2                	test   %dl,%dl
  800a02:	75 f2                	jne    8009f6 <strfind+0xc>
			break;
	return (char *) s;
}
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	57                   	push   %edi
  800a0a:	56                   	push   %esi
  800a0b:	53                   	push   %ebx
  800a0c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a0f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a12:	85 c9                	test   %ecx,%ecx
  800a14:	74 36                	je     800a4c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a16:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a1c:	75 28                	jne    800a46 <memset+0x40>
  800a1e:	f6 c1 03             	test   $0x3,%cl
  800a21:	75 23                	jne    800a46 <memset+0x40>
		c &= 0xFF;
  800a23:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a27:	89 d3                	mov    %edx,%ebx
  800a29:	c1 e3 08             	shl    $0x8,%ebx
  800a2c:	89 d6                	mov    %edx,%esi
  800a2e:	c1 e6 18             	shl    $0x18,%esi
  800a31:	89 d0                	mov    %edx,%eax
  800a33:	c1 e0 10             	shl    $0x10,%eax
  800a36:	09 f0                	or     %esi,%eax
  800a38:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a3a:	89 d8                	mov    %ebx,%eax
  800a3c:	09 d0                	or     %edx,%eax
  800a3e:	c1 e9 02             	shr    $0x2,%ecx
  800a41:	fc                   	cld    
  800a42:	f3 ab                	rep stos %eax,%es:(%edi)
  800a44:	eb 06                	jmp    800a4c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a46:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a49:	fc                   	cld    
  800a4a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a4c:	89 f8                	mov    %edi,%eax
  800a4e:	5b                   	pop    %ebx
  800a4f:	5e                   	pop    %esi
  800a50:	5f                   	pop    %edi
  800a51:	5d                   	pop    %ebp
  800a52:	c3                   	ret    

00800a53 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	57                   	push   %edi
  800a57:	56                   	push   %esi
  800a58:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a5e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a61:	39 c6                	cmp    %eax,%esi
  800a63:	73 35                	jae    800a9a <memmove+0x47>
  800a65:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a68:	39 d0                	cmp    %edx,%eax
  800a6a:	73 2e                	jae    800a9a <memmove+0x47>
		s += n;
		d += n;
  800a6c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6f:	89 d6                	mov    %edx,%esi
  800a71:	09 fe                	or     %edi,%esi
  800a73:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a79:	75 13                	jne    800a8e <memmove+0x3b>
  800a7b:	f6 c1 03             	test   $0x3,%cl
  800a7e:	75 0e                	jne    800a8e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a80:	83 ef 04             	sub    $0x4,%edi
  800a83:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a86:	c1 e9 02             	shr    $0x2,%ecx
  800a89:	fd                   	std    
  800a8a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a8c:	eb 09                	jmp    800a97 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a8e:	83 ef 01             	sub    $0x1,%edi
  800a91:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a94:	fd                   	std    
  800a95:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a97:	fc                   	cld    
  800a98:	eb 1d                	jmp    800ab7 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a9a:	89 f2                	mov    %esi,%edx
  800a9c:	09 c2                	or     %eax,%edx
  800a9e:	f6 c2 03             	test   $0x3,%dl
  800aa1:	75 0f                	jne    800ab2 <memmove+0x5f>
  800aa3:	f6 c1 03             	test   $0x3,%cl
  800aa6:	75 0a                	jne    800ab2 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800aa8:	c1 e9 02             	shr    $0x2,%ecx
  800aab:	89 c7                	mov    %eax,%edi
  800aad:	fc                   	cld    
  800aae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab0:	eb 05                	jmp    800ab7 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ab2:	89 c7                	mov    %eax,%edi
  800ab4:	fc                   	cld    
  800ab5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ab7:	5e                   	pop    %esi
  800ab8:	5f                   	pop    %edi
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800abe:	ff 75 10             	pushl  0x10(%ebp)
  800ac1:	ff 75 0c             	pushl  0xc(%ebp)
  800ac4:	ff 75 08             	pushl  0x8(%ebp)
  800ac7:	e8 87 ff ff ff       	call   800a53 <memmove>
}
  800acc:	c9                   	leave  
  800acd:	c3                   	ret    

00800ace <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ace:	55                   	push   %ebp
  800acf:	89 e5                	mov    %esp,%ebp
  800ad1:	56                   	push   %esi
  800ad2:	53                   	push   %ebx
  800ad3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad9:	89 c6                	mov    %eax,%esi
  800adb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ade:	eb 1a                	jmp    800afa <memcmp+0x2c>
		if (*s1 != *s2)
  800ae0:	0f b6 08             	movzbl (%eax),%ecx
  800ae3:	0f b6 1a             	movzbl (%edx),%ebx
  800ae6:	38 d9                	cmp    %bl,%cl
  800ae8:	74 0a                	je     800af4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800aea:	0f b6 c1             	movzbl %cl,%eax
  800aed:	0f b6 db             	movzbl %bl,%ebx
  800af0:	29 d8                	sub    %ebx,%eax
  800af2:	eb 0f                	jmp    800b03 <memcmp+0x35>
		s1++, s2++;
  800af4:	83 c0 01             	add    $0x1,%eax
  800af7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800afa:	39 f0                	cmp    %esi,%eax
  800afc:	75 e2                	jne    800ae0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800afe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b03:	5b                   	pop    %ebx
  800b04:	5e                   	pop    %esi
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	53                   	push   %ebx
  800b0b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b0e:	89 c1                	mov    %eax,%ecx
  800b10:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b13:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b17:	eb 0a                	jmp    800b23 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b19:	0f b6 10             	movzbl (%eax),%edx
  800b1c:	39 da                	cmp    %ebx,%edx
  800b1e:	74 07                	je     800b27 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b20:	83 c0 01             	add    $0x1,%eax
  800b23:	39 c8                	cmp    %ecx,%eax
  800b25:	72 f2                	jb     800b19 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b27:	5b                   	pop    %ebx
  800b28:	5d                   	pop    %ebp
  800b29:	c3                   	ret    

00800b2a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	57                   	push   %edi
  800b2e:	56                   	push   %esi
  800b2f:	53                   	push   %ebx
  800b30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b33:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b36:	eb 03                	jmp    800b3b <strtol+0x11>
		s++;
  800b38:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b3b:	0f b6 01             	movzbl (%ecx),%eax
  800b3e:	3c 20                	cmp    $0x20,%al
  800b40:	74 f6                	je     800b38 <strtol+0xe>
  800b42:	3c 09                	cmp    $0x9,%al
  800b44:	74 f2                	je     800b38 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b46:	3c 2b                	cmp    $0x2b,%al
  800b48:	75 0a                	jne    800b54 <strtol+0x2a>
		s++;
  800b4a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b4d:	bf 00 00 00 00       	mov    $0x0,%edi
  800b52:	eb 11                	jmp    800b65 <strtol+0x3b>
  800b54:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b59:	3c 2d                	cmp    $0x2d,%al
  800b5b:	75 08                	jne    800b65 <strtol+0x3b>
		s++, neg = 1;
  800b5d:	83 c1 01             	add    $0x1,%ecx
  800b60:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b65:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b6b:	75 15                	jne    800b82 <strtol+0x58>
  800b6d:	80 39 30             	cmpb   $0x30,(%ecx)
  800b70:	75 10                	jne    800b82 <strtol+0x58>
  800b72:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b76:	75 7c                	jne    800bf4 <strtol+0xca>
		s += 2, base = 16;
  800b78:	83 c1 02             	add    $0x2,%ecx
  800b7b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b80:	eb 16                	jmp    800b98 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b82:	85 db                	test   %ebx,%ebx
  800b84:	75 12                	jne    800b98 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b86:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b8b:	80 39 30             	cmpb   $0x30,(%ecx)
  800b8e:	75 08                	jne    800b98 <strtol+0x6e>
		s++, base = 8;
  800b90:	83 c1 01             	add    $0x1,%ecx
  800b93:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b98:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ba0:	0f b6 11             	movzbl (%ecx),%edx
  800ba3:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ba6:	89 f3                	mov    %esi,%ebx
  800ba8:	80 fb 09             	cmp    $0x9,%bl
  800bab:	77 08                	ja     800bb5 <strtol+0x8b>
			dig = *s - '0';
  800bad:	0f be d2             	movsbl %dl,%edx
  800bb0:	83 ea 30             	sub    $0x30,%edx
  800bb3:	eb 22                	jmp    800bd7 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800bb5:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bb8:	89 f3                	mov    %esi,%ebx
  800bba:	80 fb 19             	cmp    $0x19,%bl
  800bbd:	77 08                	ja     800bc7 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bbf:	0f be d2             	movsbl %dl,%edx
  800bc2:	83 ea 57             	sub    $0x57,%edx
  800bc5:	eb 10                	jmp    800bd7 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bc7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bca:	89 f3                	mov    %esi,%ebx
  800bcc:	80 fb 19             	cmp    $0x19,%bl
  800bcf:	77 16                	ja     800be7 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bd1:	0f be d2             	movsbl %dl,%edx
  800bd4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bd7:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bda:	7d 0b                	jge    800be7 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bdc:	83 c1 01             	add    $0x1,%ecx
  800bdf:	0f af 45 10          	imul   0x10(%ebp),%eax
  800be3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800be5:	eb b9                	jmp    800ba0 <strtol+0x76>

	if (endptr)
  800be7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800beb:	74 0d                	je     800bfa <strtol+0xd0>
		*endptr = (char *) s;
  800bed:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bf0:	89 0e                	mov    %ecx,(%esi)
  800bf2:	eb 06                	jmp    800bfa <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bf4:	85 db                	test   %ebx,%ebx
  800bf6:	74 98                	je     800b90 <strtol+0x66>
  800bf8:	eb 9e                	jmp    800b98 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bfa:	89 c2                	mov    %eax,%edx
  800bfc:	f7 da                	neg    %edx
  800bfe:	85 ff                	test   %edi,%edi
  800c00:	0f 45 c2             	cmovne %edx,%eax
}
  800c03:	5b                   	pop    %ebx
  800c04:	5e                   	pop    %esi
  800c05:	5f                   	pop    %edi
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c16:	8b 55 08             	mov    0x8(%ebp),%edx
  800c19:	89 c3                	mov    %eax,%ebx
  800c1b:	89 c7                	mov    %eax,%edi
  800c1d:	89 c6                	mov    %eax,%esi
  800c1f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c31:	b8 01 00 00 00       	mov    $0x1,%eax
  800c36:	89 d1                	mov    %edx,%ecx
  800c38:	89 d3                	mov    %edx,%ebx
  800c3a:	89 d7                	mov    %edx,%edi
  800c3c:	89 d6                	mov    %edx,%esi
  800c3e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
  800c4b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c53:	b8 03 00 00 00       	mov    $0x3,%eax
  800c58:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5b:	89 cb                	mov    %ecx,%ebx
  800c5d:	89 cf                	mov    %ecx,%edi
  800c5f:	89 ce                	mov    %ecx,%esi
  800c61:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c63:	85 c0                	test   %eax,%eax
  800c65:	7e 17                	jle    800c7e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c67:	83 ec 0c             	sub    $0xc,%esp
  800c6a:	50                   	push   %eax
  800c6b:	6a 03                	push   $0x3
  800c6d:	68 1f 27 80 00       	push   $0x80271f
  800c72:	6a 23                	push   $0x23
  800c74:	68 3c 27 80 00       	push   $0x80273c
  800c79:	e8 e5 f5 ff ff       	call   800263 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c91:	b8 02 00 00 00       	mov    $0x2,%eax
  800c96:	89 d1                	mov    %edx,%ecx
  800c98:	89 d3                	mov    %edx,%ebx
  800c9a:	89 d7                	mov    %edx,%edi
  800c9c:	89 d6                	mov    %edx,%esi
  800c9e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_yield>:

void
sys_yield(void)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cab:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cb5:	89 d1                	mov    %edx,%ecx
  800cb7:	89 d3                	mov    %edx,%ebx
  800cb9:	89 d7                	mov    %edx,%edi
  800cbb:	89 d6                	mov    %edx,%esi
  800cbd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
  800cca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccd:	be 00 00 00 00       	mov    $0x0,%esi
  800cd2:	b8 04 00 00 00       	mov    $0x4,%eax
  800cd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cda:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce0:	89 f7                	mov    %esi,%edi
  800ce2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce4:	85 c0                	test   %eax,%eax
  800ce6:	7e 17                	jle    800cff <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce8:	83 ec 0c             	sub    $0xc,%esp
  800ceb:	50                   	push   %eax
  800cec:	6a 04                	push   $0x4
  800cee:	68 1f 27 80 00       	push   $0x80271f
  800cf3:	6a 23                	push   $0x23
  800cf5:	68 3c 27 80 00       	push   $0x80273c
  800cfa:	e8 64 f5 ff ff       	call   800263 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
  800d0d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d10:	b8 05 00 00 00       	mov    $0x5,%eax
  800d15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d18:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d21:	8b 75 18             	mov    0x18(%ebp),%esi
  800d24:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d26:	85 c0                	test   %eax,%eax
  800d28:	7e 17                	jle    800d41 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2a:	83 ec 0c             	sub    $0xc,%esp
  800d2d:	50                   	push   %eax
  800d2e:	6a 05                	push   $0x5
  800d30:	68 1f 27 80 00       	push   $0x80271f
  800d35:	6a 23                	push   $0x23
  800d37:	68 3c 27 80 00       	push   $0x80273c
  800d3c:	e8 22 f5 ff ff       	call   800263 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d44:	5b                   	pop    %ebx
  800d45:	5e                   	pop    %esi
  800d46:	5f                   	pop    %edi
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    

00800d49 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	57                   	push   %edi
  800d4d:	56                   	push   %esi
  800d4e:	53                   	push   %ebx
  800d4f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d52:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d57:	b8 06 00 00 00       	mov    $0x6,%eax
  800d5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d62:	89 df                	mov    %ebx,%edi
  800d64:	89 de                	mov    %ebx,%esi
  800d66:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d68:	85 c0                	test   %eax,%eax
  800d6a:	7e 17                	jle    800d83 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6c:	83 ec 0c             	sub    $0xc,%esp
  800d6f:	50                   	push   %eax
  800d70:	6a 06                	push   $0x6
  800d72:	68 1f 27 80 00       	push   $0x80271f
  800d77:	6a 23                	push   $0x23
  800d79:	68 3c 27 80 00       	push   $0x80273c
  800d7e:	e8 e0 f4 ff ff       	call   800263 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d86:	5b                   	pop    %ebx
  800d87:	5e                   	pop    %esi
  800d88:	5f                   	pop    %edi
  800d89:	5d                   	pop    %ebp
  800d8a:	c3                   	ret    

00800d8b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	57                   	push   %edi
  800d8f:	56                   	push   %esi
  800d90:	53                   	push   %ebx
  800d91:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d94:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d99:	b8 08 00 00 00       	mov    $0x8,%eax
  800d9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da1:	8b 55 08             	mov    0x8(%ebp),%edx
  800da4:	89 df                	mov    %ebx,%edi
  800da6:	89 de                	mov    %ebx,%esi
  800da8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800daa:	85 c0                	test   %eax,%eax
  800dac:	7e 17                	jle    800dc5 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dae:	83 ec 0c             	sub    $0xc,%esp
  800db1:	50                   	push   %eax
  800db2:	6a 08                	push   $0x8
  800db4:	68 1f 27 80 00       	push   $0x80271f
  800db9:	6a 23                	push   $0x23
  800dbb:	68 3c 27 80 00       	push   $0x80273c
  800dc0:	e8 9e f4 ff ff       	call   800263 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc8:	5b                   	pop    %ebx
  800dc9:	5e                   	pop    %esi
  800dca:	5f                   	pop    %edi
  800dcb:	5d                   	pop    %ebp
  800dcc:	c3                   	ret    

00800dcd <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
  800dd0:	57                   	push   %edi
  800dd1:	56                   	push   %esi
  800dd2:	53                   	push   %ebx
  800dd3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ddb:	b8 09 00 00 00       	mov    $0x9,%eax
  800de0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de3:	8b 55 08             	mov    0x8(%ebp),%edx
  800de6:	89 df                	mov    %ebx,%edi
  800de8:	89 de                	mov    %ebx,%esi
  800dea:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dec:	85 c0                	test   %eax,%eax
  800dee:	7e 17                	jle    800e07 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df0:	83 ec 0c             	sub    $0xc,%esp
  800df3:	50                   	push   %eax
  800df4:	6a 09                	push   $0x9
  800df6:	68 1f 27 80 00       	push   $0x80271f
  800dfb:	6a 23                	push   $0x23
  800dfd:	68 3c 27 80 00       	push   $0x80273c
  800e02:	e8 5c f4 ff ff       	call   800263 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0a:	5b                   	pop    %ebx
  800e0b:	5e                   	pop    %esi
  800e0c:	5f                   	pop    %edi
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	57                   	push   %edi
  800e13:	56                   	push   %esi
  800e14:	53                   	push   %ebx
  800e15:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e18:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e25:	8b 55 08             	mov    0x8(%ebp),%edx
  800e28:	89 df                	mov    %ebx,%edi
  800e2a:	89 de                	mov    %ebx,%esi
  800e2c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e2e:	85 c0                	test   %eax,%eax
  800e30:	7e 17                	jle    800e49 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e32:	83 ec 0c             	sub    $0xc,%esp
  800e35:	50                   	push   %eax
  800e36:	6a 0a                	push   $0xa
  800e38:	68 1f 27 80 00       	push   $0x80271f
  800e3d:	6a 23                	push   $0x23
  800e3f:	68 3c 27 80 00       	push   $0x80273c
  800e44:	e8 1a f4 ff ff       	call   800263 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4c:	5b                   	pop    %ebx
  800e4d:	5e                   	pop    %esi
  800e4e:	5f                   	pop    %edi
  800e4f:	5d                   	pop    %ebp
  800e50:	c3                   	ret    

00800e51 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
  800e54:	57                   	push   %edi
  800e55:	56                   	push   %esi
  800e56:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e57:	be 00 00 00 00       	mov    $0x0,%esi
  800e5c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e64:	8b 55 08             	mov    0x8(%ebp),%edx
  800e67:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e6a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e6d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e6f:	5b                   	pop    %ebx
  800e70:	5e                   	pop    %esi
  800e71:	5f                   	pop    %edi
  800e72:	5d                   	pop    %ebp
  800e73:	c3                   	ret    

00800e74 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	57                   	push   %edi
  800e78:	56                   	push   %esi
  800e79:	53                   	push   %ebx
  800e7a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e82:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e87:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8a:	89 cb                	mov    %ecx,%ebx
  800e8c:	89 cf                	mov    %ecx,%edi
  800e8e:	89 ce                	mov    %ecx,%esi
  800e90:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e92:	85 c0                	test   %eax,%eax
  800e94:	7e 17                	jle    800ead <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e96:	83 ec 0c             	sub    $0xc,%esp
  800e99:	50                   	push   %eax
  800e9a:	6a 0d                	push   $0xd
  800e9c:	68 1f 27 80 00       	push   $0x80271f
  800ea1:	6a 23                	push   $0x23
  800ea3:	68 3c 27 80 00       	push   $0x80273c
  800ea8:	e8 b6 f3 ff ff       	call   800263 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ead:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb0:	5b                   	pop    %ebx
  800eb1:	5e                   	pop    %esi
  800eb2:	5f                   	pop    %edi
  800eb3:	5d                   	pop    %ebp
  800eb4:	c3                   	ret    

00800eb5 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	57                   	push   %edi
  800eb9:	56                   	push   %esi
  800eba:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ec0:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ec5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec8:	89 cb                	mov    %ecx,%ebx
  800eca:	89 cf                	mov    %ecx,%edi
  800ecc:	89 ce                	mov    %ecx,%esi
  800ece:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800ed0:	5b                   	pop    %ebx
  800ed1:	5e                   	pop    %esi
  800ed2:	5f                   	pop    %edi
  800ed3:	5d                   	pop    %ebp
  800ed4:	c3                   	ret    

00800ed5 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800ed5:	55                   	push   %ebp
  800ed6:	89 e5                	mov    %esp,%ebp
  800ed8:	57                   	push   %edi
  800ed9:	56                   	push   %esi
  800eda:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800edb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ee0:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ee5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee8:	89 cb                	mov    %ecx,%ebx
  800eea:	89 cf                	mov    %ecx,%edi
  800eec:	89 ce                	mov    %ecx,%esi
  800eee:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800ef0:	5b                   	pop    %ebx
  800ef1:	5e                   	pop    %esi
  800ef2:	5f                   	pop    %edi
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    

00800ef5 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
  800ef8:	53                   	push   %ebx
  800ef9:	83 ec 04             	sub    $0x4,%esp
  800efc:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800eff:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800f01:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f05:	74 11                	je     800f18 <pgfault+0x23>
  800f07:	89 d8                	mov    %ebx,%eax
  800f09:	c1 e8 0c             	shr    $0xc,%eax
  800f0c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f13:	f6 c4 08             	test   $0x8,%ah
  800f16:	75 14                	jne    800f2c <pgfault+0x37>
		panic("faulting access");
  800f18:	83 ec 04             	sub    $0x4,%esp
  800f1b:	68 4a 27 80 00       	push   $0x80274a
  800f20:	6a 1e                	push   $0x1e
  800f22:	68 5a 27 80 00       	push   $0x80275a
  800f27:	e8 37 f3 ff ff       	call   800263 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800f2c:	83 ec 04             	sub    $0x4,%esp
  800f2f:	6a 07                	push   $0x7
  800f31:	68 00 f0 7f 00       	push   $0x7ff000
  800f36:	6a 00                	push   $0x0
  800f38:	e8 87 fd ff ff       	call   800cc4 <sys_page_alloc>
	if (r < 0) {
  800f3d:	83 c4 10             	add    $0x10,%esp
  800f40:	85 c0                	test   %eax,%eax
  800f42:	79 12                	jns    800f56 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800f44:	50                   	push   %eax
  800f45:	68 65 27 80 00       	push   $0x802765
  800f4a:	6a 2c                	push   $0x2c
  800f4c:	68 5a 27 80 00       	push   $0x80275a
  800f51:	e8 0d f3 ff ff       	call   800263 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800f56:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800f5c:	83 ec 04             	sub    $0x4,%esp
  800f5f:	68 00 10 00 00       	push   $0x1000
  800f64:	53                   	push   %ebx
  800f65:	68 00 f0 7f 00       	push   $0x7ff000
  800f6a:	e8 4c fb ff ff       	call   800abb <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800f6f:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f76:	53                   	push   %ebx
  800f77:	6a 00                	push   $0x0
  800f79:	68 00 f0 7f 00       	push   $0x7ff000
  800f7e:	6a 00                	push   $0x0
  800f80:	e8 82 fd ff ff       	call   800d07 <sys_page_map>
	if (r < 0) {
  800f85:	83 c4 20             	add    $0x20,%esp
  800f88:	85 c0                	test   %eax,%eax
  800f8a:	79 12                	jns    800f9e <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800f8c:	50                   	push   %eax
  800f8d:	68 65 27 80 00       	push   $0x802765
  800f92:	6a 33                	push   $0x33
  800f94:	68 5a 27 80 00       	push   $0x80275a
  800f99:	e8 c5 f2 ff ff       	call   800263 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800f9e:	83 ec 08             	sub    $0x8,%esp
  800fa1:	68 00 f0 7f 00       	push   $0x7ff000
  800fa6:	6a 00                	push   $0x0
  800fa8:	e8 9c fd ff ff       	call   800d49 <sys_page_unmap>
	if (r < 0) {
  800fad:	83 c4 10             	add    $0x10,%esp
  800fb0:	85 c0                	test   %eax,%eax
  800fb2:	79 12                	jns    800fc6 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800fb4:	50                   	push   %eax
  800fb5:	68 65 27 80 00       	push   $0x802765
  800fba:	6a 37                	push   $0x37
  800fbc:	68 5a 27 80 00       	push   $0x80275a
  800fc1:	e8 9d f2 ff ff       	call   800263 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800fc6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fc9:	c9                   	leave  
  800fca:	c3                   	ret    

00800fcb <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fcb:	55                   	push   %ebp
  800fcc:	89 e5                	mov    %esp,%ebp
  800fce:	57                   	push   %edi
  800fcf:	56                   	push   %esi
  800fd0:	53                   	push   %ebx
  800fd1:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800fd4:	68 f5 0e 80 00       	push   $0x800ef5
  800fd9:	e8 f3 0e 00 00       	call   801ed1 <set_pgfault_handler>
  800fde:	b8 07 00 00 00       	mov    $0x7,%eax
  800fe3:	cd 30                	int    $0x30
  800fe5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800fe8:	83 c4 10             	add    $0x10,%esp
  800feb:	85 c0                	test   %eax,%eax
  800fed:	79 17                	jns    801006 <fork+0x3b>
		panic("fork fault %e");
  800fef:	83 ec 04             	sub    $0x4,%esp
  800ff2:	68 7e 27 80 00       	push   $0x80277e
  800ff7:	68 84 00 00 00       	push   $0x84
  800ffc:	68 5a 27 80 00       	push   $0x80275a
  801001:	e8 5d f2 ff ff       	call   800263 <_panic>
  801006:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  801008:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80100c:	75 25                	jne    801033 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  80100e:	e8 73 fc ff ff       	call   800c86 <sys_getenvid>
  801013:	25 ff 03 00 00       	and    $0x3ff,%eax
  801018:	89 c2                	mov    %eax,%edx
  80101a:	c1 e2 07             	shl    $0x7,%edx
  80101d:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801024:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801029:	b8 00 00 00 00       	mov    $0x0,%eax
  80102e:	e9 61 01 00 00       	jmp    801194 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  801033:	83 ec 04             	sub    $0x4,%esp
  801036:	6a 07                	push   $0x7
  801038:	68 00 f0 bf ee       	push   $0xeebff000
  80103d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801040:	e8 7f fc ff ff       	call   800cc4 <sys_page_alloc>
  801045:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801048:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80104d:	89 d8                	mov    %ebx,%eax
  80104f:	c1 e8 16             	shr    $0x16,%eax
  801052:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801059:	a8 01                	test   $0x1,%al
  80105b:	0f 84 fc 00 00 00    	je     80115d <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  801061:	89 d8                	mov    %ebx,%eax
  801063:	c1 e8 0c             	shr    $0xc,%eax
  801066:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80106d:	f6 c2 01             	test   $0x1,%dl
  801070:	0f 84 e7 00 00 00    	je     80115d <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  801076:	89 c6                	mov    %eax,%esi
  801078:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  80107b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801082:	f6 c6 04             	test   $0x4,%dh
  801085:	74 39                	je     8010c0 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  801087:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80108e:	83 ec 0c             	sub    $0xc,%esp
  801091:	25 07 0e 00 00       	and    $0xe07,%eax
  801096:	50                   	push   %eax
  801097:	56                   	push   %esi
  801098:	57                   	push   %edi
  801099:	56                   	push   %esi
  80109a:	6a 00                	push   $0x0
  80109c:	e8 66 fc ff ff       	call   800d07 <sys_page_map>
		if (r < 0) {
  8010a1:	83 c4 20             	add    $0x20,%esp
  8010a4:	85 c0                	test   %eax,%eax
  8010a6:	0f 89 b1 00 00 00    	jns    80115d <fork+0x192>
		    	panic("sys page map fault %e");
  8010ac:	83 ec 04             	sub    $0x4,%esp
  8010af:	68 8c 27 80 00       	push   $0x80278c
  8010b4:	6a 54                	push   $0x54
  8010b6:	68 5a 27 80 00       	push   $0x80275a
  8010bb:	e8 a3 f1 ff ff       	call   800263 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8010c0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010c7:	f6 c2 02             	test   $0x2,%dl
  8010ca:	75 0c                	jne    8010d8 <fork+0x10d>
  8010cc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010d3:	f6 c4 08             	test   $0x8,%ah
  8010d6:	74 5b                	je     801133 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8010d8:	83 ec 0c             	sub    $0xc,%esp
  8010db:	68 05 08 00 00       	push   $0x805
  8010e0:	56                   	push   %esi
  8010e1:	57                   	push   %edi
  8010e2:	56                   	push   %esi
  8010e3:	6a 00                	push   $0x0
  8010e5:	e8 1d fc ff ff       	call   800d07 <sys_page_map>
		if (r < 0) {
  8010ea:	83 c4 20             	add    $0x20,%esp
  8010ed:	85 c0                	test   %eax,%eax
  8010ef:	79 14                	jns    801105 <fork+0x13a>
		    	panic("sys page map fault %e");
  8010f1:	83 ec 04             	sub    $0x4,%esp
  8010f4:	68 8c 27 80 00       	push   $0x80278c
  8010f9:	6a 5b                	push   $0x5b
  8010fb:	68 5a 27 80 00       	push   $0x80275a
  801100:	e8 5e f1 ff ff       	call   800263 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  801105:	83 ec 0c             	sub    $0xc,%esp
  801108:	68 05 08 00 00       	push   $0x805
  80110d:	56                   	push   %esi
  80110e:	6a 00                	push   $0x0
  801110:	56                   	push   %esi
  801111:	6a 00                	push   $0x0
  801113:	e8 ef fb ff ff       	call   800d07 <sys_page_map>
		if (r < 0) {
  801118:	83 c4 20             	add    $0x20,%esp
  80111b:	85 c0                	test   %eax,%eax
  80111d:	79 3e                	jns    80115d <fork+0x192>
		    	panic("sys page map fault %e");
  80111f:	83 ec 04             	sub    $0x4,%esp
  801122:	68 8c 27 80 00       	push   $0x80278c
  801127:	6a 5f                	push   $0x5f
  801129:	68 5a 27 80 00       	push   $0x80275a
  80112e:	e8 30 f1 ff ff       	call   800263 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801133:	83 ec 0c             	sub    $0xc,%esp
  801136:	6a 05                	push   $0x5
  801138:	56                   	push   %esi
  801139:	57                   	push   %edi
  80113a:	56                   	push   %esi
  80113b:	6a 00                	push   $0x0
  80113d:	e8 c5 fb ff ff       	call   800d07 <sys_page_map>
		if (r < 0) {
  801142:	83 c4 20             	add    $0x20,%esp
  801145:	85 c0                	test   %eax,%eax
  801147:	79 14                	jns    80115d <fork+0x192>
		    	panic("sys page map fault %e");
  801149:	83 ec 04             	sub    $0x4,%esp
  80114c:	68 8c 27 80 00       	push   $0x80278c
  801151:	6a 64                	push   $0x64
  801153:	68 5a 27 80 00       	push   $0x80275a
  801158:	e8 06 f1 ff ff       	call   800263 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80115d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801163:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801169:	0f 85 de fe ff ff    	jne    80104d <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  80116f:	a1 04 40 80 00       	mov    0x804004,%eax
  801174:	8b 40 70             	mov    0x70(%eax),%eax
  801177:	83 ec 08             	sub    $0x8,%esp
  80117a:	50                   	push   %eax
  80117b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80117e:	57                   	push   %edi
  80117f:	e8 8b fc ff ff       	call   800e0f <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801184:	83 c4 08             	add    $0x8,%esp
  801187:	6a 02                	push   $0x2
  801189:	57                   	push   %edi
  80118a:	e8 fc fb ff ff       	call   800d8b <sys_env_set_status>
	
	return envid;
  80118f:	83 c4 10             	add    $0x10,%esp
  801192:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801194:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801197:	5b                   	pop    %ebx
  801198:	5e                   	pop    %esi
  801199:	5f                   	pop    %edi
  80119a:	5d                   	pop    %ebp
  80119b:	c3                   	ret    

0080119c <sfork>:

envid_t
sfork(void)
{
  80119c:	55                   	push   %ebp
  80119d:	89 e5                	mov    %esp,%ebp
	return 0;
}
  80119f:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a4:	5d                   	pop    %ebp
  8011a5:	c3                   	ret    

008011a6 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  8011a6:	55                   	push   %ebp
  8011a7:	89 e5                	mov    %esp,%ebp
  8011a9:	56                   	push   %esi
  8011aa:	53                   	push   %ebx
  8011ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  8011ae:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  8011b4:	83 ec 08             	sub    $0x8,%esp
  8011b7:	53                   	push   %ebx
  8011b8:	68 a4 27 80 00       	push   $0x8027a4
  8011bd:	e8 7a f1 ff ff       	call   80033c <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8011c2:	c7 04 24 29 02 80 00 	movl   $0x800229,(%esp)
  8011c9:	e8 e7 fc ff ff       	call   800eb5 <sys_thread_create>
  8011ce:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8011d0:	83 c4 08             	add    $0x8,%esp
  8011d3:	53                   	push   %ebx
  8011d4:	68 a4 27 80 00       	push   $0x8027a4
  8011d9:	e8 5e f1 ff ff       	call   80033c <cprintf>
	return id;
	//return 0;
}
  8011de:	89 f0                	mov    %esi,%eax
  8011e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011e3:	5b                   	pop    %ebx
  8011e4:	5e                   	pop    %esi
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    

008011e7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011e7:	55                   	push   %ebp
  8011e8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ed:	05 00 00 00 30       	add    $0x30000000,%eax
  8011f2:	c1 e8 0c             	shr    $0xc,%eax
}
  8011f5:	5d                   	pop    %ebp
  8011f6:	c3                   	ret    

008011f7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8011fd:	05 00 00 00 30       	add    $0x30000000,%eax
  801202:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801207:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80120c:	5d                   	pop    %ebp
  80120d:	c3                   	ret    

0080120e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80120e:	55                   	push   %ebp
  80120f:	89 e5                	mov    %esp,%ebp
  801211:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801214:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801219:	89 c2                	mov    %eax,%edx
  80121b:	c1 ea 16             	shr    $0x16,%edx
  80121e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801225:	f6 c2 01             	test   $0x1,%dl
  801228:	74 11                	je     80123b <fd_alloc+0x2d>
  80122a:	89 c2                	mov    %eax,%edx
  80122c:	c1 ea 0c             	shr    $0xc,%edx
  80122f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801236:	f6 c2 01             	test   $0x1,%dl
  801239:	75 09                	jne    801244 <fd_alloc+0x36>
			*fd_store = fd;
  80123b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80123d:	b8 00 00 00 00       	mov    $0x0,%eax
  801242:	eb 17                	jmp    80125b <fd_alloc+0x4d>
  801244:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801249:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80124e:	75 c9                	jne    801219 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801250:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801256:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80125b:	5d                   	pop    %ebp
  80125c:	c3                   	ret    

0080125d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80125d:	55                   	push   %ebp
  80125e:	89 e5                	mov    %esp,%ebp
  801260:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801263:	83 f8 1f             	cmp    $0x1f,%eax
  801266:	77 36                	ja     80129e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801268:	c1 e0 0c             	shl    $0xc,%eax
  80126b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801270:	89 c2                	mov    %eax,%edx
  801272:	c1 ea 16             	shr    $0x16,%edx
  801275:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80127c:	f6 c2 01             	test   $0x1,%dl
  80127f:	74 24                	je     8012a5 <fd_lookup+0x48>
  801281:	89 c2                	mov    %eax,%edx
  801283:	c1 ea 0c             	shr    $0xc,%edx
  801286:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80128d:	f6 c2 01             	test   $0x1,%dl
  801290:	74 1a                	je     8012ac <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801292:	8b 55 0c             	mov    0xc(%ebp),%edx
  801295:	89 02                	mov    %eax,(%edx)
	return 0;
  801297:	b8 00 00 00 00       	mov    $0x0,%eax
  80129c:	eb 13                	jmp    8012b1 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80129e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a3:	eb 0c                	jmp    8012b1 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012aa:	eb 05                	jmp    8012b1 <fd_lookup+0x54>
  8012ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012b1:	5d                   	pop    %ebp
  8012b2:	c3                   	ret    

008012b3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012b3:	55                   	push   %ebp
  8012b4:	89 e5                	mov    %esp,%ebp
  8012b6:	83 ec 08             	sub    $0x8,%esp
  8012b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012bc:	ba 48 28 80 00       	mov    $0x802848,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012c1:	eb 13                	jmp    8012d6 <dev_lookup+0x23>
  8012c3:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012c6:	39 08                	cmp    %ecx,(%eax)
  8012c8:	75 0c                	jne    8012d6 <dev_lookup+0x23>
			*dev = devtab[i];
  8012ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012cd:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d4:	eb 2e                	jmp    801304 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012d6:	8b 02                	mov    (%edx),%eax
  8012d8:	85 c0                	test   %eax,%eax
  8012da:	75 e7                	jne    8012c3 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012dc:	a1 04 40 80 00       	mov    0x804004,%eax
  8012e1:	8b 40 54             	mov    0x54(%eax),%eax
  8012e4:	83 ec 04             	sub    $0x4,%esp
  8012e7:	51                   	push   %ecx
  8012e8:	50                   	push   %eax
  8012e9:	68 c8 27 80 00       	push   $0x8027c8
  8012ee:	e8 49 f0 ff ff       	call   80033c <cprintf>
	*dev = 0;
  8012f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012f6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012fc:	83 c4 10             	add    $0x10,%esp
  8012ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801304:	c9                   	leave  
  801305:	c3                   	ret    

00801306 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801306:	55                   	push   %ebp
  801307:	89 e5                	mov    %esp,%ebp
  801309:	56                   	push   %esi
  80130a:	53                   	push   %ebx
  80130b:	83 ec 10             	sub    $0x10,%esp
  80130e:	8b 75 08             	mov    0x8(%ebp),%esi
  801311:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801314:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801317:	50                   	push   %eax
  801318:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80131e:	c1 e8 0c             	shr    $0xc,%eax
  801321:	50                   	push   %eax
  801322:	e8 36 ff ff ff       	call   80125d <fd_lookup>
  801327:	83 c4 08             	add    $0x8,%esp
  80132a:	85 c0                	test   %eax,%eax
  80132c:	78 05                	js     801333 <fd_close+0x2d>
	    || fd != fd2)
  80132e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801331:	74 0c                	je     80133f <fd_close+0x39>
		return (must_exist ? r : 0);
  801333:	84 db                	test   %bl,%bl
  801335:	ba 00 00 00 00       	mov    $0x0,%edx
  80133a:	0f 44 c2             	cmove  %edx,%eax
  80133d:	eb 41                	jmp    801380 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80133f:	83 ec 08             	sub    $0x8,%esp
  801342:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801345:	50                   	push   %eax
  801346:	ff 36                	pushl  (%esi)
  801348:	e8 66 ff ff ff       	call   8012b3 <dev_lookup>
  80134d:	89 c3                	mov    %eax,%ebx
  80134f:	83 c4 10             	add    $0x10,%esp
  801352:	85 c0                	test   %eax,%eax
  801354:	78 1a                	js     801370 <fd_close+0x6a>
		if (dev->dev_close)
  801356:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801359:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80135c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801361:	85 c0                	test   %eax,%eax
  801363:	74 0b                	je     801370 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801365:	83 ec 0c             	sub    $0xc,%esp
  801368:	56                   	push   %esi
  801369:	ff d0                	call   *%eax
  80136b:	89 c3                	mov    %eax,%ebx
  80136d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801370:	83 ec 08             	sub    $0x8,%esp
  801373:	56                   	push   %esi
  801374:	6a 00                	push   $0x0
  801376:	e8 ce f9 ff ff       	call   800d49 <sys_page_unmap>
	return r;
  80137b:	83 c4 10             	add    $0x10,%esp
  80137e:	89 d8                	mov    %ebx,%eax
}
  801380:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801383:	5b                   	pop    %ebx
  801384:	5e                   	pop    %esi
  801385:	5d                   	pop    %ebp
  801386:	c3                   	ret    

00801387 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801387:	55                   	push   %ebp
  801388:	89 e5                	mov    %esp,%ebp
  80138a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80138d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801390:	50                   	push   %eax
  801391:	ff 75 08             	pushl  0x8(%ebp)
  801394:	e8 c4 fe ff ff       	call   80125d <fd_lookup>
  801399:	83 c4 08             	add    $0x8,%esp
  80139c:	85 c0                	test   %eax,%eax
  80139e:	78 10                	js     8013b0 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013a0:	83 ec 08             	sub    $0x8,%esp
  8013a3:	6a 01                	push   $0x1
  8013a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8013a8:	e8 59 ff ff ff       	call   801306 <fd_close>
  8013ad:	83 c4 10             	add    $0x10,%esp
}
  8013b0:	c9                   	leave  
  8013b1:	c3                   	ret    

008013b2 <close_all>:

void
close_all(void)
{
  8013b2:	55                   	push   %ebp
  8013b3:	89 e5                	mov    %esp,%ebp
  8013b5:	53                   	push   %ebx
  8013b6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013b9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013be:	83 ec 0c             	sub    $0xc,%esp
  8013c1:	53                   	push   %ebx
  8013c2:	e8 c0 ff ff ff       	call   801387 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013c7:	83 c3 01             	add    $0x1,%ebx
  8013ca:	83 c4 10             	add    $0x10,%esp
  8013cd:	83 fb 20             	cmp    $0x20,%ebx
  8013d0:	75 ec                	jne    8013be <close_all+0xc>
		close(i);
}
  8013d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d5:	c9                   	leave  
  8013d6:	c3                   	ret    

008013d7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013d7:	55                   	push   %ebp
  8013d8:	89 e5                	mov    %esp,%ebp
  8013da:	57                   	push   %edi
  8013db:	56                   	push   %esi
  8013dc:	53                   	push   %ebx
  8013dd:	83 ec 2c             	sub    $0x2c,%esp
  8013e0:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013e3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013e6:	50                   	push   %eax
  8013e7:	ff 75 08             	pushl  0x8(%ebp)
  8013ea:	e8 6e fe ff ff       	call   80125d <fd_lookup>
  8013ef:	83 c4 08             	add    $0x8,%esp
  8013f2:	85 c0                	test   %eax,%eax
  8013f4:	0f 88 c1 00 00 00    	js     8014bb <dup+0xe4>
		return r;
	close(newfdnum);
  8013fa:	83 ec 0c             	sub    $0xc,%esp
  8013fd:	56                   	push   %esi
  8013fe:	e8 84 ff ff ff       	call   801387 <close>

	newfd = INDEX2FD(newfdnum);
  801403:	89 f3                	mov    %esi,%ebx
  801405:	c1 e3 0c             	shl    $0xc,%ebx
  801408:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80140e:	83 c4 04             	add    $0x4,%esp
  801411:	ff 75 e4             	pushl  -0x1c(%ebp)
  801414:	e8 de fd ff ff       	call   8011f7 <fd2data>
  801419:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80141b:	89 1c 24             	mov    %ebx,(%esp)
  80141e:	e8 d4 fd ff ff       	call   8011f7 <fd2data>
  801423:	83 c4 10             	add    $0x10,%esp
  801426:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801429:	89 f8                	mov    %edi,%eax
  80142b:	c1 e8 16             	shr    $0x16,%eax
  80142e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801435:	a8 01                	test   $0x1,%al
  801437:	74 37                	je     801470 <dup+0x99>
  801439:	89 f8                	mov    %edi,%eax
  80143b:	c1 e8 0c             	shr    $0xc,%eax
  80143e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801445:	f6 c2 01             	test   $0x1,%dl
  801448:	74 26                	je     801470 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80144a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801451:	83 ec 0c             	sub    $0xc,%esp
  801454:	25 07 0e 00 00       	and    $0xe07,%eax
  801459:	50                   	push   %eax
  80145a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80145d:	6a 00                	push   $0x0
  80145f:	57                   	push   %edi
  801460:	6a 00                	push   $0x0
  801462:	e8 a0 f8 ff ff       	call   800d07 <sys_page_map>
  801467:	89 c7                	mov    %eax,%edi
  801469:	83 c4 20             	add    $0x20,%esp
  80146c:	85 c0                	test   %eax,%eax
  80146e:	78 2e                	js     80149e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801470:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801473:	89 d0                	mov    %edx,%eax
  801475:	c1 e8 0c             	shr    $0xc,%eax
  801478:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80147f:	83 ec 0c             	sub    $0xc,%esp
  801482:	25 07 0e 00 00       	and    $0xe07,%eax
  801487:	50                   	push   %eax
  801488:	53                   	push   %ebx
  801489:	6a 00                	push   $0x0
  80148b:	52                   	push   %edx
  80148c:	6a 00                	push   $0x0
  80148e:	e8 74 f8 ff ff       	call   800d07 <sys_page_map>
  801493:	89 c7                	mov    %eax,%edi
  801495:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801498:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80149a:	85 ff                	test   %edi,%edi
  80149c:	79 1d                	jns    8014bb <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80149e:	83 ec 08             	sub    $0x8,%esp
  8014a1:	53                   	push   %ebx
  8014a2:	6a 00                	push   $0x0
  8014a4:	e8 a0 f8 ff ff       	call   800d49 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014a9:	83 c4 08             	add    $0x8,%esp
  8014ac:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014af:	6a 00                	push   $0x0
  8014b1:	e8 93 f8 ff ff       	call   800d49 <sys_page_unmap>
	return r;
  8014b6:	83 c4 10             	add    $0x10,%esp
  8014b9:	89 f8                	mov    %edi,%eax
}
  8014bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014be:	5b                   	pop    %ebx
  8014bf:	5e                   	pop    %esi
  8014c0:	5f                   	pop    %edi
  8014c1:	5d                   	pop    %ebp
  8014c2:	c3                   	ret    

008014c3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014c3:	55                   	push   %ebp
  8014c4:	89 e5                	mov    %esp,%ebp
  8014c6:	53                   	push   %ebx
  8014c7:	83 ec 14             	sub    $0x14,%esp
  8014ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d0:	50                   	push   %eax
  8014d1:	53                   	push   %ebx
  8014d2:	e8 86 fd ff ff       	call   80125d <fd_lookup>
  8014d7:	83 c4 08             	add    $0x8,%esp
  8014da:	89 c2                	mov    %eax,%edx
  8014dc:	85 c0                	test   %eax,%eax
  8014de:	78 6d                	js     80154d <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e0:	83 ec 08             	sub    $0x8,%esp
  8014e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e6:	50                   	push   %eax
  8014e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ea:	ff 30                	pushl  (%eax)
  8014ec:	e8 c2 fd ff ff       	call   8012b3 <dev_lookup>
  8014f1:	83 c4 10             	add    $0x10,%esp
  8014f4:	85 c0                	test   %eax,%eax
  8014f6:	78 4c                	js     801544 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014fb:	8b 42 08             	mov    0x8(%edx),%eax
  8014fe:	83 e0 03             	and    $0x3,%eax
  801501:	83 f8 01             	cmp    $0x1,%eax
  801504:	75 21                	jne    801527 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801506:	a1 04 40 80 00       	mov    0x804004,%eax
  80150b:	8b 40 54             	mov    0x54(%eax),%eax
  80150e:	83 ec 04             	sub    $0x4,%esp
  801511:	53                   	push   %ebx
  801512:	50                   	push   %eax
  801513:	68 0c 28 80 00       	push   $0x80280c
  801518:	e8 1f ee ff ff       	call   80033c <cprintf>
		return -E_INVAL;
  80151d:	83 c4 10             	add    $0x10,%esp
  801520:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801525:	eb 26                	jmp    80154d <read+0x8a>
	}
	if (!dev->dev_read)
  801527:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80152a:	8b 40 08             	mov    0x8(%eax),%eax
  80152d:	85 c0                	test   %eax,%eax
  80152f:	74 17                	je     801548 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801531:	83 ec 04             	sub    $0x4,%esp
  801534:	ff 75 10             	pushl  0x10(%ebp)
  801537:	ff 75 0c             	pushl  0xc(%ebp)
  80153a:	52                   	push   %edx
  80153b:	ff d0                	call   *%eax
  80153d:	89 c2                	mov    %eax,%edx
  80153f:	83 c4 10             	add    $0x10,%esp
  801542:	eb 09                	jmp    80154d <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801544:	89 c2                	mov    %eax,%edx
  801546:	eb 05                	jmp    80154d <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801548:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80154d:	89 d0                	mov    %edx,%eax
  80154f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801552:	c9                   	leave  
  801553:	c3                   	ret    

00801554 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801554:	55                   	push   %ebp
  801555:	89 e5                	mov    %esp,%ebp
  801557:	57                   	push   %edi
  801558:	56                   	push   %esi
  801559:	53                   	push   %ebx
  80155a:	83 ec 0c             	sub    $0xc,%esp
  80155d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801560:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801563:	bb 00 00 00 00       	mov    $0x0,%ebx
  801568:	eb 21                	jmp    80158b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80156a:	83 ec 04             	sub    $0x4,%esp
  80156d:	89 f0                	mov    %esi,%eax
  80156f:	29 d8                	sub    %ebx,%eax
  801571:	50                   	push   %eax
  801572:	89 d8                	mov    %ebx,%eax
  801574:	03 45 0c             	add    0xc(%ebp),%eax
  801577:	50                   	push   %eax
  801578:	57                   	push   %edi
  801579:	e8 45 ff ff ff       	call   8014c3 <read>
		if (m < 0)
  80157e:	83 c4 10             	add    $0x10,%esp
  801581:	85 c0                	test   %eax,%eax
  801583:	78 10                	js     801595 <readn+0x41>
			return m;
		if (m == 0)
  801585:	85 c0                	test   %eax,%eax
  801587:	74 0a                	je     801593 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801589:	01 c3                	add    %eax,%ebx
  80158b:	39 f3                	cmp    %esi,%ebx
  80158d:	72 db                	jb     80156a <readn+0x16>
  80158f:	89 d8                	mov    %ebx,%eax
  801591:	eb 02                	jmp    801595 <readn+0x41>
  801593:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801595:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801598:	5b                   	pop    %ebx
  801599:	5e                   	pop    %esi
  80159a:	5f                   	pop    %edi
  80159b:	5d                   	pop    %ebp
  80159c:	c3                   	ret    

0080159d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80159d:	55                   	push   %ebp
  80159e:	89 e5                	mov    %esp,%ebp
  8015a0:	53                   	push   %ebx
  8015a1:	83 ec 14             	sub    $0x14,%esp
  8015a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015aa:	50                   	push   %eax
  8015ab:	53                   	push   %ebx
  8015ac:	e8 ac fc ff ff       	call   80125d <fd_lookup>
  8015b1:	83 c4 08             	add    $0x8,%esp
  8015b4:	89 c2                	mov    %eax,%edx
  8015b6:	85 c0                	test   %eax,%eax
  8015b8:	78 68                	js     801622 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ba:	83 ec 08             	sub    $0x8,%esp
  8015bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c0:	50                   	push   %eax
  8015c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c4:	ff 30                	pushl  (%eax)
  8015c6:	e8 e8 fc ff ff       	call   8012b3 <dev_lookup>
  8015cb:	83 c4 10             	add    $0x10,%esp
  8015ce:	85 c0                	test   %eax,%eax
  8015d0:	78 47                	js     801619 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015d9:	75 21                	jne    8015fc <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015db:	a1 04 40 80 00       	mov    0x804004,%eax
  8015e0:	8b 40 54             	mov    0x54(%eax),%eax
  8015e3:	83 ec 04             	sub    $0x4,%esp
  8015e6:	53                   	push   %ebx
  8015e7:	50                   	push   %eax
  8015e8:	68 28 28 80 00       	push   $0x802828
  8015ed:	e8 4a ed ff ff       	call   80033c <cprintf>
		return -E_INVAL;
  8015f2:	83 c4 10             	add    $0x10,%esp
  8015f5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015fa:	eb 26                	jmp    801622 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015ff:	8b 52 0c             	mov    0xc(%edx),%edx
  801602:	85 d2                	test   %edx,%edx
  801604:	74 17                	je     80161d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801606:	83 ec 04             	sub    $0x4,%esp
  801609:	ff 75 10             	pushl  0x10(%ebp)
  80160c:	ff 75 0c             	pushl  0xc(%ebp)
  80160f:	50                   	push   %eax
  801610:	ff d2                	call   *%edx
  801612:	89 c2                	mov    %eax,%edx
  801614:	83 c4 10             	add    $0x10,%esp
  801617:	eb 09                	jmp    801622 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801619:	89 c2                	mov    %eax,%edx
  80161b:	eb 05                	jmp    801622 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80161d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801622:	89 d0                	mov    %edx,%eax
  801624:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801627:	c9                   	leave  
  801628:	c3                   	ret    

00801629 <seek>:

int
seek(int fdnum, off_t offset)
{
  801629:	55                   	push   %ebp
  80162a:	89 e5                	mov    %esp,%ebp
  80162c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80162f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801632:	50                   	push   %eax
  801633:	ff 75 08             	pushl  0x8(%ebp)
  801636:	e8 22 fc ff ff       	call   80125d <fd_lookup>
  80163b:	83 c4 08             	add    $0x8,%esp
  80163e:	85 c0                	test   %eax,%eax
  801640:	78 0e                	js     801650 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801642:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801645:	8b 55 0c             	mov    0xc(%ebp),%edx
  801648:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80164b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801650:	c9                   	leave  
  801651:	c3                   	ret    

00801652 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801652:	55                   	push   %ebp
  801653:	89 e5                	mov    %esp,%ebp
  801655:	53                   	push   %ebx
  801656:	83 ec 14             	sub    $0x14,%esp
  801659:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80165c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80165f:	50                   	push   %eax
  801660:	53                   	push   %ebx
  801661:	e8 f7 fb ff ff       	call   80125d <fd_lookup>
  801666:	83 c4 08             	add    $0x8,%esp
  801669:	89 c2                	mov    %eax,%edx
  80166b:	85 c0                	test   %eax,%eax
  80166d:	78 65                	js     8016d4 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166f:	83 ec 08             	sub    $0x8,%esp
  801672:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801675:	50                   	push   %eax
  801676:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801679:	ff 30                	pushl  (%eax)
  80167b:	e8 33 fc ff ff       	call   8012b3 <dev_lookup>
  801680:	83 c4 10             	add    $0x10,%esp
  801683:	85 c0                	test   %eax,%eax
  801685:	78 44                	js     8016cb <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801687:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80168a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80168e:	75 21                	jne    8016b1 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801690:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801695:	8b 40 54             	mov    0x54(%eax),%eax
  801698:	83 ec 04             	sub    $0x4,%esp
  80169b:	53                   	push   %ebx
  80169c:	50                   	push   %eax
  80169d:	68 e8 27 80 00       	push   $0x8027e8
  8016a2:	e8 95 ec ff ff       	call   80033c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016a7:	83 c4 10             	add    $0x10,%esp
  8016aa:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016af:	eb 23                	jmp    8016d4 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016b4:	8b 52 18             	mov    0x18(%edx),%edx
  8016b7:	85 d2                	test   %edx,%edx
  8016b9:	74 14                	je     8016cf <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016bb:	83 ec 08             	sub    $0x8,%esp
  8016be:	ff 75 0c             	pushl  0xc(%ebp)
  8016c1:	50                   	push   %eax
  8016c2:	ff d2                	call   *%edx
  8016c4:	89 c2                	mov    %eax,%edx
  8016c6:	83 c4 10             	add    $0x10,%esp
  8016c9:	eb 09                	jmp    8016d4 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016cb:	89 c2                	mov    %eax,%edx
  8016cd:	eb 05                	jmp    8016d4 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016cf:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016d4:	89 d0                	mov    %edx,%eax
  8016d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d9:	c9                   	leave  
  8016da:	c3                   	ret    

008016db <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016db:	55                   	push   %ebp
  8016dc:	89 e5                	mov    %esp,%ebp
  8016de:	53                   	push   %ebx
  8016df:	83 ec 14             	sub    $0x14,%esp
  8016e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e8:	50                   	push   %eax
  8016e9:	ff 75 08             	pushl  0x8(%ebp)
  8016ec:	e8 6c fb ff ff       	call   80125d <fd_lookup>
  8016f1:	83 c4 08             	add    $0x8,%esp
  8016f4:	89 c2                	mov    %eax,%edx
  8016f6:	85 c0                	test   %eax,%eax
  8016f8:	78 58                	js     801752 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016fa:	83 ec 08             	sub    $0x8,%esp
  8016fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801700:	50                   	push   %eax
  801701:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801704:	ff 30                	pushl  (%eax)
  801706:	e8 a8 fb ff ff       	call   8012b3 <dev_lookup>
  80170b:	83 c4 10             	add    $0x10,%esp
  80170e:	85 c0                	test   %eax,%eax
  801710:	78 37                	js     801749 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801712:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801715:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801719:	74 32                	je     80174d <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80171b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80171e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801725:	00 00 00 
	stat->st_isdir = 0;
  801728:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80172f:	00 00 00 
	stat->st_dev = dev;
  801732:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801738:	83 ec 08             	sub    $0x8,%esp
  80173b:	53                   	push   %ebx
  80173c:	ff 75 f0             	pushl  -0x10(%ebp)
  80173f:	ff 50 14             	call   *0x14(%eax)
  801742:	89 c2                	mov    %eax,%edx
  801744:	83 c4 10             	add    $0x10,%esp
  801747:	eb 09                	jmp    801752 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801749:	89 c2                	mov    %eax,%edx
  80174b:	eb 05                	jmp    801752 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80174d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801752:	89 d0                	mov    %edx,%eax
  801754:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801757:	c9                   	leave  
  801758:	c3                   	ret    

00801759 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801759:	55                   	push   %ebp
  80175a:	89 e5                	mov    %esp,%ebp
  80175c:	56                   	push   %esi
  80175d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80175e:	83 ec 08             	sub    $0x8,%esp
  801761:	6a 00                	push   $0x0
  801763:	ff 75 08             	pushl  0x8(%ebp)
  801766:	e8 e3 01 00 00       	call   80194e <open>
  80176b:	89 c3                	mov    %eax,%ebx
  80176d:	83 c4 10             	add    $0x10,%esp
  801770:	85 c0                	test   %eax,%eax
  801772:	78 1b                	js     80178f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801774:	83 ec 08             	sub    $0x8,%esp
  801777:	ff 75 0c             	pushl  0xc(%ebp)
  80177a:	50                   	push   %eax
  80177b:	e8 5b ff ff ff       	call   8016db <fstat>
  801780:	89 c6                	mov    %eax,%esi
	close(fd);
  801782:	89 1c 24             	mov    %ebx,(%esp)
  801785:	e8 fd fb ff ff       	call   801387 <close>
	return r;
  80178a:	83 c4 10             	add    $0x10,%esp
  80178d:	89 f0                	mov    %esi,%eax
}
  80178f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801792:	5b                   	pop    %ebx
  801793:	5e                   	pop    %esi
  801794:	5d                   	pop    %ebp
  801795:	c3                   	ret    

00801796 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801796:	55                   	push   %ebp
  801797:	89 e5                	mov    %esp,%ebp
  801799:	56                   	push   %esi
  80179a:	53                   	push   %ebx
  80179b:	89 c6                	mov    %eax,%esi
  80179d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80179f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017a6:	75 12                	jne    8017ba <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017a8:	83 ec 0c             	sub    $0xc,%esp
  8017ab:	6a 01                	push   $0x1
  8017ad:	e8 88 08 00 00       	call   80203a <ipc_find_env>
  8017b2:	a3 00 40 80 00       	mov    %eax,0x804000
  8017b7:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017ba:	6a 07                	push   $0x7
  8017bc:	68 00 50 80 00       	push   $0x805000
  8017c1:	56                   	push   %esi
  8017c2:	ff 35 00 40 80 00    	pushl  0x804000
  8017c8:	e8 0b 08 00 00       	call   801fd8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017cd:	83 c4 0c             	add    $0xc,%esp
  8017d0:	6a 00                	push   $0x0
  8017d2:	53                   	push   %ebx
  8017d3:	6a 00                	push   $0x0
  8017d5:	e8 86 07 00 00       	call   801f60 <ipc_recv>
}
  8017da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017dd:	5b                   	pop    %ebx
  8017de:	5e                   	pop    %esi
  8017df:	5d                   	pop    %ebp
  8017e0:	c3                   	ret    

008017e1 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017e1:	55                   	push   %ebp
  8017e2:	89 e5                	mov    %esp,%ebp
  8017e4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ed:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017f5:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ff:	b8 02 00 00 00       	mov    $0x2,%eax
  801804:	e8 8d ff ff ff       	call   801796 <fsipc>
}
  801809:	c9                   	leave  
  80180a:	c3                   	ret    

0080180b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80180b:	55                   	push   %ebp
  80180c:	89 e5                	mov    %esp,%ebp
  80180e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801811:	8b 45 08             	mov    0x8(%ebp),%eax
  801814:	8b 40 0c             	mov    0xc(%eax),%eax
  801817:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80181c:	ba 00 00 00 00       	mov    $0x0,%edx
  801821:	b8 06 00 00 00       	mov    $0x6,%eax
  801826:	e8 6b ff ff ff       	call   801796 <fsipc>
}
  80182b:	c9                   	leave  
  80182c:	c3                   	ret    

0080182d <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80182d:	55                   	push   %ebp
  80182e:	89 e5                	mov    %esp,%ebp
  801830:	53                   	push   %ebx
  801831:	83 ec 04             	sub    $0x4,%esp
  801834:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801837:	8b 45 08             	mov    0x8(%ebp),%eax
  80183a:	8b 40 0c             	mov    0xc(%eax),%eax
  80183d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801842:	ba 00 00 00 00       	mov    $0x0,%edx
  801847:	b8 05 00 00 00       	mov    $0x5,%eax
  80184c:	e8 45 ff ff ff       	call   801796 <fsipc>
  801851:	85 c0                	test   %eax,%eax
  801853:	78 2c                	js     801881 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801855:	83 ec 08             	sub    $0x8,%esp
  801858:	68 00 50 80 00       	push   $0x805000
  80185d:	53                   	push   %ebx
  80185e:	e8 5e f0 ff ff       	call   8008c1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801863:	a1 80 50 80 00       	mov    0x805080,%eax
  801868:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80186e:	a1 84 50 80 00       	mov    0x805084,%eax
  801873:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801879:	83 c4 10             	add    $0x10,%esp
  80187c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801881:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801884:	c9                   	leave  
  801885:	c3                   	ret    

00801886 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801886:	55                   	push   %ebp
  801887:	89 e5                	mov    %esp,%ebp
  801889:	83 ec 0c             	sub    $0xc,%esp
  80188c:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80188f:	8b 55 08             	mov    0x8(%ebp),%edx
  801892:	8b 52 0c             	mov    0xc(%edx),%edx
  801895:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80189b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018a0:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018a5:	0f 47 c2             	cmova  %edx,%eax
  8018a8:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8018ad:	50                   	push   %eax
  8018ae:	ff 75 0c             	pushl  0xc(%ebp)
  8018b1:	68 08 50 80 00       	push   $0x805008
  8018b6:	e8 98 f1 ff ff       	call   800a53 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8018bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c0:	b8 04 00 00 00       	mov    $0x4,%eax
  8018c5:	e8 cc fe ff ff       	call   801796 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8018ca:	c9                   	leave  
  8018cb:	c3                   	ret    

008018cc <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018cc:	55                   	push   %ebp
  8018cd:	89 e5                	mov    %esp,%ebp
  8018cf:	56                   	push   %esi
  8018d0:	53                   	push   %ebx
  8018d1:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d7:	8b 40 0c             	mov    0xc(%eax),%eax
  8018da:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018df:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ea:	b8 03 00 00 00       	mov    $0x3,%eax
  8018ef:	e8 a2 fe ff ff       	call   801796 <fsipc>
  8018f4:	89 c3                	mov    %eax,%ebx
  8018f6:	85 c0                	test   %eax,%eax
  8018f8:	78 4b                	js     801945 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018fa:	39 c6                	cmp    %eax,%esi
  8018fc:	73 16                	jae    801914 <devfile_read+0x48>
  8018fe:	68 58 28 80 00       	push   $0x802858
  801903:	68 5f 28 80 00       	push   $0x80285f
  801908:	6a 7c                	push   $0x7c
  80190a:	68 74 28 80 00       	push   $0x802874
  80190f:	e8 4f e9 ff ff       	call   800263 <_panic>
	assert(r <= PGSIZE);
  801914:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801919:	7e 16                	jle    801931 <devfile_read+0x65>
  80191b:	68 7f 28 80 00       	push   $0x80287f
  801920:	68 5f 28 80 00       	push   $0x80285f
  801925:	6a 7d                	push   $0x7d
  801927:	68 74 28 80 00       	push   $0x802874
  80192c:	e8 32 e9 ff ff       	call   800263 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801931:	83 ec 04             	sub    $0x4,%esp
  801934:	50                   	push   %eax
  801935:	68 00 50 80 00       	push   $0x805000
  80193a:	ff 75 0c             	pushl  0xc(%ebp)
  80193d:	e8 11 f1 ff ff       	call   800a53 <memmove>
	return r;
  801942:	83 c4 10             	add    $0x10,%esp
}
  801945:	89 d8                	mov    %ebx,%eax
  801947:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80194a:	5b                   	pop    %ebx
  80194b:	5e                   	pop    %esi
  80194c:	5d                   	pop    %ebp
  80194d:	c3                   	ret    

0080194e <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	53                   	push   %ebx
  801952:	83 ec 20             	sub    $0x20,%esp
  801955:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801958:	53                   	push   %ebx
  801959:	e8 2a ef ff ff       	call   800888 <strlen>
  80195e:	83 c4 10             	add    $0x10,%esp
  801961:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801966:	7f 67                	jg     8019cf <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801968:	83 ec 0c             	sub    $0xc,%esp
  80196b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80196e:	50                   	push   %eax
  80196f:	e8 9a f8 ff ff       	call   80120e <fd_alloc>
  801974:	83 c4 10             	add    $0x10,%esp
		return r;
  801977:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801979:	85 c0                	test   %eax,%eax
  80197b:	78 57                	js     8019d4 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80197d:	83 ec 08             	sub    $0x8,%esp
  801980:	53                   	push   %ebx
  801981:	68 00 50 80 00       	push   $0x805000
  801986:	e8 36 ef ff ff       	call   8008c1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80198b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80198e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801993:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801996:	b8 01 00 00 00       	mov    $0x1,%eax
  80199b:	e8 f6 fd ff ff       	call   801796 <fsipc>
  8019a0:	89 c3                	mov    %eax,%ebx
  8019a2:	83 c4 10             	add    $0x10,%esp
  8019a5:	85 c0                	test   %eax,%eax
  8019a7:	79 14                	jns    8019bd <open+0x6f>
		fd_close(fd, 0);
  8019a9:	83 ec 08             	sub    $0x8,%esp
  8019ac:	6a 00                	push   $0x0
  8019ae:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b1:	e8 50 f9 ff ff       	call   801306 <fd_close>
		return r;
  8019b6:	83 c4 10             	add    $0x10,%esp
  8019b9:	89 da                	mov    %ebx,%edx
  8019bb:	eb 17                	jmp    8019d4 <open+0x86>
	}

	return fd2num(fd);
  8019bd:	83 ec 0c             	sub    $0xc,%esp
  8019c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c3:	e8 1f f8 ff ff       	call   8011e7 <fd2num>
  8019c8:	89 c2                	mov    %eax,%edx
  8019ca:	83 c4 10             	add    $0x10,%esp
  8019cd:	eb 05                	jmp    8019d4 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019cf:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019d4:	89 d0                	mov    %edx,%eax
  8019d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d9:	c9                   	leave  
  8019da:	c3                   	ret    

008019db <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019db:	55                   	push   %ebp
  8019dc:	89 e5                	mov    %esp,%ebp
  8019de:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e6:	b8 08 00 00 00       	mov    $0x8,%eax
  8019eb:	e8 a6 fd ff ff       	call   801796 <fsipc>
}
  8019f0:	c9                   	leave  
  8019f1:	c3                   	ret    

008019f2 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019f2:	55                   	push   %ebp
  8019f3:	89 e5                	mov    %esp,%ebp
  8019f5:	56                   	push   %esi
  8019f6:	53                   	push   %ebx
  8019f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019fa:	83 ec 0c             	sub    $0xc,%esp
  8019fd:	ff 75 08             	pushl  0x8(%ebp)
  801a00:	e8 f2 f7 ff ff       	call   8011f7 <fd2data>
  801a05:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a07:	83 c4 08             	add    $0x8,%esp
  801a0a:	68 8b 28 80 00       	push   $0x80288b
  801a0f:	53                   	push   %ebx
  801a10:	e8 ac ee ff ff       	call   8008c1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a15:	8b 46 04             	mov    0x4(%esi),%eax
  801a18:	2b 06                	sub    (%esi),%eax
  801a1a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a20:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a27:	00 00 00 
	stat->st_dev = &devpipe;
  801a2a:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a31:	30 80 00 
	return 0;
}
  801a34:	b8 00 00 00 00       	mov    $0x0,%eax
  801a39:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a3c:	5b                   	pop    %ebx
  801a3d:	5e                   	pop    %esi
  801a3e:	5d                   	pop    %ebp
  801a3f:	c3                   	ret    

00801a40 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a40:	55                   	push   %ebp
  801a41:	89 e5                	mov    %esp,%ebp
  801a43:	53                   	push   %ebx
  801a44:	83 ec 0c             	sub    $0xc,%esp
  801a47:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a4a:	53                   	push   %ebx
  801a4b:	6a 00                	push   $0x0
  801a4d:	e8 f7 f2 ff ff       	call   800d49 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a52:	89 1c 24             	mov    %ebx,(%esp)
  801a55:	e8 9d f7 ff ff       	call   8011f7 <fd2data>
  801a5a:	83 c4 08             	add    $0x8,%esp
  801a5d:	50                   	push   %eax
  801a5e:	6a 00                	push   $0x0
  801a60:	e8 e4 f2 ff ff       	call   800d49 <sys_page_unmap>
}
  801a65:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a68:	c9                   	leave  
  801a69:	c3                   	ret    

00801a6a <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a6a:	55                   	push   %ebp
  801a6b:	89 e5                	mov    %esp,%ebp
  801a6d:	57                   	push   %edi
  801a6e:	56                   	push   %esi
  801a6f:	53                   	push   %ebx
  801a70:	83 ec 1c             	sub    $0x1c,%esp
  801a73:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a76:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a78:	a1 04 40 80 00       	mov    0x804004,%eax
  801a7d:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a80:	83 ec 0c             	sub    $0xc,%esp
  801a83:	ff 75 e0             	pushl  -0x20(%ebp)
  801a86:	e8 ef 05 00 00       	call   80207a <pageref>
  801a8b:	89 c3                	mov    %eax,%ebx
  801a8d:	89 3c 24             	mov    %edi,(%esp)
  801a90:	e8 e5 05 00 00       	call   80207a <pageref>
  801a95:	83 c4 10             	add    $0x10,%esp
  801a98:	39 c3                	cmp    %eax,%ebx
  801a9a:	0f 94 c1             	sete   %cl
  801a9d:	0f b6 c9             	movzbl %cl,%ecx
  801aa0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801aa3:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801aa9:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  801aac:	39 ce                	cmp    %ecx,%esi
  801aae:	74 1b                	je     801acb <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ab0:	39 c3                	cmp    %eax,%ebx
  801ab2:	75 c4                	jne    801a78 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ab4:	8b 42 64             	mov    0x64(%edx),%eax
  801ab7:	ff 75 e4             	pushl  -0x1c(%ebp)
  801aba:	50                   	push   %eax
  801abb:	56                   	push   %esi
  801abc:	68 92 28 80 00       	push   $0x802892
  801ac1:	e8 76 e8 ff ff       	call   80033c <cprintf>
  801ac6:	83 c4 10             	add    $0x10,%esp
  801ac9:	eb ad                	jmp    801a78 <_pipeisclosed+0xe>
	}
}
  801acb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ace:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad1:	5b                   	pop    %ebx
  801ad2:	5e                   	pop    %esi
  801ad3:	5f                   	pop    %edi
  801ad4:	5d                   	pop    %ebp
  801ad5:	c3                   	ret    

00801ad6 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ad6:	55                   	push   %ebp
  801ad7:	89 e5                	mov    %esp,%ebp
  801ad9:	57                   	push   %edi
  801ada:	56                   	push   %esi
  801adb:	53                   	push   %ebx
  801adc:	83 ec 28             	sub    $0x28,%esp
  801adf:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ae2:	56                   	push   %esi
  801ae3:	e8 0f f7 ff ff       	call   8011f7 <fd2data>
  801ae8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aea:	83 c4 10             	add    $0x10,%esp
  801aed:	bf 00 00 00 00       	mov    $0x0,%edi
  801af2:	eb 4b                	jmp    801b3f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801af4:	89 da                	mov    %ebx,%edx
  801af6:	89 f0                	mov    %esi,%eax
  801af8:	e8 6d ff ff ff       	call   801a6a <_pipeisclosed>
  801afd:	85 c0                	test   %eax,%eax
  801aff:	75 48                	jne    801b49 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b01:	e8 9f f1 ff ff       	call   800ca5 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b06:	8b 43 04             	mov    0x4(%ebx),%eax
  801b09:	8b 0b                	mov    (%ebx),%ecx
  801b0b:	8d 51 20             	lea    0x20(%ecx),%edx
  801b0e:	39 d0                	cmp    %edx,%eax
  801b10:	73 e2                	jae    801af4 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b15:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b19:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b1c:	89 c2                	mov    %eax,%edx
  801b1e:	c1 fa 1f             	sar    $0x1f,%edx
  801b21:	89 d1                	mov    %edx,%ecx
  801b23:	c1 e9 1b             	shr    $0x1b,%ecx
  801b26:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b29:	83 e2 1f             	and    $0x1f,%edx
  801b2c:	29 ca                	sub    %ecx,%edx
  801b2e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b32:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b36:	83 c0 01             	add    $0x1,%eax
  801b39:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b3c:	83 c7 01             	add    $0x1,%edi
  801b3f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b42:	75 c2                	jne    801b06 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b44:	8b 45 10             	mov    0x10(%ebp),%eax
  801b47:	eb 05                	jmp    801b4e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b49:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b51:	5b                   	pop    %ebx
  801b52:	5e                   	pop    %esi
  801b53:	5f                   	pop    %edi
  801b54:	5d                   	pop    %ebp
  801b55:	c3                   	ret    

00801b56 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b56:	55                   	push   %ebp
  801b57:	89 e5                	mov    %esp,%ebp
  801b59:	57                   	push   %edi
  801b5a:	56                   	push   %esi
  801b5b:	53                   	push   %ebx
  801b5c:	83 ec 18             	sub    $0x18,%esp
  801b5f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b62:	57                   	push   %edi
  801b63:	e8 8f f6 ff ff       	call   8011f7 <fd2data>
  801b68:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b6a:	83 c4 10             	add    $0x10,%esp
  801b6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b72:	eb 3d                	jmp    801bb1 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b74:	85 db                	test   %ebx,%ebx
  801b76:	74 04                	je     801b7c <devpipe_read+0x26>
				return i;
  801b78:	89 d8                	mov    %ebx,%eax
  801b7a:	eb 44                	jmp    801bc0 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b7c:	89 f2                	mov    %esi,%edx
  801b7e:	89 f8                	mov    %edi,%eax
  801b80:	e8 e5 fe ff ff       	call   801a6a <_pipeisclosed>
  801b85:	85 c0                	test   %eax,%eax
  801b87:	75 32                	jne    801bbb <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b89:	e8 17 f1 ff ff       	call   800ca5 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b8e:	8b 06                	mov    (%esi),%eax
  801b90:	3b 46 04             	cmp    0x4(%esi),%eax
  801b93:	74 df                	je     801b74 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b95:	99                   	cltd   
  801b96:	c1 ea 1b             	shr    $0x1b,%edx
  801b99:	01 d0                	add    %edx,%eax
  801b9b:	83 e0 1f             	and    $0x1f,%eax
  801b9e:	29 d0                	sub    %edx,%eax
  801ba0:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ba5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ba8:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bab:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bae:	83 c3 01             	add    $0x1,%ebx
  801bb1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bb4:	75 d8                	jne    801b8e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bb6:	8b 45 10             	mov    0x10(%ebp),%eax
  801bb9:	eb 05                	jmp    801bc0 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bbb:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bc3:	5b                   	pop    %ebx
  801bc4:	5e                   	pop    %esi
  801bc5:	5f                   	pop    %edi
  801bc6:	5d                   	pop    %ebp
  801bc7:	c3                   	ret    

00801bc8 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bc8:	55                   	push   %ebp
  801bc9:	89 e5                	mov    %esp,%ebp
  801bcb:	56                   	push   %esi
  801bcc:	53                   	push   %ebx
  801bcd:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bd0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bd3:	50                   	push   %eax
  801bd4:	e8 35 f6 ff ff       	call   80120e <fd_alloc>
  801bd9:	83 c4 10             	add    $0x10,%esp
  801bdc:	89 c2                	mov    %eax,%edx
  801bde:	85 c0                	test   %eax,%eax
  801be0:	0f 88 2c 01 00 00    	js     801d12 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be6:	83 ec 04             	sub    $0x4,%esp
  801be9:	68 07 04 00 00       	push   $0x407
  801bee:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf1:	6a 00                	push   $0x0
  801bf3:	e8 cc f0 ff ff       	call   800cc4 <sys_page_alloc>
  801bf8:	83 c4 10             	add    $0x10,%esp
  801bfb:	89 c2                	mov    %eax,%edx
  801bfd:	85 c0                	test   %eax,%eax
  801bff:	0f 88 0d 01 00 00    	js     801d12 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c05:	83 ec 0c             	sub    $0xc,%esp
  801c08:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c0b:	50                   	push   %eax
  801c0c:	e8 fd f5 ff ff       	call   80120e <fd_alloc>
  801c11:	89 c3                	mov    %eax,%ebx
  801c13:	83 c4 10             	add    $0x10,%esp
  801c16:	85 c0                	test   %eax,%eax
  801c18:	0f 88 e2 00 00 00    	js     801d00 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c1e:	83 ec 04             	sub    $0x4,%esp
  801c21:	68 07 04 00 00       	push   $0x407
  801c26:	ff 75 f0             	pushl  -0x10(%ebp)
  801c29:	6a 00                	push   $0x0
  801c2b:	e8 94 f0 ff ff       	call   800cc4 <sys_page_alloc>
  801c30:	89 c3                	mov    %eax,%ebx
  801c32:	83 c4 10             	add    $0x10,%esp
  801c35:	85 c0                	test   %eax,%eax
  801c37:	0f 88 c3 00 00 00    	js     801d00 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c3d:	83 ec 0c             	sub    $0xc,%esp
  801c40:	ff 75 f4             	pushl  -0xc(%ebp)
  801c43:	e8 af f5 ff ff       	call   8011f7 <fd2data>
  801c48:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c4a:	83 c4 0c             	add    $0xc,%esp
  801c4d:	68 07 04 00 00       	push   $0x407
  801c52:	50                   	push   %eax
  801c53:	6a 00                	push   $0x0
  801c55:	e8 6a f0 ff ff       	call   800cc4 <sys_page_alloc>
  801c5a:	89 c3                	mov    %eax,%ebx
  801c5c:	83 c4 10             	add    $0x10,%esp
  801c5f:	85 c0                	test   %eax,%eax
  801c61:	0f 88 89 00 00 00    	js     801cf0 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c67:	83 ec 0c             	sub    $0xc,%esp
  801c6a:	ff 75 f0             	pushl  -0x10(%ebp)
  801c6d:	e8 85 f5 ff ff       	call   8011f7 <fd2data>
  801c72:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c79:	50                   	push   %eax
  801c7a:	6a 00                	push   $0x0
  801c7c:	56                   	push   %esi
  801c7d:	6a 00                	push   $0x0
  801c7f:	e8 83 f0 ff ff       	call   800d07 <sys_page_map>
  801c84:	89 c3                	mov    %eax,%ebx
  801c86:	83 c4 20             	add    $0x20,%esp
  801c89:	85 c0                	test   %eax,%eax
  801c8b:	78 55                	js     801ce2 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c8d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c96:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c9b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ca2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ca8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cab:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cb0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cb7:	83 ec 0c             	sub    $0xc,%esp
  801cba:	ff 75 f4             	pushl  -0xc(%ebp)
  801cbd:	e8 25 f5 ff ff       	call   8011e7 <fd2num>
  801cc2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cc5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cc7:	83 c4 04             	add    $0x4,%esp
  801cca:	ff 75 f0             	pushl  -0x10(%ebp)
  801ccd:	e8 15 f5 ff ff       	call   8011e7 <fd2num>
  801cd2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cd5:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801cd8:	83 c4 10             	add    $0x10,%esp
  801cdb:	ba 00 00 00 00       	mov    $0x0,%edx
  801ce0:	eb 30                	jmp    801d12 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ce2:	83 ec 08             	sub    $0x8,%esp
  801ce5:	56                   	push   %esi
  801ce6:	6a 00                	push   $0x0
  801ce8:	e8 5c f0 ff ff       	call   800d49 <sys_page_unmap>
  801ced:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cf0:	83 ec 08             	sub    $0x8,%esp
  801cf3:	ff 75 f0             	pushl  -0x10(%ebp)
  801cf6:	6a 00                	push   $0x0
  801cf8:	e8 4c f0 ff ff       	call   800d49 <sys_page_unmap>
  801cfd:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d00:	83 ec 08             	sub    $0x8,%esp
  801d03:	ff 75 f4             	pushl  -0xc(%ebp)
  801d06:	6a 00                	push   $0x0
  801d08:	e8 3c f0 ff ff       	call   800d49 <sys_page_unmap>
  801d0d:	83 c4 10             	add    $0x10,%esp
  801d10:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d12:	89 d0                	mov    %edx,%eax
  801d14:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d17:	5b                   	pop    %ebx
  801d18:	5e                   	pop    %esi
  801d19:	5d                   	pop    %ebp
  801d1a:	c3                   	ret    

00801d1b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d1b:	55                   	push   %ebp
  801d1c:	89 e5                	mov    %esp,%ebp
  801d1e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d24:	50                   	push   %eax
  801d25:	ff 75 08             	pushl  0x8(%ebp)
  801d28:	e8 30 f5 ff ff       	call   80125d <fd_lookup>
  801d2d:	83 c4 10             	add    $0x10,%esp
  801d30:	85 c0                	test   %eax,%eax
  801d32:	78 18                	js     801d4c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d34:	83 ec 0c             	sub    $0xc,%esp
  801d37:	ff 75 f4             	pushl  -0xc(%ebp)
  801d3a:	e8 b8 f4 ff ff       	call   8011f7 <fd2data>
	return _pipeisclosed(fd, p);
  801d3f:	89 c2                	mov    %eax,%edx
  801d41:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d44:	e8 21 fd ff ff       	call   801a6a <_pipeisclosed>
  801d49:	83 c4 10             	add    $0x10,%esp
}
  801d4c:	c9                   	leave  
  801d4d:	c3                   	ret    

00801d4e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d4e:	55                   	push   %ebp
  801d4f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d51:	b8 00 00 00 00       	mov    $0x0,%eax
  801d56:	5d                   	pop    %ebp
  801d57:	c3                   	ret    

00801d58 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d58:	55                   	push   %ebp
  801d59:	89 e5                	mov    %esp,%ebp
  801d5b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d5e:	68 aa 28 80 00       	push   $0x8028aa
  801d63:	ff 75 0c             	pushl  0xc(%ebp)
  801d66:	e8 56 eb ff ff       	call   8008c1 <strcpy>
	return 0;
}
  801d6b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d70:	c9                   	leave  
  801d71:	c3                   	ret    

00801d72 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d72:	55                   	push   %ebp
  801d73:	89 e5                	mov    %esp,%ebp
  801d75:	57                   	push   %edi
  801d76:	56                   	push   %esi
  801d77:	53                   	push   %ebx
  801d78:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d7e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d83:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d89:	eb 2d                	jmp    801db8 <devcons_write+0x46>
		m = n - tot;
  801d8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d8e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d90:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d93:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d98:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d9b:	83 ec 04             	sub    $0x4,%esp
  801d9e:	53                   	push   %ebx
  801d9f:	03 45 0c             	add    0xc(%ebp),%eax
  801da2:	50                   	push   %eax
  801da3:	57                   	push   %edi
  801da4:	e8 aa ec ff ff       	call   800a53 <memmove>
		sys_cputs(buf, m);
  801da9:	83 c4 08             	add    $0x8,%esp
  801dac:	53                   	push   %ebx
  801dad:	57                   	push   %edi
  801dae:	e8 55 ee ff ff       	call   800c08 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801db3:	01 de                	add    %ebx,%esi
  801db5:	83 c4 10             	add    $0x10,%esp
  801db8:	89 f0                	mov    %esi,%eax
  801dba:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dbd:	72 cc                	jb     801d8b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dc2:	5b                   	pop    %ebx
  801dc3:	5e                   	pop    %esi
  801dc4:	5f                   	pop    %edi
  801dc5:	5d                   	pop    %ebp
  801dc6:	c3                   	ret    

00801dc7 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dc7:	55                   	push   %ebp
  801dc8:	89 e5                	mov    %esp,%ebp
  801dca:	83 ec 08             	sub    $0x8,%esp
  801dcd:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801dd2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dd6:	74 2a                	je     801e02 <devcons_read+0x3b>
  801dd8:	eb 05                	jmp    801ddf <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801dda:	e8 c6 ee ff ff       	call   800ca5 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ddf:	e8 42 ee ff ff       	call   800c26 <sys_cgetc>
  801de4:	85 c0                	test   %eax,%eax
  801de6:	74 f2                	je     801dda <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801de8:	85 c0                	test   %eax,%eax
  801dea:	78 16                	js     801e02 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dec:	83 f8 04             	cmp    $0x4,%eax
  801def:	74 0c                	je     801dfd <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801df1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801df4:	88 02                	mov    %al,(%edx)
	return 1;
  801df6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dfb:	eb 05                	jmp    801e02 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801dfd:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e02:	c9                   	leave  
  801e03:	c3                   	ret    

00801e04 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e04:	55                   	push   %ebp
  801e05:	89 e5                	mov    %esp,%ebp
  801e07:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e10:	6a 01                	push   $0x1
  801e12:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e15:	50                   	push   %eax
  801e16:	e8 ed ed ff ff       	call   800c08 <sys_cputs>
}
  801e1b:	83 c4 10             	add    $0x10,%esp
  801e1e:	c9                   	leave  
  801e1f:	c3                   	ret    

00801e20 <getchar>:

int
getchar(void)
{
  801e20:	55                   	push   %ebp
  801e21:	89 e5                	mov    %esp,%ebp
  801e23:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e26:	6a 01                	push   $0x1
  801e28:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e2b:	50                   	push   %eax
  801e2c:	6a 00                	push   $0x0
  801e2e:	e8 90 f6 ff ff       	call   8014c3 <read>
	if (r < 0)
  801e33:	83 c4 10             	add    $0x10,%esp
  801e36:	85 c0                	test   %eax,%eax
  801e38:	78 0f                	js     801e49 <getchar+0x29>
		return r;
	if (r < 1)
  801e3a:	85 c0                	test   %eax,%eax
  801e3c:	7e 06                	jle    801e44 <getchar+0x24>
		return -E_EOF;
	return c;
  801e3e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e42:	eb 05                	jmp    801e49 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e44:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e49:	c9                   	leave  
  801e4a:	c3                   	ret    

00801e4b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e4b:	55                   	push   %ebp
  801e4c:	89 e5                	mov    %esp,%ebp
  801e4e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e51:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e54:	50                   	push   %eax
  801e55:	ff 75 08             	pushl  0x8(%ebp)
  801e58:	e8 00 f4 ff ff       	call   80125d <fd_lookup>
  801e5d:	83 c4 10             	add    $0x10,%esp
  801e60:	85 c0                	test   %eax,%eax
  801e62:	78 11                	js     801e75 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e67:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e6d:	39 10                	cmp    %edx,(%eax)
  801e6f:	0f 94 c0             	sete   %al
  801e72:	0f b6 c0             	movzbl %al,%eax
}
  801e75:	c9                   	leave  
  801e76:	c3                   	ret    

00801e77 <opencons>:

int
opencons(void)
{
  801e77:	55                   	push   %ebp
  801e78:	89 e5                	mov    %esp,%ebp
  801e7a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e7d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e80:	50                   	push   %eax
  801e81:	e8 88 f3 ff ff       	call   80120e <fd_alloc>
  801e86:	83 c4 10             	add    $0x10,%esp
		return r;
  801e89:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e8b:	85 c0                	test   %eax,%eax
  801e8d:	78 3e                	js     801ecd <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e8f:	83 ec 04             	sub    $0x4,%esp
  801e92:	68 07 04 00 00       	push   $0x407
  801e97:	ff 75 f4             	pushl  -0xc(%ebp)
  801e9a:	6a 00                	push   $0x0
  801e9c:	e8 23 ee ff ff       	call   800cc4 <sys_page_alloc>
  801ea1:	83 c4 10             	add    $0x10,%esp
		return r;
  801ea4:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ea6:	85 c0                	test   %eax,%eax
  801ea8:	78 23                	js     801ecd <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801eaa:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801eb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb3:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801eb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ebf:	83 ec 0c             	sub    $0xc,%esp
  801ec2:	50                   	push   %eax
  801ec3:	e8 1f f3 ff ff       	call   8011e7 <fd2num>
  801ec8:	89 c2                	mov    %eax,%edx
  801eca:	83 c4 10             	add    $0x10,%esp
}
  801ecd:	89 d0                	mov    %edx,%eax
  801ecf:	c9                   	leave  
  801ed0:	c3                   	ret    

00801ed1 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ed1:	55                   	push   %ebp
  801ed2:	89 e5                	mov    %esp,%ebp
  801ed4:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ed7:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ede:	75 2a                	jne    801f0a <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801ee0:	83 ec 04             	sub    $0x4,%esp
  801ee3:	6a 07                	push   $0x7
  801ee5:	68 00 f0 bf ee       	push   $0xeebff000
  801eea:	6a 00                	push   $0x0
  801eec:	e8 d3 ed ff ff       	call   800cc4 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801ef1:	83 c4 10             	add    $0x10,%esp
  801ef4:	85 c0                	test   %eax,%eax
  801ef6:	79 12                	jns    801f0a <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801ef8:	50                   	push   %eax
  801ef9:	68 b6 28 80 00       	push   $0x8028b6
  801efe:	6a 23                	push   $0x23
  801f00:	68 ba 28 80 00       	push   $0x8028ba
  801f05:	e8 59 e3 ff ff       	call   800263 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f0d:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801f12:	83 ec 08             	sub    $0x8,%esp
  801f15:	68 3c 1f 80 00       	push   $0x801f3c
  801f1a:	6a 00                	push   $0x0
  801f1c:	e8 ee ee ff ff       	call   800e0f <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801f21:	83 c4 10             	add    $0x10,%esp
  801f24:	85 c0                	test   %eax,%eax
  801f26:	79 12                	jns    801f3a <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801f28:	50                   	push   %eax
  801f29:	68 b6 28 80 00       	push   $0x8028b6
  801f2e:	6a 2c                	push   $0x2c
  801f30:	68 ba 28 80 00       	push   $0x8028ba
  801f35:	e8 29 e3 ff ff       	call   800263 <_panic>
	}
}
  801f3a:	c9                   	leave  
  801f3b:	c3                   	ret    

00801f3c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f3c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f3d:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f42:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f44:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801f47:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801f4b:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801f50:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801f54:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801f56:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801f59:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801f5a:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801f5d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801f5e:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f5f:	c3                   	ret    

00801f60 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f60:	55                   	push   %ebp
  801f61:	89 e5                	mov    %esp,%ebp
  801f63:	56                   	push   %esi
  801f64:	53                   	push   %ebx
  801f65:	8b 75 08             	mov    0x8(%ebp),%esi
  801f68:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801f6e:	85 c0                	test   %eax,%eax
  801f70:	75 12                	jne    801f84 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801f72:	83 ec 0c             	sub    $0xc,%esp
  801f75:	68 00 00 c0 ee       	push   $0xeec00000
  801f7a:	e8 f5 ee ff ff       	call   800e74 <sys_ipc_recv>
  801f7f:	83 c4 10             	add    $0x10,%esp
  801f82:	eb 0c                	jmp    801f90 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801f84:	83 ec 0c             	sub    $0xc,%esp
  801f87:	50                   	push   %eax
  801f88:	e8 e7 ee ff ff       	call   800e74 <sys_ipc_recv>
  801f8d:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801f90:	85 f6                	test   %esi,%esi
  801f92:	0f 95 c1             	setne  %cl
  801f95:	85 db                	test   %ebx,%ebx
  801f97:	0f 95 c2             	setne  %dl
  801f9a:	84 d1                	test   %dl,%cl
  801f9c:	74 09                	je     801fa7 <ipc_recv+0x47>
  801f9e:	89 c2                	mov    %eax,%edx
  801fa0:	c1 ea 1f             	shr    $0x1f,%edx
  801fa3:	84 d2                	test   %dl,%dl
  801fa5:	75 2a                	jne    801fd1 <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801fa7:	85 f6                	test   %esi,%esi
  801fa9:	74 0d                	je     801fb8 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801fab:	a1 04 40 80 00       	mov    0x804004,%eax
  801fb0:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801fb6:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801fb8:	85 db                	test   %ebx,%ebx
  801fba:	74 0d                	je     801fc9 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801fbc:	a1 04 40 80 00       	mov    0x804004,%eax
  801fc1:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  801fc7:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801fc9:	a1 04 40 80 00       	mov    0x804004,%eax
  801fce:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  801fd1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fd4:	5b                   	pop    %ebx
  801fd5:	5e                   	pop    %esi
  801fd6:	5d                   	pop    %ebp
  801fd7:	c3                   	ret    

00801fd8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fd8:	55                   	push   %ebp
  801fd9:	89 e5                	mov    %esp,%ebp
  801fdb:	57                   	push   %edi
  801fdc:	56                   	push   %esi
  801fdd:	53                   	push   %ebx
  801fde:	83 ec 0c             	sub    $0xc,%esp
  801fe1:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fe4:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fe7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801fea:	85 db                	test   %ebx,%ebx
  801fec:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ff1:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801ff4:	ff 75 14             	pushl  0x14(%ebp)
  801ff7:	53                   	push   %ebx
  801ff8:	56                   	push   %esi
  801ff9:	57                   	push   %edi
  801ffa:	e8 52 ee ff ff       	call   800e51 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801fff:	89 c2                	mov    %eax,%edx
  802001:	c1 ea 1f             	shr    $0x1f,%edx
  802004:	83 c4 10             	add    $0x10,%esp
  802007:	84 d2                	test   %dl,%dl
  802009:	74 17                	je     802022 <ipc_send+0x4a>
  80200b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80200e:	74 12                	je     802022 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802010:	50                   	push   %eax
  802011:	68 c8 28 80 00       	push   $0x8028c8
  802016:	6a 47                	push   $0x47
  802018:	68 d6 28 80 00       	push   $0x8028d6
  80201d:	e8 41 e2 ff ff       	call   800263 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802022:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802025:	75 07                	jne    80202e <ipc_send+0x56>
			sys_yield();
  802027:	e8 79 ec ff ff       	call   800ca5 <sys_yield>
  80202c:	eb c6                	jmp    801ff4 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80202e:	85 c0                	test   %eax,%eax
  802030:	75 c2                	jne    801ff4 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802032:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802035:	5b                   	pop    %ebx
  802036:	5e                   	pop    %esi
  802037:	5f                   	pop    %edi
  802038:	5d                   	pop    %ebp
  802039:	c3                   	ret    

0080203a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80203a:	55                   	push   %ebp
  80203b:	89 e5                	mov    %esp,%ebp
  80203d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802040:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802045:	89 c2                	mov    %eax,%edx
  802047:	c1 e2 07             	shl    $0x7,%edx
  80204a:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  802051:	8b 52 5c             	mov    0x5c(%edx),%edx
  802054:	39 ca                	cmp    %ecx,%edx
  802056:	75 11                	jne    802069 <ipc_find_env+0x2f>
			return envs[i].env_id;
  802058:	89 c2                	mov    %eax,%edx
  80205a:	c1 e2 07             	shl    $0x7,%edx
  80205d:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  802064:	8b 40 54             	mov    0x54(%eax),%eax
  802067:	eb 0f                	jmp    802078 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802069:	83 c0 01             	add    $0x1,%eax
  80206c:	3d 00 04 00 00       	cmp    $0x400,%eax
  802071:	75 d2                	jne    802045 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802073:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802078:	5d                   	pop    %ebp
  802079:	c3                   	ret    

0080207a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80207a:	55                   	push   %ebp
  80207b:	89 e5                	mov    %esp,%ebp
  80207d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802080:	89 d0                	mov    %edx,%eax
  802082:	c1 e8 16             	shr    $0x16,%eax
  802085:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80208c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802091:	f6 c1 01             	test   $0x1,%cl
  802094:	74 1d                	je     8020b3 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802096:	c1 ea 0c             	shr    $0xc,%edx
  802099:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020a0:	f6 c2 01             	test   $0x1,%dl
  8020a3:	74 0e                	je     8020b3 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020a5:	c1 ea 0c             	shr    $0xc,%edx
  8020a8:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020af:	ef 
  8020b0:	0f b7 c0             	movzwl %ax,%eax
}
  8020b3:	5d                   	pop    %ebp
  8020b4:	c3                   	ret    
  8020b5:	66 90                	xchg   %ax,%ax
  8020b7:	66 90                	xchg   %ax,%ax
  8020b9:	66 90                	xchg   %ax,%ax
  8020bb:	66 90                	xchg   %ax,%ax
  8020bd:	66 90                	xchg   %ax,%ax
  8020bf:	90                   	nop

008020c0 <__udivdi3>:
  8020c0:	55                   	push   %ebp
  8020c1:	57                   	push   %edi
  8020c2:	56                   	push   %esi
  8020c3:	53                   	push   %ebx
  8020c4:	83 ec 1c             	sub    $0x1c,%esp
  8020c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020d7:	85 f6                	test   %esi,%esi
  8020d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020dd:	89 ca                	mov    %ecx,%edx
  8020df:	89 f8                	mov    %edi,%eax
  8020e1:	75 3d                	jne    802120 <__udivdi3+0x60>
  8020e3:	39 cf                	cmp    %ecx,%edi
  8020e5:	0f 87 c5 00 00 00    	ja     8021b0 <__udivdi3+0xf0>
  8020eb:	85 ff                	test   %edi,%edi
  8020ed:	89 fd                	mov    %edi,%ebp
  8020ef:	75 0b                	jne    8020fc <__udivdi3+0x3c>
  8020f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020f6:	31 d2                	xor    %edx,%edx
  8020f8:	f7 f7                	div    %edi
  8020fa:	89 c5                	mov    %eax,%ebp
  8020fc:	89 c8                	mov    %ecx,%eax
  8020fe:	31 d2                	xor    %edx,%edx
  802100:	f7 f5                	div    %ebp
  802102:	89 c1                	mov    %eax,%ecx
  802104:	89 d8                	mov    %ebx,%eax
  802106:	89 cf                	mov    %ecx,%edi
  802108:	f7 f5                	div    %ebp
  80210a:	89 c3                	mov    %eax,%ebx
  80210c:	89 d8                	mov    %ebx,%eax
  80210e:	89 fa                	mov    %edi,%edx
  802110:	83 c4 1c             	add    $0x1c,%esp
  802113:	5b                   	pop    %ebx
  802114:	5e                   	pop    %esi
  802115:	5f                   	pop    %edi
  802116:	5d                   	pop    %ebp
  802117:	c3                   	ret    
  802118:	90                   	nop
  802119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802120:	39 ce                	cmp    %ecx,%esi
  802122:	77 74                	ja     802198 <__udivdi3+0xd8>
  802124:	0f bd fe             	bsr    %esi,%edi
  802127:	83 f7 1f             	xor    $0x1f,%edi
  80212a:	0f 84 98 00 00 00    	je     8021c8 <__udivdi3+0x108>
  802130:	bb 20 00 00 00       	mov    $0x20,%ebx
  802135:	89 f9                	mov    %edi,%ecx
  802137:	89 c5                	mov    %eax,%ebp
  802139:	29 fb                	sub    %edi,%ebx
  80213b:	d3 e6                	shl    %cl,%esi
  80213d:	89 d9                	mov    %ebx,%ecx
  80213f:	d3 ed                	shr    %cl,%ebp
  802141:	89 f9                	mov    %edi,%ecx
  802143:	d3 e0                	shl    %cl,%eax
  802145:	09 ee                	or     %ebp,%esi
  802147:	89 d9                	mov    %ebx,%ecx
  802149:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80214d:	89 d5                	mov    %edx,%ebp
  80214f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802153:	d3 ed                	shr    %cl,%ebp
  802155:	89 f9                	mov    %edi,%ecx
  802157:	d3 e2                	shl    %cl,%edx
  802159:	89 d9                	mov    %ebx,%ecx
  80215b:	d3 e8                	shr    %cl,%eax
  80215d:	09 c2                	or     %eax,%edx
  80215f:	89 d0                	mov    %edx,%eax
  802161:	89 ea                	mov    %ebp,%edx
  802163:	f7 f6                	div    %esi
  802165:	89 d5                	mov    %edx,%ebp
  802167:	89 c3                	mov    %eax,%ebx
  802169:	f7 64 24 0c          	mull   0xc(%esp)
  80216d:	39 d5                	cmp    %edx,%ebp
  80216f:	72 10                	jb     802181 <__udivdi3+0xc1>
  802171:	8b 74 24 08          	mov    0x8(%esp),%esi
  802175:	89 f9                	mov    %edi,%ecx
  802177:	d3 e6                	shl    %cl,%esi
  802179:	39 c6                	cmp    %eax,%esi
  80217b:	73 07                	jae    802184 <__udivdi3+0xc4>
  80217d:	39 d5                	cmp    %edx,%ebp
  80217f:	75 03                	jne    802184 <__udivdi3+0xc4>
  802181:	83 eb 01             	sub    $0x1,%ebx
  802184:	31 ff                	xor    %edi,%edi
  802186:	89 d8                	mov    %ebx,%eax
  802188:	89 fa                	mov    %edi,%edx
  80218a:	83 c4 1c             	add    $0x1c,%esp
  80218d:	5b                   	pop    %ebx
  80218e:	5e                   	pop    %esi
  80218f:	5f                   	pop    %edi
  802190:	5d                   	pop    %ebp
  802191:	c3                   	ret    
  802192:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802198:	31 ff                	xor    %edi,%edi
  80219a:	31 db                	xor    %ebx,%ebx
  80219c:	89 d8                	mov    %ebx,%eax
  80219e:	89 fa                	mov    %edi,%edx
  8021a0:	83 c4 1c             	add    $0x1c,%esp
  8021a3:	5b                   	pop    %ebx
  8021a4:	5e                   	pop    %esi
  8021a5:	5f                   	pop    %edi
  8021a6:	5d                   	pop    %ebp
  8021a7:	c3                   	ret    
  8021a8:	90                   	nop
  8021a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	89 d8                	mov    %ebx,%eax
  8021b2:	f7 f7                	div    %edi
  8021b4:	31 ff                	xor    %edi,%edi
  8021b6:	89 c3                	mov    %eax,%ebx
  8021b8:	89 d8                	mov    %ebx,%eax
  8021ba:	89 fa                	mov    %edi,%edx
  8021bc:	83 c4 1c             	add    $0x1c,%esp
  8021bf:	5b                   	pop    %ebx
  8021c0:	5e                   	pop    %esi
  8021c1:	5f                   	pop    %edi
  8021c2:	5d                   	pop    %ebp
  8021c3:	c3                   	ret    
  8021c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021c8:	39 ce                	cmp    %ecx,%esi
  8021ca:	72 0c                	jb     8021d8 <__udivdi3+0x118>
  8021cc:	31 db                	xor    %ebx,%ebx
  8021ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021d2:	0f 87 34 ff ff ff    	ja     80210c <__udivdi3+0x4c>
  8021d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021dd:	e9 2a ff ff ff       	jmp    80210c <__udivdi3+0x4c>
  8021e2:	66 90                	xchg   %ax,%ax
  8021e4:	66 90                	xchg   %ax,%ax
  8021e6:	66 90                	xchg   %ax,%ax
  8021e8:	66 90                	xchg   %ax,%ax
  8021ea:	66 90                	xchg   %ax,%ax
  8021ec:	66 90                	xchg   %ax,%ax
  8021ee:	66 90                	xchg   %ax,%ax

008021f0 <__umoddi3>:
  8021f0:	55                   	push   %ebp
  8021f1:	57                   	push   %edi
  8021f2:	56                   	push   %esi
  8021f3:	53                   	push   %ebx
  8021f4:	83 ec 1c             	sub    $0x1c,%esp
  8021f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802203:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802207:	85 d2                	test   %edx,%edx
  802209:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80220d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802211:	89 f3                	mov    %esi,%ebx
  802213:	89 3c 24             	mov    %edi,(%esp)
  802216:	89 74 24 04          	mov    %esi,0x4(%esp)
  80221a:	75 1c                	jne    802238 <__umoddi3+0x48>
  80221c:	39 f7                	cmp    %esi,%edi
  80221e:	76 50                	jbe    802270 <__umoddi3+0x80>
  802220:	89 c8                	mov    %ecx,%eax
  802222:	89 f2                	mov    %esi,%edx
  802224:	f7 f7                	div    %edi
  802226:	89 d0                	mov    %edx,%eax
  802228:	31 d2                	xor    %edx,%edx
  80222a:	83 c4 1c             	add    $0x1c,%esp
  80222d:	5b                   	pop    %ebx
  80222e:	5e                   	pop    %esi
  80222f:	5f                   	pop    %edi
  802230:	5d                   	pop    %ebp
  802231:	c3                   	ret    
  802232:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802238:	39 f2                	cmp    %esi,%edx
  80223a:	89 d0                	mov    %edx,%eax
  80223c:	77 52                	ja     802290 <__umoddi3+0xa0>
  80223e:	0f bd ea             	bsr    %edx,%ebp
  802241:	83 f5 1f             	xor    $0x1f,%ebp
  802244:	75 5a                	jne    8022a0 <__umoddi3+0xb0>
  802246:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80224a:	0f 82 e0 00 00 00    	jb     802330 <__umoddi3+0x140>
  802250:	39 0c 24             	cmp    %ecx,(%esp)
  802253:	0f 86 d7 00 00 00    	jbe    802330 <__umoddi3+0x140>
  802259:	8b 44 24 08          	mov    0x8(%esp),%eax
  80225d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802261:	83 c4 1c             	add    $0x1c,%esp
  802264:	5b                   	pop    %ebx
  802265:	5e                   	pop    %esi
  802266:	5f                   	pop    %edi
  802267:	5d                   	pop    %ebp
  802268:	c3                   	ret    
  802269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802270:	85 ff                	test   %edi,%edi
  802272:	89 fd                	mov    %edi,%ebp
  802274:	75 0b                	jne    802281 <__umoddi3+0x91>
  802276:	b8 01 00 00 00       	mov    $0x1,%eax
  80227b:	31 d2                	xor    %edx,%edx
  80227d:	f7 f7                	div    %edi
  80227f:	89 c5                	mov    %eax,%ebp
  802281:	89 f0                	mov    %esi,%eax
  802283:	31 d2                	xor    %edx,%edx
  802285:	f7 f5                	div    %ebp
  802287:	89 c8                	mov    %ecx,%eax
  802289:	f7 f5                	div    %ebp
  80228b:	89 d0                	mov    %edx,%eax
  80228d:	eb 99                	jmp    802228 <__umoddi3+0x38>
  80228f:	90                   	nop
  802290:	89 c8                	mov    %ecx,%eax
  802292:	89 f2                	mov    %esi,%edx
  802294:	83 c4 1c             	add    $0x1c,%esp
  802297:	5b                   	pop    %ebx
  802298:	5e                   	pop    %esi
  802299:	5f                   	pop    %edi
  80229a:	5d                   	pop    %ebp
  80229b:	c3                   	ret    
  80229c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022a0:	8b 34 24             	mov    (%esp),%esi
  8022a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022a8:	89 e9                	mov    %ebp,%ecx
  8022aa:	29 ef                	sub    %ebp,%edi
  8022ac:	d3 e0                	shl    %cl,%eax
  8022ae:	89 f9                	mov    %edi,%ecx
  8022b0:	89 f2                	mov    %esi,%edx
  8022b2:	d3 ea                	shr    %cl,%edx
  8022b4:	89 e9                	mov    %ebp,%ecx
  8022b6:	09 c2                	or     %eax,%edx
  8022b8:	89 d8                	mov    %ebx,%eax
  8022ba:	89 14 24             	mov    %edx,(%esp)
  8022bd:	89 f2                	mov    %esi,%edx
  8022bf:	d3 e2                	shl    %cl,%edx
  8022c1:	89 f9                	mov    %edi,%ecx
  8022c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022cb:	d3 e8                	shr    %cl,%eax
  8022cd:	89 e9                	mov    %ebp,%ecx
  8022cf:	89 c6                	mov    %eax,%esi
  8022d1:	d3 e3                	shl    %cl,%ebx
  8022d3:	89 f9                	mov    %edi,%ecx
  8022d5:	89 d0                	mov    %edx,%eax
  8022d7:	d3 e8                	shr    %cl,%eax
  8022d9:	89 e9                	mov    %ebp,%ecx
  8022db:	09 d8                	or     %ebx,%eax
  8022dd:	89 d3                	mov    %edx,%ebx
  8022df:	89 f2                	mov    %esi,%edx
  8022e1:	f7 34 24             	divl   (%esp)
  8022e4:	89 d6                	mov    %edx,%esi
  8022e6:	d3 e3                	shl    %cl,%ebx
  8022e8:	f7 64 24 04          	mull   0x4(%esp)
  8022ec:	39 d6                	cmp    %edx,%esi
  8022ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022f2:	89 d1                	mov    %edx,%ecx
  8022f4:	89 c3                	mov    %eax,%ebx
  8022f6:	72 08                	jb     802300 <__umoddi3+0x110>
  8022f8:	75 11                	jne    80230b <__umoddi3+0x11b>
  8022fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022fe:	73 0b                	jae    80230b <__umoddi3+0x11b>
  802300:	2b 44 24 04          	sub    0x4(%esp),%eax
  802304:	1b 14 24             	sbb    (%esp),%edx
  802307:	89 d1                	mov    %edx,%ecx
  802309:	89 c3                	mov    %eax,%ebx
  80230b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80230f:	29 da                	sub    %ebx,%edx
  802311:	19 ce                	sbb    %ecx,%esi
  802313:	89 f9                	mov    %edi,%ecx
  802315:	89 f0                	mov    %esi,%eax
  802317:	d3 e0                	shl    %cl,%eax
  802319:	89 e9                	mov    %ebp,%ecx
  80231b:	d3 ea                	shr    %cl,%edx
  80231d:	89 e9                	mov    %ebp,%ecx
  80231f:	d3 ee                	shr    %cl,%esi
  802321:	09 d0                	or     %edx,%eax
  802323:	89 f2                	mov    %esi,%edx
  802325:	83 c4 1c             	add    $0x1c,%esp
  802328:	5b                   	pop    %ebx
  802329:	5e                   	pop    %esi
  80232a:	5f                   	pop    %edi
  80232b:	5d                   	pop    %ebp
  80232c:	c3                   	ret    
  80232d:	8d 76 00             	lea    0x0(%esi),%esi
  802330:	29 f9                	sub    %edi,%ecx
  802332:	19 d6                	sbb    %edx,%esi
  802334:	89 74 24 04          	mov    %esi,0x4(%esp)
  802338:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80233c:	e9 18 ff ff ff       	jmp    802259 <__umoddi3+0x69>
