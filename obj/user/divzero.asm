
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
  800051:	68 e0 21 80 00       	push   $0x8021e0
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
  800075:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
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
  8000cf:	e8 1a 11 00 00       	call   8011ee <close_all>
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
  8001d9:	e8 72 1d 00 00       	call   801f50 <__udivdi3>
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
  80021c:	e8 5f 1e 00 00       	call   802080 <__umoddi3>
  800221:	83 c4 14             	add    $0x14,%esp
  800224:	0f be 80 f8 21 80 00 	movsbl 0x8021f8(%eax),%eax
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
  800320:	ff 24 85 40 23 80 00 	jmp    *0x802340(,%eax,4)
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
  8003e4:	8b 14 85 a0 24 80 00 	mov    0x8024a0(,%eax,4),%edx
  8003eb:	85 d2                	test   %edx,%edx
  8003ed:	75 18                	jne    800407 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003ef:	50                   	push   %eax
  8003f0:	68 10 22 80 00       	push   $0x802210
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
  800408:	68 4d 26 80 00       	push   $0x80264d
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
  80042c:	b8 09 22 80 00       	mov    $0x802209,%eax
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
  800aa7:	68 ff 24 80 00       	push   $0x8024ff
  800aac:	6a 23                	push   $0x23
  800aae:	68 1c 25 80 00       	push   $0x80251c
  800ab3:	e8 5e 12 00 00       	call   801d16 <_panic>

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
  800b28:	68 ff 24 80 00       	push   $0x8024ff
  800b2d:	6a 23                	push   $0x23
  800b2f:	68 1c 25 80 00       	push   $0x80251c
  800b34:	e8 dd 11 00 00       	call   801d16 <_panic>

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
  800b6a:	68 ff 24 80 00       	push   $0x8024ff
  800b6f:	6a 23                	push   $0x23
  800b71:	68 1c 25 80 00       	push   $0x80251c
  800b76:	e8 9b 11 00 00       	call   801d16 <_panic>

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
  800bac:	68 ff 24 80 00       	push   $0x8024ff
  800bb1:	6a 23                	push   $0x23
  800bb3:	68 1c 25 80 00       	push   $0x80251c
  800bb8:	e8 59 11 00 00       	call   801d16 <_panic>

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
  800bee:	68 ff 24 80 00       	push   $0x8024ff
  800bf3:	6a 23                	push   $0x23
  800bf5:	68 1c 25 80 00       	push   $0x80251c
  800bfa:	e8 17 11 00 00       	call   801d16 <_panic>

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
  800c30:	68 ff 24 80 00       	push   $0x8024ff
  800c35:	6a 23                	push   $0x23
  800c37:	68 1c 25 80 00       	push   $0x80251c
  800c3c:	e8 d5 10 00 00       	call   801d16 <_panic>
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
  800c72:	68 ff 24 80 00       	push   $0x8024ff
  800c77:	6a 23                	push   $0x23
  800c79:	68 1c 25 80 00       	push   $0x80251c
  800c7e:	e8 93 10 00 00       	call   801d16 <_panic>

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
  800cd6:	68 ff 24 80 00       	push   $0x8024ff
  800cdb:	6a 23                	push   $0x23
  800cdd:	68 1c 25 80 00       	push   $0x80251c
  800ce2:	e8 2f 10 00 00       	call   801d16 <_panic>

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

00800d2f <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d2f:	55                   	push   %ebp
  800d30:	89 e5                	mov    %esp,%ebp
  800d32:	53                   	push   %ebx
  800d33:	83 ec 04             	sub    $0x4,%esp
  800d36:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d39:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800d3b:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d3f:	74 11                	je     800d52 <pgfault+0x23>
  800d41:	89 d8                	mov    %ebx,%eax
  800d43:	c1 e8 0c             	shr    $0xc,%eax
  800d46:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d4d:	f6 c4 08             	test   $0x8,%ah
  800d50:	75 14                	jne    800d66 <pgfault+0x37>
		panic("faulting access");
  800d52:	83 ec 04             	sub    $0x4,%esp
  800d55:	68 2a 25 80 00       	push   $0x80252a
  800d5a:	6a 1e                	push   $0x1e
  800d5c:	68 3a 25 80 00       	push   $0x80253a
  800d61:	e8 b0 0f 00 00       	call   801d16 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800d66:	83 ec 04             	sub    $0x4,%esp
  800d69:	6a 07                	push   $0x7
  800d6b:	68 00 f0 7f 00       	push   $0x7ff000
  800d70:	6a 00                	push   $0x0
  800d72:	e8 87 fd ff ff       	call   800afe <sys_page_alloc>
	if (r < 0) {
  800d77:	83 c4 10             	add    $0x10,%esp
  800d7a:	85 c0                	test   %eax,%eax
  800d7c:	79 12                	jns    800d90 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800d7e:	50                   	push   %eax
  800d7f:	68 45 25 80 00       	push   $0x802545
  800d84:	6a 2c                	push   $0x2c
  800d86:	68 3a 25 80 00       	push   $0x80253a
  800d8b:	e8 86 0f 00 00       	call   801d16 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800d90:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800d96:	83 ec 04             	sub    $0x4,%esp
  800d99:	68 00 10 00 00       	push   $0x1000
  800d9e:	53                   	push   %ebx
  800d9f:	68 00 f0 7f 00       	push   $0x7ff000
  800da4:	e8 4c fb ff ff       	call   8008f5 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800da9:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800db0:	53                   	push   %ebx
  800db1:	6a 00                	push   $0x0
  800db3:	68 00 f0 7f 00       	push   $0x7ff000
  800db8:	6a 00                	push   $0x0
  800dba:	e8 82 fd ff ff       	call   800b41 <sys_page_map>
	if (r < 0) {
  800dbf:	83 c4 20             	add    $0x20,%esp
  800dc2:	85 c0                	test   %eax,%eax
  800dc4:	79 12                	jns    800dd8 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800dc6:	50                   	push   %eax
  800dc7:	68 45 25 80 00       	push   $0x802545
  800dcc:	6a 33                	push   $0x33
  800dce:	68 3a 25 80 00       	push   $0x80253a
  800dd3:	e8 3e 0f 00 00       	call   801d16 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800dd8:	83 ec 08             	sub    $0x8,%esp
  800ddb:	68 00 f0 7f 00       	push   $0x7ff000
  800de0:	6a 00                	push   $0x0
  800de2:	e8 9c fd ff ff       	call   800b83 <sys_page_unmap>
	if (r < 0) {
  800de7:	83 c4 10             	add    $0x10,%esp
  800dea:	85 c0                	test   %eax,%eax
  800dec:	79 12                	jns    800e00 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800dee:	50                   	push   %eax
  800def:	68 45 25 80 00       	push   $0x802545
  800df4:	6a 37                	push   $0x37
  800df6:	68 3a 25 80 00       	push   $0x80253a
  800dfb:	e8 16 0f 00 00       	call   801d16 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e00:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e03:	c9                   	leave  
  800e04:	c3                   	ret    

00800e05 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	57                   	push   %edi
  800e09:	56                   	push   %esi
  800e0a:	53                   	push   %ebx
  800e0b:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e0e:	68 2f 0d 80 00       	push   $0x800d2f
  800e13:	e8 44 0f 00 00       	call   801d5c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e18:	b8 07 00 00 00       	mov    $0x7,%eax
  800e1d:	cd 30                	int    $0x30
  800e1f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800e22:	83 c4 10             	add    $0x10,%esp
  800e25:	85 c0                	test   %eax,%eax
  800e27:	79 17                	jns    800e40 <fork+0x3b>
		panic("fork fault %e");
  800e29:	83 ec 04             	sub    $0x4,%esp
  800e2c:	68 5e 25 80 00       	push   $0x80255e
  800e31:	68 84 00 00 00       	push   $0x84
  800e36:	68 3a 25 80 00       	push   $0x80253a
  800e3b:	e8 d6 0e 00 00       	call   801d16 <_panic>
  800e40:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800e42:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e46:	75 24                	jne    800e6c <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e48:	e8 73 fc ff ff       	call   800ac0 <sys_getenvid>
  800e4d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e52:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  800e58:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e5d:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800e62:	b8 00 00 00 00       	mov    $0x0,%eax
  800e67:	e9 64 01 00 00       	jmp    800fd0 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800e6c:	83 ec 04             	sub    $0x4,%esp
  800e6f:	6a 07                	push   $0x7
  800e71:	68 00 f0 bf ee       	push   $0xeebff000
  800e76:	ff 75 e4             	pushl  -0x1c(%ebp)
  800e79:	e8 80 fc ff ff       	call   800afe <sys_page_alloc>
  800e7e:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800e81:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800e86:	89 d8                	mov    %ebx,%eax
  800e88:	c1 e8 16             	shr    $0x16,%eax
  800e8b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e92:	a8 01                	test   $0x1,%al
  800e94:	0f 84 fc 00 00 00    	je     800f96 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800e9a:	89 d8                	mov    %ebx,%eax
  800e9c:	c1 e8 0c             	shr    $0xc,%eax
  800e9f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ea6:	f6 c2 01             	test   $0x1,%dl
  800ea9:	0f 84 e7 00 00 00    	je     800f96 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800eaf:	89 c6                	mov    %eax,%esi
  800eb1:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800eb4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ebb:	f6 c6 04             	test   $0x4,%dh
  800ebe:	74 39                	je     800ef9 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800ec0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ec7:	83 ec 0c             	sub    $0xc,%esp
  800eca:	25 07 0e 00 00       	and    $0xe07,%eax
  800ecf:	50                   	push   %eax
  800ed0:	56                   	push   %esi
  800ed1:	57                   	push   %edi
  800ed2:	56                   	push   %esi
  800ed3:	6a 00                	push   $0x0
  800ed5:	e8 67 fc ff ff       	call   800b41 <sys_page_map>
		if (r < 0) {
  800eda:	83 c4 20             	add    $0x20,%esp
  800edd:	85 c0                	test   %eax,%eax
  800edf:	0f 89 b1 00 00 00    	jns    800f96 <fork+0x191>
		    	panic("sys page map fault %e");
  800ee5:	83 ec 04             	sub    $0x4,%esp
  800ee8:	68 6c 25 80 00       	push   $0x80256c
  800eed:	6a 54                	push   $0x54
  800eef:	68 3a 25 80 00       	push   $0x80253a
  800ef4:	e8 1d 0e 00 00       	call   801d16 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800ef9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f00:	f6 c2 02             	test   $0x2,%dl
  800f03:	75 0c                	jne    800f11 <fork+0x10c>
  800f05:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f0c:	f6 c4 08             	test   $0x8,%ah
  800f0f:	74 5b                	je     800f6c <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f11:	83 ec 0c             	sub    $0xc,%esp
  800f14:	68 05 08 00 00       	push   $0x805
  800f19:	56                   	push   %esi
  800f1a:	57                   	push   %edi
  800f1b:	56                   	push   %esi
  800f1c:	6a 00                	push   $0x0
  800f1e:	e8 1e fc ff ff       	call   800b41 <sys_page_map>
		if (r < 0) {
  800f23:	83 c4 20             	add    $0x20,%esp
  800f26:	85 c0                	test   %eax,%eax
  800f28:	79 14                	jns    800f3e <fork+0x139>
		    	panic("sys page map fault %e");
  800f2a:	83 ec 04             	sub    $0x4,%esp
  800f2d:	68 6c 25 80 00       	push   $0x80256c
  800f32:	6a 5b                	push   $0x5b
  800f34:	68 3a 25 80 00       	push   $0x80253a
  800f39:	e8 d8 0d 00 00       	call   801d16 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800f3e:	83 ec 0c             	sub    $0xc,%esp
  800f41:	68 05 08 00 00       	push   $0x805
  800f46:	56                   	push   %esi
  800f47:	6a 00                	push   $0x0
  800f49:	56                   	push   %esi
  800f4a:	6a 00                	push   $0x0
  800f4c:	e8 f0 fb ff ff       	call   800b41 <sys_page_map>
		if (r < 0) {
  800f51:	83 c4 20             	add    $0x20,%esp
  800f54:	85 c0                	test   %eax,%eax
  800f56:	79 3e                	jns    800f96 <fork+0x191>
		    	panic("sys page map fault %e");
  800f58:	83 ec 04             	sub    $0x4,%esp
  800f5b:	68 6c 25 80 00       	push   $0x80256c
  800f60:	6a 5f                	push   $0x5f
  800f62:	68 3a 25 80 00       	push   $0x80253a
  800f67:	e8 aa 0d 00 00       	call   801d16 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800f6c:	83 ec 0c             	sub    $0xc,%esp
  800f6f:	6a 05                	push   $0x5
  800f71:	56                   	push   %esi
  800f72:	57                   	push   %edi
  800f73:	56                   	push   %esi
  800f74:	6a 00                	push   $0x0
  800f76:	e8 c6 fb ff ff       	call   800b41 <sys_page_map>
		if (r < 0) {
  800f7b:	83 c4 20             	add    $0x20,%esp
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	79 14                	jns    800f96 <fork+0x191>
		    	panic("sys page map fault %e");
  800f82:	83 ec 04             	sub    $0x4,%esp
  800f85:	68 6c 25 80 00       	push   $0x80256c
  800f8a:	6a 64                	push   $0x64
  800f8c:	68 3a 25 80 00       	push   $0x80253a
  800f91:	e8 80 0d 00 00       	call   801d16 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f96:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f9c:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800fa2:	0f 85 de fe ff ff    	jne    800e86 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800fa8:	a1 08 40 80 00       	mov    0x804008,%eax
  800fad:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  800fb3:	83 ec 08             	sub    $0x8,%esp
  800fb6:	50                   	push   %eax
  800fb7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800fba:	57                   	push   %edi
  800fbb:	e8 89 fc ff ff       	call   800c49 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  800fc0:	83 c4 08             	add    $0x8,%esp
  800fc3:	6a 02                	push   $0x2
  800fc5:	57                   	push   %edi
  800fc6:	e8 fa fb ff ff       	call   800bc5 <sys_env_set_status>
	
	return envid;
  800fcb:	83 c4 10             	add    $0x10,%esp
  800fce:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  800fd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fd3:	5b                   	pop    %ebx
  800fd4:	5e                   	pop    %esi
  800fd5:	5f                   	pop    %edi
  800fd6:	5d                   	pop    %ebp
  800fd7:	c3                   	ret    

00800fd8 <sfork>:

envid_t
sfork(void)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
	return 0;
}
  800fdb:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe0:	5d                   	pop    %ebp
  800fe1:	c3                   	ret    

00800fe2 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  800fe2:	55                   	push   %ebp
  800fe3:	89 e5                	mov    %esp,%ebp
  800fe5:	56                   	push   %esi
  800fe6:	53                   	push   %ebx
  800fe7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  800fea:	89 1d 0c 40 80 00    	mov    %ebx,0x80400c
	cprintf("in fork.c thread create. func: %x\n", func);
  800ff0:	83 ec 08             	sub    $0x8,%esp
  800ff3:	53                   	push   %ebx
  800ff4:	68 84 25 80 00       	push   $0x802584
  800ff9:	e8 78 f1 ff ff       	call   800176 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  800ffe:	c7 04 24 a9 00 80 00 	movl   $0x8000a9,(%esp)
  801005:	e8 e5 fc ff ff       	call   800cef <sys_thread_create>
  80100a:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80100c:	83 c4 08             	add    $0x8,%esp
  80100f:	53                   	push   %ebx
  801010:	68 84 25 80 00       	push   $0x802584
  801015:	e8 5c f1 ff ff       	call   800176 <cprintf>
	return id;
}
  80101a:	89 f0                	mov    %esi,%eax
  80101c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80101f:	5b                   	pop    %ebx
  801020:	5e                   	pop    %esi
  801021:	5d                   	pop    %ebp
  801022:	c3                   	ret    

00801023 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801023:	55                   	push   %ebp
  801024:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801026:	8b 45 08             	mov    0x8(%ebp),%eax
  801029:	05 00 00 00 30       	add    $0x30000000,%eax
  80102e:	c1 e8 0c             	shr    $0xc,%eax
}
  801031:	5d                   	pop    %ebp
  801032:	c3                   	ret    

00801033 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801036:	8b 45 08             	mov    0x8(%ebp),%eax
  801039:	05 00 00 00 30       	add    $0x30000000,%eax
  80103e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801043:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801048:	5d                   	pop    %ebp
  801049:	c3                   	ret    

0080104a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80104a:	55                   	push   %ebp
  80104b:	89 e5                	mov    %esp,%ebp
  80104d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801050:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801055:	89 c2                	mov    %eax,%edx
  801057:	c1 ea 16             	shr    $0x16,%edx
  80105a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801061:	f6 c2 01             	test   $0x1,%dl
  801064:	74 11                	je     801077 <fd_alloc+0x2d>
  801066:	89 c2                	mov    %eax,%edx
  801068:	c1 ea 0c             	shr    $0xc,%edx
  80106b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801072:	f6 c2 01             	test   $0x1,%dl
  801075:	75 09                	jne    801080 <fd_alloc+0x36>
			*fd_store = fd;
  801077:	89 01                	mov    %eax,(%ecx)
			return 0;
  801079:	b8 00 00 00 00       	mov    $0x0,%eax
  80107e:	eb 17                	jmp    801097 <fd_alloc+0x4d>
  801080:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801085:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80108a:	75 c9                	jne    801055 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80108c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801092:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801097:	5d                   	pop    %ebp
  801098:	c3                   	ret    

00801099 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801099:	55                   	push   %ebp
  80109a:	89 e5                	mov    %esp,%ebp
  80109c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80109f:	83 f8 1f             	cmp    $0x1f,%eax
  8010a2:	77 36                	ja     8010da <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010a4:	c1 e0 0c             	shl    $0xc,%eax
  8010a7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010ac:	89 c2                	mov    %eax,%edx
  8010ae:	c1 ea 16             	shr    $0x16,%edx
  8010b1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010b8:	f6 c2 01             	test   $0x1,%dl
  8010bb:	74 24                	je     8010e1 <fd_lookup+0x48>
  8010bd:	89 c2                	mov    %eax,%edx
  8010bf:	c1 ea 0c             	shr    $0xc,%edx
  8010c2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010c9:	f6 c2 01             	test   $0x1,%dl
  8010cc:	74 1a                	je     8010e8 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010d1:	89 02                	mov    %eax,(%edx)
	return 0;
  8010d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d8:	eb 13                	jmp    8010ed <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010df:	eb 0c                	jmp    8010ed <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010e6:	eb 05                	jmp    8010ed <fd_lookup+0x54>
  8010e8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010ed:	5d                   	pop    %ebp
  8010ee:	c3                   	ret    

008010ef <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010ef:	55                   	push   %ebp
  8010f0:	89 e5                	mov    %esp,%ebp
  8010f2:	83 ec 08             	sub    $0x8,%esp
  8010f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010f8:	ba 24 26 80 00       	mov    $0x802624,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8010fd:	eb 13                	jmp    801112 <dev_lookup+0x23>
  8010ff:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801102:	39 08                	cmp    %ecx,(%eax)
  801104:	75 0c                	jne    801112 <dev_lookup+0x23>
			*dev = devtab[i];
  801106:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801109:	89 01                	mov    %eax,(%ecx)
			return 0;
  80110b:	b8 00 00 00 00       	mov    $0x0,%eax
  801110:	eb 2e                	jmp    801140 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801112:	8b 02                	mov    (%edx),%eax
  801114:	85 c0                	test   %eax,%eax
  801116:	75 e7                	jne    8010ff <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801118:	a1 08 40 80 00       	mov    0x804008,%eax
  80111d:	8b 40 7c             	mov    0x7c(%eax),%eax
  801120:	83 ec 04             	sub    $0x4,%esp
  801123:	51                   	push   %ecx
  801124:	50                   	push   %eax
  801125:	68 a8 25 80 00       	push   $0x8025a8
  80112a:	e8 47 f0 ff ff       	call   800176 <cprintf>
	*dev = 0;
  80112f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801132:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801138:	83 c4 10             	add    $0x10,%esp
  80113b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801140:	c9                   	leave  
  801141:	c3                   	ret    

00801142 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801142:	55                   	push   %ebp
  801143:	89 e5                	mov    %esp,%ebp
  801145:	56                   	push   %esi
  801146:	53                   	push   %ebx
  801147:	83 ec 10             	sub    $0x10,%esp
  80114a:	8b 75 08             	mov    0x8(%ebp),%esi
  80114d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801150:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801153:	50                   	push   %eax
  801154:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80115a:	c1 e8 0c             	shr    $0xc,%eax
  80115d:	50                   	push   %eax
  80115e:	e8 36 ff ff ff       	call   801099 <fd_lookup>
  801163:	83 c4 08             	add    $0x8,%esp
  801166:	85 c0                	test   %eax,%eax
  801168:	78 05                	js     80116f <fd_close+0x2d>
	    || fd != fd2)
  80116a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80116d:	74 0c                	je     80117b <fd_close+0x39>
		return (must_exist ? r : 0);
  80116f:	84 db                	test   %bl,%bl
  801171:	ba 00 00 00 00       	mov    $0x0,%edx
  801176:	0f 44 c2             	cmove  %edx,%eax
  801179:	eb 41                	jmp    8011bc <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80117b:	83 ec 08             	sub    $0x8,%esp
  80117e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801181:	50                   	push   %eax
  801182:	ff 36                	pushl  (%esi)
  801184:	e8 66 ff ff ff       	call   8010ef <dev_lookup>
  801189:	89 c3                	mov    %eax,%ebx
  80118b:	83 c4 10             	add    $0x10,%esp
  80118e:	85 c0                	test   %eax,%eax
  801190:	78 1a                	js     8011ac <fd_close+0x6a>
		if (dev->dev_close)
  801192:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801195:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801198:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80119d:	85 c0                	test   %eax,%eax
  80119f:	74 0b                	je     8011ac <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011a1:	83 ec 0c             	sub    $0xc,%esp
  8011a4:	56                   	push   %esi
  8011a5:	ff d0                	call   *%eax
  8011a7:	89 c3                	mov    %eax,%ebx
  8011a9:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011ac:	83 ec 08             	sub    $0x8,%esp
  8011af:	56                   	push   %esi
  8011b0:	6a 00                	push   $0x0
  8011b2:	e8 cc f9 ff ff       	call   800b83 <sys_page_unmap>
	return r;
  8011b7:	83 c4 10             	add    $0x10,%esp
  8011ba:	89 d8                	mov    %ebx,%eax
}
  8011bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011bf:	5b                   	pop    %ebx
  8011c0:	5e                   	pop    %esi
  8011c1:	5d                   	pop    %ebp
  8011c2:	c3                   	ret    

008011c3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011c3:	55                   	push   %ebp
  8011c4:	89 e5                	mov    %esp,%ebp
  8011c6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011cc:	50                   	push   %eax
  8011cd:	ff 75 08             	pushl  0x8(%ebp)
  8011d0:	e8 c4 fe ff ff       	call   801099 <fd_lookup>
  8011d5:	83 c4 08             	add    $0x8,%esp
  8011d8:	85 c0                	test   %eax,%eax
  8011da:	78 10                	js     8011ec <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8011dc:	83 ec 08             	sub    $0x8,%esp
  8011df:	6a 01                	push   $0x1
  8011e1:	ff 75 f4             	pushl  -0xc(%ebp)
  8011e4:	e8 59 ff ff ff       	call   801142 <fd_close>
  8011e9:	83 c4 10             	add    $0x10,%esp
}
  8011ec:	c9                   	leave  
  8011ed:	c3                   	ret    

008011ee <close_all>:

void
close_all(void)
{
  8011ee:	55                   	push   %ebp
  8011ef:	89 e5                	mov    %esp,%ebp
  8011f1:	53                   	push   %ebx
  8011f2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011f5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011fa:	83 ec 0c             	sub    $0xc,%esp
  8011fd:	53                   	push   %ebx
  8011fe:	e8 c0 ff ff ff       	call   8011c3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801203:	83 c3 01             	add    $0x1,%ebx
  801206:	83 c4 10             	add    $0x10,%esp
  801209:	83 fb 20             	cmp    $0x20,%ebx
  80120c:	75 ec                	jne    8011fa <close_all+0xc>
		close(i);
}
  80120e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801211:	c9                   	leave  
  801212:	c3                   	ret    

00801213 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801213:	55                   	push   %ebp
  801214:	89 e5                	mov    %esp,%ebp
  801216:	57                   	push   %edi
  801217:	56                   	push   %esi
  801218:	53                   	push   %ebx
  801219:	83 ec 2c             	sub    $0x2c,%esp
  80121c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80121f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801222:	50                   	push   %eax
  801223:	ff 75 08             	pushl  0x8(%ebp)
  801226:	e8 6e fe ff ff       	call   801099 <fd_lookup>
  80122b:	83 c4 08             	add    $0x8,%esp
  80122e:	85 c0                	test   %eax,%eax
  801230:	0f 88 c1 00 00 00    	js     8012f7 <dup+0xe4>
		return r;
	close(newfdnum);
  801236:	83 ec 0c             	sub    $0xc,%esp
  801239:	56                   	push   %esi
  80123a:	e8 84 ff ff ff       	call   8011c3 <close>

	newfd = INDEX2FD(newfdnum);
  80123f:	89 f3                	mov    %esi,%ebx
  801241:	c1 e3 0c             	shl    $0xc,%ebx
  801244:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80124a:	83 c4 04             	add    $0x4,%esp
  80124d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801250:	e8 de fd ff ff       	call   801033 <fd2data>
  801255:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801257:	89 1c 24             	mov    %ebx,(%esp)
  80125a:	e8 d4 fd ff ff       	call   801033 <fd2data>
  80125f:	83 c4 10             	add    $0x10,%esp
  801262:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801265:	89 f8                	mov    %edi,%eax
  801267:	c1 e8 16             	shr    $0x16,%eax
  80126a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801271:	a8 01                	test   $0x1,%al
  801273:	74 37                	je     8012ac <dup+0x99>
  801275:	89 f8                	mov    %edi,%eax
  801277:	c1 e8 0c             	shr    $0xc,%eax
  80127a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801281:	f6 c2 01             	test   $0x1,%dl
  801284:	74 26                	je     8012ac <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801286:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80128d:	83 ec 0c             	sub    $0xc,%esp
  801290:	25 07 0e 00 00       	and    $0xe07,%eax
  801295:	50                   	push   %eax
  801296:	ff 75 d4             	pushl  -0x2c(%ebp)
  801299:	6a 00                	push   $0x0
  80129b:	57                   	push   %edi
  80129c:	6a 00                	push   $0x0
  80129e:	e8 9e f8 ff ff       	call   800b41 <sys_page_map>
  8012a3:	89 c7                	mov    %eax,%edi
  8012a5:	83 c4 20             	add    $0x20,%esp
  8012a8:	85 c0                	test   %eax,%eax
  8012aa:	78 2e                	js     8012da <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012ac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012af:	89 d0                	mov    %edx,%eax
  8012b1:	c1 e8 0c             	shr    $0xc,%eax
  8012b4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012bb:	83 ec 0c             	sub    $0xc,%esp
  8012be:	25 07 0e 00 00       	and    $0xe07,%eax
  8012c3:	50                   	push   %eax
  8012c4:	53                   	push   %ebx
  8012c5:	6a 00                	push   $0x0
  8012c7:	52                   	push   %edx
  8012c8:	6a 00                	push   $0x0
  8012ca:	e8 72 f8 ff ff       	call   800b41 <sys_page_map>
  8012cf:	89 c7                	mov    %eax,%edi
  8012d1:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8012d4:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012d6:	85 ff                	test   %edi,%edi
  8012d8:	79 1d                	jns    8012f7 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012da:	83 ec 08             	sub    $0x8,%esp
  8012dd:	53                   	push   %ebx
  8012de:	6a 00                	push   $0x0
  8012e0:	e8 9e f8 ff ff       	call   800b83 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012e5:	83 c4 08             	add    $0x8,%esp
  8012e8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012eb:	6a 00                	push   $0x0
  8012ed:	e8 91 f8 ff ff       	call   800b83 <sys_page_unmap>
	return r;
  8012f2:	83 c4 10             	add    $0x10,%esp
  8012f5:	89 f8                	mov    %edi,%eax
}
  8012f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012fa:	5b                   	pop    %ebx
  8012fb:	5e                   	pop    %esi
  8012fc:	5f                   	pop    %edi
  8012fd:	5d                   	pop    %ebp
  8012fe:	c3                   	ret    

008012ff <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012ff:	55                   	push   %ebp
  801300:	89 e5                	mov    %esp,%ebp
  801302:	53                   	push   %ebx
  801303:	83 ec 14             	sub    $0x14,%esp
  801306:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801309:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80130c:	50                   	push   %eax
  80130d:	53                   	push   %ebx
  80130e:	e8 86 fd ff ff       	call   801099 <fd_lookup>
  801313:	83 c4 08             	add    $0x8,%esp
  801316:	89 c2                	mov    %eax,%edx
  801318:	85 c0                	test   %eax,%eax
  80131a:	78 6d                	js     801389 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80131c:	83 ec 08             	sub    $0x8,%esp
  80131f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801322:	50                   	push   %eax
  801323:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801326:	ff 30                	pushl  (%eax)
  801328:	e8 c2 fd ff ff       	call   8010ef <dev_lookup>
  80132d:	83 c4 10             	add    $0x10,%esp
  801330:	85 c0                	test   %eax,%eax
  801332:	78 4c                	js     801380 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801334:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801337:	8b 42 08             	mov    0x8(%edx),%eax
  80133a:	83 e0 03             	and    $0x3,%eax
  80133d:	83 f8 01             	cmp    $0x1,%eax
  801340:	75 21                	jne    801363 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801342:	a1 08 40 80 00       	mov    0x804008,%eax
  801347:	8b 40 7c             	mov    0x7c(%eax),%eax
  80134a:	83 ec 04             	sub    $0x4,%esp
  80134d:	53                   	push   %ebx
  80134e:	50                   	push   %eax
  80134f:	68 e9 25 80 00       	push   $0x8025e9
  801354:	e8 1d ee ff ff       	call   800176 <cprintf>
		return -E_INVAL;
  801359:	83 c4 10             	add    $0x10,%esp
  80135c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801361:	eb 26                	jmp    801389 <read+0x8a>
	}
	if (!dev->dev_read)
  801363:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801366:	8b 40 08             	mov    0x8(%eax),%eax
  801369:	85 c0                	test   %eax,%eax
  80136b:	74 17                	je     801384 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80136d:	83 ec 04             	sub    $0x4,%esp
  801370:	ff 75 10             	pushl  0x10(%ebp)
  801373:	ff 75 0c             	pushl  0xc(%ebp)
  801376:	52                   	push   %edx
  801377:	ff d0                	call   *%eax
  801379:	89 c2                	mov    %eax,%edx
  80137b:	83 c4 10             	add    $0x10,%esp
  80137e:	eb 09                	jmp    801389 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801380:	89 c2                	mov    %eax,%edx
  801382:	eb 05                	jmp    801389 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801384:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801389:	89 d0                	mov    %edx,%eax
  80138b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80138e:	c9                   	leave  
  80138f:	c3                   	ret    

00801390 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801390:	55                   	push   %ebp
  801391:	89 e5                	mov    %esp,%ebp
  801393:	57                   	push   %edi
  801394:	56                   	push   %esi
  801395:	53                   	push   %ebx
  801396:	83 ec 0c             	sub    $0xc,%esp
  801399:	8b 7d 08             	mov    0x8(%ebp),%edi
  80139c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80139f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013a4:	eb 21                	jmp    8013c7 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013a6:	83 ec 04             	sub    $0x4,%esp
  8013a9:	89 f0                	mov    %esi,%eax
  8013ab:	29 d8                	sub    %ebx,%eax
  8013ad:	50                   	push   %eax
  8013ae:	89 d8                	mov    %ebx,%eax
  8013b0:	03 45 0c             	add    0xc(%ebp),%eax
  8013b3:	50                   	push   %eax
  8013b4:	57                   	push   %edi
  8013b5:	e8 45 ff ff ff       	call   8012ff <read>
		if (m < 0)
  8013ba:	83 c4 10             	add    $0x10,%esp
  8013bd:	85 c0                	test   %eax,%eax
  8013bf:	78 10                	js     8013d1 <readn+0x41>
			return m;
		if (m == 0)
  8013c1:	85 c0                	test   %eax,%eax
  8013c3:	74 0a                	je     8013cf <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013c5:	01 c3                	add    %eax,%ebx
  8013c7:	39 f3                	cmp    %esi,%ebx
  8013c9:	72 db                	jb     8013a6 <readn+0x16>
  8013cb:	89 d8                	mov    %ebx,%eax
  8013cd:	eb 02                	jmp    8013d1 <readn+0x41>
  8013cf:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d4:	5b                   	pop    %ebx
  8013d5:	5e                   	pop    %esi
  8013d6:	5f                   	pop    %edi
  8013d7:	5d                   	pop    %ebp
  8013d8:	c3                   	ret    

008013d9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013d9:	55                   	push   %ebp
  8013da:	89 e5                	mov    %esp,%ebp
  8013dc:	53                   	push   %ebx
  8013dd:	83 ec 14             	sub    $0x14,%esp
  8013e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e6:	50                   	push   %eax
  8013e7:	53                   	push   %ebx
  8013e8:	e8 ac fc ff ff       	call   801099 <fd_lookup>
  8013ed:	83 c4 08             	add    $0x8,%esp
  8013f0:	89 c2                	mov    %eax,%edx
  8013f2:	85 c0                	test   %eax,%eax
  8013f4:	78 68                	js     80145e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f6:	83 ec 08             	sub    $0x8,%esp
  8013f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013fc:	50                   	push   %eax
  8013fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801400:	ff 30                	pushl  (%eax)
  801402:	e8 e8 fc ff ff       	call   8010ef <dev_lookup>
  801407:	83 c4 10             	add    $0x10,%esp
  80140a:	85 c0                	test   %eax,%eax
  80140c:	78 47                	js     801455 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80140e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801411:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801415:	75 21                	jne    801438 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801417:	a1 08 40 80 00       	mov    0x804008,%eax
  80141c:	8b 40 7c             	mov    0x7c(%eax),%eax
  80141f:	83 ec 04             	sub    $0x4,%esp
  801422:	53                   	push   %ebx
  801423:	50                   	push   %eax
  801424:	68 05 26 80 00       	push   $0x802605
  801429:	e8 48 ed ff ff       	call   800176 <cprintf>
		return -E_INVAL;
  80142e:	83 c4 10             	add    $0x10,%esp
  801431:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801436:	eb 26                	jmp    80145e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801438:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80143b:	8b 52 0c             	mov    0xc(%edx),%edx
  80143e:	85 d2                	test   %edx,%edx
  801440:	74 17                	je     801459 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801442:	83 ec 04             	sub    $0x4,%esp
  801445:	ff 75 10             	pushl  0x10(%ebp)
  801448:	ff 75 0c             	pushl  0xc(%ebp)
  80144b:	50                   	push   %eax
  80144c:	ff d2                	call   *%edx
  80144e:	89 c2                	mov    %eax,%edx
  801450:	83 c4 10             	add    $0x10,%esp
  801453:	eb 09                	jmp    80145e <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801455:	89 c2                	mov    %eax,%edx
  801457:	eb 05                	jmp    80145e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801459:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80145e:	89 d0                	mov    %edx,%eax
  801460:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801463:	c9                   	leave  
  801464:	c3                   	ret    

00801465 <seek>:

int
seek(int fdnum, off_t offset)
{
  801465:	55                   	push   %ebp
  801466:	89 e5                	mov    %esp,%ebp
  801468:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80146b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80146e:	50                   	push   %eax
  80146f:	ff 75 08             	pushl  0x8(%ebp)
  801472:	e8 22 fc ff ff       	call   801099 <fd_lookup>
  801477:	83 c4 08             	add    $0x8,%esp
  80147a:	85 c0                	test   %eax,%eax
  80147c:	78 0e                	js     80148c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80147e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801481:	8b 55 0c             	mov    0xc(%ebp),%edx
  801484:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801487:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80148c:	c9                   	leave  
  80148d:	c3                   	ret    

0080148e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80148e:	55                   	push   %ebp
  80148f:	89 e5                	mov    %esp,%ebp
  801491:	53                   	push   %ebx
  801492:	83 ec 14             	sub    $0x14,%esp
  801495:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801498:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80149b:	50                   	push   %eax
  80149c:	53                   	push   %ebx
  80149d:	e8 f7 fb ff ff       	call   801099 <fd_lookup>
  8014a2:	83 c4 08             	add    $0x8,%esp
  8014a5:	89 c2                	mov    %eax,%edx
  8014a7:	85 c0                	test   %eax,%eax
  8014a9:	78 65                	js     801510 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ab:	83 ec 08             	sub    $0x8,%esp
  8014ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b1:	50                   	push   %eax
  8014b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b5:	ff 30                	pushl  (%eax)
  8014b7:	e8 33 fc ff ff       	call   8010ef <dev_lookup>
  8014bc:	83 c4 10             	add    $0x10,%esp
  8014bf:	85 c0                	test   %eax,%eax
  8014c1:	78 44                	js     801507 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014ca:	75 21                	jne    8014ed <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014cc:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014d1:	8b 40 7c             	mov    0x7c(%eax),%eax
  8014d4:	83 ec 04             	sub    $0x4,%esp
  8014d7:	53                   	push   %ebx
  8014d8:	50                   	push   %eax
  8014d9:	68 c8 25 80 00       	push   $0x8025c8
  8014de:	e8 93 ec ff ff       	call   800176 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014e3:	83 c4 10             	add    $0x10,%esp
  8014e6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014eb:	eb 23                	jmp    801510 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8014ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014f0:	8b 52 18             	mov    0x18(%edx),%edx
  8014f3:	85 d2                	test   %edx,%edx
  8014f5:	74 14                	je     80150b <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014f7:	83 ec 08             	sub    $0x8,%esp
  8014fa:	ff 75 0c             	pushl  0xc(%ebp)
  8014fd:	50                   	push   %eax
  8014fe:	ff d2                	call   *%edx
  801500:	89 c2                	mov    %eax,%edx
  801502:	83 c4 10             	add    $0x10,%esp
  801505:	eb 09                	jmp    801510 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801507:	89 c2                	mov    %eax,%edx
  801509:	eb 05                	jmp    801510 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80150b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801510:	89 d0                	mov    %edx,%eax
  801512:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801515:	c9                   	leave  
  801516:	c3                   	ret    

00801517 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801517:	55                   	push   %ebp
  801518:	89 e5                	mov    %esp,%ebp
  80151a:	53                   	push   %ebx
  80151b:	83 ec 14             	sub    $0x14,%esp
  80151e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801521:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801524:	50                   	push   %eax
  801525:	ff 75 08             	pushl  0x8(%ebp)
  801528:	e8 6c fb ff ff       	call   801099 <fd_lookup>
  80152d:	83 c4 08             	add    $0x8,%esp
  801530:	89 c2                	mov    %eax,%edx
  801532:	85 c0                	test   %eax,%eax
  801534:	78 58                	js     80158e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801536:	83 ec 08             	sub    $0x8,%esp
  801539:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80153c:	50                   	push   %eax
  80153d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801540:	ff 30                	pushl  (%eax)
  801542:	e8 a8 fb ff ff       	call   8010ef <dev_lookup>
  801547:	83 c4 10             	add    $0x10,%esp
  80154a:	85 c0                	test   %eax,%eax
  80154c:	78 37                	js     801585 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80154e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801551:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801555:	74 32                	je     801589 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801557:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80155a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801561:	00 00 00 
	stat->st_isdir = 0;
  801564:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80156b:	00 00 00 
	stat->st_dev = dev;
  80156e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801574:	83 ec 08             	sub    $0x8,%esp
  801577:	53                   	push   %ebx
  801578:	ff 75 f0             	pushl  -0x10(%ebp)
  80157b:	ff 50 14             	call   *0x14(%eax)
  80157e:	89 c2                	mov    %eax,%edx
  801580:	83 c4 10             	add    $0x10,%esp
  801583:	eb 09                	jmp    80158e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801585:	89 c2                	mov    %eax,%edx
  801587:	eb 05                	jmp    80158e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801589:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80158e:	89 d0                	mov    %edx,%eax
  801590:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801593:	c9                   	leave  
  801594:	c3                   	ret    

00801595 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801595:	55                   	push   %ebp
  801596:	89 e5                	mov    %esp,%ebp
  801598:	56                   	push   %esi
  801599:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80159a:	83 ec 08             	sub    $0x8,%esp
  80159d:	6a 00                	push   $0x0
  80159f:	ff 75 08             	pushl  0x8(%ebp)
  8015a2:	e8 e3 01 00 00       	call   80178a <open>
  8015a7:	89 c3                	mov    %eax,%ebx
  8015a9:	83 c4 10             	add    $0x10,%esp
  8015ac:	85 c0                	test   %eax,%eax
  8015ae:	78 1b                	js     8015cb <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015b0:	83 ec 08             	sub    $0x8,%esp
  8015b3:	ff 75 0c             	pushl  0xc(%ebp)
  8015b6:	50                   	push   %eax
  8015b7:	e8 5b ff ff ff       	call   801517 <fstat>
  8015bc:	89 c6                	mov    %eax,%esi
	close(fd);
  8015be:	89 1c 24             	mov    %ebx,(%esp)
  8015c1:	e8 fd fb ff ff       	call   8011c3 <close>
	return r;
  8015c6:	83 c4 10             	add    $0x10,%esp
  8015c9:	89 f0                	mov    %esi,%eax
}
  8015cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ce:	5b                   	pop    %ebx
  8015cf:	5e                   	pop    %esi
  8015d0:	5d                   	pop    %ebp
  8015d1:	c3                   	ret    

008015d2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015d2:	55                   	push   %ebp
  8015d3:	89 e5                	mov    %esp,%ebp
  8015d5:	56                   	push   %esi
  8015d6:	53                   	push   %ebx
  8015d7:	89 c6                	mov    %eax,%esi
  8015d9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015db:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015e2:	75 12                	jne    8015f6 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015e4:	83 ec 0c             	sub    $0xc,%esp
  8015e7:	6a 01                	push   $0x1
  8015e9:	e8 da 08 00 00       	call   801ec8 <ipc_find_env>
  8015ee:	a3 00 40 80 00       	mov    %eax,0x804000
  8015f3:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015f6:	6a 07                	push   $0x7
  8015f8:	68 00 50 80 00       	push   $0x805000
  8015fd:	56                   	push   %esi
  8015fe:	ff 35 00 40 80 00    	pushl  0x804000
  801604:	e8 5d 08 00 00       	call   801e66 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801609:	83 c4 0c             	add    $0xc,%esp
  80160c:	6a 00                	push   $0x0
  80160e:	53                   	push   %ebx
  80160f:	6a 00                	push   $0x0
  801611:	e8 d5 07 00 00       	call   801deb <ipc_recv>
}
  801616:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801619:	5b                   	pop    %ebx
  80161a:	5e                   	pop    %esi
  80161b:	5d                   	pop    %ebp
  80161c:	c3                   	ret    

0080161d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80161d:	55                   	push   %ebp
  80161e:	89 e5                	mov    %esp,%ebp
  801620:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801623:	8b 45 08             	mov    0x8(%ebp),%eax
  801626:	8b 40 0c             	mov    0xc(%eax),%eax
  801629:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80162e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801631:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801636:	ba 00 00 00 00       	mov    $0x0,%edx
  80163b:	b8 02 00 00 00       	mov    $0x2,%eax
  801640:	e8 8d ff ff ff       	call   8015d2 <fsipc>
}
  801645:	c9                   	leave  
  801646:	c3                   	ret    

00801647 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80164d:	8b 45 08             	mov    0x8(%ebp),%eax
  801650:	8b 40 0c             	mov    0xc(%eax),%eax
  801653:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801658:	ba 00 00 00 00       	mov    $0x0,%edx
  80165d:	b8 06 00 00 00       	mov    $0x6,%eax
  801662:	e8 6b ff ff ff       	call   8015d2 <fsipc>
}
  801667:	c9                   	leave  
  801668:	c3                   	ret    

00801669 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801669:	55                   	push   %ebp
  80166a:	89 e5                	mov    %esp,%ebp
  80166c:	53                   	push   %ebx
  80166d:	83 ec 04             	sub    $0x4,%esp
  801670:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801673:	8b 45 08             	mov    0x8(%ebp),%eax
  801676:	8b 40 0c             	mov    0xc(%eax),%eax
  801679:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80167e:	ba 00 00 00 00       	mov    $0x0,%edx
  801683:	b8 05 00 00 00       	mov    $0x5,%eax
  801688:	e8 45 ff ff ff       	call   8015d2 <fsipc>
  80168d:	85 c0                	test   %eax,%eax
  80168f:	78 2c                	js     8016bd <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801691:	83 ec 08             	sub    $0x8,%esp
  801694:	68 00 50 80 00       	push   $0x805000
  801699:	53                   	push   %ebx
  80169a:	e8 5c f0 ff ff       	call   8006fb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80169f:	a1 80 50 80 00       	mov    0x805080,%eax
  8016a4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016aa:	a1 84 50 80 00       	mov    0x805084,%eax
  8016af:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016b5:	83 c4 10             	add    $0x10,%esp
  8016b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c0:	c9                   	leave  
  8016c1:	c3                   	ret    

008016c2 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016c2:	55                   	push   %ebp
  8016c3:	89 e5                	mov    %esp,%ebp
  8016c5:	83 ec 0c             	sub    $0xc,%esp
  8016c8:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8016ce:	8b 52 0c             	mov    0xc(%edx),%edx
  8016d1:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8016d7:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8016dc:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8016e1:	0f 47 c2             	cmova  %edx,%eax
  8016e4:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8016e9:	50                   	push   %eax
  8016ea:	ff 75 0c             	pushl  0xc(%ebp)
  8016ed:	68 08 50 80 00       	push   $0x805008
  8016f2:	e8 96 f1 ff ff       	call   80088d <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8016f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016fc:	b8 04 00 00 00       	mov    $0x4,%eax
  801701:	e8 cc fe ff ff       	call   8015d2 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801706:	c9                   	leave  
  801707:	c3                   	ret    

00801708 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801708:	55                   	push   %ebp
  801709:	89 e5                	mov    %esp,%ebp
  80170b:	56                   	push   %esi
  80170c:	53                   	push   %ebx
  80170d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801710:	8b 45 08             	mov    0x8(%ebp),%eax
  801713:	8b 40 0c             	mov    0xc(%eax),%eax
  801716:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80171b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801721:	ba 00 00 00 00       	mov    $0x0,%edx
  801726:	b8 03 00 00 00       	mov    $0x3,%eax
  80172b:	e8 a2 fe ff ff       	call   8015d2 <fsipc>
  801730:	89 c3                	mov    %eax,%ebx
  801732:	85 c0                	test   %eax,%eax
  801734:	78 4b                	js     801781 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801736:	39 c6                	cmp    %eax,%esi
  801738:	73 16                	jae    801750 <devfile_read+0x48>
  80173a:	68 34 26 80 00       	push   $0x802634
  80173f:	68 3b 26 80 00       	push   $0x80263b
  801744:	6a 7c                	push   $0x7c
  801746:	68 50 26 80 00       	push   $0x802650
  80174b:	e8 c6 05 00 00       	call   801d16 <_panic>
	assert(r <= PGSIZE);
  801750:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801755:	7e 16                	jle    80176d <devfile_read+0x65>
  801757:	68 5b 26 80 00       	push   $0x80265b
  80175c:	68 3b 26 80 00       	push   $0x80263b
  801761:	6a 7d                	push   $0x7d
  801763:	68 50 26 80 00       	push   $0x802650
  801768:	e8 a9 05 00 00       	call   801d16 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80176d:	83 ec 04             	sub    $0x4,%esp
  801770:	50                   	push   %eax
  801771:	68 00 50 80 00       	push   $0x805000
  801776:	ff 75 0c             	pushl  0xc(%ebp)
  801779:	e8 0f f1 ff ff       	call   80088d <memmove>
	return r;
  80177e:	83 c4 10             	add    $0x10,%esp
}
  801781:	89 d8                	mov    %ebx,%eax
  801783:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801786:	5b                   	pop    %ebx
  801787:	5e                   	pop    %esi
  801788:	5d                   	pop    %ebp
  801789:	c3                   	ret    

0080178a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80178a:	55                   	push   %ebp
  80178b:	89 e5                	mov    %esp,%ebp
  80178d:	53                   	push   %ebx
  80178e:	83 ec 20             	sub    $0x20,%esp
  801791:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801794:	53                   	push   %ebx
  801795:	e8 28 ef ff ff       	call   8006c2 <strlen>
  80179a:	83 c4 10             	add    $0x10,%esp
  80179d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017a2:	7f 67                	jg     80180b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017a4:	83 ec 0c             	sub    $0xc,%esp
  8017a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017aa:	50                   	push   %eax
  8017ab:	e8 9a f8 ff ff       	call   80104a <fd_alloc>
  8017b0:	83 c4 10             	add    $0x10,%esp
		return r;
  8017b3:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017b5:	85 c0                	test   %eax,%eax
  8017b7:	78 57                	js     801810 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017b9:	83 ec 08             	sub    $0x8,%esp
  8017bc:	53                   	push   %ebx
  8017bd:	68 00 50 80 00       	push   $0x805000
  8017c2:	e8 34 ef ff ff       	call   8006fb <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ca:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8017d7:	e8 f6 fd ff ff       	call   8015d2 <fsipc>
  8017dc:	89 c3                	mov    %eax,%ebx
  8017de:	83 c4 10             	add    $0x10,%esp
  8017e1:	85 c0                	test   %eax,%eax
  8017e3:	79 14                	jns    8017f9 <open+0x6f>
		fd_close(fd, 0);
  8017e5:	83 ec 08             	sub    $0x8,%esp
  8017e8:	6a 00                	push   $0x0
  8017ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8017ed:	e8 50 f9 ff ff       	call   801142 <fd_close>
		return r;
  8017f2:	83 c4 10             	add    $0x10,%esp
  8017f5:	89 da                	mov    %ebx,%edx
  8017f7:	eb 17                	jmp    801810 <open+0x86>
	}

	return fd2num(fd);
  8017f9:	83 ec 0c             	sub    $0xc,%esp
  8017fc:	ff 75 f4             	pushl  -0xc(%ebp)
  8017ff:	e8 1f f8 ff ff       	call   801023 <fd2num>
  801804:	89 c2                	mov    %eax,%edx
  801806:	83 c4 10             	add    $0x10,%esp
  801809:	eb 05                	jmp    801810 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80180b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801810:	89 d0                	mov    %edx,%eax
  801812:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801815:	c9                   	leave  
  801816:	c3                   	ret    

00801817 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801817:	55                   	push   %ebp
  801818:	89 e5                	mov    %esp,%ebp
  80181a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80181d:	ba 00 00 00 00       	mov    $0x0,%edx
  801822:	b8 08 00 00 00       	mov    $0x8,%eax
  801827:	e8 a6 fd ff ff       	call   8015d2 <fsipc>
}
  80182c:	c9                   	leave  
  80182d:	c3                   	ret    

0080182e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80182e:	55                   	push   %ebp
  80182f:	89 e5                	mov    %esp,%ebp
  801831:	56                   	push   %esi
  801832:	53                   	push   %ebx
  801833:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801836:	83 ec 0c             	sub    $0xc,%esp
  801839:	ff 75 08             	pushl  0x8(%ebp)
  80183c:	e8 f2 f7 ff ff       	call   801033 <fd2data>
  801841:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801843:	83 c4 08             	add    $0x8,%esp
  801846:	68 67 26 80 00       	push   $0x802667
  80184b:	53                   	push   %ebx
  80184c:	e8 aa ee ff ff       	call   8006fb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801851:	8b 46 04             	mov    0x4(%esi),%eax
  801854:	2b 06                	sub    (%esi),%eax
  801856:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80185c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801863:	00 00 00 
	stat->st_dev = &devpipe;
  801866:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80186d:	30 80 00 
	return 0;
}
  801870:	b8 00 00 00 00       	mov    $0x0,%eax
  801875:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801878:	5b                   	pop    %ebx
  801879:	5e                   	pop    %esi
  80187a:	5d                   	pop    %ebp
  80187b:	c3                   	ret    

0080187c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80187c:	55                   	push   %ebp
  80187d:	89 e5                	mov    %esp,%ebp
  80187f:	53                   	push   %ebx
  801880:	83 ec 0c             	sub    $0xc,%esp
  801883:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801886:	53                   	push   %ebx
  801887:	6a 00                	push   $0x0
  801889:	e8 f5 f2 ff ff       	call   800b83 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80188e:	89 1c 24             	mov    %ebx,(%esp)
  801891:	e8 9d f7 ff ff       	call   801033 <fd2data>
  801896:	83 c4 08             	add    $0x8,%esp
  801899:	50                   	push   %eax
  80189a:	6a 00                	push   $0x0
  80189c:	e8 e2 f2 ff ff       	call   800b83 <sys_page_unmap>
}
  8018a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a4:	c9                   	leave  
  8018a5:	c3                   	ret    

008018a6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018a6:	55                   	push   %ebp
  8018a7:	89 e5                	mov    %esp,%ebp
  8018a9:	57                   	push   %edi
  8018aa:	56                   	push   %esi
  8018ab:	53                   	push   %ebx
  8018ac:	83 ec 1c             	sub    $0x1c,%esp
  8018af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018b2:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018b4:	a1 08 40 80 00       	mov    0x804008,%eax
  8018b9:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8018bf:	83 ec 0c             	sub    $0xc,%esp
  8018c2:	ff 75 e0             	pushl  -0x20(%ebp)
  8018c5:	e8 40 06 00 00       	call   801f0a <pageref>
  8018ca:	89 c3                	mov    %eax,%ebx
  8018cc:	89 3c 24             	mov    %edi,(%esp)
  8018cf:	e8 36 06 00 00       	call   801f0a <pageref>
  8018d4:	83 c4 10             	add    $0x10,%esp
  8018d7:	39 c3                	cmp    %eax,%ebx
  8018d9:	0f 94 c1             	sete   %cl
  8018dc:	0f b6 c9             	movzbl %cl,%ecx
  8018df:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8018e2:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8018e8:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  8018ee:	39 ce                	cmp    %ecx,%esi
  8018f0:	74 1e                	je     801910 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  8018f2:	39 c3                	cmp    %eax,%ebx
  8018f4:	75 be                	jne    8018b4 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018f6:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  8018fc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018ff:	50                   	push   %eax
  801900:	56                   	push   %esi
  801901:	68 6e 26 80 00       	push   $0x80266e
  801906:	e8 6b e8 ff ff       	call   800176 <cprintf>
  80190b:	83 c4 10             	add    $0x10,%esp
  80190e:	eb a4                	jmp    8018b4 <_pipeisclosed+0xe>
	}
}
  801910:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801913:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801916:	5b                   	pop    %ebx
  801917:	5e                   	pop    %esi
  801918:	5f                   	pop    %edi
  801919:	5d                   	pop    %ebp
  80191a:	c3                   	ret    

0080191b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80191b:	55                   	push   %ebp
  80191c:	89 e5                	mov    %esp,%ebp
  80191e:	57                   	push   %edi
  80191f:	56                   	push   %esi
  801920:	53                   	push   %ebx
  801921:	83 ec 28             	sub    $0x28,%esp
  801924:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801927:	56                   	push   %esi
  801928:	e8 06 f7 ff ff       	call   801033 <fd2data>
  80192d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80192f:	83 c4 10             	add    $0x10,%esp
  801932:	bf 00 00 00 00       	mov    $0x0,%edi
  801937:	eb 4b                	jmp    801984 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801939:	89 da                	mov    %ebx,%edx
  80193b:	89 f0                	mov    %esi,%eax
  80193d:	e8 64 ff ff ff       	call   8018a6 <_pipeisclosed>
  801942:	85 c0                	test   %eax,%eax
  801944:	75 48                	jne    80198e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801946:	e8 94 f1 ff ff       	call   800adf <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80194b:	8b 43 04             	mov    0x4(%ebx),%eax
  80194e:	8b 0b                	mov    (%ebx),%ecx
  801950:	8d 51 20             	lea    0x20(%ecx),%edx
  801953:	39 d0                	cmp    %edx,%eax
  801955:	73 e2                	jae    801939 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801957:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80195a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80195e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801961:	89 c2                	mov    %eax,%edx
  801963:	c1 fa 1f             	sar    $0x1f,%edx
  801966:	89 d1                	mov    %edx,%ecx
  801968:	c1 e9 1b             	shr    $0x1b,%ecx
  80196b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80196e:	83 e2 1f             	and    $0x1f,%edx
  801971:	29 ca                	sub    %ecx,%edx
  801973:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801977:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80197b:	83 c0 01             	add    $0x1,%eax
  80197e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801981:	83 c7 01             	add    $0x1,%edi
  801984:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801987:	75 c2                	jne    80194b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801989:	8b 45 10             	mov    0x10(%ebp),%eax
  80198c:	eb 05                	jmp    801993 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80198e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801993:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801996:	5b                   	pop    %ebx
  801997:	5e                   	pop    %esi
  801998:	5f                   	pop    %edi
  801999:	5d                   	pop    %ebp
  80199a:	c3                   	ret    

0080199b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80199b:	55                   	push   %ebp
  80199c:	89 e5                	mov    %esp,%ebp
  80199e:	57                   	push   %edi
  80199f:	56                   	push   %esi
  8019a0:	53                   	push   %ebx
  8019a1:	83 ec 18             	sub    $0x18,%esp
  8019a4:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019a7:	57                   	push   %edi
  8019a8:	e8 86 f6 ff ff       	call   801033 <fd2data>
  8019ad:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019af:	83 c4 10             	add    $0x10,%esp
  8019b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019b7:	eb 3d                	jmp    8019f6 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019b9:	85 db                	test   %ebx,%ebx
  8019bb:	74 04                	je     8019c1 <devpipe_read+0x26>
				return i;
  8019bd:	89 d8                	mov    %ebx,%eax
  8019bf:	eb 44                	jmp    801a05 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019c1:	89 f2                	mov    %esi,%edx
  8019c3:	89 f8                	mov    %edi,%eax
  8019c5:	e8 dc fe ff ff       	call   8018a6 <_pipeisclosed>
  8019ca:	85 c0                	test   %eax,%eax
  8019cc:	75 32                	jne    801a00 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019ce:	e8 0c f1 ff ff       	call   800adf <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019d3:	8b 06                	mov    (%esi),%eax
  8019d5:	3b 46 04             	cmp    0x4(%esi),%eax
  8019d8:	74 df                	je     8019b9 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019da:	99                   	cltd   
  8019db:	c1 ea 1b             	shr    $0x1b,%edx
  8019de:	01 d0                	add    %edx,%eax
  8019e0:	83 e0 1f             	and    $0x1f,%eax
  8019e3:	29 d0                	sub    %edx,%eax
  8019e5:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8019ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019ed:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8019f0:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019f3:	83 c3 01             	add    $0x1,%ebx
  8019f6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019f9:	75 d8                	jne    8019d3 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019fb:	8b 45 10             	mov    0x10(%ebp),%eax
  8019fe:	eb 05                	jmp    801a05 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a00:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a08:	5b                   	pop    %ebx
  801a09:	5e                   	pop    %esi
  801a0a:	5f                   	pop    %edi
  801a0b:	5d                   	pop    %ebp
  801a0c:	c3                   	ret    

00801a0d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a0d:	55                   	push   %ebp
  801a0e:	89 e5                	mov    %esp,%ebp
  801a10:	56                   	push   %esi
  801a11:	53                   	push   %ebx
  801a12:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a15:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a18:	50                   	push   %eax
  801a19:	e8 2c f6 ff ff       	call   80104a <fd_alloc>
  801a1e:	83 c4 10             	add    $0x10,%esp
  801a21:	89 c2                	mov    %eax,%edx
  801a23:	85 c0                	test   %eax,%eax
  801a25:	0f 88 2c 01 00 00    	js     801b57 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a2b:	83 ec 04             	sub    $0x4,%esp
  801a2e:	68 07 04 00 00       	push   $0x407
  801a33:	ff 75 f4             	pushl  -0xc(%ebp)
  801a36:	6a 00                	push   $0x0
  801a38:	e8 c1 f0 ff ff       	call   800afe <sys_page_alloc>
  801a3d:	83 c4 10             	add    $0x10,%esp
  801a40:	89 c2                	mov    %eax,%edx
  801a42:	85 c0                	test   %eax,%eax
  801a44:	0f 88 0d 01 00 00    	js     801b57 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a4a:	83 ec 0c             	sub    $0xc,%esp
  801a4d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a50:	50                   	push   %eax
  801a51:	e8 f4 f5 ff ff       	call   80104a <fd_alloc>
  801a56:	89 c3                	mov    %eax,%ebx
  801a58:	83 c4 10             	add    $0x10,%esp
  801a5b:	85 c0                	test   %eax,%eax
  801a5d:	0f 88 e2 00 00 00    	js     801b45 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a63:	83 ec 04             	sub    $0x4,%esp
  801a66:	68 07 04 00 00       	push   $0x407
  801a6b:	ff 75 f0             	pushl  -0x10(%ebp)
  801a6e:	6a 00                	push   $0x0
  801a70:	e8 89 f0 ff ff       	call   800afe <sys_page_alloc>
  801a75:	89 c3                	mov    %eax,%ebx
  801a77:	83 c4 10             	add    $0x10,%esp
  801a7a:	85 c0                	test   %eax,%eax
  801a7c:	0f 88 c3 00 00 00    	js     801b45 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a82:	83 ec 0c             	sub    $0xc,%esp
  801a85:	ff 75 f4             	pushl  -0xc(%ebp)
  801a88:	e8 a6 f5 ff ff       	call   801033 <fd2data>
  801a8d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a8f:	83 c4 0c             	add    $0xc,%esp
  801a92:	68 07 04 00 00       	push   $0x407
  801a97:	50                   	push   %eax
  801a98:	6a 00                	push   $0x0
  801a9a:	e8 5f f0 ff ff       	call   800afe <sys_page_alloc>
  801a9f:	89 c3                	mov    %eax,%ebx
  801aa1:	83 c4 10             	add    $0x10,%esp
  801aa4:	85 c0                	test   %eax,%eax
  801aa6:	0f 88 89 00 00 00    	js     801b35 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aac:	83 ec 0c             	sub    $0xc,%esp
  801aaf:	ff 75 f0             	pushl  -0x10(%ebp)
  801ab2:	e8 7c f5 ff ff       	call   801033 <fd2data>
  801ab7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801abe:	50                   	push   %eax
  801abf:	6a 00                	push   $0x0
  801ac1:	56                   	push   %esi
  801ac2:	6a 00                	push   $0x0
  801ac4:	e8 78 f0 ff ff       	call   800b41 <sys_page_map>
  801ac9:	89 c3                	mov    %eax,%ebx
  801acb:	83 c4 20             	add    $0x20,%esp
  801ace:	85 c0                	test   %eax,%eax
  801ad0:	78 55                	js     801b27 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ad2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801adb:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801add:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ae7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801aed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801af0:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801af2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801af5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801afc:	83 ec 0c             	sub    $0xc,%esp
  801aff:	ff 75 f4             	pushl  -0xc(%ebp)
  801b02:	e8 1c f5 ff ff       	call   801023 <fd2num>
  801b07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b0a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b0c:	83 c4 04             	add    $0x4,%esp
  801b0f:	ff 75 f0             	pushl  -0x10(%ebp)
  801b12:	e8 0c f5 ff ff       	call   801023 <fd2num>
  801b17:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b1a:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801b1d:	83 c4 10             	add    $0x10,%esp
  801b20:	ba 00 00 00 00       	mov    $0x0,%edx
  801b25:	eb 30                	jmp    801b57 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b27:	83 ec 08             	sub    $0x8,%esp
  801b2a:	56                   	push   %esi
  801b2b:	6a 00                	push   $0x0
  801b2d:	e8 51 f0 ff ff       	call   800b83 <sys_page_unmap>
  801b32:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b35:	83 ec 08             	sub    $0x8,%esp
  801b38:	ff 75 f0             	pushl  -0x10(%ebp)
  801b3b:	6a 00                	push   $0x0
  801b3d:	e8 41 f0 ff ff       	call   800b83 <sys_page_unmap>
  801b42:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b45:	83 ec 08             	sub    $0x8,%esp
  801b48:	ff 75 f4             	pushl  -0xc(%ebp)
  801b4b:	6a 00                	push   $0x0
  801b4d:	e8 31 f0 ff ff       	call   800b83 <sys_page_unmap>
  801b52:	83 c4 10             	add    $0x10,%esp
  801b55:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b57:	89 d0                	mov    %edx,%eax
  801b59:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b5c:	5b                   	pop    %ebx
  801b5d:	5e                   	pop    %esi
  801b5e:	5d                   	pop    %ebp
  801b5f:	c3                   	ret    

00801b60 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b66:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b69:	50                   	push   %eax
  801b6a:	ff 75 08             	pushl  0x8(%ebp)
  801b6d:	e8 27 f5 ff ff       	call   801099 <fd_lookup>
  801b72:	83 c4 10             	add    $0x10,%esp
  801b75:	85 c0                	test   %eax,%eax
  801b77:	78 18                	js     801b91 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b79:	83 ec 0c             	sub    $0xc,%esp
  801b7c:	ff 75 f4             	pushl  -0xc(%ebp)
  801b7f:	e8 af f4 ff ff       	call   801033 <fd2data>
	return _pipeisclosed(fd, p);
  801b84:	89 c2                	mov    %eax,%edx
  801b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b89:	e8 18 fd ff ff       	call   8018a6 <_pipeisclosed>
  801b8e:	83 c4 10             	add    $0x10,%esp
}
  801b91:	c9                   	leave  
  801b92:	c3                   	ret    

00801b93 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b93:	55                   	push   %ebp
  801b94:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b96:	b8 00 00 00 00       	mov    $0x0,%eax
  801b9b:	5d                   	pop    %ebp
  801b9c:	c3                   	ret    

00801b9d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b9d:	55                   	push   %ebp
  801b9e:	89 e5                	mov    %esp,%ebp
  801ba0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ba3:	68 86 26 80 00       	push   $0x802686
  801ba8:	ff 75 0c             	pushl  0xc(%ebp)
  801bab:	e8 4b eb ff ff       	call   8006fb <strcpy>
	return 0;
}
  801bb0:	b8 00 00 00 00       	mov    $0x0,%eax
  801bb5:	c9                   	leave  
  801bb6:	c3                   	ret    

00801bb7 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bb7:	55                   	push   %ebp
  801bb8:	89 e5                	mov    %esp,%ebp
  801bba:	57                   	push   %edi
  801bbb:	56                   	push   %esi
  801bbc:	53                   	push   %ebx
  801bbd:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bc3:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bc8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bce:	eb 2d                	jmp    801bfd <devcons_write+0x46>
		m = n - tot;
  801bd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801bd3:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801bd5:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801bd8:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801bdd:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801be0:	83 ec 04             	sub    $0x4,%esp
  801be3:	53                   	push   %ebx
  801be4:	03 45 0c             	add    0xc(%ebp),%eax
  801be7:	50                   	push   %eax
  801be8:	57                   	push   %edi
  801be9:	e8 9f ec ff ff       	call   80088d <memmove>
		sys_cputs(buf, m);
  801bee:	83 c4 08             	add    $0x8,%esp
  801bf1:	53                   	push   %ebx
  801bf2:	57                   	push   %edi
  801bf3:	e8 4a ee ff ff       	call   800a42 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bf8:	01 de                	add    %ebx,%esi
  801bfa:	83 c4 10             	add    $0x10,%esp
  801bfd:	89 f0                	mov    %esi,%eax
  801bff:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c02:	72 cc                	jb     801bd0 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c07:	5b                   	pop    %ebx
  801c08:	5e                   	pop    %esi
  801c09:	5f                   	pop    %edi
  801c0a:	5d                   	pop    %ebp
  801c0b:	c3                   	ret    

00801c0c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c0c:	55                   	push   %ebp
  801c0d:	89 e5                	mov    %esp,%ebp
  801c0f:	83 ec 08             	sub    $0x8,%esp
  801c12:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c17:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c1b:	74 2a                	je     801c47 <devcons_read+0x3b>
  801c1d:	eb 05                	jmp    801c24 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c1f:	e8 bb ee ff ff       	call   800adf <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c24:	e8 37 ee ff ff       	call   800a60 <sys_cgetc>
  801c29:	85 c0                	test   %eax,%eax
  801c2b:	74 f2                	je     801c1f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c2d:	85 c0                	test   %eax,%eax
  801c2f:	78 16                	js     801c47 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c31:	83 f8 04             	cmp    $0x4,%eax
  801c34:	74 0c                	je     801c42 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c36:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c39:	88 02                	mov    %al,(%edx)
	return 1;
  801c3b:	b8 01 00 00 00       	mov    $0x1,%eax
  801c40:	eb 05                	jmp    801c47 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c42:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c47:	c9                   	leave  
  801c48:	c3                   	ret    

00801c49 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c49:	55                   	push   %ebp
  801c4a:	89 e5                	mov    %esp,%ebp
  801c4c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c52:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c55:	6a 01                	push   $0x1
  801c57:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c5a:	50                   	push   %eax
  801c5b:	e8 e2 ed ff ff       	call   800a42 <sys_cputs>
}
  801c60:	83 c4 10             	add    $0x10,%esp
  801c63:	c9                   	leave  
  801c64:	c3                   	ret    

00801c65 <getchar>:

int
getchar(void)
{
  801c65:	55                   	push   %ebp
  801c66:	89 e5                	mov    %esp,%ebp
  801c68:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c6b:	6a 01                	push   $0x1
  801c6d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c70:	50                   	push   %eax
  801c71:	6a 00                	push   $0x0
  801c73:	e8 87 f6 ff ff       	call   8012ff <read>
	if (r < 0)
  801c78:	83 c4 10             	add    $0x10,%esp
  801c7b:	85 c0                	test   %eax,%eax
  801c7d:	78 0f                	js     801c8e <getchar+0x29>
		return r;
	if (r < 1)
  801c7f:	85 c0                	test   %eax,%eax
  801c81:	7e 06                	jle    801c89 <getchar+0x24>
		return -E_EOF;
	return c;
  801c83:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c87:	eb 05                	jmp    801c8e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c89:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c8e:	c9                   	leave  
  801c8f:	c3                   	ret    

00801c90 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c90:	55                   	push   %ebp
  801c91:	89 e5                	mov    %esp,%ebp
  801c93:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c96:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c99:	50                   	push   %eax
  801c9a:	ff 75 08             	pushl  0x8(%ebp)
  801c9d:	e8 f7 f3 ff ff       	call   801099 <fd_lookup>
  801ca2:	83 c4 10             	add    $0x10,%esp
  801ca5:	85 c0                	test   %eax,%eax
  801ca7:	78 11                	js     801cba <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cac:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cb2:	39 10                	cmp    %edx,(%eax)
  801cb4:	0f 94 c0             	sete   %al
  801cb7:	0f b6 c0             	movzbl %al,%eax
}
  801cba:	c9                   	leave  
  801cbb:	c3                   	ret    

00801cbc <opencons>:

int
opencons(void)
{
  801cbc:	55                   	push   %ebp
  801cbd:	89 e5                	mov    %esp,%ebp
  801cbf:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cc2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cc5:	50                   	push   %eax
  801cc6:	e8 7f f3 ff ff       	call   80104a <fd_alloc>
  801ccb:	83 c4 10             	add    $0x10,%esp
		return r;
  801cce:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cd0:	85 c0                	test   %eax,%eax
  801cd2:	78 3e                	js     801d12 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cd4:	83 ec 04             	sub    $0x4,%esp
  801cd7:	68 07 04 00 00       	push   $0x407
  801cdc:	ff 75 f4             	pushl  -0xc(%ebp)
  801cdf:	6a 00                	push   $0x0
  801ce1:	e8 18 ee ff ff       	call   800afe <sys_page_alloc>
  801ce6:	83 c4 10             	add    $0x10,%esp
		return r;
  801ce9:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ceb:	85 c0                	test   %eax,%eax
  801ced:	78 23                	js     801d12 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801cef:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801cfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cfd:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d04:	83 ec 0c             	sub    $0xc,%esp
  801d07:	50                   	push   %eax
  801d08:	e8 16 f3 ff ff       	call   801023 <fd2num>
  801d0d:	89 c2                	mov    %eax,%edx
  801d0f:	83 c4 10             	add    $0x10,%esp
}
  801d12:	89 d0                	mov    %edx,%eax
  801d14:	c9                   	leave  
  801d15:	c3                   	ret    

00801d16 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d16:	55                   	push   %ebp
  801d17:	89 e5                	mov    %esp,%ebp
  801d19:	56                   	push   %esi
  801d1a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d1b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d1e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d24:	e8 97 ed ff ff       	call   800ac0 <sys_getenvid>
  801d29:	83 ec 0c             	sub    $0xc,%esp
  801d2c:	ff 75 0c             	pushl  0xc(%ebp)
  801d2f:	ff 75 08             	pushl  0x8(%ebp)
  801d32:	56                   	push   %esi
  801d33:	50                   	push   %eax
  801d34:	68 94 26 80 00       	push   $0x802694
  801d39:	e8 38 e4 ff ff       	call   800176 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d3e:	83 c4 18             	add    $0x18,%esp
  801d41:	53                   	push   %ebx
  801d42:	ff 75 10             	pushl  0x10(%ebp)
  801d45:	e8 db e3 ff ff       	call   800125 <vcprintf>
	cprintf("\n");
  801d4a:	c7 04 24 ec 21 80 00 	movl   $0x8021ec,(%esp)
  801d51:	e8 20 e4 ff ff       	call   800176 <cprintf>
  801d56:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d59:	cc                   	int3   
  801d5a:	eb fd                	jmp    801d59 <_panic+0x43>

00801d5c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d5c:	55                   	push   %ebp
  801d5d:	89 e5                	mov    %esp,%ebp
  801d5f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d62:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d69:	75 2a                	jne    801d95 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d6b:	83 ec 04             	sub    $0x4,%esp
  801d6e:	6a 07                	push   $0x7
  801d70:	68 00 f0 bf ee       	push   $0xeebff000
  801d75:	6a 00                	push   $0x0
  801d77:	e8 82 ed ff ff       	call   800afe <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801d7c:	83 c4 10             	add    $0x10,%esp
  801d7f:	85 c0                	test   %eax,%eax
  801d81:	79 12                	jns    801d95 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801d83:	50                   	push   %eax
  801d84:	68 b8 26 80 00       	push   $0x8026b8
  801d89:	6a 23                	push   $0x23
  801d8b:	68 bc 26 80 00       	push   $0x8026bc
  801d90:	e8 81 ff ff ff       	call   801d16 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d95:	8b 45 08             	mov    0x8(%ebp),%eax
  801d98:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801d9d:	83 ec 08             	sub    $0x8,%esp
  801da0:	68 c7 1d 80 00       	push   $0x801dc7
  801da5:	6a 00                	push   $0x0
  801da7:	e8 9d ee ff ff       	call   800c49 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801dac:	83 c4 10             	add    $0x10,%esp
  801daf:	85 c0                	test   %eax,%eax
  801db1:	79 12                	jns    801dc5 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801db3:	50                   	push   %eax
  801db4:	68 b8 26 80 00       	push   $0x8026b8
  801db9:	6a 2c                	push   $0x2c
  801dbb:	68 bc 26 80 00       	push   $0x8026bc
  801dc0:	e8 51 ff ff ff       	call   801d16 <_panic>
	}
}
  801dc5:	c9                   	leave  
  801dc6:	c3                   	ret    

00801dc7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801dc7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801dc8:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801dcd:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801dcf:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801dd2:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801dd6:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801ddb:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801ddf:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801de1:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801de4:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801de5:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801de8:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801de9:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801dea:	c3                   	ret    

00801deb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801deb:	55                   	push   %ebp
  801dec:	89 e5                	mov    %esp,%ebp
  801dee:	56                   	push   %esi
  801def:	53                   	push   %ebx
  801df0:	8b 75 08             	mov    0x8(%ebp),%esi
  801df3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801df9:	85 c0                	test   %eax,%eax
  801dfb:	75 12                	jne    801e0f <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801dfd:	83 ec 0c             	sub    $0xc,%esp
  801e00:	68 00 00 c0 ee       	push   $0xeec00000
  801e05:	e8 a4 ee ff ff       	call   800cae <sys_ipc_recv>
  801e0a:	83 c4 10             	add    $0x10,%esp
  801e0d:	eb 0c                	jmp    801e1b <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e0f:	83 ec 0c             	sub    $0xc,%esp
  801e12:	50                   	push   %eax
  801e13:	e8 96 ee ff ff       	call   800cae <sys_ipc_recv>
  801e18:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e1b:	85 f6                	test   %esi,%esi
  801e1d:	0f 95 c1             	setne  %cl
  801e20:	85 db                	test   %ebx,%ebx
  801e22:	0f 95 c2             	setne  %dl
  801e25:	84 d1                	test   %dl,%cl
  801e27:	74 09                	je     801e32 <ipc_recv+0x47>
  801e29:	89 c2                	mov    %eax,%edx
  801e2b:	c1 ea 1f             	shr    $0x1f,%edx
  801e2e:	84 d2                	test   %dl,%dl
  801e30:	75 2d                	jne    801e5f <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e32:	85 f6                	test   %esi,%esi
  801e34:	74 0d                	je     801e43 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e36:	a1 08 40 80 00       	mov    0x804008,%eax
  801e3b:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  801e41:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e43:	85 db                	test   %ebx,%ebx
  801e45:	74 0d                	je     801e54 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e47:	a1 08 40 80 00       	mov    0x804008,%eax
  801e4c:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  801e52:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e54:	a1 08 40 80 00       	mov    0x804008,%eax
  801e59:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  801e5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e62:	5b                   	pop    %ebx
  801e63:	5e                   	pop    %esi
  801e64:	5d                   	pop    %ebp
  801e65:	c3                   	ret    

00801e66 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e66:	55                   	push   %ebp
  801e67:	89 e5                	mov    %esp,%ebp
  801e69:	57                   	push   %edi
  801e6a:	56                   	push   %esi
  801e6b:	53                   	push   %ebx
  801e6c:	83 ec 0c             	sub    $0xc,%esp
  801e6f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e72:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e75:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801e78:	85 db                	test   %ebx,%ebx
  801e7a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e7f:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e82:	ff 75 14             	pushl  0x14(%ebp)
  801e85:	53                   	push   %ebx
  801e86:	56                   	push   %esi
  801e87:	57                   	push   %edi
  801e88:	e8 fe ed ff ff       	call   800c8b <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801e8d:	89 c2                	mov    %eax,%edx
  801e8f:	c1 ea 1f             	shr    $0x1f,%edx
  801e92:	83 c4 10             	add    $0x10,%esp
  801e95:	84 d2                	test   %dl,%dl
  801e97:	74 17                	je     801eb0 <ipc_send+0x4a>
  801e99:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e9c:	74 12                	je     801eb0 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801e9e:	50                   	push   %eax
  801e9f:	68 ca 26 80 00       	push   $0x8026ca
  801ea4:	6a 47                	push   $0x47
  801ea6:	68 d8 26 80 00       	push   $0x8026d8
  801eab:	e8 66 fe ff ff       	call   801d16 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801eb0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801eb3:	75 07                	jne    801ebc <ipc_send+0x56>
			sys_yield();
  801eb5:	e8 25 ec ff ff       	call   800adf <sys_yield>
  801eba:	eb c6                	jmp    801e82 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801ebc:	85 c0                	test   %eax,%eax
  801ebe:	75 c2                	jne    801e82 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801ec0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ec3:	5b                   	pop    %ebx
  801ec4:	5e                   	pop    %esi
  801ec5:	5f                   	pop    %edi
  801ec6:	5d                   	pop    %ebp
  801ec7:	c3                   	ret    

00801ec8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ec8:	55                   	push   %ebp
  801ec9:	89 e5                	mov    %esp,%ebp
  801ecb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ece:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ed3:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  801ed9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801edf:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801ee5:	39 ca                	cmp    %ecx,%edx
  801ee7:	75 10                	jne    801ef9 <ipc_find_env+0x31>
			return envs[i].env_id;
  801ee9:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  801eef:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ef4:	8b 40 7c             	mov    0x7c(%eax),%eax
  801ef7:	eb 0f                	jmp    801f08 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ef9:	83 c0 01             	add    $0x1,%eax
  801efc:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f01:	75 d0                	jne    801ed3 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f08:	5d                   	pop    %ebp
  801f09:	c3                   	ret    

00801f0a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f0a:	55                   	push   %ebp
  801f0b:	89 e5                	mov    %esp,%ebp
  801f0d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f10:	89 d0                	mov    %edx,%eax
  801f12:	c1 e8 16             	shr    $0x16,%eax
  801f15:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f1c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f21:	f6 c1 01             	test   $0x1,%cl
  801f24:	74 1d                	je     801f43 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f26:	c1 ea 0c             	shr    $0xc,%edx
  801f29:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f30:	f6 c2 01             	test   $0x1,%dl
  801f33:	74 0e                	je     801f43 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f35:	c1 ea 0c             	shr    $0xc,%edx
  801f38:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f3f:	ef 
  801f40:	0f b7 c0             	movzwl %ax,%eax
}
  801f43:	5d                   	pop    %ebp
  801f44:	c3                   	ret    
  801f45:	66 90                	xchg   %ax,%ax
  801f47:	66 90                	xchg   %ax,%ax
  801f49:	66 90                	xchg   %ax,%ax
  801f4b:	66 90                	xchg   %ax,%ax
  801f4d:	66 90                	xchg   %ax,%ax
  801f4f:	90                   	nop

00801f50 <__udivdi3>:
  801f50:	55                   	push   %ebp
  801f51:	57                   	push   %edi
  801f52:	56                   	push   %esi
  801f53:	53                   	push   %ebx
  801f54:	83 ec 1c             	sub    $0x1c,%esp
  801f57:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f5b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f5f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f67:	85 f6                	test   %esi,%esi
  801f69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f6d:	89 ca                	mov    %ecx,%edx
  801f6f:	89 f8                	mov    %edi,%eax
  801f71:	75 3d                	jne    801fb0 <__udivdi3+0x60>
  801f73:	39 cf                	cmp    %ecx,%edi
  801f75:	0f 87 c5 00 00 00    	ja     802040 <__udivdi3+0xf0>
  801f7b:	85 ff                	test   %edi,%edi
  801f7d:	89 fd                	mov    %edi,%ebp
  801f7f:	75 0b                	jne    801f8c <__udivdi3+0x3c>
  801f81:	b8 01 00 00 00       	mov    $0x1,%eax
  801f86:	31 d2                	xor    %edx,%edx
  801f88:	f7 f7                	div    %edi
  801f8a:	89 c5                	mov    %eax,%ebp
  801f8c:	89 c8                	mov    %ecx,%eax
  801f8e:	31 d2                	xor    %edx,%edx
  801f90:	f7 f5                	div    %ebp
  801f92:	89 c1                	mov    %eax,%ecx
  801f94:	89 d8                	mov    %ebx,%eax
  801f96:	89 cf                	mov    %ecx,%edi
  801f98:	f7 f5                	div    %ebp
  801f9a:	89 c3                	mov    %eax,%ebx
  801f9c:	89 d8                	mov    %ebx,%eax
  801f9e:	89 fa                	mov    %edi,%edx
  801fa0:	83 c4 1c             	add    $0x1c,%esp
  801fa3:	5b                   	pop    %ebx
  801fa4:	5e                   	pop    %esi
  801fa5:	5f                   	pop    %edi
  801fa6:	5d                   	pop    %ebp
  801fa7:	c3                   	ret    
  801fa8:	90                   	nop
  801fa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fb0:	39 ce                	cmp    %ecx,%esi
  801fb2:	77 74                	ja     802028 <__udivdi3+0xd8>
  801fb4:	0f bd fe             	bsr    %esi,%edi
  801fb7:	83 f7 1f             	xor    $0x1f,%edi
  801fba:	0f 84 98 00 00 00    	je     802058 <__udivdi3+0x108>
  801fc0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fc5:	89 f9                	mov    %edi,%ecx
  801fc7:	89 c5                	mov    %eax,%ebp
  801fc9:	29 fb                	sub    %edi,%ebx
  801fcb:	d3 e6                	shl    %cl,%esi
  801fcd:	89 d9                	mov    %ebx,%ecx
  801fcf:	d3 ed                	shr    %cl,%ebp
  801fd1:	89 f9                	mov    %edi,%ecx
  801fd3:	d3 e0                	shl    %cl,%eax
  801fd5:	09 ee                	or     %ebp,%esi
  801fd7:	89 d9                	mov    %ebx,%ecx
  801fd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fdd:	89 d5                	mov    %edx,%ebp
  801fdf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fe3:	d3 ed                	shr    %cl,%ebp
  801fe5:	89 f9                	mov    %edi,%ecx
  801fe7:	d3 e2                	shl    %cl,%edx
  801fe9:	89 d9                	mov    %ebx,%ecx
  801feb:	d3 e8                	shr    %cl,%eax
  801fed:	09 c2                	or     %eax,%edx
  801fef:	89 d0                	mov    %edx,%eax
  801ff1:	89 ea                	mov    %ebp,%edx
  801ff3:	f7 f6                	div    %esi
  801ff5:	89 d5                	mov    %edx,%ebp
  801ff7:	89 c3                	mov    %eax,%ebx
  801ff9:	f7 64 24 0c          	mull   0xc(%esp)
  801ffd:	39 d5                	cmp    %edx,%ebp
  801fff:	72 10                	jb     802011 <__udivdi3+0xc1>
  802001:	8b 74 24 08          	mov    0x8(%esp),%esi
  802005:	89 f9                	mov    %edi,%ecx
  802007:	d3 e6                	shl    %cl,%esi
  802009:	39 c6                	cmp    %eax,%esi
  80200b:	73 07                	jae    802014 <__udivdi3+0xc4>
  80200d:	39 d5                	cmp    %edx,%ebp
  80200f:	75 03                	jne    802014 <__udivdi3+0xc4>
  802011:	83 eb 01             	sub    $0x1,%ebx
  802014:	31 ff                	xor    %edi,%edi
  802016:	89 d8                	mov    %ebx,%eax
  802018:	89 fa                	mov    %edi,%edx
  80201a:	83 c4 1c             	add    $0x1c,%esp
  80201d:	5b                   	pop    %ebx
  80201e:	5e                   	pop    %esi
  80201f:	5f                   	pop    %edi
  802020:	5d                   	pop    %ebp
  802021:	c3                   	ret    
  802022:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802028:	31 ff                	xor    %edi,%edi
  80202a:	31 db                	xor    %ebx,%ebx
  80202c:	89 d8                	mov    %ebx,%eax
  80202e:	89 fa                	mov    %edi,%edx
  802030:	83 c4 1c             	add    $0x1c,%esp
  802033:	5b                   	pop    %ebx
  802034:	5e                   	pop    %esi
  802035:	5f                   	pop    %edi
  802036:	5d                   	pop    %ebp
  802037:	c3                   	ret    
  802038:	90                   	nop
  802039:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802040:	89 d8                	mov    %ebx,%eax
  802042:	f7 f7                	div    %edi
  802044:	31 ff                	xor    %edi,%edi
  802046:	89 c3                	mov    %eax,%ebx
  802048:	89 d8                	mov    %ebx,%eax
  80204a:	89 fa                	mov    %edi,%edx
  80204c:	83 c4 1c             	add    $0x1c,%esp
  80204f:	5b                   	pop    %ebx
  802050:	5e                   	pop    %esi
  802051:	5f                   	pop    %edi
  802052:	5d                   	pop    %ebp
  802053:	c3                   	ret    
  802054:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802058:	39 ce                	cmp    %ecx,%esi
  80205a:	72 0c                	jb     802068 <__udivdi3+0x118>
  80205c:	31 db                	xor    %ebx,%ebx
  80205e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802062:	0f 87 34 ff ff ff    	ja     801f9c <__udivdi3+0x4c>
  802068:	bb 01 00 00 00       	mov    $0x1,%ebx
  80206d:	e9 2a ff ff ff       	jmp    801f9c <__udivdi3+0x4c>
  802072:	66 90                	xchg   %ax,%ax
  802074:	66 90                	xchg   %ax,%ax
  802076:	66 90                	xchg   %ax,%ax
  802078:	66 90                	xchg   %ax,%ax
  80207a:	66 90                	xchg   %ax,%ax
  80207c:	66 90                	xchg   %ax,%ax
  80207e:	66 90                	xchg   %ax,%ax

00802080 <__umoddi3>:
  802080:	55                   	push   %ebp
  802081:	57                   	push   %edi
  802082:	56                   	push   %esi
  802083:	53                   	push   %ebx
  802084:	83 ec 1c             	sub    $0x1c,%esp
  802087:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80208b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80208f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802093:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802097:	85 d2                	test   %edx,%edx
  802099:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80209d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020a1:	89 f3                	mov    %esi,%ebx
  8020a3:	89 3c 24             	mov    %edi,(%esp)
  8020a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020aa:	75 1c                	jne    8020c8 <__umoddi3+0x48>
  8020ac:	39 f7                	cmp    %esi,%edi
  8020ae:	76 50                	jbe    802100 <__umoddi3+0x80>
  8020b0:	89 c8                	mov    %ecx,%eax
  8020b2:	89 f2                	mov    %esi,%edx
  8020b4:	f7 f7                	div    %edi
  8020b6:	89 d0                	mov    %edx,%eax
  8020b8:	31 d2                	xor    %edx,%edx
  8020ba:	83 c4 1c             	add    $0x1c,%esp
  8020bd:	5b                   	pop    %ebx
  8020be:	5e                   	pop    %esi
  8020bf:	5f                   	pop    %edi
  8020c0:	5d                   	pop    %ebp
  8020c1:	c3                   	ret    
  8020c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020c8:	39 f2                	cmp    %esi,%edx
  8020ca:	89 d0                	mov    %edx,%eax
  8020cc:	77 52                	ja     802120 <__umoddi3+0xa0>
  8020ce:	0f bd ea             	bsr    %edx,%ebp
  8020d1:	83 f5 1f             	xor    $0x1f,%ebp
  8020d4:	75 5a                	jne    802130 <__umoddi3+0xb0>
  8020d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020da:	0f 82 e0 00 00 00    	jb     8021c0 <__umoddi3+0x140>
  8020e0:	39 0c 24             	cmp    %ecx,(%esp)
  8020e3:	0f 86 d7 00 00 00    	jbe    8021c0 <__umoddi3+0x140>
  8020e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020f1:	83 c4 1c             	add    $0x1c,%esp
  8020f4:	5b                   	pop    %ebx
  8020f5:	5e                   	pop    %esi
  8020f6:	5f                   	pop    %edi
  8020f7:	5d                   	pop    %ebp
  8020f8:	c3                   	ret    
  8020f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802100:	85 ff                	test   %edi,%edi
  802102:	89 fd                	mov    %edi,%ebp
  802104:	75 0b                	jne    802111 <__umoddi3+0x91>
  802106:	b8 01 00 00 00       	mov    $0x1,%eax
  80210b:	31 d2                	xor    %edx,%edx
  80210d:	f7 f7                	div    %edi
  80210f:	89 c5                	mov    %eax,%ebp
  802111:	89 f0                	mov    %esi,%eax
  802113:	31 d2                	xor    %edx,%edx
  802115:	f7 f5                	div    %ebp
  802117:	89 c8                	mov    %ecx,%eax
  802119:	f7 f5                	div    %ebp
  80211b:	89 d0                	mov    %edx,%eax
  80211d:	eb 99                	jmp    8020b8 <__umoddi3+0x38>
  80211f:	90                   	nop
  802120:	89 c8                	mov    %ecx,%eax
  802122:	89 f2                	mov    %esi,%edx
  802124:	83 c4 1c             	add    $0x1c,%esp
  802127:	5b                   	pop    %ebx
  802128:	5e                   	pop    %esi
  802129:	5f                   	pop    %edi
  80212a:	5d                   	pop    %ebp
  80212b:	c3                   	ret    
  80212c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802130:	8b 34 24             	mov    (%esp),%esi
  802133:	bf 20 00 00 00       	mov    $0x20,%edi
  802138:	89 e9                	mov    %ebp,%ecx
  80213a:	29 ef                	sub    %ebp,%edi
  80213c:	d3 e0                	shl    %cl,%eax
  80213e:	89 f9                	mov    %edi,%ecx
  802140:	89 f2                	mov    %esi,%edx
  802142:	d3 ea                	shr    %cl,%edx
  802144:	89 e9                	mov    %ebp,%ecx
  802146:	09 c2                	or     %eax,%edx
  802148:	89 d8                	mov    %ebx,%eax
  80214a:	89 14 24             	mov    %edx,(%esp)
  80214d:	89 f2                	mov    %esi,%edx
  80214f:	d3 e2                	shl    %cl,%edx
  802151:	89 f9                	mov    %edi,%ecx
  802153:	89 54 24 04          	mov    %edx,0x4(%esp)
  802157:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80215b:	d3 e8                	shr    %cl,%eax
  80215d:	89 e9                	mov    %ebp,%ecx
  80215f:	89 c6                	mov    %eax,%esi
  802161:	d3 e3                	shl    %cl,%ebx
  802163:	89 f9                	mov    %edi,%ecx
  802165:	89 d0                	mov    %edx,%eax
  802167:	d3 e8                	shr    %cl,%eax
  802169:	89 e9                	mov    %ebp,%ecx
  80216b:	09 d8                	or     %ebx,%eax
  80216d:	89 d3                	mov    %edx,%ebx
  80216f:	89 f2                	mov    %esi,%edx
  802171:	f7 34 24             	divl   (%esp)
  802174:	89 d6                	mov    %edx,%esi
  802176:	d3 e3                	shl    %cl,%ebx
  802178:	f7 64 24 04          	mull   0x4(%esp)
  80217c:	39 d6                	cmp    %edx,%esi
  80217e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802182:	89 d1                	mov    %edx,%ecx
  802184:	89 c3                	mov    %eax,%ebx
  802186:	72 08                	jb     802190 <__umoddi3+0x110>
  802188:	75 11                	jne    80219b <__umoddi3+0x11b>
  80218a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80218e:	73 0b                	jae    80219b <__umoddi3+0x11b>
  802190:	2b 44 24 04          	sub    0x4(%esp),%eax
  802194:	1b 14 24             	sbb    (%esp),%edx
  802197:	89 d1                	mov    %edx,%ecx
  802199:	89 c3                	mov    %eax,%ebx
  80219b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80219f:	29 da                	sub    %ebx,%edx
  8021a1:	19 ce                	sbb    %ecx,%esi
  8021a3:	89 f9                	mov    %edi,%ecx
  8021a5:	89 f0                	mov    %esi,%eax
  8021a7:	d3 e0                	shl    %cl,%eax
  8021a9:	89 e9                	mov    %ebp,%ecx
  8021ab:	d3 ea                	shr    %cl,%edx
  8021ad:	89 e9                	mov    %ebp,%ecx
  8021af:	d3 ee                	shr    %cl,%esi
  8021b1:	09 d0                	or     %edx,%eax
  8021b3:	89 f2                	mov    %esi,%edx
  8021b5:	83 c4 1c             	add    $0x1c,%esp
  8021b8:	5b                   	pop    %ebx
  8021b9:	5e                   	pop    %esi
  8021ba:	5f                   	pop    %edi
  8021bb:	5d                   	pop    %ebp
  8021bc:	c3                   	ret    
  8021bd:	8d 76 00             	lea    0x0(%esi),%esi
  8021c0:	29 f9                	sub    %edi,%ecx
  8021c2:	19 d6                	sbb    %edx,%esi
  8021c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021cc:	e9 18 ff ff ff       	jmp    8020e9 <__umoddi3+0x69>
