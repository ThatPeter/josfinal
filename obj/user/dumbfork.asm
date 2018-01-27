
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
  800052:	68 60 23 80 00       	push   $0x802360
  800057:	6a 20                	push   $0x20
  800059:	68 73 23 80 00       	push   $0x802373
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
  80007e:	68 83 23 80 00       	push   $0x802383
  800083:	6a 22                	push   $0x22
  800085:	68 73 23 80 00       	push   $0x802373
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
  8000b9:	68 94 23 80 00       	push   $0x802394
  8000be:	6a 25                	push   $0x25
  8000c0:	68 73 23 80 00       	push   $0x802373
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
  8000e7:	68 a7 23 80 00       	push   $0x8023a7
  8000ec:	6a 37                	push   $0x37
  8000ee:	68 73 23 80 00       	push   $0x802373
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
  800108:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
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
  80016c:	68 b7 23 80 00       	push   $0x8023b7
  800171:	6a 4c                	push   $0x4c
  800173:	68 73 23 80 00       	push   $0x802373
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
  800198:	be d5 23 80 00       	mov    $0x8023d5,%esi
  80019d:	b8 ce 23 80 00       	mov    $0x8023ce,%eax
  8001a2:	0f 45 f0             	cmovne %eax,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001aa:	eb 1a                	jmp    8001c6 <umain+0x40>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001ac:	83 ec 04             	sub    $0x4,%esp
  8001af:	56                   	push   %esi
  8001b0:	53                   	push   %ebx
  8001b1:	68 db 23 80 00       	push   $0x8023db
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
  8001f3:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
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
  80024d:	e8 60 11 00 00       	call   8013b2 <close_all>
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
  80027f:	68 f8 23 80 00       	push   $0x8023f8
  800284:	e8 b1 00 00 00       	call   80033a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800289:	83 c4 18             	add    $0x18,%esp
  80028c:	53                   	push   %ebx
  80028d:	ff 75 10             	pushl  0x10(%ebp)
  800290:	e8 54 00 00 00       	call   8002e9 <vcprintf>
	cprintf("\n");
  800295:	c7 04 24 eb 23 80 00 	movl   $0x8023eb,(%esp)
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
  80039d:	e8 2e 1d 00 00       	call   8020d0 <__udivdi3>
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
  8003e0:	e8 1b 1e 00 00       	call   802200 <__umoddi3>
  8003e5:	83 c4 14             	add    $0x14,%esp
  8003e8:	0f be 80 1b 24 80 00 	movsbl 0x80241b(%eax),%eax
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
  8004e4:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
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
  8005a8:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  8005af:	85 d2                	test   %edx,%edx
  8005b1:	75 18                	jne    8005cb <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005b3:	50                   	push   %eax
  8005b4:	68 33 24 80 00       	push   $0x802433
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
  8005cc:	68 71 28 80 00       	push   $0x802871
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
  8005f0:	b8 2c 24 80 00       	mov    $0x80242c,%eax
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
  800c6b:	68 1f 27 80 00       	push   $0x80271f
  800c70:	6a 23                	push   $0x23
  800c72:	68 3c 27 80 00       	push   $0x80273c
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
  800cec:	68 1f 27 80 00       	push   $0x80271f
  800cf1:	6a 23                	push   $0x23
  800cf3:	68 3c 27 80 00       	push   $0x80273c
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
  800d2e:	68 1f 27 80 00       	push   $0x80271f
  800d33:	6a 23                	push   $0x23
  800d35:	68 3c 27 80 00       	push   $0x80273c
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
  800d70:	68 1f 27 80 00       	push   $0x80271f
  800d75:	6a 23                	push   $0x23
  800d77:	68 3c 27 80 00       	push   $0x80273c
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
  800db2:	68 1f 27 80 00       	push   $0x80271f
  800db7:	6a 23                	push   $0x23
  800db9:	68 3c 27 80 00       	push   $0x80273c
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
  800df4:	68 1f 27 80 00       	push   $0x80271f
  800df9:	6a 23                	push   $0x23
  800dfb:	68 3c 27 80 00       	push   $0x80273c
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
  800e36:	68 1f 27 80 00       	push   $0x80271f
  800e3b:	6a 23                	push   $0x23
  800e3d:	68 3c 27 80 00       	push   $0x80273c
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
  800e9a:	68 1f 27 80 00       	push   $0x80271f
  800e9f:	6a 23                	push   $0x23
  800ea1:	68 3c 27 80 00       	push   $0x80273c
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

00800ef3 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	53                   	push   %ebx
  800ef7:	83 ec 04             	sub    $0x4,%esp
  800efa:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800efd:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800eff:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f03:	74 11                	je     800f16 <pgfault+0x23>
  800f05:	89 d8                	mov    %ebx,%eax
  800f07:	c1 e8 0c             	shr    $0xc,%eax
  800f0a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f11:	f6 c4 08             	test   $0x8,%ah
  800f14:	75 14                	jne    800f2a <pgfault+0x37>
		panic("faulting access");
  800f16:	83 ec 04             	sub    $0x4,%esp
  800f19:	68 4a 27 80 00       	push   $0x80274a
  800f1e:	6a 1e                	push   $0x1e
  800f20:	68 5a 27 80 00       	push   $0x80275a
  800f25:	e8 37 f3 ff ff       	call   800261 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800f2a:	83 ec 04             	sub    $0x4,%esp
  800f2d:	6a 07                	push   $0x7
  800f2f:	68 00 f0 7f 00       	push   $0x7ff000
  800f34:	6a 00                	push   $0x0
  800f36:	e8 87 fd ff ff       	call   800cc2 <sys_page_alloc>
	if (r < 0) {
  800f3b:	83 c4 10             	add    $0x10,%esp
  800f3e:	85 c0                	test   %eax,%eax
  800f40:	79 12                	jns    800f54 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800f42:	50                   	push   %eax
  800f43:	68 65 27 80 00       	push   $0x802765
  800f48:	6a 2c                	push   $0x2c
  800f4a:	68 5a 27 80 00       	push   $0x80275a
  800f4f:	e8 0d f3 ff ff       	call   800261 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800f54:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800f5a:	83 ec 04             	sub    $0x4,%esp
  800f5d:	68 00 10 00 00       	push   $0x1000
  800f62:	53                   	push   %ebx
  800f63:	68 00 f0 7f 00       	push   $0x7ff000
  800f68:	e8 4c fb ff ff       	call   800ab9 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800f6d:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f74:	53                   	push   %ebx
  800f75:	6a 00                	push   $0x0
  800f77:	68 00 f0 7f 00       	push   $0x7ff000
  800f7c:	6a 00                	push   $0x0
  800f7e:	e8 82 fd ff ff       	call   800d05 <sys_page_map>
	if (r < 0) {
  800f83:	83 c4 20             	add    $0x20,%esp
  800f86:	85 c0                	test   %eax,%eax
  800f88:	79 12                	jns    800f9c <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800f8a:	50                   	push   %eax
  800f8b:	68 65 27 80 00       	push   $0x802765
  800f90:	6a 33                	push   $0x33
  800f92:	68 5a 27 80 00       	push   $0x80275a
  800f97:	e8 c5 f2 ff ff       	call   800261 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800f9c:	83 ec 08             	sub    $0x8,%esp
  800f9f:	68 00 f0 7f 00       	push   $0x7ff000
  800fa4:	6a 00                	push   $0x0
  800fa6:	e8 9c fd ff ff       	call   800d47 <sys_page_unmap>
	if (r < 0) {
  800fab:	83 c4 10             	add    $0x10,%esp
  800fae:	85 c0                	test   %eax,%eax
  800fb0:	79 12                	jns    800fc4 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800fb2:	50                   	push   %eax
  800fb3:	68 65 27 80 00       	push   $0x802765
  800fb8:	6a 37                	push   $0x37
  800fba:	68 5a 27 80 00       	push   $0x80275a
  800fbf:	e8 9d f2 ff ff       	call   800261 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800fc4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fc7:	c9                   	leave  
  800fc8:	c3                   	ret    

00800fc9 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fc9:	55                   	push   %ebp
  800fca:	89 e5                	mov    %esp,%ebp
  800fcc:	57                   	push   %edi
  800fcd:	56                   	push   %esi
  800fce:	53                   	push   %ebx
  800fcf:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800fd2:	68 f3 0e 80 00       	push   $0x800ef3
  800fd7:	e8 fe 0e 00 00       	call   801eda <set_pgfault_handler>
  800fdc:	b8 07 00 00 00       	mov    $0x7,%eax
  800fe1:	cd 30                	int    $0x30
  800fe3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800fe6:	83 c4 10             	add    $0x10,%esp
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	79 17                	jns    801004 <fork+0x3b>
		panic("fork fault %e");
  800fed:	83 ec 04             	sub    $0x4,%esp
  800ff0:	68 7e 27 80 00       	push   $0x80277e
  800ff5:	68 84 00 00 00       	push   $0x84
  800ffa:	68 5a 27 80 00       	push   $0x80275a
  800fff:	e8 5d f2 ff ff       	call   800261 <_panic>
  801004:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  801006:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80100a:	75 24                	jne    801030 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  80100c:	e8 73 fc ff ff       	call   800c84 <sys_getenvid>
  801011:	25 ff 03 00 00       	and    $0x3ff,%eax
  801016:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  80101c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801021:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801026:	b8 00 00 00 00       	mov    $0x0,%eax
  80102b:	e9 64 01 00 00       	jmp    801194 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  801030:	83 ec 04             	sub    $0x4,%esp
  801033:	6a 07                	push   $0x7
  801035:	68 00 f0 bf ee       	push   $0xeebff000
  80103a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80103d:	e8 80 fc ff ff       	call   800cc2 <sys_page_alloc>
  801042:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801045:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80104a:	89 d8                	mov    %ebx,%eax
  80104c:	c1 e8 16             	shr    $0x16,%eax
  80104f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801056:	a8 01                	test   $0x1,%al
  801058:	0f 84 fc 00 00 00    	je     80115a <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  80105e:	89 d8                	mov    %ebx,%eax
  801060:	c1 e8 0c             	shr    $0xc,%eax
  801063:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80106a:	f6 c2 01             	test   $0x1,%dl
  80106d:	0f 84 e7 00 00 00    	je     80115a <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  801073:	89 c6                	mov    %eax,%esi
  801075:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  801078:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80107f:	f6 c6 04             	test   $0x4,%dh
  801082:	74 39                	je     8010bd <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  801084:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80108b:	83 ec 0c             	sub    $0xc,%esp
  80108e:	25 07 0e 00 00       	and    $0xe07,%eax
  801093:	50                   	push   %eax
  801094:	56                   	push   %esi
  801095:	57                   	push   %edi
  801096:	56                   	push   %esi
  801097:	6a 00                	push   $0x0
  801099:	e8 67 fc ff ff       	call   800d05 <sys_page_map>
		if (r < 0) {
  80109e:	83 c4 20             	add    $0x20,%esp
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	0f 89 b1 00 00 00    	jns    80115a <fork+0x191>
		    	panic("sys page map fault %e");
  8010a9:	83 ec 04             	sub    $0x4,%esp
  8010ac:	68 8c 27 80 00       	push   $0x80278c
  8010b1:	6a 54                	push   $0x54
  8010b3:	68 5a 27 80 00       	push   $0x80275a
  8010b8:	e8 a4 f1 ff ff       	call   800261 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8010bd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010c4:	f6 c2 02             	test   $0x2,%dl
  8010c7:	75 0c                	jne    8010d5 <fork+0x10c>
  8010c9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010d0:	f6 c4 08             	test   $0x8,%ah
  8010d3:	74 5b                	je     801130 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8010d5:	83 ec 0c             	sub    $0xc,%esp
  8010d8:	68 05 08 00 00       	push   $0x805
  8010dd:	56                   	push   %esi
  8010de:	57                   	push   %edi
  8010df:	56                   	push   %esi
  8010e0:	6a 00                	push   $0x0
  8010e2:	e8 1e fc ff ff       	call   800d05 <sys_page_map>
		if (r < 0) {
  8010e7:	83 c4 20             	add    $0x20,%esp
  8010ea:	85 c0                	test   %eax,%eax
  8010ec:	79 14                	jns    801102 <fork+0x139>
		    	panic("sys page map fault %e");
  8010ee:	83 ec 04             	sub    $0x4,%esp
  8010f1:	68 8c 27 80 00       	push   $0x80278c
  8010f6:	6a 5b                	push   $0x5b
  8010f8:	68 5a 27 80 00       	push   $0x80275a
  8010fd:	e8 5f f1 ff ff       	call   800261 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  801102:	83 ec 0c             	sub    $0xc,%esp
  801105:	68 05 08 00 00       	push   $0x805
  80110a:	56                   	push   %esi
  80110b:	6a 00                	push   $0x0
  80110d:	56                   	push   %esi
  80110e:	6a 00                	push   $0x0
  801110:	e8 f0 fb ff ff       	call   800d05 <sys_page_map>
		if (r < 0) {
  801115:	83 c4 20             	add    $0x20,%esp
  801118:	85 c0                	test   %eax,%eax
  80111a:	79 3e                	jns    80115a <fork+0x191>
		    	panic("sys page map fault %e");
  80111c:	83 ec 04             	sub    $0x4,%esp
  80111f:	68 8c 27 80 00       	push   $0x80278c
  801124:	6a 5f                	push   $0x5f
  801126:	68 5a 27 80 00       	push   $0x80275a
  80112b:	e8 31 f1 ff ff       	call   800261 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801130:	83 ec 0c             	sub    $0xc,%esp
  801133:	6a 05                	push   $0x5
  801135:	56                   	push   %esi
  801136:	57                   	push   %edi
  801137:	56                   	push   %esi
  801138:	6a 00                	push   $0x0
  80113a:	e8 c6 fb ff ff       	call   800d05 <sys_page_map>
		if (r < 0) {
  80113f:	83 c4 20             	add    $0x20,%esp
  801142:	85 c0                	test   %eax,%eax
  801144:	79 14                	jns    80115a <fork+0x191>
		    	panic("sys page map fault %e");
  801146:	83 ec 04             	sub    $0x4,%esp
  801149:	68 8c 27 80 00       	push   $0x80278c
  80114e:	6a 64                	push   $0x64
  801150:	68 5a 27 80 00       	push   $0x80275a
  801155:	e8 07 f1 ff ff       	call   800261 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80115a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801160:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801166:	0f 85 de fe ff ff    	jne    80104a <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  80116c:	a1 04 40 80 00       	mov    0x804004,%eax
  801171:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  801177:	83 ec 08             	sub    $0x8,%esp
  80117a:	50                   	push   %eax
  80117b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80117e:	57                   	push   %edi
  80117f:	e8 89 fc ff ff       	call   800e0d <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801184:	83 c4 08             	add    $0x8,%esp
  801187:	6a 02                	push   $0x2
  801189:	57                   	push   %edi
  80118a:	e8 fa fb ff ff       	call   800d89 <sys_env_set_status>
	
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
  8011bd:	e8 78 f1 ff ff       	call   80033a <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8011c2:	c7 04 24 27 02 80 00 	movl   $0x800227,(%esp)
  8011c9:	e8 e5 fc ff ff       	call   800eb3 <sys_thread_create>
  8011ce:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8011d0:	83 c4 08             	add    $0x8,%esp
  8011d3:	53                   	push   %ebx
  8011d4:	68 a4 27 80 00       	push   $0x8027a4
  8011d9:	e8 5c f1 ff ff       	call   80033a <cprintf>
	return id;
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
  8012e1:	8b 40 7c             	mov    0x7c(%eax),%eax
  8012e4:	83 ec 04             	sub    $0x4,%esp
  8012e7:	51                   	push   %ecx
  8012e8:	50                   	push   %eax
  8012e9:	68 c8 27 80 00       	push   $0x8027c8
  8012ee:	e8 47 f0 ff ff       	call   80033a <cprintf>
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
  801376:	e8 cc f9 ff ff       	call   800d47 <sys_page_unmap>
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
  801462:	e8 9e f8 ff ff       	call   800d05 <sys_page_map>
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
  80148e:	e8 72 f8 ff ff       	call   800d05 <sys_page_map>
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
  8014a4:	e8 9e f8 ff ff       	call   800d47 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014a9:	83 c4 08             	add    $0x8,%esp
  8014ac:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014af:	6a 00                	push   $0x0
  8014b1:	e8 91 f8 ff ff       	call   800d47 <sys_page_unmap>
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
  80150b:	8b 40 7c             	mov    0x7c(%eax),%eax
  80150e:	83 ec 04             	sub    $0x4,%esp
  801511:	53                   	push   %ebx
  801512:	50                   	push   %eax
  801513:	68 0c 28 80 00       	push   $0x80280c
  801518:	e8 1d ee ff ff       	call   80033a <cprintf>
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
  8015e0:	8b 40 7c             	mov    0x7c(%eax),%eax
  8015e3:	83 ec 04             	sub    $0x4,%esp
  8015e6:	53                   	push   %ebx
  8015e7:	50                   	push   %eax
  8015e8:	68 28 28 80 00       	push   $0x802828
  8015ed:	e8 48 ed ff ff       	call   80033a <cprintf>
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
  801695:	8b 40 7c             	mov    0x7c(%eax),%eax
  801698:	83 ec 04             	sub    $0x4,%esp
  80169b:	53                   	push   %ebx
  80169c:	50                   	push   %eax
  80169d:	68 e8 27 80 00       	push   $0x8027e8
  8016a2:	e8 93 ec ff ff       	call   80033a <cprintf>
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
  8017ad:	e8 94 08 00 00       	call   802046 <ipc_find_env>
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
  8017c8:	e8 17 08 00 00       	call   801fe4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017cd:	83 c4 0c             	add    $0xc,%esp
  8017d0:	6a 00                	push   $0x0
  8017d2:	53                   	push   %ebx
  8017d3:	6a 00                	push   $0x0
  8017d5:	e8 8f 07 00 00       	call   801f69 <ipc_recv>
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
  80185e:	e8 5c f0 ff ff       	call   8008bf <strcpy>
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
  8018b6:	e8 96 f1 ff ff       	call   800a51 <memmove>

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
  80190f:	e8 4d e9 ff ff       	call   800261 <_panic>
	assert(r <= PGSIZE);
  801914:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801919:	7e 16                	jle    801931 <devfile_read+0x65>
  80191b:	68 7f 28 80 00       	push   $0x80287f
  801920:	68 5f 28 80 00       	push   $0x80285f
  801925:	6a 7d                	push   $0x7d
  801927:	68 74 28 80 00       	push   $0x802874
  80192c:	e8 30 e9 ff ff       	call   800261 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801931:	83 ec 04             	sub    $0x4,%esp
  801934:	50                   	push   %eax
  801935:	68 00 50 80 00       	push   $0x805000
  80193a:	ff 75 0c             	pushl  0xc(%ebp)
  80193d:	e8 0f f1 ff ff       	call   800a51 <memmove>
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
  801959:	e8 28 ef ff ff       	call   800886 <strlen>
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
  801986:	e8 34 ef ff ff       	call   8008bf <strcpy>
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
  801a10:	e8 aa ee ff ff       	call   8008bf <strcpy>
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
  801a4d:	e8 f5 f2 ff ff       	call   800d47 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a52:	89 1c 24             	mov    %ebx,(%esp)
  801a55:	e8 9d f7 ff ff       	call   8011f7 <fd2data>
  801a5a:	83 c4 08             	add    $0x8,%esp
  801a5d:	50                   	push   %eax
  801a5e:	6a 00                	push   $0x0
  801a60:	e8 e2 f2 ff ff       	call   800d47 <sys_page_unmap>
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
  801a7d:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a83:	83 ec 0c             	sub    $0xc,%esp
  801a86:	ff 75 e0             	pushl  -0x20(%ebp)
  801a89:	e8 fa 05 00 00       	call   802088 <pageref>
  801a8e:	89 c3                	mov    %eax,%ebx
  801a90:	89 3c 24             	mov    %edi,(%esp)
  801a93:	e8 f0 05 00 00       	call   802088 <pageref>
  801a98:	83 c4 10             	add    $0x10,%esp
  801a9b:	39 c3                	cmp    %eax,%ebx
  801a9d:	0f 94 c1             	sete   %cl
  801aa0:	0f b6 c9             	movzbl %cl,%ecx
  801aa3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801aa6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801aac:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  801ab2:	39 ce                	cmp    %ecx,%esi
  801ab4:	74 1e                	je     801ad4 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801ab6:	39 c3                	cmp    %eax,%ebx
  801ab8:	75 be                	jne    801a78 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801aba:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  801ac0:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ac3:	50                   	push   %eax
  801ac4:	56                   	push   %esi
  801ac5:	68 92 28 80 00       	push   $0x802892
  801aca:	e8 6b e8 ff ff       	call   80033a <cprintf>
  801acf:	83 c4 10             	add    $0x10,%esp
  801ad2:	eb a4                	jmp    801a78 <_pipeisclosed+0xe>
	}
}
  801ad4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ad7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ada:	5b                   	pop    %ebx
  801adb:	5e                   	pop    %esi
  801adc:	5f                   	pop    %edi
  801add:	5d                   	pop    %ebp
  801ade:	c3                   	ret    

00801adf <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801adf:	55                   	push   %ebp
  801ae0:	89 e5                	mov    %esp,%ebp
  801ae2:	57                   	push   %edi
  801ae3:	56                   	push   %esi
  801ae4:	53                   	push   %ebx
  801ae5:	83 ec 28             	sub    $0x28,%esp
  801ae8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801aeb:	56                   	push   %esi
  801aec:	e8 06 f7 ff ff       	call   8011f7 <fd2data>
  801af1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801af3:	83 c4 10             	add    $0x10,%esp
  801af6:	bf 00 00 00 00       	mov    $0x0,%edi
  801afb:	eb 4b                	jmp    801b48 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801afd:	89 da                	mov    %ebx,%edx
  801aff:	89 f0                	mov    %esi,%eax
  801b01:	e8 64 ff ff ff       	call   801a6a <_pipeisclosed>
  801b06:	85 c0                	test   %eax,%eax
  801b08:	75 48                	jne    801b52 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b0a:	e8 94 f1 ff ff       	call   800ca3 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b0f:	8b 43 04             	mov    0x4(%ebx),%eax
  801b12:	8b 0b                	mov    (%ebx),%ecx
  801b14:	8d 51 20             	lea    0x20(%ecx),%edx
  801b17:	39 d0                	cmp    %edx,%eax
  801b19:	73 e2                	jae    801afd <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b1e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b22:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b25:	89 c2                	mov    %eax,%edx
  801b27:	c1 fa 1f             	sar    $0x1f,%edx
  801b2a:	89 d1                	mov    %edx,%ecx
  801b2c:	c1 e9 1b             	shr    $0x1b,%ecx
  801b2f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b32:	83 e2 1f             	and    $0x1f,%edx
  801b35:	29 ca                	sub    %ecx,%edx
  801b37:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b3b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b3f:	83 c0 01             	add    $0x1,%eax
  801b42:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b45:	83 c7 01             	add    $0x1,%edi
  801b48:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b4b:	75 c2                	jne    801b0f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b4d:	8b 45 10             	mov    0x10(%ebp),%eax
  801b50:	eb 05                	jmp    801b57 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b52:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b5a:	5b                   	pop    %ebx
  801b5b:	5e                   	pop    %esi
  801b5c:	5f                   	pop    %edi
  801b5d:	5d                   	pop    %ebp
  801b5e:	c3                   	ret    

00801b5f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b5f:	55                   	push   %ebp
  801b60:	89 e5                	mov    %esp,%ebp
  801b62:	57                   	push   %edi
  801b63:	56                   	push   %esi
  801b64:	53                   	push   %ebx
  801b65:	83 ec 18             	sub    $0x18,%esp
  801b68:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b6b:	57                   	push   %edi
  801b6c:	e8 86 f6 ff ff       	call   8011f7 <fd2data>
  801b71:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b73:	83 c4 10             	add    $0x10,%esp
  801b76:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b7b:	eb 3d                	jmp    801bba <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b7d:	85 db                	test   %ebx,%ebx
  801b7f:	74 04                	je     801b85 <devpipe_read+0x26>
				return i;
  801b81:	89 d8                	mov    %ebx,%eax
  801b83:	eb 44                	jmp    801bc9 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b85:	89 f2                	mov    %esi,%edx
  801b87:	89 f8                	mov    %edi,%eax
  801b89:	e8 dc fe ff ff       	call   801a6a <_pipeisclosed>
  801b8e:	85 c0                	test   %eax,%eax
  801b90:	75 32                	jne    801bc4 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b92:	e8 0c f1 ff ff       	call   800ca3 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b97:	8b 06                	mov    (%esi),%eax
  801b99:	3b 46 04             	cmp    0x4(%esi),%eax
  801b9c:	74 df                	je     801b7d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b9e:	99                   	cltd   
  801b9f:	c1 ea 1b             	shr    $0x1b,%edx
  801ba2:	01 d0                	add    %edx,%eax
  801ba4:	83 e0 1f             	and    $0x1f,%eax
  801ba7:	29 d0                	sub    %edx,%eax
  801ba9:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bb1:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bb4:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bb7:	83 c3 01             	add    $0x1,%ebx
  801bba:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bbd:	75 d8                	jne    801b97 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bbf:	8b 45 10             	mov    0x10(%ebp),%eax
  801bc2:	eb 05                	jmp    801bc9 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bc4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bcc:	5b                   	pop    %ebx
  801bcd:	5e                   	pop    %esi
  801bce:	5f                   	pop    %edi
  801bcf:	5d                   	pop    %ebp
  801bd0:	c3                   	ret    

00801bd1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bd1:	55                   	push   %ebp
  801bd2:	89 e5                	mov    %esp,%ebp
  801bd4:	56                   	push   %esi
  801bd5:	53                   	push   %ebx
  801bd6:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bd9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bdc:	50                   	push   %eax
  801bdd:	e8 2c f6 ff ff       	call   80120e <fd_alloc>
  801be2:	83 c4 10             	add    $0x10,%esp
  801be5:	89 c2                	mov    %eax,%edx
  801be7:	85 c0                	test   %eax,%eax
  801be9:	0f 88 2c 01 00 00    	js     801d1b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bef:	83 ec 04             	sub    $0x4,%esp
  801bf2:	68 07 04 00 00       	push   $0x407
  801bf7:	ff 75 f4             	pushl  -0xc(%ebp)
  801bfa:	6a 00                	push   $0x0
  801bfc:	e8 c1 f0 ff ff       	call   800cc2 <sys_page_alloc>
  801c01:	83 c4 10             	add    $0x10,%esp
  801c04:	89 c2                	mov    %eax,%edx
  801c06:	85 c0                	test   %eax,%eax
  801c08:	0f 88 0d 01 00 00    	js     801d1b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c0e:	83 ec 0c             	sub    $0xc,%esp
  801c11:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c14:	50                   	push   %eax
  801c15:	e8 f4 f5 ff ff       	call   80120e <fd_alloc>
  801c1a:	89 c3                	mov    %eax,%ebx
  801c1c:	83 c4 10             	add    $0x10,%esp
  801c1f:	85 c0                	test   %eax,%eax
  801c21:	0f 88 e2 00 00 00    	js     801d09 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c27:	83 ec 04             	sub    $0x4,%esp
  801c2a:	68 07 04 00 00       	push   $0x407
  801c2f:	ff 75 f0             	pushl  -0x10(%ebp)
  801c32:	6a 00                	push   $0x0
  801c34:	e8 89 f0 ff ff       	call   800cc2 <sys_page_alloc>
  801c39:	89 c3                	mov    %eax,%ebx
  801c3b:	83 c4 10             	add    $0x10,%esp
  801c3e:	85 c0                	test   %eax,%eax
  801c40:	0f 88 c3 00 00 00    	js     801d09 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c46:	83 ec 0c             	sub    $0xc,%esp
  801c49:	ff 75 f4             	pushl  -0xc(%ebp)
  801c4c:	e8 a6 f5 ff ff       	call   8011f7 <fd2data>
  801c51:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c53:	83 c4 0c             	add    $0xc,%esp
  801c56:	68 07 04 00 00       	push   $0x407
  801c5b:	50                   	push   %eax
  801c5c:	6a 00                	push   $0x0
  801c5e:	e8 5f f0 ff ff       	call   800cc2 <sys_page_alloc>
  801c63:	89 c3                	mov    %eax,%ebx
  801c65:	83 c4 10             	add    $0x10,%esp
  801c68:	85 c0                	test   %eax,%eax
  801c6a:	0f 88 89 00 00 00    	js     801cf9 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c70:	83 ec 0c             	sub    $0xc,%esp
  801c73:	ff 75 f0             	pushl  -0x10(%ebp)
  801c76:	e8 7c f5 ff ff       	call   8011f7 <fd2data>
  801c7b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c82:	50                   	push   %eax
  801c83:	6a 00                	push   $0x0
  801c85:	56                   	push   %esi
  801c86:	6a 00                	push   $0x0
  801c88:	e8 78 f0 ff ff       	call   800d05 <sys_page_map>
  801c8d:	89 c3                	mov    %eax,%ebx
  801c8f:	83 c4 20             	add    $0x20,%esp
  801c92:	85 c0                	test   %eax,%eax
  801c94:	78 55                	js     801ceb <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c96:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c9f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ca1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cab:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cb4:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cb9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cc0:	83 ec 0c             	sub    $0xc,%esp
  801cc3:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc6:	e8 1c f5 ff ff       	call   8011e7 <fd2num>
  801ccb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cce:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cd0:	83 c4 04             	add    $0x4,%esp
  801cd3:	ff 75 f0             	pushl  -0x10(%ebp)
  801cd6:	e8 0c f5 ff ff       	call   8011e7 <fd2num>
  801cdb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cde:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801ce1:	83 c4 10             	add    $0x10,%esp
  801ce4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ce9:	eb 30                	jmp    801d1b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ceb:	83 ec 08             	sub    $0x8,%esp
  801cee:	56                   	push   %esi
  801cef:	6a 00                	push   $0x0
  801cf1:	e8 51 f0 ff ff       	call   800d47 <sys_page_unmap>
  801cf6:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cf9:	83 ec 08             	sub    $0x8,%esp
  801cfc:	ff 75 f0             	pushl  -0x10(%ebp)
  801cff:	6a 00                	push   $0x0
  801d01:	e8 41 f0 ff ff       	call   800d47 <sys_page_unmap>
  801d06:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d09:	83 ec 08             	sub    $0x8,%esp
  801d0c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d0f:	6a 00                	push   $0x0
  801d11:	e8 31 f0 ff ff       	call   800d47 <sys_page_unmap>
  801d16:	83 c4 10             	add    $0x10,%esp
  801d19:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d1b:	89 d0                	mov    %edx,%eax
  801d1d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d20:	5b                   	pop    %ebx
  801d21:	5e                   	pop    %esi
  801d22:	5d                   	pop    %ebp
  801d23:	c3                   	ret    

00801d24 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d24:	55                   	push   %ebp
  801d25:	89 e5                	mov    %esp,%ebp
  801d27:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d2d:	50                   	push   %eax
  801d2e:	ff 75 08             	pushl  0x8(%ebp)
  801d31:	e8 27 f5 ff ff       	call   80125d <fd_lookup>
  801d36:	83 c4 10             	add    $0x10,%esp
  801d39:	85 c0                	test   %eax,%eax
  801d3b:	78 18                	js     801d55 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d3d:	83 ec 0c             	sub    $0xc,%esp
  801d40:	ff 75 f4             	pushl  -0xc(%ebp)
  801d43:	e8 af f4 ff ff       	call   8011f7 <fd2data>
	return _pipeisclosed(fd, p);
  801d48:	89 c2                	mov    %eax,%edx
  801d4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4d:	e8 18 fd ff ff       	call   801a6a <_pipeisclosed>
  801d52:	83 c4 10             	add    $0x10,%esp
}
  801d55:	c9                   	leave  
  801d56:	c3                   	ret    

00801d57 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d57:	55                   	push   %ebp
  801d58:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d5a:	b8 00 00 00 00       	mov    $0x0,%eax
  801d5f:	5d                   	pop    %ebp
  801d60:	c3                   	ret    

00801d61 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d61:	55                   	push   %ebp
  801d62:	89 e5                	mov    %esp,%ebp
  801d64:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d67:	68 aa 28 80 00       	push   $0x8028aa
  801d6c:	ff 75 0c             	pushl  0xc(%ebp)
  801d6f:	e8 4b eb ff ff       	call   8008bf <strcpy>
	return 0;
}
  801d74:	b8 00 00 00 00       	mov    $0x0,%eax
  801d79:	c9                   	leave  
  801d7a:	c3                   	ret    

00801d7b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d7b:	55                   	push   %ebp
  801d7c:	89 e5                	mov    %esp,%ebp
  801d7e:	57                   	push   %edi
  801d7f:	56                   	push   %esi
  801d80:	53                   	push   %ebx
  801d81:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d87:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d8c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d92:	eb 2d                	jmp    801dc1 <devcons_write+0x46>
		m = n - tot;
  801d94:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d97:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d99:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d9c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801da1:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801da4:	83 ec 04             	sub    $0x4,%esp
  801da7:	53                   	push   %ebx
  801da8:	03 45 0c             	add    0xc(%ebp),%eax
  801dab:	50                   	push   %eax
  801dac:	57                   	push   %edi
  801dad:	e8 9f ec ff ff       	call   800a51 <memmove>
		sys_cputs(buf, m);
  801db2:	83 c4 08             	add    $0x8,%esp
  801db5:	53                   	push   %ebx
  801db6:	57                   	push   %edi
  801db7:	e8 4a ee ff ff       	call   800c06 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dbc:	01 de                	add    %ebx,%esi
  801dbe:	83 c4 10             	add    $0x10,%esp
  801dc1:	89 f0                	mov    %esi,%eax
  801dc3:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dc6:	72 cc                	jb     801d94 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dcb:	5b                   	pop    %ebx
  801dcc:	5e                   	pop    %esi
  801dcd:	5f                   	pop    %edi
  801dce:	5d                   	pop    %ebp
  801dcf:	c3                   	ret    

00801dd0 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dd0:	55                   	push   %ebp
  801dd1:	89 e5                	mov    %esp,%ebp
  801dd3:	83 ec 08             	sub    $0x8,%esp
  801dd6:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ddb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ddf:	74 2a                	je     801e0b <devcons_read+0x3b>
  801de1:	eb 05                	jmp    801de8 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801de3:	e8 bb ee ff ff       	call   800ca3 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801de8:	e8 37 ee ff ff       	call   800c24 <sys_cgetc>
  801ded:	85 c0                	test   %eax,%eax
  801def:	74 f2                	je     801de3 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801df1:	85 c0                	test   %eax,%eax
  801df3:	78 16                	js     801e0b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801df5:	83 f8 04             	cmp    $0x4,%eax
  801df8:	74 0c                	je     801e06 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801dfa:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dfd:	88 02                	mov    %al,(%edx)
	return 1;
  801dff:	b8 01 00 00 00       	mov    $0x1,%eax
  801e04:	eb 05                	jmp    801e0b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e06:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e0b:	c9                   	leave  
  801e0c:	c3                   	ret    

00801e0d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e0d:	55                   	push   %ebp
  801e0e:	89 e5                	mov    %esp,%ebp
  801e10:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e13:	8b 45 08             	mov    0x8(%ebp),%eax
  801e16:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e19:	6a 01                	push   $0x1
  801e1b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e1e:	50                   	push   %eax
  801e1f:	e8 e2 ed ff ff       	call   800c06 <sys_cputs>
}
  801e24:	83 c4 10             	add    $0x10,%esp
  801e27:	c9                   	leave  
  801e28:	c3                   	ret    

00801e29 <getchar>:

int
getchar(void)
{
  801e29:	55                   	push   %ebp
  801e2a:	89 e5                	mov    %esp,%ebp
  801e2c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e2f:	6a 01                	push   $0x1
  801e31:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e34:	50                   	push   %eax
  801e35:	6a 00                	push   $0x0
  801e37:	e8 87 f6 ff ff       	call   8014c3 <read>
	if (r < 0)
  801e3c:	83 c4 10             	add    $0x10,%esp
  801e3f:	85 c0                	test   %eax,%eax
  801e41:	78 0f                	js     801e52 <getchar+0x29>
		return r;
	if (r < 1)
  801e43:	85 c0                	test   %eax,%eax
  801e45:	7e 06                	jle    801e4d <getchar+0x24>
		return -E_EOF;
	return c;
  801e47:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e4b:	eb 05                	jmp    801e52 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e4d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e52:	c9                   	leave  
  801e53:	c3                   	ret    

00801e54 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e54:	55                   	push   %ebp
  801e55:	89 e5                	mov    %esp,%ebp
  801e57:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e5d:	50                   	push   %eax
  801e5e:	ff 75 08             	pushl  0x8(%ebp)
  801e61:	e8 f7 f3 ff ff       	call   80125d <fd_lookup>
  801e66:	83 c4 10             	add    $0x10,%esp
  801e69:	85 c0                	test   %eax,%eax
  801e6b:	78 11                	js     801e7e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e70:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e76:	39 10                	cmp    %edx,(%eax)
  801e78:	0f 94 c0             	sete   %al
  801e7b:	0f b6 c0             	movzbl %al,%eax
}
  801e7e:	c9                   	leave  
  801e7f:	c3                   	ret    

00801e80 <opencons>:

int
opencons(void)
{
  801e80:	55                   	push   %ebp
  801e81:	89 e5                	mov    %esp,%ebp
  801e83:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e89:	50                   	push   %eax
  801e8a:	e8 7f f3 ff ff       	call   80120e <fd_alloc>
  801e8f:	83 c4 10             	add    $0x10,%esp
		return r;
  801e92:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e94:	85 c0                	test   %eax,%eax
  801e96:	78 3e                	js     801ed6 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e98:	83 ec 04             	sub    $0x4,%esp
  801e9b:	68 07 04 00 00       	push   $0x407
  801ea0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ea3:	6a 00                	push   $0x0
  801ea5:	e8 18 ee ff ff       	call   800cc2 <sys_page_alloc>
  801eaa:	83 c4 10             	add    $0x10,%esp
		return r;
  801ead:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eaf:	85 c0                	test   %eax,%eax
  801eb1:	78 23                	js     801ed6 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801eb3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801eb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ebc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ebe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ec8:	83 ec 0c             	sub    $0xc,%esp
  801ecb:	50                   	push   %eax
  801ecc:	e8 16 f3 ff ff       	call   8011e7 <fd2num>
  801ed1:	89 c2                	mov    %eax,%edx
  801ed3:	83 c4 10             	add    $0x10,%esp
}
  801ed6:	89 d0                	mov    %edx,%eax
  801ed8:	c9                   	leave  
  801ed9:	c3                   	ret    

00801eda <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801eda:	55                   	push   %ebp
  801edb:	89 e5                	mov    %esp,%ebp
  801edd:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ee0:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ee7:	75 2a                	jne    801f13 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801ee9:	83 ec 04             	sub    $0x4,%esp
  801eec:	6a 07                	push   $0x7
  801eee:	68 00 f0 bf ee       	push   $0xeebff000
  801ef3:	6a 00                	push   $0x0
  801ef5:	e8 c8 ed ff ff       	call   800cc2 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801efa:	83 c4 10             	add    $0x10,%esp
  801efd:	85 c0                	test   %eax,%eax
  801eff:	79 12                	jns    801f13 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801f01:	50                   	push   %eax
  801f02:	68 b6 28 80 00       	push   $0x8028b6
  801f07:	6a 23                	push   $0x23
  801f09:	68 ba 28 80 00       	push   $0x8028ba
  801f0e:	e8 4e e3 ff ff       	call   800261 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f13:	8b 45 08             	mov    0x8(%ebp),%eax
  801f16:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801f1b:	83 ec 08             	sub    $0x8,%esp
  801f1e:	68 45 1f 80 00       	push   $0x801f45
  801f23:	6a 00                	push   $0x0
  801f25:	e8 e3 ee ff ff       	call   800e0d <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801f2a:	83 c4 10             	add    $0x10,%esp
  801f2d:	85 c0                	test   %eax,%eax
  801f2f:	79 12                	jns    801f43 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801f31:	50                   	push   %eax
  801f32:	68 b6 28 80 00       	push   $0x8028b6
  801f37:	6a 2c                	push   $0x2c
  801f39:	68 ba 28 80 00       	push   $0x8028ba
  801f3e:	e8 1e e3 ff ff       	call   800261 <_panic>
	}
}
  801f43:	c9                   	leave  
  801f44:	c3                   	ret    

00801f45 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f45:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f46:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f4b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f4d:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801f50:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801f54:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801f59:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801f5d:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801f5f:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801f62:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801f63:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801f66:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801f67:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f68:	c3                   	ret    

00801f69 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f69:	55                   	push   %ebp
  801f6a:	89 e5                	mov    %esp,%ebp
  801f6c:	56                   	push   %esi
  801f6d:	53                   	push   %ebx
  801f6e:	8b 75 08             	mov    0x8(%ebp),%esi
  801f71:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f74:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801f77:	85 c0                	test   %eax,%eax
  801f79:	75 12                	jne    801f8d <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801f7b:	83 ec 0c             	sub    $0xc,%esp
  801f7e:	68 00 00 c0 ee       	push   $0xeec00000
  801f83:	e8 ea ee ff ff       	call   800e72 <sys_ipc_recv>
  801f88:	83 c4 10             	add    $0x10,%esp
  801f8b:	eb 0c                	jmp    801f99 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801f8d:	83 ec 0c             	sub    $0xc,%esp
  801f90:	50                   	push   %eax
  801f91:	e8 dc ee ff ff       	call   800e72 <sys_ipc_recv>
  801f96:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801f99:	85 f6                	test   %esi,%esi
  801f9b:	0f 95 c1             	setne  %cl
  801f9e:	85 db                	test   %ebx,%ebx
  801fa0:	0f 95 c2             	setne  %dl
  801fa3:	84 d1                	test   %dl,%cl
  801fa5:	74 09                	je     801fb0 <ipc_recv+0x47>
  801fa7:	89 c2                	mov    %eax,%edx
  801fa9:	c1 ea 1f             	shr    $0x1f,%edx
  801fac:	84 d2                	test   %dl,%dl
  801fae:	75 2d                	jne    801fdd <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801fb0:	85 f6                	test   %esi,%esi
  801fb2:	74 0d                	je     801fc1 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801fb4:	a1 04 40 80 00       	mov    0x804004,%eax
  801fb9:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  801fbf:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801fc1:	85 db                	test   %ebx,%ebx
  801fc3:	74 0d                	je     801fd2 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801fc5:	a1 04 40 80 00       	mov    0x804004,%eax
  801fca:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  801fd0:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801fd2:	a1 04 40 80 00       	mov    0x804004,%eax
  801fd7:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  801fdd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fe0:	5b                   	pop    %ebx
  801fe1:	5e                   	pop    %esi
  801fe2:	5d                   	pop    %ebp
  801fe3:	c3                   	ret    

00801fe4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fe4:	55                   	push   %ebp
  801fe5:	89 e5                	mov    %esp,%ebp
  801fe7:	57                   	push   %edi
  801fe8:	56                   	push   %esi
  801fe9:	53                   	push   %ebx
  801fea:	83 ec 0c             	sub    $0xc,%esp
  801fed:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ff0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ff3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801ff6:	85 db                	test   %ebx,%ebx
  801ff8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ffd:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802000:	ff 75 14             	pushl  0x14(%ebp)
  802003:	53                   	push   %ebx
  802004:	56                   	push   %esi
  802005:	57                   	push   %edi
  802006:	e8 44 ee ff ff       	call   800e4f <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  80200b:	89 c2                	mov    %eax,%edx
  80200d:	c1 ea 1f             	shr    $0x1f,%edx
  802010:	83 c4 10             	add    $0x10,%esp
  802013:	84 d2                	test   %dl,%dl
  802015:	74 17                	je     80202e <ipc_send+0x4a>
  802017:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80201a:	74 12                	je     80202e <ipc_send+0x4a>
			panic("failed ipc %e", r);
  80201c:	50                   	push   %eax
  80201d:	68 c8 28 80 00       	push   $0x8028c8
  802022:	6a 47                	push   $0x47
  802024:	68 d6 28 80 00       	push   $0x8028d6
  802029:	e8 33 e2 ff ff       	call   800261 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80202e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802031:	75 07                	jne    80203a <ipc_send+0x56>
			sys_yield();
  802033:	e8 6b ec ff ff       	call   800ca3 <sys_yield>
  802038:	eb c6                	jmp    802000 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80203a:	85 c0                	test   %eax,%eax
  80203c:	75 c2                	jne    802000 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80203e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802041:	5b                   	pop    %ebx
  802042:	5e                   	pop    %esi
  802043:	5f                   	pop    %edi
  802044:	5d                   	pop    %ebp
  802045:	c3                   	ret    

00802046 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802046:	55                   	push   %ebp
  802047:	89 e5                	mov    %esp,%ebp
  802049:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80204c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802051:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  802057:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80205d:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  802063:	39 ca                	cmp    %ecx,%edx
  802065:	75 10                	jne    802077 <ipc_find_env+0x31>
			return envs[i].env_id;
  802067:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  80206d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802072:	8b 40 7c             	mov    0x7c(%eax),%eax
  802075:	eb 0f                	jmp    802086 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802077:	83 c0 01             	add    $0x1,%eax
  80207a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80207f:	75 d0                	jne    802051 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802081:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802086:	5d                   	pop    %ebp
  802087:	c3                   	ret    

00802088 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802088:	55                   	push   %ebp
  802089:	89 e5                	mov    %esp,%ebp
  80208b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80208e:	89 d0                	mov    %edx,%eax
  802090:	c1 e8 16             	shr    $0x16,%eax
  802093:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80209a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80209f:	f6 c1 01             	test   $0x1,%cl
  8020a2:	74 1d                	je     8020c1 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020a4:	c1 ea 0c             	shr    $0xc,%edx
  8020a7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020ae:	f6 c2 01             	test   $0x1,%dl
  8020b1:	74 0e                	je     8020c1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020b3:	c1 ea 0c             	shr    $0xc,%edx
  8020b6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020bd:	ef 
  8020be:	0f b7 c0             	movzwl %ax,%eax
}
  8020c1:	5d                   	pop    %ebp
  8020c2:	c3                   	ret    
  8020c3:	66 90                	xchg   %ax,%ax
  8020c5:	66 90                	xchg   %ax,%ax
  8020c7:	66 90                	xchg   %ax,%ax
  8020c9:	66 90                	xchg   %ax,%ax
  8020cb:	66 90                	xchg   %ax,%ax
  8020cd:	66 90                	xchg   %ax,%ax
  8020cf:	90                   	nop

008020d0 <__udivdi3>:
  8020d0:	55                   	push   %ebp
  8020d1:	57                   	push   %edi
  8020d2:	56                   	push   %esi
  8020d3:	53                   	push   %ebx
  8020d4:	83 ec 1c             	sub    $0x1c,%esp
  8020d7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020db:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020df:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020e7:	85 f6                	test   %esi,%esi
  8020e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020ed:	89 ca                	mov    %ecx,%edx
  8020ef:	89 f8                	mov    %edi,%eax
  8020f1:	75 3d                	jne    802130 <__udivdi3+0x60>
  8020f3:	39 cf                	cmp    %ecx,%edi
  8020f5:	0f 87 c5 00 00 00    	ja     8021c0 <__udivdi3+0xf0>
  8020fb:	85 ff                	test   %edi,%edi
  8020fd:	89 fd                	mov    %edi,%ebp
  8020ff:	75 0b                	jne    80210c <__udivdi3+0x3c>
  802101:	b8 01 00 00 00       	mov    $0x1,%eax
  802106:	31 d2                	xor    %edx,%edx
  802108:	f7 f7                	div    %edi
  80210a:	89 c5                	mov    %eax,%ebp
  80210c:	89 c8                	mov    %ecx,%eax
  80210e:	31 d2                	xor    %edx,%edx
  802110:	f7 f5                	div    %ebp
  802112:	89 c1                	mov    %eax,%ecx
  802114:	89 d8                	mov    %ebx,%eax
  802116:	89 cf                	mov    %ecx,%edi
  802118:	f7 f5                	div    %ebp
  80211a:	89 c3                	mov    %eax,%ebx
  80211c:	89 d8                	mov    %ebx,%eax
  80211e:	89 fa                	mov    %edi,%edx
  802120:	83 c4 1c             	add    $0x1c,%esp
  802123:	5b                   	pop    %ebx
  802124:	5e                   	pop    %esi
  802125:	5f                   	pop    %edi
  802126:	5d                   	pop    %ebp
  802127:	c3                   	ret    
  802128:	90                   	nop
  802129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802130:	39 ce                	cmp    %ecx,%esi
  802132:	77 74                	ja     8021a8 <__udivdi3+0xd8>
  802134:	0f bd fe             	bsr    %esi,%edi
  802137:	83 f7 1f             	xor    $0x1f,%edi
  80213a:	0f 84 98 00 00 00    	je     8021d8 <__udivdi3+0x108>
  802140:	bb 20 00 00 00       	mov    $0x20,%ebx
  802145:	89 f9                	mov    %edi,%ecx
  802147:	89 c5                	mov    %eax,%ebp
  802149:	29 fb                	sub    %edi,%ebx
  80214b:	d3 e6                	shl    %cl,%esi
  80214d:	89 d9                	mov    %ebx,%ecx
  80214f:	d3 ed                	shr    %cl,%ebp
  802151:	89 f9                	mov    %edi,%ecx
  802153:	d3 e0                	shl    %cl,%eax
  802155:	09 ee                	or     %ebp,%esi
  802157:	89 d9                	mov    %ebx,%ecx
  802159:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80215d:	89 d5                	mov    %edx,%ebp
  80215f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802163:	d3 ed                	shr    %cl,%ebp
  802165:	89 f9                	mov    %edi,%ecx
  802167:	d3 e2                	shl    %cl,%edx
  802169:	89 d9                	mov    %ebx,%ecx
  80216b:	d3 e8                	shr    %cl,%eax
  80216d:	09 c2                	or     %eax,%edx
  80216f:	89 d0                	mov    %edx,%eax
  802171:	89 ea                	mov    %ebp,%edx
  802173:	f7 f6                	div    %esi
  802175:	89 d5                	mov    %edx,%ebp
  802177:	89 c3                	mov    %eax,%ebx
  802179:	f7 64 24 0c          	mull   0xc(%esp)
  80217d:	39 d5                	cmp    %edx,%ebp
  80217f:	72 10                	jb     802191 <__udivdi3+0xc1>
  802181:	8b 74 24 08          	mov    0x8(%esp),%esi
  802185:	89 f9                	mov    %edi,%ecx
  802187:	d3 e6                	shl    %cl,%esi
  802189:	39 c6                	cmp    %eax,%esi
  80218b:	73 07                	jae    802194 <__udivdi3+0xc4>
  80218d:	39 d5                	cmp    %edx,%ebp
  80218f:	75 03                	jne    802194 <__udivdi3+0xc4>
  802191:	83 eb 01             	sub    $0x1,%ebx
  802194:	31 ff                	xor    %edi,%edi
  802196:	89 d8                	mov    %ebx,%eax
  802198:	89 fa                	mov    %edi,%edx
  80219a:	83 c4 1c             	add    $0x1c,%esp
  80219d:	5b                   	pop    %ebx
  80219e:	5e                   	pop    %esi
  80219f:	5f                   	pop    %edi
  8021a0:	5d                   	pop    %ebp
  8021a1:	c3                   	ret    
  8021a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021a8:	31 ff                	xor    %edi,%edi
  8021aa:	31 db                	xor    %ebx,%ebx
  8021ac:	89 d8                	mov    %ebx,%eax
  8021ae:	89 fa                	mov    %edi,%edx
  8021b0:	83 c4 1c             	add    $0x1c,%esp
  8021b3:	5b                   	pop    %ebx
  8021b4:	5e                   	pop    %esi
  8021b5:	5f                   	pop    %edi
  8021b6:	5d                   	pop    %ebp
  8021b7:	c3                   	ret    
  8021b8:	90                   	nop
  8021b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	89 d8                	mov    %ebx,%eax
  8021c2:	f7 f7                	div    %edi
  8021c4:	31 ff                	xor    %edi,%edi
  8021c6:	89 c3                	mov    %eax,%ebx
  8021c8:	89 d8                	mov    %ebx,%eax
  8021ca:	89 fa                	mov    %edi,%edx
  8021cc:	83 c4 1c             	add    $0x1c,%esp
  8021cf:	5b                   	pop    %ebx
  8021d0:	5e                   	pop    %esi
  8021d1:	5f                   	pop    %edi
  8021d2:	5d                   	pop    %ebp
  8021d3:	c3                   	ret    
  8021d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021d8:	39 ce                	cmp    %ecx,%esi
  8021da:	72 0c                	jb     8021e8 <__udivdi3+0x118>
  8021dc:	31 db                	xor    %ebx,%ebx
  8021de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021e2:	0f 87 34 ff ff ff    	ja     80211c <__udivdi3+0x4c>
  8021e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021ed:	e9 2a ff ff ff       	jmp    80211c <__udivdi3+0x4c>
  8021f2:	66 90                	xchg   %ax,%ax
  8021f4:	66 90                	xchg   %ax,%ax
  8021f6:	66 90                	xchg   %ax,%ax
  8021f8:	66 90                	xchg   %ax,%ax
  8021fa:	66 90                	xchg   %ax,%ax
  8021fc:	66 90                	xchg   %ax,%ax
  8021fe:	66 90                	xchg   %ax,%ax

00802200 <__umoddi3>:
  802200:	55                   	push   %ebp
  802201:	57                   	push   %edi
  802202:	56                   	push   %esi
  802203:	53                   	push   %ebx
  802204:	83 ec 1c             	sub    $0x1c,%esp
  802207:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80220b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80220f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802213:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802217:	85 d2                	test   %edx,%edx
  802219:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80221d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802221:	89 f3                	mov    %esi,%ebx
  802223:	89 3c 24             	mov    %edi,(%esp)
  802226:	89 74 24 04          	mov    %esi,0x4(%esp)
  80222a:	75 1c                	jne    802248 <__umoddi3+0x48>
  80222c:	39 f7                	cmp    %esi,%edi
  80222e:	76 50                	jbe    802280 <__umoddi3+0x80>
  802230:	89 c8                	mov    %ecx,%eax
  802232:	89 f2                	mov    %esi,%edx
  802234:	f7 f7                	div    %edi
  802236:	89 d0                	mov    %edx,%eax
  802238:	31 d2                	xor    %edx,%edx
  80223a:	83 c4 1c             	add    $0x1c,%esp
  80223d:	5b                   	pop    %ebx
  80223e:	5e                   	pop    %esi
  80223f:	5f                   	pop    %edi
  802240:	5d                   	pop    %ebp
  802241:	c3                   	ret    
  802242:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802248:	39 f2                	cmp    %esi,%edx
  80224a:	89 d0                	mov    %edx,%eax
  80224c:	77 52                	ja     8022a0 <__umoddi3+0xa0>
  80224e:	0f bd ea             	bsr    %edx,%ebp
  802251:	83 f5 1f             	xor    $0x1f,%ebp
  802254:	75 5a                	jne    8022b0 <__umoddi3+0xb0>
  802256:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80225a:	0f 82 e0 00 00 00    	jb     802340 <__umoddi3+0x140>
  802260:	39 0c 24             	cmp    %ecx,(%esp)
  802263:	0f 86 d7 00 00 00    	jbe    802340 <__umoddi3+0x140>
  802269:	8b 44 24 08          	mov    0x8(%esp),%eax
  80226d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802271:	83 c4 1c             	add    $0x1c,%esp
  802274:	5b                   	pop    %ebx
  802275:	5e                   	pop    %esi
  802276:	5f                   	pop    %edi
  802277:	5d                   	pop    %ebp
  802278:	c3                   	ret    
  802279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802280:	85 ff                	test   %edi,%edi
  802282:	89 fd                	mov    %edi,%ebp
  802284:	75 0b                	jne    802291 <__umoddi3+0x91>
  802286:	b8 01 00 00 00       	mov    $0x1,%eax
  80228b:	31 d2                	xor    %edx,%edx
  80228d:	f7 f7                	div    %edi
  80228f:	89 c5                	mov    %eax,%ebp
  802291:	89 f0                	mov    %esi,%eax
  802293:	31 d2                	xor    %edx,%edx
  802295:	f7 f5                	div    %ebp
  802297:	89 c8                	mov    %ecx,%eax
  802299:	f7 f5                	div    %ebp
  80229b:	89 d0                	mov    %edx,%eax
  80229d:	eb 99                	jmp    802238 <__umoddi3+0x38>
  80229f:	90                   	nop
  8022a0:	89 c8                	mov    %ecx,%eax
  8022a2:	89 f2                	mov    %esi,%edx
  8022a4:	83 c4 1c             	add    $0x1c,%esp
  8022a7:	5b                   	pop    %ebx
  8022a8:	5e                   	pop    %esi
  8022a9:	5f                   	pop    %edi
  8022aa:	5d                   	pop    %ebp
  8022ab:	c3                   	ret    
  8022ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022b0:	8b 34 24             	mov    (%esp),%esi
  8022b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022b8:	89 e9                	mov    %ebp,%ecx
  8022ba:	29 ef                	sub    %ebp,%edi
  8022bc:	d3 e0                	shl    %cl,%eax
  8022be:	89 f9                	mov    %edi,%ecx
  8022c0:	89 f2                	mov    %esi,%edx
  8022c2:	d3 ea                	shr    %cl,%edx
  8022c4:	89 e9                	mov    %ebp,%ecx
  8022c6:	09 c2                	or     %eax,%edx
  8022c8:	89 d8                	mov    %ebx,%eax
  8022ca:	89 14 24             	mov    %edx,(%esp)
  8022cd:	89 f2                	mov    %esi,%edx
  8022cf:	d3 e2                	shl    %cl,%edx
  8022d1:	89 f9                	mov    %edi,%ecx
  8022d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022db:	d3 e8                	shr    %cl,%eax
  8022dd:	89 e9                	mov    %ebp,%ecx
  8022df:	89 c6                	mov    %eax,%esi
  8022e1:	d3 e3                	shl    %cl,%ebx
  8022e3:	89 f9                	mov    %edi,%ecx
  8022e5:	89 d0                	mov    %edx,%eax
  8022e7:	d3 e8                	shr    %cl,%eax
  8022e9:	89 e9                	mov    %ebp,%ecx
  8022eb:	09 d8                	or     %ebx,%eax
  8022ed:	89 d3                	mov    %edx,%ebx
  8022ef:	89 f2                	mov    %esi,%edx
  8022f1:	f7 34 24             	divl   (%esp)
  8022f4:	89 d6                	mov    %edx,%esi
  8022f6:	d3 e3                	shl    %cl,%ebx
  8022f8:	f7 64 24 04          	mull   0x4(%esp)
  8022fc:	39 d6                	cmp    %edx,%esi
  8022fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802302:	89 d1                	mov    %edx,%ecx
  802304:	89 c3                	mov    %eax,%ebx
  802306:	72 08                	jb     802310 <__umoddi3+0x110>
  802308:	75 11                	jne    80231b <__umoddi3+0x11b>
  80230a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80230e:	73 0b                	jae    80231b <__umoddi3+0x11b>
  802310:	2b 44 24 04          	sub    0x4(%esp),%eax
  802314:	1b 14 24             	sbb    (%esp),%edx
  802317:	89 d1                	mov    %edx,%ecx
  802319:	89 c3                	mov    %eax,%ebx
  80231b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80231f:	29 da                	sub    %ebx,%edx
  802321:	19 ce                	sbb    %ecx,%esi
  802323:	89 f9                	mov    %edi,%ecx
  802325:	89 f0                	mov    %esi,%eax
  802327:	d3 e0                	shl    %cl,%eax
  802329:	89 e9                	mov    %ebp,%ecx
  80232b:	d3 ea                	shr    %cl,%edx
  80232d:	89 e9                	mov    %ebp,%ecx
  80232f:	d3 ee                	shr    %cl,%esi
  802331:	09 d0                	or     %edx,%eax
  802333:	89 f2                	mov    %esi,%edx
  802335:	83 c4 1c             	add    $0x1c,%esp
  802338:	5b                   	pop    %ebx
  802339:	5e                   	pop    %esi
  80233a:	5f                   	pop    %edi
  80233b:	5d                   	pop    %ebp
  80233c:	c3                   	ret    
  80233d:	8d 76 00             	lea    0x0(%esi),%esi
  802340:	29 f9                	sub    %edi,%ecx
  802342:	19 d6                	sbb    %edx,%esi
  802344:	89 74 24 04          	mov    %esi,0x4(%esp)
  802348:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80234c:	e9 18 ff ff ff       	jmp    802269 <__umoddi3+0x69>
