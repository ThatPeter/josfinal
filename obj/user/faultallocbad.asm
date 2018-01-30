
obj/user/faultallocbad.debug:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
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
  800040:	68 80 24 80 00       	push   $0x802480
  800045:	e8 c7 01 00 00       	call   800211 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 3b 0b 00 00       	call   800b99 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 a0 24 80 00       	push   $0x8024a0
  80006f:	6a 0f                	push   $0xf
  800071:	68 8a 24 80 00       	push   $0x80248a
  800076:	e8 bd 00 00 00       	call   800138 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 cc 24 80 00       	push   $0x8024cc
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 ba 06 00 00       	call   800743 <snprintf>
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
  80009c:	e8 49 0d 00 00       	call   800dea <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 2d 0a 00 00       	call   800add <sys_cputs>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c0:	e8 96 0a 00 00       	call   800b5b <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8000d0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d5:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000da:	85 db                	test   %ebx,%ebx
  8000dc:	7e 07                	jle    8000e5 <libmain+0x30>
		binaryname = argv[0];
  8000de:	8b 06                	mov    (%esi),%eax
  8000e0:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e5:	83 ec 08             	sub    $0x8,%esp
  8000e8:	56                   	push   %esi
  8000e9:	53                   	push   %ebx
  8000ea:	e8 a2 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  8000ef:	e8 2a 00 00 00       	call   80011e <exit>
}
  8000f4:	83 c4 10             	add    $0x10,%esp
  8000f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000fa:	5b                   	pop    %ebx
  8000fb:	5e                   	pop    %esi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <thread_main>:

/*Lab 7: Multithreading thread main routine*/
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	83 ec 08             	sub    $0x8,%esp
	void (*func)(void) = (void (*)(void))eip;
  800104:	a1 0c 40 80 00       	mov    0x80400c,%eax
	func();
  800109:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  80010b:	e8 4b 0a 00 00       	call   800b5b <sys_getenvid>
  800110:	83 ec 0c             	sub    $0xc,%esp
  800113:	50                   	push   %eax
  800114:	e8 91 0c 00 00       	call   800daa <sys_thread_free>
}
  800119:	83 c4 10             	add    $0x10,%esp
  80011c:	c9                   	leave  
  80011d:	c3                   	ret    

0080011e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800124:	e8 1c 14 00 00       	call   801545 <close_all>
	sys_env_destroy(0);
  800129:	83 ec 0c             	sub    $0xc,%esp
  80012c:	6a 00                	push   $0x0
  80012e:	e8 e7 09 00 00       	call   800b1a <sys_env_destroy>
}
  800133:	83 c4 10             	add    $0x10,%esp
  800136:	c9                   	leave  
  800137:	c3                   	ret    

00800138 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80013d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800140:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800146:	e8 10 0a 00 00       	call   800b5b <sys_getenvid>
  80014b:	83 ec 0c             	sub    $0xc,%esp
  80014e:	ff 75 0c             	pushl  0xc(%ebp)
  800151:	ff 75 08             	pushl  0x8(%ebp)
  800154:	56                   	push   %esi
  800155:	50                   	push   %eax
  800156:	68 f8 24 80 00       	push   $0x8024f8
  80015b:	e8 b1 00 00 00       	call   800211 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800160:	83 c4 18             	add    $0x18,%esp
  800163:	53                   	push   %ebx
  800164:	ff 75 10             	pushl  0x10(%ebp)
  800167:	e8 54 00 00 00       	call   8001c0 <vcprintf>
	cprintf("\n");
  80016c:	c7 04 24 c9 28 80 00 	movl   $0x8028c9,(%esp)
  800173:	e8 99 00 00 00       	call   800211 <cprintf>
  800178:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80017b:	cc                   	int3   
  80017c:	eb fd                	jmp    80017b <_panic+0x43>

0080017e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80017e:	55                   	push   %ebp
  80017f:	89 e5                	mov    %esp,%ebp
  800181:	53                   	push   %ebx
  800182:	83 ec 04             	sub    $0x4,%esp
  800185:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800188:	8b 13                	mov    (%ebx),%edx
  80018a:	8d 42 01             	lea    0x1(%edx),%eax
  80018d:	89 03                	mov    %eax,(%ebx)
  80018f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800192:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800196:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019b:	75 1a                	jne    8001b7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80019d:	83 ec 08             	sub    $0x8,%esp
  8001a0:	68 ff 00 00 00       	push   $0xff
  8001a5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a8:	50                   	push   %eax
  8001a9:	e8 2f 09 00 00       	call   800add <sys_cputs>
		b->idx = 0;
  8001ae:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001b7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001be:	c9                   	leave  
  8001bf:	c3                   	ret    

008001c0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d0:	00 00 00 
	b.cnt = 0;
  8001d3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001da:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001dd:	ff 75 0c             	pushl  0xc(%ebp)
  8001e0:	ff 75 08             	pushl  0x8(%ebp)
  8001e3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e9:	50                   	push   %eax
  8001ea:	68 7e 01 80 00       	push   $0x80017e
  8001ef:	e8 54 01 00 00       	call   800348 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f4:	83 c4 08             	add    $0x8,%esp
  8001f7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001fd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800203:	50                   	push   %eax
  800204:	e8 d4 08 00 00       	call   800add <sys_cputs>

	return b.cnt;
}
  800209:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020f:	c9                   	leave  
  800210:	c3                   	ret    

00800211 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800211:	55                   	push   %ebp
  800212:	89 e5                	mov    %esp,%ebp
  800214:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800217:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80021a:	50                   	push   %eax
  80021b:	ff 75 08             	pushl  0x8(%ebp)
  80021e:	e8 9d ff ff ff       	call   8001c0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800223:	c9                   	leave  
  800224:	c3                   	ret    

00800225 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	57                   	push   %edi
  800229:	56                   	push   %esi
  80022a:	53                   	push   %ebx
  80022b:	83 ec 1c             	sub    $0x1c,%esp
  80022e:	89 c7                	mov    %eax,%edi
  800230:	89 d6                	mov    %edx,%esi
  800232:	8b 45 08             	mov    0x8(%ebp),%eax
  800235:	8b 55 0c             	mov    0xc(%ebp),%edx
  800238:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80023e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800241:	bb 00 00 00 00       	mov    $0x0,%ebx
  800246:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800249:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80024c:	39 d3                	cmp    %edx,%ebx
  80024e:	72 05                	jb     800255 <printnum+0x30>
  800250:	39 45 10             	cmp    %eax,0x10(%ebp)
  800253:	77 45                	ja     80029a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800255:	83 ec 0c             	sub    $0xc,%esp
  800258:	ff 75 18             	pushl  0x18(%ebp)
  80025b:	8b 45 14             	mov    0x14(%ebp),%eax
  80025e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800261:	53                   	push   %ebx
  800262:	ff 75 10             	pushl  0x10(%ebp)
  800265:	83 ec 08             	sub    $0x8,%esp
  800268:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026b:	ff 75 e0             	pushl  -0x20(%ebp)
  80026e:	ff 75 dc             	pushl  -0x24(%ebp)
  800271:	ff 75 d8             	pushl  -0x28(%ebp)
  800274:	e8 67 1f 00 00       	call   8021e0 <__udivdi3>
  800279:	83 c4 18             	add    $0x18,%esp
  80027c:	52                   	push   %edx
  80027d:	50                   	push   %eax
  80027e:	89 f2                	mov    %esi,%edx
  800280:	89 f8                	mov    %edi,%eax
  800282:	e8 9e ff ff ff       	call   800225 <printnum>
  800287:	83 c4 20             	add    $0x20,%esp
  80028a:	eb 18                	jmp    8002a4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80028c:	83 ec 08             	sub    $0x8,%esp
  80028f:	56                   	push   %esi
  800290:	ff 75 18             	pushl  0x18(%ebp)
  800293:	ff d7                	call   *%edi
  800295:	83 c4 10             	add    $0x10,%esp
  800298:	eb 03                	jmp    80029d <printnum+0x78>
  80029a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80029d:	83 eb 01             	sub    $0x1,%ebx
  8002a0:	85 db                	test   %ebx,%ebx
  8002a2:	7f e8                	jg     80028c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a4:	83 ec 08             	sub    $0x8,%esp
  8002a7:	56                   	push   %esi
  8002a8:	83 ec 04             	sub    $0x4,%esp
  8002ab:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ae:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b7:	e8 54 20 00 00       	call   802310 <__umoddi3>
  8002bc:	83 c4 14             	add    $0x14,%esp
  8002bf:	0f be 80 1b 25 80 00 	movsbl 0x80251b(%eax),%eax
  8002c6:	50                   	push   %eax
  8002c7:	ff d7                	call   *%edi
}
  8002c9:	83 c4 10             	add    $0x10,%esp
  8002cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cf:	5b                   	pop    %ebx
  8002d0:	5e                   	pop    %esi
  8002d1:	5f                   	pop    %edi
  8002d2:	5d                   	pop    %ebp
  8002d3:	c3                   	ret    

008002d4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d4:	55                   	push   %ebp
  8002d5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d7:	83 fa 01             	cmp    $0x1,%edx
  8002da:	7e 0e                	jle    8002ea <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002dc:	8b 10                	mov    (%eax),%edx
  8002de:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e1:	89 08                	mov    %ecx,(%eax)
  8002e3:	8b 02                	mov    (%edx),%eax
  8002e5:	8b 52 04             	mov    0x4(%edx),%edx
  8002e8:	eb 22                	jmp    80030c <getuint+0x38>
	else if (lflag)
  8002ea:	85 d2                	test   %edx,%edx
  8002ec:	74 10                	je     8002fe <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ee:	8b 10                	mov    (%eax),%edx
  8002f0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f3:	89 08                	mov    %ecx,(%eax)
  8002f5:	8b 02                	mov    (%edx),%eax
  8002f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fc:	eb 0e                	jmp    80030c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002fe:	8b 10                	mov    (%eax),%edx
  800300:	8d 4a 04             	lea    0x4(%edx),%ecx
  800303:	89 08                	mov    %ecx,(%eax)
  800305:	8b 02                	mov    (%edx),%eax
  800307:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800314:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800318:	8b 10                	mov    (%eax),%edx
  80031a:	3b 50 04             	cmp    0x4(%eax),%edx
  80031d:	73 0a                	jae    800329 <sprintputch+0x1b>
		*b->buf++ = ch;
  80031f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800322:	89 08                	mov    %ecx,(%eax)
  800324:	8b 45 08             	mov    0x8(%ebp),%eax
  800327:	88 02                	mov    %al,(%edx)
}
  800329:	5d                   	pop    %ebp
  80032a:	c3                   	ret    

0080032b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80032b:	55                   	push   %ebp
  80032c:	89 e5                	mov    %esp,%ebp
  80032e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800331:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800334:	50                   	push   %eax
  800335:	ff 75 10             	pushl  0x10(%ebp)
  800338:	ff 75 0c             	pushl  0xc(%ebp)
  80033b:	ff 75 08             	pushl  0x8(%ebp)
  80033e:	e8 05 00 00 00       	call   800348 <vprintfmt>
	va_end(ap);
}
  800343:	83 c4 10             	add    $0x10,%esp
  800346:	c9                   	leave  
  800347:	c3                   	ret    

00800348 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800348:	55                   	push   %ebp
  800349:	89 e5                	mov    %esp,%ebp
  80034b:	57                   	push   %edi
  80034c:	56                   	push   %esi
  80034d:	53                   	push   %ebx
  80034e:	83 ec 2c             	sub    $0x2c,%esp
  800351:	8b 75 08             	mov    0x8(%ebp),%esi
  800354:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800357:	8b 7d 10             	mov    0x10(%ebp),%edi
  80035a:	eb 12                	jmp    80036e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80035c:	85 c0                	test   %eax,%eax
  80035e:	0f 84 89 03 00 00    	je     8006ed <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800364:	83 ec 08             	sub    $0x8,%esp
  800367:	53                   	push   %ebx
  800368:	50                   	push   %eax
  800369:	ff d6                	call   *%esi
  80036b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80036e:	83 c7 01             	add    $0x1,%edi
  800371:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800375:	83 f8 25             	cmp    $0x25,%eax
  800378:	75 e2                	jne    80035c <vprintfmt+0x14>
  80037a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80037e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800385:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80038c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800393:	ba 00 00 00 00       	mov    $0x0,%edx
  800398:	eb 07                	jmp    8003a1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80039d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a1:	8d 47 01             	lea    0x1(%edi),%eax
  8003a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003a7:	0f b6 07             	movzbl (%edi),%eax
  8003aa:	0f b6 c8             	movzbl %al,%ecx
  8003ad:	83 e8 23             	sub    $0x23,%eax
  8003b0:	3c 55                	cmp    $0x55,%al
  8003b2:	0f 87 1a 03 00 00    	ja     8006d2 <vprintfmt+0x38a>
  8003b8:	0f b6 c0             	movzbl %al,%eax
  8003bb:	ff 24 85 60 26 80 00 	jmp    *0x802660(,%eax,4)
  8003c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003c9:	eb d6                	jmp    8003a1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003d6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003d9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003dd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003e0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003e3:	83 fa 09             	cmp    $0x9,%edx
  8003e6:	77 39                	ja     800421 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003e8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003eb:	eb e9                	jmp    8003d6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f0:	8d 48 04             	lea    0x4(%eax),%ecx
  8003f3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003f6:	8b 00                	mov    (%eax),%eax
  8003f8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003fe:	eb 27                	jmp    800427 <vprintfmt+0xdf>
  800400:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800403:	85 c0                	test   %eax,%eax
  800405:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040a:	0f 49 c8             	cmovns %eax,%ecx
  80040d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800413:	eb 8c                	jmp    8003a1 <vprintfmt+0x59>
  800415:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800418:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80041f:	eb 80                	jmp    8003a1 <vprintfmt+0x59>
  800421:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800424:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800427:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042b:	0f 89 70 ff ff ff    	jns    8003a1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800431:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800434:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800437:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80043e:	e9 5e ff ff ff       	jmp    8003a1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800443:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800446:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800449:	e9 53 ff ff ff       	jmp    8003a1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80044e:	8b 45 14             	mov    0x14(%ebp),%eax
  800451:	8d 50 04             	lea    0x4(%eax),%edx
  800454:	89 55 14             	mov    %edx,0x14(%ebp)
  800457:	83 ec 08             	sub    $0x8,%esp
  80045a:	53                   	push   %ebx
  80045b:	ff 30                	pushl  (%eax)
  80045d:	ff d6                	call   *%esi
			break;
  80045f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800462:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800465:	e9 04 ff ff ff       	jmp    80036e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046a:	8b 45 14             	mov    0x14(%ebp),%eax
  80046d:	8d 50 04             	lea    0x4(%eax),%edx
  800470:	89 55 14             	mov    %edx,0x14(%ebp)
  800473:	8b 00                	mov    (%eax),%eax
  800475:	99                   	cltd   
  800476:	31 d0                	xor    %edx,%eax
  800478:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80047a:	83 f8 0f             	cmp    $0xf,%eax
  80047d:	7f 0b                	jg     80048a <vprintfmt+0x142>
  80047f:	8b 14 85 c0 27 80 00 	mov    0x8027c0(,%eax,4),%edx
  800486:	85 d2                	test   %edx,%edx
  800488:	75 18                	jne    8004a2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80048a:	50                   	push   %eax
  80048b:	68 33 25 80 00       	push   $0x802533
  800490:	53                   	push   %ebx
  800491:	56                   	push   %esi
  800492:	e8 94 fe ff ff       	call   80032b <printfmt>
  800497:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80049d:	e9 cc fe ff ff       	jmp    80036e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004a2:	52                   	push   %edx
  8004a3:	68 8d 29 80 00       	push   $0x80298d
  8004a8:	53                   	push   %ebx
  8004a9:	56                   	push   %esi
  8004aa:	e8 7c fe ff ff       	call   80032b <printfmt>
  8004af:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b5:	e9 b4 fe ff ff       	jmp    80036e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bd:	8d 50 04             	lea    0x4(%eax),%edx
  8004c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004c5:	85 ff                	test   %edi,%edi
  8004c7:	b8 2c 25 80 00       	mov    $0x80252c,%eax
  8004cc:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004cf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d3:	0f 8e 94 00 00 00    	jle    80056d <vprintfmt+0x225>
  8004d9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004dd:	0f 84 98 00 00 00    	je     80057b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e3:	83 ec 08             	sub    $0x8,%esp
  8004e6:	ff 75 d0             	pushl  -0x30(%ebp)
  8004e9:	57                   	push   %edi
  8004ea:	e8 86 02 00 00       	call   800775 <strnlen>
  8004ef:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004f2:	29 c1                	sub    %eax,%ecx
  8004f4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004f7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004fa:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800501:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800504:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800506:	eb 0f                	jmp    800517 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	53                   	push   %ebx
  80050c:	ff 75 e0             	pushl  -0x20(%ebp)
  80050f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800511:	83 ef 01             	sub    $0x1,%edi
  800514:	83 c4 10             	add    $0x10,%esp
  800517:	85 ff                	test   %edi,%edi
  800519:	7f ed                	jg     800508 <vprintfmt+0x1c0>
  80051b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80051e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800521:	85 c9                	test   %ecx,%ecx
  800523:	b8 00 00 00 00       	mov    $0x0,%eax
  800528:	0f 49 c1             	cmovns %ecx,%eax
  80052b:	29 c1                	sub    %eax,%ecx
  80052d:	89 75 08             	mov    %esi,0x8(%ebp)
  800530:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800533:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800536:	89 cb                	mov    %ecx,%ebx
  800538:	eb 4d                	jmp    800587 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80053a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80053e:	74 1b                	je     80055b <vprintfmt+0x213>
  800540:	0f be c0             	movsbl %al,%eax
  800543:	83 e8 20             	sub    $0x20,%eax
  800546:	83 f8 5e             	cmp    $0x5e,%eax
  800549:	76 10                	jbe    80055b <vprintfmt+0x213>
					putch('?', putdat);
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	ff 75 0c             	pushl  0xc(%ebp)
  800551:	6a 3f                	push   $0x3f
  800553:	ff 55 08             	call   *0x8(%ebp)
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	eb 0d                	jmp    800568 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80055b:	83 ec 08             	sub    $0x8,%esp
  80055e:	ff 75 0c             	pushl  0xc(%ebp)
  800561:	52                   	push   %edx
  800562:	ff 55 08             	call   *0x8(%ebp)
  800565:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800568:	83 eb 01             	sub    $0x1,%ebx
  80056b:	eb 1a                	jmp    800587 <vprintfmt+0x23f>
  80056d:	89 75 08             	mov    %esi,0x8(%ebp)
  800570:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800573:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800576:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800579:	eb 0c                	jmp    800587 <vprintfmt+0x23f>
  80057b:	89 75 08             	mov    %esi,0x8(%ebp)
  80057e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800581:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800584:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800587:	83 c7 01             	add    $0x1,%edi
  80058a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80058e:	0f be d0             	movsbl %al,%edx
  800591:	85 d2                	test   %edx,%edx
  800593:	74 23                	je     8005b8 <vprintfmt+0x270>
  800595:	85 f6                	test   %esi,%esi
  800597:	78 a1                	js     80053a <vprintfmt+0x1f2>
  800599:	83 ee 01             	sub    $0x1,%esi
  80059c:	79 9c                	jns    80053a <vprintfmt+0x1f2>
  80059e:	89 df                	mov    %ebx,%edi
  8005a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a6:	eb 18                	jmp    8005c0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005a8:	83 ec 08             	sub    $0x8,%esp
  8005ab:	53                   	push   %ebx
  8005ac:	6a 20                	push   $0x20
  8005ae:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b0:	83 ef 01             	sub    $0x1,%edi
  8005b3:	83 c4 10             	add    $0x10,%esp
  8005b6:	eb 08                	jmp    8005c0 <vprintfmt+0x278>
  8005b8:	89 df                	mov    %ebx,%edi
  8005ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8005bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c0:	85 ff                	test   %edi,%edi
  8005c2:	7f e4                	jg     8005a8 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c7:	e9 a2 fd ff ff       	jmp    80036e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005cc:	83 fa 01             	cmp    $0x1,%edx
  8005cf:	7e 16                	jle    8005e7 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d4:	8d 50 08             	lea    0x8(%eax),%edx
  8005d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005da:	8b 50 04             	mov    0x4(%eax),%edx
  8005dd:	8b 00                	mov    (%eax),%eax
  8005df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e5:	eb 32                	jmp    800619 <vprintfmt+0x2d1>
	else if (lflag)
  8005e7:	85 d2                	test   %edx,%edx
  8005e9:	74 18                	je     800603 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8d 50 04             	lea    0x4(%eax),%edx
  8005f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f4:	8b 00                	mov    (%eax),%eax
  8005f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f9:	89 c1                	mov    %eax,%ecx
  8005fb:	c1 f9 1f             	sar    $0x1f,%ecx
  8005fe:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800601:	eb 16                	jmp    800619 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800603:	8b 45 14             	mov    0x14(%ebp),%eax
  800606:	8d 50 04             	lea    0x4(%eax),%edx
  800609:	89 55 14             	mov    %edx,0x14(%ebp)
  80060c:	8b 00                	mov    (%eax),%eax
  80060e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800611:	89 c1                	mov    %eax,%ecx
  800613:	c1 f9 1f             	sar    $0x1f,%ecx
  800616:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800619:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80061c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80061f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800624:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800628:	79 74                	jns    80069e <vprintfmt+0x356>
				putch('-', putdat);
  80062a:	83 ec 08             	sub    $0x8,%esp
  80062d:	53                   	push   %ebx
  80062e:	6a 2d                	push   $0x2d
  800630:	ff d6                	call   *%esi
				num = -(long long) num;
  800632:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800635:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800638:	f7 d8                	neg    %eax
  80063a:	83 d2 00             	adc    $0x0,%edx
  80063d:	f7 da                	neg    %edx
  80063f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800642:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800647:	eb 55                	jmp    80069e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800649:	8d 45 14             	lea    0x14(%ebp),%eax
  80064c:	e8 83 fc ff ff       	call   8002d4 <getuint>
			base = 10;
  800651:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800656:	eb 46                	jmp    80069e <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800658:	8d 45 14             	lea    0x14(%ebp),%eax
  80065b:	e8 74 fc ff ff       	call   8002d4 <getuint>
			base = 8;
  800660:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800665:	eb 37                	jmp    80069e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	53                   	push   %ebx
  80066b:	6a 30                	push   $0x30
  80066d:	ff d6                	call   *%esi
			putch('x', putdat);
  80066f:	83 c4 08             	add    $0x8,%esp
  800672:	53                   	push   %ebx
  800673:	6a 78                	push   $0x78
  800675:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	8d 50 04             	lea    0x4(%eax),%edx
  80067d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800680:	8b 00                	mov    (%eax),%eax
  800682:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800687:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80068a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80068f:	eb 0d                	jmp    80069e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800691:	8d 45 14             	lea    0x14(%ebp),%eax
  800694:	e8 3b fc ff ff       	call   8002d4 <getuint>
			base = 16;
  800699:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80069e:	83 ec 0c             	sub    $0xc,%esp
  8006a1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006a5:	57                   	push   %edi
  8006a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a9:	51                   	push   %ecx
  8006aa:	52                   	push   %edx
  8006ab:	50                   	push   %eax
  8006ac:	89 da                	mov    %ebx,%edx
  8006ae:	89 f0                	mov    %esi,%eax
  8006b0:	e8 70 fb ff ff       	call   800225 <printnum>
			break;
  8006b5:	83 c4 20             	add    $0x20,%esp
  8006b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006bb:	e9 ae fc ff ff       	jmp    80036e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c0:	83 ec 08             	sub    $0x8,%esp
  8006c3:	53                   	push   %ebx
  8006c4:	51                   	push   %ecx
  8006c5:	ff d6                	call   *%esi
			break;
  8006c7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006cd:	e9 9c fc ff ff       	jmp    80036e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d2:	83 ec 08             	sub    $0x8,%esp
  8006d5:	53                   	push   %ebx
  8006d6:	6a 25                	push   $0x25
  8006d8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006da:	83 c4 10             	add    $0x10,%esp
  8006dd:	eb 03                	jmp    8006e2 <vprintfmt+0x39a>
  8006df:	83 ef 01             	sub    $0x1,%edi
  8006e2:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006e6:	75 f7                	jne    8006df <vprintfmt+0x397>
  8006e8:	e9 81 fc ff ff       	jmp    80036e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f0:	5b                   	pop    %ebx
  8006f1:	5e                   	pop    %esi
  8006f2:	5f                   	pop    %edi
  8006f3:	5d                   	pop    %ebp
  8006f4:	c3                   	ret    

008006f5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f5:	55                   	push   %ebp
  8006f6:	89 e5                	mov    %esp,%ebp
  8006f8:	83 ec 18             	sub    $0x18,%esp
  8006fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800701:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800704:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800708:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80070b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800712:	85 c0                	test   %eax,%eax
  800714:	74 26                	je     80073c <vsnprintf+0x47>
  800716:	85 d2                	test   %edx,%edx
  800718:	7e 22                	jle    80073c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80071a:	ff 75 14             	pushl  0x14(%ebp)
  80071d:	ff 75 10             	pushl  0x10(%ebp)
  800720:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800723:	50                   	push   %eax
  800724:	68 0e 03 80 00       	push   $0x80030e
  800729:	e8 1a fc ff ff       	call   800348 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80072e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800731:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800734:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800737:	83 c4 10             	add    $0x10,%esp
  80073a:	eb 05                	jmp    800741 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80073c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800741:	c9                   	leave  
  800742:	c3                   	ret    

00800743 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800743:	55                   	push   %ebp
  800744:	89 e5                	mov    %esp,%ebp
  800746:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800749:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80074c:	50                   	push   %eax
  80074d:	ff 75 10             	pushl  0x10(%ebp)
  800750:	ff 75 0c             	pushl  0xc(%ebp)
  800753:	ff 75 08             	pushl  0x8(%ebp)
  800756:	e8 9a ff ff ff       	call   8006f5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80075b:	c9                   	leave  
  80075c:	c3                   	ret    

0080075d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
  800760:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800763:	b8 00 00 00 00       	mov    $0x0,%eax
  800768:	eb 03                	jmp    80076d <strlen+0x10>
		n++;
  80076a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80076d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800771:	75 f7                	jne    80076a <strlen+0xd>
		n++;
	return n;
}
  800773:	5d                   	pop    %ebp
  800774:	c3                   	ret    

00800775 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077e:	ba 00 00 00 00       	mov    $0x0,%edx
  800783:	eb 03                	jmp    800788 <strnlen+0x13>
		n++;
  800785:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800788:	39 c2                	cmp    %eax,%edx
  80078a:	74 08                	je     800794 <strnlen+0x1f>
  80078c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800790:	75 f3                	jne    800785 <strnlen+0x10>
  800792:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	53                   	push   %ebx
  80079a:	8b 45 08             	mov    0x8(%ebp),%eax
  80079d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a0:	89 c2                	mov    %eax,%edx
  8007a2:	83 c2 01             	add    $0x1,%edx
  8007a5:	83 c1 01             	add    $0x1,%ecx
  8007a8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ac:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007af:	84 db                	test   %bl,%bl
  8007b1:	75 ef                	jne    8007a2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b3:	5b                   	pop    %ebx
  8007b4:	5d                   	pop    %ebp
  8007b5:	c3                   	ret    

008007b6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	53                   	push   %ebx
  8007ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007bd:	53                   	push   %ebx
  8007be:	e8 9a ff ff ff       	call   80075d <strlen>
  8007c3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c6:	ff 75 0c             	pushl  0xc(%ebp)
  8007c9:	01 d8                	add    %ebx,%eax
  8007cb:	50                   	push   %eax
  8007cc:	e8 c5 ff ff ff       	call   800796 <strcpy>
	return dst;
}
  8007d1:	89 d8                	mov    %ebx,%eax
  8007d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d6:	c9                   	leave  
  8007d7:	c3                   	ret    

008007d8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	56                   	push   %esi
  8007dc:	53                   	push   %ebx
  8007dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e3:	89 f3                	mov    %esi,%ebx
  8007e5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e8:	89 f2                	mov    %esi,%edx
  8007ea:	eb 0f                	jmp    8007fb <strncpy+0x23>
		*dst++ = *src;
  8007ec:	83 c2 01             	add    $0x1,%edx
  8007ef:	0f b6 01             	movzbl (%ecx),%eax
  8007f2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f5:	80 39 01             	cmpb   $0x1,(%ecx)
  8007f8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fb:	39 da                	cmp    %ebx,%edx
  8007fd:	75 ed                	jne    8007ec <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007ff:	89 f0                	mov    %esi,%eax
  800801:	5b                   	pop    %ebx
  800802:	5e                   	pop    %esi
  800803:	5d                   	pop    %ebp
  800804:	c3                   	ret    

00800805 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	56                   	push   %esi
  800809:	53                   	push   %ebx
  80080a:	8b 75 08             	mov    0x8(%ebp),%esi
  80080d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800810:	8b 55 10             	mov    0x10(%ebp),%edx
  800813:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800815:	85 d2                	test   %edx,%edx
  800817:	74 21                	je     80083a <strlcpy+0x35>
  800819:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80081d:	89 f2                	mov    %esi,%edx
  80081f:	eb 09                	jmp    80082a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800821:	83 c2 01             	add    $0x1,%edx
  800824:	83 c1 01             	add    $0x1,%ecx
  800827:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80082a:	39 c2                	cmp    %eax,%edx
  80082c:	74 09                	je     800837 <strlcpy+0x32>
  80082e:	0f b6 19             	movzbl (%ecx),%ebx
  800831:	84 db                	test   %bl,%bl
  800833:	75 ec                	jne    800821 <strlcpy+0x1c>
  800835:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800837:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80083a:	29 f0                	sub    %esi,%eax
}
  80083c:	5b                   	pop    %ebx
  80083d:	5e                   	pop    %esi
  80083e:	5d                   	pop    %ebp
  80083f:	c3                   	ret    

00800840 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800846:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800849:	eb 06                	jmp    800851 <strcmp+0x11>
		p++, q++;
  80084b:	83 c1 01             	add    $0x1,%ecx
  80084e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800851:	0f b6 01             	movzbl (%ecx),%eax
  800854:	84 c0                	test   %al,%al
  800856:	74 04                	je     80085c <strcmp+0x1c>
  800858:	3a 02                	cmp    (%edx),%al
  80085a:	74 ef                	je     80084b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80085c:	0f b6 c0             	movzbl %al,%eax
  80085f:	0f b6 12             	movzbl (%edx),%edx
  800862:	29 d0                	sub    %edx,%eax
}
  800864:	5d                   	pop    %ebp
  800865:	c3                   	ret    

00800866 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	53                   	push   %ebx
  80086a:	8b 45 08             	mov    0x8(%ebp),%eax
  80086d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800870:	89 c3                	mov    %eax,%ebx
  800872:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800875:	eb 06                	jmp    80087d <strncmp+0x17>
		n--, p++, q++;
  800877:	83 c0 01             	add    $0x1,%eax
  80087a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80087d:	39 d8                	cmp    %ebx,%eax
  80087f:	74 15                	je     800896 <strncmp+0x30>
  800881:	0f b6 08             	movzbl (%eax),%ecx
  800884:	84 c9                	test   %cl,%cl
  800886:	74 04                	je     80088c <strncmp+0x26>
  800888:	3a 0a                	cmp    (%edx),%cl
  80088a:	74 eb                	je     800877 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088c:	0f b6 00             	movzbl (%eax),%eax
  80088f:	0f b6 12             	movzbl (%edx),%edx
  800892:	29 d0                	sub    %edx,%eax
  800894:	eb 05                	jmp    80089b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800896:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80089b:	5b                   	pop    %ebx
  80089c:	5d                   	pop    %ebp
  80089d:	c3                   	ret    

0080089e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a8:	eb 07                	jmp    8008b1 <strchr+0x13>
		if (*s == c)
  8008aa:	38 ca                	cmp    %cl,%dl
  8008ac:	74 0f                	je     8008bd <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ae:	83 c0 01             	add    $0x1,%eax
  8008b1:	0f b6 10             	movzbl (%eax),%edx
  8008b4:	84 d2                	test   %dl,%dl
  8008b6:	75 f2                	jne    8008aa <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    

008008bf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c9:	eb 03                	jmp    8008ce <strfind+0xf>
  8008cb:	83 c0 01             	add    $0x1,%eax
  8008ce:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d1:	38 ca                	cmp    %cl,%dl
  8008d3:	74 04                	je     8008d9 <strfind+0x1a>
  8008d5:	84 d2                	test   %dl,%dl
  8008d7:	75 f2                	jne    8008cb <strfind+0xc>
			break;
	return (char *) s;
}
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	57                   	push   %edi
  8008df:	56                   	push   %esi
  8008e0:	53                   	push   %ebx
  8008e1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e7:	85 c9                	test   %ecx,%ecx
  8008e9:	74 36                	je     800921 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008eb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f1:	75 28                	jne    80091b <memset+0x40>
  8008f3:	f6 c1 03             	test   $0x3,%cl
  8008f6:	75 23                	jne    80091b <memset+0x40>
		c &= 0xFF;
  8008f8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008fc:	89 d3                	mov    %edx,%ebx
  8008fe:	c1 e3 08             	shl    $0x8,%ebx
  800901:	89 d6                	mov    %edx,%esi
  800903:	c1 e6 18             	shl    $0x18,%esi
  800906:	89 d0                	mov    %edx,%eax
  800908:	c1 e0 10             	shl    $0x10,%eax
  80090b:	09 f0                	or     %esi,%eax
  80090d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80090f:	89 d8                	mov    %ebx,%eax
  800911:	09 d0                	or     %edx,%eax
  800913:	c1 e9 02             	shr    $0x2,%ecx
  800916:	fc                   	cld    
  800917:	f3 ab                	rep stos %eax,%es:(%edi)
  800919:	eb 06                	jmp    800921 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091e:	fc                   	cld    
  80091f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800921:	89 f8                	mov    %edi,%eax
  800923:	5b                   	pop    %ebx
  800924:	5e                   	pop    %esi
  800925:	5f                   	pop    %edi
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    

00800928 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	57                   	push   %edi
  80092c:	56                   	push   %esi
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	8b 75 0c             	mov    0xc(%ebp),%esi
  800933:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800936:	39 c6                	cmp    %eax,%esi
  800938:	73 35                	jae    80096f <memmove+0x47>
  80093a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80093d:	39 d0                	cmp    %edx,%eax
  80093f:	73 2e                	jae    80096f <memmove+0x47>
		s += n;
		d += n;
  800941:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800944:	89 d6                	mov    %edx,%esi
  800946:	09 fe                	or     %edi,%esi
  800948:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80094e:	75 13                	jne    800963 <memmove+0x3b>
  800950:	f6 c1 03             	test   $0x3,%cl
  800953:	75 0e                	jne    800963 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800955:	83 ef 04             	sub    $0x4,%edi
  800958:	8d 72 fc             	lea    -0x4(%edx),%esi
  80095b:	c1 e9 02             	shr    $0x2,%ecx
  80095e:	fd                   	std    
  80095f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800961:	eb 09                	jmp    80096c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800963:	83 ef 01             	sub    $0x1,%edi
  800966:	8d 72 ff             	lea    -0x1(%edx),%esi
  800969:	fd                   	std    
  80096a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096c:	fc                   	cld    
  80096d:	eb 1d                	jmp    80098c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096f:	89 f2                	mov    %esi,%edx
  800971:	09 c2                	or     %eax,%edx
  800973:	f6 c2 03             	test   $0x3,%dl
  800976:	75 0f                	jne    800987 <memmove+0x5f>
  800978:	f6 c1 03             	test   $0x3,%cl
  80097b:	75 0a                	jne    800987 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80097d:	c1 e9 02             	shr    $0x2,%ecx
  800980:	89 c7                	mov    %eax,%edi
  800982:	fc                   	cld    
  800983:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800985:	eb 05                	jmp    80098c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800987:	89 c7                	mov    %eax,%edi
  800989:	fc                   	cld    
  80098a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098c:	5e                   	pop    %esi
  80098d:	5f                   	pop    %edi
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800993:	ff 75 10             	pushl  0x10(%ebp)
  800996:	ff 75 0c             	pushl  0xc(%ebp)
  800999:	ff 75 08             	pushl  0x8(%ebp)
  80099c:	e8 87 ff ff ff       	call   800928 <memmove>
}
  8009a1:	c9                   	leave  
  8009a2:	c3                   	ret    

008009a3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	56                   	push   %esi
  8009a7:	53                   	push   %ebx
  8009a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ae:	89 c6                	mov    %eax,%esi
  8009b0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b3:	eb 1a                	jmp    8009cf <memcmp+0x2c>
		if (*s1 != *s2)
  8009b5:	0f b6 08             	movzbl (%eax),%ecx
  8009b8:	0f b6 1a             	movzbl (%edx),%ebx
  8009bb:	38 d9                	cmp    %bl,%cl
  8009bd:	74 0a                	je     8009c9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009bf:	0f b6 c1             	movzbl %cl,%eax
  8009c2:	0f b6 db             	movzbl %bl,%ebx
  8009c5:	29 d8                	sub    %ebx,%eax
  8009c7:	eb 0f                	jmp    8009d8 <memcmp+0x35>
		s1++, s2++;
  8009c9:	83 c0 01             	add    $0x1,%eax
  8009cc:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009cf:	39 f0                	cmp    %esi,%eax
  8009d1:	75 e2                	jne    8009b5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d8:	5b                   	pop    %ebx
  8009d9:	5e                   	pop    %esi
  8009da:	5d                   	pop    %ebp
  8009db:	c3                   	ret    

008009dc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	53                   	push   %ebx
  8009e0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009e3:	89 c1                	mov    %eax,%ecx
  8009e5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ec:	eb 0a                	jmp    8009f8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ee:	0f b6 10             	movzbl (%eax),%edx
  8009f1:	39 da                	cmp    %ebx,%edx
  8009f3:	74 07                	je     8009fc <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f5:	83 c0 01             	add    $0x1,%eax
  8009f8:	39 c8                	cmp    %ecx,%eax
  8009fa:	72 f2                	jb     8009ee <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009fc:	5b                   	pop    %ebx
  8009fd:	5d                   	pop    %ebp
  8009fe:	c3                   	ret    

008009ff <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	57                   	push   %edi
  800a03:	56                   	push   %esi
  800a04:	53                   	push   %ebx
  800a05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a08:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0b:	eb 03                	jmp    800a10 <strtol+0x11>
		s++;
  800a0d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a10:	0f b6 01             	movzbl (%ecx),%eax
  800a13:	3c 20                	cmp    $0x20,%al
  800a15:	74 f6                	je     800a0d <strtol+0xe>
  800a17:	3c 09                	cmp    $0x9,%al
  800a19:	74 f2                	je     800a0d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a1b:	3c 2b                	cmp    $0x2b,%al
  800a1d:	75 0a                	jne    800a29 <strtol+0x2a>
		s++;
  800a1f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a22:	bf 00 00 00 00       	mov    $0x0,%edi
  800a27:	eb 11                	jmp    800a3a <strtol+0x3b>
  800a29:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a2e:	3c 2d                	cmp    $0x2d,%al
  800a30:	75 08                	jne    800a3a <strtol+0x3b>
		s++, neg = 1;
  800a32:	83 c1 01             	add    $0x1,%ecx
  800a35:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a40:	75 15                	jne    800a57 <strtol+0x58>
  800a42:	80 39 30             	cmpb   $0x30,(%ecx)
  800a45:	75 10                	jne    800a57 <strtol+0x58>
  800a47:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a4b:	75 7c                	jne    800ac9 <strtol+0xca>
		s += 2, base = 16;
  800a4d:	83 c1 02             	add    $0x2,%ecx
  800a50:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a55:	eb 16                	jmp    800a6d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a57:	85 db                	test   %ebx,%ebx
  800a59:	75 12                	jne    800a6d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a5b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a60:	80 39 30             	cmpb   $0x30,(%ecx)
  800a63:	75 08                	jne    800a6d <strtol+0x6e>
		s++, base = 8;
  800a65:	83 c1 01             	add    $0x1,%ecx
  800a68:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a72:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a75:	0f b6 11             	movzbl (%ecx),%edx
  800a78:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a7b:	89 f3                	mov    %esi,%ebx
  800a7d:	80 fb 09             	cmp    $0x9,%bl
  800a80:	77 08                	ja     800a8a <strtol+0x8b>
			dig = *s - '0';
  800a82:	0f be d2             	movsbl %dl,%edx
  800a85:	83 ea 30             	sub    $0x30,%edx
  800a88:	eb 22                	jmp    800aac <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a8a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a8d:	89 f3                	mov    %esi,%ebx
  800a8f:	80 fb 19             	cmp    $0x19,%bl
  800a92:	77 08                	ja     800a9c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a94:	0f be d2             	movsbl %dl,%edx
  800a97:	83 ea 57             	sub    $0x57,%edx
  800a9a:	eb 10                	jmp    800aac <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a9c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a9f:	89 f3                	mov    %esi,%ebx
  800aa1:	80 fb 19             	cmp    $0x19,%bl
  800aa4:	77 16                	ja     800abc <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aa6:	0f be d2             	movsbl %dl,%edx
  800aa9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aac:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aaf:	7d 0b                	jge    800abc <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ab1:	83 c1 01             	add    $0x1,%ecx
  800ab4:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ab8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aba:	eb b9                	jmp    800a75 <strtol+0x76>

	if (endptr)
  800abc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac0:	74 0d                	je     800acf <strtol+0xd0>
		*endptr = (char *) s;
  800ac2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac5:	89 0e                	mov    %ecx,(%esi)
  800ac7:	eb 06                	jmp    800acf <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac9:	85 db                	test   %ebx,%ebx
  800acb:	74 98                	je     800a65 <strtol+0x66>
  800acd:	eb 9e                	jmp    800a6d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800acf:	89 c2                	mov    %eax,%edx
  800ad1:	f7 da                	neg    %edx
  800ad3:	85 ff                	test   %edi,%edi
  800ad5:	0f 45 c2             	cmovne %edx,%eax
}
  800ad8:	5b                   	pop    %ebx
  800ad9:	5e                   	pop    %esi
  800ada:	5f                   	pop    %edi
  800adb:	5d                   	pop    %ebp
  800adc:	c3                   	ret    

00800add <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	57                   	push   %edi
  800ae1:	56                   	push   %esi
  800ae2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aeb:	8b 55 08             	mov    0x8(%ebp),%edx
  800aee:	89 c3                	mov    %eax,%ebx
  800af0:	89 c7                	mov    %eax,%edi
  800af2:	89 c6                	mov    %eax,%esi
  800af4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5f                   	pop    %edi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <sys_cgetc>:

int
sys_cgetc(void)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	57                   	push   %edi
  800aff:	56                   	push   %esi
  800b00:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b01:	ba 00 00 00 00       	mov    $0x0,%edx
  800b06:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0b:	89 d1                	mov    %edx,%ecx
  800b0d:	89 d3                	mov    %edx,%ebx
  800b0f:	89 d7                	mov    %edx,%edi
  800b11:	89 d6                	mov    %edx,%esi
  800b13:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5f                   	pop    %edi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	57                   	push   %edi
  800b1e:	56                   	push   %esi
  800b1f:	53                   	push   %ebx
  800b20:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b23:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b28:	b8 03 00 00 00       	mov    $0x3,%eax
  800b2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b30:	89 cb                	mov    %ecx,%ebx
  800b32:	89 cf                	mov    %ecx,%edi
  800b34:	89 ce                	mov    %ecx,%esi
  800b36:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b38:	85 c0                	test   %eax,%eax
  800b3a:	7e 17                	jle    800b53 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3c:	83 ec 0c             	sub    $0xc,%esp
  800b3f:	50                   	push   %eax
  800b40:	6a 03                	push   $0x3
  800b42:	68 1f 28 80 00       	push   $0x80281f
  800b47:	6a 23                	push   $0x23
  800b49:	68 3c 28 80 00       	push   $0x80283c
  800b4e:	e8 e5 f5 ff ff       	call   800138 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b56:	5b                   	pop    %ebx
  800b57:	5e                   	pop    %esi
  800b58:	5f                   	pop    %edi
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	57                   	push   %edi
  800b5f:	56                   	push   %esi
  800b60:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b61:	ba 00 00 00 00       	mov    $0x0,%edx
  800b66:	b8 02 00 00 00       	mov    $0x2,%eax
  800b6b:	89 d1                	mov    %edx,%ecx
  800b6d:	89 d3                	mov    %edx,%ebx
  800b6f:	89 d7                	mov    %edx,%edi
  800b71:	89 d6                	mov    %edx,%esi
  800b73:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b75:	5b                   	pop    %ebx
  800b76:	5e                   	pop    %esi
  800b77:	5f                   	pop    %edi
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <sys_yield>:

void
sys_yield(void)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	57                   	push   %edi
  800b7e:	56                   	push   %esi
  800b7f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b80:	ba 00 00 00 00       	mov    $0x0,%edx
  800b85:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b8a:	89 d1                	mov    %edx,%ecx
  800b8c:	89 d3                	mov    %edx,%ebx
  800b8e:	89 d7                	mov    %edx,%edi
  800b90:	89 d6                	mov    %edx,%esi
  800b92:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b94:	5b                   	pop    %ebx
  800b95:	5e                   	pop    %esi
  800b96:	5f                   	pop    %edi
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    

00800b99 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	57                   	push   %edi
  800b9d:	56                   	push   %esi
  800b9e:	53                   	push   %ebx
  800b9f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba2:	be 00 00 00 00       	mov    $0x0,%esi
  800ba7:	b8 04 00 00 00       	mov    $0x4,%eax
  800bac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800baf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb5:	89 f7                	mov    %esi,%edi
  800bb7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb9:	85 c0                	test   %eax,%eax
  800bbb:	7e 17                	jle    800bd4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbd:	83 ec 0c             	sub    $0xc,%esp
  800bc0:	50                   	push   %eax
  800bc1:	6a 04                	push   $0x4
  800bc3:	68 1f 28 80 00       	push   $0x80281f
  800bc8:	6a 23                	push   $0x23
  800bca:	68 3c 28 80 00       	push   $0x80283c
  800bcf:	e8 64 f5 ff ff       	call   800138 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd7:	5b                   	pop    %ebx
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	57                   	push   %edi
  800be0:	56                   	push   %esi
  800be1:	53                   	push   %ebx
  800be2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be5:	b8 05 00 00 00       	mov    $0x5,%eax
  800bea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bed:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bf6:	8b 75 18             	mov    0x18(%ebp),%esi
  800bf9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfb:	85 c0                	test   %eax,%eax
  800bfd:	7e 17                	jle    800c16 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bff:	83 ec 0c             	sub    $0xc,%esp
  800c02:	50                   	push   %eax
  800c03:	6a 05                	push   $0x5
  800c05:	68 1f 28 80 00       	push   $0x80281f
  800c0a:	6a 23                	push   $0x23
  800c0c:	68 3c 28 80 00       	push   $0x80283c
  800c11:	e8 22 f5 ff ff       	call   800138 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c27:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2c:	b8 06 00 00 00       	mov    $0x6,%eax
  800c31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c34:	8b 55 08             	mov    0x8(%ebp),%edx
  800c37:	89 df                	mov    %ebx,%edi
  800c39:	89 de                	mov    %ebx,%esi
  800c3b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3d:	85 c0                	test   %eax,%eax
  800c3f:	7e 17                	jle    800c58 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c41:	83 ec 0c             	sub    $0xc,%esp
  800c44:	50                   	push   %eax
  800c45:	6a 06                	push   $0x6
  800c47:	68 1f 28 80 00       	push   $0x80281f
  800c4c:	6a 23                	push   $0x23
  800c4e:	68 3c 28 80 00       	push   $0x80283c
  800c53:	e8 e0 f4 ff ff       	call   800138 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
  800c66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c69:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6e:	b8 08 00 00 00       	mov    $0x8,%eax
  800c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c76:	8b 55 08             	mov    0x8(%ebp),%edx
  800c79:	89 df                	mov    %ebx,%edi
  800c7b:	89 de                	mov    %ebx,%esi
  800c7d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7f:	85 c0                	test   %eax,%eax
  800c81:	7e 17                	jle    800c9a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c83:	83 ec 0c             	sub    $0xc,%esp
  800c86:	50                   	push   %eax
  800c87:	6a 08                	push   $0x8
  800c89:	68 1f 28 80 00       	push   $0x80281f
  800c8e:	6a 23                	push   $0x23
  800c90:	68 3c 28 80 00       	push   $0x80283c
  800c95:	e8 9e f4 ff ff       	call   800138 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    

00800ca2 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	57                   	push   %edi
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
  800ca8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb0:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbb:	89 df                	mov    %ebx,%edi
  800cbd:	89 de                	mov    %ebx,%esi
  800cbf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc1:	85 c0                	test   %eax,%eax
  800cc3:	7e 17                	jle    800cdc <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc5:	83 ec 0c             	sub    $0xc,%esp
  800cc8:	50                   	push   %eax
  800cc9:	6a 09                	push   $0x9
  800ccb:	68 1f 28 80 00       	push   $0x80281f
  800cd0:	6a 23                	push   $0x23
  800cd2:	68 3c 28 80 00       	push   $0x80283c
  800cd7:	e8 5c f4 ff ff       	call   800138 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800ced:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfd:	89 df                	mov    %ebx,%edi
  800cff:	89 de                	mov    %ebx,%esi
  800d01:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d03:	85 c0                	test   %eax,%eax
  800d05:	7e 17                	jle    800d1e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d07:	83 ec 0c             	sub    $0xc,%esp
  800d0a:	50                   	push   %eax
  800d0b:	6a 0a                	push   $0xa
  800d0d:	68 1f 28 80 00       	push   $0x80281f
  800d12:	6a 23                	push   $0x23
  800d14:	68 3c 28 80 00       	push   $0x80283c
  800d19:	e8 1a f4 ff ff       	call   800138 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	57                   	push   %edi
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2c:	be 00 00 00 00       	mov    $0x0,%esi
  800d31:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d39:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d42:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d44:	5b                   	pop    %ebx
  800d45:	5e                   	pop    %esi
  800d46:	5f                   	pop    %edi
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    

00800d49 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  800d52:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d57:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5f:	89 cb                	mov    %ecx,%ebx
  800d61:	89 cf                	mov    %ecx,%edi
  800d63:	89 ce                	mov    %ecx,%esi
  800d65:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d67:	85 c0                	test   %eax,%eax
  800d69:	7e 17                	jle    800d82 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6b:	83 ec 0c             	sub    $0xc,%esp
  800d6e:	50                   	push   %eax
  800d6f:	6a 0d                	push   $0xd
  800d71:	68 1f 28 80 00       	push   $0x80281f
  800d76:	6a 23                	push   $0x23
  800d78:	68 3c 28 80 00       	push   $0x80283c
  800d7d:	e8 b6 f3 ff ff       	call   800138 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d85:	5b                   	pop    %ebx
  800d86:	5e                   	pop    %esi
  800d87:	5f                   	pop    %edi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	57                   	push   %edi
  800d8e:	56                   	push   %esi
  800d8f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d90:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d95:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9d:	89 cb                	mov    %ecx,%ebx
  800d9f:	89 cf                	mov    %ecx,%edi
  800da1:	89 ce                	mov    %ecx,%esi
  800da3:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5f                   	pop    %edi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    

00800daa <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	57                   	push   %edi
  800dae:	56                   	push   %esi
  800daf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db5:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dba:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbd:	89 cb                	mov    %ecx,%ebx
  800dbf:	89 cf                	mov    %ecx,%edi
  800dc1:	89 ce                	mov    %ecx,%esi
  800dc3:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800dc5:	5b                   	pop    %ebx
  800dc6:	5e                   	pop    %esi
  800dc7:	5f                   	pop    %edi
  800dc8:	5d                   	pop    %ebp
  800dc9:	c3                   	ret    

00800dca <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
  800dcd:	57                   	push   %edi
  800dce:	56                   	push   %esi
  800dcf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd5:	b8 10 00 00 00       	mov    $0x10,%eax
  800dda:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddd:	89 cb                	mov    %ecx,%ebx
  800ddf:	89 cf                	mov    %ecx,%edi
  800de1:	89 ce                	mov    %ecx,%esi
  800de3:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  800de5:	5b                   	pop    %ebx
  800de6:	5e                   	pop    %esi
  800de7:	5f                   	pop    %edi
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    

00800dea <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
  800ded:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800df0:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800df7:	75 2a                	jne    800e23 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  800df9:	83 ec 04             	sub    $0x4,%esp
  800dfc:	6a 07                	push   $0x7
  800dfe:	68 00 f0 bf ee       	push   $0xeebff000
  800e03:	6a 00                	push   $0x0
  800e05:	e8 8f fd ff ff       	call   800b99 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  800e0a:	83 c4 10             	add    $0x10,%esp
  800e0d:	85 c0                	test   %eax,%eax
  800e0f:	79 12                	jns    800e23 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  800e11:	50                   	push   %eax
  800e12:	68 e0 28 80 00       	push   $0x8028e0
  800e17:	6a 23                	push   $0x23
  800e19:	68 4a 28 80 00       	push   $0x80284a
  800e1e:	e8 15 f3 ff ff       	call   800138 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e23:	8b 45 08             	mov    0x8(%ebp),%eax
  800e26:	a3 08 40 80 00       	mov    %eax,0x804008
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  800e2b:	83 ec 08             	sub    $0x8,%esp
  800e2e:	68 55 0e 80 00       	push   $0x800e55
  800e33:	6a 00                	push   $0x0
  800e35:	e8 aa fe ff ff       	call   800ce4 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  800e3a:	83 c4 10             	add    $0x10,%esp
  800e3d:	85 c0                	test   %eax,%eax
  800e3f:	79 12                	jns    800e53 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  800e41:	50                   	push   %eax
  800e42:	68 e0 28 80 00       	push   $0x8028e0
  800e47:	6a 2c                	push   $0x2c
  800e49:	68 4a 28 80 00       	push   $0x80284a
  800e4e:	e8 e5 f2 ff ff       	call   800138 <_panic>
	}
}
  800e53:	c9                   	leave  
  800e54:	c3                   	ret    

00800e55 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e55:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e56:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800e5b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e5d:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  800e60:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  800e64:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  800e69:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  800e6d:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  800e6f:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  800e72:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  800e73:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  800e76:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  800e77:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e78:	c3                   	ret    

00800e79 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	53                   	push   %ebx
  800e7d:	83 ec 04             	sub    $0x4,%esp
  800e80:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e83:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800e85:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e89:	74 11                	je     800e9c <pgfault+0x23>
  800e8b:	89 d8                	mov    %ebx,%eax
  800e8d:	c1 e8 0c             	shr    $0xc,%eax
  800e90:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e97:	f6 c4 08             	test   $0x8,%ah
  800e9a:	75 14                	jne    800eb0 <pgfault+0x37>
		panic("faulting access");
  800e9c:	83 ec 04             	sub    $0x4,%esp
  800e9f:	68 58 28 80 00       	push   $0x802858
  800ea4:	6a 1f                	push   $0x1f
  800ea6:	68 68 28 80 00       	push   $0x802868
  800eab:	e8 88 f2 ff ff       	call   800138 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800eb0:	83 ec 04             	sub    $0x4,%esp
  800eb3:	6a 07                	push   $0x7
  800eb5:	68 00 f0 7f 00       	push   $0x7ff000
  800eba:	6a 00                	push   $0x0
  800ebc:	e8 d8 fc ff ff       	call   800b99 <sys_page_alloc>
	if (r < 0) {
  800ec1:	83 c4 10             	add    $0x10,%esp
  800ec4:	85 c0                	test   %eax,%eax
  800ec6:	79 12                	jns    800eda <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800ec8:	50                   	push   %eax
  800ec9:	68 73 28 80 00       	push   $0x802873
  800ece:	6a 2d                	push   $0x2d
  800ed0:	68 68 28 80 00       	push   $0x802868
  800ed5:	e8 5e f2 ff ff       	call   800138 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800eda:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800ee0:	83 ec 04             	sub    $0x4,%esp
  800ee3:	68 00 10 00 00       	push   $0x1000
  800ee8:	53                   	push   %ebx
  800ee9:	68 00 f0 7f 00       	push   $0x7ff000
  800eee:	e8 9d fa ff ff       	call   800990 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800ef3:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800efa:	53                   	push   %ebx
  800efb:	6a 00                	push   $0x0
  800efd:	68 00 f0 7f 00       	push   $0x7ff000
  800f02:	6a 00                	push   $0x0
  800f04:	e8 d3 fc ff ff       	call   800bdc <sys_page_map>
	if (r < 0) {
  800f09:	83 c4 20             	add    $0x20,%esp
  800f0c:	85 c0                	test   %eax,%eax
  800f0e:	79 12                	jns    800f22 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800f10:	50                   	push   %eax
  800f11:	68 73 28 80 00       	push   $0x802873
  800f16:	6a 34                	push   $0x34
  800f18:	68 68 28 80 00       	push   $0x802868
  800f1d:	e8 16 f2 ff ff       	call   800138 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800f22:	83 ec 08             	sub    $0x8,%esp
  800f25:	68 00 f0 7f 00       	push   $0x7ff000
  800f2a:	6a 00                	push   $0x0
  800f2c:	e8 ed fc ff ff       	call   800c1e <sys_page_unmap>
	if (r < 0) {
  800f31:	83 c4 10             	add    $0x10,%esp
  800f34:	85 c0                	test   %eax,%eax
  800f36:	79 12                	jns    800f4a <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800f38:	50                   	push   %eax
  800f39:	68 73 28 80 00       	push   $0x802873
  800f3e:	6a 38                	push   $0x38
  800f40:	68 68 28 80 00       	push   $0x802868
  800f45:	e8 ee f1 ff ff       	call   800138 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800f4a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f4d:	c9                   	leave  
  800f4e:	c3                   	ret    

00800f4f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	57                   	push   %edi
  800f53:	56                   	push   %esi
  800f54:	53                   	push   %ebx
  800f55:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800f58:	68 79 0e 80 00       	push   $0x800e79
  800f5d:	e8 88 fe ff ff       	call   800dea <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f62:	b8 07 00 00 00       	mov    $0x7,%eax
  800f67:	cd 30                	int    $0x30
  800f69:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800f6c:	83 c4 10             	add    $0x10,%esp
  800f6f:	85 c0                	test   %eax,%eax
  800f71:	79 17                	jns    800f8a <fork+0x3b>
		panic("fork fault %e");
  800f73:	83 ec 04             	sub    $0x4,%esp
  800f76:	68 8c 28 80 00       	push   $0x80288c
  800f7b:	68 85 00 00 00       	push   $0x85
  800f80:	68 68 28 80 00       	push   $0x802868
  800f85:	e8 ae f1 ff ff       	call   800138 <_panic>
  800f8a:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f8c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f90:	75 24                	jne    800fb6 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f92:	e8 c4 fb ff ff       	call   800b5b <sys_getenvid>
  800f97:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f9c:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800fa2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fa7:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800fac:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb1:	e9 64 01 00 00       	jmp    80111a <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800fb6:	83 ec 04             	sub    $0x4,%esp
  800fb9:	6a 07                	push   $0x7
  800fbb:	68 00 f0 bf ee       	push   $0xeebff000
  800fc0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fc3:	e8 d1 fb ff ff       	call   800b99 <sys_page_alloc>
  800fc8:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800fcb:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800fd0:	89 d8                	mov    %ebx,%eax
  800fd2:	c1 e8 16             	shr    $0x16,%eax
  800fd5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fdc:	a8 01                	test   $0x1,%al
  800fde:	0f 84 fc 00 00 00    	je     8010e0 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800fe4:	89 d8                	mov    %ebx,%eax
  800fe6:	c1 e8 0c             	shr    $0xc,%eax
  800fe9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ff0:	f6 c2 01             	test   $0x1,%dl
  800ff3:	0f 84 e7 00 00 00    	je     8010e0 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800ff9:	89 c6                	mov    %eax,%esi
  800ffb:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800ffe:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801005:	f6 c6 04             	test   $0x4,%dh
  801008:	74 39                	je     801043 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80100a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801011:	83 ec 0c             	sub    $0xc,%esp
  801014:	25 07 0e 00 00       	and    $0xe07,%eax
  801019:	50                   	push   %eax
  80101a:	56                   	push   %esi
  80101b:	57                   	push   %edi
  80101c:	56                   	push   %esi
  80101d:	6a 00                	push   $0x0
  80101f:	e8 b8 fb ff ff       	call   800bdc <sys_page_map>
		if (r < 0) {
  801024:	83 c4 20             	add    $0x20,%esp
  801027:	85 c0                	test   %eax,%eax
  801029:	0f 89 b1 00 00 00    	jns    8010e0 <fork+0x191>
		    	panic("sys page map fault %e");
  80102f:	83 ec 04             	sub    $0x4,%esp
  801032:	68 9a 28 80 00       	push   $0x80289a
  801037:	6a 55                	push   $0x55
  801039:	68 68 28 80 00       	push   $0x802868
  80103e:	e8 f5 f0 ff ff       	call   800138 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801043:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80104a:	f6 c2 02             	test   $0x2,%dl
  80104d:	75 0c                	jne    80105b <fork+0x10c>
  80104f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801056:	f6 c4 08             	test   $0x8,%ah
  801059:	74 5b                	je     8010b6 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80105b:	83 ec 0c             	sub    $0xc,%esp
  80105e:	68 05 08 00 00       	push   $0x805
  801063:	56                   	push   %esi
  801064:	57                   	push   %edi
  801065:	56                   	push   %esi
  801066:	6a 00                	push   $0x0
  801068:	e8 6f fb ff ff       	call   800bdc <sys_page_map>
		if (r < 0) {
  80106d:	83 c4 20             	add    $0x20,%esp
  801070:	85 c0                	test   %eax,%eax
  801072:	79 14                	jns    801088 <fork+0x139>
		    	panic("sys page map fault %e");
  801074:	83 ec 04             	sub    $0x4,%esp
  801077:	68 9a 28 80 00       	push   $0x80289a
  80107c:	6a 5c                	push   $0x5c
  80107e:	68 68 28 80 00       	push   $0x802868
  801083:	e8 b0 f0 ff ff       	call   800138 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  801088:	83 ec 0c             	sub    $0xc,%esp
  80108b:	68 05 08 00 00       	push   $0x805
  801090:	56                   	push   %esi
  801091:	6a 00                	push   $0x0
  801093:	56                   	push   %esi
  801094:	6a 00                	push   $0x0
  801096:	e8 41 fb ff ff       	call   800bdc <sys_page_map>
		if (r < 0) {
  80109b:	83 c4 20             	add    $0x20,%esp
  80109e:	85 c0                	test   %eax,%eax
  8010a0:	79 3e                	jns    8010e0 <fork+0x191>
		    	panic("sys page map fault %e");
  8010a2:	83 ec 04             	sub    $0x4,%esp
  8010a5:	68 9a 28 80 00       	push   $0x80289a
  8010aa:	6a 60                	push   $0x60
  8010ac:	68 68 28 80 00       	push   $0x802868
  8010b1:	e8 82 f0 ff ff       	call   800138 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8010b6:	83 ec 0c             	sub    $0xc,%esp
  8010b9:	6a 05                	push   $0x5
  8010bb:	56                   	push   %esi
  8010bc:	57                   	push   %edi
  8010bd:	56                   	push   %esi
  8010be:	6a 00                	push   $0x0
  8010c0:	e8 17 fb ff ff       	call   800bdc <sys_page_map>
		if (r < 0) {
  8010c5:	83 c4 20             	add    $0x20,%esp
  8010c8:	85 c0                	test   %eax,%eax
  8010ca:	79 14                	jns    8010e0 <fork+0x191>
		    	panic("sys page map fault %e");
  8010cc:	83 ec 04             	sub    $0x4,%esp
  8010cf:	68 9a 28 80 00       	push   $0x80289a
  8010d4:	6a 65                	push   $0x65
  8010d6:	68 68 28 80 00       	push   $0x802868
  8010db:	e8 58 f0 ff ff       	call   800138 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8010e0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010e6:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8010ec:	0f 85 de fe ff ff    	jne    800fd0 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  8010f2:	a1 04 40 80 00       	mov    0x804004,%eax
  8010f7:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
  8010fd:	83 ec 08             	sub    $0x8,%esp
  801100:	50                   	push   %eax
  801101:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801104:	57                   	push   %edi
  801105:	e8 da fb ff ff       	call   800ce4 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80110a:	83 c4 08             	add    $0x8,%esp
  80110d:	6a 02                	push   $0x2
  80110f:	57                   	push   %edi
  801110:	e8 4b fb ff ff       	call   800c60 <sys_env_set_status>
	
	return envid;
  801115:	83 c4 10             	add    $0x10,%esp
  801118:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80111a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80111d:	5b                   	pop    %ebx
  80111e:	5e                   	pop    %esi
  80111f:	5f                   	pop    %edi
  801120:	5d                   	pop    %ebp
  801121:	c3                   	ret    

00801122 <sfork>:

envid_t
sfork(void)
{
  801122:	55                   	push   %ebp
  801123:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801125:	b8 00 00 00 00       	mov    $0x0,%eax
  80112a:	5d                   	pop    %ebp
  80112b:	c3                   	ret    

0080112c <thread_create>:

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  80112c:	55                   	push   %ebp
  80112d:	89 e5                	mov    %esp,%ebp
  80112f:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  801132:	8b 45 08             	mov    0x8(%ebp),%eax
  801135:	a3 0c 40 80 00       	mov    %eax,0x80400c
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80113a:	68 fe 00 80 00       	push   $0x8000fe
  80113f:	e8 46 fc ff ff       	call   800d8a <sys_thread_create>

	return id;
}
  801144:	c9                   	leave  
  801145:	c3                   	ret    

00801146 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  801146:	55                   	push   %ebp
  801147:	89 e5                	mov    %esp,%ebp
  801149:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  80114c:	ff 75 08             	pushl  0x8(%ebp)
  80114f:	e8 56 fc ff ff       	call   800daa <sys_thread_free>
}
  801154:	83 c4 10             	add    $0x10,%esp
  801157:	c9                   	leave  
  801158:	c3                   	ret    

00801159 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  801159:	55                   	push   %ebp
  80115a:	89 e5                	mov    %esp,%ebp
  80115c:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  80115f:	ff 75 08             	pushl  0x8(%ebp)
  801162:	e8 63 fc ff ff       	call   800dca <sys_thread_join>
}
  801167:	83 c4 10             	add    $0x10,%esp
  80116a:	c9                   	leave  
  80116b:	c3                   	ret    

0080116c <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  80116c:	55                   	push   %ebp
  80116d:	89 e5                	mov    %esp,%ebp
  80116f:	56                   	push   %esi
  801170:	53                   	push   %ebx
  801171:	8b 75 08             	mov    0x8(%ebp),%esi
  801174:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  801177:	83 ec 04             	sub    $0x4,%esp
  80117a:	6a 07                	push   $0x7
  80117c:	6a 00                	push   $0x0
  80117e:	56                   	push   %esi
  80117f:	e8 15 fa ff ff       	call   800b99 <sys_page_alloc>
	if (r < 0) {
  801184:	83 c4 10             	add    $0x10,%esp
  801187:	85 c0                	test   %eax,%eax
  801189:	79 15                	jns    8011a0 <queue_append+0x34>
		panic("%e\n", r);
  80118b:	50                   	push   %eax
  80118c:	68 e0 28 80 00       	push   $0x8028e0
  801191:	68 d5 00 00 00       	push   $0xd5
  801196:	68 68 28 80 00       	push   $0x802868
  80119b:	e8 98 ef ff ff       	call   800138 <_panic>
	}	

	wt->envid = envid;
  8011a0:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  8011a6:	83 3b 00             	cmpl   $0x0,(%ebx)
  8011a9:	75 13                	jne    8011be <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  8011ab:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  8011b2:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8011b9:	00 00 00 
  8011bc:	eb 1b                	jmp    8011d9 <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  8011be:	8b 43 04             	mov    0x4(%ebx),%eax
  8011c1:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  8011c8:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8011cf:	00 00 00 
		queue->last = wt;
  8011d2:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8011d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011dc:	5b                   	pop    %ebx
  8011dd:	5e                   	pop    %esi
  8011de:	5d                   	pop    %ebp
  8011df:	c3                   	ret    

008011e0 <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	83 ec 08             	sub    $0x8,%esp
  8011e6:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  8011e9:	8b 02                	mov    (%edx),%eax
  8011eb:	85 c0                	test   %eax,%eax
  8011ed:	75 17                	jne    801206 <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  8011ef:	83 ec 04             	sub    $0x4,%esp
  8011f2:	68 b0 28 80 00       	push   $0x8028b0
  8011f7:	68 ec 00 00 00       	push   $0xec
  8011fc:	68 68 28 80 00       	push   $0x802868
  801201:	e8 32 ef ff ff       	call   800138 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  801206:	8b 48 04             	mov    0x4(%eax),%ecx
  801209:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  80120b:	8b 00                	mov    (%eax),%eax
}
  80120d:	c9                   	leave  
  80120e:	c3                   	ret    

0080120f <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  80120f:	55                   	push   %ebp
  801210:	89 e5                	mov    %esp,%ebp
  801212:	56                   	push   %esi
  801213:	53                   	push   %ebx
  801214:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  801217:	b8 01 00 00 00       	mov    $0x1,%eax
  80121c:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  80121f:	85 c0                	test   %eax,%eax
  801221:	74 4a                	je     80126d <mutex_lock+0x5e>
  801223:	8b 73 04             	mov    0x4(%ebx),%esi
  801226:	83 3e 00             	cmpl   $0x0,(%esi)
  801229:	75 42                	jne    80126d <mutex_lock+0x5e>
		queue_append(sys_getenvid(), mtx->queue);		
  80122b:	e8 2b f9 ff ff       	call   800b5b <sys_getenvid>
  801230:	83 ec 08             	sub    $0x8,%esp
  801233:	56                   	push   %esi
  801234:	50                   	push   %eax
  801235:	e8 32 ff ff ff       	call   80116c <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  80123a:	e8 1c f9 ff ff       	call   800b5b <sys_getenvid>
  80123f:	83 c4 08             	add    $0x8,%esp
  801242:	6a 04                	push   $0x4
  801244:	50                   	push   %eax
  801245:	e8 16 fa ff ff       	call   800c60 <sys_env_set_status>

		if (r < 0) {
  80124a:	83 c4 10             	add    $0x10,%esp
  80124d:	85 c0                	test   %eax,%eax
  80124f:	79 15                	jns    801266 <mutex_lock+0x57>
			panic("%e\n", r);
  801251:	50                   	push   %eax
  801252:	68 e0 28 80 00       	push   $0x8028e0
  801257:	68 02 01 00 00       	push   $0x102
  80125c:	68 68 28 80 00       	push   $0x802868
  801261:	e8 d2 ee ff ff       	call   800138 <_panic>
		}
		sys_yield();
  801266:	e8 0f f9 ff ff       	call   800b7a <sys_yield>
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  80126b:	eb 08                	jmp    801275 <mutex_lock+0x66>
		if (r < 0) {
			panic("%e\n", r);
		}
		sys_yield();
	} else {
		mtx->owner = sys_getenvid();
  80126d:	e8 e9 f8 ff ff       	call   800b5b <sys_getenvid>
  801272:	89 43 08             	mov    %eax,0x8(%ebx)
	}
}
  801275:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801278:	5b                   	pop    %ebx
  801279:	5e                   	pop    %esi
  80127a:	5d                   	pop    %ebp
  80127b:	c3                   	ret    

0080127c <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	53                   	push   %ebx
  801280:	83 ec 04             	sub    $0x4,%esp
  801283:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801286:	b8 00 00 00 00       	mov    $0x0,%eax
  80128b:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  80128e:	8b 43 04             	mov    0x4(%ebx),%eax
  801291:	83 38 00             	cmpl   $0x0,(%eax)
  801294:	74 33                	je     8012c9 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  801296:	83 ec 0c             	sub    $0xc,%esp
  801299:	50                   	push   %eax
  80129a:	e8 41 ff ff ff       	call   8011e0 <queue_pop>
  80129f:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8012a2:	83 c4 08             	add    $0x8,%esp
  8012a5:	6a 02                	push   $0x2
  8012a7:	50                   	push   %eax
  8012a8:	e8 b3 f9 ff ff       	call   800c60 <sys_env_set_status>
		if (r < 0) {
  8012ad:	83 c4 10             	add    $0x10,%esp
  8012b0:	85 c0                	test   %eax,%eax
  8012b2:	79 15                	jns    8012c9 <mutex_unlock+0x4d>
			panic("%e\n", r);
  8012b4:	50                   	push   %eax
  8012b5:	68 e0 28 80 00       	push   $0x8028e0
  8012ba:	68 16 01 00 00       	push   $0x116
  8012bf:	68 68 28 80 00       	push   $0x802868
  8012c4:	e8 6f ee ff ff       	call   800138 <_panic>
		}
	}

	//asm volatile("pause"); 	// might be useless here
}
  8012c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012cc:	c9                   	leave  
  8012cd:	c3                   	ret    

008012ce <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  8012ce:	55                   	push   %ebp
  8012cf:	89 e5                	mov    %esp,%ebp
  8012d1:	53                   	push   %ebx
  8012d2:	83 ec 04             	sub    $0x4,%esp
  8012d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  8012d8:	e8 7e f8 ff ff       	call   800b5b <sys_getenvid>
  8012dd:	83 ec 04             	sub    $0x4,%esp
  8012e0:	6a 07                	push   $0x7
  8012e2:	53                   	push   %ebx
  8012e3:	50                   	push   %eax
  8012e4:	e8 b0 f8 ff ff       	call   800b99 <sys_page_alloc>
  8012e9:	83 c4 10             	add    $0x10,%esp
  8012ec:	85 c0                	test   %eax,%eax
  8012ee:	79 15                	jns    801305 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  8012f0:	50                   	push   %eax
  8012f1:	68 cb 28 80 00       	push   $0x8028cb
  8012f6:	68 22 01 00 00       	push   $0x122
  8012fb:	68 68 28 80 00       	push   $0x802868
  801300:	e8 33 ee ff ff       	call   800138 <_panic>
	}	
	mtx->locked = 0;
  801305:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  80130b:	8b 43 04             	mov    0x4(%ebx),%eax
  80130e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  801314:	8b 43 04             	mov    0x4(%ebx),%eax
  801317:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  80131e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  801325:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801328:	c9                   	leave  
  801329:	c3                   	ret    

0080132a <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  80132a:	55                   	push   %ebp
  80132b:	89 e5                	mov    %esp,%ebp
  80132d:	53                   	push   %ebx
  80132e:	83 ec 04             	sub    $0x4,%esp
  801331:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue->first != NULL) {
  801334:	eb 21                	jmp    801357 <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
  801336:	83 ec 0c             	sub    $0xc,%esp
  801339:	50                   	push   %eax
  80133a:	e8 a1 fe ff ff       	call   8011e0 <queue_pop>
  80133f:	83 c4 08             	add    $0x8,%esp
  801342:	6a 02                	push   $0x2
  801344:	50                   	push   %eax
  801345:	e8 16 f9 ff ff       	call   800c60 <sys_env_set_status>
		mtx->queue->first = mtx->queue->first->next;
  80134a:	8b 43 04             	mov    0x4(%ebx),%eax
  80134d:	8b 10                	mov    (%eax),%edx
  80134f:	8b 52 04             	mov    0x4(%edx),%edx
  801352:	89 10                	mov    %edx,(%eax)
  801354:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue->first != NULL) {
  801357:	8b 43 04             	mov    0x4(%ebx),%eax
  80135a:	83 38 00             	cmpl   $0x0,(%eax)
  80135d:	75 d7                	jne    801336 <mutex_destroy+0xc>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
		mtx->queue->first = mtx->queue->first->next;
	}

	memset(mtx, 0, PGSIZE);
  80135f:	83 ec 04             	sub    $0x4,%esp
  801362:	68 00 10 00 00       	push   $0x1000
  801367:	6a 00                	push   $0x0
  801369:	53                   	push   %ebx
  80136a:	e8 6c f5 ff ff       	call   8008db <memset>
	mtx = NULL;
}
  80136f:	83 c4 10             	add    $0x10,%esp
  801372:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801375:	c9                   	leave  
  801376:	c3                   	ret    

00801377 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80137a:	8b 45 08             	mov    0x8(%ebp),%eax
  80137d:	05 00 00 00 30       	add    $0x30000000,%eax
  801382:	c1 e8 0c             	shr    $0xc,%eax
}
  801385:	5d                   	pop    %ebp
  801386:	c3                   	ret    

00801387 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801387:	55                   	push   %ebp
  801388:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80138a:	8b 45 08             	mov    0x8(%ebp),%eax
  80138d:	05 00 00 00 30       	add    $0x30000000,%eax
  801392:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801397:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80139c:	5d                   	pop    %ebp
  80139d:	c3                   	ret    

0080139e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013a4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013a9:	89 c2                	mov    %eax,%edx
  8013ab:	c1 ea 16             	shr    $0x16,%edx
  8013ae:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013b5:	f6 c2 01             	test   $0x1,%dl
  8013b8:	74 11                	je     8013cb <fd_alloc+0x2d>
  8013ba:	89 c2                	mov    %eax,%edx
  8013bc:	c1 ea 0c             	shr    $0xc,%edx
  8013bf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013c6:	f6 c2 01             	test   $0x1,%dl
  8013c9:	75 09                	jne    8013d4 <fd_alloc+0x36>
			*fd_store = fd;
  8013cb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8013d2:	eb 17                	jmp    8013eb <fd_alloc+0x4d>
  8013d4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013d9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013de:	75 c9                	jne    8013a9 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013e0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8013e6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013eb:	5d                   	pop    %ebp
  8013ec:	c3                   	ret    

008013ed <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013ed:	55                   	push   %ebp
  8013ee:	89 e5                	mov    %esp,%ebp
  8013f0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013f3:	83 f8 1f             	cmp    $0x1f,%eax
  8013f6:	77 36                	ja     80142e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013f8:	c1 e0 0c             	shl    $0xc,%eax
  8013fb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801400:	89 c2                	mov    %eax,%edx
  801402:	c1 ea 16             	shr    $0x16,%edx
  801405:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80140c:	f6 c2 01             	test   $0x1,%dl
  80140f:	74 24                	je     801435 <fd_lookup+0x48>
  801411:	89 c2                	mov    %eax,%edx
  801413:	c1 ea 0c             	shr    $0xc,%edx
  801416:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80141d:	f6 c2 01             	test   $0x1,%dl
  801420:	74 1a                	je     80143c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801422:	8b 55 0c             	mov    0xc(%ebp),%edx
  801425:	89 02                	mov    %eax,(%edx)
	return 0;
  801427:	b8 00 00 00 00       	mov    $0x0,%eax
  80142c:	eb 13                	jmp    801441 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80142e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801433:	eb 0c                	jmp    801441 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801435:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80143a:	eb 05                	jmp    801441 <fd_lookup+0x54>
  80143c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801441:	5d                   	pop    %ebp
  801442:	c3                   	ret    

00801443 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801443:	55                   	push   %ebp
  801444:	89 e5                	mov    %esp,%ebp
  801446:	83 ec 08             	sub    $0x8,%esp
  801449:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80144c:	ba 64 29 80 00       	mov    $0x802964,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801451:	eb 13                	jmp    801466 <dev_lookup+0x23>
  801453:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801456:	39 08                	cmp    %ecx,(%eax)
  801458:	75 0c                	jne    801466 <dev_lookup+0x23>
			*dev = devtab[i];
  80145a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80145d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80145f:	b8 00 00 00 00       	mov    $0x0,%eax
  801464:	eb 31                	jmp    801497 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801466:	8b 02                	mov    (%edx),%eax
  801468:	85 c0                	test   %eax,%eax
  80146a:	75 e7                	jne    801453 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80146c:	a1 04 40 80 00       	mov    0x804004,%eax
  801471:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801477:	83 ec 04             	sub    $0x4,%esp
  80147a:	51                   	push   %ecx
  80147b:	50                   	push   %eax
  80147c:	68 e4 28 80 00       	push   $0x8028e4
  801481:	e8 8b ed ff ff       	call   800211 <cprintf>
	*dev = 0;
  801486:	8b 45 0c             	mov    0xc(%ebp),%eax
  801489:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80148f:	83 c4 10             	add    $0x10,%esp
  801492:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801497:	c9                   	leave  
  801498:	c3                   	ret    

00801499 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801499:	55                   	push   %ebp
  80149a:	89 e5                	mov    %esp,%ebp
  80149c:	56                   	push   %esi
  80149d:	53                   	push   %ebx
  80149e:	83 ec 10             	sub    $0x10,%esp
  8014a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8014a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014aa:	50                   	push   %eax
  8014ab:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014b1:	c1 e8 0c             	shr    $0xc,%eax
  8014b4:	50                   	push   %eax
  8014b5:	e8 33 ff ff ff       	call   8013ed <fd_lookup>
  8014ba:	83 c4 08             	add    $0x8,%esp
  8014bd:	85 c0                	test   %eax,%eax
  8014bf:	78 05                	js     8014c6 <fd_close+0x2d>
	    || fd != fd2)
  8014c1:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014c4:	74 0c                	je     8014d2 <fd_close+0x39>
		return (must_exist ? r : 0);
  8014c6:	84 db                	test   %bl,%bl
  8014c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014cd:	0f 44 c2             	cmove  %edx,%eax
  8014d0:	eb 41                	jmp    801513 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014d2:	83 ec 08             	sub    $0x8,%esp
  8014d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d8:	50                   	push   %eax
  8014d9:	ff 36                	pushl  (%esi)
  8014db:	e8 63 ff ff ff       	call   801443 <dev_lookup>
  8014e0:	89 c3                	mov    %eax,%ebx
  8014e2:	83 c4 10             	add    $0x10,%esp
  8014e5:	85 c0                	test   %eax,%eax
  8014e7:	78 1a                	js     801503 <fd_close+0x6a>
		if (dev->dev_close)
  8014e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ec:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8014ef:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8014f4:	85 c0                	test   %eax,%eax
  8014f6:	74 0b                	je     801503 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8014f8:	83 ec 0c             	sub    $0xc,%esp
  8014fb:	56                   	push   %esi
  8014fc:	ff d0                	call   *%eax
  8014fe:	89 c3                	mov    %eax,%ebx
  801500:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801503:	83 ec 08             	sub    $0x8,%esp
  801506:	56                   	push   %esi
  801507:	6a 00                	push   $0x0
  801509:	e8 10 f7 ff ff       	call   800c1e <sys_page_unmap>
	return r;
  80150e:	83 c4 10             	add    $0x10,%esp
  801511:	89 d8                	mov    %ebx,%eax
}
  801513:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801516:	5b                   	pop    %ebx
  801517:	5e                   	pop    %esi
  801518:	5d                   	pop    %ebp
  801519:	c3                   	ret    

0080151a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80151a:	55                   	push   %ebp
  80151b:	89 e5                	mov    %esp,%ebp
  80151d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801520:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801523:	50                   	push   %eax
  801524:	ff 75 08             	pushl  0x8(%ebp)
  801527:	e8 c1 fe ff ff       	call   8013ed <fd_lookup>
  80152c:	83 c4 08             	add    $0x8,%esp
  80152f:	85 c0                	test   %eax,%eax
  801531:	78 10                	js     801543 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801533:	83 ec 08             	sub    $0x8,%esp
  801536:	6a 01                	push   $0x1
  801538:	ff 75 f4             	pushl  -0xc(%ebp)
  80153b:	e8 59 ff ff ff       	call   801499 <fd_close>
  801540:	83 c4 10             	add    $0x10,%esp
}
  801543:	c9                   	leave  
  801544:	c3                   	ret    

00801545 <close_all>:

void
close_all(void)
{
  801545:	55                   	push   %ebp
  801546:	89 e5                	mov    %esp,%ebp
  801548:	53                   	push   %ebx
  801549:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80154c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801551:	83 ec 0c             	sub    $0xc,%esp
  801554:	53                   	push   %ebx
  801555:	e8 c0 ff ff ff       	call   80151a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80155a:	83 c3 01             	add    $0x1,%ebx
  80155d:	83 c4 10             	add    $0x10,%esp
  801560:	83 fb 20             	cmp    $0x20,%ebx
  801563:	75 ec                	jne    801551 <close_all+0xc>
		close(i);
}
  801565:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801568:	c9                   	leave  
  801569:	c3                   	ret    

0080156a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	57                   	push   %edi
  80156e:	56                   	push   %esi
  80156f:	53                   	push   %ebx
  801570:	83 ec 2c             	sub    $0x2c,%esp
  801573:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801576:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801579:	50                   	push   %eax
  80157a:	ff 75 08             	pushl  0x8(%ebp)
  80157d:	e8 6b fe ff ff       	call   8013ed <fd_lookup>
  801582:	83 c4 08             	add    $0x8,%esp
  801585:	85 c0                	test   %eax,%eax
  801587:	0f 88 c1 00 00 00    	js     80164e <dup+0xe4>
		return r;
	close(newfdnum);
  80158d:	83 ec 0c             	sub    $0xc,%esp
  801590:	56                   	push   %esi
  801591:	e8 84 ff ff ff       	call   80151a <close>

	newfd = INDEX2FD(newfdnum);
  801596:	89 f3                	mov    %esi,%ebx
  801598:	c1 e3 0c             	shl    $0xc,%ebx
  80159b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8015a1:	83 c4 04             	add    $0x4,%esp
  8015a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015a7:	e8 db fd ff ff       	call   801387 <fd2data>
  8015ac:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8015ae:	89 1c 24             	mov    %ebx,(%esp)
  8015b1:	e8 d1 fd ff ff       	call   801387 <fd2data>
  8015b6:	83 c4 10             	add    $0x10,%esp
  8015b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015bc:	89 f8                	mov    %edi,%eax
  8015be:	c1 e8 16             	shr    $0x16,%eax
  8015c1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015c8:	a8 01                	test   $0x1,%al
  8015ca:	74 37                	je     801603 <dup+0x99>
  8015cc:	89 f8                	mov    %edi,%eax
  8015ce:	c1 e8 0c             	shr    $0xc,%eax
  8015d1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015d8:	f6 c2 01             	test   $0x1,%dl
  8015db:	74 26                	je     801603 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015dd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015e4:	83 ec 0c             	sub    $0xc,%esp
  8015e7:	25 07 0e 00 00       	and    $0xe07,%eax
  8015ec:	50                   	push   %eax
  8015ed:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015f0:	6a 00                	push   $0x0
  8015f2:	57                   	push   %edi
  8015f3:	6a 00                	push   $0x0
  8015f5:	e8 e2 f5 ff ff       	call   800bdc <sys_page_map>
  8015fa:	89 c7                	mov    %eax,%edi
  8015fc:	83 c4 20             	add    $0x20,%esp
  8015ff:	85 c0                	test   %eax,%eax
  801601:	78 2e                	js     801631 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801603:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801606:	89 d0                	mov    %edx,%eax
  801608:	c1 e8 0c             	shr    $0xc,%eax
  80160b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801612:	83 ec 0c             	sub    $0xc,%esp
  801615:	25 07 0e 00 00       	and    $0xe07,%eax
  80161a:	50                   	push   %eax
  80161b:	53                   	push   %ebx
  80161c:	6a 00                	push   $0x0
  80161e:	52                   	push   %edx
  80161f:	6a 00                	push   $0x0
  801621:	e8 b6 f5 ff ff       	call   800bdc <sys_page_map>
  801626:	89 c7                	mov    %eax,%edi
  801628:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80162b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80162d:	85 ff                	test   %edi,%edi
  80162f:	79 1d                	jns    80164e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801631:	83 ec 08             	sub    $0x8,%esp
  801634:	53                   	push   %ebx
  801635:	6a 00                	push   $0x0
  801637:	e8 e2 f5 ff ff       	call   800c1e <sys_page_unmap>
	sys_page_unmap(0, nva);
  80163c:	83 c4 08             	add    $0x8,%esp
  80163f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801642:	6a 00                	push   $0x0
  801644:	e8 d5 f5 ff ff       	call   800c1e <sys_page_unmap>
	return r;
  801649:	83 c4 10             	add    $0x10,%esp
  80164c:	89 f8                	mov    %edi,%eax
}
  80164e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801651:	5b                   	pop    %ebx
  801652:	5e                   	pop    %esi
  801653:	5f                   	pop    %edi
  801654:	5d                   	pop    %ebp
  801655:	c3                   	ret    

00801656 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801656:	55                   	push   %ebp
  801657:	89 e5                	mov    %esp,%ebp
  801659:	53                   	push   %ebx
  80165a:	83 ec 14             	sub    $0x14,%esp
  80165d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801660:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801663:	50                   	push   %eax
  801664:	53                   	push   %ebx
  801665:	e8 83 fd ff ff       	call   8013ed <fd_lookup>
  80166a:	83 c4 08             	add    $0x8,%esp
  80166d:	89 c2                	mov    %eax,%edx
  80166f:	85 c0                	test   %eax,%eax
  801671:	78 70                	js     8016e3 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801673:	83 ec 08             	sub    $0x8,%esp
  801676:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801679:	50                   	push   %eax
  80167a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167d:	ff 30                	pushl  (%eax)
  80167f:	e8 bf fd ff ff       	call   801443 <dev_lookup>
  801684:	83 c4 10             	add    $0x10,%esp
  801687:	85 c0                	test   %eax,%eax
  801689:	78 4f                	js     8016da <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80168b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80168e:	8b 42 08             	mov    0x8(%edx),%eax
  801691:	83 e0 03             	and    $0x3,%eax
  801694:	83 f8 01             	cmp    $0x1,%eax
  801697:	75 24                	jne    8016bd <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801699:	a1 04 40 80 00       	mov    0x804004,%eax
  80169e:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8016a4:	83 ec 04             	sub    $0x4,%esp
  8016a7:	53                   	push   %ebx
  8016a8:	50                   	push   %eax
  8016a9:	68 28 29 80 00       	push   $0x802928
  8016ae:	e8 5e eb ff ff       	call   800211 <cprintf>
		return -E_INVAL;
  8016b3:	83 c4 10             	add    $0x10,%esp
  8016b6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016bb:	eb 26                	jmp    8016e3 <read+0x8d>
	}
	if (!dev->dev_read)
  8016bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c0:	8b 40 08             	mov    0x8(%eax),%eax
  8016c3:	85 c0                	test   %eax,%eax
  8016c5:	74 17                	je     8016de <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8016c7:	83 ec 04             	sub    $0x4,%esp
  8016ca:	ff 75 10             	pushl  0x10(%ebp)
  8016cd:	ff 75 0c             	pushl  0xc(%ebp)
  8016d0:	52                   	push   %edx
  8016d1:	ff d0                	call   *%eax
  8016d3:	89 c2                	mov    %eax,%edx
  8016d5:	83 c4 10             	add    $0x10,%esp
  8016d8:	eb 09                	jmp    8016e3 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016da:	89 c2                	mov    %eax,%edx
  8016dc:	eb 05                	jmp    8016e3 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016de:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8016e3:	89 d0                	mov    %edx,%eax
  8016e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e8:	c9                   	leave  
  8016e9:	c3                   	ret    

008016ea <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	57                   	push   %edi
  8016ee:	56                   	push   %esi
  8016ef:	53                   	push   %ebx
  8016f0:	83 ec 0c             	sub    $0xc,%esp
  8016f3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016f6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016fe:	eb 21                	jmp    801721 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801700:	83 ec 04             	sub    $0x4,%esp
  801703:	89 f0                	mov    %esi,%eax
  801705:	29 d8                	sub    %ebx,%eax
  801707:	50                   	push   %eax
  801708:	89 d8                	mov    %ebx,%eax
  80170a:	03 45 0c             	add    0xc(%ebp),%eax
  80170d:	50                   	push   %eax
  80170e:	57                   	push   %edi
  80170f:	e8 42 ff ff ff       	call   801656 <read>
		if (m < 0)
  801714:	83 c4 10             	add    $0x10,%esp
  801717:	85 c0                	test   %eax,%eax
  801719:	78 10                	js     80172b <readn+0x41>
			return m;
		if (m == 0)
  80171b:	85 c0                	test   %eax,%eax
  80171d:	74 0a                	je     801729 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80171f:	01 c3                	add    %eax,%ebx
  801721:	39 f3                	cmp    %esi,%ebx
  801723:	72 db                	jb     801700 <readn+0x16>
  801725:	89 d8                	mov    %ebx,%eax
  801727:	eb 02                	jmp    80172b <readn+0x41>
  801729:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80172b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80172e:	5b                   	pop    %ebx
  80172f:	5e                   	pop    %esi
  801730:	5f                   	pop    %edi
  801731:	5d                   	pop    %ebp
  801732:	c3                   	ret    

00801733 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801733:	55                   	push   %ebp
  801734:	89 e5                	mov    %esp,%ebp
  801736:	53                   	push   %ebx
  801737:	83 ec 14             	sub    $0x14,%esp
  80173a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80173d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801740:	50                   	push   %eax
  801741:	53                   	push   %ebx
  801742:	e8 a6 fc ff ff       	call   8013ed <fd_lookup>
  801747:	83 c4 08             	add    $0x8,%esp
  80174a:	89 c2                	mov    %eax,%edx
  80174c:	85 c0                	test   %eax,%eax
  80174e:	78 6b                	js     8017bb <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801750:	83 ec 08             	sub    $0x8,%esp
  801753:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801756:	50                   	push   %eax
  801757:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80175a:	ff 30                	pushl  (%eax)
  80175c:	e8 e2 fc ff ff       	call   801443 <dev_lookup>
  801761:	83 c4 10             	add    $0x10,%esp
  801764:	85 c0                	test   %eax,%eax
  801766:	78 4a                	js     8017b2 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801768:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80176b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80176f:	75 24                	jne    801795 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801771:	a1 04 40 80 00       	mov    0x804004,%eax
  801776:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80177c:	83 ec 04             	sub    $0x4,%esp
  80177f:	53                   	push   %ebx
  801780:	50                   	push   %eax
  801781:	68 44 29 80 00       	push   $0x802944
  801786:	e8 86 ea ff ff       	call   800211 <cprintf>
		return -E_INVAL;
  80178b:	83 c4 10             	add    $0x10,%esp
  80178e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801793:	eb 26                	jmp    8017bb <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801795:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801798:	8b 52 0c             	mov    0xc(%edx),%edx
  80179b:	85 d2                	test   %edx,%edx
  80179d:	74 17                	je     8017b6 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80179f:	83 ec 04             	sub    $0x4,%esp
  8017a2:	ff 75 10             	pushl  0x10(%ebp)
  8017a5:	ff 75 0c             	pushl  0xc(%ebp)
  8017a8:	50                   	push   %eax
  8017a9:	ff d2                	call   *%edx
  8017ab:	89 c2                	mov    %eax,%edx
  8017ad:	83 c4 10             	add    $0x10,%esp
  8017b0:	eb 09                	jmp    8017bb <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b2:	89 c2                	mov    %eax,%edx
  8017b4:	eb 05                	jmp    8017bb <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017b6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8017bb:	89 d0                	mov    %edx,%eax
  8017bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c0:	c9                   	leave  
  8017c1:	c3                   	ret    

008017c2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017c2:	55                   	push   %ebp
  8017c3:	89 e5                	mov    %esp,%ebp
  8017c5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017c8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017cb:	50                   	push   %eax
  8017cc:	ff 75 08             	pushl  0x8(%ebp)
  8017cf:	e8 19 fc ff ff       	call   8013ed <fd_lookup>
  8017d4:	83 c4 08             	add    $0x8,%esp
  8017d7:	85 c0                	test   %eax,%eax
  8017d9:	78 0e                	js     8017e9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8017db:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017e1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017e9:	c9                   	leave  
  8017ea:	c3                   	ret    

008017eb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017eb:	55                   	push   %ebp
  8017ec:	89 e5                	mov    %esp,%ebp
  8017ee:	53                   	push   %ebx
  8017ef:	83 ec 14             	sub    $0x14,%esp
  8017f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017f8:	50                   	push   %eax
  8017f9:	53                   	push   %ebx
  8017fa:	e8 ee fb ff ff       	call   8013ed <fd_lookup>
  8017ff:	83 c4 08             	add    $0x8,%esp
  801802:	89 c2                	mov    %eax,%edx
  801804:	85 c0                	test   %eax,%eax
  801806:	78 68                	js     801870 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801808:	83 ec 08             	sub    $0x8,%esp
  80180b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80180e:	50                   	push   %eax
  80180f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801812:	ff 30                	pushl  (%eax)
  801814:	e8 2a fc ff ff       	call   801443 <dev_lookup>
  801819:	83 c4 10             	add    $0x10,%esp
  80181c:	85 c0                	test   %eax,%eax
  80181e:	78 47                	js     801867 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801820:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801823:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801827:	75 24                	jne    80184d <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801829:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80182e:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801834:	83 ec 04             	sub    $0x4,%esp
  801837:	53                   	push   %ebx
  801838:	50                   	push   %eax
  801839:	68 04 29 80 00       	push   $0x802904
  80183e:	e8 ce e9 ff ff       	call   800211 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801843:	83 c4 10             	add    $0x10,%esp
  801846:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80184b:	eb 23                	jmp    801870 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  80184d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801850:	8b 52 18             	mov    0x18(%edx),%edx
  801853:	85 d2                	test   %edx,%edx
  801855:	74 14                	je     80186b <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801857:	83 ec 08             	sub    $0x8,%esp
  80185a:	ff 75 0c             	pushl  0xc(%ebp)
  80185d:	50                   	push   %eax
  80185e:	ff d2                	call   *%edx
  801860:	89 c2                	mov    %eax,%edx
  801862:	83 c4 10             	add    $0x10,%esp
  801865:	eb 09                	jmp    801870 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801867:	89 c2                	mov    %eax,%edx
  801869:	eb 05                	jmp    801870 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80186b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801870:	89 d0                	mov    %edx,%eax
  801872:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801875:	c9                   	leave  
  801876:	c3                   	ret    

00801877 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801877:	55                   	push   %ebp
  801878:	89 e5                	mov    %esp,%ebp
  80187a:	53                   	push   %ebx
  80187b:	83 ec 14             	sub    $0x14,%esp
  80187e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801881:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801884:	50                   	push   %eax
  801885:	ff 75 08             	pushl  0x8(%ebp)
  801888:	e8 60 fb ff ff       	call   8013ed <fd_lookup>
  80188d:	83 c4 08             	add    $0x8,%esp
  801890:	89 c2                	mov    %eax,%edx
  801892:	85 c0                	test   %eax,%eax
  801894:	78 58                	js     8018ee <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801896:	83 ec 08             	sub    $0x8,%esp
  801899:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80189c:	50                   	push   %eax
  80189d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a0:	ff 30                	pushl  (%eax)
  8018a2:	e8 9c fb ff ff       	call   801443 <dev_lookup>
  8018a7:	83 c4 10             	add    $0x10,%esp
  8018aa:	85 c0                	test   %eax,%eax
  8018ac:	78 37                	js     8018e5 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8018ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018b1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018b5:	74 32                	je     8018e9 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018b7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018ba:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018c1:	00 00 00 
	stat->st_isdir = 0;
  8018c4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018cb:	00 00 00 
	stat->st_dev = dev;
  8018ce:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018d4:	83 ec 08             	sub    $0x8,%esp
  8018d7:	53                   	push   %ebx
  8018d8:	ff 75 f0             	pushl  -0x10(%ebp)
  8018db:	ff 50 14             	call   *0x14(%eax)
  8018de:	89 c2                	mov    %eax,%edx
  8018e0:	83 c4 10             	add    $0x10,%esp
  8018e3:	eb 09                	jmp    8018ee <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018e5:	89 c2                	mov    %eax,%edx
  8018e7:	eb 05                	jmp    8018ee <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018e9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018ee:	89 d0                	mov    %edx,%eax
  8018f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f3:	c9                   	leave  
  8018f4:	c3                   	ret    

008018f5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018f5:	55                   	push   %ebp
  8018f6:	89 e5                	mov    %esp,%ebp
  8018f8:	56                   	push   %esi
  8018f9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018fa:	83 ec 08             	sub    $0x8,%esp
  8018fd:	6a 00                	push   $0x0
  8018ff:	ff 75 08             	pushl  0x8(%ebp)
  801902:	e8 e3 01 00 00       	call   801aea <open>
  801907:	89 c3                	mov    %eax,%ebx
  801909:	83 c4 10             	add    $0x10,%esp
  80190c:	85 c0                	test   %eax,%eax
  80190e:	78 1b                	js     80192b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801910:	83 ec 08             	sub    $0x8,%esp
  801913:	ff 75 0c             	pushl  0xc(%ebp)
  801916:	50                   	push   %eax
  801917:	e8 5b ff ff ff       	call   801877 <fstat>
  80191c:	89 c6                	mov    %eax,%esi
	close(fd);
  80191e:	89 1c 24             	mov    %ebx,(%esp)
  801921:	e8 f4 fb ff ff       	call   80151a <close>
	return r;
  801926:	83 c4 10             	add    $0x10,%esp
  801929:	89 f0                	mov    %esi,%eax
}
  80192b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80192e:	5b                   	pop    %ebx
  80192f:	5e                   	pop    %esi
  801930:	5d                   	pop    %ebp
  801931:	c3                   	ret    

00801932 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801932:	55                   	push   %ebp
  801933:	89 e5                	mov    %esp,%ebp
  801935:	56                   	push   %esi
  801936:	53                   	push   %ebx
  801937:	89 c6                	mov    %eax,%esi
  801939:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80193b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801942:	75 12                	jne    801956 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801944:	83 ec 0c             	sub    $0xc,%esp
  801947:	6a 01                	push   $0x1
  801949:	e8 05 08 00 00       	call   802153 <ipc_find_env>
  80194e:	a3 00 40 80 00       	mov    %eax,0x804000
  801953:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801956:	6a 07                	push   $0x7
  801958:	68 00 50 80 00       	push   $0x805000
  80195d:	56                   	push   %esi
  80195e:	ff 35 00 40 80 00    	pushl  0x804000
  801964:	e8 88 07 00 00       	call   8020f1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801969:	83 c4 0c             	add    $0xc,%esp
  80196c:	6a 00                	push   $0x0
  80196e:	53                   	push   %ebx
  80196f:	6a 00                	push   $0x0
  801971:	e8 00 07 00 00       	call   802076 <ipc_recv>
}
  801976:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801979:	5b                   	pop    %ebx
  80197a:	5e                   	pop    %esi
  80197b:	5d                   	pop    %ebp
  80197c:	c3                   	ret    

0080197d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80197d:	55                   	push   %ebp
  80197e:	89 e5                	mov    %esp,%ebp
  801980:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801983:	8b 45 08             	mov    0x8(%ebp),%eax
  801986:	8b 40 0c             	mov    0xc(%eax),%eax
  801989:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80198e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801991:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801996:	ba 00 00 00 00       	mov    $0x0,%edx
  80199b:	b8 02 00 00 00       	mov    $0x2,%eax
  8019a0:	e8 8d ff ff ff       	call   801932 <fsipc>
}
  8019a5:	c9                   	leave  
  8019a6:	c3                   	ret    

008019a7 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019a7:	55                   	push   %ebp
  8019a8:	89 e5                	mov    %esp,%ebp
  8019aa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b0:	8b 40 0c             	mov    0xc(%eax),%eax
  8019b3:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8019bd:	b8 06 00 00 00       	mov    $0x6,%eax
  8019c2:	e8 6b ff ff ff       	call   801932 <fsipc>
}
  8019c7:	c9                   	leave  
  8019c8:	c3                   	ret    

008019c9 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019c9:	55                   	push   %ebp
  8019ca:	89 e5                	mov    %esp,%ebp
  8019cc:	53                   	push   %ebx
  8019cd:	83 ec 04             	sub    $0x4,%esp
  8019d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d6:	8b 40 0c             	mov    0xc(%eax),%eax
  8019d9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019de:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e3:	b8 05 00 00 00       	mov    $0x5,%eax
  8019e8:	e8 45 ff ff ff       	call   801932 <fsipc>
  8019ed:	85 c0                	test   %eax,%eax
  8019ef:	78 2c                	js     801a1d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019f1:	83 ec 08             	sub    $0x8,%esp
  8019f4:	68 00 50 80 00       	push   $0x805000
  8019f9:	53                   	push   %ebx
  8019fa:	e8 97 ed ff ff       	call   800796 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019ff:	a1 80 50 80 00       	mov    0x805080,%eax
  801a04:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a0a:	a1 84 50 80 00       	mov    0x805084,%eax
  801a0f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a15:	83 c4 10             	add    $0x10,%esp
  801a18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a1d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a20:	c9                   	leave  
  801a21:	c3                   	ret    

00801a22 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a22:	55                   	push   %ebp
  801a23:	89 e5                	mov    %esp,%ebp
  801a25:	83 ec 0c             	sub    $0xc,%esp
  801a28:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a2b:	8b 55 08             	mov    0x8(%ebp),%edx
  801a2e:	8b 52 0c             	mov    0xc(%edx),%edx
  801a31:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801a37:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a3c:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a41:	0f 47 c2             	cmova  %edx,%eax
  801a44:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801a49:	50                   	push   %eax
  801a4a:	ff 75 0c             	pushl  0xc(%ebp)
  801a4d:	68 08 50 80 00       	push   $0x805008
  801a52:	e8 d1 ee ff ff       	call   800928 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801a57:	ba 00 00 00 00       	mov    $0x0,%edx
  801a5c:	b8 04 00 00 00       	mov    $0x4,%eax
  801a61:	e8 cc fe ff ff       	call   801932 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801a66:	c9                   	leave  
  801a67:	c3                   	ret    

00801a68 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a68:	55                   	push   %ebp
  801a69:	89 e5                	mov    %esp,%ebp
  801a6b:	56                   	push   %esi
  801a6c:	53                   	push   %ebx
  801a6d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a70:	8b 45 08             	mov    0x8(%ebp),%eax
  801a73:	8b 40 0c             	mov    0xc(%eax),%eax
  801a76:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a7b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a81:	ba 00 00 00 00       	mov    $0x0,%edx
  801a86:	b8 03 00 00 00       	mov    $0x3,%eax
  801a8b:	e8 a2 fe ff ff       	call   801932 <fsipc>
  801a90:	89 c3                	mov    %eax,%ebx
  801a92:	85 c0                	test   %eax,%eax
  801a94:	78 4b                	js     801ae1 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a96:	39 c6                	cmp    %eax,%esi
  801a98:	73 16                	jae    801ab0 <devfile_read+0x48>
  801a9a:	68 74 29 80 00       	push   $0x802974
  801a9f:	68 7b 29 80 00       	push   $0x80297b
  801aa4:	6a 7c                	push   $0x7c
  801aa6:	68 90 29 80 00       	push   $0x802990
  801aab:	e8 88 e6 ff ff       	call   800138 <_panic>
	assert(r <= PGSIZE);
  801ab0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ab5:	7e 16                	jle    801acd <devfile_read+0x65>
  801ab7:	68 9b 29 80 00       	push   $0x80299b
  801abc:	68 7b 29 80 00       	push   $0x80297b
  801ac1:	6a 7d                	push   $0x7d
  801ac3:	68 90 29 80 00       	push   $0x802990
  801ac8:	e8 6b e6 ff ff       	call   800138 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801acd:	83 ec 04             	sub    $0x4,%esp
  801ad0:	50                   	push   %eax
  801ad1:	68 00 50 80 00       	push   $0x805000
  801ad6:	ff 75 0c             	pushl  0xc(%ebp)
  801ad9:	e8 4a ee ff ff       	call   800928 <memmove>
	return r;
  801ade:	83 c4 10             	add    $0x10,%esp
}
  801ae1:	89 d8                	mov    %ebx,%eax
  801ae3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ae6:	5b                   	pop    %ebx
  801ae7:	5e                   	pop    %esi
  801ae8:	5d                   	pop    %ebp
  801ae9:	c3                   	ret    

00801aea <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	53                   	push   %ebx
  801aee:	83 ec 20             	sub    $0x20,%esp
  801af1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801af4:	53                   	push   %ebx
  801af5:	e8 63 ec ff ff       	call   80075d <strlen>
  801afa:	83 c4 10             	add    $0x10,%esp
  801afd:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b02:	7f 67                	jg     801b6b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b04:	83 ec 0c             	sub    $0xc,%esp
  801b07:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b0a:	50                   	push   %eax
  801b0b:	e8 8e f8 ff ff       	call   80139e <fd_alloc>
  801b10:	83 c4 10             	add    $0x10,%esp
		return r;
  801b13:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b15:	85 c0                	test   %eax,%eax
  801b17:	78 57                	js     801b70 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b19:	83 ec 08             	sub    $0x8,%esp
  801b1c:	53                   	push   %ebx
  801b1d:	68 00 50 80 00       	push   $0x805000
  801b22:	e8 6f ec ff ff       	call   800796 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b27:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b2a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b2f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b32:	b8 01 00 00 00       	mov    $0x1,%eax
  801b37:	e8 f6 fd ff ff       	call   801932 <fsipc>
  801b3c:	89 c3                	mov    %eax,%ebx
  801b3e:	83 c4 10             	add    $0x10,%esp
  801b41:	85 c0                	test   %eax,%eax
  801b43:	79 14                	jns    801b59 <open+0x6f>
		fd_close(fd, 0);
  801b45:	83 ec 08             	sub    $0x8,%esp
  801b48:	6a 00                	push   $0x0
  801b4a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b4d:	e8 47 f9 ff ff       	call   801499 <fd_close>
		return r;
  801b52:	83 c4 10             	add    $0x10,%esp
  801b55:	89 da                	mov    %ebx,%edx
  801b57:	eb 17                	jmp    801b70 <open+0x86>
	}

	return fd2num(fd);
  801b59:	83 ec 0c             	sub    $0xc,%esp
  801b5c:	ff 75 f4             	pushl  -0xc(%ebp)
  801b5f:	e8 13 f8 ff ff       	call   801377 <fd2num>
  801b64:	89 c2                	mov    %eax,%edx
  801b66:	83 c4 10             	add    $0x10,%esp
  801b69:	eb 05                	jmp    801b70 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b6b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b70:	89 d0                	mov    %edx,%eax
  801b72:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b75:	c9                   	leave  
  801b76:	c3                   	ret    

00801b77 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b77:	55                   	push   %ebp
  801b78:	89 e5                	mov    %esp,%ebp
  801b7a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b7d:	ba 00 00 00 00       	mov    $0x0,%edx
  801b82:	b8 08 00 00 00       	mov    $0x8,%eax
  801b87:	e8 a6 fd ff ff       	call   801932 <fsipc>
}
  801b8c:	c9                   	leave  
  801b8d:	c3                   	ret    

00801b8e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b8e:	55                   	push   %ebp
  801b8f:	89 e5                	mov    %esp,%ebp
  801b91:	56                   	push   %esi
  801b92:	53                   	push   %ebx
  801b93:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b96:	83 ec 0c             	sub    $0xc,%esp
  801b99:	ff 75 08             	pushl  0x8(%ebp)
  801b9c:	e8 e6 f7 ff ff       	call   801387 <fd2data>
  801ba1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ba3:	83 c4 08             	add    $0x8,%esp
  801ba6:	68 a7 29 80 00       	push   $0x8029a7
  801bab:	53                   	push   %ebx
  801bac:	e8 e5 eb ff ff       	call   800796 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bb1:	8b 46 04             	mov    0x4(%esi),%eax
  801bb4:	2b 06                	sub    (%esi),%eax
  801bb6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801bbc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bc3:	00 00 00 
	stat->st_dev = &devpipe;
  801bc6:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801bcd:	30 80 00 
	return 0;
}
  801bd0:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bd8:	5b                   	pop    %ebx
  801bd9:	5e                   	pop    %esi
  801bda:	5d                   	pop    %ebp
  801bdb:	c3                   	ret    

00801bdc <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bdc:	55                   	push   %ebp
  801bdd:	89 e5                	mov    %esp,%ebp
  801bdf:	53                   	push   %ebx
  801be0:	83 ec 0c             	sub    $0xc,%esp
  801be3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801be6:	53                   	push   %ebx
  801be7:	6a 00                	push   $0x0
  801be9:	e8 30 f0 ff ff       	call   800c1e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bee:	89 1c 24             	mov    %ebx,(%esp)
  801bf1:	e8 91 f7 ff ff       	call   801387 <fd2data>
  801bf6:	83 c4 08             	add    $0x8,%esp
  801bf9:	50                   	push   %eax
  801bfa:	6a 00                	push   $0x0
  801bfc:	e8 1d f0 ff ff       	call   800c1e <sys_page_unmap>
}
  801c01:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c04:	c9                   	leave  
  801c05:	c3                   	ret    

00801c06 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c06:	55                   	push   %ebp
  801c07:	89 e5                	mov    %esp,%ebp
  801c09:	57                   	push   %edi
  801c0a:	56                   	push   %esi
  801c0b:	53                   	push   %ebx
  801c0c:	83 ec 1c             	sub    $0x1c,%esp
  801c0f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c12:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c14:	a1 04 40 80 00       	mov    0x804004,%eax
  801c19:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c1f:	83 ec 0c             	sub    $0xc,%esp
  801c22:	ff 75 e0             	pushl  -0x20(%ebp)
  801c25:	e8 6e 05 00 00       	call   802198 <pageref>
  801c2a:	89 c3                	mov    %eax,%ebx
  801c2c:	89 3c 24             	mov    %edi,(%esp)
  801c2f:	e8 64 05 00 00       	call   802198 <pageref>
  801c34:	83 c4 10             	add    $0x10,%esp
  801c37:	39 c3                	cmp    %eax,%ebx
  801c39:	0f 94 c1             	sete   %cl
  801c3c:	0f b6 c9             	movzbl %cl,%ecx
  801c3f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c42:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c48:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  801c4e:	39 ce                	cmp    %ecx,%esi
  801c50:	74 1e                	je     801c70 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801c52:	39 c3                	cmp    %eax,%ebx
  801c54:	75 be                	jne    801c14 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c56:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  801c5c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c5f:	50                   	push   %eax
  801c60:	56                   	push   %esi
  801c61:	68 ae 29 80 00       	push   $0x8029ae
  801c66:	e8 a6 e5 ff ff       	call   800211 <cprintf>
  801c6b:	83 c4 10             	add    $0x10,%esp
  801c6e:	eb a4                	jmp    801c14 <_pipeisclosed+0xe>
	}
}
  801c70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c76:	5b                   	pop    %ebx
  801c77:	5e                   	pop    %esi
  801c78:	5f                   	pop    %edi
  801c79:	5d                   	pop    %ebp
  801c7a:	c3                   	ret    

00801c7b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c7b:	55                   	push   %ebp
  801c7c:	89 e5                	mov    %esp,%ebp
  801c7e:	57                   	push   %edi
  801c7f:	56                   	push   %esi
  801c80:	53                   	push   %ebx
  801c81:	83 ec 28             	sub    $0x28,%esp
  801c84:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c87:	56                   	push   %esi
  801c88:	e8 fa f6 ff ff       	call   801387 <fd2data>
  801c8d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c8f:	83 c4 10             	add    $0x10,%esp
  801c92:	bf 00 00 00 00       	mov    $0x0,%edi
  801c97:	eb 4b                	jmp    801ce4 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c99:	89 da                	mov    %ebx,%edx
  801c9b:	89 f0                	mov    %esi,%eax
  801c9d:	e8 64 ff ff ff       	call   801c06 <_pipeisclosed>
  801ca2:	85 c0                	test   %eax,%eax
  801ca4:	75 48                	jne    801cee <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ca6:	e8 cf ee ff ff       	call   800b7a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cab:	8b 43 04             	mov    0x4(%ebx),%eax
  801cae:	8b 0b                	mov    (%ebx),%ecx
  801cb0:	8d 51 20             	lea    0x20(%ecx),%edx
  801cb3:	39 d0                	cmp    %edx,%eax
  801cb5:	73 e2                	jae    801c99 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cba:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801cbe:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801cc1:	89 c2                	mov    %eax,%edx
  801cc3:	c1 fa 1f             	sar    $0x1f,%edx
  801cc6:	89 d1                	mov    %edx,%ecx
  801cc8:	c1 e9 1b             	shr    $0x1b,%ecx
  801ccb:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801cce:	83 e2 1f             	and    $0x1f,%edx
  801cd1:	29 ca                	sub    %ecx,%edx
  801cd3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801cd7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cdb:	83 c0 01             	add    $0x1,%eax
  801cde:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ce1:	83 c7 01             	add    $0x1,%edi
  801ce4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ce7:	75 c2                	jne    801cab <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ce9:	8b 45 10             	mov    0x10(%ebp),%eax
  801cec:	eb 05                	jmp    801cf3 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cee:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801cf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cf6:	5b                   	pop    %ebx
  801cf7:	5e                   	pop    %esi
  801cf8:	5f                   	pop    %edi
  801cf9:	5d                   	pop    %ebp
  801cfa:	c3                   	ret    

00801cfb <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	57                   	push   %edi
  801cff:	56                   	push   %esi
  801d00:	53                   	push   %ebx
  801d01:	83 ec 18             	sub    $0x18,%esp
  801d04:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d07:	57                   	push   %edi
  801d08:	e8 7a f6 ff ff       	call   801387 <fd2data>
  801d0d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d0f:	83 c4 10             	add    $0x10,%esp
  801d12:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d17:	eb 3d                	jmp    801d56 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d19:	85 db                	test   %ebx,%ebx
  801d1b:	74 04                	je     801d21 <devpipe_read+0x26>
				return i;
  801d1d:	89 d8                	mov    %ebx,%eax
  801d1f:	eb 44                	jmp    801d65 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d21:	89 f2                	mov    %esi,%edx
  801d23:	89 f8                	mov    %edi,%eax
  801d25:	e8 dc fe ff ff       	call   801c06 <_pipeisclosed>
  801d2a:	85 c0                	test   %eax,%eax
  801d2c:	75 32                	jne    801d60 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d2e:	e8 47 ee ff ff       	call   800b7a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d33:	8b 06                	mov    (%esi),%eax
  801d35:	3b 46 04             	cmp    0x4(%esi),%eax
  801d38:	74 df                	je     801d19 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d3a:	99                   	cltd   
  801d3b:	c1 ea 1b             	shr    $0x1b,%edx
  801d3e:	01 d0                	add    %edx,%eax
  801d40:	83 e0 1f             	and    $0x1f,%eax
  801d43:	29 d0                	sub    %edx,%eax
  801d45:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d4d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d50:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d53:	83 c3 01             	add    $0x1,%ebx
  801d56:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d59:	75 d8                	jne    801d33 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d5b:	8b 45 10             	mov    0x10(%ebp),%eax
  801d5e:	eb 05                	jmp    801d65 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d60:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d68:	5b                   	pop    %ebx
  801d69:	5e                   	pop    %esi
  801d6a:	5f                   	pop    %edi
  801d6b:	5d                   	pop    %ebp
  801d6c:	c3                   	ret    

00801d6d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d6d:	55                   	push   %ebp
  801d6e:	89 e5                	mov    %esp,%ebp
  801d70:	56                   	push   %esi
  801d71:	53                   	push   %ebx
  801d72:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d75:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d78:	50                   	push   %eax
  801d79:	e8 20 f6 ff ff       	call   80139e <fd_alloc>
  801d7e:	83 c4 10             	add    $0x10,%esp
  801d81:	89 c2                	mov    %eax,%edx
  801d83:	85 c0                	test   %eax,%eax
  801d85:	0f 88 2c 01 00 00    	js     801eb7 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d8b:	83 ec 04             	sub    $0x4,%esp
  801d8e:	68 07 04 00 00       	push   $0x407
  801d93:	ff 75 f4             	pushl  -0xc(%ebp)
  801d96:	6a 00                	push   $0x0
  801d98:	e8 fc ed ff ff       	call   800b99 <sys_page_alloc>
  801d9d:	83 c4 10             	add    $0x10,%esp
  801da0:	89 c2                	mov    %eax,%edx
  801da2:	85 c0                	test   %eax,%eax
  801da4:	0f 88 0d 01 00 00    	js     801eb7 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801daa:	83 ec 0c             	sub    $0xc,%esp
  801dad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801db0:	50                   	push   %eax
  801db1:	e8 e8 f5 ff ff       	call   80139e <fd_alloc>
  801db6:	89 c3                	mov    %eax,%ebx
  801db8:	83 c4 10             	add    $0x10,%esp
  801dbb:	85 c0                	test   %eax,%eax
  801dbd:	0f 88 e2 00 00 00    	js     801ea5 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dc3:	83 ec 04             	sub    $0x4,%esp
  801dc6:	68 07 04 00 00       	push   $0x407
  801dcb:	ff 75 f0             	pushl  -0x10(%ebp)
  801dce:	6a 00                	push   $0x0
  801dd0:	e8 c4 ed ff ff       	call   800b99 <sys_page_alloc>
  801dd5:	89 c3                	mov    %eax,%ebx
  801dd7:	83 c4 10             	add    $0x10,%esp
  801dda:	85 c0                	test   %eax,%eax
  801ddc:	0f 88 c3 00 00 00    	js     801ea5 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801de2:	83 ec 0c             	sub    $0xc,%esp
  801de5:	ff 75 f4             	pushl  -0xc(%ebp)
  801de8:	e8 9a f5 ff ff       	call   801387 <fd2data>
  801ded:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801def:	83 c4 0c             	add    $0xc,%esp
  801df2:	68 07 04 00 00       	push   $0x407
  801df7:	50                   	push   %eax
  801df8:	6a 00                	push   $0x0
  801dfa:	e8 9a ed ff ff       	call   800b99 <sys_page_alloc>
  801dff:	89 c3                	mov    %eax,%ebx
  801e01:	83 c4 10             	add    $0x10,%esp
  801e04:	85 c0                	test   %eax,%eax
  801e06:	0f 88 89 00 00 00    	js     801e95 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e0c:	83 ec 0c             	sub    $0xc,%esp
  801e0f:	ff 75 f0             	pushl  -0x10(%ebp)
  801e12:	e8 70 f5 ff ff       	call   801387 <fd2data>
  801e17:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e1e:	50                   	push   %eax
  801e1f:	6a 00                	push   $0x0
  801e21:	56                   	push   %esi
  801e22:	6a 00                	push   $0x0
  801e24:	e8 b3 ed ff ff       	call   800bdc <sys_page_map>
  801e29:	89 c3                	mov    %eax,%ebx
  801e2b:	83 c4 20             	add    $0x20,%esp
  801e2e:	85 c0                	test   %eax,%eax
  801e30:	78 55                	js     801e87 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e32:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e3b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e40:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e47:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e50:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e52:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e55:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e5c:	83 ec 0c             	sub    $0xc,%esp
  801e5f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e62:	e8 10 f5 ff ff       	call   801377 <fd2num>
  801e67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e6a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e6c:	83 c4 04             	add    $0x4,%esp
  801e6f:	ff 75 f0             	pushl  -0x10(%ebp)
  801e72:	e8 00 f5 ff ff       	call   801377 <fd2num>
  801e77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e7a:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801e7d:	83 c4 10             	add    $0x10,%esp
  801e80:	ba 00 00 00 00       	mov    $0x0,%edx
  801e85:	eb 30                	jmp    801eb7 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e87:	83 ec 08             	sub    $0x8,%esp
  801e8a:	56                   	push   %esi
  801e8b:	6a 00                	push   $0x0
  801e8d:	e8 8c ed ff ff       	call   800c1e <sys_page_unmap>
  801e92:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e95:	83 ec 08             	sub    $0x8,%esp
  801e98:	ff 75 f0             	pushl  -0x10(%ebp)
  801e9b:	6a 00                	push   $0x0
  801e9d:	e8 7c ed ff ff       	call   800c1e <sys_page_unmap>
  801ea2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ea5:	83 ec 08             	sub    $0x8,%esp
  801ea8:	ff 75 f4             	pushl  -0xc(%ebp)
  801eab:	6a 00                	push   $0x0
  801ead:	e8 6c ed ff ff       	call   800c1e <sys_page_unmap>
  801eb2:	83 c4 10             	add    $0x10,%esp
  801eb5:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801eb7:	89 d0                	mov    %edx,%eax
  801eb9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ebc:	5b                   	pop    %ebx
  801ebd:	5e                   	pop    %esi
  801ebe:	5d                   	pop    %ebp
  801ebf:	c3                   	ret    

00801ec0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ec0:	55                   	push   %ebp
  801ec1:	89 e5                	mov    %esp,%ebp
  801ec3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ec6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ec9:	50                   	push   %eax
  801eca:	ff 75 08             	pushl  0x8(%ebp)
  801ecd:	e8 1b f5 ff ff       	call   8013ed <fd_lookup>
  801ed2:	83 c4 10             	add    $0x10,%esp
  801ed5:	85 c0                	test   %eax,%eax
  801ed7:	78 18                	js     801ef1 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ed9:	83 ec 0c             	sub    $0xc,%esp
  801edc:	ff 75 f4             	pushl  -0xc(%ebp)
  801edf:	e8 a3 f4 ff ff       	call   801387 <fd2data>
	return _pipeisclosed(fd, p);
  801ee4:	89 c2                	mov    %eax,%edx
  801ee6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee9:	e8 18 fd ff ff       	call   801c06 <_pipeisclosed>
  801eee:	83 c4 10             	add    $0x10,%esp
}
  801ef1:	c9                   	leave  
  801ef2:	c3                   	ret    

00801ef3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ef3:	55                   	push   %ebp
  801ef4:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ef6:	b8 00 00 00 00       	mov    $0x0,%eax
  801efb:	5d                   	pop    %ebp
  801efc:	c3                   	ret    

00801efd <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801efd:	55                   	push   %ebp
  801efe:	89 e5                	mov    %esp,%ebp
  801f00:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f03:	68 c6 29 80 00       	push   $0x8029c6
  801f08:	ff 75 0c             	pushl  0xc(%ebp)
  801f0b:	e8 86 e8 ff ff       	call   800796 <strcpy>
	return 0;
}
  801f10:	b8 00 00 00 00       	mov    $0x0,%eax
  801f15:	c9                   	leave  
  801f16:	c3                   	ret    

00801f17 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f17:	55                   	push   %ebp
  801f18:	89 e5                	mov    %esp,%ebp
  801f1a:	57                   	push   %edi
  801f1b:	56                   	push   %esi
  801f1c:	53                   	push   %ebx
  801f1d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f23:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f28:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f2e:	eb 2d                	jmp    801f5d <devcons_write+0x46>
		m = n - tot;
  801f30:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f33:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f35:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f38:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f3d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f40:	83 ec 04             	sub    $0x4,%esp
  801f43:	53                   	push   %ebx
  801f44:	03 45 0c             	add    0xc(%ebp),%eax
  801f47:	50                   	push   %eax
  801f48:	57                   	push   %edi
  801f49:	e8 da e9 ff ff       	call   800928 <memmove>
		sys_cputs(buf, m);
  801f4e:	83 c4 08             	add    $0x8,%esp
  801f51:	53                   	push   %ebx
  801f52:	57                   	push   %edi
  801f53:	e8 85 eb ff ff       	call   800add <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f58:	01 de                	add    %ebx,%esi
  801f5a:	83 c4 10             	add    $0x10,%esp
  801f5d:	89 f0                	mov    %esi,%eax
  801f5f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f62:	72 cc                	jb     801f30 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f67:	5b                   	pop    %ebx
  801f68:	5e                   	pop    %esi
  801f69:	5f                   	pop    %edi
  801f6a:	5d                   	pop    %ebp
  801f6b:	c3                   	ret    

00801f6c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f6c:	55                   	push   %ebp
  801f6d:	89 e5                	mov    %esp,%ebp
  801f6f:	83 ec 08             	sub    $0x8,%esp
  801f72:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f77:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f7b:	74 2a                	je     801fa7 <devcons_read+0x3b>
  801f7d:	eb 05                	jmp    801f84 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f7f:	e8 f6 eb ff ff       	call   800b7a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f84:	e8 72 eb ff ff       	call   800afb <sys_cgetc>
  801f89:	85 c0                	test   %eax,%eax
  801f8b:	74 f2                	je     801f7f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f8d:	85 c0                	test   %eax,%eax
  801f8f:	78 16                	js     801fa7 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f91:	83 f8 04             	cmp    $0x4,%eax
  801f94:	74 0c                	je     801fa2 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f96:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f99:	88 02                	mov    %al,(%edx)
	return 1;
  801f9b:	b8 01 00 00 00       	mov    $0x1,%eax
  801fa0:	eb 05                	jmp    801fa7 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801fa2:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801fa7:	c9                   	leave  
  801fa8:	c3                   	ret    

00801fa9 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801fa9:	55                   	push   %ebp
  801faa:	89 e5                	mov    %esp,%ebp
  801fac:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801faf:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb2:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801fb5:	6a 01                	push   $0x1
  801fb7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fba:	50                   	push   %eax
  801fbb:	e8 1d eb ff ff       	call   800add <sys_cputs>
}
  801fc0:	83 c4 10             	add    $0x10,%esp
  801fc3:	c9                   	leave  
  801fc4:	c3                   	ret    

00801fc5 <getchar>:

int
getchar(void)
{
  801fc5:	55                   	push   %ebp
  801fc6:	89 e5                	mov    %esp,%ebp
  801fc8:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801fcb:	6a 01                	push   $0x1
  801fcd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fd0:	50                   	push   %eax
  801fd1:	6a 00                	push   $0x0
  801fd3:	e8 7e f6 ff ff       	call   801656 <read>
	if (r < 0)
  801fd8:	83 c4 10             	add    $0x10,%esp
  801fdb:	85 c0                	test   %eax,%eax
  801fdd:	78 0f                	js     801fee <getchar+0x29>
		return r;
	if (r < 1)
  801fdf:	85 c0                	test   %eax,%eax
  801fe1:	7e 06                	jle    801fe9 <getchar+0x24>
		return -E_EOF;
	return c;
  801fe3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fe7:	eb 05                	jmp    801fee <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fe9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801fee:	c9                   	leave  
  801fef:	c3                   	ret    

00801ff0 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ff0:	55                   	push   %ebp
  801ff1:	89 e5                	mov    %esp,%ebp
  801ff3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ff6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ff9:	50                   	push   %eax
  801ffa:	ff 75 08             	pushl  0x8(%ebp)
  801ffd:	e8 eb f3 ff ff       	call   8013ed <fd_lookup>
  802002:	83 c4 10             	add    $0x10,%esp
  802005:	85 c0                	test   %eax,%eax
  802007:	78 11                	js     80201a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802009:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80200c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802012:	39 10                	cmp    %edx,(%eax)
  802014:	0f 94 c0             	sete   %al
  802017:	0f b6 c0             	movzbl %al,%eax
}
  80201a:	c9                   	leave  
  80201b:	c3                   	ret    

0080201c <opencons>:

int
opencons(void)
{
  80201c:	55                   	push   %ebp
  80201d:	89 e5                	mov    %esp,%ebp
  80201f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802022:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802025:	50                   	push   %eax
  802026:	e8 73 f3 ff ff       	call   80139e <fd_alloc>
  80202b:	83 c4 10             	add    $0x10,%esp
		return r;
  80202e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802030:	85 c0                	test   %eax,%eax
  802032:	78 3e                	js     802072 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802034:	83 ec 04             	sub    $0x4,%esp
  802037:	68 07 04 00 00       	push   $0x407
  80203c:	ff 75 f4             	pushl  -0xc(%ebp)
  80203f:	6a 00                	push   $0x0
  802041:	e8 53 eb ff ff       	call   800b99 <sys_page_alloc>
  802046:	83 c4 10             	add    $0x10,%esp
		return r;
  802049:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80204b:	85 c0                	test   %eax,%eax
  80204d:	78 23                	js     802072 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80204f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802055:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802058:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80205a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80205d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802064:	83 ec 0c             	sub    $0xc,%esp
  802067:	50                   	push   %eax
  802068:	e8 0a f3 ff ff       	call   801377 <fd2num>
  80206d:	89 c2                	mov    %eax,%edx
  80206f:	83 c4 10             	add    $0x10,%esp
}
  802072:	89 d0                	mov    %edx,%eax
  802074:	c9                   	leave  
  802075:	c3                   	ret    

00802076 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802076:	55                   	push   %ebp
  802077:	89 e5                	mov    %esp,%ebp
  802079:	56                   	push   %esi
  80207a:	53                   	push   %ebx
  80207b:	8b 75 08             	mov    0x8(%ebp),%esi
  80207e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802081:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802084:	85 c0                	test   %eax,%eax
  802086:	75 12                	jne    80209a <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802088:	83 ec 0c             	sub    $0xc,%esp
  80208b:	68 00 00 c0 ee       	push   $0xeec00000
  802090:	e8 b4 ec ff ff       	call   800d49 <sys_ipc_recv>
  802095:	83 c4 10             	add    $0x10,%esp
  802098:	eb 0c                	jmp    8020a6 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80209a:	83 ec 0c             	sub    $0xc,%esp
  80209d:	50                   	push   %eax
  80209e:	e8 a6 ec ff ff       	call   800d49 <sys_ipc_recv>
  8020a3:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8020a6:	85 f6                	test   %esi,%esi
  8020a8:	0f 95 c1             	setne  %cl
  8020ab:	85 db                	test   %ebx,%ebx
  8020ad:	0f 95 c2             	setne  %dl
  8020b0:	84 d1                	test   %dl,%cl
  8020b2:	74 09                	je     8020bd <ipc_recv+0x47>
  8020b4:	89 c2                	mov    %eax,%edx
  8020b6:	c1 ea 1f             	shr    $0x1f,%edx
  8020b9:	84 d2                	test   %dl,%dl
  8020bb:	75 2d                	jne    8020ea <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8020bd:	85 f6                	test   %esi,%esi
  8020bf:	74 0d                	je     8020ce <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8020c1:	a1 04 40 80 00       	mov    0x804004,%eax
  8020c6:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  8020cc:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8020ce:	85 db                	test   %ebx,%ebx
  8020d0:	74 0d                	je     8020df <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8020d2:	a1 04 40 80 00       	mov    0x804004,%eax
  8020d7:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8020dd:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8020df:	a1 04 40 80 00       	mov    0x804004,%eax
  8020e4:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  8020ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020ed:	5b                   	pop    %ebx
  8020ee:	5e                   	pop    %esi
  8020ef:	5d                   	pop    %ebp
  8020f0:	c3                   	ret    

008020f1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020f1:	55                   	push   %ebp
  8020f2:	89 e5                	mov    %esp,%ebp
  8020f4:	57                   	push   %edi
  8020f5:	56                   	push   %esi
  8020f6:	53                   	push   %ebx
  8020f7:	83 ec 0c             	sub    $0xc,%esp
  8020fa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020fd:	8b 75 0c             	mov    0xc(%ebp),%esi
  802100:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802103:	85 db                	test   %ebx,%ebx
  802105:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80210a:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80210d:	ff 75 14             	pushl  0x14(%ebp)
  802110:	53                   	push   %ebx
  802111:	56                   	push   %esi
  802112:	57                   	push   %edi
  802113:	e8 0e ec ff ff       	call   800d26 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802118:	89 c2                	mov    %eax,%edx
  80211a:	c1 ea 1f             	shr    $0x1f,%edx
  80211d:	83 c4 10             	add    $0x10,%esp
  802120:	84 d2                	test   %dl,%dl
  802122:	74 17                	je     80213b <ipc_send+0x4a>
  802124:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802127:	74 12                	je     80213b <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802129:	50                   	push   %eax
  80212a:	68 d2 29 80 00       	push   $0x8029d2
  80212f:	6a 47                	push   $0x47
  802131:	68 e0 29 80 00       	push   $0x8029e0
  802136:	e8 fd df ff ff       	call   800138 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80213b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80213e:	75 07                	jne    802147 <ipc_send+0x56>
			sys_yield();
  802140:	e8 35 ea ff ff       	call   800b7a <sys_yield>
  802145:	eb c6                	jmp    80210d <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802147:	85 c0                	test   %eax,%eax
  802149:	75 c2                	jne    80210d <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80214b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80214e:	5b                   	pop    %ebx
  80214f:	5e                   	pop    %esi
  802150:	5f                   	pop    %edi
  802151:	5d                   	pop    %ebp
  802152:	c3                   	ret    

00802153 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802153:	55                   	push   %ebp
  802154:	89 e5                	mov    %esp,%ebp
  802156:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802159:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80215e:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  802164:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80216a:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  802170:	39 ca                	cmp    %ecx,%edx
  802172:	75 13                	jne    802187 <ipc_find_env+0x34>
			return envs[i].env_id;
  802174:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  80217a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80217f:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  802185:	eb 0f                	jmp    802196 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802187:	83 c0 01             	add    $0x1,%eax
  80218a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80218f:	75 cd                	jne    80215e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802191:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802196:	5d                   	pop    %ebp
  802197:	c3                   	ret    

00802198 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802198:	55                   	push   %ebp
  802199:	89 e5                	mov    %esp,%ebp
  80219b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80219e:	89 d0                	mov    %edx,%eax
  8021a0:	c1 e8 16             	shr    $0x16,%eax
  8021a3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021aa:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021af:	f6 c1 01             	test   $0x1,%cl
  8021b2:	74 1d                	je     8021d1 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021b4:	c1 ea 0c             	shr    $0xc,%edx
  8021b7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021be:	f6 c2 01             	test   $0x1,%dl
  8021c1:	74 0e                	je     8021d1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021c3:	c1 ea 0c             	shr    $0xc,%edx
  8021c6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021cd:	ef 
  8021ce:	0f b7 c0             	movzwl %ax,%eax
}
  8021d1:	5d                   	pop    %ebp
  8021d2:	c3                   	ret    
  8021d3:	66 90                	xchg   %ax,%ax
  8021d5:	66 90                	xchg   %ax,%ax
  8021d7:	66 90                	xchg   %ax,%ax
  8021d9:	66 90                	xchg   %ax,%ax
  8021db:	66 90                	xchg   %ax,%ax
  8021dd:	66 90                	xchg   %ax,%ax
  8021df:	90                   	nop

008021e0 <__udivdi3>:
  8021e0:	55                   	push   %ebp
  8021e1:	57                   	push   %edi
  8021e2:	56                   	push   %esi
  8021e3:	53                   	push   %ebx
  8021e4:	83 ec 1c             	sub    $0x1c,%esp
  8021e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8021eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8021f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021f7:	85 f6                	test   %esi,%esi
  8021f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021fd:	89 ca                	mov    %ecx,%edx
  8021ff:	89 f8                	mov    %edi,%eax
  802201:	75 3d                	jne    802240 <__udivdi3+0x60>
  802203:	39 cf                	cmp    %ecx,%edi
  802205:	0f 87 c5 00 00 00    	ja     8022d0 <__udivdi3+0xf0>
  80220b:	85 ff                	test   %edi,%edi
  80220d:	89 fd                	mov    %edi,%ebp
  80220f:	75 0b                	jne    80221c <__udivdi3+0x3c>
  802211:	b8 01 00 00 00       	mov    $0x1,%eax
  802216:	31 d2                	xor    %edx,%edx
  802218:	f7 f7                	div    %edi
  80221a:	89 c5                	mov    %eax,%ebp
  80221c:	89 c8                	mov    %ecx,%eax
  80221e:	31 d2                	xor    %edx,%edx
  802220:	f7 f5                	div    %ebp
  802222:	89 c1                	mov    %eax,%ecx
  802224:	89 d8                	mov    %ebx,%eax
  802226:	89 cf                	mov    %ecx,%edi
  802228:	f7 f5                	div    %ebp
  80222a:	89 c3                	mov    %eax,%ebx
  80222c:	89 d8                	mov    %ebx,%eax
  80222e:	89 fa                	mov    %edi,%edx
  802230:	83 c4 1c             	add    $0x1c,%esp
  802233:	5b                   	pop    %ebx
  802234:	5e                   	pop    %esi
  802235:	5f                   	pop    %edi
  802236:	5d                   	pop    %ebp
  802237:	c3                   	ret    
  802238:	90                   	nop
  802239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802240:	39 ce                	cmp    %ecx,%esi
  802242:	77 74                	ja     8022b8 <__udivdi3+0xd8>
  802244:	0f bd fe             	bsr    %esi,%edi
  802247:	83 f7 1f             	xor    $0x1f,%edi
  80224a:	0f 84 98 00 00 00    	je     8022e8 <__udivdi3+0x108>
  802250:	bb 20 00 00 00       	mov    $0x20,%ebx
  802255:	89 f9                	mov    %edi,%ecx
  802257:	89 c5                	mov    %eax,%ebp
  802259:	29 fb                	sub    %edi,%ebx
  80225b:	d3 e6                	shl    %cl,%esi
  80225d:	89 d9                	mov    %ebx,%ecx
  80225f:	d3 ed                	shr    %cl,%ebp
  802261:	89 f9                	mov    %edi,%ecx
  802263:	d3 e0                	shl    %cl,%eax
  802265:	09 ee                	or     %ebp,%esi
  802267:	89 d9                	mov    %ebx,%ecx
  802269:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80226d:	89 d5                	mov    %edx,%ebp
  80226f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802273:	d3 ed                	shr    %cl,%ebp
  802275:	89 f9                	mov    %edi,%ecx
  802277:	d3 e2                	shl    %cl,%edx
  802279:	89 d9                	mov    %ebx,%ecx
  80227b:	d3 e8                	shr    %cl,%eax
  80227d:	09 c2                	or     %eax,%edx
  80227f:	89 d0                	mov    %edx,%eax
  802281:	89 ea                	mov    %ebp,%edx
  802283:	f7 f6                	div    %esi
  802285:	89 d5                	mov    %edx,%ebp
  802287:	89 c3                	mov    %eax,%ebx
  802289:	f7 64 24 0c          	mull   0xc(%esp)
  80228d:	39 d5                	cmp    %edx,%ebp
  80228f:	72 10                	jb     8022a1 <__udivdi3+0xc1>
  802291:	8b 74 24 08          	mov    0x8(%esp),%esi
  802295:	89 f9                	mov    %edi,%ecx
  802297:	d3 e6                	shl    %cl,%esi
  802299:	39 c6                	cmp    %eax,%esi
  80229b:	73 07                	jae    8022a4 <__udivdi3+0xc4>
  80229d:	39 d5                	cmp    %edx,%ebp
  80229f:	75 03                	jne    8022a4 <__udivdi3+0xc4>
  8022a1:	83 eb 01             	sub    $0x1,%ebx
  8022a4:	31 ff                	xor    %edi,%edi
  8022a6:	89 d8                	mov    %ebx,%eax
  8022a8:	89 fa                	mov    %edi,%edx
  8022aa:	83 c4 1c             	add    $0x1c,%esp
  8022ad:	5b                   	pop    %ebx
  8022ae:	5e                   	pop    %esi
  8022af:	5f                   	pop    %edi
  8022b0:	5d                   	pop    %ebp
  8022b1:	c3                   	ret    
  8022b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022b8:	31 ff                	xor    %edi,%edi
  8022ba:	31 db                	xor    %ebx,%ebx
  8022bc:	89 d8                	mov    %ebx,%eax
  8022be:	89 fa                	mov    %edi,%edx
  8022c0:	83 c4 1c             	add    $0x1c,%esp
  8022c3:	5b                   	pop    %ebx
  8022c4:	5e                   	pop    %esi
  8022c5:	5f                   	pop    %edi
  8022c6:	5d                   	pop    %ebp
  8022c7:	c3                   	ret    
  8022c8:	90                   	nop
  8022c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	89 d8                	mov    %ebx,%eax
  8022d2:	f7 f7                	div    %edi
  8022d4:	31 ff                	xor    %edi,%edi
  8022d6:	89 c3                	mov    %eax,%ebx
  8022d8:	89 d8                	mov    %ebx,%eax
  8022da:	89 fa                	mov    %edi,%edx
  8022dc:	83 c4 1c             	add    $0x1c,%esp
  8022df:	5b                   	pop    %ebx
  8022e0:	5e                   	pop    %esi
  8022e1:	5f                   	pop    %edi
  8022e2:	5d                   	pop    %ebp
  8022e3:	c3                   	ret    
  8022e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022e8:	39 ce                	cmp    %ecx,%esi
  8022ea:	72 0c                	jb     8022f8 <__udivdi3+0x118>
  8022ec:	31 db                	xor    %ebx,%ebx
  8022ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8022f2:	0f 87 34 ff ff ff    	ja     80222c <__udivdi3+0x4c>
  8022f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8022fd:	e9 2a ff ff ff       	jmp    80222c <__udivdi3+0x4c>
  802302:	66 90                	xchg   %ax,%ax
  802304:	66 90                	xchg   %ax,%ax
  802306:	66 90                	xchg   %ax,%ax
  802308:	66 90                	xchg   %ax,%ax
  80230a:	66 90                	xchg   %ax,%ax
  80230c:	66 90                	xchg   %ax,%ax
  80230e:	66 90                	xchg   %ax,%ax

00802310 <__umoddi3>:
  802310:	55                   	push   %ebp
  802311:	57                   	push   %edi
  802312:	56                   	push   %esi
  802313:	53                   	push   %ebx
  802314:	83 ec 1c             	sub    $0x1c,%esp
  802317:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80231b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80231f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802323:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802327:	85 d2                	test   %edx,%edx
  802329:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80232d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802331:	89 f3                	mov    %esi,%ebx
  802333:	89 3c 24             	mov    %edi,(%esp)
  802336:	89 74 24 04          	mov    %esi,0x4(%esp)
  80233a:	75 1c                	jne    802358 <__umoddi3+0x48>
  80233c:	39 f7                	cmp    %esi,%edi
  80233e:	76 50                	jbe    802390 <__umoddi3+0x80>
  802340:	89 c8                	mov    %ecx,%eax
  802342:	89 f2                	mov    %esi,%edx
  802344:	f7 f7                	div    %edi
  802346:	89 d0                	mov    %edx,%eax
  802348:	31 d2                	xor    %edx,%edx
  80234a:	83 c4 1c             	add    $0x1c,%esp
  80234d:	5b                   	pop    %ebx
  80234e:	5e                   	pop    %esi
  80234f:	5f                   	pop    %edi
  802350:	5d                   	pop    %ebp
  802351:	c3                   	ret    
  802352:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802358:	39 f2                	cmp    %esi,%edx
  80235a:	89 d0                	mov    %edx,%eax
  80235c:	77 52                	ja     8023b0 <__umoddi3+0xa0>
  80235e:	0f bd ea             	bsr    %edx,%ebp
  802361:	83 f5 1f             	xor    $0x1f,%ebp
  802364:	75 5a                	jne    8023c0 <__umoddi3+0xb0>
  802366:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80236a:	0f 82 e0 00 00 00    	jb     802450 <__umoddi3+0x140>
  802370:	39 0c 24             	cmp    %ecx,(%esp)
  802373:	0f 86 d7 00 00 00    	jbe    802450 <__umoddi3+0x140>
  802379:	8b 44 24 08          	mov    0x8(%esp),%eax
  80237d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802381:	83 c4 1c             	add    $0x1c,%esp
  802384:	5b                   	pop    %ebx
  802385:	5e                   	pop    %esi
  802386:	5f                   	pop    %edi
  802387:	5d                   	pop    %ebp
  802388:	c3                   	ret    
  802389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802390:	85 ff                	test   %edi,%edi
  802392:	89 fd                	mov    %edi,%ebp
  802394:	75 0b                	jne    8023a1 <__umoddi3+0x91>
  802396:	b8 01 00 00 00       	mov    $0x1,%eax
  80239b:	31 d2                	xor    %edx,%edx
  80239d:	f7 f7                	div    %edi
  80239f:	89 c5                	mov    %eax,%ebp
  8023a1:	89 f0                	mov    %esi,%eax
  8023a3:	31 d2                	xor    %edx,%edx
  8023a5:	f7 f5                	div    %ebp
  8023a7:	89 c8                	mov    %ecx,%eax
  8023a9:	f7 f5                	div    %ebp
  8023ab:	89 d0                	mov    %edx,%eax
  8023ad:	eb 99                	jmp    802348 <__umoddi3+0x38>
  8023af:	90                   	nop
  8023b0:	89 c8                	mov    %ecx,%eax
  8023b2:	89 f2                	mov    %esi,%edx
  8023b4:	83 c4 1c             	add    $0x1c,%esp
  8023b7:	5b                   	pop    %ebx
  8023b8:	5e                   	pop    %esi
  8023b9:	5f                   	pop    %edi
  8023ba:	5d                   	pop    %ebp
  8023bb:	c3                   	ret    
  8023bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023c0:	8b 34 24             	mov    (%esp),%esi
  8023c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023c8:	89 e9                	mov    %ebp,%ecx
  8023ca:	29 ef                	sub    %ebp,%edi
  8023cc:	d3 e0                	shl    %cl,%eax
  8023ce:	89 f9                	mov    %edi,%ecx
  8023d0:	89 f2                	mov    %esi,%edx
  8023d2:	d3 ea                	shr    %cl,%edx
  8023d4:	89 e9                	mov    %ebp,%ecx
  8023d6:	09 c2                	or     %eax,%edx
  8023d8:	89 d8                	mov    %ebx,%eax
  8023da:	89 14 24             	mov    %edx,(%esp)
  8023dd:	89 f2                	mov    %esi,%edx
  8023df:	d3 e2                	shl    %cl,%edx
  8023e1:	89 f9                	mov    %edi,%ecx
  8023e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8023eb:	d3 e8                	shr    %cl,%eax
  8023ed:	89 e9                	mov    %ebp,%ecx
  8023ef:	89 c6                	mov    %eax,%esi
  8023f1:	d3 e3                	shl    %cl,%ebx
  8023f3:	89 f9                	mov    %edi,%ecx
  8023f5:	89 d0                	mov    %edx,%eax
  8023f7:	d3 e8                	shr    %cl,%eax
  8023f9:	89 e9                	mov    %ebp,%ecx
  8023fb:	09 d8                	or     %ebx,%eax
  8023fd:	89 d3                	mov    %edx,%ebx
  8023ff:	89 f2                	mov    %esi,%edx
  802401:	f7 34 24             	divl   (%esp)
  802404:	89 d6                	mov    %edx,%esi
  802406:	d3 e3                	shl    %cl,%ebx
  802408:	f7 64 24 04          	mull   0x4(%esp)
  80240c:	39 d6                	cmp    %edx,%esi
  80240e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802412:	89 d1                	mov    %edx,%ecx
  802414:	89 c3                	mov    %eax,%ebx
  802416:	72 08                	jb     802420 <__umoddi3+0x110>
  802418:	75 11                	jne    80242b <__umoddi3+0x11b>
  80241a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80241e:	73 0b                	jae    80242b <__umoddi3+0x11b>
  802420:	2b 44 24 04          	sub    0x4(%esp),%eax
  802424:	1b 14 24             	sbb    (%esp),%edx
  802427:	89 d1                	mov    %edx,%ecx
  802429:	89 c3                	mov    %eax,%ebx
  80242b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80242f:	29 da                	sub    %ebx,%edx
  802431:	19 ce                	sbb    %ecx,%esi
  802433:	89 f9                	mov    %edi,%ecx
  802435:	89 f0                	mov    %esi,%eax
  802437:	d3 e0                	shl    %cl,%eax
  802439:	89 e9                	mov    %ebp,%ecx
  80243b:	d3 ea                	shr    %cl,%edx
  80243d:	89 e9                	mov    %ebp,%ecx
  80243f:	d3 ee                	shr    %cl,%esi
  802441:	09 d0                	or     %edx,%eax
  802443:	89 f2                	mov    %esi,%edx
  802445:	83 c4 1c             	add    $0x1c,%esp
  802448:	5b                   	pop    %ebx
  802449:	5e                   	pop    %esi
  80244a:	5f                   	pop    %edi
  80244b:	5d                   	pop    %ebp
  80244c:	c3                   	ret    
  80244d:	8d 76 00             	lea    0x0(%esi),%esi
  802450:	29 f9                	sub    %edi,%ecx
  802452:	19 d6                	sbb    %edx,%esi
  802454:	89 74 24 04          	mov    %esi,0x4(%esp)
  802458:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80245c:	e9 18 ff ff ff       	jmp    802379 <__umoddi3+0x69>
