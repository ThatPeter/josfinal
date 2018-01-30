
obj/user/yield.debug:     file format elf32-i386


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
  80002c:	e8 72 00 00 00       	call   8000a3 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003a:	a1 04 40 80 00       	mov    0x804004,%eax
  80003f:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800045:	50                   	push   %eax
  800046:	68 60 24 80 00       	push   $0x802460
  80004b:	e8 69 01 00 00       	call   8001b9 <cprintf>
  800050:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800053:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800058:	e8 c5 0a 00 00       	call   800b22 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005d:	a1 04 40 80 00       	mov    0x804004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  800062:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800068:	83 ec 04             	sub    $0x4,%esp
  80006b:	53                   	push   %ebx
  80006c:	50                   	push   %eax
  80006d:	68 80 24 80 00       	push   $0x802480
  800072:	e8 42 01 00 00       	call   8001b9 <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800077:	83 c3 01             	add    $0x1,%ebx
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	83 fb 05             	cmp    $0x5,%ebx
  800080:	75 d6                	jne    800058 <umain+0x25>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  800082:	a1 04 40 80 00       	mov    0x804004,%eax
  800087:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80008d:	83 ec 08             	sub    $0x8,%esp
  800090:	50                   	push   %eax
  800091:	68 ac 24 80 00       	push   $0x8024ac
  800096:	e8 1e 01 00 00       	call   8001b9 <cprintf>
}
  80009b:	83 c4 10             	add    $0x10,%esp
  80009e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000a1:	c9                   	leave  
  8000a2:	c3                   	ret    

008000a3 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a3:	55                   	push   %ebp
  8000a4:	89 e5                	mov    %esp,%ebp
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
  8000a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000ab:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ae:	e8 50 0a 00 00       	call   800b03 <sys_getenvid>
  8000b3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b8:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8000be:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c3:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c8:	85 db                	test   %ebx,%ebx
  8000ca:	7e 07                	jle    8000d3 <libmain+0x30>
		binaryname = argv[0];
  8000cc:	8b 06                	mov    (%esi),%eax
  8000ce:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000d3:	83 ec 08             	sub    $0x8,%esp
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
  8000d8:	e8 56 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000dd:	e8 2a 00 00 00       	call   80010c <exit>
}
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e8:	5b                   	pop    %ebx
  8000e9:	5e                   	pop    %esi
  8000ea:	5d                   	pop    %ebp
  8000eb:	c3                   	ret    

008000ec <thread_main>:

/*Lab 7: Multithreading thread main routine*/
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	83 ec 08             	sub    $0x8,%esp
	void (*func)(void) = (void (*)(void))eip;
  8000f2:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  8000f7:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8000f9:	e8 05 0a 00 00       	call   800b03 <sys_getenvid>
  8000fe:	83 ec 0c             	sub    $0xc,%esp
  800101:	50                   	push   %eax
  800102:	e8 4b 0c 00 00       	call   800d52 <sys_thread_free>
}
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	c9                   	leave  
  80010b:	c3                   	ret    

0080010c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80010c:	55                   	push   %ebp
  80010d:	89 e5                	mov    %esp,%ebp
  80010f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800112:	e8 43 13 00 00       	call   80145a <close_all>
	sys_env_destroy(0);
  800117:	83 ec 0c             	sub    $0xc,%esp
  80011a:	6a 00                	push   $0x0
  80011c:	e8 a1 09 00 00       	call   800ac2 <sys_env_destroy>
}
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	c9                   	leave  
  800125:	c3                   	ret    

00800126 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800126:	55                   	push   %ebp
  800127:	89 e5                	mov    %esp,%ebp
  800129:	53                   	push   %ebx
  80012a:	83 ec 04             	sub    $0x4,%esp
  80012d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800130:	8b 13                	mov    (%ebx),%edx
  800132:	8d 42 01             	lea    0x1(%edx),%eax
  800135:	89 03                	mov    %eax,(%ebx)
  800137:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80013a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80013e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800143:	75 1a                	jne    80015f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800145:	83 ec 08             	sub    $0x8,%esp
  800148:	68 ff 00 00 00       	push   $0xff
  80014d:	8d 43 08             	lea    0x8(%ebx),%eax
  800150:	50                   	push   %eax
  800151:	e8 2f 09 00 00       	call   800a85 <sys_cputs>
		b->idx = 0;
  800156:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80015c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80015f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800163:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800166:	c9                   	leave  
  800167:	c3                   	ret    

00800168 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800171:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800178:	00 00 00 
	b.cnt = 0;
  80017b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800182:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800185:	ff 75 0c             	pushl  0xc(%ebp)
  800188:	ff 75 08             	pushl  0x8(%ebp)
  80018b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800191:	50                   	push   %eax
  800192:	68 26 01 80 00       	push   $0x800126
  800197:	e8 54 01 00 00       	call   8002f0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80019c:	83 c4 08             	add    $0x8,%esp
  80019f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ab:	50                   	push   %eax
  8001ac:	e8 d4 08 00 00       	call   800a85 <sys_cputs>

	return b.cnt;
}
  8001b1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b7:	c9                   	leave  
  8001b8:	c3                   	ret    

008001b9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b9:	55                   	push   %ebp
  8001ba:	89 e5                	mov    %esp,%ebp
  8001bc:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001bf:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001c2:	50                   	push   %eax
  8001c3:	ff 75 08             	pushl  0x8(%ebp)
  8001c6:	e8 9d ff ff ff       	call   800168 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001cb:	c9                   	leave  
  8001cc:	c3                   	ret    

008001cd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001cd:	55                   	push   %ebp
  8001ce:	89 e5                	mov    %esp,%ebp
  8001d0:	57                   	push   %edi
  8001d1:	56                   	push   %esi
  8001d2:	53                   	push   %ebx
  8001d3:	83 ec 1c             	sub    $0x1c,%esp
  8001d6:	89 c7                	mov    %eax,%edi
  8001d8:	89 d6                	mov    %edx,%esi
  8001da:	8b 45 08             	mov    0x8(%ebp),%eax
  8001dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e3:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ee:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001f1:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001f4:	39 d3                	cmp    %edx,%ebx
  8001f6:	72 05                	jb     8001fd <printnum+0x30>
  8001f8:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001fb:	77 45                	ja     800242 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001fd:	83 ec 0c             	sub    $0xc,%esp
  800200:	ff 75 18             	pushl  0x18(%ebp)
  800203:	8b 45 14             	mov    0x14(%ebp),%eax
  800206:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800209:	53                   	push   %ebx
  80020a:	ff 75 10             	pushl  0x10(%ebp)
  80020d:	83 ec 08             	sub    $0x8,%esp
  800210:	ff 75 e4             	pushl  -0x1c(%ebp)
  800213:	ff 75 e0             	pushl  -0x20(%ebp)
  800216:	ff 75 dc             	pushl  -0x24(%ebp)
  800219:	ff 75 d8             	pushl  -0x28(%ebp)
  80021c:	e8 9f 1f 00 00       	call   8021c0 <__udivdi3>
  800221:	83 c4 18             	add    $0x18,%esp
  800224:	52                   	push   %edx
  800225:	50                   	push   %eax
  800226:	89 f2                	mov    %esi,%edx
  800228:	89 f8                	mov    %edi,%eax
  80022a:	e8 9e ff ff ff       	call   8001cd <printnum>
  80022f:	83 c4 20             	add    $0x20,%esp
  800232:	eb 18                	jmp    80024c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800234:	83 ec 08             	sub    $0x8,%esp
  800237:	56                   	push   %esi
  800238:	ff 75 18             	pushl  0x18(%ebp)
  80023b:	ff d7                	call   *%edi
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	eb 03                	jmp    800245 <printnum+0x78>
  800242:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800245:	83 eb 01             	sub    $0x1,%ebx
  800248:	85 db                	test   %ebx,%ebx
  80024a:	7f e8                	jg     800234 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80024c:	83 ec 08             	sub    $0x8,%esp
  80024f:	56                   	push   %esi
  800250:	83 ec 04             	sub    $0x4,%esp
  800253:	ff 75 e4             	pushl  -0x1c(%ebp)
  800256:	ff 75 e0             	pushl  -0x20(%ebp)
  800259:	ff 75 dc             	pushl  -0x24(%ebp)
  80025c:	ff 75 d8             	pushl  -0x28(%ebp)
  80025f:	e8 8c 20 00 00       	call   8022f0 <__umoddi3>
  800264:	83 c4 14             	add    $0x14,%esp
  800267:	0f be 80 d5 24 80 00 	movsbl 0x8024d5(%eax),%eax
  80026e:	50                   	push   %eax
  80026f:	ff d7                	call   *%edi
}
  800271:	83 c4 10             	add    $0x10,%esp
  800274:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800277:	5b                   	pop    %ebx
  800278:	5e                   	pop    %esi
  800279:	5f                   	pop    %edi
  80027a:	5d                   	pop    %ebp
  80027b:	c3                   	ret    

0080027c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80027f:	83 fa 01             	cmp    $0x1,%edx
  800282:	7e 0e                	jle    800292 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800284:	8b 10                	mov    (%eax),%edx
  800286:	8d 4a 08             	lea    0x8(%edx),%ecx
  800289:	89 08                	mov    %ecx,(%eax)
  80028b:	8b 02                	mov    (%edx),%eax
  80028d:	8b 52 04             	mov    0x4(%edx),%edx
  800290:	eb 22                	jmp    8002b4 <getuint+0x38>
	else if (lflag)
  800292:	85 d2                	test   %edx,%edx
  800294:	74 10                	je     8002a6 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800296:	8b 10                	mov    (%eax),%edx
  800298:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029b:	89 08                	mov    %ecx,(%eax)
  80029d:	8b 02                	mov    (%edx),%eax
  80029f:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a4:	eb 0e                	jmp    8002b4 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a6:	8b 10                	mov    (%eax),%edx
  8002a8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ab:	89 08                	mov    %ecx,(%eax)
  8002ad:	8b 02                	mov    (%edx),%eax
  8002af:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002b4:	5d                   	pop    %ebp
  8002b5:	c3                   	ret    

008002b6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
  8002b9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002bc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002c0:	8b 10                	mov    (%eax),%edx
  8002c2:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c5:	73 0a                	jae    8002d1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ca:	89 08                	mov    %ecx,(%eax)
  8002cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cf:	88 02                	mov    %al,(%edx)
}
  8002d1:	5d                   	pop    %ebp
  8002d2:	c3                   	ret    

008002d3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002d3:	55                   	push   %ebp
  8002d4:	89 e5                	mov    %esp,%ebp
  8002d6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002dc:	50                   	push   %eax
  8002dd:	ff 75 10             	pushl  0x10(%ebp)
  8002e0:	ff 75 0c             	pushl  0xc(%ebp)
  8002e3:	ff 75 08             	pushl  0x8(%ebp)
  8002e6:	e8 05 00 00 00       	call   8002f0 <vprintfmt>
	va_end(ap);
}
  8002eb:	83 c4 10             	add    $0x10,%esp
  8002ee:	c9                   	leave  
  8002ef:	c3                   	ret    

008002f0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
  8002f6:	83 ec 2c             	sub    $0x2c,%esp
  8002f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8002fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ff:	8b 7d 10             	mov    0x10(%ebp),%edi
  800302:	eb 12                	jmp    800316 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800304:	85 c0                	test   %eax,%eax
  800306:	0f 84 89 03 00 00    	je     800695 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80030c:	83 ec 08             	sub    $0x8,%esp
  80030f:	53                   	push   %ebx
  800310:	50                   	push   %eax
  800311:	ff d6                	call   *%esi
  800313:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800316:	83 c7 01             	add    $0x1,%edi
  800319:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80031d:	83 f8 25             	cmp    $0x25,%eax
  800320:	75 e2                	jne    800304 <vprintfmt+0x14>
  800322:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800326:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80032d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800334:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80033b:	ba 00 00 00 00       	mov    $0x0,%edx
  800340:	eb 07                	jmp    800349 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800342:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800345:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800349:	8d 47 01             	lea    0x1(%edi),%eax
  80034c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034f:	0f b6 07             	movzbl (%edi),%eax
  800352:	0f b6 c8             	movzbl %al,%ecx
  800355:	83 e8 23             	sub    $0x23,%eax
  800358:	3c 55                	cmp    $0x55,%al
  80035a:	0f 87 1a 03 00 00    	ja     80067a <vprintfmt+0x38a>
  800360:	0f b6 c0             	movzbl %al,%eax
  800363:	ff 24 85 20 26 80 00 	jmp    *0x802620(,%eax,4)
  80036a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80036d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800371:	eb d6                	jmp    800349 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800373:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800376:	b8 00 00 00 00       	mov    $0x0,%eax
  80037b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80037e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800381:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800385:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800388:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80038b:	83 fa 09             	cmp    $0x9,%edx
  80038e:	77 39                	ja     8003c9 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800390:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800393:	eb e9                	jmp    80037e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800395:	8b 45 14             	mov    0x14(%ebp),%eax
  800398:	8d 48 04             	lea    0x4(%eax),%ecx
  80039b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80039e:	8b 00                	mov    (%eax),%eax
  8003a0:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003a6:	eb 27                	jmp    8003cf <vprintfmt+0xdf>
  8003a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ab:	85 c0                	test   %eax,%eax
  8003ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b2:	0f 49 c8             	cmovns %eax,%ecx
  8003b5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003bb:	eb 8c                	jmp    800349 <vprintfmt+0x59>
  8003bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003c0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c7:	eb 80                	jmp    800349 <vprintfmt+0x59>
  8003c9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003cc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003cf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d3:	0f 89 70 ff ff ff    	jns    800349 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003d9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003df:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e6:	e9 5e ff ff ff       	jmp    800349 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003eb:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003f1:	e9 53 ff ff ff       	jmp    800349 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f9:	8d 50 04             	lea    0x4(%eax),%edx
  8003fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ff:	83 ec 08             	sub    $0x8,%esp
  800402:	53                   	push   %ebx
  800403:	ff 30                	pushl  (%eax)
  800405:	ff d6                	call   *%esi
			break;
  800407:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80040d:	e9 04 ff ff ff       	jmp    800316 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800412:	8b 45 14             	mov    0x14(%ebp),%eax
  800415:	8d 50 04             	lea    0x4(%eax),%edx
  800418:	89 55 14             	mov    %edx,0x14(%ebp)
  80041b:	8b 00                	mov    (%eax),%eax
  80041d:	99                   	cltd   
  80041e:	31 d0                	xor    %edx,%eax
  800420:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800422:	83 f8 0f             	cmp    $0xf,%eax
  800425:	7f 0b                	jg     800432 <vprintfmt+0x142>
  800427:	8b 14 85 80 27 80 00 	mov    0x802780(,%eax,4),%edx
  80042e:	85 d2                	test   %edx,%edx
  800430:	75 18                	jne    80044a <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800432:	50                   	push   %eax
  800433:	68 ed 24 80 00       	push   $0x8024ed
  800438:	53                   	push   %ebx
  800439:	56                   	push   %esi
  80043a:	e8 94 fe ff ff       	call   8002d3 <printfmt>
  80043f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800445:	e9 cc fe ff ff       	jmp    800316 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80044a:	52                   	push   %edx
  80044b:	68 3d 29 80 00       	push   $0x80293d
  800450:	53                   	push   %ebx
  800451:	56                   	push   %esi
  800452:	e8 7c fe ff ff       	call   8002d3 <printfmt>
  800457:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80045d:	e9 b4 fe ff ff       	jmp    800316 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800462:	8b 45 14             	mov    0x14(%ebp),%eax
  800465:	8d 50 04             	lea    0x4(%eax),%edx
  800468:	89 55 14             	mov    %edx,0x14(%ebp)
  80046b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80046d:	85 ff                	test   %edi,%edi
  80046f:	b8 e6 24 80 00       	mov    $0x8024e6,%eax
  800474:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800477:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80047b:	0f 8e 94 00 00 00    	jle    800515 <vprintfmt+0x225>
  800481:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800485:	0f 84 98 00 00 00    	je     800523 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80048b:	83 ec 08             	sub    $0x8,%esp
  80048e:	ff 75 d0             	pushl  -0x30(%ebp)
  800491:	57                   	push   %edi
  800492:	e8 86 02 00 00       	call   80071d <strnlen>
  800497:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80049a:	29 c1                	sub    %eax,%ecx
  80049c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80049f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004a2:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004ac:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ae:	eb 0f                	jmp    8004bf <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004b0:	83 ec 08             	sub    $0x8,%esp
  8004b3:	53                   	push   %ebx
  8004b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b7:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b9:	83 ef 01             	sub    $0x1,%edi
  8004bc:	83 c4 10             	add    $0x10,%esp
  8004bf:	85 ff                	test   %edi,%edi
  8004c1:	7f ed                	jg     8004b0 <vprintfmt+0x1c0>
  8004c3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004c6:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004c9:	85 c9                	test   %ecx,%ecx
  8004cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d0:	0f 49 c1             	cmovns %ecx,%eax
  8004d3:	29 c1                	sub    %eax,%ecx
  8004d5:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004db:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004de:	89 cb                	mov    %ecx,%ebx
  8004e0:	eb 4d                	jmp    80052f <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004e2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e6:	74 1b                	je     800503 <vprintfmt+0x213>
  8004e8:	0f be c0             	movsbl %al,%eax
  8004eb:	83 e8 20             	sub    $0x20,%eax
  8004ee:	83 f8 5e             	cmp    $0x5e,%eax
  8004f1:	76 10                	jbe    800503 <vprintfmt+0x213>
					putch('?', putdat);
  8004f3:	83 ec 08             	sub    $0x8,%esp
  8004f6:	ff 75 0c             	pushl  0xc(%ebp)
  8004f9:	6a 3f                	push   $0x3f
  8004fb:	ff 55 08             	call   *0x8(%ebp)
  8004fe:	83 c4 10             	add    $0x10,%esp
  800501:	eb 0d                	jmp    800510 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800503:	83 ec 08             	sub    $0x8,%esp
  800506:	ff 75 0c             	pushl  0xc(%ebp)
  800509:	52                   	push   %edx
  80050a:	ff 55 08             	call   *0x8(%ebp)
  80050d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800510:	83 eb 01             	sub    $0x1,%ebx
  800513:	eb 1a                	jmp    80052f <vprintfmt+0x23f>
  800515:	89 75 08             	mov    %esi,0x8(%ebp)
  800518:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80051b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800521:	eb 0c                	jmp    80052f <vprintfmt+0x23f>
  800523:	89 75 08             	mov    %esi,0x8(%ebp)
  800526:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800529:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80052c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80052f:	83 c7 01             	add    $0x1,%edi
  800532:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800536:	0f be d0             	movsbl %al,%edx
  800539:	85 d2                	test   %edx,%edx
  80053b:	74 23                	je     800560 <vprintfmt+0x270>
  80053d:	85 f6                	test   %esi,%esi
  80053f:	78 a1                	js     8004e2 <vprintfmt+0x1f2>
  800541:	83 ee 01             	sub    $0x1,%esi
  800544:	79 9c                	jns    8004e2 <vprintfmt+0x1f2>
  800546:	89 df                	mov    %ebx,%edi
  800548:	8b 75 08             	mov    0x8(%ebp),%esi
  80054b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80054e:	eb 18                	jmp    800568 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800550:	83 ec 08             	sub    $0x8,%esp
  800553:	53                   	push   %ebx
  800554:	6a 20                	push   $0x20
  800556:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800558:	83 ef 01             	sub    $0x1,%edi
  80055b:	83 c4 10             	add    $0x10,%esp
  80055e:	eb 08                	jmp    800568 <vprintfmt+0x278>
  800560:	89 df                	mov    %ebx,%edi
  800562:	8b 75 08             	mov    0x8(%ebp),%esi
  800565:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800568:	85 ff                	test   %edi,%edi
  80056a:	7f e4                	jg     800550 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80056f:	e9 a2 fd ff ff       	jmp    800316 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800574:	83 fa 01             	cmp    $0x1,%edx
  800577:	7e 16                	jle    80058f <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800579:	8b 45 14             	mov    0x14(%ebp),%eax
  80057c:	8d 50 08             	lea    0x8(%eax),%edx
  80057f:	89 55 14             	mov    %edx,0x14(%ebp)
  800582:	8b 50 04             	mov    0x4(%eax),%edx
  800585:	8b 00                	mov    (%eax),%eax
  800587:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80058d:	eb 32                	jmp    8005c1 <vprintfmt+0x2d1>
	else if (lflag)
  80058f:	85 d2                	test   %edx,%edx
  800591:	74 18                	je     8005ab <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800593:	8b 45 14             	mov    0x14(%ebp),%eax
  800596:	8d 50 04             	lea    0x4(%eax),%edx
  800599:	89 55 14             	mov    %edx,0x14(%ebp)
  80059c:	8b 00                	mov    (%eax),%eax
  80059e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a1:	89 c1                	mov    %eax,%ecx
  8005a3:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005a9:	eb 16                	jmp    8005c1 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ae:	8d 50 04             	lea    0x4(%eax),%edx
  8005b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b4:	8b 00                	mov    (%eax),%eax
  8005b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b9:	89 c1                	mov    %eax,%ecx
  8005bb:	c1 f9 1f             	sar    $0x1f,%ecx
  8005be:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005c1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005c4:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005cc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005d0:	79 74                	jns    800646 <vprintfmt+0x356>
				putch('-', putdat);
  8005d2:	83 ec 08             	sub    $0x8,%esp
  8005d5:	53                   	push   %ebx
  8005d6:	6a 2d                	push   $0x2d
  8005d8:	ff d6                	call   *%esi
				num = -(long long) num;
  8005da:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005dd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005e0:	f7 d8                	neg    %eax
  8005e2:	83 d2 00             	adc    $0x0,%edx
  8005e5:	f7 da                	neg    %edx
  8005e7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005ea:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005ef:	eb 55                	jmp    800646 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005f1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f4:	e8 83 fc ff ff       	call   80027c <getuint>
			base = 10;
  8005f9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005fe:	eb 46                	jmp    800646 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800600:	8d 45 14             	lea    0x14(%ebp),%eax
  800603:	e8 74 fc ff ff       	call   80027c <getuint>
			base = 8;
  800608:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80060d:	eb 37                	jmp    800646 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80060f:	83 ec 08             	sub    $0x8,%esp
  800612:	53                   	push   %ebx
  800613:	6a 30                	push   $0x30
  800615:	ff d6                	call   *%esi
			putch('x', putdat);
  800617:	83 c4 08             	add    $0x8,%esp
  80061a:	53                   	push   %ebx
  80061b:	6a 78                	push   $0x78
  80061d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80061f:	8b 45 14             	mov    0x14(%ebp),%eax
  800622:	8d 50 04             	lea    0x4(%eax),%edx
  800625:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800628:	8b 00                	mov    (%eax),%eax
  80062a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80062f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800632:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800637:	eb 0d                	jmp    800646 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800639:	8d 45 14             	lea    0x14(%ebp),%eax
  80063c:	e8 3b fc ff ff       	call   80027c <getuint>
			base = 16;
  800641:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800646:	83 ec 0c             	sub    $0xc,%esp
  800649:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80064d:	57                   	push   %edi
  80064e:	ff 75 e0             	pushl  -0x20(%ebp)
  800651:	51                   	push   %ecx
  800652:	52                   	push   %edx
  800653:	50                   	push   %eax
  800654:	89 da                	mov    %ebx,%edx
  800656:	89 f0                	mov    %esi,%eax
  800658:	e8 70 fb ff ff       	call   8001cd <printnum>
			break;
  80065d:	83 c4 20             	add    $0x20,%esp
  800660:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800663:	e9 ae fc ff ff       	jmp    800316 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	53                   	push   %ebx
  80066c:	51                   	push   %ecx
  80066d:	ff d6                	call   *%esi
			break;
  80066f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800672:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800675:	e9 9c fc ff ff       	jmp    800316 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80067a:	83 ec 08             	sub    $0x8,%esp
  80067d:	53                   	push   %ebx
  80067e:	6a 25                	push   $0x25
  800680:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800682:	83 c4 10             	add    $0x10,%esp
  800685:	eb 03                	jmp    80068a <vprintfmt+0x39a>
  800687:	83 ef 01             	sub    $0x1,%edi
  80068a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80068e:	75 f7                	jne    800687 <vprintfmt+0x397>
  800690:	e9 81 fc ff ff       	jmp    800316 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800695:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800698:	5b                   	pop    %ebx
  800699:	5e                   	pop    %esi
  80069a:	5f                   	pop    %edi
  80069b:	5d                   	pop    %ebp
  80069c:	c3                   	ret    

0080069d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80069d:	55                   	push   %ebp
  80069e:	89 e5                	mov    %esp,%ebp
  8006a0:	83 ec 18             	sub    $0x18,%esp
  8006a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ac:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006b0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006b3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ba:	85 c0                	test   %eax,%eax
  8006bc:	74 26                	je     8006e4 <vsnprintf+0x47>
  8006be:	85 d2                	test   %edx,%edx
  8006c0:	7e 22                	jle    8006e4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006c2:	ff 75 14             	pushl  0x14(%ebp)
  8006c5:	ff 75 10             	pushl  0x10(%ebp)
  8006c8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006cb:	50                   	push   %eax
  8006cc:	68 b6 02 80 00       	push   $0x8002b6
  8006d1:	e8 1a fc ff ff       	call   8002f0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006df:	83 c4 10             	add    $0x10,%esp
  8006e2:	eb 05                	jmp    8006e9 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e9:	c9                   	leave  
  8006ea:	c3                   	ret    

008006eb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006eb:	55                   	push   %ebp
  8006ec:	89 e5                	mov    %esp,%ebp
  8006ee:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006f1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006f4:	50                   	push   %eax
  8006f5:	ff 75 10             	pushl  0x10(%ebp)
  8006f8:	ff 75 0c             	pushl  0xc(%ebp)
  8006fb:	ff 75 08             	pushl  0x8(%ebp)
  8006fe:	e8 9a ff ff ff       	call   80069d <vsnprintf>
	va_end(ap);

	return rc;
}
  800703:	c9                   	leave  
  800704:	c3                   	ret    

00800705 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800705:	55                   	push   %ebp
  800706:	89 e5                	mov    %esp,%ebp
  800708:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80070b:	b8 00 00 00 00       	mov    $0x0,%eax
  800710:	eb 03                	jmp    800715 <strlen+0x10>
		n++;
  800712:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800715:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800719:	75 f7                	jne    800712 <strlen+0xd>
		n++;
	return n;
}
  80071b:	5d                   	pop    %ebp
  80071c:	c3                   	ret    

0080071d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80071d:	55                   	push   %ebp
  80071e:	89 e5                	mov    %esp,%ebp
  800720:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800723:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800726:	ba 00 00 00 00       	mov    $0x0,%edx
  80072b:	eb 03                	jmp    800730 <strnlen+0x13>
		n++;
  80072d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800730:	39 c2                	cmp    %eax,%edx
  800732:	74 08                	je     80073c <strnlen+0x1f>
  800734:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800738:	75 f3                	jne    80072d <strnlen+0x10>
  80073a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80073c:	5d                   	pop    %ebp
  80073d:	c3                   	ret    

0080073e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	53                   	push   %ebx
  800742:	8b 45 08             	mov    0x8(%ebp),%eax
  800745:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800748:	89 c2                	mov    %eax,%edx
  80074a:	83 c2 01             	add    $0x1,%edx
  80074d:	83 c1 01             	add    $0x1,%ecx
  800750:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800754:	88 5a ff             	mov    %bl,-0x1(%edx)
  800757:	84 db                	test   %bl,%bl
  800759:	75 ef                	jne    80074a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80075b:	5b                   	pop    %ebx
  80075c:	5d                   	pop    %ebp
  80075d:	c3                   	ret    

0080075e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	53                   	push   %ebx
  800762:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800765:	53                   	push   %ebx
  800766:	e8 9a ff ff ff       	call   800705 <strlen>
  80076b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80076e:	ff 75 0c             	pushl  0xc(%ebp)
  800771:	01 d8                	add    %ebx,%eax
  800773:	50                   	push   %eax
  800774:	e8 c5 ff ff ff       	call   80073e <strcpy>
	return dst;
}
  800779:	89 d8                	mov    %ebx,%eax
  80077b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80077e:	c9                   	leave  
  80077f:	c3                   	ret    

00800780 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	56                   	push   %esi
  800784:	53                   	push   %ebx
  800785:	8b 75 08             	mov    0x8(%ebp),%esi
  800788:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078b:	89 f3                	mov    %esi,%ebx
  80078d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800790:	89 f2                	mov    %esi,%edx
  800792:	eb 0f                	jmp    8007a3 <strncpy+0x23>
		*dst++ = *src;
  800794:	83 c2 01             	add    $0x1,%edx
  800797:	0f b6 01             	movzbl (%ecx),%eax
  80079a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80079d:	80 39 01             	cmpb   $0x1,(%ecx)
  8007a0:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a3:	39 da                	cmp    %ebx,%edx
  8007a5:	75 ed                	jne    800794 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007a7:	89 f0                	mov    %esi,%eax
  8007a9:	5b                   	pop    %ebx
  8007aa:	5e                   	pop    %esi
  8007ab:	5d                   	pop    %ebp
  8007ac:	c3                   	ret    

008007ad <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ad:	55                   	push   %ebp
  8007ae:	89 e5                	mov    %esp,%ebp
  8007b0:	56                   	push   %esi
  8007b1:	53                   	push   %ebx
  8007b2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b8:	8b 55 10             	mov    0x10(%ebp),%edx
  8007bb:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007bd:	85 d2                	test   %edx,%edx
  8007bf:	74 21                	je     8007e2 <strlcpy+0x35>
  8007c1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007c5:	89 f2                	mov    %esi,%edx
  8007c7:	eb 09                	jmp    8007d2 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c9:	83 c2 01             	add    $0x1,%edx
  8007cc:	83 c1 01             	add    $0x1,%ecx
  8007cf:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007d2:	39 c2                	cmp    %eax,%edx
  8007d4:	74 09                	je     8007df <strlcpy+0x32>
  8007d6:	0f b6 19             	movzbl (%ecx),%ebx
  8007d9:	84 db                	test   %bl,%bl
  8007db:	75 ec                	jne    8007c9 <strlcpy+0x1c>
  8007dd:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007df:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007e2:	29 f0                	sub    %esi,%eax
}
  8007e4:	5b                   	pop    %ebx
  8007e5:	5e                   	pop    %esi
  8007e6:	5d                   	pop    %ebp
  8007e7:	c3                   	ret    

008007e8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ee:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007f1:	eb 06                	jmp    8007f9 <strcmp+0x11>
		p++, q++;
  8007f3:	83 c1 01             	add    $0x1,%ecx
  8007f6:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f9:	0f b6 01             	movzbl (%ecx),%eax
  8007fc:	84 c0                	test   %al,%al
  8007fe:	74 04                	je     800804 <strcmp+0x1c>
  800800:	3a 02                	cmp    (%edx),%al
  800802:	74 ef                	je     8007f3 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800804:	0f b6 c0             	movzbl %al,%eax
  800807:	0f b6 12             	movzbl (%edx),%edx
  80080a:	29 d0                	sub    %edx,%eax
}
  80080c:	5d                   	pop    %ebp
  80080d:	c3                   	ret    

0080080e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	53                   	push   %ebx
  800812:	8b 45 08             	mov    0x8(%ebp),%eax
  800815:	8b 55 0c             	mov    0xc(%ebp),%edx
  800818:	89 c3                	mov    %eax,%ebx
  80081a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80081d:	eb 06                	jmp    800825 <strncmp+0x17>
		n--, p++, q++;
  80081f:	83 c0 01             	add    $0x1,%eax
  800822:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800825:	39 d8                	cmp    %ebx,%eax
  800827:	74 15                	je     80083e <strncmp+0x30>
  800829:	0f b6 08             	movzbl (%eax),%ecx
  80082c:	84 c9                	test   %cl,%cl
  80082e:	74 04                	je     800834 <strncmp+0x26>
  800830:	3a 0a                	cmp    (%edx),%cl
  800832:	74 eb                	je     80081f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800834:	0f b6 00             	movzbl (%eax),%eax
  800837:	0f b6 12             	movzbl (%edx),%edx
  80083a:	29 d0                	sub    %edx,%eax
  80083c:	eb 05                	jmp    800843 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80083e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800843:	5b                   	pop    %ebx
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    

00800846 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	8b 45 08             	mov    0x8(%ebp),%eax
  80084c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800850:	eb 07                	jmp    800859 <strchr+0x13>
		if (*s == c)
  800852:	38 ca                	cmp    %cl,%dl
  800854:	74 0f                	je     800865 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800856:	83 c0 01             	add    $0x1,%eax
  800859:	0f b6 10             	movzbl (%eax),%edx
  80085c:	84 d2                	test   %dl,%dl
  80085e:	75 f2                	jne    800852 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800860:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	8b 45 08             	mov    0x8(%ebp),%eax
  80086d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800871:	eb 03                	jmp    800876 <strfind+0xf>
  800873:	83 c0 01             	add    $0x1,%eax
  800876:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800879:	38 ca                	cmp    %cl,%dl
  80087b:	74 04                	je     800881 <strfind+0x1a>
  80087d:	84 d2                	test   %dl,%dl
  80087f:	75 f2                	jne    800873 <strfind+0xc>
			break;
	return (char *) s;
}
  800881:	5d                   	pop    %ebp
  800882:	c3                   	ret    

00800883 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	57                   	push   %edi
  800887:	56                   	push   %esi
  800888:	53                   	push   %ebx
  800889:	8b 7d 08             	mov    0x8(%ebp),%edi
  80088c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80088f:	85 c9                	test   %ecx,%ecx
  800891:	74 36                	je     8008c9 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800893:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800899:	75 28                	jne    8008c3 <memset+0x40>
  80089b:	f6 c1 03             	test   $0x3,%cl
  80089e:	75 23                	jne    8008c3 <memset+0x40>
		c &= 0xFF;
  8008a0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008a4:	89 d3                	mov    %edx,%ebx
  8008a6:	c1 e3 08             	shl    $0x8,%ebx
  8008a9:	89 d6                	mov    %edx,%esi
  8008ab:	c1 e6 18             	shl    $0x18,%esi
  8008ae:	89 d0                	mov    %edx,%eax
  8008b0:	c1 e0 10             	shl    $0x10,%eax
  8008b3:	09 f0                	or     %esi,%eax
  8008b5:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008b7:	89 d8                	mov    %ebx,%eax
  8008b9:	09 d0                	or     %edx,%eax
  8008bb:	c1 e9 02             	shr    $0x2,%ecx
  8008be:	fc                   	cld    
  8008bf:	f3 ab                	rep stos %eax,%es:(%edi)
  8008c1:	eb 06                	jmp    8008c9 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c6:	fc                   	cld    
  8008c7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c9:	89 f8                	mov    %edi,%eax
  8008cb:	5b                   	pop    %ebx
  8008cc:	5e                   	pop    %esi
  8008cd:	5f                   	pop    %edi
  8008ce:	5d                   	pop    %ebp
  8008cf:	c3                   	ret    

008008d0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	57                   	push   %edi
  8008d4:	56                   	push   %esi
  8008d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008db:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008de:	39 c6                	cmp    %eax,%esi
  8008e0:	73 35                	jae    800917 <memmove+0x47>
  8008e2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008e5:	39 d0                	cmp    %edx,%eax
  8008e7:	73 2e                	jae    800917 <memmove+0x47>
		s += n;
		d += n;
  8008e9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ec:	89 d6                	mov    %edx,%esi
  8008ee:	09 fe                	or     %edi,%esi
  8008f0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008f6:	75 13                	jne    80090b <memmove+0x3b>
  8008f8:	f6 c1 03             	test   $0x3,%cl
  8008fb:	75 0e                	jne    80090b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008fd:	83 ef 04             	sub    $0x4,%edi
  800900:	8d 72 fc             	lea    -0x4(%edx),%esi
  800903:	c1 e9 02             	shr    $0x2,%ecx
  800906:	fd                   	std    
  800907:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800909:	eb 09                	jmp    800914 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80090b:	83 ef 01             	sub    $0x1,%edi
  80090e:	8d 72 ff             	lea    -0x1(%edx),%esi
  800911:	fd                   	std    
  800912:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800914:	fc                   	cld    
  800915:	eb 1d                	jmp    800934 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800917:	89 f2                	mov    %esi,%edx
  800919:	09 c2                	or     %eax,%edx
  80091b:	f6 c2 03             	test   $0x3,%dl
  80091e:	75 0f                	jne    80092f <memmove+0x5f>
  800920:	f6 c1 03             	test   $0x3,%cl
  800923:	75 0a                	jne    80092f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800925:	c1 e9 02             	shr    $0x2,%ecx
  800928:	89 c7                	mov    %eax,%edi
  80092a:	fc                   	cld    
  80092b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092d:	eb 05                	jmp    800934 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80092f:	89 c7                	mov    %eax,%edi
  800931:	fc                   	cld    
  800932:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800934:	5e                   	pop    %esi
  800935:	5f                   	pop    %edi
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80093b:	ff 75 10             	pushl  0x10(%ebp)
  80093e:	ff 75 0c             	pushl  0xc(%ebp)
  800941:	ff 75 08             	pushl  0x8(%ebp)
  800944:	e8 87 ff ff ff       	call   8008d0 <memmove>
}
  800949:	c9                   	leave  
  80094a:	c3                   	ret    

0080094b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	56                   	push   %esi
  80094f:	53                   	push   %ebx
  800950:	8b 45 08             	mov    0x8(%ebp),%eax
  800953:	8b 55 0c             	mov    0xc(%ebp),%edx
  800956:	89 c6                	mov    %eax,%esi
  800958:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80095b:	eb 1a                	jmp    800977 <memcmp+0x2c>
		if (*s1 != *s2)
  80095d:	0f b6 08             	movzbl (%eax),%ecx
  800960:	0f b6 1a             	movzbl (%edx),%ebx
  800963:	38 d9                	cmp    %bl,%cl
  800965:	74 0a                	je     800971 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800967:	0f b6 c1             	movzbl %cl,%eax
  80096a:	0f b6 db             	movzbl %bl,%ebx
  80096d:	29 d8                	sub    %ebx,%eax
  80096f:	eb 0f                	jmp    800980 <memcmp+0x35>
		s1++, s2++;
  800971:	83 c0 01             	add    $0x1,%eax
  800974:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800977:	39 f0                	cmp    %esi,%eax
  800979:	75 e2                	jne    80095d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80097b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800980:	5b                   	pop    %ebx
  800981:	5e                   	pop    %esi
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	53                   	push   %ebx
  800988:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80098b:	89 c1                	mov    %eax,%ecx
  80098d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800990:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800994:	eb 0a                	jmp    8009a0 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800996:	0f b6 10             	movzbl (%eax),%edx
  800999:	39 da                	cmp    %ebx,%edx
  80099b:	74 07                	je     8009a4 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80099d:	83 c0 01             	add    $0x1,%eax
  8009a0:	39 c8                	cmp    %ecx,%eax
  8009a2:	72 f2                	jb     800996 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009a4:	5b                   	pop    %ebx
  8009a5:	5d                   	pop    %ebp
  8009a6:	c3                   	ret    

008009a7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	57                   	push   %edi
  8009ab:	56                   	push   %esi
  8009ac:	53                   	push   %ebx
  8009ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b3:	eb 03                	jmp    8009b8 <strtol+0x11>
		s++;
  8009b5:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b8:	0f b6 01             	movzbl (%ecx),%eax
  8009bb:	3c 20                	cmp    $0x20,%al
  8009bd:	74 f6                	je     8009b5 <strtol+0xe>
  8009bf:	3c 09                	cmp    $0x9,%al
  8009c1:	74 f2                	je     8009b5 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009c3:	3c 2b                	cmp    $0x2b,%al
  8009c5:	75 0a                	jne    8009d1 <strtol+0x2a>
		s++;
  8009c7:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ca:	bf 00 00 00 00       	mov    $0x0,%edi
  8009cf:	eb 11                	jmp    8009e2 <strtol+0x3b>
  8009d1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009d6:	3c 2d                	cmp    $0x2d,%al
  8009d8:	75 08                	jne    8009e2 <strtol+0x3b>
		s++, neg = 1;
  8009da:	83 c1 01             	add    $0x1,%ecx
  8009dd:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009e2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009e8:	75 15                	jne    8009ff <strtol+0x58>
  8009ea:	80 39 30             	cmpb   $0x30,(%ecx)
  8009ed:	75 10                	jne    8009ff <strtol+0x58>
  8009ef:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009f3:	75 7c                	jne    800a71 <strtol+0xca>
		s += 2, base = 16;
  8009f5:	83 c1 02             	add    $0x2,%ecx
  8009f8:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009fd:	eb 16                	jmp    800a15 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009ff:	85 db                	test   %ebx,%ebx
  800a01:	75 12                	jne    800a15 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a03:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a08:	80 39 30             	cmpb   $0x30,(%ecx)
  800a0b:	75 08                	jne    800a15 <strtol+0x6e>
		s++, base = 8;
  800a0d:	83 c1 01             	add    $0x1,%ecx
  800a10:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a15:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a1d:	0f b6 11             	movzbl (%ecx),%edx
  800a20:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a23:	89 f3                	mov    %esi,%ebx
  800a25:	80 fb 09             	cmp    $0x9,%bl
  800a28:	77 08                	ja     800a32 <strtol+0x8b>
			dig = *s - '0';
  800a2a:	0f be d2             	movsbl %dl,%edx
  800a2d:	83 ea 30             	sub    $0x30,%edx
  800a30:	eb 22                	jmp    800a54 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a32:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a35:	89 f3                	mov    %esi,%ebx
  800a37:	80 fb 19             	cmp    $0x19,%bl
  800a3a:	77 08                	ja     800a44 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a3c:	0f be d2             	movsbl %dl,%edx
  800a3f:	83 ea 57             	sub    $0x57,%edx
  800a42:	eb 10                	jmp    800a54 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a44:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a47:	89 f3                	mov    %esi,%ebx
  800a49:	80 fb 19             	cmp    $0x19,%bl
  800a4c:	77 16                	ja     800a64 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a4e:	0f be d2             	movsbl %dl,%edx
  800a51:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a54:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a57:	7d 0b                	jge    800a64 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a59:	83 c1 01             	add    $0x1,%ecx
  800a5c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a60:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a62:	eb b9                	jmp    800a1d <strtol+0x76>

	if (endptr)
  800a64:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a68:	74 0d                	je     800a77 <strtol+0xd0>
		*endptr = (char *) s;
  800a6a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a6d:	89 0e                	mov    %ecx,(%esi)
  800a6f:	eb 06                	jmp    800a77 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a71:	85 db                	test   %ebx,%ebx
  800a73:	74 98                	je     800a0d <strtol+0x66>
  800a75:	eb 9e                	jmp    800a15 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a77:	89 c2                	mov    %eax,%edx
  800a79:	f7 da                	neg    %edx
  800a7b:	85 ff                	test   %edi,%edi
  800a7d:	0f 45 c2             	cmovne %edx,%eax
}
  800a80:	5b                   	pop    %ebx
  800a81:	5e                   	pop    %esi
  800a82:	5f                   	pop    %edi
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    

00800a85 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	57                   	push   %edi
  800a89:	56                   	push   %esi
  800a8a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a93:	8b 55 08             	mov    0x8(%ebp),%edx
  800a96:	89 c3                	mov    %eax,%ebx
  800a98:	89 c7                	mov    %eax,%edi
  800a9a:	89 c6                	mov    %eax,%esi
  800a9c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a9e:	5b                   	pop    %ebx
  800a9f:	5e                   	pop    %esi
  800aa0:	5f                   	pop    %edi
  800aa1:	5d                   	pop    %ebp
  800aa2:	c3                   	ret    

00800aa3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	57                   	push   %edi
  800aa7:	56                   	push   %esi
  800aa8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa9:	ba 00 00 00 00       	mov    $0x0,%edx
  800aae:	b8 01 00 00 00       	mov    $0x1,%eax
  800ab3:	89 d1                	mov    %edx,%ecx
  800ab5:	89 d3                	mov    %edx,%ebx
  800ab7:	89 d7                	mov    %edx,%edi
  800ab9:	89 d6                	mov    %edx,%esi
  800abb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800abd:	5b                   	pop    %ebx
  800abe:	5e                   	pop    %esi
  800abf:	5f                   	pop    %edi
  800ac0:	5d                   	pop    %ebp
  800ac1:	c3                   	ret    

00800ac2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	57                   	push   %edi
  800ac6:	56                   	push   %esi
  800ac7:	53                   	push   %ebx
  800ac8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800acb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ad0:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad8:	89 cb                	mov    %ecx,%ebx
  800ada:	89 cf                	mov    %ecx,%edi
  800adc:	89 ce                	mov    %ecx,%esi
  800ade:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ae0:	85 c0                	test   %eax,%eax
  800ae2:	7e 17                	jle    800afb <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ae4:	83 ec 0c             	sub    $0xc,%esp
  800ae7:	50                   	push   %eax
  800ae8:	6a 03                	push   $0x3
  800aea:	68 df 27 80 00       	push   $0x8027df
  800aef:	6a 23                	push   $0x23
  800af1:	68 fc 27 80 00       	push   $0x8027fc
  800af6:	e8 90 14 00 00       	call   801f8b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800afb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800afe:	5b                   	pop    %ebx
  800aff:	5e                   	pop    %esi
  800b00:	5f                   	pop    %edi
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    

00800b03 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	57                   	push   %edi
  800b07:	56                   	push   %esi
  800b08:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b09:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0e:	b8 02 00 00 00       	mov    $0x2,%eax
  800b13:	89 d1                	mov    %edx,%ecx
  800b15:	89 d3                	mov    %edx,%ebx
  800b17:	89 d7                	mov    %edx,%edi
  800b19:	89 d6                	mov    %edx,%esi
  800b1b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b1d:	5b                   	pop    %ebx
  800b1e:	5e                   	pop    %esi
  800b1f:	5f                   	pop    %edi
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    

00800b22 <sys_yield>:

void
sys_yield(void)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	57                   	push   %edi
  800b26:	56                   	push   %esi
  800b27:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b28:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b32:	89 d1                	mov    %edx,%ecx
  800b34:	89 d3                	mov    %edx,%ebx
  800b36:	89 d7                	mov    %edx,%edi
  800b38:	89 d6                	mov    %edx,%esi
  800b3a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b3c:	5b                   	pop    %ebx
  800b3d:	5e                   	pop    %esi
  800b3e:	5f                   	pop    %edi
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800b4a:	be 00 00 00 00       	mov    $0x0,%esi
  800b4f:	b8 04 00 00 00       	mov    $0x4,%eax
  800b54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b57:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b5d:	89 f7                	mov    %esi,%edi
  800b5f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b61:	85 c0                	test   %eax,%eax
  800b63:	7e 17                	jle    800b7c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b65:	83 ec 0c             	sub    $0xc,%esp
  800b68:	50                   	push   %eax
  800b69:	6a 04                	push   $0x4
  800b6b:	68 df 27 80 00       	push   $0x8027df
  800b70:	6a 23                	push   $0x23
  800b72:	68 fc 27 80 00       	push   $0x8027fc
  800b77:	e8 0f 14 00 00       	call   801f8b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7f:	5b                   	pop    %ebx
  800b80:	5e                   	pop    %esi
  800b81:	5f                   	pop    %edi
  800b82:	5d                   	pop    %ebp
  800b83:	c3                   	ret    

00800b84 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	57                   	push   %edi
  800b88:	56                   	push   %esi
  800b89:	53                   	push   %ebx
  800b8a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8d:	b8 05 00 00 00       	mov    $0x5,%eax
  800b92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b95:	8b 55 08             	mov    0x8(%ebp),%edx
  800b98:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b9e:	8b 75 18             	mov    0x18(%ebp),%esi
  800ba1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba3:	85 c0                	test   %eax,%eax
  800ba5:	7e 17                	jle    800bbe <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba7:	83 ec 0c             	sub    $0xc,%esp
  800baa:	50                   	push   %eax
  800bab:	6a 05                	push   $0x5
  800bad:	68 df 27 80 00       	push   $0x8027df
  800bb2:	6a 23                	push   $0x23
  800bb4:	68 fc 27 80 00       	push   $0x8027fc
  800bb9:	e8 cd 13 00 00       	call   801f8b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc1:	5b                   	pop    %ebx
  800bc2:	5e                   	pop    %esi
  800bc3:	5f                   	pop    %edi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	57                   	push   %edi
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
  800bcc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd4:	b8 06 00 00 00       	mov    $0x6,%eax
  800bd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdf:	89 df                	mov    %ebx,%edi
  800be1:	89 de                	mov    %ebx,%esi
  800be3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be5:	85 c0                	test   %eax,%eax
  800be7:	7e 17                	jle    800c00 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be9:	83 ec 0c             	sub    $0xc,%esp
  800bec:	50                   	push   %eax
  800bed:	6a 06                	push   $0x6
  800bef:	68 df 27 80 00       	push   $0x8027df
  800bf4:	6a 23                	push   $0x23
  800bf6:	68 fc 27 80 00       	push   $0x8027fc
  800bfb:	e8 8b 13 00 00       	call   801f8b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c03:	5b                   	pop    %ebx
  800c04:	5e                   	pop    %esi
  800c05:	5f                   	pop    %edi
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
  800c0e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c11:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c16:	b8 08 00 00 00       	mov    $0x8,%eax
  800c1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c21:	89 df                	mov    %ebx,%edi
  800c23:	89 de                	mov    %ebx,%esi
  800c25:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c27:	85 c0                	test   %eax,%eax
  800c29:	7e 17                	jle    800c42 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2b:	83 ec 0c             	sub    $0xc,%esp
  800c2e:	50                   	push   %eax
  800c2f:	6a 08                	push   $0x8
  800c31:	68 df 27 80 00       	push   $0x8027df
  800c36:	6a 23                	push   $0x23
  800c38:	68 fc 27 80 00       	push   $0x8027fc
  800c3d:	e8 49 13 00 00       	call   801f8b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	57                   	push   %edi
  800c4e:	56                   	push   %esi
  800c4f:	53                   	push   %ebx
  800c50:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c58:	b8 09 00 00 00       	mov    $0x9,%eax
  800c5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c60:	8b 55 08             	mov    0x8(%ebp),%edx
  800c63:	89 df                	mov    %ebx,%edi
  800c65:	89 de                	mov    %ebx,%esi
  800c67:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c69:	85 c0                	test   %eax,%eax
  800c6b:	7e 17                	jle    800c84 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6d:	83 ec 0c             	sub    $0xc,%esp
  800c70:	50                   	push   %eax
  800c71:	6a 09                	push   $0x9
  800c73:	68 df 27 80 00       	push   $0x8027df
  800c78:	6a 23                	push   $0x23
  800c7a:	68 fc 27 80 00       	push   $0x8027fc
  800c7f:	e8 07 13 00 00       	call   801f8b <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    

00800c8c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	57                   	push   %edi
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
  800c92:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c95:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca5:	89 df                	mov    %ebx,%edi
  800ca7:	89 de                	mov    %ebx,%esi
  800ca9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cab:	85 c0                	test   %eax,%eax
  800cad:	7e 17                	jle    800cc6 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800caf:	83 ec 0c             	sub    $0xc,%esp
  800cb2:	50                   	push   %eax
  800cb3:	6a 0a                	push   $0xa
  800cb5:	68 df 27 80 00       	push   $0x8027df
  800cba:	6a 23                	push   $0x23
  800cbc:	68 fc 27 80 00       	push   $0x8027fc
  800cc1:	e8 c5 12 00 00       	call   801f8b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc9:	5b                   	pop    %ebx
  800cca:	5e                   	pop    %esi
  800ccb:	5f                   	pop    %edi
  800ccc:	5d                   	pop    %ebp
  800ccd:	c3                   	ret    

00800cce <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd4:	be 00 00 00 00       	mov    $0x0,%esi
  800cd9:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cea:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cec:	5b                   	pop    %ebx
  800ced:	5e                   	pop    %esi
  800cee:	5f                   	pop    %edi
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	57                   	push   %edi
  800cf5:	56                   	push   %esi
  800cf6:	53                   	push   %ebx
  800cf7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cff:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d04:	8b 55 08             	mov    0x8(%ebp),%edx
  800d07:	89 cb                	mov    %ecx,%ebx
  800d09:	89 cf                	mov    %ecx,%edi
  800d0b:	89 ce                	mov    %ecx,%esi
  800d0d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d0f:	85 c0                	test   %eax,%eax
  800d11:	7e 17                	jle    800d2a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d13:	83 ec 0c             	sub    $0xc,%esp
  800d16:	50                   	push   %eax
  800d17:	6a 0d                	push   $0xd
  800d19:	68 df 27 80 00       	push   $0x8027df
  800d1e:	6a 23                	push   $0x23
  800d20:	68 fc 27 80 00       	push   $0x8027fc
  800d25:	e8 61 12 00 00       	call   801f8b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2d:	5b                   	pop    %ebx
  800d2e:	5e                   	pop    %esi
  800d2f:	5f                   	pop    %edi
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    

00800d32 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	57                   	push   %edi
  800d36:	56                   	push   %esi
  800d37:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d38:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3d:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d42:	8b 55 08             	mov    0x8(%ebp),%edx
  800d45:	89 cb                	mov    %ecx,%ebx
  800d47:	89 cf                	mov    %ecx,%edi
  800d49:	89 ce                	mov    %ecx,%esi
  800d4b:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d4d:	5b                   	pop    %ebx
  800d4e:	5e                   	pop    %esi
  800d4f:	5f                   	pop    %edi
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    

00800d52 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800d52:	55                   	push   %ebp
  800d53:	89 e5                	mov    %esp,%ebp
  800d55:	57                   	push   %edi
  800d56:	56                   	push   %esi
  800d57:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d58:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d5d:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d62:	8b 55 08             	mov    0x8(%ebp),%edx
  800d65:	89 cb                	mov    %ecx,%ebx
  800d67:	89 cf                	mov    %ecx,%edi
  800d69:	89 ce                	mov    %ecx,%esi
  800d6b:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800d6d:	5b                   	pop    %ebx
  800d6e:	5e                   	pop    %esi
  800d6f:	5f                   	pop    %edi
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	57                   	push   %edi
  800d76:	56                   	push   %esi
  800d77:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d78:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d7d:	b8 10 00 00 00       	mov    $0x10,%eax
  800d82:	8b 55 08             	mov    0x8(%ebp),%edx
  800d85:	89 cb                	mov    %ecx,%ebx
  800d87:	89 cf                	mov    %ecx,%edi
  800d89:	89 ce                	mov    %ecx,%esi
  800d8b:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  800d8d:	5b                   	pop    %ebx
  800d8e:	5e                   	pop    %esi
  800d8f:	5f                   	pop    %edi
  800d90:	5d                   	pop    %ebp
  800d91:	c3                   	ret    

00800d92 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d92:	55                   	push   %ebp
  800d93:	89 e5                	mov    %esp,%ebp
  800d95:	53                   	push   %ebx
  800d96:	83 ec 04             	sub    $0x4,%esp
  800d99:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d9c:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800d9e:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800da2:	74 11                	je     800db5 <pgfault+0x23>
  800da4:	89 d8                	mov    %ebx,%eax
  800da6:	c1 e8 0c             	shr    $0xc,%eax
  800da9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800db0:	f6 c4 08             	test   $0x8,%ah
  800db3:	75 14                	jne    800dc9 <pgfault+0x37>
		panic("faulting access");
  800db5:	83 ec 04             	sub    $0x4,%esp
  800db8:	68 0a 28 80 00       	push   $0x80280a
  800dbd:	6a 1f                	push   $0x1f
  800dbf:	68 1a 28 80 00       	push   $0x80281a
  800dc4:	e8 c2 11 00 00       	call   801f8b <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800dc9:	83 ec 04             	sub    $0x4,%esp
  800dcc:	6a 07                	push   $0x7
  800dce:	68 00 f0 7f 00       	push   $0x7ff000
  800dd3:	6a 00                	push   $0x0
  800dd5:	e8 67 fd ff ff       	call   800b41 <sys_page_alloc>
	if (r < 0) {
  800dda:	83 c4 10             	add    $0x10,%esp
  800ddd:	85 c0                	test   %eax,%eax
  800ddf:	79 12                	jns    800df3 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800de1:	50                   	push   %eax
  800de2:	68 25 28 80 00       	push   $0x802825
  800de7:	6a 2d                	push   $0x2d
  800de9:	68 1a 28 80 00       	push   $0x80281a
  800dee:	e8 98 11 00 00       	call   801f8b <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800df3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800df9:	83 ec 04             	sub    $0x4,%esp
  800dfc:	68 00 10 00 00       	push   $0x1000
  800e01:	53                   	push   %ebx
  800e02:	68 00 f0 7f 00       	push   $0x7ff000
  800e07:	e8 2c fb ff ff       	call   800938 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e0c:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e13:	53                   	push   %ebx
  800e14:	6a 00                	push   $0x0
  800e16:	68 00 f0 7f 00       	push   $0x7ff000
  800e1b:	6a 00                	push   $0x0
  800e1d:	e8 62 fd ff ff       	call   800b84 <sys_page_map>
	if (r < 0) {
  800e22:	83 c4 20             	add    $0x20,%esp
  800e25:	85 c0                	test   %eax,%eax
  800e27:	79 12                	jns    800e3b <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e29:	50                   	push   %eax
  800e2a:	68 25 28 80 00       	push   $0x802825
  800e2f:	6a 34                	push   $0x34
  800e31:	68 1a 28 80 00       	push   $0x80281a
  800e36:	e8 50 11 00 00       	call   801f8b <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e3b:	83 ec 08             	sub    $0x8,%esp
  800e3e:	68 00 f0 7f 00       	push   $0x7ff000
  800e43:	6a 00                	push   $0x0
  800e45:	e8 7c fd ff ff       	call   800bc6 <sys_page_unmap>
	if (r < 0) {
  800e4a:	83 c4 10             	add    $0x10,%esp
  800e4d:	85 c0                	test   %eax,%eax
  800e4f:	79 12                	jns    800e63 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e51:	50                   	push   %eax
  800e52:	68 25 28 80 00       	push   $0x802825
  800e57:	6a 38                	push   $0x38
  800e59:	68 1a 28 80 00       	push   $0x80281a
  800e5e:	e8 28 11 00 00       	call   801f8b <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e66:	c9                   	leave  
  800e67:	c3                   	ret    

00800e68 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	57                   	push   %edi
  800e6c:	56                   	push   %esi
  800e6d:	53                   	push   %ebx
  800e6e:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e71:	68 92 0d 80 00       	push   $0x800d92
  800e76:	e8 56 11 00 00       	call   801fd1 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e7b:	b8 07 00 00 00       	mov    $0x7,%eax
  800e80:	cd 30                	int    $0x30
  800e82:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800e85:	83 c4 10             	add    $0x10,%esp
  800e88:	85 c0                	test   %eax,%eax
  800e8a:	79 17                	jns    800ea3 <fork+0x3b>
		panic("fork fault %e");
  800e8c:	83 ec 04             	sub    $0x4,%esp
  800e8f:	68 3e 28 80 00       	push   $0x80283e
  800e94:	68 85 00 00 00       	push   $0x85
  800e99:	68 1a 28 80 00       	push   $0x80281a
  800e9e:	e8 e8 10 00 00       	call   801f8b <_panic>
  800ea3:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800ea5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ea9:	75 24                	jne    800ecf <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800eab:	e8 53 fc ff ff       	call   800b03 <sys_getenvid>
  800eb0:	25 ff 03 00 00       	and    $0x3ff,%eax
  800eb5:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800ebb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ec0:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800ec5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eca:	e9 64 01 00 00       	jmp    801033 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800ecf:	83 ec 04             	sub    $0x4,%esp
  800ed2:	6a 07                	push   $0x7
  800ed4:	68 00 f0 bf ee       	push   $0xeebff000
  800ed9:	ff 75 e4             	pushl  -0x1c(%ebp)
  800edc:	e8 60 fc ff ff       	call   800b41 <sys_page_alloc>
  800ee1:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800ee4:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ee9:	89 d8                	mov    %ebx,%eax
  800eeb:	c1 e8 16             	shr    $0x16,%eax
  800eee:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ef5:	a8 01                	test   $0x1,%al
  800ef7:	0f 84 fc 00 00 00    	je     800ff9 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800efd:	89 d8                	mov    %ebx,%eax
  800eff:	c1 e8 0c             	shr    $0xc,%eax
  800f02:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f09:	f6 c2 01             	test   $0x1,%dl
  800f0c:	0f 84 e7 00 00 00    	je     800ff9 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f12:	89 c6                	mov    %eax,%esi
  800f14:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f17:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f1e:	f6 c6 04             	test   $0x4,%dh
  800f21:	74 39                	je     800f5c <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f23:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f2a:	83 ec 0c             	sub    $0xc,%esp
  800f2d:	25 07 0e 00 00       	and    $0xe07,%eax
  800f32:	50                   	push   %eax
  800f33:	56                   	push   %esi
  800f34:	57                   	push   %edi
  800f35:	56                   	push   %esi
  800f36:	6a 00                	push   $0x0
  800f38:	e8 47 fc ff ff       	call   800b84 <sys_page_map>
		if (r < 0) {
  800f3d:	83 c4 20             	add    $0x20,%esp
  800f40:	85 c0                	test   %eax,%eax
  800f42:	0f 89 b1 00 00 00    	jns    800ff9 <fork+0x191>
		    	panic("sys page map fault %e");
  800f48:	83 ec 04             	sub    $0x4,%esp
  800f4b:	68 4c 28 80 00       	push   $0x80284c
  800f50:	6a 55                	push   $0x55
  800f52:	68 1a 28 80 00       	push   $0x80281a
  800f57:	e8 2f 10 00 00       	call   801f8b <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f5c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f63:	f6 c2 02             	test   $0x2,%dl
  800f66:	75 0c                	jne    800f74 <fork+0x10c>
  800f68:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f6f:	f6 c4 08             	test   $0x8,%ah
  800f72:	74 5b                	je     800fcf <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f74:	83 ec 0c             	sub    $0xc,%esp
  800f77:	68 05 08 00 00       	push   $0x805
  800f7c:	56                   	push   %esi
  800f7d:	57                   	push   %edi
  800f7e:	56                   	push   %esi
  800f7f:	6a 00                	push   $0x0
  800f81:	e8 fe fb ff ff       	call   800b84 <sys_page_map>
		if (r < 0) {
  800f86:	83 c4 20             	add    $0x20,%esp
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	79 14                	jns    800fa1 <fork+0x139>
		    	panic("sys page map fault %e");
  800f8d:	83 ec 04             	sub    $0x4,%esp
  800f90:	68 4c 28 80 00       	push   $0x80284c
  800f95:	6a 5c                	push   $0x5c
  800f97:	68 1a 28 80 00       	push   $0x80281a
  800f9c:	e8 ea 0f 00 00       	call   801f8b <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800fa1:	83 ec 0c             	sub    $0xc,%esp
  800fa4:	68 05 08 00 00       	push   $0x805
  800fa9:	56                   	push   %esi
  800faa:	6a 00                	push   $0x0
  800fac:	56                   	push   %esi
  800fad:	6a 00                	push   $0x0
  800faf:	e8 d0 fb ff ff       	call   800b84 <sys_page_map>
		if (r < 0) {
  800fb4:	83 c4 20             	add    $0x20,%esp
  800fb7:	85 c0                	test   %eax,%eax
  800fb9:	79 3e                	jns    800ff9 <fork+0x191>
		    	panic("sys page map fault %e");
  800fbb:	83 ec 04             	sub    $0x4,%esp
  800fbe:	68 4c 28 80 00       	push   $0x80284c
  800fc3:	6a 60                	push   $0x60
  800fc5:	68 1a 28 80 00       	push   $0x80281a
  800fca:	e8 bc 0f 00 00       	call   801f8b <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800fcf:	83 ec 0c             	sub    $0xc,%esp
  800fd2:	6a 05                	push   $0x5
  800fd4:	56                   	push   %esi
  800fd5:	57                   	push   %edi
  800fd6:	56                   	push   %esi
  800fd7:	6a 00                	push   $0x0
  800fd9:	e8 a6 fb ff ff       	call   800b84 <sys_page_map>
		if (r < 0) {
  800fde:	83 c4 20             	add    $0x20,%esp
  800fe1:	85 c0                	test   %eax,%eax
  800fe3:	79 14                	jns    800ff9 <fork+0x191>
		    	panic("sys page map fault %e");
  800fe5:	83 ec 04             	sub    $0x4,%esp
  800fe8:	68 4c 28 80 00       	push   $0x80284c
  800fed:	6a 65                	push   $0x65
  800fef:	68 1a 28 80 00       	push   $0x80281a
  800ff4:	e8 92 0f 00 00       	call   801f8b <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800ff9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fff:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801005:	0f 85 de fe ff ff    	jne    800ee9 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  80100b:	a1 04 40 80 00       	mov    0x804004,%eax
  801010:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
  801016:	83 ec 08             	sub    $0x8,%esp
  801019:	50                   	push   %eax
  80101a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80101d:	57                   	push   %edi
  80101e:	e8 69 fc ff ff       	call   800c8c <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801023:	83 c4 08             	add    $0x8,%esp
  801026:	6a 02                	push   $0x2
  801028:	57                   	push   %edi
  801029:	e8 da fb ff ff       	call   800c08 <sys_env_set_status>
	
	return envid;
  80102e:	83 c4 10             	add    $0x10,%esp
  801031:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801033:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801036:	5b                   	pop    %ebx
  801037:	5e                   	pop    %esi
  801038:	5f                   	pop    %edi
  801039:	5d                   	pop    %ebp
  80103a:	c3                   	ret    

0080103b <sfork>:

envid_t
sfork(void)
{
  80103b:	55                   	push   %ebp
  80103c:	89 e5                	mov    %esp,%ebp
	return 0;
}
  80103e:	b8 00 00 00 00       	mov    $0x0,%eax
  801043:	5d                   	pop    %ebp
  801044:	c3                   	ret    

00801045 <thread_create>:

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  801045:	55                   	push   %ebp
  801046:	89 e5                	mov    %esp,%ebp
  801048:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  80104b:	8b 45 08             	mov    0x8(%ebp),%eax
  80104e:	a3 08 40 80 00       	mov    %eax,0x804008
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801053:	68 ec 00 80 00       	push   $0x8000ec
  801058:	e8 d5 fc ff ff       	call   800d32 <sys_thread_create>

	return id;
}
  80105d:	c9                   	leave  
  80105e:	c3                   	ret    

0080105f <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  80105f:	55                   	push   %ebp
  801060:	89 e5                	mov    %esp,%ebp
  801062:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  801065:	ff 75 08             	pushl  0x8(%ebp)
  801068:	e8 e5 fc ff ff       	call   800d52 <sys_thread_free>
}
  80106d:	83 c4 10             	add    $0x10,%esp
  801070:	c9                   	leave  
  801071:	c3                   	ret    

00801072 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  801072:	55                   	push   %ebp
  801073:	89 e5                	mov    %esp,%ebp
  801075:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  801078:	ff 75 08             	pushl  0x8(%ebp)
  80107b:	e8 f2 fc ff ff       	call   800d72 <sys_thread_join>
}
  801080:	83 c4 10             	add    $0x10,%esp
  801083:	c9                   	leave  
  801084:	c3                   	ret    

00801085 <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  801085:	55                   	push   %ebp
  801086:	89 e5                	mov    %esp,%ebp
  801088:	56                   	push   %esi
  801089:	53                   	push   %ebx
  80108a:	8b 75 08             	mov    0x8(%ebp),%esi
  80108d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  801090:	83 ec 04             	sub    $0x4,%esp
  801093:	6a 07                	push   $0x7
  801095:	6a 00                	push   $0x0
  801097:	56                   	push   %esi
  801098:	e8 a4 fa ff ff       	call   800b41 <sys_page_alloc>
	if (r < 0) {
  80109d:	83 c4 10             	add    $0x10,%esp
  8010a0:	85 c0                	test   %eax,%eax
  8010a2:	79 15                	jns    8010b9 <queue_append+0x34>
		panic("%e\n", r);
  8010a4:	50                   	push   %eax
  8010a5:	68 92 28 80 00       	push   $0x802892
  8010aa:	68 d5 00 00 00       	push   $0xd5
  8010af:	68 1a 28 80 00       	push   $0x80281a
  8010b4:	e8 d2 0e 00 00       	call   801f8b <_panic>
	}	

	wt->envid = envid;
  8010b9:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  8010bf:	83 3b 00             	cmpl   $0x0,(%ebx)
  8010c2:	75 13                	jne    8010d7 <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  8010c4:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  8010cb:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8010d2:	00 00 00 
  8010d5:	eb 1b                	jmp    8010f2 <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  8010d7:	8b 43 04             	mov    0x4(%ebx),%eax
  8010da:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  8010e1:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8010e8:	00 00 00 
		queue->last = wt;
  8010eb:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8010f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010f5:	5b                   	pop    %ebx
  8010f6:	5e                   	pop    %esi
  8010f7:	5d                   	pop    %ebp
  8010f8:	c3                   	ret    

008010f9 <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  8010f9:	55                   	push   %ebp
  8010fa:	89 e5                	mov    %esp,%ebp
  8010fc:	83 ec 08             	sub    $0x8,%esp
  8010ff:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  801102:	8b 02                	mov    (%edx),%eax
  801104:	85 c0                	test   %eax,%eax
  801106:	75 17                	jne    80111f <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  801108:	83 ec 04             	sub    $0x4,%esp
  80110b:	68 62 28 80 00       	push   $0x802862
  801110:	68 ec 00 00 00       	push   $0xec
  801115:	68 1a 28 80 00       	push   $0x80281a
  80111a:	e8 6c 0e 00 00       	call   801f8b <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  80111f:	8b 48 04             	mov    0x4(%eax),%ecx
  801122:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  801124:	8b 00                	mov    (%eax),%eax
}
  801126:	c9                   	leave  
  801127:	c3                   	ret    

00801128 <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  801128:	55                   	push   %ebp
  801129:	89 e5                	mov    %esp,%ebp
  80112b:	53                   	push   %ebx
  80112c:	83 ec 04             	sub    $0x4,%esp
  80112f:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  801132:	b8 01 00 00 00       	mov    $0x1,%eax
  801137:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0)) {
  80113a:	85 c0                	test   %eax,%eax
  80113c:	74 45                	je     801183 <mutex_lock+0x5b>
		queue_append(sys_getenvid(), &mtx->queue);		
  80113e:	e8 c0 f9 ff ff       	call   800b03 <sys_getenvid>
  801143:	83 ec 08             	sub    $0x8,%esp
  801146:	83 c3 04             	add    $0x4,%ebx
  801149:	53                   	push   %ebx
  80114a:	50                   	push   %eax
  80114b:	e8 35 ff ff ff       	call   801085 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  801150:	e8 ae f9 ff ff       	call   800b03 <sys_getenvid>
  801155:	83 c4 08             	add    $0x8,%esp
  801158:	6a 04                	push   $0x4
  80115a:	50                   	push   %eax
  80115b:	e8 a8 fa ff ff       	call   800c08 <sys_env_set_status>

		if (r < 0) {
  801160:	83 c4 10             	add    $0x10,%esp
  801163:	85 c0                	test   %eax,%eax
  801165:	79 15                	jns    80117c <mutex_lock+0x54>
			panic("%e\n", r);
  801167:	50                   	push   %eax
  801168:	68 92 28 80 00       	push   $0x802892
  80116d:	68 02 01 00 00       	push   $0x102
  801172:	68 1a 28 80 00       	push   $0x80281a
  801177:	e8 0f 0e 00 00       	call   801f8b <_panic>
		}
		sys_yield();
  80117c:	e8 a1 f9 ff ff       	call   800b22 <sys_yield>
  801181:	eb 08                	jmp    80118b <mutex_lock+0x63>
	} else {
		mtx->owner = sys_getenvid();
  801183:	e8 7b f9 ff ff       	call   800b03 <sys_getenvid>
  801188:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80118b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80118e:	c9                   	leave  
  80118f:	c3                   	ret    

00801190 <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	53                   	push   %ebx
  801194:	83 ec 04             	sub    $0x4,%esp
  801197:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	if (mtx->queue.first != NULL) {
  80119a:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  80119e:	74 36                	je     8011d6 <mutex_unlock+0x46>
		mtx->owner = queue_pop(&mtx->queue);
  8011a0:	83 ec 0c             	sub    $0xc,%esp
  8011a3:	8d 43 04             	lea    0x4(%ebx),%eax
  8011a6:	50                   	push   %eax
  8011a7:	e8 4d ff ff ff       	call   8010f9 <queue_pop>
  8011ac:	89 43 0c             	mov    %eax,0xc(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8011af:	83 c4 08             	add    $0x8,%esp
  8011b2:	6a 02                	push   $0x2
  8011b4:	50                   	push   %eax
  8011b5:	e8 4e fa ff ff       	call   800c08 <sys_env_set_status>
		if (r < 0) {
  8011ba:	83 c4 10             	add    $0x10,%esp
  8011bd:	85 c0                	test   %eax,%eax
  8011bf:	79 1d                	jns    8011de <mutex_unlock+0x4e>
			panic("%e\n", r);
  8011c1:	50                   	push   %eax
  8011c2:	68 92 28 80 00       	push   $0x802892
  8011c7:	68 16 01 00 00       	push   $0x116
  8011cc:	68 1a 28 80 00       	push   $0x80281a
  8011d1:	e8 b5 0d 00 00       	call   801f8b <_panic>
  8011d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011db:	f0 87 03             	lock xchg %eax,(%ebx)
		}
	} else xchg(&mtx->locked, 0);
	
	//asm volatile("pause"); 	// might be useless here
	sys_yield();
  8011de:	e8 3f f9 ff ff       	call   800b22 <sys_yield>
}
  8011e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011e6:	c9                   	leave  
  8011e7:	c3                   	ret    

008011e8 <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
  8011eb:	53                   	push   %ebx
  8011ec:	83 ec 04             	sub    $0x4,%esp
  8011ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  8011f2:	e8 0c f9 ff ff       	call   800b03 <sys_getenvid>
  8011f7:	83 ec 04             	sub    $0x4,%esp
  8011fa:	6a 07                	push   $0x7
  8011fc:	53                   	push   %ebx
  8011fd:	50                   	push   %eax
  8011fe:	e8 3e f9 ff ff       	call   800b41 <sys_page_alloc>
  801203:	83 c4 10             	add    $0x10,%esp
  801206:	85 c0                	test   %eax,%eax
  801208:	79 15                	jns    80121f <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  80120a:	50                   	push   %eax
  80120b:	68 7d 28 80 00       	push   $0x80287d
  801210:	68 23 01 00 00       	push   $0x123
  801215:	68 1a 28 80 00       	push   $0x80281a
  80121a:	e8 6c 0d 00 00       	call   801f8b <_panic>
	}	
	mtx->locked = 0;
  80121f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue.first = NULL;
  801225:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	mtx->queue.last = NULL;
  80122c:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	mtx->owner = 0;
  801233:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
}
  80123a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80123d:	c9                   	leave  
  80123e:	c3                   	ret    

0080123f <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  80123f:	55                   	push   %ebp
  801240:	89 e5                	mov    %esp,%ebp
  801242:	56                   	push   %esi
  801243:	53                   	push   %ebx
  801244:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue.first != NULL) {
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  801247:	8d 73 04             	lea    0x4(%ebx),%esi

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  80124a:	eb 20                	jmp    80126c <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  80124c:	83 ec 0c             	sub    $0xc,%esp
  80124f:	56                   	push   %esi
  801250:	e8 a4 fe ff ff       	call   8010f9 <queue_pop>
  801255:	83 c4 08             	add    $0x8,%esp
  801258:	6a 02                	push   $0x2
  80125a:	50                   	push   %eax
  80125b:	e8 a8 f9 ff ff       	call   800c08 <sys_env_set_status>
		mtx->queue.first = mtx->queue.first->next;
  801260:	8b 43 04             	mov    0x4(%ebx),%eax
  801263:	8b 40 04             	mov    0x4(%eax),%eax
  801266:	89 43 04             	mov    %eax,0x4(%ebx)
  801269:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  80126c:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  801270:	75 da                	jne    80124c <mutex_destroy+0xd>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
		mtx->queue.first = mtx->queue.first->next;
	}

	memset(mtx, 0, PGSIZE);
  801272:	83 ec 04             	sub    $0x4,%esp
  801275:	68 00 10 00 00       	push   $0x1000
  80127a:	6a 00                	push   $0x0
  80127c:	53                   	push   %ebx
  80127d:	e8 01 f6 ff ff       	call   800883 <memset>
	mtx = NULL;
}
  801282:	83 c4 10             	add    $0x10,%esp
  801285:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801288:	5b                   	pop    %ebx
  801289:	5e                   	pop    %esi
  80128a:	5d                   	pop    %ebp
  80128b:	c3                   	ret    

0080128c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80128c:	55                   	push   %ebp
  80128d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80128f:	8b 45 08             	mov    0x8(%ebp),%eax
  801292:	05 00 00 00 30       	add    $0x30000000,%eax
  801297:	c1 e8 0c             	shr    $0xc,%eax
}
  80129a:	5d                   	pop    %ebp
  80129b:	c3                   	ret    

0080129c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80129f:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a2:	05 00 00 00 30       	add    $0x30000000,%eax
  8012a7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012ac:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012b1:	5d                   	pop    %ebp
  8012b2:	c3                   	ret    

008012b3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012b3:	55                   	push   %ebp
  8012b4:	89 e5                	mov    %esp,%ebp
  8012b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012b9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012be:	89 c2                	mov    %eax,%edx
  8012c0:	c1 ea 16             	shr    $0x16,%edx
  8012c3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012ca:	f6 c2 01             	test   $0x1,%dl
  8012cd:	74 11                	je     8012e0 <fd_alloc+0x2d>
  8012cf:	89 c2                	mov    %eax,%edx
  8012d1:	c1 ea 0c             	shr    $0xc,%edx
  8012d4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012db:	f6 c2 01             	test   $0x1,%dl
  8012de:	75 09                	jne    8012e9 <fd_alloc+0x36>
			*fd_store = fd;
  8012e0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e7:	eb 17                	jmp    801300 <fd_alloc+0x4d>
  8012e9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012ee:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012f3:	75 c9                	jne    8012be <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012f5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012fb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801300:	5d                   	pop    %ebp
  801301:	c3                   	ret    

00801302 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801302:	55                   	push   %ebp
  801303:	89 e5                	mov    %esp,%ebp
  801305:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801308:	83 f8 1f             	cmp    $0x1f,%eax
  80130b:	77 36                	ja     801343 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80130d:	c1 e0 0c             	shl    $0xc,%eax
  801310:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801315:	89 c2                	mov    %eax,%edx
  801317:	c1 ea 16             	shr    $0x16,%edx
  80131a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801321:	f6 c2 01             	test   $0x1,%dl
  801324:	74 24                	je     80134a <fd_lookup+0x48>
  801326:	89 c2                	mov    %eax,%edx
  801328:	c1 ea 0c             	shr    $0xc,%edx
  80132b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801332:	f6 c2 01             	test   $0x1,%dl
  801335:	74 1a                	je     801351 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801337:	8b 55 0c             	mov    0xc(%ebp),%edx
  80133a:	89 02                	mov    %eax,(%edx)
	return 0;
  80133c:	b8 00 00 00 00       	mov    $0x0,%eax
  801341:	eb 13                	jmp    801356 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801343:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801348:	eb 0c                	jmp    801356 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80134a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80134f:	eb 05                	jmp    801356 <fd_lookup+0x54>
  801351:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801356:	5d                   	pop    %ebp
  801357:	c3                   	ret    

00801358 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801358:	55                   	push   %ebp
  801359:	89 e5                	mov    %esp,%ebp
  80135b:	83 ec 08             	sub    $0x8,%esp
  80135e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801361:	ba 14 29 80 00       	mov    $0x802914,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801366:	eb 13                	jmp    80137b <dev_lookup+0x23>
  801368:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80136b:	39 08                	cmp    %ecx,(%eax)
  80136d:	75 0c                	jne    80137b <dev_lookup+0x23>
			*dev = devtab[i];
  80136f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801372:	89 01                	mov    %eax,(%ecx)
			return 0;
  801374:	b8 00 00 00 00       	mov    $0x0,%eax
  801379:	eb 31                	jmp    8013ac <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80137b:	8b 02                	mov    (%edx),%eax
  80137d:	85 c0                	test   %eax,%eax
  80137f:	75 e7                	jne    801368 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801381:	a1 04 40 80 00       	mov    0x804004,%eax
  801386:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80138c:	83 ec 04             	sub    $0x4,%esp
  80138f:	51                   	push   %ecx
  801390:	50                   	push   %eax
  801391:	68 98 28 80 00       	push   $0x802898
  801396:	e8 1e ee ff ff       	call   8001b9 <cprintf>
	*dev = 0;
  80139b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80139e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013a4:	83 c4 10             	add    $0x10,%esp
  8013a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013ac:	c9                   	leave  
  8013ad:	c3                   	ret    

008013ae <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013ae:	55                   	push   %ebp
  8013af:	89 e5                	mov    %esp,%ebp
  8013b1:	56                   	push   %esi
  8013b2:	53                   	push   %ebx
  8013b3:	83 ec 10             	sub    $0x10,%esp
  8013b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8013b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013bf:	50                   	push   %eax
  8013c0:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013c6:	c1 e8 0c             	shr    $0xc,%eax
  8013c9:	50                   	push   %eax
  8013ca:	e8 33 ff ff ff       	call   801302 <fd_lookup>
  8013cf:	83 c4 08             	add    $0x8,%esp
  8013d2:	85 c0                	test   %eax,%eax
  8013d4:	78 05                	js     8013db <fd_close+0x2d>
	    || fd != fd2)
  8013d6:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013d9:	74 0c                	je     8013e7 <fd_close+0x39>
		return (must_exist ? r : 0);
  8013db:	84 db                	test   %bl,%bl
  8013dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e2:	0f 44 c2             	cmove  %edx,%eax
  8013e5:	eb 41                	jmp    801428 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013e7:	83 ec 08             	sub    $0x8,%esp
  8013ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ed:	50                   	push   %eax
  8013ee:	ff 36                	pushl  (%esi)
  8013f0:	e8 63 ff ff ff       	call   801358 <dev_lookup>
  8013f5:	89 c3                	mov    %eax,%ebx
  8013f7:	83 c4 10             	add    $0x10,%esp
  8013fa:	85 c0                	test   %eax,%eax
  8013fc:	78 1a                	js     801418 <fd_close+0x6a>
		if (dev->dev_close)
  8013fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801401:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801404:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801409:	85 c0                	test   %eax,%eax
  80140b:	74 0b                	je     801418 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80140d:	83 ec 0c             	sub    $0xc,%esp
  801410:	56                   	push   %esi
  801411:	ff d0                	call   *%eax
  801413:	89 c3                	mov    %eax,%ebx
  801415:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801418:	83 ec 08             	sub    $0x8,%esp
  80141b:	56                   	push   %esi
  80141c:	6a 00                	push   $0x0
  80141e:	e8 a3 f7 ff ff       	call   800bc6 <sys_page_unmap>
	return r;
  801423:	83 c4 10             	add    $0x10,%esp
  801426:	89 d8                	mov    %ebx,%eax
}
  801428:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80142b:	5b                   	pop    %ebx
  80142c:	5e                   	pop    %esi
  80142d:	5d                   	pop    %ebp
  80142e:	c3                   	ret    

0080142f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80142f:	55                   	push   %ebp
  801430:	89 e5                	mov    %esp,%ebp
  801432:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801435:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801438:	50                   	push   %eax
  801439:	ff 75 08             	pushl  0x8(%ebp)
  80143c:	e8 c1 fe ff ff       	call   801302 <fd_lookup>
  801441:	83 c4 08             	add    $0x8,%esp
  801444:	85 c0                	test   %eax,%eax
  801446:	78 10                	js     801458 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801448:	83 ec 08             	sub    $0x8,%esp
  80144b:	6a 01                	push   $0x1
  80144d:	ff 75 f4             	pushl  -0xc(%ebp)
  801450:	e8 59 ff ff ff       	call   8013ae <fd_close>
  801455:	83 c4 10             	add    $0x10,%esp
}
  801458:	c9                   	leave  
  801459:	c3                   	ret    

0080145a <close_all>:

void
close_all(void)
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	53                   	push   %ebx
  80145e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801461:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801466:	83 ec 0c             	sub    $0xc,%esp
  801469:	53                   	push   %ebx
  80146a:	e8 c0 ff ff ff       	call   80142f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80146f:	83 c3 01             	add    $0x1,%ebx
  801472:	83 c4 10             	add    $0x10,%esp
  801475:	83 fb 20             	cmp    $0x20,%ebx
  801478:	75 ec                	jne    801466 <close_all+0xc>
		close(i);
}
  80147a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80147d:	c9                   	leave  
  80147e:	c3                   	ret    

0080147f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80147f:	55                   	push   %ebp
  801480:	89 e5                	mov    %esp,%ebp
  801482:	57                   	push   %edi
  801483:	56                   	push   %esi
  801484:	53                   	push   %ebx
  801485:	83 ec 2c             	sub    $0x2c,%esp
  801488:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80148b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80148e:	50                   	push   %eax
  80148f:	ff 75 08             	pushl  0x8(%ebp)
  801492:	e8 6b fe ff ff       	call   801302 <fd_lookup>
  801497:	83 c4 08             	add    $0x8,%esp
  80149a:	85 c0                	test   %eax,%eax
  80149c:	0f 88 c1 00 00 00    	js     801563 <dup+0xe4>
		return r;
	close(newfdnum);
  8014a2:	83 ec 0c             	sub    $0xc,%esp
  8014a5:	56                   	push   %esi
  8014a6:	e8 84 ff ff ff       	call   80142f <close>

	newfd = INDEX2FD(newfdnum);
  8014ab:	89 f3                	mov    %esi,%ebx
  8014ad:	c1 e3 0c             	shl    $0xc,%ebx
  8014b0:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014b6:	83 c4 04             	add    $0x4,%esp
  8014b9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014bc:	e8 db fd ff ff       	call   80129c <fd2data>
  8014c1:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014c3:	89 1c 24             	mov    %ebx,(%esp)
  8014c6:	e8 d1 fd ff ff       	call   80129c <fd2data>
  8014cb:	83 c4 10             	add    $0x10,%esp
  8014ce:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014d1:	89 f8                	mov    %edi,%eax
  8014d3:	c1 e8 16             	shr    $0x16,%eax
  8014d6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014dd:	a8 01                	test   $0x1,%al
  8014df:	74 37                	je     801518 <dup+0x99>
  8014e1:	89 f8                	mov    %edi,%eax
  8014e3:	c1 e8 0c             	shr    $0xc,%eax
  8014e6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014ed:	f6 c2 01             	test   $0x1,%dl
  8014f0:	74 26                	je     801518 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014f2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014f9:	83 ec 0c             	sub    $0xc,%esp
  8014fc:	25 07 0e 00 00       	and    $0xe07,%eax
  801501:	50                   	push   %eax
  801502:	ff 75 d4             	pushl  -0x2c(%ebp)
  801505:	6a 00                	push   $0x0
  801507:	57                   	push   %edi
  801508:	6a 00                	push   $0x0
  80150a:	e8 75 f6 ff ff       	call   800b84 <sys_page_map>
  80150f:	89 c7                	mov    %eax,%edi
  801511:	83 c4 20             	add    $0x20,%esp
  801514:	85 c0                	test   %eax,%eax
  801516:	78 2e                	js     801546 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801518:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80151b:	89 d0                	mov    %edx,%eax
  80151d:	c1 e8 0c             	shr    $0xc,%eax
  801520:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801527:	83 ec 0c             	sub    $0xc,%esp
  80152a:	25 07 0e 00 00       	and    $0xe07,%eax
  80152f:	50                   	push   %eax
  801530:	53                   	push   %ebx
  801531:	6a 00                	push   $0x0
  801533:	52                   	push   %edx
  801534:	6a 00                	push   $0x0
  801536:	e8 49 f6 ff ff       	call   800b84 <sys_page_map>
  80153b:	89 c7                	mov    %eax,%edi
  80153d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801540:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801542:	85 ff                	test   %edi,%edi
  801544:	79 1d                	jns    801563 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801546:	83 ec 08             	sub    $0x8,%esp
  801549:	53                   	push   %ebx
  80154a:	6a 00                	push   $0x0
  80154c:	e8 75 f6 ff ff       	call   800bc6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801551:	83 c4 08             	add    $0x8,%esp
  801554:	ff 75 d4             	pushl  -0x2c(%ebp)
  801557:	6a 00                	push   $0x0
  801559:	e8 68 f6 ff ff       	call   800bc6 <sys_page_unmap>
	return r;
  80155e:	83 c4 10             	add    $0x10,%esp
  801561:	89 f8                	mov    %edi,%eax
}
  801563:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801566:	5b                   	pop    %ebx
  801567:	5e                   	pop    %esi
  801568:	5f                   	pop    %edi
  801569:	5d                   	pop    %ebp
  80156a:	c3                   	ret    

0080156b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80156b:	55                   	push   %ebp
  80156c:	89 e5                	mov    %esp,%ebp
  80156e:	53                   	push   %ebx
  80156f:	83 ec 14             	sub    $0x14,%esp
  801572:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801575:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801578:	50                   	push   %eax
  801579:	53                   	push   %ebx
  80157a:	e8 83 fd ff ff       	call   801302 <fd_lookup>
  80157f:	83 c4 08             	add    $0x8,%esp
  801582:	89 c2                	mov    %eax,%edx
  801584:	85 c0                	test   %eax,%eax
  801586:	78 70                	js     8015f8 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801588:	83 ec 08             	sub    $0x8,%esp
  80158b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158e:	50                   	push   %eax
  80158f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801592:	ff 30                	pushl  (%eax)
  801594:	e8 bf fd ff ff       	call   801358 <dev_lookup>
  801599:	83 c4 10             	add    $0x10,%esp
  80159c:	85 c0                	test   %eax,%eax
  80159e:	78 4f                	js     8015ef <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015a0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015a3:	8b 42 08             	mov    0x8(%edx),%eax
  8015a6:	83 e0 03             	and    $0x3,%eax
  8015a9:	83 f8 01             	cmp    $0x1,%eax
  8015ac:	75 24                	jne    8015d2 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015ae:	a1 04 40 80 00       	mov    0x804004,%eax
  8015b3:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8015b9:	83 ec 04             	sub    $0x4,%esp
  8015bc:	53                   	push   %ebx
  8015bd:	50                   	push   %eax
  8015be:	68 d9 28 80 00       	push   $0x8028d9
  8015c3:	e8 f1 eb ff ff       	call   8001b9 <cprintf>
		return -E_INVAL;
  8015c8:	83 c4 10             	add    $0x10,%esp
  8015cb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015d0:	eb 26                	jmp    8015f8 <read+0x8d>
	}
	if (!dev->dev_read)
  8015d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d5:	8b 40 08             	mov    0x8(%eax),%eax
  8015d8:	85 c0                	test   %eax,%eax
  8015da:	74 17                	je     8015f3 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8015dc:	83 ec 04             	sub    $0x4,%esp
  8015df:	ff 75 10             	pushl  0x10(%ebp)
  8015e2:	ff 75 0c             	pushl  0xc(%ebp)
  8015e5:	52                   	push   %edx
  8015e6:	ff d0                	call   *%eax
  8015e8:	89 c2                	mov    %eax,%edx
  8015ea:	83 c4 10             	add    $0x10,%esp
  8015ed:	eb 09                	jmp    8015f8 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ef:	89 c2                	mov    %eax,%edx
  8015f1:	eb 05                	jmp    8015f8 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015f3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8015f8:	89 d0                	mov    %edx,%eax
  8015fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015fd:	c9                   	leave  
  8015fe:	c3                   	ret    

008015ff <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015ff:	55                   	push   %ebp
  801600:	89 e5                	mov    %esp,%ebp
  801602:	57                   	push   %edi
  801603:	56                   	push   %esi
  801604:	53                   	push   %ebx
  801605:	83 ec 0c             	sub    $0xc,%esp
  801608:	8b 7d 08             	mov    0x8(%ebp),%edi
  80160b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80160e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801613:	eb 21                	jmp    801636 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801615:	83 ec 04             	sub    $0x4,%esp
  801618:	89 f0                	mov    %esi,%eax
  80161a:	29 d8                	sub    %ebx,%eax
  80161c:	50                   	push   %eax
  80161d:	89 d8                	mov    %ebx,%eax
  80161f:	03 45 0c             	add    0xc(%ebp),%eax
  801622:	50                   	push   %eax
  801623:	57                   	push   %edi
  801624:	e8 42 ff ff ff       	call   80156b <read>
		if (m < 0)
  801629:	83 c4 10             	add    $0x10,%esp
  80162c:	85 c0                	test   %eax,%eax
  80162e:	78 10                	js     801640 <readn+0x41>
			return m;
		if (m == 0)
  801630:	85 c0                	test   %eax,%eax
  801632:	74 0a                	je     80163e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801634:	01 c3                	add    %eax,%ebx
  801636:	39 f3                	cmp    %esi,%ebx
  801638:	72 db                	jb     801615 <readn+0x16>
  80163a:	89 d8                	mov    %ebx,%eax
  80163c:	eb 02                	jmp    801640 <readn+0x41>
  80163e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801640:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801643:	5b                   	pop    %ebx
  801644:	5e                   	pop    %esi
  801645:	5f                   	pop    %edi
  801646:	5d                   	pop    %ebp
  801647:	c3                   	ret    

00801648 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	53                   	push   %ebx
  80164c:	83 ec 14             	sub    $0x14,%esp
  80164f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801652:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801655:	50                   	push   %eax
  801656:	53                   	push   %ebx
  801657:	e8 a6 fc ff ff       	call   801302 <fd_lookup>
  80165c:	83 c4 08             	add    $0x8,%esp
  80165f:	89 c2                	mov    %eax,%edx
  801661:	85 c0                	test   %eax,%eax
  801663:	78 6b                	js     8016d0 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801665:	83 ec 08             	sub    $0x8,%esp
  801668:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166b:	50                   	push   %eax
  80166c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166f:	ff 30                	pushl  (%eax)
  801671:	e8 e2 fc ff ff       	call   801358 <dev_lookup>
  801676:	83 c4 10             	add    $0x10,%esp
  801679:	85 c0                	test   %eax,%eax
  80167b:	78 4a                	js     8016c7 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80167d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801680:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801684:	75 24                	jne    8016aa <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801686:	a1 04 40 80 00       	mov    0x804004,%eax
  80168b:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801691:	83 ec 04             	sub    $0x4,%esp
  801694:	53                   	push   %ebx
  801695:	50                   	push   %eax
  801696:	68 f5 28 80 00       	push   $0x8028f5
  80169b:	e8 19 eb ff ff       	call   8001b9 <cprintf>
		return -E_INVAL;
  8016a0:	83 c4 10             	add    $0x10,%esp
  8016a3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016a8:	eb 26                	jmp    8016d0 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016ad:	8b 52 0c             	mov    0xc(%edx),%edx
  8016b0:	85 d2                	test   %edx,%edx
  8016b2:	74 17                	je     8016cb <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016b4:	83 ec 04             	sub    $0x4,%esp
  8016b7:	ff 75 10             	pushl  0x10(%ebp)
  8016ba:	ff 75 0c             	pushl  0xc(%ebp)
  8016bd:	50                   	push   %eax
  8016be:	ff d2                	call   *%edx
  8016c0:	89 c2                	mov    %eax,%edx
  8016c2:	83 c4 10             	add    $0x10,%esp
  8016c5:	eb 09                	jmp    8016d0 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c7:	89 c2                	mov    %eax,%edx
  8016c9:	eb 05                	jmp    8016d0 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016cb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016d0:	89 d0                	mov    %edx,%eax
  8016d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d5:	c9                   	leave  
  8016d6:	c3                   	ret    

008016d7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016d7:	55                   	push   %ebp
  8016d8:	89 e5                	mov    %esp,%ebp
  8016da:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016dd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016e0:	50                   	push   %eax
  8016e1:	ff 75 08             	pushl  0x8(%ebp)
  8016e4:	e8 19 fc ff ff       	call   801302 <fd_lookup>
  8016e9:	83 c4 08             	add    $0x8,%esp
  8016ec:	85 c0                	test   %eax,%eax
  8016ee:	78 0e                	js     8016fe <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016f6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016fe:	c9                   	leave  
  8016ff:	c3                   	ret    

00801700 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801700:	55                   	push   %ebp
  801701:	89 e5                	mov    %esp,%ebp
  801703:	53                   	push   %ebx
  801704:	83 ec 14             	sub    $0x14,%esp
  801707:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80170a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80170d:	50                   	push   %eax
  80170e:	53                   	push   %ebx
  80170f:	e8 ee fb ff ff       	call   801302 <fd_lookup>
  801714:	83 c4 08             	add    $0x8,%esp
  801717:	89 c2                	mov    %eax,%edx
  801719:	85 c0                	test   %eax,%eax
  80171b:	78 68                	js     801785 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80171d:	83 ec 08             	sub    $0x8,%esp
  801720:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801723:	50                   	push   %eax
  801724:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801727:	ff 30                	pushl  (%eax)
  801729:	e8 2a fc ff ff       	call   801358 <dev_lookup>
  80172e:	83 c4 10             	add    $0x10,%esp
  801731:	85 c0                	test   %eax,%eax
  801733:	78 47                	js     80177c <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801735:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801738:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80173c:	75 24                	jne    801762 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80173e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801743:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801749:	83 ec 04             	sub    $0x4,%esp
  80174c:	53                   	push   %ebx
  80174d:	50                   	push   %eax
  80174e:	68 b8 28 80 00       	push   $0x8028b8
  801753:	e8 61 ea ff ff       	call   8001b9 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801758:	83 c4 10             	add    $0x10,%esp
  80175b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801760:	eb 23                	jmp    801785 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801762:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801765:	8b 52 18             	mov    0x18(%edx),%edx
  801768:	85 d2                	test   %edx,%edx
  80176a:	74 14                	je     801780 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80176c:	83 ec 08             	sub    $0x8,%esp
  80176f:	ff 75 0c             	pushl  0xc(%ebp)
  801772:	50                   	push   %eax
  801773:	ff d2                	call   *%edx
  801775:	89 c2                	mov    %eax,%edx
  801777:	83 c4 10             	add    $0x10,%esp
  80177a:	eb 09                	jmp    801785 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177c:	89 c2                	mov    %eax,%edx
  80177e:	eb 05                	jmp    801785 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801780:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801785:	89 d0                	mov    %edx,%eax
  801787:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80178a:	c9                   	leave  
  80178b:	c3                   	ret    

0080178c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80178c:	55                   	push   %ebp
  80178d:	89 e5                	mov    %esp,%ebp
  80178f:	53                   	push   %ebx
  801790:	83 ec 14             	sub    $0x14,%esp
  801793:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801796:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801799:	50                   	push   %eax
  80179a:	ff 75 08             	pushl  0x8(%ebp)
  80179d:	e8 60 fb ff ff       	call   801302 <fd_lookup>
  8017a2:	83 c4 08             	add    $0x8,%esp
  8017a5:	89 c2                	mov    %eax,%edx
  8017a7:	85 c0                	test   %eax,%eax
  8017a9:	78 58                	js     801803 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ab:	83 ec 08             	sub    $0x8,%esp
  8017ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b1:	50                   	push   %eax
  8017b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b5:	ff 30                	pushl  (%eax)
  8017b7:	e8 9c fb ff ff       	call   801358 <dev_lookup>
  8017bc:	83 c4 10             	add    $0x10,%esp
  8017bf:	85 c0                	test   %eax,%eax
  8017c1:	78 37                	js     8017fa <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017ca:	74 32                	je     8017fe <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017cc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017cf:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017d6:	00 00 00 
	stat->st_isdir = 0;
  8017d9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017e0:	00 00 00 
	stat->st_dev = dev;
  8017e3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017e9:	83 ec 08             	sub    $0x8,%esp
  8017ec:	53                   	push   %ebx
  8017ed:	ff 75 f0             	pushl  -0x10(%ebp)
  8017f0:	ff 50 14             	call   *0x14(%eax)
  8017f3:	89 c2                	mov    %eax,%edx
  8017f5:	83 c4 10             	add    $0x10,%esp
  8017f8:	eb 09                	jmp    801803 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017fa:	89 c2                	mov    %eax,%edx
  8017fc:	eb 05                	jmp    801803 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017fe:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801803:	89 d0                	mov    %edx,%eax
  801805:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801808:	c9                   	leave  
  801809:	c3                   	ret    

0080180a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80180a:	55                   	push   %ebp
  80180b:	89 e5                	mov    %esp,%ebp
  80180d:	56                   	push   %esi
  80180e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80180f:	83 ec 08             	sub    $0x8,%esp
  801812:	6a 00                	push   $0x0
  801814:	ff 75 08             	pushl  0x8(%ebp)
  801817:	e8 e3 01 00 00       	call   8019ff <open>
  80181c:	89 c3                	mov    %eax,%ebx
  80181e:	83 c4 10             	add    $0x10,%esp
  801821:	85 c0                	test   %eax,%eax
  801823:	78 1b                	js     801840 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801825:	83 ec 08             	sub    $0x8,%esp
  801828:	ff 75 0c             	pushl  0xc(%ebp)
  80182b:	50                   	push   %eax
  80182c:	e8 5b ff ff ff       	call   80178c <fstat>
  801831:	89 c6                	mov    %eax,%esi
	close(fd);
  801833:	89 1c 24             	mov    %ebx,(%esp)
  801836:	e8 f4 fb ff ff       	call   80142f <close>
	return r;
  80183b:	83 c4 10             	add    $0x10,%esp
  80183e:	89 f0                	mov    %esi,%eax
}
  801840:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801843:	5b                   	pop    %ebx
  801844:	5e                   	pop    %esi
  801845:	5d                   	pop    %ebp
  801846:	c3                   	ret    

00801847 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801847:	55                   	push   %ebp
  801848:	89 e5                	mov    %esp,%ebp
  80184a:	56                   	push   %esi
  80184b:	53                   	push   %ebx
  80184c:	89 c6                	mov    %eax,%esi
  80184e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801850:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801857:	75 12                	jne    80186b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801859:	83 ec 0c             	sub    $0xc,%esp
  80185c:	6a 01                	push   $0x1
  80185e:	e8 da 08 00 00       	call   80213d <ipc_find_env>
  801863:	a3 00 40 80 00       	mov    %eax,0x804000
  801868:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80186b:	6a 07                	push   $0x7
  80186d:	68 00 50 80 00       	push   $0x805000
  801872:	56                   	push   %esi
  801873:	ff 35 00 40 80 00    	pushl  0x804000
  801879:	e8 5d 08 00 00       	call   8020db <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80187e:	83 c4 0c             	add    $0xc,%esp
  801881:	6a 00                	push   $0x0
  801883:	53                   	push   %ebx
  801884:	6a 00                	push   $0x0
  801886:	e8 d5 07 00 00       	call   802060 <ipc_recv>
}
  80188b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80188e:	5b                   	pop    %ebx
  80188f:	5e                   	pop    %esi
  801890:	5d                   	pop    %ebp
  801891:	c3                   	ret    

00801892 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801892:	55                   	push   %ebp
  801893:	89 e5                	mov    %esp,%ebp
  801895:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801898:	8b 45 08             	mov    0x8(%ebp),%eax
  80189b:	8b 40 0c             	mov    0xc(%eax),%eax
  80189e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b0:	b8 02 00 00 00       	mov    $0x2,%eax
  8018b5:	e8 8d ff ff ff       	call   801847 <fsipc>
}
  8018ba:	c9                   	leave  
  8018bb:	c3                   	ret    

008018bc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d2:	b8 06 00 00 00       	mov    $0x6,%eax
  8018d7:	e8 6b ff ff ff       	call   801847 <fsipc>
}
  8018dc:	c9                   	leave  
  8018dd:	c3                   	ret    

008018de <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018de:	55                   	push   %ebp
  8018df:	89 e5                	mov    %esp,%ebp
  8018e1:	53                   	push   %ebx
  8018e2:	83 ec 04             	sub    $0x4,%esp
  8018e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018eb:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ee:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f8:	b8 05 00 00 00       	mov    $0x5,%eax
  8018fd:	e8 45 ff ff ff       	call   801847 <fsipc>
  801902:	85 c0                	test   %eax,%eax
  801904:	78 2c                	js     801932 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801906:	83 ec 08             	sub    $0x8,%esp
  801909:	68 00 50 80 00       	push   $0x805000
  80190e:	53                   	push   %ebx
  80190f:	e8 2a ee ff ff       	call   80073e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801914:	a1 80 50 80 00       	mov    0x805080,%eax
  801919:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80191f:	a1 84 50 80 00       	mov    0x805084,%eax
  801924:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80192a:	83 c4 10             	add    $0x10,%esp
  80192d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801932:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801935:	c9                   	leave  
  801936:	c3                   	ret    

00801937 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801937:	55                   	push   %ebp
  801938:	89 e5                	mov    %esp,%ebp
  80193a:	83 ec 0c             	sub    $0xc,%esp
  80193d:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801940:	8b 55 08             	mov    0x8(%ebp),%edx
  801943:	8b 52 0c             	mov    0xc(%edx),%edx
  801946:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80194c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801951:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801956:	0f 47 c2             	cmova  %edx,%eax
  801959:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80195e:	50                   	push   %eax
  80195f:	ff 75 0c             	pushl  0xc(%ebp)
  801962:	68 08 50 80 00       	push   $0x805008
  801967:	e8 64 ef ff ff       	call   8008d0 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80196c:	ba 00 00 00 00       	mov    $0x0,%edx
  801971:	b8 04 00 00 00       	mov    $0x4,%eax
  801976:	e8 cc fe ff ff       	call   801847 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80197b:	c9                   	leave  
  80197c:	c3                   	ret    

0080197d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80197d:	55                   	push   %ebp
  80197e:	89 e5                	mov    %esp,%ebp
  801980:	56                   	push   %esi
  801981:	53                   	push   %ebx
  801982:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801985:	8b 45 08             	mov    0x8(%ebp),%eax
  801988:	8b 40 0c             	mov    0xc(%eax),%eax
  80198b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801990:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801996:	ba 00 00 00 00       	mov    $0x0,%edx
  80199b:	b8 03 00 00 00       	mov    $0x3,%eax
  8019a0:	e8 a2 fe ff ff       	call   801847 <fsipc>
  8019a5:	89 c3                	mov    %eax,%ebx
  8019a7:	85 c0                	test   %eax,%eax
  8019a9:	78 4b                	js     8019f6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019ab:	39 c6                	cmp    %eax,%esi
  8019ad:	73 16                	jae    8019c5 <devfile_read+0x48>
  8019af:	68 24 29 80 00       	push   $0x802924
  8019b4:	68 2b 29 80 00       	push   $0x80292b
  8019b9:	6a 7c                	push   $0x7c
  8019bb:	68 40 29 80 00       	push   $0x802940
  8019c0:	e8 c6 05 00 00       	call   801f8b <_panic>
	assert(r <= PGSIZE);
  8019c5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019ca:	7e 16                	jle    8019e2 <devfile_read+0x65>
  8019cc:	68 4b 29 80 00       	push   $0x80294b
  8019d1:	68 2b 29 80 00       	push   $0x80292b
  8019d6:	6a 7d                	push   $0x7d
  8019d8:	68 40 29 80 00       	push   $0x802940
  8019dd:	e8 a9 05 00 00       	call   801f8b <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019e2:	83 ec 04             	sub    $0x4,%esp
  8019e5:	50                   	push   %eax
  8019e6:	68 00 50 80 00       	push   $0x805000
  8019eb:	ff 75 0c             	pushl  0xc(%ebp)
  8019ee:	e8 dd ee ff ff       	call   8008d0 <memmove>
	return r;
  8019f3:	83 c4 10             	add    $0x10,%esp
}
  8019f6:	89 d8                	mov    %ebx,%eax
  8019f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019fb:	5b                   	pop    %ebx
  8019fc:	5e                   	pop    %esi
  8019fd:	5d                   	pop    %ebp
  8019fe:	c3                   	ret    

008019ff <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019ff:	55                   	push   %ebp
  801a00:	89 e5                	mov    %esp,%ebp
  801a02:	53                   	push   %ebx
  801a03:	83 ec 20             	sub    $0x20,%esp
  801a06:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a09:	53                   	push   %ebx
  801a0a:	e8 f6 ec ff ff       	call   800705 <strlen>
  801a0f:	83 c4 10             	add    $0x10,%esp
  801a12:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a17:	7f 67                	jg     801a80 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a19:	83 ec 0c             	sub    $0xc,%esp
  801a1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a1f:	50                   	push   %eax
  801a20:	e8 8e f8 ff ff       	call   8012b3 <fd_alloc>
  801a25:	83 c4 10             	add    $0x10,%esp
		return r;
  801a28:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a2a:	85 c0                	test   %eax,%eax
  801a2c:	78 57                	js     801a85 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a2e:	83 ec 08             	sub    $0x8,%esp
  801a31:	53                   	push   %ebx
  801a32:	68 00 50 80 00       	push   $0x805000
  801a37:	e8 02 ed ff ff       	call   80073e <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a3f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a44:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a47:	b8 01 00 00 00       	mov    $0x1,%eax
  801a4c:	e8 f6 fd ff ff       	call   801847 <fsipc>
  801a51:	89 c3                	mov    %eax,%ebx
  801a53:	83 c4 10             	add    $0x10,%esp
  801a56:	85 c0                	test   %eax,%eax
  801a58:	79 14                	jns    801a6e <open+0x6f>
		fd_close(fd, 0);
  801a5a:	83 ec 08             	sub    $0x8,%esp
  801a5d:	6a 00                	push   $0x0
  801a5f:	ff 75 f4             	pushl  -0xc(%ebp)
  801a62:	e8 47 f9 ff ff       	call   8013ae <fd_close>
		return r;
  801a67:	83 c4 10             	add    $0x10,%esp
  801a6a:	89 da                	mov    %ebx,%edx
  801a6c:	eb 17                	jmp    801a85 <open+0x86>
	}

	return fd2num(fd);
  801a6e:	83 ec 0c             	sub    $0xc,%esp
  801a71:	ff 75 f4             	pushl  -0xc(%ebp)
  801a74:	e8 13 f8 ff ff       	call   80128c <fd2num>
  801a79:	89 c2                	mov    %eax,%edx
  801a7b:	83 c4 10             	add    $0x10,%esp
  801a7e:	eb 05                	jmp    801a85 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a80:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a85:	89 d0                	mov    %edx,%eax
  801a87:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a8a:	c9                   	leave  
  801a8b:	c3                   	ret    

00801a8c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a8c:	55                   	push   %ebp
  801a8d:	89 e5                	mov    %esp,%ebp
  801a8f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a92:	ba 00 00 00 00       	mov    $0x0,%edx
  801a97:	b8 08 00 00 00       	mov    $0x8,%eax
  801a9c:	e8 a6 fd ff ff       	call   801847 <fsipc>
}
  801aa1:	c9                   	leave  
  801aa2:	c3                   	ret    

00801aa3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801aa3:	55                   	push   %ebp
  801aa4:	89 e5                	mov    %esp,%ebp
  801aa6:	56                   	push   %esi
  801aa7:	53                   	push   %ebx
  801aa8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801aab:	83 ec 0c             	sub    $0xc,%esp
  801aae:	ff 75 08             	pushl  0x8(%ebp)
  801ab1:	e8 e6 f7 ff ff       	call   80129c <fd2data>
  801ab6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ab8:	83 c4 08             	add    $0x8,%esp
  801abb:	68 57 29 80 00       	push   $0x802957
  801ac0:	53                   	push   %ebx
  801ac1:	e8 78 ec ff ff       	call   80073e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ac6:	8b 46 04             	mov    0x4(%esi),%eax
  801ac9:	2b 06                	sub    (%esi),%eax
  801acb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ad1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ad8:	00 00 00 
	stat->st_dev = &devpipe;
  801adb:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801ae2:	30 80 00 
	return 0;
}
  801ae5:	b8 00 00 00 00       	mov    $0x0,%eax
  801aea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aed:	5b                   	pop    %ebx
  801aee:	5e                   	pop    %esi
  801aef:	5d                   	pop    %ebp
  801af0:	c3                   	ret    

00801af1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801af1:	55                   	push   %ebp
  801af2:	89 e5                	mov    %esp,%ebp
  801af4:	53                   	push   %ebx
  801af5:	83 ec 0c             	sub    $0xc,%esp
  801af8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801afb:	53                   	push   %ebx
  801afc:	6a 00                	push   $0x0
  801afe:	e8 c3 f0 ff ff       	call   800bc6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b03:	89 1c 24             	mov    %ebx,(%esp)
  801b06:	e8 91 f7 ff ff       	call   80129c <fd2data>
  801b0b:	83 c4 08             	add    $0x8,%esp
  801b0e:	50                   	push   %eax
  801b0f:	6a 00                	push   $0x0
  801b11:	e8 b0 f0 ff ff       	call   800bc6 <sys_page_unmap>
}
  801b16:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b19:	c9                   	leave  
  801b1a:	c3                   	ret    

00801b1b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b1b:	55                   	push   %ebp
  801b1c:	89 e5                	mov    %esp,%ebp
  801b1e:	57                   	push   %edi
  801b1f:	56                   	push   %esi
  801b20:	53                   	push   %ebx
  801b21:	83 ec 1c             	sub    $0x1c,%esp
  801b24:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b27:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b29:	a1 04 40 80 00       	mov    0x804004,%eax
  801b2e:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b34:	83 ec 0c             	sub    $0xc,%esp
  801b37:	ff 75 e0             	pushl  -0x20(%ebp)
  801b3a:	e8 43 06 00 00       	call   802182 <pageref>
  801b3f:	89 c3                	mov    %eax,%ebx
  801b41:	89 3c 24             	mov    %edi,(%esp)
  801b44:	e8 39 06 00 00       	call   802182 <pageref>
  801b49:	83 c4 10             	add    $0x10,%esp
  801b4c:	39 c3                	cmp    %eax,%ebx
  801b4e:	0f 94 c1             	sete   %cl
  801b51:	0f b6 c9             	movzbl %cl,%ecx
  801b54:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b57:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b5d:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  801b63:	39 ce                	cmp    %ecx,%esi
  801b65:	74 1e                	je     801b85 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801b67:	39 c3                	cmp    %eax,%ebx
  801b69:	75 be                	jne    801b29 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b6b:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  801b71:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b74:	50                   	push   %eax
  801b75:	56                   	push   %esi
  801b76:	68 5e 29 80 00       	push   $0x80295e
  801b7b:	e8 39 e6 ff ff       	call   8001b9 <cprintf>
  801b80:	83 c4 10             	add    $0x10,%esp
  801b83:	eb a4                	jmp    801b29 <_pipeisclosed+0xe>
	}
}
  801b85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b8b:	5b                   	pop    %ebx
  801b8c:	5e                   	pop    %esi
  801b8d:	5f                   	pop    %edi
  801b8e:	5d                   	pop    %ebp
  801b8f:	c3                   	ret    

00801b90 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b90:	55                   	push   %ebp
  801b91:	89 e5                	mov    %esp,%ebp
  801b93:	57                   	push   %edi
  801b94:	56                   	push   %esi
  801b95:	53                   	push   %ebx
  801b96:	83 ec 28             	sub    $0x28,%esp
  801b99:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b9c:	56                   	push   %esi
  801b9d:	e8 fa f6 ff ff       	call   80129c <fd2data>
  801ba2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ba4:	83 c4 10             	add    $0x10,%esp
  801ba7:	bf 00 00 00 00       	mov    $0x0,%edi
  801bac:	eb 4b                	jmp    801bf9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bae:	89 da                	mov    %ebx,%edx
  801bb0:	89 f0                	mov    %esi,%eax
  801bb2:	e8 64 ff ff ff       	call   801b1b <_pipeisclosed>
  801bb7:	85 c0                	test   %eax,%eax
  801bb9:	75 48                	jne    801c03 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bbb:	e8 62 ef ff ff       	call   800b22 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bc0:	8b 43 04             	mov    0x4(%ebx),%eax
  801bc3:	8b 0b                	mov    (%ebx),%ecx
  801bc5:	8d 51 20             	lea    0x20(%ecx),%edx
  801bc8:	39 d0                	cmp    %edx,%eax
  801bca:	73 e2                	jae    801bae <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bcf:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bd3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bd6:	89 c2                	mov    %eax,%edx
  801bd8:	c1 fa 1f             	sar    $0x1f,%edx
  801bdb:	89 d1                	mov    %edx,%ecx
  801bdd:	c1 e9 1b             	shr    $0x1b,%ecx
  801be0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801be3:	83 e2 1f             	and    $0x1f,%edx
  801be6:	29 ca                	sub    %ecx,%edx
  801be8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bec:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bf0:	83 c0 01             	add    $0x1,%eax
  801bf3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bf6:	83 c7 01             	add    $0x1,%edi
  801bf9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bfc:	75 c2                	jne    801bc0 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bfe:	8b 45 10             	mov    0x10(%ebp),%eax
  801c01:	eb 05                	jmp    801c08 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c03:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c0b:	5b                   	pop    %ebx
  801c0c:	5e                   	pop    %esi
  801c0d:	5f                   	pop    %edi
  801c0e:	5d                   	pop    %ebp
  801c0f:	c3                   	ret    

00801c10 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c10:	55                   	push   %ebp
  801c11:	89 e5                	mov    %esp,%ebp
  801c13:	57                   	push   %edi
  801c14:	56                   	push   %esi
  801c15:	53                   	push   %ebx
  801c16:	83 ec 18             	sub    $0x18,%esp
  801c19:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c1c:	57                   	push   %edi
  801c1d:	e8 7a f6 ff ff       	call   80129c <fd2data>
  801c22:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c24:	83 c4 10             	add    $0x10,%esp
  801c27:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c2c:	eb 3d                	jmp    801c6b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c2e:	85 db                	test   %ebx,%ebx
  801c30:	74 04                	je     801c36 <devpipe_read+0x26>
				return i;
  801c32:	89 d8                	mov    %ebx,%eax
  801c34:	eb 44                	jmp    801c7a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c36:	89 f2                	mov    %esi,%edx
  801c38:	89 f8                	mov    %edi,%eax
  801c3a:	e8 dc fe ff ff       	call   801b1b <_pipeisclosed>
  801c3f:	85 c0                	test   %eax,%eax
  801c41:	75 32                	jne    801c75 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c43:	e8 da ee ff ff       	call   800b22 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c48:	8b 06                	mov    (%esi),%eax
  801c4a:	3b 46 04             	cmp    0x4(%esi),%eax
  801c4d:	74 df                	je     801c2e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c4f:	99                   	cltd   
  801c50:	c1 ea 1b             	shr    $0x1b,%edx
  801c53:	01 d0                	add    %edx,%eax
  801c55:	83 e0 1f             	and    $0x1f,%eax
  801c58:	29 d0                	sub    %edx,%eax
  801c5a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c62:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c65:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c68:	83 c3 01             	add    $0x1,%ebx
  801c6b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c6e:	75 d8                	jne    801c48 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c70:	8b 45 10             	mov    0x10(%ebp),%eax
  801c73:	eb 05                	jmp    801c7a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c75:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c7d:	5b                   	pop    %ebx
  801c7e:	5e                   	pop    %esi
  801c7f:	5f                   	pop    %edi
  801c80:	5d                   	pop    %ebp
  801c81:	c3                   	ret    

00801c82 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c82:	55                   	push   %ebp
  801c83:	89 e5                	mov    %esp,%ebp
  801c85:	56                   	push   %esi
  801c86:	53                   	push   %ebx
  801c87:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c8d:	50                   	push   %eax
  801c8e:	e8 20 f6 ff ff       	call   8012b3 <fd_alloc>
  801c93:	83 c4 10             	add    $0x10,%esp
  801c96:	89 c2                	mov    %eax,%edx
  801c98:	85 c0                	test   %eax,%eax
  801c9a:	0f 88 2c 01 00 00    	js     801dcc <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ca0:	83 ec 04             	sub    $0x4,%esp
  801ca3:	68 07 04 00 00       	push   $0x407
  801ca8:	ff 75 f4             	pushl  -0xc(%ebp)
  801cab:	6a 00                	push   $0x0
  801cad:	e8 8f ee ff ff       	call   800b41 <sys_page_alloc>
  801cb2:	83 c4 10             	add    $0x10,%esp
  801cb5:	89 c2                	mov    %eax,%edx
  801cb7:	85 c0                	test   %eax,%eax
  801cb9:	0f 88 0d 01 00 00    	js     801dcc <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cbf:	83 ec 0c             	sub    $0xc,%esp
  801cc2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cc5:	50                   	push   %eax
  801cc6:	e8 e8 f5 ff ff       	call   8012b3 <fd_alloc>
  801ccb:	89 c3                	mov    %eax,%ebx
  801ccd:	83 c4 10             	add    $0x10,%esp
  801cd0:	85 c0                	test   %eax,%eax
  801cd2:	0f 88 e2 00 00 00    	js     801dba <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cd8:	83 ec 04             	sub    $0x4,%esp
  801cdb:	68 07 04 00 00       	push   $0x407
  801ce0:	ff 75 f0             	pushl  -0x10(%ebp)
  801ce3:	6a 00                	push   $0x0
  801ce5:	e8 57 ee ff ff       	call   800b41 <sys_page_alloc>
  801cea:	89 c3                	mov    %eax,%ebx
  801cec:	83 c4 10             	add    $0x10,%esp
  801cef:	85 c0                	test   %eax,%eax
  801cf1:	0f 88 c3 00 00 00    	js     801dba <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cf7:	83 ec 0c             	sub    $0xc,%esp
  801cfa:	ff 75 f4             	pushl  -0xc(%ebp)
  801cfd:	e8 9a f5 ff ff       	call   80129c <fd2data>
  801d02:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d04:	83 c4 0c             	add    $0xc,%esp
  801d07:	68 07 04 00 00       	push   $0x407
  801d0c:	50                   	push   %eax
  801d0d:	6a 00                	push   $0x0
  801d0f:	e8 2d ee ff ff       	call   800b41 <sys_page_alloc>
  801d14:	89 c3                	mov    %eax,%ebx
  801d16:	83 c4 10             	add    $0x10,%esp
  801d19:	85 c0                	test   %eax,%eax
  801d1b:	0f 88 89 00 00 00    	js     801daa <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d21:	83 ec 0c             	sub    $0xc,%esp
  801d24:	ff 75 f0             	pushl  -0x10(%ebp)
  801d27:	e8 70 f5 ff ff       	call   80129c <fd2data>
  801d2c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d33:	50                   	push   %eax
  801d34:	6a 00                	push   $0x0
  801d36:	56                   	push   %esi
  801d37:	6a 00                	push   $0x0
  801d39:	e8 46 ee ff ff       	call   800b84 <sys_page_map>
  801d3e:	89 c3                	mov    %eax,%ebx
  801d40:	83 c4 20             	add    $0x20,%esp
  801d43:	85 c0                	test   %eax,%eax
  801d45:	78 55                	js     801d9c <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d47:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d50:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d55:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d5c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d62:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d65:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d67:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d6a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d71:	83 ec 0c             	sub    $0xc,%esp
  801d74:	ff 75 f4             	pushl  -0xc(%ebp)
  801d77:	e8 10 f5 ff ff       	call   80128c <fd2num>
  801d7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d7f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d81:	83 c4 04             	add    $0x4,%esp
  801d84:	ff 75 f0             	pushl  -0x10(%ebp)
  801d87:	e8 00 f5 ff ff       	call   80128c <fd2num>
  801d8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d8f:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801d92:	83 c4 10             	add    $0x10,%esp
  801d95:	ba 00 00 00 00       	mov    $0x0,%edx
  801d9a:	eb 30                	jmp    801dcc <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d9c:	83 ec 08             	sub    $0x8,%esp
  801d9f:	56                   	push   %esi
  801da0:	6a 00                	push   $0x0
  801da2:	e8 1f ee ff ff       	call   800bc6 <sys_page_unmap>
  801da7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801daa:	83 ec 08             	sub    $0x8,%esp
  801dad:	ff 75 f0             	pushl  -0x10(%ebp)
  801db0:	6a 00                	push   $0x0
  801db2:	e8 0f ee ff ff       	call   800bc6 <sys_page_unmap>
  801db7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801dba:	83 ec 08             	sub    $0x8,%esp
  801dbd:	ff 75 f4             	pushl  -0xc(%ebp)
  801dc0:	6a 00                	push   $0x0
  801dc2:	e8 ff ed ff ff       	call   800bc6 <sys_page_unmap>
  801dc7:	83 c4 10             	add    $0x10,%esp
  801dca:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801dcc:	89 d0                	mov    %edx,%eax
  801dce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dd1:	5b                   	pop    %ebx
  801dd2:	5e                   	pop    %esi
  801dd3:	5d                   	pop    %ebp
  801dd4:	c3                   	ret    

00801dd5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801dd5:	55                   	push   %ebp
  801dd6:	89 e5                	mov    %esp,%ebp
  801dd8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ddb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dde:	50                   	push   %eax
  801ddf:	ff 75 08             	pushl  0x8(%ebp)
  801de2:	e8 1b f5 ff ff       	call   801302 <fd_lookup>
  801de7:	83 c4 10             	add    $0x10,%esp
  801dea:	85 c0                	test   %eax,%eax
  801dec:	78 18                	js     801e06 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801dee:	83 ec 0c             	sub    $0xc,%esp
  801df1:	ff 75 f4             	pushl  -0xc(%ebp)
  801df4:	e8 a3 f4 ff ff       	call   80129c <fd2data>
	return _pipeisclosed(fd, p);
  801df9:	89 c2                	mov    %eax,%edx
  801dfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dfe:	e8 18 fd ff ff       	call   801b1b <_pipeisclosed>
  801e03:	83 c4 10             	add    $0x10,%esp
}
  801e06:	c9                   	leave  
  801e07:	c3                   	ret    

00801e08 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e08:	55                   	push   %ebp
  801e09:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e0b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e10:	5d                   	pop    %ebp
  801e11:	c3                   	ret    

00801e12 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e12:	55                   	push   %ebp
  801e13:	89 e5                	mov    %esp,%ebp
  801e15:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e18:	68 76 29 80 00       	push   $0x802976
  801e1d:	ff 75 0c             	pushl  0xc(%ebp)
  801e20:	e8 19 e9 ff ff       	call   80073e <strcpy>
	return 0;
}
  801e25:	b8 00 00 00 00       	mov    $0x0,%eax
  801e2a:	c9                   	leave  
  801e2b:	c3                   	ret    

00801e2c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e2c:	55                   	push   %ebp
  801e2d:	89 e5                	mov    %esp,%ebp
  801e2f:	57                   	push   %edi
  801e30:	56                   	push   %esi
  801e31:	53                   	push   %ebx
  801e32:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e38:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e3d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e43:	eb 2d                	jmp    801e72 <devcons_write+0x46>
		m = n - tot;
  801e45:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e48:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e4a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e4d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e52:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e55:	83 ec 04             	sub    $0x4,%esp
  801e58:	53                   	push   %ebx
  801e59:	03 45 0c             	add    0xc(%ebp),%eax
  801e5c:	50                   	push   %eax
  801e5d:	57                   	push   %edi
  801e5e:	e8 6d ea ff ff       	call   8008d0 <memmove>
		sys_cputs(buf, m);
  801e63:	83 c4 08             	add    $0x8,%esp
  801e66:	53                   	push   %ebx
  801e67:	57                   	push   %edi
  801e68:	e8 18 ec ff ff       	call   800a85 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e6d:	01 de                	add    %ebx,%esi
  801e6f:	83 c4 10             	add    $0x10,%esp
  801e72:	89 f0                	mov    %esi,%eax
  801e74:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e77:	72 cc                	jb     801e45 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e7c:	5b                   	pop    %ebx
  801e7d:	5e                   	pop    %esi
  801e7e:	5f                   	pop    %edi
  801e7f:	5d                   	pop    %ebp
  801e80:	c3                   	ret    

00801e81 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e81:	55                   	push   %ebp
  801e82:	89 e5                	mov    %esp,%ebp
  801e84:	83 ec 08             	sub    $0x8,%esp
  801e87:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e8c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e90:	74 2a                	je     801ebc <devcons_read+0x3b>
  801e92:	eb 05                	jmp    801e99 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e94:	e8 89 ec ff ff       	call   800b22 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e99:	e8 05 ec ff ff       	call   800aa3 <sys_cgetc>
  801e9e:	85 c0                	test   %eax,%eax
  801ea0:	74 f2                	je     801e94 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ea2:	85 c0                	test   %eax,%eax
  801ea4:	78 16                	js     801ebc <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ea6:	83 f8 04             	cmp    $0x4,%eax
  801ea9:	74 0c                	je     801eb7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801eab:	8b 55 0c             	mov    0xc(%ebp),%edx
  801eae:	88 02                	mov    %al,(%edx)
	return 1;
  801eb0:	b8 01 00 00 00       	mov    $0x1,%eax
  801eb5:	eb 05                	jmp    801ebc <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801eb7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ebc:	c9                   	leave  
  801ebd:	c3                   	ret    

00801ebe <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ebe:	55                   	push   %ebp
  801ebf:	89 e5                	mov    %esp,%ebp
  801ec1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ec4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ec7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801eca:	6a 01                	push   $0x1
  801ecc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ecf:	50                   	push   %eax
  801ed0:	e8 b0 eb ff ff       	call   800a85 <sys_cputs>
}
  801ed5:	83 c4 10             	add    $0x10,%esp
  801ed8:	c9                   	leave  
  801ed9:	c3                   	ret    

00801eda <getchar>:

int
getchar(void)
{
  801eda:	55                   	push   %ebp
  801edb:	89 e5                	mov    %esp,%ebp
  801edd:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ee0:	6a 01                	push   $0x1
  801ee2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ee5:	50                   	push   %eax
  801ee6:	6a 00                	push   $0x0
  801ee8:	e8 7e f6 ff ff       	call   80156b <read>
	if (r < 0)
  801eed:	83 c4 10             	add    $0x10,%esp
  801ef0:	85 c0                	test   %eax,%eax
  801ef2:	78 0f                	js     801f03 <getchar+0x29>
		return r;
	if (r < 1)
  801ef4:	85 c0                	test   %eax,%eax
  801ef6:	7e 06                	jle    801efe <getchar+0x24>
		return -E_EOF;
	return c;
  801ef8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801efc:	eb 05                	jmp    801f03 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801efe:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f03:	c9                   	leave  
  801f04:	c3                   	ret    

00801f05 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f05:	55                   	push   %ebp
  801f06:	89 e5                	mov    %esp,%ebp
  801f08:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f0b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f0e:	50                   	push   %eax
  801f0f:	ff 75 08             	pushl  0x8(%ebp)
  801f12:	e8 eb f3 ff ff       	call   801302 <fd_lookup>
  801f17:	83 c4 10             	add    $0x10,%esp
  801f1a:	85 c0                	test   %eax,%eax
  801f1c:	78 11                	js     801f2f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f21:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f27:	39 10                	cmp    %edx,(%eax)
  801f29:	0f 94 c0             	sete   %al
  801f2c:	0f b6 c0             	movzbl %al,%eax
}
  801f2f:	c9                   	leave  
  801f30:	c3                   	ret    

00801f31 <opencons>:

int
opencons(void)
{
  801f31:	55                   	push   %ebp
  801f32:	89 e5                	mov    %esp,%ebp
  801f34:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f37:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f3a:	50                   	push   %eax
  801f3b:	e8 73 f3 ff ff       	call   8012b3 <fd_alloc>
  801f40:	83 c4 10             	add    $0x10,%esp
		return r;
  801f43:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f45:	85 c0                	test   %eax,%eax
  801f47:	78 3e                	js     801f87 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f49:	83 ec 04             	sub    $0x4,%esp
  801f4c:	68 07 04 00 00       	push   $0x407
  801f51:	ff 75 f4             	pushl  -0xc(%ebp)
  801f54:	6a 00                	push   $0x0
  801f56:	e8 e6 eb ff ff       	call   800b41 <sys_page_alloc>
  801f5b:	83 c4 10             	add    $0x10,%esp
		return r;
  801f5e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f60:	85 c0                	test   %eax,%eax
  801f62:	78 23                	js     801f87 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f64:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f6d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f72:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f79:	83 ec 0c             	sub    $0xc,%esp
  801f7c:	50                   	push   %eax
  801f7d:	e8 0a f3 ff ff       	call   80128c <fd2num>
  801f82:	89 c2                	mov    %eax,%edx
  801f84:	83 c4 10             	add    $0x10,%esp
}
  801f87:	89 d0                	mov    %edx,%eax
  801f89:	c9                   	leave  
  801f8a:	c3                   	ret    

00801f8b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f8b:	55                   	push   %ebp
  801f8c:	89 e5                	mov    %esp,%ebp
  801f8e:	56                   	push   %esi
  801f8f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f90:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f93:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801f99:	e8 65 eb ff ff       	call   800b03 <sys_getenvid>
  801f9e:	83 ec 0c             	sub    $0xc,%esp
  801fa1:	ff 75 0c             	pushl  0xc(%ebp)
  801fa4:	ff 75 08             	pushl  0x8(%ebp)
  801fa7:	56                   	push   %esi
  801fa8:	50                   	push   %eax
  801fa9:	68 84 29 80 00       	push   $0x802984
  801fae:	e8 06 e2 ff ff       	call   8001b9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801fb3:	83 c4 18             	add    $0x18,%esp
  801fb6:	53                   	push   %ebx
  801fb7:	ff 75 10             	pushl  0x10(%ebp)
  801fba:	e8 a9 e1 ff ff       	call   800168 <vcprintf>
	cprintf("\n");
  801fbf:	c7 04 24 7b 28 80 00 	movl   $0x80287b,(%esp)
  801fc6:	e8 ee e1 ff ff       	call   8001b9 <cprintf>
  801fcb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801fce:	cc                   	int3   
  801fcf:	eb fd                	jmp    801fce <_panic+0x43>

00801fd1 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fd1:	55                   	push   %ebp
  801fd2:	89 e5                	mov    %esp,%ebp
  801fd4:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801fd7:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fde:	75 2a                	jne    80200a <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801fe0:	83 ec 04             	sub    $0x4,%esp
  801fe3:	6a 07                	push   $0x7
  801fe5:	68 00 f0 bf ee       	push   $0xeebff000
  801fea:	6a 00                	push   $0x0
  801fec:	e8 50 eb ff ff       	call   800b41 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801ff1:	83 c4 10             	add    $0x10,%esp
  801ff4:	85 c0                	test   %eax,%eax
  801ff6:	79 12                	jns    80200a <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801ff8:	50                   	push   %eax
  801ff9:	68 92 28 80 00       	push   $0x802892
  801ffe:	6a 23                	push   $0x23
  802000:	68 a8 29 80 00       	push   $0x8029a8
  802005:	e8 81 ff ff ff       	call   801f8b <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80200a:	8b 45 08             	mov    0x8(%ebp),%eax
  80200d:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802012:	83 ec 08             	sub    $0x8,%esp
  802015:	68 3c 20 80 00       	push   $0x80203c
  80201a:	6a 00                	push   $0x0
  80201c:	e8 6b ec ff ff       	call   800c8c <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802021:	83 c4 10             	add    $0x10,%esp
  802024:	85 c0                	test   %eax,%eax
  802026:	79 12                	jns    80203a <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802028:	50                   	push   %eax
  802029:	68 92 28 80 00       	push   $0x802892
  80202e:	6a 2c                	push   $0x2c
  802030:	68 a8 29 80 00       	push   $0x8029a8
  802035:	e8 51 ff ff ff       	call   801f8b <_panic>
	}
}
  80203a:	c9                   	leave  
  80203b:	c3                   	ret    

0080203c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80203c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80203d:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802042:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802044:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802047:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  80204b:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802050:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802054:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802056:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802059:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  80205a:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80205d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  80205e:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80205f:	c3                   	ret    

00802060 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802060:	55                   	push   %ebp
  802061:	89 e5                	mov    %esp,%ebp
  802063:	56                   	push   %esi
  802064:	53                   	push   %ebx
  802065:	8b 75 08             	mov    0x8(%ebp),%esi
  802068:	8b 45 0c             	mov    0xc(%ebp),%eax
  80206b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80206e:	85 c0                	test   %eax,%eax
  802070:	75 12                	jne    802084 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802072:	83 ec 0c             	sub    $0xc,%esp
  802075:	68 00 00 c0 ee       	push   $0xeec00000
  80207a:	e8 72 ec ff ff       	call   800cf1 <sys_ipc_recv>
  80207f:	83 c4 10             	add    $0x10,%esp
  802082:	eb 0c                	jmp    802090 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802084:	83 ec 0c             	sub    $0xc,%esp
  802087:	50                   	push   %eax
  802088:	e8 64 ec ff ff       	call   800cf1 <sys_ipc_recv>
  80208d:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802090:	85 f6                	test   %esi,%esi
  802092:	0f 95 c1             	setne  %cl
  802095:	85 db                	test   %ebx,%ebx
  802097:	0f 95 c2             	setne  %dl
  80209a:	84 d1                	test   %dl,%cl
  80209c:	74 09                	je     8020a7 <ipc_recv+0x47>
  80209e:	89 c2                	mov    %eax,%edx
  8020a0:	c1 ea 1f             	shr    $0x1f,%edx
  8020a3:	84 d2                	test   %dl,%dl
  8020a5:	75 2d                	jne    8020d4 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8020a7:	85 f6                	test   %esi,%esi
  8020a9:	74 0d                	je     8020b8 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8020ab:	a1 04 40 80 00       	mov    0x804004,%eax
  8020b0:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  8020b6:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8020b8:	85 db                	test   %ebx,%ebx
  8020ba:	74 0d                	je     8020c9 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8020bc:	a1 04 40 80 00       	mov    0x804004,%eax
  8020c1:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8020c7:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8020c9:	a1 04 40 80 00       	mov    0x804004,%eax
  8020ce:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  8020d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020d7:	5b                   	pop    %ebx
  8020d8:	5e                   	pop    %esi
  8020d9:	5d                   	pop    %ebp
  8020da:	c3                   	ret    

008020db <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020db:	55                   	push   %ebp
  8020dc:	89 e5                	mov    %esp,%ebp
  8020de:	57                   	push   %edi
  8020df:	56                   	push   %esi
  8020e0:	53                   	push   %ebx
  8020e1:	83 ec 0c             	sub    $0xc,%esp
  8020e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020e7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8020ed:	85 db                	test   %ebx,%ebx
  8020ef:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8020f4:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8020f7:	ff 75 14             	pushl  0x14(%ebp)
  8020fa:	53                   	push   %ebx
  8020fb:	56                   	push   %esi
  8020fc:	57                   	push   %edi
  8020fd:	e8 cc eb ff ff       	call   800cce <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802102:	89 c2                	mov    %eax,%edx
  802104:	c1 ea 1f             	shr    $0x1f,%edx
  802107:	83 c4 10             	add    $0x10,%esp
  80210a:	84 d2                	test   %dl,%dl
  80210c:	74 17                	je     802125 <ipc_send+0x4a>
  80210e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802111:	74 12                	je     802125 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802113:	50                   	push   %eax
  802114:	68 b6 29 80 00       	push   $0x8029b6
  802119:	6a 47                	push   $0x47
  80211b:	68 c4 29 80 00       	push   $0x8029c4
  802120:	e8 66 fe ff ff       	call   801f8b <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802125:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802128:	75 07                	jne    802131 <ipc_send+0x56>
			sys_yield();
  80212a:	e8 f3 e9 ff ff       	call   800b22 <sys_yield>
  80212f:	eb c6                	jmp    8020f7 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802131:	85 c0                	test   %eax,%eax
  802133:	75 c2                	jne    8020f7 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802135:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802138:	5b                   	pop    %ebx
  802139:	5e                   	pop    %esi
  80213a:	5f                   	pop    %edi
  80213b:	5d                   	pop    %ebp
  80213c:	c3                   	ret    

0080213d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80213d:	55                   	push   %ebp
  80213e:	89 e5                	mov    %esp,%ebp
  802140:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802143:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802148:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  80214e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802154:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  80215a:	39 ca                	cmp    %ecx,%edx
  80215c:	75 13                	jne    802171 <ipc_find_env+0x34>
			return envs[i].env_id;
  80215e:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  802164:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802169:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80216f:	eb 0f                	jmp    802180 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802171:	83 c0 01             	add    $0x1,%eax
  802174:	3d 00 04 00 00       	cmp    $0x400,%eax
  802179:	75 cd                	jne    802148 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80217b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802180:	5d                   	pop    %ebp
  802181:	c3                   	ret    

00802182 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802182:	55                   	push   %ebp
  802183:	89 e5                	mov    %esp,%ebp
  802185:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802188:	89 d0                	mov    %edx,%eax
  80218a:	c1 e8 16             	shr    $0x16,%eax
  80218d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802194:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802199:	f6 c1 01             	test   $0x1,%cl
  80219c:	74 1d                	je     8021bb <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80219e:	c1 ea 0c             	shr    $0xc,%edx
  8021a1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021a8:	f6 c2 01             	test   $0x1,%dl
  8021ab:	74 0e                	je     8021bb <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021ad:	c1 ea 0c             	shr    $0xc,%edx
  8021b0:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021b7:	ef 
  8021b8:	0f b7 c0             	movzwl %ax,%eax
}
  8021bb:	5d                   	pop    %ebp
  8021bc:	c3                   	ret    
  8021bd:	66 90                	xchg   %ax,%ax
  8021bf:	90                   	nop

008021c0 <__udivdi3>:
  8021c0:	55                   	push   %ebp
  8021c1:	57                   	push   %edi
  8021c2:	56                   	push   %esi
  8021c3:	53                   	push   %ebx
  8021c4:	83 ec 1c             	sub    $0x1c,%esp
  8021c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8021cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8021d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021d7:	85 f6                	test   %esi,%esi
  8021d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021dd:	89 ca                	mov    %ecx,%edx
  8021df:	89 f8                	mov    %edi,%eax
  8021e1:	75 3d                	jne    802220 <__udivdi3+0x60>
  8021e3:	39 cf                	cmp    %ecx,%edi
  8021e5:	0f 87 c5 00 00 00    	ja     8022b0 <__udivdi3+0xf0>
  8021eb:	85 ff                	test   %edi,%edi
  8021ed:	89 fd                	mov    %edi,%ebp
  8021ef:	75 0b                	jne    8021fc <__udivdi3+0x3c>
  8021f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021f6:	31 d2                	xor    %edx,%edx
  8021f8:	f7 f7                	div    %edi
  8021fa:	89 c5                	mov    %eax,%ebp
  8021fc:	89 c8                	mov    %ecx,%eax
  8021fe:	31 d2                	xor    %edx,%edx
  802200:	f7 f5                	div    %ebp
  802202:	89 c1                	mov    %eax,%ecx
  802204:	89 d8                	mov    %ebx,%eax
  802206:	89 cf                	mov    %ecx,%edi
  802208:	f7 f5                	div    %ebp
  80220a:	89 c3                	mov    %eax,%ebx
  80220c:	89 d8                	mov    %ebx,%eax
  80220e:	89 fa                	mov    %edi,%edx
  802210:	83 c4 1c             	add    $0x1c,%esp
  802213:	5b                   	pop    %ebx
  802214:	5e                   	pop    %esi
  802215:	5f                   	pop    %edi
  802216:	5d                   	pop    %ebp
  802217:	c3                   	ret    
  802218:	90                   	nop
  802219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802220:	39 ce                	cmp    %ecx,%esi
  802222:	77 74                	ja     802298 <__udivdi3+0xd8>
  802224:	0f bd fe             	bsr    %esi,%edi
  802227:	83 f7 1f             	xor    $0x1f,%edi
  80222a:	0f 84 98 00 00 00    	je     8022c8 <__udivdi3+0x108>
  802230:	bb 20 00 00 00       	mov    $0x20,%ebx
  802235:	89 f9                	mov    %edi,%ecx
  802237:	89 c5                	mov    %eax,%ebp
  802239:	29 fb                	sub    %edi,%ebx
  80223b:	d3 e6                	shl    %cl,%esi
  80223d:	89 d9                	mov    %ebx,%ecx
  80223f:	d3 ed                	shr    %cl,%ebp
  802241:	89 f9                	mov    %edi,%ecx
  802243:	d3 e0                	shl    %cl,%eax
  802245:	09 ee                	or     %ebp,%esi
  802247:	89 d9                	mov    %ebx,%ecx
  802249:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80224d:	89 d5                	mov    %edx,%ebp
  80224f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802253:	d3 ed                	shr    %cl,%ebp
  802255:	89 f9                	mov    %edi,%ecx
  802257:	d3 e2                	shl    %cl,%edx
  802259:	89 d9                	mov    %ebx,%ecx
  80225b:	d3 e8                	shr    %cl,%eax
  80225d:	09 c2                	or     %eax,%edx
  80225f:	89 d0                	mov    %edx,%eax
  802261:	89 ea                	mov    %ebp,%edx
  802263:	f7 f6                	div    %esi
  802265:	89 d5                	mov    %edx,%ebp
  802267:	89 c3                	mov    %eax,%ebx
  802269:	f7 64 24 0c          	mull   0xc(%esp)
  80226d:	39 d5                	cmp    %edx,%ebp
  80226f:	72 10                	jb     802281 <__udivdi3+0xc1>
  802271:	8b 74 24 08          	mov    0x8(%esp),%esi
  802275:	89 f9                	mov    %edi,%ecx
  802277:	d3 e6                	shl    %cl,%esi
  802279:	39 c6                	cmp    %eax,%esi
  80227b:	73 07                	jae    802284 <__udivdi3+0xc4>
  80227d:	39 d5                	cmp    %edx,%ebp
  80227f:	75 03                	jne    802284 <__udivdi3+0xc4>
  802281:	83 eb 01             	sub    $0x1,%ebx
  802284:	31 ff                	xor    %edi,%edi
  802286:	89 d8                	mov    %ebx,%eax
  802288:	89 fa                	mov    %edi,%edx
  80228a:	83 c4 1c             	add    $0x1c,%esp
  80228d:	5b                   	pop    %ebx
  80228e:	5e                   	pop    %esi
  80228f:	5f                   	pop    %edi
  802290:	5d                   	pop    %ebp
  802291:	c3                   	ret    
  802292:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802298:	31 ff                	xor    %edi,%edi
  80229a:	31 db                	xor    %ebx,%ebx
  80229c:	89 d8                	mov    %ebx,%eax
  80229e:	89 fa                	mov    %edi,%edx
  8022a0:	83 c4 1c             	add    $0x1c,%esp
  8022a3:	5b                   	pop    %ebx
  8022a4:	5e                   	pop    %esi
  8022a5:	5f                   	pop    %edi
  8022a6:	5d                   	pop    %ebp
  8022a7:	c3                   	ret    
  8022a8:	90                   	nop
  8022a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022b0:	89 d8                	mov    %ebx,%eax
  8022b2:	f7 f7                	div    %edi
  8022b4:	31 ff                	xor    %edi,%edi
  8022b6:	89 c3                	mov    %eax,%ebx
  8022b8:	89 d8                	mov    %ebx,%eax
  8022ba:	89 fa                	mov    %edi,%edx
  8022bc:	83 c4 1c             	add    $0x1c,%esp
  8022bf:	5b                   	pop    %ebx
  8022c0:	5e                   	pop    %esi
  8022c1:	5f                   	pop    %edi
  8022c2:	5d                   	pop    %ebp
  8022c3:	c3                   	ret    
  8022c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022c8:	39 ce                	cmp    %ecx,%esi
  8022ca:	72 0c                	jb     8022d8 <__udivdi3+0x118>
  8022cc:	31 db                	xor    %ebx,%ebx
  8022ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8022d2:	0f 87 34 ff ff ff    	ja     80220c <__udivdi3+0x4c>
  8022d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8022dd:	e9 2a ff ff ff       	jmp    80220c <__udivdi3+0x4c>
  8022e2:	66 90                	xchg   %ax,%ax
  8022e4:	66 90                	xchg   %ax,%ax
  8022e6:	66 90                	xchg   %ax,%ax
  8022e8:	66 90                	xchg   %ax,%ax
  8022ea:	66 90                	xchg   %ax,%ax
  8022ec:	66 90                	xchg   %ax,%ax
  8022ee:	66 90                	xchg   %ax,%ax

008022f0 <__umoddi3>:
  8022f0:	55                   	push   %ebp
  8022f1:	57                   	push   %edi
  8022f2:	56                   	push   %esi
  8022f3:	53                   	push   %ebx
  8022f4:	83 ec 1c             	sub    $0x1c,%esp
  8022f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802303:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802307:	85 d2                	test   %edx,%edx
  802309:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80230d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802311:	89 f3                	mov    %esi,%ebx
  802313:	89 3c 24             	mov    %edi,(%esp)
  802316:	89 74 24 04          	mov    %esi,0x4(%esp)
  80231a:	75 1c                	jne    802338 <__umoddi3+0x48>
  80231c:	39 f7                	cmp    %esi,%edi
  80231e:	76 50                	jbe    802370 <__umoddi3+0x80>
  802320:	89 c8                	mov    %ecx,%eax
  802322:	89 f2                	mov    %esi,%edx
  802324:	f7 f7                	div    %edi
  802326:	89 d0                	mov    %edx,%eax
  802328:	31 d2                	xor    %edx,%edx
  80232a:	83 c4 1c             	add    $0x1c,%esp
  80232d:	5b                   	pop    %ebx
  80232e:	5e                   	pop    %esi
  80232f:	5f                   	pop    %edi
  802330:	5d                   	pop    %ebp
  802331:	c3                   	ret    
  802332:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802338:	39 f2                	cmp    %esi,%edx
  80233a:	89 d0                	mov    %edx,%eax
  80233c:	77 52                	ja     802390 <__umoddi3+0xa0>
  80233e:	0f bd ea             	bsr    %edx,%ebp
  802341:	83 f5 1f             	xor    $0x1f,%ebp
  802344:	75 5a                	jne    8023a0 <__umoddi3+0xb0>
  802346:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80234a:	0f 82 e0 00 00 00    	jb     802430 <__umoddi3+0x140>
  802350:	39 0c 24             	cmp    %ecx,(%esp)
  802353:	0f 86 d7 00 00 00    	jbe    802430 <__umoddi3+0x140>
  802359:	8b 44 24 08          	mov    0x8(%esp),%eax
  80235d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802361:	83 c4 1c             	add    $0x1c,%esp
  802364:	5b                   	pop    %ebx
  802365:	5e                   	pop    %esi
  802366:	5f                   	pop    %edi
  802367:	5d                   	pop    %ebp
  802368:	c3                   	ret    
  802369:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802370:	85 ff                	test   %edi,%edi
  802372:	89 fd                	mov    %edi,%ebp
  802374:	75 0b                	jne    802381 <__umoddi3+0x91>
  802376:	b8 01 00 00 00       	mov    $0x1,%eax
  80237b:	31 d2                	xor    %edx,%edx
  80237d:	f7 f7                	div    %edi
  80237f:	89 c5                	mov    %eax,%ebp
  802381:	89 f0                	mov    %esi,%eax
  802383:	31 d2                	xor    %edx,%edx
  802385:	f7 f5                	div    %ebp
  802387:	89 c8                	mov    %ecx,%eax
  802389:	f7 f5                	div    %ebp
  80238b:	89 d0                	mov    %edx,%eax
  80238d:	eb 99                	jmp    802328 <__umoddi3+0x38>
  80238f:	90                   	nop
  802390:	89 c8                	mov    %ecx,%eax
  802392:	89 f2                	mov    %esi,%edx
  802394:	83 c4 1c             	add    $0x1c,%esp
  802397:	5b                   	pop    %ebx
  802398:	5e                   	pop    %esi
  802399:	5f                   	pop    %edi
  80239a:	5d                   	pop    %ebp
  80239b:	c3                   	ret    
  80239c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023a0:	8b 34 24             	mov    (%esp),%esi
  8023a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023a8:	89 e9                	mov    %ebp,%ecx
  8023aa:	29 ef                	sub    %ebp,%edi
  8023ac:	d3 e0                	shl    %cl,%eax
  8023ae:	89 f9                	mov    %edi,%ecx
  8023b0:	89 f2                	mov    %esi,%edx
  8023b2:	d3 ea                	shr    %cl,%edx
  8023b4:	89 e9                	mov    %ebp,%ecx
  8023b6:	09 c2                	or     %eax,%edx
  8023b8:	89 d8                	mov    %ebx,%eax
  8023ba:	89 14 24             	mov    %edx,(%esp)
  8023bd:	89 f2                	mov    %esi,%edx
  8023bf:	d3 e2                	shl    %cl,%edx
  8023c1:	89 f9                	mov    %edi,%ecx
  8023c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8023cb:	d3 e8                	shr    %cl,%eax
  8023cd:	89 e9                	mov    %ebp,%ecx
  8023cf:	89 c6                	mov    %eax,%esi
  8023d1:	d3 e3                	shl    %cl,%ebx
  8023d3:	89 f9                	mov    %edi,%ecx
  8023d5:	89 d0                	mov    %edx,%eax
  8023d7:	d3 e8                	shr    %cl,%eax
  8023d9:	89 e9                	mov    %ebp,%ecx
  8023db:	09 d8                	or     %ebx,%eax
  8023dd:	89 d3                	mov    %edx,%ebx
  8023df:	89 f2                	mov    %esi,%edx
  8023e1:	f7 34 24             	divl   (%esp)
  8023e4:	89 d6                	mov    %edx,%esi
  8023e6:	d3 e3                	shl    %cl,%ebx
  8023e8:	f7 64 24 04          	mull   0x4(%esp)
  8023ec:	39 d6                	cmp    %edx,%esi
  8023ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023f2:	89 d1                	mov    %edx,%ecx
  8023f4:	89 c3                	mov    %eax,%ebx
  8023f6:	72 08                	jb     802400 <__umoddi3+0x110>
  8023f8:	75 11                	jne    80240b <__umoddi3+0x11b>
  8023fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8023fe:	73 0b                	jae    80240b <__umoddi3+0x11b>
  802400:	2b 44 24 04          	sub    0x4(%esp),%eax
  802404:	1b 14 24             	sbb    (%esp),%edx
  802407:	89 d1                	mov    %edx,%ecx
  802409:	89 c3                	mov    %eax,%ebx
  80240b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80240f:	29 da                	sub    %ebx,%edx
  802411:	19 ce                	sbb    %ecx,%esi
  802413:	89 f9                	mov    %edi,%ecx
  802415:	89 f0                	mov    %esi,%eax
  802417:	d3 e0                	shl    %cl,%eax
  802419:	89 e9                	mov    %ebp,%ecx
  80241b:	d3 ea                	shr    %cl,%edx
  80241d:	89 e9                	mov    %ebp,%ecx
  80241f:	d3 ee                	shr    %cl,%esi
  802421:	09 d0                	or     %edx,%eax
  802423:	89 f2                	mov    %esi,%edx
  802425:	83 c4 1c             	add    $0x1c,%esp
  802428:	5b                   	pop    %ebx
  802429:	5e                   	pop    %esi
  80242a:	5f                   	pop    %edi
  80242b:	5d                   	pop    %ebp
  80242c:	c3                   	ret    
  80242d:	8d 76 00             	lea    0x0(%esi),%esi
  802430:	29 f9                	sub    %edi,%ecx
  802432:	19 d6                	sbb    %edx,%esi
  802434:	89 74 24 04          	mov    %esi,0x4(%esp)
  802438:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80243c:	e9 18 ff ff ff       	jmp    802359 <__umoddi3+0x69>
