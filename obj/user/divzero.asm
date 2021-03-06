
obj/user/divzero.debug:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  800039:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 20 24 80 00       	push   $0x802420
  800056:	e8 1b 01 00 00       	call   800176 <cprintf>
}
  80005b:	83 c4 10             	add    $0x10,%esp
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800068:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80006b:	e8 50 0a 00 00       	call   800ac0 <sys_getenvid>
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  80007b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800080:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800085:	85 db                	test   %ebx,%ebx
  800087:	7e 07                	jle    800090 <libmain+0x30>
		binaryname = argv[0];
  800089:	8b 06                	mov    (%esi),%eax
  80008b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800090:	83 ec 08             	sub    $0x8,%esp
  800093:	56                   	push   %esi
  800094:	53                   	push   %ebx
  800095:	e8 99 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009a:	e8 2a 00 00 00       	call   8000c9 <exit>
}
  80009f:	83 c4 10             	add    $0x10,%esp
  8000a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a5:	5b                   	pop    %ebx
  8000a6:	5e                   	pop    %esi
  8000a7:	5d                   	pop    %ebp
  8000a8:	c3                   	ret    

008000a9 <thread_main>:

/*Lab 7: Multithreading thread main routine*/
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  8000a9:	55                   	push   %ebp
  8000aa:	89 e5                	mov    %esp,%ebp
  8000ac:	83 ec 08             	sub    $0x8,%esp
	void (*func)(void) = (void (*)(void))eip;
  8000af:	a1 0c 40 80 00       	mov    0x80400c,%eax
	func();
  8000b4:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8000b6:	e8 05 0a 00 00       	call   800ac0 <sys_getenvid>
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	50                   	push   %eax
  8000bf:	e8 4b 0c 00 00       	call   800d0f <sys_thread_free>
}
  8000c4:	83 c4 10             	add    $0x10,%esp
  8000c7:	c9                   	leave  
  8000c8:	c3                   	ret    

008000c9 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c9:	55                   	push   %ebp
  8000ca:	89 e5                	mov    %esp,%ebp
  8000cc:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000cf:	e8 43 13 00 00       	call   801417 <close_all>
	sys_env_destroy(0);
  8000d4:	83 ec 0c             	sub    $0xc,%esp
  8000d7:	6a 00                	push   $0x0
  8000d9:	e8 a1 09 00 00       	call   800a7f <sys_env_destroy>
}
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	c9                   	leave  
  8000e2:	c3                   	ret    

008000e3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	53                   	push   %ebx
  8000e7:	83 ec 04             	sub    $0x4,%esp
  8000ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ed:	8b 13                	mov    (%ebx),%edx
  8000ef:	8d 42 01             	lea    0x1(%edx),%eax
  8000f2:	89 03                	mov    %eax,(%ebx)
  8000f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000fb:	3d ff 00 00 00       	cmp    $0xff,%eax
  800100:	75 1a                	jne    80011c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800102:	83 ec 08             	sub    $0x8,%esp
  800105:	68 ff 00 00 00       	push   $0xff
  80010a:	8d 43 08             	lea    0x8(%ebx),%eax
  80010d:	50                   	push   %eax
  80010e:	e8 2f 09 00 00       	call   800a42 <sys_cputs>
		b->idx = 0;
  800113:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800119:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80011c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800120:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800123:	c9                   	leave  
  800124:	c3                   	ret    

00800125 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80012e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800135:	00 00 00 
	b.cnt = 0;
  800138:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800142:	ff 75 0c             	pushl  0xc(%ebp)
  800145:	ff 75 08             	pushl  0x8(%ebp)
  800148:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014e:	50                   	push   %eax
  80014f:	68 e3 00 80 00       	push   $0x8000e3
  800154:	e8 54 01 00 00       	call   8002ad <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800159:	83 c4 08             	add    $0x8,%esp
  80015c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800162:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800168:	50                   	push   %eax
  800169:	e8 d4 08 00 00       	call   800a42 <sys_cputs>

	return b.cnt;
}
  80016e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800174:	c9                   	leave  
  800175:	c3                   	ret    

00800176 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800176:	55                   	push   %ebp
  800177:	89 e5                	mov    %esp,%ebp
  800179:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80017c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80017f:	50                   	push   %eax
  800180:	ff 75 08             	pushl  0x8(%ebp)
  800183:	e8 9d ff ff ff       	call   800125 <vcprintf>
	va_end(ap);

	return cnt;
}
  800188:	c9                   	leave  
  800189:	c3                   	ret    

0080018a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80018a:	55                   	push   %ebp
  80018b:	89 e5                	mov    %esp,%ebp
  80018d:	57                   	push   %edi
  80018e:	56                   	push   %esi
  80018f:	53                   	push   %ebx
  800190:	83 ec 1c             	sub    $0x1c,%esp
  800193:	89 c7                	mov    %eax,%edi
  800195:	89 d6                	mov    %edx,%esi
  800197:	8b 45 08             	mov    0x8(%ebp),%eax
  80019a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001a0:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ab:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ae:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001b1:	39 d3                	cmp    %edx,%ebx
  8001b3:	72 05                	jb     8001ba <printnum+0x30>
  8001b5:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b8:	77 45                	ja     8001ff <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ba:	83 ec 0c             	sub    $0xc,%esp
  8001bd:	ff 75 18             	pushl  0x18(%ebp)
  8001c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8001c3:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001c6:	53                   	push   %ebx
  8001c7:	ff 75 10             	pushl  0x10(%ebp)
  8001ca:	83 ec 08             	sub    $0x8,%esp
  8001cd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d3:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d6:	ff 75 d8             	pushl  -0x28(%ebp)
  8001d9:	e8 a2 1f 00 00       	call   802180 <__udivdi3>
  8001de:	83 c4 18             	add    $0x18,%esp
  8001e1:	52                   	push   %edx
  8001e2:	50                   	push   %eax
  8001e3:	89 f2                	mov    %esi,%edx
  8001e5:	89 f8                	mov    %edi,%eax
  8001e7:	e8 9e ff ff ff       	call   80018a <printnum>
  8001ec:	83 c4 20             	add    $0x20,%esp
  8001ef:	eb 18                	jmp    800209 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001f1:	83 ec 08             	sub    $0x8,%esp
  8001f4:	56                   	push   %esi
  8001f5:	ff 75 18             	pushl  0x18(%ebp)
  8001f8:	ff d7                	call   *%edi
  8001fa:	83 c4 10             	add    $0x10,%esp
  8001fd:	eb 03                	jmp    800202 <printnum+0x78>
  8001ff:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800202:	83 eb 01             	sub    $0x1,%ebx
  800205:	85 db                	test   %ebx,%ebx
  800207:	7f e8                	jg     8001f1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800209:	83 ec 08             	sub    $0x8,%esp
  80020c:	56                   	push   %esi
  80020d:	83 ec 04             	sub    $0x4,%esp
  800210:	ff 75 e4             	pushl  -0x1c(%ebp)
  800213:	ff 75 e0             	pushl  -0x20(%ebp)
  800216:	ff 75 dc             	pushl  -0x24(%ebp)
  800219:	ff 75 d8             	pushl  -0x28(%ebp)
  80021c:	e8 8f 20 00 00       	call   8022b0 <__umoddi3>
  800221:	83 c4 14             	add    $0x14,%esp
  800224:	0f be 80 38 24 80 00 	movsbl 0x802438(%eax),%eax
  80022b:	50                   	push   %eax
  80022c:	ff d7                	call   *%edi
}
  80022e:	83 c4 10             	add    $0x10,%esp
  800231:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800234:	5b                   	pop    %ebx
  800235:	5e                   	pop    %esi
  800236:	5f                   	pop    %edi
  800237:	5d                   	pop    %ebp
  800238:	c3                   	ret    

00800239 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80023c:	83 fa 01             	cmp    $0x1,%edx
  80023f:	7e 0e                	jle    80024f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800241:	8b 10                	mov    (%eax),%edx
  800243:	8d 4a 08             	lea    0x8(%edx),%ecx
  800246:	89 08                	mov    %ecx,(%eax)
  800248:	8b 02                	mov    (%edx),%eax
  80024a:	8b 52 04             	mov    0x4(%edx),%edx
  80024d:	eb 22                	jmp    800271 <getuint+0x38>
	else if (lflag)
  80024f:	85 d2                	test   %edx,%edx
  800251:	74 10                	je     800263 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800253:	8b 10                	mov    (%eax),%edx
  800255:	8d 4a 04             	lea    0x4(%edx),%ecx
  800258:	89 08                	mov    %ecx,(%eax)
  80025a:	8b 02                	mov    (%edx),%eax
  80025c:	ba 00 00 00 00       	mov    $0x0,%edx
  800261:	eb 0e                	jmp    800271 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800263:	8b 10                	mov    (%eax),%edx
  800265:	8d 4a 04             	lea    0x4(%edx),%ecx
  800268:	89 08                	mov    %ecx,(%eax)
  80026a:	8b 02                	mov    (%edx),%eax
  80026c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    

00800273 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800279:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80027d:	8b 10                	mov    (%eax),%edx
  80027f:	3b 50 04             	cmp    0x4(%eax),%edx
  800282:	73 0a                	jae    80028e <sprintputch+0x1b>
		*b->buf++ = ch;
  800284:	8d 4a 01             	lea    0x1(%edx),%ecx
  800287:	89 08                	mov    %ecx,(%eax)
  800289:	8b 45 08             	mov    0x8(%ebp),%eax
  80028c:	88 02                	mov    %al,(%edx)
}
  80028e:	5d                   	pop    %ebp
  80028f:	c3                   	ret    

00800290 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800296:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800299:	50                   	push   %eax
  80029a:	ff 75 10             	pushl  0x10(%ebp)
  80029d:	ff 75 0c             	pushl  0xc(%ebp)
  8002a0:	ff 75 08             	pushl  0x8(%ebp)
  8002a3:	e8 05 00 00 00       	call   8002ad <vprintfmt>
	va_end(ap);
}
  8002a8:	83 c4 10             	add    $0x10,%esp
  8002ab:	c9                   	leave  
  8002ac:	c3                   	ret    

008002ad <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ad:	55                   	push   %ebp
  8002ae:	89 e5                	mov    %esp,%ebp
  8002b0:	57                   	push   %edi
  8002b1:	56                   	push   %esi
  8002b2:	53                   	push   %ebx
  8002b3:	83 ec 2c             	sub    $0x2c,%esp
  8002b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002bc:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002bf:	eb 12                	jmp    8002d3 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002c1:	85 c0                	test   %eax,%eax
  8002c3:	0f 84 89 03 00 00    	je     800652 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002c9:	83 ec 08             	sub    $0x8,%esp
  8002cc:	53                   	push   %ebx
  8002cd:	50                   	push   %eax
  8002ce:	ff d6                	call   *%esi
  8002d0:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002d3:	83 c7 01             	add    $0x1,%edi
  8002d6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002da:	83 f8 25             	cmp    $0x25,%eax
  8002dd:	75 e2                	jne    8002c1 <vprintfmt+0x14>
  8002df:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002e3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002ea:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002f1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fd:	eb 07                	jmp    800306 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800302:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800306:	8d 47 01             	lea    0x1(%edi),%eax
  800309:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80030c:	0f b6 07             	movzbl (%edi),%eax
  80030f:	0f b6 c8             	movzbl %al,%ecx
  800312:	83 e8 23             	sub    $0x23,%eax
  800315:	3c 55                	cmp    $0x55,%al
  800317:	0f 87 1a 03 00 00    	ja     800637 <vprintfmt+0x38a>
  80031d:	0f b6 c0             	movzbl %al,%eax
  800320:	ff 24 85 80 25 80 00 	jmp    *0x802580(,%eax,4)
  800327:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80032a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80032e:	eb d6                	jmp    800306 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800330:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800333:	b8 00 00 00 00       	mov    $0x0,%eax
  800338:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80033b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80033e:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800342:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800345:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800348:	83 fa 09             	cmp    $0x9,%edx
  80034b:	77 39                	ja     800386 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80034d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800350:	eb e9                	jmp    80033b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800352:	8b 45 14             	mov    0x14(%ebp),%eax
  800355:	8d 48 04             	lea    0x4(%eax),%ecx
  800358:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80035b:	8b 00                	mov    (%eax),%eax
  80035d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800360:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800363:	eb 27                	jmp    80038c <vprintfmt+0xdf>
  800365:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800368:	85 c0                	test   %eax,%eax
  80036a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80036f:	0f 49 c8             	cmovns %eax,%ecx
  800372:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800378:	eb 8c                	jmp    800306 <vprintfmt+0x59>
  80037a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80037d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800384:	eb 80                	jmp    800306 <vprintfmt+0x59>
  800386:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800389:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80038c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800390:	0f 89 70 ff ff ff    	jns    800306 <vprintfmt+0x59>
				width = precision, precision = -1;
  800396:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800399:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80039c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a3:	e9 5e ff ff ff       	jmp    800306 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003a8:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ae:	e9 53 ff ff ff       	jmp    800306 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b6:	8d 50 04             	lea    0x4(%eax),%edx
  8003b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8003bc:	83 ec 08             	sub    $0x8,%esp
  8003bf:	53                   	push   %ebx
  8003c0:	ff 30                	pushl  (%eax)
  8003c2:	ff d6                	call   *%esi
			break;
  8003c4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003ca:	e9 04 ff ff ff       	jmp    8002d3 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d2:	8d 50 04             	lea    0x4(%eax),%edx
  8003d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d8:	8b 00                	mov    (%eax),%eax
  8003da:	99                   	cltd   
  8003db:	31 d0                	xor    %edx,%eax
  8003dd:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003df:	83 f8 0f             	cmp    $0xf,%eax
  8003e2:	7f 0b                	jg     8003ef <vprintfmt+0x142>
  8003e4:	8b 14 85 e0 26 80 00 	mov    0x8026e0(,%eax,4),%edx
  8003eb:	85 d2                	test   %edx,%edx
  8003ed:	75 18                	jne    800407 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003ef:	50                   	push   %eax
  8003f0:	68 50 24 80 00       	push   $0x802450
  8003f5:	53                   	push   %ebx
  8003f6:	56                   	push   %esi
  8003f7:	e8 94 fe ff ff       	call   800290 <printfmt>
  8003fc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800402:	e9 cc fe ff ff       	jmp    8002d3 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800407:	52                   	push   %edx
  800408:	68 9d 28 80 00       	push   $0x80289d
  80040d:	53                   	push   %ebx
  80040e:	56                   	push   %esi
  80040f:	e8 7c fe ff ff       	call   800290 <printfmt>
  800414:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800417:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80041a:	e9 b4 fe ff ff       	jmp    8002d3 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80041f:	8b 45 14             	mov    0x14(%ebp),%eax
  800422:	8d 50 04             	lea    0x4(%eax),%edx
  800425:	89 55 14             	mov    %edx,0x14(%ebp)
  800428:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80042a:	85 ff                	test   %edi,%edi
  80042c:	b8 49 24 80 00       	mov    $0x802449,%eax
  800431:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800434:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800438:	0f 8e 94 00 00 00    	jle    8004d2 <vprintfmt+0x225>
  80043e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800442:	0f 84 98 00 00 00    	je     8004e0 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800448:	83 ec 08             	sub    $0x8,%esp
  80044b:	ff 75 d0             	pushl  -0x30(%ebp)
  80044e:	57                   	push   %edi
  80044f:	e8 86 02 00 00       	call   8006da <strnlen>
  800454:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800457:	29 c1                	sub    %eax,%ecx
  800459:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80045c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80045f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800463:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800466:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800469:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80046b:	eb 0f                	jmp    80047c <vprintfmt+0x1cf>
					putch(padc, putdat);
  80046d:	83 ec 08             	sub    $0x8,%esp
  800470:	53                   	push   %ebx
  800471:	ff 75 e0             	pushl  -0x20(%ebp)
  800474:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800476:	83 ef 01             	sub    $0x1,%edi
  800479:	83 c4 10             	add    $0x10,%esp
  80047c:	85 ff                	test   %edi,%edi
  80047e:	7f ed                	jg     80046d <vprintfmt+0x1c0>
  800480:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800483:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800486:	85 c9                	test   %ecx,%ecx
  800488:	b8 00 00 00 00       	mov    $0x0,%eax
  80048d:	0f 49 c1             	cmovns %ecx,%eax
  800490:	29 c1                	sub    %eax,%ecx
  800492:	89 75 08             	mov    %esi,0x8(%ebp)
  800495:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800498:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80049b:	89 cb                	mov    %ecx,%ebx
  80049d:	eb 4d                	jmp    8004ec <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80049f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004a3:	74 1b                	je     8004c0 <vprintfmt+0x213>
  8004a5:	0f be c0             	movsbl %al,%eax
  8004a8:	83 e8 20             	sub    $0x20,%eax
  8004ab:	83 f8 5e             	cmp    $0x5e,%eax
  8004ae:	76 10                	jbe    8004c0 <vprintfmt+0x213>
					putch('?', putdat);
  8004b0:	83 ec 08             	sub    $0x8,%esp
  8004b3:	ff 75 0c             	pushl  0xc(%ebp)
  8004b6:	6a 3f                	push   $0x3f
  8004b8:	ff 55 08             	call   *0x8(%ebp)
  8004bb:	83 c4 10             	add    $0x10,%esp
  8004be:	eb 0d                	jmp    8004cd <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004c0:	83 ec 08             	sub    $0x8,%esp
  8004c3:	ff 75 0c             	pushl  0xc(%ebp)
  8004c6:	52                   	push   %edx
  8004c7:	ff 55 08             	call   *0x8(%ebp)
  8004ca:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004cd:	83 eb 01             	sub    $0x1,%ebx
  8004d0:	eb 1a                	jmp    8004ec <vprintfmt+0x23f>
  8004d2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004db:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004de:	eb 0c                	jmp    8004ec <vprintfmt+0x23f>
  8004e0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ec:	83 c7 01             	add    $0x1,%edi
  8004ef:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f3:	0f be d0             	movsbl %al,%edx
  8004f6:	85 d2                	test   %edx,%edx
  8004f8:	74 23                	je     80051d <vprintfmt+0x270>
  8004fa:	85 f6                	test   %esi,%esi
  8004fc:	78 a1                	js     80049f <vprintfmt+0x1f2>
  8004fe:	83 ee 01             	sub    $0x1,%esi
  800501:	79 9c                	jns    80049f <vprintfmt+0x1f2>
  800503:	89 df                	mov    %ebx,%edi
  800505:	8b 75 08             	mov    0x8(%ebp),%esi
  800508:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050b:	eb 18                	jmp    800525 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	53                   	push   %ebx
  800511:	6a 20                	push   $0x20
  800513:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800515:	83 ef 01             	sub    $0x1,%edi
  800518:	83 c4 10             	add    $0x10,%esp
  80051b:	eb 08                	jmp    800525 <vprintfmt+0x278>
  80051d:	89 df                	mov    %ebx,%edi
  80051f:	8b 75 08             	mov    0x8(%ebp),%esi
  800522:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800525:	85 ff                	test   %edi,%edi
  800527:	7f e4                	jg     80050d <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800529:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80052c:	e9 a2 fd ff ff       	jmp    8002d3 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800531:	83 fa 01             	cmp    $0x1,%edx
  800534:	7e 16                	jle    80054c <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800536:	8b 45 14             	mov    0x14(%ebp),%eax
  800539:	8d 50 08             	lea    0x8(%eax),%edx
  80053c:	89 55 14             	mov    %edx,0x14(%ebp)
  80053f:	8b 50 04             	mov    0x4(%eax),%edx
  800542:	8b 00                	mov    (%eax),%eax
  800544:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800547:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80054a:	eb 32                	jmp    80057e <vprintfmt+0x2d1>
	else if (lflag)
  80054c:	85 d2                	test   %edx,%edx
  80054e:	74 18                	je     800568 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800550:	8b 45 14             	mov    0x14(%ebp),%eax
  800553:	8d 50 04             	lea    0x4(%eax),%edx
  800556:	89 55 14             	mov    %edx,0x14(%ebp)
  800559:	8b 00                	mov    (%eax),%eax
  80055b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055e:	89 c1                	mov    %eax,%ecx
  800560:	c1 f9 1f             	sar    $0x1f,%ecx
  800563:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800566:	eb 16                	jmp    80057e <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8d 50 04             	lea    0x4(%eax),%edx
  80056e:	89 55 14             	mov    %edx,0x14(%ebp)
  800571:	8b 00                	mov    (%eax),%eax
  800573:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800576:	89 c1                	mov    %eax,%ecx
  800578:	c1 f9 1f             	sar    $0x1f,%ecx
  80057b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80057e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800581:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800584:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800589:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80058d:	79 74                	jns    800603 <vprintfmt+0x356>
				putch('-', putdat);
  80058f:	83 ec 08             	sub    $0x8,%esp
  800592:	53                   	push   %ebx
  800593:	6a 2d                	push   $0x2d
  800595:	ff d6                	call   *%esi
				num = -(long long) num;
  800597:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80059a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80059d:	f7 d8                	neg    %eax
  80059f:	83 d2 00             	adc    $0x0,%edx
  8005a2:	f7 da                	neg    %edx
  8005a4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005a7:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005ac:	eb 55                	jmp    800603 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b1:	e8 83 fc ff ff       	call   800239 <getuint>
			base = 10;
  8005b6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005bb:	eb 46                	jmp    800603 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005bd:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c0:	e8 74 fc ff ff       	call   800239 <getuint>
			base = 8;
  8005c5:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005ca:	eb 37                	jmp    800603 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005cc:	83 ec 08             	sub    $0x8,%esp
  8005cf:	53                   	push   %ebx
  8005d0:	6a 30                	push   $0x30
  8005d2:	ff d6                	call   *%esi
			putch('x', putdat);
  8005d4:	83 c4 08             	add    $0x8,%esp
  8005d7:	53                   	push   %ebx
  8005d8:	6a 78                	push   $0x78
  8005da:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8d 50 04             	lea    0x4(%eax),%edx
  8005e2:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005e5:	8b 00                	mov    (%eax),%eax
  8005e7:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005ec:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005ef:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005f4:	eb 0d                	jmp    800603 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f9:	e8 3b fc ff ff       	call   800239 <getuint>
			base = 16;
  8005fe:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800603:	83 ec 0c             	sub    $0xc,%esp
  800606:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80060a:	57                   	push   %edi
  80060b:	ff 75 e0             	pushl  -0x20(%ebp)
  80060e:	51                   	push   %ecx
  80060f:	52                   	push   %edx
  800610:	50                   	push   %eax
  800611:	89 da                	mov    %ebx,%edx
  800613:	89 f0                	mov    %esi,%eax
  800615:	e8 70 fb ff ff       	call   80018a <printnum>
			break;
  80061a:	83 c4 20             	add    $0x20,%esp
  80061d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800620:	e9 ae fc ff ff       	jmp    8002d3 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800625:	83 ec 08             	sub    $0x8,%esp
  800628:	53                   	push   %ebx
  800629:	51                   	push   %ecx
  80062a:	ff d6                	call   *%esi
			break;
  80062c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800632:	e9 9c fc ff ff       	jmp    8002d3 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800637:	83 ec 08             	sub    $0x8,%esp
  80063a:	53                   	push   %ebx
  80063b:	6a 25                	push   $0x25
  80063d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80063f:	83 c4 10             	add    $0x10,%esp
  800642:	eb 03                	jmp    800647 <vprintfmt+0x39a>
  800644:	83 ef 01             	sub    $0x1,%edi
  800647:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80064b:	75 f7                	jne    800644 <vprintfmt+0x397>
  80064d:	e9 81 fc ff ff       	jmp    8002d3 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800652:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800655:	5b                   	pop    %ebx
  800656:	5e                   	pop    %esi
  800657:	5f                   	pop    %edi
  800658:	5d                   	pop    %ebp
  800659:	c3                   	ret    

0080065a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80065a:	55                   	push   %ebp
  80065b:	89 e5                	mov    %esp,%ebp
  80065d:	83 ec 18             	sub    $0x18,%esp
  800660:	8b 45 08             	mov    0x8(%ebp),%eax
  800663:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800666:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800669:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80066d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800670:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800677:	85 c0                	test   %eax,%eax
  800679:	74 26                	je     8006a1 <vsnprintf+0x47>
  80067b:	85 d2                	test   %edx,%edx
  80067d:	7e 22                	jle    8006a1 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80067f:	ff 75 14             	pushl  0x14(%ebp)
  800682:	ff 75 10             	pushl  0x10(%ebp)
  800685:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800688:	50                   	push   %eax
  800689:	68 73 02 80 00       	push   $0x800273
  80068e:	e8 1a fc ff ff       	call   8002ad <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800693:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800696:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800699:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069c:	83 c4 10             	add    $0x10,%esp
  80069f:	eb 05                	jmp    8006a6 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006a6:	c9                   	leave  
  8006a7:	c3                   	ret    

008006a8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006a8:	55                   	push   %ebp
  8006a9:	89 e5                	mov    %esp,%ebp
  8006ab:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ae:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006b1:	50                   	push   %eax
  8006b2:	ff 75 10             	pushl  0x10(%ebp)
  8006b5:	ff 75 0c             	pushl  0xc(%ebp)
  8006b8:	ff 75 08             	pushl  0x8(%ebp)
  8006bb:	e8 9a ff ff ff       	call   80065a <vsnprintf>
	va_end(ap);

	return rc;
}
  8006c0:	c9                   	leave  
  8006c1:	c3                   	ret    

008006c2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006c2:	55                   	push   %ebp
  8006c3:	89 e5                	mov    %esp,%ebp
  8006c5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8006cd:	eb 03                	jmp    8006d2 <strlen+0x10>
		n++;
  8006cf:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006d2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006d6:	75 f7                	jne    8006cf <strlen+0xd>
		n++;
	return n;
}
  8006d8:	5d                   	pop    %ebp
  8006d9:	c3                   	ret    

008006da <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006da:	55                   	push   %ebp
  8006db:	89 e5                	mov    %esp,%ebp
  8006dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e0:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8006e8:	eb 03                	jmp    8006ed <strnlen+0x13>
		n++;
  8006ea:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ed:	39 c2                	cmp    %eax,%edx
  8006ef:	74 08                	je     8006f9 <strnlen+0x1f>
  8006f1:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006f5:	75 f3                	jne    8006ea <strnlen+0x10>
  8006f7:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006f9:	5d                   	pop    %ebp
  8006fa:	c3                   	ret    

008006fb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006fb:	55                   	push   %ebp
  8006fc:	89 e5                	mov    %esp,%ebp
  8006fe:	53                   	push   %ebx
  8006ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800702:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800705:	89 c2                	mov    %eax,%edx
  800707:	83 c2 01             	add    $0x1,%edx
  80070a:	83 c1 01             	add    $0x1,%ecx
  80070d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800711:	88 5a ff             	mov    %bl,-0x1(%edx)
  800714:	84 db                	test   %bl,%bl
  800716:	75 ef                	jne    800707 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800718:	5b                   	pop    %ebx
  800719:	5d                   	pop    %ebp
  80071a:	c3                   	ret    

0080071b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	53                   	push   %ebx
  80071f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800722:	53                   	push   %ebx
  800723:	e8 9a ff ff ff       	call   8006c2 <strlen>
  800728:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80072b:	ff 75 0c             	pushl  0xc(%ebp)
  80072e:	01 d8                	add    %ebx,%eax
  800730:	50                   	push   %eax
  800731:	e8 c5 ff ff ff       	call   8006fb <strcpy>
	return dst;
}
  800736:	89 d8                	mov    %ebx,%eax
  800738:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80073b:	c9                   	leave  
  80073c:	c3                   	ret    

0080073d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80073d:	55                   	push   %ebp
  80073e:	89 e5                	mov    %esp,%ebp
  800740:	56                   	push   %esi
  800741:	53                   	push   %ebx
  800742:	8b 75 08             	mov    0x8(%ebp),%esi
  800745:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800748:	89 f3                	mov    %esi,%ebx
  80074a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80074d:	89 f2                	mov    %esi,%edx
  80074f:	eb 0f                	jmp    800760 <strncpy+0x23>
		*dst++ = *src;
  800751:	83 c2 01             	add    $0x1,%edx
  800754:	0f b6 01             	movzbl (%ecx),%eax
  800757:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80075a:	80 39 01             	cmpb   $0x1,(%ecx)
  80075d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800760:	39 da                	cmp    %ebx,%edx
  800762:	75 ed                	jne    800751 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800764:	89 f0                	mov    %esi,%eax
  800766:	5b                   	pop    %ebx
  800767:	5e                   	pop    %esi
  800768:	5d                   	pop    %ebp
  800769:	c3                   	ret    

0080076a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80076a:	55                   	push   %ebp
  80076b:	89 e5                	mov    %esp,%ebp
  80076d:	56                   	push   %esi
  80076e:	53                   	push   %ebx
  80076f:	8b 75 08             	mov    0x8(%ebp),%esi
  800772:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800775:	8b 55 10             	mov    0x10(%ebp),%edx
  800778:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80077a:	85 d2                	test   %edx,%edx
  80077c:	74 21                	je     80079f <strlcpy+0x35>
  80077e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800782:	89 f2                	mov    %esi,%edx
  800784:	eb 09                	jmp    80078f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800786:	83 c2 01             	add    $0x1,%edx
  800789:	83 c1 01             	add    $0x1,%ecx
  80078c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80078f:	39 c2                	cmp    %eax,%edx
  800791:	74 09                	je     80079c <strlcpy+0x32>
  800793:	0f b6 19             	movzbl (%ecx),%ebx
  800796:	84 db                	test   %bl,%bl
  800798:	75 ec                	jne    800786 <strlcpy+0x1c>
  80079a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80079c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80079f:	29 f0                	sub    %esi,%eax
}
  8007a1:	5b                   	pop    %ebx
  8007a2:	5e                   	pop    %esi
  8007a3:	5d                   	pop    %ebp
  8007a4:	c3                   	ret    

008007a5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ab:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ae:	eb 06                	jmp    8007b6 <strcmp+0x11>
		p++, q++;
  8007b0:	83 c1 01             	add    $0x1,%ecx
  8007b3:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007b6:	0f b6 01             	movzbl (%ecx),%eax
  8007b9:	84 c0                	test   %al,%al
  8007bb:	74 04                	je     8007c1 <strcmp+0x1c>
  8007bd:	3a 02                	cmp    (%edx),%al
  8007bf:	74 ef                	je     8007b0 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007c1:	0f b6 c0             	movzbl %al,%eax
  8007c4:	0f b6 12             	movzbl (%edx),%edx
  8007c7:	29 d0                	sub    %edx,%eax
}
  8007c9:	5d                   	pop    %ebp
  8007ca:	c3                   	ret    

008007cb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	53                   	push   %ebx
  8007cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d5:	89 c3                	mov    %eax,%ebx
  8007d7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007da:	eb 06                	jmp    8007e2 <strncmp+0x17>
		n--, p++, q++;
  8007dc:	83 c0 01             	add    $0x1,%eax
  8007df:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007e2:	39 d8                	cmp    %ebx,%eax
  8007e4:	74 15                	je     8007fb <strncmp+0x30>
  8007e6:	0f b6 08             	movzbl (%eax),%ecx
  8007e9:	84 c9                	test   %cl,%cl
  8007eb:	74 04                	je     8007f1 <strncmp+0x26>
  8007ed:	3a 0a                	cmp    (%edx),%cl
  8007ef:	74 eb                	je     8007dc <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f1:	0f b6 00             	movzbl (%eax),%eax
  8007f4:	0f b6 12             	movzbl (%edx),%edx
  8007f7:	29 d0                	sub    %edx,%eax
  8007f9:	eb 05                	jmp    800800 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007fb:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800800:	5b                   	pop    %ebx
  800801:	5d                   	pop    %ebp
  800802:	c3                   	ret    

00800803 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	8b 45 08             	mov    0x8(%ebp),%eax
  800809:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80080d:	eb 07                	jmp    800816 <strchr+0x13>
		if (*s == c)
  80080f:	38 ca                	cmp    %cl,%dl
  800811:	74 0f                	je     800822 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800813:	83 c0 01             	add    $0x1,%eax
  800816:	0f b6 10             	movzbl (%eax),%edx
  800819:	84 d2                	test   %dl,%dl
  80081b:	75 f2                	jne    80080f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80081d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	8b 45 08             	mov    0x8(%ebp),%eax
  80082a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80082e:	eb 03                	jmp    800833 <strfind+0xf>
  800830:	83 c0 01             	add    $0x1,%eax
  800833:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800836:	38 ca                	cmp    %cl,%dl
  800838:	74 04                	je     80083e <strfind+0x1a>
  80083a:	84 d2                	test   %dl,%dl
  80083c:	75 f2                	jne    800830 <strfind+0xc>
			break;
	return (char *) s;
}
  80083e:	5d                   	pop    %ebp
  80083f:	c3                   	ret    

00800840 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	57                   	push   %edi
  800844:	56                   	push   %esi
  800845:	53                   	push   %ebx
  800846:	8b 7d 08             	mov    0x8(%ebp),%edi
  800849:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80084c:	85 c9                	test   %ecx,%ecx
  80084e:	74 36                	je     800886 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800850:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800856:	75 28                	jne    800880 <memset+0x40>
  800858:	f6 c1 03             	test   $0x3,%cl
  80085b:	75 23                	jne    800880 <memset+0x40>
		c &= 0xFF;
  80085d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800861:	89 d3                	mov    %edx,%ebx
  800863:	c1 e3 08             	shl    $0x8,%ebx
  800866:	89 d6                	mov    %edx,%esi
  800868:	c1 e6 18             	shl    $0x18,%esi
  80086b:	89 d0                	mov    %edx,%eax
  80086d:	c1 e0 10             	shl    $0x10,%eax
  800870:	09 f0                	or     %esi,%eax
  800872:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800874:	89 d8                	mov    %ebx,%eax
  800876:	09 d0                	or     %edx,%eax
  800878:	c1 e9 02             	shr    $0x2,%ecx
  80087b:	fc                   	cld    
  80087c:	f3 ab                	rep stos %eax,%es:(%edi)
  80087e:	eb 06                	jmp    800886 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800880:	8b 45 0c             	mov    0xc(%ebp),%eax
  800883:	fc                   	cld    
  800884:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800886:	89 f8                	mov    %edi,%eax
  800888:	5b                   	pop    %ebx
  800889:	5e                   	pop    %esi
  80088a:	5f                   	pop    %edi
  80088b:	5d                   	pop    %ebp
  80088c:	c3                   	ret    

0080088d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	57                   	push   %edi
  800891:	56                   	push   %esi
  800892:	8b 45 08             	mov    0x8(%ebp),%eax
  800895:	8b 75 0c             	mov    0xc(%ebp),%esi
  800898:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80089b:	39 c6                	cmp    %eax,%esi
  80089d:	73 35                	jae    8008d4 <memmove+0x47>
  80089f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008a2:	39 d0                	cmp    %edx,%eax
  8008a4:	73 2e                	jae    8008d4 <memmove+0x47>
		s += n;
		d += n;
  8008a6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008a9:	89 d6                	mov    %edx,%esi
  8008ab:	09 fe                	or     %edi,%esi
  8008ad:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008b3:	75 13                	jne    8008c8 <memmove+0x3b>
  8008b5:	f6 c1 03             	test   $0x3,%cl
  8008b8:	75 0e                	jne    8008c8 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008ba:	83 ef 04             	sub    $0x4,%edi
  8008bd:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008c0:	c1 e9 02             	shr    $0x2,%ecx
  8008c3:	fd                   	std    
  8008c4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c6:	eb 09                	jmp    8008d1 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008c8:	83 ef 01             	sub    $0x1,%edi
  8008cb:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008ce:	fd                   	std    
  8008cf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008d1:	fc                   	cld    
  8008d2:	eb 1d                	jmp    8008f1 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d4:	89 f2                	mov    %esi,%edx
  8008d6:	09 c2                	or     %eax,%edx
  8008d8:	f6 c2 03             	test   $0x3,%dl
  8008db:	75 0f                	jne    8008ec <memmove+0x5f>
  8008dd:	f6 c1 03             	test   $0x3,%cl
  8008e0:	75 0a                	jne    8008ec <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008e2:	c1 e9 02             	shr    $0x2,%ecx
  8008e5:	89 c7                	mov    %eax,%edi
  8008e7:	fc                   	cld    
  8008e8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ea:	eb 05                	jmp    8008f1 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008ec:	89 c7                	mov    %eax,%edi
  8008ee:	fc                   	cld    
  8008ef:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008f1:	5e                   	pop    %esi
  8008f2:	5f                   	pop    %edi
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008f8:	ff 75 10             	pushl  0x10(%ebp)
  8008fb:	ff 75 0c             	pushl  0xc(%ebp)
  8008fe:	ff 75 08             	pushl  0x8(%ebp)
  800901:	e8 87 ff ff ff       	call   80088d <memmove>
}
  800906:	c9                   	leave  
  800907:	c3                   	ret    

00800908 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	56                   	push   %esi
  80090c:	53                   	push   %ebx
  80090d:	8b 45 08             	mov    0x8(%ebp),%eax
  800910:	8b 55 0c             	mov    0xc(%ebp),%edx
  800913:	89 c6                	mov    %eax,%esi
  800915:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800918:	eb 1a                	jmp    800934 <memcmp+0x2c>
		if (*s1 != *s2)
  80091a:	0f b6 08             	movzbl (%eax),%ecx
  80091d:	0f b6 1a             	movzbl (%edx),%ebx
  800920:	38 d9                	cmp    %bl,%cl
  800922:	74 0a                	je     80092e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800924:	0f b6 c1             	movzbl %cl,%eax
  800927:	0f b6 db             	movzbl %bl,%ebx
  80092a:	29 d8                	sub    %ebx,%eax
  80092c:	eb 0f                	jmp    80093d <memcmp+0x35>
		s1++, s2++;
  80092e:	83 c0 01             	add    $0x1,%eax
  800931:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800934:	39 f0                	cmp    %esi,%eax
  800936:	75 e2                	jne    80091a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800938:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093d:	5b                   	pop    %ebx
  80093e:	5e                   	pop    %esi
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	53                   	push   %ebx
  800945:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800948:	89 c1                	mov    %eax,%ecx
  80094a:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80094d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800951:	eb 0a                	jmp    80095d <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800953:	0f b6 10             	movzbl (%eax),%edx
  800956:	39 da                	cmp    %ebx,%edx
  800958:	74 07                	je     800961 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80095a:	83 c0 01             	add    $0x1,%eax
  80095d:	39 c8                	cmp    %ecx,%eax
  80095f:	72 f2                	jb     800953 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800961:	5b                   	pop    %ebx
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	57                   	push   %edi
  800968:	56                   	push   %esi
  800969:	53                   	push   %ebx
  80096a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80096d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800970:	eb 03                	jmp    800975 <strtol+0x11>
		s++;
  800972:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800975:	0f b6 01             	movzbl (%ecx),%eax
  800978:	3c 20                	cmp    $0x20,%al
  80097a:	74 f6                	je     800972 <strtol+0xe>
  80097c:	3c 09                	cmp    $0x9,%al
  80097e:	74 f2                	je     800972 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800980:	3c 2b                	cmp    $0x2b,%al
  800982:	75 0a                	jne    80098e <strtol+0x2a>
		s++;
  800984:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800987:	bf 00 00 00 00       	mov    $0x0,%edi
  80098c:	eb 11                	jmp    80099f <strtol+0x3b>
  80098e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800993:	3c 2d                	cmp    $0x2d,%al
  800995:	75 08                	jne    80099f <strtol+0x3b>
		s++, neg = 1;
  800997:	83 c1 01             	add    $0x1,%ecx
  80099a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80099f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009a5:	75 15                	jne    8009bc <strtol+0x58>
  8009a7:	80 39 30             	cmpb   $0x30,(%ecx)
  8009aa:	75 10                	jne    8009bc <strtol+0x58>
  8009ac:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009b0:	75 7c                	jne    800a2e <strtol+0xca>
		s += 2, base = 16;
  8009b2:	83 c1 02             	add    $0x2,%ecx
  8009b5:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009ba:	eb 16                	jmp    8009d2 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009bc:	85 db                	test   %ebx,%ebx
  8009be:	75 12                	jne    8009d2 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009c0:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009c5:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c8:	75 08                	jne    8009d2 <strtol+0x6e>
		s++, base = 8;
  8009ca:	83 c1 01             	add    $0x1,%ecx
  8009cd:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d7:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009da:	0f b6 11             	movzbl (%ecx),%edx
  8009dd:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009e0:	89 f3                	mov    %esi,%ebx
  8009e2:	80 fb 09             	cmp    $0x9,%bl
  8009e5:	77 08                	ja     8009ef <strtol+0x8b>
			dig = *s - '0';
  8009e7:	0f be d2             	movsbl %dl,%edx
  8009ea:	83 ea 30             	sub    $0x30,%edx
  8009ed:	eb 22                	jmp    800a11 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009ef:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009f2:	89 f3                	mov    %esi,%ebx
  8009f4:	80 fb 19             	cmp    $0x19,%bl
  8009f7:	77 08                	ja     800a01 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009f9:	0f be d2             	movsbl %dl,%edx
  8009fc:	83 ea 57             	sub    $0x57,%edx
  8009ff:	eb 10                	jmp    800a11 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a01:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a04:	89 f3                	mov    %esi,%ebx
  800a06:	80 fb 19             	cmp    $0x19,%bl
  800a09:	77 16                	ja     800a21 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a0b:	0f be d2             	movsbl %dl,%edx
  800a0e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a11:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a14:	7d 0b                	jge    800a21 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a16:	83 c1 01             	add    $0x1,%ecx
  800a19:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a1d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a1f:	eb b9                	jmp    8009da <strtol+0x76>

	if (endptr)
  800a21:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a25:	74 0d                	je     800a34 <strtol+0xd0>
		*endptr = (char *) s;
  800a27:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a2a:	89 0e                	mov    %ecx,(%esi)
  800a2c:	eb 06                	jmp    800a34 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a2e:	85 db                	test   %ebx,%ebx
  800a30:	74 98                	je     8009ca <strtol+0x66>
  800a32:	eb 9e                	jmp    8009d2 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a34:	89 c2                	mov    %eax,%edx
  800a36:	f7 da                	neg    %edx
  800a38:	85 ff                	test   %edi,%edi
  800a3a:	0f 45 c2             	cmovne %edx,%eax
}
  800a3d:	5b                   	pop    %ebx
  800a3e:	5e                   	pop    %esi
  800a3f:	5f                   	pop    %edi
  800a40:	5d                   	pop    %ebp
  800a41:	c3                   	ret    

00800a42 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	57                   	push   %edi
  800a46:	56                   	push   %esi
  800a47:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a48:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a50:	8b 55 08             	mov    0x8(%ebp),%edx
  800a53:	89 c3                	mov    %eax,%ebx
  800a55:	89 c7                	mov    %eax,%edi
  800a57:	89 c6                	mov    %eax,%esi
  800a59:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a5b:	5b                   	pop    %ebx
  800a5c:	5e                   	pop    %esi
  800a5d:	5f                   	pop    %edi
  800a5e:	5d                   	pop    %ebp
  800a5f:	c3                   	ret    

00800a60 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	57                   	push   %edi
  800a64:	56                   	push   %esi
  800a65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a66:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6b:	b8 01 00 00 00       	mov    $0x1,%eax
  800a70:	89 d1                	mov    %edx,%ecx
  800a72:	89 d3                	mov    %edx,%ebx
  800a74:	89 d7                	mov    %edx,%edi
  800a76:	89 d6                	mov    %edx,%esi
  800a78:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a7a:	5b                   	pop    %ebx
  800a7b:	5e                   	pop    %esi
  800a7c:	5f                   	pop    %edi
  800a7d:	5d                   	pop    %ebp
  800a7e:	c3                   	ret    

00800a7f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	57                   	push   %edi
  800a83:	56                   	push   %esi
  800a84:	53                   	push   %ebx
  800a85:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a88:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a8d:	b8 03 00 00 00       	mov    $0x3,%eax
  800a92:	8b 55 08             	mov    0x8(%ebp),%edx
  800a95:	89 cb                	mov    %ecx,%ebx
  800a97:	89 cf                	mov    %ecx,%edi
  800a99:	89 ce                	mov    %ecx,%esi
  800a9b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a9d:	85 c0                	test   %eax,%eax
  800a9f:	7e 17                	jle    800ab8 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aa1:	83 ec 0c             	sub    $0xc,%esp
  800aa4:	50                   	push   %eax
  800aa5:	6a 03                	push   $0x3
  800aa7:	68 3f 27 80 00       	push   $0x80273f
  800aac:	6a 23                	push   $0x23
  800aae:	68 5c 27 80 00       	push   $0x80275c
  800ab3:	e8 90 14 00 00       	call   801f48 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ab8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800abb:	5b                   	pop    %ebx
  800abc:	5e                   	pop    %esi
  800abd:	5f                   	pop    %edi
  800abe:	5d                   	pop    %ebp
  800abf:	c3                   	ret    

00800ac0 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	57                   	push   %edi
  800ac4:	56                   	push   %esi
  800ac5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac6:	ba 00 00 00 00       	mov    $0x0,%edx
  800acb:	b8 02 00 00 00       	mov    $0x2,%eax
  800ad0:	89 d1                	mov    %edx,%ecx
  800ad2:	89 d3                	mov    %edx,%ebx
  800ad4:	89 d7                	mov    %edx,%edi
  800ad6:	89 d6                	mov    %edx,%esi
  800ad8:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ada:	5b                   	pop    %ebx
  800adb:	5e                   	pop    %esi
  800adc:	5f                   	pop    %edi
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <sys_yield>:

void
sys_yield(void)
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
  800aea:	b8 0b 00 00 00       	mov    $0xb,%eax
  800aef:	89 d1                	mov    %edx,%ecx
  800af1:	89 d3                	mov    %edx,%ebx
  800af3:	89 d7                	mov    %edx,%edi
  800af5:	89 d6                	mov    %edx,%esi
  800af7:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5f                   	pop    %edi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	57                   	push   %edi
  800b02:	56                   	push   %esi
  800b03:	53                   	push   %ebx
  800b04:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b07:	be 00 00 00 00       	mov    $0x0,%esi
  800b0c:	b8 04 00 00 00       	mov    $0x4,%eax
  800b11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b14:	8b 55 08             	mov    0x8(%ebp),%edx
  800b17:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b1a:	89 f7                	mov    %esi,%edi
  800b1c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b1e:	85 c0                	test   %eax,%eax
  800b20:	7e 17                	jle    800b39 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b22:	83 ec 0c             	sub    $0xc,%esp
  800b25:	50                   	push   %eax
  800b26:	6a 04                	push   $0x4
  800b28:	68 3f 27 80 00       	push   $0x80273f
  800b2d:	6a 23                	push   $0x23
  800b2f:	68 5c 27 80 00       	push   $0x80275c
  800b34:	e8 0f 14 00 00       	call   801f48 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b3c:	5b                   	pop    %ebx
  800b3d:	5e                   	pop    %esi
  800b3e:	5f                   	pop    %edi
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	57                   	push   %edi
  800b45:	56                   	push   %esi
  800b46:	53                   	push   %ebx
  800b47:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4a:	b8 05 00 00 00       	mov    $0x5,%eax
  800b4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b52:	8b 55 08             	mov    0x8(%ebp),%edx
  800b55:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b58:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b5b:	8b 75 18             	mov    0x18(%ebp),%esi
  800b5e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b60:	85 c0                	test   %eax,%eax
  800b62:	7e 17                	jle    800b7b <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b64:	83 ec 0c             	sub    $0xc,%esp
  800b67:	50                   	push   %eax
  800b68:	6a 05                	push   $0x5
  800b6a:	68 3f 27 80 00       	push   $0x80273f
  800b6f:	6a 23                	push   $0x23
  800b71:	68 5c 27 80 00       	push   $0x80275c
  800b76:	e8 cd 13 00 00       	call   801f48 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7e:	5b                   	pop    %ebx
  800b7f:	5e                   	pop    %esi
  800b80:	5f                   	pop    %edi
  800b81:	5d                   	pop    %ebp
  800b82:	c3                   	ret    

00800b83 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	57                   	push   %edi
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
  800b89:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b91:	b8 06 00 00 00       	mov    $0x6,%eax
  800b96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b99:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9c:	89 df                	mov    %ebx,%edi
  800b9e:	89 de                	mov    %ebx,%esi
  800ba0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba2:	85 c0                	test   %eax,%eax
  800ba4:	7e 17                	jle    800bbd <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba6:	83 ec 0c             	sub    $0xc,%esp
  800ba9:	50                   	push   %eax
  800baa:	6a 06                	push   $0x6
  800bac:	68 3f 27 80 00       	push   $0x80273f
  800bb1:	6a 23                	push   $0x23
  800bb3:	68 5c 27 80 00       	push   $0x80275c
  800bb8:	e8 8b 13 00 00       	call   801f48 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	57                   	push   %edi
  800bc9:	56                   	push   %esi
  800bca:	53                   	push   %ebx
  800bcb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bce:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd3:	b8 08 00 00 00       	mov    $0x8,%eax
  800bd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bde:	89 df                	mov    %ebx,%edi
  800be0:	89 de                	mov    %ebx,%esi
  800be2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be4:	85 c0                	test   %eax,%eax
  800be6:	7e 17                	jle    800bff <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be8:	83 ec 0c             	sub    $0xc,%esp
  800beb:	50                   	push   %eax
  800bec:	6a 08                	push   $0x8
  800bee:	68 3f 27 80 00       	push   $0x80273f
  800bf3:	6a 23                	push   $0x23
  800bf5:	68 5c 27 80 00       	push   $0x80275c
  800bfa:	e8 49 13 00 00       	call   801f48 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
  800c0d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c15:	b8 09 00 00 00       	mov    $0x9,%eax
  800c1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c20:	89 df                	mov    %ebx,%edi
  800c22:	89 de                	mov    %ebx,%esi
  800c24:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c26:	85 c0                	test   %eax,%eax
  800c28:	7e 17                	jle    800c41 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2a:	83 ec 0c             	sub    $0xc,%esp
  800c2d:	50                   	push   %eax
  800c2e:	6a 09                	push   $0x9
  800c30:	68 3f 27 80 00       	push   $0x80273f
  800c35:	6a 23                	push   $0x23
  800c37:	68 5c 27 80 00       	push   $0x80275c
  800c3c:	e8 07 13 00 00       	call   801f48 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c44:	5b                   	pop    %ebx
  800c45:	5e                   	pop    %esi
  800c46:	5f                   	pop    %edi
  800c47:	5d                   	pop    %ebp
  800c48:	c3                   	ret    

00800c49 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	57                   	push   %edi
  800c4d:	56                   	push   %esi
  800c4e:	53                   	push   %ebx
  800c4f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c52:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c57:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c62:	89 df                	mov    %ebx,%edi
  800c64:	89 de                	mov    %ebx,%esi
  800c66:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c68:	85 c0                	test   %eax,%eax
  800c6a:	7e 17                	jle    800c83 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6c:	83 ec 0c             	sub    $0xc,%esp
  800c6f:	50                   	push   %eax
  800c70:	6a 0a                	push   $0xa
  800c72:	68 3f 27 80 00       	push   $0x80273f
  800c77:	6a 23                	push   $0x23
  800c79:	68 5c 27 80 00       	push   $0x80275c
  800c7e:	e8 c5 12 00 00       	call   801f48 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c86:	5b                   	pop    %ebx
  800c87:	5e                   	pop    %esi
  800c88:	5f                   	pop    %edi
  800c89:	5d                   	pop    %ebp
  800c8a:	c3                   	ret    

00800c8b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	57                   	push   %edi
  800c8f:	56                   	push   %esi
  800c90:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c91:	be 00 00 00 00       	mov    $0x0,%esi
  800c96:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ca9:	5b                   	pop    %ebx
  800caa:	5e                   	pop    %esi
  800cab:	5f                   	pop    %edi
  800cac:	5d                   	pop    %ebp
  800cad:	c3                   	ret    

00800cae <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cae:	55                   	push   %ebp
  800caf:	89 e5                	mov    %esp,%ebp
  800cb1:	57                   	push   %edi
  800cb2:	56                   	push   %esi
  800cb3:	53                   	push   %ebx
  800cb4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cbc:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc4:	89 cb                	mov    %ecx,%ebx
  800cc6:	89 cf                	mov    %ecx,%edi
  800cc8:	89 ce                	mov    %ecx,%esi
  800cca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ccc:	85 c0                	test   %eax,%eax
  800cce:	7e 17                	jle    800ce7 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd0:	83 ec 0c             	sub    $0xc,%esp
  800cd3:	50                   	push   %eax
  800cd4:	6a 0d                	push   $0xd
  800cd6:	68 3f 27 80 00       	push   $0x80273f
  800cdb:	6a 23                	push   $0x23
  800cdd:	68 5c 27 80 00       	push   $0x80275c
  800ce2:	e8 61 12 00 00       	call   801f48 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ce7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cea:	5b                   	pop    %ebx
  800ceb:	5e                   	pop    %esi
  800cec:	5f                   	pop    %edi
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    

00800cef <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	57                   	push   %edi
  800cf3:	56                   	push   %esi
  800cf4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cfa:	b8 0e 00 00 00       	mov    $0xe,%eax
  800cff:	8b 55 08             	mov    0x8(%ebp),%edx
  800d02:	89 cb                	mov    %ecx,%ebx
  800d04:	89 cf                	mov    %ecx,%edi
  800d06:	89 ce                	mov    %ecx,%esi
  800d08:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d0a:	5b                   	pop    %ebx
  800d0b:	5e                   	pop    %esi
  800d0c:	5f                   	pop    %edi
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    

00800d0f <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	57                   	push   %edi
  800d13:	56                   	push   %esi
  800d14:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d15:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d1a:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d22:	89 cb                	mov    %ecx,%ebx
  800d24:	89 cf                	mov    %ecx,%edi
  800d26:	89 ce                	mov    %ecx,%esi
  800d28:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800d2a:	5b                   	pop    %ebx
  800d2b:	5e                   	pop    %esi
  800d2c:	5f                   	pop    %edi
  800d2d:	5d                   	pop    %ebp
  800d2e:	c3                   	ret    

00800d2f <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  800d2f:	55                   	push   %ebp
  800d30:	89 e5                	mov    %esp,%ebp
  800d32:	57                   	push   %edi
  800d33:	56                   	push   %esi
  800d34:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d35:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3a:	b8 10 00 00 00       	mov    $0x10,%eax
  800d3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d42:	89 cb                	mov    %ecx,%ebx
  800d44:	89 cf                	mov    %ecx,%edi
  800d46:	89 ce                	mov    %ecx,%esi
  800d48:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  800d4a:	5b                   	pop    %ebx
  800d4b:	5e                   	pop    %esi
  800d4c:	5f                   	pop    %edi
  800d4d:	5d                   	pop    %ebp
  800d4e:	c3                   	ret    

00800d4f <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	53                   	push   %ebx
  800d53:	83 ec 04             	sub    $0x4,%esp
  800d56:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d59:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800d5b:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d5f:	74 11                	je     800d72 <pgfault+0x23>
  800d61:	89 d8                	mov    %ebx,%eax
  800d63:	c1 e8 0c             	shr    $0xc,%eax
  800d66:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d6d:	f6 c4 08             	test   $0x8,%ah
  800d70:	75 14                	jne    800d86 <pgfault+0x37>
		panic("faulting access");
  800d72:	83 ec 04             	sub    $0x4,%esp
  800d75:	68 6a 27 80 00       	push   $0x80276a
  800d7a:	6a 1f                	push   $0x1f
  800d7c:	68 7a 27 80 00       	push   $0x80277a
  800d81:	e8 c2 11 00 00       	call   801f48 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800d86:	83 ec 04             	sub    $0x4,%esp
  800d89:	6a 07                	push   $0x7
  800d8b:	68 00 f0 7f 00       	push   $0x7ff000
  800d90:	6a 00                	push   $0x0
  800d92:	e8 67 fd ff ff       	call   800afe <sys_page_alloc>
	if (r < 0) {
  800d97:	83 c4 10             	add    $0x10,%esp
  800d9a:	85 c0                	test   %eax,%eax
  800d9c:	79 12                	jns    800db0 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800d9e:	50                   	push   %eax
  800d9f:	68 85 27 80 00       	push   $0x802785
  800da4:	6a 2d                	push   $0x2d
  800da6:	68 7a 27 80 00       	push   $0x80277a
  800dab:	e8 98 11 00 00       	call   801f48 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800db0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800db6:	83 ec 04             	sub    $0x4,%esp
  800db9:	68 00 10 00 00       	push   $0x1000
  800dbe:	53                   	push   %ebx
  800dbf:	68 00 f0 7f 00       	push   $0x7ff000
  800dc4:	e8 2c fb ff ff       	call   8008f5 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800dc9:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800dd0:	53                   	push   %ebx
  800dd1:	6a 00                	push   $0x0
  800dd3:	68 00 f0 7f 00       	push   $0x7ff000
  800dd8:	6a 00                	push   $0x0
  800dda:	e8 62 fd ff ff       	call   800b41 <sys_page_map>
	if (r < 0) {
  800ddf:	83 c4 20             	add    $0x20,%esp
  800de2:	85 c0                	test   %eax,%eax
  800de4:	79 12                	jns    800df8 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800de6:	50                   	push   %eax
  800de7:	68 85 27 80 00       	push   $0x802785
  800dec:	6a 34                	push   $0x34
  800dee:	68 7a 27 80 00       	push   $0x80277a
  800df3:	e8 50 11 00 00       	call   801f48 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800df8:	83 ec 08             	sub    $0x8,%esp
  800dfb:	68 00 f0 7f 00       	push   $0x7ff000
  800e00:	6a 00                	push   $0x0
  800e02:	e8 7c fd ff ff       	call   800b83 <sys_page_unmap>
	if (r < 0) {
  800e07:	83 c4 10             	add    $0x10,%esp
  800e0a:	85 c0                	test   %eax,%eax
  800e0c:	79 12                	jns    800e20 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e0e:	50                   	push   %eax
  800e0f:	68 85 27 80 00       	push   $0x802785
  800e14:	6a 38                	push   $0x38
  800e16:	68 7a 27 80 00       	push   $0x80277a
  800e1b:	e8 28 11 00 00       	call   801f48 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e20:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e23:	c9                   	leave  
  800e24:	c3                   	ret    

00800e25 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	57                   	push   %edi
  800e29:	56                   	push   %esi
  800e2a:	53                   	push   %ebx
  800e2b:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e2e:	68 4f 0d 80 00       	push   $0x800d4f
  800e33:	e8 56 11 00 00       	call   801f8e <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e38:	b8 07 00 00 00       	mov    $0x7,%eax
  800e3d:	cd 30                	int    $0x30
  800e3f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800e42:	83 c4 10             	add    $0x10,%esp
  800e45:	85 c0                	test   %eax,%eax
  800e47:	79 17                	jns    800e60 <fork+0x3b>
		panic("fork fault %e");
  800e49:	83 ec 04             	sub    $0x4,%esp
  800e4c:	68 9e 27 80 00       	push   $0x80279e
  800e51:	68 85 00 00 00       	push   $0x85
  800e56:	68 7a 27 80 00       	push   $0x80277a
  800e5b:	e8 e8 10 00 00       	call   801f48 <_panic>
  800e60:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800e62:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e66:	75 24                	jne    800e8c <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e68:	e8 53 fc ff ff       	call   800ac0 <sys_getenvid>
  800e6d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e72:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800e78:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e7d:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800e82:	b8 00 00 00 00       	mov    $0x0,%eax
  800e87:	e9 64 01 00 00       	jmp    800ff0 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800e8c:	83 ec 04             	sub    $0x4,%esp
  800e8f:	6a 07                	push   $0x7
  800e91:	68 00 f0 bf ee       	push   $0xeebff000
  800e96:	ff 75 e4             	pushl  -0x1c(%ebp)
  800e99:	e8 60 fc ff ff       	call   800afe <sys_page_alloc>
  800e9e:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800ea1:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ea6:	89 d8                	mov    %ebx,%eax
  800ea8:	c1 e8 16             	shr    $0x16,%eax
  800eab:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800eb2:	a8 01                	test   $0x1,%al
  800eb4:	0f 84 fc 00 00 00    	je     800fb6 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800eba:	89 d8                	mov    %ebx,%eax
  800ebc:	c1 e8 0c             	shr    $0xc,%eax
  800ebf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ec6:	f6 c2 01             	test   $0x1,%dl
  800ec9:	0f 84 e7 00 00 00    	je     800fb6 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800ecf:	89 c6                	mov    %eax,%esi
  800ed1:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800ed4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800edb:	f6 c6 04             	test   $0x4,%dh
  800ede:	74 39                	je     800f19 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800ee0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ee7:	83 ec 0c             	sub    $0xc,%esp
  800eea:	25 07 0e 00 00       	and    $0xe07,%eax
  800eef:	50                   	push   %eax
  800ef0:	56                   	push   %esi
  800ef1:	57                   	push   %edi
  800ef2:	56                   	push   %esi
  800ef3:	6a 00                	push   $0x0
  800ef5:	e8 47 fc ff ff       	call   800b41 <sys_page_map>
		if (r < 0) {
  800efa:	83 c4 20             	add    $0x20,%esp
  800efd:	85 c0                	test   %eax,%eax
  800eff:	0f 89 b1 00 00 00    	jns    800fb6 <fork+0x191>
		    	panic("sys page map fault %e");
  800f05:	83 ec 04             	sub    $0x4,%esp
  800f08:	68 ac 27 80 00       	push   $0x8027ac
  800f0d:	6a 55                	push   $0x55
  800f0f:	68 7a 27 80 00       	push   $0x80277a
  800f14:	e8 2f 10 00 00       	call   801f48 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f19:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f20:	f6 c2 02             	test   $0x2,%dl
  800f23:	75 0c                	jne    800f31 <fork+0x10c>
  800f25:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f2c:	f6 c4 08             	test   $0x8,%ah
  800f2f:	74 5b                	je     800f8c <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f31:	83 ec 0c             	sub    $0xc,%esp
  800f34:	68 05 08 00 00       	push   $0x805
  800f39:	56                   	push   %esi
  800f3a:	57                   	push   %edi
  800f3b:	56                   	push   %esi
  800f3c:	6a 00                	push   $0x0
  800f3e:	e8 fe fb ff ff       	call   800b41 <sys_page_map>
		if (r < 0) {
  800f43:	83 c4 20             	add    $0x20,%esp
  800f46:	85 c0                	test   %eax,%eax
  800f48:	79 14                	jns    800f5e <fork+0x139>
		    	panic("sys page map fault %e");
  800f4a:	83 ec 04             	sub    $0x4,%esp
  800f4d:	68 ac 27 80 00       	push   $0x8027ac
  800f52:	6a 5c                	push   $0x5c
  800f54:	68 7a 27 80 00       	push   $0x80277a
  800f59:	e8 ea 0f 00 00       	call   801f48 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800f5e:	83 ec 0c             	sub    $0xc,%esp
  800f61:	68 05 08 00 00       	push   $0x805
  800f66:	56                   	push   %esi
  800f67:	6a 00                	push   $0x0
  800f69:	56                   	push   %esi
  800f6a:	6a 00                	push   $0x0
  800f6c:	e8 d0 fb ff ff       	call   800b41 <sys_page_map>
		if (r < 0) {
  800f71:	83 c4 20             	add    $0x20,%esp
  800f74:	85 c0                	test   %eax,%eax
  800f76:	79 3e                	jns    800fb6 <fork+0x191>
		    	panic("sys page map fault %e");
  800f78:	83 ec 04             	sub    $0x4,%esp
  800f7b:	68 ac 27 80 00       	push   $0x8027ac
  800f80:	6a 60                	push   $0x60
  800f82:	68 7a 27 80 00       	push   $0x80277a
  800f87:	e8 bc 0f 00 00       	call   801f48 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800f8c:	83 ec 0c             	sub    $0xc,%esp
  800f8f:	6a 05                	push   $0x5
  800f91:	56                   	push   %esi
  800f92:	57                   	push   %edi
  800f93:	56                   	push   %esi
  800f94:	6a 00                	push   $0x0
  800f96:	e8 a6 fb ff ff       	call   800b41 <sys_page_map>
		if (r < 0) {
  800f9b:	83 c4 20             	add    $0x20,%esp
  800f9e:	85 c0                	test   %eax,%eax
  800fa0:	79 14                	jns    800fb6 <fork+0x191>
		    	panic("sys page map fault %e");
  800fa2:	83 ec 04             	sub    $0x4,%esp
  800fa5:	68 ac 27 80 00       	push   $0x8027ac
  800faa:	6a 65                	push   $0x65
  800fac:	68 7a 27 80 00       	push   $0x80277a
  800fb1:	e8 92 0f 00 00       	call   801f48 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800fb6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fbc:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800fc2:	0f 85 de fe ff ff    	jne    800ea6 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800fc8:	a1 08 40 80 00       	mov    0x804008,%eax
  800fcd:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
  800fd3:	83 ec 08             	sub    $0x8,%esp
  800fd6:	50                   	push   %eax
  800fd7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800fda:	57                   	push   %edi
  800fdb:	e8 69 fc ff ff       	call   800c49 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  800fe0:	83 c4 08             	add    $0x8,%esp
  800fe3:	6a 02                	push   $0x2
  800fe5:	57                   	push   %edi
  800fe6:	e8 da fb ff ff       	call   800bc5 <sys_env_set_status>
	
	return envid;
  800feb:	83 c4 10             	add    $0x10,%esp
  800fee:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  800ff0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ff3:	5b                   	pop    %ebx
  800ff4:	5e                   	pop    %esi
  800ff5:	5f                   	pop    %edi
  800ff6:	5d                   	pop    %ebp
  800ff7:	c3                   	ret    

00800ff8 <sfork>:

envid_t
sfork(void)
{
  800ff8:	55                   	push   %ebp
  800ff9:	89 e5                	mov    %esp,%ebp
	return 0;
}
  800ffb:	b8 00 00 00 00       	mov    $0x0,%eax
  801000:	5d                   	pop    %ebp
  801001:	c3                   	ret    

00801002 <thread_create>:

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  801002:	55                   	push   %ebp
  801003:	89 e5                	mov    %esp,%ebp
  801005:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  801008:	8b 45 08             	mov    0x8(%ebp),%eax
  80100b:	a3 0c 40 80 00       	mov    %eax,0x80400c
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801010:	68 a9 00 80 00       	push   $0x8000a9
  801015:	e8 d5 fc ff ff       	call   800cef <sys_thread_create>

	return id;
}
  80101a:	c9                   	leave  
  80101b:	c3                   	ret    

0080101c <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  801022:	ff 75 08             	pushl  0x8(%ebp)
  801025:	e8 e5 fc ff ff       	call   800d0f <sys_thread_free>
}
  80102a:	83 c4 10             	add    $0x10,%esp
  80102d:	c9                   	leave  
  80102e:	c3                   	ret    

0080102f <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  801035:	ff 75 08             	pushl  0x8(%ebp)
  801038:	e8 f2 fc ff ff       	call   800d2f <sys_thread_join>
}
  80103d:	83 c4 10             	add    $0x10,%esp
  801040:	c9                   	leave  
  801041:	c3                   	ret    

00801042 <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  801042:	55                   	push   %ebp
  801043:	89 e5                	mov    %esp,%ebp
  801045:	56                   	push   %esi
  801046:	53                   	push   %ebx
  801047:	8b 75 08             	mov    0x8(%ebp),%esi
  80104a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  80104d:	83 ec 04             	sub    $0x4,%esp
  801050:	6a 07                	push   $0x7
  801052:	6a 00                	push   $0x0
  801054:	56                   	push   %esi
  801055:	e8 a4 fa ff ff       	call   800afe <sys_page_alloc>
	if (r < 0) {
  80105a:	83 c4 10             	add    $0x10,%esp
  80105d:	85 c0                	test   %eax,%eax
  80105f:	79 15                	jns    801076 <queue_append+0x34>
		panic("%e\n", r);
  801061:	50                   	push   %eax
  801062:	68 f2 27 80 00       	push   $0x8027f2
  801067:	68 d5 00 00 00       	push   $0xd5
  80106c:	68 7a 27 80 00       	push   $0x80277a
  801071:	e8 d2 0e 00 00       	call   801f48 <_panic>
	}	

	wt->envid = envid;
  801076:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  80107c:	83 3b 00             	cmpl   $0x0,(%ebx)
  80107f:	75 13                	jne    801094 <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  801081:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  801088:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80108f:	00 00 00 
  801092:	eb 1b                	jmp    8010af <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  801094:	8b 43 04             	mov    0x4(%ebx),%eax
  801097:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  80109e:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8010a5:	00 00 00 
		queue->last = wt;
  8010a8:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8010af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010b2:	5b                   	pop    %ebx
  8010b3:	5e                   	pop    %esi
  8010b4:	5d                   	pop    %ebp
  8010b5:	c3                   	ret    

008010b6 <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  8010b6:	55                   	push   %ebp
  8010b7:	89 e5                	mov    %esp,%ebp
  8010b9:	83 ec 08             	sub    $0x8,%esp
  8010bc:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  8010bf:	8b 02                	mov    (%edx),%eax
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	75 17                	jne    8010dc <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  8010c5:	83 ec 04             	sub    $0x4,%esp
  8010c8:	68 c2 27 80 00       	push   $0x8027c2
  8010cd:	68 ec 00 00 00       	push   $0xec
  8010d2:	68 7a 27 80 00       	push   $0x80277a
  8010d7:	e8 6c 0e 00 00       	call   801f48 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  8010dc:	8b 48 04             	mov    0x4(%eax),%ecx
  8010df:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  8010e1:	8b 00                	mov    (%eax),%eax
}
  8010e3:	c9                   	leave  
  8010e4:	c3                   	ret    

008010e5 <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  8010e5:	55                   	push   %ebp
  8010e6:	89 e5                	mov    %esp,%ebp
  8010e8:	53                   	push   %ebx
  8010e9:	83 ec 04             	sub    $0x4,%esp
  8010ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  8010ef:	b8 01 00 00 00       	mov    $0x1,%eax
  8010f4:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0)) {
  8010f7:	85 c0                	test   %eax,%eax
  8010f9:	74 45                	je     801140 <mutex_lock+0x5b>
		queue_append(sys_getenvid(), &mtx->queue);		
  8010fb:	e8 c0 f9 ff ff       	call   800ac0 <sys_getenvid>
  801100:	83 ec 08             	sub    $0x8,%esp
  801103:	83 c3 04             	add    $0x4,%ebx
  801106:	53                   	push   %ebx
  801107:	50                   	push   %eax
  801108:	e8 35 ff ff ff       	call   801042 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  80110d:	e8 ae f9 ff ff       	call   800ac0 <sys_getenvid>
  801112:	83 c4 08             	add    $0x8,%esp
  801115:	6a 04                	push   $0x4
  801117:	50                   	push   %eax
  801118:	e8 a8 fa ff ff       	call   800bc5 <sys_env_set_status>

		if (r < 0) {
  80111d:	83 c4 10             	add    $0x10,%esp
  801120:	85 c0                	test   %eax,%eax
  801122:	79 15                	jns    801139 <mutex_lock+0x54>
			panic("%e\n", r);
  801124:	50                   	push   %eax
  801125:	68 f2 27 80 00       	push   $0x8027f2
  80112a:	68 02 01 00 00       	push   $0x102
  80112f:	68 7a 27 80 00       	push   $0x80277a
  801134:	e8 0f 0e 00 00       	call   801f48 <_panic>
		}
		sys_yield();
  801139:	e8 a1 f9 ff ff       	call   800adf <sys_yield>
  80113e:	eb 08                	jmp    801148 <mutex_lock+0x63>
	} else {
		mtx->owner = sys_getenvid();
  801140:	e8 7b f9 ff ff       	call   800ac0 <sys_getenvid>
  801145:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801148:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80114b:	c9                   	leave  
  80114c:	c3                   	ret    

0080114d <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  80114d:	55                   	push   %ebp
  80114e:	89 e5                	mov    %esp,%ebp
  801150:	53                   	push   %ebx
  801151:	83 ec 04             	sub    $0x4,%esp
  801154:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	if (mtx->queue.first != NULL) {
  801157:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  80115b:	74 36                	je     801193 <mutex_unlock+0x46>
		mtx->owner = queue_pop(&mtx->queue);
  80115d:	83 ec 0c             	sub    $0xc,%esp
  801160:	8d 43 04             	lea    0x4(%ebx),%eax
  801163:	50                   	push   %eax
  801164:	e8 4d ff ff ff       	call   8010b6 <queue_pop>
  801169:	89 43 0c             	mov    %eax,0xc(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  80116c:	83 c4 08             	add    $0x8,%esp
  80116f:	6a 02                	push   $0x2
  801171:	50                   	push   %eax
  801172:	e8 4e fa ff ff       	call   800bc5 <sys_env_set_status>
		if (r < 0) {
  801177:	83 c4 10             	add    $0x10,%esp
  80117a:	85 c0                	test   %eax,%eax
  80117c:	79 1d                	jns    80119b <mutex_unlock+0x4e>
			panic("%e\n", r);
  80117e:	50                   	push   %eax
  80117f:	68 f2 27 80 00       	push   $0x8027f2
  801184:	68 16 01 00 00       	push   $0x116
  801189:	68 7a 27 80 00       	push   $0x80277a
  80118e:	e8 b5 0d 00 00       	call   801f48 <_panic>
  801193:	b8 00 00 00 00       	mov    $0x0,%eax
  801198:	f0 87 03             	lock xchg %eax,(%ebx)
		}
	} else xchg(&mtx->locked, 0);
	
	//asm volatile("pause"); 	// might be useless here
	sys_yield();
  80119b:	e8 3f f9 ff ff       	call   800adf <sys_yield>
}
  8011a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011a3:	c9                   	leave  
  8011a4:	c3                   	ret    

008011a5 <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  8011a5:	55                   	push   %ebp
  8011a6:	89 e5                	mov    %esp,%ebp
  8011a8:	53                   	push   %ebx
  8011a9:	83 ec 04             	sub    $0x4,%esp
  8011ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  8011af:	e8 0c f9 ff ff       	call   800ac0 <sys_getenvid>
  8011b4:	83 ec 04             	sub    $0x4,%esp
  8011b7:	6a 07                	push   $0x7
  8011b9:	53                   	push   %ebx
  8011ba:	50                   	push   %eax
  8011bb:	e8 3e f9 ff ff       	call   800afe <sys_page_alloc>
  8011c0:	83 c4 10             	add    $0x10,%esp
  8011c3:	85 c0                	test   %eax,%eax
  8011c5:	79 15                	jns    8011dc <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  8011c7:	50                   	push   %eax
  8011c8:	68 dd 27 80 00       	push   $0x8027dd
  8011cd:	68 23 01 00 00       	push   $0x123
  8011d2:	68 7a 27 80 00       	push   $0x80277a
  8011d7:	e8 6c 0d 00 00       	call   801f48 <_panic>
	}	
	mtx->locked = 0;
  8011dc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue.first = NULL;
  8011e2:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	mtx->queue.last = NULL;
  8011e9:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	mtx->owner = 0;
  8011f0:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
}
  8011f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011fa:	c9                   	leave  
  8011fb:	c3                   	ret    

008011fc <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  8011fc:	55                   	push   %ebp
  8011fd:	89 e5                	mov    %esp,%ebp
  8011ff:	56                   	push   %esi
  801200:	53                   	push   %ebx
  801201:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue.first != NULL) {
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  801204:	8d 73 04             	lea    0x4(%ebx),%esi

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  801207:	eb 20                	jmp    801229 <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  801209:	83 ec 0c             	sub    $0xc,%esp
  80120c:	56                   	push   %esi
  80120d:	e8 a4 fe ff ff       	call   8010b6 <queue_pop>
  801212:	83 c4 08             	add    $0x8,%esp
  801215:	6a 02                	push   $0x2
  801217:	50                   	push   %eax
  801218:	e8 a8 f9 ff ff       	call   800bc5 <sys_env_set_status>
		mtx->queue.first = mtx->queue.first->next;
  80121d:	8b 43 04             	mov    0x4(%ebx),%eax
  801220:	8b 40 04             	mov    0x4(%eax),%eax
  801223:	89 43 04             	mov    %eax,0x4(%ebx)
  801226:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  801229:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  80122d:	75 da                	jne    801209 <mutex_destroy+0xd>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
		mtx->queue.first = mtx->queue.first->next;
	}

	memset(mtx, 0, PGSIZE);
  80122f:	83 ec 04             	sub    $0x4,%esp
  801232:	68 00 10 00 00       	push   $0x1000
  801237:	6a 00                	push   $0x0
  801239:	53                   	push   %ebx
  80123a:	e8 01 f6 ff ff       	call   800840 <memset>
	mtx = NULL;
}
  80123f:	83 c4 10             	add    $0x10,%esp
  801242:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801245:	5b                   	pop    %ebx
  801246:	5e                   	pop    %esi
  801247:	5d                   	pop    %ebp
  801248:	c3                   	ret    

00801249 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80124c:	8b 45 08             	mov    0x8(%ebp),%eax
  80124f:	05 00 00 00 30       	add    $0x30000000,%eax
  801254:	c1 e8 0c             	shr    $0xc,%eax
}
  801257:	5d                   	pop    %ebp
  801258:	c3                   	ret    

00801259 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801259:	55                   	push   %ebp
  80125a:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80125c:	8b 45 08             	mov    0x8(%ebp),%eax
  80125f:	05 00 00 00 30       	add    $0x30000000,%eax
  801264:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801269:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80126e:	5d                   	pop    %ebp
  80126f:	c3                   	ret    

00801270 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801270:	55                   	push   %ebp
  801271:	89 e5                	mov    %esp,%ebp
  801273:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801276:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80127b:	89 c2                	mov    %eax,%edx
  80127d:	c1 ea 16             	shr    $0x16,%edx
  801280:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801287:	f6 c2 01             	test   $0x1,%dl
  80128a:	74 11                	je     80129d <fd_alloc+0x2d>
  80128c:	89 c2                	mov    %eax,%edx
  80128e:	c1 ea 0c             	shr    $0xc,%edx
  801291:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801298:	f6 c2 01             	test   $0x1,%dl
  80129b:	75 09                	jne    8012a6 <fd_alloc+0x36>
			*fd_store = fd;
  80129d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80129f:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a4:	eb 17                	jmp    8012bd <fd_alloc+0x4d>
  8012a6:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012ab:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012b0:	75 c9                	jne    80127b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012b2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012b8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012bd:	5d                   	pop    %ebp
  8012be:	c3                   	ret    

008012bf <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012bf:	55                   	push   %ebp
  8012c0:	89 e5                	mov    %esp,%ebp
  8012c2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012c5:	83 f8 1f             	cmp    $0x1f,%eax
  8012c8:	77 36                	ja     801300 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012ca:	c1 e0 0c             	shl    $0xc,%eax
  8012cd:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012d2:	89 c2                	mov    %eax,%edx
  8012d4:	c1 ea 16             	shr    $0x16,%edx
  8012d7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012de:	f6 c2 01             	test   $0x1,%dl
  8012e1:	74 24                	je     801307 <fd_lookup+0x48>
  8012e3:	89 c2                	mov    %eax,%edx
  8012e5:	c1 ea 0c             	shr    $0xc,%edx
  8012e8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012ef:	f6 c2 01             	test   $0x1,%dl
  8012f2:	74 1a                	je     80130e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012f7:	89 02                	mov    %eax,(%edx)
	return 0;
  8012f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012fe:	eb 13                	jmp    801313 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801300:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801305:	eb 0c                	jmp    801313 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801307:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80130c:	eb 05                	jmp    801313 <fd_lookup+0x54>
  80130e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801313:	5d                   	pop    %ebp
  801314:	c3                   	ret    

00801315 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801315:	55                   	push   %ebp
  801316:	89 e5                	mov    %esp,%ebp
  801318:	83 ec 08             	sub    $0x8,%esp
  80131b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80131e:	ba 74 28 80 00       	mov    $0x802874,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801323:	eb 13                	jmp    801338 <dev_lookup+0x23>
  801325:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801328:	39 08                	cmp    %ecx,(%eax)
  80132a:	75 0c                	jne    801338 <dev_lookup+0x23>
			*dev = devtab[i];
  80132c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80132f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801331:	b8 00 00 00 00       	mov    $0x0,%eax
  801336:	eb 31                	jmp    801369 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801338:	8b 02                	mov    (%edx),%eax
  80133a:	85 c0                	test   %eax,%eax
  80133c:	75 e7                	jne    801325 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80133e:	a1 08 40 80 00       	mov    0x804008,%eax
  801343:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801349:	83 ec 04             	sub    $0x4,%esp
  80134c:	51                   	push   %ecx
  80134d:	50                   	push   %eax
  80134e:	68 f8 27 80 00       	push   $0x8027f8
  801353:	e8 1e ee ff ff       	call   800176 <cprintf>
	*dev = 0;
  801358:	8b 45 0c             	mov    0xc(%ebp),%eax
  80135b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801361:	83 c4 10             	add    $0x10,%esp
  801364:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801369:	c9                   	leave  
  80136a:	c3                   	ret    

0080136b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80136b:	55                   	push   %ebp
  80136c:	89 e5                	mov    %esp,%ebp
  80136e:	56                   	push   %esi
  80136f:	53                   	push   %ebx
  801370:	83 ec 10             	sub    $0x10,%esp
  801373:	8b 75 08             	mov    0x8(%ebp),%esi
  801376:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801379:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137c:	50                   	push   %eax
  80137d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801383:	c1 e8 0c             	shr    $0xc,%eax
  801386:	50                   	push   %eax
  801387:	e8 33 ff ff ff       	call   8012bf <fd_lookup>
  80138c:	83 c4 08             	add    $0x8,%esp
  80138f:	85 c0                	test   %eax,%eax
  801391:	78 05                	js     801398 <fd_close+0x2d>
	    || fd != fd2)
  801393:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801396:	74 0c                	je     8013a4 <fd_close+0x39>
		return (must_exist ? r : 0);
  801398:	84 db                	test   %bl,%bl
  80139a:	ba 00 00 00 00       	mov    $0x0,%edx
  80139f:	0f 44 c2             	cmove  %edx,%eax
  8013a2:	eb 41                	jmp    8013e5 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013a4:	83 ec 08             	sub    $0x8,%esp
  8013a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013aa:	50                   	push   %eax
  8013ab:	ff 36                	pushl  (%esi)
  8013ad:	e8 63 ff ff ff       	call   801315 <dev_lookup>
  8013b2:	89 c3                	mov    %eax,%ebx
  8013b4:	83 c4 10             	add    $0x10,%esp
  8013b7:	85 c0                	test   %eax,%eax
  8013b9:	78 1a                	js     8013d5 <fd_close+0x6a>
		if (dev->dev_close)
  8013bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013be:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013c1:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013c6:	85 c0                	test   %eax,%eax
  8013c8:	74 0b                	je     8013d5 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013ca:	83 ec 0c             	sub    $0xc,%esp
  8013cd:	56                   	push   %esi
  8013ce:	ff d0                	call   *%eax
  8013d0:	89 c3                	mov    %eax,%ebx
  8013d2:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013d5:	83 ec 08             	sub    $0x8,%esp
  8013d8:	56                   	push   %esi
  8013d9:	6a 00                	push   $0x0
  8013db:	e8 a3 f7 ff ff       	call   800b83 <sys_page_unmap>
	return r;
  8013e0:	83 c4 10             	add    $0x10,%esp
  8013e3:	89 d8                	mov    %ebx,%eax
}
  8013e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013e8:	5b                   	pop    %ebx
  8013e9:	5e                   	pop    %esi
  8013ea:	5d                   	pop    %ebp
  8013eb:	c3                   	ret    

008013ec <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013ec:	55                   	push   %ebp
  8013ed:	89 e5                	mov    %esp,%ebp
  8013ef:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f5:	50                   	push   %eax
  8013f6:	ff 75 08             	pushl  0x8(%ebp)
  8013f9:	e8 c1 fe ff ff       	call   8012bf <fd_lookup>
  8013fe:	83 c4 08             	add    $0x8,%esp
  801401:	85 c0                	test   %eax,%eax
  801403:	78 10                	js     801415 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801405:	83 ec 08             	sub    $0x8,%esp
  801408:	6a 01                	push   $0x1
  80140a:	ff 75 f4             	pushl  -0xc(%ebp)
  80140d:	e8 59 ff ff ff       	call   80136b <fd_close>
  801412:	83 c4 10             	add    $0x10,%esp
}
  801415:	c9                   	leave  
  801416:	c3                   	ret    

00801417 <close_all>:

void
close_all(void)
{
  801417:	55                   	push   %ebp
  801418:	89 e5                	mov    %esp,%ebp
  80141a:	53                   	push   %ebx
  80141b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80141e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801423:	83 ec 0c             	sub    $0xc,%esp
  801426:	53                   	push   %ebx
  801427:	e8 c0 ff ff ff       	call   8013ec <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80142c:	83 c3 01             	add    $0x1,%ebx
  80142f:	83 c4 10             	add    $0x10,%esp
  801432:	83 fb 20             	cmp    $0x20,%ebx
  801435:	75 ec                	jne    801423 <close_all+0xc>
		close(i);
}
  801437:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80143a:	c9                   	leave  
  80143b:	c3                   	ret    

0080143c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	57                   	push   %edi
  801440:	56                   	push   %esi
  801441:	53                   	push   %ebx
  801442:	83 ec 2c             	sub    $0x2c,%esp
  801445:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801448:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80144b:	50                   	push   %eax
  80144c:	ff 75 08             	pushl  0x8(%ebp)
  80144f:	e8 6b fe ff ff       	call   8012bf <fd_lookup>
  801454:	83 c4 08             	add    $0x8,%esp
  801457:	85 c0                	test   %eax,%eax
  801459:	0f 88 c1 00 00 00    	js     801520 <dup+0xe4>
		return r;
	close(newfdnum);
  80145f:	83 ec 0c             	sub    $0xc,%esp
  801462:	56                   	push   %esi
  801463:	e8 84 ff ff ff       	call   8013ec <close>

	newfd = INDEX2FD(newfdnum);
  801468:	89 f3                	mov    %esi,%ebx
  80146a:	c1 e3 0c             	shl    $0xc,%ebx
  80146d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801473:	83 c4 04             	add    $0x4,%esp
  801476:	ff 75 e4             	pushl  -0x1c(%ebp)
  801479:	e8 db fd ff ff       	call   801259 <fd2data>
  80147e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801480:	89 1c 24             	mov    %ebx,(%esp)
  801483:	e8 d1 fd ff ff       	call   801259 <fd2data>
  801488:	83 c4 10             	add    $0x10,%esp
  80148b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80148e:	89 f8                	mov    %edi,%eax
  801490:	c1 e8 16             	shr    $0x16,%eax
  801493:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80149a:	a8 01                	test   $0x1,%al
  80149c:	74 37                	je     8014d5 <dup+0x99>
  80149e:	89 f8                	mov    %edi,%eax
  8014a0:	c1 e8 0c             	shr    $0xc,%eax
  8014a3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014aa:	f6 c2 01             	test   $0x1,%dl
  8014ad:	74 26                	je     8014d5 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014af:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014b6:	83 ec 0c             	sub    $0xc,%esp
  8014b9:	25 07 0e 00 00       	and    $0xe07,%eax
  8014be:	50                   	push   %eax
  8014bf:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014c2:	6a 00                	push   $0x0
  8014c4:	57                   	push   %edi
  8014c5:	6a 00                	push   $0x0
  8014c7:	e8 75 f6 ff ff       	call   800b41 <sys_page_map>
  8014cc:	89 c7                	mov    %eax,%edi
  8014ce:	83 c4 20             	add    $0x20,%esp
  8014d1:	85 c0                	test   %eax,%eax
  8014d3:	78 2e                	js     801503 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014d5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014d8:	89 d0                	mov    %edx,%eax
  8014da:	c1 e8 0c             	shr    $0xc,%eax
  8014dd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014e4:	83 ec 0c             	sub    $0xc,%esp
  8014e7:	25 07 0e 00 00       	and    $0xe07,%eax
  8014ec:	50                   	push   %eax
  8014ed:	53                   	push   %ebx
  8014ee:	6a 00                	push   $0x0
  8014f0:	52                   	push   %edx
  8014f1:	6a 00                	push   $0x0
  8014f3:	e8 49 f6 ff ff       	call   800b41 <sys_page_map>
  8014f8:	89 c7                	mov    %eax,%edi
  8014fa:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014fd:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014ff:	85 ff                	test   %edi,%edi
  801501:	79 1d                	jns    801520 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801503:	83 ec 08             	sub    $0x8,%esp
  801506:	53                   	push   %ebx
  801507:	6a 00                	push   $0x0
  801509:	e8 75 f6 ff ff       	call   800b83 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80150e:	83 c4 08             	add    $0x8,%esp
  801511:	ff 75 d4             	pushl  -0x2c(%ebp)
  801514:	6a 00                	push   $0x0
  801516:	e8 68 f6 ff ff       	call   800b83 <sys_page_unmap>
	return r;
  80151b:	83 c4 10             	add    $0x10,%esp
  80151e:	89 f8                	mov    %edi,%eax
}
  801520:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801523:	5b                   	pop    %ebx
  801524:	5e                   	pop    %esi
  801525:	5f                   	pop    %edi
  801526:	5d                   	pop    %ebp
  801527:	c3                   	ret    

00801528 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801528:	55                   	push   %ebp
  801529:	89 e5                	mov    %esp,%ebp
  80152b:	53                   	push   %ebx
  80152c:	83 ec 14             	sub    $0x14,%esp
  80152f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801532:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801535:	50                   	push   %eax
  801536:	53                   	push   %ebx
  801537:	e8 83 fd ff ff       	call   8012bf <fd_lookup>
  80153c:	83 c4 08             	add    $0x8,%esp
  80153f:	89 c2                	mov    %eax,%edx
  801541:	85 c0                	test   %eax,%eax
  801543:	78 70                	js     8015b5 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801545:	83 ec 08             	sub    $0x8,%esp
  801548:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154b:	50                   	push   %eax
  80154c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154f:	ff 30                	pushl  (%eax)
  801551:	e8 bf fd ff ff       	call   801315 <dev_lookup>
  801556:	83 c4 10             	add    $0x10,%esp
  801559:	85 c0                	test   %eax,%eax
  80155b:	78 4f                	js     8015ac <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80155d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801560:	8b 42 08             	mov    0x8(%edx),%eax
  801563:	83 e0 03             	and    $0x3,%eax
  801566:	83 f8 01             	cmp    $0x1,%eax
  801569:	75 24                	jne    80158f <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80156b:	a1 08 40 80 00       	mov    0x804008,%eax
  801570:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801576:	83 ec 04             	sub    $0x4,%esp
  801579:	53                   	push   %ebx
  80157a:	50                   	push   %eax
  80157b:	68 39 28 80 00       	push   $0x802839
  801580:	e8 f1 eb ff ff       	call   800176 <cprintf>
		return -E_INVAL;
  801585:	83 c4 10             	add    $0x10,%esp
  801588:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80158d:	eb 26                	jmp    8015b5 <read+0x8d>
	}
	if (!dev->dev_read)
  80158f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801592:	8b 40 08             	mov    0x8(%eax),%eax
  801595:	85 c0                	test   %eax,%eax
  801597:	74 17                	je     8015b0 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801599:	83 ec 04             	sub    $0x4,%esp
  80159c:	ff 75 10             	pushl  0x10(%ebp)
  80159f:	ff 75 0c             	pushl  0xc(%ebp)
  8015a2:	52                   	push   %edx
  8015a3:	ff d0                	call   *%eax
  8015a5:	89 c2                	mov    %eax,%edx
  8015a7:	83 c4 10             	add    $0x10,%esp
  8015aa:	eb 09                	jmp    8015b5 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ac:	89 c2                	mov    %eax,%edx
  8015ae:	eb 05                	jmp    8015b5 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015b0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8015b5:	89 d0                	mov    %edx,%eax
  8015b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ba:	c9                   	leave  
  8015bb:	c3                   	ret    

008015bc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015bc:	55                   	push   %ebp
  8015bd:	89 e5                	mov    %esp,%ebp
  8015bf:	57                   	push   %edi
  8015c0:	56                   	push   %esi
  8015c1:	53                   	push   %ebx
  8015c2:	83 ec 0c             	sub    $0xc,%esp
  8015c5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015c8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015d0:	eb 21                	jmp    8015f3 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015d2:	83 ec 04             	sub    $0x4,%esp
  8015d5:	89 f0                	mov    %esi,%eax
  8015d7:	29 d8                	sub    %ebx,%eax
  8015d9:	50                   	push   %eax
  8015da:	89 d8                	mov    %ebx,%eax
  8015dc:	03 45 0c             	add    0xc(%ebp),%eax
  8015df:	50                   	push   %eax
  8015e0:	57                   	push   %edi
  8015e1:	e8 42 ff ff ff       	call   801528 <read>
		if (m < 0)
  8015e6:	83 c4 10             	add    $0x10,%esp
  8015e9:	85 c0                	test   %eax,%eax
  8015eb:	78 10                	js     8015fd <readn+0x41>
			return m;
		if (m == 0)
  8015ed:	85 c0                	test   %eax,%eax
  8015ef:	74 0a                	je     8015fb <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015f1:	01 c3                	add    %eax,%ebx
  8015f3:	39 f3                	cmp    %esi,%ebx
  8015f5:	72 db                	jb     8015d2 <readn+0x16>
  8015f7:	89 d8                	mov    %ebx,%eax
  8015f9:	eb 02                	jmp    8015fd <readn+0x41>
  8015fb:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801600:	5b                   	pop    %ebx
  801601:	5e                   	pop    %esi
  801602:	5f                   	pop    %edi
  801603:	5d                   	pop    %ebp
  801604:	c3                   	ret    

00801605 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801605:	55                   	push   %ebp
  801606:	89 e5                	mov    %esp,%ebp
  801608:	53                   	push   %ebx
  801609:	83 ec 14             	sub    $0x14,%esp
  80160c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80160f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801612:	50                   	push   %eax
  801613:	53                   	push   %ebx
  801614:	e8 a6 fc ff ff       	call   8012bf <fd_lookup>
  801619:	83 c4 08             	add    $0x8,%esp
  80161c:	89 c2                	mov    %eax,%edx
  80161e:	85 c0                	test   %eax,%eax
  801620:	78 6b                	js     80168d <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801622:	83 ec 08             	sub    $0x8,%esp
  801625:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801628:	50                   	push   %eax
  801629:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162c:	ff 30                	pushl  (%eax)
  80162e:	e8 e2 fc ff ff       	call   801315 <dev_lookup>
  801633:	83 c4 10             	add    $0x10,%esp
  801636:	85 c0                	test   %eax,%eax
  801638:	78 4a                	js     801684 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80163a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80163d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801641:	75 24                	jne    801667 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801643:	a1 08 40 80 00       	mov    0x804008,%eax
  801648:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80164e:	83 ec 04             	sub    $0x4,%esp
  801651:	53                   	push   %ebx
  801652:	50                   	push   %eax
  801653:	68 55 28 80 00       	push   $0x802855
  801658:	e8 19 eb ff ff       	call   800176 <cprintf>
		return -E_INVAL;
  80165d:	83 c4 10             	add    $0x10,%esp
  801660:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801665:	eb 26                	jmp    80168d <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801667:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80166a:	8b 52 0c             	mov    0xc(%edx),%edx
  80166d:	85 d2                	test   %edx,%edx
  80166f:	74 17                	je     801688 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801671:	83 ec 04             	sub    $0x4,%esp
  801674:	ff 75 10             	pushl  0x10(%ebp)
  801677:	ff 75 0c             	pushl  0xc(%ebp)
  80167a:	50                   	push   %eax
  80167b:	ff d2                	call   *%edx
  80167d:	89 c2                	mov    %eax,%edx
  80167f:	83 c4 10             	add    $0x10,%esp
  801682:	eb 09                	jmp    80168d <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801684:	89 c2                	mov    %eax,%edx
  801686:	eb 05                	jmp    80168d <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801688:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80168d:	89 d0                	mov    %edx,%eax
  80168f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801692:	c9                   	leave  
  801693:	c3                   	ret    

00801694 <seek>:

int
seek(int fdnum, off_t offset)
{
  801694:	55                   	push   %ebp
  801695:	89 e5                	mov    %esp,%ebp
  801697:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80169a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80169d:	50                   	push   %eax
  80169e:	ff 75 08             	pushl  0x8(%ebp)
  8016a1:	e8 19 fc ff ff       	call   8012bf <fd_lookup>
  8016a6:	83 c4 08             	add    $0x8,%esp
  8016a9:	85 c0                	test   %eax,%eax
  8016ab:	78 0e                	js     8016bb <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016b3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016bb:	c9                   	leave  
  8016bc:	c3                   	ret    

008016bd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016bd:	55                   	push   %ebp
  8016be:	89 e5                	mov    %esp,%ebp
  8016c0:	53                   	push   %ebx
  8016c1:	83 ec 14             	sub    $0x14,%esp
  8016c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ca:	50                   	push   %eax
  8016cb:	53                   	push   %ebx
  8016cc:	e8 ee fb ff ff       	call   8012bf <fd_lookup>
  8016d1:	83 c4 08             	add    $0x8,%esp
  8016d4:	89 c2                	mov    %eax,%edx
  8016d6:	85 c0                	test   %eax,%eax
  8016d8:	78 68                	js     801742 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016da:	83 ec 08             	sub    $0x8,%esp
  8016dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e0:	50                   	push   %eax
  8016e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e4:	ff 30                	pushl  (%eax)
  8016e6:	e8 2a fc ff ff       	call   801315 <dev_lookup>
  8016eb:	83 c4 10             	add    $0x10,%esp
  8016ee:	85 c0                	test   %eax,%eax
  8016f0:	78 47                	js     801739 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016f9:	75 24                	jne    80171f <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016fb:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801700:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801706:	83 ec 04             	sub    $0x4,%esp
  801709:	53                   	push   %ebx
  80170a:	50                   	push   %eax
  80170b:	68 18 28 80 00       	push   $0x802818
  801710:	e8 61 ea ff ff       	call   800176 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801715:	83 c4 10             	add    $0x10,%esp
  801718:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80171d:	eb 23                	jmp    801742 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  80171f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801722:	8b 52 18             	mov    0x18(%edx),%edx
  801725:	85 d2                	test   %edx,%edx
  801727:	74 14                	je     80173d <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801729:	83 ec 08             	sub    $0x8,%esp
  80172c:	ff 75 0c             	pushl  0xc(%ebp)
  80172f:	50                   	push   %eax
  801730:	ff d2                	call   *%edx
  801732:	89 c2                	mov    %eax,%edx
  801734:	83 c4 10             	add    $0x10,%esp
  801737:	eb 09                	jmp    801742 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801739:	89 c2                	mov    %eax,%edx
  80173b:	eb 05                	jmp    801742 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80173d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801742:	89 d0                	mov    %edx,%eax
  801744:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801747:	c9                   	leave  
  801748:	c3                   	ret    

00801749 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801749:	55                   	push   %ebp
  80174a:	89 e5                	mov    %esp,%ebp
  80174c:	53                   	push   %ebx
  80174d:	83 ec 14             	sub    $0x14,%esp
  801750:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801753:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801756:	50                   	push   %eax
  801757:	ff 75 08             	pushl  0x8(%ebp)
  80175a:	e8 60 fb ff ff       	call   8012bf <fd_lookup>
  80175f:	83 c4 08             	add    $0x8,%esp
  801762:	89 c2                	mov    %eax,%edx
  801764:	85 c0                	test   %eax,%eax
  801766:	78 58                	js     8017c0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801768:	83 ec 08             	sub    $0x8,%esp
  80176b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80176e:	50                   	push   %eax
  80176f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801772:	ff 30                	pushl  (%eax)
  801774:	e8 9c fb ff ff       	call   801315 <dev_lookup>
  801779:	83 c4 10             	add    $0x10,%esp
  80177c:	85 c0                	test   %eax,%eax
  80177e:	78 37                	js     8017b7 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801780:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801783:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801787:	74 32                	je     8017bb <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801789:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80178c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801793:	00 00 00 
	stat->st_isdir = 0;
  801796:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80179d:	00 00 00 
	stat->st_dev = dev;
  8017a0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017a6:	83 ec 08             	sub    $0x8,%esp
  8017a9:	53                   	push   %ebx
  8017aa:	ff 75 f0             	pushl  -0x10(%ebp)
  8017ad:	ff 50 14             	call   *0x14(%eax)
  8017b0:	89 c2                	mov    %eax,%edx
  8017b2:	83 c4 10             	add    $0x10,%esp
  8017b5:	eb 09                	jmp    8017c0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b7:	89 c2                	mov    %eax,%edx
  8017b9:	eb 05                	jmp    8017c0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017bb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017c0:	89 d0                	mov    %edx,%eax
  8017c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c5:	c9                   	leave  
  8017c6:	c3                   	ret    

008017c7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	56                   	push   %esi
  8017cb:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017cc:	83 ec 08             	sub    $0x8,%esp
  8017cf:	6a 00                	push   $0x0
  8017d1:	ff 75 08             	pushl  0x8(%ebp)
  8017d4:	e8 e3 01 00 00       	call   8019bc <open>
  8017d9:	89 c3                	mov    %eax,%ebx
  8017db:	83 c4 10             	add    $0x10,%esp
  8017de:	85 c0                	test   %eax,%eax
  8017e0:	78 1b                	js     8017fd <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017e2:	83 ec 08             	sub    $0x8,%esp
  8017e5:	ff 75 0c             	pushl  0xc(%ebp)
  8017e8:	50                   	push   %eax
  8017e9:	e8 5b ff ff ff       	call   801749 <fstat>
  8017ee:	89 c6                	mov    %eax,%esi
	close(fd);
  8017f0:	89 1c 24             	mov    %ebx,(%esp)
  8017f3:	e8 f4 fb ff ff       	call   8013ec <close>
	return r;
  8017f8:	83 c4 10             	add    $0x10,%esp
  8017fb:	89 f0                	mov    %esi,%eax
}
  8017fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801800:	5b                   	pop    %ebx
  801801:	5e                   	pop    %esi
  801802:	5d                   	pop    %ebp
  801803:	c3                   	ret    

00801804 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801804:	55                   	push   %ebp
  801805:	89 e5                	mov    %esp,%ebp
  801807:	56                   	push   %esi
  801808:	53                   	push   %ebx
  801809:	89 c6                	mov    %eax,%esi
  80180b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80180d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801814:	75 12                	jne    801828 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801816:	83 ec 0c             	sub    $0xc,%esp
  801819:	6a 01                	push   $0x1
  80181b:	e8 da 08 00 00       	call   8020fa <ipc_find_env>
  801820:	a3 00 40 80 00       	mov    %eax,0x804000
  801825:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801828:	6a 07                	push   $0x7
  80182a:	68 00 50 80 00       	push   $0x805000
  80182f:	56                   	push   %esi
  801830:	ff 35 00 40 80 00    	pushl  0x804000
  801836:	e8 5d 08 00 00       	call   802098 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80183b:	83 c4 0c             	add    $0xc,%esp
  80183e:	6a 00                	push   $0x0
  801840:	53                   	push   %ebx
  801841:	6a 00                	push   $0x0
  801843:	e8 d5 07 00 00       	call   80201d <ipc_recv>
}
  801848:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80184b:	5b                   	pop    %ebx
  80184c:	5e                   	pop    %esi
  80184d:	5d                   	pop    %ebp
  80184e:	c3                   	ret    

0080184f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80184f:	55                   	push   %ebp
  801850:	89 e5                	mov    %esp,%ebp
  801852:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801855:	8b 45 08             	mov    0x8(%ebp),%eax
  801858:	8b 40 0c             	mov    0xc(%eax),%eax
  80185b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801860:	8b 45 0c             	mov    0xc(%ebp),%eax
  801863:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801868:	ba 00 00 00 00       	mov    $0x0,%edx
  80186d:	b8 02 00 00 00       	mov    $0x2,%eax
  801872:	e8 8d ff ff ff       	call   801804 <fsipc>
}
  801877:	c9                   	leave  
  801878:	c3                   	ret    

00801879 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801879:	55                   	push   %ebp
  80187a:	89 e5                	mov    %esp,%ebp
  80187c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80187f:	8b 45 08             	mov    0x8(%ebp),%eax
  801882:	8b 40 0c             	mov    0xc(%eax),%eax
  801885:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80188a:	ba 00 00 00 00       	mov    $0x0,%edx
  80188f:	b8 06 00 00 00       	mov    $0x6,%eax
  801894:	e8 6b ff ff ff       	call   801804 <fsipc>
}
  801899:	c9                   	leave  
  80189a:	c3                   	ret    

0080189b <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80189b:	55                   	push   %ebp
  80189c:	89 e5                	mov    %esp,%ebp
  80189e:	53                   	push   %ebx
  80189f:	83 ec 04             	sub    $0x4,%esp
  8018a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a8:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ab:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b5:	b8 05 00 00 00       	mov    $0x5,%eax
  8018ba:	e8 45 ff ff ff       	call   801804 <fsipc>
  8018bf:	85 c0                	test   %eax,%eax
  8018c1:	78 2c                	js     8018ef <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018c3:	83 ec 08             	sub    $0x8,%esp
  8018c6:	68 00 50 80 00       	push   $0x805000
  8018cb:	53                   	push   %ebx
  8018cc:	e8 2a ee ff ff       	call   8006fb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018d1:	a1 80 50 80 00       	mov    0x805080,%eax
  8018d6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018dc:	a1 84 50 80 00       	mov    0x805084,%eax
  8018e1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018e7:	83 c4 10             	add    $0x10,%esp
  8018ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f2:	c9                   	leave  
  8018f3:	c3                   	ret    

008018f4 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018f4:	55                   	push   %ebp
  8018f5:	89 e5                	mov    %esp,%ebp
  8018f7:	83 ec 0c             	sub    $0xc,%esp
  8018fa:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018fd:	8b 55 08             	mov    0x8(%ebp),%edx
  801900:	8b 52 0c             	mov    0xc(%edx),%edx
  801903:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801909:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80190e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801913:	0f 47 c2             	cmova  %edx,%eax
  801916:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80191b:	50                   	push   %eax
  80191c:	ff 75 0c             	pushl  0xc(%ebp)
  80191f:	68 08 50 80 00       	push   $0x805008
  801924:	e8 64 ef ff ff       	call   80088d <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801929:	ba 00 00 00 00       	mov    $0x0,%edx
  80192e:	b8 04 00 00 00       	mov    $0x4,%eax
  801933:	e8 cc fe ff ff       	call   801804 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801938:	c9                   	leave  
  801939:	c3                   	ret    

0080193a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80193a:	55                   	push   %ebp
  80193b:	89 e5                	mov    %esp,%ebp
  80193d:	56                   	push   %esi
  80193e:	53                   	push   %ebx
  80193f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801942:	8b 45 08             	mov    0x8(%ebp),%eax
  801945:	8b 40 0c             	mov    0xc(%eax),%eax
  801948:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80194d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801953:	ba 00 00 00 00       	mov    $0x0,%edx
  801958:	b8 03 00 00 00       	mov    $0x3,%eax
  80195d:	e8 a2 fe ff ff       	call   801804 <fsipc>
  801962:	89 c3                	mov    %eax,%ebx
  801964:	85 c0                	test   %eax,%eax
  801966:	78 4b                	js     8019b3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801968:	39 c6                	cmp    %eax,%esi
  80196a:	73 16                	jae    801982 <devfile_read+0x48>
  80196c:	68 84 28 80 00       	push   $0x802884
  801971:	68 8b 28 80 00       	push   $0x80288b
  801976:	6a 7c                	push   $0x7c
  801978:	68 a0 28 80 00       	push   $0x8028a0
  80197d:	e8 c6 05 00 00       	call   801f48 <_panic>
	assert(r <= PGSIZE);
  801982:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801987:	7e 16                	jle    80199f <devfile_read+0x65>
  801989:	68 ab 28 80 00       	push   $0x8028ab
  80198e:	68 8b 28 80 00       	push   $0x80288b
  801993:	6a 7d                	push   $0x7d
  801995:	68 a0 28 80 00       	push   $0x8028a0
  80199a:	e8 a9 05 00 00       	call   801f48 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80199f:	83 ec 04             	sub    $0x4,%esp
  8019a2:	50                   	push   %eax
  8019a3:	68 00 50 80 00       	push   $0x805000
  8019a8:	ff 75 0c             	pushl  0xc(%ebp)
  8019ab:	e8 dd ee ff ff       	call   80088d <memmove>
	return r;
  8019b0:	83 c4 10             	add    $0x10,%esp
}
  8019b3:	89 d8                	mov    %ebx,%eax
  8019b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019b8:	5b                   	pop    %ebx
  8019b9:	5e                   	pop    %esi
  8019ba:	5d                   	pop    %ebp
  8019bb:	c3                   	ret    

008019bc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019bc:	55                   	push   %ebp
  8019bd:	89 e5                	mov    %esp,%ebp
  8019bf:	53                   	push   %ebx
  8019c0:	83 ec 20             	sub    $0x20,%esp
  8019c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019c6:	53                   	push   %ebx
  8019c7:	e8 f6 ec ff ff       	call   8006c2 <strlen>
  8019cc:	83 c4 10             	add    $0x10,%esp
  8019cf:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019d4:	7f 67                	jg     801a3d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019d6:	83 ec 0c             	sub    $0xc,%esp
  8019d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019dc:	50                   	push   %eax
  8019dd:	e8 8e f8 ff ff       	call   801270 <fd_alloc>
  8019e2:	83 c4 10             	add    $0x10,%esp
		return r;
  8019e5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019e7:	85 c0                	test   %eax,%eax
  8019e9:	78 57                	js     801a42 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019eb:	83 ec 08             	sub    $0x8,%esp
  8019ee:	53                   	push   %ebx
  8019ef:	68 00 50 80 00       	push   $0x805000
  8019f4:	e8 02 ed ff ff       	call   8006fb <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019fc:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a01:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a04:	b8 01 00 00 00       	mov    $0x1,%eax
  801a09:	e8 f6 fd ff ff       	call   801804 <fsipc>
  801a0e:	89 c3                	mov    %eax,%ebx
  801a10:	83 c4 10             	add    $0x10,%esp
  801a13:	85 c0                	test   %eax,%eax
  801a15:	79 14                	jns    801a2b <open+0x6f>
		fd_close(fd, 0);
  801a17:	83 ec 08             	sub    $0x8,%esp
  801a1a:	6a 00                	push   $0x0
  801a1c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a1f:	e8 47 f9 ff ff       	call   80136b <fd_close>
		return r;
  801a24:	83 c4 10             	add    $0x10,%esp
  801a27:	89 da                	mov    %ebx,%edx
  801a29:	eb 17                	jmp    801a42 <open+0x86>
	}

	return fd2num(fd);
  801a2b:	83 ec 0c             	sub    $0xc,%esp
  801a2e:	ff 75 f4             	pushl  -0xc(%ebp)
  801a31:	e8 13 f8 ff ff       	call   801249 <fd2num>
  801a36:	89 c2                	mov    %eax,%edx
  801a38:	83 c4 10             	add    $0x10,%esp
  801a3b:	eb 05                	jmp    801a42 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a3d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a42:	89 d0                	mov    %edx,%eax
  801a44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a47:	c9                   	leave  
  801a48:	c3                   	ret    

00801a49 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a49:	55                   	push   %ebp
  801a4a:	89 e5                	mov    %esp,%ebp
  801a4c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a4f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a54:	b8 08 00 00 00       	mov    $0x8,%eax
  801a59:	e8 a6 fd ff ff       	call   801804 <fsipc>
}
  801a5e:	c9                   	leave  
  801a5f:	c3                   	ret    

00801a60 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	56                   	push   %esi
  801a64:	53                   	push   %ebx
  801a65:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a68:	83 ec 0c             	sub    $0xc,%esp
  801a6b:	ff 75 08             	pushl  0x8(%ebp)
  801a6e:	e8 e6 f7 ff ff       	call   801259 <fd2data>
  801a73:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a75:	83 c4 08             	add    $0x8,%esp
  801a78:	68 b7 28 80 00       	push   $0x8028b7
  801a7d:	53                   	push   %ebx
  801a7e:	e8 78 ec ff ff       	call   8006fb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a83:	8b 46 04             	mov    0x4(%esi),%eax
  801a86:	2b 06                	sub    (%esi),%eax
  801a88:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a8e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a95:	00 00 00 
	stat->st_dev = &devpipe;
  801a98:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a9f:	30 80 00 
	return 0;
}
  801aa2:	b8 00 00 00 00       	mov    $0x0,%eax
  801aa7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aaa:	5b                   	pop    %ebx
  801aab:	5e                   	pop    %esi
  801aac:	5d                   	pop    %ebp
  801aad:	c3                   	ret    

00801aae <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	53                   	push   %ebx
  801ab2:	83 ec 0c             	sub    $0xc,%esp
  801ab5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ab8:	53                   	push   %ebx
  801ab9:	6a 00                	push   $0x0
  801abb:	e8 c3 f0 ff ff       	call   800b83 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ac0:	89 1c 24             	mov    %ebx,(%esp)
  801ac3:	e8 91 f7 ff ff       	call   801259 <fd2data>
  801ac8:	83 c4 08             	add    $0x8,%esp
  801acb:	50                   	push   %eax
  801acc:	6a 00                	push   $0x0
  801ace:	e8 b0 f0 ff ff       	call   800b83 <sys_page_unmap>
}
  801ad3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ad6:	c9                   	leave  
  801ad7:	c3                   	ret    

00801ad8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ad8:	55                   	push   %ebp
  801ad9:	89 e5                	mov    %esp,%ebp
  801adb:	57                   	push   %edi
  801adc:	56                   	push   %esi
  801add:	53                   	push   %ebx
  801ade:	83 ec 1c             	sub    $0x1c,%esp
  801ae1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ae4:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ae6:	a1 08 40 80 00       	mov    0x804008,%eax
  801aeb:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801af1:	83 ec 0c             	sub    $0xc,%esp
  801af4:	ff 75 e0             	pushl  -0x20(%ebp)
  801af7:	e8 43 06 00 00       	call   80213f <pageref>
  801afc:	89 c3                	mov    %eax,%ebx
  801afe:	89 3c 24             	mov    %edi,(%esp)
  801b01:	e8 39 06 00 00       	call   80213f <pageref>
  801b06:	83 c4 10             	add    $0x10,%esp
  801b09:	39 c3                	cmp    %eax,%ebx
  801b0b:	0f 94 c1             	sete   %cl
  801b0e:	0f b6 c9             	movzbl %cl,%ecx
  801b11:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b14:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801b1a:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  801b20:	39 ce                	cmp    %ecx,%esi
  801b22:	74 1e                	je     801b42 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801b24:	39 c3                	cmp    %eax,%ebx
  801b26:	75 be                	jne    801ae6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b28:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  801b2e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b31:	50                   	push   %eax
  801b32:	56                   	push   %esi
  801b33:	68 be 28 80 00       	push   $0x8028be
  801b38:	e8 39 e6 ff ff       	call   800176 <cprintf>
  801b3d:	83 c4 10             	add    $0x10,%esp
  801b40:	eb a4                	jmp    801ae6 <_pipeisclosed+0xe>
	}
}
  801b42:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b48:	5b                   	pop    %ebx
  801b49:	5e                   	pop    %esi
  801b4a:	5f                   	pop    %edi
  801b4b:	5d                   	pop    %ebp
  801b4c:	c3                   	ret    

00801b4d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b4d:	55                   	push   %ebp
  801b4e:	89 e5                	mov    %esp,%ebp
  801b50:	57                   	push   %edi
  801b51:	56                   	push   %esi
  801b52:	53                   	push   %ebx
  801b53:	83 ec 28             	sub    $0x28,%esp
  801b56:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b59:	56                   	push   %esi
  801b5a:	e8 fa f6 ff ff       	call   801259 <fd2data>
  801b5f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b61:	83 c4 10             	add    $0x10,%esp
  801b64:	bf 00 00 00 00       	mov    $0x0,%edi
  801b69:	eb 4b                	jmp    801bb6 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b6b:	89 da                	mov    %ebx,%edx
  801b6d:	89 f0                	mov    %esi,%eax
  801b6f:	e8 64 ff ff ff       	call   801ad8 <_pipeisclosed>
  801b74:	85 c0                	test   %eax,%eax
  801b76:	75 48                	jne    801bc0 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b78:	e8 62 ef ff ff       	call   800adf <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b7d:	8b 43 04             	mov    0x4(%ebx),%eax
  801b80:	8b 0b                	mov    (%ebx),%ecx
  801b82:	8d 51 20             	lea    0x20(%ecx),%edx
  801b85:	39 d0                	cmp    %edx,%eax
  801b87:	73 e2                	jae    801b6b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b8c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b90:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b93:	89 c2                	mov    %eax,%edx
  801b95:	c1 fa 1f             	sar    $0x1f,%edx
  801b98:	89 d1                	mov    %edx,%ecx
  801b9a:	c1 e9 1b             	shr    $0x1b,%ecx
  801b9d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ba0:	83 e2 1f             	and    $0x1f,%edx
  801ba3:	29 ca                	sub    %ecx,%edx
  801ba5:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ba9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bad:	83 c0 01             	add    $0x1,%eax
  801bb0:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bb3:	83 c7 01             	add    $0x1,%edi
  801bb6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bb9:	75 c2                	jne    801b7d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bbb:	8b 45 10             	mov    0x10(%ebp),%eax
  801bbe:	eb 05                	jmp    801bc5 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bc0:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bc8:	5b                   	pop    %ebx
  801bc9:	5e                   	pop    %esi
  801bca:	5f                   	pop    %edi
  801bcb:	5d                   	pop    %ebp
  801bcc:	c3                   	ret    

00801bcd <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bcd:	55                   	push   %ebp
  801bce:	89 e5                	mov    %esp,%ebp
  801bd0:	57                   	push   %edi
  801bd1:	56                   	push   %esi
  801bd2:	53                   	push   %ebx
  801bd3:	83 ec 18             	sub    $0x18,%esp
  801bd6:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bd9:	57                   	push   %edi
  801bda:	e8 7a f6 ff ff       	call   801259 <fd2data>
  801bdf:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be1:	83 c4 10             	add    $0x10,%esp
  801be4:	bb 00 00 00 00       	mov    $0x0,%ebx
  801be9:	eb 3d                	jmp    801c28 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801beb:	85 db                	test   %ebx,%ebx
  801bed:	74 04                	je     801bf3 <devpipe_read+0x26>
				return i;
  801bef:	89 d8                	mov    %ebx,%eax
  801bf1:	eb 44                	jmp    801c37 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bf3:	89 f2                	mov    %esi,%edx
  801bf5:	89 f8                	mov    %edi,%eax
  801bf7:	e8 dc fe ff ff       	call   801ad8 <_pipeisclosed>
  801bfc:	85 c0                	test   %eax,%eax
  801bfe:	75 32                	jne    801c32 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c00:	e8 da ee ff ff       	call   800adf <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c05:	8b 06                	mov    (%esi),%eax
  801c07:	3b 46 04             	cmp    0x4(%esi),%eax
  801c0a:	74 df                	je     801beb <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c0c:	99                   	cltd   
  801c0d:	c1 ea 1b             	shr    $0x1b,%edx
  801c10:	01 d0                	add    %edx,%eax
  801c12:	83 e0 1f             	and    $0x1f,%eax
  801c15:	29 d0                	sub    %edx,%eax
  801c17:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c1f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c22:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c25:	83 c3 01             	add    $0x1,%ebx
  801c28:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c2b:	75 d8                	jne    801c05 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c2d:	8b 45 10             	mov    0x10(%ebp),%eax
  801c30:	eb 05                	jmp    801c37 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c32:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c3a:	5b                   	pop    %ebx
  801c3b:	5e                   	pop    %esi
  801c3c:	5f                   	pop    %edi
  801c3d:	5d                   	pop    %ebp
  801c3e:	c3                   	ret    

00801c3f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c3f:	55                   	push   %ebp
  801c40:	89 e5                	mov    %esp,%ebp
  801c42:	56                   	push   %esi
  801c43:	53                   	push   %ebx
  801c44:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c47:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c4a:	50                   	push   %eax
  801c4b:	e8 20 f6 ff ff       	call   801270 <fd_alloc>
  801c50:	83 c4 10             	add    $0x10,%esp
  801c53:	89 c2                	mov    %eax,%edx
  801c55:	85 c0                	test   %eax,%eax
  801c57:	0f 88 2c 01 00 00    	js     801d89 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c5d:	83 ec 04             	sub    $0x4,%esp
  801c60:	68 07 04 00 00       	push   $0x407
  801c65:	ff 75 f4             	pushl  -0xc(%ebp)
  801c68:	6a 00                	push   $0x0
  801c6a:	e8 8f ee ff ff       	call   800afe <sys_page_alloc>
  801c6f:	83 c4 10             	add    $0x10,%esp
  801c72:	89 c2                	mov    %eax,%edx
  801c74:	85 c0                	test   %eax,%eax
  801c76:	0f 88 0d 01 00 00    	js     801d89 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c7c:	83 ec 0c             	sub    $0xc,%esp
  801c7f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c82:	50                   	push   %eax
  801c83:	e8 e8 f5 ff ff       	call   801270 <fd_alloc>
  801c88:	89 c3                	mov    %eax,%ebx
  801c8a:	83 c4 10             	add    $0x10,%esp
  801c8d:	85 c0                	test   %eax,%eax
  801c8f:	0f 88 e2 00 00 00    	js     801d77 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c95:	83 ec 04             	sub    $0x4,%esp
  801c98:	68 07 04 00 00       	push   $0x407
  801c9d:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca0:	6a 00                	push   $0x0
  801ca2:	e8 57 ee ff ff       	call   800afe <sys_page_alloc>
  801ca7:	89 c3                	mov    %eax,%ebx
  801ca9:	83 c4 10             	add    $0x10,%esp
  801cac:	85 c0                	test   %eax,%eax
  801cae:	0f 88 c3 00 00 00    	js     801d77 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cb4:	83 ec 0c             	sub    $0xc,%esp
  801cb7:	ff 75 f4             	pushl  -0xc(%ebp)
  801cba:	e8 9a f5 ff ff       	call   801259 <fd2data>
  801cbf:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc1:	83 c4 0c             	add    $0xc,%esp
  801cc4:	68 07 04 00 00       	push   $0x407
  801cc9:	50                   	push   %eax
  801cca:	6a 00                	push   $0x0
  801ccc:	e8 2d ee ff ff       	call   800afe <sys_page_alloc>
  801cd1:	89 c3                	mov    %eax,%ebx
  801cd3:	83 c4 10             	add    $0x10,%esp
  801cd6:	85 c0                	test   %eax,%eax
  801cd8:	0f 88 89 00 00 00    	js     801d67 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cde:	83 ec 0c             	sub    $0xc,%esp
  801ce1:	ff 75 f0             	pushl  -0x10(%ebp)
  801ce4:	e8 70 f5 ff ff       	call   801259 <fd2data>
  801ce9:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cf0:	50                   	push   %eax
  801cf1:	6a 00                	push   $0x0
  801cf3:	56                   	push   %esi
  801cf4:	6a 00                	push   $0x0
  801cf6:	e8 46 ee ff ff       	call   800b41 <sys_page_map>
  801cfb:	89 c3                	mov    %eax,%ebx
  801cfd:	83 c4 20             	add    $0x20,%esp
  801d00:	85 c0                	test   %eax,%eax
  801d02:	78 55                	js     801d59 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d04:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d12:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d19:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d22:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d24:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d27:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d2e:	83 ec 0c             	sub    $0xc,%esp
  801d31:	ff 75 f4             	pushl  -0xc(%ebp)
  801d34:	e8 10 f5 ff ff       	call   801249 <fd2num>
  801d39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d3c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d3e:	83 c4 04             	add    $0x4,%esp
  801d41:	ff 75 f0             	pushl  -0x10(%ebp)
  801d44:	e8 00 f5 ff ff       	call   801249 <fd2num>
  801d49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d4c:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801d4f:	83 c4 10             	add    $0x10,%esp
  801d52:	ba 00 00 00 00       	mov    $0x0,%edx
  801d57:	eb 30                	jmp    801d89 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d59:	83 ec 08             	sub    $0x8,%esp
  801d5c:	56                   	push   %esi
  801d5d:	6a 00                	push   $0x0
  801d5f:	e8 1f ee ff ff       	call   800b83 <sys_page_unmap>
  801d64:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d67:	83 ec 08             	sub    $0x8,%esp
  801d6a:	ff 75 f0             	pushl  -0x10(%ebp)
  801d6d:	6a 00                	push   $0x0
  801d6f:	e8 0f ee ff ff       	call   800b83 <sys_page_unmap>
  801d74:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d77:	83 ec 08             	sub    $0x8,%esp
  801d7a:	ff 75 f4             	pushl  -0xc(%ebp)
  801d7d:	6a 00                	push   $0x0
  801d7f:	e8 ff ed ff ff       	call   800b83 <sys_page_unmap>
  801d84:	83 c4 10             	add    $0x10,%esp
  801d87:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d89:	89 d0                	mov    %edx,%eax
  801d8b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d8e:	5b                   	pop    %ebx
  801d8f:	5e                   	pop    %esi
  801d90:	5d                   	pop    %ebp
  801d91:	c3                   	ret    

00801d92 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d92:	55                   	push   %ebp
  801d93:	89 e5                	mov    %esp,%ebp
  801d95:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d98:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d9b:	50                   	push   %eax
  801d9c:	ff 75 08             	pushl  0x8(%ebp)
  801d9f:	e8 1b f5 ff ff       	call   8012bf <fd_lookup>
  801da4:	83 c4 10             	add    $0x10,%esp
  801da7:	85 c0                	test   %eax,%eax
  801da9:	78 18                	js     801dc3 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801dab:	83 ec 0c             	sub    $0xc,%esp
  801dae:	ff 75 f4             	pushl  -0xc(%ebp)
  801db1:	e8 a3 f4 ff ff       	call   801259 <fd2data>
	return _pipeisclosed(fd, p);
  801db6:	89 c2                	mov    %eax,%edx
  801db8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dbb:	e8 18 fd ff ff       	call   801ad8 <_pipeisclosed>
  801dc0:	83 c4 10             	add    $0x10,%esp
}
  801dc3:	c9                   	leave  
  801dc4:	c3                   	ret    

00801dc5 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801dc5:	55                   	push   %ebp
  801dc6:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801dc8:	b8 00 00 00 00       	mov    $0x0,%eax
  801dcd:	5d                   	pop    %ebp
  801dce:	c3                   	ret    

00801dcf <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dcf:	55                   	push   %ebp
  801dd0:	89 e5                	mov    %esp,%ebp
  801dd2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dd5:	68 d6 28 80 00       	push   $0x8028d6
  801dda:	ff 75 0c             	pushl  0xc(%ebp)
  801ddd:	e8 19 e9 ff ff       	call   8006fb <strcpy>
	return 0;
}
  801de2:	b8 00 00 00 00       	mov    $0x0,%eax
  801de7:	c9                   	leave  
  801de8:	c3                   	ret    

00801de9 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801de9:	55                   	push   %ebp
  801dea:	89 e5                	mov    %esp,%ebp
  801dec:	57                   	push   %edi
  801ded:	56                   	push   %esi
  801dee:	53                   	push   %ebx
  801def:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801df5:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dfa:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e00:	eb 2d                	jmp    801e2f <devcons_write+0x46>
		m = n - tot;
  801e02:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e05:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e07:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e0a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e0f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e12:	83 ec 04             	sub    $0x4,%esp
  801e15:	53                   	push   %ebx
  801e16:	03 45 0c             	add    0xc(%ebp),%eax
  801e19:	50                   	push   %eax
  801e1a:	57                   	push   %edi
  801e1b:	e8 6d ea ff ff       	call   80088d <memmove>
		sys_cputs(buf, m);
  801e20:	83 c4 08             	add    $0x8,%esp
  801e23:	53                   	push   %ebx
  801e24:	57                   	push   %edi
  801e25:	e8 18 ec ff ff       	call   800a42 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e2a:	01 de                	add    %ebx,%esi
  801e2c:	83 c4 10             	add    $0x10,%esp
  801e2f:	89 f0                	mov    %esi,%eax
  801e31:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e34:	72 cc                	jb     801e02 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e39:	5b                   	pop    %ebx
  801e3a:	5e                   	pop    %esi
  801e3b:	5f                   	pop    %edi
  801e3c:	5d                   	pop    %ebp
  801e3d:	c3                   	ret    

00801e3e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e3e:	55                   	push   %ebp
  801e3f:	89 e5                	mov    %esp,%ebp
  801e41:	83 ec 08             	sub    $0x8,%esp
  801e44:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e49:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e4d:	74 2a                	je     801e79 <devcons_read+0x3b>
  801e4f:	eb 05                	jmp    801e56 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e51:	e8 89 ec ff ff       	call   800adf <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e56:	e8 05 ec ff ff       	call   800a60 <sys_cgetc>
  801e5b:	85 c0                	test   %eax,%eax
  801e5d:	74 f2                	je     801e51 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e5f:	85 c0                	test   %eax,%eax
  801e61:	78 16                	js     801e79 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e63:	83 f8 04             	cmp    $0x4,%eax
  801e66:	74 0c                	je     801e74 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e68:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e6b:	88 02                	mov    %al,(%edx)
	return 1;
  801e6d:	b8 01 00 00 00       	mov    $0x1,%eax
  801e72:	eb 05                	jmp    801e79 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e74:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e79:	c9                   	leave  
  801e7a:	c3                   	ret    

00801e7b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e7b:	55                   	push   %ebp
  801e7c:	89 e5                	mov    %esp,%ebp
  801e7e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e81:	8b 45 08             	mov    0x8(%ebp),%eax
  801e84:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e87:	6a 01                	push   $0x1
  801e89:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e8c:	50                   	push   %eax
  801e8d:	e8 b0 eb ff ff       	call   800a42 <sys_cputs>
}
  801e92:	83 c4 10             	add    $0x10,%esp
  801e95:	c9                   	leave  
  801e96:	c3                   	ret    

00801e97 <getchar>:

int
getchar(void)
{
  801e97:	55                   	push   %ebp
  801e98:	89 e5                	mov    %esp,%ebp
  801e9a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e9d:	6a 01                	push   $0x1
  801e9f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ea2:	50                   	push   %eax
  801ea3:	6a 00                	push   $0x0
  801ea5:	e8 7e f6 ff ff       	call   801528 <read>
	if (r < 0)
  801eaa:	83 c4 10             	add    $0x10,%esp
  801ead:	85 c0                	test   %eax,%eax
  801eaf:	78 0f                	js     801ec0 <getchar+0x29>
		return r;
	if (r < 1)
  801eb1:	85 c0                	test   %eax,%eax
  801eb3:	7e 06                	jle    801ebb <getchar+0x24>
		return -E_EOF;
	return c;
  801eb5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801eb9:	eb 05                	jmp    801ec0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ebb:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ec0:	c9                   	leave  
  801ec1:	c3                   	ret    

00801ec2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ec2:	55                   	push   %ebp
  801ec3:	89 e5                	mov    %esp,%ebp
  801ec5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ec8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ecb:	50                   	push   %eax
  801ecc:	ff 75 08             	pushl  0x8(%ebp)
  801ecf:	e8 eb f3 ff ff       	call   8012bf <fd_lookup>
  801ed4:	83 c4 10             	add    $0x10,%esp
  801ed7:	85 c0                	test   %eax,%eax
  801ed9:	78 11                	js     801eec <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801edb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ede:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ee4:	39 10                	cmp    %edx,(%eax)
  801ee6:	0f 94 c0             	sete   %al
  801ee9:	0f b6 c0             	movzbl %al,%eax
}
  801eec:	c9                   	leave  
  801eed:	c3                   	ret    

00801eee <opencons>:

int
opencons(void)
{
  801eee:	55                   	push   %ebp
  801eef:	89 e5                	mov    %esp,%ebp
  801ef1:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ef4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ef7:	50                   	push   %eax
  801ef8:	e8 73 f3 ff ff       	call   801270 <fd_alloc>
  801efd:	83 c4 10             	add    $0x10,%esp
		return r;
  801f00:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f02:	85 c0                	test   %eax,%eax
  801f04:	78 3e                	js     801f44 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f06:	83 ec 04             	sub    $0x4,%esp
  801f09:	68 07 04 00 00       	push   $0x407
  801f0e:	ff 75 f4             	pushl  -0xc(%ebp)
  801f11:	6a 00                	push   $0x0
  801f13:	e8 e6 eb ff ff       	call   800afe <sys_page_alloc>
  801f18:	83 c4 10             	add    $0x10,%esp
		return r;
  801f1b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f1d:	85 c0                	test   %eax,%eax
  801f1f:	78 23                	js     801f44 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f21:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f36:	83 ec 0c             	sub    $0xc,%esp
  801f39:	50                   	push   %eax
  801f3a:	e8 0a f3 ff ff       	call   801249 <fd2num>
  801f3f:	89 c2                	mov    %eax,%edx
  801f41:	83 c4 10             	add    $0x10,%esp
}
  801f44:	89 d0                	mov    %edx,%eax
  801f46:	c9                   	leave  
  801f47:	c3                   	ret    

00801f48 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f48:	55                   	push   %ebp
  801f49:	89 e5                	mov    %esp,%ebp
  801f4b:	56                   	push   %esi
  801f4c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f4d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f50:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801f56:	e8 65 eb ff ff       	call   800ac0 <sys_getenvid>
  801f5b:	83 ec 0c             	sub    $0xc,%esp
  801f5e:	ff 75 0c             	pushl  0xc(%ebp)
  801f61:	ff 75 08             	pushl  0x8(%ebp)
  801f64:	56                   	push   %esi
  801f65:	50                   	push   %eax
  801f66:	68 e4 28 80 00       	push   $0x8028e4
  801f6b:	e8 06 e2 ff ff       	call   800176 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f70:	83 c4 18             	add    $0x18,%esp
  801f73:	53                   	push   %ebx
  801f74:	ff 75 10             	pushl  0x10(%ebp)
  801f77:	e8 a9 e1 ff ff       	call   800125 <vcprintf>
	cprintf("\n");
  801f7c:	c7 04 24 2c 24 80 00 	movl   $0x80242c,(%esp)
  801f83:	e8 ee e1 ff ff       	call   800176 <cprintf>
  801f88:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f8b:	cc                   	int3   
  801f8c:	eb fd                	jmp    801f8b <_panic+0x43>

00801f8e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f8e:	55                   	push   %ebp
  801f8f:	89 e5                	mov    %esp,%ebp
  801f91:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f94:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f9b:	75 2a                	jne    801fc7 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801f9d:	83 ec 04             	sub    $0x4,%esp
  801fa0:	6a 07                	push   $0x7
  801fa2:	68 00 f0 bf ee       	push   $0xeebff000
  801fa7:	6a 00                	push   $0x0
  801fa9:	e8 50 eb ff ff       	call   800afe <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801fae:	83 c4 10             	add    $0x10,%esp
  801fb1:	85 c0                	test   %eax,%eax
  801fb3:	79 12                	jns    801fc7 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801fb5:	50                   	push   %eax
  801fb6:	68 f2 27 80 00       	push   $0x8027f2
  801fbb:	6a 23                	push   $0x23
  801fbd:	68 08 29 80 00       	push   $0x802908
  801fc2:	e8 81 ff ff ff       	call   801f48 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fc7:	8b 45 08             	mov    0x8(%ebp),%eax
  801fca:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801fcf:	83 ec 08             	sub    $0x8,%esp
  801fd2:	68 f9 1f 80 00       	push   $0x801ff9
  801fd7:	6a 00                	push   $0x0
  801fd9:	e8 6b ec ff ff       	call   800c49 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801fde:	83 c4 10             	add    $0x10,%esp
  801fe1:	85 c0                	test   %eax,%eax
  801fe3:	79 12                	jns    801ff7 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801fe5:	50                   	push   %eax
  801fe6:	68 f2 27 80 00       	push   $0x8027f2
  801feb:	6a 2c                	push   $0x2c
  801fed:	68 08 29 80 00       	push   $0x802908
  801ff2:	e8 51 ff ff ff       	call   801f48 <_panic>
	}
}
  801ff7:	c9                   	leave  
  801ff8:	c3                   	ret    

00801ff9 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801ff9:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801ffa:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fff:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802001:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802004:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802008:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  80200d:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802011:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802013:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802016:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802017:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80201a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  80201b:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80201c:	c3                   	ret    

0080201d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80201d:	55                   	push   %ebp
  80201e:	89 e5                	mov    %esp,%ebp
  802020:	56                   	push   %esi
  802021:	53                   	push   %ebx
  802022:	8b 75 08             	mov    0x8(%ebp),%esi
  802025:	8b 45 0c             	mov    0xc(%ebp),%eax
  802028:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80202b:	85 c0                	test   %eax,%eax
  80202d:	75 12                	jne    802041 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80202f:	83 ec 0c             	sub    $0xc,%esp
  802032:	68 00 00 c0 ee       	push   $0xeec00000
  802037:	e8 72 ec ff ff       	call   800cae <sys_ipc_recv>
  80203c:	83 c4 10             	add    $0x10,%esp
  80203f:	eb 0c                	jmp    80204d <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802041:	83 ec 0c             	sub    $0xc,%esp
  802044:	50                   	push   %eax
  802045:	e8 64 ec ff ff       	call   800cae <sys_ipc_recv>
  80204a:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80204d:	85 f6                	test   %esi,%esi
  80204f:	0f 95 c1             	setne  %cl
  802052:	85 db                	test   %ebx,%ebx
  802054:	0f 95 c2             	setne  %dl
  802057:	84 d1                	test   %dl,%cl
  802059:	74 09                	je     802064 <ipc_recv+0x47>
  80205b:	89 c2                	mov    %eax,%edx
  80205d:	c1 ea 1f             	shr    $0x1f,%edx
  802060:	84 d2                	test   %dl,%dl
  802062:	75 2d                	jne    802091 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802064:	85 f6                	test   %esi,%esi
  802066:	74 0d                	je     802075 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802068:	a1 08 40 80 00       	mov    0x804008,%eax
  80206d:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  802073:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802075:	85 db                	test   %ebx,%ebx
  802077:	74 0d                	je     802086 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802079:	a1 08 40 80 00       	mov    0x804008,%eax
  80207e:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802084:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802086:	a1 08 40 80 00       	mov    0x804008,%eax
  80208b:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  802091:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802094:	5b                   	pop    %ebx
  802095:	5e                   	pop    %esi
  802096:	5d                   	pop    %ebp
  802097:	c3                   	ret    

00802098 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802098:	55                   	push   %ebp
  802099:	89 e5                	mov    %esp,%ebp
  80209b:	57                   	push   %edi
  80209c:	56                   	push   %esi
  80209d:	53                   	push   %ebx
  80209e:	83 ec 0c             	sub    $0xc,%esp
  8020a1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020a4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8020aa:	85 db                	test   %ebx,%ebx
  8020ac:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8020b1:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8020b4:	ff 75 14             	pushl  0x14(%ebp)
  8020b7:	53                   	push   %ebx
  8020b8:	56                   	push   %esi
  8020b9:	57                   	push   %edi
  8020ba:	e8 cc eb ff ff       	call   800c8b <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8020bf:	89 c2                	mov    %eax,%edx
  8020c1:	c1 ea 1f             	shr    $0x1f,%edx
  8020c4:	83 c4 10             	add    $0x10,%esp
  8020c7:	84 d2                	test   %dl,%dl
  8020c9:	74 17                	je     8020e2 <ipc_send+0x4a>
  8020cb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020ce:	74 12                	je     8020e2 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8020d0:	50                   	push   %eax
  8020d1:	68 16 29 80 00       	push   $0x802916
  8020d6:	6a 47                	push   $0x47
  8020d8:	68 24 29 80 00       	push   $0x802924
  8020dd:	e8 66 fe ff ff       	call   801f48 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8020e2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020e5:	75 07                	jne    8020ee <ipc_send+0x56>
			sys_yield();
  8020e7:	e8 f3 e9 ff ff       	call   800adf <sys_yield>
  8020ec:	eb c6                	jmp    8020b4 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8020ee:	85 c0                	test   %eax,%eax
  8020f0:	75 c2                	jne    8020b4 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8020f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020f5:	5b                   	pop    %ebx
  8020f6:	5e                   	pop    %esi
  8020f7:	5f                   	pop    %edi
  8020f8:	5d                   	pop    %ebp
  8020f9:	c3                   	ret    

008020fa <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020fa:	55                   	push   %ebp
  8020fb:	89 e5                	mov    %esp,%ebp
  8020fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802100:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802105:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  80210b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802111:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  802117:	39 ca                	cmp    %ecx,%edx
  802119:	75 13                	jne    80212e <ipc_find_env+0x34>
			return envs[i].env_id;
  80211b:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  802121:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802126:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80212c:	eb 0f                	jmp    80213d <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80212e:	83 c0 01             	add    $0x1,%eax
  802131:	3d 00 04 00 00       	cmp    $0x400,%eax
  802136:	75 cd                	jne    802105 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802138:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80213d:	5d                   	pop    %ebp
  80213e:	c3                   	ret    

0080213f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80213f:	55                   	push   %ebp
  802140:	89 e5                	mov    %esp,%ebp
  802142:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802145:	89 d0                	mov    %edx,%eax
  802147:	c1 e8 16             	shr    $0x16,%eax
  80214a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802151:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802156:	f6 c1 01             	test   $0x1,%cl
  802159:	74 1d                	je     802178 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80215b:	c1 ea 0c             	shr    $0xc,%edx
  80215e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802165:	f6 c2 01             	test   $0x1,%dl
  802168:	74 0e                	je     802178 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80216a:	c1 ea 0c             	shr    $0xc,%edx
  80216d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802174:	ef 
  802175:	0f b7 c0             	movzwl %ax,%eax
}
  802178:	5d                   	pop    %ebp
  802179:	c3                   	ret    
  80217a:	66 90                	xchg   %ax,%ax
  80217c:	66 90                	xchg   %ax,%ax
  80217e:	66 90                	xchg   %ax,%ax

00802180 <__udivdi3>:
  802180:	55                   	push   %ebp
  802181:	57                   	push   %edi
  802182:	56                   	push   %esi
  802183:	53                   	push   %ebx
  802184:	83 ec 1c             	sub    $0x1c,%esp
  802187:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80218b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80218f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802193:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802197:	85 f6                	test   %esi,%esi
  802199:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80219d:	89 ca                	mov    %ecx,%edx
  80219f:	89 f8                	mov    %edi,%eax
  8021a1:	75 3d                	jne    8021e0 <__udivdi3+0x60>
  8021a3:	39 cf                	cmp    %ecx,%edi
  8021a5:	0f 87 c5 00 00 00    	ja     802270 <__udivdi3+0xf0>
  8021ab:	85 ff                	test   %edi,%edi
  8021ad:	89 fd                	mov    %edi,%ebp
  8021af:	75 0b                	jne    8021bc <__udivdi3+0x3c>
  8021b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021b6:	31 d2                	xor    %edx,%edx
  8021b8:	f7 f7                	div    %edi
  8021ba:	89 c5                	mov    %eax,%ebp
  8021bc:	89 c8                	mov    %ecx,%eax
  8021be:	31 d2                	xor    %edx,%edx
  8021c0:	f7 f5                	div    %ebp
  8021c2:	89 c1                	mov    %eax,%ecx
  8021c4:	89 d8                	mov    %ebx,%eax
  8021c6:	89 cf                	mov    %ecx,%edi
  8021c8:	f7 f5                	div    %ebp
  8021ca:	89 c3                	mov    %eax,%ebx
  8021cc:	89 d8                	mov    %ebx,%eax
  8021ce:	89 fa                	mov    %edi,%edx
  8021d0:	83 c4 1c             	add    $0x1c,%esp
  8021d3:	5b                   	pop    %ebx
  8021d4:	5e                   	pop    %esi
  8021d5:	5f                   	pop    %edi
  8021d6:	5d                   	pop    %ebp
  8021d7:	c3                   	ret    
  8021d8:	90                   	nop
  8021d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	39 ce                	cmp    %ecx,%esi
  8021e2:	77 74                	ja     802258 <__udivdi3+0xd8>
  8021e4:	0f bd fe             	bsr    %esi,%edi
  8021e7:	83 f7 1f             	xor    $0x1f,%edi
  8021ea:	0f 84 98 00 00 00    	je     802288 <__udivdi3+0x108>
  8021f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8021f5:	89 f9                	mov    %edi,%ecx
  8021f7:	89 c5                	mov    %eax,%ebp
  8021f9:	29 fb                	sub    %edi,%ebx
  8021fb:	d3 e6                	shl    %cl,%esi
  8021fd:	89 d9                	mov    %ebx,%ecx
  8021ff:	d3 ed                	shr    %cl,%ebp
  802201:	89 f9                	mov    %edi,%ecx
  802203:	d3 e0                	shl    %cl,%eax
  802205:	09 ee                	or     %ebp,%esi
  802207:	89 d9                	mov    %ebx,%ecx
  802209:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80220d:	89 d5                	mov    %edx,%ebp
  80220f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802213:	d3 ed                	shr    %cl,%ebp
  802215:	89 f9                	mov    %edi,%ecx
  802217:	d3 e2                	shl    %cl,%edx
  802219:	89 d9                	mov    %ebx,%ecx
  80221b:	d3 e8                	shr    %cl,%eax
  80221d:	09 c2                	or     %eax,%edx
  80221f:	89 d0                	mov    %edx,%eax
  802221:	89 ea                	mov    %ebp,%edx
  802223:	f7 f6                	div    %esi
  802225:	89 d5                	mov    %edx,%ebp
  802227:	89 c3                	mov    %eax,%ebx
  802229:	f7 64 24 0c          	mull   0xc(%esp)
  80222d:	39 d5                	cmp    %edx,%ebp
  80222f:	72 10                	jb     802241 <__udivdi3+0xc1>
  802231:	8b 74 24 08          	mov    0x8(%esp),%esi
  802235:	89 f9                	mov    %edi,%ecx
  802237:	d3 e6                	shl    %cl,%esi
  802239:	39 c6                	cmp    %eax,%esi
  80223b:	73 07                	jae    802244 <__udivdi3+0xc4>
  80223d:	39 d5                	cmp    %edx,%ebp
  80223f:	75 03                	jne    802244 <__udivdi3+0xc4>
  802241:	83 eb 01             	sub    $0x1,%ebx
  802244:	31 ff                	xor    %edi,%edi
  802246:	89 d8                	mov    %ebx,%eax
  802248:	89 fa                	mov    %edi,%edx
  80224a:	83 c4 1c             	add    $0x1c,%esp
  80224d:	5b                   	pop    %ebx
  80224e:	5e                   	pop    %esi
  80224f:	5f                   	pop    %edi
  802250:	5d                   	pop    %ebp
  802251:	c3                   	ret    
  802252:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802258:	31 ff                	xor    %edi,%edi
  80225a:	31 db                	xor    %ebx,%ebx
  80225c:	89 d8                	mov    %ebx,%eax
  80225e:	89 fa                	mov    %edi,%edx
  802260:	83 c4 1c             	add    $0x1c,%esp
  802263:	5b                   	pop    %ebx
  802264:	5e                   	pop    %esi
  802265:	5f                   	pop    %edi
  802266:	5d                   	pop    %ebp
  802267:	c3                   	ret    
  802268:	90                   	nop
  802269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802270:	89 d8                	mov    %ebx,%eax
  802272:	f7 f7                	div    %edi
  802274:	31 ff                	xor    %edi,%edi
  802276:	89 c3                	mov    %eax,%ebx
  802278:	89 d8                	mov    %ebx,%eax
  80227a:	89 fa                	mov    %edi,%edx
  80227c:	83 c4 1c             	add    $0x1c,%esp
  80227f:	5b                   	pop    %ebx
  802280:	5e                   	pop    %esi
  802281:	5f                   	pop    %edi
  802282:	5d                   	pop    %ebp
  802283:	c3                   	ret    
  802284:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802288:	39 ce                	cmp    %ecx,%esi
  80228a:	72 0c                	jb     802298 <__udivdi3+0x118>
  80228c:	31 db                	xor    %ebx,%ebx
  80228e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802292:	0f 87 34 ff ff ff    	ja     8021cc <__udivdi3+0x4c>
  802298:	bb 01 00 00 00       	mov    $0x1,%ebx
  80229d:	e9 2a ff ff ff       	jmp    8021cc <__udivdi3+0x4c>
  8022a2:	66 90                	xchg   %ax,%ax
  8022a4:	66 90                	xchg   %ax,%ax
  8022a6:	66 90                	xchg   %ax,%ax
  8022a8:	66 90                	xchg   %ax,%ax
  8022aa:	66 90                	xchg   %ax,%ax
  8022ac:	66 90                	xchg   %ax,%ax
  8022ae:	66 90                	xchg   %ax,%ax

008022b0 <__umoddi3>:
  8022b0:	55                   	push   %ebp
  8022b1:	57                   	push   %edi
  8022b2:	56                   	push   %esi
  8022b3:	53                   	push   %ebx
  8022b4:	83 ec 1c             	sub    $0x1c,%esp
  8022b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022c7:	85 d2                	test   %edx,%edx
  8022c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022d1:	89 f3                	mov    %esi,%ebx
  8022d3:	89 3c 24             	mov    %edi,(%esp)
  8022d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022da:	75 1c                	jne    8022f8 <__umoddi3+0x48>
  8022dc:	39 f7                	cmp    %esi,%edi
  8022de:	76 50                	jbe    802330 <__umoddi3+0x80>
  8022e0:	89 c8                	mov    %ecx,%eax
  8022e2:	89 f2                	mov    %esi,%edx
  8022e4:	f7 f7                	div    %edi
  8022e6:	89 d0                	mov    %edx,%eax
  8022e8:	31 d2                	xor    %edx,%edx
  8022ea:	83 c4 1c             	add    $0x1c,%esp
  8022ed:	5b                   	pop    %ebx
  8022ee:	5e                   	pop    %esi
  8022ef:	5f                   	pop    %edi
  8022f0:	5d                   	pop    %ebp
  8022f1:	c3                   	ret    
  8022f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022f8:	39 f2                	cmp    %esi,%edx
  8022fa:	89 d0                	mov    %edx,%eax
  8022fc:	77 52                	ja     802350 <__umoddi3+0xa0>
  8022fe:	0f bd ea             	bsr    %edx,%ebp
  802301:	83 f5 1f             	xor    $0x1f,%ebp
  802304:	75 5a                	jne    802360 <__umoddi3+0xb0>
  802306:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80230a:	0f 82 e0 00 00 00    	jb     8023f0 <__umoddi3+0x140>
  802310:	39 0c 24             	cmp    %ecx,(%esp)
  802313:	0f 86 d7 00 00 00    	jbe    8023f0 <__umoddi3+0x140>
  802319:	8b 44 24 08          	mov    0x8(%esp),%eax
  80231d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802321:	83 c4 1c             	add    $0x1c,%esp
  802324:	5b                   	pop    %ebx
  802325:	5e                   	pop    %esi
  802326:	5f                   	pop    %edi
  802327:	5d                   	pop    %ebp
  802328:	c3                   	ret    
  802329:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802330:	85 ff                	test   %edi,%edi
  802332:	89 fd                	mov    %edi,%ebp
  802334:	75 0b                	jne    802341 <__umoddi3+0x91>
  802336:	b8 01 00 00 00       	mov    $0x1,%eax
  80233b:	31 d2                	xor    %edx,%edx
  80233d:	f7 f7                	div    %edi
  80233f:	89 c5                	mov    %eax,%ebp
  802341:	89 f0                	mov    %esi,%eax
  802343:	31 d2                	xor    %edx,%edx
  802345:	f7 f5                	div    %ebp
  802347:	89 c8                	mov    %ecx,%eax
  802349:	f7 f5                	div    %ebp
  80234b:	89 d0                	mov    %edx,%eax
  80234d:	eb 99                	jmp    8022e8 <__umoddi3+0x38>
  80234f:	90                   	nop
  802350:	89 c8                	mov    %ecx,%eax
  802352:	89 f2                	mov    %esi,%edx
  802354:	83 c4 1c             	add    $0x1c,%esp
  802357:	5b                   	pop    %ebx
  802358:	5e                   	pop    %esi
  802359:	5f                   	pop    %edi
  80235a:	5d                   	pop    %ebp
  80235b:	c3                   	ret    
  80235c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802360:	8b 34 24             	mov    (%esp),%esi
  802363:	bf 20 00 00 00       	mov    $0x20,%edi
  802368:	89 e9                	mov    %ebp,%ecx
  80236a:	29 ef                	sub    %ebp,%edi
  80236c:	d3 e0                	shl    %cl,%eax
  80236e:	89 f9                	mov    %edi,%ecx
  802370:	89 f2                	mov    %esi,%edx
  802372:	d3 ea                	shr    %cl,%edx
  802374:	89 e9                	mov    %ebp,%ecx
  802376:	09 c2                	or     %eax,%edx
  802378:	89 d8                	mov    %ebx,%eax
  80237a:	89 14 24             	mov    %edx,(%esp)
  80237d:	89 f2                	mov    %esi,%edx
  80237f:	d3 e2                	shl    %cl,%edx
  802381:	89 f9                	mov    %edi,%ecx
  802383:	89 54 24 04          	mov    %edx,0x4(%esp)
  802387:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80238b:	d3 e8                	shr    %cl,%eax
  80238d:	89 e9                	mov    %ebp,%ecx
  80238f:	89 c6                	mov    %eax,%esi
  802391:	d3 e3                	shl    %cl,%ebx
  802393:	89 f9                	mov    %edi,%ecx
  802395:	89 d0                	mov    %edx,%eax
  802397:	d3 e8                	shr    %cl,%eax
  802399:	89 e9                	mov    %ebp,%ecx
  80239b:	09 d8                	or     %ebx,%eax
  80239d:	89 d3                	mov    %edx,%ebx
  80239f:	89 f2                	mov    %esi,%edx
  8023a1:	f7 34 24             	divl   (%esp)
  8023a4:	89 d6                	mov    %edx,%esi
  8023a6:	d3 e3                	shl    %cl,%ebx
  8023a8:	f7 64 24 04          	mull   0x4(%esp)
  8023ac:	39 d6                	cmp    %edx,%esi
  8023ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023b2:	89 d1                	mov    %edx,%ecx
  8023b4:	89 c3                	mov    %eax,%ebx
  8023b6:	72 08                	jb     8023c0 <__umoddi3+0x110>
  8023b8:	75 11                	jne    8023cb <__umoddi3+0x11b>
  8023ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8023be:	73 0b                	jae    8023cb <__umoddi3+0x11b>
  8023c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023c4:	1b 14 24             	sbb    (%esp),%edx
  8023c7:	89 d1                	mov    %edx,%ecx
  8023c9:	89 c3                	mov    %eax,%ebx
  8023cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8023cf:	29 da                	sub    %ebx,%edx
  8023d1:	19 ce                	sbb    %ecx,%esi
  8023d3:	89 f9                	mov    %edi,%ecx
  8023d5:	89 f0                	mov    %esi,%eax
  8023d7:	d3 e0                	shl    %cl,%eax
  8023d9:	89 e9                	mov    %ebp,%ecx
  8023db:	d3 ea                	shr    %cl,%edx
  8023dd:	89 e9                	mov    %ebp,%ecx
  8023df:	d3 ee                	shr    %cl,%esi
  8023e1:	09 d0                	or     %edx,%eax
  8023e3:	89 f2                	mov    %esi,%edx
  8023e5:	83 c4 1c             	add    $0x1c,%esp
  8023e8:	5b                   	pop    %ebx
  8023e9:	5e                   	pop    %esi
  8023ea:	5f                   	pop    %edi
  8023eb:	5d                   	pop    %ebp
  8023ec:	c3                   	ret    
  8023ed:	8d 76 00             	lea    0x0(%esi),%esi
  8023f0:	29 f9                	sub    %edi,%ecx
  8023f2:	19 d6                	sbb    %edx,%esi
  8023f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023fc:	e9 18 ff ff ff       	jmp    802319 <__umoddi3+0x69>
