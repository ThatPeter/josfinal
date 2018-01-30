
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
  800040:	68 00 25 80 00       	push   $0x802500
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
  80006a:	68 20 25 80 00       	push   $0x802520
  80006f:	6a 0f                	push   $0xf
  800071:	68 0a 25 80 00       	push   $0x80250a
  800076:	e8 bd 00 00 00       	call   800138 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 4c 25 80 00       	push   $0x80254c
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
  8000ca:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8000d0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d5:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

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

void 
thread_main(/*uintptr_t eip*/)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

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
  800124:	e8 9a 14 00 00       	call   8015c3 <close_all>
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
  800156:	68 78 25 80 00       	push   $0x802578
  80015b:	e8 b1 00 00 00       	call   800211 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800160:	83 c4 18             	add    $0x18,%esp
  800163:	53                   	push   %ebx
  800164:	ff 75 10             	pushl  0x10(%ebp)
  800167:	e8 54 00 00 00       	call   8001c0 <vcprintf>
	cprintf("\n");
  80016c:	c7 04 24 74 29 80 00 	movl   $0x802974,(%esp)
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
  800274:	e8 e7 1f 00 00       	call   802260 <__udivdi3>
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
  8002b7:	e8 d4 20 00 00       	call   802390 <__umoddi3>
  8002bc:	83 c4 14             	add    $0x14,%esp
  8002bf:	0f be 80 9b 25 80 00 	movsbl 0x80259b(%eax),%eax
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
  8003bb:	ff 24 85 e0 26 80 00 	jmp    *0x8026e0(,%eax,4)
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
  80047f:	8b 14 85 40 28 80 00 	mov    0x802840(,%eax,4),%edx
  800486:	85 d2                	test   %edx,%edx
  800488:	75 18                	jne    8004a2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80048a:	50                   	push   %eax
  80048b:	68 b3 25 80 00       	push   $0x8025b3
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
  8004a3:	68 e1 2a 80 00       	push   $0x802ae1
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
  8004c7:	b8 ac 25 80 00       	mov    $0x8025ac,%eax
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
  800b42:	68 9f 28 80 00       	push   $0x80289f
  800b47:	6a 23                	push   $0x23
  800b49:	68 bc 28 80 00       	push   $0x8028bc
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
  800bc3:	68 9f 28 80 00       	push   $0x80289f
  800bc8:	6a 23                	push   $0x23
  800bca:	68 bc 28 80 00       	push   $0x8028bc
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
  800c05:	68 9f 28 80 00       	push   $0x80289f
  800c0a:	6a 23                	push   $0x23
  800c0c:	68 bc 28 80 00       	push   $0x8028bc
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
  800c47:	68 9f 28 80 00       	push   $0x80289f
  800c4c:	6a 23                	push   $0x23
  800c4e:	68 bc 28 80 00       	push   $0x8028bc
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
  800c89:	68 9f 28 80 00       	push   $0x80289f
  800c8e:	6a 23                	push   $0x23
  800c90:	68 bc 28 80 00       	push   $0x8028bc
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
  800ccb:	68 9f 28 80 00       	push   $0x80289f
  800cd0:	6a 23                	push   $0x23
  800cd2:	68 bc 28 80 00       	push   $0x8028bc
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
  800d0d:	68 9f 28 80 00       	push   $0x80289f
  800d12:	6a 23                	push   $0x23
  800d14:	68 bc 28 80 00       	push   $0x8028bc
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
  800d71:	68 9f 28 80 00       	push   $0x80289f
  800d76:	6a 23                	push   $0x23
  800d78:	68 bc 28 80 00       	push   $0x8028bc
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
  800e12:	68 a6 29 80 00       	push   $0x8029a6
  800e17:	6a 23                	push   $0x23
  800e19:	68 ca 28 80 00       	push   $0x8028ca
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
  800e42:	68 a6 29 80 00       	push   $0x8029a6
  800e47:	6a 2c                	push   $0x2c
  800e49:	68 ca 28 80 00       	push   $0x8028ca
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
  800e9f:	68 d8 28 80 00       	push   $0x8028d8
  800ea4:	6a 1f                	push   $0x1f
  800ea6:	68 e8 28 80 00       	push   $0x8028e8
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
  800ec9:	68 f3 28 80 00       	push   $0x8028f3
  800ece:	6a 2d                	push   $0x2d
  800ed0:	68 e8 28 80 00       	push   $0x8028e8
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
  800f11:	68 f3 28 80 00       	push   $0x8028f3
  800f16:	6a 34                	push   $0x34
  800f18:	68 e8 28 80 00       	push   $0x8028e8
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
  800f39:	68 f3 28 80 00       	push   $0x8028f3
  800f3e:	6a 38                	push   $0x38
  800f40:	68 e8 28 80 00       	push   $0x8028e8
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
  800f76:	68 0c 29 80 00       	push   $0x80290c
  800f7b:	68 85 00 00 00       	push   $0x85
  800f80:	68 e8 28 80 00       	push   $0x8028e8
  800f85:	e8 ae f1 ff ff       	call   800138 <_panic>
  800f8a:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f8c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f90:	75 24                	jne    800fb6 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f92:	e8 c4 fb ff ff       	call   800b5b <sys_getenvid>
  800f97:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f9c:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  801032:	68 1a 29 80 00       	push   $0x80291a
  801037:	6a 55                	push   $0x55
  801039:	68 e8 28 80 00       	push   $0x8028e8
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
  801077:	68 1a 29 80 00       	push   $0x80291a
  80107c:	6a 5c                	push   $0x5c
  80107e:	68 e8 28 80 00       	push   $0x8028e8
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
  8010a5:	68 1a 29 80 00       	push   $0x80291a
  8010aa:	6a 60                	push   $0x60
  8010ac:	68 e8 28 80 00       	push   $0x8028e8
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
  8010cf:	68 1a 29 80 00       	push   $0x80291a
  8010d4:	6a 65                	push   $0x65
  8010d6:	68 e8 28 80 00       	push   $0x8028e8
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
  8010f7:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
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
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80112c:	55                   	push   %ebp
  80112d:	89 e5                	mov    %esp,%ebp
  80112f:	56                   	push   %esi
  801130:	53                   	push   %ebx
  801131:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801134:	89 1d 0c 40 80 00    	mov    %ebx,0x80400c
	cprintf("in fork.c thread create. func: %x\n", func);
  80113a:	83 ec 08             	sub    $0x8,%esp
  80113d:	53                   	push   %ebx
  80113e:	68 ac 29 80 00       	push   $0x8029ac
  801143:	e8 c9 f0 ff ff       	call   800211 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801148:	c7 04 24 fe 00 80 00 	movl   $0x8000fe,(%esp)
  80114f:	e8 36 fc ff ff       	call   800d8a <sys_thread_create>
  801154:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801156:	83 c4 08             	add    $0x8,%esp
  801159:	53                   	push   %ebx
  80115a:	68 ac 29 80 00       	push   $0x8029ac
  80115f:	e8 ad f0 ff ff       	call   800211 <cprintf>
	return id;
}
  801164:	89 f0                	mov    %esi,%eax
  801166:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801169:	5b                   	pop    %ebx
  80116a:	5e                   	pop    %esi
  80116b:	5d                   	pop    %ebp
  80116c:	c3                   	ret    

0080116d <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  80116d:	55                   	push   %ebp
  80116e:	89 e5                	mov    %esp,%ebp
  801170:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  801173:	ff 75 08             	pushl  0x8(%ebp)
  801176:	e8 2f fc ff ff       	call   800daa <sys_thread_free>
}
  80117b:	83 c4 10             	add    $0x10,%esp
  80117e:	c9                   	leave  
  80117f:	c3                   	ret    

00801180 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
  801183:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  801186:	ff 75 08             	pushl  0x8(%ebp)
  801189:	e8 3c fc ff ff       	call   800dca <sys_thread_join>
}
  80118e:	83 c4 10             	add    $0x10,%esp
  801191:	c9                   	leave  
  801192:	c3                   	ret    

00801193 <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  801193:	55                   	push   %ebp
  801194:	89 e5                	mov    %esp,%ebp
  801196:	56                   	push   %esi
  801197:	53                   	push   %ebx
  801198:	8b 75 08             	mov    0x8(%ebp),%esi
  80119b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  80119e:	83 ec 04             	sub    $0x4,%esp
  8011a1:	6a 07                	push   $0x7
  8011a3:	6a 00                	push   $0x0
  8011a5:	56                   	push   %esi
  8011a6:	e8 ee f9 ff ff       	call   800b99 <sys_page_alloc>
	if (r < 0) {
  8011ab:	83 c4 10             	add    $0x10,%esp
  8011ae:	85 c0                	test   %eax,%eax
  8011b0:	79 15                	jns    8011c7 <queue_append+0x34>
		panic("%e\n", r);
  8011b2:	50                   	push   %eax
  8011b3:	68 a6 29 80 00       	push   $0x8029a6
  8011b8:	68 c4 00 00 00       	push   $0xc4
  8011bd:	68 e8 28 80 00       	push   $0x8028e8
  8011c2:	e8 71 ef ff ff       	call   800138 <_panic>
	}	
	wt->envid = envid;
  8011c7:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  8011cd:	83 ec 04             	sub    $0x4,%esp
  8011d0:	ff 33                	pushl  (%ebx)
  8011d2:	56                   	push   %esi
  8011d3:	68 d0 29 80 00       	push   $0x8029d0
  8011d8:	e8 34 f0 ff ff       	call   800211 <cprintf>
	if (queue->first == NULL) {
  8011dd:	83 c4 10             	add    $0x10,%esp
  8011e0:	83 3b 00             	cmpl   $0x0,(%ebx)
  8011e3:	75 29                	jne    80120e <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  8011e5:	83 ec 0c             	sub    $0xc,%esp
  8011e8:	68 30 29 80 00       	push   $0x802930
  8011ed:	e8 1f f0 ff ff       	call   800211 <cprintf>
		queue->first = wt;
  8011f2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  8011f8:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  8011ff:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801206:	00 00 00 
  801209:	83 c4 10             	add    $0x10,%esp
  80120c:	eb 2b                	jmp    801239 <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  80120e:	83 ec 0c             	sub    $0xc,%esp
  801211:	68 4a 29 80 00       	push   $0x80294a
  801216:	e8 f6 ef ff ff       	call   800211 <cprintf>
		queue->last->next = wt;
  80121b:	8b 43 04             	mov    0x4(%ebx),%eax
  80121e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  801225:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80122c:	00 00 00 
		queue->last = wt;
  80122f:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  801236:	83 c4 10             	add    $0x10,%esp
	}
}
  801239:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80123c:	5b                   	pop    %ebx
  80123d:	5e                   	pop    %esi
  80123e:	5d                   	pop    %ebp
  80123f:	c3                   	ret    

00801240 <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	53                   	push   %ebx
  801244:	83 ec 04             	sub    $0x4,%esp
  801247:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  80124a:	8b 02                	mov    (%edx),%eax
  80124c:	85 c0                	test   %eax,%eax
  80124e:	75 17                	jne    801267 <queue_pop+0x27>
		panic("queue empty!\n");
  801250:	83 ec 04             	sub    $0x4,%esp
  801253:	68 68 29 80 00       	push   $0x802968
  801258:	68 d8 00 00 00       	push   $0xd8
  80125d:	68 e8 28 80 00       	push   $0x8028e8
  801262:	e8 d1 ee ff ff       	call   800138 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  801267:	8b 48 04             	mov    0x4(%eax),%ecx
  80126a:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  80126c:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  80126e:	83 ec 08             	sub    $0x8,%esp
  801271:	53                   	push   %ebx
  801272:	68 76 29 80 00       	push   $0x802976
  801277:	e8 95 ef ff ff       	call   800211 <cprintf>
	return envid;
}
  80127c:	89 d8                	mov    %ebx,%eax
  80127e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801281:	c9                   	leave  
  801282:	c3                   	ret    

00801283 <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  801283:	55                   	push   %ebp
  801284:	89 e5                	mov    %esp,%ebp
  801286:	53                   	push   %ebx
  801287:	83 ec 04             	sub    $0x4,%esp
  80128a:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  80128d:	b8 01 00 00 00       	mov    $0x1,%eax
  801292:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801295:	85 c0                	test   %eax,%eax
  801297:	74 5a                	je     8012f3 <mutex_lock+0x70>
  801299:	8b 43 04             	mov    0x4(%ebx),%eax
  80129c:	83 38 00             	cmpl   $0x0,(%eax)
  80129f:	75 52                	jne    8012f3 <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  8012a1:	83 ec 0c             	sub    $0xc,%esp
  8012a4:	68 f8 29 80 00       	push   $0x8029f8
  8012a9:	e8 63 ef ff ff       	call   800211 <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  8012ae:	8b 5b 04             	mov    0x4(%ebx),%ebx
  8012b1:	e8 a5 f8 ff ff       	call   800b5b <sys_getenvid>
  8012b6:	83 c4 08             	add    $0x8,%esp
  8012b9:	53                   	push   %ebx
  8012ba:	50                   	push   %eax
  8012bb:	e8 d3 fe ff ff       	call   801193 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  8012c0:	e8 96 f8 ff ff       	call   800b5b <sys_getenvid>
  8012c5:	83 c4 08             	add    $0x8,%esp
  8012c8:	6a 04                	push   $0x4
  8012ca:	50                   	push   %eax
  8012cb:	e8 90 f9 ff ff       	call   800c60 <sys_env_set_status>
		if (r < 0) {
  8012d0:	83 c4 10             	add    $0x10,%esp
  8012d3:	85 c0                	test   %eax,%eax
  8012d5:	79 15                	jns    8012ec <mutex_lock+0x69>
			panic("%e\n", r);
  8012d7:	50                   	push   %eax
  8012d8:	68 a6 29 80 00       	push   $0x8029a6
  8012dd:	68 eb 00 00 00       	push   $0xeb
  8012e2:	68 e8 28 80 00       	push   $0x8028e8
  8012e7:	e8 4c ee ff ff       	call   800138 <_panic>
		}
		sys_yield();
  8012ec:	e8 89 f8 ff ff       	call   800b7a <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8012f1:	eb 18                	jmp    80130b <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  8012f3:	83 ec 0c             	sub    $0xc,%esp
  8012f6:	68 18 2a 80 00       	push   $0x802a18
  8012fb:	e8 11 ef ff ff       	call   800211 <cprintf>
	mtx->owner = sys_getenvid();}
  801300:	e8 56 f8 ff ff       	call   800b5b <sys_getenvid>
  801305:	89 43 08             	mov    %eax,0x8(%ebx)
  801308:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  80130b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80130e:	c9                   	leave  
  80130f:	c3                   	ret    

00801310 <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  801310:	55                   	push   %ebp
  801311:	89 e5                	mov    %esp,%ebp
  801313:	53                   	push   %ebx
  801314:	83 ec 04             	sub    $0x4,%esp
  801317:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80131a:	b8 00 00 00 00       	mov    $0x0,%eax
  80131f:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  801322:	8b 43 04             	mov    0x4(%ebx),%eax
  801325:	83 38 00             	cmpl   $0x0,(%eax)
  801328:	74 33                	je     80135d <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  80132a:	83 ec 0c             	sub    $0xc,%esp
  80132d:	50                   	push   %eax
  80132e:	e8 0d ff ff ff       	call   801240 <queue_pop>
  801333:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  801336:	83 c4 08             	add    $0x8,%esp
  801339:	6a 02                	push   $0x2
  80133b:	50                   	push   %eax
  80133c:	e8 1f f9 ff ff       	call   800c60 <sys_env_set_status>
		if (r < 0) {
  801341:	83 c4 10             	add    $0x10,%esp
  801344:	85 c0                	test   %eax,%eax
  801346:	79 15                	jns    80135d <mutex_unlock+0x4d>
			panic("%e\n", r);
  801348:	50                   	push   %eax
  801349:	68 a6 29 80 00       	push   $0x8029a6
  80134e:	68 00 01 00 00       	push   $0x100
  801353:	68 e8 28 80 00       	push   $0x8028e8
  801358:	e8 db ed ff ff       	call   800138 <_panic>
		}
	}

	asm volatile("pause");
  80135d:	f3 90                	pause  
	//sys_yield();
}
  80135f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801362:	c9                   	leave  
  801363:	c3                   	ret    

00801364 <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  801364:	55                   	push   %ebp
  801365:	89 e5                	mov    %esp,%ebp
  801367:	53                   	push   %ebx
  801368:	83 ec 04             	sub    $0x4,%esp
  80136b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  80136e:	e8 e8 f7 ff ff       	call   800b5b <sys_getenvid>
  801373:	83 ec 04             	sub    $0x4,%esp
  801376:	6a 07                	push   $0x7
  801378:	53                   	push   %ebx
  801379:	50                   	push   %eax
  80137a:	e8 1a f8 ff ff       	call   800b99 <sys_page_alloc>
  80137f:	83 c4 10             	add    $0x10,%esp
  801382:	85 c0                	test   %eax,%eax
  801384:	79 15                	jns    80139b <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  801386:	50                   	push   %eax
  801387:	68 91 29 80 00       	push   $0x802991
  80138c:	68 0d 01 00 00       	push   $0x10d
  801391:	68 e8 28 80 00       	push   $0x8028e8
  801396:	e8 9d ed ff ff       	call   800138 <_panic>
	}	
	mtx->locked = 0;
  80139b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  8013a1:	8b 43 04             	mov    0x4(%ebx),%eax
  8013a4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  8013aa:	8b 43 04             	mov    0x4(%ebx),%eax
  8013ad:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  8013b4:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  8013bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013be:	c9                   	leave  
  8013bf:	c3                   	ret    

008013c0 <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  8013c0:	55                   	push   %ebp
  8013c1:	89 e5                	mov    %esp,%ebp
  8013c3:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  8013c6:	e8 90 f7 ff ff       	call   800b5b <sys_getenvid>
  8013cb:	83 ec 08             	sub    $0x8,%esp
  8013ce:	ff 75 08             	pushl  0x8(%ebp)
  8013d1:	50                   	push   %eax
  8013d2:	e8 47 f8 ff ff       	call   800c1e <sys_page_unmap>
	if (r < 0) {
  8013d7:	83 c4 10             	add    $0x10,%esp
  8013da:	85 c0                	test   %eax,%eax
  8013dc:	79 15                	jns    8013f3 <mutex_destroy+0x33>
		panic("%e\n", r);
  8013de:	50                   	push   %eax
  8013df:	68 a6 29 80 00       	push   $0x8029a6
  8013e4:	68 1a 01 00 00       	push   $0x11a
  8013e9:	68 e8 28 80 00       	push   $0x8028e8
  8013ee:	e8 45 ed ff ff       	call   800138 <_panic>
	}
}
  8013f3:	c9                   	leave  
  8013f4:	c3                   	ret    

008013f5 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013f5:	55                   	push   %ebp
  8013f6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fb:	05 00 00 00 30       	add    $0x30000000,%eax
  801400:	c1 e8 0c             	shr    $0xc,%eax
}
  801403:	5d                   	pop    %ebp
  801404:	c3                   	ret    

00801405 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801405:	55                   	push   %ebp
  801406:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801408:	8b 45 08             	mov    0x8(%ebp),%eax
  80140b:	05 00 00 00 30       	add    $0x30000000,%eax
  801410:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801415:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80141a:	5d                   	pop    %ebp
  80141b:	c3                   	ret    

0080141c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80141c:	55                   	push   %ebp
  80141d:	89 e5                	mov    %esp,%ebp
  80141f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801422:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801427:	89 c2                	mov    %eax,%edx
  801429:	c1 ea 16             	shr    $0x16,%edx
  80142c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801433:	f6 c2 01             	test   $0x1,%dl
  801436:	74 11                	je     801449 <fd_alloc+0x2d>
  801438:	89 c2                	mov    %eax,%edx
  80143a:	c1 ea 0c             	shr    $0xc,%edx
  80143d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801444:	f6 c2 01             	test   $0x1,%dl
  801447:	75 09                	jne    801452 <fd_alloc+0x36>
			*fd_store = fd;
  801449:	89 01                	mov    %eax,(%ecx)
			return 0;
  80144b:	b8 00 00 00 00       	mov    $0x0,%eax
  801450:	eb 17                	jmp    801469 <fd_alloc+0x4d>
  801452:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801457:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80145c:	75 c9                	jne    801427 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80145e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801464:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801469:	5d                   	pop    %ebp
  80146a:	c3                   	ret    

0080146b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80146b:	55                   	push   %ebp
  80146c:	89 e5                	mov    %esp,%ebp
  80146e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801471:	83 f8 1f             	cmp    $0x1f,%eax
  801474:	77 36                	ja     8014ac <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801476:	c1 e0 0c             	shl    $0xc,%eax
  801479:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80147e:	89 c2                	mov    %eax,%edx
  801480:	c1 ea 16             	shr    $0x16,%edx
  801483:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80148a:	f6 c2 01             	test   $0x1,%dl
  80148d:	74 24                	je     8014b3 <fd_lookup+0x48>
  80148f:	89 c2                	mov    %eax,%edx
  801491:	c1 ea 0c             	shr    $0xc,%edx
  801494:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80149b:	f6 c2 01             	test   $0x1,%dl
  80149e:	74 1a                	je     8014ba <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014a3:	89 02                	mov    %eax,(%edx)
	return 0;
  8014a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8014aa:	eb 13                	jmp    8014bf <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014b1:	eb 0c                	jmp    8014bf <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014b8:	eb 05                	jmp    8014bf <fd_lookup+0x54>
  8014ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014bf:	5d                   	pop    %ebp
  8014c0:	c3                   	ret    

008014c1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014c1:	55                   	push   %ebp
  8014c2:	89 e5                	mov    %esp,%ebp
  8014c4:	83 ec 08             	sub    $0x8,%esp
  8014c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014ca:	ba b8 2a 80 00       	mov    $0x802ab8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014cf:	eb 13                	jmp    8014e4 <dev_lookup+0x23>
  8014d1:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8014d4:	39 08                	cmp    %ecx,(%eax)
  8014d6:	75 0c                	jne    8014e4 <dev_lookup+0x23>
			*dev = devtab[i];
  8014d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014db:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8014e2:	eb 31                	jmp    801515 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014e4:	8b 02                	mov    (%edx),%eax
  8014e6:	85 c0                	test   %eax,%eax
  8014e8:	75 e7                	jne    8014d1 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014ea:	a1 04 40 80 00       	mov    0x804004,%eax
  8014ef:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8014f5:	83 ec 04             	sub    $0x4,%esp
  8014f8:	51                   	push   %ecx
  8014f9:	50                   	push   %eax
  8014fa:	68 38 2a 80 00       	push   $0x802a38
  8014ff:	e8 0d ed ff ff       	call   800211 <cprintf>
	*dev = 0;
  801504:	8b 45 0c             	mov    0xc(%ebp),%eax
  801507:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80150d:	83 c4 10             	add    $0x10,%esp
  801510:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801515:	c9                   	leave  
  801516:	c3                   	ret    

00801517 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801517:	55                   	push   %ebp
  801518:	89 e5                	mov    %esp,%ebp
  80151a:	56                   	push   %esi
  80151b:	53                   	push   %ebx
  80151c:	83 ec 10             	sub    $0x10,%esp
  80151f:	8b 75 08             	mov    0x8(%ebp),%esi
  801522:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801525:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801528:	50                   	push   %eax
  801529:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80152f:	c1 e8 0c             	shr    $0xc,%eax
  801532:	50                   	push   %eax
  801533:	e8 33 ff ff ff       	call   80146b <fd_lookup>
  801538:	83 c4 08             	add    $0x8,%esp
  80153b:	85 c0                	test   %eax,%eax
  80153d:	78 05                	js     801544 <fd_close+0x2d>
	    || fd != fd2)
  80153f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801542:	74 0c                	je     801550 <fd_close+0x39>
		return (must_exist ? r : 0);
  801544:	84 db                	test   %bl,%bl
  801546:	ba 00 00 00 00       	mov    $0x0,%edx
  80154b:	0f 44 c2             	cmove  %edx,%eax
  80154e:	eb 41                	jmp    801591 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801550:	83 ec 08             	sub    $0x8,%esp
  801553:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801556:	50                   	push   %eax
  801557:	ff 36                	pushl  (%esi)
  801559:	e8 63 ff ff ff       	call   8014c1 <dev_lookup>
  80155e:	89 c3                	mov    %eax,%ebx
  801560:	83 c4 10             	add    $0x10,%esp
  801563:	85 c0                	test   %eax,%eax
  801565:	78 1a                	js     801581 <fd_close+0x6a>
		if (dev->dev_close)
  801567:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80156d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801572:	85 c0                	test   %eax,%eax
  801574:	74 0b                	je     801581 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801576:	83 ec 0c             	sub    $0xc,%esp
  801579:	56                   	push   %esi
  80157a:	ff d0                	call   *%eax
  80157c:	89 c3                	mov    %eax,%ebx
  80157e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801581:	83 ec 08             	sub    $0x8,%esp
  801584:	56                   	push   %esi
  801585:	6a 00                	push   $0x0
  801587:	e8 92 f6 ff ff       	call   800c1e <sys_page_unmap>
	return r;
  80158c:	83 c4 10             	add    $0x10,%esp
  80158f:	89 d8                	mov    %ebx,%eax
}
  801591:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801594:	5b                   	pop    %ebx
  801595:	5e                   	pop    %esi
  801596:	5d                   	pop    %ebp
  801597:	c3                   	ret    

00801598 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801598:	55                   	push   %ebp
  801599:	89 e5                	mov    %esp,%ebp
  80159b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80159e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a1:	50                   	push   %eax
  8015a2:	ff 75 08             	pushl  0x8(%ebp)
  8015a5:	e8 c1 fe ff ff       	call   80146b <fd_lookup>
  8015aa:	83 c4 08             	add    $0x8,%esp
  8015ad:	85 c0                	test   %eax,%eax
  8015af:	78 10                	js     8015c1 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8015b1:	83 ec 08             	sub    $0x8,%esp
  8015b4:	6a 01                	push   $0x1
  8015b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8015b9:	e8 59 ff ff ff       	call   801517 <fd_close>
  8015be:	83 c4 10             	add    $0x10,%esp
}
  8015c1:	c9                   	leave  
  8015c2:	c3                   	ret    

008015c3 <close_all>:

void
close_all(void)
{
  8015c3:	55                   	push   %ebp
  8015c4:	89 e5                	mov    %esp,%ebp
  8015c6:	53                   	push   %ebx
  8015c7:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015ca:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015cf:	83 ec 0c             	sub    $0xc,%esp
  8015d2:	53                   	push   %ebx
  8015d3:	e8 c0 ff ff ff       	call   801598 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015d8:	83 c3 01             	add    $0x1,%ebx
  8015db:	83 c4 10             	add    $0x10,%esp
  8015de:	83 fb 20             	cmp    $0x20,%ebx
  8015e1:	75 ec                	jne    8015cf <close_all+0xc>
		close(i);
}
  8015e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e6:	c9                   	leave  
  8015e7:	c3                   	ret    

008015e8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015e8:	55                   	push   %ebp
  8015e9:	89 e5                	mov    %esp,%ebp
  8015eb:	57                   	push   %edi
  8015ec:	56                   	push   %esi
  8015ed:	53                   	push   %ebx
  8015ee:	83 ec 2c             	sub    $0x2c,%esp
  8015f1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015f4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015f7:	50                   	push   %eax
  8015f8:	ff 75 08             	pushl  0x8(%ebp)
  8015fb:	e8 6b fe ff ff       	call   80146b <fd_lookup>
  801600:	83 c4 08             	add    $0x8,%esp
  801603:	85 c0                	test   %eax,%eax
  801605:	0f 88 c1 00 00 00    	js     8016cc <dup+0xe4>
		return r;
	close(newfdnum);
  80160b:	83 ec 0c             	sub    $0xc,%esp
  80160e:	56                   	push   %esi
  80160f:	e8 84 ff ff ff       	call   801598 <close>

	newfd = INDEX2FD(newfdnum);
  801614:	89 f3                	mov    %esi,%ebx
  801616:	c1 e3 0c             	shl    $0xc,%ebx
  801619:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80161f:	83 c4 04             	add    $0x4,%esp
  801622:	ff 75 e4             	pushl  -0x1c(%ebp)
  801625:	e8 db fd ff ff       	call   801405 <fd2data>
  80162a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80162c:	89 1c 24             	mov    %ebx,(%esp)
  80162f:	e8 d1 fd ff ff       	call   801405 <fd2data>
  801634:	83 c4 10             	add    $0x10,%esp
  801637:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80163a:	89 f8                	mov    %edi,%eax
  80163c:	c1 e8 16             	shr    $0x16,%eax
  80163f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801646:	a8 01                	test   $0x1,%al
  801648:	74 37                	je     801681 <dup+0x99>
  80164a:	89 f8                	mov    %edi,%eax
  80164c:	c1 e8 0c             	shr    $0xc,%eax
  80164f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801656:	f6 c2 01             	test   $0x1,%dl
  801659:	74 26                	je     801681 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80165b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801662:	83 ec 0c             	sub    $0xc,%esp
  801665:	25 07 0e 00 00       	and    $0xe07,%eax
  80166a:	50                   	push   %eax
  80166b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80166e:	6a 00                	push   $0x0
  801670:	57                   	push   %edi
  801671:	6a 00                	push   $0x0
  801673:	e8 64 f5 ff ff       	call   800bdc <sys_page_map>
  801678:	89 c7                	mov    %eax,%edi
  80167a:	83 c4 20             	add    $0x20,%esp
  80167d:	85 c0                	test   %eax,%eax
  80167f:	78 2e                	js     8016af <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801681:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801684:	89 d0                	mov    %edx,%eax
  801686:	c1 e8 0c             	shr    $0xc,%eax
  801689:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801690:	83 ec 0c             	sub    $0xc,%esp
  801693:	25 07 0e 00 00       	and    $0xe07,%eax
  801698:	50                   	push   %eax
  801699:	53                   	push   %ebx
  80169a:	6a 00                	push   $0x0
  80169c:	52                   	push   %edx
  80169d:	6a 00                	push   $0x0
  80169f:	e8 38 f5 ff ff       	call   800bdc <sys_page_map>
  8016a4:	89 c7                	mov    %eax,%edi
  8016a6:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8016a9:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016ab:	85 ff                	test   %edi,%edi
  8016ad:	79 1d                	jns    8016cc <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016af:	83 ec 08             	sub    $0x8,%esp
  8016b2:	53                   	push   %ebx
  8016b3:	6a 00                	push   $0x0
  8016b5:	e8 64 f5 ff ff       	call   800c1e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016ba:	83 c4 08             	add    $0x8,%esp
  8016bd:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016c0:	6a 00                	push   $0x0
  8016c2:	e8 57 f5 ff ff       	call   800c1e <sys_page_unmap>
	return r;
  8016c7:	83 c4 10             	add    $0x10,%esp
  8016ca:	89 f8                	mov    %edi,%eax
}
  8016cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016cf:	5b                   	pop    %ebx
  8016d0:	5e                   	pop    %esi
  8016d1:	5f                   	pop    %edi
  8016d2:	5d                   	pop    %ebp
  8016d3:	c3                   	ret    

008016d4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016d4:	55                   	push   %ebp
  8016d5:	89 e5                	mov    %esp,%ebp
  8016d7:	53                   	push   %ebx
  8016d8:	83 ec 14             	sub    $0x14,%esp
  8016db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016de:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e1:	50                   	push   %eax
  8016e2:	53                   	push   %ebx
  8016e3:	e8 83 fd ff ff       	call   80146b <fd_lookup>
  8016e8:	83 c4 08             	add    $0x8,%esp
  8016eb:	89 c2                	mov    %eax,%edx
  8016ed:	85 c0                	test   %eax,%eax
  8016ef:	78 70                	js     801761 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f1:	83 ec 08             	sub    $0x8,%esp
  8016f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f7:	50                   	push   %eax
  8016f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016fb:	ff 30                	pushl  (%eax)
  8016fd:	e8 bf fd ff ff       	call   8014c1 <dev_lookup>
  801702:	83 c4 10             	add    $0x10,%esp
  801705:	85 c0                	test   %eax,%eax
  801707:	78 4f                	js     801758 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801709:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80170c:	8b 42 08             	mov    0x8(%edx),%eax
  80170f:	83 e0 03             	and    $0x3,%eax
  801712:	83 f8 01             	cmp    $0x1,%eax
  801715:	75 24                	jne    80173b <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801717:	a1 04 40 80 00       	mov    0x804004,%eax
  80171c:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801722:	83 ec 04             	sub    $0x4,%esp
  801725:	53                   	push   %ebx
  801726:	50                   	push   %eax
  801727:	68 7c 2a 80 00       	push   $0x802a7c
  80172c:	e8 e0 ea ff ff       	call   800211 <cprintf>
		return -E_INVAL;
  801731:	83 c4 10             	add    $0x10,%esp
  801734:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801739:	eb 26                	jmp    801761 <read+0x8d>
	}
	if (!dev->dev_read)
  80173b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80173e:	8b 40 08             	mov    0x8(%eax),%eax
  801741:	85 c0                	test   %eax,%eax
  801743:	74 17                	je     80175c <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801745:	83 ec 04             	sub    $0x4,%esp
  801748:	ff 75 10             	pushl  0x10(%ebp)
  80174b:	ff 75 0c             	pushl  0xc(%ebp)
  80174e:	52                   	push   %edx
  80174f:	ff d0                	call   *%eax
  801751:	89 c2                	mov    %eax,%edx
  801753:	83 c4 10             	add    $0x10,%esp
  801756:	eb 09                	jmp    801761 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801758:	89 c2                	mov    %eax,%edx
  80175a:	eb 05                	jmp    801761 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80175c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801761:	89 d0                	mov    %edx,%eax
  801763:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801766:	c9                   	leave  
  801767:	c3                   	ret    

00801768 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801768:	55                   	push   %ebp
  801769:	89 e5                	mov    %esp,%ebp
  80176b:	57                   	push   %edi
  80176c:	56                   	push   %esi
  80176d:	53                   	push   %ebx
  80176e:	83 ec 0c             	sub    $0xc,%esp
  801771:	8b 7d 08             	mov    0x8(%ebp),%edi
  801774:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801777:	bb 00 00 00 00       	mov    $0x0,%ebx
  80177c:	eb 21                	jmp    80179f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80177e:	83 ec 04             	sub    $0x4,%esp
  801781:	89 f0                	mov    %esi,%eax
  801783:	29 d8                	sub    %ebx,%eax
  801785:	50                   	push   %eax
  801786:	89 d8                	mov    %ebx,%eax
  801788:	03 45 0c             	add    0xc(%ebp),%eax
  80178b:	50                   	push   %eax
  80178c:	57                   	push   %edi
  80178d:	e8 42 ff ff ff       	call   8016d4 <read>
		if (m < 0)
  801792:	83 c4 10             	add    $0x10,%esp
  801795:	85 c0                	test   %eax,%eax
  801797:	78 10                	js     8017a9 <readn+0x41>
			return m;
		if (m == 0)
  801799:	85 c0                	test   %eax,%eax
  80179b:	74 0a                	je     8017a7 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80179d:	01 c3                	add    %eax,%ebx
  80179f:	39 f3                	cmp    %esi,%ebx
  8017a1:	72 db                	jb     80177e <readn+0x16>
  8017a3:	89 d8                	mov    %ebx,%eax
  8017a5:	eb 02                	jmp    8017a9 <readn+0x41>
  8017a7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8017a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017ac:	5b                   	pop    %ebx
  8017ad:	5e                   	pop    %esi
  8017ae:	5f                   	pop    %edi
  8017af:	5d                   	pop    %ebp
  8017b0:	c3                   	ret    

008017b1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017b1:	55                   	push   %ebp
  8017b2:	89 e5                	mov    %esp,%ebp
  8017b4:	53                   	push   %ebx
  8017b5:	83 ec 14             	sub    $0x14,%esp
  8017b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017be:	50                   	push   %eax
  8017bf:	53                   	push   %ebx
  8017c0:	e8 a6 fc ff ff       	call   80146b <fd_lookup>
  8017c5:	83 c4 08             	add    $0x8,%esp
  8017c8:	89 c2                	mov    %eax,%edx
  8017ca:	85 c0                	test   %eax,%eax
  8017cc:	78 6b                	js     801839 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ce:	83 ec 08             	sub    $0x8,%esp
  8017d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d4:	50                   	push   %eax
  8017d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d8:	ff 30                	pushl  (%eax)
  8017da:	e8 e2 fc ff ff       	call   8014c1 <dev_lookup>
  8017df:	83 c4 10             	add    $0x10,%esp
  8017e2:	85 c0                	test   %eax,%eax
  8017e4:	78 4a                	js     801830 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017ed:	75 24                	jne    801813 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017ef:	a1 04 40 80 00       	mov    0x804004,%eax
  8017f4:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8017fa:	83 ec 04             	sub    $0x4,%esp
  8017fd:	53                   	push   %ebx
  8017fe:	50                   	push   %eax
  8017ff:	68 98 2a 80 00       	push   $0x802a98
  801804:	e8 08 ea ff ff       	call   800211 <cprintf>
		return -E_INVAL;
  801809:	83 c4 10             	add    $0x10,%esp
  80180c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801811:	eb 26                	jmp    801839 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801813:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801816:	8b 52 0c             	mov    0xc(%edx),%edx
  801819:	85 d2                	test   %edx,%edx
  80181b:	74 17                	je     801834 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80181d:	83 ec 04             	sub    $0x4,%esp
  801820:	ff 75 10             	pushl  0x10(%ebp)
  801823:	ff 75 0c             	pushl  0xc(%ebp)
  801826:	50                   	push   %eax
  801827:	ff d2                	call   *%edx
  801829:	89 c2                	mov    %eax,%edx
  80182b:	83 c4 10             	add    $0x10,%esp
  80182e:	eb 09                	jmp    801839 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801830:	89 c2                	mov    %eax,%edx
  801832:	eb 05                	jmp    801839 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801834:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801839:	89 d0                	mov    %edx,%eax
  80183b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80183e:	c9                   	leave  
  80183f:	c3                   	ret    

00801840 <seek>:

int
seek(int fdnum, off_t offset)
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801846:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801849:	50                   	push   %eax
  80184a:	ff 75 08             	pushl  0x8(%ebp)
  80184d:	e8 19 fc ff ff       	call   80146b <fd_lookup>
  801852:	83 c4 08             	add    $0x8,%esp
  801855:	85 c0                	test   %eax,%eax
  801857:	78 0e                	js     801867 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801859:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80185c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80185f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801862:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801867:	c9                   	leave  
  801868:	c3                   	ret    

00801869 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801869:	55                   	push   %ebp
  80186a:	89 e5                	mov    %esp,%ebp
  80186c:	53                   	push   %ebx
  80186d:	83 ec 14             	sub    $0x14,%esp
  801870:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801873:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801876:	50                   	push   %eax
  801877:	53                   	push   %ebx
  801878:	e8 ee fb ff ff       	call   80146b <fd_lookup>
  80187d:	83 c4 08             	add    $0x8,%esp
  801880:	89 c2                	mov    %eax,%edx
  801882:	85 c0                	test   %eax,%eax
  801884:	78 68                	js     8018ee <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801886:	83 ec 08             	sub    $0x8,%esp
  801889:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80188c:	50                   	push   %eax
  80188d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801890:	ff 30                	pushl  (%eax)
  801892:	e8 2a fc ff ff       	call   8014c1 <dev_lookup>
  801897:	83 c4 10             	add    $0x10,%esp
  80189a:	85 c0                	test   %eax,%eax
  80189c:	78 47                	js     8018e5 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80189e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018a5:	75 24                	jne    8018cb <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018a7:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018ac:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8018b2:	83 ec 04             	sub    $0x4,%esp
  8018b5:	53                   	push   %ebx
  8018b6:	50                   	push   %eax
  8018b7:	68 58 2a 80 00       	push   $0x802a58
  8018bc:	e8 50 e9 ff ff       	call   800211 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018c1:	83 c4 10             	add    $0x10,%esp
  8018c4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018c9:	eb 23                	jmp    8018ee <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  8018cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ce:	8b 52 18             	mov    0x18(%edx),%edx
  8018d1:	85 d2                	test   %edx,%edx
  8018d3:	74 14                	je     8018e9 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018d5:	83 ec 08             	sub    $0x8,%esp
  8018d8:	ff 75 0c             	pushl  0xc(%ebp)
  8018db:	50                   	push   %eax
  8018dc:	ff d2                	call   *%edx
  8018de:	89 c2                	mov    %eax,%edx
  8018e0:	83 c4 10             	add    $0x10,%esp
  8018e3:	eb 09                	jmp    8018ee <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018e5:	89 c2                	mov    %eax,%edx
  8018e7:	eb 05                	jmp    8018ee <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018e9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8018ee:	89 d0                	mov    %edx,%eax
  8018f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f3:	c9                   	leave  
  8018f4:	c3                   	ret    

008018f5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018f5:	55                   	push   %ebp
  8018f6:	89 e5                	mov    %esp,%ebp
  8018f8:	53                   	push   %ebx
  8018f9:	83 ec 14             	sub    $0x14,%esp
  8018fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801902:	50                   	push   %eax
  801903:	ff 75 08             	pushl  0x8(%ebp)
  801906:	e8 60 fb ff ff       	call   80146b <fd_lookup>
  80190b:	83 c4 08             	add    $0x8,%esp
  80190e:	89 c2                	mov    %eax,%edx
  801910:	85 c0                	test   %eax,%eax
  801912:	78 58                	js     80196c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801914:	83 ec 08             	sub    $0x8,%esp
  801917:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80191a:	50                   	push   %eax
  80191b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80191e:	ff 30                	pushl  (%eax)
  801920:	e8 9c fb ff ff       	call   8014c1 <dev_lookup>
  801925:	83 c4 10             	add    $0x10,%esp
  801928:	85 c0                	test   %eax,%eax
  80192a:	78 37                	js     801963 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80192c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80192f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801933:	74 32                	je     801967 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801935:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801938:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80193f:	00 00 00 
	stat->st_isdir = 0;
  801942:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801949:	00 00 00 
	stat->st_dev = dev;
  80194c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801952:	83 ec 08             	sub    $0x8,%esp
  801955:	53                   	push   %ebx
  801956:	ff 75 f0             	pushl  -0x10(%ebp)
  801959:	ff 50 14             	call   *0x14(%eax)
  80195c:	89 c2                	mov    %eax,%edx
  80195e:	83 c4 10             	add    $0x10,%esp
  801961:	eb 09                	jmp    80196c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801963:	89 c2                	mov    %eax,%edx
  801965:	eb 05                	jmp    80196c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801967:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80196c:	89 d0                	mov    %edx,%eax
  80196e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801971:	c9                   	leave  
  801972:	c3                   	ret    

00801973 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801973:	55                   	push   %ebp
  801974:	89 e5                	mov    %esp,%ebp
  801976:	56                   	push   %esi
  801977:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801978:	83 ec 08             	sub    $0x8,%esp
  80197b:	6a 00                	push   $0x0
  80197d:	ff 75 08             	pushl  0x8(%ebp)
  801980:	e8 e3 01 00 00       	call   801b68 <open>
  801985:	89 c3                	mov    %eax,%ebx
  801987:	83 c4 10             	add    $0x10,%esp
  80198a:	85 c0                	test   %eax,%eax
  80198c:	78 1b                	js     8019a9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80198e:	83 ec 08             	sub    $0x8,%esp
  801991:	ff 75 0c             	pushl  0xc(%ebp)
  801994:	50                   	push   %eax
  801995:	e8 5b ff ff ff       	call   8018f5 <fstat>
  80199a:	89 c6                	mov    %eax,%esi
	close(fd);
  80199c:	89 1c 24             	mov    %ebx,(%esp)
  80199f:	e8 f4 fb ff ff       	call   801598 <close>
	return r;
  8019a4:	83 c4 10             	add    $0x10,%esp
  8019a7:	89 f0                	mov    %esi,%eax
}
  8019a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ac:	5b                   	pop    %ebx
  8019ad:	5e                   	pop    %esi
  8019ae:	5d                   	pop    %ebp
  8019af:	c3                   	ret    

008019b0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019b0:	55                   	push   %ebp
  8019b1:	89 e5                	mov    %esp,%ebp
  8019b3:	56                   	push   %esi
  8019b4:	53                   	push   %ebx
  8019b5:	89 c6                	mov    %eax,%esi
  8019b7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019b9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8019c0:	75 12                	jne    8019d4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019c2:	83 ec 0c             	sub    $0xc,%esp
  8019c5:	6a 01                	push   $0x1
  8019c7:	e8 05 08 00 00       	call   8021d1 <ipc_find_env>
  8019cc:	a3 00 40 80 00       	mov    %eax,0x804000
  8019d1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019d4:	6a 07                	push   $0x7
  8019d6:	68 00 50 80 00       	push   $0x805000
  8019db:	56                   	push   %esi
  8019dc:	ff 35 00 40 80 00    	pushl  0x804000
  8019e2:	e8 88 07 00 00       	call   80216f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019e7:	83 c4 0c             	add    $0xc,%esp
  8019ea:	6a 00                	push   $0x0
  8019ec:	53                   	push   %ebx
  8019ed:	6a 00                	push   $0x0
  8019ef:	e8 00 07 00 00       	call   8020f4 <ipc_recv>
}
  8019f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019f7:	5b                   	pop    %ebx
  8019f8:	5e                   	pop    %esi
  8019f9:	5d                   	pop    %ebp
  8019fa:	c3                   	ret    

008019fb <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019fb:	55                   	push   %ebp
  8019fc:	89 e5                	mov    %esp,%ebp
  8019fe:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a01:	8b 45 08             	mov    0x8(%ebp),%eax
  801a04:	8b 40 0c             	mov    0xc(%eax),%eax
  801a07:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a14:	ba 00 00 00 00       	mov    $0x0,%edx
  801a19:	b8 02 00 00 00       	mov    $0x2,%eax
  801a1e:	e8 8d ff ff ff       	call   8019b0 <fsipc>
}
  801a23:	c9                   	leave  
  801a24:	c3                   	ret    

00801a25 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a25:	55                   	push   %ebp
  801a26:	89 e5                	mov    %esp,%ebp
  801a28:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2e:	8b 40 0c             	mov    0xc(%eax),%eax
  801a31:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a36:	ba 00 00 00 00       	mov    $0x0,%edx
  801a3b:	b8 06 00 00 00       	mov    $0x6,%eax
  801a40:	e8 6b ff ff ff       	call   8019b0 <fsipc>
}
  801a45:	c9                   	leave  
  801a46:	c3                   	ret    

00801a47 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a47:	55                   	push   %ebp
  801a48:	89 e5                	mov    %esp,%ebp
  801a4a:	53                   	push   %ebx
  801a4b:	83 ec 04             	sub    $0x4,%esp
  801a4e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a51:	8b 45 08             	mov    0x8(%ebp),%eax
  801a54:	8b 40 0c             	mov    0xc(%eax),%eax
  801a57:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a5c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a61:	b8 05 00 00 00       	mov    $0x5,%eax
  801a66:	e8 45 ff ff ff       	call   8019b0 <fsipc>
  801a6b:	85 c0                	test   %eax,%eax
  801a6d:	78 2c                	js     801a9b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a6f:	83 ec 08             	sub    $0x8,%esp
  801a72:	68 00 50 80 00       	push   $0x805000
  801a77:	53                   	push   %ebx
  801a78:	e8 19 ed ff ff       	call   800796 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a7d:	a1 80 50 80 00       	mov    0x805080,%eax
  801a82:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a88:	a1 84 50 80 00       	mov    0x805084,%eax
  801a8d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a93:	83 c4 10             	add    $0x10,%esp
  801a96:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a9e:	c9                   	leave  
  801a9f:	c3                   	ret    

00801aa0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801aa0:	55                   	push   %ebp
  801aa1:	89 e5                	mov    %esp,%ebp
  801aa3:	83 ec 0c             	sub    $0xc,%esp
  801aa6:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801aa9:	8b 55 08             	mov    0x8(%ebp),%edx
  801aac:	8b 52 0c             	mov    0xc(%edx),%edx
  801aaf:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801ab5:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801aba:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801abf:	0f 47 c2             	cmova  %edx,%eax
  801ac2:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801ac7:	50                   	push   %eax
  801ac8:	ff 75 0c             	pushl  0xc(%ebp)
  801acb:	68 08 50 80 00       	push   $0x805008
  801ad0:	e8 53 ee ff ff       	call   800928 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801ad5:	ba 00 00 00 00       	mov    $0x0,%edx
  801ada:	b8 04 00 00 00       	mov    $0x4,%eax
  801adf:	e8 cc fe ff ff       	call   8019b0 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801ae4:	c9                   	leave  
  801ae5:	c3                   	ret    

00801ae6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801ae6:	55                   	push   %ebp
  801ae7:	89 e5                	mov    %esp,%ebp
  801ae9:	56                   	push   %esi
  801aea:	53                   	push   %ebx
  801aeb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801aee:	8b 45 08             	mov    0x8(%ebp),%eax
  801af1:	8b 40 0c             	mov    0xc(%eax),%eax
  801af4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801af9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801aff:	ba 00 00 00 00       	mov    $0x0,%edx
  801b04:	b8 03 00 00 00       	mov    $0x3,%eax
  801b09:	e8 a2 fe ff ff       	call   8019b0 <fsipc>
  801b0e:	89 c3                	mov    %eax,%ebx
  801b10:	85 c0                	test   %eax,%eax
  801b12:	78 4b                	js     801b5f <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b14:	39 c6                	cmp    %eax,%esi
  801b16:	73 16                	jae    801b2e <devfile_read+0x48>
  801b18:	68 c8 2a 80 00       	push   $0x802ac8
  801b1d:	68 cf 2a 80 00       	push   $0x802acf
  801b22:	6a 7c                	push   $0x7c
  801b24:	68 e4 2a 80 00       	push   $0x802ae4
  801b29:	e8 0a e6 ff ff       	call   800138 <_panic>
	assert(r <= PGSIZE);
  801b2e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b33:	7e 16                	jle    801b4b <devfile_read+0x65>
  801b35:	68 ef 2a 80 00       	push   $0x802aef
  801b3a:	68 cf 2a 80 00       	push   $0x802acf
  801b3f:	6a 7d                	push   $0x7d
  801b41:	68 e4 2a 80 00       	push   $0x802ae4
  801b46:	e8 ed e5 ff ff       	call   800138 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b4b:	83 ec 04             	sub    $0x4,%esp
  801b4e:	50                   	push   %eax
  801b4f:	68 00 50 80 00       	push   $0x805000
  801b54:	ff 75 0c             	pushl  0xc(%ebp)
  801b57:	e8 cc ed ff ff       	call   800928 <memmove>
	return r;
  801b5c:	83 c4 10             	add    $0x10,%esp
}
  801b5f:	89 d8                	mov    %ebx,%eax
  801b61:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b64:	5b                   	pop    %ebx
  801b65:	5e                   	pop    %esi
  801b66:	5d                   	pop    %ebp
  801b67:	c3                   	ret    

00801b68 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b68:	55                   	push   %ebp
  801b69:	89 e5                	mov    %esp,%ebp
  801b6b:	53                   	push   %ebx
  801b6c:	83 ec 20             	sub    $0x20,%esp
  801b6f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b72:	53                   	push   %ebx
  801b73:	e8 e5 eb ff ff       	call   80075d <strlen>
  801b78:	83 c4 10             	add    $0x10,%esp
  801b7b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b80:	7f 67                	jg     801be9 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b82:	83 ec 0c             	sub    $0xc,%esp
  801b85:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b88:	50                   	push   %eax
  801b89:	e8 8e f8 ff ff       	call   80141c <fd_alloc>
  801b8e:	83 c4 10             	add    $0x10,%esp
		return r;
  801b91:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b93:	85 c0                	test   %eax,%eax
  801b95:	78 57                	js     801bee <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b97:	83 ec 08             	sub    $0x8,%esp
  801b9a:	53                   	push   %ebx
  801b9b:	68 00 50 80 00       	push   $0x805000
  801ba0:	e8 f1 eb ff ff       	call   800796 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801ba5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bb0:	b8 01 00 00 00       	mov    $0x1,%eax
  801bb5:	e8 f6 fd ff ff       	call   8019b0 <fsipc>
  801bba:	89 c3                	mov    %eax,%ebx
  801bbc:	83 c4 10             	add    $0x10,%esp
  801bbf:	85 c0                	test   %eax,%eax
  801bc1:	79 14                	jns    801bd7 <open+0x6f>
		fd_close(fd, 0);
  801bc3:	83 ec 08             	sub    $0x8,%esp
  801bc6:	6a 00                	push   $0x0
  801bc8:	ff 75 f4             	pushl  -0xc(%ebp)
  801bcb:	e8 47 f9 ff ff       	call   801517 <fd_close>
		return r;
  801bd0:	83 c4 10             	add    $0x10,%esp
  801bd3:	89 da                	mov    %ebx,%edx
  801bd5:	eb 17                	jmp    801bee <open+0x86>
	}

	return fd2num(fd);
  801bd7:	83 ec 0c             	sub    $0xc,%esp
  801bda:	ff 75 f4             	pushl  -0xc(%ebp)
  801bdd:	e8 13 f8 ff ff       	call   8013f5 <fd2num>
  801be2:	89 c2                	mov    %eax,%edx
  801be4:	83 c4 10             	add    $0x10,%esp
  801be7:	eb 05                	jmp    801bee <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801be9:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801bee:	89 d0                	mov    %edx,%eax
  801bf0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bf3:	c9                   	leave  
  801bf4:	c3                   	ret    

00801bf5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bf5:	55                   	push   %ebp
  801bf6:	89 e5                	mov    %esp,%ebp
  801bf8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bfb:	ba 00 00 00 00       	mov    $0x0,%edx
  801c00:	b8 08 00 00 00       	mov    $0x8,%eax
  801c05:	e8 a6 fd ff ff       	call   8019b0 <fsipc>
}
  801c0a:	c9                   	leave  
  801c0b:	c3                   	ret    

00801c0c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c0c:	55                   	push   %ebp
  801c0d:	89 e5                	mov    %esp,%ebp
  801c0f:	56                   	push   %esi
  801c10:	53                   	push   %ebx
  801c11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c14:	83 ec 0c             	sub    $0xc,%esp
  801c17:	ff 75 08             	pushl  0x8(%ebp)
  801c1a:	e8 e6 f7 ff ff       	call   801405 <fd2data>
  801c1f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c21:	83 c4 08             	add    $0x8,%esp
  801c24:	68 fb 2a 80 00       	push   $0x802afb
  801c29:	53                   	push   %ebx
  801c2a:	e8 67 eb ff ff       	call   800796 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c2f:	8b 46 04             	mov    0x4(%esi),%eax
  801c32:	2b 06                	sub    (%esi),%eax
  801c34:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c3a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c41:	00 00 00 
	stat->st_dev = &devpipe;
  801c44:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c4b:	30 80 00 
	return 0;
}
  801c4e:	b8 00 00 00 00       	mov    $0x0,%eax
  801c53:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c56:	5b                   	pop    %ebx
  801c57:	5e                   	pop    %esi
  801c58:	5d                   	pop    %ebp
  801c59:	c3                   	ret    

00801c5a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c5a:	55                   	push   %ebp
  801c5b:	89 e5                	mov    %esp,%ebp
  801c5d:	53                   	push   %ebx
  801c5e:	83 ec 0c             	sub    $0xc,%esp
  801c61:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c64:	53                   	push   %ebx
  801c65:	6a 00                	push   $0x0
  801c67:	e8 b2 ef ff ff       	call   800c1e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c6c:	89 1c 24             	mov    %ebx,(%esp)
  801c6f:	e8 91 f7 ff ff       	call   801405 <fd2data>
  801c74:	83 c4 08             	add    $0x8,%esp
  801c77:	50                   	push   %eax
  801c78:	6a 00                	push   $0x0
  801c7a:	e8 9f ef ff ff       	call   800c1e <sys_page_unmap>
}
  801c7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c82:	c9                   	leave  
  801c83:	c3                   	ret    

00801c84 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c84:	55                   	push   %ebp
  801c85:	89 e5                	mov    %esp,%ebp
  801c87:	57                   	push   %edi
  801c88:	56                   	push   %esi
  801c89:	53                   	push   %ebx
  801c8a:	83 ec 1c             	sub    $0x1c,%esp
  801c8d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c90:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c92:	a1 04 40 80 00       	mov    0x804004,%eax
  801c97:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c9d:	83 ec 0c             	sub    $0xc,%esp
  801ca0:	ff 75 e0             	pushl  -0x20(%ebp)
  801ca3:	e8 6e 05 00 00       	call   802216 <pageref>
  801ca8:	89 c3                	mov    %eax,%ebx
  801caa:	89 3c 24             	mov    %edi,(%esp)
  801cad:	e8 64 05 00 00       	call   802216 <pageref>
  801cb2:	83 c4 10             	add    $0x10,%esp
  801cb5:	39 c3                	cmp    %eax,%ebx
  801cb7:	0f 94 c1             	sete   %cl
  801cba:	0f b6 c9             	movzbl %cl,%ecx
  801cbd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801cc0:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801cc6:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801ccc:	39 ce                	cmp    %ecx,%esi
  801cce:	74 1e                	je     801cee <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801cd0:	39 c3                	cmp    %eax,%ebx
  801cd2:	75 be                	jne    801c92 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cd4:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801cda:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cdd:	50                   	push   %eax
  801cde:	56                   	push   %esi
  801cdf:	68 02 2b 80 00       	push   $0x802b02
  801ce4:	e8 28 e5 ff ff       	call   800211 <cprintf>
  801ce9:	83 c4 10             	add    $0x10,%esp
  801cec:	eb a4                	jmp    801c92 <_pipeisclosed+0xe>
	}
}
  801cee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cf4:	5b                   	pop    %ebx
  801cf5:	5e                   	pop    %esi
  801cf6:	5f                   	pop    %edi
  801cf7:	5d                   	pop    %ebp
  801cf8:	c3                   	ret    

00801cf9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cf9:	55                   	push   %ebp
  801cfa:	89 e5                	mov    %esp,%ebp
  801cfc:	57                   	push   %edi
  801cfd:	56                   	push   %esi
  801cfe:	53                   	push   %ebx
  801cff:	83 ec 28             	sub    $0x28,%esp
  801d02:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d05:	56                   	push   %esi
  801d06:	e8 fa f6 ff ff       	call   801405 <fd2data>
  801d0b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d0d:	83 c4 10             	add    $0x10,%esp
  801d10:	bf 00 00 00 00       	mov    $0x0,%edi
  801d15:	eb 4b                	jmp    801d62 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d17:	89 da                	mov    %ebx,%edx
  801d19:	89 f0                	mov    %esi,%eax
  801d1b:	e8 64 ff ff ff       	call   801c84 <_pipeisclosed>
  801d20:	85 c0                	test   %eax,%eax
  801d22:	75 48                	jne    801d6c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d24:	e8 51 ee ff ff       	call   800b7a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d29:	8b 43 04             	mov    0x4(%ebx),%eax
  801d2c:	8b 0b                	mov    (%ebx),%ecx
  801d2e:	8d 51 20             	lea    0x20(%ecx),%edx
  801d31:	39 d0                	cmp    %edx,%eax
  801d33:	73 e2                	jae    801d17 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d38:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d3c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d3f:	89 c2                	mov    %eax,%edx
  801d41:	c1 fa 1f             	sar    $0x1f,%edx
  801d44:	89 d1                	mov    %edx,%ecx
  801d46:	c1 e9 1b             	shr    $0x1b,%ecx
  801d49:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d4c:	83 e2 1f             	and    $0x1f,%edx
  801d4f:	29 ca                	sub    %ecx,%edx
  801d51:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d55:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d59:	83 c0 01             	add    $0x1,%eax
  801d5c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d5f:	83 c7 01             	add    $0x1,%edi
  801d62:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d65:	75 c2                	jne    801d29 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d67:	8b 45 10             	mov    0x10(%ebp),%eax
  801d6a:	eb 05                	jmp    801d71 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d6c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d74:	5b                   	pop    %ebx
  801d75:	5e                   	pop    %esi
  801d76:	5f                   	pop    %edi
  801d77:	5d                   	pop    %ebp
  801d78:	c3                   	ret    

00801d79 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d79:	55                   	push   %ebp
  801d7a:	89 e5                	mov    %esp,%ebp
  801d7c:	57                   	push   %edi
  801d7d:	56                   	push   %esi
  801d7e:	53                   	push   %ebx
  801d7f:	83 ec 18             	sub    $0x18,%esp
  801d82:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d85:	57                   	push   %edi
  801d86:	e8 7a f6 ff ff       	call   801405 <fd2data>
  801d8b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d8d:	83 c4 10             	add    $0x10,%esp
  801d90:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d95:	eb 3d                	jmp    801dd4 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d97:	85 db                	test   %ebx,%ebx
  801d99:	74 04                	je     801d9f <devpipe_read+0x26>
				return i;
  801d9b:	89 d8                	mov    %ebx,%eax
  801d9d:	eb 44                	jmp    801de3 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d9f:	89 f2                	mov    %esi,%edx
  801da1:	89 f8                	mov    %edi,%eax
  801da3:	e8 dc fe ff ff       	call   801c84 <_pipeisclosed>
  801da8:	85 c0                	test   %eax,%eax
  801daa:	75 32                	jne    801dde <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801dac:	e8 c9 ed ff ff       	call   800b7a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801db1:	8b 06                	mov    (%esi),%eax
  801db3:	3b 46 04             	cmp    0x4(%esi),%eax
  801db6:	74 df                	je     801d97 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801db8:	99                   	cltd   
  801db9:	c1 ea 1b             	shr    $0x1b,%edx
  801dbc:	01 d0                	add    %edx,%eax
  801dbe:	83 e0 1f             	and    $0x1f,%eax
  801dc1:	29 d0                	sub    %edx,%eax
  801dc3:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801dc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dcb:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801dce:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dd1:	83 c3 01             	add    $0x1,%ebx
  801dd4:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801dd7:	75 d8                	jne    801db1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801dd9:	8b 45 10             	mov    0x10(%ebp),%eax
  801ddc:	eb 05                	jmp    801de3 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dde:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801de3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801de6:	5b                   	pop    %ebx
  801de7:	5e                   	pop    %esi
  801de8:	5f                   	pop    %edi
  801de9:	5d                   	pop    %ebp
  801dea:	c3                   	ret    

00801deb <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801deb:	55                   	push   %ebp
  801dec:	89 e5                	mov    %esp,%ebp
  801dee:	56                   	push   %esi
  801def:	53                   	push   %ebx
  801df0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801df3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801df6:	50                   	push   %eax
  801df7:	e8 20 f6 ff ff       	call   80141c <fd_alloc>
  801dfc:	83 c4 10             	add    $0x10,%esp
  801dff:	89 c2                	mov    %eax,%edx
  801e01:	85 c0                	test   %eax,%eax
  801e03:	0f 88 2c 01 00 00    	js     801f35 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e09:	83 ec 04             	sub    $0x4,%esp
  801e0c:	68 07 04 00 00       	push   $0x407
  801e11:	ff 75 f4             	pushl  -0xc(%ebp)
  801e14:	6a 00                	push   $0x0
  801e16:	e8 7e ed ff ff       	call   800b99 <sys_page_alloc>
  801e1b:	83 c4 10             	add    $0x10,%esp
  801e1e:	89 c2                	mov    %eax,%edx
  801e20:	85 c0                	test   %eax,%eax
  801e22:	0f 88 0d 01 00 00    	js     801f35 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e28:	83 ec 0c             	sub    $0xc,%esp
  801e2b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e2e:	50                   	push   %eax
  801e2f:	e8 e8 f5 ff ff       	call   80141c <fd_alloc>
  801e34:	89 c3                	mov    %eax,%ebx
  801e36:	83 c4 10             	add    $0x10,%esp
  801e39:	85 c0                	test   %eax,%eax
  801e3b:	0f 88 e2 00 00 00    	js     801f23 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e41:	83 ec 04             	sub    $0x4,%esp
  801e44:	68 07 04 00 00       	push   $0x407
  801e49:	ff 75 f0             	pushl  -0x10(%ebp)
  801e4c:	6a 00                	push   $0x0
  801e4e:	e8 46 ed ff ff       	call   800b99 <sys_page_alloc>
  801e53:	89 c3                	mov    %eax,%ebx
  801e55:	83 c4 10             	add    $0x10,%esp
  801e58:	85 c0                	test   %eax,%eax
  801e5a:	0f 88 c3 00 00 00    	js     801f23 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e60:	83 ec 0c             	sub    $0xc,%esp
  801e63:	ff 75 f4             	pushl  -0xc(%ebp)
  801e66:	e8 9a f5 ff ff       	call   801405 <fd2data>
  801e6b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e6d:	83 c4 0c             	add    $0xc,%esp
  801e70:	68 07 04 00 00       	push   $0x407
  801e75:	50                   	push   %eax
  801e76:	6a 00                	push   $0x0
  801e78:	e8 1c ed ff ff       	call   800b99 <sys_page_alloc>
  801e7d:	89 c3                	mov    %eax,%ebx
  801e7f:	83 c4 10             	add    $0x10,%esp
  801e82:	85 c0                	test   %eax,%eax
  801e84:	0f 88 89 00 00 00    	js     801f13 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e8a:	83 ec 0c             	sub    $0xc,%esp
  801e8d:	ff 75 f0             	pushl  -0x10(%ebp)
  801e90:	e8 70 f5 ff ff       	call   801405 <fd2data>
  801e95:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e9c:	50                   	push   %eax
  801e9d:	6a 00                	push   $0x0
  801e9f:	56                   	push   %esi
  801ea0:	6a 00                	push   $0x0
  801ea2:	e8 35 ed ff ff       	call   800bdc <sys_page_map>
  801ea7:	89 c3                	mov    %eax,%ebx
  801ea9:	83 c4 20             	add    $0x20,%esp
  801eac:	85 c0                	test   %eax,%eax
  801eae:	78 55                	js     801f05 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801eb0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801eb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ebe:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ec5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ecb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ece:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ed0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ed3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801eda:	83 ec 0c             	sub    $0xc,%esp
  801edd:	ff 75 f4             	pushl  -0xc(%ebp)
  801ee0:	e8 10 f5 ff ff       	call   8013f5 <fd2num>
  801ee5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ee8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801eea:	83 c4 04             	add    $0x4,%esp
  801eed:	ff 75 f0             	pushl  -0x10(%ebp)
  801ef0:	e8 00 f5 ff ff       	call   8013f5 <fd2num>
  801ef5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ef8:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801efb:	83 c4 10             	add    $0x10,%esp
  801efe:	ba 00 00 00 00       	mov    $0x0,%edx
  801f03:	eb 30                	jmp    801f35 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f05:	83 ec 08             	sub    $0x8,%esp
  801f08:	56                   	push   %esi
  801f09:	6a 00                	push   $0x0
  801f0b:	e8 0e ed ff ff       	call   800c1e <sys_page_unmap>
  801f10:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f13:	83 ec 08             	sub    $0x8,%esp
  801f16:	ff 75 f0             	pushl  -0x10(%ebp)
  801f19:	6a 00                	push   $0x0
  801f1b:	e8 fe ec ff ff       	call   800c1e <sys_page_unmap>
  801f20:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f23:	83 ec 08             	sub    $0x8,%esp
  801f26:	ff 75 f4             	pushl  -0xc(%ebp)
  801f29:	6a 00                	push   $0x0
  801f2b:	e8 ee ec ff ff       	call   800c1e <sys_page_unmap>
  801f30:	83 c4 10             	add    $0x10,%esp
  801f33:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f35:	89 d0                	mov    %edx,%eax
  801f37:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f3a:	5b                   	pop    %ebx
  801f3b:	5e                   	pop    %esi
  801f3c:	5d                   	pop    %ebp
  801f3d:	c3                   	ret    

00801f3e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f3e:	55                   	push   %ebp
  801f3f:	89 e5                	mov    %esp,%ebp
  801f41:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f47:	50                   	push   %eax
  801f48:	ff 75 08             	pushl  0x8(%ebp)
  801f4b:	e8 1b f5 ff ff       	call   80146b <fd_lookup>
  801f50:	83 c4 10             	add    $0x10,%esp
  801f53:	85 c0                	test   %eax,%eax
  801f55:	78 18                	js     801f6f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f57:	83 ec 0c             	sub    $0xc,%esp
  801f5a:	ff 75 f4             	pushl  -0xc(%ebp)
  801f5d:	e8 a3 f4 ff ff       	call   801405 <fd2data>
	return _pipeisclosed(fd, p);
  801f62:	89 c2                	mov    %eax,%edx
  801f64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f67:	e8 18 fd ff ff       	call   801c84 <_pipeisclosed>
  801f6c:	83 c4 10             	add    $0x10,%esp
}
  801f6f:	c9                   	leave  
  801f70:	c3                   	ret    

00801f71 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f71:	55                   	push   %ebp
  801f72:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f74:	b8 00 00 00 00       	mov    $0x0,%eax
  801f79:	5d                   	pop    %ebp
  801f7a:	c3                   	ret    

00801f7b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f7b:	55                   	push   %ebp
  801f7c:	89 e5                	mov    %esp,%ebp
  801f7e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f81:	68 1a 2b 80 00       	push   $0x802b1a
  801f86:	ff 75 0c             	pushl  0xc(%ebp)
  801f89:	e8 08 e8 ff ff       	call   800796 <strcpy>
	return 0;
}
  801f8e:	b8 00 00 00 00       	mov    $0x0,%eax
  801f93:	c9                   	leave  
  801f94:	c3                   	ret    

00801f95 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f95:	55                   	push   %ebp
  801f96:	89 e5                	mov    %esp,%ebp
  801f98:	57                   	push   %edi
  801f99:	56                   	push   %esi
  801f9a:	53                   	push   %ebx
  801f9b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fa1:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fa6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fac:	eb 2d                	jmp    801fdb <devcons_write+0x46>
		m = n - tot;
  801fae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fb1:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801fb3:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801fb6:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801fbb:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fbe:	83 ec 04             	sub    $0x4,%esp
  801fc1:	53                   	push   %ebx
  801fc2:	03 45 0c             	add    0xc(%ebp),%eax
  801fc5:	50                   	push   %eax
  801fc6:	57                   	push   %edi
  801fc7:	e8 5c e9 ff ff       	call   800928 <memmove>
		sys_cputs(buf, m);
  801fcc:	83 c4 08             	add    $0x8,%esp
  801fcf:	53                   	push   %ebx
  801fd0:	57                   	push   %edi
  801fd1:	e8 07 eb ff ff       	call   800add <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fd6:	01 de                	add    %ebx,%esi
  801fd8:	83 c4 10             	add    $0x10,%esp
  801fdb:	89 f0                	mov    %esi,%eax
  801fdd:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fe0:	72 cc                	jb     801fae <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801fe2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fe5:	5b                   	pop    %ebx
  801fe6:	5e                   	pop    %esi
  801fe7:	5f                   	pop    %edi
  801fe8:	5d                   	pop    %ebp
  801fe9:	c3                   	ret    

00801fea <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fea:	55                   	push   %ebp
  801feb:	89 e5                	mov    %esp,%ebp
  801fed:	83 ec 08             	sub    $0x8,%esp
  801ff0:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ff5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ff9:	74 2a                	je     802025 <devcons_read+0x3b>
  801ffb:	eb 05                	jmp    802002 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ffd:	e8 78 eb ff ff       	call   800b7a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802002:	e8 f4 ea ff ff       	call   800afb <sys_cgetc>
  802007:	85 c0                	test   %eax,%eax
  802009:	74 f2                	je     801ffd <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80200b:	85 c0                	test   %eax,%eax
  80200d:	78 16                	js     802025 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80200f:	83 f8 04             	cmp    $0x4,%eax
  802012:	74 0c                	je     802020 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802014:	8b 55 0c             	mov    0xc(%ebp),%edx
  802017:	88 02                	mov    %al,(%edx)
	return 1;
  802019:	b8 01 00 00 00       	mov    $0x1,%eax
  80201e:	eb 05                	jmp    802025 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802020:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802025:	c9                   	leave  
  802026:	c3                   	ret    

00802027 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802027:	55                   	push   %ebp
  802028:	89 e5                	mov    %esp,%ebp
  80202a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80202d:	8b 45 08             	mov    0x8(%ebp),%eax
  802030:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802033:	6a 01                	push   $0x1
  802035:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802038:	50                   	push   %eax
  802039:	e8 9f ea ff ff       	call   800add <sys_cputs>
}
  80203e:	83 c4 10             	add    $0x10,%esp
  802041:	c9                   	leave  
  802042:	c3                   	ret    

00802043 <getchar>:

int
getchar(void)
{
  802043:	55                   	push   %ebp
  802044:	89 e5                	mov    %esp,%ebp
  802046:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802049:	6a 01                	push   $0x1
  80204b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80204e:	50                   	push   %eax
  80204f:	6a 00                	push   $0x0
  802051:	e8 7e f6 ff ff       	call   8016d4 <read>
	if (r < 0)
  802056:	83 c4 10             	add    $0x10,%esp
  802059:	85 c0                	test   %eax,%eax
  80205b:	78 0f                	js     80206c <getchar+0x29>
		return r;
	if (r < 1)
  80205d:	85 c0                	test   %eax,%eax
  80205f:	7e 06                	jle    802067 <getchar+0x24>
		return -E_EOF;
	return c;
  802061:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802065:	eb 05                	jmp    80206c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802067:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80206c:	c9                   	leave  
  80206d:	c3                   	ret    

0080206e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80206e:	55                   	push   %ebp
  80206f:	89 e5                	mov    %esp,%ebp
  802071:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802074:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802077:	50                   	push   %eax
  802078:	ff 75 08             	pushl  0x8(%ebp)
  80207b:	e8 eb f3 ff ff       	call   80146b <fd_lookup>
  802080:	83 c4 10             	add    $0x10,%esp
  802083:	85 c0                	test   %eax,%eax
  802085:	78 11                	js     802098 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802087:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80208a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802090:	39 10                	cmp    %edx,(%eax)
  802092:	0f 94 c0             	sete   %al
  802095:	0f b6 c0             	movzbl %al,%eax
}
  802098:	c9                   	leave  
  802099:	c3                   	ret    

0080209a <opencons>:

int
opencons(void)
{
  80209a:	55                   	push   %ebp
  80209b:	89 e5                	mov    %esp,%ebp
  80209d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020a3:	50                   	push   %eax
  8020a4:	e8 73 f3 ff ff       	call   80141c <fd_alloc>
  8020a9:	83 c4 10             	add    $0x10,%esp
		return r;
  8020ac:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020ae:	85 c0                	test   %eax,%eax
  8020b0:	78 3e                	js     8020f0 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020b2:	83 ec 04             	sub    $0x4,%esp
  8020b5:	68 07 04 00 00       	push   $0x407
  8020ba:	ff 75 f4             	pushl  -0xc(%ebp)
  8020bd:	6a 00                	push   $0x0
  8020bf:	e8 d5 ea ff ff       	call   800b99 <sys_page_alloc>
  8020c4:	83 c4 10             	add    $0x10,%esp
		return r;
  8020c7:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020c9:	85 c0                	test   %eax,%eax
  8020cb:	78 23                	js     8020f0 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020cd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020db:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020e2:	83 ec 0c             	sub    $0xc,%esp
  8020e5:	50                   	push   %eax
  8020e6:	e8 0a f3 ff ff       	call   8013f5 <fd2num>
  8020eb:	89 c2                	mov    %eax,%edx
  8020ed:	83 c4 10             	add    $0x10,%esp
}
  8020f0:	89 d0                	mov    %edx,%eax
  8020f2:	c9                   	leave  
  8020f3:	c3                   	ret    

008020f4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020f4:	55                   	push   %ebp
  8020f5:	89 e5                	mov    %esp,%ebp
  8020f7:	56                   	push   %esi
  8020f8:	53                   	push   %ebx
  8020f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8020fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802102:	85 c0                	test   %eax,%eax
  802104:	75 12                	jne    802118 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802106:	83 ec 0c             	sub    $0xc,%esp
  802109:	68 00 00 c0 ee       	push   $0xeec00000
  80210e:	e8 36 ec ff ff       	call   800d49 <sys_ipc_recv>
  802113:	83 c4 10             	add    $0x10,%esp
  802116:	eb 0c                	jmp    802124 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802118:	83 ec 0c             	sub    $0xc,%esp
  80211b:	50                   	push   %eax
  80211c:	e8 28 ec ff ff       	call   800d49 <sys_ipc_recv>
  802121:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802124:	85 f6                	test   %esi,%esi
  802126:	0f 95 c1             	setne  %cl
  802129:	85 db                	test   %ebx,%ebx
  80212b:	0f 95 c2             	setne  %dl
  80212e:	84 d1                	test   %dl,%cl
  802130:	74 09                	je     80213b <ipc_recv+0x47>
  802132:	89 c2                	mov    %eax,%edx
  802134:	c1 ea 1f             	shr    $0x1f,%edx
  802137:	84 d2                	test   %dl,%dl
  802139:	75 2d                	jne    802168 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  80213b:	85 f6                	test   %esi,%esi
  80213d:	74 0d                	je     80214c <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80213f:	a1 04 40 80 00       	mov    0x804004,%eax
  802144:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  80214a:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80214c:	85 db                	test   %ebx,%ebx
  80214e:	74 0d                	je     80215d <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802150:	a1 04 40 80 00       	mov    0x804004,%eax
  802155:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  80215b:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80215d:	a1 04 40 80 00       	mov    0x804004,%eax
  802162:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  802168:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80216b:	5b                   	pop    %ebx
  80216c:	5e                   	pop    %esi
  80216d:	5d                   	pop    %ebp
  80216e:	c3                   	ret    

0080216f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80216f:	55                   	push   %ebp
  802170:	89 e5                	mov    %esp,%ebp
  802172:	57                   	push   %edi
  802173:	56                   	push   %esi
  802174:	53                   	push   %ebx
  802175:	83 ec 0c             	sub    $0xc,%esp
  802178:	8b 7d 08             	mov    0x8(%ebp),%edi
  80217b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80217e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802181:	85 db                	test   %ebx,%ebx
  802183:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802188:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80218b:	ff 75 14             	pushl  0x14(%ebp)
  80218e:	53                   	push   %ebx
  80218f:	56                   	push   %esi
  802190:	57                   	push   %edi
  802191:	e8 90 eb ff ff       	call   800d26 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802196:	89 c2                	mov    %eax,%edx
  802198:	c1 ea 1f             	shr    $0x1f,%edx
  80219b:	83 c4 10             	add    $0x10,%esp
  80219e:	84 d2                	test   %dl,%dl
  8021a0:	74 17                	je     8021b9 <ipc_send+0x4a>
  8021a2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021a5:	74 12                	je     8021b9 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8021a7:	50                   	push   %eax
  8021a8:	68 26 2b 80 00       	push   $0x802b26
  8021ad:	6a 47                	push   $0x47
  8021af:	68 34 2b 80 00       	push   $0x802b34
  8021b4:	e8 7f df ff ff       	call   800138 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8021b9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021bc:	75 07                	jne    8021c5 <ipc_send+0x56>
			sys_yield();
  8021be:	e8 b7 e9 ff ff       	call   800b7a <sys_yield>
  8021c3:	eb c6                	jmp    80218b <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8021c5:	85 c0                	test   %eax,%eax
  8021c7:	75 c2                	jne    80218b <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8021c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021cc:	5b                   	pop    %ebx
  8021cd:	5e                   	pop    %esi
  8021ce:	5f                   	pop    %edi
  8021cf:	5d                   	pop    %ebp
  8021d0:	c3                   	ret    

008021d1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021d1:	55                   	push   %ebp
  8021d2:	89 e5                	mov    %esp,%ebp
  8021d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8021d7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021dc:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  8021e2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021e8:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  8021ee:	39 ca                	cmp    %ecx,%edx
  8021f0:	75 13                	jne    802205 <ipc_find_env+0x34>
			return envs[i].env_id;
  8021f2:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8021f8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021fd:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  802203:	eb 0f                	jmp    802214 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802205:	83 c0 01             	add    $0x1,%eax
  802208:	3d 00 04 00 00       	cmp    $0x400,%eax
  80220d:	75 cd                	jne    8021dc <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80220f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802214:	5d                   	pop    %ebp
  802215:	c3                   	ret    

00802216 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802216:	55                   	push   %ebp
  802217:	89 e5                	mov    %esp,%ebp
  802219:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80221c:	89 d0                	mov    %edx,%eax
  80221e:	c1 e8 16             	shr    $0x16,%eax
  802221:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802228:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80222d:	f6 c1 01             	test   $0x1,%cl
  802230:	74 1d                	je     80224f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802232:	c1 ea 0c             	shr    $0xc,%edx
  802235:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80223c:	f6 c2 01             	test   $0x1,%dl
  80223f:	74 0e                	je     80224f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802241:	c1 ea 0c             	shr    $0xc,%edx
  802244:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80224b:	ef 
  80224c:	0f b7 c0             	movzwl %ax,%eax
}
  80224f:	5d                   	pop    %ebp
  802250:	c3                   	ret    
  802251:	66 90                	xchg   %ax,%ax
  802253:	66 90                	xchg   %ax,%ax
  802255:	66 90                	xchg   %ax,%ax
  802257:	66 90                	xchg   %ax,%ax
  802259:	66 90                	xchg   %ax,%ax
  80225b:	66 90                	xchg   %ax,%ax
  80225d:	66 90                	xchg   %ax,%ax
  80225f:	90                   	nop

00802260 <__udivdi3>:
  802260:	55                   	push   %ebp
  802261:	57                   	push   %edi
  802262:	56                   	push   %esi
  802263:	53                   	push   %ebx
  802264:	83 ec 1c             	sub    $0x1c,%esp
  802267:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80226b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80226f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802273:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802277:	85 f6                	test   %esi,%esi
  802279:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80227d:	89 ca                	mov    %ecx,%edx
  80227f:	89 f8                	mov    %edi,%eax
  802281:	75 3d                	jne    8022c0 <__udivdi3+0x60>
  802283:	39 cf                	cmp    %ecx,%edi
  802285:	0f 87 c5 00 00 00    	ja     802350 <__udivdi3+0xf0>
  80228b:	85 ff                	test   %edi,%edi
  80228d:	89 fd                	mov    %edi,%ebp
  80228f:	75 0b                	jne    80229c <__udivdi3+0x3c>
  802291:	b8 01 00 00 00       	mov    $0x1,%eax
  802296:	31 d2                	xor    %edx,%edx
  802298:	f7 f7                	div    %edi
  80229a:	89 c5                	mov    %eax,%ebp
  80229c:	89 c8                	mov    %ecx,%eax
  80229e:	31 d2                	xor    %edx,%edx
  8022a0:	f7 f5                	div    %ebp
  8022a2:	89 c1                	mov    %eax,%ecx
  8022a4:	89 d8                	mov    %ebx,%eax
  8022a6:	89 cf                	mov    %ecx,%edi
  8022a8:	f7 f5                	div    %ebp
  8022aa:	89 c3                	mov    %eax,%ebx
  8022ac:	89 d8                	mov    %ebx,%eax
  8022ae:	89 fa                	mov    %edi,%edx
  8022b0:	83 c4 1c             	add    $0x1c,%esp
  8022b3:	5b                   	pop    %ebx
  8022b4:	5e                   	pop    %esi
  8022b5:	5f                   	pop    %edi
  8022b6:	5d                   	pop    %ebp
  8022b7:	c3                   	ret    
  8022b8:	90                   	nop
  8022b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	39 ce                	cmp    %ecx,%esi
  8022c2:	77 74                	ja     802338 <__udivdi3+0xd8>
  8022c4:	0f bd fe             	bsr    %esi,%edi
  8022c7:	83 f7 1f             	xor    $0x1f,%edi
  8022ca:	0f 84 98 00 00 00    	je     802368 <__udivdi3+0x108>
  8022d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8022d5:	89 f9                	mov    %edi,%ecx
  8022d7:	89 c5                	mov    %eax,%ebp
  8022d9:	29 fb                	sub    %edi,%ebx
  8022db:	d3 e6                	shl    %cl,%esi
  8022dd:	89 d9                	mov    %ebx,%ecx
  8022df:	d3 ed                	shr    %cl,%ebp
  8022e1:	89 f9                	mov    %edi,%ecx
  8022e3:	d3 e0                	shl    %cl,%eax
  8022e5:	09 ee                	or     %ebp,%esi
  8022e7:	89 d9                	mov    %ebx,%ecx
  8022e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022ed:	89 d5                	mov    %edx,%ebp
  8022ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022f3:	d3 ed                	shr    %cl,%ebp
  8022f5:	89 f9                	mov    %edi,%ecx
  8022f7:	d3 e2                	shl    %cl,%edx
  8022f9:	89 d9                	mov    %ebx,%ecx
  8022fb:	d3 e8                	shr    %cl,%eax
  8022fd:	09 c2                	or     %eax,%edx
  8022ff:	89 d0                	mov    %edx,%eax
  802301:	89 ea                	mov    %ebp,%edx
  802303:	f7 f6                	div    %esi
  802305:	89 d5                	mov    %edx,%ebp
  802307:	89 c3                	mov    %eax,%ebx
  802309:	f7 64 24 0c          	mull   0xc(%esp)
  80230d:	39 d5                	cmp    %edx,%ebp
  80230f:	72 10                	jb     802321 <__udivdi3+0xc1>
  802311:	8b 74 24 08          	mov    0x8(%esp),%esi
  802315:	89 f9                	mov    %edi,%ecx
  802317:	d3 e6                	shl    %cl,%esi
  802319:	39 c6                	cmp    %eax,%esi
  80231b:	73 07                	jae    802324 <__udivdi3+0xc4>
  80231d:	39 d5                	cmp    %edx,%ebp
  80231f:	75 03                	jne    802324 <__udivdi3+0xc4>
  802321:	83 eb 01             	sub    $0x1,%ebx
  802324:	31 ff                	xor    %edi,%edi
  802326:	89 d8                	mov    %ebx,%eax
  802328:	89 fa                	mov    %edi,%edx
  80232a:	83 c4 1c             	add    $0x1c,%esp
  80232d:	5b                   	pop    %ebx
  80232e:	5e                   	pop    %esi
  80232f:	5f                   	pop    %edi
  802330:	5d                   	pop    %ebp
  802331:	c3                   	ret    
  802332:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802338:	31 ff                	xor    %edi,%edi
  80233a:	31 db                	xor    %ebx,%ebx
  80233c:	89 d8                	mov    %ebx,%eax
  80233e:	89 fa                	mov    %edi,%edx
  802340:	83 c4 1c             	add    $0x1c,%esp
  802343:	5b                   	pop    %ebx
  802344:	5e                   	pop    %esi
  802345:	5f                   	pop    %edi
  802346:	5d                   	pop    %ebp
  802347:	c3                   	ret    
  802348:	90                   	nop
  802349:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802350:	89 d8                	mov    %ebx,%eax
  802352:	f7 f7                	div    %edi
  802354:	31 ff                	xor    %edi,%edi
  802356:	89 c3                	mov    %eax,%ebx
  802358:	89 d8                	mov    %ebx,%eax
  80235a:	89 fa                	mov    %edi,%edx
  80235c:	83 c4 1c             	add    $0x1c,%esp
  80235f:	5b                   	pop    %ebx
  802360:	5e                   	pop    %esi
  802361:	5f                   	pop    %edi
  802362:	5d                   	pop    %ebp
  802363:	c3                   	ret    
  802364:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802368:	39 ce                	cmp    %ecx,%esi
  80236a:	72 0c                	jb     802378 <__udivdi3+0x118>
  80236c:	31 db                	xor    %ebx,%ebx
  80236e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802372:	0f 87 34 ff ff ff    	ja     8022ac <__udivdi3+0x4c>
  802378:	bb 01 00 00 00       	mov    $0x1,%ebx
  80237d:	e9 2a ff ff ff       	jmp    8022ac <__udivdi3+0x4c>
  802382:	66 90                	xchg   %ax,%ax
  802384:	66 90                	xchg   %ax,%ax
  802386:	66 90                	xchg   %ax,%ax
  802388:	66 90                	xchg   %ax,%ax
  80238a:	66 90                	xchg   %ax,%ax
  80238c:	66 90                	xchg   %ax,%ax
  80238e:	66 90                	xchg   %ax,%ax

00802390 <__umoddi3>:
  802390:	55                   	push   %ebp
  802391:	57                   	push   %edi
  802392:	56                   	push   %esi
  802393:	53                   	push   %ebx
  802394:	83 ec 1c             	sub    $0x1c,%esp
  802397:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80239b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80239f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023a7:	85 d2                	test   %edx,%edx
  8023a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8023ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023b1:	89 f3                	mov    %esi,%ebx
  8023b3:	89 3c 24             	mov    %edi,(%esp)
  8023b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023ba:	75 1c                	jne    8023d8 <__umoddi3+0x48>
  8023bc:	39 f7                	cmp    %esi,%edi
  8023be:	76 50                	jbe    802410 <__umoddi3+0x80>
  8023c0:	89 c8                	mov    %ecx,%eax
  8023c2:	89 f2                	mov    %esi,%edx
  8023c4:	f7 f7                	div    %edi
  8023c6:	89 d0                	mov    %edx,%eax
  8023c8:	31 d2                	xor    %edx,%edx
  8023ca:	83 c4 1c             	add    $0x1c,%esp
  8023cd:	5b                   	pop    %ebx
  8023ce:	5e                   	pop    %esi
  8023cf:	5f                   	pop    %edi
  8023d0:	5d                   	pop    %ebp
  8023d1:	c3                   	ret    
  8023d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023d8:	39 f2                	cmp    %esi,%edx
  8023da:	89 d0                	mov    %edx,%eax
  8023dc:	77 52                	ja     802430 <__umoddi3+0xa0>
  8023de:	0f bd ea             	bsr    %edx,%ebp
  8023e1:	83 f5 1f             	xor    $0x1f,%ebp
  8023e4:	75 5a                	jne    802440 <__umoddi3+0xb0>
  8023e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8023ea:	0f 82 e0 00 00 00    	jb     8024d0 <__umoddi3+0x140>
  8023f0:	39 0c 24             	cmp    %ecx,(%esp)
  8023f3:	0f 86 d7 00 00 00    	jbe    8024d0 <__umoddi3+0x140>
  8023f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802401:	83 c4 1c             	add    $0x1c,%esp
  802404:	5b                   	pop    %ebx
  802405:	5e                   	pop    %esi
  802406:	5f                   	pop    %edi
  802407:	5d                   	pop    %ebp
  802408:	c3                   	ret    
  802409:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802410:	85 ff                	test   %edi,%edi
  802412:	89 fd                	mov    %edi,%ebp
  802414:	75 0b                	jne    802421 <__umoddi3+0x91>
  802416:	b8 01 00 00 00       	mov    $0x1,%eax
  80241b:	31 d2                	xor    %edx,%edx
  80241d:	f7 f7                	div    %edi
  80241f:	89 c5                	mov    %eax,%ebp
  802421:	89 f0                	mov    %esi,%eax
  802423:	31 d2                	xor    %edx,%edx
  802425:	f7 f5                	div    %ebp
  802427:	89 c8                	mov    %ecx,%eax
  802429:	f7 f5                	div    %ebp
  80242b:	89 d0                	mov    %edx,%eax
  80242d:	eb 99                	jmp    8023c8 <__umoddi3+0x38>
  80242f:	90                   	nop
  802430:	89 c8                	mov    %ecx,%eax
  802432:	89 f2                	mov    %esi,%edx
  802434:	83 c4 1c             	add    $0x1c,%esp
  802437:	5b                   	pop    %ebx
  802438:	5e                   	pop    %esi
  802439:	5f                   	pop    %edi
  80243a:	5d                   	pop    %ebp
  80243b:	c3                   	ret    
  80243c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802440:	8b 34 24             	mov    (%esp),%esi
  802443:	bf 20 00 00 00       	mov    $0x20,%edi
  802448:	89 e9                	mov    %ebp,%ecx
  80244a:	29 ef                	sub    %ebp,%edi
  80244c:	d3 e0                	shl    %cl,%eax
  80244e:	89 f9                	mov    %edi,%ecx
  802450:	89 f2                	mov    %esi,%edx
  802452:	d3 ea                	shr    %cl,%edx
  802454:	89 e9                	mov    %ebp,%ecx
  802456:	09 c2                	or     %eax,%edx
  802458:	89 d8                	mov    %ebx,%eax
  80245a:	89 14 24             	mov    %edx,(%esp)
  80245d:	89 f2                	mov    %esi,%edx
  80245f:	d3 e2                	shl    %cl,%edx
  802461:	89 f9                	mov    %edi,%ecx
  802463:	89 54 24 04          	mov    %edx,0x4(%esp)
  802467:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80246b:	d3 e8                	shr    %cl,%eax
  80246d:	89 e9                	mov    %ebp,%ecx
  80246f:	89 c6                	mov    %eax,%esi
  802471:	d3 e3                	shl    %cl,%ebx
  802473:	89 f9                	mov    %edi,%ecx
  802475:	89 d0                	mov    %edx,%eax
  802477:	d3 e8                	shr    %cl,%eax
  802479:	89 e9                	mov    %ebp,%ecx
  80247b:	09 d8                	or     %ebx,%eax
  80247d:	89 d3                	mov    %edx,%ebx
  80247f:	89 f2                	mov    %esi,%edx
  802481:	f7 34 24             	divl   (%esp)
  802484:	89 d6                	mov    %edx,%esi
  802486:	d3 e3                	shl    %cl,%ebx
  802488:	f7 64 24 04          	mull   0x4(%esp)
  80248c:	39 d6                	cmp    %edx,%esi
  80248e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802492:	89 d1                	mov    %edx,%ecx
  802494:	89 c3                	mov    %eax,%ebx
  802496:	72 08                	jb     8024a0 <__umoddi3+0x110>
  802498:	75 11                	jne    8024ab <__umoddi3+0x11b>
  80249a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80249e:	73 0b                	jae    8024ab <__umoddi3+0x11b>
  8024a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8024a4:	1b 14 24             	sbb    (%esp),%edx
  8024a7:	89 d1                	mov    %edx,%ecx
  8024a9:	89 c3                	mov    %eax,%ebx
  8024ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8024af:	29 da                	sub    %ebx,%edx
  8024b1:	19 ce                	sbb    %ecx,%esi
  8024b3:	89 f9                	mov    %edi,%ecx
  8024b5:	89 f0                	mov    %esi,%eax
  8024b7:	d3 e0                	shl    %cl,%eax
  8024b9:	89 e9                	mov    %ebp,%ecx
  8024bb:	d3 ea                	shr    %cl,%edx
  8024bd:	89 e9                	mov    %ebp,%ecx
  8024bf:	d3 ee                	shr    %cl,%esi
  8024c1:	09 d0                	or     %edx,%eax
  8024c3:	89 f2                	mov    %esi,%edx
  8024c5:	83 c4 1c             	add    $0x1c,%esp
  8024c8:	5b                   	pop    %ebx
  8024c9:	5e                   	pop    %esi
  8024ca:	5f                   	pop    %edi
  8024cb:	5d                   	pop    %ebp
  8024cc:	c3                   	ret    
  8024cd:	8d 76 00             	lea    0x0(%esi),%esi
  8024d0:	29 f9                	sub    %edi,%ecx
  8024d2:	19 d6                	sbb    %edx,%esi
  8024d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024dc:	e9 18 ff ff ff       	jmp    8023f9 <__umoddi3+0x69>
