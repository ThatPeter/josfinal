
obj/user/faultwritekernel.debug:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0xf0100000 = 0;
  800036:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	57                   	push   %edi
  800046:	56                   	push   %esi
  800047:	53                   	push   %ebx
  800048:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80004b:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800052:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  800055:	e8 85 0a 00 00       	call   800adf <sys_getenvid>
  80005a:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  80005c:	83 ec 08             	sub    $0x8,%esp
  80005f:	50                   	push   %eax
  800060:	68 40 1e 80 00       	push   $0x801e40
  800065:	e8 2b 01 00 00       	call   800195 <cprintf>
  80006a:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  800070:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800075:	83 c4 10             	add    $0x10,%esp
  800078:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  80007d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  800082:	89 c1                	mov    %eax,%ecx
  800084:	c1 e1 07             	shl    $0x7,%ecx
  800087:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  80008e:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  800091:	39 cb                	cmp    %ecx,%ebx
  800093:	0f 44 fa             	cmove  %edx,%edi
  800096:	b9 01 00 00 00       	mov    $0x1,%ecx
  80009b:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  80009e:	83 c0 01             	add    $0x1,%eax
  8000a1:	81 c2 84 00 00 00    	add    $0x84,%edx
  8000a7:	3d 00 04 00 00       	cmp    $0x400,%eax
  8000ac:	75 d4                	jne    800082 <libmain+0x40>
  8000ae:	89 f0                	mov    %esi,%eax
  8000b0:	84 c0                	test   %al,%al
  8000b2:	74 06                	je     8000ba <libmain+0x78>
  8000b4:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ba:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000be:	7e 0a                	jle    8000ca <libmain+0x88>
		binaryname = argv[0];
  8000c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000c3:	8b 00                	mov    (%eax),%eax
  8000c5:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ca:	83 ec 08             	sub    $0x8,%esp
  8000cd:	ff 75 0c             	pushl  0xc(%ebp)
  8000d0:	ff 75 08             	pushl  0x8(%ebp)
  8000d3:	e8 5b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d8:	e8 0b 00 00 00       	call   8000e8 <exit>
}
  8000dd:	83 c4 10             	add    $0x10,%esp
  8000e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5f                   	pop    %edi
  8000e6:	5d                   	pop    %ebp
  8000e7:	c3                   	ret    

008000e8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ee:	e8 06 0e 00 00       	call   800ef9 <close_all>
	sys_env_destroy(0);
  8000f3:	83 ec 0c             	sub    $0xc,%esp
  8000f6:	6a 00                	push   $0x0
  8000f8:	e8 a1 09 00 00       	call   800a9e <sys_env_destroy>
}
  8000fd:	83 c4 10             	add    $0x10,%esp
  800100:	c9                   	leave  
  800101:	c3                   	ret    

00800102 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	53                   	push   %ebx
  800106:	83 ec 04             	sub    $0x4,%esp
  800109:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010c:	8b 13                	mov    (%ebx),%edx
  80010e:	8d 42 01             	lea    0x1(%edx),%eax
  800111:	89 03                	mov    %eax,(%ebx)
  800113:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800116:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80011a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011f:	75 1a                	jne    80013b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800121:	83 ec 08             	sub    $0x8,%esp
  800124:	68 ff 00 00 00       	push   $0xff
  800129:	8d 43 08             	lea    0x8(%ebx),%eax
  80012c:	50                   	push   %eax
  80012d:	e8 2f 09 00 00       	call   800a61 <sys_cputs>
		b->idx = 0;
  800132:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800138:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80013b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80013f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800142:	c9                   	leave  
  800143:	c3                   	ret    

00800144 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80014d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800154:	00 00 00 
	b.cnt = 0;
  800157:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800161:	ff 75 0c             	pushl  0xc(%ebp)
  800164:	ff 75 08             	pushl  0x8(%ebp)
  800167:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016d:	50                   	push   %eax
  80016e:	68 02 01 80 00       	push   $0x800102
  800173:	e8 54 01 00 00       	call   8002cc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800178:	83 c4 08             	add    $0x8,%esp
  80017b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800181:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800187:	50                   	push   %eax
  800188:	e8 d4 08 00 00       	call   800a61 <sys_cputs>

	return b.cnt;
}
  80018d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800193:	c9                   	leave  
  800194:	c3                   	ret    

00800195 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019e:	50                   	push   %eax
  80019f:	ff 75 08             	pushl  0x8(%ebp)
  8001a2:	e8 9d ff ff ff       	call   800144 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a7:	c9                   	leave  
  8001a8:	c3                   	ret    

008001a9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	57                   	push   %edi
  8001ad:	56                   	push   %esi
  8001ae:	53                   	push   %ebx
  8001af:	83 ec 1c             	sub    $0x1c,%esp
  8001b2:	89 c7                	mov    %eax,%edi
  8001b4:	89 d6                	mov    %edx,%esi
  8001b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001bf:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ca:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001cd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001d0:	39 d3                	cmp    %edx,%ebx
  8001d2:	72 05                	jb     8001d9 <printnum+0x30>
  8001d4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d7:	77 45                	ja     80021e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d9:	83 ec 0c             	sub    $0xc,%esp
  8001dc:	ff 75 18             	pushl  0x18(%ebp)
  8001df:	8b 45 14             	mov    0x14(%ebp),%eax
  8001e2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001e5:	53                   	push   %ebx
  8001e6:	ff 75 10             	pushl  0x10(%ebp)
  8001e9:	83 ec 08             	sub    $0x8,%esp
  8001ec:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f2:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f5:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f8:	e8 b3 19 00 00       	call   801bb0 <__udivdi3>
  8001fd:	83 c4 18             	add    $0x18,%esp
  800200:	52                   	push   %edx
  800201:	50                   	push   %eax
  800202:	89 f2                	mov    %esi,%edx
  800204:	89 f8                	mov    %edi,%eax
  800206:	e8 9e ff ff ff       	call   8001a9 <printnum>
  80020b:	83 c4 20             	add    $0x20,%esp
  80020e:	eb 18                	jmp    800228 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800210:	83 ec 08             	sub    $0x8,%esp
  800213:	56                   	push   %esi
  800214:	ff 75 18             	pushl  0x18(%ebp)
  800217:	ff d7                	call   *%edi
  800219:	83 c4 10             	add    $0x10,%esp
  80021c:	eb 03                	jmp    800221 <printnum+0x78>
  80021e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800221:	83 eb 01             	sub    $0x1,%ebx
  800224:	85 db                	test   %ebx,%ebx
  800226:	7f e8                	jg     800210 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800228:	83 ec 08             	sub    $0x8,%esp
  80022b:	56                   	push   %esi
  80022c:	83 ec 04             	sub    $0x4,%esp
  80022f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800232:	ff 75 e0             	pushl  -0x20(%ebp)
  800235:	ff 75 dc             	pushl  -0x24(%ebp)
  800238:	ff 75 d8             	pushl  -0x28(%ebp)
  80023b:	e8 a0 1a 00 00       	call   801ce0 <__umoddi3>
  800240:	83 c4 14             	add    $0x14,%esp
  800243:	0f be 80 69 1e 80 00 	movsbl 0x801e69(%eax),%eax
  80024a:	50                   	push   %eax
  80024b:	ff d7                	call   *%edi
}
  80024d:	83 c4 10             	add    $0x10,%esp
  800250:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800253:	5b                   	pop    %ebx
  800254:	5e                   	pop    %esi
  800255:	5f                   	pop    %edi
  800256:	5d                   	pop    %ebp
  800257:	c3                   	ret    

00800258 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800258:	55                   	push   %ebp
  800259:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80025b:	83 fa 01             	cmp    $0x1,%edx
  80025e:	7e 0e                	jle    80026e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800260:	8b 10                	mov    (%eax),%edx
  800262:	8d 4a 08             	lea    0x8(%edx),%ecx
  800265:	89 08                	mov    %ecx,(%eax)
  800267:	8b 02                	mov    (%edx),%eax
  800269:	8b 52 04             	mov    0x4(%edx),%edx
  80026c:	eb 22                	jmp    800290 <getuint+0x38>
	else if (lflag)
  80026e:	85 d2                	test   %edx,%edx
  800270:	74 10                	je     800282 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800272:	8b 10                	mov    (%eax),%edx
  800274:	8d 4a 04             	lea    0x4(%edx),%ecx
  800277:	89 08                	mov    %ecx,(%eax)
  800279:	8b 02                	mov    (%edx),%eax
  80027b:	ba 00 00 00 00       	mov    $0x0,%edx
  800280:	eb 0e                	jmp    800290 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800282:	8b 10                	mov    (%eax),%edx
  800284:	8d 4a 04             	lea    0x4(%edx),%ecx
  800287:	89 08                	mov    %ecx,(%eax)
  800289:	8b 02                	mov    (%edx),%eax
  80028b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800290:	5d                   	pop    %ebp
  800291:	c3                   	ret    

00800292 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800292:	55                   	push   %ebp
  800293:	89 e5                	mov    %esp,%ebp
  800295:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800298:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80029c:	8b 10                	mov    (%eax),%edx
  80029e:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a1:	73 0a                	jae    8002ad <sprintputch+0x1b>
		*b->buf++ = ch;
  8002a3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002a6:	89 08                	mov    %ecx,(%eax)
  8002a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ab:	88 02                	mov    %al,(%edx)
}
  8002ad:	5d                   	pop    %ebp
  8002ae:	c3                   	ret    

008002af <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b8:	50                   	push   %eax
  8002b9:	ff 75 10             	pushl  0x10(%ebp)
  8002bc:	ff 75 0c             	pushl  0xc(%ebp)
  8002bf:	ff 75 08             	pushl  0x8(%ebp)
  8002c2:	e8 05 00 00 00       	call   8002cc <vprintfmt>
	va_end(ap);
}
  8002c7:	83 c4 10             	add    $0x10,%esp
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 2c             	sub    $0x2c,%esp
  8002d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002db:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002de:	eb 12                	jmp    8002f2 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002e0:	85 c0                	test   %eax,%eax
  8002e2:	0f 84 89 03 00 00    	je     800671 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002e8:	83 ec 08             	sub    $0x8,%esp
  8002eb:	53                   	push   %ebx
  8002ec:	50                   	push   %eax
  8002ed:	ff d6                	call   *%esi
  8002ef:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f2:	83 c7 01             	add    $0x1,%edi
  8002f5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002f9:	83 f8 25             	cmp    $0x25,%eax
  8002fc:	75 e2                	jne    8002e0 <vprintfmt+0x14>
  8002fe:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800302:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800309:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800310:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800317:	ba 00 00 00 00       	mov    $0x0,%edx
  80031c:	eb 07                	jmp    800325 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800321:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800325:	8d 47 01             	lea    0x1(%edi),%eax
  800328:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80032b:	0f b6 07             	movzbl (%edi),%eax
  80032e:	0f b6 c8             	movzbl %al,%ecx
  800331:	83 e8 23             	sub    $0x23,%eax
  800334:	3c 55                	cmp    $0x55,%al
  800336:	0f 87 1a 03 00 00    	ja     800656 <vprintfmt+0x38a>
  80033c:	0f b6 c0             	movzbl %al,%eax
  80033f:	ff 24 85 a0 1f 80 00 	jmp    *0x801fa0(,%eax,4)
  800346:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800349:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80034d:	eb d6                	jmp    800325 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800352:	b8 00 00 00 00       	mov    $0x0,%eax
  800357:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80035a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80035d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800361:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800364:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800367:	83 fa 09             	cmp    $0x9,%edx
  80036a:	77 39                	ja     8003a5 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80036c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80036f:	eb e9                	jmp    80035a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800371:	8b 45 14             	mov    0x14(%ebp),%eax
  800374:	8d 48 04             	lea    0x4(%eax),%ecx
  800377:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80037a:	8b 00                	mov    (%eax),%eax
  80037c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800382:	eb 27                	jmp    8003ab <vprintfmt+0xdf>
  800384:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800387:	85 c0                	test   %eax,%eax
  800389:	b9 00 00 00 00       	mov    $0x0,%ecx
  80038e:	0f 49 c8             	cmovns %eax,%ecx
  800391:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800394:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800397:	eb 8c                	jmp    800325 <vprintfmt+0x59>
  800399:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80039c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003a3:	eb 80                	jmp    800325 <vprintfmt+0x59>
  8003a5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003a8:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003ab:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003af:	0f 89 70 ff ff ff    	jns    800325 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003b5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003b8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003bb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003c2:	e9 5e ff ff ff       	jmp    800325 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003c7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003cd:	e9 53 ff ff ff       	jmp    800325 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d5:	8d 50 04             	lea    0x4(%eax),%edx
  8003d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003db:	83 ec 08             	sub    $0x8,%esp
  8003de:	53                   	push   %ebx
  8003df:	ff 30                	pushl  (%eax)
  8003e1:	ff d6                	call   *%esi
			break;
  8003e3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003e9:	e9 04 ff ff ff       	jmp    8002f2 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f1:	8d 50 04             	lea    0x4(%eax),%edx
  8003f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f7:	8b 00                	mov    (%eax),%eax
  8003f9:	99                   	cltd   
  8003fa:	31 d0                	xor    %edx,%eax
  8003fc:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003fe:	83 f8 0f             	cmp    $0xf,%eax
  800401:	7f 0b                	jg     80040e <vprintfmt+0x142>
  800403:	8b 14 85 00 21 80 00 	mov    0x802100(,%eax,4),%edx
  80040a:	85 d2                	test   %edx,%edx
  80040c:	75 18                	jne    800426 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80040e:	50                   	push   %eax
  80040f:	68 81 1e 80 00       	push   $0x801e81
  800414:	53                   	push   %ebx
  800415:	56                   	push   %esi
  800416:	e8 94 fe ff ff       	call   8002af <printfmt>
  80041b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800421:	e9 cc fe ff ff       	jmp    8002f2 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800426:	52                   	push   %edx
  800427:	68 31 22 80 00       	push   $0x802231
  80042c:	53                   	push   %ebx
  80042d:	56                   	push   %esi
  80042e:	e8 7c fe ff ff       	call   8002af <printfmt>
  800433:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800436:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800439:	e9 b4 fe ff ff       	jmp    8002f2 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80043e:	8b 45 14             	mov    0x14(%ebp),%eax
  800441:	8d 50 04             	lea    0x4(%eax),%edx
  800444:	89 55 14             	mov    %edx,0x14(%ebp)
  800447:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800449:	85 ff                	test   %edi,%edi
  80044b:	b8 7a 1e 80 00       	mov    $0x801e7a,%eax
  800450:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800453:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800457:	0f 8e 94 00 00 00    	jle    8004f1 <vprintfmt+0x225>
  80045d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800461:	0f 84 98 00 00 00    	je     8004ff <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800467:	83 ec 08             	sub    $0x8,%esp
  80046a:	ff 75 d0             	pushl  -0x30(%ebp)
  80046d:	57                   	push   %edi
  80046e:	e8 86 02 00 00       	call   8006f9 <strnlen>
  800473:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800476:	29 c1                	sub    %eax,%ecx
  800478:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80047b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80047e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800482:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800485:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800488:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048a:	eb 0f                	jmp    80049b <vprintfmt+0x1cf>
					putch(padc, putdat);
  80048c:	83 ec 08             	sub    $0x8,%esp
  80048f:	53                   	push   %ebx
  800490:	ff 75 e0             	pushl  -0x20(%ebp)
  800493:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800495:	83 ef 01             	sub    $0x1,%edi
  800498:	83 c4 10             	add    $0x10,%esp
  80049b:	85 ff                	test   %edi,%edi
  80049d:	7f ed                	jg     80048c <vprintfmt+0x1c0>
  80049f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004a2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004a5:	85 c9                	test   %ecx,%ecx
  8004a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ac:	0f 49 c1             	cmovns %ecx,%eax
  8004af:	29 c1                	sub    %eax,%ecx
  8004b1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ba:	89 cb                	mov    %ecx,%ebx
  8004bc:	eb 4d                	jmp    80050b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004be:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004c2:	74 1b                	je     8004df <vprintfmt+0x213>
  8004c4:	0f be c0             	movsbl %al,%eax
  8004c7:	83 e8 20             	sub    $0x20,%eax
  8004ca:	83 f8 5e             	cmp    $0x5e,%eax
  8004cd:	76 10                	jbe    8004df <vprintfmt+0x213>
					putch('?', putdat);
  8004cf:	83 ec 08             	sub    $0x8,%esp
  8004d2:	ff 75 0c             	pushl  0xc(%ebp)
  8004d5:	6a 3f                	push   $0x3f
  8004d7:	ff 55 08             	call   *0x8(%ebp)
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	eb 0d                	jmp    8004ec <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004df:	83 ec 08             	sub    $0x8,%esp
  8004e2:	ff 75 0c             	pushl  0xc(%ebp)
  8004e5:	52                   	push   %edx
  8004e6:	ff 55 08             	call   *0x8(%ebp)
  8004e9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ec:	83 eb 01             	sub    $0x1,%ebx
  8004ef:	eb 1a                	jmp    80050b <vprintfmt+0x23f>
  8004f1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004fa:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004fd:	eb 0c                	jmp    80050b <vprintfmt+0x23f>
  8004ff:	89 75 08             	mov    %esi,0x8(%ebp)
  800502:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800505:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800508:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80050b:	83 c7 01             	add    $0x1,%edi
  80050e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800512:	0f be d0             	movsbl %al,%edx
  800515:	85 d2                	test   %edx,%edx
  800517:	74 23                	je     80053c <vprintfmt+0x270>
  800519:	85 f6                	test   %esi,%esi
  80051b:	78 a1                	js     8004be <vprintfmt+0x1f2>
  80051d:	83 ee 01             	sub    $0x1,%esi
  800520:	79 9c                	jns    8004be <vprintfmt+0x1f2>
  800522:	89 df                	mov    %ebx,%edi
  800524:	8b 75 08             	mov    0x8(%ebp),%esi
  800527:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80052a:	eb 18                	jmp    800544 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	53                   	push   %ebx
  800530:	6a 20                	push   $0x20
  800532:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800534:	83 ef 01             	sub    $0x1,%edi
  800537:	83 c4 10             	add    $0x10,%esp
  80053a:	eb 08                	jmp    800544 <vprintfmt+0x278>
  80053c:	89 df                	mov    %ebx,%edi
  80053e:	8b 75 08             	mov    0x8(%ebp),%esi
  800541:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800544:	85 ff                	test   %edi,%edi
  800546:	7f e4                	jg     80052c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800548:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80054b:	e9 a2 fd ff ff       	jmp    8002f2 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800550:	83 fa 01             	cmp    $0x1,%edx
  800553:	7e 16                	jle    80056b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800555:	8b 45 14             	mov    0x14(%ebp),%eax
  800558:	8d 50 08             	lea    0x8(%eax),%edx
  80055b:	89 55 14             	mov    %edx,0x14(%ebp)
  80055e:	8b 50 04             	mov    0x4(%eax),%edx
  800561:	8b 00                	mov    (%eax),%eax
  800563:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800566:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800569:	eb 32                	jmp    80059d <vprintfmt+0x2d1>
	else if (lflag)
  80056b:	85 d2                	test   %edx,%edx
  80056d:	74 18                	je     800587 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80056f:	8b 45 14             	mov    0x14(%ebp),%eax
  800572:	8d 50 04             	lea    0x4(%eax),%edx
  800575:	89 55 14             	mov    %edx,0x14(%ebp)
  800578:	8b 00                	mov    (%eax),%eax
  80057a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057d:	89 c1                	mov    %eax,%ecx
  80057f:	c1 f9 1f             	sar    $0x1f,%ecx
  800582:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800585:	eb 16                	jmp    80059d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800587:	8b 45 14             	mov    0x14(%ebp),%eax
  80058a:	8d 50 04             	lea    0x4(%eax),%edx
  80058d:	89 55 14             	mov    %edx,0x14(%ebp)
  800590:	8b 00                	mov    (%eax),%eax
  800592:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800595:	89 c1                	mov    %eax,%ecx
  800597:	c1 f9 1f             	sar    $0x1f,%ecx
  80059a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80059d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005a0:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ac:	79 74                	jns    800622 <vprintfmt+0x356>
				putch('-', putdat);
  8005ae:	83 ec 08             	sub    $0x8,%esp
  8005b1:	53                   	push   %ebx
  8005b2:	6a 2d                	push   $0x2d
  8005b4:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005bc:	f7 d8                	neg    %eax
  8005be:	83 d2 00             	adc    $0x0,%edx
  8005c1:	f7 da                	neg    %edx
  8005c3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005c6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005cb:	eb 55                	jmp    800622 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005cd:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d0:	e8 83 fc ff ff       	call   800258 <getuint>
			base = 10;
  8005d5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005da:	eb 46                	jmp    800622 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005dc:	8d 45 14             	lea    0x14(%ebp),%eax
  8005df:	e8 74 fc ff ff       	call   800258 <getuint>
			base = 8;
  8005e4:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005e9:	eb 37                	jmp    800622 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005eb:	83 ec 08             	sub    $0x8,%esp
  8005ee:	53                   	push   %ebx
  8005ef:	6a 30                	push   $0x30
  8005f1:	ff d6                	call   *%esi
			putch('x', putdat);
  8005f3:	83 c4 08             	add    $0x8,%esp
  8005f6:	53                   	push   %ebx
  8005f7:	6a 78                	push   $0x78
  8005f9:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8d 50 04             	lea    0x4(%eax),%edx
  800601:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800604:	8b 00                	mov    (%eax),%eax
  800606:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80060b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80060e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800613:	eb 0d                	jmp    800622 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800615:	8d 45 14             	lea    0x14(%ebp),%eax
  800618:	e8 3b fc ff ff       	call   800258 <getuint>
			base = 16;
  80061d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800622:	83 ec 0c             	sub    $0xc,%esp
  800625:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800629:	57                   	push   %edi
  80062a:	ff 75 e0             	pushl  -0x20(%ebp)
  80062d:	51                   	push   %ecx
  80062e:	52                   	push   %edx
  80062f:	50                   	push   %eax
  800630:	89 da                	mov    %ebx,%edx
  800632:	89 f0                	mov    %esi,%eax
  800634:	e8 70 fb ff ff       	call   8001a9 <printnum>
			break;
  800639:	83 c4 20             	add    $0x20,%esp
  80063c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80063f:	e9 ae fc ff ff       	jmp    8002f2 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800644:	83 ec 08             	sub    $0x8,%esp
  800647:	53                   	push   %ebx
  800648:	51                   	push   %ecx
  800649:	ff d6                	call   *%esi
			break;
  80064b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800651:	e9 9c fc ff ff       	jmp    8002f2 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	53                   	push   %ebx
  80065a:	6a 25                	push   $0x25
  80065c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80065e:	83 c4 10             	add    $0x10,%esp
  800661:	eb 03                	jmp    800666 <vprintfmt+0x39a>
  800663:	83 ef 01             	sub    $0x1,%edi
  800666:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80066a:	75 f7                	jne    800663 <vprintfmt+0x397>
  80066c:	e9 81 fc ff ff       	jmp    8002f2 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800671:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800674:	5b                   	pop    %ebx
  800675:	5e                   	pop    %esi
  800676:	5f                   	pop    %edi
  800677:	5d                   	pop    %ebp
  800678:	c3                   	ret    

00800679 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800679:	55                   	push   %ebp
  80067a:	89 e5                	mov    %esp,%ebp
  80067c:	83 ec 18             	sub    $0x18,%esp
  80067f:	8b 45 08             	mov    0x8(%ebp),%eax
  800682:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800685:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800688:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80068c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80068f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800696:	85 c0                	test   %eax,%eax
  800698:	74 26                	je     8006c0 <vsnprintf+0x47>
  80069a:	85 d2                	test   %edx,%edx
  80069c:	7e 22                	jle    8006c0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80069e:	ff 75 14             	pushl  0x14(%ebp)
  8006a1:	ff 75 10             	pushl  0x10(%ebp)
  8006a4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006a7:	50                   	push   %eax
  8006a8:	68 92 02 80 00       	push   $0x800292
  8006ad:	e8 1a fc ff ff       	call   8002cc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006b5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006bb:	83 c4 10             	add    $0x10,%esp
  8006be:	eb 05                	jmp    8006c5 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006c5:	c9                   	leave  
  8006c6:	c3                   	ret    

008006c7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006c7:	55                   	push   %ebp
  8006c8:	89 e5                	mov    %esp,%ebp
  8006ca:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006cd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006d0:	50                   	push   %eax
  8006d1:	ff 75 10             	pushl  0x10(%ebp)
  8006d4:	ff 75 0c             	pushl  0xc(%ebp)
  8006d7:	ff 75 08             	pushl  0x8(%ebp)
  8006da:	e8 9a ff ff ff       	call   800679 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006df:	c9                   	leave  
  8006e0:	c3                   	ret    

008006e1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e1:	55                   	push   %ebp
  8006e2:	89 e5                	mov    %esp,%ebp
  8006e4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ec:	eb 03                	jmp    8006f1 <strlen+0x10>
		n++;
  8006ee:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006f5:	75 f7                	jne    8006ee <strlen+0xd>
		n++;
	return n;
}
  8006f7:	5d                   	pop    %ebp
  8006f8:	c3                   	ret    

008006f9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f9:	55                   	push   %ebp
  8006fa:	89 e5                	mov    %esp,%ebp
  8006fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006ff:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800702:	ba 00 00 00 00       	mov    $0x0,%edx
  800707:	eb 03                	jmp    80070c <strnlen+0x13>
		n++;
  800709:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070c:	39 c2                	cmp    %eax,%edx
  80070e:	74 08                	je     800718 <strnlen+0x1f>
  800710:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800714:	75 f3                	jne    800709 <strnlen+0x10>
  800716:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800718:	5d                   	pop    %ebp
  800719:	c3                   	ret    

0080071a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80071a:	55                   	push   %ebp
  80071b:	89 e5                	mov    %esp,%ebp
  80071d:	53                   	push   %ebx
  80071e:	8b 45 08             	mov    0x8(%ebp),%eax
  800721:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800724:	89 c2                	mov    %eax,%edx
  800726:	83 c2 01             	add    $0x1,%edx
  800729:	83 c1 01             	add    $0x1,%ecx
  80072c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800730:	88 5a ff             	mov    %bl,-0x1(%edx)
  800733:	84 db                	test   %bl,%bl
  800735:	75 ef                	jne    800726 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800737:	5b                   	pop    %ebx
  800738:	5d                   	pop    %ebp
  800739:	c3                   	ret    

0080073a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	53                   	push   %ebx
  80073e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800741:	53                   	push   %ebx
  800742:	e8 9a ff ff ff       	call   8006e1 <strlen>
  800747:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80074a:	ff 75 0c             	pushl  0xc(%ebp)
  80074d:	01 d8                	add    %ebx,%eax
  80074f:	50                   	push   %eax
  800750:	e8 c5 ff ff ff       	call   80071a <strcpy>
	return dst;
}
  800755:	89 d8                	mov    %ebx,%eax
  800757:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80075a:	c9                   	leave  
  80075b:	c3                   	ret    

0080075c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	56                   	push   %esi
  800760:	53                   	push   %ebx
  800761:	8b 75 08             	mov    0x8(%ebp),%esi
  800764:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800767:	89 f3                	mov    %esi,%ebx
  800769:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80076c:	89 f2                	mov    %esi,%edx
  80076e:	eb 0f                	jmp    80077f <strncpy+0x23>
		*dst++ = *src;
  800770:	83 c2 01             	add    $0x1,%edx
  800773:	0f b6 01             	movzbl (%ecx),%eax
  800776:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800779:	80 39 01             	cmpb   $0x1,(%ecx)
  80077c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80077f:	39 da                	cmp    %ebx,%edx
  800781:	75 ed                	jne    800770 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800783:	89 f0                	mov    %esi,%eax
  800785:	5b                   	pop    %ebx
  800786:	5e                   	pop    %esi
  800787:	5d                   	pop    %ebp
  800788:	c3                   	ret    

00800789 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800789:	55                   	push   %ebp
  80078a:	89 e5                	mov    %esp,%ebp
  80078c:	56                   	push   %esi
  80078d:	53                   	push   %ebx
  80078e:	8b 75 08             	mov    0x8(%ebp),%esi
  800791:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800794:	8b 55 10             	mov    0x10(%ebp),%edx
  800797:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800799:	85 d2                	test   %edx,%edx
  80079b:	74 21                	je     8007be <strlcpy+0x35>
  80079d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007a1:	89 f2                	mov    %esi,%edx
  8007a3:	eb 09                	jmp    8007ae <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007a5:	83 c2 01             	add    $0x1,%edx
  8007a8:	83 c1 01             	add    $0x1,%ecx
  8007ab:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ae:	39 c2                	cmp    %eax,%edx
  8007b0:	74 09                	je     8007bb <strlcpy+0x32>
  8007b2:	0f b6 19             	movzbl (%ecx),%ebx
  8007b5:	84 db                	test   %bl,%bl
  8007b7:	75 ec                	jne    8007a5 <strlcpy+0x1c>
  8007b9:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007bb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007be:	29 f0                	sub    %esi,%eax
}
  8007c0:	5b                   	pop    %ebx
  8007c1:	5e                   	pop    %esi
  8007c2:	5d                   	pop    %ebp
  8007c3:	c3                   	ret    

008007c4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ca:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007cd:	eb 06                	jmp    8007d5 <strcmp+0x11>
		p++, q++;
  8007cf:	83 c1 01             	add    $0x1,%ecx
  8007d2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007d5:	0f b6 01             	movzbl (%ecx),%eax
  8007d8:	84 c0                	test   %al,%al
  8007da:	74 04                	je     8007e0 <strcmp+0x1c>
  8007dc:	3a 02                	cmp    (%edx),%al
  8007de:	74 ef                	je     8007cf <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007e0:	0f b6 c0             	movzbl %al,%eax
  8007e3:	0f b6 12             	movzbl (%edx),%edx
  8007e6:	29 d0                	sub    %edx,%eax
}
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	53                   	push   %ebx
  8007ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f4:	89 c3                	mov    %eax,%ebx
  8007f6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007f9:	eb 06                	jmp    800801 <strncmp+0x17>
		n--, p++, q++;
  8007fb:	83 c0 01             	add    $0x1,%eax
  8007fe:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800801:	39 d8                	cmp    %ebx,%eax
  800803:	74 15                	je     80081a <strncmp+0x30>
  800805:	0f b6 08             	movzbl (%eax),%ecx
  800808:	84 c9                	test   %cl,%cl
  80080a:	74 04                	je     800810 <strncmp+0x26>
  80080c:	3a 0a                	cmp    (%edx),%cl
  80080e:	74 eb                	je     8007fb <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800810:	0f b6 00             	movzbl (%eax),%eax
  800813:	0f b6 12             	movzbl (%edx),%edx
  800816:	29 d0                	sub    %edx,%eax
  800818:	eb 05                	jmp    80081f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80081a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80081f:	5b                   	pop    %ebx
  800820:	5d                   	pop    %ebp
  800821:	c3                   	ret    

00800822 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	8b 45 08             	mov    0x8(%ebp),%eax
  800828:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80082c:	eb 07                	jmp    800835 <strchr+0x13>
		if (*s == c)
  80082e:	38 ca                	cmp    %cl,%dl
  800830:	74 0f                	je     800841 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800832:	83 c0 01             	add    $0x1,%eax
  800835:	0f b6 10             	movzbl (%eax),%edx
  800838:	84 d2                	test   %dl,%dl
  80083a:	75 f2                	jne    80082e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80083c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	8b 45 08             	mov    0x8(%ebp),%eax
  800849:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084d:	eb 03                	jmp    800852 <strfind+0xf>
  80084f:	83 c0 01             	add    $0x1,%eax
  800852:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800855:	38 ca                	cmp    %cl,%dl
  800857:	74 04                	je     80085d <strfind+0x1a>
  800859:	84 d2                	test   %dl,%dl
  80085b:	75 f2                	jne    80084f <strfind+0xc>
			break;
	return (char *) s;
}
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	57                   	push   %edi
  800863:	56                   	push   %esi
  800864:	53                   	push   %ebx
  800865:	8b 7d 08             	mov    0x8(%ebp),%edi
  800868:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80086b:	85 c9                	test   %ecx,%ecx
  80086d:	74 36                	je     8008a5 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80086f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800875:	75 28                	jne    80089f <memset+0x40>
  800877:	f6 c1 03             	test   $0x3,%cl
  80087a:	75 23                	jne    80089f <memset+0x40>
		c &= 0xFF;
  80087c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800880:	89 d3                	mov    %edx,%ebx
  800882:	c1 e3 08             	shl    $0x8,%ebx
  800885:	89 d6                	mov    %edx,%esi
  800887:	c1 e6 18             	shl    $0x18,%esi
  80088a:	89 d0                	mov    %edx,%eax
  80088c:	c1 e0 10             	shl    $0x10,%eax
  80088f:	09 f0                	or     %esi,%eax
  800891:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800893:	89 d8                	mov    %ebx,%eax
  800895:	09 d0                	or     %edx,%eax
  800897:	c1 e9 02             	shr    $0x2,%ecx
  80089a:	fc                   	cld    
  80089b:	f3 ab                	rep stos %eax,%es:(%edi)
  80089d:	eb 06                	jmp    8008a5 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80089f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a2:	fc                   	cld    
  8008a3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008a5:	89 f8                	mov    %edi,%eax
  8008a7:	5b                   	pop    %ebx
  8008a8:	5e                   	pop    %esi
  8008a9:	5f                   	pop    %edi
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    

008008ac <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	57                   	push   %edi
  8008b0:	56                   	push   %esi
  8008b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008ba:	39 c6                	cmp    %eax,%esi
  8008bc:	73 35                	jae    8008f3 <memmove+0x47>
  8008be:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008c1:	39 d0                	cmp    %edx,%eax
  8008c3:	73 2e                	jae    8008f3 <memmove+0x47>
		s += n;
		d += n;
  8008c5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c8:	89 d6                	mov    %edx,%esi
  8008ca:	09 fe                	or     %edi,%esi
  8008cc:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008d2:	75 13                	jne    8008e7 <memmove+0x3b>
  8008d4:	f6 c1 03             	test   $0x3,%cl
  8008d7:	75 0e                	jne    8008e7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008d9:	83 ef 04             	sub    $0x4,%edi
  8008dc:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008df:	c1 e9 02             	shr    $0x2,%ecx
  8008e2:	fd                   	std    
  8008e3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e5:	eb 09                	jmp    8008f0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008e7:	83 ef 01             	sub    $0x1,%edi
  8008ea:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008ed:	fd                   	std    
  8008ee:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008f0:	fc                   	cld    
  8008f1:	eb 1d                	jmp    800910 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f3:	89 f2                	mov    %esi,%edx
  8008f5:	09 c2                	or     %eax,%edx
  8008f7:	f6 c2 03             	test   $0x3,%dl
  8008fa:	75 0f                	jne    80090b <memmove+0x5f>
  8008fc:	f6 c1 03             	test   $0x3,%cl
  8008ff:	75 0a                	jne    80090b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800901:	c1 e9 02             	shr    $0x2,%ecx
  800904:	89 c7                	mov    %eax,%edi
  800906:	fc                   	cld    
  800907:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800909:	eb 05                	jmp    800910 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80090b:	89 c7                	mov    %eax,%edi
  80090d:	fc                   	cld    
  80090e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800910:	5e                   	pop    %esi
  800911:	5f                   	pop    %edi
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800917:	ff 75 10             	pushl  0x10(%ebp)
  80091a:	ff 75 0c             	pushl  0xc(%ebp)
  80091d:	ff 75 08             	pushl  0x8(%ebp)
  800920:	e8 87 ff ff ff       	call   8008ac <memmove>
}
  800925:	c9                   	leave  
  800926:	c3                   	ret    

00800927 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	56                   	push   %esi
  80092b:	53                   	push   %ebx
  80092c:	8b 45 08             	mov    0x8(%ebp),%eax
  80092f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800932:	89 c6                	mov    %eax,%esi
  800934:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800937:	eb 1a                	jmp    800953 <memcmp+0x2c>
		if (*s1 != *s2)
  800939:	0f b6 08             	movzbl (%eax),%ecx
  80093c:	0f b6 1a             	movzbl (%edx),%ebx
  80093f:	38 d9                	cmp    %bl,%cl
  800941:	74 0a                	je     80094d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800943:	0f b6 c1             	movzbl %cl,%eax
  800946:	0f b6 db             	movzbl %bl,%ebx
  800949:	29 d8                	sub    %ebx,%eax
  80094b:	eb 0f                	jmp    80095c <memcmp+0x35>
		s1++, s2++;
  80094d:	83 c0 01             	add    $0x1,%eax
  800950:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800953:	39 f0                	cmp    %esi,%eax
  800955:	75 e2                	jne    800939 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800957:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095c:	5b                   	pop    %ebx
  80095d:	5e                   	pop    %esi
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	53                   	push   %ebx
  800964:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800967:	89 c1                	mov    %eax,%ecx
  800969:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80096c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800970:	eb 0a                	jmp    80097c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800972:	0f b6 10             	movzbl (%eax),%edx
  800975:	39 da                	cmp    %ebx,%edx
  800977:	74 07                	je     800980 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800979:	83 c0 01             	add    $0x1,%eax
  80097c:	39 c8                	cmp    %ecx,%eax
  80097e:	72 f2                	jb     800972 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800980:	5b                   	pop    %ebx
  800981:	5d                   	pop    %ebp
  800982:	c3                   	ret    

00800983 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	57                   	push   %edi
  800987:	56                   	push   %esi
  800988:	53                   	push   %ebx
  800989:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80098f:	eb 03                	jmp    800994 <strtol+0x11>
		s++;
  800991:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800994:	0f b6 01             	movzbl (%ecx),%eax
  800997:	3c 20                	cmp    $0x20,%al
  800999:	74 f6                	je     800991 <strtol+0xe>
  80099b:	3c 09                	cmp    $0x9,%al
  80099d:	74 f2                	je     800991 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80099f:	3c 2b                	cmp    $0x2b,%al
  8009a1:	75 0a                	jne    8009ad <strtol+0x2a>
		s++;
  8009a3:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009a6:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ab:	eb 11                	jmp    8009be <strtol+0x3b>
  8009ad:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009b2:	3c 2d                	cmp    $0x2d,%al
  8009b4:	75 08                	jne    8009be <strtol+0x3b>
		s++, neg = 1;
  8009b6:	83 c1 01             	add    $0x1,%ecx
  8009b9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009be:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009c4:	75 15                	jne    8009db <strtol+0x58>
  8009c6:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c9:	75 10                	jne    8009db <strtol+0x58>
  8009cb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009cf:	75 7c                	jne    800a4d <strtol+0xca>
		s += 2, base = 16;
  8009d1:	83 c1 02             	add    $0x2,%ecx
  8009d4:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009d9:	eb 16                	jmp    8009f1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009db:	85 db                	test   %ebx,%ebx
  8009dd:	75 12                	jne    8009f1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009df:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009e4:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e7:	75 08                	jne    8009f1 <strtol+0x6e>
		s++, base = 8;
  8009e9:	83 c1 01             	add    $0x1,%ecx
  8009ec:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009f9:	0f b6 11             	movzbl (%ecx),%edx
  8009fc:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009ff:	89 f3                	mov    %esi,%ebx
  800a01:	80 fb 09             	cmp    $0x9,%bl
  800a04:	77 08                	ja     800a0e <strtol+0x8b>
			dig = *s - '0';
  800a06:	0f be d2             	movsbl %dl,%edx
  800a09:	83 ea 30             	sub    $0x30,%edx
  800a0c:	eb 22                	jmp    800a30 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a0e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a11:	89 f3                	mov    %esi,%ebx
  800a13:	80 fb 19             	cmp    $0x19,%bl
  800a16:	77 08                	ja     800a20 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a18:	0f be d2             	movsbl %dl,%edx
  800a1b:	83 ea 57             	sub    $0x57,%edx
  800a1e:	eb 10                	jmp    800a30 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a20:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a23:	89 f3                	mov    %esi,%ebx
  800a25:	80 fb 19             	cmp    $0x19,%bl
  800a28:	77 16                	ja     800a40 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a2a:	0f be d2             	movsbl %dl,%edx
  800a2d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a30:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a33:	7d 0b                	jge    800a40 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a35:	83 c1 01             	add    $0x1,%ecx
  800a38:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a3c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a3e:	eb b9                	jmp    8009f9 <strtol+0x76>

	if (endptr)
  800a40:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a44:	74 0d                	je     800a53 <strtol+0xd0>
		*endptr = (char *) s;
  800a46:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a49:	89 0e                	mov    %ecx,(%esi)
  800a4b:	eb 06                	jmp    800a53 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4d:	85 db                	test   %ebx,%ebx
  800a4f:	74 98                	je     8009e9 <strtol+0x66>
  800a51:	eb 9e                	jmp    8009f1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a53:	89 c2                	mov    %eax,%edx
  800a55:	f7 da                	neg    %edx
  800a57:	85 ff                	test   %edi,%edi
  800a59:	0f 45 c2             	cmovne %edx,%eax
}
  800a5c:	5b                   	pop    %ebx
  800a5d:	5e                   	pop    %esi
  800a5e:	5f                   	pop    %edi
  800a5f:	5d                   	pop    %ebp
  800a60:	c3                   	ret    

00800a61 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800a67:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a72:	89 c3                	mov    %eax,%ebx
  800a74:	89 c7                	mov    %eax,%edi
  800a76:	89 c6                	mov    %eax,%esi
  800a78:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a7a:	5b                   	pop    %ebx
  800a7b:	5e                   	pop    %esi
  800a7c:	5f                   	pop    %edi
  800a7d:	5d                   	pop    %ebp
  800a7e:	c3                   	ret    

00800a7f <sys_cgetc>:

int
sys_cgetc(void)
{
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	57                   	push   %edi
  800a83:	56                   	push   %esi
  800a84:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a85:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8a:	b8 01 00 00 00       	mov    $0x1,%eax
  800a8f:	89 d1                	mov    %edx,%ecx
  800a91:	89 d3                	mov    %edx,%ebx
  800a93:	89 d7                	mov    %edx,%edi
  800a95:	89 d6                	mov    %edx,%esi
  800a97:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a99:	5b                   	pop    %ebx
  800a9a:	5e                   	pop    %esi
  800a9b:	5f                   	pop    %edi
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	57                   	push   %edi
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
  800aa4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aac:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab4:	89 cb                	mov    %ecx,%ebx
  800ab6:	89 cf                	mov    %ecx,%edi
  800ab8:	89 ce                	mov    %ecx,%esi
  800aba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800abc:	85 c0                	test   %eax,%eax
  800abe:	7e 17                	jle    800ad7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ac0:	83 ec 0c             	sub    $0xc,%esp
  800ac3:	50                   	push   %eax
  800ac4:	6a 03                	push   $0x3
  800ac6:	68 5f 21 80 00       	push   $0x80215f
  800acb:	6a 23                	push   $0x23
  800acd:	68 7c 21 80 00       	push   $0x80217c
  800ad2:	e8 41 0f 00 00       	call   801a18 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ad7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ada:	5b                   	pop    %ebx
  800adb:	5e                   	pop    %esi
  800adc:	5f                   	pop    %edi
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	57                   	push   %edi
  800ae3:	56                   	push   %esi
  800ae4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aea:	b8 02 00 00 00       	mov    $0x2,%eax
  800aef:	89 d1                	mov    %edx,%ecx
  800af1:	89 d3                	mov    %edx,%ebx
  800af3:	89 d7                	mov    %edx,%edi
  800af5:	89 d6                	mov    %edx,%esi
  800af7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5f                   	pop    %edi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <sys_yield>:

void
sys_yield(void)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	57                   	push   %edi
  800b02:	56                   	push   %esi
  800b03:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b04:	ba 00 00 00 00       	mov    $0x0,%edx
  800b09:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b0e:	89 d1                	mov    %edx,%ecx
  800b10:	89 d3                	mov    %edx,%ebx
  800b12:	89 d7                	mov    %edx,%edi
  800b14:	89 d6                	mov    %edx,%esi
  800b16:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b18:	5b                   	pop    %ebx
  800b19:	5e                   	pop    %esi
  800b1a:	5f                   	pop    %edi
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    

00800b1d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	53                   	push   %ebx
  800b23:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b26:	be 00 00 00 00       	mov    $0x0,%esi
  800b2b:	b8 04 00 00 00       	mov    $0x4,%eax
  800b30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b33:	8b 55 08             	mov    0x8(%ebp),%edx
  800b36:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b39:	89 f7                	mov    %esi,%edi
  800b3b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b3d:	85 c0                	test   %eax,%eax
  800b3f:	7e 17                	jle    800b58 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b41:	83 ec 0c             	sub    $0xc,%esp
  800b44:	50                   	push   %eax
  800b45:	6a 04                	push   $0x4
  800b47:	68 5f 21 80 00       	push   $0x80215f
  800b4c:	6a 23                	push   $0x23
  800b4e:	68 7c 21 80 00       	push   $0x80217c
  800b53:	e8 c0 0e 00 00       	call   801a18 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5b:	5b                   	pop    %ebx
  800b5c:	5e                   	pop    %esi
  800b5d:	5f                   	pop    %edi
  800b5e:	5d                   	pop    %ebp
  800b5f:	c3                   	ret    

00800b60 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	57                   	push   %edi
  800b64:	56                   	push   %esi
  800b65:	53                   	push   %ebx
  800b66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b69:	b8 05 00 00 00       	mov    $0x5,%eax
  800b6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b71:	8b 55 08             	mov    0x8(%ebp),%edx
  800b74:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b77:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b7a:	8b 75 18             	mov    0x18(%ebp),%esi
  800b7d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b7f:	85 c0                	test   %eax,%eax
  800b81:	7e 17                	jle    800b9a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b83:	83 ec 0c             	sub    $0xc,%esp
  800b86:	50                   	push   %eax
  800b87:	6a 05                	push   $0x5
  800b89:	68 5f 21 80 00       	push   $0x80215f
  800b8e:	6a 23                	push   $0x23
  800b90:	68 7c 21 80 00       	push   $0x80217c
  800b95:	e8 7e 0e 00 00       	call   801a18 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9d:	5b                   	pop    %ebx
  800b9e:	5e                   	pop    %esi
  800b9f:	5f                   	pop    %edi
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
  800ba8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb0:	b8 06 00 00 00       	mov    $0x6,%eax
  800bb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbb:	89 df                	mov    %ebx,%edi
  800bbd:	89 de                	mov    %ebx,%esi
  800bbf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc1:	85 c0                	test   %eax,%eax
  800bc3:	7e 17                	jle    800bdc <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc5:	83 ec 0c             	sub    $0xc,%esp
  800bc8:	50                   	push   %eax
  800bc9:	6a 06                	push   $0x6
  800bcb:	68 5f 21 80 00       	push   $0x80215f
  800bd0:	6a 23                	push   $0x23
  800bd2:	68 7c 21 80 00       	push   $0x80217c
  800bd7:	e8 3c 0e 00 00       	call   801a18 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdf:	5b                   	pop    %ebx
  800be0:	5e                   	pop    %esi
  800be1:	5f                   	pop    %edi
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	57                   	push   %edi
  800be8:	56                   	push   %esi
  800be9:	53                   	push   %ebx
  800bea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bed:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf2:	b8 08 00 00 00       	mov    $0x8,%eax
  800bf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfd:	89 df                	mov    %ebx,%edi
  800bff:	89 de                	mov    %ebx,%esi
  800c01:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c03:	85 c0                	test   %eax,%eax
  800c05:	7e 17                	jle    800c1e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c07:	83 ec 0c             	sub    $0xc,%esp
  800c0a:	50                   	push   %eax
  800c0b:	6a 08                	push   $0x8
  800c0d:	68 5f 21 80 00       	push   $0x80215f
  800c12:	6a 23                	push   $0x23
  800c14:	68 7c 21 80 00       	push   $0x80217c
  800c19:	e8 fa 0d 00 00       	call   801a18 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
  800c2c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c34:	b8 09 00 00 00       	mov    $0x9,%eax
  800c39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3f:	89 df                	mov    %ebx,%edi
  800c41:	89 de                	mov    %ebx,%esi
  800c43:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c45:	85 c0                	test   %eax,%eax
  800c47:	7e 17                	jle    800c60 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c49:	83 ec 0c             	sub    $0xc,%esp
  800c4c:	50                   	push   %eax
  800c4d:	6a 09                	push   $0x9
  800c4f:	68 5f 21 80 00       	push   $0x80215f
  800c54:	6a 23                	push   $0x23
  800c56:	68 7c 21 80 00       	push   $0x80217c
  800c5b:	e8 b8 0d 00 00       	call   801a18 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c63:	5b                   	pop    %ebx
  800c64:	5e                   	pop    %esi
  800c65:	5f                   	pop    %edi
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	57                   	push   %edi
  800c6c:	56                   	push   %esi
  800c6d:	53                   	push   %ebx
  800c6e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c71:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c76:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c81:	89 df                	mov    %ebx,%edi
  800c83:	89 de                	mov    %ebx,%esi
  800c85:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c87:	85 c0                	test   %eax,%eax
  800c89:	7e 17                	jle    800ca2 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8b:	83 ec 0c             	sub    $0xc,%esp
  800c8e:	50                   	push   %eax
  800c8f:	6a 0a                	push   $0xa
  800c91:	68 5f 21 80 00       	push   $0x80215f
  800c96:	6a 23                	push   $0x23
  800c98:	68 7c 21 80 00       	push   $0x80217c
  800c9d:	e8 76 0d 00 00       	call   801a18 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ca2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    

00800caa <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	57                   	push   %edi
  800cae:	56                   	push   %esi
  800caf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb0:	be 00 00 00 00       	mov    $0x0,%esi
  800cb5:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc6:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cc8:	5b                   	pop    %ebx
  800cc9:	5e                   	pop    %esi
  800cca:	5f                   	pop    %edi
  800ccb:	5d                   	pop    %ebp
  800ccc:	c3                   	ret    

00800ccd <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	57                   	push   %edi
  800cd1:	56                   	push   %esi
  800cd2:	53                   	push   %ebx
  800cd3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cdb:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ce0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce3:	89 cb                	mov    %ecx,%ebx
  800ce5:	89 cf                	mov    %ecx,%edi
  800ce7:	89 ce                	mov    %ecx,%esi
  800ce9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ceb:	85 c0                	test   %eax,%eax
  800ced:	7e 17                	jle    800d06 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cef:	83 ec 0c             	sub    $0xc,%esp
  800cf2:	50                   	push   %eax
  800cf3:	6a 0d                	push   $0xd
  800cf5:	68 5f 21 80 00       	push   $0x80215f
  800cfa:	6a 23                	push   $0x23
  800cfc:	68 7c 21 80 00       	push   $0x80217c
  800d01:	e8 12 0d 00 00       	call   801a18 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d09:	5b                   	pop    %ebx
  800d0a:	5e                   	pop    %esi
  800d0b:	5f                   	pop    %edi
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    

00800d0e <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
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
  800d19:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d21:	89 cb                	mov    %ecx,%ebx
  800d23:	89 cf                	mov    %ecx,%edi
  800d25:	89 ce                	mov    %ecx,%esi
  800d27:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d29:	5b                   	pop    %ebx
  800d2a:	5e                   	pop    %esi
  800d2b:	5f                   	pop    %edi
  800d2c:	5d                   	pop    %ebp
  800d2d:	c3                   	ret    

00800d2e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d31:	8b 45 08             	mov    0x8(%ebp),%eax
  800d34:	05 00 00 00 30       	add    $0x30000000,%eax
  800d39:	c1 e8 0c             	shr    $0xc,%eax
}
  800d3c:	5d                   	pop    %ebp
  800d3d:	c3                   	ret    

00800d3e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d3e:	55                   	push   %ebp
  800d3f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d41:	8b 45 08             	mov    0x8(%ebp),%eax
  800d44:	05 00 00 00 30       	add    $0x30000000,%eax
  800d49:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d4e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    

00800d55 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d5b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d60:	89 c2                	mov    %eax,%edx
  800d62:	c1 ea 16             	shr    $0x16,%edx
  800d65:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d6c:	f6 c2 01             	test   $0x1,%dl
  800d6f:	74 11                	je     800d82 <fd_alloc+0x2d>
  800d71:	89 c2                	mov    %eax,%edx
  800d73:	c1 ea 0c             	shr    $0xc,%edx
  800d76:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d7d:	f6 c2 01             	test   $0x1,%dl
  800d80:	75 09                	jne    800d8b <fd_alloc+0x36>
			*fd_store = fd;
  800d82:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d84:	b8 00 00 00 00       	mov    $0x0,%eax
  800d89:	eb 17                	jmp    800da2 <fd_alloc+0x4d>
  800d8b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d90:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d95:	75 c9                	jne    800d60 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d97:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d9d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    

00800da4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800daa:	83 f8 1f             	cmp    $0x1f,%eax
  800dad:	77 36                	ja     800de5 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800daf:	c1 e0 0c             	shl    $0xc,%eax
  800db2:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800db7:	89 c2                	mov    %eax,%edx
  800db9:	c1 ea 16             	shr    $0x16,%edx
  800dbc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dc3:	f6 c2 01             	test   $0x1,%dl
  800dc6:	74 24                	je     800dec <fd_lookup+0x48>
  800dc8:	89 c2                	mov    %eax,%edx
  800dca:	c1 ea 0c             	shr    $0xc,%edx
  800dcd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dd4:	f6 c2 01             	test   $0x1,%dl
  800dd7:	74 1a                	je     800df3 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800dd9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ddc:	89 02                	mov    %eax,(%edx)
	return 0;
  800dde:	b8 00 00 00 00       	mov    $0x0,%eax
  800de3:	eb 13                	jmp    800df8 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800de5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dea:	eb 0c                	jmp    800df8 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800df1:	eb 05                	jmp    800df8 <fd_lookup+0x54>
  800df3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800df8:	5d                   	pop    %ebp
  800df9:	c3                   	ret    

00800dfa <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800dfa:	55                   	push   %ebp
  800dfb:	89 e5                	mov    %esp,%ebp
  800dfd:	83 ec 08             	sub    $0x8,%esp
  800e00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e03:	ba 08 22 80 00       	mov    $0x802208,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e08:	eb 13                	jmp    800e1d <dev_lookup+0x23>
  800e0a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e0d:	39 08                	cmp    %ecx,(%eax)
  800e0f:	75 0c                	jne    800e1d <dev_lookup+0x23>
			*dev = devtab[i];
  800e11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e14:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e16:	b8 00 00 00 00       	mov    $0x0,%eax
  800e1b:	eb 2e                	jmp    800e4b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e1d:	8b 02                	mov    (%edx),%eax
  800e1f:	85 c0                	test   %eax,%eax
  800e21:	75 e7                	jne    800e0a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e23:	a1 04 40 80 00       	mov    0x804004,%eax
  800e28:	8b 40 50             	mov    0x50(%eax),%eax
  800e2b:	83 ec 04             	sub    $0x4,%esp
  800e2e:	51                   	push   %ecx
  800e2f:	50                   	push   %eax
  800e30:	68 8c 21 80 00       	push   $0x80218c
  800e35:	e8 5b f3 ff ff       	call   800195 <cprintf>
	*dev = 0;
  800e3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e3d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e43:	83 c4 10             	add    $0x10,%esp
  800e46:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e4b:	c9                   	leave  
  800e4c:	c3                   	ret    

00800e4d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	56                   	push   %esi
  800e51:	53                   	push   %ebx
  800e52:	83 ec 10             	sub    $0x10,%esp
  800e55:	8b 75 08             	mov    0x8(%ebp),%esi
  800e58:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e5e:	50                   	push   %eax
  800e5f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e65:	c1 e8 0c             	shr    $0xc,%eax
  800e68:	50                   	push   %eax
  800e69:	e8 36 ff ff ff       	call   800da4 <fd_lookup>
  800e6e:	83 c4 08             	add    $0x8,%esp
  800e71:	85 c0                	test   %eax,%eax
  800e73:	78 05                	js     800e7a <fd_close+0x2d>
	    || fd != fd2)
  800e75:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e78:	74 0c                	je     800e86 <fd_close+0x39>
		return (must_exist ? r : 0);
  800e7a:	84 db                	test   %bl,%bl
  800e7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800e81:	0f 44 c2             	cmove  %edx,%eax
  800e84:	eb 41                	jmp    800ec7 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e86:	83 ec 08             	sub    $0x8,%esp
  800e89:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e8c:	50                   	push   %eax
  800e8d:	ff 36                	pushl  (%esi)
  800e8f:	e8 66 ff ff ff       	call   800dfa <dev_lookup>
  800e94:	89 c3                	mov    %eax,%ebx
  800e96:	83 c4 10             	add    $0x10,%esp
  800e99:	85 c0                	test   %eax,%eax
  800e9b:	78 1a                	js     800eb7 <fd_close+0x6a>
		if (dev->dev_close)
  800e9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ea0:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ea3:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ea8:	85 c0                	test   %eax,%eax
  800eaa:	74 0b                	je     800eb7 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800eac:	83 ec 0c             	sub    $0xc,%esp
  800eaf:	56                   	push   %esi
  800eb0:	ff d0                	call   *%eax
  800eb2:	89 c3                	mov    %eax,%ebx
  800eb4:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800eb7:	83 ec 08             	sub    $0x8,%esp
  800eba:	56                   	push   %esi
  800ebb:	6a 00                	push   $0x0
  800ebd:	e8 e0 fc ff ff       	call   800ba2 <sys_page_unmap>
	return r;
  800ec2:	83 c4 10             	add    $0x10,%esp
  800ec5:	89 d8                	mov    %ebx,%eax
}
  800ec7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eca:	5b                   	pop    %ebx
  800ecb:	5e                   	pop    %esi
  800ecc:	5d                   	pop    %ebp
  800ecd:	c3                   	ret    

00800ece <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ece:	55                   	push   %ebp
  800ecf:	89 e5                	mov    %esp,%ebp
  800ed1:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ed4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ed7:	50                   	push   %eax
  800ed8:	ff 75 08             	pushl  0x8(%ebp)
  800edb:	e8 c4 fe ff ff       	call   800da4 <fd_lookup>
  800ee0:	83 c4 08             	add    $0x8,%esp
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	78 10                	js     800ef7 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ee7:	83 ec 08             	sub    $0x8,%esp
  800eea:	6a 01                	push   $0x1
  800eec:	ff 75 f4             	pushl  -0xc(%ebp)
  800eef:	e8 59 ff ff ff       	call   800e4d <fd_close>
  800ef4:	83 c4 10             	add    $0x10,%esp
}
  800ef7:	c9                   	leave  
  800ef8:	c3                   	ret    

00800ef9 <close_all>:

void
close_all(void)
{
  800ef9:	55                   	push   %ebp
  800efa:	89 e5                	mov    %esp,%ebp
  800efc:	53                   	push   %ebx
  800efd:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f00:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f05:	83 ec 0c             	sub    $0xc,%esp
  800f08:	53                   	push   %ebx
  800f09:	e8 c0 ff ff ff       	call   800ece <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f0e:	83 c3 01             	add    $0x1,%ebx
  800f11:	83 c4 10             	add    $0x10,%esp
  800f14:	83 fb 20             	cmp    $0x20,%ebx
  800f17:	75 ec                	jne    800f05 <close_all+0xc>
		close(i);
}
  800f19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f1c:	c9                   	leave  
  800f1d:	c3                   	ret    

00800f1e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f1e:	55                   	push   %ebp
  800f1f:	89 e5                	mov    %esp,%ebp
  800f21:	57                   	push   %edi
  800f22:	56                   	push   %esi
  800f23:	53                   	push   %ebx
  800f24:	83 ec 2c             	sub    $0x2c,%esp
  800f27:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f2a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f2d:	50                   	push   %eax
  800f2e:	ff 75 08             	pushl  0x8(%ebp)
  800f31:	e8 6e fe ff ff       	call   800da4 <fd_lookup>
  800f36:	83 c4 08             	add    $0x8,%esp
  800f39:	85 c0                	test   %eax,%eax
  800f3b:	0f 88 c1 00 00 00    	js     801002 <dup+0xe4>
		return r;
	close(newfdnum);
  800f41:	83 ec 0c             	sub    $0xc,%esp
  800f44:	56                   	push   %esi
  800f45:	e8 84 ff ff ff       	call   800ece <close>

	newfd = INDEX2FD(newfdnum);
  800f4a:	89 f3                	mov    %esi,%ebx
  800f4c:	c1 e3 0c             	shl    $0xc,%ebx
  800f4f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f55:	83 c4 04             	add    $0x4,%esp
  800f58:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f5b:	e8 de fd ff ff       	call   800d3e <fd2data>
  800f60:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f62:	89 1c 24             	mov    %ebx,(%esp)
  800f65:	e8 d4 fd ff ff       	call   800d3e <fd2data>
  800f6a:	83 c4 10             	add    $0x10,%esp
  800f6d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f70:	89 f8                	mov    %edi,%eax
  800f72:	c1 e8 16             	shr    $0x16,%eax
  800f75:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f7c:	a8 01                	test   $0x1,%al
  800f7e:	74 37                	je     800fb7 <dup+0x99>
  800f80:	89 f8                	mov    %edi,%eax
  800f82:	c1 e8 0c             	shr    $0xc,%eax
  800f85:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f8c:	f6 c2 01             	test   $0x1,%dl
  800f8f:	74 26                	je     800fb7 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f91:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f98:	83 ec 0c             	sub    $0xc,%esp
  800f9b:	25 07 0e 00 00       	and    $0xe07,%eax
  800fa0:	50                   	push   %eax
  800fa1:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fa4:	6a 00                	push   $0x0
  800fa6:	57                   	push   %edi
  800fa7:	6a 00                	push   $0x0
  800fa9:	e8 b2 fb ff ff       	call   800b60 <sys_page_map>
  800fae:	89 c7                	mov    %eax,%edi
  800fb0:	83 c4 20             	add    $0x20,%esp
  800fb3:	85 c0                	test   %eax,%eax
  800fb5:	78 2e                	js     800fe5 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fb7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fba:	89 d0                	mov    %edx,%eax
  800fbc:	c1 e8 0c             	shr    $0xc,%eax
  800fbf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fc6:	83 ec 0c             	sub    $0xc,%esp
  800fc9:	25 07 0e 00 00       	and    $0xe07,%eax
  800fce:	50                   	push   %eax
  800fcf:	53                   	push   %ebx
  800fd0:	6a 00                	push   $0x0
  800fd2:	52                   	push   %edx
  800fd3:	6a 00                	push   $0x0
  800fd5:	e8 86 fb ff ff       	call   800b60 <sys_page_map>
  800fda:	89 c7                	mov    %eax,%edi
  800fdc:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800fdf:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fe1:	85 ff                	test   %edi,%edi
  800fe3:	79 1d                	jns    801002 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fe5:	83 ec 08             	sub    $0x8,%esp
  800fe8:	53                   	push   %ebx
  800fe9:	6a 00                	push   $0x0
  800feb:	e8 b2 fb ff ff       	call   800ba2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800ff0:	83 c4 08             	add    $0x8,%esp
  800ff3:	ff 75 d4             	pushl  -0x2c(%ebp)
  800ff6:	6a 00                	push   $0x0
  800ff8:	e8 a5 fb ff ff       	call   800ba2 <sys_page_unmap>
	return r;
  800ffd:	83 c4 10             	add    $0x10,%esp
  801000:	89 f8                	mov    %edi,%eax
}
  801002:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801005:	5b                   	pop    %ebx
  801006:	5e                   	pop    %esi
  801007:	5f                   	pop    %edi
  801008:	5d                   	pop    %ebp
  801009:	c3                   	ret    

0080100a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80100a:	55                   	push   %ebp
  80100b:	89 e5                	mov    %esp,%ebp
  80100d:	53                   	push   %ebx
  80100e:	83 ec 14             	sub    $0x14,%esp
  801011:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801014:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801017:	50                   	push   %eax
  801018:	53                   	push   %ebx
  801019:	e8 86 fd ff ff       	call   800da4 <fd_lookup>
  80101e:	83 c4 08             	add    $0x8,%esp
  801021:	89 c2                	mov    %eax,%edx
  801023:	85 c0                	test   %eax,%eax
  801025:	78 6d                	js     801094 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801027:	83 ec 08             	sub    $0x8,%esp
  80102a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80102d:	50                   	push   %eax
  80102e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801031:	ff 30                	pushl  (%eax)
  801033:	e8 c2 fd ff ff       	call   800dfa <dev_lookup>
  801038:	83 c4 10             	add    $0x10,%esp
  80103b:	85 c0                	test   %eax,%eax
  80103d:	78 4c                	js     80108b <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80103f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801042:	8b 42 08             	mov    0x8(%edx),%eax
  801045:	83 e0 03             	and    $0x3,%eax
  801048:	83 f8 01             	cmp    $0x1,%eax
  80104b:	75 21                	jne    80106e <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80104d:	a1 04 40 80 00       	mov    0x804004,%eax
  801052:	8b 40 50             	mov    0x50(%eax),%eax
  801055:	83 ec 04             	sub    $0x4,%esp
  801058:	53                   	push   %ebx
  801059:	50                   	push   %eax
  80105a:	68 cd 21 80 00       	push   $0x8021cd
  80105f:	e8 31 f1 ff ff       	call   800195 <cprintf>
		return -E_INVAL;
  801064:	83 c4 10             	add    $0x10,%esp
  801067:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80106c:	eb 26                	jmp    801094 <read+0x8a>
	}
	if (!dev->dev_read)
  80106e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801071:	8b 40 08             	mov    0x8(%eax),%eax
  801074:	85 c0                	test   %eax,%eax
  801076:	74 17                	je     80108f <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801078:	83 ec 04             	sub    $0x4,%esp
  80107b:	ff 75 10             	pushl  0x10(%ebp)
  80107e:	ff 75 0c             	pushl  0xc(%ebp)
  801081:	52                   	push   %edx
  801082:	ff d0                	call   *%eax
  801084:	89 c2                	mov    %eax,%edx
  801086:	83 c4 10             	add    $0x10,%esp
  801089:	eb 09                	jmp    801094 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80108b:	89 c2                	mov    %eax,%edx
  80108d:	eb 05                	jmp    801094 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80108f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801094:	89 d0                	mov    %edx,%eax
  801096:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801099:	c9                   	leave  
  80109a:	c3                   	ret    

0080109b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80109b:	55                   	push   %ebp
  80109c:	89 e5                	mov    %esp,%ebp
  80109e:	57                   	push   %edi
  80109f:	56                   	push   %esi
  8010a0:	53                   	push   %ebx
  8010a1:	83 ec 0c             	sub    $0xc,%esp
  8010a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010a7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010af:	eb 21                	jmp    8010d2 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010b1:	83 ec 04             	sub    $0x4,%esp
  8010b4:	89 f0                	mov    %esi,%eax
  8010b6:	29 d8                	sub    %ebx,%eax
  8010b8:	50                   	push   %eax
  8010b9:	89 d8                	mov    %ebx,%eax
  8010bb:	03 45 0c             	add    0xc(%ebp),%eax
  8010be:	50                   	push   %eax
  8010bf:	57                   	push   %edi
  8010c0:	e8 45 ff ff ff       	call   80100a <read>
		if (m < 0)
  8010c5:	83 c4 10             	add    $0x10,%esp
  8010c8:	85 c0                	test   %eax,%eax
  8010ca:	78 10                	js     8010dc <readn+0x41>
			return m;
		if (m == 0)
  8010cc:	85 c0                	test   %eax,%eax
  8010ce:	74 0a                	je     8010da <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010d0:	01 c3                	add    %eax,%ebx
  8010d2:	39 f3                	cmp    %esi,%ebx
  8010d4:	72 db                	jb     8010b1 <readn+0x16>
  8010d6:	89 d8                	mov    %ebx,%eax
  8010d8:	eb 02                	jmp    8010dc <readn+0x41>
  8010da:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010df:	5b                   	pop    %ebx
  8010e0:	5e                   	pop    %esi
  8010e1:	5f                   	pop    %edi
  8010e2:	5d                   	pop    %ebp
  8010e3:	c3                   	ret    

008010e4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	53                   	push   %ebx
  8010e8:	83 ec 14             	sub    $0x14,%esp
  8010eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010f1:	50                   	push   %eax
  8010f2:	53                   	push   %ebx
  8010f3:	e8 ac fc ff ff       	call   800da4 <fd_lookup>
  8010f8:	83 c4 08             	add    $0x8,%esp
  8010fb:	89 c2                	mov    %eax,%edx
  8010fd:	85 c0                	test   %eax,%eax
  8010ff:	78 68                	js     801169 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801101:	83 ec 08             	sub    $0x8,%esp
  801104:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801107:	50                   	push   %eax
  801108:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80110b:	ff 30                	pushl  (%eax)
  80110d:	e8 e8 fc ff ff       	call   800dfa <dev_lookup>
  801112:	83 c4 10             	add    $0x10,%esp
  801115:	85 c0                	test   %eax,%eax
  801117:	78 47                	js     801160 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801119:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80111c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801120:	75 21                	jne    801143 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801122:	a1 04 40 80 00       	mov    0x804004,%eax
  801127:	8b 40 50             	mov    0x50(%eax),%eax
  80112a:	83 ec 04             	sub    $0x4,%esp
  80112d:	53                   	push   %ebx
  80112e:	50                   	push   %eax
  80112f:	68 e9 21 80 00       	push   $0x8021e9
  801134:	e8 5c f0 ff ff       	call   800195 <cprintf>
		return -E_INVAL;
  801139:	83 c4 10             	add    $0x10,%esp
  80113c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801141:	eb 26                	jmp    801169 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801143:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801146:	8b 52 0c             	mov    0xc(%edx),%edx
  801149:	85 d2                	test   %edx,%edx
  80114b:	74 17                	je     801164 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80114d:	83 ec 04             	sub    $0x4,%esp
  801150:	ff 75 10             	pushl  0x10(%ebp)
  801153:	ff 75 0c             	pushl  0xc(%ebp)
  801156:	50                   	push   %eax
  801157:	ff d2                	call   *%edx
  801159:	89 c2                	mov    %eax,%edx
  80115b:	83 c4 10             	add    $0x10,%esp
  80115e:	eb 09                	jmp    801169 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801160:	89 c2                	mov    %eax,%edx
  801162:	eb 05                	jmp    801169 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801164:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801169:	89 d0                	mov    %edx,%eax
  80116b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80116e:	c9                   	leave  
  80116f:	c3                   	ret    

00801170 <seek>:

int
seek(int fdnum, off_t offset)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801176:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801179:	50                   	push   %eax
  80117a:	ff 75 08             	pushl  0x8(%ebp)
  80117d:	e8 22 fc ff ff       	call   800da4 <fd_lookup>
  801182:	83 c4 08             	add    $0x8,%esp
  801185:	85 c0                	test   %eax,%eax
  801187:	78 0e                	js     801197 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801189:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80118c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80118f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801192:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801197:	c9                   	leave  
  801198:	c3                   	ret    

00801199 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801199:	55                   	push   %ebp
  80119a:	89 e5                	mov    %esp,%ebp
  80119c:	53                   	push   %ebx
  80119d:	83 ec 14             	sub    $0x14,%esp
  8011a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011a6:	50                   	push   %eax
  8011a7:	53                   	push   %ebx
  8011a8:	e8 f7 fb ff ff       	call   800da4 <fd_lookup>
  8011ad:	83 c4 08             	add    $0x8,%esp
  8011b0:	89 c2                	mov    %eax,%edx
  8011b2:	85 c0                	test   %eax,%eax
  8011b4:	78 65                	js     80121b <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b6:	83 ec 08             	sub    $0x8,%esp
  8011b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011bc:	50                   	push   %eax
  8011bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c0:	ff 30                	pushl  (%eax)
  8011c2:	e8 33 fc ff ff       	call   800dfa <dev_lookup>
  8011c7:	83 c4 10             	add    $0x10,%esp
  8011ca:	85 c0                	test   %eax,%eax
  8011cc:	78 44                	js     801212 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011d5:	75 21                	jne    8011f8 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011d7:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011dc:	8b 40 50             	mov    0x50(%eax),%eax
  8011df:	83 ec 04             	sub    $0x4,%esp
  8011e2:	53                   	push   %ebx
  8011e3:	50                   	push   %eax
  8011e4:	68 ac 21 80 00       	push   $0x8021ac
  8011e9:	e8 a7 ef ff ff       	call   800195 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011ee:	83 c4 10             	add    $0x10,%esp
  8011f1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011f6:	eb 23                	jmp    80121b <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011fb:	8b 52 18             	mov    0x18(%edx),%edx
  8011fe:	85 d2                	test   %edx,%edx
  801200:	74 14                	je     801216 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801202:	83 ec 08             	sub    $0x8,%esp
  801205:	ff 75 0c             	pushl  0xc(%ebp)
  801208:	50                   	push   %eax
  801209:	ff d2                	call   *%edx
  80120b:	89 c2                	mov    %eax,%edx
  80120d:	83 c4 10             	add    $0x10,%esp
  801210:	eb 09                	jmp    80121b <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801212:	89 c2                	mov    %eax,%edx
  801214:	eb 05                	jmp    80121b <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801216:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80121b:	89 d0                	mov    %edx,%eax
  80121d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801220:	c9                   	leave  
  801221:	c3                   	ret    

00801222 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801222:	55                   	push   %ebp
  801223:	89 e5                	mov    %esp,%ebp
  801225:	53                   	push   %ebx
  801226:	83 ec 14             	sub    $0x14,%esp
  801229:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80122c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80122f:	50                   	push   %eax
  801230:	ff 75 08             	pushl  0x8(%ebp)
  801233:	e8 6c fb ff ff       	call   800da4 <fd_lookup>
  801238:	83 c4 08             	add    $0x8,%esp
  80123b:	89 c2                	mov    %eax,%edx
  80123d:	85 c0                	test   %eax,%eax
  80123f:	78 58                	js     801299 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801241:	83 ec 08             	sub    $0x8,%esp
  801244:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801247:	50                   	push   %eax
  801248:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80124b:	ff 30                	pushl  (%eax)
  80124d:	e8 a8 fb ff ff       	call   800dfa <dev_lookup>
  801252:	83 c4 10             	add    $0x10,%esp
  801255:	85 c0                	test   %eax,%eax
  801257:	78 37                	js     801290 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801259:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80125c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801260:	74 32                	je     801294 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801262:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801265:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80126c:	00 00 00 
	stat->st_isdir = 0;
  80126f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801276:	00 00 00 
	stat->st_dev = dev;
  801279:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80127f:	83 ec 08             	sub    $0x8,%esp
  801282:	53                   	push   %ebx
  801283:	ff 75 f0             	pushl  -0x10(%ebp)
  801286:	ff 50 14             	call   *0x14(%eax)
  801289:	89 c2                	mov    %eax,%edx
  80128b:	83 c4 10             	add    $0x10,%esp
  80128e:	eb 09                	jmp    801299 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801290:	89 c2                	mov    %eax,%edx
  801292:	eb 05                	jmp    801299 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801294:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801299:	89 d0                	mov    %edx,%eax
  80129b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80129e:	c9                   	leave  
  80129f:	c3                   	ret    

008012a0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012a0:	55                   	push   %ebp
  8012a1:	89 e5                	mov    %esp,%ebp
  8012a3:	56                   	push   %esi
  8012a4:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012a5:	83 ec 08             	sub    $0x8,%esp
  8012a8:	6a 00                	push   $0x0
  8012aa:	ff 75 08             	pushl  0x8(%ebp)
  8012ad:	e8 e3 01 00 00       	call   801495 <open>
  8012b2:	89 c3                	mov    %eax,%ebx
  8012b4:	83 c4 10             	add    $0x10,%esp
  8012b7:	85 c0                	test   %eax,%eax
  8012b9:	78 1b                	js     8012d6 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012bb:	83 ec 08             	sub    $0x8,%esp
  8012be:	ff 75 0c             	pushl  0xc(%ebp)
  8012c1:	50                   	push   %eax
  8012c2:	e8 5b ff ff ff       	call   801222 <fstat>
  8012c7:	89 c6                	mov    %eax,%esi
	close(fd);
  8012c9:	89 1c 24             	mov    %ebx,(%esp)
  8012cc:	e8 fd fb ff ff       	call   800ece <close>
	return r;
  8012d1:	83 c4 10             	add    $0x10,%esp
  8012d4:	89 f0                	mov    %esi,%eax
}
  8012d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012d9:	5b                   	pop    %ebx
  8012da:	5e                   	pop    %esi
  8012db:	5d                   	pop    %ebp
  8012dc:	c3                   	ret    

008012dd <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012dd:	55                   	push   %ebp
  8012de:	89 e5                	mov    %esp,%ebp
  8012e0:	56                   	push   %esi
  8012e1:	53                   	push   %ebx
  8012e2:	89 c6                	mov    %eax,%esi
  8012e4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012e6:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012ed:	75 12                	jne    801301 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012ef:	83 ec 0c             	sub    $0xc,%esp
  8012f2:	6a 01                	push   $0x1
  8012f4:	e8 3c 08 00 00       	call   801b35 <ipc_find_env>
  8012f9:	a3 00 40 80 00       	mov    %eax,0x804000
  8012fe:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801301:	6a 07                	push   $0x7
  801303:	68 00 50 80 00       	push   $0x805000
  801308:	56                   	push   %esi
  801309:	ff 35 00 40 80 00    	pushl  0x804000
  80130f:	e8 bf 07 00 00       	call   801ad3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801314:	83 c4 0c             	add    $0xc,%esp
  801317:	6a 00                	push   $0x0
  801319:	53                   	push   %ebx
  80131a:	6a 00                	push   $0x0
  80131c:	e8 3d 07 00 00       	call   801a5e <ipc_recv>
}
  801321:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801324:	5b                   	pop    %ebx
  801325:	5e                   	pop    %esi
  801326:	5d                   	pop    %ebp
  801327:	c3                   	ret    

00801328 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801328:	55                   	push   %ebp
  801329:	89 e5                	mov    %esp,%ebp
  80132b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80132e:	8b 45 08             	mov    0x8(%ebp),%eax
  801331:	8b 40 0c             	mov    0xc(%eax),%eax
  801334:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801339:	8b 45 0c             	mov    0xc(%ebp),%eax
  80133c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801341:	ba 00 00 00 00       	mov    $0x0,%edx
  801346:	b8 02 00 00 00       	mov    $0x2,%eax
  80134b:	e8 8d ff ff ff       	call   8012dd <fsipc>
}
  801350:	c9                   	leave  
  801351:	c3                   	ret    

00801352 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801352:	55                   	push   %ebp
  801353:	89 e5                	mov    %esp,%ebp
  801355:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801358:	8b 45 08             	mov    0x8(%ebp),%eax
  80135b:	8b 40 0c             	mov    0xc(%eax),%eax
  80135e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801363:	ba 00 00 00 00       	mov    $0x0,%edx
  801368:	b8 06 00 00 00       	mov    $0x6,%eax
  80136d:	e8 6b ff ff ff       	call   8012dd <fsipc>
}
  801372:	c9                   	leave  
  801373:	c3                   	ret    

00801374 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801374:	55                   	push   %ebp
  801375:	89 e5                	mov    %esp,%ebp
  801377:	53                   	push   %ebx
  801378:	83 ec 04             	sub    $0x4,%esp
  80137b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80137e:	8b 45 08             	mov    0x8(%ebp),%eax
  801381:	8b 40 0c             	mov    0xc(%eax),%eax
  801384:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801389:	ba 00 00 00 00       	mov    $0x0,%edx
  80138e:	b8 05 00 00 00       	mov    $0x5,%eax
  801393:	e8 45 ff ff ff       	call   8012dd <fsipc>
  801398:	85 c0                	test   %eax,%eax
  80139a:	78 2c                	js     8013c8 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80139c:	83 ec 08             	sub    $0x8,%esp
  80139f:	68 00 50 80 00       	push   $0x805000
  8013a4:	53                   	push   %ebx
  8013a5:	e8 70 f3 ff ff       	call   80071a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013aa:	a1 80 50 80 00       	mov    0x805080,%eax
  8013af:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013b5:	a1 84 50 80 00       	mov    0x805084,%eax
  8013ba:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013c0:	83 c4 10             	add    $0x10,%esp
  8013c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013cb:	c9                   	leave  
  8013cc:	c3                   	ret    

008013cd <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013cd:	55                   	push   %ebp
  8013ce:	89 e5                	mov    %esp,%ebp
  8013d0:	83 ec 0c             	sub    $0xc,%esp
  8013d3:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8013d9:	8b 52 0c             	mov    0xc(%edx),%edx
  8013dc:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8013e2:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8013e7:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8013ec:	0f 47 c2             	cmova  %edx,%eax
  8013ef:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8013f4:	50                   	push   %eax
  8013f5:	ff 75 0c             	pushl  0xc(%ebp)
  8013f8:	68 08 50 80 00       	push   $0x805008
  8013fd:	e8 aa f4 ff ff       	call   8008ac <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801402:	ba 00 00 00 00       	mov    $0x0,%edx
  801407:	b8 04 00 00 00       	mov    $0x4,%eax
  80140c:	e8 cc fe ff ff       	call   8012dd <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801411:	c9                   	leave  
  801412:	c3                   	ret    

00801413 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801413:	55                   	push   %ebp
  801414:	89 e5                	mov    %esp,%ebp
  801416:	56                   	push   %esi
  801417:	53                   	push   %ebx
  801418:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80141b:	8b 45 08             	mov    0x8(%ebp),%eax
  80141e:	8b 40 0c             	mov    0xc(%eax),%eax
  801421:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801426:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80142c:	ba 00 00 00 00       	mov    $0x0,%edx
  801431:	b8 03 00 00 00       	mov    $0x3,%eax
  801436:	e8 a2 fe ff ff       	call   8012dd <fsipc>
  80143b:	89 c3                	mov    %eax,%ebx
  80143d:	85 c0                	test   %eax,%eax
  80143f:	78 4b                	js     80148c <devfile_read+0x79>
		return r;
	assert(r <= n);
  801441:	39 c6                	cmp    %eax,%esi
  801443:	73 16                	jae    80145b <devfile_read+0x48>
  801445:	68 18 22 80 00       	push   $0x802218
  80144a:	68 1f 22 80 00       	push   $0x80221f
  80144f:	6a 7c                	push   $0x7c
  801451:	68 34 22 80 00       	push   $0x802234
  801456:	e8 bd 05 00 00       	call   801a18 <_panic>
	assert(r <= PGSIZE);
  80145b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801460:	7e 16                	jle    801478 <devfile_read+0x65>
  801462:	68 3f 22 80 00       	push   $0x80223f
  801467:	68 1f 22 80 00       	push   $0x80221f
  80146c:	6a 7d                	push   $0x7d
  80146e:	68 34 22 80 00       	push   $0x802234
  801473:	e8 a0 05 00 00       	call   801a18 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801478:	83 ec 04             	sub    $0x4,%esp
  80147b:	50                   	push   %eax
  80147c:	68 00 50 80 00       	push   $0x805000
  801481:	ff 75 0c             	pushl  0xc(%ebp)
  801484:	e8 23 f4 ff ff       	call   8008ac <memmove>
	return r;
  801489:	83 c4 10             	add    $0x10,%esp
}
  80148c:	89 d8                	mov    %ebx,%eax
  80148e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801491:	5b                   	pop    %ebx
  801492:	5e                   	pop    %esi
  801493:	5d                   	pop    %ebp
  801494:	c3                   	ret    

00801495 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801495:	55                   	push   %ebp
  801496:	89 e5                	mov    %esp,%ebp
  801498:	53                   	push   %ebx
  801499:	83 ec 20             	sub    $0x20,%esp
  80149c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80149f:	53                   	push   %ebx
  8014a0:	e8 3c f2 ff ff       	call   8006e1 <strlen>
  8014a5:	83 c4 10             	add    $0x10,%esp
  8014a8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014ad:	7f 67                	jg     801516 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014af:	83 ec 0c             	sub    $0xc,%esp
  8014b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b5:	50                   	push   %eax
  8014b6:	e8 9a f8 ff ff       	call   800d55 <fd_alloc>
  8014bb:	83 c4 10             	add    $0x10,%esp
		return r;
  8014be:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014c0:	85 c0                	test   %eax,%eax
  8014c2:	78 57                	js     80151b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014c4:	83 ec 08             	sub    $0x8,%esp
  8014c7:	53                   	push   %ebx
  8014c8:	68 00 50 80 00       	push   $0x805000
  8014cd:	e8 48 f2 ff ff       	call   80071a <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014d5:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014da:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8014e2:	e8 f6 fd ff ff       	call   8012dd <fsipc>
  8014e7:	89 c3                	mov    %eax,%ebx
  8014e9:	83 c4 10             	add    $0x10,%esp
  8014ec:	85 c0                	test   %eax,%eax
  8014ee:	79 14                	jns    801504 <open+0x6f>
		fd_close(fd, 0);
  8014f0:	83 ec 08             	sub    $0x8,%esp
  8014f3:	6a 00                	push   $0x0
  8014f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8014f8:	e8 50 f9 ff ff       	call   800e4d <fd_close>
		return r;
  8014fd:	83 c4 10             	add    $0x10,%esp
  801500:	89 da                	mov    %ebx,%edx
  801502:	eb 17                	jmp    80151b <open+0x86>
	}

	return fd2num(fd);
  801504:	83 ec 0c             	sub    $0xc,%esp
  801507:	ff 75 f4             	pushl  -0xc(%ebp)
  80150a:	e8 1f f8 ff ff       	call   800d2e <fd2num>
  80150f:	89 c2                	mov    %eax,%edx
  801511:	83 c4 10             	add    $0x10,%esp
  801514:	eb 05                	jmp    80151b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801516:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80151b:	89 d0                	mov    %edx,%eax
  80151d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801520:	c9                   	leave  
  801521:	c3                   	ret    

00801522 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801522:	55                   	push   %ebp
  801523:	89 e5                	mov    %esp,%ebp
  801525:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801528:	ba 00 00 00 00       	mov    $0x0,%edx
  80152d:	b8 08 00 00 00       	mov    $0x8,%eax
  801532:	e8 a6 fd ff ff       	call   8012dd <fsipc>
}
  801537:	c9                   	leave  
  801538:	c3                   	ret    

00801539 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801539:	55                   	push   %ebp
  80153a:	89 e5                	mov    %esp,%ebp
  80153c:	56                   	push   %esi
  80153d:	53                   	push   %ebx
  80153e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801541:	83 ec 0c             	sub    $0xc,%esp
  801544:	ff 75 08             	pushl  0x8(%ebp)
  801547:	e8 f2 f7 ff ff       	call   800d3e <fd2data>
  80154c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80154e:	83 c4 08             	add    $0x8,%esp
  801551:	68 4b 22 80 00       	push   $0x80224b
  801556:	53                   	push   %ebx
  801557:	e8 be f1 ff ff       	call   80071a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80155c:	8b 46 04             	mov    0x4(%esi),%eax
  80155f:	2b 06                	sub    (%esi),%eax
  801561:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801567:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80156e:	00 00 00 
	stat->st_dev = &devpipe;
  801571:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801578:	30 80 00 
	return 0;
}
  80157b:	b8 00 00 00 00       	mov    $0x0,%eax
  801580:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801583:	5b                   	pop    %ebx
  801584:	5e                   	pop    %esi
  801585:	5d                   	pop    %ebp
  801586:	c3                   	ret    

00801587 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801587:	55                   	push   %ebp
  801588:	89 e5                	mov    %esp,%ebp
  80158a:	53                   	push   %ebx
  80158b:	83 ec 0c             	sub    $0xc,%esp
  80158e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801591:	53                   	push   %ebx
  801592:	6a 00                	push   $0x0
  801594:	e8 09 f6 ff ff       	call   800ba2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801599:	89 1c 24             	mov    %ebx,(%esp)
  80159c:	e8 9d f7 ff ff       	call   800d3e <fd2data>
  8015a1:	83 c4 08             	add    $0x8,%esp
  8015a4:	50                   	push   %eax
  8015a5:	6a 00                	push   $0x0
  8015a7:	e8 f6 f5 ff ff       	call   800ba2 <sys_page_unmap>
}
  8015ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015af:	c9                   	leave  
  8015b0:	c3                   	ret    

008015b1 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015b1:	55                   	push   %ebp
  8015b2:	89 e5                	mov    %esp,%ebp
  8015b4:	57                   	push   %edi
  8015b5:	56                   	push   %esi
  8015b6:	53                   	push   %ebx
  8015b7:	83 ec 1c             	sub    $0x1c,%esp
  8015ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015bd:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015bf:	a1 04 40 80 00       	mov    0x804004,%eax
  8015c4:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015c7:	83 ec 0c             	sub    $0xc,%esp
  8015ca:	ff 75 e0             	pushl  -0x20(%ebp)
  8015cd:	e8 a3 05 00 00       	call   801b75 <pageref>
  8015d2:	89 c3                	mov    %eax,%ebx
  8015d4:	89 3c 24             	mov    %edi,(%esp)
  8015d7:	e8 99 05 00 00       	call   801b75 <pageref>
  8015dc:	83 c4 10             	add    $0x10,%esp
  8015df:	39 c3                	cmp    %eax,%ebx
  8015e1:	0f 94 c1             	sete   %cl
  8015e4:	0f b6 c9             	movzbl %cl,%ecx
  8015e7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8015ea:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8015f0:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  8015f3:	39 ce                	cmp    %ecx,%esi
  8015f5:	74 1b                	je     801612 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8015f7:	39 c3                	cmp    %eax,%ebx
  8015f9:	75 c4                	jne    8015bf <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015fb:	8b 42 60             	mov    0x60(%edx),%eax
  8015fe:	ff 75 e4             	pushl  -0x1c(%ebp)
  801601:	50                   	push   %eax
  801602:	56                   	push   %esi
  801603:	68 52 22 80 00       	push   $0x802252
  801608:	e8 88 eb ff ff       	call   800195 <cprintf>
  80160d:	83 c4 10             	add    $0x10,%esp
  801610:	eb ad                	jmp    8015bf <_pipeisclosed+0xe>
	}
}
  801612:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801615:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801618:	5b                   	pop    %ebx
  801619:	5e                   	pop    %esi
  80161a:	5f                   	pop    %edi
  80161b:	5d                   	pop    %ebp
  80161c:	c3                   	ret    

0080161d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80161d:	55                   	push   %ebp
  80161e:	89 e5                	mov    %esp,%ebp
  801620:	57                   	push   %edi
  801621:	56                   	push   %esi
  801622:	53                   	push   %ebx
  801623:	83 ec 28             	sub    $0x28,%esp
  801626:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801629:	56                   	push   %esi
  80162a:	e8 0f f7 ff ff       	call   800d3e <fd2data>
  80162f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801631:	83 c4 10             	add    $0x10,%esp
  801634:	bf 00 00 00 00       	mov    $0x0,%edi
  801639:	eb 4b                	jmp    801686 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80163b:	89 da                	mov    %ebx,%edx
  80163d:	89 f0                	mov    %esi,%eax
  80163f:	e8 6d ff ff ff       	call   8015b1 <_pipeisclosed>
  801644:	85 c0                	test   %eax,%eax
  801646:	75 48                	jne    801690 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801648:	e8 b1 f4 ff ff       	call   800afe <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80164d:	8b 43 04             	mov    0x4(%ebx),%eax
  801650:	8b 0b                	mov    (%ebx),%ecx
  801652:	8d 51 20             	lea    0x20(%ecx),%edx
  801655:	39 d0                	cmp    %edx,%eax
  801657:	73 e2                	jae    80163b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801659:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80165c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801660:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801663:	89 c2                	mov    %eax,%edx
  801665:	c1 fa 1f             	sar    $0x1f,%edx
  801668:	89 d1                	mov    %edx,%ecx
  80166a:	c1 e9 1b             	shr    $0x1b,%ecx
  80166d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801670:	83 e2 1f             	and    $0x1f,%edx
  801673:	29 ca                	sub    %ecx,%edx
  801675:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801679:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80167d:	83 c0 01             	add    $0x1,%eax
  801680:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801683:	83 c7 01             	add    $0x1,%edi
  801686:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801689:	75 c2                	jne    80164d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80168b:	8b 45 10             	mov    0x10(%ebp),%eax
  80168e:	eb 05                	jmp    801695 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801690:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801695:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801698:	5b                   	pop    %ebx
  801699:	5e                   	pop    %esi
  80169a:	5f                   	pop    %edi
  80169b:	5d                   	pop    %ebp
  80169c:	c3                   	ret    

0080169d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80169d:	55                   	push   %ebp
  80169e:	89 e5                	mov    %esp,%ebp
  8016a0:	57                   	push   %edi
  8016a1:	56                   	push   %esi
  8016a2:	53                   	push   %ebx
  8016a3:	83 ec 18             	sub    $0x18,%esp
  8016a6:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016a9:	57                   	push   %edi
  8016aa:	e8 8f f6 ff ff       	call   800d3e <fd2data>
  8016af:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016b1:	83 c4 10             	add    $0x10,%esp
  8016b4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016b9:	eb 3d                	jmp    8016f8 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8016bb:	85 db                	test   %ebx,%ebx
  8016bd:	74 04                	je     8016c3 <devpipe_read+0x26>
				return i;
  8016bf:	89 d8                	mov    %ebx,%eax
  8016c1:	eb 44                	jmp    801707 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016c3:	89 f2                	mov    %esi,%edx
  8016c5:	89 f8                	mov    %edi,%eax
  8016c7:	e8 e5 fe ff ff       	call   8015b1 <_pipeisclosed>
  8016cc:	85 c0                	test   %eax,%eax
  8016ce:	75 32                	jne    801702 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016d0:	e8 29 f4 ff ff       	call   800afe <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016d5:	8b 06                	mov    (%esi),%eax
  8016d7:	3b 46 04             	cmp    0x4(%esi),%eax
  8016da:	74 df                	je     8016bb <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016dc:	99                   	cltd   
  8016dd:	c1 ea 1b             	shr    $0x1b,%edx
  8016e0:	01 d0                	add    %edx,%eax
  8016e2:	83 e0 1f             	and    $0x1f,%eax
  8016e5:	29 d0                	sub    %edx,%eax
  8016e7:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016ef:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016f2:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016f5:	83 c3 01             	add    $0x1,%ebx
  8016f8:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016fb:	75 d8                	jne    8016d5 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016fd:	8b 45 10             	mov    0x10(%ebp),%eax
  801700:	eb 05                	jmp    801707 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801702:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801707:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80170a:	5b                   	pop    %ebx
  80170b:	5e                   	pop    %esi
  80170c:	5f                   	pop    %edi
  80170d:	5d                   	pop    %ebp
  80170e:	c3                   	ret    

0080170f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80170f:	55                   	push   %ebp
  801710:	89 e5                	mov    %esp,%ebp
  801712:	56                   	push   %esi
  801713:	53                   	push   %ebx
  801714:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801717:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80171a:	50                   	push   %eax
  80171b:	e8 35 f6 ff ff       	call   800d55 <fd_alloc>
  801720:	83 c4 10             	add    $0x10,%esp
  801723:	89 c2                	mov    %eax,%edx
  801725:	85 c0                	test   %eax,%eax
  801727:	0f 88 2c 01 00 00    	js     801859 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80172d:	83 ec 04             	sub    $0x4,%esp
  801730:	68 07 04 00 00       	push   $0x407
  801735:	ff 75 f4             	pushl  -0xc(%ebp)
  801738:	6a 00                	push   $0x0
  80173a:	e8 de f3 ff ff       	call   800b1d <sys_page_alloc>
  80173f:	83 c4 10             	add    $0x10,%esp
  801742:	89 c2                	mov    %eax,%edx
  801744:	85 c0                	test   %eax,%eax
  801746:	0f 88 0d 01 00 00    	js     801859 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80174c:	83 ec 0c             	sub    $0xc,%esp
  80174f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801752:	50                   	push   %eax
  801753:	e8 fd f5 ff ff       	call   800d55 <fd_alloc>
  801758:	89 c3                	mov    %eax,%ebx
  80175a:	83 c4 10             	add    $0x10,%esp
  80175d:	85 c0                	test   %eax,%eax
  80175f:	0f 88 e2 00 00 00    	js     801847 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801765:	83 ec 04             	sub    $0x4,%esp
  801768:	68 07 04 00 00       	push   $0x407
  80176d:	ff 75 f0             	pushl  -0x10(%ebp)
  801770:	6a 00                	push   $0x0
  801772:	e8 a6 f3 ff ff       	call   800b1d <sys_page_alloc>
  801777:	89 c3                	mov    %eax,%ebx
  801779:	83 c4 10             	add    $0x10,%esp
  80177c:	85 c0                	test   %eax,%eax
  80177e:	0f 88 c3 00 00 00    	js     801847 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801784:	83 ec 0c             	sub    $0xc,%esp
  801787:	ff 75 f4             	pushl  -0xc(%ebp)
  80178a:	e8 af f5 ff ff       	call   800d3e <fd2data>
  80178f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801791:	83 c4 0c             	add    $0xc,%esp
  801794:	68 07 04 00 00       	push   $0x407
  801799:	50                   	push   %eax
  80179a:	6a 00                	push   $0x0
  80179c:	e8 7c f3 ff ff       	call   800b1d <sys_page_alloc>
  8017a1:	89 c3                	mov    %eax,%ebx
  8017a3:	83 c4 10             	add    $0x10,%esp
  8017a6:	85 c0                	test   %eax,%eax
  8017a8:	0f 88 89 00 00 00    	js     801837 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017ae:	83 ec 0c             	sub    $0xc,%esp
  8017b1:	ff 75 f0             	pushl  -0x10(%ebp)
  8017b4:	e8 85 f5 ff ff       	call   800d3e <fd2data>
  8017b9:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017c0:	50                   	push   %eax
  8017c1:	6a 00                	push   $0x0
  8017c3:	56                   	push   %esi
  8017c4:	6a 00                	push   $0x0
  8017c6:	e8 95 f3 ff ff       	call   800b60 <sys_page_map>
  8017cb:	89 c3                	mov    %eax,%ebx
  8017cd:	83 c4 20             	add    $0x20,%esp
  8017d0:	85 c0                	test   %eax,%eax
  8017d2:	78 55                	js     801829 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017d4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017dd:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017e9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017fe:	83 ec 0c             	sub    $0xc,%esp
  801801:	ff 75 f4             	pushl  -0xc(%ebp)
  801804:	e8 25 f5 ff ff       	call   800d2e <fd2num>
  801809:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80180c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80180e:	83 c4 04             	add    $0x4,%esp
  801811:	ff 75 f0             	pushl  -0x10(%ebp)
  801814:	e8 15 f5 ff ff       	call   800d2e <fd2num>
  801819:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80181c:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80181f:	83 c4 10             	add    $0x10,%esp
  801822:	ba 00 00 00 00       	mov    $0x0,%edx
  801827:	eb 30                	jmp    801859 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801829:	83 ec 08             	sub    $0x8,%esp
  80182c:	56                   	push   %esi
  80182d:	6a 00                	push   $0x0
  80182f:	e8 6e f3 ff ff       	call   800ba2 <sys_page_unmap>
  801834:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801837:	83 ec 08             	sub    $0x8,%esp
  80183a:	ff 75 f0             	pushl  -0x10(%ebp)
  80183d:	6a 00                	push   $0x0
  80183f:	e8 5e f3 ff ff       	call   800ba2 <sys_page_unmap>
  801844:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801847:	83 ec 08             	sub    $0x8,%esp
  80184a:	ff 75 f4             	pushl  -0xc(%ebp)
  80184d:	6a 00                	push   $0x0
  80184f:	e8 4e f3 ff ff       	call   800ba2 <sys_page_unmap>
  801854:	83 c4 10             	add    $0x10,%esp
  801857:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801859:	89 d0                	mov    %edx,%eax
  80185b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80185e:	5b                   	pop    %ebx
  80185f:	5e                   	pop    %esi
  801860:	5d                   	pop    %ebp
  801861:	c3                   	ret    

00801862 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801862:	55                   	push   %ebp
  801863:	89 e5                	mov    %esp,%ebp
  801865:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801868:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80186b:	50                   	push   %eax
  80186c:	ff 75 08             	pushl  0x8(%ebp)
  80186f:	e8 30 f5 ff ff       	call   800da4 <fd_lookup>
  801874:	83 c4 10             	add    $0x10,%esp
  801877:	85 c0                	test   %eax,%eax
  801879:	78 18                	js     801893 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80187b:	83 ec 0c             	sub    $0xc,%esp
  80187e:	ff 75 f4             	pushl  -0xc(%ebp)
  801881:	e8 b8 f4 ff ff       	call   800d3e <fd2data>
	return _pipeisclosed(fd, p);
  801886:	89 c2                	mov    %eax,%edx
  801888:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80188b:	e8 21 fd ff ff       	call   8015b1 <_pipeisclosed>
  801890:	83 c4 10             	add    $0x10,%esp
}
  801893:	c9                   	leave  
  801894:	c3                   	ret    

00801895 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801895:	55                   	push   %ebp
  801896:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801898:	b8 00 00 00 00       	mov    $0x0,%eax
  80189d:	5d                   	pop    %ebp
  80189e:	c3                   	ret    

0080189f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80189f:	55                   	push   %ebp
  8018a0:	89 e5                	mov    %esp,%ebp
  8018a2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018a5:	68 6a 22 80 00       	push   $0x80226a
  8018aa:	ff 75 0c             	pushl  0xc(%ebp)
  8018ad:	e8 68 ee ff ff       	call   80071a <strcpy>
	return 0;
}
  8018b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8018b7:	c9                   	leave  
  8018b8:	c3                   	ret    

008018b9 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018b9:	55                   	push   %ebp
  8018ba:	89 e5                	mov    %esp,%ebp
  8018bc:	57                   	push   %edi
  8018bd:	56                   	push   %esi
  8018be:	53                   	push   %ebx
  8018bf:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018c5:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018ca:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018d0:	eb 2d                	jmp    8018ff <devcons_write+0x46>
		m = n - tot;
  8018d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018d5:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8018d7:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018da:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8018df:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018e2:	83 ec 04             	sub    $0x4,%esp
  8018e5:	53                   	push   %ebx
  8018e6:	03 45 0c             	add    0xc(%ebp),%eax
  8018e9:	50                   	push   %eax
  8018ea:	57                   	push   %edi
  8018eb:	e8 bc ef ff ff       	call   8008ac <memmove>
		sys_cputs(buf, m);
  8018f0:	83 c4 08             	add    $0x8,%esp
  8018f3:	53                   	push   %ebx
  8018f4:	57                   	push   %edi
  8018f5:	e8 67 f1 ff ff       	call   800a61 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018fa:	01 de                	add    %ebx,%esi
  8018fc:	83 c4 10             	add    $0x10,%esp
  8018ff:	89 f0                	mov    %esi,%eax
  801901:	3b 75 10             	cmp    0x10(%ebp),%esi
  801904:	72 cc                	jb     8018d2 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801906:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801909:	5b                   	pop    %ebx
  80190a:	5e                   	pop    %esi
  80190b:	5f                   	pop    %edi
  80190c:	5d                   	pop    %ebp
  80190d:	c3                   	ret    

0080190e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	83 ec 08             	sub    $0x8,%esp
  801914:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801919:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80191d:	74 2a                	je     801949 <devcons_read+0x3b>
  80191f:	eb 05                	jmp    801926 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801921:	e8 d8 f1 ff ff       	call   800afe <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801926:	e8 54 f1 ff ff       	call   800a7f <sys_cgetc>
  80192b:	85 c0                	test   %eax,%eax
  80192d:	74 f2                	je     801921 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80192f:	85 c0                	test   %eax,%eax
  801931:	78 16                	js     801949 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801933:	83 f8 04             	cmp    $0x4,%eax
  801936:	74 0c                	je     801944 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801938:	8b 55 0c             	mov    0xc(%ebp),%edx
  80193b:	88 02                	mov    %al,(%edx)
	return 1;
  80193d:	b8 01 00 00 00       	mov    $0x1,%eax
  801942:	eb 05                	jmp    801949 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801944:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801949:	c9                   	leave  
  80194a:	c3                   	ret    

0080194b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80194b:	55                   	push   %ebp
  80194c:	89 e5                	mov    %esp,%ebp
  80194e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801951:	8b 45 08             	mov    0x8(%ebp),%eax
  801954:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801957:	6a 01                	push   $0x1
  801959:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80195c:	50                   	push   %eax
  80195d:	e8 ff f0 ff ff       	call   800a61 <sys_cputs>
}
  801962:	83 c4 10             	add    $0x10,%esp
  801965:	c9                   	leave  
  801966:	c3                   	ret    

00801967 <getchar>:

int
getchar(void)
{
  801967:	55                   	push   %ebp
  801968:	89 e5                	mov    %esp,%ebp
  80196a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80196d:	6a 01                	push   $0x1
  80196f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801972:	50                   	push   %eax
  801973:	6a 00                	push   $0x0
  801975:	e8 90 f6 ff ff       	call   80100a <read>
	if (r < 0)
  80197a:	83 c4 10             	add    $0x10,%esp
  80197d:	85 c0                	test   %eax,%eax
  80197f:	78 0f                	js     801990 <getchar+0x29>
		return r;
	if (r < 1)
  801981:	85 c0                	test   %eax,%eax
  801983:	7e 06                	jle    80198b <getchar+0x24>
		return -E_EOF;
	return c;
  801985:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801989:	eb 05                	jmp    801990 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80198b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801990:	c9                   	leave  
  801991:	c3                   	ret    

00801992 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801992:	55                   	push   %ebp
  801993:	89 e5                	mov    %esp,%ebp
  801995:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801998:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80199b:	50                   	push   %eax
  80199c:	ff 75 08             	pushl  0x8(%ebp)
  80199f:	e8 00 f4 ff ff       	call   800da4 <fd_lookup>
  8019a4:	83 c4 10             	add    $0x10,%esp
  8019a7:	85 c0                	test   %eax,%eax
  8019a9:	78 11                	js     8019bc <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8019ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ae:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019b4:	39 10                	cmp    %edx,(%eax)
  8019b6:	0f 94 c0             	sete   %al
  8019b9:	0f b6 c0             	movzbl %al,%eax
}
  8019bc:	c9                   	leave  
  8019bd:	c3                   	ret    

008019be <opencons>:

int
opencons(void)
{
  8019be:	55                   	push   %ebp
  8019bf:	89 e5                	mov    %esp,%ebp
  8019c1:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c7:	50                   	push   %eax
  8019c8:	e8 88 f3 ff ff       	call   800d55 <fd_alloc>
  8019cd:	83 c4 10             	add    $0x10,%esp
		return r;
  8019d0:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019d2:	85 c0                	test   %eax,%eax
  8019d4:	78 3e                	js     801a14 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019d6:	83 ec 04             	sub    $0x4,%esp
  8019d9:	68 07 04 00 00       	push   $0x407
  8019de:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e1:	6a 00                	push   $0x0
  8019e3:	e8 35 f1 ff ff       	call   800b1d <sys_page_alloc>
  8019e8:	83 c4 10             	add    $0x10,%esp
		return r;
  8019eb:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019ed:	85 c0                	test   %eax,%eax
  8019ef:	78 23                	js     801a14 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8019f1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019fa:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ff:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a06:	83 ec 0c             	sub    $0xc,%esp
  801a09:	50                   	push   %eax
  801a0a:	e8 1f f3 ff ff       	call   800d2e <fd2num>
  801a0f:	89 c2                	mov    %eax,%edx
  801a11:	83 c4 10             	add    $0x10,%esp
}
  801a14:	89 d0                	mov    %edx,%eax
  801a16:	c9                   	leave  
  801a17:	c3                   	ret    

00801a18 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a18:	55                   	push   %ebp
  801a19:	89 e5                	mov    %esp,%ebp
  801a1b:	56                   	push   %esi
  801a1c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a1d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a20:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a26:	e8 b4 f0 ff ff       	call   800adf <sys_getenvid>
  801a2b:	83 ec 0c             	sub    $0xc,%esp
  801a2e:	ff 75 0c             	pushl  0xc(%ebp)
  801a31:	ff 75 08             	pushl  0x8(%ebp)
  801a34:	56                   	push   %esi
  801a35:	50                   	push   %eax
  801a36:	68 78 22 80 00       	push   $0x802278
  801a3b:	e8 55 e7 ff ff       	call   800195 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a40:	83 c4 18             	add    $0x18,%esp
  801a43:	53                   	push   %ebx
  801a44:	ff 75 10             	pushl  0x10(%ebp)
  801a47:	e8 f8 e6 ff ff       	call   800144 <vcprintf>
	cprintf("\n");
  801a4c:	c7 04 24 63 22 80 00 	movl   $0x802263,(%esp)
  801a53:	e8 3d e7 ff ff       	call   800195 <cprintf>
  801a58:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a5b:	cc                   	int3   
  801a5c:	eb fd                	jmp    801a5b <_panic+0x43>

00801a5e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a5e:	55                   	push   %ebp
  801a5f:	89 e5                	mov    %esp,%ebp
  801a61:	56                   	push   %esi
  801a62:	53                   	push   %ebx
  801a63:	8b 75 08             	mov    0x8(%ebp),%esi
  801a66:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a69:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801a6c:	85 c0                	test   %eax,%eax
  801a6e:	75 12                	jne    801a82 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801a70:	83 ec 0c             	sub    $0xc,%esp
  801a73:	68 00 00 c0 ee       	push   $0xeec00000
  801a78:	e8 50 f2 ff ff       	call   800ccd <sys_ipc_recv>
  801a7d:	83 c4 10             	add    $0x10,%esp
  801a80:	eb 0c                	jmp    801a8e <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801a82:	83 ec 0c             	sub    $0xc,%esp
  801a85:	50                   	push   %eax
  801a86:	e8 42 f2 ff ff       	call   800ccd <sys_ipc_recv>
  801a8b:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801a8e:	85 f6                	test   %esi,%esi
  801a90:	0f 95 c1             	setne  %cl
  801a93:	85 db                	test   %ebx,%ebx
  801a95:	0f 95 c2             	setne  %dl
  801a98:	84 d1                	test   %dl,%cl
  801a9a:	74 09                	je     801aa5 <ipc_recv+0x47>
  801a9c:	89 c2                	mov    %eax,%edx
  801a9e:	c1 ea 1f             	shr    $0x1f,%edx
  801aa1:	84 d2                	test   %dl,%dl
  801aa3:	75 27                	jne    801acc <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801aa5:	85 f6                	test   %esi,%esi
  801aa7:	74 0a                	je     801ab3 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801aa9:	a1 04 40 80 00       	mov    0x804004,%eax
  801aae:	8b 40 7c             	mov    0x7c(%eax),%eax
  801ab1:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801ab3:	85 db                	test   %ebx,%ebx
  801ab5:	74 0d                	je     801ac4 <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  801ab7:	a1 04 40 80 00       	mov    0x804004,%eax
  801abc:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801ac2:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ac4:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac9:	8b 40 78             	mov    0x78(%eax),%eax
}
  801acc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801acf:	5b                   	pop    %ebx
  801ad0:	5e                   	pop    %esi
  801ad1:	5d                   	pop    %ebp
  801ad2:	c3                   	ret    

00801ad3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ad3:	55                   	push   %ebp
  801ad4:	89 e5                	mov    %esp,%ebp
  801ad6:	57                   	push   %edi
  801ad7:	56                   	push   %esi
  801ad8:	53                   	push   %ebx
  801ad9:	83 ec 0c             	sub    $0xc,%esp
  801adc:	8b 7d 08             	mov    0x8(%ebp),%edi
  801adf:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ae2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801ae5:	85 db                	test   %ebx,%ebx
  801ae7:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801aec:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801aef:	ff 75 14             	pushl  0x14(%ebp)
  801af2:	53                   	push   %ebx
  801af3:	56                   	push   %esi
  801af4:	57                   	push   %edi
  801af5:	e8 b0 f1 ff ff       	call   800caa <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801afa:	89 c2                	mov    %eax,%edx
  801afc:	c1 ea 1f             	shr    $0x1f,%edx
  801aff:	83 c4 10             	add    $0x10,%esp
  801b02:	84 d2                	test   %dl,%dl
  801b04:	74 17                	je     801b1d <ipc_send+0x4a>
  801b06:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b09:	74 12                	je     801b1d <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801b0b:	50                   	push   %eax
  801b0c:	68 9c 22 80 00       	push   $0x80229c
  801b11:	6a 47                	push   $0x47
  801b13:	68 aa 22 80 00       	push   $0x8022aa
  801b18:	e8 fb fe ff ff       	call   801a18 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801b1d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b20:	75 07                	jne    801b29 <ipc_send+0x56>
			sys_yield();
  801b22:	e8 d7 ef ff ff       	call   800afe <sys_yield>
  801b27:	eb c6                	jmp    801aef <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801b29:	85 c0                	test   %eax,%eax
  801b2b:	75 c2                	jne    801aef <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801b2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b30:	5b                   	pop    %ebx
  801b31:	5e                   	pop    %esi
  801b32:	5f                   	pop    %edi
  801b33:	5d                   	pop    %ebp
  801b34:	c3                   	ret    

00801b35 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b35:	55                   	push   %ebp
  801b36:	89 e5                	mov    %esp,%ebp
  801b38:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b3b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b40:	89 c2                	mov    %eax,%edx
  801b42:	c1 e2 07             	shl    $0x7,%edx
  801b45:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801b4c:	8b 52 58             	mov    0x58(%edx),%edx
  801b4f:	39 ca                	cmp    %ecx,%edx
  801b51:	75 11                	jne    801b64 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801b53:	89 c2                	mov    %eax,%edx
  801b55:	c1 e2 07             	shl    $0x7,%edx
  801b58:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801b5f:	8b 40 50             	mov    0x50(%eax),%eax
  801b62:	eb 0f                	jmp    801b73 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b64:	83 c0 01             	add    $0x1,%eax
  801b67:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b6c:	75 d2                	jne    801b40 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b6e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b73:	5d                   	pop    %ebp
  801b74:	c3                   	ret    

00801b75 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b75:	55                   	push   %ebp
  801b76:	89 e5                	mov    %esp,%ebp
  801b78:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b7b:	89 d0                	mov    %edx,%eax
  801b7d:	c1 e8 16             	shr    $0x16,%eax
  801b80:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b87:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b8c:	f6 c1 01             	test   $0x1,%cl
  801b8f:	74 1d                	je     801bae <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b91:	c1 ea 0c             	shr    $0xc,%edx
  801b94:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b9b:	f6 c2 01             	test   $0x1,%dl
  801b9e:	74 0e                	je     801bae <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ba0:	c1 ea 0c             	shr    $0xc,%edx
  801ba3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801baa:	ef 
  801bab:	0f b7 c0             	movzwl %ax,%eax
}
  801bae:	5d                   	pop    %ebp
  801baf:	c3                   	ret    

00801bb0 <__udivdi3>:
  801bb0:	55                   	push   %ebp
  801bb1:	57                   	push   %edi
  801bb2:	56                   	push   %esi
  801bb3:	53                   	push   %ebx
  801bb4:	83 ec 1c             	sub    $0x1c,%esp
  801bb7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bbb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bbf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801bc7:	85 f6                	test   %esi,%esi
  801bc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bcd:	89 ca                	mov    %ecx,%edx
  801bcf:	89 f8                	mov    %edi,%eax
  801bd1:	75 3d                	jne    801c10 <__udivdi3+0x60>
  801bd3:	39 cf                	cmp    %ecx,%edi
  801bd5:	0f 87 c5 00 00 00    	ja     801ca0 <__udivdi3+0xf0>
  801bdb:	85 ff                	test   %edi,%edi
  801bdd:	89 fd                	mov    %edi,%ebp
  801bdf:	75 0b                	jne    801bec <__udivdi3+0x3c>
  801be1:	b8 01 00 00 00       	mov    $0x1,%eax
  801be6:	31 d2                	xor    %edx,%edx
  801be8:	f7 f7                	div    %edi
  801bea:	89 c5                	mov    %eax,%ebp
  801bec:	89 c8                	mov    %ecx,%eax
  801bee:	31 d2                	xor    %edx,%edx
  801bf0:	f7 f5                	div    %ebp
  801bf2:	89 c1                	mov    %eax,%ecx
  801bf4:	89 d8                	mov    %ebx,%eax
  801bf6:	89 cf                	mov    %ecx,%edi
  801bf8:	f7 f5                	div    %ebp
  801bfa:	89 c3                	mov    %eax,%ebx
  801bfc:	89 d8                	mov    %ebx,%eax
  801bfe:	89 fa                	mov    %edi,%edx
  801c00:	83 c4 1c             	add    $0x1c,%esp
  801c03:	5b                   	pop    %ebx
  801c04:	5e                   	pop    %esi
  801c05:	5f                   	pop    %edi
  801c06:	5d                   	pop    %ebp
  801c07:	c3                   	ret    
  801c08:	90                   	nop
  801c09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c10:	39 ce                	cmp    %ecx,%esi
  801c12:	77 74                	ja     801c88 <__udivdi3+0xd8>
  801c14:	0f bd fe             	bsr    %esi,%edi
  801c17:	83 f7 1f             	xor    $0x1f,%edi
  801c1a:	0f 84 98 00 00 00    	je     801cb8 <__udivdi3+0x108>
  801c20:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c25:	89 f9                	mov    %edi,%ecx
  801c27:	89 c5                	mov    %eax,%ebp
  801c29:	29 fb                	sub    %edi,%ebx
  801c2b:	d3 e6                	shl    %cl,%esi
  801c2d:	89 d9                	mov    %ebx,%ecx
  801c2f:	d3 ed                	shr    %cl,%ebp
  801c31:	89 f9                	mov    %edi,%ecx
  801c33:	d3 e0                	shl    %cl,%eax
  801c35:	09 ee                	or     %ebp,%esi
  801c37:	89 d9                	mov    %ebx,%ecx
  801c39:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c3d:	89 d5                	mov    %edx,%ebp
  801c3f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c43:	d3 ed                	shr    %cl,%ebp
  801c45:	89 f9                	mov    %edi,%ecx
  801c47:	d3 e2                	shl    %cl,%edx
  801c49:	89 d9                	mov    %ebx,%ecx
  801c4b:	d3 e8                	shr    %cl,%eax
  801c4d:	09 c2                	or     %eax,%edx
  801c4f:	89 d0                	mov    %edx,%eax
  801c51:	89 ea                	mov    %ebp,%edx
  801c53:	f7 f6                	div    %esi
  801c55:	89 d5                	mov    %edx,%ebp
  801c57:	89 c3                	mov    %eax,%ebx
  801c59:	f7 64 24 0c          	mull   0xc(%esp)
  801c5d:	39 d5                	cmp    %edx,%ebp
  801c5f:	72 10                	jb     801c71 <__udivdi3+0xc1>
  801c61:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c65:	89 f9                	mov    %edi,%ecx
  801c67:	d3 e6                	shl    %cl,%esi
  801c69:	39 c6                	cmp    %eax,%esi
  801c6b:	73 07                	jae    801c74 <__udivdi3+0xc4>
  801c6d:	39 d5                	cmp    %edx,%ebp
  801c6f:	75 03                	jne    801c74 <__udivdi3+0xc4>
  801c71:	83 eb 01             	sub    $0x1,%ebx
  801c74:	31 ff                	xor    %edi,%edi
  801c76:	89 d8                	mov    %ebx,%eax
  801c78:	89 fa                	mov    %edi,%edx
  801c7a:	83 c4 1c             	add    $0x1c,%esp
  801c7d:	5b                   	pop    %ebx
  801c7e:	5e                   	pop    %esi
  801c7f:	5f                   	pop    %edi
  801c80:	5d                   	pop    %ebp
  801c81:	c3                   	ret    
  801c82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c88:	31 ff                	xor    %edi,%edi
  801c8a:	31 db                	xor    %ebx,%ebx
  801c8c:	89 d8                	mov    %ebx,%eax
  801c8e:	89 fa                	mov    %edi,%edx
  801c90:	83 c4 1c             	add    $0x1c,%esp
  801c93:	5b                   	pop    %ebx
  801c94:	5e                   	pop    %esi
  801c95:	5f                   	pop    %edi
  801c96:	5d                   	pop    %ebp
  801c97:	c3                   	ret    
  801c98:	90                   	nop
  801c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ca0:	89 d8                	mov    %ebx,%eax
  801ca2:	f7 f7                	div    %edi
  801ca4:	31 ff                	xor    %edi,%edi
  801ca6:	89 c3                	mov    %eax,%ebx
  801ca8:	89 d8                	mov    %ebx,%eax
  801caa:	89 fa                	mov    %edi,%edx
  801cac:	83 c4 1c             	add    $0x1c,%esp
  801caf:	5b                   	pop    %ebx
  801cb0:	5e                   	pop    %esi
  801cb1:	5f                   	pop    %edi
  801cb2:	5d                   	pop    %ebp
  801cb3:	c3                   	ret    
  801cb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cb8:	39 ce                	cmp    %ecx,%esi
  801cba:	72 0c                	jb     801cc8 <__udivdi3+0x118>
  801cbc:	31 db                	xor    %ebx,%ebx
  801cbe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801cc2:	0f 87 34 ff ff ff    	ja     801bfc <__udivdi3+0x4c>
  801cc8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801ccd:	e9 2a ff ff ff       	jmp    801bfc <__udivdi3+0x4c>
  801cd2:	66 90                	xchg   %ax,%ax
  801cd4:	66 90                	xchg   %ax,%ax
  801cd6:	66 90                	xchg   %ax,%ax
  801cd8:	66 90                	xchg   %ax,%ax
  801cda:	66 90                	xchg   %ax,%ax
  801cdc:	66 90                	xchg   %ax,%ax
  801cde:	66 90                	xchg   %ax,%ax

00801ce0 <__umoddi3>:
  801ce0:	55                   	push   %ebp
  801ce1:	57                   	push   %edi
  801ce2:	56                   	push   %esi
  801ce3:	53                   	push   %ebx
  801ce4:	83 ec 1c             	sub    $0x1c,%esp
  801ce7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801ceb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cef:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cf3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cf7:	85 d2                	test   %edx,%edx
  801cf9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801cfd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d01:	89 f3                	mov    %esi,%ebx
  801d03:	89 3c 24             	mov    %edi,(%esp)
  801d06:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d0a:	75 1c                	jne    801d28 <__umoddi3+0x48>
  801d0c:	39 f7                	cmp    %esi,%edi
  801d0e:	76 50                	jbe    801d60 <__umoddi3+0x80>
  801d10:	89 c8                	mov    %ecx,%eax
  801d12:	89 f2                	mov    %esi,%edx
  801d14:	f7 f7                	div    %edi
  801d16:	89 d0                	mov    %edx,%eax
  801d18:	31 d2                	xor    %edx,%edx
  801d1a:	83 c4 1c             	add    $0x1c,%esp
  801d1d:	5b                   	pop    %ebx
  801d1e:	5e                   	pop    %esi
  801d1f:	5f                   	pop    %edi
  801d20:	5d                   	pop    %ebp
  801d21:	c3                   	ret    
  801d22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d28:	39 f2                	cmp    %esi,%edx
  801d2a:	89 d0                	mov    %edx,%eax
  801d2c:	77 52                	ja     801d80 <__umoddi3+0xa0>
  801d2e:	0f bd ea             	bsr    %edx,%ebp
  801d31:	83 f5 1f             	xor    $0x1f,%ebp
  801d34:	75 5a                	jne    801d90 <__umoddi3+0xb0>
  801d36:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d3a:	0f 82 e0 00 00 00    	jb     801e20 <__umoddi3+0x140>
  801d40:	39 0c 24             	cmp    %ecx,(%esp)
  801d43:	0f 86 d7 00 00 00    	jbe    801e20 <__umoddi3+0x140>
  801d49:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d4d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d51:	83 c4 1c             	add    $0x1c,%esp
  801d54:	5b                   	pop    %ebx
  801d55:	5e                   	pop    %esi
  801d56:	5f                   	pop    %edi
  801d57:	5d                   	pop    %ebp
  801d58:	c3                   	ret    
  801d59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d60:	85 ff                	test   %edi,%edi
  801d62:	89 fd                	mov    %edi,%ebp
  801d64:	75 0b                	jne    801d71 <__umoddi3+0x91>
  801d66:	b8 01 00 00 00       	mov    $0x1,%eax
  801d6b:	31 d2                	xor    %edx,%edx
  801d6d:	f7 f7                	div    %edi
  801d6f:	89 c5                	mov    %eax,%ebp
  801d71:	89 f0                	mov    %esi,%eax
  801d73:	31 d2                	xor    %edx,%edx
  801d75:	f7 f5                	div    %ebp
  801d77:	89 c8                	mov    %ecx,%eax
  801d79:	f7 f5                	div    %ebp
  801d7b:	89 d0                	mov    %edx,%eax
  801d7d:	eb 99                	jmp    801d18 <__umoddi3+0x38>
  801d7f:	90                   	nop
  801d80:	89 c8                	mov    %ecx,%eax
  801d82:	89 f2                	mov    %esi,%edx
  801d84:	83 c4 1c             	add    $0x1c,%esp
  801d87:	5b                   	pop    %ebx
  801d88:	5e                   	pop    %esi
  801d89:	5f                   	pop    %edi
  801d8a:	5d                   	pop    %ebp
  801d8b:	c3                   	ret    
  801d8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d90:	8b 34 24             	mov    (%esp),%esi
  801d93:	bf 20 00 00 00       	mov    $0x20,%edi
  801d98:	89 e9                	mov    %ebp,%ecx
  801d9a:	29 ef                	sub    %ebp,%edi
  801d9c:	d3 e0                	shl    %cl,%eax
  801d9e:	89 f9                	mov    %edi,%ecx
  801da0:	89 f2                	mov    %esi,%edx
  801da2:	d3 ea                	shr    %cl,%edx
  801da4:	89 e9                	mov    %ebp,%ecx
  801da6:	09 c2                	or     %eax,%edx
  801da8:	89 d8                	mov    %ebx,%eax
  801daa:	89 14 24             	mov    %edx,(%esp)
  801dad:	89 f2                	mov    %esi,%edx
  801daf:	d3 e2                	shl    %cl,%edx
  801db1:	89 f9                	mov    %edi,%ecx
  801db3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801db7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801dbb:	d3 e8                	shr    %cl,%eax
  801dbd:	89 e9                	mov    %ebp,%ecx
  801dbf:	89 c6                	mov    %eax,%esi
  801dc1:	d3 e3                	shl    %cl,%ebx
  801dc3:	89 f9                	mov    %edi,%ecx
  801dc5:	89 d0                	mov    %edx,%eax
  801dc7:	d3 e8                	shr    %cl,%eax
  801dc9:	89 e9                	mov    %ebp,%ecx
  801dcb:	09 d8                	or     %ebx,%eax
  801dcd:	89 d3                	mov    %edx,%ebx
  801dcf:	89 f2                	mov    %esi,%edx
  801dd1:	f7 34 24             	divl   (%esp)
  801dd4:	89 d6                	mov    %edx,%esi
  801dd6:	d3 e3                	shl    %cl,%ebx
  801dd8:	f7 64 24 04          	mull   0x4(%esp)
  801ddc:	39 d6                	cmp    %edx,%esi
  801dde:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801de2:	89 d1                	mov    %edx,%ecx
  801de4:	89 c3                	mov    %eax,%ebx
  801de6:	72 08                	jb     801df0 <__umoddi3+0x110>
  801de8:	75 11                	jne    801dfb <__umoddi3+0x11b>
  801dea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dee:	73 0b                	jae    801dfb <__umoddi3+0x11b>
  801df0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801df4:	1b 14 24             	sbb    (%esp),%edx
  801df7:	89 d1                	mov    %edx,%ecx
  801df9:	89 c3                	mov    %eax,%ebx
  801dfb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801dff:	29 da                	sub    %ebx,%edx
  801e01:	19 ce                	sbb    %ecx,%esi
  801e03:	89 f9                	mov    %edi,%ecx
  801e05:	89 f0                	mov    %esi,%eax
  801e07:	d3 e0                	shl    %cl,%eax
  801e09:	89 e9                	mov    %ebp,%ecx
  801e0b:	d3 ea                	shr    %cl,%edx
  801e0d:	89 e9                	mov    %ebp,%ecx
  801e0f:	d3 ee                	shr    %cl,%esi
  801e11:	09 d0                	or     %edx,%eax
  801e13:	89 f2                	mov    %esi,%edx
  801e15:	83 c4 1c             	add    $0x1c,%esp
  801e18:	5b                   	pop    %ebx
  801e19:	5e                   	pop    %esi
  801e1a:	5f                   	pop    %edi
  801e1b:	5d                   	pop    %ebp
  801e1c:	c3                   	ret    
  801e1d:	8d 76 00             	lea    0x0(%esi),%esi
  801e20:	29 f9                	sub    %edi,%ecx
  801e22:	19 d6                	sbb    %edx,%esi
  801e24:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e28:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e2c:	e9 18 ff ff ff       	jmp    801d49 <__umoddi3+0x69>
