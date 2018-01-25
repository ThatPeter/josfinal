
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
  800040:	68 40 22 80 00       	push   $0x802240
  800045:	e8 dd 01 00 00       	call   800227 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 51 0b 00 00       	call   800baf <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 60 22 80 00       	push   $0x802260
  80006f:	6a 0e                	push   $0xe
  800071:	68 4a 22 80 00       	push   $0x80224a
  800076:	e8 d3 00 00 00       	call   80014e <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 8c 22 80 00       	push   $0x80228c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 d0 06 00 00       	call   800759 <snprintf>
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
  80009c:	e8 3f 0d 00 00       	call   800de0 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 5c 22 80 00       	push   $0x80225c
  8000ae:	e8 74 01 00 00       	call   800227 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 5c 22 80 00       	push   $0x80225c
  8000c0:	e8 62 01 00 00       	call   800227 <cprintf>
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
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000d5:	e8 97 0a 00 00       	call   800b71 <sys_getenvid>
  8000da:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000df:	89 c2                	mov    %eax,%edx
  8000e1:	c1 e2 07             	shl    $0x7,%edx
  8000e4:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8000eb:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f0:	85 db                	test   %ebx,%ebx
  8000f2:	7e 07                	jle    8000fb <libmain+0x31>
		binaryname = argv[0];
  8000f4:	8b 06                	mov    (%esi),%eax
  8000f6:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000fb:	83 ec 08             	sub    $0x8,%esp
  8000fe:	56                   	push   %esi
  8000ff:	53                   	push   %ebx
  800100:	e8 8c ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  800105:	e8 2a 00 00 00       	call   800134 <exit>
}
  80010a:	83 c4 10             	add    $0x10,%esp
  80010d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800110:	5b                   	pop    %ebx
  800111:	5e                   	pop    %esi
  800112:	5d                   	pop    %ebp
  800113:	c3                   	ret    

00800114 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  80011a:	a1 0c 40 80 00       	mov    0x80400c,%eax
	func();
  80011f:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800121:	e8 4b 0a 00 00       	call   800b71 <sys_getenvid>
  800126:	83 ec 0c             	sub    $0xc,%esp
  800129:	50                   	push   %eax
  80012a:	e8 91 0c 00 00       	call   800dc0 <sys_thread_free>
}
  80012f:	83 c4 10             	add    $0x10,%esp
  800132:	c9                   	leave  
  800133:	c3                   	ret    

00800134 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80013a:	e8 ed 11 00 00       	call   80132c <close_all>
	sys_env_destroy(0);
  80013f:	83 ec 0c             	sub    $0xc,%esp
  800142:	6a 00                	push   $0x0
  800144:	e8 e7 09 00 00       	call   800b30 <sys_env_destroy>
}
  800149:	83 c4 10             	add    $0x10,%esp
  80014c:	c9                   	leave  
  80014d:	c3                   	ret    

0080014e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	56                   	push   %esi
  800152:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800153:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800156:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80015c:	e8 10 0a 00 00       	call   800b71 <sys_getenvid>
  800161:	83 ec 0c             	sub    $0xc,%esp
  800164:	ff 75 0c             	pushl  0xc(%ebp)
  800167:	ff 75 08             	pushl  0x8(%ebp)
  80016a:	56                   	push   %esi
  80016b:	50                   	push   %eax
  80016c:	68 b8 22 80 00       	push   $0x8022b8
  800171:	e8 b1 00 00 00       	call   800227 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800176:	83 c4 18             	add    $0x18,%esp
  800179:	53                   	push   %ebx
  80017a:	ff 75 10             	pushl  0x10(%ebp)
  80017d:	e8 54 00 00 00       	call   8001d6 <vcprintf>
	cprintf("\n");
  800182:	c7 04 24 73 27 80 00 	movl   $0x802773,(%esp)
  800189:	e8 99 00 00 00       	call   800227 <cprintf>
  80018e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800191:	cc                   	int3   
  800192:	eb fd                	jmp    800191 <_panic+0x43>

00800194 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	53                   	push   %ebx
  800198:	83 ec 04             	sub    $0x4,%esp
  80019b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019e:	8b 13                	mov    (%ebx),%edx
  8001a0:	8d 42 01             	lea    0x1(%edx),%eax
  8001a3:	89 03                	mov    %eax,(%ebx)
  8001a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ac:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b1:	75 1a                	jne    8001cd <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001b3:	83 ec 08             	sub    $0x8,%esp
  8001b6:	68 ff 00 00 00       	push   $0xff
  8001bb:	8d 43 08             	lea    0x8(%ebx),%eax
  8001be:	50                   	push   %eax
  8001bf:	e8 2f 09 00 00       	call   800af3 <sys_cputs>
		b->idx = 0;
  8001c4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001ca:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001cd:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d4:	c9                   	leave  
  8001d5:	c3                   	ret    

008001d6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001df:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e6:	00 00 00 
	b.cnt = 0;
  8001e9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f3:	ff 75 0c             	pushl  0xc(%ebp)
  8001f6:	ff 75 08             	pushl  0x8(%ebp)
  8001f9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ff:	50                   	push   %eax
  800200:	68 94 01 80 00       	push   $0x800194
  800205:	e8 54 01 00 00       	call   80035e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80020a:	83 c4 08             	add    $0x8,%esp
  80020d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800213:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800219:	50                   	push   %eax
  80021a:	e8 d4 08 00 00       	call   800af3 <sys_cputs>

	return b.cnt;
}
  80021f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800225:	c9                   	leave  
  800226:	c3                   	ret    

00800227 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800227:	55                   	push   %ebp
  800228:	89 e5                	mov    %esp,%ebp
  80022a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800230:	50                   	push   %eax
  800231:	ff 75 08             	pushl  0x8(%ebp)
  800234:	e8 9d ff ff ff       	call   8001d6 <vcprintf>
	va_end(ap);

	return cnt;
}
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	57                   	push   %edi
  80023f:	56                   	push   %esi
  800240:	53                   	push   %ebx
  800241:	83 ec 1c             	sub    $0x1c,%esp
  800244:	89 c7                	mov    %eax,%edi
  800246:	89 d6                	mov    %edx,%esi
  800248:	8b 45 08             	mov    0x8(%ebp),%eax
  80024b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800251:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800254:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800257:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80025f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800262:	39 d3                	cmp    %edx,%ebx
  800264:	72 05                	jb     80026b <printnum+0x30>
  800266:	39 45 10             	cmp    %eax,0x10(%ebp)
  800269:	77 45                	ja     8002b0 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026b:	83 ec 0c             	sub    $0xc,%esp
  80026e:	ff 75 18             	pushl  0x18(%ebp)
  800271:	8b 45 14             	mov    0x14(%ebp),%eax
  800274:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800277:	53                   	push   %ebx
  800278:	ff 75 10             	pushl  0x10(%ebp)
  80027b:	83 ec 08             	sub    $0x8,%esp
  80027e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800281:	ff 75 e0             	pushl  -0x20(%ebp)
  800284:	ff 75 dc             	pushl  -0x24(%ebp)
  800287:	ff 75 d8             	pushl  -0x28(%ebp)
  80028a:	e8 11 1d 00 00       	call   801fa0 <__udivdi3>
  80028f:	83 c4 18             	add    $0x18,%esp
  800292:	52                   	push   %edx
  800293:	50                   	push   %eax
  800294:	89 f2                	mov    %esi,%edx
  800296:	89 f8                	mov    %edi,%eax
  800298:	e8 9e ff ff ff       	call   80023b <printnum>
  80029d:	83 c4 20             	add    $0x20,%esp
  8002a0:	eb 18                	jmp    8002ba <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a2:	83 ec 08             	sub    $0x8,%esp
  8002a5:	56                   	push   %esi
  8002a6:	ff 75 18             	pushl  0x18(%ebp)
  8002a9:	ff d7                	call   *%edi
  8002ab:	83 c4 10             	add    $0x10,%esp
  8002ae:	eb 03                	jmp    8002b3 <printnum+0x78>
  8002b0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b3:	83 eb 01             	sub    $0x1,%ebx
  8002b6:	85 db                	test   %ebx,%ebx
  8002b8:	7f e8                	jg     8002a2 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ba:	83 ec 08             	sub    $0x8,%esp
  8002bd:	56                   	push   %esi
  8002be:	83 ec 04             	sub    $0x4,%esp
  8002c1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c7:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ca:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cd:	e8 fe 1d 00 00       	call   8020d0 <__umoddi3>
  8002d2:	83 c4 14             	add    $0x14,%esp
  8002d5:	0f be 80 db 22 80 00 	movsbl 0x8022db(%eax),%eax
  8002dc:	50                   	push   %eax
  8002dd:	ff d7                	call   *%edi
}
  8002df:	83 c4 10             	add    $0x10,%esp
  8002e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e5:	5b                   	pop    %ebx
  8002e6:	5e                   	pop    %esi
  8002e7:	5f                   	pop    %edi
  8002e8:	5d                   	pop    %ebp
  8002e9:	c3                   	ret    

008002ea <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ed:	83 fa 01             	cmp    $0x1,%edx
  8002f0:	7e 0e                	jle    800300 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f2:	8b 10                	mov    (%eax),%edx
  8002f4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f7:	89 08                	mov    %ecx,(%eax)
  8002f9:	8b 02                	mov    (%edx),%eax
  8002fb:	8b 52 04             	mov    0x4(%edx),%edx
  8002fe:	eb 22                	jmp    800322 <getuint+0x38>
	else if (lflag)
  800300:	85 d2                	test   %edx,%edx
  800302:	74 10                	je     800314 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800304:	8b 10                	mov    (%eax),%edx
  800306:	8d 4a 04             	lea    0x4(%edx),%ecx
  800309:	89 08                	mov    %ecx,(%eax)
  80030b:	8b 02                	mov    (%edx),%eax
  80030d:	ba 00 00 00 00       	mov    $0x0,%edx
  800312:	eb 0e                	jmp    800322 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800314:	8b 10                	mov    (%eax),%edx
  800316:	8d 4a 04             	lea    0x4(%edx),%ecx
  800319:	89 08                	mov    %ecx,(%eax)
  80031b:	8b 02                	mov    (%edx),%eax
  80031d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800322:	5d                   	pop    %ebp
  800323:	c3                   	ret    

00800324 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80032a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80032e:	8b 10                	mov    (%eax),%edx
  800330:	3b 50 04             	cmp    0x4(%eax),%edx
  800333:	73 0a                	jae    80033f <sprintputch+0x1b>
		*b->buf++ = ch;
  800335:	8d 4a 01             	lea    0x1(%edx),%ecx
  800338:	89 08                	mov    %ecx,(%eax)
  80033a:	8b 45 08             	mov    0x8(%ebp),%eax
  80033d:	88 02                	mov    %al,(%edx)
}
  80033f:	5d                   	pop    %ebp
  800340:	c3                   	ret    

00800341 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800341:	55                   	push   %ebp
  800342:	89 e5                	mov    %esp,%ebp
  800344:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800347:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80034a:	50                   	push   %eax
  80034b:	ff 75 10             	pushl  0x10(%ebp)
  80034e:	ff 75 0c             	pushl  0xc(%ebp)
  800351:	ff 75 08             	pushl  0x8(%ebp)
  800354:	e8 05 00 00 00       	call   80035e <vprintfmt>
	va_end(ap);
}
  800359:	83 c4 10             	add    $0x10,%esp
  80035c:	c9                   	leave  
  80035d:	c3                   	ret    

0080035e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80035e:	55                   	push   %ebp
  80035f:	89 e5                	mov    %esp,%ebp
  800361:	57                   	push   %edi
  800362:	56                   	push   %esi
  800363:	53                   	push   %ebx
  800364:	83 ec 2c             	sub    $0x2c,%esp
  800367:	8b 75 08             	mov    0x8(%ebp),%esi
  80036a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80036d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800370:	eb 12                	jmp    800384 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800372:	85 c0                	test   %eax,%eax
  800374:	0f 84 89 03 00 00    	je     800703 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80037a:	83 ec 08             	sub    $0x8,%esp
  80037d:	53                   	push   %ebx
  80037e:	50                   	push   %eax
  80037f:	ff d6                	call   *%esi
  800381:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800384:	83 c7 01             	add    $0x1,%edi
  800387:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80038b:	83 f8 25             	cmp    $0x25,%eax
  80038e:	75 e2                	jne    800372 <vprintfmt+0x14>
  800390:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800394:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80039b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ae:	eb 07                	jmp    8003b7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b7:	8d 47 01             	lea    0x1(%edi),%eax
  8003ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003bd:	0f b6 07             	movzbl (%edi),%eax
  8003c0:	0f b6 c8             	movzbl %al,%ecx
  8003c3:	83 e8 23             	sub    $0x23,%eax
  8003c6:	3c 55                	cmp    $0x55,%al
  8003c8:	0f 87 1a 03 00 00    	ja     8006e8 <vprintfmt+0x38a>
  8003ce:	0f b6 c0             	movzbl %al,%eax
  8003d1:	ff 24 85 20 24 80 00 	jmp    *0x802420(,%eax,4)
  8003d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003db:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003df:	eb d6                	jmp    8003b7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ec:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003ef:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003f3:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003f6:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003f9:	83 fa 09             	cmp    $0x9,%edx
  8003fc:	77 39                	ja     800437 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003fe:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800401:	eb e9                	jmp    8003ec <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800403:	8b 45 14             	mov    0x14(%ebp),%eax
  800406:	8d 48 04             	lea    0x4(%eax),%ecx
  800409:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80040c:	8b 00                	mov    (%eax),%eax
  80040e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800411:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800414:	eb 27                	jmp    80043d <vprintfmt+0xdf>
  800416:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800419:	85 c0                	test   %eax,%eax
  80041b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800420:	0f 49 c8             	cmovns %eax,%ecx
  800423:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800429:	eb 8c                	jmp    8003b7 <vprintfmt+0x59>
  80042b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80042e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800435:	eb 80                	jmp    8003b7 <vprintfmt+0x59>
  800437:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80043a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80043d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800441:	0f 89 70 ff ff ff    	jns    8003b7 <vprintfmt+0x59>
				width = precision, precision = -1;
  800447:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80044a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800454:	e9 5e ff ff ff       	jmp    8003b7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800459:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80045f:	e9 53 ff ff ff       	jmp    8003b7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800464:	8b 45 14             	mov    0x14(%ebp),%eax
  800467:	8d 50 04             	lea    0x4(%eax),%edx
  80046a:	89 55 14             	mov    %edx,0x14(%ebp)
  80046d:	83 ec 08             	sub    $0x8,%esp
  800470:	53                   	push   %ebx
  800471:	ff 30                	pushl  (%eax)
  800473:	ff d6                	call   *%esi
			break;
  800475:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800478:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80047b:	e9 04 ff ff ff       	jmp    800384 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800480:	8b 45 14             	mov    0x14(%ebp),%eax
  800483:	8d 50 04             	lea    0x4(%eax),%edx
  800486:	89 55 14             	mov    %edx,0x14(%ebp)
  800489:	8b 00                	mov    (%eax),%eax
  80048b:	99                   	cltd   
  80048c:	31 d0                	xor    %edx,%eax
  80048e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800490:	83 f8 0f             	cmp    $0xf,%eax
  800493:	7f 0b                	jg     8004a0 <vprintfmt+0x142>
  800495:	8b 14 85 80 25 80 00 	mov    0x802580(,%eax,4),%edx
  80049c:	85 d2                	test   %edx,%edx
  80049e:	75 18                	jne    8004b8 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004a0:	50                   	push   %eax
  8004a1:	68 f3 22 80 00       	push   $0x8022f3
  8004a6:	53                   	push   %ebx
  8004a7:	56                   	push   %esi
  8004a8:	e8 94 fe ff ff       	call   800341 <printfmt>
  8004ad:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004b3:	e9 cc fe ff ff       	jmp    800384 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004b8:	52                   	push   %edx
  8004b9:	68 41 27 80 00       	push   $0x802741
  8004be:	53                   	push   %ebx
  8004bf:	56                   	push   %esi
  8004c0:	e8 7c fe ff ff       	call   800341 <printfmt>
  8004c5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004cb:	e9 b4 fe ff ff       	jmp    800384 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d3:	8d 50 04             	lea    0x4(%eax),%edx
  8004d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004db:	85 ff                	test   %edi,%edi
  8004dd:	b8 ec 22 80 00       	mov    $0x8022ec,%eax
  8004e2:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e9:	0f 8e 94 00 00 00    	jle    800583 <vprintfmt+0x225>
  8004ef:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004f3:	0f 84 98 00 00 00    	je     800591 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f9:	83 ec 08             	sub    $0x8,%esp
  8004fc:	ff 75 d0             	pushl  -0x30(%ebp)
  8004ff:	57                   	push   %edi
  800500:	e8 86 02 00 00       	call   80078b <strnlen>
  800505:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800508:	29 c1                	sub    %eax,%ecx
  80050a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80050d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800510:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800514:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800517:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80051a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051c:	eb 0f                	jmp    80052d <vprintfmt+0x1cf>
					putch(padc, putdat);
  80051e:	83 ec 08             	sub    $0x8,%esp
  800521:	53                   	push   %ebx
  800522:	ff 75 e0             	pushl  -0x20(%ebp)
  800525:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800527:	83 ef 01             	sub    $0x1,%edi
  80052a:	83 c4 10             	add    $0x10,%esp
  80052d:	85 ff                	test   %edi,%edi
  80052f:	7f ed                	jg     80051e <vprintfmt+0x1c0>
  800531:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800534:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800537:	85 c9                	test   %ecx,%ecx
  800539:	b8 00 00 00 00       	mov    $0x0,%eax
  80053e:	0f 49 c1             	cmovns %ecx,%eax
  800541:	29 c1                	sub    %eax,%ecx
  800543:	89 75 08             	mov    %esi,0x8(%ebp)
  800546:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800549:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054c:	89 cb                	mov    %ecx,%ebx
  80054e:	eb 4d                	jmp    80059d <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800550:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800554:	74 1b                	je     800571 <vprintfmt+0x213>
  800556:	0f be c0             	movsbl %al,%eax
  800559:	83 e8 20             	sub    $0x20,%eax
  80055c:	83 f8 5e             	cmp    $0x5e,%eax
  80055f:	76 10                	jbe    800571 <vprintfmt+0x213>
					putch('?', putdat);
  800561:	83 ec 08             	sub    $0x8,%esp
  800564:	ff 75 0c             	pushl  0xc(%ebp)
  800567:	6a 3f                	push   $0x3f
  800569:	ff 55 08             	call   *0x8(%ebp)
  80056c:	83 c4 10             	add    $0x10,%esp
  80056f:	eb 0d                	jmp    80057e <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	ff 75 0c             	pushl  0xc(%ebp)
  800577:	52                   	push   %edx
  800578:	ff 55 08             	call   *0x8(%ebp)
  80057b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057e:	83 eb 01             	sub    $0x1,%ebx
  800581:	eb 1a                	jmp    80059d <vprintfmt+0x23f>
  800583:	89 75 08             	mov    %esi,0x8(%ebp)
  800586:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800589:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80058c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058f:	eb 0c                	jmp    80059d <vprintfmt+0x23f>
  800591:	89 75 08             	mov    %esi,0x8(%ebp)
  800594:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800597:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80059a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80059d:	83 c7 01             	add    $0x1,%edi
  8005a0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005a4:	0f be d0             	movsbl %al,%edx
  8005a7:	85 d2                	test   %edx,%edx
  8005a9:	74 23                	je     8005ce <vprintfmt+0x270>
  8005ab:	85 f6                	test   %esi,%esi
  8005ad:	78 a1                	js     800550 <vprintfmt+0x1f2>
  8005af:	83 ee 01             	sub    $0x1,%esi
  8005b2:	79 9c                	jns    800550 <vprintfmt+0x1f2>
  8005b4:	89 df                	mov    %ebx,%edi
  8005b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005bc:	eb 18                	jmp    8005d6 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005be:	83 ec 08             	sub    $0x8,%esp
  8005c1:	53                   	push   %ebx
  8005c2:	6a 20                	push   $0x20
  8005c4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c6:	83 ef 01             	sub    $0x1,%edi
  8005c9:	83 c4 10             	add    $0x10,%esp
  8005cc:	eb 08                	jmp    8005d6 <vprintfmt+0x278>
  8005ce:	89 df                	mov    %ebx,%edi
  8005d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d6:	85 ff                	test   %edi,%edi
  8005d8:	7f e4                	jg     8005be <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005dd:	e9 a2 fd ff ff       	jmp    800384 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005e2:	83 fa 01             	cmp    $0x1,%edx
  8005e5:	7e 16                	jle    8005fd <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ea:	8d 50 08             	lea    0x8(%eax),%edx
  8005ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f0:	8b 50 04             	mov    0x4(%eax),%edx
  8005f3:	8b 00                	mov    (%eax),%eax
  8005f5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005fb:	eb 32                	jmp    80062f <vprintfmt+0x2d1>
	else if (lflag)
  8005fd:	85 d2                	test   %edx,%edx
  8005ff:	74 18                	je     800619 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800601:	8b 45 14             	mov    0x14(%ebp),%eax
  800604:	8d 50 04             	lea    0x4(%eax),%edx
  800607:	89 55 14             	mov    %edx,0x14(%ebp)
  80060a:	8b 00                	mov    (%eax),%eax
  80060c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060f:	89 c1                	mov    %eax,%ecx
  800611:	c1 f9 1f             	sar    $0x1f,%ecx
  800614:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800617:	eb 16                	jmp    80062f <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800619:	8b 45 14             	mov    0x14(%ebp),%eax
  80061c:	8d 50 04             	lea    0x4(%eax),%edx
  80061f:	89 55 14             	mov    %edx,0x14(%ebp)
  800622:	8b 00                	mov    (%eax),%eax
  800624:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800627:	89 c1                	mov    %eax,%ecx
  800629:	c1 f9 1f             	sar    $0x1f,%ecx
  80062c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80062f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800632:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800635:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80063a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80063e:	79 74                	jns    8006b4 <vprintfmt+0x356>
				putch('-', putdat);
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	53                   	push   %ebx
  800644:	6a 2d                	push   $0x2d
  800646:	ff d6                	call   *%esi
				num = -(long long) num;
  800648:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80064b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80064e:	f7 d8                	neg    %eax
  800650:	83 d2 00             	adc    $0x0,%edx
  800653:	f7 da                	neg    %edx
  800655:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800658:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80065d:	eb 55                	jmp    8006b4 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80065f:	8d 45 14             	lea    0x14(%ebp),%eax
  800662:	e8 83 fc ff ff       	call   8002ea <getuint>
			base = 10;
  800667:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80066c:	eb 46                	jmp    8006b4 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80066e:	8d 45 14             	lea    0x14(%ebp),%eax
  800671:	e8 74 fc ff ff       	call   8002ea <getuint>
			base = 8;
  800676:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80067b:	eb 37                	jmp    8006b4 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80067d:	83 ec 08             	sub    $0x8,%esp
  800680:	53                   	push   %ebx
  800681:	6a 30                	push   $0x30
  800683:	ff d6                	call   *%esi
			putch('x', putdat);
  800685:	83 c4 08             	add    $0x8,%esp
  800688:	53                   	push   %ebx
  800689:	6a 78                	push   $0x78
  80068b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80068d:	8b 45 14             	mov    0x14(%ebp),%eax
  800690:	8d 50 04             	lea    0x4(%eax),%edx
  800693:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800696:	8b 00                	mov    (%eax),%eax
  800698:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80069d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006a0:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006a5:	eb 0d                	jmp    8006b4 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006aa:	e8 3b fc ff ff       	call   8002ea <getuint>
			base = 16;
  8006af:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b4:	83 ec 0c             	sub    $0xc,%esp
  8006b7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006bb:	57                   	push   %edi
  8006bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8006bf:	51                   	push   %ecx
  8006c0:	52                   	push   %edx
  8006c1:	50                   	push   %eax
  8006c2:	89 da                	mov    %ebx,%edx
  8006c4:	89 f0                	mov    %esi,%eax
  8006c6:	e8 70 fb ff ff       	call   80023b <printnum>
			break;
  8006cb:	83 c4 20             	add    $0x20,%esp
  8006ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d1:	e9 ae fc ff ff       	jmp    800384 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006d6:	83 ec 08             	sub    $0x8,%esp
  8006d9:	53                   	push   %ebx
  8006da:	51                   	push   %ecx
  8006db:	ff d6                	call   *%esi
			break;
  8006dd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006e3:	e9 9c fc ff ff       	jmp    800384 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e8:	83 ec 08             	sub    $0x8,%esp
  8006eb:	53                   	push   %ebx
  8006ec:	6a 25                	push   $0x25
  8006ee:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f0:	83 c4 10             	add    $0x10,%esp
  8006f3:	eb 03                	jmp    8006f8 <vprintfmt+0x39a>
  8006f5:	83 ef 01             	sub    $0x1,%edi
  8006f8:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006fc:	75 f7                	jne    8006f5 <vprintfmt+0x397>
  8006fe:	e9 81 fc ff ff       	jmp    800384 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800703:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800706:	5b                   	pop    %ebx
  800707:	5e                   	pop    %esi
  800708:	5f                   	pop    %edi
  800709:	5d                   	pop    %ebp
  80070a:	c3                   	ret    

0080070b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80070b:	55                   	push   %ebp
  80070c:	89 e5                	mov    %esp,%ebp
  80070e:	83 ec 18             	sub    $0x18,%esp
  800711:	8b 45 08             	mov    0x8(%ebp),%eax
  800714:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800717:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80071a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80071e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800721:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800728:	85 c0                	test   %eax,%eax
  80072a:	74 26                	je     800752 <vsnprintf+0x47>
  80072c:	85 d2                	test   %edx,%edx
  80072e:	7e 22                	jle    800752 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800730:	ff 75 14             	pushl  0x14(%ebp)
  800733:	ff 75 10             	pushl  0x10(%ebp)
  800736:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800739:	50                   	push   %eax
  80073a:	68 24 03 80 00       	push   $0x800324
  80073f:	e8 1a fc ff ff       	call   80035e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800744:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800747:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80074a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80074d:	83 c4 10             	add    $0x10,%esp
  800750:	eb 05                	jmp    800757 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800752:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800757:	c9                   	leave  
  800758:	c3                   	ret    

00800759 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800762:	50                   	push   %eax
  800763:	ff 75 10             	pushl  0x10(%ebp)
  800766:	ff 75 0c             	pushl  0xc(%ebp)
  800769:	ff 75 08             	pushl  0x8(%ebp)
  80076c:	e8 9a ff ff ff       	call   80070b <vsnprintf>
	va_end(ap);

	return rc;
}
  800771:	c9                   	leave  
  800772:	c3                   	ret    

00800773 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800779:	b8 00 00 00 00       	mov    $0x0,%eax
  80077e:	eb 03                	jmp    800783 <strlen+0x10>
		n++;
  800780:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800783:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800787:	75 f7                	jne    800780 <strlen+0xd>
		n++;
	return n;
}
  800789:	5d                   	pop    %ebp
  80078a:	c3                   	ret    

0080078b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800791:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800794:	ba 00 00 00 00       	mov    $0x0,%edx
  800799:	eb 03                	jmp    80079e <strnlen+0x13>
		n++;
  80079b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079e:	39 c2                	cmp    %eax,%edx
  8007a0:	74 08                	je     8007aa <strnlen+0x1f>
  8007a2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007a6:	75 f3                	jne    80079b <strnlen+0x10>
  8007a8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007aa:	5d                   	pop    %ebp
  8007ab:	c3                   	ret    

008007ac <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	53                   	push   %ebx
  8007b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b6:	89 c2                	mov    %eax,%edx
  8007b8:	83 c2 01             	add    $0x1,%edx
  8007bb:	83 c1 01             	add    $0x1,%ecx
  8007be:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007c2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007c5:	84 db                	test   %bl,%bl
  8007c7:	75 ef                	jne    8007b8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007c9:	5b                   	pop    %ebx
  8007ca:	5d                   	pop    %ebp
  8007cb:	c3                   	ret    

008007cc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	53                   	push   %ebx
  8007d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d3:	53                   	push   %ebx
  8007d4:	e8 9a ff ff ff       	call   800773 <strlen>
  8007d9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007dc:	ff 75 0c             	pushl  0xc(%ebp)
  8007df:	01 d8                	add    %ebx,%eax
  8007e1:	50                   	push   %eax
  8007e2:	e8 c5 ff ff ff       	call   8007ac <strcpy>
	return dst;
}
  8007e7:	89 d8                	mov    %ebx,%eax
  8007e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ec:	c9                   	leave  
  8007ed:	c3                   	ret    

008007ee <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	56                   	push   %esi
  8007f2:	53                   	push   %ebx
  8007f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f9:	89 f3                	mov    %esi,%ebx
  8007fb:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fe:	89 f2                	mov    %esi,%edx
  800800:	eb 0f                	jmp    800811 <strncpy+0x23>
		*dst++ = *src;
  800802:	83 c2 01             	add    $0x1,%edx
  800805:	0f b6 01             	movzbl (%ecx),%eax
  800808:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80080b:	80 39 01             	cmpb   $0x1,(%ecx)
  80080e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800811:	39 da                	cmp    %ebx,%edx
  800813:	75 ed                	jne    800802 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800815:	89 f0                	mov    %esi,%eax
  800817:	5b                   	pop    %ebx
  800818:	5e                   	pop    %esi
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	56                   	push   %esi
  80081f:	53                   	push   %ebx
  800820:	8b 75 08             	mov    0x8(%ebp),%esi
  800823:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800826:	8b 55 10             	mov    0x10(%ebp),%edx
  800829:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80082b:	85 d2                	test   %edx,%edx
  80082d:	74 21                	je     800850 <strlcpy+0x35>
  80082f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800833:	89 f2                	mov    %esi,%edx
  800835:	eb 09                	jmp    800840 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800837:	83 c2 01             	add    $0x1,%edx
  80083a:	83 c1 01             	add    $0x1,%ecx
  80083d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800840:	39 c2                	cmp    %eax,%edx
  800842:	74 09                	je     80084d <strlcpy+0x32>
  800844:	0f b6 19             	movzbl (%ecx),%ebx
  800847:	84 db                	test   %bl,%bl
  800849:	75 ec                	jne    800837 <strlcpy+0x1c>
  80084b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80084d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800850:	29 f0                	sub    %esi,%eax
}
  800852:	5b                   	pop    %ebx
  800853:	5e                   	pop    %esi
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80085f:	eb 06                	jmp    800867 <strcmp+0x11>
		p++, q++;
  800861:	83 c1 01             	add    $0x1,%ecx
  800864:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800867:	0f b6 01             	movzbl (%ecx),%eax
  80086a:	84 c0                	test   %al,%al
  80086c:	74 04                	je     800872 <strcmp+0x1c>
  80086e:	3a 02                	cmp    (%edx),%al
  800870:	74 ef                	je     800861 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800872:	0f b6 c0             	movzbl %al,%eax
  800875:	0f b6 12             	movzbl (%edx),%edx
  800878:	29 d0                	sub    %edx,%eax
}
  80087a:	5d                   	pop    %ebp
  80087b:	c3                   	ret    

0080087c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	53                   	push   %ebx
  800880:	8b 45 08             	mov    0x8(%ebp),%eax
  800883:	8b 55 0c             	mov    0xc(%ebp),%edx
  800886:	89 c3                	mov    %eax,%ebx
  800888:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80088b:	eb 06                	jmp    800893 <strncmp+0x17>
		n--, p++, q++;
  80088d:	83 c0 01             	add    $0x1,%eax
  800890:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800893:	39 d8                	cmp    %ebx,%eax
  800895:	74 15                	je     8008ac <strncmp+0x30>
  800897:	0f b6 08             	movzbl (%eax),%ecx
  80089a:	84 c9                	test   %cl,%cl
  80089c:	74 04                	je     8008a2 <strncmp+0x26>
  80089e:	3a 0a                	cmp    (%edx),%cl
  8008a0:	74 eb                	je     80088d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a2:	0f b6 00             	movzbl (%eax),%eax
  8008a5:	0f b6 12             	movzbl (%edx),%edx
  8008a8:	29 d0                	sub    %edx,%eax
  8008aa:	eb 05                	jmp    8008b1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ac:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008b1:	5b                   	pop    %ebx
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ba:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008be:	eb 07                	jmp    8008c7 <strchr+0x13>
		if (*s == c)
  8008c0:	38 ca                	cmp    %cl,%dl
  8008c2:	74 0f                	je     8008d3 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008c4:	83 c0 01             	add    $0x1,%eax
  8008c7:	0f b6 10             	movzbl (%eax),%edx
  8008ca:	84 d2                	test   %dl,%dl
  8008cc:	75 f2                	jne    8008c0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008db:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008df:	eb 03                	jmp    8008e4 <strfind+0xf>
  8008e1:	83 c0 01             	add    $0x1,%eax
  8008e4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008e7:	38 ca                	cmp    %cl,%dl
  8008e9:	74 04                	je     8008ef <strfind+0x1a>
  8008eb:	84 d2                	test   %dl,%dl
  8008ed:	75 f2                	jne    8008e1 <strfind+0xc>
			break;
	return (char *) s;
}
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    

008008f1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	57                   	push   %edi
  8008f5:	56                   	push   %esi
  8008f6:	53                   	push   %ebx
  8008f7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008fd:	85 c9                	test   %ecx,%ecx
  8008ff:	74 36                	je     800937 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800901:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800907:	75 28                	jne    800931 <memset+0x40>
  800909:	f6 c1 03             	test   $0x3,%cl
  80090c:	75 23                	jne    800931 <memset+0x40>
		c &= 0xFF;
  80090e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800912:	89 d3                	mov    %edx,%ebx
  800914:	c1 e3 08             	shl    $0x8,%ebx
  800917:	89 d6                	mov    %edx,%esi
  800919:	c1 e6 18             	shl    $0x18,%esi
  80091c:	89 d0                	mov    %edx,%eax
  80091e:	c1 e0 10             	shl    $0x10,%eax
  800921:	09 f0                	or     %esi,%eax
  800923:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800925:	89 d8                	mov    %ebx,%eax
  800927:	09 d0                	or     %edx,%eax
  800929:	c1 e9 02             	shr    $0x2,%ecx
  80092c:	fc                   	cld    
  80092d:	f3 ab                	rep stos %eax,%es:(%edi)
  80092f:	eb 06                	jmp    800937 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800931:	8b 45 0c             	mov    0xc(%ebp),%eax
  800934:	fc                   	cld    
  800935:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800937:	89 f8                	mov    %edi,%eax
  800939:	5b                   	pop    %ebx
  80093a:	5e                   	pop    %esi
  80093b:	5f                   	pop    %edi
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	57                   	push   %edi
  800942:	56                   	push   %esi
  800943:	8b 45 08             	mov    0x8(%ebp),%eax
  800946:	8b 75 0c             	mov    0xc(%ebp),%esi
  800949:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80094c:	39 c6                	cmp    %eax,%esi
  80094e:	73 35                	jae    800985 <memmove+0x47>
  800950:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800953:	39 d0                	cmp    %edx,%eax
  800955:	73 2e                	jae    800985 <memmove+0x47>
		s += n;
		d += n;
  800957:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095a:	89 d6                	mov    %edx,%esi
  80095c:	09 fe                	or     %edi,%esi
  80095e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800964:	75 13                	jne    800979 <memmove+0x3b>
  800966:	f6 c1 03             	test   $0x3,%cl
  800969:	75 0e                	jne    800979 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80096b:	83 ef 04             	sub    $0x4,%edi
  80096e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800971:	c1 e9 02             	shr    $0x2,%ecx
  800974:	fd                   	std    
  800975:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800977:	eb 09                	jmp    800982 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800979:	83 ef 01             	sub    $0x1,%edi
  80097c:	8d 72 ff             	lea    -0x1(%edx),%esi
  80097f:	fd                   	std    
  800980:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800982:	fc                   	cld    
  800983:	eb 1d                	jmp    8009a2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800985:	89 f2                	mov    %esi,%edx
  800987:	09 c2                	or     %eax,%edx
  800989:	f6 c2 03             	test   $0x3,%dl
  80098c:	75 0f                	jne    80099d <memmove+0x5f>
  80098e:	f6 c1 03             	test   $0x3,%cl
  800991:	75 0a                	jne    80099d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800993:	c1 e9 02             	shr    $0x2,%ecx
  800996:	89 c7                	mov    %eax,%edi
  800998:	fc                   	cld    
  800999:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099b:	eb 05                	jmp    8009a2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80099d:	89 c7                	mov    %eax,%edi
  80099f:	fc                   	cld    
  8009a0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a2:	5e                   	pop    %esi
  8009a3:	5f                   	pop    %edi
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009a9:	ff 75 10             	pushl  0x10(%ebp)
  8009ac:	ff 75 0c             	pushl  0xc(%ebp)
  8009af:	ff 75 08             	pushl  0x8(%ebp)
  8009b2:	e8 87 ff ff ff       	call   80093e <memmove>
}
  8009b7:	c9                   	leave  
  8009b8:	c3                   	ret    

008009b9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	56                   	push   %esi
  8009bd:	53                   	push   %ebx
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c4:	89 c6                	mov    %eax,%esi
  8009c6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c9:	eb 1a                	jmp    8009e5 <memcmp+0x2c>
		if (*s1 != *s2)
  8009cb:	0f b6 08             	movzbl (%eax),%ecx
  8009ce:	0f b6 1a             	movzbl (%edx),%ebx
  8009d1:	38 d9                	cmp    %bl,%cl
  8009d3:	74 0a                	je     8009df <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009d5:	0f b6 c1             	movzbl %cl,%eax
  8009d8:	0f b6 db             	movzbl %bl,%ebx
  8009db:	29 d8                	sub    %ebx,%eax
  8009dd:	eb 0f                	jmp    8009ee <memcmp+0x35>
		s1++, s2++;
  8009df:	83 c0 01             	add    $0x1,%eax
  8009e2:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e5:	39 f0                	cmp    %esi,%eax
  8009e7:	75 e2                	jne    8009cb <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ee:	5b                   	pop    %ebx
  8009ef:	5e                   	pop    %esi
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	53                   	push   %ebx
  8009f6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009f9:	89 c1                	mov    %eax,%ecx
  8009fb:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009fe:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a02:	eb 0a                	jmp    800a0e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a04:	0f b6 10             	movzbl (%eax),%edx
  800a07:	39 da                	cmp    %ebx,%edx
  800a09:	74 07                	je     800a12 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0b:	83 c0 01             	add    $0x1,%eax
  800a0e:	39 c8                	cmp    %ecx,%eax
  800a10:	72 f2                	jb     800a04 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a12:	5b                   	pop    %ebx
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	57                   	push   %edi
  800a19:	56                   	push   %esi
  800a1a:	53                   	push   %ebx
  800a1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a21:	eb 03                	jmp    800a26 <strtol+0x11>
		s++;
  800a23:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a26:	0f b6 01             	movzbl (%ecx),%eax
  800a29:	3c 20                	cmp    $0x20,%al
  800a2b:	74 f6                	je     800a23 <strtol+0xe>
  800a2d:	3c 09                	cmp    $0x9,%al
  800a2f:	74 f2                	je     800a23 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a31:	3c 2b                	cmp    $0x2b,%al
  800a33:	75 0a                	jne    800a3f <strtol+0x2a>
		s++;
  800a35:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a38:	bf 00 00 00 00       	mov    $0x0,%edi
  800a3d:	eb 11                	jmp    800a50 <strtol+0x3b>
  800a3f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a44:	3c 2d                	cmp    $0x2d,%al
  800a46:	75 08                	jne    800a50 <strtol+0x3b>
		s++, neg = 1;
  800a48:	83 c1 01             	add    $0x1,%ecx
  800a4b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a50:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a56:	75 15                	jne    800a6d <strtol+0x58>
  800a58:	80 39 30             	cmpb   $0x30,(%ecx)
  800a5b:	75 10                	jne    800a6d <strtol+0x58>
  800a5d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a61:	75 7c                	jne    800adf <strtol+0xca>
		s += 2, base = 16;
  800a63:	83 c1 02             	add    $0x2,%ecx
  800a66:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a6b:	eb 16                	jmp    800a83 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a6d:	85 db                	test   %ebx,%ebx
  800a6f:	75 12                	jne    800a83 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a71:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a76:	80 39 30             	cmpb   $0x30,(%ecx)
  800a79:	75 08                	jne    800a83 <strtol+0x6e>
		s++, base = 8;
  800a7b:	83 c1 01             	add    $0x1,%ecx
  800a7e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a83:	b8 00 00 00 00       	mov    $0x0,%eax
  800a88:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a8b:	0f b6 11             	movzbl (%ecx),%edx
  800a8e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a91:	89 f3                	mov    %esi,%ebx
  800a93:	80 fb 09             	cmp    $0x9,%bl
  800a96:	77 08                	ja     800aa0 <strtol+0x8b>
			dig = *s - '0';
  800a98:	0f be d2             	movsbl %dl,%edx
  800a9b:	83 ea 30             	sub    $0x30,%edx
  800a9e:	eb 22                	jmp    800ac2 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aa0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aa3:	89 f3                	mov    %esi,%ebx
  800aa5:	80 fb 19             	cmp    $0x19,%bl
  800aa8:	77 08                	ja     800ab2 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800aaa:	0f be d2             	movsbl %dl,%edx
  800aad:	83 ea 57             	sub    $0x57,%edx
  800ab0:	eb 10                	jmp    800ac2 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ab2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ab5:	89 f3                	mov    %esi,%ebx
  800ab7:	80 fb 19             	cmp    $0x19,%bl
  800aba:	77 16                	ja     800ad2 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800abc:	0f be d2             	movsbl %dl,%edx
  800abf:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ac2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac5:	7d 0b                	jge    800ad2 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ac7:	83 c1 01             	add    $0x1,%ecx
  800aca:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ace:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ad0:	eb b9                	jmp    800a8b <strtol+0x76>

	if (endptr)
  800ad2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad6:	74 0d                	je     800ae5 <strtol+0xd0>
		*endptr = (char *) s;
  800ad8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800adb:	89 0e                	mov    %ecx,(%esi)
  800add:	eb 06                	jmp    800ae5 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800adf:	85 db                	test   %ebx,%ebx
  800ae1:	74 98                	je     800a7b <strtol+0x66>
  800ae3:	eb 9e                	jmp    800a83 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ae5:	89 c2                	mov    %eax,%edx
  800ae7:	f7 da                	neg    %edx
  800ae9:	85 ff                	test   %edi,%edi
  800aeb:	0f 45 c2             	cmovne %edx,%eax
}
  800aee:	5b                   	pop    %ebx
  800aef:	5e                   	pop    %esi
  800af0:	5f                   	pop    %edi
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	57                   	push   %edi
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af9:	b8 00 00 00 00       	mov    $0x0,%eax
  800afe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b01:	8b 55 08             	mov    0x8(%ebp),%edx
  800b04:	89 c3                	mov    %eax,%ebx
  800b06:	89 c7                	mov    %eax,%edi
  800b08:	89 c6                	mov    %eax,%esi
  800b0a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	57                   	push   %edi
  800b15:	56                   	push   %esi
  800b16:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b17:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b21:	89 d1                	mov    %edx,%ecx
  800b23:	89 d3                	mov    %edx,%ebx
  800b25:	89 d7                	mov    %edx,%edi
  800b27:	89 d6                	mov    %edx,%esi
  800b29:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b2b:	5b                   	pop    %ebx
  800b2c:	5e                   	pop    %esi
  800b2d:	5f                   	pop    %edi
  800b2e:	5d                   	pop    %ebp
  800b2f:	c3                   	ret    

00800b30 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	57                   	push   %edi
  800b34:	56                   	push   %esi
  800b35:	53                   	push   %ebx
  800b36:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b39:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3e:	b8 03 00 00 00       	mov    $0x3,%eax
  800b43:	8b 55 08             	mov    0x8(%ebp),%edx
  800b46:	89 cb                	mov    %ecx,%ebx
  800b48:	89 cf                	mov    %ecx,%edi
  800b4a:	89 ce                	mov    %ecx,%esi
  800b4c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b4e:	85 c0                	test   %eax,%eax
  800b50:	7e 17                	jle    800b69 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b52:	83 ec 0c             	sub    $0xc,%esp
  800b55:	50                   	push   %eax
  800b56:	6a 03                	push   $0x3
  800b58:	68 df 25 80 00       	push   $0x8025df
  800b5d:	6a 23                	push   $0x23
  800b5f:	68 fc 25 80 00       	push   $0x8025fc
  800b64:	e8 e5 f5 ff ff       	call   80014e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	57                   	push   %edi
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b77:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7c:	b8 02 00 00 00       	mov    $0x2,%eax
  800b81:	89 d1                	mov    %edx,%ecx
  800b83:	89 d3                	mov    %edx,%ebx
  800b85:	89 d7                	mov    %edx,%edi
  800b87:	89 d6                	mov    %edx,%esi
  800b89:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b8b:	5b                   	pop    %ebx
  800b8c:	5e                   	pop    %esi
  800b8d:	5f                   	pop    %edi
  800b8e:	5d                   	pop    %ebp
  800b8f:	c3                   	ret    

00800b90 <sys_yield>:

void
sys_yield(void)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	57                   	push   %edi
  800b94:	56                   	push   %esi
  800b95:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b96:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ba0:	89 d1                	mov    %edx,%ecx
  800ba2:	89 d3                	mov    %edx,%ebx
  800ba4:	89 d7                	mov    %edx,%edi
  800ba6:	89 d6                	mov    %edx,%esi
  800ba8:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	57                   	push   %edi
  800bb3:	56                   	push   %esi
  800bb4:	53                   	push   %ebx
  800bb5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb8:	be 00 00 00 00       	mov    $0x0,%esi
  800bbd:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bcb:	89 f7                	mov    %esi,%edi
  800bcd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bcf:	85 c0                	test   %eax,%eax
  800bd1:	7e 17                	jle    800bea <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd3:	83 ec 0c             	sub    $0xc,%esp
  800bd6:	50                   	push   %eax
  800bd7:	6a 04                	push   $0x4
  800bd9:	68 df 25 80 00       	push   $0x8025df
  800bde:	6a 23                	push   $0x23
  800be0:	68 fc 25 80 00       	push   $0x8025fc
  800be5:	e8 64 f5 ff ff       	call   80014e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bed:	5b                   	pop    %ebx
  800bee:	5e                   	pop    %esi
  800bef:	5f                   	pop    %edi
  800bf0:	5d                   	pop    %ebp
  800bf1:	c3                   	ret    

00800bf2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	57                   	push   %edi
  800bf6:	56                   	push   %esi
  800bf7:	53                   	push   %ebx
  800bf8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfb:	b8 05 00 00 00       	mov    $0x5,%eax
  800c00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c03:	8b 55 08             	mov    0x8(%ebp),%edx
  800c06:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c09:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c0c:	8b 75 18             	mov    0x18(%ebp),%esi
  800c0f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c11:	85 c0                	test   %eax,%eax
  800c13:	7e 17                	jle    800c2c <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c15:	83 ec 0c             	sub    $0xc,%esp
  800c18:	50                   	push   %eax
  800c19:	6a 05                	push   $0x5
  800c1b:	68 df 25 80 00       	push   $0x8025df
  800c20:	6a 23                	push   $0x23
  800c22:	68 fc 25 80 00       	push   $0x8025fc
  800c27:	e8 22 f5 ff ff       	call   80014e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2f:	5b                   	pop    %ebx
  800c30:	5e                   	pop    %esi
  800c31:	5f                   	pop    %edi
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    

00800c34 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	57                   	push   %edi
  800c38:	56                   	push   %esi
  800c39:	53                   	push   %ebx
  800c3a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c42:	b8 06 00 00 00       	mov    $0x6,%eax
  800c47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4d:	89 df                	mov    %ebx,%edi
  800c4f:	89 de                	mov    %ebx,%esi
  800c51:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c53:	85 c0                	test   %eax,%eax
  800c55:	7e 17                	jle    800c6e <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c57:	83 ec 0c             	sub    $0xc,%esp
  800c5a:	50                   	push   %eax
  800c5b:	6a 06                	push   $0x6
  800c5d:	68 df 25 80 00       	push   $0x8025df
  800c62:	6a 23                	push   $0x23
  800c64:	68 fc 25 80 00       	push   $0x8025fc
  800c69:	e8 e0 f4 ff ff       	call   80014e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c71:	5b                   	pop    %ebx
  800c72:	5e                   	pop    %esi
  800c73:	5f                   	pop    %edi
  800c74:	5d                   	pop    %ebp
  800c75:	c3                   	ret    

00800c76 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
  800c79:	57                   	push   %edi
  800c7a:	56                   	push   %esi
  800c7b:	53                   	push   %ebx
  800c7c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c84:	b8 08 00 00 00       	mov    $0x8,%eax
  800c89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8f:	89 df                	mov    %ebx,%edi
  800c91:	89 de                	mov    %ebx,%esi
  800c93:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c95:	85 c0                	test   %eax,%eax
  800c97:	7e 17                	jle    800cb0 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c99:	83 ec 0c             	sub    $0xc,%esp
  800c9c:	50                   	push   %eax
  800c9d:	6a 08                	push   $0x8
  800c9f:	68 df 25 80 00       	push   $0x8025df
  800ca4:	6a 23                	push   $0x23
  800ca6:	68 fc 25 80 00       	push   $0x8025fc
  800cab:	e8 9e f4 ff ff       	call   80014e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb3:	5b                   	pop    %ebx
  800cb4:	5e                   	pop    %esi
  800cb5:	5f                   	pop    %edi
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    

00800cb8 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	57                   	push   %edi
  800cbc:	56                   	push   %esi
  800cbd:	53                   	push   %ebx
  800cbe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc6:	b8 09 00 00 00       	mov    $0x9,%eax
  800ccb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cce:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd1:	89 df                	mov    %ebx,%edi
  800cd3:	89 de                	mov    %ebx,%esi
  800cd5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd7:	85 c0                	test   %eax,%eax
  800cd9:	7e 17                	jle    800cf2 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdb:	83 ec 0c             	sub    $0xc,%esp
  800cde:	50                   	push   %eax
  800cdf:	6a 09                	push   $0x9
  800ce1:	68 df 25 80 00       	push   $0x8025df
  800ce6:	6a 23                	push   $0x23
  800ce8:	68 fc 25 80 00       	push   $0x8025fc
  800ced:	e8 5c f4 ff ff       	call   80014e <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf5:	5b                   	pop    %ebx
  800cf6:	5e                   	pop    %esi
  800cf7:	5f                   	pop    %edi
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    

00800cfa <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	57                   	push   %edi
  800cfe:	56                   	push   %esi
  800cff:	53                   	push   %ebx
  800d00:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d03:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d08:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d10:	8b 55 08             	mov    0x8(%ebp),%edx
  800d13:	89 df                	mov    %ebx,%edi
  800d15:	89 de                	mov    %ebx,%esi
  800d17:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d19:	85 c0                	test   %eax,%eax
  800d1b:	7e 17                	jle    800d34 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1d:	83 ec 0c             	sub    $0xc,%esp
  800d20:	50                   	push   %eax
  800d21:	6a 0a                	push   $0xa
  800d23:	68 df 25 80 00       	push   $0x8025df
  800d28:	6a 23                	push   $0x23
  800d2a:	68 fc 25 80 00       	push   $0x8025fc
  800d2f:	e8 1a f4 ff ff       	call   80014e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	57                   	push   %edi
  800d40:	56                   	push   %esi
  800d41:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d42:	be 00 00 00 00       	mov    $0x0,%esi
  800d47:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d52:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d55:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d58:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d5a:	5b                   	pop    %ebx
  800d5b:	5e                   	pop    %esi
  800d5c:	5f                   	pop    %edi
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	57                   	push   %edi
  800d63:	56                   	push   %esi
  800d64:	53                   	push   %ebx
  800d65:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d68:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d72:	8b 55 08             	mov    0x8(%ebp),%edx
  800d75:	89 cb                	mov    %ecx,%ebx
  800d77:	89 cf                	mov    %ecx,%edi
  800d79:	89 ce                	mov    %ecx,%esi
  800d7b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	7e 17                	jle    800d98 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d81:	83 ec 0c             	sub    $0xc,%esp
  800d84:	50                   	push   %eax
  800d85:	6a 0d                	push   $0xd
  800d87:	68 df 25 80 00       	push   $0x8025df
  800d8c:	6a 23                	push   $0x23
  800d8e:	68 fc 25 80 00       	push   $0x8025fc
  800d93:	e8 b6 f3 ff ff       	call   80014e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dab:	b8 0e 00 00 00       	mov    $0xe,%eax
  800db0:	8b 55 08             	mov    0x8(%ebp),%edx
  800db3:	89 cb                	mov    %ecx,%ebx
  800db5:	89 cf                	mov    %ecx,%edi
  800db7:	89 ce                	mov    %ecx,%esi
  800db9:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800dbb:	5b                   	pop    %ebx
  800dbc:	5e                   	pop    %esi
  800dbd:	5f                   	pop    %edi
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	57                   	push   %edi
  800dc4:	56                   	push   %esi
  800dc5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dcb:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd3:	89 cb                	mov    %ecx,%ebx
  800dd5:	89 cf                	mov    %ecx,%edi
  800dd7:	89 ce                	mov    %ecx,%esi
  800dd9:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800ddb:	5b                   	pop    %ebx
  800ddc:	5e                   	pop    %esi
  800ddd:	5f                   	pop    %edi
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    

00800de0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800de6:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800ded:	75 2a                	jne    800e19 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  800def:	83 ec 04             	sub    $0x4,%esp
  800df2:	6a 07                	push   $0x7
  800df4:	68 00 f0 bf ee       	push   $0xeebff000
  800df9:	6a 00                	push   $0x0
  800dfb:	e8 af fd ff ff       	call   800baf <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  800e00:	83 c4 10             	add    $0x10,%esp
  800e03:	85 c0                	test   %eax,%eax
  800e05:	79 12                	jns    800e19 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  800e07:	50                   	push   %eax
  800e08:	68 0a 26 80 00       	push   $0x80260a
  800e0d:	6a 23                	push   $0x23
  800e0f:	68 0e 26 80 00       	push   $0x80260e
  800e14:	e8 35 f3 ff ff       	call   80014e <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e19:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1c:	a3 08 40 80 00       	mov    %eax,0x804008
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  800e21:	83 ec 08             	sub    $0x8,%esp
  800e24:	68 4b 0e 80 00       	push   $0x800e4b
  800e29:	6a 00                	push   $0x0
  800e2b:	e8 ca fe ff ff       	call   800cfa <sys_env_set_pgfault_upcall>
	if (r < 0) {
  800e30:	83 c4 10             	add    $0x10,%esp
  800e33:	85 c0                	test   %eax,%eax
  800e35:	79 12                	jns    800e49 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  800e37:	50                   	push   %eax
  800e38:	68 0a 26 80 00       	push   $0x80260a
  800e3d:	6a 2c                	push   $0x2c
  800e3f:	68 0e 26 80 00       	push   $0x80260e
  800e44:	e8 05 f3 ff ff       	call   80014e <_panic>
	}
}
  800e49:	c9                   	leave  
  800e4a:	c3                   	ret    

00800e4b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e4b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e4c:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800e51:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e53:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  800e56:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  800e5a:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  800e5f:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  800e63:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  800e65:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  800e68:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  800e69:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  800e6c:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  800e6d:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e6e:	c3                   	ret    

00800e6f <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	53                   	push   %ebx
  800e73:	83 ec 04             	sub    $0x4,%esp
  800e76:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e79:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800e7b:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e7f:	74 11                	je     800e92 <pgfault+0x23>
  800e81:	89 d8                	mov    %ebx,%eax
  800e83:	c1 e8 0c             	shr    $0xc,%eax
  800e86:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e8d:	f6 c4 08             	test   $0x8,%ah
  800e90:	75 14                	jne    800ea6 <pgfault+0x37>
		panic("faulting access");
  800e92:	83 ec 04             	sub    $0x4,%esp
  800e95:	68 1c 26 80 00       	push   $0x80261c
  800e9a:	6a 1e                	push   $0x1e
  800e9c:	68 2c 26 80 00       	push   $0x80262c
  800ea1:	e8 a8 f2 ff ff       	call   80014e <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800ea6:	83 ec 04             	sub    $0x4,%esp
  800ea9:	6a 07                	push   $0x7
  800eab:	68 00 f0 7f 00       	push   $0x7ff000
  800eb0:	6a 00                	push   $0x0
  800eb2:	e8 f8 fc ff ff       	call   800baf <sys_page_alloc>
	if (r < 0) {
  800eb7:	83 c4 10             	add    $0x10,%esp
  800eba:	85 c0                	test   %eax,%eax
  800ebc:	79 12                	jns    800ed0 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800ebe:	50                   	push   %eax
  800ebf:	68 37 26 80 00       	push   $0x802637
  800ec4:	6a 2c                	push   $0x2c
  800ec6:	68 2c 26 80 00       	push   $0x80262c
  800ecb:	e8 7e f2 ff ff       	call   80014e <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800ed0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800ed6:	83 ec 04             	sub    $0x4,%esp
  800ed9:	68 00 10 00 00       	push   $0x1000
  800ede:	53                   	push   %ebx
  800edf:	68 00 f0 7f 00       	push   $0x7ff000
  800ee4:	e8 bd fa ff ff       	call   8009a6 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800ee9:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ef0:	53                   	push   %ebx
  800ef1:	6a 00                	push   $0x0
  800ef3:	68 00 f0 7f 00       	push   $0x7ff000
  800ef8:	6a 00                	push   $0x0
  800efa:	e8 f3 fc ff ff       	call   800bf2 <sys_page_map>
	if (r < 0) {
  800eff:	83 c4 20             	add    $0x20,%esp
  800f02:	85 c0                	test   %eax,%eax
  800f04:	79 12                	jns    800f18 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800f06:	50                   	push   %eax
  800f07:	68 37 26 80 00       	push   $0x802637
  800f0c:	6a 33                	push   $0x33
  800f0e:	68 2c 26 80 00       	push   $0x80262c
  800f13:	e8 36 f2 ff ff       	call   80014e <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800f18:	83 ec 08             	sub    $0x8,%esp
  800f1b:	68 00 f0 7f 00       	push   $0x7ff000
  800f20:	6a 00                	push   $0x0
  800f22:	e8 0d fd ff ff       	call   800c34 <sys_page_unmap>
	if (r < 0) {
  800f27:	83 c4 10             	add    $0x10,%esp
  800f2a:	85 c0                	test   %eax,%eax
  800f2c:	79 12                	jns    800f40 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800f2e:	50                   	push   %eax
  800f2f:	68 37 26 80 00       	push   $0x802637
  800f34:	6a 37                	push   $0x37
  800f36:	68 2c 26 80 00       	push   $0x80262c
  800f3b:	e8 0e f2 ff ff       	call   80014e <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800f40:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f43:	c9                   	leave  
  800f44:	c3                   	ret    

00800f45 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	57                   	push   %edi
  800f49:	56                   	push   %esi
  800f4a:	53                   	push   %ebx
  800f4b:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800f4e:	68 6f 0e 80 00       	push   $0x800e6f
  800f53:	e8 88 fe ff ff       	call   800de0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f58:	b8 07 00 00 00       	mov    $0x7,%eax
  800f5d:	cd 30                	int    $0x30
  800f5f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800f62:	83 c4 10             	add    $0x10,%esp
  800f65:	85 c0                	test   %eax,%eax
  800f67:	79 17                	jns    800f80 <fork+0x3b>
		panic("fork fault %e");
  800f69:	83 ec 04             	sub    $0x4,%esp
  800f6c:	68 50 26 80 00       	push   $0x802650
  800f71:	68 84 00 00 00       	push   $0x84
  800f76:	68 2c 26 80 00       	push   $0x80262c
  800f7b:	e8 ce f1 ff ff       	call   80014e <_panic>
  800f80:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f82:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f86:	75 25                	jne    800fad <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f88:	e8 e4 fb ff ff       	call   800b71 <sys_getenvid>
  800f8d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f92:	89 c2                	mov    %eax,%edx
  800f94:	c1 e2 07             	shl    $0x7,%edx
  800f97:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800f9e:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800fa3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa8:	e9 61 01 00 00       	jmp    80110e <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800fad:	83 ec 04             	sub    $0x4,%esp
  800fb0:	6a 07                	push   $0x7
  800fb2:	68 00 f0 bf ee       	push   $0xeebff000
  800fb7:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fba:	e8 f0 fb ff ff       	call   800baf <sys_page_alloc>
  800fbf:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800fc2:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800fc7:	89 d8                	mov    %ebx,%eax
  800fc9:	c1 e8 16             	shr    $0x16,%eax
  800fcc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fd3:	a8 01                	test   $0x1,%al
  800fd5:	0f 84 fc 00 00 00    	je     8010d7 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800fdb:	89 d8                	mov    %ebx,%eax
  800fdd:	c1 e8 0c             	shr    $0xc,%eax
  800fe0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800fe7:	f6 c2 01             	test   $0x1,%dl
  800fea:	0f 84 e7 00 00 00    	je     8010d7 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800ff0:	89 c6                	mov    %eax,%esi
  800ff2:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800ff5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ffc:	f6 c6 04             	test   $0x4,%dh
  800fff:	74 39                	je     80103a <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  801001:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801008:	83 ec 0c             	sub    $0xc,%esp
  80100b:	25 07 0e 00 00       	and    $0xe07,%eax
  801010:	50                   	push   %eax
  801011:	56                   	push   %esi
  801012:	57                   	push   %edi
  801013:	56                   	push   %esi
  801014:	6a 00                	push   $0x0
  801016:	e8 d7 fb ff ff       	call   800bf2 <sys_page_map>
		if (r < 0) {
  80101b:	83 c4 20             	add    $0x20,%esp
  80101e:	85 c0                	test   %eax,%eax
  801020:	0f 89 b1 00 00 00    	jns    8010d7 <fork+0x192>
		    	panic("sys page map fault %e");
  801026:	83 ec 04             	sub    $0x4,%esp
  801029:	68 5e 26 80 00       	push   $0x80265e
  80102e:	6a 54                	push   $0x54
  801030:	68 2c 26 80 00       	push   $0x80262c
  801035:	e8 14 f1 ff ff       	call   80014e <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  80103a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801041:	f6 c2 02             	test   $0x2,%dl
  801044:	75 0c                	jne    801052 <fork+0x10d>
  801046:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80104d:	f6 c4 08             	test   $0x8,%ah
  801050:	74 5b                	je     8010ad <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  801052:	83 ec 0c             	sub    $0xc,%esp
  801055:	68 05 08 00 00       	push   $0x805
  80105a:	56                   	push   %esi
  80105b:	57                   	push   %edi
  80105c:	56                   	push   %esi
  80105d:	6a 00                	push   $0x0
  80105f:	e8 8e fb ff ff       	call   800bf2 <sys_page_map>
		if (r < 0) {
  801064:	83 c4 20             	add    $0x20,%esp
  801067:	85 c0                	test   %eax,%eax
  801069:	79 14                	jns    80107f <fork+0x13a>
		    	panic("sys page map fault %e");
  80106b:	83 ec 04             	sub    $0x4,%esp
  80106e:	68 5e 26 80 00       	push   $0x80265e
  801073:	6a 5b                	push   $0x5b
  801075:	68 2c 26 80 00       	push   $0x80262c
  80107a:	e8 cf f0 ff ff       	call   80014e <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  80107f:	83 ec 0c             	sub    $0xc,%esp
  801082:	68 05 08 00 00       	push   $0x805
  801087:	56                   	push   %esi
  801088:	6a 00                	push   $0x0
  80108a:	56                   	push   %esi
  80108b:	6a 00                	push   $0x0
  80108d:	e8 60 fb ff ff       	call   800bf2 <sys_page_map>
		if (r < 0) {
  801092:	83 c4 20             	add    $0x20,%esp
  801095:	85 c0                	test   %eax,%eax
  801097:	79 3e                	jns    8010d7 <fork+0x192>
		    	panic("sys page map fault %e");
  801099:	83 ec 04             	sub    $0x4,%esp
  80109c:	68 5e 26 80 00       	push   $0x80265e
  8010a1:	6a 5f                	push   $0x5f
  8010a3:	68 2c 26 80 00       	push   $0x80262c
  8010a8:	e8 a1 f0 ff ff       	call   80014e <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8010ad:	83 ec 0c             	sub    $0xc,%esp
  8010b0:	6a 05                	push   $0x5
  8010b2:	56                   	push   %esi
  8010b3:	57                   	push   %edi
  8010b4:	56                   	push   %esi
  8010b5:	6a 00                	push   $0x0
  8010b7:	e8 36 fb ff ff       	call   800bf2 <sys_page_map>
		if (r < 0) {
  8010bc:	83 c4 20             	add    $0x20,%esp
  8010bf:	85 c0                	test   %eax,%eax
  8010c1:	79 14                	jns    8010d7 <fork+0x192>
		    	panic("sys page map fault %e");
  8010c3:	83 ec 04             	sub    $0x4,%esp
  8010c6:	68 5e 26 80 00       	push   $0x80265e
  8010cb:	6a 64                	push   $0x64
  8010cd:	68 2c 26 80 00       	push   $0x80262c
  8010d2:	e8 77 f0 ff ff       	call   80014e <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8010d7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010dd:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8010e3:	0f 85 de fe ff ff    	jne    800fc7 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  8010e9:	a1 04 40 80 00       	mov    0x804004,%eax
  8010ee:	8b 40 70             	mov    0x70(%eax),%eax
  8010f1:	83 ec 08             	sub    $0x8,%esp
  8010f4:	50                   	push   %eax
  8010f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010f8:	57                   	push   %edi
  8010f9:	e8 fc fb ff ff       	call   800cfa <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  8010fe:	83 c4 08             	add    $0x8,%esp
  801101:	6a 02                	push   $0x2
  801103:	57                   	push   %edi
  801104:	e8 6d fb ff ff       	call   800c76 <sys_env_set_status>
	
	return envid;
  801109:	83 c4 10             	add    $0x10,%esp
  80110c:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80110e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801111:	5b                   	pop    %ebx
  801112:	5e                   	pop    %esi
  801113:	5f                   	pop    %edi
  801114:	5d                   	pop    %ebp
  801115:	c3                   	ret    

00801116 <sfork>:

envid_t
sfork(void)
{
  801116:	55                   	push   %ebp
  801117:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801119:	b8 00 00 00 00       	mov    $0x0,%eax
  80111e:	5d                   	pop    %ebp
  80111f:	c3                   	ret    

00801120 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801120:	55                   	push   %ebp
  801121:	89 e5                	mov    %esp,%ebp
  801123:	56                   	push   %esi
  801124:	53                   	push   %ebx
  801125:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801128:	89 1d 0c 40 80 00    	mov    %ebx,0x80400c
	cprintf("in fork.c thread create. func: %x\n", func);
  80112e:	83 ec 08             	sub    $0x8,%esp
  801131:	53                   	push   %ebx
  801132:	68 74 26 80 00       	push   $0x802674
  801137:	e8 eb f0 ff ff       	call   800227 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80113c:	c7 04 24 14 01 80 00 	movl   $0x800114,(%esp)
  801143:	e8 58 fc ff ff       	call   800da0 <sys_thread_create>
  801148:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80114a:	83 c4 08             	add    $0x8,%esp
  80114d:	53                   	push   %ebx
  80114e:	68 74 26 80 00       	push   $0x802674
  801153:	e8 cf f0 ff ff       	call   800227 <cprintf>
	return id;
	//return 0;
}
  801158:	89 f0                	mov    %esi,%eax
  80115a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80115d:	5b                   	pop    %ebx
  80115e:	5e                   	pop    %esi
  80115f:	5d                   	pop    %ebp
  801160:	c3                   	ret    

00801161 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801161:	55                   	push   %ebp
  801162:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801164:	8b 45 08             	mov    0x8(%ebp),%eax
  801167:	05 00 00 00 30       	add    $0x30000000,%eax
  80116c:	c1 e8 0c             	shr    $0xc,%eax
}
  80116f:	5d                   	pop    %ebp
  801170:	c3                   	ret    

00801171 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801174:	8b 45 08             	mov    0x8(%ebp),%eax
  801177:	05 00 00 00 30       	add    $0x30000000,%eax
  80117c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801181:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801186:	5d                   	pop    %ebp
  801187:	c3                   	ret    

00801188 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801188:	55                   	push   %ebp
  801189:	89 e5                	mov    %esp,%ebp
  80118b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80118e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801193:	89 c2                	mov    %eax,%edx
  801195:	c1 ea 16             	shr    $0x16,%edx
  801198:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80119f:	f6 c2 01             	test   $0x1,%dl
  8011a2:	74 11                	je     8011b5 <fd_alloc+0x2d>
  8011a4:	89 c2                	mov    %eax,%edx
  8011a6:	c1 ea 0c             	shr    $0xc,%edx
  8011a9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011b0:	f6 c2 01             	test   $0x1,%dl
  8011b3:	75 09                	jne    8011be <fd_alloc+0x36>
			*fd_store = fd;
  8011b5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8011bc:	eb 17                	jmp    8011d5 <fd_alloc+0x4d>
  8011be:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011c3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011c8:	75 c9                	jne    801193 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011ca:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011d0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011d5:	5d                   	pop    %ebp
  8011d6:	c3                   	ret    

008011d7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011d7:	55                   	push   %ebp
  8011d8:	89 e5                	mov    %esp,%ebp
  8011da:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011dd:	83 f8 1f             	cmp    $0x1f,%eax
  8011e0:	77 36                	ja     801218 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011e2:	c1 e0 0c             	shl    $0xc,%eax
  8011e5:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011ea:	89 c2                	mov    %eax,%edx
  8011ec:	c1 ea 16             	shr    $0x16,%edx
  8011ef:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011f6:	f6 c2 01             	test   $0x1,%dl
  8011f9:	74 24                	je     80121f <fd_lookup+0x48>
  8011fb:	89 c2                	mov    %eax,%edx
  8011fd:	c1 ea 0c             	shr    $0xc,%edx
  801200:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801207:	f6 c2 01             	test   $0x1,%dl
  80120a:	74 1a                	je     801226 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80120c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80120f:	89 02                	mov    %eax,(%edx)
	return 0;
  801211:	b8 00 00 00 00       	mov    $0x0,%eax
  801216:	eb 13                	jmp    80122b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801218:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80121d:	eb 0c                	jmp    80122b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80121f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801224:	eb 05                	jmp    80122b <fd_lookup+0x54>
  801226:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80122b:	5d                   	pop    %ebp
  80122c:	c3                   	ret    

0080122d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80122d:	55                   	push   %ebp
  80122e:	89 e5                	mov    %esp,%ebp
  801230:	83 ec 08             	sub    $0x8,%esp
  801233:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801236:	ba 18 27 80 00       	mov    $0x802718,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80123b:	eb 13                	jmp    801250 <dev_lookup+0x23>
  80123d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801240:	39 08                	cmp    %ecx,(%eax)
  801242:	75 0c                	jne    801250 <dev_lookup+0x23>
			*dev = devtab[i];
  801244:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801247:	89 01                	mov    %eax,(%ecx)
			return 0;
  801249:	b8 00 00 00 00       	mov    $0x0,%eax
  80124e:	eb 2e                	jmp    80127e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801250:	8b 02                	mov    (%edx),%eax
  801252:	85 c0                	test   %eax,%eax
  801254:	75 e7                	jne    80123d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801256:	a1 04 40 80 00       	mov    0x804004,%eax
  80125b:	8b 40 54             	mov    0x54(%eax),%eax
  80125e:	83 ec 04             	sub    $0x4,%esp
  801261:	51                   	push   %ecx
  801262:	50                   	push   %eax
  801263:	68 98 26 80 00       	push   $0x802698
  801268:	e8 ba ef ff ff       	call   800227 <cprintf>
	*dev = 0;
  80126d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801270:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801276:	83 c4 10             	add    $0x10,%esp
  801279:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80127e:	c9                   	leave  
  80127f:	c3                   	ret    

00801280 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801280:	55                   	push   %ebp
  801281:	89 e5                	mov    %esp,%ebp
  801283:	56                   	push   %esi
  801284:	53                   	push   %ebx
  801285:	83 ec 10             	sub    $0x10,%esp
  801288:	8b 75 08             	mov    0x8(%ebp),%esi
  80128b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80128e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801291:	50                   	push   %eax
  801292:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801298:	c1 e8 0c             	shr    $0xc,%eax
  80129b:	50                   	push   %eax
  80129c:	e8 36 ff ff ff       	call   8011d7 <fd_lookup>
  8012a1:	83 c4 08             	add    $0x8,%esp
  8012a4:	85 c0                	test   %eax,%eax
  8012a6:	78 05                	js     8012ad <fd_close+0x2d>
	    || fd != fd2)
  8012a8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012ab:	74 0c                	je     8012b9 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012ad:	84 db                	test   %bl,%bl
  8012af:	ba 00 00 00 00       	mov    $0x0,%edx
  8012b4:	0f 44 c2             	cmove  %edx,%eax
  8012b7:	eb 41                	jmp    8012fa <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012b9:	83 ec 08             	sub    $0x8,%esp
  8012bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012bf:	50                   	push   %eax
  8012c0:	ff 36                	pushl  (%esi)
  8012c2:	e8 66 ff ff ff       	call   80122d <dev_lookup>
  8012c7:	89 c3                	mov    %eax,%ebx
  8012c9:	83 c4 10             	add    $0x10,%esp
  8012cc:	85 c0                	test   %eax,%eax
  8012ce:	78 1a                	js     8012ea <fd_close+0x6a>
		if (dev->dev_close)
  8012d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012d6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	74 0b                	je     8012ea <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012df:	83 ec 0c             	sub    $0xc,%esp
  8012e2:	56                   	push   %esi
  8012e3:	ff d0                	call   *%eax
  8012e5:	89 c3                	mov    %eax,%ebx
  8012e7:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012ea:	83 ec 08             	sub    $0x8,%esp
  8012ed:	56                   	push   %esi
  8012ee:	6a 00                	push   $0x0
  8012f0:	e8 3f f9 ff ff       	call   800c34 <sys_page_unmap>
	return r;
  8012f5:	83 c4 10             	add    $0x10,%esp
  8012f8:	89 d8                	mov    %ebx,%eax
}
  8012fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012fd:	5b                   	pop    %ebx
  8012fe:	5e                   	pop    %esi
  8012ff:	5d                   	pop    %ebp
  801300:	c3                   	ret    

00801301 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801301:	55                   	push   %ebp
  801302:	89 e5                	mov    %esp,%ebp
  801304:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801307:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130a:	50                   	push   %eax
  80130b:	ff 75 08             	pushl  0x8(%ebp)
  80130e:	e8 c4 fe ff ff       	call   8011d7 <fd_lookup>
  801313:	83 c4 08             	add    $0x8,%esp
  801316:	85 c0                	test   %eax,%eax
  801318:	78 10                	js     80132a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80131a:	83 ec 08             	sub    $0x8,%esp
  80131d:	6a 01                	push   $0x1
  80131f:	ff 75 f4             	pushl  -0xc(%ebp)
  801322:	e8 59 ff ff ff       	call   801280 <fd_close>
  801327:	83 c4 10             	add    $0x10,%esp
}
  80132a:	c9                   	leave  
  80132b:	c3                   	ret    

0080132c <close_all>:

void
close_all(void)
{
  80132c:	55                   	push   %ebp
  80132d:	89 e5                	mov    %esp,%ebp
  80132f:	53                   	push   %ebx
  801330:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801333:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801338:	83 ec 0c             	sub    $0xc,%esp
  80133b:	53                   	push   %ebx
  80133c:	e8 c0 ff ff ff       	call   801301 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801341:	83 c3 01             	add    $0x1,%ebx
  801344:	83 c4 10             	add    $0x10,%esp
  801347:	83 fb 20             	cmp    $0x20,%ebx
  80134a:	75 ec                	jne    801338 <close_all+0xc>
		close(i);
}
  80134c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80134f:	c9                   	leave  
  801350:	c3                   	ret    

00801351 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801351:	55                   	push   %ebp
  801352:	89 e5                	mov    %esp,%ebp
  801354:	57                   	push   %edi
  801355:	56                   	push   %esi
  801356:	53                   	push   %ebx
  801357:	83 ec 2c             	sub    $0x2c,%esp
  80135a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80135d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801360:	50                   	push   %eax
  801361:	ff 75 08             	pushl  0x8(%ebp)
  801364:	e8 6e fe ff ff       	call   8011d7 <fd_lookup>
  801369:	83 c4 08             	add    $0x8,%esp
  80136c:	85 c0                	test   %eax,%eax
  80136e:	0f 88 c1 00 00 00    	js     801435 <dup+0xe4>
		return r;
	close(newfdnum);
  801374:	83 ec 0c             	sub    $0xc,%esp
  801377:	56                   	push   %esi
  801378:	e8 84 ff ff ff       	call   801301 <close>

	newfd = INDEX2FD(newfdnum);
  80137d:	89 f3                	mov    %esi,%ebx
  80137f:	c1 e3 0c             	shl    $0xc,%ebx
  801382:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801388:	83 c4 04             	add    $0x4,%esp
  80138b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80138e:	e8 de fd ff ff       	call   801171 <fd2data>
  801393:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801395:	89 1c 24             	mov    %ebx,(%esp)
  801398:	e8 d4 fd ff ff       	call   801171 <fd2data>
  80139d:	83 c4 10             	add    $0x10,%esp
  8013a0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013a3:	89 f8                	mov    %edi,%eax
  8013a5:	c1 e8 16             	shr    $0x16,%eax
  8013a8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013af:	a8 01                	test   $0x1,%al
  8013b1:	74 37                	je     8013ea <dup+0x99>
  8013b3:	89 f8                	mov    %edi,%eax
  8013b5:	c1 e8 0c             	shr    $0xc,%eax
  8013b8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013bf:	f6 c2 01             	test   $0x1,%dl
  8013c2:	74 26                	je     8013ea <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013c4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013cb:	83 ec 0c             	sub    $0xc,%esp
  8013ce:	25 07 0e 00 00       	and    $0xe07,%eax
  8013d3:	50                   	push   %eax
  8013d4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013d7:	6a 00                	push   $0x0
  8013d9:	57                   	push   %edi
  8013da:	6a 00                	push   $0x0
  8013dc:	e8 11 f8 ff ff       	call   800bf2 <sys_page_map>
  8013e1:	89 c7                	mov    %eax,%edi
  8013e3:	83 c4 20             	add    $0x20,%esp
  8013e6:	85 c0                	test   %eax,%eax
  8013e8:	78 2e                	js     801418 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013ea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013ed:	89 d0                	mov    %edx,%eax
  8013ef:	c1 e8 0c             	shr    $0xc,%eax
  8013f2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013f9:	83 ec 0c             	sub    $0xc,%esp
  8013fc:	25 07 0e 00 00       	and    $0xe07,%eax
  801401:	50                   	push   %eax
  801402:	53                   	push   %ebx
  801403:	6a 00                	push   $0x0
  801405:	52                   	push   %edx
  801406:	6a 00                	push   $0x0
  801408:	e8 e5 f7 ff ff       	call   800bf2 <sys_page_map>
  80140d:	89 c7                	mov    %eax,%edi
  80140f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801412:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801414:	85 ff                	test   %edi,%edi
  801416:	79 1d                	jns    801435 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801418:	83 ec 08             	sub    $0x8,%esp
  80141b:	53                   	push   %ebx
  80141c:	6a 00                	push   $0x0
  80141e:	e8 11 f8 ff ff       	call   800c34 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801423:	83 c4 08             	add    $0x8,%esp
  801426:	ff 75 d4             	pushl  -0x2c(%ebp)
  801429:	6a 00                	push   $0x0
  80142b:	e8 04 f8 ff ff       	call   800c34 <sys_page_unmap>
	return r;
  801430:	83 c4 10             	add    $0x10,%esp
  801433:	89 f8                	mov    %edi,%eax
}
  801435:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801438:	5b                   	pop    %ebx
  801439:	5e                   	pop    %esi
  80143a:	5f                   	pop    %edi
  80143b:	5d                   	pop    %ebp
  80143c:	c3                   	ret    

0080143d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80143d:	55                   	push   %ebp
  80143e:	89 e5                	mov    %esp,%ebp
  801440:	53                   	push   %ebx
  801441:	83 ec 14             	sub    $0x14,%esp
  801444:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801447:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80144a:	50                   	push   %eax
  80144b:	53                   	push   %ebx
  80144c:	e8 86 fd ff ff       	call   8011d7 <fd_lookup>
  801451:	83 c4 08             	add    $0x8,%esp
  801454:	89 c2                	mov    %eax,%edx
  801456:	85 c0                	test   %eax,%eax
  801458:	78 6d                	js     8014c7 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80145a:	83 ec 08             	sub    $0x8,%esp
  80145d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801460:	50                   	push   %eax
  801461:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801464:	ff 30                	pushl  (%eax)
  801466:	e8 c2 fd ff ff       	call   80122d <dev_lookup>
  80146b:	83 c4 10             	add    $0x10,%esp
  80146e:	85 c0                	test   %eax,%eax
  801470:	78 4c                	js     8014be <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801472:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801475:	8b 42 08             	mov    0x8(%edx),%eax
  801478:	83 e0 03             	and    $0x3,%eax
  80147b:	83 f8 01             	cmp    $0x1,%eax
  80147e:	75 21                	jne    8014a1 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801480:	a1 04 40 80 00       	mov    0x804004,%eax
  801485:	8b 40 54             	mov    0x54(%eax),%eax
  801488:	83 ec 04             	sub    $0x4,%esp
  80148b:	53                   	push   %ebx
  80148c:	50                   	push   %eax
  80148d:	68 dc 26 80 00       	push   $0x8026dc
  801492:	e8 90 ed ff ff       	call   800227 <cprintf>
		return -E_INVAL;
  801497:	83 c4 10             	add    $0x10,%esp
  80149a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80149f:	eb 26                	jmp    8014c7 <read+0x8a>
	}
	if (!dev->dev_read)
  8014a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a4:	8b 40 08             	mov    0x8(%eax),%eax
  8014a7:	85 c0                	test   %eax,%eax
  8014a9:	74 17                	je     8014c2 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8014ab:	83 ec 04             	sub    $0x4,%esp
  8014ae:	ff 75 10             	pushl  0x10(%ebp)
  8014b1:	ff 75 0c             	pushl  0xc(%ebp)
  8014b4:	52                   	push   %edx
  8014b5:	ff d0                	call   *%eax
  8014b7:	89 c2                	mov    %eax,%edx
  8014b9:	83 c4 10             	add    $0x10,%esp
  8014bc:	eb 09                	jmp    8014c7 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014be:	89 c2                	mov    %eax,%edx
  8014c0:	eb 05                	jmp    8014c7 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014c2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8014c7:	89 d0                	mov    %edx,%eax
  8014c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014cc:	c9                   	leave  
  8014cd:	c3                   	ret    

008014ce <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014ce:	55                   	push   %ebp
  8014cf:	89 e5                	mov    %esp,%ebp
  8014d1:	57                   	push   %edi
  8014d2:	56                   	push   %esi
  8014d3:	53                   	push   %ebx
  8014d4:	83 ec 0c             	sub    $0xc,%esp
  8014d7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014da:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014dd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014e2:	eb 21                	jmp    801505 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014e4:	83 ec 04             	sub    $0x4,%esp
  8014e7:	89 f0                	mov    %esi,%eax
  8014e9:	29 d8                	sub    %ebx,%eax
  8014eb:	50                   	push   %eax
  8014ec:	89 d8                	mov    %ebx,%eax
  8014ee:	03 45 0c             	add    0xc(%ebp),%eax
  8014f1:	50                   	push   %eax
  8014f2:	57                   	push   %edi
  8014f3:	e8 45 ff ff ff       	call   80143d <read>
		if (m < 0)
  8014f8:	83 c4 10             	add    $0x10,%esp
  8014fb:	85 c0                	test   %eax,%eax
  8014fd:	78 10                	js     80150f <readn+0x41>
			return m;
		if (m == 0)
  8014ff:	85 c0                	test   %eax,%eax
  801501:	74 0a                	je     80150d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801503:	01 c3                	add    %eax,%ebx
  801505:	39 f3                	cmp    %esi,%ebx
  801507:	72 db                	jb     8014e4 <readn+0x16>
  801509:	89 d8                	mov    %ebx,%eax
  80150b:	eb 02                	jmp    80150f <readn+0x41>
  80150d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80150f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801512:	5b                   	pop    %ebx
  801513:	5e                   	pop    %esi
  801514:	5f                   	pop    %edi
  801515:	5d                   	pop    %ebp
  801516:	c3                   	ret    

00801517 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801517:	55                   	push   %ebp
  801518:	89 e5                	mov    %esp,%ebp
  80151a:	53                   	push   %ebx
  80151b:	83 ec 14             	sub    $0x14,%esp
  80151e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801521:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801524:	50                   	push   %eax
  801525:	53                   	push   %ebx
  801526:	e8 ac fc ff ff       	call   8011d7 <fd_lookup>
  80152b:	83 c4 08             	add    $0x8,%esp
  80152e:	89 c2                	mov    %eax,%edx
  801530:	85 c0                	test   %eax,%eax
  801532:	78 68                	js     80159c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801534:	83 ec 08             	sub    $0x8,%esp
  801537:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80153a:	50                   	push   %eax
  80153b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153e:	ff 30                	pushl  (%eax)
  801540:	e8 e8 fc ff ff       	call   80122d <dev_lookup>
  801545:	83 c4 10             	add    $0x10,%esp
  801548:	85 c0                	test   %eax,%eax
  80154a:	78 47                	js     801593 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80154c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801553:	75 21                	jne    801576 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801555:	a1 04 40 80 00       	mov    0x804004,%eax
  80155a:	8b 40 54             	mov    0x54(%eax),%eax
  80155d:	83 ec 04             	sub    $0x4,%esp
  801560:	53                   	push   %ebx
  801561:	50                   	push   %eax
  801562:	68 f8 26 80 00       	push   $0x8026f8
  801567:	e8 bb ec ff ff       	call   800227 <cprintf>
		return -E_INVAL;
  80156c:	83 c4 10             	add    $0x10,%esp
  80156f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801574:	eb 26                	jmp    80159c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801576:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801579:	8b 52 0c             	mov    0xc(%edx),%edx
  80157c:	85 d2                	test   %edx,%edx
  80157e:	74 17                	je     801597 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801580:	83 ec 04             	sub    $0x4,%esp
  801583:	ff 75 10             	pushl  0x10(%ebp)
  801586:	ff 75 0c             	pushl  0xc(%ebp)
  801589:	50                   	push   %eax
  80158a:	ff d2                	call   *%edx
  80158c:	89 c2                	mov    %eax,%edx
  80158e:	83 c4 10             	add    $0x10,%esp
  801591:	eb 09                	jmp    80159c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801593:	89 c2                	mov    %eax,%edx
  801595:	eb 05                	jmp    80159c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801597:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80159c:	89 d0                	mov    %edx,%eax
  80159e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a1:	c9                   	leave  
  8015a2:	c3                   	ret    

008015a3 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015a3:	55                   	push   %ebp
  8015a4:	89 e5                	mov    %esp,%ebp
  8015a6:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015a9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015ac:	50                   	push   %eax
  8015ad:	ff 75 08             	pushl  0x8(%ebp)
  8015b0:	e8 22 fc ff ff       	call   8011d7 <fd_lookup>
  8015b5:	83 c4 08             	add    $0x8,%esp
  8015b8:	85 c0                	test   %eax,%eax
  8015ba:	78 0e                	js     8015ca <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015c2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015ca:	c9                   	leave  
  8015cb:	c3                   	ret    

008015cc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	53                   	push   %ebx
  8015d0:	83 ec 14             	sub    $0x14,%esp
  8015d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d9:	50                   	push   %eax
  8015da:	53                   	push   %ebx
  8015db:	e8 f7 fb ff ff       	call   8011d7 <fd_lookup>
  8015e0:	83 c4 08             	add    $0x8,%esp
  8015e3:	89 c2                	mov    %eax,%edx
  8015e5:	85 c0                	test   %eax,%eax
  8015e7:	78 65                	js     80164e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e9:	83 ec 08             	sub    $0x8,%esp
  8015ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ef:	50                   	push   %eax
  8015f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f3:	ff 30                	pushl  (%eax)
  8015f5:	e8 33 fc ff ff       	call   80122d <dev_lookup>
  8015fa:	83 c4 10             	add    $0x10,%esp
  8015fd:	85 c0                	test   %eax,%eax
  8015ff:	78 44                	js     801645 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801601:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801604:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801608:	75 21                	jne    80162b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80160a:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80160f:	8b 40 54             	mov    0x54(%eax),%eax
  801612:	83 ec 04             	sub    $0x4,%esp
  801615:	53                   	push   %ebx
  801616:	50                   	push   %eax
  801617:	68 b8 26 80 00       	push   $0x8026b8
  80161c:	e8 06 ec ff ff       	call   800227 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801621:	83 c4 10             	add    $0x10,%esp
  801624:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801629:	eb 23                	jmp    80164e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80162b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80162e:	8b 52 18             	mov    0x18(%edx),%edx
  801631:	85 d2                	test   %edx,%edx
  801633:	74 14                	je     801649 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801635:	83 ec 08             	sub    $0x8,%esp
  801638:	ff 75 0c             	pushl  0xc(%ebp)
  80163b:	50                   	push   %eax
  80163c:	ff d2                	call   *%edx
  80163e:	89 c2                	mov    %eax,%edx
  801640:	83 c4 10             	add    $0x10,%esp
  801643:	eb 09                	jmp    80164e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801645:	89 c2                	mov    %eax,%edx
  801647:	eb 05                	jmp    80164e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801649:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80164e:	89 d0                	mov    %edx,%eax
  801650:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801653:	c9                   	leave  
  801654:	c3                   	ret    

00801655 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801655:	55                   	push   %ebp
  801656:	89 e5                	mov    %esp,%ebp
  801658:	53                   	push   %ebx
  801659:	83 ec 14             	sub    $0x14,%esp
  80165c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80165f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801662:	50                   	push   %eax
  801663:	ff 75 08             	pushl  0x8(%ebp)
  801666:	e8 6c fb ff ff       	call   8011d7 <fd_lookup>
  80166b:	83 c4 08             	add    $0x8,%esp
  80166e:	89 c2                	mov    %eax,%edx
  801670:	85 c0                	test   %eax,%eax
  801672:	78 58                	js     8016cc <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801674:	83 ec 08             	sub    $0x8,%esp
  801677:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80167a:	50                   	push   %eax
  80167b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167e:	ff 30                	pushl  (%eax)
  801680:	e8 a8 fb ff ff       	call   80122d <dev_lookup>
  801685:	83 c4 10             	add    $0x10,%esp
  801688:	85 c0                	test   %eax,%eax
  80168a:	78 37                	js     8016c3 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80168c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80168f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801693:	74 32                	je     8016c7 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801695:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801698:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80169f:	00 00 00 
	stat->st_isdir = 0;
  8016a2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016a9:	00 00 00 
	stat->st_dev = dev;
  8016ac:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016b2:	83 ec 08             	sub    $0x8,%esp
  8016b5:	53                   	push   %ebx
  8016b6:	ff 75 f0             	pushl  -0x10(%ebp)
  8016b9:	ff 50 14             	call   *0x14(%eax)
  8016bc:	89 c2                	mov    %eax,%edx
  8016be:	83 c4 10             	add    $0x10,%esp
  8016c1:	eb 09                	jmp    8016cc <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c3:	89 c2                	mov    %eax,%edx
  8016c5:	eb 05                	jmp    8016cc <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016c7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016cc:	89 d0                	mov    %edx,%eax
  8016ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d1:	c9                   	leave  
  8016d2:	c3                   	ret    

008016d3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016d3:	55                   	push   %ebp
  8016d4:	89 e5                	mov    %esp,%ebp
  8016d6:	56                   	push   %esi
  8016d7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016d8:	83 ec 08             	sub    $0x8,%esp
  8016db:	6a 00                	push   $0x0
  8016dd:	ff 75 08             	pushl  0x8(%ebp)
  8016e0:	e8 e3 01 00 00       	call   8018c8 <open>
  8016e5:	89 c3                	mov    %eax,%ebx
  8016e7:	83 c4 10             	add    $0x10,%esp
  8016ea:	85 c0                	test   %eax,%eax
  8016ec:	78 1b                	js     801709 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016ee:	83 ec 08             	sub    $0x8,%esp
  8016f1:	ff 75 0c             	pushl  0xc(%ebp)
  8016f4:	50                   	push   %eax
  8016f5:	e8 5b ff ff ff       	call   801655 <fstat>
  8016fa:	89 c6                	mov    %eax,%esi
	close(fd);
  8016fc:	89 1c 24             	mov    %ebx,(%esp)
  8016ff:	e8 fd fb ff ff       	call   801301 <close>
	return r;
  801704:	83 c4 10             	add    $0x10,%esp
  801707:	89 f0                	mov    %esi,%eax
}
  801709:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80170c:	5b                   	pop    %ebx
  80170d:	5e                   	pop    %esi
  80170e:	5d                   	pop    %ebp
  80170f:	c3                   	ret    

00801710 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801710:	55                   	push   %ebp
  801711:	89 e5                	mov    %esp,%ebp
  801713:	56                   	push   %esi
  801714:	53                   	push   %ebx
  801715:	89 c6                	mov    %eax,%esi
  801717:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801719:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801720:	75 12                	jne    801734 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801722:	83 ec 0c             	sub    $0xc,%esp
  801725:	6a 01                	push   $0x1
  801727:	e8 f9 07 00 00       	call   801f25 <ipc_find_env>
  80172c:	a3 00 40 80 00       	mov    %eax,0x804000
  801731:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801734:	6a 07                	push   $0x7
  801736:	68 00 50 80 00       	push   $0x805000
  80173b:	56                   	push   %esi
  80173c:	ff 35 00 40 80 00    	pushl  0x804000
  801742:	e8 7c 07 00 00       	call   801ec3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801747:	83 c4 0c             	add    $0xc,%esp
  80174a:	6a 00                	push   $0x0
  80174c:	53                   	push   %ebx
  80174d:	6a 00                	push   $0x0
  80174f:	e8 f7 06 00 00       	call   801e4b <ipc_recv>
}
  801754:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801757:	5b                   	pop    %ebx
  801758:	5e                   	pop    %esi
  801759:	5d                   	pop    %ebp
  80175a:	c3                   	ret    

0080175b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80175b:	55                   	push   %ebp
  80175c:	89 e5                	mov    %esp,%ebp
  80175e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801761:	8b 45 08             	mov    0x8(%ebp),%eax
  801764:	8b 40 0c             	mov    0xc(%eax),%eax
  801767:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80176c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80176f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801774:	ba 00 00 00 00       	mov    $0x0,%edx
  801779:	b8 02 00 00 00       	mov    $0x2,%eax
  80177e:	e8 8d ff ff ff       	call   801710 <fsipc>
}
  801783:	c9                   	leave  
  801784:	c3                   	ret    

00801785 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801785:	55                   	push   %ebp
  801786:	89 e5                	mov    %esp,%ebp
  801788:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80178b:	8b 45 08             	mov    0x8(%ebp),%eax
  80178e:	8b 40 0c             	mov    0xc(%eax),%eax
  801791:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801796:	ba 00 00 00 00       	mov    $0x0,%edx
  80179b:	b8 06 00 00 00       	mov    $0x6,%eax
  8017a0:	e8 6b ff ff ff       	call   801710 <fsipc>
}
  8017a5:	c9                   	leave  
  8017a6:	c3                   	ret    

008017a7 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017a7:	55                   	push   %ebp
  8017a8:	89 e5                	mov    %esp,%ebp
  8017aa:	53                   	push   %ebx
  8017ab:	83 ec 04             	sub    $0x4,%esp
  8017ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c1:	b8 05 00 00 00       	mov    $0x5,%eax
  8017c6:	e8 45 ff ff ff       	call   801710 <fsipc>
  8017cb:	85 c0                	test   %eax,%eax
  8017cd:	78 2c                	js     8017fb <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017cf:	83 ec 08             	sub    $0x8,%esp
  8017d2:	68 00 50 80 00       	push   $0x805000
  8017d7:	53                   	push   %ebx
  8017d8:	e8 cf ef ff ff       	call   8007ac <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017dd:	a1 80 50 80 00       	mov    0x805080,%eax
  8017e2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017e8:	a1 84 50 80 00       	mov    0x805084,%eax
  8017ed:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017f3:	83 c4 10             	add    $0x10,%esp
  8017f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017fe:	c9                   	leave  
  8017ff:	c3                   	ret    

00801800 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	83 ec 0c             	sub    $0xc,%esp
  801806:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801809:	8b 55 08             	mov    0x8(%ebp),%edx
  80180c:	8b 52 0c             	mov    0xc(%edx),%edx
  80180f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801815:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80181a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80181f:	0f 47 c2             	cmova  %edx,%eax
  801822:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801827:	50                   	push   %eax
  801828:	ff 75 0c             	pushl  0xc(%ebp)
  80182b:	68 08 50 80 00       	push   $0x805008
  801830:	e8 09 f1 ff ff       	call   80093e <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801835:	ba 00 00 00 00       	mov    $0x0,%edx
  80183a:	b8 04 00 00 00       	mov    $0x4,%eax
  80183f:	e8 cc fe ff ff       	call   801710 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801844:	c9                   	leave  
  801845:	c3                   	ret    

00801846 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801846:	55                   	push   %ebp
  801847:	89 e5                	mov    %esp,%ebp
  801849:	56                   	push   %esi
  80184a:	53                   	push   %ebx
  80184b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80184e:	8b 45 08             	mov    0x8(%ebp),%eax
  801851:	8b 40 0c             	mov    0xc(%eax),%eax
  801854:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801859:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80185f:	ba 00 00 00 00       	mov    $0x0,%edx
  801864:	b8 03 00 00 00       	mov    $0x3,%eax
  801869:	e8 a2 fe ff ff       	call   801710 <fsipc>
  80186e:	89 c3                	mov    %eax,%ebx
  801870:	85 c0                	test   %eax,%eax
  801872:	78 4b                	js     8018bf <devfile_read+0x79>
		return r;
	assert(r <= n);
  801874:	39 c6                	cmp    %eax,%esi
  801876:	73 16                	jae    80188e <devfile_read+0x48>
  801878:	68 28 27 80 00       	push   $0x802728
  80187d:	68 2f 27 80 00       	push   $0x80272f
  801882:	6a 7c                	push   $0x7c
  801884:	68 44 27 80 00       	push   $0x802744
  801889:	e8 c0 e8 ff ff       	call   80014e <_panic>
	assert(r <= PGSIZE);
  80188e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801893:	7e 16                	jle    8018ab <devfile_read+0x65>
  801895:	68 4f 27 80 00       	push   $0x80274f
  80189a:	68 2f 27 80 00       	push   $0x80272f
  80189f:	6a 7d                	push   $0x7d
  8018a1:	68 44 27 80 00       	push   $0x802744
  8018a6:	e8 a3 e8 ff ff       	call   80014e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018ab:	83 ec 04             	sub    $0x4,%esp
  8018ae:	50                   	push   %eax
  8018af:	68 00 50 80 00       	push   $0x805000
  8018b4:	ff 75 0c             	pushl  0xc(%ebp)
  8018b7:	e8 82 f0 ff ff       	call   80093e <memmove>
	return r;
  8018bc:	83 c4 10             	add    $0x10,%esp
}
  8018bf:	89 d8                	mov    %ebx,%eax
  8018c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c4:	5b                   	pop    %ebx
  8018c5:	5e                   	pop    %esi
  8018c6:	5d                   	pop    %ebp
  8018c7:	c3                   	ret    

008018c8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018c8:	55                   	push   %ebp
  8018c9:	89 e5                	mov    %esp,%ebp
  8018cb:	53                   	push   %ebx
  8018cc:	83 ec 20             	sub    $0x20,%esp
  8018cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018d2:	53                   	push   %ebx
  8018d3:	e8 9b ee ff ff       	call   800773 <strlen>
  8018d8:	83 c4 10             	add    $0x10,%esp
  8018db:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018e0:	7f 67                	jg     801949 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018e2:	83 ec 0c             	sub    $0xc,%esp
  8018e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018e8:	50                   	push   %eax
  8018e9:	e8 9a f8 ff ff       	call   801188 <fd_alloc>
  8018ee:	83 c4 10             	add    $0x10,%esp
		return r;
  8018f1:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018f3:	85 c0                	test   %eax,%eax
  8018f5:	78 57                	js     80194e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018f7:	83 ec 08             	sub    $0x8,%esp
  8018fa:	53                   	push   %ebx
  8018fb:	68 00 50 80 00       	push   $0x805000
  801900:	e8 a7 ee ff ff       	call   8007ac <strcpy>
	fsipcbuf.open.req_omode = mode;
  801905:	8b 45 0c             	mov    0xc(%ebp),%eax
  801908:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80190d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801910:	b8 01 00 00 00       	mov    $0x1,%eax
  801915:	e8 f6 fd ff ff       	call   801710 <fsipc>
  80191a:	89 c3                	mov    %eax,%ebx
  80191c:	83 c4 10             	add    $0x10,%esp
  80191f:	85 c0                	test   %eax,%eax
  801921:	79 14                	jns    801937 <open+0x6f>
		fd_close(fd, 0);
  801923:	83 ec 08             	sub    $0x8,%esp
  801926:	6a 00                	push   $0x0
  801928:	ff 75 f4             	pushl  -0xc(%ebp)
  80192b:	e8 50 f9 ff ff       	call   801280 <fd_close>
		return r;
  801930:	83 c4 10             	add    $0x10,%esp
  801933:	89 da                	mov    %ebx,%edx
  801935:	eb 17                	jmp    80194e <open+0x86>
	}

	return fd2num(fd);
  801937:	83 ec 0c             	sub    $0xc,%esp
  80193a:	ff 75 f4             	pushl  -0xc(%ebp)
  80193d:	e8 1f f8 ff ff       	call   801161 <fd2num>
  801942:	89 c2                	mov    %eax,%edx
  801944:	83 c4 10             	add    $0x10,%esp
  801947:	eb 05                	jmp    80194e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801949:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80194e:	89 d0                	mov    %edx,%eax
  801950:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801953:	c9                   	leave  
  801954:	c3                   	ret    

00801955 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801955:	55                   	push   %ebp
  801956:	89 e5                	mov    %esp,%ebp
  801958:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80195b:	ba 00 00 00 00       	mov    $0x0,%edx
  801960:	b8 08 00 00 00       	mov    $0x8,%eax
  801965:	e8 a6 fd ff ff       	call   801710 <fsipc>
}
  80196a:	c9                   	leave  
  80196b:	c3                   	ret    

0080196c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	56                   	push   %esi
  801970:	53                   	push   %ebx
  801971:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801974:	83 ec 0c             	sub    $0xc,%esp
  801977:	ff 75 08             	pushl  0x8(%ebp)
  80197a:	e8 f2 f7 ff ff       	call   801171 <fd2data>
  80197f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801981:	83 c4 08             	add    $0x8,%esp
  801984:	68 5b 27 80 00       	push   $0x80275b
  801989:	53                   	push   %ebx
  80198a:	e8 1d ee ff ff       	call   8007ac <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80198f:	8b 46 04             	mov    0x4(%esi),%eax
  801992:	2b 06                	sub    (%esi),%eax
  801994:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80199a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019a1:	00 00 00 
	stat->st_dev = &devpipe;
  8019a4:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019ab:	30 80 00 
	return 0;
}
  8019ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019b6:	5b                   	pop    %ebx
  8019b7:	5e                   	pop    %esi
  8019b8:	5d                   	pop    %ebp
  8019b9:	c3                   	ret    

008019ba <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019ba:	55                   	push   %ebp
  8019bb:	89 e5                	mov    %esp,%ebp
  8019bd:	53                   	push   %ebx
  8019be:	83 ec 0c             	sub    $0xc,%esp
  8019c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019c4:	53                   	push   %ebx
  8019c5:	6a 00                	push   $0x0
  8019c7:	e8 68 f2 ff ff       	call   800c34 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019cc:	89 1c 24             	mov    %ebx,(%esp)
  8019cf:	e8 9d f7 ff ff       	call   801171 <fd2data>
  8019d4:	83 c4 08             	add    $0x8,%esp
  8019d7:	50                   	push   %eax
  8019d8:	6a 00                	push   $0x0
  8019da:	e8 55 f2 ff ff       	call   800c34 <sys_page_unmap>
}
  8019df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e2:	c9                   	leave  
  8019e3:	c3                   	ret    

008019e4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019e4:	55                   	push   %ebp
  8019e5:	89 e5                	mov    %esp,%ebp
  8019e7:	57                   	push   %edi
  8019e8:	56                   	push   %esi
  8019e9:	53                   	push   %ebx
  8019ea:	83 ec 1c             	sub    $0x1c,%esp
  8019ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019f0:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019f2:	a1 04 40 80 00       	mov    0x804004,%eax
  8019f7:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019fa:	83 ec 0c             	sub    $0xc,%esp
  8019fd:	ff 75 e0             	pushl  -0x20(%ebp)
  801a00:	e8 60 05 00 00       	call   801f65 <pageref>
  801a05:	89 c3                	mov    %eax,%ebx
  801a07:	89 3c 24             	mov    %edi,(%esp)
  801a0a:	e8 56 05 00 00       	call   801f65 <pageref>
  801a0f:	83 c4 10             	add    $0x10,%esp
  801a12:	39 c3                	cmp    %eax,%ebx
  801a14:	0f 94 c1             	sete   %cl
  801a17:	0f b6 c9             	movzbl %cl,%ecx
  801a1a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a1d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a23:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  801a26:	39 ce                	cmp    %ecx,%esi
  801a28:	74 1b                	je     801a45 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a2a:	39 c3                	cmp    %eax,%ebx
  801a2c:	75 c4                	jne    8019f2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a2e:	8b 42 64             	mov    0x64(%edx),%eax
  801a31:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a34:	50                   	push   %eax
  801a35:	56                   	push   %esi
  801a36:	68 62 27 80 00       	push   $0x802762
  801a3b:	e8 e7 e7 ff ff       	call   800227 <cprintf>
  801a40:	83 c4 10             	add    $0x10,%esp
  801a43:	eb ad                	jmp    8019f2 <_pipeisclosed+0xe>
	}
}
  801a45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a4b:	5b                   	pop    %ebx
  801a4c:	5e                   	pop    %esi
  801a4d:	5f                   	pop    %edi
  801a4e:	5d                   	pop    %ebp
  801a4f:	c3                   	ret    

00801a50 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	57                   	push   %edi
  801a54:	56                   	push   %esi
  801a55:	53                   	push   %ebx
  801a56:	83 ec 28             	sub    $0x28,%esp
  801a59:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a5c:	56                   	push   %esi
  801a5d:	e8 0f f7 ff ff       	call   801171 <fd2data>
  801a62:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a64:	83 c4 10             	add    $0x10,%esp
  801a67:	bf 00 00 00 00       	mov    $0x0,%edi
  801a6c:	eb 4b                	jmp    801ab9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a6e:	89 da                	mov    %ebx,%edx
  801a70:	89 f0                	mov    %esi,%eax
  801a72:	e8 6d ff ff ff       	call   8019e4 <_pipeisclosed>
  801a77:	85 c0                	test   %eax,%eax
  801a79:	75 48                	jne    801ac3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a7b:	e8 10 f1 ff ff       	call   800b90 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a80:	8b 43 04             	mov    0x4(%ebx),%eax
  801a83:	8b 0b                	mov    (%ebx),%ecx
  801a85:	8d 51 20             	lea    0x20(%ecx),%edx
  801a88:	39 d0                	cmp    %edx,%eax
  801a8a:	73 e2                	jae    801a6e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a8f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a93:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a96:	89 c2                	mov    %eax,%edx
  801a98:	c1 fa 1f             	sar    $0x1f,%edx
  801a9b:	89 d1                	mov    %edx,%ecx
  801a9d:	c1 e9 1b             	shr    $0x1b,%ecx
  801aa0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801aa3:	83 e2 1f             	and    $0x1f,%edx
  801aa6:	29 ca                	sub    %ecx,%edx
  801aa8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801aac:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ab0:	83 c0 01             	add    $0x1,%eax
  801ab3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ab6:	83 c7 01             	add    $0x1,%edi
  801ab9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801abc:	75 c2                	jne    801a80 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801abe:	8b 45 10             	mov    0x10(%ebp),%eax
  801ac1:	eb 05                	jmp    801ac8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ac3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ac8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801acb:	5b                   	pop    %ebx
  801acc:	5e                   	pop    %esi
  801acd:	5f                   	pop    %edi
  801ace:	5d                   	pop    %ebp
  801acf:	c3                   	ret    

00801ad0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ad0:	55                   	push   %ebp
  801ad1:	89 e5                	mov    %esp,%ebp
  801ad3:	57                   	push   %edi
  801ad4:	56                   	push   %esi
  801ad5:	53                   	push   %ebx
  801ad6:	83 ec 18             	sub    $0x18,%esp
  801ad9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801adc:	57                   	push   %edi
  801add:	e8 8f f6 ff ff       	call   801171 <fd2data>
  801ae2:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ae4:	83 c4 10             	add    $0x10,%esp
  801ae7:	bb 00 00 00 00       	mov    $0x0,%ebx
  801aec:	eb 3d                	jmp    801b2b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801aee:	85 db                	test   %ebx,%ebx
  801af0:	74 04                	je     801af6 <devpipe_read+0x26>
				return i;
  801af2:	89 d8                	mov    %ebx,%eax
  801af4:	eb 44                	jmp    801b3a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801af6:	89 f2                	mov    %esi,%edx
  801af8:	89 f8                	mov    %edi,%eax
  801afa:	e8 e5 fe ff ff       	call   8019e4 <_pipeisclosed>
  801aff:	85 c0                	test   %eax,%eax
  801b01:	75 32                	jne    801b35 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b03:	e8 88 f0 ff ff       	call   800b90 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b08:	8b 06                	mov    (%esi),%eax
  801b0a:	3b 46 04             	cmp    0x4(%esi),%eax
  801b0d:	74 df                	je     801aee <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b0f:	99                   	cltd   
  801b10:	c1 ea 1b             	shr    $0x1b,%edx
  801b13:	01 d0                	add    %edx,%eax
  801b15:	83 e0 1f             	and    $0x1f,%eax
  801b18:	29 d0                	sub    %edx,%eax
  801b1a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b22:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b25:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b28:	83 c3 01             	add    $0x1,%ebx
  801b2b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b2e:	75 d8                	jne    801b08 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b30:	8b 45 10             	mov    0x10(%ebp),%eax
  801b33:	eb 05                	jmp    801b3a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b35:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b3d:	5b                   	pop    %ebx
  801b3e:	5e                   	pop    %esi
  801b3f:	5f                   	pop    %edi
  801b40:	5d                   	pop    %ebp
  801b41:	c3                   	ret    

00801b42 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b42:	55                   	push   %ebp
  801b43:	89 e5                	mov    %esp,%ebp
  801b45:	56                   	push   %esi
  801b46:	53                   	push   %ebx
  801b47:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b4a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b4d:	50                   	push   %eax
  801b4e:	e8 35 f6 ff ff       	call   801188 <fd_alloc>
  801b53:	83 c4 10             	add    $0x10,%esp
  801b56:	89 c2                	mov    %eax,%edx
  801b58:	85 c0                	test   %eax,%eax
  801b5a:	0f 88 2c 01 00 00    	js     801c8c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b60:	83 ec 04             	sub    $0x4,%esp
  801b63:	68 07 04 00 00       	push   $0x407
  801b68:	ff 75 f4             	pushl  -0xc(%ebp)
  801b6b:	6a 00                	push   $0x0
  801b6d:	e8 3d f0 ff ff       	call   800baf <sys_page_alloc>
  801b72:	83 c4 10             	add    $0x10,%esp
  801b75:	89 c2                	mov    %eax,%edx
  801b77:	85 c0                	test   %eax,%eax
  801b79:	0f 88 0d 01 00 00    	js     801c8c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b7f:	83 ec 0c             	sub    $0xc,%esp
  801b82:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b85:	50                   	push   %eax
  801b86:	e8 fd f5 ff ff       	call   801188 <fd_alloc>
  801b8b:	89 c3                	mov    %eax,%ebx
  801b8d:	83 c4 10             	add    $0x10,%esp
  801b90:	85 c0                	test   %eax,%eax
  801b92:	0f 88 e2 00 00 00    	js     801c7a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b98:	83 ec 04             	sub    $0x4,%esp
  801b9b:	68 07 04 00 00       	push   $0x407
  801ba0:	ff 75 f0             	pushl  -0x10(%ebp)
  801ba3:	6a 00                	push   $0x0
  801ba5:	e8 05 f0 ff ff       	call   800baf <sys_page_alloc>
  801baa:	89 c3                	mov    %eax,%ebx
  801bac:	83 c4 10             	add    $0x10,%esp
  801baf:	85 c0                	test   %eax,%eax
  801bb1:	0f 88 c3 00 00 00    	js     801c7a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bb7:	83 ec 0c             	sub    $0xc,%esp
  801bba:	ff 75 f4             	pushl  -0xc(%ebp)
  801bbd:	e8 af f5 ff ff       	call   801171 <fd2data>
  801bc2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc4:	83 c4 0c             	add    $0xc,%esp
  801bc7:	68 07 04 00 00       	push   $0x407
  801bcc:	50                   	push   %eax
  801bcd:	6a 00                	push   $0x0
  801bcf:	e8 db ef ff ff       	call   800baf <sys_page_alloc>
  801bd4:	89 c3                	mov    %eax,%ebx
  801bd6:	83 c4 10             	add    $0x10,%esp
  801bd9:	85 c0                	test   %eax,%eax
  801bdb:	0f 88 89 00 00 00    	js     801c6a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be1:	83 ec 0c             	sub    $0xc,%esp
  801be4:	ff 75 f0             	pushl  -0x10(%ebp)
  801be7:	e8 85 f5 ff ff       	call   801171 <fd2data>
  801bec:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bf3:	50                   	push   %eax
  801bf4:	6a 00                	push   $0x0
  801bf6:	56                   	push   %esi
  801bf7:	6a 00                	push   $0x0
  801bf9:	e8 f4 ef ff ff       	call   800bf2 <sys_page_map>
  801bfe:	89 c3                	mov    %eax,%ebx
  801c00:	83 c4 20             	add    $0x20,%esp
  801c03:	85 c0                	test   %eax,%eax
  801c05:	78 55                	js     801c5c <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c07:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c10:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c15:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c1c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c25:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c27:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c2a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c31:	83 ec 0c             	sub    $0xc,%esp
  801c34:	ff 75 f4             	pushl  -0xc(%ebp)
  801c37:	e8 25 f5 ff ff       	call   801161 <fd2num>
  801c3c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c3f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c41:	83 c4 04             	add    $0x4,%esp
  801c44:	ff 75 f0             	pushl  -0x10(%ebp)
  801c47:	e8 15 f5 ff ff       	call   801161 <fd2num>
  801c4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c4f:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801c52:	83 c4 10             	add    $0x10,%esp
  801c55:	ba 00 00 00 00       	mov    $0x0,%edx
  801c5a:	eb 30                	jmp    801c8c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c5c:	83 ec 08             	sub    $0x8,%esp
  801c5f:	56                   	push   %esi
  801c60:	6a 00                	push   $0x0
  801c62:	e8 cd ef ff ff       	call   800c34 <sys_page_unmap>
  801c67:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c6a:	83 ec 08             	sub    $0x8,%esp
  801c6d:	ff 75 f0             	pushl  -0x10(%ebp)
  801c70:	6a 00                	push   $0x0
  801c72:	e8 bd ef ff ff       	call   800c34 <sys_page_unmap>
  801c77:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c7a:	83 ec 08             	sub    $0x8,%esp
  801c7d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c80:	6a 00                	push   $0x0
  801c82:	e8 ad ef ff ff       	call   800c34 <sys_page_unmap>
  801c87:	83 c4 10             	add    $0x10,%esp
  801c8a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c8c:	89 d0                	mov    %edx,%eax
  801c8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c91:	5b                   	pop    %ebx
  801c92:	5e                   	pop    %esi
  801c93:	5d                   	pop    %ebp
  801c94:	c3                   	ret    

00801c95 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c95:	55                   	push   %ebp
  801c96:	89 e5                	mov    %esp,%ebp
  801c98:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c9e:	50                   	push   %eax
  801c9f:	ff 75 08             	pushl  0x8(%ebp)
  801ca2:	e8 30 f5 ff ff       	call   8011d7 <fd_lookup>
  801ca7:	83 c4 10             	add    $0x10,%esp
  801caa:	85 c0                	test   %eax,%eax
  801cac:	78 18                	js     801cc6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cae:	83 ec 0c             	sub    $0xc,%esp
  801cb1:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb4:	e8 b8 f4 ff ff       	call   801171 <fd2data>
	return _pipeisclosed(fd, p);
  801cb9:	89 c2                	mov    %eax,%edx
  801cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cbe:	e8 21 fd ff ff       	call   8019e4 <_pipeisclosed>
  801cc3:	83 c4 10             	add    $0x10,%esp
}
  801cc6:	c9                   	leave  
  801cc7:	c3                   	ret    

00801cc8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cc8:	55                   	push   %ebp
  801cc9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ccb:	b8 00 00 00 00       	mov    $0x0,%eax
  801cd0:	5d                   	pop    %ebp
  801cd1:	c3                   	ret    

00801cd2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cd2:	55                   	push   %ebp
  801cd3:	89 e5                	mov    %esp,%ebp
  801cd5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cd8:	68 7a 27 80 00       	push   $0x80277a
  801cdd:	ff 75 0c             	pushl  0xc(%ebp)
  801ce0:	e8 c7 ea ff ff       	call   8007ac <strcpy>
	return 0;
}
  801ce5:	b8 00 00 00 00       	mov    $0x0,%eax
  801cea:	c9                   	leave  
  801ceb:	c3                   	ret    

00801cec <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cec:	55                   	push   %ebp
  801ced:	89 e5                	mov    %esp,%ebp
  801cef:	57                   	push   %edi
  801cf0:	56                   	push   %esi
  801cf1:	53                   	push   %ebx
  801cf2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cf8:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cfd:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d03:	eb 2d                	jmp    801d32 <devcons_write+0x46>
		m = n - tot;
  801d05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d08:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d0a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d0d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d12:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d15:	83 ec 04             	sub    $0x4,%esp
  801d18:	53                   	push   %ebx
  801d19:	03 45 0c             	add    0xc(%ebp),%eax
  801d1c:	50                   	push   %eax
  801d1d:	57                   	push   %edi
  801d1e:	e8 1b ec ff ff       	call   80093e <memmove>
		sys_cputs(buf, m);
  801d23:	83 c4 08             	add    $0x8,%esp
  801d26:	53                   	push   %ebx
  801d27:	57                   	push   %edi
  801d28:	e8 c6 ed ff ff       	call   800af3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d2d:	01 de                	add    %ebx,%esi
  801d2f:	83 c4 10             	add    $0x10,%esp
  801d32:	89 f0                	mov    %esi,%eax
  801d34:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d37:	72 cc                	jb     801d05 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d3c:	5b                   	pop    %ebx
  801d3d:	5e                   	pop    %esi
  801d3e:	5f                   	pop    %edi
  801d3f:	5d                   	pop    %ebp
  801d40:	c3                   	ret    

00801d41 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d41:	55                   	push   %ebp
  801d42:	89 e5                	mov    %esp,%ebp
  801d44:	83 ec 08             	sub    $0x8,%esp
  801d47:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d4c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d50:	74 2a                	je     801d7c <devcons_read+0x3b>
  801d52:	eb 05                	jmp    801d59 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d54:	e8 37 ee ff ff       	call   800b90 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d59:	e8 b3 ed ff ff       	call   800b11 <sys_cgetc>
  801d5e:	85 c0                	test   %eax,%eax
  801d60:	74 f2                	je     801d54 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d62:	85 c0                	test   %eax,%eax
  801d64:	78 16                	js     801d7c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d66:	83 f8 04             	cmp    $0x4,%eax
  801d69:	74 0c                	je     801d77 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d6e:	88 02                	mov    %al,(%edx)
	return 1;
  801d70:	b8 01 00 00 00       	mov    $0x1,%eax
  801d75:	eb 05                	jmp    801d7c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d77:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d7c:	c9                   	leave  
  801d7d:	c3                   	ret    

00801d7e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d7e:	55                   	push   %ebp
  801d7f:	89 e5                	mov    %esp,%ebp
  801d81:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d84:	8b 45 08             	mov    0x8(%ebp),%eax
  801d87:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d8a:	6a 01                	push   $0x1
  801d8c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d8f:	50                   	push   %eax
  801d90:	e8 5e ed ff ff       	call   800af3 <sys_cputs>
}
  801d95:	83 c4 10             	add    $0x10,%esp
  801d98:	c9                   	leave  
  801d99:	c3                   	ret    

00801d9a <getchar>:

int
getchar(void)
{
  801d9a:	55                   	push   %ebp
  801d9b:	89 e5                	mov    %esp,%ebp
  801d9d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801da0:	6a 01                	push   $0x1
  801da2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801da5:	50                   	push   %eax
  801da6:	6a 00                	push   $0x0
  801da8:	e8 90 f6 ff ff       	call   80143d <read>
	if (r < 0)
  801dad:	83 c4 10             	add    $0x10,%esp
  801db0:	85 c0                	test   %eax,%eax
  801db2:	78 0f                	js     801dc3 <getchar+0x29>
		return r;
	if (r < 1)
  801db4:	85 c0                	test   %eax,%eax
  801db6:	7e 06                	jle    801dbe <getchar+0x24>
		return -E_EOF;
	return c;
  801db8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801dbc:	eb 05                	jmp    801dc3 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801dbe:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801dc3:	c9                   	leave  
  801dc4:	c3                   	ret    

00801dc5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801dc5:	55                   	push   %ebp
  801dc6:	89 e5                	mov    %esp,%ebp
  801dc8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dcb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dce:	50                   	push   %eax
  801dcf:	ff 75 08             	pushl  0x8(%ebp)
  801dd2:	e8 00 f4 ff ff       	call   8011d7 <fd_lookup>
  801dd7:	83 c4 10             	add    $0x10,%esp
  801dda:	85 c0                	test   %eax,%eax
  801ddc:	78 11                	js     801def <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801dde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801de7:	39 10                	cmp    %edx,(%eax)
  801de9:	0f 94 c0             	sete   %al
  801dec:	0f b6 c0             	movzbl %al,%eax
}
  801def:	c9                   	leave  
  801df0:	c3                   	ret    

00801df1 <opencons>:

int
opencons(void)
{
  801df1:	55                   	push   %ebp
  801df2:	89 e5                	mov    %esp,%ebp
  801df4:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801df7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dfa:	50                   	push   %eax
  801dfb:	e8 88 f3 ff ff       	call   801188 <fd_alloc>
  801e00:	83 c4 10             	add    $0x10,%esp
		return r;
  801e03:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e05:	85 c0                	test   %eax,%eax
  801e07:	78 3e                	js     801e47 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e09:	83 ec 04             	sub    $0x4,%esp
  801e0c:	68 07 04 00 00       	push   $0x407
  801e11:	ff 75 f4             	pushl  -0xc(%ebp)
  801e14:	6a 00                	push   $0x0
  801e16:	e8 94 ed ff ff       	call   800baf <sys_page_alloc>
  801e1b:	83 c4 10             	add    $0x10,%esp
		return r;
  801e1e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e20:	85 c0                	test   %eax,%eax
  801e22:	78 23                	js     801e47 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e24:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e2d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e32:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e39:	83 ec 0c             	sub    $0xc,%esp
  801e3c:	50                   	push   %eax
  801e3d:	e8 1f f3 ff ff       	call   801161 <fd2num>
  801e42:	89 c2                	mov    %eax,%edx
  801e44:	83 c4 10             	add    $0x10,%esp
}
  801e47:	89 d0                	mov    %edx,%eax
  801e49:	c9                   	leave  
  801e4a:	c3                   	ret    

00801e4b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e4b:	55                   	push   %ebp
  801e4c:	89 e5                	mov    %esp,%ebp
  801e4e:	56                   	push   %esi
  801e4f:	53                   	push   %ebx
  801e50:	8b 75 08             	mov    0x8(%ebp),%esi
  801e53:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e56:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e59:	85 c0                	test   %eax,%eax
  801e5b:	75 12                	jne    801e6f <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e5d:	83 ec 0c             	sub    $0xc,%esp
  801e60:	68 00 00 c0 ee       	push   $0xeec00000
  801e65:	e8 f5 ee ff ff       	call   800d5f <sys_ipc_recv>
  801e6a:	83 c4 10             	add    $0x10,%esp
  801e6d:	eb 0c                	jmp    801e7b <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e6f:	83 ec 0c             	sub    $0xc,%esp
  801e72:	50                   	push   %eax
  801e73:	e8 e7 ee ff ff       	call   800d5f <sys_ipc_recv>
  801e78:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e7b:	85 f6                	test   %esi,%esi
  801e7d:	0f 95 c1             	setne  %cl
  801e80:	85 db                	test   %ebx,%ebx
  801e82:	0f 95 c2             	setne  %dl
  801e85:	84 d1                	test   %dl,%cl
  801e87:	74 09                	je     801e92 <ipc_recv+0x47>
  801e89:	89 c2                	mov    %eax,%edx
  801e8b:	c1 ea 1f             	shr    $0x1f,%edx
  801e8e:	84 d2                	test   %dl,%dl
  801e90:	75 2a                	jne    801ebc <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e92:	85 f6                	test   %esi,%esi
  801e94:	74 0d                	je     801ea3 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e96:	a1 04 40 80 00       	mov    0x804004,%eax
  801e9b:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801ea1:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801ea3:	85 db                	test   %ebx,%ebx
  801ea5:	74 0d                	je     801eb4 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801ea7:	a1 04 40 80 00       	mov    0x804004,%eax
  801eac:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  801eb2:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801eb4:	a1 04 40 80 00       	mov    0x804004,%eax
  801eb9:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  801ebc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ebf:	5b                   	pop    %ebx
  801ec0:	5e                   	pop    %esi
  801ec1:	5d                   	pop    %ebp
  801ec2:	c3                   	ret    

00801ec3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ec3:	55                   	push   %ebp
  801ec4:	89 e5                	mov    %esp,%ebp
  801ec6:	57                   	push   %edi
  801ec7:	56                   	push   %esi
  801ec8:	53                   	push   %ebx
  801ec9:	83 ec 0c             	sub    $0xc,%esp
  801ecc:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ecf:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ed2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801ed5:	85 db                	test   %ebx,%ebx
  801ed7:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801edc:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801edf:	ff 75 14             	pushl  0x14(%ebp)
  801ee2:	53                   	push   %ebx
  801ee3:	56                   	push   %esi
  801ee4:	57                   	push   %edi
  801ee5:	e8 52 ee ff ff       	call   800d3c <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801eea:	89 c2                	mov    %eax,%edx
  801eec:	c1 ea 1f             	shr    $0x1f,%edx
  801eef:	83 c4 10             	add    $0x10,%esp
  801ef2:	84 d2                	test   %dl,%dl
  801ef4:	74 17                	je     801f0d <ipc_send+0x4a>
  801ef6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ef9:	74 12                	je     801f0d <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801efb:	50                   	push   %eax
  801efc:	68 86 27 80 00       	push   $0x802786
  801f01:	6a 47                	push   $0x47
  801f03:	68 94 27 80 00       	push   $0x802794
  801f08:	e8 41 e2 ff ff       	call   80014e <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801f0d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f10:	75 07                	jne    801f19 <ipc_send+0x56>
			sys_yield();
  801f12:	e8 79 ec ff ff       	call   800b90 <sys_yield>
  801f17:	eb c6                	jmp    801edf <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801f19:	85 c0                	test   %eax,%eax
  801f1b:	75 c2                	jne    801edf <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801f1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f20:	5b                   	pop    %ebx
  801f21:	5e                   	pop    %esi
  801f22:	5f                   	pop    %edi
  801f23:	5d                   	pop    %ebp
  801f24:	c3                   	ret    

00801f25 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f25:	55                   	push   %ebp
  801f26:	89 e5                	mov    %esp,%ebp
  801f28:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f2b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f30:	89 c2                	mov    %eax,%edx
  801f32:	c1 e2 07             	shl    $0x7,%edx
  801f35:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  801f3c:	8b 52 5c             	mov    0x5c(%edx),%edx
  801f3f:	39 ca                	cmp    %ecx,%edx
  801f41:	75 11                	jne    801f54 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801f43:	89 c2                	mov    %eax,%edx
  801f45:	c1 e2 07             	shl    $0x7,%edx
  801f48:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801f4f:	8b 40 54             	mov    0x54(%eax),%eax
  801f52:	eb 0f                	jmp    801f63 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f54:	83 c0 01             	add    $0x1,%eax
  801f57:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f5c:	75 d2                	jne    801f30 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f63:	5d                   	pop    %ebp
  801f64:	c3                   	ret    

00801f65 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f65:	55                   	push   %ebp
  801f66:	89 e5                	mov    %esp,%ebp
  801f68:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f6b:	89 d0                	mov    %edx,%eax
  801f6d:	c1 e8 16             	shr    $0x16,%eax
  801f70:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f77:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f7c:	f6 c1 01             	test   $0x1,%cl
  801f7f:	74 1d                	je     801f9e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f81:	c1 ea 0c             	shr    $0xc,%edx
  801f84:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f8b:	f6 c2 01             	test   $0x1,%dl
  801f8e:	74 0e                	je     801f9e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f90:	c1 ea 0c             	shr    $0xc,%edx
  801f93:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f9a:	ef 
  801f9b:	0f b7 c0             	movzwl %ax,%eax
}
  801f9e:	5d                   	pop    %ebp
  801f9f:	c3                   	ret    

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
