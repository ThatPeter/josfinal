
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
  80002c:	e8 30 00 00 00       	call   800061 <libmain>
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
  800039:	68 20 24 80 00       	push   $0x802420
  80003e:	e8 34 01 00 00       	call   800177 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 40 80 00       	mov    0x804004,%eax
  800048:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80004e:	83 c4 08             	add    $0x8,%esp
  800051:	50                   	push   %eax
  800052:	68 2e 24 80 00       	push   $0x80242e
  800057:	e8 1b 01 00 00       	call   800177 <cprintf>
}
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	56                   	push   %esi
  800065:	53                   	push   %ebx
  800066:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800069:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80006c:	e8 50 0a 00 00       	call   800ac1 <sys_getenvid>
  800071:	25 ff 03 00 00       	and    $0x3ff,%eax
  800076:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  80007c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800081:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800086:	85 db                	test   %ebx,%ebx
  800088:	7e 07                	jle    800091 <libmain+0x30>
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
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	83 ec 08             	sub    $0x8,%esp
	void (*func)(void) = (void (*)(void))eip;
  8000b0:	a1 08 40 80 00       	mov    0x804008,%eax
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
  8000d0:	e8 47 13 00 00       	call   80141c <close_all>
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
  8001da:	e8 a1 1f 00 00       	call   802180 <__udivdi3>
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
  80021d:	e8 8e 20 00 00       	call   8022b0 <__umoddi3>
  800222:	83 c4 14             	add    $0x14,%esp
  800225:	0f be 80 4f 24 80 00 	movsbl 0x80244f(%eax),%eax
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
  800321:	ff 24 85 a0 25 80 00 	jmp    *0x8025a0(,%eax,4)
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
  8003e5:	8b 14 85 00 27 80 00 	mov    0x802700(,%eax,4),%edx
  8003ec:	85 d2                	test   %edx,%edx
  8003ee:	75 18                	jne    800408 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003f0:	50                   	push   %eax
  8003f1:	68 67 24 80 00       	push   $0x802467
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
  800409:	68 bd 28 80 00       	push   $0x8028bd
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
  80042d:	b8 60 24 80 00       	mov    $0x802460,%eax
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
  800aa8:	68 5f 27 80 00       	push   $0x80275f
  800aad:	6a 23                	push   $0x23
  800aaf:	68 7c 27 80 00       	push   $0x80277c
  800ab4:	e8 94 14 00 00       	call   801f4d <_panic>

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
  800b29:	68 5f 27 80 00       	push   $0x80275f
  800b2e:	6a 23                	push   $0x23
  800b30:	68 7c 27 80 00       	push   $0x80277c
  800b35:	e8 13 14 00 00       	call   801f4d <_panic>

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
  800b6b:	68 5f 27 80 00       	push   $0x80275f
  800b70:	6a 23                	push   $0x23
  800b72:	68 7c 27 80 00       	push   $0x80277c
  800b77:	e8 d1 13 00 00       	call   801f4d <_panic>

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
  800bad:	68 5f 27 80 00       	push   $0x80275f
  800bb2:	6a 23                	push   $0x23
  800bb4:	68 7c 27 80 00       	push   $0x80277c
  800bb9:	e8 8f 13 00 00       	call   801f4d <_panic>

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
  800bef:	68 5f 27 80 00       	push   $0x80275f
  800bf4:	6a 23                	push   $0x23
  800bf6:	68 7c 27 80 00       	push   $0x80277c
  800bfb:	e8 4d 13 00 00       	call   801f4d <_panic>

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
  800c31:	68 5f 27 80 00       	push   $0x80275f
  800c36:	6a 23                	push   $0x23
  800c38:	68 7c 27 80 00       	push   $0x80277c
  800c3d:	e8 0b 13 00 00       	call   801f4d <_panic>
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
  800c73:	68 5f 27 80 00       	push   $0x80275f
  800c78:	6a 23                	push   $0x23
  800c7a:	68 7c 27 80 00       	push   $0x80277c
  800c7f:	e8 c9 12 00 00       	call   801f4d <_panic>

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
  800cd7:	68 5f 27 80 00       	push   $0x80275f
  800cdc:	6a 23                	push   $0x23
  800cde:	68 7c 27 80 00       	push   $0x80277c
  800ce3:	e8 65 12 00 00       	call   801f4d <_panic>

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

00800d30 <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
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
  800d3b:	b8 10 00 00 00       	mov    $0x10,%eax
  800d40:	8b 55 08             	mov    0x8(%ebp),%edx
  800d43:	89 cb                	mov    %ecx,%ebx
  800d45:	89 cf                	mov    %ecx,%edi
  800d47:	89 ce                	mov    %ecx,%esi
  800d49:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  800d4b:	5b                   	pop    %ebx
  800d4c:	5e                   	pop    %esi
  800d4d:	5f                   	pop    %edi
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	53                   	push   %ebx
  800d54:	83 ec 04             	sub    $0x4,%esp
  800d57:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d5a:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800d5c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d60:	74 11                	je     800d73 <pgfault+0x23>
  800d62:	89 d8                	mov    %ebx,%eax
  800d64:	c1 e8 0c             	shr    $0xc,%eax
  800d67:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d6e:	f6 c4 08             	test   $0x8,%ah
  800d71:	75 14                	jne    800d87 <pgfault+0x37>
		panic("faulting access");
  800d73:	83 ec 04             	sub    $0x4,%esp
  800d76:	68 8a 27 80 00       	push   $0x80278a
  800d7b:	6a 1f                	push   $0x1f
  800d7d:	68 9a 27 80 00       	push   $0x80279a
  800d82:	e8 c6 11 00 00       	call   801f4d <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800d87:	83 ec 04             	sub    $0x4,%esp
  800d8a:	6a 07                	push   $0x7
  800d8c:	68 00 f0 7f 00       	push   $0x7ff000
  800d91:	6a 00                	push   $0x0
  800d93:	e8 67 fd ff ff       	call   800aff <sys_page_alloc>
	if (r < 0) {
  800d98:	83 c4 10             	add    $0x10,%esp
  800d9b:	85 c0                	test   %eax,%eax
  800d9d:	79 12                	jns    800db1 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800d9f:	50                   	push   %eax
  800da0:	68 a5 27 80 00       	push   $0x8027a5
  800da5:	6a 2d                	push   $0x2d
  800da7:	68 9a 27 80 00       	push   $0x80279a
  800dac:	e8 9c 11 00 00       	call   801f4d <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800db1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800db7:	83 ec 04             	sub    $0x4,%esp
  800dba:	68 00 10 00 00       	push   $0x1000
  800dbf:	53                   	push   %ebx
  800dc0:	68 00 f0 7f 00       	push   $0x7ff000
  800dc5:	e8 2c fb ff ff       	call   8008f6 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800dca:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800dd1:	53                   	push   %ebx
  800dd2:	6a 00                	push   $0x0
  800dd4:	68 00 f0 7f 00       	push   $0x7ff000
  800dd9:	6a 00                	push   $0x0
  800ddb:	e8 62 fd ff ff       	call   800b42 <sys_page_map>
	if (r < 0) {
  800de0:	83 c4 20             	add    $0x20,%esp
  800de3:	85 c0                	test   %eax,%eax
  800de5:	79 12                	jns    800df9 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800de7:	50                   	push   %eax
  800de8:	68 a5 27 80 00       	push   $0x8027a5
  800ded:	6a 34                	push   $0x34
  800def:	68 9a 27 80 00       	push   $0x80279a
  800df4:	e8 54 11 00 00       	call   801f4d <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800df9:	83 ec 08             	sub    $0x8,%esp
  800dfc:	68 00 f0 7f 00       	push   $0x7ff000
  800e01:	6a 00                	push   $0x0
  800e03:	e8 7c fd ff ff       	call   800b84 <sys_page_unmap>
	if (r < 0) {
  800e08:	83 c4 10             	add    $0x10,%esp
  800e0b:	85 c0                	test   %eax,%eax
  800e0d:	79 12                	jns    800e21 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e0f:	50                   	push   %eax
  800e10:	68 a5 27 80 00       	push   $0x8027a5
  800e15:	6a 38                	push   $0x38
  800e17:	68 9a 27 80 00       	push   $0x80279a
  800e1c:	e8 2c 11 00 00       	call   801f4d <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e21:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e24:	c9                   	leave  
  800e25:	c3                   	ret    

00800e26 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e26:	55                   	push   %ebp
  800e27:	89 e5                	mov    %esp,%ebp
  800e29:	57                   	push   %edi
  800e2a:	56                   	push   %esi
  800e2b:	53                   	push   %ebx
  800e2c:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e2f:	68 50 0d 80 00       	push   $0x800d50
  800e34:	e8 5a 11 00 00       	call   801f93 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e39:	b8 07 00 00 00       	mov    $0x7,%eax
  800e3e:	cd 30                	int    $0x30
  800e40:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800e43:	83 c4 10             	add    $0x10,%esp
  800e46:	85 c0                	test   %eax,%eax
  800e48:	79 17                	jns    800e61 <fork+0x3b>
		panic("fork fault %e");
  800e4a:	83 ec 04             	sub    $0x4,%esp
  800e4d:	68 be 27 80 00       	push   $0x8027be
  800e52:	68 85 00 00 00       	push   $0x85
  800e57:	68 9a 27 80 00       	push   $0x80279a
  800e5c:	e8 ec 10 00 00       	call   801f4d <_panic>
  800e61:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800e63:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e67:	75 24                	jne    800e8d <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e69:	e8 53 fc ff ff       	call   800ac1 <sys_getenvid>
  800e6e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e73:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800e79:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e7e:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800e83:	b8 00 00 00 00       	mov    $0x0,%eax
  800e88:	e9 64 01 00 00       	jmp    800ff1 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800e8d:	83 ec 04             	sub    $0x4,%esp
  800e90:	6a 07                	push   $0x7
  800e92:	68 00 f0 bf ee       	push   $0xeebff000
  800e97:	ff 75 e4             	pushl  -0x1c(%ebp)
  800e9a:	e8 60 fc ff ff       	call   800aff <sys_page_alloc>
  800e9f:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800ea2:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ea7:	89 d8                	mov    %ebx,%eax
  800ea9:	c1 e8 16             	shr    $0x16,%eax
  800eac:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800eb3:	a8 01                	test   $0x1,%al
  800eb5:	0f 84 fc 00 00 00    	je     800fb7 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800ebb:	89 d8                	mov    %ebx,%eax
  800ebd:	c1 e8 0c             	shr    $0xc,%eax
  800ec0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ec7:	f6 c2 01             	test   $0x1,%dl
  800eca:	0f 84 e7 00 00 00    	je     800fb7 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800ed0:	89 c6                	mov    %eax,%esi
  800ed2:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800ed5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800edc:	f6 c6 04             	test   $0x4,%dh
  800edf:	74 39                	je     800f1a <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800ee1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ee8:	83 ec 0c             	sub    $0xc,%esp
  800eeb:	25 07 0e 00 00       	and    $0xe07,%eax
  800ef0:	50                   	push   %eax
  800ef1:	56                   	push   %esi
  800ef2:	57                   	push   %edi
  800ef3:	56                   	push   %esi
  800ef4:	6a 00                	push   $0x0
  800ef6:	e8 47 fc ff ff       	call   800b42 <sys_page_map>
		if (r < 0) {
  800efb:	83 c4 20             	add    $0x20,%esp
  800efe:	85 c0                	test   %eax,%eax
  800f00:	0f 89 b1 00 00 00    	jns    800fb7 <fork+0x191>
		    	panic("sys page map fault %e");
  800f06:	83 ec 04             	sub    $0x4,%esp
  800f09:	68 cc 27 80 00       	push   $0x8027cc
  800f0e:	6a 55                	push   $0x55
  800f10:	68 9a 27 80 00       	push   $0x80279a
  800f15:	e8 33 10 00 00       	call   801f4d <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f1a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f21:	f6 c2 02             	test   $0x2,%dl
  800f24:	75 0c                	jne    800f32 <fork+0x10c>
  800f26:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f2d:	f6 c4 08             	test   $0x8,%ah
  800f30:	74 5b                	je     800f8d <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f32:	83 ec 0c             	sub    $0xc,%esp
  800f35:	68 05 08 00 00       	push   $0x805
  800f3a:	56                   	push   %esi
  800f3b:	57                   	push   %edi
  800f3c:	56                   	push   %esi
  800f3d:	6a 00                	push   $0x0
  800f3f:	e8 fe fb ff ff       	call   800b42 <sys_page_map>
		if (r < 0) {
  800f44:	83 c4 20             	add    $0x20,%esp
  800f47:	85 c0                	test   %eax,%eax
  800f49:	79 14                	jns    800f5f <fork+0x139>
		    	panic("sys page map fault %e");
  800f4b:	83 ec 04             	sub    $0x4,%esp
  800f4e:	68 cc 27 80 00       	push   $0x8027cc
  800f53:	6a 5c                	push   $0x5c
  800f55:	68 9a 27 80 00       	push   $0x80279a
  800f5a:	e8 ee 0f 00 00       	call   801f4d <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800f5f:	83 ec 0c             	sub    $0xc,%esp
  800f62:	68 05 08 00 00       	push   $0x805
  800f67:	56                   	push   %esi
  800f68:	6a 00                	push   $0x0
  800f6a:	56                   	push   %esi
  800f6b:	6a 00                	push   $0x0
  800f6d:	e8 d0 fb ff ff       	call   800b42 <sys_page_map>
		if (r < 0) {
  800f72:	83 c4 20             	add    $0x20,%esp
  800f75:	85 c0                	test   %eax,%eax
  800f77:	79 3e                	jns    800fb7 <fork+0x191>
		    	panic("sys page map fault %e");
  800f79:	83 ec 04             	sub    $0x4,%esp
  800f7c:	68 cc 27 80 00       	push   $0x8027cc
  800f81:	6a 60                	push   $0x60
  800f83:	68 9a 27 80 00       	push   $0x80279a
  800f88:	e8 c0 0f 00 00       	call   801f4d <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800f8d:	83 ec 0c             	sub    $0xc,%esp
  800f90:	6a 05                	push   $0x5
  800f92:	56                   	push   %esi
  800f93:	57                   	push   %edi
  800f94:	56                   	push   %esi
  800f95:	6a 00                	push   $0x0
  800f97:	e8 a6 fb ff ff       	call   800b42 <sys_page_map>
		if (r < 0) {
  800f9c:	83 c4 20             	add    $0x20,%esp
  800f9f:	85 c0                	test   %eax,%eax
  800fa1:	79 14                	jns    800fb7 <fork+0x191>
		    	panic("sys page map fault %e");
  800fa3:	83 ec 04             	sub    $0x4,%esp
  800fa6:	68 cc 27 80 00       	push   $0x8027cc
  800fab:	6a 65                	push   $0x65
  800fad:	68 9a 27 80 00       	push   $0x80279a
  800fb2:	e8 96 0f 00 00       	call   801f4d <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800fb7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fbd:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800fc3:	0f 85 de fe ff ff    	jne    800ea7 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800fc9:	a1 04 40 80 00       	mov    0x804004,%eax
  800fce:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
  800fd4:	83 ec 08             	sub    $0x8,%esp
  800fd7:	50                   	push   %eax
  800fd8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800fdb:	57                   	push   %edi
  800fdc:	e8 69 fc ff ff       	call   800c4a <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  800fe1:	83 c4 08             	add    $0x8,%esp
  800fe4:	6a 02                	push   $0x2
  800fe6:	57                   	push   %edi
  800fe7:	e8 da fb ff ff       	call   800bc6 <sys_env_set_status>
	
	return envid;
  800fec:	83 c4 10             	add    $0x10,%esp
  800fef:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  800ff1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ff4:	5b                   	pop    %ebx
  800ff5:	5e                   	pop    %esi
  800ff6:	5f                   	pop    %edi
  800ff7:	5d                   	pop    %ebp
  800ff8:	c3                   	ret    

00800ff9 <sfork>:

envid_t
sfork(void)
{
  800ff9:	55                   	push   %ebp
  800ffa:	89 e5                	mov    %esp,%ebp
	return 0;
}
  800ffc:	b8 00 00 00 00       	mov    $0x0,%eax
  801001:	5d                   	pop    %ebp
  801002:	c3                   	ret    

00801003 <thread_create>:

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  801003:	55                   	push   %ebp
  801004:	89 e5                	mov    %esp,%ebp
  801006:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  801009:	8b 45 08             	mov    0x8(%ebp),%eax
  80100c:	a3 08 40 80 00       	mov    %eax,0x804008
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801011:	68 aa 00 80 00       	push   $0x8000aa
  801016:	e8 d5 fc ff ff       	call   800cf0 <sys_thread_create>

	return id;
}
  80101b:	c9                   	leave  
  80101c:	c3                   	ret    

0080101d <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  80101d:	55                   	push   %ebp
  80101e:	89 e5                	mov    %esp,%ebp
  801020:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  801023:	ff 75 08             	pushl  0x8(%ebp)
  801026:	e8 e5 fc ff ff       	call   800d10 <sys_thread_free>
}
  80102b:	83 c4 10             	add    $0x10,%esp
  80102e:	c9                   	leave  
  80102f:	c3                   	ret    

00801030 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  801036:	ff 75 08             	pushl  0x8(%ebp)
  801039:	e8 f2 fc ff ff       	call   800d30 <sys_thread_join>
}
  80103e:	83 c4 10             	add    $0x10,%esp
  801041:	c9                   	leave  
  801042:	c3                   	ret    

00801043 <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  801043:	55                   	push   %ebp
  801044:	89 e5                	mov    %esp,%ebp
  801046:	56                   	push   %esi
  801047:	53                   	push   %ebx
  801048:	8b 75 08             	mov    0x8(%ebp),%esi
  80104b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  80104e:	83 ec 04             	sub    $0x4,%esp
  801051:	6a 07                	push   $0x7
  801053:	6a 00                	push   $0x0
  801055:	56                   	push   %esi
  801056:	e8 a4 fa ff ff       	call   800aff <sys_page_alloc>
	if (r < 0) {
  80105b:	83 c4 10             	add    $0x10,%esp
  80105e:	85 c0                	test   %eax,%eax
  801060:	79 15                	jns    801077 <queue_append+0x34>
		panic("%e\n", r);
  801062:	50                   	push   %eax
  801063:	68 12 28 80 00       	push   $0x802812
  801068:	68 d5 00 00 00       	push   $0xd5
  80106d:	68 9a 27 80 00       	push   $0x80279a
  801072:	e8 d6 0e 00 00       	call   801f4d <_panic>
	}	

	wt->envid = envid;
  801077:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  80107d:	83 3b 00             	cmpl   $0x0,(%ebx)
  801080:	75 13                	jne    801095 <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  801082:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  801089:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801090:	00 00 00 
  801093:	eb 1b                	jmp    8010b0 <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  801095:	8b 43 04             	mov    0x4(%ebx),%eax
  801098:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  80109f:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8010a6:	00 00 00 
		queue->last = wt;
  8010a9:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8010b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010b3:	5b                   	pop    %ebx
  8010b4:	5e                   	pop    %esi
  8010b5:	5d                   	pop    %ebp
  8010b6:	c3                   	ret    

008010b7 <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  8010b7:	55                   	push   %ebp
  8010b8:	89 e5                	mov    %esp,%ebp
  8010ba:	83 ec 08             	sub    $0x8,%esp
  8010bd:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  8010c0:	8b 02                	mov    (%edx),%eax
  8010c2:	85 c0                	test   %eax,%eax
  8010c4:	75 17                	jne    8010dd <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  8010c6:	83 ec 04             	sub    $0x4,%esp
  8010c9:	68 e2 27 80 00       	push   $0x8027e2
  8010ce:	68 ec 00 00 00       	push   $0xec
  8010d3:	68 9a 27 80 00       	push   $0x80279a
  8010d8:	e8 70 0e 00 00       	call   801f4d <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  8010dd:	8b 48 04             	mov    0x4(%eax),%ecx
  8010e0:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  8010e2:	8b 00                	mov    (%eax),%eax
}
  8010e4:	c9                   	leave  
  8010e5:	c3                   	ret    

008010e6 <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  8010e6:	55                   	push   %ebp
  8010e7:	89 e5                	mov    %esp,%ebp
  8010e9:	56                   	push   %esi
  8010ea:	53                   	push   %ebx
  8010eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  8010ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8010f3:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8010f6:	85 c0                	test   %eax,%eax
  8010f8:	74 4a                	je     801144 <mutex_lock+0x5e>
  8010fa:	8b 73 04             	mov    0x4(%ebx),%esi
  8010fd:	83 3e 00             	cmpl   $0x0,(%esi)
  801100:	75 42                	jne    801144 <mutex_lock+0x5e>
		queue_append(sys_getenvid(), mtx->queue);		
  801102:	e8 ba f9 ff ff       	call   800ac1 <sys_getenvid>
  801107:	83 ec 08             	sub    $0x8,%esp
  80110a:	56                   	push   %esi
  80110b:	50                   	push   %eax
  80110c:	e8 32 ff ff ff       	call   801043 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  801111:	e8 ab f9 ff ff       	call   800ac1 <sys_getenvid>
  801116:	83 c4 08             	add    $0x8,%esp
  801119:	6a 04                	push   $0x4
  80111b:	50                   	push   %eax
  80111c:	e8 a5 fa ff ff       	call   800bc6 <sys_env_set_status>

		if (r < 0) {
  801121:	83 c4 10             	add    $0x10,%esp
  801124:	85 c0                	test   %eax,%eax
  801126:	79 15                	jns    80113d <mutex_lock+0x57>
			panic("%e\n", r);
  801128:	50                   	push   %eax
  801129:	68 12 28 80 00       	push   $0x802812
  80112e:	68 02 01 00 00       	push   $0x102
  801133:	68 9a 27 80 00       	push   $0x80279a
  801138:	e8 10 0e 00 00       	call   801f4d <_panic>
		}
		sys_yield();
  80113d:	e8 9e f9 ff ff       	call   800ae0 <sys_yield>
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801142:	eb 08                	jmp    80114c <mutex_lock+0x66>
		if (r < 0) {
			panic("%e\n", r);
		}
		sys_yield();
	} else {
		mtx->owner = sys_getenvid();
  801144:	e8 78 f9 ff ff       	call   800ac1 <sys_getenvid>
  801149:	89 43 08             	mov    %eax,0x8(%ebx)
	}
}
  80114c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80114f:	5b                   	pop    %ebx
  801150:	5e                   	pop    %esi
  801151:	5d                   	pop    %ebp
  801152:	c3                   	ret    

00801153 <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	53                   	push   %ebx
  801157:	83 ec 04             	sub    $0x4,%esp
  80115a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80115d:	b8 00 00 00 00       	mov    $0x0,%eax
  801162:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  801165:	8b 43 04             	mov    0x4(%ebx),%eax
  801168:	83 38 00             	cmpl   $0x0,(%eax)
  80116b:	74 33                	je     8011a0 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  80116d:	83 ec 0c             	sub    $0xc,%esp
  801170:	50                   	push   %eax
  801171:	e8 41 ff ff ff       	call   8010b7 <queue_pop>
  801176:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  801179:	83 c4 08             	add    $0x8,%esp
  80117c:	6a 02                	push   $0x2
  80117e:	50                   	push   %eax
  80117f:	e8 42 fa ff ff       	call   800bc6 <sys_env_set_status>
		if (r < 0) {
  801184:	83 c4 10             	add    $0x10,%esp
  801187:	85 c0                	test   %eax,%eax
  801189:	79 15                	jns    8011a0 <mutex_unlock+0x4d>
			panic("%e\n", r);
  80118b:	50                   	push   %eax
  80118c:	68 12 28 80 00       	push   $0x802812
  801191:	68 16 01 00 00       	push   $0x116
  801196:	68 9a 27 80 00       	push   $0x80279a
  80119b:	e8 ad 0d 00 00       	call   801f4d <_panic>
		}
	}

	//asm volatile("pause"); 	// might be useless here
}
  8011a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011a3:	c9                   	leave  
  8011a4:	c3                   	ret    

008011a5 <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  8011a5:	55                   	push   %ebp
  8011a6:	89 e5                	mov    %esp,%ebp
  8011a8:	53                   	push   %ebx
  8011a9:	83 ec 04             	sub    $0x4,%esp
  8011ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  8011af:	e8 0d f9 ff ff       	call   800ac1 <sys_getenvid>
  8011b4:	83 ec 04             	sub    $0x4,%esp
  8011b7:	6a 07                	push   $0x7
  8011b9:	53                   	push   %ebx
  8011ba:	50                   	push   %eax
  8011bb:	e8 3f f9 ff ff       	call   800aff <sys_page_alloc>
  8011c0:	83 c4 10             	add    $0x10,%esp
  8011c3:	85 c0                	test   %eax,%eax
  8011c5:	79 15                	jns    8011dc <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  8011c7:	50                   	push   %eax
  8011c8:	68 fd 27 80 00       	push   $0x8027fd
  8011cd:	68 22 01 00 00       	push   $0x122
  8011d2:	68 9a 27 80 00       	push   $0x80279a
  8011d7:	e8 71 0d 00 00       	call   801f4d <_panic>
	}	
	mtx->locked = 0;
  8011dc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  8011e2:	8b 43 04             	mov    0x4(%ebx),%eax
  8011e5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  8011eb:	8b 43 04             	mov    0x4(%ebx),%eax
  8011ee:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  8011f5:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  8011fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ff:	c9                   	leave  
  801200:	c3                   	ret    

00801201 <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  801201:	55                   	push   %ebp
  801202:	89 e5                	mov    %esp,%ebp
  801204:	53                   	push   %ebx
  801205:	83 ec 04             	sub    $0x4,%esp
  801208:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue->first != NULL) {
  80120b:	eb 21                	jmp    80122e <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
  80120d:	83 ec 0c             	sub    $0xc,%esp
  801210:	50                   	push   %eax
  801211:	e8 a1 fe ff ff       	call   8010b7 <queue_pop>
  801216:	83 c4 08             	add    $0x8,%esp
  801219:	6a 02                	push   $0x2
  80121b:	50                   	push   %eax
  80121c:	e8 a5 f9 ff ff       	call   800bc6 <sys_env_set_status>
		mtx->queue->first = mtx->queue->first->next;
  801221:	8b 43 04             	mov    0x4(%ebx),%eax
  801224:	8b 10                	mov    (%eax),%edx
  801226:	8b 52 04             	mov    0x4(%edx),%edx
  801229:	89 10                	mov    %edx,(%eax)
  80122b:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue->first != NULL) {
  80122e:	8b 43 04             	mov    0x4(%ebx),%eax
  801231:	83 38 00             	cmpl   $0x0,(%eax)
  801234:	75 d7                	jne    80120d <mutex_destroy+0xc>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
		mtx->queue->first = mtx->queue->first->next;
	}

	memset(mtx, 0, PGSIZE);
  801236:	83 ec 04             	sub    $0x4,%esp
  801239:	68 00 10 00 00       	push   $0x1000
  80123e:	6a 00                	push   $0x0
  801240:	53                   	push   %ebx
  801241:	e8 fb f5 ff ff       	call   800841 <memset>
	mtx = NULL;
}
  801246:	83 c4 10             	add    $0x10,%esp
  801249:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80124c:	c9                   	leave  
  80124d:	c3                   	ret    

0080124e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80124e:	55                   	push   %ebp
  80124f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801251:	8b 45 08             	mov    0x8(%ebp),%eax
  801254:	05 00 00 00 30       	add    $0x30000000,%eax
  801259:	c1 e8 0c             	shr    $0xc,%eax
}
  80125c:	5d                   	pop    %ebp
  80125d:	c3                   	ret    

0080125e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80125e:	55                   	push   %ebp
  80125f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801261:	8b 45 08             	mov    0x8(%ebp),%eax
  801264:	05 00 00 00 30       	add    $0x30000000,%eax
  801269:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80126e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801273:	5d                   	pop    %ebp
  801274:	c3                   	ret    

00801275 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801275:	55                   	push   %ebp
  801276:	89 e5                	mov    %esp,%ebp
  801278:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80127b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801280:	89 c2                	mov    %eax,%edx
  801282:	c1 ea 16             	shr    $0x16,%edx
  801285:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80128c:	f6 c2 01             	test   $0x1,%dl
  80128f:	74 11                	je     8012a2 <fd_alloc+0x2d>
  801291:	89 c2                	mov    %eax,%edx
  801293:	c1 ea 0c             	shr    $0xc,%edx
  801296:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80129d:	f6 c2 01             	test   $0x1,%dl
  8012a0:	75 09                	jne    8012ab <fd_alloc+0x36>
			*fd_store = fd;
  8012a2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a9:	eb 17                	jmp    8012c2 <fd_alloc+0x4d>
  8012ab:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012b0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012b5:	75 c9                	jne    801280 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012b7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012bd:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012c2:	5d                   	pop    %ebp
  8012c3:	c3                   	ret    

008012c4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
  8012c7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012ca:	83 f8 1f             	cmp    $0x1f,%eax
  8012cd:	77 36                	ja     801305 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012cf:	c1 e0 0c             	shl    $0xc,%eax
  8012d2:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012d7:	89 c2                	mov    %eax,%edx
  8012d9:	c1 ea 16             	shr    $0x16,%edx
  8012dc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012e3:	f6 c2 01             	test   $0x1,%dl
  8012e6:	74 24                	je     80130c <fd_lookup+0x48>
  8012e8:	89 c2                	mov    %eax,%edx
  8012ea:	c1 ea 0c             	shr    $0xc,%edx
  8012ed:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012f4:	f6 c2 01             	test   $0x1,%dl
  8012f7:	74 1a                	je     801313 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012fc:	89 02                	mov    %eax,(%edx)
	return 0;
  8012fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801303:	eb 13                	jmp    801318 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801305:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80130a:	eb 0c                	jmp    801318 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80130c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801311:	eb 05                	jmp    801318 <fd_lookup+0x54>
  801313:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801318:	5d                   	pop    %ebp
  801319:	c3                   	ret    

0080131a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80131a:	55                   	push   %ebp
  80131b:	89 e5                	mov    %esp,%ebp
  80131d:	83 ec 08             	sub    $0x8,%esp
  801320:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801323:	ba 94 28 80 00       	mov    $0x802894,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801328:	eb 13                	jmp    80133d <dev_lookup+0x23>
  80132a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80132d:	39 08                	cmp    %ecx,(%eax)
  80132f:	75 0c                	jne    80133d <dev_lookup+0x23>
			*dev = devtab[i];
  801331:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801334:	89 01                	mov    %eax,(%ecx)
			return 0;
  801336:	b8 00 00 00 00       	mov    $0x0,%eax
  80133b:	eb 31                	jmp    80136e <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80133d:	8b 02                	mov    (%edx),%eax
  80133f:	85 c0                	test   %eax,%eax
  801341:	75 e7                	jne    80132a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801343:	a1 04 40 80 00       	mov    0x804004,%eax
  801348:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80134e:	83 ec 04             	sub    $0x4,%esp
  801351:	51                   	push   %ecx
  801352:	50                   	push   %eax
  801353:	68 18 28 80 00       	push   $0x802818
  801358:	e8 1a ee ff ff       	call   800177 <cprintf>
	*dev = 0;
  80135d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801360:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801366:	83 c4 10             	add    $0x10,%esp
  801369:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80136e:	c9                   	leave  
  80136f:	c3                   	ret    

00801370 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801370:	55                   	push   %ebp
  801371:	89 e5                	mov    %esp,%ebp
  801373:	56                   	push   %esi
  801374:	53                   	push   %ebx
  801375:	83 ec 10             	sub    $0x10,%esp
  801378:	8b 75 08             	mov    0x8(%ebp),%esi
  80137b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80137e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801381:	50                   	push   %eax
  801382:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801388:	c1 e8 0c             	shr    $0xc,%eax
  80138b:	50                   	push   %eax
  80138c:	e8 33 ff ff ff       	call   8012c4 <fd_lookup>
  801391:	83 c4 08             	add    $0x8,%esp
  801394:	85 c0                	test   %eax,%eax
  801396:	78 05                	js     80139d <fd_close+0x2d>
	    || fd != fd2)
  801398:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80139b:	74 0c                	je     8013a9 <fd_close+0x39>
		return (must_exist ? r : 0);
  80139d:	84 db                	test   %bl,%bl
  80139f:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a4:	0f 44 c2             	cmove  %edx,%eax
  8013a7:	eb 41                	jmp    8013ea <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013a9:	83 ec 08             	sub    $0x8,%esp
  8013ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013af:	50                   	push   %eax
  8013b0:	ff 36                	pushl  (%esi)
  8013b2:	e8 63 ff ff ff       	call   80131a <dev_lookup>
  8013b7:	89 c3                	mov    %eax,%ebx
  8013b9:	83 c4 10             	add    $0x10,%esp
  8013bc:	85 c0                	test   %eax,%eax
  8013be:	78 1a                	js     8013da <fd_close+0x6a>
		if (dev->dev_close)
  8013c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013c6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013cb:	85 c0                	test   %eax,%eax
  8013cd:	74 0b                	je     8013da <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013cf:	83 ec 0c             	sub    $0xc,%esp
  8013d2:	56                   	push   %esi
  8013d3:	ff d0                	call   *%eax
  8013d5:	89 c3                	mov    %eax,%ebx
  8013d7:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013da:	83 ec 08             	sub    $0x8,%esp
  8013dd:	56                   	push   %esi
  8013de:	6a 00                	push   $0x0
  8013e0:	e8 9f f7 ff ff       	call   800b84 <sys_page_unmap>
	return r;
  8013e5:	83 c4 10             	add    $0x10,%esp
  8013e8:	89 d8                	mov    %ebx,%eax
}
  8013ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ed:	5b                   	pop    %ebx
  8013ee:	5e                   	pop    %esi
  8013ef:	5d                   	pop    %ebp
  8013f0:	c3                   	ret    

008013f1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013f1:	55                   	push   %ebp
  8013f2:	89 e5                	mov    %esp,%ebp
  8013f4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013fa:	50                   	push   %eax
  8013fb:	ff 75 08             	pushl  0x8(%ebp)
  8013fe:	e8 c1 fe ff ff       	call   8012c4 <fd_lookup>
  801403:	83 c4 08             	add    $0x8,%esp
  801406:	85 c0                	test   %eax,%eax
  801408:	78 10                	js     80141a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80140a:	83 ec 08             	sub    $0x8,%esp
  80140d:	6a 01                	push   $0x1
  80140f:	ff 75 f4             	pushl  -0xc(%ebp)
  801412:	e8 59 ff ff ff       	call   801370 <fd_close>
  801417:	83 c4 10             	add    $0x10,%esp
}
  80141a:	c9                   	leave  
  80141b:	c3                   	ret    

0080141c <close_all>:

void
close_all(void)
{
  80141c:	55                   	push   %ebp
  80141d:	89 e5                	mov    %esp,%ebp
  80141f:	53                   	push   %ebx
  801420:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801423:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801428:	83 ec 0c             	sub    $0xc,%esp
  80142b:	53                   	push   %ebx
  80142c:	e8 c0 ff ff ff       	call   8013f1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801431:	83 c3 01             	add    $0x1,%ebx
  801434:	83 c4 10             	add    $0x10,%esp
  801437:	83 fb 20             	cmp    $0x20,%ebx
  80143a:	75 ec                	jne    801428 <close_all+0xc>
		close(i);
}
  80143c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80143f:	c9                   	leave  
  801440:	c3                   	ret    

00801441 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801441:	55                   	push   %ebp
  801442:	89 e5                	mov    %esp,%ebp
  801444:	57                   	push   %edi
  801445:	56                   	push   %esi
  801446:	53                   	push   %ebx
  801447:	83 ec 2c             	sub    $0x2c,%esp
  80144a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80144d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801450:	50                   	push   %eax
  801451:	ff 75 08             	pushl  0x8(%ebp)
  801454:	e8 6b fe ff ff       	call   8012c4 <fd_lookup>
  801459:	83 c4 08             	add    $0x8,%esp
  80145c:	85 c0                	test   %eax,%eax
  80145e:	0f 88 c1 00 00 00    	js     801525 <dup+0xe4>
		return r;
	close(newfdnum);
  801464:	83 ec 0c             	sub    $0xc,%esp
  801467:	56                   	push   %esi
  801468:	e8 84 ff ff ff       	call   8013f1 <close>

	newfd = INDEX2FD(newfdnum);
  80146d:	89 f3                	mov    %esi,%ebx
  80146f:	c1 e3 0c             	shl    $0xc,%ebx
  801472:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801478:	83 c4 04             	add    $0x4,%esp
  80147b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80147e:	e8 db fd ff ff       	call   80125e <fd2data>
  801483:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801485:	89 1c 24             	mov    %ebx,(%esp)
  801488:	e8 d1 fd ff ff       	call   80125e <fd2data>
  80148d:	83 c4 10             	add    $0x10,%esp
  801490:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801493:	89 f8                	mov    %edi,%eax
  801495:	c1 e8 16             	shr    $0x16,%eax
  801498:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80149f:	a8 01                	test   $0x1,%al
  8014a1:	74 37                	je     8014da <dup+0x99>
  8014a3:	89 f8                	mov    %edi,%eax
  8014a5:	c1 e8 0c             	shr    $0xc,%eax
  8014a8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014af:	f6 c2 01             	test   $0x1,%dl
  8014b2:	74 26                	je     8014da <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014b4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014bb:	83 ec 0c             	sub    $0xc,%esp
  8014be:	25 07 0e 00 00       	and    $0xe07,%eax
  8014c3:	50                   	push   %eax
  8014c4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014c7:	6a 00                	push   $0x0
  8014c9:	57                   	push   %edi
  8014ca:	6a 00                	push   $0x0
  8014cc:	e8 71 f6 ff ff       	call   800b42 <sys_page_map>
  8014d1:	89 c7                	mov    %eax,%edi
  8014d3:	83 c4 20             	add    $0x20,%esp
  8014d6:	85 c0                	test   %eax,%eax
  8014d8:	78 2e                	js     801508 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014da:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014dd:	89 d0                	mov    %edx,%eax
  8014df:	c1 e8 0c             	shr    $0xc,%eax
  8014e2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014e9:	83 ec 0c             	sub    $0xc,%esp
  8014ec:	25 07 0e 00 00       	and    $0xe07,%eax
  8014f1:	50                   	push   %eax
  8014f2:	53                   	push   %ebx
  8014f3:	6a 00                	push   $0x0
  8014f5:	52                   	push   %edx
  8014f6:	6a 00                	push   $0x0
  8014f8:	e8 45 f6 ff ff       	call   800b42 <sys_page_map>
  8014fd:	89 c7                	mov    %eax,%edi
  8014ff:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801502:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801504:	85 ff                	test   %edi,%edi
  801506:	79 1d                	jns    801525 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801508:	83 ec 08             	sub    $0x8,%esp
  80150b:	53                   	push   %ebx
  80150c:	6a 00                	push   $0x0
  80150e:	e8 71 f6 ff ff       	call   800b84 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801513:	83 c4 08             	add    $0x8,%esp
  801516:	ff 75 d4             	pushl  -0x2c(%ebp)
  801519:	6a 00                	push   $0x0
  80151b:	e8 64 f6 ff ff       	call   800b84 <sys_page_unmap>
	return r;
  801520:	83 c4 10             	add    $0x10,%esp
  801523:	89 f8                	mov    %edi,%eax
}
  801525:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801528:	5b                   	pop    %ebx
  801529:	5e                   	pop    %esi
  80152a:	5f                   	pop    %edi
  80152b:	5d                   	pop    %ebp
  80152c:	c3                   	ret    

0080152d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80152d:	55                   	push   %ebp
  80152e:	89 e5                	mov    %esp,%ebp
  801530:	53                   	push   %ebx
  801531:	83 ec 14             	sub    $0x14,%esp
  801534:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801537:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80153a:	50                   	push   %eax
  80153b:	53                   	push   %ebx
  80153c:	e8 83 fd ff ff       	call   8012c4 <fd_lookup>
  801541:	83 c4 08             	add    $0x8,%esp
  801544:	89 c2                	mov    %eax,%edx
  801546:	85 c0                	test   %eax,%eax
  801548:	78 70                	js     8015ba <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154a:	83 ec 08             	sub    $0x8,%esp
  80154d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801550:	50                   	push   %eax
  801551:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801554:	ff 30                	pushl  (%eax)
  801556:	e8 bf fd ff ff       	call   80131a <dev_lookup>
  80155b:	83 c4 10             	add    $0x10,%esp
  80155e:	85 c0                	test   %eax,%eax
  801560:	78 4f                	js     8015b1 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801562:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801565:	8b 42 08             	mov    0x8(%edx),%eax
  801568:	83 e0 03             	and    $0x3,%eax
  80156b:	83 f8 01             	cmp    $0x1,%eax
  80156e:	75 24                	jne    801594 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801570:	a1 04 40 80 00       	mov    0x804004,%eax
  801575:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80157b:	83 ec 04             	sub    $0x4,%esp
  80157e:	53                   	push   %ebx
  80157f:	50                   	push   %eax
  801580:	68 59 28 80 00       	push   $0x802859
  801585:	e8 ed eb ff ff       	call   800177 <cprintf>
		return -E_INVAL;
  80158a:	83 c4 10             	add    $0x10,%esp
  80158d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801592:	eb 26                	jmp    8015ba <read+0x8d>
	}
	if (!dev->dev_read)
  801594:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801597:	8b 40 08             	mov    0x8(%eax),%eax
  80159a:	85 c0                	test   %eax,%eax
  80159c:	74 17                	je     8015b5 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80159e:	83 ec 04             	sub    $0x4,%esp
  8015a1:	ff 75 10             	pushl  0x10(%ebp)
  8015a4:	ff 75 0c             	pushl  0xc(%ebp)
  8015a7:	52                   	push   %edx
  8015a8:	ff d0                	call   *%eax
  8015aa:	89 c2                	mov    %eax,%edx
  8015ac:	83 c4 10             	add    $0x10,%esp
  8015af:	eb 09                	jmp    8015ba <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b1:	89 c2                	mov    %eax,%edx
  8015b3:	eb 05                	jmp    8015ba <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8015ba:	89 d0                	mov    %edx,%eax
  8015bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015bf:	c9                   	leave  
  8015c0:	c3                   	ret    

008015c1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015c1:	55                   	push   %ebp
  8015c2:	89 e5                	mov    %esp,%ebp
  8015c4:	57                   	push   %edi
  8015c5:	56                   	push   %esi
  8015c6:	53                   	push   %ebx
  8015c7:	83 ec 0c             	sub    $0xc,%esp
  8015ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015cd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015d5:	eb 21                	jmp    8015f8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015d7:	83 ec 04             	sub    $0x4,%esp
  8015da:	89 f0                	mov    %esi,%eax
  8015dc:	29 d8                	sub    %ebx,%eax
  8015de:	50                   	push   %eax
  8015df:	89 d8                	mov    %ebx,%eax
  8015e1:	03 45 0c             	add    0xc(%ebp),%eax
  8015e4:	50                   	push   %eax
  8015e5:	57                   	push   %edi
  8015e6:	e8 42 ff ff ff       	call   80152d <read>
		if (m < 0)
  8015eb:	83 c4 10             	add    $0x10,%esp
  8015ee:	85 c0                	test   %eax,%eax
  8015f0:	78 10                	js     801602 <readn+0x41>
			return m;
		if (m == 0)
  8015f2:	85 c0                	test   %eax,%eax
  8015f4:	74 0a                	je     801600 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015f6:	01 c3                	add    %eax,%ebx
  8015f8:	39 f3                	cmp    %esi,%ebx
  8015fa:	72 db                	jb     8015d7 <readn+0x16>
  8015fc:	89 d8                	mov    %ebx,%eax
  8015fe:	eb 02                	jmp    801602 <readn+0x41>
  801600:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801602:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801605:	5b                   	pop    %ebx
  801606:	5e                   	pop    %esi
  801607:	5f                   	pop    %edi
  801608:	5d                   	pop    %ebp
  801609:	c3                   	ret    

0080160a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	53                   	push   %ebx
  80160e:	83 ec 14             	sub    $0x14,%esp
  801611:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801614:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801617:	50                   	push   %eax
  801618:	53                   	push   %ebx
  801619:	e8 a6 fc ff ff       	call   8012c4 <fd_lookup>
  80161e:	83 c4 08             	add    $0x8,%esp
  801621:	89 c2                	mov    %eax,%edx
  801623:	85 c0                	test   %eax,%eax
  801625:	78 6b                	js     801692 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801627:	83 ec 08             	sub    $0x8,%esp
  80162a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162d:	50                   	push   %eax
  80162e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801631:	ff 30                	pushl  (%eax)
  801633:	e8 e2 fc ff ff       	call   80131a <dev_lookup>
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	85 c0                	test   %eax,%eax
  80163d:	78 4a                	js     801689 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80163f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801642:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801646:	75 24                	jne    80166c <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801648:	a1 04 40 80 00       	mov    0x804004,%eax
  80164d:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801653:	83 ec 04             	sub    $0x4,%esp
  801656:	53                   	push   %ebx
  801657:	50                   	push   %eax
  801658:	68 75 28 80 00       	push   $0x802875
  80165d:	e8 15 eb ff ff       	call   800177 <cprintf>
		return -E_INVAL;
  801662:	83 c4 10             	add    $0x10,%esp
  801665:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80166a:	eb 26                	jmp    801692 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80166c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80166f:	8b 52 0c             	mov    0xc(%edx),%edx
  801672:	85 d2                	test   %edx,%edx
  801674:	74 17                	je     80168d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801676:	83 ec 04             	sub    $0x4,%esp
  801679:	ff 75 10             	pushl  0x10(%ebp)
  80167c:	ff 75 0c             	pushl  0xc(%ebp)
  80167f:	50                   	push   %eax
  801680:	ff d2                	call   *%edx
  801682:	89 c2                	mov    %eax,%edx
  801684:	83 c4 10             	add    $0x10,%esp
  801687:	eb 09                	jmp    801692 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801689:	89 c2                	mov    %eax,%edx
  80168b:	eb 05                	jmp    801692 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80168d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801692:	89 d0                	mov    %edx,%eax
  801694:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801697:	c9                   	leave  
  801698:	c3                   	ret    

00801699 <seek>:

int
seek(int fdnum, off_t offset)
{
  801699:	55                   	push   %ebp
  80169a:	89 e5                	mov    %esp,%ebp
  80169c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80169f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016a2:	50                   	push   %eax
  8016a3:	ff 75 08             	pushl  0x8(%ebp)
  8016a6:	e8 19 fc ff ff       	call   8012c4 <fd_lookup>
  8016ab:	83 c4 08             	add    $0x8,%esp
  8016ae:	85 c0                	test   %eax,%eax
  8016b0:	78 0e                	js     8016c0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016b8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016c0:	c9                   	leave  
  8016c1:	c3                   	ret    

008016c2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016c2:	55                   	push   %ebp
  8016c3:	89 e5                	mov    %esp,%ebp
  8016c5:	53                   	push   %ebx
  8016c6:	83 ec 14             	sub    $0x14,%esp
  8016c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016cf:	50                   	push   %eax
  8016d0:	53                   	push   %ebx
  8016d1:	e8 ee fb ff ff       	call   8012c4 <fd_lookup>
  8016d6:	83 c4 08             	add    $0x8,%esp
  8016d9:	89 c2                	mov    %eax,%edx
  8016db:	85 c0                	test   %eax,%eax
  8016dd:	78 68                	js     801747 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016df:	83 ec 08             	sub    $0x8,%esp
  8016e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e5:	50                   	push   %eax
  8016e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e9:	ff 30                	pushl  (%eax)
  8016eb:	e8 2a fc ff ff       	call   80131a <dev_lookup>
  8016f0:	83 c4 10             	add    $0x10,%esp
  8016f3:	85 c0                	test   %eax,%eax
  8016f5:	78 47                	js     80173e <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016fa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016fe:	75 24                	jne    801724 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801700:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801705:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80170b:	83 ec 04             	sub    $0x4,%esp
  80170e:	53                   	push   %ebx
  80170f:	50                   	push   %eax
  801710:	68 38 28 80 00       	push   $0x802838
  801715:	e8 5d ea ff ff       	call   800177 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80171a:	83 c4 10             	add    $0x10,%esp
  80171d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801722:	eb 23                	jmp    801747 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801724:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801727:	8b 52 18             	mov    0x18(%edx),%edx
  80172a:	85 d2                	test   %edx,%edx
  80172c:	74 14                	je     801742 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80172e:	83 ec 08             	sub    $0x8,%esp
  801731:	ff 75 0c             	pushl  0xc(%ebp)
  801734:	50                   	push   %eax
  801735:	ff d2                	call   *%edx
  801737:	89 c2                	mov    %eax,%edx
  801739:	83 c4 10             	add    $0x10,%esp
  80173c:	eb 09                	jmp    801747 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80173e:	89 c2                	mov    %eax,%edx
  801740:	eb 05                	jmp    801747 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801742:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801747:	89 d0                	mov    %edx,%eax
  801749:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80174c:	c9                   	leave  
  80174d:	c3                   	ret    

0080174e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80174e:	55                   	push   %ebp
  80174f:	89 e5                	mov    %esp,%ebp
  801751:	53                   	push   %ebx
  801752:	83 ec 14             	sub    $0x14,%esp
  801755:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801758:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80175b:	50                   	push   %eax
  80175c:	ff 75 08             	pushl  0x8(%ebp)
  80175f:	e8 60 fb ff ff       	call   8012c4 <fd_lookup>
  801764:	83 c4 08             	add    $0x8,%esp
  801767:	89 c2                	mov    %eax,%edx
  801769:	85 c0                	test   %eax,%eax
  80176b:	78 58                	js     8017c5 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80176d:	83 ec 08             	sub    $0x8,%esp
  801770:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801773:	50                   	push   %eax
  801774:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801777:	ff 30                	pushl  (%eax)
  801779:	e8 9c fb ff ff       	call   80131a <dev_lookup>
  80177e:	83 c4 10             	add    $0x10,%esp
  801781:	85 c0                	test   %eax,%eax
  801783:	78 37                	js     8017bc <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801785:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801788:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80178c:	74 32                	je     8017c0 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80178e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801791:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801798:	00 00 00 
	stat->st_isdir = 0;
  80179b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017a2:	00 00 00 
	stat->st_dev = dev;
  8017a5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017ab:	83 ec 08             	sub    $0x8,%esp
  8017ae:	53                   	push   %ebx
  8017af:	ff 75 f0             	pushl  -0x10(%ebp)
  8017b2:	ff 50 14             	call   *0x14(%eax)
  8017b5:	89 c2                	mov    %eax,%edx
  8017b7:	83 c4 10             	add    $0x10,%esp
  8017ba:	eb 09                	jmp    8017c5 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017bc:	89 c2                	mov    %eax,%edx
  8017be:	eb 05                	jmp    8017c5 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017c0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017c5:	89 d0                	mov    %edx,%eax
  8017c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ca:	c9                   	leave  
  8017cb:	c3                   	ret    

008017cc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	56                   	push   %esi
  8017d0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017d1:	83 ec 08             	sub    $0x8,%esp
  8017d4:	6a 00                	push   $0x0
  8017d6:	ff 75 08             	pushl  0x8(%ebp)
  8017d9:	e8 e3 01 00 00       	call   8019c1 <open>
  8017de:	89 c3                	mov    %eax,%ebx
  8017e0:	83 c4 10             	add    $0x10,%esp
  8017e3:	85 c0                	test   %eax,%eax
  8017e5:	78 1b                	js     801802 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017e7:	83 ec 08             	sub    $0x8,%esp
  8017ea:	ff 75 0c             	pushl  0xc(%ebp)
  8017ed:	50                   	push   %eax
  8017ee:	e8 5b ff ff ff       	call   80174e <fstat>
  8017f3:	89 c6                	mov    %eax,%esi
	close(fd);
  8017f5:	89 1c 24             	mov    %ebx,(%esp)
  8017f8:	e8 f4 fb ff ff       	call   8013f1 <close>
	return r;
  8017fd:	83 c4 10             	add    $0x10,%esp
  801800:	89 f0                	mov    %esi,%eax
}
  801802:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801805:	5b                   	pop    %ebx
  801806:	5e                   	pop    %esi
  801807:	5d                   	pop    %ebp
  801808:	c3                   	ret    

00801809 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801809:	55                   	push   %ebp
  80180a:	89 e5                	mov    %esp,%ebp
  80180c:	56                   	push   %esi
  80180d:	53                   	push   %ebx
  80180e:	89 c6                	mov    %eax,%esi
  801810:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801812:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801819:	75 12                	jne    80182d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80181b:	83 ec 0c             	sub    $0xc,%esp
  80181e:	6a 01                	push   $0x1
  801820:	e8 da 08 00 00       	call   8020ff <ipc_find_env>
  801825:	a3 00 40 80 00       	mov    %eax,0x804000
  80182a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80182d:	6a 07                	push   $0x7
  80182f:	68 00 50 80 00       	push   $0x805000
  801834:	56                   	push   %esi
  801835:	ff 35 00 40 80 00    	pushl  0x804000
  80183b:	e8 5d 08 00 00       	call   80209d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801840:	83 c4 0c             	add    $0xc,%esp
  801843:	6a 00                	push   $0x0
  801845:	53                   	push   %ebx
  801846:	6a 00                	push   $0x0
  801848:	e8 d5 07 00 00       	call   802022 <ipc_recv>
}
  80184d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801850:	5b                   	pop    %ebx
  801851:	5e                   	pop    %esi
  801852:	5d                   	pop    %ebp
  801853:	c3                   	ret    

00801854 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801854:	55                   	push   %ebp
  801855:	89 e5                	mov    %esp,%ebp
  801857:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80185a:	8b 45 08             	mov    0x8(%ebp),%eax
  80185d:	8b 40 0c             	mov    0xc(%eax),%eax
  801860:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801865:	8b 45 0c             	mov    0xc(%ebp),%eax
  801868:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80186d:	ba 00 00 00 00       	mov    $0x0,%edx
  801872:	b8 02 00 00 00       	mov    $0x2,%eax
  801877:	e8 8d ff ff ff       	call   801809 <fsipc>
}
  80187c:	c9                   	leave  
  80187d:	c3                   	ret    

0080187e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801884:	8b 45 08             	mov    0x8(%ebp),%eax
  801887:	8b 40 0c             	mov    0xc(%eax),%eax
  80188a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80188f:	ba 00 00 00 00       	mov    $0x0,%edx
  801894:	b8 06 00 00 00       	mov    $0x6,%eax
  801899:	e8 6b ff ff ff       	call   801809 <fsipc>
}
  80189e:	c9                   	leave  
  80189f:	c3                   	ret    

008018a0 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018a0:	55                   	push   %ebp
  8018a1:	89 e5                	mov    %esp,%ebp
  8018a3:	53                   	push   %ebx
  8018a4:	83 ec 04             	sub    $0x4,%esp
  8018a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ba:	b8 05 00 00 00       	mov    $0x5,%eax
  8018bf:	e8 45 ff ff ff       	call   801809 <fsipc>
  8018c4:	85 c0                	test   %eax,%eax
  8018c6:	78 2c                	js     8018f4 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018c8:	83 ec 08             	sub    $0x8,%esp
  8018cb:	68 00 50 80 00       	push   $0x805000
  8018d0:	53                   	push   %ebx
  8018d1:	e8 26 ee ff ff       	call   8006fc <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018d6:	a1 80 50 80 00       	mov    0x805080,%eax
  8018db:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018e1:	a1 84 50 80 00       	mov    0x805084,%eax
  8018e6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018ec:	83 c4 10             	add    $0x10,%esp
  8018ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f7:	c9                   	leave  
  8018f8:	c3                   	ret    

008018f9 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018f9:	55                   	push   %ebp
  8018fa:	89 e5                	mov    %esp,%ebp
  8018fc:	83 ec 0c             	sub    $0xc,%esp
  8018ff:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801902:	8b 55 08             	mov    0x8(%ebp),%edx
  801905:	8b 52 0c             	mov    0xc(%edx),%edx
  801908:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80190e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801913:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801918:	0f 47 c2             	cmova  %edx,%eax
  80191b:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801920:	50                   	push   %eax
  801921:	ff 75 0c             	pushl  0xc(%ebp)
  801924:	68 08 50 80 00       	push   $0x805008
  801929:	e8 60 ef ff ff       	call   80088e <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80192e:	ba 00 00 00 00       	mov    $0x0,%edx
  801933:	b8 04 00 00 00       	mov    $0x4,%eax
  801938:	e8 cc fe ff ff       	call   801809 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80193d:	c9                   	leave  
  80193e:	c3                   	ret    

0080193f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80193f:	55                   	push   %ebp
  801940:	89 e5                	mov    %esp,%ebp
  801942:	56                   	push   %esi
  801943:	53                   	push   %ebx
  801944:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801947:	8b 45 08             	mov    0x8(%ebp),%eax
  80194a:	8b 40 0c             	mov    0xc(%eax),%eax
  80194d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801952:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801958:	ba 00 00 00 00       	mov    $0x0,%edx
  80195d:	b8 03 00 00 00       	mov    $0x3,%eax
  801962:	e8 a2 fe ff ff       	call   801809 <fsipc>
  801967:	89 c3                	mov    %eax,%ebx
  801969:	85 c0                	test   %eax,%eax
  80196b:	78 4b                	js     8019b8 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80196d:	39 c6                	cmp    %eax,%esi
  80196f:	73 16                	jae    801987 <devfile_read+0x48>
  801971:	68 a4 28 80 00       	push   $0x8028a4
  801976:	68 ab 28 80 00       	push   $0x8028ab
  80197b:	6a 7c                	push   $0x7c
  80197d:	68 c0 28 80 00       	push   $0x8028c0
  801982:	e8 c6 05 00 00       	call   801f4d <_panic>
	assert(r <= PGSIZE);
  801987:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80198c:	7e 16                	jle    8019a4 <devfile_read+0x65>
  80198e:	68 cb 28 80 00       	push   $0x8028cb
  801993:	68 ab 28 80 00       	push   $0x8028ab
  801998:	6a 7d                	push   $0x7d
  80199a:	68 c0 28 80 00       	push   $0x8028c0
  80199f:	e8 a9 05 00 00       	call   801f4d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019a4:	83 ec 04             	sub    $0x4,%esp
  8019a7:	50                   	push   %eax
  8019a8:	68 00 50 80 00       	push   $0x805000
  8019ad:	ff 75 0c             	pushl  0xc(%ebp)
  8019b0:	e8 d9 ee ff ff       	call   80088e <memmove>
	return r;
  8019b5:	83 c4 10             	add    $0x10,%esp
}
  8019b8:	89 d8                	mov    %ebx,%eax
  8019ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019bd:	5b                   	pop    %ebx
  8019be:	5e                   	pop    %esi
  8019bf:	5d                   	pop    %ebp
  8019c0:	c3                   	ret    

008019c1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019c1:	55                   	push   %ebp
  8019c2:	89 e5                	mov    %esp,%ebp
  8019c4:	53                   	push   %ebx
  8019c5:	83 ec 20             	sub    $0x20,%esp
  8019c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019cb:	53                   	push   %ebx
  8019cc:	e8 f2 ec ff ff       	call   8006c3 <strlen>
  8019d1:	83 c4 10             	add    $0x10,%esp
  8019d4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019d9:	7f 67                	jg     801a42 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019db:	83 ec 0c             	sub    $0xc,%esp
  8019de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019e1:	50                   	push   %eax
  8019e2:	e8 8e f8 ff ff       	call   801275 <fd_alloc>
  8019e7:	83 c4 10             	add    $0x10,%esp
		return r;
  8019ea:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019ec:	85 c0                	test   %eax,%eax
  8019ee:	78 57                	js     801a47 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019f0:	83 ec 08             	sub    $0x8,%esp
  8019f3:	53                   	push   %ebx
  8019f4:	68 00 50 80 00       	push   $0x805000
  8019f9:	e8 fe ec ff ff       	call   8006fc <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a01:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a06:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a09:	b8 01 00 00 00       	mov    $0x1,%eax
  801a0e:	e8 f6 fd ff ff       	call   801809 <fsipc>
  801a13:	89 c3                	mov    %eax,%ebx
  801a15:	83 c4 10             	add    $0x10,%esp
  801a18:	85 c0                	test   %eax,%eax
  801a1a:	79 14                	jns    801a30 <open+0x6f>
		fd_close(fd, 0);
  801a1c:	83 ec 08             	sub    $0x8,%esp
  801a1f:	6a 00                	push   $0x0
  801a21:	ff 75 f4             	pushl  -0xc(%ebp)
  801a24:	e8 47 f9 ff ff       	call   801370 <fd_close>
		return r;
  801a29:	83 c4 10             	add    $0x10,%esp
  801a2c:	89 da                	mov    %ebx,%edx
  801a2e:	eb 17                	jmp    801a47 <open+0x86>
	}

	return fd2num(fd);
  801a30:	83 ec 0c             	sub    $0xc,%esp
  801a33:	ff 75 f4             	pushl  -0xc(%ebp)
  801a36:	e8 13 f8 ff ff       	call   80124e <fd2num>
  801a3b:	89 c2                	mov    %eax,%edx
  801a3d:	83 c4 10             	add    $0x10,%esp
  801a40:	eb 05                	jmp    801a47 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a42:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a47:	89 d0                	mov    %edx,%eax
  801a49:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a4c:	c9                   	leave  
  801a4d:	c3                   	ret    

00801a4e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a4e:	55                   	push   %ebp
  801a4f:	89 e5                	mov    %esp,%ebp
  801a51:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a54:	ba 00 00 00 00       	mov    $0x0,%edx
  801a59:	b8 08 00 00 00       	mov    $0x8,%eax
  801a5e:	e8 a6 fd ff ff       	call   801809 <fsipc>
}
  801a63:	c9                   	leave  
  801a64:	c3                   	ret    

00801a65 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a65:	55                   	push   %ebp
  801a66:	89 e5                	mov    %esp,%ebp
  801a68:	56                   	push   %esi
  801a69:	53                   	push   %ebx
  801a6a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a6d:	83 ec 0c             	sub    $0xc,%esp
  801a70:	ff 75 08             	pushl  0x8(%ebp)
  801a73:	e8 e6 f7 ff ff       	call   80125e <fd2data>
  801a78:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a7a:	83 c4 08             	add    $0x8,%esp
  801a7d:	68 d7 28 80 00       	push   $0x8028d7
  801a82:	53                   	push   %ebx
  801a83:	e8 74 ec ff ff       	call   8006fc <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a88:	8b 46 04             	mov    0x4(%esi),%eax
  801a8b:	2b 06                	sub    (%esi),%eax
  801a8d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a93:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a9a:	00 00 00 
	stat->st_dev = &devpipe;
  801a9d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801aa4:	30 80 00 
	return 0;
}
  801aa7:	b8 00 00 00 00       	mov    $0x0,%eax
  801aac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aaf:	5b                   	pop    %ebx
  801ab0:	5e                   	pop    %esi
  801ab1:	5d                   	pop    %ebp
  801ab2:	c3                   	ret    

00801ab3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ab3:	55                   	push   %ebp
  801ab4:	89 e5                	mov    %esp,%ebp
  801ab6:	53                   	push   %ebx
  801ab7:	83 ec 0c             	sub    $0xc,%esp
  801aba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801abd:	53                   	push   %ebx
  801abe:	6a 00                	push   $0x0
  801ac0:	e8 bf f0 ff ff       	call   800b84 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ac5:	89 1c 24             	mov    %ebx,(%esp)
  801ac8:	e8 91 f7 ff ff       	call   80125e <fd2data>
  801acd:	83 c4 08             	add    $0x8,%esp
  801ad0:	50                   	push   %eax
  801ad1:	6a 00                	push   $0x0
  801ad3:	e8 ac f0 ff ff       	call   800b84 <sys_page_unmap>
}
  801ad8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801adb:	c9                   	leave  
  801adc:	c3                   	ret    

00801add <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801add:	55                   	push   %ebp
  801ade:	89 e5                	mov    %esp,%ebp
  801ae0:	57                   	push   %edi
  801ae1:	56                   	push   %esi
  801ae2:	53                   	push   %ebx
  801ae3:	83 ec 1c             	sub    $0x1c,%esp
  801ae6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ae9:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801aeb:	a1 04 40 80 00       	mov    0x804004,%eax
  801af0:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801af6:	83 ec 0c             	sub    $0xc,%esp
  801af9:	ff 75 e0             	pushl  -0x20(%ebp)
  801afc:	e8 43 06 00 00       	call   802144 <pageref>
  801b01:	89 c3                	mov    %eax,%ebx
  801b03:	89 3c 24             	mov    %edi,(%esp)
  801b06:	e8 39 06 00 00       	call   802144 <pageref>
  801b0b:	83 c4 10             	add    $0x10,%esp
  801b0e:	39 c3                	cmp    %eax,%ebx
  801b10:	0f 94 c1             	sete   %cl
  801b13:	0f b6 c9             	movzbl %cl,%ecx
  801b16:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b19:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b1f:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  801b25:	39 ce                	cmp    %ecx,%esi
  801b27:	74 1e                	je     801b47 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801b29:	39 c3                	cmp    %eax,%ebx
  801b2b:	75 be                	jne    801aeb <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b2d:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  801b33:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b36:	50                   	push   %eax
  801b37:	56                   	push   %esi
  801b38:	68 de 28 80 00       	push   $0x8028de
  801b3d:	e8 35 e6 ff ff       	call   800177 <cprintf>
  801b42:	83 c4 10             	add    $0x10,%esp
  801b45:	eb a4                	jmp    801aeb <_pipeisclosed+0xe>
	}
}
  801b47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b4d:	5b                   	pop    %ebx
  801b4e:	5e                   	pop    %esi
  801b4f:	5f                   	pop    %edi
  801b50:	5d                   	pop    %ebp
  801b51:	c3                   	ret    

00801b52 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b52:	55                   	push   %ebp
  801b53:	89 e5                	mov    %esp,%ebp
  801b55:	57                   	push   %edi
  801b56:	56                   	push   %esi
  801b57:	53                   	push   %ebx
  801b58:	83 ec 28             	sub    $0x28,%esp
  801b5b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b5e:	56                   	push   %esi
  801b5f:	e8 fa f6 ff ff       	call   80125e <fd2data>
  801b64:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b66:	83 c4 10             	add    $0x10,%esp
  801b69:	bf 00 00 00 00       	mov    $0x0,%edi
  801b6e:	eb 4b                	jmp    801bbb <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b70:	89 da                	mov    %ebx,%edx
  801b72:	89 f0                	mov    %esi,%eax
  801b74:	e8 64 ff ff ff       	call   801add <_pipeisclosed>
  801b79:	85 c0                	test   %eax,%eax
  801b7b:	75 48                	jne    801bc5 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b7d:	e8 5e ef ff ff       	call   800ae0 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b82:	8b 43 04             	mov    0x4(%ebx),%eax
  801b85:	8b 0b                	mov    (%ebx),%ecx
  801b87:	8d 51 20             	lea    0x20(%ecx),%edx
  801b8a:	39 d0                	cmp    %edx,%eax
  801b8c:	73 e2                	jae    801b70 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b91:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b95:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b98:	89 c2                	mov    %eax,%edx
  801b9a:	c1 fa 1f             	sar    $0x1f,%edx
  801b9d:	89 d1                	mov    %edx,%ecx
  801b9f:	c1 e9 1b             	shr    $0x1b,%ecx
  801ba2:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ba5:	83 e2 1f             	and    $0x1f,%edx
  801ba8:	29 ca                	sub    %ecx,%edx
  801baa:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bae:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bb2:	83 c0 01             	add    $0x1,%eax
  801bb5:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bb8:	83 c7 01             	add    $0x1,%edi
  801bbb:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bbe:	75 c2                	jne    801b82 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bc0:	8b 45 10             	mov    0x10(%ebp),%eax
  801bc3:	eb 05                	jmp    801bca <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bc5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bcd:	5b                   	pop    %ebx
  801bce:	5e                   	pop    %esi
  801bcf:	5f                   	pop    %edi
  801bd0:	5d                   	pop    %ebp
  801bd1:	c3                   	ret    

00801bd2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bd2:	55                   	push   %ebp
  801bd3:	89 e5                	mov    %esp,%ebp
  801bd5:	57                   	push   %edi
  801bd6:	56                   	push   %esi
  801bd7:	53                   	push   %ebx
  801bd8:	83 ec 18             	sub    $0x18,%esp
  801bdb:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bde:	57                   	push   %edi
  801bdf:	e8 7a f6 ff ff       	call   80125e <fd2data>
  801be4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be6:	83 c4 10             	add    $0x10,%esp
  801be9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bee:	eb 3d                	jmp    801c2d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bf0:	85 db                	test   %ebx,%ebx
  801bf2:	74 04                	je     801bf8 <devpipe_read+0x26>
				return i;
  801bf4:	89 d8                	mov    %ebx,%eax
  801bf6:	eb 44                	jmp    801c3c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bf8:	89 f2                	mov    %esi,%edx
  801bfa:	89 f8                	mov    %edi,%eax
  801bfc:	e8 dc fe ff ff       	call   801add <_pipeisclosed>
  801c01:	85 c0                	test   %eax,%eax
  801c03:	75 32                	jne    801c37 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c05:	e8 d6 ee ff ff       	call   800ae0 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c0a:	8b 06                	mov    (%esi),%eax
  801c0c:	3b 46 04             	cmp    0x4(%esi),%eax
  801c0f:	74 df                	je     801bf0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c11:	99                   	cltd   
  801c12:	c1 ea 1b             	shr    $0x1b,%edx
  801c15:	01 d0                	add    %edx,%eax
  801c17:	83 e0 1f             	and    $0x1f,%eax
  801c1a:	29 d0                	sub    %edx,%eax
  801c1c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c24:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c27:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c2a:	83 c3 01             	add    $0x1,%ebx
  801c2d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c30:	75 d8                	jne    801c0a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c32:	8b 45 10             	mov    0x10(%ebp),%eax
  801c35:	eb 05                	jmp    801c3c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c37:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c3f:	5b                   	pop    %ebx
  801c40:	5e                   	pop    %esi
  801c41:	5f                   	pop    %edi
  801c42:	5d                   	pop    %ebp
  801c43:	c3                   	ret    

00801c44 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c44:	55                   	push   %ebp
  801c45:	89 e5                	mov    %esp,%ebp
  801c47:	56                   	push   %esi
  801c48:	53                   	push   %ebx
  801c49:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c4f:	50                   	push   %eax
  801c50:	e8 20 f6 ff ff       	call   801275 <fd_alloc>
  801c55:	83 c4 10             	add    $0x10,%esp
  801c58:	89 c2                	mov    %eax,%edx
  801c5a:	85 c0                	test   %eax,%eax
  801c5c:	0f 88 2c 01 00 00    	js     801d8e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c62:	83 ec 04             	sub    $0x4,%esp
  801c65:	68 07 04 00 00       	push   $0x407
  801c6a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c6d:	6a 00                	push   $0x0
  801c6f:	e8 8b ee ff ff       	call   800aff <sys_page_alloc>
  801c74:	83 c4 10             	add    $0x10,%esp
  801c77:	89 c2                	mov    %eax,%edx
  801c79:	85 c0                	test   %eax,%eax
  801c7b:	0f 88 0d 01 00 00    	js     801d8e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c81:	83 ec 0c             	sub    $0xc,%esp
  801c84:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c87:	50                   	push   %eax
  801c88:	e8 e8 f5 ff ff       	call   801275 <fd_alloc>
  801c8d:	89 c3                	mov    %eax,%ebx
  801c8f:	83 c4 10             	add    $0x10,%esp
  801c92:	85 c0                	test   %eax,%eax
  801c94:	0f 88 e2 00 00 00    	js     801d7c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c9a:	83 ec 04             	sub    $0x4,%esp
  801c9d:	68 07 04 00 00       	push   $0x407
  801ca2:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca5:	6a 00                	push   $0x0
  801ca7:	e8 53 ee ff ff       	call   800aff <sys_page_alloc>
  801cac:	89 c3                	mov    %eax,%ebx
  801cae:	83 c4 10             	add    $0x10,%esp
  801cb1:	85 c0                	test   %eax,%eax
  801cb3:	0f 88 c3 00 00 00    	js     801d7c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cb9:	83 ec 0c             	sub    $0xc,%esp
  801cbc:	ff 75 f4             	pushl  -0xc(%ebp)
  801cbf:	e8 9a f5 ff ff       	call   80125e <fd2data>
  801cc4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc6:	83 c4 0c             	add    $0xc,%esp
  801cc9:	68 07 04 00 00       	push   $0x407
  801cce:	50                   	push   %eax
  801ccf:	6a 00                	push   $0x0
  801cd1:	e8 29 ee ff ff       	call   800aff <sys_page_alloc>
  801cd6:	89 c3                	mov    %eax,%ebx
  801cd8:	83 c4 10             	add    $0x10,%esp
  801cdb:	85 c0                	test   %eax,%eax
  801cdd:	0f 88 89 00 00 00    	js     801d6c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ce3:	83 ec 0c             	sub    $0xc,%esp
  801ce6:	ff 75 f0             	pushl  -0x10(%ebp)
  801ce9:	e8 70 f5 ff ff       	call   80125e <fd2data>
  801cee:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cf5:	50                   	push   %eax
  801cf6:	6a 00                	push   $0x0
  801cf8:	56                   	push   %esi
  801cf9:	6a 00                	push   $0x0
  801cfb:	e8 42 ee ff ff       	call   800b42 <sys_page_map>
  801d00:	89 c3                	mov    %eax,%ebx
  801d02:	83 c4 20             	add    $0x20,%esp
  801d05:	85 c0                	test   %eax,%eax
  801d07:	78 55                	js     801d5e <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d09:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d12:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d17:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d1e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d24:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d27:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d29:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d2c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d33:	83 ec 0c             	sub    $0xc,%esp
  801d36:	ff 75 f4             	pushl  -0xc(%ebp)
  801d39:	e8 10 f5 ff ff       	call   80124e <fd2num>
  801d3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d41:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d43:	83 c4 04             	add    $0x4,%esp
  801d46:	ff 75 f0             	pushl  -0x10(%ebp)
  801d49:	e8 00 f5 ff ff       	call   80124e <fd2num>
  801d4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d51:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801d54:	83 c4 10             	add    $0x10,%esp
  801d57:	ba 00 00 00 00       	mov    $0x0,%edx
  801d5c:	eb 30                	jmp    801d8e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d5e:	83 ec 08             	sub    $0x8,%esp
  801d61:	56                   	push   %esi
  801d62:	6a 00                	push   $0x0
  801d64:	e8 1b ee ff ff       	call   800b84 <sys_page_unmap>
  801d69:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d6c:	83 ec 08             	sub    $0x8,%esp
  801d6f:	ff 75 f0             	pushl  -0x10(%ebp)
  801d72:	6a 00                	push   $0x0
  801d74:	e8 0b ee ff ff       	call   800b84 <sys_page_unmap>
  801d79:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d7c:	83 ec 08             	sub    $0x8,%esp
  801d7f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d82:	6a 00                	push   $0x0
  801d84:	e8 fb ed ff ff       	call   800b84 <sys_page_unmap>
  801d89:	83 c4 10             	add    $0x10,%esp
  801d8c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d8e:	89 d0                	mov    %edx,%eax
  801d90:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d93:	5b                   	pop    %ebx
  801d94:	5e                   	pop    %esi
  801d95:	5d                   	pop    %ebp
  801d96:	c3                   	ret    

00801d97 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d97:	55                   	push   %ebp
  801d98:	89 e5                	mov    %esp,%ebp
  801d9a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d9d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801da0:	50                   	push   %eax
  801da1:	ff 75 08             	pushl  0x8(%ebp)
  801da4:	e8 1b f5 ff ff       	call   8012c4 <fd_lookup>
  801da9:	83 c4 10             	add    $0x10,%esp
  801dac:	85 c0                	test   %eax,%eax
  801dae:	78 18                	js     801dc8 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801db0:	83 ec 0c             	sub    $0xc,%esp
  801db3:	ff 75 f4             	pushl  -0xc(%ebp)
  801db6:	e8 a3 f4 ff ff       	call   80125e <fd2data>
	return _pipeisclosed(fd, p);
  801dbb:	89 c2                	mov    %eax,%edx
  801dbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc0:	e8 18 fd ff ff       	call   801add <_pipeisclosed>
  801dc5:	83 c4 10             	add    $0x10,%esp
}
  801dc8:	c9                   	leave  
  801dc9:	c3                   	ret    

00801dca <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801dca:	55                   	push   %ebp
  801dcb:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801dcd:	b8 00 00 00 00       	mov    $0x0,%eax
  801dd2:	5d                   	pop    %ebp
  801dd3:	c3                   	ret    

00801dd4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dd4:	55                   	push   %ebp
  801dd5:	89 e5                	mov    %esp,%ebp
  801dd7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dda:	68 f6 28 80 00       	push   $0x8028f6
  801ddf:	ff 75 0c             	pushl  0xc(%ebp)
  801de2:	e8 15 e9 ff ff       	call   8006fc <strcpy>
	return 0;
}
  801de7:	b8 00 00 00 00       	mov    $0x0,%eax
  801dec:	c9                   	leave  
  801ded:	c3                   	ret    

00801dee <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dee:	55                   	push   %ebp
  801def:	89 e5                	mov    %esp,%ebp
  801df1:	57                   	push   %edi
  801df2:	56                   	push   %esi
  801df3:	53                   	push   %ebx
  801df4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dfa:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dff:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e05:	eb 2d                	jmp    801e34 <devcons_write+0x46>
		m = n - tot;
  801e07:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e0a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e0c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e0f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e14:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e17:	83 ec 04             	sub    $0x4,%esp
  801e1a:	53                   	push   %ebx
  801e1b:	03 45 0c             	add    0xc(%ebp),%eax
  801e1e:	50                   	push   %eax
  801e1f:	57                   	push   %edi
  801e20:	e8 69 ea ff ff       	call   80088e <memmove>
		sys_cputs(buf, m);
  801e25:	83 c4 08             	add    $0x8,%esp
  801e28:	53                   	push   %ebx
  801e29:	57                   	push   %edi
  801e2a:	e8 14 ec ff ff       	call   800a43 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e2f:	01 de                	add    %ebx,%esi
  801e31:	83 c4 10             	add    $0x10,%esp
  801e34:	89 f0                	mov    %esi,%eax
  801e36:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e39:	72 cc                	jb     801e07 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e3e:	5b                   	pop    %ebx
  801e3f:	5e                   	pop    %esi
  801e40:	5f                   	pop    %edi
  801e41:	5d                   	pop    %ebp
  801e42:	c3                   	ret    

00801e43 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e43:	55                   	push   %ebp
  801e44:	89 e5                	mov    %esp,%ebp
  801e46:	83 ec 08             	sub    $0x8,%esp
  801e49:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e4e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e52:	74 2a                	je     801e7e <devcons_read+0x3b>
  801e54:	eb 05                	jmp    801e5b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e56:	e8 85 ec ff ff       	call   800ae0 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e5b:	e8 01 ec ff ff       	call   800a61 <sys_cgetc>
  801e60:	85 c0                	test   %eax,%eax
  801e62:	74 f2                	je     801e56 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e64:	85 c0                	test   %eax,%eax
  801e66:	78 16                	js     801e7e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e68:	83 f8 04             	cmp    $0x4,%eax
  801e6b:	74 0c                	je     801e79 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e6d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e70:	88 02                	mov    %al,(%edx)
	return 1;
  801e72:	b8 01 00 00 00       	mov    $0x1,%eax
  801e77:	eb 05                	jmp    801e7e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e79:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e7e:	c9                   	leave  
  801e7f:	c3                   	ret    

00801e80 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e80:	55                   	push   %ebp
  801e81:	89 e5                	mov    %esp,%ebp
  801e83:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e86:	8b 45 08             	mov    0x8(%ebp),%eax
  801e89:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e8c:	6a 01                	push   $0x1
  801e8e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e91:	50                   	push   %eax
  801e92:	e8 ac eb ff ff       	call   800a43 <sys_cputs>
}
  801e97:	83 c4 10             	add    $0x10,%esp
  801e9a:	c9                   	leave  
  801e9b:	c3                   	ret    

00801e9c <getchar>:

int
getchar(void)
{
  801e9c:	55                   	push   %ebp
  801e9d:	89 e5                	mov    %esp,%ebp
  801e9f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ea2:	6a 01                	push   $0x1
  801ea4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ea7:	50                   	push   %eax
  801ea8:	6a 00                	push   $0x0
  801eaa:	e8 7e f6 ff ff       	call   80152d <read>
	if (r < 0)
  801eaf:	83 c4 10             	add    $0x10,%esp
  801eb2:	85 c0                	test   %eax,%eax
  801eb4:	78 0f                	js     801ec5 <getchar+0x29>
		return r;
	if (r < 1)
  801eb6:	85 c0                	test   %eax,%eax
  801eb8:	7e 06                	jle    801ec0 <getchar+0x24>
		return -E_EOF;
	return c;
  801eba:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ebe:	eb 05                	jmp    801ec5 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ec0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ec5:	c9                   	leave  
  801ec6:	c3                   	ret    

00801ec7 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ec7:	55                   	push   %ebp
  801ec8:	89 e5                	mov    %esp,%ebp
  801eca:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ecd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ed0:	50                   	push   %eax
  801ed1:	ff 75 08             	pushl  0x8(%ebp)
  801ed4:	e8 eb f3 ff ff       	call   8012c4 <fd_lookup>
  801ed9:	83 c4 10             	add    $0x10,%esp
  801edc:	85 c0                	test   %eax,%eax
  801ede:	78 11                	js     801ef1 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ee9:	39 10                	cmp    %edx,(%eax)
  801eeb:	0f 94 c0             	sete   %al
  801eee:	0f b6 c0             	movzbl %al,%eax
}
  801ef1:	c9                   	leave  
  801ef2:	c3                   	ret    

00801ef3 <opencons>:

int
opencons(void)
{
  801ef3:	55                   	push   %ebp
  801ef4:	89 e5                	mov    %esp,%ebp
  801ef6:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ef9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801efc:	50                   	push   %eax
  801efd:	e8 73 f3 ff ff       	call   801275 <fd_alloc>
  801f02:	83 c4 10             	add    $0x10,%esp
		return r;
  801f05:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f07:	85 c0                	test   %eax,%eax
  801f09:	78 3e                	js     801f49 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f0b:	83 ec 04             	sub    $0x4,%esp
  801f0e:	68 07 04 00 00       	push   $0x407
  801f13:	ff 75 f4             	pushl  -0xc(%ebp)
  801f16:	6a 00                	push   $0x0
  801f18:	e8 e2 eb ff ff       	call   800aff <sys_page_alloc>
  801f1d:	83 c4 10             	add    $0x10,%esp
		return r;
  801f20:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f22:	85 c0                	test   %eax,%eax
  801f24:	78 23                	js     801f49 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f26:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f34:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f3b:	83 ec 0c             	sub    $0xc,%esp
  801f3e:	50                   	push   %eax
  801f3f:	e8 0a f3 ff ff       	call   80124e <fd2num>
  801f44:	89 c2                	mov    %eax,%edx
  801f46:	83 c4 10             	add    $0x10,%esp
}
  801f49:	89 d0                	mov    %edx,%eax
  801f4b:	c9                   	leave  
  801f4c:	c3                   	ret    

00801f4d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f4d:	55                   	push   %ebp
  801f4e:	89 e5                	mov    %esp,%ebp
  801f50:	56                   	push   %esi
  801f51:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f52:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f55:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801f5b:	e8 61 eb ff ff       	call   800ac1 <sys_getenvid>
  801f60:	83 ec 0c             	sub    $0xc,%esp
  801f63:	ff 75 0c             	pushl  0xc(%ebp)
  801f66:	ff 75 08             	pushl  0x8(%ebp)
  801f69:	56                   	push   %esi
  801f6a:	50                   	push   %eax
  801f6b:	68 04 29 80 00       	push   $0x802904
  801f70:	e8 02 e2 ff ff       	call   800177 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f75:	83 c4 18             	add    $0x18,%esp
  801f78:	53                   	push   %ebx
  801f79:	ff 75 10             	pushl  0x10(%ebp)
  801f7c:	e8 a5 e1 ff ff       	call   800126 <vcprintf>
	cprintf("\n");
  801f81:	c7 04 24 fb 27 80 00 	movl   $0x8027fb,(%esp)
  801f88:	e8 ea e1 ff ff       	call   800177 <cprintf>
  801f8d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f90:	cc                   	int3   
  801f91:	eb fd                	jmp    801f90 <_panic+0x43>

00801f93 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f93:	55                   	push   %ebp
  801f94:	89 e5                	mov    %esp,%ebp
  801f96:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f99:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fa0:	75 2a                	jne    801fcc <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801fa2:	83 ec 04             	sub    $0x4,%esp
  801fa5:	6a 07                	push   $0x7
  801fa7:	68 00 f0 bf ee       	push   $0xeebff000
  801fac:	6a 00                	push   $0x0
  801fae:	e8 4c eb ff ff       	call   800aff <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801fb3:	83 c4 10             	add    $0x10,%esp
  801fb6:	85 c0                	test   %eax,%eax
  801fb8:	79 12                	jns    801fcc <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801fba:	50                   	push   %eax
  801fbb:	68 12 28 80 00       	push   $0x802812
  801fc0:	6a 23                	push   $0x23
  801fc2:	68 28 29 80 00       	push   $0x802928
  801fc7:	e8 81 ff ff ff       	call   801f4d <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fcc:	8b 45 08             	mov    0x8(%ebp),%eax
  801fcf:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801fd4:	83 ec 08             	sub    $0x8,%esp
  801fd7:	68 fe 1f 80 00       	push   $0x801ffe
  801fdc:	6a 00                	push   $0x0
  801fde:	e8 67 ec ff ff       	call   800c4a <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801fe3:	83 c4 10             	add    $0x10,%esp
  801fe6:	85 c0                	test   %eax,%eax
  801fe8:	79 12                	jns    801ffc <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801fea:	50                   	push   %eax
  801feb:	68 12 28 80 00       	push   $0x802812
  801ff0:	6a 2c                	push   $0x2c
  801ff2:	68 28 29 80 00       	push   $0x802928
  801ff7:	e8 51 ff ff ff       	call   801f4d <_panic>
	}
}
  801ffc:	c9                   	leave  
  801ffd:	c3                   	ret    

00801ffe <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801ffe:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fff:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802004:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802006:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802009:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  80200d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802012:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802016:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802018:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  80201b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  80201c:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80201f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802020:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802021:	c3                   	ret    

00802022 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802022:	55                   	push   %ebp
  802023:	89 e5                	mov    %esp,%ebp
  802025:	56                   	push   %esi
  802026:	53                   	push   %ebx
  802027:	8b 75 08             	mov    0x8(%ebp),%esi
  80202a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80202d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802030:	85 c0                	test   %eax,%eax
  802032:	75 12                	jne    802046 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802034:	83 ec 0c             	sub    $0xc,%esp
  802037:	68 00 00 c0 ee       	push   $0xeec00000
  80203c:	e8 6e ec ff ff       	call   800caf <sys_ipc_recv>
  802041:	83 c4 10             	add    $0x10,%esp
  802044:	eb 0c                	jmp    802052 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802046:	83 ec 0c             	sub    $0xc,%esp
  802049:	50                   	push   %eax
  80204a:	e8 60 ec ff ff       	call   800caf <sys_ipc_recv>
  80204f:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802052:	85 f6                	test   %esi,%esi
  802054:	0f 95 c1             	setne  %cl
  802057:	85 db                	test   %ebx,%ebx
  802059:	0f 95 c2             	setne  %dl
  80205c:	84 d1                	test   %dl,%cl
  80205e:	74 09                	je     802069 <ipc_recv+0x47>
  802060:	89 c2                	mov    %eax,%edx
  802062:	c1 ea 1f             	shr    $0x1f,%edx
  802065:	84 d2                	test   %dl,%dl
  802067:	75 2d                	jne    802096 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802069:	85 f6                	test   %esi,%esi
  80206b:	74 0d                	je     80207a <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80206d:	a1 04 40 80 00       	mov    0x804004,%eax
  802072:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  802078:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80207a:	85 db                	test   %ebx,%ebx
  80207c:	74 0d                	je     80208b <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  80207e:	a1 04 40 80 00       	mov    0x804004,%eax
  802083:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802089:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80208b:	a1 04 40 80 00       	mov    0x804004,%eax
  802090:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  802096:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802099:	5b                   	pop    %ebx
  80209a:	5e                   	pop    %esi
  80209b:	5d                   	pop    %ebp
  80209c:	c3                   	ret    

0080209d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80209d:	55                   	push   %ebp
  80209e:	89 e5                	mov    %esp,%ebp
  8020a0:	57                   	push   %edi
  8020a1:	56                   	push   %esi
  8020a2:	53                   	push   %ebx
  8020a3:	83 ec 0c             	sub    $0xc,%esp
  8020a6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020a9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8020af:	85 db                	test   %ebx,%ebx
  8020b1:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8020b6:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8020b9:	ff 75 14             	pushl  0x14(%ebp)
  8020bc:	53                   	push   %ebx
  8020bd:	56                   	push   %esi
  8020be:	57                   	push   %edi
  8020bf:	e8 c8 eb ff ff       	call   800c8c <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8020c4:	89 c2                	mov    %eax,%edx
  8020c6:	c1 ea 1f             	shr    $0x1f,%edx
  8020c9:	83 c4 10             	add    $0x10,%esp
  8020cc:	84 d2                	test   %dl,%dl
  8020ce:	74 17                	je     8020e7 <ipc_send+0x4a>
  8020d0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020d3:	74 12                	je     8020e7 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8020d5:	50                   	push   %eax
  8020d6:	68 36 29 80 00       	push   $0x802936
  8020db:	6a 47                	push   $0x47
  8020dd:	68 44 29 80 00       	push   $0x802944
  8020e2:	e8 66 fe ff ff       	call   801f4d <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8020e7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020ea:	75 07                	jne    8020f3 <ipc_send+0x56>
			sys_yield();
  8020ec:	e8 ef e9 ff ff       	call   800ae0 <sys_yield>
  8020f1:	eb c6                	jmp    8020b9 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8020f3:	85 c0                	test   %eax,%eax
  8020f5:	75 c2                	jne    8020b9 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8020f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020fa:	5b                   	pop    %ebx
  8020fb:	5e                   	pop    %esi
  8020fc:	5f                   	pop    %edi
  8020fd:	5d                   	pop    %ebp
  8020fe:	c3                   	ret    

008020ff <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020ff:	55                   	push   %ebp
  802100:	89 e5                	mov    %esp,%ebp
  802102:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802105:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80210a:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  802110:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802116:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  80211c:	39 ca                	cmp    %ecx,%edx
  80211e:	75 13                	jne    802133 <ipc_find_env+0x34>
			return envs[i].env_id;
  802120:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  802126:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80212b:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  802131:	eb 0f                	jmp    802142 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802133:	83 c0 01             	add    $0x1,%eax
  802136:	3d 00 04 00 00       	cmp    $0x400,%eax
  80213b:	75 cd                	jne    80210a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80213d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802142:	5d                   	pop    %ebp
  802143:	c3                   	ret    

00802144 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802144:	55                   	push   %ebp
  802145:	89 e5                	mov    %esp,%ebp
  802147:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80214a:	89 d0                	mov    %edx,%eax
  80214c:	c1 e8 16             	shr    $0x16,%eax
  80214f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802156:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80215b:	f6 c1 01             	test   $0x1,%cl
  80215e:	74 1d                	je     80217d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802160:	c1 ea 0c             	shr    $0xc,%edx
  802163:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80216a:	f6 c2 01             	test   $0x1,%dl
  80216d:	74 0e                	je     80217d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80216f:	c1 ea 0c             	shr    $0xc,%edx
  802172:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802179:	ef 
  80217a:	0f b7 c0             	movzwl %ax,%eax
}
  80217d:	5d                   	pop    %ebp
  80217e:	c3                   	ret    
  80217f:	90                   	nop

00802180 <__udivdi3>:
  802180:	55                   	push   %ebp
  802181:	57                   	push   %edi
  802182:	56                   	push   %esi
  802183:	53                   	push   %ebx
  802184:	83 ec 1c             	sub    $0x1c,%esp
  802187:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80218b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80218f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802193:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802197:	85 f6                	test   %esi,%esi
  802199:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80219d:	89 ca                	mov    %ecx,%edx
  80219f:	89 f8                	mov    %edi,%eax
  8021a1:	75 3d                	jne    8021e0 <__udivdi3+0x60>
  8021a3:	39 cf                	cmp    %ecx,%edi
  8021a5:	0f 87 c5 00 00 00    	ja     802270 <__udivdi3+0xf0>
  8021ab:	85 ff                	test   %edi,%edi
  8021ad:	89 fd                	mov    %edi,%ebp
  8021af:	75 0b                	jne    8021bc <__udivdi3+0x3c>
  8021b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021b6:	31 d2                	xor    %edx,%edx
  8021b8:	f7 f7                	div    %edi
  8021ba:	89 c5                	mov    %eax,%ebp
  8021bc:	89 c8                	mov    %ecx,%eax
  8021be:	31 d2                	xor    %edx,%edx
  8021c0:	f7 f5                	div    %ebp
  8021c2:	89 c1                	mov    %eax,%ecx
  8021c4:	89 d8                	mov    %ebx,%eax
  8021c6:	89 cf                	mov    %ecx,%edi
  8021c8:	f7 f5                	div    %ebp
  8021ca:	89 c3                	mov    %eax,%ebx
  8021cc:	89 d8                	mov    %ebx,%eax
  8021ce:	89 fa                	mov    %edi,%edx
  8021d0:	83 c4 1c             	add    $0x1c,%esp
  8021d3:	5b                   	pop    %ebx
  8021d4:	5e                   	pop    %esi
  8021d5:	5f                   	pop    %edi
  8021d6:	5d                   	pop    %ebp
  8021d7:	c3                   	ret    
  8021d8:	90                   	nop
  8021d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	39 ce                	cmp    %ecx,%esi
  8021e2:	77 74                	ja     802258 <__udivdi3+0xd8>
  8021e4:	0f bd fe             	bsr    %esi,%edi
  8021e7:	83 f7 1f             	xor    $0x1f,%edi
  8021ea:	0f 84 98 00 00 00    	je     802288 <__udivdi3+0x108>
  8021f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8021f5:	89 f9                	mov    %edi,%ecx
  8021f7:	89 c5                	mov    %eax,%ebp
  8021f9:	29 fb                	sub    %edi,%ebx
  8021fb:	d3 e6                	shl    %cl,%esi
  8021fd:	89 d9                	mov    %ebx,%ecx
  8021ff:	d3 ed                	shr    %cl,%ebp
  802201:	89 f9                	mov    %edi,%ecx
  802203:	d3 e0                	shl    %cl,%eax
  802205:	09 ee                	or     %ebp,%esi
  802207:	89 d9                	mov    %ebx,%ecx
  802209:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80220d:	89 d5                	mov    %edx,%ebp
  80220f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802213:	d3 ed                	shr    %cl,%ebp
  802215:	89 f9                	mov    %edi,%ecx
  802217:	d3 e2                	shl    %cl,%edx
  802219:	89 d9                	mov    %ebx,%ecx
  80221b:	d3 e8                	shr    %cl,%eax
  80221d:	09 c2                	or     %eax,%edx
  80221f:	89 d0                	mov    %edx,%eax
  802221:	89 ea                	mov    %ebp,%edx
  802223:	f7 f6                	div    %esi
  802225:	89 d5                	mov    %edx,%ebp
  802227:	89 c3                	mov    %eax,%ebx
  802229:	f7 64 24 0c          	mull   0xc(%esp)
  80222d:	39 d5                	cmp    %edx,%ebp
  80222f:	72 10                	jb     802241 <__udivdi3+0xc1>
  802231:	8b 74 24 08          	mov    0x8(%esp),%esi
  802235:	89 f9                	mov    %edi,%ecx
  802237:	d3 e6                	shl    %cl,%esi
  802239:	39 c6                	cmp    %eax,%esi
  80223b:	73 07                	jae    802244 <__udivdi3+0xc4>
  80223d:	39 d5                	cmp    %edx,%ebp
  80223f:	75 03                	jne    802244 <__udivdi3+0xc4>
  802241:	83 eb 01             	sub    $0x1,%ebx
  802244:	31 ff                	xor    %edi,%edi
  802246:	89 d8                	mov    %ebx,%eax
  802248:	89 fa                	mov    %edi,%edx
  80224a:	83 c4 1c             	add    $0x1c,%esp
  80224d:	5b                   	pop    %ebx
  80224e:	5e                   	pop    %esi
  80224f:	5f                   	pop    %edi
  802250:	5d                   	pop    %ebp
  802251:	c3                   	ret    
  802252:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802258:	31 ff                	xor    %edi,%edi
  80225a:	31 db                	xor    %ebx,%ebx
  80225c:	89 d8                	mov    %ebx,%eax
  80225e:	89 fa                	mov    %edi,%edx
  802260:	83 c4 1c             	add    $0x1c,%esp
  802263:	5b                   	pop    %ebx
  802264:	5e                   	pop    %esi
  802265:	5f                   	pop    %edi
  802266:	5d                   	pop    %ebp
  802267:	c3                   	ret    
  802268:	90                   	nop
  802269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802270:	89 d8                	mov    %ebx,%eax
  802272:	f7 f7                	div    %edi
  802274:	31 ff                	xor    %edi,%edi
  802276:	89 c3                	mov    %eax,%ebx
  802278:	89 d8                	mov    %ebx,%eax
  80227a:	89 fa                	mov    %edi,%edx
  80227c:	83 c4 1c             	add    $0x1c,%esp
  80227f:	5b                   	pop    %ebx
  802280:	5e                   	pop    %esi
  802281:	5f                   	pop    %edi
  802282:	5d                   	pop    %ebp
  802283:	c3                   	ret    
  802284:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802288:	39 ce                	cmp    %ecx,%esi
  80228a:	72 0c                	jb     802298 <__udivdi3+0x118>
  80228c:	31 db                	xor    %ebx,%ebx
  80228e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802292:	0f 87 34 ff ff ff    	ja     8021cc <__udivdi3+0x4c>
  802298:	bb 01 00 00 00       	mov    $0x1,%ebx
  80229d:	e9 2a ff ff ff       	jmp    8021cc <__udivdi3+0x4c>
  8022a2:	66 90                	xchg   %ax,%ax
  8022a4:	66 90                	xchg   %ax,%ax
  8022a6:	66 90                	xchg   %ax,%ax
  8022a8:	66 90                	xchg   %ax,%ax
  8022aa:	66 90                	xchg   %ax,%ax
  8022ac:	66 90                	xchg   %ax,%ax
  8022ae:	66 90                	xchg   %ax,%ax

008022b0 <__umoddi3>:
  8022b0:	55                   	push   %ebp
  8022b1:	57                   	push   %edi
  8022b2:	56                   	push   %esi
  8022b3:	53                   	push   %ebx
  8022b4:	83 ec 1c             	sub    $0x1c,%esp
  8022b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022c7:	85 d2                	test   %edx,%edx
  8022c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022d1:	89 f3                	mov    %esi,%ebx
  8022d3:	89 3c 24             	mov    %edi,(%esp)
  8022d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022da:	75 1c                	jne    8022f8 <__umoddi3+0x48>
  8022dc:	39 f7                	cmp    %esi,%edi
  8022de:	76 50                	jbe    802330 <__umoddi3+0x80>
  8022e0:	89 c8                	mov    %ecx,%eax
  8022e2:	89 f2                	mov    %esi,%edx
  8022e4:	f7 f7                	div    %edi
  8022e6:	89 d0                	mov    %edx,%eax
  8022e8:	31 d2                	xor    %edx,%edx
  8022ea:	83 c4 1c             	add    $0x1c,%esp
  8022ed:	5b                   	pop    %ebx
  8022ee:	5e                   	pop    %esi
  8022ef:	5f                   	pop    %edi
  8022f0:	5d                   	pop    %ebp
  8022f1:	c3                   	ret    
  8022f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022f8:	39 f2                	cmp    %esi,%edx
  8022fa:	89 d0                	mov    %edx,%eax
  8022fc:	77 52                	ja     802350 <__umoddi3+0xa0>
  8022fe:	0f bd ea             	bsr    %edx,%ebp
  802301:	83 f5 1f             	xor    $0x1f,%ebp
  802304:	75 5a                	jne    802360 <__umoddi3+0xb0>
  802306:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80230a:	0f 82 e0 00 00 00    	jb     8023f0 <__umoddi3+0x140>
  802310:	39 0c 24             	cmp    %ecx,(%esp)
  802313:	0f 86 d7 00 00 00    	jbe    8023f0 <__umoddi3+0x140>
  802319:	8b 44 24 08          	mov    0x8(%esp),%eax
  80231d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802321:	83 c4 1c             	add    $0x1c,%esp
  802324:	5b                   	pop    %ebx
  802325:	5e                   	pop    %esi
  802326:	5f                   	pop    %edi
  802327:	5d                   	pop    %ebp
  802328:	c3                   	ret    
  802329:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802330:	85 ff                	test   %edi,%edi
  802332:	89 fd                	mov    %edi,%ebp
  802334:	75 0b                	jne    802341 <__umoddi3+0x91>
  802336:	b8 01 00 00 00       	mov    $0x1,%eax
  80233b:	31 d2                	xor    %edx,%edx
  80233d:	f7 f7                	div    %edi
  80233f:	89 c5                	mov    %eax,%ebp
  802341:	89 f0                	mov    %esi,%eax
  802343:	31 d2                	xor    %edx,%edx
  802345:	f7 f5                	div    %ebp
  802347:	89 c8                	mov    %ecx,%eax
  802349:	f7 f5                	div    %ebp
  80234b:	89 d0                	mov    %edx,%eax
  80234d:	eb 99                	jmp    8022e8 <__umoddi3+0x38>
  80234f:	90                   	nop
  802350:	89 c8                	mov    %ecx,%eax
  802352:	89 f2                	mov    %esi,%edx
  802354:	83 c4 1c             	add    $0x1c,%esp
  802357:	5b                   	pop    %ebx
  802358:	5e                   	pop    %esi
  802359:	5f                   	pop    %edi
  80235a:	5d                   	pop    %ebp
  80235b:	c3                   	ret    
  80235c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802360:	8b 34 24             	mov    (%esp),%esi
  802363:	bf 20 00 00 00       	mov    $0x20,%edi
  802368:	89 e9                	mov    %ebp,%ecx
  80236a:	29 ef                	sub    %ebp,%edi
  80236c:	d3 e0                	shl    %cl,%eax
  80236e:	89 f9                	mov    %edi,%ecx
  802370:	89 f2                	mov    %esi,%edx
  802372:	d3 ea                	shr    %cl,%edx
  802374:	89 e9                	mov    %ebp,%ecx
  802376:	09 c2                	or     %eax,%edx
  802378:	89 d8                	mov    %ebx,%eax
  80237a:	89 14 24             	mov    %edx,(%esp)
  80237d:	89 f2                	mov    %esi,%edx
  80237f:	d3 e2                	shl    %cl,%edx
  802381:	89 f9                	mov    %edi,%ecx
  802383:	89 54 24 04          	mov    %edx,0x4(%esp)
  802387:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80238b:	d3 e8                	shr    %cl,%eax
  80238d:	89 e9                	mov    %ebp,%ecx
  80238f:	89 c6                	mov    %eax,%esi
  802391:	d3 e3                	shl    %cl,%ebx
  802393:	89 f9                	mov    %edi,%ecx
  802395:	89 d0                	mov    %edx,%eax
  802397:	d3 e8                	shr    %cl,%eax
  802399:	89 e9                	mov    %ebp,%ecx
  80239b:	09 d8                	or     %ebx,%eax
  80239d:	89 d3                	mov    %edx,%ebx
  80239f:	89 f2                	mov    %esi,%edx
  8023a1:	f7 34 24             	divl   (%esp)
  8023a4:	89 d6                	mov    %edx,%esi
  8023a6:	d3 e3                	shl    %cl,%ebx
  8023a8:	f7 64 24 04          	mull   0x4(%esp)
  8023ac:	39 d6                	cmp    %edx,%esi
  8023ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023b2:	89 d1                	mov    %edx,%ecx
  8023b4:	89 c3                	mov    %eax,%ebx
  8023b6:	72 08                	jb     8023c0 <__umoddi3+0x110>
  8023b8:	75 11                	jne    8023cb <__umoddi3+0x11b>
  8023ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8023be:	73 0b                	jae    8023cb <__umoddi3+0x11b>
  8023c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023c4:	1b 14 24             	sbb    (%esp),%edx
  8023c7:	89 d1                	mov    %edx,%ecx
  8023c9:	89 c3                	mov    %eax,%ebx
  8023cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8023cf:	29 da                	sub    %ebx,%edx
  8023d1:	19 ce                	sbb    %ecx,%esi
  8023d3:	89 f9                	mov    %edi,%ecx
  8023d5:	89 f0                	mov    %esi,%eax
  8023d7:	d3 e0                	shl    %cl,%eax
  8023d9:	89 e9                	mov    %ebp,%ecx
  8023db:	d3 ea                	shr    %cl,%edx
  8023dd:	89 e9                	mov    %ebp,%ecx
  8023df:	d3 ee                	shr    %cl,%esi
  8023e1:	09 d0                	or     %edx,%eax
  8023e3:	89 f2                	mov    %esi,%edx
  8023e5:	83 c4 1c             	add    $0x1c,%esp
  8023e8:	5b                   	pop    %ebx
  8023e9:	5e                   	pop    %esi
  8023ea:	5f                   	pop    %edi
  8023eb:	5d                   	pop    %ebp
  8023ec:	c3                   	ret    
  8023ed:	8d 76 00             	lea    0x0(%esi),%esi
  8023f0:	29 f9                	sub    %edi,%ecx
  8023f2:	19 d6                	sbb    %edx,%esi
  8023f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023fc:	e9 18 ff ff ff       	jmp    802319 <__umoddi3+0x69>
