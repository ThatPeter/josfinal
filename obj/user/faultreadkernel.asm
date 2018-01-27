
obj/user/faultreadkernel.debug:     file format elf32-i386


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
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  800039:	ff 35 00 00 10 f0    	pushl  0xf0100000
  80003f:	68 e0 21 80 00       	push   $0x8021e0
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
  800063:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
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
  8000bd:	e8 1a 11 00 00       	call   8011dc <close_all>
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
  8001c7:	e8 74 1d 00 00       	call   801f40 <__udivdi3>
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
  80020a:	e8 61 1e 00 00       	call   802070 <__umoddi3>
  80020f:	83 c4 14             	add    $0x14,%esp
  800212:	0f be 80 11 22 80 00 	movsbl 0x802211(%eax),%eax
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
  80030e:	ff 24 85 60 23 80 00 	jmp    *0x802360(,%eax,4)
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
  8003d2:	8b 14 85 c0 24 80 00 	mov    0x8024c0(,%eax,4),%edx
  8003d9:	85 d2                	test   %edx,%edx
  8003db:	75 18                	jne    8003f5 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003dd:	50                   	push   %eax
  8003de:	68 29 22 80 00       	push   $0x802229
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
  8003f6:	68 6d 26 80 00       	push   $0x80266d
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
  80041a:	b8 22 22 80 00       	mov    $0x802222,%eax
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
  800a95:	68 1f 25 80 00       	push   $0x80251f
  800a9a:	6a 23                	push   $0x23
  800a9c:	68 3c 25 80 00       	push   $0x80253c
  800aa1:	e8 5e 12 00 00       	call   801d04 <_panic>

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
  800b16:	68 1f 25 80 00       	push   $0x80251f
  800b1b:	6a 23                	push   $0x23
  800b1d:	68 3c 25 80 00       	push   $0x80253c
  800b22:	e8 dd 11 00 00       	call   801d04 <_panic>

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
  800b58:	68 1f 25 80 00       	push   $0x80251f
  800b5d:	6a 23                	push   $0x23
  800b5f:	68 3c 25 80 00       	push   $0x80253c
  800b64:	e8 9b 11 00 00       	call   801d04 <_panic>

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
  800b9a:	68 1f 25 80 00       	push   $0x80251f
  800b9f:	6a 23                	push   $0x23
  800ba1:	68 3c 25 80 00       	push   $0x80253c
  800ba6:	e8 59 11 00 00       	call   801d04 <_panic>

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
  800bdc:	68 1f 25 80 00       	push   $0x80251f
  800be1:	6a 23                	push   $0x23
  800be3:	68 3c 25 80 00       	push   $0x80253c
  800be8:	e8 17 11 00 00       	call   801d04 <_panic>

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
  800c1e:	68 1f 25 80 00       	push   $0x80251f
  800c23:	6a 23                	push   $0x23
  800c25:	68 3c 25 80 00       	push   $0x80253c
  800c2a:	e8 d5 10 00 00       	call   801d04 <_panic>
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
  800c60:	68 1f 25 80 00       	push   $0x80251f
  800c65:	6a 23                	push   $0x23
  800c67:	68 3c 25 80 00       	push   $0x80253c
  800c6c:	e8 93 10 00 00       	call   801d04 <_panic>

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
  800cc4:	68 1f 25 80 00       	push   $0x80251f
  800cc9:	6a 23                	push   $0x23
  800ccb:	68 3c 25 80 00       	push   $0x80253c
  800cd0:	e8 2f 10 00 00       	call   801d04 <_panic>

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

00800d1d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	53                   	push   %ebx
  800d21:	83 ec 04             	sub    $0x4,%esp
  800d24:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d27:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800d29:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d2d:	74 11                	je     800d40 <pgfault+0x23>
  800d2f:	89 d8                	mov    %ebx,%eax
  800d31:	c1 e8 0c             	shr    $0xc,%eax
  800d34:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d3b:	f6 c4 08             	test   $0x8,%ah
  800d3e:	75 14                	jne    800d54 <pgfault+0x37>
		panic("faulting access");
  800d40:	83 ec 04             	sub    $0x4,%esp
  800d43:	68 4a 25 80 00       	push   $0x80254a
  800d48:	6a 1e                	push   $0x1e
  800d4a:	68 5a 25 80 00       	push   $0x80255a
  800d4f:	e8 b0 0f 00 00       	call   801d04 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800d54:	83 ec 04             	sub    $0x4,%esp
  800d57:	6a 07                	push   $0x7
  800d59:	68 00 f0 7f 00       	push   $0x7ff000
  800d5e:	6a 00                	push   $0x0
  800d60:	e8 87 fd ff ff       	call   800aec <sys_page_alloc>
	if (r < 0) {
  800d65:	83 c4 10             	add    $0x10,%esp
  800d68:	85 c0                	test   %eax,%eax
  800d6a:	79 12                	jns    800d7e <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800d6c:	50                   	push   %eax
  800d6d:	68 65 25 80 00       	push   $0x802565
  800d72:	6a 2c                	push   $0x2c
  800d74:	68 5a 25 80 00       	push   $0x80255a
  800d79:	e8 86 0f 00 00       	call   801d04 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800d7e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800d84:	83 ec 04             	sub    $0x4,%esp
  800d87:	68 00 10 00 00       	push   $0x1000
  800d8c:	53                   	push   %ebx
  800d8d:	68 00 f0 7f 00       	push   $0x7ff000
  800d92:	e8 4c fb ff ff       	call   8008e3 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800d97:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800d9e:	53                   	push   %ebx
  800d9f:	6a 00                	push   $0x0
  800da1:	68 00 f0 7f 00       	push   $0x7ff000
  800da6:	6a 00                	push   $0x0
  800da8:	e8 82 fd ff ff       	call   800b2f <sys_page_map>
	if (r < 0) {
  800dad:	83 c4 20             	add    $0x20,%esp
  800db0:	85 c0                	test   %eax,%eax
  800db2:	79 12                	jns    800dc6 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800db4:	50                   	push   %eax
  800db5:	68 65 25 80 00       	push   $0x802565
  800dba:	6a 33                	push   $0x33
  800dbc:	68 5a 25 80 00       	push   $0x80255a
  800dc1:	e8 3e 0f 00 00       	call   801d04 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800dc6:	83 ec 08             	sub    $0x8,%esp
  800dc9:	68 00 f0 7f 00       	push   $0x7ff000
  800dce:	6a 00                	push   $0x0
  800dd0:	e8 9c fd ff ff       	call   800b71 <sys_page_unmap>
	if (r < 0) {
  800dd5:	83 c4 10             	add    $0x10,%esp
  800dd8:	85 c0                	test   %eax,%eax
  800dda:	79 12                	jns    800dee <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800ddc:	50                   	push   %eax
  800ddd:	68 65 25 80 00       	push   $0x802565
  800de2:	6a 37                	push   $0x37
  800de4:	68 5a 25 80 00       	push   $0x80255a
  800de9:	e8 16 0f 00 00       	call   801d04 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800dee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800df1:	c9                   	leave  
  800df2:	c3                   	ret    

00800df3 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800df3:	55                   	push   %ebp
  800df4:	89 e5                	mov    %esp,%ebp
  800df6:	57                   	push   %edi
  800df7:	56                   	push   %esi
  800df8:	53                   	push   %ebx
  800df9:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800dfc:	68 1d 0d 80 00       	push   $0x800d1d
  800e01:	e8 44 0f 00 00       	call   801d4a <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e06:	b8 07 00 00 00       	mov    $0x7,%eax
  800e0b:	cd 30                	int    $0x30
  800e0d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800e10:	83 c4 10             	add    $0x10,%esp
  800e13:	85 c0                	test   %eax,%eax
  800e15:	79 17                	jns    800e2e <fork+0x3b>
		panic("fork fault %e");
  800e17:	83 ec 04             	sub    $0x4,%esp
  800e1a:	68 7e 25 80 00       	push   $0x80257e
  800e1f:	68 84 00 00 00       	push   $0x84
  800e24:	68 5a 25 80 00       	push   $0x80255a
  800e29:	e8 d6 0e 00 00       	call   801d04 <_panic>
  800e2e:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800e30:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e34:	75 24                	jne    800e5a <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e36:	e8 73 fc ff ff       	call   800aae <sys_getenvid>
  800e3b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e40:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  800e46:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e4b:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800e50:	b8 00 00 00 00       	mov    $0x0,%eax
  800e55:	e9 64 01 00 00       	jmp    800fbe <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800e5a:	83 ec 04             	sub    $0x4,%esp
  800e5d:	6a 07                	push   $0x7
  800e5f:	68 00 f0 bf ee       	push   $0xeebff000
  800e64:	ff 75 e4             	pushl  -0x1c(%ebp)
  800e67:	e8 80 fc ff ff       	call   800aec <sys_page_alloc>
  800e6c:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800e6f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800e74:	89 d8                	mov    %ebx,%eax
  800e76:	c1 e8 16             	shr    $0x16,%eax
  800e79:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e80:	a8 01                	test   $0x1,%al
  800e82:	0f 84 fc 00 00 00    	je     800f84 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800e88:	89 d8                	mov    %ebx,%eax
  800e8a:	c1 e8 0c             	shr    $0xc,%eax
  800e8d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800e94:	f6 c2 01             	test   $0x1,%dl
  800e97:	0f 84 e7 00 00 00    	je     800f84 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800e9d:	89 c6                	mov    %eax,%esi
  800e9f:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800ea2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ea9:	f6 c6 04             	test   $0x4,%dh
  800eac:	74 39                	je     800ee7 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800eae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eb5:	83 ec 0c             	sub    $0xc,%esp
  800eb8:	25 07 0e 00 00       	and    $0xe07,%eax
  800ebd:	50                   	push   %eax
  800ebe:	56                   	push   %esi
  800ebf:	57                   	push   %edi
  800ec0:	56                   	push   %esi
  800ec1:	6a 00                	push   $0x0
  800ec3:	e8 67 fc ff ff       	call   800b2f <sys_page_map>
		if (r < 0) {
  800ec8:	83 c4 20             	add    $0x20,%esp
  800ecb:	85 c0                	test   %eax,%eax
  800ecd:	0f 89 b1 00 00 00    	jns    800f84 <fork+0x191>
		    	panic("sys page map fault %e");
  800ed3:	83 ec 04             	sub    $0x4,%esp
  800ed6:	68 8c 25 80 00       	push   $0x80258c
  800edb:	6a 54                	push   $0x54
  800edd:	68 5a 25 80 00       	push   $0x80255a
  800ee2:	e8 1d 0e 00 00       	call   801d04 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800ee7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800eee:	f6 c2 02             	test   $0x2,%dl
  800ef1:	75 0c                	jne    800eff <fork+0x10c>
  800ef3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800efa:	f6 c4 08             	test   $0x8,%ah
  800efd:	74 5b                	je     800f5a <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800eff:	83 ec 0c             	sub    $0xc,%esp
  800f02:	68 05 08 00 00       	push   $0x805
  800f07:	56                   	push   %esi
  800f08:	57                   	push   %edi
  800f09:	56                   	push   %esi
  800f0a:	6a 00                	push   $0x0
  800f0c:	e8 1e fc ff ff       	call   800b2f <sys_page_map>
		if (r < 0) {
  800f11:	83 c4 20             	add    $0x20,%esp
  800f14:	85 c0                	test   %eax,%eax
  800f16:	79 14                	jns    800f2c <fork+0x139>
		    	panic("sys page map fault %e");
  800f18:	83 ec 04             	sub    $0x4,%esp
  800f1b:	68 8c 25 80 00       	push   $0x80258c
  800f20:	6a 5b                	push   $0x5b
  800f22:	68 5a 25 80 00       	push   $0x80255a
  800f27:	e8 d8 0d 00 00       	call   801d04 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800f2c:	83 ec 0c             	sub    $0xc,%esp
  800f2f:	68 05 08 00 00       	push   $0x805
  800f34:	56                   	push   %esi
  800f35:	6a 00                	push   $0x0
  800f37:	56                   	push   %esi
  800f38:	6a 00                	push   $0x0
  800f3a:	e8 f0 fb ff ff       	call   800b2f <sys_page_map>
		if (r < 0) {
  800f3f:	83 c4 20             	add    $0x20,%esp
  800f42:	85 c0                	test   %eax,%eax
  800f44:	79 3e                	jns    800f84 <fork+0x191>
		    	panic("sys page map fault %e");
  800f46:	83 ec 04             	sub    $0x4,%esp
  800f49:	68 8c 25 80 00       	push   $0x80258c
  800f4e:	6a 5f                	push   $0x5f
  800f50:	68 5a 25 80 00       	push   $0x80255a
  800f55:	e8 aa 0d 00 00       	call   801d04 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800f5a:	83 ec 0c             	sub    $0xc,%esp
  800f5d:	6a 05                	push   $0x5
  800f5f:	56                   	push   %esi
  800f60:	57                   	push   %edi
  800f61:	56                   	push   %esi
  800f62:	6a 00                	push   $0x0
  800f64:	e8 c6 fb ff ff       	call   800b2f <sys_page_map>
		if (r < 0) {
  800f69:	83 c4 20             	add    $0x20,%esp
  800f6c:	85 c0                	test   %eax,%eax
  800f6e:	79 14                	jns    800f84 <fork+0x191>
		    	panic("sys page map fault %e");
  800f70:	83 ec 04             	sub    $0x4,%esp
  800f73:	68 8c 25 80 00       	push   $0x80258c
  800f78:	6a 64                	push   $0x64
  800f7a:	68 5a 25 80 00       	push   $0x80255a
  800f7f:	e8 80 0d 00 00       	call   801d04 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f84:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f8a:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800f90:	0f 85 de fe ff ff    	jne    800e74 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800f96:	a1 04 40 80 00       	mov    0x804004,%eax
  800f9b:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  800fa1:	83 ec 08             	sub    $0x8,%esp
  800fa4:	50                   	push   %eax
  800fa5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800fa8:	57                   	push   %edi
  800fa9:	e8 89 fc ff ff       	call   800c37 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  800fae:	83 c4 08             	add    $0x8,%esp
  800fb1:	6a 02                	push   $0x2
  800fb3:	57                   	push   %edi
  800fb4:	e8 fa fb ff ff       	call   800bb3 <sys_env_set_status>
	
	return envid;
  800fb9:	83 c4 10             	add    $0x10,%esp
  800fbc:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  800fbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc1:	5b                   	pop    %ebx
  800fc2:	5e                   	pop    %esi
  800fc3:	5f                   	pop    %edi
  800fc4:	5d                   	pop    %ebp
  800fc5:	c3                   	ret    

00800fc6 <sfork>:

envid_t
sfork(void)
{
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
	return 0;
}
  800fc9:	b8 00 00 00 00       	mov    $0x0,%eax
  800fce:	5d                   	pop    %ebp
  800fcf:	c3                   	ret    

00800fd0 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	56                   	push   %esi
  800fd4:	53                   	push   %ebx
  800fd5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  800fd8:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  800fde:	83 ec 08             	sub    $0x8,%esp
  800fe1:	53                   	push   %ebx
  800fe2:	68 a4 25 80 00       	push   $0x8025a4
  800fe7:	e8 78 f1 ff ff       	call   800164 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  800fec:	c7 04 24 97 00 80 00 	movl   $0x800097,(%esp)
  800ff3:	e8 e5 fc ff ff       	call   800cdd <sys_thread_create>
  800ff8:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  800ffa:	83 c4 08             	add    $0x8,%esp
  800ffd:	53                   	push   %ebx
  800ffe:	68 a4 25 80 00       	push   $0x8025a4
  801003:	e8 5c f1 ff ff       	call   800164 <cprintf>
	return id;
}
  801008:	89 f0                	mov    %esi,%eax
  80100a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80100d:	5b                   	pop    %ebx
  80100e:	5e                   	pop    %esi
  80100f:	5d                   	pop    %ebp
  801010:	c3                   	ret    

00801011 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801011:	55                   	push   %ebp
  801012:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801014:	8b 45 08             	mov    0x8(%ebp),%eax
  801017:	05 00 00 00 30       	add    $0x30000000,%eax
  80101c:	c1 e8 0c             	shr    $0xc,%eax
}
  80101f:	5d                   	pop    %ebp
  801020:	c3                   	ret    

00801021 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801021:	55                   	push   %ebp
  801022:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801024:	8b 45 08             	mov    0x8(%ebp),%eax
  801027:	05 00 00 00 30       	add    $0x30000000,%eax
  80102c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801031:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801036:	5d                   	pop    %ebp
  801037:	c3                   	ret    

00801038 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801038:	55                   	push   %ebp
  801039:	89 e5                	mov    %esp,%ebp
  80103b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80103e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801043:	89 c2                	mov    %eax,%edx
  801045:	c1 ea 16             	shr    $0x16,%edx
  801048:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80104f:	f6 c2 01             	test   $0x1,%dl
  801052:	74 11                	je     801065 <fd_alloc+0x2d>
  801054:	89 c2                	mov    %eax,%edx
  801056:	c1 ea 0c             	shr    $0xc,%edx
  801059:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801060:	f6 c2 01             	test   $0x1,%dl
  801063:	75 09                	jne    80106e <fd_alloc+0x36>
			*fd_store = fd;
  801065:	89 01                	mov    %eax,(%ecx)
			return 0;
  801067:	b8 00 00 00 00       	mov    $0x0,%eax
  80106c:	eb 17                	jmp    801085 <fd_alloc+0x4d>
  80106e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801073:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801078:	75 c9                	jne    801043 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80107a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801080:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801085:	5d                   	pop    %ebp
  801086:	c3                   	ret    

00801087 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801087:	55                   	push   %ebp
  801088:	89 e5                	mov    %esp,%ebp
  80108a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80108d:	83 f8 1f             	cmp    $0x1f,%eax
  801090:	77 36                	ja     8010c8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801092:	c1 e0 0c             	shl    $0xc,%eax
  801095:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80109a:	89 c2                	mov    %eax,%edx
  80109c:	c1 ea 16             	shr    $0x16,%edx
  80109f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010a6:	f6 c2 01             	test   $0x1,%dl
  8010a9:	74 24                	je     8010cf <fd_lookup+0x48>
  8010ab:	89 c2                	mov    %eax,%edx
  8010ad:	c1 ea 0c             	shr    $0xc,%edx
  8010b0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010b7:	f6 c2 01             	test   $0x1,%dl
  8010ba:	74 1a                	je     8010d6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010bf:	89 02                	mov    %eax,(%edx)
	return 0;
  8010c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c6:	eb 13                	jmp    8010db <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010c8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010cd:	eb 0c                	jmp    8010db <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010d4:	eb 05                	jmp    8010db <fd_lookup+0x54>
  8010d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010db:	5d                   	pop    %ebp
  8010dc:	c3                   	ret    

008010dd <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010dd:	55                   	push   %ebp
  8010de:	89 e5                	mov    %esp,%ebp
  8010e0:	83 ec 08             	sub    $0x8,%esp
  8010e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010e6:	ba 44 26 80 00       	mov    $0x802644,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8010eb:	eb 13                	jmp    801100 <dev_lookup+0x23>
  8010ed:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8010f0:	39 08                	cmp    %ecx,(%eax)
  8010f2:	75 0c                	jne    801100 <dev_lookup+0x23>
			*dev = devtab[i];
  8010f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8010fe:	eb 2e                	jmp    80112e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801100:	8b 02                	mov    (%edx),%eax
  801102:	85 c0                	test   %eax,%eax
  801104:	75 e7                	jne    8010ed <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801106:	a1 04 40 80 00       	mov    0x804004,%eax
  80110b:	8b 40 7c             	mov    0x7c(%eax),%eax
  80110e:	83 ec 04             	sub    $0x4,%esp
  801111:	51                   	push   %ecx
  801112:	50                   	push   %eax
  801113:	68 c8 25 80 00       	push   $0x8025c8
  801118:	e8 47 f0 ff ff       	call   800164 <cprintf>
	*dev = 0;
  80111d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801120:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801126:	83 c4 10             	add    $0x10,%esp
  801129:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80112e:	c9                   	leave  
  80112f:	c3                   	ret    

00801130 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801130:	55                   	push   %ebp
  801131:	89 e5                	mov    %esp,%ebp
  801133:	56                   	push   %esi
  801134:	53                   	push   %ebx
  801135:	83 ec 10             	sub    $0x10,%esp
  801138:	8b 75 08             	mov    0x8(%ebp),%esi
  80113b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80113e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801141:	50                   	push   %eax
  801142:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801148:	c1 e8 0c             	shr    $0xc,%eax
  80114b:	50                   	push   %eax
  80114c:	e8 36 ff ff ff       	call   801087 <fd_lookup>
  801151:	83 c4 08             	add    $0x8,%esp
  801154:	85 c0                	test   %eax,%eax
  801156:	78 05                	js     80115d <fd_close+0x2d>
	    || fd != fd2)
  801158:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80115b:	74 0c                	je     801169 <fd_close+0x39>
		return (must_exist ? r : 0);
  80115d:	84 db                	test   %bl,%bl
  80115f:	ba 00 00 00 00       	mov    $0x0,%edx
  801164:	0f 44 c2             	cmove  %edx,%eax
  801167:	eb 41                	jmp    8011aa <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801169:	83 ec 08             	sub    $0x8,%esp
  80116c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80116f:	50                   	push   %eax
  801170:	ff 36                	pushl  (%esi)
  801172:	e8 66 ff ff ff       	call   8010dd <dev_lookup>
  801177:	89 c3                	mov    %eax,%ebx
  801179:	83 c4 10             	add    $0x10,%esp
  80117c:	85 c0                	test   %eax,%eax
  80117e:	78 1a                	js     80119a <fd_close+0x6a>
		if (dev->dev_close)
  801180:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801183:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801186:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80118b:	85 c0                	test   %eax,%eax
  80118d:	74 0b                	je     80119a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80118f:	83 ec 0c             	sub    $0xc,%esp
  801192:	56                   	push   %esi
  801193:	ff d0                	call   *%eax
  801195:	89 c3                	mov    %eax,%ebx
  801197:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80119a:	83 ec 08             	sub    $0x8,%esp
  80119d:	56                   	push   %esi
  80119e:	6a 00                	push   $0x0
  8011a0:	e8 cc f9 ff ff       	call   800b71 <sys_page_unmap>
	return r;
  8011a5:	83 c4 10             	add    $0x10,%esp
  8011a8:	89 d8                	mov    %ebx,%eax
}
  8011aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011ad:	5b                   	pop    %ebx
  8011ae:	5e                   	pop    %esi
  8011af:	5d                   	pop    %ebp
  8011b0:	c3                   	ret    

008011b1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011b1:	55                   	push   %ebp
  8011b2:	89 e5                	mov    %esp,%ebp
  8011b4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ba:	50                   	push   %eax
  8011bb:	ff 75 08             	pushl  0x8(%ebp)
  8011be:	e8 c4 fe ff ff       	call   801087 <fd_lookup>
  8011c3:	83 c4 08             	add    $0x8,%esp
  8011c6:	85 c0                	test   %eax,%eax
  8011c8:	78 10                	js     8011da <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8011ca:	83 ec 08             	sub    $0x8,%esp
  8011cd:	6a 01                	push   $0x1
  8011cf:	ff 75 f4             	pushl  -0xc(%ebp)
  8011d2:	e8 59 ff ff ff       	call   801130 <fd_close>
  8011d7:	83 c4 10             	add    $0x10,%esp
}
  8011da:	c9                   	leave  
  8011db:	c3                   	ret    

008011dc <close_all>:

void
close_all(void)
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
  8011df:	53                   	push   %ebx
  8011e0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011e3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011e8:	83 ec 0c             	sub    $0xc,%esp
  8011eb:	53                   	push   %ebx
  8011ec:	e8 c0 ff ff ff       	call   8011b1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8011f1:	83 c3 01             	add    $0x1,%ebx
  8011f4:	83 c4 10             	add    $0x10,%esp
  8011f7:	83 fb 20             	cmp    $0x20,%ebx
  8011fa:	75 ec                	jne    8011e8 <close_all+0xc>
		close(i);
}
  8011fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ff:	c9                   	leave  
  801200:	c3                   	ret    

00801201 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801201:	55                   	push   %ebp
  801202:	89 e5                	mov    %esp,%ebp
  801204:	57                   	push   %edi
  801205:	56                   	push   %esi
  801206:	53                   	push   %ebx
  801207:	83 ec 2c             	sub    $0x2c,%esp
  80120a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80120d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801210:	50                   	push   %eax
  801211:	ff 75 08             	pushl  0x8(%ebp)
  801214:	e8 6e fe ff ff       	call   801087 <fd_lookup>
  801219:	83 c4 08             	add    $0x8,%esp
  80121c:	85 c0                	test   %eax,%eax
  80121e:	0f 88 c1 00 00 00    	js     8012e5 <dup+0xe4>
		return r;
	close(newfdnum);
  801224:	83 ec 0c             	sub    $0xc,%esp
  801227:	56                   	push   %esi
  801228:	e8 84 ff ff ff       	call   8011b1 <close>

	newfd = INDEX2FD(newfdnum);
  80122d:	89 f3                	mov    %esi,%ebx
  80122f:	c1 e3 0c             	shl    $0xc,%ebx
  801232:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801238:	83 c4 04             	add    $0x4,%esp
  80123b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80123e:	e8 de fd ff ff       	call   801021 <fd2data>
  801243:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801245:	89 1c 24             	mov    %ebx,(%esp)
  801248:	e8 d4 fd ff ff       	call   801021 <fd2data>
  80124d:	83 c4 10             	add    $0x10,%esp
  801250:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801253:	89 f8                	mov    %edi,%eax
  801255:	c1 e8 16             	shr    $0x16,%eax
  801258:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80125f:	a8 01                	test   $0x1,%al
  801261:	74 37                	je     80129a <dup+0x99>
  801263:	89 f8                	mov    %edi,%eax
  801265:	c1 e8 0c             	shr    $0xc,%eax
  801268:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80126f:	f6 c2 01             	test   $0x1,%dl
  801272:	74 26                	je     80129a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801274:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80127b:	83 ec 0c             	sub    $0xc,%esp
  80127e:	25 07 0e 00 00       	and    $0xe07,%eax
  801283:	50                   	push   %eax
  801284:	ff 75 d4             	pushl  -0x2c(%ebp)
  801287:	6a 00                	push   $0x0
  801289:	57                   	push   %edi
  80128a:	6a 00                	push   $0x0
  80128c:	e8 9e f8 ff ff       	call   800b2f <sys_page_map>
  801291:	89 c7                	mov    %eax,%edi
  801293:	83 c4 20             	add    $0x20,%esp
  801296:	85 c0                	test   %eax,%eax
  801298:	78 2e                	js     8012c8 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80129a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80129d:	89 d0                	mov    %edx,%eax
  80129f:	c1 e8 0c             	shr    $0xc,%eax
  8012a2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012a9:	83 ec 0c             	sub    $0xc,%esp
  8012ac:	25 07 0e 00 00       	and    $0xe07,%eax
  8012b1:	50                   	push   %eax
  8012b2:	53                   	push   %ebx
  8012b3:	6a 00                	push   $0x0
  8012b5:	52                   	push   %edx
  8012b6:	6a 00                	push   $0x0
  8012b8:	e8 72 f8 ff ff       	call   800b2f <sys_page_map>
  8012bd:	89 c7                	mov    %eax,%edi
  8012bf:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8012c2:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012c4:	85 ff                	test   %edi,%edi
  8012c6:	79 1d                	jns    8012e5 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012c8:	83 ec 08             	sub    $0x8,%esp
  8012cb:	53                   	push   %ebx
  8012cc:	6a 00                	push   $0x0
  8012ce:	e8 9e f8 ff ff       	call   800b71 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012d3:	83 c4 08             	add    $0x8,%esp
  8012d6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012d9:	6a 00                	push   $0x0
  8012db:	e8 91 f8 ff ff       	call   800b71 <sys_page_unmap>
	return r;
  8012e0:	83 c4 10             	add    $0x10,%esp
  8012e3:	89 f8                	mov    %edi,%eax
}
  8012e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012e8:	5b                   	pop    %ebx
  8012e9:	5e                   	pop    %esi
  8012ea:	5f                   	pop    %edi
  8012eb:	5d                   	pop    %ebp
  8012ec:	c3                   	ret    

008012ed <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012ed:	55                   	push   %ebp
  8012ee:	89 e5                	mov    %esp,%ebp
  8012f0:	53                   	push   %ebx
  8012f1:	83 ec 14             	sub    $0x14,%esp
  8012f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012fa:	50                   	push   %eax
  8012fb:	53                   	push   %ebx
  8012fc:	e8 86 fd ff ff       	call   801087 <fd_lookup>
  801301:	83 c4 08             	add    $0x8,%esp
  801304:	89 c2                	mov    %eax,%edx
  801306:	85 c0                	test   %eax,%eax
  801308:	78 6d                	js     801377 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80130a:	83 ec 08             	sub    $0x8,%esp
  80130d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801310:	50                   	push   %eax
  801311:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801314:	ff 30                	pushl  (%eax)
  801316:	e8 c2 fd ff ff       	call   8010dd <dev_lookup>
  80131b:	83 c4 10             	add    $0x10,%esp
  80131e:	85 c0                	test   %eax,%eax
  801320:	78 4c                	js     80136e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801322:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801325:	8b 42 08             	mov    0x8(%edx),%eax
  801328:	83 e0 03             	and    $0x3,%eax
  80132b:	83 f8 01             	cmp    $0x1,%eax
  80132e:	75 21                	jne    801351 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801330:	a1 04 40 80 00       	mov    0x804004,%eax
  801335:	8b 40 7c             	mov    0x7c(%eax),%eax
  801338:	83 ec 04             	sub    $0x4,%esp
  80133b:	53                   	push   %ebx
  80133c:	50                   	push   %eax
  80133d:	68 09 26 80 00       	push   $0x802609
  801342:	e8 1d ee ff ff       	call   800164 <cprintf>
		return -E_INVAL;
  801347:	83 c4 10             	add    $0x10,%esp
  80134a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80134f:	eb 26                	jmp    801377 <read+0x8a>
	}
	if (!dev->dev_read)
  801351:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801354:	8b 40 08             	mov    0x8(%eax),%eax
  801357:	85 c0                	test   %eax,%eax
  801359:	74 17                	je     801372 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80135b:	83 ec 04             	sub    $0x4,%esp
  80135e:	ff 75 10             	pushl  0x10(%ebp)
  801361:	ff 75 0c             	pushl  0xc(%ebp)
  801364:	52                   	push   %edx
  801365:	ff d0                	call   *%eax
  801367:	89 c2                	mov    %eax,%edx
  801369:	83 c4 10             	add    $0x10,%esp
  80136c:	eb 09                	jmp    801377 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80136e:	89 c2                	mov    %eax,%edx
  801370:	eb 05                	jmp    801377 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801372:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801377:	89 d0                	mov    %edx,%eax
  801379:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137c:	c9                   	leave  
  80137d:	c3                   	ret    

0080137e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80137e:	55                   	push   %ebp
  80137f:	89 e5                	mov    %esp,%ebp
  801381:	57                   	push   %edi
  801382:	56                   	push   %esi
  801383:	53                   	push   %ebx
  801384:	83 ec 0c             	sub    $0xc,%esp
  801387:	8b 7d 08             	mov    0x8(%ebp),%edi
  80138a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80138d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801392:	eb 21                	jmp    8013b5 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801394:	83 ec 04             	sub    $0x4,%esp
  801397:	89 f0                	mov    %esi,%eax
  801399:	29 d8                	sub    %ebx,%eax
  80139b:	50                   	push   %eax
  80139c:	89 d8                	mov    %ebx,%eax
  80139e:	03 45 0c             	add    0xc(%ebp),%eax
  8013a1:	50                   	push   %eax
  8013a2:	57                   	push   %edi
  8013a3:	e8 45 ff ff ff       	call   8012ed <read>
		if (m < 0)
  8013a8:	83 c4 10             	add    $0x10,%esp
  8013ab:	85 c0                	test   %eax,%eax
  8013ad:	78 10                	js     8013bf <readn+0x41>
			return m;
		if (m == 0)
  8013af:	85 c0                	test   %eax,%eax
  8013b1:	74 0a                	je     8013bd <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013b3:	01 c3                	add    %eax,%ebx
  8013b5:	39 f3                	cmp    %esi,%ebx
  8013b7:	72 db                	jb     801394 <readn+0x16>
  8013b9:	89 d8                	mov    %ebx,%eax
  8013bb:	eb 02                	jmp    8013bf <readn+0x41>
  8013bd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c2:	5b                   	pop    %ebx
  8013c3:	5e                   	pop    %esi
  8013c4:	5f                   	pop    %edi
  8013c5:	5d                   	pop    %ebp
  8013c6:	c3                   	ret    

008013c7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013c7:	55                   	push   %ebp
  8013c8:	89 e5                	mov    %esp,%ebp
  8013ca:	53                   	push   %ebx
  8013cb:	83 ec 14             	sub    $0x14,%esp
  8013ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013d4:	50                   	push   %eax
  8013d5:	53                   	push   %ebx
  8013d6:	e8 ac fc ff ff       	call   801087 <fd_lookup>
  8013db:	83 c4 08             	add    $0x8,%esp
  8013de:	89 c2                	mov    %eax,%edx
  8013e0:	85 c0                	test   %eax,%eax
  8013e2:	78 68                	js     80144c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e4:	83 ec 08             	sub    $0x8,%esp
  8013e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ea:	50                   	push   %eax
  8013eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ee:	ff 30                	pushl  (%eax)
  8013f0:	e8 e8 fc ff ff       	call   8010dd <dev_lookup>
  8013f5:	83 c4 10             	add    $0x10,%esp
  8013f8:	85 c0                	test   %eax,%eax
  8013fa:	78 47                	js     801443 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ff:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801403:	75 21                	jne    801426 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801405:	a1 04 40 80 00       	mov    0x804004,%eax
  80140a:	8b 40 7c             	mov    0x7c(%eax),%eax
  80140d:	83 ec 04             	sub    $0x4,%esp
  801410:	53                   	push   %ebx
  801411:	50                   	push   %eax
  801412:	68 25 26 80 00       	push   $0x802625
  801417:	e8 48 ed ff ff       	call   800164 <cprintf>
		return -E_INVAL;
  80141c:	83 c4 10             	add    $0x10,%esp
  80141f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801424:	eb 26                	jmp    80144c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801426:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801429:	8b 52 0c             	mov    0xc(%edx),%edx
  80142c:	85 d2                	test   %edx,%edx
  80142e:	74 17                	je     801447 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801430:	83 ec 04             	sub    $0x4,%esp
  801433:	ff 75 10             	pushl  0x10(%ebp)
  801436:	ff 75 0c             	pushl  0xc(%ebp)
  801439:	50                   	push   %eax
  80143a:	ff d2                	call   *%edx
  80143c:	89 c2                	mov    %eax,%edx
  80143e:	83 c4 10             	add    $0x10,%esp
  801441:	eb 09                	jmp    80144c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801443:	89 c2                	mov    %eax,%edx
  801445:	eb 05                	jmp    80144c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801447:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80144c:	89 d0                	mov    %edx,%eax
  80144e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801451:	c9                   	leave  
  801452:	c3                   	ret    

00801453 <seek>:

int
seek(int fdnum, off_t offset)
{
  801453:	55                   	push   %ebp
  801454:	89 e5                	mov    %esp,%ebp
  801456:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801459:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80145c:	50                   	push   %eax
  80145d:	ff 75 08             	pushl  0x8(%ebp)
  801460:	e8 22 fc ff ff       	call   801087 <fd_lookup>
  801465:	83 c4 08             	add    $0x8,%esp
  801468:	85 c0                	test   %eax,%eax
  80146a:	78 0e                	js     80147a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80146c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80146f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801472:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801475:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80147a:	c9                   	leave  
  80147b:	c3                   	ret    

0080147c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80147c:	55                   	push   %ebp
  80147d:	89 e5                	mov    %esp,%ebp
  80147f:	53                   	push   %ebx
  801480:	83 ec 14             	sub    $0x14,%esp
  801483:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801486:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801489:	50                   	push   %eax
  80148a:	53                   	push   %ebx
  80148b:	e8 f7 fb ff ff       	call   801087 <fd_lookup>
  801490:	83 c4 08             	add    $0x8,%esp
  801493:	89 c2                	mov    %eax,%edx
  801495:	85 c0                	test   %eax,%eax
  801497:	78 65                	js     8014fe <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801499:	83 ec 08             	sub    $0x8,%esp
  80149c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80149f:	50                   	push   %eax
  8014a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a3:	ff 30                	pushl  (%eax)
  8014a5:	e8 33 fc ff ff       	call   8010dd <dev_lookup>
  8014aa:	83 c4 10             	add    $0x10,%esp
  8014ad:	85 c0                	test   %eax,%eax
  8014af:	78 44                	js     8014f5 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014b8:	75 21                	jne    8014db <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014ba:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014bf:	8b 40 7c             	mov    0x7c(%eax),%eax
  8014c2:	83 ec 04             	sub    $0x4,%esp
  8014c5:	53                   	push   %ebx
  8014c6:	50                   	push   %eax
  8014c7:	68 e8 25 80 00       	push   $0x8025e8
  8014cc:	e8 93 ec ff ff       	call   800164 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014d1:	83 c4 10             	add    $0x10,%esp
  8014d4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014d9:	eb 23                	jmp    8014fe <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8014db:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014de:	8b 52 18             	mov    0x18(%edx),%edx
  8014e1:	85 d2                	test   %edx,%edx
  8014e3:	74 14                	je     8014f9 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014e5:	83 ec 08             	sub    $0x8,%esp
  8014e8:	ff 75 0c             	pushl  0xc(%ebp)
  8014eb:	50                   	push   %eax
  8014ec:	ff d2                	call   *%edx
  8014ee:	89 c2                	mov    %eax,%edx
  8014f0:	83 c4 10             	add    $0x10,%esp
  8014f3:	eb 09                	jmp    8014fe <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f5:	89 c2                	mov    %eax,%edx
  8014f7:	eb 05                	jmp    8014fe <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8014f9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8014fe:	89 d0                	mov    %edx,%eax
  801500:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801503:	c9                   	leave  
  801504:	c3                   	ret    

00801505 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801505:	55                   	push   %ebp
  801506:	89 e5                	mov    %esp,%ebp
  801508:	53                   	push   %ebx
  801509:	83 ec 14             	sub    $0x14,%esp
  80150c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80150f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801512:	50                   	push   %eax
  801513:	ff 75 08             	pushl  0x8(%ebp)
  801516:	e8 6c fb ff ff       	call   801087 <fd_lookup>
  80151b:	83 c4 08             	add    $0x8,%esp
  80151e:	89 c2                	mov    %eax,%edx
  801520:	85 c0                	test   %eax,%eax
  801522:	78 58                	js     80157c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801524:	83 ec 08             	sub    $0x8,%esp
  801527:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152a:	50                   	push   %eax
  80152b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152e:	ff 30                	pushl  (%eax)
  801530:	e8 a8 fb ff ff       	call   8010dd <dev_lookup>
  801535:	83 c4 10             	add    $0x10,%esp
  801538:	85 c0                	test   %eax,%eax
  80153a:	78 37                	js     801573 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80153c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80153f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801543:	74 32                	je     801577 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801545:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801548:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80154f:	00 00 00 
	stat->st_isdir = 0;
  801552:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801559:	00 00 00 
	stat->st_dev = dev;
  80155c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801562:	83 ec 08             	sub    $0x8,%esp
  801565:	53                   	push   %ebx
  801566:	ff 75 f0             	pushl  -0x10(%ebp)
  801569:	ff 50 14             	call   *0x14(%eax)
  80156c:	89 c2                	mov    %eax,%edx
  80156e:	83 c4 10             	add    $0x10,%esp
  801571:	eb 09                	jmp    80157c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801573:	89 c2                	mov    %eax,%edx
  801575:	eb 05                	jmp    80157c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801577:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80157c:	89 d0                	mov    %edx,%eax
  80157e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801581:	c9                   	leave  
  801582:	c3                   	ret    

00801583 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801583:	55                   	push   %ebp
  801584:	89 e5                	mov    %esp,%ebp
  801586:	56                   	push   %esi
  801587:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801588:	83 ec 08             	sub    $0x8,%esp
  80158b:	6a 00                	push   $0x0
  80158d:	ff 75 08             	pushl  0x8(%ebp)
  801590:	e8 e3 01 00 00       	call   801778 <open>
  801595:	89 c3                	mov    %eax,%ebx
  801597:	83 c4 10             	add    $0x10,%esp
  80159a:	85 c0                	test   %eax,%eax
  80159c:	78 1b                	js     8015b9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80159e:	83 ec 08             	sub    $0x8,%esp
  8015a1:	ff 75 0c             	pushl  0xc(%ebp)
  8015a4:	50                   	push   %eax
  8015a5:	e8 5b ff ff ff       	call   801505 <fstat>
  8015aa:	89 c6                	mov    %eax,%esi
	close(fd);
  8015ac:	89 1c 24             	mov    %ebx,(%esp)
  8015af:	e8 fd fb ff ff       	call   8011b1 <close>
	return r;
  8015b4:	83 c4 10             	add    $0x10,%esp
  8015b7:	89 f0                	mov    %esi,%eax
}
  8015b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015bc:	5b                   	pop    %ebx
  8015bd:	5e                   	pop    %esi
  8015be:	5d                   	pop    %ebp
  8015bf:	c3                   	ret    

008015c0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015c0:	55                   	push   %ebp
  8015c1:	89 e5                	mov    %esp,%ebp
  8015c3:	56                   	push   %esi
  8015c4:	53                   	push   %ebx
  8015c5:	89 c6                	mov    %eax,%esi
  8015c7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015c9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015d0:	75 12                	jne    8015e4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015d2:	83 ec 0c             	sub    $0xc,%esp
  8015d5:	6a 01                	push   $0x1
  8015d7:	e8 da 08 00 00       	call   801eb6 <ipc_find_env>
  8015dc:	a3 00 40 80 00       	mov    %eax,0x804000
  8015e1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015e4:	6a 07                	push   $0x7
  8015e6:	68 00 50 80 00       	push   $0x805000
  8015eb:	56                   	push   %esi
  8015ec:	ff 35 00 40 80 00    	pushl  0x804000
  8015f2:	e8 5d 08 00 00       	call   801e54 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8015f7:	83 c4 0c             	add    $0xc,%esp
  8015fa:	6a 00                	push   $0x0
  8015fc:	53                   	push   %ebx
  8015fd:	6a 00                	push   $0x0
  8015ff:	e8 d5 07 00 00       	call   801dd9 <ipc_recv>
}
  801604:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801607:	5b                   	pop    %ebx
  801608:	5e                   	pop    %esi
  801609:	5d                   	pop    %ebp
  80160a:	c3                   	ret    

0080160b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80160b:	55                   	push   %ebp
  80160c:	89 e5                	mov    %esp,%ebp
  80160e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801611:	8b 45 08             	mov    0x8(%ebp),%eax
  801614:	8b 40 0c             	mov    0xc(%eax),%eax
  801617:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80161c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80161f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801624:	ba 00 00 00 00       	mov    $0x0,%edx
  801629:	b8 02 00 00 00       	mov    $0x2,%eax
  80162e:	e8 8d ff ff ff       	call   8015c0 <fsipc>
}
  801633:	c9                   	leave  
  801634:	c3                   	ret    

00801635 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801635:	55                   	push   %ebp
  801636:	89 e5                	mov    %esp,%ebp
  801638:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80163b:	8b 45 08             	mov    0x8(%ebp),%eax
  80163e:	8b 40 0c             	mov    0xc(%eax),%eax
  801641:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801646:	ba 00 00 00 00       	mov    $0x0,%edx
  80164b:	b8 06 00 00 00       	mov    $0x6,%eax
  801650:	e8 6b ff ff ff       	call   8015c0 <fsipc>
}
  801655:	c9                   	leave  
  801656:	c3                   	ret    

00801657 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801657:	55                   	push   %ebp
  801658:	89 e5                	mov    %esp,%ebp
  80165a:	53                   	push   %ebx
  80165b:	83 ec 04             	sub    $0x4,%esp
  80165e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801661:	8b 45 08             	mov    0x8(%ebp),%eax
  801664:	8b 40 0c             	mov    0xc(%eax),%eax
  801667:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80166c:	ba 00 00 00 00       	mov    $0x0,%edx
  801671:	b8 05 00 00 00       	mov    $0x5,%eax
  801676:	e8 45 ff ff ff       	call   8015c0 <fsipc>
  80167b:	85 c0                	test   %eax,%eax
  80167d:	78 2c                	js     8016ab <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80167f:	83 ec 08             	sub    $0x8,%esp
  801682:	68 00 50 80 00       	push   $0x805000
  801687:	53                   	push   %ebx
  801688:	e8 5c f0 ff ff       	call   8006e9 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80168d:	a1 80 50 80 00       	mov    0x805080,%eax
  801692:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801698:	a1 84 50 80 00       	mov    0x805084,%eax
  80169d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016a3:	83 c4 10             	add    $0x10,%esp
  8016a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ae:	c9                   	leave  
  8016af:	c3                   	ret    

008016b0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	83 ec 0c             	sub    $0xc,%esp
  8016b6:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8016bc:	8b 52 0c             	mov    0xc(%edx),%edx
  8016bf:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8016c5:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8016ca:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8016cf:	0f 47 c2             	cmova  %edx,%eax
  8016d2:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8016d7:	50                   	push   %eax
  8016d8:	ff 75 0c             	pushl  0xc(%ebp)
  8016db:	68 08 50 80 00       	push   $0x805008
  8016e0:	e8 96 f1 ff ff       	call   80087b <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8016e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ea:	b8 04 00 00 00       	mov    $0x4,%eax
  8016ef:	e8 cc fe ff ff       	call   8015c0 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8016f4:	c9                   	leave  
  8016f5:	c3                   	ret    

008016f6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	56                   	push   %esi
  8016fa:	53                   	push   %ebx
  8016fb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801701:	8b 40 0c             	mov    0xc(%eax),%eax
  801704:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801709:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80170f:	ba 00 00 00 00       	mov    $0x0,%edx
  801714:	b8 03 00 00 00       	mov    $0x3,%eax
  801719:	e8 a2 fe ff ff       	call   8015c0 <fsipc>
  80171e:	89 c3                	mov    %eax,%ebx
  801720:	85 c0                	test   %eax,%eax
  801722:	78 4b                	js     80176f <devfile_read+0x79>
		return r;
	assert(r <= n);
  801724:	39 c6                	cmp    %eax,%esi
  801726:	73 16                	jae    80173e <devfile_read+0x48>
  801728:	68 54 26 80 00       	push   $0x802654
  80172d:	68 5b 26 80 00       	push   $0x80265b
  801732:	6a 7c                	push   $0x7c
  801734:	68 70 26 80 00       	push   $0x802670
  801739:	e8 c6 05 00 00       	call   801d04 <_panic>
	assert(r <= PGSIZE);
  80173e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801743:	7e 16                	jle    80175b <devfile_read+0x65>
  801745:	68 7b 26 80 00       	push   $0x80267b
  80174a:	68 5b 26 80 00       	push   $0x80265b
  80174f:	6a 7d                	push   $0x7d
  801751:	68 70 26 80 00       	push   $0x802670
  801756:	e8 a9 05 00 00       	call   801d04 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80175b:	83 ec 04             	sub    $0x4,%esp
  80175e:	50                   	push   %eax
  80175f:	68 00 50 80 00       	push   $0x805000
  801764:	ff 75 0c             	pushl  0xc(%ebp)
  801767:	e8 0f f1 ff ff       	call   80087b <memmove>
	return r;
  80176c:	83 c4 10             	add    $0x10,%esp
}
  80176f:	89 d8                	mov    %ebx,%eax
  801771:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801774:	5b                   	pop    %ebx
  801775:	5e                   	pop    %esi
  801776:	5d                   	pop    %ebp
  801777:	c3                   	ret    

00801778 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801778:	55                   	push   %ebp
  801779:	89 e5                	mov    %esp,%ebp
  80177b:	53                   	push   %ebx
  80177c:	83 ec 20             	sub    $0x20,%esp
  80177f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801782:	53                   	push   %ebx
  801783:	e8 28 ef ff ff       	call   8006b0 <strlen>
  801788:	83 c4 10             	add    $0x10,%esp
  80178b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801790:	7f 67                	jg     8017f9 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801792:	83 ec 0c             	sub    $0xc,%esp
  801795:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801798:	50                   	push   %eax
  801799:	e8 9a f8 ff ff       	call   801038 <fd_alloc>
  80179e:	83 c4 10             	add    $0x10,%esp
		return r;
  8017a1:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017a3:	85 c0                	test   %eax,%eax
  8017a5:	78 57                	js     8017fe <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017a7:	83 ec 08             	sub    $0x8,%esp
  8017aa:	53                   	push   %ebx
  8017ab:	68 00 50 80 00       	push   $0x805000
  8017b0:	e8 34 ef ff ff       	call   8006e9 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017c0:	b8 01 00 00 00       	mov    $0x1,%eax
  8017c5:	e8 f6 fd ff ff       	call   8015c0 <fsipc>
  8017ca:	89 c3                	mov    %eax,%ebx
  8017cc:	83 c4 10             	add    $0x10,%esp
  8017cf:	85 c0                	test   %eax,%eax
  8017d1:	79 14                	jns    8017e7 <open+0x6f>
		fd_close(fd, 0);
  8017d3:	83 ec 08             	sub    $0x8,%esp
  8017d6:	6a 00                	push   $0x0
  8017d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8017db:	e8 50 f9 ff ff       	call   801130 <fd_close>
		return r;
  8017e0:	83 c4 10             	add    $0x10,%esp
  8017e3:	89 da                	mov    %ebx,%edx
  8017e5:	eb 17                	jmp    8017fe <open+0x86>
	}

	return fd2num(fd);
  8017e7:	83 ec 0c             	sub    $0xc,%esp
  8017ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8017ed:	e8 1f f8 ff ff       	call   801011 <fd2num>
  8017f2:	89 c2                	mov    %eax,%edx
  8017f4:	83 c4 10             	add    $0x10,%esp
  8017f7:	eb 05                	jmp    8017fe <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8017f9:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8017fe:	89 d0                	mov    %edx,%eax
  801800:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801803:	c9                   	leave  
  801804:	c3                   	ret    

00801805 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801805:	55                   	push   %ebp
  801806:	89 e5                	mov    %esp,%ebp
  801808:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80180b:	ba 00 00 00 00       	mov    $0x0,%edx
  801810:	b8 08 00 00 00       	mov    $0x8,%eax
  801815:	e8 a6 fd ff ff       	call   8015c0 <fsipc>
}
  80181a:	c9                   	leave  
  80181b:	c3                   	ret    

0080181c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80181c:	55                   	push   %ebp
  80181d:	89 e5                	mov    %esp,%ebp
  80181f:	56                   	push   %esi
  801820:	53                   	push   %ebx
  801821:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801824:	83 ec 0c             	sub    $0xc,%esp
  801827:	ff 75 08             	pushl  0x8(%ebp)
  80182a:	e8 f2 f7 ff ff       	call   801021 <fd2data>
  80182f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801831:	83 c4 08             	add    $0x8,%esp
  801834:	68 87 26 80 00       	push   $0x802687
  801839:	53                   	push   %ebx
  80183a:	e8 aa ee ff ff       	call   8006e9 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80183f:	8b 46 04             	mov    0x4(%esi),%eax
  801842:	2b 06                	sub    (%esi),%eax
  801844:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80184a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801851:	00 00 00 
	stat->st_dev = &devpipe;
  801854:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80185b:	30 80 00 
	return 0;
}
  80185e:	b8 00 00 00 00       	mov    $0x0,%eax
  801863:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801866:	5b                   	pop    %ebx
  801867:	5e                   	pop    %esi
  801868:	5d                   	pop    %ebp
  801869:	c3                   	ret    

0080186a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80186a:	55                   	push   %ebp
  80186b:	89 e5                	mov    %esp,%ebp
  80186d:	53                   	push   %ebx
  80186e:	83 ec 0c             	sub    $0xc,%esp
  801871:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801874:	53                   	push   %ebx
  801875:	6a 00                	push   $0x0
  801877:	e8 f5 f2 ff ff       	call   800b71 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80187c:	89 1c 24             	mov    %ebx,(%esp)
  80187f:	e8 9d f7 ff ff       	call   801021 <fd2data>
  801884:	83 c4 08             	add    $0x8,%esp
  801887:	50                   	push   %eax
  801888:	6a 00                	push   $0x0
  80188a:	e8 e2 f2 ff ff       	call   800b71 <sys_page_unmap>
}
  80188f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801892:	c9                   	leave  
  801893:	c3                   	ret    

00801894 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801894:	55                   	push   %ebp
  801895:	89 e5                	mov    %esp,%ebp
  801897:	57                   	push   %edi
  801898:	56                   	push   %esi
  801899:	53                   	push   %ebx
  80189a:	83 ec 1c             	sub    $0x1c,%esp
  80189d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018a0:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018a2:	a1 04 40 80 00       	mov    0x804004,%eax
  8018a7:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8018ad:	83 ec 0c             	sub    $0xc,%esp
  8018b0:	ff 75 e0             	pushl  -0x20(%ebp)
  8018b3:	e8 40 06 00 00       	call   801ef8 <pageref>
  8018b8:	89 c3                	mov    %eax,%ebx
  8018ba:	89 3c 24             	mov    %edi,(%esp)
  8018bd:	e8 36 06 00 00       	call   801ef8 <pageref>
  8018c2:	83 c4 10             	add    $0x10,%esp
  8018c5:	39 c3                	cmp    %eax,%ebx
  8018c7:	0f 94 c1             	sete   %cl
  8018ca:	0f b6 c9             	movzbl %cl,%ecx
  8018cd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8018d0:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8018d6:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  8018dc:	39 ce                	cmp    %ecx,%esi
  8018de:	74 1e                	je     8018fe <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  8018e0:	39 c3                	cmp    %eax,%ebx
  8018e2:	75 be                	jne    8018a2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018e4:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  8018ea:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018ed:	50                   	push   %eax
  8018ee:	56                   	push   %esi
  8018ef:	68 8e 26 80 00       	push   $0x80268e
  8018f4:	e8 6b e8 ff ff       	call   800164 <cprintf>
  8018f9:	83 c4 10             	add    $0x10,%esp
  8018fc:	eb a4                	jmp    8018a2 <_pipeisclosed+0xe>
	}
}
  8018fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801901:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801904:	5b                   	pop    %ebx
  801905:	5e                   	pop    %esi
  801906:	5f                   	pop    %edi
  801907:	5d                   	pop    %ebp
  801908:	c3                   	ret    

00801909 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801909:	55                   	push   %ebp
  80190a:	89 e5                	mov    %esp,%ebp
  80190c:	57                   	push   %edi
  80190d:	56                   	push   %esi
  80190e:	53                   	push   %ebx
  80190f:	83 ec 28             	sub    $0x28,%esp
  801912:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801915:	56                   	push   %esi
  801916:	e8 06 f7 ff ff       	call   801021 <fd2data>
  80191b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80191d:	83 c4 10             	add    $0x10,%esp
  801920:	bf 00 00 00 00       	mov    $0x0,%edi
  801925:	eb 4b                	jmp    801972 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801927:	89 da                	mov    %ebx,%edx
  801929:	89 f0                	mov    %esi,%eax
  80192b:	e8 64 ff ff ff       	call   801894 <_pipeisclosed>
  801930:	85 c0                	test   %eax,%eax
  801932:	75 48                	jne    80197c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801934:	e8 94 f1 ff ff       	call   800acd <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801939:	8b 43 04             	mov    0x4(%ebx),%eax
  80193c:	8b 0b                	mov    (%ebx),%ecx
  80193e:	8d 51 20             	lea    0x20(%ecx),%edx
  801941:	39 d0                	cmp    %edx,%eax
  801943:	73 e2                	jae    801927 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801945:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801948:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80194c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80194f:	89 c2                	mov    %eax,%edx
  801951:	c1 fa 1f             	sar    $0x1f,%edx
  801954:	89 d1                	mov    %edx,%ecx
  801956:	c1 e9 1b             	shr    $0x1b,%ecx
  801959:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80195c:	83 e2 1f             	and    $0x1f,%edx
  80195f:	29 ca                	sub    %ecx,%edx
  801961:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801965:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801969:	83 c0 01             	add    $0x1,%eax
  80196c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80196f:	83 c7 01             	add    $0x1,%edi
  801972:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801975:	75 c2                	jne    801939 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801977:	8b 45 10             	mov    0x10(%ebp),%eax
  80197a:	eb 05                	jmp    801981 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80197c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801981:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801984:	5b                   	pop    %ebx
  801985:	5e                   	pop    %esi
  801986:	5f                   	pop    %edi
  801987:	5d                   	pop    %ebp
  801988:	c3                   	ret    

00801989 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801989:	55                   	push   %ebp
  80198a:	89 e5                	mov    %esp,%ebp
  80198c:	57                   	push   %edi
  80198d:	56                   	push   %esi
  80198e:	53                   	push   %ebx
  80198f:	83 ec 18             	sub    $0x18,%esp
  801992:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801995:	57                   	push   %edi
  801996:	e8 86 f6 ff ff       	call   801021 <fd2data>
  80199b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80199d:	83 c4 10             	add    $0x10,%esp
  8019a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019a5:	eb 3d                	jmp    8019e4 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019a7:	85 db                	test   %ebx,%ebx
  8019a9:	74 04                	je     8019af <devpipe_read+0x26>
				return i;
  8019ab:	89 d8                	mov    %ebx,%eax
  8019ad:	eb 44                	jmp    8019f3 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019af:	89 f2                	mov    %esi,%edx
  8019b1:	89 f8                	mov    %edi,%eax
  8019b3:	e8 dc fe ff ff       	call   801894 <_pipeisclosed>
  8019b8:	85 c0                	test   %eax,%eax
  8019ba:	75 32                	jne    8019ee <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019bc:	e8 0c f1 ff ff       	call   800acd <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019c1:	8b 06                	mov    (%esi),%eax
  8019c3:	3b 46 04             	cmp    0x4(%esi),%eax
  8019c6:	74 df                	je     8019a7 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019c8:	99                   	cltd   
  8019c9:	c1 ea 1b             	shr    $0x1b,%edx
  8019cc:	01 d0                	add    %edx,%eax
  8019ce:	83 e0 1f             	and    $0x1f,%eax
  8019d1:	29 d0                	sub    %edx,%eax
  8019d3:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8019d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019db:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8019de:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019e1:	83 c3 01             	add    $0x1,%ebx
  8019e4:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019e7:	75 d8                	jne    8019c1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8019ec:	eb 05                	jmp    8019f3 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019ee:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8019f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019f6:	5b                   	pop    %ebx
  8019f7:	5e                   	pop    %esi
  8019f8:	5f                   	pop    %edi
  8019f9:	5d                   	pop    %ebp
  8019fa:	c3                   	ret    

008019fb <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8019fb:	55                   	push   %ebp
  8019fc:	89 e5                	mov    %esp,%ebp
  8019fe:	56                   	push   %esi
  8019ff:	53                   	push   %ebx
  801a00:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a03:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a06:	50                   	push   %eax
  801a07:	e8 2c f6 ff ff       	call   801038 <fd_alloc>
  801a0c:	83 c4 10             	add    $0x10,%esp
  801a0f:	89 c2                	mov    %eax,%edx
  801a11:	85 c0                	test   %eax,%eax
  801a13:	0f 88 2c 01 00 00    	js     801b45 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a19:	83 ec 04             	sub    $0x4,%esp
  801a1c:	68 07 04 00 00       	push   $0x407
  801a21:	ff 75 f4             	pushl  -0xc(%ebp)
  801a24:	6a 00                	push   $0x0
  801a26:	e8 c1 f0 ff ff       	call   800aec <sys_page_alloc>
  801a2b:	83 c4 10             	add    $0x10,%esp
  801a2e:	89 c2                	mov    %eax,%edx
  801a30:	85 c0                	test   %eax,%eax
  801a32:	0f 88 0d 01 00 00    	js     801b45 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a38:	83 ec 0c             	sub    $0xc,%esp
  801a3b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a3e:	50                   	push   %eax
  801a3f:	e8 f4 f5 ff ff       	call   801038 <fd_alloc>
  801a44:	89 c3                	mov    %eax,%ebx
  801a46:	83 c4 10             	add    $0x10,%esp
  801a49:	85 c0                	test   %eax,%eax
  801a4b:	0f 88 e2 00 00 00    	js     801b33 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a51:	83 ec 04             	sub    $0x4,%esp
  801a54:	68 07 04 00 00       	push   $0x407
  801a59:	ff 75 f0             	pushl  -0x10(%ebp)
  801a5c:	6a 00                	push   $0x0
  801a5e:	e8 89 f0 ff ff       	call   800aec <sys_page_alloc>
  801a63:	89 c3                	mov    %eax,%ebx
  801a65:	83 c4 10             	add    $0x10,%esp
  801a68:	85 c0                	test   %eax,%eax
  801a6a:	0f 88 c3 00 00 00    	js     801b33 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a70:	83 ec 0c             	sub    $0xc,%esp
  801a73:	ff 75 f4             	pushl  -0xc(%ebp)
  801a76:	e8 a6 f5 ff ff       	call   801021 <fd2data>
  801a7b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a7d:	83 c4 0c             	add    $0xc,%esp
  801a80:	68 07 04 00 00       	push   $0x407
  801a85:	50                   	push   %eax
  801a86:	6a 00                	push   $0x0
  801a88:	e8 5f f0 ff ff       	call   800aec <sys_page_alloc>
  801a8d:	89 c3                	mov    %eax,%ebx
  801a8f:	83 c4 10             	add    $0x10,%esp
  801a92:	85 c0                	test   %eax,%eax
  801a94:	0f 88 89 00 00 00    	js     801b23 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a9a:	83 ec 0c             	sub    $0xc,%esp
  801a9d:	ff 75 f0             	pushl  -0x10(%ebp)
  801aa0:	e8 7c f5 ff ff       	call   801021 <fd2data>
  801aa5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801aac:	50                   	push   %eax
  801aad:	6a 00                	push   $0x0
  801aaf:	56                   	push   %esi
  801ab0:	6a 00                	push   $0x0
  801ab2:	e8 78 f0 ff ff       	call   800b2f <sys_page_map>
  801ab7:	89 c3                	mov    %eax,%ebx
  801ab9:	83 c4 20             	add    $0x20,%esp
  801abc:	85 c0                	test   %eax,%eax
  801abe:	78 55                	js     801b15 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ac0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ace:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ad5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801adb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ade:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ae0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ae3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801aea:	83 ec 0c             	sub    $0xc,%esp
  801aed:	ff 75 f4             	pushl  -0xc(%ebp)
  801af0:	e8 1c f5 ff ff       	call   801011 <fd2num>
  801af5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801af8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801afa:	83 c4 04             	add    $0x4,%esp
  801afd:	ff 75 f0             	pushl  -0x10(%ebp)
  801b00:	e8 0c f5 ff ff       	call   801011 <fd2num>
  801b05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b08:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801b0b:	83 c4 10             	add    $0x10,%esp
  801b0e:	ba 00 00 00 00       	mov    $0x0,%edx
  801b13:	eb 30                	jmp    801b45 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b15:	83 ec 08             	sub    $0x8,%esp
  801b18:	56                   	push   %esi
  801b19:	6a 00                	push   $0x0
  801b1b:	e8 51 f0 ff ff       	call   800b71 <sys_page_unmap>
  801b20:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b23:	83 ec 08             	sub    $0x8,%esp
  801b26:	ff 75 f0             	pushl  -0x10(%ebp)
  801b29:	6a 00                	push   $0x0
  801b2b:	e8 41 f0 ff ff       	call   800b71 <sys_page_unmap>
  801b30:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b33:	83 ec 08             	sub    $0x8,%esp
  801b36:	ff 75 f4             	pushl  -0xc(%ebp)
  801b39:	6a 00                	push   $0x0
  801b3b:	e8 31 f0 ff ff       	call   800b71 <sys_page_unmap>
  801b40:	83 c4 10             	add    $0x10,%esp
  801b43:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b45:	89 d0                	mov    %edx,%eax
  801b47:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b4a:	5b                   	pop    %ebx
  801b4b:	5e                   	pop    %esi
  801b4c:	5d                   	pop    %ebp
  801b4d:	c3                   	ret    

00801b4e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b4e:	55                   	push   %ebp
  801b4f:	89 e5                	mov    %esp,%ebp
  801b51:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b54:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b57:	50                   	push   %eax
  801b58:	ff 75 08             	pushl  0x8(%ebp)
  801b5b:	e8 27 f5 ff ff       	call   801087 <fd_lookup>
  801b60:	83 c4 10             	add    $0x10,%esp
  801b63:	85 c0                	test   %eax,%eax
  801b65:	78 18                	js     801b7f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b67:	83 ec 0c             	sub    $0xc,%esp
  801b6a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b6d:	e8 af f4 ff ff       	call   801021 <fd2data>
	return _pipeisclosed(fd, p);
  801b72:	89 c2                	mov    %eax,%edx
  801b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b77:	e8 18 fd ff ff       	call   801894 <_pipeisclosed>
  801b7c:	83 c4 10             	add    $0x10,%esp
}
  801b7f:	c9                   	leave  
  801b80:	c3                   	ret    

00801b81 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b81:	55                   	push   %ebp
  801b82:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b84:	b8 00 00 00 00       	mov    $0x0,%eax
  801b89:	5d                   	pop    %ebp
  801b8a:	c3                   	ret    

00801b8b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b8b:	55                   	push   %ebp
  801b8c:	89 e5                	mov    %esp,%ebp
  801b8e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b91:	68 a6 26 80 00       	push   $0x8026a6
  801b96:	ff 75 0c             	pushl  0xc(%ebp)
  801b99:	e8 4b eb ff ff       	call   8006e9 <strcpy>
	return 0;
}
  801b9e:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba3:	c9                   	leave  
  801ba4:	c3                   	ret    

00801ba5 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ba5:	55                   	push   %ebp
  801ba6:	89 e5                	mov    %esp,%ebp
  801ba8:	57                   	push   %edi
  801ba9:	56                   	push   %esi
  801baa:	53                   	push   %ebx
  801bab:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bb1:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bb6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bbc:	eb 2d                	jmp    801beb <devcons_write+0x46>
		m = n - tot;
  801bbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801bc1:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801bc3:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801bc6:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801bcb:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bce:	83 ec 04             	sub    $0x4,%esp
  801bd1:	53                   	push   %ebx
  801bd2:	03 45 0c             	add    0xc(%ebp),%eax
  801bd5:	50                   	push   %eax
  801bd6:	57                   	push   %edi
  801bd7:	e8 9f ec ff ff       	call   80087b <memmove>
		sys_cputs(buf, m);
  801bdc:	83 c4 08             	add    $0x8,%esp
  801bdf:	53                   	push   %ebx
  801be0:	57                   	push   %edi
  801be1:	e8 4a ee ff ff       	call   800a30 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801be6:	01 de                	add    %ebx,%esi
  801be8:	83 c4 10             	add    $0x10,%esp
  801beb:	89 f0                	mov    %esi,%eax
  801bed:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bf0:	72 cc                	jb     801bbe <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801bf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bf5:	5b                   	pop    %ebx
  801bf6:	5e                   	pop    %esi
  801bf7:	5f                   	pop    %edi
  801bf8:	5d                   	pop    %ebp
  801bf9:	c3                   	ret    

00801bfa <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bfa:	55                   	push   %ebp
  801bfb:	89 e5                	mov    %esp,%ebp
  801bfd:	83 ec 08             	sub    $0x8,%esp
  801c00:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c05:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c09:	74 2a                	je     801c35 <devcons_read+0x3b>
  801c0b:	eb 05                	jmp    801c12 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c0d:	e8 bb ee ff ff       	call   800acd <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c12:	e8 37 ee ff ff       	call   800a4e <sys_cgetc>
  801c17:	85 c0                	test   %eax,%eax
  801c19:	74 f2                	je     801c0d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c1b:	85 c0                	test   %eax,%eax
  801c1d:	78 16                	js     801c35 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c1f:	83 f8 04             	cmp    $0x4,%eax
  801c22:	74 0c                	je     801c30 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c24:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c27:	88 02                	mov    %al,(%edx)
	return 1;
  801c29:	b8 01 00 00 00       	mov    $0x1,%eax
  801c2e:	eb 05                	jmp    801c35 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c30:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c35:	c9                   	leave  
  801c36:	c3                   	ret    

00801c37 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c37:	55                   	push   %ebp
  801c38:	89 e5                	mov    %esp,%ebp
  801c3a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c40:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c43:	6a 01                	push   $0x1
  801c45:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c48:	50                   	push   %eax
  801c49:	e8 e2 ed ff ff       	call   800a30 <sys_cputs>
}
  801c4e:	83 c4 10             	add    $0x10,%esp
  801c51:	c9                   	leave  
  801c52:	c3                   	ret    

00801c53 <getchar>:

int
getchar(void)
{
  801c53:	55                   	push   %ebp
  801c54:	89 e5                	mov    %esp,%ebp
  801c56:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c59:	6a 01                	push   $0x1
  801c5b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c5e:	50                   	push   %eax
  801c5f:	6a 00                	push   $0x0
  801c61:	e8 87 f6 ff ff       	call   8012ed <read>
	if (r < 0)
  801c66:	83 c4 10             	add    $0x10,%esp
  801c69:	85 c0                	test   %eax,%eax
  801c6b:	78 0f                	js     801c7c <getchar+0x29>
		return r;
	if (r < 1)
  801c6d:	85 c0                	test   %eax,%eax
  801c6f:	7e 06                	jle    801c77 <getchar+0x24>
		return -E_EOF;
	return c;
  801c71:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c75:	eb 05                	jmp    801c7c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c77:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c7c:	c9                   	leave  
  801c7d:	c3                   	ret    

00801c7e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c7e:	55                   	push   %ebp
  801c7f:	89 e5                	mov    %esp,%ebp
  801c81:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c84:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c87:	50                   	push   %eax
  801c88:	ff 75 08             	pushl  0x8(%ebp)
  801c8b:	e8 f7 f3 ff ff       	call   801087 <fd_lookup>
  801c90:	83 c4 10             	add    $0x10,%esp
  801c93:	85 c0                	test   %eax,%eax
  801c95:	78 11                	js     801ca8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c9a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ca0:	39 10                	cmp    %edx,(%eax)
  801ca2:	0f 94 c0             	sete   %al
  801ca5:	0f b6 c0             	movzbl %al,%eax
}
  801ca8:	c9                   	leave  
  801ca9:	c3                   	ret    

00801caa <opencons>:

int
opencons(void)
{
  801caa:	55                   	push   %ebp
  801cab:	89 e5                	mov    %esp,%ebp
  801cad:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cb0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cb3:	50                   	push   %eax
  801cb4:	e8 7f f3 ff ff       	call   801038 <fd_alloc>
  801cb9:	83 c4 10             	add    $0x10,%esp
		return r;
  801cbc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cbe:	85 c0                	test   %eax,%eax
  801cc0:	78 3e                	js     801d00 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cc2:	83 ec 04             	sub    $0x4,%esp
  801cc5:	68 07 04 00 00       	push   $0x407
  801cca:	ff 75 f4             	pushl  -0xc(%ebp)
  801ccd:	6a 00                	push   $0x0
  801ccf:	e8 18 ee ff ff       	call   800aec <sys_page_alloc>
  801cd4:	83 c4 10             	add    $0x10,%esp
		return r;
  801cd7:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cd9:	85 c0                	test   %eax,%eax
  801cdb:	78 23                	js     801d00 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801cdd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ceb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801cf2:	83 ec 0c             	sub    $0xc,%esp
  801cf5:	50                   	push   %eax
  801cf6:	e8 16 f3 ff ff       	call   801011 <fd2num>
  801cfb:	89 c2                	mov    %eax,%edx
  801cfd:	83 c4 10             	add    $0x10,%esp
}
  801d00:	89 d0                	mov    %edx,%eax
  801d02:	c9                   	leave  
  801d03:	c3                   	ret    

00801d04 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d04:	55                   	push   %ebp
  801d05:	89 e5                	mov    %esp,%ebp
  801d07:	56                   	push   %esi
  801d08:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d09:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d0c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d12:	e8 97 ed ff ff       	call   800aae <sys_getenvid>
  801d17:	83 ec 0c             	sub    $0xc,%esp
  801d1a:	ff 75 0c             	pushl  0xc(%ebp)
  801d1d:	ff 75 08             	pushl  0x8(%ebp)
  801d20:	56                   	push   %esi
  801d21:	50                   	push   %eax
  801d22:	68 b4 26 80 00       	push   $0x8026b4
  801d27:	e8 38 e4 ff ff       	call   800164 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d2c:	83 c4 18             	add    $0x18,%esp
  801d2f:	53                   	push   %ebx
  801d30:	ff 75 10             	pushl  0x10(%ebp)
  801d33:	e8 db e3 ff ff       	call   800113 <vcprintf>
	cprintf("\n");
  801d38:	c7 04 24 9f 26 80 00 	movl   $0x80269f,(%esp)
  801d3f:	e8 20 e4 ff ff       	call   800164 <cprintf>
  801d44:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d47:	cc                   	int3   
  801d48:	eb fd                	jmp    801d47 <_panic+0x43>

00801d4a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d4a:	55                   	push   %ebp
  801d4b:	89 e5                	mov    %esp,%ebp
  801d4d:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d50:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d57:	75 2a                	jne    801d83 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d59:	83 ec 04             	sub    $0x4,%esp
  801d5c:	6a 07                	push   $0x7
  801d5e:	68 00 f0 bf ee       	push   $0xeebff000
  801d63:	6a 00                	push   $0x0
  801d65:	e8 82 ed ff ff       	call   800aec <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801d6a:	83 c4 10             	add    $0x10,%esp
  801d6d:	85 c0                	test   %eax,%eax
  801d6f:	79 12                	jns    801d83 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801d71:	50                   	push   %eax
  801d72:	68 d8 26 80 00       	push   $0x8026d8
  801d77:	6a 23                	push   $0x23
  801d79:	68 dc 26 80 00       	push   $0x8026dc
  801d7e:	e8 81 ff ff ff       	call   801d04 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d83:	8b 45 08             	mov    0x8(%ebp),%eax
  801d86:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801d8b:	83 ec 08             	sub    $0x8,%esp
  801d8e:	68 b5 1d 80 00       	push   $0x801db5
  801d93:	6a 00                	push   $0x0
  801d95:	e8 9d ee ff ff       	call   800c37 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801d9a:	83 c4 10             	add    $0x10,%esp
  801d9d:	85 c0                	test   %eax,%eax
  801d9f:	79 12                	jns    801db3 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801da1:	50                   	push   %eax
  801da2:	68 d8 26 80 00       	push   $0x8026d8
  801da7:	6a 2c                	push   $0x2c
  801da9:	68 dc 26 80 00       	push   $0x8026dc
  801dae:	e8 51 ff ff ff       	call   801d04 <_panic>
	}
}
  801db3:	c9                   	leave  
  801db4:	c3                   	ret    

00801db5 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801db5:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801db6:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801dbb:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801dbd:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801dc0:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801dc4:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801dc9:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801dcd:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801dcf:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801dd2:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801dd3:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801dd6:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801dd7:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801dd8:	c3                   	ret    

00801dd9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801dd9:	55                   	push   %ebp
  801dda:	89 e5                	mov    %esp,%ebp
  801ddc:	56                   	push   %esi
  801ddd:	53                   	push   %ebx
  801dde:	8b 75 08             	mov    0x8(%ebp),%esi
  801de1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801de4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801de7:	85 c0                	test   %eax,%eax
  801de9:	75 12                	jne    801dfd <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801deb:	83 ec 0c             	sub    $0xc,%esp
  801dee:	68 00 00 c0 ee       	push   $0xeec00000
  801df3:	e8 a4 ee ff ff       	call   800c9c <sys_ipc_recv>
  801df8:	83 c4 10             	add    $0x10,%esp
  801dfb:	eb 0c                	jmp    801e09 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801dfd:	83 ec 0c             	sub    $0xc,%esp
  801e00:	50                   	push   %eax
  801e01:	e8 96 ee ff ff       	call   800c9c <sys_ipc_recv>
  801e06:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e09:	85 f6                	test   %esi,%esi
  801e0b:	0f 95 c1             	setne  %cl
  801e0e:	85 db                	test   %ebx,%ebx
  801e10:	0f 95 c2             	setne  %dl
  801e13:	84 d1                	test   %dl,%cl
  801e15:	74 09                	je     801e20 <ipc_recv+0x47>
  801e17:	89 c2                	mov    %eax,%edx
  801e19:	c1 ea 1f             	shr    $0x1f,%edx
  801e1c:	84 d2                	test   %dl,%dl
  801e1e:	75 2d                	jne    801e4d <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e20:	85 f6                	test   %esi,%esi
  801e22:	74 0d                	je     801e31 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e24:	a1 04 40 80 00       	mov    0x804004,%eax
  801e29:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  801e2f:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e31:	85 db                	test   %ebx,%ebx
  801e33:	74 0d                	je     801e42 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e35:	a1 04 40 80 00       	mov    0x804004,%eax
  801e3a:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  801e40:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e42:	a1 04 40 80 00       	mov    0x804004,%eax
  801e47:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  801e4d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e50:	5b                   	pop    %ebx
  801e51:	5e                   	pop    %esi
  801e52:	5d                   	pop    %ebp
  801e53:	c3                   	ret    

00801e54 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e54:	55                   	push   %ebp
  801e55:	89 e5                	mov    %esp,%ebp
  801e57:	57                   	push   %edi
  801e58:	56                   	push   %esi
  801e59:	53                   	push   %ebx
  801e5a:	83 ec 0c             	sub    $0xc,%esp
  801e5d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e60:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e63:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801e66:	85 db                	test   %ebx,%ebx
  801e68:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e6d:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e70:	ff 75 14             	pushl  0x14(%ebp)
  801e73:	53                   	push   %ebx
  801e74:	56                   	push   %esi
  801e75:	57                   	push   %edi
  801e76:	e8 fe ed ff ff       	call   800c79 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801e7b:	89 c2                	mov    %eax,%edx
  801e7d:	c1 ea 1f             	shr    $0x1f,%edx
  801e80:	83 c4 10             	add    $0x10,%esp
  801e83:	84 d2                	test   %dl,%dl
  801e85:	74 17                	je     801e9e <ipc_send+0x4a>
  801e87:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e8a:	74 12                	je     801e9e <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801e8c:	50                   	push   %eax
  801e8d:	68 ea 26 80 00       	push   $0x8026ea
  801e92:	6a 47                	push   $0x47
  801e94:	68 f8 26 80 00       	push   $0x8026f8
  801e99:	e8 66 fe ff ff       	call   801d04 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801e9e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ea1:	75 07                	jne    801eaa <ipc_send+0x56>
			sys_yield();
  801ea3:	e8 25 ec ff ff       	call   800acd <sys_yield>
  801ea8:	eb c6                	jmp    801e70 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801eaa:	85 c0                	test   %eax,%eax
  801eac:	75 c2                	jne    801e70 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801eae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eb1:	5b                   	pop    %ebx
  801eb2:	5e                   	pop    %esi
  801eb3:	5f                   	pop    %edi
  801eb4:	5d                   	pop    %ebp
  801eb5:	c3                   	ret    

00801eb6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801eb6:	55                   	push   %ebp
  801eb7:	89 e5                	mov    %esp,%ebp
  801eb9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ebc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ec1:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  801ec7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ecd:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801ed3:	39 ca                	cmp    %ecx,%edx
  801ed5:	75 10                	jne    801ee7 <ipc_find_env+0x31>
			return envs[i].env_id;
  801ed7:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  801edd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ee2:	8b 40 7c             	mov    0x7c(%eax),%eax
  801ee5:	eb 0f                	jmp    801ef6 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ee7:	83 c0 01             	add    $0x1,%eax
  801eea:	3d 00 04 00 00       	cmp    $0x400,%eax
  801eef:	75 d0                	jne    801ec1 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ef1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ef6:	5d                   	pop    %ebp
  801ef7:	c3                   	ret    

00801ef8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ef8:	55                   	push   %ebp
  801ef9:	89 e5                	mov    %esp,%ebp
  801efb:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801efe:	89 d0                	mov    %edx,%eax
  801f00:	c1 e8 16             	shr    $0x16,%eax
  801f03:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f0a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f0f:	f6 c1 01             	test   $0x1,%cl
  801f12:	74 1d                	je     801f31 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f14:	c1 ea 0c             	shr    $0xc,%edx
  801f17:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f1e:	f6 c2 01             	test   $0x1,%dl
  801f21:	74 0e                	je     801f31 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f23:	c1 ea 0c             	shr    $0xc,%edx
  801f26:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f2d:	ef 
  801f2e:	0f b7 c0             	movzwl %ax,%eax
}
  801f31:	5d                   	pop    %ebp
  801f32:	c3                   	ret    
  801f33:	66 90                	xchg   %ax,%ax
  801f35:	66 90                	xchg   %ax,%ax
  801f37:	66 90                	xchg   %ax,%ax
  801f39:	66 90                	xchg   %ax,%ax
  801f3b:	66 90                	xchg   %ax,%ax
  801f3d:	66 90                	xchg   %ax,%ax
  801f3f:	90                   	nop

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
