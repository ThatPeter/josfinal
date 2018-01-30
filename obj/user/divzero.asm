
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
  800051:	68 a0 24 80 00       	push   $0x8024a0
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
  800075:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  80007b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800080:	a3 08 40 80 00       	mov    %eax,0x804008
			thisenv = &envs[i];
		}
	}*/

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

void 
thread_main(/*uintptr_t eip*/)
{
  8000a9:	55                   	push   %ebp
  8000aa:	89 e5                	mov    %esp,%ebp
  8000ac:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

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
  8000cf:	e8 c5 13 00 00       	call   801499 <close_all>
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
  8001d9:	e8 22 20 00 00       	call   802200 <__udivdi3>
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
  80021c:	e8 0f 21 00 00       	call   802330 <__umoddi3>
  800221:	83 c4 14             	add    $0x14,%esp
  800224:	0f be 80 b8 24 80 00 	movsbl 0x8024b8(%eax),%eax
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
  800320:	ff 24 85 00 26 80 00 	jmp    *0x802600(,%eax,4)
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
  8003e4:	8b 14 85 60 27 80 00 	mov    0x802760(,%eax,4),%edx
  8003eb:	85 d2                	test   %edx,%edx
  8003ed:	75 18                	jne    800407 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003ef:	50                   	push   %eax
  8003f0:	68 d0 24 80 00       	push   $0x8024d0
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
  800408:	68 ed 29 80 00       	push   $0x8029ed
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
  80042c:	b8 c9 24 80 00       	mov    $0x8024c9,%eax
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
  800aa7:	68 bf 27 80 00       	push   $0x8027bf
  800aac:	6a 23                	push   $0x23
  800aae:	68 dc 27 80 00       	push   $0x8027dc
  800ab3:	e8 12 15 00 00       	call   801fca <_panic>

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
  800b28:	68 bf 27 80 00       	push   $0x8027bf
  800b2d:	6a 23                	push   $0x23
  800b2f:	68 dc 27 80 00       	push   $0x8027dc
  800b34:	e8 91 14 00 00       	call   801fca <_panic>

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
  800b6a:	68 bf 27 80 00       	push   $0x8027bf
  800b6f:	6a 23                	push   $0x23
  800b71:	68 dc 27 80 00       	push   $0x8027dc
  800b76:	e8 4f 14 00 00       	call   801fca <_panic>

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
  800bac:	68 bf 27 80 00       	push   $0x8027bf
  800bb1:	6a 23                	push   $0x23
  800bb3:	68 dc 27 80 00       	push   $0x8027dc
  800bb8:	e8 0d 14 00 00       	call   801fca <_panic>

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
  800bee:	68 bf 27 80 00       	push   $0x8027bf
  800bf3:	6a 23                	push   $0x23
  800bf5:	68 dc 27 80 00       	push   $0x8027dc
  800bfa:	e8 cb 13 00 00       	call   801fca <_panic>

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
  800c30:	68 bf 27 80 00       	push   $0x8027bf
  800c35:	6a 23                	push   $0x23
  800c37:	68 dc 27 80 00       	push   $0x8027dc
  800c3c:	e8 89 13 00 00       	call   801fca <_panic>
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
  800c72:	68 bf 27 80 00       	push   $0x8027bf
  800c77:	6a 23                	push   $0x23
  800c79:	68 dc 27 80 00       	push   $0x8027dc
  800c7e:	e8 47 13 00 00       	call   801fca <_panic>

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
  800cd6:	68 bf 27 80 00       	push   $0x8027bf
  800cdb:	6a 23                	push   $0x23
  800cdd:	68 dc 27 80 00       	push   $0x8027dc
  800ce2:	e8 e3 12 00 00       	call   801fca <_panic>

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
  800d75:	68 ea 27 80 00       	push   $0x8027ea
  800d7a:	6a 1f                	push   $0x1f
  800d7c:	68 fa 27 80 00       	push   $0x8027fa
  800d81:	e8 44 12 00 00       	call   801fca <_panic>
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
  800d9f:	68 05 28 80 00       	push   $0x802805
  800da4:	6a 2d                	push   $0x2d
  800da6:	68 fa 27 80 00       	push   $0x8027fa
  800dab:	e8 1a 12 00 00       	call   801fca <_panic>
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
  800de7:	68 05 28 80 00       	push   $0x802805
  800dec:	6a 34                	push   $0x34
  800dee:	68 fa 27 80 00       	push   $0x8027fa
  800df3:	e8 d2 11 00 00       	call   801fca <_panic>
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
  800e0f:	68 05 28 80 00       	push   $0x802805
  800e14:	6a 38                	push   $0x38
  800e16:	68 fa 27 80 00       	push   $0x8027fa
  800e1b:	e8 aa 11 00 00       	call   801fca <_panic>
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
  800e33:	e8 d8 11 00 00       	call   802010 <set_pgfault_handler>
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
  800e4c:	68 1e 28 80 00       	push   $0x80281e
  800e51:	68 85 00 00 00       	push   $0x85
  800e56:	68 fa 27 80 00       	push   $0x8027fa
  800e5b:	e8 6a 11 00 00       	call   801fca <_panic>
  800e60:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800e62:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e66:	75 24                	jne    800e8c <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e68:	e8 53 fc ff ff       	call   800ac0 <sys_getenvid>
  800e6d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e72:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  800f08:	68 2c 28 80 00       	push   $0x80282c
  800f0d:	6a 55                	push   $0x55
  800f0f:	68 fa 27 80 00       	push   $0x8027fa
  800f14:	e8 b1 10 00 00       	call   801fca <_panic>
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
  800f4d:	68 2c 28 80 00       	push   $0x80282c
  800f52:	6a 5c                	push   $0x5c
  800f54:	68 fa 27 80 00       	push   $0x8027fa
  800f59:	e8 6c 10 00 00       	call   801fca <_panic>
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
  800f7b:	68 2c 28 80 00       	push   $0x80282c
  800f80:	6a 60                	push   $0x60
  800f82:	68 fa 27 80 00       	push   $0x8027fa
  800f87:	e8 3e 10 00 00       	call   801fca <_panic>
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
  800fa5:	68 2c 28 80 00       	push   $0x80282c
  800faa:	6a 65                	push   $0x65
  800fac:	68 fa 27 80 00       	push   $0x8027fa
  800fb1:	e8 14 10 00 00       	call   801fca <_panic>
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
  800fcd:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
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
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801002:	55                   	push   %ebp
  801003:	89 e5                	mov    %esp,%ebp
  801005:	56                   	push   %esi
  801006:	53                   	push   %ebx
  801007:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  80100a:	89 1d 0c 40 80 00    	mov    %ebx,0x80400c
	cprintf("in fork.c thread create. func: %x\n", func);
  801010:	83 ec 08             	sub    $0x8,%esp
  801013:	53                   	push   %ebx
  801014:	68 bc 28 80 00       	push   $0x8028bc
  801019:	e8 58 f1 ff ff       	call   800176 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80101e:	c7 04 24 a9 00 80 00 	movl   $0x8000a9,(%esp)
  801025:	e8 c5 fc ff ff       	call   800cef <sys_thread_create>
  80102a:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80102c:	83 c4 08             	add    $0x8,%esp
  80102f:	53                   	push   %ebx
  801030:	68 bc 28 80 00       	push   $0x8028bc
  801035:	e8 3c f1 ff ff       	call   800176 <cprintf>
	return id;
}
  80103a:	89 f0                	mov    %esi,%eax
  80103c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80103f:	5b                   	pop    %ebx
  801040:	5e                   	pop    %esi
  801041:	5d                   	pop    %ebp
  801042:	c3                   	ret    

00801043 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  801043:	55                   	push   %ebp
  801044:	89 e5                	mov    %esp,%ebp
  801046:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  801049:	ff 75 08             	pushl  0x8(%ebp)
  80104c:	e8 be fc ff ff       	call   800d0f <sys_thread_free>
}
  801051:	83 c4 10             	add    $0x10,%esp
  801054:	c9                   	leave  
  801055:	c3                   	ret    

00801056 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  80105c:	ff 75 08             	pushl  0x8(%ebp)
  80105f:	e8 cb fc ff ff       	call   800d2f <sys_thread_join>
}
  801064:	83 c4 10             	add    $0x10,%esp
  801067:	c9                   	leave  
  801068:	c3                   	ret    

00801069 <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  801069:	55                   	push   %ebp
  80106a:	89 e5                	mov    %esp,%ebp
  80106c:	56                   	push   %esi
  80106d:	53                   	push   %ebx
  80106e:	8b 75 08             	mov    0x8(%ebp),%esi
  801071:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  801074:	83 ec 04             	sub    $0x4,%esp
  801077:	6a 07                	push   $0x7
  801079:	6a 00                	push   $0x0
  80107b:	56                   	push   %esi
  80107c:	e8 7d fa ff ff       	call   800afe <sys_page_alloc>
	if (r < 0) {
  801081:	83 c4 10             	add    $0x10,%esp
  801084:	85 c0                	test   %eax,%eax
  801086:	79 15                	jns    80109d <queue_append+0x34>
		panic("%e\n", r);
  801088:	50                   	push   %eax
  801089:	68 b8 28 80 00       	push   $0x8028b8
  80108e:	68 c4 00 00 00       	push   $0xc4
  801093:	68 fa 27 80 00       	push   $0x8027fa
  801098:	e8 2d 0f 00 00       	call   801fca <_panic>
	}	
	wt->envid = envid;
  80109d:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  8010a3:	83 ec 04             	sub    $0x4,%esp
  8010a6:	ff 33                	pushl  (%ebx)
  8010a8:	56                   	push   %esi
  8010a9:	68 e0 28 80 00       	push   $0x8028e0
  8010ae:	e8 c3 f0 ff ff       	call   800176 <cprintf>
	if (queue->first == NULL) {
  8010b3:	83 c4 10             	add    $0x10,%esp
  8010b6:	83 3b 00             	cmpl   $0x0,(%ebx)
  8010b9:	75 29                	jne    8010e4 <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  8010bb:	83 ec 0c             	sub    $0xc,%esp
  8010be:	68 42 28 80 00       	push   $0x802842
  8010c3:	e8 ae f0 ff ff       	call   800176 <cprintf>
		queue->first = wt;
  8010c8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  8010ce:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  8010d5:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8010dc:	00 00 00 
  8010df:	83 c4 10             	add    $0x10,%esp
  8010e2:	eb 2b                	jmp    80110f <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  8010e4:	83 ec 0c             	sub    $0xc,%esp
  8010e7:	68 5c 28 80 00       	push   $0x80285c
  8010ec:	e8 85 f0 ff ff       	call   800176 <cprintf>
		queue->last->next = wt;
  8010f1:	8b 43 04             	mov    0x4(%ebx),%eax
  8010f4:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  8010fb:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801102:	00 00 00 
		queue->last = wt;
  801105:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  80110c:	83 c4 10             	add    $0x10,%esp
	}
}
  80110f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801112:	5b                   	pop    %ebx
  801113:	5e                   	pop    %esi
  801114:	5d                   	pop    %ebp
  801115:	c3                   	ret    

00801116 <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  801116:	55                   	push   %ebp
  801117:	89 e5                	mov    %esp,%ebp
  801119:	53                   	push   %ebx
  80111a:	83 ec 04             	sub    $0x4,%esp
  80111d:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  801120:	8b 02                	mov    (%edx),%eax
  801122:	85 c0                	test   %eax,%eax
  801124:	75 17                	jne    80113d <queue_pop+0x27>
		panic("queue empty!\n");
  801126:	83 ec 04             	sub    $0x4,%esp
  801129:	68 7a 28 80 00       	push   $0x80287a
  80112e:	68 d8 00 00 00       	push   $0xd8
  801133:	68 fa 27 80 00       	push   $0x8027fa
  801138:	e8 8d 0e 00 00       	call   801fca <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  80113d:	8b 48 04             	mov    0x4(%eax),%ecx
  801140:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  801142:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  801144:	83 ec 08             	sub    $0x8,%esp
  801147:	53                   	push   %ebx
  801148:	68 88 28 80 00       	push   $0x802888
  80114d:	e8 24 f0 ff ff       	call   800176 <cprintf>
	return envid;
}
  801152:	89 d8                	mov    %ebx,%eax
  801154:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801157:	c9                   	leave  
  801158:	c3                   	ret    

00801159 <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  801159:	55                   	push   %ebp
  80115a:	89 e5                	mov    %esp,%ebp
  80115c:	53                   	push   %ebx
  80115d:	83 ec 04             	sub    $0x4,%esp
  801160:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  801163:	b8 01 00 00 00       	mov    $0x1,%eax
  801168:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  80116b:	85 c0                	test   %eax,%eax
  80116d:	74 5a                	je     8011c9 <mutex_lock+0x70>
  80116f:	8b 43 04             	mov    0x4(%ebx),%eax
  801172:	83 38 00             	cmpl   $0x0,(%eax)
  801175:	75 52                	jne    8011c9 <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  801177:	83 ec 0c             	sub    $0xc,%esp
  80117a:	68 08 29 80 00       	push   $0x802908
  80117f:	e8 f2 ef ff ff       	call   800176 <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  801184:	8b 5b 04             	mov    0x4(%ebx),%ebx
  801187:	e8 34 f9 ff ff       	call   800ac0 <sys_getenvid>
  80118c:	83 c4 08             	add    $0x8,%esp
  80118f:	53                   	push   %ebx
  801190:	50                   	push   %eax
  801191:	e8 d3 fe ff ff       	call   801069 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  801196:	e8 25 f9 ff ff       	call   800ac0 <sys_getenvid>
  80119b:	83 c4 08             	add    $0x8,%esp
  80119e:	6a 04                	push   $0x4
  8011a0:	50                   	push   %eax
  8011a1:	e8 1f fa ff ff       	call   800bc5 <sys_env_set_status>
		if (r < 0) {
  8011a6:	83 c4 10             	add    $0x10,%esp
  8011a9:	85 c0                	test   %eax,%eax
  8011ab:	79 15                	jns    8011c2 <mutex_lock+0x69>
			panic("%e\n", r);
  8011ad:	50                   	push   %eax
  8011ae:	68 b8 28 80 00       	push   $0x8028b8
  8011b3:	68 eb 00 00 00       	push   $0xeb
  8011b8:	68 fa 27 80 00       	push   $0x8027fa
  8011bd:	e8 08 0e 00 00       	call   801fca <_panic>
		}
		sys_yield();
  8011c2:	e8 18 f9 ff ff       	call   800adf <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8011c7:	eb 18                	jmp    8011e1 <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  8011c9:	83 ec 0c             	sub    $0xc,%esp
  8011cc:	68 28 29 80 00       	push   $0x802928
  8011d1:	e8 a0 ef ff ff       	call   800176 <cprintf>
	mtx->owner = sys_getenvid();}
  8011d6:	e8 e5 f8 ff ff       	call   800ac0 <sys_getenvid>
  8011db:	89 43 08             	mov    %eax,0x8(%ebx)
  8011de:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  8011e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011e4:	c9                   	leave  
  8011e5:	c3                   	ret    

008011e6 <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  8011e6:	55                   	push   %ebp
  8011e7:	89 e5                	mov    %esp,%ebp
  8011e9:	53                   	push   %ebx
  8011ea:	83 ec 04             	sub    $0x4,%esp
  8011ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8011f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f5:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  8011f8:	8b 43 04             	mov    0x4(%ebx),%eax
  8011fb:	83 38 00             	cmpl   $0x0,(%eax)
  8011fe:	74 33                	je     801233 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  801200:	83 ec 0c             	sub    $0xc,%esp
  801203:	50                   	push   %eax
  801204:	e8 0d ff ff ff       	call   801116 <queue_pop>
  801209:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  80120c:	83 c4 08             	add    $0x8,%esp
  80120f:	6a 02                	push   $0x2
  801211:	50                   	push   %eax
  801212:	e8 ae f9 ff ff       	call   800bc5 <sys_env_set_status>
		if (r < 0) {
  801217:	83 c4 10             	add    $0x10,%esp
  80121a:	85 c0                	test   %eax,%eax
  80121c:	79 15                	jns    801233 <mutex_unlock+0x4d>
			panic("%e\n", r);
  80121e:	50                   	push   %eax
  80121f:	68 b8 28 80 00       	push   $0x8028b8
  801224:	68 00 01 00 00       	push   $0x100
  801229:	68 fa 27 80 00       	push   $0x8027fa
  80122e:	e8 97 0d 00 00       	call   801fca <_panic>
		}
	}

	asm volatile("pause");
  801233:	f3 90                	pause  
	//sys_yield();
}
  801235:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801238:	c9                   	leave  
  801239:	c3                   	ret    

0080123a <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  80123a:	55                   	push   %ebp
  80123b:	89 e5                	mov    %esp,%ebp
  80123d:	53                   	push   %ebx
  80123e:	83 ec 04             	sub    $0x4,%esp
  801241:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  801244:	e8 77 f8 ff ff       	call   800ac0 <sys_getenvid>
  801249:	83 ec 04             	sub    $0x4,%esp
  80124c:	6a 07                	push   $0x7
  80124e:	53                   	push   %ebx
  80124f:	50                   	push   %eax
  801250:	e8 a9 f8 ff ff       	call   800afe <sys_page_alloc>
  801255:	83 c4 10             	add    $0x10,%esp
  801258:	85 c0                	test   %eax,%eax
  80125a:	79 15                	jns    801271 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  80125c:	50                   	push   %eax
  80125d:	68 a3 28 80 00       	push   $0x8028a3
  801262:	68 0d 01 00 00       	push   $0x10d
  801267:	68 fa 27 80 00       	push   $0x8027fa
  80126c:	e8 59 0d 00 00       	call   801fca <_panic>
	}	
	mtx->locked = 0;
  801271:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  801277:	8b 43 04             	mov    0x4(%ebx),%eax
  80127a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  801280:	8b 43 04             	mov    0x4(%ebx),%eax
  801283:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  80128a:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  801291:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801294:	c9                   	leave  
  801295:	c3                   	ret    

00801296 <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  801296:	55                   	push   %ebp
  801297:	89 e5                	mov    %esp,%ebp
  801299:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  80129c:	e8 1f f8 ff ff       	call   800ac0 <sys_getenvid>
  8012a1:	83 ec 08             	sub    $0x8,%esp
  8012a4:	ff 75 08             	pushl  0x8(%ebp)
  8012a7:	50                   	push   %eax
  8012a8:	e8 d6 f8 ff ff       	call   800b83 <sys_page_unmap>
	if (r < 0) {
  8012ad:	83 c4 10             	add    $0x10,%esp
  8012b0:	85 c0                	test   %eax,%eax
  8012b2:	79 15                	jns    8012c9 <mutex_destroy+0x33>
		panic("%e\n", r);
  8012b4:	50                   	push   %eax
  8012b5:	68 b8 28 80 00       	push   $0x8028b8
  8012ba:	68 1a 01 00 00       	push   $0x11a
  8012bf:	68 fa 27 80 00       	push   $0x8027fa
  8012c4:	e8 01 0d 00 00       	call   801fca <_panic>
	}
}
  8012c9:	c9                   	leave  
  8012ca:	c3                   	ret    

008012cb <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012cb:	55                   	push   %ebp
  8012cc:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d1:	05 00 00 00 30       	add    $0x30000000,%eax
  8012d6:	c1 e8 0c             	shr    $0xc,%eax
}
  8012d9:	5d                   	pop    %ebp
  8012da:	c3                   	ret    

008012db <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012db:	55                   	push   %ebp
  8012dc:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012de:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e1:	05 00 00 00 30       	add    $0x30000000,%eax
  8012e6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012eb:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012f0:	5d                   	pop    %ebp
  8012f1:	c3                   	ret    

008012f2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012f2:	55                   	push   %ebp
  8012f3:	89 e5                	mov    %esp,%ebp
  8012f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012f8:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012fd:	89 c2                	mov    %eax,%edx
  8012ff:	c1 ea 16             	shr    $0x16,%edx
  801302:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801309:	f6 c2 01             	test   $0x1,%dl
  80130c:	74 11                	je     80131f <fd_alloc+0x2d>
  80130e:	89 c2                	mov    %eax,%edx
  801310:	c1 ea 0c             	shr    $0xc,%edx
  801313:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80131a:	f6 c2 01             	test   $0x1,%dl
  80131d:	75 09                	jne    801328 <fd_alloc+0x36>
			*fd_store = fd;
  80131f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801321:	b8 00 00 00 00       	mov    $0x0,%eax
  801326:	eb 17                	jmp    80133f <fd_alloc+0x4d>
  801328:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80132d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801332:	75 c9                	jne    8012fd <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801334:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80133a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80133f:	5d                   	pop    %ebp
  801340:	c3                   	ret    

00801341 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801341:	55                   	push   %ebp
  801342:	89 e5                	mov    %esp,%ebp
  801344:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801347:	83 f8 1f             	cmp    $0x1f,%eax
  80134a:	77 36                	ja     801382 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80134c:	c1 e0 0c             	shl    $0xc,%eax
  80134f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801354:	89 c2                	mov    %eax,%edx
  801356:	c1 ea 16             	shr    $0x16,%edx
  801359:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801360:	f6 c2 01             	test   $0x1,%dl
  801363:	74 24                	je     801389 <fd_lookup+0x48>
  801365:	89 c2                	mov    %eax,%edx
  801367:	c1 ea 0c             	shr    $0xc,%edx
  80136a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801371:	f6 c2 01             	test   $0x1,%dl
  801374:	74 1a                	je     801390 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801376:	8b 55 0c             	mov    0xc(%ebp),%edx
  801379:	89 02                	mov    %eax,(%edx)
	return 0;
  80137b:	b8 00 00 00 00       	mov    $0x0,%eax
  801380:	eb 13                	jmp    801395 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801382:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801387:	eb 0c                	jmp    801395 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801389:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80138e:	eb 05                	jmp    801395 <fd_lookup+0x54>
  801390:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801395:	5d                   	pop    %ebp
  801396:	c3                   	ret    

00801397 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801397:	55                   	push   %ebp
  801398:	89 e5                	mov    %esp,%ebp
  80139a:	83 ec 08             	sub    $0x8,%esp
  80139d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013a0:	ba c4 29 80 00       	mov    $0x8029c4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013a5:	eb 13                	jmp    8013ba <dev_lookup+0x23>
  8013a7:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013aa:	39 08                	cmp    %ecx,(%eax)
  8013ac:	75 0c                	jne    8013ba <dev_lookup+0x23>
			*dev = devtab[i];
  8013ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013b1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b8:	eb 31                	jmp    8013eb <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013ba:	8b 02                	mov    (%edx),%eax
  8013bc:	85 c0                	test   %eax,%eax
  8013be:	75 e7                	jne    8013a7 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013c0:	a1 08 40 80 00       	mov    0x804008,%eax
  8013c5:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8013cb:	83 ec 04             	sub    $0x4,%esp
  8013ce:	51                   	push   %ecx
  8013cf:	50                   	push   %eax
  8013d0:	68 48 29 80 00       	push   $0x802948
  8013d5:	e8 9c ed ff ff       	call   800176 <cprintf>
	*dev = 0;
  8013da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013dd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013e3:	83 c4 10             	add    $0x10,%esp
  8013e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013eb:	c9                   	leave  
  8013ec:	c3                   	ret    

008013ed <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013ed:	55                   	push   %ebp
  8013ee:	89 e5                	mov    %esp,%ebp
  8013f0:	56                   	push   %esi
  8013f1:	53                   	push   %ebx
  8013f2:	83 ec 10             	sub    $0x10,%esp
  8013f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8013f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013fe:	50                   	push   %eax
  8013ff:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801405:	c1 e8 0c             	shr    $0xc,%eax
  801408:	50                   	push   %eax
  801409:	e8 33 ff ff ff       	call   801341 <fd_lookup>
  80140e:	83 c4 08             	add    $0x8,%esp
  801411:	85 c0                	test   %eax,%eax
  801413:	78 05                	js     80141a <fd_close+0x2d>
	    || fd != fd2)
  801415:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801418:	74 0c                	je     801426 <fd_close+0x39>
		return (must_exist ? r : 0);
  80141a:	84 db                	test   %bl,%bl
  80141c:	ba 00 00 00 00       	mov    $0x0,%edx
  801421:	0f 44 c2             	cmove  %edx,%eax
  801424:	eb 41                	jmp    801467 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801426:	83 ec 08             	sub    $0x8,%esp
  801429:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80142c:	50                   	push   %eax
  80142d:	ff 36                	pushl  (%esi)
  80142f:	e8 63 ff ff ff       	call   801397 <dev_lookup>
  801434:	89 c3                	mov    %eax,%ebx
  801436:	83 c4 10             	add    $0x10,%esp
  801439:	85 c0                	test   %eax,%eax
  80143b:	78 1a                	js     801457 <fd_close+0x6a>
		if (dev->dev_close)
  80143d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801440:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801443:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801448:	85 c0                	test   %eax,%eax
  80144a:	74 0b                	je     801457 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80144c:	83 ec 0c             	sub    $0xc,%esp
  80144f:	56                   	push   %esi
  801450:	ff d0                	call   *%eax
  801452:	89 c3                	mov    %eax,%ebx
  801454:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801457:	83 ec 08             	sub    $0x8,%esp
  80145a:	56                   	push   %esi
  80145b:	6a 00                	push   $0x0
  80145d:	e8 21 f7 ff ff       	call   800b83 <sys_page_unmap>
	return r;
  801462:	83 c4 10             	add    $0x10,%esp
  801465:	89 d8                	mov    %ebx,%eax
}
  801467:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80146a:	5b                   	pop    %ebx
  80146b:	5e                   	pop    %esi
  80146c:	5d                   	pop    %ebp
  80146d:	c3                   	ret    

0080146e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80146e:	55                   	push   %ebp
  80146f:	89 e5                	mov    %esp,%ebp
  801471:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801474:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801477:	50                   	push   %eax
  801478:	ff 75 08             	pushl  0x8(%ebp)
  80147b:	e8 c1 fe ff ff       	call   801341 <fd_lookup>
  801480:	83 c4 08             	add    $0x8,%esp
  801483:	85 c0                	test   %eax,%eax
  801485:	78 10                	js     801497 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801487:	83 ec 08             	sub    $0x8,%esp
  80148a:	6a 01                	push   $0x1
  80148c:	ff 75 f4             	pushl  -0xc(%ebp)
  80148f:	e8 59 ff ff ff       	call   8013ed <fd_close>
  801494:	83 c4 10             	add    $0x10,%esp
}
  801497:	c9                   	leave  
  801498:	c3                   	ret    

00801499 <close_all>:

void
close_all(void)
{
  801499:	55                   	push   %ebp
  80149a:	89 e5                	mov    %esp,%ebp
  80149c:	53                   	push   %ebx
  80149d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014a0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014a5:	83 ec 0c             	sub    $0xc,%esp
  8014a8:	53                   	push   %ebx
  8014a9:	e8 c0 ff ff ff       	call   80146e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014ae:	83 c3 01             	add    $0x1,%ebx
  8014b1:	83 c4 10             	add    $0x10,%esp
  8014b4:	83 fb 20             	cmp    $0x20,%ebx
  8014b7:	75 ec                	jne    8014a5 <close_all+0xc>
		close(i);
}
  8014b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014bc:	c9                   	leave  
  8014bd:	c3                   	ret    

008014be <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014be:	55                   	push   %ebp
  8014bf:	89 e5                	mov    %esp,%ebp
  8014c1:	57                   	push   %edi
  8014c2:	56                   	push   %esi
  8014c3:	53                   	push   %ebx
  8014c4:	83 ec 2c             	sub    $0x2c,%esp
  8014c7:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014ca:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014cd:	50                   	push   %eax
  8014ce:	ff 75 08             	pushl  0x8(%ebp)
  8014d1:	e8 6b fe ff ff       	call   801341 <fd_lookup>
  8014d6:	83 c4 08             	add    $0x8,%esp
  8014d9:	85 c0                	test   %eax,%eax
  8014db:	0f 88 c1 00 00 00    	js     8015a2 <dup+0xe4>
		return r;
	close(newfdnum);
  8014e1:	83 ec 0c             	sub    $0xc,%esp
  8014e4:	56                   	push   %esi
  8014e5:	e8 84 ff ff ff       	call   80146e <close>

	newfd = INDEX2FD(newfdnum);
  8014ea:	89 f3                	mov    %esi,%ebx
  8014ec:	c1 e3 0c             	shl    $0xc,%ebx
  8014ef:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014f5:	83 c4 04             	add    $0x4,%esp
  8014f8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014fb:	e8 db fd ff ff       	call   8012db <fd2data>
  801500:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801502:	89 1c 24             	mov    %ebx,(%esp)
  801505:	e8 d1 fd ff ff       	call   8012db <fd2data>
  80150a:	83 c4 10             	add    $0x10,%esp
  80150d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801510:	89 f8                	mov    %edi,%eax
  801512:	c1 e8 16             	shr    $0x16,%eax
  801515:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80151c:	a8 01                	test   $0x1,%al
  80151e:	74 37                	je     801557 <dup+0x99>
  801520:	89 f8                	mov    %edi,%eax
  801522:	c1 e8 0c             	shr    $0xc,%eax
  801525:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80152c:	f6 c2 01             	test   $0x1,%dl
  80152f:	74 26                	je     801557 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801531:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801538:	83 ec 0c             	sub    $0xc,%esp
  80153b:	25 07 0e 00 00       	and    $0xe07,%eax
  801540:	50                   	push   %eax
  801541:	ff 75 d4             	pushl  -0x2c(%ebp)
  801544:	6a 00                	push   $0x0
  801546:	57                   	push   %edi
  801547:	6a 00                	push   $0x0
  801549:	e8 f3 f5 ff ff       	call   800b41 <sys_page_map>
  80154e:	89 c7                	mov    %eax,%edi
  801550:	83 c4 20             	add    $0x20,%esp
  801553:	85 c0                	test   %eax,%eax
  801555:	78 2e                	js     801585 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801557:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80155a:	89 d0                	mov    %edx,%eax
  80155c:	c1 e8 0c             	shr    $0xc,%eax
  80155f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801566:	83 ec 0c             	sub    $0xc,%esp
  801569:	25 07 0e 00 00       	and    $0xe07,%eax
  80156e:	50                   	push   %eax
  80156f:	53                   	push   %ebx
  801570:	6a 00                	push   $0x0
  801572:	52                   	push   %edx
  801573:	6a 00                	push   $0x0
  801575:	e8 c7 f5 ff ff       	call   800b41 <sys_page_map>
  80157a:	89 c7                	mov    %eax,%edi
  80157c:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80157f:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801581:	85 ff                	test   %edi,%edi
  801583:	79 1d                	jns    8015a2 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801585:	83 ec 08             	sub    $0x8,%esp
  801588:	53                   	push   %ebx
  801589:	6a 00                	push   $0x0
  80158b:	e8 f3 f5 ff ff       	call   800b83 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801590:	83 c4 08             	add    $0x8,%esp
  801593:	ff 75 d4             	pushl  -0x2c(%ebp)
  801596:	6a 00                	push   $0x0
  801598:	e8 e6 f5 ff ff       	call   800b83 <sys_page_unmap>
	return r;
  80159d:	83 c4 10             	add    $0x10,%esp
  8015a0:	89 f8                	mov    %edi,%eax
}
  8015a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015a5:	5b                   	pop    %ebx
  8015a6:	5e                   	pop    %esi
  8015a7:	5f                   	pop    %edi
  8015a8:	5d                   	pop    %ebp
  8015a9:	c3                   	ret    

008015aa <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015aa:	55                   	push   %ebp
  8015ab:	89 e5                	mov    %esp,%ebp
  8015ad:	53                   	push   %ebx
  8015ae:	83 ec 14             	sub    $0x14,%esp
  8015b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b7:	50                   	push   %eax
  8015b8:	53                   	push   %ebx
  8015b9:	e8 83 fd ff ff       	call   801341 <fd_lookup>
  8015be:	83 c4 08             	add    $0x8,%esp
  8015c1:	89 c2                	mov    %eax,%edx
  8015c3:	85 c0                	test   %eax,%eax
  8015c5:	78 70                	js     801637 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c7:	83 ec 08             	sub    $0x8,%esp
  8015ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015cd:	50                   	push   %eax
  8015ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d1:	ff 30                	pushl  (%eax)
  8015d3:	e8 bf fd ff ff       	call   801397 <dev_lookup>
  8015d8:	83 c4 10             	add    $0x10,%esp
  8015db:	85 c0                	test   %eax,%eax
  8015dd:	78 4f                	js     80162e <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015df:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015e2:	8b 42 08             	mov    0x8(%edx),%eax
  8015e5:	83 e0 03             	and    $0x3,%eax
  8015e8:	83 f8 01             	cmp    $0x1,%eax
  8015eb:	75 24                	jne    801611 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015ed:	a1 08 40 80 00       	mov    0x804008,%eax
  8015f2:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8015f8:	83 ec 04             	sub    $0x4,%esp
  8015fb:	53                   	push   %ebx
  8015fc:	50                   	push   %eax
  8015fd:	68 89 29 80 00       	push   $0x802989
  801602:	e8 6f eb ff ff       	call   800176 <cprintf>
		return -E_INVAL;
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80160f:	eb 26                	jmp    801637 <read+0x8d>
	}
	if (!dev->dev_read)
  801611:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801614:	8b 40 08             	mov    0x8(%eax),%eax
  801617:	85 c0                	test   %eax,%eax
  801619:	74 17                	je     801632 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80161b:	83 ec 04             	sub    $0x4,%esp
  80161e:	ff 75 10             	pushl  0x10(%ebp)
  801621:	ff 75 0c             	pushl  0xc(%ebp)
  801624:	52                   	push   %edx
  801625:	ff d0                	call   *%eax
  801627:	89 c2                	mov    %eax,%edx
  801629:	83 c4 10             	add    $0x10,%esp
  80162c:	eb 09                	jmp    801637 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162e:	89 c2                	mov    %eax,%edx
  801630:	eb 05                	jmp    801637 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801632:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801637:	89 d0                	mov    %edx,%eax
  801639:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163c:	c9                   	leave  
  80163d:	c3                   	ret    

0080163e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
  801641:	57                   	push   %edi
  801642:	56                   	push   %esi
  801643:	53                   	push   %ebx
  801644:	83 ec 0c             	sub    $0xc,%esp
  801647:	8b 7d 08             	mov    0x8(%ebp),%edi
  80164a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80164d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801652:	eb 21                	jmp    801675 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801654:	83 ec 04             	sub    $0x4,%esp
  801657:	89 f0                	mov    %esi,%eax
  801659:	29 d8                	sub    %ebx,%eax
  80165b:	50                   	push   %eax
  80165c:	89 d8                	mov    %ebx,%eax
  80165e:	03 45 0c             	add    0xc(%ebp),%eax
  801661:	50                   	push   %eax
  801662:	57                   	push   %edi
  801663:	e8 42 ff ff ff       	call   8015aa <read>
		if (m < 0)
  801668:	83 c4 10             	add    $0x10,%esp
  80166b:	85 c0                	test   %eax,%eax
  80166d:	78 10                	js     80167f <readn+0x41>
			return m;
		if (m == 0)
  80166f:	85 c0                	test   %eax,%eax
  801671:	74 0a                	je     80167d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801673:	01 c3                	add    %eax,%ebx
  801675:	39 f3                	cmp    %esi,%ebx
  801677:	72 db                	jb     801654 <readn+0x16>
  801679:	89 d8                	mov    %ebx,%eax
  80167b:	eb 02                	jmp    80167f <readn+0x41>
  80167d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80167f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801682:	5b                   	pop    %ebx
  801683:	5e                   	pop    %esi
  801684:	5f                   	pop    %edi
  801685:	5d                   	pop    %ebp
  801686:	c3                   	ret    

00801687 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801687:	55                   	push   %ebp
  801688:	89 e5                	mov    %esp,%ebp
  80168a:	53                   	push   %ebx
  80168b:	83 ec 14             	sub    $0x14,%esp
  80168e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801691:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801694:	50                   	push   %eax
  801695:	53                   	push   %ebx
  801696:	e8 a6 fc ff ff       	call   801341 <fd_lookup>
  80169b:	83 c4 08             	add    $0x8,%esp
  80169e:	89 c2                	mov    %eax,%edx
  8016a0:	85 c0                	test   %eax,%eax
  8016a2:	78 6b                	js     80170f <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a4:	83 ec 08             	sub    $0x8,%esp
  8016a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016aa:	50                   	push   %eax
  8016ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ae:	ff 30                	pushl  (%eax)
  8016b0:	e8 e2 fc ff ff       	call   801397 <dev_lookup>
  8016b5:	83 c4 10             	add    $0x10,%esp
  8016b8:	85 c0                	test   %eax,%eax
  8016ba:	78 4a                	js     801706 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016bf:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016c3:	75 24                	jne    8016e9 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016c5:	a1 08 40 80 00       	mov    0x804008,%eax
  8016ca:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8016d0:	83 ec 04             	sub    $0x4,%esp
  8016d3:	53                   	push   %ebx
  8016d4:	50                   	push   %eax
  8016d5:	68 a5 29 80 00       	push   $0x8029a5
  8016da:	e8 97 ea ff ff       	call   800176 <cprintf>
		return -E_INVAL;
  8016df:	83 c4 10             	add    $0x10,%esp
  8016e2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016e7:	eb 26                	jmp    80170f <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016ec:	8b 52 0c             	mov    0xc(%edx),%edx
  8016ef:	85 d2                	test   %edx,%edx
  8016f1:	74 17                	je     80170a <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016f3:	83 ec 04             	sub    $0x4,%esp
  8016f6:	ff 75 10             	pushl  0x10(%ebp)
  8016f9:	ff 75 0c             	pushl  0xc(%ebp)
  8016fc:	50                   	push   %eax
  8016fd:	ff d2                	call   *%edx
  8016ff:	89 c2                	mov    %eax,%edx
  801701:	83 c4 10             	add    $0x10,%esp
  801704:	eb 09                	jmp    80170f <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801706:	89 c2                	mov    %eax,%edx
  801708:	eb 05                	jmp    80170f <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80170a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80170f:	89 d0                	mov    %edx,%eax
  801711:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801714:	c9                   	leave  
  801715:	c3                   	ret    

00801716 <seek>:

int
seek(int fdnum, off_t offset)
{
  801716:	55                   	push   %ebp
  801717:	89 e5                	mov    %esp,%ebp
  801719:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80171c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80171f:	50                   	push   %eax
  801720:	ff 75 08             	pushl  0x8(%ebp)
  801723:	e8 19 fc ff ff       	call   801341 <fd_lookup>
  801728:	83 c4 08             	add    $0x8,%esp
  80172b:	85 c0                	test   %eax,%eax
  80172d:	78 0e                	js     80173d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80172f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801732:	8b 55 0c             	mov    0xc(%ebp),%edx
  801735:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801738:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80173d:	c9                   	leave  
  80173e:	c3                   	ret    

0080173f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80173f:	55                   	push   %ebp
  801740:	89 e5                	mov    %esp,%ebp
  801742:	53                   	push   %ebx
  801743:	83 ec 14             	sub    $0x14,%esp
  801746:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801749:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80174c:	50                   	push   %eax
  80174d:	53                   	push   %ebx
  80174e:	e8 ee fb ff ff       	call   801341 <fd_lookup>
  801753:	83 c4 08             	add    $0x8,%esp
  801756:	89 c2                	mov    %eax,%edx
  801758:	85 c0                	test   %eax,%eax
  80175a:	78 68                	js     8017c4 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80175c:	83 ec 08             	sub    $0x8,%esp
  80175f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801762:	50                   	push   %eax
  801763:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801766:	ff 30                	pushl  (%eax)
  801768:	e8 2a fc ff ff       	call   801397 <dev_lookup>
  80176d:	83 c4 10             	add    $0x10,%esp
  801770:	85 c0                	test   %eax,%eax
  801772:	78 47                	js     8017bb <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801774:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801777:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80177b:	75 24                	jne    8017a1 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80177d:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801782:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801788:	83 ec 04             	sub    $0x4,%esp
  80178b:	53                   	push   %ebx
  80178c:	50                   	push   %eax
  80178d:	68 68 29 80 00       	push   $0x802968
  801792:	e8 df e9 ff ff       	call   800176 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801797:	83 c4 10             	add    $0x10,%esp
  80179a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80179f:	eb 23                	jmp    8017c4 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  8017a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017a4:	8b 52 18             	mov    0x18(%edx),%edx
  8017a7:	85 d2                	test   %edx,%edx
  8017a9:	74 14                	je     8017bf <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017ab:	83 ec 08             	sub    $0x8,%esp
  8017ae:	ff 75 0c             	pushl  0xc(%ebp)
  8017b1:	50                   	push   %eax
  8017b2:	ff d2                	call   *%edx
  8017b4:	89 c2                	mov    %eax,%edx
  8017b6:	83 c4 10             	add    $0x10,%esp
  8017b9:	eb 09                	jmp    8017c4 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017bb:	89 c2                	mov    %eax,%edx
  8017bd:	eb 05                	jmp    8017c4 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017bf:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017c4:	89 d0                	mov    %edx,%eax
  8017c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c9:	c9                   	leave  
  8017ca:	c3                   	ret    

008017cb <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017cb:	55                   	push   %ebp
  8017cc:	89 e5                	mov    %esp,%ebp
  8017ce:	53                   	push   %ebx
  8017cf:	83 ec 14             	sub    $0x14,%esp
  8017d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d8:	50                   	push   %eax
  8017d9:	ff 75 08             	pushl  0x8(%ebp)
  8017dc:	e8 60 fb ff ff       	call   801341 <fd_lookup>
  8017e1:	83 c4 08             	add    $0x8,%esp
  8017e4:	89 c2                	mov    %eax,%edx
  8017e6:	85 c0                	test   %eax,%eax
  8017e8:	78 58                	js     801842 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ea:	83 ec 08             	sub    $0x8,%esp
  8017ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f0:	50                   	push   %eax
  8017f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f4:	ff 30                	pushl  (%eax)
  8017f6:	e8 9c fb ff ff       	call   801397 <dev_lookup>
  8017fb:	83 c4 10             	add    $0x10,%esp
  8017fe:	85 c0                	test   %eax,%eax
  801800:	78 37                	js     801839 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801802:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801805:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801809:	74 32                	je     80183d <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80180b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80180e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801815:	00 00 00 
	stat->st_isdir = 0;
  801818:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80181f:	00 00 00 
	stat->st_dev = dev;
  801822:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801828:	83 ec 08             	sub    $0x8,%esp
  80182b:	53                   	push   %ebx
  80182c:	ff 75 f0             	pushl  -0x10(%ebp)
  80182f:	ff 50 14             	call   *0x14(%eax)
  801832:	89 c2                	mov    %eax,%edx
  801834:	83 c4 10             	add    $0x10,%esp
  801837:	eb 09                	jmp    801842 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801839:	89 c2                	mov    %eax,%edx
  80183b:	eb 05                	jmp    801842 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80183d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801842:	89 d0                	mov    %edx,%eax
  801844:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801847:	c9                   	leave  
  801848:	c3                   	ret    

00801849 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801849:	55                   	push   %ebp
  80184a:	89 e5                	mov    %esp,%ebp
  80184c:	56                   	push   %esi
  80184d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80184e:	83 ec 08             	sub    $0x8,%esp
  801851:	6a 00                	push   $0x0
  801853:	ff 75 08             	pushl  0x8(%ebp)
  801856:	e8 e3 01 00 00       	call   801a3e <open>
  80185b:	89 c3                	mov    %eax,%ebx
  80185d:	83 c4 10             	add    $0x10,%esp
  801860:	85 c0                	test   %eax,%eax
  801862:	78 1b                	js     80187f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801864:	83 ec 08             	sub    $0x8,%esp
  801867:	ff 75 0c             	pushl  0xc(%ebp)
  80186a:	50                   	push   %eax
  80186b:	e8 5b ff ff ff       	call   8017cb <fstat>
  801870:	89 c6                	mov    %eax,%esi
	close(fd);
  801872:	89 1c 24             	mov    %ebx,(%esp)
  801875:	e8 f4 fb ff ff       	call   80146e <close>
	return r;
  80187a:	83 c4 10             	add    $0x10,%esp
  80187d:	89 f0                	mov    %esi,%eax
}
  80187f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801882:	5b                   	pop    %ebx
  801883:	5e                   	pop    %esi
  801884:	5d                   	pop    %ebp
  801885:	c3                   	ret    

00801886 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801886:	55                   	push   %ebp
  801887:	89 e5                	mov    %esp,%ebp
  801889:	56                   	push   %esi
  80188a:	53                   	push   %ebx
  80188b:	89 c6                	mov    %eax,%esi
  80188d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80188f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801896:	75 12                	jne    8018aa <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801898:	83 ec 0c             	sub    $0xc,%esp
  80189b:	6a 01                	push   $0x1
  80189d:	e8 da 08 00 00       	call   80217c <ipc_find_env>
  8018a2:	a3 00 40 80 00       	mov    %eax,0x804000
  8018a7:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018aa:	6a 07                	push   $0x7
  8018ac:	68 00 50 80 00       	push   $0x805000
  8018b1:	56                   	push   %esi
  8018b2:	ff 35 00 40 80 00    	pushl  0x804000
  8018b8:	e8 5d 08 00 00       	call   80211a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018bd:	83 c4 0c             	add    $0xc,%esp
  8018c0:	6a 00                	push   $0x0
  8018c2:	53                   	push   %ebx
  8018c3:	6a 00                	push   $0x0
  8018c5:	e8 d5 07 00 00       	call   80209f <ipc_recv>
}
  8018ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018cd:	5b                   	pop    %ebx
  8018ce:	5e                   	pop    %esi
  8018cf:	5d                   	pop    %ebp
  8018d0:	c3                   	ret    

008018d1 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018d1:	55                   	push   %ebp
  8018d2:	89 e5                	mov    %esp,%ebp
  8018d4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018da:	8b 40 0c             	mov    0xc(%eax),%eax
  8018dd:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e5:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ef:	b8 02 00 00 00       	mov    $0x2,%eax
  8018f4:	e8 8d ff ff ff       	call   801886 <fsipc>
}
  8018f9:	c9                   	leave  
  8018fa:	c3                   	ret    

008018fb <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018fb:	55                   	push   %ebp
  8018fc:	89 e5                	mov    %esp,%ebp
  8018fe:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801901:	8b 45 08             	mov    0x8(%ebp),%eax
  801904:	8b 40 0c             	mov    0xc(%eax),%eax
  801907:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80190c:	ba 00 00 00 00       	mov    $0x0,%edx
  801911:	b8 06 00 00 00       	mov    $0x6,%eax
  801916:	e8 6b ff ff ff       	call   801886 <fsipc>
}
  80191b:	c9                   	leave  
  80191c:	c3                   	ret    

0080191d <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80191d:	55                   	push   %ebp
  80191e:	89 e5                	mov    %esp,%ebp
  801920:	53                   	push   %ebx
  801921:	83 ec 04             	sub    $0x4,%esp
  801924:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801927:	8b 45 08             	mov    0x8(%ebp),%eax
  80192a:	8b 40 0c             	mov    0xc(%eax),%eax
  80192d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801932:	ba 00 00 00 00       	mov    $0x0,%edx
  801937:	b8 05 00 00 00       	mov    $0x5,%eax
  80193c:	e8 45 ff ff ff       	call   801886 <fsipc>
  801941:	85 c0                	test   %eax,%eax
  801943:	78 2c                	js     801971 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801945:	83 ec 08             	sub    $0x8,%esp
  801948:	68 00 50 80 00       	push   $0x805000
  80194d:	53                   	push   %ebx
  80194e:	e8 a8 ed ff ff       	call   8006fb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801953:	a1 80 50 80 00       	mov    0x805080,%eax
  801958:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80195e:	a1 84 50 80 00       	mov    0x805084,%eax
  801963:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801969:	83 c4 10             	add    $0x10,%esp
  80196c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801971:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801974:	c9                   	leave  
  801975:	c3                   	ret    

00801976 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801976:	55                   	push   %ebp
  801977:	89 e5                	mov    %esp,%ebp
  801979:	83 ec 0c             	sub    $0xc,%esp
  80197c:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80197f:	8b 55 08             	mov    0x8(%ebp),%edx
  801982:	8b 52 0c             	mov    0xc(%edx),%edx
  801985:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80198b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801990:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801995:	0f 47 c2             	cmova  %edx,%eax
  801998:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80199d:	50                   	push   %eax
  80199e:	ff 75 0c             	pushl  0xc(%ebp)
  8019a1:	68 08 50 80 00       	push   $0x805008
  8019a6:	e8 e2 ee ff ff       	call   80088d <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8019ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b0:	b8 04 00 00 00       	mov    $0x4,%eax
  8019b5:	e8 cc fe ff ff       	call   801886 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8019ba:	c9                   	leave  
  8019bb:	c3                   	ret    

008019bc <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019bc:	55                   	push   %ebp
  8019bd:	89 e5                	mov    %esp,%ebp
  8019bf:	56                   	push   %esi
  8019c0:	53                   	push   %ebx
  8019c1:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c7:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ca:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019cf:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8019da:	b8 03 00 00 00       	mov    $0x3,%eax
  8019df:	e8 a2 fe ff ff       	call   801886 <fsipc>
  8019e4:	89 c3                	mov    %eax,%ebx
  8019e6:	85 c0                	test   %eax,%eax
  8019e8:	78 4b                	js     801a35 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019ea:	39 c6                	cmp    %eax,%esi
  8019ec:	73 16                	jae    801a04 <devfile_read+0x48>
  8019ee:	68 d4 29 80 00       	push   $0x8029d4
  8019f3:	68 db 29 80 00       	push   $0x8029db
  8019f8:	6a 7c                	push   $0x7c
  8019fa:	68 f0 29 80 00       	push   $0x8029f0
  8019ff:	e8 c6 05 00 00       	call   801fca <_panic>
	assert(r <= PGSIZE);
  801a04:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a09:	7e 16                	jle    801a21 <devfile_read+0x65>
  801a0b:	68 fb 29 80 00       	push   $0x8029fb
  801a10:	68 db 29 80 00       	push   $0x8029db
  801a15:	6a 7d                	push   $0x7d
  801a17:	68 f0 29 80 00       	push   $0x8029f0
  801a1c:	e8 a9 05 00 00       	call   801fca <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a21:	83 ec 04             	sub    $0x4,%esp
  801a24:	50                   	push   %eax
  801a25:	68 00 50 80 00       	push   $0x805000
  801a2a:	ff 75 0c             	pushl  0xc(%ebp)
  801a2d:	e8 5b ee ff ff       	call   80088d <memmove>
	return r;
  801a32:	83 c4 10             	add    $0x10,%esp
}
  801a35:	89 d8                	mov    %ebx,%eax
  801a37:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a3a:	5b                   	pop    %ebx
  801a3b:	5e                   	pop    %esi
  801a3c:	5d                   	pop    %ebp
  801a3d:	c3                   	ret    

00801a3e <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a3e:	55                   	push   %ebp
  801a3f:	89 e5                	mov    %esp,%ebp
  801a41:	53                   	push   %ebx
  801a42:	83 ec 20             	sub    $0x20,%esp
  801a45:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a48:	53                   	push   %ebx
  801a49:	e8 74 ec ff ff       	call   8006c2 <strlen>
  801a4e:	83 c4 10             	add    $0x10,%esp
  801a51:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a56:	7f 67                	jg     801abf <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a58:	83 ec 0c             	sub    $0xc,%esp
  801a5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a5e:	50                   	push   %eax
  801a5f:	e8 8e f8 ff ff       	call   8012f2 <fd_alloc>
  801a64:	83 c4 10             	add    $0x10,%esp
		return r;
  801a67:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a69:	85 c0                	test   %eax,%eax
  801a6b:	78 57                	js     801ac4 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a6d:	83 ec 08             	sub    $0x8,%esp
  801a70:	53                   	push   %ebx
  801a71:	68 00 50 80 00       	push   $0x805000
  801a76:	e8 80 ec ff ff       	call   8006fb <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a7e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a83:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a86:	b8 01 00 00 00       	mov    $0x1,%eax
  801a8b:	e8 f6 fd ff ff       	call   801886 <fsipc>
  801a90:	89 c3                	mov    %eax,%ebx
  801a92:	83 c4 10             	add    $0x10,%esp
  801a95:	85 c0                	test   %eax,%eax
  801a97:	79 14                	jns    801aad <open+0x6f>
		fd_close(fd, 0);
  801a99:	83 ec 08             	sub    $0x8,%esp
  801a9c:	6a 00                	push   $0x0
  801a9e:	ff 75 f4             	pushl  -0xc(%ebp)
  801aa1:	e8 47 f9 ff ff       	call   8013ed <fd_close>
		return r;
  801aa6:	83 c4 10             	add    $0x10,%esp
  801aa9:	89 da                	mov    %ebx,%edx
  801aab:	eb 17                	jmp    801ac4 <open+0x86>
	}

	return fd2num(fd);
  801aad:	83 ec 0c             	sub    $0xc,%esp
  801ab0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ab3:	e8 13 f8 ff ff       	call   8012cb <fd2num>
  801ab8:	89 c2                	mov    %eax,%edx
  801aba:	83 c4 10             	add    $0x10,%esp
  801abd:	eb 05                	jmp    801ac4 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801abf:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ac4:	89 d0                	mov    %edx,%eax
  801ac6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ac9:	c9                   	leave  
  801aca:	c3                   	ret    

00801acb <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801acb:	55                   	push   %ebp
  801acc:	89 e5                	mov    %esp,%ebp
  801ace:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ad1:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad6:	b8 08 00 00 00       	mov    $0x8,%eax
  801adb:	e8 a6 fd ff ff       	call   801886 <fsipc>
}
  801ae0:	c9                   	leave  
  801ae1:	c3                   	ret    

00801ae2 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ae2:	55                   	push   %ebp
  801ae3:	89 e5                	mov    %esp,%ebp
  801ae5:	56                   	push   %esi
  801ae6:	53                   	push   %ebx
  801ae7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801aea:	83 ec 0c             	sub    $0xc,%esp
  801aed:	ff 75 08             	pushl  0x8(%ebp)
  801af0:	e8 e6 f7 ff ff       	call   8012db <fd2data>
  801af5:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801af7:	83 c4 08             	add    $0x8,%esp
  801afa:	68 07 2a 80 00       	push   $0x802a07
  801aff:	53                   	push   %ebx
  801b00:	e8 f6 eb ff ff       	call   8006fb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b05:	8b 46 04             	mov    0x4(%esi),%eax
  801b08:	2b 06                	sub    (%esi),%eax
  801b0a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b10:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b17:	00 00 00 
	stat->st_dev = &devpipe;
  801b1a:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b21:	30 80 00 
	return 0;
}
  801b24:	b8 00 00 00 00       	mov    $0x0,%eax
  801b29:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b2c:	5b                   	pop    %ebx
  801b2d:	5e                   	pop    %esi
  801b2e:	5d                   	pop    %ebp
  801b2f:	c3                   	ret    

00801b30 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b30:	55                   	push   %ebp
  801b31:	89 e5                	mov    %esp,%ebp
  801b33:	53                   	push   %ebx
  801b34:	83 ec 0c             	sub    $0xc,%esp
  801b37:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b3a:	53                   	push   %ebx
  801b3b:	6a 00                	push   $0x0
  801b3d:	e8 41 f0 ff ff       	call   800b83 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b42:	89 1c 24             	mov    %ebx,(%esp)
  801b45:	e8 91 f7 ff ff       	call   8012db <fd2data>
  801b4a:	83 c4 08             	add    $0x8,%esp
  801b4d:	50                   	push   %eax
  801b4e:	6a 00                	push   $0x0
  801b50:	e8 2e f0 ff ff       	call   800b83 <sys_page_unmap>
}
  801b55:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b58:	c9                   	leave  
  801b59:	c3                   	ret    

00801b5a <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b5a:	55                   	push   %ebp
  801b5b:	89 e5                	mov    %esp,%ebp
  801b5d:	57                   	push   %edi
  801b5e:	56                   	push   %esi
  801b5f:	53                   	push   %ebx
  801b60:	83 ec 1c             	sub    $0x1c,%esp
  801b63:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b66:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b68:	a1 08 40 80 00       	mov    0x804008,%eax
  801b6d:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b73:	83 ec 0c             	sub    $0xc,%esp
  801b76:	ff 75 e0             	pushl  -0x20(%ebp)
  801b79:	e8 43 06 00 00       	call   8021c1 <pageref>
  801b7e:	89 c3                	mov    %eax,%ebx
  801b80:	89 3c 24             	mov    %edi,(%esp)
  801b83:	e8 39 06 00 00       	call   8021c1 <pageref>
  801b88:	83 c4 10             	add    $0x10,%esp
  801b8b:	39 c3                	cmp    %eax,%ebx
  801b8d:	0f 94 c1             	sete   %cl
  801b90:	0f b6 c9             	movzbl %cl,%ecx
  801b93:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b96:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801b9c:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801ba2:	39 ce                	cmp    %ecx,%esi
  801ba4:	74 1e                	je     801bc4 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801ba6:	39 c3                	cmp    %eax,%ebx
  801ba8:	75 be                	jne    801b68 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801baa:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801bb0:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bb3:	50                   	push   %eax
  801bb4:	56                   	push   %esi
  801bb5:	68 0e 2a 80 00       	push   $0x802a0e
  801bba:	e8 b7 e5 ff ff       	call   800176 <cprintf>
  801bbf:	83 c4 10             	add    $0x10,%esp
  801bc2:	eb a4                	jmp    801b68 <_pipeisclosed+0xe>
	}
}
  801bc4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bca:	5b                   	pop    %ebx
  801bcb:	5e                   	pop    %esi
  801bcc:	5f                   	pop    %edi
  801bcd:	5d                   	pop    %ebp
  801bce:	c3                   	ret    

00801bcf <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bcf:	55                   	push   %ebp
  801bd0:	89 e5                	mov    %esp,%ebp
  801bd2:	57                   	push   %edi
  801bd3:	56                   	push   %esi
  801bd4:	53                   	push   %ebx
  801bd5:	83 ec 28             	sub    $0x28,%esp
  801bd8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bdb:	56                   	push   %esi
  801bdc:	e8 fa f6 ff ff       	call   8012db <fd2data>
  801be1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be3:	83 c4 10             	add    $0x10,%esp
  801be6:	bf 00 00 00 00       	mov    $0x0,%edi
  801beb:	eb 4b                	jmp    801c38 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bed:	89 da                	mov    %ebx,%edx
  801bef:	89 f0                	mov    %esi,%eax
  801bf1:	e8 64 ff ff ff       	call   801b5a <_pipeisclosed>
  801bf6:	85 c0                	test   %eax,%eax
  801bf8:	75 48                	jne    801c42 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bfa:	e8 e0 ee ff ff       	call   800adf <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bff:	8b 43 04             	mov    0x4(%ebx),%eax
  801c02:	8b 0b                	mov    (%ebx),%ecx
  801c04:	8d 51 20             	lea    0x20(%ecx),%edx
  801c07:	39 d0                	cmp    %edx,%eax
  801c09:	73 e2                	jae    801bed <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c0e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c12:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c15:	89 c2                	mov    %eax,%edx
  801c17:	c1 fa 1f             	sar    $0x1f,%edx
  801c1a:	89 d1                	mov    %edx,%ecx
  801c1c:	c1 e9 1b             	shr    $0x1b,%ecx
  801c1f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c22:	83 e2 1f             	and    $0x1f,%edx
  801c25:	29 ca                	sub    %ecx,%edx
  801c27:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c2b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c2f:	83 c0 01             	add    $0x1,%eax
  801c32:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c35:	83 c7 01             	add    $0x1,%edi
  801c38:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c3b:	75 c2                	jne    801bff <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c3d:	8b 45 10             	mov    0x10(%ebp),%eax
  801c40:	eb 05                	jmp    801c47 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c42:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c4a:	5b                   	pop    %ebx
  801c4b:	5e                   	pop    %esi
  801c4c:	5f                   	pop    %edi
  801c4d:	5d                   	pop    %ebp
  801c4e:	c3                   	ret    

00801c4f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c4f:	55                   	push   %ebp
  801c50:	89 e5                	mov    %esp,%ebp
  801c52:	57                   	push   %edi
  801c53:	56                   	push   %esi
  801c54:	53                   	push   %ebx
  801c55:	83 ec 18             	sub    $0x18,%esp
  801c58:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c5b:	57                   	push   %edi
  801c5c:	e8 7a f6 ff ff       	call   8012db <fd2data>
  801c61:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c63:	83 c4 10             	add    $0x10,%esp
  801c66:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c6b:	eb 3d                	jmp    801caa <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c6d:	85 db                	test   %ebx,%ebx
  801c6f:	74 04                	je     801c75 <devpipe_read+0x26>
				return i;
  801c71:	89 d8                	mov    %ebx,%eax
  801c73:	eb 44                	jmp    801cb9 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c75:	89 f2                	mov    %esi,%edx
  801c77:	89 f8                	mov    %edi,%eax
  801c79:	e8 dc fe ff ff       	call   801b5a <_pipeisclosed>
  801c7e:	85 c0                	test   %eax,%eax
  801c80:	75 32                	jne    801cb4 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c82:	e8 58 ee ff ff       	call   800adf <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c87:	8b 06                	mov    (%esi),%eax
  801c89:	3b 46 04             	cmp    0x4(%esi),%eax
  801c8c:	74 df                	je     801c6d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c8e:	99                   	cltd   
  801c8f:	c1 ea 1b             	shr    $0x1b,%edx
  801c92:	01 d0                	add    %edx,%eax
  801c94:	83 e0 1f             	and    $0x1f,%eax
  801c97:	29 d0                	sub    %edx,%eax
  801c99:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ca1:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ca4:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ca7:	83 c3 01             	add    $0x1,%ebx
  801caa:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cad:	75 d8                	jne    801c87 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801caf:	8b 45 10             	mov    0x10(%ebp),%eax
  801cb2:	eb 05                	jmp    801cb9 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cb4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cbc:	5b                   	pop    %ebx
  801cbd:	5e                   	pop    %esi
  801cbe:	5f                   	pop    %edi
  801cbf:	5d                   	pop    %ebp
  801cc0:	c3                   	ret    

00801cc1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cc1:	55                   	push   %ebp
  801cc2:	89 e5                	mov    %esp,%ebp
  801cc4:	56                   	push   %esi
  801cc5:	53                   	push   %ebx
  801cc6:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cc9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ccc:	50                   	push   %eax
  801ccd:	e8 20 f6 ff ff       	call   8012f2 <fd_alloc>
  801cd2:	83 c4 10             	add    $0x10,%esp
  801cd5:	89 c2                	mov    %eax,%edx
  801cd7:	85 c0                	test   %eax,%eax
  801cd9:	0f 88 2c 01 00 00    	js     801e0b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cdf:	83 ec 04             	sub    $0x4,%esp
  801ce2:	68 07 04 00 00       	push   $0x407
  801ce7:	ff 75 f4             	pushl  -0xc(%ebp)
  801cea:	6a 00                	push   $0x0
  801cec:	e8 0d ee ff ff       	call   800afe <sys_page_alloc>
  801cf1:	83 c4 10             	add    $0x10,%esp
  801cf4:	89 c2                	mov    %eax,%edx
  801cf6:	85 c0                	test   %eax,%eax
  801cf8:	0f 88 0d 01 00 00    	js     801e0b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cfe:	83 ec 0c             	sub    $0xc,%esp
  801d01:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d04:	50                   	push   %eax
  801d05:	e8 e8 f5 ff ff       	call   8012f2 <fd_alloc>
  801d0a:	89 c3                	mov    %eax,%ebx
  801d0c:	83 c4 10             	add    $0x10,%esp
  801d0f:	85 c0                	test   %eax,%eax
  801d11:	0f 88 e2 00 00 00    	js     801df9 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d17:	83 ec 04             	sub    $0x4,%esp
  801d1a:	68 07 04 00 00       	push   $0x407
  801d1f:	ff 75 f0             	pushl  -0x10(%ebp)
  801d22:	6a 00                	push   $0x0
  801d24:	e8 d5 ed ff ff       	call   800afe <sys_page_alloc>
  801d29:	89 c3                	mov    %eax,%ebx
  801d2b:	83 c4 10             	add    $0x10,%esp
  801d2e:	85 c0                	test   %eax,%eax
  801d30:	0f 88 c3 00 00 00    	js     801df9 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d36:	83 ec 0c             	sub    $0xc,%esp
  801d39:	ff 75 f4             	pushl  -0xc(%ebp)
  801d3c:	e8 9a f5 ff ff       	call   8012db <fd2data>
  801d41:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d43:	83 c4 0c             	add    $0xc,%esp
  801d46:	68 07 04 00 00       	push   $0x407
  801d4b:	50                   	push   %eax
  801d4c:	6a 00                	push   $0x0
  801d4e:	e8 ab ed ff ff       	call   800afe <sys_page_alloc>
  801d53:	89 c3                	mov    %eax,%ebx
  801d55:	83 c4 10             	add    $0x10,%esp
  801d58:	85 c0                	test   %eax,%eax
  801d5a:	0f 88 89 00 00 00    	js     801de9 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d60:	83 ec 0c             	sub    $0xc,%esp
  801d63:	ff 75 f0             	pushl  -0x10(%ebp)
  801d66:	e8 70 f5 ff ff       	call   8012db <fd2data>
  801d6b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d72:	50                   	push   %eax
  801d73:	6a 00                	push   $0x0
  801d75:	56                   	push   %esi
  801d76:	6a 00                	push   $0x0
  801d78:	e8 c4 ed ff ff       	call   800b41 <sys_page_map>
  801d7d:	89 c3                	mov    %eax,%ebx
  801d7f:	83 c4 20             	add    $0x20,%esp
  801d82:	85 c0                	test   %eax,%eax
  801d84:	78 55                	js     801ddb <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d86:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d8f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d91:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d94:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d9b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801da1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801da4:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801da6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801da9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801db0:	83 ec 0c             	sub    $0xc,%esp
  801db3:	ff 75 f4             	pushl  -0xc(%ebp)
  801db6:	e8 10 f5 ff ff       	call   8012cb <fd2num>
  801dbb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dbe:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dc0:	83 c4 04             	add    $0x4,%esp
  801dc3:	ff 75 f0             	pushl  -0x10(%ebp)
  801dc6:	e8 00 f5 ff ff       	call   8012cb <fd2num>
  801dcb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dce:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801dd1:	83 c4 10             	add    $0x10,%esp
  801dd4:	ba 00 00 00 00       	mov    $0x0,%edx
  801dd9:	eb 30                	jmp    801e0b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ddb:	83 ec 08             	sub    $0x8,%esp
  801dde:	56                   	push   %esi
  801ddf:	6a 00                	push   $0x0
  801de1:	e8 9d ed ff ff       	call   800b83 <sys_page_unmap>
  801de6:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801de9:	83 ec 08             	sub    $0x8,%esp
  801dec:	ff 75 f0             	pushl  -0x10(%ebp)
  801def:	6a 00                	push   $0x0
  801df1:	e8 8d ed ff ff       	call   800b83 <sys_page_unmap>
  801df6:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801df9:	83 ec 08             	sub    $0x8,%esp
  801dfc:	ff 75 f4             	pushl  -0xc(%ebp)
  801dff:	6a 00                	push   $0x0
  801e01:	e8 7d ed ff ff       	call   800b83 <sys_page_unmap>
  801e06:	83 c4 10             	add    $0x10,%esp
  801e09:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e0b:	89 d0                	mov    %edx,%eax
  801e0d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e10:	5b                   	pop    %ebx
  801e11:	5e                   	pop    %esi
  801e12:	5d                   	pop    %ebp
  801e13:	c3                   	ret    

00801e14 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e14:	55                   	push   %ebp
  801e15:	89 e5                	mov    %esp,%ebp
  801e17:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e1a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e1d:	50                   	push   %eax
  801e1e:	ff 75 08             	pushl  0x8(%ebp)
  801e21:	e8 1b f5 ff ff       	call   801341 <fd_lookup>
  801e26:	83 c4 10             	add    $0x10,%esp
  801e29:	85 c0                	test   %eax,%eax
  801e2b:	78 18                	js     801e45 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e2d:	83 ec 0c             	sub    $0xc,%esp
  801e30:	ff 75 f4             	pushl  -0xc(%ebp)
  801e33:	e8 a3 f4 ff ff       	call   8012db <fd2data>
	return _pipeisclosed(fd, p);
  801e38:	89 c2                	mov    %eax,%edx
  801e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e3d:	e8 18 fd ff ff       	call   801b5a <_pipeisclosed>
  801e42:	83 c4 10             	add    $0x10,%esp
}
  801e45:	c9                   	leave  
  801e46:	c3                   	ret    

00801e47 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e47:	55                   	push   %ebp
  801e48:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e4a:	b8 00 00 00 00       	mov    $0x0,%eax
  801e4f:	5d                   	pop    %ebp
  801e50:	c3                   	ret    

00801e51 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e51:	55                   	push   %ebp
  801e52:	89 e5                	mov    %esp,%ebp
  801e54:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e57:	68 26 2a 80 00       	push   $0x802a26
  801e5c:	ff 75 0c             	pushl  0xc(%ebp)
  801e5f:	e8 97 e8 ff ff       	call   8006fb <strcpy>
	return 0;
}
  801e64:	b8 00 00 00 00       	mov    $0x0,%eax
  801e69:	c9                   	leave  
  801e6a:	c3                   	ret    

00801e6b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e6b:	55                   	push   %ebp
  801e6c:	89 e5                	mov    %esp,%ebp
  801e6e:	57                   	push   %edi
  801e6f:	56                   	push   %esi
  801e70:	53                   	push   %ebx
  801e71:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e77:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e7c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e82:	eb 2d                	jmp    801eb1 <devcons_write+0x46>
		m = n - tot;
  801e84:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e87:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e89:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e8c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e91:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e94:	83 ec 04             	sub    $0x4,%esp
  801e97:	53                   	push   %ebx
  801e98:	03 45 0c             	add    0xc(%ebp),%eax
  801e9b:	50                   	push   %eax
  801e9c:	57                   	push   %edi
  801e9d:	e8 eb e9 ff ff       	call   80088d <memmove>
		sys_cputs(buf, m);
  801ea2:	83 c4 08             	add    $0x8,%esp
  801ea5:	53                   	push   %ebx
  801ea6:	57                   	push   %edi
  801ea7:	e8 96 eb ff ff       	call   800a42 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eac:	01 de                	add    %ebx,%esi
  801eae:	83 c4 10             	add    $0x10,%esp
  801eb1:	89 f0                	mov    %esi,%eax
  801eb3:	3b 75 10             	cmp    0x10(%ebp),%esi
  801eb6:	72 cc                	jb     801e84 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801eb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ebb:	5b                   	pop    %ebx
  801ebc:	5e                   	pop    %esi
  801ebd:	5f                   	pop    %edi
  801ebe:	5d                   	pop    %ebp
  801ebf:	c3                   	ret    

00801ec0 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ec0:	55                   	push   %ebp
  801ec1:	89 e5                	mov    %esp,%ebp
  801ec3:	83 ec 08             	sub    $0x8,%esp
  801ec6:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ecb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ecf:	74 2a                	je     801efb <devcons_read+0x3b>
  801ed1:	eb 05                	jmp    801ed8 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ed3:	e8 07 ec ff ff       	call   800adf <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ed8:	e8 83 eb ff ff       	call   800a60 <sys_cgetc>
  801edd:	85 c0                	test   %eax,%eax
  801edf:	74 f2                	je     801ed3 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ee1:	85 c0                	test   %eax,%eax
  801ee3:	78 16                	js     801efb <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ee5:	83 f8 04             	cmp    $0x4,%eax
  801ee8:	74 0c                	je     801ef6 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801eea:	8b 55 0c             	mov    0xc(%ebp),%edx
  801eed:	88 02                	mov    %al,(%edx)
	return 1;
  801eef:	b8 01 00 00 00       	mov    $0x1,%eax
  801ef4:	eb 05                	jmp    801efb <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ef6:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801efb:	c9                   	leave  
  801efc:	c3                   	ret    

00801efd <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801efd:	55                   	push   %ebp
  801efe:	89 e5                	mov    %esp,%ebp
  801f00:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f03:	8b 45 08             	mov    0x8(%ebp),%eax
  801f06:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f09:	6a 01                	push   $0x1
  801f0b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f0e:	50                   	push   %eax
  801f0f:	e8 2e eb ff ff       	call   800a42 <sys_cputs>
}
  801f14:	83 c4 10             	add    $0x10,%esp
  801f17:	c9                   	leave  
  801f18:	c3                   	ret    

00801f19 <getchar>:

int
getchar(void)
{
  801f19:	55                   	push   %ebp
  801f1a:	89 e5                	mov    %esp,%ebp
  801f1c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f1f:	6a 01                	push   $0x1
  801f21:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f24:	50                   	push   %eax
  801f25:	6a 00                	push   $0x0
  801f27:	e8 7e f6 ff ff       	call   8015aa <read>
	if (r < 0)
  801f2c:	83 c4 10             	add    $0x10,%esp
  801f2f:	85 c0                	test   %eax,%eax
  801f31:	78 0f                	js     801f42 <getchar+0x29>
		return r;
	if (r < 1)
  801f33:	85 c0                	test   %eax,%eax
  801f35:	7e 06                	jle    801f3d <getchar+0x24>
		return -E_EOF;
	return c;
  801f37:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f3b:	eb 05                	jmp    801f42 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f3d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f42:	c9                   	leave  
  801f43:	c3                   	ret    

00801f44 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f44:	55                   	push   %ebp
  801f45:	89 e5                	mov    %esp,%ebp
  801f47:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f4a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f4d:	50                   	push   %eax
  801f4e:	ff 75 08             	pushl  0x8(%ebp)
  801f51:	e8 eb f3 ff ff       	call   801341 <fd_lookup>
  801f56:	83 c4 10             	add    $0x10,%esp
  801f59:	85 c0                	test   %eax,%eax
  801f5b:	78 11                	js     801f6e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f60:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f66:	39 10                	cmp    %edx,(%eax)
  801f68:	0f 94 c0             	sete   %al
  801f6b:	0f b6 c0             	movzbl %al,%eax
}
  801f6e:	c9                   	leave  
  801f6f:	c3                   	ret    

00801f70 <opencons>:

int
opencons(void)
{
  801f70:	55                   	push   %ebp
  801f71:	89 e5                	mov    %esp,%ebp
  801f73:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f76:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f79:	50                   	push   %eax
  801f7a:	e8 73 f3 ff ff       	call   8012f2 <fd_alloc>
  801f7f:	83 c4 10             	add    $0x10,%esp
		return r;
  801f82:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f84:	85 c0                	test   %eax,%eax
  801f86:	78 3e                	js     801fc6 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f88:	83 ec 04             	sub    $0x4,%esp
  801f8b:	68 07 04 00 00       	push   $0x407
  801f90:	ff 75 f4             	pushl  -0xc(%ebp)
  801f93:	6a 00                	push   $0x0
  801f95:	e8 64 eb ff ff       	call   800afe <sys_page_alloc>
  801f9a:	83 c4 10             	add    $0x10,%esp
		return r;
  801f9d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f9f:	85 c0                	test   %eax,%eax
  801fa1:	78 23                	js     801fc6 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fa3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fac:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fb8:	83 ec 0c             	sub    $0xc,%esp
  801fbb:	50                   	push   %eax
  801fbc:	e8 0a f3 ff ff       	call   8012cb <fd2num>
  801fc1:	89 c2                	mov    %eax,%edx
  801fc3:	83 c4 10             	add    $0x10,%esp
}
  801fc6:	89 d0                	mov    %edx,%eax
  801fc8:	c9                   	leave  
  801fc9:	c3                   	ret    

00801fca <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801fca:	55                   	push   %ebp
  801fcb:	89 e5                	mov    %esp,%ebp
  801fcd:	56                   	push   %esi
  801fce:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801fcf:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801fd2:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801fd8:	e8 e3 ea ff ff       	call   800ac0 <sys_getenvid>
  801fdd:	83 ec 0c             	sub    $0xc,%esp
  801fe0:	ff 75 0c             	pushl  0xc(%ebp)
  801fe3:	ff 75 08             	pushl  0x8(%ebp)
  801fe6:	56                   	push   %esi
  801fe7:	50                   	push   %eax
  801fe8:	68 34 2a 80 00       	push   $0x802a34
  801fed:	e8 84 e1 ff ff       	call   800176 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ff2:	83 c4 18             	add    $0x18,%esp
  801ff5:	53                   	push   %ebx
  801ff6:	ff 75 10             	pushl  0x10(%ebp)
  801ff9:	e8 27 e1 ff ff       	call   800125 <vcprintf>
	cprintf("\n");
  801ffe:	c7 04 24 ac 24 80 00 	movl   $0x8024ac,(%esp)
  802005:	e8 6c e1 ff ff       	call   800176 <cprintf>
  80200a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80200d:	cc                   	int3   
  80200e:	eb fd                	jmp    80200d <_panic+0x43>

00802010 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802010:	55                   	push   %ebp
  802011:	89 e5                	mov    %esp,%ebp
  802013:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802016:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80201d:	75 2a                	jne    802049 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  80201f:	83 ec 04             	sub    $0x4,%esp
  802022:	6a 07                	push   $0x7
  802024:	68 00 f0 bf ee       	push   $0xeebff000
  802029:	6a 00                	push   $0x0
  80202b:	e8 ce ea ff ff       	call   800afe <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802030:	83 c4 10             	add    $0x10,%esp
  802033:	85 c0                	test   %eax,%eax
  802035:	79 12                	jns    802049 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802037:	50                   	push   %eax
  802038:	68 b8 28 80 00       	push   $0x8028b8
  80203d:	6a 23                	push   $0x23
  80203f:	68 58 2a 80 00       	push   $0x802a58
  802044:	e8 81 ff ff ff       	call   801fca <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802049:	8b 45 08             	mov    0x8(%ebp),%eax
  80204c:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802051:	83 ec 08             	sub    $0x8,%esp
  802054:	68 7b 20 80 00       	push   $0x80207b
  802059:	6a 00                	push   $0x0
  80205b:	e8 e9 eb ff ff       	call   800c49 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802060:	83 c4 10             	add    $0x10,%esp
  802063:	85 c0                	test   %eax,%eax
  802065:	79 12                	jns    802079 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802067:	50                   	push   %eax
  802068:	68 b8 28 80 00       	push   $0x8028b8
  80206d:	6a 2c                	push   $0x2c
  80206f:	68 58 2a 80 00       	push   $0x802a58
  802074:	e8 51 ff ff ff       	call   801fca <_panic>
	}
}
  802079:	c9                   	leave  
  80207a:	c3                   	ret    

0080207b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80207b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80207c:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802081:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802083:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802086:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  80208a:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  80208f:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802093:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802095:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802098:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802099:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80209c:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  80209d:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80209e:	c3                   	ret    

0080209f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80209f:	55                   	push   %ebp
  8020a0:	89 e5                	mov    %esp,%ebp
  8020a2:	56                   	push   %esi
  8020a3:	53                   	push   %ebx
  8020a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8020a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8020ad:	85 c0                	test   %eax,%eax
  8020af:	75 12                	jne    8020c3 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8020b1:	83 ec 0c             	sub    $0xc,%esp
  8020b4:	68 00 00 c0 ee       	push   $0xeec00000
  8020b9:	e8 f0 eb ff ff       	call   800cae <sys_ipc_recv>
  8020be:	83 c4 10             	add    $0x10,%esp
  8020c1:	eb 0c                	jmp    8020cf <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8020c3:	83 ec 0c             	sub    $0xc,%esp
  8020c6:	50                   	push   %eax
  8020c7:	e8 e2 eb ff ff       	call   800cae <sys_ipc_recv>
  8020cc:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8020cf:	85 f6                	test   %esi,%esi
  8020d1:	0f 95 c1             	setne  %cl
  8020d4:	85 db                	test   %ebx,%ebx
  8020d6:	0f 95 c2             	setne  %dl
  8020d9:	84 d1                	test   %dl,%cl
  8020db:	74 09                	je     8020e6 <ipc_recv+0x47>
  8020dd:	89 c2                	mov    %eax,%edx
  8020df:	c1 ea 1f             	shr    $0x1f,%edx
  8020e2:	84 d2                	test   %dl,%dl
  8020e4:	75 2d                	jne    802113 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8020e6:	85 f6                	test   %esi,%esi
  8020e8:	74 0d                	je     8020f7 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8020ea:	a1 08 40 80 00       	mov    0x804008,%eax
  8020ef:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8020f5:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8020f7:	85 db                	test   %ebx,%ebx
  8020f9:	74 0d                	je     802108 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8020fb:	a1 08 40 80 00       	mov    0x804008,%eax
  802100:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  802106:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802108:	a1 08 40 80 00       	mov    0x804008,%eax
  80210d:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  802113:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802116:	5b                   	pop    %ebx
  802117:	5e                   	pop    %esi
  802118:	5d                   	pop    %ebp
  802119:	c3                   	ret    

0080211a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80211a:	55                   	push   %ebp
  80211b:	89 e5                	mov    %esp,%ebp
  80211d:	57                   	push   %edi
  80211e:	56                   	push   %esi
  80211f:	53                   	push   %ebx
  802120:	83 ec 0c             	sub    $0xc,%esp
  802123:	8b 7d 08             	mov    0x8(%ebp),%edi
  802126:	8b 75 0c             	mov    0xc(%ebp),%esi
  802129:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80212c:	85 db                	test   %ebx,%ebx
  80212e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802133:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802136:	ff 75 14             	pushl  0x14(%ebp)
  802139:	53                   	push   %ebx
  80213a:	56                   	push   %esi
  80213b:	57                   	push   %edi
  80213c:	e8 4a eb ff ff       	call   800c8b <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802141:	89 c2                	mov    %eax,%edx
  802143:	c1 ea 1f             	shr    $0x1f,%edx
  802146:	83 c4 10             	add    $0x10,%esp
  802149:	84 d2                	test   %dl,%dl
  80214b:	74 17                	je     802164 <ipc_send+0x4a>
  80214d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802150:	74 12                	je     802164 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802152:	50                   	push   %eax
  802153:	68 66 2a 80 00       	push   $0x802a66
  802158:	6a 47                	push   $0x47
  80215a:	68 74 2a 80 00       	push   $0x802a74
  80215f:	e8 66 fe ff ff       	call   801fca <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802164:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802167:	75 07                	jne    802170 <ipc_send+0x56>
			sys_yield();
  802169:	e8 71 e9 ff ff       	call   800adf <sys_yield>
  80216e:	eb c6                	jmp    802136 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802170:	85 c0                	test   %eax,%eax
  802172:	75 c2                	jne    802136 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802174:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802177:	5b                   	pop    %ebx
  802178:	5e                   	pop    %esi
  802179:	5f                   	pop    %edi
  80217a:	5d                   	pop    %ebp
  80217b:	c3                   	ret    

0080217c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80217c:	55                   	push   %ebp
  80217d:	89 e5                	mov    %esp,%ebp
  80217f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802182:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802187:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  80218d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802193:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  802199:	39 ca                	cmp    %ecx,%edx
  80219b:	75 13                	jne    8021b0 <ipc_find_env+0x34>
			return envs[i].env_id;
  80219d:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8021a3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021a8:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8021ae:	eb 0f                	jmp    8021bf <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021b0:	83 c0 01             	add    $0x1,%eax
  8021b3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021b8:	75 cd                	jne    802187 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021bf:	5d                   	pop    %ebp
  8021c0:	c3                   	ret    

008021c1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021c1:	55                   	push   %ebp
  8021c2:	89 e5                	mov    %esp,%ebp
  8021c4:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021c7:	89 d0                	mov    %edx,%eax
  8021c9:	c1 e8 16             	shr    $0x16,%eax
  8021cc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021d3:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021d8:	f6 c1 01             	test   $0x1,%cl
  8021db:	74 1d                	je     8021fa <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021dd:	c1 ea 0c             	shr    $0xc,%edx
  8021e0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021e7:	f6 c2 01             	test   $0x1,%dl
  8021ea:	74 0e                	je     8021fa <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021ec:	c1 ea 0c             	shr    $0xc,%edx
  8021ef:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021f6:	ef 
  8021f7:	0f b7 c0             	movzwl %ax,%eax
}
  8021fa:	5d                   	pop    %ebp
  8021fb:	c3                   	ret    
  8021fc:	66 90                	xchg   %ax,%ax
  8021fe:	66 90                	xchg   %ax,%ax

00802200 <__udivdi3>:
  802200:	55                   	push   %ebp
  802201:	57                   	push   %edi
  802202:	56                   	push   %esi
  802203:	53                   	push   %ebx
  802204:	83 ec 1c             	sub    $0x1c,%esp
  802207:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80220b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80220f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802213:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802217:	85 f6                	test   %esi,%esi
  802219:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80221d:	89 ca                	mov    %ecx,%edx
  80221f:	89 f8                	mov    %edi,%eax
  802221:	75 3d                	jne    802260 <__udivdi3+0x60>
  802223:	39 cf                	cmp    %ecx,%edi
  802225:	0f 87 c5 00 00 00    	ja     8022f0 <__udivdi3+0xf0>
  80222b:	85 ff                	test   %edi,%edi
  80222d:	89 fd                	mov    %edi,%ebp
  80222f:	75 0b                	jne    80223c <__udivdi3+0x3c>
  802231:	b8 01 00 00 00       	mov    $0x1,%eax
  802236:	31 d2                	xor    %edx,%edx
  802238:	f7 f7                	div    %edi
  80223a:	89 c5                	mov    %eax,%ebp
  80223c:	89 c8                	mov    %ecx,%eax
  80223e:	31 d2                	xor    %edx,%edx
  802240:	f7 f5                	div    %ebp
  802242:	89 c1                	mov    %eax,%ecx
  802244:	89 d8                	mov    %ebx,%eax
  802246:	89 cf                	mov    %ecx,%edi
  802248:	f7 f5                	div    %ebp
  80224a:	89 c3                	mov    %eax,%ebx
  80224c:	89 d8                	mov    %ebx,%eax
  80224e:	89 fa                	mov    %edi,%edx
  802250:	83 c4 1c             	add    $0x1c,%esp
  802253:	5b                   	pop    %ebx
  802254:	5e                   	pop    %esi
  802255:	5f                   	pop    %edi
  802256:	5d                   	pop    %ebp
  802257:	c3                   	ret    
  802258:	90                   	nop
  802259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802260:	39 ce                	cmp    %ecx,%esi
  802262:	77 74                	ja     8022d8 <__udivdi3+0xd8>
  802264:	0f bd fe             	bsr    %esi,%edi
  802267:	83 f7 1f             	xor    $0x1f,%edi
  80226a:	0f 84 98 00 00 00    	je     802308 <__udivdi3+0x108>
  802270:	bb 20 00 00 00       	mov    $0x20,%ebx
  802275:	89 f9                	mov    %edi,%ecx
  802277:	89 c5                	mov    %eax,%ebp
  802279:	29 fb                	sub    %edi,%ebx
  80227b:	d3 e6                	shl    %cl,%esi
  80227d:	89 d9                	mov    %ebx,%ecx
  80227f:	d3 ed                	shr    %cl,%ebp
  802281:	89 f9                	mov    %edi,%ecx
  802283:	d3 e0                	shl    %cl,%eax
  802285:	09 ee                	or     %ebp,%esi
  802287:	89 d9                	mov    %ebx,%ecx
  802289:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80228d:	89 d5                	mov    %edx,%ebp
  80228f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802293:	d3 ed                	shr    %cl,%ebp
  802295:	89 f9                	mov    %edi,%ecx
  802297:	d3 e2                	shl    %cl,%edx
  802299:	89 d9                	mov    %ebx,%ecx
  80229b:	d3 e8                	shr    %cl,%eax
  80229d:	09 c2                	or     %eax,%edx
  80229f:	89 d0                	mov    %edx,%eax
  8022a1:	89 ea                	mov    %ebp,%edx
  8022a3:	f7 f6                	div    %esi
  8022a5:	89 d5                	mov    %edx,%ebp
  8022a7:	89 c3                	mov    %eax,%ebx
  8022a9:	f7 64 24 0c          	mull   0xc(%esp)
  8022ad:	39 d5                	cmp    %edx,%ebp
  8022af:	72 10                	jb     8022c1 <__udivdi3+0xc1>
  8022b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8022b5:	89 f9                	mov    %edi,%ecx
  8022b7:	d3 e6                	shl    %cl,%esi
  8022b9:	39 c6                	cmp    %eax,%esi
  8022bb:	73 07                	jae    8022c4 <__udivdi3+0xc4>
  8022bd:	39 d5                	cmp    %edx,%ebp
  8022bf:	75 03                	jne    8022c4 <__udivdi3+0xc4>
  8022c1:	83 eb 01             	sub    $0x1,%ebx
  8022c4:	31 ff                	xor    %edi,%edi
  8022c6:	89 d8                	mov    %ebx,%eax
  8022c8:	89 fa                	mov    %edi,%edx
  8022ca:	83 c4 1c             	add    $0x1c,%esp
  8022cd:	5b                   	pop    %ebx
  8022ce:	5e                   	pop    %esi
  8022cf:	5f                   	pop    %edi
  8022d0:	5d                   	pop    %ebp
  8022d1:	c3                   	ret    
  8022d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022d8:	31 ff                	xor    %edi,%edi
  8022da:	31 db                	xor    %ebx,%ebx
  8022dc:	89 d8                	mov    %ebx,%eax
  8022de:	89 fa                	mov    %edi,%edx
  8022e0:	83 c4 1c             	add    $0x1c,%esp
  8022e3:	5b                   	pop    %ebx
  8022e4:	5e                   	pop    %esi
  8022e5:	5f                   	pop    %edi
  8022e6:	5d                   	pop    %ebp
  8022e7:	c3                   	ret    
  8022e8:	90                   	nop
  8022e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022f0:	89 d8                	mov    %ebx,%eax
  8022f2:	f7 f7                	div    %edi
  8022f4:	31 ff                	xor    %edi,%edi
  8022f6:	89 c3                	mov    %eax,%ebx
  8022f8:	89 d8                	mov    %ebx,%eax
  8022fa:	89 fa                	mov    %edi,%edx
  8022fc:	83 c4 1c             	add    $0x1c,%esp
  8022ff:	5b                   	pop    %ebx
  802300:	5e                   	pop    %esi
  802301:	5f                   	pop    %edi
  802302:	5d                   	pop    %ebp
  802303:	c3                   	ret    
  802304:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802308:	39 ce                	cmp    %ecx,%esi
  80230a:	72 0c                	jb     802318 <__udivdi3+0x118>
  80230c:	31 db                	xor    %ebx,%ebx
  80230e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802312:	0f 87 34 ff ff ff    	ja     80224c <__udivdi3+0x4c>
  802318:	bb 01 00 00 00       	mov    $0x1,%ebx
  80231d:	e9 2a ff ff ff       	jmp    80224c <__udivdi3+0x4c>
  802322:	66 90                	xchg   %ax,%ax
  802324:	66 90                	xchg   %ax,%ax
  802326:	66 90                	xchg   %ax,%ax
  802328:	66 90                	xchg   %ax,%ax
  80232a:	66 90                	xchg   %ax,%ax
  80232c:	66 90                	xchg   %ax,%ax
  80232e:	66 90                	xchg   %ax,%ax

00802330 <__umoddi3>:
  802330:	55                   	push   %ebp
  802331:	57                   	push   %edi
  802332:	56                   	push   %esi
  802333:	53                   	push   %ebx
  802334:	83 ec 1c             	sub    $0x1c,%esp
  802337:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80233b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80233f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802343:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802347:	85 d2                	test   %edx,%edx
  802349:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80234d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802351:	89 f3                	mov    %esi,%ebx
  802353:	89 3c 24             	mov    %edi,(%esp)
  802356:	89 74 24 04          	mov    %esi,0x4(%esp)
  80235a:	75 1c                	jne    802378 <__umoddi3+0x48>
  80235c:	39 f7                	cmp    %esi,%edi
  80235e:	76 50                	jbe    8023b0 <__umoddi3+0x80>
  802360:	89 c8                	mov    %ecx,%eax
  802362:	89 f2                	mov    %esi,%edx
  802364:	f7 f7                	div    %edi
  802366:	89 d0                	mov    %edx,%eax
  802368:	31 d2                	xor    %edx,%edx
  80236a:	83 c4 1c             	add    $0x1c,%esp
  80236d:	5b                   	pop    %ebx
  80236e:	5e                   	pop    %esi
  80236f:	5f                   	pop    %edi
  802370:	5d                   	pop    %ebp
  802371:	c3                   	ret    
  802372:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802378:	39 f2                	cmp    %esi,%edx
  80237a:	89 d0                	mov    %edx,%eax
  80237c:	77 52                	ja     8023d0 <__umoddi3+0xa0>
  80237e:	0f bd ea             	bsr    %edx,%ebp
  802381:	83 f5 1f             	xor    $0x1f,%ebp
  802384:	75 5a                	jne    8023e0 <__umoddi3+0xb0>
  802386:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80238a:	0f 82 e0 00 00 00    	jb     802470 <__umoddi3+0x140>
  802390:	39 0c 24             	cmp    %ecx,(%esp)
  802393:	0f 86 d7 00 00 00    	jbe    802470 <__umoddi3+0x140>
  802399:	8b 44 24 08          	mov    0x8(%esp),%eax
  80239d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023a1:	83 c4 1c             	add    $0x1c,%esp
  8023a4:	5b                   	pop    %ebx
  8023a5:	5e                   	pop    %esi
  8023a6:	5f                   	pop    %edi
  8023a7:	5d                   	pop    %ebp
  8023a8:	c3                   	ret    
  8023a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023b0:	85 ff                	test   %edi,%edi
  8023b2:	89 fd                	mov    %edi,%ebp
  8023b4:	75 0b                	jne    8023c1 <__umoddi3+0x91>
  8023b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023bb:	31 d2                	xor    %edx,%edx
  8023bd:	f7 f7                	div    %edi
  8023bf:	89 c5                	mov    %eax,%ebp
  8023c1:	89 f0                	mov    %esi,%eax
  8023c3:	31 d2                	xor    %edx,%edx
  8023c5:	f7 f5                	div    %ebp
  8023c7:	89 c8                	mov    %ecx,%eax
  8023c9:	f7 f5                	div    %ebp
  8023cb:	89 d0                	mov    %edx,%eax
  8023cd:	eb 99                	jmp    802368 <__umoddi3+0x38>
  8023cf:	90                   	nop
  8023d0:	89 c8                	mov    %ecx,%eax
  8023d2:	89 f2                	mov    %esi,%edx
  8023d4:	83 c4 1c             	add    $0x1c,%esp
  8023d7:	5b                   	pop    %ebx
  8023d8:	5e                   	pop    %esi
  8023d9:	5f                   	pop    %edi
  8023da:	5d                   	pop    %ebp
  8023db:	c3                   	ret    
  8023dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023e0:	8b 34 24             	mov    (%esp),%esi
  8023e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023e8:	89 e9                	mov    %ebp,%ecx
  8023ea:	29 ef                	sub    %ebp,%edi
  8023ec:	d3 e0                	shl    %cl,%eax
  8023ee:	89 f9                	mov    %edi,%ecx
  8023f0:	89 f2                	mov    %esi,%edx
  8023f2:	d3 ea                	shr    %cl,%edx
  8023f4:	89 e9                	mov    %ebp,%ecx
  8023f6:	09 c2                	or     %eax,%edx
  8023f8:	89 d8                	mov    %ebx,%eax
  8023fa:	89 14 24             	mov    %edx,(%esp)
  8023fd:	89 f2                	mov    %esi,%edx
  8023ff:	d3 e2                	shl    %cl,%edx
  802401:	89 f9                	mov    %edi,%ecx
  802403:	89 54 24 04          	mov    %edx,0x4(%esp)
  802407:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80240b:	d3 e8                	shr    %cl,%eax
  80240d:	89 e9                	mov    %ebp,%ecx
  80240f:	89 c6                	mov    %eax,%esi
  802411:	d3 e3                	shl    %cl,%ebx
  802413:	89 f9                	mov    %edi,%ecx
  802415:	89 d0                	mov    %edx,%eax
  802417:	d3 e8                	shr    %cl,%eax
  802419:	89 e9                	mov    %ebp,%ecx
  80241b:	09 d8                	or     %ebx,%eax
  80241d:	89 d3                	mov    %edx,%ebx
  80241f:	89 f2                	mov    %esi,%edx
  802421:	f7 34 24             	divl   (%esp)
  802424:	89 d6                	mov    %edx,%esi
  802426:	d3 e3                	shl    %cl,%ebx
  802428:	f7 64 24 04          	mull   0x4(%esp)
  80242c:	39 d6                	cmp    %edx,%esi
  80242e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802432:	89 d1                	mov    %edx,%ecx
  802434:	89 c3                	mov    %eax,%ebx
  802436:	72 08                	jb     802440 <__umoddi3+0x110>
  802438:	75 11                	jne    80244b <__umoddi3+0x11b>
  80243a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80243e:	73 0b                	jae    80244b <__umoddi3+0x11b>
  802440:	2b 44 24 04          	sub    0x4(%esp),%eax
  802444:	1b 14 24             	sbb    (%esp),%edx
  802447:	89 d1                	mov    %edx,%ecx
  802449:	89 c3                	mov    %eax,%ebx
  80244b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80244f:	29 da                	sub    %ebx,%edx
  802451:	19 ce                	sbb    %ecx,%esi
  802453:	89 f9                	mov    %edi,%ecx
  802455:	89 f0                	mov    %esi,%eax
  802457:	d3 e0                	shl    %cl,%eax
  802459:	89 e9                	mov    %ebp,%ecx
  80245b:	d3 ea                	shr    %cl,%edx
  80245d:	89 e9                	mov    %ebp,%ecx
  80245f:	d3 ee                	shr    %cl,%esi
  802461:	09 d0                	or     %edx,%eax
  802463:	89 f2                	mov    %esi,%edx
  802465:	83 c4 1c             	add    $0x1c,%esp
  802468:	5b                   	pop    %ebx
  802469:	5e                   	pop    %esi
  80246a:	5f                   	pop    %edi
  80246b:	5d                   	pop    %ebp
  80246c:	c3                   	ret    
  80246d:	8d 76 00             	lea    0x0(%esi),%esi
  802470:	29 f9                	sub    %edi,%ecx
  802472:	19 d6                	sbb    %edx,%esi
  802474:	89 74 24 04          	mov    %esi,0x4(%esp)
  802478:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80247c:	e9 18 ff ff ff       	jmp    802399 <__umoddi3+0x69>
