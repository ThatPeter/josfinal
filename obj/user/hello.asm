
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
  80003e:	e8 31 01 00 00       	call   800174 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 40 80 00       	mov    0x804004,%eax
  800048:	8b 40 7c             	mov    0x7c(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 ee 21 80 00       	push   $0x8021ee
  800054:	e8 1b 01 00 00       	call   800174 <cprintf>
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
  800069:	e8 50 0a 00 00       	call   800abe <sys_getenvid>
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  800079:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007e:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800083:	85 db                	test   %ebx,%ebx
  800085:	7e 07                	jle    80008e <libmain+0x30>
		binaryname = argv[0];
  800087:	8b 06                	mov    (%esi),%eax
  800089:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80008e:	83 ec 08             	sub    $0x8,%esp
  800091:	56                   	push   %esi
  800092:	53                   	push   %ebx
  800093:	e8 9b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800098:	e8 2a 00 00 00       	call   8000c7 <exit>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a3:	5b                   	pop    %ebx
  8000a4:	5e                   	pop    %esi
  8000a5:	5d                   	pop    %ebp
  8000a6:	c3                   	ret    

008000a7 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  8000ad:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  8000b2:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8000b4:	e8 05 0a 00 00       	call   800abe <sys_getenvid>
  8000b9:	83 ec 0c             	sub    $0xc,%esp
  8000bc:	50                   	push   %eax
  8000bd:	e8 4b 0c 00 00       	call   800d0d <sys_thread_free>
}
  8000c2:	83 c4 10             	add    $0x10,%esp
  8000c5:	c9                   	leave  
  8000c6:	c3                   	ret    

008000c7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c7:	55                   	push   %ebp
  8000c8:	89 e5                	mov    %esp,%ebp
  8000ca:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000cd:	e8 1a 11 00 00       	call   8011ec <close_all>
	sys_env_destroy(0);
  8000d2:	83 ec 0c             	sub    $0xc,%esp
  8000d5:	6a 00                	push   $0x0
  8000d7:	e8 a1 09 00 00       	call   800a7d <sys_env_destroy>
}
  8000dc:	83 c4 10             	add    $0x10,%esp
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    

008000e1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 04             	sub    $0x4,%esp
  8000e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000eb:	8b 13                	mov    (%ebx),%edx
  8000ed:	8d 42 01             	lea    0x1(%edx),%eax
  8000f0:	89 03                	mov    %eax,(%ebx)
  8000f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000f9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000fe:	75 1a                	jne    80011a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800100:	83 ec 08             	sub    $0x8,%esp
  800103:	68 ff 00 00 00       	push   $0xff
  800108:	8d 43 08             	lea    0x8(%ebx),%eax
  80010b:	50                   	push   %eax
  80010c:	e8 2f 09 00 00       	call   800a40 <sys_cputs>
		b->idx = 0;
  800111:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800117:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80011a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80011e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800121:	c9                   	leave  
  800122:	c3                   	ret    

00800123 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800123:	55                   	push   %ebp
  800124:	89 e5                	mov    %esp,%ebp
  800126:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80012c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800133:	00 00 00 
	b.cnt = 0;
  800136:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800140:	ff 75 0c             	pushl  0xc(%ebp)
  800143:	ff 75 08             	pushl  0x8(%ebp)
  800146:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014c:	50                   	push   %eax
  80014d:	68 e1 00 80 00       	push   $0x8000e1
  800152:	e8 54 01 00 00       	call   8002ab <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800157:	83 c4 08             	add    $0x8,%esp
  80015a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800160:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800166:	50                   	push   %eax
  800167:	e8 d4 08 00 00       	call   800a40 <sys_cputs>

	return b.cnt;
}
  80016c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800172:	c9                   	leave  
  800173:	c3                   	ret    

00800174 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80017a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80017d:	50                   	push   %eax
  80017e:	ff 75 08             	pushl  0x8(%ebp)
  800181:	e8 9d ff ff ff       	call   800123 <vcprintf>
	va_end(ap);

	return cnt;
}
  800186:	c9                   	leave  
  800187:	c3                   	ret    

00800188 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	57                   	push   %edi
  80018c:	56                   	push   %esi
  80018d:	53                   	push   %ebx
  80018e:	83 ec 1c             	sub    $0x1c,%esp
  800191:	89 c7                	mov    %eax,%edi
  800193:	89 d6                	mov    %edx,%esi
  800195:	8b 45 08             	mov    0x8(%ebp),%eax
  800198:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80019e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001a4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ac:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001af:	39 d3                	cmp    %edx,%ebx
  8001b1:	72 05                	jb     8001b8 <printnum+0x30>
  8001b3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b6:	77 45                	ja     8001fd <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b8:	83 ec 0c             	sub    $0xc,%esp
  8001bb:	ff 75 18             	pushl  0x18(%ebp)
  8001be:	8b 45 14             	mov    0x14(%ebp),%eax
  8001c1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001c4:	53                   	push   %ebx
  8001c5:	ff 75 10             	pushl  0x10(%ebp)
  8001c8:	83 ec 08             	sub    $0x8,%esp
  8001cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ce:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001d7:	e8 74 1d 00 00       	call   801f50 <__udivdi3>
  8001dc:	83 c4 18             	add    $0x18,%esp
  8001df:	52                   	push   %edx
  8001e0:	50                   	push   %eax
  8001e1:	89 f2                	mov    %esi,%edx
  8001e3:	89 f8                	mov    %edi,%eax
  8001e5:	e8 9e ff ff ff       	call   800188 <printnum>
  8001ea:	83 c4 20             	add    $0x20,%esp
  8001ed:	eb 18                	jmp    800207 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ef:	83 ec 08             	sub    $0x8,%esp
  8001f2:	56                   	push   %esi
  8001f3:	ff 75 18             	pushl  0x18(%ebp)
  8001f6:	ff d7                	call   *%edi
  8001f8:	83 c4 10             	add    $0x10,%esp
  8001fb:	eb 03                	jmp    800200 <printnum+0x78>
  8001fd:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800200:	83 eb 01             	sub    $0x1,%ebx
  800203:	85 db                	test   %ebx,%ebx
  800205:	7f e8                	jg     8001ef <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800207:	83 ec 08             	sub    $0x8,%esp
  80020a:	56                   	push   %esi
  80020b:	83 ec 04             	sub    $0x4,%esp
  80020e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800211:	ff 75 e0             	pushl  -0x20(%ebp)
  800214:	ff 75 dc             	pushl  -0x24(%ebp)
  800217:	ff 75 d8             	pushl  -0x28(%ebp)
  80021a:	e8 61 1e 00 00       	call   802080 <__umoddi3>
  80021f:	83 c4 14             	add    $0x14,%esp
  800222:	0f be 80 0f 22 80 00 	movsbl 0x80220f(%eax),%eax
  800229:	50                   	push   %eax
  80022a:	ff d7                	call   *%edi
}
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800232:	5b                   	pop    %ebx
  800233:	5e                   	pop    %esi
  800234:	5f                   	pop    %edi
  800235:	5d                   	pop    %ebp
  800236:	c3                   	ret    

00800237 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80023a:	83 fa 01             	cmp    $0x1,%edx
  80023d:	7e 0e                	jle    80024d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80023f:	8b 10                	mov    (%eax),%edx
  800241:	8d 4a 08             	lea    0x8(%edx),%ecx
  800244:	89 08                	mov    %ecx,(%eax)
  800246:	8b 02                	mov    (%edx),%eax
  800248:	8b 52 04             	mov    0x4(%edx),%edx
  80024b:	eb 22                	jmp    80026f <getuint+0x38>
	else if (lflag)
  80024d:	85 d2                	test   %edx,%edx
  80024f:	74 10                	je     800261 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800251:	8b 10                	mov    (%eax),%edx
  800253:	8d 4a 04             	lea    0x4(%edx),%ecx
  800256:	89 08                	mov    %ecx,(%eax)
  800258:	8b 02                	mov    (%edx),%eax
  80025a:	ba 00 00 00 00       	mov    $0x0,%edx
  80025f:	eb 0e                	jmp    80026f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800261:	8b 10                	mov    (%eax),%edx
  800263:	8d 4a 04             	lea    0x4(%edx),%ecx
  800266:	89 08                	mov    %ecx,(%eax)
  800268:	8b 02                	mov    (%edx),%eax
  80026a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80026f:	5d                   	pop    %ebp
  800270:	c3                   	ret    

00800271 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800277:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80027b:	8b 10                	mov    (%eax),%edx
  80027d:	3b 50 04             	cmp    0x4(%eax),%edx
  800280:	73 0a                	jae    80028c <sprintputch+0x1b>
		*b->buf++ = ch;
  800282:	8d 4a 01             	lea    0x1(%edx),%ecx
  800285:	89 08                	mov    %ecx,(%eax)
  800287:	8b 45 08             	mov    0x8(%ebp),%eax
  80028a:	88 02                	mov    %al,(%edx)
}
  80028c:	5d                   	pop    %ebp
  80028d:	c3                   	ret    

0080028e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80028e:	55                   	push   %ebp
  80028f:	89 e5                	mov    %esp,%ebp
  800291:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800294:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800297:	50                   	push   %eax
  800298:	ff 75 10             	pushl  0x10(%ebp)
  80029b:	ff 75 0c             	pushl  0xc(%ebp)
  80029e:	ff 75 08             	pushl  0x8(%ebp)
  8002a1:	e8 05 00 00 00       	call   8002ab <vprintfmt>
	va_end(ap);
}
  8002a6:	83 c4 10             	add    $0x10,%esp
  8002a9:	c9                   	leave  
  8002aa:	c3                   	ret    

008002ab <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ab:	55                   	push   %ebp
  8002ac:	89 e5                	mov    %esp,%ebp
  8002ae:	57                   	push   %edi
  8002af:	56                   	push   %esi
  8002b0:	53                   	push   %ebx
  8002b1:	83 ec 2c             	sub    $0x2c,%esp
  8002b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ba:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002bd:	eb 12                	jmp    8002d1 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002bf:	85 c0                	test   %eax,%eax
  8002c1:	0f 84 89 03 00 00    	je     800650 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002c7:	83 ec 08             	sub    $0x8,%esp
  8002ca:	53                   	push   %ebx
  8002cb:	50                   	push   %eax
  8002cc:	ff d6                	call   *%esi
  8002ce:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002d1:	83 c7 01             	add    $0x1,%edi
  8002d4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002d8:	83 f8 25             	cmp    $0x25,%eax
  8002db:	75 e2                	jne    8002bf <vprintfmt+0x14>
  8002dd:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002e1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002e8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002ef:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fb:	eb 07                	jmp    800304 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800300:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800304:	8d 47 01             	lea    0x1(%edi),%eax
  800307:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80030a:	0f b6 07             	movzbl (%edi),%eax
  80030d:	0f b6 c8             	movzbl %al,%ecx
  800310:	83 e8 23             	sub    $0x23,%eax
  800313:	3c 55                	cmp    $0x55,%al
  800315:	0f 87 1a 03 00 00    	ja     800635 <vprintfmt+0x38a>
  80031b:	0f b6 c0             	movzbl %al,%eax
  80031e:	ff 24 85 60 23 80 00 	jmp    *0x802360(,%eax,4)
  800325:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800328:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80032c:	eb d6                	jmp    800304 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800331:	b8 00 00 00 00       	mov    $0x0,%eax
  800336:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800339:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80033c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800340:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800343:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800346:	83 fa 09             	cmp    $0x9,%edx
  800349:	77 39                	ja     800384 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80034b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80034e:	eb e9                	jmp    800339 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800350:	8b 45 14             	mov    0x14(%ebp),%eax
  800353:	8d 48 04             	lea    0x4(%eax),%ecx
  800356:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800359:	8b 00                	mov    (%eax),%eax
  80035b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800361:	eb 27                	jmp    80038a <vprintfmt+0xdf>
  800363:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800366:	85 c0                	test   %eax,%eax
  800368:	b9 00 00 00 00       	mov    $0x0,%ecx
  80036d:	0f 49 c8             	cmovns %eax,%ecx
  800370:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800373:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800376:	eb 8c                	jmp    800304 <vprintfmt+0x59>
  800378:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80037b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800382:	eb 80                	jmp    800304 <vprintfmt+0x59>
  800384:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800387:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80038a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80038e:	0f 89 70 ff ff ff    	jns    800304 <vprintfmt+0x59>
				width = precision, precision = -1;
  800394:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800397:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80039a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a1:	e9 5e ff ff ff       	jmp    800304 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003a6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ac:	e9 53 ff ff ff       	jmp    800304 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b4:	8d 50 04             	lea    0x4(%eax),%edx
  8003b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ba:	83 ec 08             	sub    $0x8,%esp
  8003bd:	53                   	push   %ebx
  8003be:	ff 30                	pushl  (%eax)
  8003c0:	ff d6                	call   *%esi
			break;
  8003c2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003c8:	e9 04 ff ff ff       	jmp    8002d1 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d0:	8d 50 04             	lea    0x4(%eax),%edx
  8003d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d6:	8b 00                	mov    (%eax),%eax
  8003d8:	99                   	cltd   
  8003d9:	31 d0                	xor    %edx,%eax
  8003db:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003dd:	83 f8 0f             	cmp    $0xf,%eax
  8003e0:	7f 0b                	jg     8003ed <vprintfmt+0x142>
  8003e2:	8b 14 85 c0 24 80 00 	mov    0x8024c0(,%eax,4),%edx
  8003e9:	85 d2                	test   %edx,%edx
  8003eb:	75 18                	jne    800405 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003ed:	50                   	push   %eax
  8003ee:	68 27 22 80 00       	push   $0x802227
  8003f3:	53                   	push   %ebx
  8003f4:	56                   	push   %esi
  8003f5:	e8 94 fe ff ff       	call   80028e <printfmt>
  8003fa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800400:	e9 cc fe ff ff       	jmp    8002d1 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800405:	52                   	push   %edx
  800406:	68 6d 26 80 00       	push   $0x80266d
  80040b:	53                   	push   %ebx
  80040c:	56                   	push   %esi
  80040d:	e8 7c fe ff ff       	call   80028e <printfmt>
  800412:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800415:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800418:	e9 b4 fe ff ff       	jmp    8002d1 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80041d:	8b 45 14             	mov    0x14(%ebp),%eax
  800420:	8d 50 04             	lea    0x4(%eax),%edx
  800423:	89 55 14             	mov    %edx,0x14(%ebp)
  800426:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800428:	85 ff                	test   %edi,%edi
  80042a:	b8 20 22 80 00       	mov    $0x802220,%eax
  80042f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800432:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800436:	0f 8e 94 00 00 00    	jle    8004d0 <vprintfmt+0x225>
  80043c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800440:	0f 84 98 00 00 00    	je     8004de <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800446:	83 ec 08             	sub    $0x8,%esp
  800449:	ff 75 d0             	pushl  -0x30(%ebp)
  80044c:	57                   	push   %edi
  80044d:	e8 86 02 00 00       	call   8006d8 <strnlen>
  800452:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800455:	29 c1                	sub    %eax,%ecx
  800457:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80045a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80045d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800461:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800464:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800467:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800469:	eb 0f                	jmp    80047a <vprintfmt+0x1cf>
					putch(padc, putdat);
  80046b:	83 ec 08             	sub    $0x8,%esp
  80046e:	53                   	push   %ebx
  80046f:	ff 75 e0             	pushl  -0x20(%ebp)
  800472:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800474:	83 ef 01             	sub    $0x1,%edi
  800477:	83 c4 10             	add    $0x10,%esp
  80047a:	85 ff                	test   %edi,%edi
  80047c:	7f ed                	jg     80046b <vprintfmt+0x1c0>
  80047e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800481:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800484:	85 c9                	test   %ecx,%ecx
  800486:	b8 00 00 00 00       	mov    $0x0,%eax
  80048b:	0f 49 c1             	cmovns %ecx,%eax
  80048e:	29 c1                	sub    %eax,%ecx
  800490:	89 75 08             	mov    %esi,0x8(%ebp)
  800493:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800496:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800499:	89 cb                	mov    %ecx,%ebx
  80049b:	eb 4d                	jmp    8004ea <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80049d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004a1:	74 1b                	je     8004be <vprintfmt+0x213>
  8004a3:	0f be c0             	movsbl %al,%eax
  8004a6:	83 e8 20             	sub    $0x20,%eax
  8004a9:	83 f8 5e             	cmp    $0x5e,%eax
  8004ac:	76 10                	jbe    8004be <vprintfmt+0x213>
					putch('?', putdat);
  8004ae:	83 ec 08             	sub    $0x8,%esp
  8004b1:	ff 75 0c             	pushl  0xc(%ebp)
  8004b4:	6a 3f                	push   $0x3f
  8004b6:	ff 55 08             	call   *0x8(%ebp)
  8004b9:	83 c4 10             	add    $0x10,%esp
  8004bc:	eb 0d                	jmp    8004cb <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004be:	83 ec 08             	sub    $0x8,%esp
  8004c1:	ff 75 0c             	pushl  0xc(%ebp)
  8004c4:	52                   	push   %edx
  8004c5:	ff 55 08             	call   *0x8(%ebp)
  8004c8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004cb:	83 eb 01             	sub    $0x1,%ebx
  8004ce:	eb 1a                	jmp    8004ea <vprintfmt+0x23f>
  8004d0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004dc:	eb 0c                	jmp    8004ea <vprintfmt+0x23f>
  8004de:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ea:	83 c7 01             	add    $0x1,%edi
  8004ed:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f1:	0f be d0             	movsbl %al,%edx
  8004f4:	85 d2                	test   %edx,%edx
  8004f6:	74 23                	je     80051b <vprintfmt+0x270>
  8004f8:	85 f6                	test   %esi,%esi
  8004fa:	78 a1                	js     80049d <vprintfmt+0x1f2>
  8004fc:	83 ee 01             	sub    $0x1,%esi
  8004ff:	79 9c                	jns    80049d <vprintfmt+0x1f2>
  800501:	89 df                	mov    %ebx,%edi
  800503:	8b 75 08             	mov    0x8(%ebp),%esi
  800506:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800509:	eb 18                	jmp    800523 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80050b:	83 ec 08             	sub    $0x8,%esp
  80050e:	53                   	push   %ebx
  80050f:	6a 20                	push   $0x20
  800511:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800513:	83 ef 01             	sub    $0x1,%edi
  800516:	83 c4 10             	add    $0x10,%esp
  800519:	eb 08                	jmp    800523 <vprintfmt+0x278>
  80051b:	89 df                	mov    %ebx,%edi
  80051d:	8b 75 08             	mov    0x8(%ebp),%esi
  800520:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800523:	85 ff                	test   %edi,%edi
  800525:	7f e4                	jg     80050b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800527:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80052a:	e9 a2 fd ff ff       	jmp    8002d1 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80052f:	83 fa 01             	cmp    $0x1,%edx
  800532:	7e 16                	jle    80054a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800534:	8b 45 14             	mov    0x14(%ebp),%eax
  800537:	8d 50 08             	lea    0x8(%eax),%edx
  80053a:	89 55 14             	mov    %edx,0x14(%ebp)
  80053d:	8b 50 04             	mov    0x4(%eax),%edx
  800540:	8b 00                	mov    (%eax),%eax
  800542:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800545:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800548:	eb 32                	jmp    80057c <vprintfmt+0x2d1>
	else if (lflag)
  80054a:	85 d2                	test   %edx,%edx
  80054c:	74 18                	je     800566 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80054e:	8b 45 14             	mov    0x14(%ebp),%eax
  800551:	8d 50 04             	lea    0x4(%eax),%edx
  800554:	89 55 14             	mov    %edx,0x14(%ebp)
  800557:	8b 00                	mov    (%eax),%eax
  800559:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055c:	89 c1                	mov    %eax,%ecx
  80055e:	c1 f9 1f             	sar    $0x1f,%ecx
  800561:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800564:	eb 16                	jmp    80057c <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800566:	8b 45 14             	mov    0x14(%ebp),%eax
  800569:	8d 50 04             	lea    0x4(%eax),%edx
  80056c:	89 55 14             	mov    %edx,0x14(%ebp)
  80056f:	8b 00                	mov    (%eax),%eax
  800571:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800574:	89 c1                	mov    %eax,%ecx
  800576:	c1 f9 1f             	sar    $0x1f,%ecx
  800579:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80057c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80057f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800582:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800587:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80058b:	79 74                	jns    800601 <vprintfmt+0x356>
				putch('-', putdat);
  80058d:	83 ec 08             	sub    $0x8,%esp
  800590:	53                   	push   %ebx
  800591:	6a 2d                	push   $0x2d
  800593:	ff d6                	call   *%esi
				num = -(long long) num;
  800595:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800598:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80059b:	f7 d8                	neg    %eax
  80059d:	83 d2 00             	adc    $0x0,%edx
  8005a0:	f7 da                	neg    %edx
  8005a2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005a5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005aa:	eb 55                	jmp    800601 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ac:	8d 45 14             	lea    0x14(%ebp),%eax
  8005af:	e8 83 fc ff ff       	call   800237 <getuint>
			base = 10;
  8005b4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005b9:	eb 46                	jmp    800601 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005be:	e8 74 fc ff ff       	call   800237 <getuint>
			base = 8;
  8005c3:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005c8:	eb 37                	jmp    800601 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005ca:	83 ec 08             	sub    $0x8,%esp
  8005cd:	53                   	push   %ebx
  8005ce:	6a 30                	push   $0x30
  8005d0:	ff d6                	call   *%esi
			putch('x', putdat);
  8005d2:	83 c4 08             	add    $0x8,%esp
  8005d5:	53                   	push   %ebx
  8005d6:	6a 78                	push   $0x78
  8005d8:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005da:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dd:	8d 50 04             	lea    0x4(%eax),%edx
  8005e0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005e3:	8b 00                	mov    (%eax),%eax
  8005e5:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005ea:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005ed:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005f2:	eb 0d                	jmp    800601 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005f4:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f7:	e8 3b fc ff ff       	call   800237 <getuint>
			base = 16;
  8005fc:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800601:	83 ec 0c             	sub    $0xc,%esp
  800604:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800608:	57                   	push   %edi
  800609:	ff 75 e0             	pushl  -0x20(%ebp)
  80060c:	51                   	push   %ecx
  80060d:	52                   	push   %edx
  80060e:	50                   	push   %eax
  80060f:	89 da                	mov    %ebx,%edx
  800611:	89 f0                	mov    %esi,%eax
  800613:	e8 70 fb ff ff       	call   800188 <printnum>
			break;
  800618:	83 c4 20             	add    $0x20,%esp
  80061b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80061e:	e9 ae fc ff ff       	jmp    8002d1 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800623:	83 ec 08             	sub    $0x8,%esp
  800626:	53                   	push   %ebx
  800627:	51                   	push   %ecx
  800628:	ff d6                	call   *%esi
			break;
  80062a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800630:	e9 9c fc ff ff       	jmp    8002d1 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800635:	83 ec 08             	sub    $0x8,%esp
  800638:	53                   	push   %ebx
  800639:	6a 25                	push   $0x25
  80063b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80063d:	83 c4 10             	add    $0x10,%esp
  800640:	eb 03                	jmp    800645 <vprintfmt+0x39a>
  800642:	83 ef 01             	sub    $0x1,%edi
  800645:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800649:	75 f7                	jne    800642 <vprintfmt+0x397>
  80064b:	e9 81 fc ff ff       	jmp    8002d1 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800650:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800653:	5b                   	pop    %ebx
  800654:	5e                   	pop    %esi
  800655:	5f                   	pop    %edi
  800656:	5d                   	pop    %ebp
  800657:	c3                   	ret    

00800658 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800658:	55                   	push   %ebp
  800659:	89 e5                	mov    %esp,%ebp
  80065b:	83 ec 18             	sub    $0x18,%esp
  80065e:	8b 45 08             	mov    0x8(%ebp),%eax
  800661:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800664:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800667:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80066b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80066e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800675:	85 c0                	test   %eax,%eax
  800677:	74 26                	je     80069f <vsnprintf+0x47>
  800679:	85 d2                	test   %edx,%edx
  80067b:	7e 22                	jle    80069f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80067d:	ff 75 14             	pushl  0x14(%ebp)
  800680:	ff 75 10             	pushl  0x10(%ebp)
  800683:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800686:	50                   	push   %eax
  800687:	68 71 02 80 00       	push   $0x800271
  80068c:	e8 1a fc ff ff       	call   8002ab <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800691:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800694:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800697:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069a:	83 c4 10             	add    $0x10,%esp
  80069d:	eb 05                	jmp    8006a4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80069f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006a4:	c9                   	leave  
  8006a5:	c3                   	ret    

008006a6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006a6:	55                   	push   %ebp
  8006a7:	89 e5                	mov    %esp,%ebp
  8006a9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ac:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006af:	50                   	push   %eax
  8006b0:	ff 75 10             	pushl  0x10(%ebp)
  8006b3:	ff 75 0c             	pushl  0xc(%ebp)
  8006b6:	ff 75 08             	pushl  0x8(%ebp)
  8006b9:	e8 9a ff ff ff       	call   800658 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006be:	c9                   	leave  
  8006bf:	c3                   	ret    

008006c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006c0:	55                   	push   %ebp
  8006c1:	89 e5                	mov    %esp,%ebp
  8006c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006cb:	eb 03                	jmp    8006d0 <strlen+0x10>
		n++;
  8006cd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006d0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006d4:	75 f7                	jne    8006cd <strlen+0xd>
		n++;
	return n;
}
  8006d6:	5d                   	pop    %ebp
  8006d7:	c3                   	ret    

008006d8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006d8:	55                   	push   %ebp
  8006d9:	89 e5                	mov    %esp,%ebp
  8006db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006de:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8006e6:	eb 03                	jmp    8006eb <strnlen+0x13>
		n++;
  8006e8:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006eb:	39 c2                	cmp    %eax,%edx
  8006ed:	74 08                	je     8006f7 <strnlen+0x1f>
  8006ef:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006f3:	75 f3                	jne    8006e8 <strnlen+0x10>
  8006f5:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006f7:	5d                   	pop    %ebp
  8006f8:	c3                   	ret    

008006f9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006f9:	55                   	push   %ebp
  8006fa:	89 e5                	mov    %esp,%ebp
  8006fc:	53                   	push   %ebx
  8006fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800700:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800703:	89 c2                	mov    %eax,%edx
  800705:	83 c2 01             	add    $0x1,%edx
  800708:	83 c1 01             	add    $0x1,%ecx
  80070b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80070f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800712:	84 db                	test   %bl,%bl
  800714:	75 ef                	jne    800705 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800716:	5b                   	pop    %ebx
  800717:	5d                   	pop    %ebp
  800718:	c3                   	ret    

00800719 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800719:	55                   	push   %ebp
  80071a:	89 e5                	mov    %esp,%ebp
  80071c:	53                   	push   %ebx
  80071d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800720:	53                   	push   %ebx
  800721:	e8 9a ff ff ff       	call   8006c0 <strlen>
  800726:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800729:	ff 75 0c             	pushl  0xc(%ebp)
  80072c:	01 d8                	add    %ebx,%eax
  80072e:	50                   	push   %eax
  80072f:	e8 c5 ff ff ff       	call   8006f9 <strcpy>
	return dst;
}
  800734:	89 d8                	mov    %ebx,%eax
  800736:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800739:	c9                   	leave  
  80073a:	c3                   	ret    

0080073b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	56                   	push   %esi
  80073f:	53                   	push   %ebx
  800740:	8b 75 08             	mov    0x8(%ebp),%esi
  800743:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800746:	89 f3                	mov    %esi,%ebx
  800748:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80074b:	89 f2                	mov    %esi,%edx
  80074d:	eb 0f                	jmp    80075e <strncpy+0x23>
		*dst++ = *src;
  80074f:	83 c2 01             	add    $0x1,%edx
  800752:	0f b6 01             	movzbl (%ecx),%eax
  800755:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800758:	80 39 01             	cmpb   $0x1,(%ecx)
  80075b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80075e:	39 da                	cmp    %ebx,%edx
  800760:	75 ed                	jne    80074f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800762:	89 f0                	mov    %esi,%eax
  800764:	5b                   	pop    %ebx
  800765:	5e                   	pop    %esi
  800766:	5d                   	pop    %ebp
  800767:	c3                   	ret    

00800768 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
  80076b:	56                   	push   %esi
  80076c:	53                   	push   %ebx
  80076d:	8b 75 08             	mov    0x8(%ebp),%esi
  800770:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800773:	8b 55 10             	mov    0x10(%ebp),%edx
  800776:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800778:	85 d2                	test   %edx,%edx
  80077a:	74 21                	je     80079d <strlcpy+0x35>
  80077c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800780:	89 f2                	mov    %esi,%edx
  800782:	eb 09                	jmp    80078d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800784:	83 c2 01             	add    $0x1,%edx
  800787:	83 c1 01             	add    $0x1,%ecx
  80078a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80078d:	39 c2                	cmp    %eax,%edx
  80078f:	74 09                	je     80079a <strlcpy+0x32>
  800791:	0f b6 19             	movzbl (%ecx),%ebx
  800794:	84 db                	test   %bl,%bl
  800796:	75 ec                	jne    800784 <strlcpy+0x1c>
  800798:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80079a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80079d:	29 f0                	sub    %esi,%eax
}
  80079f:	5b                   	pop    %ebx
  8007a0:	5e                   	pop    %esi
  8007a1:	5d                   	pop    %ebp
  8007a2:	c3                   	ret    

008007a3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007a3:	55                   	push   %ebp
  8007a4:	89 e5                	mov    %esp,%ebp
  8007a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ac:	eb 06                	jmp    8007b4 <strcmp+0x11>
		p++, q++;
  8007ae:	83 c1 01             	add    $0x1,%ecx
  8007b1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007b4:	0f b6 01             	movzbl (%ecx),%eax
  8007b7:	84 c0                	test   %al,%al
  8007b9:	74 04                	je     8007bf <strcmp+0x1c>
  8007bb:	3a 02                	cmp    (%edx),%al
  8007bd:	74 ef                	je     8007ae <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007bf:	0f b6 c0             	movzbl %al,%eax
  8007c2:	0f b6 12             	movzbl (%edx),%edx
  8007c5:	29 d0                	sub    %edx,%eax
}
  8007c7:	5d                   	pop    %ebp
  8007c8:	c3                   	ret    

008007c9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	53                   	push   %ebx
  8007cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d3:	89 c3                	mov    %eax,%ebx
  8007d5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007d8:	eb 06                	jmp    8007e0 <strncmp+0x17>
		n--, p++, q++;
  8007da:	83 c0 01             	add    $0x1,%eax
  8007dd:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007e0:	39 d8                	cmp    %ebx,%eax
  8007e2:	74 15                	je     8007f9 <strncmp+0x30>
  8007e4:	0f b6 08             	movzbl (%eax),%ecx
  8007e7:	84 c9                	test   %cl,%cl
  8007e9:	74 04                	je     8007ef <strncmp+0x26>
  8007eb:	3a 0a                	cmp    (%edx),%cl
  8007ed:	74 eb                	je     8007da <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ef:	0f b6 00             	movzbl (%eax),%eax
  8007f2:	0f b6 12             	movzbl (%edx),%edx
  8007f5:	29 d0                	sub    %edx,%eax
  8007f7:	eb 05                	jmp    8007fe <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007f9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007fe:	5b                   	pop    %ebx
  8007ff:	5d                   	pop    %ebp
  800800:	c3                   	ret    

00800801 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	8b 45 08             	mov    0x8(%ebp),%eax
  800807:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80080b:	eb 07                	jmp    800814 <strchr+0x13>
		if (*s == c)
  80080d:	38 ca                	cmp    %cl,%dl
  80080f:	74 0f                	je     800820 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800811:	83 c0 01             	add    $0x1,%eax
  800814:	0f b6 10             	movzbl (%eax),%edx
  800817:	84 d2                	test   %dl,%dl
  800819:	75 f2                	jne    80080d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80081b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800820:	5d                   	pop    %ebp
  800821:	c3                   	ret    

00800822 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	8b 45 08             	mov    0x8(%ebp),%eax
  800828:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80082c:	eb 03                	jmp    800831 <strfind+0xf>
  80082e:	83 c0 01             	add    $0x1,%eax
  800831:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800834:	38 ca                	cmp    %cl,%dl
  800836:	74 04                	je     80083c <strfind+0x1a>
  800838:	84 d2                	test   %dl,%dl
  80083a:	75 f2                	jne    80082e <strfind+0xc>
			break;
	return (char *) s;
}
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	57                   	push   %edi
  800842:	56                   	push   %esi
  800843:	53                   	push   %ebx
  800844:	8b 7d 08             	mov    0x8(%ebp),%edi
  800847:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80084a:	85 c9                	test   %ecx,%ecx
  80084c:	74 36                	je     800884 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80084e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800854:	75 28                	jne    80087e <memset+0x40>
  800856:	f6 c1 03             	test   $0x3,%cl
  800859:	75 23                	jne    80087e <memset+0x40>
		c &= 0xFF;
  80085b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80085f:	89 d3                	mov    %edx,%ebx
  800861:	c1 e3 08             	shl    $0x8,%ebx
  800864:	89 d6                	mov    %edx,%esi
  800866:	c1 e6 18             	shl    $0x18,%esi
  800869:	89 d0                	mov    %edx,%eax
  80086b:	c1 e0 10             	shl    $0x10,%eax
  80086e:	09 f0                	or     %esi,%eax
  800870:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800872:	89 d8                	mov    %ebx,%eax
  800874:	09 d0                	or     %edx,%eax
  800876:	c1 e9 02             	shr    $0x2,%ecx
  800879:	fc                   	cld    
  80087a:	f3 ab                	rep stos %eax,%es:(%edi)
  80087c:	eb 06                	jmp    800884 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80087e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800881:	fc                   	cld    
  800882:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800884:	89 f8                	mov    %edi,%eax
  800886:	5b                   	pop    %ebx
  800887:	5e                   	pop    %esi
  800888:	5f                   	pop    %edi
  800889:	5d                   	pop    %ebp
  80088a:	c3                   	ret    

0080088b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	57                   	push   %edi
  80088f:	56                   	push   %esi
  800890:	8b 45 08             	mov    0x8(%ebp),%eax
  800893:	8b 75 0c             	mov    0xc(%ebp),%esi
  800896:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800899:	39 c6                	cmp    %eax,%esi
  80089b:	73 35                	jae    8008d2 <memmove+0x47>
  80089d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008a0:	39 d0                	cmp    %edx,%eax
  8008a2:	73 2e                	jae    8008d2 <memmove+0x47>
		s += n;
		d += n;
  8008a4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008a7:	89 d6                	mov    %edx,%esi
  8008a9:	09 fe                	or     %edi,%esi
  8008ab:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008b1:	75 13                	jne    8008c6 <memmove+0x3b>
  8008b3:	f6 c1 03             	test   $0x3,%cl
  8008b6:	75 0e                	jne    8008c6 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008b8:	83 ef 04             	sub    $0x4,%edi
  8008bb:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008be:	c1 e9 02             	shr    $0x2,%ecx
  8008c1:	fd                   	std    
  8008c2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c4:	eb 09                	jmp    8008cf <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008c6:	83 ef 01             	sub    $0x1,%edi
  8008c9:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008cc:	fd                   	std    
  8008cd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008cf:	fc                   	cld    
  8008d0:	eb 1d                	jmp    8008ef <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d2:	89 f2                	mov    %esi,%edx
  8008d4:	09 c2                	or     %eax,%edx
  8008d6:	f6 c2 03             	test   $0x3,%dl
  8008d9:	75 0f                	jne    8008ea <memmove+0x5f>
  8008db:	f6 c1 03             	test   $0x3,%cl
  8008de:	75 0a                	jne    8008ea <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008e0:	c1 e9 02             	shr    $0x2,%ecx
  8008e3:	89 c7                	mov    %eax,%edi
  8008e5:	fc                   	cld    
  8008e6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e8:	eb 05                	jmp    8008ef <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008ea:	89 c7                	mov    %eax,%edi
  8008ec:	fc                   	cld    
  8008ed:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008ef:	5e                   	pop    %esi
  8008f0:	5f                   	pop    %edi
  8008f1:	5d                   	pop    %ebp
  8008f2:	c3                   	ret    

008008f3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008f6:	ff 75 10             	pushl  0x10(%ebp)
  8008f9:	ff 75 0c             	pushl  0xc(%ebp)
  8008fc:	ff 75 08             	pushl  0x8(%ebp)
  8008ff:	e8 87 ff ff ff       	call   80088b <memmove>
}
  800904:	c9                   	leave  
  800905:	c3                   	ret    

00800906 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	56                   	push   %esi
  80090a:	53                   	push   %ebx
  80090b:	8b 45 08             	mov    0x8(%ebp),%eax
  80090e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800911:	89 c6                	mov    %eax,%esi
  800913:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800916:	eb 1a                	jmp    800932 <memcmp+0x2c>
		if (*s1 != *s2)
  800918:	0f b6 08             	movzbl (%eax),%ecx
  80091b:	0f b6 1a             	movzbl (%edx),%ebx
  80091e:	38 d9                	cmp    %bl,%cl
  800920:	74 0a                	je     80092c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800922:	0f b6 c1             	movzbl %cl,%eax
  800925:	0f b6 db             	movzbl %bl,%ebx
  800928:	29 d8                	sub    %ebx,%eax
  80092a:	eb 0f                	jmp    80093b <memcmp+0x35>
		s1++, s2++;
  80092c:	83 c0 01             	add    $0x1,%eax
  80092f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800932:	39 f0                	cmp    %esi,%eax
  800934:	75 e2                	jne    800918 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800936:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093b:	5b                   	pop    %ebx
  80093c:	5e                   	pop    %esi
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	53                   	push   %ebx
  800943:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800946:	89 c1                	mov    %eax,%ecx
  800948:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80094b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80094f:	eb 0a                	jmp    80095b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800951:	0f b6 10             	movzbl (%eax),%edx
  800954:	39 da                	cmp    %ebx,%edx
  800956:	74 07                	je     80095f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800958:	83 c0 01             	add    $0x1,%eax
  80095b:	39 c8                	cmp    %ecx,%eax
  80095d:	72 f2                	jb     800951 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80095f:	5b                   	pop    %ebx
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	57                   	push   %edi
  800966:	56                   	push   %esi
  800967:	53                   	push   %ebx
  800968:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80096b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80096e:	eb 03                	jmp    800973 <strtol+0x11>
		s++;
  800970:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800973:	0f b6 01             	movzbl (%ecx),%eax
  800976:	3c 20                	cmp    $0x20,%al
  800978:	74 f6                	je     800970 <strtol+0xe>
  80097a:	3c 09                	cmp    $0x9,%al
  80097c:	74 f2                	je     800970 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80097e:	3c 2b                	cmp    $0x2b,%al
  800980:	75 0a                	jne    80098c <strtol+0x2a>
		s++;
  800982:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800985:	bf 00 00 00 00       	mov    $0x0,%edi
  80098a:	eb 11                	jmp    80099d <strtol+0x3b>
  80098c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800991:	3c 2d                	cmp    $0x2d,%al
  800993:	75 08                	jne    80099d <strtol+0x3b>
		s++, neg = 1;
  800995:	83 c1 01             	add    $0x1,%ecx
  800998:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80099d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009a3:	75 15                	jne    8009ba <strtol+0x58>
  8009a5:	80 39 30             	cmpb   $0x30,(%ecx)
  8009a8:	75 10                	jne    8009ba <strtol+0x58>
  8009aa:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009ae:	75 7c                	jne    800a2c <strtol+0xca>
		s += 2, base = 16;
  8009b0:	83 c1 02             	add    $0x2,%ecx
  8009b3:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009b8:	eb 16                	jmp    8009d0 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009ba:	85 db                	test   %ebx,%ebx
  8009bc:	75 12                	jne    8009d0 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009be:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009c3:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c6:	75 08                	jne    8009d0 <strtol+0x6e>
		s++, base = 8;
  8009c8:	83 c1 01             	add    $0x1,%ecx
  8009cb:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d5:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009d8:	0f b6 11             	movzbl (%ecx),%edx
  8009db:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009de:	89 f3                	mov    %esi,%ebx
  8009e0:	80 fb 09             	cmp    $0x9,%bl
  8009e3:	77 08                	ja     8009ed <strtol+0x8b>
			dig = *s - '0';
  8009e5:	0f be d2             	movsbl %dl,%edx
  8009e8:	83 ea 30             	sub    $0x30,%edx
  8009eb:	eb 22                	jmp    800a0f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009ed:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009f0:	89 f3                	mov    %esi,%ebx
  8009f2:	80 fb 19             	cmp    $0x19,%bl
  8009f5:	77 08                	ja     8009ff <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009f7:	0f be d2             	movsbl %dl,%edx
  8009fa:	83 ea 57             	sub    $0x57,%edx
  8009fd:	eb 10                	jmp    800a0f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009ff:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a02:	89 f3                	mov    %esi,%ebx
  800a04:	80 fb 19             	cmp    $0x19,%bl
  800a07:	77 16                	ja     800a1f <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a09:	0f be d2             	movsbl %dl,%edx
  800a0c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a0f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a12:	7d 0b                	jge    800a1f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a14:	83 c1 01             	add    $0x1,%ecx
  800a17:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a1b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a1d:	eb b9                	jmp    8009d8 <strtol+0x76>

	if (endptr)
  800a1f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a23:	74 0d                	je     800a32 <strtol+0xd0>
		*endptr = (char *) s;
  800a25:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a28:	89 0e                	mov    %ecx,(%esi)
  800a2a:	eb 06                	jmp    800a32 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a2c:	85 db                	test   %ebx,%ebx
  800a2e:	74 98                	je     8009c8 <strtol+0x66>
  800a30:	eb 9e                	jmp    8009d0 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a32:	89 c2                	mov    %eax,%edx
  800a34:	f7 da                	neg    %edx
  800a36:	85 ff                	test   %edi,%edi
  800a38:	0f 45 c2             	cmovne %edx,%eax
}
  800a3b:	5b                   	pop    %ebx
  800a3c:	5e                   	pop    %esi
  800a3d:	5f                   	pop    %edi
  800a3e:	5d                   	pop    %ebp
  800a3f:	c3                   	ret    

00800a40 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	57                   	push   %edi
  800a44:	56                   	push   %esi
  800a45:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a46:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a51:	89 c3                	mov    %eax,%ebx
  800a53:	89 c7                	mov    %eax,%edi
  800a55:	89 c6                	mov    %eax,%esi
  800a57:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a59:	5b                   	pop    %ebx
  800a5a:	5e                   	pop    %esi
  800a5b:	5f                   	pop    %edi
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	57                   	push   %edi
  800a62:	56                   	push   %esi
  800a63:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a64:	ba 00 00 00 00       	mov    $0x0,%edx
  800a69:	b8 01 00 00 00       	mov    $0x1,%eax
  800a6e:	89 d1                	mov    %edx,%ecx
  800a70:	89 d3                	mov    %edx,%ebx
  800a72:	89 d7                	mov    %edx,%edi
  800a74:	89 d6                	mov    %edx,%esi
  800a76:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a78:	5b                   	pop    %ebx
  800a79:	5e                   	pop    %esi
  800a7a:	5f                   	pop    %edi
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	57                   	push   %edi
  800a81:	56                   	push   %esi
  800a82:	53                   	push   %ebx
  800a83:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a86:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a8b:	b8 03 00 00 00       	mov    $0x3,%eax
  800a90:	8b 55 08             	mov    0x8(%ebp),%edx
  800a93:	89 cb                	mov    %ecx,%ebx
  800a95:	89 cf                	mov    %ecx,%edi
  800a97:	89 ce                	mov    %ecx,%esi
  800a99:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a9b:	85 c0                	test   %eax,%eax
  800a9d:	7e 17                	jle    800ab6 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a9f:	83 ec 0c             	sub    $0xc,%esp
  800aa2:	50                   	push   %eax
  800aa3:	6a 03                	push   $0x3
  800aa5:	68 1f 25 80 00       	push   $0x80251f
  800aaa:	6a 23                	push   $0x23
  800aac:	68 3c 25 80 00       	push   $0x80253c
  800ab1:	e8 5e 12 00 00       	call   801d14 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ab6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ab9:	5b                   	pop    %ebx
  800aba:	5e                   	pop    %esi
  800abb:	5f                   	pop    %edi
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    

00800abe <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	57                   	push   %edi
  800ac2:	56                   	push   %esi
  800ac3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac9:	b8 02 00 00 00       	mov    $0x2,%eax
  800ace:	89 d1                	mov    %edx,%ecx
  800ad0:	89 d3                	mov    %edx,%ebx
  800ad2:	89 d7                	mov    %edx,%edi
  800ad4:	89 d6                	mov    %edx,%esi
  800ad6:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ad8:	5b                   	pop    %ebx
  800ad9:	5e                   	pop    %esi
  800ada:	5f                   	pop    %edi
  800adb:	5d                   	pop    %ebp
  800adc:	c3                   	ret    

00800add <sys_yield>:

void
sys_yield(void)
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
  800ae3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800aed:	89 d1                	mov    %edx,%ecx
  800aef:	89 d3                	mov    %edx,%ebx
  800af1:	89 d7                	mov    %edx,%edi
  800af3:	89 d6                	mov    %edx,%esi
  800af5:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800af7:	5b                   	pop    %ebx
  800af8:	5e                   	pop    %esi
  800af9:	5f                   	pop    %edi
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    

00800afc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	57                   	push   %edi
  800b00:	56                   	push   %esi
  800b01:	53                   	push   %ebx
  800b02:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b05:	be 00 00 00 00       	mov    $0x0,%esi
  800b0a:	b8 04 00 00 00       	mov    $0x4,%eax
  800b0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b12:	8b 55 08             	mov    0x8(%ebp),%edx
  800b15:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b18:	89 f7                	mov    %esi,%edi
  800b1a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b1c:	85 c0                	test   %eax,%eax
  800b1e:	7e 17                	jle    800b37 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b20:	83 ec 0c             	sub    $0xc,%esp
  800b23:	50                   	push   %eax
  800b24:	6a 04                	push   $0x4
  800b26:	68 1f 25 80 00       	push   $0x80251f
  800b2b:	6a 23                	push   $0x23
  800b2d:	68 3c 25 80 00       	push   $0x80253c
  800b32:	e8 dd 11 00 00       	call   801d14 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5f                   	pop    %edi
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	57                   	push   %edi
  800b43:	56                   	push   %esi
  800b44:	53                   	push   %ebx
  800b45:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b48:	b8 05 00 00 00       	mov    $0x5,%eax
  800b4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b50:	8b 55 08             	mov    0x8(%ebp),%edx
  800b53:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b56:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b59:	8b 75 18             	mov    0x18(%ebp),%esi
  800b5c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b5e:	85 c0                	test   %eax,%eax
  800b60:	7e 17                	jle    800b79 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b62:	83 ec 0c             	sub    $0xc,%esp
  800b65:	50                   	push   %eax
  800b66:	6a 05                	push   $0x5
  800b68:	68 1f 25 80 00       	push   $0x80251f
  800b6d:	6a 23                	push   $0x23
  800b6f:	68 3c 25 80 00       	push   $0x80253c
  800b74:	e8 9b 11 00 00       	call   801d14 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7c:	5b                   	pop    %ebx
  800b7d:	5e                   	pop    %esi
  800b7e:	5f                   	pop    %edi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	57                   	push   %edi
  800b85:	56                   	push   %esi
  800b86:	53                   	push   %ebx
  800b87:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b8f:	b8 06 00 00 00       	mov    $0x6,%eax
  800b94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b97:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9a:	89 df                	mov    %ebx,%edi
  800b9c:	89 de                	mov    %ebx,%esi
  800b9e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba0:	85 c0                	test   %eax,%eax
  800ba2:	7e 17                	jle    800bbb <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba4:	83 ec 0c             	sub    $0xc,%esp
  800ba7:	50                   	push   %eax
  800ba8:	6a 06                	push   $0x6
  800baa:	68 1f 25 80 00       	push   $0x80251f
  800baf:	6a 23                	push   $0x23
  800bb1:	68 3c 25 80 00       	push   $0x80253c
  800bb6:	e8 59 11 00 00       	call   801d14 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbe:	5b                   	pop    %ebx
  800bbf:	5e                   	pop    %esi
  800bc0:	5f                   	pop    %edi
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	57                   	push   %edi
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
  800bc9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd1:	b8 08 00 00 00       	mov    $0x8,%eax
  800bd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdc:	89 df                	mov    %ebx,%edi
  800bde:	89 de                	mov    %ebx,%esi
  800be0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be2:	85 c0                	test   %eax,%eax
  800be4:	7e 17                	jle    800bfd <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be6:	83 ec 0c             	sub    $0xc,%esp
  800be9:	50                   	push   %eax
  800bea:	6a 08                	push   $0x8
  800bec:	68 1f 25 80 00       	push   $0x80251f
  800bf1:	6a 23                	push   $0x23
  800bf3:	68 3c 25 80 00       	push   $0x80253c
  800bf8:	e8 17 11 00 00       	call   801d14 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5f                   	pop    %edi
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	57                   	push   %edi
  800c09:	56                   	push   %esi
  800c0a:	53                   	push   %ebx
  800c0b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c13:	b8 09 00 00 00       	mov    $0x9,%eax
  800c18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1e:	89 df                	mov    %ebx,%edi
  800c20:	89 de                	mov    %ebx,%esi
  800c22:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c24:	85 c0                	test   %eax,%eax
  800c26:	7e 17                	jle    800c3f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c28:	83 ec 0c             	sub    $0xc,%esp
  800c2b:	50                   	push   %eax
  800c2c:	6a 09                	push   $0x9
  800c2e:	68 1f 25 80 00       	push   $0x80251f
  800c33:	6a 23                	push   $0x23
  800c35:	68 3c 25 80 00       	push   $0x80253c
  800c3a:	e8 d5 10 00 00       	call   801d14 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c42:	5b                   	pop    %ebx
  800c43:	5e                   	pop    %esi
  800c44:	5f                   	pop    %edi
  800c45:	5d                   	pop    %ebp
  800c46:	c3                   	ret    

00800c47 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
  800c4d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c55:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c60:	89 df                	mov    %ebx,%edi
  800c62:	89 de                	mov    %ebx,%esi
  800c64:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c66:	85 c0                	test   %eax,%eax
  800c68:	7e 17                	jle    800c81 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6a:	83 ec 0c             	sub    $0xc,%esp
  800c6d:	50                   	push   %eax
  800c6e:	6a 0a                	push   $0xa
  800c70:	68 1f 25 80 00       	push   $0x80251f
  800c75:	6a 23                	push   $0x23
  800c77:	68 3c 25 80 00       	push   $0x80253c
  800c7c:	e8 93 10 00 00       	call   801d14 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	57                   	push   %edi
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8f:	be 00 00 00 00       	mov    $0x0,%esi
  800c94:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ca7:	5b                   	pop    %ebx
  800ca8:	5e                   	pop    %esi
  800ca9:	5f                   	pop    %edi
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    

00800cac <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	57                   	push   %edi
  800cb0:	56                   	push   %esi
  800cb1:	53                   	push   %ebx
  800cb2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cba:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc2:	89 cb                	mov    %ecx,%ebx
  800cc4:	89 cf                	mov    %ecx,%edi
  800cc6:	89 ce                	mov    %ecx,%esi
  800cc8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cca:	85 c0                	test   %eax,%eax
  800ccc:	7e 17                	jle    800ce5 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cce:	83 ec 0c             	sub    $0xc,%esp
  800cd1:	50                   	push   %eax
  800cd2:	6a 0d                	push   $0xd
  800cd4:	68 1f 25 80 00       	push   $0x80251f
  800cd9:	6a 23                	push   $0x23
  800cdb:	68 3c 25 80 00       	push   $0x80253c
  800ce0:	e8 2f 10 00 00       	call   801d14 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ce5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce8:	5b                   	pop    %ebx
  800ce9:	5e                   	pop    %esi
  800cea:	5f                   	pop    %edi
  800ceb:	5d                   	pop    %ebp
  800cec:	c3                   	ret    

00800ced <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	57                   	push   %edi
  800cf1:	56                   	push   %esi
  800cf2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf8:	b8 0e 00 00 00       	mov    $0xe,%eax
  800cfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800d00:	89 cb                	mov    %ecx,%ebx
  800d02:	89 cf                	mov    %ecx,%edi
  800d04:	89 ce                	mov    %ecx,%esi
  800d06:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5f                   	pop    %edi
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d13:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d18:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d20:	89 cb                	mov    %ecx,%ebx
  800d22:	89 cf                	mov    %ecx,%edi
  800d24:	89 ce                	mov    %ecx,%esi
  800d26:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800d28:	5b                   	pop    %ebx
  800d29:	5e                   	pop    %esi
  800d2a:	5f                   	pop    %edi
  800d2b:	5d                   	pop    %ebp
  800d2c:	c3                   	ret    

00800d2d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	53                   	push   %ebx
  800d31:	83 ec 04             	sub    $0x4,%esp
  800d34:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d37:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800d39:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d3d:	74 11                	je     800d50 <pgfault+0x23>
  800d3f:	89 d8                	mov    %ebx,%eax
  800d41:	c1 e8 0c             	shr    $0xc,%eax
  800d44:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d4b:	f6 c4 08             	test   $0x8,%ah
  800d4e:	75 14                	jne    800d64 <pgfault+0x37>
		panic("faulting access");
  800d50:	83 ec 04             	sub    $0x4,%esp
  800d53:	68 4a 25 80 00       	push   $0x80254a
  800d58:	6a 1e                	push   $0x1e
  800d5a:	68 5a 25 80 00       	push   $0x80255a
  800d5f:	e8 b0 0f 00 00       	call   801d14 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800d64:	83 ec 04             	sub    $0x4,%esp
  800d67:	6a 07                	push   $0x7
  800d69:	68 00 f0 7f 00       	push   $0x7ff000
  800d6e:	6a 00                	push   $0x0
  800d70:	e8 87 fd ff ff       	call   800afc <sys_page_alloc>
	if (r < 0) {
  800d75:	83 c4 10             	add    $0x10,%esp
  800d78:	85 c0                	test   %eax,%eax
  800d7a:	79 12                	jns    800d8e <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800d7c:	50                   	push   %eax
  800d7d:	68 65 25 80 00       	push   $0x802565
  800d82:	6a 2c                	push   $0x2c
  800d84:	68 5a 25 80 00       	push   $0x80255a
  800d89:	e8 86 0f 00 00       	call   801d14 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800d8e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800d94:	83 ec 04             	sub    $0x4,%esp
  800d97:	68 00 10 00 00       	push   $0x1000
  800d9c:	53                   	push   %ebx
  800d9d:	68 00 f0 7f 00       	push   $0x7ff000
  800da2:	e8 4c fb ff ff       	call   8008f3 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800da7:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800dae:	53                   	push   %ebx
  800daf:	6a 00                	push   $0x0
  800db1:	68 00 f0 7f 00       	push   $0x7ff000
  800db6:	6a 00                	push   $0x0
  800db8:	e8 82 fd ff ff       	call   800b3f <sys_page_map>
	if (r < 0) {
  800dbd:	83 c4 20             	add    $0x20,%esp
  800dc0:	85 c0                	test   %eax,%eax
  800dc2:	79 12                	jns    800dd6 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800dc4:	50                   	push   %eax
  800dc5:	68 65 25 80 00       	push   $0x802565
  800dca:	6a 33                	push   $0x33
  800dcc:	68 5a 25 80 00       	push   $0x80255a
  800dd1:	e8 3e 0f 00 00       	call   801d14 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800dd6:	83 ec 08             	sub    $0x8,%esp
  800dd9:	68 00 f0 7f 00       	push   $0x7ff000
  800dde:	6a 00                	push   $0x0
  800de0:	e8 9c fd ff ff       	call   800b81 <sys_page_unmap>
	if (r < 0) {
  800de5:	83 c4 10             	add    $0x10,%esp
  800de8:	85 c0                	test   %eax,%eax
  800dea:	79 12                	jns    800dfe <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800dec:	50                   	push   %eax
  800ded:	68 65 25 80 00       	push   $0x802565
  800df2:	6a 37                	push   $0x37
  800df4:	68 5a 25 80 00       	push   $0x80255a
  800df9:	e8 16 0f 00 00       	call   801d14 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800dfe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e01:	c9                   	leave  
  800e02:	c3                   	ret    

00800e03 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e03:	55                   	push   %ebp
  800e04:	89 e5                	mov    %esp,%ebp
  800e06:	57                   	push   %edi
  800e07:	56                   	push   %esi
  800e08:	53                   	push   %ebx
  800e09:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e0c:	68 2d 0d 80 00       	push   $0x800d2d
  800e11:	e8 44 0f 00 00       	call   801d5a <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e16:	b8 07 00 00 00       	mov    $0x7,%eax
  800e1b:	cd 30                	int    $0x30
  800e1d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800e20:	83 c4 10             	add    $0x10,%esp
  800e23:	85 c0                	test   %eax,%eax
  800e25:	79 17                	jns    800e3e <fork+0x3b>
		panic("fork fault %e");
  800e27:	83 ec 04             	sub    $0x4,%esp
  800e2a:	68 7e 25 80 00       	push   $0x80257e
  800e2f:	68 84 00 00 00       	push   $0x84
  800e34:	68 5a 25 80 00       	push   $0x80255a
  800e39:	e8 d6 0e 00 00       	call   801d14 <_panic>
  800e3e:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800e40:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e44:	75 24                	jne    800e6a <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e46:	e8 73 fc ff ff       	call   800abe <sys_getenvid>
  800e4b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e50:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  800e56:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e5b:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800e60:	b8 00 00 00 00       	mov    $0x0,%eax
  800e65:	e9 64 01 00 00       	jmp    800fce <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800e6a:	83 ec 04             	sub    $0x4,%esp
  800e6d:	6a 07                	push   $0x7
  800e6f:	68 00 f0 bf ee       	push   $0xeebff000
  800e74:	ff 75 e4             	pushl  -0x1c(%ebp)
  800e77:	e8 80 fc ff ff       	call   800afc <sys_page_alloc>
  800e7c:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800e7f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800e84:	89 d8                	mov    %ebx,%eax
  800e86:	c1 e8 16             	shr    $0x16,%eax
  800e89:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e90:	a8 01                	test   $0x1,%al
  800e92:	0f 84 fc 00 00 00    	je     800f94 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800e98:	89 d8                	mov    %ebx,%eax
  800e9a:	c1 e8 0c             	shr    $0xc,%eax
  800e9d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ea4:	f6 c2 01             	test   $0x1,%dl
  800ea7:	0f 84 e7 00 00 00    	je     800f94 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800ead:	89 c6                	mov    %eax,%esi
  800eaf:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800eb2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800eb9:	f6 c6 04             	test   $0x4,%dh
  800ebc:	74 39                	je     800ef7 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800ebe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ec5:	83 ec 0c             	sub    $0xc,%esp
  800ec8:	25 07 0e 00 00       	and    $0xe07,%eax
  800ecd:	50                   	push   %eax
  800ece:	56                   	push   %esi
  800ecf:	57                   	push   %edi
  800ed0:	56                   	push   %esi
  800ed1:	6a 00                	push   $0x0
  800ed3:	e8 67 fc ff ff       	call   800b3f <sys_page_map>
		if (r < 0) {
  800ed8:	83 c4 20             	add    $0x20,%esp
  800edb:	85 c0                	test   %eax,%eax
  800edd:	0f 89 b1 00 00 00    	jns    800f94 <fork+0x191>
		    	panic("sys page map fault %e");
  800ee3:	83 ec 04             	sub    $0x4,%esp
  800ee6:	68 8c 25 80 00       	push   $0x80258c
  800eeb:	6a 54                	push   $0x54
  800eed:	68 5a 25 80 00       	push   $0x80255a
  800ef2:	e8 1d 0e 00 00       	call   801d14 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800ef7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800efe:	f6 c2 02             	test   $0x2,%dl
  800f01:	75 0c                	jne    800f0f <fork+0x10c>
  800f03:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f0a:	f6 c4 08             	test   $0x8,%ah
  800f0d:	74 5b                	je     800f6a <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f0f:	83 ec 0c             	sub    $0xc,%esp
  800f12:	68 05 08 00 00       	push   $0x805
  800f17:	56                   	push   %esi
  800f18:	57                   	push   %edi
  800f19:	56                   	push   %esi
  800f1a:	6a 00                	push   $0x0
  800f1c:	e8 1e fc ff ff       	call   800b3f <sys_page_map>
		if (r < 0) {
  800f21:	83 c4 20             	add    $0x20,%esp
  800f24:	85 c0                	test   %eax,%eax
  800f26:	79 14                	jns    800f3c <fork+0x139>
		    	panic("sys page map fault %e");
  800f28:	83 ec 04             	sub    $0x4,%esp
  800f2b:	68 8c 25 80 00       	push   $0x80258c
  800f30:	6a 5b                	push   $0x5b
  800f32:	68 5a 25 80 00       	push   $0x80255a
  800f37:	e8 d8 0d 00 00       	call   801d14 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800f3c:	83 ec 0c             	sub    $0xc,%esp
  800f3f:	68 05 08 00 00       	push   $0x805
  800f44:	56                   	push   %esi
  800f45:	6a 00                	push   $0x0
  800f47:	56                   	push   %esi
  800f48:	6a 00                	push   $0x0
  800f4a:	e8 f0 fb ff ff       	call   800b3f <sys_page_map>
		if (r < 0) {
  800f4f:	83 c4 20             	add    $0x20,%esp
  800f52:	85 c0                	test   %eax,%eax
  800f54:	79 3e                	jns    800f94 <fork+0x191>
		    	panic("sys page map fault %e");
  800f56:	83 ec 04             	sub    $0x4,%esp
  800f59:	68 8c 25 80 00       	push   $0x80258c
  800f5e:	6a 5f                	push   $0x5f
  800f60:	68 5a 25 80 00       	push   $0x80255a
  800f65:	e8 aa 0d 00 00       	call   801d14 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800f6a:	83 ec 0c             	sub    $0xc,%esp
  800f6d:	6a 05                	push   $0x5
  800f6f:	56                   	push   %esi
  800f70:	57                   	push   %edi
  800f71:	56                   	push   %esi
  800f72:	6a 00                	push   $0x0
  800f74:	e8 c6 fb ff ff       	call   800b3f <sys_page_map>
		if (r < 0) {
  800f79:	83 c4 20             	add    $0x20,%esp
  800f7c:	85 c0                	test   %eax,%eax
  800f7e:	79 14                	jns    800f94 <fork+0x191>
		    	panic("sys page map fault %e");
  800f80:	83 ec 04             	sub    $0x4,%esp
  800f83:	68 8c 25 80 00       	push   $0x80258c
  800f88:	6a 64                	push   $0x64
  800f8a:	68 5a 25 80 00       	push   $0x80255a
  800f8f:	e8 80 0d 00 00       	call   801d14 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f94:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f9a:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800fa0:	0f 85 de fe ff ff    	jne    800e84 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800fa6:	a1 04 40 80 00       	mov    0x804004,%eax
  800fab:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  800fb1:	83 ec 08             	sub    $0x8,%esp
  800fb4:	50                   	push   %eax
  800fb5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800fb8:	57                   	push   %edi
  800fb9:	e8 89 fc ff ff       	call   800c47 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  800fbe:	83 c4 08             	add    $0x8,%esp
  800fc1:	6a 02                	push   $0x2
  800fc3:	57                   	push   %edi
  800fc4:	e8 fa fb ff ff       	call   800bc3 <sys_env_set_status>
	
	return envid;
  800fc9:	83 c4 10             	add    $0x10,%esp
  800fcc:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  800fce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fd1:	5b                   	pop    %ebx
  800fd2:	5e                   	pop    %esi
  800fd3:	5f                   	pop    %edi
  800fd4:	5d                   	pop    %ebp
  800fd5:	c3                   	ret    

00800fd6 <sfork>:

envid_t
sfork(void)
{
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
	return 0;
}
  800fd9:	b8 00 00 00 00       	mov    $0x0,%eax
  800fde:	5d                   	pop    %ebp
  800fdf:	c3                   	ret    

00800fe0 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	56                   	push   %esi
  800fe4:	53                   	push   %ebx
  800fe5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  800fe8:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  800fee:	83 ec 08             	sub    $0x8,%esp
  800ff1:	53                   	push   %ebx
  800ff2:	68 a4 25 80 00       	push   $0x8025a4
  800ff7:	e8 78 f1 ff ff       	call   800174 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  800ffc:	c7 04 24 a7 00 80 00 	movl   $0x8000a7,(%esp)
  801003:	e8 e5 fc ff ff       	call   800ced <sys_thread_create>
  801008:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80100a:	83 c4 08             	add    $0x8,%esp
  80100d:	53                   	push   %ebx
  80100e:	68 a4 25 80 00       	push   $0x8025a4
  801013:	e8 5c f1 ff ff       	call   800174 <cprintf>
	return id;
}
  801018:	89 f0                	mov    %esi,%eax
  80101a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80101d:	5b                   	pop    %ebx
  80101e:	5e                   	pop    %esi
  80101f:	5d                   	pop    %ebp
  801020:	c3                   	ret    

00801021 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801021:	55                   	push   %ebp
  801022:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801024:	8b 45 08             	mov    0x8(%ebp),%eax
  801027:	05 00 00 00 30       	add    $0x30000000,%eax
  80102c:	c1 e8 0c             	shr    $0xc,%eax
}
  80102f:	5d                   	pop    %ebp
  801030:	c3                   	ret    

00801031 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801031:	55                   	push   %ebp
  801032:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801034:	8b 45 08             	mov    0x8(%ebp),%eax
  801037:	05 00 00 00 30       	add    $0x30000000,%eax
  80103c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801041:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801046:	5d                   	pop    %ebp
  801047:	c3                   	ret    

00801048 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801048:	55                   	push   %ebp
  801049:	89 e5                	mov    %esp,%ebp
  80104b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80104e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801053:	89 c2                	mov    %eax,%edx
  801055:	c1 ea 16             	shr    $0x16,%edx
  801058:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80105f:	f6 c2 01             	test   $0x1,%dl
  801062:	74 11                	je     801075 <fd_alloc+0x2d>
  801064:	89 c2                	mov    %eax,%edx
  801066:	c1 ea 0c             	shr    $0xc,%edx
  801069:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801070:	f6 c2 01             	test   $0x1,%dl
  801073:	75 09                	jne    80107e <fd_alloc+0x36>
			*fd_store = fd;
  801075:	89 01                	mov    %eax,(%ecx)
			return 0;
  801077:	b8 00 00 00 00       	mov    $0x0,%eax
  80107c:	eb 17                	jmp    801095 <fd_alloc+0x4d>
  80107e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801083:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801088:	75 c9                	jne    801053 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80108a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801090:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801095:	5d                   	pop    %ebp
  801096:	c3                   	ret    

00801097 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801097:	55                   	push   %ebp
  801098:	89 e5                	mov    %esp,%ebp
  80109a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80109d:	83 f8 1f             	cmp    $0x1f,%eax
  8010a0:	77 36                	ja     8010d8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010a2:	c1 e0 0c             	shl    $0xc,%eax
  8010a5:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010aa:	89 c2                	mov    %eax,%edx
  8010ac:	c1 ea 16             	shr    $0x16,%edx
  8010af:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010b6:	f6 c2 01             	test   $0x1,%dl
  8010b9:	74 24                	je     8010df <fd_lookup+0x48>
  8010bb:	89 c2                	mov    %eax,%edx
  8010bd:	c1 ea 0c             	shr    $0xc,%edx
  8010c0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010c7:	f6 c2 01             	test   $0x1,%dl
  8010ca:	74 1a                	je     8010e6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010cf:	89 02                	mov    %eax,(%edx)
	return 0;
  8010d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d6:	eb 13                	jmp    8010eb <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010dd:	eb 0c                	jmp    8010eb <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010e4:	eb 05                	jmp    8010eb <fd_lookup+0x54>
  8010e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010eb:	5d                   	pop    %ebp
  8010ec:	c3                   	ret    

008010ed <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
  8010f0:	83 ec 08             	sub    $0x8,%esp
  8010f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010f6:	ba 44 26 80 00       	mov    $0x802644,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8010fb:	eb 13                	jmp    801110 <dev_lookup+0x23>
  8010fd:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801100:	39 08                	cmp    %ecx,(%eax)
  801102:	75 0c                	jne    801110 <dev_lookup+0x23>
			*dev = devtab[i];
  801104:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801107:	89 01                	mov    %eax,(%ecx)
			return 0;
  801109:	b8 00 00 00 00       	mov    $0x0,%eax
  80110e:	eb 2e                	jmp    80113e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801110:	8b 02                	mov    (%edx),%eax
  801112:	85 c0                	test   %eax,%eax
  801114:	75 e7                	jne    8010fd <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801116:	a1 04 40 80 00       	mov    0x804004,%eax
  80111b:	8b 40 7c             	mov    0x7c(%eax),%eax
  80111e:	83 ec 04             	sub    $0x4,%esp
  801121:	51                   	push   %ecx
  801122:	50                   	push   %eax
  801123:	68 c8 25 80 00       	push   $0x8025c8
  801128:	e8 47 f0 ff ff       	call   800174 <cprintf>
	*dev = 0;
  80112d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801130:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801136:	83 c4 10             	add    $0x10,%esp
  801139:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80113e:	c9                   	leave  
  80113f:	c3                   	ret    

00801140 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	56                   	push   %esi
  801144:	53                   	push   %ebx
  801145:	83 ec 10             	sub    $0x10,%esp
  801148:	8b 75 08             	mov    0x8(%ebp),%esi
  80114b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80114e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801151:	50                   	push   %eax
  801152:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801158:	c1 e8 0c             	shr    $0xc,%eax
  80115b:	50                   	push   %eax
  80115c:	e8 36 ff ff ff       	call   801097 <fd_lookup>
  801161:	83 c4 08             	add    $0x8,%esp
  801164:	85 c0                	test   %eax,%eax
  801166:	78 05                	js     80116d <fd_close+0x2d>
	    || fd != fd2)
  801168:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80116b:	74 0c                	je     801179 <fd_close+0x39>
		return (must_exist ? r : 0);
  80116d:	84 db                	test   %bl,%bl
  80116f:	ba 00 00 00 00       	mov    $0x0,%edx
  801174:	0f 44 c2             	cmove  %edx,%eax
  801177:	eb 41                	jmp    8011ba <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801179:	83 ec 08             	sub    $0x8,%esp
  80117c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80117f:	50                   	push   %eax
  801180:	ff 36                	pushl  (%esi)
  801182:	e8 66 ff ff ff       	call   8010ed <dev_lookup>
  801187:	89 c3                	mov    %eax,%ebx
  801189:	83 c4 10             	add    $0x10,%esp
  80118c:	85 c0                	test   %eax,%eax
  80118e:	78 1a                	js     8011aa <fd_close+0x6a>
		if (dev->dev_close)
  801190:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801193:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801196:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80119b:	85 c0                	test   %eax,%eax
  80119d:	74 0b                	je     8011aa <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80119f:	83 ec 0c             	sub    $0xc,%esp
  8011a2:	56                   	push   %esi
  8011a3:	ff d0                	call   *%eax
  8011a5:	89 c3                	mov    %eax,%ebx
  8011a7:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011aa:	83 ec 08             	sub    $0x8,%esp
  8011ad:	56                   	push   %esi
  8011ae:	6a 00                	push   $0x0
  8011b0:	e8 cc f9 ff ff       	call   800b81 <sys_page_unmap>
	return r;
  8011b5:	83 c4 10             	add    $0x10,%esp
  8011b8:	89 d8                	mov    %ebx,%eax
}
  8011ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011bd:	5b                   	pop    %ebx
  8011be:	5e                   	pop    %esi
  8011bf:	5d                   	pop    %ebp
  8011c0:	c3                   	ret    

008011c1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011c1:	55                   	push   %ebp
  8011c2:	89 e5                	mov    %esp,%ebp
  8011c4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ca:	50                   	push   %eax
  8011cb:	ff 75 08             	pushl  0x8(%ebp)
  8011ce:	e8 c4 fe ff ff       	call   801097 <fd_lookup>
  8011d3:	83 c4 08             	add    $0x8,%esp
  8011d6:	85 c0                	test   %eax,%eax
  8011d8:	78 10                	js     8011ea <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8011da:	83 ec 08             	sub    $0x8,%esp
  8011dd:	6a 01                	push   $0x1
  8011df:	ff 75 f4             	pushl  -0xc(%ebp)
  8011e2:	e8 59 ff ff ff       	call   801140 <fd_close>
  8011e7:	83 c4 10             	add    $0x10,%esp
}
  8011ea:	c9                   	leave  
  8011eb:	c3                   	ret    

008011ec <close_all>:

void
close_all(void)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	53                   	push   %ebx
  8011f0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011f3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011f8:	83 ec 0c             	sub    $0xc,%esp
  8011fb:	53                   	push   %ebx
  8011fc:	e8 c0 ff ff ff       	call   8011c1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801201:	83 c3 01             	add    $0x1,%ebx
  801204:	83 c4 10             	add    $0x10,%esp
  801207:	83 fb 20             	cmp    $0x20,%ebx
  80120a:	75 ec                	jne    8011f8 <close_all+0xc>
		close(i);
}
  80120c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80120f:	c9                   	leave  
  801210:	c3                   	ret    

00801211 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
  801214:	57                   	push   %edi
  801215:	56                   	push   %esi
  801216:	53                   	push   %ebx
  801217:	83 ec 2c             	sub    $0x2c,%esp
  80121a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80121d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801220:	50                   	push   %eax
  801221:	ff 75 08             	pushl  0x8(%ebp)
  801224:	e8 6e fe ff ff       	call   801097 <fd_lookup>
  801229:	83 c4 08             	add    $0x8,%esp
  80122c:	85 c0                	test   %eax,%eax
  80122e:	0f 88 c1 00 00 00    	js     8012f5 <dup+0xe4>
		return r;
	close(newfdnum);
  801234:	83 ec 0c             	sub    $0xc,%esp
  801237:	56                   	push   %esi
  801238:	e8 84 ff ff ff       	call   8011c1 <close>

	newfd = INDEX2FD(newfdnum);
  80123d:	89 f3                	mov    %esi,%ebx
  80123f:	c1 e3 0c             	shl    $0xc,%ebx
  801242:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801248:	83 c4 04             	add    $0x4,%esp
  80124b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80124e:	e8 de fd ff ff       	call   801031 <fd2data>
  801253:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801255:	89 1c 24             	mov    %ebx,(%esp)
  801258:	e8 d4 fd ff ff       	call   801031 <fd2data>
  80125d:	83 c4 10             	add    $0x10,%esp
  801260:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801263:	89 f8                	mov    %edi,%eax
  801265:	c1 e8 16             	shr    $0x16,%eax
  801268:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80126f:	a8 01                	test   $0x1,%al
  801271:	74 37                	je     8012aa <dup+0x99>
  801273:	89 f8                	mov    %edi,%eax
  801275:	c1 e8 0c             	shr    $0xc,%eax
  801278:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80127f:	f6 c2 01             	test   $0x1,%dl
  801282:	74 26                	je     8012aa <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801284:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80128b:	83 ec 0c             	sub    $0xc,%esp
  80128e:	25 07 0e 00 00       	and    $0xe07,%eax
  801293:	50                   	push   %eax
  801294:	ff 75 d4             	pushl  -0x2c(%ebp)
  801297:	6a 00                	push   $0x0
  801299:	57                   	push   %edi
  80129a:	6a 00                	push   $0x0
  80129c:	e8 9e f8 ff ff       	call   800b3f <sys_page_map>
  8012a1:	89 c7                	mov    %eax,%edi
  8012a3:	83 c4 20             	add    $0x20,%esp
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	78 2e                	js     8012d8 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012aa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012ad:	89 d0                	mov    %edx,%eax
  8012af:	c1 e8 0c             	shr    $0xc,%eax
  8012b2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012b9:	83 ec 0c             	sub    $0xc,%esp
  8012bc:	25 07 0e 00 00       	and    $0xe07,%eax
  8012c1:	50                   	push   %eax
  8012c2:	53                   	push   %ebx
  8012c3:	6a 00                	push   $0x0
  8012c5:	52                   	push   %edx
  8012c6:	6a 00                	push   $0x0
  8012c8:	e8 72 f8 ff ff       	call   800b3f <sys_page_map>
  8012cd:	89 c7                	mov    %eax,%edi
  8012cf:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8012d2:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012d4:	85 ff                	test   %edi,%edi
  8012d6:	79 1d                	jns    8012f5 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012d8:	83 ec 08             	sub    $0x8,%esp
  8012db:	53                   	push   %ebx
  8012dc:	6a 00                	push   $0x0
  8012de:	e8 9e f8 ff ff       	call   800b81 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012e3:	83 c4 08             	add    $0x8,%esp
  8012e6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012e9:	6a 00                	push   $0x0
  8012eb:	e8 91 f8 ff ff       	call   800b81 <sys_page_unmap>
	return r;
  8012f0:	83 c4 10             	add    $0x10,%esp
  8012f3:	89 f8                	mov    %edi,%eax
}
  8012f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012f8:	5b                   	pop    %ebx
  8012f9:	5e                   	pop    %esi
  8012fa:	5f                   	pop    %edi
  8012fb:	5d                   	pop    %ebp
  8012fc:	c3                   	ret    

008012fd <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012fd:	55                   	push   %ebp
  8012fe:	89 e5                	mov    %esp,%ebp
  801300:	53                   	push   %ebx
  801301:	83 ec 14             	sub    $0x14,%esp
  801304:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801307:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80130a:	50                   	push   %eax
  80130b:	53                   	push   %ebx
  80130c:	e8 86 fd ff ff       	call   801097 <fd_lookup>
  801311:	83 c4 08             	add    $0x8,%esp
  801314:	89 c2                	mov    %eax,%edx
  801316:	85 c0                	test   %eax,%eax
  801318:	78 6d                	js     801387 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80131a:	83 ec 08             	sub    $0x8,%esp
  80131d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801320:	50                   	push   %eax
  801321:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801324:	ff 30                	pushl  (%eax)
  801326:	e8 c2 fd ff ff       	call   8010ed <dev_lookup>
  80132b:	83 c4 10             	add    $0x10,%esp
  80132e:	85 c0                	test   %eax,%eax
  801330:	78 4c                	js     80137e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801332:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801335:	8b 42 08             	mov    0x8(%edx),%eax
  801338:	83 e0 03             	and    $0x3,%eax
  80133b:	83 f8 01             	cmp    $0x1,%eax
  80133e:	75 21                	jne    801361 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801340:	a1 04 40 80 00       	mov    0x804004,%eax
  801345:	8b 40 7c             	mov    0x7c(%eax),%eax
  801348:	83 ec 04             	sub    $0x4,%esp
  80134b:	53                   	push   %ebx
  80134c:	50                   	push   %eax
  80134d:	68 09 26 80 00       	push   $0x802609
  801352:	e8 1d ee ff ff       	call   800174 <cprintf>
		return -E_INVAL;
  801357:	83 c4 10             	add    $0x10,%esp
  80135a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80135f:	eb 26                	jmp    801387 <read+0x8a>
	}
	if (!dev->dev_read)
  801361:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801364:	8b 40 08             	mov    0x8(%eax),%eax
  801367:	85 c0                	test   %eax,%eax
  801369:	74 17                	je     801382 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80136b:	83 ec 04             	sub    $0x4,%esp
  80136e:	ff 75 10             	pushl  0x10(%ebp)
  801371:	ff 75 0c             	pushl  0xc(%ebp)
  801374:	52                   	push   %edx
  801375:	ff d0                	call   *%eax
  801377:	89 c2                	mov    %eax,%edx
  801379:	83 c4 10             	add    $0x10,%esp
  80137c:	eb 09                	jmp    801387 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80137e:	89 c2                	mov    %eax,%edx
  801380:	eb 05                	jmp    801387 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801382:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801387:	89 d0                	mov    %edx,%eax
  801389:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80138c:	c9                   	leave  
  80138d:	c3                   	ret    

0080138e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80138e:	55                   	push   %ebp
  80138f:	89 e5                	mov    %esp,%ebp
  801391:	57                   	push   %edi
  801392:	56                   	push   %esi
  801393:	53                   	push   %ebx
  801394:	83 ec 0c             	sub    $0xc,%esp
  801397:	8b 7d 08             	mov    0x8(%ebp),%edi
  80139a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80139d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013a2:	eb 21                	jmp    8013c5 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013a4:	83 ec 04             	sub    $0x4,%esp
  8013a7:	89 f0                	mov    %esi,%eax
  8013a9:	29 d8                	sub    %ebx,%eax
  8013ab:	50                   	push   %eax
  8013ac:	89 d8                	mov    %ebx,%eax
  8013ae:	03 45 0c             	add    0xc(%ebp),%eax
  8013b1:	50                   	push   %eax
  8013b2:	57                   	push   %edi
  8013b3:	e8 45 ff ff ff       	call   8012fd <read>
		if (m < 0)
  8013b8:	83 c4 10             	add    $0x10,%esp
  8013bb:	85 c0                	test   %eax,%eax
  8013bd:	78 10                	js     8013cf <readn+0x41>
			return m;
		if (m == 0)
  8013bf:	85 c0                	test   %eax,%eax
  8013c1:	74 0a                	je     8013cd <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013c3:	01 c3                	add    %eax,%ebx
  8013c5:	39 f3                	cmp    %esi,%ebx
  8013c7:	72 db                	jb     8013a4 <readn+0x16>
  8013c9:	89 d8                	mov    %ebx,%eax
  8013cb:	eb 02                	jmp    8013cf <readn+0x41>
  8013cd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d2:	5b                   	pop    %ebx
  8013d3:	5e                   	pop    %esi
  8013d4:	5f                   	pop    %edi
  8013d5:	5d                   	pop    %ebp
  8013d6:	c3                   	ret    

008013d7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013d7:	55                   	push   %ebp
  8013d8:	89 e5                	mov    %esp,%ebp
  8013da:	53                   	push   %ebx
  8013db:	83 ec 14             	sub    $0x14,%esp
  8013de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e4:	50                   	push   %eax
  8013e5:	53                   	push   %ebx
  8013e6:	e8 ac fc ff ff       	call   801097 <fd_lookup>
  8013eb:	83 c4 08             	add    $0x8,%esp
  8013ee:	89 c2                	mov    %eax,%edx
  8013f0:	85 c0                	test   %eax,%eax
  8013f2:	78 68                	js     80145c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f4:	83 ec 08             	sub    $0x8,%esp
  8013f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013fa:	50                   	push   %eax
  8013fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013fe:	ff 30                	pushl  (%eax)
  801400:	e8 e8 fc ff ff       	call   8010ed <dev_lookup>
  801405:	83 c4 10             	add    $0x10,%esp
  801408:	85 c0                	test   %eax,%eax
  80140a:	78 47                	js     801453 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80140c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80140f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801413:	75 21                	jne    801436 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801415:	a1 04 40 80 00       	mov    0x804004,%eax
  80141a:	8b 40 7c             	mov    0x7c(%eax),%eax
  80141d:	83 ec 04             	sub    $0x4,%esp
  801420:	53                   	push   %ebx
  801421:	50                   	push   %eax
  801422:	68 25 26 80 00       	push   $0x802625
  801427:	e8 48 ed ff ff       	call   800174 <cprintf>
		return -E_INVAL;
  80142c:	83 c4 10             	add    $0x10,%esp
  80142f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801434:	eb 26                	jmp    80145c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801436:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801439:	8b 52 0c             	mov    0xc(%edx),%edx
  80143c:	85 d2                	test   %edx,%edx
  80143e:	74 17                	je     801457 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801440:	83 ec 04             	sub    $0x4,%esp
  801443:	ff 75 10             	pushl  0x10(%ebp)
  801446:	ff 75 0c             	pushl  0xc(%ebp)
  801449:	50                   	push   %eax
  80144a:	ff d2                	call   *%edx
  80144c:	89 c2                	mov    %eax,%edx
  80144e:	83 c4 10             	add    $0x10,%esp
  801451:	eb 09                	jmp    80145c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801453:	89 c2                	mov    %eax,%edx
  801455:	eb 05                	jmp    80145c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801457:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80145c:	89 d0                	mov    %edx,%eax
  80145e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801461:	c9                   	leave  
  801462:	c3                   	ret    

00801463 <seek>:

int
seek(int fdnum, off_t offset)
{
  801463:	55                   	push   %ebp
  801464:	89 e5                	mov    %esp,%ebp
  801466:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801469:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80146c:	50                   	push   %eax
  80146d:	ff 75 08             	pushl  0x8(%ebp)
  801470:	e8 22 fc ff ff       	call   801097 <fd_lookup>
  801475:	83 c4 08             	add    $0x8,%esp
  801478:	85 c0                	test   %eax,%eax
  80147a:	78 0e                	js     80148a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80147c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80147f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801482:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801485:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80148a:	c9                   	leave  
  80148b:	c3                   	ret    

0080148c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80148c:	55                   	push   %ebp
  80148d:	89 e5                	mov    %esp,%ebp
  80148f:	53                   	push   %ebx
  801490:	83 ec 14             	sub    $0x14,%esp
  801493:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801496:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801499:	50                   	push   %eax
  80149a:	53                   	push   %ebx
  80149b:	e8 f7 fb ff ff       	call   801097 <fd_lookup>
  8014a0:	83 c4 08             	add    $0x8,%esp
  8014a3:	89 c2                	mov    %eax,%edx
  8014a5:	85 c0                	test   %eax,%eax
  8014a7:	78 65                	js     80150e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a9:	83 ec 08             	sub    $0x8,%esp
  8014ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014af:	50                   	push   %eax
  8014b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b3:	ff 30                	pushl  (%eax)
  8014b5:	e8 33 fc ff ff       	call   8010ed <dev_lookup>
  8014ba:	83 c4 10             	add    $0x10,%esp
  8014bd:	85 c0                	test   %eax,%eax
  8014bf:	78 44                	js     801505 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014c8:	75 21                	jne    8014eb <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014ca:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014cf:	8b 40 7c             	mov    0x7c(%eax),%eax
  8014d2:	83 ec 04             	sub    $0x4,%esp
  8014d5:	53                   	push   %ebx
  8014d6:	50                   	push   %eax
  8014d7:	68 e8 25 80 00       	push   $0x8025e8
  8014dc:	e8 93 ec ff ff       	call   800174 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014e1:	83 c4 10             	add    $0x10,%esp
  8014e4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014e9:	eb 23                	jmp    80150e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8014eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014ee:	8b 52 18             	mov    0x18(%edx),%edx
  8014f1:	85 d2                	test   %edx,%edx
  8014f3:	74 14                	je     801509 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014f5:	83 ec 08             	sub    $0x8,%esp
  8014f8:	ff 75 0c             	pushl  0xc(%ebp)
  8014fb:	50                   	push   %eax
  8014fc:	ff d2                	call   *%edx
  8014fe:	89 c2                	mov    %eax,%edx
  801500:	83 c4 10             	add    $0x10,%esp
  801503:	eb 09                	jmp    80150e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801505:	89 c2                	mov    %eax,%edx
  801507:	eb 05                	jmp    80150e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801509:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80150e:	89 d0                	mov    %edx,%eax
  801510:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801513:	c9                   	leave  
  801514:	c3                   	ret    

00801515 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	53                   	push   %ebx
  801519:	83 ec 14             	sub    $0x14,%esp
  80151c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80151f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801522:	50                   	push   %eax
  801523:	ff 75 08             	pushl  0x8(%ebp)
  801526:	e8 6c fb ff ff       	call   801097 <fd_lookup>
  80152b:	83 c4 08             	add    $0x8,%esp
  80152e:	89 c2                	mov    %eax,%edx
  801530:	85 c0                	test   %eax,%eax
  801532:	78 58                	js     80158c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801534:	83 ec 08             	sub    $0x8,%esp
  801537:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80153a:	50                   	push   %eax
  80153b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153e:	ff 30                	pushl  (%eax)
  801540:	e8 a8 fb ff ff       	call   8010ed <dev_lookup>
  801545:	83 c4 10             	add    $0x10,%esp
  801548:	85 c0                	test   %eax,%eax
  80154a:	78 37                	js     801583 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80154c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80154f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801553:	74 32                	je     801587 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801555:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801558:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80155f:	00 00 00 
	stat->st_isdir = 0;
  801562:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801569:	00 00 00 
	stat->st_dev = dev;
  80156c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801572:	83 ec 08             	sub    $0x8,%esp
  801575:	53                   	push   %ebx
  801576:	ff 75 f0             	pushl  -0x10(%ebp)
  801579:	ff 50 14             	call   *0x14(%eax)
  80157c:	89 c2                	mov    %eax,%edx
  80157e:	83 c4 10             	add    $0x10,%esp
  801581:	eb 09                	jmp    80158c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801583:	89 c2                	mov    %eax,%edx
  801585:	eb 05                	jmp    80158c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801587:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80158c:	89 d0                	mov    %edx,%eax
  80158e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801591:	c9                   	leave  
  801592:	c3                   	ret    

00801593 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801593:	55                   	push   %ebp
  801594:	89 e5                	mov    %esp,%ebp
  801596:	56                   	push   %esi
  801597:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801598:	83 ec 08             	sub    $0x8,%esp
  80159b:	6a 00                	push   $0x0
  80159d:	ff 75 08             	pushl  0x8(%ebp)
  8015a0:	e8 e3 01 00 00       	call   801788 <open>
  8015a5:	89 c3                	mov    %eax,%ebx
  8015a7:	83 c4 10             	add    $0x10,%esp
  8015aa:	85 c0                	test   %eax,%eax
  8015ac:	78 1b                	js     8015c9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015ae:	83 ec 08             	sub    $0x8,%esp
  8015b1:	ff 75 0c             	pushl  0xc(%ebp)
  8015b4:	50                   	push   %eax
  8015b5:	e8 5b ff ff ff       	call   801515 <fstat>
  8015ba:	89 c6                	mov    %eax,%esi
	close(fd);
  8015bc:	89 1c 24             	mov    %ebx,(%esp)
  8015bf:	e8 fd fb ff ff       	call   8011c1 <close>
	return r;
  8015c4:	83 c4 10             	add    $0x10,%esp
  8015c7:	89 f0                	mov    %esi,%eax
}
  8015c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015cc:	5b                   	pop    %ebx
  8015cd:	5e                   	pop    %esi
  8015ce:	5d                   	pop    %ebp
  8015cf:	c3                   	ret    

008015d0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	56                   	push   %esi
  8015d4:	53                   	push   %ebx
  8015d5:	89 c6                	mov    %eax,%esi
  8015d7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015d9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015e0:	75 12                	jne    8015f4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015e2:	83 ec 0c             	sub    $0xc,%esp
  8015e5:	6a 01                	push   $0x1
  8015e7:	e8 da 08 00 00       	call   801ec6 <ipc_find_env>
  8015ec:	a3 00 40 80 00       	mov    %eax,0x804000
  8015f1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015f4:	6a 07                	push   $0x7
  8015f6:	68 00 50 80 00       	push   $0x805000
  8015fb:	56                   	push   %esi
  8015fc:	ff 35 00 40 80 00    	pushl  0x804000
  801602:	e8 5d 08 00 00       	call   801e64 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801607:	83 c4 0c             	add    $0xc,%esp
  80160a:	6a 00                	push   $0x0
  80160c:	53                   	push   %ebx
  80160d:	6a 00                	push   $0x0
  80160f:	e8 d5 07 00 00       	call   801de9 <ipc_recv>
}
  801614:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801617:	5b                   	pop    %ebx
  801618:	5e                   	pop    %esi
  801619:	5d                   	pop    %ebp
  80161a:	c3                   	ret    

0080161b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80161b:	55                   	push   %ebp
  80161c:	89 e5                	mov    %esp,%ebp
  80161e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801621:	8b 45 08             	mov    0x8(%ebp),%eax
  801624:	8b 40 0c             	mov    0xc(%eax),%eax
  801627:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80162c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80162f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801634:	ba 00 00 00 00       	mov    $0x0,%edx
  801639:	b8 02 00 00 00       	mov    $0x2,%eax
  80163e:	e8 8d ff ff ff       	call   8015d0 <fsipc>
}
  801643:	c9                   	leave  
  801644:	c3                   	ret    

00801645 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801645:	55                   	push   %ebp
  801646:	89 e5                	mov    %esp,%ebp
  801648:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80164b:	8b 45 08             	mov    0x8(%ebp),%eax
  80164e:	8b 40 0c             	mov    0xc(%eax),%eax
  801651:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801656:	ba 00 00 00 00       	mov    $0x0,%edx
  80165b:	b8 06 00 00 00       	mov    $0x6,%eax
  801660:	e8 6b ff ff ff       	call   8015d0 <fsipc>
}
  801665:	c9                   	leave  
  801666:	c3                   	ret    

00801667 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801667:	55                   	push   %ebp
  801668:	89 e5                	mov    %esp,%ebp
  80166a:	53                   	push   %ebx
  80166b:	83 ec 04             	sub    $0x4,%esp
  80166e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801671:	8b 45 08             	mov    0x8(%ebp),%eax
  801674:	8b 40 0c             	mov    0xc(%eax),%eax
  801677:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80167c:	ba 00 00 00 00       	mov    $0x0,%edx
  801681:	b8 05 00 00 00       	mov    $0x5,%eax
  801686:	e8 45 ff ff ff       	call   8015d0 <fsipc>
  80168b:	85 c0                	test   %eax,%eax
  80168d:	78 2c                	js     8016bb <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80168f:	83 ec 08             	sub    $0x8,%esp
  801692:	68 00 50 80 00       	push   $0x805000
  801697:	53                   	push   %ebx
  801698:	e8 5c f0 ff ff       	call   8006f9 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80169d:	a1 80 50 80 00       	mov    0x805080,%eax
  8016a2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016a8:	a1 84 50 80 00       	mov    0x805084,%eax
  8016ad:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016b3:	83 c4 10             	add    $0x10,%esp
  8016b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016be:	c9                   	leave  
  8016bf:	c3                   	ret    

008016c0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	83 ec 0c             	sub    $0xc,%esp
  8016c6:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8016cc:	8b 52 0c             	mov    0xc(%edx),%edx
  8016cf:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8016d5:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8016da:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8016df:	0f 47 c2             	cmova  %edx,%eax
  8016e2:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8016e7:	50                   	push   %eax
  8016e8:	ff 75 0c             	pushl  0xc(%ebp)
  8016eb:	68 08 50 80 00       	push   $0x805008
  8016f0:	e8 96 f1 ff ff       	call   80088b <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8016f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016fa:	b8 04 00 00 00       	mov    $0x4,%eax
  8016ff:	e8 cc fe ff ff       	call   8015d0 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801704:	c9                   	leave  
  801705:	c3                   	ret    

00801706 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801706:	55                   	push   %ebp
  801707:	89 e5                	mov    %esp,%ebp
  801709:	56                   	push   %esi
  80170a:	53                   	push   %ebx
  80170b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80170e:	8b 45 08             	mov    0x8(%ebp),%eax
  801711:	8b 40 0c             	mov    0xc(%eax),%eax
  801714:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801719:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80171f:	ba 00 00 00 00       	mov    $0x0,%edx
  801724:	b8 03 00 00 00       	mov    $0x3,%eax
  801729:	e8 a2 fe ff ff       	call   8015d0 <fsipc>
  80172e:	89 c3                	mov    %eax,%ebx
  801730:	85 c0                	test   %eax,%eax
  801732:	78 4b                	js     80177f <devfile_read+0x79>
		return r;
	assert(r <= n);
  801734:	39 c6                	cmp    %eax,%esi
  801736:	73 16                	jae    80174e <devfile_read+0x48>
  801738:	68 54 26 80 00       	push   $0x802654
  80173d:	68 5b 26 80 00       	push   $0x80265b
  801742:	6a 7c                	push   $0x7c
  801744:	68 70 26 80 00       	push   $0x802670
  801749:	e8 c6 05 00 00       	call   801d14 <_panic>
	assert(r <= PGSIZE);
  80174e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801753:	7e 16                	jle    80176b <devfile_read+0x65>
  801755:	68 7b 26 80 00       	push   $0x80267b
  80175a:	68 5b 26 80 00       	push   $0x80265b
  80175f:	6a 7d                	push   $0x7d
  801761:	68 70 26 80 00       	push   $0x802670
  801766:	e8 a9 05 00 00       	call   801d14 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80176b:	83 ec 04             	sub    $0x4,%esp
  80176e:	50                   	push   %eax
  80176f:	68 00 50 80 00       	push   $0x805000
  801774:	ff 75 0c             	pushl  0xc(%ebp)
  801777:	e8 0f f1 ff ff       	call   80088b <memmove>
	return r;
  80177c:	83 c4 10             	add    $0x10,%esp
}
  80177f:	89 d8                	mov    %ebx,%eax
  801781:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801784:	5b                   	pop    %ebx
  801785:	5e                   	pop    %esi
  801786:	5d                   	pop    %ebp
  801787:	c3                   	ret    

00801788 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801788:	55                   	push   %ebp
  801789:	89 e5                	mov    %esp,%ebp
  80178b:	53                   	push   %ebx
  80178c:	83 ec 20             	sub    $0x20,%esp
  80178f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801792:	53                   	push   %ebx
  801793:	e8 28 ef ff ff       	call   8006c0 <strlen>
  801798:	83 c4 10             	add    $0x10,%esp
  80179b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017a0:	7f 67                	jg     801809 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017a2:	83 ec 0c             	sub    $0xc,%esp
  8017a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a8:	50                   	push   %eax
  8017a9:	e8 9a f8 ff ff       	call   801048 <fd_alloc>
  8017ae:	83 c4 10             	add    $0x10,%esp
		return r;
  8017b1:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017b3:	85 c0                	test   %eax,%eax
  8017b5:	78 57                	js     80180e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017b7:	83 ec 08             	sub    $0x8,%esp
  8017ba:	53                   	push   %ebx
  8017bb:	68 00 50 80 00       	push   $0x805000
  8017c0:	e8 34 ef ff ff       	call   8006f9 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017c8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8017d5:	e8 f6 fd ff ff       	call   8015d0 <fsipc>
  8017da:	89 c3                	mov    %eax,%ebx
  8017dc:	83 c4 10             	add    $0x10,%esp
  8017df:	85 c0                	test   %eax,%eax
  8017e1:	79 14                	jns    8017f7 <open+0x6f>
		fd_close(fd, 0);
  8017e3:	83 ec 08             	sub    $0x8,%esp
  8017e6:	6a 00                	push   $0x0
  8017e8:	ff 75 f4             	pushl  -0xc(%ebp)
  8017eb:	e8 50 f9 ff ff       	call   801140 <fd_close>
		return r;
  8017f0:	83 c4 10             	add    $0x10,%esp
  8017f3:	89 da                	mov    %ebx,%edx
  8017f5:	eb 17                	jmp    80180e <open+0x86>
	}

	return fd2num(fd);
  8017f7:	83 ec 0c             	sub    $0xc,%esp
  8017fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8017fd:	e8 1f f8 ff ff       	call   801021 <fd2num>
  801802:	89 c2                	mov    %eax,%edx
  801804:	83 c4 10             	add    $0x10,%esp
  801807:	eb 05                	jmp    80180e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801809:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80180e:	89 d0                	mov    %edx,%eax
  801810:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801813:	c9                   	leave  
  801814:	c3                   	ret    

00801815 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801815:	55                   	push   %ebp
  801816:	89 e5                	mov    %esp,%ebp
  801818:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80181b:	ba 00 00 00 00       	mov    $0x0,%edx
  801820:	b8 08 00 00 00       	mov    $0x8,%eax
  801825:	e8 a6 fd ff ff       	call   8015d0 <fsipc>
}
  80182a:	c9                   	leave  
  80182b:	c3                   	ret    

0080182c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80182c:	55                   	push   %ebp
  80182d:	89 e5                	mov    %esp,%ebp
  80182f:	56                   	push   %esi
  801830:	53                   	push   %ebx
  801831:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801834:	83 ec 0c             	sub    $0xc,%esp
  801837:	ff 75 08             	pushl  0x8(%ebp)
  80183a:	e8 f2 f7 ff ff       	call   801031 <fd2data>
  80183f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801841:	83 c4 08             	add    $0x8,%esp
  801844:	68 87 26 80 00       	push   $0x802687
  801849:	53                   	push   %ebx
  80184a:	e8 aa ee ff ff       	call   8006f9 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80184f:	8b 46 04             	mov    0x4(%esi),%eax
  801852:	2b 06                	sub    (%esi),%eax
  801854:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80185a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801861:	00 00 00 
	stat->st_dev = &devpipe;
  801864:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80186b:	30 80 00 
	return 0;
}
  80186e:	b8 00 00 00 00       	mov    $0x0,%eax
  801873:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801876:	5b                   	pop    %ebx
  801877:	5e                   	pop    %esi
  801878:	5d                   	pop    %ebp
  801879:	c3                   	ret    

0080187a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80187a:	55                   	push   %ebp
  80187b:	89 e5                	mov    %esp,%ebp
  80187d:	53                   	push   %ebx
  80187e:	83 ec 0c             	sub    $0xc,%esp
  801881:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801884:	53                   	push   %ebx
  801885:	6a 00                	push   $0x0
  801887:	e8 f5 f2 ff ff       	call   800b81 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80188c:	89 1c 24             	mov    %ebx,(%esp)
  80188f:	e8 9d f7 ff ff       	call   801031 <fd2data>
  801894:	83 c4 08             	add    $0x8,%esp
  801897:	50                   	push   %eax
  801898:	6a 00                	push   $0x0
  80189a:	e8 e2 f2 ff ff       	call   800b81 <sys_page_unmap>
}
  80189f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a2:	c9                   	leave  
  8018a3:	c3                   	ret    

008018a4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018a4:	55                   	push   %ebp
  8018a5:	89 e5                	mov    %esp,%ebp
  8018a7:	57                   	push   %edi
  8018a8:	56                   	push   %esi
  8018a9:	53                   	push   %ebx
  8018aa:	83 ec 1c             	sub    $0x1c,%esp
  8018ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018b0:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8018b7:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8018bd:	83 ec 0c             	sub    $0xc,%esp
  8018c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8018c3:	e8 40 06 00 00       	call   801f08 <pageref>
  8018c8:	89 c3                	mov    %eax,%ebx
  8018ca:	89 3c 24             	mov    %edi,(%esp)
  8018cd:	e8 36 06 00 00       	call   801f08 <pageref>
  8018d2:	83 c4 10             	add    $0x10,%esp
  8018d5:	39 c3                	cmp    %eax,%ebx
  8018d7:	0f 94 c1             	sete   %cl
  8018da:	0f b6 c9             	movzbl %cl,%ecx
  8018dd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8018e0:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8018e6:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  8018ec:	39 ce                	cmp    %ecx,%esi
  8018ee:	74 1e                	je     80190e <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  8018f0:	39 c3                	cmp    %eax,%ebx
  8018f2:	75 be                	jne    8018b2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018f4:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  8018fa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018fd:	50                   	push   %eax
  8018fe:	56                   	push   %esi
  8018ff:	68 8e 26 80 00       	push   $0x80268e
  801904:	e8 6b e8 ff ff       	call   800174 <cprintf>
  801909:	83 c4 10             	add    $0x10,%esp
  80190c:	eb a4                	jmp    8018b2 <_pipeisclosed+0xe>
	}
}
  80190e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801911:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801914:	5b                   	pop    %ebx
  801915:	5e                   	pop    %esi
  801916:	5f                   	pop    %edi
  801917:	5d                   	pop    %ebp
  801918:	c3                   	ret    

00801919 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801919:	55                   	push   %ebp
  80191a:	89 e5                	mov    %esp,%ebp
  80191c:	57                   	push   %edi
  80191d:	56                   	push   %esi
  80191e:	53                   	push   %ebx
  80191f:	83 ec 28             	sub    $0x28,%esp
  801922:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801925:	56                   	push   %esi
  801926:	e8 06 f7 ff ff       	call   801031 <fd2data>
  80192b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80192d:	83 c4 10             	add    $0x10,%esp
  801930:	bf 00 00 00 00       	mov    $0x0,%edi
  801935:	eb 4b                	jmp    801982 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801937:	89 da                	mov    %ebx,%edx
  801939:	89 f0                	mov    %esi,%eax
  80193b:	e8 64 ff ff ff       	call   8018a4 <_pipeisclosed>
  801940:	85 c0                	test   %eax,%eax
  801942:	75 48                	jne    80198c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801944:	e8 94 f1 ff ff       	call   800add <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801949:	8b 43 04             	mov    0x4(%ebx),%eax
  80194c:	8b 0b                	mov    (%ebx),%ecx
  80194e:	8d 51 20             	lea    0x20(%ecx),%edx
  801951:	39 d0                	cmp    %edx,%eax
  801953:	73 e2                	jae    801937 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801955:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801958:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80195c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80195f:	89 c2                	mov    %eax,%edx
  801961:	c1 fa 1f             	sar    $0x1f,%edx
  801964:	89 d1                	mov    %edx,%ecx
  801966:	c1 e9 1b             	shr    $0x1b,%ecx
  801969:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80196c:	83 e2 1f             	and    $0x1f,%edx
  80196f:	29 ca                	sub    %ecx,%edx
  801971:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801975:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801979:	83 c0 01             	add    $0x1,%eax
  80197c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80197f:	83 c7 01             	add    $0x1,%edi
  801982:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801985:	75 c2                	jne    801949 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801987:	8b 45 10             	mov    0x10(%ebp),%eax
  80198a:	eb 05                	jmp    801991 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80198c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801991:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801994:	5b                   	pop    %ebx
  801995:	5e                   	pop    %esi
  801996:	5f                   	pop    %edi
  801997:	5d                   	pop    %ebp
  801998:	c3                   	ret    

00801999 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801999:	55                   	push   %ebp
  80199a:	89 e5                	mov    %esp,%ebp
  80199c:	57                   	push   %edi
  80199d:	56                   	push   %esi
  80199e:	53                   	push   %ebx
  80199f:	83 ec 18             	sub    $0x18,%esp
  8019a2:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019a5:	57                   	push   %edi
  8019a6:	e8 86 f6 ff ff       	call   801031 <fd2data>
  8019ab:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019ad:	83 c4 10             	add    $0x10,%esp
  8019b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019b5:	eb 3d                	jmp    8019f4 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019b7:	85 db                	test   %ebx,%ebx
  8019b9:	74 04                	je     8019bf <devpipe_read+0x26>
				return i;
  8019bb:	89 d8                	mov    %ebx,%eax
  8019bd:	eb 44                	jmp    801a03 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019bf:	89 f2                	mov    %esi,%edx
  8019c1:	89 f8                	mov    %edi,%eax
  8019c3:	e8 dc fe ff ff       	call   8018a4 <_pipeisclosed>
  8019c8:	85 c0                	test   %eax,%eax
  8019ca:	75 32                	jne    8019fe <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019cc:	e8 0c f1 ff ff       	call   800add <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019d1:	8b 06                	mov    (%esi),%eax
  8019d3:	3b 46 04             	cmp    0x4(%esi),%eax
  8019d6:	74 df                	je     8019b7 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019d8:	99                   	cltd   
  8019d9:	c1 ea 1b             	shr    $0x1b,%edx
  8019dc:	01 d0                	add    %edx,%eax
  8019de:	83 e0 1f             	and    $0x1f,%eax
  8019e1:	29 d0                	sub    %edx,%eax
  8019e3:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8019e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019eb:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8019ee:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019f1:	83 c3 01             	add    $0x1,%ebx
  8019f4:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019f7:	75 d8                	jne    8019d1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8019fc:	eb 05                	jmp    801a03 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019fe:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a06:	5b                   	pop    %ebx
  801a07:	5e                   	pop    %esi
  801a08:	5f                   	pop    %edi
  801a09:	5d                   	pop    %ebp
  801a0a:	c3                   	ret    

00801a0b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a0b:	55                   	push   %ebp
  801a0c:	89 e5                	mov    %esp,%ebp
  801a0e:	56                   	push   %esi
  801a0f:	53                   	push   %ebx
  801a10:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a13:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a16:	50                   	push   %eax
  801a17:	e8 2c f6 ff ff       	call   801048 <fd_alloc>
  801a1c:	83 c4 10             	add    $0x10,%esp
  801a1f:	89 c2                	mov    %eax,%edx
  801a21:	85 c0                	test   %eax,%eax
  801a23:	0f 88 2c 01 00 00    	js     801b55 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a29:	83 ec 04             	sub    $0x4,%esp
  801a2c:	68 07 04 00 00       	push   $0x407
  801a31:	ff 75 f4             	pushl  -0xc(%ebp)
  801a34:	6a 00                	push   $0x0
  801a36:	e8 c1 f0 ff ff       	call   800afc <sys_page_alloc>
  801a3b:	83 c4 10             	add    $0x10,%esp
  801a3e:	89 c2                	mov    %eax,%edx
  801a40:	85 c0                	test   %eax,%eax
  801a42:	0f 88 0d 01 00 00    	js     801b55 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a48:	83 ec 0c             	sub    $0xc,%esp
  801a4b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a4e:	50                   	push   %eax
  801a4f:	e8 f4 f5 ff ff       	call   801048 <fd_alloc>
  801a54:	89 c3                	mov    %eax,%ebx
  801a56:	83 c4 10             	add    $0x10,%esp
  801a59:	85 c0                	test   %eax,%eax
  801a5b:	0f 88 e2 00 00 00    	js     801b43 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a61:	83 ec 04             	sub    $0x4,%esp
  801a64:	68 07 04 00 00       	push   $0x407
  801a69:	ff 75 f0             	pushl  -0x10(%ebp)
  801a6c:	6a 00                	push   $0x0
  801a6e:	e8 89 f0 ff ff       	call   800afc <sys_page_alloc>
  801a73:	89 c3                	mov    %eax,%ebx
  801a75:	83 c4 10             	add    $0x10,%esp
  801a78:	85 c0                	test   %eax,%eax
  801a7a:	0f 88 c3 00 00 00    	js     801b43 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a80:	83 ec 0c             	sub    $0xc,%esp
  801a83:	ff 75 f4             	pushl  -0xc(%ebp)
  801a86:	e8 a6 f5 ff ff       	call   801031 <fd2data>
  801a8b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a8d:	83 c4 0c             	add    $0xc,%esp
  801a90:	68 07 04 00 00       	push   $0x407
  801a95:	50                   	push   %eax
  801a96:	6a 00                	push   $0x0
  801a98:	e8 5f f0 ff ff       	call   800afc <sys_page_alloc>
  801a9d:	89 c3                	mov    %eax,%ebx
  801a9f:	83 c4 10             	add    $0x10,%esp
  801aa2:	85 c0                	test   %eax,%eax
  801aa4:	0f 88 89 00 00 00    	js     801b33 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aaa:	83 ec 0c             	sub    $0xc,%esp
  801aad:	ff 75 f0             	pushl  -0x10(%ebp)
  801ab0:	e8 7c f5 ff ff       	call   801031 <fd2data>
  801ab5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801abc:	50                   	push   %eax
  801abd:	6a 00                	push   $0x0
  801abf:	56                   	push   %esi
  801ac0:	6a 00                	push   $0x0
  801ac2:	e8 78 f0 ff ff       	call   800b3f <sys_page_map>
  801ac7:	89 c3                	mov    %eax,%ebx
  801ac9:	83 c4 20             	add    $0x20,%esp
  801acc:	85 c0                	test   %eax,%eax
  801ace:	78 55                	js     801b25 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ad0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ade:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ae5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801aeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aee:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801af0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801af3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801afa:	83 ec 0c             	sub    $0xc,%esp
  801afd:	ff 75 f4             	pushl  -0xc(%ebp)
  801b00:	e8 1c f5 ff ff       	call   801021 <fd2num>
  801b05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b08:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b0a:	83 c4 04             	add    $0x4,%esp
  801b0d:	ff 75 f0             	pushl  -0x10(%ebp)
  801b10:	e8 0c f5 ff ff       	call   801021 <fd2num>
  801b15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b18:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801b1b:	83 c4 10             	add    $0x10,%esp
  801b1e:	ba 00 00 00 00       	mov    $0x0,%edx
  801b23:	eb 30                	jmp    801b55 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b25:	83 ec 08             	sub    $0x8,%esp
  801b28:	56                   	push   %esi
  801b29:	6a 00                	push   $0x0
  801b2b:	e8 51 f0 ff ff       	call   800b81 <sys_page_unmap>
  801b30:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b33:	83 ec 08             	sub    $0x8,%esp
  801b36:	ff 75 f0             	pushl  -0x10(%ebp)
  801b39:	6a 00                	push   $0x0
  801b3b:	e8 41 f0 ff ff       	call   800b81 <sys_page_unmap>
  801b40:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b43:	83 ec 08             	sub    $0x8,%esp
  801b46:	ff 75 f4             	pushl  -0xc(%ebp)
  801b49:	6a 00                	push   $0x0
  801b4b:	e8 31 f0 ff ff       	call   800b81 <sys_page_unmap>
  801b50:	83 c4 10             	add    $0x10,%esp
  801b53:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b55:	89 d0                	mov    %edx,%eax
  801b57:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b5a:	5b                   	pop    %ebx
  801b5b:	5e                   	pop    %esi
  801b5c:	5d                   	pop    %ebp
  801b5d:	c3                   	ret    

00801b5e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b5e:	55                   	push   %ebp
  801b5f:	89 e5                	mov    %esp,%ebp
  801b61:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b67:	50                   	push   %eax
  801b68:	ff 75 08             	pushl  0x8(%ebp)
  801b6b:	e8 27 f5 ff ff       	call   801097 <fd_lookup>
  801b70:	83 c4 10             	add    $0x10,%esp
  801b73:	85 c0                	test   %eax,%eax
  801b75:	78 18                	js     801b8f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b77:	83 ec 0c             	sub    $0xc,%esp
  801b7a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b7d:	e8 af f4 ff ff       	call   801031 <fd2data>
	return _pipeisclosed(fd, p);
  801b82:	89 c2                	mov    %eax,%edx
  801b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b87:	e8 18 fd ff ff       	call   8018a4 <_pipeisclosed>
  801b8c:	83 c4 10             	add    $0x10,%esp
}
  801b8f:	c9                   	leave  
  801b90:	c3                   	ret    

00801b91 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b91:	55                   	push   %ebp
  801b92:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b94:	b8 00 00 00 00       	mov    $0x0,%eax
  801b99:	5d                   	pop    %ebp
  801b9a:	c3                   	ret    

00801b9b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b9b:	55                   	push   %ebp
  801b9c:	89 e5                	mov    %esp,%ebp
  801b9e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ba1:	68 a6 26 80 00       	push   $0x8026a6
  801ba6:	ff 75 0c             	pushl  0xc(%ebp)
  801ba9:	e8 4b eb ff ff       	call   8006f9 <strcpy>
	return 0;
}
  801bae:	b8 00 00 00 00       	mov    $0x0,%eax
  801bb3:	c9                   	leave  
  801bb4:	c3                   	ret    

00801bb5 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bb5:	55                   	push   %ebp
  801bb6:	89 e5                	mov    %esp,%ebp
  801bb8:	57                   	push   %edi
  801bb9:	56                   	push   %esi
  801bba:	53                   	push   %ebx
  801bbb:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bc1:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bc6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bcc:	eb 2d                	jmp    801bfb <devcons_write+0x46>
		m = n - tot;
  801bce:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801bd1:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801bd3:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801bd6:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801bdb:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bde:	83 ec 04             	sub    $0x4,%esp
  801be1:	53                   	push   %ebx
  801be2:	03 45 0c             	add    0xc(%ebp),%eax
  801be5:	50                   	push   %eax
  801be6:	57                   	push   %edi
  801be7:	e8 9f ec ff ff       	call   80088b <memmove>
		sys_cputs(buf, m);
  801bec:	83 c4 08             	add    $0x8,%esp
  801bef:	53                   	push   %ebx
  801bf0:	57                   	push   %edi
  801bf1:	e8 4a ee ff ff       	call   800a40 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bf6:	01 de                	add    %ebx,%esi
  801bf8:	83 c4 10             	add    $0x10,%esp
  801bfb:	89 f0                	mov    %esi,%eax
  801bfd:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c00:	72 cc                	jb     801bce <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c05:	5b                   	pop    %ebx
  801c06:	5e                   	pop    %esi
  801c07:	5f                   	pop    %edi
  801c08:	5d                   	pop    %ebp
  801c09:	c3                   	ret    

00801c0a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c0a:	55                   	push   %ebp
  801c0b:	89 e5                	mov    %esp,%ebp
  801c0d:	83 ec 08             	sub    $0x8,%esp
  801c10:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c15:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c19:	74 2a                	je     801c45 <devcons_read+0x3b>
  801c1b:	eb 05                	jmp    801c22 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c1d:	e8 bb ee ff ff       	call   800add <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c22:	e8 37 ee ff ff       	call   800a5e <sys_cgetc>
  801c27:	85 c0                	test   %eax,%eax
  801c29:	74 f2                	je     801c1d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c2b:	85 c0                	test   %eax,%eax
  801c2d:	78 16                	js     801c45 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c2f:	83 f8 04             	cmp    $0x4,%eax
  801c32:	74 0c                	je     801c40 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c34:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c37:	88 02                	mov    %al,(%edx)
	return 1;
  801c39:	b8 01 00 00 00       	mov    $0x1,%eax
  801c3e:	eb 05                	jmp    801c45 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c40:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c45:	c9                   	leave  
  801c46:	c3                   	ret    

00801c47 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c47:	55                   	push   %ebp
  801c48:	89 e5                	mov    %esp,%ebp
  801c4a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c50:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c53:	6a 01                	push   $0x1
  801c55:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c58:	50                   	push   %eax
  801c59:	e8 e2 ed ff ff       	call   800a40 <sys_cputs>
}
  801c5e:	83 c4 10             	add    $0x10,%esp
  801c61:	c9                   	leave  
  801c62:	c3                   	ret    

00801c63 <getchar>:

int
getchar(void)
{
  801c63:	55                   	push   %ebp
  801c64:	89 e5                	mov    %esp,%ebp
  801c66:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c69:	6a 01                	push   $0x1
  801c6b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c6e:	50                   	push   %eax
  801c6f:	6a 00                	push   $0x0
  801c71:	e8 87 f6 ff ff       	call   8012fd <read>
	if (r < 0)
  801c76:	83 c4 10             	add    $0x10,%esp
  801c79:	85 c0                	test   %eax,%eax
  801c7b:	78 0f                	js     801c8c <getchar+0x29>
		return r;
	if (r < 1)
  801c7d:	85 c0                	test   %eax,%eax
  801c7f:	7e 06                	jle    801c87 <getchar+0x24>
		return -E_EOF;
	return c;
  801c81:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c85:	eb 05                	jmp    801c8c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c87:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c8c:	c9                   	leave  
  801c8d:	c3                   	ret    

00801c8e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c8e:	55                   	push   %ebp
  801c8f:	89 e5                	mov    %esp,%ebp
  801c91:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c94:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c97:	50                   	push   %eax
  801c98:	ff 75 08             	pushl  0x8(%ebp)
  801c9b:	e8 f7 f3 ff ff       	call   801097 <fd_lookup>
  801ca0:	83 c4 10             	add    $0x10,%esp
  801ca3:	85 c0                	test   %eax,%eax
  801ca5:	78 11                	js     801cb8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801caa:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cb0:	39 10                	cmp    %edx,(%eax)
  801cb2:	0f 94 c0             	sete   %al
  801cb5:	0f b6 c0             	movzbl %al,%eax
}
  801cb8:	c9                   	leave  
  801cb9:	c3                   	ret    

00801cba <opencons>:

int
opencons(void)
{
  801cba:	55                   	push   %ebp
  801cbb:	89 e5                	mov    %esp,%ebp
  801cbd:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cc0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cc3:	50                   	push   %eax
  801cc4:	e8 7f f3 ff ff       	call   801048 <fd_alloc>
  801cc9:	83 c4 10             	add    $0x10,%esp
		return r;
  801ccc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cce:	85 c0                	test   %eax,%eax
  801cd0:	78 3e                	js     801d10 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cd2:	83 ec 04             	sub    $0x4,%esp
  801cd5:	68 07 04 00 00       	push   $0x407
  801cda:	ff 75 f4             	pushl  -0xc(%ebp)
  801cdd:	6a 00                	push   $0x0
  801cdf:	e8 18 ee ff ff       	call   800afc <sys_page_alloc>
  801ce4:	83 c4 10             	add    $0x10,%esp
		return r;
  801ce7:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ce9:	85 c0                	test   %eax,%eax
  801ceb:	78 23                	js     801d10 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ced:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801cf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cfb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d02:	83 ec 0c             	sub    $0xc,%esp
  801d05:	50                   	push   %eax
  801d06:	e8 16 f3 ff ff       	call   801021 <fd2num>
  801d0b:	89 c2                	mov    %eax,%edx
  801d0d:	83 c4 10             	add    $0x10,%esp
}
  801d10:	89 d0                	mov    %edx,%eax
  801d12:	c9                   	leave  
  801d13:	c3                   	ret    

00801d14 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d14:	55                   	push   %ebp
  801d15:	89 e5                	mov    %esp,%ebp
  801d17:	56                   	push   %esi
  801d18:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d19:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d1c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d22:	e8 97 ed ff ff       	call   800abe <sys_getenvid>
  801d27:	83 ec 0c             	sub    $0xc,%esp
  801d2a:	ff 75 0c             	pushl  0xc(%ebp)
  801d2d:	ff 75 08             	pushl  0x8(%ebp)
  801d30:	56                   	push   %esi
  801d31:	50                   	push   %eax
  801d32:	68 b4 26 80 00       	push   $0x8026b4
  801d37:	e8 38 e4 ff ff       	call   800174 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d3c:	83 c4 18             	add    $0x18,%esp
  801d3f:	53                   	push   %ebx
  801d40:	ff 75 10             	pushl  0x10(%ebp)
  801d43:	e8 db e3 ff ff       	call   800123 <vcprintf>
	cprintf("\n");
  801d48:	c7 04 24 9f 26 80 00 	movl   $0x80269f,(%esp)
  801d4f:	e8 20 e4 ff ff       	call   800174 <cprintf>
  801d54:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d57:	cc                   	int3   
  801d58:	eb fd                	jmp    801d57 <_panic+0x43>

00801d5a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d5a:	55                   	push   %ebp
  801d5b:	89 e5                	mov    %esp,%ebp
  801d5d:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d60:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d67:	75 2a                	jne    801d93 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d69:	83 ec 04             	sub    $0x4,%esp
  801d6c:	6a 07                	push   $0x7
  801d6e:	68 00 f0 bf ee       	push   $0xeebff000
  801d73:	6a 00                	push   $0x0
  801d75:	e8 82 ed ff ff       	call   800afc <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801d7a:	83 c4 10             	add    $0x10,%esp
  801d7d:	85 c0                	test   %eax,%eax
  801d7f:	79 12                	jns    801d93 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801d81:	50                   	push   %eax
  801d82:	68 d8 26 80 00       	push   $0x8026d8
  801d87:	6a 23                	push   $0x23
  801d89:	68 dc 26 80 00       	push   $0x8026dc
  801d8e:	e8 81 ff ff ff       	call   801d14 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d93:	8b 45 08             	mov    0x8(%ebp),%eax
  801d96:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801d9b:	83 ec 08             	sub    $0x8,%esp
  801d9e:	68 c5 1d 80 00       	push   $0x801dc5
  801da3:	6a 00                	push   $0x0
  801da5:	e8 9d ee ff ff       	call   800c47 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801daa:	83 c4 10             	add    $0x10,%esp
  801dad:	85 c0                	test   %eax,%eax
  801daf:	79 12                	jns    801dc3 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801db1:	50                   	push   %eax
  801db2:	68 d8 26 80 00       	push   $0x8026d8
  801db7:	6a 2c                	push   $0x2c
  801db9:	68 dc 26 80 00       	push   $0x8026dc
  801dbe:	e8 51 ff ff ff       	call   801d14 <_panic>
	}
}
  801dc3:	c9                   	leave  
  801dc4:	c3                   	ret    

00801dc5 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801dc5:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801dc6:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801dcb:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801dcd:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801dd0:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801dd4:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801dd9:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801ddd:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801ddf:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801de2:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801de3:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801de6:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801de7:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801de8:	c3                   	ret    

00801de9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801de9:	55                   	push   %ebp
  801dea:	89 e5                	mov    %esp,%ebp
  801dec:	56                   	push   %esi
  801ded:	53                   	push   %ebx
  801dee:	8b 75 08             	mov    0x8(%ebp),%esi
  801df1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801df7:	85 c0                	test   %eax,%eax
  801df9:	75 12                	jne    801e0d <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801dfb:	83 ec 0c             	sub    $0xc,%esp
  801dfe:	68 00 00 c0 ee       	push   $0xeec00000
  801e03:	e8 a4 ee ff ff       	call   800cac <sys_ipc_recv>
  801e08:	83 c4 10             	add    $0x10,%esp
  801e0b:	eb 0c                	jmp    801e19 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e0d:	83 ec 0c             	sub    $0xc,%esp
  801e10:	50                   	push   %eax
  801e11:	e8 96 ee ff ff       	call   800cac <sys_ipc_recv>
  801e16:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e19:	85 f6                	test   %esi,%esi
  801e1b:	0f 95 c1             	setne  %cl
  801e1e:	85 db                	test   %ebx,%ebx
  801e20:	0f 95 c2             	setne  %dl
  801e23:	84 d1                	test   %dl,%cl
  801e25:	74 09                	je     801e30 <ipc_recv+0x47>
  801e27:	89 c2                	mov    %eax,%edx
  801e29:	c1 ea 1f             	shr    $0x1f,%edx
  801e2c:	84 d2                	test   %dl,%dl
  801e2e:	75 2d                	jne    801e5d <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e30:	85 f6                	test   %esi,%esi
  801e32:	74 0d                	je     801e41 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e34:	a1 04 40 80 00       	mov    0x804004,%eax
  801e39:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  801e3f:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e41:	85 db                	test   %ebx,%ebx
  801e43:	74 0d                	je     801e52 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e45:	a1 04 40 80 00       	mov    0x804004,%eax
  801e4a:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  801e50:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e52:	a1 04 40 80 00       	mov    0x804004,%eax
  801e57:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  801e5d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e60:	5b                   	pop    %ebx
  801e61:	5e                   	pop    %esi
  801e62:	5d                   	pop    %ebp
  801e63:	c3                   	ret    

00801e64 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e64:	55                   	push   %ebp
  801e65:	89 e5                	mov    %esp,%ebp
  801e67:	57                   	push   %edi
  801e68:	56                   	push   %esi
  801e69:	53                   	push   %ebx
  801e6a:	83 ec 0c             	sub    $0xc,%esp
  801e6d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e70:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e73:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801e76:	85 db                	test   %ebx,%ebx
  801e78:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e7d:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e80:	ff 75 14             	pushl  0x14(%ebp)
  801e83:	53                   	push   %ebx
  801e84:	56                   	push   %esi
  801e85:	57                   	push   %edi
  801e86:	e8 fe ed ff ff       	call   800c89 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801e8b:	89 c2                	mov    %eax,%edx
  801e8d:	c1 ea 1f             	shr    $0x1f,%edx
  801e90:	83 c4 10             	add    $0x10,%esp
  801e93:	84 d2                	test   %dl,%dl
  801e95:	74 17                	je     801eae <ipc_send+0x4a>
  801e97:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e9a:	74 12                	je     801eae <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801e9c:	50                   	push   %eax
  801e9d:	68 ea 26 80 00       	push   $0x8026ea
  801ea2:	6a 47                	push   $0x47
  801ea4:	68 f8 26 80 00       	push   $0x8026f8
  801ea9:	e8 66 fe ff ff       	call   801d14 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801eae:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801eb1:	75 07                	jne    801eba <ipc_send+0x56>
			sys_yield();
  801eb3:	e8 25 ec ff ff       	call   800add <sys_yield>
  801eb8:	eb c6                	jmp    801e80 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801eba:	85 c0                	test   %eax,%eax
  801ebc:	75 c2                	jne    801e80 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801ebe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ec1:	5b                   	pop    %ebx
  801ec2:	5e                   	pop    %esi
  801ec3:	5f                   	pop    %edi
  801ec4:	5d                   	pop    %ebp
  801ec5:	c3                   	ret    

00801ec6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ec6:	55                   	push   %ebp
  801ec7:	89 e5                	mov    %esp,%ebp
  801ec9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ecc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ed1:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  801ed7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801edd:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801ee3:	39 ca                	cmp    %ecx,%edx
  801ee5:	75 10                	jne    801ef7 <ipc_find_env+0x31>
			return envs[i].env_id;
  801ee7:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  801eed:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ef2:	8b 40 7c             	mov    0x7c(%eax),%eax
  801ef5:	eb 0f                	jmp    801f06 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ef7:	83 c0 01             	add    $0x1,%eax
  801efa:	3d 00 04 00 00       	cmp    $0x400,%eax
  801eff:	75 d0                	jne    801ed1 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f01:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f06:	5d                   	pop    %ebp
  801f07:	c3                   	ret    

00801f08 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f08:	55                   	push   %ebp
  801f09:	89 e5                	mov    %esp,%ebp
  801f0b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f0e:	89 d0                	mov    %edx,%eax
  801f10:	c1 e8 16             	shr    $0x16,%eax
  801f13:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f1a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f1f:	f6 c1 01             	test   $0x1,%cl
  801f22:	74 1d                	je     801f41 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f24:	c1 ea 0c             	shr    $0xc,%edx
  801f27:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f2e:	f6 c2 01             	test   $0x1,%dl
  801f31:	74 0e                	je     801f41 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f33:	c1 ea 0c             	shr    $0xc,%edx
  801f36:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f3d:	ef 
  801f3e:	0f b7 c0             	movzwl %ax,%eax
}
  801f41:	5d                   	pop    %ebp
  801f42:	c3                   	ret    
  801f43:	66 90                	xchg   %ax,%ax
  801f45:	66 90                	xchg   %ax,%ax
  801f47:	66 90                	xchg   %ax,%ax
  801f49:	66 90                	xchg   %ax,%ax
  801f4b:	66 90                	xchg   %ax,%ax
  801f4d:	66 90                	xchg   %ax,%ax
  801f4f:	90                   	nop

00801f50 <__udivdi3>:
  801f50:	55                   	push   %ebp
  801f51:	57                   	push   %edi
  801f52:	56                   	push   %esi
  801f53:	53                   	push   %ebx
  801f54:	83 ec 1c             	sub    $0x1c,%esp
  801f57:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f5b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f5f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f67:	85 f6                	test   %esi,%esi
  801f69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f6d:	89 ca                	mov    %ecx,%edx
  801f6f:	89 f8                	mov    %edi,%eax
  801f71:	75 3d                	jne    801fb0 <__udivdi3+0x60>
  801f73:	39 cf                	cmp    %ecx,%edi
  801f75:	0f 87 c5 00 00 00    	ja     802040 <__udivdi3+0xf0>
  801f7b:	85 ff                	test   %edi,%edi
  801f7d:	89 fd                	mov    %edi,%ebp
  801f7f:	75 0b                	jne    801f8c <__udivdi3+0x3c>
  801f81:	b8 01 00 00 00       	mov    $0x1,%eax
  801f86:	31 d2                	xor    %edx,%edx
  801f88:	f7 f7                	div    %edi
  801f8a:	89 c5                	mov    %eax,%ebp
  801f8c:	89 c8                	mov    %ecx,%eax
  801f8e:	31 d2                	xor    %edx,%edx
  801f90:	f7 f5                	div    %ebp
  801f92:	89 c1                	mov    %eax,%ecx
  801f94:	89 d8                	mov    %ebx,%eax
  801f96:	89 cf                	mov    %ecx,%edi
  801f98:	f7 f5                	div    %ebp
  801f9a:	89 c3                	mov    %eax,%ebx
  801f9c:	89 d8                	mov    %ebx,%eax
  801f9e:	89 fa                	mov    %edi,%edx
  801fa0:	83 c4 1c             	add    $0x1c,%esp
  801fa3:	5b                   	pop    %ebx
  801fa4:	5e                   	pop    %esi
  801fa5:	5f                   	pop    %edi
  801fa6:	5d                   	pop    %ebp
  801fa7:	c3                   	ret    
  801fa8:	90                   	nop
  801fa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fb0:	39 ce                	cmp    %ecx,%esi
  801fb2:	77 74                	ja     802028 <__udivdi3+0xd8>
  801fb4:	0f bd fe             	bsr    %esi,%edi
  801fb7:	83 f7 1f             	xor    $0x1f,%edi
  801fba:	0f 84 98 00 00 00    	je     802058 <__udivdi3+0x108>
  801fc0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fc5:	89 f9                	mov    %edi,%ecx
  801fc7:	89 c5                	mov    %eax,%ebp
  801fc9:	29 fb                	sub    %edi,%ebx
  801fcb:	d3 e6                	shl    %cl,%esi
  801fcd:	89 d9                	mov    %ebx,%ecx
  801fcf:	d3 ed                	shr    %cl,%ebp
  801fd1:	89 f9                	mov    %edi,%ecx
  801fd3:	d3 e0                	shl    %cl,%eax
  801fd5:	09 ee                	or     %ebp,%esi
  801fd7:	89 d9                	mov    %ebx,%ecx
  801fd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fdd:	89 d5                	mov    %edx,%ebp
  801fdf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fe3:	d3 ed                	shr    %cl,%ebp
  801fe5:	89 f9                	mov    %edi,%ecx
  801fe7:	d3 e2                	shl    %cl,%edx
  801fe9:	89 d9                	mov    %ebx,%ecx
  801feb:	d3 e8                	shr    %cl,%eax
  801fed:	09 c2                	or     %eax,%edx
  801fef:	89 d0                	mov    %edx,%eax
  801ff1:	89 ea                	mov    %ebp,%edx
  801ff3:	f7 f6                	div    %esi
  801ff5:	89 d5                	mov    %edx,%ebp
  801ff7:	89 c3                	mov    %eax,%ebx
  801ff9:	f7 64 24 0c          	mull   0xc(%esp)
  801ffd:	39 d5                	cmp    %edx,%ebp
  801fff:	72 10                	jb     802011 <__udivdi3+0xc1>
  802001:	8b 74 24 08          	mov    0x8(%esp),%esi
  802005:	89 f9                	mov    %edi,%ecx
  802007:	d3 e6                	shl    %cl,%esi
  802009:	39 c6                	cmp    %eax,%esi
  80200b:	73 07                	jae    802014 <__udivdi3+0xc4>
  80200d:	39 d5                	cmp    %edx,%ebp
  80200f:	75 03                	jne    802014 <__udivdi3+0xc4>
  802011:	83 eb 01             	sub    $0x1,%ebx
  802014:	31 ff                	xor    %edi,%edi
  802016:	89 d8                	mov    %ebx,%eax
  802018:	89 fa                	mov    %edi,%edx
  80201a:	83 c4 1c             	add    $0x1c,%esp
  80201d:	5b                   	pop    %ebx
  80201e:	5e                   	pop    %esi
  80201f:	5f                   	pop    %edi
  802020:	5d                   	pop    %ebp
  802021:	c3                   	ret    
  802022:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802028:	31 ff                	xor    %edi,%edi
  80202a:	31 db                	xor    %ebx,%ebx
  80202c:	89 d8                	mov    %ebx,%eax
  80202e:	89 fa                	mov    %edi,%edx
  802030:	83 c4 1c             	add    $0x1c,%esp
  802033:	5b                   	pop    %ebx
  802034:	5e                   	pop    %esi
  802035:	5f                   	pop    %edi
  802036:	5d                   	pop    %ebp
  802037:	c3                   	ret    
  802038:	90                   	nop
  802039:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802040:	89 d8                	mov    %ebx,%eax
  802042:	f7 f7                	div    %edi
  802044:	31 ff                	xor    %edi,%edi
  802046:	89 c3                	mov    %eax,%ebx
  802048:	89 d8                	mov    %ebx,%eax
  80204a:	89 fa                	mov    %edi,%edx
  80204c:	83 c4 1c             	add    $0x1c,%esp
  80204f:	5b                   	pop    %ebx
  802050:	5e                   	pop    %esi
  802051:	5f                   	pop    %edi
  802052:	5d                   	pop    %ebp
  802053:	c3                   	ret    
  802054:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802058:	39 ce                	cmp    %ecx,%esi
  80205a:	72 0c                	jb     802068 <__udivdi3+0x118>
  80205c:	31 db                	xor    %ebx,%ebx
  80205e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802062:	0f 87 34 ff ff ff    	ja     801f9c <__udivdi3+0x4c>
  802068:	bb 01 00 00 00       	mov    $0x1,%ebx
  80206d:	e9 2a ff ff ff       	jmp    801f9c <__udivdi3+0x4c>
  802072:	66 90                	xchg   %ax,%ax
  802074:	66 90                	xchg   %ax,%ax
  802076:	66 90                	xchg   %ax,%ax
  802078:	66 90                	xchg   %ax,%ax
  80207a:	66 90                	xchg   %ax,%ax
  80207c:	66 90                	xchg   %ax,%ax
  80207e:	66 90                	xchg   %ax,%ax

00802080 <__umoddi3>:
  802080:	55                   	push   %ebp
  802081:	57                   	push   %edi
  802082:	56                   	push   %esi
  802083:	53                   	push   %ebx
  802084:	83 ec 1c             	sub    $0x1c,%esp
  802087:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80208b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80208f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802093:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802097:	85 d2                	test   %edx,%edx
  802099:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80209d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020a1:	89 f3                	mov    %esi,%ebx
  8020a3:	89 3c 24             	mov    %edi,(%esp)
  8020a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020aa:	75 1c                	jne    8020c8 <__umoddi3+0x48>
  8020ac:	39 f7                	cmp    %esi,%edi
  8020ae:	76 50                	jbe    802100 <__umoddi3+0x80>
  8020b0:	89 c8                	mov    %ecx,%eax
  8020b2:	89 f2                	mov    %esi,%edx
  8020b4:	f7 f7                	div    %edi
  8020b6:	89 d0                	mov    %edx,%eax
  8020b8:	31 d2                	xor    %edx,%edx
  8020ba:	83 c4 1c             	add    $0x1c,%esp
  8020bd:	5b                   	pop    %ebx
  8020be:	5e                   	pop    %esi
  8020bf:	5f                   	pop    %edi
  8020c0:	5d                   	pop    %ebp
  8020c1:	c3                   	ret    
  8020c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020c8:	39 f2                	cmp    %esi,%edx
  8020ca:	89 d0                	mov    %edx,%eax
  8020cc:	77 52                	ja     802120 <__umoddi3+0xa0>
  8020ce:	0f bd ea             	bsr    %edx,%ebp
  8020d1:	83 f5 1f             	xor    $0x1f,%ebp
  8020d4:	75 5a                	jne    802130 <__umoddi3+0xb0>
  8020d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020da:	0f 82 e0 00 00 00    	jb     8021c0 <__umoddi3+0x140>
  8020e0:	39 0c 24             	cmp    %ecx,(%esp)
  8020e3:	0f 86 d7 00 00 00    	jbe    8021c0 <__umoddi3+0x140>
  8020e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020f1:	83 c4 1c             	add    $0x1c,%esp
  8020f4:	5b                   	pop    %ebx
  8020f5:	5e                   	pop    %esi
  8020f6:	5f                   	pop    %edi
  8020f7:	5d                   	pop    %ebp
  8020f8:	c3                   	ret    
  8020f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802100:	85 ff                	test   %edi,%edi
  802102:	89 fd                	mov    %edi,%ebp
  802104:	75 0b                	jne    802111 <__umoddi3+0x91>
  802106:	b8 01 00 00 00       	mov    $0x1,%eax
  80210b:	31 d2                	xor    %edx,%edx
  80210d:	f7 f7                	div    %edi
  80210f:	89 c5                	mov    %eax,%ebp
  802111:	89 f0                	mov    %esi,%eax
  802113:	31 d2                	xor    %edx,%edx
  802115:	f7 f5                	div    %ebp
  802117:	89 c8                	mov    %ecx,%eax
  802119:	f7 f5                	div    %ebp
  80211b:	89 d0                	mov    %edx,%eax
  80211d:	eb 99                	jmp    8020b8 <__umoddi3+0x38>
  80211f:	90                   	nop
  802120:	89 c8                	mov    %ecx,%eax
  802122:	89 f2                	mov    %esi,%edx
  802124:	83 c4 1c             	add    $0x1c,%esp
  802127:	5b                   	pop    %ebx
  802128:	5e                   	pop    %esi
  802129:	5f                   	pop    %edi
  80212a:	5d                   	pop    %ebp
  80212b:	c3                   	ret    
  80212c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802130:	8b 34 24             	mov    (%esp),%esi
  802133:	bf 20 00 00 00       	mov    $0x20,%edi
  802138:	89 e9                	mov    %ebp,%ecx
  80213a:	29 ef                	sub    %ebp,%edi
  80213c:	d3 e0                	shl    %cl,%eax
  80213e:	89 f9                	mov    %edi,%ecx
  802140:	89 f2                	mov    %esi,%edx
  802142:	d3 ea                	shr    %cl,%edx
  802144:	89 e9                	mov    %ebp,%ecx
  802146:	09 c2                	or     %eax,%edx
  802148:	89 d8                	mov    %ebx,%eax
  80214a:	89 14 24             	mov    %edx,(%esp)
  80214d:	89 f2                	mov    %esi,%edx
  80214f:	d3 e2                	shl    %cl,%edx
  802151:	89 f9                	mov    %edi,%ecx
  802153:	89 54 24 04          	mov    %edx,0x4(%esp)
  802157:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80215b:	d3 e8                	shr    %cl,%eax
  80215d:	89 e9                	mov    %ebp,%ecx
  80215f:	89 c6                	mov    %eax,%esi
  802161:	d3 e3                	shl    %cl,%ebx
  802163:	89 f9                	mov    %edi,%ecx
  802165:	89 d0                	mov    %edx,%eax
  802167:	d3 e8                	shr    %cl,%eax
  802169:	89 e9                	mov    %ebp,%ecx
  80216b:	09 d8                	or     %ebx,%eax
  80216d:	89 d3                	mov    %edx,%ebx
  80216f:	89 f2                	mov    %esi,%edx
  802171:	f7 34 24             	divl   (%esp)
  802174:	89 d6                	mov    %edx,%esi
  802176:	d3 e3                	shl    %cl,%ebx
  802178:	f7 64 24 04          	mull   0x4(%esp)
  80217c:	39 d6                	cmp    %edx,%esi
  80217e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802182:	89 d1                	mov    %edx,%ecx
  802184:	89 c3                	mov    %eax,%ebx
  802186:	72 08                	jb     802190 <__umoddi3+0x110>
  802188:	75 11                	jne    80219b <__umoddi3+0x11b>
  80218a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80218e:	73 0b                	jae    80219b <__umoddi3+0x11b>
  802190:	2b 44 24 04          	sub    0x4(%esp),%eax
  802194:	1b 14 24             	sbb    (%esp),%edx
  802197:	89 d1                	mov    %edx,%ecx
  802199:	89 c3                	mov    %eax,%ebx
  80219b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80219f:	29 da                	sub    %ebx,%edx
  8021a1:	19 ce                	sbb    %ecx,%esi
  8021a3:	89 f9                	mov    %edi,%ecx
  8021a5:	89 f0                	mov    %esi,%eax
  8021a7:	d3 e0                	shl    %cl,%eax
  8021a9:	89 e9                	mov    %ebp,%ecx
  8021ab:	d3 ea                	shr    %cl,%edx
  8021ad:	89 e9                	mov    %ebp,%ecx
  8021af:	d3 ee                	shr    %cl,%esi
  8021b1:	09 d0                	or     %edx,%eax
  8021b3:	89 f2                	mov    %esi,%edx
  8021b5:	83 c4 1c             	add    $0x1c,%esp
  8021b8:	5b                   	pop    %ebx
  8021b9:	5e                   	pop    %esi
  8021ba:	5f                   	pop    %edi
  8021bb:	5d                   	pop    %ebp
  8021bc:	c3                   	ret    
  8021bd:	8d 76 00             	lea    0x0(%esi),%esi
  8021c0:	29 f9                	sub    %edi,%ecx
  8021c2:	19 d6                	sbb    %edx,%esi
  8021c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021cc:	e9 18 ff ff ff       	jmp    8020e9 <__umoddi3+0x69>
