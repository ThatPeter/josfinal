
obj/user/faultread.debug:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  800039:	ff 35 00 00 00 00    	pushl  0x0
  80003f:	68 c0 21 80 00       	push   $0x8021c0
  800044:	e8 1c 01 00 00       	call   800165 <cprintf>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800059:	e8 51 0a 00 00       	call   800aaf <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	89 c2                	mov    %eax,%edx
  800065:	c1 e2 07             	shl    $0x7,%edx
  800068:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  80006f:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800074:	85 db                	test   %ebx,%ebx
  800076:	7e 07                	jle    80007f <libmain+0x31>
		binaryname = argv[0];
  800078:	8b 06                	mov    (%esi),%eax
  80007a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80007f:	83 ec 08             	sub    $0x8,%esp
  800082:	56                   	push   %esi
  800083:	53                   	push   %ebx
  800084:	e8 aa ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800089:	e8 2a 00 00 00       	call   8000b8 <exit>
}
  80008e:	83 c4 10             	add    $0x10,%esp
  800091:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800094:	5b                   	pop    %ebx
  800095:	5e                   	pop    %esi
  800096:	5d                   	pop    %ebp
  800097:	c3                   	ret    

00800098 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  80009e:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  8000a3:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8000a5:	e8 05 0a 00 00       	call   800aaf <sys_getenvid>
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	50                   	push   %eax
  8000ae:	e8 4b 0c 00 00       	call   800cfe <sys_thread_free>
}
  8000b3:	83 c4 10             	add    $0x10,%esp
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000be:	e8 18 11 00 00       	call   8011db <close_all>
	sys_env_destroy(0);
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	6a 00                	push   $0x0
  8000c8:	e8 a1 09 00 00       	call   800a6e <sys_env_destroy>
}
  8000cd:	83 c4 10             	add    $0x10,%esp
  8000d0:	c9                   	leave  
  8000d1:	c3                   	ret    

008000d2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	53                   	push   %ebx
  8000d6:	83 ec 04             	sub    $0x4,%esp
  8000d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000dc:	8b 13                	mov    (%ebx),%edx
  8000de:	8d 42 01             	lea    0x1(%edx),%eax
  8000e1:	89 03                	mov    %eax,(%ebx)
  8000e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000ea:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ef:	75 1a                	jne    80010b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000f1:	83 ec 08             	sub    $0x8,%esp
  8000f4:	68 ff 00 00 00       	push   $0xff
  8000f9:	8d 43 08             	lea    0x8(%ebx),%eax
  8000fc:	50                   	push   %eax
  8000fd:	e8 2f 09 00 00       	call   800a31 <sys_cputs>
		b->idx = 0;
  800102:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800108:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80010b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80010f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800112:	c9                   	leave  
  800113:	c3                   	ret    

00800114 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80011d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800124:	00 00 00 
	b.cnt = 0;
  800127:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80012e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800131:	ff 75 0c             	pushl  0xc(%ebp)
  800134:	ff 75 08             	pushl  0x8(%ebp)
  800137:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80013d:	50                   	push   %eax
  80013e:	68 d2 00 80 00       	push   $0x8000d2
  800143:	e8 54 01 00 00       	call   80029c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800148:	83 c4 08             	add    $0x8,%esp
  80014b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800151:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800157:	50                   	push   %eax
  800158:	e8 d4 08 00 00       	call   800a31 <sys_cputs>

	return b.cnt;
}
  80015d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800163:	c9                   	leave  
  800164:	c3                   	ret    

00800165 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80016b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80016e:	50                   	push   %eax
  80016f:	ff 75 08             	pushl  0x8(%ebp)
  800172:	e8 9d ff ff ff       	call   800114 <vcprintf>
	va_end(ap);

	return cnt;
}
  800177:	c9                   	leave  
  800178:	c3                   	ret    

00800179 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	57                   	push   %edi
  80017d:	56                   	push   %esi
  80017e:	53                   	push   %ebx
  80017f:	83 ec 1c             	sub    $0x1c,%esp
  800182:	89 c7                	mov    %eax,%edi
  800184:	89 d6                	mov    %edx,%esi
  800186:	8b 45 08             	mov    0x8(%ebp),%eax
  800189:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80018f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800192:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800195:	bb 00 00 00 00       	mov    $0x0,%ebx
  80019a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80019d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001a0:	39 d3                	cmp    %edx,%ebx
  8001a2:	72 05                	jb     8001a9 <printnum+0x30>
  8001a4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001a7:	77 45                	ja     8001ee <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a9:	83 ec 0c             	sub    $0xc,%esp
  8001ac:	ff 75 18             	pushl  0x18(%ebp)
  8001af:	8b 45 14             	mov    0x14(%ebp),%eax
  8001b2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001b5:	53                   	push   %ebx
  8001b6:	ff 75 10             	pushl  0x10(%ebp)
  8001b9:	83 ec 08             	sub    $0x8,%esp
  8001bc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001bf:	ff 75 e0             	pushl  -0x20(%ebp)
  8001c2:	ff 75 dc             	pushl  -0x24(%ebp)
  8001c5:	ff 75 d8             	pushl  -0x28(%ebp)
  8001c8:	e8 63 1d 00 00       	call   801f30 <__udivdi3>
  8001cd:	83 c4 18             	add    $0x18,%esp
  8001d0:	52                   	push   %edx
  8001d1:	50                   	push   %eax
  8001d2:	89 f2                	mov    %esi,%edx
  8001d4:	89 f8                	mov    %edi,%eax
  8001d6:	e8 9e ff ff ff       	call   800179 <printnum>
  8001db:	83 c4 20             	add    $0x20,%esp
  8001de:	eb 18                	jmp    8001f8 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001e0:	83 ec 08             	sub    $0x8,%esp
  8001e3:	56                   	push   %esi
  8001e4:	ff 75 18             	pushl  0x18(%ebp)
  8001e7:	ff d7                	call   *%edi
  8001e9:	83 c4 10             	add    $0x10,%esp
  8001ec:	eb 03                	jmp    8001f1 <printnum+0x78>
  8001ee:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001f1:	83 eb 01             	sub    $0x1,%ebx
  8001f4:	85 db                	test   %ebx,%ebx
  8001f6:	7f e8                	jg     8001e0 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001f8:	83 ec 08             	sub    $0x8,%esp
  8001fb:	56                   	push   %esi
  8001fc:	83 ec 04             	sub    $0x4,%esp
  8001ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  800202:	ff 75 e0             	pushl  -0x20(%ebp)
  800205:	ff 75 dc             	pushl  -0x24(%ebp)
  800208:	ff 75 d8             	pushl  -0x28(%ebp)
  80020b:	e8 50 1e 00 00       	call   802060 <__umoddi3>
  800210:	83 c4 14             	add    $0x14,%esp
  800213:	0f be 80 e8 21 80 00 	movsbl 0x8021e8(%eax),%eax
  80021a:	50                   	push   %eax
  80021b:	ff d7                	call   *%edi
}
  80021d:	83 c4 10             	add    $0x10,%esp
  800220:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800223:	5b                   	pop    %ebx
  800224:	5e                   	pop    %esi
  800225:	5f                   	pop    %edi
  800226:	5d                   	pop    %ebp
  800227:	c3                   	ret    

00800228 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80022b:	83 fa 01             	cmp    $0x1,%edx
  80022e:	7e 0e                	jle    80023e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800230:	8b 10                	mov    (%eax),%edx
  800232:	8d 4a 08             	lea    0x8(%edx),%ecx
  800235:	89 08                	mov    %ecx,(%eax)
  800237:	8b 02                	mov    (%edx),%eax
  800239:	8b 52 04             	mov    0x4(%edx),%edx
  80023c:	eb 22                	jmp    800260 <getuint+0x38>
	else if (lflag)
  80023e:	85 d2                	test   %edx,%edx
  800240:	74 10                	je     800252 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800242:	8b 10                	mov    (%eax),%edx
  800244:	8d 4a 04             	lea    0x4(%edx),%ecx
  800247:	89 08                	mov    %ecx,(%eax)
  800249:	8b 02                	mov    (%edx),%eax
  80024b:	ba 00 00 00 00       	mov    $0x0,%edx
  800250:	eb 0e                	jmp    800260 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800252:	8b 10                	mov    (%eax),%edx
  800254:	8d 4a 04             	lea    0x4(%edx),%ecx
  800257:	89 08                	mov    %ecx,(%eax)
  800259:	8b 02                	mov    (%edx),%eax
  80025b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800260:	5d                   	pop    %ebp
  800261:	c3                   	ret    

00800262 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800262:	55                   	push   %ebp
  800263:	89 e5                	mov    %esp,%ebp
  800265:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800268:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80026c:	8b 10                	mov    (%eax),%edx
  80026e:	3b 50 04             	cmp    0x4(%eax),%edx
  800271:	73 0a                	jae    80027d <sprintputch+0x1b>
		*b->buf++ = ch;
  800273:	8d 4a 01             	lea    0x1(%edx),%ecx
  800276:	89 08                	mov    %ecx,(%eax)
  800278:	8b 45 08             	mov    0x8(%ebp),%eax
  80027b:	88 02                	mov    %al,(%edx)
}
  80027d:	5d                   	pop    %ebp
  80027e:	c3                   	ret    

0080027f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800285:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800288:	50                   	push   %eax
  800289:	ff 75 10             	pushl  0x10(%ebp)
  80028c:	ff 75 0c             	pushl  0xc(%ebp)
  80028f:	ff 75 08             	pushl  0x8(%ebp)
  800292:	e8 05 00 00 00       	call   80029c <vprintfmt>
	va_end(ap);
}
  800297:	83 c4 10             	add    $0x10,%esp
  80029a:	c9                   	leave  
  80029b:	c3                   	ret    

0080029c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
  80029f:	57                   	push   %edi
  8002a0:	56                   	push   %esi
  8002a1:	53                   	push   %ebx
  8002a2:	83 ec 2c             	sub    $0x2c,%esp
  8002a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8002a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ab:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002ae:	eb 12                	jmp    8002c2 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002b0:	85 c0                	test   %eax,%eax
  8002b2:	0f 84 89 03 00 00    	je     800641 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002b8:	83 ec 08             	sub    $0x8,%esp
  8002bb:	53                   	push   %ebx
  8002bc:	50                   	push   %eax
  8002bd:	ff d6                	call   *%esi
  8002bf:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002c2:	83 c7 01             	add    $0x1,%edi
  8002c5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002c9:	83 f8 25             	cmp    $0x25,%eax
  8002cc:	75 e2                	jne    8002b0 <vprintfmt+0x14>
  8002ce:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002d2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002d9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002e0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ec:	eb 07                	jmp    8002f5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002f1:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f5:	8d 47 01             	lea    0x1(%edi),%eax
  8002f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002fb:	0f b6 07             	movzbl (%edi),%eax
  8002fe:	0f b6 c8             	movzbl %al,%ecx
  800301:	83 e8 23             	sub    $0x23,%eax
  800304:	3c 55                	cmp    $0x55,%al
  800306:	0f 87 1a 03 00 00    	ja     800626 <vprintfmt+0x38a>
  80030c:	0f b6 c0             	movzbl %al,%eax
  80030f:	ff 24 85 20 23 80 00 	jmp    *0x802320(,%eax,4)
  800316:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800319:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80031d:	eb d6                	jmp    8002f5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800322:	b8 00 00 00 00       	mov    $0x0,%eax
  800327:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80032a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80032d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800331:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800334:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800337:	83 fa 09             	cmp    $0x9,%edx
  80033a:	77 39                	ja     800375 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80033c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80033f:	eb e9                	jmp    80032a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800341:	8b 45 14             	mov    0x14(%ebp),%eax
  800344:	8d 48 04             	lea    0x4(%eax),%ecx
  800347:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80034a:	8b 00                	mov    (%eax),%eax
  80034c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800352:	eb 27                	jmp    80037b <vprintfmt+0xdf>
  800354:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800357:	85 c0                	test   %eax,%eax
  800359:	b9 00 00 00 00       	mov    $0x0,%ecx
  80035e:	0f 49 c8             	cmovns %eax,%ecx
  800361:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800364:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800367:	eb 8c                	jmp    8002f5 <vprintfmt+0x59>
  800369:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80036c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800373:	eb 80                	jmp    8002f5 <vprintfmt+0x59>
  800375:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800378:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80037b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80037f:	0f 89 70 ff ff ff    	jns    8002f5 <vprintfmt+0x59>
				width = precision, precision = -1;
  800385:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800388:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80038b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800392:	e9 5e ff ff ff       	jmp    8002f5 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800397:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80039d:	e9 53 ff ff ff       	jmp    8002f5 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a5:	8d 50 04             	lea    0x4(%eax),%edx
  8003a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ab:	83 ec 08             	sub    $0x8,%esp
  8003ae:	53                   	push   %ebx
  8003af:	ff 30                	pushl  (%eax)
  8003b1:	ff d6                	call   *%esi
			break;
  8003b3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003b9:	e9 04 ff ff ff       	jmp    8002c2 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003be:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c1:	8d 50 04             	lea    0x4(%eax),%edx
  8003c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c7:	8b 00                	mov    (%eax),%eax
  8003c9:	99                   	cltd   
  8003ca:	31 d0                	xor    %edx,%eax
  8003cc:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ce:	83 f8 0f             	cmp    $0xf,%eax
  8003d1:	7f 0b                	jg     8003de <vprintfmt+0x142>
  8003d3:	8b 14 85 80 24 80 00 	mov    0x802480(,%eax,4),%edx
  8003da:	85 d2                	test   %edx,%edx
  8003dc:	75 18                	jne    8003f6 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003de:	50                   	push   %eax
  8003df:	68 00 22 80 00       	push   $0x802200
  8003e4:	53                   	push   %ebx
  8003e5:	56                   	push   %esi
  8003e6:	e8 94 fe ff ff       	call   80027f <printfmt>
  8003eb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003f1:	e9 cc fe ff ff       	jmp    8002c2 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003f6:	52                   	push   %edx
  8003f7:	68 2d 26 80 00       	push   $0x80262d
  8003fc:	53                   	push   %ebx
  8003fd:	56                   	push   %esi
  8003fe:	e8 7c fe ff ff       	call   80027f <printfmt>
  800403:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800406:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800409:	e9 b4 fe ff ff       	jmp    8002c2 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80040e:	8b 45 14             	mov    0x14(%ebp),%eax
  800411:	8d 50 04             	lea    0x4(%eax),%edx
  800414:	89 55 14             	mov    %edx,0x14(%ebp)
  800417:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800419:	85 ff                	test   %edi,%edi
  80041b:	b8 f9 21 80 00       	mov    $0x8021f9,%eax
  800420:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800423:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800427:	0f 8e 94 00 00 00    	jle    8004c1 <vprintfmt+0x225>
  80042d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800431:	0f 84 98 00 00 00    	je     8004cf <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800437:	83 ec 08             	sub    $0x8,%esp
  80043a:	ff 75 d0             	pushl  -0x30(%ebp)
  80043d:	57                   	push   %edi
  80043e:	e8 86 02 00 00       	call   8006c9 <strnlen>
  800443:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800446:	29 c1                	sub    %eax,%ecx
  800448:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80044b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80044e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800452:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800455:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800458:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80045a:	eb 0f                	jmp    80046b <vprintfmt+0x1cf>
					putch(padc, putdat);
  80045c:	83 ec 08             	sub    $0x8,%esp
  80045f:	53                   	push   %ebx
  800460:	ff 75 e0             	pushl  -0x20(%ebp)
  800463:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800465:	83 ef 01             	sub    $0x1,%edi
  800468:	83 c4 10             	add    $0x10,%esp
  80046b:	85 ff                	test   %edi,%edi
  80046d:	7f ed                	jg     80045c <vprintfmt+0x1c0>
  80046f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800472:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800475:	85 c9                	test   %ecx,%ecx
  800477:	b8 00 00 00 00       	mov    $0x0,%eax
  80047c:	0f 49 c1             	cmovns %ecx,%eax
  80047f:	29 c1                	sub    %eax,%ecx
  800481:	89 75 08             	mov    %esi,0x8(%ebp)
  800484:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800487:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80048a:	89 cb                	mov    %ecx,%ebx
  80048c:	eb 4d                	jmp    8004db <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80048e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800492:	74 1b                	je     8004af <vprintfmt+0x213>
  800494:	0f be c0             	movsbl %al,%eax
  800497:	83 e8 20             	sub    $0x20,%eax
  80049a:	83 f8 5e             	cmp    $0x5e,%eax
  80049d:	76 10                	jbe    8004af <vprintfmt+0x213>
					putch('?', putdat);
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	ff 75 0c             	pushl  0xc(%ebp)
  8004a5:	6a 3f                	push   $0x3f
  8004a7:	ff 55 08             	call   *0x8(%ebp)
  8004aa:	83 c4 10             	add    $0x10,%esp
  8004ad:	eb 0d                	jmp    8004bc <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	ff 75 0c             	pushl  0xc(%ebp)
  8004b5:	52                   	push   %edx
  8004b6:	ff 55 08             	call   *0x8(%ebp)
  8004b9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004bc:	83 eb 01             	sub    $0x1,%ebx
  8004bf:	eb 1a                	jmp    8004db <vprintfmt+0x23f>
  8004c1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ca:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004cd:	eb 0c                	jmp    8004db <vprintfmt+0x23f>
  8004cf:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004db:	83 c7 01             	add    $0x1,%edi
  8004de:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004e2:	0f be d0             	movsbl %al,%edx
  8004e5:	85 d2                	test   %edx,%edx
  8004e7:	74 23                	je     80050c <vprintfmt+0x270>
  8004e9:	85 f6                	test   %esi,%esi
  8004eb:	78 a1                	js     80048e <vprintfmt+0x1f2>
  8004ed:	83 ee 01             	sub    $0x1,%esi
  8004f0:	79 9c                	jns    80048e <vprintfmt+0x1f2>
  8004f2:	89 df                	mov    %ebx,%edi
  8004f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004fa:	eb 18                	jmp    800514 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004fc:	83 ec 08             	sub    $0x8,%esp
  8004ff:	53                   	push   %ebx
  800500:	6a 20                	push   $0x20
  800502:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800504:	83 ef 01             	sub    $0x1,%edi
  800507:	83 c4 10             	add    $0x10,%esp
  80050a:	eb 08                	jmp    800514 <vprintfmt+0x278>
  80050c:	89 df                	mov    %ebx,%edi
  80050e:	8b 75 08             	mov    0x8(%ebp),%esi
  800511:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800514:	85 ff                	test   %edi,%edi
  800516:	7f e4                	jg     8004fc <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800518:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80051b:	e9 a2 fd ff ff       	jmp    8002c2 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800520:	83 fa 01             	cmp    $0x1,%edx
  800523:	7e 16                	jle    80053b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800525:	8b 45 14             	mov    0x14(%ebp),%eax
  800528:	8d 50 08             	lea    0x8(%eax),%edx
  80052b:	89 55 14             	mov    %edx,0x14(%ebp)
  80052e:	8b 50 04             	mov    0x4(%eax),%edx
  800531:	8b 00                	mov    (%eax),%eax
  800533:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800536:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800539:	eb 32                	jmp    80056d <vprintfmt+0x2d1>
	else if (lflag)
  80053b:	85 d2                	test   %edx,%edx
  80053d:	74 18                	je     800557 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80053f:	8b 45 14             	mov    0x14(%ebp),%eax
  800542:	8d 50 04             	lea    0x4(%eax),%edx
  800545:	89 55 14             	mov    %edx,0x14(%ebp)
  800548:	8b 00                	mov    (%eax),%eax
  80054a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054d:	89 c1                	mov    %eax,%ecx
  80054f:	c1 f9 1f             	sar    $0x1f,%ecx
  800552:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800555:	eb 16                	jmp    80056d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800557:	8b 45 14             	mov    0x14(%ebp),%eax
  80055a:	8d 50 04             	lea    0x4(%eax),%edx
  80055d:	89 55 14             	mov    %edx,0x14(%ebp)
  800560:	8b 00                	mov    (%eax),%eax
  800562:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800565:	89 c1                	mov    %eax,%ecx
  800567:	c1 f9 1f             	sar    $0x1f,%ecx
  80056a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80056d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800570:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800573:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800578:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80057c:	79 74                	jns    8005f2 <vprintfmt+0x356>
				putch('-', putdat);
  80057e:	83 ec 08             	sub    $0x8,%esp
  800581:	53                   	push   %ebx
  800582:	6a 2d                	push   $0x2d
  800584:	ff d6                	call   *%esi
				num = -(long long) num;
  800586:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800589:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80058c:	f7 d8                	neg    %eax
  80058e:	83 d2 00             	adc    $0x0,%edx
  800591:	f7 da                	neg    %edx
  800593:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800596:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80059b:	eb 55                	jmp    8005f2 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80059d:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a0:	e8 83 fc ff ff       	call   800228 <getuint>
			base = 10;
  8005a5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005aa:	eb 46                	jmp    8005f2 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005ac:	8d 45 14             	lea    0x14(%ebp),%eax
  8005af:	e8 74 fc ff ff       	call   800228 <getuint>
			base = 8;
  8005b4:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005b9:	eb 37                	jmp    8005f2 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005bb:	83 ec 08             	sub    $0x8,%esp
  8005be:	53                   	push   %ebx
  8005bf:	6a 30                	push   $0x30
  8005c1:	ff d6                	call   *%esi
			putch('x', putdat);
  8005c3:	83 c4 08             	add    $0x8,%esp
  8005c6:	53                   	push   %ebx
  8005c7:	6a 78                	push   $0x78
  8005c9:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ce:	8d 50 04             	lea    0x4(%eax),%edx
  8005d1:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005d4:	8b 00                	mov    (%eax),%eax
  8005d6:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005db:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005de:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005e3:	eb 0d                	jmp    8005f2 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005e5:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e8:	e8 3b fc ff ff       	call   800228 <getuint>
			base = 16;
  8005ed:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005f2:	83 ec 0c             	sub    $0xc,%esp
  8005f5:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005f9:	57                   	push   %edi
  8005fa:	ff 75 e0             	pushl  -0x20(%ebp)
  8005fd:	51                   	push   %ecx
  8005fe:	52                   	push   %edx
  8005ff:	50                   	push   %eax
  800600:	89 da                	mov    %ebx,%edx
  800602:	89 f0                	mov    %esi,%eax
  800604:	e8 70 fb ff ff       	call   800179 <printnum>
			break;
  800609:	83 c4 20             	add    $0x20,%esp
  80060c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80060f:	e9 ae fc ff ff       	jmp    8002c2 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800614:	83 ec 08             	sub    $0x8,%esp
  800617:	53                   	push   %ebx
  800618:	51                   	push   %ecx
  800619:	ff d6                	call   *%esi
			break;
  80061b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800621:	e9 9c fc ff ff       	jmp    8002c2 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800626:	83 ec 08             	sub    $0x8,%esp
  800629:	53                   	push   %ebx
  80062a:	6a 25                	push   $0x25
  80062c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80062e:	83 c4 10             	add    $0x10,%esp
  800631:	eb 03                	jmp    800636 <vprintfmt+0x39a>
  800633:	83 ef 01             	sub    $0x1,%edi
  800636:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80063a:	75 f7                	jne    800633 <vprintfmt+0x397>
  80063c:	e9 81 fc ff ff       	jmp    8002c2 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800641:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800644:	5b                   	pop    %ebx
  800645:	5e                   	pop    %esi
  800646:	5f                   	pop    %edi
  800647:	5d                   	pop    %ebp
  800648:	c3                   	ret    

00800649 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800649:	55                   	push   %ebp
  80064a:	89 e5                	mov    %esp,%ebp
  80064c:	83 ec 18             	sub    $0x18,%esp
  80064f:	8b 45 08             	mov    0x8(%ebp),%eax
  800652:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800655:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800658:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80065c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80065f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800666:	85 c0                	test   %eax,%eax
  800668:	74 26                	je     800690 <vsnprintf+0x47>
  80066a:	85 d2                	test   %edx,%edx
  80066c:	7e 22                	jle    800690 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80066e:	ff 75 14             	pushl  0x14(%ebp)
  800671:	ff 75 10             	pushl  0x10(%ebp)
  800674:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800677:	50                   	push   %eax
  800678:	68 62 02 80 00       	push   $0x800262
  80067d:	e8 1a fc ff ff       	call   80029c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800682:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800685:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800688:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80068b:	83 c4 10             	add    $0x10,%esp
  80068e:	eb 05                	jmp    800695 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800690:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800695:	c9                   	leave  
  800696:	c3                   	ret    

00800697 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800697:	55                   	push   %ebp
  800698:	89 e5                	mov    %esp,%ebp
  80069a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80069d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006a0:	50                   	push   %eax
  8006a1:	ff 75 10             	pushl  0x10(%ebp)
  8006a4:	ff 75 0c             	pushl  0xc(%ebp)
  8006a7:	ff 75 08             	pushl  0x8(%ebp)
  8006aa:	e8 9a ff ff ff       	call   800649 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006af:	c9                   	leave  
  8006b0:	c3                   	ret    

008006b1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006b1:	55                   	push   %ebp
  8006b2:	89 e5                	mov    %esp,%ebp
  8006b4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006bc:	eb 03                	jmp    8006c1 <strlen+0x10>
		n++;
  8006be:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006c5:	75 f7                	jne    8006be <strlen+0xd>
		n++;
	return n;
}
  8006c7:	5d                   	pop    %ebp
  8006c8:	c3                   	ret    

008006c9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006c9:	55                   	push   %ebp
  8006ca:	89 e5                	mov    %esp,%ebp
  8006cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006cf:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8006d7:	eb 03                	jmp    8006dc <strnlen+0x13>
		n++;
  8006d9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006dc:	39 c2                	cmp    %eax,%edx
  8006de:	74 08                	je     8006e8 <strnlen+0x1f>
  8006e0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006e4:	75 f3                	jne    8006d9 <strnlen+0x10>
  8006e6:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006e8:	5d                   	pop    %ebp
  8006e9:	c3                   	ret    

008006ea <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006ea:	55                   	push   %ebp
  8006eb:	89 e5                	mov    %esp,%ebp
  8006ed:	53                   	push   %ebx
  8006ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006f4:	89 c2                	mov    %eax,%edx
  8006f6:	83 c2 01             	add    $0x1,%edx
  8006f9:	83 c1 01             	add    $0x1,%ecx
  8006fc:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800700:	88 5a ff             	mov    %bl,-0x1(%edx)
  800703:	84 db                	test   %bl,%bl
  800705:	75 ef                	jne    8006f6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800707:	5b                   	pop    %ebx
  800708:	5d                   	pop    %ebp
  800709:	c3                   	ret    

0080070a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	53                   	push   %ebx
  80070e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800711:	53                   	push   %ebx
  800712:	e8 9a ff ff ff       	call   8006b1 <strlen>
  800717:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80071a:	ff 75 0c             	pushl  0xc(%ebp)
  80071d:	01 d8                	add    %ebx,%eax
  80071f:	50                   	push   %eax
  800720:	e8 c5 ff ff ff       	call   8006ea <strcpy>
	return dst;
}
  800725:	89 d8                	mov    %ebx,%eax
  800727:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80072a:	c9                   	leave  
  80072b:	c3                   	ret    

0080072c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	56                   	push   %esi
  800730:	53                   	push   %ebx
  800731:	8b 75 08             	mov    0x8(%ebp),%esi
  800734:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800737:	89 f3                	mov    %esi,%ebx
  800739:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80073c:	89 f2                	mov    %esi,%edx
  80073e:	eb 0f                	jmp    80074f <strncpy+0x23>
		*dst++ = *src;
  800740:	83 c2 01             	add    $0x1,%edx
  800743:	0f b6 01             	movzbl (%ecx),%eax
  800746:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800749:	80 39 01             	cmpb   $0x1,(%ecx)
  80074c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80074f:	39 da                	cmp    %ebx,%edx
  800751:	75 ed                	jne    800740 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800753:	89 f0                	mov    %esi,%eax
  800755:	5b                   	pop    %ebx
  800756:	5e                   	pop    %esi
  800757:	5d                   	pop    %ebp
  800758:	c3                   	ret    

00800759 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	56                   	push   %esi
  80075d:	53                   	push   %ebx
  80075e:	8b 75 08             	mov    0x8(%ebp),%esi
  800761:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800764:	8b 55 10             	mov    0x10(%ebp),%edx
  800767:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800769:	85 d2                	test   %edx,%edx
  80076b:	74 21                	je     80078e <strlcpy+0x35>
  80076d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800771:	89 f2                	mov    %esi,%edx
  800773:	eb 09                	jmp    80077e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800775:	83 c2 01             	add    $0x1,%edx
  800778:	83 c1 01             	add    $0x1,%ecx
  80077b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80077e:	39 c2                	cmp    %eax,%edx
  800780:	74 09                	je     80078b <strlcpy+0x32>
  800782:	0f b6 19             	movzbl (%ecx),%ebx
  800785:	84 db                	test   %bl,%bl
  800787:	75 ec                	jne    800775 <strlcpy+0x1c>
  800789:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80078b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80078e:	29 f0                	sub    %esi,%eax
}
  800790:	5b                   	pop    %ebx
  800791:	5e                   	pop    %esi
  800792:	5d                   	pop    %ebp
  800793:	c3                   	ret    

00800794 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80079d:	eb 06                	jmp    8007a5 <strcmp+0x11>
		p++, q++;
  80079f:	83 c1 01             	add    $0x1,%ecx
  8007a2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007a5:	0f b6 01             	movzbl (%ecx),%eax
  8007a8:	84 c0                	test   %al,%al
  8007aa:	74 04                	je     8007b0 <strcmp+0x1c>
  8007ac:	3a 02                	cmp    (%edx),%al
  8007ae:	74 ef                	je     80079f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007b0:	0f b6 c0             	movzbl %al,%eax
  8007b3:	0f b6 12             	movzbl (%edx),%edx
  8007b6:	29 d0                	sub    %edx,%eax
}
  8007b8:	5d                   	pop    %ebp
  8007b9:	c3                   	ret    

008007ba <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	53                   	push   %ebx
  8007be:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c4:	89 c3                	mov    %eax,%ebx
  8007c6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007c9:	eb 06                	jmp    8007d1 <strncmp+0x17>
		n--, p++, q++;
  8007cb:	83 c0 01             	add    $0x1,%eax
  8007ce:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007d1:	39 d8                	cmp    %ebx,%eax
  8007d3:	74 15                	je     8007ea <strncmp+0x30>
  8007d5:	0f b6 08             	movzbl (%eax),%ecx
  8007d8:	84 c9                	test   %cl,%cl
  8007da:	74 04                	je     8007e0 <strncmp+0x26>
  8007dc:	3a 0a                	cmp    (%edx),%cl
  8007de:	74 eb                	je     8007cb <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007e0:	0f b6 00             	movzbl (%eax),%eax
  8007e3:	0f b6 12             	movzbl (%edx),%edx
  8007e6:	29 d0                	sub    %edx,%eax
  8007e8:	eb 05                	jmp    8007ef <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007ea:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007ef:	5b                   	pop    %ebx
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007fc:	eb 07                	jmp    800805 <strchr+0x13>
		if (*s == c)
  8007fe:	38 ca                	cmp    %cl,%dl
  800800:	74 0f                	je     800811 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800802:	83 c0 01             	add    $0x1,%eax
  800805:	0f b6 10             	movzbl (%eax),%edx
  800808:	84 d2                	test   %dl,%dl
  80080a:	75 f2                	jne    8007fe <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80080c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800811:	5d                   	pop    %ebp
  800812:	c3                   	ret    

00800813 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	8b 45 08             	mov    0x8(%ebp),%eax
  800819:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80081d:	eb 03                	jmp    800822 <strfind+0xf>
  80081f:	83 c0 01             	add    $0x1,%eax
  800822:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800825:	38 ca                	cmp    %cl,%dl
  800827:	74 04                	je     80082d <strfind+0x1a>
  800829:	84 d2                	test   %dl,%dl
  80082b:	75 f2                	jne    80081f <strfind+0xc>
			break;
	return (char *) s;
}
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	57                   	push   %edi
  800833:	56                   	push   %esi
  800834:	53                   	push   %ebx
  800835:	8b 7d 08             	mov    0x8(%ebp),%edi
  800838:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80083b:	85 c9                	test   %ecx,%ecx
  80083d:	74 36                	je     800875 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80083f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800845:	75 28                	jne    80086f <memset+0x40>
  800847:	f6 c1 03             	test   $0x3,%cl
  80084a:	75 23                	jne    80086f <memset+0x40>
		c &= 0xFF;
  80084c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800850:	89 d3                	mov    %edx,%ebx
  800852:	c1 e3 08             	shl    $0x8,%ebx
  800855:	89 d6                	mov    %edx,%esi
  800857:	c1 e6 18             	shl    $0x18,%esi
  80085a:	89 d0                	mov    %edx,%eax
  80085c:	c1 e0 10             	shl    $0x10,%eax
  80085f:	09 f0                	or     %esi,%eax
  800861:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800863:	89 d8                	mov    %ebx,%eax
  800865:	09 d0                	or     %edx,%eax
  800867:	c1 e9 02             	shr    $0x2,%ecx
  80086a:	fc                   	cld    
  80086b:	f3 ab                	rep stos %eax,%es:(%edi)
  80086d:	eb 06                	jmp    800875 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80086f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800872:	fc                   	cld    
  800873:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800875:	89 f8                	mov    %edi,%eax
  800877:	5b                   	pop    %ebx
  800878:	5e                   	pop    %esi
  800879:	5f                   	pop    %edi
  80087a:	5d                   	pop    %ebp
  80087b:	c3                   	ret    

0080087c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	57                   	push   %edi
  800880:	56                   	push   %esi
  800881:	8b 45 08             	mov    0x8(%ebp),%eax
  800884:	8b 75 0c             	mov    0xc(%ebp),%esi
  800887:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80088a:	39 c6                	cmp    %eax,%esi
  80088c:	73 35                	jae    8008c3 <memmove+0x47>
  80088e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800891:	39 d0                	cmp    %edx,%eax
  800893:	73 2e                	jae    8008c3 <memmove+0x47>
		s += n;
		d += n;
  800895:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800898:	89 d6                	mov    %edx,%esi
  80089a:	09 fe                	or     %edi,%esi
  80089c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008a2:	75 13                	jne    8008b7 <memmove+0x3b>
  8008a4:	f6 c1 03             	test   $0x3,%cl
  8008a7:	75 0e                	jne    8008b7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008a9:	83 ef 04             	sub    $0x4,%edi
  8008ac:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008af:	c1 e9 02             	shr    $0x2,%ecx
  8008b2:	fd                   	std    
  8008b3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008b5:	eb 09                	jmp    8008c0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008b7:	83 ef 01             	sub    $0x1,%edi
  8008ba:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008bd:	fd                   	std    
  8008be:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008c0:	fc                   	cld    
  8008c1:	eb 1d                	jmp    8008e0 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c3:	89 f2                	mov    %esi,%edx
  8008c5:	09 c2                	or     %eax,%edx
  8008c7:	f6 c2 03             	test   $0x3,%dl
  8008ca:	75 0f                	jne    8008db <memmove+0x5f>
  8008cc:	f6 c1 03             	test   $0x3,%cl
  8008cf:	75 0a                	jne    8008db <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008d1:	c1 e9 02             	shr    $0x2,%ecx
  8008d4:	89 c7                	mov    %eax,%edi
  8008d6:	fc                   	cld    
  8008d7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008d9:	eb 05                	jmp    8008e0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008db:	89 c7                	mov    %eax,%edi
  8008dd:	fc                   	cld    
  8008de:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008e0:	5e                   	pop    %esi
  8008e1:	5f                   	pop    %edi
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008e7:	ff 75 10             	pushl  0x10(%ebp)
  8008ea:	ff 75 0c             	pushl  0xc(%ebp)
  8008ed:	ff 75 08             	pushl  0x8(%ebp)
  8008f0:	e8 87 ff ff ff       	call   80087c <memmove>
}
  8008f5:	c9                   	leave  
  8008f6:	c3                   	ret    

008008f7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	56                   	push   %esi
  8008fb:	53                   	push   %ebx
  8008fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800902:	89 c6                	mov    %eax,%esi
  800904:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800907:	eb 1a                	jmp    800923 <memcmp+0x2c>
		if (*s1 != *s2)
  800909:	0f b6 08             	movzbl (%eax),%ecx
  80090c:	0f b6 1a             	movzbl (%edx),%ebx
  80090f:	38 d9                	cmp    %bl,%cl
  800911:	74 0a                	je     80091d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800913:	0f b6 c1             	movzbl %cl,%eax
  800916:	0f b6 db             	movzbl %bl,%ebx
  800919:	29 d8                	sub    %ebx,%eax
  80091b:	eb 0f                	jmp    80092c <memcmp+0x35>
		s1++, s2++;
  80091d:	83 c0 01             	add    $0x1,%eax
  800920:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800923:	39 f0                	cmp    %esi,%eax
  800925:	75 e2                	jne    800909 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800927:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80092c:	5b                   	pop    %ebx
  80092d:	5e                   	pop    %esi
  80092e:	5d                   	pop    %ebp
  80092f:	c3                   	ret    

00800930 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	53                   	push   %ebx
  800934:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800937:	89 c1                	mov    %eax,%ecx
  800939:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80093c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800940:	eb 0a                	jmp    80094c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800942:	0f b6 10             	movzbl (%eax),%edx
  800945:	39 da                	cmp    %ebx,%edx
  800947:	74 07                	je     800950 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800949:	83 c0 01             	add    $0x1,%eax
  80094c:	39 c8                	cmp    %ecx,%eax
  80094e:	72 f2                	jb     800942 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800950:	5b                   	pop    %ebx
  800951:	5d                   	pop    %ebp
  800952:	c3                   	ret    

00800953 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	57                   	push   %edi
  800957:	56                   	push   %esi
  800958:	53                   	push   %ebx
  800959:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80095f:	eb 03                	jmp    800964 <strtol+0x11>
		s++;
  800961:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800964:	0f b6 01             	movzbl (%ecx),%eax
  800967:	3c 20                	cmp    $0x20,%al
  800969:	74 f6                	je     800961 <strtol+0xe>
  80096b:	3c 09                	cmp    $0x9,%al
  80096d:	74 f2                	je     800961 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80096f:	3c 2b                	cmp    $0x2b,%al
  800971:	75 0a                	jne    80097d <strtol+0x2a>
		s++;
  800973:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800976:	bf 00 00 00 00       	mov    $0x0,%edi
  80097b:	eb 11                	jmp    80098e <strtol+0x3b>
  80097d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800982:	3c 2d                	cmp    $0x2d,%al
  800984:	75 08                	jne    80098e <strtol+0x3b>
		s++, neg = 1;
  800986:	83 c1 01             	add    $0x1,%ecx
  800989:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80098e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800994:	75 15                	jne    8009ab <strtol+0x58>
  800996:	80 39 30             	cmpb   $0x30,(%ecx)
  800999:	75 10                	jne    8009ab <strtol+0x58>
  80099b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80099f:	75 7c                	jne    800a1d <strtol+0xca>
		s += 2, base = 16;
  8009a1:	83 c1 02             	add    $0x2,%ecx
  8009a4:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009a9:	eb 16                	jmp    8009c1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009ab:	85 db                	test   %ebx,%ebx
  8009ad:	75 12                	jne    8009c1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009af:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009b4:	80 39 30             	cmpb   $0x30,(%ecx)
  8009b7:	75 08                	jne    8009c1 <strtol+0x6e>
		s++, base = 8;
  8009b9:	83 c1 01             	add    $0x1,%ecx
  8009bc:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009c9:	0f b6 11             	movzbl (%ecx),%edx
  8009cc:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009cf:	89 f3                	mov    %esi,%ebx
  8009d1:	80 fb 09             	cmp    $0x9,%bl
  8009d4:	77 08                	ja     8009de <strtol+0x8b>
			dig = *s - '0';
  8009d6:	0f be d2             	movsbl %dl,%edx
  8009d9:	83 ea 30             	sub    $0x30,%edx
  8009dc:	eb 22                	jmp    800a00 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009de:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009e1:	89 f3                	mov    %esi,%ebx
  8009e3:	80 fb 19             	cmp    $0x19,%bl
  8009e6:	77 08                	ja     8009f0 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009e8:	0f be d2             	movsbl %dl,%edx
  8009eb:	83 ea 57             	sub    $0x57,%edx
  8009ee:	eb 10                	jmp    800a00 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009f0:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009f3:	89 f3                	mov    %esi,%ebx
  8009f5:	80 fb 19             	cmp    $0x19,%bl
  8009f8:	77 16                	ja     800a10 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8009fa:	0f be d2             	movsbl %dl,%edx
  8009fd:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a00:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a03:	7d 0b                	jge    800a10 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a05:	83 c1 01             	add    $0x1,%ecx
  800a08:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a0c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a0e:	eb b9                	jmp    8009c9 <strtol+0x76>

	if (endptr)
  800a10:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a14:	74 0d                	je     800a23 <strtol+0xd0>
		*endptr = (char *) s;
  800a16:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a19:	89 0e                	mov    %ecx,(%esi)
  800a1b:	eb 06                	jmp    800a23 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a1d:	85 db                	test   %ebx,%ebx
  800a1f:	74 98                	je     8009b9 <strtol+0x66>
  800a21:	eb 9e                	jmp    8009c1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a23:	89 c2                	mov    %eax,%edx
  800a25:	f7 da                	neg    %edx
  800a27:	85 ff                	test   %edi,%edi
  800a29:	0f 45 c2             	cmovne %edx,%eax
}
  800a2c:	5b                   	pop    %ebx
  800a2d:	5e                   	pop    %esi
  800a2e:	5f                   	pop    %edi
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    

00800a31 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	57                   	push   %edi
  800a35:	56                   	push   %esi
  800a36:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a37:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a42:	89 c3                	mov    %eax,%ebx
  800a44:	89 c7                	mov    %eax,%edi
  800a46:	89 c6                	mov    %eax,%esi
  800a48:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a4a:	5b                   	pop    %ebx
  800a4b:	5e                   	pop    %esi
  800a4c:	5f                   	pop    %edi
  800a4d:	5d                   	pop    %ebp
  800a4e:	c3                   	ret    

00800a4f <sys_cgetc>:

int
sys_cgetc(void)
{
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
  800a52:	57                   	push   %edi
  800a53:	56                   	push   %esi
  800a54:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a55:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5a:	b8 01 00 00 00       	mov    $0x1,%eax
  800a5f:	89 d1                	mov    %edx,%ecx
  800a61:	89 d3                	mov    %edx,%ebx
  800a63:	89 d7                	mov    %edx,%edi
  800a65:	89 d6                	mov    %edx,%esi
  800a67:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a69:	5b                   	pop    %ebx
  800a6a:	5e                   	pop    %esi
  800a6b:	5f                   	pop    %edi
  800a6c:	5d                   	pop    %ebp
  800a6d:	c3                   	ret    

00800a6e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a6e:	55                   	push   %ebp
  800a6f:	89 e5                	mov    %esp,%ebp
  800a71:	57                   	push   %edi
  800a72:	56                   	push   %esi
  800a73:	53                   	push   %ebx
  800a74:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a77:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a7c:	b8 03 00 00 00       	mov    $0x3,%eax
  800a81:	8b 55 08             	mov    0x8(%ebp),%edx
  800a84:	89 cb                	mov    %ecx,%ebx
  800a86:	89 cf                	mov    %ecx,%edi
  800a88:	89 ce                	mov    %ecx,%esi
  800a8a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a8c:	85 c0                	test   %eax,%eax
  800a8e:	7e 17                	jle    800aa7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a90:	83 ec 0c             	sub    $0xc,%esp
  800a93:	50                   	push   %eax
  800a94:	6a 03                	push   $0x3
  800a96:	68 df 24 80 00       	push   $0x8024df
  800a9b:	6a 23                	push   $0x23
  800a9d:	68 fc 24 80 00       	push   $0x8024fc
  800aa2:	e8 53 12 00 00       	call   801cfa <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aa7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aaa:	5b                   	pop    %ebx
  800aab:	5e                   	pop    %esi
  800aac:	5f                   	pop    %edi
  800aad:	5d                   	pop    %ebp
  800aae:	c3                   	ret    

00800aaf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aaf:	55                   	push   %ebp
  800ab0:	89 e5                	mov    %esp,%ebp
  800ab2:	57                   	push   %edi
  800ab3:	56                   	push   %esi
  800ab4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aba:	b8 02 00 00 00       	mov    $0x2,%eax
  800abf:	89 d1                	mov    %edx,%ecx
  800ac1:	89 d3                	mov    %edx,%ebx
  800ac3:	89 d7                	mov    %edx,%edi
  800ac5:	89 d6                	mov    %edx,%esi
  800ac7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ac9:	5b                   	pop    %ebx
  800aca:	5e                   	pop    %esi
  800acb:	5f                   	pop    %edi
  800acc:	5d                   	pop    %ebp
  800acd:	c3                   	ret    

00800ace <sys_yield>:

void
sys_yield(void)
{
  800ace:	55                   	push   %ebp
  800acf:	89 e5                	mov    %esp,%ebp
  800ad1:	57                   	push   %edi
  800ad2:	56                   	push   %esi
  800ad3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ade:	89 d1                	mov    %edx,%ecx
  800ae0:	89 d3                	mov    %edx,%ebx
  800ae2:	89 d7                	mov    %edx,%edi
  800ae4:	89 d6                	mov    %edx,%esi
  800ae6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ae8:	5b                   	pop    %ebx
  800ae9:	5e                   	pop    %esi
  800aea:	5f                   	pop    %edi
  800aeb:	5d                   	pop    %ebp
  800aec:	c3                   	ret    

00800aed <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	57                   	push   %edi
  800af1:	56                   	push   %esi
  800af2:	53                   	push   %ebx
  800af3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af6:	be 00 00 00 00       	mov    $0x0,%esi
  800afb:	b8 04 00 00 00       	mov    $0x4,%eax
  800b00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b03:	8b 55 08             	mov    0x8(%ebp),%edx
  800b06:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b09:	89 f7                	mov    %esi,%edi
  800b0b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b0d:	85 c0                	test   %eax,%eax
  800b0f:	7e 17                	jle    800b28 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b11:	83 ec 0c             	sub    $0xc,%esp
  800b14:	50                   	push   %eax
  800b15:	6a 04                	push   $0x4
  800b17:	68 df 24 80 00       	push   $0x8024df
  800b1c:	6a 23                	push   $0x23
  800b1e:	68 fc 24 80 00       	push   $0x8024fc
  800b23:	e8 d2 11 00 00       	call   801cfa <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b2b:	5b                   	pop    %ebx
  800b2c:	5e                   	pop    %esi
  800b2d:	5f                   	pop    %edi
  800b2e:	5d                   	pop    %ebp
  800b2f:	c3                   	ret    

00800b30 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800b39:	b8 05 00 00 00       	mov    $0x5,%eax
  800b3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b41:	8b 55 08             	mov    0x8(%ebp),%edx
  800b44:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b47:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b4a:	8b 75 18             	mov    0x18(%ebp),%esi
  800b4d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b4f:	85 c0                	test   %eax,%eax
  800b51:	7e 17                	jle    800b6a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b53:	83 ec 0c             	sub    $0xc,%esp
  800b56:	50                   	push   %eax
  800b57:	6a 05                	push   $0x5
  800b59:	68 df 24 80 00       	push   $0x8024df
  800b5e:	6a 23                	push   $0x23
  800b60:	68 fc 24 80 00       	push   $0x8024fc
  800b65:	e8 90 11 00 00       	call   801cfa <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6d:	5b                   	pop    %ebx
  800b6e:	5e                   	pop    %esi
  800b6f:	5f                   	pop    %edi
  800b70:	5d                   	pop    %ebp
  800b71:	c3                   	ret    

00800b72 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	57                   	push   %edi
  800b76:	56                   	push   %esi
  800b77:	53                   	push   %ebx
  800b78:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b80:	b8 06 00 00 00       	mov    $0x6,%eax
  800b85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b88:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8b:	89 df                	mov    %ebx,%edi
  800b8d:	89 de                	mov    %ebx,%esi
  800b8f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b91:	85 c0                	test   %eax,%eax
  800b93:	7e 17                	jle    800bac <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b95:	83 ec 0c             	sub    $0xc,%esp
  800b98:	50                   	push   %eax
  800b99:	6a 06                	push   $0x6
  800b9b:	68 df 24 80 00       	push   $0x8024df
  800ba0:	6a 23                	push   $0x23
  800ba2:	68 fc 24 80 00       	push   $0x8024fc
  800ba7:	e8 4e 11 00 00       	call   801cfa <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5f                   	pop    %edi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	57                   	push   %edi
  800bb8:	56                   	push   %esi
  800bb9:	53                   	push   %ebx
  800bba:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bc2:	b8 08 00 00 00       	mov    $0x8,%eax
  800bc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bca:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcd:	89 df                	mov    %ebx,%edi
  800bcf:	89 de                	mov    %ebx,%esi
  800bd1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd3:	85 c0                	test   %eax,%eax
  800bd5:	7e 17                	jle    800bee <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd7:	83 ec 0c             	sub    $0xc,%esp
  800bda:	50                   	push   %eax
  800bdb:	6a 08                	push   $0x8
  800bdd:	68 df 24 80 00       	push   $0x8024df
  800be2:	6a 23                	push   $0x23
  800be4:	68 fc 24 80 00       	push   $0x8024fc
  800be9:	e8 0c 11 00 00       	call   801cfa <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    

00800bf6 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	57                   	push   %edi
  800bfa:	56                   	push   %esi
  800bfb:	53                   	push   %ebx
  800bfc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bff:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c04:	b8 09 00 00 00       	mov    $0x9,%eax
  800c09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0f:	89 df                	mov    %ebx,%edi
  800c11:	89 de                	mov    %ebx,%esi
  800c13:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c15:	85 c0                	test   %eax,%eax
  800c17:	7e 17                	jle    800c30 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c19:	83 ec 0c             	sub    $0xc,%esp
  800c1c:	50                   	push   %eax
  800c1d:	6a 09                	push   $0x9
  800c1f:	68 df 24 80 00       	push   $0x8024df
  800c24:	6a 23                	push   $0x23
  800c26:	68 fc 24 80 00       	push   $0x8024fc
  800c2b:	e8 ca 10 00 00       	call   801cfa <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c33:	5b                   	pop    %ebx
  800c34:	5e                   	pop    %esi
  800c35:	5f                   	pop    %edi
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    

00800c38 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	57                   	push   %edi
  800c3c:	56                   	push   %esi
  800c3d:	53                   	push   %ebx
  800c3e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c41:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c46:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c51:	89 df                	mov    %ebx,%edi
  800c53:	89 de                	mov    %ebx,%esi
  800c55:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c57:	85 c0                	test   %eax,%eax
  800c59:	7e 17                	jle    800c72 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5b:	83 ec 0c             	sub    $0xc,%esp
  800c5e:	50                   	push   %eax
  800c5f:	6a 0a                	push   $0xa
  800c61:	68 df 24 80 00       	push   $0x8024df
  800c66:	6a 23                	push   $0x23
  800c68:	68 fc 24 80 00       	push   $0x8024fc
  800c6d:	e8 88 10 00 00       	call   801cfa <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	57                   	push   %edi
  800c7e:	56                   	push   %esi
  800c7f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c80:	be 00 00 00 00       	mov    $0x0,%esi
  800c85:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c90:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c93:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c96:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c98:	5b                   	pop    %ebx
  800c99:	5e                   	pop    %esi
  800c9a:	5f                   	pop    %edi
  800c9b:	5d                   	pop    %ebp
  800c9c:	c3                   	ret    

00800c9d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	57                   	push   %edi
  800ca1:	56                   	push   %esi
  800ca2:	53                   	push   %ebx
  800ca3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cab:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb3:	89 cb                	mov    %ecx,%ebx
  800cb5:	89 cf                	mov    %ecx,%edi
  800cb7:	89 ce                	mov    %ecx,%esi
  800cb9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbb:	85 c0                	test   %eax,%eax
  800cbd:	7e 17                	jle    800cd6 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbf:	83 ec 0c             	sub    $0xc,%esp
  800cc2:	50                   	push   %eax
  800cc3:	6a 0d                	push   $0xd
  800cc5:	68 df 24 80 00       	push   $0x8024df
  800cca:	6a 23                	push   $0x23
  800ccc:	68 fc 24 80 00       	push   $0x8024fc
  800cd1:	e8 24 10 00 00       	call   801cfa <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd9:	5b                   	pop    %ebx
  800cda:	5e                   	pop    %esi
  800cdb:	5f                   	pop    %edi
  800cdc:	5d                   	pop    %ebp
  800cdd:	c3                   	ret    

00800cde <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800cde:	55                   	push   %ebp
  800cdf:	89 e5                	mov    %esp,%ebp
  800ce1:	57                   	push   %edi
  800ce2:	56                   	push   %esi
  800ce3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce9:	b8 0e 00 00 00       	mov    $0xe,%eax
  800cee:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf1:	89 cb                	mov    %ecx,%ebx
  800cf3:	89 cf                	mov    %ecx,%edi
  800cf5:	89 ce                	mov    %ecx,%esi
  800cf7:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    

00800cfe <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d04:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d09:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d11:	89 cb                	mov    %ecx,%ebx
  800d13:	89 cf                	mov    %ecx,%edi
  800d15:	89 ce                	mov    %ecx,%esi
  800d17:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800d19:	5b                   	pop    %ebx
  800d1a:	5e                   	pop    %esi
  800d1b:	5f                   	pop    %edi
  800d1c:	5d                   	pop    %ebp
  800d1d:	c3                   	ret    

00800d1e <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	53                   	push   %ebx
  800d22:	83 ec 04             	sub    $0x4,%esp
  800d25:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d28:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800d2a:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d2e:	74 11                	je     800d41 <pgfault+0x23>
  800d30:	89 d8                	mov    %ebx,%eax
  800d32:	c1 e8 0c             	shr    $0xc,%eax
  800d35:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d3c:	f6 c4 08             	test   $0x8,%ah
  800d3f:	75 14                	jne    800d55 <pgfault+0x37>
		panic("faulting access");
  800d41:	83 ec 04             	sub    $0x4,%esp
  800d44:	68 0a 25 80 00       	push   $0x80250a
  800d49:	6a 1e                	push   $0x1e
  800d4b:	68 1a 25 80 00       	push   $0x80251a
  800d50:	e8 a5 0f 00 00       	call   801cfa <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800d55:	83 ec 04             	sub    $0x4,%esp
  800d58:	6a 07                	push   $0x7
  800d5a:	68 00 f0 7f 00       	push   $0x7ff000
  800d5f:	6a 00                	push   $0x0
  800d61:	e8 87 fd ff ff       	call   800aed <sys_page_alloc>
	if (r < 0) {
  800d66:	83 c4 10             	add    $0x10,%esp
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	79 12                	jns    800d7f <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800d6d:	50                   	push   %eax
  800d6e:	68 25 25 80 00       	push   $0x802525
  800d73:	6a 2c                	push   $0x2c
  800d75:	68 1a 25 80 00       	push   $0x80251a
  800d7a:	e8 7b 0f 00 00       	call   801cfa <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800d7f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800d85:	83 ec 04             	sub    $0x4,%esp
  800d88:	68 00 10 00 00       	push   $0x1000
  800d8d:	53                   	push   %ebx
  800d8e:	68 00 f0 7f 00       	push   $0x7ff000
  800d93:	e8 4c fb ff ff       	call   8008e4 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800d98:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800d9f:	53                   	push   %ebx
  800da0:	6a 00                	push   $0x0
  800da2:	68 00 f0 7f 00       	push   $0x7ff000
  800da7:	6a 00                	push   $0x0
  800da9:	e8 82 fd ff ff       	call   800b30 <sys_page_map>
	if (r < 0) {
  800dae:	83 c4 20             	add    $0x20,%esp
  800db1:	85 c0                	test   %eax,%eax
  800db3:	79 12                	jns    800dc7 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800db5:	50                   	push   %eax
  800db6:	68 25 25 80 00       	push   $0x802525
  800dbb:	6a 33                	push   $0x33
  800dbd:	68 1a 25 80 00       	push   $0x80251a
  800dc2:	e8 33 0f 00 00       	call   801cfa <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800dc7:	83 ec 08             	sub    $0x8,%esp
  800dca:	68 00 f0 7f 00       	push   $0x7ff000
  800dcf:	6a 00                	push   $0x0
  800dd1:	e8 9c fd ff ff       	call   800b72 <sys_page_unmap>
	if (r < 0) {
  800dd6:	83 c4 10             	add    $0x10,%esp
  800dd9:	85 c0                	test   %eax,%eax
  800ddb:	79 12                	jns    800def <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800ddd:	50                   	push   %eax
  800dde:	68 25 25 80 00       	push   $0x802525
  800de3:	6a 37                	push   $0x37
  800de5:	68 1a 25 80 00       	push   $0x80251a
  800dea:	e8 0b 0f 00 00       	call   801cfa <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800def:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800df2:	c9                   	leave  
  800df3:	c3                   	ret    

00800df4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	57                   	push   %edi
  800df8:	56                   	push   %esi
  800df9:	53                   	push   %ebx
  800dfa:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800dfd:	68 1e 0d 80 00       	push   $0x800d1e
  800e02:	e8 39 0f 00 00       	call   801d40 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e07:	b8 07 00 00 00       	mov    $0x7,%eax
  800e0c:	cd 30                	int    $0x30
  800e0e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800e11:	83 c4 10             	add    $0x10,%esp
  800e14:	85 c0                	test   %eax,%eax
  800e16:	79 17                	jns    800e2f <fork+0x3b>
		panic("fork fault %e");
  800e18:	83 ec 04             	sub    $0x4,%esp
  800e1b:	68 3e 25 80 00       	push   $0x80253e
  800e20:	68 84 00 00 00       	push   $0x84
  800e25:	68 1a 25 80 00       	push   $0x80251a
  800e2a:	e8 cb 0e 00 00       	call   801cfa <_panic>
  800e2f:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800e31:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e35:	75 25                	jne    800e5c <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e37:	e8 73 fc ff ff       	call   800aaf <sys_getenvid>
  800e3c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e41:	89 c2                	mov    %eax,%edx
  800e43:	c1 e2 07             	shl    $0x7,%edx
  800e46:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800e4d:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800e52:	b8 00 00 00 00       	mov    $0x0,%eax
  800e57:	e9 61 01 00 00       	jmp    800fbd <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800e5c:	83 ec 04             	sub    $0x4,%esp
  800e5f:	6a 07                	push   $0x7
  800e61:	68 00 f0 bf ee       	push   $0xeebff000
  800e66:	ff 75 e4             	pushl  -0x1c(%ebp)
  800e69:	e8 7f fc ff ff       	call   800aed <sys_page_alloc>
  800e6e:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800e71:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800e76:	89 d8                	mov    %ebx,%eax
  800e78:	c1 e8 16             	shr    $0x16,%eax
  800e7b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e82:	a8 01                	test   $0x1,%al
  800e84:	0f 84 fc 00 00 00    	je     800f86 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800e8a:	89 d8                	mov    %ebx,%eax
  800e8c:	c1 e8 0c             	shr    $0xc,%eax
  800e8f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800e96:	f6 c2 01             	test   $0x1,%dl
  800e99:	0f 84 e7 00 00 00    	je     800f86 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800e9f:	89 c6                	mov    %eax,%esi
  800ea1:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800ea4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800eab:	f6 c6 04             	test   $0x4,%dh
  800eae:	74 39                	je     800ee9 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800eb0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eb7:	83 ec 0c             	sub    $0xc,%esp
  800eba:	25 07 0e 00 00       	and    $0xe07,%eax
  800ebf:	50                   	push   %eax
  800ec0:	56                   	push   %esi
  800ec1:	57                   	push   %edi
  800ec2:	56                   	push   %esi
  800ec3:	6a 00                	push   $0x0
  800ec5:	e8 66 fc ff ff       	call   800b30 <sys_page_map>
		if (r < 0) {
  800eca:	83 c4 20             	add    $0x20,%esp
  800ecd:	85 c0                	test   %eax,%eax
  800ecf:	0f 89 b1 00 00 00    	jns    800f86 <fork+0x192>
		    	panic("sys page map fault %e");
  800ed5:	83 ec 04             	sub    $0x4,%esp
  800ed8:	68 4c 25 80 00       	push   $0x80254c
  800edd:	6a 54                	push   $0x54
  800edf:	68 1a 25 80 00       	push   $0x80251a
  800ee4:	e8 11 0e 00 00       	call   801cfa <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800ee9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ef0:	f6 c2 02             	test   $0x2,%dl
  800ef3:	75 0c                	jne    800f01 <fork+0x10d>
  800ef5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800efc:	f6 c4 08             	test   $0x8,%ah
  800eff:	74 5b                	je     800f5c <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f01:	83 ec 0c             	sub    $0xc,%esp
  800f04:	68 05 08 00 00       	push   $0x805
  800f09:	56                   	push   %esi
  800f0a:	57                   	push   %edi
  800f0b:	56                   	push   %esi
  800f0c:	6a 00                	push   $0x0
  800f0e:	e8 1d fc ff ff       	call   800b30 <sys_page_map>
		if (r < 0) {
  800f13:	83 c4 20             	add    $0x20,%esp
  800f16:	85 c0                	test   %eax,%eax
  800f18:	79 14                	jns    800f2e <fork+0x13a>
		    	panic("sys page map fault %e");
  800f1a:	83 ec 04             	sub    $0x4,%esp
  800f1d:	68 4c 25 80 00       	push   $0x80254c
  800f22:	6a 5b                	push   $0x5b
  800f24:	68 1a 25 80 00       	push   $0x80251a
  800f29:	e8 cc 0d 00 00       	call   801cfa <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800f2e:	83 ec 0c             	sub    $0xc,%esp
  800f31:	68 05 08 00 00       	push   $0x805
  800f36:	56                   	push   %esi
  800f37:	6a 00                	push   $0x0
  800f39:	56                   	push   %esi
  800f3a:	6a 00                	push   $0x0
  800f3c:	e8 ef fb ff ff       	call   800b30 <sys_page_map>
		if (r < 0) {
  800f41:	83 c4 20             	add    $0x20,%esp
  800f44:	85 c0                	test   %eax,%eax
  800f46:	79 3e                	jns    800f86 <fork+0x192>
		    	panic("sys page map fault %e");
  800f48:	83 ec 04             	sub    $0x4,%esp
  800f4b:	68 4c 25 80 00       	push   $0x80254c
  800f50:	6a 5f                	push   $0x5f
  800f52:	68 1a 25 80 00       	push   $0x80251a
  800f57:	e8 9e 0d 00 00       	call   801cfa <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800f5c:	83 ec 0c             	sub    $0xc,%esp
  800f5f:	6a 05                	push   $0x5
  800f61:	56                   	push   %esi
  800f62:	57                   	push   %edi
  800f63:	56                   	push   %esi
  800f64:	6a 00                	push   $0x0
  800f66:	e8 c5 fb ff ff       	call   800b30 <sys_page_map>
		if (r < 0) {
  800f6b:	83 c4 20             	add    $0x20,%esp
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	79 14                	jns    800f86 <fork+0x192>
		    	panic("sys page map fault %e");
  800f72:	83 ec 04             	sub    $0x4,%esp
  800f75:	68 4c 25 80 00       	push   $0x80254c
  800f7a:	6a 64                	push   $0x64
  800f7c:	68 1a 25 80 00       	push   $0x80251a
  800f81:	e8 74 0d 00 00       	call   801cfa <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f86:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f8c:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800f92:	0f 85 de fe ff ff    	jne    800e76 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800f98:	a1 04 40 80 00       	mov    0x804004,%eax
  800f9d:	8b 40 70             	mov    0x70(%eax),%eax
  800fa0:	83 ec 08             	sub    $0x8,%esp
  800fa3:	50                   	push   %eax
  800fa4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800fa7:	57                   	push   %edi
  800fa8:	e8 8b fc ff ff       	call   800c38 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  800fad:	83 c4 08             	add    $0x8,%esp
  800fb0:	6a 02                	push   $0x2
  800fb2:	57                   	push   %edi
  800fb3:	e8 fc fb ff ff       	call   800bb4 <sys_env_set_status>
	
	return envid;
  800fb8:	83 c4 10             	add    $0x10,%esp
  800fbb:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  800fbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc0:	5b                   	pop    %ebx
  800fc1:	5e                   	pop    %esi
  800fc2:	5f                   	pop    %edi
  800fc3:	5d                   	pop    %ebp
  800fc4:	c3                   	ret    

00800fc5 <sfork>:

envid_t
sfork(void)
{
  800fc5:	55                   	push   %ebp
  800fc6:	89 e5                	mov    %esp,%ebp
	return 0;
}
  800fc8:	b8 00 00 00 00       	mov    $0x0,%eax
  800fcd:	5d                   	pop    %ebp
  800fce:	c3                   	ret    

00800fcf <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
  800fd2:	56                   	push   %esi
  800fd3:	53                   	push   %ebx
  800fd4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  800fd7:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  800fdd:	83 ec 08             	sub    $0x8,%esp
  800fe0:	53                   	push   %ebx
  800fe1:	68 64 25 80 00       	push   $0x802564
  800fe6:	e8 7a f1 ff ff       	call   800165 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  800feb:	c7 04 24 98 00 80 00 	movl   $0x800098,(%esp)
  800ff2:	e8 e7 fc ff ff       	call   800cde <sys_thread_create>
  800ff7:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  800ff9:	83 c4 08             	add    $0x8,%esp
  800ffc:	53                   	push   %ebx
  800ffd:	68 64 25 80 00       	push   $0x802564
  801002:	e8 5e f1 ff ff       	call   800165 <cprintf>
	return id;
	//return 0;
}
  801007:	89 f0                	mov    %esi,%eax
  801009:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80100c:	5b                   	pop    %ebx
  80100d:	5e                   	pop    %esi
  80100e:	5d                   	pop    %ebp
  80100f:	c3                   	ret    

00801010 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801013:	8b 45 08             	mov    0x8(%ebp),%eax
  801016:	05 00 00 00 30       	add    $0x30000000,%eax
  80101b:	c1 e8 0c             	shr    $0xc,%eax
}
  80101e:	5d                   	pop    %ebp
  80101f:	c3                   	ret    

00801020 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801023:	8b 45 08             	mov    0x8(%ebp),%eax
  801026:	05 00 00 00 30       	add    $0x30000000,%eax
  80102b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801030:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801035:	5d                   	pop    %ebp
  801036:	c3                   	ret    

00801037 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801037:	55                   	push   %ebp
  801038:	89 e5                	mov    %esp,%ebp
  80103a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80103d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801042:	89 c2                	mov    %eax,%edx
  801044:	c1 ea 16             	shr    $0x16,%edx
  801047:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80104e:	f6 c2 01             	test   $0x1,%dl
  801051:	74 11                	je     801064 <fd_alloc+0x2d>
  801053:	89 c2                	mov    %eax,%edx
  801055:	c1 ea 0c             	shr    $0xc,%edx
  801058:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80105f:	f6 c2 01             	test   $0x1,%dl
  801062:	75 09                	jne    80106d <fd_alloc+0x36>
			*fd_store = fd;
  801064:	89 01                	mov    %eax,(%ecx)
			return 0;
  801066:	b8 00 00 00 00       	mov    $0x0,%eax
  80106b:	eb 17                	jmp    801084 <fd_alloc+0x4d>
  80106d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801072:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801077:	75 c9                	jne    801042 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801079:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80107f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801084:	5d                   	pop    %ebp
  801085:	c3                   	ret    

00801086 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801086:	55                   	push   %ebp
  801087:	89 e5                	mov    %esp,%ebp
  801089:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80108c:	83 f8 1f             	cmp    $0x1f,%eax
  80108f:	77 36                	ja     8010c7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801091:	c1 e0 0c             	shl    $0xc,%eax
  801094:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801099:	89 c2                	mov    %eax,%edx
  80109b:	c1 ea 16             	shr    $0x16,%edx
  80109e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010a5:	f6 c2 01             	test   $0x1,%dl
  8010a8:	74 24                	je     8010ce <fd_lookup+0x48>
  8010aa:	89 c2                	mov    %eax,%edx
  8010ac:	c1 ea 0c             	shr    $0xc,%edx
  8010af:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010b6:	f6 c2 01             	test   $0x1,%dl
  8010b9:	74 1a                	je     8010d5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010be:	89 02                	mov    %eax,(%edx)
	return 0;
  8010c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c5:	eb 13                	jmp    8010da <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010cc:	eb 0c                	jmp    8010da <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010d3:	eb 05                	jmp    8010da <fd_lookup+0x54>
  8010d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010da:	5d                   	pop    %ebp
  8010db:	c3                   	ret    

008010dc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	83 ec 08             	sub    $0x8,%esp
  8010e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010e5:	ba 04 26 80 00       	mov    $0x802604,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8010ea:	eb 13                	jmp    8010ff <dev_lookup+0x23>
  8010ec:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8010ef:	39 08                	cmp    %ecx,(%eax)
  8010f1:	75 0c                	jne    8010ff <dev_lookup+0x23>
			*dev = devtab[i];
  8010f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010fd:	eb 2e                	jmp    80112d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8010ff:	8b 02                	mov    (%edx),%eax
  801101:	85 c0                	test   %eax,%eax
  801103:	75 e7                	jne    8010ec <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801105:	a1 04 40 80 00       	mov    0x804004,%eax
  80110a:	8b 40 54             	mov    0x54(%eax),%eax
  80110d:	83 ec 04             	sub    $0x4,%esp
  801110:	51                   	push   %ecx
  801111:	50                   	push   %eax
  801112:	68 88 25 80 00       	push   $0x802588
  801117:	e8 49 f0 ff ff       	call   800165 <cprintf>
	*dev = 0;
  80111c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80111f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801125:	83 c4 10             	add    $0x10,%esp
  801128:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80112d:	c9                   	leave  
  80112e:	c3                   	ret    

0080112f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80112f:	55                   	push   %ebp
  801130:	89 e5                	mov    %esp,%ebp
  801132:	56                   	push   %esi
  801133:	53                   	push   %ebx
  801134:	83 ec 10             	sub    $0x10,%esp
  801137:	8b 75 08             	mov    0x8(%ebp),%esi
  80113a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80113d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801140:	50                   	push   %eax
  801141:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801147:	c1 e8 0c             	shr    $0xc,%eax
  80114a:	50                   	push   %eax
  80114b:	e8 36 ff ff ff       	call   801086 <fd_lookup>
  801150:	83 c4 08             	add    $0x8,%esp
  801153:	85 c0                	test   %eax,%eax
  801155:	78 05                	js     80115c <fd_close+0x2d>
	    || fd != fd2)
  801157:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80115a:	74 0c                	je     801168 <fd_close+0x39>
		return (must_exist ? r : 0);
  80115c:	84 db                	test   %bl,%bl
  80115e:	ba 00 00 00 00       	mov    $0x0,%edx
  801163:	0f 44 c2             	cmove  %edx,%eax
  801166:	eb 41                	jmp    8011a9 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801168:	83 ec 08             	sub    $0x8,%esp
  80116b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80116e:	50                   	push   %eax
  80116f:	ff 36                	pushl  (%esi)
  801171:	e8 66 ff ff ff       	call   8010dc <dev_lookup>
  801176:	89 c3                	mov    %eax,%ebx
  801178:	83 c4 10             	add    $0x10,%esp
  80117b:	85 c0                	test   %eax,%eax
  80117d:	78 1a                	js     801199 <fd_close+0x6a>
		if (dev->dev_close)
  80117f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801182:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801185:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80118a:	85 c0                	test   %eax,%eax
  80118c:	74 0b                	je     801199 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80118e:	83 ec 0c             	sub    $0xc,%esp
  801191:	56                   	push   %esi
  801192:	ff d0                	call   *%eax
  801194:	89 c3                	mov    %eax,%ebx
  801196:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801199:	83 ec 08             	sub    $0x8,%esp
  80119c:	56                   	push   %esi
  80119d:	6a 00                	push   $0x0
  80119f:	e8 ce f9 ff ff       	call   800b72 <sys_page_unmap>
	return r;
  8011a4:	83 c4 10             	add    $0x10,%esp
  8011a7:	89 d8                	mov    %ebx,%eax
}
  8011a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011ac:	5b                   	pop    %ebx
  8011ad:	5e                   	pop    %esi
  8011ae:	5d                   	pop    %ebp
  8011af:	c3                   	ret    

008011b0 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011b0:	55                   	push   %ebp
  8011b1:	89 e5                	mov    %esp,%ebp
  8011b3:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b9:	50                   	push   %eax
  8011ba:	ff 75 08             	pushl  0x8(%ebp)
  8011bd:	e8 c4 fe ff ff       	call   801086 <fd_lookup>
  8011c2:	83 c4 08             	add    $0x8,%esp
  8011c5:	85 c0                	test   %eax,%eax
  8011c7:	78 10                	js     8011d9 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8011c9:	83 ec 08             	sub    $0x8,%esp
  8011cc:	6a 01                	push   $0x1
  8011ce:	ff 75 f4             	pushl  -0xc(%ebp)
  8011d1:	e8 59 ff ff ff       	call   80112f <fd_close>
  8011d6:	83 c4 10             	add    $0x10,%esp
}
  8011d9:	c9                   	leave  
  8011da:	c3                   	ret    

008011db <close_all>:

void
close_all(void)
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
  8011de:	53                   	push   %ebx
  8011df:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011e2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011e7:	83 ec 0c             	sub    $0xc,%esp
  8011ea:	53                   	push   %ebx
  8011eb:	e8 c0 ff ff ff       	call   8011b0 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8011f0:	83 c3 01             	add    $0x1,%ebx
  8011f3:	83 c4 10             	add    $0x10,%esp
  8011f6:	83 fb 20             	cmp    $0x20,%ebx
  8011f9:	75 ec                	jne    8011e7 <close_all+0xc>
		close(i);
}
  8011fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011fe:	c9                   	leave  
  8011ff:	c3                   	ret    

00801200 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801200:	55                   	push   %ebp
  801201:	89 e5                	mov    %esp,%ebp
  801203:	57                   	push   %edi
  801204:	56                   	push   %esi
  801205:	53                   	push   %ebx
  801206:	83 ec 2c             	sub    $0x2c,%esp
  801209:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80120c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80120f:	50                   	push   %eax
  801210:	ff 75 08             	pushl  0x8(%ebp)
  801213:	e8 6e fe ff ff       	call   801086 <fd_lookup>
  801218:	83 c4 08             	add    $0x8,%esp
  80121b:	85 c0                	test   %eax,%eax
  80121d:	0f 88 c1 00 00 00    	js     8012e4 <dup+0xe4>
		return r;
	close(newfdnum);
  801223:	83 ec 0c             	sub    $0xc,%esp
  801226:	56                   	push   %esi
  801227:	e8 84 ff ff ff       	call   8011b0 <close>

	newfd = INDEX2FD(newfdnum);
  80122c:	89 f3                	mov    %esi,%ebx
  80122e:	c1 e3 0c             	shl    $0xc,%ebx
  801231:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801237:	83 c4 04             	add    $0x4,%esp
  80123a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80123d:	e8 de fd ff ff       	call   801020 <fd2data>
  801242:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801244:	89 1c 24             	mov    %ebx,(%esp)
  801247:	e8 d4 fd ff ff       	call   801020 <fd2data>
  80124c:	83 c4 10             	add    $0x10,%esp
  80124f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801252:	89 f8                	mov    %edi,%eax
  801254:	c1 e8 16             	shr    $0x16,%eax
  801257:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80125e:	a8 01                	test   $0x1,%al
  801260:	74 37                	je     801299 <dup+0x99>
  801262:	89 f8                	mov    %edi,%eax
  801264:	c1 e8 0c             	shr    $0xc,%eax
  801267:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80126e:	f6 c2 01             	test   $0x1,%dl
  801271:	74 26                	je     801299 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801273:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80127a:	83 ec 0c             	sub    $0xc,%esp
  80127d:	25 07 0e 00 00       	and    $0xe07,%eax
  801282:	50                   	push   %eax
  801283:	ff 75 d4             	pushl  -0x2c(%ebp)
  801286:	6a 00                	push   $0x0
  801288:	57                   	push   %edi
  801289:	6a 00                	push   $0x0
  80128b:	e8 a0 f8 ff ff       	call   800b30 <sys_page_map>
  801290:	89 c7                	mov    %eax,%edi
  801292:	83 c4 20             	add    $0x20,%esp
  801295:	85 c0                	test   %eax,%eax
  801297:	78 2e                	js     8012c7 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801299:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80129c:	89 d0                	mov    %edx,%eax
  80129e:	c1 e8 0c             	shr    $0xc,%eax
  8012a1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012a8:	83 ec 0c             	sub    $0xc,%esp
  8012ab:	25 07 0e 00 00       	and    $0xe07,%eax
  8012b0:	50                   	push   %eax
  8012b1:	53                   	push   %ebx
  8012b2:	6a 00                	push   $0x0
  8012b4:	52                   	push   %edx
  8012b5:	6a 00                	push   $0x0
  8012b7:	e8 74 f8 ff ff       	call   800b30 <sys_page_map>
  8012bc:	89 c7                	mov    %eax,%edi
  8012be:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8012c1:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012c3:	85 ff                	test   %edi,%edi
  8012c5:	79 1d                	jns    8012e4 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012c7:	83 ec 08             	sub    $0x8,%esp
  8012ca:	53                   	push   %ebx
  8012cb:	6a 00                	push   $0x0
  8012cd:	e8 a0 f8 ff ff       	call   800b72 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012d2:	83 c4 08             	add    $0x8,%esp
  8012d5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012d8:	6a 00                	push   $0x0
  8012da:	e8 93 f8 ff ff       	call   800b72 <sys_page_unmap>
	return r;
  8012df:	83 c4 10             	add    $0x10,%esp
  8012e2:	89 f8                	mov    %edi,%eax
}
  8012e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012e7:	5b                   	pop    %ebx
  8012e8:	5e                   	pop    %esi
  8012e9:	5f                   	pop    %edi
  8012ea:	5d                   	pop    %ebp
  8012eb:	c3                   	ret    

008012ec <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012ec:	55                   	push   %ebp
  8012ed:	89 e5                	mov    %esp,%ebp
  8012ef:	53                   	push   %ebx
  8012f0:	83 ec 14             	sub    $0x14,%esp
  8012f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f9:	50                   	push   %eax
  8012fa:	53                   	push   %ebx
  8012fb:	e8 86 fd ff ff       	call   801086 <fd_lookup>
  801300:	83 c4 08             	add    $0x8,%esp
  801303:	89 c2                	mov    %eax,%edx
  801305:	85 c0                	test   %eax,%eax
  801307:	78 6d                	js     801376 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801309:	83 ec 08             	sub    $0x8,%esp
  80130c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130f:	50                   	push   %eax
  801310:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801313:	ff 30                	pushl  (%eax)
  801315:	e8 c2 fd ff ff       	call   8010dc <dev_lookup>
  80131a:	83 c4 10             	add    $0x10,%esp
  80131d:	85 c0                	test   %eax,%eax
  80131f:	78 4c                	js     80136d <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801321:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801324:	8b 42 08             	mov    0x8(%edx),%eax
  801327:	83 e0 03             	and    $0x3,%eax
  80132a:	83 f8 01             	cmp    $0x1,%eax
  80132d:	75 21                	jne    801350 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80132f:	a1 04 40 80 00       	mov    0x804004,%eax
  801334:	8b 40 54             	mov    0x54(%eax),%eax
  801337:	83 ec 04             	sub    $0x4,%esp
  80133a:	53                   	push   %ebx
  80133b:	50                   	push   %eax
  80133c:	68 c9 25 80 00       	push   $0x8025c9
  801341:	e8 1f ee ff ff       	call   800165 <cprintf>
		return -E_INVAL;
  801346:	83 c4 10             	add    $0x10,%esp
  801349:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80134e:	eb 26                	jmp    801376 <read+0x8a>
	}
	if (!dev->dev_read)
  801350:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801353:	8b 40 08             	mov    0x8(%eax),%eax
  801356:	85 c0                	test   %eax,%eax
  801358:	74 17                	je     801371 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80135a:	83 ec 04             	sub    $0x4,%esp
  80135d:	ff 75 10             	pushl  0x10(%ebp)
  801360:	ff 75 0c             	pushl  0xc(%ebp)
  801363:	52                   	push   %edx
  801364:	ff d0                	call   *%eax
  801366:	89 c2                	mov    %eax,%edx
  801368:	83 c4 10             	add    $0x10,%esp
  80136b:	eb 09                	jmp    801376 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80136d:	89 c2                	mov    %eax,%edx
  80136f:	eb 05                	jmp    801376 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801371:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801376:	89 d0                	mov    %edx,%eax
  801378:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137b:	c9                   	leave  
  80137c:	c3                   	ret    

0080137d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80137d:	55                   	push   %ebp
  80137e:	89 e5                	mov    %esp,%ebp
  801380:	57                   	push   %edi
  801381:	56                   	push   %esi
  801382:	53                   	push   %ebx
  801383:	83 ec 0c             	sub    $0xc,%esp
  801386:	8b 7d 08             	mov    0x8(%ebp),%edi
  801389:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80138c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801391:	eb 21                	jmp    8013b4 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801393:	83 ec 04             	sub    $0x4,%esp
  801396:	89 f0                	mov    %esi,%eax
  801398:	29 d8                	sub    %ebx,%eax
  80139a:	50                   	push   %eax
  80139b:	89 d8                	mov    %ebx,%eax
  80139d:	03 45 0c             	add    0xc(%ebp),%eax
  8013a0:	50                   	push   %eax
  8013a1:	57                   	push   %edi
  8013a2:	e8 45 ff ff ff       	call   8012ec <read>
		if (m < 0)
  8013a7:	83 c4 10             	add    $0x10,%esp
  8013aa:	85 c0                	test   %eax,%eax
  8013ac:	78 10                	js     8013be <readn+0x41>
			return m;
		if (m == 0)
  8013ae:	85 c0                	test   %eax,%eax
  8013b0:	74 0a                	je     8013bc <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013b2:	01 c3                	add    %eax,%ebx
  8013b4:	39 f3                	cmp    %esi,%ebx
  8013b6:	72 db                	jb     801393 <readn+0x16>
  8013b8:	89 d8                	mov    %ebx,%eax
  8013ba:	eb 02                	jmp    8013be <readn+0x41>
  8013bc:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c1:	5b                   	pop    %ebx
  8013c2:	5e                   	pop    %esi
  8013c3:	5f                   	pop    %edi
  8013c4:	5d                   	pop    %ebp
  8013c5:	c3                   	ret    

008013c6 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013c6:	55                   	push   %ebp
  8013c7:	89 e5                	mov    %esp,%ebp
  8013c9:	53                   	push   %ebx
  8013ca:	83 ec 14             	sub    $0x14,%esp
  8013cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013d3:	50                   	push   %eax
  8013d4:	53                   	push   %ebx
  8013d5:	e8 ac fc ff ff       	call   801086 <fd_lookup>
  8013da:	83 c4 08             	add    $0x8,%esp
  8013dd:	89 c2                	mov    %eax,%edx
  8013df:	85 c0                	test   %eax,%eax
  8013e1:	78 68                	js     80144b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e3:	83 ec 08             	sub    $0x8,%esp
  8013e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e9:	50                   	push   %eax
  8013ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ed:	ff 30                	pushl  (%eax)
  8013ef:	e8 e8 fc ff ff       	call   8010dc <dev_lookup>
  8013f4:	83 c4 10             	add    $0x10,%esp
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	78 47                	js     801442 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013fe:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801402:	75 21                	jne    801425 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801404:	a1 04 40 80 00       	mov    0x804004,%eax
  801409:	8b 40 54             	mov    0x54(%eax),%eax
  80140c:	83 ec 04             	sub    $0x4,%esp
  80140f:	53                   	push   %ebx
  801410:	50                   	push   %eax
  801411:	68 e5 25 80 00       	push   $0x8025e5
  801416:	e8 4a ed ff ff       	call   800165 <cprintf>
		return -E_INVAL;
  80141b:	83 c4 10             	add    $0x10,%esp
  80141e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801423:	eb 26                	jmp    80144b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801425:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801428:	8b 52 0c             	mov    0xc(%edx),%edx
  80142b:	85 d2                	test   %edx,%edx
  80142d:	74 17                	je     801446 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80142f:	83 ec 04             	sub    $0x4,%esp
  801432:	ff 75 10             	pushl  0x10(%ebp)
  801435:	ff 75 0c             	pushl  0xc(%ebp)
  801438:	50                   	push   %eax
  801439:	ff d2                	call   *%edx
  80143b:	89 c2                	mov    %eax,%edx
  80143d:	83 c4 10             	add    $0x10,%esp
  801440:	eb 09                	jmp    80144b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801442:	89 c2                	mov    %eax,%edx
  801444:	eb 05                	jmp    80144b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801446:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80144b:	89 d0                	mov    %edx,%eax
  80144d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801450:	c9                   	leave  
  801451:	c3                   	ret    

00801452 <seek>:

int
seek(int fdnum, off_t offset)
{
  801452:	55                   	push   %ebp
  801453:	89 e5                	mov    %esp,%ebp
  801455:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801458:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80145b:	50                   	push   %eax
  80145c:	ff 75 08             	pushl  0x8(%ebp)
  80145f:	e8 22 fc ff ff       	call   801086 <fd_lookup>
  801464:	83 c4 08             	add    $0x8,%esp
  801467:	85 c0                	test   %eax,%eax
  801469:	78 0e                	js     801479 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80146b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80146e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801471:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801474:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801479:	c9                   	leave  
  80147a:	c3                   	ret    

0080147b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
  80147e:	53                   	push   %ebx
  80147f:	83 ec 14             	sub    $0x14,%esp
  801482:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801485:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801488:	50                   	push   %eax
  801489:	53                   	push   %ebx
  80148a:	e8 f7 fb ff ff       	call   801086 <fd_lookup>
  80148f:	83 c4 08             	add    $0x8,%esp
  801492:	89 c2                	mov    %eax,%edx
  801494:	85 c0                	test   %eax,%eax
  801496:	78 65                	js     8014fd <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801498:	83 ec 08             	sub    $0x8,%esp
  80149b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80149e:	50                   	push   %eax
  80149f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a2:	ff 30                	pushl  (%eax)
  8014a4:	e8 33 fc ff ff       	call   8010dc <dev_lookup>
  8014a9:	83 c4 10             	add    $0x10,%esp
  8014ac:	85 c0                	test   %eax,%eax
  8014ae:	78 44                	js     8014f4 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014b7:	75 21                	jne    8014da <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014b9:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014be:	8b 40 54             	mov    0x54(%eax),%eax
  8014c1:	83 ec 04             	sub    $0x4,%esp
  8014c4:	53                   	push   %ebx
  8014c5:	50                   	push   %eax
  8014c6:	68 a8 25 80 00       	push   $0x8025a8
  8014cb:	e8 95 ec ff ff       	call   800165 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014d0:	83 c4 10             	add    $0x10,%esp
  8014d3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014d8:	eb 23                	jmp    8014fd <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8014da:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014dd:	8b 52 18             	mov    0x18(%edx),%edx
  8014e0:	85 d2                	test   %edx,%edx
  8014e2:	74 14                	je     8014f8 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014e4:	83 ec 08             	sub    $0x8,%esp
  8014e7:	ff 75 0c             	pushl  0xc(%ebp)
  8014ea:	50                   	push   %eax
  8014eb:	ff d2                	call   *%edx
  8014ed:	89 c2                	mov    %eax,%edx
  8014ef:	83 c4 10             	add    $0x10,%esp
  8014f2:	eb 09                	jmp    8014fd <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f4:	89 c2                	mov    %eax,%edx
  8014f6:	eb 05                	jmp    8014fd <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8014f8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8014fd:	89 d0                	mov    %edx,%eax
  8014ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801502:	c9                   	leave  
  801503:	c3                   	ret    

00801504 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801504:	55                   	push   %ebp
  801505:	89 e5                	mov    %esp,%ebp
  801507:	53                   	push   %ebx
  801508:	83 ec 14             	sub    $0x14,%esp
  80150b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80150e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801511:	50                   	push   %eax
  801512:	ff 75 08             	pushl  0x8(%ebp)
  801515:	e8 6c fb ff ff       	call   801086 <fd_lookup>
  80151a:	83 c4 08             	add    $0x8,%esp
  80151d:	89 c2                	mov    %eax,%edx
  80151f:	85 c0                	test   %eax,%eax
  801521:	78 58                	js     80157b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801523:	83 ec 08             	sub    $0x8,%esp
  801526:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801529:	50                   	push   %eax
  80152a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152d:	ff 30                	pushl  (%eax)
  80152f:	e8 a8 fb ff ff       	call   8010dc <dev_lookup>
  801534:	83 c4 10             	add    $0x10,%esp
  801537:	85 c0                	test   %eax,%eax
  801539:	78 37                	js     801572 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80153b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80153e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801542:	74 32                	je     801576 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801544:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801547:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80154e:	00 00 00 
	stat->st_isdir = 0;
  801551:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801558:	00 00 00 
	stat->st_dev = dev;
  80155b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801561:	83 ec 08             	sub    $0x8,%esp
  801564:	53                   	push   %ebx
  801565:	ff 75 f0             	pushl  -0x10(%ebp)
  801568:	ff 50 14             	call   *0x14(%eax)
  80156b:	89 c2                	mov    %eax,%edx
  80156d:	83 c4 10             	add    $0x10,%esp
  801570:	eb 09                	jmp    80157b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801572:	89 c2                	mov    %eax,%edx
  801574:	eb 05                	jmp    80157b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801576:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80157b:	89 d0                	mov    %edx,%eax
  80157d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801580:	c9                   	leave  
  801581:	c3                   	ret    

00801582 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801582:	55                   	push   %ebp
  801583:	89 e5                	mov    %esp,%ebp
  801585:	56                   	push   %esi
  801586:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801587:	83 ec 08             	sub    $0x8,%esp
  80158a:	6a 00                	push   $0x0
  80158c:	ff 75 08             	pushl  0x8(%ebp)
  80158f:	e8 e3 01 00 00       	call   801777 <open>
  801594:	89 c3                	mov    %eax,%ebx
  801596:	83 c4 10             	add    $0x10,%esp
  801599:	85 c0                	test   %eax,%eax
  80159b:	78 1b                	js     8015b8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80159d:	83 ec 08             	sub    $0x8,%esp
  8015a0:	ff 75 0c             	pushl  0xc(%ebp)
  8015a3:	50                   	push   %eax
  8015a4:	e8 5b ff ff ff       	call   801504 <fstat>
  8015a9:	89 c6                	mov    %eax,%esi
	close(fd);
  8015ab:	89 1c 24             	mov    %ebx,(%esp)
  8015ae:	e8 fd fb ff ff       	call   8011b0 <close>
	return r;
  8015b3:	83 c4 10             	add    $0x10,%esp
  8015b6:	89 f0                	mov    %esi,%eax
}
  8015b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015bb:	5b                   	pop    %ebx
  8015bc:	5e                   	pop    %esi
  8015bd:	5d                   	pop    %ebp
  8015be:	c3                   	ret    

008015bf <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015bf:	55                   	push   %ebp
  8015c0:	89 e5                	mov    %esp,%ebp
  8015c2:	56                   	push   %esi
  8015c3:	53                   	push   %ebx
  8015c4:	89 c6                	mov    %eax,%esi
  8015c6:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015c8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015cf:	75 12                	jne    8015e3 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015d1:	83 ec 0c             	sub    $0xc,%esp
  8015d4:	6a 01                	push   $0x1
  8015d6:	e8 ce 08 00 00       	call   801ea9 <ipc_find_env>
  8015db:	a3 00 40 80 00       	mov    %eax,0x804000
  8015e0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015e3:	6a 07                	push   $0x7
  8015e5:	68 00 50 80 00       	push   $0x805000
  8015ea:	56                   	push   %esi
  8015eb:	ff 35 00 40 80 00    	pushl  0x804000
  8015f1:	e8 51 08 00 00       	call   801e47 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8015f6:	83 c4 0c             	add    $0xc,%esp
  8015f9:	6a 00                	push   $0x0
  8015fb:	53                   	push   %ebx
  8015fc:	6a 00                	push   $0x0
  8015fe:	e8 cc 07 00 00       	call   801dcf <ipc_recv>
}
  801603:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801606:	5b                   	pop    %ebx
  801607:	5e                   	pop    %esi
  801608:	5d                   	pop    %ebp
  801609:	c3                   	ret    

0080160a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801610:	8b 45 08             	mov    0x8(%ebp),%eax
  801613:	8b 40 0c             	mov    0xc(%eax),%eax
  801616:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80161b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80161e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801623:	ba 00 00 00 00       	mov    $0x0,%edx
  801628:	b8 02 00 00 00       	mov    $0x2,%eax
  80162d:	e8 8d ff ff ff       	call   8015bf <fsipc>
}
  801632:	c9                   	leave  
  801633:	c3                   	ret    

00801634 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801634:	55                   	push   %ebp
  801635:	89 e5                	mov    %esp,%ebp
  801637:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80163a:	8b 45 08             	mov    0x8(%ebp),%eax
  80163d:	8b 40 0c             	mov    0xc(%eax),%eax
  801640:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801645:	ba 00 00 00 00       	mov    $0x0,%edx
  80164a:	b8 06 00 00 00       	mov    $0x6,%eax
  80164f:	e8 6b ff ff ff       	call   8015bf <fsipc>
}
  801654:	c9                   	leave  
  801655:	c3                   	ret    

00801656 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801656:	55                   	push   %ebp
  801657:	89 e5                	mov    %esp,%ebp
  801659:	53                   	push   %ebx
  80165a:	83 ec 04             	sub    $0x4,%esp
  80165d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801660:	8b 45 08             	mov    0x8(%ebp),%eax
  801663:	8b 40 0c             	mov    0xc(%eax),%eax
  801666:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80166b:	ba 00 00 00 00       	mov    $0x0,%edx
  801670:	b8 05 00 00 00       	mov    $0x5,%eax
  801675:	e8 45 ff ff ff       	call   8015bf <fsipc>
  80167a:	85 c0                	test   %eax,%eax
  80167c:	78 2c                	js     8016aa <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80167e:	83 ec 08             	sub    $0x8,%esp
  801681:	68 00 50 80 00       	push   $0x805000
  801686:	53                   	push   %ebx
  801687:	e8 5e f0 ff ff       	call   8006ea <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80168c:	a1 80 50 80 00       	mov    0x805080,%eax
  801691:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801697:	a1 84 50 80 00       	mov    0x805084,%eax
  80169c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016a2:	83 c4 10             	add    $0x10,%esp
  8016a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ad:	c9                   	leave  
  8016ae:	c3                   	ret    

008016af <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016af:	55                   	push   %ebp
  8016b0:	89 e5                	mov    %esp,%ebp
  8016b2:	83 ec 0c             	sub    $0xc,%esp
  8016b5:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8016bb:	8b 52 0c             	mov    0xc(%edx),%edx
  8016be:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8016c4:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8016c9:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8016ce:	0f 47 c2             	cmova  %edx,%eax
  8016d1:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8016d6:	50                   	push   %eax
  8016d7:	ff 75 0c             	pushl  0xc(%ebp)
  8016da:	68 08 50 80 00       	push   $0x805008
  8016df:	e8 98 f1 ff ff       	call   80087c <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8016e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e9:	b8 04 00 00 00       	mov    $0x4,%eax
  8016ee:	e8 cc fe ff ff       	call   8015bf <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8016f3:	c9                   	leave  
  8016f4:	c3                   	ret    

008016f5 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8016f5:	55                   	push   %ebp
  8016f6:	89 e5                	mov    %esp,%ebp
  8016f8:	56                   	push   %esi
  8016f9:	53                   	push   %ebx
  8016fa:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801700:	8b 40 0c             	mov    0xc(%eax),%eax
  801703:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801708:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80170e:	ba 00 00 00 00       	mov    $0x0,%edx
  801713:	b8 03 00 00 00       	mov    $0x3,%eax
  801718:	e8 a2 fe ff ff       	call   8015bf <fsipc>
  80171d:	89 c3                	mov    %eax,%ebx
  80171f:	85 c0                	test   %eax,%eax
  801721:	78 4b                	js     80176e <devfile_read+0x79>
		return r;
	assert(r <= n);
  801723:	39 c6                	cmp    %eax,%esi
  801725:	73 16                	jae    80173d <devfile_read+0x48>
  801727:	68 14 26 80 00       	push   $0x802614
  80172c:	68 1b 26 80 00       	push   $0x80261b
  801731:	6a 7c                	push   $0x7c
  801733:	68 30 26 80 00       	push   $0x802630
  801738:	e8 bd 05 00 00       	call   801cfa <_panic>
	assert(r <= PGSIZE);
  80173d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801742:	7e 16                	jle    80175a <devfile_read+0x65>
  801744:	68 3b 26 80 00       	push   $0x80263b
  801749:	68 1b 26 80 00       	push   $0x80261b
  80174e:	6a 7d                	push   $0x7d
  801750:	68 30 26 80 00       	push   $0x802630
  801755:	e8 a0 05 00 00       	call   801cfa <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80175a:	83 ec 04             	sub    $0x4,%esp
  80175d:	50                   	push   %eax
  80175e:	68 00 50 80 00       	push   $0x805000
  801763:	ff 75 0c             	pushl  0xc(%ebp)
  801766:	e8 11 f1 ff ff       	call   80087c <memmove>
	return r;
  80176b:	83 c4 10             	add    $0x10,%esp
}
  80176e:	89 d8                	mov    %ebx,%eax
  801770:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801773:	5b                   	pop    %ebx
  801774:	5e                   	pop    %esi
  801775:	5d                   	pop    %ebp
  801776:	c3                   	ret    

00801777 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801777:	55                   	push   %ebp
  801778:	89 e5                	mov    %esp,%ebp
  80177a:	53                   	push   %ebx
  80177b:	83 ec 20             	sub    $0x20,%esp
  80177e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801781:	53                   	push   %ebx
  801782:	e8 2a ef ff ff       	call   8006b1 <strlen>
  801787:	83 c4 10             	add    $0x10,%esp
  80178a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80178f:	7f 67                	jg     8017f8 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801791:	83 ec 0c             	sub    $0xc,%esp
  801794:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801797:	50                   	push   %eax
  801798:	e8 9a f8 ff ff       	call   801037 <fd_alloc>
  80179d:	83 c4 10             	add    $0x10,%esp
		return r;
  8017a0:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017a2:	85 c0                	test   %eax,%eax
  8017a4:	78 57                	js     8017fd <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017a6:	83 ec 08             	sub    $0x8,%esp
  8017a9:	53                   	push   %ebx
  8017aa:	68 00 50 80 00       	push   $0x805000
  8017af:	e8 36 ef ff ff       	call   8006ea <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b7:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017bf:	b8 01 00 00 00       	mov    $0x1,%eax
  8017c4:	e8 f6 fd ff ff       	call   8015bf <fsipc>
  8017c9:	89 c3                	mov    %eax,%ebx
  8017cb:	83 c4 10             	add    $0x10,%esp
  8017ce:	85 c0                	test   %eax,%eax
  8017d0:	79 14                	jns    8017e6 <open+0x6f>
		fd_close(fd, 0);
  8017d2:	83 ec 08             	sub    $0x8,%esp
  8017d5:	6a 00                	push   $0x0
  8017d7:	ff 75 f4             	pushl  -0xc(%ebp)
  8017da:	e8 50 f9 ff ff       	call   80112f <fd_close>
		return r;
  8017df:	83 c4 10             	add    $0x10,%esp
  8017e2:	89 da                	mov    %ebx,%edx
  8017e4:	eb 17                	jmp    8017fd <open+0x86>
	}

	return fd2num(fd);
  8017e6:	83 ec 0c             	sub    $0xc,%esp
  8017e9:	ff 75 f4             	pushl  -0xc(%ebp)
  8017ec:	e8 1f f8 ff ff       	call   801010 <fd2num>
  8017f1:	89 c2                	mov    %eax,%edx
  8017f3:	83 c4 10             	add    $0x10,%esp
  8017f6:	eb 05                	jmp    8017fd <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8017f8:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8017fd:	89 d0                	mov    %edx,%eax
  8017ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801802:	c9                   	leave  
  801803:	c3                   	ret    

00801804 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801804:	55                   	push   %ebp
  801805:	89 e5                	mov    %esp,%ebp
  801807:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80180a:	ba 00 00 00 00       	mov    $0x0,%edx
  80180f:	b8 08 00 00 00       	mov    $0x8,%eax
  801814:	e8 a6 fd ff ff       	call   8015bf <fsipc>
}
  801819:	c9                   	leave  
  80181a:	c3                   	ret    

0080181b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80181b:	55                   	push   %ebp
  80181c:	89 e5                	mov    %esp,%ebp
  80181e:	56                   	push   %esi
  80181f:	53                   	push   %ebx
  801820:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801823:	83 ec 0c             	sub    $0xc,%esp
  801826:	ff 75 08             	pushl  0x8(%ebp)
  801829:	e8 f2 f7 ff ff       	call   801020 <fd2data>
  80182e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801830:	83 c4 08             	add    $0x8,%esp
  801833:	68 47 26 80 00       	push   $0x802647
  801838:	53                   	push   %ebx
  801839:	e8 ac ee ff ff       	call   8006ea <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80183e:	8b 46 04             	mov    0x4(%esi),%eax
  801841:	2b 06                	sub    (%esi),%eax
  801843:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801849:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801850:	00 00 00 
	stat->st_dev = &devpipe;
  801853:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80185a:	30 80 00 
	return 0;
}
  80185d:	b8 00 00 00 00       	mov    $0x0,%eax
  801862:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801865:	5b                   	pop    %ebx
  801866:	5e                   	pop    %esi
  801867:	5d                   	pop    %ebp
  801868:	c3                   	ret    

00801869 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801869:	55                   	push   %ebp
  80186a:	89 e5                	mov    %esp,%ebp
  80186c:	53                   	push   %ebx
  80186d:	83 ec 0c             	sub    $0xc,%esp
  801870:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801873:	53                   	push   %ebx
  801874:	6a 00                	push   $0x0
  801876:	e8 f7 f2 ff ff       	call   800b72 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80187b:	89 1c 24             	mov    %ebx,(%esp)
  80187e:	e8 9d f7 ff ff       	call   801020 <fd2data>
  801883:	83 c4 08             	add    $0x8,%esp
  801886:	50                   	push   %eax
  801887:	6a 00                	push   $0x0
  801889:	e8 e4 f2 ff ff       	call   800b72 <sys_page_unmap>
}
  80188e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801891:	c9                   	leave  
  801892:	c3                   	ret    

00801893 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801893:	55                   	push   %ebp
  801894:	89 e5                	mov    %esp,%ebp
  801896:	57                   	push   %edi
  801897:	56                   	push   %esi
  801898:	53                   	push   %ebx
  801899:	83 ec 1c             	sub    $0x1c,%esp
  80189c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80189f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018a1:	a1 04 40 80 00       	mov    0x804004,%eax
  8018a6:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8018a9:	83 ec 0c             	sub    $0xc,%esp
  8018ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8018af:	e8 35 06 00 00       	call   801ee9 <pageref>
  8018b4:	89 c3                	mov    %eax,%ebx
  8018b6:	89 3c 24             	mov    %edi,(%esp)
  8018b9:	e8 2b 06 00 00       	call   801ee9 <pageref>
  8018be:	83 c4 10             	add    $0x10,%esp
  8018c1:	39 c3                	cmp    %eax,%ebx
  8018c3:	0f 94 c1             	sete   %cl
  8018c6:	0f b6 c9             	movzbl %cl,%ecx
  8018c9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8018cc:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8018d2:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  8018d5:	39 ce                	cmp    %ecx,%esi
  8018d7:	74 1b                	je     8018f4 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8018d9:	39 c3                	cmp    %eax,%ebx
  8018db:	75 c4                	jne    8018a1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018dd:	8b 42 64             	mov    0x64(%edx),%eax
  8018e0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018e3:	50                   	push   %eax
  8018e4:	56                   	push   %esi
  8018e5:	68 4e 26 80 00       	push   $0x80264e
  8018ea:	e8 76 e8 ff ff       	call   800165 <cprintf>
  8018ef:	83 c4 10             	add    $0x10,%esp
  8018f2:	eb ad                	jmp    8018a1 <_pipeisclosed+0xe>
	}
}
  8018f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018fa:	5b                   	pop    %ebx
  8018fb:	5e                   	pop    %esi
  8018fc:	5f                   	pop    %edi
  8018fd:	5d                   	pop    %ebp
  8018fe:	c3                   	ret    

008018ff <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018ff:	55                   	push   %ebp
  801900:	89 e5                	mov    %esp,%ebp
  801902:	57                   	push   %edi
  801903:	56                   	push   %esi
  801904:	53                   	push   %ebx
  801905:	83 ec 28             	sub    $0x28,%esp
  801908:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80190b:	56                   	push   %esi
  80190c:	e8 0f f7 ff ff       	call   801020 <fd2data>
  801911:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801913:	83 c4 10             	add    $0x10,%esp
  801916:	bf 00 00 00 00       	mov    $0x0,%edi
  80191b:	eb 4b                	jmp    801968 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80191d:	89 da                	mov    %ebx,%edx
  80191f:	89 f0                	mov    %esi,%eax
  801921:	e8 6d ff ff ff       	call   801893 <_pipeisclosed>
  801926:	85 c0                	test   %eax,%eax
  801928:	75 48                	jne    801972 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80192a:	e8 9f f1 ff ff       	call   800ace <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80192f:	8b 43 04             	mov    0x4(%ebx),%eax
  801932:	8b 0b                	mov    (%ebx),%ecx
  801934:	8d 51 20             	lea    0x20(%ecx),%edx
  801937:	39 d0                	cmp    %edx,%eax
  801939:	73 e2                	jae    80191d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80193b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80193e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801942:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801945:	89 c2                	mov    %eax,%edx
  801947:	c1 fa 1f             	sar    $0x1f,%edx
  80194a:	89 d1                	mov    %edx,%ecx
  80194c:	c1 e9 1b             	shr    $0x1b,%ecx
  80194f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801952:	83 e2 1f             	and    $0x1f,%edx
  801955:	29 ca                	sub    %ecx,%edx
  801957:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80195b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80195f:	83 c0 01             	add    $0x1,%eax
  801962:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801965:	83 c7 01             	add    $0x1,%edi
  801968:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80196b:	75 c2                	jne    80192f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80196d:	8b 45 10             	mov    0x10(%ebp),%eax
  801970:	eb 05                	jmp    801977 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801972:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801977:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80197a:	5b                   	pop    %ebx
  80197b:	5e                   	pop    %esi
  80197c:	5f                   	pop    %edi
  80197d:	5d                   	pop    %ebp
  80197e:	c3                   	ret    

0080197f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80197f:	55                   	push   %ebp
  801980:	89 e5                	mov    %esp,%ebp
  801982:	57                   	push   %edi
  801983:	56                   	push   %esi
  801984:	53                   	push   %ebx
  801985:	83 ec 18             	sub    $0x18,%esp
  801988:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80198b:	57                   	push   %edi
  80198c:	e8 8f f6 ff ff       	call   801020 <fd2data>
  801991:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801993:	83 c4 10             	add    $0x10,%esp
  801996:	bb 00 00 00 00       	mov    $0x0,%ebx
  80199b:	eb 3d                	jmp    8019da <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80199d:	85 db                	test   %ebx,%ebx
  80199f:	74 04                	je     8019a5 <devpipe_read+0x26>
				return i;
  8019a1:	89 d8                	mov    %ebx,%eax
  8019a3:	eb 44                	jmp    8019e9 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019a5:	89 f2                	mov    %esi,%edx
  8019a7:	89 f8                	mov    %edi,%eax
  8019a9:	e8 e5 fe ff ff       	call   801893 <_pipeisclosed>
  8019ae:	85 c0                	test   %eax,%eax
  8019b0:	75 32                	jne    8019e4 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019b2:	e8 17 f1 ff ff       	call   800ace <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019b7:	8b 06                	mov    (%esi),%eax
  8019b9:	3b 46 04             	cmp    0x4(%esi),%eax
  8019bc:	74 df                	je     80199d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019be:	99                   	cltd   
  8019bf:	c1 ea 1b             	shr    $0x1b,%edx
  8019c2:	01 d0                	add    %edx,%eax
  8019c4:	83 e0 1f             	and    $0x1f,%eax
  8019c7:	29 d0                	sub    %edx,%eax
  8019c9:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8019ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019d1:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8019d4:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019d7:	83 c3 01             	add    $0x1,%ebx
  8019da:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019dd:	75 d8                	jne    8019b7 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019df:	8b 45 10             	mov    0x10(%ebp),%eax
  8019e2:	eb 05                	jmp    8019e9 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019e4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8019e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019ec:	5b                   	pop    %ebx
  8019ed:	5e                   	pop    %esi
  8019ee:	5f                   	pop    %edi
  8019ef:	5d                   	pop    %ebp
  8019f0:	c3                   	ret    

008019f1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8019f1:	55                   	push   %ebp
  8019f2:	89 e5                	mov    %esp,%ebp
  8019f4:	56                   	push   %esi
  8019f5:	53                   	push   %ebx
  8019f6:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8019f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019fc:	50                   	push   %eax
  8019fd:	e8 35 f6 ff ff       	call   801037 <fd_alloc>
  801a02:	83 c4 10             	add    $0x10,%esp
  801a05:	89 c2                	mov    %eax,%edx
  801a07:	85 c0                	test   %eax,%eax
  801a09:	0f 88 2c 01 00 00    	js     801b3b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a0f:	83 ec 04             	sub    $0x4,%esp
  801a12:	68 07 04 00 00       	push   $0x407
  801a17:	ff 75 f4             	pushl  -0xc(%ebp)
  801a1a:	6a 00                	push   $0x0
  801a1c:	e8 cc f0 ff ff       	call   800aed <sys_page_alloc>
  801a21:	83 c4 10             	add    $0x10,%esp
  801a24:	89 c2                	mov    %eax,%edx
  801a26:	85 c0                	test   %eax,%eax
  801a28:	0f 88 0d 01 00 00    	js     801b3b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a2e:	83 ec 0c             	sub    $0xc,%esp
  801a31:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a34:	50                   	push   %eax
  801a35:	e8 fd f5 ff ff       	call   801037 <fd_alloc>
  801a3a:	89 c3                	mov    %eax,%ebx
  801a3c:	83 c4 10             	add    $0x10,%esp
  801a3f:	85 c0                	test   %eax,%eax
  801a41:	0f 88 e2 00 00 00    	js     801b29 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a47:	83 ec 04             	sub    $0x4,%esp
  801a4a:	68 07 04 00 00       	push   $0x407
  801a4f:	ff 75 f0             	pushl  -0x10(%ebp)
  801a52:	6a 00                	push   $0x0
  801a54:	e8 94 f0 ff ff       	call   800aed <sys_page_alloc>
  801a59:	89 c3                	mov    %eax,%ebx
  801a5b:	83 c4 10             	add    $0x10,%esp
  801a5e:	85 c0                	test   %eax,%eax
  801a60:	0f 88 c3 00 00 00    	js     801b29 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a66:	83 ec 0c             	sub    $0xc,%esp
  801a69:	ff 75 f4             	pushl  -0xc(%ebp)
  801a6c:	e8 af f5 ff ff       	call   801020 <fd2data>
  801a71:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a73:	83 c4 0c             	add    $0xc,%esp
  801a76:	68 07 04 00 00       	push   $0x407
  801a7b:	50                   	push   %eax
  801a7c:	6a 00                	push   $0x0
  801a7e:	e8 6a f0 ff ff       	call   800aed <sys_page_alloc>
  801a83:	89 c3                	mov    %eax,%ebx
  801a85:	83 c4 10             	add    $0x10,%esp
  801a88:	85 c0                	test   %eax,%eax
  801a8a:	0f 88 89 00 00 00    	js     801b19 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a90:	83 ec 0c             	sub    $0xc,%esp
  801a93:	ff 75 f0             	pushl  -0x10(%ebp)
  801a96:	e8 85 f5 ff ff       	call   801020 <fd2data>
  801a9b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801aa2:	50                   	push   %eax
  801aa3:	6a 00                	push   $0x0
  801aa5:	56                   	push   %esi
  801aa6:	6a 00                	push   $0x0
  801aa8:	e8 83 f0 ff ff       	call   800b30 <sys_page_map>
  801aad:	89 c3                	mov    %eax,%ebx
  801aaf:	83 c4 20             	add    $0x20,%esp
  801ab2:	85 c0                	test   %eax,%eax
  801ab4:	78 55                	js     801b0b <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ab6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801abf:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801acb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ad1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ad4:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ad6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ad9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ae0:	83 ec 0c             	sub    $0xc,%esp
  801ae3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae6:	e8 25 f5 ff ff       	call   801010 <fd2num>
  801aeb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801aee:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801af0:	83 c4 04             	add    $0x4,%esp
  801af3:	ff 75 f0             	pushl  -0x10(%ebp)
  801af6:	e8 15 f5 ff ff       	call   801010 <fd2num>
  801afb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801afe:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801b01:	83 c4 10             	add    $0x10,%esp
  801b04:	ba 00 00 00 00       	mov    $0x0,%edx
  801b09:	eb 30                	jmp    801b3b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b0b:	83 ec 08             	sub    $0x8,%esp
  801b0e:	56                   	push   %esi
  801b0f:	6a 00                	push   $0x0
  801b11:	e8 5c f0 ff ff       	call   800b72 <sys_page_unmap>
  801b16:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b19:	83 ec 08             	sub    $0x8,%esp
  801b1c:	ff 75 f0             	pushl  -0x10(%ebp)
  801b1f:	6a 00                	push   $0x0
  801b21:	e8 4c f0 ff ff       	call   800b72 <sys_page_unmap>
  801b26:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b29:	83 ec 08             	sub    $0x8,%esp
  801b2c:	ff 75 f4             	pushl  -0xc(%ebp)
  801b2f:	6a 00                	push   $0x0
  801b31:	e8 3c f0 ff ff       	call   800b72 <sys_page_unmap>
  801b36:	83 c4 10             	add    $0x10,%esp
  801b39:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b3b:	89 d0                	mov    %edx,%eax
  801b3d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b40:	5b                   	pop    %ebx
  801b41:	5e                   	pop    %esi
  801b42:	5d                   	pop    %ebp
  801b43:	c3                   	ret    

00801b44 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b4a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b4d:	50                   	push   %eax
  801b4e:	ff 75 08             	pushl  0x8(%ebp)
  801b51:	e8 30 f5 ff ff       	call   801086 <fd_lookup>
  801b56:	83 c4 10             	add    $0x10,%esp
  801b59:	85 c0                	test   %eax,%eax
  801b5b:	78 18                	js     801b75 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b5d:	83 ec 0c             	sub    $0xc,%esp
  801b60:	ff 75 f4             	pushl  -0xc(%ebp)
  801b63:	e8 b8 f4 ff ff       	call   801020 <fd2data>
	return _pipeisclosed(fd, p);
  801b68:	89 c2                	mov    %eax,%edx
  801b6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b6d:	e8 21 fd ff ff       	call   801893 <_pipeisclosed>
  801b72:	83 c4 10             	add    $0x10,%esp
}
  801b75:	c9                   	leave  
  801b76:	c3                   	ret    

00801b77 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b77:	55                   	push   %ebp
  801b78:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b7a:	b8 00 00 00 00       	mov    $0x0,%eax
  801b7f:	5d                   	pop    %ebp
  801b80:	c3                   	ret    

00801b81 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b81:	55                   	push   %ebp
  801b82:	89 e5                	mov    %esp,%ebp
  801b84:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b87:	68 66 26 80 00       	push   $0x802666
  801b8c:	ff 75 0c             	pushl  0xc(%ebp)
  801b8f:	e8 56 eb ff ff       	call   8006ea <strcpy>
	return 0;
}
  801b94:	b8 00 00 00 00       	mov    $0x0,%eax
  801b99:	c9                   	leave  
  801b9a:	c3                   	ret    

00801b9b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b9b:	55                   	push   %ebp
  801b9c:	89 e5                	mov    %esp,%ebp
  801b9e:	57                   	push   %edi
  801b9f:	56                   	push   %esi
  801ba0:	53                   	push   %ebx
  801ba1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ba7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bac:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bb2:	eb 2d                	jmp    801be1 <devcons_write+0x46>
		m = n - tot;
  801bb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801bb7:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801bb9:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801bbc:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801bc1:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bc4:	83 ec 04             	sub    $0x4,%esp
  801bc7:	53                   	push   %ebx
  801bc8:	03 45 0c             	add    0xc(%ebp),%eax
  801bcb:	50                   	push   %eax
  801bcc:	57                   	push   %edi
  801bcd:	e8 aa ec ff ff       	call   80087c <memmove>
		sys_cputs(buf, m);
  801bd2:	83 c4 08             	add    $0x8,%esp
  801bd5:	53                   	push   %ebx
  801bd6:	57                   	push   %edi
  801bd7:	e8 55 ee ff ff       	call   800a31 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bdc:	01 de                	add    %ebx,%esi
  801bde:	83 c4 10             	add    $0x10,%esp
  801be1:	89 f0                	mov    %esi,%eax
  801be3:	3b 75 10             	cmp    0x10(%ebp),%esi
  801be6:	72 cc                	jb     801bb4 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801be8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801beb:	5b                   	pop    %ebx
  801bec:	5e                   	pop    %esi
  801bed:	5f                   	pop    %edi
  801bee:	5d                   	pop    %ebp
  801bef:	c3                   	ret    

00801bf0 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bf0:	55                   	push   %ebp
  801bf1:	89 e5                	mov    %esp,%ebp
  801bf3:	83 ec 08             	sub    $0x8,%esp
  801bf6:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801bfb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bff:	74 2a                	je     801c2b <devcons_read+0x3b>
  801c01:	eb 05                	jmp    801c08 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c03:	e8 c6 ee ff ff       	call   800ace <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c08:	e8 42 ee ff ff       	call   800a4f <sys_cgetc>
  801c0d:	85 c0                	test   %eax,%eax
  801c0f:	74 f2                	je     801c03 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c11:	85 c0                	test   %eax,%eax
  801c13:	78 16                	js     801c2b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c15:	83 f8 04             	cmp    $0x4,%eax
  801c18:	74 0c                	je     801c26 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c1a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c1d:	88 02                	mov    %al,(%edx)
	return 1;
  801c1f:	b8 01 00 00 00       	mov    $0x1,%eax
  801c24:	eb 05                	jmp    801c2b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c26:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c2b:	c9                   	leave  
  801c2c:	c3                   	ret    

00801c2d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c2d:	55                   	push   %ebp
  801c2e:	89 e5                	mov    %esp,%ebp
  801c30:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c33:	8b 45 08             	mov    0x8(%ebp),%eax
  801c36:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c39:	6a 01                	push   $0x1
  801c3b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c3e:	50                   	push   %eax
  801c3f:	e8 ed ed ff ff       	call   800a31 <sys_cputs>
}
  801c44:	83 c4 10             	add    $0x10,%esp
  801c47:	c9                   	leave  
  801c48:	c3                   	ret    

00801c49 <getchar>:

int
getchar(void)
{
  801c49:	55                   	push   %ebp
  801c4a:	89 e5                	mov    %esp,%ebp
  801c4c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c4f:	6a 01                	push   $0x1
  801c51:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c54:	50                   	push   %eax
  801c55:	6a 00                	push   $0x0
  801c57:	e8 90 f6 ff ff       	call   8012ec <read>
	if (r < 0)
  801c5c:	83 c4 10             	add    $0x10,%esp
  801c5f:	85 c0                	test   %eax,%eax
  801c61:	78 0f                	js     801c72 <getchar+0x29>
		return r;
	if (r < 1)
  801c63:	85 c0                	test   %eax,%eax
  801c65:	7e 06                	jle    801c6d <getchar+0x24>
		return -E_EOF;
	return c;
  801c67:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c6b:	eb 05                	jmp    801c72 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c6d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c72:	c9                   	leave  
  801c73:	c3                   	ret    

00801c74 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c74:	55                   	push   %ebp
  801c75:	89 e5                	mov    %esp,%ebp
  801c77:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c7d:	50                   	push   %eax
  801c7e:	ff 75 08             	pushl  0x8(%ebp)
  801c81:	e8 00 f4 ff ff       	call   801086 <fd_lookup>
  801c86:	83 c4 10             	add    $0x10,%esp
  801c89:	85 c0                	test   %eax,%eax
  801c8b:	78 11                	js     801c9e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c90:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c96:	39 10                	cmp    %edx,(%eax)
  801c98:	0f 94 c0             	sete   %al
  801c9b:	0f b6 c0             	movzbl %al,%eax
}
  801c9e:	c9                   	leave  
  801c9f:	c3                   	ret    

00801ca0 <opencons>:

int
opencons(void)
{
  801ca0:	55                   	push   %ebp
  801ca1:	89 e5                	mov    %esp,%ebp
  801ca3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ca6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ca9:	50                   	push   %eax
  801caa:	e8 88 f3 ff ff       	call   801037 <fd_alloc>
  801caf:	83 c4 10             	add    $0x10,%esp
		return r;
  801cb2:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cb4:	85 c0                	test   %eax,%eax
  801cb6:	78 3e                	js     801cf6 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cb8:	83 ec 04             	sub    $0x4,%esp
  801cbb:	68 07 04 00 00       	push   $0x407
  801cc0:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc3:	6a 00                	push   $0x0
  801cc5:	e8 23 ee ff ff       	call   800aed <sys_page_alloc>
  801cca:	83 c4 10             	add    $0x10,%esp
		return r;
  801ccd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ccf:	85 c0                	test   %eax,%eax
  801cd1:	78 23                	js     801cf6 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801cd3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cdc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ce8:	83 ec 0c             	sub    $0xc,%esp
  801ceb:	50                   	push   %eax
  801cec:	e8 1f f3 ff ff       	call   801010 <fd2num>
  801cf1:	89 c2                	mov    %eax,%edx
  801cf3:	83 c4 10             	add    $0x10,%esp
}
  801cf6:	89 d0                	mov    %edx,%eax
  801cf8:	c9                   	leave  
  801cf9:	c3                   	ret    

00801cfa <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801cfa:	55                   	push   %ebp
  801cfb:	89 e5                	mov    %esp,%ebp
  801cfd:	56                   	push   %esi
  801cfe:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801cff:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d02:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d08:	e8 a2 ed ff ff       	call   800aaf <sys_getenvid>
  801d0d:	83 ec 0c             	sub    $0xc,%esp
  801d10:	ff 75 0c             	pushl  0xc(%ebp)
  801d13:	ff 75 08             	pushl  0x8(%ebp)
  801d16:	56                   	push   %esi
  801d17:	50                   	push   %eax
  801d18:	68 74 26 80 00       	push   $0x802674
  801d1d:	e8 43 e4 ff ff       	call   800165 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d22:	83 c4 18             	add    $0x18,%esp
  801d25:	53                   	push   %ebx
  801d26:	ff 75 10             	pushl  0x10(%ebp)
  801d29:	e8 e6 e3 ff ff       	call   800114 <vcprintf>
	cprintf("\n");
  801d2e:	c7 04 24 dc 21 80 00 	movl   $0x8021dc,(%esp)
  801d35:	e8 2b e4 ff ff       	call   800165 <cprintf>
  801d3a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d3d:	cc                   	int3   
  801d3e:	eb fd                	jmp    801d3d <_panic+0x43>

00801d40 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d40:	55                   	push   %ebp
  801d41:	89 e5                	mov    %esp,%ebp
  801d43:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d46:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d4d:	75 2a                	jne    801d79 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d4f:	83 ec 04             	sub    $0x4,%esp
  801d52:	6a 07                	push   $0x7
  801d54:	68 00 f0 bf ee       	push   $0xeebff000
  801d59:	6a 00                	push   $0x0
  801d5b:	e8 8d ed ff ff       	call   800aed <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801d60:	83 c4 10             	add    $0x10,%esp
  801d63:	85 c0                	test   %eax,%eax
  801d65:	79 12                	jns    801d79 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801d67:	50                   	push   %eax
  801d68:	68 98 26 80 00       	push   $0x802698
  801d6d:	6a 23                	push   $0x23
  801d6f:	68 9c 26 80 00       	push   $0x80269c
  801d74:	e8 81 ff ff ff       	call   801cfa <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d79:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7c:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801d81:	83 ec 08             	sub    $0x8,%esp
  801d84:	68 ab 1d 80 00       	push   $0x801dab
  801d89:	6a 00                	push   $0x0
  801d8b:	e8 a8 ee ff ff       	call   800c38 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801d90:	83 c4 10             	add    $0x10,%esp
  801d93:	85 c0                	test   %eax,%eax
  801d95:	79 12                	jns    801da9 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801d97:	50                   	push   %eax
  801d98:	68 98 26 80 00       	push   $0x802698
  801d9d:	6a 2c                	push   $0x2c
  801d9f:	68 9c 26 80 00       	push   $0x80269c
  801da4:	e8 51 ff ff ff       	call   801cfa <_panic>
	}
}
  801da9:	c9                   	leave  
  801daa:	c3                   	ret    

00801dab <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801dab:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801dac:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801db1:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801db3:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801db6:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801dba:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801dbf:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801dc3:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801dc5:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801dc8:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801dc9:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801dcc:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801dcd:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801dce:	c3                   	ret    

00801dcf <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801dcf:	55                   	push   %ebp
  801dd0:	89 e5                	mov    %esp,%ebp
  801dd2:	56                   	push   %esi
  801dd3:	53                   	push   %ebx
  801dd4:	8b 75 08             	mov    0x8(%ebp),%esi
  801dd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dda:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801ddd:	85 c0                	test   %eax,%eax
  801ddf:	75 12                	jne    801df3 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801de1:	83 ec 0c             	sub    $0xc,%esp
  801de4:	68 00 00 c0 ee       	push   $0xeec00000
  801de9:	e8 af ee ff ff       	call   800c9d <sys_ipc_recv>
  801dee:	83 c4 10             	add    $0x10,%esp
  801df1:	eb 0c                	jmp    801dff <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801df3:	83 ec 0c             	sub    $0xc,%esp
  801df6:	50                   	push   %eax
  801df7:	e8 a1 ee ff ff       	call   800c9d <sys_ipc_recv>
  801dfc:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801dff:	85 f6                	test   %esi,%esi
  801e01:	0f 95 c1             	setne  %cl
  801e04:	85 db                	test   %ebx,%ebx
  801e06:	0f 95 c2             	setne  %dl
  801e09:	84 d1                	test   %dl,%cl
  801e0b:	74 09                	je     801e16 <ipc_recv+0x47>
  801e0d:	89 c2                	mov    %eax,%edx
  801e0f:	c1 ea 1f             	shr    $0x1f,%edx
  801e12:	84 d2                	test   %dl,%dl
  801e14:	75 2a                	jne    801e40 <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e16:	85 f6                	test   %esi,%esi
  801e18:	74 0d                	je     801e27 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e1a:	a1 04 40 80 00       	mov    0x804004,%eax
  801e1f:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801e25:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e27:	85 db                	test   %ebx,%ebx
  801e29:	74 0d                	je     801e38 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e2b:	a1 04 40 80 00       	mov    0x804004,%eax
  801e30:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  801e36:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e38:	a1 04 40 80 00       	mov    0x804004,%eax
  801e3d:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  801e40:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e43:	5b                   	pop    %ebx
  801e44:	5e                   	pop    %esi
  801e45:	5d                   	pop    %ebp
  801e46:	c3                   	ret    

00801e47 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e47:	55                   	push   %ebp
  801e48:	89 e5                	mov    %esp,%ebp
  801e4a:	57                   	push   %edi
  801e4b:	56                   	push   %esi
  801e4c:	53                   	push   %ebx
  801e4d:	83 ec 0c             	sub    $0xc,%esp
  801e50:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e53:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e56:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801e59:	85 db                	test   %ebx,%ebx
  801e5b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e60:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e63:	ff 75 14             	pushl  0x14(%ebp)
  801e66:	53                   	push   %ebx
  801e67:	56                   	push   %esi
  801e68:	57                   	push   %edi
  801e69:	e8 0c ee ff ff       	call   800c7a <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801e6e:	89 c2                	mov    %eax,%edx
  801e70:	c1 ea 1f             	shr    $0x1f,%edx
  801e73:	83 c4 10             	add    $0x10,%esp
  801e76:	84 d2                	test   %dl,%dl
  801e78:	74 17                	je     801e91 <ipc_send+0x4a>
  801e7a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e7d:	74 12                	je     801e91 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801e7f:	50                   	push   %eax
  801e80:	68 aa 26 80 00       	push   $0x8026aa
  801e85:	6a 47                	push   $0x47
  801e87:	68 b8 26 80 00       	push   $0x8026b8
  801e8c:	e8 69 fe ff ff       	call   801cfa <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801e91:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e94:	75 07                	jne    801e9d <ipc_send+0x56>
			sys_yield();
  801e96:	e8 33 ec ff ff       	call   800ace <sys_yield>
  801e9b:	eb c6                	jmp    801e63 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801e9d:	85 c0                	test   %eax,%eax
  801e9f:	75 c2                	jne    801e63 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801ea1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ea4:	5b                   	pop    %ebx
  801ea5:	5e                   	pop    %esi
  801ea6:	5f                   	pop    %edi
  801ea7:	5d                   	pop    %ebp
  801ea8:	c3                   	ret    

00801ea9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ea9:	55                   	push   %ebp
  801eaa:	89 e5                	mov    %esp,%ebp
  801eac:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801eaf:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801eb4:	89 c2                	mov    %eax,%edx
  801eb6:	c1 e2 07             	shl    $0x7,%edx
  801eb9:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  801ec0:	8b 52 5c             	mov    0x5c(%edx),%edx
  801ec3:	39 ca                	cmp    %ecx,%edx
  801ec5:	75 11                	jne    801ed8 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801ec7:	89 c2                	mov    %eax,%edx
  801ec9:	c1 e2 07             	shl    $0x7,%edx
  801ecc:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801ed3:	8b 40 54             	mov    0x54(%eax),%eax
  801ed6:	eb 0f                	jmp    801ee7 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ed8:	83 c0 01             	add    $0x1,%eax
  801edb:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ee0:	75 d2                	jne    801eb4 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ee2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ee7:	5d                   	pop    %ebp
  801ee8:	c3                   	ret    

00801ee9 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ee9:	55                   	push   %ebp
  801eea:	89 e5                	mov    %esp,%ebp
  801eec:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801eef:	89 d0                	mov    %edx,%eax
  801ef1:	c1 e8 16             	shr    $0x16,%eax
  801ef4:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801efb:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f00:	f6 c1 01             	test   $0x1,%cl
  801f03:	74 1d                	je     801f22 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f05:	c1 ea 0c             	shr    $0xc,%edx
  801f08:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f0f:	f6 c2 01             	test   $0x1,%dl
  801f12:	74 0e                	je     801f22 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f14:	c1 ea 0c             	shr    $0xc,%edx
  801f17:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f1e:	ef 
  801f1f:	0f b7 c0             	movzwl %ax,%eax
}
  801f22:	5d                   	pop    %ebp
  801f23:	c3                   	ret    
  801f24:	66 90                	xchg   %ax,%ax
  801f26:	66 90                	xchg   %ax,%ax
  801f28:	66 90                	xchg   %ax,%ax
  801f2a:	66 90                	xchg   %ax,%ax
  801f2c:	66 90                	xchg   %ax,%ax
  801f2e:	66 90                	xchg   %ax,%ax

00801f30 <__udivdi3>:
  801f30:	55                   	push   %ebp
  801f31:	57                   	push   %edi
  801f32:	56                   	push   %esi
  801f33:	53                   	push   %ebx
  801f34:	83 ec 1c             	sub    $0x1c,%esp
  801f37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f47:	85 f6                	test   %esi,%esi
  801f49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f4d:	89 ca                	mov    %ecx,%edx
  801f4f:	89 f8                	mov    %edi,%eax
  801f51:	75 3d                	jne    801f90 <__udivdi3+0x60>
  801f53:	39 cf                	cmp    %ecx,%edi
  801f55:	0f 87 c5 00 00 00    	ja     802020 <__udivdi3+0xf0>
  801f5b:	85 ff                	test   %edi,%edi
  801f5d:	89 fd                	mov    %edi,%ebp
  801f5f:	75 0b                	jne    801f6c <__udivdi3+0x3c>
  801f61:	b8 01 00 00 00       	mov    $0x1,%eax
  801f66:	31 d2                	xor    %edx,%edx
  801f68:	f7 f7                	div    %edi
  801f6a:	89 c5                	mov    %eax,%ebp
  801f6c:	89 c8                	mov    %ecx,%eax
  801f6e:	31 d2                	xor    %edx,%edx
  801f70:	f7 f5                	div    %ebp
  801f72:	89 c1                	mov    %eax,%ecx
  801f74:	89 d8                	mov    %ebx,%eax
  801f76:	89 cf                	mov    %ecx,%edi
  801f78:	f7 f5                	div    %ebp
  801f7a:	89 c3                	mov    %eax,%ebx
  801f7c:	89 d8                	mov    %ebx,%eax
  801f7e:	89 fa                	mov    %edi,%edx
  801f80:	83 c4 1c             	add    $0x1c,%esp
  801f83:	5b                   	pop    %ebx
  801f84:	5e                   	pop    %esi
  801f85:	5f                   	pop    %edi
  801f86:	5d                   	pop    %ebp
  801f87:	c3                   	ret    
  801f88:	90                   	nop
  801f89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f90:	39 ce                	cmp    %ecx,%esi
  801f92:	77 74                	ja     802008 <__udivdi3+0xd8>
  801f94:	0f bd fe             	bsr    %esi,%edi
  801f97:	83 f7 1f             	xor    $0x1f,%edi
  801f9a:	0f 84 98 00 00 00    	je     802038 <__udivdi3+0x108>
  801fa0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fa5:	89 f9                	mov    %edi,%ecx
  801fa7:	89 c5                	mov    %eax,%ebp
  801fa9:	29 fb                	sub    %edi,%ebx
  801fab:	d3 e6                	shl    %cl,%esi
  801fad:	89 d9                	mov    %ebx,%ecx
  801faf:	d3 ed                	shr    %cl,%ebp
  801fb1:	89 f9                	mov    %edi,%ecx
  801fb3:	d3 e0                	shl    %cl,%eax
  801fb5:	09 ee                	or     %ebp,%esi
  801fb7:	89 d9                	mov    %ebx,%ecx
  801fb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fbd:	89 d5                	mov    %edx,%ebp
  801fbf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fc3:	d3 ed                	shr    %cl,%ebp
  801fc5:	89 f9                	mov    %edi,%ecx
  801fc7:	d3 e2                	shl    %cl,%edx
  801fc9:	89 d9                	mov    %ebx,%ecx
  801fcb:	d3 e8                	shr    %cl,%eax
  801fcd:	09 c2                	or     %eax,%edx
  801fcf:	89 d0                	mov    %edx,%eax
  801fd1:	89 ea                	mov    %ebp,%edx
  801fd3:	f7 f6                	div    %esi
  801fd5:	89 d5                	mov    %edx,%ebp
  801fd7:	89 c3                	mov    %eax,%ebx
  801fd9:	f7 64 24 0c          	mull   0xc(%esp)
  801fdd:	39 d5                	cmp    %edx,%ebp
  801fdf:	72 10                	jb     801ff1 <__udivdi3+0xc1>
  801fe1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801fe5:	89 f9                	mov    %edi,%ecx
  801fe7:	d3 e6                	shl    %cl,%esi
  801fe9:	39 c6                	cmp    %eax,%esi
  801feb:	73 07                	jae    801ff4 <__udivdi3+0xc4>
  801fed:	39 d5                	cmp    %edx,%ebp
  801fef:	75 03                	jne    801ff4 <__udivdi3+0xc4>
  801ff1:	83 eb 01             	sub    $0x1,%ebx
  801ff4:	31 ff                	xor    %edi,%edi
  801ff6:	89 d8                	mov    %ebx,%eax
  801ff8:	89 fa                	mov    %edi,%edx
  801ffa:	83 c4 1c             	add    $0x1c,%esp
  801ffd:	5b                   	pop    %ebx
  801ffe:	5e                   	pop    %esi
  801fff:	5f                   	pop    %edi
  802000:	5d                   	pop    %ebp
  802001:	c3                   	ret    
  802002:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802008:	31 ff                	xor    %edi,%edi
  80200a:	31 db                	xor    %ebx,%ebx
  80200c:	89 d8                	mov    %ebx,%eax
  80200e:	89 fa                	mov    %edi,%edx
  802010:	83 c4 1c             	add    $0x1c,%esp
  802013:	5b                   	pop    %ebx
  802014:	5e                   	pop    %esi
  802015:	5f                   	pop    %edi
  802016:	5d                   	pop    %ebp
  802017:	c3                   	ret    
  802018:	90                   	nop
  802019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802020:	89 d8                	mov    %ebx,%eax
  802022:	f7 f7                	div    %edi
  802024:	31 ff                	xor    %edi,%edi
  802026:	89 c3                	mov    %eax,%ebx
  802028:	89 d8                	mov    %ebx,%eax
  80202a:	89 fa                	mov    %edi,%edx
  80202c:	83 c4 1c             	add    $0x1c,%esp
  80202f:	5b                   	pop    %ebx
  802030:	5e                   	pop    %esi
  802031:	5f                   	pop    %edi
  802032:	5d                   	pop    %ebp
  802033:	c3                   	ret    
  802034:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802038:	39 ce                	cmp    %ecx,%esi
  80203a:	72 0c                	jb     802048 <__udivdi3+0x118>
  80203c:	31 db                	xor    %ebx,%ebx
  80203e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802042:	0f 87 34 ff ff ff    	ja     801f7c <__udivdi3+0x4c>
  802048:	bb 01 00 00 00       	mov    $0x1,%ebx
  80204d:	e9 2a ff ff ff       	jmp    801f7c <__udivdi3+0x4c>
  802052:	66 90                	xchg   %ax,%ax
  802054:	66 90                	xchg   %ax,%ax
  802056:	66 90                	xchg   %ax,%ax
  802058:	66 90                	xchg   %ax,%ax
  80205a:	66 90                	xchg   %ax,%ax
  80205c:	66 90                	xchg   %ax,%ax
  80205e:	66 90                	xchg   %ax,%ax

00802060 <__umoddi3>:
  802060:	55                   	push   %ebp
  802061:	57                   	push   %edi
  802062:	56                   	push   %esi
  802063:	53                   	push   %ebx
  802064:	83 ec 1c             	sub    $0x1c,%esp
  802067:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80206b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80206f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802073:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802077:	85 d2                	test   %edx,%edx
  802079:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80207d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802081:	89 f3                	mov    %esi,%ebx
  802083:	89 3c 24             	mov    %edi,(%esp)
  802086:	89 74 24 04          	mov    %esi,0x4(%esp)
  80208a:	75 1c                	jne    8020a8 <__umoddi3+0x48>
  80208c:	39 f7                	cmp    %esi,%edi
  80208e:	76 50                	jbe    8020e0 <__umoddi3+0x80>
  802090:	89 c8                	mov    %ecx,%eax
  802092:	89 f2                	mov    %esi,%edx
  802094:	f7 f7                	div    %edi
  802096:	89 d0                	mov    %edx,%eax
  802098:	31 d2                	xor    %edx,%edx
  80209a:	83 c4 1c             	add    $0x1c,%esp
  80209d:	5b                   	pop    %ebx
  80209e:	5e                   	pop    %esi
  80209f:	5f                   	pop    %edi
  8020a0:	5d                   	pop    %ebp
  8020a1:	c3                   	ret    
  8020a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020a8:	39 f2                	cmp    %esi,%edx
  8020aa:	89 d0                	mov    %edx,%eax
  8020ac:	77 52                	ja     802100 <__umoddi3+0xa0>
  8020ae:	0f bd ea             	bsr    %edx,%ebp
  8020b1:	83 f5 1f             	xor    $0x1f,%ebp
  8020b4:	75 5a                	jne    802110 <__umoddi3+0xb0>
  8020b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020ba:	0f 82 e0 00 00 00    	jb     8021a0 <__umoddi3+0x140>
  8020c0:	39 0c 24             	cmp    %ecx,(%esp)
  8020c3:	0f 86 d7 00 00 00    	jbe    8021a0 <__umoddi3+0x140>
  8020c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020d1:	83 c4 1c             	add    $0x1c,%esp
  8020d4:	5b                   	pop    %ebx
  8020d5:	5e                   	pop    %esi
  8020d6:	5f                   	pop    %edi
  8020d7:	5d                   	pop    %ebp
  8020d8:	c3                   	ret    
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	85 ff                	test   %edi,%edi
  8020e2:	89 fd                	mov    %edi,%ebp
  8020e4:	75 0b                	jne    8020f1 <__umoddi3+0x91>
  8020e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020eb:	31 d2                	xor    %edx,%edx
  8020ed:	f7 f7                	div    %edi
  8020ef:	89 c5                	mov    %eax,%ebp
  8020f1:	89 f0                	mov    %esi,%eax
  8020f3:	31 d2                	xor    %edx,%edx
  8020f5:	f7 f5                	div    %ebp
  8020f7:	89 c8                	mov    %ecx,%eax
  8020f9:	f7 f5                	div    %ebp
  8020fb:	89 d0                	mov    %edx,%eax
  8020fd:	eb 99                	jmp    802098 <__umoddi3+0x38>
  8020ff:	90                   	nop
  802100:	89 c8                	mov    %ecx,%eax
  802102:	89 f2                	mov    %esi,%edx
  802104:	83 c4 1c             	add    $0x1c,%esp
  802107:	5b                   	pop    %ebx
  802108:	5e                   	pop    %esi
  802109:	5f                   	pop    %edi
  80210a:	5d                   	pop    %ebp
  80210b:	c3                   	ret    
  80210c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802110:	8b 34 24             	mov    (%esp),%esi
  802113:	bf 20 00 00 00       	mov    $0x20,%edi
  802118:	89 e9                	mov    %ebp,%ecx
  80211a:	29 ef                	sub    %ebp,%edi
  80211c:	d3 e0                	shl    %cl,%eax
  80211e:	89 f9                	mov    %edi,%ecx
  802120:	89 f2                	mov    %esi,%edx
  802122:	d3 ea                	shr    %cl,%edx
  802124:	89 e9                	mov    %ebp,%ecx
  802126:	09 c2                	or     %eax,%edx
  802128:	89 d8                	mov    %ebx,%eax
  80212a:	89 14 24             	mov    %edx,(%esp)
  80212d:	89 f2                	mov    %esi,%edx
  80212f:	d3 e2                	shl    %cl,%edx
  802131:	89 f9                	mov    %edi,%ecx
  802133:	89 54 24 04          	mov    %edx,0x4(%esp)
  802137:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80213b:	d3 e8                	shr    %cl,%eax
  80213d:	89 e9                	mov    %ebp,%ecx
  80213f:	89 c6                	mov    %eax,%esi
  802141:	d3 e3                	shl    %cl,%ebx
  802143:	89 f9                	mov    %edi,%ecx
  802145:	89 d0                	mov    %edx,%eax
  802147:	d3 e8                	shr    %cl,%eax
  802149:	89 e9                	mov    %ebp,%ecx
  80214b:	09 d8                	or     %ebx,%eax
  80214d:	89 d3                	mov    %edx,%ebx
  80214f:	89 f2                	mov    %esi,%edx
  802151:	f7 34 24             	divl   (%esp)
  802154:	89 d6                	mov    %edx,%esi
  802156:	d3 e3                	shl    %cl,%ebx
  802158:	f7 64 24 04          	mull   0x4(%esp)
  80215c:	39 d6                	cmp    %edx,%esi
  80215e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802162:	89 d1                	mov    %edx,%ecx
  802164:	89 c3                	mov    %eax,%ebx
  802166:	72 08                	jb     802170 <__umoddi3+0x110>
  802168:	75 11                	jne    80217b <__umoddi3+0x11b>
  80216a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80216e:	73 0b                	jae    80217b <__umoddi3+0x11b>
  802170:	2b 44 24 04          	sub    0x4(%esp),%eax
  802174:	1b 14 24             	sbb    (%esp),%edx
  802177:	89 d1                	mov    %edx,%ecx
  802179:	89 c3                	mov    %eax,%ebx
  80217b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80217f:	29 da                	sub    %ebx,%edx
  802181:	19 ce                	sbb    %ecx,%esi
  802183:	89 f9                	mov    %edi,%ecx
  802185:	89 f0                	mov    %esi,%eax
  802187:	d3 e0                	shl    %cl,%eax
  802189:	89 e9                	mov    %ebp,%ecx
  80218b:	d3 ea                	shr    %cl,%edx
  80218d:	89 e9                	mov    %ebp,%ecx
  80218f:	d3 ee                	shr    %cl,%esi
  802191:	09 d0                	or     %edx,%eax
  802193:	89 f2                	mov    %esi,%edx
  802195:	83 c4 1c             	add    $0x1c,%esp
  802198:	5b                   	pop    %ebx
  802199:	5e                   	pop    %esi
  80219a:	5f                   	pop    %edi
  80219b:	5d                   	pop    %ebp
  80219c:	c3                   	ret    
  80219d:	8d 76 00             	lea    0x0(%esi),%esi
  8021a0:	29 f9                	sub    %edi,%ecx
  8021a2:	19 d6                	sbb    %edx,%esi
  8021a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021ac:	e9 18 ff ff ff       	jmp    8020c9 <__umoddi3+0x69>
