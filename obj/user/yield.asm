
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
  80003f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800045:	50                   	push   %eax
  800046:	68 e0 24 80 00       	push   $0x8024e0
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
  800062:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800068:	83 ec 04             	sub    $0x4,%esp
  80006b:	53                   	push   %ebx
  80006c:	50                   	push   %eax
  80006d:	68 00 25 80 00       	push   $0x802500
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
  800087:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80008d:	83 ec 08             	sub    $0x8,%esp
  800090:	50                   	push   %eax
  800091:	68 2c 25 80 00       	push   $0x80252c
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
  8000b8:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8000be:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c3:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

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

void 
thread_main(/*uintptr_t eip*/)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

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
  800112:	e8 c5 13 00 00       	call   8014dc <close_all>
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
  80021c:	e8 1f 20 00 00       	call   802240 <__udivdi3>
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
  80025f:	e8 0c 21 00 00       	call   802370 <__umoddi3>
  800264:	83 c4 14             	add    $0x14,%esp
  800267:	0f be 80 55 25 80 00 	movsbl 0x802555(%eax),%eax
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
  800363:	ff 24 85 a0 26 80 00 	jmp    *0x8026a0(,%eax,4)
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
  800427:	8b 14 85 00 28 80 00 	mov    0x802800(,%eax,4),%edx
  80042e:	85 d2                	test   %edx,%edx
  800430:	75 18                	jne    80044a <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800432:	50                   	push   %eax
  800433:	68 6d 25 80 00       	push   $0x80256d
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
  80044b:	68 8d 2a 80 00       	push   $0x802a8d
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
  80046f:	b8 66 25 80 00       	mov    $0x802566,%eax
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
  800aea:	68 5f 28 80 00       	push   $0x80285f
  800aef:	6a 23                	push   $0x23
  800af1:	68 7c 28 80 00       	push   $0x80287c
  800af6:	e8 12 15 00 00       	call   80200d <_panic>

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
  800b6b:	68 5f 28 80 00       	push   $0x80285f
  800b70:	6a 23                	push   $0x23
  800b72:	68 7c 28 80 00       	push   $0x80287c
  800b77:	e8 91 14 00 00       	call   80200d <_panic>

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
  800bad:	68 5f 28 80 00       	push   $0x80285f
  800bb2:	6a 23                	push   $0x23
  800bb4:	68 7c 28 80 00       	push   $0x80287c
  800bb9:	e8 4f 14 00 00       	call   80200d <_panic>

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
  800bef:	68 5f 28 80 00       	push   $0x80285f
  800bf4:	6a 23                	push   $0x23
  800bf6:	68 7c 28 80 00       	push   $0x80287c
  800bfb:	e8 0d 14 00 00       	call   80200d <_panic>

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
  800c31:	68 5f 28 80 00       	push   $0x80285f
  800c36:	6a 23                	push   $0x23
  800c38:	68 7c 28 80 00       	push   $0x80287c
  800c3d:	e8 cb 13 00 00       	call   80200d <_panic>

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
  800c73:	68 5f 28 80 00       	push   $0x80285f
  800c78:	6a 23                	push   $0x23
  800c7a:	68 7c 28 80 00       	push   $0x80287c
  800c7f:	e8 89 13 00 00       	call   80200d <_panic>
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
  800cb5:	68 5f 28 80 00       	push   $0x80285f
  800cba:	6a 23                	push   $0x23
  800cbc:	68 7c 28 80 00       	push   $0x80287c
  800cc1:	e8 47 13 00 00       	call   80200d <_panic>

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
  800d19:	68 5f 28 80 00       	push   $0x80285f
  800d1e:	6a 23                	push   $0x23
  800d20:	68 7c 28 80 00       	push   $0x80287c
  800d25:	e8 e3 12 00 00       	call   80200d <_panic>

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
  800db8:	68 8a 28 80 00       	push   $0x80288a
  800dbd:	6a 1f                	push   $0x1f
  800dbf:	68 9a 28 80 00       	push   $0x80289a
  800dc4:	e8 44 12 00 00       	call   80200d <_panic>
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
  800de2:	68 a5 28 80 00       	push   $0x8028a5
  800de7:	6a 2d                	push   $0x2d
  800de9:	68 9a 28 80 00       	push   $0x80289a
  800dee:	e8 1a 12 00 00       	call   80200d <_panic>
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
  800e2a:	68 a5 28 80 00       	push   $0x8028a5
  800e2f:	6a 34                	push   $0x34
  800e31:	68 9a 28 80 00       	push   $0x80289a
  800e36:	e8 d2 11 00 00       	call   80200d <_panic>
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
  800e52:	68 a5 28 80 00       	push   $0x8028a5
  800e57:	6a 38                	push   $0x38
  800e59:	68 9a 28 80 00       	push   $0x80289a
  800e5e:	e8 aa 11 00 00       	call   80200d <_panic>
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
  800e76:	e8 d8 11 00 00       	call   802053 <set_pgfault_handler>
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
  800e8f:	68 be 28 80 00       	push   $0x8028be
  800e94:	68 85 00 00 00       	push   $0x85
  800e99:	68 9a 28 80 00       	push   $0x80289a
  800e9e:	e8 6a 11 00 00       	call   80200d <_panic>
  800ea3:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800ea5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ea9:	75 24                	jne    800ecf <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800eab:	e8 53 fc ff ff       	call   800b03 <sys_getenvid>
  800eb0:	25 ff 03 00 00       	and    $0x3ff,%eax
  800eb5:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  800f4b:	68 cc 28 80 00       	push   $0x8028cc
  800f50:	6a 55                	push   $0x55
  800f52:	68 9a 28 80 00       	push   $0x80289a
  800f57:	e8 b1 10 00 00       	call   80200d <_panic>
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
  800f90:	68 cc 28 80 00       	push   $0x8028cc
  800f95:	6a 5c                	push   $0x5c
  800f97:	68 9a 28 80 00       	push   $0x80289a
  800f9c:	e8 6c 10 00 00       	call   80200d <_panic>
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
  800fbe:	68 cc 28 80 00       	push   $0x8028cc
  800fc3:	6a 60                	push   $0x60
  800fc5:	68 9a 28 80 00       	push   $0x80289a
  800fca:	e8 3e 10 00 00       	call   80200d <_panic>
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
  800fe8:	68 cc 28 80 00       	push   $0x8028cc
  800fed:	6a 65                	push   $0x65
  800fef:	68 9a 28 80 00       	push   $0x80289a
  800ff4:	e8 14 10 00 00       	call   80200d <_panic>
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
  801010:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
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
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801045:	55                   	push   %ebp
  801046:	89 e5                	mov    %esp,%ebp
  801048:	56                   	push   %esi
  801049:	53                   	push   %ebx
  80104a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  80104d:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  801053:	83 ec 08             	sub    $0x8,%esp
  801056:	53                   	push   %ebx
  801057:	68 5c 29 80 00       	push   $0x80295c
  80105c:	e8 58 f1 ff ff       	call   8001b9 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801061:	c7 04 24 ec 00 80 00 	movl   $0x8000ec,(%esp)
  801068:	e8 c5 fc ff ff       	call   800d32 <sys_thread_create>
  80106d:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80106f:	83 c4 08             	add    $0x8,%esp
  801072:	53                   	push   %ebx
  801073:	68 5c 29 80 00       	push   $0x80295c
  801078:	e8 3c f1 ff ff       	call   8001b9 <cprintf>
	return id;
}
  80107d:	89 f0                	mov    %esi,%eax
  80107f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801082:	5b                   	pop    %ebx
  801083:	5e                   	pop    %esi
  801084:	5d                   	pop    %ebp
  801085:	c3                   	ret    

00801086 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  801086:	55                   	push   %ebp
  801087:	89 e5                	mov    %esp,%ebp
  801089:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  80108c:	ff 75 08             	pushl  0x8(%ebp)
  80108f:	e8 be fc ff ff       	call   800d52 <sys_thread_free>
}
  801094:	83 c4 10             	add    $0x10,%esp
  801097:	c9                   	leave  
  801098:	c3                   	ret    

00801099 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  801099:	55                   	push   %ebp
  80109a:	89 e5                	mov    %esp,%ebp
  80109c:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  80109f:	ff 75 08             	pushl  0x8(%ebp)
  8010a2:	e8 cb fc ff ff       	call   800d72 <sys_thread_join>
}
  8010a7:	83 c4 10             	add    $0x10,%esp
  8010aa:	c9                   	leave  
  8010ab:	c3                   	ret    

008010ac <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  8010ac:	55                   	push   %ebp
  8010ad:	89 e5                	mov    %esp,%ebp
  8010af:	56                   	push   %esi
  8010b0:	53                   	push   %ebx
  8010b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8010b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8010b7:	83 ec 04             	sub    $0x4,%esp
  8010ba:	6a 07                	push   $0x7
  8010bc:	6a 00                	push   $0x0
  8010be:	56                   	push   %esi
  8010bf:	e8 7d fa ff ff       	call   800b41 <sys_page_alloc>
	if (r < 0) {
  8010c4:	83 c4 10             	add    $0x10,%esp
  8010c7:	85 c0                	test   %eax,%eax
  8010c9:	79 15                	jns    8010e0 <queue_append+0x34>
		panic("%e\n", r);
  8010cb:	50                   	push   %eax
  8010cc:	68 58 29 80 00       	push   $0x802958
  8010d1:	68 c4 00 00 00       	push   $0xc4
  8010d6:	68 9a 28 80 00       	push   $0x80289a
  8010db:	e8 2d 0f 00 00       	call   80200d <_panic>
	}	
	wt->envid = envid;
  8010e0:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  8010e6:	83 ec 04             	sub    $0x4,%esp
  8010e9:	ff 33                	pushl  (%ebx)
  8010eb:	56                   	push   %esi
  8010ec:	68 80 29 80 00       	push   $0x802980
  8010f1:	e8 c3 f0 ff ff       	call   8001b9 <cprintf>
	if (queue->first == NULL) {
  8010f6:	83 c4 10             	add    $0x10,%esp
  8010f9:	83 3b 00             	cmpl   $0x0,(%ebx)
  8010fc:	75 29                	jne    801127 <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  8010fe:	83 ec 0c             	sub    $0xc,%esp
  801101:	68 e2 28 80 00       	push   $0x8028e2
  801106:	e8 ae f0 ff ff       	call   8001b9 <cprintf>
		queue->first = wt;
  80110b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  801111:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  801118:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80111f:	00 00 00 
  801122:	83 c4 10             	add    $0x10,%esp
  801125:	eb 2b                	jmp    801152 <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  801127:	83 ec 0c             	sub    $0xc,%esp
  80112a:	68 fc 28 80 00       	push   $0x8028fc
  80112f:	e8 85 f0 ff ff       	call   8001b9 <cprintf>
		queue->last->next = wt;
  801134:	8b 43 04             	mov    0x4(%ebx),%eax
  801137:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  80113e:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801145:	00 00 00 
		queue->last = wt;
  801148:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  80114f:	83 c4 10             	add    $0x10,%esp
	}
}
  801152:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801155:	5b                   	pop    %ebx
  801156:	5e                   	pop    %esi
  801157:	5d                   	pop    %ebp
  801158:	c3                   	ret    

00801159 <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  801159:	55                   	push   %ebp
  80115a:	89 e5                	mov    %esp,%ebp
  80115c:	53                   	push   %ebx
  80115d:	83 ec 04             	sub    $0x4,%esp
  801160:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  801163:	8b 02                	mov    (%edx),%eax
  801165:	85 c0                	test   %eax,%eax
  801167:	75 17                	jne    801180 <queue_pop+0x27>
		panic("queue empty!\n");
  801169:	83 ec 04             	sub    $0x4,%esp
  80116c:	68 1a 29 80 00       	push   $0x80291a
  801171:	68 d8 00 00 00       	push   $0xd8
  801176:	68 9a 28 80 00       	push   $0x80289a
  80117b:	e8 8d 0e 00 00       	call   80200d <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  801180:	8b 48 04             	mov    0x4(%eax),%ecx
  801183:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  801185:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  801187:	83 ec 08             	sub    $0x8,%esp
  80118a:	53                   	push   %ebx
  80118b:	68 28 29 80 00       	push   $0x802928
  801190:	e8 24 f0 ff ff       	call   8001b9 <cprintf>
	return envid;
}
  801195:	89 d8                	mov    %ebx,%eax
  801197:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80119a:	c9                   	leave  
  80119b:	c3                   	ret    

0080119c <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  80119c:	55                   	push   %ebp
  80119d:	89 e5                	mov    %esp,%ebp
  80119f:	53                   	push   %ebx
  8011a0:	83 ec 04             	sub    $0x4,%esp
  8011a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  8011a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8011ab:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8011ae:	85 c0                	test   %eax,%eax
  8011b0:	74 5a                	je     80120c <mutex_lock+0x70>
  8011b2:	8b 43 04             	mov    0x4(%ebx),%eax
  8011b5:	83 38 00             	cmpl   $0x0,(%eax)
  8011b8:	75 52                	jne    80120c <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  8011ba:	83 ec 0c             	sub    $0xc,%esp
  8011bd:	68 a8 29 80 00       	push   $0x8029a8
  8011c2:	e8 f2 ef ff ff       	call   8001b9 <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  8011c7:	8b 5b 04             	mov    0x4(%ebx),%ebx
  8011ca:	e8 34 f9 ff ff       	call   800b03 <sys_getenvid>
  8011cf:	83 c4 08             	add    $0x8,%esp
  8011d2:	53                   	push   %ebx
  8011d3:	50                   	push   %eax
  8011d4:	e8 d3 fe ff ff       	call   8010ac <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  8011d9:	e8 25 f9 ff ff       	call   800b03 <sys_getenvid>
  8011de:	83 c4 08             	add    $0x8,%esp
  8011e1:	6a 04                	push   $0x4
  8011e3:	50                   	push   %eax
  8011e4:	e8 1f fa ff ff       	call   800c08 <sys_env_set_status>
		if (r < 0) {
  8011e9:	83 c4 10             	add    $0x10,%esp
  8011ec:	85 c0                	test   %eax,%eax
  8011ee:	79 15                	jns    801205 <mutex_lock+0x69>
			panic("%e\n", r);
  8011f0:	50                   	push   %eax
  8011f1:	68 58 29 80 00       	push   $0x802958
  8011f6:	68 eb 00 00 00       	push   $0xeb
  8011fb:	68 9a 28 80 00       	push   $0x80289a
  801200:	e8 08 0e 00 00       	call   80200d <_panic>
		}
		sys_yield();
  801205:	e8 18 f9 ff ff       	call   800b22 <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  80120a:	eb 18                	jmp    801224 <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  80120c:	83 ec 0c             	sub    $0xc,%esp
  80120f:	68 c8 29 80 00       	push   $0x8029c8
  801214:	e8 a0 ef ff ff       	call   8001b9 <cprintf>
	mtx->owner = sys_getenvid();}
  801219:	e8 e5 f8 ff ff       	call   800b03 <sys_getenvid>
  80121e:	89 43 08             	mov    %eax,0x8(%ebx)
  801221:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  801224:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801227:	c9                   	leave  
  801228:	c3                   	ret    

00801229 <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  801229:	55                   	push   %ebp
  80122a:	89 e5                	mov    %esp,%ebp
  80122c:	53                   	push   %ebx
  80122d:	83 ec 04             	sub    $0x4,%esp
  801230:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801233:	b8 00 00 00 00       	mov    $0x0,%eax
  801238:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  80123b:	8b 43 04             	mov    0x4(%ebx),%eax
  80123e:	83 38 00             	cmpl   $0x0,(%eax)
  801241:	74 33                	je     801276 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  801243:	83 ec 0c             	sub    $0xc,%esp
  801246:	50                   	push   %eax
  801247:	e8 0d ff ff ff       	call   801159 <queue_pop>
  80124c:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  80124f:	83 c4 08             	add    $0x8,%esp
  801252:	6a 02                	push   $0x2
  801254:	50                   	push   %eax
  801255:	e8 ae f9 ff ff       	call   800c08 <sys_env_set_status>
		if (r < 0) {
  80125a:	83 c4 10             	add    $0x10,%esp
  80125d:	85 c0                	test   %eax,%eax
  80125f:	79 15                	jns    801276 <mutex_unlock+0x4d>
			panic("%e\n", r);
  801261:	50                   	push   %eax
  801262:	68 58 29 80 00       	push   $0x802958
  801267:	68 00 01 00 00       	push   $0x100
  80126c:	68 9a 28 80 00       	push   $0x80289a
  801271:	e8 97 0d 00 00       	call   80200d <_panic>
		}
	}

	asm volatile("pause");
  801276:	f3 90                	pause  
	//sys_yield();
}
  801278:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80127b:	c9                   	leave  
  80127c:	c3                   	ret    

0080127d <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  80127d:	55                   	push   %ebp
  80127e:	89 e5                	mov    %esp,%ebp
  801280:	53                   	push   %ebx
  801281:	83 ec 04             	sub    $0x4,%esp
  801284:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  801287:	e8 77 f8 ff ff       	call   800b03 <sys_getenvid>
  80128c:	83 ec 04             	sub    $0x4,%esp
  80128f:	6a 07                	push   $0x7
  801291:	53                   	push   %ebx
  801292:	50                   	push   %eax
  801293:	e8 a9 f8 ff ff       	call   800b41 <sys_page_alloc>
  801298:	83 c4 10             	add    $0x10,%esp
  80129b:	85 c0                	test   %eax,%eax
  80129d:	79 15                	jns    8012b4 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  80129f:	50                   	push   %eax
  8012a0:	68 43 29 80 00       	push   $0x802943
  8012a5:	68 0d 01 00 00       	push   $0x10d
  8012aa:	68 9a 28 80 00       	push   $0x80289a
  8012af:	e8 59 0d 00 00       	call   80200d <_panic>
	}	
	mtx->locked = 0;
  8012b4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  8012ba:	8b 43 04             	mov    0x4(%ebx),%eax
  8012bd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  8012c3:	8b 43 04             	mov    0x4(%ebx),%eax
  8012c6:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  8012cd:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  8012d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d7:	c9                   	leave  
  8012d8:	c3                   	ret    

008012d9 <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  8012d9:	55                   	push   %ebp
  8012da:	89 e5                	mov    %esp,%ebp
  8012dc:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  8012df:	e8 1f f8 ff ff       	call   800b03 <sys_getenvid>
  8012e4:	83 ec 08             	sub    $0x8,%esp
  8012e7:	ff 75 08             	pushl  0x8(%ebp)
  8012ea:	50                   	push   %eax
  8012eb:	e8 d6 f8 ff ff       	call   800bc6 <sys_page_unmap>
	if (r < 0) {
  8012f0:	83 c4 10             	add    $0x10,%esp
  8012f3:	85 c0                	test   %eax,%eax
  8012f5:	79 15                	jns    80130c <mutex_destroy+0x33>
		panic("%e\n", r);
  8012f7:	50                   	push   %eax
  8012f8:	68 58 29 80 00       	push   $0x802958
  8012fd:	68 1a 01 00 00       	push   $0x11a
  801302:	68 9a 28 80 00       	push   $0x80289a
  801307:	e8 01 0d 00 00       	call   80200d <_panic>
	}
}
  80130c:	c9                   	leave  
  80130d:	c3                   	ret    

0080130e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80130e:	55                   	push   %ebp
  80130f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801311:	8b 45 08             	mov    0x8(%ebp),%eax
  801314:	05 00 00 00 30       	add    $0x30000000,%eax
  801319:	c1 e8 0c             	shr    $0xc,%eax
}
  80131c:	5d                   	pop    %ebp
  80131d:	c3                   	ret    

0080131e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80131e:	55                   	push   %ebp
  80131f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801321:	8b 45 08             	mov    0x8(%ebp),%eax
  801324:	05 00 00 00 30       	add    $0x30000000,%eax
  801329:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80132e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801333:	5d                   	pop    %ebp
  801334:	c3                   	ret    

00801335 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801335:	55                   	push   %ebp
  801336:	89 e5                	mov    %esp,%ebp
  801338:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80133b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801340:	89 c2                	mov    %eax,%edx
  801342:	c1 ea 16             	shr    $0x16,%edx
  801345:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80134c:	f6 c2 01             	test   $0x1,%dl
  80134f:	74 11                	je     801362 <fd_alloc+0x2d>
  801351:	89 c2                	mov    %eax,%edx
  801353:	c1 ea 0c             	shr    $0xc,%edx
  801356:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80135d:	f6 c2 01             	test   $0x1,%dl
  801360:	75 09                	jne    80136b <fd_alloc+0x36>
			*fd_store = fd;
  801362:	89 01                	mov    %eax,(%ecx)
			return 0;
  801364:	b8 00 00 00 00       	mov    $0x0,%eax
  801369:	eb 17                	jmp    801382 <fd_alloc+0x4d>
  80136b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801370:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801375:	75 c9                	jne    801340 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801377:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80137d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801382:	5d                   	pop    %ebp
  801383:	c3                   	ret    

00801384 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801384:	55                   	push   %ebp
  801385:	89 e5                	mov    %esp,%ebp
  801387:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80138a:	83 f8 1f             	cmp    $0x1f,%eax
  80138d:	77 36                	ja     8013c5 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80138f:	c1 e0 0c             	shl    $0xc,%eax
  801392:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801397:	89 c2                	mov    %eax,%edx
  801399:	c1 ea 16             	shr    $0x16,%edx
  80139c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013a3:	f6 c2 01             	test   $0x1,%dl
  8013a6:	74 24                	je     8013cc <fd_lookup+0x48>
  8013a8:	89 c2                	mov    %eax,%edx
  8013aa:	c1 ea 0c             	shr    $0xc,%edx
  8013ad:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013b4:	f6 c2 01             	test   $0x1,%dl
  8013b7:	74 1a                	je     8013d3 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013bc:	89 02                	mov    %eax,(%edx)
	return 0;
  8013be:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c3:	eb 13                	jmp    8013d8 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013ca:	eb 0c                	jmp    8013d8 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013d1:	eb 05                	jmp    8013d8 <fd_lookup+0x54>
  8013d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013d8:	5d                   	pop    %ebp
  8013d9:	c3                   	ret    

008013da <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013da:	55                   	push   %ebp
  8013db:	89 e5                	mov    %esp,%ebp
  8013dd:	83 ec 08             	sub    $0x8,%esp
  8013e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013e3:	ba 64 2a 80 00       	mov    $0x802a64,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013e8:	eb 13                	jmp    8013fd <dev_lookup+0x23>
  8013ea:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013ed:	39 08                	cmp    %ecx,(%eax)
  8013ef:	75 0c                	jne    8013fd <dev_lookup+0x23>
			*dev = devtab[i];
  8013f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013f4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8013fb:	eb 31                	jmp    80142e <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013fd:	8b 02                	mov    (%edx),%eax
  8013ff:	85 c0                	test   %eax,%eax
  801401:	75 e7                	jne    8013ea <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801403:	a1 04 40 80 00       	mov    0x804004,%eax
  801408:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80140e:	83 ec 04             	sub    $0x4,%esp
  801411:	51                   	push   %ecx
  801412:	50                   	push   %eax
  801413:	68 e8 29 80 00       	push   $0x8029e8
  801418:	e8 9c ed ff ff       	call   8001b9 <cprintf>
	*dev = 0;
  80141d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801420:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801426:	83 c4 10             	add    $0x10,%esp
  801429:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80142e:	c9                   	leave  
  80142f:	c3                   	ret    

00801430 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801430:	55                   	push   %ebp
  801431:	89 e5                	mov    %esp,%ebp
  801433:	56                   	push   %esi
  801434:	53                   	push   %ebx
  801435:	83 ec 10             	sub    $0x10,%esp
  801438:	8b 75 08             	mov    0x8(%ebp),%esi
  80143b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80143e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801441:	50                   	push   %eax
  801442:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801448:	c1 e8 0c             	shr    $0xc,%eax
  80144b:	50                   	push   %eax
  80144c:	e8 33 ff ff ff       	call   801384 <fd_lookup>
  801451:	83 c4 08             	add    $0x8,%esp
  801454:	85 c0                	test   %eax,%eax
  801456:	78 05                	js     80145d <fd_close+0x2d>
	    || fd != fd2)
  801458:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80145b:	74 0c                	je     801469 <fd_close+0x39>
		return (must_exist ? r : 0);
  80145d:	84 db                	test   %bl,%bl
  80145f:	ba 00 00 00 00       	mov    $0x0,%edx
  801464:	0f 44 c2             	cmove  %edx,%eax
  801467:	eb 41                	jmp    8014aa <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801469:	83 ec 08             	sub    $0x8,%esp
  80146c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80146f:	50                   	push   %eax
  801470:	ff 36                	pushl  (%esi)
  801472:	e8 63 ff ff ff       	call   8013da <dev_lookup>
  801477:	89 c3                	mov    %eax,%ebx
  801479:	83 c4 10             	add    $0x10,%esp
  80147c:	85 c0                	test   %eax,%eax
  80147e:	78 1a                	js     80149a <fd_close+0x6a>
		if (dev->dev_close)
  801480:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801483:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801486:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80148b:	85 c0                	test   %eax,%eax
  80148d:	74 0b                	je     80149a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80148f:	83 ec 0c             	sub    $0xc,%esp
  801492:	56                   	push   %esi
  801493:	ff d0                	call   *%eax
  801495:	89 c3                	mov    %eax,%ebx
  801497:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80149a:	83 ec 08             	sub    $0x8,%esp
  80149d:	56                   	push   %esi
  80149e:	6a 00                	push   $0x0
  8014a0:	e8 21 f7 ff ff       	call   800bc6 <sys_page_unmap>
	return r;
  8014a5:	83 c4 10             	add    $0x10,%esp
  8014a8:	89 d8                	mov    %ebx,%eax
}
  8014aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ad:	5b                   	pop    %ebx
  8014ae:	5e                   	pop    %esi
  8014af:	5d                   	pop    %ebp
  8014b0:	c3                   	ret    

008014b1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014b1:	55                   	push   %ebp
  8014b2:	89 e5                	mov    %esp,%ebp
  8014b4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ba:	50                   	push   %eax
  8014bb:	ff 75 08             	pushl  0x8(%ebp)
  8014be:	e8 c1 fe ff ff       	call   801384 <fd_lookup>
  8014c3:	83 c4 08             	add    $0x8,%esp
  8014c6:	85 c0                	test   %eax,%eax
  8014c8:	78 10                	js     8014da <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8014ca:	83 ec 08             	sub    $0x8,%esp
  8014cd:	6a 01                	push   $0x1
  8014cf:	ff 75 f4             	pushl  -0xc(%ebp)
  8014d2:	e8 59 ff ff ff       	call   801430 <fd_close>
  8014d7:	83 c4 10             	add    $0x10,%esp
}
  8014da:	c9                   	leave  
  8014db:	c3                   	ret    

008014dc <close_all>:

void
close_all(void)
{
  8014dc:	55                   	push   %ebp
  8014dd:	89 e5                	mov    %esp,%ebp
  8014df:	53                   	push   %ebx
  8014e0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014e3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014e8:	83 ec 0c             	sub    $0xc,%esp
  8014eb:	53                   	push   %ebx
  8014ec:	e8 c0 ff ff ff       	call   8014b1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014f1:	83 c3 01             	add    $0x1,%ebx
  8014f4:	83 c4 10             	add    $0x10,%esp
  8014f7:	83 fb 20             	cmp    $0x20,%ebx
  8014fa:	75 ec                	jne    8014e8 <close_all+0xc>
		close(i);
}
  8014fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ff:	c9                   	leave  
  801500:	c3                   	ret    

00801501 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801501:	55                   	push   %ebp
  801502:	89 e5                	mov    %esp,%ebp
  801504:	57                   	push   %edi
  801505:	56                   	push   %esi
  801506:	53                   	push   %ebx
  801507:	83 ec 2c             	sub    $0x2c,%esp
  80150a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80150d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801510:	50                   	push   %eax
  801511:	ff 75 08             	pushl  0x8(%ebp)
  801514:	e8 6b fe ff ff       	call   801384 <fd_lookup>
  801519:	83 c4 08             	add    $0x8,%esp
  80151c:	85 c0                	test   %eax,%eax
  80151e:	0f 88 c1 00 00 00    	js     8015e5 <dup+0xe4>
		return r;
	close(newfdnum);
  801524:	83 ec 0c             	sub    $0xc,%esp
  801527:	56                   	push   %esi
  801528:	e8 84 ff ff ff       	call   8014b1 <close>

	newfd = INDEX2FD(newfdnum);
  80152d:	89 f3                	mov    %esi,%ebx
  80152f:	c1 e3 0c             	shl    $0xc,%ebx
  801532:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801538:	83 c4 04             	add    $0x4,%esp
  80153b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80153e:	e8 db fd ff ff       	call   80131e <fd2data>
  801543:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801545:	89 1c 24             	mov    %ebx,(%esp)
  801548:	e8 d1 fd ff ff       	call   80131e <fd2data>
  80154d:	83 c4 10             	add    $0x10,%esp
  801550:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801553:	89 f8                	mov    %edi,%eax
  801555:	c1 e8 16             	shr    $0x16,%eax
  801558:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80155f:	a8 01                	test   $0x1,%al
  801561:	74 37                	je     80159a <dup+0x99>
  801563:	89 f8                	mov    %edi,%eax
  801565:	c1 e8 0c             	shr    $0xc,%eax
  801568:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80156f:	f6 c2 01             	test   $0x1,%dl
  801572:	74 26                	je     80159a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801574:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80157b:	83 ec 0c             	sub    $0xc,%esp
  80157e:	25 07 0e 00 00       	and    $0xe07,%eax
  801583:	50                   	push   %eax
  801584:	ff 75 d4             	pushl  -0x2c(%ebp)
  801587:	6a 00                	push   $0x0
  801589:	57                   	push   %edi
  80158a:	6a 00                	push   $0x0
  80158c:	e8 f3 f5 ff ff       	call   800b84 <sys_page_map>
  801591:	89 c7                	mov    %eax,%edi
  801593:	83 c4 20             	add    $0x20,%esp
  801596:	85 c0                	test   %eax,%eax
  801598:	78 2e                	js     8015c8 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80159a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80159d:	89 d0                	mov    %edx,%eax
  80159f:	c1 e8 0c             	shr    $0xc,%eax
  8015a2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015a9:	83 ec 0c             	sub    $0xc,%esp
  8015ac:	25 07 0e 00 00       	and    $0xe07,%eax
  8015b1:	50                   	push   %eax
  8015b2:	53                   	push   %ebx
  8015b3:	6a 00                	push   $0x0
  8015b5:	52                   	push   %edx
  8015b6:	6a 00                	push   $0x0
  8015b8:	e8 c7 f5 ff ff       	call   800b84 <sys_page_map>
  8015bd:	89 c7                	mov    %eax,%edi
  8015bf:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8015c2:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015c4:	85 ff                	test   %edi,%edi
  8015c6:	79 1d                	jns    8015e5 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015c8:	83 ec 08             	sub    $0x8,%esp
  8015cb:	53                   	push   %ebx
  8015cc:	6a 00                	push   $0x0
  8015ce:	e8 f3 f5 ff ff       	call   800bc6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015d3:	83 c4 08             	add    $0x8,%esp
  8015d6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015d9:	6a 00                	push   $0x0
  8015db:	e8 e6 f5 ff ff       	call   800bc6 <sys_page_unmap>
	return r;
  8015e0:	83 c4 10             	add    $0x10,%esp
  8015e3:	89 f8                	mov    %edi,%eax
}
  8015e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015e8:	5b                   	pop    %ebx
  8015e9:	5e                   	pop    %esi
  8015ea:	5f                   	pop    %edi
  8015eb:	5d                   	pop    %ebp
  8015ec:	c3                   	ret    

008015ed <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015ed:	55                   	push   %ebp
  8015ee:	89 e5                	mov    %esp,%ebp
  8015f0:	53                   	push   %ebx
  8015f1:	83 ec 14             	sub    $0x14,%esp
  8015f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015fa:	50                   	push   %eax
  8015fb:	53                   	push   %ebx
  8015fc:	e8 83 fd ff ff       	call   801384 <fd_lookup>
  801601:	83 c4 08             	add    $0x8,%esp
  801604:	89 c2                	mov    %eax,%edx
  801606:	85 c0                	test   %eax,%eax
  801608:	78 70                	js     80167a <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160a:	83 ec 08             	sub    $0x8,%esp
  80160d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801610:	50                   	push   %eax
  801611:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801614:	ff 30                	pushl  (%eax)
  801616:	e8 bf fd ff ff       	call   8013da <dev_lookup>
  80161b:	83 c4 10             	add    $0x10,%esp
  80161e:	85 c0                	test   %eax,%eax
  801620:	78 4f                	js     801671 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801622:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801625:	8b 42 08             	mov    0x8(%edx),%eax
  801628:	83 e0 03             	and    $0x3,%eax
  80162b:	83 f8 01             	cmp    $0x1,%eax
  80162e:	75 24                	jne    801654 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801630:	a1 04 40 80 00       	mov    0x804004,%eax
  801635:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80163b:	83 ec 04             	sub    $0x4,%esp
  80163e:	53                   	push   %ebx
  80163f:	50                   	push   %eax
  801640:	68 29 2a 80 00       	push   $0x802a29
  801645:	e8 6f eb ff ff       	call   8001b9 <cprintf>
		return -E_INVAL;
  80164a:	83 c4 10             	add    $0x10,%esp
  80164d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801652:	eb 26                	jmp    80167a <read+0x8d>
	}
	if (!dev->dev_read)
  801654:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801657:	8b 40 08             	mov    0x8(%eax),%eax
  80165a:	85 c0                	test   %eax,%eax
  80165c:	74 17                	je     801675 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80165e:	83 ec 04             	sub    $0x4,%esp
  801661:	ff 75 10             	pushl  0x10(%ebp)
  801664:	ff 75 0c             	pushl  0xc(%ebp)
  801667:	52                   	push   %edx
  801668:	ff d0                	call   *%eax
  80166a:	89 c2                	mov    %eax,%edx
  80166c:	83 c4 10             	add    $0x10,%esp
  80166f:	eb 09                	jmp    80167a <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801671:	89 c2                	mov    %eax,%edx
  801673:	eb 05                	jmp    80167a <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801675:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80167a:	89 d0                	mov    %edx,%eax
  80167c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167f:	c9                   	leave  
  801680:	c3                   	ret    

00801681 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801681:	55                   	push   %ebp
  801682:	89 e5                	mov    %esp,%ebp
  801684:	57                   	push   %edi
  801685:	56                   	push   %esi
  801686:	53                   	push   %ebx
  801687:	83 ec 0c             	sub    $0xc,%esp
  80168a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80168d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801690:	bb 00 00 00 00       	mov    $0x0,%ebx
  801695:	eb 21                	jmp    8016b8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801697:	83 ec 04             	sub    $0x4,%esp
  80169a:	89 f0                	mov    %esi,%eax
  80169c:	29 d8                	sub    %ebx,%eax
  80169e:	50                   	push   %eax
  80169f:	89 d8                	mov    %ebx,%eax
  8016a1:	03 45 0c             	add    0xc(%ebp),%eax
  8016a4:	50                   	push   %eax
  8016a5:	57                   	push   %edi
  8016a6:	e8 42 ff ff ff       	call   8015ed <read>
		if (m < 0)
  8016ab:	83 c4 10             	add    $0x10,%esp
  8016ae:	85 c0                	test   %eax,%eax
  8016b0:	78 10                	js     8016c2 <readn+0x41>
			return m;
		if (m == 0)
  8016b2:	85 c0                	test   %eax,%eax
  8016b4:	74 0a                	je     8016c0 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016b6:	01 c3                	add    %eax,%ebx
  8016b8:	39 f3                	cmp    %esi,%ebx
  8016ba:	72 db                	jb     801697 <readn+0x16>
  8016bc:	89 d8                	mov    %ebx,%eax
  8016be:	eb 02                	jmp    8016c2 <readn+0x41>
  8016c0:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8016c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c5:	5b                   	pop    %ebx
  8016c6:	5e                   	pop    %esi
  8016c7:	5f                   	pop    %edi
  8016c8:	5d                   	pop    %ebp
  8016c9:	c3                   	ret    

008016ca <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	53                   	push   %ebx
  8016ce:	83 ec 14             	sub    $0x14,%esp
  8016d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d7:	50                   	push   %eax
  8016d8:	53                   	push   %ebx
  8016d9:	e8 a6 fc ff ff       	call   801384 <fd_lookup>
  8016de:	83 c4 08             	add    $0x8,%esp
  8016e1:	89 c2                	mov    %eax,%edx
  8016e3:	85 c0                	test   %eax,%eax
  8016e5:	78 6b                	js     801752 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e7:	83 ec 08             	sub    $0x8,%esp
  8016ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ed:	50                   	push   %eax
  8016ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f1:	ff 30                	pushl  (%eax)
  8016f3:	e8 e2 fc ff ff       	call   8013da <dev_lookup>
  8016f8:	83 c4 10             	add    $0x10,%esp
  8016fb:	85 c0                	test   %eax,%eax
  8016fd:	78 4a                	js     801749 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801702:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801706:	75 24                	jne    80172c <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801708:	a1 04 40 80 00       	mov    0x804004,%eax
  80170d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801713:	83 ec 04             	sub    $0x4,%esp
  801716:	53                   	push   %ebx
  801717:	50                   	push   %eax
  801718:	68 45 2a 80 00       	push   $0x802a45
  80171d:	e8 97 ea ff ff       	call   8001b9 <cprintf>
		return -E_INVAL;
  801722:	83 c4 10             	add    $0x10,%esp
  801725:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80172a:	eb 26                	jmp    801752 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80172c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80172f:	8b 52 0c             	mov    0xc(%edx),%edx
  801732:	85 d2                	test   %edx,%edx
  801734:	74 17                	je     80174d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801736:	83 ec 04             	sub    $0x4,%esp
  801739:	ff 75 10             	pushl  0x10(%ebp)
  80173c:	ff 75 0c             	pushl  0xc(%ebp)
  80173f:	50                   	push   %eax
  801740:	ff d2                	call   *%edx
  801742:	89 c2                	mov    %eax,%edx
  801744:	83 c4 10             	add    $0x10,%esp
  801747:	eb 09                	jmp    801752 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801749:	89 c2                	mov    %eax,%edx
  80174b:	eb 05                	jmp    801752 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80174d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801752:	89 d0                	mov    %edx,%eax
  801754:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801757:	c9                   	leave  
  801758:	c3                   	ret    

00801759 <seek>:

int
seek(int fdnum, off_t offset)
{
  801759:	55                   	push   %ebp
  80175a:	89 e5                	mov    %esp,%ebp
  80175c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80175f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801762:	50                   	push   %eax
  801763:	ff 75 08             	pushl  0x8(%ebp)
  801766:	e8 19 fc ff ff       	call   801384 <fd_lookup>
  80176b:	83 c4 08             	add    $0x8,%esp
  80176e:	85 c0                	test   %eax,%eax
  801770:	78 0e                	js     801780 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801772:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801775:	8b 55 0c             	mov    0xc(%ebp),%edx
  801778:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80177b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801780:	c9                   	leave  
  801781:	c3                   	ret    

00801782 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801782:	55                   	push   %ebp
  801783:	89 e5                	mov    %esp,%ebp
  801785:	53                   	push   %ebx
  801786:	83 ec 14             	sub    $0x14,%esp
  801789:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80178c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80178f:	50                   	push   %eax
  801790:	53                   	push   %ebx
  801791:	e8 ee fb ff ff       	call   801384 <fd_lookup>
  801796:	83 c4 08             	add    $0x8,%esp
  801799:	89 c2                	mov    %eax,%edx
  80179b:	85 c0                	test   %eax,%eax
  80179d:	78 68                	js     801807 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80179f:	83 ec 08             	sub    $0x8,%esp
  8017a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a5:	50                   	push   %eax
  8017a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a9:	ff 30                	pushl  (%eax)
  8017ab:	e8 2a fc ff ff       	call   8013da <dev_lookup>
  8017b0:	83 c4 10             	add    $0x10,%esp
  8017b3:	85 c0                	test   %eax,%eax
  8017b5:	78 47                	js     8017fe <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ba:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017be:	75 24                	jne    8017e4 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017c0:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017c5:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8017cb:	83 ec 04             	sub    $0x4,%esp
  8017ce:	53                   	push   %ebx
  8017cf:	50                   	push   %eax
  8017d0:	68 08 2a 80 00       	push   $0x802a08
  8017d5:	e8 df e9 ff ff       	call   8001b9 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017da:	83 c4 10             	add    $0x10,%esp
  8017dd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017e2:	eb 23                	jmp    801807 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  8017e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017e7:	8b 52 18             	mov    0x18(%edx),%edx
  8017ea:	85 d2                	test   %edx,%edx
  8017ec:	74 14                	je     801802 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017ee:	83 ec 08             	sub    $0x8,%esp
  8017f1:	ff 75 0c             	pushl  0xc(%ebp)
  8017f4:	50                   	push   %eax
  8017f5:	ff d2                	call   *%edx
  8017f7:	89 c2                	mov    %eax,%edx
  8017f9:	83 c4 10             	add    $0x10,%esp
  8017fc:	eb 09                	jmp    801807 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017fe:	89 c2                	mov    %eax,%edx
  801800:	eb 05                	jmp    801807 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801802:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801807:	89 d0                	mov    %edx,%eax
  801809:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180c:	c9                   	leave  
  80180d:	c3                   	ret    

0080180e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80180e:	55                   	push   %ebp
  80180f:	89 e5                	mov    %esp,%ebp
  801811:	53                   	push   %ebx
  801812:	83 ec 14             	sub    $0x14,%esp
  801815:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801818:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80181b:	50                   	push   %eax
  80181c:	ff 75 08             	pushl  0x8(%ebp)
  80181f:	e8 60 fb ff ff       	call   801384 <fd_lookup>
  801824:	83 c4 08             	add    $0x8,%esp
  801827:	89 c2                	mov    %eax,%edx
  801829:	85 c0                	test   %eax,%eax
  80182b:	78 58                	js     801885 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80182d:	83 ec 08             	sub    $0x8,%esp
  801830:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801833:	50                   	push   %eax
  801834:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801837:	ff 30                	pushl  (%eax)
  801839:	e8 9c fb ff ff       	call   8013da <dev_lookup>
  80183e:	83 c4 10             	add    $0x10,%esp
  801841:	85 c0                	test   %eax,%eax
  801843:	78 37                	js     80187c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801845:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801848:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80184c:	74 32                	je     801880 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80184e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801851:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801858:	00 00 00 
	stat->st_isdir = 0;
  80185b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801862:	00 00 00 
	stat->st_dev = dev;
  801865:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80186b:	83 ec 08             	sub    $0x8,%esp
  80186e:	53                   	push   %ebx
  80186f:	ff 75 f0             	pushl  -0x10(%ebp)
  801872:	ff 50 14             	call   *0x14(%eax)
  801875:	89 c2                	mov    %eax,%edx
  801877:	83 c4 10             	add    $0x10,%esp
  80187a:	eb 09                	jmp    801885 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80187c:	89 c2                	mov    %eax,%edx
  80187e:	eb 05                	jmp    801885 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801880:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801885:	89 d0                	mov    %edx,%eax
  801887:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80188a:	c9                   	leave  
  80188b:	c3                   	ret    

0080188c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80188c:	55                   	push   %ebp
  80188d:	89 e5                	mov    %esp,%ebp
  80188f:	56                   	push   %esi
  801890:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801891:	83 ec 08             	sub    $0x8,%esp
  801894:	6a 00                	push   $0x0
  801896:	ff 75 08             	pushl  0x8(%ebp)
  801899:	e8 e3 01 00 00       	call   801a81 <open>
  80189e:	89 c3                	mov    %eax,%ebx
  8018a0:	83 c4 10             	add    $0x10,%esp
  8018a3:	85 c0                	test   %eax,%eax
  8018a5:	78 1b                	js     8018c2 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018a7:	83 ec 08             	sub    $0x8,%esp
  8018aa:	ff 75 0c             	pushl  0xc(%ebp)
  8018ad:	50                   	push   %eax
  8018ae:	e8 5b ff ff ff       	call   80180e <fstat>
  8018b3:	89 c6                	mov    %eax,%esi
	close(fd);
  8018b5:	89 1c 24             	mov    %ebx,(%esp)
  8018b8:	e8 f4 fb ff ff       	call   8014b1 <close>
	return r;
  8018bd:	83 c4 10             	add    $0x10,%esp
  8018c0:	89 f0                	mov    %esi,%eax
}
  8018c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c5:	5b                   	pop    %ebx
  8018c6:	5e                   	pop    %esi
  8018c7:	5d                   	pop    %ebp
  8018c8:	c3                   	ret    

008018c9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018c9:	55                   	push   %ebp
  8018ca:	89 e5                	mov    %esp,%ebp
  8018cc:	56                   	push   %esi
  8018cd:	53                   	push   %ebx
  8018ce:	89 c6                	mov    %eax,%esi
  8018d0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018d2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018d9:	75 12                	jne    8018ed <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018db:	83 ec 0c             	sub    $0xc,%esp
  8018de:	6a 01                	push   $0x1
  8018e0:	e8 da 08 00 00       	call   8021bf <ipc_find_env>
  8018e5:	a3 00 40 80 00       	mov    %eax,0x804000
  8018ea:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018ed:	6a 07                	push   $0x7
  8018ef:	68 00 50 80 00       	push   $0x805000
  8018f4:	56                   	push   %esi
  8018f5:	ff 35 00 40 80 00    	pushl  0x804000
  8018fb:	e8 5d 08 00 00       	call   80215d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801900:	83 c4 0c             	add    $0xc,%esp
  801903:	6a 00                	push   $0x0
  801905:	53                   	push   %ebx
  801906:	6a 00                	push   $0x0
  801908:	e8 d5 07 00 00       	call   8020e2 <ipc_recv>
}
  80190d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801910:	5b                   	pop    %ebx
  801911:	5e                   	pop    %esi
  801912:	5d                   	pop    %ebp
  801913:	c3                   	ret    

00801914 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
  801917:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80191a:	8b 45 08             	mov    0x8(%ebp),%eax
  80191d:	8b 40 0c             	mov    0xc(%eax),%eax
  801920:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801925:	8b 45 0c             	mov    0xc(%ebp),%eax
  801928:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80192d:	ba 00 00 00 00       	mov    $0x0,%edx
  801932:	b8 02 00 00 00       	mov    $0x2,%eax
  801937:	e8 8d ff ff ff       	call   8018c9 <fsipc>
}
  80193c:	c9                   	leave  
  80193d:	c3                   	ret    

0080193e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80193e:	55                   	push   %ebp
  80193f:	89 e5                	mov    %esp,%ebp
  801941:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801944:	8b 45 08             	mov    0x8(%ebp),%eax
  801947:	8b 40 0c             	mov    0xc(%eax),%eax
  80194a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80194f:	ba 00 00 00 00       	mov    $0x0,%edx
  801954:	b8 06 00 00 00       	mov    $0x6,%eax
  801959:	e8 6b ff ff ff       	call   8018c9 <fsipc>
}
  80195e:	c9                   	leave  
  80195f:	c3                   	ret    

00801960 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801960:	55                   	push   %ebp
  801961:	89 e5                	mov    %esp,%ebp
  801963:	53                   	push   %ebx
  801964:	83 ec 04             	sub    $0x4,%esp
  801967:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80196a:	8b 45 08             	mov    0x8(%ebp),%eax
  80196d:	8b 40 0c             	mov    0xc(%eax),%eax
  801970:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801975:	ba 00 00 00 00       	mov    $0x0,%edx
  80197a:	b8 05 00 00 00       	mov    $0x5,%eax
  80197f:	e8 45 ff ff ff       	call   8018c9 <fsipc>
  801984:	85 c0                	test   %eax,%eax
  801986:	78 2c                	js     8019b4 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801988:	83 ec 08             	sub    $0x8,%esp
  80198b:	68 00 50 80 00       	push   $0x805000
  801990:	53                   	push   %ebx
  801991:	e8 a8 ed ff ff       	call   80073e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801996:	a1 80 50 80 00       	mov    0x805080,%eax
  80199b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019a1:	a1 84 50 80 00       	mov    0x805084,%eax
  8019a6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019ac:	83 c4 10             	add    $0x10,%esp
  8019af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b7:	c9                   	leave  
  8019b8:	c3                   	ret    

008019b9 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019b9:	55                   	push   %ebp
  8019ba:	89 e5                	mov    %esp,%ebp
  8019bc:	83 ec 0c             	sub    $0xc,%esp
  8019bf:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8019c5:	8b 52 0c             	mov    0xc(%edx),%edx
  8019c8:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8019ce:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8019d3:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8019d8:	0f 47 c2             	cmova  %edx,%eax
  8019db:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8019e0:	50                   	push   %eax
  8019e1:	ff 75 0c             	pushl  0xc(%ebp)
  8019e4:	68 08 50 80 00       	push   $0x805008
  8019e9:	e8 e2 ee ff ff       	call   8008d0 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8019ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f3:	b8 04 00 00 00       	mov    $0x4,%eax
  8019f8:	e8 cc fe ff ff       	call   8018c9 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8019fd:	c9                   	leave  
  8019fe:	c3                   	ret    

008019ff <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019ff:	55                   	push   %ebp
  801a00:	89 e5                	mov    %esp,%ebp
  801a02:	56                   	push   %esi
  801a03:	53                   	push   %ebx
  801a04:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a07:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0a:	8b 40 0c             	mov    0xc(%eax),%eax
  801a0d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a12:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a18:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1d:	b8 03 00 00 00       	mov    $0x3,%eax
  801a22:	e8 a2 fe ff ff       	call   8018c9 <fsipc>
  801a27:	89 c3                	mov    %eax,%ebx
  801a29:	85 c0                	test   %eax,%eax
  801a2b:	78 4b                	js     801a78 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a2d:	39 c6                	cmp    %eax,%esi
  801a2f:	73 16                	jae    801a47 <devfile_read+0x48>
  801a31:	68 74 2a 80 00       	push   $0x802a74
  801a36:	68 7b 2a 80 00       	push   $0x802a7b
  801a3b:	6a 7c                	push   $0x7c
  801a3d:	68 90 2a 80 00       	push   $0x802a90
  801a42:	e8 c6 05 00 00       	call   80200d <_panic>
	assert(r <= PGSIZE);
  801a47:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a4c:	7e 16                	jle    801a64 <devfile_read+0x65>
  801a4e:	68 9b 2a 80 00       	push   $0x802a9b
  801a53:	68 7b 2a 80 00       	push   $0x802a7b
  801a58:	6a 7d                	push   $0x7d
  801a5a:	68 90 2a 80 00       	push   $0x802a90
  801a5f:	e8 a9 05 00 00       	call   80200d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a64:	83 ec 04             	sub    $0x4,%esp
  801a67:	50                   	push   %eax
  801a68:	68 00 50 80 00       	push   $0x805000
  801a6d:	ff 75 0c             	pushl  0xc(%ebp)
  801a70:	e8 5b ee ff ff       	call   8008d0 <memmove>
	return r;
  801a75:	83 c4 10             	add    $0x10,%esp
}
  801a78:	89 d8                	mov    %ebx,%eax
  801a7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a7d:	5b                   	pop    %ebx
  801a7e:	5e                   	pop    %esi
  801a7f:	5d                   	pop    %ebp
  801a80:	c3                   	ret    

00801a81 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a81:	55                   	push   %ebp
  801a82:	89 e5                	mov    %esp,%ebp
  801a84:	53                   	push   %ebx
  801a85:	83 ec 20             	sub    $0x20,%esp
  801a88:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a8b:	53                   	push   %ebx
  801a8c:	e8 74 ec ff ff       	call   800705 <strlen>
  801a91:	83 c4 10             	add    $0x10,%esp
  801a94:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a99:	7f 67                	jg     801b02 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a9b:	83 ec 0c             	sub    $0xc,%esp
  801a9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa1:	50                   	push   %eax
  801aa2:	e8 8e f8 ff ff       	call   801335 <fd_alloc>
  801aa7:	83 c4 10             	add    $0x10,%esp
		return r;
  801aaa:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801aac:	85 c0                	test   %eax,%eax
  801aae:	78 57                	js     801b07 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801ab0:	83 ec 08             	sub    $0x8,%esp
  801ab3:	53                   	push   %ebx
  801ab4:	68 00 50 80 00       	push   $0x805000
  801ab9:	e8 80 ec ff ff       	call   80073e <strcpy>
	fsipcbuf.open.req_omode = mode;
  801abe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac1:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ac6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ac9:	b8 01 00 00 00       	mov    $0x1,%eax
  801ace:	e8 f6 fd ff ff       	call   8018c9 <fsipc>
  801ad3:	89 c3                	mov    %eax,%ebx
  801ad5:	83 c4 10             	add    $0x10,%esp
  801ad8:	85 c0                	test   %eax,%eax
  801ada:	79 14                	jns    801af0 <open+0x6f>
		fd_close(fd, 0);
  801adc:	83 ec 08             	sub    $0x8,%esp
  801adf:	6a 00                	push   $0x0
  801ae1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae4:	e8 47 f9 ff ff       	call   801430 <fd_close>
		return r;
  801ae9:	83 c4 10             	add    $0x10,%esp
  801aec:	89 da                	mov    %ebx,%edx
  801aee:	eb 17                	jmp    801b07 <open+0x86>
	}

	return fd2num(fd);
  801af0:	83 ec 0c             	sub    $0xc,%esp
  801af3:	ff 75 f4             	pushl  -0xc(%ebp)
  801af6:	e8 13 f8 ff ff       	call   80130e <fd2num>
  801afb:	89 c2                	mov    %eax,%edx
  801afd:	83 c4 10             	add    $0x10,%esp
  801b00:	eb 05                	jmp    801b07 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b02:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b07:	89 d0                	mov    %edx,%eax
  801b09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b0c:	c9                   	leave  
  801b0d:	c3                   	ret    

00801b0e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b0e:	55                   	push   %ebp
  801b0f:	89 e5                	mov    %esp,%ebp
  801b11:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b14:	ba 00 00 00 00       	mov    $0x0,%edx
  801b19:	b8 08 00 00 00       	mov    $0x8,%eax
  801b1e:	e8 a6 fd ff ff       	call   8018c9 <fsipc>
}
  801b23:	c9                   	leave  
  801b24:	c3                   	ret    

00801b25 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
  801b28:	56                   	push   %esi
  801b29:	53                   	push   %ebx
  801b2a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b2d:	83 ec 0c             	sub    $0xc,%esp
  801b30:	ff 75 08             	pushl  0x8(%ebp)
  801b33:	e8 e6 f7 ff ff       	call   80131e <fd2data>
  801b38:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b3a:	83 c4 08             	add    $0x8,%esp
  801b3d:	68 a7 2a 80 00       	push   $0x802aa7
  801b42:	53                   	push   %ebx
  801b43:	e8 f6 eb ff ff       	call   80073e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b48:	8b 46 04             	mov    0x4(%esi),%eax
  801b4b:	2b 06                	sub    (%esi),%eax
  801b4d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b53:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b5a:	00 00 00 
	stat->st_dev = &devpipe;
  801b5d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b64:	30 80 00 
	return 0;
}
  801b67:	b8 00 00 00 00       	mov    $0x0,%eax
  801b6c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b6f:	5b                   	pop    %ebx
  801b70:	5e                   	pop    %esi
  801b71:	5d                   	pop    %ebp
  801b72:	c3                   	ret    

00801b73 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b73:	55                   	push   %ebp
  801b74:	89 e5                	mov    %esp,%ebp
  801b76:	53                   	push   %ebx
  801b77:	83 ec 0c             	sub    $0xc,%esp
  801b7a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b7d:	53                   	push   %ebx
  801b7e:	6a 00                	push   $0x0
  801b80:	e8 41 f0 ff ff       	call   800bc6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b85:	89 1c 24             	mov    %ebx,(%esp)
  801b88:	e8 91 f7 ff ff       	call   80131e <fd2data>
  801b8d:	83 c4 08             	add    $0x8,%esp
  801b90:	50                   	push   %eax
  801b91:	6a 00                	push   $0x0
  801b93:	e8 2e f0 ff ff       	call   800bc6 <sys_page_unmap>
}
  801b98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b9b:	c9                   	leave  
  801b9c:	c3                   	ret    

00801b9d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b9d:	55                   	push   %ebp
  801b9e:	89 e5                	mov    %esp,%ebp
  801ba0:	57                   	push   %edi
  801ba1:	56                   	push   %esi
  801ba2:	53                   	push   %ebx
  801ba3:	83 ec 1c             	sub    $0x1c,%esp
  801ba6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ba9:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bab:	a1 04 40 80 00       	mov    0x804004,%eax
  801bb0:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801bb6:	83 ec 0c             	sub    $0xc,%esp
  801bb9:	ff 75 e0             	pushl  -0x20(%ebp)
  801bbc:	e8 43 06 00 00       	call   802204 <pageref>
  801bc1:	89 c3                	mov    %eax,%ebx
  801bc3:	89 3c 24             	mov    %edi,(%esp)
  801bc6:	e8 39 06 00 00       	call   802204 <pageref>
  801bcb:	83 c4 10             	add    $0x10,%esp
  801bce:	39 c3                	cmp    %eax,%ebx
  801bd0:	0f 94 c1             	sete   %cl
  801bd3:	0f b6 c9             	movzbl %cl,%ecx
  801bd6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801bd9:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801bdf:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801be5:	39 ce                	cmp    %ecx,%esi
  801be7:	74 1e                	je     801c07 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801be9:	39 c3                	cmp    %eax,%ebx
  801beb:	75 be                	jne    801bab <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bed:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801bf3:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bf6:	50                   	push   %eax
  801bf7:	56                   	push   %esi
  801bf8:	68 ae 2a 80 00       	push   $0x802aae
  801bfd:	e8 b7 e5 ff ff       	call   8001b9 <cprintf>
  801c02:	83 c4 10             	add    $0x10,%esp
  801c05:	eb a4                	jmp    801bab <_pipeisclosed+0xe>
	}
}
  801c07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c0d:	5b                   	pop    %ebx
  801c0e:	5e                   	pop    %esi
  801c0f:	5f                   	pop    %edi
  801c10:	5d                   	pop    %ebp
  801c11:	c3                   	ret    

00801c12 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c12:	55                   	push   %ebp
  801c13:	89 e5                	mov    %esp,%ebp
  801c15:	57                   	push   %edi
  801c16:	56                   	push   %esi
  801c17:	53                   	push   %ebx
  801c18:	83 ec 28             	sub    $0x28,%esp
  801c1b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c1e:	56                   	push   %esi
  801c1f:	e8 fa f6 ff ff       	call   80131e <fd2data>
  801c24:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c26:	83 c4 10             	add    $0x10,%esp
  801c29:	bf 00 00 00 00       	mov    $0x0,%edi
  801c2e:	eb 4b                	jmp    801c7b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c30:	89 da                	mov    %ebx,%edx
  801c32:	89 f0                	mov    %esi,%eax
  801c34:	e8 64 ff ff ff       	call   801b9d <_pipeisclosed>
  801c39:	85 c0                	test   %eax,%eax
  801c3b:	75 48                	jne    801c85 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c3d:	e8 e0 ee ff ff       	call   800b22 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c42:	8b 43 04             	mov    0x4(%ebx),%eax
  801c45:	8b 0b                	mov    (%ebx),%ecx
  801c47:	8d 51 20             	lea    0x20(%ecx),%edx
  801c4a:	39 d0                	cmp    %edx,%eax
  801c4c:	73 e2                	jae    801c30 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c51:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c55:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c58:	89 c2                	mov    %eax,%edx
  801c5a:	c1 fa 1f             	sar    $0x1f,%edx
  801c5d:	89 d1                	mov    %edx,%ecx
  801c5f:	c1 e9 1b             	shr    $0x1b,%ecx
  801c62:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c65:	83 e2 1f             	and    $0x1f,%edx
  801c68:	29 ca                	sub    %ecx,%edx
  801c6a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c6e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c72:	83 c0 01             	add    $0x1,%eax
  801c75:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c78:	83 c7 01             	add    $0x1,%edi
  801c7b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c7e:	75 c2                	jne    801c42 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c80:	8b 45 10             	mov    0x10(%ebp),%eax
  801c83:	eb 05                	jmp    801c8a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c85:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c8d:	5b                   	pop    %ebx
  801c8e:	5e                   	pop    %esi
  801c8f:	5f                   	pop    %edi
  801c90:	5d                   	pop    %ebp
  801c91:	c3                   	ret    

00801c92 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c92:	55                   	push   %ebp
  801c93:	89 e5                	mov    %esp,%ebp
  801c95:	57                   	push   %edi
  801c96:	56                   	push   %esi
  801c97:	53                   	push   %ebx
  801c98:	83 ec 18             	sub    $0x18,%esp
  801c9b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c9e:	57                   	push   %edi
  801c9f:	e8 7a f6 ff ff       	call   80131e <fd2data>
  801ca4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ca6:	83 c4 10             	add    $0x10,%esp
  801ca9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cae:	eb 3d                	jmp    801ced <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801cb0:	85 db                	test   %ebx,%ebx
  801cb2:	74 04                	je     801cb8 <devpipe_read+0x26>
				return i;
  801cb4:	89 d8                	mov    %ebx,%eax
  801cb6:	eb 44                	jmp    801cfc <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cb8:	89 f2                	mov    %esi,%edx
  801cba:	89 f8                	mov    %edi,%eax
  801cbc:	e8 dc fe ff ff       	call   801b9d <_pipeisclosed>
  801cc1:	85 c0                	test   %eax,%eax
  801cc3:	75 32                	jne    801cf7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cc5:	e8 58 ee ff ff       	call   800b22 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801cca:	8b 06                	mov    (%esi),%eax
  801ccc:	3b 46 04             	cmp    0x4(%esi),%eax
  801ccf:	74 df                	je     801cb0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cd1:	99                   	cltd   
  801cd2:	c1 ea 1b             	shr    $0x1b,%edx
  801cd5:	01 d0                	add    %edx,%eax
  801cd7:	83 e0 1f             	and    $0x1f,%eax
  801cda:	29 d0                	sub    %edx,%eax
  801cdc:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ce1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ce4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ce7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cea:	83 c3 01             	add    $0x1,%ebx
  801ced:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cf0:	75 d8                	jne    801cca <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cf2:	8b 45 10             	mov    0x10(%ebp),%eax
  801cf5:	eb 05                	jmp    801cfc <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cf7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cff:	5b                   	pop    %ebx
  801d00:	5e                   	pop    %esi
  801d01:	5f                   	pop    %edi
  801d02:	5d                   	pop    %ebp
  801d03:	c3                   	ret    

00801d04 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d04:	55                   	push   %ebp
  801d05:	89 e5                	mov    %esp,%ebp
  801d07:	56                   	push   %esi
  801d08:	53                   	push   %ebx
  801d09:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d0c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d0f:	50                   	push   %eax
  801d10:	e8 20 f6 ff ff       	call   801335 <fd_alloc>
  801d15:	83 c4 10             	add    $0x10,%esp
  801d18:	89 c2                	mov    %eax,%edx
  801d1a:	85 c0                	test   %eax,%eax
  801d1c:	0f 88 2c 01 00 00    	js     801e4e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d22:	83 ec 04             	sub    $0x4,%esp
  801d25:	68 07 04 00 00       	push   $0x407
  801d2a:	ff 75 f4             	pushl  -0xc(%ebp)
  801d2d:	6a 00                	push   $0x0
  801d2f:	e8 0d ee ff ff       	call   800b41 <sys_page_alloc>
  801d34:	83 c4 10             	add    $0x10,%esp
  801d37:	89 c2                	mov    %eax,%edx
  801d39:	85 c0                	test   %eax,%eax
  801d3b:	0f 88 0d 01 00 00    	js     801e4e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d41:	83 ec 0c             	sub    $0xc,%esp
  801d44:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d47:	50                   	push   %eax
  801d48:	e8 e8 f5 ff ff       	call   801335 <fd_alloc>
  801d4d:	89 c3                	mov    %eax,%ebx
  801d4f:	83 c4 10             	add    $0x10,%esp
  801d52:	85 c0                	test   %eax,%eax
  801d54:	0f 88 e2 00 00 00    	js     801e3c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d5a:	83 ec 04             	sub    $0x4,%esp
  801d5d:	68 07 04 00 00       	push   $0x407
  801d62:	ff 75 f0             	pushl  -0x10(%ebp)
  801d65:	6a 00                	push   $0x0
  801d67:	e8 d5 ed ff ff       	call   800b41 <sys_page_alloc>
  801d6c:	89 c3                	mov    %eax,%ebx
  801d6e:	83 c4 10             	add    $0x10,%esp
  801d71:	85 c0                	test   %eax,%eax
  801d73:	0f 88 c3 00 00 00    	js     801e3c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d79:	83 ec 0c             	sub    $0xc,%esp
  801d7c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d7f:	e8 9a f5 ff ff       	call   80131e <fd2data>
  801d84:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d86:	83 c4 0c             	add    $0xc,%esp
  801d89:	68 07 04 00 00       	push   $0x407
  801d8e:	50                   	push   %eax
  801d8f:	6a 00                	push   $0x0
  801d91:	e8 ab ed ff ff       	call   800b41 <sys_page_alloc>
  801d96:	89 c3                	mov    %eax,%ebx
  801d98:	83 c4 10             	add    $0x10,%esp
  801d9b:	85 c0                	test   %eax,%eax
  801d9d:	0f 88 89 00 00 00    	js     801e2c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801da3:	83 ec 0c             	sub    $0xc,%esp
  801da6:	ff 75 f0             	pushl  -0x10(%ebp)
  801da9:	e8 70 f5 ff ff       	call   80131e <fd2data>
  801dae:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801db5:	50                   	push   %eax
  801db6:	6a 00                	push   $0x0
  801db8:	56                   	push   %esi
  801db9:	6a 00                	push   $0x0
  801dbb:	e8 c4 ed ff ff       	call   800b84 <sys_page_map>
  801dc0:	89 c3                	mov    %eax,%ebx
  801dc2:	83 c4 20             	add    $0x20,%esp
  801dc5:	85 c0                	test   %eax,%eax
  801dc7:	78 55                	js     801e1e <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801dc9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801dd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801dde:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801de4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801de7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801de9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dec:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801df3:	83 ec 0c             	sub    $0xc,%esp
  801df6:	ff 75 f4             	pushl  -0xc(%ebp)
  801df9:	e8 10 f5 ff ff       	call   80130e <fd2num>
  801dfe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e01:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e03:	83 c4 04             	add    $0x4,%esp
  801e06:	ff 75 f0             	pushl  -0x10(%ebp)
  801e09:	e8 00 f5 ff ff       	call   80130e <fd2num>
  801e0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e11:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801e14:	83 c4 10             	add    $0x10,%esp
  801e17:	ba 00 00 00 00       	mov    $0x0,%edx
  801e1c:	eb 30                	jmp    801e4e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e1e:	83 ec 08             	sub    $0x8,%esp
  801e21:	56                   	push   %esi
  801e22:	6a 00                	push   $0x0
  801e24:	e8 9d ed ff ff       	call   800bc6 <sys_page_unmap>
  801e29:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e2c:	83 ec 08             	sub    $0x8,%esp
  801e2f:	ff 75 f0             	pushl  -0x10(%ebp)
  801e32:	6a 00                	push   $0x0
  801e34:	e8 8d ed ff ff       	call   800bc6 <sys_page_unmap>
  801e39:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e3c:	83 ec 08             	sub    $0x8,%esp
  801e3f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e42:	6a 00                	push   $0x0
  801e44:	e8 7d ed ff ff       	call   800bc6 <sys_page_unmap>
  801e49:	83 c4 10             	add    $0x10,%esp
  801e4c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e4e:	89 d0                	mov    %edx,%eax
  801e50:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e53:	5b                   	pop    %ebx
  801e54:	5e                   	pop    %esi
  801e55:	5d                   	pop    %ebp
  801e56:	c3                   	ret    

00801e57 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e57:	55                   	push   %ebp
  801e58:	89 e5                	mov    %esp,%ebp
  801e5a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e5d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e60:	50                   	push   %eax
  801e61:	ff 75 08             	pushl  0x8(%ebp)
  801e64:	e8 1b f5 ff ff       	call   801384 <fd_lookup>
  801e69:	83 c4 10             	add    $0x10,%esp
  801e6c:	85 c0                	test   %eax,%eax
  801e6e:	78 18                	js     801e88 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e70:	83 ec 0c             	sub    $0xc,%esp
  801e73:	ff 75 f4             	pushl  -0xc(%ebp)
  801e76:	e8 a3 f4 ff ff       	call   80131e <fd2data>
	return _pipeisclosed(fd, p);
  801e7b:	89 c2                	mov    %eax,%edx
  801e7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e80:	e8 18 fd ff ff       	call   801b9d <_pipeisclosed>
  801e85:	83 c4 10             	add    $0x10,%esp
}
  801e88:	c9                   	leave  
  801e89:	c3                   	ret    

00801e8a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e8a:	55                   	push   %ebp
  801e8b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e8d:	b8 00 00 00 00       	mov    $0x0,%eax
  801e92:	5d                   	pop    %ebp
  801e93:	c3                   	ret    

00801e94 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e94:	55                   	push   %ebp
  801e95:	89 e5                	mov    %esp,%ebp
  801e97:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e9a:	68 c6 2a 80 00       	push   $0x802ac6
  801e9f:	ff 75 0c             	pushl  0xc(%ebp)
  801ea2:	e8 97 e8 ff ff       	call   80073e <strcpy>
	return 0;
}
  801ea7:	b8 00 00 00 00       	mov    $0x0,%eax
  801eac:	c9                   	leave  
  801ead:	c3                   	ret    

00801eae <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801eae:	55                   	push   %ebp
  801eaf:	89 e5                	mov    %esp,%ebp
  801eb1:	57                   	push   %edi
  801eb2:	56                   	push   %esi
  801eb3:	53                   	push   %ebx
  801eb4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eba:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ebf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ec5:	eb 2d                	jmp    801ef4 <devcons_write+0x46>
		m = n - tot;
  801ec7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801eca:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ecc:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ecf:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ed4:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ed7:	83 ec 04             	sub    $0x4,%esp
  801eda:	53                   	push   %ebx
  801edb:	03 45 0c             	add    0xc(%ebp),%eax
  801ede:	50                   	push   %eax
  801edf:	57                   	push   %edi
  801ee0:	e8 eb e9 ff ff       	call   8008d0 <memmove>
		sys_cputs(buf, m);
  801ee5:	83 c4 08             	add    $0x8,%esp
  801ee8:	53                   	push   %ebx
  801ee9:	57                   	push   %edi
  801eea:	e8 96 eb ff ff       	call   800a85 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eef:	01 de                	add    %ebx,%esi
  801ef1:	83 c4 10             	add    $0x10,%esp
  801ef4:	89 f0                	mov    %esi,%eax
  801ef6:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ef9:	72 cc                	jb     801ec7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801efb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801efe:	5b                   	pop    %ebx
  801eff:	5e                   	pop    %esi
  801f00:	5f                   	pop    %edi
  801f01:	5d                   	pop    %ebp
  801f02:	c3                   	ret    

00801f03 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f03:	55                   	push   %ebp
  801f04:	89 e5                	mov    %esp,%ebp
  801f06:	83 ec 08             	sub    $0x8,%esp
  801f09:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f0e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f12:	74 2a                	je     801f3e <devcons_read+0x3b>
  801f14:	eb 05                	jmp    801f1b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f16:	e8 07 ec ff ff       	call   800b22 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f1b:	e8 83 eb ff ff       	call   800aa3 <sys_cgetc>
  801f20:	85 c0                	test   %eax,%eax
  801f22:	74 f2                	je     801f16 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f24:	85 c0                	test   %eax,%eax
  801f26:	78 16                	js     801f3e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f28:	83 f8 04             	cmp    $0x4,%eax
  801f2b:	74 0c                	je     801f39 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f2d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f30:	88 02                	mov    %al,(%edx)
	return 1;
  801f32:	b8 01 00 00 00       	mov    $0x1,%eax
  801f37:	eb 05                	jmp    801f3e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f39:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f3e:	c9                   	leave  
  801f3f:	c3                   	ret    

00801f40 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f40:	55                   	push   %ebp
  801f41:	89 e5                	mov    %esp,%ebp
  801f43:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f46:	8b 45 08             	mov    0x8(%ebp),%eax
  801f49:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f4c:	6a 01                	push   $0x1
  801f4e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f51:	50                   	push   %eax
  801f52:	e8 2e eb ff ff       	call   800a85 <sys_cputs>
}
  801f57:	83 c4 10             	add    $0x10,%esp
  801f5a:	c9                   	leave  
  801f5b:	c3                   	ret    

00801f5c <getchar>:

int
getchar(void)
{
  801f5c:	55                   	push   %ebp
  801f5d:	89 e5                	mov    %esp,%ebp
  801f5f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f62:	6a 01                	push   $0x1
  801f64:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f67:	50                   	push   %eax
  801f68:	6a 00                	push   $0x0
  801f6a:	e8 7e f6 ff ff       	call   8015ed <read>
	if (r < 0)
  801f6f:	83 c4 10             	add    $0x10,%esp
  801f72:	85 c0                	test   %eax,%eax
  801f74:	78 0f                	js     801f85 <getchar+0x29>
		return r;
	if (r < 1)
  801f76:	85 c0                	test   %eax,%eax
  801f78:	7e 06                	jle    801f80 <getchar+0x24>
		return -E_EOF;
	return c;
  801f7a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f7e:	eb 05                	jmp    801f85 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f80:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f85:	c9                   	leave  
  801f86:	c3                   	ret    

00801f87 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f87:	55                   	push   %ebp
  801f88:	89 e5                	mov    %esp,%ebp
  801f8a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f8d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f90:	50                   	push   %eax
  801f91:	ff 75 08             	pushl  0x8(%ebp)
  801f94:	e8 eb f3 ff ff       	call   801384 <fd_lookup>
  801f99:	83 c4 10             	add    $0x10,%esp
  801f9c:	85 c0                	test   %eax,%eax
  801f9e:	78 11                	js     801fb1 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fa9:	39 10                	cmp    %edx,(%eax)
  801fab:	0f 94 c0             	sete   %al
  801fae:	0f b6 c0             	movzbl %al,%eax
}
  801fb1:	c9                   	leave  
  801fb2:	c3                   	ret    

00801fb3 <opencons>:

int
opencons(void)
{
  801fb3:	55                   	push   %ebp
  801fb4:	89 e5                	mov    %esp,%ebp
  801fb6:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fb9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fbc:	50                   	push   %eax
  801fbd:	e8 73 f3 ff ff       	call   801335 <fd_alloc>
  801fc2:	83 c4 10             	add    $0x10,%esp
		return r;
  801fc5:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fc7:	85 c0                	test   %eax,%eax
  801fc9:	78 3e                	js     802009 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fcb:	83 ec 04             	sub    $0x4,%esp
  801fce:	68 07 04 00 00       	push   $0x407
  801fd3:	ff 75 f4             	pushl  -0xc(%ebp)
  801fd6:	6a 00                	push   $0x0
  801fd8:	e8 64 eb ff ff       	call   800b41 <sys_page_alloc>
  801fdd:	83 c4 10             	add    $0x10,%esp
		return r;
  801fe0:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fe2:	85 c0                	test   %eax,%eax
  801fe4:	78 23                	js     802009 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fe6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fef:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ff1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ff4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ffb:	83 ec 0c             	sub    $0xc,%esp
  801ffe:	50                   	push   %eax
  801fff:	e8 0a f3 ff ff       	call   80130e <fd2num>
  802004:	89 c2                	mov    %eax,%edx
  802006:	83 c4 10             	add    $0x10,%esp
}
  802009:	89 d0                	mov    %edx,%eax
  80200b:	c9                   	leave  
  80200c:	c3                   	ret    

0080200d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80200d:	55                   	push   %ebp
  80200e:	89 e5                	mov    %esp,%ebp
  802010:	56                   	push   %esi
  802011:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802012:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802015:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80201b:	e8 e3 ea ff ff       	call   800b03 <sys_getenvid>
  802020:	83 ec 0c             	sub    $0xc,%esp
  802023:	ff 75 0c             	pushl  0xc(%ebp)
  802026:	ff 75 08             	pushl  0x8(%ebp)
  802029:	56                   	push   %esi
  80202a:	50                   	push   %eax
  80202b:	68 d4 2a 80 00       	push   $0x802ad4
  802030:	e8 84 e1 ff ff       	call   8001b9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802035:	83 c4 18             	add    $0x18,%esp
  802038:	53                   	push   %ebx
  802039:	ff 75 10             	pushl  0x10(%ebp)
  80203c:	e8 27 e1 ff ff       	call   800168 <vcprintf>
	cprintf("\n");
  802041:	c7 04 24 26 29 80 00 	movl   $0x802926,(%esp)
  802048:	e8 6c e1 ff ff       	call   8001b9 <cprintf>
  80204d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802050:	cc                   	int3   
  802051:	eb fd                	jmp    802050 <_panic+0x43>

00802053 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802053:	55                   	push   %ebp
  802054:	89 e5                	mov    %esp,%ebp
  802056:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802059:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802060:	75 2a                	jne    80208c <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802062:	83 ec 04             	sub    $0x4,%esp
  802065:	6a 07                	push   $0x7
  802067:	68 00 f0 bf ee       	push   $0xeebff000
  80206c:	6a 00                	push   $0x0
  80206e:	e8 ce ea ff ff       	call   800b41 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802073:	83 c4 10             	add    $0x10,%esp
  802076:	85 c0                	test   %eax,%eax
  802078:	79 12                	jns    80208c <set_pgfault_handler+0x39>
			panic("%e\n", r);
  80207a:	50                   	push   %eax
  80207b:	68 58 29 80 00       	push   $0x802958
  802080:	6a 23                	push   $0x23
  802082:	68 f8 2a 80 00       	push   $0x802af8
  802087:	e8 81 ff ff ff       	call   80200d <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80208c:	8b 45 08             	mov    0x8(%ebp),%eax
  80208f:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802094:	83 ec 08             	sub    $0x8,%esp
  802097:	68 be 20 80 00       	push   $0x8020be
  80209c:	6a 00                	push   $0x0
  80209e:	e8 e9 eb ff ff       	call   800c8c <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8020a3:	83 c4 10             	add    $0x10,%esp
  8020a6:	85 c0                	test   %eax,%eax
  8020a8:	79 12                	jns    8020bc <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8020aa:	50                   	push   %eax
  8020ab:	68 58 29 80 00       	push   $0x802958
  8020b0:	6a 2c                	push   $0x2c
  8020b2:	68 f8 2a 80 00       	push   $0x802af8
  8020b7:	e8 51 ff ff ff       	call   80200d <_panic>
	}
}
  8020bc:	c9                   	leave  
  8020bd:	c3                   	ret    

008020be <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8020be:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8020bf:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8020c4:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8020c6:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8020c9:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8020cd:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8020d2:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8020d6:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8020d8:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8020db:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8020dc:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8020df:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8020e0:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8020e1:	c3                   	ret    

008020e2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020e2:	55                   	push   %ebp
  8020e3:	89 e5                	mov    %esp,%ebp
  8020e5:	56                   	push   %esi
  8020e6:	53                   	push   %ebx
  8020e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8020ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8020f0:	85 c0                	test   %eax,%eax
  8020f2:	75 12                	jne    802106 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8020f4:	83 ec 0c             	sub    $0xc,%esp
  8020f7:	68 00 00 c0 ee       	push   $0xeec00000
  8020fc:	e8 f0 eb ff ff       	call   800cf1 <sys_ipc_recv>
  802101:	83 c4 10             	add    $0x10,%esp
  802104:	eb 0c                	jmp    802112 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802106:	83 ec 0c             	sub    $0xc,%esp
  802109:	50                   	push   %eax
  80210a:	e8 e2 eb ff ff       	call   800cf1 <sys_ipc_recv>
  80210f:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802112:	85 f6                	test   %esi,%esi
  802114:	0f 95 c1             	setne  %cl
  802117:	85 db                	test   %ebx,%ebx
  802119:	0f 95 c2             	setne  %dl
  80211c:	84 d1                	test   %dl,%cl
  80211e:	74 09                	je     802129 <ipc_recv+0x47>
  802120:	89 c2                	mov    %eax,%edx
  802122:	c1 ea 1f             	shr    $0x1f,%edx
  802125:	84 d2                	test   %dl,%dl
  802127:	75 2d                	jne    802156 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802129:	85 f6                	test   %esi,%esi
  80212b:	74 0d                	je     80213a <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80212d:	a1 04 40 80 00       	mov    0x804004,%eax
  802132:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802138:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80213a:	85 db                	test   %ebx,%ebx
  80213c:	74 0d                	je     80214b <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  80213e:	a1 04 40 80 00       	mov    0x804004,%eax
  802143:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  802149:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80214b:	a1 04 40 80 00       	mov    0x804004,%eax
  802150:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  802156:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802159:	5b                   	pop    %ebx
  80215a:	5e                   	pop    %esi
  80215b:	5d                   	pop    %ebp
  80215c:	c3                   	ret    

0080215d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80215d:	55                   	push   %ebp
  80215e:	89 e5                	mov    %esp,%ebp
  802160:	57                   	push   %edi
  802161:	56                   	push   %esi
  802162:	53                   	push   %ebx
  802163:	83 ec 0c             	sub    $0xc,%esp
  802166:	8b 7d 08             	mov    0x8(%ebp),%edi
  802169:	8b 75 0c             	mov    0xc(%ebp),%esi
  80216c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80216f:	85 db                	test   %ebx,%ebx
  802171:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802176:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802179:	ff 75 14             	pushl  0x14(%ebp)
  80217c:	53                   	push   %ebx
  80217d:	56                   	push   %esi
  80217e:	57                   	push   %edi
  80217f:	e8 4a eb ff ff       	call   800cce <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802184:	89 c2                	mov    %eax,%edx
  802186:	c1 ea 1f             	shr    $0x1f,%edx
  802189:	83 c4 10             	add    $0x10,%esp
  80218c:	84 d2                	test   %dl,%dl
  80218e:	74 17                	je     8021a7 <ipc_send+0x4a>
  802190:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802193:	74 12                	je     8021a7 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802195:	50                   	push   %eax
  802196:	68 06 2b 80 00       	push   $0x802b06
  80219b:	6a 47                	push   $0x47
  80219d:	68 14 2b 80 00       	push   $0x802b14
  8021a2:	e8 66 fe ff ff       	call   80200d <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8021a7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021aa:	75 07                	jne    8021b3 <ipc_send+0x56>
			sys_yield();
  8021ac:	e8 71 e9 ff ff       	call   800b22 <sys_yield>
  8021b1:	eb c6                	jmp    802179 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8021b3:	85 c0                	test   %eax,%eax
  8021b5:	75 c2                	jne    802179 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8021b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021ba:	5b                   	pop    %ebx
  8021bb:	5e                   	pop    %esi
  8021bc:	5f                   	pop    %edi
  8021bd:	5d                   	pop    %ebp
  8021be:	c3                   	ret    

008021bf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021bf:	55                   	push   %ebp
  8021c0:	89 e5                	mov    %esp,%ebp
  8021c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8021c5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021ca:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  8021d0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021d6:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  8021dc:	39 ca                	cmp    %ecx,%edx
  8021de:	75 13                	jne    8021f3 <ipc_find_env+0x34>
			return envs[i].env_id;
  8021e0:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8021e6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021eb:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8021f1:	eb 0f                	jmp    802202 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021f3:	83 c0 01             	add    $0x1,%eax
  8021f6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021fb:	75 cd                	jne    8021ca <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802202:	5d                   	pop    %ebp
  802203:	c3                   	ret    

00802204 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802204:	55                   	push   %ebp
  802205:	89 e5                	mov    %esp,%ebp
  802207:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80220a:	89 d0                	mov    %edx,%eax
  80220c:	c1 e8 16             	shr    $0x16,%eax
  80220f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802216:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80221b:	f6 c1 01             	test   $0x1,%cl
  80221e:	74 1d                	je     80223d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802220:	c1 ea 0c             	shr    $0xc,%edx
  802223:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80222a:	f6 c2 01             	test   $0x1,%dl
  80222d:	74 0e                	je     80223d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80222f:	c1 ea 0c             	shr    $0xc,%edx
  802232:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802239:	ef 
  80223a:	0f b7 c0             	movzwl %ax,%eax
}
  80223d:	5d                   	pop    %ebp
  80223e:	c3                   	ret    
  80223f:	90                   	nop

00802240 <__udivdi3>:
  802240:	55                   	push   %ebp
  802241:	57                   	push   %edi
  802242:	56                   	push   %esi
  802243:	53                   	push   %ebx
  802244:	83 ec 1c             	sub    $0x1c,%esp
  802247:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80224b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80224f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802253:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802257:	85 f6                	test   %esi,%esi
  802259:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80225d:	89 ca                	mov    %ecx,%edx
  80225f:	89 f8                	mov    %edi,%eax
  802261:	75 3d                	jne    8022a0 <__udivdi3+0x60>
  802263:	39 cf                	cmp    %ecx,%edi
  802265:	0f 87 c5 00 00 00    	ja     802330 <__udivdi3+0xf0>
  80226b:	85 ff                	test   %edi,%edi
  80226d:	89 fd                	mov    %edi,%ebp
  80226f:	75 0b                	jne    80227c <__udivdi3+0x3c>
  802271:	b8 01 00 00 00       	mov    $0x1,%eax
  802276:	31 d2                	xor    %edx,%edx
  802278:	f7 f7                	div    %edi
  80227a:	89 c5                	mov    %eax,%ebp
  80227c:	89 c8                	mov    %ecx,%eax
  80227e:	31 d2                	xor    %edx,%edx
  802280:	f7 f5                	div    %ebp
  802282:	89 c1                	mov    %eax,%ecx
  802284:	89 d8                	mov    %ebx,%eax
  802286:	89 cf                	mov    %ecx,%edi
  802288:	f7 f5                	div    %ebp
  80228a:	89 c3                	mov    %eax,%ebx
  80228c:	89 d8                	mov    %ebx,%eax
  80228e:	89 fa                	mov    %edi,%edx
  802290:	83 c4 1c             	add    $0x1c,%esp
  802293:	5b                   	pop    %ebx
  802294:	5e                   	pop    %esi
  802295:	5f                   	pop    %edi
  802296:	5d                   	pop    %ebp
  802297:	c3                   	ret    
  802298:	90                   	nop
  802299:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022a0:	39 ce                	cmp    %ecx,%esi
  8022a2:	77 74                	ja     802318 <__udivdi3+0xd8>
  8022a4:	0f bd fe             	bsr    %esi,%edi
  8022a7:	83 f7 1f             	xor    $0x1f,%edi
  8022aa:	0f 84 98 00 00 00    	je     802348 <__udivdi3+0x108>
  8022b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8022b5:	89 f9                	mov    %edi,%ecx
  8022b7:	89 c5                	mov    %eax,%ebp
  8022b9:	29 fb                	sub    %edi,%ebx
  8022bb:	d3 e6                	shl    %cl,%esi
  8022bd:	89 d9                	mov    %ebx,%ecx
  8022bf:	d3 ed                	shr    %cl,%ebp
  8022c1:	89 f9                	mov    %edi,%ecx
  8022c3:	d3 e0                	shl    %cl,%eax
  8022c5:	09 ee                	or     %ebp,%esi
  8022c7:	89 d9                	mov    %ebx,%ecx
  8022c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022cd:	89 d5                	mov    %edx,%ebp
  8022cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022d3:	d3 ed                	shr    %cl,%ebp
  8022d5:	89 f9                	mov    %edi,%ecx
  8022d7:	d3 e2                	shl    %cl,%edx
  8022d9:	89 d9                	mov    %ebx,%ecx
  8022db:	d3 e8                	shr    %cl,%eax
  8022dd:	09 c2                	or     %eax,%edx
  8022df:	89 d0                	mov    %edx,%eax
  8022e1:	89 ea                	mov    %ebp,%edx
  8022e3:	f7 f6                	div    %esi
  8022e5:	89 d5                	mov    %edx,%ebp
  8022e7:	89 c3                	mov    %eax,%ebx
  8022e9:	f7 64 24 0c          	mull   0xc(%esp)
  8022ed:	39 d5                	cmp    %edx,%ebp
  8022ef:	72 10                	jb     802301 <__udivdi3+0xc1>
  8022f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8022f5:	89 f9                	mov    %edi,%ecx
  8022f7:	d3 e6                	shl    %cl,%esi
  8022f9:	39 c6                	cmp    %eax,%esi
  8022fb:	73 07                	jae    802304 <__udivdi3+0xc4>
  8022fd:	39 d5                	cmp    %edx,%ebp
  8022ff:	75 03                	jne    802304 <__udivdi3+0xc4>
  802301:	83 eb 01             	sub    $0x1,%ebx
  802304:	31 ff                	xor    %edi,%edi
  802306:	89 d8                	mov    %ebx,%eax
  802308:	89 fa                	mov    %edi,%edx
  80230a:	83 c4 1c             	add    $0x1c,%esp
  80230d:	5b                   	pop    %ebx
  80230e:	5e                   	pop    %esi
  80230f:	5f                   	pop    %edi
  802310:	5d                   	pop    %ebp
  802311:	c3                   	ret    
  802312:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802318:	31 ff                	xor    %edi,%edi
  80231a:	31 db                	xor    %ebx,%ebx
  80231c:	89 d8                	mov    %ebx,%eax
  80231e:	89 fa                	mov    %edi,%edx
  802320:	83 c4 1c             	add    $0x1c,%esp
  802323:	5b                   	pop    %ebx
  802324:	5e                   	pop    %esi
  802325:	5f                   	pop    %edi
  802326:	5d                   	pop    %ebp
  802327:	c3                   	ret    
  802328:	90                   	nop
  802329:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802330:	89 d8                	mov    %ebx,%eax
  802332:	f7 f7                	div    %edi
  802334:	31 ff                	xor    %edi,%edi
  802336:	89 c3                	mov    %eax,%ebx
  802338:	89 d8                	mov    %ebx,%eax
  80233a:	89 fa                	mov    %edi,%edx
  80233c:	83 c4 1c             	add    $0x1c,%esp
  80233f:	5b                   	pop    %ebx
  802340:	5e                   	pop    %esi
  802341:	5f                   	pop    %edi
  802342:	5d                   	pop    %ebp
  802343:	c3                   	ret    
  802344:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802348:	39 ce                	cmp    %ecx,%esi
  80234a:	72 0c                	jb     802358 <__udivdi3+0x118>
  80234c:	31 db                	xor    %ebx,%ebx
  80234e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802352:	0f 87 34 ff ff ff    	ja     80228c <__udivdi3+0x4c>
  802358:	bb 01 00 00 00       	mov    $0x1,%ebx
  80235d:	e9 2a ff ff ff       	jmp    80228c <__udivdi3+0x4c>
  802362:	66 90                	xchg   %ax,%ax
  802364:	66 90                	xchg   %ax,%ax
  802366:	66 90                	xchg   %ax,%ax
  802368:	66 90                	xchg   %ax,%ax
  80236a:	66 90                	xchg   %ax,%ax
  80236c:	66 90                	xchg   %ax,%ax
  80236e:	66 90                	xchg   %ax,%ax

00802370 <__umoddi3>:
  802370:	55                   	push   %ebp
  802371:	57                   	push   %edi
  802372:	56                   	push   %esi
  802373:	53                   	push   %ebx
  802374:	83 ec 1c             	sub    $0x1c,%esp
  802377:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80237b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80237f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802383:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802387:	85 d2                	test   %edx,%edx
  802389:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80238d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802391:	89 f3                	mov    %esi,%ebx
  802393:	89 3c 24             	mov    %edi,(%esp)
  802396:	89 74 24 04          	mov    %esi,0x4(%esp)
  80239a:	75 1c                	jne    8023b8 <__umoddi3+0x48>
  80239c:	39 f7                	cmp    %esi,%edi
  80239e:	76 50                	jbe    8023f0 <__umoddi3+0x80>
  8023a0:	89 c8                	mov    %ecx,%eax
  8023a2:	89 f2                	mov    %esi,%edx
  8023a4:	f7 f7                	div    %edi
  8023a6:	89 d0                	mov    %edx,%eax
  8023a8:	31 d2                	xor    %edx,%edx
  8023aa:	83 c4 1c             	add    $0x1c,%esp
  8023ad:	5b                   	pop    %ebx
  8023ae:	5e                   	pop    %esi
  8023af:	5f                   	pop    %edi
  8023b0:	5d                   	pop    %ebp
  8023b1:	c3                   	ret    
  8023b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023b8:	39 f2                	cmp    %esi,%edx
  8023ba:	89 d0                	mov    %edx,%eax
  8023bc:	77 52                	ja     802410 <__umoddi3+0xa0>
  8023be:	0f bd ea             	bsr    %edx,%ebp
  8023c1:	83 f5 1f             	xor    $0x1f,%ebp
  8023c4:	75 5a                	jne    802420 <__umoddi3+0xb0>
  8023c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8023ca:	0f 82 e0 00 00 00    	jb     8024b0 <__umoddi3+0x140>
  8023d0:	39 0c 24             	cmp    %ecx,(%esp)
  8023d3:	0f 86 d7 00 00 00    	jbe    8024b0 <__umoddi3+0x140>
  8023d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023e1:	83 c4 1c             	add    $0x1c,%esp
  8023e4:	5b                   	pop    %ebx
  8023e5:	5e                   	pop    %esi
  8023e6:	5f                   	pop    %edi
  8023e7:	5d                   	pop    %ebp
  8023e8:	c3                   	ret    
  8023e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023f0:	85 ff                	test   %edi,%edi
  8023f2:	89 fd                	mov    %edi,%ebp
  8023f4:	75 0b                	jne    802401 <__umoddi3+0x91>
  8023f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023fb:	31 d2                	xor    %edx,%edx
  8023fd:	f7 f7                	div    %edi
  8023ff:	89 c5                	mov    %eax,%ebp
  802401:	89 f0                	mov    %esi,%eax
  802403:	31 d2                	xor    %edx,%edx
  802405:	f7 f5                	div    %ebp
  802407:	89 c8                	mov    %ecx,%eax
  802409:	f7 f5                	div    %ebp
  80240b:	89 d0                	mov    %edx,%eax
  80240d:	eb 99                	jmp    8023a8 <__umoddi3+0x38>
  80240f:	90                   	nop
  802410:	89 c8                	mov    %ecx,%eax
  802412:	89 f2                	mov    %esi,%edx
  802414:	83 c4 1c             	add    $0x1c,%esp
  802417:	5b                   	pop    %ebx
  802418:	5e                   	pop    %esi
  802419:	5f                   	pop    %edi
  80241a:	5d                   	pop    %ebp
  80241b:	c3                   	ret    
  80241c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802420:	8b 34 24             	mov    (%esp),%esi
  802423:	bf 20 00 00 00       	mov    $0x20,%edi
  802428:	89 e9                	mov    %ebp,%ecx
  80242a:	29 ef                	sub    %ebp,%edi
  80242c:	d3 e0                	shl    %cl,%eax
  80242e:	89 f9                	mov    %edi,%ecx
  802430:	89 f2                	mov    %esi,%edx
  802432:	d3 ea                	shr    %cl,%edx
  802434:	89 e9                	mov    %ebp,%ecx
  802436:	09 c2                	or     %eax,%edx
  802438:	89 d8                	mov    %ebx,%eax
  80243a:	89 14 24             	mov    %edx,(%esp)
  80243d:	89 f2                	mov    %esi,%edx
  80243f:	d3 e2                	shl    %cl,%edx
  802441:	89 f9                	mov    %edi,%ecx
  802443:	89 54 24 04          	mov    %edx,0x4(%esp)
  802447:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80244b:	d3 e8                	shr    %cl,%eax
  80244d:	89 e9                	mov    %ebp,%ecx
  80244f:	89 c6                	mov    %eax,%esi
  802451:	d3 e3                	shl    %cl,%ebx
  802453:	89 f9                	mov    %edi,%ecx
  802455:	89 d0                	mov    %edx,%eax
  802457:	d3 e8                	shr    %cl,%eax
  802459:	89 e9                	mov    %ebp,%ecx
  80245b:	09 d8                	or     %ebx,%eax
  80245d:	89 d3                	mov    %edx,%ebx
  80245f:	89 f2                	mov    %esi,%edx
  802461:	f7 34 24             	divl   (%esp)
  802464:	89 d6                	mov    %edx,%esi
  802466:	d3 e3                	shl    %cl,%ebx
  802468:	f7 64 24 04          	mull   0x4(%esp)
  80246c:	39 d6                	cmp    %edx,%esi
  80246e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802472:	89 d1                	mov    %edx,%ecx
  802474:	89 c3                	mov    %eax,%ebx
  802476:	72 08                	jb     802480 <__umoddi3+0x110>
  802478:	75 11                	jne    80248b <__umoddi3+0x11b>
  80247a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80247e:	73 0b                	jae    80248b <__umoddi3+0x11b>
  802480:	2b 44 24 04          	sub    0x4(%esp),%eax
  802484:	1b 14 24             	sbb    (%esp),%edx
  802487:	89 d1                	mov    %edx,%ecx
  802489:	89 c3                	mov    %eax,%ebx
  80248b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80248f:	29 da                	sub    %ebx,%edx
  802491:	19 ce                	sbb    %ecx,%esi
  802493:	89 f9                	mov    %edi,%ecx
  802495:	89 f0                	mov    %esi,%eax
  802497:	d3 e0                	shl    %cl,%eax
  802499:	89 e9                	mov    %ebp,%ecx
  80249b:	d3 ea                	shr    %cl,%edx
  80249d:	89 e9                	mov    %ebp,%ecx
  80249f:	d3 ee                	shr    %cl,%esi
  8024a1:	09 d0                	or     %edx,%eax
  8024a3:	89 f2                	mov    %esi,%edx
  8024a5:	83 c4 1c             	add    $0x1c,%esp
  8024a8:	5b                   	pop    %ebx
  8024a9:	5e                   	pop    %esi
  8024aa:	5f                   	pop    %edi
  8024ab:	5d                   	pop    %ebp
  8024ac:	c3                   	ret    
  8024ad:	8d 76 00             	lea    0x0(%esi),%esi
  8024b0:	29 f9                	sub    %edi,%ecx
  8024b2:	19 d6                	sbb    %edx,%esi
  8024b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024bc:	e9 18 ff ff ff       	jmp    8023d9 <__umoddi3+0x69>
