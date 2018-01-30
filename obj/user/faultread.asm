
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
  80003f:	68 80 24 80 00       	push   $0x802480
  800044:	e8 1b 01 00 00       	call   800164 <cprintf>
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
  800059:	e8 50 0a 00 00       	call   800aae <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  800069:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006e:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800073:	85 db                	test   %ebx,%ebx
  800075:	7e 07                	jle    80007e <libmain+0x30>
		binaryname = argv[0];
  800077:	8b 06                	mov    (%esi),%eax
  800079:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80007e:	83 ec 08             	sub    $0x8,%esp
  800081:	56                   	push   %esi
  800082:	53                   	push   %ebx
  800083:	e8 ab ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800088:	e8 2a 00 00 00       	call   8000b7 <exit>
}
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800093:	5b                   	pop    %ebx
  800094:	5e                   	pop    %esi
  800095:	5d                   	pop    %ebp
  800096:	c3                   	ret    

00800097 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  800097:	55                   	push   %ebp
  800098:	89 e5                	mov    %esp,%ebp
  80009a:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  80009d:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  8000a2:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8000a4:	e8 05 0a 00 00       	call   800aae <sys_getenvid>
  8000a9:	83 ec 0c             	sub    $0xc,%esp
  8000ac:	50                   	push   %eax
  8000ad:	e8 4b 0c 00 00       	call   800cfd <sys_thread_free>
}
  8000b2:	83 c4 10             	add    $0x10,%esp
  8000b5:	c9                   	leave  
  8000b6:	c3                   	ret    

008000b7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000bd:	e8 c5 13 00 00       	call   801487 <close_all>
	sys_env_destroy(0);
  8000c2:	83 ec 0c             	sub    $0xc,%esp
  8000c5:	6a 00                	push   $0x0
  8000c7:	e8 a1 09 00 00       	call   800a6d <sys_env_destroy>
}
  8000cc:	83 c4 10             	add    $0x10,%esp
  8000cf:	c9                   	leave  
  8000d0:	c3                   	ret    

008000d1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	53                   	push   %ebx
  8000d5:	83 ec 04             	sub    $0x4,%esp
  8000d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000db:	8b 13                	mov    (%ebx),%edx
  8000dd:	8d 42 01             	lea    0x1(%edx),%eax
  8000e0:	89 03                	mov    %eax,(%ebx)
  8000e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000e9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ee:	75 1a                	jne    80010a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000f0:	83 ec 08             	sub    $0x8,%esp
  8000f3:	68 ff 00 00 00       	push   $0xff
  8000f8:	8d 43 08             	lea    0x8(%ebx),%eax
  8000fb:	50                   	push   %eax
  8000fc:	e8 2f 09 00 00       	call   800a30 <sys_cputs>
		b->idx = 0;
  800101:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800107:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80010a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80010e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800111:	c9                   	leave  
  800112:	c3                   	ret    

00800113 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80011c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800123:	00 00 00 
	b.cnt = 0;
  800126:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80012d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800130:	ff 75 0c             	pushl  0xc(%ebp)
  800133:	ff 75 08             	pushl  0x8(%ebp)
  800136:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80013c:	50                   	push   %eax
  80013d:	68 d1 00 80 00       	push   $0x8000d1
  800142:	e8 54 01 00 00       	call   80029b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800147:	83 c4 08             	add    $0x8,%esp
  80014a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800150:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800156:	50                   	push   %eax
  800157:	e8 d4 08 00 00       	call   800a30 <sys_cputs>

	return b.cnt;
}
  80015c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800162:	c9                   	leave  
  800163:	c3                   	ret    

00800164 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80016a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80016d:	50                   	push   %eax
  80016e:	ff 75 08             	pushl  0x8(%ebp)
  800171:	e8 9d ff ff ff       	call   800113 <vcprintf>
	va_end(ap);

	return cnt;
}
  800176:	c9                   	leave  
  800177:	c3                   	ret    

00800178 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	57                   	push   %edi
  80017c:	56                   	push   %esi
  80017d:	53                   	push   %ebx
  80017e:	83 ec 1c             	sub    $0x1c,%esp
  800181:	89 c7                	mov    %eax,%edi
  800183:	89 d6                	mov    %edx,%esi
  800185:	8b 45 08             	mov    0x8(%ebp),%eax
  800188:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80018e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800191:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800194:	bb 00 00 00 00       	mov    $0x0,%ebx
  800199:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80019c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80019f:	39 d3                	cmp    %edx,%ebx
  8001a1:	72 05                	jb     8001a8 <printnum+0x30>
  8001a3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001a6:	77 45                	ja     8001ed <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a8:	83 ec 0c             	sub    $0xc,%esp
  8001ab:	ff 75 18             	pushl  0x18(%ebp)
  8001ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8001b1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001b4:	53                   	push   %ebx
  8001b5:	ff 75 10             	pushl  0x10(%ebp)
  8001b8:	83 ec 08             	sub    $0x8,%esp
  8001bb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001be:	ff 75 e0             	pushl  -0x20(%ebp)
  8001c1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001c4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001c7:	e8 24 20 00 00       	call   8021f0 <__udivdi3>
  8001cc:	83 c4 18             	add    $0x18,%esp
  8001cf:	52                   	push   %edx
  8001d0:	50                   	push   %eax
  8001d1:	89 f2                	mov    %esi,%edx
  8001d3:	89 f8                	mov    %edi,%eax
  8001d5:	e8 9e ff ff ff       	call   800178 <printnum>
  8001da:	83 c4 20             	add    $0x20,%esp
  8001dd:	eb 18                	jmp    8001f7 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001df:	83 ec 08             	sub    $0x8,%esp
  8001e2:	56                   	push   %esi
  8001e3:	ff 75 18             	pushl  0x18(%ebp)
  8001e6:	ff d7                	call   *%edi
  8001e8:	83 c4 10             	add    $0x10,%esp
  8001eb:	eb 03                	jmp    8001f0 <printnum+0x78>
  8001ed:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001f0:	83 eb 01             	sub    $0x1,%ebx
  8001f3:	85 db                	test   %ebx,%ebx
  8001f5:	7f e8                	jg     8001df <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001f7:	83 ec 08             	sub    $0x8,%esp
  8001fa:	56                   	push   %esi
  8001fb:	83 ec 04             	sub    $0x4,%esp
  8001fe:	ff 75 e4             	pushl  -0x1c(%ebp)
  800201:	ff 75 e0             	pushl  -0x20(%ebp)
  800204:	ff 75 dc             	pushl  -0x24(%ebp)
  800207:	ff 75 d8             	pushl  -0x28(%ebp)
  80020a:	e8 11 21 00 00       	call   802320 <__umoddi3>
  80020f:	83 c4 14             	add    $0x14,%esp
  800212:	0f be 80 a8 24 80 00 	movsbl 0x8024a8(%eax),%eax
  800219:	50                   	push   %eax
  80021a:	ff d7                	call   *%edi
}
  80021c:	83 c4 10             	add    $0x10,%esp
  80021f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800222:	5b                   	pop    %ebx
  800223:	5e                   	pop    %esi
  800224:	5f                   	pop    %edi
  800225:	5d                   	pop    %ebp
  800226:	c3                   	ret    

00800227 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800227:	55                   	push   %ebp
  800228:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80022a:	83 fa 01             	cmp    $0x1,%edx
  80022d:	7e 0e                	jle    80023d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80022f:	8b 10                	mov    (%eax),%edx
  800231:	8d 4a 08             	lea    0x8(%edx),%ecx
  800234:	89 08                	mov    %ecx,(%eax)
  800236:	8b 02                	mov    (%edx),%eax
  800238:	8b 52 04             	mov    0x4(%edx),%edx
  80023b:	eb 22                	jmp    80025f <getuint+0x38>
	else if (lflag)
  80023d:	85 d2                	test   %edx,%edx
  80023f:	74 10                	je     800251 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800241:	8b 10                	mov    (%eax),%edx
  800243:	8d 4a 04             	lea    0x4(%edx),%ecx
  800246:	89 08                	mov    %ecx,(%eax)
  800248:	8b 02                	mov    (%edx),%eax
  80024a:	ba 00 00 00 00       	mov    $0x0,%edx
  80024f:	eb 0e                	jmp    80025f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800251:	8b 10                	mov    (%eax),%edx
  800253:	8d 4a 04             	lea    0x4(%edx),%ecx
  800256:	89 08                	mov    %ecx,(%eax)
  800258:	8b 02                	mov    (%edx),%eax
  80025a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80025f:	5d                   	pop    %ebp
  800260:	c3                   	ret    

00800261 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800261:	55                   	push   %ebp
  800262:	89 e5                	mov    %esp,%ebp
  800264:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800267:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80026b:	8b 10                	mov    (%eax),%edx
  80026d:	3b 50 04             	cmp    0x4(%eax),%edx
  800270:	73 0a                	jae    80027c <sprintputch+0x1b>
		*b->buf++ = ch;
  800272:	8d 4a 01             	lea    0x1(%edx),%ecx
  800275:	89 08                	mov    %ecx,(%eax)
  800277:	8b 45 08             	mov    0x8(%ebp),%eax
  80027a:	88 02                	mov    %al,(%edx)
}
  80027c:	5d                   	pop    %ebp
  80027d:	c3                   	ret    

0080027e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800284:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800287:	50                   	push   %eax
  800288:	ff 75 10             	pushl  0x10(%ebp)
  80028b:	ff 75 0c             	pushl  0xc(%ebp)
  80028e:	ff 75 08             	pushl  0x8(%ebp)
  800291:	e8 05 00 00 00       	call   80029b <vprintfmt>
	va_end(ap);
}
  800296:	83 c4 10             	add    $0x10,%esp
  800299:	c9                   	leave  
  80029a:	c3                   	ret    

0080029b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80029b:	55                   	push   %ebp
  80029c:	89 e5                	mov    %esp,%ebp
  80029e:	57                   	push   %edi
  80029f:	56                   	push   %esi
  8002a0:	53                   	push   %ebx
  8002a1:	83 ec 2c             	sub    $0x2c,%esp
  8002a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002aa:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002ad:	eb 12                	jmp    8002c1 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002af:	85 c0                	test   %eax,%eax
  8002b1:	0f 84 89 03 00 00    	je     800640 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002b7:	83 ec 08             	sub    $0x8,%esp
  8002ba:	53                   	push   %ebx
  8002bb:	50                   	push   %eax
  8002bc:	ff d6                	call   *%esi
  8002be:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002c1:	83 c7 01             	add    $0x1,%edi
  8002c4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002c8:	83 f8 25             	cmp    $0x25,%eax
  8002cb:	75 e2                	jne    8002af <vprintfmt+0x14>
  8002cd:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002d1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002d8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002df:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002eb:	eb 07                	jmp    8002f4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002f0:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f4:	8d 47 01             	lea    0x1(%edi),%eax
  8002f7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002fa:	0f b6 07             	movzbl (%edi),%eax
  8002fd:	0f b6 c8             	movzbl %al,%ecx
  800300:	83 e8 23             	sub    $0x23,%eax
  800303:	3c 55                	cmp    $0x55,%al
  800305:	0f 87 1a 03 00 00    	ja     800625 <vprintfmt+0x38a>
  80030b:	0f b6 c0             	movzbl %al,%eax
  80030e:	ff 24 85 e0 25 80 00 	jmp    *0x8025e0(,%eax,4)
  800315:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800318:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80031c:	eb d6                	jmp    8002f4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800321:	b8 00 00 00 00       	mov    $0x0,%eax
  800326:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800329:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80032c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800330:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800333:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800336:	83 fa 09             	cmp    $0x9,%edx
  800339:	77 39                	ja     800374 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80033b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80033e:	eb e9                	jmp    800329 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800340:	8b 45 14             	mov    0x14(%ebp),%eax
  800343:	8d 48 04             	lea    0x4(%eax),%ecx
  800346:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800349:	8b 00                	mov    (%eax),%eax
  80034b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800351:	eb 27                	jmp    80037a <vprintfmt+0xdf>
  800353:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800356:	85 c0                	test   %eax,%eax
  800358:	b9 00 00 00 00       	mov    $0x0,%ecx
  80035d:	0f 49 c8             	cmovns %eax,%ecx
  800360:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800363:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800366:	eb 8c                	jmp    8002f4 <vprintfmt+0x59>
  800368:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80036b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800372:	eb 80                	jmp    8002f4 <vprintfmt+0x59>
  800374:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800377:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80037a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80037e:	0f 89 70 ff ff ff    	jns    8002f4 <vprintfmt+0x59>
				width = precision, precision = -1;
  800384:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800387:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80038a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800391:	e9 5e ff ff ff       	jmp    8002f4 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800396:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800399:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80039c:	e9 53 ff ff ff       	jmp    8002f4 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a4:	8d 50 04             	lea    0x4(%eax),%edx
  8003a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003aa:	83 ec 08             	sub    $0x8,%esp
  8003ad:	53                   	push   %ebx
  8003ae:	ff 30                	pushl  (%eax)
  8003b0:	ff d6                	call   *%esi
			break;
  8003b2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003b8:	e9 04 ff ff ff       	jmp    8002c1 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c0:	8d 50 04             	lea    0x4(%eax),%edx
  8003c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c6:	8b 00                	mov    (%eax),%eax
  8003c8:	99                   	cltd   
  8003c9:	31 d0                	xor    %edx,%eax
  8003cb:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003cd:	83 f8 0f             	cmp    $0xf,%eax
  8003d0:	7f 0b                	jg     8003dd <vprintfmt+0x142>
  8003d2:	8b 14 85 40 27 80 00 	mov    0x802740(,%eax,4),%edx
  8003d9:	85 d2                	test   %edx,%edx
  8003db:	75 18                	jne    8003f5 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003dd:	50                   	push   %eax
  8003de:	68 c0 24 80 00       	push   $0x8024c0
  8003e3:	53                   	push   %ebx
  8003e4:	56                   	push   %esi
  8003e5:	e8 94 fe ff ff       	call   80027e <printfmt>
  8003ea:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003f0:	e9 cc fe ff ff       	jmp    8002c1 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003f5:	52                   	push   %edx
  8003f6:	68 cd 29 80 00       	push   $0x8029cd
  8003fb:	53                   	push   %ebx
  8003fc:	56                   	push   %esi
  8003fd:	e8 7c fe ff ff       	call   80027e <printfmt>
  800402:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800405:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800408:	e9 b4 fe ff ff       	jmp    8002c1 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80040d:	8b 45 14             	mov    0x14(%ebp),%eax
  800410:	8d 50 04             	lea    0x4(%eax),%edx
  800413:	89 55 14             	mov    %edx,0x14(%ebp)
  800416:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800418:	85 ff                	test   %edi,%edi
  80041a:	b8 b9 24 80 00       	mov    $0x8024b9,%eax
  80041f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800422:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800426:	0f 8e 94 00 00 00    	jle    8004c0 <vprintfmt+0x225>
  80042c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800430:	0f 84 98 00 00 00    	je     8004ce <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800436:	83 ec 08             	sub    $0x8,%esp
  800439:	ff 75 d0             	pushl  -0x30(%ebp)
  80043c:	57                   	push   %edi
  80043d:	e8 86 02 00 00       	call   8006c8 <strnlen>
  800442:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800445:	29 c1                	sub    %eax,%ecx
  800447:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80044a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80044d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800451:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800454:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800457:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800459:	eb 0f                	jmp    80046a <vprintfmt+0x1cf>
					putch(padc, putdat);
  80045b:	83 ec 08             	sub    $0x8,%esp
  80045e:	53                   	push   %ebx
  80045f:	ff 75 e0             	pushl  -0x20(%ebp)
  800462:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800464:	83 ef 01             	sub    $0x1,%edi
  800467:	83 c4 10             	add    $0x10,%esp
  80046a:	85 ff                	test   %edi,%edi
  80046c:	7f ed                	jg     80045b <vprintfmt+0x1c0>
  80046e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800471:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800474:	85 c9                	test   %ecx,%ecx
  800476:	b8 00 00 00 00       	mov    $0x0,%eax
  80047b:	0f 49 c1             	cmovns %ecx,%eax
  80047e:	29 c1                	sub    %eax,%ecx
  800480:	89 75 08             	mov    %esi,0x8(%ebp)
  800483:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800486:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800489:	89 cb                	mov    %ecx,%ebx
  80048b:	eb 4d                	jmp    8004da <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80048d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800491:	74 1b                	je     8004ae <vprintfmt+0x213>
  800493:	0f be c0             	movsbl %al,%eax
  800496:	83 e8 20             	sub    $0x20,%eax
  800499:	83 f8 5e             	cmp    $0x5e,%eax
  80049c:	76 10                	jbe    8004ae <vprintfmt+0x213>
					putch('?', putdat);
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	ff 75 0c             	pushl  0xc(%ebp)
  8004a4:	6a 3f                	push   $0x3f
  8004a6:	ff 55 08             	call   *0x8(%ebp)
  8004a9:	83 c4 10             	add    $0x10,%esp
  8004ac:	eb 0d                	jmp    8004bb <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004ae:	83 ec 08             	sub    $0x8,%esp
  8004b1:	ff 75 0c             	pushl  0xc(%ebp)
  8004b4:	52                   	push   %edx
  8004b5:	ff 55 08             	call   *0x8(%ebp)
  8004b8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004bb:	83 eb 01             	sub    $0x1,%ebx
  8004be:	eb 1a                	jmp    8004da <vprintfmt+0x23f>
  8004c0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004cc:	eb 0c                	jmp    8004da <vprintfmt+0x23f>
  8004ce:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004da:	83 c7 01             	add    $0x1,%edi
  8004dd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004e1:	0f be d0             	movsbl %al,%edx
  8004e4:	85 d2                	test   %edx,%edx
  8004e6:	74 23                	je     80050b <vprintfmt+0x270>
  8004e8:	85 f6                	test   %esi,%esi
  8004ea:	78 a1                	js     80048d <vprintfmt+0x1f2>
  8004ec:	83 ee 01             	sub    $0x1,%esi
  8004ef:	79 9c                	jns    80048d <vprintfmt+0x1f2>
  8004f1:	89 df                	mov    %ebx,%edi
  8004f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f9:	eb 18                	jmp    800513 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	53                   	push   %ebx
  8004ff:	6a 20                	push   $0x20
  800501:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800503:	83 ef 01             	sub    $0x1,%edi
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	eb 08                	jmp    800513 <vprintfmt+0x278>
  80050b:	89 df                	mov    %ebx,%edi
  80050d:	8b 75 08             	mov    0x8(%ebp),%esi
  800510:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800513:	85 ff                	test   %edi,%edi
  800515:	7f e4                	jg     8004fb <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800517:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80051a:	e9 a2 fd ff ff       	jmp    8002c1 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80051f:	83 fa 01             	cmp    $0x1,%edx
  800522:	7e 16                	jle    80053a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800524:	8b 45 14             	mov    0x14(%ebp),%eax
  800527:	8d 50 08             	lea    0x8(%eax),%edx
  80052a:	89 55 14             	mov    %edx,0x14(%ebp)
  80052d:	8b 50 04             	mov    0x4(%eax),%edx
  800530:	8b 00                	mov    (%eax),%eax
  800532:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800535:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800538:	eb 32                	jmp    80056c <vprintfmt+0x2d1>
	else if (lflag)
  80053a:	85 d2                	test   %edx,%edx
  80053c:	74 18                	je     800556 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80053e:	8b 45 14             	mov    0x14(%ebp),%eax
  800541:	8d 50 04             	lea    0x4(%eax),%edx
  800544:	89 55 14             	mov    %edx,0x14(%ebp)
  800547:	8b 00                	mov    (%eax),%eax
  800549:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054c:	89 c1                	mov    %eax,%ecx
  80054e:	c1 f9 1f             	sar    $0x1f,%ecx
  800551:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800554:	eb 16                	jmp    80056c <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800556:	8b 45 14             	mov    0x14(%ebp),%eax
  800559:	8d 50 04             	lea    0x4(%eax),%edx
  80055c:	89 55 14             	mov    %edx,0x14(%ebp)
  80055f:	8b 00                	mov    (%eax),%eax
  800561:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800564:	89 c1                	mov    %eax,%ecx
  800566:	c1 f9 1f             	sar    $0x1f,%ecx
  800569:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80056c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80056f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800572:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800577:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80057b:	79 74                	jns    8005f1 <vprintfmt+0x356>
				putch('-', putdat);
  80057d:	83 ec 08             	sub    $0x8,%esp
  800580:	53                   	push   %ebx
  800581:	6a 2d                	push   $0x2d
  800583:	ff d6                	call   *%esi
				num = -(long long) num;
  800585:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800588:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80058b:	f7 d8                	neg    %eax
  80058d:	83 d2 00             	adc    $0x0,%edx
  800590:	f7 da                	neg    %edx
  800592:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800595:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80059a:	eb 55                	jmp    8005f1 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80059c:	8d 45 14             	lea    0x14(%ebp),%eax
  80059f:	e8 83 fc ff ff       	call   800227 <getuint>
			base = 10;
  8005a4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005a9:	eb 46                	jmp    8005f1 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ae:	e8 74 fc ff ff       	call   800227 <getuint>
			base = 8;
  8005b3:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005b8:	eb 37                	jmp    8005f1 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	53                   	push   %ebx
  8005be:	6a 30                	push   $0x30
  8005c0:	ff d6                	call   *%esi
			putch('x', putdat);
  8005c2:	83 c4 08             	add    $0x8,%esp
  8005c5:	53                   	push   %ebx
  8005c6:	6a 78                	push   $0x78
  8005c8:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8d 50 04             	lea    0x4(%eax),%edx
  8005d0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005d3:	8b 00                	mov    (%eax),%eax
  8005d5:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005da:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005dd:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005e2:	eb 0d                	jmp    8005f1 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005e4:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e7:	e8 3b fc ff ff       	call   800227 <getuint>
			base = 16;
  8005ec:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005f1:	83 ec 0c             	sub    $0xc,%esp
  8005f4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005f8:	57                   	push   %edi
  8005f9:	ff 75 e0             	pushl  -0x20(%ebp)
  8005fc:	51                   	push   %ecx
  8005fd:	52                   	push   %edx
  8005fe:	50                   	push   %eax
  8005ff:	89 da                	mov    %ebx,%edx
  800601:	89 f0                	mov    %esi,%eax
  800603:	e8 70 fb ff ff       	call   800178 <printnum>
			break;
  800608:	83 c4 20             	add    $0x20,%esp
  80060b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80060e:	e9 ae fc ff ff       	jmp    8002c1 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800613:	83 ec 08             	sub    $0x8,%esp
  800616:	53                   	push   %ebx
  800617:	51                   	push   %ecx
  800618:	ff d6                	call   *%esi
			break;
  80061a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800620:	e9 9c fc ff ff       	jmp    8002c1 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800625:	83 ec 08             	sub    $0x8,%esp
  800628:	53                   	push   %ebx
  800629:	6a 25                	push   $0x25
  80062b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80062d:	83 c4 10             	add    $0x10,%esp
  800630:	eb 03                	jmp    800635 <vprintfmt+0x39a>
  800632:	83 ef 01             	sub    $0x1,%edi
  800635:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800639:	75 f7                	jne    800632 <vprintfmt+0x397>
  80063b:	e9 81 fc ff ff       	jmp    8002c1 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800640:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800643:	5b                   	pop    %ebx
  800644:	5e                   	pop    %esi
  800645:	5f                   	pop    %edi
  800646:	5d                   	pop    %ebp
  800647:	c3                   	ret    

00800648 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800648:	55                   	push   %ebp
  800649:	89 e5                	mov    %esp,%ebp
  80064b:	83 ec 18             	sub    $0x18,%esp
  80064e:	8b 45 08             	mov    0x8(%ebp),%eax
  800651:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800654:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800657:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80065b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80065e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800665:	85 c0                	test   %eax,%eax
  800667:	74 26                	je     80068f <vsnprintf+0x47>
  800669:	85 d2                	test   %edx,%edx
  80066b:	7e 22                	jle    80068f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80066d:	ff 75 14             	pushl  0x14(%ebp)
  800670:	ff 75 10             	pushl  0x10(%ebp)
  800673:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800676:	50                   	push   %eax
  800677:	68 61 02 80 00       	push   $0x800261
  80067c:	e8 1a fc ff ff       	call   80029b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800681:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800684:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800687:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80068a:	83 c4 10             	add    $0x10,%esp
  80068d:	eb 05                	jmp    800694 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80068f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800694:	c9                   	leave  
  800695:	c3                   	ret    

00800696 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800696:	55                   	push   %ebp
  800697:	89 e5                	mov    %esp,%ebp
  800699:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80069c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80069f:	50                   	push   %eax
  8006a0:	ff 75 10             	pushl  0x10(%ebp)
  8006a3:	ff 75 0c             	pushl  0xc(%ebp)
  8006a6:	ff 75 08             	pushl  0x8(%ebp)
  8006a9:	e8 9a ff ff ff       	call   800648 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006ae:	c9                   	leave  
  8006af:	c3                   	ret    

008006b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006b0:	55                   	push   %ebp
  8006b1:	89 e5                	mov    %esp,%ebp
  8006b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006bb:	eb 03                	jmp    8006c0 <strlen+0x10>
		n++;
  8006bd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006c4:	75 f7                	jne    8006bd <strlen+0xd>
		n++;
	return n;
}
  8006c6:	5d                   	pop    %ebp
  8006c7:	c3                   	ret    

008006c8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006ce:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8006d6:	eb 03                	jmp    8006db <strnlen+0x13>
		n++;
  8006d8:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006db:	39 c2                	cmp    %eax,%edx
  8006dd:	74 08                	je     8006e7 <strnlen+0x1f>
  8006df:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006e3:	75 f3                	jne    8006d8 <strnlen+0x10>
  8006e5:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006e7:	5d                   	pop    %ebp
  8006e8:	c3                   	ret    

008006e9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006e9:	55                   	push   %ebp
  8006ea:	89 e5                	mov    %esp,%ebp
  8006ec:	53                   	push   %ebx
  8006ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006f3:	89 c2                	mov    %eax,%edx
  8006f5:	83 c2 01             	add    $0x1,%edx
  8006f8:	83 c1 01             	add    $0x1,%ecx
  8006fb:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006ff:	88 5a ff             	mov    %bl,-0x1(%edx)
  800702:	84 db                	test   %bl,%bl
  800704:	75 ef                	jne    8006f5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800706:	5b                   	pop    %ebx
  800707:	5d                   	pop    %ebp
  800708:	c3                   	ret    

00800709 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800709:	55                   	push   %ebp
  80070a:	89 e5                	mov    %esp,%ebp
  80070c:	53                   	push   %ebx
  80070d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800710:	53                   	push   %ebx
  800711:	e8 9a ff ff ff       	call   8006b0 <strlen>
  800716:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800719:	ff 75 0c             	pushl  0xc(%ebp)
  80071c:	01 d8                	add    %ebx,%eax
  80071e:	50                   	push   %eax
  80071f:	e8 c5 ff ff ff       	call   8006e9 <strcpy>
	return dst;
}
  800724:	89 d8                	mov    %ebx,%eax
  800726:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800729:	c9                   	leave  
  80072a:	c3                   	ret    

0080072b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80072b:	55                   	push   %ebp
  80072c:	89 e5                	mov    %esp,%ebp
  80072e:	56                   	push   %esi
  80072f:	53                   	push   %ebx
  800730:	8b 75 08             	mov    0x8(%ebp),%esi
  800733:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800736:	89 f3                	mov    %esi,%ebx
  800738:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80073b:	89 f2                	mov    %esi,%edx
  80073d:	eb 0f                	jmp    80074e <strncpy+0x23>
		*dst++ = *src;
  80073f:	83 c2 01             	add    $0x1,%edx
  800742:	0f b6 01             	movzbl (%ecx),%eax
  800745:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800748:	80 39 01             	cmpb   $0x1,(%ecx)
  80074b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80074e:	39 da                	cmp    %ebx,%edx
  800750:	75 ed                	jne    80073f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800752:	89 f0                	mov    %esi,%eax
  800754:	5b                   	pop    %ebx
  800755:	5e                   	pop    %esi
  800756:	5d                   	pop    %ebp
  800757:	c3                   	ret    

00800758 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	56                   	push   %esi
  80075c:	53                   	push   %ebx
  80075d:	8b 75 08             	mov    0x8(%ebp),%esi
  800760:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800763:	8b 55 10             	mov    0x10(%ebp),%edx
  800766:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800768:	85 d2                	test   %edx,%edx
  80076a:	74 21                	je     80078d <strlcpy+0x35>
  80076c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800770:	89 f2                	mov    %esi,%edx
  800772:	eb 09                	jmp    80077d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800774:	83 c2 01             	add    $0x1,%edx
  800777:	83 c1 01             	add    $0x1,%ecx
  80077a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80077d:	39 c2                	cmp    %eax,%edx
  80077f:	74 09                	je     80078a <strlcpy+0x32>
  800781:	0f b6 19             	movzbl (%ecx),%ebx
  800784:	84 db                	test   %bl,%bl
  800786:	75 ec                	jne    800774 <strlcpy+0x1c>
  800788:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80078a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80078d:	29 f0                	sub    %esi,%eax
}
  80078f:	5b                   	pop    %ebx
  800790:	5e                   	pop    %esi
  800791:	5d                   	pop    %ebp
  800792:	c3                   	ret    

00800793 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800799:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80079c:	eb 06                	jmp    8007a4 <strcmp+0x11>
		p++, q++;
  80079e:	83 c1 01             	add    $0x1,%ecx
  8007a1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007a4:	0f b6 01             	movzbl (%ecx),%eax
  8007a7:	84 c0                	test   %al,%al
  8007a9:	74 04                	je     8007af <strcmp+0x1c>
  8007ab:	3a 02                	cmp    (%edx),%al
  8007ad:	74 ef                	je     80079e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007af:	0f b6 c0             	movzbl %al,%eax
  8007b2:	0f b6 12             	movzbl (%edx),%edx
  8007b5:	29 d0                	sub    %edx,%eax
}
  8007b7:	5d                   	pop    %ebp
  8007b8:	c3                   	ret    

008007b9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	53                   	push   %ebx
  8007bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c3:	89 c3                	mov    %eax,%ebx
  8007c5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007c8:	eb 06                	jmp    8007d0 <strncmp+0x17>
		n--, p++, q++;
  8007ca:	83 c0 01             	add    $0x1,%eax
  8007cd:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007d0:	39 d8                	cmp    %ebx,%eax
  8007d2:	74 15                	je     8007e9 <strncmp+0x30>
  8007d4:	0f b6 08             	movzbl (%eax),%ecx
  8007d7:	84 c9                	test   %cl,%cl
  8007d9:	74 04                	je     8007df <strncmp+0x26>
  8007db:	3a 0a                	cmp    (%edx),%cl
  8007dd:	74 eb                	je     8007ca <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007df:	0f b6 00             	movzbl (%eax),%eax
  8007e2:	0f b6 12             	movzbl (%edx),%edx
  8007e5:	29 d0                	sub    %edx,%eax
  8007e7:	eb 05                	jmp    8007ee <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007e9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007ee:	5b                   	pop    %ebx
  8007ef:	5d                   	pop    %ebp
  8007f0:	c3                   	ret    

008007f1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007fb:	eb 07                	jmp    800804 <strchr+0x13>
		if (*s == c)
  8007fd:	38 ca                	cmp    %cl,%dl
  8007ff:	74 0f                	je     800810 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800801:	83 c0 01             	add    $0x1,%eax
  800804:	0f b6 10             	movzbl (%eax),%edx
  800807:	84 d2                	test   %dl,%dl
  800809:	75 f2                	jne    8007fd <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80080b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	8b 45 08             	mov    0x8(%ebp),%eax
  800818:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80081c:	eb 03                	jmp    800821 <strfind+0xf>
  80081e:	83 c0 01             	add    $0x1,%eax
  800821:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800824:	38 ca                	cmp    %cl,%dl
  800826:	74 04                	je     80082c <strfind+0x1a>
  800828:	84 d2                	test   %dl,%dl
  80082a:	75 f2                	jne    80081e <strfind+0xc>
			break;
	return (char *) s;
}
  80082c:	5d                   	pop    %ebp
  80082d:	c3                   	ret    

0080082e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80082e:	55                   	push   %ebp
  80082f:	89 e5                	mov    %esp,%ebp
  800831:	57                   	push   %edi
  800832:	56                   	push   %esi
  800833:	53                   	push   %ebx
  800834:	8b 7d 08             	mov    0x8(%ebp),%edi
  800837:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80083a:	85 c9                	test   %ecx,%ecx
  80083c:	74 36                	je     800874 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80083e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800844:	75 28                	jne    80086e <memset+0x40>
  800846:	f6 c1 03             	test   $0x3,%cl
  800849:	75 23                	jne    80086e <memset+0x40>
		c &= 0xFF;
  80084b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80084f:	89 d3                	mov    %edx,%ebx
  800851:	c1 e3 08             	shl    $0x8,%ebx
  800854:	89 d6                	mov    %edx,%esi
  800856:	c1 e6 18             	shl    $0x18,%esi
  800859:	89 d0                	mov    %edx,%eax
  80085b:	c1 e0 10             	shl    $0x10,%eax
  80085e:	09 f0                	or     %esi,%eax
  800860:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800862:	89 d8                	mov    %ebx,%eax
  800864:	09 d0                	or     %edx,%eax
  800866:	c1 e9 02             	shr    $0x2,%ecx
  800869:	fc                   	cld    
  80086a:	f3 ab                	rep stos %eax,%es:(%edi)
  80086c:	eb 06                	jmp    800874 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80086e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800871:	fc                   	cld    
  800872:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800874:	89 f8                	mov    %edi,%eax
  800876:	5b                   	pop    %ebx
  800877:	5e                   	pop    %esi
  800878:	5f                   	pop    %edi
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	57                   	push   %edi
  80087f:	56                   	push   %esi
  800880:	8b 45 08             	mov    0x8(%ebp),%eax
  800883:	8b 75 0c             	mov    0xc(%ebp),%esi
  800886:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800889:	39 c6                	cmp    %eax,%esi
  80088b:	73 35                	jae    8008c2 <memmove+0x47>
  80088d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800890:	39 d0                	cmp    %edx,%eax
  800892:	73 2e                	jae    8008c2 <memmove+0x47>
		s += n;
		d += n;
  800894:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800897:	89 d6                	mov    %edx,%esi
  800899:	09 fe                	or     %edi,%esi
  80089b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008a1:	75 13                	jne    8008b6 <memmove+0x3b>
  8008a3:	f6 c1 03             	test   $0x3,%cl
  8008a6:	75 0e                	jne    8008b6 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008a8:	83 ef 04             	sub    $0x4,%edi
  8008ab:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008ae:	c1 e9 02             	shr    $0x2,%ecx
  8008b1:	fd                   	std    
  8008b2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008b4:	eb 09                	jmp    8008bf <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008b6:	83 ef 01             	sub    $0x1,%edi
  8008b9:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008bc:	fd                   	std    
  8008bd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008bf:	fc                   	cld    
  8008c0:	eb 1d                	jmp    8008df <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c2:	89 f2                	mov    %esi,%edx
  8008c4:	09 c2                	or     %eax,%edx
  8008c6:	f6 c2 03             	test   $0x3,%dl
  8008c9:	75 0f                	jne    8008da <memmove+0x5f>
  8008cb:	f6 c1 03             	test   $0x3,%cl
  8008ce:	75 0a                	jne    8008da <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008d0:	c1 e9 02             	shr    $0x2,%ecx
  8008d3:	89 c7                	mov    %eax,%edi
  8008d5:	fc                   	cld    
  8008d6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008d8:	eb 05                	jmp    8008df <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008da:	89 c7                	mov    %eax,%edi
  8008dc:	fc                   	cld    
  8008dd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008df:	5e                   	pop    %esi
  8008e0:	5f                   	pop    %edi
  8008e1:	5d                   	pop    %ebp
  8008e2:	c3                   	ret    

008008e3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008e6:	ff 75 10             	pushl  0x10(%ebp)
  8008e9:	ff 75 0c             	pushl  0xc(%ebp)
  8008ec:	ff 75 08             	pushl  0x8(%ebp)
  8008ef:	e8 87 ff ff ff       	call   80087b <memmove>
}
  8008f4:	c9                   	leave  
  8008f5:	c3                   	ret    

008008f6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	56                   	push   %esi
  8008fa:	53                   	push   %ebx
  8008fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800901:	89 c6                	mov    %eax,%esi
  800903:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800906:	eb 1a                	jmp    800922 <memcmp+0x2c>
		if (*s1 != *s2)
  800908:	0f b6 08             	movzbl (%eax),%ecx
  80090b:	0f b6 1a             	movzbl (%edx),%ebx
  80090e:	38 d9                	cmp    %bl,%cl
  800910:	74 0a                	je     80091c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800912:	0f b6 c1             	movzbl %cl,%eax
  800915:	0f b6 db             	movzbl %bl,%ebx
  800918:	29 d8                	sub    %ebx,%eax
  80091a:	eb 0f                	jmp    80092b <memcmp+0x35>
		s1++, s2++;
  80091c:	83 c0 01             	add    $0x1,%eax
  80091f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800922:	39 f0                	cmp    %esi,%eax
  800924:	75 e2                	jne    800908 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800926:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80092b:	5b                   	pop    %ebx
  80092c:	5e                   	pop    %esi
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	53                   	push   %ebx
  800933:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800936:	89 c1                	mov    %eax,%ecx
  800938:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80093b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80093f:	eb 0a                	jmp    80094b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800941:	0f b6 10             	movzbl (%eax),%edx
  800944:	39 da                	cmp    %ebx,%edx
  800946:	74 07                	je     80094f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800948:	83 c0 01             	add    $0x1,%eax
  80094b:	39 c8                	cmp    %ecx,%eax
  80094d:	72 f2                	jb     800941 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80094f:	5b                   	pop    %ebx
  800950:	5d                   	pop    %ebp
  800951:	c3                   	ret    

00800952 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	57                   	push   %edi
  800956:	56                   	push   %esi
  800957:	53                   	push   %ebx
  800958:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80095e:	eb 03                	jmp    800963 <strtol+0x11>
		s++;
  800960:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800963:	0f b6 01             	movzbl (%ecx),%eax
  800966:	3c 20                	cmp    $0x20,%al
  800968:	74 f6                	je     800960 <strtol+0xe>
  80096a:	3c 09                	cmp    $0x9,%al
  80096c:	74 f2                	je     800960 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80096e:	3c 2b                	cmp    $0x2b,%al
  800970:	75 0a                	jne    80097c <strtol+0x2a>
		s++;
  800972:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800975:	bf 00 00 00 00       	mov    $0x0,%edi
  80097a:	eb 11                	jmp    80098d <strtol+0x3b>
  80097c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800981:	3c 2d                	cmp    $0x2d,%al
  800983:	75 08                	jne    80098d <strtol+0x3b>
		s++, neg = 1;
  800985:	83 c1 01             	add    $0x1,%ecx
  800988:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80098d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800993:	75 15                	jne    8009aa <strtol+0x58>
  800995:	80 39 30             	cmpb   $0x30,(%ecx)
  800998:	75 10                	jne    8009aa <strtol+0x58>
  80099a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80099e:	75 7c                	jne    800a1c <strtol+0xca>
		s += 2, base = 16;
  8009a0:	83 c1 02             	add    $0x2,%ecx
  8009a3:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009a8:	eb 16                	jmp    8009c0 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009aa:	85 db                	test   %ebx,%ebx
  8009ac:	75 12                	jne    8009c0 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009ae:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009b3:	80 39 30             	cmpb   $0x30,(%ecx)
  8009b6:	75 08                	jne    8009c0 <strtol+0x6e>
		s++, base = 8;
  8009b8:	83 c1 01             	add    $0x1,%ecx
  8009bb:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c5:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009c8:	0f b6 11             	movzbl (%ecx),%edx
  8009cb:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009ce:	89 f3                	mov    %esi,%ebx
  8009d0:	80 fb 09             	cmp    $0x9,%bl
  8009d3:	77 08                	ja     8009dd <strtol+0x8b>
			dig = *s - '0';
  8009d5:	0f be d2             	movsbl %dl,%edx
  8009d8:	83 ea 30             	sub    $0x30,%edx
  8009db:	eb 22                	jmp    8009ff <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009dd:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009e0:	89 f3                	mov    %esi,%ebx
  8009e2:	80 fb 19             	cmp    $0x19,%bl
  8009e5:	77 08                	ja     8009ef <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009e7:	0f be d2             	movsbl %dl,%edx
  8009ea:	83 ea 57             	sub    $0x57,%edx
  8009ed:	eb 10                	jmp    8009ff <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009ef:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009f2:	89 f3                	mov    %esi,%ebx
  8009f4:	80 fb 19             	cmp    $0x19,%bl
  8009f7:	77 16                	ja     800a0f <strtol+0xbd>
			dig = *s - 'A' + 10;
  8009f9:	0f be d2             	movsbl %dl,%edx
  8009fc:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8009ff:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a02:	7d 0b                	jge    800a0f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a04:	83 c1 01             	add    $0x1,%ecx
  800a07:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a0b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a0d:	eb b9                	jmp    8009c8 <strtol+0x76>

	if (endptr)
  800a0f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a13:	74 0d                	je     800a22 <strtol+0xd0>
		*endptr = (char *) s;
  800a15:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a18:	89 0e                	mov    %ecx,(%esi)
  800a1a:	eb 06                	jmp    800a22 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a1c:	85 db                	test   %ebx,%ebx
  800a1e:	74 98                	je     8009b8 <strtol+0x66>
  800a20:	eb 9e                	jmp    8009c0 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a22:	89 c2                	mov    %eax,%edx
  800a24:	f7 da                	neg    %edx
  800a26:	85 ff                	test   %edi,%edi
  800a28:	0f 45 c2             	cmovne %edx,%eax
}
  800a2b:	5b                   	pop    %ebx
  800a2c:	5e                   	pop    %esi
  800a2d:	5f                   	pop    %edi
  800a2e:	5d                   	pop    %ebp
  800a2f:	c3                   	ret    

00800a30 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	57                   	push   %edi
  800a34:	56                   	push   %esi
  800a35:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a36:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a41:	89 c3                	mov    %eax,%ebx
  800a43:	89 c7                	mov    %eax,%edi
  800a45:	89 c6                	mov    %eax,%esi
  800a47:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a49:	5b                   	pop    %ebx
  800a4a:	5e                   	pop    %esi
  800a4b:	5f                   	pop    %edi
  800a4c:	5d                   	pop    %ebp
  800a4d:	c3                   	ret    

00800a4e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	57                   	push   %edi
  800a52:	56                   	push   %esi
  800a53:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a54:	ba 00 00 00 00       	mov    $0x0,%edx
  800a59:	b8 01 00 00 00       	mov    $0x1,%eax
  800a5e:	89 d1                	mov    %edx,%ecx
  800a60:	89 d3                	mov    %edx,%ebx
  800a62:	89 d7                	mov    %edx,%edi
  800a64:	89 d6                	mov    %edx,%esi
  800a66:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a68:	5b                   	pop    %ebx
  800a69:	5e                   	pop    %esi
  800a6a:	5f                   	pop    %edi
  800a6b:	5d                   	pop    %ebp
  800a6c:	c3                   	ret    

00800a6d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	57                   	push   %edi
  800a71:	56                   	push   %esi
  800a72:	53                   	push   %ebx
  800a73:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a76:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a7b:	b8 03 00 00 00       	mov    $0x3,%eax
  800a80:	8b 55 08             	mov    0x8(%ebp),%edx
  800a83:	89 cb                	mov    %ecx,%ebx
  800a85:	89 cf                	mov    %ecx,%edi
  800a87:	89 ce                	mov    %ecx,%esi
  800a89:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a8b:	85 c0                	test   %eax,%eax
  800a8d:	7e 17                	jle    800aa6 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a8f:	83 ec 0c             	sub    $0xc,%esp
  800a92:	50                   	push   %eax
  800a93:	6a 03                	push   $0x3
  800a95:	68 9f 27 80 00       	push   $0x80279f
  800a9a:	6a 23                	push   $0x23
  800a9c:	68 bc 27 80 00       	push   $0x8027bc
  800aa1:	e8 12 15 00 00       	call   801fb8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aa6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aa9:	5b                   	pop    %ebx
  800aaa:	5e                   	pop    %esi
  800aab:	5f                   	pop    %edi
  800aac:	5d                   	pop    %ebp
  800aad:	c3                   	ret    

00800aae <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aae:	55                   	push   %ebp
  800aaf:	89 e5                	mov    %esp,%ebp
  800ab1:	57                   	push   %edi
  800ab2:	56                   	push   %esi
  800ab3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab9:	b8 02 00 00 00       	mov    $0x2,%eax
  800abe:	89 d1                	mov    %edx,%ecx
  800ac0:	89 d3                	mov    %edx,%ebx
  800ac2:	89 d7                	mov    %edx,%edi
  800ac4:	89 d6                	mov    %edx,%esi
  800ac6:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ac8:	5b                   	pop    %ebx
  800ac9:	5e                   	pop    %esi
  800aca:	5f                   	pop    %edi
  800acb:	5d                   	pop    %ebp
  800acc:	c3                   	ret    

00800acd <sys_yield>:

void
sys_yield(void)
{
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	57                   	push   %edi
  800ad1:	56                   	push   %esi
  800ad2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800add:	89 d1                	mov    %edx,%ecx
  800adf:	89 d3                	mov    %edx,%ebx
  800ae1:	89 d7                	mov    %edx,%edi
  800ae3:	89 d6                	mov    %edx,%esi
  800ae5:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ae7:	5b                   	pop    %ebx
  800ae8:	5e                   	pop    %esi
  800ae9:	5f                   	pop    %edi
  800aea:	5d                   	pop    %ebp
  800aeb:	c3                   	ret    

00800aec <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	57                   	push   %edi
  800af0:	56                   	push   %esi
  800af1:	53                   	push   %ebx
  800af2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af5:	be 00 00 00 00       	mov    $0x0,%esi
  800afa:	b8 04 00 00 00       	mov    $0x4,%eax
  800aff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b02:	8b 55 08             	mov    0x8(%ebp),%edx
  800b05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b08:	89 f7                	mov    %esi,%edi
  800b0a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b0c:	85 c0                	test   %eax,%eax
  800b0e:	7e 17                	jle    800b27 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b10:	83 ec 0c             	sub    $0xc,%esp
  800b13:	50                   	push   %eax
  800b14:	6a 04                	push   $0x4
  800b16:	68 9f 27 80 00       	push   $0x80279f
  800b1b:	6a 23                	push   $0x23
  800b1d:	68 bc 27 80 00       	push   $0x8027bc
  800b22:	e8 91 14 00 00       	call   801fb8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5f                   	pop    %edi
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
  800b35:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b38:	b8 05 00 00 00       	mov    $0x5,%eax
  800b3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b40:	8b 55 08             	mov    0x8(%ebp),%edx
  800b43:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b46:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b49:	8b 75 18             	mov    0x18(%ebp),%esi
  800b4c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b4e:	85 c0                	test   %eax,%eax
  800b50:	7e 17                	jle    800b69 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b52:	83 ec 0c             	sub    $0xc,%esp
  800b55:	50                   	push   %eax
  800b56:	6a 05                	push   $0x5
  800b58:	68 9f 27 80 00       	push   $0x80279f
  800b5d:	6a 23                	push   $0x23
  800b5f:	68 bc 27 80 00       	push   $0x8027bc
  800b64:	e8 4f 14 00 00       	call   801fb8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	57                   	push   %edi
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
  800b77:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b7f:	b8 06 00 00 00       	mov    $0x6,%eax
  800b84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b87:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8a:	89 df                	mov    %ebx,%edi
  800b8c:	89 de                	mov    %ebx,%esi
  800b8e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b90:	85 c0                	test   %eax,%eax
  800b92:	7e 17                	jle    800bab <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b94:	83 ec 0c             	sub    $0xc,%esp
  800b97:	50                   	push   %eax
  800b98:	6a 06                	push   $0x6
  800b9a:	68 9f 27 80 00       	push   $0x80279f
  800b9f:	6a 23                	push   $0x23
  800ba1:	68 bc 27 80 00       	push   $0x8027bc
  800ba6:	e8 0d 14 00 00       	call   801fb8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bae:	5b                   	pop    %ebx
  800baf:	5e                   	pop    %esi
  800bb0:	5f                   	pop    %edi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	57                   	push   %edi
  800bb7:	56                   	push   %esi
  800bb8:	53                   	push   %ebx
  800bb9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bc1:	b8 08 00 00 00       	mov    $0x8,%eax
  800bc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcc:	89 df                	mov    %ebx,%edi
  800bce:	89 de                	mov    %ebx,%esi
  800bd0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd2:	85 c0                	test   %eax,%eax
  800bd4:	7e 17                	jle    800bed <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd6:	83 ec 0c             	sub    $0xc,%esp
  800bd9:	50                   	push   %eax
  800bda:	6a 08                	push   $0x8
  800bdc:	68 9f 27 80 00       	push   $0x80279f
  800be1:	6a 23                	push   $0x23
  800be3:	68 bc 27 80 00       	push   $0x8027bc
  800be8:	e8 cb 13 00 00       	call   801fb8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
  800bfb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c03:	b8 09 00 00 00       	mov    $0x9,%eax
  800c08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0e:	89 df                	mov    %ebx,%edi
  800c10:	89 de                	mov    %ebx,%esi
  800c12:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c14:	85 c0                	test   %eax,%eax
  800c16:	7e 17                	jle    800c2f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c18:	83 ec 0c             	sub    $0xc,%esp
  800c1b:	50                   	push   %eax
  800c1c:	6a 09                	push   $0x9
  800c1e:	68 9f 27 80 00       	push   $0x80279f
  800c23:	6a 23                	push   $0x23
  800c25:	68 bc 27 80 00       	push   $0x8027bc
  800c2a:	e8 89 13 00 00       	call   801fb8 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c32:	5b                   	pop    %ebx
  800c33:	5e                   	pop    %esi
  800c34:	5f                   	pop    %edi
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    

00800c37 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	53                   	push   %ebx
  800c3d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c40:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c45:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c50:	89 df                	mov    %ebx,%edi
  800c52:	89 de                	mov    %ebx,%esi
  800c54:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c56:	85 c0                	test   %eax,%eax
  800c58:	7e 17                	jle    800c71 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5a:	83 ec 0c             	sub    $0xc,%esp
  800c5d:	50                   	push   %eax
  800c5e:	6a 0a                	push   $0xa
  800c60:	68 9f 27 80 00       	push   $0x80279f
  800c65:	6a 23                	push   $0x23
  800c67:	68 bc 27 80 00       	push   $0x8027bc
  800c6c:	e8 47 13 00 00       	call   801fb8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5f                   	pop    %edi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	57                   	push   %edi
  800c7d:	56                   	push   %esi
  800c7e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7f:	be 00 00 00 00       	mov    $0x0,%esi
  800c84:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c92:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c95:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c97:	5b                   	pop    %ebx
  800c98:	5e                   	pop    %esi
  800c99:	5f                   	pop    %edi
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	57                   	push   %edi
  800ca0:	56                   	push   %esi
  800ca1:	53                   	push   %ebx
  800ca2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800caa:	b8 0d 00 00 00       	mov    $0xd,%eax
  800caf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb2:	89 cb                	mov    %ecx,%ebx
  800cb4:	89 cf                	mov    %ecx,%edi
  800cb6:	89 ce                	mov    %ecx,%esi
  800cb8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cba:	85 c0                	test   %eax,%eax
  800cbc:	7e 17                	jle    800cd5 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbe:	83 ec 0c             	sub    $0xc,%esp
  800cc1:	50                   	push   %eax
  800cc2:	6a 0d                	push   $0xd
  800cc4:	68 9f 27 80 00       	push   $0x80279f
  800cc9:	6a 23                	push   $0x23
  800ccb:	68 bc 27 80 00       	push   $0x8027bc
  800cd0:	e8 e3 12 00 00       	call   801fb8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd8:	5b                   	pop    %ebx
  800cd9:	5e                   	pop    %esi
  800cda:	5f                   	pop    %edi
  800cdb:	5d                   	pop    %ebp
  800cdc:	c3                   	ret    

00800cdd <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
  800ce0:	57                   	push   %edi
  800ce1:	56                   	push   %esi
  800ce2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce8:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ced:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf0:	89 cb                	mov    %ecx,%ebx
  800cf2:	89 cf                	mov    %ecx,%edi
  800cf4:	89 ce                	mov    %ecx,%esi
  800cf6:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800cf8:	5b                   	pop    %ebx
  800cf9:	5e                   	pop    %esi
  800cfa:	5f                   	pop    %edi
  800cfb:	5d                   	pop    %ebp
  800cfc:	c3                   	ret    

00800cfd <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
  800d00:	57                   	push   %edi
  800d01:	56                   	push   %esi
  800d02:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d03:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d08:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d10:	89 cb                	mov    %ecx,%ebx
  800d12:	89 cf                	mov    %ecx,%edi
  800d14:	89 ce                	mov    %ecx,%esi
  800d16:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    

00800d1d <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	57                   	push   %edi
  800d21:	56                   	push   %esi
  800d22:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d23:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d28:	b8 10 00 00 00       	mov    $0x10,%eax
  800d2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d30:	89 cb                	mov    %ecx,%ebx
  800d32:	89 cf                	mov    %ecx,%edi
  800d34:	89 ce                	mov    %ecx,%esi
  800d36:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  800d38:	5b                   	pop    %ebx
  800d39:	5e                   	pop    %esi
  800d3a:	5f                   	pop    %edi
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    

00800d3d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	53                   	push   %ebx
  800d41:	83 ec 04             	sub    $0x4,%esp
  800d44:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d47:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800d49:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d4d:	74 11                	je     800d60 <pgfault+0x23>
  800d4f:	89 d8                	mov    %ebx,%eax
  800d51:	c1 e8 0c             	shr    $0xc,%eax
  800d54:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d5b:	f6 c4 08             	test   $0x8,%ah
  800d5e:	75 14                	jne    800d74 <pgfault+0x37>
		panic("faulting access");
  800d60:	83 ec 04             	sub    $0x4,%esp
  800d63:	68 ca 27 80 00       	push   $0x8027ca
  800d68:	6a 1f                	push   $0x1f
  800d6a:	68 da 27 80 00       	push   $0x8027da
  800d6f:	e8 44 12 00 00       	call   801fb8 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800d74:	83 ec 04             	sub    $0x4,%esp
  800d77:	6a 07                	push   $0x7
  800d79:	68 00 f0 7f 00       	push   $0x7ff000
  800d7e:	6a 00                	push   $0x0
  800d80:	e8 67 fd ff ff       	call   800aec <sys_page_alloc>
	if (r < 0) {
  800d85:	83 c4 10             	add    $0x10,%esp
  800d88:	85 c0                	test   %eax,%eax
  800d8a:	79 12                	jns    800d9e <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800d8c:	50                   	push   %eax
  800d8d:	68 e5 27 80 00       	push   $0x8027e5
  800d92:	6a 2d                	push   $0x2d
  800d94:	68 da 27 80 00       	push   $0x8027da
  800d99:	e8 1a 12 00 00       	call   801fb8 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800d9e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800da4:	83 ec 04             	sub    $0x4,%esp
  800da7:	68 00 10 00 00       	push   $0x1000
  800dac:	53                   	push   %ebx
  800dad:	68 00 f0 7f 00       	push   $0x7ff000
  800db2:	e8 2c fb ff ff       	call   8008e3 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800db7:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800dbe:	53                   	push   %ebx
  800dbf:	6a 00                	push   $0x0
  800dc1:	68 00 f0 7f 00       	push   $0x7ff000
  800dc6:	6a 00                	push   $0x0
  800dc8:	e8 62 fd ff ff       	call   800b2f <sys_page_map>
	if (r < 0) {
  800dcd:	83 c4 20             	add    $0x20,%esp
  800dd0:	85 c0                	test   %eax,%eax
  800dd2:	79 12                	jns    800de6 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800dd4:	50                   	push   %eax
  800dd5:	68 e5 27 80 00       	push   $0x8027e5
  800dda:	6a 34                	push   $0x34
  800ddc:	68 da 27 80 00       	push   $0x8027da
  800de1:	e8 d2 11 00 00       	call   801fb8 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800de6:	83 ec 08             	sub    $0x8,%esp
  800de9:	68 00 f0 7f 00       	push   $0x7ff000
  800dee:	6a 00                	push   $0x0
  800df0:	e8 7c fd ff ff       	call   800b71 <sys_page_unmap>
	if (r < 0) {
  800df5:	83 c4 10             	add    $0x10,%esp
  800df8:	85 c0                	test   %eax,%eax
  800dfa:	79 12                	jns    800e0e <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800dfc:	50                   	push   %eax
  800dfd:	68 e5 27 80 00       	push   $0x8027e5
  800e02:	6a 38                	push   $0x38
  800e04:	68 da 27 80 00       	push   $0x8027da
  800e09:	e8 aa 11 00 00       	call   801fb8 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e11:	c9                   	leave  
  800e12:	c3                   	ret    

00800e13 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	57                   	push   %edi
  800e17:	56                   	push   %esi
  800e18:	53                   	push   %ebx
  800e19:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e1c:	68 3d 0d 80 00       	push   $0x800d3d
  800e21:	e8 d8 11 00 00       	call   801ffe <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e26:	b8 07 00 00 00       	mov    $0x7,%eax
  800e2b:	cd 30                	int    $0x30
  800e2d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800e30:	83 c4 10             	add    $0x10,%esp
  800e33:	85 c0                	test   %eax,%eax
  800e35:	79 17                	jns    800e4e <fork+0x3b>
		panic("fork fault %e");
  800e37:	83 ec 04             	sub    $0x4,%esp
  800e3a:	68 fe 27 80 00       	push   $0x8027fe
  800e3f:	68 85 00 00 00       	push   $0x85
  800e44:	68 da 27 80 00       	push   $0x8027da
  800e49:	e8 6a 11 00 00       	call   801fb8 <_panic>
  800e4e:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800e50:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e54:	75 24                	jne    800e7a <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e56:	e8 53 fc ff ff       	call   800aae <sys_getenvid>
  800e5b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e60:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  800e66:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e6b:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800e70:	b8 00 00 00 00       	mov    $0x0,%eax
  800e75:	e9 64 01 00 00       	jmp    800fde <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800e7a:	83 ec 04             	sub    $0x4,%esp
  800e7d:	6a 07                	push   $0x7
  800e7f:	68 00 f0 bf ee       	push   $0xeebff000
  800e84:	ff 75 e4             	pushl  -0x1c(%ebp)
  800e87:	e8 60 fc ff ff       	call   800aec <sys_page_alloc>
  800e8c:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800e8f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800e94:	89 d8                	mov    %ebx,%eax
  800e96:	c1 e8 16             	shr    $0x16,%eax
  800e99:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ea0:	a8 01                	test   $0x1,%al
  800ea2:	0f 84 fc 00 00 00    	je     800fa4 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800ea8:	89 d8                	mov    %ebx,%eax
  800eaa:	c1 e8 0c             	shr    $0xc,%eax
  800ead:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800eb4:	f6 c2 01             	test   $0x1,%dl
  800eb7:	0f 84 e7 00 00 00    	je     800fa4 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800ebd:	89 c6                	mov    %eax,%esi
  800ebf:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800ec2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ec9:	f6 c6 04             	test   $0x4,%dh
  800ecc:	74 39                	je     800f07 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800ece:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ed5:	83 ec 0c             	sub    $0xc,%esp
  800ed8:	25 07 0e 00 00       	and    $0xe07,%eax
  800edd:	50                   	push   %eax
  800ede:	56                   	push   %esi
  800edf:	57                   	push   %edi
  800ee0:	56                   	push   %esi
  800ee1:	6a 00                	push   $0x0
  800ee3:	e8 47 fc ff ff       	call   800b2f <sys_page_map>
		if (r < 0) {
  800ee8:	83 c4 20             	add    $0x20,%esp
  800eeb:	85 c0                	test   %eax,%eax
  800eed:	0f 89 b1 00 00 00    	jns    800fa4 <fork+0x191>
		    	panic("sys page map fault %e");
  800ef3:	83 ec 04             	sub    $0x4,%esp
  800ef6:	68 0c 28 80 00       	push   $0x80280c
  800efb:	6a 55                	push   $0x55
  800efd:	68 da 27 80 00       	push   $0x8027da
  800f02:	e8 b1 10 00 00       	call   801fb8 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f07:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f0e:	f6 c2 02             	test   $0x2,%dl
  800f11:	75 0c                	jne    800f1f <fork+0x10c>
  800f13:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f1a:	f6 c4 08             	test   $0x8,%ah
  800f1d:	74 5b                	je     800f7a <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f1f:	83 ec 0c             	sub    $0xc,%esp
  800f22:	68 05 08 00 00       	push   $0x805
  800f27:	56                   	push   %esi
  800f28:	57                   	push   %edi
  800f29:	56                   	push   %esi
  800f2a:	6a 00                	push   $0x0
  800f2c:	e8 fe fb ff ff       	call   800b2f <sys_page_map>
		if (r < 0) {
  800f31:	83 c4 20             	add    $0x20,%esp
  800f34:	85 c0                	test   %eax,%eax
  800f36:	79 14                	jns    800f4c <fork+0x139>
		    	panic("sys page map fault %e");
  800f38:	83 ec 04             	sub    $0x4,%esp
  800f3b:	68 0c 28 80 00       	push   $0x80280c
  800f40:	6a 5c                	push   $0x5c
  800f42:	68 da 27 80 00       	push   $0x8027da
  800f47:	e8 6c 10 00 00       	call   801fb8 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800f4c:	83 ec 0c             	sub    $0xc,%esp
  800f4f:	68 05 08 00 00       	push   $0x805
  800f54:	56                   	push   %esi
  800f55:	6a 00                	push   $0x0
  800f57:	56                   	push   %esi
  800f58:	6a 00                	push   $0x0
  800f5a:	e8 d0 fb ff ff       	call   800b2f <sys_page_map>
		if (r < 0) {
  800f5f:	83 c4 20             	add    $0x20,%esp
  800f62:	85 c0                	test   %eax,%eax
  800f64:	79 3e                	jns    800fa4 <fork+0x191>
		    	panic("sys page map fault %e");
  800f66:	83 ec 04             	sub    $0x4,%esp
  800f69:	68 0c 28 80 00       	push   $0x80280c
  800f6e:	6a 60                	push   $0x60
  800f70:	68 da 27 80 00       	push   $0x8027da
  800f75:	e8 3e 10 00 00       	call   801fb8 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800f7a:	83 ec 0c             	sub    $0xc,%esp
  800f7d:	6a 05                	push   $0x5
  800f7f:	56                   	push   %esi
  800f80:	57                   	push   %edi
  800f81:	56                   	push   %esi
  800f82:	6a 00                	push   $0x0
  800f84:	e8 a6 fb ff ff       	call   800b2f <sys_page_map>
		if (r < 0) {
  800f89:	83 c4 20             	add    $0x20,%esp
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	79 14                	jns    800fa4 <fork+0x191>
		    	panic("sys page map fault %e");
  800f90:	83 ec 04             	sub    $0x4,%esp
  800f93:	68 0c 28 80 00       	push   $0x80280c
  800f98:	6a 65                	push   $0x65
  800f9a:	68 da 27 80 00       	push   $0x8027da
  800f9f:	e8 14 10 00 00       	call   801fb8 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800fa4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800faa:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800fb0:	0f 85 de fe ff ff    	jne    800e94 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800fb6:	a1 04 40 80 00       	mov    0x804004,%eax
  800fbb:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
  800fc1:	83 ec 08             	sub    $0x8,%esp
  800fc4:	50                   	push   %eax
  800fc5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800fc8:	57                   	push   %edi
  800fc9:	e8 69 fc ff ff       	call   800c37 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  800fce:	83 c4 08             	add    $0x8,%esp
  800fd1:	6a 02                	push   $0x2
  800fd3:	57                   	push   %edi
  800fd4:	e8 da fb ff ff       	call   800bb3 <sys_env_set_status>
	
	return envid;
  800fd9:	83 c4 10             	add    $0x10,%esp
  800fdc:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  800fde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe1:	5b                   	pop    %ebx
  800fe2:	5e                   	pop    %esi
  800fe3:	5f                   	pop    %edi
  800fe4:	5d                   	pop    %ebp
  800fe5:	c3                   	ret    

00800fe6 <sfork>:

envid_t
sfork(void)
{
  800fe6:	55                   	push   %ebp
  800fe7:	89 e5                	mov    %esp,%ebp
	return 0;
}
  800fe9:	b8 00 00 00 00       	mov    $0x0,%eax
  800fee:	5d                   	pop    %ebp
  800fef:	c3                   	ret    

00800ff0 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	56                   	push   %esi
  800ff4:	53                   	push   %ebx
  800ff5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  800ff8:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  800ffe:	83 ec 08             	sub    $0x8,%esp
  801001:	53                   	push   %ebx
  801002:	68 9c 28 80 00       	push   $0x80289c
  801007:	e8 58 f1 ff ff       	call   800164 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80100c:	c7 04 24 97 00 80 00 	movl   $0x800097,(%esp)
  801013:	e8 c5 fc ff ff       	call   800cdd <sys_thread_create>
  801018:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80101a:	83 c4 08             	add    $0x8,%esp
  80101d:	53                   	push   %ebx
  80101e:	68 9c 28 80 00       	push   $0x80289c
  801023:	e8 3c f1 ff ff       	call   800164 <cprintf>
	return id;
}
  801028:	89 f0                	mov    %esi,%eax
  80102a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80102d:	5b                   	pop    %ebx
  80102e:	5e                   	pop    %esi
  80102f:	5d                   	pop    %ebp
  801030:	c3                   	ret    

00801031 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  801031:	55                   	push   %ebp
  801032:	89 e5                	mov    %esp,%ebp
  801034:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  801037:	ff 75 08             	pushl  0x8(%ebp)
  80103a:	e8 be fc ff ff       	call   800cfd <sys_thread_free>
}
  80103f:	83 c4 10             	add    $0x10,%esp
  801042:	c9                   	leave  
  801043:	c3                   	ret    

00801044 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  801044:	55                   	push   %ebp
  801045:	89 e5                	mov    %esp,%ebp
  801047:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  80104a:	ff 75 08             	pushl  0x8(%ebp)
  80104d:	e8 cb fc ff ff       	call   800d1d <sys_thread_join>
}
  801052:	83 c4 10             	add    $0x10,%esp
  801055:	c9                   	leave  
  801056:	c3                   	ret    

00801057 <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	56                   	push   %esi
  80105b:	53                   	push   %ebx
  80105c:	8b 75 08             	mov    0x8(%ebp),%esi
  80105f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  801062:	83 ec 04             	sub    $0x4,%esp
  801065:	6a 07                	push   $0x7
  801067:	6a 00                	push   $0x0
  801069:	56                   	push   %esi
  80106a:	e8 7d fa ff ff       	call   800aec <sys_page_alloc>
	if (r < 0) {
  80106f:	83 c4 10             	add    $0x10,%esp
  801072:	85 c0                	test   %eax,%eax
  801074:	79 15                	jns    80108b <queue_append+0x34>
		panic("%e\n", r);
  801076:	50                   	push   %eax
  801077:	68 98 28 80 00       	push   $0x802898
  80107c:	68 c4 00 00 00       	push   $0xc4
  801081:	68 da 27 80 00       	push   $0x8027da
  801086:	e8 2d 0f 00 00       	call   801fb8 <_panic>
	}	
	wt->envid = envid;
  80108b:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  801091:	83 ec 04             	sub    $0x4,%esp
  801094:	ff 33                	pushl  (%ebx)
  801096:	56                   	push   %esi
  801097:	68 c0 28 80 00       	push   $0x8028c0
  80109c:	e8 c3 f0 ff ff       	call   800164 <cprintf>
	if (queue->first == NULL) {
  8010a1:	83 c4 10             	add    $0x10,%esp
  8010a4:	83 3b 00             	cmpl   $0x0,(%ebx)
  8010a7:	75 29                	jne    8010d2 <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  8010a9:	83 ec 0c             	sub    $0xc,%esp
  8010ac:	68 22 28 80 00       	push   $0x802822
  8010b1:	e8 ae f0 ff ff       	call   800164 <cprintf>
		queue->first = wt;
  8010b6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  8010bc:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  8010c3:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8010ca:	00 00 00 
  8010cd:	83 c4 10             	add    $0x10,%esp
  8010d0:	eb 2b                	jmp    8010fd <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  8010d2:	83 ec 0c             	sub    $0xc,%esp
  8010d5:	68 3c 28 80 00       	push   $0x80283c
  8010da:	e8 85 f0 ff ff       	call   800164 <cprintf>
		queue->last->next = wt;
  8010df:	8b 43 04             	mov    0x4(%ebx),%eax
  8010e2:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  8010e9:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8010f0:	00 00 00 
		queue->last = wt;
  8010f3:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  8010fa:	83 c4 10             	add    $0x10,%esp
	}
}
  8010fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801100:	5b                   	pop    %ebx
  801101:	5e                   	pop    %esi
  801102:	5d                   	pop    %ebp
  801103:	c3                   	ret    

00801104 <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  801104:	55                   	push   %ebp
  801105:	89 e5                	mov    %esp,%ebp
  801107:	53                   	push   %ebx
  801108:	83 ec 04             	sub    $0x4,%esp
  80110b:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  80110e:	8b 02                	mov    (%edx),%eax
  801110:	85 c0                	test   %eax,%eax
  801112:	75 17                	jne    80112b <queue_pop+0x27>
		panic("queue empty!\n");
  801114:	83 ec 04             	sub    $0x4,%esp
  801117:	68 5a 28 80 00       	push   $0x80285a
  80111c:	68 d8 00 00 00       	push   $0xd8
  801121:	68 da 27 80 00       	push   $0x8027da
  801126:	e8 8d 0e 00 00       	call   801fb8 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  80112b:	8b 48 04             	mov    0x4(%eax),%ecx
  80112e:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  801130:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  801132:	83 ec 08             	sub    $0x8,%esp
  801135:	53                   	push   %ebx
  801136:	68 68 28 80 00       	push   $0x802868
  80113b:	e8 24 f0 ff ff       	call   800164 <cprintf>
	return envid;
}
  801140:	89 d8                	mov    %ebx,%eax
  801142:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801145:	c9                   	leave  
  801146:	c3                   	ret    

00801147 <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  801147:	55                   	push   %ebp
  801148:	89 e5                	mov    %esp,%ebp
  80114a:	53                   	push   %ebx
  80114b:	83 ec 04             	sub    $0x4,%esp
  80114e:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  801151:	b8 01 00 00 00       	mov    $0x1,%eax
  801156:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801159:	85 c0                	test   %eax,%eax
  80115b:	74 5a                	je     8011b7 <mutex_lock+0x70>
  80115d:	8b 43 04             	mov    0x4(%ebx),%eax
  801160:	83 38 00             	cmpl   $0x0,(%eax)
  801163:	75 52                	jne    8011b7 <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  801165:	83 ec 0c             	sub    $0xc,%esp
  801168:	68 e8 28 80 00       	push   $0x8028e8
  80116d:	e8 f2 ef ff ff       	call   800164 <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  801172:	8b 5b 04             	mov    0x4(%ebx),%ebx
  801175:	e8 34 f9 ff ff       	call   800aae <sys_getenvid>
  80117a:	83 c4 08             	add    $0x8,%esp
  80117d:	53                   	push   %ebx
  80117e:	50                   	push   %eax
  80117f:	e8 d3 fe ff ff       	call   801057 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  801184:	e8 25 f9 ff ff       	call   800aae <sys_getenvid>
  801189:	83 c4 08             	add    $0x8,%esp
  80118c:	6a 04                	push   $0x4
  80118e:	50                   	push   %eax
  80118f:	e8 1f fa ff ff       	call   800bb3 <sys_env_set_status>
		if (r < 0) {
  801194:	83 c4 10             	add    $0x10,%esp
  801197:	85 c0                	test   %eax,%eax
  801199:	79 15                	jns    8011b0 <mutex_lock+0x69>
			panic("%e\n", r);
  80119b:	50                   	push   %eax
  80119c:	68 98 28 80 00       	push   $0x802898
  8011a1:	68 eb 00 00 00       	push   $0xeb
  8011a6:	68 da 27 80 00       	push   $0x8027da
  8011ab:	e8 08 0e 00 00       	call   801fb8 <_panic>
		}
		sys_yield();
  8011b0:	e8 18 f9 ff ff       	call   800acd <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8011b5:	eb 18                	jmp    8011cf <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  8011b7:	83 ec 0c             	sub    $0xc,%esp
  8011ba:	68 08 29 80 00       	push   $0x802908
  8011bf:	e8 a0 ef ff ff       	call   800164 <cprintf>
	mtx->owner = sys_getenvid();}
  8011c4:	e8 e5 f8 ff ff       	call   800aae <sys_getenvid>
  8011c9:	89 43 08             	mov    %eax,0x8(%ebx)
  8011cc:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  8011cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011d2:	c9                   	leave  
  8011d3:	c3                   	ret    

008011d4 <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  8011d4:	55                   	push   %ebp
  8011d5:	89 e5                	mov    %esp,%ebp
  8011d7:	53                   	push   %ebx
  8011d8:	83 ec 04             	sub    $0x4,%esp
  8011db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8011de:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e3:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  8011e6:	8b 43 04             	mov    0x4(%ebx),%eax
  8011e9:	83 38 00             	cmpl   $0x0,(%eax)
  8011ec:	74 33                	je     801221 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  8011ee:	83 ec 0c             	sub    $0xc,%esp
  8011f1:	50                   	push   %eax
  8011f2:	e8 0d ff ff ff       	call   801104 <queue_pop>
  8011f7:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8011fa:	83 c4 08             	add    $0x8,%esp
  8011fd:	6a 02                	push   $0x2
  8011ff:	50                   	push   %eax
  801200:	e8 ae f9 ff ff       	call   800bb3 <sys_env_set_status>
		if (r < 0) {
  801205:	83 c4 10             	add    $0x10,%esp
  801208:	85 c0                	test   %eax,%eax
  80120a:	79 15                	jns    801221 <mutex_unlock+0x4d>
			panic("%e\n", r);
  80120c:	50                   	push   %eax
  80120d:	68 98 28 80 00       	push   $0x802898
  801212:	68 00 01 00 00       	push   $0x100
  801217:	68 da 27 80 00       	push   $0x8027da
  80121c:	e8 97 0d 00 00       	call   801fb8 <_panic>
		}
	}

	asm volatile("pause");
  801221:	f3 90                	pause  
	//sys_yield();
}
  801223:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801226:	c9                   	leave  
  801227:	c3                   	ret    

00801228 <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
  80122b:	53                   	push   %ebx
  80122c:	83 ec 04             	sub    $0x4,%esp
  80122f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  801232:	e8 77 f8 ff ff       	call   800aae <sys_getenvid>
  801237:	83 ec 04             	sub    $0x4,%esp
  80123a:	6a 07                	push   $0x7
  80123c:	53                   	push   %ebx
  80123d:	50                   	push   %eax
  80123e:	e8 a9 f8 ff ff       	call   800aec <sys_page_alloc>
  801243:	83 c4 10             	add    $0x10,%esp
  801246:	85 c0                	test   %eax,%eax
  801248:	79 15                	jns    80125f <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  80124a:	50                   	push   %eax
  80124b:	68 83 28 80 00       	push   $0x802883
  801250:	68 0d 01 00 00       	push   $0x10d
  801255:	68 da 27 80 00       	push   $0x8027da
  80125a:	e8 59 0d 00 00       	call   801fb8 <_panic>
	}	
	mtx->locked = 0;
  80125f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  801265:	8b 43 04             	mov    0x4(%ebx),%eax
  801268:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  80126e:	8b 43 04             	mov    0x4(%ebx),%eax
  801271:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  801278:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  80127f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801282:	c9                   	leave  
  801283:	c3                   	ret    

00801284 <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  801284:	55                   	push   %ebp
  801285:	89 e5                	mov    %esp,%ebp
  801287:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  80128a:	e8 1f f8 ff ff       	call   800aae <sys_getenvid>
  80128f:	83 ec 08             	sub    $0x8,%esp
  801292:	ff 75 08             	pushl  0x8(%ebp)
  801295:	50                   	push   %eax
  801296:	e8 d6 f8 ff ff       	call   800b71 <sys_page_unmap>
	if (r < 0) {
  80129b:	83 c4 10             	add    $0x10,%esp
  80129e:	85 c0                	test   %eax,%eax
  8012a0:	79 15                	jns    8012b7 <mutex_destroy+0x33>
		panic("%e\n", r);
  8012a2:	50                   	push   %eax
  8012a3:	68 98 28 80 00       	push   $0x802898
  8012a8:	68 1a 01 00 00       	push   $0x11a
  8012ad:	68 da 27 80 00       	push   $0x8027da
  8012b2:	e8 01 0d 00 00       	call   801fb8 <_panic>
	}
}
  8012b7:	c9                   	leave  
  8012b8:	c3                   	ret    

008012b9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012b9:	55                   	push   %ebp
  8012ba:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8012bf:	05 00 00 00 30       	add    $0x30000000,%eax
  8012c4:	c1 e8 0c             	shr    $0xc,%eax
}
  8012c7:	5d                   	pop    %ebp
  8012c8:	c3                   	ret    

008012c9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012c9:	55                   	push   %ebp
  8012ca:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8012cf:	05 00 00 00 30       	add    $0x30000000,%eax
  8012d4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012d9:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012de:	5d                   	pop    %ebp
  8012df:	c3                   	ret    

008012e0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012e0:	55                   	push   %ebp
  8012e1:	89 e5                	mov    %esp,%ebp
  8012e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012eb:	89 c2                	mov    %eax,%edx
  8012ed:	c1 ea 16             	shr    $0x16,%edx
  8012f0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012f7:	f6 c2 01             	test   $0x1,%dl
  8012fa:	74 11                	je     80130d <fd_alloc+0x2d>
  8012fc:	89 c2                	mov    %eax,%edx
  8012fe:	c1 ea 0c             	shr    $0xc,%edx
  801301:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801308:	f6 c2 01             	test   $0x1,%dl
  80130b:	75 09                	jne    801316 <fd_alloc+0x36>
			*fd_store = fd;
  80130d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80130f:	b8 00 00 00 00       	mov    $0x0,%eax
  801314:	eb 17                	jmp    80132d <fd_alloc+0x4d>
  801316:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80131b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801320:	75 c9                	jne    8012eb <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801322:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801328:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80132d:	5d                   	pop    %ebp
  80132e:	c3                   	ret    

0080132f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80132f:	55                   	push   %ebp
  801330:	89 e5                	mov    %esp,%ebp
  801332:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801335:	83 f8 1f             	cmp    $0x1f,%eax
  801338:	77 36                	ja     801370 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80133a:	c1 e0 0c             	shl    $0xc,%eax
  80133d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801342:	89 c2                	mov    %eax,%edx
  801344:	c1 ea 16             	shr    $0x16,%edx
  801347:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80134e:	f6 c2 01             	test   $0x1,%dl
  801351:	74 24                	je     801377 <fd_lookup+0x48>
  801353:	89 c2                	mov    %eax,%edx
  801355:	c1 ea 0c             	shr    $0xc,%edx
  801358:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80135f:	f6 c2 01             	test   $0x1,%dl
  801362:	74 1a                	je     80137e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801364:	8b 55 0c             	mov    0xc(%ebp),%edx
  801367:	89 02                	mov    %eax,(%edx)
	return 0;
  801369:	b8 00 00 00 00       	mov    $0x0,%eax
  80136e:	eb 13                	jmp    801383 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801370:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801375:	eb 0c                	jmp    801383 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801377:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80137c:	eb 05                	jmp    801383 <fd_lookup+0x54>
  80137e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801383:	5d                   	pop    %ebp
  801384:	c3                   	ret    

00801385 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801385:	55                   	push   %ebp
  801386:	89 e5                	mov    %esp,%ebp
  801388:	83 ec 08             	sub    $0x8,%esp
  80138b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80138e:	ba a4 29 80 00       	mov    $0x8029a4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801393:	eb 13                	jmp    8013a8 <dev_lookup+0x23>
  801395:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801398:	39 08                	cmp    %ecx,(%eax)
  80139a:	75 0c                	jne    8013a8 <dev_lookup+0x23>
			*dev = devtab[i];
  80139c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80139f:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a6:	eb 31                	jmp    8013d9 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013a8:	8b 02                	mov    (%edx),%eax
  8013aa:	85 c0                	test   %eax,%eax
  8013ac:	75 e7                	jne    801395 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013ae:	a1 04 40 80 00       	mov    0x804004,%eax
  8013b3:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8013b9:	83 ec 04             	sub    $0x4,%esp
  8013bc:	51                   	push   %ecx
  8013bd:	50                   	push   %eax
  8013be:	68 28 29 80 00       	push   $0x802928
  8013c3:	e8 9c ed ff ff       	call   800164 <cprintf>
	*dev = 0;
  8013c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013cb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013d1:	83 c4 10             	add    $0x10,%esp
  8013d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013d9:	c9                   	leave  
  8013da:	c3                   	ret    

008013db <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013db:	55                   	push   %ebp
  8013dc:	89 e5                	mov    %esp,%ebp
  8013de:	56                   	push   %esi
  8013df:	53                   	push   %ebx
  8013e0:	83 ec 10             	sub    $0x10,%esp
  8013e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8013e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ec:	50                   	push   %eax
  8013ed:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013f3:	c1 e8 0c             	shr    $0xc,%eax
  8013f6:	50                   	push   %eax
  8013f7:	e8 33 ff ff ff       	call   80132f <fd_lookup>
  8013fc:	83 c4 08             	add    $0x8,%esp
  8013ff:	85 c0                	test   %eax,%eax
  801401:	78 05                	js     801408 <fd_close+0x2d>
	    || fd != fd2)
  801403:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801406:	74 0c                	je     801414 <fd_close+0x39>
		return (must_exist ? r : 0);
  801408:	84 db                	test   %bl,%bl
  80140a:	ba 00 00 00 00       	mov    $0x0,%edx
  80140f:	0f 44 c2             	cmove  %edx,%eax
  801412:	eb 41                	jmp    801455 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801414:	83 ec 08             	sub    $0x8,%esp
  801417:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80141a:	50                   	push   %eax
  80141b:	ff 36                	pushl  (%esi)
  80141d:	e8 63 ff ff ff       	call   801385 <dev_lookup>
  801422:	89 c3                	mov    %eax,%ebx
  801424:	83 c4 10             	add    $0x10,%esp
  801427:	85 c0                	test   %eax,%eax
  801429:	78 1a                	js     801445 <fd_close+0x6a>
		if (dev->dev_close)
  80142b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801431:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801436:	85 c0                	test   %eax,%eax
  801438:	74 0b                	je     801445 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80143a:	83 ec 0c             	sub    $0xc,%esp
  80143d:	56                   	push   %esi
  80143e:	ff d0                	call   *%eax
  801440:	89 c3                	mov    %eax,%ebx
  801442:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801445:	83 ec 08             	sub    $0x8,%esp
  801448:	56                   	push   %esi
  801449:	6a 00                	push   $0x0
  80144b:	e8 21 f7 ff ff       	call   800b71 <sys_page_unmap>
	return r;
  801450:	83 c4 10             	add    $0x10,%esp
  801453:	89 d8                	mov    %ebx,%eax
}
  801455:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801458:	5b                   	pop    %ebx
  801459:	5e                   	pop    %esi
  80145a:	5d                   	pop    %ebp
  80145b:	c3                   	ret    

0080145c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80145c:	55                   	push   %ebp
  80145d:	89 e5                	mov    %esp,%ebp
  80145f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801462:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801465:	50                   	push   %eax
  801466:	ff 75 08             	pushl  0x8(%ebp)
  801469:	e8 c1 fe ff ff       	call   80132f <fd_lookup>
  80146e:	83 c4 08             	add    $0x8,%esp
  801471:	85 c0                	test   %eax,%eax
  801473:	78 10                	js     801485 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801475:	83 ec 08             	sub    $0x8,%esp
  801478:	6a 01                	push   $0x1
  80147a:	ff 75 f4             	pushl  -0xc(%ebp)
  80147d:	e8 59 ff ff ff       	call   8013db <fd_close>
  801482:	83 c4 10             	add    $0x10,%esp
}
  801485:	c9                   	leave  
  801486:	c3                   	ret    

00801487 <close_all>:

void
close_all(void)
{
  801487:	55                   	push   %ebp
  801488:	89 e5                	mov    %esp,%ebp
  80148a:	53                   	push   %ebx
  80148b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80148e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801493:	83 ec 0c             	sub    $0xc,%esp
  801496:	53                   	push   %ebx
  801497:	e8 c0 ff ff ff       	call   80145c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80149c:	83 c3 01             	add    $0x1,%ebx
  80149f:	83 c4 10             	add    $0x10,%esp
  8014a2:	83 fb 20             	cmp    $0x20,%ebx
  8014a5:	75 ec                	jne    801493 <close_all+0xc>
		close(i);
}
  8014a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014aa:	c9                   	leave  
  8014ab:	c3                   	ret    

008014ac <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014ac:	55                   	push   %ebp
  8014ad:	89 e5                	mov    %esp,%ebp
  8014af:	57                   	push   %edi
  8014b0:	56                   	push   %esi
  8014b1:	53                   	push   %ebx
  8014b2:	83 ec 2c             	sub    $0x2c,%esp
  8014b5:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014b8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014bb:	50                   	push   %eax
  8014bc:	ff 75 08             	pushl  0x8(%ebp)
  8014bf:	e8 6b fe ff ff       	call   80132f <fd_lookup>
  8014c4:	83 c4 08             	add    $0x8,%esp
  8014c7:	85 c0                	test   %eax,%eax
  8014c9:	0f 88 c1 00 00 00    	js     801590 <dup+0xe4>
		return r;
	close(newfdnum);
  8014cf:	83 ec 0c             	sub    $0xc,%esp
  8014d2:	56                   	push   %esi
  8014d3:	e8 84 ff ff ff       	call   80145c <close>

	newfd = INDEX2FD(newfdnum);
  8014d8:	89 f3                	mov    %esi,%ebx
  8014da:	c1 e3 0c             	shl    $0xc,%ebx
  8014dd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014e3:	83 c4 04             	add    $0x4,%esp
  8014e6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014e9:	e8 db fd ff ff       	call   8012c9 <fd2data>
  8014ee:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014f0:	89 1c 24             	mov    %ebx,(%esp)
  8014f3:	e8 d1 fd ff ff       	call   8012c9 <fd2data>
  8014f8:	83 c4 10             	add    $0x10,%esp
  8014fb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014fe:	89 f8                	mov    %edi,%eax
  801500:	c1 e8 16             	shr    $0x16,%eax
  801503:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80150a:	a8 01                	test   $0x1,%al
  80150c:	74 37                	je     801545 <dup+0x99>
  80150e:	89 f8                	mov    %edi,%eax
  801510:	c1 e8 0c             	shr    $0xc,%eax
  801513:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80151a:	f6 c2 01             	test   $0x1,%dl
  80151d:	74 26                	je     801545 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80151f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801526:	83 ec 0c             	sub    $0xc,%esp
  801529:	25 07 0e 00 00       	and    $0xe07,%eax
  80152e:	50                   	push   %eax
  80152f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801532:	6a 00                	push   $0x0
  801534:	57                   	push   %edi
  801535:	6a 00                	push   $0x0
  801537:	e8 f3 f5 ff ff       	call   800b2f <sys_page_map>
  80153c:	89 c7                	mov    %eax,%edi
  80153e:	83 c4 20             	add    $0x20,%esp
  801541:	85 c0                	test   %eax,%eax
  801543:	78 2e                	js     801573 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801545:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801548:	89 d0                	mov    %edx,%eax
  80154a:	c1 e8 0c             	shr    $0xc,%eax
  80154d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801554:	83 ec 0c             	sub    $0xc,%esp
  801557:	25 07 0e 00 00       	and    $0xe07,%eax
  80155c:	50                   	push   %eax
  80155d:	53                   	push   %ebx
  80155e:	6a 00                	push   $0x0
  801560:	52                   	push   %edx
  801561:	6a 00                	push   $0x0
  801563:	e8 c7 f5 ff ff       	call   800b2f <sys_page_map>
  801568:	89 c7                	mov    %eax,%edi
  80156a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80156d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80156f:	85 ff                	test   %edi,%edi
  801571:	79 1d                	jns    801590 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801573:	83 ec 08             	sub    $0x8,%esp
  801576:	53                   	push   %ebx
  801577:	6a 00                	push   $0x0
  801579:	e8 f3 f5 ff ff       	call   800b71 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80157e:	83 c4 08             	add    $0x8,%esp
  801581:	ff 75 d4             	pushl  -0x2c(%ebp)
  801584:	6a 00                	push   $0x0
  801586:	e8 e6 f5 ff ff       	call   800b71 <sys_page_unmap>
	return r;
  80158b:	83 c4 10             	add    $0x10,%esp
  80158e:	89 f8                	mov    %edi,%eax
}
  801590:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801593:	5b                   	pop    %ebx
  801594:	5e                   	pop    %esi
  801595:	5f                   	pop    %edi
  801596:	5d                   	pop    %ebp
  801597:	c3                   	ret    

00801598 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801598:	55                   	push   %ebp
  801599:	89 e5                	mov    %esp,%ebp
  80159b:	53                   	push   %ebx
  80159c:	83 ec 14             	sub    $0x14,%esp
  80159f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a5:	50                   	push   %eax
  8015a6:	53                   	push   %ebx
  8015a7:	e8 83 fd ff ff       	call   80132f <fd_lookup>
  8015ac:	83 c4 08             	add    $0x8,%esp
  8015af:	89 c2                	mov    %eax,%edx
  8015b1:	85 c0                	test   %eax,%eax
  8015b3:	78 70                	js     801625 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b5:	83 ec 08             	sub    $0x8,%esp
  8015b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015bb:	50                   	push   %eax
  8015bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015bf:	ff 30                	pushl  (%eax)
  8015c1:	e8 bf fd ff ff       	call   801385 <dev_lookup>
  8015c6:	83 c4 10             	add    $0x10,%esp
  8015c9:	85 c0                	test   %eax,%eax
  8015cb:	78 4f                	js     80161c <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015cd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015d0:	8b 42 08             	mov    0x8(%edx),%eax
  8015d3:	83 e0 03             	and    $0x3,%eax
  8015d6:	83 f8 01             	cmp    $0x1,%eax
  8015d9:	75 24                	jne    8015ff <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015db:	a1 04 40 80 00       	mov    0x804004,%eax
  8015e0:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8015e6:	83 ec 04             	sub    $0x4,%esp
  8015e9:	53                   	push   %ebx
  8015ea:	50                   	push   %eax
  8015eb:	68 69 29 80 00       	push   $0x802969
  8015f0:	e8 6f eb ff ff       	call   800164 <cprintf>
		return -E_INVAL;
  8015f5:	83 c4 10             	add    $0x10,%esp
  8015f8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015fd:	eb 26                	jmp    801625 <read+0x8d>
	}
	if (!dev->dev_read)
  8015ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801602:	8b 40 08             	mov    0x8(%eax),%eax
  801605:	85 c0                	test   %eax,%eax
  801607:	74 17                	je     801620 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801609:	83 ec 04             	sub    $0x4,%esp
  80160c:	ff 75 10             	pushl  0x10(%ebp)
  80160f:	ff 75 0c             	pushl  0xc(%ebp)
  801612:	52                   	push   %edx
  801613:	ff d0                	call   *%eax
  801615:	89 c2                	mov    %eax,%edx
  801617:	83 c4 10             	add    $0x10,%esp
  80161a:	eb 09                	jmp    801625 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161c:	89 c2                	mov    %eax,%edx
  80161e:	eb 05                	jmp    801625 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801620:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801625:	89 d0                	mov    %edx,%eax
  801627:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80162a:	c9                   	leave  
  80162b:	c3                   	ret    

0080162c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80162c:	55                   	push   %ebp
  80162d:	89 e5                	mov    %esp,%ebp
  80162f:	57                   	push   %edi
  801630:	56                   	push   %esi
  801631:	53                   	push   %ebx
  801632:	83 ec 0c             	sub    $0xc,%esp
  801635:	8b 7d 08             	mov    0x8(%ebp),%edi
  801638:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80163b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801640:	eb 21                	jmp    801663 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801642:	83 ec 04             	sub    $0x4,%esp
  801645:	89 f0                	mov    %esi,%eax
  801647:	29 d8                	sub    %ebx,%eax
  801649:	50                   	push   %eax
  80164a:	89 d8                	mov    %ebx,%eax
  80164c:	03 45 0c             	add    0xc(%ebp),%eax
  80164f:	50                   	push   %eax
  801650:	57                   	push   %edi
  801651:	e8 42 ff ff ff       	call   801598 <read>
		if (m < 0)
  801656:	83 c4 10             	add    $0x10,%esp
  801659:	85 c0                	test   %eax,%eax
  80165b:	78 10                	js     80166d <readn+0x41>
			return m;
		if (m == 0)
  80165d:	85 c0                	test   %eax,%eax
  80165f:	74 0a                	je     80166b <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801661:	01 c3                	add    %eax,%ebx
  801663:	39 f3                	cmp    %esi,%ebx
  801665:	72 db                	jb     801642 <readn+0x16>
  801667:	89 d8                	mov    %ebx,%eax
  801669:	eb 02                	jmp    80166d <readn+0x41>
  80166b:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80166d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801670:	5b                   	pop    %ebx
  801671:	5e                   	pop    %esi
  801672:	5f                   	pop    %edi
  801673:	5d                   	pop    %ebp
  801674:	c3                   	ret    

00801675 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801675:	55                   	push   %ebp
  801676:	89 e5                	mov    %esp,%ebp
  801678:	53                   	push   %ebx
  801679:	83 ec 14             	sub    $0x14,%esp
  80167c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80167f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801682:	50                   	push   %eax
  801683:	53                   	push   %ebx
  801684:	e8 a6 fc ff ff       	call   80132f <fd_lookup>
  801689:	83 c4 08             	add    $0x8,%esp
  80168c:	89 c2                	mov    %eax,%edx
  80168e:	85 c0                	test   %eax,%eax
  801690:	78 6b                	js     8016fd <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801692:	83 ec 08             	sub    $0x8,%esp
  801695:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801698:	50                   	push   %eax
  801699:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80169c:	ff 30                	pushl  (%eax)
  80169e:	e8 e2 fc ff ff       	call   801385 <dev_lookup>
  8016a3:	83 c4 10             	add    $0x10,%esp
  8016a6:	85 c0                	test   %eax,%eax
  8016a8:	78 4a                	js     8016f4 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ad:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016b1:	75 24                	jne    8016d7 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016b3:	a1 04 40 80 00       	mov    0x804004,%eax
  8016b8:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8016be:	83 ec 04             	sub    $0x4,%esp
  8016c1:	53                   	push   %ebx
  8016c2:	50                   	push   %eax
  8016c3:	68 85 29 80 00       	push   $0x802985
  8016c8:	e8 97 ea ff ff       	call   800164 <cprintf>
		return -E_INVAL;
  8016cd:	83 c4 10             	add    $0x10,%esp
  8016d0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016d5:	eb 26                	jmp    8016fd <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016da:	8b 52 0c             	mov    0xc(%edx),%edx
  8016dd:	85 d2                	test   %edx,%edx
  8016df:	74 17                	je     8016f8 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016e1:	83 ec 04             	sub    $0x4,%esp
  8016e4:	ff 75 10             	pushl  0x10(%ebp)
  8016e7:	ff 75 0c             	pushl  0xc(%ebp)
  8016ea:	50                   	push   %eax
  8016eb:	ff d2                	call   *%edx
  8016ed:	89 c2                	mov    %eax,%edx
  8016ef:	83 c4 10             	add    $0x10,%esp
  8016f2:	eb 09                	jmp    8016fd <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f4:	89 c2                	mov    %eax,%edx
  8016f6:	eb 05                	jmp    8016fd <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016f8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016fd:	89 d0                	mov    %edx,%eax
  8016ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801702:	c9                   	leave  
  801703:	c3                   	ret    

00801704 <seek>:

int
seek(int fdnum, off_t offset)
{
  801704:	55                   	push   %ebp
  801705:	89 e5                	mov    %esp,%ebp
  801707:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80170a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80170d:	50                   	push   %eax
  80170e:	ff 75 08             	pushl  0x8(%ebp)
  801711:	e8 19 fc ff ff       	call   80132f <fd_lookup>
  801716:	83 c4 08             	add    $0x8,%esp
  801719:	85 c0                	test   %eax,%eax
  80171b:	78 0e                	js     80172b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80171d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801720:	8b 55 0c             	mov    0xc(%ebp),%edx
  801723:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801726:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80172b:	c9                   	leave  
  80172c:	c3                   	ret    

0080172d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	53                   	push   %ebx
  801731:	83 ec 14             	sub    $0x14,%esp
  801734:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801737:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80173a:	50                   	push   %eax
  80173b:	53                   	push   %ebx
  80173c:	e8 ee fb ff ff       	call   80132f <fd_lookup>
  801741:	83 c4 08             	add    $0x8,%esp
  801744:	89 c2                	mov    %eax,%edx
  801746:	85 c0                	test   %eax,%eax
  801748:	78 68                	js     8017b2 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80174a:	83 ec 08             	sub    $0x8,%esp
  80174d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801750:	50                   	push   %eax
  801751:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801754:	ff 30                	pushl  (%eax)
  801756:	e8 2a fc ff ff       	call   801385 <dev_lookup>
  80175b:	83 c4 10             	add    $0x10,%esp
  80175e:	85 c0                	test   %eax,%eax
  801760:	78 47                	js     8017a9 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801762:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801765:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801769:	75 24                	jne    80178f <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80176b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801770:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801776:	83 ec 04             	sub    $0x4,%esp
  801779:	53                   	push   %ebx
  80177a:	50                   	push   %eax
  80177b:	68 48 29 80 00       	push   $0x802948
  801780:	e8 df e9 ff ff       	call   800164 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801785:	83 c4 10             	add    $0x10,%esp
  801788:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80178d:	eb 23                	jmp    8017b2 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  80178f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801792:	8b 52 18             	mov    0x18(%edx),%edx
  801795:	85 d2                	test   %edx,%edx
  801797:	74 14                	je     8017ad <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801799:	83 ec 08             	sub    $0x8,%esp
  80179c:	ff 75 0c             	pushl  0xc(%ebp)
  80179f:	50                   	push   %eax
  8017a0:	ff d2                	call   *%edx
  8017a2:	89 c2                	mov    %eax,%edx
  8017a4:	83 c4 10             	add    $0x10,%esp
  8017a7:	eb 09                	jmp    8017b2 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a9:	89 c2                	mov    %eax,%edx
  8017ab:	eb 05                	jmp    8017b2 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017ad:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017b2:	89 d0                	mov    %edx,%eax
  8017b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b7:	c9                   	leave  
  8017b8:	c3                   	ret    

008017b9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017b9:	55                   	push   %ebp
  8017ba:	89 e5                	mov    %esp,%ebp
  8017bc:	53                   	push   %ebx
  8017bd:	83 ec 14             	sub    $0x14,%esp
  8017c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017c6:	50                   	push   %eax
  8017c7:	ff 75 08             	pushl  0x8(%ebp)
  8017ca:	e8 60 fb ff ff       	call   80132f <fd_lookup>
  8017cf:	83 c4 08             	add    $0x8,%esp
  8017d2:	89 c2                	mov    %eax,%edx
  8017d4:	85 c0                	test   %eax,%eax
  8017d6:	78 58                	js     801830 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017d8:	83 ec 08             	sub    $0x8,%esp
  8017db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017de:	50                   	push   %eax
  8017df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e2:	ff 30                	pushl  (%eax)
  8017e4:	e8 9c fb ff ff       	call   801385 <dev_lookup>
  8017e9:	83 c4 10             	add    $0x10,%esp
  8017ec:	85 c0                	test   %eax,%eax
  8017ee:	78 37                	js     801827 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017f3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017f7:	74 32                	je     80182b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017f9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017fc:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801803:	00 00 00 
	stat->st_isdir = 0;
  801806:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80180d:	00 00 00 
	stat->st_dev = dev;
  801810:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801816:	83 ec 08             	sub    $0x8,%esp
  801819:	53                   	push   %ebx
  80181a:	ff 75 f0             	pushl  -0x10(%ebp)
  80181d:	ff 50 14             	call   *0x14(%eax)
  801820:	89 c2                	mov    %eax,%edx
  801822:	83 c4 10             	add    $0x10,%esp
  801825:	eb 09                	jmp    801830 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801827:	89 c2                	mov    %eax,%edx
  801829:	eb 05                	jmp    801830 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80182b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801830:	89 d0                	mov    %edx,%eax
  801832:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801835:	c9                   	leave  
  801836:	c3                   	ret    

00801837 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801837:	55                   	push   %ebp
  801838:	89 e5                	mov    %esp,%ebp
  80183a:	56                   	push   %esi
  80183b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80183c:	83 ec 08             	sub    $0x8,%esp
  80183f:	6a 00                	push   $0x0
  801841:	ff 75 08             	pushl  0x8(%ebp)
  801844:	e8 e3 01 00 00       	call   801a2c <open>
  801849:	89 c3                	mov    %eax,%ebx
  80184b:	83 c4 10             	add    $0x10,%esp
  80184e:	85 c0                	test   %eax,%eax
  801850:	78 1b                	js     80186d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801852:	83 ec 08             	sub    $0x8,%esp
  801855:	ff 75 0c             	pushl  0xc(%ebp)
  801858:	50                   	push   %eax
  801859:	e8 5b ff ff ff       	call   8017b9 <fstat>
  80185e:	89 c6                	mov    %eax,%esi
	close(fd);
  801860:	89 1c 24             	mov    %ebx,(%esp)
  801863:	e8 f4 fb ff ff       	call   80145c <close>
	return r;
  801868:	83 c4 10             	add    $0x10,%esp
  80186b:	89 f0                	mov    %esi,%eax
}
  80186d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801870:	5b                   	pop    %ebx
  801871:	5e                   	pop    %esi
  801872:	5d                   	pop    %ebp
  801873:	c3                   	ret    

00801874 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801874:	55                   	push   %ebp
  801875:	89 e5                	mov    %esp,%ebp
  801877:	56                   	push   %esi
  801878:	53                   	push   %ebx
  801879:	89 c6                	mov    %eax,%esi
  80187b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80187d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801884:	75 12                	jne    801898 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801886:	83 ec 0c             	sub    $0xc,%esp
  801889:	6a 01                	push   $0x1
  80188b:	e8 da 08 00 00       	call   80216a <ipc_find_env>
  801890:	a3 00 40 80 00       	mov    %eax,0x804000
  801895:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801898:	6a 07                	push   $0x7
  80189a:	68 00 50 80 00       	push   $0x805000
  80189f:	56                   	push   %esi
  8018a0:	ff 35 00 40 80 00    	pushl  0x804000
  8018a6:	e8 5d 08 00 00       	call   802108 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018ab:	83 c4 0c             	add    $0xc,%esp
  8018ae:	6a 00                	push   $0x0
  8018b0:	53                   	push   %ebx
  8018b1:	6a 00                	push   $0x0
  8018b3:	e8 d5 07 00 00       	call   80208d <ipc_recv>
}
  8018b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018bb:	5b                   	pop    %ebx
  8018bc:	5e                   	pop    %esi
  8018bd:	5d                   	pop    %ebp
  8018be:	c3                   	ret    

008018bf <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
  8018c2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c8:	8b 40 0c             	mov    0xc(%eax),%eax
  8018cb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018d3:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018dd:	b8 02 00 00 00       	mov    $0x2,%eax
  8018e2:	e8 8d ff ff ff       	call   801874 <fsipc>
}
  8018e7:	c9                   	leave  
  8018e8:	c3                   	ret    

008018e9 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018e9:	55                   	push   %ebp
  8018ea:	89 e5                	mov    %esp,%ebp
  8018ec:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f2:	8b 40 0c             	mov    0xc(%eax),%eax
  8018f5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ff:	b8 06 00 00 00       	mov    $0x6,%eax
  801904:	e8 6b ff ff ff       	call   801874 <fsipc>
}
  801909:	c9                   	leave  
  80190a:	c3                   	ret    

0080190b <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80190b:	55                   	push   %ebp
  80190c:	89 e5                	mov    %esp,%ebp
  80190e:	53                   	push   %ebx
  80190f:	83 ec 04             	sub    $0x4,%esp
  801912:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801915:	8b 45 08             	mov    0x8(%ebp),%eax
  801918:	8b 40 0c             	mov    0xc(%eax),%eax
  80191b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801920:	ba 00 00 00 00       	mov    $0x0,%edx
  801925:	b8 05 00 00 00       	mov    $0x5,%eax
  80192a:	e8 45 ff ff ff       	call   801874 <fsipc>
  80192f:	85 c0                	test   %eax,%eax
  801931:	78 2c                	js     80195f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801933:	83 ec 08             	sub    $0x8,%esp
  801936:	68 00 50 80 00       	push   $0x805000
  80193b:	53                   	push   %ebx
  80193c:	e8 a8 ed ff ff       	call   8006e9 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801941:	a1 80 50 80 00       	mov    0x805080,%eax
  801946:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80194c:	a1 84 50 80 00       	mov    0x805084,%eax
  801951:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801957:	83 c4 10             	add    $0x10,%esp
  80195a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80195f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801962:	c9                   	leave  
  801963:	c3                   	ret    

00801964 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801964:	55                   	push   %ebp
  801965:	89 e5                	mov    %esp,%ebp
  801967:	83 ec 0c             	sub    $0xc,%esp
  80196a:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80196d:	8b 55 08             	mov    0x8(%ebp),%edx
  801970:	8b 52 0c             	mov    0xc(%edx),%edx
  801973:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801979:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80197e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801983:	0f 47 c2             	cmova  %edx,%eax
  801986:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80198b:	50                   	push   %eax
  80198c:	ff 75 0c             	pushl  0xc(%ebp)
  80198f:	68 08 50 80 00       	push   $0x805008
  801994:	e8 e2 ee ff ff       	call   80087b <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801999:	ba 00 00 00 00       	mov    $0x0,%edx
  80199e:	b8 04 00 00 00       	mov    $0x4,%eax
  8019a3:	e8 cc fe ff ff       	call   801874 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8019a8:	c9                   	leave  
  8019a9:	c3                   	ret    

008019aa <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019aa:	55                   	push   %ebp
  8019ab:	89 e5                	mov    %esp,%ebp
  8019ad:	56                   	push   %esi
  8019ae:	53                   	push   %ebx
  8019af:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8019b8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019bd:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c8:	b8 03 00 00 00       	mov    $0x3,%eax
  8019cd:	e8 a2 fe ff ff       	call   801874 <fsipc>
  8019d2:	89 c3                	mov    %eax,%ebx
  8019d4:	85 c0                	test   %eax,%eax
  8019d6:	78 4b                	js     801a23 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019d8:	39 c6                	cmp    %eax,%esi
  8019da:	73 16                	jae    8019f2 <devfile_read+0x48>
  8019dc:	68 b4 29 80 00       	push   $0x8029b4
  8019e1:	68 bb 29 80 00       	push   $0x8029bb
  8019e6:	6a 7c                	push   $0x7c
  8019e8:	68 d0 29 80 00       	push   $0x8029d0
  8019ed:	e8 c6 05 00 00       	call   801fb8 <_panic>
	assert(r <= PGSIZE);
  8019f2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019f7:	7e 16                	jle    801a0f <devfile_read+0x65>
  8019f9:	68 db 29 80 00       	push   $0x8029db
  8019fe:	68 bb 29 80 00       	push   $0x8029bb
  801a03:	6a 7d                	push   $0x7d
  801a05:	68 d0 29 80 00       	push   $0x8029d0
  801a0a:	e8 a9 05 00 00       	call   801fb8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a0f:	83 ec 04             	sub    $0x4,%esp
  801a12:	50                   	push   %eax
  801a13:	68 00 50 80 00       	push   $0x805000
  801a18:	ff 75 0c             	pushl  0xc(%ebp)
  801a1b:	e8 5b ee ff ff       	call   80087b <memmove>
	return r;
  801a20:	83 c4 10             	add    $0x10,%esp
}
  801a23:	89 d8                	mov    %ebx,%eax
  801a25:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a28:	5b                   	pop    %ebx
  801a29:	5e                   	pop    %esi
  801a2a:	5d                   	pop    %ebp
  801a2b:	c3                   	ret    

00801a2c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a2c:	55                   	push   %ebp
  801a2d:	89 e5                	mov    %esp,%ebp
  801a2f:	53                   	push   %ebx
  801a30:	83 ec 20             	sub    $0x20,%esp
  801a33:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a36:	53                   	push   %ebx
  801a37:	e8 74 ec ff ff       	call   8006b0 <strlen>
  801a3c:	83 c4 10             	add    $0x10,%esp
  801a3f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a44:	7f 67                	jg     801aad <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a46:	83 ec 0c             	sub    $0xc,%esp
  801a49:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a4c:	50                   	push   %eax
  801a4d:	e8 8e f8 ff ff       	call   8012e0 <fd_alloc>
  801a52:	83 c4 10             	add    $0x10,%esp
		return r;
  801a55:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a57:	85 c0                	test   %eax,%eax
  801a59:	78 57                	js     801ab2 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a5b:	83 ec 08             	sub    $0x8,%esp
  801a5e:	53                   	push   %ebx
  801a5f:	68 00 50 80 00       	push   $0x805000
  801a64:	e8 80 ec ff ff       	call   8006e9 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a69:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a6c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a71:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a74:	b8 01 00 00 00       	mov    $0x1,%eax
  801a79:	e8 f6 fd ff ff       	call   801874 <fsipc>
  801a7e:	89 c3                	mov    %eax,%ebx
  801a80:	83 c4 10             	add    $0x10,%esp
  801a83:	85 c0                	test   %eax,%eax
  801a85:	79 14                	jns    801a9b <open+0x6f>
		fd_close(fd, 0);
  801a87:	83 ec 08             	sub    $0x8,%esp
  801a8a:	6a 00                	push   $0x0
  801a8c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a8f:	e8 47 f9 ff ff       	call   8013db <fd_close>
		return r;
  801a94:	83 c4 10             	add    $0x10,%esp
  801a97:	89 da                	mov    %ebx,%edx
  801a99:	eb 17                	jmp    801ab2 <open+0x86>
	}

	return fd2num(fd);
  801a9b:	83 ec 0c             	sub    $0xc,%esp
  801a9e:	ff 75 f4             	pushl  -0xc(%ebp)
  801aa1:	e8 13 f8 ff ff       	call   8012b9 <fd2num>
  801aa6:	89 c2                	mov    %eax,%edx
  801aa8:	83 c4 10             	add    $0x10,%esp
  801aab:	eb 05                	jmp    801ab2 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801aad:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ab2:	89 d0                	mov    %edx,%eax
  801ab4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ab7:	c9                   	leave  
  801ab8:	c3                   	ret    

00801ab9 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ab9:	55                   	push   %ebp
  801aba:	89 e5                	mov    %esp,%ebp
  801abc:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801abf:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac4:	b8 08 00 00 00       	mov    $0x8,%eax
  801ac9:	e8 a6 fd ff ff       	call   801874 <fsipc>
}
  801ace:	c9                   	leave  
  801acf:	c3                   	ret    

00801ad0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ad0:	55                   	push   %ebp
  801ad1:	89 e5                	mov    %esp,%ebp
  801ad3:	56                   	push   %esi
  801ad4:	53                   	push   %ebx
  801ad5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ad8:	83 ec 0c             	sub    $0xc,%esp
  801adb:	ff 75 08             	pushl  0x8(%ebp)
  801ade:	e8 e6 f7 ff ff       	call   8012c9 <fd2data>
  801ae3:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ae5:	83 c4 08             	add    $0x8,%esp
  801ae8:	68 e7 29 80 00       	push   $0x8029e7
  801aed:	53                   	push   %ebx
  801aee:	e8 f6 eb ff ff       	call   8006e9 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801af3:	8b 46 04             	mov    0x4(%esi),%eax
  801af6:	2b 06                	sub    (%esi),%eax
  801af8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801afe:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b05:	00 00 00 
	stat->st_dev = &devpipe;
  801b08:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b0f:	30 80 00 
	return 0;
}
  801b12:	b8 00 00 00 00       	mov    $0x0,%eax
  801b17:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b1a:	5b                   	pop    %ebx
  801b1b:	5e                   	pop    %esi
  801b1c:	5d                   	pop    %ebp
  801b1d:	c3                   	ret    

00801b1e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b1e:	55                   	push   %ebp
  801b1f:	89 e5                	mov    %esp,%ebp
  801b21:	53                   	push   %ebx
  801b22:	83 ec 0c             	sub    $0xc,%esp
  801b25:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b28:	53                   	push   %ebx
  801b29:	6a 00                	push   $0x0
  801b2b:	e8 41 f0 ff ff       	call   800b71 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b30:	89 1c 24             	mov    %ebx,(%esp)
  801b33:	e8 91 f7 ff ff       	call   8012c9 <fd2data>
  801b38:	83 c4 08             	add    $0x8,%esp
  801b3b:	50                   	push   %eax
  801b3c:	6a 00                	push   $0x0
  801b3e:	e8 2e f0 ff ff       	call   800b71 <sys_page_unmap>
}
  801b43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b46:	c9                   	leave  
  801b47:	c3                   	ret    

00801b48 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b48:	55                   	push   %ebp
  801b49:	89 e5                	mov    %esp,%ebp
  801b4b:	57                   	push   %edi
  801b4c:	56                   	push   %esi
  801b4d:	53                   	push   %ebx
  801b4e:	83 ec 1c             	sub    $0x1c,%esp
  801b51:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b54:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b56:	a1 04 40 80 00       	mov    0x804004,%eax
  801b5b:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b61:	83 ec 0c             	sub    $0xc,%esp
  801b64:	ff 75 e0             	pushl  -0x20(%ebp)
  801b67:	e8 43 06 00 00       	call   8021af <pageref>
  801b6c:	89 c3                	mov    %eax,%ebx
  801b6e:	89 3c 24             	mov    %edi,(%esp)
  801b71:	e8 39 06 00 00       	call   8021af <pageref>
  801b76:	83 c4 10             	add    $0x10,%esp
  801b79:	39 c3                	cmp    %eax,%ebx
  801b7b:	0f 94 c1             	sete   %cl
  801b7e:	0f b6 c9             	movzbl %cl,%ecx
  801b81:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b84:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b8a:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801b90:	39 ce                	cmp    %ecx,%esi
  801b92:	74 1e                	je     801bb2 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801b94:	39 c3                	cmp    %eax,%ebx
  801b96:	75 be                	jne    801b56 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b98:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801b9e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ba1:	50                   	push   %eax
  801ba2:	56                   	push   %esi
  801ba3:	68 ee 29 80 00       	push   $0x8029ee
  801ba8:	e8 b7 e5 ff ff       	call   800164 <cprintf>
  801bad:	83 c4 10             	add    $0x10,%esp
  801bb0:	eb a4                	jmp    801b56 <_pipeisclosed+0xe>
	}
}
  801bb2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bb8:	5b                   	pop    %ebx
  801bb9:	5e                   	pop    %esi
  801bba:	5f                   	pop    %edi
  801bbb:	5d                   	pop    %ebp
  801bbc:	c3                   	ret    

00801bbd <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bbd:	55                   	push   %ebp
  801bbe:	89 e5                	mov    %esp,%ebp
  801bc0:	57                   	push   %edi
  801bc1:	56                   	push   %esi
  801bc2:	53                   	push   %ebx
  801bc3:	83 ec 28             	sub    $0x28,%esp
  801bc6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bc9:	56                   	push   %esi
  801bca:	e8 fa f6 ff ff       	call   8012c9 <fd2data>
  801bcf:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bd1:	83 c4 10             	add    $0x10,%esp
  801bd4:	bf 00 00 00 00       	mov    $0x0,%edi
  801bd9:	eb 4b                	jmp    801c26 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bdb:	89 da                	mov    %ebx,%edx
  801bdd:	89 f0                	mov    %esi,%eax
  801bdf:	e8 64 ff ff ff       	call   801b48 <_pipeisclosed>
  801be4:	85 c0                	test   %eax,%eax
  801be6:	75 48                	jne    801c30 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801be8:	e8 e0 ee ff ff       	call   800acd <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bed:	8b 43 04             	mov    0x4(%ebx),%eax
  801bf0:	8b 0b                	mov    (%ebx),%ecx
  801bf2:	8d 51 20             	lea    0x20(%ecx),%edx
  801bf5:	39 d0                	cmp    %edx,%eax
  801bf7:	73 e2                	jae    801bdb <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bfc:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c00:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c03:	89 c2                	mov    %eax,%edx
  801c05:	c1 fa 1f             	sar    $0x1f,%edx
  801c08:	89 d1                	mov    %edx,%ecx
  801c0a:	c1 e9 1b             	shr    $0x1b,%ecx
  801c0d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c10:	83 e2 1f             	and    $0x1f,%edx
  801c13:	29 ca                	sub    %ecx,%edx
  801c15:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c19:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c1d:	83 c0 01             	add    $0x1,%eax
  801c20:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c23:	83 c7 01             	add    $0x1,%edi
  801c26:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c29:	75 c2                	jne    801bed <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c2b:	8b 45 10             	mov    0x10(%ebp),%eax
  801c2e:	eb 05                	jmp    801c35 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c30:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c38:	5b                   	pop    %ebx
  801c39:	5e                   	pop    %esi
  801c3a:	5f                   	pop    %edi
  801c3b:	5d                   	pop    %ebp
  801c3c:	c3                   	ret    

00801c3d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c3d:	55                   	push   %ebp
  801c3e:	89 e5                	mov    %esp,%ebp
  801c40:	57                   	push   %edi
  801c41:	56                   	push   %esi
  801c42:	53                   	push   %ebx
  801c43:	83 ec 18             	sub    $0x18,%esp
  801c46:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c49:	57                   	push   %edi
  801c4a:	e8 7a f6 ff ff       	call   8012c9 <fd2data>
  801c4f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c51:	83 c4 10             	add    $0x10,%esp
  801c54:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c59:	eb 3d                	jmp    801c98 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c5b:	85 db                	test   %ebx,%ebx
  801c5d:	74 04                	je     801c63 <devpipe_read+0x26>
				return i;
  801c5f:	89 d8                	mov    %ebx,%eax
  801c61:	eb 44                	jmp    801ca7 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c63:	89 f2                	mov    %esi,%edx
  801c65:	89 f8                	mov    %edi,%eax
  801c67:	e8 dc fe ff ff       	call   801b48 <_pipeisclosed>
  801c6c:	85 c0                	test   %eax,%eax
  801c6e:	75 32                	jne    801ca2 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c70:	e8 58 ee ff ff       	call   800acd <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c75:	8b 06                	mov    (%esi),%eax
  801c77:	3b 46 04             	cmp    0x4(%esi),%eax
  801c7a:	74 df                	je     801c5b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c7c:	99                   	cltd   
  801c7d:	c1 ea 1b             	shr    $0x1b,%edx
  801c80:	01 d0                	add    %edx,%eax
  801c82:	83 e0 1f             	and    $0x1f,%eax
  801c85:	29 d0                	sub    %edx,%eax
  801c87:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c8f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c92:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c95:	83 c3 01             	add    $0x1,%ebx
  801c98:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c9b:	75 d8                	jne    801c75 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c9d:	8b 45 10             	mov    0x10(%ebp),%eax
  801ca0:	eb 05                	jmp    801ca7 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ca2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ca7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801caa:	5b                   	pop    %ebx
  801cab:	5e                   	pop    %esi
  801cac:	5f                   	pop    %edi
  801cad:	5d                   	pop    %ebp
  801cae:	c3                   	ret    

00801caf <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801caf:	55                   	push   %ebp
  801cb0:	89 e5                	mov    %esp,%ebp
  801cb2:	56                   	push   %esi
  801cb3:	53                   	push   %ebx
  801cb4:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cb7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cba:	50                   	push   %eax
  801cbb:	e8 20 f6 ff ff       	call   8012e0 <fd_alloc>
  801cc0:	83 c4 10             	add    $0x10,%esp
  801cc3:	89 c2                	mov    %eax,%edx
  801cc5:	85 c0                	test   %eax,%eax
  801cc7:	0f 88 2c 01 00 00    	js     801df9 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ccd:	83 ec 04             	sub    $0x4,%esp
  801cd0:	68 07 04 00 00       	push   $0x407
  801cd5:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd8:	6a 00                	push   $0x0
  801cda:	e8 0d ee ff ff       	call   800aec <sys_page_alloc>
  801cdf:	83 c4 10             	add    $0x10,%esp
  801ce2:	89 c2                	mov    %eax,%edx
  801ce4:	85 c0                	test   %eax,%eax
  801ce6:	0f 88 0d 01 00 00    	js     801df9 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cec:	83 ec 0c             	sub    $0xc,%esp
  801cef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cf2:	50                   	push   %eax
  801cf3:	e8 e8 f5 ff ff       	call   8012e0 <fd_alloc>
  801cf8:	89 c3                	mov    %eax,%ebx
  801cfa:	83 c4 10             	add    $0x10,%esp
  801cfd:	85 c0                	test   %eax,%eax
  801cff:	0f 88 e2 00 00 00    	js     801de7 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d05:	83 ec 04             	sub    $0x4,%esp
  801d08:	68 07 04 00 00       	push   $0x407
  801d0d:	ff 75 f0             	pushl  -0x10(%ebp)
  801d10:	6a 00                	push   $0x0
  801d12:	e8 d5 ed ff ff       	call   800aec <sys_page_alloc>
  801d17:	89 c3                	mov    %eax,%ebx
  801d19:	83 c4 10             	add    $0x10,%esp
  801d1c:	85 c0                	test   %eax,%eax
  801d1e:	0f 88 c3 00 00 00    	js     801de7 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d24:	83 ec 0c             	sub    $0xc,%esp
  801d27:	ff 75 f4             	pushl  -0xc(%ebp)
  801d2a:	e8 9a f5 ff ff       	call   8012c9 <fd2data>
  801d2f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d31:	83 c4 0c             	add    $0xc,%esp
  801d34:	68 07 04 00 00       	push   $0x407
  801d39:	50                   	push   %eax
  801d3a:	6a 00                	push   $0x0
  801d3c:	e8 ab ed ff ff       	call   800aec <sys_page_alloc>
  801d41:	89 c3                	mov    %eax,%ebx
  801d43:	83 c4 10             	add    $0x10,%esp
  801d46:	85 c0                	test   %eax,%eax
  801d48:	0f 88 89 00 00 00    	js     801dd7 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d4e:	83 ec 0c             	sub    $0xc,%esp
  801d51:	ff 75 f0             	pushl  -0x10(%ebp)
  801d54:	e8 70 f5 ff ff       	call   8012c9 <fd2data>
  801d59:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d60:	50                   	push   %eax
  801d61:	6a 00                	push   $0x0
  801d63:	56                   	push   %esi
  801d64:	6a 00                	push   $0x0
  801d66:	e8 c4 ed ff ff       	call   800b2f <sys_page_map>
  801d6b:	89 c3                	mov    %eax,%ebx
  801d6d:	83 c4 20             	add    $0x20,%esp
  801d70:	85 c0                	test   %eax,%eax
  801d72:	78 55                	js     801dc9 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d74:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d7d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d82:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d89:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d92:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d94:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d97:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d9e:	83 ec 0c             	sub    $0xc,%esp
  801da1:	ff 75 f4             	pushl  -0xc(%ebp)
  801da4:	e8 10 f5 ff ff       	call   8012b9 <fd2num>
  801da9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dac:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dae:	83 c4 04             	add    $0x4,%esp
  801db1:	ff 75 f0             	pushl  -0x10(%ebp)
  801db4:	e8 00 f5 ff ff       	call   8012b9 <fd2num>
  801db9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dbc:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801dbf:	83 c4 10             	add    $0x10,%esp
  801dc2:	ba 00 00 00 00       	mov    $0x0,%edx
  801dc7:	eb 30                	jmp    801df9 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801dc9:	83 ec 08             	sub    $0x8,%esp
  801dcc:	56                   	push   %esi
  801dcd:	6a 00                	push   $0x0
  801dcf:	e8 9d ed ff ff       	call   800b71 <sys_page_unmap>
  801dd4:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801dd7:	83 ec 08             	sub    $0x8,%esp
  801dda:	ff 75 f0             	pushl  -0x10(%ebp)
  801ddd:	6a 00                	push   $0x0
  801ddf:	e8 8d ed ff ff       	call   800b71 <sys_page_unmap>
  801de4:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801de7:	83 ec 08             	sub    $0x8,%esp
  801dea:	ff 75 f4             	pushl  -0xc(%ebp)
  801ded:	6a 00                	push   $0x0
  801def:	e8 7d ed ff ff       	call   800b71 <sys_page_unmap>
  801df4:	83 c4 10             	add    $0x10,%esp
  801df7:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801df9:	89 d0                	mov    %edx,%eax
  801dfb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dfe:	5b                   	pop    %ebx
  801dff:	5e                   	pop    %esi
  801e00:	5d                   	pop    %ebp
  801e01:	c3                   	ret    

00801e02 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e02:	55                   	push   %ebp
  801e03:	89 e5                	mov    %esp,%ebp
  801e05:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e08:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e0b:	50                   	push   %eax
  801e0c:	ff 75 08             	pushl  0x8(%ebp)
  801e0f:	e8 1b f5 ff ff       	call   80132f <fd_lookup>
  801e14:	83 c4 10             	add    $0x10,%esp
  801e17:	85 c0                	test   %eax,%eax
  801e19:	78 18                	js     801e33 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e1b:	83 ec 0c             	sub    $0xc,%esp
  801e1e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e21:	e8 a3 f4 ff ff       	call   8012c9 <fd2data>
	return _pipeisclosed(fd, p);
  801e26:	89 c2                	mov    %eax,%edx
  801e28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e2b:	e8 18 fd ff ff       	call   801b48 <_pipeisclosed>
  801e30:	83 c4 10             	add    $0x10,%esp
}
  801e33:	c9                   	leave  
  801e34:	c3                   	ret    

00801e35 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e35:	55                   	push   %ebp
  801e36:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e38:	b8 00 00 00 00       	mov    $0x0,%eax
  801e3d:	5d                   	pop    %ebp
  801e3e:	c3                   	ret    

00801e3f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e3f:	55                   	push   %ebp
  801e40:	89 e5                	mov    %esp,%ebp
  801e42:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e45:	68 06 2a 80 00       	push   $0x802a06
  801e4a:	ff 75 0c             	pushl  0xc(%ebp)
  801e4d:	e8 97 e8 ff ff       	call   8006e9 <strcpy>
	return 0;
}
  801e52:	b8 00 00 00 00       	mov    $0x0,%eax
  801e57:	c9                   	leave  
  801e58:	c3                   	ret    

00801e59 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e59:	55                   	push   %ebp
  801e5a:	89 e5                	mov    %esp,%ebp
  801e5c:	57                   	push   %edi
  801e5d:	56                   	push   %esi
  801e5e:	53                   	push   %ebx
  801e5f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e65:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e6a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e70:	eb 2d                	jmp    801e9f <devcons_write+0x46>
		m = n - tot;
  801e72:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e75:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e77:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e7a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e7f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e82:	83 ec 04             	sub    $0x4,%esp
  801e85:	53                   	push   %ebx
  801e86:	03 45 0c             	add    0xc(%ebp),%eax
  801e89:	50                   	push   %eax
  801e8a:	57                   	push   %edi
  801e8b:	e8 eb e9 ff ff       	call   80087b <memmove>
		sys_cputs(buf, m);
  801e90:	83 c4 08             	add    $0x8,%esp
  801e93:	53                   	push   %ebx
  801e94:	57                   	push   %edi
  801e95:	e8 96 eb ff ff       	call   800a30 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e9a:	01 de                	add    %ebx,%esi
  801e9c:	83 c4 10             	add    $0x10,%esp
  801e9f:	89 f0                	mov    %esi,%eax
  801ea1:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ea4:	72 cc                	jb     801e72 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ea6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ea9:	5b                   	pop    %ebx
  801eaa:	5e                   	pop    %esi
  801eab:	5f                   	pop    %edi
  801eac:	5d                   	pop    %ebp
  801ead:	c3                   	ret    

00801eae <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801eae:	55                   	push   %ebp
  801eaf:	89 e5                	mov    %esp,%ebp
  801eb1:	83 ec 08             	sub    $0x8,%esp
  801eb4:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801eb9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ebd:	74 2a                	je     801ee9 <devcons_read+0x3b>
  801ebf:	eb 05                	jmp    801ec6 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ec1:	e8 07 ec ff ff       	call   800acd <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ec6:	e8 83 eb ff ff       	call   800a4e <sys_cgetc>
  801ecb:	85 c0                	test   %eax,%eax
  801ecd:	74 f2                	je     801ec1 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ecf:	85 c0                	test   %eax,%eax
  801ed1:	78 16                	js     801ee9 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ed3:	83 f8 04             	cmp    $0x4,%eax
  801ed6:	74 0c                	je     801ee4 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ed8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801edb:	88 02                	mov    %al,(%edx)
	return 1;
  801edd:	b8 01 00 00 00       	mov    $0x1,%eax
  801ee2:	eb 05                	jmp    801ee9 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ee4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ee9:	c9                   	leave  
  801eea:	c3                   	ret    

00801eeb <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801eeb:	55                   	push   %ebp
  801eec:	89 e5                	mov    %esp,%ebp
  801eee:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ef1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ef7:	6a 01                	push   $0x1
  801ef9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801efc:	50                   	push   %eax
  801efd:	e8 2e eb ff ff       	call   800a30 <sys_cputs>
}
  801f02:	83 c4 10             	add    $0x10,%esp
  801f05:	c9                   	leave  
  801f06:	c3                   	ret    

00801f07 <getchar>:

int
getchar(void)
{
  801f07:	55                   	push   %ebp
  801f08:	89 e5                	mov    %esp,%ebp
  801f0a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f0d:	6a 01                	push   $0x1
  801f0f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f12:	50                   	push   %eax
  801f13:	6a 00                	push   $0x0
  801f15:	e8 7e f6 ff ff       	call   801598 <read>
	if (r < 0)
  801f1a:	83 c4 10             	add    $0x10,%esp
  801f1d:	85 c0                	test   %eax,%eax
  801f1f:	78 0f                	js     801f30 <getchar+0x29>
		return r;
	if (r < 1)
  801f21:	85 c0                	test   %eax,%eax
  801f23:	7e 06                	jle    801f2b <getchar+0x24>
		return -E_EOF;
	return c;
  801f25:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f29:	eb 05                	jmp    801f30 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f2b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f30:	c9                   	leave  
  801f31:	c3                   	ret    

00801f32 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f32:	55                   	push   %ebp
  801f33:	89 e5                	mov    %esp,%ebp
  801f35:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f38:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f3b:	50                   	push   %eax
  801f3c:	ff 75 08             	pushl  0x8(%ebp)
  801f3f:	e8 eb f3 ff ff       	call   80132f <fd_lookup>
  801f44:	83 c4 10             	add    $0x10,%esp
  801f47:	85 c0                	test   %eax,%eax
  801f49:	78 11                	js     801f5c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f4e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f54:	39 10                	cmp    %edx,(%eax)
  801f56:	0f 94 c0             	sete   %al
  801f59:	0f b6 c0             	movzbl %al,%eax
}
  801f5c:	c9                   	leave  
  801f5d:	c3                   	ret    

00801f5e <opencons>:

int
opencons(void)
{
  801f5e:	55                   	push   %ebp
  801f5f:	89 e5                	mov    %esp,%ebp
  801f61:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f67:	50                   	push   %eax
  801f68:	e8 73 f3 ff ff       	call   8012e0 <fd_alloc>
  801f6d:	83 c4 10             	add    $0x10,%esp
		return r;
  801f70:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f72:	85 c0                	test   %eax,%eax
  801f74:	78 3e                	js     801fb4 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f76:	83 ec 04             	sub    $0x4,%esp
  801f79:	68 07 04 00 00       	push   $0x407
  801f7e:	ff 75 f4             	pushl  -0xc(%ebp)
  801f81:	6a 00                	push   $0x0
  801f83:	e8 64 eb ff ff       	call   800aec <sys_page_alloc>
  801f88:	83 c4 10             	add    $0x10,%esp
		return r;
  801f8b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f8d:	85 c0                	test   %eax,%eax
  801f8f:	78 23                	js     801fb4 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f91:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f9a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f9f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fa6:	83 ec 0c             	sub    $0xc,%esp
  801fa9:	50                   	push   %eax
  801faa:	e8 0a f3 ff ff       	call   8012b9 <fd2num>
  801faf:	89 c2                	mov    %eax,%edx
  801fb1:	83 c4 10             	add    $0x10,%esp
}
  801fb4:	89 d0                	mov    %edx,%eax
  801fb6:	c9                   	leave  
  801fb7:	c3                   	ret    

00801fb8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801fb8:	55                   	push   %ebp
  801fb9:	89 e5                	mov    %esp,%ebp
  801fbb:	56                   	push   %esi
  801fbc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801fbd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801fc0:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801fc6:	e8 e3 ea ff ff       	call   800aae <sys_getenvid>
  801fcb:	83 ec 0c             	sub    $0xc,%esp
  801fce:	ff 75 0c             	pushl  0xc(%ebp)
  801fd1:	ff 75 08             	pushl  0x8(%ebp)
  801fd4:	56                   	push   %esi
  801fd5:	50                   	push   %eax
  801fd6:	68 14 2a 80 00       	push   $0x802a14
  801fdb:	e8 84 e1 ff ff       	call   800164 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801fe0:	83 c4 18             	add    $0x18,%esp
  801fe3:	53                   	push   %ebx
  801fe4:	ff 75 10             	pushl  0x10(%ebp)
  801fe7:	e8 27 e1 ff ff       	call   800113 <vcprintf>
	cprintf("\n");
  801fec:	c7 04 24 9c 24 80 00 	movl   $0x80249c,(%esp)
  801ff3:	e8 6c e1 ff ff       	call   800164 <cprintf>
  801ff8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ffb:	cc                   	int3   
  801ffc:	eb fd                	jmp    801ffb <_panic+0x43>

00801ffe <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ffe:	55                   	push   %ebp
  801fff:	89 e5                	mov    %esp,%ebp
  802001:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802004:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80200b:	75 2a                	jne    802037 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  80200d:	83 ec 04             	sub    $0x4,%esp
  802010:	6a 07                	push   $0x7
  802012:	68 00 f0 bf ee       	push   $0xeebff000
  802017:	6a 00                	push   $0x0
  802019:	e8 ce ea ff ff       	call   800aec <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  80201e:	83 c4 10             	add    $0x10,%esp
  802021:	85 c0                	test   %eax,%eax
  802023:	79 12                	jns    802037 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802025:	50                   	push   %eax
  802026:	68 98 28 80 00       	push   $0x802898
  80202b:	6a 23                	push   $0x23
  80202d:	68 38 2a 80 00       	push   $0x802a38
  802032:	e8 81 ff ff ff       	call   801fb8 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802037:	8b 45 08             	mov    0x8(%ebp),%eax
  80203a:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80203f:	83 ec 08             	sub    $0x8,%esp
  802042:	68 69 20 80 00       	push   $0x802069
  802047:	6a 00                	push   $0x0
  802049:	e8 e9 eb ff ff       	call   800c37 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  80204e:	83 c4 10             	add    $0x10,%esp
  802051:	85 c0                	test   %eax,%eax
  802053:	79 12                	jns    802067 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802055:	50                   	push   %eax
  802056:	68 98 28 80 00       	push   $0x802898
  80205b:	6a 2c                	push   $0x2c
  80205d:	68 38 2a 80 00       	push   $0x802a38
  802062:	e8 51 ff ff ff       	call   801fb8 <_panic>
	}
}
  802067:	c9                   	leave  
  802068:	c3                   	ret    

00802069 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802069:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80206a:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80206f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802071:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802074:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802078:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  80207d:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802081:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802083:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802086:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802087:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80208a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  80208b:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80208c:	c3                   	ret    

0080208d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80208d:	55                   	push   %ebp
  80208e:	89 e5                	mov    %esp,%ebp
  802090:	56                   	push   %esi
  802091:	53                   	push   %ebx
  802092:	8b 75 08             	mov    0x8(%ebp),%esi
  802095:	8b 45 0c             	mov    0xc(%ebp),%eax
  802098:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80209b:	85 c0                	test   %eax,%eax
  80209d:	75 12                	jne    8020b1 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80209f:	83 ec 0c             	sub    $0xc,%esp
  8020a2:	68 00 00 c0 ee       	push   $0xeec00000
  8020a7:	e8 f0 eb ff ff       	call   800c9c <sys_ipc_recv>
  8020ac:	83 c4 10             	add    $0x10,%esp
  8020af:	eb 0c                	jmp    8020bd <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8020b1:	83 ec 0c             	sub    $0xc,%esp
  8020b4:	50                   	push   %eax
  8020b5:	e8 e2 eb ff ff       	call   800c9c <sys_ipc_recv>
  8020ba:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8020bd:	85 f6                	test   %esi,%esi
  8020bf:	0f 95 c1             	setne  %cl
  8020c2:	85 db                	test   %ebx,%ebx
  8020c4:	0f 95 c2             	setne  %dl
  8020c7:	84 d1                	test   %dl,%cl
  8020c9:	74 09                	je     8020d4 <ipc_recv+0x47>
  8020cb:	89 c2                	mov    %eax,%edx
  8020cd:	c1 ea 1f             	shr    $0x1f,%edx
  8020d0:	84 d2                	test   %dl,%dl
  8020d2:	75 2d                	jne    802101 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8020d4:	85 f6                	test   %esi,%esi
  8020d6:	74 0d                	je     8020e5 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8020d8:	a1 04 40 80 00       	mov    0x804004,%eax
  8020dd:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8020e3:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8020e5:	85 db                	test   %ebx,%ebx
  8020e7:	74 0d                	je     8020f6 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8020e9:	a1 04 40 80 00       	mov    0x804004,%eax
  8020ee:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  8020f4:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8020f6:	a1 04 40 80 00       	mov    0x804004,%eax
  8020fb:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  802101:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802104:	5b                   	pop    %ebx
  802105:	5e                   	pop    %esi
  802106:	5d                   	pop    %ebp
  802107:	c3                   	ret    

00802108 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802108:	55                   	push   %ebp
  802109:	89 e5                	mov    %esp,%ebp
  80210b:	57                   	push   %edi
  80210c:	56                   	push   %esi
  80210d:	53                   	push   %ebx
  80210e:	83 ec 0c             	sub    $0xc,%esp
  802111:	8b 7d 08             	mov    0x8(%ebp),%edi
  802114:	8b 75 0c             	mov    0xc(%ebp),%esi
  802117:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80211a:	85 db                	test   %ebx,%ebx
  80211c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802121:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802124:	ff 75 14             	pushl  0x14(%ebp)
  802127:	53                   	push   %ebx
  802128:	56                   	push   %esi
  802129:	57                   	push   %edi
  80212a:	e8 4a eb ff ff       	call   800c79 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  80212f:	89 c2                	mov    %eax,%edx
  802131:	c1 ea 1f             	shr    $0x1f,%edx
  802134:	83 c4 10             	add    $0x10,%esp
  802137:	84 d2                	test   %dl,%dl
  802139:	74 17                	je     802152 <ipc_send+0x4a>
  80213b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80213e:	74 12                	je     802152 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802140:	50                   	push   %eax
  802141:	68 46 2a 80 00       	push   $0x802a46
  802146:	6a 47                	push   $0x47
  802148:	68 54 2a 80 00       	push   $0x802a54
  80214d:	e8 66 fe ff ff       	call   801fb8 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802152:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802155:	75 07                	jne    80215e <ipc_send+0x56>
			sys_yield();
  802157:	e8 71 e9 ff ff       	call   800acd <sys_yield>
  80215c:	eb c6                	jmp    802124 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80215e:	85 c0                	test   %eax,%eax
  802160:	75 c2                	jne    802124 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802162:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802165:	5b                   	pop    %ebx
  802166:	5e                   	pop    %esi
  802167:	5f                   	pop    %edi
  802168:	5d                   	pop    %ebp
  802169:	c3                   	ret    

0080216a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80216a:	55                   	push   %ebp
  80216b:	89 e5                	mov    %esp,%ebp
  80216d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802170:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802175:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  80217b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802181:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  802187:	39 ca                	cmp    %ecx,%edx
  802189:	75 13                	jne    80219e <ipc_find_env+0x34>
			return envs[i].env_id;
  80218b:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  802191:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802196:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80219c:	eb 0f                	jmp    8021ad <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80219e:	83 c0 01             	add    $0x1,%eax
  8021a1:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021a6:	75 cd                	jne    802175 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021ad:	5d                   	pop    %ebp
  8021ae:	c3                   	ret    

008021af <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021af:	55                   	push   %ebp
  8021b0:	89 e5                	mov    %esp,%ebp
  8021b2:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021b5:	89 d0                	mov    %edx,%eax
  8021b7:	c1 e8 16             	shr    $0x16,%eax
  8021ba:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021c1:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021c6:	f6 c1 01             	test   $0x1,%cl
  8021c9:	74 1d                	je     8021e8 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021cb:	c1 ea 0c             	shr    $0xc,%edx
  8021ce:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021d5:	f6 c2 01             	test   $0x1,%dl
  8021d8:	74 0e                	je     8021e8 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021da:	c1 ea 0c             	shr    $0xc,%edx
  8021dd:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021e4:	ef 
  8021e5:	0f b7 c0             	movzwl %ax,%eax
}
  8021e8:	5d                   	pop    %ebp
  8021e9:	c3                   	ret    
  8021ea:	66 90                	xchg   %ax,%ax
  8021ec:	66 90                	xchg   %ax,%ax
  8021ee:	66 90                	xchg   %ax,%ax

008021f0 <__udivdi3>:
  8021f0:	55                   	push   %ebp
  8021f1:	57                   	push   %edi
  8021f2:	56                   	push   %esi
  8021f3:	53                   	push   %ebx
  8021f4:	83 ec 1c             	sub    $0x1c,%esp
  8021f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8021fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802203:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802207:	85 f6                	test   %esi,%esi
  802209:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80220d:	89 ca                	mov    %ecx,%edx
  80220f:	89 f8                	mov    %edi,%eax
  802211:	75 3d                	jne    802250 <__udivdi3+0x60>
  802213:	39 cf                	cmp    %ecx,%edi
  802215:	0f 87 c5 00 00 00    	ja     8022e0 <__udivdi3+0xf0>
  80221b:	85 ff                	test   %edi,%edi
  80221d:	89 fd                	mov    %edi,%ebp
  80221f:	75 0b                	jne    80222c <__udivdi3+0x3c>
  802221:	b8 01 00 00 00       	mov    $0x1,%eax
  802226:	31 d2                	xor    %edx,%edx
  802228:	f7 f7                	div    %edi
  80222a:	89 c5                	mov    %eax,%ebp
  80222c:	89 c8                	mov    %ecx,%eax
  80222e:	31 d2                	xor    %edx,%edx
  802230:	f7 f5                	div    %ebp
  802232:	89 c1                	mov    %eax,%ecx
  802234:	89 d8                	mov    %ebx,%eax
  802236:	89 cf                	mov    %ecx,%edi
  802238:	f7 f5                	div    %ebp
  80223a:	89 c3                	mov    %eax,%ebx
  80223c:	89 d8                	mov    %ebx,%eax
  80223e:	89 fa                	mov    %edi,%edx
  802240:	83 c4 1c             	add    $0x1c,%esp
  802243:	5b                   	pop    %ebx
  802244:	5e                   	pop    %esi
  802245:	5f                   	pop    %edi
  802246:	5d                   	pop    %ebp
  802247:	c3                   	ret    
  802248:	90                   	nop
  802249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802250:	39 ce                	cmp    %ecx,%esi
  802252:	77 74                	ja     8022c8 <__udivdi3+0xd8>
  802254:	0f bd fe             	bsr    %esi,%edi
  802257:	83 f7 1f             	xor    $0x1f,%edi
  80225a:	0f 84 98 00 00 00    	je     8022f8 <__udivdi3+0x108>
  802260:	bb 20 00 00 00       	mov    $0x20,%ebx
  802265:	89 f9                	mov    %edi,%ecx
  802267:	89 c5                	mov    %eax,%ebp
  802269:	29 fb                	sub    %edi,%ebx
  80226b:	d3 e6                	shl    %cl,%esi
  80226d:	89 d9                	mov    %ebx,%ecx
  80226f:	d3 ed                	shr    %cl,%ebp
  802271:	89 f9                	mov    %edi,%ecx
  802273:	d3 e0                	shl    %cl,%eax
  802275:	09 ee                	or     %ebp,%esi
  802277:	89 d9                	mov    %ebx,%ecx
  802279:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80227d:	89 d5                	mov    %edx,%ebp
  80227f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802283:	d3 ed                	shr    %cl,%ebp
  802285:	89 f9                	mov    %edi,%ecx
  802287:	d3 e2                	shl    %cl,%edx
  802289:	89 d9                	mov    %ebx,%ecx
  80228b:	d3 e8                	shr    %cl,%eax
  80228d:	09 c2                	or     %eax,%edx
  80228f:	89 d0                	mov    %edx,%eax
  802291:	89 ea                	mov    %ebp,%edx
  802293:	f7 f6                	div    %esi
  802295:	89 d5                	mov    %edx,%ebp
  802297:	89 c3                	mov    %eax,%ebx
  802299:	f7 64 24 0c          	mull   0xc(%esp)
  80229d:	39 d5                	cmp    %edx,%ebp
  80229f:	72 10                	jb     8022b1 <__udivdi3+0xc1>
  8022a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8022a5:	89 f9                	mov    %edi,%ecx
  8022a7:	d3 e6                	shl    %cl,%esi
  8022a9:	39 c6                	cmp    %eax,%esi
  8022ab:	73 07                	jae    8022b4 <__udivdi3+0xc4>
  8022ad:	39 d5                	cmp    %edx,%ebp
  8022af:	75 03                	jne    8022b4 <__udivdi3+0xc4>
  8022b1:	83 eb 01             	sub    $0x1,%ebx
  8022b4:	31 ff                	xor    %edi,%edi
  8022b6:	89 d8                	mov    %ebx,%eax
  8022b8:	89 fa                	mov    %edi,%edx
  8022ba:	83 c4 1c             	add    $0x1c,%esp
  8022bd:	5b                   	pop    %ebx
  8022be:	5e                   	pop    %esi
  8022bf:	5f                   	pop    %edi
  8022c0:	5d                   	pop    %ebp
  8022c1:	c3                   	ret    
  8022c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022c8:	31 ff                	xor    %edi,%edi
  8022ca:	31 db                	xor    %ebx,%ebx
  8022cc:	89 d8                	mov    %ebx,%eax
  8022ce:	89 fa                	mov    %edi,%edx
  8022d0:	83 c4 1c             	add    $0x1c,%esp
  8022d3:	5b                   	pop    %ebx
  8022d4:	5e                   	pop    %esi
  8022d5:	5f                   	pop    %edi
  8022d6:	5d                   	pop    %ebp
  8022d7:	c3                   	ret    
  8022d8:	90                   	nop
  8022d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022e0:	89 d8                	mov    %ebx,%eax
  8022e2:	f7 f7                	div    %edi
  8022e4:	31 ff                	xor    %edi,%edi
  8022e6:	89 c3                	mov    %eax,%ebx
  8022e8:	89 d8                	mov    %ebx,%eax
  8022ea:	89 fa                	mov    %edi,%edx
  8022ec:	83 c4 1c             	add    $0x1c,%esp
  8022ef:	5b                   	pop    %ebx
  8022f0:	5e                   	pop    %esi
  8022f1:	5f                   	pop    %edi
  8022f2:	5d                   	pop    %ebp
  8022f3:	c3                   	ret    
  8022f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022f8:	39 ce                	cmp    %ecx,%esi
  8022fa:	72 0c                	jb     802308 <__udivdi3+0x118>
  8022fc:	31 db                	xor    %ebx,%ebx
  8022fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802302:	0f 87 34 ff ff ff    	ja     80223c <__udivdi3+0x4c>
  802308:	bb 01 00 00 00       	mov    $0x1,%ebx
  80230d:	e9 2a ff ff ff       	jmp    80223c <__udivdi3+0x4c>
  802312:	66 90                	xchg   %ax,%ax
  802314:	66 90                	xchg   %ax,%ax
  802316:	66 90                	xchg   %ax,%ax
  802318:	66 90                	xchg   %ax,%ax
  80231a:	66 90                	xchg   %ax,%ax
  80231c:	66 90                	xchg   %ax,%ax
  80231e:	66 90                	xchg   %ax,%ax

00802320 <__umoddi3>:
  802320:	55                   	push   %ebp
  802321:	57                   	push   %edi
  802322:	56                   	push   %esi
  802323:	53                   	push   %ebx
  802324:	83 ec 1c             	sub    $0x1c,%esp
  802327:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80232b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80232f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802333:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802337:	85 d2                	test   %edx,%edx
  802339:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80233d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802341:	89 f3                	mov    %esi,%ebx
  802343:	89 3c 24             	mov    %edi,(%esp)
  802346:	89 74 24 04          	mov    %esi,0x4(%esp)
  80234a:	75 1c                	jne    802368 <__umoddi3+0x48>
  80234c:	39 f7                	cmp    %esi,%edi
  80234e:	76 50                	jbe    8023a0 <__umoddi3+0x80>
  802350:	89 c8                	mov    %ecx,%eax
  802352:	89 f2                	mov    %esi,%edx
  802354:	f7 f7                	div    %edi
  802356:	89 d0                	mov    %edx,%eax
  802358:	31 d2                	xor    %edx,%edx
  80235a:	83 c4 1c             	add    $0x1c,%esp
  80235d:	5b                   	pop    %ebx
  80235e:	5e                   	pop    %esi
  80235f:	5f                   	pop    %edi
  802360:	5d                   	pop    %ebp
  802361:	c3                   	ret    
  802362:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802368:	39 f2                	cmp    %esi,%edx
  80236a:	89 d0                	mov    %edx,%eax
  80236c:	77 52                	ja     8023c0 <__umoddi3+0xa0>
  80236e:	0f bd ea             	bsr    %edx,%ebp
  802371:	83 f5 1f             	xor    $0x1f,%ebp
  802374:	75 5a                	jne    8023d0 <__umoddi3+0xb0>
  802376:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80237a:	0f 82 e0 00 00 00    	jb     802460 <__umoddi3+0x140>
  802380:	39 0c 24             	cmp    %ecx,(%esp)
  802383:	0f 86 d7 00 00 00    	jbe    802460 <__umoddi3+0x140>
  802389:	8b 44 24 08          	mov    0x8(%esp),%eax
  80238d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802391:	83 c4 1c             	add    $0x1c,%esp
  802394:	5b                   	pop    %ebx
  802395:	5e                   	pop    %esi
  802396:	5f                   	pop    %edi
  802397:	5d                   	pop    %ebp
  802398:	c3                   	ret    
  802399:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023a0:	85 ff                	test   %edi,%edi
  8023a2:	89 fd                	mov    %edi,%ebp
  8023a4:	75 0b                	jne    8023b1 <__umoddi3+0x91>
  8023a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023ab:	31 d2                	xor    %edx,%edx
  8023ad:	f7 f7                	div    %edi
  8023af:	89 c5                	mov    %eax,%ebp
  8023b1:	89 f0                	mov    %esi,%eax
  8023b3:	31 d2                	xor    %edx,%edx
  8023b5:	f7 f5                	div    %ebp
  8023b7:	89 c8                	mov    %ecx,%eax
  8023b9:	f7 f5                	div    %ebp
  8023bb:	89 d0                	mov    %edx,%eax
  8023bd:	eb 99                	jmp    802358 <__umoddi3+0x38>
  8023bf:	90                   	nop
  8023c0:	89 c8                	mov    %ecx,%eax
  8023c2:	89 f2                	mov    %esi,%edx
  8023c4:	83 c4 1c             	add    $0x1c,%esp
  8023c7:	5b                   	pop    %ebx
  8023c8:	5e                   	pop    %esi
  8023c9:	5f                   	pop    %edi
  8023ca:	5d                   	pop    %ebp
  8023cb:	c3                   	ret    
  8023cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023d0:	8b 34 24             	mov    (%esp),%esi
  8023d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023d8:	89 e9                	mov    %ebp,%ecx
  8023da:	29 ef                	sub    %ebp,%edi
  8023dc:	d3 e0                	shl    %cl,%eax
  8023de:	89 f9                	mov    %edi,%ecx
  8023e0:	89 f2                	mov    %esi,%edx
  8023e2:	d3 ea                	shr    %cl,%edx
  8023e4:	89 e9                	mov    %ebp,%ecx
  8023e6:	09 c2                	or     %eax,%edx
  8023e8:	89 d8                	mov    %ebx,%eax
  8023ea:	89 14 24             	mov    %edx,(%esp)
  8023ed:	89 f2                	mov    %esi,%edx
  8023ef:	d3 e2                	shl    %cl,%edx
  8023f1:	89 f9                	mov    %edi,%ecx
  8023f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8023fb:	d3 e8                	shr    %cl,%eax
  8023fd:	89 e9                	mov    %ebp,%ecx
  8023ff:	89 c6                	mov    %eax,%esi
  802401:	d3 e3                	shl    %cl,%ebx
  802403:	89 f9                	mov    %edi,%ecx
  802405:	89 d0                	mov    %edx,%eax
  802407:	d3 e8                	shr    %cl,%eax
  802409:	89 e9                	mov    %ebp,%ecx
  80240b:	09 d8                	or     %ebx,%eax
  80240d:	89 d3                	mov    %edx,%ebx
  80240f:	89 f2                	mov    %esi,%edx
  802411:	f7 34 24             	divl   (%esp)
  802414:	89 d6                	mov    %edx,%esi
  802416:	d3 e3                	shl    %cl,%ebx
  802418:	f7 64 24 04          	mull   0x4(%esp)
  80241c:	39 d6                	cmp    %edx,%esi
  80241e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802422:	89 d1                	mov    %edx,%ecx
  802424:	89 c3                	mov    %eax,%ebx
  802426:	72 08                	jb     802430 <__umoddi3+0x110>
  802428:	75 11                	jne    80243b <__umoddi3+0x11b>
  80242a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80242e:	73 0b                	jae    80243b <__umoddi3+0x11b>
  802430:	2b 44 24 04          	sub    0x4(%esp),%eax
  802434:	1b 14 24             	sbb    (%esp),%edx
  802437:	89 d1                	mov    %edx,%ecx
  802439:	89 c3                	mov    %eax,%ebx
  80243b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80243f:	29 da                	sub    %ebx,%edx
  802441:	19 ce                	sbb    %ecx,%esi
  802443:	89 f9                	mov    %edi,%ecx
  802445:	89 f0                	mov    %esi,%eax
  802447:	d3 e0                	shl    %cl,%eax
  802449:	89 e9                	mov    %ebp,%ecx
  80244b:	d3 ea                	shr    %cl,%edx
  80244d:	89 e9                	mov    %ebp,%ecx
  80244f:	d3 ee                	shr    %cl,%esi
  802451:	09 d0                	or     %edx,%eax
  802453:	89 f2                	mov    %esi,%edx
  802455:	83 c4 1c             	add    $0x1c,%esp
  802458:	5b                   	pop    %ebx
  802459:	5e                   	pop    %esi
  80245a:	5f                   	pop    %edi
  80245b:	5d                   	pop    %ebp
  80245c:	c3                   	ret    
  80245d:	8d 76 00             	lea    0x0(%esi),%esi
  802460:	29 f9                	sub    %edi,%ecx
  802462:	19 d6                	sbb    %edx,%esi
  802464:	89 74 24 04          	mov    %esi,0x4(%esp)
  802468:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80246c:	e9 18 ff ff ff       	jmp    802389 <__umoddi3+0x69>
