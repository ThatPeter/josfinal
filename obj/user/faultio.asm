
obj/user/faultio.debug:     file format elf32-i386


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
  80002c:	e8 3c 00 00 00       	call   80006d <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>
#include <inc/x86.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
  800039:	9c                   	pushf  
  80003a:	58                   	pop    %eax
        int x, r;
	int nsecs = 1;
	int secno = 0;
	int diskno = 1;

	if (read_eflags() & FL_IOPL_3)
  80003b:	f6 c4 30             	test   $0x30,%ah
  80003e:	74 10                	je     800050 <umain+0x1d>
		cprintf("eflags wrong\n");
  800040:	83 ec 0c             	sub    $0xc,%esp
  800043:	68 20 24 80 00       	push   $0x802420
  800048:	e8 36 01 00 00       	call   800183 <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800050:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800055:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80005a:	ee                   	out    %al,(%dx)

	// this outb to select disk 1 should result in a general protection
	// fault, because user-level code shouldn't be able to use the io space.
	outb(0x1F6, 0xE0 | (1<<4));

        cprintf("%s: made it here --- bug\n");
  80005b:	83 ec 0c             	sub    $0xc,%esp
  80005e:	68 2e 24 80 00       	push   $0x80242e
  800063:	e8 1b 01 00 00       	call   800183 <cprintf>
}
  800068:	83 c4 10             	add    $0x10,%esp
  80006b:	c9                   	leave  
  80006c:	c3                   	ret    

0080006d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80006d:	55                   	push   %ebp
  80006e:	89 e5                	mov    %esp,%ebp
  800070:	56                   	push   %esi
  800071:	53                   	push   %ebx
  800072:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800075:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800078:	e8 50 0a 00 00       	call   800acd <sys_getenvid>
  80007d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800082:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800088:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800092:	85 db                	test   %ebx,%ebx
  800094:	7e 07                	jle    80009d <libmain+0x30>
		binaryname = argv[0];
  800096:	8b 06                	mov    (%esi),%eax
  800098:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80009d:	83 ec 08             	sub    $0x8,%esp
  8000a0:	56                   	push   %esi
  8000a1:	53                   	push   %ebx
  8000a2:	e8 8c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a7:	e8 2a 00 00 00       	call   8000d6 <exit>
}
  8000ac:	83 c4 10             	add    $0x10,%esp
  8000af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000b2:	5b                   	pop    %ebx
  8000b3:	5e                   	pop    %esi
  8000b4:	5d                   	pop    %ebp
  8000b5:	c3                   	ret    

008000b6 <thread_main>:

/*Lab 7: Multithreading thread main routine*/
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  8000b6:	55                   	push   %ebp
  8000b7:	89 e5                	mov    %esp,%ebp
  8000b9:	83 ec 08             	sub    $0x8,%esp
	void (*func)(void) = (void (*)(void))eip;
  8000bc:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  8000c1:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8000c3:	e8 05 0a 00 00       	call   800acd <sys_getenvid>
  8000c8:	83 ec 0c             	sub    $0xc,%esp
  8000cb:	50                   	push   %eax
  8000cc:	e8 4b 0c 00 00       	call   800d1c <sys_thread_free>
}
  8000d1:	83 c4 10             	add    $0x10,%esp
  8000d4:	c9                   	leave  
  8000d5:	c3                   	ret    

008000d6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000dc:	e8 43 13 00 00       	call   801424 <close_all>
	sys_env_destroy(0);
  8000e1:	83 ec 0c             	sub    $0xc,%esp
  8000e4:	6a 00                	push   $0x0
  8000e6:	e8 a1 09 00 00       	call   800a8c <sys_env_destroy>
}
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	c9                   	leave  
  8000ef:	c3                   	ret    

008000f0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	53                   	push   %ebx
  8000f4:	83 ec 04             	sub    $0x4,%esp
  8000f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000fa:	8b 13                	mov    (%ebx),%edx
  8000fc:	8d 42 01             	lea    0x1(%edx),%eax
  8000ff:	89 03                	mov    %eax,(%ebx)
  800101:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800104:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800108:	3d ff 00 00 00       	cmp    $0xff,%eax
  80010d:	75 1a                	jne    800129 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80010f:	83 ec 08             	sub    $0x8,%esp
  800112:	68 ff 00 00 00       	push   $0xff
  800117:	8d 43 08             	lea    0x8(%ebx),%eax
  80011a:	50                   	push   %eax
  80011b:	e8 2f 09 00 00       	call   800a4f <sys_cputs>
		b->idx = 0;
  800120:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800126:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800129:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80012d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800130:	c9                   	leave  
  800131:	c3                   	ret    

00800132 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80013b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800142:	00 00 00 
	b.cnt = 0;
  800145:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80014c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80014f:	ff 75 0c             	pushl  0xc(%ebp)
  800152:	ff 75 08             	pushl  0x8(%ebp)
  800155:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80015b:	50                   	push   %eax
  80015c:	68 f0 00 80 00       	push   $0x8000f0
  800161:	e8 54 01 00 00       	call   8002ba <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800166:	83 c4 08             	add    $0x8,%esp
  800169:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80016f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800175:	50                   	push   %eax
  800176:	e8 d4 08 00 00       	call   800a4f <sys_cputs>

	return b.cnt;
}
  80017b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800181:	c9                   	leave  
  800182:	c3                   	ret    

00800183 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800189:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80018c:	50                   	push   %eax
  80018d:	ff 75 08             	pushl  0x8(%ebp)
  800190:	e8 9d ff ff ff       	call   800132 <vcprintf>
	va_end(ap);

	return cnt;
}
  800195:	c9                   	leave  
  800196:	c3                   	ret    

00800197 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	57                   	push   %edi
  80019b:	56                   	push   %esi
  80019c:	53                   	push   %ebx
  80019d:	83 ec 1c             	sub    $0x1c,%esp
  8001a0:	89 c7                	mov    %eax,%edi
  8001a2:	89 d6                	mov    %edx,%esi
  8001a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001aa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001ad:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001b8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001bb:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001be:	39 d3                	cmp    %edx,%ebx
  8001c0:	72 05                	jb     8001c7 <printnum+0x30>
  8001c2:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001c5:	77 45                	ja     80020c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c7:	83 ec 0c             	sub    $0xc,%esp
  8001ca:	ff 75 18             	pushl  0x18(%ebp)
  8001cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8001d0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001d3:	53                   	push   %ebx
  8001d4:	ff 75 10             	pushl  0x10(%ebp)
  8001d7:	83 ec 08             	sub    $0x8,%esp
  8001da:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001dd:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e6:	e8 a5 1f 00 00       	call   802190 <__udivdi3>
  8001eb:	83 c4 18             	add    $0x18,%esp
  8001ee:	52                   	push   %edx
  8001ef:	50                   	push   %eax
  8001f0:	89 f2                	mov    %esi,%edx
  8001f2:	89 f8                	mov    %edi,%eax
  8001f4:	e8 9e ff ff ff       	call   800197 <printnum>
  8001f9:	83 c4 20             	add    $0x20,%esp
  8001fc:	eb 18                	jmp    800216 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001fe:	83 ec 08             	sub    $0x8,%esp
  800201:	56                   	push   %esi
  800202:	ff 75 18             	pushl  0x18(%ebp)
  800205:	ff d7                	call   *%edi
  800207:	83 c4 10             	add    $0x10,%esp
  80020a:	eb 03                	jmp    80020f <printnum+0x78>
  80020c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80020f:	83 eb 01             	sub    $0x1,%ebx
  800212:	85 db                	test   %ebx,%ebx
  800214:	7f e8                	jg     8001fe <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800216:	83 ec 08             	sub    $0x8,%esp
  800219:	56                   	push   %esi
  80021a:	83 ec 04             	sub    $0x4,%esp
  80021d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800220:	ff 75 e0             	pushl  -0x20(%ebp)
  800223:	ff 75 dc             	pushl  -0x24(%ebp)
  800226:	ff 75 d8             	pushl  -0x28(%ebp)
  800229:	e8 92 20 00 00       	call   8022c0 <__umoddi3>
  80022e:	83 c4 14             	add    $0x14,%esp
  800231:	0f be 80 52 24 80 00 	movsbl 0x802452(%eax),%eax
  800238:	50                   	push   %eax
  800239:	ff d7                	call   *%edi
}
  80023b:	83 c4 10             	add    $0x10,%esp
  80023e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800241:	5b                   	pop    %ebx
  800242:	5e                   	pop    %esi
  800243:	5f                   	pop    %edi
  800244:	5d                   	pop    %ebp
  800245:	c3                   	ret    

00800246 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800246:	55                   	push   %ebp
  800247:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800249:	83 fa 01             	cmp    $0x1,%edx
  80024c:	7e 0e                	jle    80025c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80024e:	8b 10                	mov    (%eax),%edx
  800250:	8d 4a 08             	lea    0x8(%edx),%ecx
  800253:	89 08                	mov    %ecx,(%eax)
  800255:	8b 02                	mov    (%edx),%eax
  800257:	8b 52 04             	mov    0x4(%edx),%edx
  80025a:	eb 22                	jmp    80027e <getuint+0x38>
	else if (lflag)
  80025c:	85 d2                	test   %edx,%edx
  80025e:	74 10                	je     800270 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800260:	8b 10                	mov    (%eax),%edx
  800262:	8d 4a 04             	lea    0x4(%edx),%ecx
  800265:	89 08                	mov    %ecx,(%eax)
  800267:	8b 02                	mov    (%edx),%eax
  800269:	ba 00 00 00 00       	mov    $0x0,%edx
  80026e:	eb 0e                	jmp    80027e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800270:	8b 10                	mov    (%eax),%edx
  800272:	8d 4a 04             	lea    0x4(%edx),%ecx
  800275:	89 08                	mov    %ecx,(%eax)
  800277:	8b 02                	mov    (%edx),%eax
  800279:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80027e:	5d                   	pop    %ebp
  80027f:	c3                   	ret    

00800280 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800286:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80028a:	8b 10                	mov    (%eax),%edx
  80028c:	3b 50 04             	cmp    0x4(%eax),%edx
  80028f:	73 0a                	jae    80029b <sprintputch+0x1b>
		*b->buf++ = ch;
  800291:	8d 4a 01             	lea    0x1(%edx),%ecx
  800294:	89 08                	mov    %ecx,(%eax)
  800296:	8b 45 08             	mov    0x8(%ebp),%eax
  800299:	88 02                	mov    %al,(%edx)
}
  80029b:	5d                   	pop    %ebp
  80029c:	c3                   	ret    

0080029d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002a3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002a6:	50                   	push   %eax
  8002a7:	ff 75 10             	pushl  0x10(%ebp)
  8002aa:	ff 75 0c             	pushl  0xc(%ebp)
  8002ad:	ff 75 08             	pushl  0x8(%ebp)
  8002b0:	e8 05 00 00 00       	call   8002ba <vprintfmt>
	va_end(ap);
}
  8002b5:	83 c4 10             	add    $0x10,%esp
  8002b8:	c9                   	leave  
  8002b9:	c3                   	ret    

008002ba <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ba:	55                   	push   %ebp
  8002bb:	89 e5                	mov    %esp,%ebp
  8002bd:	57                   	push   %edi
  8002be:	56                   	push   %esi
  8002bf:	53                   	push   %ebx
  8002c0:	83 ec 2c             	sub    $0x2c,%esp
  8002c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8002c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002c9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002cc:	eb 12                	jmp    8002e0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ce:	85 c0                	test   %eax,%eax
  8002d0:	0f 84 89 03 00 00    	je     80065f <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002d6:	83 ec 08             	sub    $0x8,%esp
  8002d9:	53                   	push   %ebx
  8002da:	50                   	push   %eax
  8002db:	ff d6                	call   *%esi
  8002dd:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002e0:	83 c7 01             	add    $0x1,%edi
  8002e3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002e7:	83 f8 25             	cmp    $0x25,%eax
  8002ea:	75 e2                	jne    8002ce <vprintfmt+0x14>
  8002ec:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002f0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002f7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002fe:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800305:	ba 00 00 00 00       	mov    $0x0,%edx
  80030a:	eb 07                	jmp    800313 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80030f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800313:	8d 47 01             	lea    0x1(%edi),%eax
  800316:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800319:	0f b6 07             	movzbl (%edi),%eax
  80031c:	0f b6 c8             	movzbl %al,%ecx
  80031f:	83 e8 23             	sub    $0x23,%eax
  800322:	3c 55                	cmp    $0x55,%al
  800324:	0f 87 1a 03 00 00    	ja     800644 <vprintfmt+0x38a>
  80032a:	0f b6 c0             	movzbl %al,%eax
  80032d:	ff 24 85 a0 25 80 00 	jmp    *0x8025a0(,%eax,4)
  800334:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800337:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80033b:	eb d6                	jmp    800313 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800340:	b8 00 00 00 00       	mov    $0x0,%eax
  800345:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800348:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80034b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80034f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800352:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800355:	83 fa 09             	cmp    $0x9,%edx
  800358:	77 39                	ja     800393 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80035a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80035d:	eb e9                	jmp    800348 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80035f:	8b 45 14             	mov    0x14(%ebp),%eax
  800362:	8d 48 04             	lea    0x4(%eax),%ecx
  800365:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800368:	8b 00                	mov    (%eax),%eax
  80036a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800370:	eb 27                	jmp    800399 <vprintfmt+0xdf>
  800372:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800375:	85 c0                	test   %eax,%eax
  800377:	b9 00 00 00 00       	mov    $0x0,%ecx
  80037c:	0f 49 c8             	cmovns %eax,%ecx
  80037f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800382:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800385:	eb 8c                	jmp    800313 <vprintfmt+0x59>
  800387:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80038a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800391:	eb 80                	jmp    800313 <vprintfmt+0x59>
  800393:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800396:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800399:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80039d:	0f 89 70 ff ff ff    	jns    800313 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003a3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003b0:	e9 5e ff ff ff       	jmp    800313 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003b5:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003bb:	e9 53 ff ff ff       	jmp    800313 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c3:	8d 50 04             	lea    0x4(%eax),%edx
  8003c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c9:	83 ec 08             	sub    $0x8,%esp
  8003cc:	53                   	push   %ebx
  8003cd:	ff 30                	pushl  (%eax)
  8003cf:	ff d6                	call   *%esi
			break;
  8003d1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003d7:	e9 04 ff ff ff       	jmp    8002e0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003df:	8d 50 04             	lea    0x4(%eax),%edx
  8003e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e5:	8b 00                	mov    (%eax),%eax
  8003e7:	99                   	cltd   
  8003e8:	31 d0                	xor    %edx,%eax
  8003ea:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ec:	83 f8 0f             	cmp    $0xf,%eax
  8003ef:	7f 0b                	jg     8003fc <vprintfmt+0x142>
  8003f1:	8b 14 85 00 27 80 00 	mov    0x802700(,%eax,4),%edx
  8003f8:	85 d2                	test   %edx,%edx
  8003fa:	75 18                	jne    800414 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003fc:	50                   	push   %eax
  8003fd:	68 6a 24 80 00       	push   $0x80246a
  800402:	53                   	push   %ebx
  800403:	56                   	push   %esi
  800404:	e8 94 fe ff ff       	call   80029d <printfmt>
  800409:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80040f:	e9 cc fe ff ff       	jmp    8002e0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800414:	52                   	push   %edx
  800415:	68 bd 28 80 00       	push   $0x8028bd
  80041a:	53                   	push   %ebx
  80041b:	56                   	push   %esi
  80041c:	e8 7c fe ff ff       	call   80029d <printfmt>
  800421:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800424:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800427:	e9 b4 fe ff ff       	jmp    8002e0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80042c:	8b 45 14             	mov    0x14(%ebp),%eax
  80042f:	8d 50 04             	lea    0x4(%eax),%edx
  800432:	89 55 14             	mov    %edx,0x14(%ebp)
  800435:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800437:	85 ff                	test   %edi,%edi
  800439:	b8 63 24 80 00       	mov    $0x802463,%eax
  80043e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800441:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800445:	0f 8e 94 00 00 00    	jle    8004df <vprintfmt+0x225>
  80044b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80044f:	0f 84 98 00 00 00    	je     8004ed <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800455:	83 ec 08             	sub    $0x8,%esp
  800458:	ff 75 d0             	pushl  -0x30(%ebp)
  80045b:	57                   	push   %edi
  80045c:	e8 86 02 00 00       	call   8006e7 <strnlen>
  800461:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800464:	29 c1                	sub    %eax,%ecx
  800466:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800469:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80046c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800470:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800473:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800476:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800478:	eb 0f                	jmp    800489 <vprintfmt+0x1cf>
					putch(padc, putdat);
  80047a:	83 ec 08             	sub    $0x8,%esp
  80047d:	53                   	push   %ebx
  80047e:	ff 75 e0             	pushl  -0x20(%ebp)
  800481:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800483:	83 ef 01             	sub    $0x1,%edi
  800486:	83 c4 10             	add    $0x10,%esp
  800489:	85 ff                	test   %edi,%edi
  80048b:	7f ed                	jg     80047a <vprintfmt+0x1c0>
  80048d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800490:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800493:	85 c9                	test   %ecx,%ecx
  800495:	b8 00 00 00 00       	mov    $0x0,%eax
  80049a:	0f 49 c1             	cmovns %ecx,%eax
  80049d:	29 c1                	sub    %eax,%ecx
  80049f:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004a5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004a8:	89 cb                	mov    %ecx,%ebx
  8004aa:	eb 4d                	jmp    8004f9 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004ac:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b0:	74 1b                	je     8004cd <vprintfmt+0x213>
  8004b2:	0f be c0             	movsbl %al,%eax
  8004b5:	83 e8 20             	sub    $0x20,%eax
  8004b8:	83 f8 5e             	cmp    $0x5e,%eax
  8004bb:	76 10                	jbe    8004cd <vprintfmt+0x213>
					putch('?', putdat);
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	ff 75 0c             	pushl  0xc(%ebp)
  8004c3:	6a 3f                	push   $0x3f
  8004c5:	ff 55 08             	call   *0x8(%ebp)
  8004c8:	83 c4 10             	add    $0x10,%esp
  8004cb:	eb 0d                	jmp    8004da <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004cd:	83 ec 08             	sub    $0x8,%esp
  8004d0:	ff 75 0c             	pushl  0xc(%ebp)
  8004d3:	52                   	push   %edx
  8004d4:	ff 55 08             	call   *0x8(%ebp)
  8004d7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004da:	83 eb 01             	sub    $0x1,%ebx
  8004dd:	eb 1a                	jmp    8004f9 <vprintfmt+0x23f>
  8004df:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004eb:	eb 0c                	jmp    8004f9 <vprintfmt+0x23f>
  8004ed:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f9:	83 c7 01             	add    $0x1,%edi
  8004fc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800500:	0f be d0             	movsbl %al,%edx
  800503:	85 d2                	test   %edx,%edx
  800505:	74 23                	je     80052a <vprintfmt+0x270>
  800507:	85 f6                	test   %esi,%esi
  800509:	78 a1                	js     8004ac <vprintfmt+0x1f2>
  80050b:	83 ee 01             	sub    $0x1,%esi
  80050e:	79 9c                	jns    8004ac <vprintfmt+0x1f2>
  800510:	89 df                	mov    %ebx,%edi
  800512:	8b 75 08             	mov    0x8(%ebp),%esi
  800515:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800518:	eb 18                	jmp    800532 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80051a:	83 ec 08             	sub    $0x8,%esp
  80051d:	53                   	push   %ebx
  80051e:	6a 20                	push   $0x20
  800520:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800522:	83 ef 01             	sub    $0x1,%edi
  800525:	83 c4 10             	add    $0x10,%esp
  800528:	eb 08                	jmp    800532 <vprintfmt+0x278>
  80052a:	89 df                	mov    %ebx,%edi
  80052c:	8b 75 08             	mov    0x8(%ebp),%esi
  80052f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800532:	85 ff                	test   %edi,%edi
  800534:	7f e4                	jg     80051a <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800536:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800539:	e9 a2 fd ff ff       	jmp    8002e0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80053e:	83 fa 01             	cmp    $0x1,%edx
  800541:	7e 16                	jle    800559 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800543:	8b 45 14             	mov    0x14(%ebp),%eax
  800546:	8d 50 08             	lea    0x8(%eax),%edx
  800549:	89 55 14             	mov    %edx,0x14(%ebp)
  80054c:	8b 50 04             	mov    0x4(%eax),%edx
  80054f:	8b 00                	mov    (%eax),%eax
  800551:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800554:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800557:	eb 32                	jmp    80058b <vprintfmt+0x2d1>
	else if (lflag)
  800559:	85 d2                	test   %edx,%edx
  80055b:	74 18                	je     800575 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80055d:	8b 45 14             	mov    0x14(%ebp),%eax
  800560:	8d 50 04             	lea    0x4(%eax),%edx
  800563:	89 55 14             	mov    %edx,0x14(%ebp)
  800566:	8b 00                	mov    (%eax),%eax
  800568:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056b:	89 c1                	mov    %eax,%ecx
  80056d:	c1 f9 1f             	sar    $0x1f,%ecx
  800570:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800573:	eb 16                	jmp    80058b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800575:	8b 45 14             	mov    0x14(%ebp),%eax
  800578:	8d 50 04             	lea    0x4(%eax),%edx
  80057b:	89 55 14             	mov    %edx,0x14(%ebp)
  80057e:	8b 00                	mov    (%eax),%eax
  800580:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800583:	89 c1                	mov    %eax,%ecx
  800585:	c1 f9 1f             	sar    $0x1f,%ecx
  800588:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80058b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80058e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800591:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800596:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80059a:	79 74                	jns    800610 <vprintfmt+0x356>
				putch('-', putdat);
  80059c:	83 ec 08             	sub    $0x8,%esp
  80059f:	53                   	push   %ebx
  8005a0:	6a 2d                	push   $0x2d
  8005a2:	ff d6                	call   *%esi
				num = -(long long) num;
  8005a4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005a7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005aa:	f7 d8                	neg    %eax
  8005ac:	83 d2 00             	adc    $0x0,%edx
  8005af:	f7 da                	neg    %edx
  8005b1:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005b4:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005b9:	eb 55                	jmp    800610 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005be:	e8 83 fc ff ff       	call   800246 <getuint>
			base = 10;
  8005c3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005c8:	eb 46                	jmp    800610 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005ca:	8d 45 14             	lea    0x14(%ebp),%eax
  8005cd:	e8 74 fc ff ff       	call   800246 <getuint>
			base = 8;
  8005d2:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005d7:	eb 37                	jmp    800610 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005d9:	83 ec 08             	sub    $0x8,%esp
  8005dc:	53                   	push   %ebx
  8005dd:	6a 30                	push   $0x30
  8005df:	ff d6                	call   *%esi
			putch('x', putdat);
  8005e1:	83 c4 08             	add    $0x8,%esp
  8005e4:	53                   	push   %ebx
  8005e5:	6a 78                	push   $0x78
  8005e7:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	8d 50 04             	lea    0x4(%eax),%edx
  8005ef:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005f2:	8b 00                	mov    (%eax),%eax
  8005f4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005f9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005fc:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800601:	eb 0d                	jmp    800610 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800603:	8d 45 14             	lea    0x14(%ebp),%eax
  800606:	e8 3b fc ff ff       	call   800246 <getuint>
			base = 16;
  80060b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800610:	83 ec 0c             	sub    $0xc,%esp
  800613:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800617:	57                   	push   %edi
  800618:	ff 75 e0             	pushl  -0x20(%ebp)
  80061b:	51                   	push   %ecx
  80061c:	52                   	push   %edx
  80061d:	50                   	push   %eax
  80061e:	89 da                	mov    %ebx,%edx
  800620:	89 f0                	mov    %esi,%eax
  800622:	e8 70 fb ff ff       	call   800197 <printnum>
			break;
  800627:	83 c4 20             	add    $0x20,%esp
  80062a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80062d:	e9 ae fc ff ff       	jmp    8002e0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800632:	83 ec 08             	sub    $0x8,%esp
  800635:	53                   	push   %ebx
  800636:	51                   	push   %ecx
  800637:	ff d6                	call   *%esi
			break;
  800639:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80063f:	e9 9c fc ff ff       	jmp    8002e0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800644:	83 ec 08             	sub    $0x8,%esp
  800647:	53                   	push   %ebx
  800648:	6a 25                	push   $0x25
  80064a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80064c:	83 c4 10             	add    $0x10,%esp
  80064f:	eb 03                	jmp    800654 <vprintfmt+0x39a>
  800651:	83 ef 01             	sub    $0x1,%edi
  800654:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800658:	75 f7                	jne    800651 <vprintfmt+0x397>
  80065a:	e9 81 fc ff ff       	jmp    8002e0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80065f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800662:	5b                   	pop    %ebx
  800663:	5e                   	pop    %esi
  800664:	5f                   	pop    %edi
  800665:	5d                   	pop    %ebp
  800666:	c3                   	ret    

00800667 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800667:	55                   	push   %ebp
  800668:	89 e5                	mov    %esp,%ebp
  80066a:	83 ec 18             	sub    $0x18,%esp
  80066d:	8b 45 08             	mov    0x8(%ebp),%eax
  800670:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800673:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800676:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80067a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80067d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800684:	85 c0                	test   %eax,%eax
  800686:	74 26                	je     8006ae <vsnprintf+0x47>
  800688:	85 d2                	test   %edx,%edx
  80068a:	7e 22                	jle    8006ae <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80068c:	ff 75 14             	pushl  0x14(%ebp)
  80068f:	ff 75 10             	pushl  0x10(%ebp)
  800692:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800695:	50                   	push   %eax
  800696:	68 80 02 80 00       	push   $0x800280
  80069b:	e8 1a fc ff ff       	call   8002ba <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006a3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006a9:	83 c4 10             	add    $0x10,%esp
  8006ac:	eb 05                	jmp    8006b3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006b3:	c9                   	leave  
  8006b4:	c3                   	ret    

008006b5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006b5:	55                   	push   %ebp
  8006b6:	89 e5                	mov    %esp,%ebp
  8006b8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006bb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006be:	50                   	push   %eax
  8006bf:	ff 75 10             	pushl  0x10(%ebp)
  8006c2:	ff 75 0c             	pushl  0xc(%ebp)
  8006c5:	ff 75 08             	pushl  0x8(%ebp)
  8006c8:	e8 9a ff ff ff       	call   800667 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006cd:	c9                   	leave  
  8006ce:	c3                   	ret    

008006cf <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006cf:	55                   	push   %ebp
  8006d0:	89 e5                	mov    %esp,%ebp
  8006d2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8006da:	eb 03                	jmp    8006df <strlen+0x10>
		n++;
  8006dc:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006df:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006e3:	75 f7                	jne    8006dc <strlen+0xd>
		n++;
	return n;
}
  8006e5:	5d                   	pop    %ebp
  8006e6:	c3                   	ret    

008006e7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006e7:	55                   	push   %ebp
  8006e8:	89 e5                	mov    %esp,%ebp
  8006ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006ed:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8006f5:	eb 03                	jmp    8006fa <strnlen+0x13>
		n++;
  8006f7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006fa:	39 c2                	cmp    %eax,%edx
  8006fc:	74 08                	je     800706 <strnlen+0x1f>
  8006fe:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800702:	75 f3                	jne    8006f7 <strnlen+0x10>
  800704:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800706:	5d                   	pop    %ebp
  800707:	c3                   	ret    

00800708 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800708:	55                   	push   %ebp
  800709:	89 e5                	mov    %esp,%ebp
  80070b:	53                   	push   %ebx
  80070c:	8b 45 08             	mov    0x8(%ebp),%eax
  80070f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800712:	89 c2                	mov    %eax,%edx
  800714:	83 c2 01             	add    $0x1,%edx
  800717:	83 c1 01             	add    $0x1,%ecx
  80071a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80071e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800721:	84 db                	test   %bl,%bl
  800723:	75 ef                	jne    800714 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800725:	5b                   	pop    %ebx
  800726:	5d                   	pop    %ebp
  800727:	c3                   	ret    

00800728 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	53                   	push   %ebx
  80072c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80072f:	53                   	push   %ebx
  800730:	e8 9a ff ff ff       	call   8006cf <strlen>
  800735:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800738:	ff 75 0c             	pushl  0xc(%ebp)
  80073b:	01 d8                	add    %ebx,%eax
  80073d:	50                   	push   %eax
  80073e:	e8 c5 ff ff ff       	call   800708 <strcpy>
	return dst;
}
  800743:	89 d8                	mov    %ebx,%eax
  800745:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800748:	c9                   	leave  
  800749:	c3                   	ret    

0080074a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80074a:	55                   	push   %ebp
  80074b:	89 e5                	mov    %esp,%ebp
  80074d:	56                   	push   %esi
  80074e:	53                   	push   %ebx
  80074f:	8b 75 08             	mov    0x8(%ebp),%esi
  800752:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800755:	89 f3                	mov    %esi,%ebx
  800757:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80075a:	89 f2                	mov    %esi,%edx
  80075c:	eb 0f                	jmp    80076d <strncpy+0x23>
		*dst++ = *src;
  80075e:	83 c2 01             	add    $0x1,%edx
  800761:	0f b6 01             	movzbl (%ecx),%eax
  800764:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800767:	80 39 01             	cmpb   $0x1,(%ecx)
  80076a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80076d:	39 da                	cmp    %ebx,%edx
  80076f:	75 ed                	jne    80075e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800771:	89 f0                	mov    %esi,%eax
  800773:	5b                   	pop    %ebx
  800774:	5e                   	pop    %esi
  800775:	5d                   	pop    %ebp
  800776:	c3                   	ret    

00800777 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	56                   	push   %esi
  80077b:	53                   	push   %ebx
  80077c:	8b 75 08             	mov    0x8(%ebp),%esi
  80077f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800782:	8b 55 10             	mov    0x10(%ebp),%edx
  800785:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800787:	85 d2                	test   %edx,%edx
  800789:	74 21                	je     8007ac <strlcpy+0x35>
  80078b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80078f:	89 f2                	mov    %esi,%edx
  800791:	eb 09                	jmp    80079c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800793:	83 c2 01             	add    $0x1,%edx
  800796:	83 c1 01             	add    $0x1,%ecx
  800799:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80079c:	39 c2                	cmp    %eax,%edx
  80079e:	74 09                	je     8007a9 <strlcpy+0x32>
  8007a0:	0f b6 19             	movzbl (%ecx),%ebx
  8007a3:	84 db                	test   %bl,%bl
  8007a5:	75 ec                	jne    800793 <strlcpy+0x1c>
  8007a7:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007a9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007ac:	29 f0                	sub    %esi,%eax
}
  8007ae:	5b                   	pop    %ebx
  8007af:	5e                   	pop    %esi
  8007b0:	5d                   	pop    %ebp
  8007b1:	c3                   	ret    

008007b2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007bb:	eb 06                	jmp    8007c3 <strcmp+0x11>
		p++, q++;
  8007bd:	83 c1 01             	add    $0x1,%ecx
  8007c0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007c3:	0f b6 01             	movzbl (%ecx),%eax
  8007c6:	84 c0                	test   %al,%al
  8007c8:	74 04                	je     8007ce <strcmp+0x1c>
  8007ca:	3a 02                	cmp    (%edx),%al
  8007cc:	74 ef                	je     8007bd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ce:	0f b6 c0             	movzbl %al,%eax
  8007d1:	0f b6 12             	movzbl (%edx),%edx
  8007d4:	29 d0                	sub    %edx,%eax
}
  8007d6:	5d                   	pop    %ebp
  8007d7:	c3                   	ret    

008007d8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	53                   	push   %ebx
  8007dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e2:	89 c3                	mov    %eax,%ebx
  8007e4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007e7:	eb 06                	jmp    8007ef <strncmp+0x17>
		n--, p++, q++;
  8007e9:	83 c0 01             	add    $0x1,%eax
  8007ec:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007ef:	39 d8                	cmp    %ebx,%eax
  8007f1:	74 15                	je     800808 <strncmp+0x30>
  8007f3:	0f b6 08             	movzbl (%eax),%ecx
  8007f6:	84 c9                	test   %cl,%cl
  8007f8:	74 04                	je     8007fe <strncmp+0x26>
  8007fa:	3a 0a                	cmp    (%edx),%cl
  8007fc:	74 eb                	je     8007e9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007fe:	0f b6 00             	movzbl (%eax),%eax
  800801:	0f b6 12             	movzbl (%edx),%edx
  800804:	29 d0                	sub    %edx,%eax
  800806:	eb 05                	jmp    80080d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800808:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80080d:	5b                   	pop    %ebx
  80080e:	5d                   	pop    %ebp
  80080f:	c3                   	ret    

00800810 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80081a:	eb 07                	jmp    800823 <strchr+0x13>
		if (*s == c)
  80081c:	38 ca                	cmp    %cl,%dl
  80081e:	74 0f                	je     80082f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800820:	83 c0 01             	add    $0x1,%eax
  800823:	0f b6 10             	movzbl (%eax),%edx
  800826:	84 d2                	test   %dl,%dl
  800828:	75 f2                	jne    80081c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80082a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80082f:	5d                   	pop    %ebp
  800830:	c3                   	ret    

00800831 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	8b 45 08             	mov    0x8(%ebp),%eax
  800837:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80083b:	eb 03                	jmp    800840 <strfind+0xf>
  80083d:	83 c0 01             	add    $0x1,%eax
  800840:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800843:	38 ca                	cmp    %cl,%dl
  800845:	74 04                	je     80084b <strfind+0x1a>
  800847:	84 d2                	test   %dl,%dl
  800849:	75 f2                	jne    80083d <strfind+0xc>
			break;
	return (char *) s;
}
  80084b:	5d                   	pop    %ebp
  80084c:	c3                   	ret    

0080084d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	57                   	push   %edi
  800851:	56                   	push   %esi
  800852:	53                   	push   %ebx
  800853:	8b 7d 08             	mov    0x8(%ebp),%edi
  800856:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800859:	85 c9                	test   %ecx,%ecx
  80085b:	74 36                	je     800893 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80085d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800863:	75 28                	jne    80088d <memset+0x40>
  800865:	f6 c1 03             	test   $0x3,%cl
  800868:	75 23                	jne    80088d <memset+0x40>
		c &= 0xFF;
  80086a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80086e:	89 d3                	mov    %edx,%ebx
  800870:	c1 e3 08             	shl    $0x8,%ebx
  800873:	89 d6                	mov    %edx,%esi
  800875:	c1 e6 18             	shl    $0x18,%esi
  800878:	89 d0                	mov    %edx,%eax
  80087a:	c1 e0 10             	shl    $0x10,%eax
  80087d:	09 f0                	or     %esi,%eax
  80087f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800881:	89 d8                	mov    %ebx,%eax
  800883:	09 d0                	or     %edx,%eax
  800885:	c1 e9 02             	shr    $0x2,%ecx
  800888:	fc                   	cld    
  800889:	f3 ab                	rep stos %eax,%es:(%edi)
  80088b:	eb 06                	jmp    800893 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80088d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800890:	fc                   	cld    
  800891:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800893:	89 f8                	mov    %edi,%eax
  800895:	5b                   	pop    %ebx
  800896:	5e                   	pop    %esi
  800897:	5f                   	pop    %edi
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	57                   	push   %edi
  80089e:	56                   	push   %esi
  80089f:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008a5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008a8:	39 c6                	cmp    %eax,%esi
  8008aa:	73 35                	jae    8008e1 <memmove+0x47>
  8008ac:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008af:	39 d0                	cmp    %edx,%eax
  8008b1:	73 2e                	jae    8008e1 <memmove+0x47>
		s += n;
		d += n;
  8008b3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008b6:	89 d6                	mov    %edx,%esi
  8008b8:	09 fe                	or     %edi,%esi
  8008ba:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008c0:	75 13                	jne    8008d5 <memmove+0x3b>
  8008c2:	f6 c1 03             	test   $0x3,%cl
  8008c5:	75 0e                	jne    8008d5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008c7:	83 ef 04             	sub    $0x4,%edi
  8008ca:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008cd:	c1 e9 02             	shr    $0x2,%ecx
  8008d0:	fd                   	std    
  8008d1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008d3:	eb 09                	jmp    8008de <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008d5:	83 ef 01             	sub    $0x1,%edi
  8008d8:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008db:	fd                   	std    
  8008dc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008de:	fc                   	cld    
  8008df:	eb 1d                	jmp    8008fe <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e1:	89 f2                	mov    %esi,%edx
  8008e3:	09 c2                	or     %eax,%edx
  8008e5:	f6 c2 03             	test   $0x3,%dl
  8008e8:	75 0f                	jne    8008f9 <memmove+0x5f>
  8008ea:	f6 c1 03             	test   $0x3,%cl
  8008ed:	75 0a                	jne    8008f9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008ef:	c1 e9 02             	shr    $0x2,%ecx
  8008f2:	89 c7                	mov    %eax,%edi
  8008f4:	fc                   	cld    
  8008f5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f7:	eb 05                	jmp    8008fe <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008f9:	89 c7                	mov    %eax,%edi
  8008fb:	fc                   	cld    
  8008fc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008fe:	5e                   	pop    %esi
  8008ff:	5f                   	pop    %edi
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800905:	ff 75 10             	pushl  0x10(%ebp)
  800908:	ff 75 0c             	pushl  0xc(%ebp)
  80090b:	ff 75 08             	pushl  0x8(%ebp)
  80090e:	e8 87 ff ff ff       	call   80089a <memmove>
}
  800913:	c9                   	leave  
  800914:	c3                   	ret    

00800915 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	56                   	push   %esi
  800919:	53                   	push   %ebx
  80091a:	8b 45 08             	mov    0x8(%ebp),%eax
  80091d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800920:	89 c6                	mov    %eax,%esi
  800922:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800925:	eb 1a                	jmp    800941 <memcmp+0x2c>
		if (*s1 != *s2)
  800927:	0f b6 08             	movzbl (%eax),%ecx
  80092a:	0f b6 1a             	movzbl (%edx),%ebx
  80092d:	38 d9                	cmp    %bl,%cl
  80092f:	74 0a                	je     80093b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800931:	0f b6 c1             	movzbl %cl,%eax
  800934:	0f b6 db             	movzbl %bl,%ebx
  800937:	29 d8                	sub    %ebx,%eax
  800939:	eb 0f                	jmp    80094a <memcmp+0x35>
		s1++, s2++;
  80093b:	83 c0 01             	add    $0x1,%eax
  80093e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800941:	39 f0                	cmp    %esi,%eax
  800943:	75 e2                	jne    800927 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800945:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80094a:	5b                   	pop    %ebx
  80094b:	5e                   	pop    %esi
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	53                   	push   %ebx
  800952:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800955:	89 c1                	mov    %eax,%ecx
  800957:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80095a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80095e:	eb 0a                	jmp    80096a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800960:	0f b6 10             	movzbl (%eax),%edx
  800963:	39 da                	cmp    %ebx,%edx
  800965:	74 07                	je     80096e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800967:	83 c0 01             	add    $0x1,%eax
  80096a:	39 c8                	cmp    %ecx,%eax
  80096c:	72 f2                	jb     800960 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80096e:	5b                   	pop    %ebx
  80096f:	5d                   	pop    %ebp
  800970:	c3                   	ret    

00800971 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
  800974:	57                   	push   %edi
  800975:	56                   	push   %esi
  800976:	53                   	push   %ebx
  800977:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80097a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80097d:	eb 03                	jmp    800982 <strtol+0x11>
		s++;
  80097f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800982:	0f b6 01             	movzbl (%ecx),%eax
  800985:	3c 20                	cmp    $0x20,%al
  800987:	74 f6                	je     80097f <strtol+0xe>
  800989:	3c 09                	cmp    $0x9,%al
  80098b:	74 f2                	je     80097f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80098d:	3c 2b                	cmp    $0x2b,%al
  80098f:	75 0a                	jne    80099b <strtol+0x2a>
		s++;
  800991:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800994:	bf 00 00 00 00       	mov    $0x0,%edi
  800999:	eb 11                	jmp    8009ac <strtol+0x3b>
  80099b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009a0:	3c 2d                	cmp    $0x2d,%al
  8009a2:	75 08                	jne    8009ac <strtol+0x3b>
		s++, neg = 1;
  8009a4:	83 c1 01             	add    $0x1,%ecx
  8009a7:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ac:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009b2:	75 15                	jne    8009c9 <strtol+0x58>
  8009b4:	80 39 30             	cmpb   $0x30,(%ecx)
  8009b7:	75 10                	jne    8009c9 <strtol+0x58>
  8009b9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009bd:	75 7c                	jne    800a3b <strtol+0xca>
		s += 2, base = 16;
  8009bf:	83 c1 02             	add    $0x2,%ecx
  8009c2:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009c7:	eb 16                	jmp    8009df <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009c9:	85 db                	test   %ebx,%ebx
  8009cb:	75 12                	jne    8009df <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009cd:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009d2:	80 39 30             	cmpb   $0x30,(%ecx)
  8009d5:	75 08                	jne    8009df <strtol+0x6e>
		s++, base = 8;
  8009d7:	83 c1 01             	add    $0x1,%ecx
  8009da:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009df:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009e7:	0f b6 11             	movzbl (%ecx),%edx
  8009ea:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009ed:	89 f3                	mov    %esi,%ebx
  8009ef:	80 fb 09             	cmp    $0x9,%bl
  8009f2:	77 08                	ja     8009fc <strtol+0x8b>
			dig = *s - '0';
  8009f4:	0f be d2             	movsbl %dl,%edx
  8009f7:	83 ea 30             	sub    $0x30,%edx
  8009fa:	eb 22                	jmp    800a1e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009fc:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009ff:	89 f3                	mov    %esi,%ebx
  800a01:	80 fb 19             	cmp    $0x19,%bl
  800a04:	77 08                	ja     800a0e <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a06:	0f be d2             	movsbl %dl,%edx
  800a09:	83 ea 57             	sub    $0x57,%edx
  800a0c:	eb 10                	jmp    800a1e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a0e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a11:	89 f3                	mov    %esi,%ebx
  800a13:	80 fb 19             	cmp    $0x19,%bl
  800a16:	77 16                	ja     800a2e <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a18:	0f be d2             	movsbl %dl,%edx
  800a1b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a1e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a21:	7d 0b                	jge    800a2e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a23:	83 c1 01             	add    $0x1,%ecx
  800a26:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a2a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a2c:	eb b9                	jmp    8009e7 <strtol+0x76>

	if (endptr)
  800a2e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a32:	74 0d                	je     800a41 <strtol+0xd0>
		*endptr = (char *) s;
  800a34:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a37:	89 0e                	mov    %ecx,(%esi)
  800a39:	eb 06                	jmp    800a41 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a3b:	85 db                	test   %ebx,%ebx
  800a3d:	74 98                	je     8009d7 <strtol+0x66>
  800a3f:	eb 9e                	jmp    8009df <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a41:	89 c2                	mov    %eax,%edx
  800a43:	f7 da                	neg    %edx
  800a45:	85 ff                	test   %edi,%edi
  800a47:	0f 45 c2             	cmovne %edx,%eax
}
  800a4a:	5b                   	pop    %ebx
  800a4b:	5e                   	pop    %esi
  800a4c:	5f                   	pop    %edi
  800a4d:	5d                   	pop    %ebp
  800a4e:	c3                   	ret    

00800a4f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
  800a52:	57                   	push   %edi
  800a53:	56                   	push   %esi
  800a54:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a55:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a60:	89 c3                	mov    %eax,%ebx
  800a62:	89 c7                	mov    %eax,%edi
  800a64:	89 c6                	mov    %eax,%esi
  800a66:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a68:	5b                   	pop    %ebx
  800a69:	5e                   	pop    %esi
  800a6a:	5f                   	pop    %edi
  800a6b:	5d                   	pop    %ebp
  800a6c:	c3                   	ret    

00800a6d <sys_cgetc>:

int
sys_cgetc(void)
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
  800a73:	ba 00 00 00 00       	mov    $0x0,%edx
  800a78:	b8 01 00 00 00       	mov    $0x1,%eax
  800a7d:	89 d1                	mov    %edx,%ecx
  800a7f:	89 d3                	mov    %edx,%ebx
  800a81:	89 d7                	mov    %edx,%edi
  800a83:	89 d6                	mov    %edx,%esi
  800a85:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a87:	5b                   	pop    %ebx
  800a88:	5e                   	pop    %esi
  800a89:	5f                   	pop    %edi
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    

00800a8c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	57                   	push   %edi
  800a90:	56                   	push   %esi
  800a91:	53                   	push   %ebx
  800a92:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a95:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a9a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa2:	89 cb                	mov    %ecx,%ebx
  800aa4:	89 cf                	mov    %ecx,%edi
  800aa6:	89 ce                	mov    %ecx,%esi
  800aa8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800aaa:	85 c0                	test   %eax,%eax
  800aac:	7e 17                	jle    800ac5 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aae:	83 ec 0c             	sub    $0xc,%esp
  800ab1:	50                   	push   %eax
  800ab2:	6a 03                	push   $0x3
  800ab4:	68 5f 27 80 00       	push   $0x80275f
  800ab9:	6a 23                	push   $0x23
  800abb:	68 7c 27 80 00       	push   $0x80277c
  800ac0:	e8 90 14 00 00       	call   801f55 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ac5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ac8:	5b                   	pop    %ebx
  800ac9:	5e                   	pop    %esi
  800aca:	5f                   	pop    %edi
  800acb:	5d                   	pop    %ebp
  800acc:	c3                   	ret    

00800acd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	57                   	push   %edi
  800ad1:	56                   	push   %esi
  800ad2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad8:	b8 02 00 00 00       	mov    $0x2,%eax
  800add:	89 d1                	mov    %edx,%ecx
  800adf:	89 d3                	mov    %edx,%ebx
  800ae1:	89 d7                	mov    %edx,%edi
  800ae3:	89 d6                	mov    %edx,%esi
  800ae5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ae7:	5b                   	pop    %ebx
  800ae8:	5e                   	pop    %esi
  800ae9:	5f                   	pop    %edi
  800aea:	5d                   	pop    %ebp
  800aeb:	c3                   	ret    

00800aec <sys_yield>:

void
sys_yield(void)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	57                   	push   %edi
  800af0:	56                   	push   %esi
  800af1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af2:	ba 00 00 00 00       	mov    $0x0,%edx
  800af7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800afc:	89 d1                	mov    %edx,%ecx
  800afe:	89 d3                	mov    %edx,%ebx
  800b00:	89 d7                	mov    %edx,%edi
  800b02:	89 d6                	mov    %edx,%esi
  800b04:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b06:	5b                   	pop    %ebx
  800b07:	5e                   	pop    %esi
  800b08:	5f                   	pop    %edi
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	57                   	push   %edi
  800b0f:	56                   	push   %esi
  800b10:	53                   	push   %ebx
  800b11:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b14:	be 00 00 00 00       	mov    $0x0,%esi
  800b19:	b8 04 00 00 00       	mov    $0x4,%eax
  800b1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b21:	8b 55 08             	mov    0x8(%ebp),%edx
  800b24:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b27:	89 f7                	mov    %esi,%edi
  800b29:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b2b:	85 c0                	test   %eax,%eax
  800b2d:	7e 17                	jle    800b46 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b2f:	83 ec 0c             	sub    $0xc,%esp
  800b32:	50                   	push   %eax
  800b33:	6a 04                	push   $0x4
  800b35:	68 5f 27 80 00       	push   $0x80275f
  800b3a:	6a 23                	push   $0x23
  800b3c:	68 7c 27 80 00       	push   $0x80277c
  800b41:	e8 0f 14 00 00       	call   801f55 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b49:	5b                   	pop    %ebx
  800b4a:	5e                   	pop    %esi
  800b4b:	5f                   	pop    %edi
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    

00800b4e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	57                   	push   %edi
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
  800b54:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b57:	b8 05 00 00 00       	mov    $0x5,%eax
  800b5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b62:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b65:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b68:	8b 75 18             	mov    0x18(%ebp),%esi
  800b6b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b6d:	85 c0                	test   %eax,%eax
  800b6f:	7e 17                	jle    800b88 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b71:	83 ec 0c             	sub    $0xc,%esp
  800b74:	50                   	push   %eax
  800b75:	6a 05                	push   $0x5
  800b77:	68 5f 27 80 00       	push   $0x80275f
  800b7c:	6a 23                	push   $0x23
  800b7e:	68 7c 27 80 00       	push   $0x80277c
  800b83:	e8 cd 13 00 00       	call   801f55 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8b:	5b                   	pop    %ebx
  800b8c:	5e                   	pop    %esi
  800b8d:	5f                   	pop    %edi
  800b8e:	5d                   	pop    %ebp
  800b8f:	c3                   	ret    

00800b90 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	57                   	push   %edi
  800b94:	56                   	push   %esi
  800b95:	53                   	push   %ebx
  800b96:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b99:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b9e:	b8 06 00 00 00       	mov    $0x6,%eax
  800ba3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba9:	89 df                	mov    %ebx,%edi
  800bab:	89 de                	mov    %ebx,%esi
  800bad:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800baf:	85 c0                	test   %eax,%eax
  800bb1:	7e 17                	jle    800bca <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb3:	83 ec 0c             	sub    $0xc,%esp
  800bb6:	50                   	push   %eax
  800bb7:	6a 06                	push   $0x6
  800bb9:	68 5f 27 80 00       	push   $0x80275f
  800bbe:	6a 23                	push   $0x23
  800bc0:	68 7c 27 80 00       	push   $0x80277c
  800bc5:	e8 8b 13 00 00       	call   801f55 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5f                   	pop    %edi
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    

00800bd2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	57                   	push   %edi
  800bd6:	56                   	push   %esi
  800bd7:	53                   	push   %ebx
  800bd8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800be0:	b8 08 00 00 00       	mov    $0x8,%eax
  800be5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be8:	8b 55 08             	mov    0x8(%ebp),%edx
  800beb:	89 df                	mov    %ebx,%edi
  800bed:	89 de                	mov    %ebx,%esi
  800bef:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf1:	85 c0                	test   %eax,%eax
  800bf3:	7e 17                	jle    800c0c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf5:	83 ec 0c             	sub    $0xc,%esp
  800bf8:	50                   	push   %eax
  800bf9:	6a 08                	push   $0x8
  800bfb:	68 5f 27 80 00       	push   $0x80275f
  800c00:	6a 23                	push   $0x23
  800c02:	68 7c 27 80 00       	push   $0x80277c
  800c07:	e8 49 13 00 00       	call   801f55 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	57                   	push   %edi
  800c18:	56                   	push   %esi
  800c19:	53                   	push   %ebx
  800c1a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c22:	b8 09 00 00 00       	mov    $0x9,%eax
  800c27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2d:	89 df                	mov    %ebx,%edi
  800c2f:	89 de                	mov    %ebx,%esi
  800c31:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c33:	85 c0                	test   %eax,%eax
  800c35:	7e 17                	jle    800c4e <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c37:	83 ec 0c             	sub    $0xc,%esp
  800c3a:	50                   	push   %eax
  800c3b:	6a 09                	push   $0x9
  800c3d:	68 5f 27 80 00       	push   $0x80275f
  800c42:	6a 23                	push   $0x23
  800c44:	68 7c 27 80 00       	push   $0x80277c
  800c49:	e8 07 13 00 00       	call   801f55 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	57                   	push   %edi
  800c5a:	56                   	push   %esi
  800c5b:	53                   	push   %ebx
  800c5c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c64:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6f:	89 df                	mov    %ebx,%edi
  800c71:	89 de                	mov    %ebx,%esi
  800c73:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c75:	85 c0                	test   %eax,%eax
  800c77:	7e 17                	jle    800c90 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c79:	83 ec 0c             	sub    $0xc,%esp
  800c7c:	50                   	push   %eax
  800c7d:	6a 0a                	push   $0xa
  800c7f:	68 5f 27 80 00       	push   $0x80275f
  800c84:	6a 23                	push   $0x23
  800c86:	68 7c 27 80 00       	push   $0x80277c
  800c8b:	e8 c5 12 00 00       	call   801f55 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c93:	5b                   	pop    %ebx
  800c94:	5e                   	pop    %esi
  800c95:	5f                   	pop    %edi
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    

00800c98 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	57                   	push   %edi
  800c9c:	56                   	push   %esi
  800c9d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9e:	be 00 00 00 00       	mov    $0x0,%esi
  800ca3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ca8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cab:	8b 55 08             	mov    0x8(%ebp),%edx
  800cae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cb4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cb6:	5b                   	pop    %ebx
  800cb7:	5e                   	pop    %esi
  800cb8:	5f                   	pop    %edi
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	57                   	push   %edi
  800cbf:	56                   	push   %esi
  800cc0:	53                   	push   %ebx
  800cc1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cc9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cce:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd1:	89 cb                	mov    %ecx,%ebx
  800cd3:	89 cf                	mov    %ecx,%edi
  800cd5:	89 ce                	mov    %ecx,%esi
  800cd7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd9:	85 c0                	test   %eax,%eax
  800cdb:	7e 17                	jle    800cf4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdd:	83 ec 0c             	sub    $0xc,%esp
  800ce0:	50                   	push   %eax
  800ce1:	6a 0d                	push   $0xd
  800ce3:	68 5f 27 80 00       	push   $0x80275f
  800ce8:	6a 23                	push   $0x23
  800cea:	68 7c 27 80 00       	push   $0x80277c
  800cef:	e8 61 12 00 00       	call   801f55 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf7:	5b                   	pop    %ebx
  800cf8:	5e                   	pop    %esi
  800cf9:	5f                   	pop    %edi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    

00800cfc <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	57                   	push   %edi
  800d00:	56                   	push   %esi
  800d01:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d02:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d07:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0f:	89 cb                	mov    %ecx,%ebx
  800d11:	89 cf                	mov    %ecx,%edi
  800d13:	89 ce                	mov    %ecx,%esi
  800d15:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d17:	5b                   	pop    %ebx
  800d18:	5e                   	pop    %esi
  800d19:	5f                   	pop    %edi
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    

00800d1c <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	57                   	push   %edi
  800d20:	56                   	push   %esi
  800d21:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d22:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d27:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2f:	89 cb                	mov    %ecx,%ebx
  800d31:	89 cf                	mov    %ecx,%edi
  800d33:	89 ce                	mov    %ecx,%esi
  800d35:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	57                   	push   %edi
  800d40:	56                   	push   %esi
  800d41:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d42:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d47:	b8 10 00 00 00       	mov    $0x10,%eax
  800d4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4f:	89 cb                	mov    %ecx,%ebx
  800d51:	89 cf                	mov    %ecx,%edi
  800d53:	89 ce                	mov    %ecx,%esi
  800d55:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  800d57:	5b                   	pop    %ebx
  800d58:	5e                   	pop    %esi
  800d59:	5f                   	pop    %edi
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    

00800d5c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	53                   	push   %ebx
  800d60:	83 ec 04             	sub    $0x4,%esp
  800d63:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d66:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800d68:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d6c:	74 11                	je     800d7f <pgfault+0x23>
  800d6e:	89 d8                	mov    %ebx,%eax
  800d70:	c1 e8 0c             	shr    $0xc,%eax
  800d73:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d7a:	f6 c4 08             	test   $0x8,%ah
  800d7d:	75 14                	jne    800d93 <pgfault+0x37>
		panic("faulting access");
  800d7f:	83 ec 04             	sub    $0x4,%esp
  800d82:	68 8a 27 80 00       	push   $0x80278a
  800d87:	6a 1f                	push   $0x1f
  800d89:	68 9a 27 80 00       	push   $0x80279a
  800d8e:	e8 c2 11 00 00       	call   801f55 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800d93:	83 ec 04             	sub    $0x4,%esp
  800d96:	6a 07                	push   $0x7
  800d98:	68 00 f0 7f 00       	push   $0x7ff000
  800d9d:	6a 00                	push   $0x0
  800d9f:	e8 67 fd ff ff       	call   800b0b <sys_page_alloc>
	if (r < 0) {
  800da4:	83 c4 10             	add    $0x10,%esp
  800da7:	85 c0                	test   %eax,%eax
  800da9:	79 12                	jns    800dbd <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800dab:	50                   	push   %eax
  800dac:	68 a5 27 80 00       	push   $0x8027a5
  800db1:	6a 2d                	push   $0x2d
  800db3:	68 9a 27 80 00       	push   $0x80279a
  800db8:	e8 98 11 00 00       	call   801f55 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800dbd:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800dc3:	83 ec 04             	sub    $0x4,%esp
  800dc6:	68 00 10 00 00       	push   $0x1000
  800dcb:	53                   	push   %ebx
  800dcc:	68 00 f0 7f 00       	push   $0x7ff000
  800dd1:	e8 2c fb ff ff       	call   800902 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800dd6:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ddd:	53                   	push   %ebx
  800dde:	6a 00                	push   $0x0
  800de0:	68 00 f0 7f 00       	push   $0x7ff000
  800de5:	6a 00                	push   $0x0
  800de7:	e8 62 fd ff ff       	call   800b4e <sys_page_map>
	if (r < 0) {
  800dec:	83 c4 20             	add    $0x20,%esp
  800def:	85 c0                	test   %eax,%eax
  800df1:	79 12                	jns    800e05 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800df3:	50                   	push   %eax
  800df4:	68 a5 27 80 00       	push   $0x8027a5
  800df9:	6a 34                	push   $0x34
  800dfb:	68 9a 27 80 00       	push   $0x80279a
  800e00:	e8 50 11 00 00       	call   801f55 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e05:	83 ec 08             	sub    $0x8,%esp
  800e08:	68 00 f0 7f 00       	push   $0x7ff000
  800e0d:	6a 00                	push   $0x0
  800e0f:	e8 7c fd ff ff       	call   800b90 <sys_page_unmap>
	if (r < 0) {
  800e14:	83 c4 10             	add    $0x10,%esp
  800e17:	85 c0                	test   %eax,%eax
  800e19:	79 12                	jns    800e2d <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e1b:	50                   	push   %eax
  800e1c:	68 a5 27 80 00       	push   $0x8027a5
  800e21:	6a 38                	push   $0x38
  800e23:	68 9a 27 80 00       	push   $0x80279a
  800e28:	e8 28 11 00 00       	call   801f55 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e2d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e30:	c9                   	leave  
  800e31:	c3                   	ret    

00800e32 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
  800e35:	57                   	push   %edi
  800e36:	56                   	push   %esi
  800e37:	53                   	push   %ebx
  800e38:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e3b:	68 5c 0d 80 00       	push   $0x800d5c
  800e40:	e8 56 11 00 00       	call   801f9b <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e45:	b8 07 00 00 00       	mov    $0x7,%eax
  800e4a:	cd 30                	int    $0x30
  800e4c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800e4f:	83 c4 10             	add    $0x10,%esp
  800e52:	85 c0                	test   %eax,%eax
  800e54:	79 17                	jns    800e6d <fork+0x3b>
		panic("fork fault %e");
  800e56:	83 ec 04             	sub    $0x4,%esp
  800e59:	68 be 27 80 00       	push   $0x8027be
  800e5e:	68 85 00 00 00       	push   $0x85
  800e63:	68 9a 27 80 00       	push   $0x80279a
  800e68:	e8 e8 10 00 00       	call   801f55 <_panic>
  800e6d:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800e6f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e73:	75 24                	jne    800e99 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e75:	e8 53 fc ff ff       	call   800acd <sys_getenvid>
  800e7a:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e7f:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800e85:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e8a:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800e8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e94:	e9 64 01 00 00       	jmp    800ffd <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800e99:	83 ec 04             	sub    $0x4,%esp
  800e9c:	6a 07                	push   $0x7
  800e9e:	68 00 f0 bf ee       	push   $0xeebff000
  800ea3:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ea6:	e8 60 fc ff ff       	call   800b0b <sys_page_alloc>
  800eab:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800eae:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800eb3:	89 d8                	mov    %ebx,%eax
  800eb5:	c1 e8 16             	shr    $0x16,%eax
  800eb8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ebf:	a8 01                	test   $0x1,%al
  800ec1:	0f 84 fc 00 00 00    	je     800fc3 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800ec7:	89 d8                	mov    %ebx,%eax
  800ec9:	c1 e8 0c             	shr    $0xc,%eax
  800ecc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ed3:	f6 c2 01             	test   $0x1,%dl
  800ed6:	0f 84 e7 00 00 00    	je     800fc3 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800edc:	89 c6                	mov    %eax,%esi
  800ede:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800ee1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ee8:	f6 c6 04             	test   $0x4,%dh
  800eeb:	74 39                	je     800f26 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800eed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ef4:	83 ec 0c             	sub    $0xc,%esp
  800ef7:	25 07 0e 00 00       	and    $0xe07,%eax
  800efc:	50                   	push   %eax
  800efd:	56                   	push   %esi
  800efe:	57                   	push   %edi
  800eff:	56                   	push   %esi
  800f00:	6a 00                	push   $0x0
  800f02:	e8 47 fc ff ff       	call   800b4e <sys_page_map>
		if (r < 0) {
  800f07:	83 c4 20             	add    $0x20,%esp
  800f0a:	85 c0                	test   %eax,%eax
  800f0c:	0f 89 b1 00 00 00    	jns    800fc3 <fork+0x191>
		    	panic("sys page map fault %e");
  800f12:	83 ec 04             	sub    $0x4,%esp
  800f15:	68 cc 27 80 00       	push   $0x8027cc
  800f1a:	6a 55                	push   $0x55
  800f1c:	68 9a 27 80 00       	push   $0x80279a
  800f21:	e8 2f 10 00 00       	call   801f55 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f26:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f2d:	f6 c2 02             	test   $0x2,%dl
  800f30:	75 0c                	jne    800f3e <fork+0x10c>
  800f32:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f39:	f6 c4 08             	test   $0x8,%ah
  800f3c:	74 5b                	je     800f99 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f3e:	83 ec 0c             	sub    $0xc,%esp
  800f41:	68 05 08 00 00       	push   $0x805
  800f46:	56                   	push   %esi
  800f47:	57                   	push   %edi
  800f48:	56                   	push   %esi
  800f49:	6a 00                	push   $0x0
  800f4b:	e8 fe fb ff ff       	call   800b4e <sys_page_map>
		if (r < 0) {
  800f50:	83 c4 20             	add    $0x20,%esp
  800f53:	85 c0                	test   %eax,%eax
  800f55:	79 14                	jns    800f6b <fork+0x139>
		    	panic("sys page map fault %e");
  800f57:	83 ec 04             	sub    $0x4,%esp
  800f5a:	68 cc 27 80 00       	push   $0x8027cc
  800f5f:	6a 5c                	push   $0x5c
  800f61:	68 9a 27 80 00       	push   $0x80279a
  800f66:	e8 ea 0f 00 00       	call   801f55 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800f6b:	83 ec 0c             	sub    $0xc,%esp
  800f6e:	68 05 08 00 00       	push   $0x805
  800f73:	56                   	push   %esi
  800f74:	6a 00                	push   $0x0
  800f76:	56                   	push   %esi
  800f77:	6a 00                	push   $0x0
  800f79:	e8 d0 fb ff ff       	call   800b4e <sys_page_map>
		if (r < 0) {
  800f7e:	83 c4 20             	add    $0x20,%esp
  800f81:	85 c0                	test   %eax,%eax
  800f83:	79 3e                	jns    800fc3 <fork+0x191>
		    	panic("sys page map fault %e");
  800f85:	83 ec 04             	sub    $0x4,%esp
  800f88:	68 cc 27 80 00       	push   $0x8027cc
  800f8d:	6a 60                	push   $0x60
  800f8f:	68 9a 27 80 00       	push   $0x80279a
  800f94:	e8 bc 0f 00 00       	call   801f55 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800f99:	83 ec 0c             	sub    $0xc,%esp
  800f9c:	6a 05                	push   $0x5
  800f9e:	56                   	push   %esi
  800f9f:	57                   	push   %edi
  800fa0:	56                   	push   %esi
  800fa1:	6a 00                	push   $0x0
  800fa3:	e8 a6 fb ff ff       	call   800b4e <sys_page_map>
		if (r < 0) {
  800fa8:	83 c4 20             	add    $0x20,%esp
  800fab:	85 c0                	test   %eax,%eax
  800fad:	79 14                	jns    800fc3 <fork+0x191>
		    	panic("sys page map fault %e");
  800faf:	83 ec 04             	sub    $0x4,%esp
  800fb2:	68 cc 27 80 00       	push   $0x8027cc
  800fb7:	6a 65                	push   $0x65
  800fb9:	68 9a 27 80 00       	push   $0x80279a
  800fbe:	e8 92 0f 00 00       	call   801f55 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800fc3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fc9:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800fcf:	0f 85 de fe ff ff    	jne    800eb3 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800fd5:	a1 04 40 80 00       	mov    0x804004,%eax
  800fda:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
  800fe0:	83 ec 08             	sub    $0x8,%esp
  800fe3:	50                   	push   %eax
  800fe4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800fe7:	57                   	push   %edi
  800fe8:	e8 69 fc ff ff       	call   800c56 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  800fed:	83 c4 08             	add    $0x8,%esp
  800ff0:	6a 02                	push   $0x2
  800ff2:	57                   	push   %edi
  800ff3:	e8 da fb ff ff       	call   800bd2 <sys_env_set_status>
	
	return envid;
  800ff8:	83 c4 10             	add    $0x10,%esp
  800ffb:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  800ffd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801000:	5b                   	pop    %ebx
  801001:	5e                   	pop    %esi
  801002:	5f                   	pop    %edi
  801003:	5d                   	pop    %ebp
  801004:	c3                   	ret    

00801005 <sfork>:

envid_t
sfork(void)
{
  801005:	55                   	push   %ebp
  801006:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801008:	b8 00 00 00 00       	mov    $0x0,%eax
  80100d:	5d                   	pop    %ebp
  80100e:	c3                   	ret    

0080100f <thread_create>:

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  80100f:	55                   	push   %ebp
  801010:	89 e5                	mov    %esp,%ebp
  801012:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  801015:	8b 45 08             	mov    0x8(%ebp),%eax
  801018:	a3 08 40 80 00       	mov    %eax,0x804008
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80101d:	68 b6 00 80 00       	push   $0x8000b6
  801022:	e8 d5 fc ff ff       	call   800cfc <sys_thread_create>

	return id;
}
  801027:	c9                   	leave  
  801028:	c3                   	ret    

00801029 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  801029:	55                   	push   %ebp
  80102a:	89 e5                	mov    %esp,%ebp
  80102c:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  80102f:	ff 75 08             	pushl  0x8(%ebp)
  801032:	e8 e5 fc ff ff       	call   800d1c <sys_thread_free>
}
  801037:	83 c4 10             	add    $0x10,%esp
  80103a:	c9                   	leave  
  80103b:	c3                   	ret    

0080103c <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  80103c:	55                   	push   %ebp
  80103d:	89 e5                	mov    %esp,%ebp
  80103f:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  801042:	ff 75 08             	pushl  0x8(%ebp)
  801045:	e8 f2 fc ff ff       	call   800d3c <sys_thread_join>
}
  80104a:	83 c4 10             	add    $0x10,%esp
  80104d:	c9                   	leave  
  80104e:	c3                   	ret    

0080104f <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	56                   	push   %esi
  801053:	53                   	push   %ebx
  801054:	8b 75 08             	mov    0x8(%ebp),%esi
  801057:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  80105a:	83 ec 04             	sub    $0x4,%esp
  80105d:	6a 07                	push   $0x7
  80105f:	6a 00                	push   $0x0
  801061:	56                   	push   %esi
  801062:	e8 a4 fa ff ff       	call   800b0b <sys_page_alloc>
	if (r < 0) {
  801067:	83 c4 10             	add    $0x10,%esp
  80106a:	85 c0                	test   %eax,%eax
  80106c:	79 15                	jns    801083 <queue_append+0x34>
		panic("%e\n", r);
  80106e:	50                   	push   %eax
  80106f:	68 12 28 80 00       	push   $0x802812
  801074:	68 d5 00 00 00       	push   $0xd5
  801079:	68 9a 27 80 00       	push   $0x80279a
  80107e:	e8 d2 0e 00 00       	call   801f55 <_panic>
	}	

	wt->envid = envid;
  801083:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  801089:	83 3b 00             	cmpl   $0x0,(%ebx)
  80108c:	75 13                	jne    8010a1 <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  80108e:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  801095:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80109c:	00 00 00 
  80109f:	eb 1b                	jmp    8010bc <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  8010a1:	8b 43 04             	mov    0x4(%ebx),%eax
  8010a4:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  8010ab:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8010b2:	00 00 00 
		queue->last = wt;
  8010b5:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8010bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010bf:	5b                   	pop    %ebx
  8010c0:	5e                   	pop    %esi
  8010c1:	5d                   	pop    %ebp
  8010c2:	c3                   	ret    

008010c3 <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  8010c3:	55                   	push   %ebp
  8010c4:	89 e5                	mov    %esp,%ebp
  8010c6:	83 ec 08             	sub    $0x8,%esp
  8010c9:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  8010cc:	8b 02                	mov    (%edx),%eax
  8010ce:	85 c0                	test   %eax,%eax
  8010d0:	75 17                	jne    8010e9 <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  8010d2:	83 ec 04             	sub    $0x4,%esp
  8010d5:	68 e2 27 80 00       	push   $0x8027e2
  8010da:	68 ec 00 00 00       	push   $0xec
  8010df:	68 9a 27 80 00       	push   $0x80279a
  8010e4:	e8 6c 0e 00 00       	call   801f55 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  8010e9:	8b 48 04             	mov    0x4(%eax),%ecx
  8010ec:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  8010ee:	8b 00                	mov    (%eax),%eax
}
  8010f0:	c9                   	leave  
  8010f1:	c3                   	ret    

008010f2 <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
  8010f5:	53                   	push   %ebx
  8010f6:	83 ec 04             	sub    $0x4,%esp
  8010f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  8010fc:	b8 01 00 00 00       	mov    $0x1,%eax
  801101:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0)) {
  801104:	85 c0                	test   %eax,%eax
  801106:	74 45                	je     80114d <mutex_lock+0x5b>
		queue_append(sys_getenvid(), &mtx->queue);		
  801108:	e8 c0 f9 ff ff       	call   800acd <sys_getenvid>
  80110d:	83 ec 08             	sub    $0x8,%esp
  801110:	83 c3 04             	add    $0x4,%ebx
  801113:	53                   	push   %ebx
  801114:	50                   	push   %eax
  801115:	e8 35 ff ff ff       	call   80104f <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  80111a:	e8 ae f9 ff ff       	call   800acd <sys_getenvid>
  80111f:	83 c4 08             	add    $0x8,%esp
  801122:	6a 04                	push   $0x4
  801124:	50                   	push   %eax
  801125:	e8 a8 fa ff ff       	call   800bd2 <sys_env_set_status>

		if (r < 0) {
  80112a:	83 c4 10             	add    $0x10,%esp
  80112d:	85 c0                	test   %eax,%eax
  80112f:	79 15                	jns    801146 <mutex_lock+0x54>
			panic("%e\n", r);
  801131:	50                   	push   %eax
  801132:	68 12 28 80 00       	push   $0x802812
  801137:	68 02 01 00 00       	push   $0x102
  80113c:	68 9a 27 80 00       	push   $0x80279a
  801141:	e8 0f 0e 00 00       	call   801f55 <_panic>
		}
		sys_yield();
  801146:	e8 a1 f9 ff ff       	call   800aec <sys_yield>
  80114b:	eb 08                	jmp    801155 <mutex_lock+0x63>
	} else {
		mtx->owner = sys_getenvid();
  80114d:	e8 7b f9 ff ff       	call   800acd <sys_getenvid>
  801152:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801155:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801158:	c9                   	leave  
  801159:	c3                   	ret    

0080115a <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  80115a:	55                   	push   %ebp
  80115b:	89 e5                	mov    %esp,%ebp
  80115d:	53                   	push   %ebx
  80115e:	83 ec 04             	sub    $0x4,%esp
  801161:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	if (mtx->queue.first != NULL) {
  801164:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  801168:	74 36                	je     8011a0 <mutex_unlock+0x46>
		mtx->owner = queue_pop(&mtx->queue);
  80116a:	83 ec 0c             	sub    $0xc,%esp
  80116d:	8d 43 04             	lea    0x4(%ebx),%eax
  801170:	50                   	push   %eax
  801171:	e8 4d ff ff ff       	call   8010c3 <queue_pop>
  801176:	89 43 0c             	mov    %eax,0xc(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  801179:	83 c4 08             	add    $0x8,%esp
  80117c:	6a 02                	push   $0x2
  80117e:	50                   	push   %eax
  80117f:	e8 4e fa ff ff       	call   800bd2 <sys_env_set_status>
		if (r < 0) {
  801184:	83 c4 10             	add    $0x10,%esp
  801187:	85 c0                	test   %eax,%eax
  801189:	79 1d                	jns    8011a8 <mutex_unlock+0x4e>
			panic("%e\n", r);
  80118b:	50                   	push   %eax
  80118c:	68 12 28 80 00       	push   $0x802812
  801191:	68 16 01 00 00       	push   $0x116
  801196:	68 9a 27 80 00       	push   $0x80279a
  80119b:	e8 b5 0d 00 00       	call   801f55 <_panic>
  8011a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a5:	f0 87 03             	lock xchg %eax,(%ebx)
		}
	} else xchg(&mtx->locked, 0);
	
	//asm volatile("pause"); 	// might be useless here
	sys_yield();
  8011a8:	e8 3f f9 ff ff       	call   800aec <sys_yield>
}
  8011ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011b0:	c9                   	leave  
  8011b1:	c3                   	ret    

008011b2 <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  8011b2:	55                   	push   %ebp
  8011b3:	89 e5                	mov    %esp,%ebp
  8011b5:	53                   	push   %ebx
  8011b6:	83 ec 04             	sub    $0x4,%esp
  8011b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  8011bc:	e8 0c f9 ff ff       	call   800acd <sys_getenvid>
  8011c1:	83 ec 04             	sub    $0x4,%esp
  8011c4:	6a 07                	push   $0x7
  8011c6:	53                   	push   %ebx
  8011c7:	50                   	push   %eax
  8011c8:	e8 3e f9 ff ff       	call   800b0b <sys_page_alloc>
  8011cd:	83 c4 10             	add    $0x10,%esp
  8011d0:	85 c0                	test   %eax,%eax
  8011d2:	79 15                	jns    8011e9 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  8011d4:	50                   	push   %eax
  8011d5:	68 fd 27 80 00       	push   $0x8027fd
  8011da:	68 23 01 00 00       	push   $0x123
  8011df:	68 9a 27 80 00       	push   $0x80279a
  8011e4:	e8 6c 0d 00 00       	call   801f55 <_panic>
	}	
	mtx->locked = 0;
  8011e9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue.first = NULL;
  8011ef:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	mtx->queue.last = NULL;
  8011f6:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	mtx->owner = 0;
  8011fd:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
}
  801204:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801207:	c9                   	leave  
  801208:	c3                   	ret    

00801209 <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  801209:	55                   	push   %ebp
  80120a:	89 e5                	mov    %esp,%ebp
  80120c:	56                   	push   %esi
  80120d:	53                   	push   %ebx
  80120e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue.first != NULL) {
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  801211:	8d 73 04             	lea    0x4(%ebx),%esi

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  801214:	eb 20                	jmp    801236 <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  801216:	83 ec 0c             	sub    $0xc,%esp
  801219:	56                   	push   %esi
  80121a:	e8 a4 fe ff ff       	call   8010c3 <queue_pop>
  80121f:	83 c4 08             	add    $0x8,%esp
  801222:	6a 02                	push   $0x2
  801224:	50                   	push   %eax
  801225:	e8 a8 f9 ff ff       	call   800bd2 <sys_env_set_status>
		mtx->queue.first = mtx->queue.first->next;
  80122a:	8b 43 04             	mov    0x4(%ebx),%eax
  80122d:	8b 40 04             	mov    0x4(%eax),%eax
  801230:	89 43 04             	mov    %eax,0x4(%ebx)
  801233:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  801236:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  80123a:	75 da                	jne    801216 <mutex_destroy+0xd>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
		mtx->queue.first = mtx->queue.first->next;
	}

	memset(mtx, 0, PGSIZE);
  80123c:	83 ec 04             	sub    $0x4,%esp
  80123f:	68 00 10 00 00       	push   $0x1000
  801244:	6a 00                	push   $0x0
  801246:	53                   	push   %ebx
  801247:	e8 01 f6 ff ff       	call   80084d <memset>
	mtx = NULL;
}
  80124c:	83 c4 10             	add    $0x10,%esp
  80124f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801252:	5b                   	pop    %ebx
  801253:	5e                   	pop    %esi
  801254:	5d                   	pop    %ebp
  801255:	c3                   	ret    

00801256 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801256:	55                   	push   %ebp
  801257:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801259:	8b 45 08             	mov    0x8(%ebp),%eax
  80125c:	05 00 00 00 30       	add    $0x30000000,%eax
  801261:	c1 e8 0c             	shr    $0xc,%eax
}
  801264:	5d                   	pop    %ebp
  801265:	c3                   	ret    

00801266 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801266:	55                   	push   %ebp
  801267:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801269:	8b 45 08             	mov    0x8(%ebp),%eax
  80126c:	05 00 00 00 30       	add    $0x30000000,%eax
  801271:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801276:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80127b:	5d                   	pop    %ebp
  80127c:	c3                   	ret    

0080127d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80127d:	55                   	push   %ebp
  80127e:	89 e5                	mov    %esp,%ebp
  801280:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801283:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801288:	89 c2                	mov    %eax,%edx
  80128a:	c1 ea 16             	shr    $0x16,%edx
  80128d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801294:	f6 c2 01             	test   $0x1,%dl
  801297:	74 11                	je     8012aa <fd_alloc+0x2d>
  801299:	89 c2                	mov    %eax,%edx
  80129b:	c1 ea 0c             	shr    $0xc,%edx
  80129e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012a5:	f6 c2 01             	test   $0x1,%dl
  8012a8:	75 09                	jne    8012b3 <fd_alloc+0x36>
			*fd_store = fd;
  8012aa:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b1:	eb 17                	jmp    8012ca <fd_alloc+0x4d>
  8012b3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012b8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012bd:	75 c9                	jne    801288 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012bf:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012c5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012ca:	5d                   	pop    %ebp
  8012cb:	c3                   	ret    

008012cc <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012cc:	55                   	push   %ebp
  8012cd:	89 e5                	mov    %esp,%ebp
  8012cf:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012d2:	83 f8 1f             	cmp    $0x1f,%eax
  8012d5:	77 36                	ja     80130d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012d7:	c1 e0 0c             	shl    $0xc,%eax
  8012da:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012df:	89 c2                	mov    %eax,%edx
  8012e1:	c1 ea 16             	shr    $0x16,%edx
  8012e4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012eb:	f6 c2 01             	test   $0x1,%dl
  8012ee:	74 24                	je     801314 <fd_lookup+0x48>
  8012f0:	89 c2                	mov    %eax,%edx
  8012f2:	c1 ea 0c             	shr    $0xc,%edx
  8012f5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012fc:	f6 c2 01             	test   $0x1,%dl
  8012ff:	74 1a                	je     80131b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801301:	8b 55 0c             	mov    0xc(%ebp),%edx
  801304:	89 02                	mov    %eax,(%edx)
	return 0;
  801306:	b8 00 00 00 00       	mov    $0x0,%eax
  80130b:	eb 13                	jmp    801320 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80130d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801312:	eb 0c                	jmp    801320 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801314:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801319:	eb 05                	jmp    801320 <fd_lookup+0x54>
  80131b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801320:	5d                   	pop    %ebp
  801321:	c3                   	ret    

00801322 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801322:	55                   	push   %ebp
  801323:	89 e5                	mov    %esp,%ebp
  801325:	83 ec 08             	sub    $0x8,%esp
  801328:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80132b:	ba 94 28 80 00       	mov    $0x802894,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801330:	eb 13                	jmp    801345 <dev_lookup+0x23>
  801332:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801335:	39 08                	cmp    %ecx,(%eax)
  801337:	75 0c                	jne    801345 <dev_lookup+0x23>
			*dev = devtab[i];
  801339:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80133c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80133e:	b8 00 00 00 00       	mov    $0x0,%eax
  801343:	eb 31                	jmp    801376 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801345:	8b 02                	mov    (%edx),%eax
  801347:	85 c0                	test   %eax,%eax
  801349:	75 e7                	jne    801332 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80134b:	a1 04 40 80 00       	mov    0x804004,%eax
  801350:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801356:	83 ec 04             	sub    $0x4,%esp
  801359:	51                   	push   %ecx
  80135a:	50                   	push   %eax
  80135b:	68 18 28 80 00       	push   $0x802818
  801360:	e8 1e ee ff ff       	call   800183 <cprintf>
	*dev = 0;
  801365:	8b 45 0c             	mov    0xc(%ebp),%eax
  801368:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80136e:	83 c4 10             	add    $0x10,%esp
  801371:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801376:	c9                   	leave  
  801377:	c3                   	ret    

00801378 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801378:	55                   	push   %ebp
  801379:	89 e5                	mov    %esp,%ebp
  80137b:	56                   	push   %esi
  80137c:	53                   	push   %ebx
  80137d:	83 ec 10             	sub    $0x10,%esp
  801380:	8b 75 08             	mov    0x8(%ebp),%esi
  801383:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801386:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801389:	50                   	push   %eax
  80138a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801390:	c1 e8 0c             	shr    $0xc,%eax
  801393:	50                   	push   %eax
  801394:	e8 33 ff ff ff       	call   8012cc <fd_lookup>
  801399:	83 c4 08             	add    $0x8,%esp
  80139c:	85 c0                	test   %eax,%eax
  80139e:	78 05                	js     8013a5 <fd_close+0x2d>
	    || fd != fd2)
  8013a0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013a3:	74 0c                	je     8013b1 <fd_close+0x39>
		return (must_exist ? r : 0);
  8013a5:	84 db                	test   %bl,%bl
  8013a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ac:	0f 44 c2             	cmove  %edx,%eax
  8013af:	eb 41                	jmp    8013f2 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013b1:	83 ec 08             	sub    $0x8,%esp
  8013b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b7:	50                   	push   %eax
  8013b8:	ff 36                	pushl  (%esi)
  8013ba:	e8 63 ff ff ff       	call   801322 <dev_lookup>
  8013bf:	89 c3                	mov    %eax,%ebx
  8013c1:	83 c4 10             	add    $0x10,%esp
  8013c4:	85 c0                	test   %eax,%eax
  8013c6:	78 1a                	js     8013e2 <fd_close+0x6a>
		if (dev->dev_close)
  8013c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013cb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013ce:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013d3:	85 c0                	test   %eax,%eax
  8013d5:	74 0b                	je     8013e2 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013d7:	83 ec 0c             	sub    $0xc,%esp
  8013da:	56                   	push   %esi
  8013db:	ff d0                	call   *%eax
  8013dd:	89 c3                	mov    %eax,%ebx
  8013df:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013e2:	83 ec 08             	sub    $0x8,%esp
  8013e5:	56                   	push   %esi
  8013e6:	6a 00                	push   $0x0
  8013e8:	e8 a3 f7 ff ff       	call   800b90 <sys_page_unmap>
	return r;
  8013ed:	83 c4 10             	add    $0x10,%esp
  8013f0:	89 d8                	mov    %ebx,%eax
}
  8013f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f5:	5b                   	pop    %ebx
  8013f6:	5e                   	pop    %esi
  8013f7:	5d                   	pop    %ebp
  8013f8:	c3                   	ret    

008013f9 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013f9:	55                   	push   %ebp
  8013fa:	89 e5                	mov    %esp,%ebp
  8013fc:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801402:	50                   	push   %eax
  801403:	ff 75 08             	pushl  0x8(%ebp)
  801406:	e8 c1 fe ff ff       	call   8012cc <fd_lookup>
  80140b:	83 c4 08             	add    $0x8,%esp
  80140e:	85 c0                	test   %eax,%eax
  801410:	78 10                	js     801422 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801412:	83 ec 08             	sub    $0x8,%esp
  801415:	6a 01                	push   $0x1
  801417:	ff 75 f4             	pushl  -0xc(%ebp)
  80141a:	e8 59 ff ff ff       	call   801378 <fd_close>
  80141f:	83 c4 10             	add    $0x10,%esp
}
  801422:	c9                   	leave  
  801423:	c3                   	ret    

00801424 <close_all>:

void
close_all(void)
{
  801424:	55                   	push   %ebp
  801425:	89 e5                	mov    %esp,%ebp
  801427:	53                   	push   %ebx
  801428:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80142b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801430:	83 ec 0c             	sub    $0xc,%esp
  801433:	53                   	push   %ebx
  801434:	e8 c0 ff ff ff       	call   8013f9 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801439:	83 c3 01             	add    $0x1,%ebx
  80143c:	83 c4 10             	add    $0x10,%esp
  80143f:	83 fb 20             	cmp    $0x20,%ebx
  801442:	75 ec                	jne    801430 <close_all+0xc>
		close(i);
}
  801444:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801447:	c9                   	leave  
  801448:	c3                   	ret    

00801449 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801449:	55                   	push   %ebp
  80144a:	89 e5                	mov    %esp,%ebp
  80144c:	57                   	push   %edi
  80144d:	56                   	push   %esi
  80144e:	53                   	push   %ebx
  80144f:	83 ec 2c             	sub    $0x2c,%esp
  801452:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801455:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801458:	50                   	push   %eax
  801459:	ff 75 08             	pushl  0x8(%ebp)
  80145c:	e8 6b fe ff ff       	call   8012cc <fd_lookup>
  801461:	83 c4 08             	add    $0x8,%esp
  801464:	85 c0                	test   %eax,%eax
  801466:	0f 88 c1 00 00 00    	js     80152d <dup+0xe4>
		return r;
	close(newfdnum);
  80146c:	83 ec 0c             	sub    $0xc,%esp
  80146f:	56                   	push   %esi
  801470:	e8 84 ff ff ff       	call   8013f9 <close>

	newfd = INDEX2FD(newfdnum);
  801475:	89 f3                	mov    %esi,%ebx
  801477:	c1 e3 0c             	shl    $0xc,%ebx
  80147a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801480:	83 c4 04             	add    $0x4,%esp
  801483:	ff 75 e4             	pushl  -0x1c(%ebp)
  801486:	e8 db fd ff ff       	call   801266 <fd2data>
  80148b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80148d:	89 1c 24             	mov    %ebx,(%esp)
  801490:	e8 d1 fd ff ff       	call   801266 <fd2data>
  801495:	83 c4 10             	add    $0x10,%esp
  801498:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80149b:	89 f8                	mov    %edi,%eax
  80149d:	c1 e8 16             	shr    $0x16,%eax
  8014a0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014a7:	a8 01                	test   $0x1,%al
  8014a9:	74 37                	je     8014e2 <dup+0x99>
  8014ab:	89 f8                	mov    %edi,%eax
  8014ad:	c1 e8 0c             	shr    $0xc,%eax
  8014b0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014b7:	f6 c2 01             	test   $0x1,%dl
  8014ba:	74 26                	je     8014e2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014bc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014c3:	83 ec 0c             	sub    $0xc,%esp
  8014c6:	25 07 0e 00 00       	and    $0xe07,%eax
  8014cb:	50                   	push   %eax
  8014cc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014cf:	6a 00                	push   $0x0
  8014d1:	57                   	push   %edi
  8014d2:	6a 00                	push   $0x0
  8014d4:	e8 75 f6 ff ff       	call   800b4e <sys_page_map>
  8014d9:	89 c7                	mov    %eax,%edi
  8014db:	83 c4 20             	add    $0x20,%esp
  8014de:	85 c0                	test   %eax,%eax
  8014e0:	78 2e                	js     801510 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014e2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014e5:	89 d0                	mov    %edx,%eax
  8014e7:	c1 e8 0c             	shr    $0xc,%eax
  8014ea:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014f1:	83 ec 0c             	sub    $0xc,%esp
  8014f4:	25 07 0e 00 00       	and    $0xe07,%eax
  8014f9:	50                   	push   %eax
  8014fa:	53                   	push   %ebx
  8014fb:	6a 00                	push   $0x0
  8014fd:	52                   	push   %edx
  8014fe:	6a 00                	push   $0x0
  801500:	e8 49 f6 ff ff       	call   800b4e <sys_page_map>
  801505:	89 c7                	mov    %eax,%edi
  801507:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80150a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80150c:	85 ff                	test   %edi,%edi
  80150e:	79 1d                	jns    80152d <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801510:	83 ec 08             	sub    $0x8,%esp
  801513:	53                   	push   %ebx
  801514:	6a 00                	push   $0x0
  801516:	e8 75 f6 ff ff       	call   800b90 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80151b:	83 c4 08             	add    $0x8,%esp
  80151e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801521:	6a 00                	push   $0x0
  801523:	e8 68 f6 ff ff       	call   800b90 <sys_page_unmap>
	return r;
  801528:	83 c4 10             	add    $0x10,%esp
  80152b:	89 f8                	mov    %edi,%eax
}
  80152d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801530:	5b                   	pop    %ebx
  801531:	5e                   	pop    %esi
  801532:	5f                   	pop    %edi
  801533:	5d                   	pop    %ebp
  801534:	c3                   	ret    

00801535 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801535:	55                   	push   %ebp
  801536:	89 e5                	mov    %esp,%ebp
  801538:	53                   	push   %ebx
  801539:	83 ec 14             	sub    $0x14,%esp
  80153c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80153f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801542:	50                   	push   %eax
  801543:	53                   	push   %ebx
  801544:	e8 83 fd ff ff       	call   8012cc <fd_lookup>
  801549:	83 c4 08             	add    $0x8,%esp
  80154c:	89 c2                	mov    %eax,%edx
  80154e:	85 c0                	test   %eax,%eax
  801550:	78 70                	js     8015c2 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801552:	83 ec 08             	sub    $0x8,%esp
  801555:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801558:	50                   	push   %eax
  801559:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155c:	ff 30                	pushl  (%eax)
  80155e:	e8 bf fd ff ff       	call   801322 <dev_lookup>
  801563:	83 c4 10             	add    $0x10,%esp
  801566:	85 c0                	test   %eax,%eax
  801568:	78 4f                	js     8015b9 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80156a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80156d:	8b 42 08             	mov    0x8(%edx),%eax
  801570:	83 e0 03             	and    $0x3,%eax
  801573:	83 f8 01             	cmp    $0x1,%eax
  801576:	75 24                	jne    80159c <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801578:	a1 04 40 80 00       	mov    0x804004,%eax
  80157d:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801583:	83 ec 04             	sub    $0x4,%esp
  801586:	53                   	push   %ebx
  801587:	50                   	push   %eax
  801588:	68 59 28 80 00       	push   $0x802859
  80158d:	e8 f1 eb ff ff       	call   800183 <cprintf>
		return -E_INVAL;
  801592:	83 c4 10             	add    $0x10,%esp
  801595:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80159a:	eb 26                	jmp    8015c2 <read+0x8d>
	}
	if (!dev->dev_read)
  80159c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80159f:	8b 40 08             	mov    0x8(%eax),%eax
  8015a2:	85 c0                	test   %eax,%eax
  8015a4:	74 17                	je     8015bd <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8015a6:	83 ec 04             	sub    $0x4,%esp
  8015a9:	ff 75 10             	pushl  0x10(%ebp)
  8015ac:	ff 75 0c             	pushl  0xc(%ebp)
  8015af:	52                   	push   %edx
  8015b0:	ff d0                	call   *%eax
  8015b2:	89 c2                	mov    %eax,%edx
  8015b4:	83 c4 10             	add    $0x10,%esp
  8015b7:	eb 09                	jmp    8015c2 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b9:	89 c2                	mov    %eax,%edx
  8015bb:	eb 05                	jmp    8015c2 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015bd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8015c2:	89 d0                	mov    %edx,%eax
  8015c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c7:	c9                   	leave  
  8015c8:	c3                   	ret    

008015c9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015c9:	55                   	push   %ebp
  8015ca:	89 e5                	mov    %esp,%ebp
  8015cc:	57                   	push   %edi
  8015cd:	56                   	push   %esi
  8015ce:	53                   	push   %ebx
  8015cf:	83 ec 0c             	sub    $0xc,%esp
  8015d2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015d5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015dd:	eb 21                	jmp    801600 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015df:	83 ec 04             	sub    $0x4,%esp
  8015e2:	89 f0                	mov    %esi,%eax
  8015e4:	29 d8                	sub    %ebx,%eax
  8015e6:	50                   	push   %eax
  8015e7:	89 d8                	mov    %ebx,%eax
  8015e9:	03 45 0c             	add    0xc(%ebp),%eax
  8015ec:	50                   	push   %eax
  8015ed:	57                   	push   %edi
  8015ee:	e8 42 ff ff ff       	call   801535 <read>
		if (m < 0)
  8015f3:	83 c4 10             	add    $0x10,%esp
  8015f6:	85 c0                	test   %eax,%eax
  8015f8:	78 10                	js     80160a <readn+0x41>
			return m;
		if (m == 0)
  8015fa:	85 c0                	test   %eax,%eax
  8015fc:	74 0a                	je     801608 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015fe:	01 c3                	add    %eax,%ebx
  801600:	39 f3                	cmp    %esi,%ebx
  801602:	72 db                	jb     8015df <readn+0x16>
  801604:	89 d8                	mov    %ebx,%eax
  801606:	eb 02                	jmp    80160a <readn+0x41>
  801608:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80160a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80160d:	5b                   	pop    %ebx
  80160e:	5e                   	pop    %esi
  80160f:	5f                   	pop    %edi
  801610:	5d                   	pop    %ebp
  801611:	c3                   	ret    

00801612 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801612:	55                   	push   %ebp
  801613:	89 e5                	mov    %esp,%ebp
  801615:	53                   	push   %ebx
  801616:	83 ec 14             	sub    $0x14,%esp
  801619:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80161c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80161f:	50                   	push   %eax
  801620:	53                   	push   %ebx
  801621:	e8 a6 fc ff ff       	call   8012cc <fd_lookup>
  801626:	83 c4 08             	add    $0x8,%esp
  801629:	89 c2                	mov    %eax,%edx
  80162b:	85 c0                	test   %eax,%eax
  80162d:	78 6b                	js     80169a <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162f:	83 ec 08             	sub    $0x8,%esp
  801632:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801635:	50                   	push   %eax
  801636:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801639:	ff 30                	pushl  (%eax)
  80163b:	e8 e2 fc ff ff       	call   801322 <dev_lookup>
  801640:	83 c4 10             	add    $0x10,%esp
  801643:	85 c0                	test   %eax,%eax
  801645:	78 4a                	js     801691 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801647:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80164e:	75 24                	jne    801674 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801650:	a1 04 40 80 00       	mov    0x804004,%eax
  801655:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80165b:	83 ec 04             	sub    $0x4,%esp
  80165e:	53                   	push   %ebx
  80165f:	50                   	push   %eax
  801660:	68 75 28 80 00       	push   $0x802875
  801665:	e8 19 eb ff ff       	call   800183 <cprintf>
		return -E_INVAL;
  80166a:	83 c4 10             	add    $0x10,%esp
  80166d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801672:	eb 26                	jmp    80169a <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801674:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801677:	8b 52 0c             	mov    0xc(%edx),%edx
  80167a:	85 d2                	test   %edx,%edx
  80167c:	74 17                	je     801695 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80167e:	83 ec 04             	sub    $0x4,%esp
  801681:	ff 75 10             	pushl  0x10(%ebp)
  801684:	ff 75 0c             	pushl  0xc(%ebp)
  801687:	50                   	push   %eax
  801688:	ff d2                	call   *%edx
  80168a:	89 c2                	mov    %eax,%edx
  80168c:	83 c4 10             	add    $0x10,%esp
  80168f:	eb 09                	jmp    80169a <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801691:	89 c2                	mov    %eax,%edx
  801693:	eb 05                	jmp    80169a <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801695:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80169a:	89 d0                	mov    %edx,%eax
  80169c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80169f:	c9                   	leave  
  8016a0:	c3                   	ret    

008016a1 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016a7:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016aa:	50                   	push   %eax
  8016ab:	ff 75 08             	pushl  0x8(%ebp)
  8016ae:	e8 19 fc ff ff       	call   8012cc <fd_lookup>
  8016b3:	83 c4 08             	add    $0x8,%esp
  8016b6:	85 c0                	test   %eax,%eax
  8016b8:	78 0e                	js     8016c8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016c0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016c8:	c9                   	leave  
  8016c9:	c3                   	ret    

008016ca <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
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
  8016d9:	e8 ee fb ff ff       	call   8012cc <fd_lookup>
  8016de:	83 c4 08             	add    $0x8,%esp
  8016e1:	89 c2                	mov    %eax,%edx
  8016e3:	85 c0                	test   %eax,%eax
  8016e5:	78 68                	js     80174f <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e7:	83 ec 08             	sub    $0x8,%esp
  8016ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ed:	50                   	push   %eax
  8016ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f1:	ff 30                	pushl  (%eax)
  8016f3:	e8 2a fc ff ff       	call   801322 <dev_lookup>
  8016f8:	83 c4 10             	add    $0x10,%esp
  8016fb:	85 c0                	test   %eax,%eax
  8016fd:	78 47                	js     801746 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801702:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801706:	75 24                	jne    80172c <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801708:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80170d:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801713:	83 ec 04             	sub    $0x4,%esp
  801716:	53                   	push   %ebx
  801717:	50                   	push   %eax
  801718:	68 38 28 80 00       	push   $0x802838
  80171d:	e8 61 ea ff ff       	call   800183 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801722:	83 c4 10             	add    $0x10,%esp
  801725:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80172a:	eb 23                	jmp    80174f <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  80172c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80172f:	8b 52 18             	mov    0x18(%edx),%edx
  801732:	85 d2                	test   %edx,%edx
  801734:	74 14                	je     80174a <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801736:	83 ec 08             	sub    $0x8,%esp
  801739:	ff 75 0c             	pushl  0xc(%ebp)
  80173c:	50                   	push   %eax
  80173d:	ff d2                	call   *%edx
  80173f:	89 c2                	mov    %eax,%edx
  801741:	83 c4 10             	add    $0x10,%esp
  801744:	eb 09                	jmp    80174f <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801746:	89 c2                	mov    %eax,%edx
  801748:	eb 05                	jmp    80174f <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80174a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80174f:	89 d0                	mov    %edx,%eax
  801751:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801754:	c9                   	leave  
  801755:	c3                   	ret    

00801756 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801756:	55                   	push   %ebp
  801757:	89 e5                	mov    %esp,%ebp
  801759:	53                   	push   %ebx
  80175a:	83 ec 14             	sub    $0x14,%esp
  80175d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801760:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801763:	50                   	push   %eax
  801764:	ff 75 08             	pushl  0x8(%ebp)
  801767:	e8 60 fb ff ff       	call   8012cc <fd_lookup>
  80176c:	83 c4 08             	add    $0x8,%esp
  80176f:	89 c2                	mov    %eax,%edx
  801771:	85 c0                	test   %eax,%eax
  801773:	78 58                	js     8017cd <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801775:	83 ec 08             	sub    $0x8,%esp
  801778:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80177b:	50                   	push   %eax
  80177c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80177f:	ff 30                	pushl  (%eax)
  801781:	e8 9c fb ff ff       	call   801322 <dev_lookup>
  801786:	83 c4 10             	add    $0x10,%esp
  801789:	85 c0                	test   %eax,%eax
  80178b:	78 37                	js     8017c4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80178d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801790:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801794:	74 32                	je     8017c8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801796:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801799:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017a0:	00 00 00 
	stat->st_isdir = 0;
  8017a3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017aa:	00 00 00 
	stat->st_dev = dev;
  8017ad:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017b3:	83 ec 08             	sub    $0x8,%esp
  8017b6:	53                   	push   %ebx
  8017b7:	ff 75 f0             	pushl  -0x10(%ebp)
  8017ba:	ff 50 14             	call   *0x14(%eax)
  8017bd:	89 c2                	mov    %eax,%edx
  8017bf:	83 c4 10             	add    $0x10,%esp
  8017c2:	eb 09                	jmp    8017cd <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c4:	89 c2                	mov    %eax,%edx
  8017c6:	eb 05                	jmp    8017cd <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017c8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017cd:	89 d0                	mov    %edx,%eax
  8017cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d2:	c9                   	leave  
  8017d3:	c3                   	ret    

008017d4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017d4:	55                   	push   %ebp
  8017d5:	89 e5                	mov    %esp,%ebp
  8017d7:	56                   	push   %esi
  8017d8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017d9:	83 ec 08             	sub    $0x8,%esp
  8017dc:	6a 00                	push   $0x0
  8017de:	ff 75 08             	pushl  0x8(%ebp)
  8017e1:	e8 e3 01 00 00       	call   8019c9 <open>
  8017e6:	89 c3                	mov    %eax,%ebx
  8017e8:	83 c4 10             	add    $0x10,%esp
  8017eb:	85 c0                	test   %eax,%eax
  8017ed:	78 1b                	js     80180a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017ef:	83 ec 08             	sub    $0x8,%esp
  8017f2:	ff 75 0c             	pushl  0xc(%ebp)
  8017f5:	50                   	push   %eax
  8017f6:	e8 5b ff ff ff       	call   801756 <fstat>
  8017fb:	89 c6                	mov    %eax,%esi
	close(fd);
  8017fd:	89 1c 24             	mov    %ebx,(%esp)
  801800:	e8 f4 fb ff ff       	call   8013f9 <close>
	return r;
  801805:	83 c4 10             	add    $0x10,%esp
  801808:	89 f0                	mov    %esi,%eax
}
  80180a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80180d:	5b                   	pop    %ebx
  80180e:	5e                   	pop    %esi
  80180f:	5d                   	pop    %ebp
  801810:	c3                   	ret    

00801811 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801811:	55                   	push   %ebp
  801812:	89 e5                	mov    %esp,%ebp
  801814:	56                   	push   %esi
  801815:	53                   	push   %ebx
  801816:	89 c6                	mov    %eax,%esi
  801818:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80181a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801821:	75 12                	jne    801835 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801823:	83 ec 0c             	sub    $0xc,%esp
  801826:	6a 01                	push   $0x1
  801828:	e8 da 08 00 00       	call   802107 <ipc_find_env>
  80182d:	a3 00 40 80 00       	mov    %eax,0x804000
  801832:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801835:	6a 07                	push   $0x7
  801837:	68 00 50 80 00       	push   $0x805000
  80183c:	56                   	push   %esi
  80183d:	ff 35 00 40 80 00    	pushl  0x804000
  801843:	e8 5d 08 00 00       	call   8020a5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801848:	83 c4 0c             	add    $0xc,%esp
  80184b:	6a 00                	push   $0x0
  80184d:	53                   	push   %ebx
  80184e:	6a 00                	push   $0x0
  801850:	e8 d5 07 00 00       	call   80202a <ipc_recv>
}
  801855:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801858:	5b                   	pop    %ebx
  801859:	5e                   	pop    %esi
  80185a:	5d                   	pop    %ebp
  80185b:	c3                   	ret    

0080185c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80185c:	55                   	push   %ebp
  80185d:	89 e5                	mov    %esp,%ebp
  80185f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801862:	8b 45 08             	mov    0x8(%ebp),%eax
  801865:	8b 40 0c             	mov    0xc(%eax),%eax
  801868:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80186d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801870:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801875:	ba 00 00 00 00       	mov    $0x0,%edx
  80187a:	b8 02 00 00 00       	mov    $0x2,%eax
  80187f:	e8 8d ff ff ff       	call   801811 <fsipc>
}
  801884:	c9                   	leave  
  801885:	c3                   	ret    

00801886 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801886:	55                   	push   %ebp
  801887:	89 e5                	mov    %esp,%ebp
  801889:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80188c:	8b 45 08             	mov    0x8(%ebp),%eax
  80188f:	8b 40 0c             	mov    0xc(%eax),%eax
  801892:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801897:	ba 00 00 00 00       	mov    $0x0,%edx
  80189c:	b8 06 00 00 00       	mov    $0x6,%eax
  8018a1:	e8 6b ff ff ff       	call   801811 <fsipc>
}
  8018a6:	c9                   	leave  
  8018a7:	c3                   	ret    

008018a8 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018a8:	55                   	push   %ebp
  8018a9:	89 e5                	mov    %esp,%ebp
  8018ab:	53                   	push   %ebx
  8018ac:	83 ec 04             	sub    $0x4,%esp
  8018af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c2:	b8 05 00 00 00       	mov    $0x5,%eax
  8018c7:	e8 45 ff ff ff       	call   801811 <fsipc>
  8018cc:	85 c0                	test   %eax,%eax
  8018ce:	78 2c                	js     8018fc <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018d0:	83 ec 08             	sub    $0x8,%esp
  8018d3:	68 00 50 80 00       	push   $0x805000
  8018d8:	53                   	push   %ebx
  8018d9:	e8 2a ee ff ff       	call   800708 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018de:	a1 80 50 80 00       	mov    0x805080,%eax
  8018e3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018e9:	a1 84 50 80 00       	mov    0x805084,%eax
  8018ee:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018f4:	83 c4 10             	add    $0x10,%esp
  8018f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ff:	c9                   	leave  
  801900:	c3                   	ret    

00801901 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801901:	55                   	push   %ebp
  801902:	89 e5                	mov    %esp,%ebp
  801904:	83 ec 0c             	sub    $0xc,%esp
  801907:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80190a:	8b 55 08             	mov    0x8(%ebp),%edx
  80190d:	8b 52 0c             	mov    0xc(%edx),%edx
  801910:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801916:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80191b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801920:	0f 47 c2             	cmova  %edx,%eax
  801923:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801928:	50                   	push   %eax
  801929:	ff 75 0c             	pushl  0xc(%ebp)
  80192c:	68 08 50 80 00       	push   $0x805008
  801931:	e8 64 ef ff ff       	call   80089a <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801936:	ba 00 00 00 00       	mov    $0x0,%edx
  80193b:	b8 04 00 00 00       	mov    $0x4,%eax
  801940:	e8 cc fe ff ff       	call   801811 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801945:	c9                   	leave  
  801946:	c3                   	ret    

00801947 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801947:	55                   	push   %ebp
  801948:	89 e5                	mov    %esp,%ebp
  80194a:	56                   	push   %esi
  80194b:	53                   	push   %ebx
  80194c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80194f:	8b 45 08             	mov    0x8(%ebp),%eax
  801952:	8b 40 0c             	mov    0xc(%eax),%eax
  801955:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80195a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801960:	ba 00 00 00 00       	mov    $0x0,%edx
  801965:	b8 03 00 00 00       	mov    $0x3,%eax
  80196a:	e8 a2 fe ff ff       	call   801811 <fsipc>
  80196f:	89 c3                	mov    %eax,%ebx
  801971:	85 c0                	test   %eax,%eax
  801973:	78 4b                	js     8019c0 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801975:	39 c6                	cmp    %eax,%esi
  801977:	73 16                	jae    80198f <devfile_read+0x48>
  801979:	68 a4 28 80 00       	push   $0x8028a4
  80197e:	68 ab 28 80 00       	push   $0x8028ab
  801983:	6a 7c                	push   $0x7c
  801985:	68 c0 28 80 00       	push   $0x8028c0
  80198a:	e8 c6 05 00 00       	call   801f55 <_panic>
	assert(r <= PGSIZE);
  80198f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801994:	7e 16                	jle    8019ac <devfile_read+0x65>
  801996:	68 cb 28 80 00       	push   $0x8028cb
  80199b:	68 ab 28 80 00       	push   $0x8028ab
  8019a0:	6a 7d                	push   $0x7d
  8019a2:	68 c0 28 80 00       	push   $0x8028c0
  8019a7:	e8 a9 05 00 00       	call   801f55 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019ac:	83 ec 04             	sub    $0x4,%esp
  8019af:	50                   	push   %eax
  8019b0:	68 00 50 80 00       	push   $0x805000
  8019b5:	ff 75 0c             	pushl  0xc(%ebp)
  8019b8:	e8 dd ee ff ff       	call   80089a <memmove>
	return r;
  8019bd:	83 c4 10             	add    $0x10,%esp
}
  8019c0:	89 d8                	mov    %ebx,%eax
  8019c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019c5:	5b                   	pop    %ebx
  8019c6:	5e                   	pop    %esi
  8019c7:	5d                   	pop    %ebp
  8019c8:	c3                   	ret    

008019c9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019c9:	55                   	push   %ebp
  8019ca:	89 e5                	mov    %esp,%ebp
  8019cc:	53                   	push   %ebx
  8019cd:	83 ec 20             	sub    $0x20,%esp
  8019d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019d3:	53                   	push   %ebx
  8019d4:	e8 f6 ec ff ff       	call   8006cf <strlen>
  8019d9:	83 c4 10             	add    $0x10,%esp
  8019dc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019e1:	7f 67                	jg     801a4a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019e3:	83 ec 0c             	sub    $0xc,%esp
  8019e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019e9:	50                   	push   %eax
  8019ea:	e8 8e f8 ff ff       	call   80127d <fd_alloc>
  8019ef:	83 c4 10             	add    $0x10,%esp
		return r;
  8019f2:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019f4:	85 c0                	test   %eax,%eax
  8019f6:	78 57                	js     801a4f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019f8:	83 ec 08             	sub    $0x8,%esp
  8019fb:	53                   	push   %ebx
  8019fc:	68 00 50 80 00       	push   $0x805000
  801a01:	e8 02 ed ff ff       	call   800708 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a06:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a09:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a0e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a11:	b8 01 00 00 00       	mov    $0x1,%eax
  801a16:	e8 f6 fd ff ff       	call   801811 <fsipc>
  801a1b:	89 c3                	mov    %eax,%ebx
  801a1d:	83 c4 10             	add    $0x10,%esp
  801a20:	85 c0                	test   %eax,%eax
  801a22:	79 14                	jns    801a38 <open+0x6f>
		fd_close(fd, 0);
  801a24:	83 ec 08             	sub    $0x8,%esp
  801a27:	6a 00                	push   $0x0
  801a29:	ff 75 f4             	pushl  -0xc(%ebp)
  801a2c:	e8 47 f9 ff ff       	call   801378 <fd_close>
		return r;
  801a31:	83 c4 10             	add    $0x10,%esp
  801a34:	89 da                	mov    %ebx,%edx
  801a36:	eb 17                	jmp    801a4f <open+0x86>
	}

	return fd2num(fd);
  801a38:	83 ec 0c             	sub    $0xc,%esp
  801a3b:	ff 75 f4             	pushl  -0xc(%ebp)
  801a3e:	e8 13 f8 ff ff       	call   801256 <fd2num>
  801a43:	89 c2                	mov    %eax,%edx
  801a45:	83 c4 10             	add    $0x10,%esp
  801a48:	eb 05                	jmp    801a4f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a4a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a4f:	89 d0                	mov    %edx,%eax
  801a51:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a54:	c9                   	leave  
  801a55:	c3                   	ret    

00801a56 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a56:	55                   	push   %ebp
  801a57:	89 e5                	mov    %esp,%ebp
  801a59:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a5c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a61:	b8 08 00 00 00       	mov    $0x8,%eax
  801a66:	e8 a6 fd ff ff       	call   801811 <fsipc>
}
  801a6b:	c9                   	leave  
  801a6c:	c3                   	ret    

00801a6d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	56                   	push   %esi
  801a71:	53                   	push   %ebx
  801a72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a75:	83 ec 0c             	sub    $0xc,%esp
  801a78:	ff 75 08             	pushl  0x8(%ebp)
  801a7b:	e8 e6 f7 ff ff       	call   801266 <fd2data>
  801a80:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a82:	83 c4 08             	add    $0x8,%esp
  801a85:	68 d7 28 80 00       	push   $0x8028d7
  801a8a:	53                   	push   %ebx
  801a8b:	e8 78 ec ff ff       	call   800708 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a90:	8b 46 04             	mov    0x4(%esi),%eax
  801a93:	2b 06                	sub    (%esi),%eax
  801a95:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a9b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801aa2:	00 00 00 
	stat->st_dev = &devpipe;
  801aa5:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801aac:	30 80 00 
	return 0;
}
  801aaf:	b8 00 00 00 00       	mov    $0x0,%eax
  801ab4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab7:	5b                   	pop    %ebx
  801ab8:	5e                   	pop    %esi
  801ab9:	5d                   	pop    %ebp
  801aba:	c3                   	ret    

00801abb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801abb:	55                   	push   %ebp
  801abc:	89 e5                	mov    %esp,%ebp
  801abe:	53                   	push   %ebx
  801abf:	83 ec 0c             	sub    $0xc,%esp
  801ac2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ac5:	53                   	push   %ebx
  801ac6:	6a 00                	push   $0x0
  801ac8:	e8 c3 f0 ff ff       	call   800b90 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801acd:	89 1c 24             	mov    %ebx,(%esp)
  801ad0:	e8 91 f7 ff ff       	call   801266 <fd2data>
  801ad5:	83 c4 08             	add    $0x8,%esp
  801ad8:	50                   	push   %eax
  801ad9:	6a 00                	push   $0x0
  801adb:	e8 b0 f0 ff ff       	call   800b90 <sys_page_unmap>
}
  801ae0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ae3:	c9                   	leave  
  801ae4:	c3                   	ret    

00801ae5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ae5:	55                   	push   %ebp
  801ae6:	89 e5                	mov    %esp,%ebp
  801ae8:	57                   	push   %edi
  801ae9:	56                   	push   %esi
  801aea:	53                   	push   %ebx
  801aeb:	83 ec 1c             	sub    $0x1c,%esp
  801aee:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801af1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801af3:	a1 04 40 80 00       	mov    0x804004,%eax
  801af8:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801afe:	83 ec 0c             	sub    $0xc,%esp
  801b01:	ff 75 e0             	pushl  -0x20(%ebp)
  801b04:	e8 43 06 00 00       	call   80214c <pageref>
  801b09:	89 c3                	mov    %eax,%ebx
  801b0b:	89 3c 24             	mov    %edi,(%esp)
  801b0e:	e8 39 06 00 00       	call   80214c <pageref>
  801b13:	83 c4 10             	add    $0x10,%esp
  801b16:	39 c3                	cmp    %eax,%ebx
  801b18:	0f 94 c1             	sete   %cl
  801b1b:	0f b6 c9             	movzbl %cl,%ecx
  801b1e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b21:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b27:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  801b2d:	39 ce                	cmp    %ecx,%esi
  801b2f:	74 1e                	je     801b4f <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801b31:	39 c3                	cmp    %eax,%ebx
  801b33:	75 be                	jne    801af3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b35:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  801b3b:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b3e:	50                   	push   %eax
  801b3f:	56                   	push   %esi
  801b40:	68 de 28 80 00       	push   $0x8028de
  801b45:	e8 39 e6 ff ff       	call   800183 <cprintf>
  801b4a:	83 c4 10             	add    $0x10,%esp
  801b4d:	eb a4                	jmp    801af3 <_pipeisclosed+0xe>
	}
}
  801b4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b55:	5b                   	pop    %ebx
  801b56:	5e                   	pop    %esi
  801b57:	5f                   	pop    %edi
  801b58:	5d                   	pop    %ebp
  801b59:	c3                   	ret    

00801b5a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b5a:	55                   	push   %ebp
  801b5b:	89 e5                	mov    %esp,%ebp
  801b5d:	57                   	push   %edi
  801b5e:	56                   	push   %esi
  801b5f:	53                   	push   %ebx
  801b60:	83 ec 28             	sub    $0x28,%esp
  801b63:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b66:	56                   	push   %esi
  801b67:	e8 fa f6 ff ff       	call   801266 <fd2data>
  801b6c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b6e:	83 c4 10             	add    $0x10,%esp
  801b71:	bf 00 00 00 00       	mov    $0x0,%edi
  801b76:	eb 4b                	jmp    801bc3 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b78:	89 da                	mov    %ebx,%edx
  801b7a:	89 f0                	mov    %esi,%eax
  801b7c:	e8 64 ff ff ff       	call   801ae5 <_pipeisclosed>
  801b81:	85 c0                	test   %eax,%eax
  801b83:	75 48                	jne    801bcd <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b85:	e8 62 ef ff ff       	call   800aec <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b8a:	8b 43 04             	mov    0x4(%ebx),%eax
  801b8d:	8b 0b                	mov    (%ebx),%ecx
  801b8f:	8d 51 20             	lea    0x20(%ecx),%edx
  801b92:	39 d0                	cmp    %edx,%eax
  801b94:	73 e2                	jae    801b78 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b99:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b9d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ba0:	89 c2                	mov    %eax,%edx
  801ba2:	c1 fa 1f             	sar    $0x1f,%edx
  801ba5:	89 d1                	mov    %edx,%ecx
  801ba7:	c1 e9 1b             	shr    $0x1b,%ecx
  801baa:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bad:	83 e2 1f             	and    $0x1f,%edx
  801bb0:	29 ca                	sub    %ecx,%edx
  801bb2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bb6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bba:	83 c0 01             	add    $0x1,%eax
  801bbd:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bc0:	83 c7 01             	add    $0x1,%edi
  801bc3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bc6:	75 c2                	jne    801b8a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bc8:	8b 45 10             	mov    0x10(%ebp),%eax
  801bcb:	eb 05                	jmp    801bd2 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bcd:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bd5:	5b                   	pop    %ebx
  801bd6:	5e                   	pop    %esi
  801bd7:	5f                   	pop    %edi
  801bd8:	5d                   	pop    %ebp
  801bd9:	c3                   	ret    

00801bda <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bda:	55                   	push   %ebp
  801bdb:	89 e5                	mov    %esp,%ebp
  801bdd:	57                   	push   %edi
  801bde:	56                   	push   %esi
  801bdf:	53                   	push   %ebx
  801be0:	83 ec 18             	sub    $0x18,%esp
  801be3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801be6:	57                   	push   %edi
  801be7:	e8 7a f6 ff ff       	call   801266 <fd2data>
  801bec:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bee:	83 c4 10             	add    $0x10,%esp
  801bf1:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bf6:	eb 3d                	jmp    801c35 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bf8:	85 db                	test   %ebx,%ebx
  801bfa:	74 04                	je     801c00 <devpipe_read+0x26>
				return i;
  801bfc:	89 d8                	mov    %ebx,%eax
  801bfe:	eb 44                	jmp    801c44 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c00:	89 f2                	mov    %esi,%edx
  801c02:	89 f8                	mov    %edi,%eax
  801c04:	e8 dc fe ff ff       	call   801ae5 <_pipeisclosed>
  801c09:	85 c0                	test   %eax,%eax
  801c0b:	75 32                	jne    801c3f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c0d:	e8 da ee ff ff       	call   800aec <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c12:	8b 06                	mov    (%esi),%eax
  801c14:	3b 46 04             	cmp    0x4(%esi),%eax
  801c17:	74 df                	je     801bf8 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c19:	99                   	cltd   
  801c1a:	c1 ea 1b             	shr    $0x1b,%edx
  801c1d:	01 d0                	add    %edx,%eax
  801c1f:	83 e0 1f             	and    $0x1f,%eax
  801c22:	29 d0                	sub    %edx,%eax
  801c24:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c2c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c2f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c32:	83 c3 01             	add    $0x1,%ebx
  801c35:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c38:	75 d8                	jne    801c12 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c3a:	8b 45 10             	mov    0x10(%ebp),%eax
  801c3d:	eb 05                	jmp    801c44 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c3f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c47:	5b                   	pop    %ebx
  801c48:	5e                   	pop    %esi
  801c49:	5f                   	pop    %edi
  801c4a:	5d                   	pop    %ebp
  801c4b:	c3                   	ret    

00801c4c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c4c:	55                   	push   %ebp
  801c4d:	89 e5                	mov    %esp,%ebp
  801c4f:	56                   	push   %esi
  801c50:	53                   	push   %ebx
  801c51:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c54:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c57:	50                   	push   %eax
  801c58:	e8 20 f6 ff ff       	call   80127d <fd_alloc>
  801c5d:	83 c4 10             	add    $0x10,%esp
  801c60:	89 c2                	mov    %eax,%edx
  801c62:	85 c0                	test   %eax,%eax
  801c64:	0f 88 2c 01 00 00    	js     801d96 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c6a:	83 ec 04             	sub    $0x4,%esp
  801c6d:	68 07 04 00 00       	push   $0x407
  801c72:	ff 75 f4             	pushl  -0xc(%ebp)
  801c75:	6a 00                	push   $0x0
  801c77:	e8 8f ee ff ff       	call   800b0b <sys_page_alloc>
  801c7c:	83 c4 10             	add    $0x10,%esp
  801c7f:	89 c2                	mov    %eax,%edx
  801c81:	85 c0                	test   %eax,%eax
  801c83:	0f 88 0d 01 00 00    	js     801d96 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c89:	83 ec 0c             	sub    $0xc,%esp
  801c8c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c8f:	50                   	push   %eax
  801c90:	e8 e8 f5 ff ff       	call   80127d <fd_alloc>
  801c95:	89 c3                	mov    %eax,%ebx
  801c97:	83 c4 10             	add    $0x10,%esp
  801c9a:	85 c0                	test   %eax,%eax
  801c9c:	0f 88 e2 00 00 00    	js     801d84 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ca2:	83 ec 04             	sub    $0x4,%esp
  801ca5:	68 07 04 00 00       	push   $0x407
  801caa:	ff 75 f0             	pushl  -0x10(%ebp)
  801cad:	6a 00                	push   $0x0
  801caf:	e8 57 ee ff ff       	call   800b0b <sys_page_alloc>
  801cb4:	89 c3                	mov    %eax,%ebx
  801cb6:	83 c4 10             	add    $0x10,%esp
  801cb9:	85 c0                	test   %eax,%eax
  801cbb:	0f 88 c3 00 00 00    	js     801d84 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cc1:	83 ec 0c             	sub    $0xc,%esp
  801cc4:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc7:	e8 9a f5 ff ff       	call   801266 <fd2data>
  801ccc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cce:	83 c4 0c             	add    $0xc,%esp
  801cd1:	68 07 04 00 00       	push   $0x407
  801cd6:	50                   	push   %eax
  801cd7:	6a 00                	push   $0x0
  801cd9:	e8 2d ee ff ff       	call   800b0b <sys_page_alloc>
  801cde:	89 c3                	mov    %eax,%ebx
  801ce0:	83 c4 10             	add    $0x10,%esp
  801ce3:	85 c0                	test   %eax,%eax
  801ce5:	0f 88 89 00 00 00    	js     801d74 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ceb:	83 ec 0c             	sub    $0xc,%esp
  801cee:	ff 75 f0             	pushl  -0x10(%ebp)
  801cf1:	e8 70 f5 ff ff       	call   801266 <fd2data>
  801cf6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cfd:	50                   	push   %eax
  801cfe:	6a 00                	push   $0x0
  801d00:	56                   	push   %esi
  801d01:	6a 00                	push   $0x0
  801d03:	e8 46 ee ff ff       	call   800b4e <sys_page_map>
  801d08:	89 c3                	mov    %eax,%ebx
  801d0a:	83 c4 20             	add    $0x20,%esp
  801d0d:	85 c0                	test   %eax,%eax
  801d0f:	78 55                	js     801d66 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d11:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d26:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d2f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d34:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d3b:	83 ec 0c             	sub    $0xc,%esp
  801d3e:	ff 75 f4             	pushl  -0xc(%ebp)
  801d41:	e8 10 f5 ff ff       	call   801256 <fd2num>
  801d46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d49:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d4b:	83 c4 04             	add    $0x4,%esp
  801d4e:	ff 75 f0             	pushl  -0x10(%ebp)
  801d51:	e8 00 f5 ff ff       	call   801256 <fd2num>
  801d56:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d59:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801d5c:	83 c4 10             	add    $0x10,%esp
  801d5f:	ba 00 00 00 00       	mov    $0x0,%edx
  801d64:	eb 30                	jmp    801d96 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d66:	83 ec 08             	sub    $0x8,%esp
  801d69:	56                   	push   %esi
  801d6a:	6a 00                	push   $0x0
  801d6c:	e8 1f ee ff ff       	call   800b90 <sys_page_unmap>
  801d71:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d74:	83 ec 08             	sub    $0x8,%esp
  801d77:	ff 75 f0             	pushl  -0x10(%ebp)
  801d7a:	6a 00                	push   $0x0
  801d7c:	e8 0f ee ff ff       	call   800b90 <sys_page_unmap>
  801d81:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d84:	83 ec 08             	sub    $0x8,%esp
  801d87:	ff 75 f4             	pushl  -0xc(%ebp)
  801d8a:	6a 00                	push   $0x0
  801d8c:	e8 ff ed ff ff       	call   800b90 <sys_page_unmap>
  801d91:	83 c4 10             	add    $0x10,%esp
  801d94:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d96:	89 d0                	mov    %edx,%eax
  801d98:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d9b:	5b                   	pop    %ebx
  801d9c:	5e                   	pop    %esi
  801d9d:	5d                   	pop    %ebp
  801d9e:	c3                   	ret    

00801d9f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d9f:	55                   	push   %ebp
  801da0:	89 e5                	mov    %esp,%ebp
  801da2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801da5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801da8:	50                   	push   %eax
  801da9:	ff 75 08             	pushl  0x8(%ebp)
  801dac:	e8 1b f5 ff ff       	call   8012cc <fd_lookup>
  801db1:	83 c4 10             	add    $0x10,%esp
  801db4:	85 c0                	test   %eax,%eax
  801db6:	78 18                	js     801dd0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801db8:	83 ec 0c             	sub    $0xc,%esp
  801dbb:	ff 75 f4             	pushl  -0xc(%ebp)
  801dbe:	e8 a3 f4 ff ff       	call   801266 <fd2data>
	return _pipeisclosed(fd, p);
  801dc3:	89 c2                	mov    %eax,%edx
  801dc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc8:	e8 18 fd ff ff       	call   801ae5 <_pipeisclosed>
  801dcd:	83 c4 10             	add    $0x10,%esp
}
  801dd0:	c9                   	leave  
  801dd1:	c3                   	ret    

00801dd2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801dd2:	55                   	push   %ebp
  801dd3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801dd5:	b8 00 00 00 00       	mov    $0x0,%eax
  801dda:	5d                   	pop    %ebp
  801ddb:	c3                   	ret    

00801ddc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ddc:	55                   	push   %ebp
  801ddd:	89 e5                	mov    %esp,%ebp
  801ddf:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801de2:	68 f6 28 80 00       	push   $0x8028f6
  801de7:	ff 75 0c             	pushl  0xc(%ebp)
  801dea:	e8 19 e9 ff ff       	call   800708 <strcpy>
	return 0;
}
  801def:	b8 00 00 00 00       	mov    $0x0,%eax
  801df4:	c9                   	leave  
  801df5:	c3                   	ret    

00801df6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801df6:	55                   	push   %ebp
  801df7:	89 e5                	mov    %esp,%ebp
  801df9:	57                   	push   %edi
  801dfa:	56                   	push   %esi
  801dfb:	53                   	push   %ebx
  801dfc:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e02:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e07:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e0d:	eb 2d                	jmp    801e3c <devcons_write+0x46>
		m = n - tot;
  801e0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e12:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e14:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e17:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e1c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e1f:	83 ec 04             	sub    $0x4,%esp
  801e22:	53                   	push   %ebx
  801e23:	03 45 0c             	add    0xc(%ebp),%eax
  801e26:	50                   	push   %eax
  801e27:	57                   	push   %edi
  801e28:	e8 6d ea ff ff       	call   80089a <memmove>
		sys_cputs(buf, m);
  801e2d:	83 c4 08             	add    $0x8,%esp
  801e30:	53                   	push   %ebx
  801e31:	57                   	push   %edi
  801e32:	e8 18 ec ff ff       	call   800a4f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e37:	01 de                	add    %ebx,%esi
  801e39:	83 c4 10             	add    $0x10,%esp
  801e3c:	89 f0                	mov    %esi,%eax
  801e3e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e41:	72 cc                	jb     801e0f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e46:	5b                   	pop    %ebx
  801e47:	5e                   	pop    %esi
  801e48:	5f                   	pop    %edi
  801e49:	5d                   	pop    %ebp
  801e4a:	c3                   	ret    

00801e4b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e4b:	55                   	push   %ebp
  801e4c:	89 e5                	mov    %esp,%ebp
  801e4e:	83 ec 08             	sub    $0x8,%esp
  801e51:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e56:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e5a:	74 2a                	je     801e86 <devcons_read+0x3b>
  801e5c:	eb 05                	jmp    801e63 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e5e:	e8 89 ec ff ff       	call   800aec <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e63:	e8 05 ec ff ff       	call   800a6d <sys_cgetc>
  801e68:	85 c0                	test   %eax,%eax
  801e6a:	74 f2                	je     801e5e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e6c:	85 c0                	test   %eax,%eax
  801e6e:	78 16                	js     801e86 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e70:	83 f8 04             	cmp    $0x4,%eax
  801e73:	74 0c                	je     801e81 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e75:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e78:	88 02                	mov    %al,(%edx)
	return 1;
  801e7a:	b8 01 00 00 00       	mov    $0x1,%eax
  801e7f:	eb 05                	jmp    801e86 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e81:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e86:	c9                   	leave  
  801e87:	c3                   	ret    

00801e88 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e88:	55                   	push   %ebp
  801e89:	89 e5                	mov    %esp,%ebp
  801e8b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e91:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e94:	6a 01                	push   $0x1
  801e96:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e99:	50                   	push   %eax
  801e9a:	e8 b0 eb ff ff       	call   800a4f <sys_cputs>
}
  801e9f:	83 c4 10             	add    $0x10,%esp
  801ea2:	c9                   	leave  
  801ea3:	c3                   	ret    

00801ea4 <getchar>:

int
getchar(void)
{
  801ea4:	55                   	push   %ebp
  801ea5:	89 e5                	mov    %esp,%ebp
  801ea7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801eaa:	6a 01                	push   $0x1
  801eac:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eaf:	50                   	push   %eax
  801eb0:	6a 00                	push   $0x0
  801eb2:	e8 7e f6 ff ff       	call   801535 <read>
	if (r < 0)
  801eb7:	83 c4 10             	add    $0x10,%esp
  801eba:	85 c0                	test   %eax,%eax
  801ebc:	78 0f                	js     801ecd <getchar+0x29>
		return r;
	if (r < 1)
  801ebe:	85 c0                	test   %eax,%eax
  801ec0:	7e 06                	jle    801ec8 <getchar+0x24>
		return -E_EOF;
	return c;
  801ec2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ec6:	eb 05                	jmp    801ecd <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ec8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ecd:	c9                   	leave  
  801ece:	c3                   	ret    

00801ecf <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ecf:	55                   	push   %ebp
  801ed0:	89 e5                	mov    %esp,%ebp
  801ed2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ed5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ed8:	50                   	push   %eax
  801ed9:	ff 75 08             	pushl  0x8(%ebp)
  801edc:	e8 eb f3 ff ff       	call   8012cc <fd_lookup>
  801ee1:	83 c4 10             	add    $0x10,%esp
  801ee4:	85 c0                	test   %eax,%eax
  801ee6:	78 11                	js     801ef9 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eeb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ef1:	39 10                	cmp    %edx,(%eax)
  801ef3:	0f 94 c0             	sete   %al
  801ef6:	0f b6 c0             	movzbl %al,%eax
}
  801ef9:	c9                   	leave  
  801efa:	c3                   	ret    

00801efb <opencons>:

int
opencons(void)
{
  801efb:	55                   	push   %ebp
  801efc:	89 e5                	mov    %esp,%ebp
  801efe:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f04:	50                   	push   %eax
  801f05:	e8 73 f3 ff ff       	call   80127d <fd_alloc>
  801f0a:	83 c4 10             	add    $0x10,%esp
		return r;
  801f0d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f0f:	85 c0                	test   %eax,%eax
  801f11:	78 3e                	js     801f51 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f13:	83 ec 04             	sub    $0x4,%esp
  801f16:	68 07 04 00 00       	push   $0x407
  801f1b:	ff 75 f4             	pushl  -0xc(%ebp)
  801f1e:	6a 00                	push   $0x0
  801f20:	e8 e6 eb ff ff       	call   800b0b <sys_page_alloc>
  801f25:	83 c4 10             	add    $0x10,%esp
		return r;
  801f28:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f2a:	85 c0                	test   %eax,%eax
  801f2c:	78 23                	js     801f51 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f2e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f37:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f3c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f43:	83 ec 0c             	sub    $0xc,%esp
  801f46:	50                   	push   %eax
  801f47:	e8 0a f3 ff ff       	call   801256 <fd2num>
  801f4c:	89 c2                	mov    %eax,%edx
  801f4e:	83 c4 10             	add    $0x10,%esp
}
  801f51:	89 d0                	mov    %edx,%eax
  801f53:	c9                   	leave  
  801f54:	c3                   	ret    

00801f55 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f55:	55                   	push   %ebp
  801f56:	89 e5                	mov    %esp,%ebp
  801f58:	56                   	push   %esi
  801f59:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f5a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f5d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801f63:	e8 65 eb ff ff       	call   800acd <sys_getenvid>
  801f68:	83 ec 0c             	sub    $0xc,%esp
  801f6b:	ff 75 0c             	pushl  0xc(%ebp)
  801f6e:	ff 75 08             	pushl  0x8(%ebp)
  801f71:	56                   	push   %esi
  801f72:	50                   	push   %eax
  801f73:	68 04 29 80 00       	push   $0x802904
  801f78:	e8 06 e2 ff ff       	call   800183 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f7d:	83 c4 18             	add    $0x18,%esp
  801f80:	53                   	push   %ebx
  801f81:	ff 75 10             	pushl  0x10(%ebp)
  801f84:	e8 a9 e1 ff ff       	call   800132 <vcprintf>
	cprintf("\n");
  801f89:	c7 04 24 fb 27 80 00 	movl   $0x8027fb,(%esp)
  801f90:	e8 ee e1 ff ff       	call   800183 <cprintf>
  801f95:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f98:	cc                   	int3   
  801f99:	eb fd                	jmp    801f98 <_panic+0x43>

00801f9b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f9b:	55                   	push   %ebp
  801f9c:	89 e5                	mov    %esp,%ebp
  801f9e:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801fa1:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fa8:	75 2a                	jne    801fd4 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801faa:	83 ec 04             	sub    $0x4,%esp
  801fad:	6a 07                	push   $0x7
  801faf:	68 00 f0 bf ee       	push   $0xeebff000
  801fb4:	6a 00                	push   $0x0
  801fb6:	e8 50 eb ff ff       	call   800b0b <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801fbb:	83 c4 10             	add    $0x10,%esp
  801fbe:	85 c0                	test   %eax,%eax
  801fc0:	79 12                	jns    801fd4 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801fc2:	50                   	push   %eax
  801fc3:	68 12 28 80 00       	push   $0x802812
  801fc8:	6a 23                	push   $0x23
  801fca:	68 28 29 80 00       	push   $0x802928
  801fcf:	e8 81 ff ff ff       	call   801f55 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fd4:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd7:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801fdc:	83 ec 08             	sub    $0x8,%esp
  801fdf:	68 06 20 80 00       	push   $0x802006
  801fe4:	6a 00                	push   $0x0
  801fe6:	e8 6b ec ff ff       	call   800c56 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801feb:	83 c4 10             	add    $0x10,%esp
  801fee:	85 c0                	test   %eax,%eax
  801ff0:	79 12                	jns    802004 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801ff2:	50                   	push   %eax
  801ff3:	68 12 28 80 00       	push   $0x802812
  801ff8:	6a 2c                	push   $0x2c
  801ffa:	68 28 29 80 00       	push   $0x802928
  801fff:	e8 51 ff ff ff       	call   801f55 <_panic>
	}
}
  802004:	c9                   	leave  
  802005:	c3                   	ret    

00802006 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802006:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802007:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80200c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80200e:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802011:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802015:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  80201a:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  80201e:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802020:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802023:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802024:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802027:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802028:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802029:	c3                   	ret    

0080202a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80202a:	55                   	push   %ebp
  80202b:	89 e5                	mov    %esp,%ebp
  80202d:	56                   	push   %esi
  80202e:	53                   	push   %ebx
  80202f:	8b 75 08             	mov    0x8(%ebp),%esi
  802032:	8b 45 0c             	mov    0xc(%ebp),%eax
  802035:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802038:	85 c0                	test   %eax,%eax
  80203a:	75 12                	jne    80204e <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80203c:	83 ec 0c             	sub    $0xc,%esp
  80203f:	68 00 00 c0 ee       	push   $0xeec00000
  802044:	e8 72 ec ff ff       	call   800cbb <sys_ipc_recv>
  802049:	83 c4 10             	add    $0x10,%esp
  80204c:	eb 0c                	jmp    80205a <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80204e:	83 ec 0c             	sub    $0xc,%esp
  802051:	50                   	push   %eax
  802052:	e8 64 ec ff ff       	call   800cbb <sys_ipc_recv>
  802057:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80205a:	85 f6                	test   %esi,%esi
  80205c:	0f 95 c1             	setne  %cl
  80205f:	85 db                	test   %ebx,%ebx
  802061:	0f 95 c2             	setne  %dl
  802064:	84 d1                	test   %dl,%cl
  802066:	74 09                	je     802071 <ipc_recv+0x47>
  802068:	89 c2                	mov    %eax,%edx
  80206a:	c1 ea 1f             	shr    $0x1f,%edx
  80206d:	84 d2                	test   %dl,%dl
  80206f:	75 2d                	jne    80209e <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802071:	85 f6                	test   %esi,%esi
  802073:	74 0d                	je     802082 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802075:	a1 04 40 80 00       	mov    0x804004,%eax
  80207a:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  802080:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802082:	85 db                	test   %ebx,%ebx
  802084:	74 0d                	je     802093 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802086:	a1 04 40 80 00       	mov    0x804004,%eax
  80208b:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802091:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802093:	a1 04 40 80 00       	mov    0x804004,%eax
  802098:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  80209e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020a1:	5b                   	pop    %ebx
  8020a2:	5e                   	pop    %esi
  8020a3:	5d                   	pop    %ebp
  8020a4:	c3                   	ret    

008020a5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020a5:	55                   	push   %ebp
  8020a6:	89 e5                	mov    %esp,%ebp
  8020a8:	57                   	push   %edi
  8020a9:	56                   	push   %esi
  8020aa:	53                   	push   %ebx
  8020ab:	83 ec 0c             	sub    $0xc,%esp
  8020ae:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020b1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8020b7:	85 db                	test   %ebx,%ebx
  8020b9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8020be:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8020c1:	ff 75 14             	pushl  0x14(%ebp)
  8020c4:	53                   	push   %ebx
  8020c5:	56                   	push   %esi
  8020c6:	57                   	push   %edi
  8020c7:	e8 cc eb ff ff       	call   800c98 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8020cc:	89 c2                	mov    %eax,%edx
  8020ce:	c1 ea 1f             	shr    $0x1f,%edx
  8020d1:	83 c4 10             	add    $0x10,%esp
  8020d4:	84 d2                	test   %dl,%dl
  8020d6:	74 17                	je     8020ef <ipc_send+0x4a>
  8020d8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020db:	74 12                	je     8020ef <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8020dd:	50                   	push   %eax
  8020de:	68 36 29 80 00       	push   $0x802936
  8020e3:	6a 47                	push   $0x47
  8020e5:	68 44 29 80 00       	push   $0x802944
  8020ea:	e8 66 fe ff ff       	call   801f55 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8020ef:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020f2:	75 07                	jne    8020fb <ipc_send+0x56>
			sys_yield();
  8020f4:	e8 f3 e9 ff ff       	call   800aec <sys_yield>
  8020f9:	eb c6                	jmp    8020c1 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8020fb:	85 c0                	test   %eax,%eax
  8020fd:	75 c2                	jne    8020c1 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8020ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802102:	5b                   	pop    %ebx
  802103:	5e                   	pop    %esi
  802104:	5f                   	pop    %edi
  802105:	5d                   	pop    %ebp
  802106:	c3                   	ret    

00802107 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802107:	55                   	push   %ebp
  802108:	89 e5                	mov    %esp,%ebp
  80210a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80210d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802112:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  802118:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80211e:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  802124:	39 ca                	cmp    %ecx,%edx
  802126:	75 13                	jne    80213b <ipc_find_env+0x34>
			return envs[i].env_id;
  802128:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  80212e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802133:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  802139:	eb 0f                	jmp    80214a <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80213b:	83 c0 01             	add    $0x1,%eax
  80213e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802143:	75 cd                	jne    802112 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802145:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80214a:	5d                   	pop    %ebp
  80214b:	c3                   	ret    

0080214c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80214c:	55                   	push   %ebp
  80214d:	89 e5                	mov    %esp,%ebp
  80214f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802152:	89 d0                	mov    %edx,%eax
  802154:	c1 e8 16             	shr    $0x16,%eax
  802157:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80215e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802163:	f6 c1 01             	test   $0x1,%cl
  802166:	74 1d                	je     802185 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802168:	c1 ea 0c             	shr    $0xc,%edx
  80216b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802172:	f6 c2 01             	test   $0x1,%dl
  802175:	74 0e                	je     802185 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802177:	c1 ea 0c             	shr    $0xc,%edx
  80217a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802181:	ef 
  802182:	0f b7 c0             	movzwl %ax,%eax
}
  802185:	5d                   	pop    %ebp
  802186:	c3                   	ret    
  802187:	66 90                	xchg   %ax,%ax
  802189:	66 90                	xchg   %ax,%ax
  80218b:	66 90                	xchg   %ax,%ax
  80218d:	66 90                	xchg   %ax,%ax
  80218f:	90                   	nop

00802190 <__udivdi3>:
  802190:	55                   	push   %ebp
  802191:	57                   	push   %edi
  802192:	56                   	push   %esi
  802193:	53                   	push   %ebx
  802194:	83 ec 1c             	sub    $0x1c,%esp
  802197:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80219b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80219f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8021a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021a7:	85 f6                	test   %esi,%esi
  8021a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021ad:	89 ca                	mov    %ecx,%edx
  8021af:	89 f8                	mov    %edi,%eax
  8021b1:	75 3d                	jne    8021f0 <__udivdi3+0x60>
  8021b3:	39 cf                	cmp    %ecx,%edi
  8021b5:	0f 87 c5 00 00 00    	ja     802280 <__udivdi3+0xf0>
  8021bb:	85 ff                	test   %edi,%edi
  8021bd:	89 fd                	mov    %edi,%ebp
  8021bf:	75 0b                	jne    8021cc <__udivdi3+0x3c>
  8021c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021c6:	31 d2                	xor    %edx,%edx
  8021c8:	f7 f7                	div    %edi
  8021ca:	89 c5                	mov    %eax,%ebp
  8021cc:	89 c8                	mov    %ecx,%eax
  8021ce:	31 d2                	xor    %edx,%edx
  8021d0:	f7 f5                	div    %ebp
  8021d2:	89 c1                	mov    %eax,%ecx
  8021d4:	89 d8                	mov    %ebx,%eax
  8021d6:	89 cf                	mov    %ecx,%edi
  8021d8:	f7 f5                	div    %ebp
  8021da:	89 c3                	mov    %eax,%ebx
  8021dc:	89 d8                	mov    %ebx,%eax
  8021de:	89 fa                	mov    %edi,%edx
  8021e0:	83 c4 1c             	add    $0x1c,%esp
  8021e3:	5b                   	pop    %ebx
  8021e4:	5e                   	pop    %esi
  8021e5:	5f                   	pop    %edi
  8021e6:	5d                   	pop    %ebp
  8021e7:	c3                   	ret    
  8021e8:	90                   	nop
  8021e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	39 ce                	cmp    %ecx,%esi
  8021f2:	77 74                	ja     802268 <__udivdi3+0xd8>
  8021f4:	0f bd fe             	bsr    %esi,%edi
  8021f7:	83 f7 1f             	xor    $0x1f,%edi
  8021fa:	0f 84 98 00 00 00    	je     802298 <__udivdi3+0x108>
  802200:	bb 20 00 00 00       	mov    $0x20,%ebx
  802205:	89 f9                	mov    %edi,%ecx
  802207:	89 c5                	mov    %eax,%ebp
  802209:	29 fb                	sub    %edi,%ebx
  80220b:	d3 e6                	shl    %cl,%esi
  80220d:	89 d9                	mov    %ebx,%ecx
  80220f:	d3 ed                	shr    %cl,%ebp
  802211:	89 f9                	mov    %edi,%ecx
  802213:	d3 e0                	shl    %cl,%eax
  802215:	09 ee                	or     %ebp,%esi
  802217:	89 d9                	mov    %ebx,%ecx
  802219:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80221d:	89 d5                	mov    %edx,%ebp
  80221f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802223:	d3 ed                	shr    %cl,%ebp
  802225:	89 f9                	mov    %edi,%ecx
  802227:	d3 e2                	shl    %cl,%edx
  802229:	89 d9                	mov    %ebx,%ecx
  80222b:	d3 e8                	shr    %cl,%eax
  80222d:	09 c2                	or     %eax,%edx
  80222f:	89 d0                	mov    %edx,%eax
  802231:	89 ea                	mov    %ebp,%edx
  802233:	f7 f6                	div    %esi
  802235:	89 d5                	mov    %edx,%ebp
  802237:	89 c3                	mov    %eax,%ebx
  802239:	f7 64 24 0c          	mull   0xc(%esp)
  80223d:	39 d5                	cmp    %edx,%ebp
  80223f:	72 10                	jb     802251 <__udivdi3+0xc1>
  802241:	8b 74 24 08          	mov    0x8(%esp),%esi
  802245:	89 f9                	mov    %edi,%ecx
  802247:	d3 e6                	shl    %cl,%esi
  802249:	39 c6                	cmp    %eax,%esi
  80224b:	73 07                	jae    802254 <__udivdi3+0xc4>
  80224d:	39 d5                	cmp    %edx,%ebp
  80224f:	75 03                	jne    802254 <__udivdi3+0xc4>
  802251:	83 eb 01             	sub    $0x1,%ebx
  802254:	31 ff                	xor    %edi,%edi
  802256:	89 d8                	mov    %ebx,%eax
  802258:	89 fa                	mov    %edi,%edx
  80225a:	83 c4 1c             	add    $0x1c,%esp
  80225d:	5b                   	pop    %ebx
  80225e:	5e                   	pop    %esi
  80225f:	5f                   	pop    %edi
  802260:	5d                   	pop    %ebp
  802261:	c3                   	ret    
  802262:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802268:	31 ff                	xor    %edi,%edi
  80226a:	31 db                	xor    %ebx,%ebx
  80226c:	89 d8                	mov    %ebx,%eax
  80226e:	89 fa                	mov    %edi,%edx
  802270:	83 c4 1c             	add    $0x1c,%esp
  802273:	5b                   	pop    %ebx
  802274:	5e                   	pop    %esi
  802275:	5f                   	pop    %edi
  802276:	5d                   	pop    %ebp
  802277:	c3                   	ret    
  802278:	90                   	nop
  802279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802280:	89 d8                	mov    %ebx,%eax
  802282:	f7 f7                	div    %edi
  802284:	31 ff                	xor    %edi,%edi
  802286:	89 c3                	mov    %eax,%ebx
  802288:	89 d8                	mov    %ebx,%eax
  80228a:	89 fa                	mov    %edi,%edx
  80228c:	83 c4 1c             	add    $0x1c,%esp
  80228f:	5b                   	pop    %ebx
  802290:	5e                   	pop    %esi
  802291:	5f                   	pop    %edi
  802292:	5d                   	pop    %ebp
  802293:	c3                   	ret    
  802294:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802298:	39 ce                	cmp    %ecx,%esi
  80229a:	72 0c                	jb     8022a8 <__udivdi3+0x118>
  80229c:	31 db                	xor    %ebx,%ebx
  80229e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8022a2:	0f 87 34 ff ff ff    	ja     8021dc <__udivdi3+0x4c>
  8022a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8022ad:	e9 2a ff ff ff       	jmp    8021dc <__udivdi3+0x4c>
  8022b2:	66 90                	xchg   %ax,%ax
  8022b4:	66 90                	xchg   %ax,%ax
  8022b6:	66 90                	xchg   %ax,%ax
  8022b8:	66 90                	xchg   %ax,%ax
  8022ba:	66 90                	xchg   %ax,%ax
  8022bc:	66 90                	xchg   %ax,%ax
  8022be:	66 90                	xchg   %ax,%ax

008022c0 <__umoddi3>:
  8022c0:	55                   	push   %ebp
  8022c1:	57                   	push   %edi
  8022c2:	56                   	push   %esi
  8022c3:	53                   	push   %ebx
  8022c4:	83 ec 1c             	sub    $0x1c,%esp
  8022c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022d7:	85 d2                	test   %edx,%edx
  8022d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022e1:	89 f3                	mov    %esi,%ebx
  8022e3:	89 3c 24             	mov    %edi,(%esp)
  8022e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022ea:	75 1c                	jne    802308 <__umoddi3+0x48>
  8022ec:	39 f7                	cmp    %esi,%edi
  8022ee:	76 50                	jbe    802340 <__umoddi3+0x80>
  8022f0:	89 c8                	mov    %ecx,%eax
  8022f2:	89 f2                	mov    %esi,%edx
  8022f4:	f7 f7                	div    %edi
  8022f6:	89 d0                	mov    %edx,%eax
  8022f8:	31 d2                	xor    %edx,%edx
  8022fa:	83 c4 1c             	add    $0x1c,%esp
  8022fd:	5b                   	pop    %ebx
  8022fe:	5e                   	pop    %esi
  8022ff:	5f                   	pop    %edi
  802300:	5d                   	pop    %ebp
  802301:	c3                   	ret    
  802302:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802308:	39 f2                	cmp    %esi,%edx
  80230a:	89 d0                	mov    %edx,%eax
  80230c:	77 52                	ja     802360 <__umoddi3+0xa0>
  80230e:	0f bd ea             	bsr    %edx,%ebp
  802311:	83 f5 1f             	xor    $0x1f,%ebp
  802314:	75 5a                	jne    802370 <__umoddi3+0xb0>
  802316:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80231a:	0f 82 e0 00 00 00    	jb     802400 <__umoddi3+0x140>
  802320:	39 0c 24             	cmp    %ecx,(%esp)
  802323:	0f 86 d7 00 00 00    	jbe    802400 <__umoddi3+0x140>
  802329:	8b 44 24 08          	mov    0x8(%esp),%eax
  80232d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802331:	83 c4 1c             	add    $0x1c,%esp
  802334:	5b                   	pop    %ebx
  802335:	5e                   	pop    %esi
  802336:	5f                   	pop    %edi
  802337:	5d                   	pop    %ebp
  802338:	c3                   	ret    
  802339:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802340:	85 ff                	test   %edi,%edi
  802342:	89 fd                	mov    %edi,%ebp
  802344:	75 0b                	jne    802351 <__umoddi3+0x91>
  802346:	b8 01 00 00 00       	mov    $0x1,%eax
  80234b:	31 d2                	xor    %edx,%edx
  80234d:	f7 f7                	div    %edi
  80234f:	89 c5                	mov    %eax,%ebp
  802351:	89 f0                	mov    %esi,%eax
  802353:	31 d2                	xor    %edx,%edx
  802355:	f7 f5                	div    %ebp
  802357:	89 c8                	mov    %ecx,%eax
  802359:	f7 f5                	div    %ebp
  80235b:	89 d0                	mov    %edx,%eax
  80235d:	eb 99                	jmp    8022f8 <__umoddi3+0x38>
  80235f:	90                   	nop
  802360:	89 c8                	mov    %ecx,%eax
  802362:	89 f2                	mov    %esi,%edx
  802364:	83 c4 1c             	add    $0x1c,%esp
  802367:	5b                   	pop    %ebx
  802368:	5e                   	pop    %esi
  802369:	5f                   	pop    %edi
  80236a:	5d                   	pop    %ebp
  80236b:	c3                   	ret    
  80236c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802370:	8b 34 24             	mov    (%esp),%esi
  802373:	bf 20 00 00 00       	mov    $0x20,%edi
  802378:	89 e9                	mov    %ebp,%ecx
  80237a:	29 ef                	sub    %ebp,%edi
  80237c:	d3 e0                	shl    %cl,%eax
  80237e:	89 f9                	mov    %edi,%ecx
  802380:	89 f2                	mov    %esi,%edx
  802382:	d3 ea                	shr    %cl,%edx
  802384:	89 e9                	mov    %ebp,%ecx
  802386:	09 c2                	or     %eax,%edx
  802388:	89 d8                	mov    %ebx,%eax
  80238a:	89 14 24             	mov    %edx,(%esp)
  80238d:	89 f2                	mov    %esi,%edx
  80238f:	d3 e2                	shl    %cl,%edx
  802391:	89 f9                	mov    %edi,%ecx
  802393:	89 54 24 04          	mov    %edx,0x4(%esp)
  802397:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80239b:	d3 e8                	shr    %cl,%eax
  80239d:	89 e9                	mov    %ebp,%ecx
  80239f:	89 c6                	mov    %eax,%esi
  8023a1:	d3 e3                	shl    %cl,%ebx
  8023a3:	89 f9                	mov    %edi,%ecx
  8023a5:	89 d0                	mov    %edx,%eax
  8023a7:	d3 e8                	shr    %cl,%eax
  8023a9:	89 e9                	mov    %ebp,%ecx
  8023ab:	09 d8                	or     %ebx,%eax
  8023ad:	89 d3                	mov    %edx,%ebx
  8023af:	89 f2                	mov    %esi,%edx
  8023b1:	f7 34 24             	divl   (%esp)
  8023b4:	89 d6                	mov    %edx,%esi
  8023b6:	d3 e3                	shl    %cl,%ebx
  8023b8:	f7 64 24 04          	mull   0x4(%esp)
  8023bc:	39 d6                	cmp    %edx,%esi
  8023be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023c2:	89 d1                	mov    %edx,%ecx
  8023c4:	89 c3                	mov    %eax,%ebx
  8023c6:	72 08                	jb     8023d0 <__umoddi3+0x110>
  8023c8:	75 11                	jne    8023db <__umoddi3+0x11b>
  8023ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8023ce:	73 0b                	jae    8023db <__umoddi3+0x11b>
  8023d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023d4:	1b 14 24             	sbb    (%esp),%edx
  8023d7:	89 d1                	mov    %edx,%ecx
  8023d9:	89 c3                	mov    %eax,%ebx
  8023db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8023df:	29 da                	sub    %ebx,%edx
  8023e1:	19 ce                	sbb    %ecx,%esi
  8023e3:	89 f9                	mov    %edi,%ecx
  8023e5:	89 f0                	mov    %esi,%eax
  8023e7:	d3 e0                	shl    %cl,%eax
  8023e9:	89 e9                	mov    %ebp,%ecx
  8023eb:	d3 ea                	shr    %cl,%edx
  8023ed:	89 e9                	mov    %ebp,%ecx
  8023ef:	d3 ee                	shr    %cl,%esi
  8023f1:	09 d0                	or     %edx,%eax
  8023f3:	89 f2                	mov    %esi,%edx
  8023f5:	83 c4 1c             	add    $0x1c,%esp
  8023f8:	5b                   	pop    %ebx
  8023f9:	5e                   	pop    %esi
  8023fa:	5f                   	pop    %edi
  8023fb:	5d                   	pop    %ebp
  8023fc:	c3                   	ret    
  8023fd:	8d 76 00             	lea    0x0(%esi),%esi
  802400:	29 f9                	sub    %edi,%ecx
  802402:	19 d6                	sbb    %edx,%esi
  802404:	89 74 24 04          	mov    %esi,0x4(%esp)
  802408:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80240c:	e9 18 ff ff ff       	jmp    802329 <__umoddi3+0x69>
