
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
  800043:	68 a0 24 80 00       	push   $0x8024a0
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
  80005e:	68 ae 24 80 00       	push   $0x8024ae
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
  800082:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  800088:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008d:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

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

void 
thread_main(/*uintptr_t eip*/)
{
  8000b6:	55                   	push   %ebp
  8000b7:	89 e5                	mov    %esp,%ebp
  8000b9:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

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
  8000dc:	e8 c5 13 00 00       	call   8014a6 <close_all>
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
  8001e6:	e8 25 20 00 00       	call   802210 <__udivdi3>
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
  800229:	e8 12 21 00 00       	call   802340 <__umoddi3>
  80022e:	83 c4 14             	add    $0x14,%esp
  800231:	0f be 80 d2 24 80 00 	movsbl 0x8024d2(%eax),%eax
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
  80032d:	ff 24 85 20 26 80 00 	jmp    *0x802620(,%eax,4)
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
  8003f1:	8b 14 85 80 27 80 00 	mov    0x802780(,%eax,4),%edx
  8003f8:	85 d2                	test   %edx,%edx
  8003fa:	75 18                	jne    800414 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003fc:	50                   	push   %eax
  8003fd:	68 ea 24 80 00       	push   $0x8024ea
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
  800415:	68 0d 2a 80 00       	push   $0x802a0d
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
  800439:	b8 e3 24 80 00       	mov    $0x8024e3,%eax
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
  800ab4:	68 df 27 80 00       	push   $0x8027df
  800ab9:	6a 23                	push   $0x23
  800abb:	68 fc 27 80 00       	push   $0x8027fc
  800ac0:	e8 12 15 00 00       	call   801fd7 <_panic>

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
  800b35:	68 df 27 80 00       	push   $0x8027df
  800b3a:	6a 23                	push   $0x23
  800b3c:	68 fc 27 80 00       	push   $0x8027fc
  800b41:	e8 91 14 00 00       	call   801fd7 <_panic>

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
  800b77:	68 df 27 80 00       	push   $0x8027df
  800b7c:	6a 23                	push   $0x23
  800b7e:	68 fc 27 80 00       	push   $0x8027fc
  800b83:	e8 4f 14 00 00       	call   801fd7 <_panic>

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
  800bb9:	68 df 27 80 00       	push   $0x8027df
  800bbe:	6a 23                	push   $0x23
  800bc0:	68 fc 27 80 00       	push   $0x8027fc
  800bc5:	e8 0d 14 00 00       	call   801fd7 <_panic>

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
  800bfb:	68 df 27 80 00       	push   $0x8027df
  800c00:	6a 23                	push   $0x23
  800c02:	68 fc 27 80 00       	push   $0x8027fc
  800c07:	e8 cb 13 00 00       	call   801fd7 <_panic>

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
  800c3d:	68 df 27 80 00       	push   $0x8027df
  800c42:	6a 23                	push   $0x23
  800c44:	68 fc 27 80 00       	push   $0x8027fc
  800c49:	e8 89 13 00 00       	call   801fd7 <_panic>
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
  800c7f:	68 df 27 80 00       	push   $0x8027df
  800c84:	6a 23                	push   $0x23
  800c86:	68 fc 27 80 00       	push   $0x8027fc
  800c8b:	e8 47 13 00 00       	call   801fd7 <_panic>

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
  800ce3:	68 df 27 80 00       	push   $0x8027df
  800ce8:	6a 23                	push   $0x23
  800cea:	68 fc 27 80 00       	push   $0x8027fc
  800cef:	e8 e3 12 00 00       	call   801fd7 <_panic>

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
  800d82:	68 0a 28 80 00       	push   $0x80280a
  800d87:	6a 1f                	push   $0x1f
  800d89:	68 1a 28 80 00       	push   $0x80281a
  800d8e:	e8 44 12 00 00       	call   801fd7 <_panic>
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
  800dac:	68 25 28 80 00       	push   $0x802825
  800db1:	6a 2d                	push   $0x2d
  800db3:	68 1a 28 80 00       	push   $0x80281a
  800db8:	e8 1a 12 00 00       	call   801fd7 <_panic>
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
  800df4:	68 25 28 80 00       	push   $0x802825
  800df9:	6a 34                	push   $0x34
  800dfb:	68 1a 28 80 00       	push   $0x80281a
  800e00:	e8 d2 11 00 00       	call   801fd7 <_panic>
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
  800e1c:	68 25 28 80 00       	push   $0x802825
  800e21:	6a 38                	push   $0x38
  800e23:	68 1a 28 80 00       	push   $0x80281a
  800e28:	e8 aa 11 00 00       	call   801fd7 <_panic>
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
  800e40:	e8 d8 11 00 00       	call   80201d <set_pgfault_handler>
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
  800e59:	68 3e 28 80 00       	push   $0x80283e
  800e5e:	68 85 00 00 00       	push   $0x85
  800e63:	68 1a 28 80 00       	push   $0x80281a
  800e68:	e8 6a 11 00 00       	call   801fd7 <_panic>
  800e6d:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800e6f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e73:	75 24                	jne    800e99 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e75:	e8 53 fc ff ff       	call   800acd <sys_getenvid>
  800e7a:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e7f:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  800f15:	68 4c 28 80 00       	push   $0x80284c
  800f1a:	6a 55                	push   $0x55
  800f1c:	68 1a 28 80 00       	push   $0x80281a
  800f21:	e8 b1 10 00 00       	call   801fd7 <_panic>
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
  800f5a:	68 4c 28 80 00       	push   $0x80284c
  800f5f:	6a 5c                	push   $0x5c
  800f61:	68 1a 28 80 00       	push   $0x80281a
  800f66:	e8 6c 10 00 00       	call   801fd7 <_panic>
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
  800f88:	68 4c 28 80 00       	push   $0x80284c
  800f8d:	6a 60                	push   $0x60
  800f8f:	68 1a 28 80 00       	push   $0x80281a
  800f94:	e8 3e 10 00 00       	call   801fd7 <_panic>
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
  800fb2:	68 4c 28 80 00       	push   $0x80284c
  800fb7:	6a 65                	push   $0x65
  800fb9:	68 1a 28 80 00       	push   $0x80281a
  800fbe:	e8 14 10 00 00       	call   801fd7 <_panic>
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
  800fda:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
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
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80100f:	55                   	push   %ebp
  801010:	89 e5                	mov    %esp,%ebp
  801012:	56                   	push   %esi
  801013:	53                   	push   %ebx
  801014:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801017:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  80101d:	83 ec 08             	sub    $0x8,%esp
  801020:	53                   	push   %ebx
  801021:	68 dc 28 80 00       	push   $0x8028dc
  801026:	e8 58 f1 ff ff       	call   800183 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80102b:	c7 04 24 b6 00 80 00 	movl   $0x8000b6,(%esp)
  801032:	e8 c5 fc ff ff       	call   800cfc <sys_thread_create>
  801037:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801039:	83 c4 08             	add    $0x8,%esp
  80103c:	53                   	push   %ebx
  80103d:	68 dc 28 80 00       	push   $0x8028dc
  801042:	e8 3c f1 ff ff       	call   800183 <cprintf>
	return id;
}
  801047:	89 f0                	mov    %esi,%eax
  801049:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80104c:	5b                   	pop    %ebx
  80104d:	5e                   	pop    %esi
  80104e:	5d                   	pop    %ebp
  80104f:	c3                   	ret    

00801050 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
  801053:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  801056:	ff 75 08             	pushl  0x8(%ebp)
  801059:	e8 be fc ff ff       	call   800d1c <sys_thread_free>
}
  80105e:	83 c4 10             	add    $0x10,%esp
  801061:	c9                   	leave  
  801062:	c3                   	ret    

00801063 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  801063:	55                   	push   %ebp
  801064:	89 e5                	mov    %esp,%ebp
  801066:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  801069:	ff 75 08             	pushl  0x8(%ebp)
  80106c:	e8 cb fc ff ff       	call   800d3c <sys_thread_join>
}
  801071:	83 c4 10             	add    $0x10,%esp
  801074:	c9                   	leave  
  801075:	c3                   	ret    

00801076 <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	56                   	push   %esi
  80107a:	53                   	push   %ebx
  80107b:	8b 75 08             	mov    0x8(%ebp),%esi
  80107e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  801081:	83 ec 04             	sub    $0x4,%esp
  801084:	6a 07                	push   $0x7
  801086:	6a 00                	push   $0x0
  801088:	56                   	push   %esi
  801089:	e8 7d fa ff ff       	call   800b0b <sys_page_alloc>
	if (r < 0) {
  80108e:	83 c4 10             	add    $0x10,%esp
  801091:	85 c0                	test   %eax,%eax
  801093:	79 15                	jns    8010aa <queue_append+0x34>
		panic("%e\n", r);
  801095:	50                   	push   %eax
  801096:	68 d8 28 80 00       	push   $0x8028d8
  80109b:	68 c4 00 00 00       	push   $0xc4
  8010a0:	68 1a 28 80 00       	push   $0x80281a
  8010a5:	e8 2d 0f 00 00       	call   801fd7 <_panic>
	}	
	wt->envid = envid;
  8010aa:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  8010b0:	83 ec 04             	sub    $0x4,%esp
  8010b3:	ff 33                	pushl  (%ebx)
  8010b5:	56                   	push   %esi
  8010b6:	68 00 29 80 00       	push   $0x802900
  8010bb:	e8 c3 f0 ff ff       	call   800183 <cprintf>
	if (queue->first == NULL) {
  8010c0:	83 c4 10             	add    $0x10,%esp
  8010c3:	83 3b 00             	cmpl   $0x0,(%ebx)
  8010c6:	75 29                	jne    8010f1 <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  8010c8:	83 ec 0c             	sub    $0xc,%esp
  8010cb:	68 62 28 80 00       	push   $0x802862
  8010d0:	e8 ae f0 ff ff       	call   800183 <cprintf>
		queue->first = wt;
  8010d5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  8010db:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  8010e2:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8010e9:	00 00 00 
  8010ec:	83 c4 10             	add    $0x10,%esp
  8010ef:	eb 2b                	jmp    80111c <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  8010f1:	83 ec 0c             	sub    $0xc,%esp
  8010f4:	68 7c 28 80 00       	push   $0x80287c
  8010f9:	e8 85 f0 ff ff       	call   800183 <cprintf>
		queue->last->next = wt;
  8010fe:	8b 43 04             	mov    0x4(%ebx),%eax
  801101:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  801108:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80110f:	00 00 00 
		queue->last = wt;
  801112:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  801119:	83 c4 10             	add    $0x10,%esp
	}
}
  80111c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80111f:	5b                   	pop    %ebx
  801120:	5e                   	pop    %esi
  801121:	5d                   	pop    %ebp
  801122:	c3                   	ret    

00801123 <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  801123:	55                   	push   %ebp
  801124:	89 e5                	mov    %esp,%ebp
  801126:	53                   	push   %ebx
  801127:	83 ec 04             	sub    $0x4,%esp
  80112a:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  80112d:	8b 02                	mov    (%edx),%eax
  80112f:	85 c0                	test   %eax,%eax
  801131:	75 17                	jne    80114a <queue_pop+0x27>
		panic("queue empty!\n");
  801133:	83 ec 04             	sub    $0x4,%esp
  801136:	68 9a 28 80 00       	push   $0x80289a
  80113b:	68 d8 00 00 00       	push   $0xd8
  801140:	68 1a 28 80 00       	push   $0x80281a
  801145:	e8 8d 0e 00 00       	call   801fd7 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  80114a:	8b 48 04             	mov    0x4(%eax),%ecx
  80114d:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  80114f:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  801151:	83 ec 08             	sub    $0x8,%esp
  801154:	53                   	push   %ebx
  801155:	68 a8 28 80 00       	push   $0x8028a8
  80115a:	e8 24 f0 ff ff       	call   800183 <cprintf>
	return envid;
}
  80115f:	89 d8                	mov    %ebx,%eax
  801161:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801164:	c9                   	leave  
  801165:	c3                   	ret    

00801166 <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	53                   	push   %ebx
  80116a:	83 ec 04             	sub    $0x4,%esp
  80116d:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  801170:	b8 01 00 00 00       	mov    $0x1,%eax
  801175:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801178:	85 c0                	test   %eax,%eax
  80117a:	74 5a                	je     8011d6 <mutex_lock+0x70>
  80117c:	8b 43 04             	mov    0x4(%ebx),%eax
  80117f:	83 38 00             	cmpl   $0x0,(%eax)
  801182:	75 52                	jne    8011d6 <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  801184:	83 ec 0c             	sub    $0xc,%esp
  801187:	68 28 29 80 00       	push   $0x802928
  80118c:	e8 f2 ef ff ff       	call   800183 <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  801191:	8b 5b 04             	mov    0x4(%ebx),%ebx
  801194:	e8 34 f9 ff ff       	call   800acd <sys_getenvid>
  801199:	83 c4 08             	add    $0x8,%esp
  80119c:	53                   	push   %ebx
  80119d:	50                   	push   %eax
  80119e:	e8 d3 fe ff ff       	call   801076 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  8011a3:	e8 25 f9 ff ff       	call   800acd <sys_getenvid>
  8011a8:	83 c4 08             	add    $0x8,%esp
  8011ab:	6a 04                	push   $0x4
  8011ad:	50                   	push   %eax
  8011ae:	e8 1f fa ff ff       	call   800bd2 <sys_env_set_status>
		if (r < 0) {
  8011b3:	83 c4 10             	add    $0x10,%esp
  8011b6:	85 c0                	test   %eax,%eax
  8011b8:	79 15                	jns    8011cf <mutex_lock+0x69>
			panic("%e\n", r);
  8011ba:	50                   	push   %eax
  8011bb:	68 d8 28 80 00       	push   $0x8028d8
  8011c0:	68 eb 00 00 00       	push   $0xeb
  8011c5:	68 1a 28 80 00       	push   $0x80281a
  8011ca:	e8 08 0e 00 00       	call   801fd7 <_panic>
		}
		sys_yield();
  8011cf:	e8 18 f9 ff ff       	call   800aec <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8011d4:	eb 18                	jmp    8011ee <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  8011d6:	83 ec 0c             	sub    $0xc,%esp
  8011d9:	68 48 29 80 00       	push   $0x802948
  8011de:	e8 a0 ef ff ff       	call   800183 <cprintf>
	mtx->owner = sys_getenvid();}
  8011e3:	e8 e5 f8 ff ff       	call   800acd <sys_getenvid>
  8011e8:	89 43 08             	mov    %eax,0x8(%ebx)
  8011eb:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  8011ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f1:	c9                   	leave  
  8011f2:	c3                   	ret    

008011f3 <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	53                   	push   %ebx
  8011f7:	83 ec 04             	sub    $0x4,%esp
  8011fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8011fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801202:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  801205:	8b 43 04             	mov    0x4(%ebx),%eax
  801208:	83 38 00             	cmpl   $0x0,(%eax)
  80120b:	74 33                	je     801240 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  80120d:	83 ec 0c             	sub    $0xc,%esp
  801210:	50                   	push   %eax
  801211:	e8 0d ff ff ff       	call   801123 <queue_pop>
  801216:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  801219:	83 c4 08             	add    $0x8,%esp
  80121c:	6a 02                	push   $0x2
  80121e:	50                   	push   %eax
  80121f:	e8 ae f9 ff ff       	call   800bd2 <sys_env_set_status>
		if (r < 0) {
  801224:	83 c4 10             	add    $0x10,%esp
  801227:	85 c0                	test   %eax,%eax
  801229:	79 15                	jns    801240 <mutex_unlock+0x4d>
			panic("%e\n", r);
  80122b:	50                   	push   %eax
  80122c:	68 d8 28 80 00       	push   $0x8028d8
  801231:	68 00 01 00 00       	push   $0x100
  801236:	68 1a 28 80 00       	push   $0x80281a
  80123b:	e8 97 0d 00 00       	call   801fd7 <_panic>
		}
	}

	asm volatile("pause");
  801240:	f3 90                	pause  
	//sys_yield();
}
  801242:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801245:	c9                   	leave  
  801246:	c3                   	ret    

00801247 <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  801247:	55                   	push   %ebp
  801248:	89 e5                	mov    %esp,%ebp
  80124a:	53                   	push   %ebx
  80124b:	83 ec 04             	sub    $0x4,%esp
  80124e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  801251:	e8 77 f8 ff ff       	call   800acd <sys_getenvid>
  801256:	83 ec 04             	sub    $0x4,%esp
  801259:	6a 07                	push   $0x7
  80125b:	53                   	push   %ebx
  80125c:	50                   	push   %eax
  80125d:	e8 a9 f8 ff ff       	call   800b0b <sys_page_alloc>
  801262:	83 c4 10             	add    $0x10,%esp
  801265:	85 c0                	test   %eax,%eax
  801267:	79 15                	jns    80127e <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  801269:	50                   	push   %eax
  80126a:	68 c3 28 80 00       	push   $0x8028c3
  80126f:	68 0d 01 00 00       	push   $0x10d
  801274:	68 1a 28 80 00       	push   $0x80281a
  801279:	e8 59 0d 00 00       	call   801fd7 <_panic>
	}	
	mtx->locked = 0;
  80127e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  801284:	8b 43 04             	mov    0x4(%ebx),%eax
  801287:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  80128d:	8b 43 04             	mov    0x4(%ebx),%eax
  801290:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  801297:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  80129e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a1:	c9                   	leave  
  8012a2:	c3                   	ret    

008012a3 <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  8012a3:	55                   	push   %ebp
  8012a4:	89 e5                	mov    %esp,%ebp
  8012a6:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  8012a9:	e8 1f f8 ff ff       	call   800acd <sys_getenvid>
  8012ae:	83 ec 08             	sub    $0x8,%esp
  8012b1:	ff 75 08             	pushl  0x8(%ebp)
  8012b4:	50                   	push   %eax
  8012b5:	e8 d6 f8 ff ff       	call   800b90 <sys_page_unmap>
	if (r < 0) {
  8012ba:	83 c4 10             	add    $0x10,%esp
  8012bd:	85 c0                	test   %eax,%eax
  8012bf:	79 15                	jns    8012d6 <mutex_destroy+0x33>
		panic("%e\n", r);
  8012c1:	50                   	push   %eax
  8012c2:	68 d8 28 80 00       	push   $0x8028d8
  8012c7:	68 1a 01 00 00       	push   $0x11a
  8012cc:	68 1a 28 80 00       	push   $0x80281a
  8012d1:	e8 01 0d 00 00       	call   801fd7 <_panic>
	}
}
  8012d6:	c9                   	leave  
  8012d7:	c3                   	ret    

008012d8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012d8:	55                   	push   %ebp
  8012d9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012db:	8b 45 08             	mov    0x8(%ebp),%eax
  8012de:	05 00 00 00 30       	add    $0x30000000,%eax
  8012e3:	c1 e8 0c             	shr    $0xc,%eax
}
  8012e6:	5d                   	pop    %ebp
  8012e7:	c3                   	ret    

008012e8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012e8:	55                   	push   %ebp
  8012e9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ee:	05 00 00 00 30       	add    $0x30000000,%eax
  8012f3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012f8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012fd:	5d                   	pop    %ebp
  8012fe:	c3                   	ret    

008012ff <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012ff:	55                   	push   %ebp
  801300:	89 e5                	mov    %esp,%ebp
  801302:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801305:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80130a:	89 c2                	mov    %eax,%edx
  80130c:	c1 ea 16             	shr    $0x16,%edx
  80130f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801316:	f6 c2 01             	test   $0x1,%dl
  801319:	74 11                	je     80132c <fd_alloc+0x2d>
  80131b:	89 c2                	mov    %eax,%edx
  80131d:	c1 ea 0c             	shr    $0xc,%edx
  801320:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801327:	f6 c2 01             	test   $0x1,%dl
  80132a:	75 09                	jne    801335 <fd_alloc+0x36>
			*fd_store = fd;
  80132c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80132e:	b8 00 00 00 00       	mov    $0x0,%eax
  801333:	eb 17                	jmp    80134c <fd_alloc+0x4d>
  801335:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80133a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80133f:	75 c9                	jne    80130a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801341:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801347:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80134c:	5d                   	pop    %ebp
  80134d:	c3                   	ret    

0080134e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80134e:	55                   	push   %ebp
  80134f:	89 e5                	mov    %esp,%ebp
  801351:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801354:	83 f8 1f             	cmp    $0x1f,%eax
  801357:	77 36                	ja     80138f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801359:	c1 e0 0c             	shl    $0xc,%eax
  80135c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801361:	89 c2                	mov    %eax,%edx
  801363:	c1 ea 16             	shr    $0x16,%edx
  801366:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80136d:	f6 c2 01             	test   $0x1,%dl
  801370:	74 24                	je     801396 <fd_lookup+0x48>
  801372:	89 c2                	mov    %eax,%edx
  801374:	c1 ea 0c             	shr    $0xc,%edx
  801377:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80137e:	f6 c2 01             	test   $0x1,%dl
  801381:	74 1a                	je     80139d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801383:	8b 55 0c             	mov    0xc(%ebp),%edx
  801386:	89 02                	mov    %eax,(%edx)
	return 0;
  801388:	b8 00 00 00 00       	mov    $0x0,%eax
  80138d:	eb 13                	jmp    8013a2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80138f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801394:	eb 0c                	jmp    8013a2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801396:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80139b:	eb 05                	jmp    8013a2 <fd_lookup+0x54>
  80139d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013a2:	5d                   	pop    %ebp
  8013a3:	c3                   	ret    

008013a4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013a4:	55                   	push   %ebp
  8013a5:	89 e5                	mov    %esp,%ebp
  8013a7:	83 ec 08             	sub    $0x8,%esp
  8013aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013ad:	ba e4 29 80 00       	mov    $0x8029e4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013b2:	eb 13                	jmp    8013c7 <dev_lookup+0x23>
  8013b4:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013b7:	39 08                	cmp    %ecx,(%eax)
  8013b9:	75 0c                	jne    8013c7 <dev_lookup+0x23>
			*dev = devtab[i];
  8013bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013be:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c5:	eb 31                	jmp    8013f8 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013c7:	8b 02                	mov    (%edx),%eax
  8013c9:	85 c0                	test   %eax,%eax
  8013cb:	75 e7                	jne    8013b4 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013cd:	a1 04 40 80 00       	mov    0x804004,%eax
  8013d2:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8013d8:	83 ec 04             	sub    $0x4,%esp
  8013db:	51                   	push   %ecx
  8013dc:	50                   	push   %eax
  8013dd:	68 68 29 80 00       	push   $0x802968
  8013e2:	e8 9c ed ff ff       	call   800183 <cprintf>
	*dev = 0;
  8013e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ea:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013f0:	83 c4 10             	add    $0x10,%esp
  8013f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013f8:	c9                   	leave  
  8013f9:	c3                   	ret    

008013fa <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013fa:	55                   	push   %ebp
  8013fb:	89 e5                	mov    %esp,%ebp
  8013fd:	56                   	push   %esi
  8013fe:	53                   	push   %ebx
  8013ff:	83 ec 10             	sub    $0x10,%esp
  801402:	8b 75 08             	mov    0x8(%ebp),%esi
  801405:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801408:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80140b:	50                   	push   %eax
  80140c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801412:	c1 e8 0c             	shr    $0xc,%eax
  801415:	50                   	push   %eax
  801416:	e8 33 ff ff ff       	call   80134e <fd_lookup>
  80141b:	83 c4 08             	add    $0x8,%esp
  80141e:	85 c0                	test   %eax,%eax
  801420:	78 05                	js     801427 <fd_close+0x2d>
	    || fd != fd2)
  801422:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801425:	74 0c                	je     801433 <fd_close+0x39>
		return (must_exist ? r : 0);
  801427:	84 db                	test   %bl,%bl
  801429:	ba 00 00 00 00       	mov    $0x0,%edx
  80142e:	0f 44 c2             	cmove  %edx,%eax
  801431:	eb 41                	jmp    801474 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801433:	83 ec 08             	sub    $0x8,%esp
  801436:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801439:	50                   	push   %eax
  80143a:	ff 36                	pushl  (%esi)
  80143c:	e8 63 ff ff ff       	call   8013a4 <dev_lookup>
  801441:	89 c3                	mov    %eax,%ebx
  801443:	83 c4 10             	add    $0x10,%esp
  801446:	85 c0                	test   %eax,%eax
  801448:	78 1a                	js     801464 <fd_close+0x6a>
		if (dev->dev_close)
  80144a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801450:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801455:	85 c0                	test   %eax,%eax
  801457:	74 0b                	je     801464 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801459:	83 ec 0c             	sub    $0xc,%esp
  80145c:	56                   	push   %esi
  80145d:	ff d0                	call   *%eax
  80145f:	89 c3                	mov    %eax,%ebx
  801461:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801464:	83 ec 08             	sub    $0x8,%esp
  801467:	56                   	push   %esi
  801468:	6a 00                	push   $0x0
  80146a:	e8 21 f7 ff ff       	call   800b90 <sys_page_unmap>
	return r;
  80146f:	83 c4 10             	add    $0x10,%esp
  801472:	89 d8                	mov    %ebx,%eax
}
  801474:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801477:	5b                   	pop    %ebx
  801478:	5e                   	pop    %esi
  801479:	5d                   	pop    %ebp
  80147a:	c3                   	ret    

0080147b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
  80147e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801481:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801484:	50                   	push   %eax
  801485:	ff 75 08             	pushl  0x8(%ebp)
  801488:	e8 c1 fe ff ff       	call   80134e <fd_lookup>
  80148d:	83 c4 08             	add    $0x8,%esp
  801490:	85 c0                	test   %eax,%eax
  801492:	78 10                	js     8014a4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801494:	83 ec 08             	sub    $0x8,%esp
  801497:	6a 01                	push   $0x1
  801499:	ff 75 f4             	pushl  -0xc(%ebp)
  80149c:	e8 59 ff ff ff       	call   8013fa <fd_close>
  8014a1:	83 c4 10             	add    $0x10,%esp
}
  8014a4:	c9                   	leave  
  8014a5:	c3                   	ret    

008014a6 <close_all>:

void
close_all(void)
{
  8014a6:	55                   	push   %ebp
  8014a7:	89 e5                	mov    %esp,%ebp
  8014a9:	53                   	push   %ebx
  8014aa:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014ad:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014b2:	83 ec 0c             	sub    $0xc,%esp
  8014b5:	53                   	push   %ebx
  8014b6:	e8 c0 ff ff ff       	call   80147b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014bb:	83 c3 01             	add    $0x1,%ebx
  8014be:	83 c4 10             	add    $0x10,%esp
  8014c1:	83 fb 20             	cmp    $0x20,%ebx
  8014c4:	75 ec                	jne    8014b2 <close_all+0xc>
		close(i);
}
  8014c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c9:	c9                   	leave  
  8014ca:	c3                   	ret    

008014cb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014cb:	55                   	push   %ebp
  8014cc:	89 e5                	mov    %esp,%ebp
  8014ce:	57                   	push   %edi
  8014cf:	56                   	push   %esi
  8014d0:	53                   	push   %ebx
  8014d1:	83 ec 2c             	sub    $0x2c,%esp
  8014d4:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014d7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014da:	50                   	push   %eax
  8014db:	ff 75 08             	pushl  0x8(%ebp)
  8014de:	e8 6b fe ff ff       	call   80134e <fd_lookup>
  8014e3:	83 c4 08             	add    $0x8,%esp
  8014e6:	85 c0                	test   %eax,%eax
  8014e8:	0f 88 c1 00 00 00    	js     8015af <dup+0xe4>
		return r;
	close(newfdnum);
  8014ee:	83 ec 0c             	sub    $0xc,%esp
  8014f1:	56                   	push   %esi
  8014f2:	e8 84 ff ff ff       	call   80147b <close>

	newfd = INDEX2FD(newfdnum);
  8014f7:	89 f3                	mov    %esi,%ebx
  8014f9:	c1 e3 0c             	shl    $0xc,%ebx
  8014fc:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801502:	83 c4 04             	add    $0x4,%esp
  801505:	ff 75 e4             	pushl  -0x1c(%ebp)
  801508:	e8 db fd ff ff       	call   8012e8 <fd2data>
  80150d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80150f:	89 1c 24             	mov    %ebx,(%esp)
  801512:	e8 d1 fd ff ff       	call   8012e8 <fd2data>
  801517:	83 c4 10             	add    $0x10,%esp
  80151a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80151d:	89 f8                	mov    %edi,%eax
  80151f:	c1 e8 16             	shr    $0x16,%eax
  801522:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801529:	a8 01                	test   $0x1,%al
  80152b:	74 37                	je     801564 <dup+0x99>
  80152d:	89 f8                	mov    %edi,%eax
  80152f:	c1 e8 0c             	shr    $0xc,%eax
  801532:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801539:	f6 c2 01             	test   $0x1,%dl
  80153c:	74 26                	je     801564 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80153e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801545:	83 ec 0c             	sub    $0xc,%esp
  801548:	25 07 0e 00 00       	and    $0xe07,%eax
  80154d:	50                   	push   %eax
  80154e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801551:	6a 00                	push   $0x0
  801553:	57                   	push   %edi
  801554:	6a 00                	push   $0x0
  801556:	e8 f3 f5 ff ff       	call   800b4e <sys_page_map>
  80155b:	89 c7                	mov    %eax,%edi
  80155d:	83 c4 20             	add    $0x20,%esp
  801560:	85 c0                	test   %eax,%eax
  801562:	78 2e                	js     801592 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801564:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801567:	89 d0                	mov    %edx,%eax
  801569:	c1 e8 0c             	shr    $0xc,%eax
  80156c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801573:	83 ec 0c             	sub    $0xc,%esp
  801576:	25 07 0e 00 00       	and    $0xe07,%eax
  80157b:	50                   	push   %eax
  80157c:	53                   	push   %ebx
  80157d:	6a 00                	push   $0x0
  80157f:	52                   	push   %edx
  801580:	6a 00                	push   $0x0
  801582:	e8 c7 f5 ff ff       	call   800b4e <sys_page_map>
  801587:	89 c7                	mov    %eax,%edi
  801589:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80158c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80158e:	85 ff                	test   %edi,%edi
  801590:	79 1d                	jns    8015af <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801592:	83 ec 08             	sub    $0x8,%esp
  801595:	53                   	push   %ebx
  801596:	6a 00                	push   $0x0
  801598:	e8 f3 f5 ff ff       	call   800b90 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80159d:	83 c4 08             	add    $0x8,%esp
  8015a0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015a3:	6a 00                	push   $0x0
  8015a5:	e8 e6 f5 ff ff       	call   800b90 <sys_page_unmap>
	return r;
  8015aa:	83 c4 10             	add    $0x10,%esp
  8015ad:	89 f8                	mov    %edi,%eax
}
  8015af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015b2:	5b                   	pop    %ebx
  8015b3:	5e                   	pop    %esi
  8015b4:	5f                   	pop    %edi
  8015b5:	5d                   	pop    %ebp
  8015b6:	c3                   	ret    

008015b7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015b7:	55                   	push   %ebp
  8015b8:	89 e5                	mov    %esp,%ebp
  8015ba:	53                   	push   %ebx
  8015bb:	83 ec 14             	sub    $0x14,%esp
  8015be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c4:	50                   	push   %eax
  8015c5:	53                   	push   %ebx
  8015c6:	e8 83 fd ff ff       	call   80134e <fd_lookup>
  8015cb:	83 c4 08             	add    $0x8,%esp
  8015ce:	89 c2                	mov    %eax,%edx
  8015d0:	85 c0                	test   %eax,%eax
  8015d2:	78 70                	js     801644 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d4:	83 ec 08             	sub    $0x8,%esp
  8015d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015da:	50                   	push   %eax
  8015db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015de:	ff 30                	pushl  (%eax)
  8015e0:	e8 bf fd ff ff       	call   8013a4 <dev_lookup>
  8015e5:	83 c4 10             	add    $0x10,%esp
  8015e8:	85 c0                	test   %eax,%eax
  8015ea:	78 4f                	js     80163b <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015ec:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015ef:	8b 42 08             	mov    0x8(%edx),%eax
  8015f2:	83 e0 03             	and    $0x3,%eax
  8015f5:	83 f8 01             	cmp    $0x1,%eax
  8015f8:	75 24                	jne    80161e <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015fa:	a1 04 40 80 00       	mov    0x804004,%eax
  8015ff:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801605:	83 ec 04             	sub    $0x4,%esp
  801608:	53                   	push   %ebx
  801609:	50                   	push   %eax
  80160a:	68 a9 29 80 00       	push   $0x8029a9
  80160f:	e8 6f eb ff ff       	call   800183 <cprintf>
		return -E_INVAL;
  801614:	83 c4 10             	add    $0x10,%esp
  801617:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80161c:	eb 26                	jmp    801644 <read+0x8d>
	}
	if (!dev->dev_read)
  80161e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801621:	8b 40 08             	mov    0x8(%eax),%eax
  801624:	85 c0                	test   %eax,%eax
  801626:	74 17                	je     80163f <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801628:	83 ec 04             	sub    $0x4,%esp
  80162b:	ff 75 10             	pushl  0x10(%ebp)
  80162e:	ff 75 0c             	pushl  0xc(%ebp)
  801631:	52                   	push   %edx
  801632:	ff d0                	call   *%eax
  801634:	89 c2                	mov    %eax,%edx
  801636:	83 c4 10             	add    $0x10,%esp
  801639:	eb 09                	jmp    801644 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80163b:	89 c2                	mov    %eax,%edx
  80163d:	eb 05                	jmp    801644 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80163f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801644:	89 d0                	mov    %edx,%eax
  801646:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801649:	c9                   	leave  
  80164a:	c3                   	ret    

0080164b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80164b:	55                   	push   %ebp
  80164c:	89 e5                	mov    %esp,%ebp
  80164e:	57                   	push   %edi
  80164f:	56                   	push   %esi
  801650:	53                   	push   %ebx
  801651:	83 ec 0c             	sub    $0xc,%esp
  801654:	8b 7d 08             	mov    0x8(%ebp),%edi
  801657:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80165a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80165f:	eb 21                	jmp    801682 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801661:	83 ec 04             	sub    $0x4,%esp
  801664:	89 f0                	mov    %esi,%eax
  801666:	29 d8                	sub    %ebx,%eax
  801668:	50                   	push   %eax
  801669:	89 d8                	mov    %ebx,%eax
  80166b:	03 45 0c             	add    0xc(%ebp),%eax
  80166e:	50                   	push   %eax
  80166f:	57                   	push   %edi
  801670:	e8 42 ff ff ff       	call   8015b7 <read>
		if (m < 0)
  801675:	83 c4 10             	add    $0x10,%esp
  801678:	85 c0                	test   %eax,%eax
  80167a:	78 10                	js     80168c <readn+0x41>
			return m;
		if (m == 0)
  80167c:	85 c0                	test   %eax,%eax
  80167e:	74 0a                	je     80168a <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801680:	01 c3                	add    %eax,%ebx
  801682:	39 f3                	cmp    %esi,%ebx
  801684:	72 db                	jb     801661 <readn+0x16>
  801686:	89 d8                	mov    %ebx,%eax
  801688:	eb 02                	jmp    80168c <readn+0x41>
  80168a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80168c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80168f:	5b                   	pop    %ebx
  801690:	5e                   	pop    %esi
  801691:	5f                   	pop    %edi
  801692:	5d                   	pop    %ebp
  801693:	c3                   	ret    

00801694 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801694:	55                   	push   %ebp
  801695:	89 e5                	mov    %esp,%ebp
  801697:	53                   	push   %ebx
  801698:	83 ec 14             	sub    $0x14,%esp
  80169b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80169e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016a1:	50                   	push   %eax
  8016a2:	53                   	push   %ebx
  8016a3:	e8 a6 fc ff ff       	call   80134e <fd_lookup>
  8016a8:	83 c4 08             	add    $0x8,%esp
  8016ab:	89 c2                	mov    %eax,%edx
  8016ad:	85 c0                	test   %eax,%eax
  8016af:	78 6b                	js     80171c <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b1:	83 ec 08             	sub    $0x8,%esp
  8016b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b7:	50                   	push   %eax
  8016b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016bb:	ff 30                	pushl  (%eax)
  8016bd:	e8 e2 fc ff ff       	call   8013a4 <dev_lookup>
  8016c2:	83 c4 10             	add    $0x10,%esp
  8016c5:	85 c0                	test   %eax,%eax
  8016c7:	78 4a                	js     801713 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016cc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016d0:	75 24                	jne    8016f6 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016d2:	a1 04 40 80 00       	mov    0x804004,%eax
  8016d7:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8016dd:	83 ec 04             	sub    $0x4,%esp
  8016e0:	53                   	push   %ebx
  8016e1:	50                   	push   %eax
  8016e2:	68 c5 29 80 00       	push   $0x8029c5
  8016e7:	e8 97 ea ff ff       	call   800183 <cprintf>
		return -E_INVAL;
  8016ec:	83 c4 10             	add    $0x10,%esp
  8016ef:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016f4:	eb 26                	jmp    80171c <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016f9:	8b 52 0c             	mov    0xc(%edx),%edx
  8016fc:	85 d2                	test   %edx,%edx
  8016fe:	74 17                	je     801717 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801700:	83 ec 04             	sub    $0x4,%esp
  801703:	ff 75 10             	pushl  0x10(%ebp)
  801706:	ff 75 0c             	pushl  0xc(%ebp)
  801709:	50                   	push   %eax
  80170a:	ff d2                	call   *%edx
  80170c:	89 c2                	mov    %eax,%edx
  80170e:	83 c4 10             	add    $0x10,%esp
  801711:	eb 09                	jmp    80171c <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801713:	89 c2                	mov    %eax,%edx
  801715:	eb 05                	jmp    80171c <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801717:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80171c:	89 d0                	mov    %edx,%eax
  80171e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801721:	c9                   	leave  
  801722:	c3                   	ret    

00801723 <seek>:

int
seek(int fdnum, off_t offset)
{
  801723:	55                   	push   %ebp
  801724:	89 e5                	mov    %esp,%ebp
  801726:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801729:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80172c:	50                   	push   %eax
  80172d:	ff 75 08             	pushl  0x8(%ebp)
  801730:	e8 19 fc ff ff       	call   80134e <fd_lookup>
  801735:	83 c4 08             	add    $0x8,%esp
  801738:	85 c0                	test   %eax,%eax
  80173a:	78 0e                	js     80174a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80173c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80173f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801742:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801745:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80174a:	c9                   	leave  
  80174b:	c3                   	ret    

0080174c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	53                   	push   %ebx
  801750:	83 ec 14             	sub    $0x14,%esp
  801753:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801756:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801759:	50                   	push   %eax
  80175a:	53                   	push   %ebx
  80175b:	e8 ee fb ff ff       	call   80134e <fd_lookup>
  801760:	83 c4 08             	add    $0x8,%esp
  801763:	89 c2                	mov    %eax,%edx
  801765:	85 c0                	test   %eax,%eax
  801767:	78 68                	js     8017d1 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801769:	83 ec 08             	sub    $0x8,%esp
  80176c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80176f:	50                   	push   %eax
  801770:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801773:	ff 30                	pushl  (%eax)
  801775:	e8 2a fc ff ff       	call   8013a4 <dev_lookup>
  80177a:	83 c4 10             	add    $0x10,%esp
  80177d:	85 c0                	test   %eax,%eax
  80177f:	78 47                	js     8017c8 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801781:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801784:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801788:	75 24                	jne    8017ae <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80178a:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80178f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801795:	83 ec 04             	sub    $0x4,%esp
  801798:	53                   	push   %ebx
  801799:	50                   	push   %eax
  80179a:	68 88 29 80 00       	push   $0x802988
  80179f:	e8 df e9 ff ff       	call   800183 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017a4:	83 c4 10             	add    $0x10,%esp
  8017a7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017ac:	eb 23                	jmp    8017d1 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  8017ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017b1:	8b 52 18             	mov    0x18(%edx),%edx
  8017b4:	85 d2                	test   %edx,%edx
  8017b6:	74 14                	je     8017cc <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017b8:	83 ec 08             	sub    $0x8,%esp
  8017bb:	ff 75 0c             	pushl  0xc(%ebp)
  8017be:	50                   	push   %eax
  8017bf:	ff d2                	call   *%edx
  8017c1:	89 c2                	mov    %eax,%edx
  8017c3:	83 c4 10             	add    $0x10,%esp
  8017c6:	eb 09                	jmp    8017d1 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c8:	89 c2                	mov    %eax,%edx
  8017ca:	eb 05                	jmp    8017d1 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017cc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017d1:	89 d0                	mov    %edx,%eax
  8017d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d6:	c9                   	leave  
  8017d7:	c3                   	ret    

008017d8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017d8:	55                   	push   %ebp
  8017d9:	89 e5                	mov    %esp,%ebp
  8017db:	53                   	push   %ebx
  8017dc:	83 ec 14             	sub    $0x14,%esp
  8017df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e5:	50                   	push   %eax
  8017e6:	ff 75 08             	pushl  0x8(%ebp)
  8017e9:	e8 60 fb ff ff       	call   80134e <fd_lookup>
  8017ee:	83 c4 08             	add    $0x8,%esp
  8017f1:	89 c2                	mov    %eax,%edx
  8017f3:	85 c0                	test   %eax,%eax
  8017f5:	78 58                	js     80184f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f7:	83 ec 08             	sub    $0x8,%esp
  8017fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017fd:	50                   	push   %eax
  8017fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801801:	ff 30                	pushl  (%eax)
  801803:	e8 9c fb ff ff       	call   8013a4 <dev_lookup>
  801808:	83 c4 10             	add    $0x10,%esp
  80180b:	85 c0                	test   %eax,%eax
  80180d:	78 37                	js     801846 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80180f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801812:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801816:	74 32                	je     80184a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801818:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80181b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801822:	00 00 00 
	stat->st_isdir = 0;
  801825:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80182c:	00 00 00 
	stat->st_dev = dev;
  80182f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801835:	83 ec 08             	sub    $0x8,%esp
  801838:	53                   	push   %ebx
  801839:	ff 75 f0             	pushl  -0x10(%ebp)
  80183c:	ff 50 14             	call   *0x14(%eax)
  80183f:	89 c2                	mov    %eax,%edx
  801841:	83 c4 10             	add    $0x10,%esp
  801844:	eb 09                	jmp    80184f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801846:	89 c2                	mov    %eax,%edx
  801848:	eb 05                	jmp    80184f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80184a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80184f:	89 d0                	mov    %edx,%eax
  801851:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801854:	c9                   	leave  
  801855:	c3                   	ret    

00801856 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801856:	55                   	push   %ebp
  801857:	89 e5                	mov    %esp,%ebp
  801859:	56                   	push   %esi
  80185a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80185b:	83 ec 08             	sub    $0x8,%esp
  80185e:	6a 00                	push   $0x0
  801860:	ff 75 08             	pushl  0x8(%ebp)
  801863:	e8 e3 01 00 00       	call   801a4b <open>
  801868:	89 c3                	mov    %eax,%ebx
  80186a:	83 c4 10             	add    $0x10,%esp
  80186d:	85 c0                	test   %eax,%eax
  80186f:	78 1b                	js     80188c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801871:	83 ec 08             	sub    $0x8,%esp
  801874:	ff 75 0c             	pushl  0xc(%ebp)
  801877:	50                   	push   %eax
  801878:	e8 5b ff ff ff       	call   8017d8 <fstat>
  80187d:	89 c6                	mov    %eax,%esi
	close(fd);
  80187f:	89 1c 24             	mov    %ebx,(%esp)
  801882:	e8 f4 fb ff ff       	call   80147b <close>
	return r;
  801887:	83 c4 10             	add    $0x10,%esp
  80188a:	89 f0                	mov    %esi,%eax
}
  80188c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80188f:	5b                   	pop    %ebx
  801890:	5e                   	pop    %esi
  801891:	5d                   	pop    %ebp
  801892:	c3                   	ret    

00801893 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801893:	55                   	push   %ebp
  801894:	89 e5                	mov    %esp,%ebp
  801896:	56                   	push   %esi
  801897:	53                   	push   %ebx
  801898:	89 c6                	mov    %eax,%esi
  80189a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80189c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018a3:	75 12                	jne    8018b7 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018a5:	83 ec 0c             	sub    $0xc,%esp
  8018a8:	6a 01                	push   $0x1
  8018aa:	e8 da 08 00 00       	call   802189 <ipc_find_env>
  8018af:	a3 00 40 80 00       	mov    %eax,0x804000
  8018b4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018b7:	6a 07                	push   $0x7
  8018b9:	68 00 50 80 00       	push   $0x805000
  8018be:	56                   	push   %esi
  8018bf:	ff 35 00 40 80 00    	pushl  0x804000
  8018c5:	e8 5d 08 00 00       	call   802127 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018ca:	83 c4 0c             	add    $0xc,%esp
  8018cd:	6a 00                	push   $0x0
  8018cf:	53                   	push   %ebx
  8018d0:	6a 00                	push   $0x0
  8018d2:	e8 d5 07 00 00       	call   8020ac <ipc_recv>
}
  8018d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018da:	5b                   	pop    %ebx
  8018db:	5e                   	pop    %esi
  8018dc:	5d                   	pop    %ebp
  8018dd:	c3                   	ret    

008018de <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018de:	55                   	push   %ebp
  8018df:	89 e5                	mov    %esp,%ebp
  8018e1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ea:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018f2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018fc:	b8 02 00 00 00       	mov    $0x2,%eax
  801901:	e8 8d ff ff ff       	call   801893 <fsipc>
}
  801906:	c9                   	leave  
  801907:	c3                   	ret    

00801908 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801908:	55                   	push   %ebp
  801909:	89 e5                	mov    %esp,%ebp
  80190b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80190e:	8b 45 08             	mov    0x8(%ebp),%eax
  801911:	8b 40 0c             	mov    0xc(%eax),%eax
  801914:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801919:	ba 00 00 00 00       	mov    $0x0,%edx
  80191e:	b8 06 00 00 00       	mov    $0x6,%eax
  801923:	e8 6b ff ff ff       	call   801893 <fsipc>
}
  801928:	c9                   	leave  
  801929:	c3                   	ret    

0080192a <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80192a:	55                   	push   %ebp
  80192b:	89 e5                	mov    %esp,%ebp
  80192d:	53                   	push   %ebx
  80192e:	83 ec 04             	sub    $0x4,%esp
  801931:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801934:	8b 45 08             	mov    0x8(%ebp),%eax
  801937:	8b 40 0c             	mov    0xc(%eax),%eax
  80193a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80193f:	ba 00 00 00 00       	mov    $0x0,%edx
  801944:	b8 05 00 00 00       	mov    $0x5,%eax
  801949:	e8 45 ff ff ff       	call   801893 <fsipc>
  80194e:	85 c0                	test   %eax,%eax
  801950:	78 2c                	js     80197e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801952:	83 ec 08             	sub    $0x8,%esp
  801955:	68 00 50 80 00       	push   $0x805000
  80195a:	53                   	push   %ebx
  80195b:	e8 a8 ed ff ff       	call   800708 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801960:	a1 80 50 80 00       	mov    0x805080,%eax
  801965:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80196b:	a1 84 50 80 00       	mov    0x805084,%eax
  801970:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801976:	83 c4 10             	add    $0x10,%esp
  801979:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80197e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801981:	c9                   	leave  
  801982:	c3                   	ret    

00801983 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801983:	55                   	push   %ebp
  801984:	89 e5                	mov    %esp,%ebp
  801986:	83 ec 0c             	sub    $0xc,%esp
  801989:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80198c:	8b 55 08             	mov    0x8(%ebp),%edx
  80198f:	8b 52 0c             	mov    0xc(%edx),%edx
  801992:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801998:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80199d:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8019a2:	0f 47 c2             	cmova  %edx,%eax
  8019a5:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8019aa:	50                   	push   %eax
  8019ab:	ff 75 0c             	pushl  0xc(%ebp)
  8019ae:	68 08 50 80 00       	push   $0x805008
  8019b3:	e8 e2 ee ff ff       	call   80089a <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8019b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8019bd:	b8 04 00 00 00       	mov    $0x4,%eax
  8019c2:	e8 cc fe ff ff       	call   801893 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8019c7:	c9                   	leave  
  8019c8:	c3                   	ret    

008019c9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019c9:	55                   	push   %ebp
  8019ca:	89 e5                	mov    %esp,%ebp
  8019cc:	56                   	push   %esi
  8019cd:	53                   	push   %ebx
  8019ce:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d4:	8b 40 0c             	mov    0xc(%eax),%eax
  8019d7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019dc:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e7:	b8 03 00 00 00       	mov    $0x3,%eax
  8019ec:	e8 a2 fe ff ff       	call   801893 <fsipc>
  8019f1:	89 c3                	mov    %eax,%ebx
  8019f3:	85 c0                	test   %eax,%eax
  8019f5:	78 4b                	js     801a42 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019f7:	39 c6                	cmp    %eax,%esi
  8019f9:	73 16                	jae    801a11 <devfile_read+0x48>
  8019fb:	68 f4 29 80 00       	push   $0x8029f4
  801a00:	68 fb 29 80 00       	push   $0x8029fb
  801a05:	6a 7c                	push   $0x7c
  801a07:	68 10 2a 80 00       	push   $0x802a10
  801a0c:	e8 c6 05 00 00       	call   801fd7 <_panic>
	assert(r <= PGSIZE);
  801a11:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a16:	7e 16                	jle    801a2e <devfile_read+0x65>
  801a18:	68 1b 2a 80 00       	push   $0x802a1b
  801a1d:	68 fb 29 80 00       	push   $0x8029fb
  801a22:	6a 7d                	push   $0x7d
  801a24:	68 10 2a 80 00       	push   $0x802a10
  801a29:	e8 a9 05 00 00       	call   801fd7 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a2e:	83 ec 04             	sub    $0x4,%esp
  801a31:	50                   	push   %eax
  801a32:	68 00 50 80 00       	push   $0x805000
  801a37:	ff 75 0c             	pushl  0xc(%ebp)
  801a3a:	e8 5b ee ff ff       	call   80089a <memmove>
	return r;
  801a3f:	83 c4 10             	add    $0x10,%esp
}
  801a42:	89 d8                	mov    %ebx,%eax
  801a44:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a47:	5b                   	pop    %ebx
  801a48:	5e                   	pop    %esi
  801a49:	5d                   	pop    %ebp
  801a4a:	c3                   	ret    

00801a4b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a4b:	55                   	push   %ebp
  801a4c:	89 e5                	mov    %esp,%ebp
  801a4e:	53                   	push   %ebx
  801a4f:	83 ec 20             	sub    $0x20,%esp
  801a52:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a55:	53                   	push   %ebx
  801a56:	e8 74 ec ff ff       	call   8006cf <strlen>
  801a5b:	83 c4 10             	add    $0x10,%esp
  801a5e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a63:	7f 67                	jg     801acc <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a65:	83 ec 0c             	sub    $0xc,%esp
  801a68:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a6b:	50                   	push   %eax
  801a6c:	e8 8e f8 ff ff       	call   8012ff <fd_alloc>
  801a71:	83 c4 10             	add    $0x10,%esp
		return r;
  801a74:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a76:	85 c0                	test   %eax,%eax
  801a78:	78 57                	js     801ad1 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a7a:	83 ec 08             	sub    $0x8,%esp
  801a7d:	53                   	push   %ebx
  801a7e:	68 00 50 80 00       	push   $0x805000
  801a83:	e8 80 ec ff ff       	call   800708 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a88:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a8b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a90:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a93:	b8 01 00 00 00       	mov    $0x1,%eax
  801a98:	e8 f6 fd ff ff       	call   801893 <fsipc>
  801a9d:	89 c3                	mov    %eax,%ebx
  801a9f:	83 c4 10             	add    $0x10,%esp
  801aa2:	85 c0                	test   %eax,%eax
  801aa4:	79 14                	jns    801aba <open+0x6f>
		fd_close(fd, 0);
  801aa6:	83 ec 08             	sub    $0x8,%esp
  801aa9:	6a 00                	push   $0x0
  801aab:	ff 75 f4             	pushl  -0xc(%ebp)
  801aae:	e8 47 f9 ff ff       	call   8013fa <fd_close>
		return r;
  801ab3:	83 c4 10             	add    $0x10,%esp
  801ab6:	89 da                	mov    %ebx,%edx
  801ab8:	eb 17                	jmp    801ad1 <open+0x86>
	}

	return fd2num(fd);
  801aba:	83 ec 0c             	sub    $0xc,%esp
  801abd:	ff 75 f4             	pushl  -0xc(%ebp)
  801ac0:	e8 13 f8 ff ff       	call   8012d8 <fd2num>
  801ac5:	89 c2                	mov    %eax,%edx
  801ac7:	83 c4 10             	add    $0x10,%esp
  801aca:	eb 05                	jmp    801ad1 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801acc:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ad1:	89 d0                	mov    %edx,%eax
  801ad3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ad6:	c9                   	leave  
  801ad7:	c3                   	ret    

00801ad8 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ad8:	55                   	push   %ebp
  801ad9:	89 e5                	mov    %esp,%ebp
  801adb:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ade:	ba 00 00 00 00       	mov    $0x0,%edx
  801ae3:	b8 08 00 00 00       	mov    $0x8,%eax
  801ae8:	e8 a6 fd ff ff       	call   801893 <fsipc>
}
  801aed:	c9                   	leave  
  801aee:	c3                   	ret    

00801aef <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801aef:	55                   	push   %ebp
  801af0:	89 e5                	mov    %esp,%ebp
  801af2:	56                   	push   %esi
  801af3:	53                   	push   %ebx
  801af4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801af7:	83 ec 0c             	sub    $0xc,%esp
  801afa:	ff 75 08             	pushl  0x8(%ebp)
  801afd:	e8 e6 f7 ff ff       	call   8012e8 <fd2data>
  801b02:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b04:	83 c4 08             	add    $0x8,%esp
  801b07:	68 27 2a 80 00       	push   $0x802a27
  801b0c:	53                   	push   %ebx
  801b0d:	e8 f6 eb ff ff       	call   800708 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b12:	8b 46 04             	mov    0x4(%esi),%eax
  801b15:	2b 06                	sub    (%esi),%eax
  801b17:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b1d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b24:	00 00 00 
	stat->st_dev = &devpipe;
  801b27:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b2e:	30 80 00 
	return 0;
}
  801b31:	b8 00 00 00 00       	mov    $0x0,%eax
  801b36:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b39:	5b                   	pop    %ebx
  801b3a:	5e                   	pop    %esi
  801b3b:	5d                   	pop    %ebp
  801b3c:	c3                   	ret    

00801b3d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b3d:	55                   	push   %ebp
  801b3e:	89 e5                	mov    %esp,%ebp
  801b40:	53                   	push   %ebx
  801b41:	83 ec 0c             	sub    $0xc,%esp
  801b44:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b47:	53                   	push   %ebx
  801b48:	6a 00                	push   $0x0
  801b4a:	e8 41 f0 ff ff       	call   800b90 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b4f:	89 1c 24             	mov    %ebx,(%esp)
  801b52:	e8 91 f7 ff ff       	call   8012e8 <fd2data>
  801b57:	83 c4 08             	add    $0x8,%esp
  801b5a:	50                   	push   %eax
  801b5b:	6a 00                	push   $0x0
  801b5d:	e8 2e f0 ff ff       	call   800b90 <sys_page_unmap>
}
  801b62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b65:	c9                   	leave  
  801b66:	c3                   	ret    

00801b67 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b67:	55                   	push   %ebp
  801b68:	89 e5                	mov    %esp,%ebp
  801b6a:	57                   	push   %edi
  801b6b:	56                   	push   %esi
  801b6c:	53                   	push   %ebx
  801b6d:	83 ec 1c             	sub    $0x1c,%esp
  801b70:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b73:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b75:	a1 04 40 80 00       	mov    0x804004,%eax
  801b7a:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b80:	83 ec 0c             	sub    $0xc,%esp
  801b83:	ff 75 e0             	pushl  -0x20(%ebp)
  801b86:	e8 43 06 00 00       	call   8021ce <pageref>
  801b8b:	89 c3                	mov    %eax,%ebx
  801b8d:	89 3c 24             	mov    %edi,(%esp)
  801b90:	e8 39 06 00 00       	call   8021ce <pageref>
  801b95:	83 c4 10             	add    $0x10,%esp
  801b98:	39 c3                	cmp    %eax,%ebx
  801b9a:	0f 94 c1             	sete   %cl
  801b9d:	0f b6 c9             	movzbl %cl,%ecx
  801ba0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ba3:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ba9:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801baf:	39 ce                	cmp    %ecx,%esi
  801bb1:	74 1e                	je     801bd1 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801bb3:	39 c3                	cmp    %eax,%ebx
  801bb5:	75 be                	jne    801b75 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bb7:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801bbd:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bc0:	50                   	push   %eax
  801bc1:	56                   	push   %esi
  801bc2:	68 2e 2a 80 00       	push   $0x802a2e
  801bc7:	e8 b7 e5 ff ff       	call   800183 <cprintf>
  801bcc:	83 c4 10             	add    $0x10,%esp
  801bcf:	eb a4                	jmp    801b75 <_pipeisclosed+0xe>
	}
}
  801bd1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bd7:	5b                   	pop    %ebx
  801bd8:	5e                   	pop    %esi
  801bd9:	5f                   	pop    %edi
  801bda:	5d                   	pop    %ebp
  801bdb:	c3                   	ret    

00801bdc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bdc:	55                   	push   %ebp
  801bdd:	89 e5                	mov    %esp,%ebp
  801bdf:	57                   	push   %edi
  801be0:	56                   	push   %esi
  801be1:	53                   	push   %ebx
  801be2:	83 ec 28             	sub    $0x28,%esp
  801be5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801be8:	56                   	push   %esi
  801be9:	e8 fa f6 ff ff       	call   8012e8 <fd2data>
  801bee:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bf0:	83 c4 10             	add    $0x10,%esp
  801bf3:	bf 00 00 00 00       	mov    $0x0,%edi
  801bf8:	eb 4b                	jmp    801c45 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bfa:	89 da                	mov    %ebx,%edx
  801bfc:	89 f0                	mov    %esi,%eax
  801bfe:	e8 64 ff ff ff       	call   801b67 <_pipeisclosed>
  801c03:	85 c0                	test   %eax,%eax
  801c05:	75 48                	jne    801c4f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c07:	e8 e0 ee ff ff       	call   800aec <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c0c:	8b 43 04             	mov    0x4(%ebx),%eax
  801c0f:	8b 0b                	mov    (%ebx),%ecx
  801c11:	8d 51 20             	lea    0x20(%ecx),%edx
  801c14:	39 d0                	cmp    %edx,%eax
  801c16:	73 e2                	jae    801bfa <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c1b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c1f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c22:	89 c2                	mov    %eax,%edx
  801c24:	c1 fa 1f             	sar    $0x1f,%edx
  801c27:	89 d1                	mov    %edx,%ecx
  801c29:	c1 e9 1b             	shr    $0x1b,%ecx
  801c2c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c2f:	83 e2 1f             	and    $0x1f,%edx
  801c32:	29 ca                	sub    %ecx,%edx
  801c34:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c38:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c3c:	83 c0 01             	add    $0x1,%eax
  801c3f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c42:	83 c7 01             	add    $0x1,%edi
  801c45:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c48:	75 c2                	jne    801c0c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c4a:	8b 45 10             	mov    0x10(%ebp),%eax
  801c4d:	eb 05                	jmp    801c54 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c4f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c57:	5b                   	pop    %ebx
  801c58:	5e                   	pop    %esi
  801c59:	5f                   	pop    %edi
  801c5a:	5d                   	pop    %ebp
  801c5b:	c3                   	ret    

00801c5c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	57                   	push   %edi
  801c60:	56                   	push   %esi
  801c61:	53                   	push   %ebx
  801c62:	83 ec 18             	sub    $0x18,%esp
  801c65:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c68:	57                   	push   %edi
  801c69:	e8 7a f6 ff ff       	call   8012e8 <fd2data>
  801c6e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c70:	83 c4 10             	add    $0x10,%esp
  801c73:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c78:	eb 3d                	jmp    801cb7 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c7a:	85 db                	test   %ebx,%ebx
  801c7c:	74 04                	je     801c82 <devpipe_read+0x26>
				return i;
  801c7e:	89 d8                	mov    %ebx,%eax
  801c80:	eb 44                	jmp    801cc6 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c82:	89 f2                	mov    %esi,%edx
  801c84:	89 f8                	mov    %edi,%eax
  801c86:	e8 dc fe ff ff       	call   801b67 <_pipeisclosed>
  801c8b:	85 c0                	test   %eax,%eax
  801c8d:	75 32                	jne    801cc1 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c8f:	e8 58 ee ff ff       	call   800aec <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c94:	8b 06                	mov    (%esi),%eax
  801c96:	3b 46 04             	cmp    0x4(%esi),%eax
  801c99:	74 df                	je     801c7a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c9b:	99                   	cltd   
  801c9c:	c1 ea 1b             	shr    $0x1b,%edx
  801c9f:	01 d0                	add    %edx,%eax
  801ca1:	83 e0 1f             	and    $0x1f,%eax
  801ca4:	29 d0                	sub    %edx,%eax
  801ca6:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801cab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cae:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801cb1:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cb4:	83 c3 01             	add    $0x1,%ebx
  801cb7:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cba:	75 d8                	jne    801c94 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cbc:	8b 45 10             	mov    0x10(%ebp),%eax
  801cbf:	eb 05                	jmp    801cc6 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cc1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cc9:	5b                   	pop    %ebx
  801cca:	5e                   	pop    %esi
  801ccb:	5f                   	pop    %edi
  801ccc:	5d                   	pop    %ebp
  801ccd:	c3                   	ret    

00801cce <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cce:	55                   	push   %ebp
  801ccf:	89 e5                	mov    %esp,%ebp
  801cd1:	56                   	push   %esi
  801cd2:	53                   	push   %ebx
  801cd3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cd6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cd9:	50                   	push   %eax
  801cda:	e8 20 f6 ff ff       	call   8012ff <fd_alloc>
  801cdf:	83 c4 10             	add    $0x10,%esp
  801ce2:	89 c2                	mov    %eax,%edx
  801ce4:	85 c0                	test   %eax,%eax
  801ce6:	0f 88 2c 01 00 00    	js     801e18 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cec:	83 ec 04             	sub    $0x4,%esp
  801cef:	68 07 04 00 00       	push   $0x407
  801cf4:	ff 75 f4             	pushl  -0xc(%ebp)
  801cf7:	6a 00                	push   $0x0
  801cf9:	e8 0d ee ff ff       	call   800b0b <sys_page_alloc>
  801cfe:	83 c4 10             	add    $0x10,%esp
  801d01:	89 c2                	mov    %eax,%edx
  801d03:	85 c0                	test   %eax,%eax
  801d05:	0f 88 0d 01 00 00    	js     801e18 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d0b:	83 ec 0c             	sub    $0xc,%esp
  801d0e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d11:	50                   	push   %eax
  801d12:	e8 e8 f5 ff ff       	call   8012ff <fd_alloc>
  801d17:	89 c3                	mov    %eax,%ebx
  801d19:	83 c4 10             	add    $0x10,%esp
  801d1c:	85 c0                	test   %eax,%eax
  801d1e:	0f 88 e2 00 00 00    	js     801e06 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d24:	83 ec 04             	sub    $0x4,%esp
  801d27:	68 07 04 00 00       	push   $0x407
  801d2c:	ff 75 f0             	pushl  -0x10(%ebp)
  801d2f:	6a 00                	push   $0x0
  801d31:	e8 d5 ed ff ff       	call   800b0b <sys_page_alloc>
  801d36:	89 c3                	mov    %eax,%ebx
  801d38:	83 c4 10             	add    $0x10,%esp
  801d3b:	85 c0                	test   %eax,%eax
  801d3d:	0f 88 c3 00 00 00    	js     801e06 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d43:	83 ec 0c             	sub    $0xc,%esp
  801d46:	ff 75 f4             	pushl  -0xc(%ebp)
  801d49:	e8 9a f5 ff ff       	call   8012e8 <fd2data>
  801d4e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d50:	83 c4 0c             	add    $0xc,%esp
  801d53:	68 07 04 00 00       	push   $0x407
  801d58:	50                   	push   %eax
  801d59:	6a 00                	push   $0x0
  801d5b:	e8 ab ed ff ff       	call   800b0b <sys_page_alloc>
  801d60:	89 c3                	mov    %eax,%ebx
  801d62:	83 c4 10             	add    $0x10,%esp
  801d65:	85 c0                	test   %eax,%eax
  801d67:	0f 88 89 00 00 00    	js     801df6 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d6d:	83 ec 0c             	sub    $0xc,%esp
  801d70:	ff 75 f0             	pushl  -0x10(%ebp)
  801d73:	e8 70 f5 ff ff       	call   8012e8 <fd2data>
  801d78:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d7f:	50                   	push   %eax
  801d80:	6a 00                	push   $0x0
  801d82:	56                   	push   %esi
  801d83:	6a 00                	push   $0x0
  801d85:	e8 c4 ed ff ff       	call   800b4e <sys_page_map>
  801d8a:	89 c3                	mov    %eax,%ebx
  801d8c:	83 c4 20             	add    $0x20,%esp
  801d8f:	85 c0                	test   %eax,%eax
  801d91:	78 55                	js     801de8 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d93:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801da8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801db1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801db3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801db6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801dbd:	83 ec 0c             	sub    $0xc,%esp
  801dc0:	ff 75 f4             	pushl  -0xc(%ebp)
  801dc3:	e8 10 f5 ff ff       	call   8012d8 <fd2num>
  801dc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dcb:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dcd:	83 c4 04             	add    $0x4,%esp
  801dd0:	ff 75 f0             	pushl  -0x10(%ebp)
  801dd3:	e8 00 f5 ff ff       	call   8012d8 <fd2num>
  801dd8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ddb:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801dde:	83 c4 10             	add    $0x10,%esp
  801de1:	ba 00 00 00 00       	mov    $0x0,%edx
  801de6:	eb 30                	jmp    801e18 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801de8:	83 ec 08             	sub    $0x8,%esp
  801deb:	56                   	push   %esi
  801dec:	6a 00                	push   $0x0
  801dee:	e8 9d ed ff ff       	call   800b90 <sys_page_unmap>
  801df3:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801df6:	83 ec 08             	sub    $0x8,%esp
  801df9:	ff 75 f0             	pushl  -0x10(%ebp)
  801dfc:	6a 00                	push   $0x0
  801dfe:	e8 8d ed ff ff       	call   800b90 <sys_page_unmap>
  801e03:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e06:	83 ec 08             	sub    $0x8,%esp
  801e09:	ff 75 f4             	pushl  -0xc(%ebp)
  801e0c:	6a 00                	push   $0x0
  801e0e:	e8 7d ed ff ff       	call   800b90 <sys_page_unmap>
  801e13:	83 c4 10             	add    $0x10,%esp
  801e16:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e18:	89 d0                	mov    %edx,%eax
  801e1a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e1d:	5b                   	pop    %ebx
  801e1e:	5e                   	pop    %esi
  801e1f:	5d                   	pop    %ebp
  801e20:	c3                   	ret    

00801e21 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e21:	55                   	push   %ebp
  801e22:	89 e5                	mov    %esp,%ebp
  801e24:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e27:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e2a:	50                   	push   %eax
  801e2b:	ff 75 08             	pushl  0x8(%ebp)
  801e2e:	e8 1b f5 ff ff       	call   80134e <fd_lookup>
  801e33:	83 c4 10             	add    $0x10,%esp
  801e36:	85 c0                	test   %eax,%eax
  801e38:	78 18                	js     801e52 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e3a:	83 ec 0c             	sub    $0xc,%esp
  801e3d:	ff 75 f4             	pushl  -0xc(%ebp)
  801e40:	e8 a3 f4 ff ff       	call   8012e8 <fd2data>
	return _pipeisclosed(fd, p);
  801e45:	89 c2                	mov    %eax,%edx
  801e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e4a:	e8 18 fd ff ff       	call   801b67 <_pipeisclosed>
  801e4f:	83 c4 10             	add    $0x10,%esp
}
  801e52:	c9                   	leave  
  801e53:	c3                   	ret    

00801e54 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e54:	55                   	push   %ebp
  801e55:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e57:	b8 00 00 00 00       	mov    $0x0,%eax
  801e5c:	5d                   	pop    %ebp
  801e5d:	c3                   	ret    

00801e5e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e5e:	55                   	push   %ebp
  801e5f:	89 e5                	mov    %esp,%ebp
  801e61:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e64:	68 46 2a 80 00       	push   $0x802a46
  801e69:	ff 75 0c             	pushl  0xc(%ebp)
  801e6c:	e8 97 e8 ff ff       	call   800708 <strcpy>
	return 0;
}
  801e71:	b8 00 00 00 00       	mov    $0x0,%eax
  801e76:	c9                   	leave  
  801e77:	c3                   	ret    

00801e78 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e78:	55                   	push   %ebp
  801e79:	89 e5                	mov    %esp,%ebp
  801e7b:	57                   	push   %edi
  801e7c:	56                   	push   %esi
  801e7d:	53                   	push   %ebx
  801e7e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e84:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e89:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e8f:	eb 2d                	jmp    801ebe <devcons_write+0x46>
		m = n - tot;
  801e91:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e94:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e96:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e99:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e9e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ea1:	83 ec 04             	sub    $0x4,%esp
  801ea4:	53                   	push   %ebx
  801ea5:	03 45 0c             	add    0xc(%ebp),%eax
  801ea8:	50                   	push   %eax
  801ea9:	57                   	push   %edi
  801eaa:	e8 eb e9 ff ff       	call   80089a <memmove>
		sys_cputs(buf, m);
  801eaf:	83 c4 08             	add    $0x8,%esp
  801eb2:	53                   	push   %ebx
  801eb3:	57                   	push   %edi
  801eb4:	e8 96 eb ff ff       	call   800a4f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eb9:	01 de                	add    %ebx,%esi
  801ebb:	83 c4 10             	add    $0x10,%esp
  801ebe:	89 f0                	mov    %esi,%eax
  801ec0:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ec3:	72 cc                	jb     801e91 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ec5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ec8:	5b                   	pop    %ebx
  801ec9:	5e                   	pop    %esi
  801eca:	5f                   	pop    %edi
  801ecb:	5d                   	pop    %ebp
  801ecc:	c3                   	ret    

00801ecd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ecd:	55                   	push   %ebp
  801ece:	89 e5                	mov    %esp,%ebp
  801ed0:	83 ec 08             	sub    $0x8,%esp
  801ed3:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ed8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801edc:	74 2a                	je     801f08 <devcons_read+0x3b>
  801ede:	eb 05                	jmp    801ee5 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ee0:	e8 07 ec ff ff       	call   800aec <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ee5:	e8 83 eb ff ff       	call   800a6d <sys_cgetc>
  801eea:	85 c0                	test   %eax,%eax
  801eec:	74 f2                	je     801ee0 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801eee:	85 c0                	test   %eax,%eax
  801ef0:	78 16                	js     801f08 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ef2:	83 f8 04             	cmp    $0x4,%eax
  801ef5:	74 0c                	je     801f03 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ef7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801efa:	88 02                	mov    %al,(%edx)
	return 1;
  801efc:	b8 01 00 00 00       	mov    $0x1,%eax
  801f01:	eb 05                	jmp    801f08 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f03:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f08:	c9                   	leave  
  801f09:	c3                   	ret    

00801f0a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f0a:	55                   	push   %ebp
  801f0b:	89 e5                	mov    %esp,%ebp
  801f0d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f10:	8b 45 08             	mov    0x8(%ebp),%eax
  801f13:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f16:	6a 01                	push   $0x1
  801f18:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f1b:	50                   	push   %eax
  801f1c:	e8 2e eb ff ff       	call   800a4f <sys_cputs>
}
  801f21:	83 c4 10             	add    $0x10,%esp
  801f24:	c9                   	leave  
  801f25:	c3                   	ret    

00801f26 <getchar>:

int
getchar(void)
{
  801f26:	55                   	push   %ebp
  801f27:	89 e5                	mov    %esp,%ebp
  801f29:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f2c:	6a 01                	push   $0x1
  801f2e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f31:	50                   	push   %eax
  801f32:	6a 00                	push   $0x0
  801f34:	e8 7e f6 ff ff       	call   8015b7 <read>
	if (r < 0)
  801f39:	83 c4 10             	add    $0x10,%esp
  801f3c:	85 c0                	test   %eax,%eax
  801f3e:	78 0f                	js     801f4f <getchar+0x29>
		return r;
	if (r < 1)
  801f40:	85 c0                	test   %eax,%eax
  801f42:	7e 06                	jle    801f4a <getchar+0x24>
		return -E_EOF;
	return c;
  801f44:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f48:	eb 05                	jmp    801f4f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f4a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f4f:	c9                   	leave  
  801f50:	c3                   	ret    

00801f51 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f51:	55                   	push   %ebp
  801f52:	89 e5                	mov    %esp,%ebp
  801f54:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f57:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f5a:	50                   	push   %eax
  801f5b:	ff 75 08             	pushl  0x8(%ebp)
  801f5e:	e8 eb f3 ff ff       	call   80134e <fd_lookup>
  801f63:	83 c4 10             	add    $0x10,%esp
  801f66:	85 c0                	test   %eax,%eax
  801f68:	78 11                	js     801f7b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f6d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f73:	39 10                	cmp    %edx,(%eax)
  801f75:	0f 94 c0             	sete   %al
  801f78:	0f b6 c0             	movzbl %al,%eax
}
  801f7b:	c9                   	leave  
  801f7c:	c3                   	ret    

00801f7d <opencons>:

int
opencons(void)
{
  801f7d:	55                   	push   %ebp
  801f7e:	89 e5                	mov    %esp,%ebp
  801f80:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f83:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f86:	50                   	push   %eax
  801f87:	e8 73 f3 ff ff       	call   8012ff <fd_alloc>
  801f8c:	83 c4 10             	add    $0x10,%esp
		return r;
  801f8f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f91:	85 c0                	test   %eax,%eax
  801f93:	78 3e                	js     801fd3 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f95:	83 ec 04             	sub    $0x4,%esp
  801f98:	68 07 04 00 00       	push   $0x407
  801f9d:	ff 75 f4             	pushl  -0xc(%ebp)
  801fa0:	6a 00                	push   $0x0
  801fa2:	e8 64 eb ff ff       	call   800b0b <sys_page_alloc>
  801fa7:	83 c4 10             	add    $0x10,%esp
		return r;
  801faa:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fac:	85 c0                	test   %eax,%eax
  801fae:	78 23                	js     801fd3 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fb0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fbe:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fc5:	83 ec 0c             	sub    $0xc,%esp
  801fc8:	50                   	push   %eax
  801fc9:	e8 0a f3 ff ff       	call   8012d8 <fd2num>
  801fce:	89 c2                	mov    %eax,%edx
  801fd0:	83 c4 10             	add    $0x10,%esp
}
  801fd3:	89 d0                	mov    %edx,%eax
  801fd5:	c9                   	leave  
  801fd6:	c3                   	ret    

00801fd7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801fd7:	55                   	push   %ebp
  801fd8:	89 e5                	mov    %esp,%ebp
  801fda:	56                   	push   %esi
  801fdb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801fdc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801fdf:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801fe5:	e8 e3 ea ff ff       	call   800acd <sys_getenvid>
  801fea:	83 ec 0c             	sub    $0xc,%esp
  801fed:	ff 75 0c             	pushl  0xc(%ebp)
  801ff0:	ff 75 08             	pushl  0x8(%ebp)
  801ff3:	56                   	push   %esi
  801ff4:	50                   	push   %eax
  801ff5:	68 54 2a 80 00       	push   $0x802a54
  801ffa:	e8 84 e1 ff ff       	call   800183 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801fff:	83 c4 18             	add    $0x18,%esp
  802002:	53                   	push   %ebx
  802003:	ff 75 10             	pushl  0x10(%ebp)
  802006:	e8 27 e1 ff ff       	call   800132 <vcprintf>
	cprintf("\n");
  80200b:	c7 04 24 a6 28 80 00 	movl   $0x8028a6,(%esp)
  802012:	e8 6c e1 ff ff       	call   800183 <cprintf>
  802017:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80201a:	cc                   	int3   
  80201b:	eb fd                	jmp    80201a <_panic+0x43>

0080201d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80201d:	55                   	push   %ebp
  80201e:	89 e5                	mov    %esp,%ebp
  802020:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802023:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80202a:	75 2a                	jne    802056 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  80202c:	83 ec 04             	sub    $0x4,%esp
  80202f:	6a 07                	push   $0x7
  802031:	68 00 f0 bf ee       	push   $0xeebff000
  802036:	6a 00                	push   $0x0
  802038:	e8 ce ea ff ff       	call   800b0b <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  80203d:	83 c4 10             	add    $0x10,%esp
  802040:	85 c0                	test   %eax,%eax
  802042:	79 12                	jns    802056 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802044:	50                   	push   %eax
  802045:	68 d8 28 80 00       	push   $0x8028d8
  80204a:	6a 23                	push   $0x23
  80204c:	68 78 2a 80 00       	push   $0x802a78
  802051:	e8 81 ff ff ff       	call   801fd7 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802056:	8b 45 08             	mov    0x8(%ebp),%eax
  802059:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80205e:	83 ec 08             	sub    $0x8,%esp
  802061:	68 88 20 80 00       	push   $0x802088
  802066:	6a 00                	push   $0x0
  802068:	e8 e9 eb ff ff       	call   800c56 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  80206d:	83 c4 10             	add    $0x10,%esp
  802070:	85 c0                	test   %eax,%eax
  802072:	79 12                	jns    802086 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802074:	50                   	push   %eax
  802075:	68 d8 28 80 00       	push   $0x8028d8
  80207a:	6a 2c                	push   $0x2c
  80207c:	68 78 2a 80 00       	push   $0x802a78
  802081:	e8 51 ff ff ff       	call   801fd7 <_panic>
	}
}
  802086:	c9                   	leave  
  802087:	c3                   	ret    

00802088 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802088:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802089:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80208e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802090:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802093:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802097:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  80209c:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8020a0:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8020a2:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8020a5:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8020a6:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8020a9:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8020aa:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8020ab:	c3                   	ret    

008020ac <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020ac:	55                   	push   %ebp
  8020ad:	89 e5                	mov    %esp,%ebp
  8020af:	56                   	push   %esi
  8020b0:	53                   	push   %ebx
  8020b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8020b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8020ba:	85 c0                	test   %eax,%eax
  8020bc:	75 12                	jne    8020d0 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8020be:	83 ec 0c             	sub    $0xc,%esp
  8020c1:	68 00 00 c0 ee       	push   $0xeec00000
  8020c6:	e8 f0 eb ff ff       	call   800cbb <sys_ipc_recv>
  8020cb:	83 c4 10             	add    $0x10,%esp
  8020ce:	eb 0c                	jmp    8020dc <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8020d0:	83 ec 0c             	sub    $0xc,%esp
  8020d3:	50                   	push   %eax
  8020d4:	e8 e2 eb ff ff       	call   800cbb <sys_ipc_recv>
  8020d9:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8020dc:	85 f6                	test   %esi,%esi
  8020de:	0f 95 c1             	setne  %cl
  8020e1:	85 db                	test   %ebx,%ebx
  8020e3:	0f 95 c2             	setne  %dl
  8020e6:	84 d1                	test   %dl,%cl
  8020e8:	74 09                	je     8020f3 <ipc_recv+0x47>
  8020ea:	89 c2                	mov    %eax,%edx
  8020ec:	c1 ea 1f             	shr    $0x1f,%edx
  8020ef:	84 d2                	test   %dl,%dl
  8020f1:	75 2d                	jne    802120 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8020f3:	85 f6                	test   %esi,%esi
  8020f5:	74 0d                	je     802104 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8020f7:	a1 04 40 80 00       	mov    0x804004,%eax
  8020fc:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802102:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802104:	85 db                	test   %ebx,%ebx
  802106:	74 0d                	je     802115 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802108:	a1 04 40 80 00       	mov    0x804004,%eax
  80210d:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  802113:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802115:	a1 04 40 80 00       	mov    0x804004,%eax
  80211a:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  802120:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802123:	5b                   	pop    %ebx
  802124:	5e                   	pop    %esi
  802125:	5d                   	pop    %ebp
  802126:	c3                   	ret    

00802127 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802127:	55                   	push   %ebp
  802128:	89 e5                	mov    %esp,%ebp
  80212a:	57                   	push   %edi
  80212b:	56                   	push   %esi
  80212c:	53                   	push   %ebx
  80212d:	83 ec 0c             	sub    $0xc,%esp
  802130:	8b 7d 08             	mov    0x8(%ebp),%edi
  802133:	8b 75 0c             	mov    0xc(%ebp),%esi
  802136:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802139:	85 db                	test   %ebx,%ebx
  80213b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802140:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802143:	ff 75 14             	pushl  0x14(%ebp)
  802146:	53                   	push   %ebx
  802147:	56                   	push   %esi
  802148:	57                   	push   %edi
  802149:	e8 4a eb ff ff       	call   800c98 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  80214e:	89 c2                	mov    %eax,%edx
  802150:	c1 ea 1f             	shr    $0x1f,%edx
  802153:	83 c4 10             	add    $0x10,%esp
  802156:	84 d2                	test   %dl,%dl
  802158:	74 17                	je     802171 <ipc_send+0x4a>
  80215a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80215d:	74 12                	je     802171 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  80215f:	50                   	push   %eax
  802160:	68 86 2a 80 00       	push   $0x802a86
  802165:	6a 47                	push   $0x47
  802167:	68 94 2a 80 00       	push   $0x802a94
  80216c:	e8 66 fe ff ff       	call   801fd7 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802171:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802174:	75 07                	jne    80217d <ipc_send+0x56>
			sys_yield();
  802176:	e8 71 e9 ff ff       	call   800aec <sys_yield>
  80217b:	eb c6                	jmp    802143 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80217d:	85 c0                	test   %eax,%eax
  80217f:	75 c2                	jne    802143 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802181:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802184:	5b                   	pop    %ebx
  802185:	5e                   	pop    %esi
  802186:	5f                   	pop    %edi
  802187:	5d                   	pop    %ebp
  802188:	c3                   	ret    

00802189 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802189:	55                   	push   %ebp
  80218a:	89 e5                	mov    %esp,%ebp
  80218c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80218f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802194:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  80219a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021a0:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  8021a6:	39 ca                	cmp    %ecx,%edx
  8021a8:	75 13                	jne    8021bd <ipc_find_env+0x34>
			return envs[i].env_id;
  8021aa:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8021b0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021b5:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8021bb:	eb 0f                	jmp    8021cc <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021bd:	83 c0 01             	add    $0x1,%eax
  8021c0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021c5:	75 cd                	jne    802194 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021cc:	5d                   	pop    %ebp
  8021cd:	c3                   	ret    

008021ce <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021ce:	55                   	push   %ebp
  8021cf:	89 e5                	mov    %esp,%ebp
  8021d1:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021d4:	89 d0                	mov    %edx,%eax
  8021d6:	c1 e8 16             	shr    $0x16,%eax
  8021d9:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021e0:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021e5:	f6 c1 01             	test   $0x1,%cl
  8021e8:	74 1d                	je     802207 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021ea:	c1 ea 0c             	shr    $0xc,%edx
  8021ed:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021f4:	f6 c2 01             	test   $0x1,%dl
  8021f7:	74 0e                	je     802207 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021f9:	c1 ea 0c             	shr    $0xc,%edx
  8021fc:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802203:	ef 
  802204:	0f b7 c0             	movzwl %ax,%eax
}
  802207:	5d                   	pop    %ebp
  802208:	c3                   	ret    
  802209:	66 90                	xchg   %ax,%ax
  80220b:	66 90                	xchg   %ax,%ax
  80220d:	66 90                	xchg   %ax,%ax
  80220f:	90                   	nop

00802210 <__udivdi3>:
  802210:	55                   	push   %ebp
  802211:	57                   	push   %edi
  802212:	56                   	push   %esi
  802213:	53                   	push   %ebx
  802214:	83 ec 1c             	sub    $0x1c,%esp
  802217:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80221b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80221f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802223:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802227:	85 f6                	test   %esi,%esi
  802229:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80222d:	89 ca                	mov    %ecx,%edx
  80222f:	89 f8                	mov    %edi,%eax
  802231:	75 3d                	jne    802270 <__udivdi3+0x60>
  802233:	39 cf                	cmp    %ecx,%edi
  802235:	0f 87 c5 00 00 00    	ja     802300 <__udivdi3+0xf0>
  80223b:	85 ff                	test   %edi,%edi
  80223d:	89 fd                	mov    %edi,%ebp
  80223f:	75 0b                	jne    80224c <__udivdi3+0x3c>
  802241:	b8 01 00 00 00       	mov    $0x1,%eax
  802246:	31 d2                	xor    %edx,%edx
  802248:	f7 f7                	div    %edi
  80224a:	89 c5                	mov    %eax,%ebp
  80224c:	89 c8                	mov    %ecx,%eax
  80224e:	31 d2                	xor    %edx,%edx
  802250:	f7 f5                	div    %ebp
  802252:	89 c1                	mov    %eax,%ecx
  802254:	89 d8                	mov    %ebx,%eax
  802256:	89 cf                	mov    %ecx,%edi
  802258:	f7 f5                	div    %ebp
  80225a:	89 c3                	mov    %eax,%ebx
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
  802270:	39 ce                	cmp    %ecx,%esi
  802272:	77 74                	ja     8022e8 <__udivdi3+0xd8>
  802274:	0f bd fe             	bsr    %esi,%edi
  802277:	83 f7 1f             	xor    $0x1f,%edi
  80227a:	0f 84 98 00 00 00    	je     802318 <__udivdi3+0x108>
  802280:	bb 20 00 00 00       	mov    $0x20,%ebx
  802285:	89 f9                	mov    %edi,%ecx
  802287:	89 c5                	mov    %eax,%ebp
  802289:	29 fb                	sub    %edi,%ebx
  80228b:	d3 e6                	shl    %cl,%esi
  80228d:	89 d9                	mov    %ebx,%ecx
  80228f:	d3 ed                	shr    %cl,%ebp
  802291:	89 f9                	mov    %edi,%ecx
  802293:	d3 e0                	shl    %cl,%eax
  802295:	09 ee                	or     %ebp,%esi
  802297:	89 d9                	mov    %ebx,%ecx
  802299:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80229d:	89 d5                	mov    %edx,%ebp
  80229f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022a3:	d3 ed                	shr    %cl,%ebp
  8022a5:	89 f9                	mov    %edi,%ecx
  8022a7:	d3 e2                	shl    %cl,%edx
  8022a9:	89 d9                	mov    %ebx,%ecx
  8022ab:	d3 e8                	shr    %cl,%eax
  8022ad:	09 c2                	or     %eax,%edx
  8022af:	89 d0                	mov    %edx,%eax
  8022b1:	89 ea                	mov    %ebp,%edx
  8022b3:	f7 f6                	div    %esi
  8022b5:	89 d5                	mov    %edx,%ebp
  8022b7:	89 c3                	mov    %eax,%ebx
  8022b9:	f7 64 24 0c          	mull   0xc(%esp)
  8022bd:	39 d5                	cmp    %edx,%ebp
  8022bf:	72 10                	jb     8022d1 <__udivdi3+0xc1>
  8022c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8022c5:	89 f9                	mov    %edi,%ecx
  8022c7:	d3 e6                	shl    %cl,%esi
  8022c9:	39 c6                	cmp    %eax,%esi
  8022cb:	73 07                	jae    8022d4 <__udivdi3+0xc4>
  8022cd:	39 d5                	cmp    %edx,%ebp
  8022cf:	75 03                	jne    8022d4 <__udivdi3+0xc4>
  8022d1:	83 eb 01             	sub    $0x1,%ebx
  8022d4:	31 ff                	xor    %edi,%edi
  8022d6:	89 d8                	mov    %ebx,%eax
  8022d8:	89 fa                	mov    %edi,%edx
  8022da:	83 c4 1c             	add    $0x1c,%esp
  8022dd:	5b                   	pop    %ebx
  8022de:	5e                   	pop    %esi
  8022df:	5f                   	pop    %edi
  8022e0:	5d                   	pop    %ebp
  8022e1:	c3                   	ret    
  8022e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022e8:	31 ff                	xor    %edi,%edi
  8022ea:	31 db                	xor    %ebx,%ebx
  8022ec:	89 d8                	mov    %ebx,%eax
  8022ee:	89 fa                	mov    %edi,%edx
  8022f0:	83 c4 1c             	add    $0x1c,%esp
  8022f3:	5b                   	pop    %ebx
  8022f4:	5e                   	pop    %esi
  8022f5:	5f                   	pop    %edi
  8022f6:	5d                   	pop    %ebp
  8022f7:	c3                   	ret    
  8022f8:	90                   	nop
  8022f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802300:	89 d8                	mov    %ebx,%eax
  802302:	f7 f7                	div    %edi
  802304:	31 ff                	xor    %edi,%edi
  802306:	89 c3                	mov    %eax,%ebx
  802308:	89 d8                	mov    %ebx,%eax
  80230a:	89 fa                	mov    %edi,%edx
  80230c:	83 c4 1c             	add    $0x1c,%esp
  80230f:	5b                   	pop    %ebx
  802310:	5e                   	pop    %esi
  802311:	5f                   	pop    %edi
  802312:	5d                   	pop    %ebp
  802313:	c3                   	ret    
  802314:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802318:	39 ce                	cmp    %ecx,%esi
  80231a:	72 0c                	jb     802328 <__udivdi3+0x118>
  80231c:	31 db                	xor    %ebx,%ebx
  80231e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802322:	0f 87 34 ff ff ff    	ja     80225c <__udivdi3+0x4c>
  802328:	bb 01 00 00 00       	mov    $0x1,%ebx
  80232d:	e9 2a ff ff ff       	jmp    80225c <__udivdi3+0x4c>
  802332:	66 90                	xchg   %ax,%ax
  802334:	66 90                	xchg   %ax,%ax
  802336:	66 90                	xchg   %ax,%ax
  802338:	66 90                	xchg   %ax,%ax
  80233a:	66 90                	xchg   %ax,%ax
  80233c:	66 90                	xchg   %ax,%ax
  80233e:	66 90                	xchg   %ax,%ax

00802340 <__umoddi3>:
  802340:	55                   	push   %ebp
  802341:	57                   	push   %edi
  802342:	56                   	push   %esi
  802343:	53                   	push   %ebx
  802344:	83 ec 1c             	sub    $0x1c,%esp
  802347:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80234b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80234f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802353:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802357:	85 d2                	test   %edx,%edx
  802359:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80235d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802361:	89 f3                	mov    %esi,%ebx
  802363:	89 3c 24             	mov    %edi,(%esp)
  802366:	89 74 24 04          	mov    %esi,0x4(%esp)
  80236a:	75 1c                	jne    802388 <__umoddi3+0x48>
  80236c:	39 f7                	cmp    %esi,%edi
  80236e:	76 50                	jbe    8023c0 <__umoddi3+0x80>
  802370:	89 c8                	mov    %ecx,%eax
  802372:	89 f2                	mov    %esi,%edx
  802374:	f7 f7                	div    %edi
  802376:	89 d0                	mov    %edx,%eax
  802378:	31 d2                	xor    %edx,%edx
  80237a:	83 c4 1c             	add    $0x1c,%esp
  80237d:	5b                   	pop    %ebx
  80237e:	5e                   	pop    %esi
  80237f:	5f                   	pop    %edi
  802380:	5d                   	pop    %ebp
  802381:	c3                   	ret    
  802382:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802388:	39 f2                	cmp    %esi,%edx
  80238a:	89 d0                	mov    %edx,%eax
  80238c:	77 52                	ja     8023e0 <__umoddi3+0xa0>
  80238e:	0f bd ea             	bsr    %edx,%ebp
  802391:	83 f5 1f             	xor    $0x1f,%ebp
  802394:	75 5a                	jne    8023f0 <__umoddi3+0xb0>
  802396:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80239a:	0f 82 e0 00 00 00    	jb     802480 <__umoddi3+0x140>
  8023a0:	39 0c 24             	cmp    %ecx,(%esp)
  8023a3:	0f 86 d7 00 00 00    	jbe    802480 <__umoddi3+0x140>
  8023a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023b1:	83 c4 1c             	add    $0x1c,%esp
  8023b4:	5b                   	pop    %ebx
  8023b5:	5e                   	pop    %esi
  8023b6:	5f                   	pop    %edi
  8023b7:	5d                   	pop    %ebp
  8023b8:	c3                   	ret    
  8023b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023c0:	85 ff                	test   %edi,%edi
  8023c2:	89 fd                	mov    %edi,%ebp
  8023c4:	75 0b                	jne    8023d1 <__umoddi3+0x91>
  8023c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023cb:	31 d2                	xor    %edx,%edx
  8023cd:	f7 f7                	div    %edi
  8023cf:	89 c5                	mov    %eax,%ebp
  8023d1:	89 f0                	mov    %esi,%eax
  8023d3:	31 d2                	xor    %edx,%edx
  8023d5:	f7 f5                	div    %ebp
  8023d7:	89 c8                	mov    %ecx,%eax
  8023d9:	f7 f5                	div    %ebp
  8023db:	89 d0                	mov    %edx,%eax
  8023dd:	eb 99                	jmp    802378 <__umoddi3+0x38>
  8023df:	90                   	nop
  8023e0:	89 c8                	mov    %ecx,%eax
  8023e2:	89 f2                	mov    %esi,%edx
  8023e4:	83 c4 1c             	add    $0x1c,%esp
  8023e7:	5b                   	pop    %ebx
  8023e8:	5e                   	pop    %esi
  8023e9:	5f                   	pop    %edi
  8023ea:	5d                   	pop    %ebp
  8023eb:	c3                   	ret    
  8023ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023f0:	8b 34 24             	mov    (%esp),%esi
  8023f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023f8:	89 e9                	mov    %ebp,%ecx
  8023fa:	29 ef                	sub    %ebp,%edi
  8023fc:	d3 e0                	shl    %cl,%eax
  8023fe:	89 f9                	mov    %edi,%ecx
  802400:	89 f2                	mov    %esi,%edx
  802402:	d3 ea                	shr    %cl,%edx
  802404:	89 e9                	mov    %ebp,%ecx
  802406:	09 c2                	or     %eax,%edx
  802408:	89 d8                	mov    %ebx,%eax
  80240a:	89 14 24             	mov    %edx,(%esp)
  80240d:	89 f2                	mov    %esi,%edx
  80240f:	d3 e2                	shl    %cl,%edx
  802411:	89 f9                	mov    %edi,%ecx
  802413:	89 54 24 04          	mov    %edx,0x4(%esp)
  802417:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80241b:	d3 e8                	shr    %cl,%eax
  80241d:	89 e9                	mov    %ebp,%ecx
  80241f:	89 c6                	mov    %eax,%esi
  802421:	d3 e3                	shl    %cl,%ebx
  802423:	89 f9                	mov    %edi,%ecx
  802425:	89 d0                	mov    %edx,%eax
  802427:	d3 e8                	shr    %cl,%eax
  802429:	89 e9                	mov    %ebp,%ecx
  80242b:	09 d8                	or     %ebx,%eax
  80242d:	89 d3                	mov    %edx,%ebx
  80242f:	89 f2                	mov    %esi,%edx
  802431:	f7 34 24             	divl   (%esp)
  802434:	89 d6                	mov    %edx,%esi
  802436:	d3 e3                	shl    %cl,%ebx
  802438:	f7 64 24 04          	mull   0x4(%esp)
  80243c:	39 d6                	cmp    %edx,%esi
  80243e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802442:	89 d1                	mov    %edx,%ecx
  802444:	89 c3                	mov    %eax,%ebx
  802446:	72 08                	jb     802450 <__umoddi3+0x110>
  802448:	75 11                	jne    80245b <__umoddi3+0x11b>
  80244a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80244e:	73 0b                	jae    80245b <__umoddi3+0x11b>
  802450:	2b 44 24 04          	sub    0x4(%esp),%eax
  802454:	1b 14 24             	sbb    (%esp),%edx
  802457:	89 d1                	mov    %edx,%ecx
  802459:	89 c3                	mov    %eax,%ebx
  80245b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80245f:	29 da                	sub    %ebx,%edx
  802461:	19 ce                	sbb    %ecx,%esi
  802463:	89 f9                	mov    %edi,%ecx
  802465:	89 f0                	mov    %esi,%eax
  802467:	d3 e0                	shl    %cl,%eax
  802469:	89 e9                	mov    %ebp,%ecx
  80246b:	d3 ea                	shr    %cl,%edx
  80246d:	89 e9                	mov    %ebp,%ecx
  80246f:	d3 ee                	shr    %cl,%esi
  802471:	09 d0                	or     %edx,%eax
  802473:	89 f2                	mov    %esi,%edx
  802475:	83 c4 1c             	add    $0x1c,%esp
  802478:	5b                   	pop    %ebx
  802479:	5e                   	pop    %esi
  80247a:	5f                   	pop    %edi
  80247b:	5d                   	pop    %ebp
  80247c:	c3                   	ret    
  80247d:	8d 76 00             	lea    0x0(%esi),%esi
  802480:	29 f9                	sub    %edi,%ecx
  802482:	19 d6                	sbb    %edx,%esi
  802484:	89 74 24 04          	mov    %esi,0x4(%esp)
  802488:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80248c:	e9 18 ff ff ff       	jmp    8023a9 <__umoddi3+0x69>
