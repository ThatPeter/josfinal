
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
  800040:	68 40 22 80 00       	push   $0x802240
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
  80006a:	68 60 22 80 00       	push   $0x802260
  80006f:	6a 0f                	push   $0xf
  800071:	68 4a 22 80 00       	push   $0x80224a
  800076:	e8 bd 00 00 00       	call   800138 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 8c 22 80 00       	push   $0x80228c
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
  80009c:	e8 29 0d 00 00       	call   800dca <set_pgfault_handler>
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
  8000ca:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
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
  800124:	e8 ef 11 00 00       	call   801318 <close_all>
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
  800156:	68 b8 22 80 00       	push   $0x8022b8
  80015b:	e8 b1 00 00 00       	call   800211 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800160:	83 c4 18             	add    $0x18,%esp
  800163:	53                   	push   %ebx
  800164:	ff 75 10             	pushl  0x10(%ebp)
  800167:	e8 54 00 00 00       	call   8001c0 <vcprintf>
	cprintf("\n");
  80016c:	c7 04 24 73 27 80 00 	movl   $0x802773,(%esp)
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
  800274:	e8 27 1d 00 00       	call   801fa0 <__udivdi3>
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
  8002b7:	e8 14 1e 00 00       	call   8020d0 <__umoddi3>
  8002bc:	83 c4 14             	add    $0x14,%esp
  8002bf:	0f be 80 db 22 80 00 	movsbl 0x8022db(%eax),%eax
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
  8003bb:	ff 24 85 20 24 80 00 	jmp    *0x802420(,%eax,4)
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
  80047f:	8b 14 85 80 25 80 00 	mov    0x802580(,%eax,4),%edx
  800486:	85 d2                	test   %edx,%edx
  800488:	75 18                	jne    8004a2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80048a:	50                   	push   %eax
  80048b:	68 f3 22 80 00       	push   $0x8022f3
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
  8004a3:	68 41 27 80 00       	push   $0x802741
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
  8004c7:	b8 ec 22 80 00       	mov    $0x8022ec,%eax
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
  800b42:	68 df 25 80 00       	push   $0x8025df
  800b47:	6a 23                	push   $0x23
  800b49:	68 fc 25 80 00       	push   $0x8025fc
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
  800bc3:	68 df 25 80 00       	push   $0x8025df
  800bc8:	6a 23                	push   $0x23
  800bca:	68 fc 25 80 00       	push   $0x8025fc
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
  800c05:	68 df 25 80 00       	push   $0x8025df
  800c0a:	6a 23                	push   $0x23
  800c0c:	68 fc 25 80 00       	push   $0x8025fc
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
  800c47:	68 df 25 80 00       	push   $0x8025df
  800c4c:	6a 23                	push   $0x23
  800c4e:	68 fc 25 80 00       	push   $0x8025fc
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
  800c89:	68 df 25 80 00       	push   $0x8025df
  800c8e:	6a 23                	push   $0x23
  800c90:	68 fc 25 80 00       	push   $0x8025fc
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
  800ccb:	68 df 25 80 00       	push   $0x8025df
  800cd0:	6a 23                	push   $0x23
  800cd2:	68 fc 25 80 00       	push   $0x8025fc
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
  800d0d:	68 df 25 80 00       	push   $0x8025df
  800d12:	6a 23                	push   $0x23
  800d14:	68 fc 25 80 00       	push   $0x8025fc
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
  800d71:	68 df 25 80 00       	push   $0x8025df
  800d76:	6a 23                	push   $0x23
  800d78:	68 fc 25 80 00       	push   $0x8025fc
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

00800dca <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
  800dcd:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800dd0:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800dd7:	75 2a                	jne    800e03 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  800dd9:	83 ec 04             	sub    $0x4,%esp
  800ddc:	6a 07                	push   $0x7
  800dde:	68 00 f0 bf ee       	push   $0xeebff000
  800de3:	6a 00                	push   $0x0
  800de5:	e8 af fd ff ff       	call   800b99 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  800dea:	83 c4 10             	add    $0x10,%esp
  800ded:	85 c0                	test   %eax,%eax
  800def:	79 12                	jns    800e03 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  800df1:	50                   	push   %eax
  800df2:	68 0a 26 80 00       	push   $0x80260a
  800df7:	6a 23                	push   $0x23
  800df9:	68 0e 26 80 00       	push   $0x80260e
  800dfe:	e8 35 f3 ff ff       	call   800138 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e03:	8b 45 08             	mov    0x8(%ebp),%eax
  800e06:	a3 08 40 80 00       	mov    %eax,0x804008
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  800e0b:	83 ec 08             	sub    $0x8,%esp
  800e0e:	68 35 0e 80 00       	push   $0x800e35
  800e13:	6a 00                	push   $0x0
  800e15:	e8 ca fe ff ff       	call   800ce4 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  800e1a:	83 c4 10             	add    $0x10,%esp
  800e1d:	85 c0                	test   %eax,%eax
  800e1f:	79 12                	jns    800e33 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  800e21:	50                   	push   %eax
  800e22:	68 0a 26 80 00       	push   $0x80260a
  800e27:	6a 2c                	push   $0x2c
  800e29:	68 0e 26 80 00       	push   $0x80260e
  800e2e:	e8 05 f3 ff ff       	call   800138 <_panic>
	}
}
  800e33:	c9                   	leave  
  800e34:	c3                   	ret    

00800e35 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e35:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e36:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800e3b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e3d:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  800e40:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  800e44:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  800e49:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  800e4d:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  800e4f:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  800e52:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  800e53:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  800e56:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  800e57:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e58:	c3                   	ret    

00800e59 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e59:	55                   	push   %ebp
  800e5a:	89 e5                	mov    %esp,%ebp
  800e5c:	53                   	push   %ebx
  800e5d:	83 ec 04             	sub    $0x4,%esp
  800e60:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e63:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800e65:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e69:	74 11                	je     800e7c <pgfault+0x23>
  800e6b:	89 d8                	mov    %ebx,%eax
  800e6d:	c1 e8 0c             	shr    $0xc,%eax
  800e70:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e77:	f6 c4 08             	test   $0x8,%ah
  800e7a:	75 14                	jne    800e90 <pgfault+0x37>
		panic("faulting access");
  800e7c:	83 ec 04             	sub    $0x4,%esp
  800e7f:	68 1c 26 80 00       	push   $0x80261c
  800e84:	6a 1e                	push   $0x1e
  800e86:	68 2c 26 80 00       	push   $0x80262c
  800e8b:	e8 a8 f2 ff ff       	call   800138 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800e90:	83 ec 04             	sub    $0x4,%esp
  800e93:	6a 07                	push   $0x7
  800e95:	68 00 f0 7f 00       	push   $0x7ff000
  800e9a:	6a 00                	push   $0x0
  800e9c:	e8 f8 fc ff ff       	call   800b99 <sys_page_alloc>
	if (r < 0) {
  800ea1:	83 c4 10             	add    $0x10,%esp
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	79 12                	jns    800eba <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800ea8:	50                   	push   %eax
  800ea9:	68 37 26 80 00       	push   $0x802637
  800eae:	6a 2c                	push   $0x2c
  800eb0:	68 2c 26 80 00       	push   $0x80262c
  800eb5:	e8 7e f2 ff ff       	call   800138 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800eba:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800ec0:	83 ec 04             	sub    $0x4,%esp
  800ec3:	68 00 10 00 00       	push   $0x1000
  800ec8:	53                   	push   %ebx
  800ec9:	68 00 f0 7f 00       	push   $0x7ff000
  800ece:	e8 bd fa ff ff       	call   800990 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800ed3:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800eda:	53                   	push   %ebx
  800edb:	6a 00                	push   $0x0
  800edd:	68 00 f0 7f 00       	push   $0x7ff000
  800ee2:	6a 00                	push   $0x0
  800ee4:	e8 f3 fc ff ff       	call   800bdc <sys_page_map>
	if (r < 0) {
  800ee9:	83 c4 20             	add    $0x20,%esp
  800eec:	85 c0                	test   %eax,%eax
  800eee:	79 12                	jns    800f02 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800ef0:	50                   	push   %eax
  800ef1:	68 37 26 80 00       	push   $0x802637
  800ef6:	6a 33                	push   $0x33
  800ef8:	68 2c 26 80 00       	push   $0x80262c
  800efd:	e8 36 f2 ff ff       	call   800138 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800f02:	83 ec 08             	sub    $0x8,%esp
  800f05:	68 00 f0 7f 00       	push   $0x7ff000
  800f0a:	6a 00                	push   $0x0
  800f0c:	e8 0d fd ff ff       	call   800c1e <sys_page_unmap>
	if (r < 0) {
  800f11:	83 c4 10             	add    $0x10,%esp
  800f14:	85 c0                	test   %eax,%eax
  800f16:	79 12                	jns    800f2a <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800f18:	50                   	push   %eax
  800f19:	68 37 26 80 00       	push   $0x802637
  800f1e:	6a 37                	push   $0x37
  800f20:	68 2c 26 80 00       	push   $0x80262c
  800f25:	e8 0e f2 ff ff       	call   800138 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800f2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f2d:	c9                   	leave  
  800f2e:	c3                   	ret    

00800f2f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	57                   	push   %edi
  800f33:	56                   	push   %esi
  800f34:	53                   	push   %ebx
  800f35:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800f38:	68 59 0e 80 00       	push   $0x800e59
  800f3d:	e8 88 fe ff ff       	call   800dca <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f42:	b8 07 00 00 00       	mov    $0x7,%eax
  800f47:	cd 30                	int    $0x30
  800f49:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800f4c:	83 c4 10             	add    $0x10,%esp
  800f4f:	85 c0                	test   %eax,%eax
  800f51:	79 17                	jns    800f6a <fork+0x3b>
		panic("fork fault %e");
  800f53:	83 ec 04             	sub    $0x4,%esp
  800f56:	68 50 26 80 00       	push   $0x802650
  800f5b:	68 84 00 00 00       	push   $0x84
  800f60:	68 2c 26 80 00       	push   $0x80262c
  800f65:	e8 ce f1 ff ff       	call   800138 <_panic>
  800f6a:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f6c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f70:	75 24                	jne    800f96 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f72:	e8 e4 fb ff ff       	call   800b5b <sys_getenvid>
  800f77:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f7c:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  800f82:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f87:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f91:	e9 64 01 00 00       	jmp    8010fa <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800f96:	83 ec 04             	sub    $0x4,%esp
  800f99:	6a 07                	push   $0x7
  800f9b:	68 00 f0 bf ee       	push   $0xeebff000
  800fa0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fa3:	e8 f1 fb ff ff       	call   800b99 <sys_page_alloc>
  800fa8:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800fab:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800fb0:	89 d8                	mov    %ebx,%eax
  800fb2:	c1 e8 16             	shr    $0x16,%eax
  800fb5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fbc:	a8 01                	test   $0x1,%al
  800fbe:	0f 84 fc 00 00 00    	je     8010c0 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800fc4:	89 d8                	mov    %ebx,%eax
  800fc6:	c1 e8 0c             	shr    $0xc,%eax
  800fc9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800fd0:	f6 c2 01             	test   $0x1,%dl
  800fd3:	0f 84 e7 00 00 00    	je     8010c0 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800fd9:	89 c6                	mov    %eax,%esi
  800fdb:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800fde:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fe5:	f6 c6 04             	test   $0x4,%dh
  800fe8:	74 39                	je     801023 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800fea:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ff1:	83 ec 0c             	sub    $0xc,%esp
  800ff4:	25 07 0e 00 00       	and    $0xe07,%eax
  800ff9:	50                   	push   %eax
  800ffa:	56                   	push   %esi
  800ffb:	57                   	push   %edi
  800ffc:	56                   	push   %esi
  800ffd:	6a 00                	push   $0x0
  800fff:	e8 d8 fb ff ff       	call   800bdc <sys_page_map>
		if (r < 0) {
  801004:	83 c4 20             	add    $0x20,%esp
  801007:	85 c0                	test   %eax,%eax
  801009:	0f 89 b1 00 00 00    	jns    8010c0 <fork+0x191>
		    	panic("sys page map fault %e");
  80100f:	83 ec 04             	sub    $0x4,%esp
  801012:	68 5e 26 80 00       	push   $0x80265e
  801017:	6a 54                	push   $0x54
  801019:	68 2c 26 80 00       	push   $0x80262c
  80101e:	e8 15 f1 ff ff       	call   800138 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801023:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80102a:	f6 c2 02             	test   $0x2,%dl
  80102d:	75 0c                	jne    80103b <fork+0x10c>
  80102f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801036:	f6 c4 08             	test   $0x8,%ah
  801039:	74 5b                	je     801096 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80103b:	83 ec 0c             	sub    $0xc,%esp
  80103e:	68 05 08 00 00       	push   $0x805
  801043:	56                   	push   %esi
  801044:	57                   	push   %edi
  801045:	56                   	push   %esi
  801046:	6a 00                	push   $0x0
  801048:	e8 8f fb ff ff       	call   800bdc <sys_page_map>
		if (r < 0) {
  80104d:	83 c4 20             	add    $0x20,%esp
  801050:	85 c0                	test   %eax,%eax
  801052:	79 14                	jns    801068 <fork+0x139>
		    	panic("sys page map fault %e");
  801054:	83 ec 04             	sub    $0x4,%esp
  801057:	68 5e 26 80 00       	push   $0x80265e
  80105c:	6a 5b                	push   $0x5b
  80105e:	68 2c 26 80 00       	push   $0x80262c
  801063:	e8 d0 f0 ff ff       	call   800138 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  801068:	83 ec 0c             	sub    $0xc,%esp
  80106b:	68 05 08 00 00       	push   $0x805
  801070:	56                   	push   %esi
  801071:	6a 00                	push   $0x0
  801073:	56                   	push   %esi
  801074:	6a 00                	push   $0x0
  801076:	e8 61 fb ff ff       	call   800bdc <sys_page_map>
		if (r < 0) {
  80107b:	83 c4 20             	add    $0x20,%esp
  80107e:	85 c0                	test   %eax,%eax
  801080:	79 3e                	jns    8010c0 <fork+0x191>
		    	panic("sys page map fault %e");
  801082:	83 ec 04             	sub    $0x4,%esp
  801085:	68 5e 26 80 00       	push   $0x80265e
  80108a:	6a 5f                	push   $0x5f
  80108c:	68 2c 26 80 00       	push   $0x80262c
  801091:	e8 a2 f0 ff ff       	call   800138 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801096:	83 ec 0c             	sub    $0xc,%esp
  801099:	6a 05                	push   $0x5
  80109b:	56                   	push   %esi
  80109c:	57                   	push   %edi
  80109d:	56                   	push   %esi
  80109e:	6a 00                	push   $0x0
  8010a0:	e8 37 fb ff ff       	call   800bdc <sys_page_map>
		if (r < 0) {
  8010a5:	83 c4 20             	add    $0x20,%esp
  8010a8:	85 c0                	test   %eax,%eax
  8010aa:	79 14                	jns    8010c0 <fork+0x191>
		    	panic("sys page map fault %e");
  8010ac:	83 ec 04             	sub    $0x4,%esp
  8010af:	68 5e 26 80 00       	push   $0x80265e
  8010b4:	6a 64                	push   $0x64
  8010b6:	68 2c 26 80 00       	push   $0x80262c
  8010bb:	e8 78 f0 ff ff       	call   800138 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8010c0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010c6:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8010cc:	0f 85 de fe ff ff    	jne    800fb0 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  8010d2:	a1 04 40 80 00       	mov    0x804004,%eax
  8010d7:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  8010dd:	83 ec 08             	sub    $0x8,%esp
  8010e0:	50                   	push   %eax
  8010e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010e4:	57                   	push   %edi
  8010e5:	e8 fa fb ff ff       	call   800ce4 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  8010ea:	83 c4 08             	add    $0x8,%esp
  8010ed:	6a 02                	push   $0x2
  8010ef:	57                   	push   %edi
  8010f0:	e8 6b fb ff ff       	call   800c60 <sys_env_set_status>
	
	return envid;
  8010f5:	83 c4 10             	add    $0x10,%esp
  8010f8:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  8010fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fd:	5b                   	pop    %ebx
  8010fe:	5e                   	pop    %esi
  8010ff:	5f                   	pop    %edi
  801100:	5d                   	pop    %ebp
  801101:	c3                   	ret    

00801102 <sfork>:

envid_t
sfork(void)
{
  801102:	55                   	push   %ebp
  801103:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801105:	b8 00 00 00 00       	mov    $0x0,%eax
  80110a:	5d                   	pop    %ebp
  80110b:	c3                   	ret    

0080110c <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80110c:	55                   	push   %ebp
  80110d:	89 e5                	mov    %esp,%ebp
  80110f:	56                   	push   %esi
  801110:	53                   	push   %ebx
  801111:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801114:	89 1d 0c 40 80 00    	mov    %ebx,0x80400c
	cprintf("in fork.c thread create. func: %x\n", func);
  80111a:	83 ec 08             	sub    $0x8,%esp
  80111d:	53                   	push   %ebx
  80111e:	68 74 26 80 00       	push   $0x802674
  801123:	e8 e9 f0 ff ff       	call   800211 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801128:	c7 04 24 fe 00 80 00 	movl   $0x8000fe,(%esp)
  80112f:	e8 56 fc ff ff       	call   800d8a <sys_thread_create>
  801134:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801136:	83 c4 08             	add    $0x8,%esp
  801139:	53                   	push   %ebx
  80113a:	68 74 26 80 00       	push   $0x802674
  80113f:	e8 cd f0 ff ff       	call   800211 <cprintf>
	return id;
}
  801144:	89 f0                	mov    %esi,%eax
  801146:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801149:	5b                   	pop    %ebx
  80114a:	5e                   	pop    %esi
  80114b:	5d                   	pop    %ebp
  80114c:	c3                   	ret    

0080114d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80114d:	55                   	push   %ebp
  80114e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801150:	8b 45 08             	mov    0x8(%ebp),%eax
  801153:	05 00 00 00 30       	add    $0x30000000,%eax
  801158:	c1 e8 0c             	shr    $0xc,%eax
}
  80115b:	5d                   	pop    %ebp
  80115c:	c3                   	ret    

0080115d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80115d:	55                   	push   %ebp
  80115e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801160:	8b 45 08             	mov    0x8(%ebp),%eax
  801163:	05 00 00 00 30       	add    $0x30000000,%eax
  801168:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80116d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801172:	5d                   	pop    %ebp
  801173:	c3                   	ret    

00801174 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
  801177:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80117a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80117f:	89 c2                	mov    %eax,%edx
  801181:	c1 ea 16             	shr    $0x16,%edx
  801184:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80118b:	f6 c2 01             	test   $0x1,%dl
  80118e:	74 11                	je     8011a1 <fd_alloc+0x2d>
  801190:	89 c2                	mov    %eax,%edx
  801192:	c1 ea 0c             	shr    $0xc,%edx
  801195:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80119c:	f6 c2 01             	test   $0x1,%dl
  80119f:	75 09                	jne    8011aa <fd_alloc+0x36>
			*fd_store = fd;
  8011a1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a8:	eb 17                	jmp    8011c1 <fd_alloc+0x4d>
  8011aa:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011af:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011b4:	75 c9                	jne    80117f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011b6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011bc:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011c1:	5d                   	pop    %ebp
  8011c2:	c3                   	ret    

008011c3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011c3:	55                   	push   %ebp
  8011c4:	89 e5                	mov    %esp,%ebp
  8011c6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011c9:	83 f8 1f             	cmp    $0x1f,%eax
  8011cc:	77 36                	ja     801204 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011ce:	c1 e0 0c             	shl    $0xc,%eax
  8011d1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011d6:	89 c2                	mov    %eax,%edx
  8011d8:	c1 ea 16             	shr    $0x16,%edx
  8011db:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011e2:	f6 c2 01             	test   $0x1,%dl
  8011e5:	74 24                	je     80120b <fd_lookup+0x48>
  8011e7:	89 c2                	mov    %eax,%edx
  8011e9:	c1 ea 0c             	shr    $0xc,%edx
  8011ec:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011f3:	f6 c2 01             	test   $0x1,%dl
  8011f6:	74 1a                	je     801212 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011fb:	89 02                	mov    %eax,(%edx)
	return 0;
  8011fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801202:	eb 13                	jmp    801217 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801204:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801209:	eb 0c                	jmp    801217 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80120b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801210:	eb 05                	jmp    801217 <fd_lookup+0x54>
  801212:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801217:	5d                   	pop    %ebp
  801218:	c3                   	ret    

00801219 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801219:	55                   	push   %ebp
  80121a:	89 e5                	mov    %esp,%ebp
  80121c:	83 ec 08             	sub    $0x8,%esp
  80121f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801222:	ba 18 27 80 00       	mov    $0x802718,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801227:	eb 13                	jmp    80123c <dev_lookup+0x23>
  801229:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80122c:	39 08                	cmp    %ecx,(%eax)
  80122e:	75 0c                	jne    80123c <dev_lookup+0x23>
			*dev = devtab[i];
  801230:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801233:	89 01                	mov    %eax,(%ecx)
			return 0;
  801235:	b8 00 00 00 00       	mov    $0x0,%eax
  80123a:	eb 2e                	jmp    80126a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80123c:	8b 02                	mov    (%edx),%eax
  80123e:	85 c0                	test   %eax,%eax
  801240:	75 e7                	jne    801229 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801242:	a1 04 40 80 00       	mov    0x804004,%eax
  801247:	8b 40 7c             	mov    0x7c(%eax),%eax
  80124a:	83 ec 04             	sub    $0x4,%esp
  80124d:	51                   	push   %ecx
  80124e:	50                   	push   %eax
  80124f:	68 98 26 80 00       	push   $0x802698
  801254:	e8 b8 ef ff ff       	call   800211 <cprintf>
	*dev = 0;
  801259:	8b 45 0c             	mov    0xc(%ebp),%eax
  80125c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801262:	83 c4 10             	add    $0x10,%esp
  801265:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80126a:	c9                   	leave  
  80126b:	c3                   	ret    

0080126c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80126c:	55                   	push   %ebp
  80126d:	89 e5                	mov    %esp,%ebp
  80126f:	56                   	push   %esi
  801270:	53                   	push   %ebx
  801271:	83 ec 10             	sub    $0x10,%esp
  801274:	8b 75 08             	mov    0x8(%ebp),%esi
  801277:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80127a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127d:	50                   	push   %eax
  80127e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801284:	c1 e8 0c             	shr    $0xc,%eax
  801287:	50                   	push   %eax
  801288:	e8 36 ff ff ff       	call   8011c3 <fd_lookup>
  80128d:	83 c4 08             	add    $0x8,%esp
  801290:	85 c0                	test   %eax,%eax
  801292:	78 05                	js     801299 <fd_close+0x2d>
	    || fd != fd2)
  801294:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801297:	74 0c                	je     8012a5 <fd_close+0x39>
		return (must_exist ? r : 0);
  801299:	84 db                	test   %bl,%bl
  80129b:	ba 00 00 00 00       	mov    $0x0,%edx
  8012a0:	0f 44 c2             	cmove  %edx,%eax
  8012a3:	eb 41                	jmp    8012e6 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012a5:	83 ec 08             	sub    $0x8,%esp
  8012a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ab:	50                   	push   %eax
  8012ac:	ff 36                	pushl  (%esi)
  8012ae:	e8 66 ff ff ff       	call   801219 <dev_lookup>
  8012b3:	89 c3                	mov    %eax,%ebx
  8012b5:	83 c4 10             	add    $0x10,%esp
  8012b8:	85 c0                	test   %eax,%eax
  8012ba:	78 1a                	js     8012d6 <fd_close+0x6a>
		if (dev->dev_close)
  8012bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012bf:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012c2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012c7:	85 c0                	test   %eax,%eax
  8012c9:	74 0b                	je     8012d6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012cb:	83 ec 0c             	sub    $0xc,%esp
  8012ce:	56                   	push   %esi
  8012cf:	ff d0                	call   *%eax
  8012d1:	89 c3                	mov    %eax,%ebx
  8012d3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012d6:	83 ec 08             	sub    $0x8,%esp
  8012d9:	56                   	push   %esi
  8012da:	6a 00                	push   $0x0
  8012dc:	e8 3d f9 ff ff       	call   800c1e <sys_page_unmap>
	return r;
  8012e1:	83 c4 10             	add    $0x10,%esp
  8012e4:	89 d8                	mov    %ebx,%eax
}
  8012e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012e9:	5b                   	pop    %ebx
  8012ea:	5e                   	pop    %esi
  8012eb:	5d                   	pop    %ebp
  8012ec:	c3                   	ret    

008012ed <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012ed:	55                   	push   %ebp
  8012ee:	89 e5                	mov    %esp,%ebp
  8012f0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f6:	50                   	push   %eax
  8012f7:	ff 75 08             	pushl  0x8(%ebp)
  8012fa:	e8 c4 fe ff ff       	call   8011c3 <fd_lookup>
  8012ff:	83 c4 08             	add    $0x8,%esp
  801302:	85 c0                	test   %eax,%eax
  801304:	78 10                	js     801316 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801306:	83 ec 08             	sub    $0x8,%esp
  801309:	6a 01                	push   $0x1
  80130b:	ff 75 f4             	pushl  -0xc(%ebp)
  80130e:	e8 59 ff ff ff       	call   80126c <fd_close>
  801313:	83 c4 10             	add    $0x10,%esp
}
  801316:	c9                   	leave  
  801317:	c3                   	ret    

00801318 <close_all>:

void
close_all(void)
{
  801318:	55                   	push   %ebp
  801319:	89 e5                	mov    %esp,%ebp
  80131b:	53                   	push   %ebx
  80131c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80131f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801324:	83 ec 0c             	sub    $0xc,%esp
  801327:	53                   	push   %ebx
  801328:	e8 c0 ff ff ff       	call   8012ed <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80132d:	83 c3 01             	add    $0x1,%ebx
  801330:	83 c4 10             	add    $0x10,%esp
  801333:	83 fb 20             	cmp    $0x20,%ebx
  801336:	75 ec                	jne    801324 <close_all+0xc>
		close(i);
}
  801338:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80133b:	c9                   	leave  
  80133c:	c3                   	ret    

0080133d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80133d:	55                   	push   %ebp
  80133e:	89 e5                	mov    %esp,%ebp
  801340:	57                   	push   %edi
  801341:	56                   	push   %esi
  801342:	53                   	push   %ebx
  801343:	83 ec 2c             	sub    $0x2c,%esp
  801346:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801349:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80134c:	50                   	push   %eax
  80134d:	ff 75 08             	pushl  0x8(%ebp)
  801350:	e8 6e fe ff ff       	call   8011c3 <fd_lookup>
  801355:	83 c4 08             	add    $0x8,%esp
  801358:	85 c0                	test   %eax,%eax
  80135a:	0f 88 c1 00 00 00    	js     801421 <dup+0xe4>
		return r;
	close(newfdnum);
  801360:	83 ec 0c             	sub    $0xc,%esp
  801363:	56                   	push   %esi
  801364:	e8 84 ff ff ff       	call   8012ed <close>

	newfd = INDEX2FD(newfdnum);
  801369:	89 f3                	mov    %esi,%ebx
  80136b:	c1 e3 0c             	shl    $0xc,%ebx
  80136e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801374:	83 c4 04             	add    $0x4,%esp
  801377:	ff 75 e4             	pushl  -0x1c(%ebp)
  80137a:	e8 de fd ff ff       	call   80115d <fd2data>
  80137f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801381:	89 1c 24             	mov    %ebx,(%esp)
  801384:	e8 d4 fd ff ff       	call   80115d <fd2data>
  801389:	83 c4 10             	add    $0x10,%esp
  80138c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80138f:	89 f8                	mov    %edi,%eax
  801391:	c1 e8 16             	shr    $0x16,%eax
  801394:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80139b:	a8 01                	test   $0x1,%al
  80139d:	74 37                	je     8013d6 <dup+0x99>
  80139f:	89 f8                	mov    %edi,%eax
  8013a1:	c1 e8 0c             	shr    $0xc,%eax
  8013a4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013ab:	f6 c2 01             	test   $0x1,%dl
  8013ae:	74 26                	je     8013d6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013b0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013b7:	83 ec 0c             	sub    $0xc,%esp
  8013ba:	25 07 0e 00 00       	and    $0xe07,%eax
  8013bf:	50                   	push   %eax
  8013c0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013c3:	6a 00                	push   $0x0
  8013c5:	57                   	push   %edi
  8013c6:	6a 00                	push   $0x0
  8013c8:	e8 0f f8 ff ff       	call   800bdc <sys_page_map>
  8013cd:	89 c7                	mov    %eax,%edi
  8013cf:	83 c4 20             	add    $0x20,%esp
  8013d2:	85 c0                	test   %eax,%eax
  8013d4:	78 2e                	js     801404 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013d6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013d9:	89 d0                	mov    %edx,%eax
  8013db:	c1 e8 0c             	shr    $0xc,%eax
  8013de:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013e5:	83 ec 0c             	sub    $0xc,%esp
  8013e8:	25 07 0e 00 00       	and    $0xe07,%eax
  8013ed:	50                   	push   %eax
  8013ee:	53                   	push   %ebx
  8013ef:	6a 00                	push   $0x0
  8013f1:	52                   	push   %edx
  8013f2:	6a 00                	push   $0x0
  8013f4:	e8 e3 f7 ff ff       	call   800bdc <sys_page_map>
  8013f9:	89 c7                	mov    %eax,%edi
  8013fb:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013fe:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801400:	85 ff                	test   %edi,%edi
  801402:	79 1d                	jns    801421 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801404:	83 ec 08             	sub    $0x8,%esp
  801407:	53                   	push   %ebx
  801408:	6a 00                	push   $0x0
  80140a:	e8 0f f8 ff ff       	call   800c1e <sys_page_unmap>
	sys_page_unmap(0, nva);
  80140f:	83 c4 08             	add    $0x8,%esp
  801412:	ff 75 d4             	pushl  -0x2c(%ebp)
  801415:	6a 00                	push   $0x0
  801417:	e8 02 f8 ff ff       	call   800c1e <sys_page_unmap>
	return r;
  80141c:	83 c4 10             	add    $0x10,%esp
  80141f:	89 f8                	mov    %edi,%eax
}
  801421:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801424:	5b                   	pop    %ebx
  801425:	5e                   	pop    %esi
  801426:	5f                   	pop    %edi
  801427:	5d                   	pop    %ebp
  801428:	c3                   	ret    

00801429 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801429:	55                   	push   %ebp
  80142a:	89 e5                	mov    %esp,%ebp
  80142c:	53                   	push   %ebx
  80142d:	83 ec 14             	sub    $0x14,%esp
  801430:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801433:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801436:	50                   	push   %eax
  801437:	53                   	push   %ebx
  801438:	e8 86 fd ff ff       	call   8011c3 <fd_lookup>
  80143d:	83 c4 08             	add    $0x8,%esp
  801440:	89 c2                	mov    %eax,%edx
  801442:	85 c0                	test   %eax,%eax
  801444:	78 6d                	js     8014b3 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801446:	83 ec 08             	sub    $0x8,%esp
  801449:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80144c:	50                   	push   %eax
  80144d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801450:	ff 30                	pushl  (%eax)
  801452:	e8 c2 fd ff ff       	call   801219 <dev_lookup>
  801457:	83 c4 10             	add    $0x10,%esp
  80145a:	85 c0                	test   %eax,%eax
  80145c:	78 4c                	js     8014aa <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80145e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801461:	8b 42 08             	mov    0x8(%edx),%eax
  801464:	83 e0 03             	and    $0x3,%eax
  801467:	83 f8 01             	cmp    $0x1,%eax
  80146a:	75 21                	jne    80148d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80146c:	a1 04 40 80 00       	mov    0x804004,%eax
  801471:	8b 40 7c             	mov    0x7c(%eax),%eax
  801474:	83 ec 04             	sub    $0x4,%esp
  801477:	53                   	push   %ebx
  801478:	50                   	push   %eax
  801479:	68 dc 26 80 00       	push   $0x8026dc
  80147e:	e8 8e ed ff ff       	call   800211 <cprintf>
		return -E_INVAL;
  801483:	83 c4 10             	add    $0x10,%esp
  801486:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80148b:	eb 26                	jmp    8014b3 <read+0x8a>
	}
	if (!dev->dev_read)
  80148d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801490:	8b 40 08             	mov    0x8(%eax),%eax
  801493:	85 c0                	test   %eax,%eax
  801495:	74 17                	je     8014ae <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801497:	83 ec 04             	sub    $0x4,%esp
  80149a:	ff 75 10             	pushl  0x10(%ebp)
  80149d:	ff 75 0c             	pushl  0xc(%ebp)
  8014a0:	52                   	push   %edx
  8014a1:	ff d0                	call   *%eax
  8014a3:	89 c2                	mov    %eax,%edx
  8014a5:	83 c4 10             	add    $0x10,%esp
  8014a8:	eb 09                	jmp    8014b3 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014aa:	89 c2                	mov    %eax,%edx
  8014ac:	eb 05                	jmp    8014b3 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014ae:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8014b3:	89 d0                	mov    %edx,%eax
  8014b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014b8:	c9                   	leave  
  8014b9:	c3                   	ret    

008014ba <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014ba:	55                   	push   %ebp
  8014bb:	89 e5                	mov    %esp,%ebp
  8014bd:	57                   	push   %edi
  8014be:	56                   	push   %esi
  8014bf:	53                   	push   %ebx
  8014c0:	83 ec 0c             	sub    $0xc,%esp
  8014c3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014c6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014c9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014ce:	eb 21                	jmp    8014f1 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014d0:	83 ec 04             	sub    $0x4,%esp
  8014d3:	89 f0                	mov    %esi,%eax
  8014d5:	29 d8                	sub    %ebx,%eax
  8014d7:	50                   	push   %eax
  8014d8:	89 d8                	mov    %ebx,%eax
  8014da:	03 45 0c             	add    0xc(%ebp),%eax
  8014dd:	50                   	push   %eax
  8014de:	57                   	push   %edi
  8014df:	e8 45 ff ff ff       	call   801429 <read>
		if (m < 0)
  8014e4:	83 c4 10             	add    $0x10,%esp
  8014e7:	85 c0                	test   %eax,%eax
  8014e9:	78 10                	js     8014fb <readn+0x41>
			return m;
		if (m == 0)
  8014eb:	85 c0                	test   %eax,%eax
  8014ed:	74 0a                	je     8014f9 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ef:	01 c3                	add    %eax,%ebx
  8014f1:	39 f3                	cmp    %esi,%ebx
  8014f3:	72 db                	jb     8014d0 <readn+0x16>
  8014f5:	89 d8                	mov    %ebx,%eax
  8014f7:	eb 02                	jmp    8014fb <readn+0x41>
  8014f9:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014fe:	5b                   	pop    %ebx
  8014ff:	5e                   	pop    %esi
  801500:	5f                   	pop    %edi
  801501:	5d                   	pop    %ebp
  801502:	c3                   	ret    

00801503 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801503:	55                   	push   %ebp
  801504:	89 e5                	mov    %esp,%ebp
  801506:	53                   	push   %ebx
  801507:	83 ec 14             	sub    $0x14,%esp
  80150a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80150d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801510:	50                   	push   %eax
  801511:	53                   	push   %ebx
  801512:	e8 ac fc ff ff       	call   8011c3 <fd_lookup>
  801517:	83 c4 08             	add    $0x8,%esp
  80151a:	89 c2                	mov    %eax,%edx
  80151c:	85 c0                	test   %eax,%eax
  80151e:	78 68                	js     801588 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801520:	83 ec 08             	sub    $0x8,%esp
  801523:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801526:	50                   	push   %eax
  801527:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152a:	ff 30                	pushl  (%eax)
  80152c:	e8 e8 fc ff ff       	call   801219 <dev_lookup>
  801531:	83 c4 10             	add    $0x10,%esp
  801534:	85 c0                	test   %eax,%eax
  801536:	78 47                	js     80157f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801538:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80153f:	75 21                	jne    801562 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801541:	a1 04 40 80 00       	mov    0x804004,%eax
  801546:	8b 40 7c             	mov    0x7c(%eax),%eax
  801549:	83 ec 04             	sub    $0x4,%esp
  80154c:	53                   	push   %ebx
  80154d:	50                   	push   %eax
  80154e:	68 f8 26 80 00       	push   $0x8026f8
  801553:	e8 b9 ec ff ff       	call   800211 <cprintf>
		return -E_INVAL;
  801558:	83 c4 10             	add    $0x10,%esp
  80155b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801560:	eb 26                	jmp    801588 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801562:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801565:	8b 52 0c             	mov    0xc(%edx),%edx
  801568:	85 d2                	test   %edx,%edx
  80156a:	74 17                	je     801583 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80156c:	83 ec 04             	sub    $0x4,%esp
  80156f:	ff 75 10             	pushl  0x10(%ebp)
  801572:	ff 75 0c             	pushl  0xc(%ebp)
  801575:	50                   	push   %eax
  801576:	ff d2                	call   *%edx
  801578:	89 c2                	mov    %eax,%edx
  80157a:	83 c4 10             	add    $0x10,%esp
  80157d:	eb 09                	jmp    801588 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157f:	89 c2                	mov    %eax,%edx
  801581:	eb 05                	jmp    801588 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801583:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801588:	89 d0                	mov    %edx,%eax
  80158a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80158d:	c9                   	leave  
  80158e:	c3                   	ret    

0080158f <seek>:

int
seek(int fdnum, off_t offset)
{
  80158f:	55                   	push   %ebp
  801590:	89 e5                	mov    %esp,%ebp
  801592:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801595:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801598:	50                   	push   %eax
  801599:	ff 75 08             	pushl  0x8(%ebp)
  80159c:	e8 22 fc ff ff       	call   8011c3 <fd_lookup>
  8015a1:	83 c4 08             	add    $0x8,%esp
  8015a4:	85 c0                	test   %eax,%eax
  8015a6:	78 0e                	js     8015b6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015ae:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015b6:	c9                   	leave  
  8015b7:	c3                   	ret    

008015b8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015b8:	55                   	push   %ebp
  8015b9:	89 e5                	mov    %esp,%ebp
  8015bb:	53                   	push   %ebx
  8015bc:	83 ec 14             	sub    $0x14,%esp
  8015bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c5:	50                   	push   %eax
  8015c6:	53                   	push   %ebx
  8015c7:	e8 f7 fb ff ff       	call   8011c3 <fd_lookup>
  8015cc:	83 c4 08             	add    $0x8,%esp
  8015cf:	89 c2                	mov    %eax,%edx
  8015d1:	85 c0                	test   %eax,%eax
  8015d3:	78 65                	js     80163a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d5:	83 ec 08             	sub    $0x8,%esp
  8015d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015db:	50                   	push   %eax
  8015dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015df:	ff 30                	pushl  (%eax)
  8015e1:	e8 33 fc ff ff       	call   801219 <dev_lookup>
  8015e6:	83 c4 10             	add    $0x10,%esp
  8015e9:	85 c0                	test   %eax,%eax
  8015eb:	78 44                	js     801631 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015f4:	75 21                	jne    801617 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015f6:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015fb:	8b 40 7c             	mov    0x7c(%eax),%eax
  8015fe:	83 ec 04             	sub    $0x4,%esp
  801601:	53                   	push   %ebx
  801602:	50                   	push   %eax
  801603:	68 b8 26 80 00       	push   $0x8026b8
  801608:	e8 04 ec ff ff       	call   800211 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80160d:	83 c4 10             	add    $0x10,%esp
  801610:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801615:	eb 23                	jmp    80163a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801617:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80161a:	8b 52 18             	mov    0x18(%edx),%edx
  80161d:	85 d2                	test   %edx,%edx
  80161f:	74 14                	je     801635 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801621:	83 ec 08             	sub    $0x8,%esp
  801624:	ff 75 0c             	pushl  0xc(%ebp)
  801627:	50                   	push   %eax
  801628:	ff d2                	call   *%edx
  80162a:	89 c2                	mov    %eax,%edx
  80162c:	83 c4 10             	add    $0x10,%esp
  80162f:	eb 09                	jmp    80163a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801631:	89 c2                	mov    %eax,%edx
  801633:	eb 05                	jmp    80163a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801635:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80163a:	89 d0                	mov    %edx,%eax
  80163c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163f:	c9                   	leave  
  801640:	c3                   	ret    

00801641 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801641:	55                   	push   %ebp
  801642:	89 e5                	mov    %esp,%ebp
  801644:	53                   	push   %ebx
  801645:	83 ec 14             	sub    $0x14,%esp
  801648:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80164b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164e:	50                   	push   %eax
  80164f:	ff 75 08             	pushl  0x8(%ebp)
  801652:	e8 6c fb ff ff       	call   8011c3 <fd_lookup>
  801657:	83 c4 08             	add    $0x8,%esp
  80165a:	89 c2                	mov    %eax,%edx
  80165c:	85 c0                	test   %eax,%eax
  80165e:	78 58                	js     8016b8 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801660:	83 ec 08             	sub    $0x8,%esp
  801663:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801666:	50                   	push   %eax
  801667:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166a:	ff 30                	pushl  (%eax)
  80166c:	e8 a8 fb ff ff       	call   801219 <dev_lookup>
  801671:	83 c4 10             	add    $0x10,%esp
  801674:	85 c0                	test   %eax,%eax
  801676:	78 37                	js     8016af <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801678:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80167b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80167f:	74 32                	je     8016b3 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801681:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801684:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80168b:	00 00 00 
	stat->st_isdir = 0;
  80168e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801695:	00 00 00 
	stat->st_dev = dev;
  801698:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80169e:	83 ec 08             	sub    $0x8,%esp
  8016a1:	53                   	push   %ebx
  8016a2:	ff 75 f0             	pushl  -0x10(%ebp)
  8016a5:	ff 50 14             	call   *0x14(%eax)
  8016a8:	89 c2                	mov    %eax,%edx
  8016aa:	83 c4 10             	add    $0x10,%esp
  8016ad:	eb 09                	jmp    8016b8 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016af:	89 c2                	mov    %eax,%edx
  8016b1:	eb 05                	jmp    8016b8 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016b3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016b8:	89 d0                	mov    %edx,%eax
  8016ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016bd:	c9                   	leave  
  8016be:	c3                   	ret    

008016bf <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	56                   	push   %esi
  8016c3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016c4:	83 ec 08             	sub    $0x8,%esp
  8016c7:	6a 00                	push   $0x0
  8016c9:	ff 75 08             	pushl  0x8(%ebp)
  8016cc:	e8 e3 01 00 00       	call   8018b4 <open>
  8016d1:	89 c3                	mov    %eax,%ebx
  8016d3:	83 c4 10             	add    $0x10,%esp
  8016d6:	85 c0                	test   %eax,%eax
  8016d8:	78 1b                	js     8016f5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016da:	83 ec 08             	sub    $0x8,%esp
  8016dd:	ff 75 0c             	pushl  0xc(%ebp)
  8016e0:	50                   	push   %eax
  8016e1:	e8 5b ff ff ff       	call   801641 <fstat>
  8016e6:	89 c6                	mov    %eax,%esi
	close(fd);
  8016e8:	89 1c 24             	mov    %ebx,(%esp)
  8016eb:	e8 fd fb ff ff       	call   8012ed <close>
	return r;
  8016f0:	83 c4 10             	add    $0x10,%esp
  8016f3:	89 f0                	mov    %esi,%eax
}
  8016f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016f8:	5b                   	pop    %ebx
  8016f9:	5e                   	pop    %esi
  8016fa:	5d                   	pop    %ebp
  8016fb:	c3                   	ret    

008016fc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016fc:	55                   	push   %ebp
  8016fd:	89 e5                	mov    %esp,%ebp
  8016ff:	56                   	push   %esi
  801700:	53                   	push   %ebx
  801701:	89 c6                	mov    %eax,%esi
  801703:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801705:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80170c:	75 12                	jne    801720 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80170e:	83 ec 0c             	sub    $0xc,%esp
  801711:	6a 01                	push   $0x1
  801713:	e8 05 08 00 00       	call   801f1d <ipc_find_env>
  801718:	a3 00 40 80 00       	mov    %eax,0x804000
  80171d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801720:	6a 07                	push   $0x7
  801722:	68 00 50 80 00       	push   $0x805000
  801727:	56                   	push   %esi
  801728:	ff 35 00 40 80 00    	pushl  0x804000
  80172e:	e8 88 07 00 00       	call   801ebb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801733:	83 c4 0c             	add    $0xc,%esp
  801736:	6a 00                	push   $0x0
  801738:	53                   	push   %ebx
  801739:	6a 00                	push   $0x0
  80173b:	e8 00 07 00 00       	call   801e40 <ipc_recv>
}
  801740:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801743:	5b                   	pop    %ebx
  801744:	5e                   	pop    %esi
  801745:	5d                   	pop    %ebp
  801746:	c3                   	ret    

00801747 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801747:	55                   	push   %ebp
  801748:	89 e5                	mov    %esp,%ebp
  80174a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80174d:	8b 45 08             	mov    0x8(%ebp),%eax
  801750:	8b 40 0c             	mov    0xc(%eax),%eax
  801753:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801758:	8b 45 0c             	mov    0xc(%ebp),%eax
  80175b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801760:	ba 00 00 00 00       	mov    $0x0,%edx
  801765:	b8 02 00 00 00       	mov    $0x2,%eax
  80176a:	e8 8d ff ff ff       	call   8016fc <fsipc>
}
  80176f:	c9                   	leave  
  801770:	c3                   	ret    

00801771 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801771:	55                   	push   %ebp
  801772:	89 e5                	mov    %esp,%ebp
  801774:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801777:	8b 45 08             	mov    0x8(%ebp),%eax
  80177a:	8b 40 0c             	mov    0xc(%eax),%eax
  80177d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801782:	ba 00 00 00 00       	mov    $0x0,%edx
  801787:	b8 06 00 00 00       	mov    $0x6,%eax
  80178c:	e8 6b ff ff ff       	call   8016fc <fsipc>
}
  801791:	c9                   	leave  
  801792:	c3                   	ret    

00801793 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801793:	55                   	push   %ebp
  801794:	89 e5                	mov    %esp,%ebp
  801796:	53                   	push   %ebx
  801797:	83 ec 04             	sub    $0x4,%esp
  80179a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80179d:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ad:	b8 05 00 00 00       	mov    $0x5,%eax
  8017b2:	e8 45 ff ff ff       	call   8016fc <fsipc>
  8017b7:	85 c0                	test   %eax,%eax
  8017b9:	78 2c                	js     8017e7 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017bb:	83 ec 08             	sub    $0x8,%esp
  8017be:	68 00 50 80 00       	push   $0x805000
  8017c3:	53                   	push   %ebx
  8017c4:	e8 cd ef ff ff       	call   800796 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017c9:	a1 80 50 80 00       	mov    0x805080,%eax
  8017ce:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017d4:	a1 84 50 80 00       	mov    0x805084,%eax
  8017d9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017df:	83 c4 10             	add    $0x10,%esp
  8017e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ea:	c9                   	leave  
  8017eb:	c3                   	ret    

008017ec <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017ec:	55                   	push   %ebp
  8017ed:	89 e5                	mov    %esp,%ebp
  8017ef:	83 ec 0c             	sub    $0xc,%esp
  8017f2:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8017f8:	8b 52 0c             	mov    0xc(%edx),%edx
  8017fb:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801801:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801806:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80180b:	0f 47 c2             	cmova  %edx,%eax
  80180e:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801813:	50                   	push   %eax
  801814:	ff 75 0c             	pushl  0xc(%ebp)
  801817:	68 08 50 80 00       	push   $0x805008
  80181c:	e8 07 f1 ff ff       	call   800928 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801821:	ba 00 00 00 00       	mov    $0x0,%edx
  801826:	b8 04 00 00 00       	mov    $0x4,%eax
  80182b:	e8 cc fe ff ff       	call   8016fc <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801830:	c9                   	leave  
  801831:	c3                   	ret    

00801832 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801832:	55                   	push   %ebp
  801833:	89 e5                	mov    %esp,%ebp
  801835:	56                   	push   %esi
  801836:	53                   	push   %ebx
  801837:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80183a:	8b 45 08             	mov    0x8(%ebp),%eax
  80183d:	8b 40 0c             	mov    0xc(%eax),%eax
  801840:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801845:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80184b:	ba 00 00 00 00       	mov    $0x0,%edx
  801850:	b8 03 00 00 00       	mov    $0x3,%eax
  801855:	e8 a2 fe ff ff       	call   8016fc <fsipc>
  80185a:	89 c3                	mov    %eax,%ebx
  80185c:	85 c0                	test   %eax,%eax
  80185e:	78 4b                	js     8018ab <devfile_read+0x79>
		return r;
	assert(r <= n);
  801860:	39 c6                	cmp    %eax,%esi
  801862:	73 16                	jae    80187a <devfile_read+0x48>
  801864:	68 28 27 80 00       	push   $0x802728
  801869:	68 2f 27 80 00       	push   $0x80272f
  80186e:	6a 7c                	push   $0x7c
  801870:	68 44 27 80 00       	push   $0x802744
  801875:	e8 be e8 ff ff       	call   800138 <_panic>
	assert(r <= PGSIZE);
  80187a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80187f:	7e 16                	jle    801897 <devfile_read+0x65>
  801881:	68 4f 27 80 00       	push   $0x80274f
  801886:	68 2f 27 80 00       	push   $0x80272f
  80188b:	6a 7d                	push   $0x7d
  80188d:	68 44 27 80 00       	push   $0x802744
  801892:	e8 a1 e8 ff ff       	call   800138 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801897:	83 ec 04             	sub    $0x4,%esp
  80189a:	50                   	push   %eax
  80189b:	68 00 50 80 00       	push   $0x805000
  8018a0:	ff 75 0c             	pushl  0xc(%ebp)
  8018a3:	e8 80 f0 ff ff       	call   800928 <memmove>
	return r;
  8018a8:	83 c4 10             	add    $0x10,%esp
}
  8018ab:	89 d8                	mov    %ebx,%eax
  8018ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b0:	5b                   	pop    %ebx
  8018b1:	5e                   	pop    %esi
  8018b2:	5d                   	pop    %ebp
  8018b3:	c3                   	ret    

008018b4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018b4:	55                   	push   %ebp
  8018b5:	89 e5                	mov    %esp,%ebp
  8018b7:	53                   	push   %ebx
  8018b8:	83 ec 20             	sub    $0x20,%esp
  8018bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018be:	53                   	push   %ebx
  8018bf:	e8 99 ee ff ff       	call   80075d <strlen>
  8018c4:	83 c4 10             	add    $0x10,%esp
  8018c7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018cc:	7f 67                	jg     801935 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018ce:	83 ec 0c             	sub    $0xc,%esp
  8018d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d4:	50                   	push   %eax
  8018d5:	e8 9a f8 ff ff       	call   801174 <fd_alloc>
  8018da:	83 c4 10             	add    $0x10,%esp
		return r;
  8018dd:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018df:	85 c0                	test   %eax,%eax
  8018e1:	78 57                	js     80193a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018e3:	83 ec 08             	sub    $0x8,%esp
  8018e6:	53                   	push   %ebx
  8018e7:	68 00 50 80 00       	push   $0x805000
  8018ec:	e8 a5 ee ff ff       	call   800796 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018f4:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018fc:	b8 01 00 00 00       	mov    $0x1,%eax
  801901:	e8 f6 fd ff ff       	call   8016fc <fsipc>
  801906:	89 c3                	mov    %eax,%ebx
  801908:	83 c4 10             	add    $0x10,%esp
  80190b:	85 c0                	test   %eax,%eax
  80190d:	79 14                	jns    801923 <open+0x6f>
		fd_close(fd, 0);
  80190f:	83 ec 08             	sub    $0x8,%esp
  801912:	6a 00                	push   $0x0
  801914:	ff 75 f4             	pushl  -0xc(%ebp)
  801917:	e8 50 f9 ff ff       	call   80126c <fd_close>
		return r;
  80191c:	83 c4 10             	add    $0x10,%esp
  80191f:	89 da                	mov    %ebx,%edx
  801921:	eb 17                	jmp    80193a <open+0x86>
	}

	return fd2num(fd);
  801923:	83 ec 0c             	sub    $0xc,%esp
  801926:	ff 75 f4             	pushl  -0xc(%ebp)
  801929:	e8 1f f8 ff ff       	call   80114d <fd2num>
  80192e:	89 c2                	mov    %eax,%edx
  801930:	83 c4 10             	add    $0x10,%esp
  801933:	eb 05                	jmp    80193a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801935:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80193a:	89 d0                	mov    %edx,%eax
  80193c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80193f:	c9                   	leave  
  801940:	c3                   	ret    

00801941 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801941:	55                   	push   %ebp
  801942:	89 e5                	mov    %esp,%ebp
  801944:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801947:	ba 00 00 00 00       	mov    $0x0,%edx
  80194c:	b8 08 00 00 00       	mov    $0x8,%eax
  801951:	e8 a6 fd ff ff       	call   8016fc <fsipc>
}
  801956:	c9                   	leave  
  801957:	c3                   	ret    

00801958 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801958:	55                   	push   %ebp
  801959:	89 e5                	mov    %esp,%ebp
  80195b:	56                   	push   %esi
  80195c:	53                   	push   %ebx
  80195d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801960:	83 ec 0c             	sub    $0xc,%esp
  801963:	ff 75 08             	pushl  0x8(%ebp)
  801966:	e8 f2 f7 ff ff       	call   80115d <fd2data>
  80196b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80196d:	83 c4 08             	add    $0x8,%esp
  801970:	68 5b 27 80 00       	push   $0x80275b
  801975:	53                   	push   %ebx
  801976:	e8 1b ee ff ff       	call   800796 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80197b:	8b 46 04             	mov    0x4(%esi),%eax
  80197e:	2b 06                	sub    (%esi),%eax
  801980:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801986:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80198d:	00 00 00 
	stat->st_dev = &devpipe;
  801990:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801997:	30 80 00 
	return 0;
}
  80199a:	b8 00 00 00 00       	mov    $0x0,%eax
  80199f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a2:	5b                   	pop    %ebx
  8019a3:	5e                   	pop    %esi
  8019a4:	5d                   	pop    %ebp
  8019a5:	c3                   	ret    

008019a6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019a6:	55                   	push   %ebp
  8019a7:	89 e5                	mov    %esp,%ebp
  8019a9:	53                   	push   %ebx
  8019aa:	83 ec 0c             	sub    $0xc,%esp
  8019ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019b0:	53                   	push   %ebx
  8019b1:	6a 00                	push   $0x0
  8019b3:	e8 66 f2 ff ff       	call   800c1e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019b8:	89 1c 24             	mov    %ebx,(%esp)
  8019bb:	e8 9d f7 ff ff       	call   80115d <fd2data>
  8019c0:	83 c4 08             	add    $0x8,%esp
  8019c3:	50                   	push   %eax
  8019c4:	6a 00                	push   $0x0
  8019c6:	e8 53 f2 ff ff       	call   800c1e <sys_page_unmap>
}
  8019cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ce:	c9                   	leave  
  8019cf:	c3                   	ret    

008019d0 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019d0:	55                   	push   %ebp
  8019d1:	89 e5                	mov    %esp,%ebp
  8019d3:	57                   	push   %edi
  8019d4:	56                   	push   %esi
  8019d5:	53                   	push   %ebx
  8019d6:	83 ec 1c             	sub    $0x1c,%esp
  8019d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019dc:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019de:	a1 04 40 80 00       	mov    0x804004,%eax
  8019e3:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019e9:	83 ec 0c             	sub    $0xc,%esp
  8019ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8019ef:	e8 6b 05 00 00       	call   801f5f <pageref>
  8019f4:	89 c3                	mov    %eax,%ebx
  8019f6:	89 3c 24             	mov    %edi,(%esp)
  8019f9:	e8 61 05 00 00       	call   801f5f <pageref>
  8019fe:	83 c4 10             	add    $0x10,%esp
  801a01:	39 c3                	cmp    %eax,%ebx
  801a03:	0f 94 c1             	sete   %cl
  801a06:	0f b6 c9             	movzbl %cl,%ecx
  801a09:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a0c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a12:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  801a18:	39 ce                	cmp    %ecx,%esi
  801a1a:	74 1e                	je     801a3a <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801a1c:	39 c3                	cmp    %eax,%ebx
  801a1e:	75 be                	jne    8019de <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a20:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  801a26:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a29:	50                   	push   %eax
  801a2a:	56                   	push   %esi
  801a2b:	68 62 27 80 00       	push   $0x802762
  801a30:	e8 dc e7 ff ff       	call   800211 <cprintf>
  801a35:	83 c4 10             	add    $0x10,%esp
  801a38:	eb a4                	jmp    8019de <_pipeisclosed+0xe>
	}
}
  801a3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a40:	5b                   	pop    %ebx
  801a41:	5e                   	pop    %esi
  801a42:	5f                   	pop    %edi
  801a43:	5d                   	pop    %ebp
  801a44:	c3                   	ret    

00801a45 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a45:	55                   	push   %ebp
  801a46:	89 e5                	mov    %esp,%ebp
  801a48:	57                   	push   %edi
  801a49:	56                   	push   %esi
  801a4a:	53                   	push   %ebx
  801a4b:	83 ec 28             	sub    $0x28,%esp
  801a4e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a51:	56                   	push   %esi
  801a52:	e8 06 f7 ff ff       	call   80115d <fd2data>
  801a57:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a59:	83 c4 10             	add    $0x10,%esp
  801a5c:	bf 00 00 00 00       	mov    $0x0,%edi
  801a61:	eb 4b                	jmp    801aae <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a63:	89 da                	mov    %ebx,%edx
  801a65:	89 f0                	mov    %esi,%eax
  801a67:	e8 64 ff ff ff       	call   8019d0 <_pipeisclosed>
  801a6c:	85 c0                	test   %eax,%eax
  801a6e:	75 48                	jne    801ab8 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a70:	e8 05 f1 ff ff       	call   800b7a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a75:	8b 43 04             	mov    0x4(%ebx),%eax
  801a78:	8b 0b                	mov    (%ebx),%ecx
  801a7a:	8d 51 20             	lea    0x20(%ecx),%edx
  801a7d:	39 d0                	cmp    %edx,%eax
  801a7f:	73 e2                	jae    801a63 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a84:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a88:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a8b:	89 c2                	mov    %eax,%edx
  801a8d:	c1 fa 1f             	sar    $0x1f,%edx
  801a90:	89 d1                	mov    %edx,%ecx
  801a92:	c1 e9 1b             	shr    $0x1b,%ecx
  801a95:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a98:	83 e2 1f             	and    $0x1f,%edx
  801a9b:	29 ca                	sub    %ecx,%edx
  801a9d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801aa1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801aa5:	83 c0 01             	add    $0x1,%eax
  801aa8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aab:	83 c7 01             	add    $0x1,%edi
  801aae:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ab1:	75 c2                	jne    801a75 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ab3:	8b 45 10             	mov    0x10(%ebp),%eax
  801ab6:	eb 05                	jmp    801abd <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ab8:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801abd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac0:	5b                   	pop    %ebx
  801ac1:	5e                   	pop    %esi
  801ac2:	5f                   	pop    %edi
  801ac3:	5d                   	pop    %ebp
  801ac4:	c3                   	ret    

00801ac5 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ac5:	55                   	push   %ebp
  801ac6:	89 e5                	mov    %esp,%ebp
  801ac8:	57                   	push   %edi
  801ac9:	56                   	push   %esi
  801aca:	53                   	push   %ebx
  801acb:	83 ec 18             	sub    $0x18,%esp
  801ace:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ad1:	57                   	push   %edi
  801ad2:	e8 86 f6 ff ff       	call   80115d <fd2data>
  801ad7:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ad9:	83 c4 10             	add    $0x10,%esp
  801adc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ae1:	eb 3d                	jmp    801b20 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ae3:	85 db                	test   %ebx,%ebx
  801ae5:	74 04                	je     801aeb <devpipe_read+0x26>
				return i;
  801ae7:	89 d8                	mov    %ebx,%eax
  801ae9:	eb 44                	jmp    801b2f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801aeb:	89 f2                	mov    %esi,%edx
  801aed:	89 f8                	mov    %edi,%eax
  801aef:	e8 dc fe ff ff       	call   8019d0 <_pipeisclosed>
  801af4:	85 c0                	test   %eax,%eax
  801af6:	75 32                	jne    801b2a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801af8:	e8 7d f0 ff ff       	call   800b7a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801afd:	8b 06                	mov    (%esi),%eax
  801aff:	3b 46 04             	cmp    0x4(%esi),%eax
  801b02:	74 df                	je     801ae3 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b04:	99                   	cltd   
  801b05:	c1 ea 1b             	shr    $0x1b,%edx
  801b08:	01 d0                	add    %edx,%eax
  801b0a:	83 e0 1f             	and    $0x1f,%eax
  801b0d:	29 d0                	sub    %edx,%eax
  801b0f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b17:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b1a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b1d:	83 c3 01             	add    $0x1,%ebx
  801b20:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b23:	75 d8                	jne    801afd <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b25:	8b 45 10             	mov    0x10(%ebp),%eax
  801b28:	eb 05                	jmp    801b2f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b2a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b32:	5b                   	pop    %ebx
  801b33:	5e                   	pop    %esi
  801b34:	5f                   	pop    %edi
  801b35:	5d                   	pop    %ebp
  801b36:	c3                   	ret    

00801b37 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b37:	55                   	push   %ebp
  801b38:	89 e5                	mov    %esp,%ebp
  801b3a:	56                   	push   %esi
  801b3b:	53                   	push   %ebx
  801b3c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b3f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b42:	50                   	push   %eax
  801b43:	e8 2c f6 ff ff       	call   801174 <fd_alloc>
  801b48:	83 c4 10             	add    $0x10,%esp
  801b4b:	89 c2                	mov    %eax,%edx
  801b4d:	85 c0                	test   %eax,%eax
  801b4f:	0f 88 2c 01 00 00    	js     801c81 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b55:	83 ec 04             	sub    $0x4,%esp
  801b58:	68 07 04 00 00       	push   $0x407
  801b5d:	ff 75 f4             	pushl  -0xc(%ebp)
  801b60:	6a 00                	push   $0x0
  801b62:	e8 32 f0 ff ff       	call   800b99 <sys_page_alloc>
  801b67:	83 c4 10             	add    $0x10,%esp
  801b6a:	89 c2                	mov    %eax,%edx
  801b6c:	85 c0                	test   %eax,%eax
  801b6e:	0f 88 0d 01 00 00    	js     801c81 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b74:	83 ec 0c             	sub    $0xc,%esp
  801b77:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b7a:	50                   	push   %eax
  801b7b:	e8 f4 f5 ff ff       	call   801174 <fd_alloc>
  801b80:	89 c3                	mov    %eax,%ebx
  801b82:	83 c4 10             	add    $0x10,%esp
  801b85:	85 c0                	test   %eax,%eax
  801b87:	0f 88 e2 00 00 00    	js     801c6f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b8d:	83 ec 04             	sub    $0x4,%esp
  801b90:	68 07 04 00 00       	push   $0x407
  801b95:	ff 75 f0             	pushl  -0x10(%ebp)
  801b98:	6a 00                	push   $0x0
  801b9a:	e8 fa ef ff ff       	call   800b99 <sys_page_alloc>
  801b9f:	89 c3                	mov    %eax,%ebx
  801ba1:	83 c4 10             	add    $0x10,%esp
  801ba4:	85 c0                	test   %eax,%eax
  801ba6:	0f 88 c3 00 00 00    	js     801c6f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bac:	83 ec 0c             	sub    $0xc,%esp
  801baf:	ff 75 f4             	pushl  -0xc(%ebp)
  801bb2:	e8 a6 f5 ff ff       	call   80115d <fd2data>
  801bb7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb9:	83 c4 0c             	add    $0xc,%esp
  801bbc:	68 07 04 00 00       	push   $0x407
  801bc1:	50                   	push   %eax
  801bc2:	6a 00                	push   $0x0
  801bc4:	e8 d0 ef ff ff       	call   800b99 <sys_page_alloc>
  801bc9:	89 c3                	mov    %eax,%ebx
  801bcb:	83 c4 10             	add    $0x10,%esp
  801bce:	85 c0                	test   %eax,%eax
  801bd0:	0f 88 89 00 00 00    	js     801c5f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bd6:	83 ec 0c             	sub    $0xc,%esp
  801bd9:	ff 75 f0             	pushl  -0x10(%ebp)
  801bdc:	e8 7c f5 ff ff       	call   80115d <fd2data>
  801be1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801be8:	50                   	push   %eax
  801be9:	6a 00                	push   $0x0
  801beb:	56                   	push   %esi
  801bec:	6a 00                	push   $0x0
  801bee:	e8 e9 ef ff ff       	call   800bdc <sys_page_map>
  801bf3:	89 c3                	mov    %eax,%ebx
  801bf5:	83 c4 20             	add    $0x20,%esp
  801bf8:	85 c0                	test   %eax,%eax
  801bfa:	78 55                	js     801c51 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bfc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c05:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c0a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c11:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c17:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c1a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c1f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c26:	83 ec 0c             	sub    $0xc,%esp
  801c29:	ff 75 f4             	pushl  -0xc(%ebp)
  801c2c:	e8 1c f5 ff ff       	call   80114d <fd2num>
  801c31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c34:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c36:	83 c4 04             	add    $0x4,%esp
  801c39:	ff 75 f0             	pushl  -0x10(%ebp)
  801c3c:	e8 0c f5 ff ff       	call   80114d <fd2num>
  801c41:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c44:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801c47:	83 c4 10             	add    $0x10,%esp
  801c4a:	ba 00 00 00 00       	mov    $0x0,%edx
  801c4f:	eb 30                	jmp    801c81 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c51:	83 ec 08             	sub    $0x8,%esp
  801c54:	56                   	push   %esi
  801c55:	6a 00                	push   $0x0
  801c57:	e8 c2 ef ff ff       	call   800c1e <sys_page_unmap>
  801c5c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c5f:	83 ec 08             	sub    $0x8,%esp
  801c62:	ff 75 f0             	pushl  -0x10(%ebp)
  801c65:	6a 00                	push   $0x0
  801c67:	e8 b2 ef ff ff       	call   800c1e <sys_page_unmap>
  801c6c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c6f:	83 ec 08             	sub    $0x8,%esp
  801c72:	ff 75 f4             	pushl  -0xc(%ebp)
  801c75:	6a 00                	push   $0x0
  801c77:	e8 a2 ef ff ff       	call   800c1e <sys_page_unmap>
  801c7c:	83 c4 10             	add    $0x10,%esp
  801c7f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c81:	89 d0                	mov    %edx,%eax
  801c83:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c86:	5b                   	pop    %ebx
  801c87:	5e                   	pop    %esi
  801c88:	5d                   	pop    %ebp
  801c89:	c3                   	ret    

00801c8a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c8a:	55                   	push   %ebp
  801c8b:	89 e5                	mov    %esp,%ebp
  801c8d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c90:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c93:	50                   	push   %eax
  801c94:	ff 75 08             	pushl  0x8(%ebp)
  801c97:	e8 27 f5 ff ff       	call   8011c3 <fd_lookup>
  801c9c:	83 c4 10             	add    $0x10,%esp
  801c9f:	85 c0                	test   %eax,%eax
  801ca1:	78 18                	js     801cbb <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ca3:	83 ec 0c             	sub    $0xc,%esp
  801ca6:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca9:	e8 af f4 ff ff       	call   80115d <fd2data>
	return _pipeisclosed(fd, p);
  801cae:	89 c2                	mov    %eax,%edx
  801cb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb3:	e8 18 fd ff ff       	call   8019d0 <_pipeisclosed>
  801cb8:	83 c4 10             	add    $0x10,%esp
}
  801cbb:	c9                   	leave  
  801cbc:	c3                   	ret    

00801cbd <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cbd:	55                   	push   %ebp
  801cbe:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cc0:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc5:	5d                   	pop    %ebp
  801cc6:	c3                   	ret    

00801cc7 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cc7:	55                   	push   %ebp
  801cc8:	89 e5                	mov    %esp,%ebp
  801cca:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ccd:	68 7a 27 80 00       	push   $0x80277a
  801cd2:	ff 75 0c             	pushl  0xc(%ebp)
  801cd5:	e8 bc ea ff ff       	call   800796 <strcpy>
	return 0;
}
  801cda:	b8 00 00 00 00       	mov    $0x0,%eax
  801cdf:	c9                   	leave  
  801ce0:	c3                   	ret    

00801ce1 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ce1:	55                   	push   %ebp
  801ce2:	89 e5                	mov    %esp,%ebp
  801ce4:	57                   	push   %edi
  801ce5:	56                   	push   %esi
  801ce6:	53                   	push   %ebx
  801ce7:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ced:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cf2:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cf8:	eb 2d                	jmp    801d27 <devcons_write+0x46>
		m = n - tot;
  801cfa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801cfd:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801cff:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d02:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d07:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d0a:	83 ec 04             	sub    $0x4,%esp
  801d0d:	53                   	push   %ebx
  801d0e:	03 45 0c             	add    0xc(%ebp),%eax
  801d11:	50                   	push   %eax
  801d12:	57                   	push   %edi
  801d13:	e8 10 ec ff ff       	call   800928 <memmove>
		sys_cputs(buf, m);
  801d18:	83 c4 08             	add    $0x8,%esp
  801d1b:	53                   	push   %ebx
  801d1c:	57                   	push   %edi
  801d1d:	e8 bb ed ff ff       	call   800add <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d22:	01 de                	add    %ebx,%esi
  801d24:	83 c4 10             	add    $0x10,%esp
  801d27:	89 f0                	mov    %esi,%eax
  801d29:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d2c:	72 cc                	jb     801cfa <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d31:	5b                   	pop    %ebx
  801d32:	5e                   	pop    %esi
  801d33:	5f                   	pop    %edi
  801d34:	5d                   	pop    %ebp
  801d35:	c3                   	ret    

00801d36 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d36:	55                   	push   %ebp
  801d37:	89 e5                	mov    %esp,%ebp
  801d39:	83 ec 08             	sub    $0x8,%esp
  801d3c:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d41:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d45:	74 2a                	je     801d71 <devcons_read+0x3b>
  801d47:	eb 05                	jmp    801d4e <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d49:	e8 2c ee ff ff       	call   800b7a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d4e:	e8 a8 ed ff ff       	call   800afb <sys_cgetc>
  801d53:	85 c0                	test   %eax,%eax
  801d55:	74 f2                	je     801d49 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d57:	85 c0                	test   %eax,%eax
  801d59:	78 16                	js     801d71 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d5b:	83 f8 04             	cmp    $0x4,%eax
  801d5e:	74 0c                	je     801d6c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d60:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d63:	88 02                	mov    %al,(%edx)
	return 1;
  801d65:	b8 01 00 00 00       	mov    $0x1,%eax
  801d6a:	eb 05                	jmp    801d71 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d6c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d71:	c9                   	leave  
  801d72:	c3                   	ret    

00801d73 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d73:	55                   	push   %ebp
  801d74:	89 e5                	mov    %esp,%ebp
  801d76:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d79:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d7f:	6a 01                	push   $0x1
  801d81:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d84:	50                   	push   %eax
  801d85:	e8 53 ed ff ff       	call   800add <sys_cputs>
}
  801d8a:	83 c4 10             	add    $0x10,%esp
  801d8d:	c9                   	leave  
  801d8e:	c3                   	ret    

00801d8f <getchar>:

int
getchar(void)
{
  801d8f:	55                   	push   %ebp
  801d90:	89 e5                	mov    %esp,%ebp
  801d92:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d95:	6a 01                	push   $0x1
  801d97:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d9a:	50                   	push   %eax
  801d9b:	6a 00                	push   $0x0
  801d9d:	e8 87 f6 ff ff       	call   801429 <read>
	if (r < 0)
  801da2:	83 c4 10             	add    $0x10,%esp
  801da5:	85 c0                	test   %eax,%eax
  801da7:	78 0f                	js     801db8 <getchar+0x29>
		return r;
	if (r < 1)
  801da9:	85 c0                	test   %eax,%eax
  801dab:	7e 06                	jle    801db3 <getchar+0x24>
		return -E_EOF;
	return c;
  801dad:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801db1:	eb 05                	jmp    801db8 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801db3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801db8:	c9                   	leave  
  801db9:	c3                   	ret    

00801dba <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801dba:	55                   	push   %ebp
  801dbb:	89 e5                	mov    %esp,%ebp
  801dbd:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dc0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dc3:	50                   	push   %eax
  801dc4:	ff 75 08             	pushl  0x8(%ebp)
  801dc7:	e8 f7 f3 ff ff       	call   8011c3 <fd_lookup>
  801dcc:	83 c4 10             	add    $0x10,%esp
  801dcf:	85 c0                	test   %eax,%eax
  801dd1:	78 11                	js     801de4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801dd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ddc:	39 10                	cmp    %edx,(%eax)
  801dde:	0f 94 c0             	sete   %al
  801de1:	0f b6 c0             	movzbl %al,%eax
}
  801de4:	c9                   	leave  
  801de5:	c3                   	ret    

00801de6 <opencons>:

int
opencons(void)
{
  801de6:	55                   	push   %ebp
  801de7:	89 e5                	mov    %esp,%ebp
  801de9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801dec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801def:	50                   	push   %eax
  801df0:	e8 7f f3 ff ff       	call   801174 <fd_alloc>
  801df5:	83 c4 10             	add    $0x10,%esp
		return r;
  801df8:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801dfa:	85 c0                	test   %eax,%eax
  801dfc:	78 3e                	js     801e3c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801dfe:	83 ec 04             	sub    $0x4,%esp
  801e01:	68 07 04 00 00       	push   $0x407
  801e06:	ff 75 f4             	pushl  -0xc(%ebp)
  801e09:	6a 00                	push   $0x0
  801e0b:	e8 89 ed ff ff       	call   800b99 <sys_page_alloc>
  801e10:	83 c4 10             	add    $0x10,%esp
		return r;
  801e13:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e15:	85 c0                	test   %eax,%eax
  801e17:	78 23                	js     801e3c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e19:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e22:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e27:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e2e:	83 ec 0c             	sub    $0xc,%esp
  801e31:	50                   	push   %eax
  801e32:	e8 16 f3 ff ff       	call   80114d <fd2num>
  801e37:	89 c2                	mov    %eax,%edx
  801e39:	83 c4 10             	add    $0x10,%esp
}
  801e3c:	89 d0                	mov    %edx,%eax
  801e3e:	c9                   	leave  
  801e3f:	c3                   	ret    

00801e40 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e40:	55                   	push   %ebp
  801e41:	89 e5                	mov    %esp,%ebp
  801e43:	56                   	push   %esi
  801e44:	53                   	push   %ebx
  801e45:	8b 75 08             	mov    0x8(%ebp),%esi
  801e48:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e4e:	85 c0                	test   %eax,%eax
  801e50:	75 12                	jne    801e64 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e52:	83 ec 0c             	sub    $0xc,%esp
  801e55:	68 00 00 c0 ee       	push   $0xeec00000
  801e5a:	e8 ea ee ff ff       	call   800d49 <sys_ipc_recv>
  801e5f:	83 c4 10             	add    $0x10,%esp
  801e62:	eb 0c                	jmp    801e70 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e64:	83 ec 0c             	sub    $0xc,%esp
  801e67:	50                   	push   %eax
  801e68:	e8 dc ee ff ff       	call   800d49 <sys_ipc_recv>
  801e6d:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e70:	85 f6                	test   %esi,%esi
  801e72:	0f 95 c1             	setne  %cl
  801e75:	85 db                	test   %ebx,%ebx
  801e77:	0f 95 c2             	setne  %dl
  801e7a:	84 d1                	test   %dl,%cl
  801e7c:	74 09                	je     801e87 <ipc_recv+0x47>
  801e7e:	89 c2                	mov    %eax,%edx
  801e80:	c1 ea 1f             	shr    $0x1f,%edx
  801e83:	84 d2                	test   %dl,%dl
  801e85:	75 2d                	jne    801eb4 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e87:	85 f6                	test   %esi,%esi
  801e89:	74 0d                	je     801e98 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e8b:	a1 04 40 80 00       	mov    0x804004,%eax
  801e90:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  801e96:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e98:	85 db                	test   %ebx,%ebx
  801e9a:	74 0d                	je     801ea9 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e9c:	a1 04 40 80 00       	mov    0x804004,%eax
  801ea1:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  801ea7:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ea9:	a1 04 40 80 00       	mov    0x804004,%eax
  801eae:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  801eb4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eb7:	5b                   	pop    %ebx
  801eb8:	5e                   	pop    %esi
  801eb9:	5d                   	pop    %ebp
  801eba:	c3                   	ret    

00801ebb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ebb:	55                   	push   %ebp
  801ebc:	89 e5                	mov    %esp,%ebp
  801ebe:	57                   	push   %edi
  801ebf:	56                   	push   %esi
  801ec0:	53                   	push   %ebx
  801ec1:	83 ec 0c             	sub    $0xc,%esp
  801ec4:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ec7:	8b 75 0c             	mov    0xc(%ebp),%esi
  801eca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801ecd:	85 db                	test   %ebx,%ebx
  801ecf:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ed4:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801ed7:	ff 75 14             	pushl  0x14(%ebp)
  801eda:	53                   	push   %ebx
  801edb:	56                   	push   %esi
  801edc:	57                   	push   %edi
  801edd:	e8 44 ee ff ff       	call   800d26 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801ee2:	89 c2                	mov    %eax,%edx
  801ee4:	c1 ea 1f             	shr    $0x1f,%edx
  801ee7:	83 c4 10             	add    $0x10,%esp
  801eea:	84 d2                	test   %dl,%dl
  801eec:	74 17                	je     801f05 <ipc_send+0x4a>
  801eee:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ef1:	74 12                	je     801f05 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801ef3:	50                   	push   %eax
  801ef4:	68 86 27 80 00       	push   $0x802786
  801ef9:	6a 47                	push   $0x47
  801efb:	68 94 27 80 00       	push   $0x802794
  801f00:	e8 33 e2 ff ff       	call   800138 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801f05:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f08:	75 07                	jne    801f11 <ipc_send+0x56>
			sys_yield();
  801f0a:	e8 6b ec ff ff       	call   800b7a <sys_yield>
  801f0f:	eb c6                	jmp    801ed7 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801f11:	85 c0                	test   %eax,%eax
  801f13:	75 c2                	jne    801ed7 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801f15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f18:	5b                   	pop    %ebx
  801f19:	5e                   	pop    %esi
  801f1a:	5f                   	pop    %edi
  801f1b:	5d                   	pop    %ebp
  801f1c:	c3                   	ret    

00801f1d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f1d:	55                   	push   %ebp
  801f1e:	89 e5                	mov    %esp,%ebp
  801f20:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f23:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f28:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  801f2e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f34:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801f3a:	39 ca                	cmp    %ecx,%edx
  801f3c:	75 10                	jne    801f4e <ipc_find_env+0x31>
			return envs[i].env_id;
  801f3e:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  801f44:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f49:	8b 40 7c             	mov    0x7c(%eax),%eax
  801f4c:	eb 0f                	jmp    801f5d <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f4e:	83 c0 01             	add    $0x1,%eax
  801f51:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f56:	75 d0                	jne    801f28 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f58:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f5d:	5d                   	pop    %ebp
  801f5e:	c3                   	ret    

00801f5f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f5f:	55                   	push   %ebp
  801f60:	89 e5                	mov    %esp,%ebp
  801f62:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f65:	89 d0                	mov    %edx,%eax
  801f67:	c1 e8 16             	shr    $0x16,%eax
  801f6a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f71:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f76:	f6 c1 01             	test   $0x1,%cl
  801f79:	74 1d                	je     801f98 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f7b:	c1 ea 0c             	shr    $0xc,%edx
  801f7e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f85:	f6 c2 01             	test   $0x1,%dl
  801f88:	74 0e                	je     801f98 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f8a:	c1 ea 0c             	shr    $0xc,%edx
  801f8d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f94:	ef 
  801f95:	0f b7 c0             	movzwl %ax,%eax
}
  801f98:	5d                   	pop    %ebp
  801f99:	c3                   	ret    
  801f9a:	66 90                	xchg   %ax,%ax
  801f9c:	66 90                	xchg   %ax,%ax
  801f9e:	66 90                	xchg   %ax,%ax

00801fa0 <__udivdi3>:
  801fa0:	55                   	push   %ebp
  801fa1:	57                   	push   %edi
  801fa2:	56                   	push   %esi
  801fa3:	53                   	push   %ebx
  801fa4:	83 ec 1c             	sub    $0x1c,%esp
  801fa7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801faf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fb7:	85 f6                	test   %esi,%esi
  801fb9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fbd:	89 ca                	mov    %ecx,%edx
  801fbf:	89 f8                	mov    %edi,%eax
  801fc1:	75 3d                	jne    802000 <__udivdi3+0x60>
  801fc3:	39 cf                	cmp    %ecx,%edi
  801fc5:	0f 87 c5 00 00 00    	ja     802090 <__udivdi3+0xf0>
  801fcb:	85 ff                	test   %edi,%edi
  801fcd:	89 fd                	mov    %edi,%ebp
  801fcf:	75 0b                	jne    801fdc <__udivdi3+0x3c>
  801fd1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fd6:	31 d2                	xor    %edx,%edx
  801fd8:	f7 f7                	div    %edi
  801fda:	89 c5                	mov    %eax,%ebp
  801fdc:	89 c8                	mov    %ecx,%eax
  801fde:	31 d2                	xor    %edx,%edx
  801fe0:	f7 f5                	div    %ebp
  801fe2:	89 c1                	mov    %eax,%ecx
  801fe4:	89 d8                	mov    %ebx,%eax
  801fe6:	89 cf                	mov    %ecx,%edi
  801fe8:	f7 f5                	div    %ebp
  801fea:	89 c3                	mov    %eax,%ebx
  801fec:	89 d8                	mov    %ebx,%eax
  801fee:	89 fa                	mov    %edi,%edx
  801ff0:	83 c4 1c             	add    $0x1c,%esp
  801ff3:	5b                   	pop    %ebx
  801ff4:	5e                   	pop    %esi
  801ff5:	5f                   	pop    %edi
  801ff6:	5d                   	pop    %ebp
  801ff7:	c3                   	ret    
  801ff8:	90                   	nop
  801ff9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802000:	39 ce                	cmp    %ecx,%esi
  802002:	77 74                	ja     802078 <__udivdi3+0xd8>
  802004:	0f bd fe             	bsr    %esi,%edi
  802007:	83 f7 1f             	xor    $0x1f,%edi
  80200a:	0f 84 98 00 00 00    	je     8020a8 <__udivdi3+0x108>
  802010:	bb 20 00 00 00       	mov    $0x20,%ebx
  802015:	89 f9                	mov    %edi,%ecx
  802017:	89 c5                	mov    %eax,%ebp
  802019:	29 fb                	sub    %edi,%ebx
  80201b:	d3 e6                	shl    %cl,%esi
  80201d:	89 d9                	mov    %ebx,%ecx
  80201f:	d3 ed                	shr    %cl,%ebp
  802021:	89 f9                	mov    %edi,%ecx
  802023:	d3 e0                	shl    %cl,%eax
  802025:	09 ee                	or     %ebp,%esi
  802027:	89 d9                	mov    %ebx,%ecx
  802029:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80202d:	89 d5                	mov    %edx,%ebp
  80202f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802033:	d3 ed                	shr    %cl,%ebp
  802035:	89 f9                	mov    %edi,%ecx
  802037:	d3 e2                	shl    %cl,%edx
  802039:	89 d9                	mov    %ebx,%ecx
  80203b:	d3 e8                	shr    %cl,%eax
  80203d:	09 c2                	or     %eax,%edx
  80203f:	89 d0                	mov    %edx,%eax
  802041:	89 ea                	mov    %ebp,%edx
  802043:	f7 f6                	div    %esi
  802045:	89 d5                	mov    %edx,%ebp
  802047:	89 c3                	mov    %eax,%ebx
  802049:	f7 64 24 0c          	mull   0xc(%esp)
  80204d:	39 d5                	cmp    %edx,%ebp
  80204f:	72 10                	jb     802061 <__udivdi3+0xc1>
  802051:	8b 74 24 08          	mov    0x8(%esp),%esi
  802055:	89 f9                	mov    %edi,%ecx
  802057:	d3 e6                	shl    %cl,%esi
  802059:	39 c6                	cmp    %eax,%esi
  80205b:	73 07                	jae    802064 <__udivdi3+0xc4>
  80205d:	39 d5                	cmp    %edx,%ebp
  80205f:	75 03                	jne    802064 <__udivdi3+0xc4>
  802061:	83 eb 01             	sub    $0x1,%ebx
  802064:	31 ff                	xor    %edi,%edi
  802066:	89 d8                	mov    %ebx,%eax
  802068:	89 fa                	mov    %edi,%edx
  80206a:	83 c4 1c             	add    $0x1c,%esp
  80206d:	5b                   	pop    %ebx
  80206e:	5e                   	pop    %esi
  80206f:	5f                   	pop    %edi
  802070:	5d                   	pop    %ebp
  802071:	c3                   	ret    
  802072:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802078:	31 ff                	xor    %edi,%edi
  80207a:	31 db                	xor    %ebx,%ebx
  80207c:	89 d8                	mov    %ebx,%eax
  80207e:	89 fa                	mov    %edi,%edx
  802080:	83 c4 1c             	add    $0x1c,%esp
  802083:	5b                   	pop    %ebx
  802084:	5e                   	pop    %esi
  802085:	5f                   	pop    %edi
  802086:	5d                   	pop    %ebp
  802087:	c3                   	ret    
  802088:	90                   	nop
  802089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802090:	89 d8                	mov    %ebx,%eax
  802092:	f7 f7                	div    %edi
  802094:	31 ff                	xor    %edi,%edi
  802096:	89 c3                	mov    %eax,%ebx
  802098:	89 d8                	mov    %ebx,%eax
  80209a:	89 fa                	mov    %edi,%edx
  80209c:	83 c4 1c             	add    $0x1c,%esp
  80209f:	5b                   	pop    %ebx
  8020a0:	5e                   	pop    %esi
  8020a1:	5f                   	pop    %edi
  8020a2:	5d                   	pop    %ebp
  8020a3:	c3                   	ret    
  8020a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020a8:	39 ce                	cmp    %ecx,%esi
  8020aa:	72 0c                	jb     8020b8 <__udivdi3+0x118>
  8020ac:	31 db                	xor    %ebx,%ebx
  8020ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020b2:	0f 87 34 ff ff ff    	ja     801fec <__udivdi3+0x4c>
  8020b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020bd:	e9 2a ff ff ff       	jmp    801fec <__udivdi3+0x4c>
  8020c2:	66 90                	xchg   %ax,%ax
  8020c4:	66 90                	xchg   %ax,%ax
  8020c6:	66 90                	xchg   %ax,%ax
  8020c8:	66 90                	xchg   %ax,%ax
  8020ca:	66 90                	xchg   %ax,%ax
  8020cc:	66 90                	xchg   %ax,%ax
  8020ce:	66 90                	xchg   %ax,%ax

008020d0 <__umoddi3>:
  8020d0:	55                   	push   %ebp
  8020d1:	57                   	push   %edi
  8020d2:	56                   	push   %esi
  8020d3:	53                   	push   %ebx
  8020d4:	83 ec 1c             	sub    $0x1c,%esp
  8020d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020e7:	85 d2                	test   %edx,%edx
  8020e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020f1:	89 f3                	mov    %esi,%ebx
  8020f3:	89 3c 24             	mov    %edi,(%esp)
  8020f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020fa:	75 1c                	jne    802118 <__umoddi3+0x48>
  8020fc:	39 f7                	cmp    %esi,%edi
  8020fe:	76 50                	jbe    802150 <__umoddi3+0x80>
  802100:	89 c8                	mov    %ecx,%eax
  802102:	89 f2                	mov    %esi,%edx
  802104:	f7 f7                	div    %edi
  802106:	89 d0                	mov    %edx,%eax
  802108:	31 d2                	xor    %edx,%edx
  80210a:	83 c4 1c             	add    $0x1c,%esp
  80210d:	5b                   	pop    %ebx
  80210e:	5e                   	pop    %esi
  80210f:	5f                   	pop    %edi
  802110:	5d                   	pop    %ebp
  802111:	c3                   	ret    
  802112:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802118:	39 f2                	cmp    %esi,%edx
  80211a:	89 d0                	mov    %edx,%eax
  80211c:	77 52                	ja     802170 <__umoddi3+0xa0>
  80211e:	0f bd ea             	bsr    %edx,%ebp
  802121:	83 f5 1f             	xor    $0x1f,%ebp
  802124:	75 5a                	jne    802180 <__umoddi3+0xb0>
  802126:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80212a:	0f 82 e0 00 00 00    	jb     802210 <__umoddi3+0x140>
  802130:	39 0c 24             	cmp    %ecx,(%esp)
  802133:	0f 86 d7 00 00 00    	jbe    802210 <__umoddi3+0x140>
  802139:	8b 44 24 08          	mov    0x8(%esp),%eax
  80213d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802141:	83 c4 1c             	add    $0x1c,%esp
  802144:	5b                   	pop    %ebx
  802145:	5e                   	pop    %esi
  802146:	5f                   	pop    %edi
  802147:	5d                   	pop    %ebp
  802148:	c3                   	ret    
  802149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802150:	85 ff                	test   %edi,%edi
  802152:	89 fd                	mov    %edi,%ebp
  802154:	75 0b                	jne    802161 <__umoddi3+0x91>
  802156:	b8 01 00 00 00       	mov    $0x1,%eax
  80215b:	31 d2                	xor    %edx,%edx
  80215d:	f7 f7                	div    %edi
  80215f:	89 c5                	mov    %eax,%ebp
  802161:	89 f0                	mov    %esi,%eax
  802163:	31 d2                	xor    %edx,%edx
  802165:	f7 f5                	div    %ebp
  802167:	89 c8                	mov    %ecx,%eax
  802169:	f7 f5                	div    %ebp
  80216b:	89 d0                	mov    %edx,%eax
  80216d:	eb 99                	jmp    802108 <__umoddi3+0x38>
  80216f:	90                   	nop
  802170:	89 c8                	mov    %ecx,%eax
  802172:	89 f2                	mov    %esi,%edx
  802174:	83 c4 1c             	add    $0x1c,%esp
  802177:	5b                   	pop    %ebx
  802178:	5e                   	pop    %esi
  802179:	5f                   	pop    %edi
  80217a:	5d                   	pop    %ebp
  80217b:	c3                   	ret    
  80217c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802180:	8b 34 24             	mov    (%esp),%esi
  802183:	bf 20 00 00 00       	mov    $0x20,%edi
  802188:	89 e9                	mov    %ebp,%ecx
  80218a:	29 ef                	sub    %ebp,%edi
  80218c:	d3 e0                	shl    %cl,%eax
  80218e:	89 f9                	mov    %edi,%ecx
  802190:	89 f2                	mov    %esi,%edx
  802192:	d3 ea                	shr    %cl,%edx
  802194:	89 e9                	mov    %ebp,%ecx
  802196:	09 c2                	or     %eax,%edx
  802198:	89 d8                	mov    %ebx,%eax
  80219a:	89 14 24             	mov    %edx,(%esp)
  80219d:	89 f2                	mov    %esi,%edx
  80219f:	d3 e2                	shl    %cl,%edx
  8021a1:	89 f9                	mov    %edi,%ecx
  8021a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021ab:	d3 e8                	shr    %cl,%eax
  8021ad:	89 e9                	mov    %ebp,%ecx
  8021af:	89 c6                	mov    %eax,%esi
  8021b1:	d3 e3                	shl    %cl,%ebx
  8021b3:	89 f9                	mov    %edi,%ecx
  8021b5:	89 d0                	mov    %edx,%eax
  8021b7:	d3 e8                	shr    %cl,%eax
  8021b9:	89 e9                	mov    %ebp,%ecx
  8021bb:	09 d8                	or     %ebx,%eax
  8021bd:	89 d3                	mov    %edx,%ebx
  8021bf:	89 f2                	mov    %esi,%edx
  8021c1:	f7 34 24             	divl   (%esp)
  8021c4:	89 d6                	mov    %edx,%esi
  8021c6:	d3 e3                	shl    %cl,%ebx
  8021c8:	f7 64 24 04          	mull   0x4(%esp)
  8021cc:	39 d6                	cmp    %edx,%esi
  8021ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021d2:	89 d1                	mov    %edx,%ecx
  8021d4:	89 c3                	mov    %eax,%ebx
  8021d6:	72 08                	jb     8021e0 <__umoddi3+0x110>
  8021d8:	75 11                	jne    8021eb <__umoddi3+0x11b>
  8021da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021de:	73 0b                	jae    8021eb <__umoddi3+0x11b>
  8021e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021e4:	1b 14 24             	sbb    (%esp),%edx
  8021e7:	89 d1                	mov    %edx,%ecx
  8021e9:	89 c3                	mov    %eax,%ebx
  8021eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021ef:	29 da                	sub    %ebx,%edx
  8021f1:	19 ce                	sbb    %ecx,%esi
  8021f3:	89 f9                	mov    %edi,%ecx
  8021f5:	89 f0                	mov    %esi,%eax
  8021f7:	d3 e0                	shl    %cl,%eax
  8021f9:	89 e9                	mov    %ebp,%ecx
  8021fb:	d3 ea                	shr    %cl,%edx
  8021fd:	89 e9                	mov    %ebp,%ecx
  8021ff:	d3 ee                	shr    %cl,%esi
  802201:	09 d0                	or     %edx,%eax
  802203:	89 f2                	mov    %esi,%edx
  802205:	83 c4 1c             	add    $0x1c,%esp
  802208:	5b                   	pop    %ebx
  802209:	5e                   	pop    %esi
  80220a:	5f                   	pop    %edi
  80220b:	5d                   	pop    %ebp
  80220c:	c3                   	ret    
  80220d:	8d 76 00             	lea    0x0(%esi),%esi
  802210:	29 f9                	sub    %edi,%ecx
  802212:	19 d6                	sbb    %edx,%esi
  802214:	89 74 24 04          	mov    %esi,0x4(%esp)
  802218:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80221c:	e9 18 ff ff ff       	jmp    802139 <__umoddi3+0x69>
