
obj/user/breakpoint.debug:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	57                   	push   %edi
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800042:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800049:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  80004c:	e8 85 0a 00 00       	call   800ad6 <sys_getenvid>
  800051:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  800053:	83 ec 08             	sub    $0x8,%esp
  800056:	50                   	push   %eax
  800057:	68 40 1e 80 00       	push   $0x801e40
  80005c:	e8 2b 01 00 00       	call   80018c <cprintf>
  800061:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  800067:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800074:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  800079:	89 c1                	mov    %eax,%ecx
  80007b:	c1 e1 07             	shl    $0x7,%ecx
  80007e:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  800085:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  800088:	39 cb                	cmp    %ecx,%ebx
  80008a:	0f 44 fa             	cmove  %edx,%edi
  80008d:	b9 01 00 00 00       	mov    $0x1,%ecx
  800092:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  800095:	83 c0 01             	add    $0x1,%eax
  800098:	81 c2 84 00 00 00    	add    $0x84,%edx
  80009e:	3d 00 04 00 00       	cmp    $0x400,%eax
  8000a3:	75 d4                	jne    800079 <libmain+0x40>
  8000a5:	89 f0                	mov    %esi,%eax
  8000a7:	84 c0                	test   %al,%al
  8000a9:	74 06                	je     8000b1 <libmain+0x78>
  8000ab:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000b5:	7e 0a                	jle    8000c1 <libmain+0x88>
		binaryname = argv[0];
  8000b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000ba:	8b 00                	mov    (%eax),%eax
  8000bc:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	ff 75 0c             	pushl  0xc(%ebp)
  8000c7:	ff 75 08             	pushl  0x8(%ebp)
  8000ca:	e8 64 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000cf:	e8 0b 00 00 00       	call   8000df <exit>
}
  8000d4:	83 c4 10             	add    $0x10,%esp
  8000d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000e5:	e8 06 0e 00 00       	call   800ef0 <close_all>
	sys_env_destroy(0);
  8000ea:	83 ec 0c             	sub    $0xc,%esp
  8000ed:	6a 00                	push   $0x0
  8000ef:	e8 a1 09 00 00       	call   800a95 <sys_env_destroy>
}
  8000f4:	83 c4 10             	add    $0x10,%esp
  8000f7:	c9                   	leave  
  8000f8:	c3                   	ret    

008000f9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	53                   	push   %ebx
  8000fd:	83 ec 04             	sub    $0x4,%esp
  800100:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800103:	8b 13                	mov    (%ebx),%edx
  800105:	8d 42 01             	lea    0x1(%edx),%eax
  800108:	89 03                	mov    %eax,(%ebx)
  80010a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800111:	3d ff 00 00 00       	cmp    $0xff,%eax
  800116:	75 1a                	jne    800132 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800118:	83 ec 08             	sub    $0x8,%esp
  80011b:	68 ff 00 00 00       	push   $0xff
  800120:	8d 43 08             	lea    0x8(%ebx),%eax
  800123:	50                   	push   %eax
  800124:	e8 2f 09 00 00       	call   800a58 <sys_cputs>
		b->idx = 0;
  800129:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80012f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800132:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800136:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800139:	c9                   	leave  
  80013a:	c3                   	ret    

0080013b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800144:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014b:	00 00 00 
	b.cnt = 0;
  80014e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800155:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800158:	ff 75 0c             	pushl  0xc(%ebp)
  80015b:	ff 75 08             	pushl  0x8(%ebp)
  80015e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800164:	50                   	push   %eax
  800165:	68 f9 00 80 00       	push   $0x8000f9
  80016a:	e8 54 01 00 00       	call   8002c3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80016f:	83 c4 08             	add    $0x8,%esp
  800172:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800178:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017e:	50                   	push   %eax
  80017f:	e8 d4 08 00 00       	call   800a58 <sys_cputs>

	return b.cnt;
}
  800184:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018a:	c9                   	leave  
  80018b:	c3                   	ret    

0080018c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800192:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800195:	50                   	push   %eax
  800196:	ff 75 08             	pushl  0x8(%ebp)
  800199:	e8 9d ff ff ff       	call   80013b <vcprintf>
	va_end(ap);

	return cnt;
}
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	57                   	push   %edi
  8001a4:	56                   	push   %esi
  8001a5:	53                   	push   %ebx
  8001a6:	83 ec 1c             	sub    $0x1c,%esp
  8001a9:	89 c7                	mov    %eax,%edi
  8001ab:	89 d6                	mov    %edx,%esi
  8001ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001c4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001c7:	39 d3                	cmp    %edx,%ebx
  8001c9:	72 05                	jb     8001d0 <printnum+0x30>
  8001cb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ce:	77 45                	ja     800215 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d0:	83 ec 0c             	sub    $0xc,%esp
  8001d3:	ff 75 18             	pushl  0x18(%ebp)
  8001d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8001d9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001dc:	53                   	push   %ebx
  8001dd:	ff 75 10             	pushl  0x10(%ebp)
  8001e0:	83 ec 08             	sub    $0x8,%esp
  8001e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e9:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ec:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ef:	e8 bc 19 00 00       	call   801bb0 <__udivdi3>
  8001f4:	83 c4 18             	add    $0x18,%esp
  8001f7:	52                   	push   %edx
  8001f8:	50                   	push   %eax
  8001f9:	89 f2                	mov    %esi,%edx
  8001fb:	89 f8                	mov    %edi,%eax
  8001fd:	e8 9e ff ff ff       	call   8001a0 <printnum>
  800202:	83 c4 20             	add    $0x20,%esp
  800205:	eb 18                	jmp    80021f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800207:	83 ec 08             	sub    $0x8,%esp
  80020a:	56                   	push   %esi
  80020b:	ff 75 18             	pushl  0x18(%ebp)
  80020e:	ff d7                	call   *%edi
  800210:	83 c4 10             	add    $0x10,%esp
  800213:	eb 03                	jmp    800218 <printnum+0x78>
  800215:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800218:	83 eb 01             	sub    $0x1,%ebx
  80021b:	85 db                	test   %ebx,%ebx
  80021d:	7f e8                	jg     800207 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80021f:	83 ec 08             	sub    $0x8,%esp
  800222:	56                   	push   %esi
  800223:	83 ec 04             	sub    $0x4,%esp
  800226:	ff 75 e4             	pushl  -0x1c(%ebp)
  800229:	ff 75 e0             	pushl  -0x20(%ebp)
  80022c:	ff 75 dc             	pushl  -0x24(%ebp)
  80022f:	ff 75 d8             	pushl  -0x28(%ebp)
  800232:	e8 a9 1a 00 00       	call   801ce0 <__umoddi3>
  800237:	83 c4 14             	add    $0x14,%esp
  80023a:	0f be 80 69 1e 80 00 	movsbl 0x801e69(%eax),%eax
  800241:	50                   	push   %eax
  800242:	ff d7                	call   *%edi
}
  800244:	83 c4 10             	add    $0x10,%esp
  800247:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024a:	5b                   	pop    %ebx
  80024b:	5e                   	pop    %esi
  80024c:	5f                   	pop    %edi
  80024d:	5d                   	pop    %ebp
  80024e:	c3                   	ret    

0080024f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800252:	83 fa 01             	cmp    $0x1,%edx
  800255:	7e 0e                	jle    800265 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800257:	8b 10                	mov    (%eax),%edx
  800259:	8d 4a 08             	lea    0x8(%edx),%ecx
  80025c:	89 08                	mov    %ecx,(%eax)
  80025e:	8b 02                	mov    (%edx),%eax
  800260:	8b 52 04             	mov    0x4(%edx),%edx
  800263:	eb 22                	jmp    800287 <getuint+0x38>
	else if (lflag)
  800265:	85 d2                	test   %edx,%edx
  800267:	74 10                	je     800279 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800269:	8b 10                	mov    (%eax),%edx
  80026b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026e:	89 08                	mov    %ecx,(%eax)
  800270:	8b 02                	mov    (%edx),%eax
  800272:	ba 00 00 00 00       	mov    $0x0,%edx
  800277:	eb 0e                	jmp    800287 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800279:	8b 10                	mov    (%eax),%edx
  80027b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027e:	89 08                	mov    %ecx,(%eax)
  800280:	8b 02                	mov    (%edx),%eax
  800282:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800287:	5d                   	pop    %ebp
  800288:	c3                   	ret    

00800289 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
  80028c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80028f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800293:	8b 10                	mov    (%eax),%edx
  800295:	3b 50 04             	cmp    0x4(%eax),%edx
  800298:	73 0a                	jae    8002a4 <sprintputch+0x1b>
		*b->buf++ = ch;
  80029a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80029d:	89 08                	mov    %ecx,(%eax)
  80029f:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a2:	88 02                	mov    %al,(%edx)
}
  8002a4:	5d                   	pop    %ebp
  8002a5:	c3                   	ret    

008002a6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
  8002a9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002af:	50                   	push   %eax
  8002b0:	ff 75 10             	pushl  0x10(%ebp)
  8002b3:	ff 75 0c             	pushl  0xc(%ebp)
  8002b6:	ff 75 08             	pushl  0x8(%ebp)
  8002b9:	e8 05 00 00 00       	call   8002c3 <vprintfmt>
	va_end(ap);
}
  8002be:	83 c4 10             	add    $0x10,%esp
  8002c1:	c9                   	leave  
  8002c2:	c3                   	ret    

008002c3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	57                   	push   %edi
  8002c7:	56                   	push   %esi
  8002c8:	53                   	push   %ebx
  8002c9:	83 ec 2c             	sub    $0x2c,%esp
  8002cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8002cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002d5:	eb 12                	jmp    8002e9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002d7:	85 c0                	test   %eax,%eax
  8002d9:	0f 84 89 03 00 00    	je     800668 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002df:	83 ec 08             	sub    $0x8,%esp
  8002e2:	53                   	push   %ebx
  8002e3:	50                   	push   %eax
  8002e4:	ff d6                	call   *%esi
  8002e6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002e9:	83 c7 01             	add    $0x1,%edi
  8002ec:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002f0:	83 f8 25             	cmp    $0x25,%eax
  8002f3:	75 e2                	jne    8002d7 <vprintfmt+0x14>
  8002f5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002f9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800300:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800307:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80030e:	ba 00 00 00 00       	mov    $0x0,%edx
  800313:	eb 07                	jmp    80031c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800315:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800318:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031c:	8d 47 01             	lea    0x1(%edi),%eax
  80031f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800322:	0f b6 07             	movzbl (%edi),%eax
  800325:	0f b6 c8             	movzbl %al,%ecx
  800328:	83 e8 23             	sub    $0x23,%eax
  80032b:	3c 55                	cmp    $0x55,%al
  80032d:	0f 87 1a 03 00 00    	ja     80064d <vprintfmt+0x38a>
  800333:	0f b6 c0             	movzbl %al,%eax
  800336:	ff 24 85 a0 1f 80 00 	jmp    *0x801fa0(,%eax,4)
  80033d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800340:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800344:	eb d6                	jmp    80031c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800346:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800349:	b8 00 00 00 00       	mov    $0x0,%eax
  80034e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800351:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800354:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800358:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80035b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80035e:	83 fa 09             	cmp    $0x9,%edx
  800361:	77 39                	ja     80039c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800363:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800366:	eb e9                	jmp    800351 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800368:	8b 45 14             	mov    0x14(%ebp),%eax
  80036b:	8d 48 04             	lea    0x4(%eax),%ecx
  80036e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800371:	8b 00                	mov    (%eax),%eax
  800373:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800376:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800379:	eb 27                	jmp    8003a2 <vprintfmt+0xdf>
  80037b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80037e:	85 c0                	test   %eax,%eax
  800380:	b9 00 00 00 00       	mov    $0x0,%ecx
  800385:	0f 49 c8             	cmovns %eax,%ecx
  800388:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80038e:	eb 8c                	jmp    80031c <vprintfmt+0x59>
  800390:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800393:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80039a:	eb 80                	jmp    80031c <vprintfmt+0x59>
  80039c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80039f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003a2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a6:	0f 89 70 ff ff ff    	jns    80031c <vprintfmt+0x59>
				width = precision, precision = -1;
  8003ac:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003b9:	e9 5e ff ff ff       	jmp    80031c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003be:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003c4:	e9 53 ff ff ff       	jmp    80031c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cc:	8d 50 04             	lea    0x4(%eax),%edx
  8003cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d2:	83 ec 08             	sub    $0x8,%esp
  8003d5:	53                   	push   %ebx
  8003d6:	ff 30                	pushl  (%eax)
  8003d8:	ff d6                	call   *%esi
			break;
  8003da:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003e0:	e9 04 ff ff ff       	jmp    8002e9 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e8:	8d 50 04             	lea    0x4(%eax),%edx
  8003eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ee:	8b 00                	mov    (%eax),%eax
  8003f0:	99                   	cltd   
  8003f1:	31 d0                	xor    %edx,%eax
  8003f3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003f5:	83 f8 0f             	cmp    $0xf,%eax
  8003f8:	7f 0b                	jg     800405 <vprintfmt+0x142>
  8003fa:	8b 14 85 00 21 80 00 	mov    0x802100(,%eax,4),%edx
  800401:	85 d2                	test   %edx,%edx
  800403:	75 18                	jne    80041d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800405:	50                   	push   %eax
  800406:	68 81 1e 80 00       	push   $0x801e81
  80040b:	53                   	push   %ebx
  80040c:	56                   	push   %esi
  80040d:	e8 94 fe ff ff       	call   8002a6 <printfmt>
  800412:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800415:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800418:	e9 cc fe ff ff       	jmp    8002e9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80041d:	52                   	push   %edx
  80041e:	68 31 22 80 00       	push   $0x802231
  800423:	53                   	push   %ebx
  800424:	56                   	push   %esi
  800425:	e8 7c fe ff ff       	call   8002a6 <printfmt>
  80042a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800430:	e9 b4 fe ff ff       	jmp    8002e9 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8d 50 04             	lea    0x4(%eax),%edx
  80043b:	89 55 14             	mov    %edx,0x14(%ebp)
  80043e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800440:	85 ff                	test   %edi,%edi
  800442:	b8 7a 1e 80 00       	mov    $0x801e7a,%eax
  800447:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80044a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80044e:	0f 8e 94 00 00 00    	jle    8004e8 <vprintfmt+0x225>
  800454:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800458:	0f 84 98 00 00 00    	je     8004f6 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80045e:	83 ec 08             	sub    $0x8,%esp
  800461:	ff 75 d0             	pushl  -0x30(%ebp)
  800464:	57                   	push   %edi
  800465:	e8 86 02 00 00       	call   8006f0 <strnlen>
  80046a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80046d:	29 c1                	sub    %eax,%ecx
  80046f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800472:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800475:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800479:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80047c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80047f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800481:	eb 0f                	jmp    800492 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	53                   	push   %ebx
  800487:	ff 75 e0             	pushl  -0x20(%ebp)
  80048a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048c:	83 ef 01             	sub    $0x1,%edi
  80048f:	83 c4 10             	add    $0x10,%esp
  800492:	85 ff                	test   %edi,%edi
  800494:	7f ed                	jg     800483 <vprintfmt+0x1c0>
  800496:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800499:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80049c:	85 c9                	test   %ecx,%ecx
  80049e:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a3:	0f 49 c1             	cmovns %ecx,%eax
  8004a6:	29 c1                	sub    %eax,%ecx
  8004a8:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ab:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ae:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b1:	89 cb                	mov    %ecx,%ebx
  8004b3:	eb 4d                	jmp    800502 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004b5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b9:	74 1b                	je     8004d6 <vprintfmt+0x213>
  8004bb:	0f be c0             	movsbl %al,%eax
  8004be:	83 e8 20             	sub    $0x20,%eax
  8004c1:	83 f8 5e             	cmp    $0x5e,%eax
  8004c4:	76 10                	jbe    8004d6 <vprintfmt+0x213>
					putch('?', putdat);
  8004c6:	83 ec 08             	sub    $0x8,%esp
  8004c9:	ff 75 0c             	pushl  0xc(%ebp)
  8004cc:	6a 3f                	push   $0x3f
  8004ce:	ff 55 08             	call   *0x8(%ebp)
  8004d1:	83 c4 10             	add    $0x10,%esp
  8004d4:	eb 0d                	jmp    8004e3 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004d6:	83 ec 08             	sub    $0x8,%esp
  8004d9:	ff 75 0c             	pushl  0xc(%ebp)
  8004dc:	52                   	push   %edx
  8004dd:	ff 55 08             	call   *0x8(%ebp)
  8004e0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e3:	83 eb 01             	sub    $0x1,%ebx
  8004e6:	eb 1a                	jmp    800502 <vprintfmt+0x23f>
  8004e8:	89 75 08             	mov    %esi,0x8(%ebp)
  8004eb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ee:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f4:	eb 0c                	jmp    800502 <vprintfmt+0x23f>
  8004f6:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004fc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ff:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800502:	83 c7 01             	add    $0x1,%edi
  800505:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800509:	0f be d0             	movsbl %al,%edx
  80050c:	85 d2                	test   %edx,%edx
  80050e:	74 23                	je     800533 <vprintfmt+0x270>
  800510:	85 f6                	test   %esi,%esi
  800512:	78 a1                	js     8004b5 <vprintfmt+0x1f2>
  800514:	83 ee 01             	sub    $0x1,%esi
  800517:	79 9c                	jns    8004b5 <vprintfmt+0x1f2>
  800519:	89 df                	mov    %ebx,%edi
  80051b:	8b 75 08             	mov    0x8(%ebp),%esi
  80051e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800521:	eb 18                	jmp    80053b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800523:	83 ec 08             	sub    $0x8,%esp
  800526:	53                   	push   %ebx
  800527:	6a 20                	push   $0x20
  800529:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80052b:	83 ef 01             	sub    $0x1,%edi
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	eb 08                	jmp    80053b <vprintfmt+0x278>
  800533:	89 df                	mov    %ebx,%edi
  800535:	8b 75 08             	mov    0x8(%ebp),%esi
  800538:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053b:	85 ff                	test   %edi,%edi
  80053d:	7f e4                	jg     800523 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800542:	e9 a2 fd ff ff       	jmp    8002e9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800547:	83 fa 01             	cmp    $0x1,%edx
  80054a:	7e 16                	jle    800562 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80054c:	8b 45 14             	mov    0x14(%ebp),%eax
  80054f:	8d 50 08             	lea    0x8(%eax),%edx
  800552:	89 55 14             	mov    %edx,0x14(%ebp)
  800555:	8b 50 04             	mov    0x4(%eax),%edx
  800558:	8b 00                	mov    (%eax),%eax
  80055a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800560:	eb 32                	jmp    800594 <vprintfmt+0x2d1>
	else if (lflag)
  800562:	85 d2                	test   %edx,%edx
  800564:	74 18                	je     80057e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800566:	8b 45 14             	mov    0x14(%ebp),%eax
  800569:	8d 50 04             	lea    0x4(%eax),%edx
  80056c:	89 55 14             	mov    %edx,0x14(%ebp)
  80056f:	8b 00                	mov    (%eax),%eax
  800571:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800574:	89 c1                	mov    %eax,%ecx
  800576:	c1 f9 1f             	sar    $0x1f,%ecx
  800579:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80057c:	eb 16                	jmp    800594 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80057e:	8b 45 14             	mov    0x14(%ebp),%eax
  800581:	8d 50 04             	lea    0x4(%eax),%edx
  800584:	89 55 14             	mov    %edx,0x14(%ebp)
  800587:	8b 00                	mov    (%eax),%eax
  800589:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058c:	89 c1                	mov    %eax,%ecx
  80058e:	c1 f9 1f             	sar    $0x1f,%ecx
  800591:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800594:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800597:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80059a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80059f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005a3:	79 74                	jns    800619 <vprintfmt+0x356>
				putch('-', putdat);
  8005a5:	83 ec 08             	sub    $0x8,%esp
  8005a8:	53                   	push   %ebx
  8005a9:	6a 2d                	push   $0x2d
  8005ab:	ff d6                	call   *%esi
				num = -(long long) num;
  8005ad:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005b3:	f7 d8                	neg    %eax
  8005b5:	83 d2 00             	adc    $0x0,%edx
  8005b8:	f7 da                	neg    %edx
  8005ba:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005bd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005c2:	eb 55                	jmp    800619 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005c4:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c7:	e8 83 fc ff ff       	call   80024f <getuint>
			base = 10;
  8005cc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005d1:	eb 46                	jmp    800619 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d6:	e8 74 fc ff ff       	call   80024f <getuint>
			base = 8;
  8005db:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005e0:	eb 37                	jmp    800619 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005e2:	83 ec 08             	sub    $0x8,%esp
  8005e5:	53                   	push   %ebx
  8005e6:	6a 30                	push   $0x30
  8005e8:	ff d6                	call   *%esi
			putch('x', putdat);
  8005ea:	83 c4 08             	add    $0x8,%esp
  8005ed:	53                   	push   %ebx
  8005ee:	6a 78                	push   $0x78
  8005f0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8d 50 04             	lea    0x4(%eax),%edx
  8005f8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005fb:	8b 00                	mov    (%eax),%eax
  8005fd:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800602:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800605:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80060a:	eb 0d                	jmp    800619 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80060c:	8d 45 14             	lea    0x14(%ebp),%eax
  80060f:	e8 3b fc ff ff       	call   80024f <getuint>
			base = 16;
  800614:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800619:	83 ec 0c             	sub    $0xc,%esp
  80061c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800620:	57                   	push   %edi
  800621:	ff 75 e0             	pushl  -0x20(%ebp)
  800624:	51                   	push   %ecx
  800625:	52                   	push   %edx
  800626:	50                   	push   %eax
  800627:	89 da                	mov    %ebx,%edx
  800629:	89 f0                	mov    %esi,%eax
  80062b:	e8 70 fb ff ff       	call   8001a0 <printnum>
			break;
  800630:	83 c4 20             	add    $0x20,%esp
  800633:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800636:	e9 ae fc ff ff       	jmp    8002e9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80063b:	83 ec 08             	sub    $0x8,%esp
  80063e:	53                   	push   %ebx
  80063f:	51                   	push   %ecx
  800640:	ff d6                	call   *%esi
			break;
  800642:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800645:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800648:	e9 9c fc ff ff       	jmp    8002e9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	53                   	push   %ebx
  800651:	6a 25                	push   $0x25
  800653:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800655:	83 c4 10             	add    $0x10,%esp
  800658:	eb 03                	jmp    80065d <vprintfmt+0x39a>
  80065a:	83 ef 01             	sub    $0x1,%edi
  80065d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800661:	75 f7                	jne    80065a <vprintfmt+0x397>
  800663:	e9 81 fc ff ff       	jmp    8002e9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800668:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80066b:	5b                   	pop    %ebx
  80066c:	5e                   	pop    %esi
  80066d:	5f                   	pop    %edi
  80066e:	5d                   	pop    %ebp
  80066f:	c3                   	ret    

00800670 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800670:	55                   	push   %ebp
  800671:	89 e5                	mov    %esp,%ebp
  800673:	83 ec 18             	sub    $0x18,%esp
  800676:	8b 45 08             	mov    0x8(%ebp),%eax
  800679:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80067c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80067f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800683:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800686:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80068d:	85 c0                	test   %eax,%eax
  80068f:	74 26                	je     8006b7 <vsnprintf+0x47>
  800691:	85 d2                	test   %edx,%edx
  800693:	7e 22                	jle    8006b7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800695:	ff 75 14             	pushl  0x14(%ebp)
  800698:	ff 75 10             	pushl  0x10(%ebp)
  80069b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80069e:	50                   	push   %eax
  80069f:	68 89 02 80 00       	push   $0x800289
  8006a4:	e8 1a fc ff ff       	call   8002c3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ac:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b2:	83 c4 10             	add    $0x10,%esp
  8006b5:	eb 05                	jmp    8006bc <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006bc:	c9                   	leave  
  8006bd:	c3                   	ret    

008006be <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006be:	55                   	push   %ebp
  8006bf:	89 e5                	mov    %esp,%ebp
  8006c1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006c4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006c7:	50                   	push   %eax
  8006c8:	ff 75 10             	pushl  0x10(%ebp)
  8006cb:	ff 75 0c             	pushl  0xc(%ebp)
  8006ce:	ff 75 08             	pushl  0x8(%ebp)
  8006d1:	e8 9a ff ff ff       	call   800670 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006d6:	c9                   	leave  
  8006d7:	c3                   	ret    

008006d8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006d8:	55                   	push   %ebp
  8006d9:	89 e5                	mov    %esp,%ebp
  8006db:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006de:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e3:	eb 03                	jmp    8006e8 <strlen+0x10>
		n++;
  8006e5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006ec:	75 f7                	jne    8006e5 <strlen+0xd>
		n++;
	return n;
}
  8006ee:	5d                   	pop    %ebp
  8006ef:	c3                   	ret    

008006f0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f0:	55                   	push   %ebp
  8006f1:	89 e5                	mov    %esp,%ebp
  8006f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006f6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8006fe:	eb 03                	jmp    800703 <strnlen+0x13>
		n++;
  800700:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800703:	39 c2                	cmp    %eax,%edx
  800705:	74 08                	je     80070f <strnlen+0x1f>
  800707:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80070b:	75 f3                	jne    800700 <strnlen+0x10>
  80070d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80070f:	5d                   	pop    %ebp
  800710:	c3                   	ret    

00800711 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800711:	55                   	push   %ebp
  800712:	89 e5                	mov    %esp,%ebp
  800714:	53                   	push   %ebx
  800715:	8b 45 08             	mov    0x8(%ebp),%eax
  800718:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80071b:	89 c2                	mov    %eax,%edx
  80071d:	83 c2 01             	add    $0x1,%edx
  800720:	83 c1 01             	add    $0x1,%ecx
  800723:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800727:	88 5a ff             	mov    %bl,-0x1(%edx)
  80072a:	84 db                	test   %bl,%bl
  80072c:	75 ef                	jne    80071d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80072e:	5b                   	pop    %ebx
  80072f:	5d                   	pop    %ebp
  800730:	c3                   	ret    

00800731 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800731:	55                   	push   %ebp
  800732:	89 e5                	mov    %esp,%ebp
  800734:	53                   	push   %ebx
  800735:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800738:	53                   	push   %ebx
  800739:	e8 9a ff ff ff       	call   8006d8 <strlen>
  80073e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800741:	ff 75 0c             	pushl  0xc(%ebp)
  800744:	01 d8                	add    %ebx,%eax
  800746:	50                   	push   %eax
  800747:	e8 c5 ff ff ff       	call   800711 <strcpy>
	return dst;
}
  80074c:	89 d8                	mov    %ebx,%eax
  80074e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800751:	c9                   	leave  
  800752:	c3                   	ret    

00800753 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	56                   	push   %esi
  800757:	53                   	push   %ebx
  800758:	8b 75 08             	mov    0x8(%ebp),%esi
  80075b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80075e:	89 f3                	mov    %esi,%ebx
  800760:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800763:	89 f2                	mov    %esi,%edx
  800765:	eb 0f                	jmp    800776 <strncpy+0x23>
		*dst++ = *src;
  800767:	83 c2 01             	add    $0x1,%edx
  80076a:	0f b6 01             	movzbl (%ecx),%eax
  80076d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800770:	80 39 01             	cmpb   $0x1,(%ecx)
  800773:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800776:	39 da                	cmp    %ebx,%edx
  800778:	75 ed                	jne    800767 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80077a:	89 f0                	mov    %esi,%eax
  80077c:	5b                   	pop    %ebx
  80077d:	5e                   	pop    %esi
  80077e:	5d                   	pop    %ebp
  80077f:	c3                   	ret    

00800780 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	56                   	push   %esi
  800784:	53                   	push   %ebx
  800785:	8b 75 08             	mov    0x8(%ebp),%esi
  800788:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078b:	8b 55 10             	mov    0x10(%ebp),%edx
  80078e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800790:	85 d2                	test   %edx,%edx
  800792:	74 21                	je     8007b5 <strlcpy+0x35>
  800794:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800798:	89 f2                	mov    %esi,%edx
  80079a:	eb 09                	jmp    8007a5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80079c:	83 c2 01             	add    $0x1,%edx
  80079f:	83 c1 01             	add    $0x1,%ecx
  8007a2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007a5:	39 c2                	cmp    %eax,%edx
  8007a7:	74 09                	je     8007b2 <strlcpy+0x32>
  8007a9:	0f b6 19             	movzbl (%ecx),%ebx
  8007ac:	84 db                	test   %bl,%bl
  8007ae:	75 ec                	jne    80079c <strlcpy+0x1c>
  8007b0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007b2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007b5:	29 f0                	sub    %esi,%eax
}
  8007b7:	5b                   	pop    %ebx
  8007b8:	5e                   	pop    %esi
  8007b9:	5d                   	pop    %ebp
  8007ba:	c3                   	ret    

008007bb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007c4:	eb 06                	jmp    8007cc <strcmp+0x11>
		p++, q++;
  8007c6:	83 c1 01             	add    $0x1,%ecx
  8007c9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007cc:	0f b6 01             	movzbl (%ecx),%eax
  8007cf:	84 c0                	test   %al,%al
  8007d1:	74 04                	je     8007d7 <strcmp+0x1c>
  8007d3:	3a 02                	cmp    (%edx),%al
  8007d5:	74 ef                	je     8007c6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d7:	0f b6 c0             	movzbl %al,%eax
  8007da:	0f b6 12             	movzbl (%edx),%edx
  8007dd:	29 d0                	sub    %edx,%eax
}
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	53                   	push   %ebx
  8007e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007eb:	89 c3                	mov    %eax,%ebx
  8007ed:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007f0:	eb 06                	jmp    8007f8 <strncmp+0x17>
		n--, p++, q++;
  8007f2:	83 c0 01             	add    $0x1,%eax
  8007f5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007f8:	39 d8                	cmp    %ebx,%eax
  8007fa:	74 15                	je     800811 <strncmp+0x30>
  8007fc:	0f b6 08             	movzbl (%eax),%ecx
  8007ff:	84 c9                	test   %cl,%cl
  800801:	74 04                	je     800807 <strncmp+0x26>
  800803:	3a 0a                	cmp    (%edx),%cl
  800805:	74 eb                	je     8007f2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800807:	0f b6 00             	movzbl (%eax),%eax
  80080a:	0f b6 12             	movzbl (%edx),%edx
  80080d:	29 d0                	sub    %edx,%eax
  80080f:	eb 05                	jmp    800816 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800811:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800816:	5b                   	pop    %ebx
  800817:	5d                   	pop    %ebp
  800818:	c3                   	ret    

00800819 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	8b 45 08             	mov    0x8(%ebp),%eax
  80081f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800823:	eb 07                	jmp    80082c <strchr+0x13>
		if (*s == c)
  800825:	38 ca                	cmp    %cl,%dl
  800827:	74 0f                	je     800838 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800829:	83 c0 01             	add    $0x1,%eax
  80082c:	0f b6 10             	movzbl (%eax),%edx
  80082f:	84 d2                	test   %dl,%dl
  800831:	75 f2                	jne    800825 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800833:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	8b 45 08             	mov    0x8(%ebp),%eax
  800840:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800844:	eb 03                	jmp    800849 <strfind+0xf>
  800846:	83 c0 01             	add    $0x1,%eax
  800849:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80084c:	38 ca                	cmp    %cl,%dl
  80084e:	74 04                	je     800854 <strfind+0x1a>
  800850:	84 d2                	test   %dl,%dl
  800852:	75 f2                	jne    800846 <strfind+0xc>
			break;
	return (char *) s;
}
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	57                   	push   %edi
  80085a:	56                   	push   %esi
  80085b:	53                   	push   %ebx
  80085c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80085f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800862:	85 c9                	test   %ecx,%ecx
  800864:	74 36                	je     80089c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800866:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80086c:	75 28                	jne    800896 <memset+0x40>
  80086e:	f6 c1 03             	test   $0x3,%cl
  800871:	75 23                	jne    800896 <memset+0x40>
		c &= 0xFF;
  800873:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800877:	89 d3                	mov    %edx,%ebx
  800879:	c1 e3 08             	shl    $0x8,%ebx
  80087c:	89 d6                	mov    %edx,%esi
  80087e:	c1 e6 18             	shl    $0x18,%esi
  800881:	89 d0                	mov    %edx,%eax
  800883:	c1 e0 10             	shl    $0x10,%eax
  800886:	09 f0                	or     %esi,%eax
  800888:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80088a:	89 d8                	mov    %ebx,%eax
  80088c:	09 d0                	or     %edx,%eax
  80088e:	c1 e9 02             	shr    $0x2,%ecx
  800891:	fc                   	cld    
  800892:	f3 ab                	rep stos %eax,%es:(%edi)
  800894:	eb 06                	jmp    80089c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800896:	8b 45 0c             	mov    0xc(%ebp),%eax
  800899:	fc                   	cld    
  80089a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80089c:	89 f8                	mov    %edi,%eax
  80089e:	5b                   	pop    %ebx
  80089f:	5e                   	pop    %esi
  8008a0:	5f                   	pop    %edi
  8008a1:	5d                   	pop    %ebp
  8008a2:	c3                   	ret    

008008a3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	57                   	push   %edi
  8008a7:	56                   	push   %esi
  8008a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ab:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008b1:	39 c6                	cmp    %eax,%esi
  8008b3:	73 35                	jae    8008ea <memmove+0x47>
  8008b5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008b8:	39 d0                	cmp    %edx,%eax
  8008ba:	73 2e                	jae    8008ea <memmove+0x47>
		s += n;
		d += n;
  8008bc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008bf:	89 d6                	mov    %edx,%esi
  8008c1:	09 fe                	or     %edi,%esi
  8008c3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008c9:	75 13                	jne    8008de <memmove+0x3b>
  8008cb:	f6 c1 03             	test   $0x3,%cl
  8008ce:	75 0e                	jne    8008de <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008d0:	83 ef 04             	sub    $0x4,%edi
  8008d3:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008d6:	c1 e9 02             	shr    $0x2,%ecx
  8008d9:	fd                   	std    
  8008da:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008dc:	eb 09                	jmp    8008e7 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008de:	83 ef 01             	sub    $0x1,%edi
  8008e1:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008e4:	fd                   	std    
  8008e5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008e7:	fc                   	cld    
  8008e8:	eb 1d                	jmp    800907 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ea:	89 f2                	mov    %esi,%edx
  8008ec:	09 c2                	or     %eax,%edx
  8008ee:	f6 c2 03             	test   $0x3,%dl
  8008f1:	75 0f                	jne    800902 <memmove+0x5f>
  8008f3:	f6 c1 03             	test   $0x3,%cl
  8008f6:	75 0a                	jne    800902 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008f8:	c1 e9 02             	shr    $0x2,%ecx
  8008fb:	89 c7                	mov    %eax,%edi
  8008fd:	fc                   	cld    
  8008fe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800900:	eb 05                	jmp    800907 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800902:	89 c7                	mov    %eax,%edi
  800904:	fc                   	cld    
  800905:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800907:	5e                   	pop    %esi
  800908:	5f                   	pop    %edi
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80090e:	ff 75 10             	pushl  0x10(%ebp)
  800911:	ff 75 0c             	pushl  0xc(%ebp)
  800914:	ff 75 08             	pushl  0x8(%ebp)
  800917:	e8 87 ff ff ff       	call   8008a3 <memmove>
}
  80091c:	c9                   	leave  
  80091d:	c3                   	ret    

0080091e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	56                   	push   %esi
  800922:	53                   	push   %ebx
  800923:	8b 45 08             	mov    0x8(%ebp),%eax
  800926:	8b 55 0c             	mov    0xc(%ebp),%edx
  800929:	89 c6                	mov    %eax,%esi
  80092b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80092e:	eb 1a                	jmp    80094a <memcmp+0x2c>
		if (*s1 != *s2)
  800930:	0f b6 08             	movzbl (%eax),%ecx
  800933:	0f b6 1a             	movzbl (%edx),%ebx
  800936:	38 d9                	cmp    %bl,%cl
  800938:	74 0a                	je     800944 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80093a:	0f b6 c1             	movzbl %cl,%eax
  80093d:	0f b6 db             	movzbl %bl,%ebx
  800940:	29 d8                	sub    %ebx,%eax
  800942:	eb 0f                	jmp    800953 <memcmp+0x35>
		s1++, s2++;
  800944:	83 c0 01             	add    $0x1,%eax
  800947:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094a:	39 f0                	cmp    %esi,%eax
  80094c:	75 e2                	jne    800930 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80094e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800953:	5b                   	pop    %ebx
  800954:	5e                   	pop    %esi
  800955:	5d                   	pop    %ebp
  800956:	c3                   	ret    

00800957 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	53                   	push   %ebx
  80095b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80095e:	89 c1                	mov    %eax,%ecx
  800960:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800963:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800967:	eb 0a                	jmp    800973 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800969:	0f b6 10             	movzbl (%eax),%edx
  80096c:	39 da                	cmp    %ebx,%edx
  80096e:	74 07                	je     800977 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800970:	83 c0 01             	add    $0x1,%eax
  800973:	39 c8                	cmp    %ecx,%eax
  800975:	72 f2                	jb     800969 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800977:	5b                   	pop    %ebx
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	57                   	push   %edi
  80097e:	56                   	push   %esi
  80097f:	53                   	push   %ebx
  800980:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800983:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800986:	eb 03                	jmp    80098b <strtol+0x11>
		s++;
  800988:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80098b:	0f b6 01             	movzbl (%ecx),%eax
  80098e:	3c 20                	cmp    $0x20,%al
  800990:	74 f6                	je     800988 <strtol+0xe>
  800992:	3c 09                	cmp    $0x9,%al
  800994:	74 f2                	je     800988 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800996:	3c 2b                	cmp    $0x2b,%al
  800998:	75 0a                	jne    8009a4 <strtol+0x2a>
		s++;
  80099a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80099d:	bf 00 00 00 00       	mov    $0x0,%edi
  8009a2:	eb 11                	jmp    8009b5 <strtol+0x3b>
  8009a4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009a9:	3c 2d                	cmp    $0x2d,%al
  8009ab:	75 08                	jne    8009b5 <strtol+0x3b>
		s++, neg = 1;
  8009ad:	83 c1 01             	add    $0x1,%ecx
  8009b0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009b5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009bb:	75 15                	jne    8009d2 <strtol+0x58>
  8009bd:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c0:	75 10                	jne    8009d2 <strtol+0x58>
  8009c2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009c6:	75 7c                	jne    800a44 <strtol+0xca>
		s += 2, base = 16;
  8009c8:	83 c1 02             	add    $0x2,%ecx
  8009cb:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009d0:	eb 16                	jmp    8009e8 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009d2:	85 db                	test   %ebx,%ebx
  8009d4:	75 12                	jne    8009e8 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009d6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009db:	80 39 30             	cmpb   $0x30,(%ecx)
  8009de:	75 08                	jne    8009e8 <strtol+0x6e>
		s++, base = 8;
  8009e0:	83 c1 01             	add    $0x1,%ecx
  8009e3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ed:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009f0:	0f b6 11             	movzbl (%ecx),%edx
  8009f3:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009f6:	89 f3                	mov    %esi,%ebx
  8009f8:	80 fb 09             	cmp    $0x9,%bl
  8009fb:	77 08                	ja     800a05 <strtol+0x8b>
			dig = *s - '0';
  8009fd:	0f be d2             	movsbl %dl,%edx
  800a00:	83 ea 30             	sub    $0x30,%edx
  800a03:	eb 22                	jmp    800a27 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a05:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a08:	89 f3                	mov    %esi,%ebx
  800a0a:	80 fb 19             	cmp    $0x19,%bl
  800a0d:	77 08                	ja     800a17 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a0f:	0f be d2             	movsbl %dl,%edx
  800a12:	83 ea 57             	sub    $0x57,%edx
  800a15:	eb 10                	jmp    800a27 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a17:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a1a:	89 f3                	mov    %esi,%ebx
  800a1c:	80 fb 19             	cmp    $0x19,%bl
  800a1f:	77 16                	ja     800a37 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a21:	0f be d2             	movsbl %dl,%edx
  800a24:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a27:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a2a:	7d 0b                	jge    800a37 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a2c:	83 c1 01             	add    $0x1,%ecx
  800a2f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a33:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a35:	eb b9                	jmp    8009f0 <strtol+0x76>

	if (endptr)
  800a37:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a3b:	74 0d                	je     800a4a <strtol+0xd0>
		*endptr = (char *) s;
  800a3d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a40:	89 0e                	mov    %ecx,(%esi)
  800a42:	eb 06                	jmp    800a4a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a44:	85 db                	test   %ebx,%ebx
  800a46:	74 98                	je     8009e0 <strtol+0x66>
  800a48:	eb 9e                	jmp    8009e8 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a4a:	89 c2                	mov    %eax,%edx
  800a4c:	f7 da                	neg    %edx
  800a4e:	85 ff                	test   %edi,%edi
  800a50:	0f 45 c2             	cmovne %edx,%eax
}
  800a53:	5b                   	pop    %ebx
  800a54:	5e                   	pop    %esi
  800a55:	5f                   	pop    %edi
  800a56:	5d                   	pop    %ebp
  800a57:	c3                   	ret    

00800a58 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a58:	55                   	push   %ebp
  800a59:	89 e5                	mov    %esp,%ebp
  800a5b:	57                   	push   %edi
  800a5c:	56                   	push   %esi
  800a5d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a66:	8b 55 08             	mov    0x8(%ebp),%edx
  800a69:	89 c3                	mov    %eax,%ebx
  800a6b:	89 c7                	mov    %eax,%edi
  800a6d:	89 c6                	mov    %eax,%esi
  800a6f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a71:	5b                   	pop    %ebx
  800a72:	5e                   	pop    %esi
  800a73:	5f                   	pop    %edi
  800a74:	5d                   	pop    %ebp
  800a75:	c3                   	ret    

00800a76 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	57                   	push   %edi
  800a7a:	56                   	push   %esi
  800a7b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a81:	b8 01 00 00 00       	mov    $0x1,%eax
  800a86:	89 d1                	mov    %edx,%ecx
  800a88:	89 d3                	mov    %edx,%ebx
  800a8a:	89 d7                	mov    %edx,%edi
  800a8c:	89 d6                	mov    %edx,%esi
  800a8e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a90:	5b                   	pop    %ebx
  800a91:	5e                   	pop    %esi
  800a92:	5f                   	pop    %edi
  800a93:	5d                   	pop    %ebp
  800a94:	c3                   	ret    

00800a95 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a95:	55                   	push   %ebp
  800a96:	89 e5                	mov    %esp,%ebp
  800a98:	57                   	push   %edi
  800a99:	56                   	push   %esi
  800a9a:	53                   	push   %ebx
  800a9b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aa3:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa8:	8b 55 08             	mov    0x8(%ebp),%edx
  800aab:	89 cb                	mov    %ecx,%ebx
  800aad:	89 cf                	mov    %ecx,%edi
  800aaf:	89 ce                	mov    %ecx,%esi
  800ab1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ab3:	85 c0                	test   %eax,%eax
  800ab5:	7e 17                	jle    800ace <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ab7:	83 ec 0c             	sub    $0xc,%esp
  800aba:	50                   	push   %eax
  800abb:	6a 03                	push   $0x3
  800abd:	68 5f 21 80 00       	push   $0x80215f
  800ac2:	6a 23                	push   $0x23
  800ac4:	68 7c 21 80 00       	push   $0x80217c
  800ac9:	e8 41 0f 00 00       	call   801a0f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ace:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad1:	5b                   	pop    %ebx
  800ad2:	5e                   	pop    %esi
  800ad3:	5f                   	pop    %edi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	57                   	push   %edi
  800ada:	56                   	push   %esi
  800adb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800adc:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae1:	b8 02 00 00 00       	mov    $0x2,%eax
  800ae6:	89 d1                	mov    %edx,%ecx
  800ae8:	89 d3                	mov    %edx,%ebx
  800aea:	89 d7                	mov    %edx,%edi
  800aec:	89 d6                	mov    %edx,%esi
  800aee:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800af0:	5b                   	pop    %ebx
  800af1:	5e                   	pop    %esi
  800af2:	5f                   	pop    %edi
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <sys_yield>:

void
sys_yield(void)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	57                   	push   %edi
  800af9:	56                   	push   %esi
  800afa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afb:	ba 00 00 00 00       	mov    $0x0,%edx
  800b00:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b05:	89 d1                	mov    %edx,%ecx
  800b07:	89 d3                	mov    %edx,%ebx
  800b09:	89 d7                	mov    %edx,%edi
  800b0b:	89 d6                	mov    %edx,%esi
  800b0d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b0f:	5b                   	pop    %ebx
  800b10:	5e                   	pop    %esi
  800b11:	5f                   	pop    %edi
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	57                   	push   %edi
  800b18:	56                   	push   %esi
  800b19:	53                   	push   %ebx
  800b1a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1d:	be 00 00 00 00       	mov    $0x0,%esi
  800b22:	b8 04 00 00 00       	mov    $0x4,%eax
  800b27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b30:	89 f7                	mov    %esi,%edi
  800b32:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b34:	85 c0                	test   %eax,%eax
  800b36:	7e 17                	jle    800b4f <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b38:	83 ec 0c             	sub    $0xc,%esp
  800b3b:	50                   	push   %eax
  800b3c:	6a 04                	push   $0x4
  800b3e:	68 5f 21 80 00       	push   $0x80215f
  800b43:	6a 23                	push   $0x23
  800b45:	68 7c 21 80 00       	push   $0x80217c
  800b4a:	e8 c0 0e 00 00       	call   801a0f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5f                   	pop    %edi
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	57                   	push   %edi
  800b5b:	56                   	push   %esi
  800b5c:	53                   	push   %ebx
  800b5d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b60:	b8 05 00 00 00       	mov    $0x5,%eax
  800b65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b68:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b6e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b71:	8b 75 18             	mov    0x18(%ebp),%esi
  800b74:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b76:	85 c0                	test   %eax,%eax
  800b78:	7e 17                	jle    800b91 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7a:	83 ec 0c             	sub    $0xc,%esp
  800b7d:	50                   	push   %eax
  800b7e:	6a 05                	push   $0x5
  800b80:	68 5f 21 80 00       	push   $0x80215f
  800b85:	6a 23                	push   $0x23
  800b87:	68 7c 21 80 00       	push   $0x80217c
  800b8c:	e8 7e 0e 00 00       	call   801a0f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b94:	5b                   	pop    %ebx
  800b95:	5e                   	pop    %esi
  800b96:	5f                   	pop    %edi
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    

00800b99 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	57                   	push   %edi
  800b9d:	56                   	push   %esi
  800b9e:	53                   	push   %ebx
  800b9f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ba7:	b8 06 00 00 00       	mov    $0x6,%eax
  800bac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800baf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb2:	89 df                	mov    %ebx,%edi
  800bb4:	89 de                	mov    %ebx,%esi
  800bb6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb8:	85 c0                	test   %eax,%eax
  800bba:	7e 17                	jle    800bd3 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbc:	83 ec 0c             	sub    $0xc,%esp
  800bbf:	50                   	push   %eax
  800bc0:	6a 06                	push   $0x6
  800bc2:	68 5f 21 80 00       	push   $0x80215f
  800bc7:	6a 23                	push   $0x23
  800bc9:	68 7c 21 80 00       	push   $0x80217c
  800bce:	e8 3c 0e 00 00       	call   801a0f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	57                   	push   %edi
  800bdf:	56                   	push   %esi
  800be0:	53                   	push   %ebx
  800be1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800be9:	b8 08 00 00 00       	mov    $0x8,%eax
  800bee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf4:	89 df                	mov    %ebx,%edi
  800bf6:	89 de                	mov    %ebx,%esi
  800bf8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfa:	85 c0                	test   %eax,%eax
  800bfc:	7e 17                	jle    800c15 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfe:	83 ec 0c             	sub    $0xc,%esp
  800c01:	50                   	push   %eax
  800c02:	6a 08                	push   $0x8
  800c04:	68 5f 21 80 00       	push   $0x80215f
  800c09:	6a 23                	push   $0x23
  800c0b:	68 7c 21 80 00       	push   $0x80217c
  800c10:	e8 fa 0d 00 00       	call   801a0f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c18:	5b                   	pop    %ebx
  800c19:	5e                   	pop    %esi
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    

00800c1d <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	57                   	push   %edi
  800c21:	56                   	push   %esi
  800c22:	53                   	push   %ebx
  800c23:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c26:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2b:	b8 09 00 00 00       	mov    $0x9,%eax
  800c30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c33:	8b 55 08             	mov    0x8(%ebp),%edx
  800c36:	89 df                	mov    %ebx,%edi
  800c38:	89 de                	mov    %ebx,%esi
  800c3a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3c:	85 c0                	test   %eax,%eax
  800c3e:	7e 17                	jle    800c57 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c40:	83 ec 0c             	sub    $0xc,%esp
  800c43:	50                   	push   %eax
  800c44:	6a 09                	push   $0x9
  800c46:	68 5f 21 80 00       	push   $0x80215f
  800c4b:	6a 23                	push   $0x23
  800c4d:	68 7c 21 80 00       	push   $0x80217c
  800c52:	e8 b8 0d 00 00       	call   801a0f <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5a:	5b                   	pop    %ebx
  800c5b:	5e                   	pop    %esi
  800c5c:	5f                   	pop    %edi
  800c5d:	5d                   	pop    %ebp
  800c5e:	c3                   	ret    

00800c5f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	57                   	push   %edi
  800c63:	56                   	push   %esi
  800c64:	53                   	push   %ebx
  800c65:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c68:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c75:	8b 55 08             	mov    0x8(%ebp),%edx
  800c78:	89 df                	mov    %ebx,%edi
  800c7a:	89 de                	mov    %ebx,%esi
  800c7c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7e:	85 c0                	test   %eax,%eax
  800c80:	7e 17                	jle    800c99 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c82:	83 ec 0c             	sub    $0xc,%esp
  800c85:	50                   	push   %eax
  800c86:	6a 0a                	push   $0xa
  800c88:	68 5f 21 80 00       	push   $0x80215f
  800c8d:	6a 23                	push   $0x23
  800c8f:	68 7c 21 80 00       	push   $0x80217c
  800c94:	e8 76 0d 00 00       	call   801a0f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9c:	5b                   	pop    %ebx
  800c9d:	5e                   	pop    %esi
  800c9e:	5f                   	pop    %edi
  800c9f:	5d                   	pop    %ebp
  800ca0:	c3                   	ret    

00800ca1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	57                   	push   %edi
  800ca5:	56                   	push   %esi
  800ca6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca7:	be 00 00 00 00       	mov    $0x0,%esi
  800cac:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cba:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cbd:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
  800cca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd2:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	89 cb                	mov    %ecx,%ebx
  800cdc:	89 cf                	mov    %ecx,%edi
  800cde:	89 ce                	mov    %ecx,%esi
  800ce0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce2:	85 c0                	test   %eax,%eax
  800ce4:	7e 17                	jle    800cfd <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce6:	83 ec 0c             	sub    $0xc,%esp
  800ce9:	50                   	push   %eax
  800cea:	6a 0d                	push   $0xd
  800cec:	68 5f 21 80 00       	push   $0x80215f
  800cf1:	6a 23                	push   $0x23
  800cf3:	68 7c 21 80 00       	push   $0x80217c
  800cf8:	e8 12 0d 00 00       	call   801a0f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d00:	5b                   	pop    %ebx
  800d01:	5e                   	pop    %esi
  800d02:	5f                   	pop    %edi
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    

00800d05 <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	57                   	push   %edi
  800d09:	56                   	push   %esi
  800d0a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d10:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d15:	8b 55 08             	mov    0x8(%ebp),%edx
  800d18:	89 cb                	mov    %ecx,%ebx
  800d1a:	89 cf                	mov    %ecx,%edi
  800d1c:	89 ce                	mov    %ecx,%esi
  800d1e:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5f                   	pop    %edi
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    

00800d25 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d28:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2b:	05 00 00 00 30       	add    $0x30000000,%eax
  800d30:	c1 e8 0c             	shr    $0xc,%eax
}
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    

00800d35 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d38:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3b:	05 00 00 00 30       	add    $0x30000000,%eax
  800d40:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d45:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d52:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d57:	89 c2                	mov    %eax,%edx
  800d59:	c1 ea 16             	shr    $0x16,%edx
  800d5c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d63:	f6 c2 01             	test   $0x1,%dl
  800d66:	74 11                	je     800d79 <fd_alloc+0x2d>
  800d68:	89 c2                	mov    %eax,%edx
  800d6a:	c1 ea 0c             	shr    $0xc,%edx
  800d6d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d74:	f6 c2 01             	test   $0x1,%dl
  800d77:	75 09                	jne    800d82 <fd_alloc+0x36>
			*fd_store = fd;
  800d79:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d80:	eb 17                	jmp    800d99 <fd_alloc+0x4d>
  800d82:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d87:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d8c:	75 c9                	jne    800d57 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d8e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d94:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    

00800d9b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800da1:	83 f8 1f             	cmp    $0x1f,%eax
  800da4:	77 36                	ja     800ddc <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800da6:	c1 e0 0c             	shl    $0xc,%eax
  800da9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dae:	89 c2                	mov    %eax,%edx
  800db0:	c1 ea 16             	shr    $0x16,%edx
  800db3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dba:	f6 c2 01             	test   $0x1,%dl
  800dbd:	74 24                	je     800de3 <fd_lookup+0x48>
  800dbf:	89 c2                	mov    %eax,%edx
  800dc1:	c1 ea 0c             	shr    $0xc,%edx
  800dc4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dcb:	f6 c2 01             	test   $0x1,%dl
  800dce:	74 1a                	je     800dea <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800dd0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dd3:	89 02                	mov    %eax,(%edx)
	return 0;
  800dd5:	b8 00 00 00 00       	mov    $0x0,%eax
  800dda:	eb 13                	jmp    800def <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ddc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800de1:	eb 0c                	jmp    800def <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800de3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800de8:	eb 05                	jmp    800def <fd_lookup+0x54>
  800dea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800def:	5d                   	pop    %ebp
  800df0:	c3                   	ret    

00800df1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800df1:	55                   	push   %ebp
  800df2:	89 e5                	mov    %esp,%ebp
  800df4:	83 ec 08             	sub    $0x8,%esp
  800df7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dfa:	ba 08 22 80 00       	mov    $0x802208,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800dff:	eb 13                	jmp    800e14 <dev_lookup+0x23>
  800e01:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e04:	39 08                	cmp    %ecx,(%eax)
  800e06:	75 0c                	jne    800e14 <dev_lookup+0x23>
			*dev = devtab[i];
  800e08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0b:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e12:	eb 2e                	jmp    800e42 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e14:	8b 02                	mov    (%edx),%eax
  800e16:	85 c0                	test   %eax,%eax
  800e18:	75 e7                	jne    800e01 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e1a:	a1 04 40 80 00       	mov    0x804004,%eax
  800e1f:	8b 40 50             	mov    0x50(%eax),%eax
  800e22:	83 ec 04             	sub    $0x4,%esp
  800e25:	51                   	push   %ecx
  800e26:	50                   	push   %eax
  800e27:	68 8c 21 80 00       	push   $0x80218c
  800e2c:	e8 5b f3 ff ff       	call   80018c <cprintf>
	*dev = 0;
  800e31:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e34:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e3a:	83 c4 10             	add    $0x10,%esp
  800e3d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e42:	c9                   	leave  
  800e43:	c3                   	ret    

00800e44 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	56                   	push   %esi
  800e48:	53                   	push   %ebx
  800e49:	83 ec 10             	sub    $0x10,%esp
  800e4c:	8b 75 08             	mov    0x8(%ebp),%esi
  800e4f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e55:	50                   	push   %eax
  800e56:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e5c:	c1 e8 0c             	shr    $0xc,%eax
  800e5f:	50                   	push   %eax
  800e60:	e8 36 ff ff ff       	call   800d9b <fd_lookup>
  800e65:	83 c4 08             	add    $0x8,%esp
  800e68:	85 c0                	test   %eax,%eax
  800e6a:	78 05                	js     800e71 <fd_close+0x2d>
	    || fd != fd2)
  800e6c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e6f:	74 0c                	je     800e7d <fd_close+0x39>
		return (must_exist ? r : 0);
  800e71:	84 db                	test   %bl,%bl
  800e73:	ba 00 00 00 00       	mov    $0x0,%edx
  800e78:	0f 44 c2             	cmove  %edx,%eax
  800e7b:	eb 41                	jmp    800ebe <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e7d:	83 ec 08             	sub    $0x8,%esp
  800e80:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e83:	50                   	push   %eax
  800e84:	ff 36                	pushl  (%esi)
  800e86:	e8 66 ff ff ff       	call   800df1 <dev_lookup>
  800e8b:	89 c3                	mov    %eax,%ebx
  800e8d:	83 c4 10             	add    $0x10,%esp
  800e90:	85 c0                	test   %eax,%eax
  800e92:	78 1a                	js     800eae <fd_close+0x6a>
		if (dev->dev_close)
  800e94:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e97:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e9a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e9f:	85 c0                	test   %eax,%eax
  800ea1:	74 0b                	je     800eae <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ea3:	83 ec 0c             	sub    $0xc,%esp
  800ea6:	56                   	push   %esi
  800ea7:	ff d0                	call   *%eax
  800ea9:	89 c3                	mov    %eax,%ebx
  800eab:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800eae:	83 ec 08             	sub    $0x8,%esp
  800eb1:	56                   	push   %esi
  800eb2:	6a 00                	push   $0x0
  800eb4:	e8 e0 fc ff ff       	call   800b99 <sys_page_unmap>
	return r;
  800eb9:	83 c4 10             	add    $0x10,%esp
  800ebc:	89 d8                	mov    %ebx,%eax
}
  800ebe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ec1:	5b                   	pop    %ebx
  800ec2:	5e                   	pop    %esi
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    

00800ec5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ec5:	55                   	push   %ebp
  800ec6:	89 e5                	mov    %esp,%ebp
  800ec8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ecb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ece:	50                   	push   %eax
  800ecf:	ff 75 08             	pushl  0x8(%ebp)
  800ed2:	e8 c4 fe ff ff       	call   800d9b <fd_lookup>
  800ed7:	83 c4 08             	add    $0x8,%esp
  800eda:	85 c0                	test   %eax,%eax
  800edc:	78 10                	js     800eee <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ede:	83 ec 08             	sub    $0x8,%esp
  800ee1:	6a 01                	push   $0x1
  800ee3:	ff 75 f4             	pushl  -0xc(%ebp)
  800ee6:	e8 59 ff ff ff       	call   800e44 <fd_close>
  800eeb:	83 c4 10             	add    $0x10,%esp
}
  800eee:	c9                   	leave  
  800eef:	c3                   	ret    

00800ef0 <close_all>:

void
close_all(void)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	53                   	push   %ebx
  800ef4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ef7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800efc:	83 ec 0c             	sub    $0xc,%esp
  800eff:	53                   	push   %ebx
  800f00:	e8 c0 ff ff ff       	call   800ec5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f05:	83 c3 01             	add    $0x1,%ebx
  800f08:	83 c4 10             	add    $0x10,%esp
  800f0b:	83 fb 20             	cmp    $0x20,%ebx
  800f0e:	75 ec                	jne    800efc <close_all+0xc>
		close(i);
}
  800f10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f13:	c9                   	leave  
  800f14:	c3                   	ret    

00800f15 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	57                   	push   %edi
  800f19:	56                   	push   %esi
  800f1a:	53                   	push   %ebx
  800f1b:	83 ec 2c             	sub    $0x2c,%esp
  800f1e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f21:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f24:	50                   	push   %eax
  800f25:	ff 75 08             	pushl  0x8(%ebp)
  800f28:	e8 6e fe ff ff       	call   800d9b <fd_lookup>
  800f2d:	83 c4 08             	add    $0x8,%esp
  800f30:	85 c0                	test   %eax,%eax
  800f32:	0f 88 c1 00 00 00    	js     800ff9 <dup+0xe4>
		return r;
	close(newfdnum);
  800f38:	83 ec 0c             	sub    $0xc,%esp
  800f3b:	56                   	push   %esi
  800f3c:	e8 84 ff ff ff       	call   800ec5 <close>

	newfd = INDEX2FD(newfdnum);
  800f41:	89 f3                	mov    %esi,%ebx
  800f43:	c1 e3 0c             	shl    $0xc,%ebx
  800f46:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f4c:	83 c4 04             	add    $0x4,%esp
  800f4f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f52:	e8 de fd ff ff       	call   800d35 <fd2data>
  800f57:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f59:	89 1c 24             	mov    %ebx,(%esp)
  800f5c:	e8 d4 fd ff ff       	call   800d35 <fd2data>
  800f61:	83 c4 10             	add    $0x10,%esp
  800f64:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f67:	89 f8                	mov    %edi,%eax
  800f69:	c1 e8 16             	shr    $0x16,%eax
  800f6c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f73:	a8 01                	test   $0x1,%al
  800f75:	74 37                	je     800fae <dup+0x99>
  800f77:	89 f8                	mov    %edi,%eax
  800f79:	c1 e8 0c             	shr    $0xc,%eax
  800f7c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f83:	f6 c2 01             	test   $0x1,%dl
  800f86:	74 26                	je     800fae <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f88:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f8f:	83 ec 0c             	sub    $0xc,%esp
  800f92:	25 07 0e 00 00       	and    $0xe07,%eax
  800f97:	50                   	push   %eax
  800f98:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f9b:	6a 00                	push   $0x0
  800f9d:	57                   	push   %edi
  800f9e:	6a 00                	push   $0x0
  800fa0:	e8 b2 fb ff ff       	call   800b57 <sys_page_map>
  800fa5:	89 c7                	mov    %eax,%edi
  800fa7:	83 c4 20             	add    $0x20,%esp
  800faa:	85 c0                	test   %eax,%eax
  800fac:	78 2e                	js     800fdc <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fae:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fb1:	89 d0                	mov    %edx,%eax
  800fb3:	c1 e8 0c             	shr    $0xc,%eax
  800fb6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fbd:	83 ec 0c             	sub    $0xc,%esp
  800fc0:	25 07 0e 00 00       	and    $0xe07,%eax
  800fc5:	50                   	push   %eax
  800fc6:	53                   	push   %ebx
  800fc7:	6a 00                	push   $0x0
  800fc9:	52                   	push   %edx
  800fca:	6a 00                	push   $0x0
  800fcc:	e8 86 fb ff ff       	call   800b57 <sys_page_map>
  800fd1:	89 c7                	mov    %eax,%edi
  800fd3:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800fd6:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fd8:	85 ff                	test   %edi,%edi
  800fda:	79 1d                	jns    800ff9 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fdc:	83 ec 08             	sub    $0x8,%esp
  800fdf:	53                   	push   %ebx
  800fe0:	6a 00                	push   $0x0
  800fe2:	e8 b2 fb ff ff       	call   800b99 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fe7:	83 c4 08             	add    $0x8,%esp
  800fea:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fed:	6a 00                	push   $0x0
  800fef:	e8 a5 fb ff ff       	call   800b99 <sys_page_unmap>
	return r;
  800ff4:	83 c4 10             	add    $0x10,%esp
  800ff7:	89 f8                	mov    %edi,%eax
}
  800ff9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ffc:	5b                   	pop    %ebx
  800ffd:	5e                   	pop    %esi
  800ffe:	5f                   	pop    %edi
  800fff:	5d                   	pop    %ebp
  801000:	c3                   	ret    

00801001 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801001:	55                   	push   %ebp
  801002:	89 e5                	mov    %esp,%ebp
  801004:	53                   	push   %ebx
  801005:	83 ec 14             	sub    $0x14,%esp
  801008:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80100b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80100e:	50                   	push   %eax
  80100f:	53                   	push   %ebx
  801010:	e8 86 fd ff ff       	call   800d9b <fd_lookup>
  801015:	83 c4 08             	add    $0x8,%esp
  801018:	89 c2                	mov    %eax,%edx
  80101a:	85 c0                	test   %eax,%eax
  80101c:	78 6d                	js     80108b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80101e:	83 ec 08             	sub    $0x8,%esp
  801021:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801024:	50                   	push   %eax
  801025:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801028:	ff 30                	pushl  (%eax)
  80102a:	e8 c2 fd ff ff       	call   800df1 <dev_lookup>
  80102f:	83 c4 10             	add    $0x10,%esp
  801032:	85 c0                	test   %eax,%eax
  801034:	78 4c                	js     801082 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801036:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801039:	8b 42 08             	mov    0x8(%edx),%eax
  80103c:	83 e0 03             	and    $0x3,%eax
  80103f:	83 f8 01             	cmp    $0x1,%eax
  801042:	75 21                	jne    801065 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801044:	a1 04 40 80 00       	mov    0x804004,%eax
  801049:	8b 40 50             	mov    0x50(%eax),%eax
  80104c:	83 ec 04             	sub    $0x4,%esp
  80104f:	53                   	push   %ebx
  801050:	50                   	push   %eax
  801051:	68 cd 21 80 00       	push   $0x8021cd
  801056:	e8 31 f1 ff ff       	call   80018c <cprintf>
		return -E_INVAL;
  80105b:	83 c4 10             	add    $0x10,%esp
  80105e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801063:	eb 26                	jmp    80108b <read+0x8a>
	}
	if (!dev->dev_read)
  801065:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801068:	8b 40 08             	mov    0x8(%eax),%eax
  80106b:	85 c0                	test   %eax,%eax
  80106d:	74 17                	je     801086 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80106f:	83 ec 04             	sub    $0x4,%esp
  801072:	ff 75 10             	pushl  0x10(%ebp)
  801075:	ff 75 0c             	pushl  0xc(%ebp)
  801078:	52                   	push   %edx
  801079:	ff d0                	call   *%eax
  80107b:	89 c2                	mov    %eax,%edx
  80107d:	83 c4 10             	add    $0x10,%esp
  801080:	eb 09                	jmp    80108b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801082:	89 c2                	mov    %eax,%edx
  801084:	eb 05                	jmp    80108b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801086:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80108b:	89 d0                	mov    %edx,%eax
  80108d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801090:	c9                   	leave  
  801091:	c3                   	ret    

00801092 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801092:	55                   	push   %ebp
  801093:	89 e5                	mov    %esp,%ebp
  801095:	57                   	push   %edi
  801096:	56                   	push   %esi
  801097:	53                   	push   %ebx
  801098:	83 ec 0c             	sub    $0xc,%esp
  80109b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80109e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010a6:	eb 21                	jmp    8010c9 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010a8:	83 ec 04             	sub    $0x4,%esp
  8010ab:	89 f0                	mov    %esi,%eax
  8010ad:	29 d8                	sub    %ebx,%eax
  8010af:	50                   	push   %eax
  8010b0:	89 d8                	mov    %ebx,%eax
  8010b2:	03 45 0c             	add    0xc(%ebp),%eax
  8010b5:	50                   	push   %eax
  8010b6:	57                   	push   %edi
  8010b7:	e8 45 ff ff ff       	call   801001 <read>
		if (m < 0)
  8010bc:	83 c4 10             	add    $0x10,%esp
  8010bf:	85 c0                	test   %eax,%eax
  8010c1:	78 10                	js     8010d3 <readn+0x41>
			return m;
		if (m == 0)
  8010c3:	85 c0                	test   %eax,%eax
  8010c5:	74 0a                	je     8010d1 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010c7:	01 c3                	add    %eax,%ebx
  8010c9:	39 f3                	cmp    %esi,%ebx
  8010cb:	72 db                	jb     8010a8 <readn+0x16>
  8010cd:	89 d8                	mov    %ebx,%eax
  8010cf:	eb 02                	jmp    8010d3 <readn+0x41>
  8010d1:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d6:	5b                   	pop    %ebx
  8010d7:	5e                   	pop    %esi
  8010d8:	5f                   	pop    %edi
  8010d9:	5d                   	pop    %ebp
  8010da:	c3                   	ret    

008010db <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	53                   	push   %ebx
  8010df:	83 ec 14             	sub    $0x14,%esp
  8010e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010e8:	50                   	push   %eax
  8010e9:	53                   	push   %ebx
  8010ea:	e8 ac fc ff ff       	call   800d9b <fd_lookup>
  8010ef:	83 c4 08             	add    $0x8,%esp
  8010f2:	89 c2                	mov    %eax,%edx
  8010f4:	85 c0                	test   %eax,%eax
  8010f6:	78 68                	js     801160 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010f8:	83 ec 08             	sub    $0x8,%esp
  8010fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010fe:	50                   	push   %eax
  8010ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801102:	ff 30                	pushl  (%eax)
  801104:	e8 e8 fc ff ff       	call   800df1 <dev_lookup>
  801109:	83 c4 10             	add    $0x10,%esp
  80110c:	85 c0                	test   %eax,%eax
  80110e:	78 47                	js     801157 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801110:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801113:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801117:	75 21                	jne    80113a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801119:	a1 04 40 80 00       	mov    0x804004,%eax
  80111e:	8b 40 50             	mov    0x50(%eax),%eax
  801121:	83 ec 04             	sub    $0x4,%esp
  801124:	53                   	push   %ebx
  801125:	50                   	push   %eax
  801126:	68 e9 21 80 00       	push   $0x8021e9
  80112b:	e8 5c f0 ff ff       	call   80018c <cprintf>
		return -E_INVAL;
  801130:	83 c4 10             	add    $0x10,%esp
  801133:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801138:	eb 26                	jmp    801160 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80113a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80113d:	8b 52 0c             	mov    0xc(%edx),%edx
  801140:	85 d2                	test   %edx,%edx
  801142:	74 17                	je     80115b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801144:	83 ec 04             	sub    $0x4,%esp
  801147:	ff 75 10             	pushl  0x10(%ebp)
  80114a:	ff 75 0c             	pushl  0xc(%ebp)
  80114d:	50                   	push   %eax
  80114e:	ff d2                	call   *%edx
  801150:	89 c2                	mov    %eax,%edx
  801152:	83 c4 10             	add    $0x10,%esp
  801155:	eb 09                	jmp    801160 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801157:	89 c2                	mov    %eax,%edx
  801159:	eb 05                	jmp    801160 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80115b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801160:	89 d0                	mov    %edx,%eax
  801162:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801165:	c9                   	leave  
  801166:	c3                   	ret    

00801167 <seek>:

int
seek(int fdnum, off_t offset)
{
  801167:	55                   	push   %ebp
  801168:	89 e5                	mov    %esp,%ebp
  80116a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80116d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801170:	50                   	push   %eax
  801171:	ff 75 08             	pushl  0x8(%ebp)
  801174:	e8 22 fc ff ff       	call   800d9b <fd_lookup>
  801179:	83 c4 08             	add    $0x8,%esp
  80117c:	85 c0                	test   %eax,%eax
  80117e:	78 0e                	js     80118e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801180:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801183:	8b 55 0c             	mov    0xc(%ebp),%edx
  801186:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801189:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80118e:	c9                   	leave  
  80118f:	c3                   	ret    

00801190 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	53                   	push   %ebx
  801194:	83 ec 14             	sub    $0x14,%esp
  801197:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80119a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80119d:	50                   	push   %eax
  80119e:	53                   	push   %ebx
  80119f:	e8 f7 fb ff ff       	call   800d9b <fd_lookup>
  8011a4:	83 c4 08             	add    $0x8,%esp
  8011a7:	89 c2                	mov    %eax,%edx
  8011a9:	85 c0                	test   %eax,%eax
  8011ab:	78 65                	js     801212 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ad:	83 ec 08             	sub    $0x8,%esp
  8011b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b3:	50                   	push   %eax
  8011b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b7:	ff 30                	pushl  (%eax)
  8011b9:	e8 33 fc ff ff       	call   800df1 <dev_lookup>
  8011be:	83 c4 10             	add    $0x10,%esp
  8011c1:	85 c0                	test   %eax,%eax
  8011c3:	78 44                	js     801209 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011cc:	75 21                	jne    8011ef <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011ce:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011d3:	8b 40 50             	mov    0x50(%eax),%eax
  8011d6:	83 ec 04             	sub    $0x4,%esp
  8011d9:	53                   	push   %ebx
  8011da:	50                   	push   %eax
  8011db:	68 ac 21 80 00       	push   $0x8021ac
  8011e0:	e8 a7 ef ff ff       	call   80018c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011e5:	83 c4 10             	add    $0x10,%esp
  8011e8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011ed:	eb 23                	jmp    801212 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011f2:	8b 52 18             	mov    0x18(%edx),%edx
  8011f5:	85 d2                	test   %edx,%edx
  8011f7:	74 14                	je     80120d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011f9:	83 ec 08             	sub    $0x8,%esp
  8011fc:	ff 75 0c             	pushl  0xc(%ebp)
  8011ff:	50                   	push   %eax
  801200:	ff d2                	call   *%edx
  801202:	89 c2                	mov    %eax,%edx
  801204:	83 c4 10             	add    $0x10,%esp
  801207:	eb 09                	jmp    801212 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801209:	89 c2                	mov    %eax,%edx
  80120b:	eb 05                	jmp    801212 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80120d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801212:	89 d0                	mov    %edx,%eax
  801214:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801217:	c9                   	leave  
  801218:	c3                   	ret    

00801219 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801219:	55                   	push   %ebp
  80121a:	89 e5                	mov    %esp,%ebp
  80121c:	53                   	push   %ebx
  80121d:	83 ec 14             	sub    $0x14,%esp
  801220:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801223:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801226:	50                   	push   %eax
  801227:	ff 75 08             	pushl  0x8(%ebp)
  80122a:	e8 6c fb ff ff       	call   800d9b <fd_lookup>
  80122f:	83 c4 08             	add    $0x8,%esp
  801232:	89 c2                	mov    %eax,%edx
  801234:	85 c0                	test   %eax,%eax
  801236:	78 58                	js     801290 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801238:	83 ec 08             	sub    $0x8,%esp
  80123b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80123e:	50                   	push   %eax
  80123f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801242:	ff 30                	pushl  (%eax)
  801244:	e8 a8 fb ff ff       	call   800df1 <dev_lookup>
  801249:	83 c4 10             	add    $0x10,%esp
  80124c:	85 c0                	test   %eax,%eax
  80124e:	78 37                	js     801287 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801250:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801253:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801257:	74 32                	je     80128b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801259:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80125c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801263:	00 00 00 
	stat->st_isdir = 0;
  801266:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80126d:	00 00 00 
	stat->st_dev = dev;
  801270:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801276:	83 ec 08             	sub    $0x8,%esp
  801279:	53                   	push   %ebx
  80127a:	ff 75 f0             	pushl  -0x10(%ebp)
  80127d:	ff 50 14             	call   *0x14(%eax)
  801280:	89 c2                	mov    %eax,%edx
  801282:	83 c4 10             	add    $0x10,%esp
  801285:	eb 09                	jmp    801290 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801287:	89 c2                	mov    %eax,%edx
  801289:	eb 05                	jmp    801290 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80128b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801290:	89 d0                	mov    %edx,%eax
  801292:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801295:	c9                   	leave  
  801296:	c3                   	ret    

00801297 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801297:	55                   	push   %ebp
  801298:	89 e5                	mov    %esp,%ebp
  80129a:	56                   	push   %esi
  80129b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80129c:	83 ec 08             	sub    $0x8,%esp
  80129f:	6a 00                	push   $0x0
  8012a1:	ff 75 08             	pushl  0x8(%ebp)
  8012a4:	e8 e3 01 00 00       	call   80148c <open>
  8012a9:	89 c3                	mov    %eax,%ebx
  8012ab:	83 c4 10             	add    $0x10,%esp
  8012ae:	85 c0                	test   %eax,%eax
  8012b0:	78 1b                	js     8012cd <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012b2:	83 ec 08             	sub    $0x8,%esp
  8012b5:	ff 75 0c             	pushl  0xc(%ebp)
  8012b8:	50                   	push   %eax
  8012b9:	e8 5b ff ff ff       	call   801219 <fstat>
  8012be:	89 c6                	mov    %eax,%esi
	close(fd);
  8012c0:	89 1c 24             	mov    %ebx,(%esp)
  8012c3:	e8 fd fb ff ff       	call   800ec5 <close>
	return r;
  8012c8:	83 c4 10             	add    $0x10,%esp
  8012cb:	89 f0                	mov    %esi,%eax
}
  8012cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012d0:	5b                   	pop    %ebx
  8012d1:	5e                   	pop    %esi
  8012d2:	5d                   	pop    %ebp
  8012d3:	c3                   	ret    

008012d4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
  8012d7:	56                   	push   %esi
  8012d8:	53                   	push   %ebx
  8012d9:	89 c6                	mov    %eax,%esi
  8012db:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012dd:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012e4:	75 12                	jne    8012f8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012e6:	83 ec 0c             	sub    $0xc,%esp
  8012e9:	6a 01                	push   $0x1
  8012eb:	e8 3c 08 00 00       	call   801b2c <ipc_find_env>
  8012f0:	a3 00 40 80 00       	mov    %eax,0x804000
  8012f5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012f8:	6a 07                	push   $0x7
  8012fa:	68 00 50 80 00       	push   $0x805000
  8012ff:	56                   	push   %esi
  801300:	ff 35 00 40 80 00    	pushl  0x804000
  801306:	e8 bf 07 00 00       	call   801aca <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80130b:	83 c4 0c             	add    $0xc,%esp
  80130e:	6a 00                	push   $0x0
  801310:	53                   	push   %ebx
  801311:	6a 00                	push   $0x0
  801313:	e8 3d 07 00 00       	call   801a55 <ipc_recv>
}
  801318:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80131b:	5b                   	pop    %ebx
  80131c:	5e                   	pop    %esi
  80131d:	5d                   	pop    %ebp
  80131e:	c3                   	ret    

0080131f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80131f:	55                   	push   %ebp
  801320:	89 e5                	mov    %esp,%ebp
  801322:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801325:	8b 45 08             	mov    0x8(%ebp),%eax
  801328:	8b 40 0c             	mov    0xc(%eax),%eax
  80132b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801330:	8b 45 0c             	mov    0xc(%ebp),%eax
  801333:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801338:	ba 00 00 00 00       	mov    $0x0,%edx
  80133d:	b8 02 00 00 00       	mov    $0x2,%eax
  801342:	e8 8d ff ff ff       	call   8012d4 <fsipc>
}
  801347:	c9                   	leave  
  801348:	c3                   	ret    

00801349 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801349:	55                   	push   %ebp
  80134a:	89 e5                	mov    %esp,%ebp
  80134c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80134f:	8b 45 08             	mov    0x8(%ebp),%eax
  801352:	8b 40 0c             	mov    0xc(%eax),%eax
  801355:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80135a:	ba 00 00 00 00       	mov    $0x0,%edx
  80135f:	b8 06 00 00 00       	mov    $0x6,%eax
  801364:	e8 6b ff ff ff       	call   8012d4 <fsipc>
}
  801369:	c9                   	leave  
  80136a:	c3                   	ret    

0080136b <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80136b:	55                   	push   %ebp
  80136c:	89 e5                	mov    %esp,%ebp
  80136e:	53                   	push   %ebx
  80136f:	83 ec 04             	sub    $0x4,%esp
  801372:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801375:	8b 45 08             	mov    0x8(%ebp),%eax
  801378:	8b 40 0c             	mov    0xc(%eax),%eax
  80137b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801380:	ba 00 00 00 00       	mov    $0x0,%edx
  801385:	b8 05 00 00 00       	mov    $0x5,%eax
  80138a:	e8 45 ff ff ff       	call   8012d4 <fsipc>
  80138f:	85 c0                	test   %eax,%eax
  801391:	78 2c                	js     8013bf <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801393:	83 ec 08             	sub    $0x8,%esp
  801396:	68 00 50 80 00       	push   $0x805000
  80139b:	53                   	push   %ebx
  80139c:	e8 70 f3 ff ff       	call   800711 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013a1:	a1 80 50 80 00       	mov    0x805080,%eax
  8013a6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013ac:	a1 84 50 80 00       	mov    0x805084,%eax
  8013b1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013b7:	83 c4 10             	add    $0x10,%esp
  8013ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c2:	c9                   	leave  
  8013c3:	c3                   	ret    

008013c4 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013c4:	55                   	push   %ebp
  8013c5:	89 e5                	mov    %esp,%ebp
  8013c7:	83 ec 0c             	sub    $0xc,%esp
  8013ca:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8013d0:	8b 52 0c             	mov    0xc(%edx),%edx
  8013d3:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8013d9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8013de:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8013e3:	0f 47 c2             	cmova  %edx,%eax
  8013e6:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8013eb:	50                   	push   %eax
  8013ec:	ff 75 0c             	pushl  0xc(%ebp)
  8013ef:	68 08 50 80 00       	push   $0x805008
  8013f4:	e8 aa f4 ff ff       	call   8008a3 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8013f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8013fe:	b8 04 00 00 00       	mov    $0x4,%eax
  801403:	e8 cc fe ff ff       	call   8012d4 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801408:	c9                   	leave  
  801409:	c3                   	ret    

0080140a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	56                   	push   %esi
  80140e:	53                   	push   %ebx
  80140f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801412:	8b 45 08             	mov    0x8(%ebp),%eax
  801415:	8b 40 0c             	mov    0xc(%eax),%eax
  801418:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80141d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801423:	ba 00 00 00 00       	mov    $0x0,%edx
  801428:	b8 03 00 00 00       	mov    $0x3,%eax
  80142d:	e8 a2 fe ff ff       	call   8012d4 <fsipc>
  801432:	89 c3                	mov    %eax,%ebx
  801434:	85 c0                	test   %eax,%eax
  801436:	78 4b                	js     801483 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801438:	39 c6                	cmp    %eax,%esi
  80143a:	73 16                	jae    801452 <devfile_read+0x48>
  80143c:	68 18 22 80 00       	push   $0x802218
  801441:	68 1f 22 80 00       	push   $0x80221f
  801446:	6a 7c                	push   $0x7c
  801448:	68 34 22 80 00       	push   $0x802234
  80144d:	e8 bd 05 00 00       	call   801a0f <_panic>
	assert(r <= PGSIZE);
  801452:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801457:	7e 16                	jle    80146f <devfile_read+0x65>
  801459:	68 3f 22 80 00       	push   $0x80223f
  80145e:	68 1f 22 80 00       	push   $0x80221f
  801463:	6a 7d                	push   $0x7d
  801465:	68 34 22 80 00       	push   $0x802234
  80146a:	e8 a0 05 00 00       	call   801a0f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80146f:	83 ec 04             	sub    $0x4,%esp
  801472:	50                   	push   %eax
  801473:	68 00 50 80 00       	push   $0x805000
  801478:	ff 75 0c             	pushl  0xc(%ebp)
  80147b:	e8 23 f4 ff ff       	call   8008a3 <memmove>
	return r;
  801480:	83 c4 10             	add    $0x10,%esp
}
  801483:	89 d8                	mov    %ebx,%eax
  801485:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801488:	5b                   	pop    %ebx
  801489:	5e                   	pop    %esi
  80148a:	5d                   	pop    %ebp
  80148b:	c3                   	ret    

0080148c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80148c:	55                   	push   %ebp
  80148d:	89 e5                	mov    %esp,%ebp
  80148f:	53                   	push   %ebx
  801490:	83 ec 20             	sub    $0x20,%esp
  801493:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801496:	53                   	push   %ebx
  801497:	e8 3c f2 ff ff       	call   8006d8 <strlen>
  80149c:	83 c4 10             	add    $0x10,%esp
  80149f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014a4:	7f 67                	jg     80150d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014a6:	83 ec 0c             	sub    $0xc,%esp
  8014a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ac:	50                   	push   %eax
  8014ad:	e8 9a f8 ff ff       	call   800d4c <fd_alloc>
  8014b2:	83 c4 10             	add    $0x10,%esp
		return r;
  8014b5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014b7:	85 c0                	test   %eax,%eax
  8014b9:	78 57                	js     801512 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014bb:	83 ec 08             	sub    $0x8,%esp
  8014be:	53                   	push   %ebx
  8014bf:	68 00 50 80 00       	push   $0x805000
  8014c4:	e8 48 f2 ff ff       	call   800711 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014cc:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8014d9:	e8 f6 fd ff ff       	call   8012d4 <fsipc>
  8014de:	89 c3                	mov    %eax,%ebx
  8014e0:	83 c4 10             	add    $0x10,%esp
  8014e3:	85 c0                	test   %eax,%eax
  8014e5:	79 14                	jns    8014fb <open+0x6f>
		fd_close(fd, 0);
  8014e7:	83 ec 08             	sub    $0x8,%esp
  8014ea:	6a 00                	push   $0x0
  8014ec:	ff 75 f4             	pushl  -0xc(%ebp)
  8014ef:	e8 50 f9 ff ff       	call   800e44 <fd_close>
		return r;
  8014f4:	83 c4 10             	add    $0x10,%esp
  8014f7:	89 da                	mov    %ebx,%edx
  8014f9:	eb 17                	jmp    801512 <open+0x86>
	}

	return fd2num(fd);
  8014fb:	83 ec 0c             	sub    $0xc,%esp
  8014fe:	ff 75 f4             	pushl  -0xc(%ebp)
  801501:	e8 1f f8 ff ff       	call   800d25 <fd2num>
  801506:	89 c2                	mov    %eax,%edx
  801508:	83 c4 10             	add    $0x10,%esp
  80150b:	eb 05                	jmp    801512 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80150d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801512:	89 d0                	mov    %edx,%eax
  801514:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801517:	c9                   	leave  
  801518:	c3                   	ret    

00801519 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801519:	55                   	push   %ebp
  80151a:	89 e5                	mov    %esp,%ebp
  80151c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80151f:	ba 00 00 00 00       	mov    $0x0,%edx
  801524:	b8 08 00 00 00       	mov    $0x8,%eax
  801529:	e8 a6 fd ff ff       	call   8012d4 <fsipc>
}
  80152e:	c9                   	leave  
  80152f:	c3                   	ret    

00801530 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	56                   	push   %esi
  801534:	53                   	push   %ebx
  801535:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801538:	83 ec 0c             	sub    $0xc,%esp
  80153b:	ff 75 08             	pushl  0x8(%ebp)
  80153e:	e8 f2 f7 ff ff       	call   800d35 <fd2data>
  801543:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801545:	83 c4 08             	add    $0x8,%esp
  801548:	68 4b 22 80 00       	push   $0x80224b
  80154d:	53                   	push   %ebx
  80154e:	e8 be f1 ff ff       	call   800711 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801553:	8b 46 04             	mov    0x4(%esi),%eax
  801556:	2b 06                	sub    (%esi),%eax
  801558:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80155e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801565:	00 00 00 
	stat->st_dev = &devpipe;
  801568:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80156f:	30 80 00 
	return 0;
}
  801572:	b8 00 00 00 00       	mov    $0x0,%eax
  801577:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80157a:	5b                   	pop    %ebx
  80157b:	5e                   	pop    %esi
  80157c:	5d                   	pop    %ebp
  80157d:	c3                   	ret    

0080157e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80157e:	55                   	push   %ebp
  80157f:	89 e5                	mov    %esp,%ebp
  801581:	53                   	push   %ebx
  801582:	83 ec 0c             	sub    $0xc,%esp
  801585:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801588:	53                   	push   %ebx
  801589:	6a 00                	push   $0x0
  80158b:	e8 09 f6 ff ff       	call   800b99 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801590:	89 1c 24             	mov    %ebx,(%esp)
  801593:	e8 9d f7 ff ff       	call   800d35 <fd2data>
  801598:	83 c4 08             	add    $0x8,%esp
  80159b:	50                   	push   %eax
  80159c:	6a 00                	push   $0x0
  80159e:	e8 f6 f5 ff ff       	call   800b99 <sys_page_unmap>
}
  8015a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a6:	c9                   	leave  
  8015a7:	c3                   	ret    

008015a8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015a8:	55                   	push   %ebp
  8015a9:	89 e5                	mov    %esp,%ebp
  8015ab:	57                   	push   %edi
  8015ac:	56                   	push   %esi
  8015ad:	53                   	push   %ebx
  8015ae:	83 ec 1c             	sub    $0x1c,%esp
  8015b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015b4:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015b6:	a1 04 40 80 00       	mov    0x804004,%eax
  8015bb:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015be:	83 ec 0c             	sub    $0xc,%esp
  8015c1:	ff 75 e0             	pushl  -0x20(%ebp)
  8015c4:	e8 a3 05 00 00       	call   801b6c <pageref>
  8015c9:	89 c3                	mov    %eax,%ebx
  8015cb:	89 3c 24             	mov    %edi,(%esp)
  8015ce:	e8 99 05 00 00       	call   801b6c <pageref>
  8015d3:	83 c4 10             	add    $0x10,%esp
  8015d6:	39 c3                	cmp    %eax,%ebx
  8015d8:	0f 94 c1             	sete   %cl
  8015db:	0f b6 c9             	movzbl %cl,%ecx
  8015de:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8015e1:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8015e7:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  8015ea:	39 ce                	cmp    %ecx,%esi
  8015ec:	74 1b                	je     801609 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8015ee:	39 c3                	cmp    %eax,%ebx
  8015f0:	75 c4                	jne    8015b6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015f2:	8b 42 60             	mov    0x60(%edx),%eax
  8015f5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015f8:	50                   	push   %eax
  8015f9:	56                   	push   %esi
  8015fa:	68 52 22 80 00       	push   $0x802252
  8015ff:	e8 88 eb ff ff       	call   80018c <cprintf>
  801604:	83 c4 10             	add    $0x10,%esp
  801607:	eb ad                	jmp    8015b6 <_pipeisclosed+0xe>
	}
}
  801609:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80160c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80160f:	5b                   	pop    %ebx
  801610:	5e                   	pop    %esi
  801611:	5f                   	pop    %edi
  801612:	5d                   	pop    %ebp
  801613:	c3                   	ret    

00801614 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	57                   	push   %edi
  801618:	56                   	push   %esi
  801619:	53                   	push   %ebx
  80161a:	83 ec 28             	sub    $0x28,%esp
  80161d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801620:	56                   	push   %esi
  801621:	e8 0f f7 ff ff       	call   800d35 <fd2data>
  801626:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801628:	83 c4 10             	add    $0x10,%esp
  80162b:	bf 00 00 00 00       	mov    $0x0,%edi
  801630:	eb 4b                	jmp    80167d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801632:	89 da                	mov    %ebx,%edx
  801634:	89 f0                	mov    %esi,%eax
  801636:	e8 6d ff ff ff       	call   8015a8 <_pipeisclosed>
  80163b:	85 c0                	test   %eax,%eax
  80163d:	75 48                	jne    801687 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80163f:	e8 b1 f4 ff ff       	call   800af5 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801644:	8b 43 04             	mov    0x4(%ebx),%eax
  801647:	8b 0b                	mov    (%ebx),%ecx
  801649:	8d 51 20             	lea    0x20(%ecx),%edx
  80164c:	39 d0                	cmp    %edx,%eax
  80164e:	73 e2                	jae    801632 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801650:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801653:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801657:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80165a:	89 c2                	mov    %eax,%edx
  80165c:	c1 fa 1f             	sar    $0x1f,%edx
  80165f:	89 d1                	mov    %edx,%ecx
  801661:	c1 e9 1b             	shr    $0x1b,%ecx
  801664:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801667:	83 e2 1f             	and    $0x1f,%edx
  80166a:	29 ca                	sub    %ecx,%edx
  80166c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801670:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801674:	83 c0 01             	add    $0x1,%eax
  801677:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80167a:	83 c7 01             	add    $0x1,%edi
  80167d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801680:	75 c2                	jne    801644 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801682:	8b 45 10             	mov    0x10(%ebp),%eax
  801685:	eb 05                	jmp    80168c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801687:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80168c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80168f:	5b                   	pop    %ebx
  801690:	5e                   	pop    %esi
  801691:	5f                   	pop    %edi
  801692:	5d                   	pop    %ebp
  801693:	c3                   	ret    

00801694 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801694:	55                   	push   %ebp
  801695:	89 e5                	mov    %esp,%ebp
  801697:	57                   	push   %edi
  801698:	56                   	push   %esi
  801699:	53                   	push   %ebx
  80169a:	83 ec 18             	sub    $0x18,%esp
  80169d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016a0:	57                   	push   %edi
  8016a1:	e8 8f f6 ff ff       	call   800d35 <fd2data>
  8016a6:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016a8:	83 c4 10             	add    $0x10,%esp
  8016ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016b0:	eb 3d                	jmp    8016ef <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8016b2:	85 db                	test   %ebx,%ebx
  8016b4:	74 04                	je     8016ba <devpipe_read+0x26>
				return i;
  8016b6:	89 d8                	mov    %ebx,%eax
  8016b8:	eb 44                	jmp    8016fe <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016ba:	89 f2                	mov    %esi,%edx
  8016bc:	89 f8                	mov    %edi,%eax
  8016be:	e8 e5 fe ff ff       	call   8015a8 <_pipeisclosed>
  8016c3:	85 c0                	test   %eax,%eax
  8016c5:	75 32                	jne    8016f9 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016c7:	e8 29 f4 ff ff       	call   800af5 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016cc:	8b 06                	mov    (%esi),%eax
  8016ce:	3b 46 04             	cmp    0x4(%esi),%eax
  8016d1:	74 df                	je     8016b2 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016d3:	99                   	cltd   
  8016d4:	c1 ea 1b             	shr    $0x1b,%edx
  8016d7:	01 d0                	add    %edx,%eax
  8016d9:	83 e0 1f             	and    $0x1f,%eax
  8016dc:	29 d0                	sub    %edx,%eax
  8016de:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016e6:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016e9:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016ec:	83 c3 01             	add    $0x1,%ebx
  8016ef:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016f2:	75 d8                	jne    8016cc <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8016f7:	eb 05                	jmp    8016fe <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016f9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801701:	5b                   	pop    %ebx
  801702:	5e                   	pop    %esi
  801703:	5f                   	pop    %edi
  801704:	5d                   	pop    %ebp
  801705:	c3                   	ret    

00801706 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801706:	55                   	push   %ebp
  801707:	89 e5                	mov    %esp,%ebp
  801709:	56                   	push   %esi
  80170a:	53                   	push   %ebx
  80170b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80170e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801711:	50                   	push   %eax
  801712:	e8 35 f6 ff ff       	call   800d4c <fd_alloc>
  801717:	83 c4 10             	add    $0x10,%esp
  80171a:	89 c2                	mov    %eax,%edx
  80171c:	85 c0                	test   %eax,%eax
  80171e:	0f 88 2c 01 00 00    	js     801850 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801724:	83 ec 04             	sub    $0x4,%esp
  801727:	68 07 04 00 00       	push   $0x407
  80172c:	ff 75 f4             	pushl  -0xc(%ebp)
  80172f:	6a 00                	push   $0x0
  801731:	e8 de f3 ff ff       	call   800b14 <sys_page_alloc>
  801736:	83 c4 10             	add    $0x10,%esp
  801739:	89 c2                	mov    %eax,%edx
  80173b:	85 c0                	test   %eax,%eax
  80173d:	0f 88 0d 01 00 00    	js     801850 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801743:	83 ec 0c             	sub    $0xc,%esp
  801746:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801749:	50                   	push   %eax
  80174a:	e8 fd f5 ff ff       	call   800d4c <fd_alloc>
  80174f:	89 c3                	mov    %eax,%ebx
  801751:	83 c4 10             	add    $0x10,%esp
  801754:	85 c0                	test   %eax,%eax
  801756:	0f 88 e2 00 00 00    	js     80183e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80175c:	83 ec 04             	sub    $0x4,%esp
  80175f:	68 07 04 00 00       	push   $0x407
  801764:	ff 75 f0             	pushl  -0x10(%ebp)
  801767:	6a 00                	push   $0x0
  801769:	e8 a6 f3 ff ff       	call   800b14 <sys_page_alloc>
  80176e:	89 c3                	mov    %eax,%ebx
  801770:	83 c4 10             	add    $0x10,%esp
  801773:	85 c0                	test   %eax,%eax
  801775:	0f 88 c3 00 00 00    	js     80183e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80177b:	83 ec 0c             	sub    $0xc,%esp
  80177e:	ff 75 f4             	pushl  -0xc(%ebp)
  801781:	e8 af f5 ff ff       	call   800d35 <fd2data>
  801786:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801788:	83 c4 0c             	add    $0xc,%esp
  80178b:	68 07 04 00 00       	push   $0x407
  801790:	50                   	push   %eax
  801791:	6a 00                	push   $0x0
  801793:	e8 7c f3 ff ff       	call   800b14 <sys_page_alloc>
  801798:	89 c3                	mov    %eax,%ebx
  80179a:	83 c4 10             	add    $0x10,%esp
  80179d:	85 c0                	test   %eax,%eax
  80179f:	0f 88 89 00 00 00    	js     80182e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017a5:	83 ec 0c             	sub    $0xc,%esp
  8017a8:	ff 75 f0             	pushl  -0x10(%ebp)
  8017ab:	e8 85 f5 ff ff       	call   800d35 <fd2data>
  8017b0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017b7:	50                   	push   %eax
  8017b8:	6a 00                	push   $0x0
  8017ba:	56                   	push   %esi
  8017bb:	6a 00                	push   $0x0
  8017bd:	e8 95 f3 ff ff       	call   800b57 <sys_page_map>
  8017c2:	89 c3                	mov    %eax,%ebx
  8017c4:	83 c4 20             	add    $0x20,%esp
  8017c7:	85 c0                	test   %eax,%eax
  8017c9:	78 55                	js     801820 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017cb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017e0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ee:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017f5:	83 ec 0c             	sub    $0xc,%esp
  8017f8:	ff 75 f4             	pushl  -0xc(%ebp)
  8017fb:	e8 25 f5 ff ff       	call   800d25 <fd2num>
  801800:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801803:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801805:	83 c4 04             	add    $0x4,%esp
  801808:	ff 75 f0             	pushl  -0x10(%ebp)
  80180b:	e8 15 f5 ff ff       	call   800d25 <fd2num>
  801810:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801813:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801816:	83 c4 10             	add    $0x10,%esp
  801819:	ba 00 00 00 00       	mov    $0x0,%edx
  80181e:	eb 30                	jmp    801850 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801820:	83 ec 08             	sub    $0x8,%esp
  801823:	56                   	push   %esi
  801824:	6a 00                	push   $0x0
  801826:	e8 6e f3 ff ff       	call   800b99 <sys_page_unmap>
  80182b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80182e:	83 ec 08             	sub    $0x8,%esp
  801831:	ff 75 f0             	pushl  -0x10(%ebp)
  801834:	6a 00                	push   $0x0
  801836:	e8 5e f3 ff ff       	call   800b99 <sys_page_unmap>
  80183b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80183e:	83 ec 08             	sub    $0x8,%esp
  801841:	ff 75 f4             	pushl  -0xc(%ebp)
  801844:	6a 00                	push   $0x0
  801846:	e8 4e f3 ff ff       	call   800b99 <sys_page_unmap>
  80184b:	83 c4 10             	add    $0x10,%esp
  80184e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801850:	89 d0                	mov    %edx,%eax
  801852:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801855:	5b                   	pop    %ebx
  801856:	5e                   	pop    %esi
  801857:	5d                   	pop    %ebp
  801858:	c3                   	ret    

00801859 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801859:	55                   	push   %ebp
  80185a:	89 e5                	mov    %esp,%ebp
  80185c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80185f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801862:	50                   	push   %eax
  801863:	ff 75 08             	pushl  0x8(%ebp)
  801866:	e8 30 f5 ff ff       	call   800d9b <fd_lookup>
  80186b:	83 c4 10             	add    $0x10,%esp
  80186e:	85 c0                	test   %eax,%eax
  801870:	78 18                	js     80188a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801872:	83 ec 0c             	sub    $0xc,%esp
  801875:	ff 75 f4             	pushl  -0xc(%ebp)
  801878:	e8 b8 f4 ff ff       	call   800d35 <fd2data>
	return _pipeisclosed(fd, p);
  80187d:	89 c2                	mov    %eax,%edx
  80187f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801882:	e8 21 fd ff ff       	call   8015a8 <_pipeisclosed>
  801887:	83 c4 10             	add    $0x10,%esp
}
  80188a:	c9                   	leave  
  80188b:	c3                   	ret    

0080188c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80188c:	55                   	push   %ebp
  80188d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80188f:	b8 00 00 00 00       	mov    $0x0,%eax
  801894:	5d                   	pop    %ebp
  801895:	c3                   	ret    

00801896 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801896:	55                   	push   %ebp
  801897:	89 e5                	mov    %esp,%ebp
  801899:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80189c:	68 6a 22 80 00       	push   $0x80226a
  8018a1:	ff 75 0c             	pushl  0xc(%ebp)
  8018a4:	e8 68 ee ff ff       	call   800711 <strcpy>
	return 0;
}
  8018a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ae:	c9                   	leave  
  8018af:	c3                   	ret    

008018b0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018b0:	55                   	push   %ebp
  8018b1:	89 e5                	mov    %esp,%ebp
  8018b3:	57                   	push   %edi
  8018b4:	56                   	push   %esi
  8018b5:	53                   	push   %ebx
  8018b6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018bc:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018c1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018c7:	eb 2d                	jmp    8018f6 <devcons_write+0x46>
		m = n - tot;
  8018c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018cc:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8018ce:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018d1:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8018d6:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018d9:	83 ec 04             	sub    $0x4,%esp
  8018dc:	53                   	push   %ebx
  8018dd:	03 45 0c             	add    0xc(%ebp),%eax
  8018e0:	50                   	push   %eax
  8018e1:	57                   	push   %edi
  8018e2:	e8 bc ef ff ff       	call   8008a3 <memmove>
		sys_cputs(buf, m);
  8018e7:	83 c4 08             	add    $0x8,%esp
  8018ea:	53                   	push   %ebx
  8018eb:	57                   	push   %edi
  8018ec:	e8 67 f1 ff ff       	call   800a58 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018f1:	01 de                	add    %ebx,%esi
  8018f3:	83 c4 10             	add    $0x10,%esp
  8018f6:	89 f0                	mov    %esi,%eax
  8018f8:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018fb:	72 cc                	jb     8018c9 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8018fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801900:	5b                   	pop    %ebx
  801901:	5e                   	pop    %esi
  801902:	5f                   	pop    %edi
  801903:	5d                   	pop    %ebp
  801904:	c3                   	ret    

00801905 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801905:	55                   	push   %ebp
  801906:	89 e5                	mov    %esp,%ebp
  801908:	83 ec 08             	sub    $0x8,%esp
  80190b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801910:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801914:	74 2a                	je     801940 <devcons_read+0x3b>
  801916:	eb 05                	jmp    80191d <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801918:	e8 d8 f1 ff ff       	call   800af5 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80191d:	e8 54 f1 ff ff       	call   800a76 <sys_cgetc>
  801922:	85 c0                	test   %eax,%eax
  801924:	74 f2                	je     801918 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801926:	85 c0                	test   %eax,%eax
  801928:	78 16                	js     801940 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80192a:	83 f8 04             	cmp    $0x4,%eax
  80192d:	74 0c                	je     80193b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80192f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801932:	88 02                	mov    %al,(%edx)
	return 1;
  801934:	b8 01 00 00 00       	mov    $0x1,%eax
  801939:	eb 05                	jmp    801940 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80193b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801940:	c9                   	leave  
  801941:	c3                   	ret    

00801942 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801942:	55                   	push   %ebp
  801943:	89 e5                	mov    %esp,%ebp
  801945:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801948:	8b 45 08             	mov    0x8(%ebp),%eax
  80194b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80194e:	6a 01                	push   $0x1
  801950:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801953:	50                   	push   %eax
  801954:	e8 ff f0 ff ff       	call   800a58 <sys_cputs>
}
  801959:	83 c4 10             	add    $0x10,%esp
  80195c:	c9                   	leave  
  80195d:	c3                   	ret    

0080195e <getchar>:

int
getchar(void)
{
  80195e:	55                   	push   %ebp
  80195f:	89 e5                	mov    %esp,%ebp
  801961:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801964:	6a 01                	push   $0x1
  801966:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801969:	50                   	push   %eax
  80196a:	6a 00                	push   $0x0
  80196c:	e8 90 f6 ff ff       	call   801001 <read>
	if (r < 0)
  801971:	83 c4 10             	add    $0x10,%esp
  801974:	85 c0                	test   %eax,%eax
  801976:	78 0f                	js     801987 <getchar+0x29>
		return r;
	if (r < 1)
  801978:	85 c0                	test   %eax,%eax
  80197a:	7e 06                	jle    801982 <getchar+0x24>
		return -E_EOF;
	return c;
  80197c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801980:	eb 05                	jmp    801987 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801982:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801987:	c9                   	leave  
  801988:	c3                   	ret    

00801989 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801989:	55                   	push   %ebp
  80198a:	89 e5                	mov    %esp,%ebp
  80198c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80198f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801992:	50                   	push   %eax
  801993:	ff 75 08             	pushl  0x8(%ebp)
  801996:	e8 00 f4 ff ff       	call   800d9b <fd_lookup>
  80199b:	83 c4 10             	add    $0x10,%esp
  80199e:	85 c0                	test   %eax,%eax
  8019a0:	78 11                	js     8019b3 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8019a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019ab:	39 10                	cmp    %edx,(%eax)
  8019ad:	0f 94 c0             	sete   %al
  8019b0:	0f b6 c0             	movzbl %al,%eax
}
  8019b3:	c9                   	leave  
  8019b4:	c3                   	ret    

008019b5 <opencons>:

int
opencons(void)
{
  8019b5:	55                   	push   %ebp
  8019b6:	89 e5                	mov    %esp,%ebp
  8019b8:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019be:	50                   	push   %eax
  8019bf:	e8 88 f3 ff ff       	call   800d4c <fd_alloc>
  8019c4:	83 c4 10             	add    $0x10,%esp
		return r;
  8019c7:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019c9:	85 c0                	test   %eax,%eax
  8019cb:	78 3e                	js     801a0b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019cd:	83 ec 04             	sub    $0x4,%esp
  8019d0:	68 07 04 00 00       	push   $0x407
  8019d5:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d8:	6a 00                	push   $0x0
  8019da:	e8 35 f1 ff ff       	call   800b14 <sys_page_alloc>
  8019df:	83 c4 10             	add    $0x10,%esp
		return r;
  8019e2:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019e4:	85 c0                	test   %eax,%eax
  8019e6:	78 23                	js     801a0b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8019e8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019fd:	83 ec 0c             	sub    $0xc,%esp
  801a00:	50                   	push   %eax
  801a01:	e8 1f f3 ff ff       	call   800d25 <fd2num>
  801a06:	89 c2                	mov    %eax,%edx
  801a08:	83 c4 10             	add    $0x10,%esp
}
  801a0b:	89 d0                	mov    %edx,%eax
  801a0d:	c9                   	leave  
  801a0e:	c3                   	ret    

00801a0f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a0f:	55                   	push   %ebp
  801a10:	89 e5                	mov    %esp,%ebp
  801a12:	56                   	push   %esi
  801a13:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a14:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a17:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a1d:	e8 b4 f0 ff ff       	call   800ad6 <sys_getenvid>
  801a22:	83 ec 0c             	sub    $0xc,%esp
  801a25:	ff 75 0c             	pushl  0xc(%ebp)
  801a28:	ff 75 08             	pushl  0x8(%ebp)
  801a2b:	56                   	push   %esi
  801a2c:	50                   	push   %eax
  801a2d:	68 78 22 80 00       	push   $0x802278
  801a32:	e8 55 e7 ff ff       	call   80018c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a37:	83 c4 18             	add    $0x18,%esp
  801a3a:	53                   	push   %ebx
  801a3b:	ff 75 10             	pushl  0x10(%ebp)
  801a3e:	e8 f8 e6 ff ff       	call   80013b <vcprintf>
	cprintf("\n");
  801a43:	c7 04 24 63 22 80 00 	movl   $0x802263,(%esp)
  801a4a:	e8 3d e7 ff ff       	call   80018c <cprintf>
  801a4f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a52:	cc                   	int3   
  801a53:	eb fd                	jmp    801a52 <_panic+0x43>

00801a55 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a55:	55                   	push   %ebp
  801a56:	89 e5                	mov    %esp,%ebp
  801a58:	56                   	push   %esi
  801a59:	53                   	push   %ebx
  801a5a:	8b 75 08             	mov    0x8(%ebp),%esi
  801a5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a60:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801a63:	85 c0                	test   %eax,%eax
  801a65:	75 12                	jne    801a79 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801a67:	83 ec 0c             	sub    $0xc,%esp
  801a6a:	68 00 00 c0 ee       	push   $0xeec00000
  801a6f:	e8 50 f2 ff ff       	call   800cc4 <sys_ipc_recv>
  801a74:	83 c4 10             	add    $0x10,%esp
  801a77:	eb 0c                	jmp    801a85 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801a79:	83 ec 0c             	sub    $0xc,%esp
  801a7c:	50                   	push   %eax
  801a7d:	e8 42 f2 ff ff       	call   800cc4 <sys_ipc_recv>
  801a82:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801a85:	85 f6                	test   %esi,%esi
  801a87:	0f 95 c1             	setne  %cl
  801a8a:	85 db                	test   %ebx,%ebx
  801a8c:	0f 95 c2             	setne  %dl
  801a8f:	84 d1                	test   %dl,%cl
  801a91:	74 09                	je     801a9c <ipc_recv+0x47>
  801a93:	89 c2                	mov    %eax,%edx
  801a95:	c1 ea 1f             	shr    $0x1f,%edx
  801a98:	84 d2                	test   %dl,%dl
  801a9a:	75 27                	jne    801ac3 <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801a9c:	85 f6                	test   %esi,%esi
  801a9e:	74 0a                	je     801aaa <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801aa0:	a1 04 40 80 00       	mov    0x804004,%eax
  801aa5:	8b 40 7c             	mov    0x7c(%eax),%eax
  801aa8:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801aaa:	85 db                	test   %ebx,%ebx
  801aac:	74 0d                	je     801abb <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  801aae:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab3:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801ab9:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801abb:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac0:	8b 40 78             	mov    0x78(%eax),%eax
}
  801ac3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ac6:	5b                   	pop    %ebx
  801ac7:	5e                   	pop    %esi
  801ac8:	5d                   	pop    %ebp
  801ac9:	c3                   	ret    

00801aca <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801aca:	55                   	push   %ebp
  801acb:	89 e5                	mov    %esp,%ebp
  801acd:	57                   	push   %edi
  801ace:	56                   	push   %esi
  801acf:	53                   	push   %ebx
  801ad0:	83 ec 0c             	sub    $0xc,%esp
  801ad3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ad6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ad9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801adc:	85 db                	test   %ebx,%ebx
  801ade:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ae3:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801ae6:	ff 75 14             	pushl  0x14(%ebp)
  801ae9:	53                   	push   %ebx
  801aea:	56                   	push   %esi
  801aeb:	57                   	push   %edi
  801aec:	e8 b0 f1 ff ff       	call   800ca1 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801af1:	89 c2                	mov    %eax,%edx
  801af3:	c1 ea 1f             	shr    $0x1f,%edx
  801af6:	83 c4 10             	add    $0x10,%esp
  801af9:	84 d2                	test   %dl,%dl
  801afb:	74 17                	je     801b14 <ipc_send+0x4a>
  801afd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b00:	74 12                	je     801b14 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801b02:	50                   	push   %eax
  801b03:	68 9c 22 80 00       	push   $0x80229c
  801b08:	6a 47                	push   $0x47
  801b0a:	68 aa 22 80 00       	push   $0x8022aa
  801b0f:	e8 fb fe ff ff       	call   801a0f <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801b14:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b17:	75 07                	jne    801b20 <ipc_send+0x56>
			sys_yield();
  801b19:	e8 d7 ef ff ff       	call   800af5 <sys_yield>
  801b1e:	eb c6                	jmp    801ae6 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801b20:	85 c0                	test   %eax,%eax
  801b22:	75 c2                	jne    801ae6 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801b24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b27:	5b                   	pop    %ebx
  801b28:	5e                   	pop    %esi
  801b29:	5f                   	pop    %edi
  801b2a:	5d                   	pop    %ebp
  801b2b:	c3                   	ret    

00801b2c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b2c:	55                   	push   %ebp
  801b2d:	89 e5                	mov    %esp,%ebp
  801b2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b32:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b37:	89 c2                	mov    %eax,%edx
  801b39:	c1 e2 07             	shl    $0x7,%edx
  801b3c:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801b43:	8b 52 58             	mov    0x58(%edx),%edx
  801b46:	39 ca                	cmp    %ecx,%edx
  801b48:	75 11                	jne    801b5b <ipc_find_env+0x2f>
			return envs[i].env_id;
  801b4a:	89 c2                	mov    %eax,%edx
  801b4c:	c1 e2 07             	shl    $0x7,%edx
  801b4f:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801b56:	8b 40 50             	mov    0x50(%eax),%eax
  801b59:	eb 0f                	jmp    801b6a <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b5b:	83 c0 01             	add    $0x1,%eax
  801b5e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b63:	75 d2                	jne    801b37 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b65:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b6a:	5d                   	pop    %ebp
  801b6b:	c3                   	ret    

00801b6c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b6c:	55                   	push   %ebp
  801b6d:	89 e5                	mov    %esp,%ebp
  801b6f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b72:	89 d0                	mov    %edx,%eax
  801b74:	c1 e8 16             	shr    $0x16,%eax
  801b77:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b7e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b83:	f6 c1 01             	test   $0x1,%cl
  801b86:	74 1d                	je     801ba5 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b88:	c1 ea 0c             	shr    $0xc,%edx
  801b8b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b92:	f6 c2 01             	test   $0x1,%dl
  801b95:	74 0e                	je     801ba5 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b97:	c1 ea 0c             	shr    $0xc,%edx
  801b9a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ba1:	ef 
  801ba2:	0f b7 c0             	movzwl %ax,%eax
}
  801ba5:	5d                   	pop    %ebp
  801ba6:	c3                   	ret    
  801ba7:	66 90                	xchg   %ax,%ax
  801ba9:	66 90                	xchg   %ax,%ax
  801bab:	66 90                	xchg   %ax,%ax
  801bad:	66 90                	xchg   %ax,%ax
  801baf:	90                   	nop

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
