
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
  800040:	68 60 24 80 00       	push   $0x802460
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
  80006a:	68 80 24 80 00       	push   $0x802480
  80006f:	6a 0f                	push   $0xf
  800071:	68 6a 24 80 00       	push   $0x80246a
  800076:	e8 bd 00 00 00       	call   800138 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 ac 24 80 00       	push   $0x8024ac
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
  800124:	e8 18 14 00 00       	call   801541 <close_all>
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
  800156:	68 d8 24 80 00       	push   $0x8024d8
  80015b:	e8 b1 00 00 00       	call   800211 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800160:	83 c4 18             	add    $0x18,%esp
  800163:	53                   	push   %ebx
  800164:	ff 75 10             	pushl  0x10(%ebp)
  800167:	e8 54 00 00 00       	call   8001c0 <vcprintf>
	cprintf("\n");
  80016c:	c7 04 24 a9 28 80 00 	movl   $0x8028a9,(%esp)
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
  800274:	e8 57 1f 00 00       	call   8021d0 <__udivdi3>
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
  8002b7:	e8 44 20 00 00       	call   802300 <__umoddi3>
  8002bc:	83 c4 14             	add    $0x14,%esp
  8002bf:	0f be 80 fb 24 80 00 	movsbl 0x8024fb(%eax),%eax
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
  8003bb:	ff 24 85 40 26 80 00 	jmp    *0x802640(,%eax,4)
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
  80047f:	8b 14 85 a0 27 80 00 	mov    0x8027a0(,%eax,4),%edx
  800486:	85 d2                	test   %edx,%edx
  800488:	75 18                	jne    8004a2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80048a:	50                   	push   %eax
  80048b:	68 13 25 80 00       	push   $0x802513
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
  8004a3:	68 6d 29 80 00       	push   $0x80296d
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
  8004c7:	b8 0c 25 80 00       	mov    $0x80250c,%eax
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
  800b42:	68 ff 27 80 00       	push   $0x8027ff
  800b47:	6a 23                	push   $0x23
  800b49:	68 1c 28 80 00       	push   $0x80281c
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
  800bc3:	68 ff 27 80 00       	push   $0x8027ff
  800bc8:	6a 23                	push   $0x23
  800bca:	68 1c 28 80 00       	push   $0x80281c
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
  800c05:	68 ff 27 80 00       	push   $0x8027ff
  800c0a:	6a 23                	push   $0x23
  800c0c:	68 1c 28 80 00       	push   $0x80281c
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
  800c47:	68 ff 27 80 00       	push   $0x8027ff
  800c4c:	6a 23                	push   $0x23
  800c4e:	68 1c 28 80 00       	push   $0x80281c
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
  800c89:	68 ff 27 80 00       	push   $0x8027ff
  800c8e:	6a 23                	push   $0x23
  800c90:	68 1c 28 80 00       	push   $0x80281c
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
  800ccb:	68 ff 27 80 00       	push   $0x8027ff
  800cd0:	6a 23                	push   $0x23
  800cd2:	68 1c 28 80 00       	push   $0x80281c
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
  800d0d:	68 ff 27 80 00       	push   $0x8027ff
  800d12:	6a 23                	push   $0x23
  800d14:	68 1c 28 80 00       	push   $0x80281c
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
  800d71:	68 ff 27 80 00       	push   $0x8027ff
  800d76:	6a 23                	push   $0x23
  800d78:	68 1c 28 80 00       	push   $0x80281c
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
  800e12:	68 c0 28 80 00       	push   $0x8028c0
  800e17:	6a 23                	push   $0x23
  800e19:	68 2a 28 80 00       	push   $0x80282a
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
  800e42:	68 c0 28 80 00       	push   $0x8028c0
  800e47:	6a 2c                	push   $0x2c
  800e49:	68 2a 28 80 00       	push   $0x80282a
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
  800e9f:	68 38 28 80 00       	push   $0x802838
  800ea4:	6a 1f                	push   $0x1f
  800ea6:	68 48 28 80 00       	push   $0x802848
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
  800ec9:	68 53 28 80 00       	push   $0x802853
  800ece:	6a 2d                	push   $0x2d
  800ed0:	68 48 28 80 00       	push   $0x802848
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
  800f11:	68 53 28 80 00       	push   $0x802853
  800f16:	6a 34                	push   $0x34
  800f18:	68 48 28 80 00       	push   $0x802848
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
  800f39:	68 53 28 80 00       	push   $0x802853
  800f3e:	6a 38                	push   $0x38
  800f40:	68 48 28 80 00       	push   $0x802848
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
  800f76:	68 6c 28 80 00       	push   $0x80286c
  800f7b:	68 85 00 00 00       	push   $0x85
  800f80:	68 48 28 80 00       	push   $0x802848
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
  801032:	68 7a 28 80 00       	push   $0x80287a
  801037:	6a 55                	push   $0x55
  801039:	68 48 28 80 00       	push   $0x802848
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
  801077:	68 7a 28 80 00       	push   $0x80287a
  80107c:	6a 5c                	push   $0x5c
  80107e:	68 48 28 80 00       	push   $0x802848
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
  8010a5:	68 7a 28 80 00       	push   $0x80287a
  8010aa:	6a 60                	push   $0x60
  8010ac:	68 48 28 80 00       	push   $0x802848
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
  8010cf:	68 7a 28 80 00       	push   $0x80287a
  8010d4:	6a 65                	push   $0x65
  8010d6:	68 48 28 80 00       	push   $0x802848
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
  80118c:	68 c0 28 80 00       	push   $0x8028c0
  801191:	68 d5 00 00 00       	push   $0xd5
  801196:	68 48 28 80 00       	push   $0x802848
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
  8011f2:	68 90 28 80 00       	push   $0x802890
  8011f7:	68 ec 00 00 00       	push   $0xec
  8011fc:	68 48 28 80 00       	push   $0x802848
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
  801212:	53                   	push   %ebx
  801213:	83 ec 04             	sub    $0x4,%esp
  801216:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  801219:	b8 01 00 00 00       	mov    $0x1,%eax
  80121e:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0)) {
  801221:	85 c0                	test   %eax,%eax
  801223:	74 45                	je     80126a <mutex_lock+0x5b>
		queue_append(sys_getenvid(), &mtx->queue);		
  801225:	e8 31 f9 ff ff       	call   800b5b <sys_getenvid>
  80122a:	83 ec 08             	sub    $0x8,%esp
  80122d:	83 c3 04             	add    $0x4,%ebx
  801230:	53                   	push   %ebx
  801231:	50                   	push   %eax
  801232:	e8 35 ff ff ff       	call   80116c <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  801237:	e8 1f f9 ff ff       	call   800b5b <sys_getenvid>
  80123c:	83 c4 08             	add    $0x8,%esp
  80123f:	6a 04                	push   $0x4
  801241:	50                   	push   %eax
  801242:	e8 19 fa ff ff       	call   800c60 <sys_env_set_status>

		if (r < 0) {
  801247:	83 c4 10             	add    $0x10,%esp
  80124a:	85 c0                	test   %eax,%eax
  80124c:	79 15                	jns    801263 <mutex_lock+0x54>
			panic("%e\n", r);
  80124e:	50                   	push   %eax
  80124f:	68 c0 28 80 00       	push   $0x8028c0
  801254:	68 02 01 00 00       	push   $0x102
  801259:	68 48 28 80 00       	push   $0x802848
  80125e:	e8 d5 ee ff ff       	call   800138 <_panic>
		}
		sys_yield();
  801263:	e8 12 f9 ff ff       	call   800b7a <sys_yield>
  801268:	eb 08                	jmp    801272 <mutex_lock+0x63>
	} else {
		mtx->owner = sys_getenvid();
  80126a:	e8 ec f8 ff ff       	call   800b5b <sys_getenvid>
  80126f:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801272:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801275:	c9                   	leave  
  801276:	c3                   	ret    

00801277 <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  801277:	55                   	push   %ebp
  801278:	89 e5                	mov    %esp,%ebp
  80127a:	53                   	push   %ebx
  80127b:	83 ec 04             	sub    $0x4,%esp
  80127e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	if (mtx->queue.first != NULL) {
  801281:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  801285:	74 36                	je     8012bd <mutex_unlock+0x46>
		mtx->owner = queue_pop(&mtx->queue);
  801287:	83 ec 0c             	sub    $0xc,%esp
  80128a:	8d 43 04             	lea    0x4(%ebx),%eax
  80128d:	50                   	push   %eax
  80128e:	e8 4d ff ff ff       	call   8011e0 <queue_pop>
  801293:	89 43 0c             	mov    %eax,0xc(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  801296:	83 c4 08             	add    $0x8,%esp
  801299:	6a 02                	push   $0x2
  80129b:	50                   	push   %eax
  80129c:	e8 bf f9 ff ff       	call   800c60 <sys_env_set_status>
		if (r < 0) {
  8012a1:	83 c4 10             	add    $0x10,%esp
  8012a4:	85 c0                	test   %eax,%eax
  8012a6:	79 1d                	jns    8012c5 <mutex_unlock+0x4e>
			panic("%e\n", r);
  8012a8:	50                   	push   %eax
  8012a9:	68 c0 28 80 00       	push   $0x8028c0
  8012ae:	68 16 01 00 00       	push   $0x116
  8012b3:	68 48 28 80 00       	push   $0x802848
  8012b8:	e8 7b ee ff ff       	call   800138 <_panic>
  8012bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c2:	f0 87 03             	lock xchg %eax,(%ebx)
		}
	} else xchg(&mtx->locked, 0);
	
	//asm volatile("pause"); 	// might be useless here
	sys_yield();
  8012c5:	e8 b0 f8 ff ff       	call   800b7a <sys_yield>
}
  8012ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012cd:	c9                   	leave  
  8012ce:	c3                   	ret    

008012cf <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  8012cf:	55                   	push   %ebp
  8012d0:	89 e5                	mov    %esp,%ebp
  8012d2:	53                   	push   %ebx
  8012d3:	83 ec 04             	sub    $0x4,%esp
  8012d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  8012d9:	e8 7d f8 ff ff       	call   800b5b <sys_getenvid>
  8012de:	83 ec 04             	sub    $0x4,%esp
  8012e1:	6a 07                	push   $0x7
  8012e3:	53                   	push   %ebx
  8012e4:	50                   	push   %eax
  8012e5:	e8 af f8 ff ff       	call   800b99 <sys_page_alloc>
  8012ea:	83 c4 10             	add    $0x10,%esp
  8012ed:	85 c0                	test   %eax,%eax
  8012ef:	79 15                	jns    801306 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  8012f1:	50                   	push   %eax
  8012f2:	68 ab 28 80 00       	push   $0x8028ab
  8012f7:	68 23 01 00 00       	push   $0x123
  8012fc:	68 48 28 80 00       	push   $0x802848
  801301:	e8 32 ee ff ff       	call   800138 <_panic>
	}	
	mtx->locked = 0;
  801306:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue.first = NULL;
  80130c:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	mtx->queue.last = NULL;
  801313:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	mtx->owner = 0;
  80131a:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
}
  801321:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801324:	c9                   	leave  
  801325:	c3                   	ret    

00801326 <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	56                   	push   %esi
  80132a:	53                   	push   %ebx
  80132b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue.first != NULL) {
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  80132e:	8d 73 04             	lea    0x4(%ebx),%esi

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  801331:	eb 20                	jmp    801353 <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  801333:	83 ec 0c             	sub    $0xc,%esp
  801336:	56                   	push   %esi
  801337:	e8 a4 fe ff ff       	call   8011e0 <queue_pop>
  80133c:	83 c4 08             	add    $0x8,%esp
  80133f:	6a 02                	push   $0x2
  801341:	50                   	push   %eax
  801342:	e8 19 f9 ff ff       	call   800c60 <sys_env_set_status>
		mtx->queue.first = mtx->queue.first->next;
  801347:	8b 43 04             	mov    0x4(%ebx),%eax
  80134a:	8b 40 04             	mov    0x4(%eax),%eax
  80134d:	89 43 04             	mov    %eax,0x4(%ebx)
  801350:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  801353:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  801357:	75 da                	jne    801333 <mutex_destroy+0xd>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
		mtx->queue.first = mtx->queue.first->next;
	}

	memset(mtx, 0, PGSIZE);
  801359:	83 ec 04             	sub    $0x4,%esp
  80135c:	68 00 10 00 00       	push   $0x1000
  801361:	6a 00                	push   $0x0
  801363:	53                   	push   %ebx
  801364:	e8 72 f5 ff ff       	call   8008db <memset>
	mtx = NULL;
}
  801369:	83 c4 10             	add    $0x10,%esp
  80136c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80136f:	5b                   	pop    %ebx
  801370:	5e                   	pop    %esi
  801371:	5d                   	pop    %ebp
  801372:	c3                   	ret    

00801373 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801376:	8b 45 08             	mov    0x8(%ebp),%eax
  801379:	05 00 00 00 30       	add    $0x30000000,%eax
  80137e:	c1 e8 0c             	shr    $0xc,%eax
}
  801381:	5d                   	pop    %ebp
  801382:	c3                   	ret    

00801383 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801383:	55                   	push   %ebp
  801384:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801386:	8b 45 08             	mov    0x8(%ebp),%eax
  801389:	05 00 00 00 30       	add    $0x30000000,%eax
  80138e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801393:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801398:	5d                   	pop    %ebp
  801399:	c3                   	ret    

0080139a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80139a:	55                   	push   %ebp
  80139b:	89 e5                	mov    %esp,%ebp
  80139d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013a0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013a5:	89 c2                	mov    %eax,%edx
  8013a7:	c1 ea 16             	shr    $0x16,%edx
  8013aa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013b1:	f6 c2 01             	test   $0x1,%dl
  8013b4:	74 11                	je     8013c7 <fd_alloc+0x2d>
  8013b6:	89 c2                	mov    %eax,%edx
  8013b8:	c1 ea 0c             	shr    $0xc,%edx
  8013bb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013c2:	f6 c2 01             	test   $0x1,%dl
  8013c5:	75 09                	jne    8013d0 <fd_alloc+0x36>
			*fd_store = fd;
  8013c7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ce:	eb 17                	jmp    8013e7 <fd_alloc+0x4d>
  8013d0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013d5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013da:	75 c9                	jne    8013a5 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013dc:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8013e2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013e7:	5d                   	pop    %ebp
  8013e8:	c3                   	ret    

008013e9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013e9:	55                   	push   %ebp
  8013ea:	89 e5                	mov    %esp,%ebp
  8013ec:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013ef:	83 f8 1f             	cmp    $0x1f,%eax
  8013f2:	77 36                	ja     80142a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013f4:	c1 e0 0c             	shl    $0xc,%eax
  8013f7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013fc:	89 c2                	mov    %eax,%edx
  8013fe:	c1 ea 16             	shr    $0x16,%edx
  801401:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801408:	f6 c2 01             	test   $0x1,%dl
  80140b:	74 24                	je     801431 <fd_lookup+0x48>
  80140d:	89 c2                	mov    %eax,%edx
  80140f:	c1 ea 0c             	shr    $0xc,%edx
  801412:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801419:	f6 c2 01             	test   $0x1,%dl
  80141c:	74 1a                	je     801438 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80141e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801421:	89 02                	mov    %eax,(%edx)
	return 0;
  801423:	b8 00 00 00 00       	mov    $0x0,%eax
  801428:	eb 13                	jmp    80143d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80142a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80142f:	eb 0c                	jmp    80143d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801431:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801436:	eb 05                	jmp    80143d <fd_lookup+0x54>
  801438:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80143d:	5d                   	pop    %ebp
  80143e:	c3                   	ret    

0080143f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
  801442:	83 ec 08             	sub    $0x8,%esp
  801445:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801448:	ba 44 29 80 00       	mov    $0x802944,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80144d:	eb 13                	jmp    801462 <dev_lookup+0x23>
  80144f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801452:	39 08                	cmp    %ecx,(%eax)
  801454:	75 0c                	jne    801462 <dev_lookup+0x23>
			*dev = devtab[i];
  801456:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801459:	89 01                	mov    %eax,(%ecx)
			return 0;
  80145b:	b8 00 00 00 00       	mov    $0x0,%eax
  801460:	eb 31                	jmp    801493 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801462:	8b 02                	mov    (%edx),%eax
  801464:	85 c0                	test   %eax,%eax
  801466:	75 e7                	jne    80144f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801468:	a1 04 40 80 00       	mov    0x804004,%eax
  80146d:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801473:	83 ec 04             	sub    $0x4,%esp
  801476:	51                   	push   %ecx
  801477:	50                   	push   %eax
  801478:	68 c4 28 80 00       	push   $0x8028c4
  80147d:	e8 8f ed ff ff       	call   800211 <cprintf>
	*dev = 0;
  801482:	8b 45 0c             	mov    0xc(%ebp),%eax
  801485:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80148b:	83 c4 10             	add    $0x10,%esp
  80148e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801493:	c9                   	leave  
  801494:	c3                   	ret    

00801495 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801495:	55                   	push   %ebp
  801496:	89 e5                	mov    %esp,%ebp
  801498:	56                   	push   %esi
  801499:	53                   	push   %ebx
  80149a:	83 ec 10             	sub    $0x10,%esp
  80149d:	8b 75 08             	mov    0x8(%ebp),%esi
  8014a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a6:	50                   	push   %eax
  8014a7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014ad:	c1 e8 0c             	shr    $0xc,%eax
  8014b0:	50                   	push   %eax
  8014b1:	e8 33 ff ff ff       	call   8013e9 <fd_lookup>
  8014b6:	83 c4 08             	add    $0x8,%esp
  8014b9:	85 c0                	test   %eax,%eax
  8014bb:	78 05                	js     8014c2 <fd_close+0x2d>
	    || fd != fd2)
  8014bd:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014c0:	74 0c                	je     8014ce <fd_close+0x39>
		return (must_exist ? r : 0);
  8014c2:	84 db                	test   %bl,%bl
  8014c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c9:	0f 44 c2             	cmove  %edx,%eax
  8014cc:	eb 41                	jmp    80150f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014ce:	83 ec 08             	sub    $0x8,%esp
  8014d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d4:	50                   	push   %eax
  8014d5:	ff 36                	pushl  (%esi)
  8014d7:	e8 63 ff ff ff       	call   80143f <dev_lookup>
  8014dc:	89 c3                	mov    %eax,%ebx
  8014de:	83 c4 10             	add    $0x10,%esp
  8014e1:	85 c0                	test   %eax,%eax
  8014e3:	78 1a                	js     8014ff <fd_close+0x6a>
		if (dev->dev_close)
  8014e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8014eb:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8014f0:	85 c0                	test   %eax,%eax
  8014f2:	74 0b                	je     8014ff <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8014f4:	83 ec 0c             	sub    $0xc,%esp
  8014f7:	56                   	push   %esi
  8014f8:	ff d0                	call   *%eax
  8014fa:	89 c3                	mov    %eax,%ebx
  8014fc:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014ff:	83 ec 08             	sub    $0x8,%esp
  801502:	56                   	push   %esi
  801503:	6a 00                	push   $0x0
  801505:	e8 14 f7 ff ff       	call   800c1e <sys_page_unmap>
	return r;
  80150a:	83 c4 10             	add    $0x10,%esp
  80150d:	89 d8                	mov    %ebx,%eax
}
  80150f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801512:	5b                   	pop    %ebx
  801513:	5e                   	pop    %esi
  801514:	5d                   	pop    %ebp
  801515:	c3                   	ret    

00801516 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801516:	55                   	push   %ebp
  801517:	89 e5                	mov    %esp,%ebp
  801519:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80151c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151f:	50                   	push   %eax
  801520:	ff 75 08             	pushl  0x8(%ebp)
  801523:	e8 c1 fe ff ff       	call   8013e9 <fd_lookup>
  801528:	83 c4 08             	add    $0x8,%esp
  80152b:	85 c0                	test   %eax,%eax
  80152d:	78 10                	js     80153f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80152f:	83 ec 08             	sub    $0x8,%esp
  801532:	6a 01                	push   $0x1
  801534:	ff 75 f4             	pushl  -0xc(%ebp)
  801537:	e8 59 ff ff ff       	call   801495 <fd_close>
  80153c:	83 c4 10             	add    $0x10,%esp
}
  80153f:	c9                   	leave  
  801540:	c3                   	ret    

00801541 <close_all>:

void
close_all(void)
{
  801541:	55                   	push   %ebp
  801542:	89 e5                	mov    %esp,%ebp
  801544:	53                   	push   %ebx
  801545:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801548:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80154d:	83 ec 0c             	sub    $0xc,%esp
  801550:	53                   	push   %ebx
  801551:	e8 c0 ff ff ff       	call   801516 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801556:	83 c3 01             	add    $0x1,%ebx
  801559:	83 c4 10             	add    $0x10,%esp
  80155c:	83 fb 20             	cmp    $0x20,%ebx
  80155f:	75 ec                	jne    80154d <close_all+0xc>
		close(i);
}
  801561:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801564:	c9                   	leave  
  801565:	c3                   	ret    

00801566 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801566:	55                   	push   %ebp
  801567:	89 e5                	mov    %esp,%ebp
  801569:	57                   	push   %edi
  80156a:	56                   	push   %esi
  80156b:	53                   	push   %ebx
  80156c:	83 ec 2c             	sub    $0x2c,%esp
  80156f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801572:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801575:	50                   	push   %eax
  801576:	ff 75 08             	pushl  0x8(%ebp)
  801579:	e8 6b fe ff ff       	call   8013e9 <fd_lookup>
  80157e:	83 c4 08             	add    $0x8,%esp
  801581:	85 c0                	test   %eax,%eax
  801583:	0f 88 c1 00 00 00    	js     80164a <dup+0xe4>
		return r;
	close(newfdnum);
  801589:	83 ec 0c             	sub    $0xc,%esp
  80158c:	56                   	push   %esi
  80158d:	e8 84 ff ff ff       	call   801516 <close>

	newfd = INDEX2FD(newfdnum);
  801592:	89 f3                	mov    %esi,%ebx
  801594:	c1 e3 0c             	shl    $0xc,%ebx
  801597:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80159d:	83 c4 04             	add    $0x4,%esp
  8015a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015a3:	e8 db fd ff ff       	call   801383 <fd2data>
  8015a8:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8015aa:	89 1c 24             	mov    %ebx,(%esp)
  8015ad:	e8 d1 fd ff ff       	call   801383 <fd2data>
  8015b2:	83 c4 10             	add    $0x10,%esp
  8015b5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015b8:	89 f8                	mov    %edi,%eax
  8015ba:	c1 e8 16             	shr    $0x16,%eax
  8015bd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015c4:	a8 01                	test   $0x1,%al
  8015c6:	74 37                	je     8015ff <dup+0x99>
  8015c8:	89 f8                	mov    %edi,%eax
  8015ca:	c1 e8 0c             	shr    $0xc,%eax
  8015cd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015d4:	f6 c2 01             	test   $0x1,%dl
  8015d7:	74 26                	je     8015ff <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015d9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015e0:	83 ec 0c             	sub    $0xc,%esp
  8015e3:	25 07 0e 00 00       	and    $0xe07,%eax
  8015e8:	50                   	push   %eax
  8015e9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015ec:	6a 00                	push   $0x0
  8015ee:	57                   	push   %edi
  8015ef:	6a 00                	push   $0x0
  8015f1:	e8 e6 f5 ff ff       	call   800bdc <sys_page_map>
  8015f6:	89 c7                	mov    %eax,%edi
  8015f8:	83 c4 20             	add    $0x20,%esp
  8015fb:	85 c0                	test   %eax,%eax
  8015fd:	78 2e                	js     80162d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015ff:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801602:	89 d0                	mov    %edx,%eax
  801604:	c1 e8 0c             	shr    $0xc,%eax
  801607:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80160e:	83 ec 0c             	sub    $0xc,%esp
  801611:	25 07 0e 00 00       	and    $0xe07,%eax
  801616:	50                   	push   %eax
  801617:	53                   	push   %ebx
  801618:	6a 00                	push   $0x0
  80161a:	52                   	push   %edx
  80161b:	6a 00                	push   $0x0
  80161d:	e8 ba f5 ff ff       	call   800bdc <sys_page_map>
  801622:	89 c7                	mov    %eax,%edi
  801624:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801627:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801629:	85 ff                	test   %edi,%edi
  80162b:	79 1d                	jns    80164a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80162d:	83 ec 08             	sub    $0x8,%esp
  801630:	53                   	push   %ebx
  801631:	6a 00                	push   $0x0
  801633:	e8 e6 f5 ff ff       	call   800c1e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801638:	83 c4 08             	add    $0x8,%esp
  80163b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80163e:	6a 00                	push   $0x0
  801640:	e8 d9 f5 ff ff       	call   800c1e <sys_page_unmap>
	return r;
  801645:	83 c4 10             	add    $0x10,%esp
  801648:	89 f8                	mov    %edi,%eax
}
  80164a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80164d:	5b                   	pop    %ebx
  80164e:	5e                   	pop    %esi
  80164f:	5f                   	pop    %edi
  801650:	5d                   	pop    %ebp
  801651:	c3                   	ret    

00801652 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801652:	55                   	push   %ebp
  801653:	89 e5                	mov    %esp,%ebp
  801655:	53                   	push   %ebx
  801656:	83 ec 14             	sub    $0x14,%esp
  801659:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80165c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80165f:	50                   	push   %eax
  801660:	53                   	push   %ebx
  801661:	e8 83 fd ff ff       	call   8013e9 <fd_lookup>
  801666:	83 c4 08             	add    $0x8,%esp
  801669:	89 c2                	mov    %eax,%edx
  80166b:	85 c0                	test   %eax,%eax
  80166d:	78 70                	js     8016df <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166f:	83 ec 08             	sub    $0x8,%esp
  801672:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801675:	50                   	push   %eax
  801676:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801679:	ff 30                	pushl  (%eax)
  80167b:	e8 bf fd ff ff       	call   80143f <dev_lookup>
  801680:	83 c4 10             	add    $0x10,%esp
  801683:	85 c0                	test   %eax,%eax
  801685:	78 4f                	js     8016d6 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801687:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80168a:	8b 42 08             	mov    0x8(%edx),%eax
  80168d:	83 e0 03             	and    $0x3,%eax
  801690:	83 f8 01             	cmp    $0x1,%eax
  801693:	75 24                	jne    8016b9 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801695:	a1 04 40 80 00       	mov    0x804004,%eax
  80169a:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8016a0:	83 ec 04             	sub    $0x4,%esp
  8016a3:	53                   	push   %ebx
  8016a4:	50                   	push   %eax
  8016a5:	68 08 29 80 00       	push   $0x802908
  8016aa:	e8 62 eb ff ff       	call   800211 <cprintf>
		return -E_INVAL;
  8016af:	83 c4 10             	add    $0x10,%esp
  8016b2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016b7:	eb 26                	jmp    8016df <read+0x8d>
	}
	if (!dev->dev_read)
  8016b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016bc:	8b 40 08             	mov    0x8(%eax),%eax
  8016bf:	85 c0                	test   %eax,%eax
  8016c1:	74 17                	je     8016da <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8016c3:	83 ec 04             	sub    $0x4,%esp
  8016c6:	ff 75 10             	pushl  0x10(%ebp)
  8016c9:	ff 75 0c             	pushl  0xc(%ebp)
  8016cc:	52                   	push   %edx
  8016cd:	ff d0                	call   *%eax
  8016cf:	89 c2                	mov    %eax,%edx
  8016d1:	83 c4 10             	add    $0x10,%esp
  8016d4:	eb 09                	jmp    8016df <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d6:	89 c2                	mov    %eax,%edx
  8016d8:	eb 05                	jmp    8016df <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016da:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8016df:	89 d0                	mov    %edx,%eax
  8016e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e4:	c9                   	leave  
  8016e5:	c3                   	ret    

008016e6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016e6:	55                   	push   %ebp
  8016e7:	89 e5                	mov    %esp,%ebp
  8016e9:	57                   	push   %edi
  8016ea:	56                   	push   %esi
  8016eb:	53                   	push   %ebx
  8016ec:	83 ec 0c             	sub    $0xc,%esp
  8016ef:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016f2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016f5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016fa:	eb 21                	jmp    80171d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016fc:	83 ec 04             	sub    $0x4,%esp
  8016ff:	89 f0                	mov    %esi,%eax
  801701:	29 d8                	sub    %ebx,%eax
  801703:	50                   	push   %eax
  801704:	89 d8                	mov    %ebx,%eax
  801706:	03 45 0c             	add    0xc(%ebp),%eax
  801709:	50                   	push   %eax
  80170a:	57                   	push   %edi
  80170b:	e8 42 ff ff ff       	call   801652 <read>
		if (m < 0)
  801710:	83 c4 10             	add    $0x10,%esp
  801713:	85 c0                	test   %eax,%eax
  801715:	78 10                	js     801727 <readn+0x41>
			return m;
		if (m == 0)
  801717:	85 c0                	test   %eax,%eax
  801719:	74 0a                	je     801725 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80171b:	01 c3                	add    %eax,%ebx
  80171d:	39 f3                	cmp    %esi,%ebx
  80171f:	72 db                	jb     8016fc <readn+0x16>
  801721:	89 d8                	mov    %ebx,%eax
  801723:	eb 02                	jmp    801727 <readn+0x41>
  801725:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801727:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80172a:	5b                   	pop    %ebx
  80172b:	5e                   	pop    %esi
  80172c:	5f                   	pop    %edi
  80172d:	5d                   	pop    %ebp
  80172e:	c3                   	ret    

0080172f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80172f:	55                   	push   %ebp
  801730:	89 e5                	mov    %esp,%ebp
  801732:	53                   	push   %ebx
  801733:	83 ec 14             	sub    $0x14,%esp
  801736:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801739:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80173c:	50                   	push   %eax
  80173d:	53                   	push   %ebx
  80173e:	e8 a6 fc ff ff       	call   8013e9 <fd_lookup>
  801743:	83 c4 08             	add    $0x8,%esp
  801746:	89 c2                	mov    %eax,%edx
  801748:	85 c0                	test   %eax,%eax
  80174a:	78 6b                	js     8017b7 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80174c:	83 ec 08             	sub    $0x8,%esp
  80174f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801752:	50                   	push   %eax
  801753:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801756:	ff 30                	pushl  (%eax)
  801758:	e8 e2 fc ff ff       	call   80143f <dev_lookup>
  80175d:	83 c4 10             	add    $0x10,%esp
  801760:	85 c0                	test   %eax,%eax
  801762:	78 4a                	js     8017ae <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801764:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801767:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80176b:	75 24                	jne    801791 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80176d:	a1 04 40 80 00       	mov    0x804004,%eax
  801772:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801778:	83 ec 04             	sub    $0x4,%esp
  80177b:	53                   	push   %ebx
  80177c:	50                   	push   %eax
  80177d:	68 24 29 80 00       	push   $0x802924
  801782:	e8 8a ea ff ff       	call   800211 <cprintf>
		return -E_INVAL;
  801787:	83 c4 10             	add    $0x10,%esp
  80178a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80178f:	eb 26                	jmp    8017b7 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801791:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801794:	8b 52 0c             	mov    0xc(%edx),%edx
  801797:	85 d2                	test   %edx,%edx
  801799:	74 17                	je     8017b2 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80179b:	83 ec 04             	sub    $0x4,%esp
  80179e:	ff 75 10             	pushl  0x10(%ebp)
  8017a1:	ff 75 0c             	pushl  0xc(%ebp)
  8017a4:	50                   	push   %eax
  8017a5:	ff d2                	call   *%edx
  8017a7:	89 c2                	mov    %eax,%edx
  8017a9:	83 c4 10             	add    $0x10,%esp
  8017ac:	eb 09                	jmp    8017b7 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ae:	89 c2                	mov    %eax,%edx
  8017b0:	eb 05                	jmp    8017b7 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017b2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8017b7:	89 d0                	mov    %edx,%eax
  8017b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017bc:	c9                   	leave  
  8017bd:	c3                   	ret    

008017be <seek>:

int
seek(int fdnum, off_t offset)
{
  8017be:	55                   	push   %ebp
  8017bf:	89 e5                	mov    %esp,%ebp
  8017c1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017c4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017c7:	50                   	push   %eax
  8017c8:	ff 75 08             	pushl  0x8(%ebp)
  8017cb:	e8 19 fc ff ff       	call   8013e9 <fd_lookup>
  8017d0:	83 c4 08             	add    $0x8,%esp
  8017d3:	85 c0                	test   %eax,%eax
  8017d5:	78 0e                	js     8017e5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8017d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017dd:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017e5:	c9                   	leave  
  8017e6:	c3                   	ret    

008017e7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	53                   	push   %ebx
  8017eb:	83 ec 14             	sub    $0x14,%esp
  8017ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017f4:	50                   	push   %eax
  8017f5:	53                   	push   %ebx
  8017f6:	e8 ee fb ff ff       	call   8013e9 <fd_lookup>
  8017fb:	83 c4 08             	add    $0x8,%esp
  8017fe:	89 c2                	mov    %eax,%edx
  801800:	85 c0                	test   %eax,%eax
  801802:	78 68                	js     80186c <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801804:	83 ec 08             	sub    $0x8,%esp
  801807:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80180a:	50                   	push   %eax
  80180b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80180e:	ff 30                	pushl  (%eax)
  801810:	e8 2a fc ff ff       	call   80143f <dev_lookup>
  801815:	83 c4 10             	add    $0x10,%esp
  801818:	85 c0                	test   %eax,%eax
  80181a:	78 47                	js     801863 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80181c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80181f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801823:	75 24                	jne    801849 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801825:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80182a:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801830:	83 ec 04             	sub    $0x4,%esp
  801833:	53                   	push   %ebx
  801834:	50                   	push   %eax
  801835:	68 e4 28 80 00       	push   $0x8028e4
  80183a:	e8 d2 e9 ff ff       	call   800211 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80183f:	83 c4 10             	add    $0x10,%esp
  801842:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801847:	eb 23                	jmp    80186c <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801849:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80184c:	8b 52 18             	mov    0x18(%edx),%edx
  80184f:	85 d2                	test   %edx,%edx
  801851:	74 14                	je     801867 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801853:	83 ec 08             	sub    $0x8,%esp
  801856:	ff 75 0c             	pushl  0xc(%ebp)
  801859:	50                   	push   %eax
  80185a:	ff d2                	call   *%edx
  80185c:	89 c2                	mov    %eax,%edx
  80185e:	83 c4 10             	add    $0x10,%esp
  801861:	eb 09                	jmp    80186c <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801863:	89 c2                	mov    %eax,%edx
  801865:	eb 05                	jmp    80186c <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801867:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80186c:	89 d0                	mov    %edx,%eax
  80186e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801871:	c9                   	leave  
  801872:	c3                   	ret    

00801873 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801873:	55                   	push   %ebp
  801874:	89 e5                	mov    %esp,%ebp
  801876:	53                   	push   %ebx
  801877:	83 ec 14             	sub    $0x14,%esp
  80187a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80187d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801880:	50                   	push   %eax
  801881:	ff 75 08             	pushl  0x8(%ebp)
  801884:	e8 60 fb ff ff       	call   8013e9 <fd_lookup>
  801889:	83 c4 08             	add    $0x8,%esp
  80188c:	89 c2                	mov    %eax,%edx
  80188e:	85 c0                	test   %eax,%eax
  801890:	78 58                	js     8018ea <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801892:	83 ec 08             	sub    $0x8,%esp
  801895:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801898:	50                   	push   %eax
  801899:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80189c:	ff 30                	pushl  (%eax)
  80189e:	e8 9c fb ff ff       	call   80143f <dev_lookup>
  8018a3:	83 c4 10             	add    $0x10,%esp
  8018a6:	85 c0                	test   %eax,%eax
  8018a8:	78 37                	js     8018e1 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8018aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ad:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018b1:	74 32                	je     8018e5 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018b3:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018b6:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018bd:	00 00 00 
	stat->st_isdir = 0;
  8018c0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018c7:	00 00 00 
	stat->st_dev = dev;
  8018ca:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018d0:	83 ec 08             	sub    $0x8,%esp
  8018d3:	53                   	push   %ebx
  8018d4:	ff 75 f0             	pushl  -0x10(%ebp)
  8018d7:	ff 50 14             	call   *0x14(%eax)
  8018da:	89 c2                	mov    %eax,%edx
  8018dc:	83 c4 10             	add    $0x10,%esp
  8018df:	eb 09                	jmp    8018ea <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018e1:	89 c2                	mov    %eax,%edx
  8018e3:	eb 05                	jmp    8018ea <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018e5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018ea:	89 d0                	mov    %edx,%eax
  8018ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ef:	c9                   	leave  
  8018f0:	c3                   	ret    

008018f1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018f1:	55                   	push   %ebp
  8018f2:	89 e5                	mov    %esp,%ebp
  8018f4:	56                   	push   %esi
  8018f5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018f6:	83 ec 08             	sub    $0x8,%esp
  8018f9:	6a 00                	push   $0x0
  8018fb:	ff 75 08             	pushl  0x8(%ebp)
  8018fe:	e8 e3 01 00 00       	call   801ae6 <open>
  801903:	89 c3                	mov    %eax,%ebx
  801905:	83 c4 10             	add    $0x10,%esp
  801908:	85 c0                	test   %eax,%eax
  80190a:	78 1b                	js     801927 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80190c:	83 ec 08             	sub    $0x8,%esp
  80190f:	ff 75 0c             	pushl  0xc(%ebp)
  801912:	50                   	push   %eax
  801913:	e8 5b ff ff ff       	call   801873 <fstat>
  801918:	89 c6                	mov    %eax,%esi
	close(fd);
  80191a:	89 1c 24             	mov    %ebx,(%esp)
  80191d:	e8 f4 fb ff ff       	call   801516 <close>
	return r;
  801922:	83 c4 10             	add    $0x10,%esp
  801925:	89 f0                	mov    %esi,%eax
}
  801927:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80192a:	5b                   	pop    %ebx
  80192b:	5e                   	pop    %esi
  80192c:	5d                   	pop    %ebp
  80192d:	c3                   	ret    

0080192e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80192e:	55                   	push   %ebp
  80192f:	89 e5                	mov    %esp,%ebp
  801931:	56                   	push   %esi
  801932:	53                   	push   %ebx
  801933:	89 c6                	mov    %eax,%esi
  801935:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801937:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80193e:	75 12                	jne    801952 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801940:	83 ec 0c             	sub    $0xc,%esp
  801943:	6a 01                	push   $0x1
  801945:	e8 05 08 00 00       	call   80214f <ipc_find_env>
  80194a:	a3 00 40 80 00       	mov    %eax,0x804000
  80194f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801952:	6a 07                	push   $0x7
  801954:	68 00 50 80 00       	push   $0x805000
  801959:	56                   	push   %esi
  80195a:	ff 35 00 40 80 00    	pushl  0x804000
  801960:	e8 88 07 00 00       	call   8020ed <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801965:	83 c4 0c             	add    $0xc,%esp
  801968:	6a 00                	push   $0x0
  80196a:	53                   	push   %ebx
  80196b:	6a 00                	push   $0x0
  80196d:	e8 00 07 00 00       	call   802072 <ipc_recv>
}
  801972:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801975:	5b                   	pop    %ebx
  801976:	5e                   	pop    %esi
  801977:	5d                   	pop    %ebp
  801978:	c3                   	ret    

00801979 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801979:	55                   	push   %ebp
  80197a:	89 e5                	mov    %esp,%ebp
  80197c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80197f:	8b 45 08             	mov    0x8(%ebp),%eax
  801982:	8b 40 0c             	mov    0xc(%eax),%eax
  801985:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80198a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80198d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801992:	ba 00 00 00 00       	mov    $0x0,%edx
  801997:	b8 02 00 00 00       	mov    $0x2,%eax
  80199c:	e8 8d ff ff ff       	call   80192e <fsipc>
}
  8019a1:	c9                   	leave  
  8019a2:	c3                   	ret    

008019a3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019a3:	55                   	push   %ebp
  8019a4:	89 e5                	mov    %esp,%ebp
  8019a6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ac:	8b 40 0c             	mov    0xc(%eax),%eax
  8019af:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b9:	b8 06 00 00 00       	mov    $0x6,%eax
  8019be:	e8 6b ff ff ff       	call   80192e <fsipc>
}
  8019c3:	c9                   	leave  
  8019c4:	c3                   	ret    

008019c5 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019c5:	55                   	push   %ebp
  8019c6:	89 e5                	mov    %esp,%ebp
  8019c8:	53                   	push   %ebx
  8019c9:	83 ec 04             	sub    $0x4,%esp
  8019cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d2:	8b 40 0c             	mov    0xc(%eax),%eax
  8019d5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019da:	ba 00 00 00 00       	mov    $0x0,%edx
  8019df:	b8 05 00 00 00       	mov    $0x5,%eax
  8019e4:	e8 45 ff ff ff       	call   80192e <fsipc>
  8019e9:	85 c0                	test   %eax,%eax
  8019eb:	78 2c                	js     801a19 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019ed:	83 ec 08             	sub    $0x8,%esp
  8019f0:	68 00 50 80 00       	push   $0x805000
  8019f5:	53                   	push   %ebx
  8019f6:	e8 9b ed ff ff       	call   800796 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019fb:	a1 80 50 80 00       	mov    0x805080,%eax
  801a00:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a06:	a1 84 50 80 00       	mov    0x805084,%eax
  801a0b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a11:	83 c4 10             	add    $0x10,%esp
  801a14:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a1c:	c9                   	leave  
  801a1d:	c3                   	ret    

00801a1e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a1e:	55                   	push   %ebp
  801a1f:	89 e5                	mov    %esp,%ebp
  801a21:	83 ec 0c             	sub    $0xc,%esp
  801a24:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a27:	8b 55 08             	mov    0x8(%ebp),%edx
  801a2a:	8b 52 0c             	mov    0xc(%edx),%edx
  801a2d:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801a33:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a38:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a3d:	0f 47 c2             	cmova  %edx,%eax
  801a40:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801a45:	50                   	push   %eax
  801a46:	ff 75 0c             	pushl  0xc(%ebp)
  801a49:	68 08 50 80 00       	push   $0x805008
  801a4e:	e8 d5 ee ff ff       	call   800928 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801a53:	ba 00 00 00 00       	mov    $0x0,%edx
  801a58:	b8 04 00 00 00       	mov    $0x4,%eax
  801a5d:	e8 cc fe ff ff       	call   80192e <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801a62:	c9                   	leave  
  801a63:	c3                   	ret    

00801a64 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a64:	55                   	push   %ebp
  801a65:	89 e5                	mov    %esp,%ebp
  801a67:	56                   	push   %esi
  801a68:	53                   	push   %ebx
  801a69:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6f:	8b 40 0c             	mov    0xc(%eax),%eax
  801a72:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a77:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a7d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a82:	b8 03 00 00 00       	mov    $0x3,%eax
  801a87:	e8 a2 fe ff ff       	call   80192e <fsipc>
  801a8c:	89 c3                	mov    %eax,%ebx
  801a8e:	85 c0                	test   %eax,%eax
  801a90:	78 4b                	js     801add <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a92:	39 c6                	cmp    %eax,%esi
  801a94:	73 16                	jae    801aac <devfile_read+0x48>
  801a96:	68 54 29 80 00       	push   $0x802954
  801a9b:	68 5b 29 80 00       	push   $0x80295b
  801aa0:	6a 7c                	push   $0x7c
  801aa2:	68 70 29 80 00       	push   $0x802970
  801aa7:	e8 8c e6 ff ff       	call   800138 <_panic>
	assert(r <= PGSIZE);
  801aac:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ab1:	7e 16                	jle    801ac9 <devfile_read+0x65>
  801ab3:	68 7b 29 80 00       	push   $0x80297b
  801ab8:	68 5b 29 80 00       	push   $0x80295b
  801abd:	6a 7d                	push   $0x7d
  801abf:	68 70 29 80 00       	push   $0x802970
  801ac4:	e8 6f e6 ff ff       	call   800138 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ac9:	83 ec 04             	sub    $0x4,%esp
  801acc:	50                   	push   %eax
  801acd:	68 00 50 80 00       	push   $0x805000
  801ad2:	ff 75 0c             	pushl  0xc(%ebp)
  801ad5:	e8 4e ee ff ff       	call   800928 <memmove>
	return r;
  801ada:	83 c4 10             	add    $0x10,%esp
}
  801add:	89 d8                	mov    %ebx,%eax
  801adf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ae2:	5b                   	pop    %ebx
  801ae3:	5e                   	pop    %esi
  801ae4:	5d                   	pop    %ebp
  801ae5:	c3                   	ret    

00801ae6 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ae6:	55                   	push   %ebp
  801ae7:	89 e5                	mov    %esp,%ebp
  801ae9:	53                   	push   %ebx
  801aea:	83 ec 20             	sub    $0x20,%esp
  801aed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801af0:	53                   	push   %ebx
  801af1:	e8 67 ec ff ff       	call   80075d <strlen>
  801af6:	83 c4 10             	add    $0x10,%esp
  801af9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801afe:	7f 67                	jg     801b67 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b00:	83 ec 0c             	sub    $0xc,%esp
  801b03:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b06:	50                   	push   %eax
  801b07:	e8 8e f8 ff ff       	call   80139a <fd_alloc>
  801b0c:	83 c4 10             	add    $0x10,%esp
		return r;
  801b0f:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b11:	85 c0                	test   %eax,%eax
  801b13:	78 57                	js     801b6c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b15:	83 ec 08             	sub    $0x8,%esp
  801b18:	53                   	push   %ebx
  801b19:	68 00 50 80 00       	push   $0x805000
  801b1e:	e8 73 ec ff ff       	call   800796 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b23:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b26:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b2b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b2e:	b8 01 00 00 00       	mov    $0x1,%eax
  801b33:	e8 f6 fd ff ff       	call   80192e <fsipc>
  801b38:	89 c3                	mov    %eax,%ebx
  801b3a:	83 c4 10             	add    $0x10,%esp
  801b3d:	85 c0                	test   %eax,%eax
  801b3f:	79 14                	jns    801b55 <open+0x6f>
		fd_close(fd, 0);
  801b41:	83 ec 08             	sub    $0x8,%esp
  801b44:	6a 00                	push   $0x0
  801b46:	ff 75 f4             	pushl  -0xc(%ebp)
  801b49:	e8 47 f9 ff ff       	call   801495 <fd_close>
		return r;
  801b4e:	83 c4 10             	add    $0x10,%esp
  801b51:	89 da                	mov    %ebx,%edx
  801b53:	eb 17                	jmp    801b6c <open+0x86>
	}

	return fd2num(fd);
  801b55:	83 ec 0c             	sub    $0xc,%esp
  801b58:	ff 75 f4             	pushl  -0xc(%ebp)
  801b5b:	e8 13 f8 ff ff       	call   801373 <fd2num>
  801b60:	89 c2                	mov    %eax,%edx
  801b62:	83 c4 10             	add    $0x10,%esp
  801b65:	eb 05                	jmp    801b6c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b67:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b6c:	89 d0                	mov    %edx,%eax
  801b6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b71:	c9                   	leave  
  801b72:	c3                   	ret    

00801b73 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b73:	55                   	push   %ebp
  801b74:	89 e5                	mov    %esp,%ebp
  801b76:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b79:	ba 00 00 00 00       	mov    $0x0,%edx
  801b7e:	b8 08 00 00 00       	mov    $0x8,%eax
  801b83:	e8 a6 fd ff ff       	call   80192e <fsipc>
}
  801b88:	c9                   	leave  
  801b89:	c3                   	ret    

00801b8a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b8a:	55                   	push   %ebp
  801b8b:	89 e5                	mov    %esp,%ebp
  801b8d:	56                   	push   %esi
  801b8e:	53                   	push   %ebx
  801b8f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b92:	83 ec 0c             	sub    $0xc,%esp
  801b95:	ff 75 08             	pushl  0x8(%ebp)
  801b98:	e8 e6 f7 ff ff       	call   801383 <fd2data>
  801b9d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b9f:	83 c4 08             	add    $0x8,%esp
  801ba2:	68 87 29 80 00       	push   $0x802987
  801ba7:	53                   	push   %ebx
  801ba8:	e8 e9 eb ff ff       	call   800796 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bad:	8b 46 04             	mov    0x4(%esi),%eax
  801bb0:	2b 06                	sub    (%esi),%eax
  801bb2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801bb8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bbf:	00 00 00 
	stat->st_dev = &devpipe;
  801bc2:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801bc9:	30 80 00 
	return 0;
}
  801bcc:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bd4:	5b                   	pop    %ebx
  801bd5:	5e                   	pop    %esi
  801bd6:	5d                   	pop    %ebp
  801bd7:	c3                   	ret    

00801bd8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bd8:	55                   	push   %ebp
  801bd9:	89 e5                	mov    %esp,%ebp
  801bdb:	53                   	push   %ebx
  801bdc:	83 ec 0c             	sub    $0xc,%esp
  801bdf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801be2:	53                   	push   %ebx
  801be3:	6a 00                	push   $0x0
  801be5:	e8 34 f0 ff ff       	call   800c1e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bea:	89 1c 24             	mov    %ebx,(%esp)
  801bed:	e8 91 f7 ff ff       	call   801383 <fd2data>
  801bf2:	83 c4 08             	add    $0x8,%esp
  801bf5:	50                   	push   %eax
  801bf6:	6a 00                	push   $0x0
  801bf8:	e8 21 f0 ff ff       	call   800c1e <sys_page_unmap>
}
  801bfd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c00:	c9                   	leave  
  801c01:	c3                   	ret    

00801c02 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c02:	55                   	push   %ebp
  801c03:	89 e5                	mov    %esp,%ebp
  801c05:	57                   	push   %edi
  801c06:	56                   	push   %esi
  801c07:	53                   	push   %ebx
  801c08:	83 ec 1c             	sub    $0x1c,%esp
  801c0b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c0e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c10:	a1 04 40 80 00       	mov    0x804004,%eax
  801c15:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c1b:	83 ec 0c             	sub    $0xc,%esp
  801c1e:	ff 75 e0             	pushl  -0x20(%ebp)
  801c21:	e8 6e 05 00 00       	call   802194 <pageref>
  801c26:	89 c3                	mov    %eax,%ebx
  801c28:	89 3c 24             	mov    %edi,(%esp)
  801c2b:	e8 64 05 00 00       	call   802194 <pageref>
  801c30:	83 c4 10             	add    $0x10,%esp
  801c33:	39 c3                	cmp    %eax,%ebx
  801c35:	0f 94 c1             	sete   %cl
  801c38:	0f b6 c9             	movzbl %cl,%ecx
  801c3b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c3e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c44:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  801c4a:	39 ce                	cmp    %ecx,%esi
  801c4c:	74 1e                	je     801c6c <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801c4e:	39 c3                	cmp    %eax,%ebx
  801c50:	75 be                	jne    801c10 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c52:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  801c58:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c5b:	50                   	push   %eax
  801c5c:	56                   	push   %esi
  801c5d:	68 8e 29 80 00       	push   $0x80298e
  801c62:	e8 aa e5 ff ff       	call   800211 <cprintf>
  801c67:	83 c4 10             	add    $0x10,%esp
  801c6a:	eb a4                	jmp    801c10 <_pipeisclosed+0xe>
	}
}
  801c6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c72:	5b                   	pop    %ebx
  801c73:	5e                   	pop    %esi
  801c74:	5f                   	pop    %edi
  801c75:	5d                   	pop    %ebp
  801c76:	c3                   	ret    

00801c77 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c77:	55                   	push   %ebp
  801c78:	89 e5                	mov    %esp,%ebp
  801c7a:	57                   	push   %edi
  801c7b:	56                   	push   %esi
  801c7c:	53                   	push   %ebx
  801c7d:	83 ec 28             	sub    $0x28,%esp
  801c80:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c83:	56                   	push   %esi
  801c84:	e8 fa f6 ff ff       	call   801383 <fd2data>
  801c89:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c8b:	83 c4 10             	add    $0x10,%esp
  801c8e:	bf 00 00 00 00       	mov    $0x0,%edi
  801c93:	eb 4b                	jmp    801ce0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c95:	89 da                	mov    %ebx,%edx
  801c97:	89 f0                	mov    %esi,%eax
  801c99:	e8 64 ff ff ff       	call   801c02 <_pipeisclosed>
  801c9e:	85 c0                	test   %eax,%eax
  801ca0:	75 48                	jne    801cea <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ca2:	e8 d3 ee ff ff       	call   800b7a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ca7:	8b 43 04             	mov    0x4(%ebx),%eax
  801caa:	8b 0b                	mov    (%ebx),%ecx
  801cac:	8d 51 20             	lea    0x20(%ecx),%edx
  801caf:	39 d0                	cmp    %edx,%eax
  801cb1:	73 e2                	jae    801c95 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cb6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801cba:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801cbd:	89 c2                	mov    %eax,%edx
  801cbf:	c1 fa 1f             	sar    $0x1f,%edx
  801cc2:	89 d1                	mov    %edx,%ecx
  801cc4:	c1 e9 1b             	shr    $0x1b,%ecx
  801cc7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801cca:	83 e2 1f             	and    $0x1f,%edx
  801ccd:	29 ca                	sub    %ecx,%edx
  801ccf:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801cd3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cd7:	83 c0 01             	add    $0x1,%eax
  801cda:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cdd:	83 c7 01             	add    $0x1,%edi
  801ce0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ce3:	75 c2                	jne    801ca7 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ce5:	8b 45 10             	mov    0x10(%ebp),%eax
  801ce8:	eb 05                	jmp    801cef <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cea:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801cef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cf2:	5b                   	pop    %ebx
  801cf3:	5e                   	pop    %esi
  801cf4:	5f                   	pop    %edi
  801cf5:	5d                   	pop    %ebp
  801cf6:	c3                   	ret    

00801cf7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cf7:	55                   	push   %ebp
  801cf8:	89 e5                	mov    %esp,%ebp
  801cfa:	57                   	push   %edi
  801cfb:	56                   	push   %esi
  801cfc:	53                   	push   %ebx
  801cfd:	83 ec 18             	sub    $0x18,%esp
  801d00:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d03:	57                   	push   %edi
  801d04:	e8 7a f6 ff ff       	call   801383 <fd2data>
  801d09:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d0b:	83 c4 10             	add    $0x10,%esp
  801d0e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d13:	eb 3d                	jmp    801d52 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d15:	85 db                	test   %ebx,%ebx
  801d17:	74 04                	je     801d1d <devpipe_read+0x26>
				return i;
  801d19:	89 d8                	mov    %ebx,%eax
  801d1b:	eb 44                	jmp    801d61 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d1d:	89 f2                	mov    %esi,%edx
  801d1f:	89 f8                	mov    %edi,%eax
  801d21:	e8 dc fe ff ff       	call   801c02 <_pipeisclosed>
  801d26:	85 c0                	test   %eax,%eax
  801d28:	75 32                	jne    801d5c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d2a:	e8 4b ee ff ff       	call   800b7a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d2f:	8b 06                	mov    (%esi),%eax
  801d31:	3b 46 04             	cmp    0x4(%esi),%eax
  801d34:	74 df                	je     801d15 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d36:	99                   	cltd   
  801d37:	c1 ea 1b             	shr    $0x1b,%edx
  801d3a:	01 d0                	add    %edx,%eax
  801d3c:	83 e0 1f             	and    $0x1f,%eax
  801d3f:	29 d0                	sub    %edx,%eax
  801d41:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d49:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d4c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d4f:	83 c3 01             	add    $0x1,%ebx
  801d52:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d55:	75 d8                	jne    801d2f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d57:	8b 45 10             	mov    0x10(%ebp),%eax
  801d5a:	eb 05                	jmp    801d61 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d5c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d64:	5b                   	pop    %ebx
  801d65:	5e                   	pop    %esi
  801d66:	5f                   	pop    %edi
  801d67:	5d                   	pop    %ebp
  801d68:	c3                   	ret    

00801d69 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d69:	55                   	push   %ebp
  801d6a:	89 e5                	mov    %esp,%ebp
  801d6c:	56                   	push   %esi
  801d6d:	53                   	push   %ebx
  801d6e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d71:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d74:	50                   	push   %eax
  801d75:	e8 20 f6 ff ff       	call   80139a <fd_alloc>
  801d7a:	83 c4 10             	add    $0x10,%esp
  801d7d:	89 c2                	mov    %eax,%edx
  801d7f:	85 c0                	test   %eax,%eax
  801d81:	0f 88 2c 01 00 00    	js     801eb3 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d87:	83 ec 04             	sub    $0x4,%esp
  801d8a:	68 07 04 00 00       	push   $0x407
  801d8f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d92:	6a 00                	push   $0x0
  801d94:	e8 00 ee ff ff       	call   800b99 <sys_page_alloc>
  801d99:	83 c4 10             	add    $0x10,%esp
  801d9c:	89 c2                	mov    %eax,%edx
  801d9e:	85 c0                	test   %eax,%eax
  801da0:	0f 88 0d 01 00 00    	js     801eb3 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801da6:	83 ec 0c             	sub    $0xc,%esp
  801da9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801dac:	50                   	push   %eax
  801dad:	e8 e8 f5 ff ff       	call   80139a <fd_alloc>
  801db2:	89 c3                	mov    %eax,%ebx
  801db4:	83 c4 10             	add    $0x10,%esp
  801db7:	85 c0                	test   %eax,%eax
  801db9:	0f 88 e2 00 00 00    	js     801ea1 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dbf:	83 ec 04             	sub    $0x4,%esp
  801dc2:	68 07 04 00 00       	push   $0x407
  801dc7:	ff 75 f0             	pushl  -0x10(%ebp)
  801dca:	6a 00                	push   $0x0
  801dcc:	e8 c8 ed ff ff       	call   800b99 <sys_page_alloc>
  801dd1:	89 c3                	mov    %eax,%ebx
  801dd3:	83 c4 10             	add    $0x10,%esp
  801dd6:	85 c0                	test   %eax,%eax
  801dd8:	0f 88 c3 00 00 00    	js     801ea1 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801dde:	83 ec 0c             	sub    $0xc,%esp
  801de1:	ff 75 f4             	pushl  -0xc(%ebp)
  801de4:	e8 9a f5 ff ff       	call   801383 <fd2data>
  801de9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801deb:	83 c4 0c             	add    $0xc,%esp
  801dee:	68 07 04 00 00       	push   $0x407
  801df3:	50                   	push   %eax
  801df4:	6a 00                	push   $0x0
  801df6:	e8 9e ed ff ff       	call   800b99 <sys_page_alloc>
  801dfb:	89 c3                	mov    %eax,%ebx
  801dfd:	83 c4 10             	add    $0x10,%esp
  801e00:	85 c0                	test   %eax,%eax
  801e02:	0f 88 89 00 00 00    	js     801e91 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e08:	83 ec 0c             	sub    $0xc,%esp
  801e0b:	ff 75 f0             	pushl  -0x10(%ebp)
  801e0e:	e8 70 f5 ff ff       	call   801383 <fd2data>
  801e13:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e1a:	50                   	push   %eax
  801e1b:	6a 00                	push   $0x0
  801e1d:	56                   	push   %esi
  801e1e:	6a 00                	push   $0x0
  801e20:	e8 b7 ed ff ff       	call   800bdc <sys_page_map>
  801e25:	89 c3                	mov    %eax,%ebx
  801e27:	83 c4 20             	add    $0x20,%esp
  801e2a:	85 c0                	test   %eax,%eax
  801e2c:	78 55                	js     801e83 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e2e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e37:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e3c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e43:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e49:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e4c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e51:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e58:	83 ec 0c             	sub    $0xc,%esp
  801e5b:	ff 75 f4             	pushl  -0xc(%ebp)
  801e5e:	e8 10 f5 ff ff       	call   801373 <fd2num>
  801e63:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e66:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e68:	83 c4 04             	add    $0x4,%esp
  801e6b:	ff 75 f0             	pushl  -0x10(%ebp)
  801e6e:	e8 00 f5 ff ff       	call   801373 <fd2num>
  801e73:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e76:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801e79:	83 c4 10             	add    $0x10,%esp
  801e7c:	ba 00 00 00 00       	mov    $0x0,%edx
  801e81:	eb 30                	jmp    801eb3 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e83:	83 ec 08             	sub    $0x8,%esp
  801e86:	56                   	push   %esi
  801e87:	6a 00                	push   $0x0
  801e89:	e8 90 ed ff ff       	call   800c1e <sys_page_unmap>
  801e8e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e91:	83 ec 08             	sub    $0x8,%esp
  801e94:	ff 75 f0             	pushl  -0x10(%ebp)
  801e97:	6a 00                	push   $0x0
  801e99:	e8 80 ed ff ff       	call   800c1e <sys_page_unmap>
  801e9e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ea1:	83 ec 08             	sub    $0x8,%esp
  801ea4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ea7:	6a 00                	push   $0x0
  801ea9:	e8 70 ed ff ff       	call   800c1e <sys_page_unmap>
  801eae:	83 c4 10             	add    $0x10,%esp
  801eb1:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801eb3:	89 d0                	mov    %edx,%eax
  801eb5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eb8:	5b                   	pop    %ebx
  801eb9:	5e                   	pop    %esi
  801eba:	5d                   	pop    %ebp
  801ebb:	c3                   	ret    

00801ebc <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ebc:	55                   	push   %ebp
  801ebd:	89 e5                	mov    %esp,%ebp
  801ebf:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ec2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ec5:	50                   	push   %eax
  801ec6:	ff 75 08             	pushl  0x8(%ebp)
  801ec9:	e8 1b f5 ff ff       	call   8013e9 <fd_lookup>
  801ece:	83 c4 10             	add    $0x10,%esp
  801ed1:	85 c0                	test   %eax,%eax
  801ed3:	78 18                	js     801eed <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ed5:	83 ec 0c             	sub    $0xc,%esp
  801ed8:	ff 75 f4             	pushl  -0xc(%ebp)
  801edb:	e8 a3 f4 ff ff       	call   801383 <fd2data>
	return _pipeisclosed(fd, p);
  801ee0:	89 c2                	mov    %eax,%edx
  801ee2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee5:	e8 18 fd ff ff       	call   801c02 <_pipeisclosed>
  801eea:	83 c4 10             	add    $0x10,%esp
}
  801eed:	c9                   	leave  
  801eee:	c3                   	ret    

00801eef <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801eef:	55                   	push   %ebp
  801ef0:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ef2:	b8 00 00 00 00       	mov    $0x0,%eax
  801ef7:	5d                   	pop    %ebp
  801ef8:	c3                   	ret    

00801ef9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ef9:	55                   	push   %ebp
  801efa:	89 e5                	mov    %esp,%ebp
  801efc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801eff:	68 a6 29 80 00       	push   $0x8029a6
  801f04:	ff 75 0c             	pushl  0xc(%ebp)
  801f07:	e8 8a e8 ff ff       	call   800796 <strcpy>
	return 0;
}
  801f0c:	b8 00 00 00 00       	mov    $0x0,%eax
  801f11:	c9                   	leave  
  801f12:	c3                   	ret    

00801f13 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f13:	55                   	push   %ebp
  801f14:	89 e5                	mov    %esp,%ebp
  801f16:	57                   	push   %edi
  801f17:	56                   	push   %esi
  801f18:	53                   	push   %ebx
  801f19:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f1f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f24:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f2a:	eb 2d                	jmp    801f59 <devcons_write+0x46>
		m = n - tot;
  801f2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f2f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f31:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f34:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f39:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f3c:	83 ec 04             	sub    $0x4,%esp
  801f3f:	53                   	push   %ebx
  801f40:	03 45 0c             	add    0xc(%ebp),%eax
  801f43:	50                   	push   %eax
  801f44:	57                   	push   %edi
  801f45:	e8 de e9 ff ff       	call   800928 <memmove>
		sys_cputs(buf, m);
  801f4a:	83 c4 08             	add    $0x8,%esp
  801f4d:	53                   	push   %ebx
  801f4e:	57                   	push   %edi
  801f4f:	e8 89 eb ff ff       	call   800add <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f54:	01 de                	add    %ebx,%esi
  801f56:	83 c4 10             	add    $0x10,%esp
  801f59:	89 f0                	mov    %esi,%eax
  801f5b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f5e:	72 cc                	jb     801f2c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f63:	5b                   	pop    %ebx
  801f64:	5e                   	pop    %esi
  801f65:	5f                   	pop    %edi
  801f66:	5d                   	pop    %ebp
  801f67:	c3                   	ret    

00801f68 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f68:	55                   	push   %ebp
  801f69:	89 e5                	mov    %esp,%ebp
  801f6b:	83 ec 08             	sub    $0x8,%esp
  801f6e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f73:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f77:	74 2a                	je     801fa3 <devcons_read+0x3b>
  801f79:	eb 05                	jmp    801f80 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f7b:	e8 fa eb ff ff       	call   800b7a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f80:	e8 76 eb ff ff       	call   800afb <sys_cgetc>
  801f85:	85 c0                	test   %eax,%eax
  801f87:	74 f2                	je     801f7b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f89:	85 c0                	test   %eax,%eax
  801f8b:	78 16                	js     801fa3 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f8d:	83 f8 04             	cmp    $0x4,%eax
  801f90:	74 0c                	je     801f9e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f92:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f95:	88 02                	mov    %al,(%edx)
	return 1;
  801f97:	b8 01 00 00 00       	mov    $0x1,%eax
  801f9c:	eb 05                	jmp    801fa3 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f9e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801fa3:	c9                   	leave  
  801fa4:	c3                   	ret    

00801fa5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801fa5:	55                   	push   %ebp
  801fa6:	89 e5                	mov    %esp,%ebp
  801fa8:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801fab:	8b 45 08             	mov    0x8(%ebp),%eax
  801fae:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801fb1:	6a 01                	push   $0x1
  801fb3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fb6:	50                   	push   %eax
  801fb7:	e8 21 eb ff ff       	call   800add <sys_cputs>
}
  801fbc:	83 c4 10             	add    $0x10,%esp
  801fbf:	c9                   	leave  
  801fc0:	c3                   	ret    

00801fc1 <getchar>:

int
getchar(void)
{
  801fc1:	55                   	push   %ebp
  801fc2:	89 e5                	mov    %esp,%ebp
  801fc4:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801fc7:	6a 01                	push   $0x1
  801fc9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fcc:	50                   	push   %eax
  801fcd:	6a 00                	push   $0x0
  801fcf:	e8 7e f6 ff ff       	call   801652 <read>
	if (r < 0)
  801fd4:	83 c4 10             	add    $0x10,%esp
  801fd7:	85 c0                	test   %eax,%eax
  801fd9:	78 0f                	js     801fea <getchar+0x29>
		return r;
	if (r < 1)
  801fdb:	85 c0                	test   %eax,%eax
  801fdd:	7e 06                	jle    801fe5 <getchar+0x24>
		return -E_EOF;
	return c;
  801fdf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fe3:	eb 05                	jmp    801fea <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fe5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801fea:	c9                   	leave  
  801feb:	c3                   	ret    

00801fec <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fec:	55                   	push   %ebp
  801fed:	89 e5                	mov    %esp,%ebp
  801fef:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ff2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ff5:	50                   	push   %eax
  801ff6:	ff 75 08             	pushl  0x8(%ebp)
  801ff9:	e8 eb f3 ff ff       	call   8013e9 <fd_lookup>
  801ffe:	83 c4 10             	add    $0x10,%esp
  802001:	85 c0                	test   %eax,%eax
  802003:	78 11                	js     802016 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802005:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802008:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80200e:	39 10                	cmp    %edx,(%eax)
  802010:	0f 94 c0             	sete   %al
  802013:	0f b6 c0             	movzbl %al,%eax
}
  802016:	c9                   	leave  
  802017:	c3                   	ret    

00802018 <opencons>:

int
opencons(void)
{
  802018:	55                   	push   %ebp
  802019:	89 e5                	mov    %esp,%ebp
  80201b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80201e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802021:	50                   	push   %eax
  802022:	e8 73 f3 ff ff       	call   80139a <fd_alloc>
  802027:	83 c4 10             	add    $0x10,%esp
		return r;
  80202a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80202c:	85 c0                	test   %eax,%eax
  80202e:	78 3e                	js     80206e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802030:	83 ec 04             	sub    $0x4,%esp
  802033:	68 07 04 00 00       	push   $0x407
  802038:	ff 75 f4             	pushl  -0xc(%ebp)
  80203b:	6a 00                	push   $0x0
  80203d:	e8 57 eb ff ff       	call   800b99 <sys_page_alloc>
  802042:	83 c4 10             	add    $0x10,%esp
		return r;
  802045:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802047:	85 c0                	test   %eax,%eax
  802049:	78 23                	js     80206e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80204b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802051:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802054:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802056:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802059:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802060:	83 ec 0c             	sub    $0xc,%esp
  802063:	50                   	push   %eax
  802064:	e8 0a f3 ff ff       	call   801373 <fd2num>
  802069:	89 c2                	mov    %eax,%edx
  80206b:	83 c4 10             	add    $0x10,%esp
}
  80206e:	89 d0                	mov    %edx,%eax
  802070:	c9                   	leave  
  802071:	c3                   	ret    

00802072 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802072:	55                   	push   %ebp
  802073:	89 e5                	mov    %esp,%ebp
  802075:	56                   	push   %esi
  802076:	53                   	push   %ebx
  802077:	8b 75 08             	mov    0x8(%ebp),%esi
  80207a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80207d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802080:	85 c0                	test   %eax,%eax
  802082:	75 12                	jne    802096 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802084:	83 ec 0c             	sub    $0xc,%esp
  802087:	68 00 00 c0 ee       	push   $0xeec00000
  80208c:	e8 b8 ec ff ff       	call   800d49 <sys_ipc_recv>
  802091:	83 c4 10             	add    $0x10,%esp
  802094:	eb 0c                	jmp    8020a2 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802096:	83 ec 0c             	sub    $0xc,%esp
  802099:	50                   	push   %eax
  80209a:	e8 aa ec ff ff       	call   800d49 <sys_ipc_recv>
  80209f:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8020a2:	85 f6                	test   %esi,%esi
  8020a4:	0f 95 c1             	setne  %cl
  8020a7:	85 db                	test   %ebx,%ebx
  8020a9:	0f 95 c2             	setne  %dl
  8020ac:	84 d1                	test   %dl,%cl
  8020ae:	74 09                	je     8020b9 <ipc_recv+0x47>
  8020b0:	89 c2                	mov    %eax,%edx
  8020b2:	c1 ea 1f             	shr    $0x1f,%edx
  8020b5:	84 d2                	test   %dl,%dl
  8020b7:	75 2d                	jne    8020e6 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8020b9:	85 f6                	test   %esi,%esi
  8020bb:	74 0d                	je     8020ca <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8020bd:	a1 04 40 80 00       	mov    0x804004,%eax
  8020c2:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  8020c8:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8020ca:	85 db                	test   %ebx,%ebx
  8020cc:	74 0d                	je     8020db <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8020ce:	a1 04 40 80 00       	mov    0x804004,%eax
  8020d3:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8020d9:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8020db:	a1 04 40 80 00       	mov    0x804004,%eax
  8020e0:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  8020e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020e9:	5b                   	pop    %ebx
  8020ea:	5e                   	pop    %esi
  8020eb:	5d                   	pop    %ebp
  8020ec:	c3                   	ret    

008020ed <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020ed:	55                   	push   %ebp
  8020ee:	89 e5                	mov    %esp,%ebp
  8020f0:	57                   	push   %edi
  8020f1:	56                   	push   %esi
  8020f2:	53                   	push   %ebx
  8020f3:	83 ec 0c             	sub    $0xc,%esp
  8020f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020f9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8020ff:	85 db                	test   %ebx,%ebx
  802101:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802106:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802109:	ff 75 14             	pushl  0x14(%ebp)
  80210c:	53                   	push   %ebx
  80210d:	56                   	push   %esi
  80210e:	57                   	push   %edi
  80210f:	e8 12 ec ff ff       	call   800d26 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802114:	89 c2                	mov    %eax,%edx
  802116:	c1 ea 1f             	shr    $0x1f,%edx
  802119:	83 c4 10             	add    $0x10,%esp
  80211c:	84 d2                	test   %dl,%dl
  80211e:	74 17                	je     802137 <ipc_send+0x4a>
  802120:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802123:	74 12                	je     802137 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802125:	50                   	push   %eax
  802126:	68 b2 29 80 00       	push   $0x8029b2
  80212b:	6a 47                	push   $0x47
  80212d:	68 c0 29 80 00       	push   $0x8029c0
  802132:	e8 01 e0 ff ff       	call   800138 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802137:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80213a:	75 07                	jne    802143 <ipc_send+0x56>
			sys_yield();
  80213c:	e8 39 ea ff ff       	call   800b7a <sys_yield>
  802141:	eb c6                	jmp    802109 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802143:	85 c0                	test   %eax,%eax
  802145:	75 c2                	jne    802109 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802147:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80214a:	5b                   	pop    %ebx
  80214b:	5e                   	pop    %esi
  80214c:	5f                   	pop    %edi
  80214d:	5d                   	pop    %ebp
  80214e:	c3                   	ret    

0080214f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80214f:	55                   	push   %ebp
  802150:	89 e5                	mov    %esp,%ebp
  802152:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802155:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80215a:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  802160:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802166:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  80216c:	39 ca                	cmp    %ecx,%edx
  80216e:	75 13                	jne    802183 <ipc_find_env+0x34>
			return envs[i].env_id;
  802170:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  802176:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80217b:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  802181:	eb 0f                	jmp    802192 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802183:	83 c0 01             	add    $0x1,%eax
  802186:	3d 00 04 00 00       	cmp    $0x400,%eax
  80218b:	75 cd                	jne    80215a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80218d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802192:	5d                   	pop    %ebp
  802193:	c3                   	ret    

00802194 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802194:	55                   	push   %ebp
  802195:	89 e5                	mov    %esp,%ebp
  802197:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80219a:	89 d0                	mov    %edx,%eax
  80219c:	c1 e8 16             	shr    $0x16,%eax
  80219f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021a6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021ab:	f6 c1 01             	test   $0x1,%cl
  8021ae:	74 1d                	je     8021cd <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021b0:	c1 ea 0c             	shr    $0xc,%edx
  8021b3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021ba:	f6 c2 01             	test   $0x1,%dl
  8021bd:	74 0e                	je     8021cd <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021bf:	c1 ea 0c             	shr    $0xc,%edx
  8021c2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021c9:	ef 
  8021ca:	0f b7 c0             	movzwl %ax,%eax
}
  8021cd:	5d                   	pop    %ebp
  8021ce:	c3                   	ret    
  8021cf:	90                   	nop

008021d0 <__udivdi3>:
  8021d0:	55                   	push   %ebp
  8021d1:	57                   	push   %edi
  8021d2:	56                   	push   %esi
  8021d3:	53                   	push   %ebx
  8021d4:	83 ec 1c             	sub    $0x1c,%esp
  8021d7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8021db:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021df:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8021e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021e7:	85 f6                	test   %esi,%esi
  8021e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021ed:	89 ca                	mov    %ecx,%edx
  8021ef:	89 f8                	mov    %edi,%eax
  8021f1:	75 3d                	jne    802230 <__udivdi3+0x60>
  8021f3:	39 cf                	cmp    %ecx,%edi
  8021f5:	0f 87 c5 00 00 00    	ja     8022c0 <__udivdi3+0xf0>
  8021fb:	85 ff                	test   %edi,%edi
  8021fd:	89 fd                	mov    %edi,%ebp
  8021ff:	75 0b                	jne    80220c <__udivdi3+0x3c>
  802201:	b8 01 00 00 00       	mov    $0x1,%eax
  802206:	31 d2                	xor    %edx,%edx
  802208:	f7 f7                	div    %edi
  80220a:	89 c5                	mov    %eax,%ebp
  80220c:	89 c8                	mov    %ecx,%eax
  80220e:	31 d2                	xor    %edx,%edx
  802210:	f7 f5                	div    %ebp
  802212:	89 c1                	mov    %eax,%ecx
  802214:	89 d8                	mov    %ebx,%eax
  802216:	89 cf                	mov    %ecx,%edi
  802218:	f7 f5                	div    %ebp
  80221a:	89 c3                	mov    %eax,%ebx
  80221c:	89 d8                	mov    %ebx,%eax
  80221e:	89 fa                	mov    %edi,%edx
  802220:	83 c4 1c             	add    $0x1c,%esp
  802223:	5b                   	pop    %ebx
  802224:	5e                   	pop    %esi
  802225:	5f                   	pop    %edi
  802226:	5d                   	pop    %ebp
  802227:	c3                   	ret    
  802228:	90                   	nop
  802229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802230:	39 ce                	cmp    %ecx,%esi
  802232:	77 74                	ja     8022a8 <__udivdi3+0xd8>
  802234:	0f bd fe             	bsr    %esi,%edi
  802237:	83 f7 1f             	xor    $0x1f,%edi
  80223a:	0f 84 98 00 00 00    	je     8022d8 <__udivdi3+0x108>
  802240:	bb 20 00 00 00       	mov    $0x20,%ebx
  802245:	89 f9                	mov    %edi,%ecx
  802247:	89 c5                	mov    %eax,%ebp
  802249:	29 fb                	sub    %edi,%ebx
  80224b:	d3 e6                	shl    %cl,%esi
  80224d:	89 d9                	mov    %ebx,%ecx
  80224f:	d3 ed                	shr    %cl,%ebp
  802251:	89 f9                	mov    %edi,%ecx
  802253:	d3 e0                	shl    %cl,%eax
  802255:	09 ee                	or     %ebp,%esi
  802257:	89 d9                	mov    %ebx,%ecx
  802259:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80225d:	89 d5                	mov    %edx,%ebp
  80225f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802263:	d3 ed                	shr    %cl,%ebp
  802265:	89 f9                	mov    %edi,%ecx
  802267:	d3 e2                	shl    %cl,%edx
  802269:	89 d9                	mov    %ebx,%ecx
  80226b:	d3 e8                	shr    %cl,%eax
  80226d:	09 c2                	or     %eax,%edx
  80226f:	89 d0                	mov    %edx,%eax
  802271:	89 ea                	mov    %ebp,%edx
  802273:	f7 f6                	div    %esi
  802275:	89 d5                	mov    %edx,%ebp
  802277:	89 c3                	mov    %eax,%ebx
  802279:	f7 64 24 0c          	mull   0xc(%esp)
  80227d:	39 d5                	cmp    %edx,%ebp
  80227f:	72 10                	jb     802291 <__udivdi3+0xc1>
  802281:	8b 74 24 08          	mov    0x8(%esp),%esi
  802285:	89 f9                	mov    %edi,%ecx
  802287:	d3 e6                	shl    %cl,%esi
  802289:	39 c6                	cmp    %eax,%esi
  80228b:	73 07                	jae    802294 <__udivdi3+0xc4>
  80228d:	39 d5                	cmp    %edx,%ebp
  80228f:	75 03                	jne    802294 <__udivdi3+0xc4>
  802291:	83 eb 01             	sub    $0x1,%ebx
  802294:	31 ff                	xor    %edi,%edi
  802296:	89 d8                	mov    %ebx,%eax
  802298:	89 fa                	mov    %edi,%edx
  80229a:	83 c4 1c             	add    $0x1c,%esp
  80229d:	5b                   	pop    %ebx
  80229e:	5e                   	pop    %esi
  80229f:	5f                   	pop    %edi
  8022a0:	5d                   	pop    %ebp
  8022a1:	c3                   	ret    
  8022a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022a8:	31 ff                	xor    %edi,%edi
  8022aa:	31 db                	xor    %ebx,%ebx
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
  8022c0:	89 d8                	mov    %ebx,%eax
  8022c2:	f7 f7                	div    %edi
  8022c4:	31 ff                	xor    %edi,%edi
  8022c6:	89 c3                	mov    %eax,%ebx
  8022c8:	89 d8                	mov    %ebx,%eax
  8022ca:	89 fa                	mov    %edi,%edx
  8022cc:	83 c4 1c             	add    $0x1c,%esp
  8022cf:	5b                   	pop    %ebx
  8022d0:	5e                   	pop    %esi
  8022d1:	5f                   	pop    %edi
  8022d2:	5d                   	pop    %ebp
  8022d3:	c3                   	ret    
  8022d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022d8:	39 ce                	cmp    %ecx,%esi
  8022da:	72 0c                	jb     8022e8 <__udivdi3+0x118>
  8022dc:	31 db                	xor    %ebx,%ebx
  8022de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8022e2:	0f 87 34 ff ff ff    	ja     80221c <__udivdi3+0x4c>
  8022e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8022ed:	e9 2a ff ff ff       	jmp    80221c <__udivdi3+0x4c>
  8022f2:	66 90                	xchg   %ax,%ax
  8022f4:	66 90                	xchg   %ax,%ax
  8022f6:	66 90                	xchg   %ax,%ax
  8022f8:	66 90                	xchg   %ax,%ax
  8022fa:	66 90                	xchg   %ax,%ax
  8022fc:	66 90                	xchg   %ax,%ax
  8022fe:	66 90                	xchg   %ax,%ax

00802300 <__umoddi3>:
  802300:	55                   	push   %ebp
  802301:	57                   	push   %edi
  802302:	56                   	push   %esi
  802303:	53                   	push   %ebx
  802304:	83 ec 1c             	sub    $0x1c,%esp
  802307:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80230b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80230f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802313:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802317:	85 d2                	test   %edx,%edx
  802319:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80231d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802321:	89 f3                	mov    %esi,%ebx
  802323:	89 3c 24             	mov    %edi,(%esp)
  802326:	89 74 24 04          	mov    %esi,0x4(%esp)
  80232a:	75 1c                	jne    802348 <__umoddi3+0x48>
  80232c:	39 f7                	cmp    %esi,%edi
  80232e:	76 50                	jbe    802380 <__umoddi3+0x80>
  802330:	89 c8                	mov    %ecx,%eax
  802332:	89 f2                	mov    %esi,%edx
  802334:	f7 f7                	div    %edi
  802336:	89 d0                	mov    %edx,%eax
  802338:	31 d2                	xor    %edx,%edx
  80233a:	83 c4 1c             	add    $0x1c,%esp
  80233d:	5b                   	pop    %ebx
  80233e:	5e                   	pop    %esi
  80233f:	5f                   	pop    %edi
  802340:	5d                   	pop    %ebp
  802341:	c3                   	ret    
  802342:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802348:	39 f2                	cmp    %esi,%edx
  80234a:	89 d0                	mov    %edx,%eax
  80234c:	77 52                	ja     8023a0 <__umoddi3+0xa0>
  80234e:	0f bd ea             	bsr    %edx,%ebp
  802351:	83 f5 1f             	xor    $0x1f,%ebp
  802354:	75 5a                	jne    8023b0 <__umoddi3+0xb0>
  802356:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80235a:	0f 82 e0 00 00 00    	jb     802440 <__umoddi3+0x140>
  802360:	39 0c 24             	cmp    %ecx,(%esp)
  802363:	0f 86 d7 00 00 00    	jbe    802440 <__umoddi3+0x140>
  802369:	8b 44 24 08          	mov    0x8(%esp),%eax
  80236d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802371:	83 c4 1c             	add    $0x1c,%esp
  802374:	5b                   	pop    %ebx
  802375:	5e                   	pop    %esi
  802376:	5f                   	pop    %edi
  802377:	5d                   	pop    %ebp
  802378:	c3                   	ret    
  802379:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802380:	85 ff                	test   %edi,%edi
  802382:	89 fd                	mov    %edi,%ebp
  802384:	75 0b                	jne    802391 <__umoddi3+0x91>
  802386:	b8 01 00 00 00       	mov    $0x1,%eax
  80238b:	31 d2                	xor    %edx,%edx
  80238d:	f7 f7                	div    %edi
  80238f:	89 c5                	mov    %eax,%ebp
  802391:	89 f0                	mov    %esi,%eax
  802393:	31 d2                	xor    %edx,%edx
  802395:	f7 f5                	div    %ebp
  802397:	89 c8                	mov    %ecx,%eax
  802399:	f7 f5                	div    %ebp
  80239b:	89 d0                	mov    %edx,%eax
  80239d:	eb 99                	jmp    802338 <__umoddi3+0x38>
  80239f:	90                   	nop
  8023a0:	89 c8                	mov    %ecx,%eax
  8023a2:	89 f2                	mov    %esi,%edx
  8023a4:	83 c4 1c             	add    $0x1c,%esp
  8023a7:	5b                   	pop    %ebx
  8023a8:	5e                   	pop    %esi
  8023a9:	5f                   	pop    %edi
  8023aa:	5d                   	pop    %ebp
  8023ab:	c3                   	ret    
  8023ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023b0:	8b 34 24             	mov    (%esp),%esi
  8023b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023b8:	89 e9                	mov    %ebp,%ecx
  8023ba:	29 ef                	sub    %ebp,%edi
  8023bc:	d3 e0                	shl    %cl,%eax
  8023be:	89 f9                	mov    %edi,%ecx
  8023c0:	89 f2                	mov    %esi,%edx
  8023c2:	d3 ea                	shr    %cl,%edx
  8023c4:	89 e9                	mov    %ebp,%ecx
  8023c6:	09 c2                	or     %eax,%edx
  8023c8:	89 d8                	mov    %ebx,%eax
  8023ca:	89 14 24             	mov    %edx,(%esp)
  8023cd:	89 f2                	mov    %esi,%edx
  8023cf:	d3 e2                	shl    %cl,%edx
  8023d1:	89 f9                	mov    %edi,%ecx
  8023d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8023db:	d3 e8                	shr    %cl,%eax
  8023dd:	89 e9                	mov    %ebp,%ecx
  8023df:	89 c6                	mov    %eax,%esi
  8023e1:	d3 e3                	shl    %cl,%ebx
  8023e3:	89 f9                	mov    %edi,%ecx
  8023e5:	89 d0                	mov    %edx,%eax
  8023e7:	d3 e8                	shr    %cl,%eax
  8023e9:	89 e9                	mov    %ebp,%ecx
  8023eb:	09 d8                	or     %ebx,%eax
  8023ed:	89 d3                	mov    %edx,%ebx
  8023ef:	89 f2                	mov    %esi,%edx
  8023f1:	f7 34 24             	divl   (%esp)
  8023f4:	89 d6                	mov    %edx,%esi
  8023f6:	d3 e3                	shl    %cl,%ebx
  8023f8:	f7 64 24 04          	mull   0x4(%esp)
  8023fc:	39 d6                	cmp    %edx,%esi
  8023fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802402:	89 d1                	mov    %edx,%ecx
  802404:	89 c3                	mov    %eax,%ebx
  802406:	72 08                	jb     802410 <__umoddi3+0x110>
  802408:	75 11                	jne    80241b <__umoddi3+0x11b>
  80240a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80240e:	73 0b                	jae    80241b <__umoddi3+0x11b>
  802410:	2b 44 24 04          	sub    0x4(%esp),%eax
  802414:	1b 14 24             	sbb    (%esp),%edx
  802417:	89 d1                	mov    %edx,%ecx
  802419:	89 c3                	mov    %eax,%ebx
  80241b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80241f:	29 da                	sub    %ebx,%edx
  802421:	19 ce                	sbb    %ecx,%esi
  802423:	89 f9                	mov    %edi,%ecx
  802425:	89 f0                	mov    %esi,%eax
  802427:	d3 e0                	shl    %cl,%eax
  802429:	89 e9                	mov    %ebp,%ecx
  80242b:	d3 ea                	shr    %cl,%edx
  80242d:	89 e9                	mov    %ebp,%ecx
  80242f:	d3 ee                	shr    %cl,%esi
  802431:	09 d0                	or     %edx,%eax
  802433:	89 f2                	mov    %esi,%edx
  802435:	83 c4 1c             	add    $0x1c,%esp
  802438:	5b                   	pop    %ebx
  802439:	5e                   	pop    %esi
  80243a:	5f                   	pop    %edi
  80243b:	5d                   	pop    %ebp
  80243c:	c3                   	ret    
  80243d:	8d 76 00             	lea    0x0(%esi),%esi
  802440:	29 f9                	sub    %edi,%ecx
  802442:	19 d6                	sbb    %edx,%esi
  802444:	89 74 24 04          	mov    %esi,0x4(%esp)
  802448:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80244c:	e9 18 ff ff ff       	jmp    802369 <__umoddi3+0x69>
