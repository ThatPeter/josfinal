
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
  800040:	68 20 22 80 00       	push   $0x802220
  800045:	e8 c8 01 00 00       	call   800212 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 3c 0b 00 00       	call   800b9a <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 40 22 80 00       	push   $0x802240
  80006f:	6a 0f                	push   $0xf
  800071:	68 2a 22 80 00       	push   $0x80222a
  800076:	e8 be 00 00 00       	call   800139 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 6c 22 80 00       	push   $0x80226c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 bb 06 00 00       	call   800744 <snprintf>
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
  80009c:	e8 2a 0d 00 00       	call   800dcb <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 2e 0a 00 00       	call   800ade <sys_cputs>
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
  8000c0:	e8 97 0a 00 00       	call   800b5c <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	89 c2                	mov    %eax,%edx
  8000cc:	c1 e2 07             	shl    $0x7,%edx
  8000cf:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8000d6:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000db:	85 db                	test   %ebx,%ebx
  8000dd:	7e 07                	jle    8000e6 <libmain+0x31>
		binaryname = argv[0];
  8000df:	8b 06                	mov    (%esi),%eax
  8000e1:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e6:	83 ec 08             	sub    $0x8,%esp
  8000e9:	56                   	push   %esi
  8000ea:	53                   	push   %ebx
  8000eb:	e8 a1 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  8000f0:	e8 2a 00 00 00       	call   80011f <exit>
}
  8000f5:	83 c4 10             	add    $0x10,%esp
  8000f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000fb:	5b                   	pop    %ebx
  8000fc:	5e                   	pop    %esi
  8000fd:	5d                   	pop    %ebp
  8000fe:	c3                   	ret    

008000ff <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  8000ff:	55                   	push   %ebp
  800100:	89 e5                	mov    %esp,%ebp
  800102:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  800105:	a1 0c 40 80 00       	mov    0x80400c,%eax
	func();
  80010a:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  80010c:	e8 4b 0a 00 00       	call   800b5c <sys_getenvid>
  800111:	83 ec 0c             	sub    $0xc,%esp
  800114:	50                   	push   %eax
  800115:	e8 91 0c 00 00       	call   800dab <sys_thread_free>
}
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	c9                   	leave  
  80011e:	c3                   	ret    

0080011f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80011f:	55                   	push   %ebp
  800120:	89 e5                	mov    %esp,%ebp
  800122:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800125:	e8 ed 11 00 00       	call   801317 <close_all>
	sys_env_destroy(0);
  80012a:	83 ec 0c             	sub    $0xc,%esp
  80012d:	6a 00                	push   $0x0
  80012f:	e8 e7 09 00 00       	call   800b1b <sys_env_destroy>
}
  800134:	83 c4 10             	add    $0x10,%esp
  800137:	c9                   	leave  
  800138:	c3                   	ret    

00800139 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	56                   	push   %esi
  80013d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80013e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800141:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800147:	e8 10 0a 00 00       	call   800b5c <sys_getenvid>
  80014c:	83 ec 0c             	sub    $0xc,%esp
  80014f:	ff 75 0c             	pushl  0xc(%ebp)
  800152:	ff 75 08             	pushl  0x8(%ebp)
  800155:	56                   	push   %esi
  800156:	50                   	push   %eax
  800157:	68 98 22 80 00       	push   $0x802298
  80015c:	e8 b1 00 00 00       	call   800212 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800161:	83 c4 18             	add    $0x18,%esp
  800164:	53                   	push   %ebx
  800165:	ff 75 10             	pushl  0x10(%ebp)
  800168:	e8 54 00 00 00       	call   8001c1 <vcprintf>
	cprintf("\n");
  80016d:	c7 04 24 53 27 80 00 	movl   $0x802753,(%esp)
  800174:	e8 99 00 00 00       	call   800212 <cprintf>
  800179:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80017c:	cc                   	int3   
  80017d:	eb fd                	jmp    80017c <_panic+0x43>

0080017f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	53                   	push   %ebx
  800183:	83 ec 04             	sub    $0x4,%esp
  800186:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800189:	8b 13                	mov    (%ebx),%edx
  80018b:	8d 42 01             	lea    0x1(%edx),%eax
  80018e:	89 03                	mov    %eax,(%ebx)
  800190:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800193:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800197:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019c:	75 1a                	jne    8001b8 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80019e:	83 ec 08             	sub    $0x8,%esp
  8001a1:	68 ff 00 00 00       	push   $0xff
  8001a6:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a9:	50                   	push   %eax
  8001aa:	e8 2f 09 00 00       	call   800ade <sys_cputs>
		b->idx = 0;
  8001af:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b5:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001b8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001bf:	c9                   	leave  
  8001c0:	c3                   	ret    

008001c1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c1:	55                   	push   %ebp
  8001c2:	89 e5                	mov    %esp,%ebp
  8001c4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ca:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d1:	00 00 00 
	b.cnt = 0;
  8001d4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001db:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001de:	ff 75 0c             	pushl  0xc(%ebp)
  8001e1:	ff 75 08             	pushl  0x8(%ebp)
  8001e4:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ea:	50                   	push   %eax
  8001eb:	68 7f 01 80 00       	push   $0x80017f
  8001f0:	e8 54 01 00 00       	call   800349 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f5:	83 c4 08             	add    $0x8,%esp
  8001f8:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001fe:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800204:	50                   	push   %eax
  800205:	e8 d4 08 00 00       	call   800ade <sys_cputs>

	return b.cnt;
}
  80020a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800210:	c9                   	leave  
  800211:	c3                   	ret    

00800212 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800218:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80021b:	50                   	push   %eax
  80021c:	ff 75 08             	pushl  0x8(%ebp)
  80021f:	e8 9d ff ff ff       	call   8001c1 <vcprintf>
	va_end(ap);

	return cnt;
}
  800224:	c9                   	leave  
  800225:	c3                   	ret    

00800226 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	57                   	push   %edi
  80022a:	56                   	push   %esi
  80022b:	53                   	push   %ebx
  80022c:	83 ec 1c             	sub    $0x1c,%esp
  80022f:	89 c7                	mov    %eax,%edi
  800231:	89 d6                	mov    %edx,%esi
  800233:	8b 45 08             	mov    0x8(%ebp),%eax
  800236:	8b 55 0c             	mov    0xc(%ebp),%edx
  800239:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80023f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800242:	bb 00 00 00 00       	mov    $0x0,%ebx
  800247:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80024a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80024d:	39 d3                	cmp    %edx,%ebx
  80024f:	72 05                	jb     800256 <printnum+0x30>
  800251:	39 45 10             	cmp    %eax,0x10(%ebp)
  800254:	77 45                	ja     80029b <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800256:	83 ec 0c             	sub    $0xc,%esp
  800259:	ff 75 18             	pushl  0x18(%ebp)
  80025c:	8b 45 14             	mov    0x14(%ebp),%eax
  80025f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800262:	53                   	push   %ebx
  800263:	ff 75 10             	pushl  0x10(%ebp)
  800266:	83 ec 08             	sub    $0x8,%esp
  800269:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026c:	ff 75 e0             	pushl  -0x20(%ebp)
  80026f:	ff 75 dc             	pushl  -0x24(%ebp)
  800272:	ff 75 d8             	pushl  -0x28(%ebp)
  800275:	e8 16 1d 00 00       	call   801f90 <__udivdi3>
  80027a:	83 c4 18             	add    $0x18,%esp
  80027d:	52                   	push   %edx
  80027e:	50                   	push   %eax
  80027f:	89 f2                	mov    %esi,%edx
  800281:	89 f8                	mov    %edi,%eax
  800283:	e8 9e ff ff ff       	call   800226 <printnum>
  800288:	83 c4 20             	add    $0x20,%esp
  80028b:	eb 18                	jmp    8002a5 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80028d:	83 ec 08             	sub    $0x8,%esp
  800290:	56                   	push   %esi
  800291:	ff 75 18             	pushl  0x18(%ebp)
  800294:	ff d7                	call   *%edi
  800296:	83 c4 10             	add    $0x10,%esp
  800299:	eb 03                	jmp    80029e <printnum+0x78>
  80029b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80029e:	83 eb 01             	sub    $0x1,%ebx
  8002a1:	85 db                	test   %ebx,%ebx
  8002a3:	7f e8                	jg     80028d <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a5:	83 ec 08             	sub    $0x8,%esp
  8002a8:	56                   	push   %esi
  8002a9:	83 ec 04             	sub    $0x4,%esp
  8002ac:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002af:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b2:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b5:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b8:	e8 03 1e 00 00       	call   8020c0 <__umoddi3>
  8002bd:	83 c4 14             	add    $0x14,%esp
  8002c0:	0f be 80 bb 22 80 00 	movsbl 0x8022bb(%eax),%eax
  8002c7:	50                   	push   %eax
  8002c8:	ff d7                	call   *%edi
}
  8002ca:	83 c4 10             	add    $0x10,%esp
  8002cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d0:	5b                   	pop    %ebx
  8002d1:	5e                   	pop    %esi
  8002d2:	5f                   	pop    %edi
  8002d3:	5d                   	pop    %ebp
  8002d4:	c3                   	ret    

008002d5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d8:	83 fa 01             	cmp    $0x1,%edx
  8002db:	7e 0e                	jle    8002eb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002dd:	8b 10                	mov    (%eax),%edx
  8002df:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e2:	89 08                	mov    %ecx,(%eax)
  8002e4:	8b 02                	mov    (%edx),%eax
  8002e6:	8b 52 04             	mov    0x4(%edx),%edx
  8002e9:	eb 22                	jmp    80030d <getuint+0x38>
	else if (lflag)
  8002eb:	85 d2                	test   %edx,%edx
  8002ed:	74 10                	je     8002ff <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ef:	8b 10                	mov    (%eax),%edx
  8002f1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f4:	89 08                	mov    %ecx,(%eax)
  8002f6:	8b 02                	mov    (%edx),%eax
  8002f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fd:	eb 0e                	jmp    80030d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002ff:	8b 10                	mov    (%eax),%edx
  800301:	8d 4a 04             	lea    0x4(%edx),%ecx
  800304:	89 08                	mov    %ecx,(%eax)
  800306:	8b 02                	mov    (%edx),%eax
  800308:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80030d:	5d                   	pop    %ebp
  80030e:	c3                   	ret    

0080030f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800315:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800319:	8b 10                	mov    (%eax),%edx
  80031b:	3b 50 04             	cmp    0x4(%eax),%edx
  80031e:	73 0a                	jae    80032a <sprintputch+0x1b>
		*b->buf++ = ch;
  800320:	8d 4a 01             	lea    0x1(%edx),%ecx
  800323:	89 08                	mov    %ecx,(%eax)
  800325:	8b 45 08             	mov    0x8(%ebp),%eax
  800328:	88 02                	mov    %al,(%edx)
}
  80032a:	5d                   	pop    %ebp
  80032b:	c3                   	ret    

0080032c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80032c:	55                   	push   %ebp
  80032d:	89 e5                	mov    %esp,%ebp
  80032f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800332:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800335:	50                   	push   %eax
  800336:	ff 75 10             	pushl  0x10(%ebp)
  800339:	ff 75 0c             	pushl  0xc(%ebp)
  80033c:	ff 75 08             	pushl  0x8(%ebp)
  80033f:	e8 05 00 00 00       	call   800349 <vprintfmt>
	va_end(ap);
}
  800344:	83 c4 10             	add    $0x10,%esp
  800347:	c9                   	leave  
  800348:	c3                   	ret    

00800349 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800349:	55                   	push   %ebp
  80034a:	89 e5                	mov    %esp,%ebp
  80034c:	57                   	push   %edi
  80034d:	56                   	push   %esi
  80034e:	53                   	push   %ebx
  80034f:	83 ec 2c             	sub    $0x2c,%esp
  800352:	8b 75 08             	mov    0x8(%ebp),%esi
  800355:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800358:	8b 7d 10             	mov    0x10(%ebp),%edi
  80035b:	eb 12                	jmp    80036f <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80035d:	85 c0                	test   %eax,%eax
  80035f:	0f 84 89 03 00 00    	je     8006ee <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800365:	83 ec 08             	sub    $0x8,%esp
  800368:	53                   	push   %ebx
  800369:	50                   	push   %eax
  80036a:	ff d6                	call   *%esi
  80036c:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80036f:	83 c7 01             	add    $0x1,%edi
  800372:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800376:	83 f8 25             	cmp    $0x25,%eax
  800379:	75 e2                	jne    80035d <vprintfmt+0x14>
  80037b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80037f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800386:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80038d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800394:	ba 00 00 00 00       	mov    $0x0,%edx
  800399:	eb 07                	jmp    8003a2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039b:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80039e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a2:	8d 47 01             	lea    0x1(%edi),%eax
  8003a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003a8:	0f b6 07             	movzbl (%edi),%eax
  8003ab:	0f b6 c8             	movzbl %al,%ecx
  8003ae:	83 e8 23             	sub    $0x23,%eax
  8003b1:	3c 55                	cmp    $0x55,%al
  8003b3:	0f 87 1a 03 00 00    	ja     8006d3 <vprintfmt+0x38a>
  8003b9:	0f b6 c0             	movzbl %al,%eax
  8003bc:	ff 24 85 00 24 80 00 	jmp    *0x802400(,%eax,4)
  8003c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c6:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003ca:	eb d6                	jmp    8003a2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003d7:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003da:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003de:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003e1:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003e4:	83 fa 09             	cmp    $0x9,%edx
  8003e7:	77 39                	ja     800422 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003e9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ec:	eb e9                	jmp    8003d7 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f1:	8d 48 04             	lea    0x4(%eax),%ecx
  8003f4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003f7:	8b 00                	mov    (%eax),%eax
  8003f9:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003ff:	eb 27                	jmp    800428 <vprintfmt+0xdf>
  800401:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800404:	85 c0                	test   %eax,%eax
  800406:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040b:	0f 49 c8             	cmovns %eax,%ecx
  80040e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800411:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800414:	eb 8c                	jmp    8003a2 <vprintfmt+0x59>
  800416:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800419:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800420:	eb 80                	jmp    8003a2 <vprintfmt+0x59>
  800422:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800425:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800428:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042c:	0f 89 70 ff ff ff    	jns    8003a2 <vprintfmt+0x59>
				width = precision, precision = -1;
  800432:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800435:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800438:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80043f:	e9 5e ff ff ff       	jmp    8003a2 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800444:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800447:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80044a:	e9 53 ff ff ff       	jmp    8003a2 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80044f:	8b 45 14             	mov    0x14(%ebp),%eax
  800452:	8d 50 04             	lea    0x4(%eax),%edx
  800455:	89 55 14             	mov    %edx,0x14(%ebp)
  800458:	83 ec 08             	sub    $0x8,%esp
  80045b:	53                   	push   %ebx
  80045c:	ff 30                	pushl  (%eax)
  80045e:	ff d6                	call   *%esi
			break;
  800460:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800463:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800466:	e9 04 ff ff ff       	jmp    80036f <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046b:	8b 45 14             	mov    0x14(%ebp),%eax
  80046e:	8d 50 04             	lea    0x4(%eax),%edx
  800471:	89 55 14             	mov    %edx,0x14(%ebp)
  800474:	8b 00                	mov    (%eax),%eax
  800476:	99                   	cltd   
  800477:	31 d0                	xor    %edx,%eax
  800479:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80047b:	83 f8 0f             	cmp    $0xf,%eax
  80047e:	7f 0b                	jg     80048b <vprintfmt+0x142>
  800480:	8b 14 85 60 25 80 00 	mov    0x802560(,%eax,4),%edx
  800487:	85 d2                	test   %edx,%edx
  800489:	75 18                	jne    8004a3 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80048b:	50                   	push   %eax
  80048c:	68 d3 22 80 00       	push   $0x8022d3
  800491:	53                   	push   %ebx
  800492:	56                   	push   %esi
  800493:	e8 94 fe ff ff       	call   80032c <printfmt>
  800498:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80049e:	e9 cc fe ff ff       	jmp    80036f <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004a3:	52                   	push   %edx
  8004a4:	68 21 27 80 00       	push   $0x802721
  8004a9:	53                   	push   %ebx
  8004aa:	56                   	push   %esi
  8004ab:	e8 7c fe ff ff       	call   80032c <printfmt>
  8004b0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b6:	e9 b4 fe ff ff       	jmp    80036f <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004be:	8d 50 04             	lea    0x4(%eax),%edx
  8004c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c4:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004c6:	85 ff                	test   %edi,%edi
  8004c8:	b8 cc 22 80 00       	mov    $0x8022cc,%eax
  8004cd:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004d0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d4:	0f 8e 94 00 00 00    	jle    80056e <vprintfmt+0x225>
  8004da:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004de:	0f 84 98 00 00 00    	je     80057c <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e4:	83 ec 08             	sub    $0x8,%esp
  8004e7:	ff 75 d0             	pushl  -0x30(%ebp)
  8004ea:	57                   	push   %edi
  8004eb:	e8 86 02 00 00       	call   800776 <strnlen>
  8004f0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004f3:	29 c1                	sub    %eax,%ecx
  8004f5:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004f8:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004fb:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004ff:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800502:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800505:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800507:	eb 0f                	jmp    800518 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800509:	83 ec 08             	sub    $0x8,%esp
  80050c:	53                   	push   %ebx
  80050d:	ff 75 e0             	pushl  -0x20(%ebp)
  800510:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800512:	83 ef 01             	sub    $0x1,%edi
  800515:	83 c4 10             	add    $0x10,%esp
  800518:	85 ff                	test   %edi,%edi
  80051a:	7f ed                	jg     800509 <vprintfmt+0x1c0>
  80051c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80051f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800522:	85 c9                	test   %ecx,%ecx
  800524:	b8 00 00 00 00       	mov    $0x0,%eax
  800529:	0f 49 c1             	cmovns %ecx,%eax
  80052c:	29 c1                	sub    %eax,%ecx
  80052e:	89 75 08             	mov    %esi,0x8(%ebp)
  800531:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800534:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800537:	89 cb                	mov    %ecx,%ebx
  800539:	eb 4d                	jmp    800588 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80053b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80053f:	74 1b                	je     80055c <vprintfmt+0x213>
  800541:	0f be c0             	movsbl %al,%eax
  800544:	83 e8 20             	sub    $0x20,%eax
  800547:	83 f8 5e             	cmp    $0x5e,%eax
  80054a:	76 10                	jbe    80055c <vprintfmt+0x213>
					putch('?', putdat);
  80054c:	83 ec 08             	sub    $0x8,%esp
  80054f:	ff 75 0c             	pushl  0xc(%ebp)
  800552:	6a 3f                	push   $0x3f
  800554:	ff 55 08             	call   *0x8(%ebp)
  800557:	83 c4 10             	add    $0x10,%esp
  80055a:	eb 0d                	jmp    800569 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80055c:	83 ec 08             	sub    $0x8,%esp
  80055f:	ff 75 0c             	pushl  0xc(%ebp)
  800562:	52                   	push   %edx
  800563:	ff 55 08             	call   *0x8(%ebp)
  800566:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800569:	83 eb 01             	sub    $0x1,%ebx
  80056c:	eb 1a                	jmp    800588 <vprintfmt+0x23f>
  80056e:	89 75 08             	mov    %esi,0x8(%ebp)
  800571:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800574:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800577:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80057a:	eb 0c                	jmp    800588 <vprintfmt+0x23f>
  80057c:	89 75 08             	mov    %esi,0x8(%ebp)
  80057f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800582:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800585:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800588:	83 c7 01             	add    $0x1,%edi
  80058b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80058f:	0f be d0             	movsbl %al,%edx
  800592:	85 d2                	test   %edx,%edx
  800594:	74 23                	je     8005b9 <vprintfmt+0x270>
  800596:	85 f6                	test   %esi,%esi
  800598:	78 a1                	js     80053b <vprintfmt+0x1f2>
  80059a:	83 ee 01             	sub    $0x1,%esi
  80059d:	79 9c                	jns    80053b <vprintfmt+0x1f2>
  80059f:	89 df                	mov    %ebx,%edi
  8005a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a7:	eb 18                	jmp    8005c1 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005a9:	83 ec 08             	sub    $0x8,%esp
  8005ac:	53                   	push   %ebx
  8005ad:	6a 20                	push   $0x20
  8005af:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b1:	83 ef 01             	sub    $0x1,%edi
  8005b4:	83 c4 10             	add    $0x10,%esp
  8005b7:	eb 08                	jmp    8005c1 <vprintfmt+0x278>
  8005b9:	89 df                	mov    %ebx,%edi
  8005bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8005be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c1:	85 ff                	test   %edi,%edi
  8005c3:	7f e4                	jg     8005a9 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c8:	e9 a2 fd ff ff       	jmp    80036f <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005cd:	83 fa 01             	cmp    $0x1,%edx
  8005d0:	7e 16                	jle    8005e8 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8d 50 08             	lea    0x8(%eax),%edx
  8005d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005db:	8b 50 04             	mov    0x4(%eax),%edx
  8005de:	8b 00                	mov    (%eax),%eax
  8005e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e6:	eb 32                	jmp    80061a <vprintfmt+0x2d1>
	else if (lflag)
  8005e8:	85 d2                	test   %edx,%edx
  8005ea:	74 18                	je     800604 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ef:	8d 50 04             	lea    0x4(%eax),%edx
  8005f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f5:	8b 00                	mov    (%eax),%eax
  8005f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fa:	89 c1                	mov    %eax,%ecx
  8005fc:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ff:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800602:	eb 16                	jmp    80061a <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8d 50 04             	lea    0x4(%eax),%edx
  80060a:	89 55 14             	mov    %edx,0x14(%ebp)
  80060d:	8b 00                	mov    (%eax),%eax
  80060f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800612:	89 c1                	mov    %eax,%ecx
  800614:	c1 f9 1f             	sar    $0x1f,%ecx
  800617:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80061a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80061d:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800620:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800625:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800629:	79 74                	jns    80069f <vprintfmt+0x356>
				putch('-', putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	53                   	push   %ebx
  80062f:	6a 2d                	push   $0x2d
  800631:	ff d6                	call   *%esi
				num = -(long long) num;
  800633:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800636:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800639:	f7 d8                	neg    %eax
  80063b:	83 d2 00             	adc    $0x0,%edx
  80063e:	f7 da                	neg    %edx
  800640:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800643:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800648:	eb 55                	jmp    80069f <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80064a:	8d 45 14             	lea    0x14(%ebp),%eax
  80064d:	e8 83 fc ff ff       	call   8002d5 <getuint>
			base = 10;
  800652:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800657:	eb 46                	jmp    80069f <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800659:	8d 45 14             	lea    0x14(%ebp),%eax
  80065c:	e8 74 fc ff ff       	call   8002d5 <getuint>
			base = 8;
  800661:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800666:	eb 37                	jmp    80069f <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	53                   	push   %ebx
  80066c:	6a 30                	push   $0x30
  80066e:	ff d6                	call   *%esi
			putch('x', putdat);
  800670:	83 c4 08             	add    $0x8,%esp
  800673:	53                   	push   %ebx
  800674:	6a 78                	push   $0x78
  800676:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800678:	8b 45 14             	mov    0x14(%ebp),%eax
  80067b:	8d 50 04             	lea    0x4(%eax),%edx
  80067e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800681:	8b 00                	mov    (%eax),%eax
  800683:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800688:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80068b:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800690:	eb 0d                	jmp    80069f <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800692:	8d 45 14             	lea    0x14(%ebp),%eax
  800695:	e8 3b fc ff ff       	call   8002d5 <getuint>
			base = 16;
  80069a:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80069f:	83 ec 0c             	sub    $0xc,%esp
  8006a2:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006a6:	57                   	push   %edi
  8006a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8006aa:	51                   	push   %ecx
  8006ab:	52                   	push   %edx
  8006ac:	50                   	push   %eax
  8006ad:	89 da                	mov    %ebx,%edx
  8006af:	89 f0                	mov    %esi,%eax
  8006b1:	e8 70 fb ff ff       	call   800226 <printnum>
			break;
  8006b6:	83 c4 20             	add    $0x20,%esp
  8006b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006bc:	e9 ae fc ff ff       	jmp    80036f <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c1:	83 ec 08             	sub    $0x8,%esp
  8006c4:	53                   	push   %ebx
  8006c5:	51                   	push   %ecx
  8006c6:	ff d6                	call   *%esi
			break;
  8006c8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ce:	e9 9c fc ff ff       	jmp    80036f <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d3:	83 ec 08             	sub    $0x8,%esp
  8006d6:	53                   	push   %ebx
  8006d7:	6a 25                	push   $0x25
  8006d9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006db:	83 c4 10             	add    $0x10,%esp
  8006de:	eb 03                	jmp    8006e3 <vprintfmt+0x39a>
  8006e0:	83 ef 01             	sub    $0x1,%edi
  8006e3:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006e7:	75 f7                	jne    8006e0 <vprintfmt+0x397>
  8006e9:	e9 81 fc ff ff       	jmp    80036f <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f1:	5b                   	pop    %ebx
  8006f2:	5e                   	pop    %esi
  8006f3:	5f                   	pop    %edi
  8006f4:	5d                   	pop    %ebp
  8006f5:	c3                   	ret    

008006f6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f6:	55                   	push   %ebp
  8006f7:	89 e5                	mov    %esp,%ebp
  8006f9:	83 ec 18             	sub    $0x18,%esp
  8006fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ff:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800702:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800705:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800709:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80070c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800713:	85 c0                	test   %eax,%eax
  800715:	74 26                	je     80073d <vsnprintf+0x47>
  800717:	85 d2                	test   %edx,%edx
  800719:	7e 22                	jle    80073d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80071b:	ff 75 14             	pushl  0x14(%ebp)
  80071e:	ff 75 10             	pushl  0x10(%ebp)
  800721:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800724:	50                   	push   %eax
  800725:	68 0f 03 80 00       	push   $0x80030f
  80072a:	e8 1a fc ff ff       	call   800349 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80072f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800732:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800735:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	eb 05                	jmp    800742 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80073d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800742:	c9                   	leave  
  800743:	c3                   	ret    

00800744 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80074a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80074d:	50                   	push   %eax
  80074e:	ff 75 10             	pushl  0x10(%ebp)
  800751:	ff 75 0c             	pushl  0xc(%ebp)
  800754:	ff 75 08             	pushl  0x8(%ebp)
  800757:	e8 9a ff ff ff       	call   8006f6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80075c:	c9                   	leave  
  80075d:	c3                   	ret    

0080075e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800764:	b8 00 00 00 00       	mov    $0x0,%eax
  800769:	eb 03                	jmp    80076e <strlen+0x10>
		n++;
  80076b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80076e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800772:	75 f7                	jne    80076b <strlen+0xd>
		n++;
	return n;
}
  800774:	5d                   	pop    %ebp
  800775:	c3                   	ret    

00800776 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077f:	ba 00 00 00 00       	mov    $0x0,%edx
  800784:	eb 03                	jmp    800789 <strnlen+0x13>
		n++;
  800786:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800789:	39 c2                	cmp    %eax,%edx
  80078b:	74 08                	je     800795 <strnlen+0x1f>
  80078d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800791:	75 f3                	jne    800786 <strnlen+0x10>
  800793:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	53                   	push   %ebx
  80079b:	8b 45 08             	mov    0x8(%ebp),%eax
  80079e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a1:	89 c2                	mov    %eax,%edx
  8007a3:	83 c2 01             	add    $0x1,%edx
  8007a6:	83 c1 01             	add    $0x1,%ecx
  8007a9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ad:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007b0:	84 db                	test   %bl,%bl
  8007b2:	75 ef                	jne    8007a3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b4:	5b                   	pop    %ebx
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    

008007b7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	53                   	push   %ebx
  8007bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007be:	53                   	push   %ebx
  8007bf:	e8 9a ff ff ff       	call   80075e <strlen>
  8007c4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c7:	ff 75 0c             	pushl  0xc(%ebp)
  8007ca:	01 d8                	add    %ebx,%eax
  8007cc:	50                   	push   %eax
  8007cd:	e8 c5 ff ff ff       	call   800797 <strcpy>
	return dst;
}
  8007d2:	89 d8                	mov    %ebx,%eax
  8007d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d7:	c9                   	leave  
  8007d8:	c3                   	ret    

008007d9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	56                   	push   %esi
  8007dd:	53                   	push   %ebx
  8007de:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e4:	89 f3                	mov    %esi,%ebx
  8007e6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e9:	89 f2                	mov    %esi,%edx
  8007eb:	eb 0f                	jmp    8007fc <strncpy+0x23>
		*dst++ = *src;
  8007ed:	83 c2 01             	add    $0x1,%edx
  8007f0:	0f b6 01             	movzbl (%ecx),%eax
  8007f3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f6:	80 39 01             	cmpb   $0x1,(%ecx)
  8007f9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fc:	39 da                	cmp    %ebx,%edx
  8007fe:	75 ed                	jne    8007ed <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800800:	89 f0                	mov    %esi,%eax
  800802:	5b                   	pop    %ebx
  800803:	5e                   	pop    %esi
  800804:	5d                   	pop    %ebp
  800805:	c3                   	ret    

00800806 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	56                   	push   %esi
  80080a:	53                   	push   %ebx
  80080b:	8b 75 08             	mov    0x8(%ebp),%esi
  80080e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800811:	8b 55 10             	mov    0x10(%ebp),%edx
  800814:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800816:	85 d2                	test   %edx,%edx
  800818:	74 21                	je     80083b <strlcpy+0x35>
  80081a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80081e:	89 f2                	mov    %esi,%edx
  800820:	eb 09                	jmp    80082b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800822:	83 c2 01             	add    $0x1,%edx
  800825:	83 c1 01             	add    $0x1,%ecx
  800828:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80082b:	39 c2                	cmp    %eax,%edx
  80082d:	74 09                	je     800838 <strlcpy+0x32>
  80082f:	0f b6 19             	movzbl (%ecx),%ebx
  800832:	84 db                	test   %bl,%bl
  800834:	75 ec                	jne    800822 <strlcpy+0x1c>
  800836:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800838:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80083b:	29 f0                	sub    %esi,%eax
}
  80083d:	5b                   	pop    %ebx
  80083e:	5e                   	pop    %esi
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    

00800841 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800847:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80084a:	eb 06                	jmp    800852 <strcmp+0x11>
		p++, q++;
  80084c:	83 c1 01             	add    $0x1,%ecx
  80084f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800852:	0f b6 01             	movzbl (%ecx),%eax
  800855:	84 c0                	test   %al,%al
  800857:	74 04                	je     80085d <strcmp+0x1c>
  800859:	3a 02                	cmp    (%edx),%al
  80085b:	74 ef                	je     80084c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80085d:	0f b6 c0             	movzbl %al,%eax
  800860:	0f b6 12             	movzbl (%edx),%edx
  800863:	29 d0                	sub    %edx,%eax
}
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	53                   	push   %ebx
  80086b:	8b 45 08             	mov    0x8(%ebp),%eax
  80086e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800871:	89 c3                	mov    %eax,%ebx
  800873:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800876:	eb 06                	jmp    80087e <strncmp+0x17>
		n--, p++, q++;
  800878:	83 c0 01             	add    $0x1,%eax
  80087b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80087e:	39 d8                	cmp    %ebx,%eax
  800880:	74 15                	je     800897 <strncmp+0x30>
  800882:	0f b6 08             	movzbl (%eax),%ecx
  800885:	84 c9                	test   %cl,%cl
  800887:	74 04                	je     80088d <strncmp+0x26>
  800889:	3a 0a                	cmp    (%edx),%cl
  80088b:	74 eb                	je     800878 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088d:	0f b6 00             	movzbl (%eax),%eax
  800890:	0f b6 12             	movzbl (%edx),%edx
  800893:	29 d0                	sub    %edx,%eax
  800895:	eb 05                	jmp    80089c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800897:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80089c:	5b                   	pop    %ebx
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a9:	eb 07                	jmp    8008b2 <strchr+0x13>
		if (*s == c)
  8008ab:	38 ca                	cmp    %cl,%dl
  8008ad:	74 0f                	je     8008be <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008af:	83 c0 01             	add    $0x1,%eax
  8008b2:	0f b6 10             	movzbl (%eax),%edx
  8008b5:	84 d2                	test   %dl,%dl
  8008b7:	75 f2                	jne    8008ab <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ca:	eb 03                	jmp    8008cf <strfind+0xf>
  8008cc:	83 c0 01             	add    $0x1,%eax
  8008cf:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d2:	38 ca                	cmp    %cl,%dl
  8008d4:	74 04                	je     8008da <strfind+0x1a>
  8008d6:	84 d2                	test   %dl,%dl
  8008d8:	75 f2                	jne    8008cc <strfind+0xc>
			break;
	return (char *) s;
}
  8008da:	5d                   	pop    %ebp
  8008db:	c3                   	ret    

008008dc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	57                   	push   %edi
  8008e0:	56                   	push   %esi
  8008e1:	53                   	push   %ebx
  8008e2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e8:	85 c9                	test   %ecx,%ecx
  8008ea:	74 36                	je     800922 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ec:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f2:	75 28                	jne    80091c <memset+0x40>
  8008f4:	f6 c1 03             	test   $0x3,%cl
  8008f7:	75 23                	jne    80091c <memset+0x40>
		c &= 0xFF;
  8008f9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008fd:	89 d3                	mov    %edx,%ebx
  8008ff:	c1 e3 08             	shl    $0x8,%ebx
  800902:	89 d6                	mov    %edx,%esi
  800904:	c1 e6 18             	shl    $0x18,%esi
  800907:	89 d0                	mov    %edx,%eax
  800909:	c1 e0 10             	shl    $0x10,%eax
  80090c:	09 f0                	or     %esi,%eax
  80090e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800910:	89 d8                	mov    %ebx,%eax
  800912:	09 d0                	or     %edx,%eax
  800914:	c1 e9 02             	shr    $0x2,%ecx
  800917:	fc                   	cld    
  800918:	f3 ab                	rep stos %eax,%es:(%edi)
  80091a:	eb 06                	jmp    800922 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091f:	fc                   	cld    
  800920:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800922:	89 f8                	mov    %edi,%eax
  800924:	5b                   	pop    %ebx
  800925:	5e                   	pop    %esi
  800926:	5f                   	pop    %edi
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	57                   	push   %edi
  80092d:	56                   	push   %esi
  80092e:	8b 45 08             	mov    0x8(%ebp),%eax
  800931:	8b 75 0c             	mov    0xc(%ebp),%esi
  800934:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800937:	39 c6                	cmp    %eax,%esi
  800939:	73 35                	jae    800970 <memmove+0x47>
  80093b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80093e:	39 d0                	cmp    %edx,%eax
  800940:	73 2e                	jae    800970 <memmove+0x47>
		s += n;
		d += n;
  800942:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800945:	89 d6                	mov    %edx,%esi
  800947:	09 fe                	or     %edi,%esi
  800949:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80094f:	75 13                	jne    800964 <memmove+0x3b>
  800951:	f6 c1 03             	test   $0x3,%cl
  800954:	75 0e                	jne    800964 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800956:	83 ef 04             	sub    $0x4,%edi
  800959:	8d 72 fc             	lea    -0x4(%edx),%esi
  80095c:	c1 e9 02             	shr    $0x2,%ecx
  80095f:	fd                   	std    
  800960:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800962:	eb 09                	jmp    80096d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800964:	83 ef 01             	sub    $0x1,%edi
  800967:	8d 72 ff             	lea    -0x1(%edx),%esi
  80096a:	fd                   	std    
  80096b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096d:	fc                   	cld    
  80096e:	eb 1d                	jmp    80098d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800970:	89 f2                	mov    %esi,%edx
  800972:	09 c2                	or     %eax,%edx
  800974:	f6 c2 03             	test   $0x3,%dl
  800977:	75 0f                	jne    800988 <memmove+0x5f>
  800979:	f6 c1 03             	test   $0x3,%cl
  80097c:	75 0a                	jne    800988 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80097e:	c1 e9 02             	shr    $0x2,%ecx
  800981:	89 c7                	mov    %eax,%edi
  800983:	fc                   	cld    
  800984:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800986:	eb 05                	jmp    80098d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800988:	89 c7                	mov    %eax,%edi
  80098a:	fc                   	cld    
  80098b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098d:	5e                   	pop    %esi
  80098e:	5f                   	pop    %edi
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800994:	ff 75 10             	pushl  0x10(%ebp)
  800997:	ff 75 0c             	pushl  0xc(%ebp)
  80099a:	ff 75 08             	pushl  0x8(%ebp)
  80099d:	e8 87 ff ff ff       	call   800929 <memmove>
}
  8009a2:	c9                   	leave  
  8009a3:	c3                   	ret    

008009a4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	56                   	push   %esi
  8009a8:	53                   	push   %ebx
  8009a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009af:	89 c6                	mov    %eax,%esi
  8009b1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b4:	eb 1a                	jmp    8009d0 <memcmp+0x2c>
		if (*s1 != *s2)
  8009b6:	0f b6 08             	movzbl (%eax),%ecx
  8009b9:	0f b6 1a             	movzbl (%edx),%ebx
  8009bc:	38 d9                	cmp    %bl,%cl
  8009be:	74 0a                	je     8009ca <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009c0:	0f b6 c1             	movzbl %cl,%eax
  8009c3:	0f b6 db             	movzbl %bl,%ebx
  8009c6:	29 d8                	sub    %ebx,%eax
  8009c8:	eb 0f                	jmp    8009d9 <memcmp+0x35>
		s1++, s2++;
  8009ca:	83 c0 01             	add    $0x1,%eax
  8009cd:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d0:	39 f0                	cmp    %esi,%eax
  8009d2:	75 e2                	jne    8009b6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d9:	5b                   	pop    %ebx
  8009da:	5e                   	pop    %esi
  8009db:	5d                   	pop    %ebp
  8009dc:	c3                   	ret    

008009dd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	53                   	push   %ebx
  8009e1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009e4:	89 c1                	mov    %eax,%ecx
  8009e6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ed:	eb 0a                	jmp    8009f9 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ef:	0f b6 10             	movzbl (%eax),%edx
  8009f2:	39 da                	cmp    %ebx,%edx
  8009f4:	74 07                	je     8009fd <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f6:	83 c0 01             	add    $0x1,%eax
  8009f9:	39 c8                	cmp    %ecx,%eax
  8009fb:	72 f2                	jb     8009ef <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009fd:	5b                   	pop    %ebx
  8009fe:	5d                   	pop    %ebp
  8009ff:	c3                   	ret    

00800a00 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	57                   	push   %edi
  800a04:	56                   	push   %esi
  800a05:	53                   	push   %ebx
  800a06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a09:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0c:	eb 03                	jmp    800a11 <strtol+0x11>
		s++;
  800a0e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a11:	0f b6 01             	movzbl (%ecx),%eax
  800a14:	3c 20                	cmp    $0x20,%al
  800a16:	74 f6                	je     800a0e <strtol+0xe>
  800a18:	3c 09                	cmp    $0x9,%al
  800a1a:	74 f2                	je     800a0e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a1c:	3c 2b                	cmp    $0x2b,%al
  800a1e:	75 0a                	jne    800a2a <strtol+0x2a>
		s++;
  800a20:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a23:	bf 00 00 00 00       	mov    $0x0,%edi
  800a28:	eb 11                	jmp    800a3b <strtol+0x3b>
  800a2a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a2f:	3c 2d                	cmp    $0x2d,%al
  800a31:	75 08                	jne    800a3b <strtol+0x3b>
		s++, neg = 1;
  800a33:	83 c1 01             	add    $0x1,%ecx
  800a36:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a41:	75 15                	jne    800a58 <strtol+0x58>
  800a43:	80 39 30             	cmpb   $0x30,(%ecx)
  800a46:	75 10                	jne    800a58 <strtol+0x58>
  800a48:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a4c:	75 7c                	jne    800aca <strtol+0xca>
		s += 2, base = 16;
  800a4e:	83 c1 02             	add    $0x2,%ecx
  800a51:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a56:	eb 16                	jmp    800a6e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a58:	85 db                	test   %ebx,%ebx
  800a5a:	75 12                	jne    800a6e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a5c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a61:	80 39 30             	cmpb   $0x30,(%ecx)
  800a64:	75 08                	jne    800a6e <strtol+0x6e>
		s++, base = 8;
  800a66:	83 c1 01             	add    $0x1,%ecx
  800a69:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a73:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a76:	0f b6 11             	movzbl (%ecx),%edx
  800a79:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a7c:	89 f3                	mov    %esi,%ebx
  800a7e:	80 fb 09             	cmp    $0x9,%bl
  800a81:	77 08                	ja     800a8b <strtol+0x8b>
			dig = *s - '0';
  800a83:	0f be d2             	movsbl %dl,%edx
  800a86:	83 ea 30             	sub    $0x30,%edx
  800a89:	eb 22                	jmp    800aad <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a8b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a8e:	89 f3                	mov    %esi,%ebx
  800a90:	80 fb 19             	cmp    $0x19,%bl
  800a93:	77 08                	ja     800a9d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a95:	0f be d2             	movsbl %dl,%edx
  800a98:	83 ea 57             	sub    $0x57,%edx
  800a9b:	eb 10                	jmp    800aad <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a9d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aa0:	89 f3                	mov    %esi,%ebx
  800aa2:	80 fb 19             	cmp    $0x19,%bl
  800aa5:	77 16                	ja     800abd <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aa7:	0f be d2             	movsbl %dl,%edx
  800aaa:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aad:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ab0:	7d 0b                	jge    800abd <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ab2:	83 c1 01             	add    $0x1,%ecx
  800ab5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ab9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800abb:	eb b9                	jmp    800a76 <strtol+0x76>

	if (endptr)
  800abd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac1:	74 0d                	je     800ad0 <strtol+0xd0>
		*endptr = (char *) s;
  800ac3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac6:	89 0e                	mov    %ecx,(%esi)
  800ac8:	eb 06                	jmp    800ad0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aca:	85 db                	test   %ebx,%ebx
  800acc:	74 98                	je     800a66 <strtol+0x66>
  800ace:	eb 9e                	jmp    800a6e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ad0:	89 c2                	mov    %eax,%edx
  800ad2:	f7 da                	neg    %edx
  800ad4:	85 ff                	test   %edi,%edi
  800ad6:	0f 45 c2             	cmovne %edx,%eax
}
  800ad9:	5b                   	pop    %ebx
  800ada:	5e                   	pop    %esi
  800adb:	5f                   	pop    %edi
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	57                   	push   %edi
  800ae2:	56                   	push   %esi
  800ae3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aec:	8b 55 08             	mov    0x8(%ebp),%edx
  800aef:	89 c3                	mov    %eax,%ebx
  800af1:	89 c7                	mov    %eax,%edi
  800af3:	89 c6                	mov    %eax,%esi
  800af5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800af7:	5b                   	pop    %ebx
  800af8:	5e                   	pop    %esi
  800af9:	5f                   	pop    %edi
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    

00800afc <sys_cgetc>:

int
sys_cgetc(void)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	57                   	push   %edi
  800b00:	56                   	push   %esi
  800b01:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b02:	ba 00 00 00 00       	mov    $0x0,%edx
  800b07:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0c:	89 d1                	mov    %edx,%ecx
  800b0e:	89 d3                	mov    %edx,%ebx
  800b10:	89 d7                	mov    %edx,%edi
  800b12:	89 d6                	mov    %edx,%esi
  800b14:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5f                   	pop    %edi
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	57                   	push   %edi
  800b1f:	56                   	push   %esi
  800b20:	53                   	push   %ebx
  800b21:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b24:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b29:	b8 03 00 00 00       	mov    $0x3,%eax
  800b2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b31:	89 cb                	mov    %ecx,%ebx
  800b33:	89 cf                	mov    %ecx,%edi
  800b35:	89 ce                	mov    %ecx,%esi
  800b37:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b39:	85 c0                	test   %eax,%eax
  800b3b:	7e 17                	jle    800b54 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3d:	83 ec 0c             	sub    $0xc,%esp
  800b40:	50                   	push   %eax
  800b41:	6a 03                	push   $0x3
  800b43:	68 bf 25 80 00       	push   $0x8025bf
  800b48:	6a 23                	push   $0x23
  800b4a:	68 dc 25 80 00       	push   $0x8025dc
  800b4f:	e8 e5 f5 ff ff       	call   800139 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b57:	5b                   	pop    %ebx
  800b58:	5e                   	pop    %esi
  800b59:	5f                   	pop    %edi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b62:	ba 00 00 00 00       	mov    $0x0,%edx
  800b67:	b8 02 00 00 00       	mov    $0x2,%eax
  800b6c:	89 d1                	mov    %edx,%ecx
  800b6e:	89 d3                	mov    %edx,%ebx
  800b70:	89 d7                	mov    %edx,%edi
  800b72:	89 d6                	mov    %edx,%esi
  800b74:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b76:	5b                   	pop    %ebx
  800b77:	5e                   	pop    %esi
  800b78:	5f                   	pop    %edi
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <sys_yield>:

void
sys_yield(void)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	57                   	push   %edi
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b81:	ba 00 00 00 00       	mov    $0x0,%edx
  800b86:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b8b:	89 d1                	mov    %edx,%ecx
  800b8d:	89 d3                	mov    %edx,%ebx
  800b8f:	89 d7                	mov    %edx,%edi
  800b91:	89 d6                	mov    %edx,%esi
  800b93:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
  800ba0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba3:	be 00 00 00 00       	mov    $0x0,%esi
  800ba8:	b8 04 00 00 00       	mov    $0x4,%eax
  800bad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb6:	89 f7                	mov    %esi,%edi
  800bb8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bba:	85 c0                	test   %eax,%eax
  800bbc:	7e 17                	jle    800bd5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbe:	83 ec 0c             	sub    $0xc,%esp
  800bc1:	50                   	push   %eax
  800bc2:	6a 04                	push   $0x4
  800bc4:	68 bf 25 80 00       	push   $0x8025bf
  800bc9:	6a 23                	push   $0x23
  800bcb:	68 dc 25 80 00       	push   $0x8025dc
  800bd0:	e8 64 f5 ff ff       	call   800139 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd8:	5b                   	pop    %ebx
  800bd9:	5e                   	pop    %esi
  800bda:	5f                   	pop    %edi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    

00800bdd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	57                   	push   %edi
  800be1:	56                   	push   %esi
  800be2:	53                   	push   %ebx
  800be3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be6:	b8 05 00 00 00       	mov    $0x5,%eax
  800beb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bee:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bf7:	8b 75 18             	mov    0x18(%ebp),%esi
  800bfa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfc:	85 c0                	test   %eax,%eax
  800bfe:	7e 17                	jle    800c17 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c00:	83 ec 0c             	sub    $0xc,%esp
  800c03:	50                   	push   %eax
  800c04:	6a 05                	push   $0x5
  800c06:	68 bf 25 80 00       	push   $0x8025bf
  800c0b:	6a 23                	push   $0x23
  800c0d:	68 dc 25 80 00       	push   $0x8025dc
  800c12:	e8 22 f5 ff ff       	call   800139 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1a:	5b                   	pop    %ebx
  800c1b:	5e                   	pop    %esi
  800c1c:	5f                   	pop    %edi
  800c1d:	5d                   	pop    %ebp
  800c1e:	c3                   	ret    

00800c1f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	57                   	push   %edi
  800c23:	56                   	push   %esi
  800c24:	53                   	push   %ebx
  800c25:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c28:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2d:	b8 06 00 00 00       	mov    $0x6,%eax
  800c32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c35:	8b 55 08             	mov    0x8(%ebp),%edx
  800c38:	89 df                	mov    %ebx,%edi
  800c3a:	89 de                	mov    %ebx,%esi
  800c3c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3e:	85 c0                	test   %eax,%eax
  800c40:	7e 17                	jle    800c59 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c42:	83 ec 0c             	sub    $0xc,%esp
  800c45:	50                   	push   %eax
  800c46:	6a 06                	push   $0x6
  800c48:	68 bf 25 80 00       	push   $0x8025bf
  800c4d:	6a 23                	push   $0x23
  800c4f:	68 dc 25 80 00       	push   $0x8025dc
  800c54:	e8 e0 f4 ff ff       	call   800139 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	57                   	push   %edi
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
  800c67:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6f:	b8 08 00 00 00       	mov    $0x8,%eax
  800c74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c77:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7a:	89 df                	mov    %ebx,%edi
  800c7c:	89 de                	mov    %ebx,%esi
  800c7e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c80:	85 c0                	test   %eax,%eax
  800c82:	7e 17                	jle    800c9b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c84:	83 ec 0c             	sub    $0xc,%esp
  800c87:	50                   	push   %eax
  800c88:	6a 08                	push   $0x8
  800c8a:	68 bf 25 80 00       	push   $0x8025bf
  800c8f:	6a 23                	push   $0x23
  800c91:	68 dc 25 80 00       	push   $0x8025dc
  800c96:	e8 9e f4 ff ff       	call   800139 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9e:	5b                   	pop    %ebx
  800c9f:	5e                   	pop    %esi
  800ca0:	5f                   	pop    %edi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    

00800ca3 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	57                   	push   %edi
  800ca7:	56                   	push   %esi
  800ca8:	53                   	push   %ebx
  800ca9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cac:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb1:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbc:	89 df                	mov    %ebx,%edi
  800cbe:	89 de                	mov    %ebx,%esi
  800cc0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc2:	85 c0                	test   %eax,%eax
  800cc4:	7e 17                	jle    800cdd <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc6:	83 ec 0c             	sub    $0xc,%esp
  800cc9:	50                   	push   %eax
  800cca:	6a 09                	push   $0x9
  800ccc:	68 bf 25 80 00       	push   $0x8025bf
  800cd1:	6a 23                	push   $0x23
  800cd3:	68 dc 25 80 00       	push   $0x8025dc
  800cd8:	e8 5c f4 ff ff       	call   800139 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce0:	5b                   	pop    %ebx
  800ce1:	5e                   	pop    %esi
  800ce2:	5f                   	pop    %edi
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    

00800ce5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	57                   	push   %edi
  800ce9:	56                   	push   %esi
  800cea:	53                   	push   %ebx
  800ceb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cee:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cf8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfe:	89 df                	mov    %ebx,%edi
  800d00:	89 de                	mov    %ebx,%esi
  800d02:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d04:	85 c0                	test   %eax,%eax
  800d06:	7e 17                	jle    800d1f <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d08:	83 ec 0c             	sub    $0xc,%esp
  800d0b:	50                   	push   %eax
  800d0c:	6a 0a                	push   $0xa
  800d0e:	68 bf 25 80 00       	push   $0x8025bf
  800d13:	6a 23                	push   $0x23
  800d15:	68 dc 25 80 00       	push   $0x8025dc
  800d1a:	e8 1a f4 ff ff       	call   800139 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d22:	5b                   	pop    %ebx
  800d23:	5e                   	pop    %esi
  800d24:	5f                   	pop    %edi
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    

00800d27 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	57                   	push   %edi
  800d2b:	56                   	push   %esi
  800d2c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2d:	be 00 00 00 00       	mov    $0x0,%esi
  800d32:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d40:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d43:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	57                   	push   %edi
  800d4e:	56                   	push   %esi
  800d4f:	53                   	push   %ebx
  800d50:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d53:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d58:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d60:	89 cb                	mov    %ecx,%ebx
  800d62:	89 cf                	mov    %ecx,%edi
  800d64:	89 ce                	mov    %ecx,%esi
  800d66:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d68:	85 c0                	test   %eax,%eax
  800d6a:	7e 17                	jle    800d83 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6c:	83 ec 0c             	sub    $0xc,%esp
  800d6f:	50                   	push   %eax
  800d70:	6a 0d                	push   $0xd
  800d72:	68 bf 25 80 00       	push   $0x8025bf
  800d77:	6a 23                	push   $0x23
  800d79:	68 dc 25 80 00       	push   $0x8025dc
  800d7e:	e8 b6 f3 ff ff       	call   800139 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d86:	5b                   	pop    %ebx
  800d87:	5e                   	pop    %esi
  800d88:	5f                   	pop    %edi
  800d89:	5d                   	pop    %ebp
  800d8a:	c3                   	ret    

00800d8b <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	57                   	push   %edi
  800d8f:	56                   	push   %esi
  800d90:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d91:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d96:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9e:	89 cb                	mov    %ecx,%ebx
  800da0:	89 cf                	mov    %ecx,%edi
  800da2:	89 ce                	mov    %ecx,%esi
  800da4:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800da6:	5b                   	pop    %ebx
  800da7:	5e                   	pop    %esi
  800da8:	5f                   	pop    %edi
  800da9:	5d                   	pop    %ebp
  800daa:	c3                   	ret    

00800dab <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	57                   	push   %edi
  800daf:	56                   	push   %esi
  800db0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db6:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbe:	89 cb                	mov    %ecx,%ebx
  800dc0:	89 cf                	mov    %ecx,%edi
  800dc2:	89 ce                	mov    %ecx,%esi
  800dc4:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800dc6:	5b                   	pop    %ebx
  800dc7:	5e                   	pop    %esi
  800dc8:	5f                   	pop    %edi
  800dc9:	5d                   	pop    %ebp
  800dca:	c3                   	ret    

00800dcb <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800dd1:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800dd8:	75 2a                	jne    800e04 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  800dda:	83 ec 04             	sub    $0x4,%esp
  800ddd:	6a 07                	push   $0x7
  800ddf:	68 00 f0 bf ee       	push   $0xeebff000
  800de4:	6a 00                	push   $0x0
  800de6:	e8 af fd ff ff       	call   800b9a <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  800deb:	83 c4 10             	add    $0x10,%esp
  800dee:	85 c0                	test   %eax,%eax
  800df0:	79 12                	jns    800e04 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  800df2:	50                   	push   %eax
  800df3:	68 ea 25 80 00       	push   $0x8025ea
  800df8:	6a 23                	push   $0x23
  800dfa:	68 ee 25 80 00       	push   $0x8025ee
  800dff:	e8 35 f3 ff ff       	call   800139 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e04:	8b 45 08             	mov    0x8(%ebp),%eax
  800e07:	a3 08 40 80 00       	mov    %eax,0x804008
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  800e0c:	83 ec 08             	sub    $0x8,%esp
  800e0f:	68 36 0e 80 00       	push   $0x800e36
  800e14:	6a 00                	push   $0x0
  800e16:	e8 ca fe ff ff       	call   800ce5 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  800e1b:	83 c4 10             	add    $0x10,%esp
  800e1e:	85 c0                	test   %eax,%eax
  800e20:	79 12                	jns    800e34 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  800e22:	50                   	push   %eax
  800e23:	68 ea 25 80 00       	push   $0x8025ea
  800e28:	6a 2c                	push   $0x2c
  800e2a:	68 ee 25 80 00       	push   $0x8025ee
  800e2f:	e8 05 f3 ff ff       	call   800139 <_panic>
	}
}
  800e34:	c9                   	leave  
  800e35:	c3                   	ret    

00800e36 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e36:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e37:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800e3c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e3e:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  800e41:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  800e45:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  800e4a:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  800e4e:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  800e50:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  800e53:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  800e54:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  800e57:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  800e58:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e59:	c3                   	ret    

00800e5a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	53                   	push   %ebx
  800e5e:	83 ec 04             	sub    $0x4,%esp
  800e61:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e64:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800e66:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e6a:	74 11                	je     800e7d <pgfault+0x23>
  800e6c:	89 d8                	mov    %ebx,%eax
  800e6e:	c1 e8 0c             	shr    $0xc,%eax
  800e71:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e78:	f6 c4 08             	test   $0x8,%ah
  800e7b:	75 14                	jne    800e91 <pgfault+0x37>
		panic("faulting access");
  800e7d:	83 ec 04             	sub    $0x4,%esp
  800e80:	68 fc 25 80 00       	push   $0x8025fc
  800e85:	6a 1e                	push   $0x1e
  800e87:	68 0c 26 80 00       	push   $0x80260c
  800e8c:	e8 a8 f2 ff ff       	call   800139 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800e91:	83 ec 04             	sub    $0x4,%esp
  800e94:	6a 07                	push   $0x7
  800e96:	68 00 f0 7f 00       	push   $0x7ff000
  800e9b:	6a 00                	push   $0x0
  800e9d:	e8 f8 fc ff ff       	call   800b9a <sys_page_alloc>
	if (r < 0) {
  800ea2:	83 c4 10             	add    $0x10,%esp
  800ea5:	85 c0                	test   %eax,%eax
  800ea7:	79 12                	jns    800ebb <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800ea9:	50                   	push   %eax
  800eaa:	68 17 26 80 00       	push   $0x802617
  800eaf:	6a 2c                	push   $0x2c
  800eb1:	68 0c 26 80 00       	push   $0x80260c
  800eb6:	e8 7e f2 ff ff       	call   800139 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800ebb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800ec1:	83 ec 04             	sub    $0x4,%esp
  800ec4:	68 00 10 00 00       	push   $0x1000
  800ec9:	53                   	push   %ebx
  800eca:	68 00 f0 7f 00       	push   $0x7ff000
  800ecf:	e8 bd fa ff ff       	call   800991 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800ed4:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800edb:	53                   	push   %ebx
  800edc:	6a 00                	push   $0x0
  800ede:	68 00 f0 7f 00       	push   $0x7ff000
  800ee3:	6a 00                	push   $0x0
  800ee5:	e8 f3 fc ff ff       	call   800bdd <sys_page_map>
	if (r < 0) {
  800eea:	83 c4 20             	add    $0x20,%esp
  800eed:	85 c0                	test   %eax,%eax
  800eef:	79 12                	jns    800f03 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800ef1:	50                   	push   %eax
  800ef2:	68 17 26 80 00       	push   $0x802617
  800ef7:	6a 33                	push   $0x33
  800ef9:	68 0c 26 80 00       	push   $0x80260c
  800efe:	e8 36 f2 ff ff       	call   800139 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800f03:	83 ec 08             	sub    $0x8,%esp
  800f06:	68 00 f0 7f 00       	push   $0x7ff000
  800f0b:	6a 00                	push   $0x0
  800f0d:	e8 0d fd ff ff       	call   800c1f <sys_page_unmap>
	if (r < 0) {
  800f12:	83 c4 10             	add    $0x10,%esp
  800f15:	85 c0                	test   %eax,%eax
  800f17:	79 12                	jns    800f2b <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800f19:	50                   	push   %eax
  800f1a:	68 17 26 80 00       	push   $0x802617
  800f1f:	6a 37                	push   $0x37
  800f21:	68 0c 26 80 00       	push   $0x80260c
  800f26:	e8 0e f2 ff ff       	call   800139 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800f2b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f2e:	c9                   	leave  
  800f2f:	c3                   	ret    

00800f30 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	57                   	push   %edi
  800f34:	56                   	push   %esi
  800f35:	53                   	push   %ebx
  800f36:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800f39:	68 5a 0e 80 00       	push   $0x800e5a
  800f3e:	e8 88 fe ff ff       	call   800dcb <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f43:	b8 07 00 00 00       	mov    $0x7,%eax
  800f48:	cd 30                	int    $0x30
  800f4a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800f4d:	83 c4 10             	add    $0x10,%esp
  800f50:	85 c0                	test   %eax,%eax
  800f52:	79 17                	jns    800f6b <fork+0x3b>
		panic("fork fault %e");
  800f54:	83 ec 04             	sub    $0x4,%esp
  800f57:	68 30 26 80 00       	push   $0x802630
  800f5c:	68 84 00 00 00       	push   $0x84
  800f61:	68 0c 26 80 00       	push   $0x80260c
  800f66:	e8 ce f1 ff ff       	call   800139 <_panic>
  800f6b:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f6d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f71:	75 25                	jne    800f98 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f73:	e8 e4 fb ff ff       	call   800b5c <sys_getenvid>
  800f78:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f7d:	89 c2                	mov    %eax,%edx
  800f7f:	c1 e2 07             	shl    $0x7,%edx
  800f82:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800f89:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f93:	e9 61 01 00 00       	jmp    8010f9 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800f98:	83 ec 04             	sub    $0x4,%esp
  800f9b:	6a 07                	push   $0x7
  800f9d:	68 00 f0 bf ee       	push   $0xeebff000
  800fa2:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fa5:	e8 f0 fb ff ff       	call   800b9a <sys_page_alloc>
  800faa:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800fad:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800fb2:	89 d8                	mov    %ebx,%eax
  800fb4:	c1 e8 16             	shr    $0x16,%eax
  800fb7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fbe:	a8 01                	test   $0x1,%al
  800fc0:	0f 84 fc 00 00 00    	je     8010c2 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800fc6:	89 d8                	mov    %ebx,%eax
  800fc8:	c1 e8 0c             	shr    $0xc,%eax
  800fcb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800fd2:	f6 c2 01             	test   $0x1,%dl
  800fd5:	0f 84 e7 00 00 00    	je     8010c2 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800fdb:	89 c6                	mov    %eax,%esi
  800fdd:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800fe0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fe7:	f6 c6 04             	test   $0x4,%dh
  800fea:	74 39                	je     801025 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800fec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ff3:	83 ec 0c             	sub    $0xc,%esp
  800ff6:	25 07 0e 00 00       	and    $0xe07,%eax
  800ffb:	50                   	push   %eax
  800ffc:	56                   	push   %esi
  800ffd:	57                   	push   %edi
  800ffe:	56                   	push   %esi
  800fff:	6a 00                	push   $0x0
  801001:	e8 d7 fb ff ff       	call   800bdd <sys_page_map>
		if (r < 0) {
  801006:	83 c4 20             	add    $0x20,%esp
  801009:	85 c0                	test   %eax,%eax
  80100b:	0f 89 b1 00 00 00    	jns    8010c2 <fork+0x192>
		    	panic("sys page map fault %e");
  801011:	83 ec 04             	sub    $0x4,%esp
  801014:	68 3e 26 80 00       	push   $0x80263e
  801019:	6a 54                	push   $0x54
  80101b:	68 0c 26 80 00       	push   $0x80260c
  801020:	e8 14 f1 ff ff       	call   800139 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801025:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80102c:	f6 c2 02             	test   $0x2,%dl
  80102f:	75 0c                	jne    80103d <fork+0x10d>
  801031:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801038:	f6 c4 08             	test   $0x8,%ah
  80103b:	74 5b                	je     801098 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80103d:	83 ec 0c             	sub    $0xc,%esp
  801040:	68 05 08 00 00       	push   $0x805
  801045:	56                   	push   %esi
  801046:	57                   	push   %edi
  801047:	56                   	push   %esi
  801048:	6a 00                	push   $0x0
  80104a:	e8 8e fb ff ff       	call   800bdd <sys_page_map>
		if (r < 0) {
  80104f:	83 c4 20             	add    $0x20,%esp
  801052:	85 c0                	test   %eax,%eax
  801054:	79 14                	jns    80106a <fork+0x13a>
		    	panic("sys page map fault %e");
  801056:	83 ec 04             	sub    $0x4,%esp
  801059:	68 3e 26 80 00       	push   $0x80263e
  80105e:	6a 5b                	push   $0x5b
  801060:	68 0c 26 80 00       	push   $0x80260c
  801065:	e8 cf f0 ff ff       	call   800139 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  80106a:	83 ec 0c             	sub    $0xc,%esp
  80106d:	68 05 08 00 00       	push   $0x805
  801072:	56                   	push   %esi
  801073:	6a 00                	push   $0x0
  801075:	56                   	push   %esi
  801076:	6a 00                	push   $0x0
  801078:	e8 60 fb ff ff       	call   800bdd <sys_page_map>
		if (r < 0) {
  80107d:	83 c4 20             	add    $0x20,%esp
  801080:	85 c0                	test   %eax,%eax
  801082:	79 3e                	jns    8010c2 <fork+0x192>
		    	panic("sys page map fault %e");
  801084:	83 ec 04             	sub    $0x4,%esp
  801087:	68 3e 26 80 00       	push   $0x80263e
  80108c:	6a 5f                	push   $0x5f
  80108e:	68 0c 26 80 00       	push   $0x80260c
  801093:	e8 a1 f0 ff ff       	call   800139 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801098:	83 ec 0c             	sub    $0xc,%esp
  80109b:	6a 05                	push   $0x5
  80109d:	56                   	push   %esi
  80109e:	57                   	push   %edi
  80109f:	56                   	push   %esi
  8010a0:	6a 00                	push   $0x0
  8010a2:	e8 36 fb ff ff       	call   800bdd <sys_page_map>
		if (r < 0) {
  8010a7:	83 c4 20             	add    $0x20,%esp
  8010aa:	85 c0                	test   %eax,%eax
  8010ac:	79 14                	jns    8010c2 <fork+0x192>
		    	panic("sys page map fault %e");
  8010ae:	83 ec 04             	sub    $0x4,%esp
  8010b1:	68 3e 26 80 00       	push   $0x80263e
  8010b6:	6a 64                	push   $0x64
  8010b8:	68 0c 26 80 00       	push   $0x80260c
  8010bd:	e8 77 f0 ff ff       	call   800139 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8010c2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010c8:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8010ce:	0f 85 de fe ff ff    	jne    800fb2 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  8010d4:	a1 04 40 80 00       	mov    0x804004,%eax
  8010d9:	8b 40 70             	mov    0x70(%eax),%eax
  8010dc:	83 ec 08             	sub    $0x8,%esp
  8010df:	50                   	push   %eax
  8010e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010e3:	57                   	push   %edi
  8010e4:	e8 fc fb ff ff       	call   800ce5 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  8010e9:	83 c4 08             	add    $0x8,%esp
  8010ec:	6a 02                	push   $0x2
  8010ee:	57                   	push   %edi
  8010ef:	e8 6d fb ff ff       	call   800c61 <sys_env_set_status>
	
	return envid;
  8010f4:	83 c4 10             	add    $0x10,%esp
  8010f7:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  8010f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fc:	5b                   	pop    %ebx
  8010fd:	5e                   	pop    %esi
  8010fe:	5f                   	pop    %edi
  8010ff:	5d                   	pop    %ebp
  801100:	c3                   	ret    

00801101 <sfork>:

envid_t
sfork(void)
{
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801104:	b8 00 00 00 00       	mov    $0x0,%eax
  801109:	5d                   	pop    %ebp
  80110a:	c3                   	ret    

0080110b <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
  80110e:	56                   	push   %esi
  80110f:	53                   	push   %ebx
  801110:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801113:	89 1d 0c 40 80 00    	mov    %ebx,0x80400c
	cprintf("in fork.c thread create. func: %x\n", func);
  801119:	83 ec 08             	sub    $0x8,%esp
  80111c:	53                   	push   %ebx
  80111d:	68 54 26 80 00       	push   $0x802654
  801122:	e8 eb f0 ff ff       	call   800212 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801127:	c7 04 24 ff 00 80 00 	movl   $0x8000ff,(%esp)
  80112e:	e8 58 fc ff ff       	call   800d8b <sys_thread_create>
  801133:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801135:	83 c4 08             	add    $0x8,%esp
  801138:	53                   	push   %ebx
  801139:	68 54 26 80 00       	push   $0x802654
  80113e:	e8 cf f0 ff ff       	call   800212 <cprintf>
	return id;
	//return 0;
}
  801143:	89 f0                	mov    %esi,%eax
  801145:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801148:	5b                   	pop    %ebx
  801149:	5e                   	pop    %esi
  80114a:	5d                   	pop    %ebp
  80114b:	c3                   	ret    

0080114c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80114c:	55                   	push   %ebp
  80114d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80114f:	8b 45 08             	mov    0x8(%ebp),%eax
  801152:	05 00 00 00 30       	add    $0x30000000,%eax
  801157:	c1 e8 0c             	shr    $0xc,%eax
}
  80115a:	5d                   	pop    %ebp
  80115b:	c3                   	ret    

0080115c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80115f:	8b 45 08             	mov    0x8(%ebp),%eax
  801162:	05 00 00 00 30       	add    $0x30000000,%eax
  801167:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80116c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801171:	5d                   	pop    %ebp
  801172:	c3                   	ret    

00801173 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801173:	55                   	push   %ebp
  801174:	89 e5                	mov    %esp,%ebp
  801176:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801179:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80117e:	89 c2                	mov    %eax,%edx
  801180:	c1 ea 16             	shr    $0x16,%edx
  801183:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80118a:	f6 c2 01             	test   $0x1,%dl
  80118d:	74 11                	je     8011a0 <fd_alloc+0x2d>
  80118f:	89 c2                	mov    %eax,%edx
  801191:	c1 ea 0c             	shr    $0xc,%edx
  801194:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80119b:	f6 c2 01             	test   $0x1,%dl
  80119e:	75 09                	jne    8011a9 <fd_alloc+0x36>
			*fd_store = fd;
  8011a0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a7:	eb 17                	jmp    8011c0 <fd_alloc+0x4d>
  8011a9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011ae:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011b3:	75 c9                	jne    80117e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011b5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011bb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011c0:	5d                   	pop    %ebp
  8011c1:	c3                   	ret    

008011c2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011c2:	55                   	push   %ebp
  8011c3:	89 e5                	mov    %esp,%ebp
  8011c5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011c8:	83 f8 1f             	cmp    $0x1f,%eax
  8011cb:	77 36                	ja     801203 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011cd:	c1 e0 0c             	shl    $0xc,%eax
  8011d0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011d5:	89 c2                	mov    %eax,%edx
  8011d7:	c1 ea 16             	shr    $0x16,%edx
  8011da:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011e1:	f6 c2 01             	test   $0x1,%dl
  8011e4:	74 24                	je     80120a <fd_lookup+0x48>
  8011e6:	89 c2                	mov    %eax,%edx
  8011e8:	c1 ea 0c             	shr    $0xc,%edx
  8011eb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011f2:	f6 c2 01             	test   $0x1,%dl
  8011f5:	74 1a                	je     801211 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011fa:	89 02                	mov    %eax,(%edx)
	return 0;
  8011fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801201:	eb 13                	jmp    801216 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801203:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801208:	eb 0c                	jmp    801216 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80120a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80120f:	eb 05                	jmp    801216 <fd_lookup+0x54>
  801211:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801216:	5d                   	pop    %ebp
  801217:	c3                   	ret    

00801218 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801218:	55                   	push   %ebp
  801219:	89 e5                	mov    %esp,%ebp
  80121b:	83 ec 08             	sub    $0x8,%esp
  80121e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801221:	ba f8 26 80 00       	mov    $0x8026f8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801226:	eb 13                	jmp    80123b <dev_lookup+0x23>
  801228:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80122b:	39 08                	cmp    %ecx,(%eax)
  80122d:	75 0c                	jne    80123b <dev_lookup+0x23>
			*dev = devtab[i];
  80122f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801232:	89 01                	mov    %eax,(%ecx)
			return 0;
  801234:	b8 00 00 00 00       	mov    $0x0,%eax
  801239:	eb 2e                	jmp    801269 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80123b:	8b 02                	mov    (%edx),%eax
  80123d:	85 c0                	test   %eax,%eax
  80123f:	75 e7                	jne    801228 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801241:	a1 04 40 80 00       	mov    0x804004,%eax
  801246:	8b 40 54             	mov    0x54(%eax),%eax
  801249:	83 ec 04             	sub    $0x4,%esp
  80124c:	51                   	push   %ecx
  80124d:	50                   	push   %eax
  80124e:	68 78 26 80 00       	push   $0x802678
  801253:	e8 ba ef ff ff       	call   800212 <cprintf>
	*dev = 0;
  801258:	8b 45 0c             	mov    0xc(%ebp),%eax
  80125b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801261:	83 c4 10             	add    $0x10,%esp
  801264:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801269:	c9                   	leave  
  80126a:	c3                   	ret    

0080126b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80126b:	55                   	push   %ebp
  80126c:	89 e5                	mov    %esp,%ebp
  80126e:	56                   	push   %esi
  80126f:	53                   	push   %ebx
  801270:	83 ec 10             	sub    $0x10,%esp
  801273:	8b 75 08             	mov    0x8(%ebp),%esi
  801276:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801279:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127c:	50                   	push   %eax
  80127d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801283:	c1 e8 0c             	shr    $0xc,%eax
  801286:	50                   	push   %eax
  801287:	e8 36 ff ff ff       	call   8011c2 <fd_lookup>
  80128c:	83 c4 08             	add    $0x8,%esp
  80128f:	85 c0                	test   %eax,%eax
  801291:	78 05                	js     801298 <fd_close+0x2d>
	    || fd != fd2)
  801293:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801296:	74 0c                	je     8012a4 <fd_close+0x39>
		return (must_exist ? r : 0);
  801298:	84 db                	test   %bl,%bl
  80129a:	ba 00 00 00 00       	mov    $0x0,%edx
  80129f:	0f 44 c2             	cmove  %edx,%eax
  8012a2:	eb 41                	jmp    8012e5 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012a4:	83 ec 08             	sub    $0x8,%esp
  8012a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012aa:	50                   	push   %eax
  8012ab:	ff 36                	pushl  (%esi)
  8012ad:	e8 66 ff ff ff       	call   801218 <dev_lookup>
  8012b2:	89 c3                	mov    %eax,%ebx
  8012b4:	83 c4 10             	add    $0x10,%esp
  8012b7:	85 c0                	test   %eax,%eax
  8012b9:	78 1a                	js     8012d5 <fd_close+0x6a>
		if (dev->dev_close)
  8012bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012be:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012c1:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012c6:	85 c0                	test   %eax,%eax
  8012c8:	74 0b                	je     8012d5 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012ca:	83 ec 0c             	sub    $0xc,%esp
  8012cd:	56                   	push   %esi
  8012ce:	ff d0                	call   *%eax
  8012d0:	89 c3                	mov    %eax,%ebx
  8012d2:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012d5:	83 ec 08             	sub    $0x8,%esp
  8012d8:	56                   	push   %esi
  8012d9:	6a 00                	push   $0x0
  8012db:	e8 3f f9 ff ff       	call   800c1f <sys_page_unmap>
	return r;
  8012e0:	83 c4 10             	add    $0x10,%esp
  8012e3:	89 d8                	mov    %ebx,%eax
}
  8012e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012e8:	5b                   	pop    %ebx
  8012e9:	5e                   	pop    %esi
  8012ea:	5d                   	pop    %ebp
  8012eb:	c3                   	ret    

008012ec <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012ec:	55                   	push   %ebp
  8012ed:	89 e5                	mov    %esp,%ebp
  8012ef:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f5:	50                   	push   %eax
  8012f6:	ff 75 08             	pushl  0x8(%ebp)
  8012f9:	e8 c4 fe ff ff       	call   8011c2 <fd_lookup>
  8012fe:	83 c4 08             	add    $0x8,%esp
  801301:	85 c0                	test   %eax,%eax
  801303:	78 10                	js     801315 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801305:	83 ec 08             	sub    $0x8,%esp
  801308:	6a 01                	push   $0x1
  80130a:	ff 75 f4             	pushl  -0xc(%ebp)
  80130d:	e8 59 ff ff ff       	call   80126b <fd_close>
  801312:	83 c4 10             	add    $0x10,%esp
}
  801315:	c9                   	leave  
  801316:	c3                   	ret    

00801317 <close_all>:

void
close_all(void)
{
  801317:	55                   	push   %ebp
  801318:	89 e5                	mov    %esp,%ebp
  80131a:	53                   	push   %ebx
  80131b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80131e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801323:	83 ec 0c             	sub    $0xc,%esp
  801326:	53                   	push   %ebx
  801327:	e8 c0 ff ff ff       	call   8012ec <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80132c:	83 c3 01             	add    $0x1,%ebx
  80132f:	83 c4 10             	add    $0x10,%esp
  801332:	83 fb 20             	cmp    $0x20,%ebx
  801335:	75 ec                	jne    801323 <close_all+0xc>
		close(i);
}
  801337:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80133a:	c9                   	leave  
  80133b:	c3                   	ret    

0080133c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80133c:	55                   	push   %ebp
  80133d:	89 e5                	mov    %esp,%ebp
  80133f:	57                   	push   %edi
  801340:	56                   	push   %esi
  801341:	53                   	push   %ebx
  801342:	83 ec 2c             	sub    $0x2c,%esp
  801345:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801348:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80134b:	50                   	push   %eax
  80134c:	ff 75 08             	pushl  0x8(%ebp)
  80134f:	e8 6e fe ff ff       	call   8011c2 <fd_lookup>
  801354:	83 c4 08             	add    $0x8,%esp
  801357:	85 c0                	test   %eax,%eax
  801359:	0f 88 c1 00 00 00    	js     801420 <dup+0xe4>
		return r;
	close(newfdnum);
  80135f:	83 ec 0c             	sub    $0xc,%esp
  801362:	56                   	push   %esi
  801363:	e8 84 ff ff ff       	call   8012ec <close>

	newfd = INDEX2FD(newfdnum);
  801368:	89 f3                	mov    %esi,%ebx
  80136a:	c1 e3 0c             	shl    $0xc,%ebx
  80136d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801373:	83 c4 04             	add    $0x4,%esp
  801376:	ff 75 e4             	pushl  -0x1c(%ebp)
  801379:	e8 de fd ff ff       	call   80115c <fd2data>
  80137e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801380:	89 1c 24             	mov    %ebx,(%esp)
  801383:	e8 d4 fd ff ff       	call   80115c <fd2data>
  801388:	83 c4 10             	add    $0x10,%esp
  80138b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80138e:	89 f8                	mov    %edi,%eax
  801390:	c1 e8 16             	shr    $0x16,%eax
  801393:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80139a:	a8 01                	test   $0x1,%al
  80139c:	74 37                	je     8013d5 <dup+0x99>
  80139e:	89 f8                	mov    %edi,%eax
  8013a0:	c1 e8 0c             	shr    $0xc,%eax
  8013a3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013aa:	f6 c2 01             	test   $0x1,%dl
  8013ad:	74 26                	je     8013d5 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013af:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013b6:	83 ec 0c             	sub    $0xc,%esp
  8013b9:	25 07 0e 00 00       	and    $0xe07,%eax
  8013be:	50                   	push   %eax
  8013bf:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013c2:	6a 00                	push   $0x0
  8013c4:	57                   	push   %edi
  8013c5:	6a 00                	push   $0x0
  8013c7:	e8 11 f8 ff ff       	call   800bdd <sys_page_map>
  8013cc:	89 c7                	mov    %eax,%edi
  8013ce:	83 c4 20             	add    $0x20,%esp
  8013d1:	85 c0                	test   %eax,%eax
  8013d3:	78 2e                	js     801403 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013d5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013d8:	89 d0                	mov    %edx,%eax
  8013da:	c1 e8 0c             	shr    $0xc,%eax
  8013dd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013e4:	83 ec 0c             	sub    $0xc,%esp
  8013e7:	25 07 0e 00 00       	and    $0xe07,%eax
  8013ec:	50                   	push   %eax
  8013ed:	53                   	push   %ebx
  8013ee:	6a 00                	push   $0x0
  8013f0:	52                   	push   %edx
  8013f1:	6a 00                	push   $0x0
  8013f3:	e8 e5 f7 ff ff       	call   800bdd <sys_page_map>
  8013f8:	89 c7                	mov    %eax,%edi
  8013fa:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013fd:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013ff:	85 ff                	test   %edi,%edi
  801401:	79 1d                	jns    801420 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801403:	83 ec 08             	sub    $0x8,%esp
  801406:	53                   	push   %ebx
  801407:	6a 00                	push   $0x0
  801409:	e8 11 f8 ff ff       	call   800c1f <sys_page_unmap>
	sys_page_unmap(0, nva);
  80140e:	83 c4 08             	add    $0x8,%esp
  801411:	ff 75 d4             	pushl  -0x2c(%ebp)
  801414:	6a 00                	push   $0x0
  801416:	e8 04 f8 ff ff       	call   800c1f <sys_page_unmap>
	return r;
  80141b:	83 c4 10             	add    $0x10,%esp
  80141e:	89 f8                	mov    %edi,%eax
}
  801420:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801423:	5b                   	pop    %ebx
  801424:	5e                   	pop    %esi
  801425:	5f                   	pop    %edi
  801426:	5d                   	pop    %ebp
  801427:	c3                   	ret    

00801428 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801428:	55                   	push   %ebp
  801429:	89 e5                	mov    %esp,%ebp
  80142b:	53                   	push   %ebx
  80142c:	83 ec 14             	sub    $0x14,%esp
  80142f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801432:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801435:	50                   	push   %eax
  801436:	53                   	push   %ebx
  801437:	e8 86 fd ff ff       	call   8011c2 <fd_lookup>
  80143c:	83 c4 08             	add    $0x8,%esp
  80143f:	89 c2                	mov    %eax,%edx
  801441:	85 c0                	test   %eax,%eax
  801443:	78 6d                	js     8014b2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801445:	83 ec 08             	sub    $0x8,%esp
  801448:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80144b:	50                   	push   %eax
  80144c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144f:	ff 30                	pushl  (%eax)
  801451:	e8 c2 fd ff ff       	call   801218 <dev_lookup>
  801456:	83 c4 10             	add    $0x10,%esp
  801459:	85 c0                	test   %eax,%eax
  80145b:	78 4c                	js     8014a9 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80145d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801460:	8b 42 08             	mov    0x8(%edx),%eax
  801463:	83 e0 03             	and    $0x3,%eax
  801466:	83 f8 01             	cmp    $0x1,%eax
  801469:	75 21                	jne    80148c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80146b:	a1 04 40 80 00       	mov    0x804004,%eax
  801470:	8b 40 54             	mov    0x54(%eax),%eax
  801473:	83 ec 04             	sub    $0x4,%esp
  801476:	53                   	push   %ebx
  801477:	50                   	push   %eax
  801478:	68 bc 26 80 00       	push   $0x8026bc
  80147d:	e8 90 ed ff ff       	call   800212 <cprintf>
		return -E_INVAL;
  801482:	83 c4 10             	add    $0x10,%esp
  801485:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80148a:	eb 26                	jmp    8014b2 <read+0x8a>
	}
	if (!dev->dev_read)
  80148c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80148f:	8b 40 08             	mov    0x8(%eax),%eax
  801492:	85 c0                	test   %eax,%eax
  801494:	74 17                	je     8014ad <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801496:	83 ec 04             	sub    $0x4,%esp
  801499:	ff 75 10             	pushl  0x10(%ebp)
  80149c:	ff 75 0c             	pushl  0xc(%ebp)
  80149f:	52                   	push   %edx
  8014a0:	ff d0                	call   *%eax
  8014a2:	89 c2                	mov    %eax,%edx
  8014a4:	83 c4 10             	add    $0x10,%esp
  8014a7:	eb 09                	jmp    8014b2 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a9:	89 c2                	mov    %eax,%edx
  8014ab:	eb 05                	jmp    8014b2 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014ad:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8014b2:	89 d0                	mov    %edx,%eax
  8014b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014b7:	c9                   	leave  
  8014b8:	c3                   	ret    

008014b9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014b9:	55                   	push   %ebp
  8014ba:	89 e5                	mov    %esp,%ebp
  8014bc:	57                   	push   %edi
  8014bd:	56                   	push   %esi
  8014be:	53                   	push   %ebx
  8014bf:	83 ec 0c             	sub    $0xc,%esp
  8014c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014c5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014c8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014cd:	eb 21                	jmp    8014f0 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014cf:	83 ec 04             	sub    $0x4,%esp
  8014d2:	89 f0                	mov    %esi,%eax
  8014d4:	29 d8                	sub    %ebx,%eax
  8014d6:	50                   	push   %eax
  8014d7:	89 d8                	mov    %ebx,%eax
  8014d9:	03 45 0c             	add    0xc(%ebp),%eax
  8014dc:	50                   	push   %eax
  8014dd:	57                   	push   %edi
  8014de:	e8 45 ff ff ff       	call   801428 <read>
		if (m < 0)
  8014e3:	83 c4 10             	add    $0x10,%esp
  8014e6:	85 c0                	test   %eax,%eax
  8014e8:	78 10                	js     8014fa <readn+0x41>
			return m;
		if (m == 0)
  8014ea:	85 c0                	test   %eax,%eax
  8014ec:	74 0a                	je     8014f8 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ee:	01 c3                	add    %eax,%ebx
  8014f0:	39 f3                	cmp    %esi,%ebx
  8014f2:	72 db                	jb     8014cf <readn+0x16>
  8014f4:	89 d8                	mov    %ebx,%eax
  8014f6:	eb 02                	jmp    8014fa <readn+0x41>
  8014f8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014fd:	5b                   	pop    %ebx
  8014fe:	5e                   	pop    %esi
  8014ff:	5f                   	pop    %edi
  801500:	5d                   	pop    %ebp
  801501:	c3                   	ret    

00801502 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801502:	55                   	push   %ebp
  801503:	89 e5                	mov    %esp,%ebp
  801505:	53                   	push   %ebx
  801506:	83 ec 14             	sub    $0x14,%esp
  801509:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80150c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80150f:	50                   	push   %eax
  801510:	53                   	push   %ebx
  801511:	e8 ac fc ff ff       	call   8011c2 <fd_lookup>
  801516:	83 c4 08             	add    $0x8,%esp
  801519:	89 c2                	mov    %eax,%edx
  80151b:	85 c0                	test   %eax,%eax
  80151d:	78 68                	js     801587 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151f:	83 ec 08             	sub    $0x8,%esp
  801522:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801525:	50                   	push   %eax
  801526:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801529:	ff 30                	pushl  (%eax)
  80152b:	e8 e8 fc ff ff       	call   801218 <dev_lookup>
  801530:	83 c4 10             	add    $0x10,%esp
  801533:	85 c0                	test   %eax,%eax
  801535:	78 47                	js     80157e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801537:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80153e:	75 21                	jne    801561 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801540:	a1 04 40 80 00       	mov    0x804004,%eax
  801545:	8b 40 54             	mov    0x54(%eax),%eax
  801548:	83 ec 04             	sub    $0x4,%esp
  80154b:	53                   	push   %ebx
  80154c:	50                   	push   %eax
  80154d:	68 d8 26 80 00       	push   $0x8026d8
  801552:	e8 bb ec ff ff       	call   800212 <cprintf>
		return -E_INVAL;
  801557:	83 c4 10             	add    $0x10,%esp
  80155a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80155f:	eb 26                	jmp    801587 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801561:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801564:	8b 52 0c             	mov    0xc(%edx),%edx
  801567:	85 d2                	test   %edx,%edx
  801569:	74 17                	je     801582 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80156b:	83 ec 04             	sub    $0x4,%esp
  80156e:	ff 75 10             	pushl  0x10(%ebp)
  801571:	ff 75 0c             	pushl  0xc(%ebp)
  801574:	50                   	push   %eax
  801575:	ff d2                	call   *%edx
  801577:	89 c2                	mov    %eax,%edx
  801579:	83 c4 10             	add    $0x10,%esp
  80157c:	eb 09                	jmp    801587 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157e:	89 c2                	mov    %eax,%edx
  801580:	eb 05                	jmp    801587 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801582:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801587:	89 d0                	mov    %edx,%eax
  801589:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80158c:	c9                   	leave  
  80158d:	c3                   	ret    

0080158e <seek>:

int
seek(int fdnum, off_t offset)
{
  80158e:	55                   	push   %ebp
  80158f:	89 e5                	mov    %esp,%ebp
  801591:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801594:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801597:	50                   	push   %eax
  801598:	ff 75 08             	pushl  0x8(%ebp)
  80159b:	e8 22 fc ff ff       	call   8011c2 <fd_lookup>
  8015a0:	83 c4 08             	add    $0x8,%esp
  8015a3:	85 c0                	test   %eax,%eax
  8015a5:	78 0e                	js     8015b5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015ad:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015b5:	c9                   	leave  
  8015b6:	c3                   	ret    

008015b7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015b7:	55                   	push   %ebp
  8015b8:	89 e5                	mov    %esp,%ebp
  8015ba:	53                   	push   %ebx
  8015bb:	83 ec 14             	sub    $0x14,%esp
  8015be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c4:	50                   	push   %eax
  8015c5:	53                   	push   %ebx
  8015c6:	e8 f7 fb ff ff       	call   8011c2 <fd_lookup>
  8015cb:	83 c4 08             	add    $0x8,%esp
  8015ce:	89 c2                	mov    %eax,%edx
  8015d0:	85 c0                	test   %eax,%eax
  8015d2:	78 65                	js     801639 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d4:	83 ec 08             	sub    $0x8,%esp
  8015d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015da:	50                   	push   %eax
  8015db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015de:	ff 30                	pushl  (%eax)
  8015e0:	e8 33 fc ff ff       	call   801218 <dev_lookup>
  8015e5:	83 c4 10             	add    $0x10,%esp
  8015e8:	85 c0                	test   %eax,%eax
  8015ea:	78 44                	js     801630 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ef:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015f3:	75 21                	jne    801616 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015f5:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015fa:	8b 40 54             	mov    0x54(%eax),%eax
  8015fd:	83 ec 04             	sub    $0x4,%esp
  801600:	53                   	push   %ebx
  801601:	50                   	push   %eax
  801602:	68 98 26 80 00       	push   $0x802698
  801607:	e8 06 ec ff ff       	call   800212 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80160c:	83 c4 10             	add    $0x10,%esp
  80160f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801614:	eb 23                	jmp    801639 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801616:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801619:	8b 52 18             	mov    0x18(%edx),%edx
  80161c:	85 d2                	test   %edx,%edx
  80161e:	74 14                	je     801634 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801620:	83 ec 08             	sub    $0x8,%esp
  801623:	ff 75 0c             	pushl  0xc(%ebp)
  801626:	50                   	push   %eax
  801627:	ff d2                	call   *%edx
  801629:	89 c2                	mov    %eax,%edx
  80162b:	83 c4 10             	add    $0x10,%esp
  80162e:	eb 09                	jmp    801639 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801630:	89 c2                	mov    %eax,%edx
  801632:	eb 05                	jmp    801639 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801634:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801639:	89 d0                	mov    %edx,%eax
  80163b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163e:	c9                   	leave  
  80163f:	c3                   	ret    

00801640 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801640:	55                   	push   %ebp
  801641:	89 e5                	mov    %esp,%ebp
  801643:	53                   	push   %ebx
  801644:	83 ec 14             	sub    $0x14,%esp
  801647:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80164a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164d:	50                   	push   %eax
  80164e:	ff 75 08             	pushl  0x8(%ebp)
  801651:	e8 6c fb ff ff       	call   8011c2 <fd_lookup>
  801656:	83 c4 08             	add    $0x8,%esp
  801659:	89 c2                	mov    %eax,%edx
  80165b:	85 c0                	test   %eax,%eax
  80165d:	78 58                	js     8016b7 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165f:	83 ec 08             	sub    $0x8,%esp
  801662:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801665:	50                   	push   %eax
  801666:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801669:	ff 30                	pushl  (%eax)
  80166b:	e8 a8 fb ff ff       	call   801218 <dev_lookup>
  801670:	83 c4 10             	add    $0x10,%esp
  801673:	85 c0                	test   %eax,%eax
  801675:	78 37                	js     8016ae <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801677:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80167a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80167e:	74 32                	je     8016b2 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801680:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801683:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80168a:	00 00 00 
	stat->st_isdir = 0;
  80168d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801694:	00 00 00 
	stat->st_dev = dev;
  801697:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80169d:	83 ec 08             	sub    $0x8,%esp
  8016a0:	53                   	push   %ebx
  8016a1:	ff 75 f0             	pushl  -0x10(%ebp)
  8016a4:	ff 50 14             	call   *0x14(%eax)
  8016a7:	89 c2                	mov    %eax,%edx
  8016a9:	83 c4 10             	add    $0x10,%esp
  8016ac:	eb 09                	jmp    8016b7 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ae:	89 c2                	mov    %eax,%edx
  8016b0:	eb 05                	jmp    8016b7 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016b2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016b7:	89 d0                	mov    %edx,%eax
  8016b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016bc:	c9                   	leave  
  8016bd:	c3                   	ret    

008016be <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016be:	55                   	push   %ebp
  8016bf:	89 e5                	mov    %esp,%ebp
  8016c1:	56                   	push   %esi
  8016c2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016c3:	83 ec 08             	sub    $0x8,%esp
  8016c6:	6a 00                	push   $0x0
  8016c8:	ff 75 08             	pushl  0x8(%ebp)
  8016cb:	e8 e3 01 00 00       	call   8018b3 <open>
  8016d0:	89 c3                	mov    %eax,%ebx
  8016d2:	83 c4 10             	add    $0x10,%esp
  8016d5:	85 c0                	test   %eax,%eax
  8016d7:	78 1b                	js     8016f4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016d9:	83 ec 08             	sub    $0x8,%esp
  8016dc:	ff 75 0c             	pushl  0xc(%ebp)
  8016df:	50                   	push   %eax
  8016e0:	e8 5b ff ff ff       	call   801640 <fstat>
  8016e5:	89 c6                	mov    %eax,%esi
	close(fd);
  8016e7:	89 1c 24             	mov    %ebx,(%esp)
  8016ea:	e8 fd fb ff ff       	call   8012ec <close>
	return r;
  8016ef:	83 c4 10             	add    $0x10,%esp
  8016f2:	89 f0                	mov    %esi,%eax
}
  8016f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016f7:	5b                   	pop    %ebx
  8016f8:	5e                   	pop    %esi
  8016f9:	5d                   	pop    %ebp
  8016fa:	c3                   	ret    

008016fb <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016fb:	55                   	push   %ebp
  8016fc:	89 e5                	mov    %esp,%ebp
  8016fe:	56                   	push   %esi
  8016ff:	53                   	push   %ebx
  801700:	89 c6                	mov    %eax,%esi
  801702:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801704:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80170b:	75 12                	jne    80171f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80170d:	83 ec 0c             	sub    $0xc,%esp
  801710:	6a 01                	push   $0x1
  801712:	e8 f9 07 00 00       	call   801f10 <ipc_find_env>
  801717:	a3 00 40 80 00       	mov    %eax,0x804000
  80171c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80171f:	6a 07                	push   $0x7
  801721:	68 00 50 80 00       	push   $0x805000
  801726:	56                   	push   %esi
  801727:	ff 35 00 40 80 00    	pushl  0x804000
  80172d:	e8 7c 07 00 00       	call   801eae <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801732:	83 c4 0c             	add    $0xc,%esp
  801735:	6a 00                	push   $0x0
  801737:	53                   	push   %ebx
  801738:	6a 00                	push   $0x0
  80173a:	e8 f7 06 00 00       	call   801e36 <ipc_recv>
}
  80173f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801742:	5b                   	pop    %ebx
  801743:	5e                   	pop    %esi
  801744:	5d                   	pop    %ebp
  801745:	c3                   	ret    

00801746 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801746:	55                   	push   %ebp
  801747:	89 e5                	mov    %esp,%ebp
  801749:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80174c:	8b 45 08             	mov    0x8(%ebp),%eax
  80174f:	8b 40 0c             	mov    0xc(%eax),%eax
  801752:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801757:	8b 45 0c             	mov    0xc(%ebp),%eax
  80175a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80175f:	ba 00 00 00 00       	mov    $0x0,%edx
  801764:	b8 02 00 00 00       	mov    $0x2,%eax
  801769:	e8 8d ff ff ff       	call   8016fb <fsipc>
}
  80176e:	c9                   	leave  
  80176f:	c3                   	ret    

00801770 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801770:	55                   	push   %ebp
  801771:	89 e5                	mov    %esp,%ebp
  801773:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801776:	8b 45 08             	mov    0x8(%ebp),%eax
  801779:	8b 40 0c             	mov    0xc(%eax),%eax
  80177c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801781:	ba 00 00 00 00       	mov    $0x0,%edx
  801786:	b8 06 00 00 00       	mov    $0x6,%eax
  80178b:	e8 6b ff ff ff       	call   8016fb <fsipc>
}
  801790:	c9                   	leave  
  801791:	c3                   	ret    

00801792 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801792:	55                   	push   %ebp
  801793:	89 e5                	mov    %esp,%ebp
  801795:	53                   	push   %ebx
  801796:	83 ec 04             	sub    $0x4,%esp
  801799:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80179c:	8b 45 08             	mov    0x8(%ebp),%eax
  80179f:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ac:	b8 05 00 00 00       	mov    $0x5,%eax
  8017b1:	e8 45 ff ff ff       	call   8016fb <fsipc>
  8017b6:	85 c0                	test   %eax,%eax
  8017b8:	78 2c                	js     8017e6 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017ba:	83 ec 08             	sub    $0x8,%esp
  8017bd:	68 00 50 80 00       	push   $0x805000
  8017c2:	53                   	push   %ebx
  8017c3:	e8 cf ef ff ff       	call   800797 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017c8:	a1 80 50 80 00       	mov    0x805080,%eax
  8017cd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017d3:	a1 84 50 80 00       	mov    0x805084,%eax
  8017d8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017de:	83 c4 10             	add    $0x10,%esp
  8017e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e9:	c9                   	leave  
  8017ea:	c3                   	ret    

008017eb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017eb:	55                   	push   %ebp
  8017ec:	89 e5                	mov    %esp,%ebp
  8017ee:	83 ec 0c             	sub    $0xc,%esp
  8017f1:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8017f7:	8b 52 0c             	mov    0xc(%edx),%edx
  8017fa:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801800:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801805:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80180a:	0f 47 c2             	cmova  %edx,%eax
  80180d:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801812:	50                   	push   %eax
  801813:	ff 75 0c             	pushl  0xc(%ebp)
  801816:	68 08 50 80 00       	push   $0x805008
  80181b:	e8 09 f1 ff ff       	call   800929 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801820:	ba 00 00 00 00       	mov    $0x0,%edx
  801825:	b8 04 00 00 00       	mov    $0x4,%eax
  80182a:	e8 cc fe ff ff       	call   8016fb <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80182f:	c9                   	leave  
  801830:	c3                   	ret    

00801831 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801831:	55                   	push   %ebp
  801832:	89 e5                	mov    %esp,%ebp
  801834:	56                   	push   %esi
  801835:	53                   	push   %ebx
  801836:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801839:	8b 45 08             	mov    0x8(%ebp),%eax
  80183c:	8b 40 0c             	mov    0xc(%eax),%eax
  80183f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801844:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80184a:	ba 00 00 00 00       	mov    $0x0,%edx
  80184f:	b8 03 00 00 00       	mov    $0x3,%eax
  801854:	e8 a2 fe ff ff       	call   8016fb <fsipc>
  801859:	89 c3                	mov    %eax,%ebx
  80185b:	85 c0                	test   %eax,%eax
  80185d:	78 4b                	js     8018aa <devfile_read+0x79>
		return r;
	assert(r <= n);
  80185f:	39 c6                	cmp    %eax,%esi
  801861:	73 16                	jae    801879 <devfile_read+0x48>
  801863:	68 08 27 80 00       	push   $0x802708
  801868:	68 0f 27 80 00       	push   $0x80270f
  80186d:	6a 7c                	push   $0x7c
  80186f:	68 24 27 80 00       	push   $0x802724
  801874:	e8 c0 e8 ff ff       	call   800139 <_panic>
	assert(r <= PGSIZE);
  801879:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80187e:	7e 16                	jle    801896 <devfile_read+0x65>
  801880:	68 2f 27 80 00       	push   $0x80272f
  801885:	68 0f 27 80 00       	push   $0x80270f
  80188a:	6a 7d                	push   $0x7d
  80188c:	68 24 27 80 00       	push   $0x802724
  801891:	e8 a3 e8 ff ff       	call   800139 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801896:	83 ec 04             	sub    $0x4,%esp
  801899:	50                   	push   %eax
  80189a:	68 00 50 80 00       	push   $0x805000
  80189f:	ff 75 0c             	pushl  0xc(%ebp)
  8018a2:	e8 82 f0 ff ff       	call   800929 <memmove>
	return r;
  8018a7:	83 c4 10             	add    $0x10,%esp
}
  8018aa:	89 d8                	mov    %ebx,%eax
  8018ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018af:	5b                   	pop    %ebx
  8018b0:	5e                   	pop    %esi
  8018b1:	5d                   	pop    %ebp
  8018b2:	c3                   	ret    

008018b3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018b3:	55                   	push   %ebp
  8018b4:	89 e5                	mov    %esp,%ebp
  8018b6:	53                   	push   %ebx
  8018b7:	83 ec 20             	sub    $0x20,%esp
  8018ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018bd:	53                   	push   %ebx
  8018be:	e8 9b ee ff ff       	call   80075e <strlen>
  8018c3:	83 c4 10             	add    $0x10,%esp
  8018c6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018cb:	7f 67                	jg     801934 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018cd:	83 ec 0c             	sub    $0xc,%esp
  8018d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d3:	50                   	push   %eax
  8018d4:	e8 9a f8 ff ff       	call   801173 <fd_alloc>
  8018d9:	83 c4 10             	add    $0x10,%esp
		return r;
  8018dc:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018de:	85 c0                	test   %eax,%eax
  8018e0:	78 57                	js     801939 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018e2:	83 ec 08             	sub    $0x8,%esp
  8018e5:	53                   	push   %ebx
  8018e6:	68 00 50 80 00       	push   $0x805000
  8018eb:	e8 a7 ee ff ff       	call   800797 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018f3:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018fb:	b8 01 00 00 00       	mov    $0x1,%eax
  801900:	e8 f6 fd ff ff       	call   8016fb <fsipc>
  801905:	89 c3                	mov    %eax,%ebx
  801907:	83 c4 10             	add    $0x10,%esp
  80190a:	85 c0                	test   %eax,%eax
  80190c:	79 14                	jns    801922 <open+0x6f>
		fd_close(fd, 0);
  80190e:	83 ec 08             	sub    $0x8,%esp
  801911:	6a 00                	push   $0x0
  801913:	ff 75 f4             	pushl  -0xc(%ebp)
  801916:	e8 50 f9 ff ff       	call   80126b <fd_close>
		return r;
  80191b:	83 c4 10             	add    $0x10,%esp
  80191e:	89 da                	mov    %ebx,%edx
  801920:	eb 17                	jmp    801939 <open+0x86>
	}

	return fd2num(fd);
  801922:	83 ec 0c             	sub    $0xc,%esp
  801925:	ff 75 f4             	pushl  -0xc(%ebp)
  801928:	e8 1f f8 ff ff       	call   80114c <fd2num>
  80192d:	89 c2                	mov    %eax,%edx
  80192f:	83 c4 10             	add    $0x10,%esp
  801932:	eb 05                	jmp    801939 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801934:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801939:	89 d0                	mov    %edx,%eax
  80193b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80193e:	c9                   	leave  
  80193f:	c3                   	ret    

00801940 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
  801943:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801946:	ba 00 00 00 00       	mov    $0x0,%edx
  80194b:	b8 08 00 00 00       	mov    $0x8,%eax
  801950:	e8 a6 fd ff ff       	call   8016fb <fsipc>
}
  801955:	c9                   	leave  
  801956:	c3                   	ret    

00801957 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801957:	55                   	push   %ebp
  801958:	89 e5                	mov    %esp,%ebp
  80195a:	56                   	push   %esi
  80195b:	53                   	push   %ebx
  80195c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80195f:	83 ec 0c             	sub    $0xc,%esp
  801962:	ff 75 08             	pushl  0x8(%ebp)
  801965:	e8 f2 f7 ff ff       	call   80115c <fd2data>
  80196a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80196c:	83 c4 08             	add    $0x8,%esp
  80196f:	68 3b 27 80 00       	push   $0x80273b
  801974:	53                   	push   %ebx
  801975:	e8 1d ee ff ff       	call   800797 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80197a:	8b 46 04             	mov    0x4(%esi),%eax
  80197d:	2b 06                	sub    (%esi),%eax
  80197f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801985:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80198c:	00 00 00 
	stat->st_dev = &devpipe;
  80198f:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801996:	30 80 00 
	return 0;
}
  801999:	b8 00 00 00 00       	mov    $0x0,%eax
  80199e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a1:	5b                   	pop    %ebx
  8019a2:	5e                   	pop    %esi
  8019a3:	5d                   	pop    %ebp
  8019a4:	c3                   	ret    

008019a5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019a5:	55                   	push   %ebp
  8019a6:	89 e5                	mov    %esp,%ebp
  8019a8:	53                   	push   %ebx
  8019a9:	83 ec 0c             	sub    $0xc,%esp
  8019ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019af:	53                   	push   %ebx
  8019b0:	6a 00                	push   $0x0
  8019b2:	e8 68 f2 ff ff       	call   800c1f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019b7:	89 1c 24             	mov    %ebx,(%esp)
  8019ba:	e8 9d f7 ff ff       	call   80115c <fd2data>
  8019bf:	83 c4 08             	add    $0x8,%esp
  8019c2:	50                   	push   %eax
  8019c3:	6a 00                	push   $0x0
  8019c5:	e8 55 f2 ff ff       	call   800c1f <sys_page_unmap>
}
  8019ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019cd:	c9                   	leave  
  8019ce:	c3                   	ret    

008019cf <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019cf:	55                   	push   %ebp
  8019d0:	89 e5                	mov    %esp,%ebp
  8019d2:	57                   	push   %edi
  8019d3:	56                   	push   %esi
  8019d4:	53                   	push   %ebx
  8019d5:	83 ec 1c             	sub    $0x1c,%esp
  8019d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019db:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019dd:	a1 04 40 80 00       	mov    0x804004,%eax
  8019e2:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019e5:	83 ec 0c             	sub    $0xc,%esp
  8019e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8019eb:	e8 60 05 00 00       	call   801f50 <pageref>
  8019f0:	89 c3                	mov    %eax,%ebx
  8019f2:	89 3c 24             	mov    %edi,(%esp)
  8019f5:	e8 56 05 00 00       	call   801f50 <pageref>
  8019fa:	83 c4 10             	add    $0x10,%esp
  8019fd:	39 c3                	cmp    %eax,%ebx
  8019ff:	0f 94 c1             	sete   %cl
  801a02:	0f b6 c9             	movzbl %cl,%ecx
  801a05:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a08:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a0e:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  801a11:	39 ce                	cmp    %ecx,%esi
  801a13:	74 1b                	je     801a30 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a15:	39 c3                	cmp    %eax,%ebx
  801a17:	75 c4                	jne    8019dd <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a19:	8b 42 64             	mov    0x64(%edx),%eax
  801a1c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a1f:	50                   	push   %eax
  801a20:	56                   	push   %esi
  801a21:	68 42 27 80 00       	push   $0x802742
  801a26:	e8 e7 e7 ff ff       	call   800212 <cprintf>
  801a2b:	83 c4 10             	add    $0x10,%esp
  801a2e:	eb ad                	jmp    8019dd <_pipeisclosed+0xe>
	}
}
  801a30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a36:	5b                   	pop    %ebx
  801a37:	5e                   	pop    %esi
  801a38:	5f                   	pop    %edi
  801a39:	5d                   	pop    %ebp
  801a3a:	c3                   	ret    

00801a3b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a3b:	55                   	push   %ebp
  801a3c:	89 e5                	mov    %esp,%ebp
  801a3e:	57                   	push   %edi
  801a3f:	56                   	push   %esi
  801a40:	53                   	push   %ebx
  801a41:	83 ec 28             	sub    $0x28,%esp
  801a44:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a47:	56                   	push   %esi
  801a48:	e8 0f f7 ff ff       	call   80115c <fd2data>
  801a4d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a4f:	83 c4 10             	add    $0x10,%esp
  801a52:	bf 00 00 00 00       	mov    $0x0,%edi
  801a57:	eb 4b                	jmp    801aa4 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a59:	89 da                	mov    %ebx,%edx
  801a5b:	89 f0                	mov    %esi,%eax
  801a5d:	e8 6d ff ff ff       	call   8019cf <_pipeisclosed>
  801a62:	85 c0                	test   %eax,%eax
  801a64:	75 48                	jne    801aae <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a66:	e8 10 f1 ff ff       	call   800b7b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a6b:	8b 43 04             	mov    0x4(%ebx),%eax
  801a6e:	8b 0b                	mov    (%ebx),%ecx
  801a70:	8d 51 20             	lea    0x20(%ecx),%edx
  801a73:	39 d0                	cmp    %edx,%eax
  801a75:	73 e2                	jae    801a59 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a7a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a7e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a81:	89 c2                	mov    %eax,%edx
  801a83:	c1 fa 1f             	sar    $0x1f,%edx
  801a86:	89 d1                	mov    %edx,%ecx
  801a88:	c1 e9 1b             	shr    $0x1b,%ecx
  801a8b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a8e:	83 e2 1f             	and    $0x1f,%edx
  801a91:	29 ca                	sub    %ecx,%edx
  801a93:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a97:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a9b:	83 c0 01             	add    $0x1,%eax
  801a9e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aa1:	83 c7 01             	add    $0x1,%edi
  801aa4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801aa7:	75 c2                	jne    801a6b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801aa9:	8b 45 10             	mov    0x10(%ebp),%eax
  801aac:	eb 05                	jmp    801ab3 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aae:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ab3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab6:	5b                   	pop    %ebx
  801ab7:	5e                   	pop    %esi
  801ab8:	5f                   	pop    %edi
  801ab9:	5d                   	pop    %ebp
  801aba:	c3                   	ret    

00801abb <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801abb:	55                   	push   %ebp
  801abc:	89 e5                	mov    %esp,%ebp
  801abe:	57                   	push   %edi
  801abf:	56                   	push   %esi
  801ac0:	53                   	push   %ebx
  801ac1:	83 ec 18             	sub    $0x18,%esp
  801ac4:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ac7:	57                   	push   %edi
  801ac8:	e8 8f f6 ff ff       	call   80115c <fd2data>
  801acd:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801acf:	83 c4 10             	add    $0x10,%esp
  801ad2:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ad7:	eb 3d                	jmp    801b16 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ad9:	85 db                	test   %ebx,%ebx
  801adb:	74 04                	je     801ae1 <devpipe_read+0x26>
				return i;
  801add:	89 d8                	mov    %ebx,%eax
  801adf:	eb 44                	jmp    801b25 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ae1:	89 f2                	mov    %esi,%edx
  801ae3:	89 f8                	mov    %edi,%eax
  801ae5:	e8 e5 fe ff ff       	call   8019cf <_pipeisclosed>
  801aea:	85 c0                	test   %eax,%eax
  801aec:	75 32                	jne    801b20 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801aee:	e8 88 f0 ff ff       	call   800b7b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801af3:	8b 06                	mov    (%esi),%eax
  801af5:	3b 46 04             	cmp    0x4(%esi),%eax
  801af8:	74 df                	je     801ad9 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801afa:	99                   	cltd   
  801afb:	c1 ea 1b             	shr    $0x1b,%edx
  801afe:	01 d0                	add    %edx,%eax
  801b00:	83 e0 1f             	and    $0x1f,%eax
  801b03:	29 d0                	sub    %edx,%eax
  801b05:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b0d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b10:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b13:	83 c3 01             	add    $0x1,%ebx
  801b16:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b19:	75 d8                	jne    801af3 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b1b:	8b 45 10             	mov    0x10(%ebp),%eax
  801b1e:	eb 05                	jmp    801b25 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b20:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b28:	5b                   	pop    %ebx
  801b29:	5e                   	pop    %esi
  801b2a:	5f                   	pop    %edi
  801b2b:	5d                   	pop    %ebp
  801b2c:	c3                   	ret    

00801b2d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b2d:	55                   	push   %ebp
  801b2e:	89 e5                	mov    %esp,%ebp
  801b30:	56                   	push   %esi
  801b31:	53                   	push   %ebx
  801b32:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b35:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b38:	50                   	push   %eax
  801b39:	e8 35 f6 ff ff       	call   801173 <fd_alloc>
  801b3e:	83 c4 10             	add    $0x10,%esp
  801b41:	89 c2                	mov    %eax,%edx
  801b43:	85 c0                	test   %eax,%eax
  801b45:	0f 88 2c 01 00 00    	js     801c77 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b4b:	83 ec 04             	sub    $0x4,%esp
  801b4e:	68 07 04 00 00       	push   $0x407
  801b53:	ff 75 f4             	pushl  -0xc(%ebp)
  801b56:	6a 00                	push   $0x0
  801b58:	e8 3d f0 ff ff       	call   800b9a <sys_page_alloc>
  801b5d:	83 c4 10             	add    $0x10,%esp
  801b60:	89 c2                	mov    %eax,%edx
  801b62:	85 c0                	test   %eax,%eax
  801b64:	0f 88 0d 01 00 00    	js     801c77 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b6a:	83 ec 0c             	sub    $0xc,%esp
  801b6d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b70:	50                   	push   %eax
  801b71:	e8 fd f5 ff ff       	call   801173 <fd_alloc>
  801b76:	89 c3                	mov    %eax,%ebx
  801b78:	83 c4 10             	add    $0x10,%esp
  801b7b:	85 c0                	test   %eax,%eax
  801b7d:	0f 88 e2 00 00 00    	js     801c65 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b83:	83 ec 04             	sub    $0x4,%esp
  801b86:	68 07 04 00 00       	push   $0x407
  801b8b:	ff 75 f0             	pushl  -0x10(%ebp)
  801b8e:	6a 00                	push   $0x0
  801b90:	e8 05 f0 ff ff       	call   800b9a <sys_page_alloc>
  801b95:	89 c3                	mov    %eax,%ebx
  801b97:	83 c4 10             	add    $0x10,%esp
  801b9a:	85 c0                	test   %eax,%eax
  801b9c:	0f 88 c3 00 00 00    	js     801c65 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ba2:	83 ec 0c             	sub    $0xc,%esp
  801ba5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba8:	e8 af f5 ff ff       	call   80115c <fd2data>
  801bad:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801baf:	83 c4 0c             	add    $0xc,%esp
  801bb2:	68 07 04 00 00       	push   $0x407
  801bb7:	50                   	push   %eax
  801bb8:	6a 00                	push   $0x0
  801bba:	e8 db ef ff ff       	call   800b9a <sys_page_alloc>
  801bbf:	89 c3                	mov    %eax,%ebx
  801bc1:	83 c4 10             	add    $0x10,%esp
  801bc4:	85 c0                	test   %eax,%eax
  801bc6:	0f 88 89 00 00 00    	js     801c55 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bcc:	83 ec 0c             	sub    $0xc,%esp
  801bcf:	ff 75 f0             	pushl  -0x10(%ebp)
  801bd2:	e8 85 f5 ff ff       	call   80115c <fd2data>
  801bd7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bde:	50                   	push   %eax
  801bdf:	6a 00                	push   $0x0
  801be1:	56                   	push   %esi
  801be2:	6a 00                	push   $0x0
  801be4:	e8 f4 ef ff ff       	call   800bdd <sys_page_map>
  801be9:	89 c3                	mov    %eax,%ebx
  801beb:	83 c4 20             	add    $0x20,%esp
  801bee:	85 c0                	test   %eax,%eax
  801bf0:	78 55                	js     801c47 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bf2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bfb:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c00:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c07:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c10:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c12:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c15:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c1c:	83 ec 0c             	sub    $0xc,%esp
  801c1f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c22:	e8 25 f5 ff ff       	call   80114c <fd2num>
  801c27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c2a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c2c:	83 c4 04             	add    $0x4,%esp
  801c2f:	ff 75 f0             	pushl  -0x10(%ebp)
  801c32:	e8 15 f5 ff ff       	call   80114c <fd2num>
  801c37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c3a:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801c3d:	83 c4 10             	add    $0x10,%esp
  801c40:	ba 00 00 00 00       	mov    $0x0,%edx
  801c45:	eb 30                	jmp    801c77 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c47:	83 ec 08             	sub    $0x8,%esp
  801c4a:	56                   	push   %esi
  801c4b:	6a 00                	push   $0x0
  801c4d:	e8 cd ef ff ff       	call   800c1f <sys_page_unmap>
  801c52:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c55:	83 ec 08             	sub    $0x8,%esp
  801c58:	ff 75 f0             	pushl  -0x10(%ebp)
  801c5b:	6a 00                	push   $0x0
  801c5d:	e8 bd ef ff ff       	call   800c1f <sys_page_unmap>
  801c62:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c65:	83 ec 08             	sub    $0x8,%esp
  801c68:	ff 75 f4             	pushl  -0xc(%ebp)
  801c6b:	6a 00                	push   $0x0
  801c6d:	e8 ad ef ff ff       	call   800c1f <sys_page_unmap>
  801c72:	83 c4 10             	add    $0x10,%esp
  801c75:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c77:	89 d0                	mov    %edx,%eax
  801c79:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c7c:	5b                   	pop    %ebx
  801c7d:	5e                   	pop    %esi
  801c7e:	5d                   	pop    %ebp
  801c7f:	c3                   	ret    

00801c80 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c80:	55                   	push   %ebp
  801c81:	89 e5                	mov    %esp,%ebp
  801c83:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c89:	50                   	push   %eax
  801c8a:	ff 75 08             	pushl  0x8(%ebp)
  801c8d:	e8 30 f5 ff ff       	call   8011c2 <fd_lookup>
  801c92:	83 c4 10             	add    $0x10,%esp
  801c95:	85 c0                	test   %eax,%eax
  801c97:	78 18                	js     801cb1 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c99:	83 ec 0c             	sub    $0xc,%esp
  801c9c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c9f:	e8 b8 f4 ff ff       	call   80115c <fd2data>
	return _pipeisclosed(fd, p);
  801ca4:	89 c2                	mov    %eax,%edx
  801ca6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca9:	e8 21 fd ff ff       	call   8019cf <_pipeisclosed>
  801cae:	83 c4 10             	add    $0x10,%esp
}
  801cb1:	c9                   	leave  
  801cb2:	c3                   	ret    

00801cb3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cb3:	55                   	push   %ebp
  801cb4:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cb6:	b8 00 00 00 00       	mov    $0x0,%eax
  801cbb:	5d                   	pop    %ebp
  801cbc:	c3                   	ret    

00801cbd <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cbd:	55                   	push   %ebp
  801cbe:	89 e5                	mov    %esp,%ebp
  801cc0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cc3:	68 5a 27 80 00       	push   $0x80275a
  801cc8:	ff 75 0c             	pushl  0xc(%ebp)
  801ccb:	e8 c7 ea ff ff       	call   800797 <strcpy>
	return 0;
}
  801cd0:	b8 00 00 00 00       	mov    $0x0,%eax
  801cd5:	c9                   	leave  
  801cd6:	c3                   	ret    

00801cd7 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cd7:	55                   	push   %ebp
  801cd8:	89 e5                	mov    %esp,%ebp
  801cda:	57                   	push   %edi
  801cdb:	56                   	push   %esi
  801cdc:	53                   	push   %ebx
  801cdd:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ce3:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ce8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cee:	eb 2d                	jmp    801d1d <devcons_write+0x46>
		m = n - tot;
  801cf0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801cf3:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801cf5:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801cf8:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801cfd:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d00:	83 ec 04             	sub    $0x4,%esp
  801d03:	53                   	push   %ebx
  801d04:	03 45 0c             	add    0xc(%ebp),%eax
  801d07:	50                   	push   %eax
  801d08:	57                   	push   %edi
  801d09:	e8 1b ec ff ff       	call   800929 <memmove>
		sys_cputs(buf, m);
  801d0e:	83 c4 08             	add    $0x8,%esp
  801d11:	53                   	push   %ebx
  801d12:	57                   	push   %edi
  801d13:	e8 c6 ed ff ff       	call   800ade <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d18:	01 de                	add    %ebx,%esi
  801d1a:	83 c4 10             	add    $0x10,%esp
  801d1d:	89 f0                	mov    %esi,%eax
  801d1f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d22:	72 cc                	jb     801cf0 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d27:	5b                   	pop    %ebx
  801d28:	5e                   	pop    %esi
  801d29:	5f                   	pop    %edi
  801d2a:	5d                   	pop    %ebp
  801d2b:	c3                   	ret    

00801d2c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d2c:	55                   	push   %ebp
  801d2d:	89 e5                	mov    %esp,%ebp
  801d2f:	83 ec 08             	sub    $0x8,%esp
  801d32:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d37:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d3b:	74 2a                	je     801d67 <devcons_read+0x3b>
  801d3d:	eb 05                	jmp    801d44 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d3f:	e8 37 ee ff ff       	call   800b7b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d44:	e8 b3 ed ff ff       	call   800afc <sys_cgetc>
  801d49:	85 c0                	test   %eax,%eax
  801d4b:	74 f2                	je     801d3f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d4d:	85 c0                	test   %eax,%eax
  801d4f:	78 16                	js     801d67 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d51:	83 f8 04             	cmp    $0x4,%eax
  801d54:	74 0c                	je     801d62 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d56:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d59:	88 02                	mov    %al,(%edx)
	return 1;
  801d5b:	b8 01 00 00 00       	mov    $0x1,%eax
  801d60:	eb 05                	jmp    801d67 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d62:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d67:	c9                   	leave  
  801d68:	c3                   	ret    

00801d69 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d69:	55                   	push   %ebp
  801d6a:	89 e5                	mov    %esp,%ebp
  801d6c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d72:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d75:	6a 01                	push   $0x1
  801d77:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d7a:	50                   	push   %eax
  801d7b:	e8 5e ed ff ff       	call   800ade <sys_cputs>
}
  801d80:	83 c4 10             	add    $0x10,%esp
  801d83:	c9                   	leave  
  801d84:	c3                   	ret    

00801d85 <getchar>:

int
getchar(void)
{
  801d85:	55                   	push   %ebp
  801d86:	89 e5                	mov    %esp,%ebp
  801d88:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d8b:	6a 01                	push   $0x1
  801d8d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d90:	50                   	push   %eax
  801d91:	6a 00                	push   $0x0
  801d93:	e8 90 f6 ff ff       	call   801428 <read>
	if (r < 0)
  801d98:	83 c4 10             	add    $0x10,%esp
  801d9b:	85 c0                	test   %eax,%eax
  801d9d:	78 0f                	js     801dae <getchar+0x29>
		return r;
	if (r < 1)
  801d9f:	85 c0                	test   %eax,%eax
  801da1:	7e 06                	jle    801da9 <getchar+0x24>
		return -E_EOF;
	return c;
  801da3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801da7:	eb 05                	jmp    801dae <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801da9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801dae:	c9                   	leave  
  801daf:	c3                   	ret    

00801db0 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801db0:	55                   	push   %ebp
  801db1:	89 e5                	mov    %esp,%ebp
  801db3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801db6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801db9:	50                   	push   %eax
  801dba:	ff 75 08             	pushl  0x8(%ebp)
  801dbd:	e8 00 f4 ff ff       	call   8011c2 <fd_lookup>
  801dc2:	83 c4 10             	add    $0x10,%esp
  801dc5:	85 c0                	test   %eax,%eax
  801dc7:	78 11                	js     801dda <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801dc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dcc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dd2:	39 10                	cmp    %edx,(%eax)
  801dd4:	0f 94 c0             	sete   %al
  801dd7:	0f b6 c0             	movzbl %al,%eax
}
  801dda:	c9                   	leave  
  801ddb:	c3                   	ret    

00801ddc <opencons>:

int
opencons(void)
{
  801ddc:	55                   	push   %ebp
  801ddd:	89 e5                	mov    %esp,%ebp
  801ddf:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801de2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de5:	50                   	push   %eax
  801de6:	e8 88 f3 ff ff       	call   801173 <fd_alloc>
  801deb:	83 c4 10             	add    $0x10,%esp
		return r;
  801dee:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801df0:	85 c0                	test   %eax,%eax
  801df2:	78 3e                	js     801e32 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801df4:	83 ec 04             	sub    $0x4,%esp
  801df7:	68 07 04 00 00       	push   $0x407
  801dfc:	ff 75 f4             	pushl  -0xc(%ebp)
  801dff:	6a 00                	push   $0x0
  801e01:	e8 94 ed ff ff       	call   800b9a <sys_page_alloc>
  801e06:	83 c4 10             	add    $0x10,%esp
		return r;
  801e09:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e0b:	85 c0                	test   %eax,%eax
  801e0d:	78 23                	js     801e32 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e0f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e18:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e1d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e24:	83 ec 0c             	sub    $0xc,%esp
  801e27:	50                   	push   %eax
  801e28:	e8 1f f3 ff ff       	call   80114c <fd2num>
  801e2d:	89 c2                	mov    %eax,%edx
  801e2f:	83 c4 10             	add    $0x10,%esp
}
  801e32:	89 d0                	mov    %edx,%eax
  801e34:	c9                   	leave  
  801e35:	c3                   	ret    

00801e36 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e36:	55                   	push   %ebp
  801e37:	89 e5                	mov    %esp,%ebp
  801e39:	56                   	push   %esi
  801e3a:	53                   	push   %ebx
  801e3b:	8b 75 08             	mov    0x8(%ebp),%esi
  801e3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e41:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e44:	85 c0                	test   %eax,%eax
  801e46:	75 12                	jne    801e5a <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e48:	83 ec 0c             	sub    $0xc,%esp
  801e4b:	68 00 00 c0 ee       	push   $0xeec00000
  801e50:	e8 f5 ee ff ff       	call   800d4a <sys_ipc_recv>
  801e55:	83 c4 10             	add    $0x10,%esp
  801e58:	eb 0c                	jmp    801e66 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e5a:	83 ec 0c             	sub    $0xc,%esp
  801e5d:	50                   	push   %eax
  801e5e:	e8 e7 ee ff ff       	call   800d4a <sys_ipc_recv>
  801e63:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e66:	85 f6                	test   %esi,%esi
  801e68:	0f 95 c1             	setne  %cl
  801e6b:	85 db                	test   %ebx,%ebx
  801e6d:	0f 95 c2             	setne  %dl
  801e70:	84 d1                	test   %dl,%cl
  801e72:	74 09                	je     801e7d <ipc_recv+0x47>
  801e74:	89 c2                	mov    %eax,%edx
  801e76:	c1 ea 1f             	shr    $0x1f,%edx
  801e79:	84 d2                	test   %dl,%dl
  801e7b:	75 2a                	jne    801ea7 <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e7d:	85 f6                	test   %esi,%esi
  801e7f:	74 0d                	je     801e8e <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e81:	a1 04 40 80 00       	mov    0x804004,%eax
  801e86:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801e8c:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e8e:	85 db                	test   %ebx,%ebx
  801e90:	74 0d                	je     801e9f <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e92:	a1 04 40 80 00       	mov    0x804004,%eax
  801e97:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  801e9d:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e9f:	a1 04 40 80 00       	mov    0x804004,%eax
  801ea4:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  801ea7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eaa:	5b                   	pop    %ebx
  801eab:	5e                   	pop    %esi
  801eac:	5d                   	pop    %ebp
  801ead:	c3                   	ret    

00801eae <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801eae:	55                   	push   %ebp
  801eaf:	89 e5                	mov    %esp,%ebp
  801eb1:	57                   	push   %edi
  801eb2:	56                   	push   %esi
  801eb3:	53                   	push   %ebx
  801eb4:	83 ec 0c             	sub    $0xc,%esp
  801eb7:	8b 7d 08             	mov    0x8(%ebp),%edi
  801eba:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ebd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801ec0:	85 db                	test   %ebx,%ebx
  801ec2:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ec7:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801eca:	ff 75 14             	pushl  0x14(%ebp)
  801ecd:	53                   	push   %ebx
  801ece:	56                   	push   %esi
  801ecf:	57                   	push   %edi
  801ed0:	e8 52 ee ff ff       	call   800d27 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801ed5:	89 c2                	mov    %eax,%edx
  801ed7:	c1 ea 1f             	shr    $0x1f,%edx
  801eda:	83 c4 10             	add    $0x10,%esp
  801edd:	84 d2                	test   %dl,%dl
  801edf:	74 17                	je     801ef8 <ipc_send+0x4a>
  801ee1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ee4:	74 12                	je     801ef8 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801ee6:	50                   	push   %eax
  801ee7:	68 66 27 80 00       	push   $0x802766
  801eec:	6a 47                	push   $0x47
  801eee:	68 74 27 80 00       	push   $0x802774
  801ef3:	e8 41 e2 ff ff       	call   800139 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801ef8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801efb:	75 07                	jne    801f04 <ipc_send+0x56>
			sys_yield();
  801efd:	e8 79 ec ff ff       	call   800b7b <sys_yield>
  801f02:	eb c6                	jmp    801eca <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801f04:	85 c0                	test   %eax,%eax
  801f06:	75 c2                	jne    801eca <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801f08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f0b:	5b                   	pop    %ebx
  801f0c:	5e                   	pop    %esi
  801f0d:	5f                   	pop    %edi
  801f0e:	5d                   	pop    %ebp
  801f0f:	c3                   	ret    

00801f10 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f10:	55                   	push   %ebp
  801f11:	89 e5                	mov    %esp,%ebp
  801f13:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f16:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f1b:	89 c2                	mov    %eax,%edx
  801f1d:	c1 e2 07             	shl    $0x7,%edx
  801f20:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  801f27:	8b 52 5c             	mov    0x5c(%edx),%edx
  801f2a:	39 ca                	cmp    %ecx,%edx
  801f2c:	75 11                	jne    801f3f <ipc_find_env+0x2f>
			return envs[i].env_id;
  801f2e:	89 c2                	mov    %eax,%edx
  801f30:	c1 e2 07             	shl    $0x7,%edx
  801f33:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801f3a:	8b 40 54             	mov    0x54(%eax),%eax
  801f3d:	eb 0f                	jmp    801f4e <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f3f:	83 c0 01             	add    $0x1,%eax
  801f42:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f47:	75 d2                	jne    801f1b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f49:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f4e:	5d                   	pop    %ebp
  801f4f:	c3                   	ret    

00801f50 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f50:	55                   	push   %ebp
  801f51:	89 e5                	mov    %esp,%ebp
  801f53:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f56:	89 d0                	mov    %edx,%eax
  801f58:	c1 e8 16             	shr    $0x16,%eax
  801f5b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f62:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f67:	f6 c1 01             	test   $0x1,%cl
  801f6a:	74 1d                	je     801f89 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f6c:	c1 ea 0c             	shr    $0xc,%edx
  801f6f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f76:	f6 c2 01             	test   $0x1,%dl
  801f79:	74 0e                	je     801f89 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f7b:	c1 ea 0c             	shr    $0xc,%edx
  801f7e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f85:	ef 
  801f86:	0f b7 c0             	movzwl %ax,%eax
}
  801f89:	5d                   	pop    %ebp
  801f8a:	c3                   	ret    
  801f8b:	66 90                	xchg   %ax,%ax
  801f8d:	66 90                	xchg   %ax,%ax
  801f8f:	90                   	nop

00801f90 <__udivdi3>:
  801f90:	55                   	push   %ebp
  801f91:	57                   	push   %edi
  801f92:	56                   	push   %esi
  801f93:	53                   	push   %ebx
  801f94:	83 ec 1c             	sub    $0x1c,%esp
  801f97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fa3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fa7:	85 f6                	test   %esi,%esi
  801fa9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fad:	89 ca                	mov    %ecx,%edx
  801faf:	89 f8                	mov    %edi,%eax
  801fb1:	75 3d                	jne    801ff0 <__udivdi3+0x60>
  801fb3:	39 cf                	cmp    %ecx,%edi
  801fb5:	0f 87 c5 00 00 00    	ja     802080 <__udivdi3+0xf0>
  801fbb:	85 ff                	test   %edi,%edi
  801fbd:	89 fd                	mov    %edi,%ebp
  801fbf:	75 0b                	jne    801fcc <__udivdi3+0x3c>
  801fc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fc6:	31 d2                	xor    %edx,%edx
  801fc8:	f7 f7                	div    %edi
  801fca:	89 c5                	mov    %eax,%ebp
  801fcc:	89 c8                	mov    %ecx,%eax
  801fce:	31 d2                	xor    %edx,%edx
  801fd0:	f7 f5                	div    %ebp
  801fd2:	89 c1                	mov    %eax,%ecx
  801fd4:	89 d8                	mov    %ebx,%eax
  801fd6:	89 cf                	mov    %ecx,%edi
  801fd8:	f7 f5                	div    %ebp
  801fda:	89 c3                	mov    %eax,%ebx
  801fdc:	89 d8                	mov    %ebx,%eax
  801fde:	89 fa                	mov    %edi,%edx
  801fe0:	83 c4 1c             	add    $0x1c,%esp
  801fe3:	5b                   	pop    %ebx
  801fe4:	5e                   	pop    %esi
  801fe5:	5f                   	pop    %edi
  801fe6:	5d                   	pop    %ebp
  801fe7:	c3                   	ret    
  801fe8:	90                   	nop
  801fe9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ff0:	39 ce                	cmp    %ecx,%esi
  801ff2:	77 74                	ja     802068 <__udivdi3+0xd8>
  801ff4:	0f bd fe             	bsr    %esi,%edi
  801ff7:	83 f7 1f             	xor    $0x1f,%edi
  801ffa:	0f 84 98 00 00 00    	je     802098 <__udivdi3+0x108>
  802000:	bb 20 00 00 00       	mov    $0x20,%ebx
  802005:	89 f9                	mov    %edi,%ecx
  802007:	89 c5                	mov    %eax,%ebp
  802009:	29 fb                	sub    %edi,%ebx
  80200b:	d3 e6                	shl    %cl,%esi
  80200d:	89 d9                	mov    %ebx,%ecx
  80200f:	d3 ed                	shr    %cl,%ebp
  802011:	89 f9                	mov    %edi,%ecx
  802013:	d3 e0                	shl    %cl,%eax
  802015:	09 ee                	or     %ebp,%esi
  802017:	89 d9                	mov    %ebx,%ecx
  802019:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80201d:	89 d5                	mov    %edx,%ebp
  80201f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802023:	d3 ed                	shr    %cl,%ebp
  802025:	89 f9                	mov    %edi,%ecx
  802027:	d3 e2                	shl    %cl,%edx
  802029:	89 d9                	mov    %ebx,%ecx
  80202b:	d3 e8                	shr    %cl,%eax
  80202d:	09 c2                	or     %eax,%edx
  80202f:	89 d0                	mov    %edx,%eax
  802031:	89 ea                	mov    %ebp,%edx
  802033:	f7 f6                	div    %esi
  802035:	89 d5                	mov    %edx,%ebp
  802037:	89 c3                	mov    %eax,%ebx
  802039:	f7 64 24 0c          	mull   0xc(%esp)
  80203d:	39 d5                	cmp    %edx,%ebp
  80203f:	72 10                	jb     802051 <__udivdi3+0xc1>
  802041:	8b 74 24 08          	mov    0x8(%esp),%esi
  802045:	89 f9                	mov    %edi,%ecx
  802047:	d3 e6                	shl    %cl,%esi
  802049:	39 c6                	cmp    %eax,%esi
  80204b:	73 07                	jae    802054 <__udivdi3+0xc4>
  80204d:	39 d5                	cmp    %edx,%ebp
  80204f:	75 03                	jne    802054 <__udivdi3+0xc4>
  802051:	83 eb 01             	sub    $0x1,%ebx
  802054:	31 ff                	xor    %edi,%edi
  802056:	89 d8                	mov    %ebx,%eax
  802058:	89 fa                	mov    %edi,%edx
  80205a:	83 c4 1c             	add    $0x1c,%esp
  80205d:	5b                   	pop    %ebx
  80205e:	5e                   	pop    %esi
  80205f:	5f                   	pop    %edi
  802060:	5d                   	pop    %ebp
  802061:	c3                   	ret    
  802062:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802068:	31 ff                	xor    %edi,%edi
  80206a:	31 db                	xor    %ebx,%ebx
  80206c:	89 d8                	mov    %ebx,%eax
  80206e:	89 fa                	mov    %edi,%edx
  802070:	83 c4 1c             	add    $0x1c,%esp
  802073:	5b                   	pop    %ebx
  802074:	5e                   	pop    %esi
  802075:	5f                   	pop    %edi
  802076:	5d                   	pop    %ebp
  802077:	c3                   	ret    
  802078:	90                   	nop
  802079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802080:	89 d8                	mov    %ebx,%eax
  802082:	f7 f7                	div    %edi
  802084:	31 ff                	xor    %edi,%edi
  802086:	89 c3                	mov    %eax,%ebx
  802088:	89 d8                	mov    %ebx,%eax
  80208a:	89 fa                	mov    %edi,%edx
  80208c:	83 c4 1c             	add    $0x1c,%esp
  80208f:	5b                   	pop    %ebx
  802090:	5e                   	pop    %esi
  802091:	5f                   	pop    %edi
  802092:	5d                   	pop    %ebp
  802093:	c3                   	ret    
  802094:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802098:	39 ce                	cmp    %ecx,%esi
  80209a:	72 0c                	jb     8020a8 <__udivdi3+0x118>
  80209c:	31 db                	xor    %ebx,%ebx
  80209e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020a2:	0f 87 34 ff ff ff    	ja     801fdc <__udivdi3+0x4c>
  8020a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020ad:	e9 2a ff ff ff       	jmp    801fdc <__udivdi3+0x4c>
  8020b2:	66 90                	xchg   %ax,%ax
  8020b4:	66 90                	xchg   %ax,%ax
  8020b6:	66 90                	xchg   %ax,%ax
  8020b8:	66 90                	xchg   %ax,%ax
  8020ba:	66 90                	xchg   %ax,%ax
  8020bc:	66 90                	xchg   %ax,%ax
  8020be:	66 90                	xchg   %ax,%ax

008020c0 <__umoddi3>:
  8020c0:	55                   	push   %ebp
  8020c1:	57                   	push   %edi
  8020c2:	56                   	push   %esi
  8020c3:	53                   	push   %ebx
  8020c4:	83 ec 1c             	sub    $0x1c,%esp
  8020c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020d7:	85 d2                	test   %edx,%edx
  8020d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020e1:	89 f3                	mov    %esi,%ebx
  8020e3:	89 3c 24             	mov    %edi,(%esp)
  8020e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ea:	75 1c                	jne    802108 <__umoddi3+0x48>
  8020ec:	39 f7                	cmp    %esi,%edi
  8020ee:	76 50                	jbe    802140 <__umoddi3+0x80>
  8020f0:	89 c8                	mov    %ecx,%eax
  8020f2:	89 f2                	mov    %esi,%edx
  8020f4:	f7 f7                	div    %edi
  8020f6:	89 d0                	mov    %edx,%eax
  8020f8:	31 d2                	xor    %edx,%edx
  8020fa:	83 c4 1c             	add    $0x1c,%esp
  8020fd:	5b                   	pop    %ebx
  8020fe:	5e                   	pop    %esi
  8020ff:	5f                   	pop    %edi
  802100:	5d                   	pop    %ebp
  802101:	c3                   	ret    
  802102:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802108:	39 f2                	cmp    %esi,%edx
  80210a:	89 d0                	mov    %edx,%eax
  80210c:	77 52                	ja     802160 <__umoddi3+0xa0>
  80210e:	0f bd ea             	bsr    %edx,%ebp
  802111:	83 f5 1f             	xor    $0x1f,%ebp
  802114:	75 5a                	jne    802170 <__umoddi3+0xb0>
  802116:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80211a:	0f 82 e0 00 00 00    	jb     802200 <__umoddi3+0x140>
  802120:	39 0c 24             	cmp    %ecx,(%esp)
  802123:	0f 86 d7 00 00 00    	jbe    802200 <__umoddi3+0x140>
  802129:	8b 44 24 08          	mov    0x8(%esp),%eax
  80212d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802131:	83 c4 1c             	add    $0x1c,%esp
  802134:	5b                   	pop    %ebx
  802135:	5e                   	pop    %esi
  802136:	5f                   	pop    %edi
  802137:	5d                   	pop    %ebp
  802138:	c3                   	ret    
  802139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802140:	85 ff                	test   %edi,%edi
  802142:	89 fd                	mov    %edi,%ebp
  802144:	75 0b                	jne    802151 <__umoddi3+0x91>
  802146:	b8 01 00 00 00       	mov    $0x1,%eax
  80214b:	31 d2                	xor    %edx,%edx
  80214d:	f7 f7                	div    %edi
  80214f:	89 c5                	mov    %eax,%ebp
  802151:	89 f0                	mov    %esi,%eax
  802153:	31 d2                	xor    %edx,%edx
  802155:	f7 f5                	div    %ebp
  802157:	89 c8                	mov    %ecx,%eax
  802159:	f7 f5                	div    %ebp
  80215b:	89 d0                	mov    %edx,%eax
  80215d:	eb 99                	jmp    8020f8 <__umoddi3+0x38>
  80215f:	90                   	nop
  802160:	89 c8                	mov    %ecx,%eax
  802162:	89 f2                	mov    %esi,%edx
  802164:	83 c4 1c             	add    $0x1c,%esp
  802167:	5b                   	pop    %ebx
  802168:	5e                   	pop    %esi
  802169:	5f                   	pop    %edi
  80216a:	5d                   	pop    %ebp
  80216b:	c3                   	ret    
  80216c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802170:	8b 34 24             	mov    (%esp),%esi
  802173:	bf 20 00 00 00       	mov    $0x20,%edi
  802178:	89 e9                	mov    %ebp,%ecx
  80217a:	29 ef                	sub    %ebp,%edi
  80217c:	d3 e0                	shl    %cl,%eax
  80217e:	89 f9                	mov    %edi,%ecx
  802180:	89 f2                	mov    %esi,%edx
  802182:	d3 ea                	shr    %cl,%edx
  802184:	89 e9                	mov    %ebp,%ecx
  802186:	09 c2                	or     %eax,%edx
  802188:	89 d8                	mov    %ebx,%eax
  80218a:	89 14 24             	mov    %edx,(%esp)
  80218d:	89 f2                	mov    %esi,%edx
  80218f:	d3 e2                	shl    %cl,%edx
  802191:	89 f9                	mov    %edi,%ecx
  802193:	89 54 24 04          	mov    %edx,0x4(%esp)
  802197:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80219b:	d3 e8                	shr    %cl,%eax
  80219d:	89 e9                	mov    %ebp,%ecx
  80219f:	89 c6                	mov    %eax,%esi
  8021a1:	d3 e3                	shl    %cl,%ebx
  8021a3:	89 f9                	mov    %edi,%ecx
  8021a5:	89 d0                	mov    %edx,%eax
  8021a7:	d3 e8                	shr    %cl,%eax
  8021a9:	89 e9                	mov    %ebp,%ecx
  8021ab:	09 d8                	or     %ebx,%eax
  8021ad:	89 d3                	mov    %edx,%ebx
  8021af:	89 f2                	mov    %esi,%edx
  8021b1:	f7 34 24             	divl   (%esp)
  8021b4:	89 d6                	mov    %edx,%esi
  8021b6:	d3 e3                	shl    %cl,%ebx
  8021b8:	f7 64 24 04          	mull   0x4(%esp)
  8021bc:	39 d6                	cmp    %edx,%esi
  8021be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021c2:	89 d1                	mov    %edx,%ecx
  8021c4:	89 c3                	mov    %eax,%ebx
  8021c6:	72 08                	jb     8021d0 <__umoddi3+0x110>
  8021c8:	75 11                	jne    8021db <__umoddi3+0x11b>
  8021ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021ce:	73 0b                	jae    8021db <__umoddi3+0x11b>
  8021d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021d4:	1b 14 24             	sbb    (%esp),%edx
  8021d7:	89 d1                	mov    %edx,%ecx
  8021d9:	89 c3                	mov    %eax,%ebx
  8021db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021df:	29 da                	sub    %ebx,%edx
  8021e1:	19 ce                	sbb    %ecx,%esi
  8021e3:	89 f9                	mov    %edi,%ecx
  8021e5:	89 f0                	mov    %esi,%eax
  8021e7:	d3 e0                	shl    %cl,%eax
  8021e9:	89 e9                	mov    %ebp,%ecx
  8021eb:	d3 ea                	shr    %cl,%edx
  8021ed:	89 e9                	mov    %ebp,%ecx
  8021ef:	d3 ee                	shr    %cl,%esi
  8021f1:	09 d0                	or     %edx,%eax
  8021f3:	89 f2                	mov    %esi,%edx
  8021f5:	83 c4 1c             	add    $0x1c,%esp
  8021f8:	5b                   	pop    %ebx
  8021f9:	5e                   	pop    %esi
  8021fa:	5f                   	pop    %edi
  8021fb:	5d                   	pop    %ebp
  8021fc:	c3                   	ret    
  8021fd:	8d 76 00             	lea    0x0(%esi),%esi
  802200:	29 f9                	sub    %edi,%ecx
  802202:	19 d6                	sbb    %edx,%esi
  802204:	89 74 24 04          	mov    %esi,0x4(%esp)
  802208:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80220c:	e9 18 ff ff ff       	jmp    802129 <__umoddi3+0x69>
