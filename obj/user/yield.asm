
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
  800046:	68 80 22 80 00       	push   $0x802280
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
  80006d:	68 a0 22 80 00       	push   $0x8022a0
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
  800091:	68 cc 22 80 00       	push   $0x8022cc
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
  800112:	e8 63 11 00 00       	call   80127a <close_all>
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
  80021c:	e8 bf 1d 00 00       	call   801fe0 <__udivdi3>
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
  80025f:	e8 ac 1e 00 00       	call   802110 <__umoddi3>
  800264:	83 c4 14             	add    $0x14,%esp
  800267:	0f be 80 f5 22 80 00 	movsbl 0x8022f5(%eax),%eax
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
  800363:	ff 24 85 40 24 80 00 	jmp    *0x802440(,%eax,4)
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
  800427:	8b 14 85 a0 25 80 00 	mov    0x8025a0(,%eax,4),%edx
  80042e:	85 d2                	test   %edx,%edx
  800430:	75 18                	jne    80044a <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800432:	50                   	push   %eax
  800433:	68 0d 23 80 00       	push   $0x80230d
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
  80044b:	68 4d 27 80 00       	push   $0x80274d
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
  80046f:	b8 06 23 80 00       	mov    $0x802306,%eax
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
  800aea:	68 ff 25 80 00       	push   $0x8025ff
  800aef:	6a 23                	push   $0x23
  800af1:	68 1c 26 80 00       	push   $0x80261c
  800af6:	e8 b0 12 00 00       	call   801dab <_panic>

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
  800b6b:	68 ff 25 80 00       	push   $0x8025ff
  800b70:	6a 23                	push   $0x23
  800b72:	68 1c 26 80 00       	push   $0x80261c
  800b77:	e8 2f 12 00 00       	call   801dab <_panic>

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
  800bad:	68 ff 25 80 00       	push   $0x8025ff
  800bb2:	6a 23                	push   $0x23
  800bb4:	68 1c 26 80 00       	push   $0x80261c
  800bb9:	e8 ed 11 00 00       	call   801dab <_panic>

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
  800bef:	68 ff 25 80 00       	push   $0x8025ff
  800bf4:	6a 23                	push   $0x23
  800bf6:	68 1c 26 80 00       	push   $0x80261c
  800bfb:	e8 ab 11 00 00       	call   801dab <_panic>

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
  800c31:	68 ff 25 80 00       	push   $0x8025ff
  800c36:	6a 23                	push   $0x23
  800c38:	68 1c 26 80 00       	push   $0x80261c
  800c3d:	e8 69 11 00 00       	call   801dab <_panic>

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
  800c73:	68 ff 25 80 00       	push   $0x8025ff
  800c78:	6a 23                	push   $0x23
  800c7a:	68 1c 26 80 00       	push   $0x80261c
  800c7f:	e8 27 11 00 00       	call   801dab <_panic>
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
  800cb5:	68 ff 25 80 00       	push   $0x8025ff
  800cba:	6a 23                	push   $0x23
  800cbc:	68 1c 26 80 00       	push   $0x80261c
  800cc1:	e8 e5 10 00 00       	call   801dab <_panic>

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
  800d19:	68 ff 25 80 00       	push   $0x8025ff
  800d1e:	6a 23                	push   $0x23
  800d20:	68 1c 26 80 00       	push   $0x80261c
  800d25:	e8 81 10 00 00       	call   801dab <_panic>

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
  800db8:	68 2a 26 80 00       	push   $0x80262a
  800dbd:	6a 1e                	push   $0x1e
  800dbf:	68 3a 26 80 00       	push   $0x80263a
  800dc4:	e8 e2 0f 00 00       	call   801dab <_panic>
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
  800de2:	68 45 26 80 00       	push   $0x802645
  800de7:	6a 2c                	push   $0x2c
  800de9:	68 3a 26 80 00       	push   $0x80263a
  800dee:	e8 b8 0f 00 00       	call   801dab <_panic>
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
  800e2a:	68 45 26 80 00       	push   $0x802645
  800e2f:	6a 33                	push   $0x33
  800e31:	68 3a 26 80 00       	push   $0x80263a
  800e36:	e8 70 0f 00 00       	call   801dab <_panic>
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
  800e52:	68 45 26 80 00       	push   $0x802645
  800e57:	6a 37                	push   $0x37
  800e59:	68 3a 26 80 00       	push   $0x80263a
  800e5e:	e8 48 0f 00 00       	call   801dab <_panic>
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
  800e76:	e8 76 0f 00 00       	call   801df1 <set_pgfault_handler>
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
  800e8f:	68 5e 26 80 00       	push   $0x80265e
  800e94:	68 84 00 00 00       	push   $0x84
  800e99:	68 3a 26 80 00       	push   $0x80263a
  800e9e:	e8 08 0f 00 00       	call   801dab <_panic>
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
  800f4b:	68 6c 26 80 00       	push   $0x80266c
  800f50:	6a 54                	push   $0x54
  800f52:	68 3a 26 80 00       	push   $0x80263a
  800f57:	e8 4f 0e 00 00       	call   801dab <_panic>
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
  800f90:	68 6c 26 80 00       	push   $0x80266c
  800f95:	6a 5b                	push   $0x5b
  800f97:	68 3a 26 80 00       	push   $0x80263a
  800f9c:	e8 0a 0e 00 00       	call   801dab <_panic>
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
  800fbe:	68 6c 26 80 00       	push   $0x80266c
  800fc3:	6a 5f                	push   $0x5f
  800fc5:	68 3a 26 80 00       	push   $0x80263a
  800fca:	e8 dc 0d 00 00       	call   801dab <_panic>
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
  800fe8:	68 6c 26 80 00       	push   $0x80266c
  800fed:	6a 64                	push   $0x64
  800fef:	68 3a 26 80 00       	push   $0x80263a
  800ff4:	e8 b2 0d 00 00       	call   801dab <_panic>
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
  801057:	68 84 26 80 00       	push   $0x802684
  80105c:	e8 58 f1 ff ff       	call   8001b9 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801061:	c7 04 24 ec 00 80 00 	movl   $0x8000ec,(%esp)
  801068:	e8 c5 fc ff ff       	call   800d32 <sys_thread_create>
  80106d:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80106f:	83 c4 08             	add    $0x8,%esp
  801072:	53                   	push   %ebx
  801073:	68 84 26 80 00       	push   $0x802684
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

008010ac <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010ac:	55                   	push   %ebp
  8010ad:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010af:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b2:	05 00 00 00 30       	add    $0x30000000,%eax
  8010b7:	c1 e8 0c             	shr    $0xc,%eax
}
  8010ba:	5d                   	pop    %ebp
  8010bb:	c3                   	ret    

008010bc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c2:	05 00 00 00 30       	add    $0x30000000,%eax
  8010c7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010cc:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010d1:	5d                   	pop    %ebp
  8010d2:	c3                   	ret    

008010d3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010d9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010de:	89 c2                	mov    %eax,%edx
  8010e0:	c1 ea 16             	shr    $0x16,%edx
  8010e3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010ea:	f6 c2 01             	test   $0x1,%dl
  8010ed:	74 11                	je     801100 <fd_alloc+0x2d>
  8010ef:	89 c2                	mov    %eax,%edx
  8010f1:	c1 ea 0c             	shr    $0xc,%edx
  8010f4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010fb:	f6 c2 01             	test   $0x1,%dl
  8010fe:	75 09                	jne    801109 <fd_alloc+0x36>
			*fd_store = fd;
  801100:	89 01                	mov    %eax,(%ecx)
			return 0;
  801102:	b8 00 00 00 00       	mov    $0x0,%eax
  801107:	eb 17                	jmp    801120 <fd_alloc+0x4d>
  801109:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80110e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801113:	75 c9                	jne    8010de <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801115:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80111b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801120:	5d                   	pop    %ebp
  801121:	c3                   	ret    

00801122 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801122:	55                   	push   %ebp
  801123:	89 e5                	mov    %esp,%ebp
  801125:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801128:	83 f8 1f             	cmp    $0x1f,%eax
  80112b:	77 36                	ja     801163 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80112d:	c1 e0 0c             	shl    $0xc,%eax
  801130:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801135:	89 c2                	mov    %eax,%edx
  801137:	c1 ea 16             	shr    $0x16,%edx
  80113a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801141:	f6 c2 01             	test   $0x1,%dl
  801144:	74 24                	je     80116a <fd_lookup+0x48>
  801146:	89 c2                	mov    %eax,%edx
  801148:	c1 ea 0c             	shr    $0xc,%edx
  80114b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801152:	f6 c2 01             	test   $0x1,%dl
  801155:	74 1a                	je     801171 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801157:	8b 55 0c             	mov    0xc(%ebp),%edx
  80115a:	89 02                	mov    %eax,(%edx)
	return 0;
  80115c:	b8 00 00 00 00       	mov    $0x0,%eax
  801161:	eb 13                	jmp    801176 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801163:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801168:	eb 0c                	jmp    801176 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80116a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80116f:	eb 05                	jmp    801176 <fd_lookup+0x54>
  801171:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801176:	5d                   	pop    %ebp
  801177:	c3                   	ret    

00801178 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
  80117b:	83 ec 08             	sub    $0x8,%esp
  80117e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801181:	ba 24 27 80 00       	mov    $0x802724,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801186:	eb 13                	jmp    80119b <dev_lookup+0x23>
  801188:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80118b:	39 08                	cmp    %ecx,(%eax)
  80118d:	75 0c                	jne    80119b <dev_lookup+0x23>
			*dev = devtab[i];
  80118f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801192:	89 01                	mov    %eax,(%ecx)
			return 0;
  801194:	b8 00 00 00 00       	mov    $0x0,%eax
  801199:	eb 31                	jmp    8011cc <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80119b:	8b 02                	mov    (%edx),%eax
  80119d:	85 c0                	test   %eax,%eax
  80119f:	75 e7                	jne    801188 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011a1:	a1 04 40 80 00       	mov    0x804004,%eax
  8011a6:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8011ac:	83 ec 04             	sub    $0x4,%esp
  8011af:	51                   	push   %ecx
  8011b0:	50                   	push   %eax
  8011b1:	68 a8 26 80 00       	push   $0x8026a8
  8011b6:	e8 fe ef ff ff       	call   8001b9 <cprintf>
	*dev = 0;
  8011bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011be:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011c4:	83 c4 10             	add    $0x10,%esp
  8011c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011cc:	c9                   	leave  
  8011cd:	c3                   	ret    

008011ce <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011ce:	55                   	push   %ebp
  8011cf:	89 e5                	mov    %esp,%ebp
  8011d1:	56                   	push   %esi
  8011d2:	53                   	push   %ebx
  8011d3:	83 ec 10             	sub    $0x10,%esp
  8011d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8011d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011df:	50                   	push   %eax
  8011e0:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011e6:	c1 e8 0c             	shr    $0xc,%eax
  8011e9:	50                   	push   %eax
  8011ea:	e8 33 ff ff ff       	call   801122 <fd_lookup>
  8011ef:	83 c4 08             	add    $0x8,%esp
  8011f2:	85 c0                	test   %eax,%eax
  8011f4:	78 05                	js     8011fb <fd_close+0x2d>
	    || fd != fd2)
  8011f6:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011f9:	74 0c                	je     801207 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011fb:	84 db                	test   %bl,%bl
  8011fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801202:	0f 44 c2             	cmove  %edx,%eax
  801205:	eb 41                	jmp    801248 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801207:	83 ec 08             	sub    $0x8,%esp
  80120a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80120d:	50                   	push   %eax
  80120e:	ff 36                	pushl  (%esi)
  801210:	e8 63 ff ff ff       	call   801178 <dev_lookup>
  801215:	89 c3                	mov    %eax,%ebx
  801217:	83 c4 10             	add    $0x10,%esp
  80121a:	85 c0                	test   %eax,%eax
  80121c:	78 1a                	js     801238 <fd_close+0x6a>
		if (dev->dev_close)
  80121e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801221:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801224:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801229:	85 c0                	test   %eax,%eax
  80122b:	74 0b                	je     801238 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80122d:	83 ec 0c             	sub    $0xc,%esp
  801230:	56                   	push   %esi
  801231:	ff d0                	call   *%eax
  801233:	89 c3                	mov    %eax,%ebx
  801235:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801238:	83 ec 08             	sub    $0x8,%esp
  80123b:	56                   	push   %esi
  80123c:	6a 00                	push   $0x0
  80123e:	e8 83 f9 ff ff       	call   800bc6 <sys_page_unmap>
	return r;
  801243:	83 c4 10             	add    $0x10,%esp
  801246:	89 d8                	mov    %ebx,%eax
}
  801248:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80124b:	5b                   	pop    %ebx
  80124c:	5e                   	pop    %esi
  80124d:	5d                   	pop    %ebp
  80124e:	c3                   	ret    

0080124f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80124f:	55                   	push   %ebp
  801250:	89 e5                	mov    %esp,%ebp
  801252:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801255:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801258:	50                   	push   %eax
  801259:	ff 75 08             	pushl  0x8(%ebp)
  80125c:	e8 c1 fe ff ff       	call   801122 <fd_lookup>
  801261:	83 c4 08             	add    $0x8,%esp
  801264:	85 c0                	test   %eax,%eax
  801266:	78 10                	js     801278 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801268:	83 ec 08             	sub    $0x8,%esp
  80126b:	6a 01                	push   $0x1
  80126d:	ff 75 f4             	pushl  -0xc(%ebp)
  801270:	e8 59 ff ff ff       	call   8011ce <fd_close>
  801275:	83 c4 10             	add    $0x10,%esp
}
  801278:	c9                   	leave  
  801279:	c3                   	ret    

0080127a <close_all>:

void
close_all(void)
{
  80127a:	55                   	push   %ebp
  80127b:	89 e5                	mov    %esp,%ebp
  80127d:	53                   	push   %ebx
  80127e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801281:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801286:	83 ec 0c             	sub    $0xc,%esp
  801289:	53                   	push   %ebx
  80128a:	e8 c0 ff ff ff       	call   80124f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80128f:	83 c3 01             	add    $0x1,%ebx
  801292:	83 c4 10             	add    $0x10,%esp
  801295:	83 fb 20             	cmp    $0x20,%ebx
  801298:	75 ec                	jne    801286 <close_all+0xc>
		close(i);
}
  80129a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80129d:	c9                   	leave  
  80129e:	c3                   	ret    

0080129f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80129f:	55                   	push   %ebp
  8012a0:	89 e5                	mov    %esp,%ebp
  8012a2:	57                   	push   %edi
  8012a3:	56                   	push   %esi
  8012a4:	53                   	push   %ebx
  8012a5:	83 ec 2c             	sub    $0x2c,%esp
  8012a8:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012ab:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012ae:	50                   	push   %eax
  8012af:	ff 75 08             	pushl  0x8(%ebp)
  8012b2:	e8 6b fe ff ff       	call   801122 <fd_lookup>
  8012b7:	83 c4 08             	add    $0x8,%esp
  8012ba:	85 c0                	test   %eax,%eax
  8012bc:	0f 88 c1 00 00 00    	js     801383 <dup+0xe4>
		return r;
	close(newfdnum);
  8012c2:	83 ec 0c             	sub    $0xc,%esp
  8012c5:	56                   	push   %esi
  8012c6:	e8 84 ff ff ff       	call   80124f <close>

	newfd = INDEX2FD(newfdnum);
  8012cb:	89 f3                	mov    %esi,%ebx
  8012cd:	c1 e3 0c             	shl    $0xc,%ebx
  8012d0:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012d6:	83 c4 04             	add    $0x4,%esp
  8012d9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012dc:	e8 db fd ff ff       	call   8010bc <fd2data>
  8012e1:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012e3:	89 1c 24             	mov    %ebx,(%esp)
  8012e6:	e8 d1 fd ff ff       	call   8010bc <fd2data>
  8012eb:	83 c4 10             	add    $0x10,%esp
  8012ee:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012f1:	89 f8                	mov    %edi,%eax
  8012f3:	c1 e8 16             	shr    $0x16,%eax
  8012f6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012fd:	a8 01                	test   $0x1,%al
  8012ff:	74 37                	je     801338 <dup+0x99>
  801301:	89 f8                	mov    %edi,%eax
  801303:	c1 e8 0c             	shr    $0xc,%eax
  801306:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80130d:	f6 c2 01             	test   $0x1,%dl
  801310:	74 26                	je     801338 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801312:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801319:	83 ec 0c             	sub    $0xc,%esp
  80131c:	25 07 0e 00 00       	and    $0xe07,%eax
  801321:	50                   	push   %eax
  801322:	ff 75 d4             	pushl  -0x2c(%ebp)
  801325:	6a 00                	push   $0x0
  801327:	57                   	push   %edi
  801328:	6a 00                	push   $0x0
  80132a:	e8 55 f8 ff ff       	call   800b84 <sys_page_map>
  80132f:	89 c7                	mov    %eax,%edi
  801331:	83 c4 20             	add    $0x20,%esp
  801334:	85 c0                	test   %eax,%eax
  801336:	78 2e                	js     801366 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801338:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80133b:	89 d0                	mov    %edx,%eax
  80133d:	c1 e8 0c             	shr    $0xc,%eax
  801340:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801347:	83 ec 0c             	sub    $0xc,%esp
  80134a:	25 07 0e 00 00       	and    $0xe07,%eax
  80134f:	50                   	push   %eax
  801350:	53                   	push   %ebx
  801351:	6a 00                	push   $0x0
  801353:	52                   	push   %edx
  801354:	6a 00                	push   $0x0
  801356:	e8 29 f8 ff ff       	call   800b84 <sys_page_map>
  80135b:	89 c7                	mov    %eax,%edi
  80135d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801360:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801362:	85 ff                	test   %edi,%edi
  801364:	79 1d                	jns    801383 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801366:	83 ec 08             	sub    $0x8,%esp
  801369:	53                   	push   %ebx
  80136a:	6a 00                	push   $0x0
  80136c:	e8 55 f8 ff ff       	call   800bc6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801371:	83 c4 08             	add    $0x8,%esp
  801374:	ff 75 d4             	pushl  -0x2c(%ebp)
  801377:	6a 00                	push   $0x0
  801379:	e8 48 f8 ff ff       	call   800bc6 <sys_page_unmap>
	return r;
  80137e:	83 c4 10             	add    $0x10,%esp
  801381:	89 f8                	mov    %edi,%eax
}
  801383:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801386:	5b                   	pop    %ebx
  801387:	5e                   	pop    %esi
  801388:	5f                   	pop    %edi
  801389:	5d                   	pop    %ebp
  80138a:	c3                   	ret    

0080138b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80138b:	55                   	push   %ebp
  80138c:	89 e5                	mov    %esp,%ebp
  80138e:	53                   	push   %ebx
  80138f:	83 ec 14             	sub    $0x14,%esp
  801392:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801395:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801398:	50                   	push   %eax
  801399:	53                   	push   %ebx
  80139a:	e8 83 fd ff ff       	call   801122 <fd_lookup>
  80139f:	83 c4 08             	add    $0x8,%esp
  8013a2:	89 c2                	mov    %eax,%edx
  8013a4:	85 c0                	test   %eax,%eax
  8013a6:	78 70                	js     801418 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a8:	83 ec 08             	sub    $0x8,%esp
  8013ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ae:	50                   	push   %eax
  8013af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b2:	ff 30                	pushl  (%eax)
  8013b4:	e8 bf fd ff ff       	call   801178 <dev_lookup>
  8013b9:	83 c4 10             	add    $0x10,%esp
  8013bc:	85 c0                	test   %eax,%eax
  8013be:	78 4f                	js     80140f <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013c0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013c3:	8b 42 08             	mov    0x8(%edx),%eax
  8013c6:	83 e0 03             	and    $0x3,%eax
  8013c9:	83 f8 01             	cmp    $0x1,%eax
  8013cc:	75 24                	jne    8013f2 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013ce:	a1 04 40 80 00       	mov    0x804004,%eax
  8013d3:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8013d9:	83 ec 04             	sub    $0x4,%esp
  8013dc:	53                   	push   %ebx
  8013dd:	50                   	push   %eax
  8013de:	68 e9 26 80 00       	push   $0x8026e9
  8013e3:	e8 d1 ed ff ff       	call   8001b9 <cprintf>
		return -E_INVAL;
  8013e8:	83 c4 10             	add    $0x10,%esp
  8013eb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013f0:	eb 26                	jmp    801418 <read+0x8d>
	}
	if (!dev->dev_read)
  8013f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013f5:	8b 40 08             	mov    0x8(%eax),%eax
  8013f8:	85 c0                	test   %eax,%eax
  8013fa:	74 17                	je     801413 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8013fc:	83 ec 04             	sub    $0x4,%esp
  8013ff:	ff 75 10             	pushl  0x10(%ebp)
  801402:	ff 75 0c             	pushl  0xc(%ebp)
  801405:	52                   	push   %edx
  801406:	ff d0                	call   *%eax
  801408:	89 c2                	mov    %eax,%edx
  80140a:	83 c4 10             	add    $0x10,%esp
  80140d:	eb 09                	jmp    801418 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80140f:	89 c2                	mov    %eax,%edx
  801411:	eb 05                	jmp    801418 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801413:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801418:	89 d0                	mov    %edx,%eax
  80141a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80141d:	c9                   	leave  
  80141e:	c3                   	ret    

0080141f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80141f:	55                   	push   %ebp
  801420:	89 e5                	mov    %esp,%ebp
  801422:	57                   	push   %edi
  801423:	56                   	push   %esi
  801424:	53                   	push   %ebx
  801425:	83 ec 0c             	sub    $0xc,%esp
  801428:	8b 7d 08             	mov    0x8(%ebp),%edi
  80142b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80142e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801433:	eb 21                	jmp    801456 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801435:	83 ec 04             	sub    $0x4,%esp
  801438:	89 f0                	mov    %esi,%eax
  80143a:	29 d8                	sub    %ebx,%eax
  80143c:	50                   	push   %eax
  80143d:	89 d8                	mov    %ebx,%eax
  80143f:	03 45 0c             	add    0xc(%ebp),%eax
  801442:	50                   	push   %eax
  801443:	57                   	push   %edi
  801444:	e8 42 ff ff ff       	call   80138b <read>
		if (m < 0)
  801449:	83 c4 10             	add    $0x10,%esp
  80144c:	85 c0                	test   %eax,%eax
  80144e:	78 10                	js     801460 <readn+0x41>
			return m;
		if (m == 0)
  801450:	85 c0                	test   %eax,%eax
  801452:	74 0a                	je     80145e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801454:	01 c3                	add    %eax,%ebx
  801456:	39 f3                	cmp    %esi,%ebx
  801458:	72 db                	jb     801435 <readn+0x16>
  80145a:	89 d8                	mov    %ebx,%eax
  80145c:	eb 02                	jmp    801460 <readn+0x41>
  80145e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801460:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801463:	5b                   	pop    %ebx
  801464:	5e                   	pop    %esi
  801465:	5f                   	pop    %edi
  801466:	5d                   	pop    %ebp
  801467:	c3                   	ret    

00801468 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801468:	55                   	push   %ebp
  801469:	89 e5                	mov    %esp,%ebp
  80146b:	53                   	push   %ebx
  80146c:	83 ec 14             	sub    $0x14,%esp
  80146f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801472:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801475:	50                   	push   %eax
  801476:	53                   	push   %ebx
  801477:	e8 a6 fc ff ff       	call   801122 <fd_lookup>
  80147c:	83 c4 08             	add    $0x8,%esp
  80147f:	89 c2                	mov    %eax,%edx
  801481:	85 c0                	test   %eax,%eax
  801483:	78 6b                	js     8014f0 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801485:	83 ec 08             	sub    $0x8,%esp
  801488:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148b:	50                   	push   %eax
  80148c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80148f:	ff 30                	pushl  (%eax)
  801491:	e8 e2 fc ff ff       	call   801178 <dev_lookup>
  801496:	83 c4 10             	add    $0x10,%esp
  801499:	85 c0                	test   %eax,%eax
  80149b:	78 4a                	js     8014e7 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80149d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014a4:	75 24                	jne    8014ca <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8014ab:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8014b1:	83 ec 04             	sub    $0x4,%esp
  8014b4:	53                   	push   %ebx
  8014b5:	50                   	push   %eax
  8014b6:	68 05 27 80 00       	push   $0x802705
  8014bb:	e8 f9 ec ff ff       	call   8001b9 <cprintf>
		return -E_INVAL;
  8014c0:	83 c4 10             	add    $0x10,%esp
  8014c3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014c8:	eb 26                	jmp    8014f0 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014cd:	8b 52 0c             	mov    0xc(%edx),%edx
  8014d0:	85 d2                	test   %edx,%edx
  8014d2:	74 17                	je     8014eb <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014d4:	83 ec 04             	sub    $0x4,%esp
  8014d7:	ff 75 10             	pushl  0x10(%ebp)
  8014da:	ff 75 0c             	pushl  0xc(%ebp)
  8014dd:	50                   	push   %eax
  8014de:	ff d2                	call   *%edx
  8014e0:	89 c2                	mov    %eax,%edx
  8014e2:	83 c4 10             	add    $0x10,%esp
  8014e5:	eb 09                	jmp    8014f0 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e7:	89 c2                	mov    %eax,%edx
  8014e9:	eb 05                	jmp    8014f0 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014eb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014f0:	89 d0                	mov    %edx,%eax
  8014f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f5:	c9                   	leave  
  8014f6:	c3                   	ret    

008014f7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014f7:	55                   	push   %ebp
  8014f8:	89 e5                	mov    %esp,%ebp
  8014fa:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014fd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801500:	50                   	push   %eax
  801501:	ff 75 08             	pushl  0x8(%ebp)
  801504:	e8 19 fc ff ff       	call   801122 <fd_lookup>
  801509:	83 c4 08             	add    $0x8,%esp
  80150c:	85 c0                	test   %eax,%eax
  80150e:	78 0e                	js     80151e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801510:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801513:	8b 55 0c             	mov    0xc(%ebp),%edx
  801516:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801519:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80151e:	c9                   	leave  
  80151f:	c3                   	ret    

00801520 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801520:	55                   	push   %ebp
  801521:	89 e5                	mov    %esp,%ebp
  801523:	53                   	push   %ebx
  801524:	83 ec 14             	sub    $0x14,%esp
  801527:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80152a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80152d:	50                   	push   %eax
  80152e:	53                   	push   %ebx
  80152f:	e8 ee fb ff ff       	call   801122 <fd_lookup>
  801534:	83 c4 08             	add    $0x8,%esp
  801537:	89 c2                	mov    %eax,%edx
  801539:	85 c0                	test   %eax,%eax
  80153b:	78 68                	js     8015a5 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80153d:	83 ec 08             	sub    $0x8,%esp
  801540:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801543:	50                   	push   %eax
  801544:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801547:	ff 30                	pushl  (%eax)
  801549:	e8 2a fc ff ff       	call   801178 <dev_lookup>
  80154e:	83 c4 10             	add    $0x10,%esp
  801551:	85 c0                	test   %eax,%eax
  801553:	78 47                	js     80159c <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801555:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801558:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80155c:	75 24                	jne    801582 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80155e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801563:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801569:	83 ec 04             	sub    $0x4,%esp
  80156c:	53                   	push   %ebx
  80156d:	50                   	push   %eax
  80156e:	68 c8 26 80 00       	push   $0x8026c8
  801573:	e8 41 ec ff ff       	call   8001b9 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801578:	83 c4 10             	add    $0x10,%esp
  80157b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801580:	eb 23                	jmp    8015a5 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801582:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801585:	8b 52 18             	mov    0x18(%edx),%edx
  801588:	85 d2                	test   %edx,%edx
  80158a:	74 14                	je     8015a0 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80158c:	83 ec 08             	sub    $0x8,%esp
  80158f:	ff 75 0c             	pushl  0xc(%ebp)
  801592:	50                   	push   %eax
  801593:	ff d2                	call   *%edx
  801595:	89 c2                	mov    %eax,%edx
  801597:	83 c4 10             	add    $0x10,%esp
  80159a:	eb 09                	jmp    8015a5 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80159c:	89 c2                	mov    %eax,%edx
  80159e:	eb 05                	jmp    8015a5 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015a0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015a5:	89 d0                	mov    %edx,%eax
  8015a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015aa:	c9                   	leave  
  8015ab:	c3                   	ret    

008015ac <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015ac:	55                   	push   %ebp
  8015ad:	89 e5                	mov    %esp,%ebp
  8015af:	53                   	push   %ebx
  8015b0:	83 ec 14             	sub    $0x14,%esp
  8015b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b9:	50                   	push   %eax
  8015ba:	ff 75 08             	pushl  0x8(%ebp)
  8015bd:	e8 60 fb ff ff       	call   801122 <fd_lookup>
  8015c2:	83 c4 08             	add    $0x8,%esp
  8015c5:	89 c2                	mov    %eax,%edx
  8015c7:	85 c0                	test   %eax,%eax
  8015c9:	78 58                	js     801623 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015cb:	83 ec 08             	sub    $0x8,%esp
  8015ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d1:	50                   	push   %eax
  8015d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d5:	ff 30                	pushl  (%eax)
  8015d7:	e8 9c fb ff ff       	call   801178 <dev_lookup>
  8015dc:	83 c4 10             	add    $0x10,%esp
  8015df:	85 c0                	test   %eax,%eax
  8015e1:	78 37                	js     80161a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015ea:	74 32                	je     80161e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015ec:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015ef:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015f6:	00 00 00 
	stat->st_isdir = 0;
  8015f9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801600:	00 00 00 
	stat->st_dev = dev;
  801603:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801609:	83 ec 08             	sub    $0x8,%esp
  80160c:	53                   	push   %ebx
  80160d:	ff 75 f0             	pushl  -0x10(%ebp)
  801610:	ff 50 14             	call   *0x14(%eax)
  801613:	89 c2                	mov    %eax,%edx
  801615:	83 c4 10             	add    $0x10,%esp
  801618:	eb 09                	jmp    801623 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161a:	89 c2                	mov    %eax,%edx
  80161c:	eb 05                	jmp    801623 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80161e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801623:	89 d0                	mov    %edx,%eax
  801625:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801628:	c9                   	leave  
  801629:	c3                   	ret    

0080162a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80162a:	55                   	push   %ebp
  80162b:	89 e5                	mov    %esp,%ebp
  80162d:	56                   	push   %esi
  80162e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80162f:	83 ec 08             	sub    $0x8,%esp
  801632:	6a 00                	push   $0x0
  801634:	ff 75 08             	pushl  0x8(%ebp)
  801637:	e8 e3 01 00 00       	call   80181f <open>
  80163c:	89 c3                	mov    %eax,%ebx
  80163e:	83 c4 10             	add    $0x10,%esp
  801641:	85 c0                	test   %eax,%eax
  801643:	78 1b                	js     801660 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801645:	83 ec 08             	sub    $0x8,%esp
  801648:	ff 75 0c             	pushl  0xc(%ebp)
  80164b:	50                   	push   %eax
  80164c:	e8 5b ff ff ff       	call   8015ac <fstat>
  801651:	89 c6                	mov    %eax,%esi
	close(fd);
  801653:	89 1c 24             	mov    %ebx,(%esp)
  801656:	e8 f4 fb ff ff       	call   80124f <close>
	return r;
  80165b:	83 c4 10             	add    $0x10,%esp
  80165e:	89 f0                	mov    %esi,%eax
}
  801660:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801663:	5b                   	pop    %ebx
  801664:	5e                   	pop    %esi
  801665:	5d                   	pop    %ebp
  801666:	c3                   	ret    

00801667 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801667:	55                   	push   %ebp
  801668:	89 e5                	mov    %esp,%ebp
  80166a:	56                   	push   %esi
  80166b:	53                   	push   %ebx
  80166c:	89 c6                	mov    %eax,%esi
  80166e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801670:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801677:	75 12                	jne    80168b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801679:	83 ec 0c             	sub    $0xc,%esp
  80167c:	6a 01                	push   $0x1
  80167e:	e8 da 08 00 00       	call   801f5d <ipc_find_env>
  801683:	a3 00 40 80 00       	mov    %eax,0x804000
  801688:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80168b:	6a 07                	push   $0x7
  80168d:	68 00 50 80 00       	push   $0x805000
  801692:	56                   	push   %esi
  801693:	ff 35 00 40 80 00    	pushl  0x804000
  801699:	e8 5d 08 00 00       	call   801efb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80169e:	83 c4 0c             	add    $0xc,%esp
  8016a1:	6a 00                	push   $0x0
  8016a3:	53                   	push   %ebx
  8016a4:	6a 00                	push   $0x0
  8016a6:	e8 d5 07 00 00       	call   801e80 <ipc_recv>
}
  8016ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ae:	5b                   	pop    %ebx
  8016af:	5e                   	pop    %esi
  8016b0:	5d                   	pop    %ebp
  8016b1:	c3                   	ret    

008016b2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016b2:	55                   	push   %ebp
  8016b3:	89 e5                	mov    %esp,%ebp
  8016b5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8016be:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016c6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d0:	b8 02 00 00 00       	mov    $0x2,%eax
  8016d5:	e8 8d ff ff ff       	call   801667 <fsipc>
}
  8016da:	c9                   	leave  
  8016db:	c3                   	ret    

008016dc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016dc:	55                   	push   %ebp
  8016dd:	89 e5                	mov    %esp,%ebp
  8016df:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e5:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f2:	b8 06 00 00 00       	mov    $0x6,%eax
  8016f7:	e8 6b ff ff ff       	call   801667 <fsipc>
}
  8016fc:	c9                   	leave  
  8016fd:	c3                   	ret    

008016fe <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016fe:	55                   	push   %ebp
  8016ff:	89 e5                	mov    %esp,%ebp
  801701:	53                   	push   %ebx
  801702:	83 ec 04             	sub    $0x4,%esp
  801705:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801708:	8b 45 08             	mov    0x8(%ebp),%eax
  80170b:	8b 40 0c             	mov    0xc(%eax),%eax
  80170e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801713:	ba 00 00 00 00       	mov    $0x0,%edx
  801718:	b8 05 00 00 00       	mov    $0x5,%eax
  80171d:	e8 45 ff ff ff       	call   801667 <fsipc>
  801722:	85 c0                	test   %eax,%eax
  801724:	78 2c                	js     801752 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801726:	83 ec 08             	sub    $0x8,%esp
  801729:	68 00 50 80 00       	push   $0x805000
  80172e:	53                   	push   %ebx
  80172f:	e8 0a f0 ff ff       	call   80073e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801734:	a1 80 50 80 00       	mov    0x805080,%eax
  801739:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80173f:	a1 84 50 80 00       	mov    0x805084,%eax
  801744:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80174a:	83 c4 10             	add    $0x10,%esp
  80174d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801752:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801755:	c9                   	leave  
  801756:	c3                   	ret    

00801757 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801757:	55                   	push   %ebp
  801758:	89 e5                	mov    %esp,%ebp
  80175a:	83 ec 0c             	sub    $0xc,%esp
  80175d:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801760:	8b 55 08             	mov    0x8(%ebp),%edx
  801763:	8b 52 0c             	mov    0xc(%edx),%edx
  801766:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80176c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801771:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801776:	0f 47 c2             	cmova  %edx,%eax
  801779:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80177e:	50                   	push   %eax
  80177f:	ff 75 0c             	pushl  0xc(%ebp)
  801782:	68 08 50 80 00       	push   $0x805008
  801787:	e8 44 f1 ff ff       	call   8008d0 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80178c:	ba 00 00 00 00       	mov    $0x0,%edx
  801791:	b8 04 00 00 00       	mov    $0x4,%eax
  801796:	e8 cc fe ff ff       	call   801667 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80179b:	c9                   	leave  
  80179c:	c3                   	ret    

0080179d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80179d:	55                   	push   %ebp
  80179e:	89 e5                	mov    %esp,%ebp
  8017a0:	56                   	push   %esi
  8017a1:	53                   	push   %ebx
  8017a2:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a8:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ab:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017b0:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017bb:	b8 03 00 00 00       	mov    $0x3,%eax
  8017c0:	e8 a2 fe ff ff       	call   801667 <fsipc>
  8017c5:	89 c3                	mov    %eax,%ebx
  8017c7:	85 c0                	test   %eax,%eax
  8017c9:	78 4b                	js     801816 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017cb:	39 c6                	cmp    %eax,%esi
  8017cd:	73 16                	jae    8017e5 <devfile_read+0x48>
  8017cf:	68 34 27 80 00       	push   $0x802734
  8017d4:	68 3b 27 80 00       	push   $0x80273b
  8017d9:	6a 7c                	push   $0x7c
  8017db:	68 50 27 80 00       	push   $0x802750
  8017e0:	e8 c6 05 00 00       	call   801dab <_panic>
	assert(r <= PGSIZE);
  8017e5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017ea:	7e 16                	jle    801802 <devfile_read+0x65>
  8017ec:	68 5b 27 80 00       	push   $0x80275b
  8017f1:	68 3b 27 80 00       	push   $0x80273b
  8017f6:	6a 7d                	push   $0x7d
  8017f8:	68 50 27 80 00       	push   $0x802750
  8017fd:	e8 a9 05 00 00       	call   801dab <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801802:	83 ec 04             	sub    $0x4,%esp
  801805:	50                   	push   %eax
  801806:	68 00 50 80 00       	push   $0x805000
  80180b:	ff 75 0c             	pushl  0xc(%ebp)
  80180e:	e8 bd f0 ff ff       	call   8008d0 <memmove>
	return r;
  801813:	83 c4 10             	add    $0x10,%esp
}
  801816:	89 d8                	mov    %ebx,%eax
  801818:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80181b:	5b                   	pop    %ebx
  80181c:	5e                   	pop    %esi
  80181d:	5d                   	pop    %ebp
  80181e:	c3                   	ret    

0080181f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80181f:	55                   	push   %ebp
  801820:	89 e5                	mov    %esp,%ebp
  801822:	53                   	push   %ebx
  801823:	83 ec 20             	sub    $0x20,%esp
  801826:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801829:	53                   	push   %ebx
  80182a:	e8 d6 ee ff ff       	call   800705 <strlen>
  80182f:	83 c4 10             	add    $0x10,%esp
  801832:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801837:	7f 67                	jg     8018a0 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801839:	83 ec 0c             	sub    $0xc,%esp
  80183c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80183f:	50                   	push   %eax
  801840:	e8 8e f8 ff ff       	call   8010d3 <fd_alloc>
  801845:	83 c4 10             	add    $0x10,%esp
		return r;
  801848:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80184a:	85 c0                	test   %eax,%eax
  80184c:	78 57                	js     8018a5 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80184e:	83 ec 08             	sub    $0x8,%esp
  801851:	53                   	push   %ebx
  801852:	68 00 50 80 00       	push   $0x805000
  801857:	e8 e2 ee ff ff       	call   80073e <strcpy>
	fsipcbuf.open.req_omode = mode;
  80185c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80185f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801864:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801867:	b8 01 00 00 00       	mov    $0x1,%eax
  80186c:	e8 f6 fd ff ff       	call   801667 <fsipc>
  801871:	89 c3                	mov    %eax,%ebx
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	85 c0                	test   %eax,%eax
  801878:	79 14                	jns    80188e <open+0x6f>
		fd_close(fd, 0);
  80187a:	83 ec 08             	sub    $0x8,%esp
  80187d:	6a 00                	push   $0x0
  80187f:	ff 75 f4             	pushl  -0xc(%ebp)
  801882:	e8 47 f9 ff ff       	call   8011ce <fd_close>
		return r;
  801887:	83 c4 10             	add    $0x10,%esp
  80188a:	89 da                	mov    %ebx,%edx
  80188c:	eb 17                	jmp    8018a5 <open+0x86>
	}

	return fd2num(fd);
  80188e:	83 ec 0c             	sub    $0xc,%esp
  801891:	ff 75 f4             	pushl  -0xc(%ebp)
  801894:	e8 13 f8 ff ff       	call   8010ac <fd2num>
  801899:	89 c2                	mov    %eax,%edx
  80189b:	83 c4 10             	add    $0x10,%esp
  80189e:	eb 05                	jmp    8018a5 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018a0:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018a5:	89 d0                	mov    %edx,%eax
  8018a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018aa:	c9                   	leave  
  8018ab:	c3                   	ret    

008018ac <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018ac:	55                   	push   %ebp
  8018ad:	89 e5                	mov    %esp,%ebp
  8018af:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b7:	b8 08 00 00 00       	mov    $0x8,%eax
  8018bc:	e8 a6 fd ff ff       	call   801667 <fsipc>
}
  8018c1:	c9                   	leave  
  8018c2:	c3                   	ret    

008018c3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018c3:	55                   	push   %ebp
  8018c4:	89 e5                	mov    %esp,%ebp
  8018c6:	56                   	push   %esi
  8018c7:	53                   	push   %ebx
  8018c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018cb:	83 ec 0c             	sub    $0xc,%esp
  8018ce:	ff 75 08             	pushl  0x8(%ebp)
  8018d1:	e8 e6 f7 ff ff       	call   8010bc <fd2data>
  8018d6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018d8:	83 c4 08             	add    $0x8,%esp
  8018db:	68 67 27 80 00       	push   $0x802767
  8018e0:	53                   	push   %ebx
  8018e1:	e8 58 ee ff ff       	call   80073e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018e6:	8b 46 04             	mov    0x4(%esi),%eax
  8018e9:	2b 06                	sub    (%esi),%eax
  8018eb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018f1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018f8:	00 00 00 
	stat->st_dev = &devpipe;
  8018fb:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801902:	30 80 00 
	return 0;
}
  801905:	b8 00 00 00 00       	mov    $0x0,%eax
  80190a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80190d:	5b                   	pop    %ebx
  80190e:	5e                   	pop    %esi
  80190f:	5d                   	pop    %ebp
  801910:	c3                   	ret    

00801911 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801911:	55                   	push   %ebp
  801912:	89 e5                	mov    %esp,%ebp
  801914:	53                   	push   %ebx
  801915:	83 ec 0c             	sub    $0xc,%esp
  801918:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80191b:	53                   	push   %ebx
  80191c:	6a 00                	push   $0x0
  80191e:	e8 a3 f2 ff ff       	call   800bc6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801923:	89 1c 24             	mov    %ebx,(%esp)
  801926:	e8 91 f7 ff ff       	call   8010bc <fd2data>
  80192b:	83 c4 08             	add    $0x8,%esp
  80192e:	50                   	push   %eax
  80192f:	6a 00                	push   $0x0
  801931:	e8 90 f2 ff ff       	call   800bc6 <sys_page_unmap>
}
  801936:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801939:	c9                   	leave  
  80193a:	c3                   	ret    

0080193b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80193b:	55                   	push   %ebp
  80193c:	89 e5                	mov    %esp,%ebp
  80193e:	57                   	push   %edi
  80193f:	56                   	push   %esi
  801940:	53                   	push   %ebx
  801941:	83 ec 1c             	sub    $0x1c,%esp
  801944:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801947:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801949:	a1 04 40 80 00       	mov    0x804004,%eax
  80194e:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801954:	83 ec 0c             	sub    $0xc,%esp
  801957:	ff 75 e0             	pushl  -0x20(%ebp)
  80195a:	e8 43 06 00 00       	call   801fa2 <pageref>
  80195f:	89 c3                	mov    %eax,%ebx
  801961:	89 3c 24             	mov    %edi,(%esp)
  801964:	e8 39 06 00 00       	call   801fa2 <pageref>
  801969:	83 c4 10             	add    $0x10,%esp
  80196c:	39 c3                	cmp    %eax,%ebx
  80196e:	0f 94 c1             	sete   %cl
  801971:	0f b6 c9             	movzbl %cl,%ecx
  801974:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801977:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80197d:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801983:	39 ce                	cmp    %ecx,%esi
  801985:	74 1e                	je     8019a5 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801987:	39 c3                	cmp    %eax,%ebx
  801989:	75 be                	jne    801949 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80198b:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801991:	ff 75 e4             	pushl  -0x1c(%ebp)
  801994:	50                   	push   %eax
  801995:	56                   	push   %esi
  801996:	68 6e 27 80 00       	push   $0x80276e
  80199b:	e8 19 e8 ff ff       	call   8001b9 <cprintf>
  8019a0:	83 c4 10             	add    $0x10,%esp
  8019a3:	eb a4                	jmp    801949 <_pipeisclosed+0xe>
	}
}
  8019a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019ab:	5b                   	pop    %ebx
  8019ac:	5e                   	pop    %esi
  8019ad:	5f                   	pop    %edi
  8019ae:	5d                   	pop    %ebp
  8019af:	c3                   	ret    

008019b0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019b0:	55                   	push   %ebp
  8019b1:	89 e5                	mov    %esp,%ebp
  8019b3:	57                   	push   %edi
  8019b4:	56                   	push   %esi
  8019b5:	53                   	push   %ebx
  8019b6:	83 ec 28             	sub    $0x28,%esp
  8019b9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019bc:	56                   	push   %esi
  8019bd:	e8 fa f6 ff ff       	call   8010bc <fd2data>
  8019c2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019c4:	83 c4 10             	add    $0x10,%esp
  8019c7:	bf 00 00 00 00       	mov    $0x0,%edi
  8019cc:	eb 4b                	jmp    801a19 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019ce:	89 da                	mov    %ebx,%edx
  8019d0:	89 f0                	mov    %esi,%eax
  8019d2:	e8 64 ff ff ff       	call   80193b <_pipeisclosed>
  8019d7:	85 c0                	test   %eax,%eax
  8019d9:	75 48                	jne    801a23 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019db:	e8 42 f1 ff ff       	call   800b22 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019e0:	8b 43 04             	mov    0x4(%ebx),%eax
  8019e3:	8b 0b                	mov    (%ebx),%ecx
  8019e5:	8d 51 20             	lea    0x20(%ecx),%edx
  8019e8:	39 d0                	cmp    %edx,%eax
  8019ea:	73 e2                	jae    8019ce <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019ef:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019f3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019f6:	89 c2                	mov    %eax,%edx
  8019f8:	c1 fa 1f             	sar    $0x1f,%edx
  8019fb:	89 d1                	mov    %edx,%ecx
  8019fd:	c1 e9 1b             	shr    $0x1b,%ecx
  801a00:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a03:	83 e2 1f             	and    $0x1f,%edx
  801a06:	29 ca                	sub    %ecx,%edx
  801a08:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a0c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a10:	83 c0 01             	add    $0x1,%eax
  801a13:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a16:	83 c7 01             	add    $0x1,%edi
  801a19:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a1c:	75 c2                	jne    8019e0 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a1e:	8b 45 10             	mov    0x10(%ebp),%eax
  801a21:	eb 05                	jmp    801a28 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a23:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a2b:	5b                   	pop    %ebx
  801a2c:	5e                   	pop    %esi
  801a2d:	5f                   	pop    %edi
  801a2e:	5d                   	pop    %ebp
  801a2f:	c3                   	ret    

00801a30 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a30:	55                   	push   %ebp
  801a31:	89 e5                	mov    %esp,%ebp
  801a33:	57                   	push   %edi
  801a34:	56                   	push   %esi
  801a35:	53                   	push   %ebx
  801a36:	83 ec 18             	sub    $0x18,%esp
  801a39:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a3c:	57                   	push   %edi
  801a3d:	e8 7a f6 ff ff       	call   8010bc <fd2data>
  801a42:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a44:	83 c4 10             	add    $0x10,%esp
  801a47:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a4c:	eb 3d                	jmp    801a8b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a4e:	85 db                	test   %ebx,%ebx
  801a50:	74 04                	je     801a56 <devpipe_read+0x26>
				return i;
  801a52:	89 d8                	mov    %ebx,%eax
  801a54:	eb 44                	jmp    801a9a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a56:	89 f2                	mov    %esi,%edx
  801a58:	89 f8                	mov    %edi,%eax
  801a5a:	e8 dc fe ff ff       	call   80193b <_pipeisclosed>
  801a5f:	85 c0                	test   %eax,%eax
  801a61:	75 32                	jne    801a95 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a63:	e8 ba f0 ff ff       	call   800b22 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a68:	8b 06                	mov    (%esi),%eax
  801a6a:	3b 46 04             	cmp    0x4(%esi),%eax
  801a6d:	74 df                	je     801a4e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a6f:	99                   	cltd   
  801a70:	c1 ea 1b             	shr    $0x1b,%edx
  801a73:	01 d0                	add    %edx,%eax
  801a75:	83 e0 1f             	and    $0x1f,%eax
  801a78:	29 d0                	sub    %edx,%eax
  801a7a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a82:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a85:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a88:	83 c3 01             	add    $0x1,%ebx
  801a8b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a8e:	75 d8                	jne    801a68 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a90:	8b 45 10             	mov    0x10(%ebp),%eax
  801a93:	eb 05                	jmp    801a9a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a95:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a9d:	5b                   	pop    %ebx
  801a9e:	5e                   	pop    %esi
  801a9f:	5f                   	pop    %edi
  801aa0:	5d                   	pop    %ebp
  801aa1:	c3                   	ret    

00801aa2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801aa2:	55                   	push   %ebp
  801aa3:	89 e5                	mov    %esp,%ebp
  801aa5:	56                   	push   %esi
  801aa6:	53                   	push   %ebx
  801aa7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801aaa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aad:	50                   	push   %eax
  801aae:	e8 20 f6 ff ff       	call   8010d3 <fd_alloc>
  801ab3:	83 c4 10             	add    $0x10,%esp
  801ab6:	89 c2                	mov    %eax,%edx
  801ab8:	85 c0                	test   %eax,%eax
  801aba:	0f 88 2c 01 00 00    	js     801bec <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ac0:	83 ec 04             	sub    $0x4,%esp
  801ac3:	68 07 04 00 00       	push   $0x407
  801ac8:	ff 75 f4             	pushl  -0xc(%ebp)
  801acb:	6a 00                	push   $0x0
  801acd:	e8 6f f0 ff ff       	call   800b41 <sys_page_alloc>
  801ad2:	83 c4 10             	add    $0x10,%esp
  801ad5:	89 c2                	mov    %eax,%edx
  801ad7:	85 c0                	test   %eax,%eax
  801ad9:	0f 88 0d 01 00 00    	js     801bec <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801adf:	83 ec 0c             	sub    $0xc,%esp
  801ae2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ae5:	50                   	push   %eax
  801ae6:	e8 e8 f5 ff ff       	call   8010d3 <fd_alloc>
  801aeb:	89 c3                	mov    %eax,%ebx
  801aed:	83 c4 10             	add    $0x10,%esp
  801af0:	85 c0                	test   %eax,%eax
  801af2:	0f 88 e2 00 00 00    	js     801bda <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801af8:	83 ec 04             	sub    $0x4,%esp
  801afb:	68 07 04 00 00       	push   $0x407
  801b00:	ff 75 f0             	pushl  -0x10(%ebp)
  801b03:	6a 00                	push   $0x0
  801b05:	e8 37 f0 ff ff       	call   800b41 <sys_page_alloc>
  801b0a:	89 c3                	mov    %eax,%ebx
  801b0c:	83 c4 10             	add    $0x10,%esp
  801b0f:	85 c0                	test   %eax,%eax
  801b11:	0f 88 c3 00 00 00    	js     801bda <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b17:	83 ec 0c             	sub    $0xc,%esp
  801b1a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b1d:	e8 9a f5 ff ff       	call   8010bc <fd2data>
  801b22:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b24:	83 c4 0c             	add    $0xc,%esp
  801b27:	68 07 04 00 00       	push   $0x407
  801b2c:	50                   	push   %eax
  801b2d:	6a 00                	push   $0x0
  801b2f:	e8 0d f0 ff ff       	call   800b41 <sys_page_alloc>
  801b34:	89 c3                	mov    %eax,%ebx
  801b36:	83 c4 10             	add    $0x10,%esp
  801b39:	85 c0                	test   %eax,%eax
  801b3b:	0f 88 89 00 00 00    	js     801bca <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b41:	83 ec 0c             	sub    $0xc,%esp
  801b44:	ff 75 f0             	pushl  -0x10(%ebp)
  801b47:	e8 70 f5 ff ff       	call   8010bc <fd2data>
  801b4c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b53:	50                   	push   %eax
  801b54:	6a 00                	push   $0x0
  801b56:	56                   	push   %esi
  801b57:	6a 00                	push   $0x0
  801b59:	e8 26 f0 ff ff       	call   800b84 <sys_page_map>
  801b5e:	89 c3                	mov    %eax,%ebx
  801b60:	83 c4 20             	add    $0x20,%esp
  801b63:	85 c0                	test   %eax,%eax
  801b65:	78 55                	js     801bbc <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b67:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b70:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b75:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b7c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b85:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b87:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b8a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b91:	83 ec 0c             	sub    $0xc,%esp
  801b94:	ff 75 f4             	pushl  -0xc(%ebp)
  801b97:	e8 10 f5 ff ff       	call   8010ac <fd2num>
  801b9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b9f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ba1:	83 c4 04             	add    $0x4,%esp
  801ba4:	ff 75 f0             	pushl  -0x10(%ebp)
  801ba7:	e8 00 f5 ff ff       	call   8010ac <fd2num>
  801bac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801baf:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801bb2:	83 c4 10             	add    $0x10,%esp
  801bb5:	ba 00 00 00 00       	mov    $0x0,%edx
  801bba:	eb 30                	jmp    801bec <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801bbc:	83 ec 08             	sub    $0x8,%esp
  801bbf:	56                   	push   %esi
  801bc0:	6a 00                	push   $0x0
  801bc2:	e8 ff ef ff ff       	call   800bc6 <sys_page_unmap>
  801bc7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801bca:	83 ec 08             	sub    $0x8,%esp
  801bcd:	ff 75 f0             	pushl  -0x10(%ebp)
  801bd0:	6a 00                	push   $0x0
  801bd2:	e8 ef ef ff ff       	call   800bc6 <sys_page_unmap>
  801bd7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801bda:	83 ec 08             	sub    $0x8,%esp
  801bdd:	ff 75 f4             	pushl  -0xc(%ebp)
  801be0:	6a 00                	push   $0x0
  801be2:	e8 df ef ff ff       	call   800bc6 <sys_page_unmap>
  801be7:	83 c4 10             	add    $0x10,%esp
  801bea:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801bec:	89 d0                	mov    %edx,%eax
  801bee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bf1:	5b                   	pop    %ebx
  801bf2:	5e                   	pop    %esi
  801bf3:	5d                   	pop    %ebp
  801bf4:	c3                   	ret    

00801bf5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801bf5:	55                   	push   %ebp
  801bf6:	89 e5                	mov    %esp,%ebp
  801bf8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bfb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bfe:	50                   	push   %eax
  801bff:	ff 75 08             	pushl  0x8(%ebp)
  801c02:	e8 1b f5 ff ff       	call   801122 <fd_lookup>
  801c07:	83 c4 10             	add    $0x10,%esp
  801c0a:	85 c0                	test   %eax,%eax
  801c0c:	78 18                	js     801c26 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c0e:	83 ec 0c             	sub    $0xc,%esp
  801c11:	ff 75 f4             	pushl  -0xc(%ebp)
  801c14:	e8 a3 f4 ff ff       	call   8010bc <fd2data>
	return _pipeisclosed(fd, p);
  801c19:	89 c2                	mov    %eax,%edx
  801c1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c1e:	e8 18 fd ff ff       	call   80193b <_pipeisclosed>
  801c23:	83 c4 10             	add    $0x10,%esp
}
  801c26:	c9                   	leave  
  801c27:	c3                   	ret    

00801c28 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c28:	55                   	push   %ebp
  801c29:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c2b:	b8 00 00 00 00       	mov    $0x0,%eax
  801c30:	5d                   	pop    %ebp
  801c31:	c3                   	ret    

00801c32 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c32:	55                   	push   %ebp
  801c33:	89 e5                	mov    %esp,%ebp
  801c35:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c38:	68 86 27 80 00       	push   $0x802786
  801c3d:	ff 75 0c             	pushl  0xc(%ebp)
  801c40:	e8 f9 ea ff ff       	call   80073e <strcpy>
	return 0;
}
  801c45:	b8 00 00 00 00       	mov    $0x0,%eax
  801c4a:	c9                   	leave  
  801c4b:	c3                   	ret    

00801c4c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c4c:	55                   	push   %ebp
  801c4d:	89 e5                	mov    %esp,%ebp
  801c4f:	57                   	push   %edi
  801c50:	56                   	push   %esi
  801c51:	53                   	push   %ebx
  801c52:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c58:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c5d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c63:	eb 2d                	jmp    801c92 <devcons_write+0x46>
		m = n - tot;
  801c65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c68:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c6a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c6d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c72:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c75:	83 ec 04             	sub    $0x4,%esp
  801c78:	53                   	push   %ebx
  801c79:	03 45 0c             	add    0xc(%ebp),%eax
  801c7c:	50                   	push   %eax
  801c7d:	57                   	push   %edi
  801c7e:	e8 4d ec ff ff       	call   8008d0 <memmove>
		sys_cputs(buf, m);
  801c83:	83 c4 08             	add    $0x8,%esp
  801c86:	53                   	push   %ebx
  801c87:	57                   	push   %edi
  801c88:	e8 f8 ed ff ff       	call   800a85 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c8d:	01 de                	add    %ebx,%esi
  801c8f:	83 c4 10             	add    $0x10,%esp
  801c92:	89 f0                	mov    %esi,%eax
  801c94:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c97:	72 cc                	jb     801c65 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c9c:	5b                   	pop    %ebx
  801c9d:	5e                   	pop    %esi
  801c9e:	5f                   	pop    %edi
  801c9f:	5d                   	pop    %ebp
  801ca0:	c3                   	ret    

00801ca1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ca1:	55                   	push   %ebp
  801ca2:	89 e5                	mov    %esp,%ebp
  801ca4:	83 ec 08             	sub    $0x8,%esp
  801ca7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801cac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cb0:	74 2a                	je     801cdc <devcons_read+0x3b>
  801cb2:	eb 05                	jmp    801cb9 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801cb4:	e8 69 ee ff ff       	call   800b22 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801cb9:	e8 e5 ed ff ff       	call   800aa3 <sys_cgetc>
  801cbe:	85 c0                	test   %eax,%eax
  801cc0:	74 f2                	je     801cb4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801cc2:	85 c0                	test   %eax,%eax
  801cc4:	78 16                	js     801cdc <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801cc6:	83 f8 04             	cmp    $0x4,%eax
  801cc9:	74 0c                	je     801cd7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ccb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cce:	88 02                	mov    %al,(%edx)
	return 1;
  801cd0:	b8 01 00 00 00       	mov    $0x1,%eax
  801cd5:	eb 05                	jmp    801cdc <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801cd7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801cdc:	c9                   	leave  
  801cdd:	c3                   	ret    

00801cde <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801cde:	55                   	push   %ebp
  801cdf:	89 e5                	mov    %esp,%ebp
  801ce1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ce4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801cea:	6a 01                	push   $0x1
  801cec:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cef:	50                   	push   %eax
  801cf0:	e8 90 ed ff ff       	call   800a85 <sys_cputs>
}
  801cf5:	83 c4 10             	add    $0x10,%esp
  801cf8:	c9                   	leave  
  801cf9:	c3                   	ret    

00801cfa <getchar>:

int
getchar(void)
{
  801cfa:	55                   	push   %ebp
  801cfb:	89 e5                	mov    %esp,%ebp
  801cfd:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d00:	6a 01                	push   $0x1
  801d02:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d05:	50                   	push   %eax
  801d06:	6a 00                	push   $0x0
  801d08:	e8 7e f6 ff ff       	call   80138b <read>
	if (r < 0)
  801d0d:	83 c4 10             	add    $0x10,%esp
  801d10:	85 c0                	test   %eax,%eax
  801d12:	78 0f                	js     801d23 <getchar+0x29>
		return r;
	if (r < 1)
  801d14:	85 c0                	test   %eax,%eax
  801d16:	7e 06                	jle    801d1e <getchar+0x24>
		return -E_EOF;
	return c;
  801d18:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d1c:	eb 05                	jmp    801d23 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d1e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d23:	c9                   	leave  
  801d24:	c3                   	ret    

00801d25 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d25:	55                   	push   %ebp
  801d26:	89 e5                	mov    %esp,%ebp
  801d28:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d2b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d2e:	50                   	push   %eax
  801d2f:	ff 75 08             	pushl  0x8(%ebp)
  801d32:	e8 eb f3 ff ff       	call   801122 <fd_lookup>
  801d37:	83 c4 10             	add    $0x10,%esp
  801d3a:	85 c0                	test   %eax,%eax
  801d3c:	78 11                	js     801d4f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d41:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d47:	39 10                	cmp    %edx,(%eax)
  801d49:	0f 94 c0             	sete   %al
  801d4c:	0f b6 c0             	movzbl %al,%eax
}
  801d4f:	c9                   	leave  
  801d50:	c3                   	ret    

00801d51 <opencons>:

int
opencons(void)
{
  801d51:	55                   	push   %ebp
  801d52:	89 e5                	mov    %esp,%ebp
  801d54:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d57:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d5a:	50                   	push   %eax
  801d5b:	e8 73 f3 ff ff       	call   8010d3 <fd_alloc>
  801d60:	83 c4 10             	add    $0x10,%esp
		return r;
  801d63:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d65:	85 c0                	test   %eax,%eax
  801d67:	78 3e                	js     801da7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d69:	83 ec 04             	sub    $0x4,%esp
  801d6c:	68 07 04 00 00       	push   $0x407
  801d71:	ff 75 f4             	pushl  -0xc(%ebp)
  801d74:	6a 00                	push   $0x0
  801d76:	e8 c6 ed ff ff       	call   800b41 <sys_page_alloc>
  801d7b:	83 c4 10             	add    $0x10,%esp
		return r;
  801d7e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d80:	85 c0                	test   %eax,%eax
  801d82:	78 23                	js     801da7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d84:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d8d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d92:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d99:	83 ec 0c             	sub    $0xc,%esp
  801d9c:	50                   	push   %eax
  801d9d:	e8 0a f3 ff ff       	call   8010ac <fd2num>
  801da2:	89 c2                	mov    %eax,%edx
  801da4:	83 c4 10             	add    $0x10,%esp
}
  801da7:	89 d0                	mov    %edx,%eax
  801da9:	c9                   	leave  
  801daa:	c3                   	ret    

00801dab <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801dab:	55                   	push   %ebp
  801dac:	89 e5                	mov    %esp,%ebp
  801dae:	56                   	push   %esi
  801daf:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801db0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801db3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801db9:	e8 45 ed ff ff       	call   800b03 <sys_getenvid>
  801dbe:	83 ec 0c             	sub    $0xc,%esp
  801dc1:	ff 75 0c             	pushl  0xc(%ebp)
  801dc4:	ff 75 08             	pushl  0x8(%ebp)
  801dc7:	56                   	push   %esi
  801dc8:	50                   	push   %eax
  801dc9:	68 94 27 80 00       	push   $0x802794
  801dce:	e8 e6 e3 ff ff       	call   8001b9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801dd3:	83 c4 18             	add    $0x18,%esp
  801dd6:	53                   	push   %ebx
  801dd7:	ff 75 10             	pushl  0x10(%ebp)
  801dda:	e8 89 e3 ff ff       	call   800168 <vcprintf>
	cprintf("\n");
  801ddf:	c7 04 24 7f 27 80 00 	movl   $0x80277f,(%esp)
  801de6:	e8 ce e3 ff ff       	call   8001b9 <cprintf>
  801deb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801dee:	cc                   	int3   
  801def:	eb fd                	jmp    801dee <_panic+0x43>

00801df1 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801df1:	55                   	push   %ebp
  801df2:	89 e5                	mov    %esp,%ebp
  801df4:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801df7:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801dfe:	75 2a                	jne    801e2a <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801e00:	83 ec 04             	sub    $0x4,%esp
  801e03:	6a 07                	push   $0x7
  801e05:	68 00 f0 bf ee       	push   $0xeebff000
  801e0a:	6a 00                	push   $0x0
  801e0c:	e8 30 ed ff ff       	call   800b41 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801e11:	83 c4 10             	add    $0x10,%esp
  801e14:	85 c0                	test   %eax,%eax
  801e16:	79 12                	jns    801e2a <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801e18:	50                   	push   %eax
  801e19:	68 b8 27 80 00       	push   $0x8027b8
  801e1e:	6a 23                	push   $0x23
  801e20:	68 bc 27 80 00       	push   $0x8027bc
  801e25:	e8 81 ff ff ff       	call   801dab <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e2d:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801e32:	83 ec 08             	sub    $0x8,%esp
  801e35:	68 5c 1e 80 00       	push   $0x801e5c
  801e3a:	6a 00                	push   $0x0
  801e3c:	e8 4b ee ff ff       	call   800c8c <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801e41:	83 c4 10             	add    $0x10,%esp
  801e44:	85 c0                	test   %eax,%eax
  801e46:	79 12                	jns    801e5a <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801e48:	50                   	push   %eax
  801e49:	68 b8 27 80 00       	push   $0x8027b8
  801e4e:	6a 2c                	push   $0x2c
  801e50:	68 bc 27 80 00       	push   $0x8027bc
  801e55:	e8 51 ff ff ff       	call   801dab <_panic>
	}
}
  801e5a:	c9                   	leave  
  801e5b:	c3                   	ret    

00801e5c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e5c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e5d:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e62:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e64:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801e67:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801e6b:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801e70:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801e74:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801e76:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801e79:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801e7a:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801e7d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801e7e:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e7f:	c3                   	ret    

00801e80 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e80:	55                   	push   %ebp
  801e81:	89 e5                	mov    %esp,%ebp
  801e83:	56                   	push   %esi
  801e84:	53                   	push   %ebx
  801e85:	8b 75 08             	mov    0x8(%ebp),%esi
  801e88:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e8e:	85 c0                	test   %eax,%eax
  801e90:	75 12                	jne    801ea4 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e92:	83 ec 0c             	sub    $0xc,%esp
  801e95:	68 00 00 c0 ee       	push   $0xeec00000
  801e9a:	e8 52 ee ff ff       	call   800cf1 <sys_ipc_recv>
  801e9f:	83 c4 10             	add    $0x10,%esp
  801ea2:	eb 0c                	jmp    801eb0 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801ea4:	83 ec 0c             	sub    $0xc,%esp
  801ea7:	50                   	push   %eax
  801ea8:	e8 44 ee ff ff       	call   800cf1 <sys_ipc_recv>
  801ead:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801eb0:	85 f6                	test   %esi,%esi
  801eb2:	0f 95 c1             	setne  %cl
  801eb5:	85 db                	test   %ebx,%ebx
  801eb7:	0f 95 c2             	setne  %dl
  801eba:	84 d1                	test   %dl,%cl
  801ebc:	74 09                	je     801ec7 <ipc_recv+0x47>
  801ebe:	89 c2                	mov    %eax,%edx
  801ec0:	c1 ea 1f             	shr    $0x1f,%edx
  801ec3:	84 d2                	test   %dl,%dl
  801ec5:	75 2d                	jne    801ef4 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801ec7:	85 f6                	test   %esi,%esi
  801ec9:	74 0d                	je     801ed8 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801ecb:	a1 04 40 80 00       	mov    0x804004,%eax
  801ed0:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  801ed6:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801ed8:	85 db                	test   %ebx,%ebx
  801eda:	74 0d                	je     801ee9 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801edc:	a1 04 40 80 00       	mov    0x804004,%eax
  801ee1:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  801ee7:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ee9:	a1 04 40 80 00       	mov    0x804004,%eax
  801eee:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  801ef4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ef7:	5b                   	pop    %ebx
  801ef8:	5e                   	pop    %esi
  801ef9:	5d                   	pop    %ebp
  801efa:	c3                   	ret    

00801efb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801efb:	55                   	push   %ebp
  801efc:	89 e5                	mov    %esp,%ebp
  801efe:	57                   	push   %edi
  801eff:	56                   	push   %esi
  801f00:	53                   	push   %ebx
  801f01:	83 ec 0c             	sub    $0xc,%esp
  801f04:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f07:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801f0d:	85 db                	test   %ebx,%ebx
  801f0f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f14:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801f17:	ff 75 14             	pushl  0x14(%ebp)
  801f1a:	53                   	push   %ebx
  801f1b:	56                   	push   %esi
  801f1c:	57                   	push   %edi
  801f1d:	e8 ac ed ff ff       	call   800cce <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801f22:	89 c2                	mov    %eax,%edx
  801f24:	c1 ea 1f             	shr    $0x1f,%edx
  801f27:	83 c4 10             	add    $0x10,%esp
  801f2a:	84 d2                	test   %dl,%dl
  801f2c:	74 17                	je     801f45 <ipc_send+0x4a>
  801f2e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f31:	74 12                	je     801f45 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801f33:	50                   	push   %eax
  801f34:	68 ca 27 80 00       	push   $0x8027ca
  801f39:	6a 47                	push   $0x47
  801f3b:	68 d8 27 80 00       	push   $0x8027d8
  801f40:	e8 66 fe ff ff       	call   801dab <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801f45:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f48:	75 07                	jne    801f51 <ipc_send+0x56>
			sys_yield();
  801f4a:	e8 d3 eb ff ff       	call   800b22 <sys_yield>
  801f4f:	eb c6                	jmp    801f17 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801f51:	85 c0                	test   %eax,%eax
  801f53:	75 c2                	jne    801f17 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801f55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f58:	5b                   	pop    %ebx
  801f59:	5e                   	pop    %esi
  801f5a:	5f                   	pop    %edi
  801f5b:	5d                   	pop    %ebp
  801f5c:	c3                   	ret    

00801f5d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f5d:	55                   	push   %ebp
  801f5e:	89 e5                	mov    %esp,%ebp
  801f60:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f63:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f68:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  801f6e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f74:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  801f7a:	39 ca                	cmp    %ecx,%edx
  801f7c:	75 13                	jne    801f91 <ipc_find_env+0x34>
			return envs[i].env_id;
  801f7e:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  801f84:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f89:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801f8f:	eb 0f                	jmp    801fa0 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f91:	83 c0 01             	add    $0x1,%eax
  801f94:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f99:	75 cd                	jne    801f68 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fa0:	5d                   	pop    %ebp
  801fa1:	c3                   	ret    

00801fa2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fa2:	55                   	push   %ebp
  801fa3:	89 e5                	mov    %esp,%ebp
  801fa5:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fa8:	89 d0                	mov    %edx,%eax
  801faa:	c1 e8 16             	shr    $0x16,%eax
  801fad:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fb4:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fb9:	f6 c1 01             	test   $0x1,%cl
  801fbc:	74 1d                	je     801fdb <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fbe:	c1 ea 0c             	shr    $0xc,%edx
  801fc1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fc8:	f6 c2 01             	test   $0x1,%dl
  801fcb:	74 0e                	je     801fdb <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fcd:	c1 ea 0c             	shr    $0xc,%edx
  801fd0:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fd7:	ef 
  801fd8:	0f b7 c0             	movzwl %ax,%eax
}
  801fdb:	5d                   	pop    %ebp
  801fdc:	c3                   	ret    
  801fdd:	66 90                	xchg   %ax,%ax
  801fdf:	90                   	nop

00801fe0 <__udivdi3>:
  801fe0:	55                   	push   %ebp
  801fe1:	57                   	push   %edi
  801fe2:	56                   	push   %esi
  801fe3:	53                   	push   %ebx
  801fe4:	83 ec 1c             	sub    $0x1c,%esp
  801fe7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801feb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ff3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ff7:	85 f6                	test   %esi,%esi
  801ff9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ffd:	89 ca                	mov    %ecx,%edx
  801fff:	89 f8                	mov    %edi,%eax
  802001:	75 3d                	jne    802040 <__udivdi3+0x60>
  802003:	39 cf                	cmp    %ecx,%edi
  802005:	0f 87 c5 00 00 00    	ja     8020d0 <__udivdi3+0xf0>
  80200b:	85 ff                	test   %edi,%edi
  80200d:	89 fd                	mov    %edi,%ebp
  80200f:	75 0b                	jne    80201c <__udivdi3+0x3c>
  802011:	b8 01 00 00 00       	mov    $0x1,%eax
  802016:	31 d2                	xor    %edx,%edx
  802018:	f7 f7                	div    %edi
  80201a:	89 c5                	mov    %eax,%ebp
  80201c:	89 c8                	mov    %ecx,%eax
  80201e:	31 d2                	xor    %edx,%edx
  802020:	f7 f5                	div    %ebp
  802022:	89 c1                	mov    %eax,%ecx
  802024:	89 d8                	mov    %ebx,%eax
  802026:	89 cf                	mov    %ecx,%edi
  802028:	f7 f5                	div    %ebp
  80202a:	89 c3                	mov    %eax,%ebx
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
  802040:	39 ce                	cmp    %ecx,%esi
  802042:	77 74                	ja     8020b8 <__udivdi3+0xd8>
  802044:	0f bd fe             	bsr    %esi,%edi
  802047:	83 f7 1f             	xor    $0x1f,%edi
  80204a:	0f 84 98 00 00 00    	je     8020e8 <__udivdi3+0x108>
  802050:	bb 20 00 00 00       	mov    $0x20,%ebx
  802055:	89 f9                	mov    %edi,%ecx
  802057:	89 c5                	mov    %eax,%ebp
  802059:	29 fb                	sub    %edi,%ebx
  80205b:	d3 e6                	shl    %cl,%esi
  80205d:	89 d9                	mov    %ebx,%ecx
  80205f:	d3 ed                	shr    %cl,%ebp
  802061:	89 f9                	mov    %edi,%ecx
  802063:	d3 e0                	shl    %cl,%eax
  802065:	09 ee                	or     %ebp,%esi
  802067:	89 d9                	mov    %ebx,%ecx
  802069:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80206d:	89 d5                	mov    %edx,%ebp
  80206f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802073:	d3 ed                	shr    %cl,%ebp
  802075:	89 f9                	mov    %edi,%ecx
  802077:	d3 e2                	shl    %cl,%edx
  802079:	89 d9                	mov    %ebx,%ecx
  80207b:	d3 e8                	shr    %cl,%eax
  80207d:	09 c2                	or     %eax,%edx
  80207f:	89 d0                	mov    %edx,%eax
  802081:	89 ea                	mov    %ebp,%edx
  802083:	f7 f6                	div    %esi
  802085:	89 d5                	mov    %edx,%ebp
  802087:	89 c3                	mov    %eax,%ebx
  802089:	f7 64 24 0c          	mull   0xc(%esp)
  80208d:	39 d5                	cmp    %edx,%ebp
  80208f:	72 10                	jb     8020a1 <__udivdi3+0xc1>
  802091:	8b 74 24 08          	mov    0x8(%esp),%esi
  802095:	89 f9                	mov    %edi,%ecx
  802097:	d3 e6                	shl    %cl,%esi
  802099:	39 c6                	cmp    %eax,%esi
  80209b:	73 07                	jae    8020a4 <__udivdi3+0xc4>
  80209d:	39 d5                	cmp    %edx,%ebp
  80209f:	75 03                	jne    8020a4 <__udivdi3+0xc4>
  8020a1:	83 eb 01             	sub    $0x1,%ebx
  8020a4:	31 ff                	xor    %edi,%edi
  8020a6:	89 d8                	mov    %ebx,%eax
  8020a8:	89 fa                	mov    %edi,%edx
  8020aa:	83 c4 1c             	add    $0x1c,%esp
  8020ad:	5b                   	pop    %ebx
  8020ae:	5e                   	pop    %esi
  8020af:	5f                   	pop    %edi
  8020b0:	5d                   	pop    %ebp
  8020b1:	c3                   	ret    
  8020b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020b8:	31 ff                	xor    %edi,%edi
  8020ba:	31 db                	xor    %ebx,%ebx
  8020bc:	89 d8                	mov    %ebx,%eax
  8020be:	89 fa                	mov    %edi,%edx
  8020c0:	83 c4 1c             	add    $0x1c,%esp
  8020c3:	5b                   	pop    %ebx
  8020c4:	5e                   	pop    %esi
  8020c5:	5f                   	pop    %edi
  8020c6:	5d                   	pop    %ebp
  8020c7:	c3                   	ret    
  8020c8:	90                   	nop
  8020c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020d0:	89 d8                	mov    %ebx,%eax
  8020d2:	f7 f7                	div    %edi
  8020d4:	31 ff                	xor    %edi,%edi
  8020d6:	89 c3                	mov    %eax,%ebx
  8020d8:	89 d8                	mov    %ebx,%eax
  8020da:	89 fa                	mov    %edi,%edx
  8020dc:	83 c4 1c             	add    $0x1c,%esp
  8020df:	5b                   	pop    %ebx
  8020e0:	5e                   	pop    %esi
  8020e1:	5f                   	pop    %edi
  8020e2:	5d                   	pop    %ebp
  8020e3:	c3                   	ret    
  8020e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020e8:	39 ce                	cmp    %ecx,%esi
  8020ea:	72 0c                	jb     8020f8 <__udivdi3+0x118>
  8020ec:	31 db                	xor    %ebx,%ebx
  8020ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020f2:	0f 87 34 ff ff ff    	ja     80202c <__udivdi3+0x4c>
  8020f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020fd:	e9 2a ff ff ff       	jmp    80202c <__udivdi3+0x4c>
  802102:	66 90                	xchg   %ax,%ax
  802104:	66 90                	xchg   %ax,%ax
  802106:	66 90                	xchg   %ax,%ax
  802108:	66 90                	xchg   %ax,%ax
  80210a:	66 90                	xchg   %ax,%ax
  80210c:	66 90                	xchg   %ax,%ax
  80210e:	66 90                	xchg   %ax,%ax

00802110 <__umoddi3>:
  802110:	55                   	push   %ebp
  802111:	57                   	push   %edi
  802112:	56                   	push   %esi
  802113:	53                   	push   %ebx
  802114:	83 ec 1c             	sub    $0x1c,%esp
  802117:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80211b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80211f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802123:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802127:	85 d2                	test   %edx,%edx
  802129:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80212d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802131:	89 f3                	mov    %esi,%ebx
  802133:	89 3c 24             	mov    %edi,(%esp)
  802136:	89 74 24 04          	mov    %esi,0x4(%esp)
  80213a:	75 1c                	jne    802158 <__umoddi3+0x48>
  80213c:	39 f7                	cmp    %esi,%edi
  80213e:	76 50                	jbe    802190 <__umoddi3+0x80>
  802140:	89 c8                	mov    %ecx,%eax
  802142:	89 f2                	mov    %esi,%edx
  802144:	f7 f7                	div    %edi
  802146:	89 d0                	mov    %edx,%eax
  802148:	31 d2                	xor    %edx,%edx
  80214a:	83 c4 1c             	add    $0x1c,%esp
  80214d:	5b                   	pop    %ebx
  80214e:	5e                   	pop    %esi
  80214f:	5f                   	pop    %edi
  802150:	5d                   	pop    %ebp
  802151:	c3                   	ret    
  802152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802158:	39 f2                	cmp    %esi,%edx
  80215a:	89 d0                	mov    %edx,%eax
  80215c:	77 52                	ja     8021b0 <__umoddi3+0xa0>
  80215e:	0f bd ea             	bsr    %edx,%ebp
  802161:	83 f5 1f             	xor    $0x1f,%ebp
  802164:	75 5a                	jne    8021c0 <__umoddi3+0xb0>
  802166:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80216a:	0f 82 e0 00 00 00    	jb     802250 <__umoddi3+0x140>
  802170:	39 0c 24             	cmp    %ecx,(%esp)
  802173:	0f 86 d7 00 00 00    	jbe    802250 <__umoddi3+0x140>
  802179:	8b 44 24 08          	mov    0x8(%esp),%eax
  80217d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802181:	83 c4 1c             	add    $0x1c,%esp
  802184:	5b                   	pop    %ebx
  802185:	5e                   	pop    %esi
  802186:	5f                   	pop    %edi
  802187:	5d                   	pop    %ebp
  802188:	c3                   	ret    
  802189:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802190:	85 ff                	test   %edi,%edi
  802192:	89 fd                	mov    %edi,%ebp
  802194:	75 0b                	jne    8021a1 <__umoddi3+0x91>
  802196:	b8 01 00 00 00       	mov    $0x1,%eax
  80219b:	31 d2                	xor    %edx,%edx
  80219d:	f7 f7                	div    %edi
  80219f:	89 c5                	mov    %eax,%ebp
  8021a1:	89 f0                	mov    %esi,%eax
  8021a3:	31 d2                	xor    %edx,%edx
  8021a5:	f7 f5                	div    %ebp
  8021a7:	89 c8                	mov    %ecx,%eax
  8021a9:	f7 f5                	div    %ebp
  8021ab:	89 d0                	mov    %edx,%eax
  8021ad:	eb 99                	jmp    802148 <__umoddi3+0x38>
  8021af:	90                   	nop
  8021b0:	89 c8                	mov    %ecx,%eax
  8021b2:	89 f2                	mov    %esi,%edx
  8021b4:	83 c4 1c             	add    $0x1c,%esp
  8021b7:	5b                   	pop    %ebx
  8021b8:	5e                   	pop    %esi
  8021b9:	5f                   	pop    %edi
  8021ba:	5d                   	pop    %ebp
  8021bb:	c3                   	ret    
  8021bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	8b 34 24             	mov    (%esp),%esi
  8021c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021c8:	89 e9                	mov    %ebp,%ecx
  8021ca:	29 ef                	sub    %ebp,%edi
  8021cc:	d3 e0                	shl    %cl,%eax
  8021ce:	89 f9                	mov    %edi,%ecx
  8021d0:	89 f2                	mov    %esi,%edx
  8021d2:	d3 ea                	shr    %cl,%edx
  8021d4:	89 e9                	mov    %ebp,%ecx
  8021d6:	09 c2                	or     %eax,%edx
  8021d8:	89 d8                	mov    %ebx,%eax
  8021da:	89 14 24             	mov    %edx,(%esp)
  8021dd:	89 f2                	mov    %esi,%edx
  8021df:	d3 e2                	shl    %cl,%edx
  8021e1:	89 f9                	mov    %edi,%ecx
  8021e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021eb:	d3 e8                	shr    %cl,%eax
  8021ed:	89 e9                	mov    %ebp,%ecx
  8021ef:	89 c6                	mov    %eax,%esi
  8021f1:	d3 e3                	shl    %cl,%ebx
  8021f3:	89 f9                	mov    %edi,%ecx
  8021f5:	89 d0                	mov    %edx,%eax
  8021f7:	d3 e8                	shr    %cl,%eax
  8021f9:	89 e9                	mov    %ebp,%ecx
  8021fb:	09 d8                	or     %ebx,%eax
  8021fd:	89 d3                	mov    %edx,%ebx
  8021ff:	89 f2                	mov    %esi,%edx
  802201:	f7 34 24             	divl   (%esp)
  802204:	89 d6                	mov    %edx,%esi
  802206:	d3 e3                	shl    %cl,%ebx
  802208:	f7 64 24 04          	mull   0x4(%esp)
  80220c:	39 d6                	cmp    %edx,%esi
  80220e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802212:	89 d1                	mov    %edx,%ecx
  802214:	89 c3                	mov    %eax,%ebx
  802216:	72 08                	jb     802220 <__umoddi3+0x110>
  802218:	75 11                	jne    80222b <__umoddi3+0x11b>
  80221a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80221e:	73 0b                	jae    80222b <__umoddi3+0x11b>
  802220:	2b 44 24 04          	sub    0x4(%esp),%eax
  802224:	1b 14 24             	sbb    (%esp),%edx
  802227:	89 d1                	mov    %edx,%ecx
  802229:	89 c3                	mov    %eax,%ebx
  80222b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80222f:	29 da                	sub    %ebx,%edx
  802231:	19 ce                	sbb    %ecx,%esi
  802233:	89 f9                	mov    %edi,%ecx
  802235:	89 f0                	mov    %esi,%eax
  802237:	d3 e0                	shl    %cl,%eax
  802239:	89 e9                	mov    %ebp,%ecx
  80223b:	d3 ea                	shr    %cl,%edx
  80223d:	89 e9                	mov    %ebp,%ecx
  80223f:	d3 ee                	shr    %cl,%esi
  802241:	09 d0                	or     %edx,%eax
  802243:	89 f2                	mov    %esi,%edx
  802245:	83 c4 1c             	add    $0x1c,%esp
  802248:	5b                   	pop    %ebx
  802249:	5e                   	pop    %esi
  80224a:	5f                   	pop    %edi
  80224b:	5d                   	pop    %ebp
  80224c:	c3                   	ret    
  80224d:	8d 76 00             	lea    0x0(%esi),%esi
  802250:	29 f9                	sub    %edi,%ecx
  802252:	19 d6                	sbb    %edx,%esi
  802254:	89 74 24 04          	mov    %esi,0x4(%esp)
  802258:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80225c:	e9 18 ff ff ff       	jmp    802179 <__umoddi3+0x69>
