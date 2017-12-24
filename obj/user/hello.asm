
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
  800039:	68 20 1e 80 00       	push   $0x801e20
  80003e:	e8 56 01 00 00       	call   800199 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 40 80 00       	mov    0x804004,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 2e 1e 80 00       	push   $0x801e2e
  800054:	e8 40 01 00 00       	call   800199 <cprintf>
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
  800061:	57                   	push   %edi
  800062:	56                   	push   %esi
  800063:	53                   	push   %ebx
  800064:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800067:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  80006e:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  800071:	e8 6d 0a 00 00       	call   800ae3 <sys_getenvid>
  800076:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  80007c:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  800081:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800086:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  80008b:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  80008e:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  800094:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  800097:	39 c8                	cmp    %ecx,%eax
  800099:	0f 44 fb             	cmove  %ebx,%edi
  80009c:	b9 01 00 00 00       	mov    $0x1,%ecx
  8000a1:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000a4:	83 c2 01             	add    $0x1,%edx
  8000a7:	83 c3 7c             	add    $0x7c,%ebx
  8000aa:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  8000b0:	75 d9                	jne    80008b <libmain+0x2d>
  8000b2:	89 f0                	mov    %esi,%eax
  8000b4:	84 c0                	test   %al,%al
  8000b6:	74 06                	je     8000be <libmain+0x60>
  8000b8:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000be:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000c2:	7e 0a                	jle    8000ce <libmain+0x70>
		binaryname = argv[0];
  8000c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000c7:	8b 00                	mov    (%eax),%eax
  8000c9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ce:	83 ec 08             	sub    $0x8,%esp
  8000d1:	ff 75 0c             	pushl  0xc(%ebp)
  8000d4:	ff 75 08             	pushl  0x8(%ebp)
  8000d7:	e8 57 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000dc:	e8 0b 00 00 00       	call   8000ec <exit>
}
  8000e1:	83 c4 10             	add    $0x10,%esp
  8000e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e7:	5b                   	pop    %ebx
  8000e8:	5e                   	pop    %esi
  8000e9:	5f                   	pop    %edi
  8000ea:	5d                   	pop    %ebp
  8000eb:	c3                   	ret    

008000ec <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000f2:	e8 e6 0d 00 00       	call   800edd <close_all>
	sys_env_destroy(0);
  8000f7:	83 ec 0c             	sub    $0xc,%esp
  8000fa:	6a 00                	push   $0x0
  8000fc:	e8 a1 09 00 00       	call   800aa2 <sys_env_destroy>
}
  800101:	83 c4 10             	add    $0x10,%esp
  800104:	c9                   	leave  
  800105:	c3                   	ret    

00800106 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800106:	55                   	push   %ebp
  800107:	89 e5                	mov    %esp,%ebp
  800109:	53                   	push   %ebx
  80010a:	83 ec 04             	sub    $0x4,%esp
  80010d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800110:	8b 13                	mov    (%ebx),%edx
  800112:	8d 42 01             	lea    0x1(%edx),%eax
  800115:	89 03                	mov    %eax,(%ebx)
  800117:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80011a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80011e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800123:	75 1a                	jne    80013f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	68 ff 00 00 00       	push   $0xff
  80012d:	8d 43 08             	lea    0x8(%ebx),%eax
  800130:	50                   	push   %eax
  800131:	e8 2f 09 00 00       	call   800a65 <sys_cputs>
		b->idx = 0;
  800136:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80013c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80013f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800143:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800146:	c9                   	leave  
  800147:	c3                   	ret    

00800148 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800151:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800158:	00 00 00 
	b.cnt = 0;
  80015b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800162:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800165:	ff 75 0c             	pushl  0xc(%ebp)
  800168:	ff 75 08             	pushl  0x8(%ebp)
  80016b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800171:	50                   	push   %eax
  800172:	68 06 01 80 00       	push   $0x800106
  800177:	e8 54 01 00 00       	call   8002d0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80017c:	83 c4 08             	add    $0x8,%esp
  80017f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800185:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80018b:	50                   	push   %eax
  80018c:	e8 d4 08 00 00       	call   800a65 <sys_cputs>

	return b.cnt;
}
  800191:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a2:	50                   	push   %eax
  8001a3:	ff 75 08             	pushl  0x8(%ebp)
  8001a6:	e8 9d ff ff ff       	call   800148 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ab:	c9                   	leave  
  8001ac:	c3                   	ret    

008001ad <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	57                   	push   %edi
  8001b1:	56                   	push   %esi
  8001b2:	53                   	push   %ebx
  8001b3:	83 ec 1c             	sub    $0x1c,%esp
  8001b6:	89 c7                	mov    %eax,%edi
  8001b8:	89 d6                	mov    %edx,%esi
  8001ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8001bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001c3:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001c9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ce:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001d1:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001d4:	39 d3                	cmp    %edx,%ebx
  8001d6:	72 05                	jb     8001dd <printnum+0x30>
  8001d8:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001db:	77 45                	ja     800222 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001dd:	83 ec 0c             	sub    $0xc,%esp
  8001e0:	ff 75 18             	pushl  0x18(%ebp)
  8001e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8001e6:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001e9:	53                   	push   %ebx
  8001ea:	ff 75 10             	pushl  0x10(%ebp)
  8001ed:	83 ec 08             	sub    $0x8,%esp
  8001f0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f3:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f6:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f9:	ff 75 d8             	pushl  -0x28(%ebp)
  8001fc:	e8 8f 19 00 00       	call   801b90 <__udivdi3>
  800201:	83 c4 18             	add    $0x18,%esp
  800204:	52                   	push   %edx
  800205:	50                   	push   %eax
  800206:	89 f2                	mov    %esi,%edx
  800208:	89 f8                	mov    %edi,%eax
  80020a:	e8 9e ff ff ff       	call   8001ad <printnum>
  80020f:	83 c4 20             	add    $0x20,%esp
  800212:	eb 18                	jmp    80022c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800214:	83 ec 08             	sub    $0x8,%esp
  800217:	56                   	push   %esi
  800218:	ff 75 18             	pushl  0x18(%ebp)
  80021b:	ff d7                	call   *%edi
  80021d:	83 c4 10             	add    $0x10,%esp
  800220:	eb 03                	jmp    800225 <printnum+0x78>
  800222:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800225:	83 eb 01             	sub    $0x1,%ebx
  800228:	85 db                	test   %ebx,%ebx
  80022a:	7f e8                	jg     800214 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80022c:	83 ec 08             	sub    $0x8,%esp
  80022f:	56                   	push   %esi
  800230:	83 ec 04             	sub    $0x4,%esp
  800233:	ff 75 e4             	pushl  -0x1c(%ebp)
  800236:	ff 75 e0             	pushl  -0x20(%ebp)
  800239:	ff 75 dc             	pushl  -0x24(%ebp)
  80023c:	ff 75 d8             	pushl  -0x28(%ebp)
  80023f:	e8 7c 1a 00 00       	call   801cc0 <__umoddi3>
  800244:	83 c4 14             	add    $0x14,%esp
  800247:	0f be 80 4f 1e 80 00 	movsbl 0x801e4f(%eax),%eax
  80024e:	50                   	push   %eax
  80024f:	ff d7                	call   *%edi
}
  800251:	83 c4 10             	add    $0x10,%esp
  800254:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800257:	5b                   	pop    %ebx
  800258:	5e                   	pop    %esi
  800259:	5f                   	pop    %edi
  80025a:	5d                   	pop    %ebp
  80025b:	c3                   	ret    

0080025c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80025c:	55                   	push   %ebp
  80025d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80025f:	83 fa 01             	cmp    $0x1,%edx
  800262:	7e 0e                	jle    800272 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800264:	8b 10                	mov    (%eax),%edx
  800266:	8d 4a 08             	lea    0x8(%edx),%ecx
  800269:	89 08                	mov    %ecx,(%eax)
  80026b:	8b 02                	mov    (%edx),%eax
  80026d:	8b 52 04             	mov    0x4(%edx),%edx
  800270:	eb 22                	jmp    800294 <getuint+0x38>
	else if (lflag)
  800272:	85 d2                	test   %edx,%edx
  800274:	74 10                	je     800286 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800276:	8b 10                	mov    (%eax),%edx
  800278:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027b:	89 08                	mov    %ecx,(%eax)
  80027d:	8b 02                	mov    (%edx),%eax
  80027f:	ba 00 00 00 00       	mov    $0x0,%edx
  800284:	eb 0e                	jmp    800294 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800286:	8b 10                	mov    (%eax),%edx
  800288:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028b:	89 08                	mov    %ecx,(%eax)
  80028d:	8b 02                	mov    (%edx),%eax
  80028f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800294:	5d                   	pop    %ebp
  800295:	c3                   	ret    

00800296 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
  800299:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80029c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002a0:	8b 10                	mov    (%eax),%edx
  8002a2:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a5:	73 0a                	jae    8002b1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002a7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002aa:	89 08                	mov    %ecx,(%eax)
  8002ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8002af:	88 02                	mov    %al,(%edx)
}
  8002b1:	5d                   	pop    %ebp
  8002b2:	c3                   	ret    

008002b3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002bc:	50                   	push   %eax
  8002bd:	ff 75 10             	pushl  0x10(%ebp)
  8002c0:	ff 75 0c             	pushl  0xc(%ebp)
  8002c3:	ff 75 08             	pushl  0x8(%ebp)
  8002c6:	e8 05 00 00 00       	call   8002d0 <vprintfmt>
	va_end(ap);
}
  8002cb:	83 c4 10             	add    $0x10,%esp
  8002ce:	c9                   	leave  
  8002cf:	c3                   	ret    

008002d0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	57                   	push   %edi
  8002d4:	56                   	push   %esi
  8002d5:	53                   	push   %ebx
  8002d6:	83 ec 2c             	sub    $0x2c,%esp
  8002d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8002dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002df:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002e2:	eb 12                	jmp    8002f6 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002e4:	85 c0                	test   %eax,%eax
  8002e6:	0f 84 89 03 00 00    	je     800675 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002ec:	83 ec 08             	sub    $0x8,%esp
  8002ef:	53                   	push   %ebx
  8002f0:	50                   	push   %eax
  8002f1:	ff d6                	call   *%esi
  8002f3:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f6:	83 c7 01             	add    $0x1,%edi
  8002f9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002fd:	83 f8 25             	cmp    $0x25,%eax
  800300:	75 e2                	jne    8002e4 <vprintfmt+0x14>
  800302:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800306:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80030d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800314:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80031b:	ba 00 00 00 00       	mov    $0x0,%edx
  800320:	eb 07                	jmp    800329 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800322:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800325:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800329:	8d 47 01             	lea    0x1(%edi),%eax
  80032c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80032f:	0f b6 07             	movzbl (%edi),%eax
  800332:	0f b6 c8             	movzbl %al,%ecx
  800335:	83 e8 23             	sub    $0x23,%eax
  800338:	3c 55                	cmp    $0x55,%al
  80033a:	0f 87 1a 03 00 00    	ja     80065a <vprintfmt+0x38a>
  800340:	0f b6 c0             	movzbl %al,%eax
  800343:	ff 24 85 a0 1f 80 00 	jmp    *0x801fa0(,%eax,4)
  80034a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80034d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800351:	eb d6                	jmp    800329 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800353:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800356:	b8 00 00 00 00       	mov    $0x0,%eax
  80035b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80035e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800361:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800365:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800368:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80036b:	83 fa 09             	cmp    $0x9,%edx
  80036e:	77 39                	ja     8003a9 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800370:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800373:	eb e9                	jmp    80035e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800375:	8b 45 14             	mov    0x14(%ebp),%eax
  800378:	8d 48 04             	lea    0x4(%eax),%ecx
  80037b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80037e:	8b 00                	mov    (%eax),%eax
  800380:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800383:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800386:	eb 27                	jmp    8003af <vprintfmt+0xdf>
  800388:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80038b:	85 c0                	test   %eax,%eax
  80038d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800392:	0f 49 c8             	cmovns %eax,%ecx
  800395:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800398:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80039b:	eb 8c                	jmp    800329 <vprintfmt+0x59>
  80039d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003a0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003a7:	eb 80                	jmp    800329 <vprintfmt+0x59>
  8003a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003ac:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003af:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003b3:	0f 89 70 ff ff ff    	jns    800329 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003b9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003bc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003bf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003c6:	e9 5e ff ff ff       	jmp    800329 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003cb:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003d1:	e9 53 ff ff ff       	jmp    800329 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d9:	8d 50 04             	lea    0x4(%eax),%edx
  8003dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8003df:	83 ec 08             	sub    $0x8,%esp
  8003e2:	53                   	push   %ebx
  8003e3:	ff 30                	pushl  (%eax)
  8003e5:	ff d6                	call   *%esi
			break;
  8003e7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003ed:	e9 04 ff ff ff       	jmp    8002f6 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f5:	8d 50 04             	lea    0x4(%eax),%edx
  8003f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fb:	8b 00                	mov    (%eax),%eax
  8003fd:	99                   	cltd   
  8003fe:	31 d0                	xor    %edx,%eax
  800400:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800402:	83 f8 0f             	cmp    $0xf,%eax
  800405:	7f 0b                	jg     800412 <vprintfmt+0x142>
  800407:	8b 14 85 00 21 80 00 	mov    0x802100(,%eax,4),%edx
  80040e:	85 d2                	test   %edx,%edx
  800410:	75 18                	jne    80042a <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800412:	50                   	push   %eax
  800413:	68 67 1e 80 00       	push   $0x801e67
  800418:	53                   	push   %ebx
  800419:	56                   	push   %esi
  80041a:	e8 94 fe ff ff       	call   8002b3 <printfmt>
  80041f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800425:	e9 cc fe ff ff       	jmp    8002f6 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80042a:	52                   	push   %edx
  80042b:	68 31 22 80 00       	push   $0x802231
  800430:	53                   	push   %ebx
  800431:	56                   	push   %esi
  800432:	e8 7c fe ff ff       	call   8002b3 <printfmt>
  800437:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80043d:	e9 b4 fe ff ff       	jmp    8002f6 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800442:	8b 45 14             	mov    0x14(%ebp),%eax
  800445:	8d 50 04             	lea    0x4(%eax),%edx
  800448:	89 55 14             	mov    %edx,0x14(%ebp)
  80044b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80044d:	85 ff                	test   %edi,%edi
  80044f:	b8 60 1e 80 00       	mov    $0x801e60,%eax
  800454:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800457:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80045b:	0f 8e 94 00 00 00    	jle    8004f5 <vprintfmt+0x225>
  800461:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800465:	0f 84 98 00 00 00    	je     800503 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80046b:	83 ec 08             	sub    $0x8,%esp
  80046e:	ff 75 d0             	pushl  -0x30(%ebp)
  800471:	57                   	push   %edi
  800472:	e8 86 02 00 00       	call   8006fd <strnlen>
  800477:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80047a:	29 c1                	sub    %eax,%ecx
  80047c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80047f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800482:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800486:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800489:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80048c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048e:	eb 0f                	jmp    80049f <vprintfmt+0x1cf>
					putch(padc, putdat);
  800490:	83 ec 08             	sub    $0x8,%esp
  800493:	53                   	push   %ebx
  800494:	ff 75 e0             	pushl  -0x20(%ebp)
  800497:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800499:	83 ef 01             	sub    $0x1,%edi
  80049c:	83 c4 10             	add    $0x10,%esp
  80049f:	85 ff                	test   %edi,%edi
  8004a1:	7f ed                	jg     800490 <vprintfmt+0x1c0>
  8004a3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004a6:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004a9:	85 c9                	test   %ecx,%ecx
  8004ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b0:	0f 49 c1             	cmovns %ecx,%eax
  8004b3:	29 c1                	sub    %eax,%ecx
  8004b5:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004bb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004be:	89 cb                	mov    %ecx,%ebx
  8004c0:	eb 4d                	jmp    80050f <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004c2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004c6:	74 1b                	je     8004e3 <vprintfmt+0x213>
  8004c8:	0f be c0             	movsbl %al,%eax
  8004cb:	83 e8 20             	sub    $0x20,%eax
  8004ce:	83 f8 5e             	cmp    $0x5e,%eax
  8004d1:	76 10                	jbe    8004e3 <vprintfmt+0x213>
					putch('?', putdat);
  8004d3:	83 ec 08             	sub    $0x8,%esp
  8004d6:	ff 75 0c             	pushl  0xc(%ebp)
  8004d9:	6a 3f                	push   $0x3f
  8004db:	ff 55 08             	call   *0x8(%ebp)
  8004de:	83 c4 10             	add    $0x10,%esp
  8004e1:	eb 0d                	jmp    8004f0 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004e3:	83 ec 08             	sub    $0x8,%esp
  8004e6:	ff 75 0c             	pushl  0xc(%ebp)
  8004e9:	52                   	push   %edx
  8004ea:	ff 55 08             	call   *0x8(%ebp)
  8004ed:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f0:	83 eb 01             	sub    $0x1,%ebx
  8004f3:	eb 1a                	jmp    80050f <vprintfmt+0x23f>
  8004f5:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004fb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004fe:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800501:	eb 0c                	jmp    80050f <vprintfmt+0x23f>
  800503:	89 75 08             	mov    %esi,0x8(%ebp)
  800506:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800509:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80050c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80050f:	83 c7 01             	add    $0x1,%edi
  800512:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800516:	0f be d0             	movsbl %al,%edx
  800519:	85 d2                	test   %edx,%edx
  80051b:	74 23                	je     800540 <vprintfmt+0x270>
  80051d:	85 f6                	test   %esi,%esi
  80051f:	78 a1                	js     8004c2 <vprintfmt+0x1f2>
  800521:	83 ee 01             	sub    $0x1,%esi
  800524:	79 9c                	jns    8004c2 <vprintfmt+0x1f2>
  800526:	89 df                	mov    %ebx,%edi
  800528:	8b 75 08             	mov    0x8(%ebp),%esi
  80052b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80052e:	eb 18                	jmp    800548 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800530:	83 ec 08             	sub    $0x8,%esp
  800533:	53                   	push   %ebx
  800534:	6a 20                	push   $0x20
  800536:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800538:	83 ef 01             	sub    $0x1,%edi
  80053b:	83 c4 10             	add    $0x10,%esp
  80053e:	eb 08                	jmp    800548 <vprintfmt+0x278>
  800540:	89 df                	mov    %ebx,%edi
  800542:	8b 75 08             	mov    0x8(%ebp),%esi
  800545:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800548:	85 ff                	test   %edi,%edi
  80054a:	7f e4                	jg     800530 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80054f:	e9 a2 fd ff ff       	jmp    8002f6 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800554:	83 fa 01             	cmp    $0x1,%edx
  800557:	7e 16                	jle    80056f <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800559:	8b 45 14             	mov    0x14(%ebp),%eax
  80055c:	8d 50 08             	lea    0x8(%eax),%edx
  80055f:	89 55 14             	mov    %edx,0x14(%ebp)
  800562:	8b 50 04             	mov    0x4(%eax),%edx
  800565:	8b 00                	mov    (%eax),%eax
  800567:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80056d:	eb 32                	jmp    8005a1 <vprintfmt+0x2d1>
	else if (lflag)
  80056f:	85 d2                	test   %edx,%edx
  800571:	74 18                	je     80058b <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800573:	8b 45 14             	mov    0x14(%ebp),%eax
  800576:	8d 50 04             	lea    0x4(%eax),%edx
  800579:	89 55 14             	mov    %edx,0x14(%ebp)
  80057c:	8b 00                	mov    (%eax),%eax
  80057e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800581:	89 c1                	mov    %eax,%ecx
  800583:	c1 f9 1f             	sar    $0x1f,%ecx
  800586:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800589:	eb 16                	jmp    8005a1 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80058b:	8b 45 14             	mov    0x14(%ebp),%eax
  80058e:	8d 50 04             	lea    0x4(%eax),%edx
  800591:	89 55 14             	mov    %edx,0x14(%ebp)
  800594:	8b 00                	mov    (%eax),%eax
  800596:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800599:	89 c1                	mov    %eax,%ecx
  80059b:	c1 f9 1f             	sar    $0x1f,%ecx
  80059e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005a1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005a4:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005ac:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005b0:	79 74                	jns    800626 <vprintfmt+0x356>
				putch('-', putdat);
  8005b2:	83 ec 08             	sub    $0x8,%esp
  8005b5:	53                   	push   %ebx
  8005b6:	6a 2d                	push   $0x2d
  8005b8:	ff d6                	call   *%esi
				num = -(long long) num;
  8005ba:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005bd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005c0:	f7 d8                	neg    %eax
  8005c2:	83 d2 00             	adc    $0x0,%edx
  8005c5:	f7 da                	neg    %edx
  8005c7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005ca:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005cf:	eb 55                	jmp    800626 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005d1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d4:	e8 83 fc ff ff       	call   80025c <getuint>
			base = 10;
  8005d9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005de:	eb 46                	jmp    800626 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005e0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e3:	e8 74 fc ff ff       	call   80025c <getuint>
			base = 8;
  8005e8:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005ed:	eb 37                	jmp    800626 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005ef:	83 ec 08             	sub    $0x8,%esp
  8005f2:	53                   	push   %ebx
  8005f3:	6a 30                	push   $0x30
  8005f5:	ff d6                	call   *%esi
			putch('x', putdat);
  8005f7:	83 c4 08             	add    $0x8,%esp
  8005fa:	53                   	push   %ebx
  8005fb:	6a 78                	push   $0x78
  8005fd:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800602:	8d 50 04             	lea    0x4(%eax),%edx
  800605:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800608:	8b 00                	mov    (%eax),%eax
  80060a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80060f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800612:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800617:	eb 0d                	jmp    800626 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800619:	8d 45 14             	lea    0x14(%ebp),%eax
  80061c:	e8 3b fc ff ff       	call   80025c <getuint>
			base = 16;
  800621:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800626:	83 ec 0c             	sub    $0xc,%esp
  800629:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80062d:	57                   	push   %edi
  80062e:	ff 75 e0             	pushl  -0x20(%ebp)
  800631:	51                   	push   %ecx
  800632:	52                   	push   %edx
  800633:	50                   	push   %eax
  800634:	89 da                	mov    %ebx,%edx
  800636:	89 f0                	mov    %esi,%eax
  800638:	e8 70 fb ff ff       	call   8001ad <printnum>
			break;
  80063d:	83 c4 20             	add    $0x20,%esp
  800640:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800643:	e9 ae fc ff ff       	jmp    8002f6 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	53                   	push   %ebx
  80064c:	51                   	push   %ecx
  80064d:	ff d6                	call   *%esi
			break;
  80064f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800652:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800655:	e9 9c fc ff ff       	jmp    8002f6 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80065a:	83 ec 08             	sub    $0x8,%esp
  80065d:	53                   	push   %ebx
  80065e:	6a 25                	push   $0x25
  800660:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800662:	83 c4 10             	add    $0x10,%esp
  800665:	eb 03                	jmp    80066a <vprintfmt+0x39a>
  800667:	83 ef 01             	sub    $0x1,%edi
  80066a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80066e:	75 f7                	jne    800667 <vprintfmt+0x397>
  800670:	e9 81 fc ff ff       	jmp    8002f6 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800675:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800678:	5b                   	pop    %ebx
  800679:	5e                   	pop    %esi
  80067a:	5f                   	pop    %edi
  80067b:	5d                   	pop    %ebp
  80067c:	c3                   	ret    

0080067d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80067d:	55                   	push   %ebp
  80067e:	89 e5                	mov    %esp,%ebp
  800680:	83 ec 18             	sub    $0x18,%esp
  800683:	8b 45 08             	mov    0x8(%ebp),%eax
  800686:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800689:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80068c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800690:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800693:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80069a:	85 c0                	test   %eax,%eax
  80069c:	74 26                	je     8006c4 <vsnprintf+0x47>
  80069e:	85 d2                	test   %edx,%edx
  8006a0:	7e 22                	jle    8006c4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006a2:	ff 75 14             	pushl  0x14(%ebp)
  8006a5:	ff 75 10             	pushl  0x10(%ebp)
  8006a8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006ab:	50                   	push   %eax
  8006ac:	68 96 02 80 00       	push   $0x800296
  8006b1:	e8 1a fc ff ff       	call   8002d0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006b9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006bf:	83 c4 10             	add    $0x10,%esp
  8006c2:	eb 05                	jmp    8006c9 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006c9:	c9                   	leave  
  8006ca:	c3                   	ret    

008006cb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006cb:	55                   	push   %ebp
  8006cc:	89 e5                	mov    %esp,%ebp
  8006ce:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006d1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006d4:	50                   	push   %eax
  8006d5:	ff 75 10             	pushl  0x10(%ebp)
  8006d8:	ff 75 0c             	pushl  0xc(%ebp)
  8006db:	ff 75 08             	pushl  0x8(%ebp)
  8006de:	e8 9a ff ff ff       	call   80067d <vsnprintf>
	va_end(ap);

	return rc;
}
  8006e3:	c9                   	leave  
  8006e4:	c3                   	ret    

008006e5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e5:	55                   	push   %ebp
  8006e6:	89 e5                	mov    %esp,%ebp
  8006e8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f0:	eb 03                	jmp    8006f5 <strlen+0x10>
		n++;
  8006f2:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006f9:	75 f7                	jne    8006f2 <strlen+0xd>
		n++;
	return n;
}
  8006fb:	5d                   	pop    %ebp
  8006fc:	c3                   	ret    

008006fd <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006fd:	55                   	push   %ebp
  8006fe:	89 e5                	mov    %esp,%ebp
  800700:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800703:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800706:	ba 00 00 00 00       	mov    $0x0,%edx
  80070b:	eb 03                	jmp    800710 <strnlen+0x13>
		n++;
  80070d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800710:	39 c2                	cmp    %eax,%edx
  800712:	74 08                	je     80071c <strnlen+0x1f>
  800714:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800718:	75 f3                	jne    80070d <strnlen+0x10>
  80071a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80071c:	5d                   	pop    %ebp
  80071d:	c3                   	ret    

0080071e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80071e:	55                   	push   %ebp
  80071f:	89 e5                	mov    %esp,%ebp
  800721:	53                   	push   %ebx
  800722:	8b 45 08             	mov    0x8(%ebp),%eax
  800725:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800728:	89 c2                	mov    %eax,%edx
  80072a:	83 c2 01             	add    $0x1,%edx
  80072d:	83 c1 01             	add    $0x1,%ecx
  800730:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800734:	88 5a ff             	mov    %bl,-0x1(%edx)
  800737:	84 db                	test   %bl,%bl
  800739:	75 ef                	jne    80072a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80073b:	5b                   	pop    %ebx
  80073c:	5d                   	pop    %ebp
  80073d:	c3                   	ret    

0080073e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	53                   	push   %ebx
  800742:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800745:	53                   	push   %ebx
  800746:	e8 9a ff ff ff       	call   8006e5 <strlen>
  80074b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80074e:	ff 75 0c             	pushl  0xc(%ebp)
  800751:	01 d8                	add    %ebx,%eax
  800753:	50                   	push   %eax
  800754:	e8 c5 ff ff ff       	call   80071e <strcpy>
	return dst;
}
  800759:	89 d8                	mov    %ebx,%eax
  80075b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80075e:	c9                   	leave  
  80075f:	c3                   	ret    

00800760 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	56                   	push   %esi
  800764:	53                   	push   %ebx
  800765:	8b 75 08             	mov    0x8(%ebp),%esi
  800768:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80076b:	89 f3                	mov    %esi,%ebx
  80076d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800770:	89 f2                	mov    %esi,%edx
  800772:	eb 0f                	jmp    800783 <strncpy+0x23>
		*dst++ = *src;
  800774:	83 c2 01             	add    $0x1,%edx
  800777:	0f b6 01             	movzbl (%ecx),%eax
  80077a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80077d:	80 39 01             	cmpb   $0x1,(%ecx)
  800780:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800783:	39 da                	cmp    %ebx,%edx
  800785:	75 ed                	jne    800774 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800787:	89 f0                	mov    %esi,%eax
  800789:	5b                   	pop    %ebx
  80078a:	5e                   	pop    %esi
  80078b:	5d                   	pop    %ebp
  80078c:	c3                   	ret    

0080078d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80078d:	55                   	push   %ebp
  80078e:	89 e5                	mov    %esp,%ebp
  800790:	56                   	push   %esi
  800791:	53                   	push   %ebx
  800792:	8b 75 08             	mov    0x8(%ebp),%esi
  800795:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800798:	8b 55 10             	mov    0x10(%ebp),%edx
  80079b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80079d:	85 d2                	test   %edx,%edx
  80079f:	74 21                	je     8007c2 <strlcpy+0x35>
  8007a1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007a5:	89 f2                	mov    %esi,%edx
  8007a7:	eb 09                	jmp    8007b2 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007a9:	83 c2 01             	add    $0x1,%edx
  8007ac:	83 c1 01             	add    $0x1,%ecx
  8007af:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007b2:	39 c2                	cmp    %eax,%edx
  8007b4:	74 09                	je     8007bf <strlcpy+0x32>
  8007b6:	0f b6 19             	movzbl (%ecx),%ebx
  8007b9:	84 db                	test   %bl,%bl
  8007bb:	75 ec                	jne    8007a9 <strlcpy+0x1c>
  8007bd:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007bf:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007c2:	29 f0                	sub    %esi,%eax
}
  8007c4:	5b                   	pop    %ebx
  8007c5:	5e                   	pop    %esi
  8007c6:	5d                   	pop    %ebp
  8007c7:	c3                   	ret    

008007c8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ce:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007d1:	eb 06                	jmp    8007d9 <strcmp+0x11>
		p++, q++;
  8007d3:	83 c1 01             	add    $0x1,%ecx
  8007d6:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007d9:	0f b6 01             	movzbl (%ecx),%eax
  8007dc:	84 c0                	test   %al,%al
  8007de:	74 04                	je     8007e4 <strcmp+0x1c>
  8007e0:	3a 02                	cmp    (%edx),%al
  8007e2:	74 ef                	je     8007d3 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007e4:	0f b6 c0             	movzbl %al,%eax
  8007e7:	0f b6 12             	movzbl (%edx),%edx
  8007ea:	29 d0                	sub    %edx,%eax
}
  8007ec:	5d                   	pop    %ebp
  8007ed:	c3                   	ret    

008007ee <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	53                   	push   %ebx
  8007f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f8:	89 c3                	mov    %eax,%ebx
  8007fa:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007fd:	eb 06                	jmp    800805 <strncmp+0x17>
		n--, p++, q++;
  8007ff:	83 c0 01             	add    $0x1,%eax
  800802:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800805:	39 d8                	cmp    %ebx,%eax
  800807:	74 15                	je     80081e <strncmp+0x30>
  800809:	0f b6 08             	movzbl (%eax),%ecx
  80080c:	84 c9                	test   %cl,%cl
  80080e:	74 04                	je     800814 <strncmp+0x26>
  800810:	3a 0a                	cmp    (%edx),%cl
  800812:	74 eb                	je     8007ff <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800814:	0f b6 00             	movzbl (%eax),%eax
  800817:	0f b6 12             	movzbl (%edx),%edx
  80081a:	29 d0                	sub    %edx,%eax
  80081c:	eb 05                	jmp    800823 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80081e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800823:	5b                   	pop    %ebx
  800824:	5d                   	pop    %ebp
  800825:	c3                   	ret    

00800826 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	8b 45 08             	mov    0x8(%ebp),%eax
  80082c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800830:	eb 07                	jmp    800839 <strchr+0x13>
		if (*s == c)
  800832:	38 ca                	cmp    %cl,%dl
  800834:	74 0f                	je     800845 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800836:	83 c0 01             	add    $0x1,%eax
  800839:	0f b6 10             	movzbl (%eax),%edx
  80083c:	84 d2                	test   %dl,%dl
  80083e:	75 f2                	jne    800832 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800840:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800845:	5d                   	pop    %ebp
  800846:	c3                   	ret    

00800847 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	8b 45 08             	mov    0x8(%ebp),%eax
  80084d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800851:	eb 03                	jmp    800856 <strfind+0xf>
  800853:	83 c0 01             	add    $0x1,%eax
  800856:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800859:	38 ca                	cmp    %cl,%dl
  80085b:	74 04                	je     800861 <strfind+0x1a>
  80085d:	84 d2                	test   %dl,%dl
  80085f:	75 f2                	jne    800853 <strfind+0xc>
			break;
	return (char *) s;
}
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	57                   	push   %edi
  800867:	56                   	push   %esi
  800868:	53                   	push   %ebx
  800869:	8b 7d 08             	mov    0x8(%ebp),%edi
  80086c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80086f:	85 c9                	test   %ecx,%ecx
  800871:	74 36                	je     8008a9 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800873:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800879:	75 28                	jne    8008a3 <memset+0x40>
  80087b:	f6 c1 03             	test   $0x3,%cl
  80087e:	75 23                	jne    8008a3 <memset+0x40>
		c &= 0xFF;
  800880:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800884:	89 d3                	mov    %edx,%ebx
  800886:	c1 e3 08             	shl    $0x8,%ebx
  800889:	89 d6                	mov    %edx,%esi
  80088b:	c1 e6 18             	shl    $0x18,%esi
  80088e:	89 d0                	mov    %edx,%eax
  800890:	c1 e0 10             	shl    $0x10,%eax
  800893:	09 f0                	or     %esi,%eax
  800895:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800897:	89 d8                	mov    %ebx,%eax
  800899:	09 d0                	or     %edx,%eax
  80089b:	c1 e9 02             	shr    $0x2,%ecx
  80089e:	fc                   	cld    
  80089f:	f3 ab                	rep stos %eax,%es:(%edi)
  8008a1:	eb 06                	jmp    8008a9 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a6:	fc                   	cld    
  8008a7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008a9:	89 f8                	mov    %edi,%eax
  8008ab:	5b                   	pop    %ebx
  8008ac:	5e                   	pop    %esi
  8008ad:	5f                   	pop    %edi
  8008ae:	5d                   	pop    %ebp
  8008af:	c3                   	ret    

008008b0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	57                   	push   %edi
  8008b4:	56                   	push   %esi
  8008b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008bb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008be:	39 c6                	cmp    %eax,%esi
  8008c0:	73 35                	jae    8008f7 <memmove+0x47>
  8008c2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008c5:	39 d0                	cmp    %edx,%eax
  8008c7:	73 2e                	jae    8008f7 <memmove+0x47>
		s += n;
		d += n;
  8008c9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008cc:	89 d6                	mov    %edx,%esi
  8008ce:	09 fe                	or     %edi,%esi
  8008d0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008d6:	75 13                	jne    8008eb <memmove+0x3b>
  8008d8:	f6 c1 03             	test   $0x3,%cl
  8008db:	75 0e                	jne    8008eb <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008dd:	83 ef 04             	sub    $0x4,%edi
  8008e0:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008e3:	c1 e9 02             	shr    $0x2,%ecx
  8008e6:	fd                   	std    
  8008e7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e9:	eb 09                	jmp    8008f4 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008eb:	83 ef 01             	sub    $0x1,%edi
  8008ee:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008f1:	fd                   	std    
  8008f2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008f4:	fc                   	cld    
  8008f5:	eb 1d                	jmp    800914 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f7:	89 f2                	mov    %esi,%edx
  8008f9:	09 c2                	or     %eax,%edx
  8008fb:	f6 c2 03             	test   $0x3,%dl
  8008fe:	75 0f                	jne    80090f <memmove+0x5f>
  800900:	f6 c1 03             	test   $0x3,%cl
  800903:	75 0a                	jne    80090f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800905:	c1 e9 02             	shr    $0x2,%ecx
  800908:	89 c7                	mov    %eax,%edi
  80090a:	fc                   	cld    
  80090b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090d:	eb 05                	jmp    800914 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80090f:	89 c7                	mov    %eax,%edi
  800911:	fc                   	cld    
  800912:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800914:	5e                   	pop    %esi
  800915:	5f                   	pop    %edi
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80091b:	ff 75 10             	pushl  0x10(%ebp)
  80091e:	ff 75 0c             	pushl  0xc(%ebp)
  800921:	ff 75 08             	pushl  0x8(%ebp)
  800924:	e8 87 ff ff ff       	call   8008b0 <memmove>
}
  800929:	c9                   	leave  
  80092a:	c3                   	ret    

0080092b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	56                   	push   %esi
  80092f:	53                   	push   %ebx
  800930:	8b 45 08             	mov    0x8(%ebp),%eax
  800933:	8b 55 0c             	mov    0xc(%ebp),%edx
  800936:	89 c6                	mov    %eax,%esi
  800938:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80093b:	eb 1a                	jmp    800957 <memcmp+0x2c>
		if (*s1 != *s2)
  80093d:	0f b6 08             	movzbl (%eax),%ecx
  800940:	0f b6 1a             	movzbl (%edx),%ebx
  800943:	38 d9                	cmp    %bl,%cl
  800945:	74 0a                	je     800951 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800947:	0f b6 c1             	movzbl %cl,%eax
  80094a:	0f b6 db             	movzbl %bl,%ebx
  80094d:	29 d8                	sub    %ebx,%eax
  80094f:	eb 0f                	jmp    800960 <memcmp+0x35>
		s1++, s2++;
  800951:	83 c0 01             	add    $0x1,%eax
  800954:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800957:	39 f0                	cmp    %esi,%eax
  800959:	75 e2                	jne    80093d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80095b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800960:	5b                   	pop    %ebx
  800961:	5e                   	pop    %esi
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	53                   	push   %ebx
  800968:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80096b:	89 c1                	mov    %eax,%ecx
  80096d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800970:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800974:	eb 0a                	jmp    800980 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800976:	0f b6 10             	movzbl (%eax),%edx
  800979:	39 da                	cmp    %ebx,%edx
  80097b:	74 07                	je     800984 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80097d:	83 c0 01             	add    $0x1,%eax
  800980:	39 c8                	cmp    %ecx,%eax
  800982:	72 f2                	jb     800976 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800984:	5b                   	pop    %ebx
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	57                   	push   %edi
  80098b:	56                   	push   %esi
  80098c:	53                   	push   %ebx
  80098d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800990:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800993:	eb 03                	jmp    800998 <strtol+0x11>
		s++;
  800995:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800998:	0f b6 01             	movzbl (%ecx),%eax
  80099b:	3c 20                	cmp    $0x20,%al
  80099d:	74 f6                	je     800995 <strtol+0xe>
  80099f:	3c 09                	cmp    $0x9,%al
  8009a1:	74 f2                	je     800995 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009a3:	3c 2b                	cmp    $0x2b,%al
  8009a5:	75 0a                	jne    8009b1 <strtol+0x2a>
		s++;
  8009a7:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009aa:	bf 00 00 00 00       	mov    $0x0,%edi
  8009af:	eb 11                	jmp    8009c2 <strtol+0x3b>
  8009b1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009b6:	3c 2d                	cmp    $0x2d,%al
  8009b8:	75 08                	jne    8009c2 <strtol+0x3b>
		s++, neg = 1;
  8009ba:	83 c1 01             	add    $0x1,%ecx
  8009bd:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009c2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009c8:	75 15                	jne    8009df <strtol+0x58>
  8009ca:	80 39 30             	cmpb   $0x30,(%ecx)
  8009cd:	75 10                	jne    8009df <strtol+0x58>
  8009cf:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009d3:	75 7c                	jne    800a51 <strtol+0xca>
		s += 2, base = 16;
  8009d5:	83 c1 02             	add    $0x2,%ecx
  8009d8:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009dd:	eb 16                	jmp    8009f5 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009df:	85 db                	test   %ebx,%ebx
  8009e1:	75 12                	jne    8009f5 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009e3:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009e8:	80 39 30             	cmpb   $0x30,(%ecx)
  8009eb:	75 08                	jne    8009f5 <strtol+0x6e>
		s++, base = 8;
  8009ed:	83 c1 01             	add    $0x1,%ecx
  8009f0:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fa:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009fd:	0f b6 11             	movzbl (%ecx),%edx
  800a00:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a03:	89 f3                	mov    %esi,%ebx
  800a05:	80 fb 09             	cmp    $0x9,%bl
  800a08:	77 08                	ja     800a12 <strtol+0x8b>
			dig = *s - '0';
  800a0a:	0f be d2             	movsbl %dl,%edx
  800a0d:	83 ea 30             	sub    $0x30,%edx
  800a10:	eb 22                	jmp    800a34 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a12:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a15:	89 f3                	mov    %esi,%ebx
  800a17:	80 fb 19             	cmp    $0x19,%bl
  800a1a:	77 08                	ja     800a24 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a1c:	0f be d2             	movsbl %dl,%edx
  800a1f:	83 ea 57             	sub    $0x57,%edx
  800a22:	eb 10                	jmp    800a34 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a24:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a27:	89 f3                	mov    %esi,%ebx
  800a29:	80 fb 19             	cmp    $0x19,%bl
  800a2c:	77 16                	ja     800a44 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a2e:	0f be d2             	movsbl %dl,%edx
  800a31:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a34:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a37:	7d 0b                	jge    800a44 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a39:	83 c1 01             	add    $0x1,%ecx
  800a3c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a40:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a42:	eb b9                	jmp    8009fd <strtol+0x76>

	if (endptr)
  800a44:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a48:	74 0d                	je     800a57 <strtol+0xd0>
		*endptr = (char *) s;
  800a4a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a4d:	89 0e                	mov    %ecx,(%esi)
  800a4f:	eb 06                	jmp    800a57 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a51:	85 db                	test   %ebx,%ebx
  800a53:	74 98                	je     8009ed <strtol+0x66>
  800a55:	eb 9e                	jmp    8009f5 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a57:	89 c2                	mov    %eax,%edx
  800a59:	f7 da                	neg    %edx
  800a5b:	85 ff                	test   %edi,%edi
  800a5d:	0f 45 c2             	cmovne %edx,%eax
}
  800a60:	5b                   	pop    %ebx
  800a61:	5e                   	pop    %esi
  800a62:	5f                   	pop    %edi
  800a63:	5d                   	pop    %ebp
  800a64:	c3                   	ret    

00800a65 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	57                   	push   %edi
  800a69:	56                   	push   %esi
  800a6a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a73:	8b 55 08             	mov    0x8(%ebp),%edx
  800a76:	89 c3                	mov    %eax,%ebx
  800a78:	89 c7                	mov    %eax,%edi
  800a7a:	89 c6                	mov    %eax,%esi
  800a7c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a7e:	5b                   	pop    %ebx
  800a7f:	5e                   	pop    %esi
  800a80:	5f                   	pop    %edi
  800a81:	5d                   	pop    %ebp
  800a82:	c3                   	ret    

00800a83 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	57                   	push   %edi
  800a87:	56                   	push   %esi
  800a88:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a89:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8e:	b8 01 00 00 00       	mov    $0x1,%eax
  800a93:	89 d1                	mov    %edx,%ecx
  800a95:	89 d3                	mov    %edx,%ebx
  800a97:	89 d7                	mov    %edx,%edi
  800a99:	89 d6                	mov    %edx,%esi
  800a9b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a9d:	5b                   	pop    %ebx
  800a9e:	5e                   	pop    %esi
  800a9f:	5f                   	pop    %edi
  800aa0:	5d                   	pop    %ebp
  800aa1:	c3                   	ret    

00800aa2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	57                   	push   %edi
  800aa6:	56                   	push   %esi
  800aa7:	53                   	push   %ebx
  800aa8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aab:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab0:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab8:	89 cb                	mov    %ecx,%ebx
  800aba:	89 cf                	mov    %ecx,%edi
  800abc:	89 ce                	mov    %ecx,%esi
  800abe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ac0:	85 c0                	test   %eax,%eax
  800ac2:	7e 17                	jle    800adb <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ac4:	83 ec 0c             	sub    $0xc,%esp
  800ac7:	50                   	push   %eax
  800ac8:	6a 03                	push   $0x3
  800aca:	68 5f 21 80 00       	push   $0x80215f
  800acf:	6a 23                	push   $0x23
  800ad1:	68 7c 21 80 00       	push   $0x80217c
  800ad6:	e8 21 0f 00 00       	call   8019fc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800adb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ade:	5b                   	pop    %ebx
  800adf:	5e                   	pop    %esi
  800ae0:	5f                   	pop    %edi
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	57                   	push   %edi
  800ae7:	56                   	push   %esi
  800ae8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae9:	ba 00 00 00 00       	mov    $0x0,%edx
  800aee:	b8 02 00 00 00       	mov    $0x2,%eax
  800af3:	89 d1                	mov    %edx,%ecx
  800af5:	89 d3                	mov    %edx,%ebx
  800af7:	89 d7                	mov    %edx,%edi
  800af9:	89 d6                	mov    %edx,%esi
  800afb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800afd:	5b                   	pop    %ebx
  800afe:	5e                   	pop    %esi
  800aff:	5f                   	pop    %edi
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <sys_yield>:

void
sys_yield(void)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b08:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b12:	89 d1                	mov    %edx,%ecx
  800b14:	89 d3                	mov    %edx,%ebx
  800b16:	89 d7                	mov    %edx,%edi
  800b18:	89 d6                	mov    %edx,%esi
  800b1a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b1c:	5b                   	pop    %ebx
  800b1d:	5e                   	pop    %esi
  800b1e:	5f                   	pop    %edi
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	57                   	push   %edi
  800b25:	56                   	push   %esi
  800b26:	53                   	push   %ebx
  800b27:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2a:	be 00 00 00 00       	mov    $0x0,%esi
  800b2f:	b8 04 00 00 00       	mov    $0x4,%eax
  800b34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b37:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b3d:	89 f7                	mov    %esi,%edi
  800b3f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b41:	85 c0                	test   %eax,%eax
  800b43:	7e 17                	jle    800b5c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b45:	83 ec 0c             	sub    $0xc,%esp
  800b48:	50                   	push   %eax
  800b49:	6a 04                	push   $0x4
  800b4b:	68 5f 21 80 00       	push   $0x80215f
  800b50:	6a 23                	push   $0x23
  800b52:	68 7c 21 80 00       	push   $0x80217c
  800b57:	e8 a0 0e 00 00       	call   8019fc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5f:	5b                   	pop    %ebx
  800b60:	5e                   	pop    %esi
  800b61:	5f                   	pop    %edi
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    

00800b64 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	57                   	push   %edi
  800b68:	56                   	push   %esi
  800b69:	53                   	push   %ebx
  800b6a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6d:	b8 05 00 00 00       	mov    $0x5,%eax
  800b72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b75:	8b 55 08             	mov    0x8(%ebp),%edx
  800b78:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b7b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b7e:	8b 75 18             	mov    0x18(%ebp),%esi
  800b81:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b83:	85 c0                	test   %eax,%eax
  800b85:	7e 17                	jle    800b9e <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b87:	83 ec 0c             	sub    $0xc,%esp
  800b8a:	50                   	push   %eax
  800b8b:	6a 05                	push   $0x5
  800b8d:	68 5f 21 80 00       	push   $0x80215f
  800b92:	6a 23                	push   $0x23
  800b94:	68 7c 21 80 00       	push   $0x80217c
  800b99:	e8 5e 0e 00 00       	call   8019fc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba1:	5b                   	pop    %ebx
  800ba2:	5e                   	pop    %esi
  800ba3:	5f                   	pop    %edi
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	57                   	push   %edi
  800baa:	56                   	push   %esi
  800bab:	53                   	push   %ebx
  800bac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800baf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb4:	b8 06 00 00 00       	mov    $0x6,%eax
  800bb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbf:	89 df                	mov    %ebx,%edi
  800bc1:	89 de                	mov    %ebx,%esi
  800bc3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc5:	85 c0                	test   %eax,%eax
  800bc7:	7e 17                	jle    800be0 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc9:	83 ec 0c             	sub    $0xc,%esp
  800bcc:	50                   	push   %eax
  800bcd:	6a 06                	push   $0x6
  800bcf:	68 5f 21 80 00       	push   $0x80215f
  800bd4:	6a 23                	push   $0x23
  800bd6:	68 7c 21 80 00       	push   $0x80217c
  800bdb:	e8 1c 0e 00 00       	call   8019fc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800be0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be3:	5b                   	pop    %ebx
  800be4:	5e                   	pop    %esi
  800be5:	5f                   	pop    %edi
  800be6:	5d                   	pop    %ebp
  800be7:	c3                   	ret    

00800be8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	57                   	push   %edi
  800bec:	56                   	push   %esi
  800bed:	53                   	push   %ebx
  800bee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf6:	b8 08 00 00 00       	mov    $0x8,%eax
  800bfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800c01:	89 df                	mov    %ebx,%edi
  800c03:	89 de                	mov    %ebx,%esi
  800c05:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c07:	85 c0                	test   %eax,%eax
  800c09:	7e 17                	jle    800c22 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0b:	83 ec 0c             	sub    $0xc,%esp
  800c0e:	50                   	push   %eax
  800c0f:	6a 08                	push   $0x8
  800c11:	68 5f 21 80 00       	push   $0x80215f
  800c16:	6a 23                	push   $0x23
  800c18:	68 7c 21 80 00       	push   $0x80217c
  800c1d:	e8 da 0d 00 00       	call   8019fc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c25:	5b                   	pop    %ebx
  800c26:	5e                   	pop    %esi
  800c27:	5f                   	pop    %edi
  800c28:	5d                   	pop    %ebp
  800c29:	c3                   	ret    

00800c2a <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	57                   	push   %edi
  800c2e:	56                   	push   %esi
  800c2f:	53                   	push   %ebx
  800c30:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c33:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c38:	b8 09 00 00 00       	mov    $0x9,%eax
  800c3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c40:	8b 55 08             	mov    0x8(%ebp),%edx
  800c43:	89 df                	mov    %ebx,%edi
  800c45:	89 de                	mov    %ebx,%esi
  800c47:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c49:	85 c0                	test   %eax,%eax
  800c4b:	7e 17                	jle    800c64 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4d:	83 ec 0c             	sub    $0xc,%esp
  800c50:	50                   	push   %eax
  800c51:	6a 09                	push   $0x9
  800c53:	68 5f 21 80 00       	push   $0x80215f
  800c58:	6a 23                	push   $0x23
  800c5a:	68 7c 21 80 00       	push   $0x80217c
  800c5f:	e8 98 0d 00 00       	call   8019fc <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c67:	5b                   	pop    %ebx
  800c68:	5e                   	pop    %esi
  800c69:	5f                   	pop    %edi
  800c6a:	5d                   	pop    %ebp
  800c6b:	c3                   	ret    

00800c6c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	57                   	push   %edi
  800c70:	56                   	push   %esi
  800c71:	53                   	push   %ebx
  800c72:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c75:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c82:	8b 55 08             	mov    0x8(%ebp),%edx
  800c85:	89 df                	mov    %ebx,%edi
  800c87:	89 de                	mov    %ebx,%esi
  800c89:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c8b:	85 c0                	test   %eax,%eax
  800c8d:	7e 17                	jle    800ca6 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8f:	83 ec 0c             	sub    $0xc,%esp
  800c92:	50                   	push   %eax
  800c93:	6a 0a                	push   $0xa
  800c95:	68 5f 21 80 00       	push   $0x80215f
  800c9a:	6a 23                	push   $0x23
  800c9c:	68 7c 21 80 00       	push   $0x80217c
  800ca1:	e8 56 0d 00 00       	call   8019fc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ca6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca9:	5b                   	pop    %ebx
  800caa:	5e                   	pop    %esi
  800cab:	5f                   	pop    %edi
  800cac:	5d                   	pop    %ebp
  800cad:	c3                   	ret    

00800cae <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cae:	55                   	push   %ebp
  800caf:	89 e5                	mov    %esp,%ebp
  800cb1:	57                   	push   %edi
  800cb2:	56                   	push   %esi
  800cb3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb4:	be 00 00 00 00       	mov    $0x0,%esi
  800cb9:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cca:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ccc:	5b                   	pop    %ebx
  800ccd:	5e                   	pop    %esi
  800cce:	5f                   	pop    %edi
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    

00800cd1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	57                   	push   %edi
  800cd5:	56                   	push   %esi
  800cd6:	53                   	push   %ebx
  800cd7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cda:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cdf:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ce4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce7:	89 cb                	mov    %ecx,%ebx
  800ce9:	89 cf                	mov    %ecx,%edi
  800ceb:	89 ce                	mov    %ecx,%esi
  800ced:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cef:	85 c0                	test   %eax,%eax
  800cf1:	7e 17                	jle    800d0a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf3:	83 ec 0c             	sub    $0xc,%esp
  800cf6:	50                   	push   %eax
  800cf7:	6a 0d                	push   $0xd
  800cf9:	68 5f 21 80 00       	push   $0x80215f
  800cfe:	6a 23                	push   $0x23
  800d00:	68 7c 21 80 00       	push   $0x80217c
  800d05:	e8 f2 0c 00 00       	call   8019fc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0d:	5b                   	pop    %ebx
  800d0e:	5e                   	pop    %esi
  800d0f:	5f                   	pop    %edi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    

00800d12 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d15:	8b 45 08             	mov    0x8(%ebp),%eax
  800d18:	05 00 00 00 30       	add    $0x30000000,%eax
  800d1d:	c1 e8 0c             	shr    $0xc,%eax
}
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    

00800d22 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d25:	8b 45 08             	mov    0x8(%ebp),%eax
  800d28:	05 00 00 00 30       	add    $0x30000000,%eax
  800d2d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d32:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    

00800d39 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d3f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d44:	89 c2                	mov    %eax,%edx
  800d46:	c1 ea 16             	shr    $0x16,%edx
  800d49:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d50:	f6 c2 01             	test   $0x1,%dl
  800d53:	74 11                	je     800d66 <fd_alloc+0x2d>
  800d55:	89 c2                	mov    %eax,%edx
  800d57:	c1 ea 0c             	shr    $0xc,%edx
  800d5a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d61:	f6 c2 01             	test   $0x1,%dl
  800d64:	75 09                	jne    800d6f <fd_alloc+0x36>
			*fd_store = fd;
  800d66:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d68:	b8 00 00 00 00       	mov    $0x0,%eax
  800d6d:	eb 17                	jmp    800d86 <fd_alloc+0x4d>
  800d6f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d74:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d79:	75 c9                	jne    800d44 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d7b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d81:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d8e:	83 f8 1f             	cmp    $0x1f,%eax
  800d91:	77 36                	ja     800dc9 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d93:	c1 e0 0c             	shl    $0xc,%eax
  800d96:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d9b:	89 c2                	mov    %eax,%edx
  800d9d:	c1 ea 16             	shr    $0x16,%edx
  800da0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800da7:	f6 c2 01             	test   $0x1,%dl
  800daa:	74 24                	je     800dd0 <fd_lookup+0x48>
  800dac:	89 c2                	mov    %eax,%edx
  800dae:	c1 ea 0c             	shr    $0xc,%edx
  800db1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800db8:	f6 c2 01             	test   $0x1,%dl
  800dbb:	74 1a                	je     800dd7 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800dbd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dc0:	89 02                	mov    %eax,(%edx)
	return 0;
  800dc2:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc7:	eb 13                	jmp    800ddc <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dc9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dce:	eb 0c                	jmp    800ddc <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dd0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dd5:	eb 05                	jmp    800ddc <fd_lookup+0x54>
  800dd7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ddc:	5d                   	pop    %ebp
  800ddd:	c3                   	ret    

00800dde <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800dde:	55                   	push   %ebp
  800ddf:	89 e5                	mov    %esp,%ebp
  800de1:	83 ec 08             	sub    $0x8,%esp
  800de4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de7:	ba 08 22 80 00       	mov    $0x802208,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800dec:	eb 13                	jmp    800e01 <dev_lookup+0x23>
  800dee:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800df1:	39 08                	cmp    %ecx,(%eax)
  800df3:	75 0c                	jne    800e01 <dev_lookup+0x23>
			*dev = devtab[i];
  800df5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df8:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dfa:	b8 00 00 00 00       	mov    $0x0,%eax
  800dff:	eb 2e                	jmp    800e2f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e01:	8b 02                	mov    (%edx),%eax
  800e03:	85 c0                	test   %eax,%eax
  800e05:	75 e7                	jne    800dee <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e07:	a1 04 40 80 00       	mov    0x804004,%eax
  800e0c:	8b 40 48             	mov    0x48(%eax),%eax
  800e0f:	83 ec 04             	sub    $0x4,%esp
  800e12:	51                   	push   %ecx
  800e13:	50                   	push   %eax
  800e14:	68 8c 21 80 00       	push   $0x80218c
  800e19:	e8 7b f3 ff ff       	call   800199 <cprintf>
	*dev = 0;
  800e1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e21:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e27:	83 c4 10             	add    $0x10,%esp
  800e2a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e2f:	c9                   	leave  
  800e30:	c3                   	ret    

00800e31 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	56                   	push   %esi
  800e35:	53                   	push   %ebx
  800e36:	83 ec 10             	sub    $0x10,%esp
  800e39:	8b 75 08             	mov    0x8(%ebp),%esi
  800e3c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e3f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e42:	50                   	push   %eax
  800e43:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e49:	c1 e8 0c             	shr    $0xc,%eax
  800e4c:	50                   	push   %eax
  800e4d:	e8 36 ff ff ff       	call   800d88 <fd_lookup>
  800e52:	83 c4 08             	add    $0x8,%esp
  800e55:	85 c0                	test   %eax,%eax
  800e57:	78 05                	js     800e5e <fd_close+0x2d>
	    || fd != fd2)
  800e59:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e5c:	74 0c                	je     800e6a <fd_close+0x39>
		return (must_exist ? r : 0);
  800e5e:	84 db                	test   %bl,%bl
  800e60:	ba 00 00 00 00       	mov    $0x0,%edx
  800e65:	0f 44 c2             	cmove  %edx,%eax
  800e68:	eb 41                	jmp    800eab <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e6a:	83 ec 08             	sub    $0x8,%esp
  800e6d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e70:	50                   	push   %eax
  800e71:	ff 36                	pushl  (%esi)
  800e73:	e8 66 ff ff ff       	call   800dde <dev_lookup>
  800e78:	89 c3                	mov    %eax,%ebx
  800e7a:	83 c4 10             	add    $0x10,%esp
  800e7d:	85 c0                	test   %eax,%eax
  800e7f:	78 1a                	js     800e9b <fd_close+0x6a>
		if (dev->dev_close)
  800e81:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e84:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e87:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e8c:	85 c0                	test   %eax,%eax
  800e8e:	74 0b                	je     800e9b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800e90:	83 ec 0c             	sub    $0xc,%esp
  800e93:	56                   	push   %esi
  800e94:	ff d0                	call   *%eax
  800e96:	89 c3                	mov    %eax,%ebx
  800e98:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e9b:	83 ec 08             	sub    $0x8,%esp
  800e9e:	56                   	push   %esi
  800e9f:	6a 00                	push   $0x0
  800ea1:	e8 00 fd ff ff       	call   800ba6 <sys_page_unmap>
	return r;
  800ea6:	83 c4 10             	add    $0x10,%esp
  800ea9:	89 d8                	mov    %ebx,%eax
}
  800eab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eae:	5b                   	pop    %ebx
  800eaf:	5e                   	pop    %esi
  800eb0:	5d                   	pop    %ebp
  800eb1:	c3                   	ret    

00800eb2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800eb2:	55                   	push   %ebp
  800eb3:	89 e5                	mov    %esp,%ebp
  800eb5:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ebb:	50                   	push   %eax
  800ebc:	ff 75 08             	pushl  0x8(%ebp)
  800ebf:	e8 c4 fe ff ff       	call   800d88 <fd_lookup>
  800ec4:	83 c4 08             	add    $0x8,%esp
  800ec7:	85 c0                	test   %eax,%eax
  800ec9:	78 10                	js     800edb <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ecb:	83 ec 08             	sub    $0x8,%esp
  800ece:	6a 01                	push   $0x1
  800ed0:	ff 75 f4             	pushl  -0xc(%ebp)
  800ed3:	e8 59 ff ff ff       	call   800e31 <fd_close>
  800ed8:	83 c4 10             	add    $0x10,%esp
}
  800edb:	c9                   	leave  
  800edc:	c3                   	ret    

00800edd <close_all>:

void
close_all(void)
{
  800edd:	55                   	push   %ebp
  800ede:	89 e5                	mov    %esp,%ebp
  800ee0:	53                   	push   %ebx
  800ee1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ee4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ee9:	83 ec 0c             	sub    $0xc,%esp
  800eec:	53                   	push   %ebx
  800eed:	e8 c0 ff ff ff       	call   800eb2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ef2:	83 c3 01             	add    $0x1,%ebx
  800ef5:	83 c4 10             	add    $0x10,%esp
  800ef8:	83 fb 20             	cmp    $0x20,%ebx
  800efb:	75 ec                	jne    800ee9 <close_all+0xc>
		close(i);
}
  800efd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f00:	c9                   	leave  
  800f01:	c3                   	ret    

00800f02 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f02:	55                   	push   %ebp
  800f03:	89 e5                	mov    %esp,%ebp
  800f05:	57                   	push   %edi
  800f06:	56                   	push   %esi
  800f07:	53                   	push   %ebx
  800f08:	83 ec 2c             	sub    $0x2c,%esp
  800f0b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f0e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f11:	50                   	push   %eax
  800f12:	ff 75 08             	pushl  0x8(%ebp)
  800f15:	e8 6e fe ff ff       	call   800d88 <fd_lookup>
  800f1a:	83 c4 08             	add    $0x8,%esp
  800f1d:	85 c0                	test   %eax,%eax
  800f1f:	0f 88 c1 00 00 00    	js     800fe6 <dup+0xe4>
		return r;
	close(newfdnum);
  800f25:	83 ec 0c             	sub    $0xc,%esp
  800f28:	56                   	push   %esi
  800f29:	e8 84 ff ff ff       	call   800eb2 <close>

	newfd = INDEX2FD(newfdnum);
  800f2e:	89 f3                	mov    %esi,%ebx
  800f30:	c1 e3 0c             	shl    $0xc,%ebx
  800f33:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f39:	83 c4 04             	add    $0x4,%esp
  800f3c:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f3f:	e8 de fd ff ff       	call   800d22 <fd2data>
  800f44:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f46:	89 1c 24             	mov    %ebx,(%esp)
  800f49:	e8 d4 fd ff ff       	call   800d22 <fd2data>
  800f4e:	83 c4 10             	add    $0x10,%esp
  800f51:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f54:	89 f8                	mov    %edi,%eax
  800f56:	c1 e8 16             	shr    $0x16,%eax
  800f59:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f60:	a8 01                	test   $0x1,%al
  800f62:	74 37                	je     800f9b <dup+0x99>
  800f64:	89 f8                	mov    %edi,%eax
  800f66:	c1 e8 0c             	shr    $0xc,%eax
  800f69:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f70:	f6 c2 01             	test   $0x1,%dl
  800f73:	74 26                	je     800f9b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f75:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f7c:	83 ec 0c             	sub    $0xc,%esp
  800f7f:	25 07 0e 00 00       	and    $0xe07,%eax
  800f84:	50                   	push   %eax
  800f85:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f88:	6a 00                	push   $0x0
  800f8a:	57                   	push   %edi
  800f8b:	6a 00                	push   $0x0
  800f8d:	e8 d2 fb ff ff       	call   800b64 <sys_page_map>
  800f92:	89 c7                	mov    %eax,%edi
  800f94:	83 c4 20             	add    $0x20,%esp
  800f97:	85 c0                	test   %eax,%eax
  800f99:	78 2e                	js     800fc9 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f9b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f9e:	89 d0                	mov    %edx,%eax
  800fa0:	c1 e8 0c             	shr    $0xc,%eax
  800fa3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800faa:	83 ec 0c             	sub    $0xc,%esp
  800fad:	25 07 0e 00 00       	and    $0xe07,%eax
  800fb2:	50                   	push   %eax
  800fb3:	53                   	push   %ebx
  800fb4:	6a 00                	push   $0x0
  800fb6:	52                   	push   %edx
  800fb7:	6a 00                	push   $0x0
  800fb9:	e8 a6 fb ff ff       	call   800b64 <sys_page_map>
  800fbe:	89 c7                	mov    %eax,%edi
  800fc0:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800fc3:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fc5:	85 ff                	test   %edi,%edi
  800fc7:	79 1d                	jns    800fe6 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fc9:	83 ec 08             	sub    $0x8,%esp
  800fcc:	53                   	push   %ebx
  800fcd:	6a 00                	push   $0x0
  800fcf:	e8 d2 fb ff ff       	call   800ba6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fd4:	83 c4 08             	add    $0x8,%esp
  800fd7:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fda:	6a 00                	push   $0x0
  800fdc:	e8 c5 fb ff ff       	call   800ba6 <sys_page_unmap>
	return r;
  800fe1:	83 c4 10             	add    $0x10,%esp
  800fe4:	89 f8                	mov    %edi,%eax
}
  800fe6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe9:	5b                   	pop    %ebx
  800fea:	5e                   	pop    %esi
  800feb:	5f                   	pop    %edi
  800fec:	5d                   	pop    %ebp
  800fed:	c3                   	ret    

00800fee <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800fee:	55                   	push   %ebp
  800fef:	89 e5                	mov    %esp,%ebp
  800ff1:	53                   	push   %ebx
  800ff2:	83 ec 14             	sub    $0x14,%esp
  800ff5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ff8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ffb:	50                   	push   %eax
  800ffc:	53                   	push   %ebx
  800ffd:	e8 86 fd ff ff       	call   800d88 <fd_lookup>
  801002:	83 c4 08             	add    $0x8,%esp
  801005:	89 c2                	mov    %eax,%edx
  801007:	85 c0                	test   %eax,%eax
  801009:	78 6d                	js     801078 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80100b:	83 ec 08             	sub    $0x8,%esp
  80100e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801011:	50                   	push   %eax
  801012:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801015:	ff 30                	pushl  (%eax)
  801017:	e8 c2 fd ff ff       	call   800dde <dev_lookup>
  80101c:	83 c4 10             	add    $0x10,%esp
  80101f:	85 c0                	test   %eax,%eax
  801021:	78 4c                	js     80106f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801023:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801026:	8b 42 08             	mov    0x8(%edx),%eax
  801029:	83 e0 03             	and    $0x3,%eax
  80102c:	83 f8 01             	cmp    $0x1,%eax
  80102f:	75 21                	jne    801052 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801031:	a1 04 40 80 00       	mov    0x804004,%eax
  801036:	8b 40 48             	mov    0x48(%eax),%eax
  801039:	83 ec 04             	sub    $0x4,%esp
  80103c:	53                   	push   %ebx
  80103d:	50                   	push   %eax
  80103e:	68 cd 21 80 00       	push   $0x8021cd
  801043:	e8 51 f1 ff ff       	call   800199 <cprintf>
		return -E_INVAL;
  801048:	83 c4 10             	add    $0x10,%esp
  80104b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801050:	eb 26                	jmp    801078 <read+0x8a>
	}
	if (!dev->dev_read)
  801052:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801055:	8b 40 08             	mov    0x8(%eax),%eax
  801058:	85 c0                	test   %eax,%eax
  80105a:	74 17                	je     801073 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80105c:	83 ec 04             	sub    $0x4,%esp
  80105f:	ff 75 10             	pushl  0x10(%ebp)
  801062:	ff 75 0c             	pushl  0xc(%ebp)
  801065:	52                   	push   %edx
  801066:	ff d0                	call   *%eax
  801068:	89 c2                	mov    %eax,%edx
  80106a:	83 c4 10             	add    $0x10,%esp
  80106d:	eb 09                	jmp    801078 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80106f:	89 c2                	mov    %eax,%edx
  801071:	eb 05                	jmp    801078 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801073:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801078:	89 d0                	mov    %edx,%eax
  80107a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80107d:	c9                   	leave  
  80107e:	c3                   	ret    

0080107f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80107f:	55                   	push   %ebp
  801080:	89 e5                	mov    %esp,%ebp
  801082:	57                   	push   %edi
  801083:	56                   	push   %esi
  801084:	53                   	push   %ebx
  801085:	83 ec 0c             	sub    $0xc,%esp
  801088:	8b 7d 08             	mov    0x8(%ebp),%edi
  80108b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80108e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801093:	eb 21                	jmp    8010b6 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801095:	83 ec 04             	sub    $0x4,%esp
  801098:	89 f0                	mov    %esi,%eax
  80109a:	29 d8                	sub    %ebx,%eax
  80109c:	50                   	push   %eax
  80109d:	89 d8                	mov    %ebx,%eax
  80109f:	03 45 0c             	add    0xc(%ebp),%eax
  8010a2:	50                   	push   %eax
  8010a3:	57                   	push   %edi
  8010a4:	e8 45 ff ff ff       	call   800fee <read>
		if (m < 0)
  8010a9:	83 c4 10             	add    $0x10,%esp
  8010ac:	85 c0                	test   %eax,%eax
  8010ae:	78 10                	js     8010c0 <readn+0x41>
			return m;
		if (m == 0)
  8010b0:	85 c0                	test   %eax,%eax
  8010b2:	74 0a                	je     8010be <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010b4:	01 c3                	add    %eax,%ebx
  8010b6:	39 f3                	cmp    %esi,%ebx
  8010b8:	72 db                	jb     801095 <readn+0x16>
  8010ba:	89 d8                	mov    %ebx,%eax
  8010bc:	eb 02                	jmp    8010c0 <readn+0x41>
  8010be:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c3:	5b                   	pop    %ebx
  8010c4:	5e                   	pop    %esi
  8010c5:	5f                   	pop    %edi
  8010c6:	5d                   	pop    %ebp
  8010c7:	c3                   	ret    

008010c8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010c8:	55                   	push   %ebp
  8010c9:	89 e5                	mov    %esp,%ebp
  8010cb:	53                   	push   %ebx
  8010cc:	83 ec 14             	sub    $0x14,%esp
  8010cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010d5:	50                   	push   %eax
  8010d6:	53                   	push   %ebx
  8010d7:	e8 ac fc ff ff       	call   800d88 <fd_lookup>
  8010dc:	83 c4 08             	add    $0x8,%esp
  8010df:	89 c2                	mov    %eax,%edx
  8010e1:	85 c0                	test   %eax,%eax
  8010e3:	78 68                	js     80114d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010e5:	83 ec 08             	sub    $0x8,%esp
  8010e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010eb:	50                   	push   %eax
  8010ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010ef:	ff 30                	pushl  (%eax)
  8010f1:	e8 e8 fc ff ff       	call   800dde <dev_lookup>
  8010f6:	83 c4 10             	add    $0x10,%esp
  8010f9:	85 c0                	test   %eax,%eax
  8010fb:	78 47                	js     801144 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801100:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801104:	75 21                	jne    801127 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801106:	a1 04 40 80 00       	mov    0x804004,%eax
  80110b:	8b 40 48             	mov    0x48(%eax),%eax
  80110e:	83 ec 04             	sub    $0x4,%esp
  801111:	53                   	push   %ebx
  801112:	50                   	push   %eax
  801113:	68 e9 21 80 00       	push   $0x8021e9
  801118:	e8 7c f0 ff ff       	call   800199 <cprintf>
		return -E_INVAL;
  80111d:	83 c4 10             	add    $0x10,%esp
  801120:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801125:	eb 26                	jmp    80114d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801127:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80112a:	8b 52 0c             	mov    0xc(%edx),%edx
  80112d:	85 d2                	test   %edx,%edx
  80112f:	74 17                	je     801148 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801131:	83 ec 04             	sub    $0x4,%esp
  801134:	ff 75 10             	pushl  0x10(%ebp)
  801137:	ff 75 0c             	pushl  0xc(%ebp)
  80113a:	50                   	push   %eax
  80113b:	ff d2                	call   *%edx
  80113d:	89 c2                	mov    %eax,%edx
  80113f:	83 c4 10             	add    $0x10,%esp
  801142:	eb 09                	jmp    80114d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801144:	89 c2                	mov    %eax,%edx
  801146:	eb 05                	jmp    80114d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801148:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80114d:	89 d0                	mov    %edx,%eax
  80114f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801152:	c9                   	leave  
  801153:	c3                   	ret    

00801154 <seek>:

int
seek(int fdnum, off_t offset)
{
  801154:	55                   	push   %ebp
  801155:	89 e5                	mov    %esp,%ebp
  801157:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80115a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80115d:	50                   	push   %eax
  80115e:	ff 75 08             	pushl  0x8(%ebp)
  801161:	e8 22 fc ff ff       	call   800d88 <fd_lookup>
  801166:	83 c4 08             	add    $0x8,%esp
  801169:	85 c0                	test   %eax,%eax
  80116b:	78 0e                	js     80117b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80116d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801170:	8b 55 0c             	mov    0xc(%ebp),%edx
  801173:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801176:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80117b:	c9                   	leave  
  80117c:	c3                   	ret    

0080117d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80117d:	55                   	push   %ebp
  80117e:	89 e5                	mov    %esp,%ebp
  801180:	53                   	push   %ebx
  801181:	83 ec 14             	sub    $0x14,%esp
  801184:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801187:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80118a:	50                   	push   %eax
  80118b:	53                   	push   %ebx
  80118c:	e8 f7 fb ff ff       	call   800d88 <fd_lookup>
  801191:	83 c4 08             	add    $0x8,%esp
  801194:	89 c2                	mov    %eax,%edx
  801196:	85 c0                	test   %eax,%eax
  801198:	78 65                	js     8011ff <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80119a:	83 ec 08             	sub    $0x8,%esp
  80119d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a0:	50                   	push   %eax
  8011a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a4:	ff 30                	pushl  (%eax)
  8011a6:	e8 33 fc ff ff       	call   800dde <dev_lookup>
  8011ab:	83 c4 10             	add    $0x10,%esp
  8011ae:	85 c0                	test   %eax,%eax
  8011b0:	78 44                	js     8011f6 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011b9:	75 21                	jne    8011dc <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011bb:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011c0:	8b 40 48             	mov    0x48(%eax),%eax
  8011c3:	83 ec 04             	sub    $0x4,%esp
  8011c6:	53                   	push   %ebx
  8011c7:	50                   	push   %eax
  8011c8:	68 ac 21 80 00       	push   $0x8021ac
  8011cd:	e8 c7 ef ff ff       	call   800199 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011d2:	83 c4 10             	add    $0x10,%esp
  8011d5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011da:	eb 23                	jmp    8011ff <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011df:	8b 52 18             	mov    0x18(%edx),%edx
  8011e2:	85 d2                	test   %edx,%edx
  8011e4:	74 14                	je     8011fa <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011e6:	83 ec 08             	sub    $0x8,%esp
  8011e9:	ff 75 0c             	pushl  0xc(%ebp)
  8011ec:	50                   	push   %eax
  8011ed:	ff d2                	call   *%edx
  8011ef:	89 c2                	mov    %eax,%edx
  8011f1:	83 c4 10             	add    $0x10,%esp
  8011f4:	eb 09                	jmp    8011ff <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f6:	89 c2                	mov    %eax,%edx
  8011f8:	eb 05                	jmp    8011ff <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011fa:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8011ff:	89 d0                	mov    %edx,%eax
  801201:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801204:	c9                   	leave  
  801205:	c3                   	ret    

00801206 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801206:	55                   	push   %ebp
  801207:	89 e5                	mov    %esp,%ebp
  801209:	53                   	push   %ebx
  80120a:	83 ec 14             	sub    $0x14,%esp
  80120d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801210:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801213:	50                   	push   %eax
  801214:	ff 75 08             	pushl  0x8(%ebp)
  801217:	e8 6c fb ff ff       	call   800d88 <fd_lookup>
  80121c:	83 c4 08             	add    $0x8,%esp
  80121f:	89 c2                	mov    %eax,%edx
  801221:	85 c0                	test   %eax,%eax
  801223:	78 58                	js     80127d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801225:	83 ec 08             	sub    $0x8,%esp
  801228:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122b:	50                   	push   %eax
  80122c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80122f:	ff 30                	pushl  (%eax)
  801231:	e8 a8 fb ff ff       	call   800dde <dev_lookup>
  801236:	83 c4 10             	add    $0x10,%esp
  801239:	85 c0                	test   %eax,%eax
  80123b:	78 37                	js     801274 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80123d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801240:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801244:	74 32                	je     801278 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801246:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801249:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801250:	00 00 00 
	stat->st_isdir = 0;
  801253:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80125a:	00 00 00 
	stat->st_dev = dev;
  80125d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801263:	83 ec 08             	sub    $0x8,%esp
  801266:	53                   	push   %ebx
  801267:	ff 75 f0             	pushl  -0x10(%ebp)
  80126a:	ff 50 14             	call   *0x14(%eax)
  80126d:	89 c2                	mov    %eax,%edx
  80126f:	83 c4 10             	add    $0x10,%esp
  801272:	eb 09                	jmp    80127d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801274:	89 c2                	mov    %eax,%edx
  801276:	eb 05                	jmp    80127d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801278:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80127d:	89 d0                	mov    %edx,%eax
  80127f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801282:	c9                   	leave  
  801283:	c3                   	ret    

00801284 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801284:	55                   	push   %ebp
  801285:	89 e5                	mov    %esp,%ebp
  801287:	56                   	push   %esi
  801288:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801289:	83 ec 08             	sub    $0x8,%esp
  80128c:	6a 00                	push   $0x0
  80128e:	ff 75 08             	pushl  0x8(%ebp)
  801291:	e8 e3 01 00 00       	call   801479 <open>
  801296:	89 c3                	mov    %eax,%ebx
  801298:	83 c4 10             	add    $0x10,%esp
  80129b:	85 c0                	test   %eax,%eax
  80129d:	78 1b                	js     8012ba <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80129f:	83 ec 08             	sub    $0x8,%esp
  8012a2:	ff 75 0c             	pushl  0xc(%ebp)
  8012a5:	50                   	push   %eax
  8012a6:	e8 5b ff ff ff       	call   801206 <fstat>
  8012ab:	89 c6                	mov    %eax,%esi
	close(fd);
  8012ad:	89 1c 24             	mov    %ebx,(%esp)
  8012b0:	e8 fd fb ff ff       	call   800eb2 <close>
	return r;
  8012b5:	83 c4 10             	add    $0x10,%esp
  8012b8:	89 f0                	mov    %esi,%eax
}
  8012ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012bd:	5b                   	pop    %ebx
  8012be:	5e                   	pop    %esi
  8012bf:	5d                   	pop    %ebp
  8012c0:	c3                   	ret    

008012c1 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012c1:	55                   	push   %ebp
  8012c2:	89 e5                	mov    %esp,%ebp
  8012c4:	56                   	push   %esi
  8012c5:	53                   	push   %ebx
  8012c6:	89 c6                	mov    %eax,%esi
  8012c8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012ca:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012d1:	75 12                	jne    8012e5 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012d3:	83 ec 0c             	sub    $0xc,%esp
  8012d6:	6a 01                	push   $0x1
  8012d8:	e8 39 08 00 00       	call   801b16 <ipc_find_env>
  8012dd:	a3 00 40 80 00       	mov    %eax,0x804000
  8012e2:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012e5:	6a 07                	push   $0x7
  8012e7:	68 00 50 80 00       	push   $0x805000
  8012ec:	56                   	push   %esi
  8012ed:	ff 35 00 40 80 00    	pushl  0x804000
  8012f3:	e8 bc 07 00 00       	call   801ab4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8012f8:	83 c4 0c             	add    $0xc,%esp
  8012fb:	6a 00                	push   $0x0
  8012fd:	53                   	push   %ebx
  8012fe:	6a 00                	push   $0x0
  801300:	e8 3d 07 00 00       	call   801a42 <ipc_recv>
}
  801305:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801308:	5b                   	pop    %ebx
  801309:	5e                   	pop    %esi
  80130a:	5d                   	pop    %ebp
  80130b:	c3                   	ret    

0080130c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80130c:	55                   	push   %ebp
  80130d:	89 e5                	mov    %esp,%ebp
  80130f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801312:	8b 45 08             	mov    0x8(%ebp),%eax
  801315:	8b 40 0c             	mov    0xc(%eax),%eax
  801318:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80131d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801320:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801325:	ba 00 00 00 00       	mov    $0x0,%edx
  80132a:	b8 02 00 00 00       	mov    $0x2,%eax
  80132f:	e8 8d ff ff ff       	call   8012c1 <fsipc>
}
  801334:	c9                   	leave  
  801335:	c3                   	ret    

00801336 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801336:	55                   	push   %ebp
  801337:	89 e5                	mov    %esp,%ebp
  801339:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80133c:	8b 45 08             	mov    0x8(%ebp),%eax
  80133f:	8b 40 0c             	mov    0xc(%eax),%eax
  801342:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801347:	ba 00 00 00 00       	mov    $0x0,%edx
  80134c:	b8 06 00 00 00       	mov    $0x6,%eax
  801351:	e8 6b ff ff ff       	call   8012c1 <fsipc>
}
  801356:	c9                   	leave  
  801357:	c3                   	ret    

00801358 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801358:	55                   	push   %ebp
  801359:	89 e5                	mov    %esp,%ebp
  80135b:	53                   	push   %ebx
  80135c:	83 ec 04             	sub    $0x4,%esp
  80135f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801362:	8b 45 08             	mov    0x8(%ebp),%eax
  801365:	8b 40 0c             	mov    0xc(%eax),%eax
  801368:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80136d:	ba 00 00 00 00       	mov    $0x0,%edx
  801372:	b8 05 00 00 00       	mov    $0x5,%eax
  801377:	e8 45 ff ff ff       	call   8012c1 <fsipc>
  80137c:	85 c0                	test   %eax,%eax
  80137e:	78 2c                	js     8013ac <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801380:	83 ec 08             	sub    $0x8,%esp
  801383:	68 00 50 80 00       	push   $0x805000
  801388:	53                   	push   %ebx
  801389:	e8 90 f3 ff ff       	call   80071e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80138e:	a1 80 50 80 00       	mov    0x805080,%eax
  801393:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801399:	a1 84 50 80 00       	mov    0x805084,%eax
  80139e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013a4:	83 c4 10             	add    $0x10,%esp
  8013a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013af:	c9                   	leave  
  8013b0:	c3                   	ret    

008013b1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013b1:	55                   	push   %ebp
  8013b2:	89 e5                	mov    %esp,%ebp
  8013b4:	83 ec 0c             	sub    $0xc,%esp
  8013b7:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8013bd:	8b 52 0c             	mov    0xc(%edx),%edx
  8013c0:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8013c6:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8013cb:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8013d0:	0f 47 c2             	cmova  %edx,%eax
  8013d3:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8013d8:	50                   	push   %eax
  8013d9:	ff 75 0c             	pushl  0xc(%ebp)
  8013dc:	68 08 50 80 00       	push   $0x805008
  8013e1:	e8 ca f4 ff ff       	call   8008b0 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8013e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8013eb:	b8 04 00 00 00       	mov    $0x4,%eax
  8013f0:	e8 cc fe ff ff       	call   8012c1 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8013f5:	c9                   	leave  
  8013f6:	c3                   	ret    

008013f7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013f7:	55                   	push   %ebp
  8013f8:	89 e5                	mov    %esp,%ebp
  8013fa:	56                   	push   %esi
  8013fb:	53                   	push   %ebx
  8013fc:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801402:	8b 40 0c             	mov    0xc(%eax),%eax
  801405:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80140a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801410:	ba 00 00 00 00       	mov    $0x0,%edx
  801415:	b8 03 00 00 00       	mov    $0x3,%eax
  80141a:	e8 a2 fe ff ff       	call   8012c1 <fsipc>
  80141f:	89 c3                	mov    %eax,%ebx
  801421:	85 c0                	test   %eax,%eax
  801423:	78 4b                	js     801470 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801425:	39 c6                	cmp    %eax,%esi
  801427:	73 16                	jae    80143f <devfile_read+0x48>
  801429:	68 18 22 80 00       	push   $0x802218
  80142e:	68 1f 22 80 00       	push   $0x80221f
  801433:	6a 7c                	push   $0x7c
  801435:	68 34 22 80 00       	push   $0x802234
  80143a:	e8 bd 05 00 00       	call   8019fc <_panic>
	assert(r <= PGSIZE);
  80143f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801444:	7e 16                	jle    80145c <devfile_read+0x65>
  801446:	68 3f 22 80 00       	push   $0x80223f
  80144b:	68 1f 22 80 00       	push   $0x80221f
  801450:	6a 7d                	push   $0x7d
  801452:	68 34 22 80 00       	push   $0x802234
  801457:	e8 a0 05 00 00       	call   8019fc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80145c:	83 ec 04             	sub    $0x4,%esp
  80145f:	50                   	push   %eax
  801460:	68 00 50 80 00       	push   $0x805000
  801465:	ff 75 0c             	pushl  0xc(%ebp)
  801468:	e8 43 f4 ff ff       	call   8008b0 <memmove>
	return r;
  80146d:	83 c4 10             	add    $0x10,%esp
}
  801470:	89 d8                	mov    %ebx,%eax
  801472:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801475:	5b                   	pop    %ebx
  801476:	5e                   	pop    %esi
  801477:	5d                   	pop    %ebp
  801478:	c3                   	ret    

00801479 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801479:	55                   	push   %ebp
  80147a:	89 e5                	mov    %esp,%ebp
  80147c:	53                   	push   %ebx
  80147d:	83 ec 20             	sub    $0x20,%esp
  801480:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801483:	53                   	push   %ebx
  801484:	e8 5c f2 ff ff       	call   8006e5 <strlen>
  801489:	83 c4 10             	add    $0x10,%esp
  80148c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801491:	7f 67                	jg     8014fa <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801493:	83 ec 0c             	sub    $0xc,%esp
  801496:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801499:	50                   	push   %eax
  80149a:	e8 9a f8 ff ff       	call   800d39 <fd_alloc>
  80149f:	83 c4 10             	add    $0x10,%esp
		return r;
  8014a2:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014a4:	85 c0                	test   %eax,%eax
  8014a6:	78 57                	js     8014ff <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014a8:	83 ec 08             	sub    $0x8,%esp
  8014ab:	53                   	push   %ebx
  8014ac:	68 00 50 80 00       	push   $0x805000
  8014b1:	e8 68 f2 ff ff       	call   80071e <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014b9:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014be:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8014c6:	e8 f6 fd ff ff       	call   8012c1 <fsipc>
  8014cb:	89 c3                	mov    %eax,%ebx
  8014cd:	83 c4 10             	add    $0x10,%esp
  8014d0:	85 c0                	test   %eax,%eax
  8014d2:	79 14                	jns    8014e8 <open+0x6f>
		fd_close(fd, 0);
  8014d4:	83 ec 08             	sub    $0x8,%esp
  8014d7:	6a 00                	push   $0x0
  8014d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8014dc:	e8 50 f9 ff ff       	call   800e31 <fd_close>
		return r;
  8014e1:	83 c4 10             	add    $0x10,%esp
  8014e4:	89 da                	mov    %ebx,%edx
  8014e6:	eb 17                	jmp    8014ff <open+0x86>
	}

	return fd2num(fd);
  8014e8:	83 ec 0c             	sub    $0xc,%esp
  8014eb:	ff 75 f4             	pushl  -0xc(%ebp)
  8014ee:	e8 1f f8 ff ff       	call   800d12 <fd2num>
  8014f3:	89 c2                	mov    %eax,%edx
  8014f5:	83 c4 10             	add    $0x10,%esp
  8014f8:	eb 05                	jmp    8014ff <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8014fa:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8014ff:	89 d0                	mov    %edx,%eax
  801501:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801504:	c9                   	leave  
  801505:	c3                   	ret    

00801506 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801506:	55                   	push   %ebp
  801507:	89 e5                	mov    %esp,%ebp
  801509:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80150c:	ba 00 00 00 00       	mov    $0x0,%edx
  801511:	b8 08 00 00 00       	mov    $0x8,%eax
  801516:	e8 a6 fd ff ff       	call   8012c1 <fsipc>
}
  80151b:	c9                   	leave  
  80151c:	c3                   	ret    

0080151d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80151d:	55                   	push   %ebp
  80151e:	89 e5                	mov    %esp,%ebp
  801520:	56                   	push   %esi
  801521:	53                   	push   %ebx
  801522:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801525:	83 ec 0c             	sub    $0xc,%esp
  801528:	ff 75 08             	pushl  0x8(%ebp)
  80152b:	e8 f2 f7 ff ff       	call   800d22 <fd2data>
  801530:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801532:	83 c4 08             	add    $0x8,%esp
  801535:	68 4b 22 80 00       	push   $0x80224b
  80153a:	53                   	push   %ebx
  80153b:	e8 de f1 ff ff       	call   80071e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801540:	8b 46 04             	mov    0x4(%esi),%eax
  801543:	2b 06                	sub    (%esi),%eax
  801545:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80154b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801552:	00 00 00 
	stat->st_dev = &devpipe;
  801555:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80155c:	30 80 00 
	return 0;
}
  80155f:	b8 00 00 00 00       	mov    $0x0,%eax
  801564:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801567:	5b                   	pop    %ebx
  801568:	5e                   	pop    %esi
  801569:	5d                   	pop    %ebp
  80156a:	c3                   	ret    

0080156b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80156b:	55                   	push   %ebp
  80156c:	89 e5                	mov    %esp,%ebp
  80156e:	53                   	push   %ebx
  80156f:	83 ec 0c             	sub    $0xc,%esp
  801572:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801575:	53                   	push   %ebx
  801576:	6a 00                	push   $0x0
  801578:	e8 29 f6 ff ff       	call   800ba6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80157d:	89 1c 24             	mov    %ebx,(%esp)
  801580:	e8 9d f7 ff ff       	call   800d22 <fd2data>
  801585:	83 c4 08             	add    $0x8,%esp
  801588:	50                   	push   %eax
  801589:	6a 00                	push   $0x0
  80158b:	e8 16 f6 ff ff       	call   800ba6 <sys_page_unmap>
}
  801590:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801593:	c9                   	leave  
  801594:	c3                   	ret    

00801595 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801595:	55                   	push   %ebp
  801596:	89 e5                	mov    %esp,%ebp
  801598:	57                   	push   %edi
  801599:	56                   	push   %esi
  80159a:	53                   	push   %ebx
  80159b:	83 ec 1c             	sub    $0x1c,%esp
  80159e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015a1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015a3:	a1 04 40 80 00       	mov    0x804004,%eax
  8015a8:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015ab:	83 ec 0c             	sub    $0xc,%esp
  8015ae:	ff 75 e0             	pushl  -0x20(%ebp)
  8015b1:	e8 99 05 00 00       	call   801b4f <pageref>
  8015b6:	89 c3                	mov    %eax,%ebx
  8015b8:	89 3c 24             	mov    %edi,(%esp)
  8015bb:	e8 8f 05 00 00       	call   801b4f <pageref>
  8015c0:	83 c4 10             	add    $0x10,%esp
  8015c3:	39 c3                	cmp    %eax,%ebx
  8015c5:	0f 94 c1             	sete   %cl
  8015c8:	0f b6 c9             	movzbl %cl,%ecx
  8015cb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8015ce:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8015d4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015d7:	39 ce                	cmp    %ecx,%esi
  8015d9:	74 1b                	je     8015f6 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8015db:	39 c3                	cmp    %eax,%ebx
  8015dd:	75 c4                	jne    8015a3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015df:	8b 42 58             	mov    0x58(%edx),%eax
  8015e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015e5:	50                   	push   %eax
  8015e6:	56                   	push   %esi
  8015e7:	68 52 22 80 00       	push   $0x802252
  8015ec:	e8 a8 eb ff ff       	call   800199 <cprintf>
  8015f1:	83 c4 10             	add    $0x10,%esp
  8015f4:	eb ad                	jmp    8015a3 <_pipeisclosed+0xe>
	}
}
  8015f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015fc:	5b                   	pop    %ebx
  8015fd:	5e                   	pop    %esi
  8015fe:	5f                   	pop    %edi
  8015ff:	5d                   	pop    %ebp
  801600:	c3                   	ret    

00801601 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801601:	55                   	push   %ebp
  801602:	89 e5                	mov    %esp,%ebp
  801604:	57                   	push   %edi
  801605:	56                   	push   %esi
  801606:	53                   	push   %ebx
  801607:	83 ec 28             	sub    $0x28,%esp
  80160a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80160d:	56                   	push   %esi
  80160e:	e8 0f f7 ff ff       	call   800d22 <fd2data>
  801613:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801615:	83 c4 10             	add    $0x10,%esp
  801618:	bf 00 00 00 00       	mov    $0x0,%edi
  80161d:	eb 4b                	jmp    80166a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80161f:	89 da                	mov    %ebx,%edx
  801621:	89 f0                	mov    %esi,%eax
  801623:	e8 6d ff ff ff       	call   801595 <_pipeisclosed>
  801628:	85 c0                	test   %eax,%eax
  80162a:	75 48                	jne    801674 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80162c:	e8 d1 f4 ff ff       	call   800b02 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801631:	8b 43 04             	mov    0x4(%ebx),%eax
  801634:	8b 0b                	mov    (%ebx),%ecx
  801636:	8d 51 20             	lea    0x20(%ecx),%edx
  801639:	39 d0                	cmp    %edx,%eax
  80163b:	73 e2                	jae    80161f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80163d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801640:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801644:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801647:	89 c2                	mov    %eax,%edx
  801649:	c1 fa 1f             	sar    $0x1f,%edx
  80164c:	89 d1                	mov    %edx,%ecx
  80164e:	c1 e9 1b             	shr    $0x1b,%ecx
  801651:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801654:	83 e2 1f             	and    $0x1f,%edx
  801657:	29 ca                	sub    %ecx,%edx
  801659:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80165d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801661:	83 c0 01             	add    $0x1,%eax
  801664:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801667:	83 c7 01             	add    $0x1,%edi
  80166a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80166d:	75 c2                	jne    801631 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80166f:	8b 45 10             	mov    0x10(%ebp),%eax
  801672:	eb 05                	jmp    801679 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801674:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801679:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80167c:	5b                   	pop    %ebx
  80167d:	5e                   	pop    %esi
  80167e:	5f                   	pop    %edi
  80167f:	5d                   	pop    %ebp
  801680:	c3                   	ret    

00801681 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801681:	55                   	push   %ebp
  801682:	89 e5                	mov    %esp,%ebp
  801684:	57                   	push   %edi
  801685:	56                   	push   %esi
  801686:	53                   	push   %ebx
  801687:	83 ec 18             	sub    $0x18,%esp
  80168a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80168d:	57                   	push   %edi
  80168e:	e8 8f f6 ff ff       	call   800d22 <fd2data>
  801693:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801695:	83 c4 10             	add    $0x10,%esp
  801698:	bb 00 00 00 00       	mov    $0x0,%ebx
  80169d:	eb 3d                	jmp    8016dc <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80169f:	85 db                	test   %ebx,%ebx
  8016a1:	74 04                	je     8016a7 <devpipe_read+0x26>
				return i;
  8016a3:	89 d8                	mov    %ebx,%eax
  8016a5:	eb 44                	jmp    8016eb <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016a7:	89 f2                	mov    %esi,%edx
  8016a9:	89 f8                	mov    %edi,%eax
  8016ab:	e8 e5 fe ff ff       	call   801595 <_pipeisclosed>
  8016b0:	85 c0                	test   %eax,%eax
  8016b2:	75 32                	jne    8016e6 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016b4:	e8 49 f4 ff ff       	call   800b02 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016b9:	8b 06                	mov    (%esi),%eax
  8016bb:	3b 46 04             	cmp    0x4(%esi),%eax
  8016be:	74 df                	je     80169f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016c0:	99                   	cltd   
  8016c1:	c1 ea 1b             	shr    $0x1b,%edx
  8016c4:	01 d0                	add    %edx,%eax
  8016c6:	83 e0 1f             	and    $0x1f,%eax
  8016c9:	29 d0                	sub    %edx,%eax
  8016cb:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016d3:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016d6:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016d9:	83 c3 01             	add    $0x1,%ebx
  8016dc:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016df:	75 d8                	jne    8016b9 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016e1:	8b 45 10             	mov    0x10(%ebp),%eax
  8016e4:	eb 05                	jmp    8016eb <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016e6:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016ee:	5b                   	pop    %ebx
  8016ef:	5e                   	pop    %esi
  8016f0:	5f                   	pop    %edi
  8016f1:	5d                   	pop    %ebp
  8016f2:	c3                   	ret    

008016f3 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8016f3:	55                   	push   %ebp
  8016f4:	89 e5                	mov    %esp,%ebp
  8016f6:	56                   	push   %esi
  8016f7:	53                   	push   %ebx
  8016f8:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8016fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016fe:	50                   	push   %eax
  8016ff:	e8 35 f6 ff ff       	call   800d39 <fd_alloc>
  801704:	83 c4 10             	add    $0x10,%esp
  801707:	89 c2                	mov    %eax,%edx
  801709:	85 c0                	test   %eax,%eax
  80170b:	0f 88 2c 01 00 00    	js     80183d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801711:	83 ec 04             	sub    $0x4,%esp
  801714:	68 07 04 00 00       	push   $0x407
  801719:	ff 75 f4             	pushl  -0xc(%ebp)
  80171c:	6a 00                	push   $0x0
  80171e:	e8 fe f3 ff ff       	call   800b21 <sys_page_alloc>
  801723:	83 c4 10             	add    $0x10,%esp
  801726:	89 c2                	mov    %eax,%edx
  801728:	85 c0                	test   %eax,%eax
  80172a:	0f 88 0d 01 00 00    	js     80183d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801730:	83 ec 0c             	sub    $0xc,%esp
  801733:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801736:	50                   	push   %eax
  801737:	e8 fd f5 ff ff       	call   800d39 <fd_alloc>
  80173c:	89 c3                	mov    %eax,%ebx
  80173e:	83 c4 10             	add    $0x10,%esp
  801741:	85 c0                	test   %eax,%eax
  801743:	0f 88 e2 00 00 00    	js     80182b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801749:	83 ec 04             	sub    $0x4,%esp
  80174c:	68 07 04 00 00       	push   $0x407
  801751:	ff 75 f0             	pushl  -0x10(%ebp)
  801754:	6a 00                	push   $0x0
  801756:	e8 c6 f3 ff ff       	call   800b21 <sys_page_alloc>
  80175b:	89 c3                	mov    %eax,%ebx
  80175d:	83 c4 10             	add    $0x10,%esp
  801760:	85 c0                	test   %eax,%eax
  801762:	0f 88 c3 00 00 00    	js     80182b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801768:	83 ec 0c             	sub    $0xc,%esp
  80176b:	ff 75 f4             	pushl  -0xc(%ebp)
  80176e:	e8 af f5 ff ff       	call   800d22 <fd2data>
  801773:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801775:	83 c4 0c             	add    $0xc,%esp
  801778:	68 07 04 00 00       	push   $0x407
  80177d:	50                   	push   %eax
  80177e:	6a 00                	push   $0x0
  801780:	e8 9c f3 ff ff       	call   800b21 <sys_page_alloc>
  801785:	89 c3                	mov    %eax,%ebx
  801787:	83 c4 10             	add    $0x10,%esp
  80178a:	85 c0                	test   %eax,%eax
  80178c:	0f 88 89 00 00 00    	js     80181b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801792:	83 ec 0c             	sub    $0xc,%esp
  801795:	ff 75 f0             	pushl  -0x10(%ebp)
  801798:	e8 85 f5 ff ff       	call   800d22 <fd2data>
  80179d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017a4:	50                   	push   %eax
  8017a5:	6a 00                	push   $0x0
  8017a7:	56                   	push   %esi
  8017a8:	6a 00                	push   $0x0
  8017aa:	e8 b5 f3 ff ff       	call   800b64 <sys_page_map>
  8017af:	89 c3                	mov    %eax,%ebx
  8017b1:	83 c4 20             	add    $0x20,%esp
  8017b4:	85 c0                	test   %eax,%eax
  8017b6:	78 55                	js     80180d <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017b8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017cd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017db:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017e2:	83 ec 0c             	sub    $0xc,%esp
  8017e5:	ff 75 f4             	pushl  -0xc(%ebp)
  8017e8:	e8 25 f5 ff ff       	call   800d12 <fd2num>
  8017ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017f0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017f2:	83 c4 04             	add    $0x4,%esp
  8017f5:	ff 75 f0             	pushl  -0x10(%ebp)
  8017f8:	e8 15 f5 ff ff       	call   800d12 <fd2num>
  8017fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801800:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801803:	83 c4 10             	add    $0x10,%esp
  801806:	ba 00 00 00 00       	mov    $0x0,%edx
  80180b:	eb 30                	jmp    80183d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80180d:	83 ec 08             	sub    $0x8,%esp
  801810:	56                   	push   %esi
  801811:	6a 00                	push   $0x0
  801813:	e8 8e f3 ff ff       	call   800ba6 <sys_page_unmap>
  801818:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80181b:	83 ec 08             	sub    $0x8,%esp
  80181e:	ff 75 f0             	pushl  -0x10(%ebp)
  801821:	6a 00                	push   $0x0
  801823:	e8 7e f3 ff ff       	call   800ba6 <sys_page_unmap>
  801828:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80182b:	83 ec 08             	sub    $0x8,%esp
  80182e:	ff 75 f4             	pushl  -0xc(%ebp)
  801831:	6a 00                	push   $0x0
  801833:	e8 6e f3 ff ff       	call   800ba6 <sys_page_unmap>
  801838:	83 c4 10             	add    $0x10,%esp
  80183b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80183d:	89 d0                	mov    %edx,%eax
  80183f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801842:	5b                   	pop    %ebx
  801843:	5e                   	pop    %esi
  801844:	5d                   	pop    %ebp
  801845:	c3                   	ret    

00801846 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801846:	55                   	push   %ebp
  801847:	89 e5                	mov    %esp,%ebp
  801849:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80184c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80184f:	50                   	push   %eax
  801850:	ff 75 08             	pushl  0x8(%ebp)
  801853:	e8 30 f5 ff ff       	call   800d88 <fd_lookup>
  801858:	83 c4 10             	add    $0x10,%esp
  80185b:	85 c0                	test   %eax,%eax
  80185d:	78 18                	js     801877 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80185f:	83 ec 0c             	sub    $0xc,%esp
  801862:	ff 75 f4             	pushl  -0xc(%ebp)
  801865:	e8 b8 f4 ff ff       	call   800d22 <fd2data>
	return _pipeisclosed(fd, p);
  80186a:	89 c2                	mov    %eax,%edx
  80186c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80186f:	e8 21 fd ff ff       	call   801595 <_pipeisclosed>
  801874:	83 c4 10             	add    $0x10,%esp
}
  801877:	c9                   	leave  
  801878:	c3                   	ret    

00801879 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801879:	55                   	push   %ebp
  80187a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80187c:	b8 00 00 00 00       	mov    $0x0,%eax
  801881:	5d                   	pop    %ebp
  801882:	c3                   	ret    

00801883 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801883:	55                   	push   %ebp
  801884:	89 e5                	mov    %esp,%ebp
  801886:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801889:	68 6a 22 80 00       	push   $0x80226a
  80188e:	ff 75 0c             	pushl  0xc(%ebp)
  801891:	e8 88 ee ff ff       	call   80071e <strcpy>
	return 0;
}
  801896:	b8 00 00 00 00       	mov    $0x0,%eax
  80189b:	c9                   	leave  
  80189c:	c3                   	ret    

0080189d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80189d:	55                   	push   %ebp
  80189e:	89 e5                	mov    %esp,%ebp
  8018a0:	57                   	push   %edi
  8018a1:	56                   	push   %esi
  8018a2:	53                   	push   %ebx
  8018a3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018a9:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018ae:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018b4:	eb 2d                	jmp    8018e3 <devcons_write+0x46>
		m = n - tot;
  8018b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018b9:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8018bb:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018be:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8018c3:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018c6:	83 ec 04             	sub    $0x4,%esp
  8018c9:	53                   	push   %ebx
  8018ca:	03 45 0c             	add    0xc(%ebp),%eax
  8018cd:	50                   	push   %eax
  8018ce:	57                   	push   %edi
  8018cf:	e8 dc ef ff ff       	call   8008b0 <memmove>
		sys_cputs(buf, m);
  8018d4:	83 c4 08             	add    $0x8,%esp
  8018d7:	53                   	push   %ebx
  8018d8:	57                   	push   %edi
  8018d9:	e8 87 f1 ff ff       	call   800a65 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018de:	01 de                	add    %ebx,%esi
  8018e0:	83 c4 10             	add    $0x10,%esp
  8018e3:	89 f0                	mov    %esi,%eax
  8018e5:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018e8:	72 cc                	jb     8018b6 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8018ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018ed:	5b                   	pop    %ebx
  8018ee:	5e                   	pop    %esi
  8018ef:	5f                   	pop    %edi
  8018f0:	5d                   	pop    %ebp
  8018f1:	c3                   	ret    

008018f2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018f2:	55                   	push   %ebp
  8018f3:	89 e5                	mov    %esp,%ebp
  8018f5:	83 ec 08             	sub    $0x8,%esp
  8018f8:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8018fd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801901:	74 2a                	je     80192d <devcons_read+0x3b>
  801903:	eb 05                	jmp    80190a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801905:	e8 f8 f1 ff ff       	call   800b02 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80190a:	e8 74 f1 ff ff       	call   800a83 <sys_cgetc>
  80190f:	85 c0                	test   %eax,%eax
  801911:	74 f2                	je     801905 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801913:	85 c0                	test   %eax,%eax
  801915:	78 16                	js     80192d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801917:	83 f8 04             	cmp    $0x4,%eax
  80191a:	74 0c                	je     801928 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80191c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80191f:	88 02                	mov    %al,(%edx)
	return 1;
  801921:	b8 01 00 00 00       	mov    $0x1,%eax
  801926:	eb 05                	jmp    80192d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801928:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80192d:	c9                   	leave  
  80192e:	c3                   	ret    

0080192f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80192f:	55                   	push   %ebp
  801930:	89 e5                	mov    %esp,%ebp
  801932:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801935:	8b 45 08             	mov    0x8(%ebp),%eax
  801938:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80193b:	6a 01                	push   $0x1
  80193d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801940:	50                   	push   %eax
  801941:	e8 1f f1 ff ff       	call   800a65 <sys_cputs>
}
  801946:	83 c4 10             	add    $0x10,%esp
  801949:	c9                   	leave  
  80194a:	c3                   	ret    

0080194b <getchar>:

int
getchar(void)
{
  80194b:	55                   	push   %ebp
  80194c:	89 e5                	mov    %esp,%ebp
  80194e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801951:	6a 01                	push   $0x1
  801953:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801956:	50                   	push   %eax
  801957:	6a 00                	push   $0x0
  801959:	e8 90 f6 ff ff       	call   800fee <read>
	if (r < 0)
  80195e:	83 c4 10             	add    $0x10,%esp
  801961:	85 c0                	test   %eax,%eax
  801963:	78 0f                	js     801974 <getchar+0x29>
		return r;
	if (r < 1)
  801965:	85 c0                	test   %eax,%eax
  801967:	7e 06                	jle    80196f <getchar+0x24>
		return -E_EOF;
	return c;
  801969:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80196d:	eb 05                	jmp    801974 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80196f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801974:	c9                   	leave  
  801975:	c3                   	ret    

00801976 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801976:	55                   	push   %ebp
  801977:	89 e5                	mov    %esp,%ebp
  801979:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80197c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80197f:	50                   	push   %eax
  801980:	ff 75 08             	pushl  0x8(%ebp)
  801983:	e8 00 f4 ff ff       	call   800d88 <fd_lookup>
  801988:	83 c4 10             	add    $0x10,%esp
  80198b:	85 c0                	test   %eax,%eax
  80198d:	78 11                	js     8019a0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80198f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801992:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801998:	39 10                	cmp    %edx,(%eax)
  80199a:	0f 94 c0             	sete   %al
  80199d:	0f b6 c0             	movzbl %al,%eax
}
  8019a0:	c9                   	leave  
  8019a1:	c3                   	ret    

008019a2 <opencons>:

int
opencons(void)
{
  8019a2:	55                   	push   %ebp
  8019a3:	89 e5                	mov    %esp,%ebp
  8019a5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ab:	50                   	push   %eax
  8019ac:	e8 88 f3 ff ff       	call   800d39 <fd_alloc>
  8019b1:	83 c4 10             	add    $0x10,%esp
		return r;
  8019b4:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019b6:	85 c0                	test   %eax,%eax
  8019b8:	78 3e                	js     8019f8 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019ba:	83 ec 04             	sub    $0x4,%esp
  8019bd:	68 07 04 00 00       	push   $0x407
  8019c2:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c5:	6a 00                	push   $0x0
  8019c7:	e8 55 f1 ff ff       	call   800b21 <sys_page_alloc>
  8019cc:	83 c4 10             	add    $0x10,%esp
		return r;
  8019cf:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019d1:	85 c0                	test   %eax,%eax
  8019d3:	78 23                	js     8019f8 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8019d5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019de:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019ea:	83 ec 0c             	sub    $0xc,%esp
  8019ed:	50                   	push   %eax
  8019ee:	e8 1f f3 ff ff       	call   800d12 <fd2num>
  8019f3:	89 c2                	mov    %eax,%edx
  8019f5:	83 c4 10             	add    $0x10,%esp
}
  8019f8:	89 d0                	mov    %edx,%eax
  8019fa:	c9                   	leave  
  8019fb:	c3                   	ret    

008019fc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	56                   	push   %esi
  801a00:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a01:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a04:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a0a:	e8 d4 f0 ff ff       	call   800ae3 <sys_getenvid>
  801a0f:	83 ec 0c             	sub    $0xc,%esp
  801a12:	ff 75 0c             	pushl  0xc(%ebp)
  801a15:	ff 75 08             	pushl  0x8(%ebp)
  801a18:	56                   	push   %esi
  801a19:	50                   	push   %eax
  801a1a:	68 78 22 80 00       	push   $0x802278
  801a1f:	e8 75 e7 ff ff       	call   800199 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a24:	83 c4 18             	add    $0x18,%esp
  801a27:	53                   	push   %ebx
  801a28:	ff 75 10             	pushl  0x10(%ebp)
  801a2b:	e8 18 e7 ff ff       	call   800148 <vcprintf>
	cprintf("\n");
  801a30:	c7 04 24 63 22 80 00 	movl   $0x802263,(%esp)
  801a37:	e8 5d e7 ff ff       	call   800199 <cprintf>
  801a3c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a3f:	cc                   	int3   
  801a40:	eb fd                	jmp    801a3f <_panic+0x43>

00801a42 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a42:	55                   	push   %ebp
  801a43:	89 e5                	mov    %esp,%ebp
  801a45:	56                   	push   %esi
  801a46:	53                   	push   %ebx
  801a47:	8b 75 08             	mov    0x8(%ebp),%esi
  801a4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801a50:	85 c0                	test   %eax,%eax
  801a52:	75 12                	jne    801a66 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801a54:	83 ec 0c             	sub    $0xc,%esp
  801a57:	68 00 00 c0 ee       	push   $0xeec00000
  801a5c:	e8 70 f2 ff ff       	call   800cd1 <sys_ipc_recv>
  801a61:	83 c4 10             	add    $0x10,%esp
  801a64:	eb 0c                	jmp    801a72 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801a66:	83 ec 0c             	sub    $0xc,%esp
  801a69:	50                   	push   %eax
  801a6a:	e8 62 f2 ff ff       	call   800cd1 <sys_ipc_recv>
  801a6f:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801a72:	85 f6                	test   %esi,%esi
  801a74:	0f 95 c1             	setne  %cl
  801a77:	85 db                	test   %ebx,%ebx
  801a79:	0f 95 c2             	setne  %dl
  801a7c:	84 d1                	test   %dl,%cl
  801a7e:	74 09                	je     801a89 <ipc_recv+0x47>
  801a80:	89 c2                	mov    %eax,%edx
  801a82:	c1 ea 1f             	shr    $0x1f,%edx
  801a85:	84 d2                	test   %dl,%dl
  801a87:	75 24                	jne    801aad <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801a89:	85 f6                	test   %esi,%esi
  801a8b:	74 0a                	je     801a97 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801a8d:	a1 04 40 80 00       	mov    0x804004,%eax
  801a92:	8b 40 74             	mov    0x74(%eax),%eax
  801a95:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801a97:	85 db                	test   %ebx,%ebx
  801a99:	74 0a                	je     801aa5 <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  801a9b:	a1 04 40 80 00       	mov    0x804004,%eax
  801aa0:	8b 40 78             	mov    0x78(%eax),%eax
  801aa3:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801aa5:	a1 04 40 80 00       	mov    0x804004,%eax
  801aaa:	8b 40 70             	mov    0x70(%eax),%eax
}
  801aad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab0:	5b                   	pop    %ebx
  801ab1:	5e                   	pop    %esi
  801ab2:	5d                   	pop    %ebp
  801ab3:	c3                   	ret    

00801ab4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ab4:	55                   	push   %ebp
  801ab5:	89 e5                	mov    %esp,%ebp
  801ab7:	57                   	push   %edi
  801ab8:	56                   	push   %esi
  801ab9:	53                   	push   %ebx
  801aba:	83 ec 0c             	sub    $0xc,%esp
  801abd:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ac0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ac3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801ac6:	85 db                	test   %ebx,%ebx
  801ac8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801acd:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801ad0:	ff 75 14             	pushl  0x14(%ebp)
  801ad3:	53                   	push   %ebx
  801ad4:	56                   	push   %esi
  801ad5:	57                   	push   %edi
  801ad6:	e8 d3 f1 ff ff       	call   800cae <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801adb:	89 c2                	mov    %eax,%edx
  801add:	c1 ea 1f             	shr    $0x1f,%edx
  801ae0:	83 c4 10             	add    $0x10,%esp
  801ae3:	84 d2                	test   %dl,%dl
  801ae5:	74 17                	je     801afe <ipc_send+0x4a>
  801ae7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aea:	74 12                	je     801afe <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801aec:	50                   	push   %eax
  801aed:	68 9c 22 80 00       	push   $0x80229c
  801af2:	6a 47                	push   $0x47
  801af4:	68 aa 22 80 00       	push   $0x8022aa
  801af9:	e8 fe fe ff ff       	call   8019fc <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801afe:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b01:	75 07                	jne    801b0a <ipc_send+0x56>
			sys_yield();
  801b03:	e8 fa ef ff ff       	call   800b02 <sys_yield>
  801b08:	eb c6                	jmp    801ad0 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801b0a:	85 c0                	test   %eax,%eax
  801b0c:	75 c2                	jne    801ad0 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801b0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b11:	5b                   	pop    %ebx
  801b12:	5e                   	pop    %esi
  801b13:	5f                   	pop    %edi
  801b14:	5d                   	pop    %ebp
  801b15:	c3                   	ret    

00801b16 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b16:	55                   	push   %ebp
  801b17:	89 e5                	mov    %esp,%ebp
  801b19:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b1c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b21:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b24:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b2a:	8b 52 50             	mov    0x50(%edx),%edx
  801b2d:	39 ca                	cmp    %ecx,%edx
  801b2f:	75 0d                	jne    801b3e <ipc_find_env+0x28>
			return envs[i].env_id;
  801b31:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b34:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b39:	8b 40 48             	mov    0x48(%eax),%eax
  801b3c:	eb 0f                	jmp    801b4d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b3e:	83 c0 01             	add    $0x1,%eax
  801b41:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b46:	75 d9                	jne    801b21 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b48:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b4d:	5d                   	pop    %ebp
  801b4e:	c3                   	ret    

00801b4f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b4f:	55                   	push   %ebp
  801b50:	89 e5                	mov    %esp,%ebp
  801b52:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b55:	89 d0                	mov    %edx,%eax
  801b57:	c1 e8 16             	shr    $0x16,%eax
  801b5a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b61:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b66:	f6 c1 01             	test   $0x1,%cl
  801b69:	74 1d                	je     801b88 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b6b:	c1 ea 0c             	shr    $0xc,%edx
  801b6e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b75:	f6 c2 01             	test   $0x1,%dl
  801b78:	74 0e                	je     801b88 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b7a:	c1 ea 0c             	shr    $0xc,%edx
  801b7d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b84:	ef 
  801b85:	0f b7 c0             	movzwl %ax,%eax
}
  801b88:	5d                   	pop    %ebp
  801b89:	c3                   	ret    
  801b8a:	66 90                	xchg   %ax,%ax
  801b8c:	66 90                	xchg   %ax,%ax
  801b8e:	66 90                	xchg   %ax,%ax

00801b90 <__udivdi3>:
  801b90:	55                   	push   %ebp
  801b91:	57                   	push   %edi
  801b92:	56                   	push   %esi
  801b93:	53                   	push   %ebx
  801b94:	83 ec 1c             	sub    $0x1c,%esp
  801b97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ba3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ba7:	85 f6                	test   %esi,%esi
  801ba9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bad:	89 ca                	mov    %ecx,%edx
  801baf:	89 f8                	mov    %edi,%eax
  801bb1:	75 3d                	jne    801bf0 <__udivdi3+0x60>
  801bb3:	39 cf                	cmp    %ecx,%edi
  801bb5:	0f 87 c5 00 00 00    	ja     801c80 <__udivdi3+0xf0>
  801bbb:	85 ff                	test   %edi,%edi
  801bbd:	89 fd                	mov    %edi,%ebp
  801bbf:	75 0b                	jne    801bcc <__udivdi3+0x3c>
  801bc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc6:	31 d2                	xor    %edx,%edx
  801bc8:	f7 f7                	div    %edi
  801bca:	89 c5                	mov    %eax,%ebp
  801bcc:	89 c8                	mov    %ecx,%eax
  801bce:	31 d2                	xor    %edx,%edx
  801bd0:	f7 f5                	div    %ebp
  801bd2:	89 c1                	mov    %eax,%ecx
  801bd4:	89 d8                	mov    %ebx,%eax
  801bd6:	89 cf                	mov    %ecx,%edi
  801bd8:	f7 f5                	div    %ebp
  801bda:	89 c3                	mov    %eax,%ebx
  801bdc:	89 d8                	mov    %ebx,%eax
  801bde:	89 fa                	mov    %edi,%edx
  801be0:	83 c4 1c             	add    $0x1c,%esp
  801be3:	5b                   	pop    %ebx
  801be4:	5e                   	pop    %esi
  801be5:	5f                   	pop    %edi
  801be6:	5d                   	pop    %ebp
  801be7:	c3                   	ret    
  801be8:	90                   	nop
  801be9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bf0:	39 ce                	cmp    %ecx,%esi
  801bf2:	77 74                	ja     801c68 <__udivdi3+0xd8>
  801bf4:	0f bd fe             	bsr    %esi,%edi
  801bf7:	83 f7 1f             	xor    $0x1f,%edi
  801bfa:	0f 84 98 00 00 00    	je     801c98 <__udivdi3+0x108>
  801c00:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c05:	89 f9                	mov    %edi,%ecx
  801c07:	89 c5                	mov    %eax,%ebp
  801c09:	29 fb                	sub    %edi,%ebx
  801c0b:	d3 e6                	shl    %cl,%esi
  801c0d:	89 d9                	mov    %ebx,%ecx
  801c0f:	d3 ed                	shr    %cl,%ebp
  801c11:	89 f9                	mov    %edi,%ecx
  801c13:	d3 e0                	shl    %cl,%eax
  801c15:	09 ee                	or     %ebp,%esi
  801c17:	89 d9                	mov    %ebx,%ecx
  801c19:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c1d:	89 d5                	mov    %edx,%ebp
  801c1f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c23:	d3 ed                	shr    %cl,%ebp
  801c25:	89 f9                	mov    %edi,%ecx
  801c27:	d3 e2                	shl    %cl,%edx
  801c29:	89 d9                	mov    %ebx,%ecx
  801c2b:	d3 e8                	shr    %cl,%eax
  801c2d:	09 c2                	or     %eax,%edx
  801c2f:	89 d0                	mov    %edx,%eax
  801c31:	89 ea                	mov    %ebp,%edx
  801c33:	f7 f6                	div    %esi
  801c35:	89 d5                	mov    %edx,%ebp
  801c37:	89 c3                	mov    %eax,%ebx
  801c39:	f7 64 24 0c          	mull   0xc(%esp)
  801c3d:	39 d5                	cmp    %edx,%ebp
  801c3f:	72 10                	jb     801c51 <__udivdi3+0xc1>
  801c41:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c45:	89 f9                	mov    %edi,%ecx
  801c47:	d3 e6                	shl    %cl,%esi
  801c49:	39 c6                	cmp    %eax,%esi
  801c4b:	73 07                	jae    801c54 <__udivdi3+0xc4>
  801c4d:	39 d5                	cmp    %edx,%ebp
  801c4f:	75 03                	jne    801c54 <__udivdi3+0xc4>
  801c51:	83 eb 01             	sub    $0x1,%ebx
  801c54:	31 ff                	xor    %edi,%edi
  801c56:	89 d8                	mov    %ebx,%eax
  801c58:	89 fa                	mov    %edi,%edx
  801c5a:	83 c4 1c             	add    $0x1c,%esp
  801c5d:	5b                   	pop    %ebx
  801c5e:	5e                   	pop    %esi
  801c5f:	5f                   	pop    %edi
  801c60:	5d                   	pop    %ebp
  801c61:	c3                   	ret    
  801c62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c68:	31 ff                	xor    %edi,%edi
  801c6a:	31 db                	xor    %ebx,%ebx
  801c6c:	89 d8                	mov    %ebx,%eax
  801c6e:	89 fa                	mov    %edi,%edx
  801c70:	83 c4 1c             	add    $0x1c,%esp
  801c73:	5b                   	pop    %ebx
  801c74:	5e                   	pop    %esi
  801c75:	5f                   	pop    %edi
  801c76:	5d                   	pop    %ebp
  801c77:	c3                   	ret    
  801c78:	90                   	nop
  801c79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c80:	89 d8                	mov    %ebx,%eax
  801c82:	f7 f7                	div    %edi
  801c84:	31 ff                	xor    %edi,%edi
  801c86:	89 c3                	mov    %eax,%ebx
  801c88:	89 d8                	mov    %ebx,%eax
  801c8a:	89 fa                	mov    %edi,%edx
  801c8c:	83 c4 1c             	add    $0x1c,%esp
  801c8f:	5b                   	pop    %ebx
  801c90:	5e                   	pop    %esi
  801c91:	5f                   	pop    %edi
  801c92:	5d                   	pop    %ebp
  801c93:	c3                   	ret    
  801c94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c98:	39 ce                	cmp    %ecx,%esi
  801c9a:	72 0c                	jb     801ca8 <__udivdi3+0x118>
  801c9c:	31 db                	xor    %ebx,%ebx
  801c9e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801ca2:	0f 87 34 ff ff ff    	ja     801bdc <__udivdi3+0x4c>
  801ca8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801cad:	e9 2a ff ff ff       	jmp    801bdc <__udivdi3+0x4c>
  801cb2:	66 90                	xchg   %ax,%ax
  801cb4:	66 90                	xchg   %ax,%ax
  801cb6:	66 90                	xchg   %ax,%ax
  801cb8:	66 90                	xchg   %ax,%ax
  801cba:	66 90                	xchg   %ax,%ax
  801cbc:	66 90                	xchg   %ax,%ax
  801cbe:	66 90                	xchg   %ax,%ax

00801cc0 <__umoddi3>:
  801cc0:	55                   	push   %ebp
  801cc1:	57                   	push   %edi
  801cc2:	56                   	push   %esi
  801cc3:	53                   	push   %ebx
  801cc4:	83 ec 1c             	sub    $0x1c,%esp
  801cc7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801ccb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801ccf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cd7:	85 d2                	test   %edx,%edx
  801cd9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801cdd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ce1:	89 f3                	mov    %esi,%ebx
  801ce3:	89 3c 24             	mov    %edi,(%esp)
  801ce6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cea:	75 1c                	jne    801d08 <__umoddi3+0x48>
  801cec:	39 f7                	cmp    %esi,%edi
  801cee:	76 50                	jbe    801d40 <__umoddi3+0x80>
  801cf0:	89 c8                	mov    %ecx,%eax
  801cf2:	89 f2                	mov    %esi,%edx
  801cf4:	f7 f7                	div    %edi
  801cf6:	89 d0                	mov    %edx,%eax
  801cf8:	31 d2                	xor    %edx,%edx
  801cfa:	83 c4 1c             	add    $0x1c,%esp
  801cfd:	5b                   	pop    %ebx
  801cfe:	5e                   	pop    %esi
  801cff:	5f                   	pop    %edi
  801d00:	5d                   	pop    %ebp
  801d01:	c3                   	ret    
  801d02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d08:	39 f2                	cmp    %esi,%edx
  801d0a:	89 d0                	mov    %edx,%eax
  801d0c:	77 52                	ja     801d60 <__umoddi3+0xa0>
  801d0e:	0f bd ea             	bsr    %edx,%ebp
  801d11:	83 f5 1f             	xor    $0x1f,%ebp
  801d14:	75 5a                	jne    801d70 <__umoddi3+0xb0>
  801d16:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d1a:	0f 82 e0 00 00 00    	jb     801e00 <__umoddi3+0x140>
  801d20:	39 0c 24             	cmp    %ecx,(%esp)
  801d23:	0f 86 d7 00 00 00    	jbe    801e00 <__umoddi3+0x140>
  801d29:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d2d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d31:	83 c4 1c             	add    $0x1c,%esp
  801d34:	5b                   	pop    %ebx
  801d35:	5e                   	pop    %esi
  801d36:	5f                   	pop    %edi
  801d37:	5d                   	pop    %ebp
  801d38:	c3                   	ret    
  801d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d40:	85 ff                	test   %edi,%edi
  801d42:	89 fd                	mov    %edi,%ebp
  801d44:	75 0b                	jne    801d51 <__umoddi3+0x91>
  801d46:	b8 01 00 00 00       	mov    $0x1,%eax
  801d4b:	31 d2                	xor    %edx,%edx
  801d4d:	f7 f7                	div    %edi
  801d4f:	89 c5                	mov    %eax,%ebp
  801d51:	89 f0                	mov    %esi,%eax
  801d53:	31 d2                	xor    %edx,%edx
  801d55:	f7 f5                	div    %ebp
  801d57:	89 c8                	mov    %ecx,%eax
  801d59:	f7 f5                	div    %ebp
  801d5b:	89 d0                	mov    %edx,%eax
  801d5d:	eb 99                	jmp    801cf8 <__umoddi3+0x38>
  801d5f:	90                   	nop
  801d60:	89 c8                	mov    %ecx,%eax
  801d62:	89 f2                	mov    %esi,%edx
  801d64:	83 c4 1c             	add    $0x1c,%esp
  801d67:	5b                   	pop    %ebx
  801d68:	5e                   	pop    %esi
  801d69:	5f                   	pop    %edi
  801d6a:	5d                   	pop    %ebp
  801d6b:	c3                   	ret    
  801d6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d70:	8b 34 24             	mov    (%esp),%esi
  801d73:	bf 20 00 00 00       	mov    $0x20,%edi
  801d78:	89 e9                	mov    %ebp,%ecx
  801d7a:	29 ef                	sub    %ebp,%edi
  801d7c:	d3 e0                	shl    %cl,%eax
  801d7e:	89 f9                	mov    %edi,%ecx
  801d80:	89 f2                	mov    %esi,%edx
  801d82:	d3 ea                	shr    %cl,%edx
  801d84:	89 e9                	mov    %ebp,%ecx
  801d86:	09 c2                	or     %eax,%edx
  801d88:	89 d8                	mov    %ebx,%eax
  801d8a:	89 14 24             	mov    %edx,(%esp)
  801d8d:	89 f2                	mov    %esi,%edx
  801d8f:	d3 e2                	shl    %cl,%edx
  801d91:	89 f9                	mov    %edi,%ecx
  801d93:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d97:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d9b:	d3 e8                	shr    %cl,%eax
  801d9d:	89 e9                	mov    %ebp,%ecx
  801d9f:	89 c6                	mov    %eax,%esi
  801da1:	d3 e3                	shl    %cl,%ebx
  801da3:	89 f9                	mov    %edi,%ecx
  801da5:	89 d0                	mov    %edx,%eax
  801da7:	d3 e8                	shr    %cl,%eax
  801da9:	89 e9                	mov    %ebp,%ecx
  801dab:	09 d8                	or     %ebx,%eax
  801dad:	89 d3                	mov    %edx,%ebx
  801daf:	89 f2                	mov    %esi,%edx
  801db1:	f7 34 24             	divl   (%esp)
  801db4:	89 d6                	mov    %edx,%esi
  801db6:	d3 e3                	shl    %cl,%ebx
  801db8:	f7 64 24 04          	mull   0x4(%esp)
  801dbc:	39 d6                	cmp    %edx,%esi
  801dbe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dc2:	89 d1                	mov    %edx,%ecx
  801dc4:	89 c3                	mov    %eax,%ebx
  801dc6:	72 08                	jb     801dd0 <__umoddi3+0x110>
  801dc8:	75 11                	jne    801ddb <__umoddi3+0x11b>
  801dca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dce:	73 0b                	jae    801ddb <__umoddi3+0x11b>
  801dd0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801dd4:	1b 14 24             	sbb    (%esp),%edx
  801dd7:	89 d1                	mov    %edx,%ecx
  801dd9:	89 c3                	mov    %eax,%ebx
  801ddb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801ddf:	29 da                	sub    %ebx,%edx
  801de1:	19 ce                	sbb    %ecx,%esi
  801de3:	89 f9                	mov    %edi,%ecx
  801de5:	89 f0                	mov    %esi,%eax
  801de7:	d3 e0                	shl    %cl,%eax
  801de9:	89 e9                	mov    %ebp,%ecx
  801deb:	d3 ea                	shr    %cl,%edx
  801ded:	89 e9                	mov    %ebp,%ecx
  801def:	d3 ee                	shr    %cl,%esi
  801df1:	09 d0                	or     %edx,%eax
  801df3:	89 f2                	mov    %esi,%edx
  801df5:	83 c4 1c             	add    $0x1c,%esp
  801df8:	5b                   	pop    %ebx
  801df9:	5e                   	pop    %esi
  801dfa:	5f                   	pop    %edi
  801dfb:	5d                   	pop    %ebp
  801dfc:	c3                   	ret    
  801dfd:	8d 76 00             	lea    0x0(%esi),%esi
  801e00:	29 f9                	sub    %edi,%ecx
  801e02:	19 d6                	sbb    %edx,%esi
  801e04:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e08:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e0c:	e9 18 ff ff ff       	jmp    801d29 <__umoddi3+0x69>
