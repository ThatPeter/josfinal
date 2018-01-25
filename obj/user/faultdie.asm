
obj/user/faultdie.debug:     file format elf32-i386


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
  80002c:	e8 4f 00 00 00       	call   800080 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
  800039:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003c:	8b 42 04             	mov    0x4(%edx),%eax
  80003f:	83 e0 07             	and    $0x7,%eax
  800042:	50                   	push   %eax
  800043:	ff 32                	pushl  (%edx)
  800045:	68 00 22 80 00       	push   $0x802200
  80004a:	e8 48 01 00 00       	call   800197 <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 8d 0a 00 00       	call   800ae1 <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 44 0a 00 00       	call   800aa0 <sys_env_destroy>
}
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800067:	68 33 00 80 00       	push   $0x800033
  80006c:	e8 df 0c 00 00       	call   800d50 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800071:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800078:	00 00 00 
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800088:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80008b:	e8 51 0a 00 00       	call   800ae1 <sys_getenvid>
  800090:	25 ff 03 00 00       	and    $0x3ff,%eax
  800095:	89 c2                	mov    %eax,%edx
  800097:	c1 e2 07             	shl    $0x7,%edx
  80009a:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8000a1:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a6:	85 db                	test   %ebx,%ebx
  8000a8:	7e 07                	jle    8000b1 <libmain+0x31>
		binaryname = argv[0];
  8000aa:	8b 06                	mov    (%esi),%eax
  8000ac:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000b1:	83 ec 08             	sub    $0x8,%esp
  8000b4:	56                   	push   %esi
  8000b5:	53                   	push   %ebx
  8000b6:	e8 a6 ff ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8000bb:	e8 2a 00 00 00       	call   8000ea <exit>
}
  8000c0:	83 c4 10             	add    $0x10,%esp
  8000c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c6:	5b                   	pop    %ebx
  8000c7:	5e                   	pop    %esi
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  8000d0:	a1 0c 40 80 00       	mov    0x80400c,%eax
	func();
  8000d5:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8000d7:	e8 05 0a 00 00       	call   800ae1 <sys_getenvid>
  8000dc:	83 ec 0c             	sub    $0xc,%esp
  8000df:	50                   	push   %eax
  8000e0:	e8 4b 0c 00 00       	call   800d30 <sys_thread_free>
}
  8000e5:	83 c4 10             	add    $0x10,%esp
  8000e8:	c9                   	leave  
  8000e9:	c3                   	ret    

008000ea <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ea:	55                   	push   %ebp
  8000eb:	89 e5                	mov    %esp,%ebp
  8000ed:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000f0:	e8 a7 11 00 00       	call   80129c <close_all>
	sys_env_destroy(0);
  8000f5:	83 ec 0c             	sub    $0xc,%esp
  8000f8:	6a 00                	push   $0x0
  8000fa:	e8 a1 09 00 00       	call   800aa0 <sys_env_destroy>
}
  8000ff:	83 c4 10             	add    $0x10,%esp
  800102:	c9                   	leave  
  800103:	c3                   	ret    

00800104 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	53                   	push   %ebx
  800108:	83 ec 04             	sub    $0x4,%esp
  80010b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010e:	8b 13                	mov    (%ebx),%edx
  800110:	8d 42 01             	lea    0x1(%edx),%eax
  800113:	89 03                	mov    %eax,(%ebx)
  800115:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800118:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80011c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800121:	75 1a                	jne    80013d <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800123:	83 ec 08             	sub    $0x8,%esp
  800126:	68 ff 00 00 00       	push   $0xff
  80012b:	8d 43 08             	lea    0x8(%ebx),%eax
  80012e:	50                   	push   %eax
  80012f:	e8 2f 09 00 00       	call   800a63 <sys_cputs>
		b->idx = 0;
  800134:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80013a:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80013d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800141:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800144:	c9                   	leave  
  800145:	c3                   	ret    

00800146 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80014f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800156:	00 00 00 
	b.cnt = 0;
  800159:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800160:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800163:	ff 75 0c             	pushl  0xc(%ebp)
  800166:	ff 75 08             	pushl  0x8(%ebp)
  800169:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016f:	50                   	push   %eax
  800170:	68 04 01 80 00       	push   $0x800104
  800175:	e8 54 01 00 00       	call   8002ce <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80017a:	83 c4 08             	add    $0x8,%esp
  80017d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800183:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800189:	50                   	push   %eax
  80018a:	e8 d4 08 00 00       	call   800a63 <sys_cputs>

	return b.cnt;
}
  80018f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800195:	c9                   	leave  
  800196:	c3                   	ret    

00800197 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a0:	50                   	push   %eax
  8001a1:	ff 75 08             	pushl  0x8(%ebp)
  8001a4:	e8 9d ff ff ff       	call   800146 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a9:	c9                   	leave  
  8001aa:	c3                   	ret    

008001ab <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	57                   	push   %edi
  8001af:	56                   	push   %esi
  8001b0:	53                   	push   %ebx
  8001b1:	83 ec 1c             	sub    $0x1c,%esp
  8001b4:	89 c7                	mov    %eax,%edi
  8001b6:	89 d6                	mov    %edx,%esi
  8001b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001c1:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001cc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001cf:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001d2:	39 d3                	cmp    %edx,%ebx
  8001d4:	72 05                	jb     8001db <printnum+0x30>
  8001d6:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d9:	77 45                	ja     800220 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001db:	83 ec 0c             	sub    $0xc,%esp
  8001de:	ff 75 18             	pushl  0x18(%ebp)
  8001e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8001e4:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001e7:	53                   	push   %ebx
  8001e8:	ff 75 10             	pushl  0x10(%ebp)
  8001eb:	83 ec 08             	sub    $0x8,%esp
  8001ee:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f1:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f4:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f7:	ff 75 d8             	pushl  -0x28(%ebp)
  8001fa:	e8 61 1d 00 00       	call   801f60 <__udivdi3>
  8001ff:	83 c4 18             	add    $0x18,%esp
  800202:	52                   	push   %edx
  800203:	50                   	push   %eax
  800204:	89 f2                	mov    %esi,%edx
  800206:	89 f8                	mov    %edi,%eax
  800208:	e8 9e ff ff ff       	call   8001ab <printnum>
  80020d:	83 c4 20             	add    $0x20,%esp
  800210:	eb 18                	jmp    80022a <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800212:	83 ec 08             	sub    $0x8,%esp
  800215:	56                   	push   %esi
  800216:	ff 75 18             	pushl  0x18(%ebp)
  800219:	ff d7                	call   *%edi
  80021b:	83 c4 10             	add    $0x10,%esp
  80021e:	eb 03                	jmp    800223 <printnum+0x78>
  800220:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800223:	83 eb 01             	sub    $0x1,%ebx
  800226:	85 db                	test   %ebx,%ebx
  800228:	7f e8                	jg     800212 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80022a:	83 ec 08             	sub    $0x8,%esp
  80022d:	56                   	push   %esi
  80022e:	83 ec 04             	sub    $0x4,%esp
  800231:	ff 75 e4             	pushl  -0x1c(%ebp)
  800234:	ff 75 e0             	pushl  -0x20(%ebp)
  800237:	ff 75 dc             	pushl  -0x24(%ebp)
  80023a:	ff 75 d8             	pushl  -0x28(%ebp)
  80023d:	e8 4e 1e 00 00       	call   802090 <__umoddi3>
  800242:	83 c4 14             	add    $0x14,%esp
  800245:	0f be 80 26 22 80 00 	movsbl 0x802226(%eax),%eax
  80024c:	50                   	push   %eax
  80024d:	ff d7                	call   *%edi
}
  80024f:	83 c4 10             	add    $0x10,%esp
  800252:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800255:	5b                   	pop    %ebx
  800256:	5e                   	pop    %esi
  800257:	5f                   	pop    %edi
  800258:	5d                   	pop    %ebp
  800259:	c3                   	ret    

0080025a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80025a:	55                   	push   %ebp
  80025b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80025d:	83 fa 01             	cmp    $0x1,%edx
  800260:	7e 0e                	jle    800270 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800262:	8b 10                	mov    (%eax),%edx
  800264:	8d 4a 08             	lea    0x8(%edx),%ecx
  800267:	89 08                	mov    %ecx,(%eax)
  800269:	8b 02                	mov    (%edx),%eax
  80026b:	8b 52 04             	mov    0x4(%edx),%edx
  80026e:	eb 22                	jmp    800292 <getuint+0x38>
	else if (lflag)
  800270:	85 d2                	test   %edx,%edx
  800272:	74 10                	je     800284 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800274:	8b 10                	mov    (%eax),%edx
  800276:	8d 4a 04             	lea    0x4(%edx),%ecx
  800279:	89 08                	mov    %ecx,(%eax)
  80027b:	8b 02                	mov    (%edx),%eax
  80027d:	ba 00 00 00 00       	mov    $0x0,%edx
  800282:	eb 0e                	jmp    800292 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800284:	8b 10                	mov    (%eax),%edx
  800286:	8d 4a 04             	lea    0x4(%edx),%ecx
  800289:	89 08                	mov    %ecx,(%eax)
  80028b:	8b 02                	mov    (%edx),%eax
  80028d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800292:	5d                   	pop    %ebp
  800293:	c3                   	ret    

00800294 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80029a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80029e:	8b 10                	mov    (%eax),%edx
  8002a0:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a3:	73 0a                	jae    8002af <sprintputch+0x1b>
		*b->buf++ = ch;
  8002a5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002a8:	89 08                	mov    %ecx,(%eax)
  8002aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ad:	88 02                	mov    %al,(%edx)
}
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ba:	50                   	push   %eax
  8002bb:	ff 75 10             	pushl  0x10(%ebp)
  8002be:	ff 75 0c             	pushl  0xc(%ebp)
  8002c1:	ff 75 08             	pushl  0x8(%ebp)
  8002c4:	e8 05 00 00 00       	call   8002ce <vprintfmt>
	va_end(ap);
}
  8002c9:	83 c4 10             	add    $0x10,%esp
  8002cc:	c9                   	leave  
  8002cd:	c3                   	ret    

008002ce <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	57                   	push   %edi
  8002d2:	56                   	push   %esi
  8002d3:	53                   	push   %ebx
  8002d4:	83 ec 2c             	sub    $0x2c,%esp
  8002d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8002da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002dd:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002e0:	eb 12                	jmp    8002f4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002e2:	85 c0                	test   %eax,%eax
  8002e4:	0f 84 89 03 00 00    	je     800673 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002ea:	83 ec 08             	sub    $0x8,%esp
  8002ed:	53                   	push   %ebx
  8002ee:	50                   	push   %eax
  8002ef:	ff d6                	call   *%esi
  8002f1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f4:	83 c7 01             	add    $0x1,%edi
  8002f7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002fb:	83 f8 25             	cmp    $0x25,%eax
  8002fe:	75 e2                	jne    8002e2 <vprintfmt+0x14>
  800300:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800304:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80030b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800312:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800319:	ba 00 00 00 00       	mov    $0x0,%edx
  80031e:	eb 07                	jmp    800327 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800320:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800323:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800327:	8d 47 01             	lea    0x1(%edi),%eax
  80032a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80032d:	0f b6 07             	movzbl (%edi),%eax
  800330:	0f b6 c8             	movzbl %al,%ecx
  800333:	83 e8 23             	sub    $0x23,%eax
  800336:	3c 55                	cmp    $0x55,%al
  800338:	0f 87 1a 03 00 00    	ja     800658 <vprintfmt+0x38a>
  80033e:	0f b6 c0             	movzbl %al,%eax
  800341:	ff 24 85 60 23 80 00 	jmp    *0x802360(,%eax,4)
  800348:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80034b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80034f:	eb d6                	jmp    800327 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800351:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800354:	b8 00 00 00 00       	mov    $0x0,%eax
  800359:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80035c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80035f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800363:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800366:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800369:	83 fa 09             	cmp    $0x9,%edx
  80036c:	77 39                	ja     8003a7 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80036e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800371:	eb e9                	jmp    80035c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800373:	8b 45 14             	mov    0x14(%ebp),%eax
  800376:	8d 48 04             	lea    0x4(%eax),%ecx
  800379:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80037c:	8b 00                	mov    (%eax),%eax
  80037e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800381:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800384:	eb 27                	jmp    8003ad <vprintfmt+0xdf>
  800386:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800389:	85 c0                	test   %eax,%eax
  80038b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800390:	0f 49 c8             	cmovns %eax,%ecx
  800393:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800396:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800399:	eb 8c                	jmp    800327 <vprintfmt+0x59>
  80039b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80039e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003a5:	eb 80                	jmp    800327 <vprintfmt+0x59>
  8003a7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003aa:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003ad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003b1:	0f 89 70 ff ff ff    	jns    800327 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003b7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003bd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003c4:	e9 5e ff ff ff       	jmp    800327 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003c9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003cf:	e9 53 ff ff ff       	jmp    800327 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d7:	8d 50 04             	lea    0x4(%eax),%edx
  8003da:	89 55 14             	mov    %edx,0x14(%ebp)
  8003dd:	83 ec 08             	sub    $0x8,%esp
  8003e0:	53                   	push   %ebx
  8003e1:	ff 30                	pushl  (%eax)
  8003e3:	ff d6                	call   *%esi
			break;
  8003e5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003eb:	e9 04 ff ff ff       	jmp    8002f4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f3:	8d 50 04             	lea    0x4(%eax),%edx
  8003f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f9:	8b 00                	mov    (%eax),%eax
  8003fb:	99                   	cltd   
  8003fc:	31 d0                	xor    %edx,%eax
  8003fe:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800400:	83 f8 0f             	cmp    $0xf,%eax
  800403:	7f 0b                	jg     800410 <vprintfmt+0x142>
  800405:	8b 14 85 c0 24 80 00 	mov    0x8024c0(,%eax,4),%edx
  80040c:	85 d2                	test   %edx,%edx
  80040e:	75 18                	jne    800428 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800410:	50                   	push   %eax
  800411:	68 3e 22 80 00       	push   $0x80223e
  800416:	53                   	push   %ebx
  800417:	56                   	push   %esi
  800418:	e8 94 fe ff ff       	call   8002b1 <printfmt>
  80041d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800420:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800423:	e9 cc fe ff ff       	jmp    8002f4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800428:	52                   	push   %edx
  800429:	68 7d 26 80 00       	push   $0x80267d
  80042e:	53                   	push   %ebx
  80042f:	56                   	push   %esi
  800430:	e8 7c fe ff ff       	call   8002b1 <printfmt>
  800435:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800438:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80043b:	e9 b4 fe ff ff       	jmp    8002f4 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 50 04             	lea    0x4(%eax),%edx
  800446:	89 55 14             	mov    %edx,0x14(%ebp)
  800449:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80044b:	85 ff                	test   %edi,%edi
  80044d:	b8 37 22 80 00       	mov    $0x802237,%eax
  800452:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800455:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800459:	0f 8e 94 00 00 00    	jle    8004f3 <vprintfmt+0x225>
  80045f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800463:	0f 84 98 00 00 00    	je     800501 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800469:	83 ec 08             	sub    $0x8,%esp
  80046c:	ff 75 d0             	pushl  -0x30(%ebp)
  80046f:	57                   	push   %edi
  800470:	e8 86 02 00 00       	call   8006fb <strnlen>
  800475:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800478:	29 c1                	sub    %eax,%ecx
  80047a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80047d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800480:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800484:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800487:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80048a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048c:	eb 0f                	jmp    80049d <vprintfmt+0x1cf>
					putch(padc, putdat);
  80048e:	83 ec 08             	sub    $0x8,%esp
  800491:	53                   	push   %ebx
  800492:	ff 75 e0             	pushl  -0x20(%ebp)
  800495:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800497:	83 ef 01             	sub    $0x1,%edi
  80049a:	83 c4 10             	add    $0x10,%esp
  80049d:	85 ff                	test   %edi,%edi
  80049f:	7f ed                	jg     80048e <vprintfmt+0x1c0>
  8004a1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004a4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004a7:	85 c9                	test   %ecx,%ecx
  8004a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ae:	0f 49 c1             	cmovns %ecx,%eax
  8004b1:	29 c1                	sub    %eax,%ecx
  8004b3:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004bc:	89 cb                	mov    %ecx,%ebx
  8004be:	eb 4d                	jmp    80050d <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004c0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004c4:	74 1b                	je     8004e1 <vprintfmt+0x213>
  8004c6:	0f be c0             	movsbl %al,%eax
  8004c9:	83 e8 20             	sub    $0x20,%eax
  8004cc:	83 f8 5e             	cmp    $0x5e,%eax
  8004cf:	76 10                	jbe    8004e1 <vprintfmt+0x213>
					putch('?', putdat);
  8004d1:	83 ec 08             	sub    $0x8,%esp
  8004d4:	ff 75 0c             	pushl  0xc(%ebp)
  8004d7:	6a 3f                	push   $0x3f
  8004d9:	ff 55 08             	call   *0x8(%ebp)
  8004dc:	83 c4 10             	add    $0x10,%esp
  8004df:	eb 0d                	jmp    8004ee <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004e1:	83 ec 08             	sub    $0x8,%esp
  8004e4:	ff 75 0c             	pushl  0xc(%ebp)
  8004e7:	52                   	push   %edx
  8004e8:	ff 55 08             	call   *0x8(%ebp)
  8004eb:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ee:	83 eb 01             	sub    $0x1,%ebx
  8004f1:	eb 1a                	jmp    80050d <vprintfmt+0x23f>
  8004f3:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004fc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ff:	eb 0c                	jmp    80050d <vprintfmt+0x23f>
  800501:	89 75 08             	mov    %esi,0x8(%ebp)
  800504:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800507:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80050a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80050d:	83 c7 01             	add    $0x1,%edi
  800510:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800514:	0f be d0             	movsbl %al,%edx
  800517:	85 d2                	test   %edx,%edx
  800519:	74 23                	je     80053e <vprintfmt+0x270>
  80051b:	85 f6                	test   %esi,%esi
  80051d:	78 a1                	js     8004c0 <vprintfmt+0x1f2>
  80051f:	83 ee 01             	sub    $0x1,%esi
  800522:	79 9c                	jns    8004c0 <vprintfmt+0x1f2>
  800524:	89 df                	mov    %ebx,%edi
  800526:	8b 75 08             	mov    0x8(%ebp),%esi
  800529:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80052c:	eb 18                	jmp    800546 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80052e:	83 ec 08             	sub    $0x8,%esp
  800531:	53                   	push   %ebx
  800532:	6a 20                	push   $0x20
  800534:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800536:	83 ef 01             	sub    $0x1,%edi
  800539:	83 c4 10             	add    $0x10,%esp
  80053c:	eb 08                	jmp    800546 <vprintfmt+0x278>
  80053e:	89 df                	mov    %ebx,%edi
  800540:	8b 75 08             	mov    0x8(%ebp),%esi
  800543:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800546:	85 ff                	test   %edi,%edi
  800548:	7f e4                	jg     80052e <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80054d:	e9 a2 fd ff ff       	jmp    8002f4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800552:	83 fa 01             	cmp    $0x1,%edx
  800555:	7e 16                	jle    80056d <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800557:	8b 45 14             	mov    0x14(%ebp),%eax
  80055a:	8d 50 08             	lea    0x8(%eax),%edx
  80055d:	89 55 14             	mov    %edx,0x14(%ebp)
  800560:	8b 50 04             	mov    0x4(%eax),%edx
  800563:	8b 00                	mov    (%eax),%eax
  800565:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800568:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80056b:	eb 32                	jmp    80059f <vprintfmt+0x2d1>
	else if (lflag)
  80056d:	85 d2                	test   %edx,%edx
  80056f:	74 18                	je     800589 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8d 50 04             	lea    0x4(%eax),%edx
  800577:	89 55 14             	mov    %edx,0x14(%ebp)
  80057a:	8b 00                	mov    (%eax),%eax
  80057c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057f:	89 c1                	mov    %eax,%ecx
  800581:	c1 f9 1f             	sar    $0x1f,%ecx
  800584:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800587:	eb 16                	jmp    80059f <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800589:	8b 45 14             	mov    0x14(%ebp),%eax
  80058c:	8d 50 04             	lea    0x4(%eax),%edx
  80058f:	89 55 14             	mov    %edx,0x14(%ebp)
  800592:	8b 00                	mov    (%eax),%eax
  800594:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800597:	89 c1                	mov    %eax,%ecx
  800599:	c1 f9 1f             	sar    $0x1f,%ecx
  80059c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80059f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005a2:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005aa:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ae:	79 74                	jns    800624 <vprintfmt+0x356>
				putch('-', putdat);
  8005b0:	83 ec 08             	sub    $0x8,%esp
  8005b3:	53                   	push   %ebx
  8005b4:	6a 2d                	push   $0x2d
  8005b6:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005bb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005be:	f7 d8                	neg    %eax
  8005c0:	83 d2 00             	adc    $0x0,%edx
  8005c3:	f7 da                	neg    %edx
  8005c5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005c8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005cd:	eb 55                	jmp    800624 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005cf:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d2:	e8 83 fc ff ff       	call   80025a <getuint>
			base = 10;
  8005d7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005dc:	eb 46                	jmp    800624 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005de:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e1:	e8 74 fc ff ff       	call   80025a <getuint>
			base = 8;
  8005e6:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005eb:	eb 37                	jmp    800624 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005ed:	83 ec 08             	sub    $0x8,%esp
  8005f0:	53                   	push   %ebx
  8005f1:	6a 30                	push   $0x30
  8005f3:	ff d6                	call   *%esi
			putch('x', putdat);
  8005f5:	83 c4 08             	add    $0x8,%esp
  8005f8:	53                   	push   %ebx
  8005f9:	6a 78                	push   $0x78
  8005fb:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800600:	8d 50 04             	lea    0x4(%eax),%edx
  800603:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800606:	8b 00                	mov    (%eax),%eax
  800608:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80060d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800610:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800615:	eb 0d                	jmp    800624 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800617:	8d 45 14             	lea    0x14(%ebp),%eax
  80061a:	e8 3b fc ff ff       	call   80025a <getuint>
			base = 16;
  80061f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800624:	83 ec 0c             	sub    $0xc,%esp
  800627:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80062b:	57                   	push   %edi
  80062c:	ff 75 e0             	pushl  -0x20(%ebp)
  80062f:	51                   	push   %ecx
  800630:	52                   	push   %edx
  800631:	50                   	push   %eax
  800632:	89 da                	mov    %ebx,%edx
  800634:	89 f0                	mov    %esi,%eax
  800636:	e8 70 fb ff ff       	call   8001ab <printnum>
			break;
  80063b:	83 c4 20             	add    $0x20,%esp
  80063e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800641:	e9 ae fc ff ff       	jmp    8002f4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800646:	83 ec 08             	sub    $0x8,%esp
  800649:	53                   	push   %ebx
  80064a:	51                   	push   %ecx
  80064b:	ff d6                	call   *%esi
			break;
  80064d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800650:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800653:	e9 9c fc ff ff       	jmp    8002f4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800658:	83 ec 08             	sub    $0x8,%esp
  80065b:	53                   	push   %ebx
  80065c:	6a 25                	push   $0x25
  80065e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800660:	83 c4 10             	add    $0x10,%esp
  800663:	eb 03                	jmp    800668 <vprintfmt+0x39a>
  800665:	83 ef 01             	sub    $0x1,%edi
  800668:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80066c:	75 f7                	jne    800665 <vprintfmt+0x397>
  80066e:	e9 81 fc ff ff       	jmp    8002f4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800673:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800676:	5b                   	pop    %ebx
  800677:	5e                   	pop    %esi
  800678:	5f                   	pop    %edi
  800679:	5d                   	pop    %ebp
  80067a:	c3                   	ret    

0080067b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80067b:	55                   	push   %ebp
  80067c:	89 e5                	mov    %esp,%ebp
  80067e:	83 ec 18             	sub    $0x18,%esp
  800681:	8b 45 08             	mov    0x8(%ebp),%eax
  800684:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800687:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80068a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80068e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800691:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800698:	85 c0                	test   %eax,%eax
  80069a:	74 26                	je     8006c2 <vsnprintf+0x47>
  80069c:	85 d2                	test   %edx,%edx
  80069e:	7e 22                	jle    8006c2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006a0:	ff 75 14             	pushl  0x14(%ebp)
  8006a3:	ff 75 10             	pushl  0x10(%ebp)
  8006a6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006a9:	50                   	push   %eax
  8006aa:	68 94 02 80 00       	push   $0x800294
  8006af:	e8 1a fc ff ff       	call   8002ce <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006b7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006bd:	83 c4 10             	add    $0x10,%esp
  8006c0:	eb 05                	jmp    8006c7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006c7:	c9                   	leave  
  8006c8:	c3                   	ret    

008006c9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006c9:	55                   	push   %ebp
  8006ca:	89 e5                	mov    %esp,%ebp
  8006cc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006cf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006d2:	50                   	push   %eax
  8006d3:	ff 75 10             	pushl  0x10(%ebp)
  8006d6:	ff 75 0c             	pushl  0xc(%ebp)
  8006d9:	ff 75 08             	pushl  0x8(%ebp)
  8006dc:	e8 9a ff ff ff       	call   80067b <vsnprintf>
	va_end(ap);

	return rc;
}
  8006e1:	c9                   	leave  
  8006e2:	c3                   	ret    

008006e3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e3:	55                   	push   %ebp
  8006e4:	89 e5                	mov    %esp,%ebp
  8006e6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ee:	eb 03                	jmp    8006f3 <strlen+0x10>
		n++;
  8006f0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006f7:	75 f7                	jne    8006f0 <strlen+0xd>
		n++;
	return n;
}
  8006f9:	5d                   	pop    %ebp
  8006fa:	c3                   	ret    

008006fb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006fb:	55                   	push   %ebp
  8006fc:	89 e5                	mov    %esp,%ebp
  8006fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800701:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800704:	ba 00 00 00 00       	mov    $0x0,%edx
  800709:	eb 03                	jmp    80070e <strnlen+0x13>
		n++;
  80070b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070e:	39 c2                	cmp    %eax,%edx
  800710:	74 08                	je     80071a <strnlen+0x1f>
  800712:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800716:	75 f3                	jne    80070b <strnlen+0x10>
  800718:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80071a:	5d                   	pop    %ebp
  80071b:	c3                   	ret    

0080071c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	53                   	push   %ebx
  800720:	8b 45 08             	mov    0x8(%ebp),%eax
  800723:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800726:	89 c2                	mov    %eax,%edx
  800728:	83 c2 01             	add    $0x1,%edx
  80072b:	83 c1 01             	add    $0x1,%ecx
  80072e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800732:	88 5a ff             	mov    %bl,-0x1(%edx)
  800735:	84 db                	test   %bl,%bl
  800737:	75 ef                	jne    800728 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800739:	5b                   	pop    %ebx
  80073a:	5d                   	pop    %ebp
  80073b:	c3                   	ret    

0080073c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	53                   	push   %ebx
  800740:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800743:	53                   	push   %ebx
  800744:	e8 9a ff ff ff       	call   8006e3 <strlen>
  800749:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80074c:	ff 75 0c             	pushl  0xc(%ebp)
  80074f:	01 d8                	add    %ebx,%eax
  800751:	50                   	push   %eax
  800752:	e8 c5 ff ff ff       	call   80071c <strcpy>
	return dst;
}
  800757:	89 d8                	mov    %ebx,%eax
  800759:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80075c:	c9                   	leave  
  80075d:	c3                   	ret    

0080075e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	56                   	push   %esi
  800762:	53                   	push   %ebx
  800763:	8b 75 08             	mov    0x8(%ebp),%esi
  800766:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800769:	89 f3                	mov    %esi,%ebx
  80076b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80076e:	89 f2                	mov    %esi,%edx
  800770:	eb 0f                	jmp    800781 <strncpy+0x23>
		*dst++ = *src;
  800772:	83 c2 01             	add    $0x1,%edx
  800775:	0f b6 01             	movzbl (%ecx),%eax
  800778:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80077b:	80 39 01             	cmpb   $0x1,(%ecx)
  80077e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800781:	39 da                	cmp    %ebx,%edx
  800783:	75 ed                	jne    800772 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800785:	89 f0                	mov    %esi,%eax
  800787:	5b                   	pop    %ebx
  800788:	5e                   	pop    %esi
  800789:	5d                   	pop    %ebp
  80078a:	c3                   	ret    

0080078b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	56                   	push   %esi
  80078f:	53                   	push   %ebx
  800790:	8b 75 08             	mov    0x8(%ebp),%esi
  800793:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800796:	8b 55 10             	mov    0x10(%ebp),%edx
  800799:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80079b:	85 d2                	test   %edx,%edx
  80079d:	74 21                	je     8007c0 <strlcpy+0x35>
  80079f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007a3:	89 f2                	mov    %esi,%edx
  8007a5:	eb 09                	jmp    8007b0 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007a7:	83 c2 01             	add    $0x1,%edx
  8007aa:	83 c1 01             	add    $0x1,%ecx
  8007ad:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007b0:	39 c2                	cmp    %eax,%edx
  8007b2:	74 09                	je     8007bd <strlcpy+0x32>
  8007b4:	0f b6 19             	movzbl (%ecx),%ebx
  8007b7:	84 db                	test   %bl,%bl
  8007b9:	75 ec                	jne    8007a7 <strlcpy+0x1c>
  8007bb:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007bd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007c0:	29 f0                	sub    %esi,%eax
}
  8007c2:	5b                   	pop    %ebx
  8007c3:	5e                   	pop    %esi
  8007c4:	5d                   	pop    %ebp
  8007c5:	c3                   	ret    

008007c6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007cc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007cf:	eb 06                	jmp    8007d7 <strcmp+0x11>
		p++, q++;
  8007d1:	83 c1 01             	add    $0x1,%ecx
  8007d4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007d7:	0f b6 01             	movzbl (%ecx),%eax
  8007da:	84 c0                	test   %al,%al
  8007dc:	74 04                	je     8007e2 <strcmp+0x1c>
  8007de:	3a 02                	cmp    (%edx),%al
  8007e0:	74 ef                	je     8007d1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007e2:	0f b6 c0             	movzbl %al,%eax
  8007e5:	0f b6 12             	movzbl (%edx),%edx
  8007e8:	29 d0                	sub    %edx,%eax
}
  8007ea:	5d                   	pop    %ebp
  8007eb:	c3                   	ret    

008007ec <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	53                   	push   %ebx
  8007f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f6:	89 c3                	mov    %eax,%ebx
  8007f8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007fb:	eb 06                	jmp    800803 <strncmp+0x17>
		n--, p++, q++;
  8007fd:	83 c0 01             	add    $0x1,%eax
  800800:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800803:	39 d8                	cmp    %ebx,%eax
  800805:	74 15                	je     80081c <strncmp+0x30>
  800807:	0f b6 08             	movzbl (%eax),%ecx
  80080a:	84 c9                	test   %cl,%cl
  80080c:	74 04                	je     800812 <strncmp+0x26>
  80080e:	3a 0a                	cmp    (%edx),%cl
  800810:	74 eb                	je     8007fd <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800812:	0f b6 00             	movzbl (%eax),%eax
  800815:	0f b6 12             	movzbl (%edx),%edx
  800818:	29 d0                	sub    %edx,%eax
  80081a:	eb 05                	jmp    800821 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80081c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800821:	5b                   	pop    %ebx
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	8b 45 08             	mov    0x8(%ebp),%eax
  80082a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80082e:	eb 07                	jmp    800837 <strchr+0x13>
		if (*s == c)
  800830:	38 ca                	cmp    %cl,%dl
  800832:	74 0f                	je     800843 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800834:	83 c0 01             	add    $0x1,%eax
  800837:	0f b6 10             	movzbl (%eax),%edx
  80083a:	84 d2                	test   %dl,%dl
  80083c:	75 f2                	jne    800830 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80083e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	8b 45 08             	mov    0x8(%ebp),%eax
  80084b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084f:	eb 03                	jmp    800854 <strfind+0xf>
  800851:	83 c0 01             	add    $0x1,%eax
  800854:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800857:	38 ca                	cmp    %cl,%dl
  800859:	74 04                	je     80085f <strfind+0x1a>
  80085b:	84 d2                	test   %dl,%dl
  80085d:	75 f2                	jne    800851 <strfind+0xc>
			break;
	return (char *) s;
}
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	57                   	push   %edi
  800865:	56                   	push   %esi
  800866:	53                   	push   %ebx
  800867:	8b 7d 08             	mov    0x8(%ebp),%edi
  80086a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80086d:	85 c9                	test   %ecx,%ecx
  80086f:	74 36                	je     8008a7 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800871:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800877:	75 28                	jne    8008a1 <memset+0x40>
  800879:	f6 c1 03             	test   $0x3,%cl
  80087c:	75 23                	jne    8008a1 <memset+0x40>
		c &= 0xFF;
  80087e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800882:	89 d3                	mov    %edx,%ebx
  800884:	c1 e3 08             	shl    $0x8,%ebx
  800887:	89 d6                	mov    %edx,%esi
  800889:	c1 e6 18             	shl    $0x18,%esi
  80088c:	89 d0                	mov    %edx,%eax
  80088e:	c1 e0 10             	shl    $0x10,%eax
  800891:	09 f0                	or     %esi,%eax
  800893:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800895:	89 d8                	mov    %ebx,%eax
  800897:	09 d0                	or     %edx,%eax
  800899:	c1 e9 02             	shr    $0x2,%ecx
  80089c:	fc                   	cld    
  80089d:	f3 ab                	rep stos %eax,%es:(%edi)
  80089f:	eb 06                	jmp    8008a7 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a4:	fc                   	cld    
  8008a5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008a7:	89 f8                	mov    %edi,%eax
  8008a9:	5b                   	pop    %ebx
  8008aa:	5e                   	pop    %esi
  8008ab:	5f                   	pop    %edi
  8008ac:	5d                   	pop    %ebp
  8008ad:	c3                   	ret    

008008ae <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	57                   	push   %edi
  8008b2:	56                   	push   %esi
  8008b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008bc:	39 c6                	cmp    %eax,%esi
  8008be:	73 35                	jae    8008f5 <memmove+0x47>
  8008c0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008c3:	39 d0                	cmp    %edx,%eax
  8008c5:	73 2e                	jae    8008f5 <memmove+0x47>
		s += n;
		d += n;
  8008c7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ca:	89 d6                	mov    %edx,%esi
  8008cc:	09 fe                	or     %edi,%esi
  8008ce:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008d4:	75 13                	jne    8008e9 <memmove+0x3b>
  8008d6:	f6 c1 03             	test   $0x3,%cl
  8008d9:	75 0e                	jne    8008e9 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008db:	83 ef 04             	sub    $0x4,%edi
  8008de:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008e1:	c1 e9 02             	shr    $0x2,%ecx
  8008e4:	fd                   	std    
  8008e5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e7:	eb 09                	jmp    8008f2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008e9:	83 ef 01             	sub    $0x1,%edi
  8008ec:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008ef:	fd                   	std    
  8008f0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008f2:	fc                   	cld    
  8008f3:	eb 1d                	jmp    800912 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f5:	89 f2                	mov    %esi,%edx
  8008f7:	09 c2                	or     %eax,%edx
  8008f9:	f6 c2 03             	test   $0x3,%dl
  8008fc:	75 0f                	jne    80090d <memmove+0x5f>
  8008fe:	f6 c1 03             	test   $0x3,%cl
  800901:	75 0a                	jne    80090d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800903:	c1 e9 02             	shr    $0x2,%ecx
  800906:	89 c7                	mov    %eax,%edi
  800908:	fc                   	cld    
  800909:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090b:	eb 05                	jmp    800912 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80090d:	89 c7                	mov    %eax,%edi
  80090f:	fc                   	cld    
  800910:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800912:	5e                   	pop    %esi
  800913:	5f                   	pop    %edi
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800919:	ff 75 10             	pushl  0x10(%ebp)
  80091c:	ff 75 0c             	pushl  0xc(%ebp)
  80091f:	ff 75 08             	pushl  0x8(%ebp)
  800922:	e8 87 ff ff ff       	call   8008ae <memmove>
}
  800927:	c9                   	leave  
  800928:	c3                   	ret    

00800929 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	56                   	push   %esi
  80092d:	53                   	push   %ebx
  80092e:	8b 45 08             	mov    0x8(%ebp),%eax
  800931:	8b 55 0c             	mov    0xc(%ebp),%edx
  800934:	89 c6                	mov    %eax,%esi
  800936:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800939:	eb 1a                	jmp    800955 <memcmp+0x2c>
		if (*s1 != *s2)
  80093b:	0f b6 08             	movzbl (%eax),%ecx
  80093e:	0f b6 1a             	movzbl (%edx),%ebx
  800941:	38 d9                	cmp    %bl,%cl
  800943:	74 0a                	je     80094f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800945:	0f b6 c1             	movzbl %cl,%eax
  800948:	0f b6 db             	movzbl %bl,%ebx
  80094b:	29 d8                	sub    %ebx,%eax
  80094d:	eb 0f                	jmp    80095e <memcmp+0x35>
		s1++, s2++;
  80094f:	83 c0 01             	add    $0x1,%eax
  800952:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800955:	39 f0                	cmp    %esi,%eax
  800957:	75 e2                	jne    80093b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800959:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095e:	5b                   	pop    %ebx
  80095f:	5e                   	pop    %esi
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	53                   	push   %ebx
  800966:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800969:	89 c1                	mov    %eax,%ecx
  80096b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80096e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800972:	eb 0a                	jmp    80097e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800974:	0f b6 10             	movzbl (%eax),%edx
  800977:	39 da                	cmp    %ebx,%edx
  800979:	74 07                	je     800982 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80097b:	83 c0 01             	add    $0x1,%eax
  80097e:	39 c8                	cmp    %ecx,%eax
  800980:	72 f2                	jb     800974 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800982:	5b                   	pop    %ebx
  800983:	5d                   	pop    %ebp
  800984:	c3                   	ret    

00800985 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	57                   	push   %edi
  800989:	56                   	push   %esi
  80098a:	53                   	push   %ebx
  80098b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800991:	eb 03                	jmp    800996 <strtol+0x11>
		s++;
  800993:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800996:	0f b6 01             	movzbl (%ecx),%eax
  800999:	3c 20                	cmp    $0x20,%al
  80099b:	74 f6                	je     800993 <strtol+0xe>
  80099d:	3c 09                	cmp    $0x9,%al
  80099f:	74 f2                	je     800993 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009a1:	3c 2b                	cmp    $0x2b,%al
  8009a3:	75 0a                	jne    8009af <strtol+0x2a>
		s++;
  8009a5:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009a8:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ad:	eb 11                	jmp    8009c0 <strtol+0x3b>
  8009af:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009b4:	3c 2d                	cmp    $0x2d,%al
  8009b6:	75 08                	jne    8009c0 <strtol+0x3b>
		s++, neg = 1;
  8009b8:	83 c1 01             	add    $0x1,%ecx
  8009bb:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009c0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009c6:	75 15                	jne    8009dd <strtol+0x58>
  8009c8:	80 39 30             	cmpb   $0x30,(%ecx)
  8009cb:	75 10                	jne    8009dd <strtol+0x58>
  8009cd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009d1:	75 7c                	jne    800a4f <strtol+0xca>
		s += 2, base = 16;
  8009d3:	83 c1 02             	add    $0x2,%ecx
  8009d6:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009db:	eb 16                	jmp    8009f3 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009dd:	85 db                	test   %ebx,%ebx
  8009df:	75 12                	jne    8009f3 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009e1:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009e6:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e9:	75 08                	jne    8009f3 <strtol+0x6e>
		s++, base = 8;
  8009eb:	83 c1 01             	add    $0x1,%ecx
  8009ee:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009fb:	0f b6 11             	movzbl (%ecx),%edx
  8009fe:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a01:	89 f3                	mov    %esi,%ebx
  800a03:	80 fb 09             	cmp    $0x9,%bl
  800a06:	77 08                	ja     800a10 <strtol+0x8b>
			dig = *s - '0';
  800a08:	0f be d2             	movsbl %dl,%edx
  800a0b:	83 ea 30             	sub    $0x30,%edx
  800a0e:	eb 22                	jmp    800a32 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a10:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a13:	89 f3                	mov    %esi,%ebx
  800a15:	80 fb 19             	cmp    $0x19,%bl
  800a18:	77 08                	ja     800a22 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a1a:	0f be d2             	movsbl %dl,%edx
  800a1d:	83 ea 57             	sub    $0x57,%edx
  800a20:	eb 10                	jmp    800a32 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a22:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a25:	89 f3                	mov    %esi,%ebx
  800a27:	80 fb 19             	cmp    $0x19,%bl
  800a2a:	77 16                	ja     800a42 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a2c:	0f be d2             	movsbl %dl,%edx
  800a2f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a32:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a35:	7d 0b                	jge    800a42 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a37:	83 c1 01             	add    $0x1,%ecx
  800a3a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a3e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a40:	eb b9                	jmp    8009fb <strtol+0x76>

	if (endptr)
  800a42:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a46:	74 0d                	je     800a55 <strtol+0xd0>
		*endptr = (char *) s;
  800a48:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a4b:	89 0e                	mov    %ecx,(%esi)
  800a4d:	eb 06                	jmp    800a55 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4f:	85 db                	test   %ebx,%ebx
  800a51:	74 98                	je     8009eb <strtol+0x66>
  800a53:	eb 9e                	jmp    8009f3 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a55:	89 c2                	mov    %eax,%edx
  800a57:	f7 da                	neg    %edx
  800a59:	85 ff                	test   %edi,%edi
  800a5b:	0f 45 c2             	cmovne %edx,%eax
}
  800a5e:	5b                   	pop    %ebx
  800a5f:	5e                   	pop    %esi
  800a60:	5f                   	pop    %edi
  800a61:	5d                   	pop    %ebp
  800a62:	c3                   	ret    

00800a63 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	57                   	push   %edi
  800a67:	56                   	push   %esi
  800a68:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a69:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a71:	8b 55 08             	mov    0x8(%ebp),%edx
  800a74:	89 c3                	mov    %eax,%ebx
  800a76:	89 c7                	mov    %eax,%edi
  800a78:	89 c6                	mov    %eax,%esi
  800a7a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a7c:	5b                   	pop    %ebx
  800a7d:	5e                   	pop    %esi
  800a7e:	5f                   	pop    %edi
  800a7f:	5d                   	pop    %ebp
  800a80:	c3                   	ret    

00800a81 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	57                   	push   %edi
  800a85:	56                   	push   %esi
  800a86:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a87:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8c:	b8 01 00 00 00       	mov    $0x1,%eax
  800a91:	89 d1                	mov    %edx,%ecx
  800a93:	89 d3                	mov    %edx,%ebx
  800a95:	89 d7                	mov    %edx,%edi
  800a97:	89 d6                	mov    %edx,%esi
  800a99:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a9b:	5b                   	pop    %ebx
  800a9c:	5e                   	pop    %esi
  800a9d:	5f                   	pop    %edi
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	57                   	push   %edi
  800aa4:	56                   	push   %esi
  800aa5:	53                   	push   %ebx
  800aa6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aae:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab6:	89 cb                	mov    %ecx,%ebx
  800ab8:	89 cf                	mov    %ecx,%edi
  800aba:	89 ce                	mov    %ecx,%esi
  800abc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800abe:	85 c0                	test   %eax,%eax
  800ac0:	7e 17                	jle    800ad9 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ac2:	83 ec 0c             	sub    $0xc,%esp
  800ac5:	50                   	push   %eax
  800ac6:	6a 03                	push   $0x3
  800ac8:	68 1f 25 80 00       	push   $0x80251f
  800acd:	6a 23                	push   $0x23
  800acf:	68 3c 25 80 00       	push   $0x80253c
  800ad4:	e8 e2 12 00 00       	call   801dbb <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ad9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800adc:	5b                   	pop    %ebx
  800add:	5e                   	pop    %esi
  800ade:	5f                   	pop    %edi
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	57                   	push   %edi
  800ae5:	56                   	push   %esi
  800ae6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae7:	ba 00 00 00 00       	mov    $0x0,%edx
  800aec:	b8 02 00 00 00       	mov    $0x2,%eax
  800af1:	89 d1                	mov    %edx,%ecx
  800af3:	89 d3                	mov    %edx,%ebx
  800af5:	89 d7                	mov    %edx,%edi
  800af7:	89 d6                	mov    %edx,%esi
  800af9:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800afb:	5b                   	pop    %ebx
  800afc:	5e                   	pop    %esi
  800afd:	5f                   	pop    %edi
  800afe:	5d                   	pop    %ebp
  800aff:	c3                   	ret    

00800b00 <sys_yield>:

void
sys_yield(void)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	57                   	push   %edi
  800b04:	56                   	push   %esi
  800b05:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b06:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b10:	89 d1                	mov    %edx,%ecx
  800b12:	89 d3                	mov    %edx,%ebx
  800b14:	89 d7                	mov    %edx,%edi
  800b16:	89 d6                	mov    %edx,%esi
  800b18:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b1a:	5b                   	pop    %ebx
  800b1b:	5e                   	pop    %esi
  800b1c:	5f                   	pop    %edi
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    

00800b1f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	57                   	push   %edi
  800b23:	56                   	push   %esi
  800b24:	53                   	push   %ebx
  800b25:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b28:	be 00 00 00 00       	mov    $0x0,%esi
  800b2d:	b8 04 00 00 00       	mov    $0x4,%eax
  800b32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b35:	8b 55 08             	mov    0x8(%ebp),%edx
  800b38:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b3b:	89 f7                	mov    %esi,%edi
  800b3d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b3f:	85 c0                	test   %eax,%eax
  800b41:	7e 17                	jle    800b5a <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b43:	83 ec 0c             	sub    $0xc,%esp
  800b46:	50                   	push   %eax
  800b47:	6a 04                	push   $0x4
  800b49:	68 1f 25 80 00       	push   $0x80251f
  800b4e:	6a 23                	push   $0x23
  800b50:	68 3c 25 80 00       	push   $0x80253c
  800b55:	e8 61 12 00 00       	call   801dbb <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5d:	5b                   	pop    %ebx
  800b5e:	5e                   	pop    %esi
  800b5f:	5f                   	pop    %edi
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
  800b68:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6b:	b8 05 00 00 00       	mov    $0x5,%eax
  800b70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b73:	8b 55 08             	mov    0x8(%ebp),%edx
  800b76:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b79:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b7c:	8b 75 18             	mov    0x18(%ebp),%esi
  800b7f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b81:	85 c0                	test   %eax,%eax
  800b83:	7e 17                	jle    800b9c <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b85:	83 ec 0c             	sub    $0xc,%esp
  800b88:	50                   	push   %eax
  800b89:	6a 05                	push   $0x5
  800b8b:	68 1f 25 80 00       	push   $0x80251f
  800b90:	6a 23                	push   $0x23
  800b92:	68 3c 25 80 00       	push   $0x80253c
  800b97:	e8 1f 12 00 00       	call   801dbb <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5f                   	pop    %edi
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	57                   	push   %edi
  800ba8:	56                   	push   %esi
  800ba9:	53                   	push   %ebx
  800baa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bad:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb2:	b8 06 00 00 00       	mov    $0x6,%eax
  800bb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bba:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbd:	89 df                	mov    %ebx,%edi
  800bbf:	89 de                	mov    %ebx,%esi
  800bc1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc3:	85 c0                	test   %eax,%eax
  800bc5:	7e 17                	jle    800bde <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc7:	83 ec 0c             	sub    $0xc,%esp
  800bca:	50                   	push   %eax
  800bcb:	6a 06                	push   $0x6
  800bcd:	68 1f 25 80 00       	push   $0x80251f
  800bd2:	6a 23                	push   $0x23
  800bd4:	68 3c 25 80 00       	push   $0x80253c
  800bd9:	e8 dd 11 00 00       	call   801dbb <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be1:	5b                   	pop    %ebx
  800be2:	5e                   	pop    %esi
  800be3:	5f                   	pop    %edi
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    

00800be6 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	57                   	push   %edi
  800bea:	56                   	push   %esi
  800beb:	53                   	push   %ebx
  800bec:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bef:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf4:	b8 08 00 00 00       	mov    $0x8,%eax
  800bf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bff:	89 df                	mov    %ebx,%edi
  800c01:	89 de                	mov    %ebx,%esi
  800c03:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c05:	85 c0                	test   %eax,%eax
  800c07:	7e 17                	jle    800c20 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c09:	83 ec 0c             	sub    $0xc,%esp
  800c0c:	50                   	push   %eax
  800c0d:	6a 08                	push   $0x8
  800c0f:	68 1f 25 80 00       	push   $0x80251f
  800c14:	6a 23                	push   $0x23
  800c16:	68 3c 25 80 00       	push   $0x80253c
  800c1b:	e8 9b 11 00 00       	call   801dbb <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c23:	5b                   	pop    %ebx
  800c24:	5e                   	pop    %esi
  800c25:	5f                   	pop    %edi
  800c26:	5d                   	pop    %ebp
  800c27:	c3                   	ret    

00800c28 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c28:	55                   	push   %ebp
  800c29:	89 e5                	mov    %esp,%ebp
  800c2b:	57                   	push   %edi
  800c2c:	56                   	push   %esi
  800c2d:	53                   	push   %ebx
  800c2e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c31:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c36:	b8 09 00 00 00       	mov    $0x9,%eax
  800c3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c41:	89 df                	mov    %ebx,%edi
  800c43:	89 de                	mov    %ebx,%esi
  800c45:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c47:	85 c0                	test   %eax,%eax
  800c49:	7e 17                	jle    800c62 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4b:	83 ec 0c             	sub    $0xc,%esp
  800c4e:	50                   	push   %eax
  800c4f:	6a 09                	push   $0x9
  800c51:	68 1f 25 80 00       	push   $0x80251f
  800c56:	6a 23                	push   $0x23
  800c58:	68 3c 25 80 00       	push   $0x80253c
  800c5d:	e8 59 11 00 00       	call   801dbb <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c65:	5b                   	pop    %ebx
  800c66:	5e                   	pop    %esi
  800c67:	5f                   	pop    %edi
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    

00800c6a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	57                   	push   %edi
  800c6e:	56                   	push   %esi
  800c6f:	53                   	push   %ebx
  800c70:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c73:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c78:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c80:	8b 55 08             	mov    0x8(%ebp),%edx
  800c83:	89 df                	mov    %ebx,%edi
  800c85:	89 de                	mov    %ebx,%esi
  800c87:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c89:	85 c0                	test   %eax,%eax
  800c8b:	7e 17                	jle    800ca4 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8d:	83 ec 0c             	sub    $0xc,%esp
  800c90:	50                   	push   %eax
  800c91:	6a 0a                	push   $0xa
  800c93:	68 1f 25 80 00       	push   $0x80251f
  800c98:	6a 23                	push   $0x23
  800c9a:	68 3c 25 80 00       	push   $0x80253c
  800c9f:	e8 17 11 00 00       	call   801dbb <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ca4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca7:	5b                   	pop    %ebx
  800ca8:	5e                   	pop    %esi
  800ca9:	5f                   	pop    %edi
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    

00800cac <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	57                   	push   %edi
  800cb0:	56                   	push   %esi
  800cb1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb2:	be 00 00 00 00       	mov    $0x0,%esi
  800cb7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cca:	5b                   	pop    %ebx
  800ccb:	5e                   	pop    %esi
  800ccc:	5f                   	pop    %edi
  800ccd:	5d                   	pop    %ebp
  800cce:	c3                   	ret    

00800ccf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	57                   	push   %edi
  800cd3:	56                   	push   %esi
  800cd4:	53                   	push   %ebx
  800cd5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cdd:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ce2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce5:	89 cb                	mov    %ecx,%ebx
  800ce7:	89 cf                	mov    %ecx,%edi
  800ce9:	89 ce                	mov    %ecx,%esi
  800ceb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ced:	85 c0                	test   %eax,%eax
  800cef:	7e 17                	jle    800d08 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf1:	83 ec 0c             	sub    $0xc,%esp
  800cf4:	50                   	push   %eax
  800cf5:	6a 0d                	push   $0xd
  800cf7:	68 1f 25 80 00       	push   $0x80251f
  800cfc:	6a 23                	push   $0x23
  800cfe:	68 3c 25 80 00       	push   $0x80253c
  800d03:	e8 b3 10 00 00       	call   801dbb <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0b:	5b                   	pop    %ebx
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    

00800d10 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	57                   	push   %edi
  800d14:	56                   	push   %esi
  800d15:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d16:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d1b:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d20:	8b 55 08             	mov    0x8(%ebp),%edx
  800d23:	89 cb                	mov    %ecx,%ebx
  800d25:	89 cf                	mov    %ecx,%edi
  800d27:	89 ce                	mov    %ecx,%esi
  800d29:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	57                   	push   %edi
  800d34:	56                   	push   %esi
  800d35:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d36:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3b:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d40:	8b 55 08             	mov    0x8(%ebp),%edx
  800d43:	89 cb                	mov    %ecx,%ebx
  800d45:	89 cf                	mov    %ecx,%edi
  800d47:	89 ce                	mov    %ecx,%esi
  800d49:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800d4b:	5b                   	pop    %ebx
  800d4c:	5e                   	pop    %esi
  800d4d:	5f                   	pop    %edi
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d56:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800d5d:	75 2a                	jne    800d89 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  800d5f:	83 ec 04             	sub    $0x4,%esp
  800d62:	6a 07                	push   $0x7
  800d64:	68 00 f0 bf ee       	push   $0xeebff000
  800d69:	6a 00                	push   $0x0
  800d6b:	e8 af fd ff ff       	call   800b1f <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  800d70:	83 c4 10             	add    $0x10,%esp
  800d73:	85 c0                	test   %eax,%eax
  800d75:	79 12                	jns    800d89 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  800d77:	50                   	push   %eax
  800d78:	68 4a 25 80 00       	push   $0x80254a
  800d7d:	6a 23                	push   $0x23
  800d7f:	68 4e 25 80 00       	push   $0x80254e
  800d84:	e8 32 10 00 00       	call   801dbb <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d89:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8c:	a3 08 40 80 00       	mov    %eax,0x804008
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  800d91:	83 ec 08             	sub    $0x8,%esp
  800d94:	68 bb 0d 80 00       	push   $0x800dbb
  800d99:	6a 00                	push   $0x0
  800d9b:	e8 ca fe ff ff       	call   800c6a <sys_env_set_pgfault_upcall>
	if (r < 0) {
  800da0:	83 c4 10             	add    $0x10,%esp
  800da3:	85 c0                	test   %eax,%eax
  800da5:	79 12                	jns    800db9 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  800da7:	50                   	push   %eax
  800da8:	68 4a 25 80 00       	push   $0x80254a
  800dad:	6a 2c                	push   $0x2c
  800daf:	68 4e 25 80 00       	push   $0x80254e
  800db4:	e8 02 10 00 00       	call   801dbb <_panic>
	}
}
  800db9:	c9                   	leave  
  800dba:	c3                   	ret    

00800dbb <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800dbb:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800dbc:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800dc1:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800dc3:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  800dc6:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  800dca:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  800dcf:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  800dd3:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  800dd5:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  800dd8:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  800dd9:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  800ddc:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  800ddd:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800dde:	c3                   	ret    

00800ddf <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	53                   	push   %ebx
  800de3:	83 ec 04             	sub    $0x4,%esp
  800de6:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800de9:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800deb:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800def:	74 11                	je     800e02 <pgfault+0x23>
  800df1:	89 d8                	mov    %ebx,%eax
  800df3:	c1 e8 0c             	shr    $0xc,%eax
  800df6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dfd:	f6 c4 08             	test   $0x8,%ah
  800e00:	75 14                	jne    800e16 <pgfault+0x37>
		panic("faulting access");
  800e02:	83 ec 04             	sub    $0x4,%esp
  800e05:	68 5c 25 80 00       	push   $0x80255c
  800e0a:	6a 1e                	push   $0x1e
  800e0c:	68 6c 25 80 00       	push   $0x80256c
  800e11:	e8 a5 0f 00 00       	call   801dbb <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800e16:	83 ec 04             	sub    $0x4,%esp
  800e19:	6a 07                	push   $0x7
  800e1b:	68 00 f0 7f 00       	push   $0x7ff000
  800e20:	6a 00                	push   $0x0
  800e22:	e8 f8 fc ff ff       	call   800b1f <sys_page_alloc>
	if (r < 0) {
  800e27:	83 c4 10             	add    $0x10,%esp
  800e2a:	85 c0                	test   %eax,%eax
  800e2c:	79 12                	jns    800e40 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800e2e:	50                   	push   %eax
  800e2f:	68 77 25 80 00       	push   $0x802577
  800e34:	6a 2c                	push   $0x2c
  800e36:	68 6c 25 80 00       	push   $0x80256c
  800e3b:	e8 7b 0f 00 00       	call   801dbb <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e40:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e46:	83 ec 04             	sub    $0x4,%esp
  800e49:	68 00 10 00 00       	push   $0x1000
  800e4e:	53                   	push   %ebx
  800e4f:	68 00 f0 7f 00       	push   $0x7ff000
  800e54:	e8 bd fa ff ff       	call   800916 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e59:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e60:	53                   	push   %ebx
  800e61:	6a 00                	push   $0x0
  800e63:	68 00 f0 7f 00       	push   $0x7ff000
  800e68:	6a 00                	push   $0x0
  800e6a:	e8 f3 fc ff ff       	call   800b62 <sys_page_map>
	if (r < 0) {
  800e6f:	83 c4 20             	add    $0x20,%esp
  800e72:	85 c0                	test   %eax,%eax
  800e74:	79 12                	jns    800e88 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e76:	50                   	push   %eax
  800e77:	68 77 25 80 00       	push   $0x802577
  800e7c:	6a 33                	push   $0x33
  800e7e:	68 6c 25 80 00       	push   $0x80256c
  800e83:	e8 33 0f 00 00       	call   801dbb <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e88:	83 ec 08             	sub    $0x8,%esp
  800e8b:	68 00 f0 7f 00       	push   $0x7ff000
  800e90:	6a 00                	push   $0x0
  800e92:	e8 0d fd ff ff       	call   800ba4 <sys_page_unmap>
	if (r < 0) {
  800e97:	83 c4 10             	add    $0x10,%esp
  800e9a:	85 c0                	test   %eax,%eax
  800e9c:	79 12                	jns    800eb0 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e9e:	50                   	push   %eax
  800e9f:	68 77 25 80 00       	push   $0x802577
  800ea4:	6a 37                	push   $0x37
  800ea6:	68 6c 25 80 00       	push   $0x80256c
  800eab:	e8 0b 0f 00 00       	call   801dbb <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800eb0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eb3:	c9                   	leave  
  800eb4:	c3                   	ret    

00800eb5 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	57                   	push   %edi
  800eb9:	56                   	push   %esi
  800eba:	53                   	push   %ebx
  800ebb:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800ebe:	68 df 0d 80 00       	push   $0x800ddf
  800ec3:	e8 88 fe ff ff       	call   800d50 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ec8:	b8 07 00 00 00       	mov    $0x7,%eax
  800ecd:	cd 30                	int    $0x30
  800ecf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800ed2:	83 c4 10             	add    $0x10,%esp
  800ed5:	85 c0                	test   %eax,%eax
  800ed7:	79 17                	jns    800ef0 <fork+0x3b>
		panic("fork fault %e");
  800ed9:	83 ec 04             	sub    $0x4,%esp
  800edc:	68 90 25 80 00       	push   $0x802590
  800ee1:	68 84 00 00 00       	push   $0x84
  800ee6:	68 6c 25 80 00       	push   $0x80256c
  800eeb:	e8 cb 0e 00 00       	call   801dbb <_panic>
  800ef0:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800ef2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ef6:	75 25                	jne    800f1d <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ef8:	e8 e4 fb ff ff       	call   800ae1 <sys_getenvid>
  800efd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f02:	89 c2                	mov    %eax,%edx
  800f04:	c1 e2 07             	shl    $0x7,%edx
  800f07:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800f0e:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f13:	b8 00 00 00 00       	mov    $0x0,%eax
  800f18:	e9 61 01 00 00       	jmp    80107e <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800f1d:	83 ec 04             	sub    $0x4,%esp
  800f20:	6a 07                	push   $0x7
  800f22:	68 00 f0 bf ee       	push   $0xeebff000
  800f27:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f2a:	e8 f0 fb ff ff       	call   800b1f <sys_page_alloc>
  800f2f:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f32:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f37:	89 d8                	mov    %ebx,%eax
  800f39:	c1 e8 16             	shr    $0x16,%eax
  800f3c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f43:	a8 01                	test   $0x1,%al
  800f45:	0f 84 fc 00 00 00    	je     801047 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f4b:	89 d8                	mov    %ebx,%eax
  800f4d:	c1 e8 0c             	shr    $0xc,%eax
  800f50:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f57:	f6 c2 01             	test   $0x1,%dl
  800f5a:	0f 84 e7 00 00 00    	je     801047 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f60:	89 c6                	mov    %eax,%esi
  800f62:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f65:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f6c:	f6 c6 04             	test   $0x4,%dh
  800f6f:	74 39                	je     800faa <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f71:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f78:	83 ec 0c             	sub    $0xc,%esp
  800f7b:	25 07 0e 00 00       	and    $0xe07,%eax
  800f80:	50                   	push   %eax
  800f81:	56                   	push   %esi
  800f82:	57                   	push   %edi
  800f83:	56                   	push   %esi
  800f84:	6a 00                	push   $0x0
  800f86:	e8 d7 fb ff ff       	call   800b62 <sys_page_map>
		if (r < 0) {
  800f8b:	83 c4 20             	add    $0x20,%esp
  800f8e:	85 c0                	test   %eax,%eax
  800f90:	0f 89 b1 00 00 00    	jns    801047 <fork+0x192>
		    	panic("sys page map fault %e");
  800f96:	83 ec 04             	sub    $0x4,%esp
  800f99:	68 9e 25 80 00       	push   $0x80259e
  800f9e:	6a 54                	push   $0x54
  800fa0:	68 6c 25 80 00       	push   $0x80256c
  800fa5:	e8 11 0e 00 00       	call   801dbb <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800faa:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fb1:	f6 c2 02             	test   $0x2,%dl
  800fb4:	75 0c                	jne    800fc2 <fork+0x10d>
  800fb6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fbd:	f6 c4 08             	test   $0x8,%ah
  800fc0:	74 5b                	je     80101d <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800fc2:	83 ec 0c             	sub    $0xc,%esp
  800fc5:	68 05 08 00 00       	push   $0x805
  800fca:	56                   	push   %esi
  800fcb:	57                   	push   %edi
  800fcc:	56                   	push   %esi
  800fcd:	6a 00                	push   $0x0
  800fcf:	e8 8e fb ff ff       	call   800b62 <sys_page_map>
		if (r < 0) {
  800fd4:	83 c4 20             	add    $0x20,%esp
  800fd7:	85 c0                	test   %eax,%eax
  800fd9:	79 14                	jns    800fef <fork+0x13a>
		    	panic("sys page map fault %e");
  800fdb:	83 ec 04             	sub    $0x4,%esp
  800fde:	68 9e 25 80 00       	push   $0x80259e
  800fe3:	6a 5b                	push   $0x5b
  800fe5:	68 6c 25 80 00       	push   $0x80256c
  800fea:	e8 cc 0d 00 00       	call   801dbb <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800fef:	83 ec 0c             	sub    $0xc,%esp
  800ff2:	68 05 08 00 00       	push   $0x805
  800ff7:	56                   	push   %esi
  800ff8:	6a 00                	push   $0x0
  800ffa:	56                   	push   %esi
  800ffb:	6a 00                	push   $0x0
  800ffd:	e8 60 fb ff ff       	call   800b62 <sys_page_map>
		if (r < 0) {
  801002:	83 c4 20             	add    $0x20,%esp
  801005:	85 c0                	test   %eax,%eax
  801007:	79 3e                	jns    801047 <fork+0x192>
		    	panic("sys page map fault %e");
  801009:	83 ec 04             	sub    $0x4,%esp
  80100c:	68 9e 25 80 00       	push   $0x80259e
  801011:	6a 5f                	push   $0x5f
  801013:	68 6c 25 80 00       	push   $0x80256c
  801018:	e8 9e 0d 00 00       	call   801dbb <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80101d:	83 ec 0c             	sub    $0xc,%esp
  801020:	6a 05                	push   $0x5
  801022:	56                   	push   %esi
  801023:	57                   	push   %edi
  801024:	56                   	push   %esi
  801025:	6a 00                	push   $0x0
  801027:	e8 36 fb ff ff       	call   800b62 <sys_page_map>
		if (r < 0) {
  80102c:	83 c4 20             	add    $0x20,%esp
  80102f:	85 c0                	test   %eax,%eax
  801031:	79 14                	jns    801047 <fork+0x192>
		    	panic("sys page map fault %e");
  801033:	83 ec 04             	sub    $0x4,%esp
  801036:	68 9e 25 80 00       	push   $0x80259e
  80103b:	6a 64                	push   $0x64
  80103d:	68 6c 25 80 00       	push   $0x80256c
  801042:	e8 74 0d 00 00       	call   801dbb <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801047:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80104d:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801053:	0f 85 de fe ff ff    	jne    800f37 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801059:	a1 04 40 80 00       	mov    0x804004,%eax
  80105e:	8b 40 70             	mov    0x70(%eax),%eax
  801061:	83 ec 08             	sub    $0x8,%esp
  801064:	50                   	push   %eax
  801065:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801068:	57                   	push   %edi
  801069:	e8 fc fb ff ff       	call   800c6a <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80106e:	83 c4 08             	add    $0x8,%esp
  801071:	6a 02                	push   $0x2
  801073:	57                   	push   %edi
  801074:	e8 6d fb ff ff       	call   800be6 <sys_env_set_status>
	
	return envid;
  801079:	83 c4 10             	add    $0x10,%esp
  80107c:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80107e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801081:	5b                   	pop    %ebx
  801082:	5e                   	pop    %esi
  801083:	5f                   	pop    %edi
  801084:	5d                   	pop    %ebp
  801085:	c3                   	ret    

00801086 <sfork>:

envid_t
sfork(void)
{
  801086:	55                   	push   %ebp
  801087:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801089:	b8 00 00 00 00       	mov    $0x0,%eax
  80108e:	5d                   	pop    %ebp
  80108f:	c3                   	ret    

00801090 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	56                   	push   %esi
  801094:	53                   	push   %ebx
  801095:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801098:	89 1d 0c 40 80 00    	mov    %ebx,0x80400c
	cprintf("in fork.c thread create. func: %x\n", func);
  80109e:	83 ec 08             	sub    $0x8,%esp
  8010a1:	53                   	push   %ebx
  8010a2:	68 b4 25 80 00       	push   $0x8025b4
  8010a7:	e8 eb f0 ff ff       	call   800197 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8010ac:	c7 04 24 ca 00 80 00 	movl   $0x8000ca,(%esp)
  8010b3:	e8 58 fc ff ff       	call   800d10 <sys_thread_create>
  8010b8:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8010ba:	83 c4 08             	add    $0x8,%esp
  8010bd:	53                   	push   %ebx
  8010be:	68 b4 25 80 00       	push   $0x8025b4
  8010c3:	e8 cf f0 ff ff       	call   800197 <cprintf>
	return id;
	//return 0;
}
  8010c8:	89 f0                	mov    %esi,%eax
  8010ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010cd:	5b                   	pop    %ebx
  8010ce:	5e                   	pop    %esi
  8010cf:	5d                   	pop    %ebp
  8010d0:	c3                   	ret    

008010d1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010d1:	55                   	push   %ebp
  8010d2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d7:	05 00 00 00 30       	add    $0x30000000,%eax
  8010dc:	c1 e8 0c             	shr    $0xc,%eax
}
  8010df:	5d                   	pop    %ebp
  8010e0:	c3                   	ret    

008010e1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e7:	05 00 00 00 30       	add    $0x30000000,%eax
  8010ec:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010f1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010f6:	5d                   	pop    %ebp
  8010f7:	c3                   	ret    

008010f8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
  8010fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010fe:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801103:	89 c2                	mov    %eax,%edx
  801105:	c1 ea 16             	shr    $0x16,%edx
  801108:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80110f:	f6 c2 01             	test   $0x1,%dl
  801112:	74 11                	je     801125 <fd_alloc+0x2d>
  801114:	89 c2                	mov    %eax,%edx
  801116:	c1 ea 0c             	shr    $0xc,%edx
  801119:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801120:	f6 c2 01             	test   $0x1,%dl
  801123:	75 09                	jne    80112e <fd_alloc+0x36>
			*fd_store = fd;
  801125:	89 01                	mov    %eax,(%ecx)
			return 0;
  801127:	b8 00 00 00 00       	mov    $0x0,%eax
  80112c:	eb 17                	jmp    801145 <fd_alloc+0x4d>
  80112e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801133:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801138:	75 c9                	jne    801103 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80113a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801140:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801145:	5d                   	pop    %ebp
  801146:	c3                   	ret    

00801147 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801147:	55                   	push   %ebp
  801148:	89 e5                	mov    %esp,%ebp
  80114a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80114d:	83 f8 1f             	cmp    $0x1f,%eax
  801150:	77 36                	ja     801188 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801152:	c1 e0 0c             	shl    $0xc,%eax
  801155:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80115a:	89 c2                	mov    %eax,%edx
  80115c:	c1 ea 16             	shr    $0x16,%edx
  80115f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801166:	f6 c2 01             	test   $0x1,%dl
  801169:	74 24                	je     80118f <fd_lookup+0x48>
  80116b:	89 c2                	mov    %eax,%edx
  80116d:	c1 ea 0c             	shr    $0xc,%edx
  801170:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801177:	f6 c2 01             	test   $0x1,%dl
  80117a:	74 1a                	je     801196 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80117c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80117f:	89 02                	mov    %eax,(%edx)
	return 0;
  801181:	b8 00 00 00 00       	mov    $0x0,%eax
  801186:	eb 13                	jmp    80119b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801188:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80118d:	eb 0c                	jmp    80119b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80118f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801194:	eb 05                	jmp    80119b <fd_lookup+0x54>
  801196:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80119b:	5d                   	pop    %ebp
  80119c:	c3                   	ret    

0080119d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
  8011a0:	83 ec 08             	sub    $0x8,%esp
  8011a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011a6:	ba 54 26 80 00       	mov    $0x802654,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011ab:	eb 13                	jmp    8011c0 <dev_lookup+0x23>
  8011ad:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011b0:	39 08                	cmp    %ecx,(%eax)
  8011b2:	75 0c                	jne    8011c0 <dev_lookup+0x23>
			*dev = devtab[i];
  8011b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011be:	eb 2e                	jmp    8011ee <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011c0:	8b 02                	mov    (%edx),%eax
  8011c2:	85 c0                	test   %eax,%eax
  8011c4:	75 e7                	jne    8011ad <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011c6:	a1 04 40 80 00       	mov    0x804004,%eax
  8011cb:	8b 40 54             	mov    0x54(%eax),%eax
  8011ce:	83 ec 04             	sub    $0x4,%esp
  8011d1:	51                   	push   %ecx
  8011d2:	50                   	push   %eax
  8011d3:	68 d8 25 80 00       	push   $0x8025d8
  8011d8:	e8 ba ef ff ff       	call   800197 <cprintf>
	*dev = 0;
  8011dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011e0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011e6:	83 c4 10             	add    $0x10,%esp
  8011e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011ee:	c9                   	leave  
  8011ef:	c3                   	ret    

008011f0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	56                   	push   %esi
  8011f4:	53                   	push   %ebx
  8011f5:	83 ec 10             	sub    $0x10,%esp
  8011f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8011fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801201:	50                   	push   %eax
  801202:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801208:	c1 e8 0c             	shr    $0xc,%eax
  80120b:	50                   	push   %eax
  80120c:	e8 36 ff ff ff       	call   801147 <fd_lookup>
  801211:	83 c4 08             	add    $0x8,%esp
  801214:	85 c0                	test   %eax,%eax
  801216:	78 05                	js     80121d <fd_close+0x2d>
	    || fd != fd2)
  801218:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80121b:	74 0c                	je     801229 <fd_close+0x39>
		return (must_exist ? r : 0);
  80121d:	84 db                	test   %bl,%bl
  80121f:	ba 00 00 00 00       	mov    $0x0,%edx
  801224:	0f 44 c2             	cmove  %edx,%eax
  801227:	eb 41                	jmp    80126a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801229:	83 ec 08             	sub    $0x8,%esp
  80122c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80122f:	50                   	push   %eax
  801230:	ff 36                	pushl  (%esi)
  801232:	e8 66 ff ff ff       	call   80119d <dev_lookup>
  801237:	89 c3                	mov    %eax,%ebx
  801239:	83 c4 10             	add    $0x10,%esp
  80123c:	85 c0                	test   %eax,%eax
  80123e:	78 1a                	js     80125a <fd_close+0x6a>
		if (dev->dev_close)
  801240:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801243:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801246:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80124b:	85 c0                	test   %eax,%eax
  80124d:	74 0b                	je     80125a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80124f:	83 ec 0c             	sub    $0xc,%esp
  801252:	56                   	push   %esi
  801253:	ff d0                	call   *%eax
  801255:	89 c3                	mov    %eax,%ebx
  801257:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80125a:	83 ec 08             	sub    $0x8,%esp
  80125d:	56                   	push   %esi
  80125e:	6a 00                	push   $0x0
  801260:	e8 3f f9 ff ff       	call   800ba4 <sys_page_unmap>
	return r;
  801265:	83 c4 10             	add    $0x10,%esp
  801268:	89 d8                	mov    %ebx,%eax
}
  80126a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80126d:	5b                   	pop    %ebx
  80126e:	5e                   	pop    %esi
  80126f:	5d                   	pop    %ebp
  801270:	c3                   	ret    

00801271 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801271:	55                   	push   %ebp
  801272:	89 e5                	mov    %esp,%ebp
  801274:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801277:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127a:	50                   	push   %eax
  80127b:	ff 75 08             	pushl  0x8(%ebp)
  80127e:	e8 c4 fe ff ff       	call   801147 <fd_lookup>
  801283:	83 c4 08             	add    $0x8,%esp
  801286:	85 c0                	test   %eax,%eax
  801288:	78 10                	js     80129a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80128a:	83 ec 08             	sub    $0x8,%esp
  80128d:	6a 01                	push   $0x1
  80128f:	ff 75 f4             	pushl  -0xc(%ebp)
  801292:	e8 59 ff ff ff       	call   8011f0 <fd_close>
  801297:	83 c4 10             	add    $0x10,%esp
}
  80129a:	c9                   	leave  
  80129b:	c3                   	ret    

0080129c <close_all>:

void
close_all(void)
{
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
  80129f:	53                   	push   %ebx
  8012a0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012a3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012a8:	83 ec 0c             	sub    $0xc,%esp
  8012ab:	53                   	push   %ebx
  8012ac:	e8 c0 ff ff ff       	call   801271 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012b1:	83 c3 01             	add    $0x1,%ebx
  8012b4:	83 c4 10             	add    $0x10,%esp
  8012b7:	83 fb 20             	cmp    $0x20,%ebx
  8012ba:	75 ec                	jne    8012a8 <close_all+0xc>
		close(i);
}
  8012bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012bf:	c9                   	leave  
  8012c0:	c3                   	ret    

008012c1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012c1:	55                   	push   %ebp
  8012c2:	89 e5                	mov    %esp,%ebp
  8012c4:	57                   	push   %edi
  8012c5:	56                   	push   %esi
  8012c6:	53                   	push   %ebx
  8012c7:	83 ec 2c             	sub    $0x2c,%esp
  8012ca:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012cd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012d0:	50                   	push   %eax
  8012d1:	ff 75 08             	pushl  0x8(%ebp)
  8012d4:	e8 6e fe ff ff       	call   801147 <fd_lookup>
  8012d9:	83 c4 08             	add    $0x8,%esp
  8012dc:	85 c0                	test   %eax,%eax
  8012de:	0f 88 c1 00 00 00    	js     8013a5 <dup+0xe4>
		return r;
	close(newfdnum);
  8012e4:	83 ec 0c             	sub    $0xc,%esp
  8012e7:	56                   	push   %esi
  8012e8:	e8 84 ff ff ff       	call   801271 <close>

	newfd = INDEX2FD(newfdnum);
  8012ed:	89 f3                	mov    %esi,%ebx
  8012ef:	c1 e3 0c             	shl    $0xc,%ebx
  8012f2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012f8:	83 c4 04             	add    $0x4,%esp
  8012fb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012fe:	e8 de fd ff ff       	call   8010e1 <fd2data>
  801303:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801305:	89 1c 24             	mov    %ebx,(%esp)
  801308:	e8 d4 fd ff ff       	call   8010e1 <fd2data>
  80130d:	83 c4 10             	add    $0x10,%esp
  801310:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801313:	89 f8                	mov    %edi,%eax
  801315:	c1 e8 16             	shr    $0x16,%eax
  801318:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80131f:	a8 01                	test   $0x1,%al
  801321:	74 37                	je     80135a <dup+0x99>
  801323:	89 f8                	mov    %edi,%eax
  801325:	c1 e8 0c             	shr    $0xc,%eax
  801328:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80132f:	f6 c2 01             	test   $0x1,%dl
  801332:	74 26                	je     80135a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801334:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80133b:	83 ec 0c             	sub    $0xc,%esp
  80133e:	25 07 0e 00 00       	and    $0xe07,%eax
  801343:	50                   	push   %eax
  801344:	ff 75 d4             	pushl  -0x2c(%ebp)
  801347:	6a 00                	push   $0x0
  801349:	57                   	push   %edi
  80134a:	6a 00                	push   $0x0
  80134c:	e8 11 f8 ff ff       	call   800b62 <sys_page_map>
  801351:	89 c7                	mov    %eax,%edi
  801353:	83 c4 20             	add    $0x20,%esp
  801356:	85 c0                	test   %eax,%eax
  801358:	78 2e                	js     801388 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80135a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80135d:	89 d0                	mov    %edx,%eax
  80135f:	c1 e8 0c             	shr    $0xc,%eax
  801362:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801369:	83 ec 0c             	sub    $0xc,%esp
  80136c:	25 07 0e 00 00       	and    $0xe07,%eax
  801371:	50                   	push   %eax
  801372:	53                   	push   %ebx
  801373:	6a 00                	push   $0x0
  801375:	52                   	push   %edx
  801376:	6a 00                	push   $0x0
  801378:	e8 e5 f7 ff ff       	call   800b62 <sys_page_map>
  80137d:	89 c7                	mov    %eax,%edi
  80137f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801382:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801384:	85 ff                	test   %edi,%edi
  801386:	79 1d                	jns    8013a5 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801388:	83 ec 08             	sub    $0x8,%esp
  80138b:	53                   	push   %ebx
  80138c:	6a 00                	push   $0x0
  80138e:	e8 11 f8 ff ff       	call   800ba4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801393:	83 c4 08             	add    $0x8,%esp
  801396:	ff 75 d4             	pushl  -0x2c(%ebp)
  801399:	6a 00                	push   $0x0
  80139b:	e8 04 f8 ff ff       	call   800ba4 <sys_page_unmap>
	return r;
  8013a0:	83 c4 10             	add    $0x10,%esp
  8013a3:	89 f8                	mov    %edi,%eax
}
  8013a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013a8:	5b                   	pop    %ebx
  8013a9:	5e                   	pop    %esi
  8013aa:	5f                   	pop    %edi
  8013ab:	5d                   	pop    %ebp
  8013ac:	c3                   	ret    

008013ad <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013ad:	55                   	push   %ebp
  8013ae:	89 e5                	mov    %esp,%ebp
  8013b0:	53                   	push   %ebx
  8013b1:	83 ec 14             	sub    $0x14,%esp
  8013b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ba:	50                   	push   %eax
  8013bb:	53                   	push   %ebx
  8013bc:	e8 86 fd ff ff       	call   801147 <fd_lookup>
  8013c1:	83 c4 08             	add    $0x8,%esp
  8013c4:	89 c2                	mov    %eax,%edx
  8013c6:	85 c0                	test   %eax,%eax
  8013c8:	78 6d                	js     801437 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ca:	83 ec 08             	sub    $0x8,%esp
  8013cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d0:	50                   	push   %eax
  8013d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d4:	ff 30                	pushl  (%eax)
  8013d6:	e8 c2 fd ff ff       	call   80119d <dev_lookup>
  8013db:	83 c4 10             	add    $0x10,%esp
  8013de:	85 c0                	test   %eax,%eax
  8013e0:	78 4c                	js     80142e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013e2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013e5:	8b 42 08             	mov    0x8(%edx),%eax
  8013e8:	83 e0 03             	and    $0x3,%eax
  8013eb:	83 f8 01             	cmp    $0x1,%eax
  8013ee:	75 21                	jne    801411 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013f0:	a1 04 40 80 00       	mov    0x804004,%eax
  8013f5:	8b 40 54             	mov    0x54(%eax),%eax
  8013f8:	83 ec 04             	sub    $0x4,%esp
  8013fb:	53                   	push   %ebx
  8013fc:	50                   	push   %eax
  8013fd:	68 19 26 80 00       	push   $0x802619
  801402:	e8 90 ed ff ff       	call   800197 <cprintf>
		return -E_INVAL;
  801407:	83 c4 10             	add    $0x10,%esp
  80140a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80140f:	eb 26                	jmp    801437 <read+0x8a>
	}
	if (!dev->dev_read)
  801411:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801414:	8b 40 08             	mov    0x8(%eax),%eax
  801417:	85 c0                	test   %eax,%eax
  801419:	74 17                	je     801432 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80141b:	83 ec 04             	sub    $0x4,%esp
  80141e:	ff 75 10             	pushl  0x10(%ebp)
  801421:	ff 75 0c             	pushl  0xc(%ebp)
  801424:	52                   	push   %edx
  801425:	ff d0                	call   *%eax
  801427:	89 c2                	mov    %eax,%edx
  801429:	83 c4 10             	add    $0x10,%esp
  80142c:	eb 09                	jmp    801437 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142e:	89 c2                	mov    %eax,%edx
  801430:	eb 05                	jmp    801437 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801432:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801437:	89 d0                	mov    %edx,%eax
  801439:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80143c:	c9                   	leave  
  80143d:	c3                   	ret    

0080143e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80143e:	55                   	push   %ebp
  80143f:	89 e5                	mov    %esp,%ebp
  801441:	57                   	push   %edi
  801442:	56                   	push   %esi
  801443:	53                   	push   %ebx
  801444:	83 ec 0c             	sub    $0xc,%esp
  801447:	8b 7d 08             	mov    0x8(%ebp),%edi
  80144a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80144d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801452:	eb 21                	jmp    801475 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801454:	83 ec 04             	sub    $0x4,%esp
  801457:	89 f0                	mov    %esi,%eax
  801459:	29 d8                	sub    %ebx,%eax
  80145b:	50                   	push   %eax
  80145c:	89 d8                	mov    %ebx,%eax
  80145e:	03 45 0c             	add    0xc(%ebp),%eax
  801461:	50                   	push   %eax
  801462:	57                   	push   %edi
  801463:	e8 45 ff ff ff       	call   8013ad <read>
		if (m < 0)
  801468:	83 c4 10             	add    $0x10,%esp
  80146b:	85 c0                	test   %eax,%eax
  80146d:	78 10                	js     80147f <readn+0x41>
			return m;
		if (m == 0)
  80146f:	85 c0                	test   %eax,%eax
  801471:	74 0a                	je     80147d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801473:	01 c3                	add    %eax,%ebx
  801475:	39 f3                	cmp    %esi,%ebx
  801477:	72 db                	jb     801454 <readn+0x16>
  801479:	89 d8                	mov    %ebx,%eax
  80147b:	eb 02                	jmp    80147f <readn+0x41>
  80147d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80147f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801482:	5b                   	pop    %ebx
  801483:	5e                   	pop    %esi
  801484:	5f                   	pop    %edi
  801485:	5d                   	pop    %ebp
  801486:	c3                   	ret    

00801487 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801487:	55                   	push   %ebp
  801488:	89 e5                	mov    %esp,%ebp
  80148a:	53                   	push   %ebx
  80148b:	83 ec 14             	sub    $0x14,%esp
  80148e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801491:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801494:	50                   	push   %eax
  801495:	53                   	push   %ebx
  801496:	e8 ac fc ff ff       	call   801147 <fd_lookup>
  80149b:	83 c4 08             	add    $0x8,%esp
  80149e:	89 c2                	mov    %eax,%edx
  8014a0:	85 c0                	test   %eax,%eax
  8014a2:	78 68                	js     80150c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a4:	83 ec 08             	sub    $0x8,%esp
  8014a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014aa:	50                   	push   %eax
  8014ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ae:	ff 30                	pushl  (%eax)
  8014b0:	e8 e8 fc ff ff       	call   80119d <dev_lookup>
  8014b5:	83 c4 10             	add    $0x10,%esp
  8014b8:	85 c0                	test   %eax,%eax
  8014ba:	78 47                	js     801503 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014bf:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014c3:	75 21                	jne    8014e6 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014c5:	a1 04 40 80 00       	mov    0x804004,%eax
  8014ca:	8b 40 54             	mov    0x54(%eax),%eax
  8014cd:	83 ec 04             	sub    $0x4,%esp
  8014d0:	53                   	push   %ebx
  8014d1:	50                   	push   %eax
  8014d2:	68 35 26 80 00       	push   $0x802635
  8014d7:	e8 bb ec ff ff       	call   800197 <cprintf>
		return -E_INVAL;
  8014dc:	83 c4 10             	add    $0x10,%esp
  8014df:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014e4:	eb 26                	jmp    80150c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014e9:	8b 52 0c             	mov    0xc(%edx),%edx
  8014ec:	85 d2                	test   %edx,%edx
  8014ee:	74 17                	je     801507 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014f0:	83 ec 04             	sub    $0x4,%esp
  8014f3:	ff 75 10             	pushl  0x10(%ebp)
  8014f6:	ff 75 0c             	pushl  0xc(%ebp)
  8014f9:	50                   	push   %eax
  8014fa:	ff d2                	call   *%edx
  8014fc:	89 c2                	mov    %eax,%edx
  8014fe:	83 c4 10             	add    $0x10,%esp
  801501:	eb 09                	jmp    80150c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801503:	89 c2                	mov    %eax,%edx
  801505:	eb 05                	jmp    80150c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801507:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80150c:	89 d0                	mov    %edx,%eax
  80150e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801511:	c9                   	leave  
  801512:	c3                   	ret    

00801513 <seek>:

int
seek(int fdnum, off_t offset)
{
  801513:	55                   	push   %ebp
  801514:	89 e5                	mov    %esp,%ebp
  801516:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801519:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80151c:	50                   	push   %eax
  80151d:	ff 75 08             	pushl  0x8(%ebp)
  801520:	e8 22 fc ff ff       	call   801147 <fd_lookup>
  801525:	83 c4 08             	add    $0x8,%esp
  801528:	85 c0                	test   %eax,%eax
  80152a:	78 0e                	js     80153a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80152c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80152f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801532:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801535:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80153a:	c9                   	leave  
  80153b:	c3                   	ret    

0080153c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80153c:	55                   	push   %ebp
  80153d:	89 e5                	mov    %esp,%ebp
  80153f:	53                   	push   %ebx
  801540:	83 ec 14             	sub    $0x14,%esp
  801543:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801546:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801549:	50                   	push   %eax
  80154a:	53                   	push   %ebx
  80154b:	e8 f7 fb ff ff       	call   801147 <fd_lookup>
  801550:	83 c4 08             	add    $0x8,%esp
  801553:	89 c2                	mov    %eax,%edx
  801555:	85 c0                	test   %eax,%eax
  801557:	78 65                	js     8015be <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801559:	83 ec 08             	sub    $0x8,%esp
  80155c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155f:	50                   	push   %eax
  801560:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801563:	ff 30                	pushl  (%eax)
  801565:	e8 33 fc ff ff       	call   80119d <dev_lookup>
  80156a:	83 c4 10             	add    $0x10,%esp
  80156d:	85 c0                	test   %eax,%eax
  80156f:	78 44                	js     8015b5 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801571:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801574:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801578:	75 21                	jne    80159b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80157a:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80157f:	8b 40 54             	mov    0x54(%eax),%eax
  801582:	83 ec 04             	sub    $0x4,%esp
  801585:	53                   	push   %ebx
  801586:	50                   	push   %eax
  801587:	68 f8 25 80 00       	push   $0x8025f8
  80158c:	e8 06 ec ff ff       	call   800197 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801591:	83 c4 10             	add    $0x10,%esp
  801594:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801599:	eb 23                	jmp    8015be <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80159b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80159e:	8b 52 18             	mov    0x18(%edx),%edx
  8015a1:	85 d2                	test   %edx,%edx
  8015a3:	74 14                	je     8015b9 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015a5:	83 ec 08             	sub    $0x8,%esp
  8015a8:	ff 75 0c             	pushl  0xc(%ebp)
  8015ab:	50                   	push   %eax
  8015ac:	ff d2                	call   *%edx
  8015ae:	89 c2                	mov    %eax,%edx
  8015b0:	83 c4 10             	add    $0x10,%esp
  8015b3:	eb 09                	jmp    8015be <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b5:	89 c2                	mov    %eax,%edx
  8015b7:	eb 05                	jmp    8015be <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015b9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015be:	89 d0                	mov    %edx,%eax
  8015c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c3:	c9                   	leave  
  8015c4:	c3                   	ret    

008015c5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015c5:	55                   	push   %ebp
  8015c6:	89 e5                	mov    %esp,%ebp
  8015c8:	53                   	push   %ebx
  8015c9:	83 ec 14             	sub    $0x14,%esp
  8015cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d2:	50                   	push   %eax
  8015d3:	ff 75 08             	pushl  0x8(%ebp)
  8015d6:	e8 6c fb ff ff       	call   801147 <fd_lookup>
  8015db:	83 c4 08             	add    $0x8,%esp
  8015de:	89 c2                	mov    %eax,%edx
  8015e0:	85 c0                	test   %eax,%eax
  8015e2:	78 58                	js     80163c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e4:	83 ec 08             	sub    $0x8,%esp
  8015e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ea:	50                   	push   %eax
  8015eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ee:	ff 30                	pushl  (%eax)
  8015f0:	e8 a8 fb ff ff       	call   80119d <dev_lookup>
  8015f5:	83 c4 10             	add    $0x10,%esp
  8015f8:	85 c0                	test   %eax,%eax
  8015fa:	78 37                	js     801633 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015ff:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801603:	74 32                	je     801637 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801605:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801608:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80160f:	00 00 00 
	stat->st_isdir = 0;
  801612:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801619:	00 00 00 
	stat->st_dev = dev;
  80161c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801622:	83 ec 08             	sub    $0x8,%esp
  801625:	53                   	push   %ebx
  801626:	ff 75 f0             	pushl  -0x10(%ebp)
  801629:	ff 50 14             	call   *0x14(%eax)
  80162c:	89 c2                	mov    %eax,%edx
  80162e:	83 c4 10             	add    $0x10,%esp
  801631:	eb 09                	jmp    80163c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801633:	89 c2                	mov    %eax,%edx
  801635:	eb 05                	jmp    80163c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801637:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80163c:	89 d0                	mov    %edx,%eax
  80163e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801641:	c9                   	leave  
  801642:	c3                   	ret    

00801643 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801643:	55                   	push   %ebp
  801644:	89 e5                	mov    %esp,%ebp
  801646:	56                   	push   %esi
  801647:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801648:	83 ec 08             	sub    $0x8,%esp
  80164b:	6a 00                	push   $0x0
  80164d:	ff 75 08             	pushl  0x8(%ebp)
  801650:	e8 e3 01 00 00       	call   801838 <open>
  801655:	89 c3                	mov    %eax,%ebx
  801657:	83 c4 10             	add    $0x10,%esp
  80165a:	85 c0                	test   %eax,%eax
  80165c:	78 1b                	js     801679 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80165e:	83 ec 08             	sub    $0x8,%esp
  801661:	ff 75 0c             	pushl  0xc(%ebp)
  801664:	50                   	push   %eax
  801665:	e8 5b ff ff ff       	call   8015c5 <fstat>
  80166a:	89 c6                	mov    %eax,%esi
	close(fd);
  80166c:	89 1c 24             	mov    %ebx,(%esp)
  80166f:	e8 fd fb ff ff       	call   801271 <close>
	return r;
  801674:	83 c4 10             	add    $0x10,%esp
  801677:	89 f0                	mov    %esi,%eax
}
  801679:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80167c:	5b                   	pop    %ebx
  80167d:	5e                   	pop    %esi
  80167e:	5d                   	pop    %ebp
  80167f:	c3                   	ret    

00801680 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801680:	55                   	push   %ebp
  801681:	89 e5                	mov    %esp,%ebp
  801683:	56                   	push   %esi
  801684:	53                   	push   %ebx
  801685:	89 c6                	mov    %eax,%esi
  801687:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801689:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801690:	75 12                	jne    8016a4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801692:	83 ec 0c             	sub    $0xc,%esp
  801695:	6a 01                	push   $0x1
  801697:	e8 3f 08 00 00       	call   801edb <ipc_find_env>
  80169c:	a3 00 40 80 00       	mov    %eax,0x804000
  8016a1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016a4:	6a 07                	push   $0x7
  8016a6:	68 00 50 80 00       	push   $0x805000
  8016ab:	56                   	push   %esi
  8016ac:	ff 35 00 40 80 00    	pushl  0x804000
  8016b2:	e8 c2 07 00 00       	call   801e79 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016b7:	83 c4 0c             	add    $0xc,%esp
  8016ba:	6a 00                	push   $0x0
  8016bc:	53                   	push   %ebx
  8016bd:	6a 00                	push   $0x0
  8016bf:	e8 3d 07 00 00       	call   801e01 <ipc_recv>
}
  8016c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c7:	5b                   	pop    %ebx
  8016c8:	5e                   	pop    %esi
  8016c9:	5d                   	pop    %ebp
  8016ca:	c3                   	ret    

008016cb <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016cb:	55                   	push   %ebp
  8016cc:	89 e5                	mov    %esp,%ebp
  8016ce:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d4:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016df:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e9:	b8 02 00 00 00       	mov    $0x2,%eax
  8016ee:	e8 8d ff ff ff       	call   801680 <fsipc>
}
  8016f3:	c9                   	leave  
  8016f4:	c3                   	ret    

008016f5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016f5:	55                   	push   %ebp
  8016f6:	89 e5                	mov    %esp,%ebp
  8016f8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fe:	8b 40 0c             	mov    0xc(%eax),%eax
  801701:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801706:	ba 00 00 00 00       	mov    $0x0,%edx
  80170b:	b8 06 00 00 00       	mov    $0x6,%eax
  801710:	e8 6b ff ff ff       	call   801680 <fsipc>
}
  801715:	c9                   	leave  
  801716:	c3                   	ret    

00801717 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	53                   	push   %ebx
  80171b:	83 ec 04             	sub    $0x4,%esp
  80171e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801721:	8b 45 08             	mov    0x8(%ebp),%eax
  801724:	8b 40 0c             	mov    0xc(%eax),%eax
  801727:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80172c:	ba 00 00 00 00       	mov    $0x0,%edx
  801731:	b8 05 00 00 00       	mov    $0x5,%eax
  801736:	e8 45 ff ff ff       	call   801680 <fsipc>
  80173b:	85 c0                	test   %eax,%eax
  80173d:	78 2c                	js     80176b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80173f:	83 ec 08             	sub    $0x8,%esp
  801742:	68 00 50 80 00       	push   $0x805000
  801747:	53                   	push   %ebx
  801748:	e8 cf ef ff ff       	call   80071c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80174d:	a1 80 50 80 00       	mov    0x805080,%eax
  801752:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801758:	a1 84 50 80 00       	mov    0x805084,%eax
  80175d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801763:	83 c4 10             	add    $0x10,%esp
  801766:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80176b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80176e:	c9                   	leave  
  80176f:	c3                   	ret    

00801770 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801770:	55                   	push   %ebp
  801771:	89 e5                	mov    %esp,%ebp
  801773:	83 ec 0c             	sub    $0xc,%esp
  801776:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801779:	8b 55 08             	mov    0x8(%ebp),%edx
  80177c:	8b 52 0c             	mov    0xc(%edx),%edx
  80177f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801785:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80178a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80178f:	0f 47 c2             	cmova  %edx,%eax
  801792:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801797:	50                   	push   %eax
  801798:	ff 75 0c             	pushl  0xc(%ebp)
  80179b:	68 08 50 80 00       	push   $0x805008
  8017a0:	e8 09 f1 ff ff       	call   8008ae <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8017a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017aa:	b8 04 00 00 00       	mov    $0x4,%eax
  8017af:	e8 cc fe ff ff       	call   801680 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8017b4:	c9                   	leave  
  8017b5:	c3                   	ret    

008017b6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017b6:	55                   	push   %ebp
  8017b7:	89 e5                	mov    %esp,%ebp
  8017b9:	56                   	push   %esi
  8017ba:	53                   	push   %ebx
  8017bb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017be:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c1:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017c9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d4:	b8 03 00 00 00       	mov    $0x3,%eax
  8017d9:	e8 a2 fe ff ff       	call   801680 <fsipc>
  8017de:	89 c3                	mov    %eax,%ebx
  8017e0:	85 c0                	test   %eax,%eax
  8017e2:	78 4b                	js     80182f <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017e4:	39 c6                	cmp    %eax,%esi
  8017e6:	73 16                	jae    8017fe <devfile_read+0x48>
  8017e8:	68 64 26 80 00       	push   $0x802664
  8017ed:	68 6b 26 80 00       	push   $0x80266b
  8017f2:	6a 7c                	push   $0x7c
  8017f4:	68 80 26 80 00       	push   $0x802680
  8017f9:	e8 bd 05 00 00       	call   801dbb <_panic>
	assert(r <= PGSIZE);
  8017fe:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801803:	7e 16                	jle    80181b <devfile_read+0x65>
  801805:	68 8b 26 80 00       	push   $0x80268b
  80180a:	68 6b 26 80 00       	push   $0x80266b
  80180f:	6a 7d                	push   $0x7d
  801811:	68 80 26 80 00       	push   $0x802680
  801816:	e8 a0 05 00 00       	call   801dbb <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80181b:	83 ec 04             	sub    $0x4,%esp
  80181e:	50                   	push   %eax
  80181f:	68 00 50 80 00       	push   $0x805000
  801824:	ff 75 0c             	pushl  0xc(%ebp)
  801827:	e8 82 f0 ff ff       	call   8008ae <memmove>
	return r;
  80182c:	83 c4 10             	add    $0x10,%esp
}
  80182f:	89 d8                	mov    %ebx,%eax
  801831:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801834:	5b                   	pop    %ebx
  801835:	5e                   	pop    %esi
  801836:	5d                   	pop    %ebp
  801837:	c3                   	ret    

00801838 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801838:	55                   	push   %ebp
  801839:	89 e5                	mov    %esp,%ebp
  80183b:	53                   	push   %ebx
  80183c:	83 ec 20             	sub    $0x20,%esp
  80183f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801842:	53                   	push   %ebx
  801843:	e8 9b ee ff ff       	call   8006e3 <strlen>
  801848:	83 c4 10             	add    $0x10,%esp
  80184b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801850:	7f 67                	jg     8018b9 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801852:	83 ec 0c             	sub    $0xc,%esp
  801855:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801858:	50                   	push   %eax
  801859:	e8 9a f8 ff ff       	call   8010f8 <fd_alloc>
  80185e:	83 c4 10             	add    $0x10,%esp
		return r;
  801861:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801863:	85 c0                	test   %eax,%eax
  801865:	78 57                	js     8018be <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801867:	83 ec 08             	sub    $0x8,%esp
  80186a:	53                   	push   %ebx
  80186b:	68 00 50 80 00       	push   $0x805000
  801870:	e8 a7 ee ff ff       	call   80071c <strcpy>
	fsipcbuf.open.req_omode = mode;
  801875:	8b 45 0c             	mov    0xc(%ebp),%eax
  801878:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80187d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801880:	b8 01 00 00 00       	mov    $0x1,%eax
  801885:	e8 f6 fd ff ff       	call   801680 <fsipc>
  80188a:	89 c3                	mov    %eax,%ebx
  80188c:	83 c4 10             	add    $0x10,%esp
  80188f:	85 c0                	test   %eax,%eax
  801891:	79 14                	jns    8018a7 <open+0x6f>
		fd_close(fd, 0);
  801893:	83 ec 08             	sub    $0x8,%esp
  801896:	6a 00                	push   $0x0
  801898:	ff 75 f4             	pushl  -0xc(%ebp)
  80189b:	e8 50 f9 ff ff       	call   8011f0 <fd_close>
		return r;
  8018a0:	83 c4 10             	add    $0x10,%esp
  8018a3:	89 da                	mov    %ebx,%edx
  8018a5:	eb 17                	jmp    8018be <open+0x86>
	}

	return fd2num(fd);
  8018a7:	83 ec 0c             	sub    $0xc,%esp
  8018aa:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ad:	e8 1f f8 ff ff       	call   8010d1 <fd2num>
  8018b2:	89 c2                	mov    %eax,%edx
  8018b4:	83 c4 10             	add    $0x10,%esp
  8018b7:	eb 05                	jmp    8018be <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018b9:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018be:	89 d0                	mov    %edx,%eax
  8018c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c3:	c9                   	leave  
  8018c4:	c3                   	ret    

008018c5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018c5:	55                   	push   %ebp
  8018c6:	89 e5                	mov    %esp,%ebp
  8018c8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d0:	b8 08 00 00 00       	mov    $0x8,%eax
  8018d5:	e8 a6 fd ff ff       	call   801680 <fsipc>
}
  8018da:	c9                   	leave  
  8018db:	c3                   	ret    

008018dc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018dc:	55                   	push   %ebp
  8018dd:	89 e5                	mov    %esp,%ebp
  8018df:	56                   	push   %esi
  8018e0:	53                   	push   %ebx
  8018e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018e4:	83 ec 0c             	sub    $0xc,%esp
  8018e7:	ff 75 08             	pushl  0x8(%ebp)
  8018ea:	e8 f2 f7 ff ff       	call   8010e1 <fd2data>
  8018ef:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018f1:	83 c4 08             	add    $0x8,%esp
  8018f4:	68 97 26 80 00       	push   $0x802697
  8018f9:	53                   	push   %ebx
  8018fa:	e8 1d ee ff ff       	call   80071c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018ff:	8b 46 04             	mov    0x4(%esi),%eax
  801902:	2b 06                	sub    (%esi),%eax
  801904:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80190a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801911:	00 00 00 
	stat->st_dev = &devpipe;
  801914:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80191b:	30 80 00 
	return 0;
}
  80191e:	b8 00 00 00 00       	mov    $0x0,%eax
  801923:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801926:	5b                   	pop    %ebx
  801927:	5e                   	pop    %esi
  801928:	5d                   	pop    %ebp
  801929:	c3                   	ret    

0080192a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80192a:	55                   	push   %ebp
  80192b:	89 e5                	mov    %esp,%ebp
  80192d:	53                   	push   %ebx
  80192e:	83 ec 0c             	sub    $0xc,%esp
  801931:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801934:	53                   	push   %ebx
  801935:	6a 00                	push   $0x0
  801937:	e8 68 f2 ff ff       	call   800ba4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80193c:	89 1c 24             	mov    %ebx,(%esp)
  80193f:	e8 9d f7 ff ff       	call   8010e1 <fd2data>
  801944:	83 c4 08             	add    $0x8,%esp
  801947:	50                   	push   %eax
  801948:	6a 00                	push   $0x0
  80194a:	e8 55 f2 ff ff       	call   800ba4 <sys_page_unmap>
}
  80194f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801952:	c9                   	leave  
  801953:	c3                   	ret    

00801954 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	57                   	push   %edi
  801958:	56                   	push   %esi
  801959:	53                   	push   %ebx
  80195a:	83 ec 1c             	sub    $0x1c,%esp
  80195d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801960:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801962:	a1 04 40 80 00       	mov    0x804004,%eax
  801967:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80196a:	83 ec 0c             	sub    $0xc,%esp
  80196d:	ff 75 e0             	pushl  -0x20(%ebp)
  801970:	e8 a6 05 00 00       	call   801f1b <pageref>
  801975:	89 c3                	mov    %eax,%ebx
  801977:	89 3c 24             	mov    %edi,(%esp)
  80197a:	e8 9c 05 00 00       	call   801f1b <pageref>
  80197f:	83 c4 10             	add    $0x10,%esp
  801982:	39 c3                	cmp    %eax,%ebx
  801984:	0f 94 c1             	sete   %cl
  801987:	0f b6 c9             	movzbl %cl,%ecx
  80198a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80198d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801993:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  801996:	39 ce                	cmp    %ecx,%esi
  801998:	74 1b                	je     8019b5 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80199a:	39 c3                	cmp    %eax,%ebx
  80199c:	75 c4                	jne    801962 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80199e:	8b 42 64             	mov    0x64(%edx),%eax
  8019a1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019a4:	50                   	push   %eax
  8019a5:	56                   	push   %esi
  8019a6:	68 9e 26 80 00       	push   $0x80269e
  8019ab:	e8 e7 e7 ff ff       	call   800197 <cprintf>
  8019b0:	83 c4 10             	add    $0x10,%esp
  8019b3:	eb ad                	jmp    801962 <_pipeisclosed+0xe>
	}
}
  8019b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019bb:	5b                   	pop    %ebx
  8019bc:	5e                   	pop    %esi
  8019bd:	5f                   	pop    %edi
  8019be:	5d                   	pop    %ebp
  8019bf:	c3                   	ret    

008019c0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
  8019c3:	57                   	push   %edi
  8019c4:	56                   	push   %esi
  8019c5:	53                   	push   %ebx
  8019c6:	83 ec 28             	sub    $0x28,%esp
  8019c9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019cc:	56                   	push   %esi
  8019cd:	e8 0f f7 ff ff       	call   8010e1 <fd2data>
  8019d2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019d4:	83 c4 10             	add    $0x10,%esp
  8019d7:	bf 00 00 00 00       	mov    $0x0,%edi
  8019dc:	eb 4b                	jmp    801a29 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019de:	89 da                	mov    %ebx,%edx
  8019e0:	89 f0                	mov    %esi,%eax
  8019e2:	e8 6d ff ff ff       	call   801954 <_pipeisclosed>
  8019e7:	85 c0                	test   %eax,%eax
  8019e9:	75 48                	jne    801a33 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019eb:	e8 10 f1 ff ff       	call   800b00 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019f0:	8b 43 04             	mov    0x4(%ebx),%eax
  8019f3:	8b 0b                	mov    (%ebx),%ecx
  8019f5:	8d 51 20             	lea    0x20(%ecx),%edx
  8019f8:	39 d0                	cmp    %edx,%eax
  8019fa:	73 e2                	jae    8019de <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019ff:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a03:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a06:	89 c2                	mov    %eax,%edx
  801a08:	c1 fa 1f             	sar    $0x1f,%edx
  801a0b:	89 d1                	mov    %edx,%ecx
  801a0d:	c1 e9 1b             	shr    $0x1b,%ecx
  801a10:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a13:	83 e2 1f             	and    $0x1f,%edx
  801a16:	29 ca                	sub    %ecx,%edx
  801a18:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a1c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a20:	83 c0 01             	add    $0x1,%eax
  801a23:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a26:	83 c7 01             	add    $0x1,%edi
  801a29:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a2c:	75 c2                	jne    8019f0 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a2e:	8b 45 10             	mov    0x10(%ebp),%eax
  801a31:	eb 05                	jmp    801a38 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a33:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a3b:	5b                   	pop    %ebx
  801a3c:	5e                   	pop    %esi
  801a3d:	5f                   	pop    %edi
  801a3e:	5d                   	pop    %ebp
  801a3f:	c3                   	ret    

00801a40 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a40:	55                   	push   %ebp
  801a41:	89 e5                	mov    %esp,%ebp
  801a43:	57                   	push   %edi
  801a44:	56                   	push   %esi
  801a45:	53                   	push   %ebx
  801a46:	83 ec 18             	sub    $0x18,%esp
  801a49:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a4c:	57                   	push   %edi
  801a4d:	e8 8f f6 ff ff       	call   8010e1 <fd2data>
  801a52:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a54:	83 c4 10             	add    $0x10,%esp
  801a57:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a5c:	eb 3d                	jmp    801a9b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a5e:	85 db                	test   %ebx,%ebx
  801a60:	74 04                	je     801a66 <devpipe_read+0x26>
				return i;
  801a62:	89 d8                	mov    %ebx,%eax
  801a64:	eb 44                	jmp    801aaa <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a66:	89 f2                	mov    %esi,%edx
  801a68:	89 f8                	mov    %edi,%eax
  801a6a:	e8 e5 fe ff ff       	call   801954 <_pipeisclosed>
  801a6f:	85 c0                	test   %eax,%eax
  801a71:	75 32                	jne    801aa5 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a73:	e8 88 f0 ff ff       	call   800b00 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a78:	8b 06                	mov    (%esi),%eax
  801a7a:	3b 46 04             	cmp    0x4(%esi),%eax
  801a7d:	74 df                	je     801a5e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a7f:	99                   	cltd   
  801a80:	c1 ea 1b             	shr    $0x1b,%edx
  801a83:	01 d0                	add    %edx,%eax
  801a85:	83 e0 1f             	and    $0x1f,%eax
  801a88:	29 d0                	sub    %edx,%eax
  801a8a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a92:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a95:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a98:	83 c3 01             	add    $0x1,%ebx
  801a9b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a9e:	75 d8                	jne    801a78 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801aa0:	8b 45 10             	mov    0x10(%ebp),%eax
  801aa3:	eb 05                	jmp    801aaa <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aa5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801aaa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aad:	5b                   	pop    %ebx
  801aae:	5e                   	pop    %esi
  801aaf:	5f                   	pop    %edi
  801ab0:	5d                   	pop    %ebp
  801ab1:	c3                   	ret    

00801ab2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ab2:	55                   	push   %ebp
  801ab3:	89 e5                	mov    %esp,%ebp
  801ab5:	56                   	push   %esi
  801ab6:	53                   	push   %ebx
  801ab7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801aba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801abd:	50                   	push   %eax
  801abe:	e8 35 f6 ff ff       	call   8010f8 <fd_alloc>
  801ac3:	83 c4 10             	add    $0x10,%esp
  801ac6:	89 c2                	mov    %eax,%edx
  801ac8:	85 c0                	test   %eax,%eax
  801aca:	0f 88 2c 01 00 00    	js     801bfc <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ad0:	83 ec 04             	sub    $0x4,%esp
  801ad3:	68 07 04 00 00       	push   $0x407
  801ad8:	ff 75 f4             	pushl  -0xc(%ebp)
  801adb:	6a 00                	push   $0x0
  801add:	e8 3d f0 ff ff       	call   800b1f <sys_page_alloc>
  801ae2:	83 c4 10             	add    $0x10,%esp
  801ae5:	89 c2                	mov    %eax,%edx
  801ae7:	85 c0                	test   %eax,%eax
  801ae9:	0f 88 0d 01 00 00    	js     801bfc <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801aef:	83 ec 0c             	sub    $0xc,%esp
  801af2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801af5:	50                   	push   %eax
  801af6:	e8 fd f5 ff ff       	call   8010f8 <fd_alloc>
  801afb:	89 c3                	mov    %eax,%ebx
  801afd:	83 c4 10             	add    $0x10,%esp
  801b00:	85 c0                	test   %eax,%eax
  801b02:	0f 88 e2 00 00 00    	js     801bea <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b08:	83 ec 04             	sub    $0x4,%esp
  801b0b:	68 07 04 00 00       	push   $0x407
  801b10:	ff 75 f0             	pushl  -0x10(%ebp)
  801b13:	6a 00                	push   $0x0
  801b15:	e8 05 f0 ff ff       	call   800b1f <sys_page_alloc>
  801b1a:	89 c3                	mov    %eax,%ebx
  801b1c:	83 c4 10             	add    $0x10,%esp
  801b1f:	85 c0                	test   %eax,%eax
  801b21:	0f 88 c3 00 00 00    	js     801bea <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b27:	83 ec 0c             	sub    $0xc,%esp
  801b2a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b2d:	e8 af f5 ff ff       	call   8010e1 <fd2data>
  801b32:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b34:	83 c4 0c             	add    $0xc,%esp
  801b37:	68 07 04 00 00       	push   $0x407
  801b3c:	50                   	push   %eax
  801b3d:	6a 00                	push   $0x0
  801b3f:	e8 db ef ff ff       	call   800b1f <sys_page_alloc>
  801b44:	89 c3                	mov    %eax,%ebx
  801b46:	83 c4 10             	add    $0x10,%esp
  801b49:	85 c0                	test   %eax,%eax
  801b4b:	0f 88 89 00 00 00    	js     801bda <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b51:	83 ec 0c             	sub    $0xc,%esp
  801b54:	ff 75 f0             	pushl  -0x10(%ebp)
  801b57:	e8 85 f5 ff ff       	call   8010e1 <fd2data>
  801b5c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b63:	50                   	push   %eax
  801b64:	6a 00                	push   $0x0
  801b66:	56                   	push   %esi
  801b67:	6a 00                	push   $0x0
  801b69:	e8 f4 ef ff ff       	call   800b62 <sys_page_map>
  801b6e:	89 c3                	mov    %eax,%ebx
  801b70:	83 c4 20             	add    $0x20,%esp
  801b73:	85 c0                	test   %eax,%eax
  801b75:	78 55                	js     801bcc <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b77:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b80:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b85:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b8c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b92:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b95:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b97:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b9a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ba1:	83 ec 0c             	sub    $0xc,%esp
  801ba4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba7:	e8 25 f5 ff ff       	call   8010d1 <fd2num>
  801bac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801baf:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bb1:	83 c4 04             	add    $0x4,%esp
  801bb4:	ff 75 f0             	pushl  -0x10(%ebp)
  801bb7:	e8 15 f5 ff ff       	call   8010d1 <fd2num>
  801bbc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bbf:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801bc2:	83 c4 10             	add    $0x10,%esp
  801bc5:	ba 00 00 00 00       	mov    $0x0,%edx
  801bca:	eb 30                	jmp    801bfc <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801bcc:	83 ec 08             	sub    $0x8,%esp
  801bcf:	56                   	push   %esi
  801bd0:	6a 00                	push   $0x0
  801bd2:	e8 cd ef ff ff       	call   800ba4 <sys_page_unmap>
  801bd7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801bda:	83 ec 08             	sub    $0x8,%esp
  801bdd:	ff 75 f0             	pushl  -0x10(%ebp)
  801be0:	6a 00                	push   $0x0
  801be2:	e8 bd ef ff ff       	call   800ba4 <sys_page_unmap>
  801be7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801bea:	83 ec 08             	sub    $0x8,%esp
  801bed:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf0:	6a 00                	push   $0x0
  801bf2:	e8 ad ef ff ff       	call   800ba4 <sys_page_unmap>
  801bf7:	83 c4 10             	add    $0x10,%esp
  801bfa:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801bfc:	89 d0                	mov    %edx,%eax
  801bfe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c01:	5b                   	pop    %ebx
  801c02:	5e                   	pop    %esi
  801c03:	5d                   	pop    %ebp
  801c04:	c3                   	ret    

00801c05 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c05:	55                   	push   %ebp
  801c06:	89 e5                	mov    %esp,%ebp
  801c08:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c0b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c0e:	50                   	push   %eax
  801c0f:	ff 75 08             	pushl  0x8(%ebp)
  801c12:	e8 30 f5 ff ff       	call   801147 <fd_lookup>
  801c17:	83 c4 10             	add    $0x10,%esp
  801c1a:	85 c0                	test   %eax,%eax
  801c1c:	78 18                	js     801c36 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c1e:	83 ec 0c             	sub    $0xc,%esp
  801c21:	ff 75 f4             	pushl  -0xc(%ebp)
  801c24:	e8 b8 f4 ff ff       	call   8010e1 <fd2data>
	return _pipeisclosed(fd, p);
  801c29:	89 c2                	mov    %eax,%edx
  801c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c2e:	e8 21 fd ff ff       	call   801954 <_pipeisclosed>
  801c33:	83 c4 10             	add    $0x10,%esp
}
  801c36:	c9                   	leave  
  801c37:	c3                   	ret    

00801c38 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c38:	55                   	push   %ebp
  801c39:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c3b:	b8 00 00 00 00       	mov    $0x0,%eax
  801c40:	5d                   	pop    %ebp
  801c41:	c3                   	ret    

00801c42 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c42:	55                   	push   %ebp
  801c43:	89 e5                	mov    %esp,%ebp
  801c45:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c48:	68 b6 26 80 00       	push   $0x8026b6
  801c4d:	ff 75 0c             	pushl  0xc(%ebp)
  801c50:	e8 c7 ea ff ff       	call   80071c <strcpy>
	return 0;
}
  801c55:	b8 00 00 00 00       	mov    $0x0,%eax
  801c5a:	c9                   	leave  
  801c5b:	c3                   	ret    

00801c5c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	57                   	push   %edi
  801c60:	56                   	push   %esi
  801c61:	53                   	push   %ebx
  801c62:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c68:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c6d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c73:	eb 2d                	jmp    801ca2 <devcons_write+0x46>
		m = n - tot;
  801c75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c78:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c7a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c7d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c82:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c85:	83 ec 04             	sub    $0x4,%esp
  801c88:	53                   	push   %ebx
  801c89:	03 45 0c             	add    0xc(%ebp),%eax
  801c8c:	50                   	push   %eax
  801c8d:	57                   	push   %edi
  801c8e:	e8 1b ec ff ff       	call   8008ae <memmove>
		sys_cputs(buf, m);
  801c93:	83 c4 08             	add    $0x8,%esp
  801c96:	53                   	push   %ebx
  801c97:	57                   	push   %edi
  801c98:	e8 c6 ed ff ff       	call   800a63 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c9d:	01 de                	add    %ebx,%esi
  801c9f:	83 c4 10             	add    $0x10,%esp
  801ca2:	89 f0                	mov    %esi,%eax
  801ca4:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ca7:	72 cc                	jb     801c75 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ca9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cac:	5b                   	pop    %ebx
  801cad:	5e                   	pop    %esi
  801cae:	5f                   	pop    %edi
  801caf:	5d                   	pop    %ebp
  801cb0:	c3                   	ret    

00801cb1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cb1:	55                   	push   %ebp
  801cb2:	89 e5                	mov    %esp,%ebp
  801cb4:	83 ec 08             	sub    $0x8,%esp
  801cb7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801cbc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cc0:	74 2a                	je     801cec <devcons_read+0x3b>
  801cc2:	eb 05                	jmp    801cc9 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801cc4:	e8 37 ee ff ff       	call   800b00 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801cc9:	e8 b3 ed ff ff       	call   800a81 <sys_cgetc>
  801cce:	85 c0                	test   %eax,%eax
  801cd0:	74 f2                	je     801cc4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801cd2:	85 c0                	test   %eax,%eax
  801cd4:	78 16                	js     801cec <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801cd6:	83 f8 04             	cmp    $0x4,%eax
  801cd9:	74 0c                	je     801ce7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801cdb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cde:	88 02                	mov    %al,(%edx)
	return 1;
  801ce0:	b8 01 00 00 00       	mov    $0x1,%eax
  801ce5:	eb 05                	jmp    801cec <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ce7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801cec:	c9                   	leave  
  801ced:	c3                   	ret    

00801cee <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801cee:	55                   	push   %ebp
  801cef:	89 e5                	mov    %esp,%ebp
  801cf1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801cfa:	6a 01                	push   $0x1
  801cfc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cff:	50                   	push   %eax
  801d00:	e8 5e ed ff ff       	call   800a63 <sys_cputs>
}
  801d05:	83 c4 10             	add    $0x10,%esp
  801d08:	c9                   	leave  
  801d09:	c3                   	ret    

00801d0a <getchar>:

int
getchar(void)
{
  801d0a:	55                   	push   %ebp
  801d0b:	89 e5                	mov    %esp,%ebp
  801d0d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d10:	6a 01                	push   $0x1
  801d12:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d15:	50                   	push   %eax
  801d16:	6a 00                	push   $0x0
  801d18:	e8 90 f6 ff ff       	call   8013ad <read>
	if (r < 0)
  801d1d:	83 c4 10             	add    $0x10,%esp
  801d20:	85 c0                	test   %eax,%eax
  801d22:	78 0f                	js     801d33 <getchar+0x29>
		return r;
	if (r < 1)
  801d24:	85 c0                	test   %eax,%eax
  801d26:	7e 06                	jle    801d2e <getchar+0x24>
		return -E_EOF;
	return c;
  801d28:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d2c:	eb 05                	jmp    801d33 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d2e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d33:	c9                   	leave  
  801d34:	c3                   	ret    

00801d35 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d35:	55                   	push   %ebp
  801d36:	89 e5                	mov    %esp,%ebp
  801d38:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d3b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d3e:	50                   	push   %eax
  801d3f:	ff 75 08             	pushl  0x8(%ebp)
  801d42:	e8 00 f4 ff ff       	call   801147 <fd_lookup>
  801d47:	83 c4 10             	add    $0x10,%esp
  801d4a:	85 c0                	test   %eax,%eax
  801d4c:	78 11                	js     801d5f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d51:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d57:	39 10                	cmp    %edx,(%eax)
  801d59:	0f 94 c0             	sete   %al
  801d5c:	0f b6 c0             	movzbl %al,%eax
}
  801d5f:	c9                   	leave  
  801d60:	c3                   	ret    

00801d61 <opencons>:

int
opencons(void)
{
  801d61:	55                   	push   %ebp
  801d62:	89 e5                	mov    %esp,%ebp
  801d64:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d6a:	50                   	push   %eax
  801d6b:	e8 88 f3 ff ff       	call   8010f8 <fd_alloc>
  801d70:	83 c4 10             	add    $0x10,%esp
		return r;
  801d73:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d75:	85 c0                	test   %eax,%eax
  801d77:	78 3e                	js     801db7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d79:	83 ec 04             	sub    $0x4,%esp
  801d7c:	68 07 04 00 00       	push   $0x407
  801d81:	ff 75 f4             	pushl  -0xc(%ebp)
  801d84:	6a 00                	push   $0x0
  801d86:	e8 94 ed ff ff       	call   800b1f <sys_page_alloc>
  801d8b:	83 c4 10             	add    $0x10,%esp
		return r;
  801d8e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d90:	85 c0                	test   %eax,%eax
  801d92:	78 23                	js     801db7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d94:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801da9:	83 ec 0c             	sub    $0xc,%esp
  801dac:	50                   	push   %eax
  801dad:	e8 1f f3 ff ff       	call   8010d1 <fd2num>
  801db2:	89 c2                	mov    %eax,%edx
  801db4:	83 c4 10             	add    $0x10,%esp
}
  801db7:	89 d0                	mov    %edx,%eax
  801db9:	c9                   	leave  
  801dba:	c3                   	ret    

00801dbb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801dbb:	55                   	push   %ebp
  801dbc:	89 e5                	mov    %esp,%ebp
  801dbe:	56                   	push   %esi
  801dbf:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801dc0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801dc3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801dc9:	e8 13 ed ff ff       	call   800ae1 <sys_getenvid>
  801dce:	83 ec 0c             	sub    $0xc,%esp
  801dd1:	ff 75 0c             	pushl  0xc(%ebp)
  801dd4:	ff 75 08             	pushl  0x8(%ebp)
  801dd7:	56                   	push   %esi
  801dd8:	50                   	push   %eax
  801dd9:	68 c4 26 80 00       	push   $0x8026c4
  801dde:	e8 b4 e3 ff ff       	call   800197 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801de3:	83 c4 18             	add    $0x18,%esp
  801de6:	53                   	push   %ebx
  801de7:	ff 75 10             	pushl  0x10(%ebp)
  801dea:	e8 57 e3 ff ff       	call   800146 <vcprintf>
	cprintf("\n");
  801def:	c7 04 24 af 26 80 00 	movl   $0x8026af,(%esp)
  801df6:	e8 9c e3 ff ff       	call   800197 <cprintf>
  801dfb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801dfe:	cc                   	int3   
  801dff:	eb fd                	jmp    801dfe <_panic+0x43>

00801e01 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e01:	55                   	push   %ebp
  801e02:	89 e5                	mov    %esp,%ebp
  801e04:	56                   	push   %esi
  801e05:	53                   	push   %ebx
  801e06:	8b 75 08             	mov    0x8(%ebp),%esi
  801e09:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e0f:	85 c0                	test   %eax,%eax
  801e11:	75 12                	jne    801e25 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e13:	83 ec 0c             	sub    $0xc,%esp
  801e16:	68 00 00 c0 ee       	push   $0xeec00000
  801e1b:	e8 af ee ff ff       	call   800ccf <sys_ipc_recv>
  801e20:	83 c4 10             	add    $0x10,%esp
  801e23:	eb 0c                	jmp    801e31 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e25:	83 ec 0c             	sub    $0xc,%esp
  801e28:	50                   	push   %eax
  801e29:	e8 a1 ee ff ff       	call   800ccf <sys_ipc_recv>
  801e2e:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e31:	85 f6                	test   %esi,%esi
  801e33:	0f 95 c1             	setne  %cl
  801e36:	85 db                	test   %ebx,%ebx
  801e38:	0f 95 c2             	setne  %dl
  801e3b:	84 d1                	test   %dl,%cl
  801e3d:	74 09                	je     801e48 <ipc_recv+0x47>
  801e3f:	89 c2                	mov    %eax,%edx
  801e41:	c1 ea 1f             	shr    $0x1f,%edx
  801e44:	84 d2                	test   %dl,%dl
  801e46:	75 2a                	jne    801e72 <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e48:	85 f6                	test   %esi,%esi
  801e4a:	74 0d                	je     801e59 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e4c:	a1 04 40 80 00       	mov    0x804004,%eax
  801e51:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801e57:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e59:	85 db                	test   %ebx,%ebx
  801e5b:	74 0d                	je     801e6a <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e5d:	a1 04 40 80 00       	mov    0x804004,%eax
  801e62:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  801e68:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e6a:	a1 04 40 80 00       	mov    0x804004,%eax
  801e6f:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  801e72:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e75:	5b                   	pop    %ebx
  801e76:	5e                   	pop    %esi
  801e77:	5d                   	pop    %ebp
  801e78:	c3                   	ret    

00801e79 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e79:	55                   	push   %ebp
  801e7a:	89 e5                	mov    %esp,%ebp
  801e7c:	57                   	push   %edi
  801e7d:	56                   	push   %esi
  801e7e:	53                   	push   %ebx
  801e7f:	83 ec 0c             	sub    $0xc,%esp
  801e82:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e85:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e88:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801e8b:	85 db                	test   %ebx,%ebx
  801e8d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e92:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e95:	ff 75 14             	pushl  0x14(%ebp)
  801e98:	53                   	push   %ebx
  801e99:	56                   	push   %esi
  801e9a:	57                   	push   %edi
  801e9b:	e8 0c ee ff ff       	call   800cac <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801ea0:	89 c2                	mov    %eax,%edx
  801ea2:	c1 ea 1f             	shr    $0x1f,%edx
  801ea5:	83 c4 10             	add    $0x10,%esp
  801ea8:	84 d2                	test   %dl,%dl
  801eaa:	74 17                	je     801ec3 <ipc_send+0x4a>
  801eac:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801eaf:	74 12                	je     801ec3 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801eb1:	50                   	push   %eax
  801eb2:	68 e8 26 80 00       	push   $0x8026e8
  801eb7:	6a 47                	push   $0x47
  801eb9:	68 f6 26 80 00       	push   $0x8026f6
  801ebe:	e8 f8 fe ff ff       	call   801dbb <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801ec3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ec6:	75 07                	jne    801ecf <ipc_send+0x56>
			sys_yield();
  801ec8:	e8 33 ec ff ff       	call   800b00 <sys_yield>
  801ecd:	eb c6                	jmp    801e95 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801ecf:	85 c0                	test   %eax,%eax
  801ed1:	75 c2                	jne    801e95 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801ed3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ed6:	5b                   	pop    %ebx
  801ed7:	5e                   	pop    %esi
  801ed8:	5f                   	pop    %edi
  801ed9:	5d                   	pop    %ebp
  801eda:	c3                   	ret    

00801edb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801edb:	55                   	push   %ebp
  801edc:	89 e5                	mov    %esp,%ebp
  801ede:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ee1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ee6:	89 c2                	mov    %eax,%edx
  801ee8:	c1 e2 07             	shl    $0x7,%edx
  801eeb:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  801ef2:	8b 52 5c             	mov    0x5c(%edx),%edx
  801ef5:	39 ca                	cmp    %ecx,%edx
  801ef7:	75 11                	jne    801f0a <ipc_find_env+0x2f>
			return envs[i].env_id;
  801ef9:	89 c2                	mov    %eax,%edx
  801efb:	c1 e2 07             	shl    $0x7,%edx
  801efe:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801f05:	8b 40 54             	mov    0x54(%eax),%eax
  801f08:	eb 0f                	jmp    801f19 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f0a:	83 c0 01             	add    $0x1,%eax
  801f0d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f12:	75 d2                	jne    801ee6 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f14:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f19:	5d                   	pop    %ebp
  801f1a:	c3                   	ret    

00801f1b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f1b:	55                   	push   %ebp
  801f1c:	89 e5                	mov    %esp,%ebp
  801f1e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f21:	89 d0                	mov    %edx,%eax
  801f23:	c1 e8 16             	shr    $0x16,%eax
  801f26:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f2d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f32:	f6 c1 01             	test   $0x1,%cl
  801f35:	74 1d                	je     801f54 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f37:	c1 ea 0c             	shr    $0xc,%edx
  801f3a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f41:	f6 c2 01             	test   $0x1,%dl
  801f44:	74 0e                	je     801f54 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f46:	c1 ea 0c             	shr    $0xc,%edx
  801f49:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f50:	ef 
  801f51:	0f b7 c0             	movzwl %ax,%eax
}
  801f54:	5d                   	pop    %ebp
  801f55:	c3                   	ret    
  801f56:	66 90                	xchg   %ax,%ax
  801f58:	66 90                	xchg   %ax,%ax
  801f5a:	66 90                	xchg   %ax,%ax
  801f5c:	66 90                	xchg   %ax,%ax
  801f5e:	66 90                	xchg   %ax,%ax

00801f60 <__udivdi3>:
  801f60:	55                   	push   %ebp
  801f61:	57                   	push   %edi
  801f62:	56                   	push   %esi
  801f63:	53                   	push   %ebx
  801f64:	83 ec 1c             	sub    $0x1c,%esp
  801f67:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f6b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f6f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f77:	85 f6                	test   %esi,%esi
  801f79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f7d:	89 ca                	mov    %ecx,%edx
  801f7f:	89 f8                	mov    %edi,%eax
  801f81:	75 3d                	jne    801fc0 <__udivdi3+0x60>
  801f83:	39 cf                	cmp    %ecx,%edi
  801f85:	0f 87 c5 00 00 00    	ja     802050 <__udivdi3+0xf0>
  801f8b:	85 ff                	test   %edi,%edi
  801f8d:	89 fd                	mov    %edi,%ebp
  801f8f:	75 0b                	jne    801f9c <__udivdi3+0x3c>
  801f91:	b8 01 00 00 00       	mov    $0x1,%eax
  801f96:	31 d2                	xor    %edx,%edx
  801f98:	f7 f7                	div    %edi
  801f9a:	89 c5                	mov    %eax,%ebp
  801f9c:	89 c8                	mov    %ecx,%eax
  801f9e:	31 d2                	xor    %edx,%edx
  801fa0:	f7 f5                	div    %ebp
  801fa2:	89 c1                	mov    %eax,%ecx
  801fa4:	89 d8                	mov    %ebx,%eax
  801fa6:	89 cf                	mov    %ecx,%edi
  801fa8:	f7 f5                	div    %ebp
  801faa:	89 c3                	mov    %eax,%ebx
  801fac:	89 d8                	mov    %ebx,%eax
  801fae:	89 fa                	mov    %edi,%edx
  801fb0:	83 c4 1c             	add    $0x1c,%esp
  801fb3:	5b                   	pop    %ebx
  801fb4:	5e                   	pop    %esi
  801fb5:	5f                   	pop    %edi
  801fb6:	5d                   	pop    %ebp
  801fb7:	c3                   	ret    
  801fb8:	90                   	nop
  801fb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fc0:	39 ce                	cmp    %ecx,%esi
  801fc2:	77 74                	ja     802038 <__udivdi3+0xd8>
  801fc4:	0f bd fe             	bsr    %esi,%edi
  801fc7:	83 f7 1f             	xor    $0x1f,%edi
  801fca:	0f 84 98 00 00 00    	je     802068 <__udivdi3+0x108>
  801fd0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fd5:	89 f9                	mov    %edi,%ecx
  801fd7:	89 c5                	mov    %eax,%ebp
  801fd9:	29 fb                	sub    %edi,%ebx
  801fdb:	d3 e6                	shl    %cl,%esi
  801fdd:	89 d9                	mov    %ebx,%ecx
  801fdf:	d3 ed                	shr    %cl,%ebp
  801fe1:	89 f9                	mov    %edi,%ecx
  801fe3:	d3 e0                	shl    %cl,%eax
  801fe5:	09 ee                	or     %ebp,%esi
  801fe7:	89 d9                	mov    %ebx,%ecx
  801fe9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fed:	89 d5                	mov    %edx,%ebp
  801fef:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ff3:	d3 ed                	shr    %cl,%ebp
  801ff5:	89 f9                	mov    %edi,%ecx
  801ff7:	d3 e2                	shl    %cl,%edx
  801ff9:	89 d9                	mov    %ebx,%ecx
  801ffb:	d3 e8                	shr    %cl,%eax
  801ffd:	09 c2                	or     %eax,%edx
  801fff:	89 d0                	mov    %edx,%eax
  802001:	89 ea                	mov    %ebp,%edx
  802003:	f7 f6                	div    %esi
  802005:	89 d5                	mov    %edx,%ebp
  802007:	89 c3                	mov    %eax,%ebx
  802009:	f7 64 24 0c          	mull   0xc(%esp)
  80200d:	39 d5                	cmp    %edx,%ebp
  80200f:	72 10                	jb     802021 <__udivdi3+0xc1>
  802011:	8b 74 24 08          	mov    0x8(%esp),%esi
  802015:	89 f9                	mov    %edi,%ecx
  802017:	d3 e6                	shl    %cl,%esi
  802019:	39 c6                	cmp    %eax,%esi
  80201b:	73 07                	jae    802024 <__udivdi3+0xc4>
  80201d:	39 d5                	cmp    %edx,%ebp
  80201f:	75 03                	jne    802024 <__udivdi3+0xc4>
  802021:	83 eb 01             	sub    $0x1,%ebx
  802024:	31 ff                	xor    %edi,%edi
  802026:	89 d8                	mov    %ebx,%eax
  802028:	89 fa                	mov    %edi,%edx
  80202a:	83 c4 1c             	add    $0x1c,%esp
  80202d:	5b                   	pop    %ebx
  80202e:	5e                   	pop    %esi
  80202f:	5f                   	pop    %edi
  802030:	5d                   	pop    %ebp
  802031:	c3                   	ret    
  802032:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802038:	31 ff                	xor    %edi,%edi
  80203a:	31 db                	xor    %ebx,%ebx
  80203c:	89 d8                	mov    %ebx,%eax
  80203e:	89 fa                	mov    %edi,%edx
  802040:	83 c4 1c             	add    $0x1c,%esp
  802043:	5b                   	pop    %ebx
  802044:	5e                   	pop    %esi
  802045:	5f                   	pop    %edi
  802046:	5d                   	pop    %ebp
  802047:	c3                   	ret    
  802048:	90                   	nop
  802049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802050:	89 d8                	mov    %ebx,%eax
  802052:	f7 f7                	div    %edi
  802054:	31 ff                	xor    %edi,%edi
  802056:	89 c3                	mov    %eax,%ebx
  802058:	89 d8                	mov    %ebx,%eax
  80205a:	89 fa                	mov    %edi,%edx
  80205c:	83 c4 1c             	add    $0x1c,%esp
  80205f:	5b                   	pop    %ebx
  802060:	5e                   	pop    %esi
  802061:	5f                   	pop    %edi
  802062:	5d                   	pop    %ebp
  802063:	c3                   	ret    
  802064:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802068:	39 ce                	cmp    %ecx,%esi
  80206a:	72 0c                	jb     802078 <__udivdi3+0x118>
  80206c:	31 db                	xor    %ebx,%ebx
  80206e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802072:	0f 87 34 ff ff ff    	ja     801fac <__udivdi3+0x4c>
  802078:	bb 01 00 00 00       	mov    $0x1,%ebx
  80207d:	e9 2a ff ff ff       	jmp    801fac <__udivdi3+0x4c>
  802082:	66 90                	xchg   %ax,%ax
  802084:	66 90                	xchg   %ax,%ax
  802086:	66 90                	xchg   %ax,%ax
  802088:	66 90                	xchg   %ax,%ax
  80208a:	66 90                	xchg   %ax,%ax
  80208c:	66 90                	xchg   %ax,%ax
  80208e:	66 90                	xchg   %ax,%ax

00802090 <__umoddi3>:
  802090:	55                   	push   %ebp
  802091:	57                   	push   %edi
  802092:	56                   	push   %esi
  802093:	53                   	push   %ebx
  802094:	83 ec 1c             	sub    $0x1c,%esp
  802097:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80209b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80209f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020a7:	85 d2                	test   %edx,%edx
  8020a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020b1:	89 f3                	mov    %esi,%ebx
  8020b3:	89 3c 24             	mov    %edi,(%esp)
  8020b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ba:	75 1c                	jne    8020d8 <__umoddi3+0x48>
  8020bc:	39 f7                	cmp    %esi,%edi
  8020be:	76 50                	jbe    802110 <__umoddi3+0x80>
  8020c0:	89 c8                	mov    %ecx,%eax
  8020c2:	89 f2                	mov    %esi,%edx
  8020c4:	f7 f7                	div    %edi
  8020c6:	89 d0                	mov    %edx,%eax
  8020c8:	31 d2                	xor    %edx,%edx
  8020ca:	83 c4 1c             	add    $0x1c,%esp
  8020cd:	5b                   	pop    %ebx
  8020ce:	5e                   	pop    %esi
  8020cf:	5f                   	pop    %edi
  8020d0:	5d                   	pop    %ebp
  8020d1:	c3                   	ret    
  8020d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020d8:	39 f2                	cmp    %esi,%edx
  8020da:	89 d0                	mov    %edx,%eax
  8020dc:	77 52                	ja     802130 <__umoddi3+0xa0>
  8020de:	0f bd ea             	bsr    %edx,%ebp
  8020e1:	83 f5 1f             	xor    $0x1f,%ebp
  8020e4:	75 5a                	jne    802140 <__umoddi3+0xb0>
  8020e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020ea:	0f 82 e0 00 00 00    	jb     8021d0 <__umoddi3+0x140>
  8020f0:	39 0c 24             	cmp    %ecx,(%esp)
  8020f3:	0f 86 d7 00 00 00    	jbe    8021d0 <__umoddi3+0x140>
  8020f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802101:	83 c4 1c             	add    $0x1c,%esp
  802104:	5b                   	pop    %ebx
  802105:	5e                   	pop    %esi
  802106:	5f                   	pop    %edi
  802107:	5d                   	pop    %ebp
  802108:	c3                   	ret    
  802109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802110:	85 ff                	test   %edi,%edi
  802112:	89 fd                	mov    %edi,%ebp
  802114:	75 0b                	jne    802121 <__umoddi3+0x91>
  802116:	b8 01 00 00 00       	mov    $0x1,%eax
  80211b:	31 d2                	xor    %edx,%edx
  80211d:	f7 f7                	div    %edi
  80211f:	89 c5                	mov    %eax,%ebp
  802121:	89 f0                	mov    %esi,%eax
  802123:	31 d2                	xor    %edx,%edx
  802125:	f7 f5                	div    %ebp
  802127:	89 c8                	mov    %ecx,%eax
  802129:	f7 f5                	div    %ebp
  80212b:	89 d0                	mov    %edx,%eax
  80212d:	eb 99                	jmp    8020c8 <__umoddi3+0x38>
  80212f:	90                   	nop
  802130:	89 c8                	mov    %ecx,%eax
  802132:	89 f2                	mov    %esi,%edx
  802134:	83 c4 1c             	add    $0x1c,%esp
  802137:	5b                   	pop    %ebx
  802138:	5e                   	pop    %esi
  802139:	5f                   	pop    %edi
  80213a:	5d                   	pop    %ebp
  80213b:	c3                   	ret    
  80213c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802140:	8b 34 24             	mov    (%esp),%esi
  802143:	bf 20 00 00 00       	mov    $0x20,%edi
  802148:	89 e9                	mov    %ebp,%ecx
  80214a:	29 ef                	sub    %ebp,%edi
  80214c:	d3 e0                	shl    %cl,%eax
  80214e:	89 f9                	mov    %edi,%ecx
  802150:	89 f2                	mov    %esi,%edx
  802152:	d3 ea                	shr    %cl,%edx
  802154:	89 e9                	mov    %ebp,%ecx
  802156:	09 c2                	or     %eax,%edx
  802158:	89 d8                	mov    %ebx,%eax
  80215a:	89 14 24             	mov    %edx,(%esp)
  80215d:	89 f2                	mov    %esi,%edx
  80215f:	d3 e2                	shl    %cl,%edx
  802161:	89 f9                	mov    %edi,%ecx
  802163:	89 54 24 04          	mov    %edx,0x4(%esp)
  802167:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80216b:	d3 e8                	shr    %cl,%eax
  80216d:	89 e9                	mov    %ebp,%ecx
  80216f:	89 c6                	mov    %eax,%esi
  802171:	d3 e3                	shl    %cl,%ebx
  802173:	89 f9                	mov    %edi,%ecx
  802175:	89 d0                	mov    %edx,%eax
  802177:	d3 e8                	shr    %cl,%eax
  802179:	89 e9                	mov    %ebp,%ecx
  80217b:	09 d8                	or     %ebx,%eax
  80217d:	89 d3                	mov    %edx,%ebx
  80217f:	89 f2                	mov    %esi,%edx
  802181:	f7 34 24             	divl   (%esp)
  802184:	89 d6                	mov    %edx,%esi
  802186:	d3 e3                	shl    %cl,%ebx
  802188:	f7 64 24 04          	mull   0x4(%esp)
  80218c:	39 d6                	cmp    %edx,%esi
  80218e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802192:	89 d1                	mov    %edx,%ecx
  802194:	89 c3                	mov    %eax,%ebx
  802196:	72 08                	jb     8021a0 <__umoddi3+0x110>
  802198:	75 11                	jne    8021ab <__umoddi3+0x11b>
  80219a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80219e:	73 0b                	jae    8021ab <__umoddi3+0x11b>
  8021a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021a4:	1b 14 24             	sbb    (%esp),%edx
  8021a7:	89 d1                	mov    %edx,%ecx
  8021a9:	89 c3                	mov    %eax,%ebx
  8021ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021af:	29 da                	sub    %ebx,%edx
  8021b1:	19 ce                	sbb    %ecx,%esi
  8021b3:	89 f9                	mov    %edi,%ecx
  8021b5:	89 f0                	mov    %esi,%eax
  8021b7:	d3 e0                	shl    %cl,%eax
  8021b9:	89 e9                	mov    %ebp,%ecx
  8021bb:	d3 ea                	shr    %cl,%edx
  8021bd:	89 e9                	mov    %ebp,%ecx
  8021bf:	d3 ee                	shr    %cl,%esi
  8021c1:	09 d0                	or     %edx,%eax
  8021c3:	89 f2                	mov    %esi,%edx
  8021c5:	83 c4 1c             	add    $0x1c,%esp
  8021c8:	5b                   	pop    %ebx
  8021c9:	5e                   	pop    %esi
  8021ca:	5f                   	pop    %edi
  8021cb:	5d                   	pop    %ebp
  8021cc:	c3                   	ret    
  8021cd:	8d 76 00             	lea    0x0(%esi),%esi
  8021d0:	29 f9                	sub    %edi,%ecx
  8021d2:	19 d6                	sbb    %edx,%esi
  8021d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021dc:	e9 18 ff ff ff       	jmp    8020f9 <__umoddi3+0x69>
