
obj/user/softint.debug:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	57                   	push   %edi
  80003e:	56                   	push   %esi
  80003f:	53                   	push   %ebx
  800040:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800043:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  80004a:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  80004d:	e8 85 0a 00 00       	call   800ad7 <sys_getenvid>
  800052:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  800054:	83 ec 08             	sub    $0x8,%esp
  800057:	50                   	push   %eax
  800058:	68 40 1e 80 00       	push   $0x801e40
  80005d:	e8 2b 01 00 00       	call   80018d <cprintf>
  800062:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  800068:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80006d:	83 c4 10             	add    $0x10,%esp
  800070:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800075:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  80007a:	89 c1                	mov    %eax,%ecx
  80007c:	c1 e1 07             	shl    $0x7,%ecx
  80007f:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  800086:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  800089:	39 cb                	cmp    %ecx,%ebx
  80008b:	0f 44 fa             	cmove  %edx,%edi
  80008e:	b9 01 00 00 00       	mov    $0x1,%ecx
  800093:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  800096:	83 c0 01             	add    $0x1,%eax
  800099:	81 c2 84 00 00 00    	add    $0x84,%edx
  80009f:	3d 00 04 00 00       	cmp    $0x400,%eax
  8000a4:	75 d4                	jne    80007a <libmain+0x40>
  8000a6:	89 f0                	mov    %esi,%eax
  8000a8:	84 c0                	test   %al,%al
  8000aa:	74 06                	je     8000b2 <libmain+0x78>
  8000ac:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000b6:	7e 0a                	jle    8000c2 <libmain+0x88>
		binaryname = argv[0];
  8000b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000bb:	8b 00                	mov    (%eax),%eax
  8000bd:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000c2:	83 ec 08             	sub    $0x8,%esp
  8000c5:	ff 75 0c             	pushl  0xc(%ebp)
  8000c8:	ff 75 08             	pushl  0x8(%ebp)
  8000cb:	e8 63 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d0:	e8 0b 00 00 00       	call   8000e0 <exit>
}
  8000d5:	83 c4 10             	add    $0x10,%esp
  8000d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000db:	5b                   	pop    %ebx
  8000dc:	5e                   	pop    %esi
  8000dd:	5f                   	pop    %edi
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000e6:	e8 06 0e 00 00       	call   800ef1 <close_all>
	sys_env_destroy(0);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	6a 00                	push   $0x0
  8000f0:	e8 a1 09 00 00       	call   800a96 <sys_env_destroy>
}
  8000f5:	83 c4 10             	add    $0x10,%esp
  8000f8:	c9                   	leave  
  8000f9:	c3                   	ret    

008000fa <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	53                   	push   %ebx
  8000fe:	83 ec 04             	sub    $0x4,%esp
  800101:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800104:	8b 13                	mov    (%ebx),%edx
  800106:	8d 42 01             	lea    0x1(%edx),%eax
  800109:	89 03                	mov    %eax,(%ebx)
  80010b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800112:	3d ff 00 00 00       	cmp    $0xff,%eax
  800117:	75 1a                	jne    800133 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800119:	83 ec 08             	sub    $0x8,%esp
  80011c:	68 ff 00 00 00       	push   $0xff
  800121:	8d 43 08             	lea    0x8(%ebx),%eax
  800124:	50                   	push   %eax
  800125:	e8 2f 09 00 00       	call   800a59 <sys_cputs>
		b->idx = 0;
  80012a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800130:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800133:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800137:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800145:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014c:	00 00 00 
	b.cnt = 0;
  80014f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800156:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800159:	ff 75 0c             	pushl  0xc(%ebp)
  80015c:	ff 75 08             	pushl  0x8(%ebp)
  80015f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800165:	50                   	push   %eax
  800166:	68 fa 00 80 00       	push   $0x8000fa
  80016b:	e8 54 01 00 00       	call   8002c4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800170:	83 c4 08             	add    $0x8,%esp
  800173:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800179:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017f:	50                   	push   %eax
  800180:	e8 d4 08 00 00       	call   800a59 <sys_cputs>

	return b.cnt;
}
  800185:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018b:	c9                   	leave  
  80018c:	c3                   	ret    

0080018d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800193:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800196:	50                   	push   %eax
  800197:	ff 75 08             	pushl  0x8(%ebp)
  80019a:	e8 9d ff ff ff       	call   80013c <vcprintf>
	va_end(ap);

	return cnt;
}
  80019f:	c9                   	leave  
  8001a0:	c3                   	ret    

008001a1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 1c             	sub    $0x1c,%esp
  8001aa:	89 c7                	mov    %eax,%edi
  8001ac:	89 d6                	mov    %edx,%esi
  8001ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001c5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001c8:	39 d3                	cmp    %edx,%ebx
  8001ca:	72 05                	jb     8001d1 <printnum+0x30>
  8001cc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001cf:	77 45                	ja     800216 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d1:	83 ec 0c             	sub    $0xc,%esp
  8001d4:	ff 75 18             	pushl  0x18(%ebp)
  8001d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8001da:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001dd:	53                   	push   %ebx
  8001de:	ff 75 10             	pushl  0x10(%ebp)
  8001e1:	83 ec 08             	sub    $0x8,%esp
  8001e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ea:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ed:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f0:	e8 bb 19 00 00       	call   801bb0 <__udivdi3>
  8001f5:	83 c4 18             	add    $0x18,%esp
  8001f8:	52                   	push   %edx
  8001f9:	50                   	push   %eax
  8001fa:	89 f2                	mov    %esi,%edx
  8001fc:	89 f8                	mov    %edi,%eax
  8001fe:	e8 9e ff ff ff       	call   8001a1 <printnum>
  800203:	83 c4 20             	add    $0x20,%esp
  800206:	eb 18                	jmp    800220 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	56                   	push   %esi
  80020c:	ff 75 18             	pushl  0x18(%ebp)
  80020f:	ff d7                	call   *%edi
  800211:	83 c4 10             	add    $0x10,%esp
  800214:	eb 03                	jmp    800219 <printnum+0x78>
  800216:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800219:	83 eb 01             	sub    $0x1,%ebx
  80021c:	85 db                	test   %ebx,%ebx
  80021e:	7f e8                	jg     800208 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800220:	83 ec 08             	sub    $0x8,%esp
  800223:	56                   	push   %esi
  800224:	83 ec 04             	sub    $0x4,%esp
  800227:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022a:	ff 75 e0             	pushl  -0x20(%ebp)
  80022d:	ff 75 dc             	pushl  -0x24(%ebp)
  800230:	ff 75 d8             	pushl  -0x28(%ebp)
  800233:	e8 a8 1a 00 00       	call   801ce0 <__umoddi3>
  800238:	83 c4 14             	add    $0x14,%esp
  80023b:	0f be 80 69 1e 80 00 	movsbl 0x801e69(%eax),%eax
  800242:	50                   	push   %eax
  800243:	ff d7                	call   *%edi
}
  800245:	83 c4 10             	add    $0x10,%esp
  800248:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024b:	5b                   	pop    %ebx
  80024c:	5e                   	pop    %esi
  80024d:	5f                   	pop    %edi
  80024e:	5d                   	pop    %ebp
  80024f:	c3                   	ret    

00800250 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800253:	83 fa 01             	cmp    $0x1,%edx
  800256:	7e 0e                	jle    800266 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800258:	8b 10                	mov    (%eax),%edx
  80025a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80025d:	89 08                	mov    %ecx,(%eax)
  80025f:	8b 02                	mov    (%edx),%eax
  800261:	8b 52 04             	mov    0x4(%edx),%edx
  800264:	eb 22                	jmp    800288 <getuint+0x38>
	else if (lflag)
  800266:	85 d2                	test   %edx,%edx
  800268:	74 10                	je     80027a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80026a:	8b 10                	mov    (%eax),%edx
  80026c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026f:	89 08                	mov    %ecx,(%eax)
  800271:	8b 02                	mov    (%edx),%eax
  800273:	ba 00 00 00 00       	mov    $0x0,%edx
  800278:	eb 0e                	jmp    800288 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80027a:	8b 10                	mov    (%eax),%edx
  80027c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027f:	89 08                	mov    %ecx,(%eax)
  800281:	8b 02                	mov    (%edx),%eax
  800283:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800290:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800294:	8b 10                	mov    (%eax),%edx
  800296:	3b 50 04             	cmp    0x4(%eax),%edx
  800299:	73 0a                	jae    8002a5 <sprintputch+0x1b>
		*b->buf++ = ch;
  80029b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80029e:	89 08                	mov    %ecx,(%eax)
  8002a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a3:	88 02                	mov    %al,(%edx)
}
  8002a5:	5d                   	pop    %ebp
  8002a6:	c3                   	ret    

008002a7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
  8002aa:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ad:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b0:	50                   	push   %eax
  8002b1:	ff 75 10             	pushl  0x10(%ebp)
  8002b4:	ff 75 0c             	pushl  0xc(%ebp)
  8002b7:	ff 75 08             	pushl  0x8(%ebp)
  8002ba:	e8 05 00 00 00       	call   8002c4 <vprintfmt>
	va_end(ap);
}
  8002bf:	83 c4 10             	add    $0x10,%esp
  8002c2:	c9                   	leave  
  8002c3:	c3                   	ret    

008002c4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	57                   	push   %edi
  8002c8:	56                   	push   %esi
  8002c9:	53                   	push   %ebx
  8002ca:	83 ec 2c             	sub    $0x2c,%esp
  8002cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002d6:	eb 12                	jmp    8002ea <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002d8:	85 c0                	test   %eax,%eax
  8002da:	0f 84 89 03 00 00    	je     800669 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002e0:	83 ec 08             	sub    $0x8,%esp
  8002e3:	53                   	push   %ebx
  8002e4:	50                   	push   %eax
  8002e5:	ff d6                	call   *%esi
  8002e7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ea:	83 c7 01             	add    $0x1,%edi
  8002ed:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002f1:	83 f8 25             	cmp    $0x25,%eax
  8002f4:	75 e2                	jne    8002d8 <vprintfmt+0x14>
  8002f6:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002fa:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800301:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800308:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80030f:	ba 00 00 00 00       	mov    $0x0,%edx
  800314:	eb 07                	jmp    80031d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800316:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800319:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031d:	8d 47 01             	lea    0x1(%edi),%eax
  800320:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800323:	0f b6 07             	movzbl (%edi),%eax
  800326:	0f b6 c8             	movzbl %al,%ecx
  800329:	83 e8 23             	sub    $0x23,%eax
  80032c:	3c 55                	cmp    $0x55,%al
  80032e:	0f 87 1a 03 00 00    	ja     80064e <vprintfmt+0x38a>
  800334:	0f b6 c0             	movzbl %al,%eax
  800337:	ff 24 85 a0 1f 80 00 	jmp    *0x801fa0(,%eax,4)
  80033e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800341:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800345:	eb d6                	jmp    80031d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800347:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80034a:	b8 00 00 00 00       	mov    $0x0,%eax
  80034f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800352:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800355:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800359:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80035c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80035f:	83 fa 09             	cmp    $0x9,%edx
  800362:	77 39                	ja     80039d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800364:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800367:	eb e9                	jmp    800352 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800369:	8b 45 14             	mov    0x14(%ebp),%eax
  80036c:	8d 48 04             	lea    0x4(%eax),%ecx
  80036f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800372:	8b 00                	mov    (%eax),%eax
  800374:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800377:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80037a:	eb 27                	jmp    8003a3 <vprintfmt+0xdf>
  80037c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80037f:	85 c0                	test   %eax,%eax
  800381:	b9 00 00 00 00       	mov    $0x0,%ecx
  800386:	0f 49 c8             	cmovns %eax,%ecx
  800389:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80038f:	eb 8c                	jmp    80031d <vprintfmt+0x59>
  800391:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800394:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80039b:	eb 80                	jmp    80031d <vprintfmt+0x59>
  80039d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003a0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003a3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a7:	0f 89 70 ff ff ff    	jns    80031d <vprintfmt+0x59>
				width = precision, precision = -1;
  8003ad:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ba:	e9 5e ff ff ff       	jmp    80031d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003bf:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003c5:	e9 53 ff ff ff       	jmp    80031d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cd:	8d 50 04             	lea    0x4(%eax),%edx
  8003d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d3:	83 ec 08             	sub    $0x8,%esp
  8003d6:	53                   	push   %ebx
  8003d7:	ff 30                	pushl  (%eax)
  8003d9:	ff d6                	call   *%esi
			break;
  8003db:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003e1:	e9 04 ff ff ff       	jmp    8002ea <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e9:	8d 50 04             	lea    0x4(%eax),%edx
  8003ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ef:	8b 00                	mov    (%eax),%eax
  8003f1:	99                   	cltd   
  8003f2:	31 d0                	xor    %edx,%eax
  8003f4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003f6:	83 f8 0f             	cmp    $0xf,%eax
  8003f9:	7f 0b                	jg     800406 <vprintfmt+0x142>
  8003fb:	8b 14 85 00 21 80 00 	mov    0x802100(,%eax,4),%edx
  800402:	85 d2                	test   %edx,%edx
  800404:	75 18                	jne    80041e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800406:	50                   	push   %eax
  800407:	68 81 1e 80 00       	push   $0x801e81
  80040c:	53                   	push   %ebx
  80040d:	56                   	push   %esi
  80040e:	e8 94 fe ff ff       	call   8002a7 <printfmt>
  800413:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800419:	e9 cc fe ff ff       	jmp    8002ea <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80041e:	52                   	push   %edx
  80041f:	68 31 22 80 00       	push   $0x802231
  800424:	53                   	push   %ebx
  800425:	56                   	push   %esi
  800426:	e8 7c fe ff ff       	call   8002a7 <printfmt>
  80042b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800431:	e9 b4 fe ff ff       	jmp    8002ea <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800436:	8b 45 14             	mov    0x14(%ebp),%eax
  800439:	8d 50 04             	lea    0x4(%eax),%edx
  80043c:	89 55 14             	mov    %edx,0x14(%ebp)
  80043f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800441:	85 ff                	test   %edi,%edi
  800443:	b8 7a 1e 80 00       	mov    $0x801e7a,%eax
  800448:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80044b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80044f:	0f 8e 94 00 00 00    	jle    8004e9 <vprintfmt+0x225>
  800455:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800459:	0f 84 98 00 00 00    	je     8004f7 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80045f:	83 ec 08             	sub    $0x8,%esp
  800462:	ff 75 d0             	pushl  -0x30(%ebp)
  800465:	57                   	push   %edi
  800466:	e8 86 02 00 00       	call   8006f1 <strnlen>
  80046b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80046e:	29 c1                	sub    %eax,%ecx
  800470:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800473:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800476:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80047a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80047d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800480:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800482:	eb 0f                	jmp    800493 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800484:	83 ec 08             	sub    $0x8,%esp
  800487:	53                   	push   %ebx
  800488:	ff 75 e0             	pushl  -0x20(%ebp)
  80048b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048d:	83 ef 01             	sub    $0x1,%edi
  800490:	83 c4 10             	add    $0x10,%esp
  800493:	85 ff                	test   %edi,%edi
  800495:	7f ed                	jg     800484 <vprintfmt+0x1c0>
  800497:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80049a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80049d:	85 c9                	test   %ecx,%ecx
  80049f:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a4:	0f 49 c1             	cmovns %ecx,%eax
  8004a7:	29 c1                	sub    %eax,%ecx
  8004a9:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ac:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004af:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b2:	89 cb                	mov    %ecx,%ebx
  8004b4:	eb 4d                	jmp    800503 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004b6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ba:	74 1b                	je     8004d7 <vprintfmt+0x213>
  8004bc:	0f be c0             	movsbl %al,%eax
  8004bf:	83 e8 20             	sub    $0x20,%eax
  8004c2:	83 f8 5e             	cmp    $0x5e,%eax
  8004c5:	76 10                	jbe    8004d7 <vprintfmt+0x213>
					putch('?', putdat);
  8004c7:	83 ec 08             	sub    $0x8,%esp
  8004ca:	ff 75 0c             	pushl  0xc(%ebp)
  8004cd:	6a 3f                	push   $0x3f
  8004cf:	ff 55 08             	call   *0x8(%ebp)
  8004d2:	83 c4 10             	add    $0x10,%esp
  8004d5:	eb 0d                	jmp    8004e4 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004d7:	83 ec 08             	sub    $0x8,%esp
  8004da:	ff 75 0c             	pushl  0xc(%ebp)
  8004dd:	52                   	push   %edx
  8004de:	ff 55 08             	call   *0x8(%ebp)
  8004e1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e4:	83 eb 01             	sub    $0x1,%ebx
  8004e7:	eb 1a                	jmp    800503 <vprintfmt+0x23f>
  8004e9:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ec:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ef:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f5:	eb 0c                	jmp    800503 <vprintfmt+0x23f>
  8004f7:	89 75 08             	mov    %esi,0x8(%ebp)
  8004fa:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004fd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800500:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800503:	83 c7 01             	add    $0x1,%edi
  800506:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80050a:	0f be d0             	movsbl %al,%edx
  80050d:	85 d2                	test   %edx,%edx
  80050f:	74 23                	je     800534 <vprintfmt+0x270>
  800511:	85 f6                	test   %esi,%esi
  800513:	78 a1                	js     8004b6 <vprintfmt+0x1f2>
  800515:	83 ee 01             	sub    $0x1,%esi
  800518:	79 9c                	jns    8004b6 <vprintfmt+0x1f2>
  80051a:	89 df                	mov    %ebx,%edi
  80051c:	8b 75 08             	mov    0x8(%ebp),%esi
  80051f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800522:	eb 18                	jmp    80053c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800524:	83 ec 08             	sub    $0x8,%esp
  800527:	53                   	push   %ebx
  800528:	6a 20                	push   $0x20
  80052a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80052c:	83 ef 01             	sub    $0x1,%edi
  80052f:	83 c4 10             	add    $0x10,%esp
  800532:	eb 08                	jmp    80053c <vprintfmt+0x278>
  800534:	89 df                	mov    %ebx,%edi
  800536:	8b 75 08             	mov    0x8(%ebp),%esi
  800539:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053c:	85 ff                	test   %edi,%edi
  80053e:	7f e4                	jg     800524 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800540:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800543:	e9 a2 fd ff ff       	jmp    8002ea <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800548:	83 fa 01             	cmp    $0x1,%edx
  80054b:	7e 16                	jle    800563 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80054d:	8b 45 14             	mov    0x14(%ebp),%eax
  800550:	8d 50 08             	lea    0x8(%eax),%edx
  800553:	89 55 14             	mov    %edx,0x14(%ebp)
  800556:	8b 50 04             	mov    0x4(%eax),%edx
  800559:	8b 00                	mov    (%eax),%eax
  80055b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800561:	eb 32                	jmp    800595 <vprintfmt+0x2d1>
	else if (lflag)
  800563:	85 d2                	test   %edx,%edx
  800565:	74 18                	je     80057f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8d 50 04             	lea    0x4(%eax),%edx
  80056d:	89 55 14             	mov    %edx,0x14(%ebp)
  800570:	8b 00                	mov    (%eax),%eax
  800572:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800575:	89 c1                	mov    %eax,%ecx
  800577:	c1 f9 1f             	sar    $0x1f,%ecx
  80057a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80057d:	eb 16                	jmp    800595 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80057f:	8b 45 14             	mov    0x14(%ebp),%eax
  800582:	8d 50 04             	lea    0x4(%eax),%edx
  800585:	89 55 14             	mov    %edx,0x14(%ebp)
  800588:	8b 00                	mov    (%eax),%eax
  80058a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058d:	89 c1                	mov    %eax,%ecx
  80058f:	c1 f9 1f             	sar    $0x1f,%ecx
  800592:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800595:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800598:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80059b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005a4:	79 74                	jns    80061a <vprintfmt+0x356>
				putch('-', putdat);
  8005a6:	83 ec 08             	sub    $0x8,%esp
  8005a9:	53                   	push   %ebx
  8005aa:	6a 2d                	push   $0x2d
  8005ac:	ff d6                	call   *%esi
				num = -(long long) num;
  8005ae:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005b4:	f7 d8                	neg    %eax
  8005b6:	83 d2 00             	adc    $0x0,%edx
  8005b9:	f7 da                	neg    %edx
  8005bb:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005be:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005c3:	eb 55                	jmp    80061a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005c5:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c8:	e8 83 fc ff ff       	call   800250 <getuint>
			base = 10;
  8005cd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005d2:	eb 46                	jmp    80061a <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005d4:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d7:	e8 74 fc ff ff       	call   800250 <getuint>
			base = 8;
  8005dc:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005e1:	eb 37                	jmp    80061a <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005e3:	83 ec 08             	sub    $0x8,%esp
  8005e6:	53                   	push   %ebx
  8005e7:	6a 30                	push   $0x30
  8005e9:	ff d6                	call   *%esi
			putch('x', putdat);
  8005eb:	83 c4 08             	add    $0x8,%esp
  8005ee:	53                   	push   %ebx
  8005ef:	6a 78                	push   $0x78
  8005f1:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8d 50 04             	lea    0x4(%eax),%edx
  8005f9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005fc:	8b 00                	mov    (%eax),%eax
  8005fe:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800603:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800606:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80060b:	eb 0d                	jmp    80061a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80060d:	8d 45 14             	lea    0x14(%ebp),%eax
  800610:	e8 3b fc ff ff       	call   800250 <getuint>
			base = 16;
  800615:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80061a:	83 ec 0c             	sub    $0xc,%esp
  80061d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800621:	57                   	push   %edi
  800622:	ff 75 e0             	pushl  -0x20(%ebp)
  800625:	51                   	push   %ecx
  800626:	52                   	push   %edx
  800627:	50                   	push   %eax
  800628:	89 da                	mov    %ebx,%edx
  80062a:	89 f0                	mov    %esi,%eax
  80062c:	e8 70 fb ff ff       	call   8001a1 <printnum>
			break;
  800631:	83 c4 20             	add    $0x20,%esp
  800634:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800637:	e9 ae fc ff ff       	jmp    8002ea <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80063c:	83 ec 08             	sub    $0x8,%esp
  80063f:	53                   	push   %ebx
  800640:	51                   	push   %ecx
  800641:	ff d6                	call   *%esi
			break;
  800643:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800646:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800649:	e9 9c fc ff ff       	jmp    8002ea <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80064e:	83 ec 08             	sub    $0x8,%esp
  800651:	53                   	push   %ebx
  800652:	6a 25                	push   $0x25
  800654:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800656:	83 c4 10             	add    $0x10,%esp
  800659:	eb 03                	jmp    80065e <vprintfmt+0x39a>
  80065b:	83 ef 01             	sub    $0x1,%edi
  80065e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800662:	75 f7                	jne    80065b <vprintfmt+0x397>
  800664:	e9 81 fc ff ff       	jmp    8002ea <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800669:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80066c:	5b                   	pop    %ebx
  80066d:	5e                   	pop    %esi
  80066e:	5f                   	pop    %edi
  80066f:	5d                   	pop    %ebp
  800670:	c3                   	ret    

00800671 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800671:	55                   	push   %ebp
  800672:	89 e5                	mov    %esp,%ebp
  800674:	83 ec 18             	sub    $0x18,%esp
  800677:	8b 45 08             	mov    0x8(%ebp),%eax
  80067a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80067d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800680:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800684:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800687:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80068e:	85 c0                	test   %eax,%eax
  800690:	74 26                	je     8006b8 <vsnprintf+0x47>
  800692:	85 d2                	test   %edx,%edx
  800694:	7e 22                	jle    8006b8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800696:	ff 75 14             	pushl  0x14(%ebp)
  800699:	ff 75 10             	pushl  0x10(%ebp)
  80069c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80069f:	50                   	push   %eax
  8006a0:	68 8a 02 80 00       	push   $0x80028a
  8006a5:	e8 1a fc ff ff       	call   8002c4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ad:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b3:	83 c4 10             	add    $0x10,%esp
  8006b6:	eb 05                	jmp    8006bd <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006bd:	c9                   	leave  
  8006be:	c3                   	ret    

008006bf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006bf:	55                   	push   %ebp
  8006c0:	89 e5                	mov    %esp,%ebp
  8006c2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006c5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006c8:	50                   	push   %eax
  8006c9:	ff 75 10             	pushl  0x10(%ebp)
  8006cc:	ff 75 0c             	pushl  0xc(%ebp)
  8006cf:	ff 75 08             	pushl  0x8(%ebp)
  8006d2:	e8 9a ff ff ff       	call   800671 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006d7:	c9                   	leave  
  8006d8:	c3                   	ret    

008006d9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006d9:	55                   	push   %ebp
  8006da:	89 e5                	mov    %esp,%ebp
  8006dc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006df:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e4:	eb 03                	jmp    8006e9 <strlen+0x10>
		n++;
  8006e6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006ed:	75 f7                	jne    8006e6 <strlen+0xd>
		n++;
	return n;
}
  8006ef:	5d                   	pop    %ebp
  8006f0:	c3                   	ret    

008006f1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f1:	55                   	push   %ebp
  8006f2:	89 e5                	mov    %esp,%ebp
  8006f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006f7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8006ff:	eb 03                	jmp    800704 <strnlen+0x13>
		n++;
  800701:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800704:	39 c2                	cmp    %eax,%edx
  800706:	74 08                	je     800710 <strnlen+0x1f>
  800708:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80070c:	75 f3                	jne    800701 <strnlen+0x10>
  80070e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800710:	5d                   	pop    %ebp
  800711:	c3                   	ret    

00800712 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800712:	55                   	push   %ebp
  800713:	89 e5                	mov    %esp,%ebp
  800715:	53                   	push   %ebx
  800716:	8b 45 08             	mov    0x8(%ebp),%eax
  800719:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80071c:	89 c2                	mov    %eax,%edx
  80071e:	83 c2 01             	add    $0x1,%edx
  800721:	83 c1 01             	add    $0x1,%ecx
  800724:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800728:	88 5a ff             	mov    %bl,-0x1(%edx)
  80072b:	84 db                	test   %bl,%bl
  80072d:	75 ef                	jne    80071e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80072f:	5b                   	pop    %ebx
  800730:	5d                   	pop    %ebp
  800731:	c3                   	ret    

00800732 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	53                   	push   %ebx
  800736:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800739:	53                   	push   %ebx
  80073a:	e8 9a ff ff ff       	call   8006d9 <strlen>
  80073f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800742:	ff 75 0c             	pushl  0xc(%ebp)
  800745:	01 d8                	add    %ebx,%eax
  800747:	50                   	push   %eax
  800748:	e8 c5 ff ff ff       	call   800712 <strcpy>
	return dst;
}
  80074d:	89 d8                	mov    %ebx,%eax
  80074f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800752:	c9                   	leave  
  800753:	c3                   	ret    

00800754 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	56                   	push   %esi
  800758:	53                   	push   %ebx
  800759:	8b 75 08             	mov    0x8(%ebp),%esi
  80075c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80075f:	89 f3                	mov    %esi,%ebx
  800761:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800764:	89 f2                	mov    %esi,%edx
  800766:	eb 0f                	jmp    800777 <strncpy+0x23>
		*dst++ = *src;
  800768:	83 c2 01             	add    $0x1,%edx
  80076b:	0f b6 01             	movzbl (%ecx),%eax
  80076e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800771:	80 39 01             	cmpb   $0x1,(%ecx)
  800774:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800777:	39 da                	cmp    %ebx,%edx
  800779:	75 ed                	jne    800768 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80077b:	89 f0                	mov    %esi,%eax
  80077d:	5b                   	pop    %ebx
  80077e:	5e                   	pop    %esi
  80077f:	5d                   	pop    %ebp
  800780:	c3                   	ret    

00800781 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800781:	55                   	push   %ebp
  800782:	89 e5                	mov    %esp,%ebp
  800784:	56                   	push   %esi
  800785:	53                   	push   %ebx
  800786:	8b 75 08             	mov    0x8(%ebp),%esi
  800789:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078c:	8b 55 10             	mov    0x10(%ebp),%edx
  80078f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800791:	85 d2                	test   %edx,%edx
  800793:	74 21                	je     8007b6 <strlcpy+0x35>
  800795:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800799:	89 f2                	mov    %esi,%edx
  80079b:	eb 09                	jmp    8007a6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80079d:	83 c2 01             	add    $0x1,%edx
  8007a0:	83 c1 01             	add    $0x1,%ecx
  8007a3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007a6:	39 c2                	cmp    %eax,%edx
  8007a8:	74 09                	je     8007b3 <strlcpy+0x32>
  8007aa:	0f b6 19             	movzbl (%ecx),%ebx
  8007ad:	84 db                	test   %bl,%bl
  8007af:	75 ec                	jne    80079d <strlcpy+0x1c>
  8007b1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007b3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007b6:	29 f0                	sub    %esi,%eax
}
  8007b8:	5b                   	pop    %ebx
  8007b9:	5e                   	pop    %esi
  8007ba:	5d                   	pop    %ebp
  8007bb:	c3                   	ret    

008007bc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007c5:	eb 06                	jmp    8007cd <strcmp+0x11>
		p++, q++;
  8007c7:	83 c1 01             	add    $0x1,%ecx
  8007ca:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007cd:	0f b6 01             	movzbl (%ecx),%eax
  8007d0:	84 c0                	test   %al,%al
  8007d2:	74 04                	je     8007d8 <strcmp+0x1c>
  8007d4:	3a 02                	cmp    (%edx),%al
  8007d6:	74 ef                	je     8007c7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d8:	0f b6 c0             	movzbl %al,%eax
  8007db:	0f b6 12             	movzbl (%edx),%edx
  8007de:	29 d0                	sub    %edx,%eax
}
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	53                   	push   %ebx
  8007e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ec:	89 c3                	mov    %eax,%ebx
  8007ee:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007f1:	eb 06                	jmp    8007f9 <strncmp+0x17>
		n--, p++, q++;
  8007f3:	83 c0 01             	add    $0x1,%eax
  8007f6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007f9:	39 d8                	cmp    %ebx,%eax
  8007fb:	74 15                	je     800812 <strncmp+0x30>
  8007fd:	0f b6 08             	movzbl (%eax),%ecx
  800800:	84 c9                	test   %cl,%cl
  800802:	74 04                	je     800808 <strncmp+0x26>
  800804:	3a 0a                	cmp    (%edx),%cl
  800806:	74 eb                	je     8007f3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800808:	0f b6 00             	movzbl (%eax),%eax
  80080b:	0f b6 12             	movzbl (%edx),%edx
  80080e:	29 d0                	sub    %edx,%eax
  800810:	eb 05                	jmp    800817 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800812:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800817:	5b                   	pop    %ebx
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	8b 45 08             	mov    0x8(%ebp),%eax
  800820:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800824:	eb 07                	jmp    80082d <strchr+0x13>
		if (*s == c)
  800826:	38 ca                	cmp    %cl,%dl
  800828:	74 0f                	je     800839 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80082a:	83 c0 01             	add    $0x1,%eax
  80082d:	0f b6 10             	movzbl (%eax),%edx
  800830:	84 d2                	test   %dl,%dl
  800832:	75 f2                	jne    800826 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800834:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	8b 45 08             	mov    0x8(%ebp),%eax
  800841:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800845:	eb 03                	jmp    80084a <strfind+0xf>
  800847:	83 c0 01             	add    $0x1,%eax
  80084a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80084d:	38 ca                	cmp    %cl,%dl
  80084f:	74 04                	je     800855 <strfind+0x1a>
  800851:	84 d2                	test   %dl,%dl
  800853:	75 f2                	jne    800847 <strfind+0xc>
			break;
	return (char *) s;
}
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	57                   	push   %edi
  80085b:	56                   	push   %esi
  80085c:	53                   	push   %ebx
  80085d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800860:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800863:	85 c9                	test   %ecx,%ecx
  800865:	74 36                	je     80089d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800867:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80086d:	75 28                	jne    800897 <memset+0x40>
  80086f:	f6 c1 03             	test   $0x3,%cl
  800872:	75 23                	jne    800897 <memset+0x40>
		c &= 0xFF;
  800874:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800878:	89 d3                	mov    %edx,%ebx
  80087a:	c1 e3 08             	shl    $0x8,%ebx
  80087d:	89 d6                	mov    %edx,%esi
  80087f:	c1 e6 18             	shl    $0x18,%esi
  800882:	89 d0                	mov    %edx,%eax
  800884:	c1 e0 10             	shl    $0x10,%eax
  800887:	09 f0                	or     %esi,%eax
  800889:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80088b:	89 d8                	mov    %ebx,%eax
  80088d:	09 d0                	or     %edx,%eax
  80088f:	c1 e9 02             	shr    $0x2,%ecx
  800892:	fc                   	cld    
  800893:	f3 ab                	rep stos %eax,%es:(%edi)
  800895:	eb 06                	jmp    80089d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800897:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089a:	fc                   	cld    
  80089b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80089d:	89 f8                	mov    %edi,%eax
  80089f:	5b                   	pop    %ebx
  8008a0:	5e                   	pop    %esi
  8008a1:	5f                   	pop    %edi
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	57                   	push   %edi
  8008a8:	56                   	push   %esi
  8008a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ac:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008af:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008b2:	39 c6                	cmp    %eax,%esi
  8008b4:	73 35                	jae    8008eb <memmove+0x47>
  8008b6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008b9:	39 d0                	cmp    %edx,%eax
  8008bb:	73 2e                	jae    8008eb <memmove+0x47>
		s += n;
		d += n;
  8008bd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c0:	89 d6                	mov    %edx,%esi
  8008c2:	09 fe                	or     %edi,%esi
  8008c4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ca:	75 13                	jne    8008df <memmove+0x3b>
  8008cc:	f6 c1 03             	test   $0x3,%cl
  8008cf:	75 0e                	jne    8008df <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008d1:	83 ef 04             	sub    $0x4,%edi
  8008d4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008d7:	c1 e9 02             	shr    $0x2,%ecx
  8008da:	fd                   	std    
  8008db:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008dd:	eb 09                	jmp    8008e8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008df:	83 ef 01             	sub    $0x1,%edi
  8008e2:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008e5:	fd                   	std    
  8008e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008e8:	fc                   	cld    
  8008e9:	eb 1d                	jmp    800908 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008eb:	89 f2                	mov    %esi,%edx
  8008ed:	09 c2                	or     %eax,%edx
  8008ef:	f6 c2 03             	test   $0x3,%dl
  8008f2:	75 0f                	jne    800903 <memmove+0x5f>
  8008f4:	f6 c1 03             	test   $0x3,%cl
  8008f7:	75 0a                	jne    800903 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008f9:	c1 e9 02             	shr    $0x2,%ecx
  8008fc:	89 c7                	mov    %eax,%edi
  8008fe:	fc                   	cld    
  8008ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800901:	eb 05                	jmp    800908 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800903:	89 c7                	mov    %eax,%edi
  800905:	fc                   	cld    
  800906:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800908:	5e                   	pop    %esi
  800909:	5f                   	pop    %edi
  80090a:	5d                   	pop    %ebp
  80090b:	c3                   	ret    

0080090c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80090f:	ff 75 10             	pushl  0x10(%ebp)
  800912:	ff 75 0c             	pushl  0xc(%ebp)
  800915:	ff 75 08             	pushl  0x8(%ebp)
  800918:	e8 87 ff ff ff       	call   8008a4 <memmove>
}
  80091d:	c9                   	leave  
  80091e:	c3                   	ret    

0080091f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	56                   	push   %esi
  800923:	53                   	push   %ebx
  800924:	8b 45 08             	mov    0x8(%ebp),%eax
  800927:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092a:	89 c6                	mov    %eax,%esi
  80092c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80092f:	eb 1a                	jmp    80094b <memcmp+0x2c>
		if (*s1 != *s2)
  800931:	0f b6 08             	movzbl (%eax),%ecx
  800934:	0f b6 1a             	movzbl (%edx),%ebx
  800937:	38 d9                	cmp    %bl,%cl
  800939:	74 0a                	je     800945 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80093b:	0f b6 c1             	movzbl %cl,%eax
  80093e:	0f b6 db             	movzbl %bl,%ebx
  800941:	29 d8                	sub    %ebx,%eax
  800943:	eb 0f                	jmp    800954 <memcmp+0x35>
		s1++, s2++;
  800945:	83 c0 01             	add    $0x1,%eax
  800948:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094b:	39 f0                	cmp    %esi,%eax
  80094d:	75 e2                	jne    800931 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80094f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800954:	5b                   	pop    %ebx
  800955:	5e                   	pop    %esi
  800956:	5d                   	pop    %ebp
  800957:	c3                   	ret    

00800958 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	53                   	push   %ebx
  80095c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80095f:	89 c1                	mov    %eax,%ecx
  800961:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800964:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800968:	eb 0a                	jmp    800974 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80096a:	0f b6 10             	movzbl (%eax),%edx
  80096d:	39 da                	cmp    %ebx,%edx
  80096f:	74 07                	je     800978 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800971:	83 c0 01             	add    $0x1,%eax
  800974:	39 c8                	cmp    %ecx,%eax
  800976:	72 f2                	jb     80096a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800978:	5b                   	pop    %ebx
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	57                   	push   %edi
  80097f:	56                   	push   %esi
  800980:	53                   	push   %ebx
  800981:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800984:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800987:	eb 03                	jmp    80098c <strtol+0x11>
		s++;
  800989:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80098c:	0f b6 01             	movzbl (%ecx),%eax
  80098f:	3c 20                	cmp    $0x20,%al
  800991:	74 f6                	je     800989 <strtol+0xe>
  800993:	3c 09                	cmp    $0x9,%al
  800995:	74 f2                	je     800989 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800997:	3c 2b                	cmp    $0x2b,%al
  800999:	75 0a                	jne    8009a5 <strtol+0x2a>
		s++;
  80099b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80099e:	bf 00 00 00 00       	mov    $0x0,%edi
  8009a3:	eb 11                	jmp    8009b6 <strtol+0x3b>
  8009a5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009aa:	3c 2d                	cmp    $0x2d,%al
  8009ac:	75 08                	jne    8009b6 <strtol+0x3b>
		s++, neg = 1;
  8009ae:	83 c1 01             	add    $0x1,%ecx
  8009b1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009b6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009bc:	75 15                	jne    8009d3 <strtol+0x58>
  8009be:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c1:	75 10                	jne    8009d3 <strtol+0x58>
  8009c3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009c7:	75 7c                	jne    800a45 <strtol+0xca>
		s += 2, base = 16;
  8009c9:	83 c1 02             	add    $0x2,%ecx
  8009cc:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009d1:	eb 16                	jmp    8009e9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009d3:	85 db                	test   %ebx,%ebx
  8009d5:	75 12                	jne    8009e9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009d7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009dc:	80 39 30             	cmpb   $0x30,(%ecx)
  8009df:	75 08                	jne    8009e9 <strtol+0x6e>
		s++, base = 8;
  8009e1:	83 c1 01             	add    $0x1,%ecx
  8009e4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ee:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009f1:	0f b6 11             	movzbl (%ecx),%edx
  8009f4:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009f7:	89 f3                	mov    %esi,%ebx
  8009f9:	80 fb 09             	cmp    $0x9,%bl
  8009fc:	77 08                	ja     800a06 <strtol+0x8b>
			dig = *s - '0';
  8009fe:	0f be d2             	movsbl %dl,%edx
  800a01:	83 ea 30             	sub    $0x30,%edx
  800a04:	eb 22                	jmp    800a28 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a06:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a09:	89 f3                	mov    %esi,%ebx
  800a0b:	80 fb 19             	cmp    $0x19,%bl
  800a0e:	77 08                	ja     800a18 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a10:	0f be d2             	movsbl %dl,%edx
  800a13:	83 ea 57             	sub    $0x57,%edx
  800a16:	eb 10                	jmp    800a28 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a18:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a1b:	89 f3                	mov    %esi,%ebx
  800a1d:	80 fb 19             	cmp    $0x19,%bl
  800a20:	77 16                	ja     800a38 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a22:	0f be d2             	movsbl %dl,%edx
  800a25:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a28:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a2b:	7d 0b                	jge    800a38 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a2d:	83 c1 01             	add    $0x1,%ecx
  800a30:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a34:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a36:	eb b9                	jmp    8009f1 <strtol+0x76>

	if (endptr)
  800a38:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a3c:	74 0d                	je     800a4b <strtol+0xd0>
		*endptr = (char *) s;
  800a3e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a41:	89 0e                	mov    %ecx,(%esi)
  800a43:	eb 06                	jmp    800a4b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a45:	85 db                	test   %ebx,%ebx
  800a47:	74 98                	je     8009e1 <strtol+0x66>
  800a49:	eb 9e                	jmp    8009e9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a4b:	89 c2                	mov    %eax,%edx
  800a4d:	f7 da                	neg    %edx
  800a4f:	85 ff                	test   %edi,%edi
  800a51:	0f 45 c2             	cmovne %edx,%eax
}
  800a54:	5b                   	pop    %ebx
  800a55:	5e                   	pop    %esi
  800a56:	5f                   	pop    %edi
  800a57:	5d                   	pop    %ebp
  800a58:	c3                   	ret    

00800a59 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	57                   	push   %edi
  800a5d:	56                   	push   %esi
  800a5e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a67:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6a:	89 c3                	mov    %eax,%ebx
  800a6c:	89 c7                	mov    %eax,%edi
  800a6e:	89 c6                	mov    %eax,%esi
  800a70:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a72:	5b                   	pop    %ebx
  800a73:	5e                   	pop    %esi
  800a74:	5f                   	pop    %edi
  800a75:	5d                   	pop    %ebp
  800a76:	c3                   	ret    

00800a77 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	57                   	push   %edi
  800a7b:	56                   	push   %esi
  800a7c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a82:	b8 01 00 00 00       	mov    $0x1,%eax
  800a87:	89 d1                	mov    %edx,%ecx
  800a89:	89 d3                	mov    %edx,%ebx
  800a8b:	89 d7                	mov    %edx,%edi
  800a8d:	89 d6                	mov    %edx,%esi
  800a8f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a91:	5b                   	pop    %ebx
  800a92:	5e                   	pop    %esi
  800a93:	5f                   	pop    %edi
  800a94:	5d                   	pop    %ebp
  800a95:	c3                   	ret    

00800a96 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	57                   	push   %edi
  800a9a:	56                   	push   %esi
  800a9b:	53                   	push   %ebx
  800a9c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aa4:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa9:	8b 55 08             	mov    0x8(%ebp),%edx
  800aac:	89 cb                	mov    %ecx,%ebx
  800aae:	89 cf                	mov    %ecx,%edi
  800ab0:	89 ce                	mov    %ecx,%esi
  800ab2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ab4:	85 c0                	test   %eax,%eax
  800ab6:	7e 17                	jle    800acf <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ab8:	83 ec 0c             	sub    $0xc,%esp
  800abb:	50                   	push   %eax
  800abc:	6a 03                	push   $0x3
  800abe:	68 5f 21 80 00       	push   $0x80215f
  800ac3:	6a 23                	push   $0x23
  800ac5:	68 7c 21 80 00       	push   $0x80217c
  800aca:	e8 41 0f 00 00       	call   801a10 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800acf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad2:	5b                   	pop    %ebx
  800ad3:	5e                   	pop    %esi
  800ad4:	5f                   	pop    %edi
  800ad5:	5d                   	pop    %ebp
  800ad6:	c3                   	ret    

00800ad7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	57                   	push   %edi
  800adb:	56                   	push   %esi
  800adc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800add:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae2:	b8 02 00 00 00       	mov    $0x2,%eax
  800ae7:	89 d1                	mov    %edx,%ecx
  800ae9:	89 d3                	mov    %edx,%ebx
  800aeb:	89 d7                	mov    %edx,%edi
  800aed:	89 d6                	mov    %edx,%esi
  800aef:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5f                   	pop    %edi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <sys_yield>:

void
sys_yield(void)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	57                   	push   %edi
  800afa:	56                   	push   %esi
  800afb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afc:	ba 00 00 00 00       	mov    $0x0,%edx
  800b01:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b06:	89 d1                	mov    %edx,%ecx
  800b08:	89 d3                	mov    %edx,%ebx
  800b0a:	89 d7                	mov    %edx,%edi
  800b0c:	89 d6                	mov    %edx,%esi
  800b0e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b10:	5b                   	pop    %ebx
  800b11:	5e                   	pop    %esi
  800b12:	5f                   	pop    %edi
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	57                   	push   %edi
  800b19:	56                   	push   %esi
  800b1a:	53                   	push   %ebx
  800b1b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1e:	be 00 00 00 00       	mov    $0x0,%esi
  800b23:	b8 04 00 00 00       	mov    $0x4,%eax
  800b28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b31:	89 f7                	mov    %esi,%edi
  800b33:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b35:	85 c0                	test   %eax,%eax
  800b37:	7e 17                	jle    800b50 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b39:	83 ec 0c             	sub    $0xc,%esp
  800b3c:	50                   	push   %eax
  800b3d:	6a 04                	push   $0x4
  800b3f:	68 5f 21 80 00       	push   $0x80215f
  800b44:	6a 23                	push   $0x23
  800b46:	68 7c 21 80 00       	push   $0x80217c
  800b4b:	e8 c0 0e 00 00       	call   801a10 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b53:	5b                   	pop    %ebx
  800b54:	5e                   	pop    %esi
  800b55:	5f                   	pop    %edi
  800b56:	5d                   	pop    %ebp
  800b57:	c3                   	ret    

00800b58 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	53                   	push   %ebx
  800b5e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b61:	b8 05 00 00 00       	mov    $0x5,%eax
  800b66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b69:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b6f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b72:	8b 75 18             	mov    0x18(%ebp),%esi
  800b75:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b77:	85 c0                	test   %eax,%eax
  800b79:	7e 17                	jle    800b92 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7b:	83 ec 0c             	sub    $0xc,%esp
  800b7e:	50                   	push   %eax
  800b7f:	6a 05                	push   $0x5
  800b81:	68 5f 21 80 00       	push   $0x80215f
  800b86:	6a 23                	push   $0x23
  800b88:	68 7c 21 80 00       	push   $0x80217c
  800b8d:	e8 7e 0e 00 00       	call   801a10 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
  800ba0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ba8:	b8 06 00 00 00       	mov    $0x6,%eax
  800bad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb3:	89 df                	mov    %ebx,%edi
  800bb5:	89 de                	mov    %ebx,%esi
  800bb7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb9:	85 c0                	test   %eax,%eax
  800bbb:	7e 17                	jle    800bd4 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbd:	83 ec 0c             	sub    $0xc,%esp
  800bc0:	50                   	push   %eax
  800bc1:	6a 06                	push   $0x6
  800bc3:	68 5f 21 80 00       	push   $0x80215f
  800bc8:	6a 23                	push   $0x23
  800bca:	68 7c 21 80 00       	push   $0x80217c
  800bcf:	e8 3c 0e 00 00       	call   801a10 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd7:	5b                   	pop    %ebx
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	57                   	push   %edi
  800be0:	56                   	push   %esi
  800be1:	53                   	push   %ebx
  800be2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bea:	b8 08 00 00 00       	mov    $0x8,%eax
  800bef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf5:	89 df                	mov    %ebx,%edi
  800bf7:	89 de                	mov    %ebx,%esi
  800bf9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfb:	85 c0                	test   %eax,%eax
  800bfd:	7e 17                	jle    800c16 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bff:	83 ec 0c             	sub    $0xc,%esp
  800c02:	50                   	push   %eax
  800c03:	6a 08                	push   $0x8
  800c05:	68 5f 21 80 00       	push   $0x80215f
  800c0a:	6a 23                	push   $0x23
  800c0c:	68 7c 21 80 00       	push   $0x80217c
  800c11:	e8 fa 0d 00 00       	call   801a10 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c27:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2c:	b8 09 00 00 00       	mov    $0x9,%eax
  800c31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c34:	8b 55 08             	mov    0x8(%ebp),%edx
  800c37:	89 df                	mov    %ebx,%edi
  800c39:	89 de                	mov    %ebx,%esi
  800c3b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3d:	85 c0                	test   %eax,%eax
  800c3f:	7e 17                	jle    800c58 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c41:	83 ec 0c             	sub    $0xc,%esp
  800c44:	50                   	push   %eax
  800c45:	6a 09                	push   $0x9
  800c47:	68 5f 21 80 00       	push   $0x80215f
  800c4c:	6a 23                	push   $0x23
  800c4e:	68 7c 21 80 00       	push   $0x80217c
  800c53:	e8 b8 0d 00 00       	call   801a10 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
  800c66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c69:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c76:	8b 55 08             	mov    0x8(%ebp),%edx
  800c79:	89 df                	mov    %ebx,%edi
  800c7b:	89 de                	mov    %ebx,%esi
  800c7d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7f:	85 c0                	test   %eax,%eax
  800c81:	7e 17                	jle    800c9a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c83:	83 ec 0c             	sub    $0xc,%esp
  800c86:	50                   	push   %eax
  800c87:	6a 0a                	push   $0xa
  800c89:	68 5f 21 80 00       	push   $0x80215f
  800c8e:	6a 23                	push   $0x23
  800c90:	68 7c 21 80 00       	push   $0x80217c
  800c95:	e8 76 0d 00 00       	call   801a10 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    

00800ca2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	57                   	push   %edi
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca8:	be 00 00 00 00       	mov    $0x0,%esi
  800cad:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cbb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cbe:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
  800ccb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cce:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd3:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdb:	89 cb                	mov    %ecx,%ebx
  800cdd:	89 cf                	mov    %ecx,%edi
  800cdf:	89 ce                	mov    %ecx,%esi
  800ce1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7e 17                	jle    800cfe <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce7:	83 ec 0c             	sub    $0xc,%esp
  800cea:	50                   	push   %eax
  800ceb:	6a 0d                	push   $0xd
  800ced:	68 5f 21 80 00       	push   $0x80215f
  800cf2:	6a 23                	push   $0x23
  800cf4:	68 7c 21 80 00       	push   $0x80217c
  800cf9:	e8 12 0d 00 00       	call   801a10 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d11:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d16:	8b 55 08             	mov    0x8(%ebp),%edx
  800d19:	89 cb                	mov    %ecx,%ebx
  800d1b:	89 cf                	mov    %ecx,%edi
  800d1d:	89 ce                	mov    %ecx,%esi
  800d1f:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d29:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2c:	05 00 00 00 30       	add    $0x30000000,%eax
  800d31:	c1 e8 0c             	shr    $0xc,%eax
}
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d39:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3c:	05 00 00 00 30       	add    $0x30000000,%eax
  800d41:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d46:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    

00800d4d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d53:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d58:	89 c2                	mov    %eax,%edx
  800d5a:	c1 ea 16             	shr    $0x16,%edx
  800d5d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d64:	f6 c2 01             	test   $0x1,%dl
  800d67:	74 11                	je     800d7a <fd_alloc+0x2d>
  800d69:	89 c2                	mov    %eax,%edx
  800d6b:	c1 ea 0c             	shr    $0xc,%edx
  800d6e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d75:	f6 c2 01             	test   $0x1,%dl
  800d78:	75 09                	jne    800d83 <fd_alloc+0x36>
			*fd_store = fd;
  800d7a:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d81:	eb 17                	jmp    800d9a <fd_alloc+0x4d>
  800d83:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d88:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d8d:	75 c9                	jne    800d58 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d8f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d95:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    

00800d9c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800da2:	83 f8 1f             	cmp    $0x1f,%eax
  800da5:	77 36                	ja     800ddd <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800da7:	c1 e0 0c             	shl    $0xc,%eax
  800daa:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800daf:	89 c2                	mov    %eax,%edx
  800db1:	c1 ea 16             	shr    $0x16,%edx
  800db4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dbb:	f6 c2 01             	test   $0x1,%dl
  800dbe:	74 24                	je     800de4 <fd_lookup+0x48>
  800dc0:	89 c2                	mov    %eax,%edx
  800dc2:	c1 ea 0c             	shr    $0xc,%edx
  800dc5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dcc:	f6 c2 01             	test   $0x1,%dl
  800dcf:	74 1a                	je     800deb <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800dd1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dd4:	89 02                	mov    %eax,(%edx)
	return 0;
  800dd6:	b8 00 00 00 00       	mov    $0x0,%eax
  800ddb:	eb 13                	jmp    800df0 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ddd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800de2:	eb 0c                	jmp    800df0 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800de4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800de9:	eb 05                	jmp    800df0 <fd_lookup+0x54>
  800deb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    

00800df2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	83 ec 08             	sub    $0x8,%esp
  800df8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dfb:	ba 08 22 80 00       	mov    $0x802208,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e00:	eb 13                	jmp    800e15 <dev_lookup+0x23>
  800e02:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e05:	39 08                	cmp    %ecx,(%eax)
  800e07:	75 0c                	jne    800e15 <dev_lookup+0x23>
			*dev = devtab[i];
  800e09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0c:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e13:	eb 2e                	jmp    800e43 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e15:	8b 02                	mov    (%edx),%eax
  800e17:	85 c0                	test   %eax,%eax
  800e19:	75 e7                	jne    800e02 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e1b:	a1 04 40 80 00       	mov    0x804004,%eax
  800e20:	8b 40 50             	mov    0x50(%eax),%eax
  800e23:	83 ec 04             	sub    $0x4,%esp
  800e26:	51                   	push   %ecx
  800e27:	50                   	push   %eax
  800e28:	68 8c 21 80 00       	push   $0x80218c
  800e2d:	e8 5b f3 ff ff       	call   80018d <cprintf>
	*dev = 0;
  800e32:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e35:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e3b:	83 c4 10             	add    $0x10,%esp
  800e3e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e43:	c9                   	leave  
  800e44:	c3                   	ret    

00800e45 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e45:	55                   	push   %ebp
  800e46:	89 e5                	mov    %esp,%ebp
  800e48:	56                   	push   %esi
  800e49:	53                   	push   %ebx
  800e4a:	83 ec 10             	sub    $0x10,%esp
  800e4d:	8b 75 08             	mov    0x8(%ebp),%esi
  800e50:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e56:	50                   	push   %eax
  800e57:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e5d:	c1 e8 0c             	shr    $0xc,%eax
  800e60:	50                   	push   %eax
  800e61:	e8 36 ff ff ff       	call   800d9c <fd_lookup>
  800e66:	83 c4 08             	add    $0x8,%esp
  800e69:	85 c0                	test   %eax,%eax
  800e6b:	78 05                	js     800e72 <fd_close+0x2d>
	    || fd != fd2)
  800e6d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e70:	74 0c                	je     800e7e <fd_close+0x39>
		return (must_exist ? r : 0);
  800e72:	84 db                	test   %bl,%bl
  800e74:	ba 00 00 00 00       	mov    $0x0,%edx
  800e79:	0f 44 c2             	cmove  %edx,%eax
  800e7c:	eb 41                	jmp    800ebf <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e7e:	83 ec 08             	sub    $0x8,%esp
  800e81:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e84:	50                   	push   %eax
  800e85:	ff 36                	pushl  (%esi)
  800e87:	e8 66 ff ff ff       	call   800df2 <dev_lookup>
  800e8c:	89 c3                	mov    %eax,%ebx
  800e8e:	83 c4 10             	add    $0x10,%esp
  800e91:	85 c0                	test   %eax,%eax
  800e93:	78 1a                	js     800eaf <fd_close+0x6a>
		if (dev->dev_close)
  800e95:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e98:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e9b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ea0:	85 c0                	test   %eax,%eax
  800ea2:	74 0b                	je     800eaf <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ea4:	83 ec 0c             	sub    $0xc,%esp
  800ea7:	56                   	push   %esi
  800ea8:	ff d0                	call   *%eax
  800eaa:	89 c3                	mov    %eax,%ebx
  800eac:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800eaf:	83 ec 08             	sub    $0x8,%esp
  800eb2:	56                   	push   %esi
  800eb3:	6a 00                	push   $0x0
  800eb5:	e8 e0 fc ff ff       	call   800b9a <sys_page_unmap>
	return r;
  800eba:	83 c4 10             	add    $0x10,%esp
  800ebd:	89 d8                	mov    %ebx,%eax
}
  800ebf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ec2:	5b                   	pop    %ebx
  800ec3:	5e                   	pop    %esi
  800ec4:	5d                   	pop    %ebp
  800ec5:	c3                   	ret    

00800ec6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ecc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ecf:	50                   	push   %eax
  800ed0:	ff 75 08             	pushl  0x8(%ebp)
  800ed3:	e8 c4 fe ff ff       	call   800d9c <fd_lookup>
  800ed8:	83 c4 08             	add    $0x8,%esp
  800edb:	85 c0                	test   %eax,%eax
  800edd:	78 10                	js     800eef <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800edf:	83 ec 08             	sub    $0x8,%esp
  800ee2:	6a 01                	push   $0x1
  800ee4:	ff 75 f4             	pushl  -0xc(%ebp)
  800ee7:	e8 59 ff ff ff       	call   800e45 <fd_close>
  800eec:	83 c4 10             	add    $0x10,%esp
}
  800eef:	c9                   	leave  
  800ef0:	c3                   	ret    

00800ef1 <close_all>:

void
close_all(void)
{
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	53                   	push   %ebx
  800ef5:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ef8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800efd:	83 ec 0c             	sub    $0xc,%esp
  800f00:	53                   	push   %ebx
  800f01:	e8 c0 ff ff ff       	call   800ec6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f06:	83 c3 01             	add    $0x1,%ebx
  800f09:	83 c4 10             	add    $0x10,%esp
  800f0c:	83 fb 20             	cmp    $0x20,%ebx
  800f0f:	75 ec                	jne    800efd <close_all+0xc>
		close(i);
}
  800f11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f14:	c9                   	leave  
  800f15:	c3                   	ret    

00800f16 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f16:	55                   	push   %ebp
  800f17:	89 e5                	mov    %esp,%ebp
  800f19:	57                   	push   %edi
  800f1a:	56                   	push   %esi
  800f1b:	53                   	push   %ebx
  800f1c:	83 ec 2c             	sub    $0x2c,%esp
  800f1f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f22:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f25:	50                   	push   %eax
  800f26:	ff 75 08             	pushl  0x8(%ebp)
  800f29:	e8 6e fe ff ff       	call   800d9c <fd_lookup>
  800f2e:	83 c4 08             	add    $0x8,%esp
  800f31:	85 c0                	test   %eax,%eax
  800f33:	0f 88 c1 00 00 00    	js     800ffa <dup+0xe4>
		return r;
	close(newfdnum);
  800f39:	83 ec 0c             	sub    $0xc,%esp
  800f3c:	56                   	push   %esi
  800f3d:	e8 84 ff ff ff       	call   800ec6 <close>

	newfd = INDEX2FD(newfdnum);
  800f42:	89 f3                	mov    %esi,%ebx
  800f44:	c1 e3 0c             	shl    $0xc,%ebx
  800f47:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f4d:	83 c4 04             	add    $0x4,%esp
  800f50:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f53:	e8 de fd ff ff       	call   800d36 <fd2data>
  800f58:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f5a:	89 1c 24             	mov    %ebx,(%esp)
  800f5d:	e8 d4 fd ff ff       	call   800d36 <fd2data>
  800f62:	83 c4 10             	add    $0x10,%esp
  800f65:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f68:	89 f8                	mov    %edi,%eax
  800f6a:	c1 e8 16             	shr    $0x16,%eax
  800f6d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f74:	a8 01                	test   $0x1,%al
  800f76:	74 37                	je     800faf <dup+0x99>
  800f78:	89 f8                	mov    %edi,%eax
  800f7a:	c1 e8 0c             	shr    $0xc,%eax
  800f7d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f84:	f6 c2 01             	test   $0x1,%dl
  800f87:	74 26                	je     800faf <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f89:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f90:	83 ec 0c             	sub    $0xc,%esp
  800f93:	25 07 0e 00 00       	and    $0xe07,%eax
  800f98:	50                   	push   %eax
  800f99:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f9c:	6a 00                	push   $0x0
  800f9e:	57                   	push   %edi
  800f9f:	6a 00                	push   $0x0
  800fa1:	e8 b2 fb ff ff       	call   800b58 <sys_page_map>
  800fa6:	89 c7                	mov    %eax,%edi
  800fa8:	83 c4 20             	add    $0x20,%esp
  800fab:	85 c0                	test   %eax,%eax
  800fad:	78 2e                	js     800fdd <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800faf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fb2:	89 d0                	mov    %edx,%eax
  800fb4:	c1 e8 0c             	shr    $0xc,%eax
  800fb7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fbe:	83 ec 0c             	sub    $0xc,%esp
  800fc1:	25 07 0e 00 00       	and    $0xe07,%eax
  800fc6:	50                   	push   %eax
  800fc7:	53                   	push   %ebx
  800fc8:	6a 00                	push   $0x0
  800fca:	52                   	push   %edx
  800fcb:	6a 00                	push   $0x0
  800fcd:	e8 86 fb ff ff       	call   800b58 <sys_page_map>
  800fd2:	89 c7                	mov    %eax,%edi
  800fd4:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800fd7:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fd9:	85 ff                	test   %edi,%edi
  800fdb:	79 1d                	jns    800ffa <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fdd:	83 ec 08             	sub    $0x8,%esp
  800fe0:	53                   	push   %ebx
  800fe1:	6a 00                	push   $0x0
  800fe3:	e8 b2 fb ff ff       	call   800b9a <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fe8:	83 c4 08             	add    $0x8,%esp
  800feb:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fee:	6a 00                	push   $0x0
  800ff0:	e8 a5 fb ff ff       	call   800b9a <sys_page_unmap>
	return r;
  800ff5:	83 c4 10             	add    $0x10,%esp
  800ff8:	89 f8                	mov    %edi,%eax
}
  800ffa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ffd:	5b                   	pop    %ebx
  800ffe:	5e                   	pop    %esi
  800fff:	5f                   	pop    %edi
  801000:	5d                   	pop    %ebp
  801001:	c3                   	ret    

00801002 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801002:	55                   	push   %ebp
  801003:	89 e5                	mov    %esp,%ebp
  801005:	53                   	push   %ebx
  801006:	83 ec 14             	sub    $0x14,%esp
  801009:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80100c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80100f:	50                   	push   %eax
  801010:	53                   	push   %ebx
  801011:	e8 86 fd ff ff       	call   800d9c <fd_lookup>
  801016:	83 c4 08             	add    $0x8,%esp
  801019:	89 c2                	mov    %eax,%edx
  80101b:	85 c0                	test   %eax,%eax
  80101d:	78 6d                	js     80108c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80101f:	83 ec 08             	sub    $0x8,%esp
  801022:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801025:	50                   	push   %eax
  801026:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801029:	ff 30                	pushl  (%eax)
  80102b:	e8 c2 fd ff ff       	call   800df2 <dev_lookup>
  801030:	83 c4 10             	add    $0x10,%esp
  801033:	85 c0                	test   %eax,%eax
  801035:	78 4c                	js     801083 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801037:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80103a:	8b 42 08             	mov    0x8(%edx),%eax
  80103d:	83 e0 03             	and    $0x3,%eax
  801040:	83 f8 01             	cmp    $0x1,%eax
  801043:	75 21                	jne    801066 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801045:	a1 04 40 80 00       	mov    0x804004,%eax
  80104a:	8b 40 50             	mov    0x50(%eax),%eax
  80104d:	83 ec 04             	sub    $0x4,%esp
  801050:	53                   	push   %ebx
  801051:	50                   	push   %eax
  801052:	68 cd 21 80 00       	push   $0x8021cd
  801057:	e8 31 f1 ff ff       	call   80018d <cprintf>
		return -E_INVAL;
  80105c:	83 c4 10             	add    $0x10,%esp
  80105f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801064:	eb 26                	jmp    80108c <read+0x8a>
	}
	if (!dev->dev_read)
  801066:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801069:	8b 40 08             	mov    0x8(%eax),%eax
  80106c:	85 c0                	test   %eax,%eax
  80106e:	74 17                	je     801087 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801070:	83 ec 04             	sub    $0x4,%esp
  801073:	ff 75 10             	pushl  0x10(%ebp)
  801076:	ff 75 0c             	pushl  0xc(%ebp)
  801079:	52                   	push   %edx
  80107a:	ff d0                	call   *%eax
  80107c:	89 c2                	mov    %eax,%edx
  80107e:	83 c4 10             	add    $0x10,%esp
  801081:	eb 09                	jmp    80108c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801083:	89 c2                	mov    %eax,%edx
  801085:	eb 05                	jmp    80108c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801087:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80108c:	89 d0                	mov    %edx,%eax
  80108e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801091:	c9                   	leave  
  801092:	c3                   	ret    

00801093 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801093:	55                   	push   %ebp
  801094:	89 e5                	mov    %esp,%ebp
  801096:	57                   	push   %edi
  801097:	56                   	push   %esi
  801098:	53                   	push   %ebx
  801099:	83 ec 0c             	sub    $0xc,%esp
  80109c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80109f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010a7:	eb 21                	jmp    8010ca <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010a9:	83 ec 04             	sub    $0x4,%esp
  8010ac:	89 f0                	mov    %esi,%eax
  8010ae:	29 d8                	sub    %ebx,%eax
  8010b0:	50                   	push   %eax
  8010b1:	89 d8                	mov    %ebx,%eax
  8010b3:	03 45 0c             	add    0xc(%ebp),%eax
  8010b6:	50                   	push   %eax
  8010b7:	57                   	push   %edi
  8010b8:	e8 45 ff ff ff       	call   801002 <read>
		if (m < 0)
  8010bd:	83 c4 10             	add    $0x10,%esp
  8010c0:	85 c0                	test   %eax,%eax
  8010c2:	78 10                	js     8010d4 <readn+0x41>
			return m;
		if (m == 0)
  8010c4:	85 c0                	test   %eax,%eax
  8010c6:	74 0a                	je     8010d2 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010c8:	01 c3                	add    %eax,%ebx
  8010ca:	39 f3                	cmp    %esi,%ebx
  8010cc:	72 db                	jb     8010a9 <readn+0x16>
  8010ce:	89 d8                	mov    %ebx,%eax
  8010d0:	eb 02                	jmp    8010d4 <readn+0x41>
  8010d2:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d7:	5b                   	pop    %ebx
  8010d8:	5e                   	pop    %esi
  8010d9:	5f                   	pop    %edi
  8010da:	5d                   	pop    %ebp
  8010db:	c3                   	ret    

008010dc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	53                   	push   %ebx
  8010e0:	83 ec 14             	sub    $0x14,%esp
  8010e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010e9:	50                   	push   %eax
  8010ea:	53                   	push   %ebx
  8010eb:	e8 ac fc ff ff       	call   800d9c <fd_lookup>
  8010f0:	83 c4 08             	add    $0x8,%esp
  8010f3:	89 c2                	mov    %eax,%edx
  8010f5:	85 c0                	test   %eax,%eax
  8010f7:	78 68                	js     801161 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010f9:	83 ec 08             	sub    $0x8,%esp
  8010fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ff:	50                   	push   %eax
  801100:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801103:	ff 30                	pushl  (%eax)
  801105:	e8 e8 fc ff ff       	call   800df2 <dev_lookup>
  80110a:	83 c4 10             	add    $0x10,%esp
  80110d:	85 c0                	test   %eax,%eax
  80110f:	78 47                	js     801158 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801111:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801114:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801118:	75 21                	jne    80113b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80111a:	a1 04 40 80 00       	mov    0x804004,%eax
  80111f:	8b 40 50             	mov    0x50(%eax),%eax
  801122:	83 ec 04             	sub    $0x4,%esp
  801125:	53                   	push   %ebx
  801126:	50                   	push   %eax
  801127:	68 e9 21 80 00       	push   $0x8021e9
  80112c:	e8 5c f0 ff ff       	call   80018d <cprintf>
		return -E_INVAL;
  801131:	83 c4 10             	add    $0x10,%esp
  801134:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801139:	eb 26                	jmp    801161 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80113b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80113e:	8b 52 0c             	mov    0xc(%edx),%edx
  801141:	85 d2                	test   %edx,%edx
  801143:	74 17                	je     80115c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801145:	83 ec 04             	sub    $0x4,%esp
  801148:	ff 75 10             	pushl  0x10(%ebp)
  80114b:	ff 75 0c             	pushl  0xc(%ebp)
  80114e:	50                   	push   %eax
  80114f:	ff d2                	call   *%edx
  801151:	89 c2                	mov    %eax,%edx
  801153:	83 c4 10             	add    $0x10,%esp
  801156:	eb 09                	jmp    801161 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801158:	89 c2                	mov    %eax,%edx
  80115a:	eb 05                	jmp    801161 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80115c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801161:	89 d0                	mov    %edx,%eax
  801163:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801166:	c9                   	leave  
  801167:	c3                   	ret    

00801168 <seek>:

int
seek(int fdnum, off_t offset)
{
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
  80116b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80116e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801171:	50                   	push   %eax
  801172:	ff 75 08             	pushl  0x8(%ebp)
  801175:	e8 22 fc ff ff       	call   800d9c <fd_lookup>
  80117a:	83 c4 08             	add    $0x8,%esp
  80117d:	85 c0                	test   %eax,%eax
  80117f:	78 0e                	js     80118f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801181:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801184:	8b 55 0c             	mov    0xc(%ebp),%edx
  801187:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80118a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80118f:	c9                   	leave  
  801190:	c3                   	ret    

00801191 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801191:	55                   	push   %ebp
  801192:	89 e5                	mov    %esp,%ebp
  801194:	53                   	push   %ebx
  801195:	83 ec 14             	sub    $0x14,%esp
  801198:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80119b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80119e:	50                   	push   %eax
  80119f:	53                   	push   %ebx
  8011a0:	e8 f7 fb ff ff       	call   800d9c <fd_lookup>
  8011a5:	83 c4 08             	add    $0x8,%esp
  8011a8:	89 c2                	mov    %eax,%edx
  8011aa:	85 c0                	test   %eax,%eax
  8011ac:	78 65                	js     801213 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ae:	83 ec 08             	sub    $0x8,%esp
  8011b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b4:	50                   	push   %eax
  8011b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b8:	ff 30                	pushl  (%eax)
  8011ba:	e8 33 fc ff ff       	call   800df2 <dev_lookup>
  8011bf:	83 c4 10             	add    $0x10,%esp
  8011c2:	85 c0                	test   %eax,%eax
  8011c4:	78 44                	js     80120a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011cd:	75 21                	jne    8011f0 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011cf:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011d4:	8b 40 50             	mov    0x50(%eax),%eax
  8011d7:	83 ec 04             	sub    $0x4,%esp
  8011da:	53                   	push   %ebx
  8011db:	50                   	push   %eax
  8011dc:	68 ac 21 80 00       	push   $0x8021ac
  8011e1:	e8 a7 ef ff ff       	call   80018d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011e6:	83 c4 10             	add    $0x10,%esp
  8011e9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011ee:	eb 23                	jmp    801213 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011f3:	8b 52 18             	mov    0x18(%edx),%edx
  8011f6:	85 d2                	test   %edx,%edx
  8011f8:	74 14                	je     80120e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011fa:	83 ec 08             	sub    $0x8,%esp
  8011fd:	ff 75 0c             	pushl  0xc(%ebp)
  801200:	50                   	push   %eax
  801201:	ff d2                	call   *%edx
  801203:	89 c2                	mov    %eax,%edx
  801205:	83 c4 10             	add    $0x10,%esp
  801208:	eb 09                	jmp    801213 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80120a:	89 c2                	mov    %eax,%edx
  80120c:	eb 05                	jmp    801213 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80120e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801213:	89 d0                	mov    %edx,%eax
  801215:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801218:	c9                   	leave  
  801219:	c3                   	ret    

0080121a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
  80121d:	53                   	push   %ebx
  80121e:	83 ec 14             	sub    $0x14,%esp
  801221:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801224:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801227:	50                   	push   %eax
  801228:	ff 75 08             	pushl  0x8(%ebp)
  80122b:	e8 6c fb ff ff       	call   800d9c <fd_lookup>
  801230:	83 c4 08             	add    $0x8,%esp
  801233:	89 c2                	mov    %eax,%edx
  801235:	85 c0                	test   %eax,%eax
  801237:	78 58                	js     801291 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801239:	83 ec 08             	sub    $0x8,%esp
  80123c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80123f:	50                   	push   %eax
  801240:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801243:	ff 30                	pushl  (%eax)
  801245:	e8 a8 fb ff ff       	call   800df2 <dev_lookup>
  80124a:	83 c4 10             	add    $0x10,%esp
  80124d:	85 c0                	test   %eax,%eax
  80124f:	78 37                	js     801288 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801251:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801254:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801258:	74 32                	je     80128c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80125a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80125d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801264:	00 00 00 
	stat->st_isdir = 0;
  801267:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80126e:	00 00 00 
	stat->st_dev = dev;
  801271:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801277:	83 ec 08             	sub    $0x8,%esp
  80127a:	53                   	push   %ebx
  80127b:	ff 75 f0             	pushl  -0x10(%ebp)
  80127e:	ff 50 14             	call   *0x14(%eax)
  801281:	89 c2                	mov    %eax,%edx
  801283:	83 c4 10             	add    $0x10,%esp
  801286:	eb 09                	jmp    801291 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801288:	89 c2                	mov    %eax,%edx
  80128a:	eb 05                	jmp    801291 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80128c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801291:	89 d0                	mov    %edx,%eax
  801293:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801296:	c9                   	leave  
  801297:	c3                   	ret    

00801298 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	56                   	push   %esi
  80129c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80129d:	83 ec 08             	sub    $0x8,%esp
  8012a0:	6a 00                	push   $0x0
  8012a2:	ff 75 08             	pushl  0x8(%ebp)
  8012a5:	e8 e3 01 00 00       	call   80148d <open>
  8012aa:	89 c3                	mov    %eax,%ebx
  8012ac:	83 c4 10             	add    $0x10,%esp
  8012af:	85 c0                	test   %eax,%eax
  8012b1:	78 1b                	js     8012ce <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012b3:	83 ec 08             	sub    $0x8,%esp
  8012b6:	ff 75 0c             	pushl  0xc(%ebp)
  8012b9:	50                   	push   %eax
  8012ba:	e8 5b ff ff ff       	call   80121a <fstat>
  8012bf:	89 c6                	mov    %eax,%esi
	close(fd);
  8012c1:	89 1c 24             	mov    %ebx,(%esp)
  8012c4:	e8 fd fb ff ff       	call   800ec6 <close>
	return r;
  8012c9:	83 c4 10             	add    $0x10,%esp
  8012cc:	89 f0                	mov    %esi,%eax
}
  8012ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012d1:	5b                   	pop    %ebx
  8012d2:	5e                   	pop    %esi
  8012d3:	5d                   	pop    %ebp
  8012d4:	c3                   	ret    

008012d5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012d5:	55                   	push   %ebp
  8012d6:	89 e5                	mov    %esp,%ebp
  8012d8:	56                   	push   %esi
  8012d9:	53                   	push   %ebx
  8012da:	89 c6                	mov    %eax,%esi
  8012dc:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012de:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012e5:	75 12                	jne    8012f9 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012e7:	83 ec 0c             	sub    $0xc,%esp
  8012ea:	6a 01                	push   $0x1
  8012ec:	e8 3c 08 00 00       	call   801b2d <ipc_find_env>
  8012f1:	a3 00 40 80 00       	mov    %eax,0x804000
  8012f6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012f9:	6a 07                	push   $0x7
  8012fb:	68 00 50 80 00       	push   $0x805000
  801300:	56                   	push   %esi
  801301:	ff 35 00 40 80 00    	pushl  0x804000
  801307:	e8 bf 07 00 00       	call   801acb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80130c:	83 c4 0c             	add    $0xc,%esp
  80130f:	6a 00                	push   $0x0
  801311:	53                   	push   %ebx
  801312:	6a 00                	push   $0x0
  801314:	e8 3d 07 00 00       	call   801a56 <ipc_recv>
}
  801319:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80131c:	5b                   	pop    %ebx
  80131d:	5e                   	pop    %esi
  80131e:	5d                   	pop    %ebp
  80131f:	c3                   	ret    

00801320 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
  801323:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801326:	8b 45 08             	mov    0x8(%ebp),%eax
  801329:	8b 40 0c             	mov    0xc(%eax),%eax
  80132c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801331:	8b 45 0c             	mov    0xc(%ebp),%eax
  801334:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801339:	ba 00 00 00 00       	mov    $0x0,%edx
  80133e:	b8 02 00 00 00       	mov    $0x2,%eax
  801343:	e8 8d ff ff ff       	call   8012d5 <fsipc>
}
  801348:	c9                   	leave  
  801349:	c3                   	ret    

0080134a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80134a:	55                   	push   %ebp
  80134b:	89 e5                	mov    %esp,%ebp
  80134d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801350:	8b 45 08             	mov    0x8(%ebp),%eax
  801353:	8b 40 0c             	mov    0xc(%eax),%eax
  801356:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80135b:	ba 00 00 00 00       	mov    $0x0,%edx
  801360:	b8 06 00 00 00       	mov    $0x6,%eax
  801365:	e8 6b ff ff ff       	call   8012d5 <fsipc>
}
  80136a:	c9                   	leave  
  80136b:	c3                   	ret    

0080136c <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80136c:	55                   	push   %ebp
  80136d:	89 e5                	mov    %esp,%ebp
  80136f:	53                   	push   %ebx
  801370:	83 ec 04             	sub    $0x4,%esp
  801373:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801376:	8b 45 08             	mov    0x8(%ebp),%eax
  801379:	8b 40 0c             	mov    0xc(%eax),%eax
  80137c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801381:	ba 00 00 00 00       	mov    $0x0,%edx
  801386:	b8 05 00 00 00       	mov    $0x5,%eax
  80138b:	e8 45 ff ff ff       	call   8012d5 <fsipc>
  801390:	85 c0                	test   %eax,%eax
  801392:	78 2c                	js     8013c0 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801394:	83 ec 08             	sub    $0x8,%esp
  801397:	68 00 50 80 00       	push   $0x805000
  80139c:	53                   	push   %ebx
  80139d:	e8 70 f3 ff ff       	call   800712 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013a2:	a1 80 50 80 00       	mov    0x805080,%eax
  8013a7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013ad:	a1 84 50 80 00       	mov    0x805084,%eax
  8013b2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013b8:	83 c4 10             	add    $0x10,%esp
  8013bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c3:	c9                   	leave  
  8013c4:	c3                   	ret    

008013c5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013c5:	55                   	push   %ebp
  8013c6:	89 e5                	mov    %esp,%ebp
  8013c8:	83 ec 0c             	sub    $0xc,%esp
  8013cb:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8013d1:	8b 52 0c             	mov    0xc(%edx),%edx
  8013d4:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8013da:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8013df:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8013e4:	0f 47 c2             	cmova  %edx,%eax
  8013e7:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8013ec:	50                   	push   %eax
  8013ed:	ff 75 0c             	pushl  0xc(%ebp)
  8013f0:	68 08 50 80 00       	push   $0x805008
  8013f5:	e8 aa f4 ff ff       	call   8008a4 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8013fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ff:	b8 04 00 00 00       	mov    $0x4,%eax
  801404:	e8 cc fe ff ff       	call   8012d5 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801409:	c9                   	leave  
  80140a:	c3                   	ret    

0080140b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80140b:	55                   	push   %ebp
  80140c:	89 e5                	mov    %esp,%ebp
  80140e:	56                   	push   %esi
  80140f:	53                   	push   %ebx
  801410:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801413:	8b 45 08             	mov    0x8(%ebp),%eax
  801416:	8b 40 0c             	mov    0xc(%eax),%eax
  801419:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80141e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801424:	ba 00 00 00 00       	mov    $0x0,%edx
  801429:	b8 03 00 00 00       	mov    $0x3,%eax
  80142e:	e8 a2 fe ff ff       	call   8012d5 <fsipc>
  801433:	89 c3                	mov    %eax,%ebx
  801435:	85 c0                	test   %eax,%eax
  801437:	78 4b                	js     801484 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801439:	39 c6                	cmp    %eax,%esi
  80143b:	73 16                	jae    801453 <devfile_read+0x48>
  80143d:	68 18 22 80 00       	push   $0x802218
  801442:	68 1f 22 80 00       	push   $0x80221f
  801447:	6a 7c                	push   $0x7c
  801449:	68 34 22 80 00       	push   $0x802234
  80144e:	e8 bd 05 00 00       	call   801a10 <_panic>
	assert(r <= PGSIZE);
  801453:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801458:	7e 16                	jle    801470 <devfile_read+0x65>
  80145a:	68 3f 22 80 00       	push   $0x80223f
  80145f:	68 1f 22 80 00       	push   $0x80221f
  801464:	6a 7d                	push   $0x7d
  801466:	68 34 22 80 00       	push   $0x802234
  80146b:	e8 a0 05 00 00       	call   801a10 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801470:	83 ec 04             	sub    $0x4,%esp
  801473:	50                   	push   %eax
  801474:	68 00 50 80 00       	push   $0x805000
  801479:	ff 75 0c             	pushl  0xc(%ebp)
  80147c:	e8 23 f4 ff ff       	call   8008a4 <memmove>
	return r;
  801481:	83 c4 10             	add    $0x10,%esp
}
  801484:	89 d8                	mov    %ebx,%eax
  801486:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801489:	5b                   	pop    %ebx
  80148a:	5e                   	pop    %esi
  80148b:	5d                   	pop    %ebp
  80148c:	c3                   	ret    

0080148d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80148d:	55                   	push   %ebp
  80148e:	89 e5                	mov    %esp,%ebp
  801490:	53                   	push   %ebx
  801491:	83 ec 20             	sub    $0x20,%esp
  801494:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801497:	53                   	push   %ebx
  801498:	e8 3c f2 ff ff       	call   8006d9 <strlen>
  80149d:	83 c4 10             	add    $0x10,%esp
  8014a0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014a5:	7f 67                	jg     80150e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014a7:	83 ec 0c             	sub    $0xc,%esp
  8014aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ad:	50                   	push   %eax
  8014ae:	e8 9a f8 ff ff       	call   800d4d <fd_alloc>
  8014b3:	83 c4 10             	add    $0x10,%esp
		return r;
  8014b6:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014b8:	85 c0                	test   %eax,%eax
  8014ba:	78 57                	js     801513 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014bc:	83 ec 08             	sub    $0x8,%esp
  8014bf:	53                   	push   %ebx
  8014c0:	68 00 50 80 00       	push   $0x805000
  8014c5:	e8 48 f2 ff ff       	call   800712 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014cd:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8014da:	e8 f6 fd ff ff       	call   8012d5 <fsipc>
  8014df:	89 c3                	mov    %eax,%ebx
  8014e1:	83 c4 10             	add    $0x10,%esp
  8014e4:	85 c0                	test   %eax,%eax
  8014e6:	79 14                	jns    8014fc <open+0x6f>
		fd_close(fd, 0);
  8014e8:	83 ec 08             	sub    $0x8,%esp
  8014eb:	6a 00                	push   $0x0
  8014ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8014f0:	e8 50 f9 ff ff       	call   800e45 <fd_close>
		return r;
  8014f5:	83 c4 10             	add    $0x10,%esp
  8014f8:	89 da                	mov    %ebx,%edx
  8014fa:	eb 17                	jmp    801513 <open+0x86>
	}

	return fd2num(fd);
  8014fc:	83 ec 0c             	sub    $0xc,%esp
  8014ff:	ff 75 f4             	pushl  -0xc(%ebp)
  801502:	e8 1f f8 ff ff       	call   800d26 <fd2num>
  801507:	89 c2                	mov    %eax,%edx
  801509:	83 c4 10             	add    $0x10,%esp
  80150c:	eb 05                	jmp    801513 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80150e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801513:	89 d0                	mov    %edx,%eax
  801515:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801518:	c9                   	leave  
  801519:	c3                   	ret    

0080151a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80151a:	55                   	push   %ebp
  80151b:	89 e5                	mov    %esp,%ebp
  80151d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801520:	ba 00 00 00 00       	mov    $0x0,%edx
  801525:	b8 08 00 00 00       	mov    $0x8,%eax
  80152a:	e8 a6 fd ff ff       	call   8012d5 <fsipc>
}
  80152f:	c9                   	leave  
  801530:	c3                   	ret    

00801531 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801531:	55                   	push   %ebp
  801532:	89 e5                	mov    %esp,%ebp
  801534:	56                   	push   %esi
  801535:	53                   	push   %ebx
  801536:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801539:	83 ec 0c             	sub    $0xc,%esp
  80153c:	ff 75 08             	pushl  0x8(%ebp)
  80153f:	e8 f2 f7 ff ff       	call   800d36 <fd2data>
  801544:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801546:	83 c4 08             	add    $0x8,%esp
  801549:	68 4b 22 80 00       	push   $0x80224b
  80154e:	53                   	push   %ebx
  80154f:	e8 be f1 ff ff       	call   800712 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801554:	8b 46 04             	mov    0x4(%esi),%eax
  801557:	2b 06                	sub    (%esi),%eax
  801559:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80155f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801566:	00 00 00 
	stat->st_dev = &devpipe;
  801569:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801570:	30 80 00 
	return 0;
}
  801573:	b8 00 00 00 00       	mov    $0x0,%eax
  801578:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80157b:	5b                   	pop    %ebx
  80157c:	5e                   	pop    %esi
  80157d:	5d                   	pop    %ebp
  80157e:	c3                   	ret    

0080157f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80157f:	55                   	push   %ebp
  801580:	89 e5                	mov    %esp,%ebp
  801582:	53                   	push   %ebx
  801583:	83 ec 0c             	sub    $0xc,%esp
  801586:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801589:	53                   	push   %ebx
  80158a:	6a 00                	push   $0x0
  80158c:	e8 09 f6 ff ff       	call   800b9a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801591:	89 1c 24             	mov    %ebx,(%esp)
  801594:	e8 9d f7 ff ff       	call   800d36 <fd2data>
  801599:	83 c4 08             	add    $0x8,%esp
  80159c:	50                   	push   %eax
  80159d:	6a 00                	push   $0x0
  80159f:	e8 f6 f5 ff ff       	call   800b9a <sys_page_unmap>
}
  8015a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a7:	c9                   	leave  
  8015a8:	c3                   	ret    

008015a9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015a9:	55                   	push   %ebp
  8015aa:	89 e5                	mov    %esp,%ebp
  8015ac:	57                   	push   %edi
  8015ad:	56                   	push   %esi
  8015ae:	53                   	push   %ebx
  8015af:	83 ec 1c             	sub    $0x1c,%esp
  8015b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015b5:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015b7:	a1 04 40 80 00       	mov    0x804004,%eax
  8015bc:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015bf:	83 ec 0c             	sub    $0xc,%esp
  8015c2:	ff 75 e0             	pushl  -0x20(%ebp)
  8015c5:	e8 a3 05 00 00       	call   801b6d <pageref>
  8015ca:	89 c3                	mov    %eax,%ebx
  8015cc:	89 3c 24             	mov    %edi,(%esp)
  8015cf:	e8 99 05 00 00       	call   801b6d <pageref>
  8015d4:	83 c4 10             	add    $0x10,%esp
  8015d7:	39 c3                	cmp    %eax,%ebx
  8015d9:	0f 94 c1             	sete   %cl
  8015dc:	0f b6 c9             	movzbl %cl,%ecx
  8015df:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8015e2:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8015e8:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  8015eb:	39 ce                	cmp    %ecx,%esi
  8015ed:	74 1b                	je     80160a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8015ef:	39 c3                	cmp    %eax,%ebx
  8015f1:	75 c4                	jne    8015b7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015f3:	8b 42 60             	mov    0x60(%edx),%eax
  8015f6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015f9:	50                   	push   %eax
  8015fa:	56                   	push   %esi
  8015fb:	68 52 22 80 00       	push   $0x802252
  801600:	e8 88 eb ff ff       	call   80018d <cprintf>
  801605:	83 c4 10             	add    $0x10,%esp
  801608:	eb ad                	jmp    8015b7 <_pipeisclosed+0xe>
	}
}
  80160a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80160d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801610:	5b                   	pop    %ebx
  801611:	5e                   	pop    %esi
  801612:	5f                   	pop    %edi
  801613:	5d                   	pop    %ebp
  801614:	c3                   	ret    

00801615 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801615:	55                   	push   %ebp
  801616:	89 e5                	mov    %esp,%ebp
  801618:	57                   	push   %edi
  801619:	56                   	push   %esi
  80161a:	53                   	push   %ebx
  80161b:	83 ec 28             	sub    $0x28,%esp
  80161e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801621:	56                   	push   %esi
  801622:	e8 0f f7 ff ff       	call   800d36 <fd2data>
  801627:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801629:	83 c4 10             	add    $0x10,%esp
  80162c:	bf 00 00 00 00       	mov    $0x0,%edi
  801631:	eb 4b                	jmp    80167e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801633:	89 da                	mov    %ebx,%edx
  801635:	89 f0                	mov    %esi,%eax
  801637:	e8 6d ff ff ff       	call   8015a9 <_pipeisclosed>
  80163c:	85 c0                	test   %eax,%eax
  80163e:	75 48                	jne    801688 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801640:	e8 b1 f4 ff ff       	call   800af6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801645:	8b 43 04             	mov    0x4(%ebx),%eax
  801648:	8b 0b                	mov    (%ebx),%ecx
  80164a:	8d 51 20             	lea    0x20(%ecx),%edx
  80164d:	39 d0                	cmp    %edx,%eax
  80164f:	73 e2                	jae    801633 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801651:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801654:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801658:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80165b:	89 c2                	mov    %eax,%edx
  80165d:	c1 fa 1f             	sar    $0x1f,%edx
  801660:	89 d1                	mov    %edx,%ecx
  801662:	c1 e9 1b             	shr    $0x1b,%ecx
  801665:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801668:	83 e2 1f             	and    $0x1f,%edx
  80166b:	29 ca                	sub    %ecx,%edx
  80166d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801671:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801675:	83 c0 01             	add    $0x1,%eax
  801678:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80167b:	83 c7 01             	add    $0x1,%edi
  80167e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801681:	75 c2                	jne    801645 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801683:	8b 45 10             	mov    0x10(%ebp),%eax
  801686:	eb 05                	jmp    80168d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801688:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80168d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801690:	5b                   	pop    %ebx
  801691:	5e                   	pop    %esi
  801692:	5f                   	pop    %edi
  801693:	5d                   	pop    %ebp
  801694:	c3                   	ret    

00801695 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801695:	55                   	push   %ebp
  801696:	89 e5                	mov    %esp,%ebp
  801698:	57                   	push   %edi
  801699:	56                   	push   %esi
  80169a:	53                   	push   %ebx
  80169b:	83 ec 18             	sub    $0x18,%esp
  80169e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016a1:	57                   	push   %edi
  8016a2:	e8 8f f6 ff ff       	call   800d36 <fd2data>
  8016a7:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016a9:	83 c4 10             	add    $0x10,%esp
  8016ac:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016b1:	eb 3d                	jmp    8016f0 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8016b3:	85 db                	test   %ebx,%ebx
  8016b5:	74 04                	je     8016bb <devpipe_read+0x26>
				return i;
  8016b7:	89 d8                	mov    %ebx,%eax
  8016b9:	eb 44                	jmp    8016ff <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016bb:	89 f2                	mov    %esi,%edx
  8016bd:	89 f8                	mov    %edi,%eax
  8016bf:	e8 e5 fe ff ff       	call   8015a9 <_pipeisclosed>
  8016c4:	85 c0                	test   %eax,%eax
  8016c6:	75 32                	jne    8016fa <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016c8:	e8 29 f4 ff ff       	call   800af6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016cd:	8b 06                	mov    (%esi),%eax
  8016cf:	3b 46 04             	cmp    0x4(%esi),%eax
  8016d2:	74 df                	je     8016b3 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016d4:	99                   	cltd   
  8016d5:	c1 ea 1b             	shr    $0x1b,%edx
  8016d8:	01 d0                	add    %edx,%eax
  8016da:	83 e0 1f             	and    $0x1f,%eax
  8016dd:	29 d0                	sub    %edx,%eax
  8016df:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016e7:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016ea:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016ed:	83 c3 01             	add    $0x1,%ebx
  8016f0:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016f3:	75 d8                	jne    8016cd <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8016f8:	eb 05                	jmp    8016ff <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016fa:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801702:	5b                   	pop    %ebx
  801703:	5e                   	pop    %esi
  801704:	5f                   	pop    %edi
  801705:	5d                   	pop    %ebp
  801706:	c3                   	ret    

00801707 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801707:	55                   	push   %ebp
  801708:	89 e5                	mov    %esp,%ebp
  80170a:	56                   	push   %esi
  80170b:	53                   	push   %ebx
  80170c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80170f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801712:	50                   	push   %eax
  801713:	e8 35 f6 ff ff       	call   800d4d <fd_alloc>
  801718:	83 c4 10             	add    $0x10,%esp
  80171b:	89 c2                	mov    %eax,%edx
  80171d:	85 c0                	test   %eax,%eax
  80171f:	0f 88 2c 01 00 00    	js     801851 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801725:	83 ec 04             	sub    $0x4,%esp
  801728:	68 07 04 00 00       	push   $0x407
  80172d:	ff 75 f4             	pushl  -0xc(%ebp)
  801730:	6a 00                	push   $0x0
  801732:	e8 de f3 ff ff       	call   800b15 <sys_page_alloc>
  801737:	83 c4 10             	add    $0x10,%esp
  80173a:	89 c2                	mov    %eax,%edx
  80173c:	85 c0                	test   %eax,%eax
  80173e:	0f 88 0d 01 00 00    	js     801851 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801744:	83 ec 0c             	sub    $0xc,%esp
  801747:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80174a:	50                   	push   %eax
  80174b:	e8 fd f5 ff ff       	call   800d4d <fd_alloc>
  801750:	89 c3                	mov    %eax,%ebx
  801752:	83 c4 10             	add    $0x10,%esp
  801755:	85 c0                	test   %eax,%eax
  801757:	0f 88 e2 00 00 00    	js     80183f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80175d:	83 ec 04             	sub    $0x4,%esp
  801760:	68 07 04 00 00       	push   $0x407
  801765:	ff 75 f0             	pushl  -0x10(%ebp)
  801768:	6a 00                	push   $0x0
  80176a:	e8 a6 f3 ff ff       	call   800b15 <sys_page_alloc>
  80176f:	89 c3                	mov    %eax,%ebx
  801771:	83 c4 10             	add    $0x10,%esp
  801774:	85 c0                	test   %eax,%eax
  801776:	0f 88 c3 00 00 00    	js     80183f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80177c:	83 ec 0c             	sub    $0xc,%esp
  80177f:	ff 75 f4             	pushl  -0xc(%ebp)
  801782:	e8 af f5 ff ff       	call   800d36 <fd2data>
  801787:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801789:	83 c4 0c             	add    $0xc,%esp
  80178c:	68 07 04 00 00       	push   $0x407
  801791:	50                   	push   %eax
  801792:	6a 00                	push   $0x0
  801794:	e8 7c f3 ff ff       	call   800b15 <sys_page_alloc>
  801799:	89 c3                	mov    %eax,%ebx
  80179b:	83 c4 10             	add    $0x10,%esp
  80179e:	85 c0                	test   %eax,%eax
  8017a0:	0f 88 89 00 00 00    	js     80182f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017a6:	83 ec 0c             	sub    $0xc,%esp
  8017a9:	ff 75 f0             	pushl  -0x10(%ebp)
  8017ac:	e8 85 f5 ff ff       	call   800d36 <fd2data>
  8017b1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017b8:	50                   	push   %eax
  8017b9:	6a 00                	push   $0x0
  8017bb:	56                   	push   %esi
  8017bc:	6a 00                	push   $0x0
  8017be:	e8 95 f3 ff ff       	call   800b58 <sys_page_map>
  8017c3:	89 c3                	mov    %eax,%ebx
  8017c5:	83 c4 20             	add    $0x20,%esp
  8017c8:	85 c0                	test   %eax,%eax
  8017ca:	78 55                	js     801821 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017cc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017da:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017e1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ea:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ef:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017f6:	83 ec 0c             	sub    $0xc,%esp
  8017f9:	ff 75 f4             	pushl  -0xc(%ebp)
  8017fc:	e8 25 f5 ff ff       	call   800d26 <fd2num>
  801801:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801804:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801806:	83 c4 04             	add    $0x4,%esp
  801809:	ff 75 f0             	pushl  -0x10(%ebp)
  80180c:	e8 15 f5 ff ff       	call   800d26 <fd2num>
  801811:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801814:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801817:	83 c4 10             	add    $0x10,%esp
  80181a:	ba 00 00 00 00       	mov    $0x0,%edx
  80181f:	eb 30                	jmp    801851 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801821:	83 ec 08             	sub    $0x8,%esp
  801824:	56                   	push   %esi
  801825:	6a 00                	push   $0x0
  801827:	e8 6e f3 ff ff       	call   800b9a <sys_page_unmap>
  80182c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80182f:	83 ec 08             	sub    $0x8,%esp
  801832:	ff 75 f0             	pushl  -0x10(%ebp)
  801835:	6a 00                	push   $0x0
  801837:	e8 5e f3 ff ff       	call   800b9a <sys_page_unmap>
  80183c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80183f:	83 ec 08             	sub    $0x8,%esp
  801842:	ff 75 f4             	pushl  -0xc(%ebp)
  801845:	6a 00                	push   $0x0
  801847:	e8 4e f3 ff ff       	call   800b9a <sys_page_unmap>
  80184c:	83 c4 10             	add    $0x10,%esp
  80184f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801851:	89 d0                	mov    %edx,%eax
  801853:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801856:	5b                   	pop    %ebx
  801857:	5e                   	pop    %esi
  801858:	5d                   	pop    %ebp
  801859:	c3                   	ret    

0080185a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80185a:	55                   	push   %ebp
  80185b:	89 e5                	mov    %esp,%ebp
  80185d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801860:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801863:	50                   	push   %eax
  801864:	ff 75 08             	pushl  0x8(%ebp)
  801867:	e8 30 f5 ff ff       	call   800d9c <fd_lookup>
  80186c:	83 c4 10             	add    $0x10,%esp
  80186f:	85 c0                	test   %eax,%eax
  801871:	78 18                	js     80188b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801873:	83 ec 0c             	sub    $0xc,%esp
  801876:	ff 75 f4             	pushl  -0xc(%ebp)
  801879:	e8 b8 f4 ff ff       	call   800d36 <fd2data>
	return _pipeisclosed(fd, p);
  80187e:	89 c2                	mov    %eax,%edx
  801880:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801883:	e8 21 fd ff ff       	call   8015a9 <_pipeisclosed>
  801888:	83 c4 10             	add    $0x10,%esp
}
  80188b:	c9                   	leave  
  80188c:	c3                   	ret    

0080188d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80188d:	55                   	push   %ebp
  80188e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801890:	b8 00 00 00 00       	mov    $0x0,%eax
  801895:	5d                   	pop    %ebp
  801896:	c3                   	ret    

00801897 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801897:	55                   	push   %ebp
  801898:	89 e5                	mov    %esp,%ebp
  80189a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80189d:	68 6a 22 80 00       	push   $0x80226a
  8018a2:	ff 75 0c             	pushl  0xc(%ebp)
  8018a5:	e8 68 ee ff ff       	call   800712 <strcpy>
	return 0;
}
  8018aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8018af:	c9                   	leave  
  8018b0:	c3                   	ret    

008018b1 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018b1:	55                   	push   %ebp
  8018b2:	89 e5                	mov    %esp,%ebp
  8018b4:	57                   	push   %edi
  8018b5:	56                   	push   %esi
  8018b6:	53                   	push   %ebx
  8018b7:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018bd:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018c2:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018c8:	eb 2d                	jmp    8018f7 <devcons_write+0x46>
		m = n - tot;
  8018ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018cd:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8018cf:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018d2:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8018d7:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018da:	83 ec 04             	sub    $0x4,%esp
  8018dd:	53                   	push   %ebx
  8018de:	03 45 0c             	add    0xc(%ebp),%eax
  8018e1:	50                   	push   %eax
  8018e2:	57                   	push   %edi
  8018e3:	e8 bc ef ff ff       	call   8008a4 <memmove>
		sys_cputs(buf, m);
  8018e8:	83 c4 08             	add    $0x8,%esp
  8018eb:	53                   	push   %ebx
  8018ec:	57                   	push   %edi
  8018ed:	e8 67 f1 ff ff       	call   800a59 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018f2:	01 de                	add    %ebx,%esi
  8018f4:	83 c4 10             	add    $0x10,%esp
  8018f7:	89 f0                	mov    %esi,%eax
  8018f9:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018fc:	72 cc                	jb     8018ca <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8018fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801901:	5b                   	pop    %ebx
  801902:	5e                   	pop    %esi
  801903:	5f                   	pop    %edi
  801904:	5d                   	pop    %ebp
  801905:	c3                   	ret    

00801906 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801906:	55                   	push   %ebp
  801907:	89 e5                	mov    %esp,%ebp
  801909:	83 ec 08             	sub    $0x8,%esp
  80190c:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801911:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801915:	74 2a                	je     801941 <devcons_read+0x3b>
  801917:	eb 05                	jmp    80191e <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801919:	e8 d8 f1 ff ff       	call   800af6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80191e:	e8 54 f1 ff ff       	call   800a77 <sys_cgetc>
  801923:	85 c0                	test   %eax,%eax
  801925:	74 f2                	je     801919 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801927:	85 c0                	test   %eax,%eax
  801929:	78 16                	js     801941 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80192b:	83 f8 04             	cmp    $0x4,%eax
  80192e:	74 0c                	je     80193c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801930:	8b 55 0c             	mov    0xc(%ebp),%edx
  801933:	88 02                	mov    %al,(%edx)
	return 1;
  801935:	b8 01 00 00 00       	mov    $0x1,%eax
  80193a:	eb 05                	jmp    801941 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80193c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801941:	c9                   	leave  
  801942:	c3                   	ret    

00801943 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801943:	55                   	push   %ebp
  801944:	89 e5                	mov    %esp,%ebp
  801946:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801949:	8b 45 08             	mov    0x8(%ebp),%eax
  80194c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80194f:	6a 01                	push   $0x1
  801951:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801954:	50                   	push   %eax
  801955:	e8 ff f0 ff ff       	call   800a59 <sys_cputs>
}
  80195a:	83 c4 10             	add    $0x10,%esp
  80195d:	c9                   	leave  
  80195e:	c3                   	ret    

0080195f <getchar>:

int
getchar(void)
{
  80195f:	55                   	push   %ebp
  801960:	89 e5                	mov    %esp,%ebp
  801962:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801965:	6a 01                	push   $0x1
  801967:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80196a:	50                   	push   %eax
  80196b:	6a 00                	push   $0x0
  80196d:	e8 90 f6 ff ff       	call   801002 <read>
	if (r < 0)
  801972:	83 c4 10             	add    $0x10,%esp
  801975:	85 c0                	test   %eax,%eax
  801977:	78 0f                	js     801988 <getchar+0x29>
		return r;
	if (r < 1)
  801979:	85 c0                	test   %eax,%eax
  80197b:	7e 06                	jle    801983 <getchar+0x24>
		return -E_EOF;
	return c;
  80197d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801981:	eb 05                	jmp    801988 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801983:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801988:	c9                   	leave  
  801989:	c3                   	ret    

0080198a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
  80198d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801990:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801993:	50                   	push   %eax
  801994:	ff 75 08             	pushl  0x8(%ebp)
  801997:	e8 00 f4 ff ff       	call   800d9c <fd_lookup>
  80199c:	83 c4 10             	add    $0x10,%esp
  80199f:	85 c0                	test   %eax,%eax
  8019a1:	78 11                	js     8019b4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8019a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019ac:	39 10                	cmp    %edx,(%eax)
  8019ae:	0f 94 c0             	sete   %al
  8019b1:	0f b6 c0             	movzbl %al,%eax
}
  8019b4:	c9                   	leave  
  8019b5:	c3                   	ret    

008019b6 <opencons>:

int
opencons(void)
{
  8019b6:	55                   	push   %ebp
  8019b7:	89 e5                	mov    %esp,%ebp
  8019b9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019bf:	50                   	push   %eax
  8019c0:	e8 88 f3 ff ff       	call   800d4d <fd_alloc>
  8019c5:	83 c4 10             	add    $0x10,%esp
		return r;
  8019c8:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019ca:	85 c0                	test   %eax,%eax
  8019cc:	78 3e                	js     801a0c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019ce:	83 ec 04             	sub    $0x4,%esp
  8019d1:	68 07 04 00 00       	push   $0x407
  8019d6:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d9:	6a 00                	push   $0x0
  8019db:	e8 35 f1 ff ff       	call   800b15 <sys_page_alloc>
  8019e0:	83 c4 10             	add    $0x10,%esp
		return r;
  8019e3:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019e5:	85 c0                	test   %eax,%eax
  8019e7:	78 23                	js     801a0c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8019e9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019fe:	83 ec 0c             	sub    $0xc,%esp
  801a01:	50                   	push   %eax
  801a02:	e8 1f f3 ff ff       	call   800d26 <fd2num>
  801a07:	89 c2                	mov    %eax,%edx
  801a09:	83 c4 10             	add    $0x10,%esp
}
  801a0c:	89 d0                	mov    %edx,%eax
  801a0e:	c9                   	leave  
  801a0f:	c3                   	ret    

00801a10 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	56                   	push   %esi
  801a14:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a15:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a18:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a1e:	e8 b4 f0 ff ff       	call   800ad7 <sys_getenvid>
  801a23:	83 ec 0c             	sub    $0xc,%esp
  801a26:	ff 75 0c             	pushl  0xc(%ebp)
  801a29:	ff 75 08             	pushl  0x8(%ebp)
  801a2c:	56                   	push   %esi
  801a2d:	50                   	push   %eax
  801a2e:	68 78 22 80 00       	push   $0x802278
  801a33:	e8 55 e7 ff ff       	call   80018d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a38:	83 c4 18             	add    $0x18,%esp
  801a3b:	53                   	push   %ebx
  801a3c:	ff 75 10             	pushl  0x10(%ebp)
  801a3f:	e8 f8 e6 ff ff       	call   80013c <vcprintf>
	cprintf("\n");
  801a44:	c7 04 24 63 22 80 00 	movl   $0x802263,(%esp)
  801a4b:	e8 3d e7 ff ff       	call   80018d <cprintf>
  801a50:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a53:	cc                   	int3   
  801a54:	eb fd                	jmp    801a53 <_panic+0x43>

00801a56 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a56:	55                   	push   %ebp
  801a57:	89 e5                	mov    %esp,%ebp
  801a59:	56                   	push   %esi
  801a5a:	53                   	push   %ebx
  801a5b:	8b 75 08             	mov    0x8(%ebp),%esi
  801a5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a61:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801a64:	85 c0                	test   %eax,%eax
  801a66:	75 12                	jne    801a7a <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801a68:	83 ec 0c             	sub    $0xc,%esp
  801a6b:	68 00 00 c0 ee       	push   $0xeec00000
  801a70:	e8 50 f2 ff ff       	call   800cc5 <sys_ipc_recv>
  801a75:	83 c4 10             	add    $0x10,%esp
  801a78:	eb 0c                	jmp    801a86 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801a7a:	83 ec 0c             	sub    $0xc,%esp
  801a7d:	50                   	push   %eax
  801a7e:	e8 42 f2 ff ff       	call   800cc5 <sys_ipc_recv>
  801a83:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801a86:	85 f6                	test   %esi,%esi
  801a88:	0f 95 c1             	setne  %cl
  801a8b:	85 db                	test   %ebx,%ebx
  801a8d:	0f 95 c2             	setne  %dl
  801a90:	84 d1                	test   %dl,%cl
  801a92:	74 09                	je     801a9d <ipc_recv+0x47>
  801a94:	89 c2                	mov    %eax,%edx
  801a96:	c1 ea 1f             	shr    $0x1f,%edx
  801a99:	84 d2                	test   %dl,%dl
  801a9b:	75 27                	jne    801ac4 <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801a9d:	85 f6                	test   %esi,%esi
  801a9f:	74 0a                	je     801aab <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801aa1:	a1 04 40 80 00       	mov    0x804004,%eax
  801aa6:	8b 40 7c             	mov    0x7c(%eax),%eax
  801aa9:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801aab:	85 db                	test   %ebx,%ebx
  801aad:	74 0d                	je     801abc <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  801aaf:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab4:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801aba:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801abc:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac1:	8b 40 78             	mov    0x78(%eax),%eax
}
  801ac4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ac7:	5b                   	pop    %ebx
  801ac8:	5e                   	pop    %esi
  801ac9:	5d                   	pop    %ebp
  801aca:	c3                   	ret    

00801acb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801acb:	55                   	push   %ebp
  801acc:	89 e5                	mov    %esp,%ebp
  801ace:	57                   	push   %edi
  801acf:	56                   	push   %esi
  801ad0:	53                   	push   %ebx
  801ad1:	83 ec 0c             	sub    $0xc,%esp
  801ad4:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ad7:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ada:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801add:	85 db                	test   %ebx,%ebx
  801adf:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ae4:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801ae7:	ff 75 14             	pushl  0x14(%ebp)
  801aea:	53                   	push   %ebx
  801aeb:	56                   	push   %esi
  801aec:	57                   	push   %edi
  801aed:	e8 b0 f1 ff ff       	call   800ca2 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801af2:	89 c2                	mov    %eax,%edx
  801af4:	c1 ea 1f             	shr    $0x1f,%edx
  801af7:	83 c4 10             	add    $0x10,%esp
  801afa:	84 d2                	test   %dl,%dl
  801afc:	74 17                	je     801b15 <ipc_send+0x4a>
  801afe:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b01:	74 12                	je     801b15 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801b03:	50                   	push   %eax
  801b04:	68 9c 22 80 00       	push   $0x80229c
  801b09:	6a 47                	push   $0x47
  801b0b:	68 aa 22 80 00       	push   $0x8022aa
  801b10:	e8 fb fe ff ff       	call   801a10 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801b15:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b18:	75 07                	jne    801b21 <ipc_send+0x56>
			sys_yield();
  801b1a:	e8 d7 ef ff ff       	call   800af6 <sys_yield>
  801b1f:	eb c6                	jmp    801ae7 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801b21:	85 c0                	test   %eax,%eax
  801b23:	75 c2                	jne    801ae7 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801b25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b28:	5b                   	pop    %ebx
  801b29:	5e                   	pop    %esi
  801b2a:	5f                   	pop    %edi
  801b2b:	5d                   	pop    %ebp
  801b2c:	c3                   	ret    

00801b2d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b2d:	55                   	push   %ebp
  801b2e:	89 e5                	mov    %esp,%ebp
  801b30:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b33:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b38:	89 c2                	mov    %eax,%edx
  801b3a:	c1 e2 07             	shl    $0x7,%edx
  801b3d:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801b44:	8b 52 58             	mov    0x58(%edx),%edx
  801b47:	39 ca                	cmp    %ecx,%edx
  801b49:	75 11                	jne    801b5c <ipc_find_env+0x2f>
			return envs[i].env_id;
  801b4b:	89 c2                	mov    %eax,%edx
  801b4d:	c1 e2 07             	shl    $0x7,%edx
  801b50:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801b57:	8b 40 50             	mov    0x50(%eax),%eax
  801b5a:	eb 0f                	jmp    801b6b <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b5c:	83 c0 01             	add    $0x1,%eax
  801b5f:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b64:	75 d2                	jne    801b38 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b66:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b6b:	5d                   	pop    %ebp
  801b6c:	c3                   	ret    

00801b6d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b6d:	55                   	push   %ebp
  801b6e:	89 e5                	mov    %esp,%ebp
  801b70:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b73:	89 d0                	mov    %edx,%eax
  801b75:	c1 e8 16             	shr    $0x16,%eax
  801b78:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b7f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b84:	f6 c1 01             	test   $0x1,%cl
  801b87:	74 1d                	je     801ba6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b89:	c1 ea 0c             	shr    $0xc,%edx
  801b8c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b93:	f6 c2 01             	test   $0x1,%dl
  801b96:	74 0e                	je     801ba6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b98:	c1 ea 0c             	shr    $0xc,%edx
  801b9b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ba2:	ef 
  801ba3:	0f b7 c0             	movzwl %ax,%eax
}
  801ba6:	5d                   	pop    %ebp
  801ba7:	c3                   	ret    
  801ba8:	66 90                	xchg   %ax,%ax
  801baa:	66 90                	xchg   %ax,%ax
  801bac:	66 90                	xchg   %ax,%ax
  801bae:	66 90                	xchg   %ax,%ax

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
