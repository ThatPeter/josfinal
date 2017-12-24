
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
  80003f:	68 20 1e 80 00       	push   $0x801e20
  800044:	e8 40 01 00 00       	call   800189 <cprintf>
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
  800061:	e8 6d 0a 00 00       	call   800ad3 <sys_getenvid>
  800066:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  80006c:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  800071:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800076:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  80007b:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  80007e:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  800084:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  800087:	39 c8                	cmp    %ecx,%eax
  800089:	0f 44 fb             	cmove  %ebx,%edi
  80008c:	b9 01 00 00 00       	mov    $0x1,%ecx
  800091:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  800094:	83 c2 01             	add    $0x1,%edx
  800097:	83 c3 7c             	add    $0x7c,%ebx
  80009a:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  8000a0:	75 d9                	jne    80007b <libmain+0x2d>
  8000a2:	89 f0                	mov    %esi,%eax
  8000a4:	84 c0                	test   %al,%al
  8000a6:	74 06                	je     8000ae <libmain+0x60>
  8000a8:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ae:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000b2:	7e 0a                	jle    8000be <libmain+0x70>
		binaryname = argv[0];
  8000b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000b7:	8b 00                	mov    (%eax),%eax
  8000b9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000be:	83 ec 08             	sub    $0x8,%esp
  8000c1:	ff 75 0c             	pushl  0xc(%ebp)
  8000c4:	ff 75 08             	pushl  0x8(%ebp)
  8000c7:	e8 67 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000cc:	e8 0b 00 00 00       	call   8000dc <exit>
}
  8000d1:	83 c4 10             	add    $0x10,%esp
  8000d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d7:	5b                   	pop    %ebx
  8000d8:	5e                   	pop    %esi
  8000d9:	5f                   	pop    %edi
  8000da:	5d                   	pop    %ebp
  8000db:	c3                   	ret    

008000dc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000e2:	e8 e6 0d 00 00       	call   800ecd <close_all>
	sys_env_destroy(0);
  8000e7:	83 ec 0c             	sub    $0xc,%esp
  8000ea:	6a 00                	push   $0x0
  8000ec:	e8 a1 09 00 00       	call   800a92 <sys_env_destroy>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	c9                   	leave  
  8000f5:	c3                   	ret    

008000f6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f6:	55                   	push   %ebp
  8000f7:	89 e5                	mov    %esp,%ebp
  8000f9:	53                   	push   %ebx
  8000fa:	83 ec 04             	sub    $0x4,%esp
  8000fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800100:	8b 13                	mov    (%ebx),%edx
  800102:	8d 42 01             	lea    0x1(%edx),%eax
  800105:	89 03                	mov    %eax,(%ebx)
  800107:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80010e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800113:	75 1a                	jne    80012f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800115:	83 ec 08             	sub    $0x8,%esp
  800118:	68 ff 00 00 00       	push   $0xff
  80011d:	8d 43 08             	lea    0x8(%ebx),%eax
  800120:	50                   	push   %eax
  800121:	e8 2f 09 00 00       	call   800a55 <sys_cputs>
		b->idx = 0;
  800126:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80012c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80012f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800133:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800136:	c9                   	leave  
  800137:	c3                   	ret    

00800138 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800141:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800148:	00 00 00 
	b.cnt = 0;
  80014b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800152:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800155:	ff 75 0c             	pushl  0xc(%ebp)
  800158:	ff 75 08             	pushl  0x8(%ebp)
  80015b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800161:	50                   	push   %eax
  800162:	68 f6 00 80 00       	push   $0x8000f6
  800167:	e8 54 01 00 00       	call   8002c0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80016c:	83 c4 08             	add    $0x8,%esp
  80016f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800175:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017b:	50                   	push   %eax
  80017c:	e8 d4 08 00 00       	call   800a55 <sys_cputs>

	return b.cnt;
}
  800181:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800187:	c9                   	leave  
  800188:	c3                   	ret    

00800189 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80018f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800192:	50                   	push   %eax
  800193:	ff 75 08             	pushl  0x8(%ebp)
  800196:	e8 9d ff ff ff       	call   800138 <vcprintf>
	va_end(ap);

	return cnt;
}
  80019b:	c9                   	leave  
  80019c:	c3                   	ret    

0080019d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	57                   	push   %edi
  8001a1:	56                   	push   %esi
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 1c             	sub    $0x1c,%esp
  8001a6:	89 c7                	mov    %eax,%edi
  8001a8:	89 d6                	mov    %edx,%esi
  8001aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001b3:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001b9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001be:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001c1:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001c4:	39 d3                	cmp    %edx,%ebx
  8001c6:	72 05                	jb     8001cd <printnum+0x30>
  8001c8:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001cb:	77 45                	ja     800212 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001cd:	83 ec 0c             	sub    $0xc,%esp
  8001d0:	ff 75 18             	pushl  0x18(%ebp)
  8001d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8001d6:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001d9:	53                   	push   %ebx
  8001da:	ff 75 10             	pushl  0x10(%ebp)
  8001dd:	83 ec 08             	sub    $0x8,%esp
  8001e0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e3:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e6:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e9:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ec:	e8 8f 19 00 00       	call   801b80 <__udivdi3>
  8001f1:	83 c4 18             	add    $0x18,%esp
  8001f4:	52                   	push   %edx
  8001f5:	50                   	push   %eax
  8001f6:	89 f2                	mov    %esi,%edx
  8001f8:	89 f8                	mov    %edi,%eax
  8001fa:	e8 9e ff ff ff       	call   80019d <printnum>
  8001ff:	83 c4 20             	add    $0x20,%esp
  800202:	eb 18                	jmp    80021c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800204:	83 ec 08             	sub    $0x8,%esp
  800207:	56                   	push   %esi
  800208:	ff 75 18             	pushl  0x18(%ebp)
  80020b:	ff d7                	call   *%edi
  80020d:	83 c4 10             	add    $0x10,%esp
  800210:	eb 03                	jmp    800215 <printnum+0x78>
  800212:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800215:	83 eb 01             	sub    $0x1,%ebx
  800218:	85 db                	test   %ebx,%ebx
  80021a:	7f e8                	jg     800204 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80021c:	83 ec 08             	sub    $0x8,%esp
  80021f:	56                   	push   %esi
  800220:	83 ec 04             	sub    $0x4,%esp
  800223:	ff 75 e4             	pushl  -0x1c(%ebp)
  800226:	ff 75 e0             	pushl  -0x20(%ebp)
  800229:	ff 75 dc             	pushl  -0x24(%ebp)
  80022c:	ff 75 d8             	pushl  -0x28(%ebp)
  80022f:	e8 7c 1a 00 00       	call   801cb0 <__umoddi3>
  800234:	83 c4 14             	add    $0x14,%esp
  800237:	0f be 80 51 1e 80 00 	movsbl 0x801e51(%eax),%eax
  80023e:	50                   	push   %eax
  80023f:	ff d7                	call   *%edi
}
  800241:	83 c4 10             	add    $0x10,%esp
  800244:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800247:	5b                   	pop    %ebx
  800248:	5e                   	pop    %esi
  800249:	5f                   	pop    %edi
  80024a:	5d                   	pop    %ebp
  80024b:	c3                   	ret    

0080024c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80024f:	83 fa 01             	cmp    $0x1,%edx
  800252:	7e 0e                	jle    800262 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800254:	8b 10                	mov    (%eax),%edx
  800256:	8d 4a 08             	lea    0x8(%edx),%ecx
  800259:	89 08                	mov    %ecx,(%eax)
  80025b:	8b 02                	mov    (%edx),%eax
  80025d:	8b 52 04             	mov    0x4(%edx),%edx
  800260:	eb 22                	jmp    800284 <getuint+0x38>
	else if (lflag)
  800262:	85 d2                	test   %edx,%edx
  800264:	74 10                	je     800276 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800266:	8b 10                	mov    (%eax),%edx
  800268:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026b:	89 08                	mov    %ecx,(%eax)
  80026d:	8b 02                	mov    (%edx),%eax
  80026f:	ba 00 00 00 00       	mov    $0x0,%edx
  800274:	eb 0e                	jmp    800284 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800276:	8b 10                	mov    (%eax),%edx
  800278:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027b:	89 08                	mov    %ecx,(%eax)
  80027d:	8b 02                	mov    (%edx),%eax
  80027f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800284:	5d                   	pop    %ebp
  800285:	c3                   	ret    

00800286 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800286:	55                   	push   %ebp
  800287:	89 e5                	mov    %esp,%ebp
  800289:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80028c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800290:	8b 10                	mov    (%eax),%edx
  800292:	3b 50 04             	cmp    0x4(%eax),%edx
  800295:	73 0a                	jae    8002a1 <sprintputch+0x1b>
		*b->buf++ = ch;
  800297:	8d 4a 01             	lea    0x1(%edx),%ecx
  80029a:	89 08                	mov    %ecx,(%eax)
  80029c:	8b 45 08             	mov    0x8(%ebp),%eax
  80029f:	88 02                	mov    %al,(%edx)
}
  8002a1:	5d                   	pop    %ebp
  8002a2:	c3                   	ret    

008002a3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002a3:	55                   	push   %ebp
  8002a4:	89 e5                	mov    %esp,%ebp
  8002a6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002a9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ac:	50                   	push   %eax
  8002ad:	ff 75 10             	pushl  0x10(%ebp)
  8002b0:	ff 75 0c             	pushl  0xc(%ebp)
  8002b3:	ff 75 08             	pushl  0x8(%ebp)
  8002b6:	e8 05 00 00 00       	call   8002c0 <vprintfmt>
	va_end(ap);
}
  8002bb:	83 c4 10             	add    $0x10,%esp
  8002be:	c9                   	leave  
  8002bf:	c3                   	ret    

008002c0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	57                   	push   %edi
  8002c4:	56                   	push   %esi
  8002c5:	53                   	push   %ebx
  8002c6:	83 ec 2c             	sub    $0x2c,%esp
  8002c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8002cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002cf:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002d2:	eb 12                	jmp    8002e6 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002d4:	85 c0                	test   %eax,%eax
  8002d6:	0f 84 89 03 00 00    	je     800665 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002dc:	83 ec 08             	sub    $0x8,%esp
  8002df:	53                   	push   %ebx
  8002e0:	50                   	push   %eax
  8002e1:	ff d6                	call   *%esi
  8002e3:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002e6:	83 c7 01             	add    $0x1,%edi
  8002e9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002ed:	83 f8 25             	cmp    $0x25,%eax
  8002f0:	75 e2                	jne    8002d4 <vprintfmt+0x14>
  8002f2:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002f6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002fd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800304:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80030b:	ba 00 00 00 00       	mov    $0x0,%edx
  800310:	eb 07                	jmp    800319 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800312:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800315:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800319:	8d 47 01             	lea    0x1(%edi),%eax
  80031c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80031f:	0f b6 07             	movzbl (%edi),%eax
  800322:	0f b6 c8             	movzbl %al,%ecx
  800325:	83 e8 23             	sub    $0x23,%eax
  800328:	3c 55                	cmp    $0x55,%al
  80032a:	0f 87 1a 03 00 00    	ja     80064a <vprintfmt+0x38a>
  800330:	0f b6 c0             	movzbl %al,%eax
  800333:	ff 24 85 a0 1f 80 00 	jmp    *0x801fa0(,%eax,4)
  80033a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80033d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800341:	eb d6                	jmp    800319 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800343:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800346:	b8 00 00 00 00       	mov    $0x0,%eax
  80034b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80034e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800351:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800355:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800358:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80035b:	83 fa 09             	cmp    $0x9,%edx
  80035e:	77 39                	ja     800399 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800360:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800363:	eb e9                	jmp    80034e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800365:	8b 45 14             	mov    0x14(%ebp),%eax
  800368:	8d 48 04             	lea    0x4(%eax),%ecx
  80036b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80036e:	8b 00                	mov    (%eax),%eax
  800370:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800373:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800376:	eb 27                	jmp    80039f <vprintfmt+0xdf>
  800378:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80037b:	85 c0                	test   %eax,%eax
  80037d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800382:	0f 49 c8             	cmovns %eax,%ecx
  800385:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800388:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80038b:	eb 8c                	jmp    800319 <vprintfmt+0x59>
  80038d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800390:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800397:	eb 80                	jmp    800319 <vprintfmt+0x59>
  800399:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80039c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80039f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a3:	0f 89 70 ff ff ff    	jns    800319 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003a9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003af:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003b6:	e9 5e ff ff ff       	jmp    800319 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003bb:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003c1:	e9 53 ff ff ff       	jmp    800319 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c9:	8d 50 04             	lea    0x4(%eax),%edx
  8003cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8003cf:	83 ec 08             	sub    $0x8,%esp
  8003d2:	53                   	push   %ebx
  8003d3:	ff 30                	pushl  (%eax)
  8003d5:	ff d6                	call   *%esi
			break;
  8003d7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003dd:	e9 04 ff ff ff       	jmp    8002e6 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e5:	8d 50 04             	lea    0x4(%eax),%edx
  8003e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003eb:	8b 00                	mov    (%eax),%eax
  8003ed:	99                   	cltd   
  8003ee:	31 d0                	xor    %edx,%eax
  8003f0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003f2:	83 f8 0f             	cmp    $0xf,%eax
  8003f5:	7f 0b                	jg     800402 <vprintfmt+0x142>
  8003f7:	8b 14 85 00 21 80 00 	mov    0x802100(,%eax,4),%edx
  8003fe:	85 d2                	test   %edx,%edx
  800400:	75 18                	jne    80041a <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800402:	50                   	push   %eax
  800403:	68 69 1e 80 00       	push   $0x801e69
  800408:	53                   	push   %ebx
  800409:	56                   	push   %esi
  80040a:	e8 94 fe ff ff       	call   8002a3 <printfmt>
  80040f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800412:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800415:	e9 cc fe ff ff       	jmp    8002e6 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80041a:	52                   	push   %edx
  80041b:	68 31 22 80 00       	push   $0x802231
  800420:	53                   	push   %ebx
  800421:	56                   	push   %esi
  800422:	e8 7c fe ff ff       	call   8002a3 <printfmt>
  800427:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80042d:	e9 b4 fe ff ff       	jmp    8002e6 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800432:	8b 45 14             	mov    0x14(%ebp),%eax
  800435:	8d 50 04             	lea    0x4(%eax),%edx
  800438:	89 55 14             	mov    %edx,0x14(%ebp)
  80043b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80043d:	85 ff                	test   %edi,%edi
  80043f:	b8 62 1e 80 00       	mov    $0x801e62,%eax
  800444:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800447:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80044b:	0f 8e 94 00 00 00    	jle    8004e5 <vprintfmt+0x225>
  800451:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800455:	0f 84 98 00 00 00    	je     8004f3 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80045b:	83 ec 08             	sub    $0x8,%esp
  80045e:	ff 75 d0             	pushl  -0x30(%ebp)
  800461:	57                   	push   %edi
  800462:	e8 86 02 00 00       	call   8006ed <strnlen>
  800467:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80046a:	29 c1                	sub    %eax,%ecx
  80046c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80046f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800472:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800476:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800479:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80047c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80047e:	eb 0f                	jmp    80048f <vprintfmt+0x1cf>
					putch(padc, putdat);
  800480:	83 ec 08             	sub    $0x8,%esp
  800483:	53                   	push   %ebx
  800484:	ff 75 e0             	pushl  -0x20(%ebp)
  800487:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800489:	83 ef 01             	sub    $0x1,%edi
  80048c:	83 c4 10             	add    $0x10,%esp
  80048f:	85 ff                	test   %edi,%edi
  800491:	7f ed                	jg     800480 <vprintfmt+0x1c0>
  800493:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800496:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800499:	85 c9                	test   %ecx,%ecx
  80049b:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a0:	0f 49 c1             	cmovns %ecx,%eax
  8004a3:	29 c1                	sub    %eax,%ecx
  8004a5:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ab:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ae:	89 cb                	mov    %ecx,%ebx
  8004b0:	eb 4d                	jmp    8004ff <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004b2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b6:	74 1b                	je     8004d3 <vprintfmt+0x213>
  8004b8:	0f be c0             	movsbl %al,%eax
  8004bb:	83 e8 20             	sub    $0x20,%eax
  8004be:	83 f8 5e             	cmp    $0x5e,%eax
  8004c1:	76 10                	jbe    8004d3 <vprintfmt+0x213>
					putch('?', putdat);
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	ff 75 0c             	pushl  0xc(%ebp)
  8004c9:	6a 3f                	push   $0x3f
  8004cb:	ff 55 08             	call   *0x8(%ebp)
  8004ce:	83 c4 10             	add    $0x10,%esp
  8004d1:	eb 0d                	jmp    8004e0 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004d3:	83 ec 08             	sub    $0x8,%esp
  8004d6:	ff 75 0c             	pushl  0xc(%ebp)
  8004d9:	52                   	push   %edx
  8004da:	ff 55 08             	call   *0x8(%ebp)
  8004dd:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e0:	83 eb 01             	sub    $0x1,%ebx
  8004e3:	eb 1a                	jmp    8004ff <vprintfmt+0x23f>
  8004e5:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004eb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ee:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f1:	eb 0c                	jmp    8004ff <vprintfmt+0x23f>
  8004f3:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004fc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ff:	83 c7 01             	add    $0x1,%edi
  800502:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800506:	0f be d0             	movsbl %al,%edx
  800509:	85 d2                	test   %edx,%edx
  80050b:	74 23                	je     800530 <vprintfmt+0x270>
  80050d:	85 f6                	test   %esi,%esi
  80050f:	78 a1                	js     8004b2 <vprintfmt+0x1f2>
  800511:	83 ee 01             	sub    $0x1,%esi
  800514:	79 9c                	jns    8004b2 <vprintfmt+0x1f2>
  800516:	89 df                	mov    %ebx,%edi
  800518:	8b 75 08             	mov    0x8(%ebp),%esi
  80051b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80051e:	eb 18                	jmp    800538 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800520:	83 ec 08             	sub    $0x8,%esp
  800523:	53                   	push   %ebx
  800524:	6a 20                	push   $0x20
  800526:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800528:	83 ef 01             	sub    $0x1,%edi
  80052b:	83 c4 10             	add    $0x10,%esp
  80052e:	eb 08                	jmp    800538 <vprintfmt+0x278>
  800530:	89 df                	mov    %ebx,%edi
  800532:	8b 75 08             	mov    0x8(%ebp),%esi
  800535:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800538:	85 ff                	test   %edi,%edi
  80053a:	7f e4                	jg     800520 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80053f:	e9 a2 fd ff ff       	jmp    8002e6 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800544:	83 fa 01             	cmp    $0x1,%edx
  800547:	7e 16                	jle    80055f <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800549:	8b 45 14             	mov    0x14(%ebp),%eax
  80054c:	8d 50 08             	lea    0x8(%eax),%edx
  80054f:	89 55 14             	mov    %edx,0x14(%ebp)
  800552:	8b 50 04             	mov    0x4(%eax),%edx
  800555:	8b 00                	mov    (%eax),%eax
  800557:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80055d:	eb 32                	jmp    800591 <vprintfmt+0x2d1>
	else if (lflag)
  80055f:	85 d2                	test   %edx,%edx
  800561:	74 18                	je     80057b <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800563:	8b 45 14             	mov    0x14(%ebp),%eax
  800566:	8d 50 04             	lea    0x4(%eax),%edx
  800569:	89 55 14             	mov    %edx,0x14(%ebp)
  80056c:	8b 00                	mov    (%eax),%eax
  80056e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800571:	89 c1                	mov    %eax,%ecx
  800573:	c1 f9 1f             	sar    $0x1f,%ecx
  800576:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800579:	eb 16                	jmp    800591 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80057b:	8b 45 14             	mov    0x14(%ebp),%eax
  80057e:	8d 50 04             	lea    0x4(%eax),%edx
  800581:	89 55 14             	mov    %edx,0x14(%ebp)
  800584:	8b 00                	mov    (%eax),%eax
  800586:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800589:	89 c1                	mov    %eax,%ecx
  80058b:	c1 f9 1f             	sar    $0x1f,%ecx
  80058e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800591:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800594:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800597:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80059c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005a0:	79 74                	jns    800616 <vprintfmt+0x356>
				putch('-', putdat);
  8005a2:	83 ec 08             	sub    $0x8,%esp
  8005a5:	53                   	push   %ebx
  8005a6:	6a 2d                	push   $0x2d
  8005a8:	ff d6                	call   *%esi
				num = -(long long) num;
  8005aa:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005ad:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005b0:	f7 d8                	neg    %eax
  8005b2:	83 d2 00             	adc    $0x0,%edx
  8005b5:	f7 da                	neg    %edx
  8005b7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005ba:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005bf:	eb 55                	jmp    800616 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005c1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c4:	e8 83 fc ff ff       	call   80024c <getuint>
			base = 10;
  8005c9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005ce:	eb 46                	jmp    800616 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005d0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d3:	e8 74 fc ff ff       	call   80024c <getuint>
			base = 8;
  8005d8:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005dd:	eb 37                	jmp    800616 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005df:	83 ec 08             	sub    $0x8,%esp
  8005e2:	53                   	push   %ebx
  8005e3:	6a 30                	push   $0x30
  8005e5:	ff d6                	call   *%esi
			putch('x', putdat);
  8005e7:	83 c4 08             	add    $0x8,%esp
  8005ea:	53                   	push   %ebx
  8005eb:	6a 78                	push   $0x78
  8005ed:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8d 50 04             	lea    0x4(%eax),%edx
  8005f5:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005f8:	8b 00                	mov    (%eax),%eax
  8005fa:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005ff:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800602:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800607:	eb 0d                	jmp    800616 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800609:	8d 45 14             	lea    0x14(%ebp),%eax
  80060c:	e8 3b fc ff ff       	call   80024c <getuint>
			base = 16;
  800611:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800616:	83 ec 0c             	sub    $0xc,%esp
  800619:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80061d:	57                   	push   %edi
  80061e:	ff 75 e0             	pushl  -0x20(%ebp)
  800621:	51                   	push   %ecx
  800622:	52                   	push   %edx
  800623:	50                   	push   %eax
  800624:	89 da                	mov    %ebx,%edx
  800626:	89 f0                	mov    %esi,%eax
  800628:	e8 70 fb ff ff       	call   80019d <printnum>
			break;
  80062d:	83 c4 20             	add    $0x20,%esp
  800630:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800633:	e9 ae fc ff ff       	jmp    8002e6 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800638:	83 ec 08             	sub    $0x8,%esp
  80063b:	53                   	push   %ebx
  80063c:	51                   	push   %ecx
  80063d:	ff d6                	call   *%esi
			break;
  80063f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800642:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800645:	e9 9c fc ff ff       	jmp    8002e6 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80064a:	83 ec 08             	sub    $0x8,%esp
  80064d:	53                   	push   %ebx
  80064e:	6a 25                	push   $0x25
  800650:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800652:	83 c4 10             	add    $0x10,%esp
  800655:	eb 03                	jmp    80065a <vprintfmt+0x39a>
  800657:	83 ef 01             	sub    $0x1,%edi
  80065a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80065e:	75 f7                	jne    800657 <vprintfmt+0x397>
  800660:	e9 81 fc ff ff       	jmp    8002e6 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800665:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800668:	5b                   	pop    %ebx
  800669:	5e                   	pop    %esi
  80066a:	5f                   	pop    %edi
  80066b:	5d                   	pop    %ebp
  80066c:	c3                   	ret    

0080066d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80066d:	55                   	push   %ebp
  80066e:	89 e5                	mov    %esp,%ebp
  800670:	83 ec 18             	sub    $0x18,%esp
  800673:	8b 45 08             	mov    0x8(%ebp),%eax
  800676:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800679:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80067c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800680:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800683:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80068a:	85 c0                	test   %eax,%eax
  80068c:	74 26                	je     8006b4 <vsnprintf+0x47>
  80068e:	85 d2                	test   %edx,%edx
  800690:	7e 22                	jle    8006b4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800692:	ff 75 14             	pushl  0x14(%ebp)
  800695:	ff 75 10             	pushl  0x10(%ebp)
  800698:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80069b:	50                   	push   %eax
  80069c:	68 86 02 80 00       	push   $0x800286
  8006a1:	e8 1a fc ff ff       	call   8002c0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006a9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006af:	83 c4 10             	add    $0x10,%esp
  8006b2:	eb 05                	jmp    8006b9 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006b9:	c9                   	leave  
  8006ba:	c3                   	ret    

008006bb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006bb:	55                   	push   %ebp
  8006bc:	89 e5                	mov    %esp,%ebp
  8006be:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006c1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006c4:	50                   	push   %eax
  8006c5:	ff 75 10             	pushl  0x10(%ebp)
  8006c8:	ff 75 0c             	pushl  0xc(%ebp)
  8006cb:	ff 75 08             	pushl  0x8(%ebp)
  8006ce:	e8 9a ff ff ff       	call   80066d <vsnprintf>
	va_end(ap);

	return rc;
}
  8006d3:	c9                   	leave  
  8006d4:	c3                   	ret    

008006d5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006d5:	55                   	push   %ebp
  8006d6:	89 e5                	mov    %esp,%ebp
  8006d8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006db:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e0:	eb 03                	jmp    8006e5 <strlen+0x10>
		n++;
  8006e2:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006e9:	75 f7                	jne    8006e2 <strlen+0xd>
		n++;
	return n;
}
  8006eb:	5d                   	pop    %ebp
  8006ec:	c3                   	ret    

008006ed <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006ed:	55                   	push   %ebp
  8006ee:	89 e5                	mov    %esp,%ebp
  8006f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006f3:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8006fb:	eb 03                	jmp    800700 <strnlen+0x13>
		n++;
  8006fd:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800700:	39 c2                	cmp    %eax,%edx
  800702:	74 08                	je     80070c <strnlen+0x1f>
  800704:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800708:	75 f3                	jne    8006fd <strnlen+0x10>
  80070a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80070c:	5d                   	pop    %ebp
  80070d:	c3                   	ret    

0080070e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80070e:	55                   	push   %ebp
  80070f:	89 e5                	mov    %esp,%ebp
  800711:	53                   	push   %ebx
  800712:	8b 45 08             	mov    0x8(%ebp),%eax
  800715:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800718:	89 c2                	mov    %eax,%edx
  80071a:	83 c2 01             	add    $0x1,%edx
  80071d:	83 c1 01             	add    $0x1,%ecx
  800720:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800724:	88 5a ff             	mov    %bl,-0x1(%edx)
  800727:	84 db                	test   %bl,%bl
  800729:	75 ef                	jne    80071a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80072b:	5b                   	pop    %ebx
  80072c:	5d                   	pop    %ebp
  80072d:	c3                   	ret    

0080072e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80072e:	55                   	push   %ebp
  80072f:	89 e5                	mov    %esp,%ebp
  800731:	53                   	push   %ebx
  800732:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800735:	53                   	push   %ebx
  800736:	e8 9a ff ff ff       	call   8006d5 <strlen>
  80073b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80073e:	ff 75 0c             	pushl  0xc(%ebp)
  800741:	01 d8                	add    %ebx,%eax
  800743:	50                   	push   %eax
  800744:	e8 c5 ff ff ff       	call   80070e <strcpy>
	return dst;
}
  800749:	89 d8                	mov    %ebx,%eax
  80074b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80074e:	c9                   	leave  
  80074f:	c3                   	ret    

00800750 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	56                   	push   %esi
  800754:	53                   	push   %ebx
  800755:	8b 75 08             	mov    0x8(%ebp),%esi
  800758:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80075b:	89 f3                	mov    %esi,%ebx
  80075d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800760:	89 f2                	mov    %esi,%edx
  800762:	eb 0f                	jmp    800773 <strncpy+0x23>
		*dst++ = *src;
  800764:	83 c2 01             	add    $0x1,%edx
  800767:	0f b6 01             	movzbl (%ecx),%eax
  80076a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80076d:	80 39 01             	cmpb   $0x1,(%ecx)
  800770:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800773:	39 da                	cmp    %ebx,%edx
  800775:	75 ed                	jne    800764 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800777:	89 f0                	mov    %esi,%eax
  800779:	5b                   	pop    %ebx
  80077a:	5e                   	pop    %esi
  80077b:	5d                   	pop    %ebp
  80077c:	c3                   	ret    

0080077d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	56                   	push   %esi
  800781:	53                   	push   %ebx
  800782:	8b 75 08             	mov    0x8(%ebp),%esi
  800785:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800788:	8b 55 10             	mov    0x10(%ebp),%edx
  80078b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80078d:	85 d2                	test   %edx,%edx
  80078f:	74 21                	je     8007b2 <strlcpy+0x35>
  800791:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800795:	89 f2                	mov    %esi,%edx
  800797:	eb 09                	jmp    8007a2 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800799:	83 c2 01             	add    $0x1,%edx
  80079c:	83 c1 01             	add    $0x1,%ecx
  80079f:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007a2:	39 c2                	cmp    %eax,%edx
  8007a4:	74 09                	je     8007af <strlcpy+0x32>
  8007a6:	0f b6 19             	movzbl (%ecx),%ebx
  8007a9:	84 db                	test   %bl,%bl
  8007ab:	75 ec                	jne    800799 <strlcpy+0x1c>
  8007ad:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007af:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007b2:	29 f0                	sub    %esi,%eax
}
  8007b4:	5b                   	pop    %ebx
  8007b5:	5e                   	pop    %esi
  8007b6:	5d                   	pop    %ebp
  8007b7:	c3                   	ret    

008007b8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007be:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007c1:	eb 06                	jmp    8007c9 <strcmp+0x11>
		p++, q++;
  8007c3:	83 c1 01             	add    $0x1,%ecx
  8007c6:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007c9:	0f b6 01             	movzbl (%ecx),%eax
  8007cc:	84 c0                	test   %al,%al
  8007ce:	74 04                	je     8007d4 <strcmp+0x1c>
  8007d0:	3a 02                	cmp    (%edx),%al
  8007d2:	74 ef                	je     8007c3 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d4:	0f b6 c0             	movzbl %al,%eax
  8007d7:	0f b6 12             	movzbl (%edx),%edx
  8007da:	29 d0                	sub    %edx,%eax
}
  8007dc:	5d                   	pop    %ebp
  8007dd:	c3                   	ret    

008007de <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	53                   	push   %ebx
  8007e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e8:	89 c3                	mov    %eax,%ebx
  8007ea:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007ed:	eb 06                	jmp    8007f5 <strncmp+0x17>
		n--, p++, q++;
  8007ef:	83 c0 01             	add    $0x1,%eax
  8007f2:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007f5:	39 d8                	cmp    %ebx,%eax
  8007f7:	74 15                	je     80080e <strncmp+0x30>
  8007f9:	0f b6 08             	movzbl (%eax),%ecx
  8007fc:	84 c9                	test   %cl,%cl
  8007fe:	74 04                	je     800804 <strncmp+0x26>
  800800:	3a 0a                	cmp    (%edx),%cl
  800802:	74 eb                	je     8007ef <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800804:	0f b6 00             	movzbl (%eax),%eax
  800807:	0f b6 12             	movzbl (%edx),%edx
  80080a:	29 d0                	sub    %edx,%eax
  80080c:	eb 05                	jmp    800813 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80080e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800813:	5b                   	pop    %ebx
  800814:	5d                   	pop    %ebp
  800815:	c3                   	ret    

00800816 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	8b 45 08             	mov    0x8(%ebp),%eax
  80081c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800820:	eb 07                	jmp    800829 <strchr+0x13>
		if (*s == c)
  800822:	38 ca                	cmp    %cl,%dl
  800824:	74 0f                	je     800835 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800826:	83 c0 01             	add    $0x1,%eax
  800829:	0f b6 10             	movzbl (%eax),%edx
  80082c:	84 d2                	test   %dl,%dl
  80082e:	75 f2                	jne    800822 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800830:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800835:	5d                   	pop    %ebp
  800836:	c3                   	ret    

00800837 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	8b 45 08             	mov    0x8(%ebp),%eax
  80083d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800841:	eb 03                	jmp    800846 <strfind+0xf>
  800843:	83 c0 01             	add    $0x1,%eax
  800846:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800849:	38 ca                	cmp    %cl,%dl
  80084b:	74 04                	je     800851 <strfind+0x1a>
  80084d:	84 d2                	test   %dl,%dl
  80084f:	75 f2                	jne    800843 <strfind+0xc>
			break;
	return (char *) s;
}
  800851:	5d                   	pop    %ebp
  800852:	c3                   	ret    

00800853 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	57                   	push   %edi
  800857:	56                   	push   %esi
  800858:	53                   	push   %ebx
  800859:	8b 7d 08             	mov    0x8(%ebp),%edi
  80085c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80085f:	85 c9                	test   %ecx,%ecx
  800861:	74 36                	je     800899 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800863:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800869:	75 28                	jne    800893 <memset+0x40>
  80086b:	f6 c1 03             	test   $0x3,%cl
  80086e:	75 23                	jne    800893 <memset+0x40>
		c &= 0xFF;
  800870:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800874:	89 d3                	mov    %edx,%ebx
  800876:	c1 e3 08             	shl    $0x8,%ebx
  800879:	89 d6                	mov    %edx,%esi
  80087b:	c1 e6 18             	shl    $0x18,%esi
  80087e:	89 d0                	mov    %edx,%eax
  800880:	c1 e0 10             	shl    $0x10,%eax
  800883:	09 f0                	or     %esi,%eax
  800885:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800887:	89 d8                	mov    %ebx,%eax
  800889:	09 d0                	or     %edx,%eax
  80088b:	c1 e9 02             	shr    $0x2,%ecx
  80088e:	fc                   	cld    
  80088f:	f3 ab                	rep stos %eax,%es:(%edi)
  800891:	eb 06                	jmp    800899 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800893:	8b 45 0c             	mov    0xc(%ebp),%eax
  800896:	fc                   	cld    
  800897:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800899:	89 f8                	mov    %edi,%eax
  80089b:	5b                   	pop    %ebx
  80089c:	5e                   	pop    %esi
  80089d:	5f                   	pop    %edi
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	57                   	push   %edi
  8008a4:	56                   	push   %esi
  8008a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008ab:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008ae:	39 c6                	cmp    %eax,%esi
  8008b0:	73 35                	jae    8008e7 <memmove+0x47>
  8008b2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008b5:	39 d0                	cmp    %edx,%eax
  8008b7:	73 2e                	jae    8008e7 <memmove+0x47>
		s += n;
		d += n;
  8008b9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008bc:	89 d6                	mov    %edx,%esi
  8008be:	09 fe                	or     %edi,%esi
  8008c0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008c6:	75 13                	jne    8008db <memmove+0x3b>
  8008c8:	f6 c1 03             	test   $0x3,%cl
  8008cb:	75 0e                	jne    8008db <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008cd:	83 ef 04             	sub    $0x4,%edi
  8008d0:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008d3:	c1 e9 02             	shr    $0x2,%ecx
  8008d6:	fd                   	std    
  8008d7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008d9:	eb 09                	jmp    8008e4 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008db:	83 ef 01             	sub    $0x1,%edi
  8008de:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008e1:	fd                   	std    
  8008e2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008e4:	fc                   	cld    
  8008e5:	eb 1d                	jmp    800904 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e7:	89 f2                	mov    %esi,%edx
  8008e9:	09 c2                	or     %eax,%edx
  8008eb:	f6 c2 03             	test   $0x3,%dl
  8008ee:	75 0f                	jne    8008ff <memmove+0x5f>
  8008f0:	f6 c1 03             	test   $0x3,%cl
  8008f3:	75 0a                	jne    8008ff <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008f5:	c1 e9 02             	shr    $0x2,%ecx
  8008f8:	89 c7                	mov    %eax,%edi
  8008fa:	fc                   	cld    
  8008fb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008fd:	eb 05                	jmp    800904 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008ff:	89 c7                	mov    %eax,%edi
  800901:	fc                   	cld    
  800902:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800904:	5e                   	pop    %esi
  800905:	5f                   	pop    %edi
  800906:	5d                   	pop    %ebp
  800907:	c3                   	ret    

00800908 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80090b:	ff 75 10             	pushl  0x10(%ebp)
  80090e:	ff 75 0c             	pushl  0xc(%ebp)
  800911:	ff 75 08             	pushl  0x8(%ebp)
  800914:	e8 87 ff ff ff       	call   8008a0 <memmove>
}
  800919:	c9                   	leave  
  80091a:	c3                   	ret    

0080091b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	56                   	push   %esi
  80091f:	53                   	push   %ebx
  800920:	8b 45 08             	mov    0x8(%ebp),%eax
  800923:	8b 55 0c             	mov    0xc(%ebp),%edx
  800926:	89 c6                	mov    %eax,%esi
  800928:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80092b:	eb 1a                	jmp    800947 <memcmp+0x2c>
		if (*s1 != *s2)
  80092d:	0f b6 08             	movzbl (%eax),%ecx
  800930:	0f b6 1a             	movzbl (%edx),%ebx
  800933:	38 d9                	cmp    %bl,%cl
  800935:	74 0a                	je     800941 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800937:	0f b6 c1             	movzbl %cl,%eax
  80093a:	0f b6 db             	movzbl %bl,%ebx
  80093d:	29 d8                	sub    %ebx,%eax
  80093f:	eb 0f                	jmp    800950 <memcmp+0x35>
		s1++, s2++;
  800941:	83 c0 01             	add    $0x1,%eax
  800944:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800947:	39 f0                	cmp    %esi,%eax
  800949:	75 e2                	jne    80092d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80094b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800950:	5b                   	pop    %ebx
  800951:	5e                   	pop    %esi
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	53                   	push   %ebx
  800958:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80095b:	89 c1                	mov    %eax,%ecx
  80095d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800960:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800964:	eb 0a                	jmp    800970 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800966:	0f b6 10             	movzbl (%eax),%edx
  800969:	39 da                	cmp    %ebx,%edx
  80096b:	74 07                	je     800974 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80096d:	83 c0 01             	add    $0x1,%eax
  800970:	39 c8                	cmp    %ecx,%eax
  800972:	72 f2                	jb     800966 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800974:	5b                   	pop    %ebx
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	57                   	push   %edi
  80097b:	56                   	push   %esi
  80097c:	53                   	push   %ebx
  80097d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800980:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800983:	eb 03                	jmp    800988 <strtol+0x11>
		s++;
  800985:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800988:	0f b6 01             	movzbl (%ecx),%eax
  80098b:	3c 20                	cmp    $0x20,%al
  80098d:	74 f6                	je     800985 <strtol+0xe>
  80098f:	3c 09                	cmp    $0x9,%al
  800991:	74 f2                	je     800985 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800993:	3c 2b                	cmp    $0x2b,%al
  800995:	75 0a                	jne    8009a1 <strtol+0x2a>
		s++;
  800997:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80099a:	bf 00 00 00 00       	mov    $0x0,%edi
  80099f:	eb 11                	jmp    8009b2 <strtol+0x3b>
  8009a1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009a6:	3c 2d                	cmp    $0x2d,%al
  8009a8:	75 08                	jne    8009b2 <strtol+0x3b>
		s++, neg = 1;
  8009aa:	83 c1 01             	add    $0x1,%ecx
  8009ad:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009b2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009b8:	75 15                	jne    8009cf <strtol+0x58>
  8009ba:	80 39 30             	cmpb   $0x30,(%ecx)
  8009bd:	75 10                	jne    8009cf <strtol+0x58>
  8009bf:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009c3:	75 7c                	jne    800a41 <strtol+0xca>
		s += 2, base = 16;
  8009c5:	83 c1 02             	add    $0x2,%ecx
  8009c8:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009cd:	eb 16                	jmp    8009e5 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009cf:	85 db                	test   %ebx,%ebx
  8009d1:	75 12                	jne    8009e5 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009d3:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009d8:	80 39 30             	cmpb   $0x30,(%ecx)
  8009db:	75 08                	jne    8009e5 <strtol+0x6e>
		s++, base = 8;
  8009dd:	83 c1 01             	add    $0x1,%ecx
  8009e0:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ea:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009ed:	0f b6 11             	movzbl (%ecx),%edx
  8009f0:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009f3:	89 f3                	mov    %esi,%ebx
  8009f5:	80 fb 09             	cmp    $0x9,%bl
  8009f8:	77 08                	ja     800a02 <strtol+0x8b>
			dig = *s - '0';
  8009fa:	0f be d2             	movsbl %dl,%edx
  8009fd:	83 ea 30             	sub    $0x30,%edx
  800a00:	eb 22                	jmp    800a24 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a02:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a05:	89 f3                	mov    %esi,%ebx
  800a07:	80 fb 19             	cmp    $0x19,%bl
  800a0a:	77 08                	ja     800a14 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a0c:	0f be d2             	movsbl %dl,%edx
  800a0f:	83 ea 57             	sub    $0x57,%edx
  800a12:	eb 10                	jmp    800a24 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a14:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a17:	89 f3                	mov    %esi,%ebx
  800a19:	80 fb 19             	cmp    $0x19,%bl
  800a1c:	77 16                	ja     800a34 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a1e:	0f be d2             	movsbl %dl,%edx
  800a21:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a24:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a27:	7d 0b                	jge    800a34 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a29:	83 c1 01             	add    $0x1,%ecx
  800a2c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a30:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a32:	eb b9                	jmp    8009ed <strtol+0x76>

	if (endptr)
  800a34:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a38:	74 0d                	je     800a47 <strtol+0xd0>
		*endptr = (char *) s;
  800a3a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a3d:	89 0e                	mov    %ecx,(%esi)
  800a3f:	eb 06                	jmp    800a47 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a41:	85 db                	test   %ebx,%ebx
  800a43:	74 98                	je     8009dd <strtol+0x66>
  800a45:	eb 9e                	jmp    8009e5 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a47:	89 c2                	mov    %eax,%edx
  800a49:	f7 da                	neg    %edx
  800a4b:	85 ff                	test   %edi,%edi
  800a4d:	0f 45 c2             	cmovne %edx,%eax
}
  800a50:	5b                   	pop    %ebx
  800a51:	5e                   	pop    %esi
  800a52:	5f                   	pop    %edi
  800a53:	5d                   	pop    %ebp
  800a54:	c3                   	ret    

00800a55 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	57                   	push   %edi
  800a59:	56                   	push   %esi
  800a5a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a63:	8b 55 08             	mov    0x8(%ebp),%edx
  800a66:	89 c3                	mov    %eax,%ebx
  800a68:	89 c7                	mov    %eax,%edi
  800a6a:	89 c6                	mov    %eax,%esi
  800a6c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a6e:	5b                   	pop    %ebx
  800a6f:	5e                   	pop    %esi
  800a70:	5f                   	pop    %edi
  800a71:	5d                   	pop    %ebp
  800a72:	c3                   	ret    

00800a73 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	57                   	push   %edi
  800a77:	56                   	push   %esi
  800a78:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a79:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7e:	b8 01 00 00 00       	mov    $0x1,%eax
  800a83:	89 d1                	mov    %edx,%ecx
  800a85:	89 d3                	mov    %edx,%ebx
  800a87:	89 d7                	mov    %edx,%edi
  800a89:	89 d6                	mov    %edx,%esi
  800a8b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a8d:	5b                   	pop    %ebx
  800a8e:	5e                   	pop    %esi
  800a8f:	5f                   	pop    %edi
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	57                   	push   %edi
  800a96:	56                   	push   %esi
  800a97:	53                   	push   %ebx
  800a98:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aa0:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa5:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa8:	89 cb                	mov    %ecx,%ebx
  800aaa:	89 cf                	mov    %ecx,%edi
  800aac:	89 ce                	mov    %ecx,%esi
  800aae:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ab0:	85 c0                	test   %eax,%eax
  800ab2:	7e 17                	jle    800acb <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ab4:	83 ec 0c             	sub    $0xc,%esp
  800ab7:	50                   	push   %eax
  800ab8:	6a 03                	push   $0x3
  800aba:	68 5f 21 80 00       	push   $0x80215f
  800abf:	6a 23                	push   $0x23
  800ac1:	68 7c 21 80 00       	push   $0x80217c
  800ac6:	e8 21 0f 00 00       	call   8019ec <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800acb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ace:	5b                   	pop    %ebx
  800acf:	5e                   	pop    %esi
  800ad0:	5f                   	pop    %edi
  800ad1:	5d                   	pop    %ebp
  800ad2:	c3                   	ret    

00800ad3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	57                   	push   %edi
  800ad7:	56                   	push   %esi
  800ad8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad9:	ba 00 00 00 00       	mov    $0x0,%edx
  800ade:	b8 02 00 00 00       	mov    $0x2,%eax
  800ae3:	89 d1                	mov    %edx,%ecx
  800ae5:	89 d3                	mov    %edx,%ebx
  800ae7:	89 d7                	mov    %edx,%edi
  800ae9:	89 d6                	mov    %edx,%esi
  800aeb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5f                   	pop    %edi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <sys_yield>:

void
sys_yield(void)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af8:	ba 00 00 00 00       	mov    $0x0,%edx
  800afd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b02:	89 d1                	mov    %edx,%ecx
  800b04:	89 d3                	mov    %edx,%ebx
  800b06:	89 d7                	mov    %edx,%edi
  800b08:	89 d6                	mov    %edx,%esi
  800b0a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	57                   	push   %edi
  800b15:	56                   	push   %esi
  800b16:	53                   	push   %ebx
  800b17:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1a:	be 00 00 00 00       	mov    $0x0,%esi
  800b1f:	b8 04 00 00 00       	mov    $0x4,%eax
  800b24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b27:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b2d:	89 f7                	mov    %esi,%edi
  800b2f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b31:	85 c0                	test   %eax,%eax
  800b33:	7e 17                	jle    800b4c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b35:	83 ec 0c             	sub    $0xc,%esp
  800b38:	50                   	push   %eax
  800b39:	6a 04                	push   $0x4
  800b3b:	68 5f 21 80 00       	push   $0x80215f
  800b40:	6a 23                	push   $0x23
  800b42:	68 7c 21 80 00       	push   $0x80217c
  800b47:	e8 a0 0e 00 00       	call   8019ec <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b4f:	5b                   	pop    %ebx
  800b50:	5e                   	pop    %esi
  800b51:	5f                   	pop    %edi
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	57                   	push   %edi
  800b58:	56                   	push   %esi
  800b59:	53                   	push   %ebx
  800b5a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5d:	b8 05 00 00 00       	mov    $0x5,%eax
  800b62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b65:	8b 55 08             	mov    0x8(%ebp),%edx
  800b68:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b6b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b6e:	8b 75 18             	mov    0x18(%ebp),%esi
  800b71:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b73:	85 c0                	test   %eax,%eax
  800b75:	7e 17                	jle    800b8e <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b77:	83 ec 0c             	sub    $0xc,%esp
  800b7a:	50                   	push   %eax
  800b7b:	6a 05                	push   $0x5
  800b7d:	68 5f 21 80 00       	push   $0x80215f
  800b82:	6a 23                	push   $0x23
  800b84:	68 7c 21 80 00       	push   $0x80217c
  800b89:	e8 5e 0e 00 00       	call   8019ec <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b91:	5b                   	pop    %ebx
  800b92:	5e                   	pop    %esi
  800b93:	5f                   	pop    %edi
  800b94:	5d                   	pop    %ebp
  800b95:	c3                   	ret    

00800b96 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	57                   	push   %edi
  800b9a:	56                   	push   %esi
  800b9b:	53                   	push   %ebx
  800b9c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ba4:	b8 06 00 00 00       	mov    $0x6,%eax
  800ba9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bac:	8b 55 08             	mov    0x8(%ebp),%edx
  800baf:	89 df                	mov    %ebx,%edi
  800bb1:	89 de                	mov    %ebx,%esi
  800bb3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb5:	85 c0                	test   %eax,%eax
  800bb7:	7e 17                	jle    800bd0 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb9:	83 ec 0c             	sub    $0xc,%esp
  800bbc:	50                   	push   %eax
  800bbd:	6a 06                	push   $0x6
  800bbf:	68 5f 21 80 00       	push   $0x80215f
  800bc4:	6a 23                	push   $0x23
  800bc6:	68 7c 21 80 00       	push   $0x80217c
  800bcb:	e8 1c 0e 00 00       	call   8019ec <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd3:	5b                   	pop    %ebx
  800bd4:	5e                   	pop    %esi
  800bd5:	5f                   	pop    %edi
  800bd6:	5d                   	pop    %ebp
  800bd7:	c3                   	ret    

00800bd8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	57                   	push   %edi
  800bdc:	56                   	push   %esi
  800bdd:	53                   	push   %ebx
  800bde:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800be6:	b8 08 00 00 00       	mov    $0x8,%eax
  800beb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bee:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf1:	89 df                	mov    %ebx,%edi
  800bf3:	89 de                	mov    %ebx,%esi
  800bf5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf7:	85 c0                	test   %eax,%eax
  800bf9:	7e 17                	jle    800c12 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfb:	83 ec 0c             	sub    $0xc,%esp
  800bfe:	50                   	push   %eax
  800bff:	6a 08                	push   $0x8
  800c01:	68 5f 21 80 00       	push   $0x80215f
  800c06:	6a 23                	push   $0x23
  800c08:	68 7c 21 80 00       	push   $0x80217c
  800c0d:	e8 da 0d 00 00       	call   8019ec <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5f                   	pop    %edi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	57                   	push   %edi
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
  800c20:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c23:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c28:	b8 09 00 00 00       	mov    $0x9,%eax
  800c2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c30:	8b 55 08             	mov    0x8(%ebp),%edx
  800c33:	89 df                	mov    %ebx,%edi
  800c35:	89 de                	mov    %ebx,%esi
  800c37:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c39:	85 c0                	test   %eax,%eax
  800c3b:	7e 17                	jle    800c54 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3d:	83 ec 0c             	sub    $0xc,%esp
  800c40:	50                   	push   %eax
  800c41:	6a 09                	push   $0x9
  800c43:	68 5f 21 80 00       	push   $0x80215f
  800c48:	6a 23                	push   $0x23
  800c4a:	68 7c 21 80 00       	push   $0x80217c
  800c4f:	e8 98 0d 00 00       	call   8019ec <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c57:	5b                   	pop    %ebx
  800c58:	5e                   	pop    %esi
  800c59:	5f                   	pop    %edi
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    

00800c5c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	57                   	push   %edi
  800c60:	56                   	push   %esi
  800c61:	53                   	push   %ebx
  800c62:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c65:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c72:	8b 55 08             	mov    0x8(%ebp),%edx
  800c75:	89 df                	mov    %ebx,%edi
  800c77:	89 de                	mov    %ebx,%esi
  800c79:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7b:	85 c0                	test   %eax,%eax
  800c7d:	7e 17                	jle    800c96 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7f:	83 ec 0c             	sub    $0xc,%esp
  800c82:	50                   	push   %eax
  800c83:	6a 0a                	push   $0xa
  800c85:	68 5f 21 80 00       	push   $0x80215f
  800c8a:	6a 23                	push   $0x23
  800c8c:	68 7c 21 80 00       	push   $0x80217c
  800c91:	e8 56 0d 00 00       	call   8019ec <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c99:	5b                   	pop    %ebx
  800c9a:	5e                   	pop    %esi
  800c9b:	5f                   	pop    %edi
  800c9c:	5d                   	pop    %ebp
  800c9d:	c3                   	ret    

00800c9e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	57                   	push   %edi
  800ca2:	56                   	push   %esi
  800ca3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca4:	be 00 00 00 00       	mov    $0x0,%esi
  800ca9:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cba:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cca:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ccf:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd7:	89 cb                	mov    %ecx,%ebx
  800cd9:	89 cf                	mov    %ecx,%edi
  800cdb:	89 ce                	mov    %ecx,%esi
  800cdd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cdf:	85 c0                	test   %eax,%eax
  800ce1:	7e 17                	jle    800cfa <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce3:	83 ec 0c             	sub    $0xc,%esp
  800ce6:	50                   	push   %eax
  800ce7:	6a 0d                	push   $0xd
  800ce9:	68 5f 21 80 00       	push   $0x80215f
  800cee:	6a 23                	push   $0x23
  800cf0:	68 7c 21 80 00       	push   $0x80217c
  800cf5:	e8 f2 0c 00 00       	call   8019ec <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfd:	5b                   	pop    %ebx
  800cfe:	5e                   	pop    %esi
  800cff:	5f                   	pop    %edi
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    

00800d02 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d02:	55                   	push   %ebp
  800d03:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d05:	8b 45 08             	mov    0x8(%ebp),%eax
  800d08:	05 00 00 00 30       	add    $0x30000000,%eax
  800d0d:	c1 e8 0c             	shr    $0xc,%eax
}
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    

00800d12 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d15:	8b 45 08             	mov    0x8(%ebp),%eax
  800d18:	05 00 00 00 30       	add    $0x30000000,%eax
  800d1d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d22:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    

00800d29 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d2f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d34:	89 c2                	mov    %eax,%edx
  800d36:	c1 ea 16             	shr    $0x16,%edx
  800d39:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d40:	f6 c2 01             	test   $0x1,%dl
  800d43:	74 11                	je     800d56 <fd_alloc+0x2d>
  800d45:	89 c2                	mov    %eax,%edx
  800d47:	c1 ea 0c             	shr    $0xc,%edx
  800d4a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d51:	f6 c2 01             	test   $0x1,%dl
  800d54:	75 09                	jne    800d5f <fd_alloc+0x36>
			*fd_store = fd;
  800d56:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d58:	b8 00 00 00 00       	mov    $0x0,%eax
  800d5d:	eb 17                	jmp    800d76 <fd_alloc+0x4d>
  800d5f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d64:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d69:	75 c9                	jne    800d34 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d6b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d71:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    

00800d78 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d7e:	83 f8 1f             	cmp    $0x1f,%eax
  800d81:	77 36                	ja     800db9 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d83:	c1 e0 0c             	shl    $0xc,%eax
  800d86:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d8b:	89 c2                	mov    %eax,%edx
  800d8d:	c1 ea 16             	shr    $0x16,%edx
  800d90:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d97:	f6 c2 01             	test   $0x1,%dl
  800d9a:	74 24                	je     800dc0 <fd_lookup+0x48>
  800d9c:	89 c2                	mov    %eax,%edx
  800d9e:	c1 ea 0c             	shr    $0xc,%edx
  800da1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800da8:	f6 c2 01             	test   $0x1,%dl
  800dab:	74 1a                	je     800dc7 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800dad:	8b 55 0c             	mov    0xc(%ebp),%edx
  800db0:	89 02                	mov    %eax,(%edx)
	return 0;
  800db2:	b8 00 00 00 00       	mov    $0x0,%eax
  800db7:	eb 13                	jmp    800dcc <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800db9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dbe:	eb 0c                	jmp    800dcc <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dc0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dc5:	eb 05                	jmp    800dcc <fd_lookup+0x54>
  800dc7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800dcc:	5d                   	pop    %ebp
  800dcd:	c3                   	ret    

00800dce <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800dce:	55                   	push   %ebp
  800dcf:	89 e5                	mov    %esp,%ebp
  800dd1:	83 ec 08             	sub    $0x8,%esp
  800dd4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dd7:	ba 08 22 80 00       	mov    $0x802208,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ddc:	eb 13                	jmp    800df1 <dev_lookup+0x23>
  800dde:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800de1:	39 08                	cmp    %ecx,(%eax)
  800de3:	75 0c                	jne    800df1 <dev_lookup+0x23>
			*dev = devtab[i];
  800de5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de8:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dea:	b8 00 00 00 00       	mov    $0x0,%eax
  800def:	eb 2e                	jmp    800e1f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800df1:	8b 02                	mov    (%edx),%eax
  800df3:	85 c0                	test   %eax,%eax
  800df5:	75 e7                	jne    800dde <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800df7:	a1 04 40 80 00       	mov    0x804004,%eax
  800dfc:	8b 40 48             	mov    0x48(%eax),%eax
  800dff:	83 ec 04             	sub    $0x4,%esp
  800e02:	51                   	push   %ecx
  800e03:	50                   	push   %eax
  800e04:	68 8c 21 80 00       	push   $0x80218c
  800e09:	e8 7b f3 ff ff       	call   800189 <cprintf>
	*dev = 0;
  800e0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e11:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e17:	83 c4 10             	add    $0x10,%esp
  800e1a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e1f:	c9                   	leave  
  800e20:	c3                   	ret    

00800e21 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
  800e24:	56                   	push   %esi
  800e25:	53                   	push   %ebx
  800e26:	83 ec 10             	sub    $0x10,%esp
  800e29:	8b 75 08             	mov    0x8(%ebp),%esi
  800e2c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e32:	50                   	push   %eax
  800e33:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e39:	c1 e8 0c             	shr    $0xc,%eax
  800e3c:	50                   	push   %eax
  800e3d:	e8 36 ff ff ff       	call   800d78 <fd_lookup>
  800e42:	83 c4 08             	add    $0x8,%esp
  800e45:	85 c0                	test   %eax,%eax
  800e47:	78 05                	js     800e4e <fd_close+0x2d>
	    || fd != fd2)
  800e49:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e4c:	74 0c                	je     800e5a <fd_close+0x39>
		return (must_exist ? r : 0);
  800e4e:	84 db                	test   %bl,%bl
  800e50:	ba 00 00 00 00       	mov    $0x0,%edx
  800e55:	0f 44 c2             	cmove  %edx,%eax
  800e58:	eb 41                	jmp    800e9b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e5a:	83 ec 08             	sub    $0x8,%esp
  800e5d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e60:	50                   	push   %eax
  800e61:	ff 36                	pushl  (%esi)
  800e63:	e8 66 ff ff ff       	call   800dce <dev_lookup>
  800e68:	89 c3                	mov    %eax,%ebx
  800e6a:	83 c4 10             	add    $0x10,%esp
  800e6d:	85 c0                	test   %eax,%eax
  800e6f:	78 1a                	js     800e8b <fd_close+0x6a>
		if (dev->dev_close)
  800e71:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e74:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e77:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e7c:	85 c0                	test   %eax,%eax
  800e7e:	74 0b                	je     800e8b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800e80:	83 ec 0c             	sub    $0xc,%esp
  800e83:	56                   	push   %esi
  800e84:	ff d0                	call   *%eax
  800e86:	89 c3                	mov    %eax,%ebx
  800e88:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e8b:	83 ec 08             	sub    $0x8,%esp
  800e8e:	56                   	push   %esi
  800e8f:	6a 00                	push   $0x0
  800e91:	e8 00 fd ff ff       	call   800b96 <sys_page_unmap>
	return r;
  800e96:	83 c4 10             	add    $0x10,%esp
  800e99:	89 d8                	mov    %ebx,%eax
}
  800e9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e9e:	5b                   	pop    %ebx
  800e9f:	5e                   	pop    %esi
  800ea0:	5d                   	pop    %ebp
  800ea1:	c3                   	ret    

00800ea2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ea2:	55                   	push   %ebp
  800ea3:	89 e5                	mov    %esp,%ebp
  800ea5:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ea8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eab:	50                   	push   %eax
  800eac:	ff 75 08             	pushl  0x8(%ebp)
  800eaf:	e8 c4 fe ff ff       	call   800d78 <fd_lookup>
  800eb4:	83 c4 08             	add    $0x8,%esp
  800eb7:	85 c0                	test   %eax,%eax
  800eb9:	78 10                	js     800ecb <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ebb:	83 ec 08             	sub    $0x8,%esp
  800ebe:	6a 01                	push   $0x1
  800ec0:	ff 75 f4             	pushl  -0xc(%ebp)
  800ec3:	e8 59 ff ff ff       	call   800e21 <fd_close>
  800ec8:	83 c4 10             	add    $0x10,%esp
}
  800ecb:	c9                   	leave  
  800ecc:	c3                   	ret    

00800ecd <close_all>:

void
close_all(void)
{
  800ecd:	55                   	push   %ebp
  800ece:	89 e5                	mov    %esp,%ebp
  800ed0:	53                   	push   %ebx
  800ed1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ed4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ed9:	83 ec 0c             	sub    $0xc,%esp
  800edc:	53                   	push   %ebx
  800edd:	e8 c0 ff ff ff       	call   800ea2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ee2:	83 c3 01             	add    $0x1,%ebx
  800ee5:	83 c4 10             	add    $0x10,%esp
  800ee8:	83 fb 20             	cmp    $0x20,%ebx
  800eeb:	75 ec                	jne    800ed9 <close_all+0xc>
		close(i);
}
  800eed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef0:	c9                   	leave  
  800ef1:	c3                   	ret    

00800ef2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ef2:	55                   	push   %ebp
  800ef3:	89 e5                	mov    %esp,%ebp
  800ef5:	57                   	push   %edi
  800ef6:	56                   	push   %esi
  800ef7:	53                   	push   %ebx
  800ef8:	83 ec 2c             	sub    $0x2c,%esp
  800efb:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800efe:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f01:	50                   	push   %eax
  800f02:	ff 75 08             	pushl  0x8(%ebp)
  800f05:	e8 6e fe ff ff       	call   800d78 <fd_lookup>
  800f0a:	83 c4 08             	add    $0x8,%esp
  800f0d:	85 c0                	test   %eax,%eax
  800f0f:	0f 88 c1 00 00 00    	js     800fd6 <dup+0xe4>
		return r;
	close(newfdnum);
  800f15:	83 ec 0c             	sub    $0xc,%esp
  800f18:	56                   	push   %esi
  800f19:	e8 84 ff ff ff       	call   800ea2 <close>

	newfd = INDEX2FD(newfdnum);
  800f1e:	89 f3                	mov    %esi,%ebx
  800f20:	c1 e3 0c             	shl    $0xc,%ebx
  800f23:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f29:	83 c4 04             	add    $0x4,%esp
  800f2c:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f2f:	e8 de fd ff ff       	call   800d12 <fd2data>
  800f34:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f36:	89 1c 24             	mov    %ebx,(%esp)
  800f39:	e8 d4 fd ff ff       	call   800d12 <fd2data>
  800f3e:	83 c4 10             	add    $0x10,%esp
  800f41:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f44:	89 f8                	mov    %edi,%eax
  800f46:	c1 e8 16             	shr    $0x16,%eax
  800f49:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f50:	a8 01                	test   $0x1,%al
  800f52:	74 37                	je     800f8b <dup+0x99>
  800f54:	89 f8                	mov    %edi,%eax
  800f56:	c1 e8 0c             	shr    $0xc,%eax
  800f59:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f60:	f6 c2 01             	test   $0x1,%dl
  800f63:	74 26                	je     800f8b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f65:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f6c:	83 ec 0c             	sub    $0xc,%esp
  800f6f:	25 07 0e 00 00       	and    $0xe07,%eax
  800f74:	50                   	push   %eax
  800f75:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f78:	6a 00                	push   $0x0
  800f7a:	57                   	push   %edi
  800f7b:	6a 00                	push   $0x0
  800f7d:	e8 d2 fb ff ff       	call   800b54 <sys_page_map>
  800f82:	89 c7                	mov    %eax,%edi
  800f84:	83 c4 20             	add    $0x20,%esp
  800f87:	85 c0                	test   %eax,%eax
  800f89:	78 2e                	js     800fb9 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f8b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f8e:	89 d0                	mov    %edx,%eax
  800f90:	c1 e8 0c             	shr    $0xc,%eax
  800f93:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f9a:	83 ec 0c             	sub    $0xc,%esp
  800f9d:	25 07 0e 00 00       	and    $0xe07,%eax
  800fa2:	50                   	push   %eax
  800fa3:	53                   	push   %ebx
  800fa4:	6a 00                	push   $0x0
  800fa6:	52                   	push   %edx
  800fa7:	6a 00                	push   $0x0
  800fa9:	e8 a6 fb ff ff       	call   800b54 <sys_page_map>
  800fae:	89 c7                	mov    %eax,%edi
  800fb0:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800fb3:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fb5:	85 ff                	test   %edi,%edi
  800fb7:	79 1d                	jns    800fd6 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fb9:	83 ec 08             	sub    $0x8,%esp
  800fbc:	53                   	push   %ebx
  800fbd:	6a 00                	push   $0x0
  800fbf:	e8 d2 fb ff ff       	call   800b96 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fc4:	83 c4 08             	add    $0x8,%esp
  800fc7:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fca:	6a 00                	push   $0x0
  800fcc:	e8 c5 fb ff ff       	call   800b96 <sys_page_unmap>
	return r;
  800fd1:	83 c4 10             	add    $0x10,%esp
  800fd4:	89 f8                	mov    %edi,%eax
}
  800fd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fd9:	5b                   	pop    %ebx
  800fda:	5e                   	pop    %esi
  800fdb:	5f                   	pop    %edi
  800fdc:	5d                   	pop    %ebp
  800fdd:	c3                   	ret    

00800fde <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800fde:	55                   	push   %ebp
  800fdf:	89 e5                	mov    %esp,%ebp
  800fe1:	53                   	push   %ebx
  800fe2:	83 ec 14             	sub    $0x14,%esp
  800fe5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800fe8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800feb:	50                   	push   %eax
  800fec:	53                   	push   %ebx
  800fed:	e8 86 fd ff ff       	call   800d78 <fd_lookup>
  800ff2:	83 c4 08             	add    $0x8,%esp
  800ff5:	89 c2                	mov    %eax,%edx
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	78 6d                	js     801068 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ffb:	83 ec 08             	sub    $0x8,%esp
  800ffe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801001:	50                   	push   %eax
  801002:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801005:	ff 30                	pushl  (%eax)
  801007:	e8 c2 fd ff ff       	call   800dce <dev_lookup>
  80100c:	83 c4 10             	add    $0x10,%esp
  80100f:	85 c0                	test   %eax,%eax
  801011:	78 4c                	js     80105f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801013:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801016:	8b 42 08             	mov    0x8(%edx),%eax
  801019:	83 e0 03             	and    $0x3,%eax
  80101c:	83 f8 01             	cmp    $0x1,%eax
  80101f:	75 21                	jne    801042 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801021:	a1 04 40 80 00       	mov    0x804004,%eax
  801026:	8b 40 48             	mov    0x48(%eax),%eax
  801029:	83 ec 04             	sub    $0x4,%esp
  80102c:	53                   	push   %ebx
  80102d:	50                   	push   %eax
  80102e:	68 cd 21 80 00       	push   $0x8021cd
  801033:	e8 51 f1 ff ff       	call   800189 <cprintf>
		return -E_INVAL;
  801038:	83 c4 10             	add    $0x10,%esp
  80103b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801040:	eb 26                	jmp    801068 <read+0x8a>
	}
	if (!dev->dev_read)
  801042:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801045:	8b 40 08             	mov    0x8(%eax),%eax
  801048:	85 c0                	test   %eax,%eax
  80104a:	74 17                	je     801063 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80104c:	83 ec 04             	sub    $0x4,%esp
  80104f:	ff 75 10             	pushl  0x10(%ebp)
  801052:	ff 75 0c             	pushl  0xc(%ebp)
  801055:	52                   	push   %edx
  801056:	ff d0                	call   *%eax
  801058:	89 c2                	mov    %eax,%edx
  80105a:	83 c4 10             	add    $0x10,%esp
  80105d:	eb 09                	jmp    801068 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80105f:	89 c2                	mov    %eax,%edx
  801061:	eb 05                	jmp    801068 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801063:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801068:	89 d0                	mov    %edx,%eax
  80106a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80106d:	c9                   	leave  
  80106e:	c3                   	ret    

0080106f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80106f:	55                   	push   %ebp
  801070:	89 e5                	mov    %esp,%ebp
  801072:	57                   	push   %edi
  801073:	56                   	push   %esi
  801074:	53                   	push   %ebx
  801075:	83 ec 0c             	sub    $0xc,%esp
  801078:	8b 7d 08             	mov    0x8(%ebp),%edi
  80107b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80107e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801083:	eb 21                	jmp    8010a6 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801085:	83 ec 04             	sub    $0x4,%esp
  801088:	89 f0                	mov    %esi,%eax
  80108a:	29 d8                	sub    %ebx,%eax
  80108c:	50                   	push   %eax
  80108d:	89 d8                	mov    %ebx,%eax
  80108f:	03 45 0c             	add    0xc(%ebp),%eax
  801092:	50                   	push   %eax
  801093:	57                   	push   %edi
  801094:	e8 45 ff ff ff       	call   800fde <read>
		if (m < 0)
  801099:	83 c4 10             	add    $0x10,%esp
  80109c:	85 c0                	test   %eax,%eax
  80109e:	78 10                	js     8010b0 <readn+0x41>
			return m;
		if (m == 0)
  8010a0:	85 c0                	test   %eax,%eax
  8010a2:	74 0a                	je     8010ae <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010a4:	01 c3                	add    %eax,%ebx
  8010a6:	39 f3                	cmp    %esi,%ebx
  8010a8:	72 db                	jb     801085 <readn+0x16>
  8010aa:	89 d8                	mov    %ebx,%eax
  8010ac:	eb 02                	jmp    8010b0 <readn+0x41>
  8010ae:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b3:	5b                   	pop    %ebx
  8010b4:	5e                   	pop    %esi
  8010b5:	5f                   	pop    %edi
  8010b6:	5d                   	pop    %ebp
  8010b7:	c3                   	ret    

008010b8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
  8010bb:	53                   	push   %ebx
  8010bc:	83 ec 14             	sub    $0x14,%esp
  8010bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010c5:	50                   	push   %eax
  8010c6:	53                   	push   %ebx
  8010c7:	e8 ac fc ff ff       	call   800d78 <fd_lookup>
  8010cc:	83 c4 08             	add    $0x8,%esp
  8010cf:	89 c2                	mov    %eax,%edx
  8010d1:	85 c0                	test   %eax,%eax
  8010d3:	78 68                	js     80113d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010d5:	83 ec 08             	sub    $0x8,%esp
  8010d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010db:	50                   	push   %eax
  8010dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010df:	ff 30                	pushl  (%eax)
  8010e1:	e8 e8 fc ff ff       	call   800dce <dev_lookup>
  8010e6:	83 c4 10             	add    $0x10,%esp
  8010e9:	85 c0                	test   %eax,%eax
  8010eb:	78 47                	js     801134 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010f0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8010f4:	75 21                	jne    801117 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8010f6:	a1 04 40 80 00       	mov    0x804004,%eax
  8010fb:	8b 40 48             	mov    0x48(%eax),%eax
  8010fe:	83 ec 04             	sub    $0x4,%esp
  801101:	53                   	push   %ebx
  801102:	50                   	push   %eax
  801103:	68 e9 21 80 00       	push   $0x8021e9
  801108:	e8 7c f0 ff ff       	call   800189 <cprintf>
		return -E_INVAL;
  80110d:	83 c4 10             	add    $0x10,%esp
  801110:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801115:	eb 26                	jmp    80113d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801117:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80111a:	8b 52 0c             	mov    0xc(%edx),%edx
  80111d:	85 d2                	test   %edx,%edx
  80111f:	74 17                	je     801138 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801121:	83 ec 04             	sub    $0x4,%esp
  801124:	ff 75 10             	pushl  0x10(%ebp)
  801127:	ff 75 0c             	pushl  0xc(%ebp)
  80112a:	50                   	push   %eax
  80112b:	ff d2                	call   *%edx
  80112d:	89 c2                	mov    %eax,%edx
  80112f:	83 c4 10             	add    $0x10,%esp
  801132:	eb 09                	jmp    80113d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801134:	89 c2                	mov    %eax,%edx
  801136:	eb 05                	jmp    80113d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801138:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80113d:	89 d0                	mov    %edx,%eax
  80113f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801142:	c9                   	leave  
  801143:	c3                   	ret    

00801144 <seek>:

int
seek(int fdnum, off_t offset)
{
  801144:	55                   	push   %ebp
  801145:	89 e5                	mov    %esp,%ebp
  801147:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80114a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80114d:	50                   	push   %eax
  80114e:	ff 75 08             	pushl  0x8(%ebp)
  801151:	e8 22 fc ff ff       	call   800d78 <fd_lookup>
  801156:	83 c4 08             	add    $0x8,%esp
  801159:	85 c0                	test   %eax,%eax
  80115b:	78 0e                	js     80116b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80115d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801160:	8b 55 0c             	mov    0xc(%ebp),%edx
  801163:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801166:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80116b:	c9                   	leave  
  80116c:	c3                   	ret    

0080116d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80116d:	55                   	push   %ebp
  80116e:	89 e5                	mov    %esp,%ebp
  801170:	53                   	push   %ebx
  801171:	83 ec 14             	sub    $0x14,%esp
  801174:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801177:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80117a:	50                   	push   %eax
  80117b:	53                   	push   %ebx
  80117c:	e8 f7 fb ff ff       	call   800d78 <fd_lookup>
  801181:	83 c4 08             	add    $0x8,%esp
  801184:	89 c2                	mov    %eax,%edx
  801186:	85 c0                	test   %eax,%eax
  801188:	78 65                	js     8011ef <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80118a:	83 ec 08             	sub    $0x8,%esp
  80118d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801190:	50                   	push   %eax
  801191:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801194:	ff 30                	pushl  (%eax)
  801196:	e8 33 fc ff ff       	call   800dce <dev_lookup>
  80119b:	83 c4 10             	add    $0x10,%esp
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	78 44                	js     8011e6 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011a9:	75 21                	jne    8011cc <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011ab:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011b0:	8b 40 48             	mov    0x48(%eax),%eax
  8011b3:	83 ec 04             	sub    $0x4,%esp
  8011b6:	53                   	push   %ebx
  8011b7:	50                   	push   %eax
  8011b8:	68 ac 21 80 00       	push   $0x8021ac
  8011bd:	e8 c7 ef ff ff       	call   800189 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011c2:	83 c4 10             	add    $0x10,%esp
  8011c5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011ca:	eb 23                	jmp    8011ef <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011cf:	8b 52 18             	mov    0x18(%edx),%edx
  8011d2:	85 d2                	test   %edx,%edx
  8011d4:	74 14                	je     8011ea <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011d6:	83 ec 08             	sub    $0x8,%esp
  8011d9:	ff 75 0c             	pushl  0xc(%ebp)
  8011dc:	50                   	push   %eax
  8011dd:	ff d2                	call   *%edx
  8011df:	89 c2                	mov    %eax,%edx
  8011e1:	83 c4 10             	add    $0x10,%esp
  8011e4:	eb 09                	jmp    8011ef <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e6:	89 c2                	mov    %eax,%edx
  8011e8:	eb 05                	jmp    8011ef <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011ea:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8011ef:	89 d0                	mov    %edx,%eax
  8011f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f4:	c9                   	leave  
  8011f5:	c3                   	ret    

008011f6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011f6:	55                   	push   %ebp
  8011f7:	89 e5                	mov    %esp,%ebp
  8011f9:	53                   	push   %ebx
  8011fa:	83 ec 14             	sub    $0x14,%esp
  8011fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801200:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801203:	50                   	push   %eax
  801204:	ff 75 08             	pushl  0x8(%ebp)
  801207:	e8 6c fb ff ff       	call   800d78 <fd_lookup>
  80120c:	83 c4 08             	add    $0x8,%esp
  80120f:	89 c2                	mov    %eax,%edx
  801211:	85 c0                	test   %eax,%eax
  801213:	78 58                	js     80126d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801215:	83 ec 08             	sub    $0x8,%esp
  801218:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80121b:	50                   	push   %eax
  80121c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121f:	ff 30                	pushl  (%eax)
  801221:	e8 a8 fb ff ff       	call   800dce <dev_lookup>
  801226:	83 c4 10             	add    $0x10,%esp
  801229:	85 c0                	test   %eax,%eax
  80122b:	78 37                	js     801264 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80122d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801230:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801234:	74 32                	je     801268 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801236:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801239:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801240:	00 00 00 
	stat->st_isdir = 0;
  801243:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80124a:	00 00 00 
	stat->st_dev = dev;
  80124d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801253:	83 ec 08             	sub    $0x8,%esp
  801256:	53                   	push   %ebx
  801257:	ff 75 f0             	pushl  -0x10(%ebp)
  80125a:	ff 50 14             	call   *0x14(%eax)
  80125d:	89 c2                	mov    %eax,%edx
  80125f:	83 c4 10             	add    $0x10,%esp
  801262:	eb 09                	jmp    80126d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801264:	89 c2                	mov    %eax,%edx
  801266:	eb 05                	jmp    80126d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801268:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80126d:	89 d0                	mov    %edx,%eax
  80126f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801272:	c9                   	leave  
  801273:	c3                   	ret    

00801274 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801274:	55                   	push   %ebp
  801275:	89 e5                	mov    %esp,%ebp
  801277:	56                   	push   %esi
  801278:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801279:	83 ec 08             	sub    $0x8,%esp
  80127c:	6a 00                	push   $0x0
  80127e:	ff 75 08             	pushl  0x8(%ebp)
  801281:	e8 e3 01 00 00       	call   801469 <open>
  801286:	89 c3                	mov    %eax,%ebx
  801288:	83 c4 10             	add    $0x10,%esp
  80128b:	85 c0                	test   %eax,%eax
  80128d:	78 1b                	js     8012aa <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80128f:	83 ec 08             	sub    $0x8,%esp
  801292:	ff 75 0c             	pushl  0xc(%ebp)
  801295:	50                   	push   %eax
  801296:	e8 5b ff ff ff       	call   8011f6 <fstat>
  80129b:	89 c6                	mov    %eax,%esi
	close(fd);
  80129d:	89 1c 24             	mov    %ebx,(%esp)
  8012a0:	e8 fd fb ff ff       	call   800ea2 <close>
	return r;
  8012a5:	83 c4 10             	add    $0x10,%esp
  8012a8:	89 f0                	mov    %esi,%eax
}
  8012aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ad:	5b                   	pop    %ebx
  8012ae:	5e                   	pop    %esi
  8012af:	5d                   	pop    %ebp
  8012b0:	c3                   	ret    

008012b1 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012b1:	55                   	push   %ebp
  8012b2:	89 e5                	mov    %esp,%ebp
  8012b4:	56                   	push   %esi
  8012b5:	53                   	push   %ebx
  8012b6:	89 c6                	mov    %eax,%esi
  8012b8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012ba:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012c1:	75 12                	jne    8012d5 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012c3:	83 ec 0c             	sub    $0xc,%esp
  8012c6:	6a 01                	push   $0x1
  8012c8:	e8 39 08 00 00       	call   801b06 <ipc_find_env>
  8012cd:	a3 00 40 80 00       	mov    %eax,0x804000
  8012d2:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012d5:	6a 07                	push   $0x7
  8012d7:	68 00 50 80 00       	push   $0x805000
  8012dc:	56                   	push   %esi
  8012dd:	ff 35 00 40 80 00    	pushl  0x804000
  8012e3:	e8 bc 07 00 00       	call   801aa4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8012e8:	83 c4 0c             	add    $0xc,%esp
  8012eb:	6a 00                	push   $0x0
  8012ed:	53                   	push   %ebx
  8012ee:	6a 00                	push   $0x0
  8012f0:	e8 3d 07 00 00       	call   801a32 <ipc_recv>
}
  8012f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012f8:	5b                   	pop    %ebx
  8012f9:	5e                   	pop    %esi
  8012fa:	5d                   	pop    %ebp
  8012fb:	c3                   	ret    

008012fc <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8012fc:	55                   	push   %ebp
  8012fd:	89 e5                	mov    %esp,%ebp
  8012ff:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801302:	8b 45 08             	mov    0x8(%ebp),%eax
  801305:	8b 40 0c             	mov    0xc(%eax),%eax
  801308:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80130d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801310:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801315:	ba 00 00 00 00       	mov    $0x0,%edx
  80131a:	b8 02 00 00 00       	mov    $0x2,%eax
  80131f:	e8 8d ff ff ff       	call   8012b1 <fsipc>
}
  801324:	c9                   	leave  
  801325:	c3                   	ret    

00801326 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80132c:	8b 45 08             	mov    0x8(%ebp),%eax
  80132f:	8b 40 0c             	mov    0xc(%eax),%eax
  801332:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801337:	ba 00 00 00 00       	mov    $0x0,%edx
  80133c:	b8 06 00 00 00       	mov    $0x6,%eax
  801341:	e8 6b ff ff ff       	call   8012b1 <fsipc>
}
  801346:	c9                   	leave  
  801347:	c3                   	ret    

00801348 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801348:	55                   	push   %ebp
  801349:	89 e5                	mov    %esp,%ebp
  80134b:	53                   	push   %ebx
  80134c:	83 ec 04             	sub    $0x4,%esp
  80134f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801352:	8b 45 08             	mov    0x8(%ebp),%eax
  801355:	8b 40 0c             	mov    0xc(%eax),%eax
  801358:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80135d:	ba 00 00 00 00       	mov    $0x0,%edx
  801362:	b8 05 00 00 00       	mov    $0x5,%eax
  801367:	e8 45 ff ff ff       	call   8012b1 <fsipc>
  80136c:	85 c0                	test   %eax,%eax
  80136e:	78 2c                	js     80139c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801370:	83 ec 08             	sub    $0x8,%esp
  801373:	68 00 50 80 00       	push   $0x805000
  801378:	53                   	push   %ebx
  801379:	e8 90 f3 ff ff       	call   80070e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80137e:	a1 80 50 80 00       	mov    0x805080,%eax
  801383:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801389:	a1 84 50 80 00       	mov    0x805084,%eax
  80138e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801394:	83 c4 10             	add    $0x10,%esp
  801397:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80139c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80139f:	c9                   	leave  
  8013a0:	c3                   	ret    

008013a1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013a1:	55                   	push   %ebp
  8013a2:	89 e5                	mov    %esp,%ebp
  8013a4:	83 ec 0c             	sub    $0xc,%esp
  8013a7:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8013ad:	8b 52 0c             	mov    0xc(%edx),%edx
  8013b0:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8013b6:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8013bb:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8013c0:	0f 47 c2             	cmova  %edx,%eax
  8013c3:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8013c8:	50                   	push   %eax
  8013c9:	ff 75 0c             	pushl  0xc(%ebp)
  8013cc:	68 08 50 80 00       	push   $0x805008
  8013d1:	e8 ca f4 ff ff       	call   8008a0 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8013d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8013db:	b8 04 00 00 00       	mov    $0x4,%eax
  8013e0:	e8 cc fe ff ff       	call   8012b1 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8013e5:	c9                   	leave  
  8013e6:	c3                   	ret    

008013e7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013e7:	55                   	push   %ebp
  8013e8:	89 e5                	mov    %esp,%ebp
  8013ea:	56                   	push   %esi
  8013eb:	53                   	push   %ebx
  8013ec:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f2:	8b 40 0c             	mov    0xc(%eax),%eax
  8013f5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013fa:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801400:	ba 00 00 00 00       	mov    $0x0,%edx
  801405:	b8 03 00 00 00       	mov    $0x3,%eax
  80140a:	e8 a2 fe ff ff       	call   8012b1 <fsipc>
  80140f:	89 c3                	mov    %eax,%ebx
  801411:	85 c0                	test   %eax,%eax
  801413:	78 4b                	js     801460 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801415:	39 c6                	cmp    %eax,%esi
  801417:	73 16                	jae    80142f <devfile_read+0x48>
  801419:	68 18 22 80 00       	push   $0x802218
  80141e:	68 1f 22 80 00       	push   $0x80221f
  801423:	6a 7c                	push   $0x7c
  801425:	68 34 22 80 00       	push   $0x802234
  80142a:	e8 bd 05 00 00       	call   8019ec <_panic>
	assert(r <= PGSIZE);
  80142f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801434:	7e 16                	jle    80144c <devfile_read+0x65>
  801436:	68 3f 22 80 00       	push   $0x80223f
  80143b:	68 1f 22 80 00       	push   $0x80221f
  801440:	6a 7d                	push   $0x7d
  801442:	68 34 22 80 00       	push   $0x802234
  801447:	e8 a0 05 00 00       	call   8019ec <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80144c:	83 ec 04             	sub    $0x4,%esp
  80144f:	50                   	push   %eax
  801450:	68 00 50 80 00       	push   $0x805000
  801455:	ff 75 0c             	pushl  0xc(%ebp)
  801458:	e8 43 f4 ff ff       	call   8008a0 <memmove>
	return r;
  80145d:	83 c4 10             	add    $0x10,%esp
}
  801460:	89 d8                	mov    %ebx,%eax
  801462:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801465:	5b                   	pop    %ebx
  801466:	5e                   	pop    %esi
  801467:	5d                   	pop    %ebp
  801468:	c3                   	ret    

00801469 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801469:	55                   	push   %ebp
  80146a:	89 e5                	mov    %esp,%ebp
  80146c:	53                   	push   %ebx
  80146d:	83 ec 20             	sub    $0x20,%esp
  801470:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801473:	53                   	push   %ebx
  801474:	e8 5c f2 ff ff       	call   8006d5 <strlen>
  801479:	83 c4 10             	add    $0x10,%esp
  80147c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801481:	7f 67                	jg     8014ea <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801483:	83 ec 0c             	sub    $0xc,%esp
  801486:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801489:	50                   	push   %eax
  80148a:	e8 9a f8 ff ff       	call   800d29 <fd_alloc>
  80148f:	83 c4 10             	add    $0x10,%esp
		return r;
  801492:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801494:	85 c0                	test   %eax,%eax
  801496:	78 57                	js     8014ef <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801498:	83 ec 08             	sub    $0x8,%esp
  80149b:	53                   	push   %ebx
  80149c:	68 00 50 80 00       	push   $0x805000
  8014a1:	e8 68 f2 ff ff       	call   80070e <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a9:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8014b6:	e8 f6 fd ff ff       	call   8012b1 <fsipc>
  8014bb:	89 c3                	mov    %eax,%ebx
  8014bd:	83 c4 10             	add    $0x10,%esp
  8014c0:	85 c0                	test   %eax,%eax
  8014c2:	79 14                	jns    8014d8 <open+0x6f>
		fd_close(fd, 0);
  8014c4:	83 ec 08             	sub    $0x8,%esp
  8014c7:	6a 00                	push   $0x0
  8014c9:	ff 75 f4             	pushl  -0xc(%ebp)
  8014cc:	e8 50 f9 ff ff       	call   800e21 <fd_close>
		return r;
  8014d1:	83 c4 10             	add    $0x10,%esp
  8014d4:	89 da                	mov    %ebx,%edx
  8014d6:	eb 17                	jmp    8014ef <open+0x86>
	}

	return fd2num(fd);
  8014d8:	83 ec 0c             	sub    $0xc,%esp
  8014db:	ff 75 f4             	pushl  -0xc(%ebp)
  8014de:	e8 1f f8 ff ff       	call   800d02 <fd2num>
  8014e3:	89 c2                	mov    %eax,%edx
  8014e5:	83 c4 10             	add    $0x10,%esp
  8014e8:	eb 05                	jmp    8014ef <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8014ea:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8014ef:	89 d0                	mov    %edx,%eax
  8014f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f4:	c9                   	leave  
  8014f5:	c3                   	ret    

008014f6 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8014f6:	55                   	push   %ebp
  8014f7:	89 e5                	mov    %esp,%ebp
  8014f9:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8014fc:	ba 00 00 00 00       	mov    $0x0,%edx
  801501:	b8 08 00 00 00       	mov    $0x8,%eax
  801506:	e8 a6 fd ff ff       	call   8012b1 <fsipc>
}
  80150b:	c9                   	leave  
  80150c:	c3                   	ret    

0080150d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80150d:	55                   	push   %ebp
  80150e:	89 e5                	mov    %esp,%ebp
  801510:	56                   	push   %esi
  801511:	53                   	push   %ebx
  801512:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801515:	83 ec 0c             	sub    $0xc,%esp
  801518:	ff 75 08             	pushl  0x8(%ebp)
  80151b:	e8 f2 f7 ff ff       	call   800d12 <fd2data>
  801520:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801522:	83 c4 08             	add    $0x8,%esp
  801525:	68 4b 22 80 00       	push   $0x80224b
  80152a:	53                   	push   %ebx
  80152b:	e8 de f1 ff ff       	call   80070e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801530:	8b 46 04             	mov    0x4(%esi),%eax
  801533:	2b 06                	sub    (%esi),%eax
  801535:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80153b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801542:	00 00 00 
	stat->st_dev = &devpipe;
  801545:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80154c:	30 80 00 
	return 0;
}
  80154f:	b8 00 00 00 00       	mov    $0x0,%eax
  801554:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801557:	5b                   	pop    %ebx
  801558:	5e                   	pop    %esi
  801559:	5d                   	pop    %ebp
  80155a:	c3                   	ret    

0080155b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	53                   	push   %ebx
  80155f:	83 ec 0c             	sub    $0xc,%esp
  801562:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801565:	53                   	push   %ebx
  801566:	6a 00                	push   $0x0
  801568:	e8 29 f6 ff ff       	call   800b96 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80156d:	89 1c 24             	mov    %ebx,(%esp)
  801570:	e8 9d f7 ff ff       	call   800d12 <fd2data>
  801575:	83 c4 08             	add    $0x8,%esp
  801578:	50                   	push   %eax
  801579:	6a 00                	push   $0x0
  80157b:	e8 16 f6 ff ff       	call   800b96 <sys_page_unmap>
}
  801580:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801583:	c9                   	leave  
  801584:	c3                   	ret    

00801585 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801585:	55                   	push   %ebp
  801586:	89 e5                	mov    %esp,%ebp
  801588:	57                   	push   %edi
  801589:	56                   	push   %esi
  80158a:	53                   	push   %ebx
  80158b:	83 ec 1c             	sub    $0x1c,%esp
  80158e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801591:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801593:	a1 04 40 80 00       	mov    0x804004,%eax
  801598:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80159b:	83 ec 0c             	sub    $0xc,%esp
  80159e:	ff 75 e0             	pushl  -0x20(%ebp)
  8015a1:	e8 99 05 00 00       	call   801b3f <pageref>
  8015a6:	89 c3                	mov    %eax,%ebx
  8015a8:	89 3c 24             	mov    %edi,(%esp)
  8015ab:	e8 8f 05 00 00       	call   801b3f <pageref>
  8015b0:	83 c4 10             	add    $0x10,%esp
  8015b3:	39 c3                	cmp    %eax,%ebx
  8015b5:	0f 94 c1             	sete   %cl
  8015b8:	0f b6 c9             	movzbl %cl,%ecx
  8015bb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8015be:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8015c4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015c7:	39 ce                	cmp    %ecx,%esi
  8015c9:	74 1b                	je     8015e6 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8015cb:	39 c3                	cmp    %eax,%ebx
  8015cd:	75 c4                	jne    801593 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015cf:	8b 42 58             	mov    0x58(%edx),%eax
  8015d2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015d5:	50                   	push   %eax
  8015d6:	56                   	push   %esi
  8015d7:	68 52 22 80 00       	push   $0x802252
  8015dc:	e8 a8 eb ff ff       	call   800189 <cprintf>
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	eb ad                	jmp    801593 <_pipeisclosed+0xe>
	}
}
  8015e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ec:	5b                   	pop    %ebx
  8015ed:	5e                   	pop    %esi
  8015ee:	5f                   	pop    %edi
  8015ef:	5d                   	pop    %ebp
  8015f0:	c3                   	ret    

008015f1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8015f1:	55                   	push   %ebp
  8015f2:	89 e5                	mov    %esp,%ebp
  8015f4:	57                   	push   %edi
  8015f5:	56                   	push   %esi
  8015f6:	53                   	push   %ebx
  8015f7:	83 ec 28             	sub    $0x28,%esp
  8015fa:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8015fd:	56                   	push   %esi
  8015fe:	e8 0f f7 ff ff       	call   800d12 <fd2data>
  801603:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801605:	83 c4 10             	add    $0x10,%esp
  801608:	bf 00 00 00 00       	mov    $0x0,%edi
  80160d:	eb 4b                	jmp    80165a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80160f:	89 da                	mov    %ebx,%edx
  801611:	89 f0                	mov    %esi,%eax
  801613:	e8 6d ff ff ff       	call   801585 <_pipeisclosed>
  801618:	85 c0                	test   %eax,%eax
  80161a:	75 48                	jne    801664 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80161c:	e8 d1 f4 ff ff       	call   800af2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801621:	8b 43 04             	mov    0x4(%ebx),%eax
  801624:	8b 0b                	mov    (%ebx),%ecx
  801626:	8d 51 20             	lea    0x20(%ecx),%edx
  801629:	39 d0                	cmp    %edx,%eax
  80162b:	73 e2                	jae    80160f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80162d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801630:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801634:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801637:	89 c2                	mov    %eax,%edx
  801639:	c1 fa 1f             	sar    $0x1f,%edx
  80163c:	89 d1                	mov    %edx,%ecx
  80163e:	c1 e9 1b             	shr    $0x1b,%ecx
  801641:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801644:	83 e2 1f             	and    $0x1f,%edx
  801647:	29 ca                	sub    %ecx,%edx
  801649:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80164d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801651:	83 c0 01             	add    $0x1,%eax
  801654:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801657:	83 c7 01             	add    $0x1,%edi
  80165a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80165d:	75 c2                	jne    801621 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80165f:	8b 45 10             	mov    0x10(%ebp),%eax
  801662:	eb 05                	jmp    801669 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801664:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801669:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80166c:	5b                   	pop    %ebx
  80166d:	5e                   	pop    %esi
  80166e:	5f                   	pop    %edi
  80166f:	5d                   	pop    %ebp
  801670:	c3                   	ret    

00801671 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	57                   	push   %edi
  801675:	56                   	push   %esi
  801676:	53                   	push   %ebx
  801677:	83 ec 18             	sub    $0x18,%esp
  80167a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80167d:	57                   	push   %edi
  80167e:	e8 8f f6 ff ff       	call   800d12 <fd2data>
  801683:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801685:	83 c4 10             	add    $0x10,%esp
  801688:	bb 00 00 00 00       	mov    $0x0,%ebx
  80168d:	eb 3d                	jmp    8016cc <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80168f:	85 db                	test   %ebx,%ebx
  801691:	74 04                	je     801697 <devpipe_read+0x26>
				return i;
  801693:	89 d8                	mov    %ebx,%eax
  801695:	eb 44                	jmp    8016db <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801697:	89 f2                	mov    %esi,%edx
  801699:	89 f8                	mov    %edi,%eax
  80169b:	e8 e5 fe ff ff       	call   801585 <_pipeisclosed>
  8016a0:	85 c0                	test   %eax,%eax
  8016a2:	75 32                	jne    8016d6 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016a4:	e8 49 f4 ff ff       	call   800af2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016a9:	8b 06                	mov    (%esi),%eax
  8016ab:	3b 46 04             	cmp    0x4(%esi),%eax
  8016ae:	74 df                	je     80168f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016b0:	99                   	cltd   
  8016b1:	c1 ea 1b             	shr    $0x1b,%edx
  8016b4:	01 d0                	add    %edx,%eax
  8016b6:	83 e0 1f             	and    $0x1f,%eax
  8016b9:	29 d0                	sub    %edx,%eax
  8016bb:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016c3:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016c6:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016c9:	83 c3 01             	add    $0x1,%ebx
  8016cc:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016cf:	75 d8                	jne    8016a9 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8016d4:	eb 05                	jmp    8016db <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016d6:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016de:	5b                   	pop    %ebx
  8016df:	5e                   	pop    %esi
  8016e0:	5f                   	pop    %edi
  8016e1:	5d                   	pop    %ebp
  8016e2:	c3                   	ret    

008016e3 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8016e3:	55                   	push   %ebp
  8016e4:	89 e5                	mov    %esp,%ebp
  8016e6:	56                   	push   %esi
  8016e7:	53                   	push   %ebx
  8016e8:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8016eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ee:	50                   	push   %eax
  8016ef:	e8 35 f6 ff ff       	call   800d29 <fd_alloc>
  8016f4:	83 c4 10             	add    $0x10,%esp
  8016f7:	89 c2                	mov    %eax,%edx
  8016f9:	85 c0                	test   %eax,%eax
  8016fb:	0f 88 2c 01 00 00    	js     80182d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801701:	83 ec 04             	sub    $0x4,%esp
  801704:	68 07 04 00 00       	push   $0x407
  801709:	ff 75 f4             	pushl  -0xc(%ebp)
  80170c:	6a 00                	push   $0x0
  80170e:	e8 fe f3 ff ff       	call   800b11 <sys_page_alloc>
  801713:	83 c4 10             	add    $0x10,%esp
  801716:	89 c2                	mov    %eax,%edx
  801718:	85 c0                	test   %eax,%eax
  80171a:	0f 88 0d 01 00 00    	js     80182d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801720:	83 ec 0c             	sub    $0xc,%esp
  801723:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801726:	50                   	push   %eax
  801727:	e8 fd f5 ff ff       	call   800d29 <fd_alloc>
  80172c:	89 c3                	mov    %eax,%ebx
  80172e:	83 c4 10             	add    $0x10,%esp
  801731:	85 c0                	test   %eax,%eax
  801733:	0f 88 e2 00 00 00    	js     80181b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801739:	83 ec 04             	sub    $0x4,%esp
  80173c:	68 07 04 00 00       	push   $0x407
  801741:	ff 75 f0             	pushl  -0x10(%ebp)
  801744:	6a 00                	push   $0x0
  801746:	e8 c6 f3 ff ff       	call   800b11 <sys_page_alloc>
  80174b:	89 c3                	mov    %eax,%ebx
  80174d:	83 c4 10             	add    $0x10,%esp
  801750:	85 c0                	test   %eax,%eax
  801752:	0f 88 c3 00 00 00    	js     80181b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801758:	83 ec 0c             	sub    $0xc,%esp
  80175b:	ff 75 f4             	pushl  -0xc(%ebp)
  80175e:	e8 af f5 ff ff       	call   800d12 <fd2data>
  801763:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801765:	83 c4 0c             	add    $0xc,%esp
  801768:	68 07 04 00 00       	push   $0x407
  80176d:	50                   	push   %eax
  80176e:	6a 00                	push   $0x0
  801770:	e8 9c f3 ff ff       	call   800b11 <sys_page_alloc>
  801775:	89 c3                	mov    %eax,%ebx
  801777:	83 c4 10             	add    $0x10,%esp
  80177a:	85 c0                	test   %eax,%eax
  80177c:	0f 88 89 00 00 00    	js     80180b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801782:	83 ec 0c             	sub    $0xc,%esp
  801785:	ff 75 f0             	pushl  -0x10(%ebp)
  801788:	e8 85 f5 ff ff       	call   800d12 <fd2data>
  80178d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801794:	50                   	push   %eax
  801795:	6a 00                	push   $0x0
  801797:	56                   	push   %esi
  801798:	6a 00                	push   $0x0
  80179a:	e8 b5 f3 ff ff       	call   800b54 <sys_page_map>
  80179f:	89 c3                	mov    %eax,%ebx
  8017a1:	83 c4 20             	add    $0x20,%esp
  8017a4:	85 c0                	test   %eax,%eax
  8017a6:	78 55                	js     8017fd <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017a8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017bd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017cb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017d2:	83 ec 0c             	sub    $0xc,%esp
  8017d5:	ff 75 f4             	pushl  -0xc(%ebp)
  8017d8:	e8 25 f5 ff ff       	call   800d02 <fd2num>
  8017dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017e0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017e2:	83 c4 04             	add    $0x4,%esp
  8017e5:	ff 75 f0             	pushl  -0x10(%ebp)
  8017e8:	e8 15 f5 ff ff       	call   800d02 <fd2num>
  8017ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017f0:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8017f3:	83 c4 10             	add    $0x10,%esp
  8017f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017fb:	eb 30                	jmp    80182d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8017fd:	83 ec 08             	sub    $0x8,%esp
  801800:	56                   	push   %esi
  801801:	6a 00                	push   $0x0
  801803:	e8 8e f3 ff ff       	call   800b96 <sys_page_unmap>
  801808:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80180b:	83 ec 08             	sub    $0x8,%esp
  80180e:	ff 75 f0             	pushl  -0x10(%ebp)
  801811:	6a 00                	push   $0x0
  801813:	e8 7e f3 ff ff       	call   800b96 <sys_page_unmap>
  801818:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80181b:	83 ec 08             	sub    $0x8,%esp
  80181e:	ff 75 f4             	pushl  -0xc(%ebp)
  801821:	6a 00                	push   $0x0
  801823:	e8 6e f3 ff ff       	call   800b96 <sys_page_unmap>
  801828:	83 c4 10             	add    $0x10,%esp
  80182b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80182d:	89 d0                	mov    %edx,%eax
  80182f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801832:	5b                   	pop    %ebx
  801833:	5e                   	pop    %esi
  801834:	5d                   	pop    %ebp
  801835:	c3                   	ret    

00801836 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801836:	55                   	push   %ebp
  801837:	89 e5                	mov    %esp,%ebp
  801839:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80183c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80183f:	50                   	push   %eax
  801840:	ff 75 08             	pushl  0x8(%ebp)
  801843:	e8 30 f5 ff ff       	call   800d78 <fd_lookup>
  801848:	83 c4 10             	add    $0x10,%esp
  80184b:	85 c0                	test   %eax,%eax
  80184d:	78 18                	js     801867 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80184f:	83 ec 0c             	sub    $0xc,%esp
  801852:	ff 75 f4             	pushl  -0xc(%ebp)
  801855:	e8 b8 f4 ff ff       	call   800d12 <fd2data>
	return _pipeisclosed(fd, p);
  80185a:	89 c2                	mov    %eax,%edx
  80185c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80185f:	e8 21 fd ff ff       	call   801585 <_pipeisclosed>
  801864:	83 c4 10             	add    $0x10,%esp
}
  801867:	c9                   	leave  
  801868:	c3                   	ret    

00801869 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801869:	55                   	push   %ebp
  80186a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80186c:	b8 00 00 00 00       	mov    $0x0,%eax
  801871:	5d                   	pop    %ebp
  801872:	c3                   	ret    

00801873 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801873:	55                   	push   %ebp
  801874:	89 e5                	mov    %esp,%ebp
  801876:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801879:	68 6a 22 80 00       	push   $0x80226a
  80187e:	ff 75 0c             	pushl  0xc(%ebp)
  801881:	e8 88 ee ff ff       	call   80070e <strcpy>
	return 0;
}
  801886:	b8 00 00 00 00       	mov    $0x0,%eax
  80188b:	c9                   	leave  
  80188c:	c3                   	ret    

0080188d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80188d:	55                   	push   %ebp
  80188e:	89 e5                	mov    %esp,%ebp
  801890:	57                   	push   %edi
  801891:	56                   	push   %esi
  801892:	53                   	push   %ebx
  801893:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801899:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80189e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018a4:	eb 2d                	jmp    8018d3 <devcons_write+0x46>
		m = n - tot;
  8018a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018a9:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8018ab:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018ae:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8018b3:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018b6:	83 ec 04             	sub    $0x4,%esp
  8018b9:	53                   	push   %ebx
  8018ba:	03 45 0c             	add    0xc(%ebp),%eax
  8018bd:	50                   	push   %eax
  8018be:	57                   	push   %edi
  8018bf:	e8 dc ef ff ff       	call   8008a0 <memmove>
		sys_cputs(buf, m);
  8018c4:	83 c4 08             	add    $0x8,%esp
  8018c7:	53                   	push   %ebx
  8018c8:	57                   	push   %edi
  8018c9:	e8 87 f1 ff ff       	call   800a55 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018ce:	01 de                	add    %ebx,%esi
  8018d0:	83 c4 10             	add    $0x10,%esp
  8018d3:	89 f0                	mov    %esi,%eax
  8018d5:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018d8:	72 cc                	jb     8018a6 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8018da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018dd:	5b                   	pop    %ebx
  8018de:	5e                   	pop    %esi
  8018df:	5f                   	pop    %edi
  8018e0:	5d                   	pop    %ebp
  8018e1:	c3                   	ret    

008018e2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018e2:	55                   	push   %ebp
  8018e3:	89 e5                	mov    %esp,%ebp
  8018e5:	83 ec 08             	sub    $0x8,%esp
  8018e8:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8018ed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018f1:	74 2a                	je     80191d <devcons_read+0x3b>
  8018f3:	eb 05                	jmp    8018fa <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8018f5:	e8 f8 f1 ff ff       	call   800af2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8018fa:	e8 74 f1 ff ff       	call   800a73 <sys_cgetc>
  8018ff:	85 c0                	test   %eax,%eax
  801901:	74 f2                	je     8018f5 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801903:	85 c0                	test   %eax,%eax
  801905:	78 16                	js     80191d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801907:	83 f8 04             	cmp    $0x4,%eax
  80190a:	74 0c                	je     801918 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80190c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80190f:	88 02                	mov    %al,(%edx)
	return 1;
  801911:	b8 01 00 00 00       	mov    $0x1,%eax
  801916:	eb 05                	jmp    80191d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801918:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80191d:	c9                   	leave  
  80191e:	c3                   	ret    

0080191f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80191f:	55                   	push   %ebp
  801920:	89 e5                	mov    %esp,%ebp
  801922:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801925:	8b 45 08             	mov    0x8(%ebp),%eax
  801928:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80192b:	6a 01                	push   $0x1
  80192d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801930:	50                   	push   %eax
  801931:	e8 1f f1 ff ff       	call   800a55 <sys_cputs>
}
  801936:	83 c4 10             	add    $0x10,%esp
  801939:	c9                   	leave  
  80193a:	c3                   	ret    

0080193b <getchar>:

int
getchar(void)
{
  80193b:	55                   	push   %ebp
  80193c:	89 e5                	mov    %esp,%ebp
  80193e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801941:	6a 01                	push   $0x1
  801943:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801946:	50                   	push   %eax
  801947:	6a 00                	push   $0x0
  801949:	e8 90 f6 ff ff       	call   800fde <read>
	if (r < 0)
  80194e:	83 c4 10             	add    $0x10,%esp
  801951:	85 c0                	test   %eax,%eax
  801953:	78 0f                	js     801964 <getchar+0x29>
		return r;
	if (r < 1)
  801955:	85 c0                	test   %eax,%eax
  801957:	7e 06                	jle    80195f <getchar+0x24>
		return -E_EOF;
	return c;
  801959:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80195d:	eb 05                	jmp    801964 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80195f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801964:	c9                   	leave  
  801965:	c3                   	ret    

00801966 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801966:	55                   	push   %ebp
  801967:	89 e5                	mov    %esp,%ebp
  801969:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80196c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80196f:	50                   	push   %eax
  801970:	ff 75 08             	pushl  0x8(%ebp)
  801973:	e8 00 f4 ff ff       	call   800d78 <fd_lookup>
  801978:	83 c4 10             	add    $0x10,%esp
  80197b:	85 c0                	test   %eax,%eax
  80197d:	78 11                	js     801990 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80197f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801982:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801988:	39 10                	cmp    %edx,(%eax)
  80198a:	0f 94 c0             	sete   %al
  80198d:	0f b6 c0             	movzbl %al,%eax
}
  801990:	c9                   	leave  
  801991:	c3                   	ret    

00801992 <opencons>:

int
opencons(void)
{
  801992:	55                   	push   %ebp
  801993:	89 e5                	mov    %esp,%ebp
  801995:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801998:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80199b:	50                   	push   %eax
  80199c:	e8 88 f3 ff ff       	call   800d29 <fd_alloc>
  8019a1:	83 c4 10             	add    $0x10,%esp
		return r;
  8019a4:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019a6:	85 c0                	test   %eax,%eax
  8019a8:	78 3e                	js     8019e8 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019aa:	83 ec 04             	sub    $0x4,%esp
  8019ad:	68 07 04 00 00       	push   $0x407
  8019b2:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b5:	6a 00                	push   $0x0
  8019b7:	e8 55 f1 ff ff       	call   800b11 <sys_page_alloc>
  8019bc:	83 c4 10             	add    $0x10,%esp
		return r;
  8019bf:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019c1:	85 c0                	test   %eax,%eax
  8019c3:	78 23                	js     8019e8 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8019c5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ce:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019da:	83 ec 0c             	sub    $0xc,%esp
  8019dd:	50                   	push   %eax
  8019de:	e8 1f f3 ff ff       	call   800d02 <fd2num>
  8019e3:	89 c2                	mov    %eax,%edx
  8019e5:	83 c4 10             	add    $0x10,%esp
}
  8019e8:	89 d0                	mov    %edx,%eax
  8019ea:	c9                   	leave  
  8019eb:	c3                   	ret    

008019ec <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019ec:	55                   	push   %ebp
  8019ed:	89 e5                	mov    %esp,%ebp
  8019ef:	56                   	push   %esi
  8019f0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019f1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019f4:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8019fa:	e8 d4 f0 ff ff       	call   800ad3 <sys_getenvid>
  8019ff:	83 ec 0c             	sub    $0xc,%esp
  801a02:	ff 75 0c             	pushl  0xc(%ebp)
  801a05:	ff 75 08             	pushl  0x8(%ebp)
  801a08:	56                   	push   %esi
  801a09:	50                   	push   %eax
  801a0a:	68 78 22 80 00       	push   $0x802278
  801a0f:	e8 75 e7 ff ff       	call   800189 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a14:	83 c4 18             	add    $0x18,%esp
  801a17:	53                   	push   %ebx
  801a18:	ff 75 10             	pushl  0x10(%ebp)
  801a1b:	e8 18 e7 ff ff       	call   800138 <vcprintf>
	cprintf("\n");
  801a20:	c7 04 24 63 22 80 00 	movl   $0x802263,(%esp)
  801a27:	e8 5d e7 ff ff       	call   800189 <cprintf>
  801a2c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a2f:	cc                   	int3   
  801a30:	eb fd                	jmp    801a2f <_panic+0x43>

00801a32 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a32:	55                   	push   %ebp
  801a33:	89 e5                	mov    %esp,%ebp
  801a35:	56                   	push   %esi
  801a36:	53                   	push   %ebx
  801a37:	8b 75 08             	mov    0x8(%ebp),%esi
  801a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801a40:	85 c0                	test   %eax,%eax
  801a42:	75 12                	jne    801a56 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801a44:	83 ec 0c             	sub    $0xc,%esp
  801a47:	68 00 00 c0 ee       	push   $0xeec00000
  801a4c:	e8 70 f2 ff ff       	call   800cc1 <sys_ipc_recv>
  801a51:	83 c4 10             	add    $0x10,%esp
  801a54:	eb 0c                	jmp    801a62 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801a56:	83 ec 0c             	sub    $0xc,%esp
  801a59:	50                   	push   %eax
  801a5a:	e8 62 f2 ff ff       	call   800cc1 <sys_ipc_recv>
  801a5f:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801a62:	85 f6                	test   %esi,%esi
  801a64:	0f 95 c1             	setne  %cl
  801a67:	85 db                	test   %ebx,%ebx
  801a69:	0f 95 c2             	setne  %dl
  801a6c:	84 d1                	test   %dl,%cl
  801a6e:	74 09                	je     801a79 <ipc_recv+0x47>
  801a70:	89 c2                	mov    %eax,%edx
  801a72:	c1 ea 1f             	shr    $0x1f,%edx
  801a75:	84 d2                	test   %dl,%dl
  801a77:	75 24                	jne    801a9d <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801a79:	85 f6                	test   %esi,%esi
  801a7b:	74 0a                	je     801a87 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801a7d:	a1 04 40 80 00       	mov    0x804004,%eax
  801a82:	8b 40 74             	mov    0x74(%eax),%eax
  801a85:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801a87:	85 db                	test   %ebx,%ebx
  801a89:	74 0a                	je     801a95 <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  801a8b:	a1 04 40 80 00       	mov    0x804004,%eax
  801a90:	8b 40 78             	mov    0x78(%eax),%eax
  801a93:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801a95:	a1 04 40 80 00       	mov    0x804004,%eax
  801a9a:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a9d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa0:	5b                   	pop    %ebx
  801aa1:	5e                   	pop    %esi
  801aa2:	5d                   	pop    %ebp
  801aa3:	c3                   	ret    

00801aa4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801aa4:	55                   	push   %ebp
  801aa5:	89 e5                	mov    %esp,%ebp
  801aa7:	57                   	push   %edi
  801aa8:	56                   	push   %esi
  801aa9:	53                   	push   %ebx
  801aaa:	83 ec 0c             	sub    $0xc,%esp
  801aad:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ab0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ab3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801ab6:	85 db                	test   %ebx,%ebx
  801ab8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801abd:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801ac0:	ff 75 14             	pushl  0x14(%ebp)
  801ac3:	53                   	push   %ebx
  801ac4:	56                   	push   %esi
  801ac5:	57                   	push   %edi
  801ac6:	e8 d3 f1 ff ff       	call   800c9e <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801acb:	89 c2                	mov    %eax,%edx
  801acd:	c1 ea 1f             	shr    $0x1f,%edx
  801ad0:	83 c4 10             	add    $0x10,%esp
  801ad3:	84 d2                	test   %dl,%dl
  801ad5:	74 17                	je     801aee <ipc_send+0x4a>
  801ad7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ada:	74 12                	je     801aee <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801adc:	50                   	push   %eax
  801add:	68 9c 22 80 00       	push   $0x80229c
  801ae2:	6a 47                	push   $0x47
  801ae4:	68 aa 22 80 00       	push   $0x8022aa
  801ae9:	e8 fe fe ff ff       	call   8019ec <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801aee:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801af1:	75 07                	jne    801afa <ipc_send+0x56>
			sys_yield();
  801af3:	e8 fa ef ff ff       	call   800af2 <sys_yield>
  801af8:	eb c6                	jmp    801ac0 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801afa:	85 c0                	test   %eax,%eax
  801afc:	75 c2                	jne    801ac0 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801afe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b01:	5b                   	pop    %ebx
  801b02:	5e                   	pop    %esi
  801b03:	5f                   	pop    %edi
  801b04:	5d                   	pop    %ebp
  801b05:	c3                   	ret    

00801b06 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b06:	55                   	push   %ebp
  801b07:	89 e5                	mov    %esp,%ebp
  801b09:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b0c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b11:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b14:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b1a:	8b 52 50             	mov    0x50(%edx),%edx
  801b1d:	39 ca                	cmp    %ecx,%edx
  801b1f:	75 0d                	jne    801b2e <ipc_find_env+0x28>
			return envs[i].env_id;
  801b21:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b24:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b29:	8b 40 48             	mov    0x48(%eax),%eax
  801b2c:	eb 0f                	jmp    801b3d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b2e:	83 c0 01             	add    $0x1,%eax
  801b31:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b36:	75 d9                	jne    801b11 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b38:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b3d:	5d                   	pop    %ebp
  801b3e:	c3                   	ret    

00801b3f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b3f:	55                   	push   %ebp
  801b40:	89 e5                	mov    %esp,%ebp
  801b42:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b45:	89 d0                	mov    %edx,%eax
  801b47:	c1 e8 16             	shr    $0x16,%eax
  801b4a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b51:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b56:	f6 c1 01             	test   $0x1,%cl
  801b59:	74 1d                	je     801b78 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b5b:	c1 ea 0c             	shr    $0xc,%edx
  801b5e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b65:	f6 c2 01             	test   $0x1,%dl
  801b68:	74 0e                	je     801b78 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b6a:	c1 ea 0c             	shr    $0xc,%edx
  801b6d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b74:	ef 
  801b75:	0f b7 c0             	movzwl %ax,%eax
}
  801b78:	5d                   	pop    %ebp
  801b79:	c3                   	ret    
  801b7a:	66 90                	xchg   %ax,%ax
  801b7c:	66 90                	xchg   %ax,%ax
  801b7e:	66 90                	xchg   %ax,%ax

00801b80 <__udivdi3>:
  801b80:	55                   	push   %ebp
  801b81:	57                   	push   %edi
  801b82:	56                   	push   %esi
  801b83:	53                   	push   %ebx
  801b84:	83 ec 1c             	sub    $0x1c,%esp
  801b87:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b97:	85 f6                	test   %esi,%esi
  801b99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b9d:	89 ca                	mov    %ecx,%edx
  801b9f:	89 f8                	mov    %edi,%eax
  801ba1:	75 3d                	jne    801be0 <__udivdi3+0x60>
  801ba3:	39 cf                	cmp    %ecx,%edi
  801ba5:	0f 87 c5 00 00 00    	ja     801c70 <__udivdi3+0xf0>
  801bab:	85 ff                	test   %edi,%edi
  801bad:	89 fd                	mov    %edi,%ebp
  801baf:	75 0b                	jne    801bbc <__udivdi3+0x3c>
  801bb1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bb6:	31 d2                	xor    %edx,%edx
  801bb8:	f7 f7                	div    %edi
  801bba:	89 c5                	mov    %eax,%ebp
  801bbc:	89 c8                	mov    %ecx,%eax
  801bbe:	31 d2                	xor    %edx,%edx
  801bc0:	f7 f5                	div    %ebp
  801bc2:	89 c1                	mov    %eax,%ecx
  801bc4:	89 d8                	mov    %ebx,%eax
  801bc6:	89 cf                	mov    %ecx,%edi
  801bc8:	f7 f5                	div    %ebp
  801bca:	89 c3                	mov    %eax,%ebx
  801bcc:	89 d8                	mov    %ebx,%eax
  801bce:	89 fa                	mov    %edi,%edx
  801bd0:	83 c4 1c             	add    $0x1c,%esp
  801bd3:	5b                   	pop    %ebx
  801bd4:	5e                   	pop    %esi
  801bd5:	5f                   	pop    %edi
  801bd6:	5d                   	pop    %ebp
  801bd7:	c3                   	ret    
  801bd8:	90                   	nop
  801bd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801be0:	39 ce                	cmp    %ecx,%esi
  801be2:	77 74                	ja     801c58 <__udivdi3+0xd8>
  801be4:	0f bd fe             	bsr    %esi,%edi
  801be7:	83 f7 1f             	xor    $0x1f,%edi
  801bea:	0f 84 98 00 00 00    	je     801c88 <__udivdi3+0x108>
  801bf0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801bf5:	89 f9                	mov    %edi,%ecx
  801bf7:	89 c5                	mov    %eax,%ebp
  801bf9:	29 fb                	sub    %edi,%ebx
  801bfb:	d3 e6                	shl    %cl,%esi
  801bfd:	89 d9                	mov    %ebx,%ecx
  801bff:	d3 ed                	shr    %cl,%ebp
  801c01:	89 f9                	mov    %edi,%ecx
  801c03:	d3 e0                	shl    %cl,%eax
  801c05:	09 ee                	or     %ebp,%esi
  801c07:	89 d9                	mov    %ebx,%ecx
  801c09:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c0d:	89 d5                	mov    %edx,%ebp
  801c0f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c13:	d3 ed                	shr    %cl,%ebp
  801c15:	89 f9                	mov    %edi,%ecx
  801c17:	d3 e2                	shl    %cl,%edx
  801c19:	89 d9                	mov    %ebx,%ecx
  801c1b:	d3 e8                	shr    %cl,%eax
  801c1d:	09 c2                	or     %eax,%edx
  801c1f:	89 d0                	mov    %edx,%eax
  801c21:	89 ea                	mov    %ebp,%edx
  801c23:	f7 f6                	div    %esi
  801c25:	89 d5                	mov    %edx,%ebp
  801c27:	89 c3                	mov    %eax,%ebx
  801c29:	f7 64 24 0c          	mull   0xc(%esp)
  801c2d:	39 d5                	cmp    %edx,%ebp
  801c2f:	72 10                	jb     801c41 <__udivdi3+0xc1>
  801c31:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c35:	89 f9                	mov    %edi,%ecx
  801c37:	d3 e6                	shl    %cl,%esi
  801c39:	39 c6                	cmp    %eax,%esi
  801c3b:	73 07                	jae    801c44 <__udivdi3+0xc4>
  801c3d:	39 d5                	cmp    %edx,%ebp
  801c3f:	75 03                	jne    801c44 <__udivdi3+0xc4>
  801c41:	83 eb 01             	sub    $0x1,%ebx
  801c44:	31 ff                	xor    %edi,%edi
  801c46:	89 d8                	mov    %ebx,%eax
  801c48:	89 fa                	mov    %edi,%edx
  801c4a:	83 c4 1c             	add    $0x1c,%esp
  801c4d:	5b                   	pop    %ebx
  801c4e:	5e                   	pop    %esi
  801c4f:	5f                   	pop    %edi
  801c50:	5d                   	pop    %ebp
  801c51:	c3                   	ret    
  801c52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c58:	31 ff                	xor    %edi,%edi
  801c5a:	31 db                	xor    %ebx,%ebx
  801c5c:	89 d8                	mov    %ebx,%eax
  801c5e:	89 fa                	mov    %edi,%edx
  801c60:	83 c4 1c             	add    $0x1c,%esp
  801c63:	5b                   	pop    %ebx
  801c64:	5e                   	pop    %esi
  801c65:	5f                   	pop    %edi
  801c66:	5d                   	pop    %ebp
  801c67:	c3                   	ret    
  801c68:	90                   	nop
  801c69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c70:	89 d8                	mov    %ebx,%eax
  801c72:	f7 f7                	div    %edi
  801c74:	31 ff                	xor    %edi,%edi
  801c76:	89 c3                	mov    %eax,%ebx
  801c78:	89 d8                	mov    %ebx,%eax
  801c7a:	89 fa                	mov    %edi,%edx
  801c7c:	83 c4 1c             	add    $0x1c,%esp
  801c7f:	5b                   	pop    %ebx
  801c80:	5e                   	pop    %esi
  801c81:	5f                   	pop    %edi
  801c82:	5d                   	pop    %ebp
  801c83:	c3                   	ret    
  801c84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c88:	39 ce                	cmp    %ecx,%esi
  801c8a:	72 0c                	jb     801c98 <__udivdi3+0x118>
  801c8c:	31 db                	xor    %ebx,%ebx
  801c8e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c92:	0f 87 34 ff ff ff    	ja     801bcc <__udivdi3+0x4c>
  801c98:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c9d:	e9 2a ff ff ff       	jmp    801bcc <__udivdi3+0x4c>
  801ca2:	66 90                	xchg   %ax,%ax
  801ca4:	66 90                	xchg   %ax,%ax
  801ca6:	66 90                	xchg   %ax,%ax
  801ca8:	66 90                	xchg   %ax,%ax
  801caa:	66 90                	xchg   %ax,%ax
  801cac:	66 90                	xchg   %ax,%ax
  801cae:	66 90                	xchg   %ax,%ax

00801cb0 <__umoddi3>:
  801cb0:	55                   	push   %ebp
  801cb1:	57                   	push   %edi
  801cb2:	56                   	push   %esi
  801cb3:	53                   	push   %ebx
  801cb4:	83 ec 1c             	sub    $0x1c,%esp
  801cb7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801cbb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cbf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cc7:	85 d2                	test   %edx,%edx
  801cc9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ccd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cd1:	89 f3                	mov    %esi,%ebx
  801cd3:	89 3c 24             	mov    %edi,(%esp)
  801cd6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cda:	75 1c                	jne    801cf8 <__umoddi3+0x48>
  801cdc:	39 f7                	cmp    %esi,%edi
  801cde:	76 50                	jbe    801d30 <__umoddi3+0x80>
  801ce0:	89 c8                	mov    %ecx,%eax
  801ce2:	89 f2                	mov    %esi,%edx
  801ce4:	f7 f7                	div    %edi
  801ce6:	89 d0                	mov    %edx,%eax
  801ce8:	31 d2                	xor    %edx,%edx
  801cea:	83 c4 1c             	add    $0x1c,%esp
  801ced:	5b                   	pop    %ebx
  801cee:	5e                   	pop    %esi
  801cef:	5f                   	pop    %edi
  801cf0:	5d                   	pop    %ebp
  801cf1:	c3                   	ret    
  801cf2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cf8:	39 f2                	cmp    %esi,%edx
  801cfa:	89 d0                	mov    %edx,%eax
  801cfc:	77 52                	ja     801d50 <__umoddi3+0xa0>
  801cfe:	0f bd ea             	bsr    %edx,%ebp
  801d01:	83 f5 1f             	xor    $0x1f,%ebp
  801d04:	75 5a                	jne    801d60 <__umoddi3+0xb0>
  801d06:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d0a:	0f 82 e0 00 00 00    	jb     801df0 <__umoddi3+0x140>
  801d10:	39 0c 24             	cmp    %ecx,(%esp)
  801d13:	0f 86 d7 00 00 00    	jbe    801df0 <__umoddi3+0x140>
  801d19:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d1d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d21:	83 c4 1c             	add    $0x1c,%esp
  801d24:	5b                   	pop    %ebx
  801d25:	5e                   	pop    %esi
  801d26:	5f                   	pop    %edi
  801d27:	5d                   	pop    %ebp
  801d28:	c3                   	ret    
  801d29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d30:	85 ff                	test   %edi,%edi
  801d32:	89 fd                	mov    %edi,%ebp
  801d34:	75 0b                	jne    801d41 <__umoddi3+0x91>
  801d36:	b8 01 00 00 00       	mov    $0x1,%eax
  801d3b:	31 d2                	xor    %edx,%edx
  801d3d:	f7 f7                	div    %edi
  801d3f:	89 c5                	mov    %eax,%ebp
  801d41:	89 f0                	mov    %esi,%eax
  801d43:	31 d2                	xor    %edx,%edx
  801d45:	f7 f5                	div    %ebp
  801d47:	89 c8                	mov    %ecx,%eax
  801d49:	f7 f5                	div    %ebp
  801d4b:	89 d0                	mov    %edx,%eax
  801d4d:	eb 99                	jmp    801ce8 <__umoddi3+0x38>
  801d4f:	90                   	nop
  801d50:	89 c8                	mov    %ecx,%eax
  801d52:	89 f2                	mov    %esi,%edx
  801d54:	83 c4 1c             	add    $0x1c,%esp
  801d57:	5b                   	pop    %ebx
  801d58:	5e                   	pop    %esi
  801d59:	5f                   	pop    %edi
  801d5a:	5d                   	pop    %ebp
  801d5b:	c3                   	ret    
  801d5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d60:	8b 34 24             	mov    (%esp),%esi
  801d63:	bf 20 00 00 00       	mov    $0x20,%edi
  801d68:	89 e9                	mov    %ebp,%ecx
  801d6a:	29 ef                	sub    %ebp,%edi
  801d6c:	d3 e0                	shl    %cl,%eax
  801d6e:	89 f9                	mov    %edi,%ecx
  801d70:	89 f2                	mov    %esi,%edx
  801d72:	d3 ea                	shr    %cl,%edx
  801d74:	89 e9                	mov    %ebp,%ecx
  801d76:	09 c2                	or     %eax,%edx
  801d78:	89 d8                	mov    %ebx,%eax
  801d7a:	89 14 24             	mov    %edx,(%esp)
  801d7d:	89 f2                	mov    %esi,%edx
  801d7f:	d3 e2                	shl    %cl,%edx
  801d81:	89 f9                	mov    %edi,%ecx
  801d83:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d87:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d8b:	d3 e8                	shr    %cl,%eax
  801d8d:	89 e9                	mov    %ebp,%ecx
  801d8f:	89 c6                	mov    %eax,%esi
  801d91:	d3 e3                	shl    %cl,%ebx
  801d93:	89 f9                	mov    %edi,%ecx
  801d95:	89 d0                	mov    %edx,%eax
  801d97:	d3 e8                	shr    %cl,%eax
  801d99:	89 e9                	mov    %ebp,%ecx
  801d9b:	09 d8                	or     %ebx,%eax
  801d9d:	89 d3                	mov    %edx,%ebx
  801d9f:	89 f2                	mov    %esi,%edx
  801da1:	f7 34 24             	divl   (%esp)
  801da4:	89 d6                	mov    %edx,%esi
  801da6:	d3 e3                	shl    %cl,%ebx
  801da8:	f7 64 24 04          	mull   0x4(%esp)
  801dac:	39 d6                	cmp    %edx,%esi
  801dae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801db2:	89 d1                	mov    %edx,%ecx
  801db4:	89 c3                	mov    %eax,%ebx
  801db6:	72 08                	jb     801dc0 <__umoddi3+0x110>
  801db8:	75 11                	jne    801dcb <__umoddi3+0x11b>
  801dba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dbe:	73 0b                	jae    801dcb <__umoddi3+0x11b>
  801dc0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801dc4:	1b 14 24             	sbb    (%esp),%edx
  801dc7:	89 d1                	mov    %edx,%ecx
  801dc9:	89 c3                	mov    %eax,%ebx
  801dcb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801dcf:	29 da                	sub    %ebx,%edx
  801dd1:	19 ce                	sbb    %ecx,%esi
  801dd3:	89 f9                	mov    %edi,%ecx
  801dd5:	89 f0                	mov    %esi,%eax
  801dd7:	d3 e0                	shl    %cl,%eax
  801dd9:	89 e9                	mov    %ebp,%ecx
  801ddb:	d3 ea                	shr    %cl,%edx
  801ddd:	89 e9                	mov    %ebp,%ecx
  801ddf:	d3 ee                	shr    %cl,%esi
  801de1:	09 d0                	or     %edx,%eax
  801de3:	89 f2                	mov    %esi,%edx
  801de5:	83 c4 1c             	add    $0x1c,%esp
  801de8:	5b                   	pop    %ebx
  801de9:	5e                   	pop    %esi
  801dea:	5f                   	pop    %edi
  801deb:	5d                   	pop    %ebp
  801dec:	c3                   	ret    
  801ded:	8d 76 00             	lea    0x0(%esi),%esi
  801df0:	29 f9                	sub    %edi,%ecx
  801df2:	19 d6                	sbb    %edx,%esi
  801df4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801df8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dfc:	e9 18 ff ff ff       	jmp    801d19 <__umoddi3+0x69>
