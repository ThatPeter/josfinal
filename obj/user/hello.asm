
obj/user/hello.debug:     file format elf32-i386


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
  80002c:	e8 2d 00 00 00       	call   80005e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  800039:	68 e0 21 80 00       	push   $0x8021e0
  80003e:	e8 32 01 00 00       	call   800175 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 40 80 00       	mov    0x804004,%eax
  800048:	8b 40 54             	mov    0x54(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 ee 21 80 00       	push   $0x8021ee
  800054:	e8 1c 01 00 00       	call   800175 <cprintf>
}
  800059:	83 c4 10             	add    $0x10,%esp
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800066:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800069:	e8 51 0a 00 00       	call   800abf <sys_getenvid>
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	89 c2                	mov    %eax,%edx
  800075:	c1 e2 07             	shl    $0x7,%edx
  800078:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  80007f:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800084:	85 db                	test   %ebx,%ebx
  800086:	7e 07                	jle    80008f <libmain+0x31>
		binaryname = argv[0];
  800088:	8b 06                	mov    (%esi),%eax
  80008a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80008f:	83 ec 08             	sub    $0x8,%esp
  800092:	56                   	push   %esi
  800093:	53                   	push   %ebx
  800094:	e8 9a ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800099:	e8 2a 00 00 00       	call   8000c8 <exit>
}
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a4:	5b                   	pop    %ebx
  8000a5:	5e                   	pop    %esi
  8000a6:	5d                   	pop    %ebp
  8000a7:	c3                   	ret    

008000a8 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  8000ae:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  8000b3:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8000b5:	e8 05 0a 00 00       	call   800abf <sys_getenvid>
  8000ba:	83 ec 0c             	sub    $0xc,%esp
  8000bd:	50                   	push   %eax
  8000be:	e8 4b 0c 00 00       	call   800d0e <sys_thread_free>
}
  8000c3:	83 c4 10             	add    $0x10,%esp
  8000c6:	c9                   	leave  
  8000c7:	c3                   	ret    

008000c8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ce:	e8 18 11 00 00       	call   8011eb <close_all>
	sys_env_destroy(0);
  8000d3:	83 ec 0c             	sub    $0xc,%esp
  8000d6:	6a 00                	push   $0x0
  8000d8:	e8 a1 09 00 00       	call   800a7e <sys_env_destroy>
}
  8000dd:	83 c4 10             	add    $0x10,%esp
  8000e0:	c9                   	leave  
  8000e1:	c3                   	ret    

008000e2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e2:	55                   	push   %ebp
  8000e3:	89 e5                	mov    %esp,%ebp
  8000e5:	53                   	push   %ebx
  8000e6:	83 ec 04             	sub    $0x4,%esp
  8000e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ec:	8b 13                	mov    (%ebx),%edx
  8000ee:	8d 42 01             	lea    0x1(%edx),%eax
  8000f1:	89 03                	mov    %eax,(%ebx)
  8000f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000fa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ff:	75 1a                	jne    80011b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800101:	83 ec 08             	sub    $0x8,%esp
  800104:	68 ff 00 00 00       	push   $0xff
  800109:	8d 43 08             	lea    0x8(%ebx),%eax
  80010c:	50                   	push   %eax
  80010d:	e8 2f 09 00 00       	call   800a41 <sys_cputs>
		b->idx = 0;
  800112:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800118:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80011b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80011f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800122:	c9                   	leave  
  800123:	c3                   	ret    

00800124 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80012d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800134:	00 00 00 
	b.cnt = 0;
  800137:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800141:	ff 75 0c             	pushl  0xc(%ebp)
  800144:	ff 75 08             	pushl  0x8(%ebp)
  800147:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014d:	50                   	push   %eax
  80014e:	68 e2 00 80 00       	push   $0x8000e2
  800153:	e8 54 01 00 00       	call   8002ac <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800158:	83 c4 08             	add    $0x8,%esp
  80015b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800161:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800167:	50                   	push   %eax
  800168:	e8 d4 08 00 00       	call   800a41 <sys_cputs>

	return b.cnt;
}
  80016d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800173:	c9                   	leave  
  800174:	c3                   	ret    

00800175 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80017b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80017e:	50                   	push   %eax
  80017f:	ff 75 08             	pushl  0x8(%ebp)
  800182:	e8 9d ff ff ff       	call   800124 <vcprintf>
	va_end(ap);

	return cnt;
}
  800187:	c9                   	leave  
  800188:	c3                   	ret    

00800189 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	57                   	push   %edi
  80018d:	56                   	push   %esi
  80018e:	53                   	push   %ebx
  80018f:	83 ec 1c             	sub    $0x1c,%esp
  800192:	89 c7                	mov    %eax,%edi
  800194:	89 d6                	mov    %edx,%esi
  800196:	8b 45 08             	mov    0x8(%ebp),%eax
  800199:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80019f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001aa:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ad:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001b0:	39 d3                	cmp    %edx,%ebx
  8001b2:	72 05                	jb     8001b9 <printnum+0x30>
  8001b4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b7:	77 45                	ja     8001fe <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b9:	83 ec 0c             	sub    $0xc,%esp
  8001bc:	ff 75 18             	pushl  0x18(%ebp)
  8001bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8001c2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001c5:	53                   	push   %ebx
  8001c6:	ff 75 10             	pushl  0x10(%ebp)
  8001c9:	83 ec 08             	sub    $0x8,%esp
  8001cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d2:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d5:	ff 75 d8             	pushl  -0x28(%ebp)
  8001d8:	e8 63 1d 00 00       	call   801f40 <__udivdi3>
  8001dd:	83 c4 18             	add    $0x18,%esp
  8001e0:	52                   	push   %edx
  8001e1:	50                   	push   %eax
  8001e2:	89 f2                	mov    %esi,%edx
  8001e4:	89 f8                	mov    %edi,%eax
  8001e6:	e8 9e ff ff ff       	call   800189 <printnum>
  8001eb:	83 c4 20             	add    $0x20,%esp
  8001ee:	eb 18                	jmp    800208 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001f0:	83 ec 08             	sub    $0x8,%esp
  8001f3:	56                   	push   %esi
  8001f4:	ff 75 18             	pushl  0x18(%ebp)
  8001f7:	ff d7                	call   *%edi
  8001f9:	83 c4 10             	add    $0x10,%esp
  8001fc:	eb 03                	jmp    800201 <printnum+0x78>
  8001fe:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800201:	83 eb 01             	sub    $0x1,%ebx
  800204:	85 db                	test   %ebx,%ebx
  800206:	7f e8                	jg     8001f0 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	56                   	push   %esi
  80020c:	83 ec 04             	sub    $0x4,%esp
  80020f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800212:	ff 75 e0             	pushl  -0x20(%ebp)
  800215:	ff 75 dc             	pushl  -0x24(%ebp)
  800218:	ff 75 d8             	pushl  -0x28(%ebp)
  80021b:	e8 50 1e 00 00       	call   802070 <__umoddi3>
  800220:	83 c4 14             	add    $0x14,%esp
  800223:	0f be 80 0f 22 80 00 	movsbl 0x80220f(%eax),%eax
  80022a:	50                   	push   %eax
  80022b:	ff d7                	call   *%edi
}
  80022d:	83 c4 10             	add    $0x10,%esp
  800230:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800233:	5b                   	pop    %ebx
  800234:	5e                   	pop    %esi
  800235:	5f                   	pop    %edi
  800236:	5d                   	pop    %ebp
  800237:	c3                   	ret    

00800238 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80023b:	83 fa 01             	cmp    $0x1,%edx
  80023e:	7e 0e                	jle    80024e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800240:	8b 10                	mov    (%eax),%edx
  800242:	8d 4a 08             	lea    0x8(%edx),%ecx
  800245:	89 08                	mov    %ecx,(%eax)
  800247:	8b 02                	mov    (%edx),%eax
  800249:	8b 52 04             	mov    0x4(%edx),%edx
  80024c:	eb 22                	jmp    800270 <getuint+0x38>
	else if (lflag)
  80024e:	85 d2                	test   %edx,%edx
  800250:	74 10                	je     800262 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800252:	8b 10                	mov    (%eax),%edx
  800254:	8d 4a 04             	lea    0x4(%edx),%ecx
  800257:	89 08                	mov    %ecx,(%eax)
  800259:	8b 02                	mov    (%edx),%eax
  80025b:	ba 00 00 00 00       	mov    $0x0,%edx
  800260:	eb 0e                	jmp    800270 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800262:	8b 10                	mov    (%eax),%edx
  800264:	8d 4a 04             	lea    0x4(%edx),%ecx
  800267:	89 08                	mov    %ecx,(%eax)
  800269:	8b 02                	mov    (%edx),%eax
  80026b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800270:	5d                   	pop    %ebp
  800271:	c3                   	ret    

00800272 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
  800275:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800278:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80027c:	8b 10                	mov    (%eax),%edx
  80027e:	3b 50 04             	cmp    0x4(%eax),%edx
  800281:	73 0a                	jae    80028d <sprintputch+0x1b>
		*b->buf++ = ch;
  800283:	8d 4a 01             	lea    0x1(%edx),%ecx
  800286:	89 08                	mov    %ecx,(%eax)
  800288:	8b 45 08             	mov    0x8(%ebp),%eax
  80028b:	88 02                	mov    %al,(%edx)
}
  80028d:	5d                   	pop    %ebp
  80028e:	c3                   	ret    

0080028f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
  800292:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800295:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800298:	50                   	push   %eax
  800299:	ff 75 10             	pushl  0x10(%ebp)
  80029c:	ff 75 0c             	pushl  0xc(%ebp)
  80029f:	ff 75 08             	pushl  0x8(%ebp)
  8002a2:	e8 05 00 00 00       	call   8002ac <vprintfmt>
	va_end(ap);
}
  8002a7:	83 c4 10             	add    $0x10,%esp
  8002aa:	c9                   	leave  
  8002ab:	c3                   	ret    

008002ac <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
  8002af:	57                   	push   %edi
  8002b0:	56                   	push   %esi
  8002b1:	53                   	push   %ebx
  8002b2:	83 ec 2c             	sub    $0x2c,%esp
  8002b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002bb:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002be:	eb 12                	jmp    8002d2 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002c0:	85 c0                	test   %eax,%eax
  8002c2:	0f 84 89 03 00 00    	je     800651 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002c8:	83 ec 08             	sub    $0x8,%esp
  8002cb:	53                   	push   %ebx
  8002cc:	50                   	push   %eax
  8002cd:	ff d6                	call   *%esi
  8002cf:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002d2:	83 c7 01             	add    $0x1,%edi
  8002d5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002d9:	83 f8 25             	cmp    $0x25,%eax
  8002dc:	75 e2                	jne    8002c0 <vprintfmt+0x14>
  8002de:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002e2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002e9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002f0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fc:	eb 07                	jmp    800305 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800301:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800305:	8d 47 01             	lea    0x1(%edi),%eax
  800308:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80030b:	0f b6 07             	movzbl (%edi),%eax
  80030e:	0f b6 c8             	movzbl %al,%ecx
  800311:	83 e8 23             	sub    $0x23,%eax
  800314:	3c 55                	cmp    $0x55,%al
  800316:	0f 87 1a 03 00 00    	ja     800636 <vprintfmt+0x38a>
  80031c:	0f b6 c0             	movzbl %al,%eax
  80031f:	ff 24 85 60 23 80 00 	jmp    *0x802360(,%eax,4)
  800326:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800329:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80032d:	eb d6                	jmp    800305 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800332:	b8 00 00 00 00       	mov    $0x0,%eax
  800337:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80033a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80033d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800341:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800344:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800347:	83 fa 09             	cmp    $0x9,%edx
  80034a:	77 39                	ja     800385 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80034c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80034f:	eb e9                	jmp    80033a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800351:	8b 45 14             	mov    0x14(%ebp),%eax
  800354:	8d 48 04             	lea    0x4(%eax),%ecx
  800357:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80035a:	8b 00                	mov    (%eax),%eax
  80035c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800362:	eb 27                	jmp    80038b <vprintfmt+0xdf>
  800364:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800367:	85 c0                	test   %eax,%eax
  800369:	b9 00 00 00 00       	mov    $0x0,%ecx
  80036e:	0f 49 c8             	cmovns %eax,%ecx
  800371:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800374:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800377:	eb 8c                	jmp    800305 <vprintfmt+0x59>
  800379:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80037c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800383:	eb 80                	jmp    800305 <vprintfmt+0x59>
  800385:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800388:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80038b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80038f:	0f 89 70 ff ff ff    	jns    800305 <vprintfmt+0x59>
				width = precision, precision = -1;
  800395:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800398:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80039b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a2:	e9 5e ff ff ff       	jmp    800305 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003a7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ad:	e9 53 ff ff ff       	jmp    800305 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b5:	8d 50 04             	lea    0x4(%eax),%edx
  8003b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003bb:	83 ec 08             	sub    $0x8,%esp
  8003be:	53                   	push   %ebx
  8003bf:	ff 30                	pushl  (%eax)
  8003c1:	ff d6                	call   *%esi
			break;
  8003c3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003c9:	e9 04 ff ff ff       	jmp    8002d2 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d1:	8d 50 04             	lea    0x4(%eax),%edx
  8003d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d7:	8b 00                	mov    (%eax),%eax
  8003d9:	99                   	cltd   
  8003da:	31 d0                	xor    %edx,%eax
  8003dc:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003de:	83 f8 0f             	cmp    $0xf,%eax
  8003e1:	7f 0b                	jg     8003ee <vprintfmt+0x142>
  8003e3:	8b 14 85 c0 24 80 00 	mov    0x8024c0(,%eax,4),%edx
  8003ea:	85 d2                	test   %edx,%edx
  8003ec:	75 18                	jne    800406 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003ee:	50                   	push   %eax
  8003ef:	68 27 22 80 00       	push   $0x802227
  8003f4:	53                   	push   %ebx
  8003f5:	56                   	push   %esi
  8003f6:	e8 94 fe ff ff       	call   80028f <printfmt>
  8003fb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800401:	e9 cc fe ff ff       	jmp    8002d2 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800406:	52                   	push   %edx
  800407:	68 6d 26 80 00       	push   $0x80266d
  80040c:	53                   	push   %ebx
  80040d:	56                   	push   %esi
  80040e:	e8 7c fe ff ff       	call   80028f <printfmt>
  800413:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800419:	e9 b4 fe ff ff       	jmp    8002d2 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80041e:	8b 45 14             	mov    0x14(%ebp),%eax
  800421:	8d 50 04             	lea    0x4(%eax),%edx
  800424:	89 55 14             	mov    %edx,0x14(%ebp)
  800427:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800429:	85 ff                	test   %edi,%edi
  80042b:	b8 20 22 80 00       	mov    $0x802220,%eax
  800430:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800433:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800437:	0f 8e 94 00 00 00    	jle    8004d1 <vprintfmt+0x225>
  80043d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800441:	0f 84 98 00 00 00    	je     8004df <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800447:	83 ec 08             	sub    $0x8,%esp
  80044a:	ff 75 d0             	pushl  -0x30(%ebp)
  80044d:	57                   	push   %edi
  80044e:	e8 86 02 00 00       	call   8006d9 <strnlen>
  800453:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800456:	29 c1                	sub    %eax,%ecx
  800458:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80045b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80045e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800462:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800465:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800468:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80046a:	eb 0f                	jmp    80047b <vprintfmt+0x1cf>
					putch(padc, putdat);
  80046c:	83 ec 08             	sub    $0x8,%esp
  80046f:	53                   	push   %ebx
  800470:	ff 75 e0             	pushl  -0x20(%ebp)
  800473:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800475:	83 ef 01             	sub    $0x1,%edi
  800478:	83 c4 10             	add    $0x10,%esp
  80047b:	85 ff                	test   %edi,%edi
  80047d:	7f ed                	jg     80046c <vprintfmt+0x1c0>
  80047f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800482:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800485:	85 c9                	test   %ecx,%ecx
  800487:	b8 00 00 00 00       	mov    $0x0,%eax
  80048c:	0f 49 c1             	cmovns %ecx,%eax
  80048f:	29 c1                	sub    %eax,%ecx
  800491:	89 75 08             	mov    %esi,0x8(%ebp)
  800494:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800497:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80049a:	89 cb                	mov    %ecx,%ebx
  80049c:	eb 4d                	jmp    8004eb <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80049e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004a2:	74 1b                	je     8004bf <vprintfmt+0x213>
  8004a4:	0f be c0             	movsbl %al,%eax
  8004a7:	83 e8 20             	sub    $0x20,%eax
  8004aa:	83 f8 5e             	cmp    $0x5e,%eax
  8004ad:	76 10                	jbe    8004bf <vprintfmt+0x213>
					putch('?', putdat);
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	ff 75 0c             	pushl  0xc(%ebp)
  8004b5:	6a 3f                	push   $0x3f
  8004b7:	ff 55 08             	call   *0x8(%ebp)
  8004ba:	83 c4 10             	add    $0x10,%esp
  8004bd:	eb 0d                	jmp    8004cc <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004bf:	83 ec 08             	sub    $0x8,%esp
  8004c2:	ff 75 0c             	pushl  0xc(%ebp)
  8004c5:	52                   	push   %edx
  8004c6:	ff 55 08             	call   *0x8(%ebp)
  8004c9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004cc:	83 eb 01             	sub    $0x1,%ebx
  8004cf:	eb 1a                	jmp    8004eb <vprintfmt+0x23f>
  8004d1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004da:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004dd:	eb 0c                	jmp    8004eb <vprintfmt+0x23f>
  8004df:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004eb:	83 c7 01             	add    $0x1,%edi
  8004ee:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f2:	0f be d0             	movsbl %al,%edx
  8004f5:	85 d2                	test   %edx,%edx
  8004f7:	74 23                	je     80051c <vprintfmt+0x270>
  8004f9:	85 f6                	test   %esi,%esi
  8004fb:	78 a1                	js     80049e <vprintfmt+0x1f2>
  8004fd:	83 ee 01             	sub    $0x1,%esi
  800500:	79 9c                	jns    80049e <vprintfmt+0x1f2>
  800502:	89 df                	mov    %ebx,%edi
  800504:	8b 75 08             	mov    0x8(%ebp),%esi
  800507:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050a:	eb 18                	jmp    800524 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80050c:	83 ec 08             	sub    $0x8,%esp
  80050f:	53                   	push   %ebx
  800510:	6a 20                	push   $0x20
  800512:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800514:	83 ef 01             	sub    $0x1,%edi
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	eb 08                	jmp    800524 <vprintfmt+0x278>
  80051c:	89 df                	mov    %ebx,%edi
  80051e:	8b 75 08             	mov    0x8(%ebp),%esi
  800521:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800524:	85 ff                	test   %edi,%edi
  800526:	7f e4                	jg     80050c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800528:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80052b:	e9 a2 fd ff ff       	jmp    8002d2 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800530:	83 fa 01             	cmp    $0x1,%edx
  800533:	7e 16                	jle    80054b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800535:	8b 45 14             	mov    0x14(%ebp),%eax
  800538:	8d 50 08             	lea    0x8(%eax),%edx
  80053b:	89 55 14             	mov    %edx,0x14(%ebp)
  80053e:	8b 50 04             	mov    0x4(%eax),%edx
  800541:	8b 00                	mov    (%eax),%eax
  800543:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800546:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800549:	eb 32                	jmp    80057d <vprintfmt+0x2d1>
	else if (lflag)
  80054b:	85 d2                	test   %edx,%edx
  80054d:	74 18                	je     800567 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	8d 50 04             	lea    0x4(%eax),%edx
  800555:	89 55 14             	mov    %edx,0x14(%ebp)
  800558:	8b 00                	mov    (%eax),%eax
  80055a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055d:	89 c1                	mov    %eax,%ecx
  80055f:	c1 f9 1f             	sar    $0x1f,%ecx
  800562:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800565:	eb 16                	jmp    80057d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8d 50 04             	lea    0x4(%eax),%edx
  80056d:	89 55 14             	mov    %edx,0x14(%ebp)
  800570:	8b 00                	mov    (%eax),%eax
  800572:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800575:	89 c1                	mov    %eax,%ecx
  800577:	c1 f9 1f             	sar    $0x1f,%ecx
  80057a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80057d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800580:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800583:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800588:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80058c:	79 74                	jns    800602 <vprintfmt+0x356>
				putch('-', putdat);
  80058e:	83 ec 08             	sub    $0x8,%esp
  800591:	53                   	push   %ebx
  800592:	6a 2d                	push   $0x2d
  800594:	ff d6                	call   *%esi
				num = -(long long) num;
  800596:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800599:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80059c:	f7 d8                	neg    %eax
  80059e:	83 d2 00             	adc    $0x0,%edx
  8005a1:	f7 da                	neg    %edx
  8005a3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005a6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005ab:	eb 55                	jmp    800602 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ad:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b0:	e8 83 fc ff ff       	call   800238 <getuint>
			base = 10;
  8005b5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005ba:	eb 46                	jmp    800602 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005bc:	8d 45 14             	lea    0x14(%ebp),%eax
  8005bf:	e8 74 fc ff ff       	call   800238 <getuint>
			base = 8;
  8005c4:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005c9:	eb 37                	jmp    800602 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005cb:	83 ec 08             	sub    $0x8,%esp
  8005ce:	53                   	push   %ebx
  8005cf:	6a 30                	push   $0x30
  8005d1:	ff d6                	call   *%esi
			putch('x', putdat);
  8005d3:	83 c4 08             	add    $0x8,%esp
  8005d6:	53                   	push   %ebx
  8005d7:	6a 78                	push   $0x78
  8005d9:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005db:	8b 45 14             	mov    0x14(%ebp),%eax
  8005de:	8d 50 04             	lea    0x4(%eax),%edx
  8005e1:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005e4:	8b 00                	mov    (%eax),%eax
  8005e6:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005eb:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005ee:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005f3:	eb 0d                	jmp    800602 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005f5:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f8:	e8 3b fc ff ff       	call   800238 <getuint>
			base = 16;
  8005fd:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800602:	83 ec 0c             	sub    $0xc,%esp
  800605:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800609:	57                   	push   %edi
  80060a:	ff 75 e0             	pushl  -0x20(%ebp)
  80060d:	51                   	push   %ecx
  80060e:	52                   	push   %edx
  80060f:	50                   	push   %eax
  800610:	89 da                	mov    %ebx,%edx
  800612:	89 f0                	mov    %esi,%eax
  800614:	e8 70 fb ff ff       	call   800189 <printnum>
			break;
  800619:	83 c4 20             	add    $0x20,%esp
  80061c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80061f:	e9 ae fc ff ff       	jmp    8002d2 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800624:	83 ec 08             	sub    $0x8,%esp
  800627:	53                   	push   %ebx
  800628:	51                   	push   %ecx
  800629:	ff d6                	call   *%esi
			break;
  80062b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800631:	e9 9c fc ff ff       	jmp    8002d2 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800636:	83 ec 08             	sub    $0x8,%esp
  800639:	53                   	push   %ebx
  80063a:	6a 25                	push   $0x25
  80063c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80063e:	83 c4 10             	add    $0x10,%esp
  800641:	eb 03                	jmp    800646 <vprintfmt+0x39a>
  800643:	83 ef 01             	sub    $0x1,%edi
  800646:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80064a:	75 f7                	jne    800643 <vprintfmt+0x397>
  80064c:	e9 81 fc ff ff       	jmp    8002d2 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800651:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800654:	5b                   	pop    %ebx
  800655:	5e                   	pop    %esi
  800656:	5f                   	pop    %edi
  800657:	5d                   	pop    %ebp
  800658:	c3                   	ret    

00800659 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800659:	55                   	push   %ebp
  80065a:	89 e5                	mov    %esp,%ebp
  80065c:	83 ec 18             	sub    $0x18,%esp
  80065f:	8b 45 08             	mov    0x8(%ebp),%eax
  800662:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800665:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800668:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80066c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80066f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800676:	85 c0                	test   %eax,%eax
  800678:	74 26                	je     8006a0 <vsnprintf+0x47>
  80067a:	85 d2                	test   %edx,%edx
  80067c:	7e 22                	jle    8006a0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80067e:	ff 75 14             	pushl  0x14(%ebp)
  800681:	ff 75 10             	pushl  0x10(%ebp)
  800684:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800687:	50                   	push   %eax
  800688:	68 72 02 80 00       	push   $0x800272
  80068d:	e8 1a fc ff ff       	call   8002ac <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800692:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800695:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800698:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069b:	83 c4 10             	add    $0x10,%esp
  80069e:	eb 05                	jmp    8006a5 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006a5:	c9                   	leave  
  8006a6:	c3                   	ret    

008006a7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006a7:	55                   	push   %ebp
  8006a8:	89 e5                	mov    %esp,%ebp
  8006aa:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ad:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006b0:	50                   	push   %eax
  8006b1:	ff 75 10             	pushl  0x10(%ebp)
  8006b4:	ff 75 0c             	pushl  0xc(%ebp)
  8006b7:	ff 75 08             	pushl  0x8(%ebp)
  8006ba:	e8 9a ff ff ff       	call   800659 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006bf:	c9                   	leave  
  8006c0:	c3                   	ret    

008006c1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006c1:	55                   	push   %ebp
  8006c2:	89 e5                	mov    %esp,%ebp
  8006c4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006cc:	eb 03                	jmp    8006d1 <strlen+0x10>
		n++;
  8006ce:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006d1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006d5:	75 f7                	jne    8006ce <strlen+0xd>
		n++;
	return n;
}
  8006d7:	5d                   	pop    %ebp
  8006d8:	c3                   	ret    

008006d9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006d9:	55                   	push   %ebp
  8006da:	89 e5                	mov    %esp,%ebp
  8006dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006df:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8006e7:	eb 03                	jmp    8006ec <strnlen+0x13>
		n++;
  8006e9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ec:	39 c2                	cmp    %eax,%edx
  8006ee:	74 08                	je     8006f8 <strnlen+0x1f>
  8006f0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006f4:	75 f3                	jne    8006e9 <strnlen+0x10>
  8006f6:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006f8:	5d                   	pop    %ebp
  8006f9:	c3                   	ret    

008006fa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006fa:	55                   	push   %ebp
  8006fb:	89 e5                	mov    %esp,%ebp
  8006fd:	53                   	push   %ebx
  8006fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800701:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800704:	89 c2                	mov    %eax,%edx
  800706:	83 c2 01             	add    $0x1,%edx
  800709:	83 c1 01             	add    $0x1,%ecx
  80070c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800710:	88 5a ff             	mov    %bl,-0x1(%edx)
  800713:	84 db                	test   %bl,%bl
  800715:	75 ef                	jne    800706 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800717:	5b                   	pop    %ebx
  800718:	5d                   	pop    %ebp
  800719:	c3                   	ret    

0080071a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80071a:	55                   	push   %ebp
  80071b:	89 e5                	mov    %esp,%ebp
  80071d:	53                   	push   %ebx
  80071e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800721:	53                   	push   %ebx
  800722:	e8 9a ff ff ff       	call   8006c1 <strlen>
  800727:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80072a:	ff 75 0c             	pushl  0xc(%ebp)
  80072d:	01 d8                	add    %ebx,%eax
  80072f:	50                   	push   %eax
  800730:	e8 c5 ff ff ff       	call   8006fa <strcpy>
	return dst;
}
  800735:	89 d8                	mov    %ebx,%eax
  800737:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80073a:	c9                   	leave  
  80073b:	c3                   	ret    

0080073c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	56                   	push   %esi
  800740:	53                   	push   %ebx
  800741:	8b 75 08             	mov    0x8(%ebp),%esi
  800744:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800747:	89 f3                	mov    %esi,%ebx
  800749:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80074c:	89 f2                	mov    %esi,%edx
  80074e:	eb 0f                	jmp    80075f <strncpy+0x23>
		*dst++ = *src;
  800750:	83 c2 01             	add    $0x1,%edx
  800753:	0f b6 01             	movzbl (%ecx),%eax
  800756:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800759:	80 39 01             	cmpb   $0x1,(%ecx)
  80075c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80075f:	39 da                	cmp    %ebx,%edx
  800761:	75 ed                	jne    800750 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800763:	89 f0                	mov    %esi,%eax
  800765:	5b                   	pop    %ebx
  800766:	5e                   	pop    %esi
  800767:	5d                   	pop    %ebp
  800768:	c3                   	ret    

00800769 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800769:	55                   	push   %ebp
  80076a:	89 e5                	mov    %esp,%ebp
  80076c:	56                   	push   %esi
  80076d:	53                   	push   %ebx
  80076e:	8b 75 08             	mov    0x8(%ebp),%esi
  800771:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800774:	8b 55 10             	mov    0x10(%ebp),%edx
  800777:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800779:	85 d2                	test   %edx,%edx
  80077b:	74 21                	je     80079e <strlcpy+0x35>
  80077d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800781:	89 f2                	mov    %esi,%edx
  800783:	eb 09                	jmp    80078e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800785:	83 c2 01             	add    $0x1,%edx
  800788:	83 c1 01             	add    $0x1,%ecx
  80078b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80078e:	39 c2                	cmp    %eax,%edx
  800790:	74 09                	je     80079b <strlcpy+0x32>
  800792:	0f b6 19             	movzbl (%ecx),%ebx
  800795:	84 db                	test   %bl,%bl
  800797:	75 ec                	jne    800785 <strlcpy+0x1c>
  800799:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80079b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80079e:	29 f0                	sub    %esi,%eax
}
  8007a0:	5b                   	pop    %ebx
  8007a1:	5e                   	pop    %esi
  8007a2:	5d                   	pop    %ebp
  8007a3:	c3                   	ret    

008007a4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007aa:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ad:	eb 06                	jmp    8007b5 <strcmp+0x11>
		p++, q++;
  8007af:	83 c1 01             	add    $0x1,%ecx
  8007b2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007b5:	0f b6 01             	movzbl (%ecx),%eax
  8007b8:	84 c0                	test   %al,%al
  8007ba:	74 04                	je     8007c0 <strcmp+0x1c>
  8007bc:	3a 02                	cmp    (%edx),%al
  8007be:	74 ef                	je     8007af <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007c0:	0f b6 c0             	movzbl %al,%eax
  8007c3:	0f b6 12             	movzbl (%edx),%edx
  8007c6:	29 d0                	sub    %edx,%eax
}
  8007c8:	5d                   	pop    %ebp
  8007c9:	c3                   	ret    

008007ca <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	53                   	push   %ebx
  8007ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d4:	89 c3                	mov    %eax,%ebx
  8007d6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007d9:	eb 06                	jmp    8007e1 <strncmp+0x17>
		n--, p++, q++;
  8007db:	83 c0 01             	add    $0x1,%eax
  8007de:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007e1:	39 d8                	cmp    %ebx,%eax
  8007e3:	74 15                	je     8007fa <strncmp+0x30>
  8007e5:	0f b6 08             	movzbl (%eax),%ecx
  8007e8:	84 c9                	test   %cl,%cl
  8007ea:	74 04                	je     8007f0 <strncmp+0x26>
  8007ec:	3a 0a                	cmp    (%edx),%cl
  8007ee:	74 eb                	je     8007db <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f0:	0f b6 00             	movzbl (%eax),%eax
  8007f3:	0f b6 12             	movzbl (%edx),%edx
  8007f6:	29 d0                	sub    %edx,%eax
  8007f8:	eb 05                	jmp    8007ff <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007fa:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007ff:	5b                   	pop    %ebx
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	8b 45 08             	mov    0x8(%ebp),%eax
  800808:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80080c:	eb 07                	jmp    800815 <strchr+0x13>
		if (*s == c)
  80080e:	38 ca                	cmp    %cl,%dl
  800810:	74 0f                	je     800821 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800812:	83 c0 01             	add    $0x1,%eax
  800815:	0f b6 10             	movzbl (%eax),%edx
  800818:	84 d2                	test   %dl,%dl
  80081a:	75 f2                	jne    80080e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80081c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800821:	5d                   	pop    %ebp
  800822:	c3                   	ret    

00800823 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	8b 45 08             	mov    0x8(%ebp),%eax
  800829:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80082d:	eb 03                	jmp    800832 <strfind+0xf>
  80082f:	83 c0 01             	add    $0x1,%eax
  800832:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800835:	38 ca                	cmp    %cl,%dl
  800837:	74 04                	je     80083d <strfind+0x1a>
  800839:	84 d2                	test   %dl,%dl
  80083b:	75 f2                	jne    80082f <strfind+0xc>
			break;
	return (char *) s;
}
  80083d:	5d                   	pop    %ebp
  80083e:	c3                   	ret    

0080083f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	57                   	push   %edi
  800843:	56                   	push   %esi
  800844:	53                   	push   %ebx
  800845:	8b 7d 08             	mov    0x8(%ebp),%edi
  800848:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80084b:	85 c9                	test   %ecx,%ecx
  80084d:	74 36                	je     800885 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80084f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800855:	75 28                	jne    80087f <memset+0x40>
  800857:	f6 c1 03             	test   $0x3,%cl
  80085a:	75 23                	jne    80087f <memset+0x40>
		c &= 0xFF;
  80085c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800860:	89 d3                	mov    %edx,%ebx
  800862:	c1 e3 08             	shl    $0x8,%ebx
  800865:	89 d6                	mov    %edx,%esi
  800867:	c1 e6 18             	shl    $0x18,%esi
  80086a:	89 d0                	mov    %edx,%eax
  80086c:	c1 e0 10             	shl    $0x10,%eax
  80086f:	09 f0                	or     %esi,%eax
  800871:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800873:	89 d8                	mov    %ebx,%eax
  800875:	09 d0                	or     %edx,%eax
  800877:	c1 e9 02             	shr    $0x2,%ecx
  80087a:	fc                   	cld    
  80087b:	f3 ab                	rep stos %eax,%es:(%edi)
  80087d:	eb 06                	jmp    800885 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80087f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800882:	fc                   	cld    
  800883:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800885:	89 f8                	mov    %edi,%eax
  800887:	5b                   	pop    %ebx
  800888:	5e                   	pop    %esi
  800889:	5f                   	pop    %edi
  80088a:	5d                   	pop    %ebp
  80088b:	c3                   	ret    

0080088c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	57                   	push   %edi
  800890:	56                   	push   %esi
  800891:	8b 45 08             	mov    0x8(%ebp),%eax
  800894:	8b 75 0c             	mov    0xc(%ebp),%esi
  800897:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80089a:	39 c6                	cmp    %eax,%esi
  80089c:	73 35                	jae    8008d3 <memmove+0x47>
  80089e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008a1:	39 d0                	cmp    %edx,%eax
  8008a3:	73 2e                	jae    8008d3 <memmove+0x47>
		s += n;
		d += n;
  8008a5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008a8:	89 d6                	mov    %edx,%esi
  8008aa:	09 fe                	or     %edi,%esi
  8008ac:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008b2:	75 13                	jne    8008c7 <memmove+0x3b>
  8008b4:	f6 c1 03             	test   $0x3,%cl
  8008b7:	75 0e                	jne    8008c7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008b9:	83 ef 04             	sub    $0x4,%edi
  8008bc:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008bf:	c1 e9 02             	shr    $0x2,%ecx
  8008c2:	fd                   	std    
  8008c3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c5:	eb 09                	jmp    8008d0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008c7:	83 ef 01             	sub    $0x1,%edi
  8008ca:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008cd:	fd                   	std    
  8008ce:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008d0:	fc                   	cld    
  8008d1:	eb 1d                	jmp    8008f0 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d3:	89 f2                	mov    %esi,%edx
  8008d5:	09 c2                	or     %eax,%edx
  8008d7:	f6 c2 03             	test   $0x3,%dl
  8008da:	75 0f                	jne    8008eb <memmove+0x5f>
  8008dc:	f6 c1 03             	test   $0x3,%cl
  8008df:	75 0a                	jne    8008eb <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008e1:	c1 e9 02             	shr    $0x2,%ecx
  8008e4:	89 c7                	mov    %eax,%edi
  8008e6:	fc                   	cld    
  8008e7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e9:	eb 05                	jmp    8008f0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008eb:	89 c7                	mov    %eax,%edi
  8008ed:	fc                   	cld    
  8008ee:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008f0:	5e                   	pop    %esi
  8008f1:	5f                   	pop    %edi
  8008f2:	5d                   	pop    %ebp
  8008f3:	c3                   	ret    

008008f4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008f7:	ff 75 10             	pushl  0x10(%ebp)
  8008fa:	ff 75 0c             	pushl  0xc(%ebp)
  8008fd:	ff 75 08             	pushl  0x8(%ebp)
  800900:	e8 87 ff ff ff       	call   80088c <memmove>
}
  800905:	c9                   	leave  
  800906:	c3                   	ret    

00800907 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	56                   	push   %esi
  80090b:	53                   	push   %ebx
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800912:	89 c6                	mov    %eax,%esi
  800914:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800917:	eb 1a                	jmp    800933 <memcmp+0x2c>
		if (*s1 != *s2)
  800919:	0f b6 08             	movzbl (%eax),%ecx
  80091c:	0f b6 1a             	movzbl (%edx),%ebx
  80091f:	38 d9                	cmp    %bl,%cl
  800921:	74 0a                	je     80092d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800923:	0f b6 c1             	movzbl %cl,%eax
  800926:	0f b6 db             	movzbl %bl,%ebx
  800929:	29 d8                	sub    %ebx,%eax
  80092b:	eb 0f                	jmp    80093c <memcmp+0x35>
		s1++, s2++;
  80092d:	83 c0 01             	add    $0x1,%eax
  800930:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800933:	39 f0                	cmp    %esi,%eax
  800935:	75 e2                	jne    800919 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800937:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093c:	5b                   	pop    %ebx
  80093d:	5e                   	pop    %esi
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	53                   	push   %ebx
  800944:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800947:	89 c1                	mov    %eax,%ecx
  800949:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80094c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800950:	eb 0a                	jmp    80095c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800952:	0f b6 10             	movzbl (%eax),%edx
  800955:	39 da                	cmp    %ebx,%edx
  800957:	74 07                	je     800960 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800959:	83 c0 01             	add    $0x1,%eax
  80095c:	39 c8                	cmp    %ecx,%eax
  80095e:	72 f2                	jb     800952 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800960:	5b                   	pop    %ebx
  800961:	5d                   	pop    %ebp
  800962:	c3                   	ret    

00800963 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	57                   	push   %edi
  800967:	56                   	push   %esi
  800968:	53                   	push   %ebx
  800969:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80096c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80096f:	eb 03                	jmp    800974 <strtol+0x11>
		s++;
  800971:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800974:	0f b6 01             	movzbl (%ecx),%eax
  800977:	3c 20                	cmp    $0x20,%al
  800979:	74 f6                	je     800971 <strtol+0xe>
  80097b:	3c 09                	cmp    $0x9,%al
  80097d:	74 f2                	je     800971 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80097f:	3c 2b                	cmp    $0x2b,%al
  800981:	75 0a                	jne    80098d <strtol+0x2a>
		s++;
  800983:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800986:	bf 00 00 00 00       	mov    $0x0,%edi
  80098b:	eb 11                	jmp    80099e <strtol+0x3b>
  80098d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800992:	3c 2d                	cmp    $0x2d,%al
  800994:	75 08                	jne    80099e <strtol+0x3b>
		s++, neg = 1;
  800996:	83 c1 01             	add    $0x1,%ecx
  800999:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80099e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009a4:	75 15                	jne    8009bb <strtol+0x58>
  8009a6:	80 39 30             	cmpb   $0x30,(%ecx)
  8009a9:	75 10                	jne    8009bb <strtol+0x58>
  8009ab:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009af:	75 7c                	jne    800a2d <strtol+0xca>
		s += 2, base = 16;
  8009b1:	83 c1 02             	add    $0x2,%ecx
  8009b4:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009b9:	eb 16                	jmp    8009d1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009bb:	85 db                	test   %ebx,%ebx
  8009bd:	75 12                	jne    8009d1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009bf:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009c4:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c7:	75 08                	jne    8009d1 <strtol+0x6e>
		s++, base = 8;
  8009c9:	83 c1 01             	add    $0x1,%ecx
  8009cc:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009d9:	0f b6 11             	movzbl (%ecx),%edx
  8009dc:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009df:	89 f3                	mov    %esi,%ebx
  8009e1:	80 fb 09             	cmp    $0x9,%bl
  8009e4:	77 08                	ja     8009ee <strtol+0x8b>
			dig = *s - '0';
  8009e6:	0f be d2             	movsbl %dl,%edx
  8009e9:	83 ea 30             	sub    $0x30,%edx
  8009ec:	eb 22                	jmp    800a10 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009ee:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009f1:	89 f3                	mov    %esi,%ebx
  8009f3:	80 fb 19             	cmp    $0x19,%bl
  8009f6:	77 08                	ja     800a00 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009f8:	0f be d2             	movsbl %dl,%edx
  8009fb:	83 ea 57             	sub    $0x57,%edx
  8009fe:	eb 10                	jmp    800a10 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a00:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a03:	89 f3                	mov    %esi,%ebx
  800a05:	80 fb 19             	cmp    $0x19,%bl
  800a08:	77 16                	ja     800a20 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a0a:	0f be d2             	movsbl %dl,%edx
  800a0d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a10:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a13:	7d 0b                	jge    800a20 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a15:	83 c1 01             	add    $0x1,%ecx
  800a18:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a1c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a1e:	eb b9                	jmp    8009d9 <strtol+0x76>

	if (endptr)
  800a20:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a24:	74 0d                	je     800a33 <strtol+0xd0>
		*endptr = (char *) s;
  800a26:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a29:	89 0e                	mov    %ecx,(%esi)
  800a2b:	eb 06                	jmp    800a33 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a2d:	85 db                	test   %ebx,%ebx
  800a2f:	74 98                	je     8009c9 <strtol+0x66>
  800a31:	eb 9e                	jmp    8009d1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a33:	89 c2                	mov    %eax,%edx
  800a35:	f7 da                	neg    %edx
  800a37:	85 ff                	test   %edi,%edi
  800a39:	0f 45 c2             	cmovne %edx,%eax
}
  800a3c:	5b                   	pop    %ebx
  800a3d:	5e                   	pop    %esi
  800a3e:	5f                   	pop    %edi
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	57                   	push   %edi
  800a45:	56                   	push   %esi
  800a46:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a47:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a52:	89 c3                	mov    %eax,%ebx
  800a54:	89 c7                	mov    %eax,%edi
  800a56:	89 c6                	mov    %eax,%esi
  800a58:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a5a:	5b                   	pop    %ebx
  800a5b:	5e                   	pop    %esi
  800a5c:	5f                   	pop    %edi
  800a5d:	5d                   	pop    %ebp
  800a5e:	c3                   	ret    

00800a5f <sys_cgetc>:

int
sys_cgetc(void)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	57                   	push   %edi
  800a63:	56                   	push   %esi
  800a64:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a65:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6a:	b8 01 00 00 00       	mov    $0x1,%eax
  800a6f:	89 d1                	mov    %edx,%ecx
  800a71:	89 d3                	mov    %edx,%ebx
  800a73:	89 d7                	mov    %edx,%edi
  800a75:	89 d6                	mov    %edx,%esi
  800a77:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a79:	5b                   	pop    %ebx
  800a7a:	5e                   	pop    %esi
  800a7b:	5f                   	pop    %edi
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	57                   	push   %edi
  800a82:	56                   	push   %esi
  800a83:	53                   	push   %ebx
  800a84:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a87:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a8c:	b8 03 00 00 00       	mov    $0x3,%eax
  800a91:	8b 55 08             	mov    0x8(%ebp),%edx
  800a94:	89 cb                	mov    %ecx,%ebx
  800a96:	89 cf                	mov    %ecx,%edi
  800a98:	89 ce                	mov    %ecx,%esi
  800a9a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a9c:	85 c0                	test   %eax,%eax
  800a9e:	7e 17                	jle    800ab7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aa0:	83 ec 0c             	sub    $0xc,%esp
  800aa3:	50                   	push   %eax
  800aa4:	6a 03                	push   $0x3
  800aa6:	68 1f 25 80 00       	push   $0x80251f
  800aab:	6a 23                	push   $0x23
  800aad:	68 3c 25 80 00       	push   $0x80253c
  800ab2:	e8 53 12 00 00       	call   801d0a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ab7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aba:	5b                   	pop    %ebx
  800abb:	5e                   	pop    %esi
  800abc:	5f                   	pop    %edi
  800abd:	5d                   	pop    %ebp
  800abe:	c3                   	ret    

00800abf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	57                   	push   %edi
  800ac3:	56                   	push   %esi
  800ac4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aca:	b8 02 00 00 00       	mov    $0x2,%eax
  800acf:	89 d1                	mov    %edx,%ecx
  800ad1:	89 d3                	mov    %edx,%ebx
  800ad3:	89 d7                	mov    %edx,%edi
  800ad5:	89 d6                	mov    %edx,%esi
  800ad7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ad9:	5b                   	pop    %ebx
  800ada:	5e                   	pop    %esi
  800adb:	5f                   	pop    %edi
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <sys_yield>:

void
sys_yield(void)
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
  800ae4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800aee:	89 d1                	mov    %edx,%ecx
  800af0:	89 d3                	mov    %edx,%ebx
  800af2:	89 d7                	mov    %edx,%edi
  800af4:	89 d6                	mov    %edx,%esi
  800af6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
  800b03:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b06:	be 00 00 00 00       	mov    $0x0,%esi
  800b0b:	b8 04 00 00 00       	mov    $0x4,%eax
  800b10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b13:	8b 55 08             	mov    0x8(%ebp),%edx
  800b16:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b19:	89 f7                	mov    %esi,%edi
  800b1b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b1d:	85 c0                	test   %eax,%eax
  800b1f:	7e 17                	jle    800b38 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b21:	83 ec 0c             	sub    $0xc,%esp
  800b24:	50                   	push   %eax
  800b25:	6a 04                	push   $0x4
  800b27:	68 1f 25 80 00       	push   $0x80251f
  800b2c:	6a 23                	push   $0x23
  800b2e:	68 3c 25 80 00       	push   $0x80253c
  800b33:	e8 d2 11 00 00       	call   801d0a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b3b:	5b                   	pop    %ebx
  800b3c:	5e                   	pop    %esi
  800b3d:	5f                   	pop    %edi
  800b3e:	5d                   	pop    %ebp
  800b3f:	c3                   	ret    

00800b40 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
  800b46:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b49:	b8 05 00 00 00       	mov    $0x5,%eax
  800b4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b51:	8b 55 08             	mov    0x8(%ebp),%edx
  800b54:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b57:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b5a:	8b 75 18             	mov    0x18(%ebp),%esi
  800b5d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b5f:	85 c0                	test   %eax,%eax
  800b61:	7e 17                	jle    800b7a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b63:	83 ec 0c             	sub    $0xc,%esp
  800b66:	50                   	push   %eax
  800b67:	6a 05                	push   $0x5
  800b69:	68 1f 25 80 00       	push   $0x80251f
  800b6e:	6a 23                	push   $0x23
  800b70:	68 3c 25 80 00       	push   $0x80253c
  800b75:	e8 90 11 00 00       	call   801d0a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7d:	5b                   	pop    %ebx
  800b7e:	5e                   	pop    %esi
  800b7f:	5f                   	pop    %edi
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	57                   	push   %edi
  800b86:	56                   	push   %esi
  800b87:	53                   	push   %ebx
  800b88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b90:	b8 06 00 00 00       	mov    $0x6,%eax
  800b95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b98:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9b:	89 df                	mov    %ebx,%edi
  800b9d:	89 de                	mov    %ebx,%esi
  800b9f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba1:	85 c0                	test   %eax,%eax
  800ba3:	7e 17                	jle    800bbc <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba5:	83 ec 0c             	sub    $0xc,%esp
  800ba8:	50                   	push   %eax
  800ba9:	6a 06                	push   $0x6
  800bab:	68 1f 25 80 00       	push   $0x80251f
  800bb0:	6a 23                	push   $0x23
  800bb2:	68 3c 25 80 00       	push   $0x80253c
  800bb7:	e8 4e 11 00 00       	call   801d0a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
  800bca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd2:	b8 08 00 00 00       	mov    $0x8,%eax
  800bd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bda:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdd:	89 df                	mov    %ebx,%edi
  800bdf:	89 de                	mov    %ebx,%esi
  800be1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be3:	85 c0                	test   %eax,%eax
  800be5:	7e 17                	jle    800bfe <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be7:	83 ec 0c             	sub    $0xc,%esp
  800bea:	50                   	push   %eax
  800beb:	6a 08                	push   $0x8
  800bed:	68 1f 25 80 00       	push   $0x80251f
  800bf2:	6a 23                	push   $0x23
  800bf4:	68 3c 25 80 00       	push   $0x80253c
  800bf9:	e8 0c 11 00 00       	call   801d0a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c01:	5b                   	pop    %ebx
  800c02:	5e                   	pop    %esi
  800c03:	5f                   	pop    %edi
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	57                   	push   %edi
  800c0a:	56                   	push   %esi
  800c0b:	53                   	push   %ebx
  800c0c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c14:	b8 09 00 00 00       	mov    $0x9,%eax
  800c19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1f:	89 df                	mov    %ebx,%edi
  800c21:	89 de                	mov    %ebx,%esi
  800c23:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c25:	85 c0                	test   %eax,%eax
  800c27:	7e 17                	jle    800c40 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c29:	83 ec 0c             	sub    $0xc,%esp
  800c2c:	50                   	push   %eax
  800c2d:	6a 09                	push   $0x9
  800c2f:	68 1f 25 80 00       	push   $0x80251f
  800c34:	6a 23                	push   $0x23
  800c36:	68 3c 25 80 00       	push   $0x80253c
  800c3b:	e8 ca 10 00 00       	call   801d0a <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c43:	5b                   	pop    %ebx
  800c44:	5e                   	pop    %esi
  800c45:	5f                   	pop    %edi
  800c46:	5d                   	pop    %ebp
  800c47:	c3                   	ret    

00800c48 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	57                   	push   %edi
  800c4c:	56                   	push   %esi
  800c4d:	53                   	push   %ebx
  800c4e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c51:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c56:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c61:	89 df                	mov    %ebx,%edi
  800c63:	89 de                	mov    %ebx,%esi
  800c65:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c67:	85 c0                	test   %eax,%eax
  800c69:	7e 17                	jle    800c82 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6b:	83 ec 0c             	sub    $0xc,%esp
  800c6e:	50                   	push   %eax
  800c6f:	6a 0a                	push   $0xa
  800c71:	68 1f 25 80 00       	push   $0x80251f
  800c76:	6a 23                	push   $0x23
  800c78:	68 3c 25 80 00       	push   $0x80253c
  800c7d:	e8 88 10 00 00       	call   801d0a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	57                   	push   %edi
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c90:	be 00 00 00 00       	mov    $0x0,%esi
  800c95:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca6:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5f                   	pop    %edi
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    

00800cad <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	57                   	push   %edi
  800cb1:	56                   	push   %esi
  800cb2:	53                   	push   %ebx
  800cb3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cbb:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc3:	89 cb                	mov    %ecx,%ebx
  800cc5:	89 cf                	mov    %ecx,%edi
  800cc7:	89 ce                	mov    %ecx,%esi
  800cc9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ccb:	85 c0                	test   %eax,%eax
  800ccd:	7e 17                	jle    800ce6 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccf:	83 ec 0c             	sub    $0xc,%esp
  800cd2:	50                   	push   %eax
  800cd3:	6a 0d                	push   $0xd
  800cd5:	68 1f 25 80 00       	push   $0x80251f
  800cda:	6a 23                	push   $0x23
  800cdc:	68 3c 25 80 00       	push   $0x80253c
  800ce1:	e8 24 10 00 00       	call   801d0a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ce6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce9:	5b                   	pop    %ebx
  800cea:	5e                   	pop    %esi
  800ceb:	5f                   	pop    %edi
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    

00800cee <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	57                   	push   %edi
  800cf2:	56                   	push   %esi
  800cf3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf9:	b8 0e 00 00 00       	mov    $0xe,%eax
  800cfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800d01:	89 cb                	mov    %ecx,%ebx
  800d03:	89 cf                	mov    %ecx,%edi
  800d05:	89 ce                	mov    %ecx,%esi
  800d07:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d09:	5b                   	pop    %ebx
  800d0a:	5e                   	pop    %esi
  800d0b:	5f                   	pop    %edi
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    

00800d0e <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d14:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d19:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d21:	89 cb                	mov    %ecx,%ebx
  800d23:	89 cf                	mov    %ecx,%edi
  800d25:	89 ce                	mov    %ecx,%esi
  800d27:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800d29:	5b                   	pop    %ebx
  800d2a:	5e                   	pop    %esi
  800d2b:	5f                   	pop    %edi
  800d2c:	5d                   	pop    %ebp
  800d2d:	c3                   	ret    

00800d2e <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	53                   	push   %ebx
  800d32:	83 ec 04             	sub    $0x4,%esp
  800d35:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d38:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800d3a:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d3e:	74 11                	je     800d51 <pgfault+0x23>
  800d40:	89 d8                	mov    %ebx,%eax
  800d42:	c1 e8 0c             	shr    $0xc,%eax
  800d45:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d4c:	f6 c4 08             	test   $0x8,%ah
  800d4f:	75 14                	jne    800d65 <pgfault+0x37>
		panic("faulting access");
  800d51:	83 ec 04             	sub    $0x4,%esp
  800d54:	68 4a 25 80 00       	push   $0x80254a
  800d59:	6a 1e                	push   $0x1e
  800d5b:	68 5a 25 80 00       	push   $0x80255a
  800d60:	e8 a5 0f 00 00       	call   801d0a <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800d65:	83 ec 04             	sub    $0x4,%esp
  800d68:	6a 07                	push   $0x7
  800d6a:	68 00 f0 7f 00       	push   $0x7ff000
  800d6f:	6a 00                	push   $0x0
  800d71:	e8 87 fd ff ff       	call   800afd <sys_page_alloc>
	if (r < 0) {
  800d76:	83 c4 10             	add    $0x10,%esp
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	79 12                	jns    800d8f <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800d7d:	50                   	push   %eax
  800d7e:	68 65 25 80 00       	push   $0x802565
  800d83:	6a 2c                	push   $0x2c
  800d85:	68 5a 25 80 00       	push   $0x80255a
  800d8a:	e8 7b 0f 00 00       	call   801d0a <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800d8f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800d95:	83 ec 04             	sub    $0x4,%esp
  800d98:	68 00 10 00 00       	push   $0x1000
  800d9d:	53                   	push   %ebx
  800d9e:	68 00 f0 7f 00       	push   $0x7ff000
  800da3:	e8 4c fb ff ff       	call   8008f4 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800da8:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800daf:	53                   	push   %ebx
  800db0:	6a 00                	push   $0x0
  800db2:	68 00 f0 7f 00       	push   $0x7ff000
  800db7:	6a 00                	push   $0x0
  800db9:	e8 82 fd ff ff       	call   800b40 <sys_page_map>
	if (r < 0) {
  800dbe:	83 c4 20             	add    $0x20,%esp
  800dc1:	85 c0                	test   %eax,%eax
  800dc3:	79 12                	jns    800dd7 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800dc5:	50                   	push   %eax
  800dc6:	68 65 25 80 00       	push   $0x802565
  800dcb:	6a 33                	push   $0x33
  800dcd:	68 5a 25 80 00       	push   $0x80255a
  800dd2:	e8 33 0f 00 00       	call   801d0a <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800dd7:	83 ec 08             	sub    $0x8,%esp
  800dda:	68 00 f0 7f 00       	push   $0x7ff000
  800ddf:	6a 00                	push   $0x0
  800de1:	e8 9c fd ff ff       	call   800b82 <sys_page_unmap>
	if (r < 0) {
  800de6:	83 c4 10             	add    $0x10,%esp
  800de9:	85 c0                	test   %eax,%eax
  800deb:	79 12                	jns    800dff <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800ded:	50                   	push   %eax
  800dee:	68 65 25 80 00       	push   $0x802565
  800df3:	6a 37                	push   $0x37
  800df5:	68 5a 25 80 00       	push   $0x80255a
  800dfa:	e8 0b 0f 00 00       	call   801d0a <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800dff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e02:	c9                   	leave  
  800e03:	c3                   	ret    

00800e04 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	57                   	push   %edi
  800e08:	56                   	push   %esi
  800e09:	53                   	push   %ebx
  800e0a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e0d:	68 2e 0d 80 00       	push   $0x800d2e
  800e12:	e8 39 0f 00 00       	call   801d50 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e17:	b8 07 00 00 00       	mov    $0x7,%eax
  800e1c:	cd 30                	int    $0x30
  800e1e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800e21:	83 c4 10             	add    $0x10,%esp
  800e24:	85 c0                	test   %eax,%eax
  800e26:	79 17                	jns    800e3f <fork+0x3b>
		panic("fork fault %e");
  800e28:	83 ec 04             	sub    $0x4,%esp
  800e2b:	68 7e 25 80 00       	push   $0x80257e
  800e30:	68 84 00 00 00       	push   $0x84
  800e35:	68 5a 25 80 00       	push   $0x80255a
  800e3a:	e8 cb 0e 00 00       	call   801d0a <_panic>
  800e3f:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800e41:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e45:	75 25                	jne    800e6c <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e47:	e8 73 fc ff ff       	call   800abf <sys_getenvid>
  800e4c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e51:	89 c2                	mov    %eax,%edx
  800e53:	c1 e2 07             	shl    $0x7,%edx
  800e56:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800e5d:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800e62:	b8 00 00 00 00       	mov    $0x0,%eax
  800e67:	e9 61 01 00 00       	jmp    800fcd <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800e6c:	83 ec 04             	sub    $0x4,%esp
  800e6f:	6a 07                	push   $0x7
  800e71:	68 00 f0 bf ee       	push   $0xeebff000
  800e76:	ff 75 e4             	pushl  -0x1c(%ebp)
  800e79:	e8 7f fc ff ff       	call   800afd <sys_page_alloc>
  800e7e:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800e81:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800e86:	89 d8                	mov    %ebx,%eax
  800e88:	c1 e8 16             	shr    $0x16,%eax
  800e8b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e92:	a8 01                	test   $0x1,%al
  800e94:	0f 84 fc 00 00 00    	je     800f96 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800e9a:	89 d8                	mov    %ebx,%eax
  800e9c:	c1 e8 0c             	shr    $0xc,%eax
  800e9f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ea6:	f6 c2 01             	test   $0x1,%dl
  800ea9:	0f 84 e7 00 00 00    	je     800f96 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800eaf:	89 c6                	mov    %eax,%esi
  800eb1:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800eb4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ebb:	f6 c6 04             	test   $0x4,%dh
  800ebe:	74 39                	je     800ef9 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800ec0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ec7:	83 ec 0c             	sub    $0xc,%esp
  800eca:	25 07 0e 00 00       	and    $0xe07,%eax
  800ecf:	50                   	push   %eax
  800ed0:	56                   	push   %esi
  800ed1:	57                   	push   %edi
  800ed2:	56                   	push   %esi
  800ed3:	6a 00                	push   $0x0
  800ed5:	e8 66 fc ff ff       	call   800b40 <sys_page_map>
		if (r < 0) {
  800eda:	83 c4 20             	add    $0x20,%esp
  800edd:	85 c0                	test   %eax,%eax
  800edf:	0f 89 b1 00 00 00    	jns    800f96 <fork+0x192>
		    	panic("sys page map fault %e");
  800ee5:	83 ec 04             	sub    $0x4,%esp
  800ee8:	68 8c 25 80 00       	push   $0x80258c
  800eed:	6a 54                	push   $0x54
  800eef:	68 5a 25 80 00       	push   $0x80255a
  800ef4:	e8 11 0e 00 00       	call   801d0a <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800ef9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f00:	f6 c2 02             	test   $0x2,%dl
  800f03:	75 0c                	jne    800f11 <fork+0x10d>
  800f05:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f0c:	f6 c4 08             	test   $0x8,%ah
  800f0f:	74 5b                	je     800f6c <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f11:	83 ec 0c             	sub    $0xc,%esp
  800f14:	68 05 08 00 00       	push   $0x805
  800f19:	56                   	push   %esi
  800f1a:	57                   	push   %edi
  800f1b:	56                   	push   %esi
  800f1c:	6a 00                	push   $0x0
  800f1e:	e8 1d fc ff ff       	call   800b40 <sys_page_map>
		if (r < 0) {
  800f23:	83 c4 20             	add    $0x20,%esp
  800f26:	85 c0                	test   %eax,%eax
  800f28:	79 14                	jns    800f3e <fork+0x13a>
		    	panic("sys page map fault %e");
  800f2a:	83 ec 04             	sub    $0x4,%esp
  800f2d:	68 8c 25 80 00       	push   $0x80258c
  800f32:	6a 5b                	push   $0x5b
  800f34:	68 5a 25 80 00       	push   $0x80255a
  800f39:	e8 cc 0d 00 00       	call   801d0a <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800f3e:	83 ec 0c             	sub    $0xc,%esp
  800f41:	68 05 08 00 00       	push   $0x805
  800f46:	56                   	push   %esi
  800f47:	6a 00                	push   $0x0
  800f49:	56                   	push   %esi
  800f4a:	6a 00                	push   $0x0
  800f4c:	e8 ef fb ff ff       	call   800b40 <sys_page_map>
		if (r < 0) {
  800f51:	83 c4 20             	add    $0x20,%esp
  800f54:	85 c0                	test   %eax,%eax
  800f56:	79 3e                	jns    800f96 <fork+0x192>
		    	panic("sys page map fault %e");
  800f58:	83 ec 04             	sub    $0x4,%esp
  800f5b:	68 8c 25 80 00       	push   $0x80258c
  800f60:	6a 5f                	push   $0x5f
  800f62:	68 5a 25 80 00       	push   $0x80255a
  800f67:	e8 9e 0d 00 00       	call   801d0a <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800f6c:	83 ec 0c             	sub    $0xc,%esp
  800f6f:	6a 05                	push   $0x5
  800f71:	56                   	push   %esi
  800f72:	57                   	push   %edi
  800f73:	56                   	push   %esi
  800f74:	6a 00                	push   $0x0
  800f76:	e8 c5 fb ff ff       	call   800b40 <sys_page_map>
		if (r < 0) {
  800f7b:	83 c4 20             	add    $0x20,%esp
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	79 14                	jns    800f96 <fork+0x192>
		    	panic("sys page map fault %e");
  800f82:	83 ec 04             	sub    $0x4,%esp
  800f85:	68 8c 25 80 00       	push   $0x80258c
  800f8a:	6a 64                	push   $0x64
  800f8c:	68 5a 25 80 00       	push   $0x80255a
  800f91:	e8 74 0d 00 00       	call   801d0a <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f96:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f9c:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800fa2:	0f 85 de fe ff ff    	jne    800e86 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800fa8:	a1 04 40 80 00       	mov    0x804004,%eax
  800fad:	8b 40 70             	mov    0x70(%eax),%eax
  800fb0:	83 ec 08             	sub    $0x8,%esp
  800fb3:	50                   	push   %eax
  800fb4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800fb7:	57                   	push   %edi
  800fb8:	e8 8b fc ff ff       	call   800c48 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  800fbd:	83 c4 08             	add    $0x8,%esp
  800fc0:	6a 02                	push   $0x2
  800fc2:	57                   	push   %edi
  800fc3:	e8 fc fb ff ff       	call   800bc4 <sys_env_set_status>
	
	return envid;
  800fc8:	83 c4 10             	add    $0x10,%esp
  800fcb:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  800fcd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fd0:	5b                   	pop    %ebx
  800fd1:	5e                   	pop    %esi
  800fd2:	5f                   	pop    %edi
  800fd3:	5d                   	pop    %ebp
  800fd4:	c3                   	ret    

00800fd5 <sfork>:

envid_t
sfork(void)
{
  800fd5:	55                   	push   %ebp
  800fd6:	89 e5                	mov    %esp,%ebp
	return 0;
}
  800fd8:	b8 00 00 00 00       	mov    $0x0,%eax
  800fdd:	5d                   	pop    %ebp
  800fde:	c3                   	ret    

00800fdf <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  800fdf:	55                   	push   %ebp
  800fe0:	89 e5                	mov    %esp,%ebp
  800fe2:	56                   	push   %esi
  800fe3:	53                   	push   %ebx
  800fe4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  800fe7:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  800fed:	83 ec 08             	sub    $0x8,%esp
  800ff0:	53                   	push   %ebx
  800ff1:	68 a4 25 80 00       	push   $0x8025a4
  800ff6:	e8 7a f1 ff ff       	call   800175 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  800ffb:	c7 04 24 a8 00 80 00 	movl   $0x8000a8,(%esp)
  801002:	e8 e7 fc ff ff       	call   800cee <sys_thread_create>
  801007:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801009:	83 c4 08             	add    $0x8,%esp
  80100c:	53                   	push   %ebx
  80100d:	68 a4 25 80 00       	push   $0x8025a4
  801012:	e8 5e f1 ff ff       	call   800175 <cprintf>
	return id;
	//return 0;
}
  801017:	89 f0                	mov    %esi,%eax
  801019:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80101c:	5b                   	pop    %ebx
  80101d:	5e                   	pop    %esi
  80101e:	5d                   	pop    %ebp
  80101f:	c3                   	ret    

00801020 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801023:	8b 45 08             	mov    0x8(%ebp),%eax
  801026:	05 00 00 00 30       	add    $0x30000000,%eax
  80102b:	c1 e8 0c             	shr    $0xc,%eax
}
  80102e:	5d                   	pop    %ebp
  80102f:	c3                   	ret    

00801030 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801033:	8b 45 08             	mov    0x8(%ebp),%eax
  801036:	05 00 00 00 30       	add    $0x30000000,%eax
  80103b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801040:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801045:	5d                   	pop    %ebp
  801046:	c3                   	ret    

00801047 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801047:	55                   	push   %ebp
  801048:	89 e5                	mov    %esp,%ebp
  80104a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80104d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801052:	89 c2                	mov    %eax,%edx
  801054:	c1 ea 16             	shr    $0x16,%edx
  801057:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80105e:	f6 c2 01             	test   $0x1,%dl
  801061:	74 11                	je     801074 <fd_alloc+0x2d>
  801063:	89 c2                	mov    %eax,%edx
  801065:	c1 ea 0c             	shr    $0xc,%edx
  801068:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80106f:	f6 c2 01             	test   $0x1,%dl
  801072:	75 09                	jne    80107d <fd_alloc+0x36>
			*fd_store = fd;
  801074:	89 01                	mov    %eax,(%ecx)
			return 0;
  801076:	b8 00 00 00 00       	mov    $0x0,%eax
  80107b:	eb 17                	jmp    801094 <fd_alloc+0x4d>
  80107d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801082:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801087:	75 c9                	jne    801052 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801089:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80108f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801094:	5d                   	pop    %ebp
  801095:	c3                   	ret    

00801096 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801096:	55                   	push   %ebp
  801097:	89 e5                	mov    %esp,%ebp
  801099:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80109c:	83 f8 1f             	cmp    $0x1f,%eax
  80109f:	77 36                	ja     8010d7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010a1:	c1 e0 0c             	shl    $0xc,%eax
  8010a4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010a9:	89 c2                	mov    %eax,%edx
  8010ab:	c1 ea 16             	shr    $0x16,%edx
  8010ae:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010b5:	f6 c2 01             	test   $0x1,%dl
  8010b8:	74 24                	je     8010de <fd_lookup+0x48>
  8010ba:	89 c2                	mov    %eax,%edx
  8010bc:	c1 ea 0c             	shr    $0xc,%edx
  8010bf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010c6:	f6 c2 01             	test   $0x1,%dl
  8010c9:	74 1a                	je     8010e5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010ce:	89 02                	mov    %eax,(%edx)
	return 0;
  8010d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d5:	eb 13                	jmp    8010ea <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010dc:	eb 0c                	jmp    8010ea <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010e3:	eb 05                	jmp    8010ea <fd_lookup+0x54>
  8010e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010ea:	5d                   	pop    %ebp
  8010eb:	c3                   	ret    

008010ec <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	83 ec 08             	sub    $0x8,%esp
  8010f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010f5:	ba 44 26 80 00       	mov    $0x802644,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8010fa:	eb 13                	jmp    80110f <dev_lookup+0x23>
  8010fc:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8010ff:	39 08                	cmp    %ecx,(%eax)
  801101:	75 0c                	jne    80110f <dev_lookup+0x23>
			*dev = devtab[i];
  801103:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801106:	89 01                	mov    %eax,(%ecx)
			return 0;
  801108:	b8 00 00 00 00       	mov    $0x0,%eax
  80110d:	eb 2e                	jmp    80113d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80110f:	8b 02                	mov    (%edx),%eax
  801111:	85 c0                	test   %eax,%eax
  801113:	75 e7                	jne    8010fc <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801115:	a1 04 40 80 00       	mov    0x804004,%eax
  80111a:	8b 40 54             	mov    0x54(%eax),%eax
  80111d:	83 ec 04             	sub    $0x4,%esp
  801120:	51                   	push   %ecx
  801121:	50                   	push   %eax
  801122:	68 c8 25 80 00       	push   $0x8025c8
  801127:	e8 49 f0 ff ff       	call   800175 <cprintf>
	*dev = 0;
  80112c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80112f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801135:	83 c4 10             	add    $0x10,%esp
  801138:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80113d:	c9                   	leave  
  80113e:	c3                   	ret    

0080113f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80113f:	55                   	push   %ebp
  801140:	89 e5                	mov    %esp,%ebp
  801142:	56                   	push   %esi
  801143:	53                   	push   %ebx
  801144:	83 ec 10             	sub    $0x10,%esp
  801147:	8b 75 08             	mov    0x8(%ebp),%esi
  80114a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80114d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801150:	50                   	push   %eax
  801151:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801157:	c1 e8 0c             	shr    $0xc,%eax
  80115a:	50                   	push   %eax
  80115b:	e8 36 ff ff ff       	call   801096 <fd_lookup>
  801160:	83 c4 08             	add    $0x8,%esp
  801163:	85 c0                	test   %eax,%eax
  801165:	78 05                	js     80116c <fd_close+0x2d>
	    || fd != fd2)
  801167:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80116a:	74 0c                	je     801178 <fd_close+0x39>
		return (must_exist ? r : 0);
  80116c:	84 db                	test   %bl,%bl
  80116e:	ba 00 00 00 00       	mov    $0x0,%edx
  801173:	0f 44 c2             	cmove  %edx,%eax
  801176:	eb 41                	jmp    8011b9 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801178:	83 ec 08             	sub    $0x8,%esp
  80117b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80117e:	50                   	push   %eax
  80117f:	ff 36                	pushl  (%esi)
  801181:	e8 66 ff ff ff       	call   8010ec <dev_lookup>
  801186:	89 c3                	mov    %eax,%ebx
  801188:	83 c4 10             	add    $0x10,%esp
  80118b:	85 c0                	test   %eax,%eax
  80118d:	78 1a                	js     8011a9 <fd_close+0x6a>
		if (dev->dev_close)
  80118f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801192:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801195:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80119a:	85 c0                	test   %eax,%eax
  80119c:	74 0b                	je     8011a9 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80119e:	83 ec 0c             	sub    $0xc,%esp
  8011a1:	56                   	push   %esi
  8011a2:	ff d0                	call   *%eax
  8011a4:	89 c3                	mov    %eax,%ebx
  8011a6:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011a9:	83 ec 08             	sub    $0x8,%esp
  8011ac:	56                   	push   %esi
  8011ad:	6a 00                	push   $0x0
  8011af:	e8 ce f9 ff ff       	call   800b82 <sys_page_unmap>
	return r;
  8011b4:	83 c4 10             	add    $0x10,%esp
  8011b7:	89 d8                	mov    %ebx,%eax
}
  8011b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011bc:	5b                   	pop    %ebx
  8011bd:	5e                   	pop    %esi
  8011be:	5d                   	pop    %ebp
  8011bf:	c3                   	ret    

008011c0 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
  8011c3:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c9:	50                   	push   %eax
  8011ca:	ff 75 08             	pushl  0x8(%ebp)
  8011cd:	e8 c4 fe ff ff       	call   801096 <fd_lookup>
  8011d2:	83 c4 08             	add    $0x8,%esp
  8011d5:	85 c0                	test   %eax,%eax
  8011d7:	78 10                	js     8011e9 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8011d9:	83 ec 08             	sub    $0x8,%esp
  8011dc:	6a 01                	push   $0x1
  8011de:	ff 75 f4             	pushl  -0xc(%ebp)
  8011e1:	e8 59 ff ff ff       	call   80113f <fd_close>
  8011e6:	83 c4 10             	add    $0x10,%esp
}
  8011e9:	c9                   	leave  
  8011ea:	c3                   	ret    

008011eb <close_all>:

void
close_all(void)
{
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
  8011ee:	53                   	push   %ebx
  8011ef:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011f2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011f7:	83 ec 0c             	sub    $0xc,%esp
  8011fa:	53                   	push   %ebx
  8011fb:	e8 c0 ff ff ff       	call   8011c0 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801200:	83 c3 01             	add    $0x1,%ebx
  801203:	83 c4 10             	add    $0x10,%esp
  801206:	83 fb 20             	cmp    $0x20,%ebx
  801209:	75 ec                	jne    8011f7 <close_all+0xc>
		close(i);
}
  80120b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80120e:	c9                   	leave  
  80120f:	c3                   	ret    

00801210 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	57                   	push   %edi
  801214:	56                   	push   %esi
  801215:	53                   	push   %ebx
  801216:	83 ec 2c             	sub    $0x2c,%esp
  801219:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80121c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80121f:	50                   	push   %eax
  801220:	ff 75 08             	pushl  0x8(%ebp)
  801223:	e8 6e fe ff ff       	call   801096 <fd_lookup>
  801228:	83 c4 08             	add    $0x8,%esp
  80122b:	85 c0                	test   %eax,%eax
  80122d:	0f 88 c1 00 00 00    	js     8012f4 <dup+0xe4>
		return r;
	close(newfdnum);
  801233:	83 ec 0c             	sub    $0xc,%esp
  801236:	56                   	push   %esi
  801237:	e8 84 ff ff ff       	call   8011c0 <close>

	newfd = INDEX2FD(newfdnum);
  80123c:	89 f3                	mov    %esi,%ebx
  80123e:	c1 e3 0c             	shl    $0xc,%ebx
  801241:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801247:	83 c4 04             	add    $0x4,%esp
  80124a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80124d:	e8 de fd ff ff       	call   801030 <fd2data>
  801252:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801254:	89 1c 24             	mov    %ebx,(%esp)
  801257:	e8 d4 fd ff ff       	call   801030 <fd2data>
  80125c:	83 c4 10             	add    $0x10,%esp
  80125f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801262:	89 f8                	mov    %edi,%eax
  801264:	c1 e8 16             	shr    $0x16,%eax
  801267:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80126e:	a8 01                	test   $0x1,%al
  801270:	74 37                	je     8012a9 <dup+0x99>
  801272:	89 f8                	mov    %edi,%eax
  801274:	c1 e8 0c             	shr    $0xc,%eax
  801277:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80127e:	f6 c2 01             	test   $0x1,%dl
  801281:	74 26                	je     8012a9 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801283:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80128a:	83 ec 0c             	sub    $0xc,%esp
  80128d:	25 07 0e 00 00       	and    $0xe07,%eax
  801292:	50                   	push   %eax
  801293:	ff 75 d4             	pushl  -0x2c(%ebp)
  801296:	6a 00                	push   $0x0
  801298:	57                   	push   %edi
  801299:	6a 00                	push   $0x0
  80129b:	e8 a0 f8 ff ff       	call   800b40 <sys_page_map>
  8012a0:	89 c7                	mov    %eax,%edi
  8012a2:	83 c4 20             	add    $0x20,%esp
  8012a5:	85 c0                	test   %eax,%eax
  8012a7:	78 2e                	js     8012d7 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012ac:	89 d0                	mov    %edx,%eax
  8012ae:	c1 e8 0c             	shr    $0xc,%eax
  8012b1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012b8:	83 ec 0c             	sub    $0xc,%esp
  8012bb:	25 07 0e 00 00       	and    $0xe07,%eax
  8012c0:	50                   	push   %eax
  8012c1:	53                   	push   %ebx
  8012c2:	6a 00                	push   $0x0
  8012c4:	52                   	push   %edx
  8012c5:	6a 00                	push   $0x0
  8012c7:	e8 74 f8 ff ff       	call   800b40 <sys_page_map>
  8012cc:	89 c7                	mov    %eax,%edi
  8012ce:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8012d1:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012d3:	85 ff                	test   %edi,%edi
  8012d5:	79 1d                	jns    8012f4 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012d7:	83 ec 08             	sub    $0x8,%esp
  8012da:	53                   	push   %ebx
  8012db:	6a 00                	push   $0x0
  8012dd:	e8 a0 f8 ff ff       	call   800b82 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012e2:	83 c4 08             	add    $0x8,%esp
  8012e5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012e8:	6a 00                	push   $0x0
  8012ea:	e8 93 f8 ff ff       	call   800b82 <sys_page_unmap>
	return r;
  8012ef:	83 c4 10             	add    $0x10,%esp
  8012f2:	89 f8                	mov    %edi,%eax
}
  8012f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012f7:	5b                   	pop    %ebx
  8012f8:	5e                   	pop    %esi
  8012f9:	5f                   	pop    %edi
  8012fa:	5d                   	pop    %ebp
  8012fb:	c3                   	ret    

008012fc <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012fc:	55                   	push   %ebp
  8012fd:	89 e5                	mov    %esp,%ebp
  8012ff:	53                   	push   %ebx
  801300:	83 ec 14             	sub    $0x14,%esp
  801303:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801306:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801309:	50                   	push   %eax
  80130a:	53                   	push   %ebx
  80130b:	e8 86 fd ff ff       	call   801096 <fd_lookup>
  801310:	83 c4 08             	add    $0x8,%esp
  801313:	89 c2                	mov    %eax,%edx
  801315:	85 c0                	test   %eax,%eax
  801317:	78 6d                	js     801386 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801319:	83 ec 08             	sub    $0x8,%esp
  80131c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131f:	50                   	push   %eax
  801320:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801323:	ff 30                	pushl  (%eax)
  801325:	e8 c2 fd ff ff       	call   8010ec <dev_lookup>
  80132a:	83 c4 10             	add    $0x10,%esp
  80132d:	85 c0                	test   %eax,%eax
  80132f:	78 4c                	js     80137d <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801331:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801334:	8b 42 08             	mov    0x8(%edx),%eax
  801337:	83 e0 03             	and    $0x3,%eax
  80133a:	83 f8 01             	cmp    $0x1,%eax
  80133d:	75 21                	jne    801360 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80133f:	a1 04 40 80 00       	mov    0x804004,%eax
  801344:	8b 40 54             	mov    0x54(%eax),%eax
  801347:	83 ec 04             	sub    $0x4,%esp
  80134a:	53                   	push   %ebx
  80134b:	50                   	push   %eax
  80134c:	68 09 26 80 00       	push   $0x802609
  801351:	e8 1f ee ff ff       	call   800175 <cprintf>
		return -E_INVAL;
  801356:	83 c4 10             	add    $0x10,%esp
  801359:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80135e:	eb 26                	jmp    801386 <read+0x8a>
	}
	if (!dev->dev_read)
  801360:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801363:	8b 40 08             	mov    0x8(%eax),%eax
  801366:	85 c0                	test   %eax,%eax
  801368:	74 17                	je     801381 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80136a:	83 ec 04             	sub    $0x4,%esp
  80136d:	ff 75 10             	pushl  0x10(%ebp)
  801370:	ff 75 0c             	pushl  0xc(%ebp)
  801373:	52                   	push   %edx
  801374:	ff d0                	call   *%eax
  801376:	89 c2                	mov    %eax,%edx
  801378:	83 c4 10             	add    $0x10,%esp
  80137b:	eb 09                	jmp    801386 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80137d:	89 c2                	mov    %eax,%edx
  80137f:	eb 05                	jmp    801386 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801381:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801386:	89 d0                	mov    %edx,%eax
  801388:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80138b:	c9                   	leave  
  80138c:	c3                   	ret    

0080138d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80138d:	55                   	push   %ebp
  80138e:	89 e5                	mov    %esp,%ebp
  801390:	57                   	push   %edi
  801391:	56                   	push   %esi
  801392:	53                   	push   %ebx
  801393:	83 ec 0c             	sub    $0xc,%esp
  801396:	8b 7d 08             	mov    0x8(%ebp),%edi
  801399:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80139c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013a1:	eb 21                	jmp    8013c4 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013a3:	83 ec 04             	sub    $0x4,%esp
  8013a6:	89 f0                	mov    %esi,%eax
  8013a8:	29 d8                	sub    %ebx,%eax
  8013aa:	50                   	push   %eax
  8013ab:	89 d8                	mov    %ebx,%eax
  8013ad:	03 45 0c             	add    0xc(%ebp),%eax
  8013b0:	50                   	push   %eax
  8013b1:	57                   	push   %edi
  8013b2:	e8 45 ff ff ff       	call   8012fc <read>
		if (m < 0)
  8013b7:	83 c4 10             	add    $0x10,%esp
  8013ba:	85 c0                	test   %eax,%eax
  8013bc:	78 10                	js     8013ce <readn+0x41>
			return m;
		if (m == 0)
  8013be:	85 c0                	test   %eax,%eax
  8013c0:	74 0a                	je     8013cc <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013c2:	01 c3                	add    %eax,%ebx
  8013c4:	39 f3                	cmp    %esi,%ebx
  8013c6:	72 db                	jb     8013a3 <readn+0x16>
  8013c8:	89 d8                	mov    %ebx,%eax
  8013ca:	eb 02                	jmp    8013ce <readn+0x41>
  8013cc:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d1:	5b                   	pop    %ebx
  8013d2:	5e                   	pop    %esi
  8013d3:	5f                   	pop    %edi
  8013d4:	5d                   	pop    %ebp
  8013d5:	c3                   	ret    

008013d6 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013d6:	55                   	push   %ebp
  8013d7:	89 e5                	mov    %esp,%ebp
  8013d9:	53                   	push   %ebx
  8013da:	83 ec 14             	sub    $0x14,%esp
  8013dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e3:	50                   	push   %eax
  8013e4:	53                   	push   %ebx
  8013e5:	e8 ac fc ff ff       	call   801096 <fd_lookup>
  8013ea:	83 c4 08             	add    $0x8,%esp
  8013ed:	89 c2                	mov    %eax,%edx
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	78 68                	js     80145b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f3:	83 ec 08             	sub    $0x8,%esp
  8013f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f9:	50                   	push   %eax
  8013fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013fd:	ff 30                	pushl  (%eax)
  8013ff:	e8 e8 fc ff ff       	call   8010ec <dev_lookup>
  801404:	83 c4 10             	add    $0x10,%esp
  801407:	85 c0                	test   %eax,%eax
  801409:	78 47                	js     801452 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80140b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80140e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801412:	75 21                	jne    801435 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801414:	a1 04 40 80 00       	mov    0x804004,%eax
  801419:	8b 40 54             	mov    0x54(%eax),%eax
  80141c:	83 ec 04             	sub    $0x4,%esp
  80141f:	53                   	push   %ebx
  801420:	50                   	push   %eax
  801421:	68 25 26 80 00       	push   $0x802625
  801426:	e8 4a ed ff ff       	call   800175 <cprintf>
		return -E_INVAL;
  80142b:	83 c4 10             	add    $0x10,%esp
  80142e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801433:	eb 26                	jmp    80145b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801435:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801438:	8b 52 0c             	mov    0xc(%edx),%edx
  80143b:	85 d2                	test   %edx,%edx
  80143d:	74 17                	je     801456 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80143f:	83 ec 04             	sub    $0x4,%esp
  801442:	ff 75 10             	pushl  0x10(%ebp)
  801445:	ff 75 0c             	pushl  0xc(%ebp)
  801448:	50                   	push   %eax
  801449:	ff d2                	call   *%edx
  80144b:	89 c2                	mov    %eax,%edx
  80144d:	83 c4 10             	add    $0x10,%esp
  801450:	eb 09                	jmp    80145b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801452:	89 c2                	mov    %eax,%edx
  801454:	eb 05                	jmp    80145b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801456:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80145b:	89 d0                	mov    %edx,%eax
  80145d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801460:	c9                   	leave  
  801461:	c3                   	ret    

00801462 <seek>:

int
seek(int fdnum, off_t offset)
{
  801462:	55                   	push   %ebp
  801463:	89 e5                	mov    %esp,%ebp
  801465:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801468:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80146b:	50                   	push   %eax
  80146c:	ff 75 08             	pushl  0x8(%ebp)
  80146f:	e8 22 fc ff ff       	call   801096 <fd_lookup>
  801474:	83 c4 08             	add    $0x8,%esp
  801477:	85 c0                	test   %eax,%eax
  801479:	78 0e                	js     801489 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80147b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80147e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801481:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801484:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801489:	c9                   	leave  
  80148a:	c3                   	ret    

0080148b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80148b:	55                   	push   %ebp
  80148c:	89 e5                	mov    %esp,%ebp
  80148e:	53                   	push   %ebx
  80148f:	83 ec 14             	sub    $0x14,%esp
  801492:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801495:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801498:	50                   	push   %eax
  801499:	53                   	push   %ebx
  80149a:	e8 f7 fb ff ff       	call   801096 <fd_lookup>
  80149f:	83 c4 08             	add    $0x8,%esp
  8014a2:	89 c2                	mov    %eax,%edx
  8014a4:	85 c0                	test   %eax,%eax
  8014a6:	78 65                	js     80150d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a8:	83 ec 08             	sub    $0x8,%esp
  8014ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ae:	50                   	push   %eax
  8014af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b2:	ff 30                	pushl  (%eax)
  8014b4:	e8 33 fc ff ff       	call   8010ec <dev_lookup>
  8014b9:	83 c4 10             	add    $0x10,%esp
  8014bc:	85 c0                	test   %eax,%eax
  8014be:	78 44                	js     801504 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014c7:	75 21                	jne    8014ea <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014c9:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014ce:	8b 40 54             	mov    0x54(%eax),%eax
  8014d1:	83 ec 04             	sub    $0x4,%esp
  8014d4:	53                   	push   %ebx
  8014d5:	50                   	push   %eax
  8014d6:	68 e8 25 80 00       	push   $0x8025e8
  8014db:	e8 95 ec ff ff       	call   800175 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014e0:	83 c4 10             	add    $0x10,%esp
  8014e3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014e8:	eb 23                	jmp    80150d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8014ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014ed:	8b 52 18             	mov    0x18(%edx),%edx
  8014f0:	85 d2                	test   %edx,%edx
  8014f2:	74 14                	je     801508 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014f4:	83 ec 08             	sub    $0x8,%esp
  8014f7:	ff 75 0c             	pushl  0xc(%ebp)
  8014fa:	50                   	push   %eax
  8014fb:	ff d2                	call   *%edx
  8014fd:	89 c2                	mov    %eax,%edx
  8014ff:	83 c4 10             	add    $0x10,%esp
  801502:	eb 09                	jmp    80150d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801504:	89 c2                	mov    %eax,%edx
  801506:	eb 05                	jmp    80150d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801508:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80150d:	89 d0                	mov    %edx,%eax
  80150f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801512:	c9                   	leave  
  801513:	c3                   	ret    

00801514 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801514:	55                   	push   %ebp
  801515:	89 e5                	mov    %esp,%ebp
  801517:	53                   	push   %ebx
  801518:	83 ec 14             	sub    $0x14,%esp
  80151b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80151e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801521:	50                   	push   %eax
  801522:	ff 75 08             	pushl  0x8(%ebp)
  801525:	e8 6c fb ff ff       	call   801096 <fd_lookup>
  80152a:	83 c4 08             	add    $0x8,%esp
  80152d:	89 c2                	mov    %eax,%edx
  80152f:	85 c0                	test   %eax,%eax
  801531:	78 58                	js     80158b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801533:	83 ec 08             	sub    $0x8,%esp
  801536:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801539:	50                   	push   %eax
  80153a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153d:	ff 30                	pushl  (%eax)
  80153f:	e8 a8 fb ff ff       	call   8010ec <dev_lookup>
  801544:	83 c4 10             	add    $0x10,%esp
  801547:	85 c0                	test   %eax,%eax
  801549:	78 37                	js     801582 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80154b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80154e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801552:	74 32                	je     801586 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801554:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801557:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80155e:	00 00 00 
	stat->st_isdir = 0;
  801561:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801568:	00 00 00 
	stat->st_dev = dev;
  80156b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801571:	83 ec 08             	sub    $0x8,%esp
  801574:	53                   	push   %ebx
  801575:	ff 75 f0             	pushl  -0x10(%ebp)
  801578:	ff 50 14             	call   *0x14(%eax)
  80157b:	89 c2                	mov    %eax,%edx
  80157d:	83 c4 10             	add    $0x10,%esp
  801580:	eb 09                	jmp    80158b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801582:	89 c2                	mov    %eax,%edx
  801584:	eb 05                	jmp    80158b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801586:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80158b:	89 d0                	mov    %edx,%eax
  80158d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801590:	c9                   	leave  
  801591:	c3                   	ret    

00801592 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801592:	55                   	push   %ebp
  801593:	89 e5                	mov    %esp,%ebp
  801595:	56                   	push   %esi
  801596:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801597:	83 ec 08             	sub    $0x8,%esp
  80159a:	6a 00                	push   $0x0
  80159c:	ff 75 08             	pushl  0x8(%ebp)
  80159f:	e8 e3 01 00 00       	call   801787 <open>
  8015a4:	89 c3                	mov    %eax,%ebx
  8015a6:	83 c4 10             	add    $0x10,%esp
  8015a9:	85 c0                	test   %eax,%eax
  8015ab:	78 1b                	js     8015c8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015ad:	83 ec 08             	sub    $0x8,%esp
  8015b0:	ff 75 0c             	pushl  0xc(%ebp)
  8015b3:	50                   	push   %eax
  8015b4:	e8 5b ff ff ff       	call   801514 <fstat>
  8015b9:	89 c6                	mov    %eax,%esi
	close(fd);
  8015bb:	89 1c 24             	mov    %ebx,(%esp)
  8015be:	e8 fd fb ff ff       	call   8011c0 <close>
	return r;
  8015c3:	83 c4 10             	add    $0x10,%esp
  8015c6:	89 f0                	mov    %esi,%eax
}
  8015c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015cb:	5b                   	pop    %ebx
  8015cc:	5e                   	pop    %esi
  8015cd:	5d                   	pop    %ebp
  8015ce:	c3                   	ret    

008015cf <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015cf:	55                   	push   %ebp
  8015d0:	89 e5                	mov    %esp,%ebp
  8015d2:	56                   	push   %esi
  8015d3:	53                   	push   %ebx
  8015d4:	89 c6                	mov    %eax,%esi
  8015d6:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015d8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015df:	75 12                	jne    8015f3 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015e1:	83 ec 0c             	sub    $0xc,%esp
  8015e4:	6a 01                	push   $0x1
  8015e6:	e8 ce 08 00 00       	call   801eb9 <ipc_find_env>
  8015eb:	a3 00 40 80 00       	mov    %eax,0x804000
  8015f0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015f3:	6a 07                	push   $0x7
  8015f5:	68 00 50 80 00       	push   $0x805000
  8015fa:	56                   	push   %esi
  8015fb:	ff 35 00 40 80 00    	pushl  0x804000
  801601:	e8 51 08 00 00       	call   801e57 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801606:	83 c4 0c             	add    $0xc,%esp
  801609:	6a 00                	push   $0x0
  80160b:	53                   	push   %ebx
  80160c:	6a 00                	push   $0x0
  80160e:	e8 cc 07 00 00       	call   801ddf <ipc_recv>
}
  801613:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801616:	5b                   	pop    %ebx
  801617:	5e                   	pop    %esi
  801618:	5d                   	pop    %ebp
  801619:	c3                   	ret    

0080161a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80161a:	55                   	push   %ebp
  80161b:	89 e5                	mov    %esp,%ebp
  80161d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801620:	8b 45 08             	mov    0x8(%ebp),%eax
  801623:	8b 40 0c             	mov    0xc(%eax),%eax
  801626:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80162b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80162e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801633:	ba 00 00 00 00       	mov    $0x0,%edx
  801638:	b8 02 00 00 00       	mov    $0x2,%eax
  80163d:	e8 8d ff ff ff       	call   8015cf <fsipc>
}
  801642:	c9                   	leave  
  801643:	c3                   	ret    

00801644 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801644:	55                   	push   %ebp
  801645:	89 e5                	mov    %esp,%ebp
  801647:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80164a:	8b 45 08             	mov    0x8(%ebp),%eax
  80164d:	8b 40 0c             	mov    0xc(%eax),%eax
  801650:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801655:	ba 00 00 00 00       	mov    $0x0,%edx
  80165a:	b8 06 00 00 00       	mov    $0x6,%eax
  80165f:	e8 6b ff ff ff       	call   8015cf <fsipc>
}
  801664:	c9                   	leave  
  801665:	c3                   	ret    

00801666 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801666:	55                   	push   %ebp
  801667:	89 e5                	mov    %esp,%ebp
  801669:	53                   	push   %ebx
  80166a:	83 ec 04             	sub    $0x4,%esp
  80166d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801670:	8b 45 08             	mov    0x8(%ebp),%eax
  801673:	8b 40 0c             	mov    0xc(%eax),%eax
  801676:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80167b:	ba 00 00 00 00       	mov    $0x0,%edx
  801680:	b8 05 00 00 00       	mov    $0x5,%eax
  801685:	e8 45 ff ff ff       	call   8015cf <fsipc>
  80168a:	85 c0                	test   %eax,%eax
  80168c:	78 2c                	js     8016ba <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80168e:	83 ec 08             	sub    $0x8,%esp
  801691:	68 00 50 80 00       	push   $0x805000
  801696:	53                   	push   %ebx
  801697:	e8 5e f0 ff ff       	call   8006fa <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80169c:	a1 80 50 80 00       	mov    0x805080,%eax
  8016a1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016a7:	a1 84 50 80 00       	mov    0x805084,%eax
  8016ac:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016b2:	83 c4 10             	add    $0x10,%esp
  8016b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016bd:	c9                   	leave  
  8016be:	c3                   	ret    

008016bf <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	83 ec 0c             	sub    $0xc,%esp
  8016c5:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8016cb:	8b 52 0c             	mov    0xc(%edx),%edx
  8016ce:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8016d4:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8016d9:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8016de:	0f 47 c2             	cmova  %edx,%eax
  8016e1:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8016e6:	50                   	push   %eax
  8016e7:	ff 75 0c             	pushl  0xc(%ebp)
  8016ea:	68 08 50 80 00       	push   $0x805008
  8016ef:	e8 98 f1 ff ff       	call   80088c <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8016f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f9:	b8 04 00 00 00       	mov    $0x4,%eax
  8016fe:	e8 cc fe ff ff       	call   8015cf <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801703:	c9                   	leave  
  801704:	c3                   	ret    

00801705 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801705:	55                   	push   %ebp
  801706:	89 e5                	mov    %esp,%ebp
  801708:	56                   	push   %esi
  801709:	53                   	push   %ebx
  80170a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80170d:	8b 45 08             	mov    0x8(%ebp),%eax
  801710:	8b 40 0c             	mov    0xc(%eax),%eax
  801713:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801718:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80171e:	ba 00 00 00 00       	mov    $0x0,%edx
  801723:	b8 03 00 00 00       	mov    $0x3,%eax
  801728:	e8 a2 fe ff ff       	call   8015cf <fsipc>
  80172d:	89 c3                	mov    %eax,%ebx
  80172f:	85 c0                	test   %eax,%eax
  801731:	78 4b                	js     80177e <devfile_read+0x79>
		return r;
	assert(r <= n);
  801733:	39 c6                	cmp    %eax,%esi
  801735:	73 16                	jae    80174d <devfile_read+0x48>
  801737:	68 54 26 80 00       	push   $0x802654
  80173c:	68 5b 26 80 00       	push   $0x80265b
  801741:	6a 7c                	push   $0x7c
  801743:	68 70 26 80 00       	push   $0x802670
  801748:	e8 bd 05 00 00       	call   801d0a <_panic>
	assert(r <= PGSIZE);
  80174d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801752:	7e 16                	jle    80176a <devfile_read+0x65>
  801754:	68 7b 26 80 00       	push   $0x80267b
  801759:	68 5b 26 80 00       	push   $0x80265b
  80175e:	6a 7d                	push   $0x7d
  801760:	68 70 26 80 00       	push   $0x802670
  801765:	e8 a0 05 00 00       	call   801d0a <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80176a:	83 ec 04             	sub    $0x4,%esp
  80176d:	50                   	push   %eax
  80176e:	68 00 50 80 00       	push   $0x805000
  801773:	ff 75 0c             	pushl  0xc(%ebp)
  801776:	e8 11 f1 ff ff       	call   80088c <memmove>
	return r;
  80177b:	83 c4 10             	add    $0x10,%esp
}
  80177e:	89 d8                	mov    %ebx,%eax
  801780:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801783:	5b                   	pop    %ebx
  801784:	5e                   	pop    %esi
  801785:	5d                   	pop    %ebp
  801786:	c3                   	ret    

00801787 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	53                   	push   %ebx
  80178b:	83 ec 20             	sub    $0x20,%esp
  80178e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801791:	53                   	push   %ebx
  801792:	e8 2a ef ff ff       	call   8006c1 <strlen>
  801797:	83 c4 10             	add    $0x10,%esp
  80179a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80179f:	7f 67                	jg     801808 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017a1:	83 ec 0c             	sub    $0xc,%esp
  8017a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a7:	50                   	push   %eax
  8017a8:	e8 9a f8 ff ff       	call   801047 <fd_alloc>
  8017ad:	83 c4 10             	add    $0x10,%esp
		return r;
  8017b0:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017b2:	85 c0                	test   %eax,%eax
  8017b4:	78 57                	js     80180d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017b6:	83 ec 08             	sub    $0x8,%esp
  8017b9:	53                   	push   %ebx
  8017ba:	68 00 50 80 00       	push   $0x805000
  8017bf:	e8 36 ef ff ff       	call   8006fa <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017c7:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017cf:	b8 01 00 00 00       	mov    $0x1,%eax
  8017d4:	e8 f6 fd ff ff       	call   8015cf <fsipc>
  8017d9:	89 c3                	mov    %eax,%ebx
  8017db:	83 c4 10             	add    $0x10,%esp
  8017de:	85 c0                	test   %eax,%eax
  8017e0:	79 14                	jns    8017f6 <open+0x6f>
		fd_close(fd, 0);
  8017e2:	83 ec 08             	sub    $0x8,%esp
  8017e5:	6a 00                	push   $0x0
  8017e7:	ff 75 f4             	pushl  -0xc(%ebp)
  8017ea:	e8 50 f9 ff ff       	call   80113f <fd_close>
		return r;
  8017ef:	83 c4 10             	add    $0x10,%esp
  8017f2:	89 da                	mov    %ebx,%edx
  8017f4:	eb 17                	jmp    80180d <open+0x86>
	}

	return fd2num(fd);
  8017f6:	83 ec 0c             	sub    $0xc,%esp
  8017f9:	ff 75 f4             	pushl  -0xc(%ebp)
  8017fc:	e8 1f f8 ff ff       	call   801020 <fd2num>
  801801:	89 c2                	mov    %eax,%edx
  801803:	83 c4 10             	add    $0x10,%esp
  801806:	eb 05                	jmp    80180d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801808:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80180d:	89 d0                	mov    %edx,%eax
  80180f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801812:	c9                   	leave  
  801813:	c3                   	ret    

00801814 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801814:	55                   	push   %ebp
  801815:	89 e5                	mov    %esp,%ebp
  801817:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80181a:	ba 00 00 00 00       	mov    $0x0,%edx
  80181f:	b8 08 00 00 00       	mov    $0x8,%eax
  801824:	e8 a6 fd ff ff       	call   8015cf <fsipc>
}
  801829:	c9                   	leave  
  80182a:	c3                   	ret    

0080182b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80182b:	55                   	push   %ebp
  80182c:	89 e5                	mov    %esp,%ebp
  80182e:	56                   	push   %esi
  80182f:	53                   	push   %ebx
  801830:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801833:	83 ec 0c             	sub    $0xc,%esp
  801836:	ff 75 08             	pushl  0x8(%ebp)
  801839:	e8 f2 f7 ff ff       	call   801030 <fd2data>
  80183e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801840:	83 c4 08             	add    $0x8,%esp
  801843:	68 87 26 80 00       	push   $0x802687
  801848:	53                   	push   %ebx
  801849:	e8 ac ee ff ff       	call   8006fa <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80184e:	8b 46 04             	mov    0x4(%esi),%eax
  801851:	2b 06                	sub    (%esi),%eax
  801853:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801859:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801860:	00 00 00 
	stat->st_dev = &devpipe;
  801863:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80186a:	30 80 00 
	return 0;
}
  80186d:	b8 00 00 00 00       	mov    $0x0,%eax
  801872:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801875:	5b                   	pop    %ebx
  801876:	5e                   	pop    %esi
  801877:	5d                   	pop    %ebp
  801878:	c3                   	ret    

00801879 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801879:	55                   	push   %ebp
  80187a:	89 e5                	mov    %esp,%ebp
  80187c:	53                   	push   %ebx
  80187d:	83 ec 0c             	sub    $0xc,%esp
  801880:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801883:	53                   	push   %ebx
  801884:	6a 00                	push   $0x0
  801886:	e8 f7 f2 ff ff       	call   800b82 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80188b:	89 1c 24             	mov    %ebx,(%esp)
  80188e:	e8 9d f7 ff ff       	call   801030 <fd2data>
  801893:	83 c4 08             	add    $0x8,%esp
  801896:	50                   	push   %eax
  801897:	6a 00                	push   $0x0
  801899:	e8 e4 f2 ff ff       	call   800b82 <sys_page_unmap>
}
  80189e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a1:	c9                   	leave  
  8018a2:	c3                   	ret    

008018a3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018a3:	55                   	push   %ebp
  8018a4:	89 e5                	mov    %esp,%ebp
  8018a6:	57                   	push   %edi
  8018a7:	56                   	push   %esi
  8018a8:	53                   	push   %ebx
  8018a9:	83 ec 1c             	sub    $0x1c,%esp
  8018ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018af:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018b1:	a1 04 40 80 00       	mov    0x804004,%eax
  8018b6:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8018b9:	83 ec 0c             	sub    $0xc,%esp
  8018bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8018bf:	e8 35 06 00 00       	call   801ef9 <pageref>
  8018c4:	89 c3                	mov    %eax,%ebx
  8018c6:	89 3c 24             	mov    %edi,(%esp)
  8018c9:	e8 2b 06 00 00       	call   801ef9 <pageref>
  8018ce:	83 c4 10             	add    $0x10,%esp
  8018d1:	39 c3                	cmp    %eax,%ebx
  8018d3:	0f 94 c1             	sete   %cl
  8018d6:	0f b6 c9             	movzbl %cl,%ecx
  8018d9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8018dc:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8018e2:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  8018e5:	39 ce                	cmp    %ecx,%esi
  8018e7:	74 1b                	je     801904 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8018e9:	39 c3                	cmp    %eax,%ebx
  8018eb:	75 c4                	jne    8018b1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018ed:	8b 42 64             	mov    0x64(%edx),%eax
  8018f0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018f3:	50                   	push   %eax
  8018f4:	56                   	push   %esi
  8018f5:	68 8e 26 80 00       	push   $0x80268e
  8018fa:	e8 76 e8 ff ff       	call   800175 <cprintf>
  8018ff:	83 c4 10             	add    $0x10,%esp
  801902:	eb ad                	jmp    8018b1 <_pipeisclosed+0xe>
	}
}
  801904:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801907:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80190a:	5b                   	pop    %ebx
  80190b:	5e                   	pop    %esi
  80190c:	5f                   	pop    %edi
  80190d:	5d                   	pop    %ebp
  80190e:	c3                   	ret    

0080190f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80190f:	55                   	push   %ebp
  801910:	89 e5                	mov    %esp,%ebp
  801912:	57                   	push   %edi
  801913:	56                   	push   %esi
  801914:	53                   	push   %ebx
  801915:	83 ec 28             	sub    $0x28,%esp
  801918:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80191b:	56                   	push   %esi
  80191c:	e8 0f f7 ff ff       	call   801030 <fd2data>
  801921:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801923:	83 c4 10             	add    $0x10,%esp
  801926:	bf 00 00 00 00       	mov    $0x0,%edi
  80192b:	eb 4b                	jmp    801978 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80192d:	89 da                	mov    %ebx,%edx
  80192f:	89 f0                	mov    %esi,%eax
  801931:	e8 6d ff ff ff       	call   8018a3 <_pipeisclosed>
  801936:	85 c0                	test   %eax,%eax
  801938:	75 48                	jne    801982 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80193a:	e8 9f f1 ff ff       	call   800ade <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80193f:	8b 43 04             	mov    0x4(%ebx),%eax
  801942:	8b 0b                	mov    (%ebx),%ecx
  801944:	8d 51 20             	lea    0x20(%ecx),%edx
  801947:	39 d0                	cmp    %edx,%eax
  801949:	73 e2                	jae    80192d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80194b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80194e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801952:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801955:	89 c2                	mov    %eax,%edx
  801957:	c1 fa 1f             	sar    $0x1f,%edx
  80195a:	89 d1                	mov    %edx,%ecx
  80195c:	c1 e9 1b             	shr    $0x1b,%ecx
  80195f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801962:	83 e2 1f             	and    $0x1f,%edx
  801965:	29 ca                	sub    %ecx,%edx
  801967:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80196b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80196f:	83 c0 01             	add    $0x1,%eax
  801972:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801975:	83 c7 01             	add    $0x1,%edi
  801978:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80197b:	75 c2                	jne    80193f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80197d:	8b 45 10             	mov    0x10(%ebp),%eax
  801980:	eb 05                	jmp    801987 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801982:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801987:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80198a:	5b                   	pop    %ebx
  80198b:	5e                   	pop    %esi
  80198c:	5f                   	pop    %edi
  80198d:	5d                   	pop    %ebp
  80198e:	c3                   	ret    

0080198f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80198f:	55                   	push   %ebp
  801990:	89 e5                	mov    %esp,%ebp
  801992:	57                   	push   %edi
  801993:	56                   	push   %esi
  801994:	53                   	push   %ebx
  801995:	83 ec 18             	sub    $0x18,%esp
  801998:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80199b:	57                   	push   %edi
  80199c:	e8 8f f6 ff ff       	call   801030 <fd2data>
  8019a1:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019a3:	83 c4 10             	add    $0x10,%esp
  8019a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019ab:	eb 3d                	jmp    8019ea <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019ad:	85 db                	test   %ebx,%ebx
  8019af:	74 04                	je     8019b5 <devpipe_read+0x26>
				return i;
  8019b1:	89 d8                	mov    %ebx,%eax
  8019b3:	eb 44                	jmp    8019f9 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019b5:	89 f2                	mov    %esi,%edx
  8019b7:	89 f8                	mov    %edi,%eax
  8019b9:	e8 e5 fe ff ff       	call   8018a3 <_pipeisclosed>
  8019be:	85 c0                	test   %eax,%eax
  8019c0:	75 32                	jne    8019f4 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019c2:	e8 17 f1 ff ff       	call   800ade <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019c7:	8b 06                	mov    (%esi),%eax
  8019c9:	3b 46 04             	cmp    0x4(%esi),%eax
  8019cc:	74 df                	je     8019ad <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019ce:	99                   	cltd   
  8019cf:	c1 ea 1b             	shr    $0x1b,%edx
  8019d2:	01 d0                	add    %edx,%eax
  8019d4:	83 e0 1f             	and    $0x1f,%eax
  8019d7:	29 d0                	sub    %edx,%eax
  8019d9:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8019de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019e1:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8019e4:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019e7:	83 c3 01             	add    $0x1,%ebx
  8019ea:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019ed:	75 d8                	jne    8019c7 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019ef:	8b 45 10             	mov    0x10(%ebp),%eax
  8019f2:	eb 05                	jmp    8019f9 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019f4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8019f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019fc:	5b                   	pop    %ebx
  8019fd:	5e                   	pop    %esi
  8019fe:	5f                   	pop    %edi
  8019ff:	5d                   	pop    %ebp
  801a00:	c3                   	ret    

00801a01 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a01:	55                   	push   %ebp
  801a02:	89 e5                	mov    %esp,%ebp
  801a04:	56                   	push   %esi
  801a05:	53                   	push   %ebx
  801a06:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a09:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a0c:	50                   	push   %eax
  801a0d:	e8 35 f6 ff ff       	call   801047 <fd_alloc>
  801a12:	83 c4 10             	add    $0x10,%esp
  801a15:	89 c2                	mov    %eax,%edx
  801a17:	85 c0                	test   %eax,%eax
  801a19:	0f 88 2c 01 00 00    	js     801b4b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a1f:	83 ec 04             	sub    $0x4,%esp
  801a22:	68 07 04 00 00       	push   $0x407
  801a27:	ff 75 f4             	pushl  -0xc(%ebp)
  801a2a:	6a 00                	push   $0x0
  801a2c:	e8 cc f0 ff ff       	call   800afd <sys_page_alloc>
  801a31:	83 c4 10             	add    $0x10,%esp
  801a34:	89 c2                	mov    %eax,%edx
  801a36:	85 c0                	test   %eax,%eax
  801a38:	0f 88 0d 01 00 00    	js     801b4b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a3e:	83 ec 0c             	sub    $0xc,%esp
  801a41:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a44:	50                   	push   %eax
  801a45:	e8 fd f5 ff ff       	call   801047 <fd_alloc>
  801a4a:	89 c3                	mov    %eax,%ebx
  801a4c:	83 c4 10             	add    $0x10,%esp
  801a4f:	85 c0                	test   %eax,%eax
  801a51:	0f 88 e2 00 00 00    	js     801b39 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a57:	83 ec 04             	sub    $0x4,%esp
  801a5a:	68 07 04 00 00       	push   $0x407
  801a5f:	ff 75 f0             	pushl  -0x10(%ebp)
  801a62:	6a 00                	push   $0x0
  801a64:	e8 94 f0 ff ff       	call   800afd <sys_page_alloc>
  801a69:	89 c3                	mov    %eax,%ebx
  801a6b:	83 c4 10             	add    $0x10,%esp
  801a6e:	85 c0                	test   %eax,%eax
  801a70:	0f 88 c3 00 00 00    	js     801b39 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a76:	83 ec 0c             	sub    $0xc,%esp
  801a79:	ff 75 f4             	pushl  -0xc(%ebp)
  801a7c:	e8 af f5 ff ff       	call   801030 <fd2data>
  801a81:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a83:	83 c4 0c             	add    $0xc,%esp
  801a86:	68 07 04 00 00       	push   $0x407
  801a8b:	50                   	push   %eax
  801a8c:	6a 00                	push   $0x0
  801a8e:	e8 6a f0 ff ff       	call   800afd <sys_page_alloc>
  801a93:	89 c3                	mov    %eax,%ebx
  801a95:	83 c4 10             	add    $0x10,%esp
  801a98:	85 c0                	test   %eax,%eax
  801a9a:	0f 88 89 00 00 00    	js     801b29 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aa0:	83 ec 0c             	sub    $0xc,%esp
  801aa3:	ff 75 f0             	pushl  -0x10(%ebp)
  801aa6:	e8 85 f5 ff ff       	call   801030 <fd2data>
  801aab:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ab2:	50                   	push   %eax
  801ab3:	6a 00                	push   $0x0
  801ab5:	56                   	push   %esi
  801ab6:	6a 00                	push   $0x0
  801ab8:	e8 83 f0 ff ff       	call   800b40 <sys_page_map>
  801abd:	89 c3                	mov    %eax,%ebx
  801abf:	83 c4 20             	add    $0x20,%esp
  801ac2:	85 c0                	test   %eax,%eax
  801ac4:	78 55                	js     801b1b <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ac6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801acf:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801adb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ae1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ae4:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ae6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ae9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801af0:	83 ec 0c             	sub    $0xc,%esp
  801af3:	ff 75 f4             	pushl  -0xc(%ebp)
  801af6:	e8 25 f5 ff ff       	call   801020 <fd2num>
  801afb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801afe:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b00:	83 c4 04             	add    $0x4,%esp
  801b03:	ff 75 f0             	pushl  -0x10(%ebp)
  801b06:	e8 15 f5 ff ff       	call   801020 <fd2num>
  801b0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b0e:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801b11:	83 c4 10             	add    $0x10,%esp
  801b14:	ba 00 00 00 00       	mov    $0x0,%edx
  801b19:	eb 30                	jmp    801b4b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b1b:	83 ec 08             	sub    $0x8,%esp
  801b1e:	56                   	push   %esi
  801b1f:	6a 00                	push   $0x0
  801b21:	e8 5c f0 ff ff       	call   800b82 <sys_page_unmap>
  801b26:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b29:	83 ec 08             	sub    $0x8,%esp
  801b2c:	ff 75 f0             	pushl  -0x10(%ebp)
  801b2f:	6a 00                	push   $0x0
  801b31:	e8 4c f0 ff ff       	call   800b82 <sys_page_unmap>
  801b36:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b39:	83 ec 08             	sub    $0x8,%esp
  801b3c:	ff 75 f4             	pushl  -0xc(%ebp)
  801b3f:	6a 00                	push   $0x0
  801b41:	e8 3c f0 ff ff       	call   800b82 <sys_page_unmap>
  801b46:	83 c4 10             	add    $0x10,%esp
  801b49:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b4b:	89 d0                	mov    %edx,%eax
  801b4d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b50:	5b                   	pop    %ebx
  801b51:	5e                   	pop    %esi
  801b52:	5d                   	pop    %ebp
  801b53:	c3                   	ret    

00801b54 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b54:	55                   	push   %ebp
  801b55:	89 e5                	mov    %esp,%ebp
  801b57:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b5d:	50                   	push   %eax
  801b5e:	ff 75 08             	pushl  0x8(%ebp)
  801b61:	e8 30 f5 ff ff       	call   801096 <fd_lookup>
  801b66:	83 c4 10             	add    $0x10,%esp
  801b69:	85 c0                	test   %eax,%eax
  801b6b:	78 18                	js     801b85 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b6d:	83 ec 0c             	sub    $0xc,%esp
  801b70:	ff 75 f4             	pushl  -0xc(%ebp)
  801b73:	e8 b8 f4 ff ff       	call   801030 <fd2data>
	return _pipeisclosed(fd, p);
  801b78:	89 c2                	mov    %eax,%edx
  801b7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b7d:	e8 21 fd ff ff       	call   8018a3 <_pipeisclosed>
  801b82:	83 c4 10             	add    $0x10,%esp
}
  801b85:	c9                   	leave  
  801b86:	c3                   	ret    

00801b87 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b87:	55                   	push   %ebp
  801b88:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b8a:	b8 00 00 00 00       	mov    $0x0,%eax
  801b8f:	5d                   	pop    %ebp
  801b90:	c3                   	ret    

00801b91 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b91:	55                   	push   %ebp
  801b92:	89 e5                	mov    %esp,%ebp
  801b94:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b97:	68 a6 26 80 00       	push   $0x8026a6
  801b9c:	ff 75 0c             	pushl  0xc(%ebp)
  801b9f:	e8 56 eb ff ff       	call   8006fa <strcpy>
	return 0;
}
  801ba4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba9:	c9                   	leave  
  801baa:	c3                   	ret    

00801bab <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bab:	55                   	push   %ebp
  801bac:	89 e5                	mov    %esp,%ebp
  801bae:	57                   	push   %edi
  801baf:	56                   	push   %esi
  801bb0:	53                   	push   %ebx
  801bb1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bb7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bbc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bc2:	eb 2d                	jmp    801bf1 <devcons_write+0x46>
		m = n - tot;
  801bc4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801bc7:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801bc9:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801bcc:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801bd1:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bd4:	83 ec 04             	sub    $0x4,%esp
  801bd7:	53                   	push   %ebx
  801bd8:	03 45 0c             	add    0xc(%ebp),%eax
  801bdb:	50                   	push   %eax
  801bdc:	57                   	push   %edi
  801bdd:	e8 aa ec ff ff       	call   80088c <memmove>
		sys_cputs(buf, m);
  801be2:	83 c4 08             	add    $0x8,%esp
  801be5:	53                   	push   %ebx
  801be6:	57                   	push   %edi
  801be7:	e8 55 ee ff ff       	call   800a41 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bec:	01 de                	add    %ebx,%esi
  801bee:	83 c4 10             	add    $0x10,%esp
  801bf1:	89 f0                	mov    %esi,%eax
  801bf3:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bf6:	72 cc                	jb     801bc4 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801bf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bfb:	5b                   	pop    %ebx
  801bfc:	5e                   	pop    %esi
  801bfd:	5f                   	pop    %edi
  801bfe:	5d                   	pop    %ebp
  801bff:	c3                   	ret    

00801c00 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c00:	55                   	push   %ebp
  801c01:	89 e5                	mov    %esp,%ebp
  801c03:	83 ec 08             	sub    $0x8,%esp
  801c06:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c0b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c0f:	74 2a                	je     801c3b <devcons_read+0x3b>
  801c11:	eb 05                	jmp    801c18 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c13:	e8 c6 ee ff ff       	call   800ade <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c18:	e8 42 ee ff ff       	call   800a5f <sys_cgetc>
  801c1d:	85 c0                	test   %eax,%eax
  801c1f:	74 f2                	je     801c13 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c21:	85 c0                	test   %eax,%eax
  801c23:	78 16                	js     801c3b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c25:	83 f8 04             	cmp    $0x4,%eax
  801c28:	74 0c                	je     801c36 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c2a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c2d:	88 02                	mov    %al,(%edx)
	return 1;
  801c2f:	b8 01 00 00 00       	mov    $0x1,%eax
  801c34:	eb 05                	jmp    801c3b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c36:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c3b:	c9                   	leave  
  801c3c:	c3                   	ret    

00801c3d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c3d:	55                   	push   %ebp
  801c3e:	89 e5                	mov    %esp,%ebp
  801c40:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c43:	8b 45 08             	mov    0x8(%ebp),%eax
  801c46:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c49:	6a 01                	push   $0x1
  801c4b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c4e:	50                   	push   %eax
  801c4f:	e8 ed ed ff ff       	call   800a41 <sys_cputs>
}
  801c54:	83 c4 10             	add    $0x10,%esp
  801c57:	c9                   	leave  
  801c58:	c3                   	ret    

00801c59 <getchar>:

int
getchar(void)
{
  801c59:	55                   	push   %ebp
  801c5a:	89 e5                	mov    %esp,%ebp
  801c5c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c5f:	6a 01                	push   $0x1
  801c61:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c64:	50                   	push   %eax
  801c65:	6a 00                	push   $0x0
  801c67:	e8 90 f6 ff ff       	call   8012fc <read>
	if (r < 0)
  801c6c:	83 c4 10             	add    $0x10,%esp
  801c6f:	85 c0                	test   %eax,%eax
  801c71:	78 0f                	js     801c82 <getchar+0x29>
		return r;
	if (r < 1)
  801c73:	85 c0                	test   %eax,%eax
  801c75:	7e 06                	jle    801c7d <getchar+0x24>
		return -E_EOF;
	return c;
  801c77:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c7b:	eb 05                	jmp    801c82 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c7d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c82:	c9                   	leave  
  801c83:	c3                   	ret    

00801c84 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c84:	55                   	push   %ebp
  801c85:	89 e5                	mov    %esp,%ebp
  801c87:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c8d:	50                   	push   %eax
  801c8e:	ff 75 08             	pushl  0x8(%ebp)
  801c91:	e8 00 f4 ff ff       	call   801096 <fd_lookup>
  801c96:	83 c4 10             	add    $0x10,%esp
  801c99:	85 c0                	test   %eax,%eax
  801c9b:	78 11                	js     801cae <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ca6:	39 10                	cmp    %edx,(%eax)
  801ca8:	0f 94 c0             	sete   %al
  801cab:	0f b6 c0             	movzbl %al,%eax
}
  801cae:	c9                   	leave  
  801caf:	c3                   	ret    

00801cb0 <opencons>:

int
opencons(void)
{
  801cb0:	55                   	push   %ebp
  801cb1:	89 e5                	mov    %esp,%ebp
  801cb3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cb6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cb9:	50                   	push   %eax
  801cba:	e8 88 f3 ff ff       	call   801047 <fd_alloc>
  801cbf:	83 c4 10             	add    $0x10,%esp
		return r;
  801cc2:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cc4:	85 c0                	test   %eax,%eax
  801cc6:	78 3e                	js     801d06 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cc8:	83 ec 04             	sub    $0x4,%esp
  801ccb:	68 07 04 00 00       	push   $0x407
  801cd0:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd3:	6a 00                	push   $0x0
  801cd5:	e8 23 ee ff ff       	call   800afd <sys_page_alloc>
  801cda:	83 c4 10             	add    $0x10,%esp
		return r;
  801cdd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cdf:	85 c0                	test   %eax,%eax
  801ce1:	78 23                	js     801d06 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ce3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cec:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801cf8:	83 ec 0c             	sub    $0xc,%esp
  801cfb:	50                   	push   %eax
  801cfc:	e8 1f f3 ff ff       	call   801020 <fd2num>
  801d01:	89 c2                	mov    %eax,%edx
  801d03:	83 c4 10             	add    $0x10,%esp
}
  801d06:	89 d0                	mov    %edx,%eax
  801d08:	c9                   	leave  
  801d09:	c3                   	ret    

00801d0a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d0a:	55                   	push   %ebp
  801d0b:	89 e5                	mov    %esp,%ebp
  801d0d:	56                   	push   %esi
  801d0e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d0f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d12:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d18:	e8 a2 ed ff ff       	call   800abf <sys_getenvid>
  801d1d:	83 ec 0c             	sub    $0xc,%esp
  801d20:	ff 75 0c             	pushl  0xc(%ebp)
  801d23:	ff 75 08             	pushl  0x8(%ebp)
  801d26:	56                   	push   %esi
  801d27:	50                   	push   %eax
  801d28:	68 b4 26 80 00       	push   $0x8026b4
  801d2d:	e8 43 e4 ff ff       	call   800175 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d32:	83 c4 18             	add    $0x18,%esp
  801d35:	53                   	push   %ebx
  801d36:	ff 75 10             	pushl  0x10(%ebp)
  801d39:	e8 e6 e3 ff ff       	call   800124 <vcprintf>
	cprintf("\n");
  801d3e:	c7 04 24 9f 26 80 00 	movl   $0x80269f,(%esp)
  801d45:	e8 2b e4 ff ff       	call   800175 <cprintf>
  801d4a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d4d:	cc                   	int3   
  801d4e:	eb fd                	jmp    801d4d <_panic+0x43>

00801d50 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d50:	55                   	push   %ebp
  801d51:	89 e5                	mov    %esp,%ebp
  801d53:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d56:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d5d:	75 2a                	jne    801d89 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d5f:	83 ec 04             	sub    $0x4,%esp
  801d62:	6a 07                	push   $0x7
  801d64:	68 00 f0 bf ee       	push   $0xeebff000
  801d69:	6a 00                	push   $0x0
  801d6b:	e8 8d ed ff ff       	call   800afd <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801d70:	83 c4 10             	add    $0x10,%esp
  801d73:	85 c0                	test   %eax,%eax
  801d75:	79 12                	jns    801d89 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801d77:	50                   	push   %eax
  801d78:	68 d8 26 80 00       	push   $0x8026d8
  801d7d:	6a 23                	push   $0x23
  801d7f:	68 dc 26 80 00       	push   $0x8026dc
  801d84:	e8 81 ff ff ff       	call   801d0a <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d89:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8c:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801d91:	83 ec 08             	sub    $0x8,%esp
  801d94:	68 bb 1d 80 00       	push   $0x801dbb
  801d99:	6a 00                	push   $0x0
  801d9b:	e8 a8 ee ff ff       	call   800c48 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801da0:	83 c4 10             	add    $0x10,%esp
  801da3:	85 c0                	test   %eax,%eax
  801da5:	79 12                	jns    801db9 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801da7:	50                   	push   %eax
  801da8:	68 d8 26 80 00       	push   $0x8026d8
  801dad:	6a 2c                	push   $0x2c
  801daf:	68 dc 26 80 00       	push   $0x8026dc
  801db4:	e8 51 ff ff ff       	call   801d0a <_panic>
	}
}
  801db9:	c9                   	leave  
  801dba:	c3                   	ret    

00801dbb <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801dbb:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801dbc:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801dc1:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801dc3:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801dc6:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801dca:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801dcf:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801dd3:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801dd5:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801dd8:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801dd9:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801ddc:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801ddd:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801dde:	c3                   	ret    

00801ddf <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ddf:	55                   	push   %ebp
  801de0:	89 e5                	mov    %esp,%ebp
  801de2:	56                   	push   %esi
  801de3:	53                   	push   %ebx
  801de4:	8b 75 08             	mov    0x8(%ebp),%esi
  801de7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801ded:	85 c0                	test   %eax,%eax
  801def:	75 12                	jne    801e03 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801df1:	83 ec 0c             	sub    $0xc,%esp
  801df4:	68 00 00 c0 ee       	push   $0xeec00000
  801df9:	e8 af ee ff ff       	call   800cad <sys_ipc_recv>
  801dfe:	83 c4 10             	add    $0x10,%esp
  801e01:	eb 0c                	jmp    801e0f <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e03:	83 ec 0c             	sub    $0xc,%esp
  801e06:	50                   	push   %eax
  801e07:	e8 a1 ee ff ff       	call   800cad <sys_ipc_recv>
  801e0c:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e0f:	85 f6                	test   %esi,%esi
  801e11:	0f 95 c1             	setne  %cl
  801e14:	85 db                	test   %ebx,%ebx
  801e16:	0f 95 c2             	setne  %dl
  801e19:	84 d1                	test   %dl,%cl
  801e1b:	74 09                	je     801e26 <ipc_recv+0x47>
  801e1d:	89 c2                	mov    %eax,%edx
  801e1f:	c1 ea 1f             	shr    $0x1f,%edx
  801e22:	84 d2                	test   %dl,%dl
  801e24:	75 2a                	jne    801e50 <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e26:	85 f6                	test   %esi,%esi
  801e28:	74 0d                	je     801e37 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e2a:	a1 04 40 80 00       	mov    0x804004,%eax
  801e2f:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801e35:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e37:	85 db                	test   %ebx,%ebx
  801e39:	74 0d                	je     801e48 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e3b:	a1 04 40 80 00       	mov    0x804004,%eax
  801e40:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  801e46:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e48:	a1 04 40 80 00       	mov    0x804004,%eax
  801e4d:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  801e50:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e53:	5b                   	pop    %ebx
  801e54:	5e                   	pop    %esi
  801e55:	5d                   	pop    %ebp
  801e56:	c3                   	ret    

00801e57 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e57:	55                   	push   %ebp
  801e58:	89 e5                	mov    %esp,%ebp
  801e5a:	57                   	push   %edi
  801e5b:	56                   	push   %esi
  801e5c:	53                   	push   %ebx
  801e5d:	83 ec 0c             	sub    $0xc,%esp
  801e60:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e63:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e66:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801e69:	85 db                	test   %ebx,%ebx
  801e6b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e70:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e73:	ff 75 14             	pushl  0x14(%ebp)
  801e76:	53                   	push   %ebx
  801e77:	56                   	push   %esi
  801e78:	57                   	push   %edi
  801e79:	e8 0c ee ff ff       	call   800c8a <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801e7e:	89 c2                	mov    %eax,%edx
  801e80:	c1 ea 1f             	shr    $0x1f,%edx
  801e83:	83 c4 10             	add    $0x10,%esp
  801e86:	84 d2                	test   %dl,%dl
  801e88:	74 17                	je     801ea1 <ipc_send+0x4a>
  801e8a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e8d:	74 12                	je     801ea1 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801e8f:	50                   	push   %eax
  801e90:	68 ea 26 80 00       	push   $0x8026ea
  801e95:	6a 47                	push   $0x47
  801e97:	68 f8 26 80 00       	push   $0x8026f8
  801e9c:	e8 69 fe ff ff       	call   801d0a <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801ea1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ea4:	75 07                	jne    801ead <ipc_send+0x56>
			sys_yield();
  801ea6:	e8 33 ec ff ff       	call   800ade <sys_yield>
  801eab:	eb c6                	jmp    801e73 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801ead:	85 c0                	test   %eax,%eax
  801eaf:	75 c2                	jne    801e73 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801eb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eb4:	5b                   	pop    %ebx
  801eb5:	5e                   	pop    %esi
  801eb6:	5f                   	pop    %edi
  801eb7:	5d                   	pop    %ebp
  801eb8:	c3                   	ret    

00801eb9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801eb9:	55                   	push   %ebp
  801eba:	89 e5                	mov    %esp,%ebp
  801ebc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ebf:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ec4:	89 c2                	mov    %eax,%edx
  801ec6:	c1 e2 07             	shl    $0x7,%edx
  801ec9:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  801ed0:	8b 52 5c             	mov    0x5c(%edx),%edx
  801ed3:	39 ca                	cmp    %ecx,%edx
  801ed5:	75 11                	jne    801ee8 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801ed7:	89 c2                	mov    %eax,%edx
  801ed9:	c1 e2 07             	shl    $0x7,%edx
  801edc:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801ee3:	8b 40 54             	mov    0x54(%eax),%eax
  801ee6:	eb 0f                	jmp    801ef7 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ee8:	83 c0 01             	add    $0x1,%eax
  801eeb:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ef0:	75 d2                	jne    801ec4 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ef2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ef7:	5d                   	pop    %ebp
  801ef8:	c3                   	ret    

00801ef9 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ef9:	55                   	push   %ebp
  801efa:	89 e5                	mov    %esp,%ebp
  801efc:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801eff:	89 d0                	mov    %edx,%eax
  801f01:	c1 e8 16             	shr    $0x16,%eax
  801f04:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f0b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f10:	f6 c1 01             	test   $0x1,%cl
  801f13:	74 1d                	je     801f32 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f15:	c1 ea 0c             	shr    $0xc,%edx
  801f18:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f1f:	f6 c2 01             	test   $0x1,%dl
  801f22:	74 0e                	je     801f32 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f24:	c1 ea 0c             	shr    $0xc,%edx
  801f27:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f2e:	ef 
  801f2f:	0f b7 c0             	movzwl %ax,%eax
}
  801f32:	5d                   	pop    %ebp
  801f33:	c3                   	ret    
  801f34:	66 90                	xchg   %ax,%ax
  801f36:	66 90                	xchg   %ax,%ax
  801f38:	66 90                	xchg   %ax,%ax
  801f3a:	66 90                	xchg   %ax,%ax
  801f3c:	66 90                	xchg   %ax,%ax
  801f3e:	66 90                	xchg   %ax,%ax

00801f40 <__udivdi3>:
  801f40:	55                   	push   %ebp
  801f41:	57                   	push   %edi
  801f42:	56                   	push   %esi
  801f43:	53                   	push   %ebx
  801f44:	83 ec 1c             	sub    $0x1c,%esp
  801f47:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f4b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f4f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f57:	85 f6                	test   %esi,%esi
  801f59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f5d:	89 ca                	mov    %ecx,%edx
  801f5f:	89 f8                	mov    %edi,%eax
  801f61:	75 3d                	jne    801fa0 <__udivdi3+0x60>
  801f63:	39 cf                	cmp    %ecx,%edi
  801f65:	0f 87 c5 00 00 00    	ja     802030 <__udivdi3+0xf0>
  801f6b:	85 ff                	test   %edi,%edi
  801f6d:	89 fd                	mov    %edi,%ebp
  801f6f:	75 0b                	jne    801f7c <__udivdi3+0x3c>
  801f71:	b8 01 00 00 00       	mov    $0x1,%eax
  801f76:	31 d2                	xor    %edx,%edx
  801f78:	f7 f7                	div    %edi
  801f7a:	89 c5                	mov    %eax,%ebp
  801f7c:	89 c8                	mov    %ecx,%eax
  801f7e:	31 d2                	xor    %edx,%edx
  801f80:	f7 f5                	div    %ebp
  801f82:	89 c1                	mov    %eax,%ecx
  801f84:	89 d8                	mov    %ebx,%eax
  801f86:	89 cf                	mov    %ecx,%edi
  801f88:	f7 f5                	div    %ebp
  801f8a:	89 c3                	mov    %eax,%ebx
  801f8c:	89 d8                	mov    %ebx,%eax
  801f8e:	89 fa                	mov    %edi,%edx
  801f90:	83 c4 1c             	add    $0x1c,%esp
  801f93:	5b                   	pop    %ebx
  801f94:	5e                   	pop    %esi
  801f95:	5f                   	pop    %edi
  801f96:	5d                   	pop    %ebp
  801f97:	c3                   	ret    
  801f98:	90                   	nop
  801f99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fa0:	39 ce                	cmp    %ecx,%esi
  801fa2:	77 74                	ja     802018 <__udivdi3+0xd8>
  801fa4:	0f bd fe             	bsr    %esi,%edi
  801fa7:	83 f7 1f             	xor    $0x1f,%edi
  801faa:	0f 84 98 00 00 00    	je     802048 <__udivdi3+0x108>
  801fb0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fb5:	89 f9                	mov    %edi,%ecx
  801fb7:	89 c5                	mov    %eax,%ebp
  801fb9:	29 fb                	sub    %edi,%ebx
  801fbb:	d3 e6                	shl    %cl,%esi
  801fbd:	89 d9                	mov    %ebx,%ecx
  801fbf:	d3 ed                	shr    %cl,%ebp
  801fc1:	89 f9                	mov    %edi,%ecx
  801fc3:	d3 e0                	shl    %cl,%eax
  801fc5:	09 ee                	or     %ebp,%esi
  801fc7:	89 d9                	mov    %ebx,%ecx
  801fc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fcd:	89 d5                	mov    %edx,%ebp
  801fcf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fd3:	d3 ed                	shr    %cl,%ebp
  801fd5:	89 f9                	mov    %edi,%ecx
  801fd7:	d3 e2                	shl    %cl,%edx
  801fd9:	89 d9                	mov    %ebx,%ecx
  801fdb:	d3 e8                	shr    %cl,%eax
  801fdd:	09 c2                	or     %eax,%edx
  801fdf:	89 d0                	mov    %edx,%eax
  801fe1:	89 ea                	mov    %ebp,%edx
  801fe3:	f7 f6                	div    %esi
  801fe5:	89 d5                	mov    %edx,%ebp
  801fe7:	89 c3                	mov    %eax,%ebx
  801fe9:	f7 64 24 0c          	mull   0xc(%esp)
  801fed:	39 d5                	cmp    %edx,%ebp
  801fef:	72 10                	jb     802001 <__udivdi3+0xc1>
  801ff1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801ff5:	89 f9                	mov    %edi,%ecx
  801ff7:	d3 e6                	shl    %cl,%esi
  801ff9:	39 c6                	cmp    %eax,%esi
  801ffb:	73 07                	jae    802004 <__udivdi3+0xc4>
  801ffd:	39 d5                	cmp    %edx,%ebp
  801fff:	75 03                	jne    802004 <__udivdi3+0xc4>
  802001:	83 eb 01             	sub    $0x1,%ebx
  802004:	31 ff                	xor    %edi,%edi
  802006:	89 d8                	mov    %ebx,%eax
  802008:	89 fa                	mov    %edi,%edx
  80200a:	83 c4 1c             	add    $0x1c,%esp
  80200d:	5b                   	pop    %ebx
  80200e:	5e                   	pop    %esi
  80200f:	5f                   	pop    %edi
  802010:	5d                   	pop    %ebp
  802011:	c3                   	ret    
  802012:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802018:	31 ff                	xor    %edi,%edi
  80201a:	31 db                	xor    %ebx,%ebx
  80201c:	89 d8                	mov    %ebx,%eax
  80201e:	89 fa                	mov    %edi,%edx
  802020:	83 c4 1c             	add    $0x1c,%esp
  802023:	5b                   	pop    %ebx
  802024:	5e                   	pop    %esi
  802025:	5f                   	pop    %edi
  802026:	5d                   	pop    %ebp
  802027:	c3                   	ret    
  802028:	90                   	nop
  802029:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802030:	89 d8                	mov    %ebx,%eax
  802032:	f7 f7                	div    %edi
  802034:	31 ff                	xor    %edi,%edi
  802036:	89 c3                	mov    %eax,%ebx
  802038:	89 d8                	mov    %ebx,%eax
  80203a:	89 fa                	mov    %edi,%edx
  80203c:	83 c4 1c             	add    $0x1c,%esp
  80203f:	5b                   	pop    %ebx
  802040:	5e                   	pop    %esi
  802041:	5f                   	pop    %edi
  802042:	5d                   	pop    %ebp
  802043:	c3                   	ret    
  802044:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802048:	39 ce                	cmp    %ecx,%esi
  80204a:	72 0c                	jb     802058 <__udivdi3+0x118>
  80204c:	31 db                	xor    %ebx,%ebx
  80204e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802052:	0f 87 34 ff ff ff    	ja     801f8c <__udivdi3+0x4c>
  802058:	bb 01 00 00 00       	mov    $0x1,%ebx
  80205d:	e9 2a ff ff ff       	jmp    801f8c <__udivdi3+0x4c>
  802062:	66 90                	xchg   %ax,%ax
  802064:	66 90                	xchg   %ax,%ax
  802066:	66 90                	xchg   %ax,%ax
  802068:	66 90                	xchg   %ax,%ax
  80206a:	66 90                	xchg   %ax,%ax
  80206c:	66 90                	xchg   %ax,%ax
  80206e:	66 90                	xchg   %ax,%ax

00802070 <__umoddi3>:
  802070:	55                   	push   %ebp
  802071:	57                   	push   %edi
  802072:	56                   	push   %esi
  802073:	53                   	push   %ebx
  802074:	83 ec 1c             	sub    $0x1c,%esp
  802077:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80207b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80207f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802083:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802087:	85 d2                	test   %edx,%edx
  802089:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80208d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802091:	89 f3                	mov    %esi,%ebx
  802093:	89 3c 24             	mov    %edi,(%esp)
  802096:	89 74 24 04          	mov    %esi,0x4(%esp)
  80209a:	75 1c                	jne    8020b8 <__umoddi3+0x48>
  80209c:	39 f7                	cmp    %esi,%edi
  80209e:	76 50                	jbe    8020f0 <__umoddi3+0x80>
  8020a0:	89 c8                	mov    %ecx,%eax
  8020a2:	89 f2                	mov    %esi,%edx
  8020a4:	f7 f7                	div    %edi
  8020a6:	89 d0                	mov    %edx,%eax
  8020a8:	31 d2                	xor    %edx,%edx
  8020aa:	83 c4 1c             	add    $0x1c,%esp
  8020ad:	5b                   	pop    %ebx
  8020ae:	5e                   	pop    %esi
  8020af:	5f                   	pop    %edi
  8020b0:	5d                   	pop    %ebp
  8020b1:	c3                   	ret    
  8020b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020b8:	39 f2                	cmp    %esi,%edx
  8020ba:	89 d0                	mov    %edx,%eax
  8020bc:	77 52                	ja     802110 <__umoddi3+0xa0>
  8020be:	0f bd ea             	bsr    %edx,%ebp
  8020c1:	83 f5 1f             	xor    $0x1f,%ebp
  8020c4:	75 5a                	jne    802120 <__umoddi3+0xb0>
  8020c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020ca:	0f 82 e0 00 00 00    	jb     8021b0 <__umoddi3+0x140>
  8020d0:	39 0c 24             	cmp    %ecx,(%esp)
  8020d3:	0f 86 d7 00 00 00    	jbe    8021b0 <__umoddi3+0x140>
  8020d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020e1:	83 c4 1c             	add    $0x1c,%esp
  8020e4:	5b                   	pop    %ebx
  8020e5:	5e                   	pop    %esi
  8020e6:	5f                   	pop    %edi
  8020e7:	5d                   	pop    %ebp
  8020e8:	c3                   	ret    
  8020e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020f0:	85 ff                	test   %edi,%edi
  8020f2:	89 fd                	mov    %edi,%ebp
  8020f4:	75 0b                	jne    802101 <__umoddi3+0x91>
  8020f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020fb:	31 d2                	xor    %edx,%edx
  8020fd:	f7 f7                	div    %edi
  8020ff:	89 c5                	mov    %eax,%ebp
  802101:	89 f0                	mov    %esi,%eax
  802103:	31 d2                	xor    %edx,%edx
  802105:	f7 f5                	div    %ebp
  802107:	89 c8                	mov    %ecx,%eax
  802109:	f7 f5                	div    %ebp
  80210b:	89 d0                	mov    %edx,%eax
  80210d:	eb 99                	jmp    8020a8 <__umoddi3+0x38>
  80210f:	90                   	nop
  802110:	89 c8                	mov    %ecx,%eax
  802112:	89 f2                	mov    %esi,%edx
  802114:	83 c4 1c             	add    $0x1c,%esp
  802117:	5b                   	pop    %ebx
  802118:	5e                   	pop    %esi
  802119:	5f                   	pop    %edi
  80211a:	5d                   	pop    %ebp
  80211b:	c3                   	ret    
  80211c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802120:	8b 34 24             	mov    (%esp),%esi
  802123:	bf 20 00 00 00       	mov    $0x20,%edi
  802128:	89 e9                	mov    %ebp,%ecx
  80212a:	29 ef                	sub    %ebp,%edi
  80212c:	d3 e0                	shl    %cl,%eax
  80212e:	89 f9                	mov    %edi,%ecx
  802130:	89 f2                	mov    %esi,%edx
  802132:	d3 ea                	shr    %cl,%edx
  802134:	89 e9                	mov    %ebp,%ecx
  802136:	09 c2                	or     %eax,%edx
  802138:	89 d8                	mov    %ebx,%eax
  80213a:	89 14 24             	mov    %edx,(%esp)
  80213d:	89 f2                	mov    %esi,%edx
  80213f:	d3 e2                	shl    %cl,%edx
  802141:	89 f9                	mov    %edi,%ecx
  802143:	89 54 24 04          	mov    %edx,0x4(%esp)
  802147:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80214b:	d3 e8                	shr    %cl,%eax
  80214d:	89 e9                	mov    %ebp,%ecx
  80214f:	89 c6                	mov    %eax,%esi
  802151:	d3 e3                	shl    %cl,%ebx
  802153:	89 f9                	mov    %edi,%ecx
  802155:	89 d0                	mov    %edx,%eax
  802157:	d3 e8                	shr    %cl,%eax
  802159:	89 e9                	mov    %ebp,%ecx
  80215b:	09 d8                	or     %ebx,%eax
  80215d:	89 d3                	mov    %edx,%ebx
  80215f:	89 f2                	mov    %esi,%edx
  802161:	f7 34 24             	divl   (%esp)
  802164:	89 d6                	mov    %edx,%esi
  802166:	d3 e3                	shl    %cl,%ebx
  802168:	f7 64 24 04          	mull   0x4(%esp)
  80216c:	39 d6                	cmp    %edx,%esi
  80216e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802172:	89 d1                	mov    %edx,%ecx
  802174:	89 c3                	mov    %eax,%ebx
  802176:	72 08                	jb     802180 <__umoddi3+0x110>
  802178:	75 11                	jne    80218b <__umoddi3+0x11b>
  80217a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80217e:	73 0b                	jae    80218b <__umoddi3+0x11b>
  802180:	2b 44 24 04          	sub    0x4(%esp),%eax
  802184:	1b 14 24             	sbb    (%esp),%edx
  802187:	89 d1                	mov    %edx,%ecx
  802189:	89 c3                	mov    %eax,%ebx
  80218b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80218f:	29 da                	sub    %ebx,%edx
  802191:	19 ce                	sbb    %ecx,%esi
  802193:	89 f9                	mov    %edi,%ecx
  802195:	89 f0                	mov    %esi,%eax
  802197:	d3 e0                	shl    %cl,%eax
  802199:	89 e9                	mov    %ebp,%ecx
  80219b:	d3 ea                	shr    %cl,%edx
  80219d:	89 e9                	mov    %ebp,%ecx
  80219f:	d3 ee                	shr    %cl,%esi
  8021a1:	09 d0                	or     %edx,%eax
  8021a3:	89 f2                	mov    %esi,%edx
  8021a5:	83 c4 1c             	add    $0x1c,%esp
  8021a8:	5b                   	pop    %ebx
  8021a9:	5e                   	pop    %esi
  8021aa:	5f                   	pop    %edi
  8021ab:	5d                   	pop    %ebp
  8021ac:	c3                   	ret    
  8021ad:	8d 76 00             	lea    0x0(%esi),%esi
  8021b0:	29 f9                	sub    %edi,%ecx
  8021b2:	19 d6                	sbb    %edx,%esi
  8021b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021bc:	e9 18 ff ff ff       	jmp    8020d9 <__umoddi3+0x69>
