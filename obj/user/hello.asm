
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
  800039:	68 40 22 80 00       	push   $0x802240
  80003e:	e8 34 01 00 00       	call   800177 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 40 80 00       	mov    0x804004,%eax
  800048:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80004e:	83 c4 08             	add    $0x8,%esp
  800051:	50                   	push   %eax
  800052:	68 4e 22 80 00       	push   $0x80224e
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
  800076:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  80007c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800081:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

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

void 
thread_main(/*uintptr_t eip*/)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

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
  8000d0:	e8 63 11 00 00       	call   801238 <close_all>
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
  8001da:	e8 c1 1d 00 00       	call   801fa0 <__udivdi3>
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
  80021d:	e8 ae 1e 00 00       	call   8020d0 <__umoddi3>
  800222:	83 c4 14             	add    $0x14,%esp
  800225:	0f be 80 6f 22 80 00 	movsbl 0x80226f(%eax),%eax
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
  800321:	ff 24 85 c0 23 80 00 	jmp    *0x8023c0(,%eax,4)
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
  8003e5:	8b 14 85 20 25 80 00 	mov    0x802520(,%eax,4),%edx
  8003ec:	85 d2                	test   %edx,%edx
  8003ee:	75 18                	jne    800408 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003f0:	50                   	push   %eax
  8003f1:	68 87 22 80 00       	push   $0x802287
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
  800409:	68 cd 26 80 00       	push   $0x8026cd
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
  80042d:	b8 80 22 80 00       	mov    $0x802280,%eax
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
  800aa8:	68 7f 25 80 00       	push   $0x80257f
  800aad:	6a 23                	push   $0x23
  800aaf:	68 9c 25 80 00       	push   $0x80259c
  800ab4:	e8 b0 12 00 00       	call   801d69 <_panic>

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
  800b29:	68 7f 25 80 00       	push   $0x80257f
  800b2e:	6a 23                	push   $0x23
  800b30:	68 9c 25 80 00       	push   $0x80259c
  800b35:	e8 2f 12 00 00       	call   801d69 <_panic>

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
  800b6b:	68 7f 25 80 00       	push   $0x80257f
  800b70:	6a 23                	push   $0x23
  800b72:	68 9c 25 80 00       	push   $0x80259c
  800b77:	e8 ed 11 00 00       	call   801d69 <_panic>

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
  800bad:	68 7f 25 80 00       	push   $0x80257f
  800bb2:	6a 23                	push   $0x23
  800bb4:	68 9c 25 80 00       	push   $0x80259c
  800bb9:	e8 ab 11 00 00       	call   801d69 <_panic>

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
  800bef:	68 7f 25 80 00       	push   $0x80257f
  800bf4:	6a 23                	push   $0x23
  800bf6:	68 9c 25 80 00       	push   $0x80259c
  800bfb:	e8 69 11 00 00       	call   801d69 <_panic>

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
  800c31:	68 7f 25 80 00       	push   $0x80257f
  800c36:	6a 23                	push   $0x23
  800c38:	68 9c 25 80 00       	push   $0x80259c
  800c3d:	e8 27 11 00 00       	call   801d69 <_panic>
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
  800c73:	68 7f 25 80 00       	push   $0x80257f
  800c78:	6a 23                	push   $0x23
  800c7a:	68 9c 25 80 00       	push   $0x80259c
  800c7f:	e8 e5 10 00 00       	call   801d69 <_panic>

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
  800cd7:	68 7f 25 80 00       	push   $0x80257f
  800cdc:	6a 23                	push   $0x23
  800cde:	68 9c 25 80 00       	push   $0x80259c
  800ce3:	e8 81 10 00 00       	call   801d69 <_panic>

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
  800d76:	68 aa 25 80 00       	push   $0x8025aa
  800d7b:	6a 1e                	push   $0x1e
  800d7d:	68 ba 25 80 00       	push   $0x8025ba
  800d82:	e8 e2 0f 00 00       	call   801d69 <_panic>
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
  800da0:	68 c5 25 80 00       	push   $0x8025c5
  800da5:	6a 2c                	push   $0x2c
  800da7:	68 ba 25 80 00       	push   $0x8025ba
  800dac:	e8 b8 0f 00 00       	call   801d69 <_panic>
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
  800de8:	68 c5 25 80 00       	push   $0x8025c5
  800ded:	6a 33                	push   $0x33
  800def:	68 ba 25 80 00       	push   $0x8025ba
  800df4:	e8 70 0f 00 00       	call   801d69 <_panic>
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
  800e10:	68 c5 25 80 00       	push   $0x8025c5
  800e15:	6a 37                	push   $0x37
  800e17:	68 ba 25 80 00       	push   $0x8025ba
  800e1c:	e8 48 0f 00 00       	call   801d69 <_panic>
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
  800e34:	e8 76 0f 00 00       	call   801daf <set_pgfault_handler>
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
  800e4d:	68 de 25 80 00       	push   $0x8025de
  800e52:	68 84 00 00 00       	push   $0x84
  800e57:	68 ba 25 80 00       	push   $0x8025ba
  800e5c:	e8 08 0f 00 00       	call   801d69 <_panic>
  800e61:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800e63:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e67:	75 24                	jne    800e8d <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e69:	e8 53 fc ff ff       	call   800ac1 <sys_getenvid>
  800e6e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e73:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  800f09:	68 ec 25 80 00       	push   $0x8025ec
  800f0e:	6a 54                	push   $0x54
  800f10:	68 ba 25 80 00       	push   $0x8025ba
  800f15:	e8 4f 0e 00 00       	call   801d69 <_panic>
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
  800f4e:	68 ec 25 80 00       	push   $0x8025ec
  800f53:	6a 5b                	push   $0x5b
  800f55:	68 ba 25 80 00       	push   $0x8025ba
  800f5a:	e8 0a 0e 00 00       	call   801d69 <_panic>
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
  800f7c:	68 ec 25 80 00       	push   $0x8025ec
  800f81:	6a 5f                	push   $0x5f
  800f83:	68 ba 25 80 00       	push   $0x8025ba
  800f88:	e8 dc 0d 00 00       	call   801d69 <_panic>
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
  800fa6:	68 ec 25 80 00       	push   $0x8025ec
  800fab:	6a 64                	push   $0x64
  800fad:	68 ba 25 80 00       	push   $0x8025ba
  800fb2:	e8 b2 0d 00 00       	call   801d69 <_panic>
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
  800fce:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
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
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801003:	55                   	push   %ebp
  801004:	89 e5                	mov    %esp,%ebp
  801006:	56                   	push   %esi
  801007:	53                   	push   %ebx
  801008:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  80100b:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  801011:	83 ec 08             	sub    $0x8,%esp
  801014:	53                   	push   %ebx
  801015:	68 04 26 80 00       	push   $0x802604
  80101a:	e8 58 f1 ff ff       	call   800177 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80101f:	c7 04 24 aa 00 80 00 	movl   $0x8000aa,(%esp)
  801026:	e8 c5 fc ff ff       	call   800cf0 <sys_thread_create>
  80102b:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80102d:	83 c4 08             	add    $0x8,%esp
  801030:	53                   	push   %ebx
  801031:	68 04 26 80 00       	push   $0x802604
  801036:	e8 3c f1 ff ff       	call   800177 <cprintf>
	return id;
}
  80103b:	89 f0                	mov    %esi,%eax
  80103d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801040:	5b                   	pop    %ebx
  801041:	5e                   	pop    %esi
  801042:	5d                   	pop    %ebp
  801043:	c3                   	ret    

00801044 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  801044:	55                   	push   %ebp
  801045:	89 e5                	mov    %esp,%ebp
  801047:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  80104a:	ff 75 08             	pushl  0x8(%ebp)
  80104d:	e8 be fc ff ff       	call   800d10 <sys_thread_free>
}
  801052:	83 c4 10             	add    $0x10,%esp
  801055:	c9                   	leave  
  801056:	c3                   	ret    

00801057 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  80105d:	ff 75 08             	pushl  0x8(%ebp)
  801060:	e8 cb fc ff ff       	call   800d30 <sys_thread_join>
}
  801065:	83 c4 10             	add    $0x10,%esp
  801068:	c9                   	leave  
  801069:	c3                   	ret    

0080106a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80106a:	55                   	push   %ebp
  80106b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80106d:	8b 45 08             	mov    0x8(%ebp),%eax
  801070:	05 00 00 00 30       	add    $0x30000000,%eax
  801075:	c1 e8 0c             	shr    $0xc,%eax
}
  801078:	5d                   	pop    %ebp
  801079:	c3                   	ret    

0080107a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80107a:	55                   	push   %ebp
  80107b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80107d:	8b 45 08             	mov    0x8(%ebp),%eax
  801080:	05 00 00 00 30       	add    $0x30000000,%eax
  801085:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80108a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80108f:	5d                   	pop    %ebp
  801090:	c3                   	ret    

00801091 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801091:	55                   	push   %ebp
  801092:	89 e5                	mov    %esp,%ebp
  801094:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801097:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80109c:	89 c2                	mov    %eax,%edx
  80109e:	c1 ea 16             	shr    $0x16,%edx
  8010a1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010a8:	f6 c2 01             	test   $0x1,%dl
  8010ab:	74 11                	je     8010be <fd_alloc+0x2d>
  8010ad:	89 c2                	mov    %eax,%edx
  8010af:	c1 ea 0c             	shr    $0xc,%edx
  8010b2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010b9:	f6 c2 01             	test   $0x1,%dl
  8010bc:	75 09                	jne    8010c7 <fd_alloc+0x36>
			*fd_store = fd;
  8010be:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c5:	eb 17                	jmp    8010de <fd_alloc+0x4d>
  8010c7:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010cc:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010d1:	75 c9                	jne    80109c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010d3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010d9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010de:	5d                   	pop    %ebp
  8010df:	c3                   	ret    

008010e0 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010e6:	83 f8 1f             	cmp    $0x1f,%eax
  8010e9:	77 36                	ja     801121 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010eb:	c1 e0 0c             	shl    $0xc,%eax
  8010ee:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010f3:	89 c2                	mov    %eax,%edx
  8010f5:	c1 ea 16             	shr    $0x16,%edx
  8010f8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010ff:	f6 c2 01             	test   $0x1,%dl
  801102:	74 24                	je     801128 <fd_lookup+0x48>
  801104:	89 c2                	mov    %eax,%edx
  801106:	c1 ea 0c             	shr    $0xc,%edx
  801109:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801110:	f6 c2 01             	test   $0x1,%dl
  801113:	74 1a                	je     80112f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801115:	8b 55 0c             	mov    0xc(%ebp),%edx
  801118:	89 02                	mov    %eax,(%edx)
	return 0;
  80111a:	b8 00 00 00 00       	mov    $0x0,%eax
  80111f:	eb 13                	jmp    801134 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801121:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801126:	eb 0c                	jmp    801134 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801128:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80112d:	eb 05                	jmp    801134 <fd_lookup+0x54>
  80112f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    

00801136 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	83 ec 08             	sub    $0x8,%esp
  80113c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80113f:	ba a4 26 80 00       	mov    $0x8026a4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801144:	eb 13                	jmp    801159 <dev_lookup+0x23>
  801146:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801149:	39 08                	cmp    %ecx,(%eax)
  80114b:	75 0c                	jne    801159 <dev_lookup+0x23>
			*dev = devtab[i];
  80114d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801150:	89 01                	mov    %eax,(%ecx)
			return 0;
  801152:	b8 00 00 00 00       	mov    $0x0,%eax
  801157:	eb 31                	jmp    80118a <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801159:	8b 02                	mov    (%edx),%eax
  80115b:	85 c0                	test   %eax,%eax
  80115d:	75 e7                	jne    801146 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80115f:	a1 04 40 80 00       	mov    0x804004,%eax
  801164:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80116a:	83 ec 04             	sub    $0x4,%esp
  80116d:	51                   	push   %ecx
  80116e:	50                   	push   %eax
  80116f:	68 28 26 80 00       	push   $0x802628
  801174:	e8 fe ef ff ff       	call   800177 <cprintf>
	*dev = 0;
  801179:	8b 45 0c             	mov    0xc(%ebp),%eax
  80117c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801182:	83 c4 10             	add    $0x10,%esp
  801185:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80118a:	c9                   	leave  
  80118b:	c3                   	ret    

0080118c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80118c:	55                   	push   %ebp
  80118d:	89 e5                	mov    %esp,%ebp
  80118f:	56                   	push   %esi
  801190:	53                   	push   %ebx
  801191:	83 ec 10             	sub    $0x10,%esp
  801194:	8b 75 08             	mov    0x8(%ebp),%esi
  801197:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80119a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80119d:	50                   	push   %eax
  80119e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011a4:	c1 e8 0c             	shr    $0xc,%eax
  8011a7:	50                   	push   %eax
  8011a8:	e8 33 ff ff ff       	call   8010e0 <fd_lookup>
  8011ad:	83 c4 08             	add    $0x8,%esp
  8011b0:	85 c0                	test   %eax,%eax
  8011b2:	78 05                	js     8011b9 <fd_close+0x2d>
	    || fd != fd2)
  8011b4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011b7:	74 0c                	je     8011c5 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011b9:	84 db                	test   %bl,%bl
  8011bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8011c0:	0f 44 c2             	cmove  %edx,%eax
  8011c3:	eb 41                	jmp    801206 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011c5:	83 ec 08             	sub    $0x8,%esp
  8011c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011cb:	50                   	push   %eax
  8011cc:	ff 36                	pushl  (%esi)
  8011ce:	e8 63 ff ff ff       	call   801136 <dev_lookup>
  8011d3:	89 c3                	mov    %eax,%ebx
  8011d5:	83 c4 10             	add    $0x10,%esp
  8011d8:	85 c0                	test   %eax,%eax
  8011da:	78 1a                	js     8011f6 <fd_close+0x6a>
		if (dev->dev_close)
  8011dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011df:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011e2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011e7:	85 c0                	test   %eax,%eax
  8011e9:	74 0b                	je     8011f6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011eb:	83 ec 0c             	sub    $0xc,%esp
  8011ee:	56                   	push   %esi
  8011ef:	ff d0                	call   *%eax
  8011f1:	89 c3                	mov    %eax,%ebx
  8011f3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011f6:	83 ec 08             	sub    $0x8,%esp
  8011f9:	56                   	push   %esi
  8011fa:	6a 00                	push   $0x0
  8011fc:	e8 83 f9 ff ff       	call   800b84 <sys_page_unmap>
	return r;
  801201:	83 c4 10             	add    $0x10,%esp
  801204:	89 d8                	mov    %ebx,%eax
}
  801206:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801209:	5b                   	pop    %ebx
  80120a:	5e                   	pop    %esi
  80120b:	5d                   	pop    %ebp
  80120c:	c3                   	ret    

0080120d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
  801210:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801213:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801216:	50                   	push   %eax
  801217:	ff 75 08             	pushl  0x8(%ebp)
  80121a:	e8 c1 fe ff ff       	call   8010e0 <fd_lookup>
  80121f:	83 c4 08             	add    $0x8,%esp
  801222:	85 c0                	test   %eax,%eax
  801224:	78 10                	js     801236 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801226:	83 ec 08             	sub    $0x8,%esp
  801229:	6a 01                	push   $0x1
  80122b:	ff 75 f4             	pushl  -0xc(%ebp)
  80122e:	e8 59 ff ff ff       	call   80118c <fd_close>
  801233:	83 c4 10             	add    $0x10,%esp
}
  801236:	c9                   	leave  
  801237:	c3                   	ret    

00801238 <close_all>:

void
close_all(void)
{
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	53                   	push   %ebx
  80123c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80123f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801244:	83 ec 0c             	sub    $0xc,%esp
  801247:	53                   	push   %ebx
  801248:	e8 c0 ff ff ff       	call   80120d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80124d:	83 c3 01             	add    $0x1,%ebx
  801250:	83 c4 10             	add    $0x10,%esp
  801253:	83 fb 20             	cmp    $0x20,%ebx
  801256:	75 ec                	jne    801244 <close_all+0xc>
		close(i);
}
  801258:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80125b:	c9                   	leave  
  80125c:	c3                   	ret    

0080125d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80125d:	55                   	push   %ebp
  80125e:	89 e5                	mov    %esp,%ebp
  801260:	57                   	push   %edi
  801261:	56                   	push   %esi
  801262:	53                   	push   %ebx
  801263:	83 ec 2c             	sub    $0x2c,%esp
  801266:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801269:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80126c:	50                   	push   %eax
  80126d:	ff 75 08             	pushl  0x8(%ebp)
  801270:	e8 6b fe ff ff       	call   8010e0 <fd_lookup>
  801275:	83 c4 08             	add    $0x8,%esp
  801278:	85 c0                	test   %eax,%eax
  80127a:	0f 88 c1 00 00 00    	js     801341 <dup+0xe4>
		return r;
	close(newfdnum);
  801280:	83 ec 0c             	sub    $0xc,%esp
  801283:	56                   	push   %esi
  801284:	e8 84 ff ff ff       	call   80120d <close>

	newfd = INDEX2FD(newfdnum);
  801289:	89 f3                	mov    %esi,%ebx
  80128b:	c1 e3 0c             	shl    $0xc,%ebx
  80128e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801294:	83 c4 04             	add    $0x4,%esp
  801297:	ff 75 e4             	pushl  -0x1c(%ebp)
  80129a:	e8 db fd ff ff       	call   80107a <fd2data>
  80129f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012a1:	89 1c 24             	mov    %ebx,(%esp)
  8012a4:	e8 d1 fd ff ff       	call   80107a <fd2data>
  8012a9:	83 c4 10             	add    $0x10,%esp
  8012ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012af:	89 f8                	mov    %edi,%eax
  8012b1:	c1 e8 16             	shr    $0x16,%eax
  8012b4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012bb:	a8 01                	test   $0x1,%al
  8012bd:	74 37                	je     8012f6 <dup+0x99>
  8012bf:	89 f8                	mov    %edi,%eax
  8012c1:	c1 e8 0c             	shr    $0xc,%eax
  8012c4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012cb:	f6 c2 01             	test   $0x1,%dl
  8012ce:	74 26                	je     8012f6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012d0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012d7:	83 ec 0c             	sub    $0xc,%esp
  8012da:	25 07 0e 00 00       	and    $0xe07,%eax
  8012df:	50                   	push   %eax
  8012e0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012e3:	6a 00                	push   $0x0
  8012e5:	57                   	push   %edi
  8012e6:	6a 00                	push   $0x0
  8012e8:	e8 55 f8 ff ff       	call   800b42 <sys_page_map>
  8012ed:	89 c7                	mov    %eax,%edi
  8012ef:	83 c4 20             	add    $0x20,%esp
  8012f2:	85 c0                	test   %eax,%eax
  8012f4:	78 2e                	js     801324 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012f6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012f9:	89 d0                	mov    %edx,%eax
  8012fb:	c1 e8 0c             	shr    $0xc,%eax
  8012fe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801305:	83 ec 0c             	sub    $0xc,%esp
  801308:	25 07 0e 00 00       	and    $0xe07,%eax
  80130d:	50                   	push   %eax
  80130e:	53                   	push   %ebx
  80130f:	6a 00                	push   $0x0
  801311:	52                   	push   %edx
  801312:	6a 00                	push   $0x0
  801314:	e8 29 f8 ff ff       	call   800b42 <sys_page_map>
  801319:	89 c7                	mov    %eax,%edi
  80131b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80131e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801320:	85 ff                	test   %edi,%edi
  801322:	79 1d                	jns    801341 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801324:	83 ec 08             	sub    $0x8,%esp
  801327:	53                   	push   %ebx
  801328:	6a 00                	push   $0x0
  80132a:	e8 55 f8 ff ff       	call   800b84 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80132f:	83 c4 08             	add    $0x8,%esp
  801332:	ff 75 d4             	pushl  -0x2c(%ebp)
  801335:	6a 00                	push   $0x0
  801337:	e8 48 f8 ff ff       	call   800b84 <sys_page_unmap>
	return r;
  80133c:	83 c4 10             	add    $0x10,%esp
  80133f:	89 f8                	mov    %edi,%eax
}
  801341:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801344:	5b                   	pop    %ebx
  801345:	5e                   	pop    %esi
  801346:	5f                   	pop    %edi
  801347:	5d                   	pop    %ebp
  801348:	c3                   	ret    

00801349 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801349:	55                   	push   %ebp
  80134a:	89 e5                	mov    %esp,%ebp
  80134c:	53                   	push   %ebx
  80134d:	83 ec 14             	sub    $0x14,%esp
  801350:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801353:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801356:	50                   	push   %eax
  801357:	53                   	push   %ebx
  801358:	e8 83 fd ff ff       	call   8010e0 <fd_lookup>
  80135d:	83 c4 08             	add    $0x8,%esp
  801360:	89 c2                	mov    %eax,%edx
  801362:	85 c0                	test   %eax,%eax
  801364:	78 70                	js     8013d6 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801366:	83 ec 08             	sub    $0x8,%esp
  801369:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136c:	50                   	push   %eax
  80136d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801370:	ff 30                	pushl  (%eax)
  801372:	e8 bf fd ff ff       	call   801136 <dev_lookup>
  801377:	83 c4 10             	add    $0x10,%esp
  80137a:	85 c0                	test   %eax,%eax
  80137c:	78 4f                	js     8013cd <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80137e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801381:	8b 42 08             	mov    0x8(%edx),%eax
  801384:	83 e0 03             	and    $0x3,%eax
  801387:	83 f8 01             	cmp    $0x1,%eax
  80138a:	75 24                	jne    8013b0 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80138c:	a1 04 40 80 00       	mov    0x804004,%eax
  801391:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801397:	83 ec 04             	sub    $0x4,%esp
  80139a:	53                   	push   %ebx
  80139b:	50                   	push   %eax
  80139c:	68 69 26 80 00       	push   $0x802669
  8013a1:	e8 d1 ed ff ff       	call   800177 <cprintf>
		return -E_INVAL;
  8013a6:	83 c4 10             	add    $0x10,%esp
  8013a9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013ae:	eb 26                	jmp    8013d6 <read+0x8d>
	}
	if (!dev->dev_read)
  8013b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b3:	8b 40 08             	mov    0x8(%eax),%eax
  8013b6:	85 c0                	test   %eax,%eax
  8013b8:	74 17                	je     8013d1 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8013ba:	83 ec 04             	sub    $0x4,%esp
  8013bd:	ff 75 10             	pushl  0x10(%ebp)
  8013c0:	ff 75 0c             	pushl  0xc(%ebp)
  8013c3:	52                   	push   %edx
  8013c4:	ff d0                	call   *%eax
  8013c6:	89 c2                	mov    %eax,%edx
  8013c8:	83 c4 10             	add    $0x10,%esp
  8013cb:	eb 09                	jmp    8013d6 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013cd:	89 c2                	mov    %eax,%edx
  8013cf:	eb 05                	jmp    8013d6 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013d1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8013d6:	89 d0                	mov    %edx,%eax
  8013d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013db:	c9                   	leave  
  8013dc:	c3                   	ret    

008013dd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013dd:	55                   	push   %ebp
  8013de:	89 e5                	mov    %esp,%ebp
  8013e0:	57                   	push   %edi
  8013e1:	56                   	push   %esi
  8013e2:	53                   	push   %ebx
  8013e3:	83 ec 0c             	sub    $0xc,%esp
  8013e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013e9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013f1:	eb 21                	jmp    801414 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013f3:	83 ec 04             	sub    $0x4,%esp
  8013f6:	89 f0                	mov    %esi,%eax
  8013f8:	29 d8                	sub    %ebx,%eax
  8013fa:	50                   	push   %eax
  8013fb:	89 d8                	mov    %ebx,%eax
  8013fd:	03 45 0c             	add    0xc(%ebp),%eax
  801400:	50                   	push   %eax
  801401:	57                   	push   %edi
  801402:	e8 42 ff ff ff       	call   801349 <read>
		if (m < 0)
  801407:	83 c4 10             	add    $0x10,%esp
  80140a:	85 c0                	test   %eax,%eax
  80140c:	78 10                	js     80141e <readn+0x41>
			return m;
		if (m == 0)
  80140e:	85 c0                	test   %eax,%eax
  801410:	74 0a                	je     80141c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801412:	01 c3                	add    %eax,%ebx
  801414:	39 f3                	cmp    %esi,%ebx
  801416:	72 db                	jb     8013f3 <readn+0x16>
  801418:	89 d8                	mov    %ebx,%eax
  80141a:	eb 02                	jmp    80141e <readn+0x41>
  80141c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80141e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801421:	5b                   	pop    %ebx
  801422:	5e                   	pop    %esi
  801423:	5f                   	pop    %edi
  801424:	5d                   	pop    %ebp
  801425:	c3                   	ret    

00801426 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801426:	55                   	push   %ebp
  801427:	89 e5                	mov    %esp,%ebp
  801429:	53                   	push   %ebx
  80142a:	83 ec 14             	sub    $0x14,%esp
  80142d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801430:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801433:	50                   	push   %eax
  801434:	53                   	push   %ebx
  801435:	e8 a6 fc ff ff       	call   8010e0 <fd_lookup>
  80143a:	83 c4 08             	add    $0x8,%esp
  80143d:	89 c2                	mov    %eax,%edx
  80143f:	85 c0                	test   %eax,%eax
  801441:	78 6b                	js     8014ae <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801443:	83 ec 08             	sub    $0x8,%esp
  801446:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801449:	50                   	push   %eax
  80144a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144d:	ff 30                	pushl  (%eax)
  80144f:	e8 e2 fc ff ff       	call   801136 <dev_lookup>
  801454:	83 c4 10             	add    $0x10,%esp
  801457:	85 c0                	test   %eax,%eax
  801459:	78 4a                	js     8014a5 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80145b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80145e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801462:	75 24                	jne    801488 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801464:	a1 04 40 80 00       	mov    0x804004,%eax
  801469:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80146f:	83 ec 04             	sub    $0x4,%esp
  801472:	53                   	push   %ebx
  801473:	50                   	push   %eax
  801474:	68 85 26 80 00       	push   $0x802685
  801479:	e8 f9 ec ff ff       	call   800177 <cprintf>
		return -E_INVAL;
  80147e:	83 c4 10             	add    $0x10,%esp
  801481:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801486:	eb 26                	jmp    8014ae <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801488:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80148b:	8b 52 0c             	mov    0xc(%edx),%edx
  80148e:	85 d2                	test   %edx,%edx
  801490:	74 17                	je     8014a9 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801492:	83 ec 04             	sub    $0x4,%esp
  801495:	ff 75 10             	pushl  0x10(%ebp)
  801498:	ff 75 0c             	pushl  0xc(%ebp)
  80149b:	50                   	push   %eax
  80149c:	ff d2                	call   *%edx
  80149e:	89 c2                	mov    %eax,%edx
  8014a0:	83 c4 10             	add    $0x10,%esp
  8014a3:	eb 09                	jmp    8014ae <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a5:	89 c2                	mov    %eax,%edx
  8014a7:	eb 05                	jmp    8014ae <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014a9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014ae:	89 d0                	mov    %edx,%eax
  8014b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014b3:	c9                   	leave  
  8014b4:	c3                   	ret    

008014b5 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014b5:	55                   	push   %ebp
  8014b6:	89 e5                	mov    %esp,%ebp
  8014b8:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014bb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014be:	50                   	push   %eax
  8014bf:	ff 75 08             	pushl  0x8(%ebp)
  8014c2:	e8 19 fc ff ff       	call   8010e0 <fd_lookup>
  8014c7:	83 c4 08             	add    $0x8,%esp
  8014ca:	85 c0                	test   %eax,%eax
  8014cc:	78 0e                	js     8014dc <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014d4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014dc:	c9                   	leave  
  8014dd:	c3                   	ret    

008014de <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014de:	55                   	push   %ebp
  8014df:	89 e5                	mov    %esp,%ebp
  8014e1:	53                   	push   %ebx
  8014e2:	83 ec 14             	sub    $0x14,%esp
  8014e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014eb:	50                   	push   %eax
  8014ec:	53                   	push   %ebx
  8014ed:	e8 ee fb ff ff       	call   8010e0 <fd_lookup>
  8014f2:	83 c4 08             	add    $0x8,%esp
  8014f5:	89 c2                	mov    %eax,%edx
  8014f7:	85 c0                	test   %eax,%eax
  8014f9:	78 68                	js     801563 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014fb:	83 ec 08             	sub    $0x8,%esp
  8014fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801501:	50                   	push   %eax
  801502:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801505:	ff 30                	pushl  (%eax)
  801507:	e8 2a fc ff ff       	call   801136 <dev_lookup>
  80150c:	83 c4 10             	add    $0x10,%esp
  80150f:	85 c0                	test   %eax,%eax
  801511:	78 47                	js     80155a <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801513:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801516:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80151a:	75 24                	jne    801540 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80151c:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801521:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801527:	83 ec 04             	sub    $0x4,%esp
  80152a:	53                   	push   %ebx
  80152b:	50                   	push   %eax
  80152c:	68 48 26 80 00       	push   $0x802648
  801531:	e8 41 ec ff ff       	call   800177 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801536:	83 c4 10             	add    $0x10,%esp
  801539:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80153e:	eb 23                	jmp    801563 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801540:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801543:	8b 52 18             	mov    0x18(%edx),%edx
  801546:	85 d2                	test   %edx,%edx
  801548:	74 14                	je     80155e <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80154a:	83 ec 08             	sub    $0x8,%esp
  80154d:	ff 75 0c             	pushl  0xc(%ebp)
  801550:	50                   	push   %eax
  801551:	ff d2                	call   *%edx
  801553:	89 c2                	mov    %eax,%edx
  801555:	83 c4 10             	add    $0x10,%esp
  801558:	eb 09                	jmp    801563 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155a:	89 c2                	mov    %eax,%edx
  80155c:	eb 05                	jmp    801563 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80155e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801563:	89 d0                	mov    %edx,%eax
  801565:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801568:	c9                   	leave  
  801569:	c3                   	ret    

0080156a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	53                   	push   %ebx
  80156e:	83 ec 14             	sub    $0x14,%esp
  801571:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801574:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801577:	50                   	push   %eax
  801578:	ff 75 08             	pushl  0x8(%ebp)
  80157b:	e8 60 fb ff ff       	call   8010e0 <fd_lookup>
  801580:	83 c4 08             	add    $0x8,%esp
  801583:	89 c2                	mov    %eax,%edx
  801585:	85 c0                	test   %eax,%eax
  801587:	78 58                	js     8015e1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801589:	83 ec 08             	sub    $0x8,%esp
  80158c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158f:	50                   	push   %eax
  801590:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801593:	ff 30                	pushl  (%eax)
  801595:	e8 9c fb ff ff       	call   801136 <dev_lookup>
  80159a:	83 c4 10             	add    $0x10,%esp
  80159d:	85 c0                	test   %eax,%eax
  80159f:	78 37                	js     8015d8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015a8:	74 32                	je     8015dc <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015aa:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015ad:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015b4:	00 00 00 
	stat->st_isdir = 0;
  8015b7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015be:	00 00 00 
	stat->st_dev = dev;
  8015c1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015c7:	83 ec 08             	sub    $0x8,%esp
  8015ca:	53                   	push   %ebx
  8015cb:	ff 75 f0             	pushl  -0x10(%ebp)
  8015ce:	ff 50 14             	call   *0x14(%eax)
  8015d1:	89 c2                	mov    %eax,%edx
  8015d3:	83 c4 10             	add    $0x10,%esp
  8015d6:	eb 09                	jmp    8015e1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d8:	89 c2                	mov    %eax,%edx
  8015da:	eb 05                	jmp    8015e1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015dc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015e1:	89 d0                	mov    %edx,%eax
  8015e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e6:	c9                   	leave  
  8015e7:	c3                   	ret    

008015e8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015e8:	55                   	push   %ebp
  8015e9:	89 e5                	mov    %esp,%ebp
  8015eb:	56                   	push   %esi
  8015ec:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015ed:	83 ec 08             	sub    $0x8,%esp
  8015f0:	6a 00                	push   $0x0
  8015f2:	ff 75 08             	pushl  0x8(%ebp)
  8015f5:	e8 e3 01 00 00       	call   8017dd <open>
  8015fa:	89 c3                	mov    %eax,%ebx
  8015fc:	83 c4 10             	add    $0x10,%esp
  8015ff:	85 c0                	test   %eax,%eax
  801601:	78 1b                	js     80161e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801603:	83 ec 08             	sub    $0x8,%esp
  801606:	ff 75 0c             	pushl  0xc(%ebp)
  801609:	50                   	push   %eax
  80160a:	e8 5b ff ff ff       	call   80156a <fstat>
  80160f:	89 c6                	mov    %eax,%esi
	close(fd);
  801611:	89 1c 24             	mov    %ebx,(%esp)
  801614:	e8 f4 fb ff ff       	call   80120d <close>
	return r;
  801619:	83 c4 10             	add    $0x10,%esp
  80161c:	89 f0                	mov    %esi,%eax
}
  80161e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801621:	5b                   	pop    %ebx
  801622:	5e                   	pop    %esi
  801623:	5d                   	pop    %ebp
  801624:	c3                   	ret    

00801625 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801625:	55                   	push   %ebp
  801626:	89 e5                	mov    %esp,%ebp
  801628:	56                   	push   %esi
  801629:	53                   	push   %ebx
  80162a:	89 c6                	mov    %eax,%esi
  80162c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80162e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801635:	75 12                	jne    801649 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801637:	83 ec 0c             	sub    $0xc,%esp
  80163a:	6a 01                	push   $0x1
  80163c:	e8 da 08 00 00       	call   801f1b <ipc_find_env>
  801641:	a3 00 40 80 00       	mov    %eax,0x804000
  801646:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801649:	6a 07                	push   $0x7
  80164b:	68 00 50 80 00       	push   $0x805000
  801650:	56                   	push   %esi
  801651:	ff 35 00 40 80 00    	pushl  0x804000
  801657:	e8 5d 08 00 00       	call   801eb9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80165c:	83 c4 0c             	add    $0xc,%esp
  80165f:	6a 00                	push   $0x0
  801661:	53                   	push   %ebx
  801662:	6a 00                	push   $0x0
  801664:	e8 d5 07 00 00       	call   801e3e <ipc_recv>
}
  801669:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80166c:	5b                   	pop    %ebx
  80166d:	5e                   	pop    %esi
  80166e:	5d                   	pop    %ebp
  80166f:	c3                   	ret    

00801670 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801670:	55                   	push   %ebp
  801671:	89 e5                	mov    %esp,%ebp
  801673:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801676:	8b 45 08             	mov    0x8(%ebp),%eax
  801679:	8b 40 0c             	mov    0xc(%eax),%eax
  80167c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801681:	8b 45 0c             	mov    0xc(%ebp),%eax
  801684:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801689:	ba 00 00 00 00       	mov    $0x0,%edx
  80168e:	b8 02 00 00 00       	mov    $0x2,%eax
  801693:	e8 8d ff ff ff       	call   801625 <fsipc>
}
  801698:	c9                   	leave  
  801699:	c3                   	ret    

0080169a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80169a:	55                   	push   %ebp
  80169b:	89 e5                	mov    %esp,%ebp
  80169d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b0:	b8 06 00 00 00       	mov    $0x6,%eax
  8016b5:	e8 6b ff ff ff       	call   801625 <fsipc>
}
  8016ba:	c9                   	leave  
  8016bb:	c3                   	ret    

008016bc <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016bc:	55                   	push   %ebp
  8016bd:	89 e5                	mov    %esp,%ebp
  8016bf:	53                   	push   %ebx
  8016c0:	83 ec 04             	sub    $0x4,%esp
  8016c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8016cc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d6:	b8 05 00 00 00       	mov    $0x5,%eax
  8016db:	e8 45 ff ff ff       	call   801625 <fsipc>
  8016e0:	85 c0                	test   %eax,%eax
  8016e2:	78 2c                	js     801710 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016e4:	83 ec 08             	sub    $0x8,%esp
  8016e7:	68 00 50 80 00       	push   $0x805000
  8016ec:	53                   	push   %ebx
  8016ed:	e8 0a f0 ff ff       	call   8006fc <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016f2:	a1 80 50 80 00       	mov    0x805080,%eax
  8016f7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016fd:	a1 84 50 80 00       	mov    0x805084,%eax
  801702:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801708:	83 c4 10             	add    $0x10,%esp
  80170b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801710:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801713:	c9                   	leave  
  801714:	c3                   	ret    

00801715 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801715:	55                   	push   %ebp
  801716:	89 e5                	mov    %esp,%ebp
  801718:	83 ec 0c             	sub    $0xc,%esp
  80171b:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80171e:	8b 55 08             	mov    0x8(%ebp),%edx
  801721:	8b 52 0c             	mov    0xc(%edx),%edx
  801724:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80172a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80172f:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801734:	0f 47 c2             	cmova  %edx,%eax
  801737:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80173c:	50                   	push   %eax
  80173d:	ff 75 0c             	pushl  0xc(%ebp)
  801740:	68 08 50 80 00       	push   $0x805008
  801745:	e8 44 f1 ff ff       	call   80088e <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80174a:	ba 00 00 00 00       	mov    $0x0,%edx
  80174f:	b8 04 00 00 00       	mov    $0x4,%eax
  801754:	e8 cc fe ff ff       	call   801625 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801759:	c9                   	leave  
  80175a:	c3                   	ret    

0080175b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80175b:	55                   	push   %ebp
  80175c:	89 e5                	mov    %esp,%ebp
  80175e:	56                   	push   %esi
  80175f:	53                   	push   %ebx
  801760:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801763:	8b 45 08             	mov    0x8(%ebp),%eax
  801766:	8b 40 0c             	mov    0xc(%eax),%eax
  801769:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80176e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801774:	ba 00 00 00 00       	mov    $0x0,%edx
  801779:	b8 03 00 00 00       	mov    $0x3,%eax
  80177e:	e8 a2 fe ff ff       	call   801625 <fsipc>
  801783:	89 c3                	mov    %eax,%ebx
  801785:	85 c0                	test   %eax,%eax
  801787:	78 4b                	js     8017d4 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801789:	39 c6                	cmp    %eax,%esi
  80178b:	73 16                	jae    8017a3 <devfile_read+0x48>
  80178d:	68 b4 26 80 00       	push   $0x8026b4
  801792:	68 bb 26 80 00       	push   $0x8026bb
  801797:	6a 7c                	push   $0x7c
  801799:	68 d0 26 80 00       	push   $0x8026d0
  80179e:	e8 c6 05 00 00       	call   801d69 <_panic>
	assert(r <= PGSIZE);
  8017a3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017a8:	7e 16                	jle    8017c0 <devfile_read+0x65>
  8017aa:	68 db 26 80 00       	push   $0x8026db
  8017af:	68 bb 26 80 00       	push   $0x8026bb
  8017b4:	6a 7d                	push   $0x7d
  8017b6:	68 d0 26 80 00       	push   $0x8026d0
  8017bb:	e8 a9 05 00 00       	call   801d69 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017c0:	83 ec 04             	sub    $0x4,%esp
  8017c3:	50                   	push   %eax
  8017c4:	68 00 50 80 00       	push   $0x805000
  8017c9:	ff 75 0c             	pushl  0xc(%ebp)
  8017cc:	e8 bd f0 ff ff       	call   80088e <memmove>
	return r;
  8017d1:	83 c4 10             	add    $0x10,%esp
}
  8017d4:	89 d8                	mov    %ebx,%eax
  8017d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d9:	5b                   	pop    %ebx
  8017da:	5e                   	pop    %esi
  8017db:	5d                   	pop    %ebp
  8017dc:	c3                   	ret    

008017dd <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017dd:	55                   	push   %ebp
  8017de:	89 e5                	mov    %esp,%ebp
  8017e0:	53                   	push   %ebx
  8017e1:	83 ec 20             	sub    $0x20,%esp
  8017e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017e7:	53                   	push   %ebx
  8017e8:	e8 d6 ee ff ff       	call   8006c3 <strlen>
  8017ed:	83 c4 10             	add    $0x10,%esp
  8017f0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017f5:	7f 67                	jg     80185e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017f7:	83 ec 0c             	sub    $0xc,%esp
  8017fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017fd:	50                   	push   %eax
  8017fe:	e8 8e f8 ff ff       	call   801091 <fd_alloc>
  801803:	83 c4 10             	add    $0x10,%esp
		return r;
  801806:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801808:	85 c0                	test   %eax,%eax
  80180a:	78 57                	js     801863 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80180c:	83 ec 08             	sub    $0x8,%esp
  80180f:	53                   	push   %ebx
  801810:	68 00 50 80 00       	push   $0x805000
  801815:	e8 e2 ee ff ff       	call   8006fc <strcpy>
	fsipcbuf.open.req_omode = mode;
  80181a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80181d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801822:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801825:	b8 01 00 00 00       	mov    $0x1,%eax
  80182a:	e8 f6 fd ff ff       	call   801625 <fsipc>
  80182f:	89 c3                	mov    %eax,%ebx
  801831:	83 c4 10             	add    $0x10,%esp
  801834:	85 c0                	test   %eax,%eax
  801836:	79 14                	jns    80184c <open+0x6f>
		fd_close(fd, 0);
  801838:	83 ec 08             	sub    $0x8,%esp
  80183b:	6a 00                	push   $0x0
  80183d:	ff 75 f4             	pushl  -0xc(%ebp)
  801840:	e8 47 f9 ff ff       	call   80118c <fd_close>
		return r;
  801845:	83 c4 10             	add    $0x10,%esp
  801848:	89 da                	mov    %ebx,%edx
  80184a:	eb 17                	jmp    801863 <open+0x86>
	}

	return fd2num(fd);
  80184c:	83 ec 0c             	sub    $0xc,%esp
  80184f:	ff 75 f4             	pushl  -0xc(%ebp)
  801852:	e8 13 f8 ff ff       	call   80106a <fd2num>
  801857:	89 c2                	mov    %eax,%edx
  801859:	83 c4 10             	add    $0x10,%esp
  80185c:	eb 05                	jmp    801863 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80185e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801863:	89 d0                	mov    %edx,%eax
  801865:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801868:	c9                   	leave  
  801869:	c3                   	ret    

0080186a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80186a:	55                   	push   %ebp
  80186b:	89 e5                	mov    %esp,%ebp
  80186d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801870:	ba 00 00 00 00       	mov    $0x0,%edx
  801875:	b8 08 00 00 00       	mov    $0x8,%eax
  80187a:	e8 a6 fd ff ff       	call   801625 <fsipc>
}
  80187f:	c9                   	leave  
  801880:	c3                   	ret    

00801881 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801881:	55                   	push   %ebp
  801882:	89 e5                	mov    %esp,%ebp
  801884:	56                   	push   %esi
  801885:	53                   	push   %ebx
  801886:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801889:	83 ec 0c             	sub    $0xc,%esp
  80188c:	ff 75 08             	pushl  0x8(%ebp)
  80188f:	e8 e6 f7 ff ff       	call   80107a <fd2data>
  801894:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801896:	83 c4 08             	add    $0x8,%esp
  801899:	68 e7 26 80 00       	push   $0x8026e7
  80189e:	53                   	push   %ebx
  80189f:	e8 58 ee ff ff       	call   8006fc <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018a4:	8b 46 04             	mov    0x4(%esi),%eax
  8018a7:	2b 06                	sub    (%esi),%eax
  8018a9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018af:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018b6:	00 00 00 
	stat->st_dev = &devpipe;
  8018b9:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018c0:	30 80 00 
	return 0;
}
  8018c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8018c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018cb:	5b                   	pop    %ebx
  8018cc:	5e                   	pop    %esi
  8018cd:	5d                   	pop    %ebp
  8018ce:	c3                   	ret    

008018cf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018cf:	55                   	push   %ebp
  8018d0:	89 e5                	mov    %esp,%ebp
  8018d2:	53                   	push   %ebx
  8018d3:	83 ec 0c             	sub    $0xc,%esp
  8018d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018d9:	53                   	push   %ebx
  8018da:	6a 00                	push   $0x0
  8018dc:	e8 a3 f2 ff ff       	call   800b84 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018e1:	89 1c 24             	mov    %ebx,(%esp)
  8018e4:	e8 91 f7 ff ff       	call   80107a <fd2data>
  8018e9:	83 c4 08             	add    $0x8,%esp
  8018ec:	50                   	push   %eax
  8018ed:	6a 00                	push   $0x0
  8018ef:	e8 90 f2 ff ff       	call   800b84 <sys_page_unmap>
}
  8018f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f7:	c9                   	leave  
  8018f8:	c3                   	ret    

008018f9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018f9:	55                   	push   %ebp
  8018fa:	89 e5                	mov    %esp,%ebp
  8018fc:	57                   	push   %edi
  8018fd:	56                   	push   %esi
  8018fe:	53                   	push   %ebx
  8018ff:	83 ec 1c             	sub    $0x1c,%esp
  801902:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801905:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801907:	a1 04 40 80 00       	mov    0x804004,%eax
  80190c:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801912:	83 ec 0c             	sub    $0xc,%esp
  801915:	ff 75 e0             	pushl  -0x20(%ebp)
  801918:	e8 43 06 00 00       	call   801f60 <pageref>
  80191d:	89 c3                	mov    %eax,%ebx
  80191f:	89 3c 24             	mov    %edi,(%esp)
  801922:	e8 39 06 00 00       	call   801f60 <pageref>
  801927:	83 c4 10             	add    $0x10,%esp
  80192a:	39 c3                	cmp    %eax,%ebx
  80192c:	0f 94 c1             	sete   %cl
  80192f:	0f b6 c9             	movzbl %cl,%ecx
  801932:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801935:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80193b:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801941:	39 ce                	cmp    %ecx,%esi
  801943:	74 1e                	je     801963 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801945:	39 c3                	cmp    %eax,%ebx
  801947:	75 be                	jne    801907 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801949:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  80194f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801952:	50                   	push   %eax
  801953:	56                   	push   %esi
  801954:	68 ee 26 80 00       	push   $0x8026ee
  801959:	e8 19 e8 ff ff       	call   800177 <cprintf>
  80195e:	83 c4 10             	add    $0x10,%esp
  801961:	eb a4                	jmp    801907 <_pipeisclosed+0xe>
	}
}
  801963:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801966:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801969:	5b                   	pop    %ebx
  80196a:	5e                   	pop    %esi
  80196b:	5f                   	pop    %edi
  80196c:	5d                   	pop    %ebp
  80196d:	c3                   	ret    

0080196e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80196e:	55                   	push   %ebp
  80196f:	89 e5                	mov    %esp,%ebp
  801971:	57                   	push   %edi
  801972:	56                   	push   %esi
  801973:	53                   	push   %ebx
  801974:	83 ec 28             	sub    $0x28,%esp
  801977:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80197a:	56                   	push   %esi
  80197b:	e8 fa f6 ff ff       	call   80107a <fd2data>
  801980:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801982:	83 c4 10             	add    $0x10,%esp
  801985:	bf 00 00 00 00       	mov    $0x0,%edi
  80198a:	eb 4b                	jmp    8019d7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80198c:	89 da                	mov    %ebx,%edx
  80198e:	89 f0                	mov    %esi,%eax
  801990:	e8 64 ff ff ff       	call   8018f9 <_pipeisclosed>
  801995:	85 c0                	test   %eax,%eax
  801997:	75 48                	jne    8019e1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801999:	e8 42 f1 ff ff       	call   800ae0 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80199e:	8b 43 04             	mov    0x4(%ebx),%eax
  8019a1:	8b 0b                	mov    (%ebx),%ecx
  8019a3:	8d 51 20             	lea    0x20(%ecx),%edx
  8019a6:	39 d0                	cmp    %edx,%eax
  8019a8:	73 e2                	jae    80198c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019ad:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019b1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019b4:	89 c2                	mov    %eax,%edx
  8019b6:	c1 fa 1f             	sar    $0x1f,%edx
  8019b9:	89 d1                	mov    %edx,%ecx
  8019bb:	c1 e9 1b             	shr    $0x1b,%ecx
  8019be:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019c1:	83 e2 1f             	and    $0x1f,%edx
  8019c4:	29 ca                	sub    %ecx,%edx
  8019c6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8019ca:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019ce:	83 c0 01             	add    $0x1,%eax
  8019d1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019d4:	83 c7 01             	add    $0x1,%edi
  8019d7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019da:	75 c2                	jne    80199e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8019df:	eb 05                	jmp    8019e6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019e1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019e9:	5b                   	pop    %ebx
  8019ea:	5e                   	pop    %esi
  8019eb:	5f                   	pop    %edi
  8019ec:	5d                   	pop    %ebp
  8019ed:	c3                   	ret    

008019ee <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019ee:	55                   	push   %ebp
  8019ef:	89 e5                	mov    %esp,%ebp
  8019f1:	57                   	push   %edi
  8019f2:	56                   	push   %esi
  8019f3:	53                   	push   %ebx
  8019f4:	83 ec 18             	sub    $0x18,%esp
  8019f7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019fa:	57                   	push   %edi
  8019fb:	e8 7a f6 ff ff       	call   80107a <fd2data>
  801a00:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a02:	83 c4 10             	add    $0x10,%esp
  801a05:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a0a:	eb 3d                	jmp    801a49 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a0c:	85 db                	test   %ebx,%ebx
  801a0e:	74 04                	je     801a14 <devpipe_read+0x26>
				return i;
  801a10:	89 d8                	mov    %ebx,%eax
  801a12:	eb 44                	jmp    801a58 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a14:	89 f2                	mov    %esi,%edx
  801a16:	89 f8                	mov    %edi,%eax
  801a18:	e8 dc fe ff ff       	call   8018f9 <_pipeisclosed>
  801a1d:	85 c0                	test   %eax,%eax
  801a1f:	75 32                	jne    801a53 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a21:	e8 ba f0 ff ff       	call   800ae0 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a26:	8b 06                	mov    (%esi),%eax
  801a28:	3b 46 04             	cmp    0x4(%esi),%eax
  801a2b:	74 df                	je     801a0c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a2d:	99                   	cltd   
  801a2e:	c1 ea 1b             	shr    $0x1b,%edx
  801a31:	01 d0                	add    %edx,%eax
  801a33:	83 e0 1f             	and    $0x1f,%eax
  801a36:	29 d0                	sub    %edx,%eax
  801a38:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a40:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a43:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a46:	83 c3 01             	add    $0x1,%ebx
  801a49:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a4c:	75 d8                	jne    801a26 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a4e:	8b 45 10             	mov    0x10(%ebp),%eax
  801a51:	eb 05                	jmp    801a58 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a53:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a5b:	5b                   	pop    %ebx
  801a5c:	5e                   	pop    %esi
  801a5d:	5f                   	pop    %edi
  801a5e:	5d                   	pop    %ebp
  801a5f:	c3                   	ret    

00801a60 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	56                   	push   %esi
  801a64:	53                   	push   %ebx
  801a65:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a68:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a6b:	50                   	push   %eax
  801a6c:	e8 20 f6 ff ff       	call   801091 <fd_alloc>
  801a71:	83 c4 10             	add    $0x10,%esp
  801a74:	89 c2                	mov    %eax,%edx
  801a76:	85 c0                	test   %eax,%eax
  801a78:	0f 88 2c 01 00 00    	js     801baa <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a7e:	83 ec 04             	sub    $0x4,%esp
  801a81:	68 07 04 00 00       	push   $0x407
  801a86:	ff 75 f4             	pushl  -0xc(%ebp)
  801a89:	6a 00                	push   $0x0
  801a8b:	e8 6f f0 ff ff       	call   800aff <sys_page_alloc>
  801a90:	83 c4 10             	add    $0x10,%esp
  801a93:	89 c2                	mov    %eax,%edx
  801a95:	85 c0                	test   %eax,%eax
  801a97:	0f 88 0d 01 00 00    	js     801baa <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a9d:	83 ec 0c             	sub    $0xc,%esp
  801aa0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801aa3:	50                   	push   %eax
  801aa4:	e8 e8 f5 ff ff       	call   801091 <fd_alloc>
  801aa9:	89 c3                	mov    %eax,%ebx
  801aab:	83 c4 10             	add    $0x10,%esp
  801aae:	85 c0                	test   %eax,%eax
  801ab0:	0f 88 e2 00 00 00    	js     801b98 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ab6:	83 ec 04             	sub    $0x4,%esp
  801ab9:	68 07 04 00 00       	push   $0x407
  801abe:	ff 75 f0             	pushl  -0x10(%ebp)
  801ac1:	6a 00                	push   $0x0
  801ac3:	e8 37 f0 ff ff       	call   800aff <sys_page_alloc>
  801ac8:	89 c3                	mov    %eax,%ebx
  801aca:	83 c4 10             	add    $0x10,%esp
  801acd:	85 c0                	test   %eax,%eax
  801acf:	0f 88 c3 00 00 00    	js     801b98 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ad5:	83 ec 0c             	sub    $0xc,%esp
  801ad8:	ff 75 f4             	pushl  -0xc(%ebp)
  801adb:	e8 9a f5 ff ff       	call   80107a <fd2data>
  801ae0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ae2:	83 c4 0c             	add    $0xc,%esp
  801ae5:	68 07 04 00 00       	push   $0x407
  801aea:	50                   	push   %eax
  801aeb:	6a 00                	push   $0x0
  801aed:	e8 0d f0 ff ff       	call   800aff <sys_page_alloc>
  801af2:	89 c3                	mov    %eax,%ebx
  801af4:	83 c4 10             	add    $0x10,%esp
  801af7:	85 c0                	test   %eax,%eax
  801af9:	0f 88 89 00 00 00    	js     801b88 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aff:	83 ec 0c             	sub    $0xc,%esp
  801b02:	ff 75 f0             	pushl  -0x10(%ebp)
  801b05:	e8 70 f5 ff ff       	call   80107a <fd2data>
  801b0a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b11:	50                   	push   %eax
  801b12:	6a 00                	push   $0x0
  801b14:	56                   	push   %esi
  801b15:	6a 00                	push   $0x0
  801b17:	e8 26 f0 ff ff       	call   800b42 <sys_page_map>
  801b1c:	89 c3                	mov    %eax,%ebx
  801b1e:	83 c4 20             	add    $0x20,%esp
  801b21:	85 c0                	test   %eax,%eax
  801b23:	78 55                	js     801b7a <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b25:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b2e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b33:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b3a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b40:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b43:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b45:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b48:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b4f:	83 ec 0c             	sub    $0xc,%esp
  801b52:	ff 75 f4             	pushl  -0xc(%ebp)
  801b55:	e8 10 f5 ff ff       	call   80106a <fd2num>
  801b5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b5d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b5f:	83 c4 04             	add    $0x4,%esp
  801b62:	ff 75 f0             	pushl  -0x10(%ebp)
  801b65:	e8 00 f5 ff ff       	call   80106a <fd2num>
  801b6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b6d:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801b70:	83 c4 10             	add    $0x10,%esp
  801b73:	ba 00 00 00 00       	mov    $0x0,%edx
  801b78:	eb 30                	jmp    801baa <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b7a:	83 ec 08             	sub    $0x8,%esp
  801b7d:	56                   	push   %esi
  801b7e:	6a 00                	push   $0x0
  801b80:	e8 ff ef ff ff       	call   800b84 <sys_page_unmap>
  801b85:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b88:	83 ec 08             	sub    $0x8,%esp
  801b8b:	ff 75 f0             	pushl  -0x10(%ebp)
  801b8e:	6a 00                	push   $0x0
  801b90:	e8 ef ef ff ff       	call   800b84 <sys_page_unmap>
  801b95:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b98:	83 ec 08             	sub    $0x8,%esp
  801b9b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b9e:	6a 00                	push   $0x0
  801ba0:	e8 df ef ff ff       	call   800b84 <sys_page_unmap>
  801ba5:	83 c4 10             	add    $0x10,%esp
  801ba8:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801baa:	89 d0                	mov    %edx,%eax
  801bac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801baf:	5b                   	pop    %ebx
  801bb0:	5e                   	pop    %esi
  801bb1:	5d                   	pop    %ebp
  801bb2:	c3                   	ret    

00801bb3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801bb3:	55                   	push   %ebp
  801bb4:	89 e5                	mov    %esp,%ebp
  801bb6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bb9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bbc:	50                   	push   %eax
  801bbd:	ff 75 08             	pushl  0x8(%ebp)
  801bc0:	e8 1b f5 ff ff       	call   8010e0 <fd_lookup>
  801bc5:	83 c4 10             	add    $0x10,%esp
  801bc8:	85 c0                	test   %eax,%eax
  801bca:	78 18                	js     801be4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801bcc:	83 ec 0c             	sub    $0xc,%esp
  801bcf:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd2:	e8 a3 f4 ff ff       	call   80107a <fd2data>
	return _pipeisclosed(fd, p);
  801bd7:	89 c2                	mov    %eax,%edx
  801bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bdc:	e8 18 fd ff ff       	call   8018f9 <_pipeisclosed>
  801be1:	83 c4 10             	add    $0x10,%esp
}
  801be4:	c9                   	leave  
  801be5:	c3                   	ret    

00801be6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801be6:	55                   	push   %ebp
  801be7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801be9:	b8 00 00 00 00       	mov    $0x0,%eax
  801bee:	5d                   	pop    %ebp
  801bef:	c3                   	ret    

00801bf0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801bf0:	55                   	push   %ebp
  801bf1:	89 e5                	mov    %esp,%ebp
  801bf3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801bf6:	68 06 27 80 00       	push   $0x802706
  801bfb:	ff 75 0c             	pushl  0xc(%ebp)
  801bfe:	e8 f9 ea ff ff       	call   8006fc <strcpy>
	return 0;
}
  801c03:	b8 00 00 00 00       	mov    $0x0,%eax
  801c08:	c9                   	leave  
  801c09:	c3                   	ret    

00801c0a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c0a:	55                   	push   %ebp
  801c0b:	89 e5                	mov    %esp,%ebp
  801c0d:	57                   	push   %edi
  801c0e:	56                   	push   %esi
  801c0f:	53                   	push   %ebx
  801c10:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c16:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c1b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c21:	eb 2d                	jmp    801c50 <devcons_write+0x46>
		m = n - tot;
  801c23:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c26:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c28:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c2b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c30:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c33:	83 ec 04             	sub    $0x4,%esp
  801c36:	53                   	push   %ebx
  801c37:	03 45 0c             	add    0xc(%ebp),%eax
  801c3a:	50                   	push   %eax
  801c3b:	57                   	push   %edi
  801c3c:	e8 4d ec ff ff       	call   80088e <memmove>
		sys_cputs(buf, m);
  801c41:	83 c4 08             	add    $0x8,%esp
  801c44:	53                   	push   %ebx
  801c45:	57                   	push   %edi
  801c46:	e8 f8 ed ff ff       	call   800a43 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c4b:	01 de                	add    %ebx,%esi
  801c4d:	83 c4 10             	add    $0x10,%esp
  801c50:	89 f0                	mov    %esi,%eax
  801c52:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c55:	72 cc                	jb     801c23 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c5a:	5b                   	pop    %ebx
  801c5b:	5e                   	pop    %esi
  801c5c:	5f                   	pop    %edi
  801c5d:	5d                   	pop    %ebp
  801c5e:	c3                   	ret    

00801c5f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c5f:	55                   	push   %ebp
  801c60:	89 e5                	mov    %esp,%ebp
  801c62:	83 ec 08             	sub    $0x8,%esp
  801c65:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c6a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c6e:	74 2a                	je     801c9a <devcons_read+0x3b>
  801c70:	eb 05                	jmp    801c77 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c72:	e8 69 ee ff ff       	call   800ae0 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c77:	e8 e5 ed ff ff       	call   800a61 <sys_cgetc>
  801c7c:	85 c0                	test   %eax,%eax
  801c7e:	74 f2                	je     801c72 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c80:	85 c0                	test   %eax,%eax
  801c82:	78 16                	js     801c9a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c84:	83 f8 04             	cmp    $0x4,%eax
  801c87:	74 0c                	je     801c95 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c89:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c8c:	88 02                	mov    %al,(%edx)
	return 1;
  801c8e:	b8 01 00 00 00       	mov    $0x1,%eax
  801c93:	eb 05                	jmp    801c9a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c95:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c9a:	c9                   	leave  
  801c9b:	c3                   	ret    

00801c9c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c9c:	55                   	push   %ebp
  801c9d:	89 e5                	mov    %esp,%ebp
  801c9f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ca2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca5:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ca8:	6a 01                	push   $0x1
  801caa:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cad:	50                   	push   %eax
  801cae:	e8 90 ed ff ff       	call   800a43 <sys_cputs>
}
  801cb3:	83 c4 10             	add    $0x10,%esp
  801cb6:	c9                   	leave  
  801cb7:	c3                   	ret    

00801cb8 <getchar>:

int
getchar(void)
{
  801cb8:	55                   	push   %ebp
  801cb9:	89 e5                	mov    %esp,%ebp
  801cbb:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801cbe:	6a 01                	push   $0x1
  801cc0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cc3:	50                   	push   %eax
  801cc4:	6a 00                	push   $0x0
  801cc6:	e8 7e f6 ff ff       	call   801349 <read>
	if (r < 0)
  801ccb:	83 c4 10             	add    $0x10,%esp
  801cce:	85 c0                	test   %eax,%eax
  801cd0:	78 0f                	js     801ce1 <getchar+0x29>
		return r;
	if (r < 1)
  801cd2:	85 c0                	test   %eax,%eax
  801cd4:	7e 06                	jle    801cdc <getchar+0x24>
		return -E_EOF;
	return c;
  801cd6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801cda:	eb 05                	jmp    801ce1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801cdc:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ce1:	c9                   	leave  
  801ce2:	c3                   	ret    

00801ce3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ce3:	55                   	push   %ebp
  801ce4:	89 e5                	mov    %esp,%ebp
  801ce6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ce9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cec:	50                   	push   %eax
  801ced:	ff 75 08             	pushl  0x8(%ebp)
  801cf0:	e8 eb f3 ff ff       	call   8010e0 <fd_lookup>
  801cf5:	83 c4 10             	add    $0x10,%esp
  801cf8:	85 c0                	test   %eax,%eax
  801cfa:	78 11                	js     801d0d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801cfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cff:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d05:	39 10                	cmp    %edx,(%eax)
  801d07:	0f 94 c0             	sete   %al
  801d0a:	0f b6 c0             	movzbl %al,%eax
}
  801d0d:	c9                   	leave  
  801d0e:	c3                   	ret    

00801d0f <opencons>:

int
opencons(void)
{
  801d0f:	55                   	push   %ebp
  801d10:	89 e5                	mov    %esp,%ebp
  801d12:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d15:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d18:	50                   	push   %eax
  801d19:	e8 73 f3 ff ff       	call   801091 <fd_alloc>
  801d1e:	83 c4 10             	add    $0x10,%esp
		return r;
  801d21:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d23:	85 c0                	test   %eax,%eax
  801d25:	78 3e                	js     801d65 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d27:	83 ec 04             	sub    $0x4,%esp
  801d2a:	68 07 04 00 00       	push   $0x407
  801d2f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d32:	6a 00                	push   $0x0
  801d34:	e8 c6 ed ff ff       	call   800aff <sys_page_alloc>
  801d39:	83 c4 10             	add    $0x10,%esp
		return r;
  801d3c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d3e:	85 c0                	test   %eax,%eax
  801d40:	78 23                	js     801d65 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d42:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d50:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d57:	83 ec 0c             	sub    $0xc,%esp
  801d5a:	50                   	push   %eax
  801d5b:	e8 0a f3 ff ff       	call   80106a <fd2num>
  801d60:	89 c2                	mov    %eax,%edx
  801d62:	83 c4 10             	add    $0x10,%esp
}
  801d65:	89 d0                	mov    %edx,%eax
  801d67:	c9                   	leave  
  801d68:	c3                   	ret    

00801d69 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d69:	55                   	push   %ebp
  801d6a:	89 e5                	mov    %esp,%ebp
  801d6c:	56                   	push   %esi
  801d6d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d6e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d71:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d77:	e8 45 ed ff ff       	call   800ac1 <sys_getenvid>
  801d7c:	83 ec 0c             	sub    $0xc,%esp
  801d7f:	ff 75 0c             	pushl  0xc(%ebp)
  801d82:	ff 75 08             	pushl  0x8(%ebp)
  801d85:	56                   	push   %esi
  801d86:	50                   	push   %eax
  801d87:	68 14 27 80 00       	push   $0x802714
  801d8c:	e8 e6 e3 ff ff       	call   800177 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d91:	83 c4 18             	add    $0x18,%esp
  801d94:	53                   	push   %ebx
  801d95:	ff 75 10             	pushl  0x10(%ebp)
  801d98:	e8 89 e3 ff ff       	call   800126 <vcprintf>
	cprintf("\n");
  801d9d:	c7 04 24 ff 26 80 00 	movl   $0x8026ff,(%esp)
  801da4:	e8 ce e3 ff ff       	call   800177 <cprintf>
  801da9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801dac:	cc                   	int3   
  801dad:	eb fd                	jmp    801dac <_panic+0x43>

00801daf <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801daf:	55                   	push   %ebp
  801db0:	89 e5                	mov    %esp,%ebp
  801db2:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801db5:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801dbc:	75 2a                	jne    801de8 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801dbe:	83 ec 04             	sub    $0x4,%esp
  801dc1:	6a 07                	push   $0x7
  801dc3:	68 00 f0 bf ee       	push   $0xeebff000
  801dc8:	6a 00                	push   $0x0
  801dca:	e8 30 ed ff ff       	call   800aff <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801dcf:	83 c4 10             	add    $0x10,%esp
  801dd2:	85 c0                	test   %eax,%eax
  801dd4:	79 12                	jns    801de8 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801dd6:	50                   	push   %eax
  801dd7:	68 38 27 80 00       	push   $0x802738
  801ddc:	6a 23                	push   $0x23
  801dde:	68 3c 27 80 00       	push   $0x80273c
  801de3:	e8 81 ff ff ff       	call   801d69 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801de8:	8b 45 08             	mov    0x8(%ebp),%eax
  801deb:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801df0:	83 ec 08             	sub    $0x8,%esp
  801df3:	68 1a 1e 80 00       	push   $0x801e1a
  801df8:	6a 00                	push   $0x0
  801dfa:	e8 4b ee ff ff       	call   800c4a <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801dff:	83 c4 10             	add    $0x10,%esp
  801e02:	85 c0                	test   %eax,%eax
  801e04:	79 12                	jns    801e18 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801e06:	50                   	push   %eax
  801e07:	68 38 27 80 00       	push   $0x802738
  801e0c:	6a 2c                	push   $0x2c
  801e0e:	68 3c 27 80 00       	push   $0x80273c
  801e13:	e8 51 ff ff ff       	call   801d69 <_panic>
	}
}
  801e18:	c9                   	leave  
  801e19:	c3                   	ret    

00801e1a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e1a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e1b:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e20:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e22:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801e25:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801e29:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801e2e:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801e32:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801e34:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801e37:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801e38:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801e3b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801e3c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e3d:	c3                   	ret    

00801e3e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e3e:	55                   	push   %ebp
  801e3f:	89 e5                	mov    %esp,%ebp
  801e41:	56                   	push   %esi
  801e42:	53                   	push   %ebx
  801e43:	8b 75 08             	mov    0x8(%ebp),%esi
  801e46:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e49:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e4c:	85 c0                	test   %eax,%eax
  801e4e:	75 12                	jne    801e62 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e50:	83 ec 0c             	sub    $0xc,%esp
  801e53:	68 00 00 c0 ee       	push   $0xeec00000
  801e58:	e8 52 ee ff ff       	call   800caf <sys_ipc_recv>
  801e5d:	83 c4 10             	add    $0x10,%esp
  801e60:	eb 0c                	jmp    801e6e <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e62:	83 ec 0c             	sub    $0xc,%esp
  801e65:	50                   	push   %eax
  801e66:	e8 44 ee ff ff       	call   800caf <sys_ipc_recv>
  801e6b:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e6e:	85 f6                	test   %esi,%esi
  801e70:	0f 95 c1             	setne  %cl
  801e73:	85 db                	test   %ebx,%ebx
  801e75:	0f 95 c2             	setne  %dl
  801e78:	84 d1                	test   %dl,%cl
  801e7a:	74 09                	je     801e85 <ipc_recv+0x47>
  801e7c:	89 c2                	mov    %eax,%edx
  801e7e:	c1 ea 1f             	shr    $0x1f,%edx
  801e81:	84 d2                	test   %dl,%dl
  801e83:	75 2d                	jne    801eb2 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e85:	85 f6                	test   %esi,%esi
  801e87:	74 0d                	je     801e96 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e89:	a1 04 40 80 00       	mov    0x804004,%eax
  801e8e:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  801e94:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e96:	85 db                	test   %ebx,%ebx
  801e98:	74 0d                	je     801ea7 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e9a:	a1 04 40 80 00       	mov    0x804004,%eax
  801e9f:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  801ea5:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ea7:	a1 04 40 80 00       	mov    0x804004,%eax
  801eac:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  801eb2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eb5:	5b                   	pop    %ebx
  801eb6:	5e                   	pop    %esi
  801eb7:	5d                   	pop    %ebp
  801eb8:	c3                   	ret    

00801eb9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801eb9:	55                   	push   %ebp
  801eba:	89 e5                	mov    %esp,%ebp
  801ebc:	57                   	push   %edi
  801ebd:	56                   	push   %esi
  801ebe:	53                   	push   %ebx
  801ebf:	83 ec 0c             	sub    $0xc,%esp
  801ec2:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ec5:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ec8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801ecb:	85 db                	test   %ebx,%ebx
  801ecd:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ed2:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801ed5:	ff 75 14             	pushl  0x14(%ebp)
  801ed8:	53                   	push   %ebx
  801ed9:	56                   	push   %esi
  801eda:	57                   	push   %edi
  801edb:	e8 ac ed ff ff       	call   800c8c <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801ee0:	89 c2                	mov    %eax,%edx
  801ee2:	c1 ea 1f             	shr    $0x1f,%edx
  801ee5:	83 c4 10             	add    $0x10,%esp
  801ee8:	84 d2                	test   %dl,%dl
  801eea:	74 17                	je     801f03 <ipc_send+0x4a>
  801eec:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801eef:	74 12                	je     801f03 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801ef1:	50                   	push   %eax
  801ef2:	68 4a 27 80 00       	push   $0x80274a
  801ef7:	6a 47                	push   $0x47
  801ef9:	68 58 27 80 00       	push   $0x802758
  801efe:	e8 66 fe ff ff       	call   801d69 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801f03:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f06:	75 07                	jne    801f0f <ipc_send+0x56>
			sys_yield();
  801f08:	e8 d3 eb ff ff       	call   800ae0 <sys_yield>
  801f0d:	eb c6                	jmp    801ed5 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801f0f:	85 c0                	test   %eax,%eax
  801f11:	75 c2                	jne    801ed5 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801f13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f16:	5b                   	pop    %ebx
  801f17:	5e                   	pop    %esi
  801f18:	5f                   	pop    %edi
  801f19:	5d                   	pop    %ebp
  801f1a:	c3                   	ret    

00801f1b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f1b:	55                   	push   %ebp
  801f1c:	89 e5                	mov    %esp,%ebp
  801f1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f21:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f26:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  801f2c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f32:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  801f38:	39 ca                	cmp    %ecx,%edx
  801f3a:	75 13                	jne    801f4f <ipc_find_env+0x34>
			return envs[i].env_id;
  801f3c:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  801f42:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f47:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801f4d:	eb 0f                	jmp    801f5e <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f4f:	83 c0 01             	add    $0x1,%eax
  801f52:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f57:	75 cd                	jne    801f26 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f59:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f5e:	5d                   	pop    %ebp
  801f5f:	c3                   	ret    

00801f60 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f60:	55                   	push   %ebp
  801f61:	89 e5                	mov    %esp,%ebp
  801f63:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f66:	89 d0                	mov    %edx,%eax
  801f68:	c1 e8 16             	shr    $0x16,%eax
  801f6b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f72:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f77:	f6 c1 01             	test   $0x1,%cl
  801f7a:	74 1d                	je     801f99 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f7c:	c1 ea 0c             	shr    $0xc,%edx
  801f7f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f86:	f6 c2 01             	test   $0x1,%dl
  801f89:	74 0e                	je     801f99 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f8b:	c1 ea 0c             	shr    $0xc,%edx
  801f8e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f95:	ef 
  801f96:	0f b7 c0             	movzwl %ax,%eax
}
  801f99:	5d                   	pop    %ebp
  801f9a:	c3                   	ret    
  801f9b:	66 90                	xchg   %ax,%ax
  801f9d:	66 90                	xchg   %ax,%ax
  801f9f:	90                   	nop

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
