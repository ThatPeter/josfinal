
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
  80003f:	68 60 1e 80 00       	push   $0x801e60
  800044:	e8 58 01 00 00       	call   8001a1 <cprintf>
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
  800051:	57                   	push   %edi
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800057:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  80005e:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  800061:	e8 85 0a 00 00       	call   800aeb <sys_getenvid>
  800066:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  800068:	83 ec 08             	sub    $0x8,%esp
  80006b:	50                   	push   %eax
  80006c:	68 80 1e 80 00       	push   $0x801e80
  800071:	e8 2b 01 00 00       	call   8001a1 <cprintf>
  800076:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  80007c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800089:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  80008e:	89 c1                	mov    %eax,%ecx
  800090:	c1 e1 07             	shl    $0x7,%ecx
  800093:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  80009a:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  80009d:	39 cb                	cmp    %ecx,%ebx
  80009f:	0f 44 fa             	cmove  %edx,%edi
  8000a2:	b9 01 00 00 00       	mov    $0x1,%ecx
  8000a7:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000aa:	83 c0 01             	add    $0x1,%eax
  8000ad:	81 c2 84 00 00 00    	add    $0x84,%edx
  8000b3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8000b8:	75 d4                	jne    80008e <libmain+0x40>
  8000ba:	89 f0                	mov    %esi,%eax
  8000bc:	84 c0                	test   %al,%al
  8000be:	74 06                	je     8000c6 <libmain+0x78>
  8000c0:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000ca:	7e 0a                	jle    8000d6 <libmain+0x88>
		binaryname = argv[0];
  8000cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000cf:	8b 00                	mov    (%eax),%eax
  8000d1:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000d6:	83 ec 08             	sub    $0x8,%esp
  8000d9:	ff 75 0c             	pushl  0xc(%ebp)
  8000dc:	ff 75 08             	pushl  0x8(%ebp)
  8000df:	e8 4f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000e4:	e8 0b 00 00 00       	call   8000f4 <exit>
}
  8000e9:	83 c4 10             	add    $0x10,%esp
  8000ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000ef:	5b                   	pop    %ebx
  8000f0:	5e                   	pop    %esi
  8000f1:	5f                   	pop    %edi
  8000f2:	5d                   	pop    %ebp
  8000f3:	c3                   	ret    

008000f4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000fa:	e8 06 0e 00 00       	call   800f05 <close_all>
	sys_env_destroy(0);
  8000ff:	83 ec 0c             	sub    $0xc,%esp
  800102:	6a 00                	push   $0x0
  800104:	e8 a1 09 00 00       	call   800aaa <sys_env_destroy>
}
  800109:	83 c4 10             	add    $0x10,%esp
  80010c:	c9                   	leave  
  80010d:	c3                   	ret    

0080010e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80010e:	55                   	push   %ebp
  80010f:	89 e5                	mov    %esp,%ebp
  800111:	53                   	push   %ebx
  800112:	83 ec 04             	sub    $0x4,%esp
  800115:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800118:	8b 13                	mov    (%ebx),%edx
  80011a:	8d 42 01             	lea    0x1(%edx),%eax
  80011d:	89 03                	mov    %eax,(%ebx)
  80011f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800122:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800126:	3d ff 00 00 00       	cmp    $0xff,%eax
  80012b:	75 1a                	jne    800147 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80012d:	83 ec 08             	sub    $0x8,%esp
  800130:	68 ff 00 00 00       	push   $0xff
  800135:	8d 43 08             	lea    0x8(%ebx),%eax
  800138:	50                   	push   %eax
  800139:	e8 2f 09 00 00       	call   800a6d <sys_cputs>
		b->idx = 0;
  80013e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800144:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800147:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80014b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80014e:	c9                   	leave  
  80014f:	c3                   	ret    

00800150 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800159:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800160:	00 00 00 
	b.cnt = 0;
  800163:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80016a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016d:	ff 75 0c             	pushl  0xc(%ebp)
  800170:	ff 75 08             	pushl  0x8(%ebp)
  800173:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800179:	50                   	push   %eax
  80017a:	68 0e 01 80 00       	push   $0x80010e
  80017f:	e8 54 01 00 00       	call   8002d8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800184:	83 c4 08             	add    $0x8,%esp
  800187:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80018d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800193:	50                   	push   %eax
  800194:	e8 d4 08 00 00       	call   800a6d <sys_cputs>

	return b.cnt;
}
  800199:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80019f:	c9                   	leave  
  8001a0:	c3                   	ret    

008001a1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001aa:	50                   	push   %eax
  8001ab:	ff 75 08             	pushl  0x8(%ebp)
  8001ae:	e8 9d ff ff ff       	call   800150 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b3:	c9                   	leave  
  8001b4:	c3                   	ret    

008001b5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b5:	55                   	push   %ebp
  8001b6:	89 e5                	mov    %esp,%ebp
  8001b8:	57                   	push   %edi
  8001b9:	56                   	push   %esi
  8001ba:	53                   	push   %ebx
  8001bb:	83 ec 1c             	sub    $0x1c,%esp
  8001be:	89 c7                	mov    %eax,%edi
  8001c0:	89 d6                	mov    %edx,%esi
  8001c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001cb:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001d6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001d9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001dc:	39 d3                	cmp    %edx,%ebx
  8001de:	72 05                	jb     8001e5 <printnum+0x30>
  8001e0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001e3:	77 45                	ja     80022a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e5:	83 ec 0c             	sub    $0xc,%esp
  8001e8:	ff 75 18             	pushl  0x18(%ebp)
  8001eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8001ee:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001f1:	53                   	push   %ebx
  8001f2:	ff 75 10             	pushl  0x10(%ebp)
  8001f5:	83 ec 08             	sub    $0x8,%esp
  8001f8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001fb:	ff 75 e0             	pushl  -0x20(%ebp)
  8001fe:	ff 75 dc             	pushl  -0x24(%ebp)
  800201:	ff 75 d8             	pushl  -0x28(%ebp)
  800204:	e8 b7 19 00 00       	call   801bc0 <__udivdi3>
  800209:	83 c4 18             	add    $0x18,%esp
  80020c:	52                   	push   %edx
  80020d:	50                   	push   %eax
  80020e:	89 f2                	mov    %esi,%edx
  800210:	89 f8                	mov    %edi,%eax
  800212:	e8 9e ff ff ff       	call   8001b5 <printnum>
  800217:	83 c4 20             	add    $0x20,%esp
  80021a:	eb 18                	jmp    800234 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80021c:	83 ec 08             	sub    $0x8,%esp
  80021f:	56                   	push   %esi
  800220:	ff 75 18             	pushl  0x18(%ebp)
  800223:	ff d7                	call   *%edi
  800225:	83 c4 10             	add    $0x10,%esp
  800228:	eb 03                	jmp    80022d <printnum+0x78>
  80022a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80022d:	83 eb 01             	sub    $0x1,%ebx
  800230:	85 db                	test   %ebx,%ebx
  800232:	7f e8                	jg     80021c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800234:	83 ec 08             	sub    $0x8,%esp
  800237:	56                   	push   %esi
  800238:	83 ec 04             	sub    $0x4,%esp
  80023b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80023e:	ff 75 e0             	pushl  -0x20(%ebp)
  800241:	ff 75 dc             	pushl  -0x24(%ebp)
  800244:	ff 75 d8             	pushl  -0x28(%ebp)
  800247:	e8 a4 1a 00 00       	call   801cf0 <__umoddi3>
  80024c:	83 c4 14             	add    $0x14,%esp
  80024f:	0f be 80 a9 1e 80 00 	movsbl 0x801ea9(%eax),%eax
  800256:	50                   	push   %eax
  800257:	ff d7                	call   *%edi
}
  800259:	83 c4 10             	add    $0x10,%esp
  80025c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025f:	5b                   	pop    %ebx
  800260:	5e                   	pop    %esi
  800261:	5f                   	pop    %edi
  800262:	5d                   	pop    %ebp
  800263:	c3                   	ret    

00800264 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800267:	83 fa 01             	cmp    $0x1,%edx
  80026a:	7e 0e                	jle    80027a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80026c:	8b 10                	mov    (%eax),%edx
  80026e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800271:	89 08                	mov    %ecx,(%eax)
  800273:	8b 02                	mov    (%edx),%eax
  800275:	8b 52 04             	mov    0x4(%edx),%edx
  800278:	eb 22                	jmp    80029c <getuint+0x38>
	else if (lflag)
  80027a:	85 d2                	test   %edx,%edx
  80027c:	74 10                	je     80028e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80027e:	8b 10                	mov    (%eax),%edx
  800280:	8d 4a 04             	lea    0x4(%edx),%ecx
  800283:	89 08                	mov    %ecx,(%eax)
  800285:	8b 02                	mov    (%edx),%eax
  800287:	ba 00 00 00 00       	mov    $0x0,%edx
  80028c:	eb 0e                	jmp    80029c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80028e:	8b 10                	mov    (%eax),%edx
  800290:	8d 4a 04             	lea    0x4(%edx),%ecx
  800293:	89 08                	mov    %ecx,(%eax)
  800295:	8b 02                	mov    (%edx),%eax
  800297:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80029c:	5d                   	pop    %ebp
  80029d:	c3                   	ret    

0080029e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80029e:	55                   	push   %ebp
  80029f:	89 e5                	mov    %esp,%ebp
  8002a1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002a4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002a8:	8b 10                	mov    (%eax),%edx
  8002aa:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ad:	73 0a                	jae    8002b9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002af:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002b2:	89 08                	mov    %ecx,(%eax)
  8002b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b7:	88 02                	mov    %al,(%edx)
}
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    

008002bb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002c4:	50                   	push   %eax
  8002c5:	ff 75 10             	pushl  0x10(%ebp)
  8002c8:	ff 75 0c             	pushl  0xc(%ebp)
  8002cb:	ff 75 08             	pushl  0x8(%ebp)
  8002ce:	e8 05 00 00 00       	call   8002d8 <vprintfmt>
	va_end(ap);
}
  8002d3:	83 c4 10             	add    $0x10,%esp
  8002d6:	c9                   	leave  
  8002d7:	c3                   	ret    

008002d8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
  8002db:	57                   	push   %edi
  8002dc:	56                   	push   %esi
  8002dd:	53                   	push   %ebx
  8002de:	83 ec 2c             	sub    $0x2c,%esp
  8002e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8002e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002ea:	eb 12                	jmp    8002fe <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ec:	85 c0                	test   %eax,%eax
  8002ee:	0f 84 89 03 00 00    	je     80067d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002f4:	83 ec 08             	sub    $0x8,%esp
  8002f7:	53                   	push   %ebx
  8002f8:	50                   	push   %eax
  8002f9:	ff d6                	call   *%esi
  8002fb:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002fe:	83 c7 01             	add    $0x1,%edi
  800301:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800305:	83 f8 25             	cmp    $0x25,%eax
  800308:	75 e2                	jne    8002ec <vprintfmt+0x14>
  80030a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80030e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800315:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80031c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800323:	ba 00 00 00 00       	mov    $0x0,%edx
  800328:	eb 07                	jmp    800331 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80032d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800331:	8d 47 01             	lea    0x1(%edi),%eax
  800334:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800337:	0f b6 07             	movzbl (%edi),%eax
  80033a:	0f b6 c8             	movzbl %al,%ecx
  80033d:	83 e8 23             	sub    $0x23,%eax
  800340:	3c 55                	cmp    $0x55,%al
  800342:	0f 87 1a 03 00 00    	ja     800662 <vprintfmt+0x38a>
  800348:	0f b6 c0             	movzbl %al,%eax
  80034b:	ff 24 85 e0 1f 80 00 	jmp    *0x801fe0(,%eax,4)
  800352:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800355:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800359:	eb d6                	jmp    800331 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80035e:	b8 00 00 00 00       	mov    $0x0,%eax
  800363:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800366:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800369:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80036d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800370:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800373:	83 fa 09             	cmp    $0x9,%edx
  800376:	77 39                	ja     8003b1 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800378:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80037b:	eb e9                	jmp    800366 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80037d:	8b 45 14             	mov    0x14(%ebp),%eax
  800380:	8d 48 04             	lea    0x4(%eax),%ecx
  800383:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800386:	8b 00                	mov    (%eax),%eax
  800388:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80038e:	eb 27                	jmp    8003b7 <vprintfmt+0xdf>
  800390:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800393:	85 c0                	test   %eax,%eax
  800395:	b9 00 00 00 00       	mov    $0x0,%ecx
  80039a:	0f 49 c8             	cmovns %eax,%ecx
  80039d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a3:	eb 8c                	jmp    800331 <vprintfmt+0x59>
  8003a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003a8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003af:	eb 80                	jmp    800331 <vprintfmt+0x59>
  8003b1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003b4:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003b7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003bb:	0f 89 70 ff ff ff    	jns    800331 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003c1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ce:	e9 5e ff ff ff       	jmp    800331 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003d9:	e9 53 ff ff ff       	jmp    800331 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003de:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e1:	8d 50 04             	lea    0x4(%eax),%edx
  8003e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e7:	83 ec 08             	sub    $0x8,%esp
  8003ea:	53                   	push   %ebx
  8003eb:	ff 30                	pushl  (%eax)
  8003ed:	ff d6                	call   *%esi
			break;
  8003ef:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003f5:	e9 04 ff ff ff       	jmp    8002fe <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fd:	8d 50 04             	lea    0x4(%eax),%edx
  800400:	89 55 14             	mov    %edx,0x14(%ebp)
  800403:	8b 00                	mov    (%eax),%eax
  800405:	99                   	cltd   
  800406:	31 d0                	xor    %edx,%eax
  800408:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80040a:	83 f8 0f             	cmp    $0xf,%eax
  80040d:	7f 0b                	jg     80041a <vprintfmt+0x142>
  80040f:	8b 14 85 40 21 80 00 	mov    0x802140(,%eax,4),%edx
  800416:	85 d2                	test   %edx,%edx
  800418:	75 18                	jne    800432 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80041a:	50                   	push   %eax
  80041b:	68 c1 1e 80 00       	push   $0x801ec1
  800420:	53                   	push   %ebx
  800421:	56                   	push   %esi
  800422:	e8 94 fe ff ff       	call   8002bb <printfmt>
  800427:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80042d:	e9 cc fe ff ff       	jmp    8002fe <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800432:	52                   	push   %edx
  800433:	68 71 22 80 00       	push   $0x802271
  800438:	53                   	push   %ebx
  800439:	56                   	push   %esi
  80043a:	e8 7c fe ff ff       	call   8002bb <printfmt>
  80043f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800445:	e9 b4 fe ff ff       	jmp    8002fe <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80044a:	8b 45 14             	mov    0x14(%ebp),%eax
  80044d:	8d 50 04             	lea    0x4(%eax),%edx
  800450:	89 55 14             	mov    %edx,0x14(%ebp)
  800453:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800455:	85 ff                	test   %edi,%edi
  800457:	b8 ba 1e 80 00       	mov    $0x801eba,%eax
  80045c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80045f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800463:	0f 8e 94 00 00 00    	jle    8004fd <vprintfmt+0x225>
  800469:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80046d:	0f 84 98 00 00 00    	je     80050b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800473:	83 ec 08             	sub    $0x8,%esp
  800476:	ff 75 d0             	pushl  -0x30(%ebp)
  800479:	57                   	push   %edi
  80047a:	e8 86 02 00 00       	call   800705 <strnlen>
  80047f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800482:	29 c1                	sub    %eax,%ecx
  800484:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800487:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80048a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80048e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800491:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800494:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800496:	eb 0f                	jmp    8004a7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800498:	83 ec 08             	sub    $0x8,%esp
  80049b:	53                   	push   %ebx
  80049c:	ff 75 e0             	pushl  -0x20(%ebp)
  80049f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a1:	83 ef 01             	sub    $0x1,%edi
  8004a4:	83 c4 10             	add    $0x10,%esp
  8004a7:	85 ff                	test   %edi,%edi
  8004a9:	7f ed                	jg     800498 <vprintfmt+0x1c0>
  8004ab:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004ae:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004b1:	85 c9                	test   %ecx,%ecx
  8004b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b8:	0f 49 c1             	cmovns %ecx,%eax
  8004bb:	29 c1                	sub    %eax,%ecx
  8004bd:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c6:	89 cb                	mov    %ecx,%ebx
  8004c8:	eb 4d                	jmp    800517 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004ca:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ce:	74 1b                	je     8004eb <vprintfmt+0x213>
  8004d0:	0f be c0             	movsbl %al,%eax
  8004d3:	83 e8 20             	sub    $0x20,%eax
  8004d6:	83 f8 5e             	cmp    $0x5e,%eax
  8004d9:	76 10                	jbe    8004eb <vprintfmt+0x213>
					putch('?', putdat);
  8004db:	83 ec 08             	sub    $0x8,%esp
  8004de:	ff 75 0c             	pushl  0xc(%ebp)
  8004e1:	6a 3f                	push   $0x3f
  8004e3:	ff 55 08             	call   *0x8(%ebp)
  8004e6:	83 c4 10             	add    $0x10,%esp
  8004e9:	eb 0d                	jmp    8004f8 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004eb:	83 ec 08             	sub    $0x8,%esp
  8004ee:	ff 75 0c             	pushl  0xc(%ebp)
  8004f1:	52                   	push   %edx
  8004f2:	ff 55 08             	call   *0x8(%ebp)
  8004f5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f8:	83 eb 01             	sub    $0x1,%ebx
  8004fb:	eb 1a                	jmp    800517 <vprintfmt+0x23f>
  8004fd:	89 75 08             	mov    %esi,0x8(%ebp)
  800500:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800503:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800506:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800509:	eb 0c                	jmp    800517 <vprintfmt+0x23f>
  80050b:	89 75 08             	mov    %esi,0x8(%ebp)
  80050e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800511:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800514:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800517:	83 c7 01             	add    $0x1,%edi
  80051a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80051e:	0f be d0             	movsbl %al,%edx
  800521:	85 d2                	test   %edx,%edx
  800523:	74 23                	je     800548 <vprintfmt+0x270>
  800525:	85 f6                	test   %esi,%esi
  800527:	78 a1                	js     8004ca <vprintfmt+0x1f2>
  800529:	83 ee 01             	sub    $0x1,%esi
  80052c:	79 9c                	jns    8004ca <vprintfmt+0x1f2>
  80052e:	89 df                	mov    %ebx,%edi
  800530:	8b 75 08             	mov    0x8(%ebp),%esi
  800533:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800536:	eb 18                	jmp    800550 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800538:	83 ec 08             	sub    $0x8,%esp
  80053b:	53                   	push   %ebx
  80053c:	6a 20                	push   $0x20
  80053e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800540:	83 ef 01             	sub    $0x1,%edi
  800543:	83 c4 10             	add    $0x10,%esp
  800546:	eb 08                	jmp    800550 <vprintfmt+0x278>
  800548:	89 df                	mov    %ebx,%edi
  80054a:	8b 75 08             	mov    0x8(%ebp),%esi
  80054d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800550:	85 ff                	test   %edi,%edi
  800552:	7f e4                	jg     800538 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800554:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800557:	e9 a2 fd ff ff       	jmp    8002fe <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80055c:	83 fa 01             	cmp    $0x1,%edx
  80055f:	7e 16                	jle    800577 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800561:	8b 45 14             	mov    0x14(%ebp),%eax
  800564:	8d 50 08             	lea    0x8(%eax),%edx
  800567:	89 55 14             	mov    %edx,0x14(%ebp)
  80056a:	8b 50 04             	mov    0x4(%eax),%edx
  80056d:	8b 00                	mov    (%eax),%eax
  80056f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800572:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800575:	eb 32                	jmp    8005a9 <vprintfmt+0x2d1>
	else if (lflag)
  800577:	85 d2                	test   %edx,%edx
  800579:	74 18                	je     800593 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80057b:	8b 45 14             	mov    0x14(%ebp),%eax
  80057e:	8d 50 04             	lea    0x4(%eax),%edx
  800581:	89 55 14             	mov    %edx,0x14(%ebp)
  800584:	8b 00                	mov    (%eax),%eax
  800586:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800589:	89 c1                	mov    %eax,%ecx
  80058b:	c1 f9 1f             	sar    $0x1f,%ecx
  80058e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800591:	eb 16                	jmp    8005a9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800593:	8b 45 14             	mov    0x14(%ebp),%eax
  800596:	8d 50 04             	lea    0x4(%eax),%edx
  800599:	89 55 14             	mov    %edx,0x14(%ebp)
  80059c:	8b 00                	mov    (%eax),%eax
  80059e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a1:	89 c1                	mov    %eax,%ecx
  8005a3:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005a9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005ac:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005af:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005b4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005b8:	79 74                	jns    80062e <vprintfmt+0x356>
				putch('-', putdat);
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	53                   	push   %ebx
  8005be:	6a 2d                	push   $0x2d
  8005c0:	ff d6                	call   *%esi
				num = -(long long) num;
  8005c2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005c5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005c8:	f7 d8                	neg    %eax
  8005ca:	83 d2 00             	adc    $0x0,%edx
  8005cd:	f7 da                	neg    %edx
  8005cf:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005d2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005d7:	eb 55                	jmp    80062e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005d9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005dc:	e8 83 fc ff ff       	call   800264 <getuint>
			base = 10;
  8005e1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005e6:	eb 46                	jmp    80062e <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005e8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005eb:	e8 74 fc ff ff       	call   800264 <getuint>
			base = 8;
  8005f0:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005f5:	eb 37                	jmp    80062e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005f7:	83 ec 08             	sub    $0x8,%esp
  8005fa:	53                   	push   %ebx
  8005fb:	6a 30                	push   $0x30
  8005fd:	ff d6                	call   *%esi
			putch('x', putdat);
  8005ff:	83 c4 08             	add    $0x8,%esp
  800602:	53                   	push   %ebx
  800603:	6a 78                	push   $0x78
  800605:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8d 50 04             	lea    0x4(%eax),%edx
  80060d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800610:	8b 00                	mov    (%eax),%eax
  800612:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800617:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80061a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80061f:	eb 0d                	jmp    80062e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800621:	8d 45 14             	lea    0x14(%ebp),%eax
  800624:	e8 3b fc ff ff       	call   800264 <getuint>
			base = 16;
  800629:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80062e:	83 ec 0c             	sub    $0xc,%esp
  800631:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800635:	57                   	push   %edi
  800636:	ff 75 e0             	pushl  -0x20(%ebp)
  800639:	51                   	push   %ecx
  80063a:	52                   	push   %edx
  80063b:	50                   	push   %eax
  80063c:	89 da                	mov    %ebx,%edx
  80063e:	89 f0                	mov    %esi,%eax
  800640:	e8 70 fb ff ff       	call   8001b5 <printnum>
			break;
  800645:	83 c4 20             	add    $0x20,%esp
  800648:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80064b:	e9 ae fc ff ff       	jmp    8002fe <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	53                   	push   %ebx
  800654:	51                   	push   %ecx
  800655:	ff d6                	call   *%esi
			break;
  800657:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80065d:	e9 9c fc ff ff       	jmp    8002fe <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800662:	83 ec 08             	sub    $0x8,%esp
  800665:	53                   	push   %ebx
  800666:	6a 25                	push   $0x25
  800668:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80066a:	83 c4 10             	add    $0x10,%esp
  80066d:	eb 03                	jmp    800672 <vprintfmt+0x39a>
  80066f:	83 ef 01             	sub    $0x1,%edi
  800672:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800676:	75 f7                	jne    80066f <vprintfmt+0x397>
  800678:	e9 81 fc ff ff       	jmp    8002fe <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80067d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800680:	5b                   	pop    %ebx
  800681:	5e                   	pop    %esi
  800682:	5f                   	pop    %edi
  800683:	5d                   	pop    %ebp
  800684:	c3                   	ret    

00800685 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800685:	55                   	push   %ebp
  800686:	89 e5                	mov    %esp,%ebp
  800688:	83 ec 18             	sub    $0x18,%esp
  80068b:	8b 45 08             	mov    0x8(%ebp),%eax
  80068e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800691:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800694:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800698:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80069b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006a2:	85 c0                	test   %eax,%eax
  8006a4:	74 26                	je     8006cc <vsnprintf+0x47>
  8006a6:	85 d2                	test   %edx,%edx
  8006a8:	7e 22                	jle    8006cc <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006aa:	ff 75 14             	pushl  0x14(%ebp)
  8006ad:	ff 75 10             	pushl  0x10(%ebp)
  8006b0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006b3:	50                   	push   %eax
  8006b4:	68 9e 02 80 00       	push   $0x80029e
  8006b9:	e8 1a fc ff ff       	call   8002d8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006be:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006c1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c7:	83 c4 10             	add    $0x10,%esp
  8006ca:	eb 05                	jmp    8006d1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006d1:	c9                   	leave  
  8006d2:	c3                   	ret    

008006d3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006d3:	55                   	push   %ebp
  8006d4:	89 e5                	mov    %esp,%ebp
  8006d6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006d9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006dc:	50                   	push   %eax
  8006dd:	ff 75 10             	pushl  0x10(%ebp)
  8006e0:	ff 75 0c             	pushl  0xc(%ebp)
  8006e3:	ff 75 08             	pushl  0x8(%ebp)
  8006e6:	e8 9a ff ff ff       	call   800685 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006eb:	c9                   	leave  
  8006ec:	c3                   	ret    

008006ed <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006ed:	55                   	push   %ebp
  8006ee:	89 e5                	mov    %esp,%ebp
  8006f0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f8:	eb 03                	jmp    8006fd <strlen+0x10>
		n++;
  8006fa:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006fd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800701:	75 f7                	jne    8006fa <strlen+0xd>
		n++;
	return n;
}
  800703:	5d                   	pop    %ebp
  800704:	c3                   	ret    

00800705 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800705:	55                   	push   %ebp
  800706:	89 e5                	mov    %esp,%ebp
  800708:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80070b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070e:	ba 00 00 00 00       	mov    $0x0,%edx
  800713:	eb 03                	jmp    800718 <strnlen+0x13>
		n++;
  800715:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800718:	39 c2                	cmp    %eax,%edx
  80071a:	74 08                	je     800724 <strnlen+0x1f>
  80071c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800720:	75 f3                	jne    800715 <strnlen+0x10>
  800722:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800724:	5d                   	pop    %ebp
  800725:	c3                   	ret    

00800726 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800726:	55                   	push   %ebp
  800727:	89 e5                	mov    %esp,%ebp
  800729:	53                   	push   %ebx
  80072a:	8b 45 08             	mov    0x8(%ebp),%eax
  80072d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800730:	89 c2                	mov    %eax,%edx
  800732:	83 c2 01             	add    $0x1,%edx
  800735:	83 c1 01             	add    $0x1,%ecx
  800738:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80073c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80073f:	84 db                	test   %bl,%bl
  800741:	75 ef                	jne    800732 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800743:	5b                   	pop    %ebx
  800744:	5d                   	pop    %ebp
  800745:	c3                   	ret    

00800746 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800746:	55                   	push   %ebp
  800747:	89 e5                	mov    %esp,%ebp
  800749:	53                   	push   %ebx
  80074a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80074d:	53                   	push   %ebx
  80074e:	e8 9a ff ff ff       	call   8006ed <strlen>
  800753:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800756:	ff 75 0c             	pushl  0xc(%ebp)
  800759:	01 d8                	add    %ebx,%eax
  80075b:	50                   	push   %eax
  80075c:	e8 c5 ff ff ff       	call   800726 <strcpy>
	return dst;
}
  800761:	89 d8                	mov    %ebx,%eax
  800763:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800766:	c9                   	leave  
  800767:	c3                   	ret    

00800768 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
  80076b:	56                   	push   %esi
  80076c:	53                   	push   %ebx
  80076d:	8b 75 08             	mov    0x8(%ebp),%esi
  800770:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800773:	89 f3                	mov    %esi,%ebx
  800775:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800778:	89 f2                	mov    %esi,%edx
  80077a:	eb 0f                	jmp    80078b <strncpy+0x23>
		*dst++ = *src;
  80077c:	83 c2 01             	add    $0x1,%edx
  80077f:	0f b6 01             	movzbl (%ecx),%eax
  800782:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800785:	80 39 01             	cmpb   $0x1,(%ecx)
  800788:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80078b:	39 da                	cmp    %ebx,%edx
  80078d:	75 ed                	jne    80077c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80078f:	89 f0                	mov    %esi,%eax
  800791:	5b                   	pop    %ebx
  800792:	5e                   	pop    %esi
  800793:	5d                   	pop    %ebp
  800794:	c3                   	ret    

00800795 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	56                   	push   %esi
  800799:	53                   	push   %ebx
  80079a:	8b 75 08             	mov    0x8(%ebp),%esi
  80079d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a0:	8b 55 10             	mov    0x10(%ebp),%edx
  8007a3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007a5:	85 d2                	test   %edx,%edx
  8007a7:	74 21                	je     8007ca <strlcpy+0x35>
  8007a9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007ad:	89 f2                	mov    %esi,%edx
  8007af:	eb 09                	jmp    8007ba <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007b1:	83 c2 01             	add    $0x1,%edx
  8007b4:	83 c1 01             	add    $0x1,%ecx
  8007b7:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ba:	39 c2                	cmp    %eax,%edx
  8007bc:	74 09                	je     8007c7 <strlcpy+0x32>
  8007be:	0f b6 19             	movzbl (%ecx),%ebx
  8007c1:	84 db                	test   %bl,%bl
  8007c3:	75 ec                	jne    8007b1 <strlcpy+0x1c>
  8007c5:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007c7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007ca:	29 f0                	sub    %esi,%eax
}
  8007cc:	5b                   	pop    %ebx
  8007cd:	5e                   	pop    %esi
  8007ce:	5d                   	pop    %ebp
  8007cf:	c3                   	ret    

008007d0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007d9:	eb 06                	jmp    8007e1 <strcmp+0x11>
		p++, q++;
  8007db:	83 c1 01             	add    $0x1,%ecx
  8007de:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007e1:	0f b6 01             	movzbl (%ecx),%eax
  8007e4:	84 c0                	test   %al,%al
  8007e6:	74 04                	je     8007ec <strcmp+0x1c>
  8007e8:	3a 02                	cmp    (%edx),%al
  8007ea:	74 ef                	je     8007db <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ec:	0f b6 c0             	movzbl %al,%eax
  8007ef:	0f b6 12             	movzbl (%edx),%edx
  8007f2:	29 d0                	sub    %edx,%eax
}
  8007f4:	5d                   	pop    %ebp
  8007f5:	c3                   	ret    

008007f6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007f6:	55                   	push   %ebp
  8007f7:	89 e5                	mov    %esp,%ebp
  8007f9:	53                   	push   %ebx
  8007fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800800:	89 c3                	mov    %eax,%ebx
  800802:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800805:	eb 06                	jmp    80080d <strncmp+0x17>
		n--, p++, q++;
  800807:	83 c0 01             	add    $0x1,%eax
  80080a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80080d:	39 d8                	cmp    %ebx,%eax
  80080f:	74 15                	je     800826 <strncmp+0x30>
  800811:	0f b6 08             	movzbl (%eax),%ecx
  800814:	84 c9                	test   %cl,%cl
  800816:	74 04                	je     80081c <strncmp+0x26>
  800818:	3a 0a                	cmp    (%edx),%cl
  80081a:	74 eb                	je     800807 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80081c:	0f b6 00             	movzbl (%eax),%eax
  80081f:	0f b6 12             	movzbl (%edx),%edx
  800822:	29 d0                	sub    %edx,%eax
  800824:	eb 05                	jmp    80082b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800826:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80082b:	5b                   	pop    %ebx
  80082c:	5d                   	pop    %ebp
  80082d:	c3                   	ret    

0080082e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80082e:	55                   	push   %ebp
  80082f:	89 e5                	mov    %esp,%ebp
  800831:	8b 45 08             	mov    0x8(%ebp),%eax
  800834:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800838:	eb 07                	jmp    800841 <strchr+0x13>
		if (*s == c)
  80083a:	38 ca                	cmp    %cl,%dl
  80083c:	74 0f                	je     80084d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80083e:	83 c0 01             	add    $0x1,%eax
  800841:	0f b6 10             	movzbl (%eax),%edx
  800844:	84 d2                	test   %dl,%dl
  800846:	75 f2                	jne    80083a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800848:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80084d:	5d                   	pop    %ebp
  80084e:	c3                   	ret    

0080084f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	8b 45 08             	mov    0x8(%ebp),%eax
  800855:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800859:	eb 03                	jmp    80085e <strfind+0xf>
  80085b:	83 c0 01             	add    $0x1,%eax
  80085e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800861:	38 ca                	cmp    %cl,%dl
  800863:	74 04                	je     800869 <strfind+0x1a>
  800865:	84 d2                	test   %dl,%dl
  800867:	75 f2                	jne    80085b <strfind+0xc>
			break;
	return (char *) s;
}
  800869:	5d                   	pop    %ebp
  80086a:	c3                   	ret    

0080086b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	57                   	push   %edi
  80086f:	56                   	push   %esi
  800870:	53                   	push   %ebx
  800871:	8b 7d 08             	mov    0x8(%ebp),%edi
  800874:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800877:	85 c9                	test   %ecx,%ecx
  800879:	74 36                	je     8008b1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80087b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800881:	75 28                	jne    8008ab <memset+0x40>
  800883:	f6 c1 03             	test   $0x3,%cl
  800886:	75 23                	jne    8008ab <memset+0x40>
		c &= 0xFF;
  800888:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80088c:	89 d3                	mov    %edx,%ebx
  80088e:	c1 e3 08             	shl    $0x8,%ebx
  800891:	89 d6                	mov    %edx,%esi
  800893:	c1 e6 18             	shl    $0x18,%esi
  800896:	89 d0                	mov    %edx,%eax
  800898:	c1 e0 10             	shl    $0x10,%eax
  80089b:	09 f0                	or     %esi,%eax
  80089d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80089f:	89 d8                	mov    %ebx,%eax
  8008a1:	09 d0                	or     %edx,%eax
  8008a3:	c1 e9 02             	shr    $0x2,%ecx
  8008a6:	fc                   	cld    
  8008a7:	f3 ab                	rep stos %eax,%es:(%edi)
  8008a9:	eb 06                	jmp    8008b1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ae:	fc                   	cld    
  8008af:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008b1:	89 f8                	mov    %edi,%eax
  8008b3:	5b                   	pop    %ebx
  8008b4:	5e                   	pop    %esi
  8008b5:	5f                   	pop    %edi
  8008b6:	5d                   	pop    %ebp
  8008b7:	c3                   	ret    

008008b8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	57                   	push   %edi
  8008bc:	56                   	push   %esi
  8008bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008c3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008c6:	39 c6                	cmp    %eax,%esi
  8008c8:	73 35                	jae    8008ff <memmove+0x47>
  8008ca:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008cd:	39 d0                	cmp    %edx,%eax
  8008cf:	73 2e                	jae    8008ff <memmove+0x47>
		s += n;
		d += n;
  8008d1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d4:	89 d6                	mov    %edx,%esi
  8008d6:	09 fe                	or     %edi,%esi
  8008d8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008de:	75 13                	jne    8008f3 <memmove+0x3b>
  8008e0:	f6 c1 03             	test   $0x3,%cl
  8008e3:	75 0e                	jne    8008f3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008e5:	83 ef 04             	sub    $0x4,%edi
  8008e8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008eb:	c1 e9 02             	shr    $0x2,%ecx
  8008ee:	fd                   	std    
  8008ef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f1:	eb 09                	jmp    8008fc <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008f3:	83 ef 01             	sub    $0x1,%edi
  8008f6:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008f9:	fd                   	std    
  8008fa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008fc:	fc                   	cld    
  8008fd:	eb 1d                	jmp    80091c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ff:	89 f2                	mov    %esi,%edx
  800901:	09 c2                	or     %eax,%edx
  800903:	f6 c2 03             	test   $0x3,%dl
  800906:	75 0f                	jne    800917 <memmove+0x5f>
  800908:	f6 c1 03             	test   $0x3,%cl
  80090b:	75 0a                	jne    800917 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80090d:	c1 e9 02             	shr    $0x2,%ecx
  800910:	89 c7                	mov    %eax,%edi
  800912:	fc                   	cld    
  800913:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800915:	eb 05                	jmp    80091c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800917:	89 c7                	mov    %eax,%edi
  800919:	fc                   	cld    
  80091a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80091c:	5e                   	pop    %esi
  80091d:	5f                   	pop    %edi
  80091e:	5d                   	pop    %ebp
  80091f:	c3                   	ret    

00800920 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800923:	ff 75 10             	pushl  0x10(%ebp)
  800926:	ff 75 0c             	pushl  0xc(%ebp)
  800929:	ff 75 08             	pushl  0x8(%ebp)
  80092c:	e8 87 ff ff ff       	call   8008b8 <memmove>
}
  800931:	c9                   	leave  
  800932:	c3                   	ret    

00800933 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	56                   	push   %esi
  800937:	53                   	push   %ebx
  800938:	8b 45 08             	mov    0x8(%ebp),%eax
  80093b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093e:	89 c6                	mov    %eax,%esi
  800940:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800943:	eb 1a                	jmp    80095f <memcmp+0x2c>
		if (*s1 != *s2)
  800945:	0f b6 08             	movzbl (%eax),%ecx
  800948:	0f b6 1a             	movzbl (%edx),%ebx
  80094b:	38 d9                	cmp    %bl,%cl
  80094d:	74 0a                	je     800959 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80094f:	0f b6 c1             	movzbl %cl,%eax
  800952:	0f b6 db             	movzbl %bl,%ebx
  800955:	29 d8                	sub    %ebx,%eax
  800957:	eb 0f                	jmp    800968 <memcmp+0x35>
		s1++, s2++;
  800959:	83 c0 01             	add    $0x1,%eax
  80095c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80095f:	39 f0                	cmp    %esi,%eax
  800961:	75 e2                	jne    800945 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800963:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800968:	5b                   	pop    %ebx
  800969:	5e                   	pop    %esi
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	53                   	push   %ebx
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800973:	89 c1                	mov    %eax,%ecx
  800975:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800978:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80097c:	eb 0a                	jmp    800988 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80097e:	0f b6 10             	movzbl (%eax),%edx
  800981:	39 da                	cmp    %ebx,%edx
  800983:	74 07                	je     80098c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800985:	83 c0 01             	add    $0x1,%eax
  800988:	39 c8                	cmp    %ecx,%eax
  80098a:	72 f2                	jb     80097e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80098c:	5b                   	pop    %ebx
  80098d:	5d                   	pop    %ebp
  80098e:	c3                   	ret    

0080098f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	57                   	push   %edi
  800993:	56                   	push   %esi
  800994:	53                   	push   %ebx
  800995:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800998:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80099b:	eb 03                	jmp    8009a0 <strtol+0x11>
		s++;
  80099d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a0:	0f b6 01             	movzbl (%ecx),%eax
  8009a3:	3c 20                	cmp    $0x20,%al
  8009a5:	74 f6                	je     80099d <strtol+0xe>
  8009a7:	3c 09                	cmp    $0x9,%al
  8009a9:	74 f2                	je     80099d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009ab:	3c 2b                	cmp    $0x2b,%al
  8009ad:	75 0a                	jne    8009b9 <strtol+0x2a>
		s++;
  8009af:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009b2:	bf 00 00 00 00       	mov    $0x0,%edi
  8009b7:	eb 11                	jmp    8009ca <strtol+0x3b>
  8009b9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009be:	3c 2d                	cmp    $0x2d,%al
  8009c0:	75 08                	jne    8009ca <strtol+0x3b>
		s++, neg = 1;
  8009c2:	83 c1 01             	add    $0x1,%ecx
  8009c5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ca:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009d0:	75 15                	jne    8009e7 <strtol+0x58>
  8009d2:	80 39 30             	cmpb   $0x30,(%ecx)
  8009d5:	75 10                	jne    8009e7 <strtol+0x58>
  8009d7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009db:	75 7c                	jne    800a59 <strtol+0xca>
		s += 2, base = 16;
  8009dd:	83 c1 02             	add    $0x2,%ecx
  8009e0:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009e5:	eb 16                	jmp    8009fd <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009e7:	85 db                	test   %ebx,%ebx
  8009e9:	75 12                	jne    8009fd <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009eb:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009f0:	80 39 30             	cmpb   $0x30,(%ecx)
  8009f3:	75 08                	jne    8009fd <strtol+0x6e>
		s++, base = 8;
  8009f5:	83 c1 01             	add    $0x1,%ecx
  8009f8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800a02:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a05:	0f b6 11             	movzbl (%ecx),%edx
  800a08:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a0b:	89 f3                	mov    %esi,%ebx
  800a0d:	80 fb 09             	cmp    $0x9,%bl
  800a10:	77 08                	ja     800a1a <strtol+0x8b>
			dig = *s - '0';
  800a12:	0f be d2             	movsbl %dl,%edx
  800a15:	83 ea 30             	sub    $0x30,%edx
  800a18:	eb 22                	jmp    800a3c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a1a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a1d:	89 f3                	mov    %esi,%ebx
  800a1f:	80 fb 19             	cmp    $0x19,%bl
  800a22:	77 08                	ja     800a2c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a24:	0f be d2             	movsbl %dl,%edx
  800a27:	83 ea 57             	sub    $0x57,%edx
  800a2a:	eb 10                	jmp    800a3c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a2c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a2f:	89 f3                	mov    %esi,%ebx
  800a31:	80 fb 19             	cmp    $0x19,%bl
  800a34:	77 16                	ja     800a4c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a36:	0f be d2             	movsbl %dl,%edx
  800a39:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a3c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a3f:	7d 0b                	jge    800a4c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a41:	83 c1 01             	add    $0x1,%ecx
  800a44:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a48:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a4a:	eb b9                	jmp    800a05 <strtol+0x76>

	if (endptr)
  800a4c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a50:	74 0d                	je     800a5f <strtol+0xd0>
		*endptr = (char *) s;
  800a52:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a55:	89 0e                	mov    %ecx,(%esi)
  800a57:	eb 06                	jmp    800a5f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a59:	85 db                	test   %ebx,%ebx
  800a5b:	74 98                	je     8009f5 <strtol+0x66>
  800a5d:	eb 9e                	jmp    8009fd <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a5f:	89 c2                	mov    %eax,%edx
  800a61:	f7 da                	neg    %edx
  800a63:	85 ff                	test   %edi,%edi
  800a65:	0f 45 c2             	cmovne %edx,%eax
}
  800a68:	5b                   	pop    %ebx
  800a69:	5e                   	pop    %esi
  800a6a:	5f                   	pop    %edi
  800a6b:	5d                   	pop    %ebp
  800a6c:	c3                   	ret    

00800a6d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	57                   	push   %edi
  800a71:	56                   	push   %esi
  800a72:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a73:	b8 00 00 00 00       	mov    $0x0,%eax
  800a78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7e:	89 c3                	mov    %eax,%ebx
  800a80:	89 c7                	mov    %eax,%edi
  800a82:	89 c6                	mov    %eax,%esi
  800a84:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a86:	5b                   	pop    %ebx
  800a87:	5e                   	pop    %esi
  800a88:	5f                   	pop    %edi
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <sys_cgetc>:

int
sys_cgetc(void)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	57                   	push   %edi
  800a8f:	56                   	push   %esi
  800a90:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a91:	ba 00 00 00 00       	mov    $0x0,%edx
  800a96:	b8 01 00 00 00       	mov    $0x1,%eax
  800a9b:	89 d1                	mov    %edx,%ecx
  800a9d:	89 d3                	mov    %edx,%ebx
  800a9f:	89 d7                	mov    %edx,%edi
  800aa1:	89 d6                	mov    %edx,%esi
  800aa3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aa5:	5b                   	pop    %ebx
  800aa6:	5e                   	pop    %esi
  800aa7:	5f                   	pop    %edi
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	57                   	push   %edi
  800aae:	56                   	push   %esi
  800aaf:	53                   	push   %ebx
  800ab0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab8:	b8 03 00 00 00       	mov    $0x3,%eax
  800abd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac0:	89 cb                	mov    %ecx,%ebx
  800ac2:	89 cf                	mov    %ecx,%edi
  800ac4:	89 ce                	mov    %ecx,%esi
  800ac6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ac8:	85 c0                	test   %eax,%eax
  800aca:	7e 17                	jle    800ae3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800acc:	83 ec 0c             	sub    $0xc,%esp
  800acf:	50                   	push   %eax
  800ad0:	6a 03                	push   $0x3
  800ad2:	68 9f 21 80 00       	push   $0x80219f
  800ad7:	6a 23                	push   $0x23
  800ad9:	68 bc 21 80 00       	push   $0x8021bc
  800ade:	e8 41 0f 00 00       	call   801a24 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ae3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ae6:	5b                   	pop    %ebx
  800ae7:	5e                   	pop    %esi
  800ae8:	5f                   	pop    %edi
  800ae9:	5d                   	pop    %ebp
  800aea:	c3                   	ret    

00800aeb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	57                   	push   %edi
  800aef:	56                   	push   %esi
  800af0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af1:	ba 00 00 00 00       	mov    $0x0,%edx
  800af6:	b8 02 00 00 00       	mov    $0x2,%eax
  800afb:	89 d1                	mov    %edx,%ecx
  800afd:	89 d3                	mov    %edx,%ebx
  800aff:	89 d7                	mov    %edx,%edi
  800b01:	89 d6                	mov    %edx,%esi
  800b03:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b05:	5b                   	pop    %ebx
  800b06:	5e                   	pop    %esi
  800b07:	5f                   	pop    %edi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <sys_yield>:

void
sys_yield(void)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	57                   	push   %edi
  800b0e:	56                   	push   %esi
  800b0f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b10:	ba 00 00 00 00       	mov    $0x0,%edx
  800b15:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b1a:	89 d1                	mov    %edx,%ecx
  800b1c:	89 d3                	mov    %edx,%ebx
  800b1e:	89 d7                	mov    %edx,%edi
  800b20:	89 d6                	mov    %edx,%esi
  800b22:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b24:	5b                   	pop    %ebx
  800b25:	5e                   	pop    %esi
  800b26:	5f                   	pop    %edi
  800b27:	5d                   	pop    %ebp
  800b28:	c3                   	ret    

00800b29 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	57                   	push   %edi
  800b2d:	56                   	push   %esi
  800b2e:	53                   	push   %ebx
  800b2f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b32:	be 00 00 00 00       	mov    $0x0,%esi
  800b37:	b8 04 00 00 00       	mov    $0x4,%eax
  800b3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b42:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b45:	89 f7                	mov    %esi,%edi
  800b47:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b49:	85 c0                	test   %eax,%eax
  800b4b:	7e 17                	jle    800b64 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b4d:	83 ec 0c             	sub    $0xc,%esp
  800b50:	50                   	push   %eax
  800b51:	6a 04                	push   $0x4
  800b53:	68 9f 21 80 00       	push   $0x80219f
  800b58:	6a 23                	push   $0x23
  800b5a:	68 bc 21 80 00       	push   $0x8021bc
  800b5f:	e8 c0 0e 00 00       	call   801a24 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b67:	5b                   	pop    %ebx
  800b68:	5e                   	pop    %esi
  800b69:	5f                   	pop    %edi
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	57                   	push   %edi
  800b70:	56                   	push   %esi
  800b71:	53                   	push   %ebx
  800b72:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b75:	b8 05 00 00 00       	mov    $0x5,%eax
  800b7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b80:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b83:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b86:	8b 75 18             	mov    0x18(%ebp),%esi
  800b89:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b8b:	85 c0                	test   %eax,%eax
  800b8d:	7e 17                	jle    800ba6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8f:	83 ec 0c             	sub    $0xc,%esp
  800b92:	50                   	push   %eax
  800b93:	6a 05                	push   $0x5
  800b95:	68 9f 21 80 00       	push   $0x80219f
  800b9a:	6a 23                	push   $0x23
  800b9c:	68 bc 21 80 00       	push   $0x8021bc
  800ba1:	e8 7e 0e 00 00       	call   801a24 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ba6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bbc:	b8 06 00 00 00       	mov    $0x6,%eax
  800bc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc7:	89 df                	mov    %ebx,%edi
  800bc9:	89 de                	mov    %ebx,%esi
  800bcb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bcd:	85 c0                	test   %eax,%eax
  800bcf:	7e 17                	jle    800be8 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd1:	83 ec 0c             	sub    $0xc,%esp
  800bd4:	50                   	push   %eax
  800bd5:	6a 06                	push   $0x6
  800bd7:	68 9f 21 80 00       	push   $0x80219f
  800bdc:	6a 23                	push   $0x23
  800bde:	68 bc 21 80 00       	push   $0x8021bc
  800be3:	e8 3c 0e 00 00       	call   801a24 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800be8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800beb:	5b                   	pop    %ebx
  800bec:	5e                   	pop    %esi
  800bed:	5f                   	pop    %edi
  800bee:	5d                   	pop    %ebp
  800bef:	c3                   	ret    

00800bf0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	57                   	push   %edi
  800bf4:	56                   	push   %esi
  800bf5:	53                   	push   %ebx
  800bf6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bfe:	b8 08 00 00 00       	mov    $0x8,%eax
  800c03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c06:	8b 55 08             	mov    0x8(%ebp),%edx
  800c09:	89 df                	mov    %ebx,%edi
  800c0b:	89 de                	mov    %ebx,%esi
  800c0d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c0f:	85 c0                	test   %eax,%eax
  800c11:	7e 17                	jle    800c2a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c13:	83 ec 0c             	sub    $0xc,%esp
  800c16:	50                   	push   %eax
  800c17:	6a 08                	push   $0x8
  800c19:	68 9f 21 80 00       	push   $0x80219f
  800c1e:	6a 23                	push   $0x23
  800c20:	68 bc 21 80 00       	push   $0x8021bc
  800c25:	e8 fa 0d 00 00       	call   801a24 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2d:	5b                   	pop    %ebx
  800c2e:	5e                   	pop    %esi
  800c2f:	5f                   	pop    %edi
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    

00800c32 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	57                   	push   %edi
  800c36:	56                   	push   %esi
  800c37:	53                   	push   %ebx
  800c38:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c40:	b8 09 00 00 00       	mov    $0x9,%eax
  800c45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c48:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4b:	89 df                	mov    %ebx,%edi
  800c4d:	89 de                	mov    %ebx,%esi
  800c4f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c51:	85 c0                	test   %eax,%eax
  800c53:	7e 17                	jle    800c6c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c55:	83 ec 0c             	sub    $0xc,%esp
  800c58:	50                   	push   %eax
  800c59:	6a 09                	push   $0x9
  800c5b:	68 9f 21 80 00       	push   $0x80219f
  800c60:	6a 23                	push   $0x23
  800c62:	68 bc 21 80 00       	push   $0x8021bc
  800c67:	e8 b8 0d 00 00       	call   801a24 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6f:	5b                   	pop    %ebx
  800c70:	5e                   	pop    %esi
  800c71:	5f                   	pop    %edi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	53                   	push   %ebx
  800c7a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c82:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8d:	89 df                	mov    %ebx,%edi
  800c8f:	89 de                	mov    %ebx,%esi
  800c91:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c93:	85 c0                	test   %eax,%eax
  800c95:	7e 17                	jle    800cae <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c97:	83 ec 0c             	sub    $0xc,%esp
  800c9a:	50                   	push   %eax
  800c9b:	6a 0a                	push   $0xa
  800c9d:	68 9f 21 80 00       	push   $0x80219f
  800ca2:	6a 23                	push   $0x23
  800ca4:	68 bc 21 80 00       	push   $0x8021bc
  800ca9:	e8 76 0d 00 00       	call   801a24 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb1:	5b                   	pop    %ebx
  800cb2:	5e                   	pop    %esi
  800cb3:	5f                   	pop    %edi
  800cb4:	5d                   	pop    %ebp
  800cb5:	c3                   	ret    

00800cb6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	57                   	push   %edi
  800cba:	56                   	push   %esi
  800cbb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbc:	be 00 00 00 00       	mov    $0x0,%esi
  800cc1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ccf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    

00800cd9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	57                   	push   %edi
  800cdd:	56                   	push   %esi
  800cde:	53                   	push   %ebx
  800cdf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cec:	8b 55 08             	mov    0x8(%ebp),%edx
  800cef:	89 cb                	mov    %ecx,%ebx
  800cf1:	89 cf                	mov    %ecx,%edi
  800cf3:	89 ce                	mov    %ecx,%esi
  800cf5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf7:	85 c0                	test   %eax,%eax
  800cf9:	7e 17                	jle    800d12 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfb:	83 ec 0c             	sub    $0xc,%esp
  800cfe:	50                   	push   %eax
  800cff:	6a 0d                	push   $0xd
  800d01:	68 9f 21 80 00       	push   $0x80219f
  800d06:	6a 23                	push   $0x23
  800d08:	68 bc 21 80 00       	push   $0x8021bc
  800d0d:	e8 12 0d 00 00       	call   801a24 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d15:	5b                   	pop    %ebx
  800d16:	5e                   	pop    %esi
  800d17:	5f                   	pop    %edi
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    

00800d1a <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	57                   	push   %edi
  800d1e:	56                   	push   %esi
  800d1f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d20:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d25:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2d:	89 cb                	mov    %ecx,%ebx
  800d2f:	89 cf                	mov    %ecx,%edi
  800d31:	89 ce                	mov    %ecx,%esi
  800d33:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d40:	05 00 00 00 30       	add    $0x30000000,%eax
  800d45:	c1 e8 0c             	shr    $0xc,%eax
}
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d50:	05 00 00 00 30       	add    $0x30000000,%eax
  800d55:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d5a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d5f:	5d                   	pop    %ebp
  800d60:	c3                   	ret    

00800d61 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d61:	55                   	push   %ebp
  800d62:	89 e5                	mov    %esp,%ebp
  800d64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d67:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d6c:	89 c2                	mov    %eax,%edx
  800d6e:	c1 ea 16             	shr    $0x16,%edx
  800d71:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d78:	f6 c2 01             	test   $0x1,%dl
  800d7b:	74 11                	je     800d8e <fd_alloc+0x2d>
  800d7d:	89 c2                	mov    %eax,%edx
  800d7f:	c1 ea 0c             	shr    $0xc,%edx
  800d82:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d89:	f6 c2 01             	test   $0x1,%dl
  800d8c:	75 09                	jne    800d97 <fd_alloc+0x36>
			*fd_store = fd;
  800d8e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d90:	b8 00 00 00 00       	mov    $0x0,%eax
  800d95:	eb 17                	jmp    800dae <fd_alloc+0x4d>
  800d97:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d9c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800da1:	75 c9                	jne    800d6c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800da3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800da9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800dae:	5d                   	pop    %ebp
  800daf:	c3                   	ret    

00800db0 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800db6:	83 f8 1f             	cmp    $0x1f,%eax
  800db9:	77 36                	ja     800df1 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dbb:	c1 e0 0c             	shl    $0xc,%eax
  800dbe:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dc3:	89 c2                	mov    %eax,%edx
  800dc5:	c1 ea 16             	shr    $0x16,%edx
  800dc8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dcf:	f6 c2 01             	test   $0x1,%dl
  800dd2:	74 24                	je     800df8 <fd_lookup+0x48>
  800dd4:	89 c2                	mov    %eax,%edx
  800dd6:	c1 ea 0c             	shr    $0xc,%edx
  800dd9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800de0:	f6 c2 01             	test   $0x1,%dl
  800de3:	74 1a                	je     800dff <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800de5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800de8:	89 02                	mov    %eax,(%edx)
	return 0;
  800dea:	b8 00 00 00 00       	mov    $0x0,%eax
  800def:	eb 13                	jmp    800e04 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800df1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800df6:	eb 0c                	jmp    800e04 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800df8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dfd:	eb 05                	jmp    800e04 <fd_lookup+0x54>
  800dff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    

00800e06 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	83 ec 08             	sub    $0x8,%esp
  800e0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0f:	ba 48 22 80 00       	mov    $0x802248,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e14:	eb 13                	jmp    800e29 <dev_lookup+0x23>
  800e16:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e19:	39 08                	cmp    %ecx,(%eax)
  800e1b:	75 0c                	jne    800e29 <dev_lookup+0x23>
			*dev = devtab[i];
  800e1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e20:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e22:	b8 00 00 00 00       	mov    $0x0,%eax
  800e27:	eb 2e                	jmp    800e57 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e29:	8b 02                	mov    (%edx),%eax
  800e2b:	85 c0                	test   %eax,%eax
  800e2d:	75 e7                	jne    800e16 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e2f:	a1 04 40 80 00       	mov    0x804004,%eax
  800e34:	8b 40 50             	mov    0x50(%eax),%eax
  800e37:	83 ec 04             	sub    $0x4,%esp
  800e3a:	51                   	push   %ecx
  800e3b:	50                   	push   %eax
  800e3c:	68 cc 21 80 00       	push   $0x8021cc
  800e41:	e8 5b f3 ff ff       	call   8001a1 <cprintf>
	*dev = 0;
  800e46:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e49:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e4f:	83 c4 10             	add    $0x10,%esp
  800e52:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e57:	c9                   	leave  
  800e58:	c3                   	ret    

00800e59 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e59:	55                   	push   %ebp
  800e5a:	89 e5                	mov    %esp,%ebp
  800e5c:	56                   	push   %esi
  800e5d:	53                   	push   %ebx
  800e5e:	83 ec 10             	sub    $0x10,%esp
  800e61:	8b 75 08             	mov    0x8(%ebp),%esi
  800e64:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e6a:	50                   	push   %eax
  800e6b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e71:	c1 e8 0c             	shr    $0xc,%eax
  800e74:	50                   	push   %eax
  800e75:	e8 36 ff ff ff       	call   800db0 <fd_lookup>
  800e7a:	83 c4 08             	add    $0x8,%esp
  800e7d:	85 c0                	test   %eax,%eax
  800e7f:	78 05                	js     800e86 <fd_close+0x2d>
	    || fd != fd2)
  800e81:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e84:	74 0c                	je     800e92 <fd_close+0x39>
		return (must_exist ? r : 0);
  800e86:	84 db                	test   %bl,%bl
  800e88:	ba 00 00 00 00       	mov    $0x0,%edx
  800e8d:	0f 44 c2             	cmove  %edx,%eax
  800e90:	eb 41                	jmp    800ed3 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e92:	83 ec 08             	sub    $0x8,%esp
  800e95:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e98:	50                   	push   %eax
  800e99:	ff 36                	pushl  (%esi)
  800e9b:	e8 66 ff ff ff       	call   800e06 <dev_lookup>
  800ea0:	89 c3                	mov    %eax,%ebx
  800ea2:	83 c4 10             	add    $0x10,%esp
  800ea5:	85 c0                	test   %eax,%eax
  800ea7:	78 1a                	js     800ec3 <fd_close+0x6a>
		if (dev->dev_close)
  800ea9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eac:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800eaf:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800eb4:	85 c0                	test   %eax,%eax
  800eb6:	74 0b                	je     800ec3 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800eb8:	83 ec 0c             	sub    $0xc,%esp
  800ebb:	56                   	push   %esi
  800ebc:	ff d0                	call   *%eax
  800ebe:	89 c3                	mov    %eax,%ebx
  800ec0:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ec3:	83 ec 08             	sub    $0x8,%esp
  800ec6:	56                   	push   %esi
  800ec7:	6a 00                	push   $0x0
  800ec9:	e8 e0 fc ff ff       	call   800bae <sys_page_unmap>
	return r;
  800ece:	83 c4 10             	add    $0x10,%esp
  800ed1:	89 d8                	mov    %ebx,%eax
}
  800ed3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ed6:	5b                   	pop    %ebx
  800ed7:	5e                   	pop    %esi
  800ed8:	5d                   	pop    %ebp
  800ed9:	c3                   	ret    

00800eda <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800eda:	55                   	push   %ebp
  800edb:	89 e5                	mov    %esp,%ebp
  800edd:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ee0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ee3:	50                   	push   %eax
  800ee4:	ff 75 08             	pushl  0x8(%ebp)
  800ee7:	e8 c4 fe ff ff       	call   800db0 <fd_lookup>
  800eec:	83 c4 08             	add    $0x8,%esp
  800eef:	85 c0                	test   %eax,%eax
  800ef1:	78 10                	js     800f03 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ef3:	83 ec 08             	sub    $0x8,%esp
  800ef6:	6a 01                	push   $0x1
  800ef8:	ff 75 f4             	pushl  -0xc(%ebp)
  800efb:	e8 59 ff ff ff       	call   800e59 <fd_close>
  800f00:	83 c4 10             	add    $0x10,%esp
}
  800f03:	c9                   	leave  
  800f04:	c3                   	ret    

00800f05 <close_all>:

void
close_all(void)
{
  800f05:	55                   	push   %ebp
  800f06:	89 e5                	mov    %esp,%ebp
  800f08:	53                   	push   %ebx
  800f09:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f0c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f11:	83 ec 0c             	sub    $0xc,%esp
  800f14:	53                   	push   %ebx
  800f15:	e8 c0 ff ff ff       	call   800eda <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f1a:	83 c3 01             	add    $0x1,%ebx
  800f1d:	83 c4 10             	add    $0x10,%esp
  800f20:	83 fb 20             	cmp    $0x20,%ebx
  800f23:	75 ec                	jne    800f11 <close_all+0xc>
		close(i);
}
  800f25:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f28:	c9                   	leave  
  800f29:	c3                   	ret    

00800f2a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f2a:	55                   	push   %ebp
  800f2b:	89 e5                	mov    %esp,%ebp
  800f2d:	57                   	push   %edi
  800f2e:	56                   	push   %esi
  800f2f:	53                   	push   %ebx
  800f30:	83 ec 2c             	sub    $0x2c,%esp
  800f33:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f36:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f39:	50                   	push   %eax
  800f3a:	ff 75 08             	pushl  0x8(%ebp)
  800f3d:	e8 6e fe ff ff       	call   800db0 <fd_lookup>
  800f42:	83 c4 08             	add    $0x8,%esp
  800f45:	85 c0                	test   %eax,%eax
  800f47:	0f 88 c1 00 00 00    	js     80100e <dup+0xe4>
		return r;
	close(newfdnum);
  800f4d:	83 ec 0c             	sub    $0xc,%esp
  800f50:	56                   	push   %esi
  800f51:	e8 84 ff ff ff       	call   800eda <close>

	newfd = INDEX2FD(newfdnum);
  800f56:	89 f3                	mov    %esi,%ebx
  800f58:	c1 e3 0c             	shl    $0xc,%ebx
  800f5b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f61:	83 c4 04             	add    $0x4,%esp
  800f64:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f67:	e8 de fd ff ff       	call   800d4a <fd2data>
  800f6c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f6e:	89 1c 24             	mov    %ebx,(%esp)
  800f71:	e8 d4 fd ff ff       	call   800d4a <fd2data>
  800f76:	83 c4 10             	add    $0x10,%esp
  800f79:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f7c:	89 f8                	mov    %edi,%eax
  800f7e:	c1 e8 16             	shr    $0x16,%eax
  800f81:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f88:	a8 01                	test   $0x1,%al
  800f8a:	74 37                	je     800fc3 <dup+0x99>
  800f8c:	89 f8                	mov    %edi,%eax
  800f8e:	c1 e8 0c             	shr    $0xc,%eax
  800f91:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f98:	f6 c2 01             	test   $0x1,%dl
  800f9b:	74 26                	je     800fc3 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f9d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fa4:	83 ec 0c             	sub    $0xc,%esp
  800fa7:	25 07 0e 00 00       	and    $0xe07,%eax
  800fac:	50                   	push   %eax
  800fad:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fb0:	6a 00                	push   $0x0
  800fb2:	57                   	push   %edi
  800fb3:	6a 00                	push   $0x0
  800fb5:	e8 b2 fb ff ff       	call   800b6c <sys_page_map>
  800fba:	89 c7                	mov    %eax,%edi
  800fbc:	83 c4 20             	add    $0x20,%esp
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	78 2e                	js     800ff1 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fc3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fc6:	89 d0                	mov    %edx,%eax
  800fc8:	c1 e8 0c             	shr    $0xc,%eax
  800fcb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fd2:	83 ec 0c             	sub    $0xc,%esp
  800fd5:	25 07 0e 00 00       	and    $0xe07,%eax
  800fda:	50                   	push   %eax
  800fdb:	53                   	push   %ebx
  800fdc:	6a 00                	push   $0x0
  800fde:	52                   	push   %edx
  800fdf:	6a 00                	push   $0x0
  800fe1:	e8 86 fb ff ff       	call   800b6c <sys_page_map>
  800fe6:	89 c7                	mov    %eax,%edi
  800fe8:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800feb:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fed:	85 ff                	test   %edi,%edi
  800fef:	79 1d                	jns    80100e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800ff1:	83 ec 08             	sub    $0x8,%esp
  800ff4:	53                   	push   %ebx
  800ff5:	6a 00                	push   $0x0
  800ff7:	e8 b2 fb ff ff       	call   800bae <sys_page_unmap>
	sys_page_unmap(0, nva);
  800ffc:	83 c4 08             	add    $0x8,%esp
  800fff:	ff 75 d4             	pushl  -0x2c(%ebp)
  801002:	6a 00                	push   $0x0
  801004:	e8 a5 fb ff ff       	call   800bae <sys_page_unmap>
	return r;
  801009:	83 c4 10             	add    $0x10,%esp
  80100c:	89 f8                	mov    %edi,%eax
}
  80100e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801011:	5b                   	pop    %ebx
  801012:	5e                   	pop    %esi
  801013:	5f                   	pop    %edi
  801014:	5d                   	pop    %ebp
  801015:	c3                   	ret    

00801016 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801016:	55                   	push   %ebp
  801017:	89 e5                	mov    %esp,%ebp
  801019:	53                   	push   %ebx
  80101a:	83 ec 14             	sub    $0x14,%esp
  80101d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801020:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801023:	50                   	push   %eax
  801024:	53                   	push   %ebx
  801025:	e8 86 fd ff ff       	call   800db0 <fd_lookup>
  80102a:	83 c4 08             	add    $0x8,%esp
  80102d:	89 c2                	mov    %eax,%edx
  80102f:	85 c0                	test   %eax,%eax
  801031:	78 6d                	js     8010a0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801033:	83 ec 08             	sub    $0x8,%esp
  801036:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801039:	50                   	push   %eax
  80103a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80103d:	ff 30                	pushl  (%eax)
  80103f:	e8 c2 fd ff ff       	call   800e06 <dev_lookup>
  801044:	83 c4 10             	add    $0x10,%esp
  801047:	85 c0                	test   %eax,%eax
  801049:	78 4c                	js     801097 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80104b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80104e:	8b 42 08             	mov    0x8(%edx),%eax
  801051:	83 e0 03             	and    $0x3,%eax
  801054:	83 f8 01             	cmp    $0x1,%eax
  801057:	75 21                	jne    80107a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801059:	a1 04 40 80 00       	mov    0x804004,%eax
  80105e:	8b 40 50             	mov    0x50(%eax),%eax
  801061:	83 ec 04             	sub    $0x4,%esp
  801064:	53                   	push   %ebx
  801065:	50                   	push   %eax
  801066:	68 0d 22 80 00       	push   $0x80220d
  80106b:	e8 31 f1 ff ff       	call   8001a1 <cprintf>
		return -E_INVAL;
  801070:	83 c4 10             	add    $0x10,%esp
  801073:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801078:	eb 26                	jmp    8010a0 <read+0x8a>
	}
	if (!dev->dev_read)
  80107a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80107d:	8b 40 08             	mov    0x8(%eax),%eax
  801080:	85 c0                	test   %eax,%eax
  801082:	74 17                	je     80109b <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801084:	83 ec 04             	sub    $0x4,%esp
  801087:	ff 75 10             	pushl  0x10(%ebp)
  80108a:	ff 75 0c             	pushl  0xc(%ebp)
  80108d:	52                   	push   %edx
  80108e:	ff d0                	call   *%eax
  801090:	89 c2                	mov    %eax,%edx
  801092:	83 c4 10             	add    $0x10,%esp
  801095:	eb 09                	jmp    8010a0 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801097:	89 c2                	mov    %eax,%edx
  801099:	eb 05                	jmp    8010a0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80109b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8010a0:	89 d0                	mov    %edx,%eax
  8010a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010a5:	c9                   	leave  
  8010a6:	c3                   	ret    

008010a7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010a7:	55                   	push   %ebp
  8010a8:	89 e5                	mov    %esp,%ebp
  8010aa:	57                   	push   %edi
  8010ab:	56                   	push   %esi
  8010ac:	53                   	push   %ebx
  8010ad:	83 ec 0c             	sub    $0xc,%esp
  8010b0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010b3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010bb:	eb 21                	jmp    8010de <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010bd:	83 ec 04             	sub    $0x4,%esp
  8010c0:	89 f0                	mov    %esi,%eax
  8010c2:	29 d8                	sub    %ebx,%eax
  8010c4:	50                   	push   %eax
  8010c5:	89 d8                	mov    %ebx,%eax
  8010c7:	03 45 0c             	add    0xc(%ebp),%eax
  8010ca:	50                   	push   %eax
  8010cb:	57                   	push   %edi
  8010cc:	e8 45 ff ff ff       	call   801016 <read>
		if (m < 0)
  8010d1:	83 c4 10             	add    $0x10,%esp
  8010d4:	85 c0                	test   %eax,%eax
  8010d6:	78 10                	js     8010e8 <readn+0x41>
			return m;
		if (m == 0)
  8010d8:	85 c0                	test   %eax,%eax
  8010da:	74 0a                	je     8010e6 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010dc:	01 c3                	add    %eax,%ebx
  8010de:	39 f3                	cmp    %esi,%ebx
  8010e0:	72 db                	jb     8010bd <readn+0x16>
  8010e2:	89 d8                	mov    %ebx,%eax
  8010e4:	eb 02                	jmp    8010e8 <readn+0x41>
  8010e6:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010eb:	5b                   	pop    %ebx
  8010ec:	5e                   	pop    %esi
  8010ed:	5f                   	pop    %edi
  8010ee:	5d                   	pop    %ebp
  8010ef:	c3                   	ret    

008010f0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	53                   	push   %ebx
  8010f4:	83 ec 14             	sub    $0x14,%esp
  8010f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010fd:	50                   	push   %eax
  8010fe:	53                   	push   %ebx
  8010ff:	e8 ac fc ff ff       	call   800db0 <fd_lookup>
  801104:	83 c4 08             	add    $0x8,%esp
  801107:	89 c2                	mov    %eax,%edx
  801109:	85 c0                	test   %eax,%eax
  80110b:	78 68                	js     801175 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80110d:	83 ec 08             	sub    $0x8,%esp
  801110:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801113:	50                   	push   %eax
  801114:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801117:	ff 30                	pushl  (%eax)
  801119:	e8 e8 fc ff ff       	call   800e06 <dev_lookup>
  80111e:	83 c4 10             	add    $0x10,%esp
  801121:	85 c0                	test   %eax,%eax
  801123:	78 47                	js     80116c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801125:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801128:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80112c:	75 21                	jne    80114f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80112e:	a1 04 40 80 00       	mov    0x804004,%eax
  801133:	8b 40 50             	mov    0x50(%eax),%eax
  801136:	83 ec 04             	sub    $0x4,%esp
  801139:	53                   	push   %ebx
  80113a:	50                   	push   %eax
  80113b:	68 29 22 80 00       	push   $0x802229
  801140:	e8 5c f0 ff ff       	call   8001a1 <cprintf>
		return -E_INVAL;
  801145:	83 c4 10             	add    $0x10,%esp
  801148:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80114d:	eb 26                	jmp    801175 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80114f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801152:	8b 52 0c             	mov    0xc(%edx),%edx
  801155:	85 d2                	test   %edx,%edx
  801157:	74 17                	je     801170 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801159:	83 ec 04             	sub    $0x4,%esp
  80115c:	ff 75 10             	pushl  0x10(%ebp)
  80115f:	ff 75 0c             	pushl  0xc(%ebp)
  801162:	50                   	push   %eax
  801163:	ff d2                	call   *%edx
  801165:	89 c2                	mov    %eax,%edx
  801167:	83 c4 10             	add    $0x10,%esp
  80116a:	eb 09                	jmp    801175 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80116c:	89 c2                	mov    %eax,%edx
  80116e:	eb 05                	jmp    801175 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801170:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801175:	89 d0                	mov    %edx,%eax
  801177:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80117a:	c9                   	leave  
  80117b:	c3                   	ret    

0080117c <seek>:

int
seek(int fdnum, off_t offset)
{
  80117c:	55                   	push   %ebp
  80117d:	89 e5                	mov    %esp,%ebp
  80117f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801182:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801185:	50                   	push   %eax
  801186:	ff 75 08             	pushl  0x8(%ebp)
  801189:	e8 22 fc ff ff       	call   800db0 <fd_lookup>
  80118e:	83 c4 08             	add    $0x8,%esp
  801191:	85 c0                	test   %eax,%eax
  801193:	78 0e                	js     8011a3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801195:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801198:	8b 55 0c             	mov    0xc(%ebp),%edx
  80119b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80119e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011a3:	c9                   	leave  
  8011a4:	c3                   	ret    

008011a5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011a5:	55                   	push   %ebp
  8011a6:	89 e5                	mov    %esp,%ebp
  8011a8:	53                   	push   %ebx
  8011a9:	83 ec 14             	sub    $0x14,%esp
  8011ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b2:	50                   	push   %eax
  8011b3:	53                   	push   %ebx
  8011b4:	e8 f7 fb ff ff       	call   800db0 <fd_lookup>
  8011b9:	83 c4 08             	add    $0x8,%esp
  8011bc:	89 c2                	mov    %eax,%edx
  8011be:	85 c0                	test   %eax,%eax
  8011c0:	78 65                	js     801227 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c2:	83 ec 08             	sub    $0x8,%esp
  8011c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c8:	50                   	push   %eax
  8011c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011cc:	ff 30                	pushl  (%eax)
  8011ce:	e8 33 fc ff ff       	call   800e06 <dev_lookup>
  8011d3:	83 c4 10             	add    $0x10,%esp
  8011d6:	85 c0                	test   %eax,%eax
  8011d8:	78 44                	js     80121e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011dd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011e1:	75 21                	jne    801204 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011e3:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011e8:	8b 40 50             	mov    0x50(%eax),%eax
  8011eb:	83 ec 04             	sub    $0x4,%esp
  8011ee:	53                   	push   %ebx
  8011ef:	50                   	push   %eax
  8011f0:	68 ec 21 80 00       	push   $0x8021ec
  8011f5:	e8 a7 ef ff ff       	call   8001a1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011fa:	83 c4 10             	add    $0x10,%esp
  8011fd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801202:	eb 23                	jmp    801227 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801204:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801207:	8b 52 18             	mov    0x18(%edx),%edx
  80120a:	85 d2                	test   %edx,%edx
  80120c:	74 14                	je     801222 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80120e:	83 ec 08             	sub    $0x8,%esp
  801211:	ff 75 0c             	pushl  0xc(%ebp)
  801214:	50                   	push   %eax
  801215:	ff d2                	call   *%edx
  801217:	89 c2                	mov    %eax,%edx
  801219:	83 c4 10             	add    $0x10,%esp
  80121c:	eb 09                	jmp    801227 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80121e:	89 c2                	mov    %eax,%edx
  801220:	eb 05                	jmp    801227 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801222:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801227:	89 d0                	mov    %edx,%eax
  801229:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80122c:	c9                   	leave  
  80122d:	c3                   	ret    

0080122e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80122e:	55                   	push   %ebp
  80122f:	89 e5                	mov    %esp,%ebp
  801231:	53                   	push   %ebx
  801232:	83 ec 14             	sub    $0x14,%esp
  801235:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801238:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80123b:	50                   	push   %eax
  80123c:	ff 75 08             	pushl  0x8(%ebp)
  80123f:	e8 6c fb ff ff       	call   800db0 <fd_lookup>
  801244:	83 c4 08             	add    $0x8,%esp
  801247:	89 c2                	mov    %eax,%edx
  801249:	85 c0                	test   %eax,%eax
  80124b:	78 58                	js     8012a5 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80124d:	83 ec 08             	sub    $0x8,%esp
  801250:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801253:	50                   	push   %eax
  801254:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801257:	ff 30                	pushl  (%eax)
  801259:	e8 a8 fb ff ff       	call   800e06 <dev_lookup>
  80125e:	83 c4 10             	add    $0x10,%esp
  801261:	85 c0                	test   %eax,%eax
  801263:	78 37                	js     80129c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801265:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801268:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80126c:	74 32                	je     8012a0 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80126e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801271:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801278:	00 00 00 
	stat->st_isdir = 0;
  80127b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801282:	00 00 00 
	stat->st_dev = dev;
  801285:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80128b:	83 ec 08             	sub    $0x8,%esp
  80128e:	53                   	push   %ebx
  80128f:	ff 75 f0             	pushl  -0x10(%ebp)
  801292:	ff 50 14             	call   *0x14(%eax)
  801295:	89 c2                	mov    %eax,%edx
  801297:	83 c4 10             	add    $0x10,%esp
  80129a:	eb 09                	jmp    8012a5 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80129c:	89 c2                	mov    %eax,%edx
  80129e:	eb 05                	jmp    8012a5 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012a0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012a5:	89 d0                	mov    %edx,%eax
  8012a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012aa:	c9                   	leave  
  8012ab:	c3                   	ret    

008012ac <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012ac:	55                   	push   %ebp
  8012ad:	89 e5                	mov    %esp,%ebp
  8012af:	56                   	push   %esi
  8012b0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012b1:	83 ec 08             	sub    $0x8,%esp
  8012b4:	6a 00                	push   $0x0
  8012b6:	ff 75 08             	pushl  0x8(%ebp)
  8012b9:	e8 e3 01 00 00       	call   8014a1 <open>
  8012be:	89 c3                	mov    %eax,%ebx
  8012c0:	83 c4 10             	add    $0x10,%esp
  8012c3:	85 c0                	test   %eax,%eax
  8012c5:	78 1b                	js     8012e2 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012c7:	83 ec 08             	sub    $0x8,%esp
  8012ca:	ff 75 0c             	pushl  0xc(%ebp)
  8012cd:	50                   	push   %eax
  8012ce:	e8 5b ff ff ff       	call   80122e <fstat>
  8012d3:	89 c6                	mov    %eax,%esi
	close(fd);
  8012d5:	89 1c 24             	mov    %ebx,(%esp)
  8012d8:	e8 fd fb ff ff       	call   800eda <close>
	return r;
  8012dd:	83 c4 10             	add    $0x10,%esp
  8012e0:	89 f0                	mov    %esi,%eax
}
  8012e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012e5:	5b                   	pop    %ebx
  8012e6:	5e                   	pop    %esi
  8012e7:	5d                   	pop    %ebp
  8012e8:	c3                   	ret    

008012e9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012e9:	55                   	push   %ebp
  8012ea:	89 e5                	mov    %esp,%ebp
  8012ec:	56                   	push   %esi
  8012ed:	53                   	push   %ebx
  8012ee:	89 c6                	mov    %eax,%esi
  8012f0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012f2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012f9:	75 12                	jne    80130d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012fb:	83 ec 0c             	sub    $0xc,%esp
  8012fe:	6a 01                	push   $0x1
  801300:	e8 3c 08 00 00       	call   801b41 <ipc_find_env>
  801305:	a3 00 40 80 00       	mov    %eax,0x804000
  80130a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80130d:	6a 07                	push   $0x7
  80130f:	68 00 50 80 00       	push   $0x805000
  801314:	56                   	push   %esi
  801315:	ff 35 00 40 80 00    	pushl  0x804000
  80131b:	e8 bf 07 00 00       	call   801adf <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801320:	83 c4 0c             	add    $0xc,%esp
  801323:	6a 00                	push   $0x0
  801325:	53                   	push   %ebx
  801326:	6a 00                	push   $0x0
  801328:	e8 3d 07 00 00       	call   801a6a <ipc_recv>
}
  80132d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801330:	5b                   	pop    %ebx
  801331:	5e                   	pop    %esi
  801332:	5d                   	pop    %ebp
  801333:	c3                   	ret    

00801334 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801334:	55                   	push   %ebp
  801335:	89 e5                	mov    %esp,%ebp
  801337:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80133a:	8b 45 08             	mov    0x8(%ebp),%eax
  80133d:	8b 40 0c             	mov    0xc(%eax),%eax
  801340:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801345:	8b 45 0c             	mov    0xc(%ebp),%eax
  801348:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80134d:	ba 00 00 00 00       	mov    $0x0,%edx
  801352:	b8 02 00 00 00       	mov    $0x2,%eax
  801357:	e8 8d ff ff ff       	call   8012e9 <fsipc>
}
  80135c:	c9                   	leave  
  80135d:	c3                   	ret    

0080135e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80135e:	55                   	push   %ebp
  80135f:	89 e5                	mov    %esp,%ebp
  801361:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801364:	8b 45 08             	mov    0x8(%ebp),%eax
  801367:	8b 40 0c             	mov    0xc(%eax),%eax
  80136a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80136f:	ba 00 00 00 00       	mov    $0x0,%edx
  801374:	b8 06 00 00 00       	mov    $0x6,%eax
  801379:	e8 6b ff ff ff       	call   8012e9 <fsipc>
}
  80137e:	c9                   	leave  
  80137f:	c3                   	ret    

00801380 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
  801383:	53                   	push   %ebx
  801384:	83 ec 04             	sub    $0x4,%esp
  801387:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80138a:	8b 45 08             	mov    0x8(%ebp),%eax
  80138d:	8b 40 0c             	mov    0xc(%eax),%eax
  801390:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801395:	ba 00 00 00 00       	mov    $0x0,%edx
  80139a:	b8 05 00 00 00       	mov    $0x5,%eax
  80139f:	e8 45 ff ff ff       	call   8012e9 <fsipc>
  8013a4:	85 c0                	test   %eax,%eax
  8013a6:	78 2c                	js     8013d4 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013a8:	83 ec 08             	sub    $0x8,%esp
  8013ab:	68 00 50 80 00       	push   $0x805000
  8013b0:	53                   	push   %ebx
  8013b1:	e8 70 f3 ff ff       	call   800726 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013b6:	a1 80 50 80 00       	mov    0x805080,%eax
  8013bb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013c1:	a1 84 50 80 00       	mov    0x805084,%eax
  8013c6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013cc:	83 c4 10             	add    $0x10,%esp
  8013cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d7:	c9                   	leave  
  8013d8:	c3                   	ret    

008013d9 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013d9:	55                   	push   %ebp
  8013da:	89 e5                	mov    %esp,%ebp
  8013dc:	83 ec 0c             	sub    $0xc,%esp
  8013df:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8013e5:	8b 52 0c             	mov    0xc(%edx),%edx
  8013e8:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8013ee:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8013f3:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8013f8:	0f 47 c2             	cmova  %edx,%eax
  8013fb:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801400:	50                   	push   %eax
  801401:	ff 75 0c             	pushl  0xc(%ebp)
  801404:	68 08 50 80 00       	push   $0x805008
  801409:	e8 aa f4 ff ff       	call   8008b8 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80140e:	ba 00 00 00 00       	mov    $0x0,%edx
  801413:	b8 04 00 00 00       	mov    $0x4,%eax
  801418:	e8 cc fe ff ff       	call   8012e9 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80141d:	c9                   	leave  
  80141e:	c3                   	ret    

0080141f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80141f:	55                   	push   %ebp
  801420:	89 e5                	mov    %esp,%ebp
  801422:	56                   	push   %esi
  801423:	53                   	push   %ebx
  801424:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801427:	8b 45 08             	mov    0x8(%ebp),%eax
  80142a:	8b 40 0c             	mov    0xc(%eax),%eax
  80142d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801432:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801438:	ba 00 00 00 00       	mov    $0x0,%edx
  80143d:	b8 03 00 00 00       	mov    $0x3,%eax
  801442:	e8 a2 fe ff ff       	call   8012e9 <fsipc>
  801447:	89 c3                	mov    %eax,%ebx
  801449:	85 c0                	test   %eax,%eax
  80144b:	78 4b                	js     801498 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80144d:	39 c6                	cmp    %eax,%esi
  80144f:	73 16                	jae    801467 <devfile_read+0x48>
  801451:	68 58 22 80 00       	push   $0x802258
  801456:	68 5f 22 80 00       	push   $0x80225f
  80145b:	6a 7c                	push   $0x7c
  80145d:	68 74 22 80 00       	push   $0x802274
  801462:	e8 bd 05 00 00       	call   801a24 <_panic>
	assert(r <= PGSIZE);
  801467:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80146c:	7e 16                	jle    801484 <devfile_read+0x65>
  80146e:	68 7f 22 80 00       	push   $0x80227f
  801473:	68 5f 22 80 00       	push   $0x80225f
  801478:	6a 7d                	push   $0x7d
  80147a:	68 74 22 80 00       	push   $0x802274
  80147f:	e8 a0 05 00 00       	call   801a24 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801484:	83 ec 04             	sub    $0x4,%esp
  801487:	50                   	push   %eax
  801488:	68 00 50 80 00       	push   $0x805000
  80148d:	ff 75 0c             	pushl  0xc(%ebp)
  801490:	e8 23 f4 ff ff       	call   8008b8 <memmove>
	return r;
  801495:	83 c4 10             	add    $0x10,%esp
}
  801498:	89 d8                	mov    %ebx,%eax
  80149a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80149d:	5b                   	pop    %ebx
  80149e:	5e                   	pop    %esi
  80149f:	5d                   	pop    %ebp
  8014a0:	c3                   	ret    

008014a1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014a1:	55                   	push   %ebp
  8014a2:	89 e5                	mov    %esp,%ebp
  8014a4:	53                   	push   %ebx
  8014a5:	83 ec 20             	sub    $0x20,%esp
  8014a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014ab:	53                   	push   %ebx
  8014ac:	e8 3c f2 ff ff       	call   8006ed <strlen>
  8014b1:	83 c4 10             	add    $0x10,%esp
  8014b4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014b9:	7f 67                	jg     801522 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014bb:	83 ec 0c             	sub    $0xc,%esp
  8014be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c1:	50                   	push   %eax
  8014c2:	e8 9a f8 ff ff       	call   800d61 <fd_alloc>
  8014c7:	83 c4 10             	add    $0x10,%esp
		return r;
  8014ca:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014cc:	85 c0                	test   %eax,%eax
  8014ce:	78 57                	js     801527 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014d0:	83 ec 08             	sub    $0x8,%esp
  8014d3:	53                   	push   %ebx
  8014d4:	68 00 50 80 00       	push   $0x805000
  8014d9:	e8 48 f2 ff ff       	call   800726 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014e1:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8014ee:	e8 f6 fd ff ff       	call   8012e9 <fsipc>
  8014f3:	89 c3                	mov    %eax,%ebx
  8014f5:	83 c4 10             	add    $0x10,%esp
  8014f8:	85 c0                	test   %eax,%eax
  8014fa:	79 14                	jns    801510 <open+0x6f>
		fd_close(fd, 0);
  8014fc:	83 ec 08             	sub    $0x8,%esp
  8014ff:	6a 00                	push   $0x0
  801501:	ff 75 f4             	pushl  -0xc(%ebp)
  801504:	e8 50 f9 ff ff       	call   800e59 <fd_close>
		return r;
  801509:	83 c4 10             	add    $0x10,%esp
  80150c:	89 da                	mov    %ebx,%edx
  80150e:	eb 17                	jmp    801527 <open+0x86>
	}

	return fd2num(fd);
  801510:	83 ec 0c             	sub    $0xc,%esp
  801513:	ff 75 f4             	pushl  -0xc(%ebp)
  801516:	e8 1f f8 ff ff       	call   800d3a <fd2num>
  80151b:	89 c2                	mov    %eax,%edx
  80151d:	83 c4 10             	add    $0x10,%esp
  801520:	eb 05                	jmp    801527 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801522:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801527:	89 d0                	mov    %edx,%eax
  801529:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80152c:	c9                   	leave  
  80152d:	c3                   	ret    

0080152e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80152e:	55                   	push   %ebp
  80152f:	89 e5                	mov    %esp,%ebp
  801531:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801534:	ba 00 00 00 00       	mov    $0x0,%edx
  801539:	b8 08 00 00 00       	mov    $0x8,%eax
  80153e:	e8 a6 fd ff ff       	call   8012e9 <fsipc>
}
  801543:	c9                   	leave  
  801544:	c3                   	ret    

00801545 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801545:	55                   	push   %ebp
  801546:	89 e5                	mov    %esp,%ebp
  801548:	56                   	push   %esi
  801549:	53                   	push   %ebx
  80154a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80154d:	83 ec 0c             	sub    $0xc,%esp
  801550:	ff 75 08             	pushl  0x8(%ebp)
  801553:	e8 f2 f7 ff ff       	call   800d4a <fd2data>
  801558:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80155a:	83 c4 08             	add    $0x8,%esp
  80155d:	68 8b 22 80 00       	push   $0x80228b
  801562:	53                   	push   %ebx
  801563:	e8 be f1 ff ff       	call   800726 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801568:	8b 46 04             	mov    0x4(%esi),%eax
  80156b:	2b 06                	sub    (%esi),%eax
  80156d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801573:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80157a:	00 00 00 
	stat->st_dev = &devpipe;
  80157d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801584:	30 80 00 
	return 0;
}
  801587:	b8 00 00 00 00       	mov    $0x0,%eax
  80158c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80158f:	5b                   	pop    %ebx
  801590:	5e                   	pop    %esi
  801591:	5d                   	pop    %ebp
  801592:	c3                   	ret    

00801593 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801593:	55                   	push   %ebp
  801594:	89 e5                	mov    %esp,%ebp
  801596:	53                   	push   %ebx
  801597:	83 ec 0c             	sub    $0xc,%esp
  80159a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80159d:	53                   	push   %ebx
  80159e:	6a 00                	push   $0x0
  8015a0:	e8 09 f6 ff ff       	call   800bae <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015a5:	89 1c 24             	mov    %ebx,(%esp)
  8015a8:	e8 9d f7 ff ff       	call   800d4a <fd2data>
  8015ad:	83 c4 08             	add    $0x8,%esp
  8015b0:	50                   	push   %eax
  8015b1:	6a 00                	push   $0x0
  8015b3:	e8 f6 f5 ff ff       	call   800bae <sys_page_unmap>
}
  8015b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015bb:	c9                   	leave  
  8015bc:	c3                   	ret    

008015bd <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015bd:	55                   	push   %ebp
  8015be:	89 e5                	mov    %esp,%ebp
  8015c0:	57                   	push   %edi
  8015c1:	56                   	push   %esi
  8015c2:	53                   	push   %ebx
  8015c3:	83 ec 1c             	sub    $0x1c,%esp
  8015c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015c9:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015cb:	a1 04 40 80 00       	mov    0x804004,%eax
  8015d0:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015d3:	83 ec 0c             	sub    $0xc,%esp
  8015d6:	ff 75 e0             	pushl  -0x20(%ebp)
  8015d9:	e8 a3 05 00 00       	call   801b81 <pageref>
  8015de:	89 c3                	mov    %eax,%ebx
  8015e0:	89 3c 24             	mov    %edi,(%esp)
  8015e3:	e8 99 05 00 00       	call   801b81 <pageref>
  8015e8:	83 c4 10             	add    $0x10,%esp
  8015eb:	39 c3                	cmp    %eax,%ebx
  8015ed:	0f 94 c1             	sete   %cl
  8015f0:	0f b6 c9             	movzbl %cl,%ecx
  8015f3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8015f6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8015fc:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  8015ff:	39 ce                	cmp    %ecx,%esi
  801601:	74 1b                	je     80161e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801603:	39 c3                	cmp    %eax,%ebx
  801605:	75 c4                	jne    8015cb <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801607:	8b 42 60             	mov    0x60(%edx),%eax
  80160a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80160d:	50                   	push   %eax
  80160e:	56                   	push   %esi
  80160f:	68 92 22 80 00       	push   $0x802292
  801614:	e8 88 eb ff ff       	call   8001a1 <cprintf>
  801619:	83 c4 10             	add    $0x10,%esp
  80161c:	eb ad                	jmp    8015cb <_pipeisclosed+0xe>
	}
}
  80161e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801621:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801624:	5b                   	pop    %ebx
  801625:	5e                   	pop    %esi
  801626:	5f                   	pop    %edi
  801627:	5d                   	pop    %ebp
  801628:	c3                   	ret    

00801629 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801629:	55                   	push   %ebp
  80162a:	89 e5                	mov    %esp,%ebp
  80162c:	57                   	push   %edi
  80162d:	56                   	push   %esi
  80162e:	53                   	push   %ebx
  80162f:	83 ec 28             	sub    $0x28,%esp
  801632:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801635:	56                   	push   %esi
  801636:	e8 0f f7 ff ff       	call   800d4a <fd2data>
  80163b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80163d:	83 c4 10             	add    $0x10,%esp
  801640:	bf 00 00 00 00       	mov    $0x0,%edi
  801645:	eb 4b                	jmp    801692 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801647:	89 da                	mov    %ebx,%edx
  801649:	89 f0                	mov    %esi,%eax
  80164b:	e8 6d ff ff ff       	call   8015bd <_pipeisclosed>
  801650:	85 c0                	test   %eax,%eax
  801652:	75 48                	jne    80169c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801654:	e8 b1 f4 ff ff       	call   800b0a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801659:	8b 43 04             	mov    0x4(%ebx),%eax
  80165c:	8b 0b                	mov    (%ebx),%ecx
  80165e:	8d 51 20             	lea    0x20(%ecx),%edx
  801661:	39 d0                	cmp    %edx,%eax
  801663:	73 e2                	jae    801647 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801665:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801668:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80166c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80166f:	89 c2                	mov    %eax,%edx
  801671:	c1 fa 1f             	sar    $0x1f,%edx
  801674:	89 d1                	mov    %edx,%ecx
  801676:	c1 e9 1b             	shr    $0x1b,%ecx
  801679:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80167c:	83 e2 1f             	and    $0x1f,%edx
  80167f:	29 ca                	sub    %ecx,%edx
  801681:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801685:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801689:	83 c0 01             	add    $0x1,%eax
  80168c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80168f:	83 c7 01             	add    $0x1,%edi
  801692:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801695:	75 c2                	jne    801659 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801697:	8b 45 10             	mov    0x10(%ebp),%eax
  80169a:	eb 05                	jmp    8016a1 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80169c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8016a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016a4:	5b                   	pop    %ebx
  8016a5:	5e                   	pop    %esi
  8016a6:	5f                   	pop    %edi
  8016a7:	5d                   	pop    %ebp
  8016a8:	c3                   	ret    

008016a9 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016a9:	55                   	push   %ebp
  8016aa:	89 e5                	mov    %esp,%ebp
  8016ac:	57                   	push   %edi
  8016ad:	56                   	push   %esi
  8016ae:	53                   	push   %ebx
  8016af:	83 ec 18             	sub    $0x18,%esp
  8016b2:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016b5:	57                   	push   %edi
  8016b6:	e8 8f f6 ff ff       	call   800d4a <fd2data>
  8016bb:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016bd:	83 c4 10             	add    $0x10,%esp
  8016c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016c5:	eb 3d                	jmp    801704 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8016c7:	85 db                	test   %ebx,%ebx
  8016c9:	74 04                	je     8016cf <devpipe_read+0x26>
				return i;
  8016cb:	89 d8                	mov    %ebx,%eax
  8016cd:	eb 44                	jmp    801713 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016cf:	89 f2                	mov    %esi,%edx
  8016d1:	89 f8                	mov    %edi,%eax
  8016d3:	e8 e5 fe ff ff       	call   8015bd <_pipeisclosed>
  8016d8:	85 c0                	test   %eax,%eax
  8016da:	75 32                	jne    80170e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016dc:	e8 29 f4 ff ff       	call   800b0a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016e1:	8b 06                	mov    (%esi),%eax
  8016e3:	3b 46 04             	cmp    0x4(%esi),%eax
  8016e6:	74 df                	je     8016c7 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016e8:	99                   	cltd   
  8016e9:	c1 ea 1b             	shr    $0x1b,%edx
  8016ec:	01 d0                	add    %edx,%eax
  8016ee:	83 e0 1f             	and    $0x1f,%eax
  8016f1:	29 d0                	sub    %edx,%eax
  8016f3:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016fb:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016fe:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801701:	83 c3 01             	add    $0x1,%ebx
  801704:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801707:	75 d8                	jne    8016e1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801709:	8b 45 10             	mov    0x10(%ebp),%eax
  80170c:	eb 05                	jmp    801713 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80170e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801713:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801716:	5b                   	pop    %ebx
  801717:	5e                   	pop    %esi
  801718:	5f                   	pop    %edi
  801719:	5d                   	pop    %ebp
  80171a:	c3                   	ret    

0080171b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80171b:	55                   	push   %ebp
  80171c:	89 e5                	mov    %esp,%ebp
  80171e:	56                   	push   %esi
  80171f:	53                   	push   %ebx
  801720:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801723:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801726:	50                   	push   %eax
  801727:	e8 35 f6 ff ff       	call   800d61 <fd_alloc>
  80172c:	83 c4 10             	add    $0x10,%esp
  80172f:	89 c2                	mov    %eax,%edx
  801731:	85 c0                	test   %eax,%eax
  801733:	0f 88 2c 01 00 00    	js     801865 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801739:	83 ec 04             	sub    $0x4,%esp
  80173c:	68 07 04 00 00       	push   $0x407
  801741:	ff 75 f4             	pushl  -0xc(%ebp)
  801744:	6a 00                	push   $0x0
  801746:	e8 de f3 ff ff       	call   800b29 <sys_page_alloc>
  80174b:	83 c4 10             	add    $0x10,%esp
  80174e:	89 c2                	mov    %eax,%edx
  801750:	85 c0                	test   %eax,%eax
  801752:	0f 88 0d 01 00 00    	js     801865 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801758:	83 ec 0c             	sub    $0xc,%esp
  80175b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80175e:	50                   	push   %eax
  80175f:	e8 fd f5 ff ff       	call   800d61 <fd_alloc>
  801764:	89 c3                	mov    %eax,%ebx
  801766:	83 c4 10             	add    $0x10,%esp
  801769:	85 c0                	test   %eax,%eax
  80176b:	0f 88 e2 00 00 00    	js     801853 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801771:	83 ec 04             	sub    $0x4,%esp
  801774:	68 07 04 00 00       	push   $0x407
  801779:	ff 75 f0             	pushl  -0x10(%ebp)
  80177c:	6a 00                	push   $0x0
  80177e:	e8 a6 f3 ff ff       	call   800b29 <sys_page_alloc>
  801783:	89 c3                	mov    %eax,%ebx
  801785:	83 c4 10             	add    $0x10,%esp
  801788:	85 c0                	test   %eax,%eax
  80178a:	0f 88 c3 00 00 00    	js     801853 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801790:	83 ec 0c             	sub    $0xc,%esp
  801793:	ff 75 f4             	pushl  -0xc(%ebp)
  801796:	e8 af f5 ff ff       	call   800d4a <fd2data>
  80179b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80179d:	83 c4 0c             	add    $0xc,%esp
  8017a0:	68 07 04 00 00       	push   $0x407
  8017a5:	50                   	push   %eax
  8017a6:	6a 00                	push   $0x0
  8017a8:	e8 7c f3 ff ff       	call   800b29 <sys_page_alloc>
  8017ad:	89 c3                	mov    %eax,%ebx
  8017af:	83 c4 10             	add    $0x10,%esp
  8017b2:	85 c0                	test   %eax,%eax
  8017b4:	0f 88 89 00 00 00    	js     801843 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017ba:	83 ec 0c             	sub    $0xc,%esp
  8017bd:	ff 75 f0             	pushl  -0x10(%ebp)
  8017c0:	e8 85 f5 ff ff       	call   800d4a <fd2data>
  8017c5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017cc:	50                   	push   %eax
  8017cd:	6a 00                	push   $0x0
  8017cf:	56                   	push   %esi
  8017d0:	6a 00                	push   $0x0
  8017d2:	e8 95 f3 ff ff       	call   800b6c <sys_page_map>
  8017d7:	89 c3                	mov    %eax,%ebx
  8017d9:	83 c4 20             	add    $0x20,%esp
  8017dc:	85 c0                	test   %eax,%eax
  8017de:	78 55                	js     801835 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017e0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ee:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017f5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017fe:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801800:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801803:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80180a:	83 ec 0c             	sub    $0xc,%esp
  80180d:	ff 75 f4             	pushl  -0xc(%ebp)
  801810:	e8 25 f5 ff ff       	call   800d3a <fd2num>
  801815:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801818:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80181a:	83 c4 04             	add    $0x4,%esp
  80181d:	ff 75 f0             	pushl  -0x10(%ebp)
  801820:	e8 15 f5 ff ff       	call   800d3a <fd2num>
  801825:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801828:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80182b:	83 c4 10             	add    $0x10,%esp
  80182e:	ba 00 00 00 00       	mov    $0x0,%edx
  801833:	eb 30                	jmp    801865 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801835:	83 ec 08             	sub    $0x8,%esp
  801838:	56                   	push   %esi
  801839:	6a 00                	push   $0x0
  80183b:	e8 6e f3 ff ff       	call   800bae <sys_page_unmap>
  801840:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801843:	83 ec 08             	sub    $0x8,%esp
  801846:	ff 75 f0             	pushl  -0x10(%ebp)
  801849:	6a 00                	push   $0x0
  80184b:	e8 5e f3 ff ff       	call   800bae <sys_page_unmap>
  801850:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801853:	83 ec 08             	sub    $0x8,%esp
  801856:	ff 75 f4             	pushl  -0xc(%ebp)
  801859:	6a 00                	push   $0x0
  80185b:	e8 4e f3 ff ff       	call   800bae <sys_page_unmap>
  801860:	83 c4 10             	add    $0x10,%esp
  801863:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801865:	89 d0                	mov    %edx,%eax
  801867:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80186a:	5b                   	pop    %ebx
  80186b:	5e                   	pop    %esi
  80186c:	5d                   	pop    %ebp
  80186d:	c3                   	ret    

0080186e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80186e:	55                   	push   %ebp
  80186f:	89 e5                	mov    %esp,%ebp
  801871:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801874:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801877:	50                   	push   %eax
  801878:	ff 75 08             	pushl  0x8(%ebp)
  80187b:	e8 30 f5 ff ff       	call   800db0 <fd_lookup>
  801880:	83 c4 10             	add    $0x10,%esp
  801883:	85 c0                	test   %eax,%eax
  801885:	78 18                	js     80189f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801887:	83 ec 0c             	sub    $0xc,%esp
  80188a:	ff 75 f4             	pushl  -0xc(%ebp)
  80188d:	e8 b8 f4 ff ff       	call   800d4a <fd2data>
	return _pipeisclosed(fd, p);
  801892:	89 c2                	mov    %eax,%edx
  801894:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801897:	e8 21 fd ff ff       	call   8015bd <_pipeisclosed>
  80189c:	83 c4 10             	add    $0x10,%esp
}
  80189f:	c9                   	leave  
  8018a0:	c3                   	ret    

008018a1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8018a1:	55                   	push   %ebp
  8018a2:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8018a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a9:	5d                   	pop    %ebp
  8018aa:	c3                   	ret    

008018ab <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018ab:	55                   	push   %ebp
  8018ac:	89 e5                	mov    %esp,%ebp
  8018ae:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018b1:	68 aa 22 80 00       	push   $0x8022aa
  8018b6:	ff 75 0c             	pushl  0xc(%ebp)
  8018b9:	e8 68 ee ff ff       	call   800726 <strcpy>
	return 0;
}
  8018be:	b8 00 00 00 00       	mov    $0x0,%eax
  8018c3:	c9                   	leave  
  8018c4:	c3                   	ret    

008018c5 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018c5:	55                   	push   %ebp
  8018c6:	89 e5                	mov    %esp,%ebp
  8018c8:	57                   	push   %edi
  8018c9:	56                   	push   %esi
  8018ca:	53                   	push   %ebx
  8018cb:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018d1:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018d6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018dc:	eb 2d                	jmp    80190b <devcons_write+0x46>
		m = n - tot;
  8018de:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018e1:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8018e3:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018e6:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8018eb:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018ee:	83 ec 04             	sub    $0x4,%esp
  8018f1:	53                   	push   %ebx
  8018f2:	03 45 0c             	add    0xc(%ebp),%eax
  8018f5:	50                   	push   %eax
  8018f6:	57                   	push   %edi
  8018f7:	e8 bc ef ff ff       	call   8008b8 <memmove>
		sys_cputs(buf, m);
  8018fc:	83 c4 08             	add    $0x8,%esp
  8018ff:	53                   	push   %ebx
  801900:	57                   	push   %edi
  801901:	e8 67 f1 ff ff       	call   800a6d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801906:	01 de                	add    %ebx,%esi
  801908:	83 c4 10             	add    $0x10,%esp
  80190b:	89 f0                	mov    %esi,%eax
  80190d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801910:	72 cc                	jb     8018de <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801912:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801915:	5b                   	pop    %ebx
  801916:	5e                   	pop    %esi
  801917:	5f                   	pop    %edi
  801918:	5d                   	pop    %ebp
  801919:	c3                   	ret    

0080191a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80191a:	55                   	push   %ebp
  80191b:	89 e5                	mov    %esp,%ebp
  80191d:	83 ec 08             	sub    $0x8,%esp
  801920:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801925:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801929:	74 2a                	je     801955 <devcons_read+0x3b>
  80192b:	eb 05                	jmp    801932 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80192d:	e8 d8 f1 ff ff       	call   800b0a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801932:	e8 54 f1 ff ff       	call   800a8b <sys_cgetc>
  801937:	85 c0                	test   %eax,%eax
  801939:	74 f2                	je     80192d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80193b:	85 c0                	test   %eax,%eax
  80193d:	78 16                	js     801955 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80193f:	83 f8 04             	cmp    $0x4,%eax
  801942:	74 0c                	je     801950 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801944:	8b 55 0c             	mov    0xc(%ebp),%edx
  801947:	88 02                	mov    %al,(%edx)
	return 1;
  801949:	b8 01 00 00 00       	mov    $0x1,%eax
  80194e:	eb 05                	jmp    801955 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801950:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801955:	c9                   	leave  
  801956:	c3                   	ret    

00801957 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801957:	55                   	push   %ebp
  801958:	89 e5                	mov    %esp,%ebp
  80195a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80195d:	8b 45 08             	mov    0x8(%ebp),%eax
  801960:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801963:	6a 01                	push   $0x1
  801965:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801968:	50                   	push   %eax
  801969:	e8 ff f0 ff ff       	call   800a6d <sys_cputs>
}
  80196e:	83 c4 10             	add    $0x10,%esp
  801971:	c9                   	leave  
  801972:	c3                   	ret    

00801973 <getchar>:

int
getchar(void)
{
  801973:	55                   	push   %ebp
  801974:	89 e5                	mov    %esp,%ebp
  801976:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801979:	6a 01                	push   $0x1
  80197b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80197e:	50                   	push   %eax
  80197f:	6a 00                	push   $0x0
  801981:	e8 90 f6 ff ff       	call   801016 <read>
	if (r < 0)
  801986:	83 c4 10             	add    $0x10,%esp
  801989:	85 c0                	test   %eax,%eax
  80198b:	78 0f                	js     80199c <getchar+0x29>
		return r;
	if (r < 1)
  80198d:	85 c0                	test   %eax,%eax
  80198f:	7e 06                	jle    801997 <getchar+0x24>
		return -E_EOF;
	return c;
  801991:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801995:	eb 05                	jmp    80199c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801997:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80199c:	c9                   	leave  
  80199d:	c3                   	ret    

0080199e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019a7:	50                   	push   %eax
  8019a8:	ff 75 08             	pushl  0x8(%ebp)
  8019ab:	e8 00 f4 ff ff       	call   800db0 <fd_lookup>
  8019b0:	83 c4 10             	add    $0x10,%esp
  8019b3:	85 c0                	test   %eax,%eax
  8019b5:	78 11                	js     8019c8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8019b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ba:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019c0:	39 10                	cmp    %edx,(%eax)
  8019c2:	0f 94 c0             	sete   %al
  8019c5:	0f b6 c0             	movzbl %al,%eax
}
  8019c8:	c9                   	leave  
  8019c9:	c3                   	ret    

008019ca <opencons>:

int
opencons(void)
{
  8019ca:	55                   	push   %ebp
  8019cb:	89 e5                	mov    %esp,%ebp
  8019cd:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019d3:	50                   	push   %eax
  8019d4:	e8 88 f3 ff ff       	call   800d61 <fd_alloc>
  8019d9:	83 c4 10             	add    $0x10,%esp
		return r;
  8019dc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019de:	85 c0                	test   %eax,%eax
  8019e0:	78 3e                	js     801a20 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019e2:	83 ec 04             	sub    $0x4,%esp
  8019e5:	68 07 04 00 00       	push   $0x407
  8019ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8019ed:	6a 00                	push   $0x0
  8019ef:	e8 35 f1 ff ff       	call   800b29 <sys_page_alloc>
  8019f4:	83 c4 10             	add    $0x10,%esp
		return r;
  8019f7:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019f9:	85 c0                	test   %eax,%eax
  8019fb:	78 23                	js     801a20 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8019fd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a06:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a0b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a12:	83 ec 0c             	sub    $0xc,%esp
  801a15:	50                   	push   %eax
  801a16:	e8 1f f3 ff ff       	call   800d3a <fd2num>
  801a1b:	89 c2                	mov    %eax,%edx
  801a1d:	83 c4 10             	add    $0x10,%esp
}
  801a20:	89 d0                	mov    %edx,%eax
  801a22:	c9                   	leave  
  801a23:	c3                   	ret    

00801a24 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a24:	55                   	push   %ebp
  801a25:	89 e5                	mov    %esp,%ebp
  801a27:	56                   	push   %esi
  801a28:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a29:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a2c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a32:	e8 b4 f0 ff ff       	call   800aeb <sys_getenvid>
  801a37:	83 ec 0c             	sub    $0xc,%esp
  801a3a:	ff 75 0c             	pushl  0xc(%ebp)
  801a3d:	ff 75 08             	pushl  0x8(%ebp)
  801a40:	56                   	push   %esi
  801a41:	50                   	push   %eax
  801a42:	68 b8 22 80 00       	push   $0x8022b8
  801a47:	e8 55 e7 ff ff       	call   8001a1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a4c:	83 c4 18             	add    $0x18,%esp
  801a4f:	53                   	push   %ebx
  801a50:	ff 75 10             	pushl  0x10(%ebp)
  801a53:	e8 f8 e6 ff ff       	call   800150 <vcprintf>
	cprintf("\n");
  801a58:	c7 04 24 7c 1e 80 00 	movl   $0x801e7c,(%esp)
  801a5f:	e8 3d e7 ff ff       	call   8001a1 <cprintf>
  801a64:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a67:	cc                   	int3   
  801a68:	eb fd                	jmp    801a67 <_panic+0x43>

00801a6a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a6a:	55                   	push   %ebp
  801a6b:	89 e5                	mov    %esp,%ebp
  801a6d:	56                   	push   %esi
  801a6e:	53                   	push   %ebx
  801a6f:	8b 75 08             	mov    0x8(%ebp),%esi
  801a72:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a75:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801a78:	85 c0                	test   %eax,%eax
  801a7a:	75 12                	jne    801a8e <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801a7c:	83 ec 0c             	sub    $0xc,%esp
  801a7f:	68 00 00 c0 ee       	push   $0xeec00000
  801a84:	e8 50 f2 ff ff       	call   800cd9 <sys_ipc_recv>
  801a89:	83 c4 10             	add    $0x10,%esp
  801a8c:	eb 0c                	jmp    801a9a <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801a8e:	83 ec 0c             	sub    $0xc,%esp
  801a91:	50                   	push   %eax
  801a92:	e8 42 f2 ff ff       	call   800cd9 <sys_ipc_recv>
  801a97:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801a9a:	85 f6                	test   %esi,%esi
  801a9c:	0f 95 c1             	setne  %cl
  801a9f:	85 db                	test   %ebx,%ebx
  801aa1:	0f 95 c2             	setne  %dl
  801aa4:	84 d1                	test   %dl,%cl
  801aa6:	74 09                	je     801ab1 <ipc_recv+0x47>
  801aa8:	89 c2                	mov    %eax,%edx
  801aaa:	c1 ea 1f             	shr    $0x1f,%edx
  801aad:	84 d2                	test   %dl,%dl
  801aaf:	75 27                	jne    801ad8 <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801ab1:	85 f6                	test   %esi,%esi
  801ab3:	74 0a                	je     801abf <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801ab5:	a1 04 40 80 00       	mov    0x804004,%eax
  801aba:	8b 40 7c             	mov    0x7c(%eax),%eax
  801abd:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801abf:	85 db                	test   %ebx,%ebx
  801ac1:	74 0d                	je     801ad0 <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  801ac3:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac8:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801ace:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ad0:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad5:	8b 40 78             	mov    0x78(%eax),%eax
}
  801ad8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801adb:	5b                   	pop    %ebx
  801adc:	5e                   	pop    %esi
  801add:	5d                   	pop    %ebp
  801ade:	c3                   	ret    

00801adf <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801adf:	55                   	push   %ebp
  801ae0:	89 e5                	mov    %esp,%ebp
  801ae2:	57                   	push   %edi
  801ae3:	56                   	push   %esi
  801ae4:	53                   	push   %ebx
  801ae5:	83 ec 0c             	sub    $0xc,%esp
  801ae8:	8b 7d 08             	mov    0x8(%ebp),%edi
  801aeb:	8b 75 0c             	mov    0xc(%ebp),%esi
  801aee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801af1:	85 db                	test   %ebx,%ebx
  801af3:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801af8:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801afb:	ff 75 14             	pushl  0x14(%ebp)
  801afe:	53                   	push   %ebx
  801aff:	56                   	push   %esi
  801b00:	57                   	push   %edi
  801b01:	e8 b0 f1 ff ff       	call   800cb6 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801b06:	89 c2                	mov    %eax,%edx
  801b08:	c1 ea 1f             	shr    $0x1f,%edx
  801b0b:	83 c4 10             	add    $0x10,%esp
  801b0e:	84 d2                	test   %dl,%dl
  801b10:	74 17                	je     801b29 <ipc_send+0x4a>
  801b12:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b15:	74 12                	je     801b29 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801b17:	50                   	push   %eax
  801b18:	68 dc 22 80 00       	push   $0x8022dc
  801b1d:	6a 47                	push   $0x47
  801b1f:	68 ea 22 80 00       	push   $0x8022ea
  801b24:	e8 fb fe ff ff       	call   801a24 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801b29:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b2c:	75 07                	jne    801b35 <ipc_send+0x56>
			sys_yield();
  801b2e:	e8 d7 ef ff ff       	call   800b0a <sys_yield>
  801b33:	eb c6                	jmp    801afb <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801b35:	85 c0                	test   %eax,%eax
  801b37:	75 c2                	jne    801afb <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801b39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b3c:	5b                   	pop    %ebx
  801b3d:	5e                   	pop    %esi
  801b3e:	5f                   	pop    %edi
  801b3f:	5d                   	pop    %ebp
  801b40:	c3                   	ret    

00801b41 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b41:	55                   	push   %ebp
  801b42:	89 e5                	mov    %esp,%ebp
  801b44:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b47:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b4c:	89 c2                	mov    %eax,%edx
  801b4e:	c1 e2 07             	shl    $0x7,%edx
  801b51:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801b58:	8b 52 58             	mov    0x58(%edx),%edx
  801b5b:	39 ca                	cmp    %ecx,%edx
  801b5d:	75 11                	jne    801b70 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801b5f:	89 c2                	mov    %eax,%edx
  801b61:	c1 e2 07             	shl    $0x7,%edx
  801b64:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801b6b:	8b 40 50             	mov    0x50(%eax),%eax
  801b6e:	eb 0f                	jmp    801b7f <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b70:	83 c0 01             	add    $0x1,%eax
  801b73:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b78:	75 d2                	jne    801b4c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b7a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b7f:	5d                   	pop    %ebp
  801b80:	c3                   	ret    

00801b81 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b81:	55                   	push   %ebp
  801b82:	89 e5                	mov    %esp,%ebp
  801b84:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b87:	89 d0                	mov    %edx,%eax
  801b89:	c1 e8 16             	shr    $0x16,%eax
  801b8c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b93:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b98:	f6 c1 01             	test   $0x1,%cl
  801b9b:	74 1d                	je     801bba <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b9d:	c1 ea 0c             	shr    $0xc,%edx
  801ba0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ba7:	f6 c2 01             	test   $0x1,%dl
  801baa:	74 0e                	je     801bba <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bac:	c1 ea 0c             	shr    $0xc,%edx
  801baf:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bb6:	ef 
  801bb7:	0f b7 c0             	movzwl %ax,%eax
}
  801bba:	5d                   	pop    %ebp
  801bbb:	c3                   	ret    
  801bbc:	66 90                	xchg   %ax,%ax
  801bbe:	66 90                	xchg   %ax,%ax

00801bc0 <__udivdi3>:
  801bc0:	55                   	push   %ebp
  801bc1:	57                   	push   %edi
  801bc2:	56                   	push   %esi
  801bc3:	53                   	push   %ebx
  801bc4:	83 ec 1c             	sub    $0x1c,%esp
  801bc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bcb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bcf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801bd7:	85 f6                	test   %esi,%esi
  801bd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bdd:	89 ca                	mov    %ecx,%edx
  801bdf:	89 f8                	mov    %edi,%eax
  801be1:	75 3d                	jne    801c20 <__udivdi3+0x60>
  801be3:	39 cf                	cmp    %ecx,%edi
  801be5:	0f 87 c5 00 00 00    	ja     801cb0 <__udivdi3+0xf0>
  801beb:	85 ff                	test   %edi,%edi
  801bed:	89 fd                	mov    %edi,%ebp
  801bef:	75 0b                	jne    801bfc <__udivdi3+0x3c>
  801bf1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bf6:	31 d2                	xor    %edx,%edx
  801bf8:	f7 f7                	div    %edi
  801bfa:	89 c5                	mov    %eax,%ebp
  801bfc:	89 c8                	mov    %ecx,%eax
  801bfe:	31 d2                	xor    %edx,%edx
  801c00:	f7 f5                	div    %ebp
  801c02:	89 c1                	mov    %eax,%ecx
  801c04:	89 d8                	mov    %ebx,%eax
  801c06:	89 cf                	mov    %ecx,%edi
  801c08:	f7 f5                	div    %ebp
  801c0a:	89 c3                	mov    %eax,%ebx
  801c0c:	89 d8                	mov    %ebx,%eax
  801c0e:	89 fa                	mov    %edi,%edx
  801c10:	83 c4 1c             	add    $0x1c,%esp
  801c13:	5b                   	pop    %ebx
  801c14:	5e                   	pop    %esi
  801c15:	5f                   	pop    %edi
  801c16:	5d                   	pop    %ebp
  801c17:	c3                   	ret    
  801c18:	90                   	nop
  801c19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c20:	39 ce                	cmp    %ecx,%esi
  801c22:	77 74                	ja     801c98 <__udivdi3+0xd8>
  801c24:	0f bd fe             	bsr    %esi,%edi
  801c27:	83 f7 1f             	xor    $0x1f,%edi
  801c2a:	0f 84 98 00 00 00    	je     801cc8 <__udivdi3+0x108>
  801c30:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c35:	89 f9                	mov    %edi,%ecx
  801c37:	89 c5                	mov    %eax,%ebp
  801c39:	29 fb                	sub    %edi,%ebx
  801c3b:	d3 e6                	shl    %cl,%esi
  801c3d:	89 d9                	mov    %ebx,%ecx
  801c3f:	d3 ed                	shr    %cl,%ebp
  801c41:	89 f9                	mov    %edi,%ecx
  801c43:	d3 e0                	shl    %cl,%eax
  801c45:	09 ee                	or     %ebp,%esi
  801c47:	89 d9                	mov    %ebx,%ecx
  801c49:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c4d:	89 d5                	mov    %edx,%ebp
  801c4f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c53:	d3 ed                	shr    %cl,%ebp
  801c55:	89 f9                	mov    %edi,%ecx
  801c57:	d3 e2                	shl    %cl,%edx
  801c59:	89 d9                	mov    %ebx,%ecx
  801c5b:	d3 e8                	shr    %cl,%eax
  801c5d:	09 c2                	or     %eax,%edx
  801c5f:	89 d0                	mov    %edx,%eax
  801c61:	89 ea                	mov    %ebp,%edx
  801c63:	f7 f6                	div    %esi
  801c65:	89 d5                	mov    %edx,%ebp
  801c67:	89 c3                	mov    %eax,%ebx
  801c69:	f7 64 24 0c          	mull   0xc(%esp)
  801c6d:	39 d5                	cmp    %edx,%ebp
  801c6f:	72 10                	jb     801c81 <__udivdi3+0xc1>
  801c71:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c75:	89 f9                	mov    %edi,%ecx
  801c77:	d3 e6                	shl    %cl,%esi
  801c79:	39 c6                	cmp    %eax,%esi
  801c7b:	73 07                	jae    801c84 <__udivdi3+0xc4>
  801c7d:	39 d5                	cmp    %edx,%ebp
  801c7f:	75 03                	jne    801c84 <__udivdi3+0xc4>
  801c81:	83 eb 01             	sub    $0x1,%ebx
  801c84:	31 ff                	xor    %edi,%edi
  801c86:	89 d8                	mov    %ebx,%eax
  801c88:	89 fa                	mov    %edi,%edx
  801c8a:	83 c4 1c             	add    $0x1c,%esp
  801c8d:	5b                   	pop    %ebx
  801c8e:	5e                   	pop    %esi
  801c8f:	5f                   	pop    %edi
  801c90:	5d                   	pop    %ebp
  801c91:	c3                   	ret    
  801c92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c98:	31 ff                	xor    %edi,%edi
  801c9a:	31 db                	xor    %ebx,%ebx
  801c9c:	89 d8                	mov    %ebx,%eax
  801c9e:	89 fa                	mov    %edi,%edx
  801ca0:	83 c4 1c             	add    $0x1c,%esp
  801ca3:	5b                   	pop    %ebx
  801ca4:	5e                   	pop    %esi
  801ca5:	5f                   	pop    %edi
  801ca6:	5d                   	pop    %ebp
  801ca7:	c3                   	ret    
  801ca8:	90                   	nop
  801ca9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cb0:	89 d8                	mov    %ebx,%eax
  801cb2:	f7 f7                	div    %edi
  801cb4:	31 ff                	xor    %edi,%edi
  801cb6:	89 c3                	mov    %eax,%ebx
  801cb8:	89 d8                	mov    %ebx,%eax
  801cba:	89 fa                	mov    %edi,%edx
  801cbc:	83 c4 1c             	add    $0x1c,%esp
  801cbf:	5b                   	pop    %ebx
  801cc0:	5e                   	pop    %esi
  801cc1:	5f                   	pop    %edi
  801cc2:	5d                   	pop    %ebp
  801cc3:	c3                   	ret    
  801cc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cc8:	39 ce                	cmp    %ecx,%esi
  801cca:	72 0c                	jb     801cd8 <__udivdi3+0x118>
  801ccc:	31 db                	xor    %ebx,%ebx
  801cce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801cd2:	0f 87 34 ff ff ff    	ja     801c0c <__udivdi3+0x4c>
  801cd8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801cdd:	e9 2a ff ff ff       	jmp    801c0c <__udivdi3+0x4c>
  801ce2:	66 90                	xchg   %ax,%ax
  801ce4:	66 90                	xchg   %ax,%ax
  801ce6:	66 90                	xchg   %ax,%ax
  801ce8:	66 90                	xchg   %ax,%ax
  801cea:	66 90                	xchg   %ax,%ax
  801cec:	66 90                	xchg   %ax,%ax
  801cee:	66 90                	xchg   %ax,%ax

00801cf0 <__umoddi3>:
  801cf0:	55                   	push   %ebp
  801cf1:	57                   	push   %edi
  801cf2:	56                   	push   %esi
  801cf3:	53                   	push   %ebx
  801cf4:	83 ec 1c             	sub    $0x1c,%esp
  801cf7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801cfb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cff:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d07:	85 d2                	test   %edx,%edx
  801d09:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d11:	89 f3                	mov    %esi,%ebx
  801d13:	89 3c 24             	mov    %edi,(%esp)
  801d16:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d1a:	75 1c                	jne    801d38 <__umoddi3+0x48>
  801d1c:	39 f7                	cmp    %esi,%edi
  801d1e:	76 50                	jbe    801d70 <__umoddi3+0x80>
  801d20:	89 c8                	mov    %ecx,%eax
  801d22:	89 f2                	mov    %esi,%edx
  801d24:	f7 f7                	div    %edi
  801d26:	89 d0                	mov    %edx,%eax
  801d28:	31 d2                	xor    %edx,%edx
  801d2a:	83 c4 1c             	add    $0x1c,%esp
  801d2d:	5b                   	pop    %ebx
  801d2e:	5e                   	pop    %esi
  801d2f:	5f                   	pop    %edi
  801d30:	5d                   	pop    %ebp
  801d31:	c3                   	ret    
  801d32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d38:	39 f2                	cmp    %esi,%edx
  801d3a:	89 d0                	mov    %edx,%eax
  801d3c:	77 52                	ja     801d90 <__umoddi3+0xa0>
  801d3e:	0f bd ea             	bsr    %edx,%ebp
  801d41:	83 f5 1f             	xor    $0x1f,%ebp
  801d44:	75 5a                	jne    801da0 <__umoddi3+0xb0>
  801d46:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d4a:	0f 82 e0 00 00 00    	jb     801e30 <__umoddi3+0x140>
  801d50:	39 0c 24             	cmp    %ecx,(%esp)
  801d53:	0f 86 d7 00 00 00    	jbe    801e30 <__umoddi3+0x140>
  801d59:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d5d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d61:	83 c4 1c             	add    $0x1c,%esp
  801d64:	5b                   	pop    %ebx
  801d65:	5e                   	pop    %esi
  801d66:	5f                   	pop    %edi
  801d67:	5d                   	pop    %ebp
  801d68:	c3                   	ret    
  801d69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d70:	85 ff                	test   %edi,%edi
  801d72:	89 fd                	mov    %edi,%ebp
  801d74:	75 0b                	jne    801d81 <__umoddi3+0x91>
  801d76:	b8 01 00 00 00       	mov    $0x1,%eax
  801d7b:	31 d2                	xor    %edx,%edx
  801d7d:	f7 f7                	div    %edi
  801d7f:	89 c5                	mov    %eax,%ebp
  801d81:	89 f0                	mov    %esi,%eax
  801d83:	31 d2                	xor    %edx,%edx
  801d85:	f7 f5                	div    %ebp
  801d87:	89 c8                	mov    %ecx,%eax
  801d89:	f7 f5                	div    %ebp
  801d8b:	89 d0                	mov    %edx,%eax
  801d8d:	eb 99                	jmp    801d28 <__umoddi3+0x38>
  801d8f:	90                   	nop
  801d90:	89 c8                	mov    %ecx,%eax
  801d92:	89 f2                	mov    %esi,%edx
  801d94:	83 c4 1c             	add    $0x1c,%esp
  801d97:	5b                   	pop    %ebx
  801d98:	5e                   	pop    %esi
  801d99:	5f                   	pop    %edi
  801d9a:	5d                   	pop    %ebp
  801d9b:	c3                   	ret    
  801d9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801da0:	8b 34 24             	mov    (%esp),%esi
  801da3:	bf 20 00 00 00       	mov    $0x20,%edi
  801da8:	89 e9                	mov    %ebp,%ecx
  801daa:	29 ef                	sub    %ebp,%edi
  801dac:	d3 e0                	shl    %cl,%eax
  801dae:	89 f9                	mov    %edi,%ecx
  801db0:	89 f2                	mov    %esi,%edx
  801db2:	d3 ea                	shr    %cl,%edx
  801db4:	89 e9                	mov    %ebp,%ecx
  801db6:	09 c2                	or     %eax,%edx
  801db8:	89 d8                	mov    %ebx,%eax
  801dba:	89 14 24             	mov    %edx,(%esp)
  801dbd:	89 f2                	mov    %esi,%edx
  801dbf:	d3 e2                	shl    %cl,%edx
  801dc1:	89 f9                	mov    %edi,%ecx
  801dc3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dc7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801dcb:	d3 e8                	shr    %cl,%eax
  801dcd:	89 e9                	mov    %ebp,%ecx
  801dcf:	89 c6                	mov    %eax,%esi
  801dd1:	d3 e3                	shl    %cl,%ebx
  801dd3:	89 f9                	mov    %edi,%ecx
  801dd5:	89 d0                	mov    %edx,%eax
  801dd7:	d3 e8                	shr    %cl,%eax
  801dd9:	89 e9                	mov    %ebp,%ecx
  801ddb:	09 d8                	or     %ebx,%eax
  801ddd:	89 d3                	mov    %edx,%ebx
  801ddf:	89 f2                	mov    %esi,%edx
  801de1:	f7 34 24             	divl   (%esp)
  801de4:	89 d6                	mov    %edx,%esi
  801de6:	d3 e3                	shl    %cl,%ebx
  801de8:	f7 64 24 04          	mull   0x4(%esp)
  801dec:	39 d6                	cmp    %edx,%esi
  801dee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801df2:	89 d1                	mov    %edx,%ecx
  801df4:	89 c3                	mov    %eax,%ebx
  801df6:	72 08                	jb     801e00 <__umoddi3+0x110>
  801df8:	75 11                	jne    801e0b <__umoddi3+0x11b>
  801dfa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dfe:	73 0b                	jae    801e0b <__umoddi3+0x11b>
  801e00:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e04:	1b 14 24             	sbb    (%esp),%edx
  801e07:	89 d1                	mov    %edx,%ecx
  801e09:	89 c3                	mov    %eax,%ebx
  801e0b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e0f:	29 da                	sub    %ebx,%edx
  801e11:	19 ce                	sbb    %ecx,%esi
  801e13:	89 f9                	mov    %edi,%ecx
  801e15:	89 f0                	mov    %esi,%eax
  801e17:	d3 e0                	shl    %cl,%eax
  801e19:	89 e9                	mov    %ebp,%ecx
  801e1b:	d3 ea                	shr    %cl,%edx
  801e1d:	89 e9                	mov    %ebp,%ecx
  801e1f:	d3 ee                	shr    %cl,%esi
  801e21:	09 d0                	or     %edx,%eax
  801e23:	89 f2                	mov    %esi,%edx
  801e25:	83 c4 1c             	add    $0x1c,%esp
  801e28:	5b                   	pop    %ebx
  801e29:	5e                   	pop    %esi
  801e2a:	5f                   	pop    %edi
  801e2b:	5d                   	pop    %ebp
  801e2c:	c3                   	ret    
  801e2d:	8d 76 00             	lea    0x0(%esi),%esi
  801e30:	29 f9                	sub    %edi,%ecx
  801e32:	19 d6                	sbb    %edx,%esi
  801e34:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e38:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e3c:	e9 18 ff ff ff       	jmp    801d59 <__umoddi3+0x69>
