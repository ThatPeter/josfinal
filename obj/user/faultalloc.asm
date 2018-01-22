
obj/user/faultalloc.debug:     file format elf32-i386


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
  80002c:	e8 99 00 00 00       	call   8000ca <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 60 1f 80 00       	push   $0x801f60
  800045:	e8 19 02 00 00       	call   800263 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 8d 0b 00 00       	call   800beb <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 80 1f 80 00       	push   $0x801f80
  80006f:	6a 0e                	push   $0xe
  800071:	68 6a 1f 80 00       	push   $0x801f6a
  800076:	e8 0f 01 00 00       	call   80018a <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 ac 1f 80 00       	push   $0x801fac
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 0c 07 00 00       	call   800795 <snprintf>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 5b 0d 00 00       	call   800dfc <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 7c 1f 80 00       	push   $0x801f7c
  8000ae:	e8 b0 01 00 00       	call   800263 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 7c 1f 80 00       	push   $0x801f7c
  8000c0:	e8 9e 01 00 00       	call   800263 <cprintf>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
  8000d0:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000d3:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  8000da:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  8000dd:	e8 cb 0a 00 00       	call   800bad <sys_getenvid>
  8000e2:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  8000e4:	83 ec 08             	sub    $0x8,%esp
  8000e7:	50                   	push   %eax
  8000e8:	68 d0 1f 80 00       	push   $0x801fd0
  8000ed:	e8 71 01 00 00       	call   800263 <cprintf>
  8000f2:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  8000f8:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8000fd:	83 c4 10             	add    $0x10,%esp
  800100:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800105:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  80010a:	89 c1                	mov    %eax,%ecx
  80010c:	c1 e1 07             	shl    $0x7,%ecx
  80010f:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  800116:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  800119:	39 cb                	cmp    %ecx,%ebx
  80011b:	0f 44 fa             	cmove  %edx,%edi
  80011e:	b9 01 00 00 00       	mov    $0x1,%ecx
  800123:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  800126:	83 c0 01             	add    $0x1,%eax
  800129:	81 c2 84 00 00 00    	add    $0x84,%edx
  80012f:	3d 00 04 00 00       	cmp    $0x400,%eax
  800134:	75 d4                	jne    80010a <libmain+0x40>
  800136:	89 f0                	mov    %esi,%eax
  800138:	84 c0                	test   %al,%al
  80013a:	74 06                	je     800142 <libmain+0x78>
  80013c:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800142:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800146:	7e 0a                	jle    800152 <libmain+0x88>
		binaryname = argv[0];
  800148:	8b 45 0c             	mov    0xc(%ebp),%eax
  80014b:	8b 00                	mov    (%eax),%eax
  80014d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800152:	83 ec 08             	sub    $0x8,%esp
  800155:	ff 75 0c             	pushl  0xc(%ebp)
  800158:	ff 75 08             	pushl  0x8(%ebp)
  80015b:	e8 31 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  800160:	e8 0b 00 00 00       	call   800170 <exit>
}
  800165:	83 c4 10             	add    $0x10,%esp
  800168:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80016b:	5b                   	pop    %ebx
  80016c:	5e                   	pop    %esi
  80016d:	5f                   	pop    %edi
  80016e:	5d                   	pop    %ebp
  80016f:	c3                   	ret    

00800170 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800176:	e8 db 0e 00 00       	call   801056 <close_all>
	sys_env_destroy(0);
  80017b:	83 ec 0c             	sub    $0xc,%esp
  80017e:	6a 00                	push   $0x0
  800180:	e8 e7 09 00 00       	call   800b6c <sys_env_destroy>
}
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	c9                   	leave  
  800189:	c3                   	ret    

0080018a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80018a:	55                   	push   %ebp
  80018b:	89 e5                	mov    %esp,%ebp
  80018d:	56                   	push   %esi
  80018e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80018f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800192:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800198:	e8 10 0a 00 00       	call   800bad <sys_getenvid>
  80019d:	83 ec 0c             	sub    $0xc,%esp
  8001a0:	ff 75 0c             	pushl  0xc(%ebp)
  8001a3:	ff 75 08             	pushl  0x8(%ebp)
  8001a6:	56                   	push   %esi
  8001a7:	50                   	push   %eax
  8001a8:	68 fc 1f 80 00       	push   $0x801ffc
  8001ad:	e8 b1 00 00 00       	call   800263 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b2:	83 c4 18             	add    $0x18,%esp
  8001b5:	53                   	push   %ebx
  8001b6:	ff 75 10             	pushl  0x10(%ebp)
  8001b9:	e8 54 00 00 00       	call   800212 <vcprintf>
	cprintf("\n");
  8001be:	c7 04 24 37 24 80 00 	movl   $0x802437,(%esp)
  8001c5:	e8 99 00 00 00       	call   800263 <cprintf>
  8001ca:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001cd:	cc                   	int3   
  8001ce:	eb fd                	jmp    8001cd <_panic+0x43>

008001d0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	53                   	push   %ebx
  8001d4:	83 ec 04             	sub    $0x4,%esp
  8001d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001da:	8b 13                	mov    (%ebx),%edx
  8001dc:	8d 42 01             	lea    0x1(%edx),%eax
  8001df:	89 03                	mov    %eax,(%ebx)
  8001e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001e8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ed:	75 1a                	jne    800209 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001ef:	83 ec 08             	sub    $0x8,%esp
  8001f2:	68 ff 00 00 00       	push   $0xff
  8001f7:	8d 43 08             	lea    0x8(%ebx),%eax
  8001fa:	50                   	push   %eax
  8001fb:	e8 2f 09 00 00       	call   800b2f <sys_cputs>
		b->idx = 0;
  800200:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800206:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800209:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80020d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800210:	c9                   	leave  
  800211:	c3                   	ret    

00800212 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80021b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800222:	00 00 00 
	b.cnt = 0;
  800225:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80022c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80022f:	ff 75 0c             	pushl  0xc(%ebp)
  800232:	ff 75 08             	pushl  0x8(%ebp)
  800235:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80023b:	50                   	push   %eax
  80023c:	68 d0 01 80 00       	push   $0x8001d0
  800241:	e8 54 01 00 00       	call   80039a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800246:	83 c4 08             	add    $0x8,%esp
  800249:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80024f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800255:	50                   	push   %eax
  800256:	e8 d4 08 00 00       	call   800b2f <sys_cputs>

	return b.cnt;
}
  80025b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800261:	c9                   	leave  
  800262:	c3                   	ret    

00800263 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800269:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80026c:	50                   	push   %eax
  80026d:	ff 75 08             	pushl  0x8(%ebp)
  800270:	e8 9d ff ff ff       	call   800212 <vcprintf>
	va_end(ap);

	return cnt;
}
  800275:	c9                   	leave  
  800276:	c3                   	ret    

00800277 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
  80027a:	57                   	push   %edi
  80027b:	56                   	push   %esi
  80027c:	53                   	push   %ebx
  80027d:	83 ec 1c             	sub    $0x1c,%esp
  800280:	89 c7                	mov    %eax,%edi
  800282:	89 d6                	mov    %edx,%esi
  800284:	8b 45 08             	mov    0x8(%ebp),%eax
  800287:	8b 55 0c             	mov    0xc(%ebp),%edx
  80028a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80028d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800290:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800293:	bb 00 00 00 00       	mov    $0x0,%ebx
  800298:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80029b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80029e:	39 d3                	cmp    %edx,%ebx
  8002a0:	72 05                	jb     8002a7 <printnum+0x30>
  8002a2:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002a5:	77 45                	ja     8002ec <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002a7:	83 ec 0c             	sub    $0xc,%esp
  8002aa:	ff 75 18             	pushl  0x18(%ebp)
  8002ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8002b0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002b3:	53                   	push   %ebx
  8002b4:	ff 75 10             	pushl  0x10(%ebp)
  8002b7:	83 ec 08             	sub    $0x8,%esp
  8002ba:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002bd:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c0:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c3:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c6:	e8 05 1a 00 00       	call   801cd0 <__udivdi3>
  8002cb:	83 c4 18             	add    $0x18,%esp
  8002ce:	52                   	push   %edx
  8002cf:	50                   	push   %eax
  8002d0:	89 f2                	mov    %esi,%edx
  8002d2:	89 f8                	mov    %edi,%eax
  8002d4:	e8 9e ff ff ff       	call   800277 <printnum>
  8002d9:	83 c4 20             	add    $0x20,%esp
  8002dc:	eb 18                	jmp    8002f6 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002de:	83 ec 08             	sub    $0x8,%esp
  8002e1:	56                   	push   %esi
  8002e2:	ff 75 18             	pushl  0x18(%ebp)
  8002e5:	ff d7                	call   *%edi
  8002e7:	83 c4 10             	add    $0x10,%esp
  8002ea:	eb 03                	jmp    8002ef <printnum+0x78>
  8002ec:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ef:	83 eb 01             	sub    $0x1,%ebx
  8002f2:	85 db                	test   %ebx,%ebx
  8002f4:	7f e8                	jg     8002de <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002f6:	83 ec 08             	sub    $0x8,%esp
  8002f9:	56                   	push   %esi
  8002fa:	83 ec 04             	sub    $0x4,%esp
  8002fd:	ff 75 e4             	pushl  -0x1c(%ebp)
  800300:	ff 75 e0             	pushl  -0x20(%ebp)
  800303:	ff 75 dc             	pushl  -0x24(%ebp)
  800306:	ff 75 d8             	pushl  -0x28(%ebp)
  800309:	e8 f2 1a 00 00       	call   801e00 <__umoddi3>
  80030e:	83 c4 14             	add    $0x14,%esp
  800311:	0f be 80 1f 20 80 00 	movsbl 0x80201f(%eax),%eax
  800318:	50                   	push   %eax
  800319:	ff d7                	call   *%edi
}
  80031b:	83 c4 10             	add    $0x10,%esp
  80031e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800321:	5b                   	pop    %ebx
  800322:	5e                   	pop    %esi
  800323:	5f                   	pop    %edi
  800324:	5d                   	pop    %ebp
  800325:	c3                   	ret    

00800326 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800326:	55                   	push   %ebp
  800327:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800329:	83 fa 01             	cmp    $0x1,%edx
  80032c:	7e 0e                	jle    80033c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80032e:	8b 10                	mov    (%eax),%edx
  800330:	8d 4a 08             	lea    0x8(%edx),%ecx
  800333:	89 08                	mov    %ecx,(%eax)
  800335:	8b 02                	mov    (%edx),%eax
  800337:	8b 52 04             	mov    0x4(%edx),%edx
  80033a:	eb 22                	jmp    80035e <getuint+0x38>
	else if (lflag)
  80033c:	85 d2                	test   %edx,%edx
  80033e:	74 10                	je     800350 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800340:	8b 10                	mov    (%eax),%edx
  800342:	8d 4a 04             	lea    0x4(%edx),%ecx
  800345:	89 08                	mov    %ecx,(%eax)
  800347:	8b 02                	mov    (%edx),%eax
  800349:	ba 00 00 00 00       	mov    $0x0,%edx
  80034e:	eb 0e                	jmp    80035e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800350:	8b 10                	mov    (%eax),%edx
  800352:	8d 4a 04             	lea    0x4(%edx),%ecx
  800355:	89 08                	mov    %ecx,(%eax)
  800357:	8b 02                	mov    (%edx),%eax
  800359:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80035e:	5d                   	pop    %ebp
  80035f:	c3                   	ret    

00800360 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
  800363:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800366:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80036a:	8b 10                	mov    (%eax),%edx
  80036c:	3b 50 04             	cmp    0x4(%eax),%edx
  80036f:	73 0a                	jae    80037b <sprintputch+0x1b>
		*b->buf++ = ch;
  800371:	8d 4a 01             	lea    0x1(%edx),%ecx
  800374:	89 08                	mov    %ecx,(%eax)
  800376:	8b 45 08             	mov    0x8(%ebp),%eax
  800379:	88 02                	mov    %al,(%edx)
}
  80037b:	5d                   	pop    %ebp
  80037c:	c3                   	ret    

0080037d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80037d:	55                   	push   %ebp
  80037e:	89 e5                	mov    %esp,%ebp
  800380:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800383:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800386:	50                   	push   %eax
  800387:	ff 75 10             	pushl  0x10(%ebp)
  80038a:	ff 75 0c             	pushl  0xc(%ebp)
  80038d:	ff 75 08             	pushl  0x8(%ebp)
  800390:	e8 05 00 00 00       	call   80039a <vprintfmt>
	va_end(ap);
}
  800395:	83 c4 10             	add    $0x10,%esp
  800398:	c9                   	leave  
  800399:	c3                   	ret    

0080039a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	57                   	push   %edi
  80039e:	56                   	push   %esi
  80039f:	53                   	push   %ebx
  8003a0:	83 ec 2c             	sub    $0x2c,%esp
  8003a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8003a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003a9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003ac:	eb 12                	jmp    8003c0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003ae:	85 c0                	test   %eax,%eax
  8003b0:	0f 84 89 03 00 00    	je     80073f <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8003b6:	83 ec 08             	sub    $0x8,%esp
  8003b9:	53                   	push   %ebx
  8003ba:	50                   	push   %eax
  8003bb:	ff d6                	call   *%esi
  8003bd:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c0:	83 c7 01             	add    $0x1,%edi
  8003c3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003c7:	83 f8 25             	cmp    $0x25,%eax
  8003ca:	75 e2                	jne    8003ae <vprintfmt+0x14>
  8003cc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003d0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003d7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003de:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ea:	eb 07                	jmp    8003f3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003ef:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f3:	8d 47 01             	lea    0x1(%edi),%eax
  8003f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003f9:	0f b6 07             	movzbl (%edi),%eax
  8003fc:	0f b6 c8             	movzbl %al,%ecx
  8003ff:	83 e8 23             	sub    $0x23,%eax
  800402:	3c 55                	cmp    $0x55,%al
  800404:	0f 87 1a 03 00 00    	ja     800724 <vprintfmt+0x38a>
  80040a:	0f b6 c0             	movzbl %al,%eax
  80040d:	ff 24 85 60 21 80 00 	jmp    *0x802160(,%eax,4)
  800414:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800417:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80041b:	eb d6                	jmp    8003f3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800420:	b8 00 00 00 00       	mov    $0x0,%eax
  800425:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800428:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80042b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80042f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800432:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800435:	83 fa 09             	cmp    $0x9,%edx
  800438:	77 39                	ja     800473 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80043a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80043d:	eb e9                	jmp    800428 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80043f:	8b 45 14             	mov    0x14(%ebp),%eax
  800442:	8d 48 04             	lea    0x4(%eax),%ecx
  800445:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800448:	8b 00                	mov    (%eax),%eax
  80044a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800450:	eb 27                	jmp    800479 <vprintfmt+0xdf>
  800452:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800455:	85 c0                	test   %eax,%eax
  800457:	b9 00 00 00 00       	mov    $0x0,%ecx
  80045c:	0f 49 c8             	cmovns %eax,%ecx
  80045f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800462:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800465:	eb 8c                	jmp    8003f3 <vprintfmt+0x59>
  800467:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80046a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800471:	eb 80                	jmp    8003f3 <vprintfmt+0x59>
  800473:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800476:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800479:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80047d:	0f 89 70 ff ff ff    	jns    8003f3 <vprintfmt+0x59>
				width = precision, precision = -1;
  800483:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800486:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800489:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800490:	e9 5e ff ff ff       	jmp    8003f3 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800495:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800498:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80049b:	e9 53 ff ff ff       	jmp    8003f3 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a3:	8d 50 04             	lea    0x4(%eax),%edx
  8004a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a9:	83 ec 08             	sub    $0x8,%esp
  8004ac:	53                   	push   %ebx
  8004ad:	ff 30                	pushl  (%eax)
  8004af:	ff d6                	call   *%esi
			break;
  8004b1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004b7:	e9 04 ff ff ff       	jmp    8003c0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bf:	8d 50 04             	lea    0x4(%eax),%edx
  8004c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c5:	8b 00                	mov    (%eax),%eax
  8004c7:	99                   	cltd   
  8004c8:	31 d0                	xor    %edx,%eax
  8004ca:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004cc:	83 f8 0f             	cmp    $0xf,%eax
  8004cf:	7f 0b                	jg     8004dc <vprintfmt+0x142>
  8004d1:	8b 14 85 c0 22 80 00 	mov    0x8022c0(,%eax,4),%edx
  8004d8:	85 d2                	test   %edx,%edx
  8004da:	75 18                	jne    8004f4 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004dc:	50                   	push   %eax
  8004dd:	68 37 20 80 00       	push   $0x802037
  8004e2:	53                   	push   %ebx
  8004e3:	56                   	push   %esi
  8004e4:	e8 94 fe ff ff       	call   80037d <printfmt>
  8004e9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004ef:	e9 cc fe ff ff       	jmp    8003c0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004f4:	52                   	push   %edx
  8004f5:	68 05 24 80 00       	push   $0x802405
  8004fa:	53                   	push   %ebx
  8004fb:	56                   	push   %esi
  8004fc:	e8 7c fe ff ff       	call   80037d <printfmt>
  800501:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800504:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800507:	e9 b4 fe ff ff       	jmp    8003c0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80050c:	8b 45 14             	mov    0x14(%ebp),%eax
  80050f:	8d 50 04             	lea    0x4(%eax),%edx
  800512:	89 55 14             	mov    %edx,0x14(%ebp)
  800515:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800517:	85 ff                	test   %edi,%edi
  800519:	b8 30 20 80 00       	mov    $0x802030,%eax
  80051e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800521:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800525:	0f 8e 94 00 00 00    	jle    8005bf <vprintfmt+0x225>
  80052b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80052f:	0f 84 98 00 00 00    	je     8005cd <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800535:	83 ec 08             	sub    $0x8,%esp
  800538:	ff 75 d0             	pushl  -0x30(%ebp)
  80053b:	57                   	push   %edi
  80053c:	e8 86 02 00 00       	call   8007c7 <strnlen>
  800541:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800544:	29 c1                	sub    %eax,%ecx
  800546:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800549:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80054c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800550:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800553:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800556:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800558:	eb 0f                	jmp    800569 <vprintfmt+0x1cf>
					putch(padc, putdat);
  80055a:	83 ec 08             	sub    $0x8,%esp
  80055d:	53                   	push   %ebx
  80055e:	ff 75 e0             	pushl  -0x20(%ebp)
  800561:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800563:	83 ef 01             	sub    $0x1,%edi
  800566:	83 c4 10             	add    $0x10,%esp
  800569:	85 ff                	test   %edi,%edi
  80056b:	7f ed                	jg     80055a <vprintfmt+0x1c0>
  80056d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800570:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800573:	85 c9                	test   %ecx,%ecx
  800575:	b8 00 00 00 00       	mov    $0x0,%eax
  80057a:	0f 49 c1             	cmovns %ecx,%eax
  80057d:	29 c1                	sub    %eax,%ecx
  80057f:	89 75 08             	mov    %esi,0x8(%ebp)
  800582:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800585:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800588:	89 cb                	mov    %ecx,%ebx
  80058a:	eb 4d                	jmp    8005d9 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80058c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800590:	74 1b                	je     8005ad <vprintfmt+0x213>
  800592:	0f be c0             	movsbl %al,%eax
  800595:	83 e8 20             	sub    $0x20,%eax
  800598:	83 f8 5e             	cmp    $0x5e,%eax
  80059b:	76 10                	jbe    8005ad <vprintfmt+0x213>
					putch('?', putdat);
  80059d:	83 ec 08             	sub    $0x8,%esp
  8005a0:	ff 75 0c             	pushl  0xc(%ebp)
  8005a3:	6a 3f                	push   $0x3f
  8005a5:	ff 55 08             	call   *0x8(%ebp)
  8005a8:	83 c4 10             	add    $0x10,%esp
  8005ab:	eb 0d                	jmp    8005ba <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005ad:	83 ec 08             	sub    $0x8,%esp
  8005b0:	ff 75 0c             	pushl  0xc(%ebp)
  8005b3:	52                   	push   %edx
  8005b4:	ff 55 08             	call   *0x8(%ebp)
  8005b7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ba:	83 eb 01             	sub    $0x1,%ebx
  8005bd:	eb 1a                	jmp    8005d9 <vprintfmt+0x23f>
  8005bf:	89 75 08             	mov    %esi,0x8(%ebp)
  8005c2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005c5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005c8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005cb:	eb 0c                	jmp    8005d9 <vprintfmt+0x23f>
  8005cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005d9:	83 c7 01             	add    $0x1,%edi
  8005dc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005e0:	0f be d0             	movsbl %al,%edx
  8005e3:	85 d2                	test   %edx,%edx
  8005e5:	74 23                	je     80060a <vprintfmt+0x270>
  8005e7:	85 f6                	test   %esi,%esi
  8005e9:	78 a1                	js     80058c <vprintfmt+0x1f2>
  8005eb:	83 ee 01             	sub    $0x1,%esi
  8005ee:	79 9c                	jns    80058c <vprintfmt+0x1f2>
  8005f0:	89 df                	mov    %ebx,%edi
  8005f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8005f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005f8:	eb 18                	jmp    800612 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005fa:	83 ec 08             	sub    $0x8,%esp
  8005fd:	53                   	push   %ebx
  8005fe:	6a 20                	push   $0x20
  800600:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800602:	83 ef 01             	sub    $0x1,%edi
  800605:	83 c4 10             	add    $0x10,%esp
  800608:	eb 08                	jmp    800612 <vprintfmt+0x278>
  80060a:	89 df                	mov    %ebx,%edi
  80060c:	8b 75 08             	mov    0x8(%ebp),%esi
  80060f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800612:	85 ff                	test   %edi,%edi
  800614:	7f e4                	jg     8005fa <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800616:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800619:	e9 a2 fd ff ff       	jmp    8003c0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80061e:	83 fa 01             	cmp    $0x1,%edx
  800621:	7e 16                	jle    800639 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8d 50 08             	lea    0x8(%eax),%edx
  800629:	89 55 14             	mov    %edx,0x14(%ebp)
  80062c:	8b 50 04             	mov    0x4(%eax),%edx
  80062f:	8b 00                	mov    (%eax),%eax
  800631:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800634:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800637:	eb 32                	jmp    80066b <vprintfmt+0x2d1>
	else if (lflag)
  800639:	85 d2                	test   %edx,%edx
  80063b:	74 18                	je     800655 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80063d:	8b 45 14             	mov    0x14(%ebp),%eax
  800640:	8d 50 04             	lea    0x4(%eax),%edx
  800643:	89 55 14             	mov    %edx,0x14(%ebp)
  800646:	8b 00                	mov    (%eax),%eax
  800648:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80064b:	89 c1                	mov    %eax,%ecx
  80064d:	c1 f9 1f             	sar    $0x1f,%ecx
  800650:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800653:	eb 16                	jmp    80066b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800655:	8b 45 14             	mov    0x14(%ebp),%eax
  800658:	8d 50 04             	lea    0x4(%eax),%edx
  80065b:	89 55 14             	mov    %edx,0x14(%ebp)
  80065e:	8b 00                	mov    (%eax),%eax
  800660:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800663:	89 c1                	mov    %eax,%ecx
  800665:	c1 f9 1f             	sar    $0x1f,%ecx
  800668:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80066b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80066e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800671:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800676:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80067a:	79 74                	jns    8006f0 <vprintfmt+0x356>
				putch('-', putdat);
  80067c:	83 ec 08             	sub    $0x8,%esp
  80067f:	53                   	push   %ebx
  800680:	6a 2d                	push   $0x2d
  800682:	ff d6                	call   *%esi
				num = -(long long) num;
  800684:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800687:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80068a:	f7 d8                	neg    %eax
  80068c:	83 d2 00             	adc    $0x0,%edx
  80068f:	f7 da                	neg    %edx
  800691:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800694:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800699:	eb 55                	jmp    8006f0 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80069b:	8d 45 14             	lea    0x14(%ebp),%eax
  80069e:	e8 83 fc ff ff       	call   800326 <getuint>
			base = 10;
  8006a3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006a8:	eb 46                	jmp    8006f0 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006aa:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ad:	e8 74 fc ff ff       	call   800326 <getuint>
			base = 8;
  8006b2:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006b7:	eb 37                	jmp    8006f0 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8006b9:	83 ec 08             	sub    $0x8,%esp
  8006bc:	53                   	push   %ebx
  8006bd:	6a 30                	push   $0x30
  8006bf:	ff d6                	call   *%esi
			putch('x', putdat);
  8006c1:	83 c4 08             	add    $0x8,%esp
  8006c4:	53                   	push   %ebx
  8006c5:	6a 78                	push   $0x78
  8006c7:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cc:	8d 50 04             	lea    0x4(%eax),%edx
  8006cf:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006d2:	8b 00                	mov    (%eax),%eax
  8006d4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006d9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006dc:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006e1:	eb 0d                	jmp    8006f0 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006e3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e6:	e8 3b fc ff ff       	call   800326 <getuint>
			base = 16;
  8006eb:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f0:	83 ec 0c             	sub    $0xc,%esp
  8006f3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006f7:	57                   	push   %edi
  8006f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006fb:	51                   	push   %ecx
  8006fc:	52                   	push   %edx
  8006fd:	50                   	push   %eax
  8006fe:	89 da                	mov    %ebx,%edx
  800700:	89 f0                	mov    %esi,%eax
  800702:	e8 70 fb ff ff       	call   800277 <printnum>
			break;
  800707:	83 c4 20             	add    $0x20,%esp
  80070a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80070d:	e9 ae fc ff ff       	jmp    8003c0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800712:	83 ec 08             	sub    $0x8,%esp
  800715:	53                   	push   %ebx
  800716:	51                   	push   %ecx
  800717:	ff d6                	call   *%esi
			break;
  800719:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80071f:	e9 9c fc ff ff       	jmp    8003c0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	53                   	push   %ebx
  800728:	6a 25                	push   $0x25
  80072a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80072c:	83 c4 10             	add    $0x10,%esp
  80072f:	eb 03                	jmp    800734 <vprintfmt+0x39a>
  800731:	83 ef 01             	sub    $0x1,%edi
  800734:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800738:	75 f7                	jne    800731 <vprintfmt+0x397>
  80073a:	e9 81 fc ff ff       	jmp    8003c0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80073f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800742:	5b                   	pop    %ebx
  800743:	5e                   	pop    %esi
  800744:	5f                   	pop    %edi
  800745:	5d                   	pop    %ebp
  800746:	c3                   	ret    

00800747 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	83 ec 18             	sub    $0x18,%esp
  80074d:	8b 45 08             	mov    0x8(%ebp),%eax
  800750:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800753:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800756:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80075a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80075d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800764:	85 c0                	test   %eax,%eax
  800766:	74 26                	je     80078e <vsnprintf+0x47>
  800768:	85 d2                	test   %edx,%edx
  80076a:	7e 22                	jle    80078e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80076c:	ff 75 14             	pushl  0x14(%ebp)
  80076f:	ff 75 10             	pushl  0x10(%ebp)
  800772:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800775:	50                   	push   %eax
  800776:	68 60 03 80 00       	push   $0x800360
  80077b:	e8 1a fc ff ff       	call   80039a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800780:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800783:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800786:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800789:	83 c4 10             	add    $0x10,%esp
  80078c:	eb 05                	jmp    800793 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80078e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800793:	c9                   	leave  
  800794:	c3                   	ret    

00800795 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80079b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80079e:	50                   	push   %eax
  80079f:	ff 75 10             	pushl  0x10(%ebp)
  8007a2:	ff 75 0c             	pushl  0xc(%ebp)
  8007a5:	ff 75 08             	pushl  0x8(%ebp)
  8007a8:	e8 9a ff ff ff       	call   800747 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ad:	c9                   	leave  
  8007ae:	c3                   	ret    

008007af <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ba:	eb 03                	jmp    8007bf <strlen+0x10>
		n++;
  8007bc:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007bf:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007c3:	75 f7                	jne    8007bc <strlen+0xd>
		n++;
	return n;
}
  8007c5:	5d                   	pop    %ebp
  8007c6:	c3                   	ret    

008007c7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007cd:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8007d5:	eb 03                	jmp    8007da <strnlen+0x13>
		n++;
  8007d7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007da:	39 c2                	cmp    %eax,%edx
  8007dc:	74 08                	je     8007e6 <strnlen+0x1f>
  8007de:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007e2:	75 f3                	jne    8007d7 <strnlen+0x10>
  8007e4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007e6:	5d                   	pop    %ebp
  8007e7:	c3                   	ret    

008007e8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	53                   	push   %ebx
  8007ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f2:	89 c2                	mov    %eax,%edx
  8007f4:	83 c2 01             	add    $0x1,%edx
  8007f7:	83 c1 01             	add    $0x1,%ecx
  8007fa:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007fe:	88 5a ff             	mov    %bl,-0x1(%edx)
  800801:	84 db                	test   %bl,%bl
  800803:	75 ef                	jne    8007f4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800805:	5b                   	pop    %ebx
  800806:	5d                   	pop    %ebp
  800807:	c3                   	ret    

00800808 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	53                   	push   %ebx
  80080c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80080f:	53                   	push   %ebx
  800810:	e8 9a ff ff ff       	call   8007af <strlen>
  800815:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800818:	ff 75 0c             	pushl  0xc(%ebp)
  80081b:	01 d8                	add    %ebx,%eax
  80081d:	50                   	push   %eax
  80081e:	e8 c5 ff ff ff       	call   8007e8 <strcpy>
	return dst;
}
  800823:	89 d8                	mov    %ebx,%eax
  800825:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800828:	c9                   	leave  
  800829:	c3                   	ret    

0080082a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	56                   	push   %esi
  80082e:	53                   	push   %ebx
  80082f:	8b 75 08             	mov    0x8(%ebp),%esi
  800832:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800835:	89 f3                	mov    %esi,%ebx
  800837:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80083a:	89 f2                	mov    %esi,%edx
  80083c:	eb 0f                	jmp    80084d <strncpy+0x23>
		*dst++ = *src;
  80083e:	83 c2 01             	add    $0x1,%edx
  800841:	0f b6 01             	movzbl (%ecx),%eax
  800844:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800847:	80 39 01             	cmpb   $0x1,(%ecx)
  80084a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084d:	39 da                	cmp    %ebx,%edx
  80084f:	75 ed                	jne    80083e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800851:	89 f0                	mov    %esi,%eax
  800853:	5b                   	pop    %ebx
  800854:	5e                   	pop    %esi
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	56                   	push   %esi
  80085b:	53                   	push   %ebx
  80085c:	8b 75 08             	mov    0x8(%ebp),%esi
  80085f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800862:	8b 55 10             	mov    0x10(%ebp),%edx
  800865:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800867:	85 d2                	test   %edx,%edx
  800869:	74 21                	je     80088c <strlcpy+0x35>
  80086b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80086f:	89 f2                	mov    %esi,%edx
  800871:	eb 09                	jmp    80087c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800873:	83 c2 01             	add    $0x1,%edx
  800876:	83 c1 01             	add    $0x1,%ecx
  800879:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80087c:	39 c2                	cmp    %eax,%edx
  80087e:	74 09                	je     800889 <strlcpy+0x32>
  800880:	0f b6 19             	movzbl (%ecx),%ebx
  800883:	84 db                	test   %bl,%bl
  800885:	75 ec                	jne    800873 <strlcpy+0x1c>
  800887:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800889:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80088c:	29 f0                	sub    %esi,%eax
}
  80088e:	5b                   	pop    %ebx
  80088f:	5e                   	pop    %esi
  800890:	5d                   	pop    %ebp
  800891:	c3                   	ret    

00800892 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800898:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80089b:	eb 06                	jmp    8008a3 <strcmp+0x11>
		p++, q++;
  80089d:	83 c1 01             	add    $0x1,%ecx
  8008a0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008a3:	0f b6 01             	movzbl (%ecx),%eax
  8008a6:	84 c0                	test   %al,%al
  8008a8:	74 04                	je     8008ae <strcmp+0x1c>
  8008aa:	3a 02                	cmp    (%edx),%al
  8008ac:	74 ef                	je     80089d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ae:	0f b6 c0             	movzbl %al,%eax
  8008b1:	0f b6 12             	movzbl (%edx),%edx
  8008b4:	29 d0                	sub    %edx,%eax
}
  8008b6:	5d                   	pop    %ebp
  8008b7:	c3                   	ret    

008008b8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	53                   	push   %ebx
  8008bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c2:	89 c3                	mov    %eax,%ebx
  8008c4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008c7:	eb 06                	jmp    8008cf <strncmp+0x17>
		n--, p++, q++;
  8008c9:	83 c0 01             	add    $0x1,%eax
  8008cc:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008cf:	39 d8                	cmp    %ebx,%eax
  8008d1:	74 15                	je     8008e8 <strncmp+0x30>
  8008d3:	0f b6 08             	movzbl (%eax),%ecx
  8008d6:	84 c9                	test   %cl,%cl
  8008d8:	74 04                	je     8008de <strncmp+0x26>
  8008da:	3a 0a                	cmp    (%edx),%cl
  8008dc:	74 eb                	je     8008c9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008de:	0f b6 00             	movzbl (%eax),%eax
  8008e1:	0f b6 12             	movzbl (%edx),%edx
  8008e4:	29 d0                	sub    %edx,%eax
  8008e6:	eb 05                	jmp    8008ed <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008e8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ed:	5b                   	pop    %ebx
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    

008008f0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008fa:	eb 07                	jmp    800903 <strchr+0x13>
		if (*s == c)
  8008fc:	38 ca                	cmp    %cl,%dl
  8008fe:	74 0f                	je     80090f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800900:	83 c0 01             	add    $0x1,%eax
  800903:	0f b6 10             	movzbl (%eax),%edx
  800906:	84 d2                	test   %dl,%dl
  800908:	75 f2                	jne    8008fc <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80090a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	8b 45 08             	mov    0x8(%ebp),%eax
  800917:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80091b:	eb 03                	jmp    800920 <strfind+0xf>
  80091d:	83 c0 01             	add    $0x1,%eax
  800920:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800923:	38 ca                	cmp    %cl,%dl
  800925:	74 04                	je     80092b <strfind+0x1a>
  800927:	84 d2                	test   %dl,%dl
  800929:	75 f2                	jne    80091d <strfind+0xc>
			break;
	return (char *) s;
}
  80092b:	5d                   	pop    %ebp
  80092c:	c3                   	ret    

0080092d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80092d:	55                   	push   %ebp
  80092e:	89 e5                	mov    %esp,%ebp
  800930:	57                   	push   %edi
  800931:	56                   	push   %esi
  800932:	53                   	push   %ebx
  800933:	8b 7d 08             	mov    0x8(%ebp),%edi
  800936:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800939:	85 c9                	test   %ecx,%ecx
  80093b:	74 36                	je     800973 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80093d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800943:	75 28                	jne    80096d <memset+0x40>
  800945:	f6 c1 03             	test   $0x3,%cl
  800948:	75 23                	jne    80096d <memset+0x40>
		c &= 0xFF;
  80094a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80094e:	89 d3                	mov    %edx,%ebx
  800950:	c1 e3 08             	shl    $0x8,%ebx
  800953:	89 d6                	mov    %edx,%esi
  800955:	c1 e6 18             	shl    $0x18,%esi
  800958:	89 d0                	mov    %edx,%eax
  80095a:	c1 e0 10             	shl    $0x10,%eax
  80095d:	09 f0                	or     %esi,%eax
  80095f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800961:	89 d8                	mov    %ebx,%eax
  800963:	09 d0                	or     %edx,%eax
  800965:	c1 e9 02             	shr    $0x2,%ecx
  800968:	fc                   	cld    
  800969:	f3 ab                	rep stos %eax,%es:(%edi)
  80096b:	eb 06                	jmp    800973 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80096d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800970:	fc                   	cld    
  800971:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800973:	89 f8                	mov    %edi,%eax
  800975:	5b                   	pop    %ebx
  800976:	5e                   	pop    %esi
  800977:	5f                   	pop    %edi
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	57                   	push   %edi
  80097e:	56                   	push   %esi
  80097f:	8b 45 08             	mov    0x8(%ebp),%eax
  800982:	8b 75 0c             	mov    0xc(%ebp),%esi
  800985:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800988:	39 c6                	cmp    %eax,%esi
  80098a:	73 35                	jae    8009c1 <memmove+0x47>
  80098c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80098f:	39 d0                	cmp    %edx,%eax
  800991:	73 2e                	jae    8009c1 <memmove+0x47>
		s += n;
		d += n;
  800993:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800996:	89 d6                	mov    %edx,%esi
  800998:	09 fe                	or     %edi,%esi
  80099a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a0:	75 13                	jne    8009b5 <memmove+0x3b>
  8009a2:	f6 c1 03             	test   $0x3,%cl
  8009a5:	75 0e                	jne    8009b5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009a7:	83 ef 04             	sub    $0x4,%edi
  8009aa:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009ad:	c1 e9 02             	shr    $0x2,%ecx
  8009b0:	fd                   	std    
  8009b1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b3:	eb 09                	jmp    8009be <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009b5:	83 ef 01             	sub    $0x1,%edi
  8009b8:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009bb:	fd                   	std    
  8009bc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009be:	fc                   	cld    
  8009bf:	eb 1d                	jmp    8009de <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c1:	89 f2                	mov    %esi,%edx
  8009c3:	09 c2                	or     %eax,%edx
  8009c5:	f6 c2 03             	test   $0x3,%dl
  8009c8:	75 0f                	jne    8009d9 <memmove+0x5f>
  8009ca:	f6 c1 03             	test   $0x3,%cl
  8009cd:	75 0a                	jne    8009d9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009cf:	c1 e9 02             	shr    $0x2,%ecx
  8009d2:	89 c7                	mov    %eax,%edi
  8009d4:	fc                   	cld    
  8009d5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d7:	eb 05                	jmp    8009de <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009d9:	89 c7                	mov    %eax,%edi
  8009db:	fc                   	cld    
  8009dc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009de:	5e                   	pop    %esi
  8009df:	5f                   	pop    %edi
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    

008009e2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009e5:	ff 75 10             	pushl  0x10(%ebp)
  8009e8:	ff 75 0c             	pushl  0xc(%ebp)
  8009eb:	ff 75 08             	pushl  0x8(%ebp)
  8009ee:	e8 87 ff ff ff       	call   80097a <memmove>
}
  8009f3:	c9                   	leave  
  8009f4:	c3                   	ret    

008009f5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
  8009f8:	56                   	push   %esi
  8009f9:	53                   	push   %ebx
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a00:	89 c6                	mov    %eax,%esi
  800a02:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a05:	eb 1a                	jmp    800a21 <memcmp+0x2c>
		if (*s1 != *s2)
  800a07:	0f b6 08             	movzbl (%eax),%ecx
  800a0a:	0f b6 1a             	movzbl (%edx),%ebx
  800a0d:	38 d9                	cmp    %bl,%cl
  800a0f:	74 0a                	je     800a1b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a11:	0f b6 c1             	movzbl %cl,%eax
  800a14:	0f b6 db             	movzbl %bl,%ebx
  800a17:	29 d8                	sub    %ebx,%eax
  800a19:	eb 0f                	jmp    800a2a <memcmp+0x35>
		s1++, s2++;
  800a1b:	83 c0 01             	add    $0x1,%eax
  800a1e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a21:	39 f0                	cmp    %esi,%eax
  800a23:	75 e2                	jne    800a07 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a25:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2a:	5b                   	pop    %ebx
  800a2b:	5e                   	pop    %esi
  800a2c:	5d                   	pop    %ebp
  800a2d:	c3                   	ret    

00800a2e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
  800a31:	53                   	push   %ebx
  800a32:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a35:	89 c1                	mov    %eax,%ecx
  800a37:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a3a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a3e:	eb 0a                	jmp    800a4a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a40:	0f b6 10             	movzbl (%eax),%edx
  800a43:	39 da                	cmp    %ebx,%edx
  800a45:	74 07                	je     800a4e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a47:	83 c0 01             	add    $0x1,%eax
  800a4a:	39 c8                	cmp    %ecx,%eax
  800a4c:	72 f2                	jb     800a40 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a4e:	5b                   	pop    %ebx
  800a4f:	5d                   	pop    %ebp
  800a50:	c3                   	ret    

00800a51 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	57                   	push   %edi
  800a55:	56                   	push   %esi
  800a56:	53                   	push   %ebx
  800a57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5d:	eb 03                	jmp    800a62 <strtol+0x11>
		s++;
  800a5f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a62:	0f b6 01             	movzbl (%ecx),%eax
  800a65:	3c 20                	cmp    $0x20,%al
  800a67:	74 f6                	je     800a5f <strtol+0xe>
  800a69:	3c 09                	cmp    $0x9,%al
  800a6b:	74 f2                	je     800a5f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a6d:	3c 2b                	cmp    $0x2b,%al
  800a6f:	75 0a                	jne    800a7b <strtol+0x2a>
		s++;
  800a71:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a74:	bf 00 00 00 00       	mov    $0x0,%edi
  800a79:	eb 11                	jmp    800a8c <strtol+0x3b>
  800a7b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a80:	3c 2d                	cmp    $0x2d,%al
  800a82:	75 08                	jne    800a8c <strtol+0x3b>
		s++, neg = 1;
  800a84:	83 c1 01             	add    $0x1,%ecx
  800a87:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a92:	75 15                	jne    800aa9 <strtol+0x58>
  800a94:	80 39 30             	cmpb   $0x30,(%ecx)
  800a97:	75 10                	jne    800aa9 <strtol+0x58>
  800a99:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a9d:	75 7c                	jne    800b1b <strtol+0xca>
		s += 2, base = 16;
  800a9f:	83 c1 02             	add    $0x2,%ecx
  800aa2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa7:	eb 16                	jmp    800abf <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800aa9:	85 db                	test   %ebx,%ebx
  800aab:	75 12                	jne    800abf <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aad:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab5:	75 08                	jne    800abf <strtol+0x6e>
		s++, base = 8;
  800ab7:	83 c1 01             	add    $0x1,%ecx
  800aba:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800abf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ac7:	0f b6 11             	movzbl (%ecx),%edx
  800aca:	8d 72 d0             	lea    -0x30(%edx),%esi
  800acd:	89 f3                	mov    %esi,%ebx
  800acf:	80 fb 09             	cmp    $0x9,%bl
  800ad2:	77 08                	ja     800adc <strtol+0x8b>
			dig = *s - '0';
  800ad4:	0f be d2             	movsbl %dl,%edx
  800ad7:	83 ea 30             	sub    $0x30,%edx
  800ada:	eb 22                	jmp    800afe <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800adc:	8d 72 9f             	lea    -0x61(%edx),%esi
  800adf:	89 f3                	mov    %esi,%ebx
  800ae1:	80 fb 19             	cmp    $0x19,%bl
  800ae4:	77 08                	ja     800aee <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ae6:	0f be d2             	movsbl %dl,%edx
  800ae9:	83 ea 57             	sub    $0x57,%edx
  800aec:	eb 10                	jmp    800afe <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800aee:	8d 72 bf             	lea    -0x41(%edx),%esi
  800af1:	89 f3                	mov    %esi,%ebx
  800af3:	80 fb 19             	cmp    $0x19,%bl
  800af6:	77 16                	ja     800b0e <strtol+0xbd>
			dig = *s - 'A' + 10;
  800af8:	0f be d2             	movsbl %dl,%edx
  800afb:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800afe:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b01:	7d 0b                	jge    800b0e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b03:	83 c1 01             	add    $0x1,%ecx
  800b06:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b0a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b0c:	eb b9                	jmp    800ac7 <strtol+0x76>

	if (endptr)
  800b0e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b12:	74 0d                	je     800b21 <strtol+0xd0>
		*endptr = (char *) s;
  800b14:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b17:	89 0e                	mov    %ecx,(%esi)
  800b19:	eb 06                	jmp    800b21 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b1b:	85 db                	test   %ebx,%ebx
  800b1d:	74 98                	je     800ab7 <strtol+0x66>
  800b1f:	eb 9e                	jmp    800abf <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b21:	89 c2                	mov    %eax,%edx
  800b23:	f7 da                	neg    %edx
  800b25:	85 ff                	test   %edi,%edi
  800b27:	0f 45 c2             	cmovne %edx,%eax
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5f                   	pop    %edi
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b35:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b40:	89 c3                	mov    %eax,%ebx
  800b42:	89 c7                	mov    %eax,%edi
  800b44:	89 c6                	mov    %eax,%esi
  800b46:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5f                   	pop    %edi
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    

00800b4d <sys_cgetc>:

int
sys_cgetc(void)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	57                   	push   %edi
  800b51:	56                   	push   %esi
  800b52:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b53:	ba 00 00 00 00       	mov    $0x0,%edx
  800b58:	b8 01 00 00 00       	mov    $0x1,%eax
  800b5d:	89 d1                	mov    %edx,%ecx
  800b5f:	89 d3                	mov    %edx,%ebx
  800b61:	89 d7                	mov    %edx,%edi
  800b63:	89 d6                	mov    %edx,%esi
  800b65:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b67:	5b                   	pop    %ebx
  800b68:	5e                   	pop    %esi
  800b69:	5f                   	pop    %edi
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	57                   	push   %edi
  800b70:	56                   	push   %esi
  800b71:	53                   	push   %ebx
  800b72:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b75:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b82:	89 cb                	mov    %ecx,%ebx
  800b84:	89 cf                	mov    %ecx,%edi
  800b86:	89 ce                	mov    %ecx,%esi
  800b88:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b8a:	85 c0                	test   %eax,%eax
  800b8c:	7e 17                	jle    800ba5 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8e:	83 ec 0c             	sub    $0xc,%esp
  800b91:	50                   	push   %eax
  800b92:	6a 03                	push   $0x3
  800b94:	68 1f 23 80 00       	push   $0x80231f
  800b99:	6a 23                	push   $0x23
  800b9b:	68 3c 23 80 00       	push   $0x80233c
  800ba0:	e8 e5 f5 ff ff       	call   80018a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ba5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba8:	5b                   	pop    %ebx
  800ba9:	5e                   	pop    %esi
  800baa:	5f                   	pop    %edi
  800bab:	5d                   	pop    %ebp
  800bac:	c3                   	ret    

00800bad <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	57                   	push   %edi
  800bb1:	56                   	push   %esi
  800bb2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb8:	b8 02 00 00 00       	mov    $0x2,%eax
  800bbd:	89 d1                	mov    %edx,%ecx
  800bbf:	89 d3                	mov    %edx,%ebx
  800bc1:	89 d7                	mov    %edx,%edi
  800bc3:	89 d6                	mov    %edx,%esi
  800bc5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bc7:	5b                   	pop    %ebx
  800bc8:	5e                   	pop    %esi
  800bc9:	5f                   	pop    %edi
  800bca:	5d                   	pop    %ebp
  800bcb:	c3                   	ret    

00800bcc <sys_yield>:

void
sys_yield(void)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	57                   	push   %edi
  800bd0:	56                   	push   %esi
  800bd1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bdc:	89 d1                	mov    %edx,%ecx
  800bde:	89 d3                	mov    %edx,%ebx
  800be0:	89 d7                	mov    %edx,%edi
  800be2:	89 d6                	mov    %edx,%esi
  800be4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800be6:	5b                   	pop    %ebx
  800be7:	5e                   	pop    %esi
  800be8:	5f                   	pop    %edi
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
  800bf1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf4:	be 00 00 00 00       	mov    $0x0,%esi
  800bf9:	b8 04 00 00 00       	mov    $0x4,%eax
  800bfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c01:	8b 55 08             	mov    0x8(%ebp),%edx
  800c04:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c07:	89 f7                	mov    %esi,%edi
  800c09:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c0b:	85 c0                	test   %eax,%eax
  800c0d:	7e 17                	jle    800c26 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0f:	83 ec 0c             	sub    $0xc,%esp
  800c12:	50                   	push   %eax
  800c13:	6a 04                	push   $0x4
  800c15:	68 1f 23 80 00       	push   $0x80231f
  800c1a:	6a 23                	push   $0x23
  800c1c:	68 3c 23 80 00       	push   $0x80233c
  800c21:	e8 64 f5 ff ff       	call   80018a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c29:	5b                   	pop    %ebx
  800c2a:	5e                   	pop    %esi
  800c2b:	5f                   	pop    %edi
  800c2c:	5d                   	pop    %ebp
  800c2d:	c3                   	ret    

00800c2e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	57                   	push   %edi
  800c32:	56                   	push   %esi
  800c33:	53                   	push   %ebx
  800c34:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c37:	b8 05 00 00 00       	mov    $0x5,%eax
  800c3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c42:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c45:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c48:	8b 75 18             	mov    0x18(%ebp),%esi
  800c4b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c4d:	85 c0                	test   %eax,%eax
  800c4f:	7e 17                	jle    800c68 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c51:	83 ec 0c             	sub    $0xc,%esp
  800c54:	50                   	push   %eax
  800c55:	6a 05                	push   $0x5
  800c57:	68 1f 23 80 00       	push   $0x80231f
  800c5c:	6a 23                	push   $0x23
  800c5e:	68 3c 23 80 00       	push   $0x80233c
  800c63:	e8 22 f5 ff ff       	call   80018a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6b:	5b                   	pop    %ebx
  800c6c:	5e                   	pop    %esi
  800c6d:	5f                   	pop    %edi
  800c6e:	5d                   	pop    %ebp
  800c6f:	c3                   	ret    

00800c70 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	57                   	push   %edi
  800c74:	56                   	push   %esi
  800c75:	53                   	push   %ebx
  800c76:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c79:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c86:	8b 55 08             	mov    0x8(%ebp),%edx
  800c89:	89 df                	mov    %ebx,%edi
  800c8b:	89 de                	mov    %ebx,%esi
  800c8d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c8f:	85 c0                	test   %eax,%eax
  800c91:	7e 17                	jle    800caa <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c93:	83 ec 0c             	sub    $0xc,%esp
  800c96:	50                   	push   %eax
  800c97:	6a 06                	push   $0x6
  800c99:	68 1f 23 80 00       	push   $0x80231f
  800c9e:	6a 23                	push   $0x23
  800ca0:	68 3c 23 80 00       	push   $0x80233c
  800ca5:	e8 e0 f4 ff ff       	call   80018a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800caa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cad:	5b                   	pop    %ebx
  800cae:	5e                   	pop    %esi
  800caf:	5f                   	pop    %edi
  800cb0:	5d                   	pop    %ebp
  800cb1:	c3                   	ret    

00800cb2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cb2:	55                   	push   %ebp
  800cb3:	89 e5                	mov    %esp,%ebp
  800cb5:	57                   	push   %edi
  800cb6:	56                   	push   %esi
  800cb7:	53                   	push   %ebx
  800cb8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc0:	b8 08 00 00 00       	mov    $0x8,%eax
  800cc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccb:	89 df                	mov    %ebx,%edi
  800ccd:	89 de                	mov    %ebx,%esi
  800ccf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd1:	85 c0                	test   %eax,%eax
  800cd3:	7e 17                	jle    800cec <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd5:	83 ec 0c             	sub    $0xc,%esp
  800cd8:	50                   	push   %eax
  800cd9:	6a 08                	push   $0x8
  800cdb:	68 1f 23 80 00       	push   $0x80231f
  800ce0:	6a 23                	push   $0x23
  800ce2:	68 3c 23 80 00       	push   $0x80233c
  800ce7:	e8 9e f4 ff ff       	call   80018a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	57                   	push   %edi
  800cf8:	56                   	push   %esi
  800cf9:	53                   	push   %ebx
  800cfa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d02:	b8 09 00 00 00       	mov    $0x9,%eax
  800d07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0d:	89 df                	mov    %ebx,%edi
  800d0f:	89 de                	mov    %ebx,%esi
  800d11:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d13:	85 c0                	test   %eax,%eax
  800d15:	7e 17                	jle    800d2e <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d17:	83 ec 0c             	sub    $0xc,%esp
  800d1a:	50                   	push   %eax
  800d1b:	6a 09                	push   $0x9
  800d1d:	68 1f 23 80 00       	push   $0x80231f
  800d22:	6a 23                	push   $0x23
  800d24:	68 3c 23 80 00       	push   $0x80233c
  800d29:	e8 5c f4 ff ff       	call   80018a <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d31:	5b                   	pop    %ebx
  800d32:	5e                   	pop    %esi
  800d33:	5f                   	pop    %edi
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	57                   	push   %edi
  800d3a:	56                   	push   %esi
  800d3b:	53                   	push   %ebx
  800d3c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d44:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4f:	89 df                	mov    %ebx,%edi
  800d51:	89 de                	mov    %ebx,%esi
  800d53:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d55:	85 c0                	test   %eax,%eax
  800d57:	7e 17                	jle    800d70 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d59:	83 ec 0c             	sub    $0xc,%esp
  800d5c:	50                   	push   %eax
  800d5d:	6a 0a                	push   $0xa
  800d5f:	68 1f 23 80 00       	push   $0x80231f
  800d64:	6a 23                	push   $0x23
  800d66:	68 3c 23 80 00       	push   $0x80233c
  800d6b:	e8 1a f4 ff ff       	call   80018a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5f                   	pop    %edi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    

00800d78 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	57                   	push   %edi
  800d7c:	56                   	push   %esi
  800d7d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7e:	be 00 00 00 00       	mov    $0x0,%esi
  800d83:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d91:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d94:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d96:	5b                   	pop    %ebx
  800d97:	5e                   	pop    %esi
  800d98:	5f                   	pop    %edi
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    

00800d9b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	57                   	push   %edi
  800d9f:	56                   	push   %esi
  800da0:	53                   	push   %ebx
  800da1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dae:	8b 55 08             	mov    0x8(%ebp),%edx
  800db1:	89 cb                	mov    %ecx,%ebx
  800db3:	89 cf                	mov    %ecx,%edi
  800db5:	89 ce                	mov    %ecx,%esi
  800db7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800db9:	85 c0                	test   %eax,%eax
  800dbb:	7e 17                	jle    800dd4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbd:	83 ec 0c             	sub    $0xc,%esp
  800dc0:	50                   	push   %eax
  800dc1:	6a 0d                	push   $0xd
  800dc3:	68 1f 23 80 00       	push   $0x80231f
  800dc8:	6a 23                	push   $0x23
  800dca:	68 3c 23 80 00       	push   $0x80233c
  800dcf:	e8 b6 f3 ff ff       	call   80018a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd7:	5b                   	pop    %ebx
  800dd8:	5e                   	pop    %esi
  800dd9:	5f                   	pop    %edi
  800dda:	5d                   	pop    %ebp
  800ddb:	c3                   	ret    

00800ddc <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	57                   	push   %edi
  800de0:	56                   	push   %esi
  800de1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800de7:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dec:	8b 55 08             	mov    0x8(%ebp),%edx
  800def:	89 cb                	mov    %ecx,%ebx
  800df1:	89 cf                	mov    %ecx,%edi
  800df3:	89 ce                	mov    %ecx,%esi
  800df5:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800df7:	5b                   	pop    %ebx
  800df8:	5e                   	pop    %esi
  800df9:	5f                   	pop    %edi
  800dfa:	5d                   	pop    %ebp
  800dfb:	c3                   	ret    

00800dfc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e02:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800e09:	75 2a                	jne    800e35 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  800e0b:	83 ec 04             	sub    $0x4,%esp
  800e0e:	6a 07                	push   $0x7
  800e10:	68 00 f0 bf ee       	push   $0xeebff000
  800e15:	6a 00                	push   $0x0
  800e17:	e8 cf fd ff ff       	call   800beb <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  800e1c:	83 c4 10             	add    $0x10,%esp
  800e1f:	85 c0                	test   %eax,%eax
  800e21:	79 12                	jns    800e35 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  800e23:	50                   	push   %eax
  800e24:	68 4a 23 80 00       	push   $0x80234a
  800e29:	6a 23                	push   $0x23
  800e2b:	68 4e 23 80 00       	push   $0x80234e
  800e30:	e8 55 f3 ff ff       	call   80018a <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e35:	8b 45 08             	mov    0x8(%ebp),%eax
  800e38:	a3 08 40 80 00       	mov    %eax,0x804008
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  800e3d:	83 ec 08             	sub    $0x8,%esp
  800e40:	68 67 0e 80 00       	push   $0x800e67
  800e45:	6a 00                	push   $0x0
  800e47:	e8 ea fe ff ff       	call   800d36 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  800e4c:	83 c4 10             	add    $0x10,%esp
  800e4f:	85 c0                	test   %eax,%eax
  800e51:	79 12                	jns    800e65 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  800e53:	50                   	push   %eax
  800e54:	68 4a 23 80 00       	push   $0x80234a
  800e59:	6a 2c                	push   $0x2c
  800e5b:	68 4e 23 80 00       	push   $0x80234e
  800e60:	e8 25 f3 ff ff       	call   80018a <_panic>
	}
}
  800e65:	c9                   	leave  
  800e66:	c3                   	ret    

00800e67 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e67:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e68:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800e6d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e6f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  800e72:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  800e76:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  800e7b:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  800e7f:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  800e81:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  800e84:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  800e85:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  800e88:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  800e89:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e8a:	c3                   	ret    

00800e8b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e91:	05 00 00 00 30       	add    $0x30000000,%eax
  800e96:	c1 e8 0c             	shr    $0xc,%eax
}
  800e99:	5d                   	pop    %ebp
  800e9a:	c3                   	ret    

00800e9b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e9b:	55                   	push   %ebp
  800e9c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea1:	05 00 00 00 30       	add    $0x30000000,%eax
  800ea6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800eab:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800eb0:	5d                   	pop    %ebp
  800eb1:	c3                   	ret    

00800eb2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800eb2:	55                   	push   %ebp
  800eb3:	89 e5                	mov    %esp,%ebp
  800eb5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eb8:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ebd:	89 c2                	mov    %eax,%edx
  800ebf:	c1 ea 16             	shr    $0x16,%edx
  800ec2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ec9:	f6 c2 01             	test   $0x1,%dl
  800ecc:	74 11                	je     800edf <fd_alloc+0x2d>
  800ece:	89 c2                	mov    %eax,%edx
  800ed0:	c1 ea 0c             	shr    $0xc,%edx
  800ed3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eda:	f6 c2 01             	test   $0x1,%dl
  800edd:	75 09                	jne    800ee8 <fd_alloc+0x36>
			*fd_store = fd;
  800edf:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ee1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee6:	eb 17                	jmp    800eff <fd_alloc+0x4d>
  800ee8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800eed:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ef2:	75 c9                	jne    800ebd <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ef4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800efa:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800eff:	5d                   	pop    %ebp
  800f00:	c3                   	ret    

00800f01 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f01:	55                   	push   %ebp
  800f02:	89 e5                	mov    %esp,%ebp
  800f04:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f07:	83 f8 1f             	cmp    $0x1f,%eax
  800f0a:	77 36                	ja     800f42 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f0c:	c1 e0 0c             	shl    $0xc,%eax
  800f0f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f14:	89 c2                	mov    %eax,%edx
  800f16:	c1 ea 16             	shr    $0x16,%edx
  800f19:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f20:	f6 c2 01             	test   $0x1,%dl
  800f23:	74 24                	je     800f49 <fd_lookup+0x48>
  800f25:	89 c2                	mov    %eax,%edx
  800f27:	c1 ea 0c             	shr    $0xc,%edx
  800f2a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f31:	f6 c2 01             	test   $0x1,%dl
  800f34:	74 1a                	je     800f50 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f36:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f39:	89 02                	mov    %eax,(%edx)
	return 0;
  800f3b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f40:	eb 13                	jmp    800f55 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f42:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f47:	eb 0c                	jmp    800f55 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f49:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f4e:	eb 05                	jmp    800f55 <fd_lookup+0x54>
  800f50:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f55:	5d                   	pop    %ebp
  800f56:	c3                   	ret    

00800f57 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f57:	55                   	push   %ebp
  800f58:	89 e5                	mov    %esp,%ebp
  800f5a:	83 ec 08             	sub    $0x8,%esp
  800f5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f60:	ba dc 23 80 00       	mov    $0x8023dc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f65:	eb 13                	jmp    800f7a <dev_lookup+0x23>
  800f67:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f6a:	39 08                	cmp    %ecx,(%eax)
  800f6c:	75 0c                	jne    800f7a <dev_lookup+0x23>
			*dev = devtab[i];
  800f6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f71:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f73:	b8 00 00 00 00       	mov    $0x0,%eax
  800f78:	eb 2e                	jmp    800fa8 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f7a:	8b 02                	mov    (%edx),%eax
  800f7c:	85 c0                	test   %eax,%eax
  800f7e:	75 e7                	jne    800f67 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f80:	a1 04 40 80 00       	mov    0x804004,%eax
  800f85:	8b 40 50             	mov    0x50(%eax),%eax
  800f88:	83 ec 04             	sub    $0x4,%esp
  800f8b:	51                   	push   %ecx
  800f8c:	50                   	push   %eax
  800f8d:	68 5c 23 80 00       	push   $0x80235c
  800f92:	e8 cc f2 ff ff       	call   800263 <cprintf>
	*dev = 0;
  800f97:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f9a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fa0:	83 c4 10             	add    $0x10,%esp
  800fa3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fa8:	c9                   	leave  
  800fa9:	c3                   	ret    

00800faa <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	56                   	push   %esi
  800fae:	53                   	push   %ebx
  800faf:	83 ec 10             	sub    $0x10,%esp
  800fb2:	8b 75 08             	mov    0x8(%ebp),%esi
  800fb5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fbb:	50                   	push   %eax
  800fbc:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fc2:	c1 e8 0c             	shr    $0xc,%eax
  800fc5:	50                   	push   %eax
  800fc6:	e8 36 ff ff ff       	call   800f01 <fd_lookup>
  800fcb:	83 c4 08             	add    $0x8,%esp
  800fce:	85 c0                	test   %eax,%eax
  800fd0:	78 05                	js     800fd7 <fd_close+0x2d>
	    || fd != fd2)
  800fd2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fd5:	74 0c                	je     800fe3 <fd_close+0x39>
		return (must_exist ? r : 0);
  800fd7:	84 db                	test   %bl,%bl
  800fd9:	ba 00 00 00 00       	mov    $0x0,%edx
  800fde:	0f 44 c2             	cmove  %edx,%eax
  800fe1:	eb 41                	jmp    801024 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fe3:	83 ec 08             	sub    $0x8,%esp
  800fe6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fe9:	50                   	push   %eax
  800fea:	ff 36                	pushl  (%esi)
  800fec:	e8 66 ff ff ff       	call   800f57 <dev_lookup>
  800ff1:	89 c3                	mov    %eax,%ebx
  800ff3:	83 c4 10             	add    $0x10,%esp
  800ff6:	85 c0                	test   %eax,%eax
  800ff8:	78 1a                	js     801014 <fd_close+0x6a>
		if (dev->dev_close)
  800ffa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ffd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801000:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801005:	85 c0                	test   %eax,%eax
  801007:	74 0b                	je     801014 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801009:	83 ec 0c             	sub    $0xc,%esp
  80100c:	56                   	push   %esi
  80100d:	ff d0                	call   *%eax
  80100f:	89 c3                	mov    %eax,%ebx
  801011:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801014:	83 ec 08             	sub    $0x8,%esp
  801017:	56                   	push   %esi
  801018:	6a 00                	push   $0x0
  80101a:	e8 51 fc ff ff       	call   800c70 <sys_page_unmap>
	return r;
  80101f:	83 c4 10             	add    $0x10,%esp
  801022:	89 d8                	mov    %ebx,%eax
}
  801024:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801027:	5b                   	pop    %ebx
  801028:	5e                   	pop    %esi
  801029:	5d                   	pop    %ebp
  80102a:	c3                   	ret    

0080102b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80102b:	55                   	push   %ebp
  80102c:	89 e5                	mov    %esp,%ebp
  80102e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801031:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801034:	50                   	push   %eax
  801035:	ff 75 08             	pushl  0x8(%ebp)
  801038:	e8 c4 fe ff ff       	call   800f01 <fd_lookup>
  80103d:	83 c4 08             	add    $0x8,%esp
  801040:	85 c0                	test   %eax,%eax
  801042:	78 10                	js     801054 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801044:	83 ec 08             	sub    $0x8,%esp
  801047:	6a 01                	push   $0x1
  801049:	ff 75 f4             	pushl  -0xc(%ebp)
  80104c:	e8 59 ff ff ff       	call   800faa <fd_close>
  801051:	83 c4 10             	add    $0x10,%esp
}
  801054:	c9                   	leave  
  801055:	c3                   	ret    

00801056 <close_all>:

void
close_all(void)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	53                   	push   %ebx
  80105a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80105d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801062:	83 ec 0c             	sub    $0xc,%esp
  801065:	53                   	push   %ebx
  801066:	e8 c0 ff ff ff       	call   80102b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80106b:	83 c3 01             	add    $0x1,%ebx
  80106e:	83 c4 10             	add    $0x10,%esp
  801071:	83 fb 20             	cmp    $0x20,%ebx
  801074:	75 ec                	jne    801062 <close_all+0xc>
		close(i);
}
  801076:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801079:	c9                   	leave  
  80107a:	c3                   	ret    

0080107b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80107b:	55                   	push   %ebp
  80107c:	89 e5                	mov    %esp,%ebp
  80107e:	57                   	push   %edi
  80107f:	56                   	push   %esi
  801080:	53                   	push   %ebx
  801081:	83 ec 2c             	sub    $0x2c,%esp
  801084:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801087:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80108a:	50                   	push   %eax
  80108b:	ff 75 08             	pushl  0x8(%ebp)
  80108e:	e8 6e fe ff ff       	call   800f01 <fd_lookup>
  801093:	83 c4 08             	add    $0x8,%esp
  801096:	85 c0                	test   %eax,%eax
  801098:	0f 88 c1 00 00 00    	js     80115f <dup+0xe4>
		return r;
	close(newfdnum);
  80109e:	83 ec 0c             	sub    $0xc,%esp
  8010a1:	56                   	push   %esi
  8010a2:	e8 84 ff ff ff       	call   80102b <close>

	newfd = INDEX2FD(newfdnum);
  8010a7:	89 f3                	mov    %esi,%ebx
  8010a9:	c1 e3 0c             	shl    $0xc,%ebx
  8010ac:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010b2:	83 c4 04             	add    $0x4,%esp
  8010b5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010b8:	e8 de fd ff ff       	call   800e9b <fd2data>
  8010bd:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010bf:	89 1c 24             	mov    %ebx,(%esp)
  8010c2:	e8 d4 fd ff ff       	call   800e9b <fd2data>
  8010c7:	83 c4 10             	add    $0x10,%esp
  8010ca:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010cd:	89 f8                	mov    %edi,%eax
  8010cf:	c1 e8 16             	shr    $0x16,%eax
  8010d2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010d9:	a8 01                	test   $0x1,%al
  8010db:	74 37                	je     801114 <dup+0x99>
  8010dd:	89 f8                	mov    %edi,%eax
  8010df:	c1 e8 0c             	shr    $0xc,%eax
  8010e2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010e9:	f6 c2 01             	test   $0x1,%dl
  8010ec:	74 26                	je     801114 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010ee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010f5:	83 ec 0c             	sub    $0xc,%esp
  8010f8:	25 07 0e 00 00       	and    $0xe07,%eax
  8010fd:	50                   	push   %eax
  8010fe:	ff 75 d4             	pushl  -0x2c(%ebp)
  801101:	6a 00                	push   $0x0
  801103:	57                   	push   %edi
  801104:	6a 00                	push   $0x0
  801106:	e8 23 fb ff ff       	call   800c2e <sys_page_map>
  80110b:	89 c7                	mov    %eax,%edi
  80110d:	83 c4 20             	add    $0x20,%esp
  801110:	85 c0                	test   %eax,%eax
  801112:	78 2e                	js     801142 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801114:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801117:	89 d0                	mov    %edx,%eax
  801119:	c1 e8 0c             	shr    $0xc,%eax
  80111c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801123:	83 ec 0c             	sub    $0xc,%esp
  801126:	25 07 0e 00 00       	and    $0xe07,%eax
  80112b:	50                   	push   %eax
  80112c:	53                   	push   %ebx
  80112d:	6a 00                	push   $0x0
  80112f:	52                   	push   %edx
  801130:	6a 00                	push   $0x0
  801132:	e8 f7 fa ff ff       	call   800c2e <sys_page_map>
  801137:	89 c7                	mov    %eax,%edi
  801139:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80113c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80113e:	85 ff                	test   %edi,%edi
  801140:	79 1d                	jns    80115f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801142:	83 ec 08             	sub    $0x8,%esp
  801145:	53                   	push   %ebx
  801146:	6a 00                	push   $0x0
  801148:	e8 23 fb ff ff       	call   800c70 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80114d:	83 c4 08             	add    $0x8,%esp
  801150:	ff 75 d4             	pushl  -0x2c(%ebp)
  801153:	6a 00                	push   $0x0
  801155:	e8 16 fb ff ff       	call   800c70 <sys_page_unmap>
	return r;
  80115a:	83 c4 10             	add    $0x10,%esp
  80115d:	89 f8                	mov    %edi,%eax
}
  80115f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801162:	5b                   	pop    %ebx
  801163:	5e                   	pop    %esi
  801164:	5f                   	pop    %edi
  801165:	5d                   	pop    %ebp
  801166:	c3                   	ret    

00801167 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801167:	55                   	push   %ebp
  801168:	89 e5                	mov    %esp,%ebp
  80116a:	53                   	push   %ebx
  80116b:	83 ec 14             	sub    $0x14,%esp
  80116e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801171:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801174:	50                   	push   %eax
  801175:	53                   	push   %ebx
  801176:	e8 86 fd ff ff       	call   800f01 <fd_lookup>
  80117b:	83 c4 08             	add    $0x8,%esp
  80117e:	89 c2                	mov    %eax,%edx
  801180:	85 c0                	test   %eax,%eax
  801182:	78 6d                	js     8011f1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801184:	83 ec 08             	sub    $0x8,%esp
  801187:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80118a:	50                   	push   %eax
  80118b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80118e:	ff 30                	pushl  (%eax)
  801190:	e8 c2 fd ff ff       	call   800f57 <dev_lookup>
  801195:	83 c4 10             	add    $0x10,%esp
  801198:	85 c0                	test   %eax,%eax
  80119a:	78 4c                	js     8011e8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80119c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80119f:	8b 42 08             	mov    0x8(%edx),%eax
  8011a2:	83 e0 03             	and    $0x3,%eax
  8011a5:	83 f8 01             	cmp    $0x1,%eax
  8011a8:	75 21                	jne    8011cb <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011aa:	a1 04 40 80 00       	mov    0x804004,%eax
  8011af:	8b 40 50             	mov    0x50(%eax),%eax
  8011b2:	83 ec 04             	sub    $0x4,%esp
  8011b5:	53                   	push   %ebx
  8011b6:	50                   	push   %eax
  8011b7:	68 a0 23 80 00       	push   $0x8023a0
  8011bc:	e8 a2 f0 ff ff       	call   800263 <cprintf>
		return -E_INVAL;
  8011c1:	83 c4 10             	add    $0x10,%esp
  8011c4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011c9:	eb 26                	jmp    8011f1 <read+0x8a>
	}
	if (!dev->dev_read)
  8011cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ce:	8b 40 08             	mov    0x8(%eax),%eax
  8011d1:	85 c0                	test   %eax,%eax
  8011d3:	74 17                	je     8011ec <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8011d5:	83 ec 04             	sub    $0x4,%esp
  8011d8:	ff 75 10             	pushl  0x10(%ebp)
  8011db:	ff 75 0c             	pushl  0xc(%ebp)
  8011de:	52                   	push   %edx
  8011df:	ff d0                	call   *%eax
  8011e1:	89 c2                	mov    %eax,%edx
  8011e3:	83 c4 10             	add    $0x10,%esp
  8011e6:	eb 09                	jmp    8011f1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e8:	89 c2                	mov    %eax,%edx
  8011ea:	eb 05                	jmp    8011f1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011ec:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8011f1:	89 d0                	mov    %edx,%eax
  8011f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f6:	c9                   	leave  
  8011f7:	c3                   	ret    

008011f8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011f8:	55                   	push   %ebp
  8011f9:	89 e5                	mov    %esp,%ebp
  8011fb:	57                   	push   %edi
  8011fc:	56                   	push   %esi
  8011fd:	53                   	push   %ebx
  8011fe:	83 ec 0c             	sub    $0xc,%esp
  801201:	8b 7d 08             	mov    0x8(%ebp),%edi
  801204:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801207:	bb 00 00 00 00       	mov    $0x0,%ebx
  80120c:	eb 21                	jmp    80122f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80120e:	83 ec 04             	sub    $0x4,%esp
  801211:	89 f0                	mov    %esi,%eax
  801213:	29 d8                	sub    %ebx,%eax
  801215:	50                   	push   %eax
  801216:	89 d8                	mov    %ebx,%eax
  801218:	03 45 0c             	add    0xc(%ebp),%eax
  80121b:	50                   	push   %eax
  80121c:	57                   	push   %edi
  80121d:	e8 45 ff ff ff       	call   801167 <read>
		if (m < 0)
  801222:	83 c4 10             	add    $0x10,%esp
  801225:	85 c0                	test   %eax,%eax
  801227:	78 10                	js     801239 <readn+0x41>
			return m;
		if (m == 0)
  801229:	85 c0                	test   %eax,%eax
  80122b:	74 0a                	je     801237 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80122d:	01 c3                	add    %eax,%ebx
  80122f:	39 f3                	cmp    %esi,%ebx
  801231:	72 db                	jb     80120e <readn+0x16>
  801233:	89 d8                	mov    %ebx,%eax
  801235:	eb 02                	jmp    801239 <readn+0x41>
  801237:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801239:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80123c:	5b                   	pop    %ebx
  80123d:	5e                   	pop    %esi
  80123e:	5f                   	pop    %edi
  80123f:	5d                   	pop    %ebp
  801240:	c3                   	ret    

00801241 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
  801244:	53                   	push   %ebx
  801245:	83 ec 14             	sub    $0x14,%esp
  801248:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80124b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80124e:	50                   	push   %eax
  80124f:	53                   	push   %ebx
  801250:	e8 ac fc ff ff       	call   800f01 <fd_lookup>
  801255:	83 c4 08             	add    $0x8,%esp
  801258:	89 c2                	mov    %eax,%edx
  80125a:	85 c0                	test   %eax,%eax
  80125c:	78 68                	js     8012c6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125e:	83 ec 08             	sub    $0x8,%esp
  801261:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801264:	50                   	push   %eax
  801265:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801268:	ff 30                	pushl  (%eax)
  80126a:	e8 e8 fc ff ff       	call   800f57 <dev_lookup>
  80126f:	83 c4 10             	add    $0x10,%esp
  801272:	85 c0                	test   %eax,%eax
  801274:	78 47                	js     8012bd <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801276:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801279:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80127d:	75 21                	jne    8012a0 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80127f:	a1 04 40 80 00       	mov    0x804004,%eax
  801284:	8b 40 50             	mov    0x50(%eax),%eax
  801287:	83 ec 04             	sub    $0x4,%esp
  80128a:	53                   	push   %ebx
  80128b:	50                   	push   %eax
  80128c:	68 bc 23 80 00       	push   $0x8023bc
  801291:	e8 cd ef ff ff       	call   800263 <cprintf>
		return -E_INVAL;
  801296:	83 c4 10             	add    $0x10,%esp
  801299:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80129e:	eb 26                	jmp    8012c6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012a3:	8b 52 0c             	mov    0xc(%edx),%edx
  8012a6:	85 d2                	test   %edx,%edx
  8012a8:	74 17                	je     8012c1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012aa:	83 ec 04             	sub    $0x4,%esp
  8012ad:	ff 75 10             	pushl  0x10(%ebp)
  8012b0:	ff 75 0c             	pushl  0xc(%ebp)
  8012b3:	50                   	push   %eax
  8012b4:	ff d2                	call   *%edx
  8012b6:	89 c2                	mov    %eax,%edx
  8012b8:	83 c4 10             	add    $0x10,%esp
  8012bb:	eb 09                	jmp    8012c6 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012bd:	89 c2                	mov    %eax,%edx
  8012bf:	eb 05                	jmp    8012c6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012c1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012c6:	89 d0                	mov    %edx,%eax
  8012c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012cb:	c9                   	leave  
  8012cc:	c3                   	ret    

008012cd <seek>:

int
seek(int fdnum, off_t offset)
{
  8012cd:	55                   	push   %ebp
  8012ce:	89 e5                	mov    %esp,%ebp
  8012d0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012d3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012d6:	50                   	push   %eax
  8012d7:	ff 75 08             	pushl  0x8(%ebp)
  8012da:	e8 22 fc ff ff       	call   800f01 <fd_lookup>
  8012df:	83 c4 08             	add    $0x8,%esp
  8012e2:	85 c0                	test   %eax,%eax
  8012e4:	78 0e                	js     8012f4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ec:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012f4:	c9                   	leave  
  8012f5:	c3                   	ret    

008012f6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012f6:	55                   	push   %ebp
  8012f7:	89 e5                	mov    %esp,%ebp
  8012f9:	53                   	push   %ebx
  8012fa:	83 ec 14             	sub    $0x14,%esp
  8012fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801300:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801303:	50                   	push   %eax
  801304:	53                   	push   %ebx
  801305:	e8 f7 fb ff ff       	call   800f01 <fd_lookup>
  80130a:	83 c4 08             	add    $0x8,%esp
  80130d:	89 c2                	mov    %eax,%edx
  80130f:	85 c0                	test   %eax,%eax
  801311:	78 65                	js     801378 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801313:	83 ec 08             	sub    $0x8,%esp
  801316:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801319:	50                   	push   %eax
  80131a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131d:	ff 30                	pushl  (%eax)
  80131f:	e8 33 fc ff ff       	call   800f57 <dev_lookup>
  801324:	83 c4 10             	add    $0x10,%esp
  801327:	85 c0                	test   %eax,%eax
  801329:	78 44                	js     80136f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80132b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80132e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801332:	75 21                	jne    801355 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801334:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801339:	8b 40 50             	mov    0x50(%eax),%eax
  80133c:	83 ec 04             	sub    $0x4,%esp
  80133f:	53                   	push   %ebx
  801340:	50                   	push   %eax
  801341:	68 7c 23 80 00       	push   $0x80237c
  801346:	e8 18 ef ff ff       	call   800263 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80134b:	83 c4 10             	add    $0x10,%esp
  80134e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801353:	eb 23                	jmp    801378 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801355:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801358:	8b 52 18             	mov    0x18(%edx),%edx
  80135b:	85 d2                	test   %edx,%edx
  80135d:	74 14                	je     801373 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80135f:	83 ec 08             	sub    $0x8,%esp
  801362:	ff 75 0c             	pushl  0xc(%ebp)
  801365:	50                   	push   %eax
  801366:	ff d2                	call   *%edx
  801368:	89 c2                	mov    %eax,%edx
  80136a:	83 c4 10             	add    $0x10,%esp
  80136d:	eb 09                	jmp    801378 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80136f:	89 c2                	mov    %eax,%edx
  801371:	eb 05                	jmp    801378 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801373:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801378:	89 d0                	mov    %edx,%eax
  80137a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137d:	c9                   	leave  
  80137e:	c3                   	ret    

0080137f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80137f:	55                   	push   %ebp
  801380:	89 e5                	mov    %esp,%ebp
  801382:	53                   	push   %ebx
  801383:	83 ec 14             	sub    $0x14,%esp
  801386:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801389:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138c:	50                   	push   %eax
  80138d:	ff 75 08             	pushl  0x8(%ebp)
  801390:	e8 6c fb ff ff       	call   800f01 <fd_lookup>
  801395:	83 c4 08             	add    $0x8,%esp
  801398:	89 c2                	mov    %eax,%edx
  80139a:	85 c0                	test   %eax,%eax
  80139c:	78 58                	js     8013f6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80139e:	83 ec 08             	sub    $0x8,%esp
  8013a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a4:	50                   	push   %eax
  8013a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a8:	ff 30                	pushl  (%eax)
  8013aa:	e8 a8 fb ff ff       	call   800f57 <dev_lookup>
  8013af:	83 c4 10             	add    $0x10,%esp
  8013b2:	85 c0                	test   %eax,%eax
  8013b4:	78 37                	js     8013ed <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013bd:	74 32                	je     8013f1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013bf:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013c2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013c9:	00 00 00 
	stat->st_isdir = 0;
  8013cc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013d3:	00 00 00 
	stat->st_dev = dev;
  8013d6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013dc:	83 ec 08             	sub    $0x8,%esp
  8013df:	53                   	push   %ebx
  8013e0:	ff 75 f0             	pushl  -0x10(%ebp)
  8013e3:	ff 50 14             	call   *0x14(%eax)
  8013e6:	89 c2                	mov    %eax,%edx
  8013e8:	83 c4 10             	add    $0x10,%esp
  8013eb:	eb 09                	jmp    8013f6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ed:	89 c2                	mov    %eax,%edx
  8013ef:	eb 05                	jmp    8013f6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013f1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013f6:	89 d0                	mov    %edx,%eax
  8013f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013fb:	c9                   	leave  
  8013fc:	c3                   	ret    

008013fd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013fd:	55                   	push   %ebp
  8013fe:	89 e5                	mov    %esp,%ebp
  801400:	56                   	push   %esi
  801401:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801402:	83 ec 08             	sub    $0x8,%esp
  801405:	6a 00                	push   $0x0
  801407:	ff 75 08             	pushl  0x8(%ebp)
  80140a:	e8 e3 01 00 00       	call   8015f2 <open>
  80140f:	89 c3                	mov    %eax,%ebx
  801411:	83 c4 10             	add    $0x10,%esp
  801414:	85 c0                	test   %eax,%eax
  801416:	78 1b                	js     801433 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801418:	83 ec 08             	sub    $0x8,%esp
  80141b:	ff 75 0c             	pushl  0xc(%ebp)
  80141e:	50                   	push   %eax
  80141f:	e8 5b ff ff ff       	call   80137f <fstat>
  801424:	89 c6                	mov    %eax,%esi
	close(fd);
  801426:	89 1c 24             	mov    %ebx,(%esp)
  801429:	e8 fd fb ff ff       	call   80102b <close>
	return r;
  80142e:	83 c4 10             	add    $0x10,%esp
  801431:	89 f0                	mov    %esi,%eax
}
  801433:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801436:	5b                   	pop    %ebx
  801437:	5e                   	pop    %esi
  801438:	5d                   	pop    %ebp
  801439:	c3                   	ret    

0080143a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80143a:	55                   	push   %ebp
  80143b:	89 e5                	mov    %esp,%ebp
  80143d:	56                   	push   %esi
  80143e:	53                   	push   %ebx
  80143f:	89 c6                	mov    %eax,%esi
  801441:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801443:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80144a:	75 12                	jne    80145e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80144c:	83 ec 0c             	sub    $0xc,%esp
  80144f:	6a 01                	push   $0x1
  801451:	e8 f6 07 00 00       	call   801c4c <ipc_find_env>
  801456:	a3 00 40 80 00       	mov    %eax,0x804000
  80145b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80145e:	6a 07                	push   $0x7
  801460:	68 00 50 80 00       	push   $0x805000
  801465:	56                   	push   %esi
  801466:	ff 35 00 40 80 00    	pushl  0x804000
  80146c:	e8 79 07 00 00       	call   801bea <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801471:	83 c4 0c             	add    $0xc,%esp
  801474:	6a 00                	push   $0x0
  801476:	53                   	push   %ebx
  801477:	6a 00                	push   $0x0
  801479:	e8 f7 06 00 00       	call   801b75 <ipc_recv>
}
  80147e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801481:	5b                   	pop    %ebx
  801482:	5e                   	pop    %esi
  801483:	5d                   	pop    %ebp
  801484:	c3                   	ret    

00801485 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801485:	55                   	push   %ebp
  801486:	89 e5                	mov    %esp,%ebp
  801488:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80148b:	8b 45 08             	mov    0x8(%ebp),%eax
  80148e:	8b 40 0c             	mov    0xc(%eax),%eax
  801491:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801496:	8b 45 0c             	mov    0xc(%ebp),%eax
  801499:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80149e:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a3:	b8 02 00 00 00       	mov    $0x2,%eax
  8014a8:	e8 8d ff ff ff       	call   80143a <fsipc>
}
  8014ad:	c9                   	leave  
  8014ae:	c3                   	ret    

008014af <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014af:	55                   	push   %ebp
  8014b0:	89 e5                	mov    %esp,%ebp
  8014b2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b8:	8b 40 0c             	mov    0xc(%eax),%eax
  8014bb:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c5:	b8 06 00 00 00       	mov    $0x6,%eax
  8014ca:	e8 6b ff ff ff       	call   80143a <fsipc>
}
  8014cf:	c9                   	leave  
  8014d0:	c3                   	ret    

008014d1 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014d1:	55                   	push   %ebp
  8014d2:	89 e5                	mov    %esp,%ebp
  8014d4:	53                   	push   %ebx
  8014d5:	83 ec 04             	sub    $0x4,%esp
  8014d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014db:	8b 45 08             	mov    0x8(%ebp),%eax
  8014de:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8014eb:	b8 05 00 00 00       	mov    $0x5,%eax
  8014f0:	e8 45 ff ff ff       	call   80143a <fsipc>
  8014f5:	85 c0                	test   %eax,%eax
  8014f7:	78 2c                	js     801525 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014f9:	83 ec 08             	sub    $0x8,%esp
  8014fc:	68 00 50 80 00       	push   $0x805000
  801501:	53                   	push   %ebx
  801502:	e8 e1 f2 ff ff       	call   8007e8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801507:	a1 80 50 80 00       	mov    0x805080,%eax
  80150c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801512:	a1 84 50 80 00       	mov    0x805084,%eax
  801517:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80151d:	83 c4 10             	add    $0x10,%esp
  801520:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801525:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801528:	c9                   	leave  
  801529:	c3                   	ret    

0080152a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80152a:	55                   	push   %ebp
  80152b:	89 e5                	mov    %esp,%ebp
  80152d:	83 ec 0c             	sub    $0xc,%esp
  801530:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801533:	8b 55 08             	mov    0x8(%ebp),%edx
  801536:	8b 52 0c             	mov    0xc(%edx),%edx
  801539:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80153f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801544:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801549:	0f 47 c2             	cmova  %edx,%eax
  80154c:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801551:	50                   	push   %eax
  801552:	ff 75 0c             	pushl  0xc(%ebp)
  801555:	68 08 50 80 00       	push   $0x805008
  80155a:	e8 1b f4 ff ff       	call   80097a <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80155f:	ba 00 00 00 00       	mov    $0x0,%edx
  801564:	b8 04 00 00 00       	mov    $0x4,%eax
  801569:	e8 cc fe ff ff       	call   80143a <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80156e:	c9                   	leave  
  80156f:	c3                   	ret    

00801570 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801570:	55                   	push   %ebp
  801571:	89 e5                	mov    %esp,%ebp
  801573:	56                   	push   %esi
  801574:	53                   	push   %ebx
  801575:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801578:	8b 45 08             	mov    0x8(%ebp),%eax
  80157b:	8b 40 0c             	mov    0xc(%eax),%eax
  80157e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801583:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801589:	ba 00 00 00 00       	mov    $0x0,%edx
  80158e:	b8 03 00 00 00       	mov    $0x3,%eax
  801593:	e8 a2 fe ff ff       	call   80143a <fsipc>
  801598:	89 c3                	mov    %eax,%ebx
  80159a:	85 c0                	test   %eax,%eax
  80159c:	78 4b                	js     8015e9 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80159e:	39 c6                	cmp    %eax,%esi
  8015a0:	73 16                	jae    8015b8 <devfile_read+0x48>
  8015a2:	68 ec 23 80 00       	push   $0x8023ec
  8015a7:	68 f3 23 80 00       	push   $0x8023f3
  8015ac:	6a 7c                	push   $0x7c
  8015ae:	68 08 24 80 00       	push   $0x802408
  8015b3:	e8 d2 eb ff ff       	call   80018a <_panic>
	assert(r <= PGSIZE);
  8015b8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015bd:	7e 16                	jle    8015d5 <devfile_read+0x65>
  8015bf:	68 13 24 80 00       	push   $0x802413
  8015c4:	68 f3 23 80 00       	push   $0x8023f3
  8015c9:	6a 7d                	push   $0x7d
  8015cb:	68 08 24 80 00       	push   $0x802408
  8015d0:	e8 b5 eb ff ff       	call   80018a <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015d5:	83 ec 04             	sub    $0x4,%esp
  8015d8:	50                   	push   %eax
  8015d9:	68 00 50 80 00       	push   $0x805000
  8015de:	ff 75 0c             	pushl  0xc(%ebp)
  8015e1:	e8 94 f3 ff ff       	call   80097a <memmove>
	return r;
  8015e6:	83 c4 10             	add    $0x10,%esp
}
  8015e9:	89 d8                	mov    %ebx,%eax
  8015eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ee:	5b                   	pop    %ebx
  8015ef:	5e                   	pop    %esi
  8015f0:	5d                   	pop    %ebp
  8015f1:	c3                   	ret    

008015f2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015f2:	55                   	push   %ebp
  8015f3:	89 e5                	mov    %esp,%ebp
  8015f5:	53                   	push   %ebx
  8015f6:	83 ec 20             	sub    $0x20,%esp
  8015f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015fc:	53                   	push   %ebx
  8015fd:	e8 ad f1 ff ff       	call   8007af <strlen>
  801602:	83 c4 10             	add    $0x10,%esp
  801605:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80160a:	7f 67                	jg     801673 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80160c:	83 ec 0c             	sub    $0xc,%esp
  80160f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801612:	50                   	push   %eax
  801613:	e8 9a f8 ff ff       	call   800eb2 <fd_alloc>
  801618:	83 c4 10             	add    $0x10,%esp
		return r;
  80161b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80161d:	85 c0                	test   %eax,%eax
  80161f:	78 57                	js     801678 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801621:	83 ec 08             	sub    $0x8,%esp
  801624:	53                   	push   %ebx
  801625:	68 00 50 80 00       	push   $0x805000
  80162a:	e8 b9 f1 ff ff       	call   8007e8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80162f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801632:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801637:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80163a:	b8 01 00 00 00       	mov    $0x1,%eax
  80163f:	e8 f6 fd ff ff       	call   80143a <fsipc>
  801644:	89 c3                	mov    %eax,%ebx
  801646:	83 c4 10             	add    $0x10,%esp
  801649:	85 c0                	test   %eax,%eax
  80164b:	79 14                	jns    801661 <open+0x6f>
		fd_close(fd, 0);
  80164d:	83 ec 08             	sub    $0x8,%esp
  801650:	6a 00                	push   $0x0
  801652:	ff 75 f4             	pushl  -0xc(%ebp)
  801655:	e8 50 f9 ff ff       	call   800faa <fd_close>
		return r;
  80165a:	83 c4 10             	add    $0x10,%esp
  80165d:	89 da                	mov    %ebx,%edx
  80165f:	eb 17                	jmp    801678 <open+0x86>
	}

	return fd2num(fd);
  801661:	83 ec 0c             	sub    $0xc,%esp
  801664:	ff 75 f4             	pushl  -0xc(%ebp)
  801667:	e8 1f f8 ff ff       	call   800e8b <fd2num>
  80166c:	89 c2                	mov    %eax,%edx
  80166e:	83 c4 10             	add    $0x10,%esp
  801671:	eb 05                	jmp    801678 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801673:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801678:	89 d0                	mov    %edx,%eax
  80167a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167d:	c9                   	leave  
  80167e:	c3                   	ret    

0080167f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801685:	ba 00 00 00 00       	mov    $0x0,%edx
  80168a:	b8 08 00 00 00       	mov    $0x8,%eax
  80168f:	e8 a6 fd ff ff       	call   80143a <fsipc>
}
  801694:	c9                   	leave  
  801695:	c3                   	ret    

00801696 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801696:	55                   	push   %ebp
  801697:	89 e5                	mov    %esp,%ebp
  801699:	56                   	push   %esi
  80169a:	53                   	push   %ebx
  80169b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80169e:	83 ec 0c             	sub    $0xc,%esp
  8016a1:	ff 75 08             	pushl  0x8(%ebp)
  8016a4:	e8 f2 f7 ff ff       	call   800e9b <fd2data>
  8016a9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8016ab:	83 c4 08             	add    $0x8,%esp
  8016ae:	68 1f 24 80 00       	push   $0x80241f
  8016b3:	53                   	push   %ebx
  8016b4:	e8 2f f1 ff ff       	call   8007e8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8016b9:	8b 46 04             	mov    0x4(%esi),%eax
  8016bc:	2b 06                	sub    (%esi),%eax
  8016be:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8016c4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016cb:	00 00 00 
	stat->st_dev = &devpipe;
  8016ce:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016d5:	30 80 00 
	return 0;
}
  8016d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8016dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016e0:	5b                   	pop    %ebx
  8016e1:	5e                   	pop    %esi
  8016e2:	5d                   	pop    %ebp
  8016e3:	c3                   	ret    

008016e4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016e4:	55                   	push   %ebp
  8016e5:	89 e5                	mov    %esp,%ebp
  8016e7:	53                   	push   %ebx
  8016e8:	83 ec 0c             	sub    $0xc,%esp
  8016eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016ee:	53                   	push   %ebx
  8016ef:	6a 00                	push   $0x0
  8016f1:	e8 7a f5 ff ff       	call   800c70 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016f6:	89 1c 24             	mov    %ebx,(%esp)
  8016f9:	e8 9d f7 ff ff       	call   800e9b <fd2data>
  8016fe:	83 c4 08             	add    $0x8,%esp
  801701:	50                   	push   %eax
  801702:	6a 00                	push   $0x0
  801704:	e8 67 f5 ff ff       	call   800c70 <sys_page_unmap>
}
  801709:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170c:	c9                   	leave  
  80170d:	c3                   	ret    

0080170e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80170e:	55                   	push   %ebp
  80170f:	89 e5                	mov    %esp,%ebp
  801711:	57                   	push   %edi
  801712:	56                   	push   %esi
  801713:	53                   	push   %ebx
  801714:	83 ec 1c             	sub    $0x1c,%esp
  801717:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80171a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80171c:	a1 04 40 80 00       	mov    0x804004,%eax
  801721:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801724:	83 ec 0c             	sub    $0xc,%esp
  801727:	ff 75 e0             	pushl  -0x20(%ebp)
  80172a:	e8 5d 05 00 00       	call   801c8c <pageref>
  80172f:	89 c3                	mov    %eax,%ebx
  801731:	89 3c 24             	mov    %edi,(%esp)
  801734:	e8 53 05 00 00       	call   801c8c <pageref>
  801739:	83 c4 10             	add    $0x10,%esp
  80173c:	39 c3                	cmp    %eax,%ebx
  80173e:	0f 94 c1             	sete   %cl
  801741:	0f b6 c9             	movzbl %cl,%ecx
  801744:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801747:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80174d:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  801750:	39 ce                	cmp    %ecx,%esi
  801752:	74 1b                	je     80176f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801754:	39 c3                	cmp    %eax,%ebx
  801756:	75 c4                	jne    80171c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801758:	8b 42 60             	mov    0x60(%edx),%eax
  80175b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80175e:	50                   	push   %eax
  80175f:	56                   	push   %esi
  801760:	68 26 24 80 00       	push   $0x802426
  801765:	e8 f9 ea ff ff       	call   800263 <cprintf>
  80176a:	83 c4 10             	add    $0x10,%esp
  80176d:	eb ad                	jmp    80171c <_pipeisclosed+0xe>
	}
}
  80176f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801772:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801775:	5b                   	pop    %ebx
  801776:	5e                   	pop    %esi
  801777:	5f                   	pop    %edi
  801778:	5d                   	pop    %ebp
  801779:	c3                   	ret    

0080177a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80177a:	55                   	push   %ebp
  80177b:	89 e5                	mov    %esp,%ebp
  80177d:	57                   	push   %edi
  80177e:	56                   	push   %esi
  80177f:	53                   	push   %ebx
  801780:	83 ec 28             	sub    $0x28,%esp
  801783:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801786:	56                   	push   %esi
  801787:	e8 0f f7 ff ff       	call   800e9b <fd2data>
  80178c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80178e:	83 c4 10             	add    $0x10,%esp
  801791:	bf 00 00 00 00       	mov    $0x0,%edi
  801796:	eb 4b                	jmp    8017e3 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801798:	89 da                	mov    %ebx,%edx
  80179a:	89 f0                	mov    %esi,%eax
  80179c:	e8 6d ff ff ff       	call   80170e <_pipeisclosed>
  8017a1:	85 c0                	test   %eax,%eax
  8017a3:	75 48                	jne    8017ed <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8017a5:	e8 22 f4 ff ff       	call   800bcc <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017aa:	8b 43 04             	mov    0x4(%ebx),%eax
  8017ad:	8b 0b                	mov    (%ebx),%ecx
  8017af:	8d 51 20             	lea    0x20(%ecx),%edx
  8017b2:	39 d0                	cmp    %edx,%eax
  8017b4:	73 e2                	jae    801798 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8017b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017b9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8017bd:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8017c0:	89 c2                	mov    %eax,%edx
  8017c2:	c1 fa 1f             	sar    $0x1f,%edx
  8017c5:	89 d1                	mov    %edx,%ecx
  8017c7:	c1 e9 1b             	shr    $0x1b,%ecx
  8017ca:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8017cd:	83 e2 1f             	and    $0x1f,%edx
  8017d0:	29 ca                	sub    %ecx,%edx
  8017d2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8017d6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017da:	83 c0 01             	add    $0x1,%eax
  8017dd:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017e0:	83 c7 01             	add    $0x1,%edi
  8017e3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017e6:	75 c2                	jne    8017aa <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8017e8:	8b 45 10             	mov    0x10(%ebp),%eax
  8017eb:	eb 05                	jmp    8017f2 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017ed:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8017f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017f5:	5b                   	pop    %ebx
  8017f6:	5e                   	pop    %esi
  8017f7:	5f                   	pop    %edi
  8017f8:	5d                   	pop    %ebp
  8017f9:	c3                   	ret    

008017fa <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017fa:	55                   	push   %ebp
  8017fb:	89 e5                	mov    %esp,%ebp
  8017fd:	57                   	push   %edi
  8017fe:	56                   	push   %esi
  8017ff:	53                   	push   %ebx
  801800:	83 ec 18             	sub    $0x18,%esp
  801803:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801806:	57                   	push   %edi
  801807:	e8 8f f6 ff ff       	call   800e9b <fd2data>
  80180c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80180e:	83 c4 10             	add    $0x10,%esp
  801811:	bb 00 00 00 00       	mov    $0x0,%ebx
  801816:	eb 3d                	jmp    801855 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801818:	85 db                	test   %ebx,%ebx
  80181a:	74 04                	je     801820 <devpipe_read+0x26>
				return i;
  80181c:	89 d8                	mov    %ebx,%eax
  80181e:	eb 44                	jmp    801864 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801820:	89 f2                	mov    %esi,%edx
  801822:	89 f8                	mov    %edi,%eax
  801824:	e8 e5 fe ff ff       	call   80170e <_pipeisclosed>
  801829:	85 c0                	test   %eax,%eax
  80182b:	75 32                	jne    80185f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80182d:	e8 9a f3 ff ff       	call   800bcc <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801832:	8b 06                	mov    (%esi),%eax
  801834:	3b 46 04             	cmp    0x4(%esi),%eax
  801837:	74 df                	je     801818 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801839:	99                   	cltd   
  80183a:	c1 ea 1b             	shr    $0x1b,%edx
  80183d:	01 d0                	add    %edx,%eax
  80183f:	83 e0 1f             	and    $0x1f,%eax
  801842:	29 d0                	sub    %edx,%eax
  801844:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801849:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80184c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80184f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801852:	83 c3 01             	add    $0x1,%ebx
  801855:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801858:	75 d8                	jne    801832 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80185a:	8b 45 10             	mov    0x10(%ebp),%eax
  80185d:	eb 05                	jmp    801864 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80185f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801864:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801867:	5b                   	pop    %ebx
  801868:	5e                   	pop    %esi
  801869:	5f                   	pop    %edi
  80186a:	5d                   	pop    %ebp
  80186b:	c3                   	ret    

0080186c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80186c:	55                   	push   %ebp
  80186d:	89 e5                	mov    %esp,%ebp
  80186f:	56                   	push   %esi
  801870:	53                   	push   %ebx
  801871:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801874:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801877:	50                   	push   %eax
  801878:	e8 35 f6 ff ff       	call   800eb2 <fd_alloc>
  80187d:	83 c4 10             	add    $0x10,%esp
  801880:	89 c2                	mov    %eax,%edx
  801882:	85 c0                	test   %eax,%eax
  801884:	0f 88 2c 01 00 00    	js     8019b6 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80188a:	83 ec 04             	sub    $0x4,%esp
  80188d:	68 07 04 00 00       	push   $0x407
  801892:	ff 75 f4             	pushl  -0xc(%ebp)
  801895:	6a 00                	push   $0x0
  801897:	e8 4f f3 ff ff       	call   800beb <sys_page_alloc>
  80189c:	83 c4 10             	add    $0x10,%esp
  80189f:	89 c2                	mov    %eax,%edx
  8018a1:	85 c0                	test   %eax,%eax
  8018a3:	0f 88 0d 01 00 00    	js     8019b6 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8018a9:	83 ec 0c             	sub    $0xc,%esp
  8018ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018af:	50                   	push   %eax
  8018b0:	e8 fd f5 ff ff       	call   800eb2 <fd_alloc>
  8018b5:	89 c3                	mov    %eax,%ebx
  8018b7:	83 c4 10             	add    $0x10,%esp
  8018ba:	85 c0                	test   %eax,%eax
  8018bc:	0f 88 e2 00 00 00    	js     8019a4 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018c2:	83 ec 04             	sub    $0x4,%esp
  8018c5:	68 07 04 00 00       	push   $0x407
  8018ca:	ff 75 f0             	pushl  -0x10(%ebp)
  8018cd:	6a 00                	push   $0x0
  8018cf:	e8 17 f3 ff ff       	call   800beb <sys_page_alloc>
  8018d4:	89 c3                	mov    %eax,%ebx
  8018d6:	83 c4 10             	add    $0x10,%esp
  8018d9:	85 c0                	test   %eax,%eax
  8018db:	0f 88 c3 00 00 00    	js     8019a4 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8018e1:	83 ec 0c             	sub    $0xc,%esp
  8018e4:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e7:	e8 af f5 ff ff       	call   800e9b <fd2data>
  8018ec:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018ee:	83 c4 0c             	add    $0xc,%esp
  8018f1:	68 07 04 00 00       	push   $0x407
  8018f6:	50                   	push   %eax
  8018f7:	6a 00                	push   $0x0
  8018f9:	e8 ed f2 ff ff       	call   800beb <sys_page_alloc>
  8018fe:	89 c3                	mov    %eax,%ebx
  801900:	83 c4 10             	add    $0x10,%esp
  801903:	85 c0                	test   %eax,%eax
  801905:	0f 88 89 00 00 00    	js     801994 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80190b:	83 ec 0c             	sub    $0xc,%esp
  80190e:	ff 75 f0             	pushl  -0x10(%ebp)
  801911:	e8 85 f5 ff ff       	call   800e9b <fd2data>
  801916:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80191d:	50                   	push   %eax
  80191e:	6a 00                	push   $0x0
  801920:	56                   	push   %esi
  801921:	6a 00                	push   $0x0
  801923:	e8 06 f3 ff ff       	call   800c2e <sys_page_map>
  801928:	89 c3                	mov    %eax,%ebx
  80192a:	83 c4 20             	add    $0x20,%esp
  80192d:	85 c0                	test   %eax,%eax
  80192f:	78 55                	js     801986 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801931:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801937:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80193a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80193c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80193f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801946:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80194c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80194f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801951:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801954:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80195b:	83 ec 0c             	sub    $0xc,%esp
  80195e:	ff 75 f4             	pushl  -0xc(%ebp)
  801961:	e8 25 f5 ff ff       	call   800e8b <fd2num>
  801966:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801969:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80196b:	83 c4 04             	add    $0x4,%esp
  80196e:	ff 75 f0             	pushl  -0x10(%ebp)
  801971:	e8 15 f5 ff ff       	call   800e8b <fd2num>
  801976:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801979:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80197c:	83 c4 10             	add    $0x10,%esp
  80197f:	ba 00 00 00 00       	mov    $0x0,%edx
  801984:	eb 30                	jmp    8019b6 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801986:	83 ec 08             	sub    $0x8,%esp
  801989:	56                   	push   %esi
  80198a:	6a 00                	push   $0x0
  80198c:	e8 df f2 ff ff       	call   800c70 <sys_page_unmap>
  801991:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801994:	83 ec 08             	sub    $0x8,%esp
  801997:	ff 75 f0             	pushl  -0x10(%ebp)
  80199a:	6a 00                	push   $0x0
  80199c:	e8 cf f2 ff ff       	call   800c70 <sys_page_unmap>
  8019a1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8019a4:	83 ec 08             	sub    $0x8,%esp
  8019a7:	ff 75 f4             	pushl  -0xc(%ebp)
  8019aa:	6a 00                	push   $0x0
  8019ac:	e8 bf f2 ff ff       	call   800c70 <sys_page_unmap>
  8019b1:	83 c4 10             	add    $0x10,%esp
  8019b4:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8019b6:	89 d0                	mov    %edx,%eax
  8019b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019bb:	5b                   	pop    %ebx
  8019bc:	5e                   	pop    %esi
  8019bd:	5d                   	pop    %ebp
  8019be:	c3                   	ret    

008019bf <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8019bf:	55                   	push   %ebp
  8019c0:	89 e5                	mov    %esp,%ebp
  8019c2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c8:	50                   	push   %eax
  8019c9:	ff 75 08             	pushl  0x8(%ebp)
  8019cc:	e8 30 f5 ff ff       	call   800f01 <fd_lookup>
  8019d1:	83 c4 10             	add    $0x10,%esp
  8019d4:	85 c0                	test   %eax,%eax
  8019d6:	78 18                	js     8019f0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8019d8:	83 ec 0c             	sub    $0xc,%esp
  8019db:	ff 75 f4             	pushl  -0xc(%ebp)
  8019de:	e8 b8 f4 ff ff       	call   800e9b <fd2data>
	return _pipeisclosed(fd, p);
  8019e3:	89 c2                	mov    %eax,%edx
  8019e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e8:	e8 21 fd ff ff       	call   80170e <_pipeisclosed>
  8019ed:	83 c4 10             	add    $0x10,%esp
}
  8019f0:	c9                   	leave  
  8019f1:	c3                   	ret    

008019f2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019f2:	55                   	push   %ebp
  8019f3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8019fa:	5d                   	pop    %ebp
  8019fb:	c3                   	ret    

008019fc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a02:	68 3e 24 80 00       	push   $0x80243e
  801a07:	ff 75 0c             	pushl  0xc(%ebp)
  801a0a:	e8 d9 ed ff ff       	call   8007e8 <strcpy>
	return 0;
}
  801a0f:	b8 00 00 00 00       	mov    $0x0,%eax
  801a14:	c9                   	leave  
  801a15:	c3                   	ret    

00801a16 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a16:	55                   	push   %ebp
  801a17:	89 e5                	mov    %esp,%ebp
  801a19:	57                   	push   %edi
  801a1a:	56                   	push   %esi
  801a1b:	53                   	push   %ebx
  801a1c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a22:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a27:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a2d:	eb 2d                	jmp    801a5c <devcons_write+0x46>
		m = n - tot;
  801a2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a32:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801a34:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801a37:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801a3c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a3f:	83 ec 04             	sub    $0x4,%esp
  801a42:	53                   	push   %ebx
  801a43:	03 45 0c             	add    0xc(%ebp),%eax
  801a46:	50                   	push   %eax
  801a47:	57                   	push   %edi
  801a48:	e8 2d ef ff ff       	call   80097a <memmove>
		sys_cputs(buf, m);
  801a4d:	83 c4 08             	add    $0x8,%esp
  801a50:	53                   	push   %ebx
  801a51:	57                   	push   %edi
  801a52:	e8 d8 f0 ff ff       	call   800b2f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a57:	01 de                	add    %ebx,%esi
  801a59:	83 c4 10             	add    $0x10,%esp
  801a5c:	89 f0                	mov    %esi,%eax
  801a5e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a61:	72 cc                	jb     801a2f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a66:	5b                   	pop    %ebx
  801a67:	5e                   	pop    %esi
  801a68:	5f                   	pop    %edi
  801a69:	5d                   	pop    %ebp
  801a6a:	c3                   	ret    

00801a6b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	83 ec 08             	sub    $0x8,%esp
  801a71:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801a76:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a7a:	74 2a                	je     801aa6 <devcons_read+0x3b>
  801a7c:	eb 05                	jmp    801a83 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a7e:	e8 49 f1 ff ff       	call   800bcc <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a83:	e8 c5 f0 ff ff       	call   800b4d <sys_cgetc>
  801a88:	85 c0                	test   %eax,%eax
  801a8a:	74 f2                	je     801a7e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a8c:	85 c0                	test   %eax,%eax
  801a8e:	78 16                	js     801aa6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a90:	83 f8 04             	cmp    $0x4,%eax
  801a93:	74 0c                	je     801aa1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a95:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a98:	88 02                	mov    %al,(%edx)
	return 1;
  801a9a:	b8 01 00 00 00       	mov    $0x1,%eax
  801a9f:	eb 05                	jmp    801aa6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801aa1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801aa6:	c9                   	leave  
  801aa7:	c3                   	ret    

00801aa8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801aae:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ab4:	6a 01                	push   $0x1
  801ab6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ab9:	50                   	push   %eax
  801aba:	e8 70 f0 ff ff       	call   800b2f <sys_cputs>
}
  801abf:	83 c4 10             	add    $0x10,%esp
  801ac2:	c9                   	leave  
  801ac3:	c3                   	ret    

00801ac4 <getchar>:

int
getchar(void)
{
  801ac4:	55                   	push   %ebp
  801ac5:	89 e5                	mov    %esp,%ebp
  801ac7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801aca:	6a 01                	push   $0x1
  801acc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801acf:	50                   	push   %eax
  801ad0:	6a 00                	push   $0x0
  801ad2:	e8 90 f6 ff ff       	call   801167 <read>
	if (r < 0)
  801ad7:	83 c4 10             	add    $0x10,%esp
  801ada:	85 c0                	test   %eax,%eax
  801adc:	78 0f                	js     801aed <getchar+0x29>
		return r;
	if (r < 1)
  801ade:	85 c0                	test   %eax,%eax
  801ae0:	7e 06                	jle    801ae8 <getchar+0x24>
		return -E_EOF;
	return c;
  801ae2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ae6:	eb 05                	jmp    801aed <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ae8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801aed:	c9                   	leave  
  801aee:	c3                   	ret    

00801aef <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801aef:	55                   	push   %ebp
  801af0:	89 e5                	mov    %esp,%ebp
  801af2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801af5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801af8:	50                   	push   %eax
  801af9:	ff 75 08             	pushl  0x8(%ebp)
  801afc:	e8 00 f4 ff ff       	call   800f01 <fd_lookup>
  801b01:	83 c4 10             	add    $0x10,%esp
  801b04:	85 c0                	test   %eax,%eax
  801b06:	78 11                	js     801b19 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b0b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b11:	39 10                	cmp    %edx,(%eax)
  801b13:	0f 94 c0             	sete   %al
  801b16:	0f b6 c0             	movzbl %al,%eax
}
  801b19:	c9                   	leave  
  801b1a:	c3                   	ret    

00801b1b <opencons>:

int
opencons(void)
{
  801b1b:	55                   	push   %ebp
  801b1c:	89 e5                	mov    %esp,%ebp
  801b1e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b24:	50                   	push   %eax
  801b25:	e8 88 f3 ff ff       	call   800eb2 <fd_alloc>
  801b2a:	83 c4 10             	add    $0x10,%esp
		return r;
  801b2d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b2f:	85 c0                	test   %eax,%eax
  801b31:	78 3e                	js     801b71 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b33:	83 ec 04             	sub    $0x4,%esp
  801b36:	68 07 04 00 00       	push   $0x407
  801b3b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b3e:	6a 00                	push   $0x0
  801b40:	e8 a6 f0 ff ff       	call   800beb <sys_page_alloc>
  801b45:	83 c4 10             	add    $0x10,%esp
		return r;
  801b48:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b4a:	85 c0                	test   %eax,%eax
  801b4c:	78 23                	js     801b71 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b4e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b57:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b5c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b63:	83 ec 0c             	sub    $0xc,%esp
  801b66:	50                   	push   %eax
  801b67:	e8 1f f3 ff ff       	call   800e8b <fd2num>
  801b6c:	89 c2                	mov    %eax,%edx
  801b6e:	83 c4 10             	add    $0x10,%esp
}
  801b71:	89 d0                	mov    %edx,%eax
  801b73:	c9                   	leave  
  801b74:	c3                   	ret    

00801b75 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b75:	55                   	push   %ebp
  801b76:	89 e5                	mov    %esp,%ebp
  801b78:	56                   	push   %esi
  801b79:	53                   	push   %ebx
  801b7a:	8b 75 08             	mov    0x8(%ebp),%esi
  801b7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b80:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801b83:	85 c0                	test   %eax,%eax
  801b85:	75 12                	jne    801b99 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801b87:	83 ec 0c             	sub    $0xc,%esp
  801b8a:	68 00 00 c0 ee       	push   $0xeec00000
  801b8f:	e8 07 f2 ff ff       	call   800d9b <sys_ipc_recv>
  801b94:	83 c4 10             	add    $0x10,%esp
  801b97:	eb 0c                	jmp    801ba5 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801b99:	83 ec 0c             	sub    $0xc,%esp
  801b9c:	50                   	push   %eax
  801b9d:	e8 f9 f1 ff ff       	call   800d9b <sys_ipc_recv>
  801ba2:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801ba5:	85 f6                	test   %esi,%esi
  801ba7:	0f 95 c1             	setne  %cl
  801baa:	85 db                	test   %ebx,%ebx
  801bac:	0f 95 c2             	setne  %dl
  801baf:	84 d1                	test   %dl,%cl
  801bb1:	74 09                	je     801bbc <ipc_recv+0x47>
  801bb3:	89 c2                	mov    %eax,%edx
  801bb5:	c1 ea 1f             	shr    $0x1f,%edx
  801bb8:	84 d2                	test   %dl,%dl
  801bba:	75 27                	jne    801be3 <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801bbc:	85 f6                	test   %esi,%esi
  801bbe:	74 0a                	je     801bca <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801bc0:	a1 04 40 80 00       	mov    0x804004,%eax
  801bc5:	8b 40 7c             	mov    0x7c(%eax),%eax
  801bc8:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801bca:	85 db                	test   %ebx,%ebx
  801bcc:	74 0d                	je     801bdb <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  801bce:	a1 04 40 80 00       	mov    0x804004,%eax
  801bd3:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801bd9:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801bdb:	a1 04 40 80 00       	mov    0x804004,%eax
  801be0:	8b 40 78             	mov    0x78(%eax),%eax
}
  801be3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801be6:	5b                   	pop    %ebx
  801be7:	5e                   	pop    %esi
  801be8:	5d                   	pop    %ebp
  801be9:	c3                   	ret    

00801bea <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bea:	55                   	push   %ebp
  801beb:	89 e5                	mov    %esp,%ebp
  801bed:	57                   	push   %edi
  801bee:	56                   	push   %esi
  801bef:	53                   	push   %ebx
  801bf0:	83 ec 0c             	sub    $0xc,%esp
  801bf3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bf6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bf9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801bfc:	85 db                	test   %ebx,%ebx
  801bfe:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801c03:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801c06:	ff 75 14             	pushl  0x14(%ebp)
  801c09:	53                   	push   %ebx
  801c0a:	56                   	push   %esi
  801c0b:	57                   	push   %edi
  801c0c:	e8 67 f1 ff ff       	call   800d78 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801c11:	89 c2                	mov    %eax,%edx
  801c13:	c1 ea 1f             	shr    $0x1f,%edx
  801c16:	83 c4 10             	add    $0x10,%esp
  801c19:	84 d2                	test   %dl,%dl
  801c1b:	74 17                	je     801c34 <ipc_send+0x4a>
  801c1d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c20:	74 12                	je     801c34 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801c22:	50                   	push   %eax
  801c23:	68 4a 24 80 00       	push   $0x80244a
  801c28:	6a 47                	push   $0x47
  801c2a:	68 58 24 80 00       	push   $0x802458
  801c2f:	e8 56 e5 ff ff       	call   80018a <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801c34:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c37:	75 07                	jne    801c40 <ipc_send+0x56>
			sys_yield();
  801c39:	e8 8e ef ff ff       	call   800bcc <sys_yield>
  801c3e:	eb c6                	jmp    801c06 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801c40:	85 c0                	test   %eax,%eax
  801c42:	75 c2                	jne    801c06 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801c44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c47:	5b                   	pop    %ebx
  801c48:	5e                   	pop    %esi
  801c49:	5f                   	pop    %edi
  801c4a:	5d                   	pop    %ebp
  801c4b:	c3                   	ret    

00801c4c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c4c:	55                   	push   %ebp
  801c4d:	89 e5                	mov    %esp,%ebp
  801c4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c52:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c57:	89 c2                	mov    %eax,%edx
  801c59:	c1 e2 07             	shl    $0x7,%edx
  801c5c:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801c63:	8b 52 58             	mov    0x58(%edx),%edx
  801c66:	39 ca                	cmp    %ecx,%edx
  801c68:	75 11                	jne    801c7b <ipc_find_env+0x2f>
			return envs[i].env_id;
  801c6a:	89 c2                	mov    %eax,%edx
  801c6c:	c1 e2 07             	shl    $0x7,%edx
  801c6f:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801c76:	8b 40 50             	mov    0x50(%eax),%eax
  801c79:	eb 0f                	jmp    801c8a <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c7b:	83 c0 01             	add    $0x1,%eax
  801c7e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c83:	75 d2                	jne    801c57 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c85:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c8a:	5d                   	pop    %ebp
  801c8b:	c3                   	ret    

00801c8c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c8c:	55                   	push   %ebp
  801c8d:	89 e5                	mov    %esp,%ebp
  801c8f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c92:	89 d0                	mov    %edx,%eax
  801c94:	c1 e8 16             	shr    $0x16,%eax
  801c97:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c9e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ca3:	f6 c1 01             	test   $0x1,%cl
  801ca6:	74 1d                	je     801cc5 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ca8:	c1 ea 0c             	shr    $0xc,%edx
  801cab:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801cb2:	f6 c2 01             	test   $0x1,%dl
  801cb5:	74 0e                	je     801cc5 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801cb7:	c1 ea 0c             	shr    $0xc,%edx
  801cba:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801cc1:	ef 
  801cc2:	0f b7 c0             	movzwl %ax,%eax
}
  801cc5:	5d                   	pop    %ebp
  801cc6:	c3                   	ret    
  801cc7:	66 90                	xchg   %ax,%ax
  801cc9:	66 90                	xchg   %ax,%ax
  801ccb:	66 90                	xchg   %ax,%ax
  801ccd:	66 90                	xchg   %ax,%ax
  801ccf:	90                   	nop

00801cd0 <__udivdi3>:
  801cd0:	55                   	push   %ebp
  801cd1:	57                   	push   %edi
  801cd2:	56                   	push   %esi
  801cd3:	53                   	push   %ebx
  801cd4:	83 ec 1c             	sub    $0x1c,%esp
  801cd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801cdb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801cdf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ce3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ce7:	85 f6                	test   %esi,%esi
  801ce9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ced:	89 ca                	mov    %ecx,%edx
  801cef:	89 f8                	mov    %edi,%eax
  801cf1:	75 3d                	jne    801d30 <__udivdi3+0x60>
  801cf3:	39 cf                	cmp    %ecx,%edi
  801cf5:	0f 87 c5 00 00 00    	ja     801dc0 <__udivdi3+0xf0>
  801cfb:	85 ff                	test   %edi,%edi
  801cfd:	89 fd                	mov    %edi,%ebp
  801cff:	75 0b                	jne    801d0c <__udivdi3+0x3c>
  801d01:	b8 01 00 00 00       	mov    $0x1,%eax
  801d06:	31 d2                	xor    %edx,%edx
  801d08:	f7 f7                	div    %edi
  801d0a:	89 c5                	mov    %eax,%ebp
  801d0c:	89 c8                	mov    %ecx,%eax
  801d0e:	31 d2                	xor    %edx,%edx
  801d10:	f7 f5                	div    %ebp
  801d12:	89 c1                	mov    %eax,%ecx
  801d14:	89 d8                	mov    %ebx,%eax
  801d16:	89 cf                	mov    %ecx,%edi
  801d18:	f7 f5                	div    %ebp
  801d1a:	89 c3                	mov    %eax,%ebx
  801d1c:	89 d8                	mov    %ebx,%eax
  801d1e:	89 fa                	mov    %edi,%edx
  801d20:	83 c4 1c             	add    $0x1c,%esp
  801d23:	5b                   	pop    %ebx
  801d24:	5e                   	pop    %esi
  801d25:	5f                   	pop    %edi
  801d26:	5d                   	pop    %ebp
  801d27:	c3                   	ret    
  801d28:	90                   	nop
  801d29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d30:	39 ce                	cmp    %ecx,%esi
  801d32:	77 74                	ja     801da8 <__udivdi3+0xd8>
  801d34:	0f bd fe             	bsr    %esi,%edi
  801d37:	83 f7 1f             	xor    $0x1f,%edi
  801d3a:	0f 84 98 00 00 00    	je     801dd8 <__udivdi3+0x108>
  801d40:	bb 20 00 00 00       	mov    $0x20,%ebx
  801d45:	89 f9                	mov    %edi,%ecx
  801d47:	89 c5                	mov    %eax,%ebp
  801d49:	29 fb                	sub    %edi,%ebx
  801d4b:	d3 e6                	shl    %cl,%esi
  801d4d:	89 d9                	mov    %ebx,%ecx
  801d4f:	d3 ed                	shr    %cl,%ebp
  801d51:	89 f9                	mov    %edi,%ecx
  801d53:	d3 e0                	shl    %cl,%eax
  801d55:	09 ee                	or     %ebp,%esi
  801d57:	89 d9                	mov    %ebx,%ecx
  801d59:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d5d:	89 d5                	mov    %edx,%ebp
  801d5f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d63:	d3 ed                	shr    %cl,%ebp
  801d65:	89 f9                	mov    %edi,%ecx
  801d67:	d3 e2                	shl    %cl,%edx
  801d69:	89 d9                	mov    %ebx,%ecx
  801d6b:	d3 e8                	shr    %cl,%eax
  801d6d:	09 c2                	or     %eax,%edx
  801d6f:	89 d0                	mov    %edx,%eax
  801d71:	89 ea                	mov    %ebp,%edx
  801d73:	f7 f6                	div    %esi
  801d75:	89 d5                	mov    %edx,%ebp
  801d77:	89 c3                	mov    %eax,%ebx
  801d79:	f7 64 24 0c          	mull   0xc(%esp)
  801d7d:	39 d5                	cmp    %edx,%ebp
  801d7f:	72 10                	jb     801d91 <__udivdi3+0xc1>
  801d81:	8b 74 24 08          	mov    0x8(%esp),%esi
  801d85:	89 f9                	mov    %edi,%ecx
  801d87:	d3 e6                	shl    %cl,%esi
  801d89:	39 c6                	cmp    %eax,%esi
  801d8b:	73 07                	jae    801d94 <__udivdi3+0xc4>
  801d8d:	39 d5                	cmp    %edx,%ebp
  801d8f:	75 03                	jne    801d94 <__udivdi3+0xc4>
  801d91:	83 eb 01             	sub    $0x1,%ebx
  801d94:	31 ff                	xor    %edi,%edi
  801d96:	89 d8                	mov    %ebx,%eax
  801d98:	89 fa                	mov    %edi,%edx
  801d9a:	83 c4 1c             	add    $0x1c,%esp
  801d9d:	5b                   	pop    %ebx
  801d9e:	5e                   	pop    %esi
  801d9f:	5f                   	pop    %edi
  801da0:	5d                   	pop    %ebp
  801da1:	c3                   	ret    
  801da2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801da8:	31 ff                	xor    %edi,%edi
  801daa:	31 db                	xor    %ebx,%ebx
  801dac:	89 d8                	mov    %ebx,%eax
  801dae:	89 fa                	mov    %edi,%edx
  801db0:	83 c4 1c             	add    $0x1c,%esp
  801db3:	5b                   	pop    %ebx
  801db4:	5e                   	pop    %esi
  801db5:	5f                   	pop    %edi
  801db6:	5d                   	pop    %ebp
  801db7:	c3                   	ret    
  801db8:	90                   	nop
  801db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dc0:	89 d8                	mov    %ebx,%eax
  801dc2:	f7 f7                	div    %edi
  801dc4:	31 ff                	xor    %edi,%edi
  801dc6:	89 c3                	mov    %eax,%ebx
  801dc8:	89 d8                	mov    %ebx,%eax
  801dca:	89 fa                	mov    %edi,%edx
  801dcc:	83 c4 1c             	add    $0x1c,%esp
  801dcf:	5b                   	pop    %ebx
  801dd0:	5e                   	pop    %esi
  801dd1:	5f                   	pop    %edi
  801dd2:	5d                   	pop    %ebp
  801dd3:	c3                   	ret    
  801dd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801dd8:	39 ce                	cmp    %ecx,%esi
  801dda:	72 0c                	jb     801de8 <__udivdi3+0x118>
  801ddc:	31 db                	xor    %ebx,%ebx
  801dde:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801de2:	0f 87 34 ff ff ff    	ja     801d1c <__udivdi3+0x4c>
  801de8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801ded:	e9 2a ff ff ff       	jmp    801d1c <__udivdi3+0x4c>
  801df2:	66 90                	xchg   %ax,%ax
  801df4:	66 90                	xchg   %ax,%ax
  801df6:	66 90                	xchg   %ax,%ax
  801df8:	66 90                	xchg   %ax,%ax
  801dfa:	66 90                	xchg   %ax,%ax
  801dfc:	66 90                	xchg   %ax,%ax
  801dfe:	66 90                	xchg   %ax,%ax

00801e00 <__umoddi3>:
  801e00:	55                   	push   %ebp
  801e01:	57                   	push   %edi
  801e02:	56                   	push   %esi
  801e03:	53                   	push   %ebx
  801e04:	83 ec 1c             	sub    $0x1c,%esp
  801e07:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801e0b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801e0f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801e13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e17:	85 d2                	test   %edx,%edx
  801e19:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e21:	89 f3                	mov    %esi,%ebx
  801e23:	89 3c 24             	mov    %edi,(%esp)
  801e26:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e2a:	75 1c                	jne    801e48 <__umoddi3+0x48>
  801e2c:	39 f7                	cmp    %esi,%edi
  801e2e:	76 50                	jbe    801e80 <__umoddi3+0x80>
  801e30:	89 c8                	mov    %ecx,%eax
  801e32:	89 f2                	mov    %esi,%edx
  801e34:	f7 f7                	div    %edi
  801e36:	89 d0                	mov    %edx,%eax
  801e38:	31 d2                	xor    %edx,%edx
  801e3a:	83 c4 1c             	add    $0x1c,%esp
  801e3d:	5b                   	pop    %ebx
  801e3e:	5e                   	pop    %esi
  801e3f:	5f                   	pop    %edi
  801e40:	5d                   	pop    %ebp
  801e41:	c3                   	ret    
  801e42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e48:	39 f2                	cmp    %esi,%edx
  801e4a:	89 d0                	mov    %edx,%eax
  801e4c:	77 52                	ja     801ea0 <__umoddi3+0xa0>
  801e4e:	0f bd ea             	bsr    %edx,%ebp
  801e51:	83 f5 1f             	xor    $0x1f,%ebp
  801e54:	75 5a                	jne    801eb0 <__umoddi3+0xb0>
  801e56:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801e5a:	0f 82 e0 00 00 00    	jb     801f40 <__umoddi3+0x140>
  801e60:	39 0c 24             	cmp    %ecx,(%esp)
  801e63:	0f 86 d7 00 00 00    	jbe    801f40 <__umoddi3+0x140>
  801e69:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e6d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e71:	83 c4 1c             	add    $0x1c,%esp
  801e74:	5b                   	pop    %ebx
  801e75:	5e                   	pop    %esi
  801e76:	5f                   	pop    %edi
  801e77:	5d                   	pop    %ebp
  801e78:	c3                   	ret    
  801e79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e80:	85 ff                	test   %edi,%edi
  801e82:	89 fd                	mov    %edi,%ebp
  801e84:	75 0b                	jne    801e91 <__umoddi3+0x91>
  801e86:	b8 01 00 00 00       	mov    $0x1,%eax
  801e8b:	31 d2                	xor    %edx,%edx
  801e8d:	f7 f7                	div    %edi
  801e8f:	89 c5                	mov    %eax,%ebp
  801e91:	89 f0                	mov    %esi,%eax
  801e93:	31 d2                	xor    %edx,%edx
  801e95:	f7 f5                	div    %ebp
  801e97:	89 c8                	mov    %ecx,%eax
  801e99:	f7 f5                	div    %ebp
  801e9b:	89 d0                	mov    %edx,%eax
  801e9d:	eb 99                	jmp    801e38 <__umoddi3+0x38>
  801e9f:	90                   	nop
  801ea0:	89 c8                	mov    %ecx,%eax
  801ea2:	89 f2                	mov    %esi,%edx
  801ea4:	83 c4 1c             	add    $0x1c,%esp
  801ea7:	5b                   	pop    %ebx
  801ea8:	5e                   	pop    %esi
  801ea9:	5f                   	pop    %edi
  801eaa:	5d                   	pop    %ebp
  801eab:	c3                   	ret    
  801eac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801eb0:	8b 34 24             	mov    (%esp),%esi
  801eb3:	bf 20 00 00 00       	mov    $0x20,%edi
  801eb8:	89 e9                	mov    %ebp,%ecx
  801eba:	29 ef                	sub    %ebp,%edi
  801ebc:	d3 e0                	shl    %cl,%eax
  801ebe:	89 f9                	mov    %edi,%ecx
  801ec0:	89 f2                	mov    %esi,%edx
  801ec2:	d3 ea                	shr    %cl,%edx
  801ec4:	89 e9                	mov    %ebp,%ecx
  801ec6:	09 c2                	or     %eax,%edx
  801ec8:	89 d8                	mov    %ebx,%eax
  801eca:	89 14 24             	mov    %edx,(%esp)
  801ecd:	89 f2                	mov    %esi,%edx
  801ecf:	d3 e2                	shl    %cl,%edx
  801ed1:	89 f9                	mov    %edi,%ecx
  801ed3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ed7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801edb:	d3 e8                	shr    %cl,%eax
  801edd:	89 e9                	mov    %ebp,%ecx
  801edf:	89 c6                	mov    %eax,%esi
  801ee1:	d3 e3                	shl    %cl,%ebx
  801ee3:	89 f9                	mov    %edi,%ecx
  801ee5:	89 d0                	mov    %edx,%eax
  801ee7:	d3 e8                	shr    %cl,%eax
  801ee9:	89 e9                	mov    %ebp,%ecx
  801eeb:	09 d8                	or     %ebx,%eax
  801eed:	89 d3                	mov    %edx,%ebx
  801eef:	89 f2                	mov    %esi,%edx
  801ef1:	f7 34 24             	divl   (%esp)
  801ef4:	89 d6                	mov    %edx,%esi
  801ef6:	d3 e3                	shl    %cl,%ebx
  801ef8:	f7 64 24 04          	mull   0x4(%esp)
  801efc:	39 d6                	cmp    %edx,%esi
  801efe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f02:	89 d1                	mov    %edx,%ecx
  801f04:	89 c3                	mov    %eax,%ebx
  801f06:	72 08                	jb     801f10 <__umoddi3+0x110>
  801f08:	75 11                	jne    801f1b <__umoddi3+0x11b>
  801f0a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801f0e:	73 0b                	jae    801f1b <__umoddi3+0x11b>
  801f10:	2b 44 24 04          	sub    0x4(%esp),%eax
  801f14:	1b 14 24             	sbb    (%esp),%edx
  801f17:	89 d1                	mov    %edx,%ecx
  801f19:	89 c3                	mov    %eax,%ebx
  801f1b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801f1f:	29 da                	sub    %ebx,%edx
  801f21:	19 ce                	sbb    %ecx,%esi
  801f23:	89 f9                	mov    %edi,%ecx
  801f25:	89 f0                	mov    %esi,%eax
  801f27:	d3 e0                	shl    %cl,%eax
  801f29:	89 e9                	mov    %ebp,%ecx
  801f2b:	d3 ea                	shr    %cl,%edx
  801f2d:	89 e9                	mov    %ebp,%ecx
  801f2f:	d3 ee                	shr    %cl,%esi
  801f31:	09 d0                	or     %edx,%eax
  801f33:	89 f2                	mov    %esi,%edx
  801f35:	83 c4 1c             	add    $0x1c,%esp
  801f38:	5b                   	pop    %ebx
  801f39:	5e                   	pop    %esi
  801f3a:	5f                   	pop    %edi
  801f3b:	5d                   	pop    %ebp
  801f3c:	c3                   	ret    
  801f3d:	8d 76 00             	lea    0x0(%esi),%esi
  801f40:	29 f9                	sub    %edi,%ecx
  801f42:	19 d6                	sbb    %edx,%esi
  801f44:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f48:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f4c:	e9 18 ff ff ff       	jmp    801e69 <__umoddi3+0x69>
