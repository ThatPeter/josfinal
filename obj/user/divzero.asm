
obj/user/divzero.debug:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  800039:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 e0 21 80 00       	push   $0x8021e0
  800056:	e8 1c 01 00 00       	call   800177 <cprintf>
}
  80005b:	83 c4 10             	add    $0x10,%esp
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800068:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80006b:	e8 51 0a 00 00       	call   800ac1 <sys_getenvid>
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	89 c2                	mov    %eax,%edx
  800077:	c1 e2 07             	shl    $0x7,%edx
  80007a:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800081:	a3 08 40 80 00       	mov    %eax,0x804008
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800086:	85 db                	test   %ebx,%ebx
  800088:	7e 07                	jle    800091 <libmain+0x31>
		binaryname = argv[0];
  80008a:	8b 06                	mov    (%esi),%eax
  80008c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800091:	83 ec 08             	sub    $0x8,%esp
  800094:	56                   	push   %esi
  800095:	53                   	push   %ebx
  800096:	e8 98 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009b:	e8 2a 00 00 00       	call   8000ca <exit>
}
  8000a0:	83 c4 10             	add    $0x10,%esp
  8000a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a6:	5b                   	pop    %ebx
  8000a7:	5e                   	pop    %esi
  8000a8:	5d                   	pop    %ebp
  8000a9:	c3                   	ret    

008000aa <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  8000b0:	a1 0c 40 80 00       	mov    0x80400c,%eax
	func();
  8000b5:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8000b7:	e8 05 0a 00 00       	call   800ac1 <sys_getenvid>
  8000bc:	83 ec 0c             	sub    $0xc,%esp
  8000bf:	50                   	push   %eax
  8000c0:	e8 4b 0c 00 00       	call   800d10 <sys_thread_free>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000d0:	e8 18 11 00 00       	call   8011ed <close_all>
	sys_env_destroy(0);
  8000d5:	83 ec 0c             	sub    $0xc,%esp
  8000d8:	6a 00                	push   $0x0
  8000da:	e8 a1 09 00 00       	call   800a80 <sys_env_destroy>
}
  8000df:	83 c4 10             	add    $0x10,%esp
  8000e2:	c9                   	leave  
  8000e3:	c3                   	ret    

008000e4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	53                   	push   %ebx
  8000e8:	83 ec 04             	sub    $0x4,%esp
  8000eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ee:	8b 13                	mov    (%ebx),%edx
  8000f0:	8d 42 01             	lea    0x1(%edx),%eax
  8000f3:	89 03                	mov    %eax,(%ebx)
  8000f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000fc:	3d ff 00 00 00       	cmp    $0xff,%eax
  800101:	75 1a                	jne    80011d <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800103:	83 ec 08             	sub    $0x8,%esp
  800106:	68 ff 00 00 00       	push   $0xff
  80010b:	8d 43 08             	lea    0x8(%ebx),%eax
  80010e:	50                   	push   %eax
  80010f:	e8 2f 09 00 00       	call   800a43 <sys_cputs>
		b->idx = 0;
  800114:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80011a:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80011d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800121:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800124:	c9                   	leave  
  800125:	c3                   	ret    

00800126 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800126:	55                   	push   %ebp
  800127:	89 e5                	mov    %esp,%ebp
  800129:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80012f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800136:	00 00 00 
	b.cnt = 0;
  800139:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800140:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800143:	ff 75 0c             	pushl  0xc(%ebp)
  800146:	ff 75 08             	pushl  0x8(%ebp)
  800149:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014f:	50                   	push   %eax
  800150:	68 e4 00 80 00       	push   $0x8000e4
  800155:	e8 54 01 00 00       	call   8002ae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80015a:	83 c4 08             	add    $0x8,%esp
  80015d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800163:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800169:	50                   	push   %eax
  80016a:	e8 d4 08 00 00       	call   800a43 <sys_cputs>

	return b.cnt;
}
  80016f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800175:	c9                   	leave  
  800176:	c3                   	ret    

00800177 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80017d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800180:	50                   	push   %eax
  800181:	ff 75 08             	pushl  0x8(%ebp)
  800184:	e8 9d ff ff ff       	call   800126 <vcprintf>
	va_end(ap);

	return cnt;
}
  800189:	c9                   	leave  
  80018a:	c3                   	ret    

0080018b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80018b:	55                   	push   %ebp
  80018c:	89 e5                	mov    %esp,%ebp
  80018e:	57                   	push   %edi
  80018f:	56                   	push   %esi
  800190:	53                   	push   %ebx
  800191:	83 ec 1c             	sub    $0x1c,%esp
  800194:	89 c7                	mov    %eax,%edi
  800196:	89 d6                	mov    %edx,%esi
  800198:	8b 45 08             	mov    0x8(%ebp),%eax
  80019b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001a1:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001a7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ac:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001af:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001b2:	39 d3                	cmp    %edx,%ebx
  8001b4:	72 05                	jb     8001bb <printnum+0x30>
  8001b6:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b9:	77 45                	ja     800200 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001bb:	83 ec 0c             	sub    $0xc,%esp
  8001be:	ff 75 18             	pushl  0x18(%ebp)
  8001c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8001c4:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001c7:	53                   	push   %ebx
  8001c8:	ff 75 10             	pushl  0x10(%ebp)
  8001cb:	83 ec 08             	sub    $0x8,%esp
  8001ce:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001d1:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d4:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d7:	ff 75 d8             	pushl  -0x28(%ebp)
  8001da:	e8 61 1d 00 00       	call   801f40 <__udivdi3>
  8001df:	83 c4 18             	add    $0x18,%esp
  8001e2:	52                   	push   %edx
  8001e3:	50                   	push   %eax
  8001e4:	89 f2                	mov    %esi,%edx
  8001e6:	89 f8                	mov    %edi,%eax
  8001e8:	e8 9e ff ff ff       	call   80018b <printnum>
  8001ed:	83 c4 20             	add    $0x20,%esp
  8001f0:	eb 18                	jmp    80020a <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001f2:	83 ec 08             	sub    $0x8,%esp
  8001f5:	56                   	push   %esi
  8001f6:	ff 75 18             	pushl  0x18(%ebp)
  8001f9:	ff d7                	call   *%edi
  8001fb:	83 c4 10             	add    $0x10,%esp
  8001fe:	eb 03                	jmp    800203 <printnum+0x78>
  800200:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800203:	83 eb 01             	sub    $0x1,%ebx
  800206:	85 db                	test   %ebx,%ebx
  800208:	7f e8                	jg     8001f2 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80020a:	83 ec 08             	sub    $0x8,%esp
  80020d:	56                   	push   %esi
  80020e:	83 ec 04             	sub    $0x4,%esp
  800211:	ff 75 e4             	pushl  -0x1c(%ebp)
  800214:	ff 75 e0             	pushl  -0x20(%ebp)
  800217:	ff 75 dc             	pushl  -0x24(%ebp)
  80021a:	ff 75 d8             	pushl  -0x28(%ebp)
  80021d:	e8 4e 1e 00 00       	call   802070 <__umoddi3>
  800222:	83 c4 14             	add    $0x14,%esp
  800225:	0f be 80 f8 21 80 00 	movsbl 0x8021f8(%eax),%eax
  80022c:	50                   	push   %eax
  80022d:	ff d7                	call   *%edi
}
  80022f:	83 c4 10             	add    $0x10,%esp
  800232:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800235:	5b                   	pop    %ebx
  800236:	5e                   	pop    %esi
  800237:	5f                   	pop    %edi
  800238:	5d                   	pop    %ebp
  800239:	c3                   	ret    

0080023a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80023d:	83 fa 01             	cmp    $0x1,%edx
  800240:	7e 0e                	jle    800250 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800242:	8b 10                	mov    (%eax),%edx
  800244:	8d 4a 08             	lea    0x8(%edx),%ecx
  800247:	89 08                	mov    %ecx,(%eax)
  800249:	8b 02                	mov    (%edx),%eax
  80024b:	8b 52 04             	mov    0x4(%edx),%edx
  80024e:	eb 22                	jmp    800272 <getuint+0x38>
	else if (lflag)
  800250:	85 d2                	test   %edx,%edx
  800252:	74 10                	je     800264 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800254:	8b 10                	mov    (%eax),%edx
  800256:	8d 4a 04             	lea    0x4(%edx),%ecx
  800259:	89 08                	mov    %ecx,(%eax)
  80025b:	8b 02                	mov    (%edx),%eax
  80025d:	ba 00 00 00 00       	mov    $0x0,%edx
  800262:	eb 0e                	jmp    800272 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800264:	8b 10                	mov    (%eax),%edx
  800266:	8d 4a 04             	lea    0x4(%edx),%ecx
  800269:	89 08                	mov    %ecx,(%eax)
  80026b:	8b 02                	mov    (%edx),%eax
  80026d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80027a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80027e:	8b 10                	mov    (%eax),%edx
  800280:	3b 50 04             	cmp    0x4(%eax),%edx
  800283:	73 0a                	jae    80028f <sprintputch+0x1b>
		*b->buf++ = ch;
  800285:	8d 4a 01             	lea    0x1(%edx),%ecx
  800288:	89 08                	mov    %ecx,(%eax)
  80028a:	8b 45 08             	mov    0x8(%ebp),%eax
  80028d:	88 02                	mov    %al,(%edx)
}
  80028f:	5d                   	pop    %ebp
  800290:	c3                   	ret    

00800291 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800297:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80029a:	50                   	push   %eax
  80029b:	ff 75 10             	pushl  0x10(%ebp)
  80029e:	ff 75 0c             	pushl  0xc(%ebp)
  8002a1:	ff 75 08             	pushl  0x8(%ebp)
  8002a4:	e8 05 00 00 00       	call   8002ae <vprintfmt>
	va_end(ap);
}
  8002a9:	83 c4 10             	add    $0x10,%esp
  8002ac:	c9                   	leave  
  8002ad:	c3                   	ret    

008002ae <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 2c             	sub    $0x2c,%esp
  8002b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8002ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002bd:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002c0:	eb 12                	jmp    8002d4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002c2:	85 c0                	test   %eax,%eax
  8002c4:	0f 84 89 03 00 00    	je     800653 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002ca:	83 ec 08             	sub    $0x8,%esp
  8002cd:	53                   	push   %ebx
  8002ce:	50                   	push   %eax
  8002cf:	ff d6                	call   *%esi
  8002d1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002d4:	83 c7 01             	add    $0x1,%edi
  8002d7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002db:	83 f8 25             	cmp    $0x25,%eax
  8002de:	75 e2                	jne    8002c2 <vprintfmt+0x14>
  8002e0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002e4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002eb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002f2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fe:	eb 07                	jmp    800307 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800300:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800303:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800307:	8d 47 01             	lea    0x1(%edi),%eax
  80030a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80030d:	0f b6 07             	movzbl (%edi),%eax
  800310:	0f b6 c8             	movzbl %al,%ecx
  800313:	83 e8 23             	sub    $0x23,%eax
  800316:	3c 55                	cmp    $0x55,%al
  800318:	0f 87 1a 03 00 00    	ja     800638 <vprintfmt+0x38a>
  80031e:	0f b6 c0             	movzbl %al,%eax
  800321:	ff 24 85 40 23 80 00 	jmp    *0x802340(,%eax,4)
  800328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80032b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80032f:	eb d6                	jmp    800307 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800331:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800334:	b8 00 00 00 00       	mov    $0x0,%eax
  800339:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80033c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80033f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800343:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800346:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800349:	83 fa 09             	cmp    $0x9,%edx
  80034c:	77 39                	ja     800387 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80034e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800351:	eb e9                	jmp    80033c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800353:	8b 45 14             	mov    0x14(%ebp),%eax
  800356:	8d 48 04             	lea    0x4(%eax),%ecx
  800359:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80035c:	8b 00                	mov    (%eax),%eax
  80035e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800361:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800364:	eb 27                	jmp    80038d <vprintfmt+0xdf>
  800366:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800369:	85 c0                	test   %eax,%eax
  80036b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800370:	0f 49 c8             	cmovns %eax,%ecx
  800373:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800376:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800379:	eb 8c                	jmp    800307 <vprintfmt+0x59>
  80037b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80037e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800385:	eb 80                	jmp    800307 <vprintfmt+0x59>
  800387:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80038a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80038d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800391:	0f 89 70 ff ff ff    	jns    800307 <vprintfmt+0x59>
				width = precision, precision = -1;
  800397:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80039a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80039d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a4:	e9 5e ff ff ff       	jmp    800307 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003a9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003af:	e9 53 ff ff ff       	jmp    800307 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b7:	8d 50 04             	lea    0x4(%eax),%edx
  8003ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8003bd:	83 ec 08             	sub    $0x8,%esp
  8003c0:	53                   	push   %ebx
  8003c1:	ff 30                	pushl  (%eax)
  8003c3:	ff d6                	call   *%esi
			break;
  8003c5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003cb:	e9 04 ff ff ff       	jmp    8002d4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d3:	8d 50 04             	lea    0x4(%eax),%edx
  8003d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d9:	8b 00                	mov    (%eax),%eax
  8003db:	99                   	cltd   
  8003dc:	31 d0                	xor    %edx,%eax
  8003de:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e0:	83 f8 0f             	cmp    $0xf,%eax
  8003e3:	7f 0b                	jg     8003f0 <vprintfmt+0x142>
  8003e5:	8b 14 85 a0 24 80 00 	mov    0x8024a0(,%eax,4),%edx
  8003ec:	85 d2                	test   %edx,%edx
  8003ee:	75 18                	jne    800408 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003f0:	50                   	push   %eax
  8003f1:	68 10 22 80 00       	push   $0x802210
  8003f6:	53                   	push   %ebx
  8003f7:	56                   	push   %esi
  8003f8:	e8 94 fe ff ff       	call   800291 <printfmt>
  8003fd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800400:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800403:	e9 cc fe ff ff       	jmp    8002d4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800408:	52                   	push   %edx
  800409:	68 4d 26 80 00       	push   $0x80264d
  80040e:	53                   	push   %ebx
  80040f:	56                   	push   %esi
  800410:	e8 7c fe ff ff       	call   800291 <printfmt>
  800415:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800418:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80041b:	e9 b4 fe ff ff       	jmp    8002d4 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800420:	8b 45 14             	mov    0x14(%ebp),%eax
  800423:	8d 50 04             	lea    0x4(%eax),%edx
  800426:	89 55 14             	mov    %edx,0x14(%ebp)
  800429:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80042b:	85 ff                	test   %edi,%edi
  80042d:	b8 09 22 80 00       	mov    $0x802209,%eax
  800432:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800435:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800439:	0f 8e 94 00 00 00    	jle    8004d3 <vprintfmt+0x225>
  80043f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800443:	0f 84 98 00 00 00    	je     8004e1 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800449:	83 ec 08             	sub    $0x8,%esp
  80044c:	ff 75 d0             	pushl  -0x30(%ebp)
  80044f:	57                   	push   %edi
  800450:	e8 86 02 00 00       	call   8006db <strnlen>
  800455:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800458:	29 c1                	sub    %eax,%ecx
  80045a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80045d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800460:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800464:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800467:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80046a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80046c:	eb 0f                	jmp    80047d <vprintfmt+0x1cf>
					putch(padc, putdat);
  80046e:	83 ec 08             	sub    $0x8,%esp
  800471:	53                   	push   %ebx
  800472:	ff 75 e0             	pushl  -0x20(%ebp)
  800475:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800477:	83 ef 01             	sub    $0x1,%edi
  80047a:	83 c4 10             	add    $0x10,%esp
  80047d:	85 ff                	test   %edi,%edi
  80047f:	7f ed                	jg     80046e <vprintfmt+0x1c0>
  800481:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800484:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800487:	85 c9                	test   %ecx,%ecx
  800489:	b8 00 00 00 00       	mov    $0x0,%eax
  80048e:	0f 49 c1             	cmovns %ecx,%eax
  800491:	29 c1                	sub    %eax,%ecx
  800493:	89 75 08             	mov    %esi,0x8(%ebp)
  800496:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800499:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80049c:	89 cb                	mov    %ecx,%ebx
  80049e:	eb 4d                	jmp    8004ed <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004a0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004a4:	74 1b                	je     8004c1 <vprintfmt+0x213>
  8004a6:	0f be c0             	movsbl %al,%eax
  8004a9:	83 e8 20             	sub    $0x20,%eax
  8004ac:	83 f8 5e             	cmp    $0x5e,%eax
  8004af:	76 10                	jbe    8004c1 <vprintfmt+0x213>
					putch('?', putdat);
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	ff 75 0c             	pushl  0xc(%ebp)
  8004b7:	6a 3f                	push   $0x3f
  8004b9:	ff 55 08             	call   *0x8(%ebp)
  8004bc:	83 c4 10             	add    $0x10,%esp
  8004bf:	eb 0d                	jmp    8004ce <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004c1:	83 ec 08             	sub    $0x8,%esp
  8004c4:	ff 75 0c             	pushl  0xc(%ebp)
  8004c7:	52                   	push   %edx
  8004c8:	ff 55 08             	call   *0x8(%ebp)
  8004cb:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ce:	83 eb 01             	sub    $0x1,%ebx
  8004d1:	eb 1a                	jmp    8004ed <vprintfmt+0x23f>
  8004d3:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004dc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004df:	eb 0c                	jmp    8004ed <vprintfmt+0x23f>
  8004e1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ea:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ed:	83 c7 01             	add    $0x1,%edi
  8004f0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f4:	0f be d0             	movsbl %al,%edx
  8004f7:	85 d2                	test   %edx,%edx
  8004f9:	74 23                	je     80051e <vprintfmt+0x270>
  8004fb:	85 f6                	test   %esi,%esi
  8004fd:	78 a1                	js     8004a0 <vprintfmt+0x1f2>
  8004ff:	83 ee 01             	sub    $0x1,%esi
  800502:	79 9c                	jns    8004a0 <vprintfmt+0x1f2>
  800504:	89 df                	mov    %ebx,%edi
  800506:	8b 75 08             	mov    0x8(%ebp),%esi
  800509:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050c:	eb 18                	jmp    800526 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	53                   	push   %ebx
  800512:	6a 20                	push   $0x20
  800514:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800516:	83 ef 01             	sub    $0x1,%edi
  800519:	83 c4 10             	add    $0x10,%esp
  80051c:	eb 08                	jmp    800526 <vprintfmt+0x278>
  80051e:	89 df                	mov    %ebx,%edi
  800520:	8b 75 08             	mov    0x8(%ebp),%esi
  800523:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800526:	85 ff                	test   %edi,%edi
  800528:	7f e4                	jg     80050e <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80052d:	e9 a2 fd ff ff       	jmp    8002d4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800532:	83 fa 01             	cmp    $0x1,%edx
  800535:	7e 16                	jle    80054d <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800537:	8b 45 14             	mov    0x14(%ebp),%eax
  80053a:	8d 50 08             	lea    0x8(%eax),%edx
  80053d:	89 55 14             	mov    %edx,0x14(%ebp)
  800540:	8b 50 04             	mov    0x4(%eax),%edx
  800543:	8b 00                	mov    (%eax),%eax
  800545:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800548:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80054b:	eb 32                	jmp    80057f <vprintfmt+0x2d1>
	else if (lflag)
  80054d:	85 d2                	test   %edx,%edx
  80054f:	74 18                	je     800569 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800551:	8b 45 14             	mov    0x14(%ebp),%eax
  800554:	8d 50 04             	lea    0x4(%eax),%edx
  800557:	89 55 14             	mov    %edx,0x14(%ebp)
  80055a:	8b 00                	mov    (%eax),%eax
  80055c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055f:	89 c1                	mov    %eax,%ecx
  800561:	c1 f9 1f             	sar    $0x1f,%ecx
  800564:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800567:	eb 16                	jmp    80057f <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8d 50 04             	lea    0x4(%eax),%edx
  80056f:	89 55 14             	mov    %edx,0x14(%ebp)
  800572:	8b 00                	mov    (%eax),%eax
  800574:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800577:	89 c1                	mov    %eax,%ecx
  800579:	c1 f9 1f             	sar    $0x1f,%ecx
  80057c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80057f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800582:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800585:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80058a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80058e:	79 74                	jns    800604 <vprintfmt+0x356>
				putch('-', putdat);
  800590:	83 ec 08             	sub    $0x8,%esp
  800593:	53                   	push   %ebx
  800594:	6a 2d                	push   $0x2d
  800596:	ff d6                	call   *%esi
				num = -(long long) num;
  800598:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80059b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80059e:	f7 d8                	neg    %eax
  8005a0:	83 d2 00             	adc    $0x0,%edx
  8005a3:	f7 da                	neg    %edx
  8005a5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005a8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005ad:	eb 55                	jmp    800604 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005af:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b2:	e8 83 fc ff ff       	call   80023a <getuint>
			base = 10;
  8005b7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005bc:	eb 46                	jmp    800604 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005be:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c1:	e8 74 fc ff ff       	call   80023a <getuint>
			base = 8;
  8005c6:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005cb:	eb 37                	jmp    800604 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005cd:	83 ec 08             	sub    $0x8,%esp
  8005d0:	53                   	push   %ebx
  8005d1:	6a 30                	push   $0x30
  8005d3:	ff d6                	call   *%esi
			putch('x', putdat);
  8005d5:	83 c4 08             	add    $0x8,%esp
  8005d8:	53                   	push   %ebx
  8005d9:	6a 78                	push   $0x78
  8005db:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8d 50 04             	lea    0x4(%eax),%edx
  8005e3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005e6:	8b 00                	mov    (%eax),%eax
  8005e8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005ed:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005f0:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005f5:	eb 0d                	jmp    800604 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fa:	e8 3b fc ff ff       	call   80023a <getuint>
			base = 16;
  8005ff:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800604:	83 ec 0c             	sub    $0xc,%esp
  800607:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80060b:	57                   	push   %edi
  80060c:	ff 75 e0             	pushl  -0x20(%ebp)
  80060f:	51                   	push   %ecx
  800610:	52                   	push   %edx
  800611:	50                   	push   %eax
  800612:	89 da                	mov    %ebx,%edx
  800614:	89 f0                	mov    %esi,%eax
  800616:	e8 70 fb ff ff       	call   80018b <printnum>
			break;
  80061b:	83 c4 20             	add    $0x20,%esp
  80061e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800621:	e9 ae fc ff ff       	jmp    8002d4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800626:	83 ec 08             	sub    $0x8,%esp
  800629:	53                   	push   %ebx
  80062a:	51                   	push   %ecx
  80062b:	ff d6                	call   *%esi
			break;
  80062d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800630:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800633:	e9 9c fc ff ff       	jmp    8002d4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800638:	83 ec 08             	sub    $0x8,%esp
  80063b:	53                   	push   %ebx
  80063c:	6a 25                	push   $0x25
  80063e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800640:	83 c4 10             	add    $0x10,%esp
  800643:	eb 03                	jmp    800648 <vprintfmt+0x39a>
  800645:	83 ef 01             	sub    $0x1,%edi
  800648:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80064c:	75 f7                	jne    800645 <vprintfmt+0x397>
  80064e:	e9 81 fc ff ff       	jmp    8002d4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800653:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800656:	5b                   	pop    %ebx
  800657:	5e                   	pop    %esi
  800658:	5f                   	pop    %edi
  800659:	5d                   	pop    %ebp
  80065a:	c3                   	ret    

0080065b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80065b:	55                   	push   %ebp
  80065c:	89 e5                	mov    %esp,%ebp
  80065e:	83 ec 18             	sub    $0x18,%esp
  800661:	8b 45 08             	mov    0x8(%ebp),%eax
  800664:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800667:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80066a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80066e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800671:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800678:	85 c0                	test   %eax,%eax
  80067a:	74 26                	je     8006a2 <vsnprintf+0x47>
  80067c:	85 d2                	test   %edx,%edx
  80067e:	7e 22                	jle    8006a2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800680:	ff 75 14             	pushl  0x14(%ebp)
  800683:	ff 75 10             	pushl  0x10(%ebp)
  800686:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800689:	50                   	push   %eax
  80068a:	68 74 02 80 00       	push   $0x800274
  80068f:	e8 1a fc ff ff       	call   8002ae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800694:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800697:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80069a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069d:	83 c4 10             	add    $0x10,%esp
  8006a0:	eb 05                	jmp    8006a7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006a7:	c9                   	leave  
  8006a8:	c3                   	ret    

008006a9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006a9:	55                   	push   %ebp
  8006aa:	89 e5                	mov    %esp,%ebp
  8006ac:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006af:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006b2:	50                   	push   %eax
  8006b3:	ff 75 10             	pushl  0x10(%ebp)
  8006b6:	ff 75 0c             	pushl  0xc(%ebp)
  8006b9:	ff 75 08             	pushl  0x8(%ebp)
  8006bc:	e8 9a ff ff ff       	call   80065b <vsnprintf>
	va_end(ap);

	return rc;
}
  8006c1:	c9                   	leave  
  8006c2:	c3                   	ret    

008006c3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006c3:	55                   	push   %ebp
  8006c4:	89 e5                	mov    %esp,%ebp
  8006c6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ce:	eb 03                	jmp    8006d3 <strlen+0x10>
		n++;
  8006d0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006d3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006d7:	75 f7                	jne    8006d0 <strlen+0xd>
		n++;
	return n;
}
  8006d9:	5d                   	pop    %ebp
  8006da:	c3                   	ret    

008006db <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006db:	55                   	push   %ebp
  8006dc:	89 e5                	mov    %esp,%ebp
  8006de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e1:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8006e9:	eb 03                	jmp    8006ee <strnlen+0x13>
		n++;
  8006eb:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ee:	39 c2                	cmp    %eax,%edx
  8006f0:	74 08                	je     8006fa <strnlen+0x1f>
  8006f2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006f6:	75 f3                	jne    8006eb <strnlen+0x10>
  8006f8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006fa:	5d                   	pop    %ebp
  8006fb:	c3                   	ret    

008006fc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	53                   	push   %ebx
  800700:	8b 45 08             	mov    0x8(%ebp),%eax
  800703:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800706:	89 c2                	mov    %eax,%edx
  800708:	83 c2 01             	add    $0x1,%edx
  80070b:	83 c1 01             	add    $0x1,%ecx
  80070e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800712:	88 5a ff             	mov    %bl,-0x1(%edx)
  800715:	84 db                	test   %bl,%bl
  800717:	75 ef                	jne    800708 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800719:	5b                   	pop    %ebx
  80071a:	5d                   	pop    %ebp
  80071b:	c3                   	ret    

0080071c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	53                   	push   %ebx
  800720:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800723:	53                   	push   %ebx
  800724:	e8 9a ff ff ff       	call   8006c3 <strlen>
  800729:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80072c:	ff 75 0c             	pushl  0xc(%ebp)
  80072f:	01 d8                	add    %ebx,%eax
  800731:	50                   	push   %eax
  800732:	e8 c5 ff ff ff       	call   8006fc <strcpy>
	return dst;
}
  800737:	89 d8                	mov    %ebx,%eax
  800739:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80073c:	c9                   	leave  
  80073d:	c3                   	ret    

0080073e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	56                   	push   %esi
  800742:	53                   	push   %ebx
  800743:	8b 75 08             	mov    0x8(%ebp),%esi
  800746:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800749:	89 f3                	mov    %esi,%ebx
  80074b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80074e:	89 f2                	mov    %esi,%edx
  800750:	eb 0f                	jmp    800761 <strncpy+0x23>
		*dst++ = *src;
  800752:	83 c2 01             	add    $0x1,%edx
  800755:	0f b6 01             	movzbl (%ecx),%eax
  800758:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80075b:	80 39 01             	cmpb   $0x1,(%ecx)
  80075e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800761:	39 da                	cmp    %ebx,%edx
  800763:	75 ed                	jne    800752 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800765:	89 f0                	mov    %esi,%eax
  800767:	5b                   	pop    %ebx
  800768:	5e                   	pop    %esi
  800769:	5d                   	pop    %ebp
  80076a:	c3                   	ret    

0080076b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	56                   	push   %esi
  80076f:	53                   	push   %ebx
  800770:	8b 75 08             	mov    0x8(%ebp),%esi
  800773:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800776:	8b 55 10             	mov    0x10(%ebp),%edx
  800779:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80077b:	85 d2                	test   %edx,%edx
  80077d:	74 21                	je     8007a0 <strlcpy+0x35>
  80077f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800783:	89 f2                	mov    %esi,%edx
  800785:	eb 09                	jmp    800790 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800787:	83 c2 01             	add    $0x1,%edx
  80078a:	83 c1 01             	add    $0x1,%ecx
  80078d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800790:	39 c2                	cmp    %eax,%edx
  800792:	74 09                	je     80079d <strlcpy+0x32>
  800794:	0f b6 19             	movzbl (%ecx),%ebx
  800797:	84 db                	test   %bl,%bl
  800799:	75 ec                	jne    800787 <strlcpy+0x1c>
  80079b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80079d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007a0:	29 f0                	sub    %esi,%eax
}
  8007a2:	5b                   	pop    %ebx
  8007a3:	5e                   	pop    %esi
  8007a4:	5d                   	pop    %ebp
  8007a5:	c3                   	ret    

008007a6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ac:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007af:	eb 06                	jmp    8007b7 <strcmp+0x11>
		p++, q++;
  8007b1:	83 c1 01             	add    $0x1,%ecx
  8007b4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007b7:	0f b6 01             	movzbl (%ecx),%eax
  8007ba:	84 c0                	test   %al,%al
  8007bc:	74 04                	je     8007c2 <strcmp+0x1c>
  8007be:	3a 02                	cmp    (%edx),%al
  8007c0:	74 ef                	je     8007b1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007c2:	0f b6 c0             	movzbl %al,%eax
  8007c5:	0f b6 12             	movzbl (%edx),%edx
  8007c8:	29 d0                	sub    %edx,%eax
}
  8007ca:	5d                   	pop    %ebp
  8007cb:	c3                   	ret    

008007cc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	53                   	push   %ebx
  8007d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d6:	89 c3                	mov    %eax,%ebx
  8007d8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007db:	eb 06                	jmp    8007e3 <strncmp+0x17>
		n--, p++, q++;
  8007dd:	83 c0 01             	add    $0x1,%eax
  8007e0:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007e3:	39 d8                	cmp    %ebx,%eax
  8007e5:	74 15                	je     8007fc <strncmp+0x30>
  8007e7:	0f b6 08             	movzbl (%eax),%ecx
  8007ea:	84 c9                	test   %cl,%cl
  8007ec:	74 04                	je     8007f2 <strncmp+0x26>
  8007ee:	3a 0a                	cmp    (%edx),%cl
  8007f0:	74 eb                	je     8007dd <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f2:	0f b6 00             	movzbl (%eax),%eax
  8007f5:	0f b6 12             	movzbl (%edx),%edx
  8007f8:	29 d0                	sub    %edx,%eax
  8007fa:	eb 05                	jmp    800801 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007fc:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800801:	5b                   	pop    %ebx
  800802:	5d                   	pop    %ebp
  800803:	c3                   	ret    

00800804 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800804:	55                   	push   %ebp
  800805:	89 e5                	mov    %esp,%ebp
  800807:	8b 45 08             	mov    0x8(%ebp),%eax
  80080a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80080e:	eb 07                	jmp    800817 <strchr+0x13>
		if (*s == c)
  800810:	38 ca                	cmp    %cl,%dl
  800812:	74 0f                	je     800823 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800814:	83 c0 01             	add    $0x1,%eax
  800817:	0f b6 10             	movzbl (%eax),%edx
  80081a:	84 d2                	test   %dl,%dl
  80081c:	75 f2                	jne    800810 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80081e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800823:	5d                   	pop    %ebp
  800824:	c3                   	ret    

00800825 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	8b 45 08             	mov    0x8(%ebp),%eax
  80082b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80082f:	eb 03                	jmp    800834 <strfind+0xf>
  800831:	83 c0 01             	add    $0x1,%eax
  800834:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800837:	38 ca                	cmp    %cl,%dl
  800839:	74 04                	je     80083f <strfind+0x1a>
  80083b:	84 d2                	test   %dl,%dl
  80083d:	75 f2                	jne    800831 <strfind+0xc>
			break;
	return (char *) s;
}
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    

00800841 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	57                   	push   %edi
  800845:	56                   	push   %esi
  800846:	53                   	push   %ebx
  800847:	8b 7d 08             	mov    0x8(%ebp),%edi
  80084a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80084d:	85 c9                	test   %ecx,%ecx
  80084f:	74 36                	je     800887 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800851:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800857:	75 28                	jne    800881 <memset+0x40>
  800859:	f6 c1 03             	test   $0x3,%cl
  80085c:	75 23                	jne    800881 <memset+0x40>
		c &= 0xFF;
  80085e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800862:	89 d3                	mov    %edx,%ebx
  800864:	c1 e3 08             	shl    $0x8,%ebx
  800867:	89 d6                	mov    %edx,%esi
  800869:	c1 e6 18             	shl    $0x18,%esi
  80086c:	89 d0                	mov    %edx,%eax
  80086e:	c1 e0 10             	shl    $0x10,%eax
  800871:	09 f0                	or     %esi,%eax
  800873:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800875:	89 d8                	mov    %ebx,%eax
  800877:	09 d0                	or     %edx,%eax
  800879:	c1 e9 02             	shr    $0x2,%ecx
  80087c:	fc                   	cld    
  80087d:	f3 ab                	rep stos %eax,%es:(%edi)
  80087f:	eb 06                	jmp    800887 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800881:	8b 45 0c             	mov    0xc(%ebp),%eax
  800884:	fc                   	cld    
  800885:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800887:	89 f8                	mov    %edi,%eax
  800889:	5b                   	pop    %ebx
  80088a:	5e                   	pop    %esi
  80088b:	5f                   	pop    %edi
  80088c:	5d                   	pop    %ebp
  80088d:	c3                   	ret    

0080088e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	57                   	push   %edi
  800892:	56                   	push   %esi
  800893:	8b 45 08             	mov    0x8(%ebp),%eax
  800896:	8b 75 0c             	mov    0xc(%ebp),%esi
  800899:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80089c:	39 c6                	cmp    %eax,%esi
  80089e:	73 35                	jae    8008d5 <memmove+0x47>
  8008a0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008a3:	39 d0                	cmp    %edx,%eax
  8008a5:	73 2e                	jae    8008d5 <memmove+0x47>
		s += n;
		d += n;
  8008a7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008aa:	89 d6                	mov    %edx,%esi
  8008ac:	09 fe                	or     %edi,%esi
  8008ae:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008b4:	75 13                	jne    8008c9 <memmove+0x3b>
  8008b6:	f6 c1 03             	test   $0x3,%cl
  8008b9:	75 0e                	jne    8008c9 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008bb:	83 ef 04             	sub    $0x4,%edi
  8008be:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008c1:	c1 e9 02             	shr    $0x2,%ecx
  8008c4:	fd                   	std    
  8008c5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c7:	eb 09                	jmp    8008d2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008c9:	83 ef 01             	sub    $0x1,%edi
  8008cc:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008cf:	fd                   	std    
  8008d0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008d2:	fc                   	cld    
  8008d3:	eb 1d                	jmp    8008f2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d5:	89 f2                	mov    %esi,%edx
  8008d7:	09 c2                	or     %eax,%edx
  8008d9:	f6 c2 03             	test   $0x3,%dl
  8008dc:	75 0f                	jne    8008ed <memmove+0x5f>
  8008de:	f6 c1 03             	test   $0x3,%cl
  8008e1:	75 0a                	jne    8008ed <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008e3:	c1 e9 02             	shr    $0x2,%ecx
  8008e6:	89 c7                	mov    %eax,%edi
  8008e8:	fc                   	cld    
  8008e9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008eb:	eb 05                	jmp    8008f2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008ed:	89 c7                	mov    %eax,%edi
  8008ef:	fc                   	cld    
  8008f0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008f2:	5e                   	pop    %esi
  8008f3:	5f                   	pop    %edi
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008f9:	ff 75 10             	pushl  0x10(%ebp)
  8008fc:	ff 75 0c             	pushl  0xc(%ebp)
  8008ff:	ff 75 08             	pushl  0x8(%ebp)
  800902:	e8 87 ff ff ff       	call   80088e <memmove>
}
  800907:	c9                   	leave  
  800908:	c3                   	ret    

00800909 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	56                   	push   %esi
  80090d:	53                   	push   %ebx
  80090e:	8b 45 08             	mov    0x8(%ebp),%eax
  800911:	8b 55 0c             	mov    0xc(%ebp),%edx
  800914:	89 c6                	mov    %eax,%esi
  800916:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800919:	eb 1a                	jmp    800935 <memcmp+0x2c>
		if (*s1 != *s2)
  80091b:	0f b6 08             	movzbl (%eax),%ecx
  80091e:	0f b6 1a             	movzbl (%edx),%ebx
  800921:	38 d9                	cmp    %bl,%cl
  800923:	74 0a                	je     80092f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800925:	0f b6 c1             	movzbl %cl,%eax
  800928:	0f b6 db             	movzbl %bl,%ebx
  80092b:	29 d8                	sub    %ebx,%eax
  80092d:	eb 0f                	jmp    80093e <memcmp+0x35>
		s1++, s2++;
  80092f:	83 c0 01             	add    $0x1,%eax
  800932:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800935:	39 f0                	cmp    %esi,%eax
  800937:	75 e2                	jne    80091b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800939:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093e:	5b                   	pop    %ebx
  80093f:	5e                   	pop    %esi
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	53                   	push   %ebx
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800949:	89 c1                	mov    %eax,%ecx
  80094b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80094e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800952:	eb 0a                	jmp    80095e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800954:	0f b6 10             	movzbl (%eax),%edx
  800957:	39 da                	cmp    %ebx,%edx
  800959:	74 07                	je     800962 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80095b:	83 c0 01             	add    $0x1,%eax
  80095e:	39 c8                	cmp    %ecx,%eax
  800960:	72 f2                	jb     800954 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800962:	5b                   	pop    %ebx
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	57                   	push   %edi
  800969:	56                   	push   %esi
  80096a:	53                   	push   %ebx
  80096b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80096e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800971:	eb 03                	jmp    800976 <strtol+0x11>
		s++;
  800973:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800976:	0f b6 01             	movzbl (%ecx),%eax
  800979:	3c 20                	cmp    $0x20,%al
  80097b:	74 f6                	je     800973 <strtol+0xe>
  80097d:	3c 09                	cmp    $0x9,%al
  80097f:	74 f2                	je     800973 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800981:	3c 2b                	cmp    $0x2b,%al
  800983:	75 0a                	jne    80098f <strtol+0x2a>
		s++;
  800985:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800988:	bf 00 00 00 00       	mov    $0x0,%edi
  80098d:	eb 11                	jmp    8009a0 <strtol+0x3b>
  80098f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800994:	3c 2d                	cmp    $0x2d,%al
  800996:	75 08                	jne    8009a0 <strtol+0x3b>
		s++, neg = 1;
  800998:	83 c1 01             	add    $0x1,%ecx
  80099b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009a0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009a6:	75 15                	jne    8009bd <strtol+0x58>
  8009a8:	80 39 30             	cmpb   $0x30,(%ecx)
  8009ab:	75 10                	jne    8009bd <strtol+0x58>
  8009ad:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009b1:	75 7c                	jne    800a2f <strtol+0xca>
		s += 2, base = 16;
  8009b3:	83 c1 02             	add    $0x2,%ecx
  8009b6:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009bb:	eb 16                	jmp    8009d3 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009bd:	85 db                	test   %ebx,%ebx
  8009bf:	75 12                	jne    8009d3 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009c1:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009c6:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c9:	75 08                	jne    8009d3 <strtol+0x6e>
		s++, base = 8;
  8009cb:	83 c1 01             	add    $0x1,%ecx
  8009ce:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009db:	0f b6 11             	movzbl (%ecx),%edx
  8009de:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009e1:	89 f3                	mov    %esi,%ebx
  8009e3:	80 fb 09             	cmp    $0x9,%bl
  8009e6:	77 08                	ja     8009f0 <strtol+0x8b>
			dig = *s - '0';
  8009e8:	0f be d2             	movsbl %dl,%edx
  8009eb:	83 ea 30             	sub    $0x30,%edx
  8009ee:	eb 22                	jmp    800a12 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009f0:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009f3:	89 f3                	mov    %esi,%ebx
  8009f5:	80 fb 19             	cmp    $0x19,%bl
  8009f8:	77 08                	ja     800a02 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009fa:	0f be d2             	movsbl %dl,%edx
  8009fd:	83 ea 57             	sub    $0x57,%edx
  800a00:	eb 10                	jmp    800a12 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a02:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a05:	89 f3                	mov    %esi,%ebx
  800a07:	80 fb 19             	cmp    $0x19,%bl
  800a0a:	77 16                	ja     800a22 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a0c:	0f be d2             	movsbl %dl,%edx
  800a0f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a12:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a15:	7d 0b                	jge    800a22 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a17:	83 c1 01             	add    $0x1,%ecx
  800a1a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a1e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a20:	eb b9                	jmp    8009db <strtol+0x76>

	if (endptr)
  800a22:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a26:	74 0d                	je     800a35 <strtol+0xd0>
		*endptr = (char *) s;
  800a28:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a2b:	89 0e                	mov    %ecx,(%esi)
  800a2d:	eb 06                	jmp    800a35 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a2f:	85 db                	test   %ebx,%ebx
  800a31:	74 98                	je     8009cb <strtol+0x66>
  800a33:	eb 9e                	jmp    8009d3 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a35:	89 c2                	mov    %eax,%edx
  800a37:	f7 da                	neg    %edx
  800a39:	85 ff                	test   %edi,%edi
  800a3b:	0f 45 c2             	cmovne %edx,%eax
}
  800a3e:	5b                   	pop    %ebx
  800a3f:	5e                   	pop    %esi
  800a40:	5f                   	pop    %edi
  800a41:	5d                   	pop    %ebp
  800a42:	c3                   	ret    

00800a43 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	57                   	push   %edi
  800a47:	56                   	push   %esi
  800a48:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a49:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a51:	8b 55 08             	mov    0x8(%ebp),%edx
  800a54:	89 c3                	mov    %eax,%ebx
  800a56:	89 c7                	mov    %eax,%edi
  800a58:	89 c6                	mov    %eax,%esi
  800a5a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a5c:	5b                   	pop    %ebx
  800a5d:	5e                   	pop    %esi
  800a5e:	5f                   	pop    %edi
  800a5f:	5d                   	pop    %ebp
  800a60:	c3                   	ret    

00800a61 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	57                   	push   %edi
  800a65:	56                   	push   %esi
  800a66:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a67:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6c:	b8 01 00 00 00       	mov    $0x1,%eax
  800a71:	89 d1                	mov    %edx,%ecx
  800a73:	89 d3                	mov    %edx,%ebx
  800a75:	89 d7                	mov    %edx,%edi
  800a77:	89 d6                	mov    %edx,%esi
  800a79:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a7b:	5b                   	pop    %ebx
  800a7c:	5e                   	pop    %esi
  800a7d:	5f                   	pop    %edi
  800a7e:	5d                   	pop    %ebp
  800a7f:	c3                   	ret    

00800a80 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	57                   	push   %edi
  800a84:	56                   	push   %esi
  800a85:	53                   	push   %ebx
  800a86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a89:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a8e:	b8 03 00 00 00       	mov    $0x3,%eax
  800a93:	8b 55 08             	mov    0x8(%ebp),%edx
  800a96:	89 cb                	mov    %ecx,%ebx
  800a98:	89 cf                	mov    %ecx,%edi
  800a9a:	89 ce                	mov    %ecx,%esi
  800a9c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a9e:	85 c0                	test   %eax,%eax
  800aa0:	7e 17                	jle    800ab9 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aa2:	83 ec 0c             	sub    $0xc,%esp
  800aa5:	50                   	push   %eax
  800aa6:	6a 03                	push   $0x3
  800aa8:	68 ff 24 80 00       	push   $0x8024ff
  800aad:	6a 23                	push   $0x23
  800aaf:	68 1c 25 80 00       	push   $0x80251c
  800ab4:	e8 53 12 00 00       	call   801d0c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ab9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800abc:	5b                   	pop    %ebx
  800abd:	5e                   	pop    %esi
  800abe:	5f                   	pop    %edi
  800abf:	5d                   	pop    %ebp
  800ac0:	c3                   	ret    

00800ac1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	57                   	push   %edi
  800ac5:	56                   	push   %esi
  800ac6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac7:	ba 00 00 00 00       	mov    $0x0,%edx
  800acc:	b8 02 00 00 00       	mov    $0x2,%eax
  800ad1:	89 d1                	mov    %edx,%ecx
  800ad3:	89 d3                	mov    %edx,%ebx
  800ad5:	89 d7                	mov    %edx,%edi
  800ad7:	89 d6                	mov    %edx,%esi
  800ad9:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800adb:	5b                   	pop    %ebx
  800adc:	5e                   	pop    %esi
  800add:	5f                   	pop    %edi
  800ade:	5d                   	pop    %ebp
  800adf:	c3                   	ret    

00800ae0 <sys_yield>:

void
sys_yield(void)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	57                   	push   %edi
  800ae4:	56                   	push   %esi
  800ae5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae6:	ba 00 00 00 00       	mov    $0x0,%edx
  800aeb:	b8 0b 00 00 00       	mov    $0xb,%eax
  800af0:	89 d1                	mov    %edx,%ecx
  800af2:	89 d3                	mov    %edx,%ebx
  800af4:	89 d7                	mov    %edx,%edi
  800af6:	89 d6                	mov    %edx,%esi
  800af8:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800afa:	5b                   	pop    %ebx
  800afb:	5e                   	pop    %esi
  800afc:	5f                   	pop    %edi
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    

00800aff <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	57                   	push   %edi
  800b03:	56                   	push   %esi
  800b04:	53                   	push   %ebx
  800b05:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b08:	be 00 00 00 00       	mov    $0x0,%esi
  800b0d:	b8 04 00 00 00       	mov    $0x4,%eax
  800b12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b15:	8b 55 08             	mov    0x8(%ebp),%edx
  800b18:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b1b:	89 f7                	mov    %esi,%edi
  800b1d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b1f:	85 c0                	test   %eax,%eax
  800b21:	7e 17                	jle    800b3a <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b23:	83 ec 0c             	sub    $0xc,%esp
  800b26:	50                   	push   %eax
  800b27:	6a 04                	push   $0x4
  800b29:	68 ff 24 80 00       	push   $0x8024ff
  800b2e:	6a 23                	push   $0x23
  800b30:	68 1c 25 80 00       	push   $0x80251c
  800b35:	e8 d2 11 00 00       	call   801d0c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b3d:	5b                   	pop    %ebx
  800b3e:	5e                   	pop    %esi
  800b3f:	5f                   	pop    %edi
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	57                   	push   %edi
  800b46:	56                   	push   %esi
  800b47:	53                   	push   %ebx
  800b48:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4b:	b8 05 00 00 00       	mov    $0x5,%eax
  800b50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b53:	8b 55 08             	mov    0x8(%ebp),%edx
  800b56:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b59:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b5c:	8b 75 18             	mov    0x18(%ebp),%esi
  800b5f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b61:	85 c0                	test   %eax,%eax
  800b63:	7e 17                	jle    800b7c <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b65:	83 ec 0c             	sub    $0xc,%esp
  800b68:	50                   	push   %eax
  800b69:	6a 05                	push   $0x5
  800b6b:	68 ff 24 80 00       	push   $0x8024ff
  800b70:	6a 23                	push   $0x23
  800b72:	68 1c 25 80 00       	push   $0x80251c
  800b77:	e8 90 11 00 00       	call   801d0c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7f:	5b                   	pop    %ebx
  800b80:	5e                   	pop    %esi
  800b81:	5f                   	pop    %edi
  800b82:	5d                   	pop    %ebp
  800b83:	c3                   	ret    

00800b84 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	57                   	push   %edi
  800b88:	56                   	push   %esi
  800b89:	53                   	push   %ebx
  800b8a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b92:	b8 06 00 00 00       	mov    $0x6,%eax
  800b97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9d:	89 df                	mov    %ebx,%edi
  800b9f:	89 de                	mov    %ebx,%esi
  800ba1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba3:	85 c0                	test   %eax,%eax
  800ba5:	7e 17                	jle    800bbe <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba7:	83 ec 0c             	sub    $0xc,%esp
  800baa:	50                   	push   %eax
  800bab:	6a 06                	push   $0x6
  800bad:	68 ff 24 80 00       	push   $0x8024ff
  800bb2:	6a 23                	push   $0x23
  800bb4:	68 1c 25 80 00       	push   $0x80251c
  800bb9:	e8 4e 11 00 00       	call   801d0c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc1:	5b                   	pop    %ebx
  800bc2:	5e                   	pop    %esi
  800bc3:	5f                   	pop    %edi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	57                   	push   %edi
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
  800bcc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd4:	b8 08 00 00 00       	mov    $0x8,%eax
  800bd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdf:	89 df                	mov    %ebx,%edi
  800be1:	89 de                	mov    %ebx,%esi
  800be3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be5:	85 c0                	test   %eax,%eax
  800be7:	7e 17                	jle    800c00 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be9:	83 ec 0c             	sub    $0xc,%esp
  800bec:	50                   	push   %eax
  800bed:	6a 08                	push   $0x8
  800bef:	68 ff 24 80 00       	push   $0x8024ff
  800bf4:	6a 23                	push   $0x23
  800bf6:	68 1c 25 80 00       	push   $0x80251c
  800bfb:	e8 0c 11 00 00       	call   801d0c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c03:	5b                   	pop    %ebx
  800c04:	5e                   	pop    %esi
  800c05:	5f                   	pop    %edi
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
  800c0e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c11:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c16:	b8 09 00 00 00       	mov    $0x9,%eax
  800c1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c21:	89 df                	mov    %ebx,%edi
  800c23:	89 de                	mov    %ebx,%esi
  800c25:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c27:	85 c0                	test   %eax,%eax
  800c29:	7e 17                	jle    800c42 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2b:	83 ec 0c             	sub    $0xc,%esp
  800c2e:	50                   	push   %eax
  800c2f:	6a 09                	push   $0x9
  800c31:	68 ff 24 80 00       	push   $0x8024ff
  800c36:	6a 23                	push   $0x23
  800c38:	68 1c 25 80 00       	push   $0x80251c
  800c3d:	e8 ca 10 00 00       	call   801d0c <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	57                   	push   %edi
  800c4e:	56                   	push   %esi
  800c4f:	53                   	push   %ebx
  800c50:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c58:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c60:	8b 55 08             	mov    0x8(%ebp),%edx
  800c63:	89 df                	mov    %ebx,%edi
  800c65:	89 de                	mov    %ebx,%esi
  800c67:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c69:	85 c0                	test   %eax,%eax
  800c6b:	7e 17                	jle    800c84 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6d:	83 ec 0c             	sub    $0xc,%esp
  800c70:	50                   	push   %eax
  800c71:	6a 0a                	push   $0xa
  800c73:	68 ff 24 80 00       	push   $0x8024ff
  800c78:	6a 23                	push   $0x23
  800c7a:	68 1c 25 80 00       	push   $0x80251c
  800c7f:	e8 88 10 00 00       	call   801d0c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    

00800c8c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	57                   	push   %edi
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c92:	be 00 00 00 00       	mov    $0x0,%esi
  800c97:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800caa:	5b                   	pop    %ebx
  800cab:	5e                   	pop    %esi
  800cac:	5f                   	pop    %edi
  800cad:	5d                   	pop    %ebp
  800cae:	c3                   	ret    

00800caf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	57                   	push   %edi
  800cb3:	56                   	push   %esi
  800cb4:	53                   	push   %ebx
  800cb5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cbd:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc5:	89 cb                	mov    %ecx,%ebx
  800cc7:	89 cf                	mov    %ecx,%edi
  800cc9:	89 ce                	mov    %ecx,%esi
  800ccb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ccd:	85 c0                	test   %eax,%eax
  800ccf:	7e 17                	jle    800ce8 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd1:	83 ec 0c             	sub    $0xc,%esp
  800cd4:	50                   	push   %eax
  800cd5:	6a 0d                	push   $0xd
  800cd7:	68 ff 24 80 00       	push   $0x8024ff
  800cdc:	6a 23                	push   $0x23
  800cde:	68 1c 25 80 00       	push   $0x80251c
  800ce3:	e8 24 10 00 00       	call   801d0c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ce8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ceb:	5b                   	pop    %ebx
  800cec:	5e                   	pop    %esi
  800ced:	5f                   	pop    %edi
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    

00800cf0 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	57                   	push   %edi
  800cf4:	56                   	push   %esi
  800cf5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cfb:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d00:	8b 55 08             	mov    0x8(%ebp),%edx
  800d03:	89 cb                	mov    %ecx,%ebx
  800d05:	89 cf                	mov    %ecx,%edi
  800d07:	89 ce                	mov    %ecx,%esi
  800d09:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d0b:	5b                   	pop    %ebx
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    

00800d10 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
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
  800d1b:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d20:	8b 55 08             	mov    0x8(%ebp),%edx
  800d23:	89 cb                	mov    %ecx,%ebx
  800d25:	89 cf                	mov    %ecx,%edi
  800d27:	89 ce                	mov    %ecx,%esi
  800d29:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	53                   	push   %ebx
  800d34:	83 ec 04             	sub    $0x4,%esp
  800d37:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d3a:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800d3c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d40:	74 11                	je     800d53 <pgfault+0x23>
  800d42:	89 d8                	mov    %ebx,%eax
  800d44:	c1 e8 0c             	shr    $0xc,%eax
  800d47:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d4e:	f6 c4 08             	test   $0x8,%ah
  800d51:	75 14                	jne    800d67 <pgfault+0x37>
		panic("faulting access");
  800d53:	83 ec 04             	sub    $0x4,%esp
  800d56:	68 2a 25 80 00       	push   $0x80252a
  800d5b:	6a 1e                	push   $0x1e
  800d5d:	68 3a 25 80 00       	push   $0x80253a
  800d62:	e8 a5 0f 00 00       	call   801d0c <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800d67:	83 ec 04             	sub    $0x4,%esp
  800d6a:	6a 07                	push   $0x7
  800d6c:	68 00 f0 7f 00       	push   $0x7ff000
  800d71:	6a 00                	push   $0x0
  800d73:	e8 87 fd ff ff       	call   800aff <sys_page_alloc>
	if (r < 0) {
  800d78:	83 c4 10             	add    $0x10,%esp
  800d7b:	85 c0                	test   %eax,%eax
  800d7d:	79 12                	jns    800d91 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800d7f:	50                   	push   %eax
  800d80:	68 45 25 80 00       	push   $0x802545
  800d85:	6a 2c                	push   $0x2c
  800d87:	68 3a 25 80 00       	push   $0x80253a
  800d8c:	e8 7b 0f 00 00       	call   801d0c <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800d91:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800d97:	83 ec 04             	sub    $0x4,%esp
  800d9a:	68 00 10 00 00       	push   $0x1000
  800d9f:	53                   	push   %ebx
  800da0:	68 00 f0 7f 00       	push   $0x7ff000
  800da5:	e8 4c fb ff ff       	call   8008f6 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800daa:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800db1:	53                   	push   %ebx
  800db2:	6a 00                	push   $0x0
  800db4:	68 00 f0 7f 00       	push   $0x7ff000
  800db9:	6a 00                	push   $0x0
  800dbb:	e8 82 fd ff ff       	call   800b42 <sys_page_map>
	if (r < 0) {
  800dc0:	83 c4 20             	add    $0x20,%esp
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	79 12                	jns    800dd9 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800dc7:	50                   	push   %eax
  800dc8:	68 45 25 80 00       	push   $0x802545
  800dcd:	6a 33                	push   $0x33
  800dcf:	68 3a 25 80 00       	push   $0x80253a
  800dd4:	e8 33 0f 00 00       	call   801d0c <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800dd9:	83 ec 08             	sub    $0x8,%esp
  800ddc:	68 00 f0 7f 00       	push   $0x7ff000
  800de1:	6a 00                	push   $0x0
  800de3:	e8 9c fd ff ff       	call   800b84 <sys_page_unmap>
	if (r < 0) {
  800de8:	83 c4 10             	add    $0x10,%esp
  800deb:	85 c0                	test   %eax,%eax
  800ded:	79 12                	jns    800e01 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800def:	50                   	push   %eax
  800df0:	68 45 25 80 00       	push   $0x802545
  800df5:	6a 37                	push   $0x37
  800df7:	68 3a 25 80 00       	push   $0x80253a
  800dfc:	e8 0b 0f 00 00       	call   801d0c <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e01:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e04:	c9                   	leave  
  800e05:	c3                   	ret    

00800e06 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	57                   	push   %edi
  800e0a:	56                   	push   %esi
  800e0b:	53                   	push   %ebx
  800e0c:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e0f:	68 30 0d 80 00       	push   $0x800d30
  800e14:	e8 39 0f 00 00       	call   801d52 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e19:	b8 07 00 00 00       	mov    $0x7,%eax
  800e1e:	cd 30                	int    $0x30
  800e20:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800e23:	83 c4 10             	add    $0x10,%esp
  800e26:	85 c0                	test   %eax,%eax
  800e28:	79 17                	jns    800e41 <fork+0x3b>
		panic("fork fault %e");
  800e2a:	83 ec 04             	sub    $0x4,%esp
  800e2d:	68 5e 25 80 00       	push   $0x80255e
  800e32:	68 84 00 00 00       	push   $0x84
  800e37:	68 3a 25 80 00       	push   $0x80253a
  800e3c:	e8 cb 0e 00 00       	call   801d0c <_panic>
  800e41:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800e43:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e47:	75 25                	jne    800e6e <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e49:	e8 73 fc ff ff       	call   800ac1 <sys_getenvid>
  800e4e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e53:	89 c2                	mov    %eax,%edx
  800e55:	c1 e2 07             	shl    $0x7,%edx
  800e58:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800e5f:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800e64:	b8 00 00 00 00       	mov    $0x0,%eax
  800e69:	e9 61 01 00 00       	jmp    800fcf <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800e6e:	83 ec 04             	sub    $0x4,%esp
  800e71:	6a 07                	push   $0x7
  800e73:	68 00 f0 bf ee       	push   $0xeebff000
  800e78:	ff 75 e4             	pushl  -0x1c(%ebp)
  800e7b:	e8 7f fc ff ff       	call   800aff <sys_page_alloc>
  800e80:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800e83:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800e88:	89 d8                	mov    %ebx,%eax
  800e8a:	c1 e8 16             	shr    $0x16,%eax
  800e8d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e94:	a8 01                	test   $0x1,%al
  800e96:	0f 84 fc 00 00 00    	je     800f98 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800e9c:	89 d8                	mov    %ebx,%eax
  800e9e:	c1 e8 0c             	shr    $0xc,%eax
  800ea1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ea8:	f6 c2 01             	test   $0x1,%dl
  800eab:	0f 84 e7 00 00 00    	je     800f98 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800eb1:	89 c6                	mov    %eax,%esi
  800eb3:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800eb6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ebd:	f6 c6 04             	test   $0x4,%dh
  800ec0:	74 39                	je     800efb <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800ec2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ec9:	83 ec 0c             	sub    $0xc,%esp
  800ecc:	25 07 0e 00 00       	and    $0xe07,%eax
  800ed1:	50                   	push   %eax
  800ed2:	56                   	push   %esi
  800ed3:	57                   	push   %edi
  800ed4:	56                   	push   %esi
  800ed5:	6a 00                	push   $0x0
  800ed7:	e8 66 fc ff ff       	call   800b42 <sys_page_map>
		if (r < 0) {
  800edc:	83 c4 20             	add    $0x20,%esp
  800edf:	85 c0                	test   %eax,%eax
  800ee1:	0f 89 b1 00 00 00    	jns    800f98 <fork+0x192>
		    	panic("sys page map fault %e");
  800ee7:	83 ec 04             	sub    $0x4,%esp
  800eea:	68 6c 25 80 00       	push   $0x80256c
  800eef:	6a 54                	push   $0x54
  800ef1:	68 3a 25 80 00       	push   $0x80253a
  800ef6:	e8 11 0e 00 00       	call   801d0c <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800efb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f02:	f6 c2 02             	test   $0x2,%dl
  800f05:	75 0c                	jne    800f13 <fork+0x10d>
  800f07:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f0e:	f6 c4 08             	test   $0x8,%ah
  800f11:	74 5b                	je     800f6e <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f13:	83 ec 0c             	sub    $0xc,%esp
  800f16:	68 05 08 00 00       	push   $0x805
  800f1b:	56                   	push   %esi
  800f1c:	57                   	push   %edi
  800f1d:	56                   	push   %esi
  800f1e:	6a 00                	push   $0x0
  800f20:	e8 1d fc ff ff       	call   800b42 <sys_page_map>
		if (r < 0) {
  800f25:	83 c4 20             	add    $0x20,%esp
  800f28:	85 c0                	test   %eax,%eax
  800f2a:	79 14                	jns    800f40 <fork+0x13a>
		    	panic("sys page map fault %e");
  800f2c:	83 ec 04             	sub    $0x4,%esp
  800f2f:	68 6c 25 80 00       	push   $0x80256c
  800f34:	6a 5b                	push   $0x5b
  800f36:	68 3a 25 80 00       	push   $0x80253a
  800f3b:	e8 cc 0d 00 00       	call   801d0c <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800f40:	83 ec 0c             	sub    $0xc,%esp
  800f43:	68 05 08 00 00       	push   $0x805
  800f48:	56                   	push   %esi
  800f49:	6a 00                	push   $0x0
  800f4b:	56                   	push   %esi
  800f4c:	6a 00                	push   $0x0
  800f4e:	e8 ef fb ff ff       	call   800b42 <sys_page_map>
		if (r < 0) {
  800f53:	83 c4 20             	add    $0x20,%esp
  800f56:	85 c0                	test   %eax,%eax
  800f58:	79 3e                	jns    800f98 <fork+0x192>
		    	panic("sys page map fault %e");
  800f5a:	83 ec 04             	sub    $0x4,%esp
  800f5d:	68 6c 25 80 00       	push   $0x80256c
  800f62:	6a 5f                	push   $0x5f
  800f64:	68 3a 25 80 00       	push   $0x80253a
  800f69:	e8 9e 0d 00 00       	call   801d0c <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800f6e:	83 ec 0c             	sub    $0xc,%esp
  800f71:	6a 05                	push   $0x5
  800f73:	56                   	push   %esi
  800f74:	57                   	push   %edi
  800f75:	56                   	push   %esi
  800f76:	6a 00                	push   $0x0
  800f78:	e8 c5 fb ff ff       	call   800b42 <sys_page_map>
		if (r < 0) {
  800f7d:	83 c4 20             	add    $0x20,%esp
  800f80:	85 c0                	test   %eax,%eax
  800f82:	79 14                	jns    800f98 <fork+0x192>
		    	panic("sys page map fault %e");
  800f84:	83 ec 04             	sub    $0x4,%esp
  800f87:	68 6c 25 80 00       	push   $0x80256c
  800f8c:	6a 64                	push   $0x64
  800f8e:	68 3a 25 80 00       	push   $0x80253a
  800f93:	e8 74 0d 00 00       	call   801d0c <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f98:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f9e:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800fa4:	0f 85 de fe ff ff    	jne    800e88 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800faa:	a1 08 40 80 00       	mov    0x804008,%eax
  800faf:	8b 40 70             	mov    0x70(%eax),%eax
  800fb2:	83 ec 08             	sub    $0x8,%esp
  800fb5:	50                   	push   %eax
  800fb6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800fb9:	57                   	push   %edi
  800fba:	e8 8b fc ff ff       	call   800c4a <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  800fbf:	83 c4 08             	add    $0x8,%esp
  800fc2:	6a 02                	push   $0x2
  800fc4:	57                   	push   %edi
  800fc5:	e8 fc fb ff ff       	call   800bc6 <sys_env_set_status>
	
	return envid;
  800fca:	83 c4 10             	add    $0x10,%esp
  800fcd:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  800fcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fd2:	5b                   	pop    %ebx
  800fd3:	5e                   	pop    %esi
  800fd4:	5f                   	pop    %edi
  800fd5:	5d                   	pop    %ebp
  800fd6:	c3                   	ret    

00800fd7 <sfork>:

envid_t
sfork(void)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
	return 0;
}
  800fda:	b8 00 00 00 00       	mov    $0x0,%eax
  800fdf:	5d                   	pop    %ebp
  800fe0:	c3                   	ret    

00800fe1 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  800fe1:	55                   	push   %ebp
  800fe2:	89 e5                	mov    %esp,%ebp
  800fe4:	56                   	push   %esi
  800fe5:	53                   	push   %ebx
  800fe6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  800fe9:	89 1d 0c 40 80 00    	mov    %ebx,0x80400c
	cprintf("in fork.c thread create. func: %x\n", func);
  800fef:	83 ec 08             	sub    $0x8,%esp
  800ff2:	53                   	push   %ebx
  800ff3:	68 84 25 80 00       	push   $0x802584
  800ff8:	e8 7a f1 ff ff       	call   800177 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  800ffd:	c7 04 24 aa 00 80 00 	movl   $0x8000aa,(%esp)
  801004:	e8 e7 fc ff ff       	call   800cf0 <sys_thread_create>
  801009:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80100b:	83 c4 08             	add    $0x8,%esp
  80100e:	53                   	push   %ebx
  80100f:	68 84 25 80 00       	push   $0x802584
  801014:	e8 5e f1 ff ff       	call   800177 <cprintf>
	return id;
	//return 0;
}
  801019:	89 f0                	mov    %esi,%eax
  80101b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80101e:	5b                   	pop    %ebx
  80101f:	5e                   	pop    %esi
  801020:	5d                   	pop    %ebp
  801021:	c3                   	ret    

00801022 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801022:	55                   	push   %ebp
  801023:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801025:	8b 45 08             	mov    0x8(%ebp),%eax
  801028:	05 00 00 00 30       	add    $0x30000000,%eax
  80102d:	c1 e8 0c             	shr    $0xc,%eax
}
  801030:	5d                   	pop    %ebp
  801031:	c3                   	ret    

00801032 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801032:	55                   	push   %ebp
  801033:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801035:	8b 45 08             	mov    0x8(%ebp),%eax
  801038:	05 00 00 00 30       	add    $0x30000000,%eax
  80103d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801042:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801047:	5d                   	pop    %ebp
  801048:	c3                   	ret    

00801049 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801049:	55                   	push   %ebp
  80104a:	89 e5                	mov    %esp,%ebp
  80104c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80104f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801054:	89 c2                	mov    %eax,%edx
  801056:	c1 ea 16             	shr    $0x16,%edx
  801059:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801060:	f6 c2 01             	test   $0x1,%dl
  801063:	74 11                	je     801076 <fd_alloc+0x2d>
  801065:	89 c2                	mov    %eax,%edx
  801067:	c1 ea 0c             	shr    $0xc,%edx
  80106a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801071:	f6 c2 01             	test   $0x1,%dl
  801074:	75 09                	jne    80107f <fd_alloc+0x36>
			*fd_store = fd;
  801076:	89 01                	mov    %eax,(%ecx)
			return 0;
  801078:	b8 00 00 00 00       	mov    $0x0,%eax
  80107d:	eb 17                	jmp    801096 <fd_alloc+0x4d>
  80107f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801084:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801089:	75 c9                	jne    801054 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80108b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801091:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801096:	5d                   	pop    %ebp
  801097:	c3                   	ret    

00801098 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
  80109b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80109e:	83 f8 1f             	cmp    $0x1f,%eax
  8010a1:	77 36                	ja     8010d9 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010a3:	c1 e0 0c             	shl    $0xc,%eax
  8010a6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010ab:	89 c2                	mov    %eax,%edx
  8010ad:	c1 ea 16             	shr    $0x16,%edx
  8010b0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010b7:	f6 c2 01             	test   $0x1,%dl
  8010ba:	74 24                	je     8010e0 <fd_lookup+0x48>
  8010bc:	89 c2                	mov    %eax,%edx
  8010be:	c1 ea 0c             	shr    $0xc,%edx
  8010c1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010c8:	f6 c2 01             	test   $0x1,%dl
  8010cb:	74 1a                	je     8010e7 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010d0:	89 02                	mov    %eax,(%edx)
	return 0;
  8010d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d7:	eb 13                	jmp    8010ec <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010de:	eb 0c                	jmp    8010ec <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010e0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010e5:	eb 05                	jmp    8010ec <fd_lookup+0x54>
  8010e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010ec:	5d                   	pop    %ebp
  8010ed:	c3                   	ret    

008010ee <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010ee:	55                   	push   %ebp
  8010ef:	89 e5                	mov    %esp,%ebp
  8010f1:	83 ec 08             	sub    $0x8,%esp
  8010f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010f7:	ba 24 26 80 00       	mov    $0x802624,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8010fc:	eb 13                	jmp    801111 <dev_lookup+0x23>
  8010fe:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801101:	39 08                	cmp    %ecx,(%eax)
  801103:	75 0c                	jne    801111 <dev_lookup+0x23>
			*dev = devtab[i];
  801105:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801108:	89 01                	mov    %eax,(%ecx)
			return 0;
  80110a:	b8 00 00 00 00       	mov    $0x0,%eax
  80110f:	eb 2e                	jmp    80113f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801111:	8b 02                	mov    (%edx),%eax
  801113:	85 c0                	test   %eax,%eax
  801115:	75 e7                	jne    8010fe <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801117:	a1 08 40 80 00       	mov    0x804008,%eax
  80111c:	8b 40 54             	mov    0x54(%eax),%eax
  80111f:	83 ec 04             	sub    $0x4,%esp
  801122:	51                   	push   %ecx
  801123:	50                   	push   %eax
  801124:	68 a8 25 80 00       	push   $0x8025a8
  801129:	e8 49 f0 ff ff       	call   800177 <cprintf>
	*dev = 0;
  80112e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801131:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801137:	83 c4 10             	add    $0x10,%esp
  80113a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80113f:	c9                   	leave  
  801140:	c3                   	ret    

00801141 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801141:	55                   	push   %ebp
  801142:	89 e5                	mov    %esp,%ebp
  801144:	56                   	push   %esi
  801145:	53                   	push   %ebx
  801146:	83 ec 10             	sub    $0x10,%esp
  801149:	8b 75 08             	mov    0x8(%ebp),%esi
  80114c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80114f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801152:	50                   	push   %eax
  801153:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801159:	c1 e8 0c             	shr    $0xc,%eax
  80115c:	50                   	push   %eax
  80115d:	e8 36 ff ff ff       	call   801098 <fd_lookup>
  801162:	83 c4 08             	add    $0x8,%esp
  801165:	85 c0                	test   %eax,%eax
  801167:	78 05                	js     80116e <fd_close+0x2d>
	    || fd != fd2)
  801169:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80116c:	74 0c                	je     80117a <fd_close+0x39>
		return (must_exist ? r : 0);
  80116e:	84 db                	test   %bl,%bl
  801170:	ba 00 00 00 00       	mov    $0x0,%edx
  801175:	0f 44 c2             	cmove  %edx,%eax
  801178:	eb 41                	jmp    8011bb <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80117a:	83 ec 08             	sub    $0x8,%esp
  80117d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801180:	50                   	push   %eax
  801181:	ff 36                	pushl  (%esi)
  801183:	e8 66 ff ff ff       	call   8010ee <dev_lookup>
  801188:	89 c3                	mov    %eax,%ebx
  80118a:	83 c4 10             	add    $0x10,%esp
  80118d:	85 c0                	test   %eax,%eax
  80118f:	78 1a                	js     8011ab <fd_close+0x6a>
		if (dev->dev_close)
  801191:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801194:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801197:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80119c:	85 c0                	test   %eax,%eax
  80119e:	74 0b                	je     8011ab <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011a0:	83 ec 0c             	sub    $0xc,%esp
  8011a3:	56                   	push   %esi
  8011a4:	ff d0                	call   *%eax
  8011a6:	89 c3                	mov    %eax,%ebx
  8011a8:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011ab:	83 ec 08             	sub    $0x8,%esp
  8011ae:	56                   	push   %esi
  8011af:	6a 00                	push   $0x0
  8011b1:	e8 ce f9 ff ff       	call   800b84 <sys_page_unmap>
	return r;
  8011b6:	83 c4 10             	add    $0x10,%esp
  8011b9:	89 d8                	mov    %ebx,%eax
}
  8011bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011be:	5b                   	pop    %ebx
  8011bf:	5e                   	pop    %esi
  8011c0:	5d                   	pop    %ebp
  8011c1:	c3                   	ret    

008011c2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011c2:	55                   	push   %ebp
  8011c3:	89 e5                	mov    %esp,%ebp
  8011c5:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011cb:	50                   	push   %eax
  8011cc:	ff 75 08             	pushl  0x8(%ebp)
  8011cf:	e8 c4 fe ff ff       	call   801098 <fd_lookup>
  8011d4:	83 c4 08             	add    $0x8,%esp
  8011d7:	85 c0                	test   %eax,%eax
  8011d9:	78 10                	js     8011eb <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8011db:	83 ec 08             	sub    $0x8,%esp
  8011de:	6a 01                	push   $0x1
  8011e0:	ff 75 f4             	pushl  -0xc(%ebp)
  8011e3:	e8 59 ff ff ff       	call   801141 <fd_close>
  8011e8:	83 c4 10             	add    $0x10,%esp
}
  8011eb:	c9                   	leave  
  8011ec:	c3                   	ret    

008011ed <close_all>:

void
close_all(void)
{
  8011ed:	55                   	push   %ebp
  8011ee:	89 e5                	mov    %esp,%ebp
  8011f0:	53                   	push   %ebx
  8011f1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011f4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011f9:	83 ec 0c             	sub    $0xc,%esp
  8011fc:	53                   	push   %ebx
  8011fd:	e8 c0 ff ff ff       	call   8011c2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801202:	83 c3 01             	add    $0x1,%ebx
  801205:	83 c4 10             	add    $0x10,%esp
  801208:	83 fb 20             	cmp    $0x20,%ebx
  80120b:	75 ec                	jne    8011f9 <close_all+0xc>
		close(i);
}
  80120d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801210:	c9                   	leave  
  801211:	c3                   	ret    

00801212 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801212:	55                   	push   %ebp
  801213:	89 e5                	mov    %esp,%ebp
  801215:	57                   	push   %edi
  801216:	56                   	push   %esi
  801217:	53                   	push   %ebx
  801218:	83 ec 2c             	sub    $0x2c,%esp
  80121b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80121e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801221:	50                   	push   %eax
  801222:	ff 75 08             	pushl  0x8(%ebp)
  801225:	e8 6e fe ff ff       	call   801098 <fd_lookup>
  80122a:	83 c4 08             	add    $0x8,%esp
  80122d:	85 c0                	test   %eax,%eax
  80122f:	0f 88 c1 00 00 00    	js     8012f6 <dup+0xe4>
		return r;
	close(newfdnum);
  801235:	83 ec 0c             	sub    $0xc,%esp
  801238:	56                   	push   %esi
  801239:	e8 84 ff ff ff       	call   8011c2 <close>

	newfd = INDEX2FD(newfdnum);
  80123e:	89 f3                	mov    %esi,%ebx
  801240:	c1 e3 0c             	shl    $0xc,%ebx
  801243:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801249:	83 c4 04             	add    $0x4,%esp
  80124c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80124f:	e8 de fd ff ff       	call   801032 <fd2data>
  801254:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801256:	89 1c 24             	mov    %ebx,(%esp)
  801259:	e8 d4 fd ff ff       	call   801032 <fd2data>
  80125e:	83 c4 10             	add    $0x10,%esp
  801261:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801264:	89 f8                	mov    %edi,%eax
  801266:	c1 e8 16             	shr    $0x16,%eax
  801269:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801270:	a8 01                	test   $0x1,%al
  801272:	74 37                	je     8012ab <dup+0x99>
  801274:	89 f8                	mov    %edi,%eax
  801276:	c1 e8 0c             	shr    $0xc,%eax
  801279:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801280:	f6 c2 01             	test   $0x1,%dl
  801283:	74 26                	je     8012ab <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801285:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80128c:	83 ec 0c             	sub    $0xc,%esp
  80128f:	25 07 0e 00 00       	and    $0xe07,%eax
  801294:	50                   	push   %eax
  801295:	ff 75 d4             	pushl  -0x2c(%ebp)
  801298:	6a 00                	push   $0x0
  80129a:	57                   	push   %edi
  80129b:	6a 00                	push   $0x0
  80129d:	e8 a0 f8 ff ff       	call   800b42 <sys_page_map>
  8012a2:	89 c7                	mov    %eax,%edi
  8012a4:	83 c4 20             	add    $0x20,%esp
  8012a7:	85 c0                	test   %eax,%eax
  8012a9:	78 2e                	js     8012d9 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012ab:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012ae:	89 d0                	mov    %edx,%eax
  8012b0:	c1 e8 0c             	shr    $0xc,%eax
  8012b3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012ba:	83 ec 0c             	sub    $0xc,%esp
  8012bd:	25 07 0e 00 00       	and    $0xe07,%eax
  8012c2:	50                   	push   %eax
  8012c3:	53                   	push   %ebx
  8012c4:	6a 00                	push   $0x0
  8012c6:	52                   	push   %edx
  8012c7:	6a 00                	push   $0x0
  8012c9:	e8 74 f8 ff ff       	call   800b42 <sys_page_map>
  8012ce:	89 c7                	mov    %eax,%edi
  8012d0:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8012d3:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012d5:	85 ff                	test   %edi,%edi
  8012d7:	79 1d                	jns    8012f6 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012d9:	83 ec 08             	sub    $0x8,%esp
  8012dc:	53                   	push   %ebx
  8012dd:	6a 00                	push   $0x0
  8012df:	e8 a0 f8 ff ff       	call   800b84 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012e4:	83 c4 08             	add    $0x8,%esp
  8012e7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012ea:	6a 00                	push   $0x0
  8012ec:	e8 93 f8 ff ff       	call   800b84 <sys_page_unmap>
	return r;
  8012f1:	83 c4 10             	add    $0x10,%esp
  8012f4:	89 f8                	mov    %edi,%eax
}
  8012f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012f9:	5b                   	pop    %ebx
  8012fa:	5e                   	pop    %esi
  8012fb:	5f                   	pop    %edi
  8012fc:	5d                   	pop    %ebp
  8012fd:	c3                   	ret    

008012fe <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012fe:	55                   	push   %ebp
  8012ff:	89 e5                	mov    %esp,%ebp
  801301:	53                   	push   %ebx
  801302:	83 ec 14             	sub    $0x14,%esp
  801305:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801308:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80130b:	50                   	push   %eax
  80130c:	53                   	push   %ebx
  80130d:	e8 86 fd ff ff       	call   801098 <fd_lookup>
  801312:	83 c4 08             	add    $0x8,%esp
  801315:	89 c2                	mov    %eax,%edx
  801317:	85 c0                	test   %eax,%eax
  801319:	78 6d                	js     801388 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80131b:	83 ec 08             	sub    $0x8,%esp
  80131e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801321:	50                   	push   %eax
  801322:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801325:	ff 30                	pushl  (%eax)
  801327:	e8 c2 fd ff ff       	call   8010ee <dev_lookup>
  80132c:	83 c4 10             	add    $0x10,%esp
  80132f:	85 c0                	test   %eax,%eax
  801331:	78 4c                	js     80137f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801333:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801336:	8b 42 08             	mov    0x8(%edx),%eax
  801339:	83 e0 03             	and    $0x3,%eax
  80133c:	83 f8 01             	cmp    $0x1,%eax
  80133f:	75 21                	jne    801362 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801341:	a1 08 40 80 00       	mov    0x804008,%eax
  801346:	8b 40 54             	mov    0x54(%eax),%eax
  801349:	83 ec 04             	sub    $0x4,%esp
  80134c:	53                   	push   %ebx
  80134d:	50                   	push   %eax
  80134e:	68 e9 25 80 00       	push   $0x8025e9
  801353:	e8 1f ee ff ff       	call   800177 <cprintf>
		return -E_INVAL;
  801358:	83 c4 10             	add    $0x10,%esp
  80135b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801360:	eb 26                	jmp    801388 <read+0x8a>
	}
	if (!dev->dev_read)
  801362:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801365:	8b 40 08             	mov    0x8(%eax),%eax
  801368:	85 c0                	test   %eax,%eax
  80136a:	74 17                	je     801383 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80136c:	83 ec 04             	sub    $0x4,%esp
  80136f:	ff 75 10             	pushl  0x10(%ebp)
  801372:	ff 75 0c             	pushl  0xc(%ebp)
  801375:	52                   	push   %edx
  801376:	ff d0                	call   *%eax
  801378:	89 c2                	mov    %eax,%edx
  80137a:	83 c4 10             	add    $0x10,%esp
  80137d:	eb 09                	jmp    801388 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80137f:	89 c2                	mov    %eax,%edx
  801381:	eb 05                	jmp    801388 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801383:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801388:	89 d0                	mov    %edx,%eax
  80138a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80138d:	c9                   	leave  
  80138e:	c3                   	ret    

0080138f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80138f:	55                   	push   %ebp
  801390:	89 e5                	mov    %esp,%ebp
  801392:	57                   	push   %edi
  801393:	56                   	push   %esi
  801394:	53                   	push   %ebx
  801395:	83 ec 0c             	sub    $0xc,%esp
  801398:	8b 7d 08             	mov    0x8(%ebp),%edi
  80139b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80139e:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013a3:	eb 21                	jmp    8013c6 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013a5:	83 ec 04             	sub    $0x4,%esp
  8013a8:	89 f0                	mov    %esi,%eax
  8013aa:	29 d8                	sub    %ebx,%eax
  8013ac:	50                   	push   %eax
  8013ad:	89 d8                	mov    %ebx,%eax
  8013af:	03 45 0c             	add    0xc(%ebp),%eax
  8013b2:	50                   	push   %eax
  8013b3:	57                   	push   %edi
  8013b4:	e8 45 ff ff ff       	call   8012fe <read>
		if (m < 0)
  8013b9:	83 c4 10             	add    $0x10,%esp
  8013bc:	85 c0                	test   %eax,%eax
  8013be:	78 10                	js     8013d0 <readn+0x41>
			return m;
		if (m == 0)
  8013c0:	85 c0                	test   %eax,%eax
  8013c2:	74 0a                	je     8013ce <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013c4:	01 c3                	add    %eax,%ebx
  8013c6:	39 f3                	cmp    %esi,%ebx
  8013c8:	72 db                	jb     8013a5 <readn+0x16>
  8013ca:	89 d8                	mov    %ebx,%eax
  8013cc:	eb 02                	jmp    8013d0 <readn+0x41>
  8013ce:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d3:	5b                   	pop    %ebx
  8013d4:	5e                   	pop    %esi
  8013d5:	5f                   	pop    %edi
  8013d6:	5d                   	pop    %ebp
  8013d7:	c3                   	ret    

008013d8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013d8:	55                   	push   %ebp
  8013d9:	89 e5                	mov    %esp,%ebp
  8013db:	53                   	push   %ebx
  8013dc:	83 ec 14             	sub    $0x14,%esp
  8013df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e5:	50                   	push   %eax
  8013e6:	53                   	push   %ebx
  8013e7:	e8 ac fc ff ff       	call   801098 <fd_lookup>
  8013ec:	83 c4 08             	add    $0x8,%esp
  8013ef:	89 c2                	mov    %eax,%edx
  8013f1:	85 c0                	test   %eax,%eax
  8013f3:	78 68                	js     80145d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f5:	83 ec 08             	sub    $0x8,%esp
  8013f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013fb:	50                   	push   %eax
  8013fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ff:	ff 30                	pushl  (%eax)
  801401:	e8 e8 fc ff ff       	call   8010ee <dev_lookup>
  801406:	83 c4 10             	add    $0x10,%esp
  801409:	85 c0                	test   %eax,%eax
  80140b:	78 47                	js     801454 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80140d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801410:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801414:	75 21                	jne    801437 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801416:	a1 08 40 80 00       	mov    0x804008,%eax
  80141b:	8b 40 54             	mov    0x54(%eax),%eax
  80141e:	83 ec 04             	sub    $0x4,%esp
  801421:	53                   	push   %ebx
  801422:	50                   	push   %eax
  801423:	68 05 26 80 00       	push   $0x802605
  801428:	e8 4a ed ff ff       	call   800177 <cprintf>
		return -E_INVAL;
  80142d:	83 c4 10             	add    $0x10,%esp
  801430:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801435:	eb 26                	jmp    80145d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801437:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80143a:	8b 52 0c             	mov    0xc(%edx),%edx
  80143d:	85 d2                	test   %edx,%edx
  80143f:	74 17                	je     801458 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801441:	83 ec 04             	sub    $0x4,%esp
  801444:	ff 75 10             	pushl  0x10(%ebp)
  801447:	ff 75 0c             	pushl  0xc(%ebp)
  80144a:	50                   	push   %eax
  80144b:	ff d2                	call   *%edx
  80144d:	89 c2                	mov    %eax,%edx
  80144f:	83 c4 10             	add    $0x10,%esp
  801452:	eb 09                	jmp    80145d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801454:	89 c2                	mov    %eax,%edx
  801456:	eb 05                	jmp    80145d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801458:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80145d:	89 d0                	mov    %edx,%eax
  80145f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801462:	c9                   	leave  
  801463:	c3                   	ret    

00801464 <seek>:

int
seek(int fdnum, off_t offset)
{
  801464:	55                   	push   %ebp
  801465:	89 e5                	mov    %esp,%ebp
  801467:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80146a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80146d:	50                   	push   %eax
  80146e:	ff 75 08             	pushl  0x8(%ebp)
  801471:	e8 22 fc ff ff       	call   801098 <fd_lookup>
  801476:	83 c4 08             	add    $0x8,%esp
  801479:	85 c0                	test   %eax,%eax
  80147b:	78 0e                	js     80148b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80147d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801480:	8b 55 0c             	mov    0xc(%ebp),%edx
  801483:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801486:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80148b:	c9                   	leave  
  80148c:	c3                   	ret    

0080148d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80148d:	55                   	push   %ebp
  80148e:	89 e5                	mov    %esp,%ebp
  801490:	53                   	push   %ebx
  801491:	83 ec 14             	sub    $0x14,%esp
  801494:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801497:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80149a:	50                   	push   %eax
  80149b:	53                   	push   %ebx
  80149c:	e8 f7 fb ff ff       	call   801098 <fd_lookup>
  8014a1:	83 c4 08             	add    $0x8,%esp
  8014a4:	89 c2                	mov    %eax,%edx
  8014a6:	85 c0                	test   %eax,%eax
  8014a8:	78 65                	js     80150f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014aa:	83 ec 08             	sub    $0x8,%esp
  8014ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b0:	50                   	push   %eax
  8014b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b4:	ff 30                	pushl  (%eax)
  8014b6:	e8 33 fc ff ff       	call   8010ee <dev_lookup>
  8014bb:	83 c4 10             	add    $0x10,%esp
  8014be:	85 c0                	test   %eax,%eax
  8014c0:	78 44                	js     801506 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014c9:	75 21                	jne    8014ec <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014cb:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014d0:	8b 40 54             	mov    0x54(%eax),%eax
  8014d3:	83 ec 04             	sub    $0x4,%esp
  8014d6:	53                   	push   %ebx
  8014d7:	50                   	push   %eax
  8014d8:	68 c8 25 80 00       	push   $0x8025c8
  8014dd:	e8 95 ec ff ff       	call   800177 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014e2:	83 c4 10             	add    $0x10,%esp
  8014e5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014ea:	eb 23                	jmp    80150f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8014ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014ef:	8b 52 18             	mov    0x18(%edx),%edx
  8014f2:	85 d2                	test   %edx,%edx
  8014f4:	74 14                	je     80150a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014f6:	83 ec 08             	sub    $0x8,%esp
  8014f9:	ff 75 0c             	pushl  0xc(%ebp)
  8014fc:	50                   	push   %eax
  8014fd:	ff d2                	call   *%edx
  8014ff:	89 c2                	mov    %eax,%edx
  801501:	83 c4 10             	add    $0x10,%esp
  801504:	eb 09                	jmp    80150f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801506:	89 c2                	mov    %eax,%edx
  801508:	eb 05                	jmp    80150f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80150a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80150f:	89 d0                	mov    %edx,%eax
  801511:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801514:	c9                   	leave  
  801515:	c3                   	ret    

00801516 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801516:	55                   	push   %ebp
  801517:	89 e5                	mov    %esp,%ebp
  801519:	53                   	push   %ebx
  80151a:	83 ec 14             	sub    $0x14,%esp
  80151d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801520:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801523:	50                   	push   %eax
  801524:	ff 75 08             	pushl  0x8(%ebp)
  801527:	e8 6c fb ff ff       	call   801098 <fd_lookup>
  80152c:	83 c4 08             	add    $0x8,%esp
  80152f:	89 c2                	mov    %eax,%edx
  801531:	85 c0                	test   %eax,%eax
  801533:	78 58                	js     80158d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801535:	83 ec 08             	sub    $0x8,%esp
  801538:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80153b:	50                   	push   %eax
  80153c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153f:	ff 30                	pushl  (%eax)
  801541:	e8 a8 fb ff ff       	call   8010ee <dev_lookup>
  801546:	83 c4 10             	add    $0x10,%esp
  801549:	85 c0                	test   %eax,%eax
  80154b:	78 37                	js     801584 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80154d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801550:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801554:	74 32                	je     801588 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801556:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801559:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801560:	00 00 00 
	stat->st_isdir = 0;
  801563:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80156a:	00 00 00 
	stat->st_dev = dev;
  80156d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801573:	83 ec 08             	sub    $0x8,%esp
  801576:	53                   	push   %ebx
  801577:	ff 75 f0             	pushl  -0x10(%ebp)
  80157a:	ff 50 14             	call   *0x14(%eax)
  80157d:	89 c2                	mov    %eax,%edx
  80157f:	83 c4 10             	add    $0x10,%esp
  801582:	eb 09                	jmp    80158d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801584:	89 c2                	mov    %eax,%edx
  801586:	eb 05                	jmp    80158d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801588:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80158d:	89 d0                	mov    %edx,%eax
  80158f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801592:	c9                   	leave  
  801593:	c3                   	ret    

00801594 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801594:	55                   	push   %ebp
  801595:	89 e5                	mov    %esp,%ebp
  801597:	56                   	push   %esi
  801598:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801599:	83 ec 08             	sub    $0x8,%esp
  80159c:	6a 00                	push   $0x0
  80159e:	ff 75 08             	pushl  0x8(%ebp)
  8015a1:	e8 e3 01 00 00       	call   801789 <open>
  8015a6:	89 c3                	mov    %eax,%ebx
  8015a8:	83 c4 10             	add    $0x10,%esp
  8015ab:	85 c0                	test   %eax,%eax
  8015ad:	78 1b                	js     8015ca <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015af:	83 ec 08             	sub    $0x8,%esp
  8015b2:	ff 75 0c             	pushl  0xc(%ebp)
  8015b5:	50                   	push   %eax
  8015b6:	e8 5b ff ff ff       	call   801516 <fstat>
  8015bb:	89 c6                	mov    %eax,%esi
	close(fd);
  8015bd:	89 1c 24             	mov    %ebx,(%esp)
  8015c0:	e8 fd fb ff ff       	call   8011c2 <close>
	return r;
  8015c5:	83 c4 10             	add    $0x10,%esp
  8015c8:	89 f0                	mov    %esi,%eax
}
  8015ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015cd:	5b                   	pop    %ebx
  8015ce:	5e                   	pop    %esi
  8015cf:	5d                   	pop    %ebp
  8015d0:	c3                   	ret    

008015d1 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015d1:	55                   	push   %ebp
  8015d2:	89 e5                	mov    %esp,%ebp
  8015d4:	56                   	push   %esi
  8015d5:	53                   	push   %ebx
  8015d6:	89 c6                	mov    %eax,%esi
  8015d8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015da:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015e1:	75 12                	jne    8015f5 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015e3:	83 ec 0c             	sub    $0xc,%esp
  8015e6:	6a 01                	push   $0x1
  8015e8:	e8 ce 08 00 00       	call   801ebb <ipc_find_env>
  8015ed:	a3 00 40 80 00       	mov    %eax,0x804000
  8015f2:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015f5:	6a 07                	push   $0x7
  8015f7:	68 00 50 80 00       	push   $0x805000
  8015fc:	56                   	push   %esi
  8015fd:	ff 35 00 40 80 00    	pushl  0x804000
  801603:	e8 51 08 00 00       	call   801e59 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801608:	83 c4 0c             	add    $0xc,%esp
  80160b:	6a 00                	push   $0x0
  80160d:	53                   	push   %ebx
  80160e:	6a 00                	push   $0x0
  801610:	e8 cc 07 00 00       	call   801de1 <ipc_recv>
}
  801615:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801618:	5b                   	pop    %ebx
  801619:	5e                   	pop    %esi
  80161a:	5d                   	pop    %ebp
  80161b:	c3                   	ret    

0080161c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80161c:	55                   	push   %ebp
  80161d:	89 e5                	mov    %esp,%ebp
  80161f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801622:	8b 45 08             	mov    0x8(%ebp),%eax
  801625:	8b 40 0c             	mov    0xc(%eax),%eax
  801628:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80162d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801630:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801635:	ba 00 00 00 00       	mov    $0x0,%edx
  80163a:	b8 02 00 00 00       	mov    $0x2,%eax
  80163f:	e8 8d ff ff ff       	call   8015d1 <fsipc>
}
  801644:	c9                   	leave  
  801645:	c3                   	ret    

00801646 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80164c:	8b 45 08             	mov    0x8(%ebp),%eax
  80164f:	8b 40 0c             	mov    0xc(%eax),%eax
  801652:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801657:	ba 00 00 00 00       	mov    $0x0,%edx
  80165c:	b8 06 00 00 00       	mov    $0x6,%eax
  801661:	e8 6b ff ff ff       	call   8015d1 <fsipc>
}
  801666:	c9                   	leave  
  801667:	c3                   	ret    

00801668 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801668:	55                   	push   %ebp
  801669:	89 e5                	mov    %esp,%ebp
  80166b:	53                   	push   %ebx
  80166c:	83 ec 04             	sub    $0x4,%esp
  80166f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801672:	8b 45 08             	mov    0x8(%ebp),%eax
  801675:	8b 40 0c             	mov    0xc(%eax),%eax
  801678:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80167d:	ba 00 00 00 00       	mov    $0x0,%edx
  801682:	b8 05 00 00 00       	mov    $0x5,%eax
  801687:	e8 45 ff ff ff       	call   8015d1 <fsipc>
  80168c:	85 c0                	test   %eax,%eax
  80168e:	78 2c                	js     8016bc <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801690:	83 ec 08             	sub    $0x8,%esp
  801693:	68 00 50 80 00       	push   $0x805000
  801698:	53                   	push   %ebx
  801699:	e8 5e f0 ff ff       	call   8006fc <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80169e:	a1 80 50 80 00       	mov    0x805080,%eax
  8016a3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016a9:	a1 84 50 80 00       	mov    0x805084,%eax
  8016ae:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016b4:	83 c4 10             	add    $0x10,%esp
  8016b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016bf:	c9                   	leave  
  8016c0:	c3                   	ret    

008016c1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	83 ec 0c             	sub    $0xc,%esp
  8016c7:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8016cd:	8b 52 0c             	mov    0xc(%edx),%edx
  8016d0:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8016d6:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8016db:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8016e0:	0f 47 c2             	cmova  %edx,%eax
  8016e3:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8016e8:	50                   	push   %eax
  8016e9:	ff 75 0c             	pushl  0xc(%ebp)
  8016ec:	68 08 50 80 00       	push   $0x805008
  8016f1:	e8 98 f1 ff ff       	call   80088e <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8016f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8016fb:	b8 04 00 00 00       	mov    $0x4,%eax
  801700:	e8 cc fe ff ff       	call   8015d1 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801705:	c9                   	leave  
  801706:	c3                   	ret    

00801707 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801707:	55                   	push   %ebp
  801708:	89 e5                	mov    %esp,%ebp
  80170a:	56                   	push   %esi
  80170b:	53                   	push   %ebx
  80170c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80170f:	8b 45 08             	mov    0x8(%ebp),%eax
  801712:	8b 40 0c             	mov    0xc(%eax),%eax
  801715:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80171a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801720:	ba 00 00 00 00       	mov    $0x0,%edx
  801725:	b8 03 00 00 00       	mov    $0x3,%eax
  80172a:	e8 a2 fe ff ff       	call   8015d1 <fsipc>
  80172f:	89 c3                	mov    %eax,%ebx
  801731:	85 c0                	test   %eax,%eax
  801733:	78 4b                	js     801780 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801735:	39 c6                	cmp    %eax,%esi
  801737:	73 16                	jae    80174f <devfile_read+0x48>
  801739:	68 34 26 80 00       	push   $0x802634
  80173e:	68 3b 26 80 00       	push   $0x80263b
  801743:	6a 7c                	push   $0x7c
  801745:	68 50 26 80 00       	push   $0x802650
  80174a:	e8 bd 05 00 00       	call   801d0c <_panic>
	assert(r <= PGSIZE);
  80174f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801754:	7e 16                	jle    80176c <devfile_read+0x65>
  801756:	68 5b 26 80 00       	push   $0x80265b
  80175b:	68 3b 26 80 00       	push   $0x80263b
  801760:	6a 7d                	push   $0x7d
  801762:	68 50 26 80 00       	push   $0x802650
  801767:	e8 a0 05 00 00       	call   801d0c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80176c:	83 ec 04             	sub    $0x4,%esp
  80176f:	50                   	push   %eax
  801770:	68 00 50 80 00       	push   $0x805000
  801775:	ff 75 0c             	pushl  0xc(%ebp)
  801778:	e8 11 f1 ff ff       	call   80088e <memmove>
	return r;
  80177d:	83 c4 10             	add    $0x10,%esp
}
  801780:	89 d8                	mov    %ebx,%eax
  801782:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801785:	5b                   	pop    %ebx
  801786:	5e                   	pop    %esi
  801787:	5d                   	pop    %ebp
  801788:	c3                   	ret    

00801789 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801789:	55                   	push   %ebp
  80178a:	89 e5                	mov    %esp,%ebp
  80178c:	53                   	push   %ebx
  80178d:	83 ec 20             	sub    $0x20,%esp
  801790:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801793:	53                   	push   %ebx
  801794:	e8 2a ef ff ff       	call   8006c3 <strlen>
  801799:	83 c4 10             	add    $0x10,%esp
  80179c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017a1:	7f 67                	jg     80180a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017a3:	83 ec 0c             	sub    $0xc,%esp
  8017a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a9:	50                   	push   %eax
  8017aa:	e8 9a f8 ff ff       	call   801049 <fd_alloc>
  8017af:	83 c4 10             	add    $0x10,%esp
		return r;
  8017b2:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017b4:	85 c0                	test   %eax,%eax
  8017b6:	78 57                	js     80180f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017b8:	83 ec 08             	sub    $0x8,%esp
  8017bb:	53                   	push   %ebx
  8017bc:	68 00 50 80 00       	push   $0x805000
  8017c1:	e8 36 ef ff ff       	call   8006fc <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017c9:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8017d6:	e8 f6 fd ff ff       	call   8015d1 <fsipc>
  8017db:	89 c3                	mov    %eax,%ebx
  8017dd:	83 c4 10             	add    $0x10,%esp
  8017e0:	85 c0                	test   %eax,%eax
  8017e2:	79 14                	jns    8017f8 <open+0x6f>
		fd_close(fd, 0);
  8017e4:	83 ec 08             	sub    $0x8,%esp
  8017e7:	6a 00                	push   $0x0
  8017e9:	ff 75 f4             	pushl  -0xc(%ebp)
  8017ec:	e8 50 f9 ff ff       	call   801141 <fd_close>
		return r;
  8017f1:	83 c4 10             	add    $0x10,%esp
  8017f4:	89 da                	mov    %ebx,%edx
  8017f6:	eb 17                	jmp    80180f <open+0x86>
	}

	return fd2num(fd);
  8017f8:	83 ec 0c             	sub    $0xc,%esp
  8017fb:	ff 75 f4             	pushl  -0xc(%ebp)
  8017fe:	e8 1f f8 ff ff       	call   801022 <fd2num>
  801803:	89 c2                	mov    %eax,%edx
  801805:	83 c4 10             	add    $0x10,%esp
  801808:	eb 05                	jmp    80180f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80180a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80180f:	89 d0                	mov    %edx,%eax
  801811:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801814:	c9                   	leave  
  801815:	c3                   	ret    

00801816 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801816:	55                   	push   %ebp
  801817:	89 e5                	mov    %esp,%ebp
  801819:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80181c:	ba 00 00 00 00       	mov    $0x0,%edx
  801821:	b8 08 00 00 00       	mov    $0x8,%eax
  801826:	e8 a6 fd ff ff       	call   8015d1 <fsipc>
}
  80182b:	c9                   	leave  
  80182c:	c3                   	ret    

0080182d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80182d:	55                   	push   %ebp
  80182e:	89 e5                	mov    %esp,%ebp
  801830:	56                   	push   %esi
  801831:	53                   	push   %ebx
  801832:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801835:	83 ec 0c             	sub    $0xc,%esp
  801838:	ff 75 08             	pushl  0x8(%ebp)
  80183b:	e8 f2 f7 ff ff       	call   801032 <fd2data>
  801840:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801842:	83 c4 08             	add    $0x8,%esp
  801845:	68 67 26 80 00       	push   $0x802667
  80184a:	53                   	push   %ebx
  80184b:	e8 ac ee ff ff       	call   8006fc <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801850:	8b 46 04             	mov    0x4(%esi),%eax
  801853:	2b 06                	sub    (%esi),%eax
  801855:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80185b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801862:	00 00 00 
	stat->st_dev = &devpipe;
  801865:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80186c:	30 80 00 
	return 0;
}
  80186f:	b8 00 00 00 00       	mov    $0x0,%eax
  801874:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801877:	5b                   	pop    %ebx
  801878:	5e                   	pop    %esi
  801879:	5d                   	pop    %ebp
  80187a:	c3                   	ret    

0080187b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80187b:	55                   	push   %ebp
  80187c:	89 e5                	mov    %esp,%ebp
  80187e:	53                   	push   %ebx
  80187f:	83 ec 0c             	sub    $0xc,%esp
  801882:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801885:	53                   	push   %ebx
  801886:	6a 00                	push   $0x0
  801888:	e8 f7 f2 ff ff       	call   800b84 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80188d:	89 1c 24             	mov    %ebx,(%esp)
  801890:	e8 9d f7 ff ff       	call   801032 <fd2data>
  801895:	83 c4 08             	add    $0x8,%esp
  801898:	50                   	push   %eax
  801899:	6a 00                	push   $0x0
  80189b:	e8 e4 f2 ff ff       	call   800b84 <sys_page_unmap>
}
  8018a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a3:	c9                   	leave  
  8018a4:	c3                   	ret    

008018a5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018a5:	55                   	push   %ebp
  8018a6:	89 e5                	mov    %esp,%ebp
  8018a8:	57                   	push   %edi
  8018a9:	56                   	push   %esi
  8018aa:	53                   	push   %ebx
  8018ab:	83 ec 1c             	sub    $0x1c,%esp
  8018ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018b1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018b3:	a1 08 40 80 00       	mov    0x804008,%eax
  8018b8:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8018bb:	83 ec 0c             	sub    $0xc,%esp
  8018be:	ff 75 e0             	pushl  -0x20(%ebp)
  8018c1:	e8 35 06 00 00       	call   801efb <pageref>
  8018c6:	89 c3                	mov    %eax,%ebx
  8018c8:	89 3c 24             	mov    %edi,(%esp)
  8018cb:	e8 2b 06 00 00       	call   801efb <pageref>
  8018d0:	83 c4 10             	add    $0x10,%esp
  8018d3:	39 c3                	cmp    %eax,%ebx
  8018d5:	0f 94 c1             	sete   %cl
  8018d8:	0f b6 c9             	movzbl %cl,%ecx
  8018db:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8018de:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8018e4:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  8018e7:	39 ce                	cmp    %ecx,%esi
  8018e9:	74 1b                	je     801906 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8018eb:	39 c3                	cmp    %eax,%ebx
  8018ed:	75 c4                	jne    8018b3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018ef:	8b 42 64             	mov    0x64(%edx),%eax
  8018f2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018f5:	50                   	push   %eax
  8018f6:	56                   	push   %esi
  8018f7:	68 6e 26 80 00       	push   $0x80266e
  8018fc:	e8 76 e8 ff ff       	call   800177 <cprintf>
  801901:	83 c4 10             	add    $0x10,%esp
  801904:	eb ad                	jmp    8018b3 <_pipeisclosed+0xe>
	}
}
  801906:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801909:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80190c:	5b                   	pop    %ebx
  80190d:	5e                   	pop    %esi
  80190e:	5f                   	pop    %edi
  80190f:	5d                   	pop    %ebp
  801910:	c3                   	ret    

00801911 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801911:	55                   	push   %ebp
  801912:	89 e5                	mov    %esp,%ebp
  801914:	57                   	push   %edi
  801915:	56                   	push   %esi
  801916:	53                   	push   %ebx
  801917:	83 ec 28             	sub    $0x28,%esp
  80191a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80191d:	56                   	push   %esi
  80191e:	e8 0f f7 ff ff       	call   801032 <fd2data>
  801923:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801925:	83 c4 10             	add    $0x10,%esp
  801928:	bf 00 00 00 00       	mov    $0x0,%edi
  80192d:	eb 4b                	jmp    80197a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80192f:	89 da                	mov    %ebx,%edx
  801931:	89 f0                	mov    %esi,%eax
  801933:	e8 6d ff ff ff       	call   8018a5 <_pipeisclosed>
  801938:	85 c0                	test   %eax,%eax
  80193a:	75 48                	jne    801984 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80193c:	e8 9f f1 ff ff       	call   800ae0 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801941:	8b 43 04             	mov    0x4(%ebx),%eax
  801944:	8b 0b                	mov    (%ebx),%ecx
  801946:	8d 51 20             	lea    0x20(%ecx),%edx
  801949:	39 d0                	cmp    %edx,%eax
  80194b:	73 e2                	jae    80192f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80194d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801950:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801954:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801957:	89 c2                	mov    %eax,%edx
  801959:	c1 fa 1f             	sar    $0x1f,%edx
  80195c:	89 d1                	mov    %edx,%ecx
  80195e:	c1 e9 1b             	shr    $0x1b,%ecx
  801961:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801964:	83 e2 1f             	and    $0x1f,%edx
  801967:	29 ca                	sub    %ecx,%edx
  801969:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80196d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801971:	83 c0 01             	add    $0x1,%eax
  801974:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801977:	83 c7 01             	add    $0x1,%edi
  80197a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80197d:	75 c2                	jne    801941 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80197f:	8b 45 10             	mov    0x10(%ebp),%eax
  801982:	eb 05                	jmp    801989 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801984:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801989:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80198c:	5b                   	pop    %ebx
  80198d:	5e                   	pop    %esi
  80198e:	5f                   	pop    %edi
  80198f:	5d                   	pop    %ebp
  801990:	c3                   	ret    

00801991 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801991:	55                   	push   %ebp
  801992:	89 e5                	mov    %esp,%ebp
  801994:	57                   	push   %edi
  801995:	56                   	push   %esi
  801996:	53                   	push   %ebx
  801997:	83 ec 18             	sub    $0x18,%esp
  80199a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80199d:	57                   	push   %edi
  80199e:	e8 8f f6 ff ff       	call   801032 <fd2data>
  8019a3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019a5:	83 c4 10             	add    $0x10,%esp
  8019a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019ad:	eb 3d                	jmp    8019ec <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019af:	85 db                	test   %ebx,%ebx
  8019b1:	74 04                	je     8019b7 <devpipe_read+0x26>
				return i;
  8019b3:	89 d8                	mov    %ebx,%eax
  8019b5:	eb 44                	jmp    8019fb <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019b7:	89 f2                	mov    %esi,%edx
  8019b9:	89 f8                	mov    %edi,%eax
  8019bb:	e8 e5 fe ff ff       	call   8018a5 <_pipeisclosed>
  8019c0:	85 c0                	test   %eax,%eax
  8019c2:	75 32                	jne    8019f6 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019c4:	e8 17 f1 ff ff       	call   800ae0 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019c9:	8b 06                	mov    (%esi),%eax
  8019cb:	3b 46 04             	cmp    0x4(%esi),%eax
  8019ce:	74 df                	je     8019af <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019d0:	99                   	cltd   
  8019d1:	c1 ea 1b             	shr    $0x1b,%edx
  8019d4:	01 d0                	add    %edx,%eax
  8019d6:	83 e0 1f             	and    $0x1f,%eax
  8019d9:	29 d0                	sub    %edx,%eax
  8019db:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8019e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019e3:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8019e6:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019e9:	83 c3 01             	add    $0x1,%ebx
  8019ec:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019ef:	75 d8                	jne    8019c9 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019f1:	8b 45 10             	mov    0x10(%ebp),%eax
  8019f4:	eb 05                	jmp    8019fb <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019f6:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8019fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019fe:	5b                   	pop    %ebx
  8019ff:	5e                   	pop    %esi
  801a00:	5f                   	pop    %edi
  801a01:	5d                   	pop    %ebp
  801a02:	c3                   	ret    

00801a03 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a03:	55                   	push   %ebp
  801a04:	89 e5                	mov    %esp,%ebp
  801a06:	56                   	push   %esi
  801a07:	53                   	push   %ebx
  801a08:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a0b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a0e:	50                   	push   %eax
  801a0f:	e8 35 f6 ff ff       	call   801049 <fd_alloc>
  801a14:	83 c4 10             	add    $0x10,%esp
  801a17:	89 c2                	mov    %eax,%edx
  801a19:	85 c0                	test   %eax,%eax
  801a1b:	0f 88 2c 01 00 00    	js     801b4d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a21:	83 ec 04             	sub    $0x4,%esp
  801a24:	68 07 04 00 00       	push   $0x407
  801a29:	ff 75 f4             	pushl  -0xc(%ebp)
  801a2c:	6a 00                	push   $0x0
  801a2e:	e8 cc f0 ff ff       	call   800aff <sys_page_alloc>
  801a33:	83 c4 10             	add    $0x10,%esp
  801a36:	89 c2                	mov    %eax,%edx
  801a38:	85 c0                	test   %eax,%eax
  801a3a:	0f 88 0d 01 00 00    	js     801b4d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a40:	83 ec 0c             	sub    $0xc,%esp
  801a43:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a46:	50                   	push   %eax
  801a47:	e8 fd f5 ff ff       	call   801049 <fd_alloc>
  801a4c:	89 c3                	mov    %eax,%ebx
  801a4e:	83 c4 10             	add    $0x10,%esp
  801a51:	85 c0                	test   %eax,%eax
  801a53:	0f 88 e2 00 00 00    	js     801b3b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a59:	83 ec 04             	sub    $0x4,%esp
  801a5c:	68 07 04 00 00       	push   $0x407
  801a61:	ff 75 f0             	pushl  -0x10(%ebp)
  801a64:	6a 00                	push   $0x0
  801a66:	e8 94 f0 ff ff       	call   800aff <sys_page_alloc>
  801a6b:	89 c3                	mov    %eax,%ebx
  801a6d:	83 c4 10             	add    $0x10,%esp
  801a70:	85 c0                	test   %eax,%eax
  801a72:	0f 88 c3 00 00 00    	js     801b3b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a78:	83 ec 0c             	sub    $0xc,%esp
  801a7b:	ff 75 f4             	pushl  -0xc(%ebp)
  801a7e:	e8 af f5 ff ff       	call   801032 <fd2data>
  801a83:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a85:	83 c4 0c             	add    $0xc,%esp
  801a88:	68 07 04 00 00       	push   $0x407
  801a8d:	50                   	push   %eax
  801a8e:	6a 00                	push   $0x0
  801a90:	e8 6a f0 ff ff       	call   800aff <sys_page_alloc>
  801a95:	89 c3                	mov    %eax,%ebx
  801a97:	83 c4 10             	add    $0x10,%esp
  801a9a:	85 c0                	test   %eax,%eax
  801a9c:	0f 88 89 00 00 00    	js     801b2b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aa2:	83 ec 0c             	sub    $0xc,%esp
  801aa5:	ff 75 f0             	pushl  -0x10(%ebp)
  801aa8:	e8 85 f5 ff ff       	call   801032 <fd2data>
  801aad:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ab4:	50                   	push   %eax
  801ab5:	6a 00                	push   $0x0
  801ab7:	56                   	push   %esi
  801ab8:	6a 00                	push   $0x0
  801aba:	e8 83 f0 ff ff       	call   800b42 <sys_page_map>
  801abf:	89 c3                	mov    %eax,%ebx
  801ac1:	83 c4 20             	add    $0x20,%esp
  801ac4:	85 c0                	test   %eax,%eax
  801ac6:	78 55                	js     801b1d <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ac8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801add:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ae3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ae6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ae8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aeb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801af2:	83 ec 0c             	sub    $0xc,%esp
  801af5:	ff 75 f4             	pushl  -0xc(%ebp)
  801af8:	e8 25 f5 ff ff       	call   801022 <fd2num>
  801afd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b00:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b02:	83 c4 04             	add    $0x4,%esp
  801b05:	ff 75 f0             	pushl  -0x10(%ebp)
  801b08:	e8 15 f5 ff ff       	call   801022 <fd2num>
  801b0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b10:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801b13:	83 c4 10             	add    $0x10,%esp
  801b16:	ba 00 00 00 00       	mov    $0x0,%edx
  801b1b:	eb 30                	jmp    801b4d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b1d:	83 ec 08             	sub    $0x8,%esp
  801b20:	56                   	push   %esi
  801b21:	6a 00                	push   $0x0
  801b23:	e8 5c f0 ff ff       	call   800b84 <sys_page_unmap>
  801b28:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b2b:	83 ec 08             	sub    $0x8,%esp
  801b2e:	ff 75 f0             	pushl  -0x10(%ebp)
  801b31:	6a 00                	push   $0x0
  801b33:	e8 4c f0 ff ff       	call   800b84 <sys_page_unmap>
  801b38:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b3b:	83 ec 08             	sub    $0x8,%esp
  801b3e:	ff 75 f4             	pushl  -0xc(%ebp)
  801b41:	6a 00                	push   $0x0
  801b43:	e8 3c f0 ff ff       	call   800b84 <sys_page_unmap>
  801b48:	83 c4 10             	add    $0x10,%esp
  801b4b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b4d:	89 d0                	mov    %edx,%eax
  801b4f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b52:	5b                   	pop    %ebx
  801b53:	5e                   	pop    %esi
  801b54:	5d                   	pop    %ebp
  801b55:	c3                   	ret    

00801b56 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b56:	55                   	push   %ebp
  801b57:	89 e5                	mov    %esp,%ebp
  801b59:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b5f:	50                   	push   %eax
  801b60:	ff 75 08             	pushl  0x8(%ebp)
  801b63:	e8 30 f5 ff ff       	call   801098 <fd_lookup>
  801b68:	83 c4 10             	add    $0x10,%esp
  801b6b:	85 c0                	test   %eax,%eax
  801b6d:	78 18                	js     801b87 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b6f:	83 ec 0c             	sub    $0xc,%esp
  801b72:	ff 75 f4             	pushl  -0xc(%ebp)
  801b75:	e8 b8 f4 ff ff       	call   801032 <fd2data>
	return _pipeisclosed(fd, p);
  801b7a:	89 c2                	mov    %eax,%edx
  801b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b7f:	e8 21 fd ff ff       	call   8018a5 <_pipeisclosed>
  801b84:	83 c4 10             	add    $0x10,%esp
}
  801b87:	c9                   	leave  
  801b88:	c3                   	ret    

00801b89 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b89:	55                   	push   %ebp
  801b8a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b8c:	b8 00 00 00 00       	mov    $0x0,%eax
  801b91:	5d                   	pop    %ebp
  801b92:	c3                   	ret    

00801b93 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b93:	55                   	push   %ebp
  801b94:	89 e5                	mov    %esp,%ebp
  801b96:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b99:	68 86 26 80 00       	push   $0x802686
  801b9e:	ff 75 0c             	pushl  0xc(%ebp)
  801ba1:	e8 56 eb ff ff       	call   8006fc <strcpy>
	return 0;
}
  801ba6:	b8 00 00 00 00       	mov    $0x0,%eax
  801bab:	c9                   	leave  
  801bac:	c3                   	ret    

00801bad <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bad:	55                   	push   %ebp
  801bae:	89 e5                	mov    %esp,%ebp
  801bb0:	57                   	push   %edi
  801bb1:	56                   	push   %esi
  801bb2:	53                   	push   %ebx
  801bb3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bb9:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bbe:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bc4:	eb 2d                	jmp    801bf3 <devcons_write+0x46>
		m = n - tot;
  801bc6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801bc9:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801bcb:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801bce:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801bd3:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bd6:	83 ec 04             	sub    $0x4,%esp
  801bd9:	53                   	push   %ebx
  801bda:	03 45 0c             	add    0xc(%ebp),%eax
  801bdd:	50                   	push   %eax
  801bde:	57                   	push   %edi
  801bdf:	e8 aa ec ff ff       	call   80088e <memmove>
		sys_cputs(buf, m);
  801be4:	83 c4 08             	add    $0x8,%esp
  801be7:	53                   	push   %ebx
  801be8:	57                   	push   %edi
  801be9:	e8 55 ee ff ff       	call   800a43 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bee:	01 de                	add    %ebx,%esi
  801bf0:	83 c4 10             	add    $0x10,%esp
  801bf3:	89 f0                	mov    %esi,%eax
  801bf5:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bf8:	72 cc                	jb     801bc6 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801bfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bfd:	5b                   	pop    %ebx
  801bfe:	5e                   	pop    %esi
  801bff:	5f                   	pop    %edi
  801c00:	5d                   	pop    %ebp
  801c01:	c3                   	ret    

00801c02 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c02:	55                   	push   %ebp
  801c03:	89 e5                	mov    %esp,%ebp
  801c05:	83 ec 08             	sub    $0x8,%esp
  801c08:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c0d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c11:	74 2a                	je     801c3d <devcons_read+0x3b>
  801c13:	eb 05                	jmp    801c1a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c15:	e8 c6 ee ff ff       	call   800ae0 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c1a:	e8 42 ee ff ff       	call   800a61 <sys_cgetc>
  801c1f:	85 c0                	test   %eax,%eax
  801c21:	74 f2                	je     801c15 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c23:	85 c0                	test   %eax,%eax
  801c25:	78 16                	js     801c3d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c27:	83 f8 04             	cmp    $0x4,%eax
  801c2a:	74 0c                	je     801c38 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c2f:	88 02                	mov    %al,(%edx)
	return 1;
  801c31:	b8 01 00 00 00       	mov    $0x1,%eax
  801c36:	eb 05                	jmp    801c3d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c38:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c3d:	c9                   	leave  
  801c3e:	c3                   	ret    

00801c3f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c3f:	55                   	push   %ebp
  801c40:	89 e5                	mov    %esp,%ebp
  801c42:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c45:	8b 45 08             	mov    0x8(%ebp),%eax
  801c48:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c4b:	6a 01                	push   $0x1
  801c4d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c50:	50                   	push   %eax
  801c51:	e8 ed ed ff ff       	call   800a43 <sys_cputs>
}
  801c56:	83 c4 10             	add    $0x10,%esp
  801c59:	c9                   	leave  
  801c5a:	c3                   	ret    

00801c5b <getchar>:

int
getchar(void)
{
  801c5b:	55                   	push   %ebp
  801c5c:	89 e5                	mov    %esp,%ebp
  801c5e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c61:	6a 01                	push   $0x1
  801c63:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c66:	50                   	push   %eax
  801c67:	6a 00                	push   $0x0
  801c69:	e8 90 f6 ff ff       	call   8012fe <read>
	if (r < 0)
  801c6e:	83 c4 10             	add    $0x10,%esp
  801c71:	85 c0                	test   %eax,%eax
  801c73:	78 0f                	js     801c84 <getchar+0x29>
		return r;
	if (r < 1)
  801c75:	85 c0                	test   %eax,%eax
  801c77:	7e 06                	jle    801c7f <getchar+0x24>
		return -E_EOF;
	return c;
  801c79:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c7d:	eb 05                	jmp    801c84 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c7f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c84:	c9                   	leave  
  801c85:	c3                   	ret    

00801c86 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c86:	55                   	push   %ebp
  801c87:	89 e5                	mov    %esp,%ebp
  801c89:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c8f:	50                   	push   %eax
  801c90:	ff 75 08             	pushl  0x8(%ebp)
  801c93:	e8 00 f4 ff ff       	call   801098 <fd_lookup>
  801c98:	83 c4 10             	add    $0x10,%esp
  801c9b:	85 c0                	test   %eax,%eax
  801c9d:	78 11                	js     801cb0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ca8:	39 10                	cmp    %edx,(%eax)
  801caa:	0f 94 c0             	sete   %al
  801cad:	0f b6 c0             	movzbl %al,%eax
}
  801cb0:	c9                   	leave  
  801cb1:	c3                   	ret    

00801cb2 <opencons>:

int
opencons(void)
{
  801cb2:	55                   	push   %ebp
  801cb3:	89 e5                	mov    %esp,%ebp
  801cb5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cbb:	50                   	push   %eax
  801cbc:	e8 88 f3 ff ff       	call   801049 <fd_alloc>
  801cc1:	83 c4 10             	add    $0x10,%esp
		return r;
  801cc4:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cc6:	85 c0                	test   %eax,%eax
  801cc8:	78 3e                	js     801d08 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cca:	83 ec 04             	sub    $0x4,%esp
  801ccd:	68 07 04 00 00       	push   $0x407
  801cd2:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd5:	6a 00                	push   $0x0
  801cd7:	e8 23 ee ff ff       	call   800aff <sys_page_alloc>
  801cdc:	83 c4 10             	add    $0x10,%esp
		return r;
  801cdf:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ce1:	85 c0                	test   %eax,%eax
  801ce3:	78 23                	js     801d08 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ce5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ceb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cee:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801cf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801cfa:	83 ec 0c             	sub    $0xc,%esp
  801cfd:	50                   	push   %eax
  801cfe:	e8 1f f3 ff ff       	call   801022 <fd2num>
  801d03:	89 c2                	mov    %eax,%edx
  801d05:	83 c4 10             	add    $0x10,%esp
}
  801d08:	89 d0                	mov    %edx,%eax
  801d0a:	c9                   	leave  
  801d0b:	c3                   	ret    

00801d0c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d0c:	55                   	push   %ebp
  801d0d:	89 e5                	mov    %esp,%ebp
  801d0f:	56                   	push   %esi
  801d10:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d11:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d14:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d1a:	e8 a2 ed ff ff       	call   800ac1 <sys_getenvid>
  801d1f:	83 ec 0c             	sub    $0xc,%esp
  801d22:	ff 75 0c             	pushl  0xc(%ebp)
  801d25:	ff 75 08             	pushl  0x8(%ebp)
  801d28:	56                   	push   %esi
  801d29:	50                   	push   %eax
  801d2a:	68 94 26 80 00       	push   $0x802694
  801d2f:	e8 43 e4 ff ff       	call   800177 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d34:	83 c4 18             	add    $0x18,%esp
  801d37:	53                   	push   %ebx
  801d38:	ff 75 10             	pushl  0x10(%ebp)
  801d3b:	e8 e6 e3 ff ff       	call   800126 <vcprintf>
	cprintf("\n");
  801d40:	c7 04 24 ec 21 80 00 	movl   $0x8021ec,(%esp)
  801d47:	e8 2b e4 ff ff       	call   800177 <cprintf>
  801d4c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d4f:	cc                   	int3   
  801d50:	eb fd                	jmp    801d4f <_panic+0x43>

00801d52 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d52:	55                   	push   %ebp
  801d53:	89 e5                	mov    %esp,%ebp
  801d55:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d58:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d5f:	75 2a                	jne    801d8b <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d61:	83 ec 04             	sub    $0x4,%esp
  801d64:	6a 07                	push   $0x7
  801d66:	68 00 f0 bf ee       	push   $0xeebff000
  801d6b:	6a 00                	push   $0x0
  801d6d:	e8 8d ed ff ff       	call   800aff <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801d72:	83 c4 10             	add    $0x10,%esp
  801d75:	85 c0                	test   %eax,%eax
  801d77:	79 12                	jns    801d8b <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801d79:	50                   	push   %eax
  801d7a:	68 b8 26 80 00       	push   $0x8026b8
  801d7f:	6a 23                	push   $0x23
  801d81:	68 bc 26 80 00       	push   $0x8026bc
  801d86:	e8 81 ff ff ff       	call   801d0c <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8e:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801d93:	83 ec 08             	sub    $0x8,%esp
  801d96:	68 bd 1d 80 00       	push   $0x801dbd
  801d9b:	6a 00                	push   $0x0
  801d9d:	e8 a8 ee ff ff       	call   800c4a <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801da2:	83 c4 10             	add    $0x10,%esp
  801da5:	85 c0                	test   %eax,%eax
  801da7:	79 12                	jns    801dbb <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801da9:	50                   	push   %eax
  801daa:	68 b8 26 80 00       	push   $0x8026b8
  801daf:	6a 2c                	push   $0x2c
  801db1:	68 bc 26 80 00       	push   $0x8026bc
  801db6:	e8 51 ff ff ff       	call   801d0c <_panic>
	}
}
  801dbb:	c9                   	leave  
  801dbc:	c3                   	ret    

00801dbd <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801dbd:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801dbe:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801dc3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801dc5:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801dc8:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801dcc:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801dd1:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801dd5:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801dd7:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801dda:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801ddb:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801dde:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801ddf:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801de0:	c3                   	ret    

00801de1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801de1:	55                   	push   %ebp
  801de2:	89 e5                	mov    %esp,%ebp
  801de4:	56                   	push   %esi
  801de5:	53                   	push   %ebx
  801de6:	8b 75 08             	mov    0x8(%ebp),%esi
  801de9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801def:	85 c0                	test   %eax,%eax
  801df1:	75 12                	jne    801e05 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801df3:	83 ec 0c             	sub    $0xc,%esp
  801df6:	68 00 00 c0 ee       	push   $0xeec00000
  801dfb:	e8 af ee ff ff       	call   800caf <sys_ipc_recv>
  801e00:	83 c4 10             	add    $0x10,%esp
  801e03:	eb 0c                	jmp    801e11 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e05:	83 ec 0c             	sub    $0xc,%esp
  801e08:	50                   	push   %eax
  801e09:	e8 a1 ee ff ff       	call   800caf <sys_ipc_recv>
  801e0e:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e11:	85 f6                	test   %esi,%esi
  801e13:	0f 95 c1             	setne  %cl
  801e16:	85 db                	test   %ebx,%ebx
  801e18:	0f 95 c2             	setne  %dl
  801e1b:	84 d1                	test   %dl,%cl
  801e1d:	74 09                	je     801e28 <ipc_recv+0x47>
  801e1f:	89 c2                	mov    %eax,%edx
  801e21:	c1 ea 1f             	shr    $0x1f,%edx
  801e24:	84 d2                	test   %dl,%dl
  801e26:	75 2a                	jne    801e52 <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e28:	85 f6                	test   %esi,%esi
  801e2a:	74 0d                	je     801e39 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e2c:	a1 08 40 80 00       	mov    0x804008,%eax
  801e31:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801e37:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e39:	85 db                	test   %ebx,%ebx
  801e3b:	74 0d                	je     801e4a <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e3d:	a1 08 40 80 00       	mov    0x804008,%eax
  801e42:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  801e48:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e4a:	a1 08 40 80 00       	mov    0x804008,%eax
  801e4f:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  801e52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e55:	5b                   	pop    %ebx
  801e56:	5e                   	pop    %esi
  801e57:	5d                   	pop    %ebp
  801e58:	c3                   	ret    

00801e59 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e59:	55                   	push   %ebp
  801e5a:	89 e5                	mov    %esp,%ebp
  801e5c:	57                   	push   %edi
  801e5d:	56                   	push   %esi
  801e5e:	53                   	push   %ebx
  801e5f:	83 ec 0c             	sub    $0xc,%esp
  801e62:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e65:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e68:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801e6b:	85 db                	test   %ebx,%ebx
  801e6d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e72:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e75:	ff 75 14             	pushl  0x14(%ebp)
  801e78:	53                   	push   %ebx
  801e79:	56                   	push   %esi
  801e7a:	57                   	push   %edi
  801e7b:	e8 0c ee ff ff       	call   800c8c <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801e80:	89 c2                	mov    %eax,%edx
  801e82:	c1 ea 1f             	shr    $0x1f,%edx
  801e85:	83 c4 10             	add    $0x10,%esp
  801e88:	84 d2                	test   %dl,%dl
  801e8a:	74 17                	je     801ea3 <ipc_send+0x4a>
  801e8c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e8f:	74 12                	je     801ea3 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801e91:	50                   	push   %eax
  801e92:	68 ca 26 80 00       	push   $0x8026ca
  801e97:	6a 47                	push   $0x47
  801e99:	68 d8 26 80 00       	push   $0x8026d8
  801e9e:	e8 69 fe ff ff       	call   801d0c <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801ea3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ea6:	75 07                	jne    801eaf <ipc_send+0x56>
			sys_yield();
  801ea8:	e8 33 ec ff ff       	call   800ae0 <sys_yield>
  801ead:	eb c6                	jmp    801e75 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801eaf:	85 c0                	test   %eax,%eax
  801eb1:	75 c2                	jne    801e75 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801eb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eb6:	5b                   	pop    %ebx
  801eb7:	5e                   	pop    %esi
  801eb8:	5f                   	pop    %edi
  801eb9:	5d                   	pop    %ebp
  801eba:	c3                   	ret    

00801ebb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ebb:	55                   	push   %ebp
  801ebc:	89 e5                	mov    %esp,%ebp
  801ebe:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ec1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ec6:	89 c2                	mov    %eax,%edx
  801ec8:	c1 e2 07             	shl    $0x7,%edx
  801ecb:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  801ed2:	8b 52 5c             	mov    0x5c(%edx),%edx
  801ed5:	39 ca                	cmp    %ecx,%edx
  801ed7:	75 11                	jne    801eea <ipc_find_env+0x2f>
			return envs[i].env_id;
  801ed9:	89 c2                	mov    %eax,%edx
  801edb:	c1 e2 07             	shl    $0x7,%edx
  801ede:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801ee5:	8b 40 54             	mov    0x54(%eax),%eax
  801ee8:	eb 0f                	jmp    801ef9 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801eea:	83 c0 01             	add    $0x1,%eax
  801eed:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ef2:	75 d2                	jne    801ec6 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ef4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ef9:	5d                   	pop    %ebp
  801efa:	c3                   	ret    

00801efb <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801efb:	55                   	push   %ebp
  801efc:	89 e5                	mov    %esp,%ebp
  801efe:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f01:	89 d0                	mov    %edx,%eax
  801f03:	c1 e8 16             	shr    $0x16,%eax
  801f06:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f0d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f12:	f6 c1 01             	test   $0x1,%cl
  801f15:	74 1d                	je     801f34 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f17:	c1 ea 0c             	shr    $0xc,%edx
  801f1a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f21:	f6 c2 01             	test   $0x1,%dl
  801f24:	74 0e                	je     801f34 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f26:	c1 ea 0c             	shr    $0xc,%edx
  801f29:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f30:	ef 
  801f31:	0f b7 c0             	movzwl %ax,%eax
}
  801f34:	5d                   	pop    %ebp
  801f35:	c3                   	ret    
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
