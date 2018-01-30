
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
  800052:	68 20 26 80 00       	push   $0x802620
  800057:	6a 20                	push   $0x20
  800059:	68 33 26 80 00       	push   $0x802633
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
  80007e:	68 43 26 80 00       	push   $0x802643
  800083:	6a 22                	push   $0x22
  800085:	68 33 26 80 00       	push   $0x802633
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
  8000b9:	68 54 26 80 00       	push   $0x802654
  8000be:	6a 25                	push   $0x25
  8000c0:	68 33 26 80 00       	push   $0x802633
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
  8000e7:	68 67 26 80 00       	push   $0x802667
  8000ec:	6a 37                	push   $0x37
  8000ee:	68 33 26 80 00       	push   $0x802633
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
  800108:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  80016c:	68 77 26 80 00       	push   $0x802677
  800171:	6a 4c                	push   $0x4c
  800173:	68 33 26 80 00       	push   $0x802633
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
  800198:	be 95 26 80 00       	mov    $0x802695,%esi
  80019d:	b8 8e 26 80 00       	mov    $0x80268e,%eax
  8001a2:	0f 45 f0             	cmovne %eax,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001aa:	eb 1a                	jmp    8001c6 <umain+0x40>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001ac:	83 ec 04             	sub    $0x4,%esp
  8001af:	56                   	push   %esi
  8001b0:	53                   	push   %ebx
  8001b1:	68 9b 26 80 00       	push   $0x80269b
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
  8001f3:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8001f9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001fe:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

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

void 
thread_main(/*uintptr_t eip*/)
{
  800227:	55                   	push   %ebp
  800228:	89 e5                	mov    %esp,%ebp
  80022a:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

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
  80024d:	e8 0b 14 00 00       	call   80165d <close_all>
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
  80027f:	68 b8 26 80 00       	push   $0x8026b8
  800284:	e8 b1 00 00 00       	call   80033a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800289:	83 c4 18             	add    $0x18,%esp
  80028c:	53                   	push   %ebx
  80028d:	ff 75 10             	pushl  0x10(%ebp)
  800290:	e8 54 00 00 00       	call   8002e9 <vcprintf>
	cprintf("\n");
  800295:	c7 04 24 ab 26 80 00 	movl   $0x8026ab,(%esp)
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
  80039d:	e8 de 1f 00 00       	call   802380 <__udivdi3>
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
  8003e0:	e8 cb 20 00 00       	call   8024b0 <__umoddi3>
  8003e5:	83 c4 14             	add    $0x14,%esp
  8003e8:	0f be 80 db 26 80 00 	movsbl 0x8026db(%eax),%eax
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
  8004e4:	ff 24 85 20 28 80 00 	jmp    *0x802820(,%eax,4)
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
  8005a8:	8b 14 85 80 29 80 00 	mov    0x802980(,%eax,4),%edx
  8005af:	85 d2                	test   %edx,%edx
  8005b1:	75 18                	jne    8005cb <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005b3:	50                   	push   %eax
  8005b4:	68 f3 26 80 00       	push   $0x8026f3
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
  8005cc:	68 11 2c 80 00       	push   $0x802c11
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
  8005f0:	b8 ec 26 80 00       	mov    $0x8026ec,%eax
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
  800c6b:	68 df 29 80 00       	push   $0x8029df
  800c70:	6a 23                	push   $0x23
  800c72:	68 fc 29 80 00       	push   $0x8029fc
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
  800cec:	68 df 29 80 00       	push   $0x8029df
  800cf1:	6a 23                	push   $0x23
  800cf3:	68 fc 29 80 00       	push   $0x8029fc
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
  800d2e:	68 df 29 80 00       	push   $0x8029df
  800d33:	6a 23                	push   $0x23
  800d35:	68 fc 29 80 00       	push   $0x8029fc
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
  800d70:	68 df 29 80 00       	push   $0x8029df
  800d75:	6a 23                	push   $0x23
  800d77:	68 fc 29 80 00       	push   $0x8029fc
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
  800db2:	68 df 29 80 00       	push   $0x8029df
  800db7:	6a 23                	push   $0x23
  800db9:	68 fc 29 80 00       	push   $0x8029fc
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
  800df4:	68 df 29 80 00       	push   $0x8029df
  800df9:	6a 23                	push   $0x23
  800dfb:	68 fc 29 80 00       	push   $0x8029fc
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
  800e36:	68 df 29 80 00       	push   $0x8029df
  800e3b:	6a 23                	push   $0x23
  800e3d:	68 fc 29 80 00       	push   $0x8029fc
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
  800e9a:	68 df 29 80 00       	push   $0x8029df
  800e9f:	6a 23                	push   $0x23
  800ea1:	68 fc 29 80 00       	push   $0x8029fc
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
  800f39:	68 0a 2a 80 00       	push   $0x802a0a
  800f3e:	6a 1f                	push   $0x1f
  800f40:	68 1a 2a 80 00       	push   $0x802a1a
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
  800f63:	68 25 2a 80 00       	push   $0x802a25
  800f68:	6a 2d                	push   $0x2d
  800f6a:	68 1a 2a 80 00       	push   $0x802a1a
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
  800fab:	68 25 2a 80 00       	push   $0x802a25
  800fb0:	6a 34                	push   $0x34
  800fb2:	68 1a 2a 80 00       	push   $0x802a1a
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
  800fd3:	68 25 2a 80 00       	push   $0x802a25
  800fd8:	6a 38                	push   $0x38
  800fda:	68 1a 2a 80 00       	push   $0x802a1a
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
  800ff7:	e8 92 11 00 00       	call   80218e <set_pgfault_handler>
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
  801010:	68 3e 2a 80 00       	push   $0x802a3e
  801015:	68 85 00 00 00       	push   $0x85
  80101a:	68 1a 2a 80 00       	push   $0x802a1a
  80101f:	e8 3d f2 ff ff       	call   800261 <_panic>
  801024:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  801026:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80102a:	75 24                	jne    801050 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  80102c:	e8 53 fc ff ff       	call   800c84 <sys_getenvid>
  801031:	25 ff 03 00 00       	and    $0x3ff,%eax
  801036:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  8010cc:	68 4c 2a 80 00       	push   $0x802a4c
  8010d1:	6a 55                	push   $0x55
  8010d3:	68 1a 2a 80 00       	push   $0x802a1a
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
  801111:	68 4c 2a 80 00       	push   $0x802a4c
  801116:	6a 5c                	push   $0x5c
  801118:	68 1a 2a 80 00       	push   $0x802a1a
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
  80113f:	68 4c 2a 80 00       	push   $0x802a4c
  801144:	6a 60                	push   $0x60
  801146:	68 1a 2a 80 00       	push   $0x802a1a
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
  801169:	68 4c 2a 80 00       	push   $0x802a4c
  80116e:	6a 65                	push   $0x65
  801170:	68 1a 2a 80 00       	push   $0x802a1a
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
  801191:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
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
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  8011c6:	55                   	push   %ebp
  8011c7:	89 e5                	mov    %esp,%ebp
  8011c9:	56                   	push   %esi
  8011ca:	53                   	push   %ebx
  8011cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  8011ce:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  8011d4:	83 ec 08             	sub    $0x8,%esp
  8011d7:	53                   	push   %ebx
  8011d8:	68 dc 2a 80 00       	push   $0x802adc
  8011dd:	e8 58 f1 ff ff       	call   80033a <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8011e2:	c7 04 24 27 02 80 00 	movl   $0x800227,(%esp)
  8011e9:	e8 c5 fc ff ff       	call   800eb3 <sys_thread_create>
  8011ee:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8011f0:	83 c4 08             	add    $0x8,%esp
  8011f3:	53                   	push   %ebx
  8011f4:	68 dc 2a 80 00       	push   $0x802adc
  8011f9:	e8 3c f1 ff ff       	call   80033a <cprintf>
	return id;
}
  8011fe:	89 f0                	mov    %esi,%eax
  801200:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801203:	5b                   	pop    %ebx
  801204:	5e                   	pop    %esi
  801205:	5d                   	pop    %ebp
  801206:	c3                   	ret    

00801207 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  801207:	55                   	push   %ebp
  801208:	89 e5                	mov    %esp,%ebp
  80120a:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  80120d:	ff 75 08             	pushl  0x8(%ebp)
  801210:	e8 be fc ff ff       	call   800ed3 <sys_thread_free>
}
  801215:	83 c4 10             	add    $0x10,%esp
  801218:	c9                   	leave  
  801219:	c3                   	ret    

0080121a <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
  80121d:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  801220:	ff 75 08             	pushl  0x8(%ebp)
  801223:	e8 cb fc ff ff       	call   800ef3 <sys_thread_join>
}
  801228:	83 c4 10             	add    $0x10,%esp
  80122b:	c9                   	leave  
  80122c:	c3                   	ret    

0080122d <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  80122d:	55                   	push   %ebp
  80122e:	89 e5                	mov    %esp,%ebp
  801230:	56                   	push   %esi
  801231:	53                   	push   %ebx
  801232:	8b 75 08             	mov    0x8(%ebp),%esi
  801235:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  801238:	83 ec 04             	sub    $0x4,%esp
  80123b:	6a 07                	push   $0x7
  80123d:	6a 00                	push   $0x0
  80123f:	56                   	push   %esi
  801240:	e8 7d fa ff ff       	call   800cc2 <sys_page_alloc>
	if (r < 0) {
  801245:	83 c4 10             	add    $0x10,%esp
  801248:	85 c0                	test   %eax,%eax
  80124a:	79 15                	jns    801261 <queue_append+0x34>
		panic("%e\n", r);
  80124c:	50                   	push   %eax
  80124d:	68 d8 2a 80 00       	push   $0x802ad8
  801252:	68 c4 00 00 00       	push   $0xc4
  801257:	68 1a 2a 80 00       	push   $0x802a1a
  80125c:	e8 00 f0 ff ff       	call   800261 <_panic>
	}	
	wt->envid = envid;
  801261:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  801267:	83 ec 04             	sub    $0x4,%esp
  80126a:	ff 33                	pushl  (%ebx)
  80126c:	56                   	push   %esi
  80126d:	68 00 2b 80 00       	push   $0x802b00
  801272:	e8 c3 f0 ff ff       	call   80033a <cprintf>
	if (queue->first == NULL) {
  801277:	83 c4 10             	add    $0x10,%esp
  80127a:	83 3b 00             	cmpl   $0x0,(%ebx)
  80127d:	75 29                	jne    8012a8 <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  80127f:	83 ec 0c             	sub    $0xc,%esp
  801282:	68 62 2a 80 00       	push   $0x802a62
  801287:	e8 ae f0 ff ff       	call   80033a <cprintf>
		queue->first = wt;
  80128c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  801292:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  801299:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8012a0:	00 00 00 
  8012a3:	83 c4 10             	add    $0x10,%esp
  8012a6:	eb 2b                	jmp    8012d3 <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  8012a8:	83 ec 0c             	sub    $0xc,%esp
  8012ab:	68 7c 2a 80 00       	push   $0x802a7c
  8012b0:	e8 85 f0 ff ff       	call   80033a <cprintf>
		queue->last->next = wt;
  8012b5:	8b 43 04             	mov    0x4(%ebx),%eax
  8012b8:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  8012bf:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8012c6:	00 00 00 
		queue->last = wt;
  8012c9:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  8012d0:	83 c4 10             	add    $0x10,%esp
	}
}
  8012d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012d6:	5b                   	pop    %ebx
  8012d7:	5e                   	pop    %esi
  8012d8:	5d                   	pop    %ebp
  8012d9:	c3                   	ret    

008012da <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  8012da:	55                   	push   %ebp
  8012db:	89 e5                	mov    %esp,%ebp
  8012dd:	53                   	push   %ebx
  8012de:	83 ec 04             	sub    $0x4,%esp
  8012e1:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  8012e4:	8b 02                	mov    (%edx),%eax
  8012e6:	85 c0                	test   %eax,%eax
  8012e8:	75 17                	jne    801301 <queue_pop+0x27>
		panic("queue empty!\n");
  8012ea:	83 ec 04             	sub    $0x4,%esp
  8012ed:	68 9a 2a 80 00       	push   $0x802a9a
  8012f2:	68 d8 00 00 00       	push   $0xd8
  8012f7:	68 1a 2a 80 00       	push   $0x802a1a
  8012fc:	e8 60 ef ff ff       	call   800261 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  801301:	8b 48 04             	mov    0x4(%eax),%ecx
  801304:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  801306:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  801308:	83 ec 08             	sub    $0x8,%esp
  80130b:	53                   	push   %ebx
  80130c:	68 a8 2a 80 00       	push   $0x802aa8
  801311:	e8 24 f0 ff ff       	call   80033a <cprintf>
	return envid;
}
  801316:	89 d8                	mov    %ebx,%eax
  801318:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80131b:	c9                   	leave  
  80131c:	c3                   	ret    

0080131d <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  80131d:	55                   	push   %ebp
  80131e:	89 e5                	mov    %esp,%ebp
  801320:	53                   	push   %ebx
  801321:	83 ec 04             	sub    $0x4,%esp
  801324:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  801327:	b8 01 00 00 00       	mov    $0x1,%eax
  80132c:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  80132f:	85 c0                	test   %eax,%eax
  801331:	74 5a                	je     80138d <mutex_lock+0x70>
  801333:	8b 43 04             	mov    0x4(%ebx),%eax
  801336:	83 38 00             	cmpl   $0x0,(%eax)
  801339:	75 52                	jne    80138d <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  80133b:	83 ec 0c             	sub    $0xc,%esp
  80133e:	68 28 2b 80 00       	push   $0x802b28
  801343:	e8 f2 ef ff ff       	call   80033a <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  801348:	8b 5b 04             	mov    0x4(%ebx),%ebx
  80134b:	e8 34 f9 ff ff       	call   800c84 <sys_getenvid>
  801350:	83 c4 08             	add    $0x8,%esp
  801353:	53                   	push   %ebx
  801354:	50                   	push   %eax
  801355:	e8 d3 fe ff ff       	call   80122d <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  80135a:	e8 25 f9 ff ff       	call   800c84 <sys_getenvid>
  80135f:	83 c4 08             	add    $0x8,%esp
  801362:	6a 04                	push   $0x4
  801364:	50                   	push   %eax
  801365:	e8 1f fa ff ff       	call   800d89 <sys_env_set_status>
		if (r < 0) {
  80136a:	83 c4 10             	add    $0x10,%esp
  80136d:	85 c0                	test   %eax,%eax
  80136f:	79 15                	jns    801386 <mutex_lock+0x69>
			panic("%e\n", r);
  801371:	50                   	push   %eax
  801372:	68 d8 2a 80 00       	push   $0x802ad8
  801377:	68 eb 00 00 00       	push   $0xeb
  80137c:	68 1a 2a 80 00       	push   $0x802a1a
  801381:	e8 db ee ff ff       	call   800261 <_panic>
		}
		sys_yield();
  801386:	e8 18 f9 ff ff       	call   800ca3 <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  80138b:	eb 18                	jmp    8013a5 <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  80138d:	83 ec 0c             	sub    $0xc,%esp
  801390:	68 48 2b 80 00       	push   $0x802b48
  801395:	e8 a0 ef ff ff       	call   80033a <cprintf>
	mtx->owner = sys_getenvid();}
  80139a:	e8 e5 f8 ff ff       	call   800c84 <sys_getenvid>
  80139f:	89 43 08             	mov    %eax,0x8(%ebx)
  8013a2:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  8013a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a8:	c9                   	leave  
  8013a9:	c3                   	ret    

008013aa <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  8013aa:	55                   	push   %ebp
  8013ab:	89 e5                	mov    %esp,%ebp
  8013ad:	53                   	push   %ebx
  8013ae:	83 ec 04             	sub    $0x4,%esp
  8013b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8013b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b9:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  8013bc:	8b 43 04             	mov    0x4(%ebx),%eax
  8013bf:	83 38 00             	cmpl   $0x0,(%eax)
  8013c2:	74 33                	je     8013f7 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  8013c4:	83 ec 0c             	sub    $0xc,%esp
  8013c7:	50                   	push   %eax
  8013c8:	e8 0d ff ff ff       	call   8012da <queue_pop>
  8013cd:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8013d0:	83 c4 08             	add    $0x8,%esp
  8013d3:	6a 02                	push   $0x2
  8013d5:	50                   	push   %eax
  8013d6:	e8 ae f9 ff ff       	call   800d89 <sys_env_set_status>
		if (r < 0) {
  8013db:	83 c4 10             	add    $0x10,%esp
  8013de:	85 c0                	test   %eax,%eax
  8013e0:	79 15                	jns    8013f7 <mutex_unlock+0x4d>
			panic("%e\n", r);
  8013e2:	50                   	push   %eax
  8013e3:	68 d8 2a 80 00       	push   $0x802ad8
  8013e8:	68 00 01 00 00       	push   $0x100
  8013ed:	68 1a 2a 80 00       	push   $0x802a1a
  8013f2:	e8 6a ee ff ff       	call   800261 <_panic>
		}
	}

	asm volatile("pause");
  8013f7:	f3 90                	pause  
	//sys_yield();
}
  8013f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013fc:	c9                   	leave  
  8013fd:	c3                   	ret    

008013fe <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  8013fe:	55                   	push   %ebp
  8013ff:	89 e5                	mov    %esp,%ebp
  801401:	53                   	push   %ebx
  801402:	83 ec 04             	sub    $0x4,%esp
  801405:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  801408:	e8 77 f8 ff ff       	call   800c84 <sys_getenvid>
  80140d:	83 ec 04             	sub    $0x4,%esp
  801410:	6a 07                	push   $0x7
  801412:	53                   	push   %ebx
  801413:	50                   	push   %eax
  801414:	e8 a9 f8 ff ff       	call   800cc2 <sys_page_alloc>
  801419:	83 c4 10             	add    $0x10,%esp
  80141c:	85 c0                	test   %eax,%eax
  80141e:	79 15                	jns    801435 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  801420:	50                   	push   %eax
  801421:	68 c3 2a 80 00       	push   $0x802ac3
  801426:	68 0d 01 00 00       	push   $0x10d
  80142b:	68 1a 2a 80 00       	push   $0x802a1a
  801430:	e8 2c ee ff ff       	call   800261 <_panic>
	}	
	mtx->locked = 0;
  801435:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  80143b:	8b 43 04             	mov    0x4(%ebx),%eax
  80143e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  801444:	8b 43 04             	mov    0x4(%ebx),%eax
  801447:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  80144e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  801455:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801458:	c9                   	leave  
  801459:	c3                   	ret    

0080145a <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  801460:	e8 1f f8 ff ff       	call   800c84 <sys_getenvid>
  801465:	83 ec 08             	sub    $0x8,%esp
  801468:	ff 75 08             	pushl  0x8(%ebp)
  80146b:	50                   	push   %eax
  80146c:	e8 d6 f8 ff ff       	call   800d47 <sys_page_unmap>
	if (r < 0) {
  801471:	83 c4 10             	add    $0x10,%esp
  801474:	85 c0                	test   %eax,%eax
  801476:	79 15                	jns    80148d <mutex_destroy+0x33>
		panic("%e\n", r);
  801478:	50                   	push   %eax
  801479:	68 d8 2a 80 00       	push   $0x802ad8
  80147e:	68 1a 01 00 00       	push   $0x11a
  801483:	68 1a 2a 80 00       	push   $0x802a1a
  801488:	e8 d4 ed ff ff       	call   800261 <_panic>
	}
}
  80148d:	c9                   	leave  
  80148e:	c3                   	ret    

0080148f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80148f:	55                   	push   %ebp
  801490:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801492:	8b 45 08             	mov    0x8(%ebp),%eax
  801495:	05 00 00 00 30       	add    $0x30000000,%eax
  80149a:	c1 e8 0c             	shr    $0xc,%eax
}
  80149d:	5d                   	pop    %ebp
  80149e:	c3                   	ret    

0080149f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80149f:	55                   	push   %ebp
  8014a0:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8014a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a5:	05 00 00 00 30       	add    $0x30000000,%eax
  8014aa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8014af:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8014b4:	5d                   	pop    %ebp
  8014b5:	c3                   	ret    

008014b6 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014b6:	55                   	push   %ebp
  8014b7:	89 e5                	mov    %esp,%ebp
  8014b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014bc:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014c1:	89 c2                	mov    %eax,%edx
  8014c3:	c1 ea 16             	shr    $0x16,%edx
  8014c6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014cd:	f6 c2 01             	test   $0x1,%dl
  8014d0:	74 11                	je     8014e3 <fd_alloc+0x2d>
  8014d2:	89 c2                	mov    %eax,%edx
  8014d4:	c1 ea 0c             	shr    $0xc,%edx
  8014d7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014de:	f6 c2 01             	test   $0x1,%dl
  8014e1:	75 09                	jne    8014ec <fd_alloc+0x36>
			*fd_store = fd;
  8014e3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ea:	eb 17                	jmp    801503 <fd_alloc+0x4d>
  8014ec:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014f1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014f6:	75 c9                	jne    8014c1 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014f8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8014fe:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801503:	5d                   	pop    %ebp
  801504:	c3                   	ret    

00801505 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801505:	55                   	push   %ebp
  801506:	89 e5                	mov    %esp,%ebp
  801508:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80150b:	83 f8 1f             	cmp    $0x1f,%eax
  80150e:	77 36                	ja     801546 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801510:	c1 e0 0c             	shl    $0xc,%eax
  801513:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801518:	89 c2                	mov    %eax,%edx
  80151a:	c1 ea 16             	shr    $0x16,%edx
  80151d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801524:	f6 c2 01             	test   $0x1,%dl
  801527:	74 24                	je     80154d <fd_lookup+0x48>
  801529:	89 c2                	mov    %eax,%edx
  80152b:	c1 ea 0c             	shr    $0xc,%edx
  80152e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801535:	f6 c2 01             	test   $0x1,%dl
  801538:	74 1a                	je     801554 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80153a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80153d:	89 02                	mov    %eax,(%edx)
	return 0;
  80153f:	b8 00 00 00 00       	mov    $0x0,%eax
  801544:	eb 13                	jmp    801559 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801546:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80154b:	eb 0c                	jmp    801559 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80154d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801552:	eb 05                	jmp    801559 <fd_lookup+0x54>
  801554:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801559:	5d                   	pop    %ebp
  80155a:	c3                   	ret    

0080155b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	83 ec 08             	sub    $0x8,%esp
  801561:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801564:	ba e8 2b 80 00       	mov    $0x802be8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801569:	eb 13                	jmp    80157e <dev_lookup+0x23>
  80156b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80156e:	39 08                	cmp    %ecx,(%eax)
  801570:	75 0c                	jne    80157e <dev_lookup+0x23>
			*dev = devtab[i];
  801572:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801575:	89 01                	mov    %eax,(%ecx)
			return 0;
  801577:	b8 00 00 00 00       	mov    $0x0,%eax
  80157c:	eb 31                	jmp    8015af <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80157e:	8b 02                	mov    (%edx),%eax
  801580:	85 c0                	test   %eax,%eax
  801582:	75 e7                	jne    80156b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801584:	a1 04 40 80 00       	mov    0x804004,%eax
  801589:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80158f:	83 ec 04             	sub    $0x4,%esp
  801592:	51                   	push   %ecx
  801593:	50                   	push   %eax
  801594:	68 68 2b 80 00       	push   $0x802b68
  801599:	e8 9c ed ff ff       	call   80033a <cprintf>
	*dev = 0;
  80159e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015a1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8015a7:	83 c4 10             	add    $0x10,%esp
  8015aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015af:	c9                   	leave  
  8015b0:	c3                   	ret    

008015b1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015b1:	55                   	push   %ebp
  8015b2:	89 e5                	mov    %esp,%ebp
  8015b4:	56                   	push   %esi
  8015b5:	53                   	push   %ebx
  8015b6:	83 ec 10             	sub    $0x10,%esp
  8015b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8015bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c2:	50                   	push   %eax
  8015c3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8015c9:	c1 e8 0c             	shr    $0xc,%eax
  8015cc:	50                   	push   %eax
  8015cd:	e8 33 ff ff ff       	call   801505 <fd_lookup>
  8015d2:	83 c4 08             	add    $0x8,%esp
  8015d5:	85 c0                	test   %eax,%eax
  8015d7:	78 05                	js     8015de <fd_close+0x2d>
	    || fd != fd2)
  8015d9:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015dc:	74 0c                	je     8015ea <fd_close+0x39>
		return (must_exist ? r : 0);
  8015de:	84 db                	test   %bl,%bl
  8015e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e5:	0f 44 c2             	cmove  %edx,%eax
  8015e8:	eb 41                	jmp    80162b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015ea:	83 ec 08             	sub    $0x8,%esp
  8015ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f0:	50                   	push   %eax
  8015f1:	ff 36                	pushl  (%esi)
  8015f3:	e8 63 ff ff ff       	call   80155b <dev_lookup>
  8015f8:	89 c3                	mov    %eax,%ebx
  8015fa:	83 c4 10             	add    $0x10,%esp
  8015fd:	85 c0                	test   %eax,%eax
  8015ff:	78 1a                	js     80161b <fd_close+0x6a>
		if (dev->dev_close)
  801601:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801604:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801607:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80160c:	85 c0                	test   %eax,%eax
  80160e:	74 0b                	je     80161b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801610:	83 ec 0c             	sub    $0xc,%esp
  801613:	56                   	push   %esi
  801614:	ff d0                	call   *%eax
  801616:	89 c3                	mov    %eax,%ebx
  801618:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80161b:	83 ec 08             	sub    $0x8,%esp
  80161e:	56                   	push   %esi
  80161f:	6a 00                	push   $0x0
  801621:	e8 21 f7 ff ff       	call   800d47 <sys_page_unmap>
	return r;
  801626:	83 c4 10             	add    $0x10,%esp
  801629:	89 d8                	mov    %ebx,%eax
}
  80162b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80162e:	5b                   	pop    %ebx
  80162f:	5e                   	pop    %esi
  801630:	5d                   	pop    %ebp
  801631:	c3                   	ret    

00801632 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801632:	55                   	push   %ebp
  801633:	89 e5                	mov    %esp,%ebp
  801635:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801638:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80163b:	50                   	push   %eax
  80163c:	ff 75 08             	pushl  0x8(%ebp)
  80163f:	e8 c1 fe ff ff       	call   801505 <fd_lookup>
  801644:	83 c4 08             	add    $0x8,%esp
  801647:	85 c0                	test   %eax,%eax
  801649:	78 10                	js     80165b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80164b:	83 ec 08             	sub    $0x8,%esp
  80164e:	6a 01                	push   $0x1
  801650:	ff 75 f4             	pushl  -0xc(%ebp)
  801653:	e8 59 ff ff ff       	call   8015b1 <fd_close>
  801658:	83 c4 10             	add    $0x10,%esp
}
  80165b:	c9                   	leave  
  80165c:	c3                   	ret    

0080165d <close_all>:

void
close_all(void)
{
  80165d:	55                   	push   %ebp
  80165e:	89 e5                	mov    %esp,%ebp
  801660:	53                   	push   %ebx
  801661:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801664:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801669:	83 ec 0c             	sub    $0xc,%esp
  80166c:	53                   	push   %ebx
  80166d:	e8 c0 ff ff ff       	call   801632 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801672:	83 c3 01             	add    $0x1,%ebx
  801675:	83 c4 10             	add    $0x10,%esp
  801678:	83 fb 20             	cmp    $0x20,%ebx
  80167b:	75 ec                	jne    801669 <close_all+0xc>
		close(i);
}
  80167d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801680:	c9                   	leave  
  801681:	c3                   	ret    

00801682 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801682:	55                   	push   %ebp
  801683:	89 e5                	mov    %esp,%ebp
  801685:	57                   	push   %edi
  801686:	56                   	push   %esi
  801687:	53                   	push   %ebx
  801688:	83 ec 2c             	sub    $0x2c,%esp
  80168b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80168e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801691:	50                   	push   %eax
  801692:	ff 75 08             	pushl  0x8(%ebp)
  801695:	e8 6b fe ff ff       	call   801505 <fd_lookup>
  80169a:	83 c4 08             	add    $0x8,%esp
  80169d:	85 c0                	test   %eax,%eax
  80169f:	0f 88 c1 00 00 00    	js     801766 <dup+0xe4>
		return r;
	close(newfdnum);
  8016a5:	83 ec 0c             	sub    $0xc,%esp
  8016a8:	56                   	push   %esi
  8016a9:	e8 84 ff ff ff       	call   801632 <close>

	newfd = INDEX2FD(newfdnum);
  8016ae:	89 f3                	mov    %esi,%ebx
  8016b0:	c1 e3 0c             	shl    $0xc,%ebx
  8016b3:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8016b9:	83 c4 04             	add    $0x4,%esp
  8016bc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016bf:	e8 db fd ff ff       	call   80149f <fd2data>
  8016c4:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8016c6:	89 1c 24             	mov    %ebx,(%esp)
  8016c9:	e8 d1 fd ff ff       	call   80149f <fd2data>
  8016ce:	83 c4 10             	add    $0x10,%esp
  8016d1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016d4:	89 f8                	mov    %edi,%eax
  8016d6:	c1 e8 16             	shr    $0x16,%eax
  8016d9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016e0:	a8 01                	test   $0x1,%al
  8016e2:	74 37                	je     80171b <dup+0x99>
  8016e4:	89 f8                	mov    %edi,%eax
  8016e6:	c1 e8 0c             	shr    $0xc,%eax
  8016e9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016f0:	f6 c2 01             	test   $0x1,%dl
  8016f3:	74 26                	je     80171b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016f5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016fc:	83 ec 0c             	sub    $0xc,%esp
  8016ff:	25 07 0e 00 00       	and    $0xe07,%eax
  801704:	50                   	push   %eax
  801705:	ff 75 d4             	pushl  -0x2c(%ebp)
  801708:	6a 00                	push   $0x0
  80170a:	57                   	push   %edi
  80170b:	6a 00                	push   $0x0
  80170d:	e8 f3 f5 ff ff       	call   800d05 <sys_page_map>
  801712:	89 c7                	mov    %eax,%edi
  801714:	83 c4 20             	add    $0x20,%esp
  801717:	85 c0                	test   %eax,%eax
  801719:	78 2e                	js     801749 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80171b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80171e:	89 d0                	mov    %edx,%eax
  801720:	c1 e8 0c             	shr    $0xc,%eax
  801723:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80172a:	83 ec 0c             	sub    $0xc,%esp
  80172d:	25 07 0e 00 00       	and    $0xe07,%eax
  801732:	50                   	push   %eax
  801733:	53                   	push   %ebx
  801734:	6a 00                	push   $0x0
  801736:	52                   	push   %edx
  801737:	6a 00                	push   $0x0
  801739:	e8 c7 f5 ff ff       	call   800d05 <sys_page_map>
  80173e:	89 c7                	mov    %eax,%edi
  801740:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801743:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801745:	85 ff                	test   %edi,%edi
  801747:	79 1d                	jns    801766 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801749:	83 ec 08             	sub    $0x8,%esp
  80174c:	53                   	push   %ebx
  80174d:	6a 00                	push   $0x0
  80174f:	e8 f3 f5 ff ff       	call   800d47 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801754:	83 c4 08             	add    $0x8,%esp
  801757:	ff 75 d4             	pushl  -0x2c(%ebp)
  80175a:	6a 00                	push   $0x0
  80175c:	e8 e6 f5 ff ff       	call   800d47 <sys_page_unmap>
	return r;
  801761:	83 c4 10             	add    $0x10,%esp
  801764:	89 f8                	mov    %edi,%eax
}
  801766:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801769:	5b                   	pop    %ebx
  80176a:	5e                   	pop    %esi
  80176b:	5f                   	pop    %edi
  80176c:	5d                   	pop    %ebp
  80176d:	c3                   	ret    

0080176e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80176e:	55                   	push   %ebp
  80176f:	89 e5                	mov    %esp,%ebp
  801771:	53                   	push   %ebx
  801772:	83 ec 14             	sub    $0x14,%esp
  801775:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801778:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80177b:	50                   	push   %eax
  80177c:	53                   	push   %ebx
  80177d:	e8 83 fd ff ff       	call   801505 <fd_lookup>
  801782:	83 c4 08             	add    $0x8,%esp
  801785:	89 c2                	mov    %eax,%edx
  801787:	85 c0                	test   %eax,%eax
  801789:	78 70                	js     8017fb <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80178b:	83 ec 08             	sub    $0x8,%esp
  80178e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801791:	50                   	push   %eax
  801792:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801795:	ff 30                	pushl  (%eax)
  801797:	e8 bf fd ff ff       	call   80155b <dev_lookup>
  80179c:	83 c4 10             	add    $0x10,%esp
  80179f:	85 c0                	test   %eax,%eax
  8017a1:	78 4f                	js     8017f2 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017a3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017a6:	8b 42 08             	mov    0x8(%edx),%eax
  8017a9:	83 e0 03             	and    $0x3,%eax
  8017ac:	83 f8 01             	cmp    $0x1,%eax
  8017af:	75 24                	jne    8017d5 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017b1:	a1 04 40 80 00       	mov    0x804004,%eax
  8017b6:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8017bc:	83 ec 04             	sub    $0x4,%esp
  8017bf:	53                   	push   %ebx
  8017c0:	50                   	push   %eax
  8017c1:	68 ac 2b 80 00       	push   $0x802bac
  8017c6:	e8 6f eb ff ff       	call   80033a <cprintf>
		return -E_INVAL;
  8017cb:	83 c4 10             	add    $0x10,%esp
  8017ce:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017d3:	eb 26                	jmp    8017fb <read+0x8d>
	}
	if (!dev->dev_read)
  8017d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d8:	8b 40 08             	mov    0x8(%eax),%eax
  8017db:	85 c0                	test   %eax,%eax
  8017dd:	74 17                	je     8017f6 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8017df:	83 ec 04             	sub    $0x4,%esp
  8017e2:	ff 75 10             	pushl  0x10(%ebp)
  8017e5:	ff 75 0c             	pushl  0xc(%ebp)
  8017e8:	52                   	push   %edx
  8017e9:	ff d0                	call   *%eax
  8017eb:	89 c2                	mov    %eax,%edx
  8017ed:	83 c4 10             	add    $0x10,%esp
  8017f0:	eb 09                	jmp    8017fb <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f2:	89 c2                	mov    %eax,%edx
  8017f4:	eb 05                	jmp    8017fb <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8017f6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8017fb:	89 d0                	mov    %edx,%eax
  8017fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801800:	c9                   	leave  
  801801:	c3                   	ret    

00801802 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801802:	55                   	push   %ebp
  801803:	89 e5                	mov    %esp,%ebp
  801805:	57                   	push   %edi
  801806:	56                   	push   %esi
  801807:	53                   	push   %ebx
  801808:	83 ec 0c             	sub    $0xc,%esp
  80180b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80180e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801811:	bb 00 00 00 00       	mov    $0x0,%ebx
  801816:	eb 21                	jmp    801839 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801818:	83 ec 04             	sub    $0x4,%esp
  80181b:	89 f0                	mov    %esi,%eax
  80181d:	29 d8                	sub    %ebx,%eax
  80181f:	50                   	push   %eax
  801820:	89 d8                	mov    %ebx,%eax
  801822:	03 45 0c             	add    0xc(%ebp),%eax
  801825:	50                   	push   %eax
  801826:	57                   	push   %edi
  801827:	e8 42 ff ff ff       	call   80176e <read>
		if (m < 0)
  80182c:	83 c4 10             	add    $0x10,%esp
  80182f:	85 c0                	test   %eax,%eax
  801831:	78 10                	js     801843 <readn+0x41>
			return m;
		if (m == 0)
  801833:	85 c0                	test   %eax,%eax
  801835:	74 0a                	je     801841 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801837:	01 c3                	add    %eax,%ebx
  801839:	39 f3                	cmp    %esi,%ebx
  80183b:	72 db                	jb     801818 <readn+0x16>
  80183d:	89 d8                	mov    %ebx,%eax
  80183f:	eb 02                	jmp    801843 <readn+0x41>
  801841:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801843:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801846:	5b                   	pop    %ebx
  801847:	5e                   	pop    %esi
  801848:	5f                   	pop    %edi
  801849:	5d                   	pop    %ebp
  80184a:	c3                   	ret    

0080184b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80184b:	55                   	push   %ebp
  80184c:	89 e5                	mov    %esp,%ebp
  80184e:	53                   	push   %ebx
  80184f:	83 ec 14             	sub    $0x14,%esp
  801852:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801855:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801858:	50                   	push   %eax
  801859:	53                   	push   %ebx
  80185a:	e8 a6 fc ff ff       	call   801505 <fd_lookup>
  80185f:	83 c4 08             	add    $0x8,%esp
  801862:	89 c2                	mov    %eax,%edx
  801864:	85 c0                	test   %eax,%eax
  801866:	78 6b                	js     8018d3 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801868:	83 ec 08             	sub    $0x8,%esp
  80186b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80186e:	50                   	push   %eax
  80186f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801872:	ff 30                	pushl  (%eax)
  801874:	e8 e2 fc ff ff       	call   80155b <dev_lookup>
  801879:	83 c4 10             	add    $0x10,%esp
  80187c:	85 c0                	test   %eax,%eax
  80187e:	78 4a                	js     8018ca <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801880:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801883:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801887:	75 24                	jne    8018ad <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801889:	a1 04 40 80 00       	mov    0x804004,%eax
  80188e:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801894:	83 ec 04             	sub    $0x4,%esp
  801897:	53                   	push   %ebx
  801898:	50                   	push   %eax
  801899:	68 c8 2b 80 00       	push   $0x802bc8
  80189e:	e8 97 ea ff ff       	call   80033a <cprintf>
		return -E_INVAL;
  8018a3:	83 c4 10             	add    $0x10,%esp
  8018a6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018ab:	eb 26                	jmp    8018d3 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018b0:	8b 52 0c             	mov    0xc(%edx),%edx
  8018b3:	85 d2                	test   %edx,%edx
  8018b5:	74 17                	je     8018ce <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018b7:	83 ec 04             	sub    $0x4,%esp
  8018ba:	ff 75 10             	pushl  0x10(%ebp)
  8018bd:	ff 75 0c             	pushl  0xc(%ebp)
  8018c0:	50                   	push   %eax
  8018c1:	ff d2                	call   *%edx
  8018c3:	89 c2                	mov    %eax,%edx
  8018c5:	83 c4 10             	add    $0x10,%esp
  8018c8:	eb 09                	jmp    8018d3 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018ca:	89 c2                	mov    %eax,%edx
  8018cc:	eb 05                	jmp    8018d3 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8018ce:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8018d3:	89 d0                	mov    %edx,%eax
  8018d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d8:	c9                   	leave  
  8018d9:	c3                   	ret    

008018da <seek>:

int
seek(int fdnum, off_t offset)
{
  8018da:	55                   	push   %ebp
  8018db:	89 e5                	mov    %esp,%ebp
  8018dd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018e0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018e3:	50                   	push   %eax
  8018e4:	ff 75 08             	pushl  0x8(%ebp)
  8018e7:	e8 19 fc ff ff       	call   801505 <fd_lookup>
  8018ec:	83 c4 08             	add    $0x8,%esp
  8018ef:	85 c0                	test   %eax,%eax
  8018f1:	78 0e                	js     801901 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8018f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018f9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801901:	c9                   	leave  
  801902:	c3                   	ret    

00801903 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801903:	55                   	push   %ebp
  801904:	89 e5                	mov    %esp,%ebp
  801906:	53                   	push   %ebx
  801907:	83 ec 14             	sub    $0x14,%esp
  80190a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80190d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801910:	50                   	push   %eax
  801911:	53                   	push   %ebx
  801912:	e8 ee fb ff ff       	call   801505 <fd_lookup>
  801917:	83 c4 08             	add    $0x8,%esp
  80191a:	89 c2                	mov    %eax,%edx
  80191c:	85 c0                	test   %eax,%eax
  80191e:	78 68                	js     801988 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801920:	83 ec 08             	sub    $0x8,%esp
  801923:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801926:	50                   	push   %eax
  801927:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80192a:	ff 30                	pushl  (%eax)
  80192c:	e8 2a fc ff ff       	call   80155b <dev_lookup>
  801931:	83 c4 10             	add    $0x10,%esp
  801934:	85 c0                	test   %eax,%eax
  801936:	78 47                	js     80197f <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801938:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80193b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80193f:	75 24                	jne    801965 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801941:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801946:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80194c:	83 ec 04             	sub    $0x4,%esp
  80194f:	53                   	push   %ebx
  801950:	50                   	push   %eax
  801951:	68 88 2b 80 00       	push   $0x802b88
  801956:	e8 df e9 ff ff       	call   80033a <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80195b:	83 c4 10             	add    $0x10,%esp
  80195e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801963:	eb 23                	jmp    801988 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801965:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801968:	8b 52 18             	mov    0x18(%edx),%edx
  80196b:	85 d2                	test   %edx,%edx
  80196d:	74 14                	je     801983 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80196f:	83 ec 08             	sub    $0x8,%esp
  801972:	ff 75 0c             	pushl  0xc(%ebp)
  801975:	50                   	push   %eax
  801976:	ff d2                	call   *%edx
  801978:	89 c2                	mov    %eax,%edx
  80197a:	83 c4 10             	add    $0x10,%esp
  80197d:	eb 09                	jmp    801988 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80197f:	89 c2                	mov    %eax,%edx
  801981:	eb 05                	jmp    801988 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801983:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801988:	89 d0                	mov    %edx,%eax
  80198a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198d:	c9                   	leave  
  80198e:	c3                   	ret    

0080198f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80198f:	55                   	push   %ebp
  801990:	89 e5                	mov    %esp,%ebp
  801992:	53                   	push   %ebx
  801993:	83 ec 14             	sub    $0x14,%esp
  801996:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801999:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80199c:	50                   	push   %eax
  80199d:	ff 75 08             	pushl  0x8(%ebp)
  8019a0:	e8 60 fb ff ff       	call   801505 <fd_lookup>
  8019a5:	83 c4 08             	add    $0x8,%esp
  8019a8:	89 c2                	mov    %eax,%edx
  8019aa:	85 c0                	test   %eax,%eax
  8019ac:	78 58                	js     801a06 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019ae:	83 ec 08             	sub    $0x8,%esp
  8019b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b4:	50                   	push   %eax
  8019b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019b8:	ff 30                	pushl  (%eax)
  8019ba:	e8 9c fb ff ff       	call   80155b <dev_lookup>
  8019bf:	83 c4 10             	add    $0x10,%esp
  8019c2:	85 c0                	test   %eax,%eax
  8019c4:	78 37                	js     8019fd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8019c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019cd:	74 32                	je     801a01 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019cf:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019d2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019d9:	00 00 00 
	stat->st_isdir = 0;
  8019dc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019e3:	00 00 00 
	stat->st_dev = dev;
  8019e6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019ec:	83 ec 08             	sub    $0x8,%esp
  8019ef:	53                   	push   %ebx
  8019f0:	ff 75 f0             	pushl  -0x10(%ebp)
  8019f3:	ff 50 14             	call   *0x14(%eax)
  8019f6:	89 c2                	mov    %eax,%edx
  8019f8:	83 c4 10             	add    $0x10,%esp
  8019fb:	eb 09                	jmp    801a06 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019fd:	89 c2                	mov    %eax,%edx
  8019ff:	eb 05                	jmp    801a06 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a01:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a06:	89 d0                	mov    %edx,%eax
  801a08:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a0b:	c9                   	leave  
  801a0c:	c3                   	ret    

00801a0d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a0d:	55                   	push   %ebp
  801a0e:	89 e5                	mov    %esp,%ebp
  801a10:	56                   	push   %esi
  801a11:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a12:	83 ec 08             	sub    $0x8,%esp
  801a15:	6a 00                	push   $0x0
  801a17:	ff 75 08             	pushl  0x8(%ebp)
  801a1a:	e8 e3 01 00 00       	call   801c02 <open>
  801a1f:	89 c3                	mov    %eax,%ebx
  801a21:	83 c4 10             	add    $0x10,%esp
  801a24:	85 c0                	test   %eax,%eax
  801a26:	78 1b                	js     801a43 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a28:	83 ec 08             	sub    $0x8,%esp
  801a2b:	ff 75 0c             	pushl  0xc(%ebp)
  801a2e:	50                   	push   %eax
  801a2f:	e8 5b ff ff ff       	call   80198f <fstat>
  801a34:	89 c6                	mov    %eax,%esi
	close(fd);
  801a36:	89 1c 24             	mov    %ebx,(%esp)
  801a39:	e8 f4 fb ff ff       	call   801632 <close>
	return r;
  801a3e:	83 c4 10             	add    $0x10,%esp
  801a41:	89 f0                	mov    %esi,%eax
}
  801a43:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a46:	5b                   	pop    %ebx
  801a47:	5e                   	pop    %esi
  801a48:	5d                   	pop    %ebp
  801a49:	c3                   	ret    

00801a4a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a4a:	55                   	push   %ebp
  801a4b:	89 e5                	mov    %esp,%ebp
  801a4d:	56                   	push   %esi
  801a4e:	53                   	push   %ebx
  801a4f:	89 c6                	mov    %eax,%esi
  801a51:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a53:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a5a:	75 12                	jne    801a6e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a5c:	83 ec 0c             	sub    $0xc,%esp
  801a5f:	6a 01                	push   $0x1
  801a61:	e8 94 08 00 00       	call   8022fa <ipc_find_env>
  801a66:	a3 00 40 80 00       	mov    %eax,0x804000
  801a6b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a6e:	6a 07                	push   $0x7
  801a70:	68 00 50 80 00       	push   $0x805000
  801a75:	56                   	push   %esi
  801a76:	ff 35 00 40 80 00    	pushl  0x804000
  801a7c:	e8 17 08 00 00       	call   802298 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a81:	83 c4 0c             	add    $0xc,%esp
  801a84:	6a 00                	push   $0x0
  801a86:	53                   	push   %ebx
  801a87:	6a 00                	push   $0x0
  801a89:	e8 8f 07 00 00       	call   80221d <ipc_recv>
}
  801a8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a91:	5b                   	pop    %ebx
  801a92:	5e                   	pop    %esi
  801a93:	5d                   	pop    %ebp
  801a94:	c3                   	ret    

00801a95 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a95:	55                   	push   %ebp
  801a96:	89 e5                	mov    %esp,%ebp
  801a98:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9e:	8b 40 0c             	mov    0xc(%eax),%eax
  801aa1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801aa6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801aae:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab3:	b8 02 00 00 00       	mov    $0x2,%eax
  801ab8:	e8 8d ff ff ff       	call   801a4a <fsipc>
}
  801abd:	c9                   	leave  
  801abe:	c3                   	ret    

00801abf <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801abf:	55                   	push   %ebp
  801ac0:	89 e5                	mov    %esp,%ebp
  801ac2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801ac5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac8:	8b 40 0c             	mov    0xc(%eax),%eax
  801acb:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801ad0:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad5:	b8 06 00 00 00       	mov    $0x6,%eax
  801ada:	e8 6b ff ff ff       	call   801a4a <fsipc>
}
  801adf:	c9                   	leave  
  801ae0:	c3                   	ret    

00801ae1 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801ae1:	55                   	push   %ebp
  801ae2:	89 e5                	mov    %esp,%ebp
  801ae4:	53                   	push   %ebx
  801ae5:	83 ec 04             	sub    $0x4,%esp
  801ae8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801aeb:	8b 45 08             	mov    0x8(%ebp),%eax
  801aee:	8b 40 0c             	mov    0xc(%eax),%eax
  801af1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801af6:	ba 00 00 00 00       	mov    $0x0,%edx
  801afb:	b8 05 00 00 00       	mov    $0x5,%eax
  801b00:	e8 45 ff ff ff       	call   801a4a <fsipc>
  801b05:	85 c0                	test   %eax,%eax
  801b07:	78 2c                	js     801b35 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b09:	83 ec 08             	sub    $0x8,%esp
  801b0c:	68 00 50 80 00       	push   $0x805000
  801b11:	53                   	push   %ebx
  801b12:	e8 a8 ed ff ff       	call   8008bf <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b17:	a1 80 50 80 00       	mov    0x805080,%eax
  801b1c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b22:	a1 84 50 80 00       	mov    0x805084,%eax
  801b27:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b2d:	83 c4 10             	add    $0x10,%esp
  801b30:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b38:	c9                   	leave  
  801b39:	c3                   	ret    

00801b3a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b3a:	55                   	push   %ebp
  801b3b:	89 e5                	mov    %esp,%ebp
  801b3d:	83 ec 0c             	sub    $0xc,%esp
  801b40:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b43:	8b 55 08             	mov    0x8(%ebp),%edx
  801b46:	8b 52 0c             	mov    0xc(%edx),%edx
  801b49:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801b4f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b54:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801b59:	0f 47 c2             	cmova  %edx,%eax
  801b5c:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801b61:	50                   	push   %eax
  801b62:	ff 75 0c             	pushl  0xc(%ebp)
  801b65:	68 08 50 80 00       	push   $0x805008
  801b6a:	e8 e2 ee ff ff       	call   800a51 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801b6f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b74:	b8 04 00 00 00       	mov    $0x4,%eax
  801b79:	e8 cc fe ff ff       	call   801a4a <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801b7e:	c9                   	leave  
  801b7f:	c3                   	ret    

00801b80 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	56                   	push   %esi
  801b84:	53                   	push   %ebx
  801b85:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b88:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8b:	8b 40 0c             	mov    0xc(%eax),%eax
  801b8e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b93:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b99:	ba 00 00 00 00       	mov    $0x0,%edx
  801b9e:	b8 03 00 00 00       	mov    $0x3,%eax
  801ba3:	e8 a2 fe ff ff       	call   801a4a <fsipc>
  801ba8:	89 c3                	mov    %eax,%ebx
  801baa:	85 c0                	test   %eax,%eax
  801bac:	78 4b                	js     801bf9 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801bae:	39 c6                	cmp    %eax,%esi
  801bb0:	73 16                	jae    801bc8 <devfile_read+0x48>
  801bb2:	68 f8 2b 80 00       	push   $0x802bf8
  801bb7:	68 ff 2b 80 00       	push   $0x802bff
  801bbc:	6a 7c                	push   $0x7c
  801bbe:	68 14 2c 80 00       	push   $0x802c14
  801bc3:	e8 99 e6 ff ff       	call   800261 <_panic>
	assert(r <= PGSIZE);
  801bc8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bcd:	7e 16                	jle    801be5 <devfile_read+0x65>
  801bcf:	68 1f 2c 80 00       	push   $0x802c1f
  801bd4:	68 ff 2b 80 00       	push   $0x802bff
  801bd9:	6a 7d                	push   $0x7d
  801bdb:	68 14 2c 80 00       	push   $0x802c14
  801be0:	e8 7c e6 ff ff       	call   800261 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801be5:	83 ec 04             	sub    $0x4,%esp
  801be8:	50                   	push   %eax
  801be9:	68 00 50 80 00       	push   $0x805000
  801bee:	ff 75 0c             	pushl  0xc(%ebp)
  801bf1:	e8 5b ee ff ff       	call   800a51 <memmove>
	return r;
  801bf6:	83 c4 10             	add    $0x10,%esp
}
  801bf9:	89 d8                	mov    %ebx,%eax
  801bfb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bfe:	5b                   	pop    %ebx
  801bff:	5e                   	pop    %esi
  801c00:	5d                   	pop    %ebp
  801c01:	c3                   	ret    

00801c02 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c02:	55                   	push   %ebp
  801c03:	89 e5                	mov    %esp,%ebp
  801c05:	53                   	push   %ebx
  801c06:	83 ec 20             	sub    $0x20,%esp
  801c09:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c0c:	53                   	push   %ebx
  801c0d:	e8 74 ec ff ff       	call   800886 <strlen>
  801c12:	83 c4 10             	add    $0x10,%esp
  801c15:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c1a:	7f 67                	jg     801c83 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c1c:	83 ec 0c             	sub    $0xc,%esp
  801c1f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c22:	50                   	push   %eax
  801c23:	e8 8e f8 ff ff       	call   8014b6 <fd_alloc>
  801c28:	83 c4 10             	add    $0x10,%esp
		return r;
  801c2b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c2d:	85 c0                	test   %eax,%eax
  801c2f:	78 57                	js     801c88 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c31:	83 ec 08             	sub    $0x8,%esp
  801c34:	53                   	push   %ebx
  801c35:	68 00 50 80 00       	push   $0x805000
  801c3a:	e8 80 ec ff ff       	call   8008bf <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c42:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c47:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c4a:	b8 01 00 00 00       	mov    $0x1,%eax
  801c4f:	e8 f6 fd ff ff       	call   801a4a <fsipc>
  801c54:	89 c3                	mov    %eax,%ebx
  801c56:	83 c4 10             	add    $0x10,%esp
  801c59:	85 c0                	test   %eax,%eax
  801c5b:	79 14                	jns    801c71 <open+0x6f>
		fd_close(fd, 0);
  801c5d:	83 ec 08             	sub    $0x8,%esp
  801c60:	6a 00                	push   $0x0
  801c62:	ff 75 f4             	pushl  -0xc(%ebp)
  801c65:	e8 47 f9 ff ff       	call   8015b1 <fd_close>
		return r;
  801c6a:	83 c4 10             	add    $0x10,%esp
  801c6d:	89 da                	mov    %ebx,%edx
  801c6f:	eb 17                	jmp    801c88 <open+0x86>
	}

	return fd2num(fd);
  801c71:	83 ec 0c             	sub    $0xc,%esp
  801c74:	ff 75 f4             	pushl  -0xc(%ebp)
  801c77:	e8 13 f8 ff ff       	call   80148f <fd2num>
  801c7c:	89 c2                	mov    %eax,%edx
  801c7e:	83 c4 10             	add    $0x10,%esp
  801c81:	eb 05                	jmp    801c88 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c83:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c88:	89 d0                	mov    %edx,%eax
  801c8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c8d:	c9                   	leave  
  801c8e:	c3                   	ret    

00801c8f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c8f:	55                   	push   %ebp
  801c90:	89 e5                	mov    %esp,%ebp
  801c92:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c95:	ba 00 00 00 00       	mov    $0x0,%edx
  801c9a:	b8 08 00 00 00       	mov    $0x8,%eax
  801c9f:	e8 a6 fd ff ff       	call   801a4a <fsipc>
}
  801ca4:	c9                   	leave  
  801ca5:	c3                   	ret    

00801ca6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ca6:	55                   	push   %ebp
  801ca7:	89 e5                	mov    %esp,%ebp
  801ca9:	56                   	push   %esi
  801caa:	53                   	push   %ebx
  801cab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801cae:	83 ec 0c             	sub    $0xc,%esp
  801cb1:	ff 75 08             	pushl  0x8(%ebp)
  801cb4:	e8 e6 f7 ff ff       	call   80149f <fd2data>
  801cb9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801cbb:	83 c4 08             	add    $0x8,%esp
  801cbe:	68 2b 2c 80 00       	push   $0x802c2b
  801cc3:	53                   	push   %ebx
  801cc4:	e8 f6 eb ff ff       	call   8008bf <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801cc9:	8b 46 04             	mov    0x4(%esi),%eax
  801ccc:	2b 06                	sub    (%esi),%eax
  801cce:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801cd4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801cdb:	00 00 00 
	stat->st_dev = &devpipe;
  801cde:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801ce5:	30 80 00 
	return 0;
}
  801ce8:	b8 00 00 00 00       	mov    $0x0,%eax
  801ced:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cf0:	5b                   	pop    %ebx
  801cf1:	5e                   	pop    %esi
  801cf2:	5d                   	pop    %ebp
  801cf3:	c3                   	ret    

00801cf4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cf4:	55                   	push   %ebp
  801cf5:	89 e5                	mov    %esp,%ebp
  801cf7:	53                   	push   %ebx
  801cf8:	83 ec 0c             	sub    $0xc,%esp
  801cfb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cfe:	53                   	push   %ebx
  801cff:	6a 00                	push   $0x0
  801d01:	e8 41 f0 ff ff       	call   800d47 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d06:	89 1c 24             	mov    %ebx,(%esp)
  801d09:	e8 91 f7 ff ff       	call   80149f <fd2data>
  801d0e:	83 c4 08             	add    $0x8,%esp
  801d11:	50                   	push   %eax
  801d12:	6a 00                	push   $0x0
  801d14:	e8 2e f0 ff ff       	call   800d47 <sys_page_unmap>
}
  801d19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d1c:	c9                   	leave  
  801d1d:	c3                   	ret    

00801d1e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d1e:	55                   	push   %ebp
  801d1f:	89 e5                	mov    %esp,%ebp
  801d21:	57                   	push   %edi
  801d22:	56                   	push   %esi
  801d23:	53                   	push   %ebx
  801d24:	83 ec 1c             	sub    $0x1c,%esp
  801d27:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d2a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d2c:	a1 04 40 80 00       	mov    0x804004,%eax
  801d31:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801d37:	83 ec 0c             	sub    $0xc,%esp
  801d3a:	ff 75 e0             	pushl  -0x20(%ebp)
  801d3d:	e8 fd 05 00 00       	call   80233f <pageref>
  801d42:	89 c3                	mov    %eax,%ebx
  801d44:	89 3c 24             	mov    %edi,(%esp)
  801d47:	e8 f3 05 00 00       	call   80233f <pageref>
  801d4c:	83 c4 10             	add    $0x10,%esp
  801d4f:	39 c3                	cmp    %eax,%ebx
  801d51:	0f 94 c1             	sete   %cl
  801d54:	0f b6 c9             	movzbl %cl,%ecx
  801d57:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d5a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d60:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801d66:	39 ce                	cmp    %ecx,%esi
  801d68:	74 1e                	je     801d88 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801d6a:	39 c3                	cmp    %eax,%ebx
  801d6c:	75 be                	jne    801d2c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d6e:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801d74:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d77:	50                   	push   %eax
  801d78:	56                   	push   %esi
  801d79:	68 32 2c 80 00       	push   $0x802c32
  801d7e:	e8 b7 e5 ff ff       	call   80033a <cprintf>
  801d83:	83 c4 10             	add    $0x10,%esp
  801d86:	eb a4                	jmp    801d2c <_pipeisclosed+0xe>
	}
}
  801d88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d8e:	5b                   	pop    %ebx
  801d8f:	5e                   	pop    %esi
  801d90:	5f                   	pop    %edi
  801d91:	5d                   	pop    %ebp
  801d92:	c3                   	ret    

00801d93 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d93:	55                   	push   %ebp
  801d94:	89 e5                	mov    %esp,%ebp
  801d96:	57                   	push   %edi
  801d97:	56                   	push   %esi
  801d98:	53                   	push   %ebx
  801d99:	83 ec 28             	sub    $0x28,%esp
  801d9c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d9f:	56                   	push   %esi
  801da0:	e8 fa f6 ff ff       	call   80149f <fd2data>
  801da5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801da7:	83 c4 10             	add    $0x10,%esp
  801daa:	bf 00 00 00 00       	mov    $0x0,%edi
  801daf:	eb 4b                	jmp    801dfc <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801db1:	89 da                	mov    %ebx,%edx
  801db3:	89 f0                	mov    %esi,%eax
  801db5:	e8 64 ff ff ff       	call   801d1e <_pipeisclosed>
  801dba:	85 c0                	test   %eax,%eax
  801dbc:	75 48                	jne    801e06 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801dbe:	e8 e0 ee ff ff       	call   800ca3 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801dc3:	8b 43 04             	mov    0x4(%ebx),%eax
  801dc6:	8b 0b                	mov    (%ebx),%ecx
  801dc8:	8d 51 20             	lea    0x20(%ecx),%edx
  801dcb:	39 d0                	cmp    %edx,%eax
  801dcd:	73 e2                	jae    801db1 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801dcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dd2:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801dd6:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801dd9:	89 c2                	mov    %eax,%edx
  801ddb:	c1 fa 1f             	sar    $0x1f,%edx
  801dde:	89 d1                	mov    %edx,%ecx
  801de0:	c1 e9 1b             	shr    $0x1b,%ecx
  801de3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801de6:	83 e2 1f             	and    $0x1f,%edx
  801de9:	29 ca                	sub    %ecx,%edx
  801deb:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801def:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801df3:	83 c0 01             	add    $0x1,%eax
  801df6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801df9:	83 c7 01             	add    $0x1,%edi
  801dfc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801dff:	75 c2                	jne    801dc3 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e01:	8b 45 10             	mov    0x10(%ebp),%eax
  801e04:	eb 05                	jmp    801e0b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e06:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e0e:	5b                   	pop    %ebx
  801e0f:	5e                   	pop    %esi
  801e10:	5f                   	pop    %edi
  801e11:	5d                   	pop    %ebp
  801e12:	c3                   	ret    

00801e13 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e13:	55                   	push   %ebp
  801e14:	89 e5                	mov    %esp,%ebp
  801e16:	57                   	push   %edi
  801e17:	56                   	push   %esi
  801e18:	53                   	push   %ebx
  801e19:	83 ec 18             	sub    $0x18,%esp
  801e1c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e1f:	57                   	push   %edi
  801e20:	e8 7a f6 ff ff       	call   80149f <fd2data>
  801e25:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e27:	83 c4 10             	add    $0x10,%esp
  801e2a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e2f:	eb 3d                	jmp    801e6e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e31:	85 db                	test   %ebx,%ebx
  801e33:	74 04                	je     801e39 <devpipe_read+0x26>
				return i;
  801e35:	89 d8                	mov    %ebx,%eax
  801e37:	eb 44                	jmp    801e7d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e39:	89 f2                	mov    %esi,%edx
  801e3b:	89 f8                	mov    %edi,%eax
  801e3d:	e8 dc fe ff ff       	call   801d1e <_pipeisclosed>
  801e42:	85 c0                	test   %eax,%eax
  801e44:	75 32                	jne    801e78 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e46:	e8 58 ee ff ff       	call   800ca3 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e4b:	8b 06                	mov    (%esi),%eax
  801e4d:	3b 46 04             	cmp    0x4(%esi),%eax
  801e50:	74 df                	je     801e31 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e52:	99                   	cltd   
  801e53:	c1 ea 1b             	shr    $0x1b,%edx
  801e56:	01 d0                	add    %edx,%eax
  801e58:	83 e0 1f             	and    $0x1f,%eax
  801e5b:	29 d0                	sub    %edx,%eax
  801e5d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e65:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e68:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e6b:	83 c3 01             	add    $0x1,%ebx
  801e6e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e71:	75 d8                	jne    801e4b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e73:	8b 45 10             	mov    0x10(%ebp),%eax
  801e76:	eb 05                	jmp    801e7d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e78:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e80:	5b                   	pop    %ebx
  801e81:	5e                   	pop    %esi
  801e82:	5f                   	pop    %edi
  801e83:	5d                   	pop    %ebp
  801e84:	c3                   	ret    

00801e85 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e85:	55                   	push   %ebp
  801e86:	89 e5                	mov    %esp,%ebp
  801e88:	56                   	push   %esi
  801e89:	53                   	push   %ebx
  801e8a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e8d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e90:	50                   	push   %eax
  801e91:	e8 20 f6 ff ff       	call   8014b6 <fd_alloc>
  801e96:	83 c4 10             	add    $0x10,%esp
  801e99:	89 c2                	mov    %eax,%edx
  801e9b:	85 c0                	test   %eax,%eax
  801e9d:	0f 88 2c 01 00 00    	js     801fcf <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ea3:	83 ec 04             	sub    $0x4,%esp
  801ea6:	68 07 04 00 00       	push   $0x407
  801eab:	ff 75 f4             	pushl  -0xc(%ebp)
  801eae:	6a 00                	push   $0x0
  801eb0:	e8 0d ee ff ff       	call   800cc2 <sys_page_alloc>
  801eb5:	83 c4 10             	add    $0x10,%esp
  801eb8:	89 c2                	mov    %eax,%edx
  801eba:	85 c0                	test   %eax,%eax
  801ebc:	0f 88 0d 01 00 00    	js     801fcf <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ec2:	83 ec 0c             	sub    $0xc,%esp
  801ec5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ec8:	50                   	push   %eax
  801ec9:	e8 e8 f5 ff ff       	call   8014b6 <fd_alloc>
  801ece:	89 c3                	mov    %eax,%ebx
  801ed0:	83 c4 10             	add    $0x10,%esp
  801ed3:	85 c0                	test   %eax,%eax
  801ed5:	0f 88 e2 00 00 00    	js     801fbd <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801edb:	83 ec 04             	sub    $0x4,%esp
  801ede:	68 07 04 00 00       	push   $0x407
  801ee3:	ff 75 f0             	pushl  -0x10(%ebp)
  801ee6:	6a 00                	push   $0x0
  801ee8:	e8 d5 ed ff ff       	call   800cc2 <sys_page_alloc>
  801eed:	89 c3                	mov    %eax,%ebx
  801eef:	83 c4 10             	add    $0x10,%esp
  801ef2:	85 c0                	test   %eax,%eax
  801ef4:	0f 88 c3 00 00 00    	js     801fbd <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801efa:	83 ec 0c             	sub    $0xc,%esp
  801efd:	ff 75 f4             	pushl  -0xc(%ebp)
  801f00:	e8 9a f5 ff ff       	call   80149f <fd2data>
  801f05:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f07:	83 c4 0c             	add    $0xc,%esp
  801f0a:	68 07 04 00 00       	push   $0x407
  801f0f:	50                   	push   %eax
  801f10:	6a 00                	push   $0x0
  801f12:	e8 ab ed ff ff       	call   800cc2 <sys_page_alloc>
  801f17:	89 c3                	mov    %eax,%ebx
  801f19:	83 c4 10             	add    $0x10,%esp
  801f1c:	85 c0                	test   %eax,%eax
  801f1e:	0f 88 89 00 00 00    	js     801fad <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f24:	83 ec 0c             	sub    $0xc,%esp
  801f27:	ff 75 f0             	pushl  -0x10(%ebp)
  801f2a:	e8 70 f5 ff ff       	call   80149f <fd2data>
  801f2f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f36:	50                   	push   %eax
  801f37:	6a 00                	push   $0x0
  801f39:	56                   	push   %esi
  801f3a:	6a 00                	push   $0x0
  801f3c:	e8 c4 ed ff ff       	call   800d05 <sys_page_map>
  801f41:	89 c3                	mov    %eax,%ebx
  801f43:	83 c4 20             	add    $0x20,%esp
  801f46:	85 c0                	test   %eax,%eax
  801f48:	78 55                	js     801f9f <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f4a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f53:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f58:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f5f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f65:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f68:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f6d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f74:	83 ec 0c             	sub    $0xc,%esp
  801f77:	ff 75 f4             	pushl  -0xc(%ebp)
  801f7a:	e8 10 f5 ff ff       	call   80148f <fd2num>
  801f7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f82:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f84:	83 c4 04             	add    $0x4,%esp
  801f87:	ff 75 f0             	pushl  -0x10(%ebp)
  801f8a:	e8 00 f5 ff ff       	call   80148f <fd2num>
  801f8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f92:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801f95:	83 c4 10             	add    $0x10,%esp
  801f98:	ba 00 00 00 00       	mov    $0x0,%edx
  801f9d:	eb 30                	jmp    801fcf <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f9f:	83 ec 08             	sub    $0x8,%esp
  801fa2:	56                   	push   %esi
  801fa3:	6a 00                	push   $0x0
  801fa5:	e8 9d ed ff ff       	call   800d47 <sys_page_unmap>
  801faa:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801fad:	83 ec 08             	sub    $0x8,%esp
  801fb0:	ff 75 f0             	pushl  -0x10(%ebp)
  801fb3:	6a 00                	push   $0x0
  801fb5:	e8 8d ed ff ff       	call   800d47 <sys_page_unmap>
  801fba:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801fbd:	83 ec 08             	sub    $0x8,%esp
  801fc0:	ff 75 f4             	pushl  -0xc(%ebp)
  801fc3:	6a 00                	push   $0x0
  801fc5:	e8 7d ed ff ff       	call   800d47 <sys_page_unmap>
  801fca:	83 c4 10             	add    $0x10,%esp
  801fcd:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801fcf:	89 d0                	mov    %edx,%eax
  801fd1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fd4:	5b                   	pop    %ebx
  801fd5:	5e                   	pop    %esi
  801fd6:	5d                   	pop    %ebp
  801fd7:	c3                   	ret    

00801fd8 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801fd8:	55                   	push   %ebp
  801fd9:	89 e5                	mov    %esp,%ebp
  801fdb:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fde:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fe1:	50                   	push   %eax
  801fe2:	ff 75 08             	pushl  0x8(%ebp)
  801fe5:	e8 1b f5 ff ff       	call   801505 <fd_lookup>
  801fea:	83 c4 10             	add    $0x10,%esp
  801fed:	85 c0                	test   %eax,%eax
  801fef:	78 18                	js     802009 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ff1:	83 ec 0c             	sub    $0xc,%esp
  801ff4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ff7:	e8 a3 f4 ff ff       	call   80149f <fd2data>
	return _pipeisclosed(fd, p);
  801ffc:	89 c2                	mov    %eax,%edx
  801ffe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802001:	e8 18 fd ff ff       	call   801d1e <_pipeisclosed>
  802006:	83 c4 10             	add    $0x10,%esp
}
  802009:	c9                   	leave  
  80200a:	c3                   	ret    

0080200b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80200b:	55                   	push   %ebp
  80200c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80200e:	b8 00 00 00 00       	mov    $0x0,%eax
  802013:	5d                   	pop    %ebp
  802014:	c3                   	ret    

00802015 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802015:	55                   	push   %ebp
  802016:	89 e5                	mov    %esp,%ebp
  802018:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80201b:	68 4a 2c 80 00       	push   $0x802c4a
  802020:	ff 75 0c             	pushl  0xc(%ebp)
  802023:	e8 97 e8 ff ff       	call   8008bf <strcpy>
	return 0;
}
  802028:	b8 00 00 00 00       	mov    $0x0,%eax
  80202d:	c9                   	leave  
  80202e:	c3                   	ret    

0080202f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80202f:	55                   	push   %ebp
  802030:	89 e5                	mov    %esp,%ebp
  802032:	57                   	push   %edi
  802033:	56                   	push   %esi
  802034:	53                   	push   %ebx
  802035:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80203b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802040:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802046:	eb 2d                	jmp    802075 <devcons_write+0x46>
		m = n - tot;
  802048:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80204b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80204d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802050:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802055:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802058:	83 ec 04             	sub    $0x4,%esp
  80205b:	53                   	push   %ebx
  80205c:	03 45 0c             	add    0xc(%ebp),%eax
  80205f:	50                   	push   %eax
  802060:	57                   	push   %edi
  802061:	e8 eb e9 ff ff       	call   800a51 <memmove>
		sys_cputs(buf, m);
  802066:	83 c4 08             	add    $0x8,%esp
  802069:	53                   	push   %ebx
  80206a:	57                   	push   %edi
  80206b:	e8 96 eb ff ff       	call   800c06 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802070:	01 de                	add    %ebx,%esi
  802072:	83 c4 10             	add    $0x10,%esp
  802075:	89 f0                	mov    %esi,%eax
  802077:	3b 75 10             	cmp    0x10(%ebp),%esi
  80207a:	72 cc                	jb     802048 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80207c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80207f:	5b                   	pop    %ebx
  802080:	5e                   	pop    %esi
  802081:	5f                   	pop    %edi
  802082:	5d                   	pop    %ebp
  802083:	c3                   	ret    

00802084 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802084:	55                   	push   %ebp
  802085:	89 e5                	mov    %esp,%ebp
  802087:	83 ec 08             	sub    $0x8,%esp
  80208a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80208f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802093:	74 2a                	je     8020bf <devcons_read+0x3b>
  802095:	eb 05                	jmp    80209c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802097:	e8 07 ec ff ff       	call   800ca3 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80209c:	e8 83 eb ff ff       	call   800c24 <sys_cgetc>
  8020a1:	85 c0                	test   %eax,%eax
  8020a3:	74 f2                	je     802097 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8020a5:	85 c0                	test   %eax,%eax
  8020a7:	78 16                	js     8020bf <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8020a9:	83 f8 04             	cmp    $0x4,%eax
  8020ac:	74 0c                	je     8020ba <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8020ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020b1:	88 02                	mov    %al,(%edx)
	return 1;
  8020b3:	b8 01 00 00 00       	mov    $0x1,%eax
  8020b8:	eb 05                	jmp    8020bf <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020ba:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8020bf:	c9                   	leave  
  8020c0:	c3                   	ret    

008020c1 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8020c1:	55                   	push   %ebp
  8020c2:	89 e5                	mov    %esp,%ebp
  8020c4:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8020c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ca:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8020cd:	6a 01                	push   $0x1
  8020cf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020d2:	50                   	push   %eax
  8020d3:	e8 2e eb ff ff       	call   800c06 <sys_cputs>
}
  8020d8:	83 c4 10             	add    $0x10,%esp
  8020db:	c9                   	leave  
  8020dc:	c3                   	ret    

008020dd <getchar>:

int
getchar(void)
{
  8020dd:	55                   	push   %ebp
  8020de:	89 e5                	mov    %esp,%ebp
  8020e0:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020e3:	6a 01                	push   $0x1
  8020e5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020e8:	50                   	push   %eax
  8020e9:	6a 00                	push   $0x0
  8020eb:	e8 7e f6 ff ff       	call   80176e <read>
	if (r < 0)
  8020f0:	83 c4 10             	add    $0x10,%esp
  8020f3:	85 c0                	test   %eax,%eax
  8020f5:	78 0f                	js     802106 <getchar+0x29>
		return r;
	if (r < 1)
  8020f7:	85 c0                	test   %eax,%eax
  8020f9:	7e 06                	jle    802101 <getchar+0x24>
		return -E_EOF;
	return c;
  8020fb:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020ff:	eb 05                	jmp    802106 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802101:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802106:	c9                   	leave  
  802107:	c3                   	ret    

00802108 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802108:	55                   	push   %ebp
  802109:	89 e5                	mov    %esp,%ebp
  80210b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80210e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802111:	50                   	push   %eax
  802112:	ff 75 08             	pushl  0x8(%ebp)
  802115:	e8 eb f3 ff ff       	call   801505 <fd_lookup>
  80211a:	83 c4 10             	add    $0x10,%esp
  80211d:	85 c0                	test   %eax,%eax
  80211f:	78 11                	js     802132 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802121:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802124:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80212a:	39 10                	cmp    %edx,(%eax)
  80212c:	0f 94 c0             	sete   %al
  80212f:	0f b6 c0             	movzbl %al,%eax
}
  802132:	c9                   	leave  
  802133:	c3                   	ret    

00802134 <opencons>:

int
opencons(void)
{
  802134:	55                   	push   %ebp
  802135:	89 e5                	mov    %esp,%ebp
  802137:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80213a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80213d:	50                   	push   %eax
  80213e:	e8 73 f3 ff ff       	call   8014b6 <fd_alloc>
  802143:	83 c4 10             	add    $0x10,%esp
		return r;
  802146:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802148:	85 c0                	test   %eax,%eax
  80214a:	78 3e                	js     80218a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80214c:	83 ec 04             	sub    $0x4,%esp
  80214f:	68 07 04 00 00       	push   $0x407
  802154:	ff 75 f4             	pushl  -0xc(%ebp)
  802157:	6a 00                	push   $0x0
  802159:	e8 64 eb ff ff       	call   800cc2 <sys_page_alloc>
  80215e:	83 c4 10             	add    $0x10,%esp
		return r;
  802161:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802163:	85 c0                	test   %eax,%eax
  802165:	78 23                	js     80218a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802167:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80216d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802170:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802172:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802175:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80217c:	83 ec 0c             	sub    $0xc,%esp
  80217f:	50                   	push   %eax
  802180:	e8 0a f3 ff ff       	call   80148f <fd2num>
  802185:	89 c2                	mov    %eax,%edx
  802187:	83 c4 10             	add    $0x10,%esp
}
  80218a:	89 d0                	mov    %edx,%eax
  80218c:	c9                   	leave  
  80218d:	c3                   	ret    

0080218e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80218e:	55                   	push   %ebp
  80218f:	89 e5                	mov    %esp,%ebp
  802191:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802194:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80219b:	75 2a                	jne    8021c7 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  80219d:	83 ec 04             	sub    $0x4,%esp
  8021a0:	6a 07                	push   $0x7
  8021a2:	68 00 f0 bf ee       	push   $0xeebff000
  8021a7:	6a 00                	push   $0x0
  8021a9:	e8 14 eb ff ff       	call   800cc2 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  8021ae:	83 c4 10             	add    $0x10,%esp
  8021b1:	85 c0                	test   %eax,%eax
  8021b3:	79 12                	jns    8021c7 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  8021b5:	50                   	push   %eax
  8021b6:	68 d8 2a 80 00       	push   $0x802ad8
  8021bb:	6a 23                	push   $0x23
  8021bd:	68 56 2c 80 00       	push   $0x802c56
  8021c2:	e8 9a e0 ff ff       	call   800261 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8021c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ca:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8021cf:	83 ec 08             	sub    $0x8,%esp
  8021d2:	68 f9 21 80 00       	push   $0x8021f9
  8021d7:	6a 00                	push   $0x0
  8021d9:	e8 2f ec ff ff       	call   800e0d <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8021de:	83 c4 10             	add    $0x10,%esp
  8021e1:	85 c0                	test   %eax,%eax
  8021e3:	79 12                	jns    8021f7 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8021e5:	50                   	push   %eax
  8021e6:	68 d8 2a 80 00       	push   $0x802ad8
  8021eb:	6a 2c                	push   $0x2c
  8021ed:	68 56 2c 80 00       	push   $0x802c56
  8021f2:	e8 6a e0 ff ff       	call   800261 <_panic>
	}
}
  8021f7:	c9                   	leave  
  8021f8:	c3                   	ret    

008021f9 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8021f9:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8021fa:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8021ff:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802201:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802204:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802208:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  80220d:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802211:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802213:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802216:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802217:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80221a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  80221b:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80221c:	c3                   	ret    

0080221d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80221d:	55                   	push   %ebp
  80221e:	89 e5                	mov    %esp,%ebp
  802220:	56                   	push   %esi
  802221:	53                   	push   %ebx
  802222:	8b 75 08             	mov    0x8(%ebp),%esi
  802225:	8b 45 0c             	mov    0xc(%ebp),%eax
  802228:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80222b:	85 c0                	test   %eax,%eax
  80222d:	75 12                	jne    802241 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80222f:	83 ec 0c             	sub    $0xc,%esp
  802232:	68 00 00 c0 ee       	push   $0xeec00000
  802237:	e8 36 ec ff ff       	call   800e72 <sys_ipc_recv>
  80223c:	83 c4 10             	add    $0x10,%esp
  80223f:	eb 0c                	jmp    80224d <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802241:	83 ec 0c             	sub    $0xc,%esp
  802244:	50                   	push   %eax
  802245:	e8 28 ec ff ff       	call   800e72 <sys_ipc_recv>
  80224a:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80224d:	85 f6                	test   %esi,%esi
  80224f:	0f 95 c1             	setne  %cl
  802252:	85 db                	test   %ebx,%ebx
  802254:	0f 95 c2             	setne  %dl
  802257:	84 d1                	test   %dl,%cl
  802259:	74 09                	je     802264 <ipc_recv+0x47>
  80225b:	89 c2                	mov    %eax,%edx
  80225d:	c1 ea 1f             	shr    $0x1f,%edx
  802260:	84 d2                	test   %dl,%dl
  802262:	75 2d                	jne    802291 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802264:	85 f6                	test   %esi,%esi
  802266:	74 0d                	je     802275 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802268:	a1 04 40 80 00       	mov    0x804004,%eax
  80226d:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802273:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802275:	85 db                	test   %ebx,%ebx
  802277:	74 0d                	je     802286 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802279:	a1 04 40 80 00       	mov    0x804004,%eax
  80227e:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  802284:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802286:	a1 04 40 80 00       	mov    0x804004,%eax
  80228b:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  802291:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802294:	5b                   	pop    %ebx
  802295:	5e                   	pop    %esi
  802296:	5d                   	pop    %ebp
  802297:	c3                   	ret    

00802298 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802298:	55                   	push   %ebp
  802299:	89 e5                	mov    %esp,%ebp
  80229b:	57                   	push   %edi
  80229c:	56                   	push   %esi
  80229d:	53                   	push   %ebx
  80229e:	83 ec 0c             	sub    $0xc,%esp
  8022a1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022a4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8022a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8022aa:	85 db                	test   %ebx,%ebx
  8022ac:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8022b1:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8022b4:	ff 75 14             	pushl  0x14(%ebp)
  8022b7:	53                   	push   %ebx
  8022b8:	56                   	push   %esi
  8022b9:	57                   	push   %edi
  8022ba:	e8 90 eb ff ff       	call   800e4f <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8022bf:	89 c2                	mov    %eax,%edx
  8022c1:	c1 ea 1f             	shr    $0x1f,%edx
  8022c4:	83 c4 10             	add    $0x10,%esp
  8022c7:	84 d2                	test   %dl,%dl
  8022c9:	74 17                	je     8022e2 <ipc_send+0x4a>
  8022cb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022ce:	74 12                	je     8022e2 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8022d0:	50                   	push   %eax
  8022d1:	68 64 2c 80 00       	push   $0x802c64
  8022d6:	6a 47                	push   $0x47
  8022d8:	68 72 2c 80 00       	push   $0x802c72
  8022dd:	e8 7f df ff ff       	call   800261 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8022e2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022e5:	75 07                	jne    8022ee <ipc_send+0x56>
			sys_yield();
  8022e7:	e8 b7 e9 ff ff       	call   800ca3 <sys_yield>
  8022ec:	eb c6                	jmp    8022b4 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8022ee:	85 c0                	test   %eax,%eax
  8022f0:	75 c2                	jne    8022b4 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8022f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022f5:	5b                   	pop    %ebx
  8022f6:	5e                   	pop    %esi
  8022f7:	5f                   	pop    %edi
  8022f8:	5d                   	pop    %ebp
  8022f9:	c3                   	ret    

008022fa <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8022fa:	55                   	push   %ebp
  8022fb:	89 e5                	mov    %esp,%ebp
  8022fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802300:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802305:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  80230b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802311:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  802317:	39 ca                	cmp    %ecx,%edx
  802319:	75 13                	jne    80232e <ipc_find_env+0x34>
			return envs[i].env_id;
  80231b:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  802321:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802326:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80232c:	eb 0f                	jmp    80233d <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80232e:	83 c0 01             	add    $0x1,%eax
  802331:	3d 00 04 00 00       	cmp    $0x400,%eax
  802336:	75 cd                	jne    802305 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802338:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80233d:	5d                   	pop    %ebp
  80233e:	c3                   	ret    

0080233f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80233f:	55                   	push   %ebp
  802340:	89 e5                	mov    %esp,%ebp
  802342:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802345:	89 d0                	mov    %edx,%eax
  802347:	c1 e8 16             	shr    $0x16,%eax
  80234a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802351:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802356:	f6 c1 01             	test   $0x1,%cl
  802359:	74 1d                	je     802378 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80235b:	c1 ea 0c             	shr    $0xc,%edx
  80235e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802365:	f6 c2 01             	test   $0x1,%dl
  802368:	74 0e                	je     802378 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80236a:	c1 ea 0c             	shr    $0xc,%edx
  80236d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802374:	ef 
  802375:	0f b7 c0             	movzwl %ax,%eax
}
  802378:	5d                   	pop    %ebp
  802379:	c3                   	ret    
  80237a:	66 90                	xchg   %ax,%ax
  80237c:	66 90                	xchg   %ax,%ax
  80237e:	66 90                	xchg   %ax,%ax

00802380 <__udivdi3>:
  802380:	55                   	push   %ebp
  802381:	57                   	push   %edi
  802382:	56                   	push   %esi
  802383:	53                   	push   %ebx
  802384:	83 ec 1c             	sub    $0x1c,%esp
  802387:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80238b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80238f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802393:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802397:	85 f6                	test   %esi,%esi
  802399:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80239d:	89 ca                	mov    %ecx,%edx
  80239f:	89 f8                	mov    %edi,%eax
  8023a1:	75 3d                	jne    8023e0 <__udivdi3+0x60>
  8023a3:	39 cf                	cmp    %ecx,%edi
  8023a5:	0f 87 c5 00 00 00    	ja     802470 <__udivdi3+0xf0>
  8023ab:	85 ff                	test   %edi,%edi
  8023ad:	89 fd                	mov    %edi,%ebp
  8023af:	75 0b                	jne    8023bc <__udivdi3+0x3c>
  8023b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8023b6:	31 d2                	xor    %edx,%edx
  8023b8:	f7 f7                	div    %edi
  8023ba:	89 c5                	mov    %eax,%ebp
  8023bc:	89 c8                	mov    %ecx,%eax
  8023be:	31 d2                	xor    %edx,%edx
  8023c0:	f7 f5                	div    %ebp
  8023c2:	89 c1                	mov    %eax,%ecx
  8023c4:	89 d8                	mov    %ebx,%eax
  8023c6:	89 cf                	mov    %ecx,%edi
  8023c8:	f7 f5                	div    %ebp
  8023ca:	89 c3                	mov    %eax,%ebx
  8023cc:	89 d8                	mov    %ebx,%eax
  8023ce:	89 fa                	mov    %edi,%edx
  8023d0:	83 c4 1c             	add    $0x1c,%esp
  8023d3:	5b                   	pop    %ebx
  8023d4:	5e                   	pop    %esi
  8023d5:	5f                   	pop    %edi
  8023d6:	5d                   	pop    %ebp
  8023d7:	c3                   	ret    
  8023d8:	90                   	nop
  8023d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023e0:	39 ce                	cmp    %ecx,%esi
  8023e2:	77 74                	ja     802458 <__udivdi3+0xd8>
  8023e4:	0f bd fe             	bsr    %esi,%edi
  8023e7:	83 f7 1f             	xor    $0x1f,%edi
  8023ea:	0f 84 98 00 00 00    	je     802488 <__udivdi3+0x108>
  8023f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8023f5:	89 f9                	mov    %edi,%ecx
  8023f7:	89 c5                	mov    %eax,%ebp
  8023f9:	29 fb                	sub    %edi,%ebx
  8023fb:	d3 e6                	shl    %cl,%esi
  8023fd:	89 d9                	mov    %ebx,%ecx
  8023ff:	d3 ed                	shr    %cl,%ebp
  802401:	89 f9                	mov    %edi,%ecx
  802403:	d3 e0                	shl    %cl,%eax
  802405:	09 ee                	or     %ebp,%esi
  802407:	89 d9                	mov    %ebx,%ecx
  802409:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80240d:	89 d5                	mov    %edx,%ebp
  80240f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802413:	d3 ed                	shr    %cl,%ebp
  802415:	89 f9                	mov    %edi,%ecx
  802417:	d3 e2                	shl    %cl,%edx
  802419:	89 d9                	mov    %ebx,%ecx
  80241b:	d3 e8                	shr    %cl,%eax
  80241d:	09 c2                	or     %eax,%edx
  80241f:	89 d0                	mov    %edx,%eax
  802421:	89 ea                	mov    %ebp,%edx
  802423:	f7 f6                	div    %esi
  802425:	89 d5                	mov    %edx,%ebp
  802427:	89 c3                	mov    %eax,%ebx
  802429:	f7 64 24 0c          	mull   0xc(%esp)
  80242d:	39 d5                	cmp    %edx,%ebp
  80242f:	72 10                	jb     802441 <__udivdi3+0xc1>
  802431:	8b 74 24 08          	mov    0x8(%esp),%esi
  802435:	89 f9                	mov    %edi,%ecx
  802437:	d3 e6                	shl    %cl,%esi
  802439:	39 c6                	cmp    %eax,%esi
  80243b:	73 07                	jae    802444 <__udivdi3+0xc4>
  80243d:	39 d5                	cmp    %edx,%ebp
  80243f:	75 03                	jne    802444 <__udivdi3+0xc4>
  802441:	83 eb 01             	sub    $0x1,%ebx
  802444:	31 ff                	xor    %edi,%edi
  802446:	89 d8                	mov    %ebx,%eax
  802448:	89 fa                	mov    %edi,%edx
  80244a:	83 c4 1c             	add    $0x1c,%esp
  80244d:	5b                   	pop    %ebx
  80244e:	5e                   	pop    %esi
  80244f:	5f                   	pop    %edi
  802450:	5d                   	pop    %ebp
  802451:	c3                   	ret    
  802452:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802458:	31 ff                	xor    %edi,%edi
  80245a:	31 db                	xor    %ebx,%ebx
  80245c:	89 d8                	mov    %ebx,%eax
  80245e:	89 fa                	mov    %edi,%edx
  802460:	83 c4 1c             	add    $0x1c,%esp
  802463:	5b                   	pop    %ebx
  802464:	5e                   	pop    %esi
  802465:	5f                   	pop    %edi
  802466:	5d                   	pop    %ebp
  802467:	c3                   	ret    
  802468:	90                   	nop
  802469:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802470:	89 d8                	mov    %ebx,%eax
  802472:	f7 f7                	div    %edi
  802474:	31 ff                	xor    %edi,%edi
  802476:	89 c3                	mov    %eax,%ebx
  802478:	89 d8                	mov    %ebx,%eax
  80247a:	89 fa                	mov    %edi,%edx
  80247c:	83 c4 1c             	add    $0x1c,%esp
  80247f:	5b                   	pop    %ebx
  802480:	5e                   	pop    %esi
  802481:	5f                   	pop    %edi
  802482:	5d                   	pop    %ebp
  802483:	c3                   	ret    
  802484:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802488:	39 ce                	cmp    %ecx,%esi
  80248a:	72 0c                	jb     802498 <__udivdi3+0x118>
  80248c:	31 db                	xor    %ebx,%ebx
  80248e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802492:	0f 87 34 ff ff ff    	ja     8023cc <__udivdi3+0x4c>
  802498:	bb 01 00 00 00       	mov    $0x1,%ebx
  80249d:	e9 2a ff ff ff       	jmp    8023cc <__udivdi3+0x4c>
  8024a2:	66 90                	xchg   %ax,%ax
  8024a4:	66 90                	xchg   %ax,%ax
  8024a6:	66 90                	xchg   %ax,%ax
  8024a8:	66 90                	xchg   %ax,%ax
  8024aa:	66 90                	xchg   %ax,%ax
  8024ac:	66 90                	xchg   %ax,%ax
  8024ae:	66 90                	xchg   %ax,%ax

008024b0 <__umoddi3>:
  8024b0:	55                   	push   %ebp
  8024b1:	57                   	push   %edi
  8024b2:	56                   	push   %esi
  8024b3:	53                   	push   %ebx
  8024b4:	83 ec 1c             	sub    $0x1c,%esp
  8024b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8024bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8024bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024c7:	85 d2                	test   %edx,%edx
  8024c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8024cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024d1:	89 f3                	mov    %esi,%ebx
  8024d3:	89 3c 24             	mov    %edi,(%esp)
  8024d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024da:	75 1c                	jne    8024f8 <__umoddi3+0x48>
  8024dc:	39 f7                	cmp    %esi,%edi
  8024de:	76 50                	jbe    802530 <__umoddi3+0x80>
  8024e0:	89 c8                	mov    %ecx,%eax
  8024e2:	89 f2                	mov    %esi,%edx
  8024e4:	f7 f7                	div    %edi
  8024e6:	89 d0                	mov    %edx,%eax
  8024e8:	31 d2                	xor    %edx,%edx
  8024ea:	83 c4 1c             	add    $0x1c,%esp
  8024ed:	5b                   	pop    %ebx
  8024ee:	5e                   	pop    %esi
  8024ef:	5f                   	pop    %edi
  8024f0:	5d                   	pop    %ebp
  8024f1:	c3                   	ret    
  8024f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024f8:	39 f2                	cmp    %esi,%edx
  8024fa:	89 d0                	mov    %edx,%eax
  8024fc:	77 52                	ja     802550 <__umoddi3+0xa0>
  8024fe:	0f bd ea             	bsr    %edx,%ebp
  802501:	83 f5 1f             	xor    $0x1f,%ebp
  802504:	75 5a                	jne    802560 <__umoddi3+0xb0>
  802506:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80250a:	0f 82 e0 00 00 00    	jb     8025f0 <__umoddi3+0x140>
  802510:	39 0c 24             	cmp    %ecx,(%esp)
  802513:	0f 86 d7 00 00 00    	jbe    8025f0 <__umoddi3+0x140>
  802519:	8b 44 24 08          	mov    0x8(%esp),%eax
  80251d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802521:	83 c4 1c             	add    $0x1c,%esp
  802524:	5b                   	pop    %ebx
  802525:	5e                   	pop    %esi
  802526:	5f                   	pop    %edi
  802527:	5d                   	pop    %ebp
  802528:	c3                   	ret    
  802529:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802530:	85 ff                	test   %edi,%edi
  802532:	89 fd                	mov    %edi,%ebp
  802534:	75 0b                	jne    802541 <__umoddi3+0x91>
  802536:	b8 01 00 00 00       	mov    $0x1,%eax
  80253b:	31 d2                	xor    %edx,%edx
  80253d:	f7 f7                	div    %edi
  80253f:	89 c5                	mov    %eax,%ebp
  802541:	89 f0                	mov    %esi,%eax
  802543:	31 d2                	xor    %edx,%edx
  802545:	f7 f5                	div    %ebp
  802547:	89 c8                	mov    %ecx,%eax
  802549:	f7 f5                	div    %ebp
  80254b:	89 d0                	mov    %edx,%eax
  80254d:	eb 99                	jmp    8024e8 <__umoddi3+0x38>
  80254f:	90                   	nop
  802550:	89 c8                	mov    %ecx,%eax
  802552:	89 f2                	mov    %esi,%edx
  802554:	83 c4 1c             	add    $0x1c,%esp
  802557:	5b                   	pop    %ebx
  802558:	5e                   	pop    %esi
  802559:	5f                   	pop    %edi
  80255a:	5d                   	pop    %ebp
  80255b:	c3                   	ret    
  80255c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802560:	8b 34 24             	mov    (%esp),%esi
  802563:	bf 20 00 00 00       	mov    $0x20,%edi
  802568:	89 e9                	mov    %ebp,%ecx
  80256a:	29 ef                	sub    %ebp,%edi
  80256c:	d3 e0                	shl    %cl,%eax
  80256e:	89 f9                	mov    %edi,%ecx
  802570:	89 f2                	mov    %esi,%edx
  802572:	d3 ea                	shr    %cl,%edx
  802574:	89 e9                	mov    %ebp,%ecx
  802576:	09 c2                	or     %eax,%edx
  802578:	89 d8                	mov    %ebx,%eax
  80257a:	89 14 24             	mov    %edx,(%esp)
  80257d:	89 f2                	mov    %esi,%edx
  80257f:	d3 e2                	shl    %cl,%edx
  802581:	89 f9                	mov    %edi,%ecx
  802583:	89 54 24 04          	mov    %edx,0x4(%esp)
  802587:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80258b:	d3 e8                	shr    %cl,%eax
  80258d:	89 e9                	mov    %ebp,%ecx
  80258f:	89 c6                	mov    %eax,%esi
  802591:	d3 e3                	shl    %cl,%ebx
  802593:	89 f9                	mov    %edi,%ecx
  802595:	89 d0                	mov    %edx,%eax
  802597:	d3 e8                	shr    %cl,%eax
  802599:	89 e9                	mov    %ebp,%ecx
  80259b:	09 d8                	or     %ebx,%eax
  80259d:	89 d3                	mov    %edx,%ebx
  80259f:	89 f2                	mov    %esi,%edx
  8025a1:	f7 34 24             	divl   (%esp)
  8025a4:	89 d6                	mov    %edx,%esi
  8025a6:	d3 e3                	shl    %cl,%ebx
  8025a8:	f7 64 24 04          	mull   0x4(%esp)
  8025ac:	39 d6                	cmp    %edx,%esi
  8025ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025b2:	89 d1                	mov    %edx,%ecx
  8025b4:	89 c3                	mov    %eax,%ebx
  8025b6:	72 08                	jb     8025c0 <__umoddi3+0x110>
  8025b8:	75 11                	jne    8025cb <__umoddi3+0x11b>
  8025ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8025be:	73 0b                	jae    8025cb <__umoddi3+0x11b>
  8025c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8025c4:	1b 14 24             	sbb    (%esp),%edx
  8025c7:	89 d1                	mov    %edx,%ecx
  8025c9:	89 c3                	mov    %eax,%ebx
  8025cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8025cf:	29 da                	sub    %ebx,%edx
  8025d1:	19 ce                	sbb    %ecx,%esi
  8025d3:	89 f9                	mov    %edi,%ecx
  8025d5:	89 f0                	mov    %esi,%eax
  8025d7:	d3 e0                	shl    %cl,%eax
  8025d9:	89 e9                	mov    %ebp,%ecx
  8025db:	d3 ea                	shr    %cl,%edx
  8025dd:	89 e9                	mov    %ebp,%ecx
  8025df:	d3 ee                	shr    %cl,%esi
  8025e1:	09 d0                	or     %edx,%eax
  8025e3:	89 f2                	mov    %esi,%edx
  8025e5:	83 c4 1c             	add    $0x1c,%esp
  8025e8:	5b                   	pop    %ebx
  8025e9:	5e                   	pop    %esi
  8025ea:	5f                   	pop    %edi
  8025eb:	5d                   	pop    %ebp
  8025ec:	c3                   	ret    
  8025ed:	8d 76 00             	lea    0x0(%esi),%esi
  8025f0:	29 f9                	sub    %edi,%ecx
  8025f2:	19 d6                	sbb    %edx,%esi
  8025f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025fc:	e9 18 ff ff ff       	jmp    802519 <__umoddi3+0x69>
