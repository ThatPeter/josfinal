
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
  80002c:	e8 ad 01 00 00       	call   8001de <libmain>
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
  800045:	e8 78 0c 00 00       	call   800cc2 <sys_page_alloc>
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800051:	50                   	push   %eax
  800052:	68 a0 25 80 00       	push   $0x8025a0
  800057:	6a 20                	push   $0x20
  800059:	68 b3 25 80 00       	push   $0x8025b3
  80005e:	e8 fe 01 00 00       	call   800261 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800063:	83 ec 0c             	sub    $0xc,%esp
  800066:	6a 07                	push   $0x7
  800068:	68 00 00 40 00       	push   $0x400000
  80006d:	6a 00                	push   $0x0
  80006f:	53                   	push   %ebx
  800070:	56                   	push   %esi
  800071:	e8 8f 0c 00 00       	call   800d05 <sys_page_map>
  800076:	83 c4 20             	add    $0x20,%esp
  800079:	85 c0                	test   %eax,%eax
  80007b:	79 12                	jns    80008f <duppage+0x5c>
		panic("sys_page_map: %e", r);
  80007d:	50                   	push   %eax
  80007e:	68 c3 25 80 00       	push   $0x8025c3
  800083:	6a 22                	push   $0x22
  800085:	68 b3 25 80 00       	push   $0x8025b3
  80008a:	e8 d2 01 00 00       	call   800261 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  80008f:	83 ec 04             	sub    $0x4,%esp
  800092:	68 00 10 00 00       	push   $0x1000
  800097:	53                   	push   %ebx
  800098:	68 00 00 40 00       	push   $0x400000
  80009d:	e8 af 09 00 00       	call   800a51 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	68 00 00 40 00       	push   $0x400000
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 96 0c 00 00       	call   800d47 <sys_page_unmap>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	79 12                	jns    8000ca <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  8000b8:	50                   	push   %eax
  8000b9:	68 d4 25 80 00       	push   $0x8025d4
  8000be:	6a 25                	push   $0x25
  8000c0:	68 b3 25 80 00       	push   $0x8025b3
  8000c5:	e8 97 01 00 00       	call   800261 <_panic>
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
  8000e7:	68 e7 25 80 00       	push   $0x8025e7
  8000ec:	6a 37                	push   $0x37
  8000ee:	68 b3 25 80 00       	push   $0x8025b3
  8000f3:	e8 69 01 00 00       	call   800261 <_panic>
  8000f8:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	75 21                	jne    80011f <dumbfork+0x4e>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8000fe:	e8 81 0b 00 00       	call   800c84 <sys_getenvid>
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
  800108:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  80010e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800113:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800118:	b8 00 00 00 00       	mov    $0x0,%eax
  80011d:	eb 60                	jmp    80017f <dumbfork+0xae>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80011f:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800126:	eb 14                	jmp    80013c <dumbfork+0x6b>
		duppage(envid, addr);
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	52                   	push   %edx
  80012c:	56                   	push   %esi
  80012d:	e8 01 ff ff ff       	call   800033 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800132:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800139:	83 c4 10             	add    $0x10,%esp
  80013c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80013f:	81 fa 04 60 80 00    	cmp    $0x806004,%edx
  800145:	72 e1                	jb     800128 <dumbfork+0x57>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800147:	83 ec 08             	sub    $0x8,%esp
  80014a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80014d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800152:	50                   	push   %eax
  800153:	53                   	push   %ebx
  800154:	e8 da fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800159:	83 c4 08             	add    $0x8,%esp
  80015c:	6a 02                	push   $0x2
  80015e:	53                   	push   %ebx
  80015f:	e8 25 0c 00 00       	call   800d89 <sys_env_set_status>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	85 c0                	test   %eax,%eax
  800169:	79 12                	jns    80017d <dumbfork+0xac>
		panic("sys_env_set_status: %e", r);
  80016b:	50                   	push   %eax
  80016c:	68 f7 25 80 00       	push   $0x8025f7
  800171:	6a 4c                	push   $0x4c
  800173:	68 b3 25 80 00       	push   $0x8025b3
  800178:	e8 e4 00 00 00       	call   800261 <_panic>

	return envid;
  80017d:	89 d8                	mov    %ebx,%eax
}
  80017f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800182:	5b                   	pop    %ebx
  800183:	5e                   	pop    %esi
  800184:	5d                   	pop    %ebp
  800185:	c3                   	ret    

00800186 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  800186:	55                   	push   %ebp
  800187:	89 e5                	mov    %esp,%ebp
  800189:	57                   	push   %edi
  80018a:	56                   	push   %esi
  80018b:	53                   	push   %ebx
  80018c:	83 ec 0c             	sub    $0xc,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  80018f:	e8 3d ff ff ff       	call   8000d1 <dumbfork>
  800194:	89 c7                	mov    %eax,%edi
  800196:	85 c0                	test   %eax,%eax
  800198:	be 15 26 80 00       	mov    $0x802615,%esi
  80019d:	b8 0e 26 80 00       	mov    $0x80260e,%eax
  8001a2:	0f 45 f0             	cmovne %eax,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001aa:	eb 1a                	jmp    8001c6 <umain+0x40>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001ac:	83 ec 04             	sub    $0x4,%esp
  8001af:	56                   	push   %esi
  8001b0:	53                   	push   %ebx
  8001b1:	68 1b 26 80 00       	push   $0x80261b
  8001b6:	e8 7f 01 00 00       	call   80033a <cprintf>
		sys_yield();
  8001bb:	e8 e3 0a 00 00       	call   800ca3 <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001c0:	83 c3 01             	add    $0x1,%ebx
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	85 ff                	test   %edi,%edi
  8001c8:	74 07                	je     8001d1 <umain+0x4b>
  8001ca:	83 fb 09             	cmp    $0x9,%ebx
  8001cd:	7e dd                	jle    8001ac <umain+0x26>
  8001cf:	eb 05                	jmp    8001d6 <umain+0x50>
  8001d1:	83 fb 13             	cmp    $0x13,%ebx
  8001d4:	7e d6                	jle    8001ac <umain+0x26>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  8001d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d9:	5b                   	pop    %ebx
  8001da:	5e                   	pop    %esi
  8001db:	5f                   	pop    %edi
  8001dc:	5d                   	pop    %ebp
  8001dd:	c3                   	ret    

008001de <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001de:	55                   	push   %ebp
  8001df:	89 e5                	mov    %esp,%ebp
  8001e1:	56                   	push   %esi
  8001e2:	53                   	push   %ebx
  8001e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001e6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001e9:	e8 96 0a 00 00       	call   800c84 <sys_getenvid>
  8001ee:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f3:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8001f9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001fe:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800203:	85 db                	test   %ebx,%ebx
  800205:	7e 07                	jle    80020e <libmain+0x30>
		binaryname = argv[0];
  800207:	8b 06                	mov    (%esi),%eax
  800209:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80020e:	83 ec 08             	sub    $0x8,%esp
  800211:	56                   	push   %esi
  800212:	53                   	push   %ebx
  800213:	e8 6e ff ff ff       	call   800186 <umain>

	// exit gracefully
	exit();
  800218:	e8 2a 00 00 00       	call   800247 <exit>
}
  80021d:	83 c4 10             	add    $0x10,%esp
  800220:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800223:	5b                   	pop    %ebx
  800224:	5e                   	pop    %esi
  800225:	5d                   	pop    %ebp
  800226:	c3                   	ret    

00800227 <thread_main>:

/*Lab 7: Multithreading thread main routine*/
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  800227:	55                   	push   %ebp
  800228:	89 e5                	mov    %esp,%ebp
  80022a:	83 ec 08             	sub    $0x8,%esp
	void (*func)(void) = (void (*)(void))eip;
  80022d:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  800232:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800234:	e8 4b 0a 00 00       	call   800c84 <sys_getenvid>
  800239:	83 ec 0c             	sub    $0xc,%esp
  80023c:	50                   	push   %eax
  80023d:	e8 91 0c 00 00       	call   800ed3 <sys_thread_free>
}
  800242:	83 c4 10             	add    $0x10,%esp
  800245:	c9                   	leave  
  800246:	c3                   	ret    

00800247 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800247:	55                   	push   %ebp
  800248:	89 e5                	mov    %esp,%ebp
  80024a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80024d:	e8 89 13 00 00       	call   8015db <close_all>
	sys_env_destroy(0);
  800252:	83 ec 0c             	sub    $0xc,%esp
  800255:	6a 00                	push   $0x0
  800257:	e8 e7 09 00 00       	call   800c43 <sys_env_destroy>
}
  80025c:	83 c4 10             	add    $0x10,%esp
  80025f:	c9                   	leave  
  800260:	c3                   	ret    

00800261 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800261:	55                   	push   %ebp
  800262:	89 e5                	mov    %esp,%ebp
  800264:	56                   	push   %esi
  800265:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800266:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800269:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80026f:	e8 10 0a 00 00       	call   800c84 <sys_getenvid>
  800274:	83 ec 0c             	sub    $0xc,%esp
  800277:	ff 75 0c             	pushl  0xc(%ebp)
  80027a:	ff 75 08             	pushl  0x8(%ebp)
  80027d:	56                   	push   %esi
  80027e:	50                   	push   %eax
  80027f:	68 38 26 80 00       	push   $0x802638
  800284:	e8 b1 00 00 00       	call   80033a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800289:	83 c4 18             	add    $0x18,%esp
  80028c:	53                   	push   %ebx
  80028d:	ff 75 10             	pushl  0x10(%ebp)
  800290:	e8 54 00 00 00       	call   8002e9 <vcprintf>
	cprintf("\n");
  800295:	c7 04 24 2b 26 80 00 	movl   $0x80262b,(%esp)
  80029c:	e8 99 00 00 00       	call   80033a <cprintf>
  8002a1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002a4:	cc                   	int3   
  8002a5:	eb fd                	jmp    8002a4 <_panic+0x43>

008002a7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 04             	sub    $0x4,%esp
  8002ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002b1:	8b 13                	mov    (%ebx),%edx
  8002b3:	8d 42 01             	lea    0x1(%edx),%eax
  8002b6:	89 03                	mov    %eax,(%ebx)
  8002b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002bb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002bf:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002c4:	75 1a                	jne    8002e0 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002c6:	83 ec 08             	sub    $0x8,%esp
  8002c9:	68 ff 00 00 00       	push   $0xff
  8002ce:	8d 43 08             	lea    0x8(%ebx),%eax
  8002d1:	50                   	push   %eax
  8002d2:	e8 2f 09 00 00       	call   800c06 <sys_cputs>
		b->idx = 0;
  8002d7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002dd:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002e0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002e7:	c9                   	leave  
  8002e8:	c3                   	ret    

008002e9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
  8002ec:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002f2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002f9:	00 00 00 
	b.cnt = 0;
  8002fc:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800303:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800306:	ff 75 0c             	pushl  0xc(%ebp)
  800309:	ff 75 08             	pushl  0x8(%ebp)
  80030c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800312:	50                   	push   %eax
  800313:	68 a7 02 80 00       	push   $0x8002a7
  800318:	e8 54 01 00 00       	call   800471 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80031d:	83 c4 08             	add    $0x8,%esp
  800320:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800326:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80032c:	50                   	push   %eax
  80032d:	e8 d4 08 00 00       	call   800c06 <sys_cputs>

	return b.cnt;
}
  800332:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800338:	c9                   	leave  
  800339:	c3                   	ret    

0080033a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80033a:	55                   	push   %ebp
  80033b:	89 e5                	mov    %esp,%ebp
  80033d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800340:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800343:	50                   	push   %eax
  800344:	ff 75 08             	pushl  0x8(%ebp)
  800347:	e8 9d ff ff ff       	call   8002e9 <vcprintf>
	va_end(ap);

	return cnt;
}
  80034c:	c9                   	leave  
  80034d:	c3                   	ret    

0080034e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
  800351:	57                   	push   %edi
  800352:	56                   	push   %esi
  800353:	53                   	push   %ebx
  800354:	83 ec 1c             	sub    $0x1c,%esp
  800357:	89 c7                	mov    %eax,%edi
  800359:	89 d6                	mov    %edx,%esi
  80035b:	8b 45 08             	mov    0x8(%ebp),%eax
  80035e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800361:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800364:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800367:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80036a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80036f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800372:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800375:	39 d3                	cmp    %edx,%ebx
  800377:	72 05                	jb     80037e <printnum+0x30>
  800379:	39 45 10             	cmp    %eax,0x10(%ebp)
  80037c:	77 45                	ja     8003c3 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80037e:	83 ec 0c             	sub    $0xc,%esp
  800381:	ff 75 18             	pushl  0x18(%ebp)
  800384:	8b 45 14             	mov    0x14(%ebp),%eax
  800387:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80038a:	53                   	push   %ebx
  80038b:	ff 75 10             	pushl  0x10(%ebp)
  80038e:	83 ec 08             	sub    $0x8,%esp
  800391:	ff 75 e4             	pushl  -0x1c(%ebp)
  800394:	ff 75 e0             	pushl  -0x20(%ebp)
  800397:	ff 75 dc             	pushl  -0x24(%ebp)
  80039a:	ff 75 d8             	pushl  -0x28(%ebp)
  80039d:	e8 5e 1f 00 00       	call   802300 <__udivdi3>
  8003a2:	83 c4 18             	add    $0x18,%esp
  8003a5:	52                   	push   %edx
  8003a6:	50                   	push   %eax
  8003a7:	89 f2                	mov    %esi,%edx
  8003a9:	89 f8                	mov    %edi,%eax
  8003ab:	e8 9e ff ff ff       	call   80034e <printnum>
  8003b0:	83 c4 20             	add    $0x20,%esp
  8003b3:	eb 18                	jmp    8003cd <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003b5:	83 ec 08             	sub    $0x8,%esp
  8003b8:	56                   	push   %esi
  8003b9:	ff 75 18             	pushl  0x18(%ebp)
  8003bc:	ff d7                	call   *%edi
  8003be:	83 c4 10             	add    $0x10,%esp
  8003c1:	eb 03                	jmp    8003c6 <printnum+0x78>
  8003c3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003c6:	83 eb 01             	sub    $0x1,%ebx
  8003c9:	85 db                	test   %ebx,%ebx
  8003cb:	7f e8                	jg     8003b5 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003cd:	83 ec 08             	sub    $0x8,%esp
  8003d0:	56                   	push   %esi
  8003d1:	83 ec 04             	sub    $0x4,%esp
  8003d4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003d7:	ff 75 e0             	pushl  -0x20(%ebp)
  8003da:	ff 75 dc             	pushl  -0x24(%ebp)
  8003dd:	ff 75 d8             	pushl  -0x28(%ebp)
  8003e0:	e8 4b 20 00 00       	call   802430 <__umoddi3>
  8003e5:	83 c4 14             	add    $0x14,%esp
  8003e8:	0f be 80 5b 26 80 00 	movsbl 0x80265b(%eax),%eax
  8003ef:	50                   	push   %eax
  8003f0:	ff d7                	call   *%edi
}
  8003f2:	83 c4 10             	add    $0x10,%esp
  8003f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003f8:	5b                   	pop    %ebx
  8003f9:	5e                   	pop    %esi
  8003fa:	5f                   	pop    %edi
  8003fb:	5d                   	pop    %ebp
  8003fc:	c3                   	ret    

008003fd <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003fd:	55                   	push   %ebp
  8003fe:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800400:	83 fa 01             	cmp    $0x1,%edx
  800403:	7e 0e                	jle    800413 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800405:	8b 10                	mov    (%eax),%edx
  800407:	8d 4a 08             	lea    0x8(%edx),%ecx
  80040a:	89 08                	mov    %ecx,(%eax)
  80040c:	8b 02                	mov    (%edx),%eax
  80040e:	8b 52 04             	mov    0x4(%edx),%edx
  800411:	eb 22                	jmp    800435 <getuint+0x38>
	else if (lflag)
  800413:	85 d2                	test   %edx,%edx
  800415:	74 10                	je     800427 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800417:	8b 10                	mov    (%eax),%edx
  800419:	8d 4a 04             	lea    0x4(%edx),%ecx
  80041c:	89 08                	mov    %ecx,(%eax)
  80041e:	8b 02                	mov    (%edx),%eax
  800420:	ba 00 00 00 00       	mov    $0x0,%edx
  800425:	eb 0e                	jmp    800435 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800427:	8b 10                	mov    (%eax),%edx
  800429:	8d 4a 04             	lea    0x4(%edx),%ecx
  80042c:	89 08                	mov    %ecx,(%eax)
  80042e:	8b 02                	mov    (%edx),%eax
  800430:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800435:	5d                   	pop    %ebp
  800436:	c3                   	ret    

00800437 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800437:	55                   	push   %ebp
  800438:	89 e5                	mov    %esp,%ebp
  80043a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80043d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800441:	8b 10                	mov    (%eax),%edx
  800443:	3b 50 04             	cmp    0x4(%eax),%edx
  800446:	73 0a                	jae    800452 <sprintputch+0x1b>
		*b->buf++ = ch;
  800448:	8d 4a 01             	lea    0x1(%edx),%ecx
  80044b:	89 08                	mov    %ecx,(%eax)
  80044d:	8b 45 08             	mov    0x8(%ebp),%eax
  800450:	88 02                	mov    %al,(%edx)
}
  800452:	5d                   	pop    %ebp
  800453:	c3                   	ret    

00800454 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800454:	55                   	push   %ebp
  800455:	89 e5                	mov    %esp,%ebp
  800457:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80045a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80045d:	50                   	push   %eax
  80045e:	ff 75 10             	pushl  0x10(%ebp)
  800461:	ff 75 0c             	pushl  0xc(%ebp)
  800464:	ff 75 08             	pushl  0x8(%ebp)
  800467:	e8 05 00 00 00       	call   800471 <vprintfmt>
	va_end(ap);
}
  80046c:	83 c4 10             	add    $0x10,%esp
  80046f:	c9                   	leave  
  800470:	c3                   	ret    

00800471 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800471:	55                   	push   %ebp
  800472:	89 e5                	mov    %esp,%ebp
  800474:	57                   	push   %edi
  800475:	56                   	push   %esi
  800476:	53                   	push   %ebx
  800477:	83 ec 2c             	sub    $0x2c,%esp
  80047a:	8b 75 08             	mov    0x8(%ebp),%esi
  80047d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800480:	8b 7d 10             	mov    0x10(%ebp),%edi
  800483:	eb 12                	jmp    800497 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800485:	85 c0                	test   %eax,%eax
  800487:	0f 84 89 03 00 00    	je     800816 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80048d:	83 ec 08             	sub    $0x8,%esp
  800490:	53                   	push   %ebx
  800491:	50                   	push   %eax
  800492:	ff d6                	call   *%esi
  800494:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800497:	83 c7 01             	add    $0x1,%edi
  80049a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80049e:	83 f8 25             	cmp    $0x25,%eax
  8004a1:	75 e2                	jne    800485 <vprintfmt+0x14>
  8004a3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004a7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004ae:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004b5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c1:	eb 07                	jmp    8004ca <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004c6:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ca:	8d 47 01             	lea    0x1(%edi),%eax
  8004cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004d0:	0f b6 07             	movzbl (%edi),%eax
  8004d3:	0f b6 c8             	movzbl %al,%ecx
  8004d6:	83 e8 23             	sub    $0x23,%eax
  8004d9:	3c 55                	cmp    $0x55,%al
  8004db:	0f 87 1a 03 00 00    	ja     8007fb <vprintfmt+0x38a>
  8004e1:	0f b6 c0             	movzbl %al,%eax
  8004e4:	ff 24 85 a0 27 80 00 	jmp    *0x8027a0(,%eax,4)
  8004eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004ee:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004f2:	eb d6                	jmp    8004ca <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004ff:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800502:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800506:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800509:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80050c:	83 fa 09             	cmp    $0x9,%edx
  80050f:	77 39                	ja     80054a <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800511:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800514:	eb e9                	jmp    8004ff <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800516:	8b 45 14             	mov    0x14(%ebp),%eax
  800519:	8d 48 04             	lea    0x4(%eax),%ecx
  80051c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80051f:	8b 00                	mov    (%eax),%eax
  800521:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800524:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800527:	eb 27                	jmp    800550 <vprintfmt+0xdf>
  800529:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80052c:	85 c0                	test   %eax,%eax
  80052e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800533:	0f 49 c8             	cmovns %eax,%ecx
  800536:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800539:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80053c:	eb 8c                	jmp    8004ca <vprintfmt+0x59>
  80053e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800541:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800548:	eb 80                	jmp    8004ca <vprintfmt+0x59>
  80054a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80054d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800550:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800554:	0f 89 70 ff ff ff    	jns    8004ca <vprintfmt+0x59>
				width = precision, precision = -1;
  80055a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80055d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800560:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800567:	e9 5e ff ff ff       	jmp    8004ca <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80056c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800572:	e9 53 ff ff ff       	jmp    8004ca <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8d 50 04             	lea    0x4(%eax),%edx
  80057d:	89 55 14             	mov    %edx,0x14(%ebp)
  800580:	83 ec 08             	sub    $0x8,%esp
  800583:	53                   	push   %ebx
  800584:	ff 30                	pushl  (%eax)
  800586:	ff d6                	call   *%esi
			break;
  800588:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80058e:	e9 04 ff ff ff       	jmp    800497 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800593:	8b 45 14             	mov    0x14(%ebp),%eax
  800596:	8d 50 04             	lea    0x4(%eax),%edx
  800599:	89 55 14             	mov    %edx,0x14(%ebp)
  80059c:	8b 00                	mov    (%eax),%eax
  80059e:	99                   	cltd   
  80059f:	31 d0                	xor    %edx,%eax
  8005a1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005a3:	83 f8 0f             	cmp    $0xf,%eax
  8005a6:	7f 0b                	jg     8005b3 <vprintfmt+0x142>
  8005a8:	8b 14 85 00 29 80 00 	mov    0x802900(,%eax,4),%edx
  8005af:	85 d2                	test   %edx,%edx
  8005b1:	75 18                	jne    8005cb <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005b3:	50                   	push   %eax
  8005b4:	68 73 26 80 00       	push   $0x802673
  8005b9:	53                   	push   %ebx
  8005ba:	56                   	push   %esi
  8005bb:	e8 94 fe ff ff       	call   800454 <printfmt>
  8005c0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005c6:	e9 cc fe ff ff       	jmp    800497 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005cb:	52                   	push   %edx
  8005cc:	68 c1 2a 80 00       	push   $0x802ac1
  8005d1:	53                   	push   %ebx
  8005d2:	56                   	push   %esi
  8005d3:	e8 7c fe ff ff       	call   800454 <printfmt>
  8005d8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005de:	e9 b4 fe ff ff       	jmp    800497 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8d 50 04             	lea    0x4(%eax),%edx
  8005e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ec:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005ee:	85 ff                	test   %edi,%edi
  8005f0:	b8 6c 26 80 00       	mov    $0x80266c,%eax
  8005f5:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005f8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005fc:	0f 8e 94 00 00 00    	jle    800696 <vprintfmt+0x225>
  800602:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800606:	0f 84 98 00 00 00    	je     8006a4 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80060c:	83 ec 08             	sub    $0x8,%esp
  80060f:	ff 75 d0             	pushl  -0x30(%ebp)
  800612:	57                   	push   %edi
  800613:	e8 86 02 00 00       	call   80089e <strnlen>
  800618:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80061b:	29 c1                	sub    %eax,%ecx
  80061d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800620:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800623:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800627:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80062a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80062d:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80062f:	eb 0f                	jmp    800640 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800631:	83 ec 08             	sub    $0x8,%esp
  800634:	53                   	push   %ebx
  800635:	ff 75 e0             	pushl  -0x20(%ebp)
  800638:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80063a:	83 ef 01             	sub    $0x1,%edi
  80063d:	83 c4 10             	add    $0x10,%esp
  800640:	85 ff                	test   %edi,%edi
  800642:	7f ed                	jg     800631 <vprintfmt+0x1c0>
  800644:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800647:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80064a:	85 c9                	test   %ecx,%ecx
  80064c:	b8 00 00 00 00       	mov    $0x0,%eax
  800651:	0f 49 c1             	cmovns %ecx,%eax
  800654:	29 c1                	sub    %eax,%ecx
  800656:	89 75 08             	mov    %esi,0x8(%ebp)
  800659:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80065c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80065f:	89 cb                	mov    %ecx,%ebx
  800661:	eb 4d                	jmp    8006b0 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800663:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800667:	74 1b                	je     800684 <vprintfmt+0x213>
  800669:	0f be c0             	movsbl %al,%eax
  80066c:	83 e8 20             	sub    $0x20,%eax
  80066f:	83 f8 5e             	cmp    $0x5e,%eax
  800672:	76 10                	jbe    800684 <vprintfmt+0x213>
					putch('?', putdat);
  800674:	83 ec 08             	sub    $0x8,%esp
  800677:	ff 75 0c             	pushl  0xc(%ebp)
  80067a:	6a 3f                	push   $0x3f
  80067c:	ff 55 08             	call   *0x8(%ebp)
  80067f:	83 c4 10             	add    $0x10,%esp
  800682:	eb 0d                	jmp    800691 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800684:	83 ec 08             	sub    $0x8,%esp
  800687:	ff 75 0c             	pushl  0xc(%ebp)
  80068a:	52                   	push   %edx
  80068b:	ff 55 08             	call   *0x8(%ebp)
  80068e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800691:	83 eb 01             	sub    $0x1,%ebx
  800694:	eb 1a                	jmp    8006b0 <vprintfmt+0x23f>
  800696:	89 75 08             	mov    %esi,0x8(%ebp)
  800699:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80069c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80069f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006a2:	eb 0c                	jmp    8006b0 <vprintfmt+0x23f>
  8006a4:	89 75 08             	mov    %esi,0x8(%ebp)
  8006a7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006aa:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006ad:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006b0:	83 c7 01             	add    $0x1,%edi
  8006b3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006b7:	0f be d0             	movsbl %al,%edx
  8006ba:	85 d2                	test   %edx,%edx
  8006bc:	74 23                	je     8006e1 <vprintfmt+0x270>
  8006be:	85 f6                	test   %esi,%esi
  8006c0:	78 a1                	js     800663 <vprintfmt+0x1f2>
  8006c2:	83 ee 01             	sub    $0x1,%esi
  8006c5:	79 9c                	jns    800663 <vprintfmt+0x1f2>
  8006c7:	89 df                	mov    %ebx,%edi
  8006c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8006cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006cf:	eb 18                	jmp    8006e9 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006d1:	83 ec 08             	sub    $0x8,%esp
  8006d4:	53                   	push   %ebx
  8006d5:	6a 20                	push   $0x20
  8006d7:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006d9:	83 ef 01             	sub    $0x1,%edi
  8006dc:	83 c4 10             	add    $0x10,%esp
  8006df:	eb 08                	jmp    8006e9 <vprintfmt+0x278>
  8006e1:	89 df                	mov    %ebx,%edi
  8006e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8006e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006e9:	85 ff                	test   %edi,%edi
  8006eb:	7f e4                	jg     8006d1 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006f0:	e9 a2 fd ff ff       	jmp    800497 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006f5:	83 fa 01             	cmp    $0x1,%edx
  8006f8:	7e 16                	jle    800710 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fd:	8d 50 08             	lea    0x8(%eax),%edx
  800700:	89 55 14             	mov    %edx,0x14(%ebp)
  800703:	8b 50 04             	mov    0x4(%eax),%edx
  800706:	8b 00                	mov    (%eax),%eax
  800708:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80070b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80070e:	eb 32                	jmp    800742 <vprintfmt+0x2d1>
	else if (lflag)
  800710:	85 d2                	test   %edx,%edx
  800712:	74 18                	je     80072c <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800714:	8b 45 14             	mov    0x14(%ebp),%eax
  800717:	8d 50 04             	lea    0x4(%eax),%edx
  80071a:	89 55 14             	mov    %edx,0x14(%ebp)
  80071d:	8b 00                	mov    (%eax),%eax
  80071f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800722:	89 c1                	mov    %eax,%ecx
  800724:	c1 f9 1f             	sar    $0x1f,%ecx
  800727:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80072a:	eb 16                	jmp    800742 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80072c:	8b 45 14             	mov    0x14(%ebp),%eax
  80072f:	8d 50 04             	lea    0x4(%eax),%edx
  800732:	89 55 14             	mov    %edx,0x14(%ebp)
  800735:	8b 00                	mov    (%eax),%eax
  800737:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80073a:	89 c1                	mov    %eax,%ecx
  80073c:	c1 f9 1f             	sar    $0x1f,%ecx
  80073f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800742:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800745:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800748:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80074d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800751:	79 74                	jns    8007c7 <vprintfmt+0x356>
				putch('-', putdat);
  800753:	83 ec 08             	sub    $0x8,%esp
  800756:	53                   	push   %ebx
  800757:	6a 2d                	push   $0x2d
  800759:	ff d6                	call   *%esi
				num = -(long long) num;
  80075b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80075e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800761:	f7 d8                	neg    %eax
  800763:	83 d2 00             	adc    $0x0,%edx
  800766:	f7 da                	neg    %edx
  800768:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80076b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800770:	eb 55                	jmp    8007c7 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800772:	8d 45 14             	lea    0x14(%ebp),%eax
  800775:	e8 83 fc ff ff       	call   8003fd <getuint>
			base = 10;
  80077a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80077f:	eb 46                	jmp    8007c7 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800781:	8d 45 14             	lea    0x14(%ebp),%eax
  800784:	e8 74 fc ff ff       	call   8003fd <getuint>
			base = 8;
  800789:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80078e:	eb 37                	jmp    8007c7 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800790:	83 ec 08             	sub    $0x8,%esp
  800793:	53                   	push   %ebx
  800794:	6a 30                	push   $0x30
  800796:	ff d6                	call   *%esi
			putch('x', putdat);
  800798:	83 c4 08             	add    $0x8,%esp
  80079b:	53                   	push   %ebx
  80079c:	6a 78                	push   $0x78
  80079e:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a3:	8d 50 04             	lea    0x4(%eax),%edx
  8007a6:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007a9:	8b 00                	mov    (%eax),%eax
  8007ab:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007b0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007b3:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007b8:	eb 0d                	jmp    8007c7 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8007bd:	e8 3b fc ff ff       	call   8003fd <getuint>
			base = 16;
  8007c2:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007c7:	83 ec 0c             	sub    $0xc,%esp
  8007ca:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007ce:	57                   	push   %edi
  8007cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8007d2:	51                   	push   %ecx
  8007d3:	52                   	push   %edx
  8007d4:	50                   	push   %eax
  8007d5:	89 da                	mov    %ebx,%edx
  8007d7:	89 f0                	mov    %esi,%eax
  8007d9:	e8 70 fb ff ff       	call   80034e <printnum>
			break;
  8007de:	83 c4 20             	add    $0x20,%esp
  8007e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007e4:	e9 ae fc ff ff       	jmp    800497 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007e9:	83 ec 08             	sub    $0x8,%esp
  8007ec:	53                   	push   %ebx
  8007ed:	51                   	push   %ecx
  8007ee:	ff d6                	call   *%esi
			break;
  8007f0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007f6:	e9 9c fc ff ff       	jmp    800497 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007fb:	83 ec 08             	sub    $0x8,%esp
  8007fe:	53                   	push   %ebx
  8007ff:	6a 25                	push   $0x25
  800801:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800803:	83 c4 10             	add    $0x10,%esp
  800806:	eb 03                	jmp    80080b <vprintfmt+0x39a>
  800808:	83 ef 01             	sub    $0x1,%edi
  80080b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80080f:	75 f7                	jne    800808 <vprintfmt+0x397>
  800811:	e9 81 fc ff ff       	jmp    800497 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800816:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800819:	5b                   	pop    %ebx
  80081a:	5e                   	pop    %esi
  80081b:	5f                   	pop    %edi
  80081c:	5d                   	pop    %ebp
  80081d:	c3                   	ret    

0080081e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	83 ec 18             	sub    $0x18,%esp
  800824:	8b 45 08             	mov    0x8(%ebp),%eax
  800827:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80082a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80082d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800831:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800834:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80083b:	85 c0                	test   %eax,%eax
  80083d:	74 26                	je     800865 <vsnprintf+0x47>
  80083f:	85 d2                	test   %edx,%edx
  800841:	7e 22                	jle    800865 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800843:	ff 75 14             	pushl  0x14(%ebp)
  800846:	ff 75 10             	pushl  0x10(%ebp)
  800849:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80084c:	50                   	push   %eax
  80084d:	68 37 04 80 00       	push   $0x800437
  800852:	e8 1a fc ff ff       	call   800471 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800857:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80085a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80085d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800860:	83 c4 10             	add    $0x10,%esp
  800863:	eb 05                	jmp    80086a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800865:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80086a:	c9                   	leave  
  80086b:	c3                   	ret    

0080086c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80086c:	55                   	push   %ebp
  80086d:	89 e5                	mov    %esp,%ebp
  80086f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800872:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800875:	50                   	push   %eax
  800876:	ff 75 10             	pushl  0x10(%ebp)
  800879:	ff 75 0c             	pushl  0xc(%ebp)
  80087c:	ff 75 08             	pushl  0x8(%ebp)
  80087f:	e8 9a ff ff ff       	call   80081e <vsnprintf>
	va_end(ap);

	return rc;
}
  800884:	c9                   	leave  
  800885:	c3                   	ret    

00800886 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80088c:	b8 00 00 00 00       	mov    $0x0,%eax
  800891:	eb 03                	jmp    800896 <strlen+0x10>
		n++;
  800893:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800896:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80089a:	75 f7                	jne    800893 <strlen+0xd>
		n++;
	return n;
}
  80089c:	5d                   	pop    %ebp
  80089d:	c3                   	ret    

0080089e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a4:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ac:	eb 03                	jmp    8008b1 <strnlen+0x13>
		n++;
  8008ae:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b1:	39 c2                	cmp    %eax,%edx
  8008b3:	74 08                	je     8008bd <strnlen+0x1f>
  8008b5:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008b9:	75 f3                	jne    8008ae <strnlen+0x10>
  8008bb:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    

008008bf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	53                   	push   %ebx
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008c9:	89 c2                	mov    %eax,%edx
  8008cb:	83 c2 01             	add    $0x1,%edx
  8008ce:	83 c1 01             	add    $0x1,%ecx
  8008d1:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008d5:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008d8:	84 db                	test   %bl,%bl
  8008da:	75 ef                	jne    8008cb <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008dc:	5b                   	pop    %ebx
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	53                   	push   %ebx
  8008e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008e6:	53                   	push   %ebx
  8008e7:	e8 9a ff ff ff       	call   800886 <strlen>
  8008ec:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008ef:	ff 75 0c             	pushl  0xc(%ebp)
  8008f2:	01 d8                	add    %ebx,%eax
  8008f4:	50                   	push   %eax
  8008f5:	e8 c5 ff ff ff       	call   8008bf <strcpy>
	return dst;
}
  8008fa:	89 d8                	mov    %ebx,%eax
  8008fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ff:	c9                   	leave  
  800900:	c3                   	ret    

00800901 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	56                   	push   %esi
  800905:	53                   	push   %ebx
  800906:	8b 75 08             	mov    0x8(%ebp),%esi
  800909:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090c:	89 f3                	mov    %esi,%ebx
  80090e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800911:	89 f2                	mov    %esi,%edx
  800913:	eb 0f                	jmp    800924 <strncpy+0x23>
		*dst++ = *src;
  800915:	83 c2 01             	add    $0x1,%edx
  800918:	0f b6 01             	movzbl (%ecx),%eax
  80091b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80091e:	80 39 01             	cmpb   $0x1,(%ecx)
  800921:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800924:	39 da                	cmp    %ebx,%edx
  800926:	75 ed                	jne    800915 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800928:	89 f0                	mov    %esi,%eax
  80092a:	5b                   	pop    %ebx
  80092b:	5e                   	pop    %esi
  80092c:	5d                   	pop    %ebp
  80092d:	c3                   	ret    

0080092e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	56                   	push   %esi
  800932:	53                   	push   %ebx
  800933:	8b 75 08             	mov    0x8(%ebp),%esi
  800936:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800939:	8b 55 10             	mov    0x10(%ebp),%edx
  80093c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80093e:	85 d2                	test   %edx,%edx
  800940:	74 21                	je     800963 <strlcpy+0x35>
  800942:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800946:	89 f2                	mov    %esi,%edx
  800948:	eb 09                	jmp    800953 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80094a:	83 c2 01             	add    $0x1,%edx
  80094d:	83 c1 01             	add    $0x1,%ecx
  800950:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800953:	39 c2                	cmp    %eax,%edx
  800955:	74 09                	je     800960 <strlcpy+0x32>
  800957:	0f b6 19             	movzbl (%ecx),%ebx
  80095a:	84 db                	test   %bl,%bl
  80095c:	75 ec                	jne    80094a <strlcpy+0x1c>
  80095e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800960:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800963:	29 f0                	sub    %esi,%eax
}
  800965:	5b                   	pop    %ebx
  800966:	5e                   	pop    %esi
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    

00800969 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80096f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800972:	eb 06                	jmp    80097a <strcmp+0x11>
		p++, q++;
  800974:	83 c1 01             	add    $0x1,%ecx
  800977:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80097a:	0f b6 01             	movzbl (%ecx),%eax
  80097d:	84 c0                	test   %al,%al
  80097f:	74 04                	je     800985 <strcmp+0x1c>
  800981:	3a 02                	cmp    (%edx),%al
  800983:	74 ef                	je     800974 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800985:	0f b6 c0             	movzbl %al,%eax
  800988:	0f b6 12             	movzbl (%edx),%edx
  80098b:	29 d0                	sub    %edx,%eax
}
  80098d:	5d                   	pop    %ebp
  80098e:	c3                   	ret    

0080098f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	53                   	push   %ebx
  800993:	8b 45 08             	mov    0x8(%ebp),%eax
  800996:	8b 55 0c             	mov    0xc(%ebp),%edx
  800999:	89 c3                	mov    %eax,%ebx
  80099b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80099e:	eb 06                	jmp    8009a6 <strncmp+0x17>
		n--, p++, q++;
  8009a0:	83 c0 01             	add    $0x1,%eax
  8009a3:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009a6:	39 d8                	cmp    %ebx,%eax
  8009a8:	74 15                	je     8009bf <strncmp+0x30>
  8009aa:	0f b6 08             	movzbl (%eax),%ecx
  8009ad:	84 c9                	test   %cl,%cl
  8009af:	74 04                	je     8009b5 <strncmp+0x26>
  8009b1:	3a 0a                	cmp    (%edx),%cl
  8009b3:	74 eb                	je     8009a0 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b5:	0f b6 00             	movzbl (%eax),%eax
  8009b8:	0f b6 12             	movzbl (%edx),%edx
  8009bb:	29 d0                	sub    %edx,%eax
  8009bd:	eb 05                	jmp    8009c4 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009bf:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009c4:	5b                   	pop    %ebx
  8009c5:	5d                   	pop    %ebp
  8009c6:	c3                   	ret    

008009c7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d1:	eb 07                	jmp    8009da <strchr+0x13>
		if (*s == c)
  8009d3:	38 ca                	cmp    %cl,%dl
  8009d5:	74 0f                	je     8009e6 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009d7:	83 c0 01             	add    $0x1,%eax
  8009da:	0f b6 10             	movzbl (%eax),%edx
  8009dd:	84 d2                	test   %dl,%dl
  8009df:	75 f2                	jne    8009d3 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e6:	5d                   	pop    %ebp
  8009e7:	c3                   	ret    

008009e8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ee:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f2:	eb 03                	jmp    8009f7 <strfind+0xf>
  8009f4:	83 c0 01             	add    $0x1,%eax
  8009f7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009fa:	38 ca                	cmp    %cl,%dl
  8009fc:	74 04                	je     800a02 <strfind+0x1a>
  8009fe:	84 d2                	test   %dl,%dl
  800a00:	75 f2                	jne    8009f4 <strfind+0xc>
			break;
	return (char *) s;
}
  800a02:	5d                   	pop    %ebp
  800a03:	c3                   	ret    

00800a04 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	57                   	push   %edi
  800a08:	56                   	push   %esi
  800a09:	53                   	push   %ebx
  800a0a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a0d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a10:	85 c9                	test   %ecx,%ecx
  800a12:	74 36                	je     800a4a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a14:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a1a:	75 28                	jne    800a44 <memset+0x40>
  800a1c:	f6 c1 03             	test   $0x3,%cl
  800a1f:	75 23                	jne    800a44 <memset+0x40>
		c &= 0xFF;
  800a21:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a25:	89 d3                	mov    %edx,%ebx
  800a27:	c1 e3 08             	shl    $0x8,%ebx
  800a2a:	89 d6                	mov    %edx,%esi
  800a2c:	c1 e6 18             	shl    $0x18,%esi
  800a2f:	89 d0                	mov    %edx,%eax
  800a31:	c1 e0 10             	shl    $0x10,%eax
  800a34:	09 f0                	or     %esi,%eax
  800a36:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a38:	89 d8                	mov    %ebx,%eax
  800a3a:	09 d0                	or     %edx,%eax
  800a3c:	c1 e9 02             	shr    $0x2,%ecx
  800a3f:	fc                   	cld    
  800a40:	f3 ab                	rep stos %eax,%es:(%edi)
  800a42:	eb 06                	jmp    800a4a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a44:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a47:	fc                   	cld    
  800a48:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a4a:	89 f8                	mov    %edi,%eax
  800a4c:	5b                   	pop    %ebx
  800a4d:	5e                   	pop    %esi
  800a4e:	5f                   	pop    %edi
  800a4f:	5d                   	pop    %ebp
  800a50:	c3                   	ret    

00800a51 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	57                   	push   %edi
  800a55:	56                   	push   %esi
  800a56:	8b 45 08             	mov    0x8(%ebp),%eax
  800a59:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a5c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a5f:	39 c6                	cmp    %eax,%esi
  800a61:	73 35                	jae    800a98 <memmove+0x47>
  800a63:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a66:	39 d0                	cmp    %edx,%eax
  800a68:	73 2e                	jae    800a98 <memmove+0x47>
		s += n;
		d += n;
  800a6a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6d:	89 d6                	mov    %edx,%esi
  800a6f:	09 fe                	or     %edi,%esi
  800a71:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a77:	75 13                	jne    800a8c <memmove+0x3b>
  800a79:	f6 c1 03             	test   $0x3,%cl
  800a7c:	75 0e                	jne    800a8c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a7e:	83 ef 04             	sub    $0x4,%edi
  800a81:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a84:	c1 e9 02             	shr    $0x2,%ecx
  800a87:	fd                   	std    
  800a88:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a8a:	eb 09                	jmp    800a95 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a8c:	83 ef 01             	sub    $0x1,%edi
  800a8f:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a92:	fd                   	std    
  800a93:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a95:	fc                   	cld    
  800a96:	eb 1d                	jmp    800ab5 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a98:	89 f2                	mov    %esi,%edx
  800a9a:	09 c2                	or     %eax,%edx
  800a9c:	f6 c2 03             	test   $0x3,%dl
  800a9f:	75 0f                	jne    800ab0 <memmove+0x5f>
  800aa1:	f6 c1 03             	test   $0x3,%cl
  800aa4:	75 0a                	jne    800ab0 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800aa6:	c1 e9 02             	shr    $0x2,%ecx
  800aa9:	89 c7                	mov    %eax,%edi
  800aab:	fc                   	cld    
  800aac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aae:	eb 05                	jmp    800ab5 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ab0:	89 c7                	mov    %eax,%edi
  800ab2:	fc                   	cld    
  800ab3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ab5:	5e                   	pop    %esi
  800ab6:	5f                   	pop    %edi
  800ab7:	5d                   	pop    %ebp
  800ab8:	c3                   	ret    

00800ab9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800abc:	ff 75 10             	pushl  0x10(%ebp)
  800abf:	ff 75 0c             	pushl  0xc(%ebp)
  800ac2:	ff 75 08             	pushl  0x8(%ebp)
  800ac5:	e8 87 ff ff ff       	call   800a51 <memmove>
}
  800aca:	c9                   	leave  
  800acb:	c3                   	ret    

00800acc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	56                   	push   %esi
  800ad0:	53                   	push   %ebx
  800ad1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad7:	89 c6                	mov    %eax,%esi
  800ad9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800adc:	eb 1a                	jmp    800af8 <memcmp+0x2c>
		if (*s1 != *s2)
  800ade:	0f b6 08             	movzbl (%eax),%ecx
  800ae1:	0f b6 1a             	movzbl (%edx),%ebx
  800ae4:	38 d9                	cmp    %bl,%cl
  800ae6:	74 0a                	je     800af2 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ae8:	0f b6 c1             	movzbl %cl,%eax
  800aeb:	0f b6 db             	movzbl %bl,%ebx
  800aee:	29 d8                	sub    %ebx,%eax
  800af0:	eb 0f                	jmp    800b01 <memcmp+0x35>
		s1++, s2++;
  800af2:	83 c0 01             	add    $0x1,%eax
  800af5:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af8:	39 f0                	cmp    %esi,%eax
  800afa:	75 e2                	jne    800ade <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800afc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b01:	5b                   	pop    %ebx
  800b02:	5e                   	pop    %esi
  800b03:	5d                   	pop    %ebp
  800b04:	c3                   	ret    

00800b05 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	53                   	push   %ebx
  800b09:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b0c:	89 c1                	mov    %eax,%ecx
  800b0e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b11:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b15:	eb 0a                	jmp    800b21 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b17:	0f b6 10             	movzbl (%eax),%edx
  800b1a:	39 da                	cmp    %ebx,%edx
  800b1c:	74 07                	je     800b25 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b1e:	83 c0 01             	add    $0x1,%eax
  800b21:	39 c8                	cmp    %ecx,%eax
  800b23:	72 f2                	jb     800b17 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b25:	5b                   	pop    %ebx
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    

00800b28 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	57                   	push   %edi
  800b2c:	56                   	push   %esi
  800b2d:	53                   	push   %ebx
  800b2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b31:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b34:	eb 03                	jmp    800b39 <strtol+0x11>
		s++;
  800b36:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b39:	0f b6 01             	movzbl (%ecx),%eax
  800b3c:	3c 20                	cmp    $0x20,%al
  800b3e:	74 f6                	je     800b36 <strtol+0xe>
  800b40:	3c 09                	cmp    $0x9,%al
  800b42:	74 f2                	je     800b36 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b44:	3c 2b                	cmp    $0x2b,%al
  800b46:	75 0a                	jne    800b52 <strtol+0x2a>
		s++;
  800b48:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b4b:	bf 00 00 00 00       	mov    $0x0,%edi
  800b50:	eb 11                	jmp    800b63 <strtol+0x3b>
  800b52:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b57:	3c 2d                	cmp    $0x2d,%al
  800b59:	75 08                	jne    800b63 <strtol+0x3b>
		s++, neg = 1;
  800b5b:	83 c1 01             	add    $0x1,%ecx
  800b5e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b63:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b69:	75 15                	jne    800b80 <strtol+0x58>
  800b6b:	80 39 30             	cmpb   $0x30,(%ecx)
  800b6e:	75 10                	jne    800b80 <strtol+0x58>
  800b70:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b74:	75 7c                	jne    800bf2 <strtol+0xca>
		s += 2, base = 16;
  800b76:	83 c1 02             	add    $0x2,%ecx
  800b79:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b7e:	eb 16                	jmp    800b96 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b80:	85 db                	test   %ebx,%ebx
  800b82:	75 12                	jne    800b96 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b84:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b89:	80 39 30             	cmpb   $0x30,(%ecx)
  800b8c:	75 08                	jne    800b96 <strtol+0x6e>
		s++, base = 8;
  800b8e:	83 c1 01             	add    $0x1,%ecx
  800b91:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b96:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b9e:	0f b6 11             	movzbl (%ecx),%edx
  800ba1:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ba4:	89 f3                	mov    %esi,%ebx
  800ba6:	80 fb 09             	cmp    $0x9,%bl
  800ba9:	77 08                	ja     800bb3 <strtol+0x8b>
			dig = *s - '0';
  800bab:	0f be d2             	movsbl %dl,%edx
  800bae:	83 ea 30             	sub    $0x30,%edx
  800bb1:	eb 22                	jmp    800bd5 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800bb3:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bb6:	89 f3                	mov    %esi,%ebx
  800bb8:	80 fb 19             	cmp    $0x19,%bl
  800bbb:	77 08                	ja     800bc5 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bbd:	0f be d2             	movsbl %dl,%edx
  800bc0:	83 ea 57             	sub    $0x57,%edx
  800bc3:	eb 10                	jmp    800bd5 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bc5:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bc8:	89 f3                	mov    %esi,%ebx
  800bca:	80 fb 19             	cmp    $0x19,%bl
  800bcd:	77 16                	ja     800be5 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bcf:	0f be d2             	movsbl %dl,%edx
  800bd2:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bd5:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bd8:	7d 0b                	jge    800be5 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bda:	83 c1 01             	add    $0x1,%ecx
  800bdd:	0f af 45 10          	imul   0x10(%ebp),%eax
  800be1:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800be3:	eb b9                	jmp    800b9e <strtol+0x76>

	if (endptr)
  800be5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800be9:	74 0d                	je     800bf8 <strtol+0xd0>
		*endptr = (char *) s;
  800beb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bee:	89 0e                	mov    %ecx,(%esi)
  800bf0:	eb 06                	jmp    800bf8 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bf2:	85 db                	test   %ebx,%ebx
  800bf4:	74 98                	je     800b8e <strtol+0x66>
  800bf6:	eb 9e                	jmp    800b96 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bf8:	89 c2                	mov    %eax,%edx
  800bfa:	f7 da                	neg    %edx
  800bfc:	85 ff                	test   %edi,%edi
  800bfe:	0f 45 c2             	cmovne %edx,%eax
}
  800c01:	5b                   	pop    %ebx
  800c02:	5e                   	pop    %esi
  800c03:	5f                   	pop    %edi
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	57                   	push   %edi
  800c0a:	56                   	push   %esi
  800c0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c14:	8b 55 08             	mov    0x8(%ebp),%edx
  800c17:	89 c3                	mov    %eax,%ebx
  800c19:	89 c7                	mov    %eax,%edi
  800c1b:	89 c6                	mov    %eax,%esi
  800c1d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c1f:	5b                   	pop    %ebx
  800c20:	5e                   	pop    %esi
  800c21:	5f                   	pop    %edi
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	57                   	push   %edi
  800c28:	56                   	push   %esi
  800c29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c34:	89 d1                	mov    %edx,%ecx
  800c36:	89 d3                	mov    %edx,%ebx
  800c38:	89 d7                	mov    %edx,%edi
  800c3a:	89 d6                	mov    %edx,%esi
  800c3c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c51:	b8 03 00 00 00       	mov    $0x3,%eax
  800c56:	8b 55 08             	mov    0x8(%ebp),%edx
  800c59:	89 cb                	mov    %ecx,%ebx
  800c5b:	89 cf                	mov    %ecx,%edi
  800c5d:	89 ce                	mov    %ecx,%esi
  800c5f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c61:	85 c0                	test   %eax,%eax
  800c63:	7e 17                	jle    800c7c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c65:	83 ec 0c             	sub    $0xc,%esp
  800c68:	50                   	push   %eax
  800c69:	6a 03                	push   $0x3
  800c6b:	68 5f 29 80 00       	push   $0x80295f
  800c70:	6a 23                	push   $0x23
  800c72:	68 7c 29 80 00       	push   $0x80297c
  800c77:	e8 e5 f5 ff ff       	call   800261 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8f:	b8 02 00 00 00       	mov    $0x2,%eax
  800c94:	89 d1                	mov    %edx,%ecx
  800c96:	89 d3                	mov    %edx,%ebx
  800c98:	89 d7                	mov    %edx,%edi
  800c9a:	89 d6                	mov    %edx,%esi
  800c9c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c9e:	5b                   	pop    %ebx
  800c9f:	5e                   	pop    %esi
  800ca0:	5f                   	pop    %edi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    

00800ca3 <sys_yield>:

void
sys_yield(void)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	57                   	push   %edi
  800ca7:	56                   	push   %esi
  800ca8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca9:	ba 00 00 00 00       	mov    $0x0,%edx
  800cae:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cb3:	89 d1                	mov    %edx,%ecx
  800cb5:	89 d3                	mov    %edx,%ebx
  800cb7:	89 d7                	mov    %edx,%edi
  800cb9:	89 d6                	mov    %edx,%esi
  800cbb:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
  800cc8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccb:	be 00 00 00 00       	mov    $0x0,%esi
  800cd0:	b8 04 00 00 00       	mov    $0x4,%eax
  800cd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cde:	89 f7                	mov    %esi,%edi
  800ce0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce2:	85 c0                	test   %eax,%eax
  800ce4:	7e 17                	jle    800cfd <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce6:	83 ec 0c             	sub    $0xc,%esp
  800ce9:	50                   	push   %eax
  800cea:	6a 04                	push   $0x4
  800cec:	68 5f 29 80 00       	push   $0x80295f
  800cf1:	6a 23                	push   $0x23
  800cf3:	68 7c 29 80 00       	push   $0x80297c
  800cf8:	e8 64 f5 ff ff       	call   800261 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d00:	5b                   	pop    %ebx
  800d01:	5e                   	pop    %esi
  800d02:	5f                   	pop    %edi
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    

00800d05 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	57                   	push   %edi
  800d09:	56                   	push   %esi
  800d0a:	53                   	push   %ebx
  800d0b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0e:	b8 05 00 00 00       	mov    $0x5,%eax
  800d13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d16:	8b 55 08             	mov    0x8(%ebp),%edx
  800d19:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d1f:	8b 75 18             	mov    0x18(%ebp),%esi
  800d22:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d24:	85 c0                	test   %eax,%eax
  800d26:	7e 17                	jle    800d3f <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d28:	83 ec 0c             	sub    $0xc,%esp
  800d2b:	50                   	push   %eax
  800d2c:	6a 05                	push   $0x5
  800d2e:	68 5f 29 80 00       	push   $0x80295f
  800d33:	6a 23                	push   $0x23
  800d35:	68 7c 29 80 00       	push   $0x80297c
  800d3a:	e8 22 f5 ff ff       	call   800261 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d42:	5b                   	pop    %ebx
  800d43:	5e                   	pop    %esi
  800d44:	5f                   	pop    %edi
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    

00800d47 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	57                   	push   %edi
  800d4b:	56                   	push   %esi
  800d4c:	53                   	push   %ebx
  800d4d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d55:	b8 06 00 00 00       	mov    $0x6,%eax
  800d5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d60:	89 df                	mov    %ebx,%edi
  800d62:	89 de                	mov    %ebx,%esi
  800d64:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d66:	85 c0                	test   %eax,%eax
  800d68:	7e 17                	jle    800d81 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6a:	83 ec 0c             	sub    $0xc,%esp
  800d6d:	50                   	push   %eax
  800d6e:	6a 06                	push   $0x6
  800d70:	68 5f 29 80 00       	push   $0x80295f
  800d75:	6a 23                	push   $0x23
  800d77:	68 7c 29 80 00       	push   $0x80297c
  800d7c:	e8 e0 f4 ff ff       	call   800261 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5f                   	pop    %edi
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    

00800d89 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	57                   	push   %edi
  800d8d:	56                   	push   %esi
  800d8e:	53                   	push   %ebx
  800d8f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d92:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d97:	b8 08 00 00 00       	mov    $0x8,%eax
  800d9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800da2:	89 df                	mov    %ebx,%edi
  800da4:	89 de                	mov    %ebx,%esi
  800da6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da8:	85 c0                	test   %eax,%eax
  800daa:	7e 17                	jle    800dc3 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dac:	83 ec 0c             	sub    $0xc,%esp
  800daf:	50                   	push   %eax
  800db0:	6a 08                	push   $0x8
  800db2:	68 5f 29 80 00       	push   $0x80295f
  800db7:	6a 23                	push   $0x23
  800db9:	68 7c 29 80 00       	push   $0x80297c
  800dbe:	e8 9e f4 ff ff       	call   800261 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc6:	5b                   	pop    %ebx
  800dc7:	5e                   	pop    %esi
  800dc8:	5f                   	pop    %edi
  800dc9:	5d                   	pop    %ebp
  800dca:	c3                   	ret    

00800dcb <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	57                   	push   %edi
  800dcf:	56                   	push   %esi
  800dd0:	53                   	push   %ebx
  800dd1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd9:	b8 09 00 00 00       	mov    $0x9,%eax
  800dde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de1:	8b 55 08             	mov    0x8(%ebp),%edx
  800de4:	89 df                	mov    %ebx,%edi
  800de6:	89 de                	mov    %ebx,%esi
  800de8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dea:	85 c0                	test   %eax,%eax
  800dec:	7e 17                	jle    800e05 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dee:	83 ec 0c             	sub    $0xc,%esp
  800df1:	50                   	push   %eax
  800df2:	6a 09                	push   $0x9
  800df4:	68 5f 29 80 00       	push   $0x80295f
  800df9:	6a 23                	push   $0x23
  800dfb:	68 7c 29 80 00       	push   $0x80297c
  800e00:	e8 5c f4 ff ff       	call   800261 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e08:	5b                   	pop    %ebx
  800e09:	5e                   	pop    %esi
  800e0a:	5f                   	pop    %edi
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    

00800e0d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	57                   	push   %edi
  800e11:	56                   	push   %esi
  800e12:	53                   	push   %ebx
  800e13:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e16:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e23:	8b 55 08             	mov    0x8(%ebp),%edx
  800e26:	89 df                	mov    %ebx,%edi
  800e28:	89 de                	mov    %ebx,%esi
  800e2a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e2c:	85 c0                	test   %eax,%eax
  800e2e:	7e 17                	jle    800e47 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e30:	83 ec 0c             	sub    $0xc,%esp
  800e33:	50                   	push   %eax
  800e34:	6a 0a                	push   $0xa
  800e36:	68 5f 29 80 00       	push   $0x80295f
  800e3b:	6a 23                	push   $0x23
  800e3d:	68 7c 29 80 00       	push   $0x80297c
  800e42:	e8 1a f4 ff ff       	call   800261 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4a:	5b                   	pop    %ebx
  800e4b:	5e                   	pop    %esi
  800e4c:	5f                   	pop    %edi
  800e4d:	5d                   	pop    %ebp
  800e4e:	c3                   	ret    

00800e4f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	57                   	push   %edi
  800e53:	56                   	push   %esi
  800e54:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e55:	be 00 00 00 00       	mov    $0x0,%esi
  800e5a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e62:	8b 55 08             	mov    0x8(%ebp),%edx
  800e65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e68:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e6b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e6d:	5b                   	pop    %ebx
  800e6e:	5e                   	pop    %esi
  800e6f:	5f                   	pop    %edi
  800e70:	5d                   	pop    %ebp
  800e71:	c3                   	ret    

00800e72 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e72:	55                   	push   %ebp
  800e73:	89 e5                	mov    %esp,%ebp
  800e75:	57                   	push   %edi
  800e76:	56                   	push   %esi
  800e77:	53                   	push   %ebx
  800e78:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e80:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e85:	8b 55 08             	mov    0x8(%ebp),%edx
  800e88:	89 cb                	mov    %ecx,%ebx
  800e8a:	89 cf                	mov    %ecx,%edi
  800e8c:	89 ce                	mov    %ecx,%esi
  800e8e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e90:	85 c0                	test   %eax,%eax
  800e92:	7e 17                	jle    800eab <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e94:	83 ec 0c             	sub    $0xc,%esp
  800e97:	50                   	push   %eax
  800e98:	6a 0d                	push   $0xd
  800e9a:	68 5f 29 80 00       	push   $0x80295f
  800e9f:	6a 23                	push   $0x23
  800ea1:	68 7c 29 80 00       	push   $0x80297c
  800ea6:	e8 b6 f3 ff ff       	call   800261 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eae:	5b                   	pop    %ebx
  800eaf:	5e                   	pop    %esi
  800eb0:	5f                   	pop    %edi
  800eb1:	5d                   	pop    %ebp
  800eb2:	c3                   	ret    

00800eb3 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
  800eb6:	57                   	push   %edi
  800eb7:	56                   	push   %esi
  800eb8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ebe:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ec3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec6:	89 cb                	mov    %ecx,%ebx
  800ec8:	89 cf                	mov    %ecx,%edi
  800eca:	89 ce                	mov    %ecx,%esi
  800ecc:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800ece:	5b                   	pop    %ebx
  800ecf:	5e                   	pop    %esi
  800ed0:	5f                   	pop    %edi
  800ed1:	5d                   	pop    %ebp
  800ed2:	c3                   	ret    

00800ed3 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800ed3:	55                   	push   %ebp
  800ed4:	89 e5                	mov    %esp,%ebp
  800ed6:	57                   	push   %edi
  800ed7:	56                   	push   %esi
  800ed8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ede:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ee3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee6:	89 cb                	mov    %ecx,%ebx
  800ee8:	89 cf                	mov    %ecx,%edi
  800eea:	89 ce                	mov    %ecx,%esi
  800eec:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800eee:	5b                   	pop    %ebx
  800eef:	5e                   	pop    %esi
  800ef0:	5f                   	pop    %edi
  800ef1:	5d                   	pop    %ebp
  800ef2:	c3                   	ret    

00800ef3 <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	57                   	push   %edi
  800ef7:	56                   	push   %esi
  800ef8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800efe:	b8 10 00 00 00       	mov    $0x10,%eax
  800f03:	8b 55 08             	mov    0x8(%ebp),%edx
  800f06:	89 cb                	mov    %ecx,%ebx
  800f08:	89 cf                	mov    %ecx,%edi
  800f0a:	89 ce                	mov    %ecx,%esi
  800f0c:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  800f0e:	5b                   	pop    %ebx
  800f0f:	5e                   	pop    %esi
  800f10:	5f                   	pop    %edi
  800f11:	5d                   	pop    %ebp
  800f12:	c3                   	ret    

00800f13 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f13:	55                   	push   %ebp
  800f14:	89 e5                	mov    %esp,%ebp
  800f16:	53                   	push   %ebx
  800f17:	83 ec 04             	sub    $0x4,%esp
  800f1a:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f1d:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800f1f:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f23:	74 11                	je     800f36 <pgfault+0x23>
  800f25:	89 d8                	mov    %ebx,%eax
  800f27:	c1 e8 0c             	shr    $0xc,%eax
  800f2a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f31:	f6 c4 08             	test   $0x8,%ah
  800f34:	75 14                	jne    800f4a <pgfault+0x37>
		panic("faulting access");
  800f36:	83 ec 04             	sub    $0x4,%esp
  800f39:	68 8a 29 80 00       	push   $0x80298a
  800f3e:	6a 1f                	push   $0x1f
  800f40:	68 9a 29 80 00       	push   $0x80299a
  800f45:	e8 17 f3 ff ff       	call   800261 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800f4a:	83 ec 04             	sub    $0x4,%esp
  800f4d:	6a 07                	push   $0x7
  800f4f:	68 00 f0 7f 00       	push   $0x7ff000
  800f54:	6a 00                	push   $0x0
  800f56:	e8 67 fd ff ff       	call   800cc2 <sys_page_alloc>
	if (r < 0) {
  800f5b:	83 c4 10             	add    $0x10,%esp
  800f5e:	85 c0                	test   %eax,%eax
  800f60:	79 12                	jns    800f74 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800f62:	50                   	push   %eax
  800f63:	68 a5 29 80 00       	push   $0x8029a5
  800f68:	6a 2d                	push   $0x2d
  800f6a:	68 9a 29 80 00       	push   $0x80299a
  800f6f:	e8 ed f2 ff ff       	call   800261 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800f74:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800f7a:	83 ec 04             	sub    $0x4,%esp
  800f7d:	68 00 10 00 00       	push   $0x1000
  800f82:	53                   	push   %ebx
  800f83:	68 00 f0 7f 00       	push   $0x7ff000
  800f88:	e8 2c fb ff ff       	call   800ab9 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800f8d:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f94:	53                   	push   %ebx
  800f95:	6a 00                	push   $0x0
  800f97:	68 00 f0 7f 00       	push   $0x7ff000
  800f9c:	6a 00                	push   $0x0
  800f9e:	e8 62 fd ff ff       	call   800d05 <sys_page_map>
	if (r < 0) {
  800fa3:	83 c4 20             	add    $0x20,%esp
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	79 12                	jns    800fbc <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800faa:	50                   	push   %eax
  800fab:	68 a5 29 80 00       	push   $0x8029a5
  800fb0:	6a 34                	push   $0x34
  800fb2:	68 9a 29 80 00       	push   $0x80299a
  800fb7:	e8 a5 f2 ff ff       	call   800261 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800fbc:	83 ec 08             	sub    $0x8,%esp
  800fbf:	68 00 f0 7f 00       	push   $0x7ff000
  800fc4:	6a 00                	push   $0x0
  800fc6:	e8 7c fd ff ff       	call   800d47 <sys_page_unmap>
	if (r < 0) {
  800fcb:	83 c4 10             	add    $0x10,%esp
  800fce:	85 c0                	test   %eax,%eax
  800fd0:	79 12                	jns    800fe4 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800fd2:	50                   	push   %eax
  800fd3:	68 a5 29 80 00       	push   $0x8029a5
  800fd8:	6a 38                	push   $0x38
  800fda:	68 9a 29 80 00       	push   $0x80299a
  800fdf:	e8 7d f2 ff ff       	call   800261 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800fe4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fe7:	c9                   	leave  
  800fe8:	c3                   	ret    

00800fe9 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fe9:	55                   	push   %ebp
  800fea:	89 e5                	mov    %esp,%ebp
  800fec:	57                   	push   %edi
  800fed:	56                   	push   %esi
  800fee:	53                   	push   %ebx
  800fef:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800ff2:	68 13 0f 80 00       	push   $0x800f13
  800ff7:	e8 10 11 00 00       	call   80210c <set_pgfault_handler>
  800ffc:	b8 07 00 00 00       	mov    $0x7,%eax
  801001:	cd 30                	int    $0x30
  801003:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  801006:	83 c4 10             	add    $0x10,%esp
  801009:	85 c0                	test   %eax,%eax
  80100b:	79 17                	jns    801024 <fork+0x3b>
		panic("fork fault %e");
  80100d:	83 ec 04             	sub    $0x4,%esp
  801010:	68 be 29 80 00       	push   $0x8029be
  801015:	68 85 00 00 00       	push   $0x85
  80101a:	68 9a 29 80 00       	push   $0x80299a
  80101f:	e8 3d f2 ff ff       	call   800261 <_panic>
  801024:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  801026:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80102a:	75 24                	jne    801050 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  80102c:	e8 53 fc ff ff       	call   800c84 <sys_getenvid>
  801031:	25 ff 03 00 00       	and    $0x3ff,%eax
  801036:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  80103c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801041:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801046:	b8 00 00 00 00       	mov    $0x0,%eax
  80104b:	e9 64 01 00 00       	jmp    8011b4 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  801050:	83 ec 04             	sub    $0x4,%esp
  801053:	6a 07                	push   $0x7
  801055:	68 00 f0 bf ee       	push   $0xeebff000
  80105a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80105d:	e8 60 fc ff ff       	call   800cc2 <sys_page_alloc>
  801062:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801065:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80106a:	89 d8                	mov    %ebx,%eax
  80106c:	c1 e8 16             	shr    $0x16,%eax
  80106f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801076:	a8 01                	test   $0x1,%al
  801078:	0f 84 fc 00 00 00    	je     80117a <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  80107e:	89 d8                	mov    %ebx,%eax
  801080:	c1 e8 0c             	shr    $0xc,%eax
  801083:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80108a:	f6 c2 01             	test   $0x1,%dl
  80108d:	0f 84 e7 00 00 00    	je     80117a <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  801093:	89 c6                	mov    %eax,%esi
  801095:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  801098:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80109f:	f6 c6 04             	test   $0x4,%dh
  8010a2:	74 39                	je     8010dd <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  8010a4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010ab:	83 ec 0c             	sub    $0xc,%esp
  8010ae:	25 07 0e 00 00       	and    $0xe07,%eax
  8010b3:	50                   	push   %eax
  8010b4:	56                   	push   %esi
  8010b5:	57                   	push   %edi
  8010b6:	56                   	push   %esi
  8010b7:	6a 00                	push   $0x0
  8010b9:	e8 47 fc ff ff       	call   800d05 <sys_page_map>
		if (r < 0) {
  8010be:	83 c4 20             	add    $0x20,%esp
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	0f 89 b1 00 00 00    	jns    80117a <fork+0x191>
		    	panic("sys page map fault %e");
  8010c9:	83 ec 04             	sub    $0x4,%esp
  8010cc:	68 cc 29 80 00       	push   $0x8029cc
  8010d1:	6a 55                	push   $0x55
  8010d3:	68 9a 29 80 00       	push   $0x80299a
  8010d8:	e8 84 f1 ff ff       	call   800261 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8010dd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010e4:	f6 c2 02             	test   $0x2,%dl
  8010e7:	75 0c                	jne    8010f5 <fork+0x10c>
  8010e9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010f0:	f6 c4 08             	test   $0x8,%ah
  8010f3:	74 5b                	je     801150 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8010f5:	83 ec 0c             	sub    $0xc,%esp
  8010f8:	68 05 08 00 00       	push   $0x805
  8010fd:	56                   	push   %esi
  8010fe:	57                   	push   %edi
  8010ff:	56                   	push   %esi
  801100:	6a 00                	push   $0x0
  801102:	e8 fe fb ff ff       	call   800d05 <sys_page_map>
		if (r < 0) {
  801107:	83 c4 20             	add    $0x20,%esp
  80110a:	85 c0                	test   %eax,%eax
  80110c:	79 14                	jns    801122 <fork+0x139>
		    	panic("sys page map fault %e");
  80110e:	83 ec 04             	sub    $0x4,%esp
  801111:	68 cc 29 80 00       	push   $0x8029cc
  801116:	6a 5c                	push   $0x5c
  801118:	68 9a 29 80 00       	push   $0x80299a
  80111d:	e8 3f f1 ff ff       	call   800261 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  801122:	83 ec 0c             	sub    $0xc,%esp
  801125:	68 05 08 00 00       	push   $0x805
  80112a:	56                   	push   %esi
  80112b:	6a 00                	push   $0x0
  80112d:	56                   	push   %esi
  80112e:	6a 00                	push   $0x0
  801130:	e8 d0 fb ff ff       	call   800d05 <sys_page_map>
		if (r < 0) {
  801135:	83 c4 20             	add    $0x20,%esp
  801138:	85 c0                	test   %eax,%eax
  80113a:	79 3e                	jns    80117a <fork+0x191>
		    	panic("sys page map fault %e");
  80113c:	83 ec 04             	sub    $0x4,%esp
  80113f:	68 cc 29 80 00       	push   $0x8029cc
  801144:	6a 60                	push   $0x60
  801146:	68 9a 29 80 00       	push   $0x80299a
  80114b:	e8 11 f1 ff ff       	call   800261 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801150:	83 ec 0c             	sub    $0xc,%esp
  801153:	6a 05                	push   $0x5
  801155:	56                   	push   %esi
  801156:	57                   	push   %edi
  801157:	56                   	push   %esi
  801158:	6a 00                	push   $0x0
  80115a:	e8 a6 fb ff ff       	call   800d05 <sys_page_map>
		if (r < 0) {
  80115f:	83 c4 20             	add    $0x20,%esp
  801162:	85 c0                	test   %eax,%eax
  801164:	79 14                	jns    80117a <fork+0x191>
		    	panic("sys page map fault %e");
  801166:	83 ec 04             	sub    $0x4,%esp
  801169:	68 cc 29 80 00       	push   $0x8029cc
  80116e:	6a 65                	push   $0x65
  801170:	68 9a 29 80 00       	push   $0x80299a
  801175:	e8 e7 f0 ff ff       	call   800261 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80117a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801180:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801186:	0f 85 de fe ff ff    	jne    80106a <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  80118c:	a1 04 40 80 00       	mov    0x804004,%eax
  801191:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
  801197:	83 ec 08             	sub    $0x8,%esp
  80119a:	50                   	push   %eax
  80119b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80119e:	57                   	push   %edi
  80119f:	e8 69 fc ff ff       	call   800e0d <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  8011a4:	83 c4 08             	add    $0x8,%esp
  8011a7:	6a 02                	push   $0x2
  8011a9:	57                   	push   %edi
  8011aa:	e8 da fb ff ff       	call   800d89 <sys_env_set_status>
	
	return envid;
  8011af:	83 c4 10             	add    $0x10,%esp
  8011b2:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  8011b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b7:	5b                   	pop    %ebx
  8011b8:	5e                   	pop    %esi
  8011b9:	5f                   	pop    %edi
  8011ba:	5d                   	pop    %ebp
  8011bb:	c3                   	ret    

008011bc <sfork>:

envid_t
sfork(void)
{
  8011bc:	55                   	push   %ebp
  8011bd:	89 e5                	mov    %esp,%ebp
	return 0;
}
  8011bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c4:	5d                   	pop    %ebp
  8011c5:	c3                   	ret    

008011c6 <thread_create>:

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  8011c6:	55                   	push   %ebp
  8011c7:	89 e5                	mov    %esp,%ebp
  8011c9:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  8011cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8011cf:	a3 08 40 80 00       	mov    %eax,0x804008
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8011d4:	68 27 02 80 00       	push   $0x800227
  8011d9:	e8 d5 fc ff ff       	call   800eb3 <sys_thread_create>

	return id;
}
  8011de:	c9                   	leave  
  8011df:	c3                   	ret    

008011e0 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  8011e6:	ff 75 08             	pushl  0x8(%ebp)
  8011e9:	e8 e5 fc ff ff       	call   800ed3 <sys_thread_free>
}
  8011ee:	83 c4 10             	add    $0x10,%esp
  8011f1:	c9                   	leave  
  8011f2:	c3                   	ret    

008011f3 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  8011f9:	ff 75 08             	pushl  0x8(%ebp)
  8011fc:	e8 f2 fc ff ff       	call   800ef3 <sys_thread_join>
}
  801201:	83 c4 10             	add    $0x10,%esp
  801204:	c9                   	leave  
  801205:	c3                   	ret    

00801206 <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  801206:	55                   	push   %ebp
  801207:	89 e5                	mov    %esp,%ebp
  801209:	56                   	push   %esi
  80120a:	53                   	push   %ebx
  80120b:	8b 75 08             	mov    0x8(%ebp),%esi
  80120e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  801211:	83 ec 04             	sub    $0x4,%esp
  801214:	6a 07                	push   $0x7
  801216:	6a 00                	push   $0x0
  801218:	56                   	push   %esi
  801219:	e8 a4 fa ff ff       	call   800cc2 <sys_page_alloc>
	if (r < 0) {
  80121e:	83 c4 10             	add    $0x10,%esp
  801221:	85 c0                	test   %eax,%eax
  801223:	79 15                	jns    80123a <queue_append+0x34>
		panic("%e\n", r);
  801225:	50                   	push   %eax
  801226:	68 12 2a 80 00       	push   $0x802a12
  80122b:	68 d5 00 00 00       	push   $0xd5
  801230:	68 9a 29 80 00       	push   $0x80299a
  801235:	e8 27 f0 ff ff       	call   800261 <_panic>
	}	

	wt->envid = envid;
  80123a:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  801240:	83 3b 00             	cmpl   $0x0,(%ebx)
  801243:	75 13                	jne    801258 <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  801245:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  80124c:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801253:	00 00 00 
  801256:	eb 1b                	jmp    801273 <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  801258:	8b 43 04             	mov    0x4(%ebx),%eax
  80125b:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  801262:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801269:	00 00 00 
		queue->last = wt;
  80126c:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801273:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801276:	5b                   	pop    %ebx
  801277:	5e                   	pop    %esi
  801278:	5d                   	pop    %ebp
  801279:	c3                   	ret    

0080127a <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  80127a:	55                   	push   %ebp
  80127b:	89 e5                	mov    %esp,%ebp
  80127d:	83 ec 08             	sub    $0x8,%esp
  801280:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  801283:	8b 02                	mov    (%edx),%eax
  801285:	85 c0                	test   %eax,%eax
  801287:	75 17                	jne    8012a0 <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  801289:	83 ec 04             	sub    $0x4,%esp
  80128c:	68 e2 29 80 00       	push   $0x8029e2
  801291:	68 ec 00 00 00       	push   $0xec
  801296:	68 9a 29 80 00       	push   $0x80299a
  80129b:	e8 c1 ef ff ff       	call   800261 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  8012a0:	8b 48 04             	mov    0x4(%eax),%ecx
  8012a3:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  8012a5:	8b 00                	mov    (%eax),%eax
}
  8012a7:	c9                   	leave  
  8012a8:	c3                   	ret    

008012a9 <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  8012a9:	55                   	push   %ebp
  8012aa:	89 e5                	mov    %esp,%ebp
  8012ac:	53                   	push   %ebx
  8012ad:	83 ec 04             	sub    $0x4,%esp
  8012b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  8012b3:	b8 01 00 00 00       	mov    $0x1,%eax
  8012b8:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0)) {
  8012bb:	85 c0                	test   %eax,%eax
  8012bd:	74 45                	je     801304 <mutex_lock+0x5b>
		queue_append(sys_getenvid(), &mtx->queue);		
  8012bf:	e8 c0 f9 ff ff       	call   800c84 <sys_getenvid>
  8012c4:	83 ec 08             	sub    $0x8,%esp
  8012c7:	83 c3 04             	add    $0x4,%ebx
  8012ca:	53                   	push   %ebx
  8012cb:	50                   	push   %eax
  8012cc:	e8 35 ff ff ff       	call   801206 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  8012d1:	e8 ae f9 ff ff       	call   800c84 <sys_getenvid>
  8012d6:	83 c4 08             	add    $0x8,%esp
  8012d9:	6a 04                	push   $0x4
  8012db:	50                   	push   %eax
  8012dc:	e8 a8 fa ff ff       	call   800d89 <sys_env_set_status>

		if (r < 0) {
  8012e1:	83 c4 10             	add    $0x10,%esp
  8012e4:	85 c0                	test   %eax,%eax
  8012e6:	79 15                	jns    8012fd <mutex_lock+0x54>
			panic("%e\n", r);
  8012e8:	50                   	push   %eax
  8012e9:	68 12 2a 80 00       	push   $0x802a12
  8012ee:	68 02 01 00 00       	push   $0x102
  8012f3:	68 9a 29 80 00       	push   $0x80299a
  8012f8:	e8 64 ef ff ff       	call   800261 <_panic>
		}
		sys_yield();
  8012fd:	e8 a1 f9 ff ff       	call   800ca3 <sys_yield>
  801302:	eb 08                	jmp    80130c <mutex_lock+0x63>
	} else {
		mtx->owner = sys_getenvid();
  801304:	e8 7b f9 ff ff       	call   800c84 <sys_getenvid>
  801309:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80130c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80130f:	c9                   	leave  
  801310:	c3                   	ret    

00801311 <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  801311:	55                   	push   %ebp
  801312:	89 e5                	mov    %esp,%ebp
  801314:	53                   	push   %ebx
  801315:	83 ec 04             	sub    $0x4,%esp
  801318:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	if (mtx->queue.first != NULL) {
  80131b:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  80131f:	74 36                	je     801357 <mutex_unlock+0x46>
		mtx->owner = queue_pop(&mtx->queue);
  801321:	83 ec 0c             	sub    $0xc,%esp
  801324:	8d 43 04             	lea    0x4(%ebx),%eax
  801327:	50                   	push   %eax
  801328:	e8 4d ff ff ff       	call   80127a <queue_pop>
  80132d:	89 43 0c             	mov    %eax,0xc(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  801330:	83 c4 08             	add    $0x8,%esp
  801333:	6a 02                	push   $0x2
  801335:	50                   	push   %eax
  801336:	e8 4e fa ff ff       	call   800d89 <sys_env_set_status>
		if (r < 0) {
  80133b:	83 c4 10             	add    $0x10,%esp
  80133e:	85 c0                	test   %eax,%eax
  801340:	79 1d                	jns    80135f <mutex_unlock+0x4e>
			panic("%e\n", r);
  801342:	50                   	push   %eax
  801343:	68 12 2a 80 00       	push   $0x802a12
  801348:	68 16 01 00 00       	push   $0x116
  80134d:	68 9a 29 80 00       	push   $0x80299a
  801352:	e8 0a ef ff ff       	call   800261 <_panic>
  801357:	b8 00 00 00 00       	mov    $0x0,%eax
  80135c:	f0 87 03             	lock xchg %eax,(%ebx)
		}
	} else xchg(&mtx->locked, 0);
	
	//asm volatile("pause"); 	// might be useless here
	sys_yield();
  80135f:	e8 3f f9 ff ff       	call   800ca3 <sys_yield>
}
  801364:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801367:	c9                   	leave  
  801368:	c3                   	ret    

00801369 <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  801369:	55                   	push   %ebp
  80136a:	89 e5                	mov    %esp,%ebp
  80136c:	53                   	push   %ebx
  80136d:	83 ec 04             	sub    $0x4,%esp
  801370:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  801373:	e8 0c f9 ff ff       	call   800c84 <sys_getenvid>
  801378:	83 ec 04             	sub    $0x4,%esp
  80137b:	6a 07                	push   $0x7
  80137d:	53                   	push   %ebx
  80137e:	50                   	push   %eax
  80137f:	e8 3e f9 ff ff       	call   800cc2 <sys_page_alloc>
  801384:	83 c4 10             	add    $0x10,%esp
  801387:	85 c0                	test   %eax,%eax
  801389:	79 15                	jns    8013a0 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  80138b:	50                   	push   %eax
  80138c:	68 fd 29 80 00       	push   $0x8029fd
  801391:	68 23 01 00 00       	push   $0x123
  801396:	68 9a 29 80 00       	push   $0x80299a
  80139b:	e8 c1 ee ff ff       	call   800261 <_panic>
	}	
	mtx->locked = 0;
  8013a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue.first = NULL;
  8013a6:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	mtx->queue.last = NULL;
  8013ad:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	mtx->owner = 0;
  8013b4:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
}
  8013bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013be:	c9                   	leave  
  8013bf:	c3                   	ret    

008013c0 <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  8013c0:	55                   	push   %ebp
  8013c1:	89 e5                	mov    %esp,%ebp
  8013c3:	56                   	push   %esi
  8013c4:	53                   	push   %ebx
  8013c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue.first != NULL) {
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  8013c8:	8d 73 04             	lea    0x4(%ebx),%esi

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  8013cb:	eb 20                	jmp    8013ed <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  8013cd:	83 ec 0c             	sub    $0xc,%esp
  8013d0:	56                   	push   %esi
  8013d1:	e8 a4 fe ff ff       	call   80127a <queue_pop>
  8013d6:	83 c4 08             	add    $0x8,%esp
  8013d9:	6a 02                	push   $0x2
  8013db:	50                   	push   %eax
  8013dc:	e8 a8 f9 ff ff       	call   800d89 <sys_env_set_status>
		mtx->queue.first = mtx->queue.first->next;
  8013e1:	8b 43 04             	mov    0x4(%ebx),%eax
  8013e4:	8b 40 04             	mov    0x4(%eax),%eax
  8013e7:	89 43 04             	mov    %eax,0x4(%ebx)
  8013ea:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  8013ed:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8013f1:	75 da                	jne    8013cd <mutex_destroy+0xd>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
		mtx->queue.first = mtx->queue.first->next;
	}

	memset(mtx, 0, PGSIZE);
  8013f3:	83 ec 04             	sub    $0x4,%esp
  8013f6:	68 00 10 00 00       	push   $0x1000
  8013fb:	6a 00                	push   $0x0
  8013fd:	53                   	push   %ebx
  8013fe:	e8 01 f6 ff ff       	call   800a04 <memset>
	mtx = NULL;
}
  801403:	83 c4 10             	add    $0x10,%esp
  801406:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801409:	5b                   	pop    %ebx
  80140a:	5e                   	pop    %esi
  80140b:	5d                   	pop    %ebp
  80140c:	c3                   	ret    

0080140d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80140d:	55                   	push   %ebp
  80140e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801410:	8b 45 08             	mov    0x8(%ebp),%eax
  801413:	05 00 00 00 30       	add    $0x30000000,%eax
  801418:	c1 e8 0c             	shr    $0xc,%eax
}
  80141b:	5d                   	pop    %ebp
  80141c:	c3                   	ret    

0080141d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80141d:	55                   	push   %ebp
  80141e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801420:	8b 45 08             	mov    0x8(%ebp),%eax
  801423:	05 00 00 00 30       	add    $0x30000000,%eax
  801428:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80142d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801432:	5d                   	pop    %ebp
  801433:	c3                   	ret    

00801434 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
  801437:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80143a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80143f:	89 c2                	mov    %eax,%edx
  801441:	c1 ea 16             	shr    $0x16,%edx
  801444:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80144b:	f6 c2 01             	test   $0x1,%dl
  80144e:	74 11                	je     801461 <fd_alloc+0x2d>
  801450:	89 c2                	mov    %eax,%edx
  801452:	c1 ea 0c             	shr    $0xc,%edx
  801455:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80145c:	f6 c2 01             	test   $0x1,%dl
  80145f:	75 09                	jne    80146a <fd_alloc+0x36>
			*fd_store = fd;
  801461:	89 01                	mov    %eax,(%ecx)
			return 0;
  801463:	b8 00 00 00 00       	mov    $0x0,%eax
  801468:	eb 17                	jmp    801481 <fd_alloc+0x4d>
  80146a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80146f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801474:	75 c9                	jne    80143f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801476:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80147c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801481:	5d                   	pop    %ebp
  801482:	c3                   	ret    

00801483 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801483:	55                   	push   %ebp
  801484:	89 e5                	mov    %esp,%ebp
  801486:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801489:	83 f8 1f             	cmp    $0x1f,%eax
  80148c:	77 36                	ja     8014c4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80148e:	c1 e0 0c             	shl    $0xc,%eax
  801491:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801496:	89 c2                	mov    %eax,%edx
  801498:	c1 ea 16             	shr    $0x16,%edx
  80149b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014a2:	f6 c2 01             	test   $0x1,%dl
  8014a5:	74 24                	je     8014cb <fd_lookup+0x48>
  8014a7:	89 c2                	mov    %eax,%edx
  8014a9:	c1 ea 0c             	shr    $0xc,%edx
  8014ac:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014b3:	f6 c2 01             	test   $0x1,%dl
  8014b6:	74 1a                	je     8014d2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014bb:	89 02                	mov    %eax,(%edx)
	return 0;
  8014bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8014c2:	eb 13                	jmp    8014d7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014c9:	eb 0c                	jmp    8014d7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014d0:	eb 05                	jmp    8014d7 <fd_lookup+0x54>
  8014d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014d7:	5d                   	pop    %ebp
  8014d8:	c3                   	ret    

008014d9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014d9:	55                   	push   %ebp
  8014da:	89 e5                	mov    %esp,%ebp
  8014dc:	83 ec 08             	sub    $0x8,%esp
  8014df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014e2:	ba 98 2a 80 00       	mov    $0x802a98,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014e7:	eb 13                	jmp    8014fc <dev_lookup+0x23>
  8014e9:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8014ec:	39 08                	cmp    %ecx,(%eax)
  8014ee:	75 0c                	jne    8014fc <dev_lookup+0x23>
			*dev = devtab[i];
  8014f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014f3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8014fa:	eb 31                	jmp    80152d <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014fc:	8b 02                	mov    (%edx),%eax
  8014fe:	85 c0                	test   %eax,%eax
  801500:	75 e7                	jne    8014e9 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801502:	a1 04 40 80 00       	mov    0x804004,%eax
  801507:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80150d:	83 ec 04             	sub    $0x4,%esp
  801510:	51                   	push   %ecx
  801511:	50                   	push   %eax
  801512:	68 18 2a 80 00       	push   $0x802a18
  801517:	e8 1e ee ff ff       	call   80033a <cprintf>
	*dev = 0;
  80151c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80151f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801525:	83 c4 10             	add    $0x10,%esp
  801528:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80152d:	c9                   	leave  
  80152e:	c3                   	ret    

0080152f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80152f:	55                   	push   %ebp
  801530:	89 e5                	mov    %esp,%ebp
  801532:	56                   	push   %esi
  801533:	53                   	push   %ebx
  801534:	83 ec 10             	sub    $0x10,%esp
  801537:	8b 75 08             	mov    0x8(%ebp),%esi
  80153a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80153d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801540:	50                   	push   %eax
  801541:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801547:	c1 e8 0c             	shr    $0xc,%eax
  80154a:	50                   	push   %eax
  80154b:	e8 33 ff ff ff       	call   801483 <fd_lookup>
  801550:	83 c4 08             	add    $0x8,%esp
  801553:	85 c0                	test   %eax,%eax
  801555:	78 05                	js     80155c <fd_close+0x2d>
	    || fd != fd2)
  801557:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80155a:	74 0c                	je     801568 <fd_close+0x39>
		return (must_exist ? r : 0);
  80155c:	84 db                	test   %bl,%bl
  80155e:	ba 00 00 00 00       	mov    $0x0,%edx
  801563:	0f 44 c2             	cmove  %edx,%eax
  801566:	eb 41                	jmp    8015a9 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801568:	83 ec 08             	sub    $0x8,%esp
  80156b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80156e:	50                   	push   %eax
  80156f:	ff 36                	pushl  (%esi)
  801571:	e8 63 ff ff ff       	call   8014d9 <dev_lookup>
  801576:	89 c3                	mov    %eax,%ebx
  801578:	83 c4 10             	add    $0x10,%esp
  80157b:	85 c0                	test   %eax,%eax
  80157d:	78 1a                	js     801599 <fd_close+0x6a>
		if (dev->dev_close)
  80157f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801582:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801585:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80158a:	85 c0                	test   %eax,%eax
  80158c:	74 0b                	je     801599 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80158e:	83 ec 0c             	sub    $0xc,%esp
  801591:	56                   	push   %esi
  801592:	ff d0                	call   *%eax
  801594:	89 c3                	mov    %eax,%ebx
  801596:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801599:	83 ec 08             	sub    $0x8,%esp
  80159c:	56                   	push   %esi
  80159d:	6a 00                	push   $0x0
  80159f:	e8 a3 f7 ff ff       	call   800d47 <sys_page_unmap>
	return r;
  8015a4:	83 c4 10             	add    $0x10,%esp
  8015a7:	89 d8                	mov    %ebx,%eax
}
  8015a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ac:	5b                   	pop    %ebx
  8015ad:	5e                   	pop    %esi
  8015ae:	5d                   	pop    %ebp
  8015af:	c3                   	ret    

008015b0 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015b0:	55                   	push   %ebp
  8015b1:	89 e5                	mov    %esp,%ebp
  8015b3:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b9:	50                   	push   %eax
  8015ba:	ff 75 08             	pushl  0x8(%ebp)
  8015bd:	e8 c1 fe ff ff       	call   801483 <fd_lookup>
  8015c2:	83 c4 08             	add    $0x8,%esp
  8015c5:	85 c0                	test   %eax,%eax
  8015c7:	78 10                	js     8015d9 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8015c9:	83 ec 08             	sub    $0x8,%esp
  8015cc:	6a 01                	push   $0x1
  8015ce:	ff 75 f4             	pushl  -0xc(%ebp)
  8015d1:	e8 59 ff ff ff       	call   80152f <fd_close>
  8015d6:	83 c4 10             	add    $0x10,%esp
}
  8015d9:	c9                   	leave  
  8015da:	c3                   	ret    

008015db <close_all>:

void
close_all(void)
{
  8015db:	55                   	push   %ebp
  8015dc:	89 e5                	mov    %esp,%ebp
  8015de:	53                   	push   %ebx
  8015df:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015e2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015e7:	83 ec 0c             	sub    $0xc,%esp
  8015ea:	53                   	push   %ebx
  8015eb:	e8 c0 ff ff ff       	call   8015b0 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015f0:	83 c3 01             	add    $0x1,%ebx
  8015f3:	83 c4 10             	add    $0x10,%esp
  8015f6:	83 fb 20             	cmp    $0x20,%ebx
  8015f9:	75 ec                	jne    8015e7 <close_all+0xc>
		close(i);
}
  8015fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015fe:	c9                   	leave  
  8015ff:	c3                   	ret    

00801600 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	57                   	push   %edi
  801604:	56                   	push   %esi
  801605:	53                   	push   %ebx
  801606:	83 ec 2c             	sub    $0x2c,%esp
  801609:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80160c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80160f:	50                   	push   %eax
  801610:	ff 75 08             	pushl  0x8(%ebp)
  801613:	e8 6b fe ff ff       	call   801483 <fd_lookup>
  801618:	83 c4 08             	add    $0x8,%esp
  80161b:	85 c0                	test   %eax,%eax
  80161d:	0f 88 c1 00 00 00    	js     8016e4 <dup+0xe4>
		return r;
	close(newfdnum);
  801623:	83 ec 0c             	sub    $0xc,%esp
  801626:	56                   	push   %esi
  801627:	e8 84 ff ff ff       	call   8015b0 <close>

	newfd = INDEX2FD(newfdnum);
  80162c:	89 f3                	mov    %esi,%ebx
  80162e:	c1 e3 0c             	shl    $0xc,%ebx
  801631:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801637:	83 c4 04             	add    $0x4,%esp
  80163a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80163d:	e8 db fd ff ff       	call   80141d <fd2data>
  801642:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801644:	89 1c 24             	mov    %ebx,(%esp)
  801647:	e8 d1 fd ff ff       	call   80141d <fd2data>
  80164c:	83 c4 10             	add    $0x10,%esp
  80164f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801652:	89 f8                	mov    %edi,%eax
  801654:	c1 e8 16             	shr    $0x16,%eax
  801657:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80165e:	a8 01                	test   $0x1,%al
  801660:	74 37                	je     801699 <dup+0x99>
  801662:	89 f8                	mov    %edi,%eax
  801664:	c1 e8 0c             	shr    $0xc,%eax
  801667:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80166e:	f6 c2 01             	test   $0x1,%dl
  801671:	74 26                	je     801699 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801673:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80167a:	83 ec 0c             	sub    $0xc,%esp
  80167d:	25 07 0e 00 00       	and    $0xe07,%eax
  801682:	50                   	push   %eax
  801683:	ff 75 d4             	pushl  -0x2c(%ebp)
  801686:	6a 00                	push   $0x0
  801688:	57                   	push   %edi
  801689:	6a 00                	push   $0x0
  80168b:	e8 75 f6 ff ff       	call   800d05 <sys_page_map>
  801690:	89 c7                	mov    %eax,%edi
  801692:	83 c4 20             	add    $0x20,%esp
  801695:	85 c0                	test   %eax,%eax
  801697:	78 2e                	js     8016c7 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801699:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80169c:	89 d0                	mov    %edx,%eax
  80169e:	c1 e8 0c             	shr    $0xc,%eax
  8016a1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016a8:	83 ec 0c             	sub    $0xc,%esp
  8016ab:	25 07 0e 00 00       	and    $0xe07,%eax
  8016b0:	50                   	push   %eax
  8016b1:	53                   	push   %ebx
  8016b2:	6a 00                	push   $0x0
  8016b4:	52                   	push   %edx
  8016b5:	6a 00                	push   $0x0
  8016b7:	e8 49 f6 ff ff       	call   800d05 <sys_page_map>
  8016bc:	89 c7                	mov    %eax,%edi
  8016be:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8016c1:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016c3:	85 ff                	test   %edi,%edi
  8016c5:	79 1d                	jns    8016e4 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016c7:	83 ec 08             	sub    $0x8,%esp
  8016ca:	53                   	push   %ebx
  8016cb:	6a 00                	push   $0x0
  8016cd:	e8 75 f6 ff ff       	call   800d47 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016d2:	83 c4 08             	add    $0x8,%esp
  8016d5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016d8:	6a 00                	push   $0x0
  8016da:	e8 68 f6 ff ff       	call   800d47 <sys_page_unmap>
	return r;
  8016df:	83 c4 10             	add    $0x10,%esp
  8016e2:	89 f8                	mov    %edi,%eax
}
  8016e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016e7:	5b                   	pop    %ebx
  8016e8:	5e                   	pop    %esi
  8016e9:	5f                   	pop    %edi
  8016ea:	5d                   	pop    %ebp
  8016eb:	c3                   	ret    

008016ec <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016ec:	55                   	push   %ebp
  8016ed:	89 e5                	mov    %esp,%ebp
  8016ef:	53                   	push   %ebx
  8016f0:	83 ec 14             	sub    $0x14,%esp
  8016f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016f9:	50                   	push   %eax
  8016fa:	53                   	push   %ebx
  8016fb:	e8 83 fd ff ff       	call   801483 <fd_lookup>
  801700:	83 c4 08             	add    $0x8,%esp
  801703:	89 c2                	mov    %eax,%edx
  801705:	85 c0                	test   %eax,%eax
  801707:	78 70                	js     801779 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801709:	83 ec 08             	sub    $0x8,%esp
  80170c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80170f:	50                   	push   %eax
  801710:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801713:	ff 30                	pushl  (%eax)
  801715:	e8 bf fd ff ff       	call   8014d9 <dev_lookup>
  80171a:	83 c4 10             	add    $0x10,%esp
  80171d:	85 c0                	test   %eax,%eax
  80171f:	78 4f                	js     801770 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801721:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801724:	8b 42 08             	mov    0x8(%edx),%eax
  801727:	83 e0 03             	and    $0x3,%eax
  80172a:	83 f8 01             	cmp    $0x1,%eax
  80172d:	75 24                	jne    801753 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80172f:	a1 04 40 80 00       	mov    0x804004,%eax
  801734:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80173a:	83 ec 04             	sub    $0x4,%esp
  80173d:	53                   	push   %ebx
  80173e:	50                   	push   %eax
  80173f:	68 5c 2a 80 00       	push   $0x802a5c
  801744:	e8 f1 eb ff ff       	call   80033a <cprintf>
		return -E_INVAL;
  801749:	83 c4 10             	add    $0x10,%esp
  80174c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801751:	eb 26                	jmp    801779 <read+0x8d>
	}
	if (!dev->dev_read)
  801753:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801756:	8b 40 08             	mov    0x8(%eax),%eax
  801759:	85 c0                	test   %eax,%eax
  80175b:	74 17                	je     801774 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80175d:	83 ec 04             	sub    $0x4,%esp
  801760:	ff 75 10             	pushl  0x10(%ebp)
  801763:	ff 75 0c             	pushl  0xc(%ebp)
  801766:	52                   	push   %edx
  801767:	ff d0                	call   *%eax
  801769:	89 c2                	mov    %eax,%edx
  80176b:	83 c4 10             	add    $0x10,%esp
  80176e:	eb 09                	jmp    801779 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801770:	89 c2                	mov    %eax,%edx
  801772:	eb 05                	jmp    801779 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801774:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801779:	89 d0                	mov    %edx,%eax
  80177b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80177e:	c9                   	leave  
  80177f:	c3                   	ret    

00801780 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	57                   	push   %edi
  801784:	56                   	push   %esi
  801785:	53                   	push   %ebx
  801786:	83 ec 0c             	sub    $0xc,%esp
  801789:	8b 7d 08             	mov    0x8(%ebp),%edi
  80178c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80178f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801794:	eb 21                	jmp    8017b7 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801796:	83 ec 04             	sub    $0x4,%esp
  801799:	89 f0                	mov    %esi,%eax
  80179b:	29 d8                	sub    %ebx,%eax
  80179d:	50                   	push   %eax
  80179e:	89 d8                	mov    %ebx,%eax
  8017a0:	03 45 0c             	add    0xc(%ebp),%eax
  8017a3:	50                   	push   %eax
  8017a4:	57                   	push   %edi
  8017a5:	e8 42 ff ff ff       	call   8016ec <read>
		if (m < 0)
  8017aa:	83 c4 10             	add    $0x10,%esp
  8017ad:	85 c0                	test   %eax,%eax
  8017af:	78 10                	js     8017c1 <readn+0x41>
			return m;
		if (m == 0)
  8017b1:	85 c0                	test   %eax,%eax
  8017b3:	74 0a                	je     8017bf <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017b5:	01 c3                	add    %eax,%ebx
  8017b7:	39 f3                	cmp    %esi,%ebx
  8017b9:	72 db                	jb     801796 <readn+0x16>
  8017bb:	89 d8                	mov    %ebx,%eax
  8017bd:	eb 02                	jmp    8017c1 <readn+0x41>
  8017bf:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8017c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017c4:	5b                   	pop    %ebx
  8017c5:	5e                   	pop    %esi
  8017c6:	5f                   	pop    %edi
  8017c7:	5d                   	pop    %ebp
  8017c8:	c3                   	ret    

008017c9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017c9:	55                   	push   %ebp
  8017ca:	89 e5                	mov    %esp,%ebp
  8017cc:	53                   	push   %ebx
  8017cd:	83 ec 14             	sub    $0x14,%esp
  8017d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d6:	50                   	push   %eax
  8017d7:	53                   	push   %ebx
  8017d8:	e8 a6 fc ff ff       	call   801483 <fd_lookup>
  8017dd:	83 c4 08             	add    $0x8,%esp
  8017e0:	89 c2                	mov    %eax,%edx
  8017e2:	85 c0                	test   %eax,%eax
  8017e4:	78 6b                	js     801851 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e6:	83 ec 08             	sub    $0x8,%esp
  8017e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ec:	50                   	push   %eax
  8017ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f0:	ff 30                	pushl  (%eax)
  8017f2:	e8 e2 fc ff ff       	call   8014d9 <dev_lookup>
  8017f7:	83 c4 10             	add    $0x10,%esp
  8017fa:	85 c0                	test   %eax,%eax
  8017fc:	78 4a                	js     801848 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801801:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801805:	75 24                	jne    80182b <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801807:	a1 04 40 80 00       	mov    0x804004,%eax
  80180c:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801812:	83 ec 04             	sub    $0x4,%esp
  801815:	53                   	push   %ebx
  801816:	50                   	push   %eax
  801817:	68 78 2a 80 00       	push   $0x802a78
  80181c:	e8 19 eb ff ff       	call   80033a <cprintf>
		return -E_INVAL;
  801821:	83 c4 10             	add    $0x10,%esp
  801824:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801829:	eb 26                	jmp    801851 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80182b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80182e:	8b 52 0c             	mov    0xc(%edx),%edx
  801831:	85 d2                	test   %edx,%edx
  801833:	74 17                	je     80184c <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801835:	83 ec 04             	sub    $0x4,%esp
  801838:	ff 75 10             	pushl  0x10(%ebp)
  80183b:	ff 75 0c             	pushl  0xc(%ebp)
  80183e:	50                   	push   %eax
  80183f:	ff d2                	call   *%edx
  801841:	89 c2                	mov    %eax,%edx
  801843:	83 c4 10             	add    $0x10,%esp
  801846:	eb 09                	jmp    801851 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801848:	89 c2                	mov    %eax,%edx
  80184a:	eb 05                	jmp    801851 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80184c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801851:	89 d0                	mov    %edx,%eax
  801853:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801856:	c9                   	leave  
  801857:	c3                   	ret    

00801858 <seek>:

int
seek(int fdnum, off_t offset)
{
  801858:	55                   	push   %ebp
  801859:	89 e5                	mov    %esp,%ebp
  80185b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80185e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801861:	50                   	push   %eax
  801862:	ff 75 08             	pushl  0x8(%ebp)
  801865:	e8 19 fc ff ff       	call   801483 <fd_lookup>
  80186a:	83 c4 08             	add    $0x8,%esp
  80186d:	85 c0                	test   %eax,%eax
  80186f:	78 0e                	js     80187f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801871:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801874:	8b 55 0c             	mov    0xc(%ebp),%edx
  801877:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80187a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80187f:	c9                   	leave  
  801880:	c3                   	ret    

00801881 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801881:	55                   	push   %ebp
  801882:	89 e5                	mov    %esp,%ebp
  801884:	53                   	push   %ebx
  801885:	83 ec 14             	sub    $0x14,%esp
  801888:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80188b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80188e:	50                   	push   %eax
  80188f:	53                   	push   %ebx
  801890:	e8 ee fb ff ff       	call   801483 <fd_lookup>
  801895:	83 c4 08             	add    $0x8,%esp
  801898:	89 c2                	mov    %eax,%edx
  80189a:	85 c0                	test   %eax,%eax
  80189c:	78 68                	js     801906 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80189e:	83 ec 08             	sub    $0x8,%esp
  8018a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a4:	50                   	push   %eax
  8018a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a8:	ff 30                	pushl  (%eax)
  8018aa:	e8 2a fc ff ff       	call   8014d9 <dev_lookup>
  8018af:	83 c4 10             	add    $0x10,%esp
  8018b2:	85 c0                	test   %eax,%eax
  8018b4:	78 47                	js     8018fd <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018bd:	75 24                	jne    8018e3 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018bf:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018c4:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8018ca:	83 ec 04             	sub    $0x4,%esp
  8018cd:	53                   	push   %ebx
  8018ce:	50                   	push   %eax
  8018cf:	68 38 2a 80 00       	push   $0x802a38
  8018d4:	e8 61 ea ff ff       	call   80033a <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018d9:	83 c4 10             	add    $0x10,%esp
  8018dc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018e1:	eb 23                	jmp    801906 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  8018e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018e6:	8b 52 18             	mov    0x18(%edx),%edx
  8018e9:	85 d2                	test   %edx,%edx
  8018eb:	74 14                	je     801901 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018ed:	83 ec 08             	sub    $0x8,%esp
  8018f0:	ff 75 0c             	pushl  0xc(%ebp)
  8018f3:	50                   	push   %eax
  8018f4:	ff d2                	call   *%edx
  8018f6:	89 c2                	mov    %eax,%edx
  8018f8:	83 c4 10             	add    $0x10,%esp
  8018fb:	eb 09                	jmp    801906 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018fd:	89 c2                	mov    %eax,%edx
  8018ff:	eb 05                	jmp    801906 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801901:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801906:	89 d0                	mov    %edx,%eax
  801908:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80190b:	c9                   	leave  
  80190c:	c3                   	ret    

0080190d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80190d:	55                   	push   %ebp
  80190e:	89 e5                	mov    %esp,%ebp
  801910:	53                   	push   %ebx
  801911:	83 ec 14             	sub    $0x14,%esp
  801914:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801917:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80191a:	50                   	push   %eax
  80191b:	ff 75 08             	pushl  0x8(%ebp)
  80191e:	e8 60 fb ff ff       	call   801483 <fd_lookup>
  801923:	83 c4 08             	add    $0x8,%esp
  801926:	89 c2                	mov    %eax,%edx
  801928:	85 c0                	test   %eax,%eax
  80192a:	78 58                	js     801984 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80192c:	83 ec 08             	sub    $0x8,%esp
  80192f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801932:	50                   	push   %eax
  801933:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801936:	ff 30                	pushl  (%eax)
  801938:	e8 9c fb ff ff       	call   8014d9 <dev_lookup>
  80193d:	83 c4 10             	add    $0x10,%esp
  801940:	85 c0                	test   %eax,%eax
  801942:	78 37                	js     80197b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801944:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801947:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80194b:	74 32                	je     80197f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80194d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801950:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801957:	00 00 00 
	stat->st_isdir = 0;
  80195a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801961:	00 00 00 
	stat->st_dev = dev;
  801964:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80196a:	83 ec 08             	sub    $0x8,%esp
  80196d:	53                   	push   %ebx
  80196e:	ff 75 f0             	pushl  -0x10(%ebp)
  801971:	ff 50 14             	call   *0x14(%eax)
  801974:	89 c2                	mov    %eax,%edx
  801976:	83 c4 10             	add    $0x10,%esp
  801979:	eb 09                	jmp    801984 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80197b:	89 c2                	mov    %eax,%edx
  80197d:	eb 05                	jmp    801984 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80197f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801984:	89 d0                	mov    %edx,%eax
  801986:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801989:	c9                   	leave  
  80198a:	c3                   	ret    

0080198b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80198b:	55                   	push   %ebp
  80198c:	89 e5                	mov    %esp,%ebp
  80198e:	56                   	push   %esi
  80198f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801990:	83 ec 08             	sub    $0x8,%esp
  801993:	6a 00                	push   $0x0
  801995:	ff 75 08             	pushl  0x8(%ebp)
  801998:	e8 e3 01 00 00       	call   801b80 <open>
  80199d:	89 c3                	mov    %eax,%ebx
  80199f:	83 c4 10             	add    $0x10,%esp
  8019a2:	85 c0                	test   %eax,%eax
  8019a4:	78 1b                	js     8019c1 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8019a6:	83 ec 08             	sub    $0x8,%esp
  8019a9:	ff 75 0c             	pushl  0xc(%ebp)
  8019ac:	50                   	push   %eax
  8019ad:	e8 5b ff ff ff       	call   80190d <fstat>
  8019b2:	89 c6                	mov    %eax,%esi
	close(fd);
  8019b4:	89 1c 24             	mov    %ebx,(%esp)
  8019b7:	e8 f4 fb ff ff       	call   8015b0 <close>
	return r;
  8019bc:	83 c4 10             	add    $0x10,%esp
  8019bf:	89 f0                	mov    %esi,%eax
}
  8019c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019c4:	5b                   	pop    %ebx
  8019c5:	5e                   	pop    %esi
  8019c6:	5d                   	pop    %ebp
  8019c7:	c3                   	ret    

008019c8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019c8:	55                   	push   %ebp
  8019c9:	89 e5                	mov    %esp,%ebp
  8019cb:	56                   	push   %esi
  8019cc:	53                   	push   %ebx
  8019cd:	89 c6                	mov    %eax,%esi
  8019cf:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019d1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8019d8:	75 12                	jne    8019ec <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019da:	83 ec 0c             	sub    $0xc,%esp
  8019dd:	6a 01                	push   $0x1
  8019df:	e8 94 08 00 00       	call   802278 <ipc_find_env>
  8019e4:	a3 00 40 80 00       	mov    %eax,0x804000
  8019e9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019ec:	6a 07                	push   $0x7
  8019ee:	68 00 50 80 00       	push   $0x805000
  8019f3:	56                   	push   %esi
  8019f4:	ff 35 00 40 80 00    	pushl  0x804000
  8019fa:	e8 17 08 00 00       	call   802216 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019ff:	83 c4 0c             	add    $0xc,%esp
  801a02:	6a 00                	push   $0x0
  801a04:	53                   	push   %ebx
  801a05:	6a 00                	push   $0x0
  801a07:	e8 8f 07 00 00       	call   80219b <ipc_recv>
}
  801a0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a0f:	5b                   	pop    %ebx
  801a10:	5e                   	pop    %esi
  801a11:	5d                   	pop    %ebp
  801a12:	c3                   	ret    

00801a13 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a13:	55                   	push   %ebp
  801a14:	89 e5                	mov    %esp,%ebp
  801a16:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a19:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1c:	8b 40 0c             	mov    0xc(%eax),%eax
  801a1f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a24:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a27:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a2c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a31:	b8 02 00 00 00       	mov    $0x2,%eax
  801a36:	e8 8d ff ff ff       	call   8019c8 <fsipc>
}
  801a3b:	c9                   	leave  
  801a3c:	c3                   	ret    

00801a3d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a3d:	55                   	push   %ebp
  801a3e:	89 e5                	mov    %esp,%ebp
  801a40:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a43:	8b 45 08             	mov    0x8(%ebp),%eax
  801a46:	8b 40 0c             	mov    0xc(%eax),%eax
  801a49:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a4e:	ba 00 00 00 00       	mov    $0x0,%edx
  801a53:	b8 06 00 00 00       	mov    $0x6,%eax
  801a58:	e8 6b ff ff ff       	call   8019c8 <fsipc>
}
  801a5d:	c9                   	leave  
  801a5e:	c3                   	ret    

00801a5f <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	53                   	push   %ebx
  801a63:	83 ec 04             	sub    $0x4,%esp
  801a66:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a69:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6c:	8b 40 0c             	mov    0xc(%eax),%eax
  801a6f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a74:	ba 00 00 00 00       	mov    $0x0,%edx
  801a79:	b8 05 00 00 00       	mov    $0x5,%eax
  801a7e:	e8 45 ff ff ff       	call   8019c8 <fsipc>
  801a83:	85 c0                	test   %eax,%eax
  801a85:	78 2c                	js     801ab3 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a87:	83 ec 08             	sub    $0x8,%esp
  801a8a:	68 00 50 80 00       	push   $0x805000
  801a8f:	53                   	push   %ebx
  801a90:	e8 2a ee ff ff       	call   8008bf <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a95:	a1 80 50 80 00       	mov    0x805080,%eax
  801a9a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801aa0:	a1 84 50 80 00       	mov    0x805084,%eax
  801aa5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801aab:	83 c4 10             	add    $0x10,%esp
  801aae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ab3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ab6:	c9                   	leave  
  801ab7:	c3                   	ret    

00801ab8 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801ab8:	55                   	push   %ebp
  801ab9:	89 e5                	mov    %esp,%ebp
  801abb:	83 ec 0c             	sub    $0xc,%esp
  801abe:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801ac1:	8b 55 08             	mov    0x8(%ebp),%edx
  801ac4:	8b 52 0c             	mov    0xc(%edx),%edx
  801ac7:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801acd:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801ad2:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801ad7:	0f 47 c2             	cmova  %edx,%eax
  801ada:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801adf:	50                   	push   %eax
  801ae0:	ff 75 0c             	pushl  0xc(%ebp)
  801ae3:	68 08 50 80 00       	push   $0x805008
  801ae8:	e8 64 ef ff ff       	call   800a51 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801aed:	ba 00 00 00 00       	mov    $0x0,%edx
  801af2:	b8 04 00 00 00       	mov    $0x4,%eax
  801af7:	e8 cc fe ff ff       	call   8019c8 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801afc:	c9                   	leave  
  801afd:	c3                   	ret    

00801afe <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801afe:	55                   	push   %ebp
  801aff:	89 e5                	mov    %esp,%ebp
  801b01:	56                   	push   %esi
  801b02:	53                   	push   %ebx
  801b03:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b06:	8b 45 08             	mov    0x8(%ebp),%eax
  801b09:	8b 40 0c             	mov    0xc(%eax),%eax
  801b0c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b11:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b17:	ba 00 00 00 00       	mov    $0x0,%edx
  801b1c:	b8 03 00 00 00       	mov    $0x3,%eax
  801b21:	e8 a2 fe ff ff       	call   8019c8 <fsipc>
  801b26:	89 c3                	mov    %eax,%ebx
  801b28:	85 c0                	test   %eax,%eax
  801b2a:	78 4b                	js     801b77 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b2c:	39 c6                	cmp    %eax,%esi
  801b2e:	73 16                	jae    801b46 <devfile_read+0x48>
  801b30:	68 a8 2a 80 00       	push   $0x802aa8
  801b35:	68 af 2a 80 00       	push   $0x802aaf
  801b3a:	6a 7c                	push   $0x7c
  801b3c:	68 c4 2a 80 00       	push   $0x802ac4
  801b41:	e8 1b e7 ff ff       	call   800261 <_panic>
	assert(r <= PGSIZE);
  801b46:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b4b:	7e 16                	jle    801b63 <devfile_read+0x65>
  801b4d:	68 cf 2a 80 00       	push   $0x802acf
  801b52:	68 af 2a 80 00       	push   $0x802aaf
  801b57:	6a 7d                	push   $0x7d
  801b59:	68 c4 2a 80 00       	push   $0x802ac4
  801b5e:	e8 fe e6 ff ff       	call   800261 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b63:	83 ec 04             	sub    $0x4,%esp
  801b66:	50                   	push   %eax
  801b67:	68 00 50 80 00       	push   $0x805000
  801b6c:	ff 75 0c             	pushl  0xc(%ebp)
  801b6f:	e8 dd ee ff ff       	call   800a51 <memmove>
	return r;
  801b74:	83 c4 10             	add    $0x10,%esp
}
  801b77:	89 d8                	mov    %ebx,%eax
  801b79:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b7c:	5b                   	pop    %ebx
  801b7d:	5e                   	pop    %esi
  801b7e:	5d                   	pop    %ebp
  801b7f:	c3                   	ret    

00801b80 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	53                   	push   %ebx
  801b84:	83 ec 20             	sub    $0x20,%esp
  801b87:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b8a:	53                   	push   %ebx
  801b8b:	e8 f6 ec ff ff       	call   800886 <strlen>
  801b90:	83 c4 10             	add    $0x10,%esp
  801b93:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b98:	7f 67                	jg     801c01 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b9a:	83 ec 0c             	sub    $0xc,%esp
  801b9d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba0:	50                   	push   %eax
  801ba1:	e8 8e f8 ff ff       	call   801434 <fd_alloc>
  801ba6:	83 c4 10             	add    $0x10,%esp
		return r;
  801ba9:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bab:	85 c0                	test   %eax,%eax
  801bad:	78 57                	js     801c06 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801baf:	83 ec 08             	sub    $0x8,%esp
  801bb2:	53                   	push   %ebx
  801bb3:	68 00 50 80 00       	push   $0x805000
  801bb8:	e8 02 ed ff ff       	call   8008bf <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bbd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bc0:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bc5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bc8:	b8 01 00 00 00       	mov    $0x1,%eax
  801bcd:	e8 f6 fd ff ff       	call   8019c8 <fsipc>
  801bd2:	89 c3                	mov    %eax,%ebx
  801bd4:	83 c4 10             	add    $0x10,%esp
  801bd7:	85 c0                	test   %eax,%eax
  801bd9:	79 14                	jns    801bef <open+0x6f>
		fd_close(fd, 0);
  801bdb:	83 ec 08             	sub    $0x8,%esp
  801bde:	6a 00                	push   $0x0
  801be0:	ff 75 f4             	pushl  -0xc(%ebp)
  801be3:	e8 47 f9 ff ff       	call   80152f <fd_close>
		return r;
  801be8:	83 c4 10             	add    $0x10,%esp
  801beb:	89 da                	mov    %ebx,%edx
  801bed:	eb 17                	jmp    801c06 <open+0x86>
	}

	return fd2num(fd);
  801bef:	83 ec 0c             	sub    $0xc,%esp
  801bf2:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf5:	e8 13 f8 ff ff       	call   80140d <fd2num>
  801bfa:	89 c2                	mov    %eax,%edx
  801bfc:	83 c4 10             	add    $0x10,%esp
  801bff:	eb 05                	jmp    801c06 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c01:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c06:	89 d0                	mov    %edx,%eax
  801c08:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c0b:	c9                   	leave  
  801c0c:	c3                   	ret    

00801c0d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c0d:	55                   	push   %ebp
  801c0e:	89 e5                	mov    %esp,%ebp
  801c10:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c13:	ba 00 00 00 00       	mov    $0x0,%edx
  801c18:	b8 08 00 00 00       	mov    $0x8,%eax
  801c1d:	e8 a6 fd ff ff       	call   8019c8 <fsipc>
}
  801c22:	c9                   	leave  
  801c23:	c3                   	ret    

00801c24 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c24:	55                   	push   %ebp
  801c25:	89 e5                	mov    %esp,%ebp
  801c27:	56                   	push   %esi
  801c28:	53                   	push   %ebx
  801c29:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c2c:	83 ec 0c             	sub    $0xc,%esp
  801c2f:	ff 75 08             	pushl  0x8(%ebp)
  801c32:	e8 e6 f7 ff ff       	call   80141d <fd2data>
  801c37:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c39:	83 c4 08             	add    $0x8,%esp
  801c3c:	68 db 2a 80 00       	push   $0x802adb
  801c41:	53                   	push   %ebx
  801c42:	e8 78 ec ff ff       	call   8008bf <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c47:	8b 46 04             	mov    0x4(%esi),%eax
  801c4a:	2b 06                	sub    (%esi),%eax
  801c4c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c52:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c59:	00 00 00 
	stat->st_dev = &devpipe;
  801c5c:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c63:	30 80 00 
	return 0;
}
  801c66:	b8 00 00 00 00       	mov    $0x0,%eax
  801c6b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c6e:	5b                   	pop    %ebx
  801c6f:	5e                   	pop    %esi
  801c70:	5d                   	pop    %ebp
  801c71:	c3                   	ret    

00801c72 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c72:	55                   	push   %ebp
  801c73:	89 e5                	mov    %esp,%ebp
  801c75:	53                   	push   %ebx
  801c76:	83 ec 0c             	sub    $0xc,%esp
  801c79:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c7c:	53                   	push   %ebx
  801c7d:	6a 00                	push   $0x0
  801c7f:	e8 c3 f0 ff ff       	call   800d47 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c84:	89 1c 24             	mov    %ebx,(%esp)
  801c87:	e8 91 f7 ff ff       	call   80141d <fd2data>
  801c8c:	83 c4 08             	add    $0x8,%esp
  801c8f:	50                   	push   %eax
  801c90:	6a 00                	push   $0x0
  801c92:	e8 b0 f0 ff ff       	call   800d47 <sys_page_unmap>
}
  801c97:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c9a:	c9                   	leave  
  801c9b:	c3                   	ret    

00801c9c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c9c:	55                   	push   %ebp
  801c9d:	89 e5                	mov    %esp,%ebp
  801c9f:	57                   	push   %edi
  801ca0:	56                   	push   %esi
  801ca1:	53                   	push   %ebx
  801ca2:	83 ec 1c             	sub    $0x1c,%esp
  801ca5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ca8:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801caa:	a1 04 40 80 00       	mov    0x804004,%eax
  801caf:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801cb5:	83 ec 0c             	sub    $0xc,%esp
  801cb8:	ff 75 e0             	pushl  -0x20(%ebp)
  801cbb:	e8 fd 05 00 00       	call   8022bd <pageref>
  801cc0:	89 c3                	mov    %eax,%ebx
  801cc2:	89 3c 24             	mov    %edi,(%esp)
  801cc5:	e8 f3 05 00 00       	call   8022bd <pageref>
  801cca:	83 c4 10             	add    $0x10,%esp
  801ccd:	39 c3                	cmp    %eax,%ebx
  801ccf:	0f 94 c1             	sete   %cl
  801cd2:	0f b6 c9             	movzbl %cl,%ecx
  801cd5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801cd8:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801cde:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  801ce4:	39 ce                	cmp    %ecx,%esi
  801ce6:	74 1e                	je     801d06 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801ce8:	39 c3                	cmp    %eax,%ebx
  801cea:	75 be                	jne    801caa <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cec:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  801cf2:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cf5:	50                   	push   %eax
  801cf6:	56                   	push   %esi
  801cf7:	68 e2 2a 80 00       	push   $0x802ae2
  801cfc:	e8 39 e6 ff ff       	call   80033a <cprintf>
  801d01:	83 c4 10             	add    $0x10,%esp
  801d04:	eb a4                	jmp    801caa <_pipeisclosed+0xe>
	}
}
  801d06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d0c:	5b                   	pop    %ebx
  801d0d:	5e                   	pop    %esi
  801d0e:	5f                   	pop    %edi
  801d0f:	5d                   	pop    %ebp
  801d10:	c3                   	ret    

00801d11 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d11:	55                   	push   %ebp
  801d12:	89 e5                	mov    %esp,%ebp
  801d14:	57                   	push   %edi
  801d15:	56                   	push   %esi
  801d16:	53                   	push   %ebx
  801d17:	83 ec 28             	sub    $0x28,%esp
  801d1a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d1d:	56                   	push   %esi
  801d1e:	e8 fa f6 ff ff       	call   80141d <fd2data>
  801d23:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d25:	83 c4 10             	add    $0x10,%esp
  801d28:	bf 00 00 00 00       	mov    $0x0,%edi
  801d2d:	eb 4b                	jmp    801d7a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d2f:	89 da                	mov    %ebx,%edx
  801d31:	89 f0                	mov    %esi,%eax
  801d33:	e8 64 ff ff ff       	call   801c9c <_pipeisclosed>
  801d38:	85 c0                	test   %eax,%eax
  801d3a:	75 48                	jne    801d84 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d3c:	e8 62 ef ff ff       	call   800ca3 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d41:	8b 43 04             	mov    0x4(%ebx),%eax
  801d44:	8b 0b                	mov    (%ebx),%ecx
  801d46:	8d 51 20             	lea    0x20(%ecx),%edx
  801d49:	39 d0                	cmp    %edx,%eax
  801d4b:	73 e2                	jae    801d2f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d50:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d54:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d57:	89 c2                	mov    %eax,%edx
  801d59:	c1 fa 1f             	sar    $0x1f,%edx
  801d5c:	89 d1                	mov    %edx,%ecx
  801d5e:	c1 e9 1b             	shr    $0x1b,%ecx
  801d61:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d64:	83 e2 1f             	and    $0x1f,%edx
  801d67:	29 ca                	sub    %ecx,%edx
  801d69:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d6d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d71:	83 c0 01             	add    $0x1,%eax
  801d74:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d77:	83 c7 01             	add    $0x1,%edi
  801d7a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d7d:	75 c2                	jne    801d41 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d7f:	8b 45 10             	mov    0x10(%ebp),%eax
  801d82:	eb 05                	jmp    801d89 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d84:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d8c:	5b                   	pop    %ebx
  801d8d:	5e                   	pop    %esi
  801d8e:	5f                   	pop    %edi
  801d8f:	5d                   	pop    %ebp
  801d90:	c3                   	ret    

00801d91 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d91:	55                   	push   %ebp
  801d92:	89 e5                	mov    %esp,%ebp
  801d94:	57                   	push   %edi
  801d95:	56                   	push   %esi
  801d96:	53                   	push   %ebx
  801d97:	83 ec 18             	sub    $0x18,%esp
  801d9a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d9d:	57                   	push   %edi
  801d9e:	e8 7a f6 ff ff       	call   80141d <fd2data>
  801da3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801da5:	83 c4 10             	add    $0x10,%esp
  801da8:	bb 00 00 00 00       	mov    $0x0,%ebx
  801dad:	eb 3d                	jmp    801dec <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801daf:	85 db                	test   %ebx,%ebx
  801db1:	74 04                	je     801db7 <devpipe_read+0x26>
				return i;
  801db3:	89 d8                	mov    %ebx,%eax
  801db5:	eb 44                	jmp    801dfb <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801db7:	89 f2                	mov    %esi,%edx
  801db9:	89 f8                	mov    %edi,%eax
  801dbb:	e8 dc fe ff ff       	call   801c9c <_pipeisclosed>
  801dc0:	85 c0                	test   %eax,%eax
  801dc2:	75 32                	jne    801df6 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801dc4:	e8 da ee ff ff       	call   800ca3 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801dc9:	8b 06                	mov    (%esi),%eax
  801dcb:	3b 46 04             	cmp    0x4(%esi),%eax
  801dce:	74 df                	je     801daf <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801dd0:	99                   	cltd   
  801dd1:	c1 ea 1b             	shr    $0x1b,%edx
  801dd4:	01 d0                	add    %edx,%eax
  801dd6:	83 e0 1f             	and    $0x1f,%eax
  801dd9:	29 d0                	sub    %edx,%eax
  801ddb:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801de0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801de3:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801de6:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801de9:	83 c3 01             	add    $0x1,%ebx
  801dec:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801def:	75 d8                	jne    801dc9 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801df1:	8b 45 10             	mov    0x10(%ebp),%eax
  801df4:	eb 05                	jmp    801dfb <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801df6:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801dfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dfe:	5b                   	pop    %ebx
  801dff:	5e                   	pop    %esi
  801e00:	5f                   	pop    %edi
  801e01:	5d                   	pop    %ebp
  801e02:	c3                   	ret    

00801e03 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e03:	55                   	push   %ebp
  801e04:	89 e5                	mov    %esp,%ebp
  801e06:	56                   	push   %esi
  801e07:	53                   	push   %ebx
  801e08:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e0b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e0e:	50                   	push   %eax
  801e0f:	e8 20 f6 ff ff       	call   801434 <fd_alloc>
  801e14:	83 c4 10             	add    $0x10,%esp
  801e17:	89 c2                	mov    %eax,%edx
  801e19:	85 c0                	test   %eax,%eax
  801e1b:	0f 88 2c 01 00 00    	js     801f4d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e21:	83 ec 04             	sub    $0x4,%esp
  801e24:	68 07 04 00 00       	push   $0x407
  801e29:	ff 75 f4             	pushl  -0xc(%ebp)
  801e2c:	6a 00                	push   $0x0
  801e2e:	e8 8f ee ff ff       	call   800cc2 <sys_page_alloc>
  801e33:	83 c4 10             	add    $0x10,%esp
  801e36:	89 c2                	mov    %eax,%edx
  801e38:	85 c0                	test   %eax,%eax
  801e3a:	0f 88 0d 01 00 00    	js     801f4d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e40:	83 ec 0c             	sub    $0xc,%esp
  801e43:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e46:	50                   	push   %eax
  801e47:	e8 e8 f5 ff ff       	call   801434 <fd_alloc>
  801e4c:	89 c3                	mov    %eax,%ebx
  801e4e:	83 c4 10             	add    $0x10,%esp
  801e51:	85 c0                	test   %eax,%eax
  801e53:	0f 88 e2 00 00 00    	js     801f3b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e59:	83 ec 04             	sub    $0x4,%esp
  801e5c:	68 07 04 00 00       	push   $0x407
  801e61:	ff 75 f0             	pushl  -0x10(%ebp)
  801e64:	6a 00                	push   $0x0
  801e66:	e8 57 ee ff ff       	call   800cc2 <sys_page_alloc>
  801e6b:	89 c3                	mov    %eax,%ebx
  801e6d:	83 c4 10             	add    $0x10,%esp
  801e70:	85 c0                	test   %eax,%eax
  801e72:	0f 88 c3 00 00 00    	js     801f3b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e78:	83 ec 0c             	sub    $0xc,%esp
  801e7b:	ff 75 f4             	pushl  -0xc(%ebp)
  801e7e:	e8 9a f5 ff ff       	call   80141d <fd2data>
  801e83:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e85:	83 c4 0c             	add    $0xc,%esp
  801e88:	68 07 04 00 00       	push   $0x407
  801e8d:	50                   	push   %eax
  801e8e:	6a 00                	push   $0x0
  801e90:	e8 2d ee ff ff       	call   800cc2 <sys_page_alloc>
  801e95:	89 c3                	mov    %eax,%ebx
  801e97:	83 c4 10             	add    $0x10,%esp
  801e9a:	85 c0                	test   %eax,%eax
  801e9c:	0f 88 89 00 00 00    	js     801f2b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ea2:	83 ec 0c             	sub    $0xc,%esp
  801ea5:	ff 75 f0             	pushl  -0x10(%ebp)
  801ea8:	e8 70 f5 ff ff       	call   80141d <fd2data>
  801ead:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801eb4:	50                   	push   %eax
  801eb5:	6a 00                	push   $0x0
  801eb7:	56                   	push   %esi
  801eb8:	6a 00                	push   $0x0
  801eba:	e8 46 ee ff ff       	call   800d05 <sys_page_map>
  801ebf:	89 c3                	mov    %eax,%ebx
  801ec1:	83 c4 20             	add    $0x20,%esp
  801ec4:	85 c0                	test   %eax,%eax
  801ec6:	78 55                	js     801f1d <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ec8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ed3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801edd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ee3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ee6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ee8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801eeb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ef2:	83 ec 0c             	sub    $0xc,%esp
  801ef5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ef8:	e8 10 f5 ff ff       	call   80140d <fd2num>
  801efd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f00:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f02:	83 c4 04             	add    $0x4,%esp
  801f05:	ff 75 f0             	pushl  -0x10(%ebp)
  801f08:	e8 00 f5 ff ff       	call   80140d <fd2num>
  801f0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f10:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801f13:	83 c4 10             	add    $0x10,%esp
  801f16:	ba 00 00 00 00       	mov    $0x0,%edx
  801f1b:	eb 30                	jmp    801f4d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f1d:	83 ec 08             	sub    $0x8,%esp
  801f20:	56                   	push   %esi
  801f21:	6a 00                	push   $0x0
  801f23:	e8 1f ee ff ff       	call   800d47 <sys_page_unmap>
  801f28:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f2b:	83 ec 08             	sub    $0x8,%esp
  801f2e:	ff 75 f0             	pushl  -0x10(%ebp)
  801f31:	6a 00                	push   $0x0
  801f33:	e8 0f ee ff ff       	call   800d47 <sys_page_unmap>
  801f38:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f3b:	83 ec 08             	sub    $0x8,%esp
  801f3e:	ff 75 f4             	pushl  -0xc(%ebp)
  801f41:	6a 00                	push   $0x0
  801f43:	e8 ff ed ff ff       	call   800d47 <sys_page_unmap>
  801f48:	83 c4 10             	add    $0x10,%esp
  801f4b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f4d:	89 d0                	mov    %edx,%eax
  801f4f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f52:	5b                   	pop    %ebx
  801f53:	5e                   	pop    %esi
  801f54:	5d                   	pop    %ebp
  801f55:	c3                   	ret    

00801f56 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f56:	55                   	push   %ebp
  801f57:	89 e5                	mov    %esp,%ebp
  801f59:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f5f:	50                   	push   %eax
  801f60:	ff 75 08             	pushl  0x8(%ebp)
  801f63:	e8 1b f5 ff ff       	call   801483 <fd_lookup>
  801f68:	83 c4 10             	add    $0x10,%esp
  801f6b:	85 c0                	test   %eax,%eax
  801f6d:	78 18                	js     801f87 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f6f:	83 ec 0c             	sub    $0xc,%esp
  801f72:	ff 75 f4             	pushl  -0xc(%ebp)
  801f75:	e8 a3 f4 ff ff       	call   80141d <fd2data>
	return _pipeisclosed(fd, p);
  801f7a:	89 c2                	mov    %eax,%edx
  801f7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f7f:	e8 18 fd ff ff       	call   801c9c <_pipeisclosed>
  801f84:	83 c4 10             	add    $0x10,%esp
}
  801f87:	c9                   	leave  
  801f88:	c3                   	ret    

00801f89 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f89:	55                   	push   %ebp
  801f8a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f8c:	b8 00 00 00 00       	mov    $0x0,%eax
  801f91:	5d                   	pop    %ebp
  801f92:	c3                   	ret    

00801f93 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f93:	55                   	push   %ebp
  801f94:	89 e5                	mov    %esp,%ebp
  801f96:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f99:	68 fa 2a 80 00       	push   $0x802afa
  801f9e:	ff 75 0c             	pushl  0xc(%ebp)
  801fa1:	e8 19 e9 ff ff       	call   8008bf <strcpy>
	return 0;
}
  801fa6:	b8 00 00 00 00       	mov    $0x0,%eax
  801fab:	c9                   	leave  
  801fac:	c3                   	ret    

00801fad <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fad:	55                   	push   %ebp
  801fae:	89 e5                	mov    %esp,%ebp
  801fb0:	57                   	push   %edi
  801fb1:	56                   	push   %esi
  801fb2:	53                   	push   %ebx
  801fb3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fb9:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fbe:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fc4:	eb 2d                	jmp    801ff3 <devcons_write+0x46>
		m = n - tot;
  801fc6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fc9:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801fcb:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801fce:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801fd3:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fd6:	83 ec 04             	sub    $0x4,%esp
  801fd9:	53                   	push   %ebx
  801fda:	03 45 0c             	add    0xc(%ebp),%eax
  801fdd:	50                   	push   %eax
  801fde:	57                   	push   %edi
  801fdf:	e8 6d ea ff ff       	call   800a51 <memmove>
		sys_cputs(buf, m);
  801fe4:	83 c4 08             	add    $0x8,%esp
  801fe7:	53                   	push   %ebx
  801fe8:	57                   	push   %edi
  801fe9:	e8 18 ec ff ff       	call   800c06 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fee:	01 de                	add    %ebx,%esi
  801ff0:	83 c4 10             	add    $0x10,%esp
  801ff3:	89 f0                	mov    %esi,%eax
  801ff5:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ff8:	72 cc                	jb     801fc6 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ffa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ffd:	5b                   	pop    %ebx
  801ffe:	5e                   	pop    %esi
  801fff:	5f                   	pop    %edi
  802000:	5d                   	pop    %ebp
  802001:	c3                   	ret    

00802002 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802002:	55                   	push   %ebp
  802003:	89 e5                	mov    %esp,%ebp
  802005:	83 ec 08             	sub    $0x8,%esp
  802008:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80200d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802011:	74 2a                	je     80203d <devcons_read+0x3b>
  802013:	eb 05                	jmp    80201a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802015:	e8 89 ec ff ff       	call   800ca3 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80201a:	e8 05 ec ff ff       	call   800c24 <sys_cgetc>
  80201f:	85 c0                	test   %eax,%eax
  802021:	74 f2                	je     802015 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802023:	85 c0                	test   %eax,%eax
  802025:	78 16                	js     80203d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802027:	83 f8 04             	cmp    $0x4,%eax
  80202a:	74 0c                	je     802038 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80202c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80202f:	88 02                	mov    %al,(%edx)
	return 1;
  802031:	b8 01 00 00 00       	mov    $0x1,%eax
  802036:	eb 05                	jmp    80203d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802038:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80203d:	c9                   	leave  
  80203e:	c3                   	ret    

0080203f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80203f:	55                   	push   %ebp
  802040:	89 e5                	mov    %esp,%ebp
  802042:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802045:	8b 45 08             	mov    0x8(%ebp),%eax
  802048:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80204b:	6a 01                	push   $0x1
  80204d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802050:	50                   	push   %eax
  802051:	e8 b0 eb ff ff       	call   800c06 <sys_cputs>
}
  802056:	83 c4 10             	add    $0x10,%esp
  802059:	c9                   	leave  
  80205a:	c3                   	ret    

0080205b <getchar>:

int
getchar(void)
{
  80205b:	55                   	push   %ebp
  80205c:	89 e5                	mov    %esp,%ebp
  80205e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802061:	6a 01                	push   $0x1
  802063:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802066:	50                   	push   %eax
  802067:	6a 00                	push   $0x0
  802069:	e8 7e f6 ff ff       	call   8016ec <read>
	if (r < 0)
  80206e:	83 c4 10             	add    $0x10,%esp
  802071:	85 c0                	test   %eax,%eax
  802073:	78 0f                	js     802084 <getchar+0x29>
		return r;
	if (r < 1)
  802075:	85 c0                	test   %eax,%eax
  802077:	7e 06                	jle    80207f <getchar+0x24>
		return -E_EOF;
	return c;
  802079:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80207d:	eb 05                	jmp    802084 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80207f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802084:	c9                   	leave  
  802085:	c3                   	ret    

00802086 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802086:	55                   	push   %ebp
  802087:	89 e5                	mov    %esp,%ebp
  802089:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80208c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80208f:	50                   	push   %eax
  802090:	ff 75 08             	pushl  0x8(%ebp)
  802093:	e8 eb f3 ff ff       	call   801483 <fd_lookup>
  802098:	83 c4 10             	add    $0x10,%esp
  80209b:	85 c0                	test   %eax,%eax
  80209d:	78 11                	js     8020b0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80209f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020a8:	39 10                	cmp    %edx,(%eax)
  8020aa:	0f 94 c0             	sete   %al
  8020ad:	0f b6 c0             	movzbl %al,%eax
}
  8020b0:	c9                   	leave  
  8020b1:	c3                   	ret    

008020b2 <opencons>:

int
opencons(void)
{
  8020b2:	55                   	push   %ebp
  8020b3:	89 e5                	mov    %esp,%ebp
  8020b5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020bb:	50                   	push   %eax
  8020bc:	e8 73 f3 ff ff       	call   801434 <fd_alloc>
  8020c1:	83 c4 10             	add    $0x10,%esp
		return r;
  8020c4:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020c6:	85 c0                	test   %eax,%eax
  8020c8:	78 3e                	js     802108 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020ca:	83 ec 04             	sub    $0x4,%esp
  8020cd:	68 07 04 00 00       	push   $0x407
  8020d2:	ff 75 f4             	pushl  -0xc(%ebp)
  8020d5:	6a 00                	push   $0x0
  8020d7:	e8 e6 eb ff ff       	call   800cc2 <sys_page_alloc>
  8020dc:	83 c4 10             	add    $0x10,%esp
		return r;
  8020df:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020e1:	85 c0                	test   %eax,%eax
  8020e3:	78 23                	js     802108 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020e5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ee:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020fa:	83 ec 0c             	sub    $0xc,%esp
  8020fd:	50                   	push   %eax
  8020fe:	e8 0a f3 ff ff       	call   80140d <fd2num>
  802103:	89 c2                	mov    %eax,%edx
  802105:	83 c4 10             	add    $0x10,%esp
}
  802108:	89 d0                	mov    %edx,%eax
  80210a:	c9                   	leave  
  80210b:	c3                   	ret    

0080210c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80210c:	55                   	push   %ebp
  80210d:	89 e5                	mov    %esp,%ebp
  80210f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802112:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802119:	75 2a                	jne    802145 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  80211b:	83 ec 04             	sub    $0x4,%esp
  80211e:	6a 07                	push   $0x7
  802120:	68 00 f0 bf ee       	push   $0xeebff000
  802125:	6a 00                	push   $0x0
  802127:	e8 96 eb ff ff       	call   800cc2 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  80212c:	83 c4 10             	add    $0x10,%esp
  80212f:	85 c0                	test   %eax,%eax
  802131:	79 12                	jns    802145 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802133:	50                   	push   %eax
  802134:	68 12 2a 80 00       	push   $0x802a12
  802139:	6a 23                	push   $0x23
  80213b:	68 06 2b 80 00       	push   $0x802b06
  802140:	e8 1c e1 ff ff       	call   800261 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802145:	8b 45 08             	mov    0x8(%ebp),%eax
  802148:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80214d:	83 ec 08             	sub    $0x8,%esp
  802150:	68 77 21 80 00       	push   $0x802177
  802155:	6a 00                	push   $0x0
  802157:	e8 b1 ec ff ff       	call   800e0d <sys_env_set_pgfault_upcall>
	if (r < 0) {
  80215c:	83 c4 10             	add    $0x10,%esp
  80215f:	85 c0                	test   %eax,%eax
  802161:	79 12                	jns    802175 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802163:	50                   	push   %eax
  802164:	68 12 2a 80 00       	push   $0x802a12
  802169:	6a 2c                	push   $0x2c
  80216b:	68 06 2b 80 00       	push   $0x802b06
  802170:	e8 ec e0 ff ff       	call   800261 <_panic>
	}
}
  802175:	c9                   	leave  
  802176:	c3                   	ret    

00802177 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802177:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802178:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80217d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80217f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802182:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802186:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  80218b:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  80218f:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802191:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802194:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802195:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802198:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802199:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80219a:	c3                   	ret    

0080219b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80219b:	55                   	push   %ebp
  80219c:	89 e5                	mov    %esp,%ebp
  80219e:	56                   	push   %esi
  80219f:	53                   	push   %ebx
  8021a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8021a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8021a9:	85 c0                	test   %eax,%eax
  8021ab:	75 12                	jne    8021bf <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8021ad:	83 ec 0c             	sub    $0xc,%esp
  8021b0:	68 00 00 c0 ee       	push   $0xeec00000
  8021b5:	e8 b8 ec ff ff       	call   800e72 <sys_ipc_recv>
  8021ba:	83 c4 10             	add    $0x10,%esp
  8021bd:	eb 0c                	jmp    8021cb <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8021bf:	83 ec 0c             	sub    $0xc,%esp
  8021c2:	50                   	push   %eax
  8021c3:	e8 aa ec ff ff       	call   800e72 <sys_ipc_recv>
  8021c8:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8021cb:	85 f6                	test   %esi,%esi
  8021cd:	0f 95 c1             	setne  %cl
  8021d0:	85 db                	test   %ebx,%ebx
  8021d2:	0f 95 c2             	setne  %dl
  8021d5:	84 d1                	test   %dl,%cl
  8021d7:	74 09                	je     8021e2 <ipc_recv+0x47>
  8021d9:	89 c2                	mov    %eax,%edx
  8021db:	c1 ea 1f             	shr    $0x1f,%edx
  8021de:	84 d2                	test   %dl,%dl
  8021e0:	75 2d                	jne    80220f <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8021e2:	85 f6                	test   %esi,%esi
  8021e4:	74 0d                	je     8021f3 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8021e6:	a1 04 40 80 00       	mov    0x804004,%eax
  8021eb:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  8021f1:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8021f3:	85 db                	test   %ebx,%ebx
  8021f5:	74 0d                	je     802204 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8021f7:	a1 04 40 80 00       	mov    0x804004,%eax
  8021fc:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802202:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802204:	a1 04 40 80 00       	mov    0x804004,%eax
  802209:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  80220f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802212:	5b                   	pop    %ebx
  802213:	5e                   	pop    %esi
  802214:	5d                   	pop    %ebp
  802215:	c3                   	ret    

00802216 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802216:	55                   	push   %ebp
  802217:	89 e5                	mov    %esp,%ebp
  802219:	57                   	push   %edi
  80221a:	56                   	push   %esi
  80221b:	53                   	push   %ebx
  80221c:	83 ec 0c             	sub    $0xc,%esp
  80221f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802222:	8b 75 0c             	mov    0xc(%ebp),%esi
  802225:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802228:	85 db                	test   %ebx,%ebx
  80222a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80222f:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802232:	ff 75 14             	pushl  0x14(%ebp)
  802235:	53                   	push   %ebx
  802236:	56                   	push   %esi
  802237:	57                   	push   %edi
  802238:	e8 12 ec ff ff       	call   800e4f <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  80223d:	89 c2                	mov    %eax,%edx
  80223f:	c1 ea 1f             	shr    $0x1f,%edx
  802242:	83 c4 10             	add    $0x10,%esp
  802245:	84 d2                	test   %dl,%dl
  802247:	74 17                	je     802260 <ipc_send+0x4a>
  802249:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80224c:	74 12                	je     802260 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  80224e:	50                   	push   %eax
  80224f:	68 14 2b 80 00       	push   $0x802b14
  802254:	6a 47                	push   $0x47
  802256:	68 22 2b 80 00       	push   $0x802b22
  80225b:	e8 01 e0 ff ff       	call   800261 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802260:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802263:	75 07                	jne    80226c <ipc_send+0x56>
			sys_yield();
  802265:	e8 39 ea ff ff       	call   800ca3 <sys_yield>
  80226a:	eb c6                	jmp    802232 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80226c:	85 c0                	test   %eax,%eax
  80226e:	75 c2                	jne    802232 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802270:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802273:	5b                   	pop    %ebx
  802274:	5e                   	pop    %esi
  802275:	5f                   	pop    %edi
  802276:	5d                   	pop    %ebp
  802277:	c3                   	ret    

00802278 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802278:	55                   	push   %ebp
  802279:	89 e5                	mov    %esp,%ebp
  80227b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80227e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802283:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  802289:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80228f:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  802295:	39 ca                	cmp    %ecx,%edx
  802297:	75 13                	jne    8022ac <ipc_find_env+0x34>
			return envs[i].env_id;
  802299:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  80229f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8022a4:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8022aa:	eb 0f                	jmp    8022bb <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8022ac:	83 c0 01             	add    $0x1,%eax
  8022af:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022b4:	75 cd                	jne    802283 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8022b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022bb:	5d                   	pop    %ebp
  8022bc:	c3                   	ret    

008022bd <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022bd:	55                   	push   %ebp
  8022be:	89 e5                	mov    %esp,%ebp
  8022c0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022c3:	89 d0                	mov    %edx,%eax
  8022c5:	c1 e8 16             	shr    $0x16,%eax
  8022c8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8022cf:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022d4:	f6 c1 01             	test   $0x1,%cl
  8022d7:	74 1d                	je     8022f6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8022d9:	c1 ea 0c             	shr    $0xc,%edx
  8022dc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8022e3:	f6 c2 01             	test   $0x1,%dl
  8022e6:	74 0e                	je     8022f6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8022e8:	c1 ea 0c             	shr    $0xc,%edx
  8022eb:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8022f2:	ef 
  8022f3:	0f b7 c0             	movzwl %ax,%eax
}
  8022f6:	5d                   	pop    %ebp
  8022f7:	c3                   	ret    
  8022f8:	66 90                	xchg   %ax,%ax
  8022fa:	66 90                	xchg   %ax,%ax
  8022fc:	66 90                	xchg   %ax,%ax
  8022fe:	66 90                	xchg   %ax,%ax

00802300 <__udivdi3>:
  802300:	55                   	push   %ebp
  802301:	57                   	push   %edi
  802302:	56                   	push   %esi
  802303:	53                   	push   %ebx
  802304:	83 ec 1c             	sub    $0x1c,%esp
  802307:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80230b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80230f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802313:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802317:	85 f6                	test   %esi,%esi
  802319:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80231d:	89 ca                	mov    %ecx,%edx
  80231f:	89 f8                	mov    %edi,%eax
  802321:	75 3d                	jne    802360 <__udivdi3+0x60>
  802323:	39 cf                	cmp    %ecx,%edi
  802325:	0f 87 c5 00 00 00    	ja     8023f0 <__udivdi3+0xf0>
  80232b:	85 ff                	test   %edi,%edi
  80232d:	89 fd                	mov    %edi,%ebp
  80232f:	75 0b                	jne    80233c <__udivdi3+0x3c>
  802331:	b8 01 00 00 00       	mov    $0x1,%eax
  802336:	31 d2                	xor    %edx,%edx
  802338:	f7 f7                	div    %edi
  80233a:	89 c5                	mov    %eax,%ebp
  80233c:	89 c8                	mov    %ecx,%eax
  80233e:	31 d2                	xor    %edx,%edx
  802340:	f7 f5                	div    %ebp
  802342:	89 c1                	mov    %eax,%ecx
  802344:	89 d8                	mov    %ebx,%eax
  802346:	89 cf                	mov    %ecx,%edi
  802348:	f7 f5                	div    %ebp
  80234a:	89 c3                	mov    %eax,%ebx
  80234c:	89 d8                	mov    %ebx,%eax
  80234e:	89 fa                	mov    %edi,%edx
  802350:	83 c4 1c             	add    $0x1c,%esp
  802353:	5b                   	pop    %ebx
  802354:	5e                   	pop    %esi
  802355:	5f                   	pop    %edi
  802356:	5d                   	pop    %ebp
  802357:	c3                   	ret    
  802358:	90                   	nop
  802359:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802360:	39 ce                	cmp    %ecx,%esi
  802362:	77 74                	ja     8023d8 <__udivdi3+0xd8>
  802364:	0f bd fe             	bsr    %esi,%edi
  802367:	83 f7 1f             	xor    $0x1f,%edi
  80236a:	0f 84 98 00 00 00    	je     802408 <__udivdi3+0x108>
  802370:	bb 20 00 00 00       	mov    $0x20,%ebx
  802375:	89 f9                	mov    %edi,%ecx
  802377:	89 c5                	mov    %eax,%ebp
  802379:	29 fb                	sub    %edi,%ebx
  80237b:	d3 e6                	shl    %cl,%esi
  80237d:	89 d9                	mov    %ebx,%ecx
  80237f:	d3 ed                	shr    %cl,%ebp
  802381:	89 f9                	mov    %edi,%ecx
  802383:	d3 e0                	shl    %cl,%eax
  802385:	09 ee                	or     %ebp,%esi
  802387:	89 d9                	mov    %ebx,%ecx
  802389:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80238d:	89 d5                	mov    %edx,%ebp
  80238f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802393:	d3 ed                	shr    %cl,%ebp
  802395:	89 f9                	mov    %edi,%ecx
  802397:	d3 e2                	shl    %cl,%edx
  802399:	89 d9                	mov    %ebx,%ecx
  80239b:	d3 e8                	shr    %cl,%eax
  80239d:	09 c2                	or     %eax,%edx
  80239f:	89 d0                	mov    %edx,%eax
  8023a1:	89 ea                	mov    %ebp,%edx
  8023a3:	f7 f6                	div    %esi
  8023a5:	89 d5                	mov    %edx,%ebp
  8023a7:	89 c3                	mov    %eax,%ebx
  8023a9:	f7 64 24 0c          	mull   0xc(%esp)
  8023ad:	39 d5                	cmp    %edx,%ebp
  8023af:	72 10                	jb     8023c1 <__udivdi3+0xc1>
  8023b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8023b5:	89 f9                	mov    %edi,%ecx
  8023b7:	d3 e6                	shl    %cl,%esi
  8023b9:	39 c6                	cmp    %eax,%esi
  8023bb:	73 07                	jae    8023c4 <__udivdi3+0xc4>
  8023bd:	39 d5                	cmp    %edx,%ebp
  8023bf:	75 03                	jne    8023c4 <__udivdi3+0xc4>
  8023c1:	83 eb 01             	sub    $0x1,%ebx
  8023c4:	31 ff                	xor    %edi,%edi
  8023c6:	89 d8                	mov    %ebx,%eax
  8023c8:	89 fa                	mov    %edi,%edx
  8023ca:	83 c4 1c             	add    $0x1c,%esp
  8023cd:	5b                   	pop    %ebx
  8023ce:	5e                   	pop    %esi
  8023cf:	5f                   	pop    %edi
  8023d0:	5d                   	pop    %ebp
  8023d1:	c3                   	ret    
  8023d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023d8:	31 ff                	xor    %edi,%edi
  8023da:	31 db                	xor    %ebx,%ebx
  8023dc:	89 d8                	mov    %ebx,%eax
  8023de:	89 fa                	mov    %edi,%edx
  8023e0:	83 c4 1c             	add    $0x1c,%esp
  8023e3:	5b                   	pop    %ebx
  8023e4:	5e                   	pop    %esi
  8023e5:	5f                   	pop    %edi
  8023e6:	5d                   	pop    %ebp
  8023e7:	c3                   	ret    
  8023e8:	90                   	nop
  8023e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023f0:	89 d8                	mov    %ebx,%eax
  8023f2:	f7 f7                	div    %edi
  8023f4:	31 ff                	xor    %edi,%edi
  8023f6:	89 c3                	mov    %eax,%ebx
  8023f8:	89 d8                	mov    %ebx,%eax
  8023fa:	89 fa                	mov    %edi,%edx
  8023fc:	83 c4 1c             	add    $0x1c,%esp
  8023ff:	5b                   	pop    %ebx
  802400:	5e                   	pop    %esi
  802401:	5f                   	pop    %edi
  802402:	5d                   	pop    %ebp
  802403:	c3                   	ret    
  802404:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802408:	39 ce                	cmp    %ecx,%esi
  80240a:	72 0c                	jb     802418 <__udivdi3+0x118>
  80240c:	31 db                	xor    %ebx,%ebx
  80240e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802412:	0f 87 34 ff ff ff    	ja     80234c <__udivdi3+0x4c>
  802418:	bb 01 00 00 00       	mov    $0x1,%ebx
  80241d:	e9 2a ff ff ff       	jmp    80234c <__udivdi3+0x4c>
  802422:	66 90                	xchg   %ax,%ax
  802424:	66 90                	xchg   %ax,%ax
  802426:	66 90                	xchg   %ax,%ax
  802428:	66 90                	xchg   %ax,%ax
  80242a:	66 90                	xchg   %ax,%ax
  80242c:	66 90                	xchg   %ax,%ax
  80242e:	66 90                	xchg   %ax,%ax

00802430 <__umoddi3>:
  802430:	55                   	push   %ebp
  802431:	57                   	push   %edi
  802432:	56                   	push   %esi
  802433:	53                   	push   %ebx
  802434:	83 ec 1c             	sub    $0x1c,%esp
  802437:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80243b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80243f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802443:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802447:	85 d2                	test   %edx,%edx
  802449:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80244d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802451:	89 f3                	mov    %esi,%ebx
  802453:	89 3c 24             	mov    %edi,(%esp)
  802456:	89 74 24 04          	mov    %esi,0x4(%esp)
  80245a:	75 1c                	jne    802478 <__umoddi3+0x48>
  80245c:	39 f7                	cmp    %esi,%edi
  80245e:	76 50                	jbe    8024b0 <__umoddi3+0x80>
  802460:	89 c8                	mov    %ecx,%eax
  802462:	89 f2                	mov    %esi,%edx
  802464:	f7 f7                	div    %edi
  802466:	89 d0                	mov    %edx,%eax
  802468:	31 d2                	xor    %edx,%edx
  80246a:	83 c4 1c             	add    $0x1c,%esp
  80246d:	5b                   	pop    %ebx
  80246e:	5e                   	pop    %esi
  80246f:	5f                   	pop    %edi
  802470:	5d                   	pop    %ebp
  802471:	c3                   	ret    
  802472:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802478:	39 f2                	cmp    %esi,%edx
  80247a:	89 d0                	mov    %edx,%eax
  80247c:	77 52                	ja     8024d0 <__umoddi3+0xa0>
  80247e:	0f bd ea             	bsr    %edx,%ebp
  802481:	83 f5 1f             	xor    $0x1f,%ebp
  802484:	75 5a                	jne    8024e0 <__umoddi3+0xb0>
  802486:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80248a:	0f 82 e0 00 00 00    	jb     802570 <__umoddi3+0x140>
  802490:	39 0c 24             	cmp    %ecx,(%esp)
  802493:	0f 86 d7 00 00 00    	jbe    802570 <__umoddi3+0x140>
  802499:	8b 44 24 08          	mov    0x8(%esp),%eax
  80249d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024a1:	83 c4 1c             	add    $0x1c,%esp
  8024a4:	5b                   	pop    %ebx
  8024a5:	5e                   	pop    %esi
  8024a6:	5f                   	pop    %edi
  8024a7:	5d                   	pop    %ebp
  8024a8:	c3                   	ret    
  8024a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024b0:	85 ff                	test   %edi,%edi
  8024b2:	89 fd                	mov    %edi,%ebp
  8024b4:	75 0b                	jne    8024c1 <__umoddi3+0x91>
  8024b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024bb:	31 d2                	xor    %edx,%edx
  8024bd:	f7 f7                	div    %edi
  8024bf:	89 c5                	mov    %eax,%ebp
  8024c1:	89 f0                	mov    %esi,%eax
  8024c3:	31 d2                	xor    %edx,%edx
  8024c5:	f7 f5                	div    %ebp
  8024c7:	89 c8                	mov    %ecx,%eax
  8024c9:	f7 f5                	div    %ebp
  8024cb:	89 d0                	mov    %edx,%eax
  8024cd:	eb 99                	jmp    802468 <__umoddi3+0x38>
  8024cf:	90                   	nop
  8024d0:	89 c8                	mov    %ecx,%eax
  8024d2:	89 f2                	mov    %esi,%edx
  8024d4:	83 c4 1c             	add    $0x1c,%esp
  8024d7:	5b                   	pop    %ebx
  8024d8:	5e                   	pop    %esi
  8024d9:	5f                   	pop    %edi
  8024da:	5d                   	pop    %ebp
  8024db:	c3                   	ret    
  8024dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024e0:	8b 34 24             	mov    (%esp),%esi
  8024e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8024e8:	89 e9                	mov    %ebp,%ecx
  8024ea:	29 ef                	sub    %ebp,%edi
  8024ec:	d3 e0                	shl    %cl,%eax
  8024ee:	89 f9                	mov    %edi,%ecx
  8024f0:	89 f2                	mov    %esi,%edx
  8024f2:	d3 ea                	shr    %cl,%edx
  8024f4:	89 e9                	mov    %ebp,%ecx
  8024f6:	09 c2                	or     %eax,%edx
  8024f8:	89 d8                	mov    %ebx,%eax
  8024fa:	89 14 24             	mov    %edx,(%esp)
  8024fd:	89 f2                	mov    %esi,%edx
  8024ff:	d3 e2                	shl    %cl,%edx
  802501:	89 f9                	mov    %edi,%ecx
  802503:	89 54 24 04          	mov    %edx,0x4(%esp)
  802507:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80250b:	d3 e8                	shr    %cl,%eax
  80250d:	89 e9                	mov    %ebp,%ecx
  80250f:	89 c6                	mov    %eax,%esi
  802511:	d3 e3                	shl    %cl,%ebx
  802513:	89 f9                	mov    %edi,%ecx
  802515:	89 d0                	mov    %edx,%eax
  802517:	d3 e8                	shr    %cl,%eax
  802519:	89 e9                	mov    %ebp,%ecx
  80251b:	09 d8                	or     %ebx,%eax
  80251d:	89 d3                	mov    %edx,%ebx
  80251f:	89 f2                	mov    %esi,%edx
  802521:	f7 34 24             	divl   (%esp)
  802524:	89 d6                	mov    %edx,%esi
  802526:	d3 e3                	shl    %cl,%ebx
  802528:	f7 64 24 04          	mull   0x4(%esp)
  80252c:	39 d6                	cmp    %edx,%esi
  80252e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802532:	89 d1                	mov    %edx,%ecx
  802534:	89 c3                	mov    %eax,%ebx
  802536:	72 08                	jb     802540 <__umoddi3+0x110>
  802538:	75 11                	jne    80254b <__umoddi3+0x11b>
  80253a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80253e:	73 0b                	jae    80254b <__umoddi3+0x11b>
  802540:	2b 44 24 04          	sub    0x4(%esp),%eax
  802544:	1b 14 24             	sbb    (%esp),%edx
  802547:	89 d1                	mov    %edx,%ecx
  802549:	89 c3                	mov    %eax,%ebx
  80254b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80254f:	29 da                	sub    %ebx,%edx
  802551:	19 ce                	sbb    %ecx,%esi
  802553:	89 f9                	mov    %edi,%ecx
  802555:	89 f0                	mov    %esi,%eax
  802557:	d3 e0                	shl    %cl,%eax
  802559:	89 e9                	mov    %ebp,%ecx
  80255b:	d3 ea                	shr    %cl,%edx
  80255d:	89 e9                	mov    %ebp,%ecx
  80255f:	d3 ee                	shr    %cl,%esi
  802561:	09 d0                	or     %edx,%eax
  802563:	89 f2                	mov    %esi,%edx
  802565:	83 c4 1c             	add    $0x1c,%esp
  802568:	5b                   	pop    %ebx
  802569:	5e                   	pop    %esi
  80256a:	5f                   	pop    %edi
  80256b:	5d                   	pop    %ebp
  80256c:	c3                   	ret    
  80256d:	8d 76 00             	lea    0x0(%esi),%esi
  802570:	29 f9                	sub    %edi,%ecx
  802572:	19 d6                	sbb    %edx,%esi
  802574:	89 74 24 04          	mov    %esi,0x4(%esp)
  802578:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80257c:	e9 18 ff ff ff       	jmp    802499 <__umoddi3+0x69>
